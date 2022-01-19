class AbilityVehicleVamp extends CostRPGAbility
	abstract;

static function HandleDamage(int Damage, Pawn Injured, Pawn Instigator, out vector Momentum, class<DamageType> DamageType, bool bOwnedByInstigator, int AbilityLevel)
{
	local int HealthVamped;
	local float VampDamage;
	local Vehicle v;

	if (!bOwnedByInstigator || DamageType == class'DamTypeRetaliation' || Injured == Instigator || Instigator == None)
		return;

	if (Vehicle(Instigator) == None)
		return;

	v = Vehicle(Instigator);

	if (v.Driver == None)
		if (TeamGame(Instigator.Level.Game) != None)
			return;

	if (ONSWeaponPawn(v) != None && ONSWeaponPawn(v).VehicleBase != None && !ONSWeaponPawn(v).bHasOwnHealth)
		 v = ONSWeaponPawn(v).VehicleBase;

	VampDamage = Damage;

	if (Injured != None && VampDamage > Injured.Health)
		VampDamage = Injured.Health;

	HealthVamped = int(VampDamage * 0.03 * AbilityLevel);
	if (HealthVamped == 0 && Damage > 0)
	{
		HealthVamped = 1;
	}

	v.GiveHealth(HealthVamped, v.HealthMax);
}

defaultproperties
{
     AbilityCantBuyColor=(R=164,G=14,B=122,A=200)
     AbilityMaxColor=(R=1,G=1,B=1,A=200)
     AbilityName="Armor Vampirism"
     DescColor(0)=(R=255,G=255,B=255,A=220)
     Description(0)="Whenever you damage another player from a vehicle or turret, it is healed for 3% of the damage per level (up to its starting health amount). You must have a Damage Bonus of at least 50 to purchase this ability. |Cost (per level): 10,15,20,25,30,35,40,45,50,55..."
     StartingCost=10
     CostAddPerLevel=5
     MaxLevel=20
}
