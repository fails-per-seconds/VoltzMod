Class BTClient_VRI extends VotingReplicationInfo;

const MapVotingPageClass = class'BTClient_MapVotingPage';

simulated function string GetMapNameString(int Index)
{
	if (Index >= MapList.Length)
		return "";
	else
		return class'BTClient_MapVoteMultiColumnList'.static.ParseMapName(MapList[Index].MapName);
}

simulated function OpenWindow()
{
	local GUIController controller;

	controller = GetController();
	if (controller.FindMenuByClass(MapVotingPageClass) != none)
		return;

	controller.OpenMenu(string(MapVotingPageClass));
}

delegate string InjectMapNameData(VotingReplicationInfo VRI, int mapIndex);
delegate OnReceiveMapInfo(VotingHandler.MapVoteMapList MapInfo);

function TickedReplication_MapList(int Index, bool bDedicated)
{
	local VotingHandler.MapVoteMapList MapInfo;
	local string data;

	MapInfo = VH.GetMapList(Index);
	DebugLog("___Sending " $ Index $ " - " $ MapInfo.MapName);

	data = InjectMapNameData(self, index);
	if (data != "")
	{
		MapInfo.MapName $= "$$" $ data;
	}

	if (bDedicated)
	{
		ReceiveMapInfo(MapInfo);
		bWaitingForReply = True;
	}
	else
		MapList[MapList.Length] = MapInfo;
}

simulated function ReceiveMapInfo(VotingHandler.MapVoteMapList MapInfo)
{
	Super.ReceiveMapInfo(MapInfo);
	OnReceiveMapInfo(MapInfo);
}

defaultproperties
{
     NetUpdateFrequency=2.000000
     NetPriority=1.500000
}
