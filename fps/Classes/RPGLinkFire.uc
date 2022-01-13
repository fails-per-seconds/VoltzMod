class RPGLinkFire extends LinkFire;

function bool IsLinkable(Actor Other)
{
	local Pawn P;
	local LinkGun LG;
	local LinkFire LF;
	local int sanity;

	if (Other.IsA('Pawn') && Other.bProjTarget)
	{
		P = Pawn(Other);

		if (P.Weapon == None || (!P.Weapon.IsA('LinkGun') && (RPGWeapon(P.Weapon) == None || !RPGWeapon(P.Weapon).ModifiedWeapon.IsA('LinkGun'))))
		{
			if (Vehicle(P) != None)
				return P.TeamLink(Instigator.GetTeamNum());
			return false;
		}

		LG = LinkGun(P.Weapon);
		if (LG == None)
			LG = LinkGun(RPGWeapon(P.Weapon).ModifiedWeapon);
		LF = LinkFire(LG.GetFireMode(1));
		while (LF != None && LF.LockedPawn != None && LF.LockedPawn != P && sanity < 20)
		{
			if (LF.LockedPawn == Instigator)
				return false;
			LG = LinkGun(LF.LockedPawn.Weapon);
			if (LG == None)
			{
				if (RPGWeapon(LF.LockedPawn.Weapon) != None)
					LG = LinkGun(RPGWeapon(LF.LockedPawn.Weapon).ModifiedWeapon);
				if (LG == None)
					break;
			}
			LF = LinkFire(LG.GetFireMode(1));
			sanity++;
		}

		return (Level.Game.bTeamGame && P.GetTeamNum() == Instigator.GetTeamNum());
	}
	return false;
}

function bool AddLink(int Size, Pawn Starter)
{
	local Inventory Inv;

	if (LockedPawn != None && !bFeedbackDeath)
	{
		if (LockedPawn == Starter)
		{
			return false;
		}
		else
		{
			for (Inv = LockedPawn.Inventory; Inv != None; Inv = Inv.Inventory)
			{
				if (LinkGun(Inv) != None)
					break;
				else if (RPGWeapon(Inv) != None && LinkGun(RPGWeapon(Inv).ModifiedWeapon) != None)
				{
					Inv = RPGWeapon(Inv).ModifiedWeapon;
					break;
				}
			}
			if (Inv != None)
			{
				if (LinkFire(LinkGun(Inv).GetFireMode(1)).AddLink(Size, Starter))
					LinkGun(Inv).Links += Size;
				else
					return false;
			}
		}
	}
	return true;
}

function RemoveLink(int Size, Pawn Starter)
{
	local Inventory Inv;

	if (LockedPawn != None && !bFeedbackDeath)
	{
		if (LockedPawn != Starter)
		{
			for (Inv = LockedPawn.Inventory; Inv != None; Inv = Inv.Inventory)
			{
				if (LinkGun(Inv) != None)
					break;
				else if (RPGWeapon(Inv) != None && LinkGun(RPGWeapon(Inv).ModifiedWeapon) != None)
				{
					Inv = RPGWeapon(Inv).ModifiedWeapon;
					break;
				}
			}
			if (Inv != None)
			{
				LinkFire(LinkGun(Inv).GetFireMode(1)).RemoveLink(Size, Starter);
				LinkGun(Inv).Links -= Size;
			}
		}
	}
}

defaultproperties
{
}
