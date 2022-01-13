class FM_SentinelFire extends FM_Sentinel_Fire;

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

	if (Instigator != None && Instigator.Controller != None && xSentinelController(Instigator.Controller) != None)
	{
		p.Damage *= xSentinelController(Instigator.Controller).DamageAdjust;
	}

	return p;
}

defaultproperties
{
     FireRate=0.330000
}
