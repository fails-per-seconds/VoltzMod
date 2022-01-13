class BTGUI_MapQueryDataPanel extends BTGUI_QueryDataPanel;

defaultproperties
{
     DataRows(0)=(Caption="First Played On",bind="RegisterDate",Format=F_Date)
     DataRows(1)=(Caption="Last Played On",bind="LastPlayedDate",Format=F_Date)
     DataRows(2)=(Caption="Is Ranked",bind="bIsRanked",Format=F_Bool)
     DataRows(3)=(Caption="Is Available",bind="bMapIsActive",Format=F_Bool)
     DataRows(4)=(Caption="Rating",bind="rating")
     DataRows(5)=(Caption="Mean Record Time",bind="AverageRecordTime",Format=F_Time)
     DataRows(6)=(Caption="Played Time",bind="PlayHours",Format=F_Hours)
     DataRows(7)=(Caption="Completed",bind="CompletedCount",Format=F_Numeric)
     DataRows(8)=(Caption="Hijacked",bind="HijackedCount",Format=F_Numeric)
     DataRows(9)=(Caption="Fails",bind="FailedCount",Format=F_Numeric)
}
