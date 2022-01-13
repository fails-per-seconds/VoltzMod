class RPGDeathAbility extends CostRPGAbility
	abstract;

static function bool PrePreventDeath(Pawn Killed, Controller Killer, class<DamageType> DamageType, vector HitLocation, int AbilityLevel);

static function PotentialDeathPending(Pawn Killed, Controller Killer, class<DamageType> DamageType, vector HitLocation, int AbilityLevel);

static function bool GenuinePreventDeath(Pawn Killed, Controller Killer, class<DamageType> DamageType, vector HitLocation, int AbilityLevel);

static function bool PreventSever(Pawn Killed, name boneName, int Damage, class<DamageType> DamageType, int AbilityLevel)
{
	return false;
}

static function GenuineDeath(Pawn Killed, Controller Killer, class<DamageType> DamageType, vector HitLocation, int AbilityLevel);

defaultproperties
{
}
