class RPGGameRules extends GameRules
	config(fps);

struct PetDamageHolder
{
	var class<Monster> PetClass;
	var class<WeaponDamageType> PetDamageType;
};
var config array<PetDamageHolder> PetDamageHolders;

function bool PreventDeath(Pawn Killed, Controller Killer, class<DamageType> damageType, vector HitLocation)
{
	local bool bAlreadyPrevented;
	local int x;
	local RPGStatsInv StatsInv;
	local Controller KilledController;
	local class<RPGDeathAbility> DeathAbility;
	local Controller PlayerSpawner;
	local FriendlyMonsterKillMarker M;
	local TeamPlayerReplicationInfo TPRI;

	bAlreadyPrevented = Super.PreventDeath(Killed, Killer, damageType, HitLocation);
	if (bAlreadyPrevented)
		return true;

	if (Killed.Controller != None)
		KilledController = Killed.Controller;
	else if (Killed.DrivenVehicle != None && Killed.DrivenVehicle.Controller != None)
		KilledController = Killed.DrivenVehicle.Controller;
	if (KilledController != None)
		StatsInv = class'RPGClass'.static.getPlayerStats(KilledController);

	if (StatsInv != None && StatsInv.DataObject != None)
	{
		if (!KilledController.bPendingDelete && (KilledController.PlayerReplicationInfo == None || !KilledController.PlayerReplicationInfo.bOnlySpectator))
		{
			for (x = 0; x < StatsInv.DataObject.Abilities.length; x++)
			{
				if (ClassIsChildOf(StatsInv.DataObject.Abilities[x], Class'RPGDeathAbility'))
				{
					DeathAbility = class<RPGDeathAbility>(StatsInv.DataObject.Abilities[x]);
					bAlreadyPrevented = DeathAbility.static.PrePreventDeath(Killed, Killer, damageType, HitLocation, StatsInv.DataObject.AbilityLevels[x]);
					if (bAlreadyPrevented)
						return true;
				}
			}

			for (x = 0; x < StatsInv.DataObject.Abilities.length; x++)
			{
				if (ClassIsChildOf(StatsInv.DataObject.Abilities[x], Class'RPGDeathAbility'))
				{
					DeathAbility = class<RPGDeathAbility>(StatsInv.DataObject.Abilities[x]);
					DeathAbility.static.PotentialDeathPending(Killed, Killer, damageType, HitLocation, StatsInv.DataObject.AbilityLevels[x]);
				}
			}

			for (x = 0; x < StatsInv.DataObject.Abilities.length; x++)
			{
				if (ClassIsChildOf(StatsInv.DataObject.Abilities[x], Class'RPGDeathAbility'))
				{
					DeathAbility = class<RPGDeathAbility>(StatsInv.DataObject.Abilities[x]);
					bAlreadyPrevented = DeathAbility.static.GenuinePreventDeath(Killed, Killer, damageType, HitLocation, StatsInv.DataObject.AbilityLevels[x]);
					if (bAlreadyPrevented)
						return true;
				}
			}

			for (x = 0; x < StatsInv.DataObject.Abilities.length; x++)
			{
				if (ClassIsChildOf(StatsInv.DataObject.Abilities[x], Class'RPGDeathAbility'))
				{
					DeathAbility = class<RPGDeathAbility>(StatsInv.DataObject.Abilities[x]);
					DeathAbility.static.GenuineDeath(Killed, Killer, damageType, HitLocation, StatsInv.DataObject.AbilityLevels[x]);
				}
			}
		}
	}

	PlayerSpawner = None;
	if (xSentinelController(Killer) != None)
		PlayerSpawner = xSentinelController(Killer).PlayerSpawner;
	else if (xSentinelBaseController(Killer) != None)
		PlayerSpawner = xSentinelBaseController(Killer).PlayerSpawner;
	else if (xLightningSentinelController(Killer) != None)
		PlayerSpawner = xLightningSentinelController(Killer).PlayerSpawner;
	else if (xEnergyWallController(Killer) != None)
		PlayerSpawner = xEnergyWallController(Killer).PlayerSpawner;
	else if (AutoGunController(Killer) != None)
		PlayerSpawner = AutoGunController(Killer).PlayerSpawner;
	if (PlayerSpawner != None)
	{
		M = spawn(class'FriendlyMonsterKillMarker', Killed);
		M.Killer = PlayerSpawner;
		M.Health = Killed.Health;
		M.DamageType = damageType;
		M.HitLocation = HitLocation;
		return true;
	}
	
	if (FriendlyMonsterController(Killer) != None && Killer.Pawn != None)
	{
		if (!ClassIsChildOf(damageType,class'WeaponDamageType') && !ClassIsChildOf(damageType,class'VehicleDamageType'))
		{
			if (FriendlyMonsterController(Killer).Master != None && FriendlyMonsterController(Killer).Master.bIsPlayer) 
			{
				TPRI = TeamPlayerReplicationInfo(FriendlyMonsterController(Killer).Master.PlayerReplicationInfo);
				if (TPRI != None)
				{
					for (x = 0; x < PetDamageHolders.length; x++)
					{
						if (Killer.Pawn.Class == PetDamageHolders[x].PetClass)
						{
							TPRI.AddWeaponKill(PetDamageHolders[x].PetDamageType);
							break;
						}
					}
				}
			}
		}
	}

	if (bAlreadyPrevented)
		return true;
	else
		return false;
}

defaultproperties
{
}
