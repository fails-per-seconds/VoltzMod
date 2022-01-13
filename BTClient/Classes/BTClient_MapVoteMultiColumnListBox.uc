class BTClient_MapVoteMultiColumnListBox extends MapVoteMultiColumnListBox;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	DefaultListClass = string(class'BTClient_MapVoteMultiColumnList');
	Super.Initcomponent(MyController, MyOwner);
}

function LoadList(VotingReplicationInfo LoadVRI)
{
	local int i, g;

	ListArray.Length = LoadVRI.GameConfig.Length;
	for(i = 0; i < LoadVRI.GameConfig.Length; i++)
	{
		ListArray[i] = new class'BTClient_MapVoteMultiColumnList';
		ListArray[i].LoadList(LoadVRI, i);
		if (LoadVRI.GameConfig[i].GameClass ~= PlayerOwner().GameReplicationInfo.GameClass)
			g = i;
	}
	ChangeGameType(g);
}

defaultproperties
{
     DefaultListClass=""
     Begin Object Class=GUIContextMenu Name=oRCMenu
         ContextItems(0)="Vote for this Map"
         SelectionStyleName="BTListSelection"
         OnSelect=BTClient_MapVoteMultiColumnListBox.InternalOnClick
         StyleName="BTContextMenu"
     End Object
     ContextMenu=GUIContextMenu'BTClient_MapVoteMultiColumnListBox.oRCMenu'
}
