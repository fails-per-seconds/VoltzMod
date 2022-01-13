class AbilityWeaponsProficiency extends CostRPGAbility
	config(fps) 
	abstract;

var config float LevMultiplier, MaxIncrease;

static function GetNumKillsForWeapon(out float incPerc, class<Weapon> WeaponClass, TeamPlayerReplicationInfo TPPI, int AbilityLevel)
{
	local int i, numKills;

	incPerc = 0.0;
	if (TPPI == None)
		return;

	for (i = 0; i < TPPI.WeaponStatsArray.Length && i < 200; i++)
	{
		if (ClassIsChildOf(WeaponClass, TPPI.WeaponStatsArray[i].WeaponClass))
		{
			numKills = TPPI.WeaponStatsArray[i].Kills;
			i = TPPI.WeaponStatsArray.Length;
		}
	}
	incPerc = numKills * (AbilityLevel * default.LevMultiplier);
	if (incPerc > default.MaxIncrease)
		incPerc = default.MaxIncrease;
} 

static function HandleDamage(out int Damage, Pawn Injured, Pawn Instigator, out vector Momentum, class<DamageType> DamageType, bool bOwnedByInstigator, int AbilityLevel)
{
	local float incPerc;
	
	if (!bOwnedByInstigator)
		return;
	if (Damage > 0 && Instigator != None && ClassIsChildOf(DamageType, class'WeaponDamageType'))
	{
		GetNumKillsForWeapon(incPerc, class<WeapondamageType>(DamageType).default.WeaponClass, TeamPlayerReplicationInfo(Instigator.PlayerReplicationInfo), AbilityLevel);
		if (Instigator.HasUDamage())
		{
			incPerc = incPerc / 2.f;
		}
		Damage = damage * (incPerc + 1.0);
	}
}

static function ModifyWeapon(Weapon Weapon, int AbilityLevel)
{
	local float incPerc;
	local int intPerc;
	local Weapon W;

	if (Weapon == None || Weapon.Owner == None || Pawn(Weapon.Owner) == None || Pawn(Weapon.Owner).PlayerReplicationInfo == None || PlayerController(Pawn(Weapon.Owner).Controller) == None)
		return;
	if (Weapon.Role != ROLE_Authority)
		return;

	if (RPGWeapon(Weapon) != None)
		W = RPGWeapon(Weapon).ModifiedWeapon;
	else
		W = Weapon;

	if (instr(caps(string(W)), "AVRIL") > -1)
		GetNumKillsForWeapon(incPerc, class'ONSAVRiL', TeamPlayerReplicationInfo(Pawn(Weapon.Owner).PlayerReplicationInfo), AbilityLevel);
	else
		GetNumKillsForWeapon(incPerc, W.Class, TeamPlayerReplicationInfo(Pawn(Weapon.Owner).PlayerReplicationInfo), AbilityLevel);
	intPerc = 100 * incPerc;
	PlayerController(Pawn(Weapon.Owner).Controller).ReceiveLocalizedMessage(Class'ProficiencyMessage', intPerc,,,W);
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
     LevMultiplier=0.000500
     MaxIncrease=2.000000
     AbilityName="Weapons Proficiency"
     Description="Tracks the kills per weapon, and adds extra damage the more you kill. |Cost (per level): 20. "
     StartingCost=20
     MaxLevel=10
}
