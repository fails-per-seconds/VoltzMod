class AbilityDefenseSentinelHealing extends EngineerAbility
	config(fps)
	abstract;

static simulated function ModifyConstruction(Pawn Other, int AbilityLevel)
{
	if (xDefenseSentinel(Other) != None)
		xDefenseSentinel(Other).HealthHealingLevel = AbilityLevel;
}

defaultproperties
{
     AbilityName="DefSent Health Bonus"
     Description="Allows defense sentinels to heal nearby players when they are not busy. Each level adds 1 to each healing shot.|Cost (per level): 10,10,10,10,10,..."
     StartingCost=10
     MaxLevel=10
}
