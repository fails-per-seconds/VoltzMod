class GiveItemsInv extends Inventory;

//client side only
var PlayerController PC;
var Player Player;
var RPGKeysInteraction DKInteraction;

var MutKeyBinds KeysMut;
var bool Initialized;
var bool InitializedSubClasses;
var bool InitializedAbilities;
var int tickcount;
var bool bRemovedInteraction;

var int AwarenessLevel, MedicAwarenessLevel, EngAwarenessLevel;

struct ArtifactKeyConfig
{
	Var String Alias;
	var Class<RPGArtifact> ArtifactClass;
};
var config Array<ArtifactKeyConfig> ArtifactKeyConfigs;

var Array<string> SubClasses;

struct SubClassConfig
{
	var class<RPGClass> AvailableClass;
	var string AvailableSubClass;
	var int MinLevel;
};
var Array<SubClassConfig> SubClassConfigs;

struct AbilityConfig
{
	var int SubClassIndex;
	var class<RPGAbility> AvailableAbility;
	var int MaxLevel;
};
var Array<AbilityConfig> AbilityConfigs;

var RPGStatsInv ClientStatsInv;

replication
{
	reliable if (Role < ROLE_Authority)
		DropHealthPickup, DropAdrenalinePickup, ServerSellData, ServerSetSubClass, ServerGetAbilities;
	reliable if (Role == ROLE_Authority)
		ClientReceiveKeys, ClientRemainingAbility, ClientRemoveAbilities, ClientReceiveSubClass, ClientReceiveSubClasses, ClientReceiveSubClassAbilities, ClientSetSubClass, ClientSetSubClassSizes, ClientDoReconnect, RemoveInteraction;
	reliable if (Role == ROLE_Authority)
		AwarenessLevel, MedicAwarenessLevel, EngAwarenessLevel;
}

static final function GiveItemsInv GetGiveItemsInv(Controller C)
{
	local Inventory Inv;
	local GiveItemsInv FoundGiveItemsInv;

	if (C == None)
		return None;

	for (Inv = C.Inventory; Inv != None; Inv = Inv.Inventory)
	{
		FoundGiveItemsInv = GiveItemsInv(Inv);
		if (FoundGiveItemsInv != None)
			return FoundGiveItemsInv;

		if (Inv.Inventory == Inv)
		{
			Inv.Inventory = None;
			return None;
		}
	}

	return None;
}

function PostBeginPlay()
{
	Super.PostBeginPlay();
}

simulated function PostNetBeginPlay()
{
	bRemovedInteraction = false;
	if (Level.NetMode != NM_DedicatedServer)
		enable('Tick');
	Super.PostNetBeginPlay();
}

simulated function Tick(float deltaTime)
{
	local int x;
	local RPGInteraction RPGI;

	if (Level.NetMode == NM_DedicatedServer || (DKInteraction != None && bRemovedInteraction))
	{
		disable('Tick');
	}
	else
	{
		if (!Initialized)
		{
			tickcount++;
			if (tickcount > 5000)
			{
				disable('Tick');
			}
			return;
		}

		PC = Level.GetLocalPlayerController();
		if (PC != None)
		{
			Player = PC.Player;
			if (Player != None)
			{
				for(x = 0; x < Player.LocalInteractions.length; x++)
				{
					if (RPGInteraction(Player.LocalInteractions[x]) != None && RPGKeysInteraction(Player.LocalInteractions[x]) == None)
						RPGI = RPGInteraction(Player.LocalInteractions[x]);
					else if (RPGKeysInteraction(Player.LocalInteractions[x]) != None && DKInteraction == None)
						DKInteraction = RPGKeysInteraction(Player.LocalInteractions[x]);
				}
				if (RPGI != None && Player.InteractionMaster != None)
				{
					Player.InteractionMaster.RemoveInteraction(RPGI);
					bRemovedInteraction = true;
				}
				if (DKInteraction == None)
					AddInteraction();
			}
			if (DKInteraction != None && bRemovedInteraction)
				disable('Tick');
		}
	}
}

simulated function AddInteraction()
{
	local int x;

	DKInteraction = new class'RPGKeysInteraction';
	if (DKInteraction != None)
	{
		Player.LocalInteractions.Length = Player.LocalInteractions.Length + 1;
		Player.LocalInteractions[Player.LocalInteractions.Length-1] = DKInteraction;
		DKInteraction.ViewportOwner = Player;

		DKInteraction.Initialize();
		DKInteraction.Master = Player.InteractionMaster;
		DKInteraction.GiveItemsInv = self;

		DKInteraction.ArtifactKeyConfigs.Length = 0;
		for (x = 0; x < ArtifactKeyConfigs.Length; x++)
		{
			if (ArtifactKeyConfigs[x].Alias != "")
			{
				DKInteraction.ArtifactKeyConfigs.Length = x+1;
				DKInteraction.ArtifactKeyConfigs[x].Alias = ArtifactKeyConfigs[x].Alias;
				DKInteraction.ArtifactKeyConfigs[x].ArtifactClass = ArtifactKeyConfigs[x].ArtifactClass;
			}
		}
	}
	else
		Log("Could not create RPGKeysInteraction");
} 

function InitializeKeyArray()
{
	local int x;

	if (!Initialized)
	{
		if (KeysMut != None)
		{
			for (x = 0; x < KeysMut.ArtifactKeyConfigs.Length; x++)
			{
				if (KeysMut.ArtifactKeyConfigs[x].Alias != "")
					ClientReceiveKeys(x, KeysMut.ArtifactKeyConfigs[x].Alias, KeysMut.ArtifactKeyConfigs[x].ArtifactClass);
				else
					ClientReceiveKeys(x, "", None);
			}
			ClientReceiveKeys(-1, "", None);
			Initialized = True;
		}
	}
}

simulated function ClientReceiveKeys(int index, string newAliasString, Class<RPGArtifact> newArtifactClass)
{
	if (Level.NetMode != NM_DedicatedServer)
	{
		if (index < 0)
		{
			Initialized = True;
		}
		else
		{
			ArtifactKeyConfigs.Length = index+1;
			ArtifactKeyConfigs[index].Alias = newAliasString;
			ArtifactKeyConfigs[index].ArtifactClass = newArtifactClass;
		}
	}
}

simulated function Destroyed()
{
	if (Level.NetMode != NM_DedicatedServer)
	{
		if (DKInteraction != None)
		{
			DKInteraction.GiveItemsInv = None;
			RemoveInteraction();
		}
	}

	Super.Destroyed();
}

simulated function RemoveInteraction()
{
	if (Player != None && Player.InteractionMaster != None && DKInteraction != None)
		Player.InteractionMaster.RemoveInteraction(DKInteraction);
	if (DKInteraction != None)
		DKInteraction.GiveItemsInv = None;
	DKInteraction = None;
}

static function DropHealth(Controller C)
{
	local GiveItemsInv GI;

	if (C == None)
		return;
	if (C.Pawn == None || C.Pawn.Health <= 25 || Vehicle(C.Pawn) != None)
		return;

	GI = class'GiveItemsInv'.static.GetGiveItemsInv(C);
	if (GI != None)
	{
		GI.DropHealthPickup();
	}
}

function DropHealthPickup()
{
	local vector X, Y, Z;
	local Inventory Inv;
	local int ab, HealthUsed;
	local RPGStatsInv StatsInv;
	local Controller ControllerOwner;
	local Pawn PawnOwner;
	local Pickup NewPickup; 

	ControllerOwner = Controller(Owner);
	if (ControllerOwner == None || ControllerOwner.Pawn == None)
		return;
	PawnOwner = ControllerOwner.Pawn;

	HealthUsed = class'HealthPickup'.default.HealingAmount;

	for (Inv = ControllerOwner.Inventory; Inv != None; Inv = Inv.Inventory)
	{
		StatsInv = RPGStatsInv(Inv);
		if (StatsInv != None)
			break;
	}
	if (StatsInv == None)
		StatsInv = RPGStatsInv(PawnOwner.FindInventoryType(class'RPGStatsInv'));
	if (StatsInv != None)
	{
		for (ab = 0; ab < StatsInv.Data.Abilities.length; ab++)
			if (ClassIsChildOf(StatsInv.Data.Abilities[ab], class'AbilitySmartHealing'))
				HealthUsed += 25 * 0.25 * StatsInv.Data.AbilityLevels[ab];
	}

	if (PawnOwner.Health <= HealthUsed)
		return;

	GetAxes(PawnOwner.Rotation, X, Y, Z);
	NewPickup = PawnOwner.spawn(class'HealthPickup',,, PawnOwner.Location + (1.5*PawnOwner.CollisionRadius + 1.5*class'HealthPickup'.default.CollisionRadius) * Normal(Vector(ControllerOwner.GetViewRotation())));
	if (NewPickup == None)
	{
		return;
	}
	NewPickup.RemoteRole = ROLE_SimulatedProxy;
	NewPickup.bReplicateMovement = True;
	NewPickup.bTravel=True;
	NewPickup.NetPriority=1.4;
	NewPickup.bClientAnim=true;
	NewPickup.Velocity = Vector(ControllerOwner.GetViewRotation());
	NewPickup.Velocity = NewPickup.Velocity * ((PawnOwner.Velocity Dot NewPickup.Velocity) + 500) + Vect(0,0,200);
	NewPickup.RespawnTime = 0.0;
	NewPickup.InitDroppedPickupFor(None);
	NewPickup.bAlwaysRelevant = True;

	PawnOwner.Health -= HealthUsed;
	if (PawnOwner.Health <= 0)
		PawnOwner.Health = 1;
}

static function DropAdrenaline(Controller C)
{
	local GiveItemsInv GI;

	if (C == None)
		return;
	if (C.Pawn == None || C.Pawn.Health <= 5)
		return;

	GI = class'GiveItemsInv'.static.GetGiveItemsInv(C);
	if (GI != None)
	{
		GI.DropAdrenalinePickup();
	}
}

function DropAdrenalinePickup()
{
	local vector X, Y, Z;
	local Controller ControllerOwner;
	local Pawn PawnOwner;
	local AdrenalinePickup NewPickup; 
	local xPawn xP;

	ControllerOwner = Controller(Owner);
	if (ControllerOwner == None || ControllerOwner.Pawn == None)
		return;
	PawnOwner = ControllerOwner.Pawn;

	if (ControllerOwner.Adrenaline < 25)
		return;
	xP = xPawn(PawnOwner);
	if (xP != None && xP.CurrentCombo != None)
		return;

	GetAxes(PawnOwner.Rotation, X, Y, Z);
	NewPickup = PawnOwner.spawn(class'AdrenPickup',,, PawnOwner.Location + (1.5*PawnOwner.CollisionRadius + 1.5*class'AdrenPickup'.default.CollisionRadius) * Normal(Vector(ControllerOwner.GetViewRotation())));
	if (NewPickup == None)
	{
		return;
	}
	NewPickup.RemoteRole = ROLE_SimulatedProxy;
	NewPickup.bReplicateMovement = True;
	NewPickup.bTravel=True;
	NewPickup.NetPriority=1.4;
	NewPickup.bClientAnim=true;
	NewPickup.Velocity = Vector(ControllerOwner.GetViewRotation());
	NewPickup.Velocity = NewPickup.Velocity * ((PawnOwner.Velocity Dot NewPickup.Velocity) + 500) + Vect(0,0,200);
	NewPickup.RespawnTime = 0.0;
	NewPickup.InitDroppedPickupFor(None);
	NewPickup.bAlwaysRelevant = True;
	NewPickup.AdrenalineAmount = 25;
	NewPickup.SetDrawScale(class'AdrenalinePickup'.default.DrawScale * 2);

	ControllerOwner.Adrenaline -= 25;
	if (ControllerOwner.Adrenaline < 0)
		ControllerOwner.Adrenaline = 0;
}

function InitializeSubClasses(Pawn Other)
{
	local int x, sc, numConfigs;
	local bool bGotSC;

	if (!InitializedSubClasses)
	{
		SubClasses.length = class'SubClass'.default.SubClasses.length;
		for (x = 0; x < SubClasses.Length; x++)
		{
			SubClasses[x] = class'SubClass'.default.SubClasses[x];
		}
		SubClassConfigs.length = class'SubClass'.default.SubClassConfigs.length;
		for (x = 0; x < SubClassConfigs.Length; x++)
		{
			bGotSC = false;
			for (sc = 0; sc < SubClasses.Length; sc++)
			{
				if (SubClasses[sc] == class'SubClass'.default.SubClassConfigs[x].AvailableSubClass)
					bGotSC = true;
			}
			if (!bGotSC)
				Warn("Invalid SubClass in configuration. SubClass:" $ class'SubClass'.default.SubClassConfigs[x].AvailableSubClass @ "Class:" $ class'SubClass'.default.SubClassConfigs[x].AvailableClass);
			SubClassConfigs[x].AvailableClass = class'SubClass'.default.SubClassConfigs[x].AvailableClass;
			SubClassConfigs[x].AvailableSubClass = class'SubClass'.default.SubClassConfigs[x].AvailableSubClass;
			SubClassConfigs[x].MinLevel = class'SubClass'.default.SubClassConfigs[x].MinLevel;
		}
		AbilityConfigs.length = 0;
		numConfigs = 0;
		for (x = 0; x < class'SubClass'.default.AbilityConfigs.Length; x++)
		{
			for (sc = 0; sc < SubClasses.Length; sc++)
			{
				AbilityConfigs.length = numConfigs+1;
				AbilityConfigs[numConfigs].SubClassIndex = sc;
				AbilityConfigs[numConfigs].AvailableAbility = class'SubClass'.default.AbilityConfigs[x].AvailableAbility;
				if (class'SubClass'.default.AbilityConfigs[x].MaxLevels.length > sc)
					AbilityConfigs[numConfigs].MaxLevel = class'SubClass'.default.AbilityConfigs[x].MaxLevels[sc];
				else
					AbilityConfigs[numConfigs].MaxLevel = 0;
				numConfigs++;
			}
		}

		InitializedAbilities = true;

		for (x = 0; x < SubClasses.Length; x++)
		{
			ClientReceiveSubClass(x, SubClasses[x]);
		}
		for (x = 0; x < SubClassConfigs.Length; x++)
		{
			if (SubClassConfigs[x].AvailableClass != None)
				ClientReceiveSubClasses(x, SubClassConfigs[x].AvailableClass, SubClassConfigs[x].AvailableSubClass, SubClassConfigs[x].Minlevel);
			else
				ClientReceiveSubClasses(x, None, "", 0);
		}

		ClientSetSubClassSizes(SubClasses.Length,SubClassConfigs.Length,0);
		InitializedSubClasses = True;
	}

	if (Other != None && Other.Controller != None && Other.Controller.IsA('PlayerController'))
	{
		if (!ValidateSubClassData(RPGStatsInv(Other.FindInventoryType(class'RPGStatsInv'))))
			ClientDoReconnect();
	}
	else
		Log("+++++++ GI ValidateSubClassData cannot be called. Other:" $ Other @ "Controller:" $ other.Controller);
}

simulated function ClientDoReconnect()
{
	local Player Ply;
	local PlayerController PlyC;

	if (Level.NetMode == NM_Client)
	{
		if (Player != None)
			Ply = Player;
		else
		{
			PlyC = Level.GetLocalPlayerController();
			if (PlyC != None)
				Ply = PlyC.Player;
		}
		Log("Forcing reconnect of player due to invalid SubClass configuration");
		if (Ply != None && Ply.GUIController != None)
			Ply.GUIController.ViewportOwner.Console.DelayedConsoleCommand("Reconnect");
		else
			Log("++++++++ GI Could not do ClientDoReconnect - Player None or GUIController None. Player:" $ Ply);
	}
}

simulated function ClientReceiveSubClass(int index, string thisSubClass)
{
	if (Level.NetMode == NM_Client)
	{
		if (index >= 0)
		{
			if (index+1 > SubClasses.Length)
				SubClasses.Length = index+1;
			SubClasses[index] = thisSubClass;
		}
	}
}

simulated function ClientReceiveSubClasses(int index, class<RPGClass> AvailableClass, string AvailableSubClass, int MinLevel)
{
	if (Level.NetMode == NM_Client)
	{
		if (index >= 0)
		{
			if (index+1 > SubClassConfigs.Length)
				SubClassConfigs.Length = index+1;
			SubClassConfigs[index].AvailableClass = AvailableClass;
			SubClassConfigs[index].AvailableSubClass = AvailableSubClass;
			SubClassConfigs[index].MinLevel = MinLevel;
		}
	}
}

simulated function ClientReceiveSubClassAbilities(int index, int SubClassIndex, class<RPGAbility> AvailableAbility, int MaxLevel)
{
	if (Level.NetMode == NM_Client)
	{
		if (index >= 0)
		{
			if (index+1 > AbilityConfigs.Length)
				AbilityConfigs.Length = index+1;
			AbilityConfigs[index].SubClassIndex = SubClassIndex;
			AbilityConfigs[index].AvailableAbility = AvailableAbility;
			AbilityConfigs[index].MaxLevel = MaxLevel;
		}
	}
}

simulated function ClientSetSubClassSizes(int SubClassesLen,int SubClassConfigsLen,int AbilitiesLen)
{
	if (Level.NetMode == NM_Client)
	{
		if (SubClassesLen >= 0 && SubClassesLen < SubClasses.Length)
			SubClasses.Length = SubClassesLen;

		if (SubClassConfigsLen >= 0 && SubClassConfigsLen < SubClassConfigs.Length)
			SubClassConfigs.Length = SubClassConfigsLen;

		if (AbilitiesLen >= 0 && AbilitiesLen < AbilityConfigs.Length)
			AbilityConfigs.Length = AbilitiesLen;
		InitializedSubClasses = True;
		if (AbilitiesLen > 0)
			InitializedAbilities = True;
		else
			InitializedAbilities = False;
	}
}


simulated function int MaxCanBuy(int SubClassIndex, class<RPGAbility> RequestedAbility)
{
	local int x, MaxL, CountForSubClass;

	MaxL = RequestedAbility.default.MaxLevel;
	
	CountForSubClass = 0;
	for (x = 0; x < AbilityConfigs.length; x++)
		if (AbilityConfigs[x].SubClassIndex == SubClassIndex)
		{
			CountForSubClass++;
			if (AbilityConfigs[x].AvailableAbility == RequestedAbility)
				MaxL = AbilityConfigs[x].MaxLevel;
		}

	if (CountForSubClass == 0)
		return 0;

	return MaxL;
}

function bool ValidateSubClassData(RPGStatsInv StatsInv)
{
	local class<RPGClass> curClass;
	local string curSubClass;
	local int x, y, curSubClasslevel;
	local bool bGotSubClass, bUpdatedAbility;
	local string locPlayerName;

	locPlayerName = "<unknown>";
	if (Owner == None)
	{
		Log("++++++++++ GI ValidateSubClassData problem Owner None");
		return false;
	}
	else if (Controller(Owner) == None)
	{
		Log("++++++++++ GI ValidateSubClassData problem Controller(Owner) None. Owner:" @ Owner);
		return false;
	}
	else if (Controller(Owner).Pawn == None)
	{
		Log("++++++++++ GI ValidateSubClassData problem Controller(Owner).Pawn None");
		return false;
	}
	else if (Controller(Owner).Pawn.PlayerReplicationInfo == None)
	{
		Log("++++++++++ GI ValidateSubClassData problem Controller(Owner).Pawn.PlayerReplicationInfo None");
		return false;
	}
	else
		locPlayerName = Controller(Owner).Pawn.PlayerReplicationInfo.PlayerName;

	if (StatsInv == None || StatsInv.RPGMut == None || StatsInv.DataObject.Abilities.length == 0)
	{
		if (StatsInv == None)
		{
			Log("++++++++++ GI ValidateSubClassData problem player" @ locPlayerName @ "couldnt process. StatsInv:" $ StatsInv);
			return false;
		}

		if (StatsInv.RPGMut == None)
			if (Level.Game != None)
				StatsInv.RPGMut = class'MutFPS'.static.GetRPGMutator(Level.Game);
		if (StatsInv.RPGMut == None)
		{
			Log("++++++++++ GI ValidateSubClassData problem player" @ locPlayerName @ "couldnt process. StatsInv.RPGMut none");
			return false;
		}

		if (StatsInv.DataObject.Abilities.length == 0)
			return true;
	}
	
	curClass = None;
	curSubClass = "";
	curSubClassLevel = 0;
	for (y = 0; y < StatsInv.DataObject.Abilities.length; y++)
	{
		if (ClassIsChildOf(StatsInv.DataObject.Abilities[y], class'RPGClass'))
		{
			if (curClass == None)
				curClass = class<RPGClass>(StatsInv.DataObject.Abilities[y]);
			else
			{
				Log("GiveItemsInv ValidateSubClassData problem player" @ locPlayerName @ "multiple classes. Got:" $ curClass @ "selling:" $ StatsInv.DataObject.Abilities[y]);
				ServerSellAbility(StatsInv,y);
				return false;
			}
		}
		else if (ClassIsChildOf(StatsInv.DataObject.Abilities[y], class'SubClass'))
		{
			if (curSubClassLevel > 0)
			{
				Log("GiveItemsInv ValidateSubClassData problem player" @ locPlayerName @ "multiple subclasses");
				ServerSellData(None, StatsInv);
				return false;
			}
			curSubClassLevel = StatsInv.DataObject.AbilityLevels[y];
			if (curSubClassLevel < class'SubClass'.default.SubClasses.length)
				curSubClass = class'SubClass'.default.SubClasses[curSubClassLevel];
			else
			{
				Log("GiveItemsInv ValidateSubClassData problem player" @ locPlayerName @ "subclass out of range");
				ServerSellData(None, StatsInv);
				return false;
			}
		}
	}

	if (curSubClass != "" && curClass != None && curSubClass != curClass.default.AbilityName)
	{
		bGotSubClass = false;
		for (y = 0; y < class'SubClass'.default.SubClassConfigs.length; y++)
		{
			if (class'SubClass'.default.SubClassConfigs[y].AvailableClass == curClass && class'SubClass'.default.SubClassConfigs[y].AvailableSubClass == curSubClass && class'SubClass'.default.SubClassConfigs[y].MinLevel <= StatsInv.DataObject.Level)
				bGotSubClass = true;
		}
		if (!bGotSubClass)
		{
			Log("GiveItemsInv ValidateSubClassData problem player" @ locPlayerName @ "subclass:" $ curSubClass @ "not found for class");
			ServerSellData(None, StatsInv);
			return false;
		}
	}
	
	if (curSubClass == "")
	{
		if (curclass != None) 
			curSubClass = curClass.default.AbilityName;
		else
			curSubClass = "None";

		for (y = 0; y < class'SubClass'.default.SubClasses.length; y++)
			if (class'SubClass'.default.SubClasses[y] == curSubClass)
				curSubClassLevel = y;
	}

	bUpdatedAbility = false;
	for (x = 0; x < StatsInv.DataObject.Abilities.length; x++)
	{
		if (!ClassIsChildOf(StatsInv.DataObject.Abilities[x], class'SubClass') && !ClassIsChildOf(StatsInv.DataObject.Abilities[x], class'RPGClass'))
		{
			for (y = 0; y < class'SubClass'.default.AbilityConfigs.length; y++)
			{
				if (class'SubClass'.default.AbilityConfigs[y].AvailableAbility == StatsInv.DataObject.Abilities[x])
				{
					if (class'SubClass'.default.AbilityConfigs[y].MaxLevels.length <= curSubClassLevel || class'SubClass'.default.AbilityConfigs[y].MaxLevels[curSubClassLevel] < StatsInv.DataObject.AbilityLevels[x])
					{
						if (class'SubClass'.default.AbilityConfigs[y].MaxLevels.length > curSubClassLevel && class'SubClass'.default.AbilityConfigs[y].MaxLevels[curSubClassLevel] > 0)
						{
							Log("GiveItemsInv ValidateSubClassData problem player" @ locPlayerName @ "subclass:" $ curSubClass @ "ability:" $ StatsInv.DataObject.Abilities[x] @ "level:" $ StatsInv.DataObject.AbilityLevels[x] @ "too high, max now:" $ class'SubClass'.default.AbilityConfigs[y].MaxLevels[curSubClassLevel]);
							StatsInv.DataObject.AbilityLevels[x] = class'SubClass'.default.AbilityConfigs[y].MaxLevels[curSubClassLevel];
						}
						else
						{
							Log("GiveItemsInv ValidateSubClassData problem player" @ locPlayerName @ "subclass:" $ curSubClass @ "ability:" $ StatsInv.DataObject.Abilities[x] @ "not available for subclass");
							StatsInv.DataObject.Abilities.Remove(x, 1); 
							StatsInv.DataObject.AbilityLevels.Remove(x, 1);
							x--; 
						}
						bUpdatedAbility = true;;
					}
					break;
				}
			}
		}

		if (x >= 0)
		{ 
			if (ClassIsChildOf(StatsInv.DataObject.Abilities[x], class'AbilityAwareness'))
				AwarenessLevel = StatsInv.DataObject.AbilityLevels[x];
			else if (ClassIsChildOf(StatsInv.DataObject.Abilities[x], class'AbilityMedicAwareness'))
				MedicAwarenessLevel = StatsInv.DataObject.AbilityLevels[x];
			else if (ClassIsChildOf(StatsInv.DataObject.Abilities[x], class'AbilityEngineerAwareness'))
				EngAwarenessLevel = StatsInv.DataObject.AbilityLevels[x];
		}
	}
	
	if (bUpdatedAbility)
	{
		StatsInv.DataObject.SaveConfig();

		StatsInv.DataObject.CreateDataStruct(StatsInv.Data, false);
		if (StatsInv.RPGMut != None)
		{
			StatsInv.RPGMut.ValidateData(StatsInv.DataObject);
			StatsInv.DataObject.CreateDataStruct(StatsInv.Data, false);
		}

		return false;
	}

	return true;
}

function ServerSetSubClass(RPGStatsInv StatsInv, int SubClassLevel)
{
	local int x, spaceindex;
	local MutFPSHud HUDMut;
	local Mutator m;
	local string tmpstr;

	if (StatsInv == None || StatsInv.RPGMut == None || StatsInv.DataObject.Abilities.length == 0)
		return;

	for (x = 0; x < StatsInv.DataObject.Abilities.length; x++)
	{
		if (ClassIsChildOf(StatsInv.DataObject.Abilities[x], class'SubClass'))
		{
			StatsInv.DataObject.AbilityLevels[x] = SubClassLevel;
			StatsInv.Data.AbilityLevels[x] = SubClassLevel;
			
			ClientSetSubClass(SubClassLevel);
			break;
		}
	}

	for (m = Level.Game.BaseMutator; m != None; m = m.NextMutator)
	{
		if (MutFPSHud(m) != None)
		{
			HUDMut = MutFPSHud(m);
			break;
		}
	}
	if (HUDMut != None && Instigator != None && Instigator.PlayerReplicationInfo != None)
	{
		for (x = 0; x < HUDMut.InitialXPs.Length; x++)
		{
			if (HUDMut.InitialXPs[x].PlayerName == Instigator.PlayerReplicationInfo.PlayerName)
			{
    				tmpstr = class'SubClass'.default.SubClasses[SubClassLevel];

    				spaceindex = Instr(tmpstr," ");
    				if (spaceindex > 0)
           				HUDMut.InitialXPs[x].SubClass = Left (tmpstr, spaceindex);
           			else
           				HUDMut.InitialXPs[x].SubClass = tmpstr;
           			break;
			}
		}
	}
}

simulated function ClientSetSubClass(int SubClassLevel)
{
	local int x;

	if (Level.NetMode == NM_Client)
	{
		if (ClientStatsInv == None)
		{
			return;
		}
		for (x = 0; x < ClientStatsInv.Data.Abilities.length; x++)
		{
			if (ClassIsChildOf(ClientStatsInv.Data.Abilities[x], class'SubClass'))
			{
				ClientStatsInv.Data.AbilityLevels[x] = SubClassLevel;
				x = ClientStatsInv.Data.Abilities.length;
			}
		}
	
		if (ClientStatsInv.StatsMenu != None)
		{
			if (RPGStatsMenuX(ClientStatsInv.StatsMenu) != None)
			{
				if (RPGStatsMenuX(ClientStatsInv.StatsMenu).GiveItems != None)
					RPGStatsMenuX(ClientStatsInv.StatsMenu).InitFor(ClientStatsInv);
				else
					RPGStatsMenuX(ClientStatsInv.StatsMenu).InitFor2(ClientStatsInv, self);
			}
		}
		else
		{
			if (Player != None && Player.GUIController != None)
			{
				Player.GUIController.OpenMenu(string(class'RPGStatsMenuX'));
				RPGStatsMenuX(GUIController(Player.GUIController).TopPage()).InitFor2(ClientStatsInv,self);
			}
		}
	}	
}

function ServerGetAbilities(int SubClassIndex)
{
	local int x, NumAbilities;

	NumAbilities = 0;
	for (x = 0; x < AbilityConfigs.Length; x++)
	{
		if (SubClassIndex == AbilityConfigs[x].SubClassIndex && !ClassIsChildOf(AbilityConfigs[x].AvailableAbility, class'BotAbility'))
		{
			ClientReceiveSubClassAbilities(NumAbilities, AbilityConfigs[x].SubClassIndex, AbilityConfigs[x].AvailableAbility, AbilityConfigs[x].MaxLevel);
			NumAbilities++;
		}
	}
	ClientSetSubClassSizes(SubClasses.Length,SubClassConfigs.Length,NumAbilities);
}

function ServerSellAbility(RPGStatsInv StatsInv, int AbilityNo)
{
	local int x;

	if (StatsInv == None || StatsInv.RPGMut == None || Level.Game.bGameRestarted || StatsInv.DataObject.Abilities.length < AbilityNo)
		return;

	StatsInv.DataObject.Abilities.Remove(AbilityNo, 1); 
	StatsInv.DataObject.AbilityLevels.Remove(AbilityNo, 1);

	StatsInv.Data.Abilities.length = 0;
	StatsInv.Data.AbilityLevels.length = 0;
	for (x = 0; x < StatsInv.DataObject.Abilities.length; x++)
	{
		StatsInv.Data.Abilities[x] = StatsInv.DataObject.Abilities[x];
		StatsInv.Data.AbilityLevels[x] = StatsInv.DataObject.AbilityLevels[x];
	}

	ServerSellData(None, StatsInv);
}

function ServerSellData(PlayerReplicationInfo PRI, RPGStatsInv StatsInv)
{
	local int x;

	if (StatsInv == None || StatsInv.RPGMut == None || Level.Game.bGameRestarted || StatsInv.DataObject.Abilities.length == 0)
		return;

	for (x = 0; x < StatsInv.DataObject.Abilities.length; x++)
	{
		if (!ClassIsChildOf(StatsInv.DataObject.Abilities[x], class'RPGClass'))
		{
			StatsInv.DataObject.Abilities.Remove(x, 1); 
			StatsInv.DataObject.AbilityLevels.Remove(x, 1);
			x--; 
		}
	}

	StatsInv.Data.Abilities.length = 0;
	StatsInv.Data.AbilityLevels.length = 0;
	for (x = 0; x < StatsInv.DataObject.Abilities.length; x++)
	{
		StatsInv.Data.Abilities[x] = StatsInv.DataObject.Abilities[x];
		StatsInv.Data.AbilityLevels[x] = StatsInv.DataObject.AbilityLevels[x];
	}

	StatsInv.DataObject.PointsAvailable = -30;
	StatsInv.Data.PointsAvailable = -30;

	if (Instigator != None && Instigator.Health > 0)
	{
		Level.Game.SetPlayerDefaults(Instigator);
		OwnerEvent('ChangedWeapon');
		Timer();
	}

	ClientRemoveAbilities(StatsInv);
	for (x = 0; x < StatsInv.DataObject.Abilities.length; x++)
		ClientRemainingAbility(x, StatsInv.Data.Abilities[x], StatsInv.Data.AbilityLevels[x], StatsInv);
}

simulated function ClientRemoveAbilities(RPGStatsInv thisStatsInv)
{
	if (Level.NetMode == NM_Client)
	{
		thisStatsInv.Data.Abilities.length = 0;
		thisStatsInv.Data.AbilityLevels.length = 0;
		thisStatsInv.Data.PointsAvailable = -30;

		AbilityConfigs.Length = 0;	
		InitializedAbilities = False;
	}	
}

simulated function ClientRemainingAbility(int x, class<RPGAbility> thisAbility, int thisLevel, RPGStatsInv thisStatsInv)
{
	if (Level.NetMode == NM_Client)
	{
		thisStatsInv.Data.Abilities[x] = thisAbility;
		thisStatsInv.Data.AbilityLevels[x] = thisLevel;
	}	
}

defaultproperties
{
     bOnlyRelevantToOwner=False
     bAlwaysRelevant=True
}
