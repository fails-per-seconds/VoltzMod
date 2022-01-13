class AbilityDefenseSentinelResupply extends EngineerAbility
	config(fps)
	abstract;

static simulated function ModifyConstruction(Pawn Other, int AbilityLevel)
{
	if (xDefenseSentinel(Other) != None)
		xDefenseSentinel(Other).ResupplyLevel = AbilityLevel;
}

defaultproperties
{
     AbilityName="DefSent Resupply"
     Description="Allows defense sentinels to grant ammo resupply when they are not busy. Each level adds 1 to each healing shot.|Cost (per level): 10,10,10,10,10,..."
     StartingCost=10
     MaxLevel=10
}
