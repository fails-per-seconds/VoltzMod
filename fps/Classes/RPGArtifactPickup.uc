class RPGArtifactPickup extends TournamentPickup;

var float LifeTime;
var RPGArtifactManager ArtifactManager;

function PostBeginPlay()
{
	Super.PostBeginPlay();

	foreach DynamicActors(class'RPGArtifactManager', ArtifactManager)
		break;

	if (ArtifactManager != None)
		SetTimer(Lifetime, false);
	else
		Destroy();
}

function bool CanPickupArtifact(Pawn Other)
{
	local Inventory Inv;
	local int Count, NumArtifacts;

	if (ArtifactManager == None)
	{
		PendingTouch = Other.PendingTouch;
		Other.PendingTouch = self;
		return false;
	}

	if (ArtifactManager.MaxHeldArtifacts <= 0)
		return true;

	for (Inv = Other.Inventory; Inv != None; Inv = Inv.Inventory)
	{
		if (RPGArtifact(Inv) != None)
			NumArtifacts++;
		Count++;
		if (Count > 1000)
			break;
	}

	if (NumArtifacts >= ArtifactManager.MaxHeldArtifacts)
		return false;

	return true;
}

function float DetourWeight(Pawn Other, float PathWeight)
{
	if (CanPickupArtifact(Other))
		return MaxDesireability/PathWeight;
	else
		return 0;
}

function float BotDesireability(Pawn Bot)
{
	if (CanPickupArtifact(Bot))
		return MaxDesireability;
	else
		return 0;
}

auto state Pickup
{
	function bool ValidTouch(Actor Other)
	{
		if (!Super.ValidTouch(Other))
			return false;

		return CanPickupArtifact(Pawn(Other));
	}
}

defaultproperties
{
     Lifetime=30.000000
     MaxDesireability=1.500000
}
