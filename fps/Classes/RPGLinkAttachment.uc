class RPGLinkAttachment extends LinkAttachment;

simulated function UpdateLinkColor()
{
	if (Instigator != None && Instigator.Weapon != None)
	{
		if (LinkGun(Instigator.Weapon) != None)
			LinkGun(Instigator.Weapon).UpdateLinkColor(LinkColor);
		else if (RPGWeapon(Instigator.Weapon) != None && LinkGun(RPGWeapon(Instigator.Weapon).ModifiedWeapon) != None)
			LinkGun(RPGWeapon(Instigator.Weapon).ModifiedWeapon).UpdateLinkColor(LinkColor);
	}

	if (MuzFlash != None)
	{
		switch (LinkColor)
		{
			case LC_Gold:
				MuzFlash.Skins[0] = FinalBlend'XEffectMat.LinkMuzProjYellowFB';
				break;
			case LC_Green:
			default:
				MuzFlash.Skins[0] = FinalBlend'XEffectMat.LinkMuzProjGreenFB';
				break;
		}
	}
}

defaultproperties
{
}
