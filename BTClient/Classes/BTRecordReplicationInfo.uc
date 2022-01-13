class BTRecordReplicationInfo extends BTQueryDataReplicationInfo;

var string PlayerId, MapId;

var int Completed;
var float AverageDodgeTiming, BestDodgeTiming, WorstDodgeTiming;
var int GhostId;
var bool bIsCurrentMap;

replication
{
	reliable if (bNetInitial)
		PlayerId, MapId, Completed, AverageDodgeTiming, BestDodgeTiming, WorstDodgeTiming, GhostId, bIsCurrentMap;
}

defaultproperties
{
     Completed=1
     AverageDodgeTiming=0.430000
     BestDodgeTiming=0.400000
     WorstDodgeTiming=0.470000
     DataPanelClass=Class'BTGUI_RecordQueryDataPanel'
}
