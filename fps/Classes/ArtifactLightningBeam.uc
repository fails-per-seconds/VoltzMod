class ArtifactLightningBeam extends EnhancedRPGArtifact
	config(fps);

var RPGRules Rules;
var class<xEmitter> HitEmitterClass;
var config float MaxRange;
var config int DamagePerAdrenaline;
var config int AdrenalineForMiss;
var config int MaxDamage;

function BotConsider()
{
	if (Instigator.Controller.Adrenaline < 20)
		return;

	if ( !bActive && NoArtifactsActive() && FRand() < 0.3 && BotFireBeam())
		Activate();
}

function PostBeginPlay()
{
	super.PostBeginPlay();
	disable('Tick');

	CheckRPGRules();
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

function bool BotFireBeam()
{
	local vector FaceDir;
	local vector BeamEndLocation;
	local vector StartTrace;
	local vector HitLocation;
	local vector HitNormal;
	local Pawn HitPawn;
	local Actor AHit;

	FaceDir = Vector(Instigator.Controller.GetViewRotation());
	StartTrace = Instigator.Location + Instigator.EyePosition();
	BeamEndLocation = StartTrace + (FaceDir * MaxRange);

	AHit = Trace(HitLocation, HitNormal, BeamEndLocation, StartTrace, true);
	if ((AHit == None) || (Pawn(AHit) == None) || (Pawn(AHit).Controller == None))
		return false;

	HitPawn = Pawn(AHit);
	if (HitPawn != Instigator && HitPawn.Health > 0 && !HitPawn.Controller.SameTeamAs(Instigator.Controller)
		&& VSize(HitPawn.Location - StartTrace) < MaxRange && HitPawn.Controller.bGodMode == False)
	{
		return true;
	}

	return false;
}

function Activate()
{
	local Vehicle V;
	local vector FaceDir;
	local vector BeamEndLocation;
	local vector StartTrace;
	local vector HitLocation;
	local vector HitNormal;
	local Actor AHit;
	local Actor A;
	local Pawn HitPawn;
	local xEmitter HitEmitter;
	local int StartHealth, NewHealth, HealthTaken;
	local int UDamageAdjust, DamageToDo, ExtraDamage;
	local float ataken;
	local bool RunningTriple;

	if ((Instigator == None) || (Instigator.Controller == None))
	{
		bActive = false;
		GotoState('');
		return;
	}

	if (LastUsedTime + (TimeBetweenUses*AdrenalineUsage) > Instigator.Level.TimeSeconds)
	{
		Instigator.ReceiveLocalizedMessage(MessageClass, 5000, None, None, Class);
		bActive = false;
		GotoState('');
		return;
	}
	if (Instigator.Controller.Adrenaline < (AdrenalineForMiss*AdrenalineUsage))
	{
		Instigator.ReceiveLocalizedMessage(MessageClass, AdrenalineForMiss*AdrenalineUsage, None, None, Class);
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

	FaceDir = Vector(Instigator.Controller.GetViewRotation());
	StartTrace = Instigator.Location + Instigator.EyePosition();
	BeamEndLocation = StartTrace + (FaceDir * MaxRange);

	AHit = Trace(HitLocation, HitNormal, BeamEndLocation, StartTrace, true);
	if ((AHit == None) || (Pawn(AHit) == None) || (Pawn(AHit).Controller == None))
	{
		Instigator.Controller.Adrenaline -= (AdrenalineForMiss*AdrenalineUsage);
		if (Instigator.Controller.Adrenaline < 0)
			Instigator.Controller.Adrenaline = 0;

		bActive = false;
		GotoState('');
		return;
	}

	HitPawn = Pawn(AHit);
	if (HitPawn != Instigator && HitPawn.Health > 0 && !HitPawn.Controller.SameTeamAs(Instigator.Controller)
	     && VSize(HitPawn.Location - StartTrace) < MaxRange && HitPawn.Controller.bGodMode == False)
	{
		HitEmitter = spawn(HitEmitterClass,,, (StartTrace + Instigator.Location)/2, rotator(HitLocation - ((StartTrace + Instigator.Location)/2)));
		if (HitEmitter != None)
		{
			HitEmitter.mSpawnVecA = HitPawn.Location;
		}

		A = spawn(class'BlueSparks',,, Instigator.Location);
		if (A != None)
		{
			A.RemoteRole = ROLE_SimulatedProxy;
			A.PlaySound(Sound'WeaponSounds.LightningGun.LightningGunImpact',,1.5*Instigator.TransientSoundVolume,,Instigator.TransientSoundRadius);
		}
		A = spawn(class'BlueSparks',,, HitPawn.Location);
		if (A != None)
		{
			A.RemoteRole = ROLE_SimulatedProxy;
			A.PlaySound(Sound'WeaponSounds.LightningGun.LightningGunImpact',,1.5*HitPawn.TransientSoundVolume,,HitPawn.TransientSoundRadius);
		}

		StartHealth = HitPawn.Health;

		DamageToDo = min(MaxDamage,DamagePerAdrenaline * (Instigator.Controller.Adrenaline/AdrenalineUsage));

		RunningTriple = false;
		if (Instigator.HasUDamage())
		{
			UDamageAdjust = 2;
			if (class'ArtifactDoubleModifier'.static.HasTripleRunning(Instigator))
			{
				RunningTriple = true;
				DamageToDo = DamageToDo/UDamageAdjust;
			}

			if (StartHealth > DamageToDo)
			{
				ExtraDamage = min(DamageToDo, StartHealth - DamageToDo); 
				if (Rules == None)
					CheckRPGRules();
				if (Rules != None)
				    Rules.AwardEXPForDamage(Instigator.Controller, RPGStatsInv(Instigator.FindInventoryType(class'RPGStatsInv')), HitPawn, ExtraDamage);
			}
		}
		else
			UDamageAdjust = 1;

		HitPawn.TakeDamage(DamageToDo, Instigator, HitPawn.Location, vect(0,0,0), class'DamTypeLightningBolt');

		if (HitPawn == None || HitPawn.Health <= 0)
			AddArtifactKill(Instigator,class'WeaponBeam');

		NewHealth = 0;
		if (HitPawn != None)
			NewHealth = HitPawn.Health;
		if (NewHealth < 0)
			NewHealth = 0;
		HealthTaken = StartHealth - NewHealth;
		if (HealthTaken < 0)
			HealthTaken = StartHealth;

		if (!RunningTriple)
			ataken = (HealthTaken*AdrenalineUsage) / (DamagePerAdrenaline * UDamageAdjust);
		else
			ataken = (HealthTaken*AdrenalineUsage) / DamagePerAdrenaline;
		Instigator.Controller.Adrenaline -= ataken;                          

		if (Instigator.Controller.Adrenaline < 0)
			Instigator.Controller.Adrenaline = 0;

		SetRecoveryTime(TimeBetweenUses*AdrenalineUsage);
	}
}

static function AddArtifactKill(Pawn P,class<Weapon> W)
{
	local int i;
	local TeamPlayerReplicationInfo TPPI;
	local TeamPlayerReplicationInfo.WeaponStats NewWeaponStats;

	if (P == None || W == None)
		return;

	TPPI = TeamPlayerReplicationInfo(P.PlayerReplicationInfo);
	if (TPPI == None)
		return;

	for (i = 0; i < TPPI.WeaponStatsArray.Length && i < 200; i++)
	{
		if (TPPI.WeaponStatsArray[i].WeaponClass == W)
		{
			TPPI.WeaponStatsArray[i].Kills++;
			return;
		}
	}

	NewWeaponStats.WeaponClass = W;
	NewWeaponStats.Kills = 1;
	TPPI.WeaponStatsArray[TPPI.WeaponStatsArray.Length] = NewWeaponStats;
}

static function string GetLocalString(optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2)
{
	if (Switch == 3000)
		return "Cannot use this artifact inside a vehicle";
	else if (Switch == 5000)
		return "Cannot use this artifact again yet";
	else
		return "At least" @ switch @ "adrenaline is required to use this artifact";
}

defaultproperties
{
     HitEmitterClass=Class'fps.LightningBeamEmitter'
     MaxRange=3000.000000
     DamagePerAdrenaline=7
     AdrenalineForMiss=4
     MaxDamage=180
     TimeBetweenUses=0.500000
     CostPerSec=1
     MinActivationTime=0.000001
     PickupClass=Class'fps.ArtifactLightningBeamPickup'
     IconMaterial=Texture'ArtifactIcons.beam'
     ItemName="Lightning Beam"
}
