class AbilityMonsterSkill extends MonsterAbility
	abstract;

static simulated function ModifyMonster(Monster Other, int AbilityLevel)
{
	local FriendlyMonsterInv FriendlyInv;

	FriendlyInv = FriendlyMonsterInv(Other.FindInventoryType(class'FriendlyMonsterInv'));
	if (FriendlyInv != None)
		FriendlyInv.Skill = AbilityLevel;

	FriendlyMonsterController(Other.Controller).InitializeSkill(AbilityLevel);
}

defaultproperties
{
     AbilityCantBuyColor=(R=164,G=14,B=122,A=200)
     AbilityMaxColor=(R=1,G=1,B=1,A=200)
     AbilityName="Summons: Intelligence"
     DescColor(0)=(R=255,G=255,B=255,A=220)
     Description(0)="Increases your summoned monsters' intelligence. At each level, your pet monsters become more intelligent. (Max Level: 7)|Cost (per level): 2,3,4,5,6,7,8"
     StartingCost=2
     CostAddPerLevel=1
     MaxLevel=7
}
