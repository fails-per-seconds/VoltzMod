class AbilityAdrenShield extends RPGDeathAbility
	config(fps) 
	abstract;

var config int HealthLimit;
var config float HealthBonus;

static function bool PrePreventDeath(Pawn Killed, Controller Killer, class<DamageType> DamageType, vector HitLocation, int AbilityLevel)
{
	local int DamageCouldHeal, AdrenalineReqd;

	if (Killed.Controller != None)
	{
		DamageCouldHeal = Killed.Controller.Adrenaline * default.HealthBonus * AbilityLevel;
		AdrenalineReqd = Killed.Controller.Adrenaline;
		if (Killed.Health <= 0 && DamageCouldHeal + Killed.Health > 0)
		{
			if (DamageCouldHeal + Killed.Health > default.HealthLimit)
			{
				DamageCouldHeal = default.HealthLimit - Killed.Health;
				AdrenalineReqd = DamageCouldHeal / (default.HealthBonus * AbilityLevel);
			}
			Killed.Controller.Adrenaline -= AdrenalineReqd;
			Killed.Health += DamageCouldHeal;

			return true;
		}
	}

	return false;
}

static function HandleDamage(out int Damage, Pawn Injured, Pawn Instigator, out vector Momentum, class<DamageType> DamageType, bool bOwnedByInstigator, int AbilityLevel)
{
	local int iCount, DamageAbsorbed, DamageLeft;
	local float AdrenalineReqd;

	if (bOwnedByInstigator || Injured == None || Injured.Controller == None)
		return;

	if (Damage <= 0 || Damage <= Injured.Health - default.HealthLimit)
		return;

	if (DamageType.default.bArmorStops)
	{
		iCount = 0;
		while (Damage > 0 && Injured.ShieldStrength > 0 && iCount < 50)
		{
			Damage = Injured.ShieldAbsorb(Damage);
			iCount++;
		}
	}

	if (Damage <= 0 || Damage <= Injured.Health - default.HealthLimit)
		return;

	if (Injured.Health <= default.HealthLimit)
		DamageLeft = 0;
	else
		DamageLeft = Injured.Health - default.HealthLimit;
	DamageAbsorbed = Damage - DamageLeft;

	AdrenalineReqd = DamageAbsorbed / (default.HealthBonus * AbilityLevel);

	if (Injured.Controller.Adrenaline > AdrenalineReqd)
	{
		Injured.Controller.Adrenaline -= AdrenalineReqd;
		Damage = DamageLeft;
	}
	else
	{
		DamageAbsorbed = Injured.Controller.Adrenaline * default.HealthBonus * AbilityLevel;
		Injured.Controller.Adrenaline = 0;
		Damage -= DamageAbsorbed;
	}
}

defaultproperties
{
     HealthLimit=5
     HealthBonus=1.000000
     AbilityCantBuyColor=(R=164,G=14,B=122,A=200)
     AbilityMaxColor=(R=1,G=1,B=1,A=200)
     AbilityName="Energy Shield"
     DescColor(0)=(R=255,G=255,B=255,A=220)
     Description(0)="Uses adrenaline as a shield. Cost (per level): 15."
     StartingCost=15
     MaxLevel=4
}
