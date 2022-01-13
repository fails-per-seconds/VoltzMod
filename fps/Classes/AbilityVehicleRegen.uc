class AbilityVehicleRegen extends CostRPGAbility
	abstract;

static simulated function ModifyPawn(Pawn Other, int AbilityLevel)
{
	local RegenInv R;
	local Inventory Inv;

	if (Other.Role != ROLE_Authority)
		return;

	Inv = Other.FindInventoryType(class'RegenInv');
	if (Inv != None)
		Inv.Destroy();

	R = Other.spawn(class'RegenInv', Other,,,rot(0,0,0));
	R.bVehicleRegen = true;
	R.SetTimer(1, true);
	R.RegenAmount = AbilityLevel*2;
	R.GiveTo(Other);
}

defaultproperties
{
     MinHealthBonus=25
     HealthBonusStep=25
     AbilityName="Armor Regeneration"
     Description="Heals 2 armor per second per level. Does not heal past starting armor amount. You must have a Health Bonus stat equal to 25 times the ability level you wish to have before you can purchase it. |Cost (per level): 15,20,25,30,..."
     StartingCost=15
     CostAddPerLevel=5
     MaxLevel=10
}
