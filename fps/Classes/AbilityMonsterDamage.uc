class AbilityMonsterDamage extends CostRPGAbility
	config(fps) 
	abstract;

var config float LevMultiplier;

static function HandleDamage(out int Damage, Pawn Injured, Pawn Instigator, out vector Momentum, class<DamageType> DamageType, bool bOwnedByInstigator, int AbilityLevel)
{
	if (!bOwnedByInstigator || Instigator == None || Monster(Instigator) == None)
		return;
	if (Damage > 0)
		Damage *= (1 + (AbilityLevel * default.LevMultiplier));
}

defaultproperties
{
     LevMultiplier=0.020000
     AbilityCantBuyColor=(R=164,G=14,B=122,A=200)
     AbilityMaxColor=(R=1,G=1,B=1,A=200)
     AbilityName="Monster Damage Bonus"
     DescColor(0)=(R=255,G=255,B=255,A=220)
     Description(0)="Increases the damage done by Pets by 2% per level. |Cost (per level): 5."
     StartingCost=5
     MaxLevel=20
}
