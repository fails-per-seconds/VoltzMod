class AbilityBerserkerDamage extends CostRPGAbility
	config(fps) 
	abstract;

var config float MinDamageBonus, MaxDamageBonus, MaxDamageDist;

static function HandleDamage(out int Damage, Pawn Injured, Pawn Instigator, out vector Momentum, class<DamageType> DamageType, bool bOwnedByInstigator, int AbilityLevel)
{
	local float damageScale, dist, distScale;
	local vector dir;

	if (DamageType == class'DamTypeRetaliation' || Injured == None || Instigator == None || Injured == Instigator || Damage <= 0)
		return;

	dir = Instigator.Location - Injured.Location;
	dist = FMax(1,VSize(dir));

	if (dist > default.MaxDamageDist)
		distScale = 0.0;
	else
		distScale = FMin(1.0,FMax(0.0, 1.0 - (dist/default.MaxDamageDist)));

	if (bOwnedByInstigator) 
	{
		damageScale = default.MinDamageBonus + (distscale * (default.MaxDamageBonus - default.MinDamageBonus));
		Damage *= (1 + (AbilityLevel * damageScale));
	}
	else
	{
		damageScale = default.MaxDamageBonus - (distscale * (default.MaxDamageBonus - default.MinDamageBonus));
		Damage *= (1 + (AbilityLevel * damageScale));
	}
}

static function bool OverridePickupQuery(Pawn Other, Pickup item, out byte bAllowPickup, int AbilityLevel)
{
	if (ClassIsChildOf(item.InventoryType, class'EnhancedRPGArtifact'))
	{
		bAllowPickup = 0;
		return true;
	}
	return false;
}

defaultproperties
{
     MaxDamageBonus=0.150000
     MaxDamageDist=1800.000000
     MinPlayerLevel=60
     PlayerLevelStep=2
     AbilityName="Berserker Damage Bonus"
     Description="Increases your cumulative total damage bonus by up to 15% per level, depending on closeness to enemy. However, you also take up to 15% extra damage per level, again depending on how close. The closer the better. |Cost (per level): 10. You must be level 60 to purchase the first level of this ability, level 62 to purchase the second level, and so on."
     StartingCost=10
     MaxLevel=20
}
