class BTClient_MapVoteCountMultiColumnListBox extends MapVoteCountMultiColumnListBox;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	DefaultListClass = string(class'BTClient_MapVoteCountMultiColumnList');
	Super.Initcomponent(MyController, MyOwner);
}

defaultproperties
{
     MapInfoPage=""
     DefaultListClass="BTClient_MapVoteCountMultiColumnList"
     Begin Object Class=GUIContextMenu Name=RCMenu
         ContextItems(0)="Vote for this Map"
         SelectionStyleName="BTListSelection"
         OnSelect=BTClient_MapVoteCountMultiColumnListBox.InternalOnClick
         StyleName="BTContextMenu"
     End Object
     ContextMenu=GUIContextMenu'BTClient_MapVoteCountMultiColumnListBox.RCMenu'
}
