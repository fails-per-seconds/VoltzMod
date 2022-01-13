class ArtifactLightningRod extends EnhancedRPGArtifact
	config(fps);

var config float CostPerHit, HealthMultiplier;
var config int MaxDamagePerHit, MinDamagePerHit;
var float TargetRadius;
var class<xEmitter> HitEmitterClass;

var RPGRules Rules;

function PostBeginPlay()
{
	super.PostBeginPlay();

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

function EnhanceArtifact(float Adusage)
{
	AdrenalineUsage = (AdUsage + 2.0)/3.0;
}

function BotConsider()
{
	if (bActive && (Instigator.Controller.Enemy == None || !Instigator.Controller.CanSee(Instigator.Controller.Enemy)))
	{
		Activate();
		return;
	}
		
	if (Instigator.Controller.Adrenaline < 30)
		return;

	if ( !bActive && Instigator.Controller.Enemy != None && Instigator.Controller.CanSee(Instigator.Controller.Enemy) && NoArtifactsActive())
	{ 
		if (Instigator.HasUDamage())
			Activate();
		else if (FRand() < 0.7)
			Activate();
	}
}

function Activate()
{
	if (class'ArtifactDoubleModifier'.static.HasTripleRunning(Instigator))
		return;

	Super.Activate();
}

state Activated
{
	function Timer()
	{
		local Controller C, NextC;
		local xEmitter HitEmitter;
		local int DamageDealt, UDamageAdjust;
		local int lCost, ExtraDamage;
		local bool RunningTriple;

		if (Instigator == None || Instigator.Controller == None)
			return;

		if (VSize(Instigator.Velocity) ~= 0)
			return;

		RunningTriple = false;
		if (Instigator.HasUDamage())
		{
			UDamageAdjust = 2;
			if (class'ArtifactDoubleModifier'.static.HasTripleRunning(Instigator))
				RunningTriple = true;
		}
		else
			UDamageAdjust = 1;

		C = Level.ControllerList;
		while (C != None)
		{
			NextC = C.NextController;

			if (C == None)
			{
				C = NextC;
				break;
			}

			if (C.Pawn != None && Instigator != None && C.Pawn != Instigator && C.Pawn.Health > 0 && !C.SameTeamAs(Instigator.Controller)
			     && VSize(C.Pawn.Location - Instigator.Location) < TargetRadius && FastTrace(C.Pawn.Location, Instigator.Location))
			{
				DamageDealt = max(min(C.Pawn.HealthMax * HealthMultiplier, MaxDamagePerHit), MinDamagePerHit);

				lCost = (DamageDealt * CostPerHit) * AdrenalineUsage;
				if (lCost < 1)
					lCost = 1;

				if (lCost < Instigator.Controller.Adrenaline)
				{
					if (UDamageAdjust > 1)
					{
						if (RunningTriple)
						{
							DamageDealt = DamageDealt/UDamageAdjust;
						}
						if (C.Pawn.Health > DamageDealt)
						{
							ExtraDamage = min(DamageDealt, C.Pawn.Health - DamageDealt);
							if (Rules == None)
								CheckRPGRules();
							if (Rules != None)
							    Rules.AwardEXPForDamage(Instigator.Controller, RPGStatsInv(Instigator.FindInventoryType(class'RPGStatsInv')), C.Pawn, ExtraDamage);
						}
					}

					if (C == None)
					{
						C = NextC;
						break;
					}

					HitEmitter = spawn(HitEmitterClass,,, Instigator.Location, rotator(C.Pawn.Location - Instigator.Location));
					if (HitEmitter != None)
						HitEmitter.mSpawnVecA = C.Pawn.Location;

					if (C == None)
					{
						C = NextC;
						break;
					}

					if (Instigator != None && Instigator.Controller != None)
					{
						C.Pawn.TakeDamage(DamageDealt, Instigator, C.Pawn.Location, vect(0,0,0), class'DamTypeEnhLightningRod');
						Instigator.Controller.Adrenaline -=lCost;
						if (Instigator.Controller.Adrenaline < 0)
							Instigator.Controller.Adrenaline = 0;

						if (C == None || C.Pawn == None || C.Pawn.Health <= 0)
							if (Instigator != None)
								class'ArtifactLightningBeam'.static.AddArtifactKill(Instigator, class'WeaponRod');
					}
				}
			}
			C = NextC;
		}
	}

	function BeginState()
	{
		SetTimer(0.5, true);
		bActive = true;
	}

	function EndState()
	{
		SetTimer(0, false);
		bActive = false;
	}
}

simulated function Tick(float deltaTime)
{
	if (bActive)
	{
		if (Instigator != None && Instigator.Controller != None)
		{
			Instigator.Controller.Adrenaline -= deltaTime * CostPerSec;
			if (Instigator.Controller.Adrenaline <= 0.0)
			{
				Instigator.Controller.Adrenaline = 0.0;
				UsedUp();
			}
		}
	}
}

defaultproperties
{
     CostPerHit=0.250000
     HealthMultiplier=0.100000
     MaxDamagePerHit=70
     MinDamagePerHit=5
     TargetRadius=2000.000000
     HitEmitterClass=Class'XEffects.LightningBolt'
     CostPerSec=1
     PickupClass=Class'fps.ArtifactLightningRodPickup'
     IconMaterial=Texture'ArtifactIcons.rod'
     ItemName="Lightning Rod"
}
