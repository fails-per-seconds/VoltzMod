class RW_Sturdy extends RPGWeapon
	HideDropDown
	CacheExempt
	config(fps);

var config float DamageBonus;

function NewAdjustTargetDamage(out int Damage, int OriginalDamage, Actor Victim, vector HitLocation, out vector Momentum, class<DamageType> DamageType)
{
	if (damage > 0)
	{
		if (Damage < (OriginalDamage * class'OneDropRPGWeapon'.default.MinDamagePercent))
			Damage = OriginalDamage * class'OneDropRPGWeapon'.default.MinDamagePercent;
	}

	Super.NewAdjustTargetDamage(Damage, OriginalDamage, Victim, HitLocation, Momentum, DamageType);
}

function AdjustTargetDamage(out int Damage, Actor Victim, Vector HitLocation, out Vector Momentum, class<DamageType> DamageType)
{
	if (!bIdentified)
		Identify();

	if (!class'OneDropRPGWeapon'.static.CheckCorrectDamage(ModifiedWeapon, DamageType))
		return;

	if (damage > 0)
	{
		Damage = Max(1, Damage * (1.0 + DamageBonus * Modifier));
		Momentum *= 1.0 + DamageBonus * Modifier;
	}
}

function AdjustPlayerDamage(out int Damage, Pawn InstigatedBy, Vector HitLocation, out Vector Momentum, class<DamageType> DamageType)
{
	if (!bIdentified)
		Identify();
	Momentum = vect(0,0,0);
	Super.AdjustPlayerDamage(Damage, InstigatedBy, HitLocation, Momentum, DamageType);
}

simulated function int MaxAmmo(int mode)
{
	if (bNoAmmoInstances && HolderStatsInv != None)
		return (ModifiedWeapon.MaxAmmo(mode) * (1.0 + 0.01 * HolderStatsInv.Data.AmmoMax));

	return ModifiedWeapon.MaxAmmo(mode);
}

defaultproperties
{
     DamageBonus=0.040000
     ModifierOverlay=Shader'UT2004Weapons.Shaders.ShockHitShader'
     MinModifier=-1
     MaxModifier=4
     AIRatingBonus=0.700000
     PrefixPos="Sturdy "
     PrefixNeg="Sturdy "
     bCanHaveZeroModifier=True
}
