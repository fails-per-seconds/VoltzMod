class RPGAbility extends Object
	abstract;

var config color AbilityCantBuyColor;
var config color AbilityMaxColor;
var localized string AbilityName;
var config array<Color> DescColor;
var config array<string> Description;
var int StartingCost, CostAddPerLevel, BotChance, MaxLevel;

static function string MakeColorCode(color NewColor)
{
	if (NewColor.R == 0)
		NewColor.R = 1;

	if (NewColor.G == 0)
		NewColor.G = 1;

	if (NewColor.B == 0)
		NewColor.B = 1;

	return Chr(0x1B)$Chr(NewColor.R)$Chr(NewColor.G)$Chr(NewColor.B);
}

static function bool AbilityIsAllowed(GameInfo Game, MutFPS RPGMut)
{
	return true;
}

static simulated function int Cost(RPGPlayerDataObject Data, int CurrentLevel)
{
	if (CurrentLevel < default.MaxLevel)
		return default.StartingCost + default.CostAddPerLevel * CurrentLevel;
	else
		return 0;
}

static function int BotBuyChance(Bot B, RPGPlayerDataObject Data, int CurrentLevel)
{
	if (static.Cost(Data, CurrentLevel) > 0)
		return default.BotChance;
	else
		return 0;
}

static simulated function ModifyPawn(Pawn Other, int AbilityLevel);

static simulated function ModifyWeapon(Weapon Weapon, int AbilityLevel);

static simulated function ModifyVehicle(Vehicle V, int AbilityLevel);

static simulated function UnModifyVehicle(Vehicle V, int AbilityLevel);

static function HandleDamage(out int Damage, Pawn Injured, Pawn Instigator, out vector Momentum, class<DamageType> DamageType, bool bOwnedByInstigator, int AbilityLevel);

static function ScoreKill(Controller Killer, Controller Killed, bool bOwnedByKiller, int AbilityLevel);

static function bool PreventDeath(Pawn Killed, Controller Killer, class<DamageType> DamageType, vector HitLocation, int AbilityLevel, bool bAlreadyPrevented)
{
	return false;
}

static function bool PreventSever(Pawn Killed, name boneName, int Damage, class<DamageType> DamageType, int AbilityLevel)
{
	return false;
}

static function bool OverridePickupQuery(Pawn Other, Pickup item, out byte bAllowPickup, int AbilityLevel)
{
	return false;
}

defaultproperties
{
     BotChance=5
}
