class BTGUI_StatsTab extends BTGUI_TabBase;

var automated GUIImage Region;

var automated GUIScrollTextBox Summary;
var private string SummaryText;

var() editinline protected BTClient_ClientReplication CRI;

const RegionHeight = 128;
const IconSize = 64;

var editconst protected int CurPos;

var() texture RegionImage;

event Free()
{
    CRI = none;
    super.Free();
}

function PostInitPanel()
{
    CRI = class'BTClient_ClientReplication'.static.GetRep( PlayerOwner() );
}

function InitComponent( GUIController InController, GUIComponent InOwner )
{
    super.InitComponent( InController, InOwner );
    Summary.MyScrollText.NewText = SummaryText;
    Summary.MyScrollBar.AlignThumb();
    Summary.MyScrollBar.UpdateGripPosition( 0 );
}

function ShowPanel( bool bShow )
{
    if( CRI == none )
        CRI = class'BTClient_ClientReplication'.static.GetRep( PlayerOwner() );

    if( CRI == none )
    {
        Log( "ShowPanel, CRI not found!" );
    }
    super.ShowPanel( bShow );
}

function bool InternalOnDraw( Canvas C )
{
    return false;
}

defaultproperties
{
     Begin Object Class=GUIImage Name=oRegion
         ImageColor=(A=128)
         ImageStyle=ISTY_Stretched
         WinTop=0.060000
         WinHeight=0.840000
         bBoundToParent=True
         bScaleToParent=True
         OnDraw=BTGUI_StatsTab.InternalOnDraw
     End Object
     Region=GUIImage'BTGUI_StatsTab.oRegion'

     Begin Object Class=GUIScrollTextBox Name=oSummary
         bNoTeletype=True
         OnCreateComponent=oSummary.InternalOnCreateComponent
         WinHeight=0.060000
         bNeverFocus=True
     End Object
     Summary=GUIScrollTextBox'BTGUI_StatsTab.oSummary'

     RegionImage=Texture'InterfaceContent.Menu.EditBox'
}
