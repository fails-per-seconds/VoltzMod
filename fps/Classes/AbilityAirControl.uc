class AbilityAirControl extends RPGAbility
	abstract;

static simulated function int Cost(RPGPlayerDataObject Data, int CurrentLevel)
{
	if (Data.Level < 10 * (CurrentLevel + 1))
		return 0;
	else
		return Super.Cost(Data, CurrentLevel);
}

static function int BotBuyChance(Bot B, RPGPlayerDataObject Data, int CurrentLevel)
{
	if (static.Cost(Data, CurrentLevel) > 0)
	{
		if (CurrentLevel < 1)
			return default.BotChance;
		else
			return default.BotChance - 1;
	}
	else
		return 0;
}

static simulated function ModifyPawn(Pawn Other, int AbilityLevel)
{
	if (Other.Role != ROLE_Authority)
		return;

	Other.AirControl = class'DMMutator'.default.AirControl * (1.0 + 0.50 * float(AbilityLevel));
}

defaultproperties
{
     AbilityName="Airmaster"
     Description="Increases your air control by 50% per level. You must be a Level equal to ten times the ability level you wish to have before you can purchase it. (Max Level: 4)"
     StartingCost=10
     CostAddPerLevel=5
     BotChance=4
     MaxLevel=4
}
