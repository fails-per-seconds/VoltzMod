class ArtifactFreezeBomb extends EnhancedRPGArtifact
	config(fps);

var config int AdrenalineRequired;
var config int BlastDistance;
var config float ChargeTime;
var config float MaxFreezeTime;
var config float FreezeRadius;

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
	local FreezeBombCharger FBC;

	if (Instigator != None)
	{
		if (Instigator.Controller.Adrenaline < AdrenalineRequired*AdrenalineUsage)
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

		FBC = Instigator.spawn(class'FreezeBombCharger', Instigator.Controller,,BlastLocation);
		if (FBC != None)
		{
			FBC.MaxFreezeTime = MaxFreezeTime;
			FBC.FreezeRadius = FreezeRadius;
			FBC.ChargeTime = ChargeTime*AdrenalineUsage;

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
     AdrenalineRequired=75
     BlastDistance=1500
     ChargeTime=2.000000
     MaxFreezeTime=15.000000
     FreezeRadius=2000.000000
     CostPerSec=1
     MinActivationTime=0.000001
     PickupClass=Class'fps.ArtifactFreezeBombPickup'
     IconMaterial=Texture'Engine.DefaultTexture'
     ItemName="FreezeBomb"
}
