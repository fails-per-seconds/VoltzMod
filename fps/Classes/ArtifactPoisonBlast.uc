class ArtifactPoisonBlast extends EnhancedRPGArtifact
	config(fps);

var config int AdrenalineRequired;
var config int BlastDistance;
var config float ChargeTime;
var config float MaxDrain;
var config float MinDrain;
var config float DrainTime;
var config float DamageRadius;

function BotConsider()
{
	if (Instigator.Controller.Adrenaline < AdrenalineRequired)
		return;

	if ( !bActive && Instigator.Controller.Enemy != None
		   && Instigator.Controller.CanSee(Instigator.Controller.Enemy) && NoArtifactsActive() && FRand() < 0.2 )
		Activate();
}

function PostBeginPlay()
{
	super.PostBeginPlay();
	disable('Tick');
}

function Activate()
{
	local Vehicle V;
	local vector FaceDir;
	local vector BlastLocation;
	local vector HitLocation;
	local vector HitNormal;
	local PoisonBlastCharger PBC;

	if (Instigator != None)
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

		FaceDir = Vector(Instigator.Controller.GetViewRotation());
		BlastLocation = Instigator.Location + (FaceDir * BlastDistance);
		if (!FastTrace(Instigator.Location, BlastLocation))
		{
       			Trace(HitLocation, HitNormal, BlastLocation, Instigator.Location, true);
			BlastLocation = HitLocation - (30*Normal(FaceDir));
		}

		PBC = Instigator.spawn(class'PoisonBlastCharger', Instigator.Controller,,BlastLocation);
		if (PBC != None)
		{
			PBC.MaxDrain = MaxDrain;
			PBC.MinDrain = MinDrain;
			PBC.DamageRadius = DamageRadius;
			PBC.ChargeTime = ChargeTime*AdrenalineUsage;
			PBC.DrainTime = DrainTime;

			Instigator.Controller.Adrenaline -= AdrenalineRequired*AdrenalineUsage;
			if (Instigator.Controller.Adrenaline < 0)
				Instigator.Controller.Adrenaline = 0;
		}
	}
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
	else
		return switch @ "Adrenaline is required to use this artifact";
}

defaultproperties
{
     AdrenalineRequired=100
     BlastDistance=1500
     ChargeTime=2.000000
     MaxDrain=30.000000
     MinDrain=15.000000
     DrainTime=5.000000
     DamageRadius=2200.000000
     CostPerSec=1
     MinActivationTime=0.000001
     PickupClass=Class'fps.ArtifactPoisonBlastPickup'
     IconMaterial=Texture'XEffects.Skins.MuzFlashLink_t'
     ItemName="PoisonBlast"
}
