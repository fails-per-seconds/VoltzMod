class AbilityExtremeEngineer extends AbilityLoadedEngineer
	config(fps)
	abstract;

static function bool OverridePickupQuery(Pawn Other, Pickup item, out byte bAllowPickup, int AbilityLevel)
{
	if (ClassIsChildOf(item.InventoryType, class'EnhancedRPGArtifact'))
	{
		bAllowPickup = 0;
		return true;
	}
	return super.OverridePickupQuery(Other, item,  bAllowPickup, AbilityLevel);
}

defaultproperties
{
     WeaponDamage=0.800000
     AdrenalineDamage=0.500000
     VehicleDamage=1.200000
     SentinelDamage=1.200000
     AbilityName="Extreme Engineer"
}
