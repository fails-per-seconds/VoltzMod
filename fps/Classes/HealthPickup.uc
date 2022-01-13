class HealthPickup extends HealthPack
	notplaceable;

function InitDroppedPickupFor(Inventory Inv)
{
	SetPhysics(PHYS_Falling);
	GotoState('Pickup','Begin');
	Inventory = Inv;
	bAlwaysRelevant = false;
	bOnlyReplicateHidden = false;
	bUpdateSimulatedPosition = true;
	bDropped = true;
	LifeSpan = 16;
	bIgnoreEncroachers = false;
	NetUpdateFrequency = 8;
}

defaultproperties
{
}
