class GlobeInv extends Inventory;

var RPGRules Rules;
var float ExpPerDamage, EffectRadius;
var int EstimatedRunTime, PlayerHealth;
var vector CoreLocation;
var Controller InvPlayerController;
var Material EffectOverlay;
var Pawn PlayerPawn;

replication
{
	reliable if (bNetInitial && Role == ROLE_Authority)
		InvPlayerController, CoreLocation, EstimatedRunTime;
}

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();

	SetTimer(1, true);
}

function GiveTo(Pawn Other, optional Pickup Pickup)
{
	super.GiveTo(Other, Pickup);
	SwitchOnGlobe();
}

function SwitchOnGlobe()
{
	if ((Owner == None) || (InvPlayerController == None) || (Pawn(Owner) == None) || (Pawn(Owner).Controller == None))
	{
		Destroy();
		return;
	}

	if (PlayerController(Pawn(Owner).Controller) != None)
	{
		PlayerController(Pawn(Owner).Controller).ReceiveLocalizedMessage(class'GlobeConditionMessage', 0, InvPlayerController.Pawn.PlayerReplicationInfo);
	}
	Pawn(Owner).SetOverlayMaterial(EffectOverlay, EstimatedRunTime, true);
	PlayerHealth = Pawn(Owner).Health;
	PlayerPawn = Pawn(Owner);
}

function SwitchOffGlobe()
{
	if (Pawn(Owner) != None && Pawn(Owner).Controller != None)
	{
		if (PlayerController(Pawn(Owner).Controller) != None)
		{
			PlayerController(Pawn(Owner).Controller).ReceiveLocalizedMessage(class'GlobeConditionMessage', 1);
		}
		Pawn(Owner).SetOverlayMaterial(EffectOverlay, -1, true);
	}
}

simulated function Timer()
{
	local Controller C;
	local ArtifactSphereGlobe InitiatingSphere;

	if (Role == ROLE_Authority)
	{

		if ((Owner == None) || (Pawn(Owner) == None))
		{
			if (Owner == None)
				Warn("*** Globe Sphere effect still active and unable to terminate. Owner None");
			else 
				Warn("*** Globe Sphere effect still active and unable to terminate. Pawn(Owner) None");
			Destroy();
			return;
		}
		if ((Pawn(Owner).Controller == None))
		{
			C = Level.ControllerList;
			while (C != None)
			{
				if (C.Pawn != None && Vehicle(C.Pawn) != None && Vehicle(C.Pawn).Driver == Owner)
				{
					if (PlayerController(C) != None)
						PlayerController(C).ReceiveLocalizedMessage(class'GlobeConditionMessage', 1);
					C.Pawn.SetOverlayMaterial(EffectOverlay, -1, true);
					Pawn(Owner).SetOverlayMaterial(EffectOverlay, -1, true);
					Destroy();
					return;
				}
				else if (C.Pawn != None && RedeemerWarhead(C.Pawn) != None && RedeemerWarhead(C.Pawn).OldPawn == Owner)
				{
					if (PlayerController(C) != None)
						PlayerController(C).ReceiveLocalizedMessage(class'GlobeConditionMessage', 1);
					C.Pawn.SetOverlayMaterial(EffectOverlay, -1, true);
					Pawn(Owner).SetOverlayMaterial(EffectOverlay, -1, true);
					Destroy();
					return;
				}
				C = C.NextController;
			}
			
			Warn("*** Globe Sphere effect still active and unable to terminate. controller None");
			Destroy();
			return;
		}

		if (EffectRadius > 0.5)
		{
			if ((InvPlayerController == None) || (InvPlayerController.Pawn == None) || (InvPlayerController.Pawn.Health <= 0))
			{
				SwitchOffGlobe();
				Destroy();
				return;
			}

			InitiatingSphere = ArtifactSphereGlobe(InvPlayerController.Pawn.FindInventoryType(class'ArtifactSphereGlobe'));

			if ((VSize(Pawn(Owner).Location - CoreLocation) > EffectRadius) || (InitiatingSphere == None) || (!InitiatingSphere.bActive))
			{
				SwitchOffGlobe();
				Destroy();
				return;
			}
		}

		EstimatedRunTime--;
		if (EstimatedRunTime <= 0)
		{
			SwitchOffGlobe();
			Destroy();
			return;
		}
	}
}

simulated function Destroyed()
{	
	if ((Owner != None) && (Pawn(Owner) != None) && (Pawn(Owner).Controller != None))
		 SwitchOffGlobe();
	super.Destroyed();
}

defaultproperties
{
     EstimatedRunTime=5
     EffectOverlay=Shader'GlobeOverlay'
     bOnlyRelevantToOwner=False
}
