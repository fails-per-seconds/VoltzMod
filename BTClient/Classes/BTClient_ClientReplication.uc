class BTClient_ClientReplication extends LinkedReplicationInfo;

struct sAchievementState
{
	var string Title;
	var string Description;
	var string Icon;
	var int Progress;
	var int Count;
	var int Points;
	var bool bEarned;
	var string CatId;
	var Color EffectColor;
};
var(DEBUG) array<sAchievementState> AchievementsStates;
var sAchievementState LastAchievementEvent;

struct sTrophyClient
{
	var string Title;
};
var(DEBUG) array<sTrophyClient> Trophies;
var sTrophyClient LastTrophyEvent;

struct sStoreItemClient
{
	var string Name;
	var string ID;
	var int Cost;
	var byte Access;
	var string Desc;
	var Material IconTexture;
	var transient bool bSync;
	var transient bool bHasMeta;
};
var(DEBUG) array<sStoreItemClient> Items;

struct sCategoryClient
{
	var string Name;
	var array<sStoreItemClient> CachedItems;
};
var(DEBUG) array<sCategoryClient> Categories;
var(DEBUG) bool bReceivedCategories;

struct sPlayerItemClient
{
	var string Name;
	var string ID;
	var string ItemClass;
	var bool bEnabled;
	var byte Access;
	var string Desc;
	var Material IconTexture;
	var byte Rarity;
	var byte Count;
};
var(DEBUG) array<sPlayerItemClient> PlayerItems;

var(DEBUG) array<struct sAchievementCategory
{
	var string Name;
	var string Id;
	var string ParentId;
}> AchievementCategories;
var(DEBUG) bool bReceivedAchievementCategories;

var bool bAllowDodgePerk;

var(DEBUG) transient bool bItemsTransferComplete;
var(DEBUG) array<string> Text;

var int PlayerId;
var int Rank, SoloRank;
var(DEBUG) string Title;

var Pawn myPawn;
var Pawn LastPawn;
var private Pawn DeadPawn;

var float JoinServerTime;
var float InitServerSpawnTime;
var float LastSpawnTime;
var float PersonalTime;
var transient string SFMSG;

var int BTLevel;
var int BTPoints;
var int APoints;
var int BTWage;
var bool bIsPremiumMember;

var Color PreferedColor;

var float BTExperience;
var float LastObjectiveCompletedTime;
var float LastDropChanceTime;
var float LastRenderedBTExperience;
var float LastRenderedBTLevel;
var float BTExperienceChangeTime;
var float BTExperienceDiff;

var float ClientMatchStartTime;

const CFCHECKPOINT = 0x00000004;

var private int ClientFlags;

var Pawn ProhibitedCappingPawn;
var Pawn ClientSpawnPawn;

var int EventTeamIndex;

var BTClient_LevelReplication PlayingLevel;
var byte SpawnPing;

var BTClient_Config Options;
var bool bNetNotified;

var int myPlayerSlot;
var bool bReceivedRankings;
var bool bAutoPress;
var bool bPermitBoosting;
var bool bWantsToWage;
var int AmountToWage;
var transient float LastFlexTime;

var BTClient_MutatorReplicationInfo MRI;
var BTGUI_PlayerRankingsReplicationInfo Rankings[3];
var BTGUI_RecordRankingsReplicationInfo RecordsPRI;

var string ClientMessage;

replication
{
	reliable if (Role == ROLE_Authority)
		myPawn, ClientSpawnPawn, PersonalTime, Rank, ClientFlags, SoloRank,
		BTLevel, BTExperience, BTPoints, APoints, BTWage, PreferedColor,
		bIsPremiumMember, Title, EventTeamIndex, SpawnPing, PlayingLevel;

	reliable if (bNetOwner && Role == ROLE_Authority)
		bAllowDodgePerk, ProhibitedCappingPawn, JoinServerTime, PlayerId;

	reliable if (!bNetOwner && bNetInitial && Role == ROLE_Authority)
		InitServerSpawnTime;

	reliable if (Role == ROLE_Authority)
		ClientSpawned, ClientMatchStarting,
		ClientSendAchievementState, ClientAchievementAccomplished, ClientAchievementProgressed, ClientCleanAchievements,
		ClientSendTrophy, ClientTrophyEarned, ClientCleanTrophies,
		ClientSendItem, ClientSendStoreCategory, ClientSendAchievementCategory,
		ClientSendItemsCompleted, ClientSendItemMeta,
		ClientSendPlayerItem, ClientNotifyItemUpdated, ClientNotifyItemRemoved;

	reliable if (Role == ROLE_Authority)
		ClientSendText, ClientCleanText, ClientSendMessage, ClientSendConsoleMessage;

	unreliable if (Role < ROLE_Authority)
		ServerSetClientFlags;

	reliable if (Role < ROLE_Authority)
		ServerSetPreferedColor, ServerRequestAchievementCategories, ServerRequestAchievementsByCategory,
		ServerRequestPlayerItems, ServerRequestPlayerRanks, ServerRequestRecordRanks, ServerPerformQuery;
}

static function BTClient_ClientReplication GetCRI( PlayerReplicationInfo PRI )
{
	local LinkedReplicationInfo LRI;

	for(LRI = PRI.CustomReplicationInfo; LRI != none; LRI = LRI.NextReplicationInfo)
	{
		if (BTClient_ClientReplication(LRI) != none)
			return BTClient_ClientReplication(LRI);
	}
	return none;
}

// Server hooks
delegate OnRequestAchievementCategories( PlayerController requester, BTClient_ClientReplication CRI );
delegate OnRequestAchievementsByCategory( PlayerController requester, BTClient_ClientReplication CRI, string catID );

delegate OnRequestPlayerItems( PlayerController requester, BTClient_ClientReplication CRI, string filter );

// UI hooks
delegate OnClientNotify( string message, byte ranksId );

delegate OnAchievementStateReceived( int index );
delegate OnAchievementCategoryReceived( int index );

delegate OnPlayerItemReceived( int index );
delegate OnPlayerItemRemoved( int index );
delegate OnPlayerItemUpdated( int index );

simulated event PostBeginPlay()
{
	Super.PostBeginPlay();
	if (Level.NetMode != NM_DedicatedServer)
		if (Role == ROLE_Authority && Level.GetLocalPlayerController() == Owner)
			InitializeClient();
}

simulated event PostNetBeginPlay()
{
	Super.PostNetBeginPlay();
	if (Role == ROLE_Authority)
	{
		JoinServerTime = Level.TimeSeconds;
	}
	else if (Role < ROLE_Authority)
	{
		if (bNetOwner)
			InitializeClient();
	}
}

simulated event PostNetReceive()
{
	local BTClient_ClientReplication CRI;
	local PlayerController localPC;

	Super.PostNetReceive();
	if (!bNetOwner)
	{
		if (myPawn != none && myPawn != DeadPawn)
		{
			if (myPawn != ClientSpawnPawn)
				ClientSpawned();

			DeadPawn = myPawn;
		}

		if (!bNetNotified)
		{
			localPC = Level.GetLocalPlayerController();
			if (localPC.PlayerReplicationInfo != none)
			{
				CRI = GetRep(Level.GetLocalPlayerController());
				if (CRI != none)
				{
					LastSpawnTime = (InitServerSpawnTime - CRI.JoinServerTime);
					bNetNotified = true;
				}
			}
		}
	}
	else
	{
		if (Options != none && Options.bAutoBehindView)
			Level.GetLocalPlayerController().BehindView(true);
	}
}

simulated function InitializeClient( optional BTClient_Interaction myInter )
{
	Options = class'BTClient_Config'.static.FindSavedData();
	if (Options == none)
		Log("BTClient_Config not found!", Name);

	ServerSetPreferedColor(Options.PreferedColor);
}

function bool SetActiveLevel( BTClient_LevelReplication myLevel )
{
	local Pawn p;

	if (!MRI.OnPlayerChangeLevel(Controller(Owner), self, myLevel))
		return false;

	PlayingLevel = myLevel;
	NetUpdateTime = Level.TimeSeconds - 1;

	p = Controller(Owner).Pawn;
	Level.Game.RestartPlayer(Controller(Owner));
	Controller(Owner).PawnDied(p);
	if (p != none)
		p.Destroy();

	return true;
}

private function ServerSetClientFlags( int newFlags, bool bAdd )
{
	SetClientFlags(newFlags, bAdd);
}

function ServerSetPreferedColor( Color newPreferedColor )
{
	PreferedColor = newPreferedColor;
}

simulated function bool HasClientFlags( int flags )
{
	return (ClientFlags & flags) != 0;
}

function SetClientFlags( int newFlags, bool bAdd )
{
	if (bAdd)
		ClientFlags = ClientFlags | newFlags;
	else
		ClientFlags = ClientFlags & ~newFlags;
}

simulated function ClientSendMessage( class<BTClient_LocalMessage> messageClass, string message, optional byte switch, optional PlayerReplicationInfo PRI2)
{
	ClientMessage = message;
	PlayerController(Owner).ReceiveLocalizedMessage(messageClass, int(switch), PlayerController(Owner).PlayerReplicationInfo, PRI2, self);
}

final function float GetPingCompensationInTime()
{
	return FMin(SpawnPing*4, 80.0)/1000.0;
}

function PlayerSpawned()
{
	LastSpawnTime = Level.TimeSeconds + GetPingCompensationInTime();

	InitServerSpawnTime = LastSpawnTime;
	ClientSpawned();
}

function ClientSetPersonalTime( float CPT )
{
	PersonalTime = CPT;
}

simulated function ClientSpawned()
{
	LastSpawnTime = Level.TimeSeconds + GetPingCompensationInTime();
}

simulated function ClientSendConsoleMessage( coerce string Msg )
{
	PlayerController(Owner).Player.Console.Message(Msg, 1.0);
}

simulated function ClientSendText( string Packet )
{
	Text[Text.Length] = Packet;
}

simulated function ClientCleanText()
{
	Text.Length = 0;
}

simulated function ClientMatchStarting( float serverTime )
{
	ClientMatchStartTime = serverTime - Level.TimeSeconds;
}

final function ServerRequestAchievementCategories()
{
	OnRequestAchievementCategories(PlayerController(Owner), self);
}

final function ServerRequestAchievementsByCategory( string catID )
{
	OnRequestAchievementsByCategory(PlayerController(Owner), self, catID);
}

final function ServerRequestPlayerRanks( int pageIndex, optional byte ranksId )
{
	MRI.OnRequestPlayerRanks(PlayerController(Owner), self, pageIndex, ranksId);
}

final function ServerRequestRecordRanks( int pageIndex, optional string query )
{
	MRI.OnRequestRecordRanks(PlayerController(Owner), self, pageIndex, Level.Game.StripColor(query));
}

simulated final function ClientSendAchievementState( string title, string description, string icon, int progress, int count, int points, optional Color effectColor )
{
	local int i;

	i = AchievementsStates.Length;
	AchievementsStates.Length = i + 1;
	AchievementsStates[i].Title = title;
	AchievementsStates[i].Description = description;
	AchievementsStates[i].Icon = icon;
	AchievementsStates[i].Progress = progress;
	AchievementsStates[i].Count = count;
	AchievementsStates[i].Points = points;
	AchievementsStates[i].bEarned = progress == -1 || (count > 0 && progress >= count);
	if (effectColor.A == 0)
	{
		effectColor.A = 255;
		effectColor.R = 0;
		effectColor.G = 255;
		effectColor.B = 0;
	}
	AchievementsStates[i].EffectColor = effectColor;
	OnAchievementStateReceived(i);
}

simulated final function ClientSendAchievementCategory( sAchievementCategory cat )
{
	local int i;

	i = AchievementCategories.Length;
	AchievementCategories.Length = i + 1;
	AchievementCategories[i] = cat;
	OnAchievementCategoryReceived(i);
}

final function ServerRequestPlayerItems( optional string filter )
{
	OnRequestPlayerItems( PlayerController(Owner), self, filter );
}

simulated final function ClientSendPlayerItem( sPlayerItemClient item )
{
	local int i;

	i = PlayerItems.Length;
	PlayerItems.Length = i + 1;
	PlayerItems[i] = item;
	OnPlayerItemReceived(i);
}

simulated function ClientNotifyItemRemoved( string id )
{
	local int i;

	for(i = 0; i < PlayerItems.Length; ++i)
	{
		if (PlayerItems[i].Id == id)
		{
			OnPlayerItemRemoved(i);
			PlayerItems.Remove(i, 1);
			break;
		}
	}
}

simulated function ClientNotifyItemUpdated( string id, bool bEnabled, byte newCount )
{
	local int i;

	for(i = 0; i < PlayerItems.Length; ++i)
	{
		if (PlayerItems[i].Id == id)
		{
			PlayerItems[i].bEnabled = bEnabled;
			PlayerItems[i].Count = newCount;
			OnPlayerItemUpdated(i);
			break;
		}
	}
}

simulated final function ClientSendTrophy( string title )
{
	Trophies.Insert(0, 1);
	Trophies[0].Title = title;
}

simulated final function ClientTrophyEarned( string title )
{
	LastTrophyEvent.Title = title;

	PlayerController(Owner).ReceiveLocalizedMessage(Class'BTUI_TrophyState', 0,,, self);
	if (PlayerController(Owner).ViewTarget != none)
		PlayerController(Owner).ViewTarget.PlayOwnedSound(Options.TrophySound, SLOT_Interface, 255, True);
}

simulated final function ClientCleanTrophies()
{
	Trophies.Length = 0;
}

simulated final function ClientAchievementProgressed( string title, string icon, int progress, int count )
{
	if (progress % Max(Round(count * 0.10), 1) == 0)
	{
		LastAchievementEvent.Title = title;
		LastAchievementEvent.Icon = icon;
		LastAchievementEvent.Progress = progress;
		LastAchievementEvent.Count = count;

		PlayerController(Owner).ReceiveLocalizedMessage(class'BTUI_AchievementState', 0,,, self);

		if (PlayerController(Owner).ViewTarget != none)
			PlayerController(Owner).ViewTarget.PlayOwnedSound(Options.AchievementSound, SLOT_Interface, 255, true);
	}

	ClientSendConsoleMessage("You have made progress on the achievement" @ title);
}

simulated final function ClientAchievementAccomplished( string title, optional string icon )
{
	LastAchievementEvent.Title = title;
	LastAchievementEvent.Icon = icon;

	PlayerController(Owner).ReceiveLocalizedMessage(class'BTUI_AchievementState', 0,,, self);

	if (PlayerController(Owner).ViewTarget != none)
		PlayerController(Owner).ViewTarget.PlayOwnedSound(Options.AchievementSound, SLOT_Interface, 255, true);

	ClientSendConsoleMessage("You accomplished the achievement" @ title);
}

simulated final function ClientCleanAchievements()
{
	AchievementsStates.Length = 0;
}

final static function int CompressStoreData( int cost, byte access )
{
	local int data;

	data = cost & 0x0000FFFF;
	data = data | (access << 24);
	return data;
}

final static function DecompressStoreData( int data, out int price, out byte access )
{
	local int acc;

	acc = data & 0x0F000000;
	access = acc >> 24;

	price = data & 0x0000FFFF;
}

simulated final function ClientSendItem( string itemName, string id, int data )
{
	local byte access;
	local int cost;

	Items.Insert(0, 1);
	DecompressStoreData(data, cost, access);

	Items[0].Name = itemName;
	Items[0].ID = id;
	Items[0].Cost = cost;
	Items[0].Access = access;
}

simulated final function ClientSendItemMeta( string id, string desc, Material iconMat )
{
	local int i;

	for(i = 0; i < Items.Length; ++i)
	{
		if (Items[i].id == id)
		{
			Items[i].IconTexture = iconMat;
			Items[i].Desc = desc;
			Items[i].bSync = true;
			Items[i].bHasMeta = true;
			break;
		}
	}
}

simulated final function ClientSendStoreCategory( string categoryName )
{
	Categories.Insert(0, 1);
	Categories[0].Name = categoryName;
}

simulated final function ClientSendItemsCompleted()
{
	bItemsTransferComplete = true;
}

simulated function ServerToggleItem( string id )
{
	PlayerController(Owner).ConsoleCommand("Store ToggleItem" @ id);
}

simulated function ServerBuyItem( string id )
{
	PlayerController(Owner).ConsoleCommand("Store BuyItem" @ id);
}

simulated function ServerSellItem( string id )
{
	PlayerController(Owner).ConsoleCommand("Store SellItem" @ id);
}

simulated function ServerDestroyItem( string id )
{
	PlayerController(Owner).ConsoleCommand("Store DestroyItem" @ id);
}

simulated function ServerPerformQuery( string query )
{
	MRI.OnServerQuery(PlayerController(Owner), self, query);
}

static function BTClient_ClientReplication GetRep( PlayerController PC )
{
	local LinkedReplicationInfo LRI;

	for(LRI = PC.PlayerReplicationInfo.CustomReplicationInfo; LRI != none; LRI = LRI.NextReplicationInfo)
	{
		if (BTClient_ClientReplication(LRI) != none)
			return BTClient_ClientReplication(LRI);
	}
	return none;
}

event Tick( float deltaTime )
{
	local UseObjective objective;

	if (PlayerController(Owner) == none)
	{
		Destroy();
		return;
	}

	if (PlayerController(Owner).Pawn != none && bAutoPress)
	{
		foreach PlayerController(Owner).Pawn.TouchingActors(class'UseObjective', objective)
		{
			if (objective.bDisabled)
				continue;

			PlayerController(Owner).ServerUse();
		}
	}
}

simulated event Destroyed()
{
	local int i;

	Super.Destroyed();
	for(i = 0 ; i < arraycount(Rankings); ++i)
	{
		if (Rankings[i] != none)
			Rankings[i].Destroy();
	}

	if (RecordsPRI != none)
		RecordsPRI.Destroy();
}

defaultproperties
{
     LastObjectiveCompletedTime=-10.000000
     LastDropChanceTime=-60.000000
     EventTeamIndex=-1
     myPlayerSlot=-1
     bSkipActorPropertyReplication=False
     bNetNotify=True
}
