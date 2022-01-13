class BTGUI_PlayerRankingsMultiColumnListBox extends GUIMultiColumnListBox;

var BTGUI_PlayerRankingsMultiColumnList RankingLists[3];

event Free()
{
    super.Free();
    RankingLists[0] = none;
    RankingLists[1] = none;
    RankingLists[2] = none;
}

event InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	DefaultListClass = string(class'BTGUI_PlayerRankingsMultiColumnList');
    super.InitComponent( MyController, MyOwner );

    // Skip first list
    RankingLists[0] = BTGUI_PlayerRankingsMultiColumnList(List);
}

final function SwitchRankings( byte newRanksId, BTGUI_PlayerRankingsReplicationInfo source )
{
    List.Hide();
    if( RankingLists[newRanksId] == none )
    {
        RankingLists[newRanksId] = BTGUI_PlayerRankingsMultiColumnList(AddComponent(DefaultListClass));
    }
    else
    {
        AppendComponent( RankingLists[newRanksId] );
    }
    RankingLists[newRanksId].RanksId = newRanksId;
    RankingLists[newRanksId].Rankings = source;

    RemoveComponent( List );
    InitBaseList( RankingLists[newRanksId] );
}

defaultproperties
{
     Begin Object Class=BTClient_MultiColumnListHeader Name=MyHeader
         HeadingIcons(4)=ColorModifier'Icons.Star'
         OnDraw=MyHeader.InternalOnDraw
     End Object
     Header=BTClient_MultiColumnListHeader'BTGUI_PlayerRankingsMultiColumnListBox.MyHeader'

     ColumnHeadings(0)="#"
     ColumnHeadings(1)="Player"
     ColumnHeadings(2)="ELO"
     ColumnHeadings(3)="Recs"
     ColumnHeadings(4)="Stars"
     ColumnHeadings(5)="AP"
     DefaultListClass=""
     Begin Object Class=GUIVertScrollBar Name=TheScrollbar
         bVisible=False
         OnPreDraw=TheScrollbar.GripPreDraw
     End Object
     MyScrollBar=GUIVertScrollBar'BTGUI_PlayerRankingsMultiColumnListBox.TheScrollbar'

     Begin Object Class=GUIContextMenu Name=oContextMenu
         ContextItems(0)="View Player Details"
         SelectionStyleName="BTListSelection"
         StyleName="BTContextMenu"
     End Object
     ContextMenu=GUIContextMenu'BTGUI_PlayerRankingsMultiColumnListBox.oContextMenu'
}
