class AbilityIncreasedProtection extends CostRPGAbility
	config(fps) 
	abstract;

var config float ProtectionMultiplier, SpeedMultiplier;

static function HandleDamage(out int Damage, Pawn Injured, Pawn Instigator, out vector Momentum, class<DamageType> DamageType, bool bOwnedByInstigator, int AbilityLevel)
{
	if (bOwnedByInstigator)
		return;
	if (Damage > 0)
	{
		Damage *= (abs(1-(AbilityLevel * default.ProtectionMultiplier)));
		if (Damage == 0)
			Damage = 1;
	}
}

static simulated function ModifyPawn(Pawn Other, int AbilityLevel)
{
	class'RW_Speedy'.static.quickfoot(0, Other);
}

static simulated function SlowDown(Pawn Other, int AbilityLevel)
{
	Other.GroundSpeed = Other.default.GroundSpeed * (1.0 - (default.SpeedMultiplier * float(AbilityLevel)));
	Other.WaterSpeed = Other.default.WaterSpeed * (1.0 - (default.SpeedMultiplier * float(AbilityLevel)));
	Other.AirSpeed = Other.default.AirSpeed * (1.0 - (default.SpeedMultiplier * float(AbilityLevel)));
}

defaultproperties
{
     ProtectionMultiplier=0.050000
     SpeedMultiplier=0.025000
     AbilityCantBuyColor=(R=164,G=14,B=122,A=200)
     AbilityMaxColor=(R=1,G=1,B=1,A=200)
     AbilityName="Increased Damage Protection"
     DescColor(0)=(R=255,G=255,B=255,A=220)
     Description(0)="Increases your cumulative total damage reduction by 5% per level. Does not apply to self damage. However, the extra armor slows you down.|Cost (per level): 10."
     StartingCost=10
     MaxLevel=20
}
