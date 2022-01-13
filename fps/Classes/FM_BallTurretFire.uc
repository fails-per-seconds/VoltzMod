class FM_BallTurretFire extends FM_BallTurret_Fire;

function Projectile SpawnProjectile(Vector Start, Rotator Dir)
{
	local Projectile p;

	p = Weapon.Spawn(class'xBallTurretPlasmaProj', Instigator, , Start, Dir);
	if (p == None)
		return None;

	p.Damage *= DamageAtten;
	return p;
}

defaultproperties
{
}
