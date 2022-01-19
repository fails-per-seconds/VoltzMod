class AbilityDefenseSentinelArmor extends EngineerAbility
	config(fps)
	abstract;

static simulated function ModifyConstruction(Pawn Other, int AbilityLevel)
{
	if (xDefenseSentinel(Other) != None)
		xDefenseSentinel(Other).ArmorHealingLevel = AbilityLevel;
}

defaultproperties
{
     AbilityCantBuyColor=(R=164,G=14,B=122,A=200)
     AbilityMaxColor=(R=1,G=1,B=1,A=200)
     AbilityName="DefSent Armor healing"
     DescColor(0)=(R=255,G=255,B=255,A=220)
     Description(0)="Allows defense sentinels to heal armor when they are not busy. Each level adds 1 to each healing shot.|Cost (per level): 10,10,10,10,10,..."
     StartingCost=10
     MaxLevel=10
}
