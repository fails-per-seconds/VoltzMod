class AbilityCautiousness extends RPGAbility
	abstract;

static simulated function int Cost(RPGPlayerDataObject Data, int CurrentLevel)
{
	if (Data.HealthBonus < 50)
		return 0;
	else
		return Super.Cost(Data, CurrentLevel);
}

static function HandleDamage(out int Damage, Pawn Injured, Pawn Instigator, out vector Momentum, class<DamageType> DamageType, bool bOwnedByInstigator, int AbilityLevel)
{
	if (Injured != Instigator || !bOwnedByInstigator || DamageType == class'Fell')
		return;

	Damage -= float(Damage) * 0.15 * AbilityLevel;
}

defaultproperties
{
     AbilityCantBuyColor=(R=164,G=14,B=122,A=200)
     AbilityMaxColor=(R=1,G=1,B=1,A=200)
     AbilityName="Cautiousness"
     DescColor(0)=(R=255,G=255,B=255,A=220)
     Description(0)="Reduces self damage by 15% per level. Your Health Bonus stat must be at least 50 and your Damage Reduction stat at least 25 to purchase this ability. (Max Level: 5)"
     StartingCost=15
     CostAddPerLevel=5
     MaxLevel=5
}
