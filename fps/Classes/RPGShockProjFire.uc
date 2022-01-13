class RPGShockProjFire extends ShockProjFire;

function Projectile SpawnProjectile(Vector Start, Rotator Dir)
{
	local Projectile p;

	p = Super(ProjectileFire).SpawnProjectile(Start,Dir);
	if ((ShockRifle(Weapon) != None) && (p != None))
		ShockRifle(Weapon).SetComboTarget(ShockProjectile(P));
	return p;
}

defaultproperties
{
     ProjectileClass=Class'fps.RPGShockProjectile'
}
