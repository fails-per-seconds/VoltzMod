class BTGUI_RankingsMenu extends BTGUI_ScoreboardBase;

var automated GUITabControl Tabs;
var automated BTGUI_QueryPanel QueryPanel;
var private BTGUI_PlayerRankingsScoreboard PlayersScoreboard;
var private BTGUI_RecordRankingsScoreboard RecordsScoreboard;

event bool NotifyLevelChange()
{
    bPersistent = false;
    // Don't clear on Free() (bug: called on closing)
    PlayersScoreboard = none;
    RecordsScoreboard = none;
    return super.NotifyLevelChange();
}

event InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	super.InitComponent(MyController,MyOwner);

    // To prevent ShowPanel being called before we can assign our scoreboards.
    Tabs.AddTab(
        "Top Players",
        string(class'BTGUI_PlayerRankingsScoreboard'),
        PlayersScoreboard,
        "View the highest ranked players",
        false
    );
    Tabs.AddTab(
        "Top Records",
        string(class'BTGUI_RecordRankingsScoreboard'),
        RecordsScoreboard,
        "View the fastest map records",
        true
    );
}

function ReplicationReady( BTGUI_ScoreboardReplicationInfo repSource )
{
    // Log("ReplicationReady", Name);
    PlayersScoreboard.RepReady( repSource );
    RecordsScoreboard.RepReady( repSource );
}

function PassQueryReceived( BTQueryDataReplicationInfo queryRI )
{
    QueryPanel.OnQueryReceived( queryRi );
}

function InternalOnQueryPlayerRecord( coerce string mapId, coerce string playerId )
{
    local string query;

    if( mapId == "" || playerId == "" )
    {
        Warn("Received request with invalid data!");
        return;
    }

    query = "player:" $ playerId @ "map:" $ mapId;
    QueryPanel.SetQuery( query );
}

function InternalOnQueryPlayer( coerce string playerId )
{
    local string query;

    if( playerId == "" )
    {
        Warn("Received request with invalid data!");
        return;
    }

    query = "player:" $ playerId;
    QueryPanel.SetQuery( query );
}

final static function BTGUI_RankingsMenu GetMenu( PlayerController localPC )
{
    local GUIController myController;

    myController = GUIController(localPC.Player.GUIController);
    return BTGUI_RankingsMenu(myController.FindPersistentMenuByClass( default.Class ));
}

defaultproperties
{
     Begin Object Class=GUITabControl Name=oRankPages
         bDockPanels=True
         TabHeight=0.045000
         WinTop=0.065000
         WinLeft=0.005000
         WinWidth=0.640000
         WinHeight=0.925000
         OnActivate=oRankPages.InternalOnActivate
     End Object
     Tabs=GUITabControl'BTGUI_RankingsMenu.oRankPages'

     Begin Object Class=BTGUI_QueryPanel Name=oQueryPanel
         OnQueryReceived=oQueryPanel.InternalOnQueryReceived
         WinTop=0.065000
         WinLeft=0.650000
         WinWidth=0.345000
         WinHeight=0.925000
     End Object
     QueryPanel=BTGUI_QueryPanel'BTGUI_RankingsMenu.oQueryPanel'

     Begin Object Class=BTGUI_PlayerRankingsScoreboard Name=oPlayersPanel
         OnQueryPlayer=BTGUI_RankingsMenu.InternalOnQueryPlayer
     End Object
     PlayersScoreboard=BTGUI_PlayerRankingsScoreboard'BTGUI_RankingsMenu.oPlayersPanel'

     Begin Object Class=BTGUI_RecordRankingsScoreboard Name=oRecordsPanel
         OnQueryPlayerRecord=BTGUI_RankingsMenu.InternalOnQueryPlayerRecord
         OnQueryPlayer=BTGUI_RankingsMenu.InternalOnQueryPlayer
     End Object
     RecordsScoreboard=BTGUI_RecordRankingsScoreboard'BTGUI_RankingsMenu.oRecordsPanel'

     WindowName="BTimes Leaderboards"
     MinPageWidth=0.800000
     MinPageHeight=0.400000
     FadeTime=1.000000
     bPersistent=True
     bAllowedAsLast=True
     WinTop=0.108500
     WinLeft=0.100000
     WinWidth=0.800000
     WinHeight=0.817000
}
