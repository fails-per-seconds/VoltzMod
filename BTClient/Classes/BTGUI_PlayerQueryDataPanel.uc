class BTGUI_PlayerQueryDataPanel extends BTGUI_QueryDataPanel;

var automated GUIButton ViewRankedRecordsButton;
var private string PlayerId;

function ApplyData( BTQueryDataReplicationInfo queryRI )
{
	local BTPlayerProfileReplicationInfo myRI;

    super.ApplyData( queryRI );
	myRI = BTPlayerProfileReplicationInfo(queryRI);
    PlayerId = myRI.PlayerId;
    ViewRankedRecordsButton.DisableMe();
}

function bool InternalOnClick( GUIComponent sender )
{
    switch( sender )
    {
        case ViewRankedRecordsButton:
            // OnQueryRequest( "player:"$PlayerId );
            return true;
    }
    return false;
}

defaultproperties
{
     Begin Object Class=GUIButton Name=oViewRankedRecordsButton
         Caption="View Ranked Records"
         FontScale=FNS_Small
         StyleName="BTButton"
         WinTop=0.900000
         WinLeft=0.010000
         WinWidth=0.480000
         WinHeight=0.090000
         OnClick=BTGUI_PlayerQueryDataPanel.InternalOnClick
         OnKeyEvent=oViewRankedRecordsButton.InternalOnKeyEvent
     End Object
     ViewRankedRecordsButton=GUIButton'BTGUI_PlayerQueryDataPanel.oViewRankedRecordsButton'

     DataRows(0)=(Caption="First Played On",bind="RegisterDate",Format=F_Date)
     DataRows(1)=(Caption="Last Played On",bind="LastPlayedDate",Format=F_Date)
     DataRows(2)=(Caption="Country",bind="CountryCode")
     DataRows(3)=(Caption="Played Time",bind="PlayTime",Format=F_Hours)
     DataRows(4)=(Caption="Ranked ELO",bind="RankedELORating",Format=F_Numeric)
     DataRows(5)=(Caption="Ranked ELO Change",bind="RankedELORatingChange",Format=F_Numeric)
     DataRows(6)=(Caption="Ranked Stars",bind="NumStars",Format=F_Numeric)
     DataRows(7)=(Caption="Ranked Records",bind="NumRankedRecords",Format=F_Numeric)
     DataRows(8)=(Caption="Total Records",bind="NumRecords",Format=F_Numeric)
     DataRows(9)=(Caption="Objectives Completed",bind="NumObjectives",Format=F_Numeric)
     DataRows(10)=(Caption="Rounds Played",bind="NumRounds",Format=F_Numeric)
     DataRows(11)=(Caption="Records Hijacked",bind="NumHijacks",Format=F_Numeric)
     DataRows(12)=(Caption="Map Completions",bind="NumFinishes",Format=F_Numeric)
     DataRows(13)=(Caption="Achievement Points",bind="AchievementPoints")
}
