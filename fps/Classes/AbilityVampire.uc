class AbilityVampire extends CostRPGAbility
	config(fps) 
	abstract;

var config int AdjustableHealingDamage;

static function HandleDamage(int Damage, Pawn Injured, Pawn Instigator, out vector Momentum, class<DamageType> DamageType, bool bOwnedByInstigator, int AbilityLevel)
{
	if (Instigator.Weapon != None && Instigator.Weapon.IsA('RW_Rage'))
		return;
	LocalHandleDamage(Damage, Injured, Instigator, Momentum, DamageType, bOwnedByInstigator, float(AbilityLevel));
}

static function LocalHandleDamage(int Damage, Pawn Injured, Pawn Instigator, out vector Momentum, class<DamageType> DamageType, bool bOwnedByInstigator, Float AbilityLevel)
{
	local float VampHealth;
	local Pawn P;

	if (!bOwnedByInstigator || DamageType == class'DamTypeRetaliation' || Injured == Instigator || Instigator == None)
		return;

	if (Vehicle(Instigator) == None)
	{
		P = Instigator;
	}
	else
	{
		P = Vehicle(Instigator).Driver;
		if (P == None)
			return;
	}

	VampHealth = Damage;

	if (Injured != None && VampHealth > Injured.Health)
		VampHealth = Injured.Health;

	VampHealth *= 0.05 * AbilityLevel;
	if (VampHealth < 1.0 && Damage > 0)
	{
		VampHealth = 1.0;
	}

	P.GiveHealth(VampHealth, P.HealthMax + default.AdjustableHealingDamage);
}

defaultproperties
{
     AdjustableHealingDamage=50
     AbilityCantBuyColor=(R=164,G=14,B=122,A=200)
     AbilityMaxColor=(R=1,G=1,B=1,A=200)
     AbilityName="Vampirism"
     DescColor(0)=(R=255,G=255,B=255,A=220)
     Description(0)="Whenever you damage an opponent, you are healed for 5% of the damage per level (up to your starting health amount + 50). You can't gain health from self-damage and you can't gain health from damage caused by the Retaliation ability. You must have a Damage Bonus of at least 50 to purchase this ability. |Cost (per level): 10,15,20,25,30,35,40,45,50..."
     StartingCost=10
     CostAddPerLevel=5
     BotChance=10
     MaxLevel=20
}
