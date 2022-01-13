class AbilitySpeed extends RPGAbility
	abstract;

static simulated function int Cost(RPGPlayerDataObject Data, int CurrentLevel)
{
	if (Data.Level < 10 * (CurrentLevel + 1))
		return 0;
	else
		return Super.Cost(Data, CurrentLevel);
}

static simulated function ModifyPawn(Pawn Other, int AbilityLevel)
{
	Other.GroundSpeed = Other.default.GroundSpeed * (1.0 + 0.05 * float(AbilityLevel));
	Other.WaterSpeed = Other.default.WaterSpeed * (1.0 + 0.05 * float(AbilityLevel));
	Other.AirSpeed = Other.default.AirSpeed * (1.0 + 0.05 * float(AbilityLevel));
}

defaultproperties
{
     AbilityName="Quickfoot"
     Description="Increases your speed in all environments by 5% per level. The Speed adrenaline combo will stack with this effect. You must be a Level equal to ten times the ability level you wish to have before you can purchase it. (Max Level: 4)"
     StartingCost=10
     CostAddPerLevel=5
     MaxLevel=5
}
