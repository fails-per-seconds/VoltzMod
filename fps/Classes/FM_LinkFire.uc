class FM_LinkFire extends FM_LinkTurret_Fire;

function Projectile SpawnProjectile(Vector Start, Rotator Dir)
{
	local xLinkTurretPlasma Proj;

	Start += Vector(Dir) * 10.0 * WeaponLinkTurret(Weapon).Links;
	Proj = Weapon.Spawn(class'xLinkTurretPlasma',,, Start, Dir);
	if (Proj != None)
	{
		Proj.Links = WeaponLinkTurret(Weapon).Links;
		Proj.LinkAdjust();
	}
	return Proj;
}

function ServerPlayFiring()
{
	if (WeaponLinkTurret(Weapon).Links > 0)
		FireSound = LinkedFireSound;
	else
		FireSound = default.FireSound;

	super.ServerPlayFiring();
}

function PlayFiring()
{
	if (WeaponLinkTurret(Weapon).Links > 0)
		FireSound = LinkedFireSound;
	else
		FireSound = default.FireSound;

	super.PlayFiring();
}

defaultproperties
{
     FireRate=0.400000
}
