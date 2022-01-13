class BTGUI_PlayerItemsListBox extends GUIVertImageListBox;

defaultproperties
{
     Begin Object Class=GUIContextMenu Name=oContextMenu
         ContextItems(0)="Equip/Unequip Item"
         ContextItems(1)="Edit Item (if available)"
         ContextItems(2)="Sell Item to Vendor"
         ContextItems(3)="Destroy Item"
     End Object
     ContextMenu=GUIContextMenu'BTGUI_PlayerItemsListBox.oContextMenu'
}
