class RW_Force extends RPGWeapon
	HideDropDown
	CacheExempt
	config(fps);

var int LastFlashCount;
var config float DamageBonus;

function SetModifiedWeapon(Weapon w, bool bIdentify)
{
	Super.SetModifiedWeapon(w, bIdentify);

	if (ProjectileFire(FireMode[0]) != None && ProjectileFire(FireMode[1]) != None)
		AIRatingBonus *= 1.5;
}

static function bool AllowedFor(class<Weapon> Weapon, Pawn Other)
{
	local int x;

	for (x = 0; x < NUM_FIRE_MODES; x++)
		if (class<ProjectileFire>(Weapon.default.FireModeClass[x]) != None)
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
	if (!bIdentified)
		Identify();

	if (!class'OneDropRPGWeapon'.static.CheckCorrectDamage(ModifiedWeapon, DamageType))
		return;

	if (damage > 0)
	{
		Damage = Max(1, Damage * (1.0 + DamageBonus * Modifier));
		if (Modifier > 0)
			Momentum *= 1.0 + DamageBonus * Modifier;
		if (Modifier < 0)
			Momentum /= 1.0 + DamageBonus * abs(Modifier);
	}
	super.AdjustTargetDamage(Damage, Victim, HitLocation, Momentum, DamageType);
}

simulated event WeaponTick(float dt)
{
	local Projectile P;
	local ProjectileSpeedChanger C;

	if (Role == ROLE_Authority && Instigator != None && (WeaponAttachment(ThirdPersonActor) == None || LastFlashCount != WeaponAttachment(ThirdPersonActor).FlashCount))
	{
		foreach Instigator.CollidingActors(class'Projectile', P, 200)
		{
			if (P.Instigator == Instigator && P.Speed == P.default.Speed && P.MaxSpeed == P.default.MaxSpeed)
			{
				if (!bIdentified)
					Identify();
				P.Speed *= 1.0 + 0.2 * Modifier;
				P.MaxSpeed *= 1.0 + 0.2 * Modifier;
				P.Velocity *= 1.0 + 0.2 * Modifier;
				if (Level.NetMode != NM_Standalone)
				{
					C = spawn(class'ProjectileSpeedChanger',,,P.Location, P.Rotation);
					if (C != None)
					{
						C.Modifier = Modifier;
						C.ModifiedProjectile = P;
						C.SetBase(P);
						if (P.AmbientSound != None)
						{
							C.AmbientSound = P.AmbientSound;
							C.SoundRadius = P.SoundRadius;
						}
						else
							C.bAlwaysRelevant = true;
					}
				}
			}
		}
		if (WeaponAttachment(ThirdPersonActor) != None)
			LastFlashCount = WeaponAttachment(ThirdPersonActor).FlashCount;
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
     DamageBonus=0.040000
     ModifierOverlay=Shader'XGameShaders.PlayerShaders.PlayerTransRed'
     MaxModifier=5
     MinModifier=-5
     AIRatingBonus=0.020000
     PostfixPos=" of Force"
     PostfixNeg=" of Slow Motion"
}
