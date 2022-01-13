class BTQueryDataReplicationInfo extends ReplicationInfo;

var() const class<BTGUI_QueryDataPanel> DataPanelClass;

replication
{
	reliable if (Role < ROLE_Authority)
		Abandon;
}

simulated event PostNetBeginPlay()
{
	Super.PostNetBeginPlay();
	if (Level.NetMode != NM_DedicatedServer)
		SetTimer(0.05, false);
}

simulated event Timer()
{
	RepReady();
}

simulated function RepReady()
{
	local BTGUI_RankingsMenu menu;

	menu = class'BTGUI_RankingsMenu'.static.GetMenu(Level.GetLocalPlayerController());
	if (menu == none)
	{
		Warn("Received query replication data, but no menu was found");
		return;
	}

	menu.PassQueryReceived( self );
}

simulated function Abandon()
{
	Destroy();
}

defaultproperties
{
     bOnlyRelevantToOwner=True
     bAlwaysRelevant=False
     bReplicateMovement=False
     NetPriority=0.500000
}
