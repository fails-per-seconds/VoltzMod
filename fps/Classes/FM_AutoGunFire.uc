class FM_AutoGunFire extends FM_Sentinel_Fire;

function Projectile SpawnProjectile(Vector Start, Rotator Dir)
{
	local Projectile p;

	if (Instigator.GetTeamNum() == 255)
		p = Weapon.Spawn(TeamProjectileClasses[0], Instigator, , Start, Dir);
	else
		p = Weapon.Spawn(TeamProjectileClasses[Instigator.GetTeamNum()], Instigator, , Start, Dir);
	if (p == None)
		return None;

	p.Damage *= DamageAtten;
	
	return p;
}

defaultproperties
{
     TeamProjectileClasses(0)=Class'fps.xAutoGunLaserProjRed'
     TeamProjectileClasses(1)=Class'fps.xAutoGunLaserProj'
     FireRate=0.450000
}
