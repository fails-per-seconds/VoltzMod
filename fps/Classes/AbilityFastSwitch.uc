class AbilityFastSwitch extends RPGAbility
	abstract;

static simulated function int Cost(RPGPlayerDataObject Data, int CurrentLevel)
{
	if (Data.WeaponSpeed < 50)
		return 0;
	else
		return Super.Cost(Data, CurrentLevel);
}

static simulated function ModifyWeapon(Weapon Weapon, int AbilityLevel)
{
	local float Modifier;
	local RPGWeapon RW;

	if (!Weapon.Instigator.IsLocallyControlled())
		return;

	Modifier = 1.0 + (0.5 * AbilityLevel);
	RW = RPGWeapon(Weapon);
	if (RW != None)
	{
		RW.ModifiedWeapon.BringUpTime = RW.ModifiedWeapon.default.BringUpTime / Modifier;
		RW.ModifiedWeapon.PutDownTime = RW.ModifiedWeapon.default.PutDownTime / Modifier;
		RW.ModifiedWeapon.MinReloadPct = RW.ModifiedWeapon.default.MinReloadPct / Modifier;
		RW.ModifiedWeapon.PutDownAnimRate = RW.ModifiedWeapon.default.PutDownAnimRate * Modifier;
		RW.ModifiedWeapon.SelectAnimRate = RW.ModifiedWeapon.default.SelectAnimRate * Modifier;
	}
	else
	{	Weapon.BringUpTime = Weapon.default.BringUpTime / Modifier;
		Weapon.PutDownTime = Weapon.default.PutDownTime / Modifier;
		Weapon.MinReloadPct = Weapon.default.MinReloadPct / Modifier;
		Weapon.PutDownAnimRate = Weapon.default.PutDownAnimRate * Modifier;
		Weapon.SelectAnimRate = Weapon.default.SelectAnimRate * Modifier;
	}
}

defaultproperties
{
     AbilityCantBuyColor=(R=164,G=14,B=122,A=200)
     AbilityMaxColor=(R=1,G=1,B=1,A=200)
     AbilityName="Speed Switcher"
     DescColor(0)=(R=255,G=255,B=255,A=220)
     Description(0)="For each level of this ability, you switch weapons 50% faster. You need to have at least 50 Weapon Speed before you can purchase this ability. (Max Level: 2)"
     StartingCost=15
     CostAddPerLevel=5
     BotChance=3
     MaxLevel=2
}
