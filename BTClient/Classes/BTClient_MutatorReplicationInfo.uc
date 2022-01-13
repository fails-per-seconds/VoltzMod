class BTClient_MutatorReplicationInfo extends ReplicationInfo;

var string PlayersBestTimes, EndMsg, PointsReward, Credits, RankingPage;
var float MapBestTime, ObjectiveTotalTime, MatchStartTime;
var bool bSoloMap, bKeyMap, bHasInitialized, bCompetitiveMode;

var Enum ERecordState
{
	RS_Active,
	RS_Succeed,
	RS_Failure,
	RS_QuickStart,
} RecordState;

var BTClient_ClientReplication CR;
var int RecordsCount, MaxRecords, PlayersCount, RankedPlayersCount;
var float TeamTime[2];


var struct sTeam
{
	var string Name;
	var float Points;
	var int Voters;
} Teams[3];

var BTClient_LevelReplication BaseLevel, MapLevel;

replication
{
	reliable if (Role == ROLE_Authority)
		MatchStartTime, ObjectiveTotalTime, RecordState, EndMsg, bCompetitiveMode, Teams;

	reliable if (bNetDirty && EndMsg != "")
		PlayersBestTimes, MapBestTime, PointsReward;

	reliable if (bNetInitial)
		Credits, RankingPage, bSoloMap, bKeyMap, RecordsCount, MaxRecords,
		PlayersCount, RankedPlayersCount, BaseLevel, MapLevel;

	reliable if (bNetDirty && bCompetitiveMode)
		TeamTime;
}

/** Queries the server for the all time, quarterly or daily player ranks. */
delegate OnRequestPlayerRanks(PlayerController requester, BTClient_ClientReplication CRI, int pageIndex, byte ranksId);
delegate OnRequestRecordRanks(PlayerController requester, BTClient_ClientReplication CRI, int pageIndex, string mapName);
delegate OnServerQuery(PlayerController requester, BTClient_ClientReplication CRI, string query);
delegate bool OnPlayerChangeLevel(Controller other, BTClient_ClientReplication CRI, BTClient_LevelReplication myLevel);

final function AddLevelReplication(BTClient_LevelReplication levelRep)
{
	local BTClient_LevelReplication other;

	if (BaseLevel == none)
	{
		BaseLevel = levelRep;
		return;
	}

	other = BaseLevel;
	BaseLevel = levelRep;
	levelRep.NextLevel = other;
}

simulated event PostNetBeginPlay()
{
	Super.PostNetBeginPlay();
	if (Level.NetMode == NM_DedicatedServer)
	{
		return;
	}
	SetTimer(0.5, true);
}

simulated event Timer()
{
	if (!bHasInitialized && Level.GetLocalPlayerController() != none)
		InitializeClient();
}

simulated function InitializeClient()
{
	local PlayerController PC;
	local BTClient_Interaction Inter;
	local LinkedReplicationInfo LRI;

	PC = Level.GetLocalPlayerController();
	if (PC != none && PC.Player != none && PC.PlayerReplicationInfo != none)
	{
		Inter = BTClient_Interaction(PC.Player.InteractionMaster.AddInteraction(string(Class'BTClient_Interaction'), PC.Player));
		Inter.ObjectsInitialized(self);

		if (CR == none)
		{
			for(LRI = PC.PlayerReplicationInfo.CustomReplicationInfo; LRI != none; LRI = LRI.NextReplicationInfo)
			{
				if (BTClient_ClientReplication(LRI) != none)
				{
					CR = BTClient_ClientReplication(LRI);
					CR.MRI = self;
					break;
				}
			}
		}
		bHasInitialized = true;
		SetTimer(0, false);
	}
}

function Reset()
{
	RecordState = RS_Active;
}

final simulated function Color GetFadingColor( Color FadingColor )
{
	local float pulse;

	pulse = 1.0 - (Level.TimeSeconds % 1.0);
	return FadingColor * (1.0 - pulse) + class'HUD'.default.WhiteColor * pulse;
}

defaultproperties
{
     NetUpdateFrequency=2.000000
}
