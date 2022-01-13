class AbilityIncreasedDamage extends CostRPGAbility
	config(fps) 
	abstract;

var config float DamageMultiplier;
var config float SpeedMultiplier;

static function HandleDamage(out int Damage, Pawn Injured, Pawn Instigator, out vector Momentum, class<DamageType> DamageType, bool bOwnedByInstigator, int AbilityLevel)
{
	if (!bOwnedByInstigator)
		return;
	if (Damage > 0 && ClassIsChildOf(DamageType, class'WeaponDamageType'))
		Damage *= (1 + (AbilityLevel * default.DamageMultiplier));
}

static simulated function ModifyWeapon(Weapon Weapon, int AbilityLevel)
{
	local float Modifier;
	local WeaponFire FireMode[2];
	local RPGStatsInv StatsInv;
	local int WeaponSpeed;

	if (Weapon == None)
		return;

	WeaponSpeed = 0;
	if (Pawn(Weapon.Owner) != None)
	{
		StatsInv = RPGStatsInv(Pawn(Weapon.Owner).FindInventoryType(class'RPGStatsInv'));
		if (StatsInv != None)
			WeaponSpeed =  StatsInv.Data.WeaponSpeed;
	}

	Modifier = 1.f + 0.01 * WeaponSpeed;
	Modifier *= 1.f - (default.SpeedMultiplier * AbilityLevel);
	if (Modifier < 0.1)
		Modifier = 0.1;

	FireMode[0] = Weapon.GetFireMode(0);
	FireMode[1] = Weapon.GetFireMode(1);
	if (MinigunFire(FireMode[0]) != None)
	{
		MinigunFire(FireMode[0]).BarrelRotationsPerSec = MinigunFire(FireMode[0]).default.BarrelRotationsPerSec * Modifier;
		MinigunFire(FireMode[0]).FireRate = 1.f / (MinigunFire(FireMode[0]).RoundsPerRotation * MinigunFire(FireMode[0]).BarrelRotationsPerSec);
		MinigunFire(FireMode[0]).MaxRollSpeed = 65536.f*MinigunFire(FireMode[0]).BarrelRotationsPerSec;
		MinigunFire(FireMode[1]).BarrelRotationsPerSec = MinigunFire(FireMode[1]).default.BarrelRotationsPerSec * Modifier;
		MinigunFire(FireMode[1]).FireRate = 1.f / (MinigunFire(FireMode[1]).RoundsPerRotation * MinigunFire(FireMode[1]).BarrelRotationsPerSec);
		MinigunFire(FireMode[1]).MaxRollSpeed = 65536.f*MinigunFire(FireMode[1]).BarrelRotationsPerSec;
	}
	else if (!FireMode[0].IsA('TransFire') && !FireMode[0].IsA('BallShoot') && !FireMode[0].IsA('MeleeSwordFire'))
	{
		if (FireMode[0] != None)
		{
			if (ShieldFire(FireMode[0]) != None)
				ShieldFire(FireMode[0]).FullyChargedTime = ShieldFire(FireMode[0]).default.FullyChargedTime / Modifier;
			FireMode[0].FireRate = FireMode[0].default.FireRate / Modifier;
			FireMode[0].FireAnimRate = FireMode[0].default.FireAnimRate * Modifier;
			FireMode[0].MaxHoldTime = FireMode[0].default.MaxHoldTime / Modifier;
		}
		if (FireMode[1] != None)
		{
			FireMode[1].FireRate = FireMode[1].default.FireRate / Modifier;
			FireMode[1].FireAnimRate = FireMode[1].default.FireAnimRate * Modifier;
			FireMode[1].MaxHoldTime = FireMode[1].default.MaxHoldTime / Modifier;
		}
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
     DamageMultiplier=0.300000
     SpeedMultiplier=0.050000
     AbilityName="Increased Damage Bonus"
     Description="Increases your cumulative total damage bonus by 30% per level. However, weapon speed reduced.|Cost (per level): 10. "
     StartingCost=10
     MaxLevel=20
}
