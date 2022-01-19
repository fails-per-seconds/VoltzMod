class AbilityShieldStrength extends RPGAbility
	abstract;

static simulated function int Cost(RPGPlayerDataObject Data, int CurrentLevel)
{
	if (Data.HealthBonus < 100)
		return 0;
	else
		return Super.Cost(Data, CurrentLevel);
}

static simulated function ModifyPawn(Pawn Other, int AbilityLevel)
{
	if (xPawn(Other) != None)
		xPawn(Other).ShieldStrengthMax = xPawn(Other).default.ShieldStrengthMax + 25 * AbilityLevel;
}

defaultproperties
{
     AbilityCantBuyColor=(R=164,G=14,B=122,A=200)
     AbilityMaxColor=(R=1,G=1,B=1,A=200)
     AbilityName="Shields Up"
     DescColor(0)=(R=255,G=255,B=255,A=220)
     Description(0)="Increases your maximum shield by 25 per level. You must have a Health Bonus stat of 100 before you can purchase this ability. (Max Level: 4)"
     StartingCost=20
     CostAddPerLevel=5
     MaxLevel=4
}
