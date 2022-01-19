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
     AbilityCantBuyColor=(R=164,G=14,B=122,A=200)
     AbilityMaxColor=(R=1,G=1,B=1,A=200)
     AbilityName="Airmaster"
     DescColor(0)=(R=255,G=255,B=255,A=220)
     DescColor(1)=(R=255,G=5,B=5,A=220)
     DescColor(2)=(R=5,G=2555,B=5,A=220)
     DescColor(3)=(R=5,G=5,B=255,A=220)
     Description(0)="Increases your air control by 50% per level. You must be a Level equal to ten times the ability level you wish to have before you can purchase it|"
     Description(1)="line 1...red|"
     Description(2)="line 2...green|"
     Description(3)="line 3...blue|"
     StartingCost=10
     CostAddPerLevel=5
     BotChance=4
     MaxLevel=4
}
