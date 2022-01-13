class BTGUI_RecordRankingsMultiColumnListBox extends GUIMultiColumnListBox;

var() const localized string EraseRecordName;

event InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	DefaultListClass = string(class'BTGUI_RecordRankingsMultiColumnList');
    super.InitComponent( MyController, MyOwner );
}

function bool InternalOnOpen( GUIContextMenu Sender )
{
    if( PlayerOwner().PlayerReplicationInfo.bAdmin || PlayerOwner().Level.NetMode == NM_Standalone )
    {
        ContextMenu.AddItem( EraseRecordName );
    }
    return true;
}

function bool InternalOnClose( GUIContextMenu Sender )
{
    ContextMenu.RemoveItemByName( EraseRecordName );
    return true;
}

// final function SwitchRankings( byte newRanksId, BTGUI_RecordRankingsReplicationInfo source )
// {
//     List.Hide();
//     if( RankingLists[newRanksId] == none )
//     {
//         RankingLists[newRanksId] = BTGUI_RecordRankingsMultiColumnList(AddComponent(DefaultListClass));
//     }
//     else
//     {
//         AppendComponent( RankingLists[newRanksId] );
//     }
//     RankingLists[newRanksId].RanksId = newRanksId;
//     RankingLists[newRanksId].Rankings = source;

//     RemoveComponent( List );
//     InitBaseList( RankingLists[newRanksId] );
// }

defaultproperties
{
     EraseRecordName="Erase Record"
     Begin Object Class=BTClient_MultiColumnListHeader Name=MyHeader
         OnDraw=MyHeader.InternalOnDraw
     End Object
     Header=BTClient_MultiColumnListHeader'BTGUI_RecordRankingsMultiColumnListBox.MyHeader'

     ColumnHeadings(0)="#"
     ColumnHeadings(1)="Rating"
     ColumnHeadings(2)="Player"
     ColumnHeadings(3)="Time"
     ColumnHeadings(4)="Date"
     DefaultListClass=""
     Begin Object Class=GUIVertScrollBar Name=TheScrollbar
         bVisible=False
         OnPreDraw=TheScrollbar.GripPreDraw
     End Object
     MyScrollBar=GUIVertScrollBar'BTGUI_RecordRankingsMultiColumnListBox.TheScrollbar'

     Begin Object Class=GUIContextMenu Name=oContextMenu
         ContextItems(0)="View Record Details"
         ContextItems(1)="View Player Details"
         SelectionStyleName="BTListSelection"
         OnOpen=BTGUI_RecordRankingsMultiColumnListBox.InternalOnOpen
         OnClose=BTGUI_RecordRankingsMultiColumnListBox.InternalOnClose
         StyleName="BTContextMenu"
     End Object
     ContextMenu=GUIContextMenu'BTGUI_RecordRankingsMultiColumnListBox.oContextMenu'
}
