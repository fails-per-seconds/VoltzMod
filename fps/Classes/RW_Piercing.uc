class RW_Piercing extends RPGWeapon
	HideDropDown
	CacheExempt
	config(fps);

var config float DamageBonus;
var class<DamageType> ModifiedDamageType;

function float GetAIRating()
{
	if (Bot(Instigator.Controller) != None && Bot(Instigator.Controller).Enemy.ShieldStrength > 0)
		return ModifiedWeapon.GetAIRating() + AIRatingBonus;

	return ModifiedWeapon.GetAIRating();
}

function NewAdjustTargetDamage(out int Damage, int OriginalDamage, Actor Victim, vector HitLocation, out vector Momentum, class<DamageType> DamageType)
{
	local bool RunningTriple;

	if (!bIdentified)
		Identify();

	if (!class'OneDropRPGWeapon'.static.CheckCorrectDamage(ModifiedWeapon, DamageType))
		return;

	if (Damage > 0)
	{
		RunningTriple = false;
		if (Instigator.HasUDamage())
		{
			if (class'ArtifactDoubleModifier'.static.HasTripleRunning(Instigator))
			{
				Damage *= 2;
				RunningTriple = true;
			}
		}
		Damage = Max(1, Damage * (1.0 + DamageBonus * Modifier));
		if (Damage < OriginalDamage)
			Damage = OriginalDamage;

		if (RunningTriple)
			Damage = Damage/2;

		Momentum *= 1.0 + DamageBonus * Modifier;
	}

	super.AdjustTargetDamage(Damage, Victim, HitLocation, Momentum, DamageType);
}

function AdjustTargetDamage(out int Damage, Actor Victim, Vector HitLocation, out Vector Momentum, class<DamageType> DamageType)
{
	if (Pawn(Victim) != None && Pawn(Victim).ShieldStrength > 0 && DamageType.default.bArmorStops)
	{
		if (!bIdentified)
			Identify();
		DamageType.default.bArmorStops = false;
		ModifiedDamageType = DamageType;
	}
}

simulated function WeaponTick(float dt)
{
	if (ModifiedDamageType != None)
	{
		ModifiedDamageType.default.bArmorStops = true;
		ModifiedDamageType = None;
	}

	Super.WeaponTick(dt);
}

simulated function int MaxAmmo(int mode)
{
	if (bNoAmmoInstances && HolderStatsInv != None)
		return (ModifiedWeapon.MaxAmmo(mode) * (1.0 + 0.01 * HolderStatsInv.Data.AmmoMax));

	return ModifiedWeapon.MaxAmmo(mode);
}

defaultproperties
{
     DamageBonus=0.030000
     ModifierOverlay=Shader'XGameShaders.PlayerShaders.PlayerTrans'
     MinModifier=-2
     MaxModifier=6
     AIRatingBonus=0.150000
     PrefixPos="Piercing "
     PrefixNeg="Piercing "
     bCanHaveZeroModifier=True
}
