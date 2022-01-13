class BTClient_SpawnWeapon extends Weapon
	HideDropDown;

simulated function Fire(float F)
{
	if (Level.NetMode != NM_DedicatedServer)
		Instigator.Controller.ConsoleCommand("mutate SetClientSpawn");
}

simulated function AltFire(float F)
{
	if (Level.NetMode != NM_DedicatedServer)
		Instigator.Controller.ConsoleCommand("mutate DeleteClientSpawn");
}

simulated function bool ConsumeAmmo(int Mode, float load, optional bool bAmountNeededIsMax)
{
	return false;
}

simulated function bool HasAmmo()
{
	return true;
}

defaultproperties
{
     FireModeClass(0)=Class'XWeapons.SniperZoom'
     FireModeClass(1)=Class'XWeapons.SniperZoom'
     PutDownAnim="PutDown"
     IdleAnimRate=0.250000
     SelectSound=Sound'WeaponSounds.Misc.translocator_change'
     SelectForce="Translocator_change"
     bCanThrow=False
     DisplayFOV=60.000000
     Priority=1
     HudColor=(B=255,G=0,R=0)
     SmallViewOffset=(X=38.000000,Y=16.000000,Z=-16.000000)
     CenteredOffsetY=0.000000
     CenteredRoll=0
     CustomCrosshair=2
     CustomCrossHairColor=(G=0,R=0)
     CustomCrossHairTextureName="Crosshairs.Hud.Crosshair_Cross3"
     InventoryGroup=10
     PlayerViewOffset=(X=28.500000,Y=12.000000,Z=-12.000000)
     PlayerViewPivot=(Pitch=1000,Yaw=400)
     BobDamping=1.800000
     AttachmentClass=Class'XWeapons.TransAttachment'
     IconMaterial=Texture'HUDContent.Generic.HUD'
     IconCoords=(X2=2,Y2=2)
     ItemName="Spawn Manager"
     Mesh=SkeletalMesh'NewWeapons2004.NewTranslauncher_1st'
     DrawScale=0.800000
     Skins(0)=FinalBlend'EpicParticles.JumpPad.NewTransLaunBoltFB'
     Skins(1)=Texture'WeaponSkins.Skins.NEWTranslocatorTEX'
     Skins(2)=Texture'WeaponSkins.AmmoPickups.NEWTranslocatorPUCK'
     Skins(3)=FinalBlend'WeaponSkins.AmmoPickups.NewTransGlassFB'
}
