class RW_Healing extends RPGWeapon
	HideDropDown
	CacheExempt;

static function bool AllowedFor(class<Weapon> Weapon, Pawn Other)
{
	local int x;
	local class<ProjectileFire> ProjFire;
	local RPGStatsInv StatsInv;

	StatsInv = RPGStatsInv(Other.FindInventoryType(class'RPGStatsInv'));
	if (StatsInv != None && StatsInv.ClientVersion <= 12)
	{
		return false;
	}
	else if (Other.Level.Game.bTeamGame)
	{
		return true;
	}
	else
	{
		for (x = 0; x < NUM_FIRE_MODES; x++)
			if (!ClassIsChildOf(Weapon.default.FireModeClass[x], class'InstantFire'))
			{
				ProjFire = class<ProjectileFire>(Weapon.default.FireModeClass[x]);
				if (ProjFire == None || ProjFire.default.ProjectileClass == None || ProjFire.default.ProjectileClass.default.DamageRadius > 0)
					return true;
			}
	}

	return false;
}

function NewAdjustTargetDamage(out int Damage, int OriginalDamage, Actor Victim, vector HitLocation, out vector Momentum, class<DamageType> DamageType)
{
	local Pawn P;
	local int BestDamage;

	BestDamage = Max(Damage, OriginalDamage);
	if (BestDamage > 0)
	{
		P = Pawn(Victim);
		if (P != None && (P == Instigator || (P.Controller.IsA('FriendlyMonsterController') && FriendlyMonsterController(P.Controller).Master == Instigator.Controller)
		     || (P.GetTeam() == Instigator.GetTeam() && Instigator.GetTeam() != None)))
		{
			if (!bIdentified)
			{
				Identify();
			}
			P.GiveHealth(Max(1, BestDamage * (0.05 * Modifier)), P.HealthMax + 50);
			P.SetOverlayMaterial(ModifierOverlay, 1.0, false);
			Damage = 0;
		}
	}

	Super.NewAdjustTargetDamage(Damage, OriginalDamage, Victim, HitLocation, Momentum, DamageType);
}

defaultproperties
{
     ModifierOverlay=Shader'BlueShader'
     MinModifier=1
     MaxModifier=3
     AIRatingBonus=0.020000
     PrefixPos="Healing "
}
