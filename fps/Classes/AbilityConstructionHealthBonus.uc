class AbilityConstructionHealthBonus extends EngineerAbility
	config(fps)
	abstract;

var config float HealthBonus;

static simulated function ModifyConstruction(Pawn Other, int AbilityLevel)
{
	Other.HealthMax += Other.HealthMax * (default.HealthBonus * AbilityLevel);
	Other.Health += Other.Health * (default.HealthBonus * AbilityLevel);
	Other.SuperHealthMax += Other.SuperHealthMax * (default.HealthBonus * AbilityLevel);
}

defaultproperties
{
     HealthBonus=0.200000
     AbilityCantBuyColor=(R=164,G=14,B=122,A=200)
     AbilityMaxColor=(R=1,G=1,B=1,A=200)
     AbilityName="Constructions: Health Bonus"
     DescColor(0)=(R=255,G=255,B=255,A=220)
     Description(0)="Gives an additional health bonus to your summoned constructions. Each level adds 20% health to your construction's max health.|Cost (per level): 2,4,6,8,10,12,14,16,18,20"
     StartingCost=2
     CostAddPerLevel=2
     MaxLevel=20
}
