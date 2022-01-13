class AbilityIronLegs extends RPGAbility
	abstract;

static simulated function int Cost(RPGPlayerDataObject Data, int CurrentLevel)
{
	if (Data.HealthBonus < 50)
		return 0;
	else
		return Super.Cost(Data, CurrentLevel);
}

static simulated function ModifyPawn(Pawn Other, int AbilityLevel)
{
	Other.MaxFallSpeed = Other.default.MaxFallSpeed * (1.0 + 0.25 * float(AbilityLevel));
}

defaultproperties
{
     AbilityName="Iron Legs"
     Description="Increases the distance you can safely fall by 25% per level and reduces fall damage for distances still beyond your capacity to handle. Your Health Bonus stat must be at least 50 to purchase this ability. (Max Level: 4)"
     StartingCost=10
     CostAddPerLevel=5
     BotChance=6
     MaxLevel=4
}
