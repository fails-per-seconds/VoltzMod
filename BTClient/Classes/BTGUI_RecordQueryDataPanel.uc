class BTGUI_RecordQueryDataPanel extends BTGUI_QueryDataPanel;

var automated GUIButton ViewMapButton, ViewPlayerButton, ViewGhostButton;

var private string PlayerId, MapId;
var private int GhostId;

function ApplyData( BTQueryDataReplicationInfo queryRI )
{
	local BTRecordReplicationInfo myQueryRI;

	myQueryRI = BTRecordReplicationInfo(queryRI);
    // Completed Objectives
    DataRows[0].Value = Format(myQueryRI.Completed);
    DataRows[1].Value = Format(myQueryRI.AverageDodgeTiming);
    DataRows[2].Value = Format(myQueryRI.BestDodgeTiming);
    DataRows[3].Value = Format(myQueryRI.WorstDodgeTiming);

    if( myQueryRI.GhostId > 0 && myQueryRI.bIsCurrentMap )
        ViewGhostButton.EnableMe();
    else ViewGhostButton.DisableMe();

    GhostId = myQueryRI.GhostId;
    PlayerId = myQueryRI.PlayerId;
    MapId = myQueryRI.MapId;
    if( PlayerId == "" || PlayerId == "0" )
    {
        ViewPlayerButton.DisableMe();
    }
}

function bool InternalOnClick( GUIComponent sender )
{
    switch( sender )
    {
        case ViewMapButton:
            OnQueryRequest("map:"$MapId);
            return true;

        case ViewPlayerButton:
            OnQueryRequest("player:"$PlayerId);
            return true;

        case ViewGhostButton:
            PlayerOwner().ConsoleCommand("say" @ "!"$"ghost" @ GhostId);
            return true;
    }
    return false;
}

defaultproperties
{
     Begin Object Class=GUIButton Name=oViewMapButton
         Caption="Map Profile"
         FontScale=FNS_Small
         StyleName="BTButton"
         WinTop=0.800000
         WinLeft=0.010000
         WinWidth=0.480000
         WinHeight=0.090000
         OnClick=BTGUI_RecordQueryDataPanel.InternalOnClick
         OnKeyEvent=oViewMapButton.InternalOnKeyEvent
     End Object
     ViewMapButton=GUIButton'BTGUI_RecordQueryDataPanel.oViewMapButton'

     Begin Object Class=GUIButton Name=oViewPlayerButton
         Caption="Player Profile"
         FontScale=FNS_Small
         StyleName="BTButton"
         WinTop=0.900000
         WinLeft=0.010000
         WinWidth=0.480000
         WinHeight=0.090000
         OnClick=BTGUI_RecordQueryDataPanel.InternalOnClick
         OnKeyEvent=oViewPlayerButton.InternalOnKeyEvent
     End Object
     ViewPlayerButton=GUIButton'BTGUI_RecordQueryDataPanel.oViewPlayerButton'

     Begin Object Class=GUIButton Name=oViewGhostButton
         Caption="Spawn Ghost"
         FontScale=FNS_Small
         StyleName="BTButton"
         WinTop=0.900000
         WinLeft=0.510000
         WinWidth=0.480000
         WinHeight=0.090000
         OnClick=BTGUI_RecordQueryDataPanel.InternalOnClick
         OnKeyEvent=oViewGhostButton.InternalOnKeyEvent
     End Object
     ViewGhostButton=GUIButton'BTGUI_RecordQueryDataPanel.oViewGhostButton'

     DataRows(0)=(Caption="Objectives")
     DataRows(1)=(Caption="Average Dodge")
     DataRows(2)=(Caption="Best Dodge")
     DataRows(3)=(Caption="Worst Dodge")
}
