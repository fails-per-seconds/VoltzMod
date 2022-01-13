class AbilityLoadedEngineer extends CostRPGAbility
	config(fps)
	abstract;

struct SentinelConfig
{
	Var String FriendlyName;
	var Class<Pawn> Sentinel;
	var int Points;
	var int StartHealth;
	var int NormalHealth;
	var int RecoveryPeriod;
	var int Level;
};
var config Array<SentinelConfig> SentinelConfigs;

struct TurretConfig
{
	Var String FriendlyName;
	var Class<Pawn> Turret;
	var int Points;
	var int StartHealth;
	var int NormalHealth;
	var int RecoveryPeriod;
	var int Level;
};
var config Array<TurretConfig> TurretConfigs;

struct VehicleConfig
{
	Var String FriendlyName;
	var Class<Pawn> Vehicle;
	var int Points;
	var int StartHealth;
	var int NormalHealth;
	var int RecoveryPeriod;
	var int Level;
};
var config Array<VehicleConfig> VehicleConfigs;

var config int PointsPerLevel;
var config Array<string> IncludeVehicleGametypes;

var config float WeaponDamage;
var config float AdrenalineDamage;
var config float VehicleDamage;
var config float SentinelDamage;

static function SetShieldHealingLevel(Pawn Other, RW_EngineerLink EGun)
{
	local int x;
	local RPGStatsInv StatsInv;

	if (EGun == None || Other == None)
		return;

	StatsInv = RPGStatsInv(Other.FindInventoryType(class'RPGStatsInv'));
	for (x = 0; StatsInv != None && x < StatsInv.Data.Abilities.length; x++)
	{
		if (StatsInv.Data.Abilities[x] == class'AbilityShieldHealing')
		{
			EGun.HealingLevel = StatsInv.Data.AbilityLevels[x];
			EGun.ShieldHealingPercent = class'AbilityShieldHealing'.default.ShieldHealingPercent;
		}
	}

	return;
}

static function SetSpiderBoostLevel(Pawn Other, RW_EngineerLink EGun)
{
	local int x;
	local RPGStatsInv StatsInv;

	if (EGun == None || Other == None)
		return;

	StatsInv = RPGStatsInv(Other.FindInventoryType(class'RPGStatsInv'));
	for (x = 0; StatsInv != None && x < StatsInv.Data.Abilities.length; x++)
	{
		if (StatsInv.Data.Abilities[x] == class'AbilitySpiderSteroids')
			EGun.SpiderBoost = StatsInv.Data.AbilityLevels[x] * class'AbilitySpiderSteroids'.default.LevMultiplier;
	}

	return;
}

static function EngineerPointsInv GetEngInv(Pawn Other)
{
	local EngineerPointsInv EInv;
	local RPGStatsInv StatsInv;

	StatsInv = RPGStatsInv(Other.FindInventoryType(class'RPGStatsInv'));
	EInv = EngineerPointsInv(Other.FindInventoryType(class'EngineerPointsInv'));
	if (EInv != None && StatsInv != None)
		EInv.PlayerLevel = StatsInv.Data.Level;

	if (EInv == None)
	{
		EInv = Other.spawn(class'EngineerPointsInv', Other,,, rot(0,0,0));
		if (EInv == None)
		{
			return EInv;
		}
		EInv.UsedEngineerPoints = 0;
		EInv.FastBuildPercent = 1.0;
		EInv.SentinelDamageAdjust = 1.0;
		if (StatsInv != None)
			EInv.PlayerLevel = StatsInv.Data.Level;
		EInv.giveTo(Other);
	}
	return EInv;
}

static function ModifyPawn(Pawn Other, int AbilityLevel)
{
	local int i, Level;
	local LoadedInv LoadedInv;
	local RPGArtifact Artifact;
	local bool PreciseLevel, bAddVehicles, bGotTrans;
	local Inventory OInv;
	local Weapon NewWeapon;
	local EngineerPointsInv EInv;
	local EngTranslocator ETrans;
	local RW_EngineerLink EGun;
	local Summonifact sa;

	LoadedInv = LoadedInv(Other.FindInventoryType(class'LoadedInv'));
	if (LoadedInv != None)
	{
		if (LoadedInv.bGotLoadedEngineer)
		{
			if (LoadedInv.LEAbilityLevel == AbilityLevel)
				return;
			PreciseLevel = true;
		}
	}
	else
	{
		LoadedInv = Other.spawn(class'LoadedInv');
		LoadedInv.giveTo(Other);
		PreciseLevel = false;
	}

	if (LoadedInv == None)
		return;

	LoadedInv.bGotLoadedEngineer = true;
	LoadedInv.LEAbilityLevel = AbilityLevel;

	EInv = GetEngInv(Other);
	if (EInv != None)
	{
		EInv.TotalEngineerPoints = AbilityLevel * default.PointsPerLevel;
		EInv.SentinelDamageAdjust = AbilityLevel * default.SentinelDamage;
	}

	bAddVehicles = false;
	for(i = 0; i < Default.IncludeVehicleGametypes.length; i++)
	{
		if (caps(Default.IncludeVehicleGametypes[i]) == "ALL" || (Other.Level.Game != None && instr(caps(Other.Level.Game.GameName), caps(Default.IncludeVehicleGametypes[i])) > -1))
			bAddVehicles = true;
	}

	if (PreciseLevel)
	{
		sa = Summonifact(Other.FindInventoryType(class'Summonifact'));
		while (sa != None)
		{
			Other.DeleteInventory(sa);
			sa.Destroy();
			sa = Summonifact(Other.FindInventoryType(class'Summonifact'));
		}
		OInv = Other.FindInventoryType(class'ArtifactKillAllSentinels');
		if (OInv != None)
		{
			Other.DeleteInventory(OInv);
			OInv.Destroy();
		}
		OInv = Other.FindInventoryType(class'ArtifactKillAllTurrets');
		if (OInv != None)
		{
			Other.DeleteInventory(OInv);
			OInv.Destroy();
		}
		OInv = Other.FindInventoryType(class'ArtifactKillAllVehicles');
		if (OInv != None)
		{
			Other.DeleteInventory(OInv);
			OInv.Destroy();
		}
	}

	for(i = 0; i < Default.SentinelConfigs.length; i++)
	{
		if (Default.SentinelConfigs[i].Sentinel != None)
		{
			Level = Default.SentinelConfigs[i].Level;
			if (Level == 0)
				Level = Default.SentinelConfigs[i].Points/Default.PointsPerLevel;
			if (Level <= AbilityLevel)
			{
				Artifact = Other.spawn(class'ArtifactEngSentinel', Other,,, rot(0,0,0));
				if (Artifact == None)
					continue;
				ArtifactEngSentinel(Artifact).Setup(Default.SentinelConfigs[i].FriendlyName, Default.SentinelConfigs[i].Sentinel, Default.SentinelConfigs[i].Points, Default.SentinelConfigs[i].StartHealth, Default.SentinelConfigs[i].NormalHealth, Default.SentinelConfigs[i].RecoveryPeriod);
				Artifact.GiveTo(Other);
			}
		}
	}

	for(i = 0; i < Default.TurretConfigs.length; i++)
	{
		if (Default.TurretConfigs[i].Turret != None)
		{
			Level = Default.TurretConfigs[i].Level;
			if (Level == 0)
				Level = Default.TurretConfigs[i].Points/Default.PointsPerLevel;
			if (Level <= AbilityLevel)
			{
				Artifact = Other.spawn(class'ArtifactEngTurret', Other,,, rot(0,0,0));
				if (Artifact == None)
					continue;
				ArtifactEngTurret(Artifact).Setup(Default.TurretConfigs[i].FriendlyName, Default.TurretConfigs[i].Turret, Default.TurretConfigs[i].Points, Default.TurretConfigs[i].StartHealth, Default.TurretConfigs[i].NormalHealth, Default.TurretConfigs[i].RecoveryPeriod);
				Artifact.GiveTo(Other);
			}
		}
	}

	if (bAddVehicles)
	{
		for(i = 0; i < Default.VehicleConfigs.length; i++)
		{
			if (Default.VehicleConfigs[i].vehicle != None)
			{
				Level = Default.VehicleConfigs[i].Level;
				if (Level == 0)
					Level = Default.VehicleConfigs[i].Points/Default.PointsPerLevel;
				if (Level <= AbilityLevel)
				{
					Artifact = Other.spawn(class'ArtifactEngVehicle', Other,,, rot(0,0,0));
					if (Artifact == None)
						continue;
					ArtifactEngVehicle(Artifact).Setup(Default.VehicleConfigs[i].FriendlyName, Default.VehicleConfigs[i].Vehicle, Default.VehicleConfigs[i].Points, Default.VehicleConfigs[i].StartHealth, Default.VehicleConfigs[i].NormalHealth, Default.VehicleConfigs[i].RecoveryPeriod);
					Artifact.GiveTo(Other);
				}
			}
		}
	}

	if (Default.SentinelConfigs.length > 0)
	{
		Artifact = Other.spawn(class'ArtifactKillAllSentinels', Other,,, rot(0,0,0));
		Artifact.GiveTo(Other);
	}
	if (Default.TurretConfigs.length > 0)
	{
		Artifact = Other.spawn(class'ArtifactKillAllTurrets', Other,,, rot(0,0,0));
		Artifact.GiveTo(Other);
	}
	if (bAddVehicles && Default.vehicleConfigs.length > 0)
	{
		Artifact = Other.spawn(class'ArtifactKillAllVehicles', Other,,, rot(0,0,0));
		Artifact.GiveTo(Other);
	}

	if (Other.SelectedItem == None)
		Other.NextItem();

	bGotTrans = false;
	for(OInv = Other.Inventory; OInv != None; OInv = OInv.Inventory)
	{
		if (instr(caps(OInv.ItemName), "TRANSLOCATOR") > -1 && ClassIsChildOf(OInv.Class,class'Weapon'))
			bGotTrans = true;
	}
	if (!bGotTrans)
	{
		ETrans = Other.spawn(class'EngTranslocator', Other,,, rot(0,0,0));
		if (ETrans != None)
			ETrans.GiveTo(Other);
	}

	EGun = None;
	for(OInv = Other.Inventory; OInv != None; OInv = OInv.Inventory)
	{
		if (ClassIsChildOf(OInv.Class,class'RW_EngineerLink'))
		{
			EGun = RW_EngineerLink(OInv);
			break;
		}
	}
	if (EGun != None)
		return;

	NewWeapon = Other.spawn(class'EngineerLinkGun', Other,,, rot(0,0,0));
	if (NewWeapon == None)
		return;
	while (NewWeapon.IsA('RPGWeapon'))
		NewWeapon = RPGWeapon(NewWeapon).ModifiedWeapon;

	EGun = Other.spawn(class'RW_EngineerLink', Other,,, rot(0,0,0));
	if (EGun == None)
		return;

	EGun.Generate(None);
	if (EGun != None)
	{
		SetShieldHealingLevel(Other, EGun);
		SetSpiderBoostLevel(Other, EGun);
	}

	if (EGun != None)
		EGun.SetModifiedWeapon(NewWeapon, true);

	if (EGun != None)
		EGun.GiveTo(Other);
}

static function bool OverridePickupQuery(Pawn Other, Pickup item, out byte bAllowPickup, int AbilityLevel)
{
	local class<Weapon> NewWeaponClass;

	if (RPGLinkGunPickup(item) != None)
	{
		bAllowPickup = 0;
		return true;
	}
	else if (WeaponPickup(item) != None && WeaponPickup(item).InventoryType != None)
	{
		NewWeaponClass = class<Weapon>(WeaponPickup(item).InventoryType);
		if (NewWeaponClass != None && ClassIsChildOf(NewWeaponClass, class'RPGLinkGun'))
		{
			bAllowPickup = 0;
			return true;
		}
	}
	else if (WeaponLocker(item) != None && WeaponLocker(item).InventoryType != None)
	{
		NewWeaponClass = class<Weapon>(WeaponLocker(item).InventoryType);
		if (NewWeaponClass != None && ClassIsChildOf(NewWeaponClass, class'RPGLinkGun'))
		{
			bAllowPickup = 0;
			return true;
		}
	}
	return false;
}

static function HandleDamage(out int Damage, Pawn Injured, Pawn Instigator, out vector Momentum, class<DamageType> DamageType, bool bOwnedByInstigator, int AbilityLevel)
{
	local vehicle V;
	
	if (!bOwnedByInstigator)
		return;

	if (Damage > 0)
	{
		if (ClassIsChildOf(DamageType, class'VehicleDamageType'))
		{
			Damage *= default.VehicleDamage;
		}
		else
		{
			if (ClassIsChildOf(DamageType, class'WeaponDamageType'))
			{
				V = Vehicle(Instigator);
				if (V != None)
					Damage *= default.VehicleDamage;
				else if (Instigator.Controller != None && (xSentinelController(Instigator.Controller) != None || xSentinelBaseController(Instigator.Controller) != None || xLightningSentinelController(Instigator.Controller) != None || xEnergyWallController(Instigator.Controller) != None))
					Damage *= default.SentinelDamage;
				else
					Damage *= default.WeaponDamage;
			}
			else
			{
				Damage *= default.AdrenalineDamage;
			}
		}
		if (Damage == 0)
			Damage = 1;
	}
}

defaultproperties
{
     PointsPerLevel=3
     IncludeVehicleGametypes(0)="All"
     WeaponDamage=1.000000
     AdrenalineDamage=1.000000
     VehicleDamage=1.000000
     SentinelDamage=2.000000
     MinPlayerLevel=6
     PlayerLevelStep=6
     AbilityName="Loaded Engineer"
     Description="Learn sentinels, turrets, vehicle and buildings to summon. At each level, you can summon better items. You need to have a level six times the ability level you wish to purchase. |Cost (per level): 3,4,5,6,7,8,9,10,11,12,13,14,15,16,17..."
     StartingCost=3
     CostAddPerLevel=1
     MaxLevel=30
}
