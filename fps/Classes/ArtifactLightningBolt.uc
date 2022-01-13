class ArtifactLightningBolt extends EnhancedRPGArtifact
	config(fps);

var RPGRules Rules;
var class<xEmitter> HitEmitterClass;
var config float TargetRadius;
var config int DamagePerAdrenaline;
var config int MaxDamage;
var config int AdrenalineForMiss;

function BotConsider()
{
	if (Instigator.Controller.Adrenaline < 30)
		return;

	if ( !bActive && Instigator.Controller.Enemy != None
		   && Instigator.Controller.CanSee(Instigator.Controller.Enemy) && NoArtifactsActive() && FRand() < 0.5 )
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

function Activate()
{
	local Controller C, BestC;
	local xEmitter HitEmitter;
	local int MostHealth, NewHealth, HealthTaken;
	local int UDamageAdjust, DamageToDo, ExtraDamage;
	local bool RunningTriple;
	local Vehicle V;
	local Actor A;

	if ((Instigator == None) || (Instigator.Controller == None))
	{
		bActive = false;
		GotoState('');
		return;
	}

	if (LastUsedTime + TimeBetweenUses > Instigator.Level.TimeSeconds)
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

	C = Level.ControllerList;
	BestC = None;
	MostHealth = 0;
	while (C != None)
	{
		if (C.Pawn != None && C.Pawn != Instigator && C.Pawn.Health > 0 && !C.SameTeamAs(Instigator.Controller)
		     && VSize(C.Pawn.Location - Instigator.Location) < TargetRadius && FastTrace(C.Pawn.Location, Instigator.Location) && C.bGodMode == False)
		{
			if (C.Pawn.Health > MostHealth)
			{
				MostHealth = C.Pawn.Health;
				BestC = C;
			}
		}
		C = C.NextController;
	}
	if ((MostHealth > 0) && (BestC != None) && (BestC.Pawn != None))
	{
		HitEmitter = spawn(HitEmitterClass,,, Instigator.Location, rotator(BestC.Pawn.Location - Instigator.Location));
		if (HitEmitter != None)
			HitEmitter.mSpawnVecA = BestC.Pawn.Location;

		A = spawn(class'BlueSparks',,, Instigator.Location);
		if (A != None)
		{
			A.RemoteRole = ROLE_SimulatedProxy;
			A.PlaySound(Sound'WeaponSounds.LightningGun.LightningGunImpact',,1.5*Instigator.TransientSoundVolume,,Instigator.TransientSoundRadius);
		}
		A = spawn(class'BlueSparks',,, BestC.Pawn.Location);
		if (A != None)
		{
			A.RemoteRole = ROLE_SimulatedProxy;
			A.PlaySound(Sound'WeaponSounds.LightningGun.LightningGunImpact',,1.5*BestC.Pawn.TransientSoundVolume,,BestC.Pawn.TransientSoundRadius);
		}

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

			if (BestC.Pawn.Health > DamageToDo)
			{
				ExtraDamage = min(DamageToDo, BestC.Pawn.Health - DamageToDo);
				if (Rules == None)
					CheckRPGRules();
				if (Rules != None)
				    Rules.AwardEXPForDamage(Instigator.Controller, RPGStatsInv(Instigator.FindInventoryType(class'RPGStatsInv')), BestC.Pawn, ExtraDamage);
			}
		}
		else
			UDamageAdjust = 1;

		BestC.Pawn.TakeDamage(DamageToDo, Instigator, BestC.Pawn.Location, vect(0,0,0), class'DamTypeLightningBolt');

		if (BestC == None || BestC.Pawn == None || BestC.Pawn.Health <= 0)
			class'ArtifactLightningBeam'.static.AddArtifactKill(Instigator, class'WeaponBolt');

		NewHealth = 0;
		if (BestC != None && BestC.Pawn != None)
			NewHealth = BestC.Pawn.Health;
		if (NewHealth < 0)
			NewHealth = 0;
		HealthTaken = MostHealth - NewHealth;
		if (HealthTaken < 0)
			HealthTaken = MostHealth;

		if (!RunningTriple)
			Instigator.Controller.Adrenaline -= (HealthTaken*AdrenalineUsage) / (DamagePerAdrenaline * UDamageAdjust);
		else
			Instigator.Controller.Adrenaline -= (HealthTaken*AdrenalineUsage) / DamagePerAdrenaline;

		if (Instigator.Controller.Adrenaline < 0)
			Instigator.Controller.Adrenaline = 0;

		SetRecoveryTime(TimeBetweenUses);
	}
	else
	{
		Instigator.Controller.Adrenaline -= (AdrenalineForMiss*AdrenalineUsage);
		if (Instigator.Controller.Adrenaline < 0)
			Instigator.Controller.Adrenaline = 0;

		SetRecoveryTime(TimeBetweenUses);
	}
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
     HitEmitterClass=Class'fps.LightningBoltEmitter'
     TargetRadius=2000.000000
     DamagePerAdrenaline=4
     MaxDamage=100
     AdrenalineForMiss=10
     TimeBetweenUses=1.500000
     CostPerSec=1
     MinActivationTime=0.000001
     PickupClass=Class'fps.ArtifactLightningBoltPickup'
     IconMaterial=Texture'ArtifactIcons.bolt'
     ItemName="Lightning Bolt"
}
