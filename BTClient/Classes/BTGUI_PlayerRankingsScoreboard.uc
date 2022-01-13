class BTGUI_PlayerRankingsScoreboard extends BTGUI_RankingsBase;

var const array<string> RankingCategories;

var automated BTGUI_ComboBox RankingsCombo;
var automated BTGUI_PlayerRankingsMultiColumnListBox RankingsListBox;
var private bool bWaitingForReplication;

event InitComponent( GUIController myController, GUIComponent myOwner )
{
	local int i;

	super.InitComponent( myController, myOwner );
	RankingsListBox.MyScrollBar.PositionChanged = InternalOnScroll;
    RankingsListBox.ContextMenu.OnSelect = InternalOnContext;
    RankingsListBox.List.OnDblClick = InternalOnSelected;
	for( i = 0; i < RankingCategories.Length; ++ i )
	{
	    RankingsCombo.AddItem( RankingCategories[i], none, string(i) );
	}
}

event Opened( GUIComponent sender )
{
    local BTClient_ClientReplication CRI;

    super.Opened( sender );
    CRI = GetCRI( PlayerOwner().PlayerReplicationInfo );
    if( CRI == none )
        return;

    if( CRI.Rankings[GetCurrentRanksId()] == none && !bWaitingForReplication)
    {
        bWaitingForReplication = true;
        RequestReplicationChannels();
    }
}

private function RequestReplicationChannels()
{
	local BTClient_ClientReplication CRI;
	local byte ranksId;

	ranksId = GetCurrentRanksId();
    CRI = GetCRI( PlayerOwner().PlayerReplicationInfo );
    CRI.ServerRequestPlayerRanks( -1, ranksId ); // Initialize replication channels.
	// PlayerOwner().ClientMessage("Requesting channel" @ ranksId);
}

private function QueryNextPlayerRanks()
{
	local BTClient_ClientReplication CRI;

	// PlayerOwner().ClientMessage("Querying next ranks" @ bIsQuerying);
    if( bIsQuerying )
    	return;

    bIsQuerying = true;
    RankingsCombo.DisableMe();
    CRI = GetCRI( PlayerOwner().PlayerReplicationInfo );
    CRI.Rankings[GetCurrentRanksId()].QueryNextPlayerRanks();;
}

final function byte GetCurrentRanksId()
{
	return byte(RankingsCombo.GetExtra());
}

// Wait for the ready event, before we request ranks.
function RepReady( BTGUI_ScoreboardReplicationInfo source )
{
    local BTGUI_PlayerRankingsReplicationInfo ranksRep;

    ranksRep = BTGUI_PlayerRankingsReplicationInfo(source);
    if( ranksRep == none ) // Not meant for this instance
        return;

    Log("Rep ready" @ ranksRep.RanksId);
    // Start receiving updates.
    ranksRep.OnPlayerRankReceived = InternalOnPlayerRankReceived;
    ranksRep.OnPlayerRanksDone = InternalOnPlayerRanksDone;
    RankingsListBox.SwitchRankings( ranksRep.RanksId, ranksRep );
    QueryNextPlayerRanks();
    bWaitingForReplication = false;
}

function InternalOnChangeRankingsCategory( GUIComponent sender )
{
    local BTGUI_PlayerRankingsMultiColumnList list;
	local BTClient_ClientReplication CRI;
	local byte ranksId;

    bIsQuerying = false; // renable querying
    ranksId = GetCurrentRanksId();
    CRI = GetCRI( PlayerOwner().PlayerReplicationInfo );
    Log("Changing rankings category to" @ ranksId @ "channel:" @ CRI.Rankings[ranksId]);
	if( CRI.Rankings[ranksId] == none )
	{
		// PlayerOwner().ClientMessage("Requesting new rankings channel" @ ranksId);
    	CRI.ServerRequestPlayerRanks( -1, ranksId ); // Initialize replication channels.
    	return;
	}
	RankingsListBox.SwitchRankings( ranksId, CRI.Rankings[ranksId] );

    list = RankingsListBox.RankingLists[ranksId];
    // t_WindowTitle.SetCaption(
    //     WindowName @ "(" $ list.ItemCount $ "/" $ Inter.MRI.RankedPlayersCount $ ") out of"
    //     @ Inter.MRI.PlayersCount
    // );
}

function InternalOnPlayerRankReceived( int index, BTGUI_PlayerRankingsReplicationInfo source )
{
	local BTGUI_PlayerRankingsMultiColumnList list;

	// PlayerOwner().ClientMessage("Received a rank packet");
	list = RankingsListBox.RankingLists[source.RanksId];
	if( list == none )
	{
		Warn("Received a rank for a non existing rankings list!");
		return;
	}
	list.AddedItem();
	if( Inter == none ) // None once this menu is reopened :<?
    	Inter = GetInter();

	// t_WindowTitle.SetCaption(
	// 	WindowName @ "(" $ list.ItemCount $ "/" $ Inter.MRI.RankedPlayersCount $ ") out of"
	// 	@ Inter.MRI.PlayersCount
	// );
}

function InternalOnPlayerRanksDone( BTGUI_PlayerRankingsReplicationInfo source, bool bAll )
{
	// PlayerOwner().ClientMessage("Query completed");
	bIsQuerying = bAll; // Don't ever query again if we have received all there is to be received!
    RankingsCombo.EnableMe();

	if( !bIsQuerying && !RankingsListBox.MyScrollBar.bVisible )
	{
		QueryNextPlayerRanks();
	}
    else
    {
        // If our end user is sorting by other means than Rank, then we should make sure the newly added data gets sorted straight away!
        RankingsListBox.List.NeedsSorting = true;
    }
}

function InternalOnScroll( int newPos )
{
    if( newPos > RankingsListBox.MyScrollBar.ItemCount-15 )
    {
        QueryNextPlayerRanks();
    }
}

function InternalOnContext( GUIContextMenu sender, int clickIndex )
{
    switch( clickIndex )
    {
        // Player
        case 0:
            ViewPlayer( RankingsListBox.List.CurrentListId() );
            break;
    }
}

function bool InternalOnSelected( GUIComponent sender )
{
    local int itemIndex;

    itemIndex = RankingsListBox.List.CurrentListId();
    ViewPlayer( itemIndex );
    return false;
}

private function ViewPlayer( int itemIndex )
{
    local BTClient_ClientReplication CRI;
    local byte ranksId;

    ranksId = GetCurrentRanksId();
    CRI = GetCRI( PlayerOwner().PlayerReplicationInfo );
    OnQueryPlayer( CRI.Rankings[ranksId].PlayerRanks[itemIndex].PlayerId );
}

defaultproperties
{
     RankingCategories(0)="Ranks - All Time"
     RankingCategories(1)="Ranks - This Year"
     RankingCategories(2)="Ranks - This Month"
     Begin Object Class=BTGUI_ComboBox Name=RanksComboBox
         bReadOnly=True
         bIgnoreChangeWhenTyping=True
         FontScale=FNS_Small
         WinTop=0.010000
         WinWidth=0.380000
         WinHeight=0.050000
         bBoundToParent=True
         bScaleToParent=True
         OnChange=BTGUI_PlayerRankingsScoreboard.InternalOnChangeRankingsCategory
         OnKeyEvent=RanksComboBox.InternalOnKeyEvent
     End Object
     RankingsCombo=BTGUI_ComboBox'BTGUI_PlayerRankingsScoreboard.RanksComboBox'

     Begin Object Class=BTGUI_PlayerRankingsMultiColumnListBox Name=ItemsListBox
         bVisibleWhenEmpty=True
         OnCreateComponent=ItemsListBox.InternalOnCreateComponent
         WinTop=0.070000
         WinHeight=0.915000
         bBoundToParent=True
         bScaleToParent=True
     End Object
     RankingsListBox=BTGUI_PlayerRankingsMultiColumnListBox'BTGUI_PlayerRankingsScoreboard.ItemsListBox'
}
