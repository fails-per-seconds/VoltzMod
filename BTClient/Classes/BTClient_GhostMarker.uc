class BTClient_GhostMarker extends Actor;

var int MoveIndex;
var Vector LastRenderScr;
var float LastRenderTimeX;
var float LastRecordTimeDelta;

replication
{
	reliable if (bNetInitial)
		MoveIndex;
}

defaultproperties
{
     bOnlyDirtyReplication=True
     bNetInitialRotation=True
     NetUpdateFrequency=1.000000
     NetPriority=0.500000
     Texture=None
     bMovable=False
     bBlockZeroExtentTraces=False
     bBlockNonZeroExtentTraces=False
}
