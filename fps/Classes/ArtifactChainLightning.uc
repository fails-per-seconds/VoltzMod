class ArtifactChainLightning extends EnhancedRPGArtifact
	config(fps);

var class<xEmitter> HitEmitterClass;
var config float MaxRange, MaxStepRange, StepDamageFraction;
var config int AdrenalineForMiss, AdrenalineForHit;
var config int FirstDamage, MaxSteps;

var array<Pawn> ChainHitPawn;
var array<int> ChainStepNumber;
var array<vector> ChainHitLocation;
var array<int> ChainActive;
var RPGRules Rules;

function BotConsider()
{
	if (Instigator.Controller.Adrenaline < 20)
		return;

	if ( !bActive && NoArtifactsActive() && FRand() < 0.8 && BotFireBeam())
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
	local Pawn  HitPawn;
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

function ChainPawn(Pawn Victim, vector HitLocation, vector StartLocation, int StepNumber)
{
	local int i, DamageToDo, UDamageAdjust, ExtraDamage;
	local float CurPercent;
	local bool RunningTriple;
	local xEmitter HitEmitter;
	local Actor A;

	if (StepNumber > MaxSteps)
		return;

	for(i = 0; i < ChainHitPawn.length; i++)
		if (ChainHitPawn[i] == Victim)
			return;

	if (StepNumber < MaxSteps)
	{
		ChainHitPawn[ChainHitPawn.length] = Victim;
		ChainStepNumber[ChainStepNumber.length] = StepNumber;
		ChainHitLocation[ChainHitLocation.length] = HitLocation;
		ChainActive[ChainActive.length] = 1;
	}

	HitEmitter = spawn(HitEmitterClass,,,StartLocation , rotator(HitLocation - StartLocation));
	if (HitEmitter != None)
	{
		HitEmitter.mSpawnVecA = Victim.Location;
	}

	A = spawn(class'BlueSparks',,, Victim.Location);
	if (A != None)
	{
		A.RemoteRole = ROLE_SimulatedProxy;
		A.PlaySound(Sound'WeaponSounds.LightningGun.LightningGunImpact',,1.5*Victim.TransientSoundVolume,,Victim.TransientSoundRadius);
	}

	CurPercent = 1.0;
	for (i = 0; i < StepNumber; i++)
		CurPercent *= StepDamageFraction;

	DamageToDo = FirstDamage * CurPercent;

	RunningTriple = false;
	if (Instigator != None && Instigator.HasUDamage())
	{
		UDamageAdjust = 2;
		if (class'ArtifactDoubleModifier'.static.HasTripleRunning(Instigator))
		{
			RunningTriple = true;
			DamageToDo = DamageToDo/UDamageAdjust;
		}

		if (Victim.Health > DamageToDo)
		{
			ExtraDamage = min(DamageToDo, Victim.Health - DamageToDo);
			if (Rules == None)
				CheckRPGRules();
			if (Rules != None)
			    Rules.AwardEXPForDamage(Instigator.Controller, RPGStatsInv(Instigator.FindInventoryType(class'RPGStatsInv')), Victim, ExtraDamage);
		}
	}
	else
		UDamageAdjust = 1;

	Victim.TakeDamage(DamageToDo, Instigator, Victim.Location, vect(0,0,0), class'DamTypeLightningBolt');

	if (Victim == None || Victim.Health <= 0)
		class'ArtifactLightningBeam'.static.AddArtifactKill(Instigator,class'WeaponChainLightning');
}


function Activate()
{	
	local Vehicle V;
	local vector FaceDir;
	local vector StartTrace;
	local vector BeamEndLocation;
	local vector HitLocation;
	local vector HitNormal;
	local Pawn HitPawn;
	local Actor AHit;
	local Actor A;

	if ((Instigator == None) || (Instigator.Controller == None))
		return;

	if (LastUsedTime + (TimeBetweenUses*AdrenalineUsage) > Instigator.Level.TimeSeconds)
	{
		Instigator.ReceiveLocalizedMessage(MessageClass, 5000, None, None, Class);
		bActive = false;
		GotoState('');
		return;
	}
	if (Instigator.Controller.Adrenaline < (AdrenalineForHit*AdrenalineUsage))
	{
		Instigator.ReceiveLocalizedMessage(MessageClass, AdrenalineForHit*AdrenalineUsage, None, None, Class);
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

	ChainHitPawn.length = 0;
	ChainStepNumber.length = 0;
	ChainHitLocation.length = 0;
	ChainActive.length = 0;

	HitPawn = Pawn(AHit);
	if (HitPawn != Instigator && HitPawn.Health > 0 && !HitPawn.Controller.SameTeamAs(Instigator.Controller)
	     && VSize(HitPawn.Location - StartTrace) < MaxRange && HitPawn.Controller.bGodMode == False)
	{
		Instigator.Controller.Adrenaline -= AdrenalineForHit * AdrenalineUsage;                          

		if (Instigator.Controller.Adrenaline < 0)
			Instigator.Controller.Adrenaline = 0;

		SetRecoveryTime(TimeBetweenUses*AdrenalineUsage);

		A = spawn(class'BlueSparks',,, Instigator.Location);
		if (A != None)
		{
			A.RemoteRole = ROLE_SimulatedProxy;
			A.PlaySound(Sound'WeaponSounds.LightningGun.LightningGunImpact',,1.5*Instigator.TransientSoundVolume,,Instigator.TransientSoundRadius);
		}

		ChainPawn(HitPawn, HitLocation, (StartTrace + Instigator.Location)/2, 0);
	}

	SetTimer(0.2, true);
}

function Timer()
{
	local Controller C, NextC;
	local vector Ploc;
	local int i, j, besti;
	local int minStepNo, NumActiveChainEntries;
	local float CurPercent;
	local bool bGotLive;

	if (Instigator == None || Instigator.Controller == None || ChainHitPawn.length == 0)
	{
		ChainHitPawn.length = 0;
		ChainStepNumber.length = 0;
		ChainHitLocation.length = 0;
		ChainActive.length = 0;
		SetTimer(0, false);
		return;		
	}

	bGotLive = false;
	for (i = 0; i < ChainActive.length; i++)
		if (ChainActive[i] > 0)
			bGotLive = true;
	if (!bGotLive)
	{
		ChainHitPawn.length = 0;
		ChainStepNumber.length = 0;
		ChainHitLocation.length = 0;
		ChainActive.length = 0;
		SetTimer(0, false);
		return;		
	}

	for (i = 0; i < ChainStepNumber.length; i++)
		ChainStepNumber[i]++;
	NumActiveChainEntries = ChainStepNumber.length;
	
	C = Level.ControllerList;
	while (C != None)
	{
		NextC = C.NextController;
		if (C.Pawn != None && C.Pawn != Instigator && C.Pawn.Health > 0 && !C.SameTeamAs(Instigator.Controller) && C.bGodMode == False)
		{
			bGotLive = false;
			for (i = 0; i < ChainHitPawn.length; i++)
				if (ChainHitPawn[i] == C.Pawn)
					bGotLive = true;

			if (!bGotLive)
			{			
				minStepNo = MaxSteps+1;
				besti = -1;
				for (i = 0; i < ChainHitPawn.length; i++)
				{
					if (ChainHitPawn[i] == None)
						Ploc = ChainHitLocation[i];
					else
						Ploc = ChainHitPawn[i].Location;
					if (ChainStepNumber[i] <= MaxSteps && FastTrace(C.Pawn.Location, Ploc))
					{
						CurPercent = 1.0;
						for (j = 1; j < ChainStepNumber[i]; j++)
							CurPercent *= StepDamageFraction;
						if (VSize(C.Pawn.Location - Ploc) < (MaxStepRange * CurPercent) && minStepNo > ChainStepNumber[i])
						{
							minStepNo = ChainStepNumber[i];
							besti = i;
						}
					}
				}
				if (besti >= 0)
				{
					if (ChainHitPawn[besti] == None)
						Ploc = ChainHitLocation[besti];
					else
						Ploc = ChainHitPawn[besti].Location;
					ChainPawn(C.Pawn, C.Pawn.Location, Ploc, minStepNo);
				}
			
			}		
		}

		C = NextC;
	}
	
	for (i = 0; i < NumActiveChainEntries; i++)
		ChainActive[i] = 0;
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
     HitEmitterClass=Class'fps.RedBoltEmitter'
     MaxRange=3000.000000
     MaxStepRange=650.000000
     AdrenalineForMiss=4
     AdrenalineForHit=50
     FirstDamage=180
     StepDamageFraction=0.700000
     MaxSteps=3
     TimeBetweenUses=2.000000
     CostPerSec=1
     MinActivationTime=0.000001
     IconMaterial=Texture'AW-2004Particles.Weapons.PlasmaHeadRed'
     ItemName="Chain Lightning"
}
