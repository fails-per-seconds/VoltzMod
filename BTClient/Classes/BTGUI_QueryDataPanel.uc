class BTGUI_QueryDataPanel extends GUIPanel;

enum EFormating
{
    F_Default,
    F_Numeric,
    F_Bool,
    F_Date,
    F_Time,
    F_Hours
};

var() editconstarray array<struct sMetaDataRow{
    var() localized string Caption;
    var() name Bind;
    var() EFormating Format;
    var transient string Value;
}> DataRows;

var automated GUIMultiColumnListBox RowsListBox;

delegate OnQueryRequest( string newQuery );

event Free()
{
    super.Free();
    RowsListBox.List.Clear();
    OnQueryRequest = none;
}

event InitComponent( GUIController myController, GUIComponent myOwner )
{
    super.InitComponent( myController, myOwner );
    RowsListBox.List.SortColumn = -1;
    RowsListBox.List.OnDrawItem = InternalOnDrawRow;
    RowsListBox.List.GetItemHeight = InternalGetRowHeight;
    CreateDataRows();
}

private function CreateDataRows()
{
    local int i;

    for( i = 0; i < DataRows.Length; ++ i )
    {
        RowsListBox.List.AddedItem( i );
    }
}

function bool InternalOnDraw( Canvas C )
{
    C.SetPos( ActualLeft(), ActualTop() );
    C.DrawColor = class'BTClient_Config'.static.FindSavedData().CTable;
    C.DrawTile( Texture'BTScoreBoardBG', ActualWidth(), ActualHeight(), 0, 0, 256, 256 );
    return false;
}

function float InternalGetRowHeight( Canvas C )
{
    local float xl, yl;

    C.StrLen( "T", xl, yl );
    return yl + 8;
}

function InternalOnDrawRow( Canvas C, int i, float X, float Y, float W, float H, bool bSelected, bool bPending )
{
    local float CellLeft, CellWidth;
    local GUIStyles DrawStyle;

    Y += 2;
    H -= 2;

    C.Style = 1;
    DrawStyle = RowsListBox.List.Style;

    RowsListBox.List.GetCellLeftWidth( 0, CellLeft, CellWidth );
    DrawStyle.FontColors[0] = class'HUD'.default.WhiteColor;
    C.DrawColor.R = 255;
    C.DrawColor.G = 32;
    C.DrawColor.B = 10;
    C.DrawColor.A = 84;
    C.SetPos( CellLeft, Y );
    C.DrawTile( Texture'BTScoreBoardBG', CellWidth, H, 0, 0, 256, 256 );
    DrawStyle.DrawText(
        C, MSAT_Blurry, CellLeft+2, Y, CellWidth-4, H, TXTA_Left,
        DataRows[i].Caption,
        RowsListBox.List.FontScale
    );

    RowsListBox.List.GetCellLeftWidth( 1, CellLeft, CellWidth );
    DrawStyle.FontColors[0] = class'HUD'.default.GoldColor;
    C.DrawColor.R = 32;
    C.DrawColor.G = 32;
    C.DrawColor.B = 32;
    C.DrawColor.A = 84;
    C.SetPos( CellLeft, Y );
    C.DrawTile( Texture'BTScoreBoardBG', CellWidth, H, 0, 0, 256, 256 );
    DrawStyle.DrawText(
        C, MSAT_Blurry, CellLeft+2, Y, CellWidth-4, H, TXTA_Right,
        DataRows[i].Value,
        RowsListBox.List.FontScale
    );
}

final protected function string Formatize( coerce string value, EFormating format )
{
    switch( format )
    {
        case F_Default:
            if( value == "" )
                return "N/A";
            return value;

        case F_Bool:
            return Eval(bool(value), "Yes", "No");

        case F_Numeric:
            if( value == "" || float(value) == 0.00 )
                return "N/A";
            return value;

        case F_Date:
            if( int(value) == 0 )
                return "N/A";
            return class'BTClient_Interaction'.static.CompactDateToString( int(value) );

        case F_Time:
            return class'BTClient_Interaction'.static.FormatTimeCompact( float(value) );

        case F_Hours:
            return int(value)$"h";
    }
    return value;
}

final protected function string Format( coerce string value )
{
    if( value == "" || float(value) == 0.00 )
        return "N/A";
    return value;
}

function ApplyData( BTQueryDataReplicationInfo queryRI )
{
    local int i;

    for( i = 0; i < DataRows.Length; ++ i )
    {
        if( DataRows[i].Bind != '' )
        {
            DataRows[i].Value = Formatize( queryRI.GetPropertyText( string(DataRows[i].Bind) ), DataRows[i].Format );
        }
        else
        {
            DataRows[i].Value = Formatize( DataRows[i].Value, DataRows[i].Format );
        }
    }
}

defaultproperties
{
     Begin Object Class=GUIMultiColumnListBox Name=oRowsListBox
         bDisplayHeader=False
         HeaderColumnPerc(0)=0.500000
         HeaderColumnPerc(1)=0.500000
         ColumnHeadings(0)="Key"
         ColumnHeadings(1)="Value"
         SelectedStyleName="BTListSelection"
         OnCreateComponent=oRowsListBox.InternalOnCreateComponent
         WinTop=0.010000
         WinLeft=0.010000
         WinWidth=0.980000
         WinHeight=0.780000
     End Object
     RowsListBox=GUIMultiColumnListBox'BTGUI_QueryDataPanel.oRowsListBox'

     OnDraw=BTGUI_QueryDataPanel.InternalOnDraw
}
