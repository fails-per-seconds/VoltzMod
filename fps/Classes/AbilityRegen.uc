class AbilityRegen extends CostRPGAbility
	abstract;

static simulated function ModifyPawn(Pawn Other, int AbilityLevel)
{
	local RegenHealthInv R;
	local Inventory Inv;

	if (Other.Role != ROLE_Authority)
		return;

	Inv = Other.FindInventoryType(class'RegenHealthInv');
	if (Inv != None)
		Inv.Destroy();

	if (R == None)
	{
		R = Other.spawn(class'RegenHealthInv', Other,,,rot(0,0,0));
		R.GiveTo(Other);
	}

	if (R != None)
	{
		R.SetTimer(1, true);
		R.RegenAmount = AbilityLevel;
	}
}

defaultproperties
{
     MinHealthBonus=30
     HealthBonusStep=30
     AbilityName="Regeneration"
     Description="Heals 1 health per second per level. Does not heal past starting health amount. You must have a Health Bonus stat equal to 30 times the ability level you wish to have before you can purchase it. |Cost (per level): 15,20,25,30,..."
     StartingCost=15
     CostAddPerLevel=5
     BotChance=10
     MaxLevel=10
}
