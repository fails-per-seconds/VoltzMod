class RW_Energy extends RPGWeapon
	HideDropDown
	CacheExempt
	config(fps);

var config float DamageBonus;

static function bool AllowedFor(class<Weapon> Weapon, Pawn Other)
{
	if (Other.Controller != None && Other.Controller.bAdrenalineEnabled)
		return true;

	return false;
}

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
	local float AdrenalineBonus;
	
	if (!bIdentified)
		Identify();

	if (!class'OneDropRPGWeapon'.static.CheckCorrectDamage(ModifiedWeapon, DamageType))
		return;

	if (damage > 0)
	{
		Damage = Max(1, Damage * (1.0 + DamageBonus * Modifier));
		Momentum *= 1.0 + DamageBonus * Modifier;
	}

	if (Pawn(Victim) == None || Instigator == None)
		return;

	AdrenalineBonus = Damage;

	if (AdrenalineBonus > Pawn(Victim).Health)
		AdrenalineBonus = Pawn(Victim).Health;

	AdrenalineBonus *= 0.02 * Modifier;

	if ( UnrealPlayer(Instigator.Controller) != None && Instigator.Controller.Adrenaline < Instigator.Controller.AdrenalineMax
	     && Instigator.Controller.Adrenaline + AdrenalineBonus >= Instigator.Controller.AdrenalineMax && !Instigator.InCurrentCombo() )
		UnrealPlayer(Instigator.Controller).ClientDelayedAnnouncementNamed('Adrenalin', 15);
	Instigator.Controller.Adrenaline = FMin(Instigator.Controller.Adrenaline + AdrenalineBonus, Instigator.Controller.AdrenalineMax);
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
     ModifierOverlay=Shader'XGameShaders.PlayerShaders.LightningHit'
     MinModifier=-2
     MaxModifier=3
     AIRatingBonus=0.020000
     PostfixPos=" of Energy"
     PrefixNeg="Draining "
}
