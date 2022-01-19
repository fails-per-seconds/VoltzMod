class AbilityAmmoRegen extends CostRPGAbility 
	abstract;

static simulated function ModifyPawn(Pawn Other, int AbilityLevel)
{
	local RegenAmmoInv R;
	local Inventory Inv;

	if (Other.Role != ROLE_Authority)
		return;

	Inv = Other.FindInventoryType(class'RegenAmmoInv');
	if (Inv != None)
		Inv.Destroy();

	if (R == None)
	{
		R = Other.spawn(class'RegenAmmoInv', Other,,,rot(0,0,0));
		R.GiveTo(Other);
	}

	if (R != None)
	{
		R.SetTimer(3, true);
		R.RegenAmount = AbilityLevel;
	}
}

defaultproperties
{
     MinAmmo=50
     AbilityCantBuyColor=(R=164,G=14,B=122,A=200)
     AbilityMaxColor=(R=1,G=1,B=1,A=200)
     AbilityName="Resupply"
     DescColor(0)=(R=255,G=255,B=255,A=220)
     Description=(0)"Adds 1 ammo per level to each ammo type you own every 3 seconds. Does not give ammo to superweapons or the translocator. You must have a Max Ammo stat of at least 50 to purchase this ability."
     StartingCost=15
     CostAddPerLevel=5
     MaxLevel=6
}
