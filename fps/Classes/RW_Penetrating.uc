class RW_Penetrating extends RPGWeapon
	HideDropDown
	CacheExempt
	config(fps);

var config float DamageBonus;

static function bool AllowedFor(class<Weapon> Weapon, Pawn Other)
{
	local int x;

	for (x = 0; x < NUM_FIRE_MODES; x++)
		if (class<InstantFire>(Weapon.default.FireModeClass[x]) != None)
			return true;

	return false;
}

function SetModifiedWeapon(Weapon w, bool bIdentify)
{
	Super.SetModifiedWeapon(w, bIdentify);

	if (InstantFire(FireMode[0]) != None && InstantFire(FireMode[1]) != None)
		AIRatingBonus *= 1.2;
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

function AdjustTargetDamage(out int Damage, Actor Victim, vector HitLocation, out vector Momentum, class<DamageType> DamageType)
{
	local int i;
	local vector X, Y, Z, StartTrace;

	if (HitLocation == vect(0,0,0))
		return;

	if (!class'OneDropRPGWeapon'.static.CheckCorrectDamage(ModifiedWeapon, DamageType))
		return;

	if (damage > 0)
	{
		Damage = Max(1, Damage * (1.0 + DamageBonus * Modifier));
		Momentum *= 1.0 + DamageBonus * Modifier;
	}

	for (i = 0; i < NUM_FIRE_MODES; i++)
	{
		if (InstantFire(FireMode[i]) != None && InstantFire(FireMode[i]).DamageType == DamageType)
		{
			if (!bIdentified)
				Identify();

			if (ShockBeamFire(FireMode[i]) != None && PlayerController(Instigator.Controller) != None)
			{
				StartTrace = Instigator.Location + Instigator.EyePosition();
				GetViewAxes(X,Y,Z);
				StartTrace = StartTrace + X*class'ShockProjFire'.Default.ProjSpawnOffset.X;
				if (!WeaponCentered())
					StartTrace = StartTrace + Hand * Y*class'ShockProjFire'.Default.ProjSpawnOffset.Y + Z*class'ShockProjFire'.Default.ProjSpawnOffset.Z;
				InstantFire(FireMode[i]).DoTrace(HitLocation + Normal(HitLocation - StartTrace) * Victim.CollisionRadius * 2, rotator(HitLocation - StartTrace));
			}
			else
				InstantFire(FireMode[i]).DoTrace(HitLocation + Normal(HitLocation - (Instigator.Location + Instigator.EyePosition())) * Victim.CollisionRadius * 2, rotator(HitLocation - (Instigator.Location + Instigator.EyePosition())));
			return;
		}
	}
}

simulated function int MaxAmmo(int mode)
{
	if (bNoAmmoInstances && HolderStatsInv != None)
		return (ModifiedWeapon.MaxAmmo(mode) * (1.0 + 0.01 * HolderStatsInv.Data.AmmoMax));

	return ModifiedWeapon.MaxAmmo(mode);
}

defaultproperties
{
     DamageBonus=0.050000
     ModifierOverlay=Shader'XGameShaders.PlayerShaders.PlayerTrans'
     MinModifier=-2
     MaxModifier=4
     AIRatingBonus=0.080000
     PrefixPos="Penetrating "
     PrefixNeg="Penetrating "
     bCanHaveZeroModifier=True
}
