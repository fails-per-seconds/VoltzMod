class AbilityEnhancedDamage extends CostRPGAbility
	config(fps) 
	abstract;

var config float LevMultiplier;

static function HandleDamage(out int Damage, Pawn Injured, Pawn Instigator, out vector Momentum, class<DamageType> DamageType, bool bOwnedByInstigator, int AbilityLevel)
{
	if (!bOwnedByInstigator)
		return;
	if (Damage > 0)
		Damage *= (1 + (AbilityLevel * default.LevMultiplier));
}

defaultproperties
{
     LevMultiplier=0.030000
     MinPlayerLevel=75
     PlayerLevelStep=1
     AbilityCantBuyColor=(R=164,G=14,B=122,A=200)
     AbilityMaxColor=(R=1,G=1,B=1,A=200)
     AbilityName="Advanced Damage Bonus"
     DescColor(0)=(R=255,G=255,B=255,A=220)
     Description(0)="Increases your cumulative total damage bonus by 3% per level. |Cost (per level): 5. You must be level 75 to purchase the first level of this ability, level 76 to purchase the second level, and so on."
     StartingCost=5
     MaxLevel=20
}
