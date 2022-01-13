class ArtifactMegaBlast extends EnhancedRPGArtifact
		config(fps);

var config int AdrenalineRequired;
var config int BlastDistance;
var config float ChargeTime;
var config float Damage;
var config float DamageRadius;

function BotConsider()
{
	if (Instigator.Controller.Adrenaline < AdrenalineRequired)
		return;

	if ( !bActive && Instigator.Controller.Enemy != None
		   && Instigator.Controller.CanSee(Instigator.Controller.Enemy) && NoArtifactsActive() && FRand() < 0.2 )	// make it rare
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
	local Vector FaceDir;
	local Vector BlastLocation;
	local vector HitLocation;
	local vector HitNormal;
	Local MegaCharger MC;

	if (Instigator != None)
	{
		if (Instigator.Controller.Adrenaline < (AdrenalineRequired*AdrenalineUsage))
		{
			Instigator.ReceiveLocalizedMessage(MessageClass, AdrenalineRequired*AdrenalineUsage, None, None, Class);
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

		MC = Instigator.spawn(class'MegaCharger', Instigator.Controller,,BlastLocation);
		if (MC != None)
		{
			MC.Damage = Damage;
			MC.DamageRadius = DamageRadius;
			MC.ChargeTime = ChargeTime*AdrenalineUsage;

			Instigator.Controller.Adrenaline -= (AdrenalineRequired*AdrenalineUsage);
			if (Instigator.Controller.Adrenaline < 0)
				Instigator.Controller.Adrenaline = 0;

			SetRecoveryTime(TimeBetweenUses*AdrenalineUsage);
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
	else if (Switch == 5000)
		return "Cannot use this artifact again yet";
	else
		return switch @ "Adrenaline is required to use this artifact";
}

defaultproperties
{
     AdrenalineRequired=200
     BlastDistance=2000
     ChargeTime=2.000000
     Damage=1300.000000
     DamageRadius=1600.000000
     TimeBetweenUses=30.000000
     CostPerSec=1
     MinActivationTime=0.000001
     PickupClass=Class'fps.ArtifactMegaBlastPickup'
     IconMaterial=Texture'XEffects.Skins.MuzFlashA_t'
     ItemName="MegaBlast"
}
