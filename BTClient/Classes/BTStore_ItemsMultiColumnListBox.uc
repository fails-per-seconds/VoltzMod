class BTStore_ItemsMultiColumnListBox extends GUIMultiColumnListBox;

event InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	DefaultListClass = string(class'BTStore_ItemsMultiColumnList');
	Super.InitComponent(MyController, MyOwner);
}

defaultproperties
{
     Begin Object Class=BTClient_MultiColumnListHeader Name=MyHeader
         OnDraw=MyHeader.InternalOnDraw
     End Object
     Header=BTClient_MultiColumnListHeader'BTStore_ItemsMultiColumnListBox.MyHeader'

     DefaultListClass=""
     Begin Object Class=GUIContextMenu Name=oContextMenu
         ContextItems(0)="Buy this item"
     End Object
     ContextMenu=GUIContextMenu'BTStore_ItemsMultiColumnListBox.oContextMenu'
}
