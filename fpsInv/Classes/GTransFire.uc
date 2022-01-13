class GTransFire extends ProjectileFire;

var() Sound TransFireSound;
var() Sound RecallFireSound;
var() String TransFireForce;
var() String RecallFireForce;

simulated function PlayFiring()
{
	if (!GTransLauncher(Weapon).bBeaconDeployed)
	{
		Weapon.PlayAnim(FireAnim, FireAnimRate, TweenTime);
		ClientPlayForceFeedback(TransFireForce);
	}
}

function Rotator AdjustAim(Vector Start, float InAimError)
{
	return Instigator.Controller.Rotation;
}

simulated function bool AllowFire()
{
	return (GTransLauncher(Weapon).AmmoChargeF >= 1.0);
}

function projectile SpawnProjectile(Vector Start, Rotator Dir)
{
	local GTransBeacon GTransBeacon;

	if (GTransLauncher(Weapon).GTransBeacon == None)
	{
		if ((Instigator == None) || (Instigator.PlayerReplicationInfo == None) || (Instigator.PlayerReplicationInfo.Team == None))
			GTransBeacon = Weapon.Spawn(class'fpsInv.GTransBeacon',,, Start, Dir);
		else if (Instigator.PlayerReplicationInfo.Team.TeamIndex == 0)
			GTransBeacon = Weapon.Spawn(class'fpsInv.GTransBeacon',,, Start, Dir);
		else
			GTransBeacon = Weapon.Spawn(class'fpsInv.GTransBeacon',,, Start, Dir);

		GTransLauncher(Weapon).GTransBeacon = GTransBeacon;
		Weapon.PlaySound(TransFireSound,SLOT_Interact,,,,,false);
	}
	else
	{
		GTransLauncher(Weapon).ViewPlayer();
		if (GTransLauncher(Weapon).GTransBeacon.Disrupted())
		{
			if ((Instigator != None) && (PlayerController(Instigator.Controller) != None))
				PlayerController(Instigator.Controller).ClientPlaySound(Sound'WeaponSounds.BSeekLost1');
		}
		else
		{
			GTransLauncher(Weapon).GTransBeacon.Destroy();
			GTransLauncher(Weapon).GTransBeacon = None;
			Weapon.PlaySound(RecallFireSound,SLOT_Interact,,,,,false);
		}
	}
	return GTransBeacon;
}

defaultproperties
{
     TransFireSound=SoundGroup'WeaponSounds.Translocator.TranslocatorFire'
     RecallFireSound=SoundGroup'WeaponSounds.Translocator.TranslocatorModuleRegeneration'
     TransFireForce="TranslocatorFire"
     RecallFireForce="TranslocatorModuleRegeneration"
     ProjSpawnOffset=(X=25.000000,Y=8.000000)
     bLeadTarget=False
     bWaitForRelease=True
     bModeExclusive=False
     FireAnimRate=1.500000
     FireRate=0.250000
     AmmoPerFire=1
     ProjectileClass=Class'fpsInv.GTransBeacon'
     BotRefireRate=0.300000
}
