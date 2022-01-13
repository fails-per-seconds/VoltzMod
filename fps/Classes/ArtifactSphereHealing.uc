class ArtifactSphereHealing extends EnhancedRPGArtifact
		config(fps);

var config int AdrenalineRequired;
var config int AdrenalinePerSecond;
var config int HealthPerSecond;
var config float EffectRadius;

var RPGRules Rules;
var vector SpawnLocation;
var Material EffectOverlay;
var float EXPMultiplier;
var int MaxHealth;
var ArtifactMakeSuperHealer AMSH;

function BotConsider()
{
	if (bActive && Instigator.Health > 200)
	{
		Activate();
		return;
	}

	if (Instigator.Controller.Adrenaline < AdrenalineRequired*2)
		return;

	if ( !bActive && Instigator.Health < 125 && NoArtifactsActive() && FRand() < 0.6 )
		Activate();
}

function PreBeginPlay()
{
	local GameRules G;
	local HealableDamageGameRules SG;

	super.PreBeginPlay();

	if (Level.Game == None)
		return;

	if (Level.Game.GameRulesModifiers == None)
	{
		SG = Level.Game.Spawn(class'HealableDamageGameRules');
		if (SG == None)
			log("Warning: Unable to spawn HealableDamageGameRules for Sphere of healing. EXP for Healing will not occur.");
		else
			Level.Game.GameRulesModifiers = SG;
	}
	else
	{
		for(G = Level.Game.GameRulesModifiers; G != None; G = G.NextGameRules)
		{
			if (G.IsA('HealableDamageGameRules'))
			{
				SG = HealableDamageGameRules(G);
				break;
			}
			if (G.NextGameRules == None)
			{
				SG = Level.Game.Spawn(class'HealableDamageGameRules');
				if (SG == None)
				{
					log("Warning: Unable to spawn HealableDamageGameRules for Sphere of healing. Healing for EXP will not occur.");
					return;
				}

				Level.Game.GameRulesModifiers.AddGameRules(SG);
				break;
			}
		}
	}
}

simulated function PostBeginPlay()
{
	CostPerSec = AdrenalinePerSecond*AdrenalineUsage;

	super.PostBeginPlay();

	CheckRPGRules();
}

function EnhanceArtifact(float Adusage)
{
	Super.EnhanceArtifact(AdUsage);

	CostPerSec = AdrenalinePerSecond * AdrenalineUsage;
}

function CheckRPGRules()
{
	local GameRules G;

	if (Level.Game == None)
		return;

	for(G = Level.Game.GameRulesModifiers; G != None; G = G.NextGameRules)
	{
		if (G.IsA('RPGRules'))
		{
			Rules = RPGRules(G);
			break;
		}
	}

	if (Rules == None)
		Log("WARNING: Unable to find RPGRules in GameRules. EXP will not be properly awarded");
}

function HealTeam(vector CoreLocation)
{
	local Controller C;
	local Pawn P;
	local int HealthGiven, localMaxHealth;
	local xPawn xP;

	HealthGiven = Min((Instigator.HealthMax + MaxHealth) - Instigator.Health, HealthPerSecond/2);
	if (HealthGiven > 0)
	{
		Instigator.GiveHealth(HealthGiven, Instigator.HealthMax + MaxHealth);
	}

	C = Level.ControllerList;
	while (C != None)
	{
		if (C.Pawn != None && C.Pawn != Instigator && C.Pawn.Health > 0 && C.SameTeamAs(Instigator.Controller) && VSize(C.Pawn.Location - CoreLocation) < EffectRadius)
		{
			P = C.Pawn;

			localMaxHealth = MaxHealth;
			xP = xPawn(P);
			if (xP != None && xP.CurrentCombo != None && xP.CurrentCombo.Name == 'ComboDefensive')
				localMaxHealth = class'RW_Healer'.default.MaxHealth;

			if (P != None && P.IsA('Vehicle'))
				P = Vehicle(P).Driver;
			if (P != None && ((P.Controller != None && P.Controller.IsA('FriendlyMonsterController') && FriendlyMonsterController(P.Controller).Master == Instigator.Controller)
				|| (P.GetTeam() == Instigator.GetTeam() && Instigator.GetTeam() != None)))
			{
				HealthGiven = HealthPerSecond/2;
			
				HealthGiven = Min((P.HealthMax + localMaxHealth) - P.Health, HealthGiven);
				if (HealthGiven > 0)
				{
					P.GiveHealth(HealthGiven, P.HealthMax + localMaxHealth);
					P.SetOverlayMaterial(EffectOverlay, 0.5, false);
					if (Instigator != P)
					{
						if (P.Controller != None && !P.Controller.IsA('FriendlyMonsterController'))
							doHealed(HealthGiven, P, localMaxHealth);
					}
				}

				if (HealthGiven > 0 && P != None && P.Controller != None && PlayerController(P.Controller) != None)	
				{
					PlayerController(P.Controller).ReceiveLocalizedMessage(class'HealedConditionMessage', 0, Instigator.PlayerReplicationInfo);
					P.PlaySound(sound'PickupSounds.HealthPack',, 2 * P.TransientSoundVolume,, 1.5 * P.TransientSoundRadius);
				}
			}
		}
		C = C.NextController;
	}
}

function doHealed(int HealthGiven, Pawn Victim, int localMaxHealth)
{
	local int ValidHealthGiven;
	local float GrantExp;
	local RPGStatsInv StatsInv;
	local HealableDamageInv Inv;

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

			Rules.ShareExperience(StatsInv, GrantExp);
		}

		if (Inv.Damage > (Victim.HealthMax + Class'HealableDamageGameRules'.default.MaxHealthBonus) - Victim.Health)
			Inv.Damage = Max(0, (Victim.HealthMax + Class'HealableDamageGameRules'.default.MaxHealthBonus) - Victim.Health);
	}
}

state Activated
{
	function BeginState()
	{
		local Vehicle V;

		if (Rules == None)
			CheckRPGRules();

		if ((Instigator != None) && (Instigator.Controller != None))
		{
			if (Instigator.Controller.Adrenaline < (AdrenalineRequired*AdrenalineUsage))
			{
				Instigator.ReceiveLocalizedMessage(MessageClass, AdrenalineRequired*AdrenalineUsage, None, None, Class);
				bActive = false;
				GotoState('');
				return;
			}
		
			V = Vehicle(Instigator);
			if (V != None)
			{
				Instigator.ReceiveLocalizedMessage(MessageClass, 3000, None, None, Class);
				bActive = false;
				GotoState('');
				return;
			}

			SpawnLocation = Instigator.Location;
			switch (EffectRadius) 
			{
				case 500:
					spawn(class'SphereHealing500r', Instigator.Controller,,SpawnLocation);
					break;
				case 700:
					spawn(class'SphereHealing700r', Instigator.Controller,,SpawnLocation);
					break;
				default:
					Log("ArtifactSphereHealing invalid radius used. Should be 500");
					spawn(class'SphereHealing500r', Instigator.Controller,,SpawnLocation);
					break;
			}
			bActive = true;

			ExpMultiplier = getExpMultiplier();
			MaxHealth = getMaxHealthBonus();

			HealTeam(SpawnLocation);
			SetTimer(0.5, true);
		}
	}
	function Timer()
	{
		if (bActive)
		{
			if (Instigator.Controller == None)
			{
				bActive = false;
				GotoState('');
				return;	
			}
			switch (EffectRadius) 
			{
				case 500:
					spawn(class'SphereHealing500r', Instigator.Controller,,SpawnLocation);
					break;
				case 700:
					spawn(class'SphereHealing700r', Instigator.Controller,,SpawnLocation);
					break;
				default:
					spawn(class'SphereHealing500r', Instigator.Controller,,SpawnLocation);
					break;
			}
			HealTeam(SpawnLocation);
		}
	}
	function EndState()
	{
		SetTimer(0, false);
		bActive = false;
	}
}

function int getMaxHealthBonus()
{
	if (AMSH == None)
		AMSH = ArtifactMakeSuperHealer(Instigator.FindInventoryType(class'ArtifactMakeSuperHealer'));
	if (AMSH != None)
		return AMSH.MaxHealth;
	else
		return class'RW_Healer'.default.MaxHealth;
}

function float getExpMultiplier()
{
	if (AMSH == None)
		AMSH = ArtifactMakeSuperHealer(Instigator.FindInventoryType(class'ArtifactMakeSuperHealer'));
	if (AMSH != None)
		return AMSH.EXPMultiplier;
	else
		return class'RW_Healer'.default.EXPMultiplier;
}

exec function TossArtifact()
{
	//do nothing.
}

function DropFrom(vector StartLocation)
{
	if (bActive)
		GotoState('');
	bActive = false;

	Destroy();
	Instigator.NextItem();
}

static function string GetLocalString(optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2)
{
	if (Switch == 3000)
		return "Cannot use this artifact inside a vehicle";
	else if (Switch == 0)
		return "Your adrenaline has run out.";
	else
		return switch @ "Adrenaline is required to use this artifact";
}

defaultproperties
{
     AdrenalineRequired=28
     AdrenalinePerSecond=7
     HealthPerSecond=15
     EffectRadius=900.000000
     EffectOverlay=Shader'BlueShader'
     CostPerSec=7
     PickupClass=Class'fps.ArtifactSphereHealingPickup'
     IconMaterial=Texture'ArtifactIcons.SphereHealing'
     ItemName="Healing Sphere"
}
