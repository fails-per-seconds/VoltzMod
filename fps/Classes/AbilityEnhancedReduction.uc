class AbilityEnhancedReduction extends CostRPGAbility
	config(fps) 
	abstract;

var config float LevMultiplier;

static function HandleDamage(out int Damage, Pawn Injured, Pawn Instigator, out vector Momentum, class<DamageType> DamageType, bool bOwnedByInstigator, int AbilityLevel)
{
	if (bOwnedByInstigator)
		return;
	if (Damage > 0)
		Damage *= (abs((AbilityLevel * default.LevMultiplier)-1));
}

defaultproperties
{
     LevMultiplier=0.040000
     MinPlayerLevel=40
     PlayerLevelStep=1
     AbilityCantBuyColor=(R=164,G=14,B=122,A=200)
     AbilityMaxColor=(R=1,G=1,B=1,A=200)
     AbilityName="Advanced Damage Reduction"
     DescColor(0)=(R=255,G=255,B=255,A=220)
     Description(0)="Increases your cumulative total damage reduction by 4% per level. Does not apply to self damage.|Cost (per level): 5. You must be level 40 to purchase the first level of this ability, level 41 to purchase the second level, and so on."
     StartingCost=5
     MaxLevel=20
}
