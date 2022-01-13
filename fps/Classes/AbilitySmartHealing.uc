class AbilitySmartHealing extends RPGAbility
	abstract;

static simulated function int Cost(RPGPlayerDataObject Data, int CurrentLevel)
{
	if (Data.HealthBonus < 50 || Data.AmmoMax < 25)
		return 0;
	else
		return Super.Cost(Data, CurrentLevel);
}

static function bool OverridePickupQuery(Pawn Other, Pickup item, out byte bAllowPickup, int AbilityLevel)
{
	local int HealMax;

	if (TournamentHealth(item) != None)
	{
		HealMax = TournamentHealth(item).GetHealMax(Other);
		if (Other.Health + TournamentHealth(item).HealingAmount < HealMax)
		{
			Other.GiveHealth(int(float(TournamentHealth(item).HealingAmount) * 0.25 * AbilityLevel), HealMax);
			bAllowPickup = 1;
			return true;
		}
	}

	return false;
}

defaultproperties
{
     AbilityName="Smart Healing"
     Description="Causes healing items to heal you an addition 25% per level. You need to have a Health Bonus stat of at least 50 and a Max Ammo stat of at least 25 to purchase this ability. (Max Level: 4)"
     StartingCost=15
     CostAddPerLevel=5
     MaxLevel=4
}
