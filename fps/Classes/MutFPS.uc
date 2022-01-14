class MutFPS extends Mutator
	config(fps);

const RPG_VERSION = 30;

var config int SaveDuringGameInterval;
var config int StartingLevel;
var config int PointsPerLevel;
var config array<int> Levels;
var config int InfiniteReqEXPOp;
var config int InfiniteReqEXPValue;
var config float LevelDiffExpGainDiv;
var config int MaxLevelupEffectStacking;
var config int EXPForWin;
var config int BotBonusLevels;
var config int StatCaps[6];
var config array<class<RPGAbility> > Abilities;
var config array<class<RPGAbility> > RemovedAbilities;
var config float WeaponModifierChance;

struct WeaponModifier
{
	var class<RPGWeapon> WeaponClass;
	var int Chance;
};

var config array<WeaponModifier> WeaponModifiers;
var int TotalModifierChance;
var config int Version;
var bool bHasInteraction;
var bool bJustSaved;
var config bool bMagicalStartingWeapons;
var config bool bAutoAdjustInvasionLevel;
var config bool bFakeBotLevels;
var config bool bIronmanMode;
var config bool bNoUnidentified;
var config bool bReset;
var config bool bUseOfficialRedirect;
var config bool bAllowMagicSuperWeaponReplenish;
var config float InvasionAutoAdjustFactor;
var int BotSpendAmount;
var config string HighestLevelPlayerName;
var config int HighestLevelPlayerLevel;
var transient RPGPlayerDataObject CurrentLowestLevelPlayer;
var transient array<RPGPlayerDataObject> OldPlayers;
var transient string LastOverrideDownloadIP;
var config array<name> SuperAmmoClassNames;
var config array< class<Monster> > ConfigMonsterList;
var array< class<Monster> > MonsterList;

var localized string PropsDisplayText[21];
var localized string PropsDescText[21];
var localized string PropsExtras;

static final function int GetVersion()
{
	return RPG_VERSION;
}

static final function MutFPS GetRPGMutator(GameInfo G)
{
	local Mutator M;
	local MutFPS RPGMut;

	for (M = G.BaseMutator; M != None && RPGMut == None; M = M.NextMutator)
	{
		RPGMut = MutFPS(M);
	}

	return RPGMut;
}

static final function bool IsSuperWeaponAmmo(class<Ammunition> AmmoClass)
{
	local int i;

	if (AmmoClass.default.MaxAmmo < 5)
	{
		return true;
	}
	else
	{
		for (i = 0; i < default.SuperAmmoClassNames.length; i++)
			if (AmmoClass.Name == default.SuperAmmoClassNames[i])
				return true;
	}

	return false;
}

function PostBeginPlay()
{
	local RPGRules G;
	local int x;
	local Pickup P;
	local RPGPlayerDataObject DataObject;
	local array<string> PlayerNames;
	local TCPNetDriver NetDriver;
	local string DownloadManagers;

	if (Version <= 20)
	{
		if (Version <= 12)
		{
			if (Levels.length == 29 && Levels[28] == 150 && InfiniteReqEXPOp == 0 && InfiniteReqEXPValue == 0)
			{
				InfiniteReqEXPValue = 5;
			}
			WeaponModifiers.Insert(0, 1);
			WeaponModifiers[0].WeaponClass = class<RPGWeapon>(DynamicLoadObject("fps.RW_Healing", class'Class'));
			WeaponModifiers[0].Chance = 1;
		}

		class'RPGArtifactManager'.static.UpdateArtifactList();

		Version = RPG_VERSION;
		SaveConfig();
	}

	G = spawn(class'RPGRules');
	G.RPGMut = self;
	G.PointsPerLevel = PointsPerLevel;
	G.LevelDiffExpGainDiv = LevelDiffExpGainDiv;
	if (Level.Game.GameRulesModifiers != None)
		G.NextGameRules = Level.Game.GameRulesModifiers;
	Level.Game.GameRulesModifiers = G;

	if (bReset)
	{
		PlayerNames = class'RPGPlayerDataObject'.static.GetPerObjectNames("fps",, 1000000);
		for (x = 0; x < PlayerNames.length; x++)
		{
			DataObject = new(None, PlayerNames[x]) class'RPGPlayerDataObject';
			DataObject.ClearConfig();

			DataObject = new(None, PlayerNames[x]) class'RPGPlayerDataObject';
		}

		bReset = false;
		SaveConfig();
	}

	for (x = 0; x < WeaponModifiers.length; x++)
		TotalModifierChance += WeaponModifiers[x].Chance;

	spawn(class'RPGArtifactManager');

	if (SaveDuringGameInterval > 0.0 && !bIronmanMode)
		SetTimer(SaveDuringGameInterval, true);

	if (StartingLevel < 1)
	{
		StartingLevel = 1;
		SaveConfig();
	}

	BotSpendAmount = PointsPerLevel * 3;

	foreach DynamicActors(class'Pickup', P)
		if (P.bScriptInitialized && !P.bGameRelevant && !CheckRelevance(P))
			P.Destroy();

	for (x = 0; x < Abilities.length; x++)
	{
		if (Abilities[x] == None)
		{
			Abilities.Remove(x, 1);
			SaveConfig();
			x--;
		}
		else if (!Abilities[x].static.AbilityIsAllowed(Level.Game, self))
		{
			RemovedAbilities[RemovedAbilities.length] = Abilities[x];
			Abilities.Remove(x, 1);
			SaveConfig();
			x--;
		}
	}

	for (x = 0; x < RemovedAbilities.length; x++)
	{
		if (RemovedAbilities[x].static.AbilityIsAllowed(Level.Game, self))
		{
			Abilities[Abilities.length] = RemovedAbilities[x];
			RemovedAbilities.Remove(x, 1);
			SaveConfig();
			x--;
		}
	}

	if (Level.NetMode != NM_StandAlone && bUseOfficialRedirect)
	{
		foreach AllObjects(class'TCPNetDriver', NetDriver)
		{
			DownloadManagers = NetDriver.GetPropertyText("DownloadManagers");
			NetDriver.SetPropertyText("DownloadManagers", "(\"IpDrv.HTTPDownload\"," $ Right(DownloadManagers, Len(DownloadManagers) - 1));
		}
	}

	Super.PostBeginPlay();
}

function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
	local int x;
	local FakeMonsterWeapon w;
	local RPGWeaponPickup p;
	local WeaponLocker Locker;
	local RPGWeaponLocker RPGLocker;
	local Controller C;
	local RPGStatsInv StatsInv;
	local Weapon Weap;

	if (Other == None)
		return true;

	if (Ammunition(Other) != None && ShieldAmmo(Other) == None)
		Ammunition(Other).MaxAmmo = 999;

	if (WeaponModifierChance > 0)
	{
		if (Other.IsA('WeaponLocker') && !Other.IsA('RPGWeaponLocker'))
		{
			Locker = WeaponLocker(Other);
			RPGLocker = RPGWeaponLocker(ReplaceWithActor(Other, "fps.RPGWeaponLocker"));
			if (RPGLocker != None)
			{
				RPGLocker.SetLocation(Locker.Location);
				RPGLocker.RPGMut = self;
				RPGLocker.ReplacedLocker = Locker;
				Locker.GotoState('Disabled');
			}
			for (x = 0; x < Locker.Weapons.length; x++)
				if (Locker.Weapons[x].WeaponClass == class'LinkGun')
					Locker.Weapons[x].WeaponClass = class'RPGLinkGun';
		}

		if (Other.IsA('WeaponPickup') && !Other.IsA('TransPickup') && !Other.IsA('RPGWeaponPickup') && !Other.IsA('SentinelDeployerPickup'))
		{
			p = RPGWeaponPickup(ReplaceWithActor(Other, "fps.RPGWeaponPickup"));
			if (p != None)
			{
				p.RPGMut = self;
				p.FindPickupBase();
				p.GetPropertiesFrom(class<WeaponPickup>(Other.Class));
			}
			return false;
		}

		if (xWeaponBase(Other) != None)
		{
			if (xWeaponBase(Other).WeaponType == class'LinkGun')
				xWeaponBase(Other).WeaponType = class'RPGLinkGun';
		}
		else
		{
			Weap = Weapon(Other);
			if (Weap != None)
			{
				for (x = 0; x < Weap.NUM_FIRE_MODES; x++)
				{
					if (Weap.FireModeClass[x] == class'ShockProjFire')
						Weap.FireModeClass[x] = class'RPGShockProjFire';
					else if (Weap.FireModeClass[x] == class'PainterFire')
						Weap.FireModeClass[x] = class'RPGPainterFire';
				}
			}
		}
	}
	else if (Other.IsA('Weapon'))
	{
		Weapon(Other).bNoAmmoInstances = false;
	}

	if (Other.IsA('Monster'))
	{
		Pawn(Other).HealthMax = Pawn(Other).Health;
		w = spawn(class'FakeMonsterWeapon',Other,,,rot(0,0,0));
		w.GiveTo(Pawn(Other));
	}
	else if (Pawn(Other) != None)
	{
		C = Controller(Other.Owner);
		if (C != None && C.Pawn != None)
		{
			StatsInv = RPGStatsInv(C.Pawn.FindInventoryType(class'RPGStatsInv'));
			if (StatsInv != None)
				StatsInv.OwnerDied();
		}
	}

	if (Controller(Other) != None && class'RPGArtifactManager'.default.ArtifactDelay > 0 && class'RPGArtifactManager'.default.MaxArtifacts > 0
	     && class'RPGArtifactManager'.default.AvailableArtifacts.length > 0)
		Controller(Other).bAdrenalineEnabled = true;

	return true;
}

function Actor ReplaceWithActor(actor Other, string aClassName)
{
	local Actor A;
	local class<Actor> aClass;

	if (aClassName == "")
		return None;

	aClass = class<Actor>(DynamicLoadObject(aClassName, class'Class'));
	if (aClass != None)
		A = Spawn(aClass,Other.Owner,Other.tag,Other.Location, Other.Rotation);
	if (Other.IsA('Pickup'))
	{
		if (Pickup(Other).MyMarker != None)
		{
			Pickup(Other).MyMarker.markedItem = Pickup(A);
			if (Pickup(A) != None)
			{
				Pickup(A).MyMarker = Pickup(Other).MyMarker;
				A.SetLocation(A.Location + (A.CollisionHeight - Other.CollisionHeight) * vect(0,0,1));
			}
			Pickup(Other).MyMarker = None;
		}
		else if (A.IsA('Pickup'))
			Pickup(A).Respawntime = 0.0;
	}
	if (A != None)
	{
		A.event = Other.event;
		A.tag = Other.tag;
		return A;
	}
	return None;
}

function ModifyPlayer(Pawn Other)
{
	local RPGPlayerDataObject data;
	local int x, FakeBotLevelDiff;
	local RPGStatsInv StatsInv;
	local Inventory Inv;
	local array<Weapon> StartingWeapons;
	local class<Weapon> StartingWeaponClass;
	local RPGWeapon MagicWeapon;

	Super.ModifyPlayer(Other);

	if (Other.Controller == None || !Other.Controller.bIsPlayer)
		return;
	StatsInv = RPGStatsInv(Other.FindInventoryType(class'RPGStatsInv'));
	if (StatsInv != None)
	{
		if (StatsInv.Instigator != None)
			for (x = 0; x < StatsInv.Data.Abilities.length; x++)
				StatsInv.Data.Abilities[x].static.ModifyPawn(StatsInv.Instigator, StatsInv.Data.AbilityLevels[x]);
		return;
	}
	else
	{
		for (Inv = Other.Controller.Inventory; Inv != None; Inv = Inv.Inventory)
		{
			StatsInv = RPGStatsInv(Inv);
			if (StatsInv != None)
				break;
			if (Inv.Inventory == None)
			{
				Inv.Inventory = None;
				break;
			}
		}
	}

	if (StatsInv != None)
		data = StatsInv.DataObject;
	else
	{
		data = RPGPlayerDataObject(FindObject("Package." $ Other.PlayerReplicationInfo.PlayerName, class'RPGPlayerDataObject'));
		if (data == None)
			data = new(None, Other.PlayerReplicationInfo.PlayerName) class'RPGPlayerDataObject';
		if (bFakeBotLevels && PlayerController(Other.Controller) == None)
		{
			if (data.Level != 0)
			{
				data.ClearConfig();
				data = new(None, Other.PlayerReplicationInfo.PlayerName) class'RPGPlayerDataObject';
			}

			if (CurrentLowestLevelPlayer != None)
			{
				FakeBotLevelDiff = 3 + Min(25, CurrentLowestLevelPlayer.Level * 0.1);
				data.Level = Max(StartingLevel, CurrentLowestLevelPlayer.Level - FakeBotLevelDiff + Rand(FakeBotLevelDiff * 2));
			}
			else
				data.Level = StartingLevel;

			data.PointsAvailable = PointsPerLevel * data.Level;
			data.AdrenalineMax = 100;
			if (Levels.length > data.Level)
				data.NeededExp = Levels[data.Level];
			else if (InfiniteReqEXPValue != 0)
			{
				if (InfiniteReqEXPOp == 0)
					data.NeededExp = Levels[Levels.length - 1] + InfiniteReqEXPValue * (data.Level - (Levels.length - 1));
				else
				{
					data.NeededExp = Levels[Levels.length - 1];
					for (x = Levels.length - 1; x < data.Level; x++)
						data.NeededExp += int(float(data.NeededExp) * float(InfiniteReqEXPValue) * 0.01);
				}
			}
			else
				data.NeededExp = Levels[Levels.length - 1];

			data.Experience = Rand(data.NeededExp);
			data.OwnerID = "Bot";
		}
		else if (data.Level == 0)
		{
			data.Level = StartingLevel;
			data.PointsAvailable = PointsPerLevel * (StartingLevel - 1);
			data.AdrenalineMax = 100;
			if (Levels.length > StartingLevel)
				data.NeededExp = Levels[StartingLevel];
			else if (InfiniteReqEXPValue != 0)
			{
				if (InfiniteReqEXPOp == 0)
					data.NeededExp = Levels[Levels.length - 1] + InfiniteReqEXPValue * (data.Level - (Levels.length - 1));
				else
				{
					data.NeededExp = Levels[Levels.length - 1];
					for (x = Levels.length - 1; x < StartingLevel; x++)
						data.NeededExp += int(float(data.NeededEXP) * float(InfiniteReqEXPValue) * 0.01);
				}
			}
			else
				data.NeededExp = Levels[Levels.length - 1];
			if (PlayerController(Other.Controller) != None)
				data.OwnerID = PlayerController(Other.Controller).GetPlayerIDHash();
			else
				data.OwnerID = "Bot";
		}
		else
		{
			if ( (PlayerController(Other.Controller) != None && !(PlayerController(Other.Controller).GetPlayerIDHash() ~= data.OwnerID))
			     || (Bot(Other.Controller) != None && data.OwnerID != "Bot") )
			{
				if (PlayerController(Other.Controller) != None)
					PlayerController(Other.Controller).ReceiveLocalizedMessage(class'RPGNameMessage', 0);
				Level.Game.ChangeName(Other.Controller, Other.PlayerReplicationInfo.PlayerName$"_Imposter", true);
				if (string(data.Name) ~= Other.PlayerReplicationInfo.PlayerName)
					Level.Game.ChangeName(Other.Controller, string(Rand(65000)), true);
				ModifyPlayer(Other);
				return;
			}
			ValidateData(data);
		}
	}

	if (data.PointsAvailable > 0 && Bot(Other.Controller) != None)
	{
		x = 0;
		do
		{
			BotLevelUp(Bot(Other.Controller), data);
			x++;
		} until (data.PointsAvailable <= 0 || data.BotAbilityGoal != None || x > 10000)
	}

	if ((CurrentLowestLevelPlayer == None || data.Level < CurrentLowestLevelPlayer.Level) && (!bFakeBotLevels || Other.Controller.IsA('PlayerController')))
		CurrentLowestLevelPlayer = data;

	if (StatsInv == None)
	{
		StatsInv = spawn(class'RPGStatsInv',Other,,,rot(0,0,0));
		if (Other.Controller.Inventory == None)
			Other.Controller.Inventory = StatsInv;
		else
		{
			for (Inv = Other.Controller.Inventory; Inv.Inventory != None; Inv = Inv.Inventory)
			{}
			Inv.Inventory = StatsInv;
		}
	}
	StatsInv.DataObject = data;
	data.CreateDataStruct(StatsInv.Data, false);
	StatsInv.RPGMut = self;
	StatsInv.GiveTo(Other);

	if (WeaponModifierChance > 0)
	{
		x = 0;
		for (Inv = Other.Inventory; Inv != None; Inv = Inv.Inventory)
		{
			if (Weapon(Inv) != None && RPGWeapon(Inv) == None)
				StartingWeapons[StartingWeapons.length] = Weapon(Inv);
			x++;
			if (x > 1000)
				break;
		}

		for (x = 0; x < StartingWeapons.length; x++)
		{
			StartingWeaponClass = StartingWeapons[x].Class;
			if (StartingWeaponClass.Name != 'TransLauncher' && StartingWeaponClass.Name != 'SentinelDeployer')
			{
				StartingWeapons[x].Destroy();
				if (bMagicalStartingWeapons)
					MagicWeapon = spawn(GetRandomWeaponModifier(StartingWeaponClass, Other), Other,,, rot(0,0,0));
				else
					MagicWeapon = spawn(class'RPGWeapon', Other,,, rot(0,0,0));
				MagicWeapon.Generate(None);
				MagicWeapon.SetModifiedWeapon(spawn(StartingWeaponClass,Other,,,rot(0,0,0)), bNoUnidentified);
				MagicWeapon.GiveTo(Other);
			}
		}
		Other.Controller.ClientSwitchToBestWeapon();
	}

	Other.Health = Other.default.Health + data.HealthBonus;
	Other.HealthMax = Other.default.HealthMax + data.HealthBonus;
	Other.SuperHealthMax = Other.HealthMax + (Other.default.SuperHealthMax - Other.default.HealthMax);
	Other.Controller.AdrenalineMax = data.AdrenalineMax;
	for (x = 0; x < data.Abilities.length; x++)
		data.Abilities[x].static.ModifyPawn(Other, data.AbilityLevels[x]);
}

function DriverEnteredVehicle(Vehicle V, Pawn P)
{
	local Inventory Inv;
	local RPGStatsInv StatsInv;
	local int i, DefHealth;
	local float DefLinkHealMult, HealthPct;
	local array<RPGArtifact> Artifacts;

	if (V.Controller != None)
	{
		for (Inv = V.Controller.Inventory; Inv != None; Inv = Inv.Inventory)
		{
			StatsInv = RPGStatsInv(Inv);
			if (StatsInv != None)
				break;
		}
	}

	if (StatsInv == None)
		StatsInv = RPGStatsInv(P.FindInventoryType(class'RPGStatsInv'));
	if (StatsInv != None)
	{
		if (ASVehicleFactory(V.ParentFactory) != None)
		{
			DefHealth = ASVehicleFactory(V.ParentFactory).VehicleHealth;
			DefLinkHealMult = ASVehicleFactory(V.ParentFactory).VehicleLinkHealMult;
		}
		else
		{
			DefHealth = V.default.Health;
			DefLinkHealMult = V.default.LinkHealMult;
		}
		HealthPct = float(V.Health) / V.HealthMax;
		V.HealthMax = DefHealth + StatsInv.Data.HealthBonus;
		V.Health = HealthPct * V.HealthMax;
		V.LinkHealMult = DefLinkHealMult * (V.HealthMax / DefHealth);

		StatsInv.ModifyVehicle(V);
		StatsInv.ClientModifyVehicle(V);
	}
	else
		Warn("Couldn't find RPGStatsInv for "$P.GetHumanReadableName());

	for (Inv = P.Inventory; Inv != None; Inv = Inv.Inventory)
		if (RPGArtifact(Inv) != None)
			Artifacts[Artifacts.length] = RPGArtifact(Inv);

	P.Controller = V.Controller;
	for (i = 0; i < Artifacts.length; i++)
	{
		if (Artifacts[i].bActive)
		{
			Artifacts[i].ActivatedTime = -1000000;
			Artifacts[i].Activate();
		}
		if (Artifacts[i] == P.SelectedItem)
			V.SelectedItem = Artifacts[i];
		P.DeleteInventory(Artifacts[i]);
		Artifacts[i].GiveTo(V);
	}
	P.Controller = None;

	Super.DriverEnteredVehicle(V, P);
}

function DriverLeftVehicle(Vehicle V, Pawn P)
{
	local Inventory Inv;
	local RPGStatsInv StatsInv;
	local array<RPGArtifact> Artifacts;
	local int i;

	if (P.Controller != None)
	{
		for (Inv = P.Controller.Inventory; Inv != None; Inv = Inv.Inventory)
		{
			StatsInv = RPGStatsInv(Inv);
			if (StatsInv != None)
				break;
		}
	}

	if (StatsInv == None)
		StatsInv = RPGStatsInv(P.FindInventoryType(class'RPGStatsInv'));
	if (StatsInv != None)
	{
		if (StatsInv.Instigator == V)
			V.DeleteInventory(StatsInv);

		StatsInv.UnModifyVehicle(V);
		StatsInv.ClientUnModifyVehicle(V);
	}
	else
		Warn("Couldn't find RPGStatsInv for "$P.GetHumanReadableName());

	for (Inv = V.Inventory; Inv != None; Inv = Inv.Inventory)
		if (RPGArtifact(Inv) != None)
			Artifacts[Artifacts.length] = RPGArtifact(Inv);

	V.Controller = P.Controller;
	for (i = 0; i < Artifacts.length; i++)
	{
		if (Artifacts[i].bActive)
		{
			Artifacts[i].ActivatedTime = -1000000;
			Artifacts[i].Activate();
		}
		if (Artifacts[i] == V.SelectedItem)
			P.SelectedItem = Artifacts[i];
		V.DeleteInventory(Artifacts[i]);
		Artifacts[i].GiveTo(P);
	}
	V.Controller = None;

	Super.DriverLeftVehicle(V, P);
}

function ValidateData(RPGPlayerDataObject Data)
{
	local int TotalPoints, x, y;
	local bool bAllowedAbility;

	if (StatCaps[0] >= 0)
		Data.WeaponSpeed = Min(Data.WeaponSpeed, StatCaps[0]);
	if (StatCaps[1] >= 0)
		Data.HealthBonus = Min(Data.HealthBonus, StatCaps[1]);
	if (StatCaps[2] >= 0)
		Data.AdrenalineMax = Max(Min(Data.AdrenalineMax, StatCaps[2]), Min(StatCaps[2], 100));
	else
		Data.AdrenalineMax = Max(Data.AdrenalineMax, 100);
	if (StatCaps[3] >= 0)
		Data.Attack = Min(Data.Attack, StatCaps[3]);
	if (StatCaps[4] >= 0)
		Data.Defense = Min(Data.Defense, StatCaps[4]);
	if (StatCaps[5] >= 0)
		Data.AmmoMax = Min(Data.AmmoMax, StatCaps[5]);

	TotalPoints += Data.WeaponSpeed + Data.Attack + Data.Defense + Data.AmmoMax + Data.HealthBonus;
	TotalPoints += Data.AdrenalineMax - 100;
	for (x = 0; x < Data.Abilities.length; x++)
	{
		bAllowedAbility = false;
		for (y = 0; y < Abilities.length; y++)
			if (Data.Abilities[x] == Abilities[y])
			{
				bAllowedAbility = true;
				y = Abilities.length;
			}
		if (bAllowedAbility)
		{
			for (y = 0; y < Data.AbilityLevels[x]; y++)
				TotalPoints += Data.Abilities[x].static.Cost(Data, y);
		}
		else
		{
			for (y = 0; y < Data.AbilityLevels[x]; y++)
				Data.PointsAvailable += Data.Abilities[x].static.Cost(Data, y);
			Log("Ability"@Data.Abilities[x]@"was in"@Data.Name$"'s data but is not an available ability - removed (stat points refunded)");
			Data.Abilities.Remove(x, 1);
			Data.AbilityLevels.Remove(x, 1);
			x--;
		}
	}
	TotalPoints += Data.PointsAvailable;

	if (TotalPoints != ((Data.Level - 1) * PointsPerLevel))
	{
		Data.PointsAvailable += ((Data.Level - 1) * PointsPerLevel) - TotalPoints;
		Log(Data.Name$" had "$TotalPoints$" total stat points at Level "$Data.Level$", should be "$((Data.Level - 1) * PointsPerLevel)$", PointsAvailable changed by "$(((Data.Level - 1) * PointsPerLevel) - TotalPoints)$" to compensate");
	}
}

function BotLevelUp(Bot B, RPGPlayerDataObject Data)
{
	local int WSpeedChance, HealthBonusChance, AdrenalineMaxChance, AttackChance, DefenseChance, AmmoMaxChance, AbilityChance;
	local int x, y, Index, Chance, TotalAbilityChance;
	local bool bHasAbility, bAddAbility;

	if (Data.BotAbilityGoal != None)
	{
		if (Data.BotAbilityGoal.static.Cost(Data, Data.BotGoalAbilityCurrentLevel) > Data.PointsAvailable)
			return;

		Index = -1;
		for (x = 0; x < Data.Abilities.length; x++)
			if (Data.Abilities[x] == Data.BotAbilityGoal)
			{
				Index = x;
				break;
			}
		if (Index == -1)
			Index = Data.Abilities.length;
		Data.PointsAvailable -= Data.BotAbilityGoal.static.Cost(Data, Data.BotGoalAbilityCurrentLevel);
		Data.Abilities[Index] = Data.BotAbilityGoal;
		Data.AbilityLevels[Index]++;
		Data.BotAbilityGoal = None;
		return;
	}

	WSpeedChance = 2;
	HealthBonusChance = 2;
	AdrenalineMaxChance = 1;
	AttackChance = 2;
	DefenseChance = 2;
	AmmoMaxChance = 1;
	AbilityChance = 3;

	if (B.Aggressiveness > 0.25)
	{
		WSpeedChance += 3;
		AttackChance += 3;
		AmmoMaxChance += 2;
	}
	if (B.Accuracy < 0)
	{
		WSpeedChance++;
		DefenseChance++;
		AmmoMaxChance += 2;
	}
	if (B.FavoriteWeapon != None && B.FavoriteWeapon.default.FireModeClass[0] != None && B.FavoriteWeapon.default.FireModeClass[0].default.FireRate > 1.25)
		WSpeedChance += 2;
	if (B.Tactics > 0.9)
	{
		HealthBonusChance += 3;
		AdrenalineMaxChance += 3;
		DefenseChance += 3;
	}
	else if (B.Tactics > 0.4)
	{
		HealthBonusChance += 2;
		AdrenalineMaxChance += 2;
		DefenseChance += 2;
	}
	else if (B.Tactics > 0)
	{
		HealthBonusChance++;
		AdrenalineMaxChance++;
		DefenseChance++;
	}
	if (B.StrafingAbility < 0)
	{
		HealthBonusChance++;
		AdrenalineMaxChance++;
		DefenseChance += 2;
	}
	if (B.CombatStyle < 0)
	{
		HealthBonusChance += 2;
		AdrenalineMaxChance += 2;
		DefenseChance += 2;
	}
	else if (B.CombatStyle > 0)
	{
		AttackChance += 2;
		AmmoMaxChance++;
	}
	if (Data.Level < 20)
		AbilityChance--;
	else
	{
		y = 0;
		for (x = 0; x < Data.AbilityLevels.length; x++)
			y += Data.AbilityLevels[x];
		if (y < (Data.Level - 20) / 10)
			AbilityChance++;
	}

	if (Data.AmmoMax >= 50)
		AmmoMaxChance = Max(AmmoMaxChance / 1.5, 1);
	if (Data.AdrenalineMax >= 175)
		AdrenalineMaxChance /= 1.5;

	if (StatCaps[0] >= 0 && Data.WeaponSpeed >= StatCaps[0])
		WSpeedChance = 0;
	if (StatCaps[1] >= 0 && Data.HealthBonus >= StatCaps[1])
		HealthBonusChance = 0;
	if (StatCaps[2] >= 0 && Data.AdrenalineMax >= StatCaps[2])
		AdrenalineMaxChance = 0;
	if (StatCaps[3] >= 0 && Data.Attack >= StatCaps[3])
		AttackChance = 0;
	if (StatCaps[4] >= 0 && Data.Defense >= StatCaps[4])
		DefenseChance = 0;
	if (StatCaps[5] >= 0 && Data.AmmoMax >= StatCaps[5])
		AmmoMaxChance = 0;

	Chance = Rand(WSpeedChance + HealthBonusChance + AdrenalineMaxChance + AttackChance + DefenseChance + AmmoMaxChance + AbilityChance);
	bAddAbility = false;
	if (Chance < WSpeedChance)
		Data.WeaponSpeed += Min(Data.PointsAvailable, BotSpendAmount);
	else if (Chance < WSpeedChance + HealthBonusChance)
		Data.HealthBonus += Min(Data.PointsAvailable, BotSpendAmount);
	else if (Chance < WSpeedChance + HealthBonusChance + AdrenalineMaxChance)
		Data.AdrenalineMax += Min(Data.PointsAvailable, BotSpendAmount);
	else if (Chance < WSpeedChance + HealthBonusChance + AdrenalineMaxChance + AttackChance)
		Data.Attack += Min(Data.PointsAvailable, BotSpendAmount);
	else if (Chance < WSpeedChance + HealthBonusChance + AdrenalineMaxChance + AttackChance + DefenseChance)
		Data.Defense += Min(Data.PointsAvailable, BotSpendAmount);
	else if (Chance < WSpeedChance + HealthBonusChance + AdrenalineMaxChance + AttackChance + DefenseChance + AmmoMaxChance)
		Data.AmmoMax += Min(Data.PointsAvailable, BotSpendAmount);
	else
		bAddAbility = true;
	if (!bAddAbility)
		Data.PointsAvailable -= Min(Data.PointsAvailable, BotSpendAmount);
	else
	{
		TotalAbilityChance = 0;
		for (x = 0; x < Abilities.length; x++)
		{
			bHasAbility = false;
			for (y = 0; y < Data.Abilities.length; y++)
			{
				if (Abilities[x] == Data.Abilities[y])
				{
					bHasAbility = true;
					TotalAbilityChance += Abilities[x].static.BotBuyChance(B, Data, Data.AbilityLevels[y]);
					y = Data.Abilities.length;
				}
			}
			if (!bHasAbility)
				TotalAbilityChance += Abilities[x].static.BotBuyChance(B, Data, 0);
		}
		if (TotalAbilityChance == 0)
			return;
		Chance = Rand(TotalAbilityChance);
		TotalAbilityChance = 0;
		for (x = 0; x < Abilities.length; x++)
		{
			bHasAbility = false;
			for (y = 0; y < Data.Abilities.length; y++)
			{
				if (Abilities[x] == Data.Abilities[y])
				{
					bHasAbility = true;
					TotalAbilityChance += Abilities[x].static.BotBuyChance(B, Data, Data.AbilityLevels[y]);
					if (Chance < TotalAbilityChance)
					{
						Data.BotAbilityGoal = Abilities[x];
						Data.BotGoalAbilityCurrentLevel = Data.AbilityLevels[y];
						Index = y;
					}
					y = Data.Abilities.length;
				}
			}
			if (!bHasAbility)
			{
				TotalAbilityChance += Abilities[x].static.BotBuyChance(B, Data, 0);
				if (Chance < TotalAbilityChance)
				{
					Data.BotAbilityGoal = Abilities[x];
					Data.BotGoalAbilityCurrentLevel = 0;
					Index = Data.Abilities.length;
					Data.AbilityLevels[Index] = 0;
				}
			}
			if (Chance < TotalAbilityChance)
				break;
		}
		if (Data.BotAbilityGoal.static.Cost(Data, Data.BotGoalAbilityCurrentLevel) <= Data.PointsAvailable)
		{
			Data.PointsAvailable -= Data.BotAbilityGoal.static.Cost(Data, Data.BotGoalAbilityCurrentLevel);
			Data.Abilities[Index] = Data.BotAbilityGoal;
			Data.AbilityLevels[Index]++;
			Data.BotAbilityGoal = None;
		}
	}
}

function CheckLevelUp(RPGPlayerDataObject data, PlayerReplicationInfo MessagePRI)
{
	local LevelUpEffect Effect;
	local int Count;

	while (data.Experience >= data.NeededExp && Count < 10000)
	{
		Count++;
		data.Level++;
		data.PointsAvailable += PointsPerLevel;
		data.Experience -= data.NeededExp;

		if (Levels.length > data.Level)
			data.NeededExp = Levels[data.Level];
		else if (InfiniteReqEXPValue != 0)
		{
			if (InfiniteReqEXPOp == 0)
				data.NeededExp = Levels[Levels.length - 1] + InfiniteReqEXPValue * (data.Level - (Levels.length - 1));
			else
				data.NeededExp += int(float(data.NeededEXP) * float(InfiniteReqEXPValue) / 100.f);
		}
		else
			data.NeededExp = Levels[Levels.length - 1];

		if (MessagePRI != None)
		{
			if (Count <= MaxLevelupEffectStacking && Controller(MessagePRI.Owner) != None && Controller(MessagePRI.Owner).Pawn != None)
			{
				Effect = Controller(MessagePRI.Owner).Pawn.spawn(class'LevelUpEffect', Controller(MessagePRI.Owner).Pawn);
				Effect.SetDrawScale(Controller(MessagePRI.Owner).Pawn.CollisionRadius / Effect.CollisionRadius);
				Effect.Initialize();
			}
		}

		if (data.Level > HighestLevelPlayerLevel && (!bFakeBotLevels || data.OwnerID != "Bot"))
		{
			HighestLevelPlayerName = string(data.Name);
			HighestLevelPlayerLevel = data.Level;
			SaveConfig();
		}
	}

	if (Count > 0 && MessagePRI != None)
		Level.Game.BroadCastLocalized(self, class'GainLevelMessage', data.Level, MessagePRI);
}

function class<RPGWeapon> GetRandomWeaponModifier(class<Weapon> WeaponType, Pawn Other)
{
	local int x, Chance;

	if (FRand() < WeaponModifierChance)
	{
		Chance = Rand(TotalModifierChance);
		for (x = 0; x < WeaponModifiers.Length; x++)
		{
			Chance -= WeaponModifiers[x].Chance;
			if (Chance < 0 && WeaponModifiers[x].WeaponClass.static.AllowedFor(WeaponType, Other))
				return WeaponModifiers[x].WeaponClass;
		}
	}

	return class'RPGWeapon';
}

function FillMonsterList()
{
	local Object O;
	local class<Monster> MonsterClass;

	if (MonsterList.length == 0)
	{
		if (ConfigMonsterList.length > 0)
		{
			MonsterList = ConfigMonsterList;
		}
		else
		{
			foreach AllObjects(class'Object', O)
			{
				MonsterClass = class<Monster>(O);
				if (MonsterClass != None && MonsterClass != class'Monster' && MonsterClass.default.Mesh != class'xPawn'.default.Mesh && MonsterClass.default.ScoringValue < 100)
					MonsterList[MonsterList.length] = MonsterClass;
			}
		}
	}
}

function NotifyLogout(Controller Exiting)
{
	local Inventory Inv;
	local RPGStatsInv StatsInv;
	local RPGPlayerDataObject DataObject;

	if (Level.Game.bGameRestarted)
		return;

	for (Inv = Exiting.Inventory; Inv != None; Inv = Inv.Inventory)
	{
		StatsInv = RPGStatsInv(Inv);
		if (StatsInv != None)
			break;
	}

	if (StatsInv == None)
		return;

	DataObject = StatsInv.DataObject;
	StatsInv.Destroy();

	if (!bFakeBotLevels || Exiting.IsA('PlayerController'))
	{
		if (bIronmanMode)
		{
			if (Level.Game.IsA('Invasion'))
				OldPlayers[OldPlayers.length] = DataObject;
		}
		else
		{
			DataObject.SaveConfig();
		}
	}

	if (DataObject == CurrentLowestLevelPlayer)
		FindCurrentLowestLevelPlayer();
}

function FindCurrentLowestLevelPlayer()
{
	local Controller C;
	local Inventory Inv;

	CurrentLowestLevelPlayer = None;
	for (C = Level.ControllerList; C != None; C = C.NextController)
	{
		if (C.bIsPlayer && C.PlayerReplicationInfo != None && !C.PlayerReplicationInfo.bOutOfLives && (!bFakeBotLevels || C.IsA('PlayerController')))
			for (Inv = C.Inventory; Inv != None; Inv = Inv.Inventory)
				if (RPGStatsInv(Inv) != None && (CurrentLowestLevelPlayer == None || RPGStatsInv(Inv).DataObject.Level < CurrentLowestLevelPlayer.Level))
					CurrentLowestLevelPlayer = RPGStatsInv(Inv).DataObject;
	}
}

simulated function Tick(float deltaTime)
{
	local PlayerController PC;
	local Controller C;
	local Inventory Inv;
	local RPGStatsInv StatsInv;
	local RPGPlayerDataObject NewDataObject;

	if (bJustSaved)
	{
		for (C = Level.ControllerList; C != None; C = C.NextController)
		{
			if (C.bIsPlayer)
			{
				for (Inv = C.Inventory; Inv != None; Inv = Inv.Inventory)
				{
					StatsInv = RPGStatsInv(Inv);
					if (StatsInv != None)
					{
						NewDataObject = RPGPlayerDataObject(FindObject("Package." $ string(StatsInv.DataObject.Name), class'RPGPlayerDataObject'));
						if (NewDataObject == None)
							NewDataObject = new(None, string(StatsInv.DataObject.Name)) class'RPGPlayerDataObject';
						NewDataObject.CopyDataFrom(StatsInv.DataObject);
						StatsInv.DataObject = NewDataObject;
					}
				}
			}
		}

		FindCurrentLowestLevelPlayer();
		bJustSaved = false;
	}

	if (Level.NetMode == NM_DedicatedServer || bHasInteraction)
	{
		disable('Tick');
	}
	else
	{
		PC = Level.GetLocalPlayerController();
		if (PC != None)
		{
			PC.Player.InteractionMaster.AddInteraction("fps.RPGInteraction", PC.Player);
			if (GUIController(PC.Player.GUIController) != None)
			{
				GUIController(PC.Player.GUIController).RegisterStyle(class'STY_AbilityList');
				//custom
				GUIController(PC.Player.GUIController).RegisterStyle(class'STY_MyHome');
				GUIController(PC.Player.GUIController).RegisterStyle(class'STY_MyStore');
				GUIController(PC.Player.GUIController).RegisterStyle(class'STY_MyReset');
				GUIController(PC.Player.GUIController).RegisterStyle(class'STY_CloseButton');
				GUIController(PC.Player.GUIController).RegisterStyle(class'STY_MyButton');
				GUIController(PC.Player.GUIController).RegisterStyle(class'STY_MyLabel');
				GUIController(PC.Player.GUIController).RegisterStyle(class'STY_MyList');
				GUIController(PC.Player.GUIController).RegisterStyle(class'STY_AeBox');
				GUIController(PC.Player.GUIController).RegisterStyle(class'STY_AeEditBox');
			}
			bHasInteraction = true;
			disable('Tick');
		}
	}
}

function Timer()
{
	SaveData();
}

function SaveData()
{
	local Controller C;
	local Inventory Inv;
	local int i;

	for (C = Level.ControllerList; C != None; C = C.NextController)
	{
		if ( C.bIsPlayer && (!bFakeBotLevels || C.IsA('PlayerController'))
		     && ( !bIronmanMode || (C.PlayerReplicationInfo != None && C.PlayerReplicationInfo == Level.Game.GameReplicationInfo.Winner)
		          || (C.PlayerReplicationInfo.Team != None && C.PlayerReplicationInfo.Team == Level.Game.GameReplicationInfo.Winner) ) )
		{
			for (Inv = C.Inventory; Inv != None; Inv = Inv.Inventory)
				if (Inv.IsA('RPGStatsInv'))
				{
					RPGStatsInv(Inv).DataObject.SaveConfig();
					break;
				}
		}
	}

	if (bIronmanMode && Level.Game.IsA('Invasion') && Level.Game.GameReplicationInfo.Winner == TeamGame(Level.Game).Teams[0])
	{
		for (i = 0; i < OldPlayers.length; i++)
			OldPlayers[i].SaveConfig();
	}
}

function GetServerDetails(out GameInfo.ServerResponseLine ServerState)
{
	local int i, NumPlayers;
	local float AvgLevel;
	local Controller C;
	local Inventory Inv;

	Super.GetServerDetails(ServerState);

	i = ServerState.ServerInfo.Length;

	ServerState.ServerInfo.Length = i+1;
	ServerState.ServerInfo[i].Key = "FPS Version";
	ServerState.ServerInfo[i++].Value = ""$(RPG_VERSION / 10)$"."$int(RPG_VERSION % 10);

	ServerState.ServerInfo.Length = i+1;
	ServerState.ServerInfo[i].Key = "Starting Level";
	ServerState.ServerInfo[i++].Value = string(StartingLevel);

	ServerState.ServerInfo.Length = i+1;
	ServerState.ServerInfo[i].Key = "Stat Points Per Level";
	ServerState.ServerInfo[i++].Value = string(PointsPerLevel);

	if (!Level.Game.bGameRestarted)
	{
		for (C = Level.ControllerList; C != None; C = C.NextController)
		{
			if (C.bIsPlayer && (!bFakeBotLevels || C.IsA('PlayerController')))
			{
				for (Inv = C.Inventory; Inv != None; Inv = Inv.Inventory)
					if (Inv.IsA('RPGStatsInv'))
					{
						AvgLevel += RPGStatsInv(Inv).DataObject.Level;
						NumPlayers++;
					}
			}
		}
		if (NumPlayers > 0)
			AvgLevel = AvgLevel / NumPlayers;

		ServerState.ServerInfo.Length = i+1;
		ServerState.ServerInfo[i].Key = "Current Avg. Level";
		ServerState.ServerInfo[i++].Value = ""$AvgLevel;
	}

	if (HighestLevelPlayerLevel > 0)
	{
		ServerState.ServerInfo.Length = i+1;
		ServerState.ServerInfo[i].Key = "Highest Level Player";
		ServerState.ServerInfo[i++].Value = HighestLevelPlayerName@"("$HighestLevelPlayerLevel$")";
	}

	ServerState.ServerInfo.Length = i+1;
	ServerState.ServerInfo[i].Key = "Magic Weapon Chance";
	ServerState.ServerInfo[i++].Value = string(int(WeaponModifierChance*100))$"%";

	ServerState.ServerInfo.Length = i+1;
	ServerState.ServerInfo[i].Key = "Magical Starting Weapons";
	ServerState.ServerInfo[i++].Value = string(bMagicalStartingWeapons);

	ServerState.ServerInfo.Length = i+1;
	ServerState.ServerInfo[i].Key = "Artifacts";
	ServerState.ServerInfo[i++].Value = string(class'RPGArtifactManager'.default.MaxArtifacts > 0 && class'RPGArtifactManager'.default.ArtifactDelay > 0);

	if (Level.Game.IsA('Invasion'))
	{
		ServerState.ServerInfo.Length = i+1;
		ServerState.ServerInfo[i].Key = "Auto Adjust Invasion Monster Level";
		ServerState.ServerInfo[i++].Value = string(bAutoAdjustInvasionLevel);
		if (bAutoAdjustInvasionLevel)
		{
			ServerState.ServerInfo.Length = i+1;
			ServerState.ServerInfo[i].Key = "Monster Adjustment Factor";
			ServerState.ServerInfo[i++].Value = string(InvasionAutoAdjustFactor);
		}
	}

	ServerState.ServerInfo.Length = i+1;
	ServerState.ServerInfo[i].Key = "Ironman Mode";
	ServerState.ServerInfo[i++].Value = string(bIronmanMode);
}

event bool OverrideDownload(string PlayerIP, string PlayerID, string PlayerURL, out string RedirectURL)
{
	if (!bUseOfficialRedirect || LastOverrideDownloadIP ~= PlayerIP)
	{
		return Super.OverrideDownload(PlayerIP, PlayerID, PlayerURL, RedirectURL);
	}
	else
	{
		RedirectURL = "http://jasvant.nl/squigz/inv/";
		LastOverrideDownloadIP = PlayerIP;
		return true;
	}
}

function Mutate(string MutateString, PlayerController Sender)
{
	local GhostInv Inv;
	local Pawn P;

	if (MutateString ~= "g")
	{
		P = Pawn(Sender.ViewTarget);
		if (P != None)
		{
			Inv = GhostInv(P.FindInventoryType(class'GhostInv'));
			if (Inv != None)
			{
				Inv.ReviveInstigator();
				P.Suicide();
			}
		}
	}

	Super.Mutate(MutateString, Sender);
}

event PreSaveGame()
{
	local Controller C;
	local Inventory Inv;
	local RPGStatsInv StatsInv;
	local RPGPlayerDataObject NewDataObject;

	for (C = Level.ControllerList; C != None; C = C.NextController)
	{
		if (C.bIsPlayer)
		{
			for (Inv = C.Inventory; Inv != None; Inv = Inv.Inventory)
			{
				StatsInv = RPGStatsInv(Inv);
				if (StatsInv != None)
				{
					NewDataObject = RPGPlayerDataObject(FindObject(string(xLevel) $ "." $ string(StatsInv.DataObject.Name), class'RPGPlayerDataObject'));
					if (NewDataObject == None)
						NewDataObject = new(xLevel, string(StatsInv.DataObject.Name)) class'RPGPlayerDataObject';
					NewDataObject.CopyDataFrom(StatsInv.DataObject);
					StatsInv.DataObject = NewDataObject;
				}
			}
		}
	}

	Level.GetLocalPlayerController().Player.GUIController.CloseAll(false);

	bJustSaved = true;
	enable('Tick');
}

event PostLoadSavedGame()
{
	bHasInteraction = false;
	enable('Tick');
}

static function FillPlayInfo(PlayInfo PlayInfo)
{
	local int i;

	Super.FillPlayInfo(PlayInfo);

	PlayInfo.AddSetting("fps", "SaveDuringGameInterval", default.PropsDisplayText[i++], 1, 10, "Text", "3;0:999");
	PlayInfo.AddSetting("fps", "StartingLevel", default.PropsDisplayText[i++], 1, 10, "Text", "5;1:99999");
	PlayInfo.AddSetting("fps", "PointsPerLevel", default.PropsDisplayText[i++], 5, 10, "Text", "5;1:99999");
	PlayInfo.AddSetting("fps", "LevelDiffExpGainDiv", default.PropsDisplayText[i++], 1, 10, "Text", "5;0.001:100.0",,, true);
	PlayInfo.AddSetting("fps", "EXPForWin", default.PropsDisplayText[i++], 10, 10, "Text", "7;0:9999999");
	PlayInfo.AddSetting("fps", "bFakeBotLevels", default.PropsDisplayText[i++], 4, 10, "Check");
	PlayInfo.AddSetting("fps", "bReset", default.PropsDisplayText[i++], 0, 10, "Check");
	PlayInfo.AddSetting("fps", "WeaponModifierChance", default.PropsDisplayText[i++], 50, 10, "Text", "4;0.0:1.0");
	PlayInfo.AddSetting("fps", "bMagicalStartingWeapons", default.PropsDisplayText[i++], 0, 10, "Check");
	PlayInfo.AddSetting("fps", "bNoUnidentified", default.PropsDisplayText[i++], 0, 10, "Check");
	PlayInfo.AddSetting("fps", "bAutoAdjustInvasionLevel", default.PropsDisplayText[i++], 1, 10, "Check");
	PlayInfo.AddSetting("fps", "InvasionAutoAdjustFactor", default.PropsDisplayText[i++], 1, 10, "Text", "4;0.01:3.0");
	PlayInfo.AddSetting("fps", "MaxLevelupEffectStacking", default.PropsDisplayText[i++], 1, 10, "Text", "2;1:10",,, true);
	PlayInfo.AddSetting("fps", "StatCaps", default.PropsDisplayText[i++], 1, 14, "Text",,,, true);
	PlayInfo.AddSetting("fps", "InfiniteReqEXPOp", default.PropsDisplayText[i++], 1, 12, "Select", default.PropsExtras,,, true);
	PlayInfo.AddSetting("fps", "InfiniteReqEXPValue", default.PropsDisplayText[i++], 1, 13, "Text", "3;0:999",,, true);
	PlayInfo.AddSetting("fps", "Levels", default.PropsDisplayText[i++], 1, 11, "Text",,,, true);
	PlayInfo.AddSetting("fps", "Abilities", default.PropsDisplayText[i++], 1, 15, "Text",,,, true);
	PlayInfo.AddSetting("fps", "bIronmanMode", default.PropsDisplayText[i++], 4, 10, "Check",,,, true);
	PlayInfo.AddSetting("fps", "bUseOfficialRedirect", default.PropsDisplayText[i++], 4, 10, "Check",,, true, true);
	PlayInfo.AddSetting("fps", "BotBonusLevels", default.PropsDisplayText[i++], 4, 10, "Text", "2;0:99",,, true);

	class'RPGArtifactManager'.static.FillPlayInfo(PlayInfo);
}

static function string GetDescriptionText(string PropName)
{
	switch (PropName)
	{
		case "SaveDuringGameInterval":	return default.PropsDescText[0];
		case "StartingLevel":		return default.PropsDescText[1];
		case "PointsPerLevel":		return default.PropsDescText[2];
		case "LevelDiffExpGainDiv":	return default.PropsDescText[3];
		case "EXPForWin":		return default.PropsDescText[4];
		case "bFakeBotLevels":		return default.PropsDescText[5];
		case "bReset":			return default.PropsDescText[6];
		case "WeaponModifierChance":	return default.PropsDescText[7];
		case "bMagicalStartingWeapons":	return default.PropsDescText[8];
		case "bNoUnidentified":		return default.PropsDescText[9];
		case "bAutoAdjustInvasionLevel":return default.PropsDescText[10];
		case "InvasionAutoAdjustFactor":return default.PropsDescText[11];
		case "MaxLevelupEffectStacking":return default.PropsDescText[12];
		case "StatCaps":		return default.PropsDescText[13];
		case "InfiniteReqEXPOp":	return default.PropsDescText[14];
		case "InfiniteReqEXPValue":	return default.PropsDescText[15];
		case "Levels":			return default.PropsDescText[16];
		case "Abilities":		return default.PropsDescText[17];
		case "bIronmanMode":		return default.PropsDescText[18];
		case "bUseOfficialRedirect":	return default.PropsDescText[19];
		case "BotBonusLevels":		return default.PropsDescText[20];
	}
}

defaultproperties
{
     SaveDuringGameInterval=5
     StartingLevel=15
     PointsPerLevel=5
     Levels[1]=1
     Levels[2]=1
     Levels[3]=1
     Levels[4]=1
     Levels[5]=1
     Levels[6]=1
     Levels[7]=1
     Levels[8]=1
     Levels[9]=1
     Levels[10]=1
     Levels[11]=1
     Levels[12]=1
     Levels[13]=1
     Levels[14]=1
     Levels[15]=37
     InfiniteReqEXPValue=33
     LevelDiffExpGainDiv=1.000000
     MaxLevelupEffectStacking=1
     EXPForWin=100000
     BotBonusLevels=1
     StatCaps[0]=300
     StatCaps[1]=7500
     StatCaps[2]=1000
     StatCaps[3]=0
     StatCaps[4]=0
     StatCaps[5]=2000
     Abilities[0]=Class'fps.AbilityRegen'
     Abilities[1]=Class'fps.AbilityAdrenRegen'
     Abilities[2]=Class'fps.AbilityAmmoRegen'
     Abilities[3]=Class'fps.AbilityCounterShove'
     Abilities[4]=Class'fps.AbilityJumpZ'
     Abilities[5]=Class'fps.AbilityIronLegs'
     Abilities[6]=Class'fps.AbilityRetaliate'
     Abilities[7]=Class'fps.AbilitySpeed'
     Abilities[8]=Class'fps.AbilityShieldStrength'
     Abilities[9]=Class'fps.AbilityDenial'
     Abilities[10]=Class'fps.AbilityVampire'
     Abilities[11]=Class'fps.SubClass'
     Abilities[12]=Class'fps.AbilityCautiousness'
     Abilities[13]=Class'fps.AbilitySmartHealing'
     Abilities[14]=Class'fps.AbilityAirControl'
     Abilities[15]=Class'fps.AbilityGhost'
     Abilities[16]=Class'fps.AbilityUltima'
     Abilities[17]=Class'fps.AbilityAdrenSurge'
     Abilities[18]=Class'fps.AbilityFastSwitch'
     Abilities[19]=Class'fps.AbilityAwareness'
     Abilities[20]=Class'fps.AbilityMonsterSummon'
     WeaponModifierChance=0.150000
     WeaponModifiers[0]=(WeaponClass=Class'fps.RW_Damage',Chance=4)
     WeaponModifiers[1]=(WeaponClass=Class'fps.RW_Energy',Chance=2)
     WeaponModifiers[2]=(WeaponClass=Class'fps.RW_Force',Chance=2)
     WeaponModifiers[3]=(WeaponClass=Class'fps.RW_Freeze',Chance=1)
     WeaponModifiers[4]=(WeaponClass=Class'fps.RW_Healer',Chance=2)
     WeaponModifiers[5]=(WeaponClass=Class'fps.RW_Infinity',Chance=1)
     WeaponModifiers[6]=(WeaponClass=Class'fps.RW_Knockback',Chance=1)
     WeaponModifiers[7]=(WeaponClass=Class'fps.RW_Luck',Chance=3)
     WeaponModifiers[8]=(WeaponClass=Class'fps.RW_NullEntropy',Chance=1)
     WeaponModifiers[9]=(WeaponClass=Class'fps.RW_Penetrating',Chance=2)
     WeaponModifiers[10]=(WeaponClass=Class'fps.RW_Piercing',Chance=2)
     WeaponModifiers[11]=(WeaponClass=Class'fps.RW_PoisonEH',Chance=3)
     WeaponModifiers[12]=(WeaponClass=Class'fps.RW_Protection',Chance=3)
     WeaponModifiers[13]=(WeaponClass=Class'fps.RW_Rage',Chance=1)
     WeaponModifiers[14]=(WeaponClass=Class'fps.RW_Reflection',Chance=1)
     WeaponModifiers[15]=(WeaponClass=Class'fps.RW_Speedy',Chance=1)
     WeaponModifiers[16]=(WeaponClass=Class'fps.RW_Sturdy',Chance=3)
     WeaponModifiers[17]=(WeaponClass=Class'fps.RW_Vampire',Chance=1)
     WeaponModifiers[18]=(WeaponClass=Class'fps.RW_Vorpal',Chance=1)
     Version=30
     bAutoAdjustInvasionLevel=false
     bFakeBotLevels=false
     bUseOfficialRedirect=True
     InvasionAutoAdjustFactor=0.100000
     SuperAmmoClassNames[0]="RedeemerAmmo"
     SuperAmmoClassNames[1]="BallAmmo"
     SuperAmmoClassNames[2]="SCannonAmmo"
     PropsDisplayText(0)="Autosave Interval (seconds)"
     PropsDisplayText(1)="Starting Level"
     PropsDisplayText(2)="Stat Points per Level"
     PropsDisplayText(3)="Divisor to EXP from Level Diff"
     PropsDisplayText(4)="EXP for Winning"
     PropsDisplayText(5)="Fake Bot Levels"
     PropsDisplayText(6)="Reset Player Data Next Game"
     PropsDisplayText(7)="Magic Weapon Chance"
     PropsDisplayText(8)="Magical Starting Weapons"
     PropsDisplayText(9)="No Unidentified Items"
     PropsDisplayText(10)="Auto Adjust Invasion Monster Level"
     PropsDisplayText(11)="Monster Adjustment Factor"
     PropsDisplayText(12)="Max Levelup Effects at Once"
     PropsDisplayText(13)="Stat Caps"
     PropsDisplayText(14)="Infinite Required EXP Operation"
     PropsDisplayText(15)="Infinite Required EXP Value"
     PropsDisplayText(16)="EXP Required for Each Level"
     PropsDisplayText(17)="Allowed Abilities"
     PropsDisplayText(18)="Ironman Mode"
     PropsDisplayText(19)="Use Official Redirect Server"
     PropsDisplayText(20)="Extra Bot Levelups After Match"
     PropsDescText(0)="During the game, all data will be saved every this many seconds."
     PropsDescText(1)="New players start at this Level."
     PropsDescText(2)="The number of stat points earned from a levelup."
     PropsDescText(3)="Lower values = more exp when killing someone of higher level."
     PropsDescText(4)="The EXP gained for winning a match."
     PropsDescText(5)="If checked, bots' data is not saved and instead they are simply given a level near that of the human player(s)."
     PropsDescText(6)="If checked, player data will be reset before the next match begins."
     PropsDescText(7)="Chance of any given weapon having magical properties."
     PropsDescText(8)="If checked, weapons given to players when they spawn can have magical properties."
     PropsDescText(9)="If checked, magical weapons will always be identified."
     PropsDescText(10)="If checked, Invasion monsters' level will be adjusted based on the lowest level player."
     PropsDescText(11)="Invasion monsters will be adjusted based on this fraction of the weakest player's level."
     PropsDescText(12)="The maximum number of levelup particle effects that can be spawned on a character at once."
     PropsDescText(13)="Limit on how high stats can go. Values less than 0 mean no limit. The stats are: 1: Weapon Speed 2: Health Bonus 3: Max Adrenaline 4: Damage Bonus 5: Damage Reduction 6: Max Ammo Bonus"
     PropsDescText(14)="Allows you to make the EXP required for the next level always increase, no matter how high a level you get. This option controls how it increases."
     PropsDescText(15)="Allows you to make the EXP required for the next level always increase, no matter how high a level you get. This option is the value for the previous option's operation."
     PropsDescText(16)="Change the EXP required for each level. Levels after the last in your list will use the last value in the list."
     PropsDescText(17)="Change the list of abilities players can choose from."
     PropsDescText(18)="If checked, only the winning player or team's data is saved - the losers lose the experience they gained that match."
     PropsDescText(19)="If checked, the server will redirect clients to a special official redirect server for files (all other files will continue to use the normal redirect server, if any)"
     PropsDescText(20)="If Fake Bot Levels is off, bots gain this many extra levels after a match because individual bots don't play often."
     PropsExtras="0;Add Specified Value;1;Add Specified Percent"
     bAddToServerPackages=True
     GroupName="RPG"
     FriendlyName="fps"
     Description="fps experience level system, magic weapons, and artifacts. voltz"
     bAlwaysRelevant=True
     RemoteRole=ROLE_SimulatedProxy
}
