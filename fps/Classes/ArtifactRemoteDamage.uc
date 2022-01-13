class ArtifactRemoteDamage extends RPGArtifact
		config(fps);

var class<xEmitter> HitEmitterClass;
var config float MaxRange;
var config int AdrenalineRequired;
var config int DamageRunTime;
var config int XPforUse;

var RPGRules Rules;

function BotConsider()
{
	return;
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
	local Vehicle V;
	local vector FaceDir;
	local vector BeamEndLocation;
	local vector StartTrace;
	local vector HitLocation;
	local vector HitNormal;
	local Pawn HitPawn;
	local Actor AHit;
	local Actor A;
	local xEmitter HitEmitter;

	if ((Instigator != None) && (Instigator.Controller != None))
	{
		if (Instigator.Controller.Adrenaline < AdrenalineRequired)
		{
			Instigator.ReceiveLocalizedMessage(MessageClass, AdrenalineRequired, None, None, Class);
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
			bActive = false;
			GotoState('');
			return;
		}

		HitPawn = Pawn(AHit);
		if (HitPawn != Instigator && HitPawn.Health > 0 && HitPawn.Controller.SameTeamAs(Instigator.Controller)
		     && VSize(HitPawn.Location - StartTrace) < MaxRange && Vehicle(HitPawn) == None)
		{
			if (HitPawn.HasUDamage())
			{
				Instigator.ReceiveLocalizedMessage(MessageClass, 4000, None, None, Class);
				bActive = false;
				GotoState('');
				return;
			}	

			HitPawn.EnableUDamage(DamageRunTime);

			Instigator.Controller.Adrenaline -= AdrenalineRequired;
			if (Instigator.Controller.Adrenaline < 0)
				Instigator.Controller.Adrenaline = 0;

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

			if (HitPawn != None && PlayerController(HitPawn.Controller) != None)	
				PlayerController(HitPawn.Controller).ReceiveLocalizedMessage(class'DamageConditionMessage', 0, Instigator.PlayerReplicationInfo);

			if ((XPforUse > 0) && (Rules != None))
			{
				Rules.ShareExperience(RPGStatsInv(Instigator.FindInventoryType(class'RPGStatsInv')), XPforUse);
			}

		}
	}
	bActive = false;
	GotoState('');
	return;			
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
	else if (Switch == 4000)
		return "That person cannot accept the powerup";
	else
		return "At least" @ switch @ "adrenaline is required to use this artifact";
}

defaultproperties
{
     HitEmitterClass=Class'fps.LightningBeamEmitter'
     MaxRange=3000.000000
     AdrenalineRequired=100
     DamageRunTime=20
     XPforUse=10
     CostPerSec=1
     MinActivationTime=0.000001
     IconMaterial=Texture'ArtifactIcons.TeamTriple'
     ItemName="Remote Damage"
}
