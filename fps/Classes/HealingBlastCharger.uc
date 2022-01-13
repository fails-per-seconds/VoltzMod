class HealingBlastCharger extends Actor;

var xEmitter ChargeEmitter;
var Controller InstigatorController;

var float ChargeTime;
var float MaxHealing;
var float MinHealing;
var float HealingRadius;
var RPGRules RPGRules;
var float EXPMultiplier;
var int MaxHealth;

var Material EffectOverlay;

function DoHealing(float Radius)
{
	local float healingScale, dist;
	local vector dir;
	local Controller C;
	local Pawn P;
	local int HealthGiven, localMaxHealth;
	local xPawn xP;

	if (Instigator == None && InstigatorController != None)
		Instigator = InstigatorController.Pawn;

	if (Instigator == None || Instigator.Health <= 0 || Instigator.Controller == None)
		return;

	C = Level.ControllerList;
	while (C != None)
	{
		if ( C.Pawn != None && C.Pawn.Health > 0 && Instigator != None && C.SameTeamAs(Instigator.Controller)
		     && VSize(C.Pawn.Location - Location) < Radius && FastTrace(C.Pawn.Location, Location) )
		{
			P = C.Pawn;

			if (P != None && P.isA('Vehicle'))
				P = Vehicle(P).Driver;
			if (P != None && Instigator != None && P.GetTeam() == Instigator.GetTeam() && Instigator.GetTeam() != None)
			{
				if (P == Instigator)
				{
					localMaxHealth = MaxHealth;

					xP = xPawn(P);
					if (xP != None && xP.CurrentCombo != None && xP.CurrentCombo.Name == 'ComboDefensive')
						localMaxHealth = class'RW_Healer'.default.MaxHealth;

					dir = C.Pawn.Location - Location;
					dist = FMax(1,VSize(dir));
					healingScale = 1 - FMax(0,dist/Radius);

					HealthGiven = max(1,(healingScale * (MaxHealing-MinHealing)) + MinHealing);
					HealthGiven = min((P.HealthMax + localMaxHealth) - P.Health, HealthGiven);

					if (HealthGiven > 0)
					{
						P.GiveHealth(HealthGiven, P.HealthMax + localMaxHealth);
						P.SetOverlayMaterial(EffectOverlay, 0.5, false);
						if (Instigator != P)
						{
							doHealed(HealthGiven, P, localMaxHealth);
							if (PlayerController(C) != None)
							{
								PlayerController(C).ReceiveLocalizedMessage(class'HealedConditionMessage', 0, Instigator.PlayerReplicationInfo);
		
								P.PlaySound(sound'PickupSounds.HealthPack',, 2 * P.TransientSoundVolume,, 1.5 * P.TransientSoundRadius);
							}
						}
					}
				}

			}
		}

		C = C.NextController;
	}
}

function doHealed(int HealthGiven, Pawn Victim, int localMaxHealth)
{
	local HealableDamageInv Inv;
	local int ValidHealthGiven;
	local float GrantExp;
	local RPGStatsInv StatsInv;

	if (RPGRules == None)
		return;

	if (Victim.Controller != None && Victim.Controller.IsA('FriendlyMonsterController'))
		return;

	if (Instigator == Victim) 
		return;

	Inv = HealableDamageInv(Victim.FindInventoryType(class'HealableDamageInv'));
	if (Inv != None)
	{
		ValidHealthGiven = Min(HealthGiven, Inv.Damage);
		if (ValidHealthGiven > 0)
		{
			StatsInv = RPGStatsInv(Instigator.FindInventoryType(class'RPGStatsInv'));
			if (StatsInv == None)
			{
				log("Warning: No stats inv found. Healing exp not granted.");
				return;
			}

			GrantExp = EXPMultiplier * float(ValidHealthGiven);

			Inv.Damage -= ValidHealthGiven;

			RPGRules.ShareExperience(StatsInv, GrantExp);
		}

		if (Inv.Damage > (Victim.HealthMax + Class'HealableDamageGameRules'.default.MaxHealthBonus) - Victim.Health)
			Inv.Damage = Max(0, (Victim.HealthMax + Class'HealableDamageGameRules'.default.MaxHealthBonus) - Victim.Health);
		else if (Inv.Damage < 0)
			Inv.Damage = 0;
	}
}

simulated function PostBeginPlay()
{
	if (Level.NetMode != NM_DedicatedServer)
		ChargeEmitter = spawn(class'HealingChargeEmitter');

	if (Role == ROLE_Authority)
		InstigatorController = Controller(Owner);

	super.PostBeginPlay();
}

simulated function Destroyed()
{
	if (ChargeEmitter != None)
		ChargeEmitter.Destroy();

	Super.Destroyed();
}

auto state Charging
{
Begin:
	if (Instigator != None)
	{

		Sleep(ChargeTime);
		if (Instigator != None && Instigator.Health > 0)
			spawn(class'HealingExplosion');
		bHidden = true;
		if (ChargeEmitter != None)
			ChargeEmitter.Destroy();
		if (Instigator != None && Instigator.Health > 0)
		{
			MakeNoise(1.0);
			PlaySound(sound'WeaponSounds.redeemer_explosionsound');
			DoHealing(HealingRadius);
		}
	}
	else if (ChargeEmitter != None)
		ChargeEmitter.Destroy();

	Destroy();
}

defaultproperties
{
     ChargeTime=2.000000
     MaxHealing=500.000000
     MinHealing=100.000000
     HealingRadius=2200.000000
     EffectOverlay=Shader'BlueShader'
     DrawType=DT_None
     TransientSoundVolume=1.000000
     TransientSoundRadius=5000.000000
}
