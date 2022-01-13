class DamageInv extends Inventory;

var RPGRules Rules;
var float KillXPPerc, EffectRadius;
var int EstimatedRunTime;
var vector CoreLocation;
var Controller DamagePlayerController;
var Material EffectOverlay;

replication
{
	reliable if (bNetInitial && Role == ROLE_Authority)
		DamagePlayerController, CoreLocation, EstimatedRunTime;
}

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();

	SetTimer(1, true);
}

function GiveTo(Pawn Other, optional Pickup Pickup)
{
	super.GiveTo(Other, Pickup);
	SwitchOnDamage();
}

function SwitchOnDamage()
{
	if ((Owner == None) || (DamagePlayerController == None) || (Pawn(Owner) == None) || (Pawn(Owner).Controller == None) || Pawn(Owner).HasUDamage())
	{
		Destroy();
		return;
	}

	Pawn(Owner).EnableUDamage(EstimatedRunTime);
	if (PlayerController(Pawn(Owner).Controller) != None)
	{
		PlayerController(Pawn(Owner).Controller).ReceiveLocalizedMessage(class'DamageConditionMessage', 0);
	}
	Pawn(Owner).SetOverlayMaterial(EffectOverlay, EstimatedRunTime, true);
}

function SwitchOffDamage()
{
	if (Pawn(Owner) != None)
	{
		Pawn(Owner).DisableUDamage();
		if (Pawn(Owner).Controller != None && PlayerController(Pawn(Owner).Controller) != None)
		{
			PlayerController(Pawn(Owner).Controller).ReceiveLocalizedMessage(class'DamageConditionMessage', 1);
		}
		Pawn(Owner).SetOverlayMaterial(EffectOverlay, -1, true);
	}
}

simulated function Timer()
{
	local ArtifactSphereDamage InitiatingSphere;

	if (Role == ROLE_Authority)
	{
		if ((Owner == None) || (Pawn(Owner) == None))
		{
			if (Owner == None)
				Warn("*** Damage Sphere effect still active and unable to terminate. Owner None");
			else 
				Warn("*** Damage Sphere effect still active and unable to terminate. Pawn(Owner) None");
			Destroy();
			return;
		}

		if (Pawn(Owner).Controller == None)
		{
			SwitchOffDamage();
			Destroy();
			return;
		}

		if (!Pawn(Owner).HasUDamage())
		{
			Destroy();
			return;
		}

		if ((DamagePlayerController == None) || (DamagePlayerController.Pawn == None) || (DamagePlayerController.Pawn.Health <= 0) || !DamagePlayerController.Pawn.HasUDamage())
		{
			SwitchOffDamage();
			Destroy();
			return;
		}

		InitiatingSphere = ArtifactSphereDamage(DamagePlayerController.Pawn.FindInventoryType(class'ArtifactSphereDamage'));

		if ((VSize(Pawn(Owner).Location - CoreLocation) > EffectRadius) || (InitiatingSphere == None) || (!InitiatingSphere.bActive))
		{
			SwitchOffDamage();
			Destroy();
			return;
		}

		EstimatedRunTime--;
		if (EstimatedRunTime <= 0)
		{
			SwitchOffDamage();
			Destroy();
			return;
		}
	}
}

simulated function Destroyed()
{	
	if ((Owner != None) && (Pawn(Owner) != None) && (Pawn(Owner).Controller != None) && Pawn(Owner).HasUDamage())
		 SwitchOffDamage();
	super.Destroyed();
}

defaultproperties
{
     KillXPPerc=0.100000
     EffectOverlay=Shader'XGameShaders.PlayerShaders.WeaponUDamageShader'
     bOnlyRelevantToOwner=False
}
