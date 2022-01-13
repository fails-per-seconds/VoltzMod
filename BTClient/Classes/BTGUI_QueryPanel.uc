class BTGUI_QueryPanel extends GUIPanel;

var automated GUIHeader Header;
var automated GUILabel QueryLabel;
var automated GUIEditBox QueryBox;
var automated GUIImage PanelImage;
var automated BTGUI_QueryDataPanel DataPanel;

delegate OnQueryReceived( BTQueryDataReplicationInfo queryRI );

event Free()
{
	super.Free();
	OnQueryReceived = none;
}

function InternalOnQueryChange( GUIComponent sender )
{
	DoQuery( GetQuery() );
}

function DoQuery( string query )
{
    local BTClient_ClientReplication CRI;

    Log( "received request for query \"" $ query $ "\"" );
    CRI = class'BTClient_ClientReplication'.static.GetRep( PlayerOwner() );
    if( CRI == none )
    {
    	Warn("Attempt to query with no CRI");
    	return;
    }
    CRI.ServerPerformQuery( query );
}

function InternalOnQueryReceived( BTQueryDataReplicationInfo queryRI )
{
	SwitchDataPanel( queryRI );
}

function InternalOnQueryRequest( string newQuery )
{
	SetQuery( newQuery );
}

final function SwitchDataPanel( BTQueryDataReplicationInfo queryRI )
{
	local BTGUI_QueryDataPanel newDataPanel;

	newDataPanel = BTGUI_QueryDataPanel(AddComponent( string(queryRI.DataPanelClass) ));
	newDataPanel.WinWidth = DataPanel.WinWidth;
	newDataPanel.WinHeight = DataPanel.WinHeight;
	newDataPanel.WinTop = DataPanel.WinTop;
	newDataPanel.WinLeft = DataPanel.WinLeft;
	newDataPanel.bScaleToParent = DataPanel.bScaleToParent;
	newDataPanel.bBoundToParent = DataPanel.bBoundToParent;
	newDataPanel.OnQueryRequest = InternalOnQueryRequest;
	DataPanel.Free();
	RemoveComponent( DataPanel );
	DataPanel = newDataPanel;
	DataPanel.ApplyData( queryRI );
	queryRI.Abandon();
}

final function string GetQuery()
{
	return QueryBox.GetText();
}

final function SetQuery( coerce string query )
{
	QueryBox.SetText( query );
}

defaultproperties
{
     Begin Object Class=GUIHeader Name=oHeader
         bUseTextHeight=True
         Caption="Details"
         StyleName="BTHeader"
         WinTop=0.065000
         WinHeight=0.043750
         RenderWeight=0.100000
         ScalingType=SCALE_X
     End Object
     Header=GUIHeader'BTGUI_QueryPanel.oHeader'

     Begin Object Class=GUILabel Name=oQueryLabel
         Caption="Search"
         TextAlign=TXTA_Center
         TextColor=(B=255,G=255,R=255)
         bTransparent=False
         FontScale=FNS_Small
         StyleName="BTLabel"
         WinWidth=0.195000
         bBoundToParent=True
         bScaleToParent=True
     End Object
     QueryLabel=GUILabel'BTGUI_QueryPanel.oQueryLabel'

     Begin Object Class=GUIEditBox Name=oQueryBox
         StyleName="BTEditBox"
         WinLeft=0.200000
         WinWidth=0.800000
         bBoundToParent=True
         bScaleToParent=True
         OnActivate=oQueryBox.InternalActivate
         OnDeActivate=oQueryBox.InternalDeactivate
         OnChange=BTGUI_QueryPanel.InternalOnQueryChange
         OnKeyType=oQueryBox.InternalOnKeyType
         OnKeyEvent=oQueryBox.InternalOnKeyEvent
     End Object
     QueryBox=GUIEditBox'BTGUI_QueryPanel.oQueryBox'

     Begin Object Class=BTGUI_QueryDataPanel Name=oQueryDataPanel
         WinTop=0.115000
         WinHeight=0.885000
         bBoundToParent=True
         bScaleToParent=True
         OnDraw=oQueryDataPanel.InternalOnDraw
     End Object
     DataPanel=BTGUI_QueryDataPanel'BTGUI_QueryPanel.oQueryDataPanel'

     OnQueryReceived=BTGUI_QueryPanel.InternalOnQueryReceived
}
