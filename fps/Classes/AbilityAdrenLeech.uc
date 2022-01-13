class AbilityAdrenLeech extends CostRPGAbility
	abstract;

static function HandleDamage(int Damage, Pawn Injured, Pawn Instigator, out vector Momentum, class<DamageType> DamageType, bool bOwnedByInstigator, int AbilityLevel)
{
	local float AdrenalineBonus;

	if (Instigator.Weapon != None && Instigator.Weapon.IsA('RW_Rage'))
		return;

	if (Damage < 1 || !bOwnedByInstigator || DamageType == class'DamTypeRetaliation' || Injured == Instigator || Instigator == None || Injured == None ||  UnrealPlayer(Instigator.Controller) == None || Instigator.Controller.Adrenaline >= Instigator.Controller.AdrenalineMax || Instigator.InCurrentCombo() || HasActiveArtifact(Instigator))
		return;
	
	if (!ClassIsChildOf(DamageType, class'WeaponDamageType'))
		return;

	AdrenalineBonus = Damage;

	if (AdrenalineBonus > Injured.Health)
		AdrenalineBonus = Injured.Health;

	AdrenalineBonus *= 0.01 * AbilityLevel;

	if (Instigator.Controller.Adrenaline + AdrenalineBonus >= Instigator.Controller.AdrenalineMax)
		UnrealPlayer(Instigator.Controller).ClientDelayedAnnouncementNamed('Adrenalin', 15);

	Instigator.Controller.Adrenaline = FMin(Instigator.Controller.Adrenaline + AdrenalineBonus, Instigator.Controller.AdrenalineMax);
}

static function bool HasActiveArtifact(Pawn Instigator)
{
	return class'ActiveArtifactInv'.static.hasActiveArtifact(Instigator);
}

defaultproperties
{
     AbilityName="Energy Leech"
     Description="Whenever you damage another player, you gain 1% of the damage as adrenaline. Each level increases this by 1%. |Cost (per level): 2,8,14,..."
     StartingCost=2
     CostAddPerLevel=6
     MaxLevel=20
}
