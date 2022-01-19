class AbilityMonsterHealthBonus extends MonsterAbility
	config(fps)
	abstract;

var config float HealthBonus;

static simulated function ModifyMonster(Monster Other, int AbilityLevel)
{
	Other.HealthMax += Other.HealthMax * (Default.HealthBonus * AbilityLevel);
	Other.Health += Other.Health * (Default.HealthBonus * AbilityLevel);
}

defaultproperties
{
     HealthBonus=0.100000
     AbilityCantBuyColor=(R=164,G=14,B=122,A=200)
     AbilityMaxColor=(R=1,G=1,B=1,A=200)
     AbilityName="Summons: Health Bonus"
     DescColor(0)=(R=255,G=255,B=255,A=220)
     Description(0)="Gives an additional health bonus to your summoned monsters. Each level adds 10% health to your monster's max health. |Cost (per level): 2,6,10,14,18,22,26,30,34,38"
     StartingCost=2
     CostAddPerLevel=4
     MaxLevel=20
}
