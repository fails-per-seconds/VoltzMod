class BTGUI_Trophies extends BTGUI_StatsTab
	dependson(Actor);

var const Texture TrophyIcon;

var automated GUIButton b_Exchange;
var automated GUIEditBox eb_Amount;

//var automated GUIImage i_ItemIcon;
var automated GUISectionBackground sb_Background;
var automated GUIScrollTextBox eb_Description;
var automated GUIImage i_Render;

var() editinline SpinnyWeap SpinnyDude;
var() const vector SpinnyDudeOffset;

event Free()
{
    if( SpinnyDude != none )
    {
        SpinnyDude.Destroy();
        SpinnyDude = none;
    }
    super.Free();
}

function ShowPanel( bool bShow )
{
    super.ShowPanel( bShow );

    if( bShow && CRI != none && PlayerOwner().Level.TimeSeconds > 5 )
    {
        LoadData();
    }
}

function InitComponent( GUIController InController, GUIComponent InOwner )
{
    super.InitComponent( InController, InOwner );
    eb_Description.MyScrollText.SetContent( "Minimum trophies necessary to exchange: 25|Maximum exchangeable trophies: 45" );
    eb_Description.MyScrollBar.AlignThumb();
    eb_Description.MyScrollBar.UpdateGripPosition( 0 );

    SpinnyDude = PlayerOwner().Spawn( class'SpinnySkel' );
    SpinnyDude.SetDrawType( DT_Mesh );
    SpinnyDude.bPlayRandomAnims = true;
    SpinnyDude.SetDrawScale( 0.3 );
    SpinnyDude.bHidden = true;

    SpinnyDude.LinkMesh( SkeletalMesh'SkaarjAnims.Skaarj_Skel' );
    SpinnyDude.LoopAnim( 'Idle_Rest', 1.0 );
}

private function LoadData()
{
    PlayerOwner().ConsoleCommand( "Mutate BTClient_RequestTrophies" );
}

private function bool ExchangeTrophies()
{
    PlayerOwner().ConsoleCommand( "Mutate ExchangeTrophies" @ eb_Amount.GetText() );
    LoadData();
    return true;
}

function bool InternalOnClick( GUIComponent Sender )
{
    if( Sender == b_Exchange )
    {
        return ExchangeTrophies();
    }
}

function bool InternalOnDrawSpinnyDude( Canvas canvas )
{
    local vector CamPos, X, Y, Z;
    local rotator CamRot;

    canvas.GetCameraLocation( CamPos, CamRot );
    GetAxes( CamRot, X, Y, Z );

    SpinnyDude.SetLocation( CamPos + (SpinnyDudeOffset.X * X) + (SpinnyDudeOffset.Y * Y) + (SpinnyDudeOffset.Z * Z) );
    SpinnyDude.SetRotation( rotator(CamPos - SpinnyDude.Location) );

    canvas.DrawActor( SpinnyDude, false, true, 90.0 );
    return false;
}

function bool InternalOnDraw( Canvas C )
{
    local int i;
    local float YPos, XPos, XL, YL, orgCurY;

    if( CRI == none )
        return false;

    C.Font = Font'UT2003Fonts.jFontSmallText800x600';
    YPos = Region.ActualTop();
    C.StrLen( "T", XL, YL );
    for( i = CurPos; i < CRI.Trophies.Length; ++ i )
    {
        XPos = Region.ActualLeft();
        orgCurY = C.CurY;

        C.SetPos( XPos, YPos );
        C.DrawColor = class'HUD'.default.WhiteColor;
        C.Style = 5;
        C.DrawTileStretched( RegionImage, Region.ActualWidth(), YL + 8 );

        XPos += 8;
        C.SetPos( XPos, YPos + 4 );
        C.DrawTileJustified( TrophyIcon, 1, YL, YL );

        // Title
        XPos += YL + 8;
        C.SetPos( XPos, YPos + 4 );
        C.Style = 3;
        C.DrawText( CRI.Trophies[i].Title );

        YPos += (YL + 8) + 8;

        if( YPos + (YL + 8) >= Region.ActualTop() + Region.ActualHeight() )
            break;
    }
    return true;
}

function bool InternalOnKeyEvent( out byte Key, out byte State, float delta )
{
    if( State == 0x01 )
    {
        if( Key == 0xEC )
        {
            CurPos = Max( CurPos - 1, 0 );
            return true;
        }
        else if( Key == 0xED )
        {
            CurPos = Min( CurPos + 1, CRI.Trophies.Length - 1 );
            return true;
        }
    }
    return false;
}

defaultproperties
{
     TrophyIcon=Texture'itemChecked'
     Begin Object Class=GUIButton Name=oExchange
         Caption="Exchange for Currency"
         Hint="Exchange all your trophies for Curreny points"
         WinTop=0.870000
         WinLeft=0.110000
         WinWidth=0.300000
         WinHeight=0.060000
         OnClick=BTGUI_Trophies.InternalOnClick
         OnKeyEvent=oExchange.InternalOnKeyEvent
     End Object
     b_Exchange=GUIButton'BTGUI_Trophies.oExchange'

     Begin Object Class=GUIEditBox Name=oAmount
         TextStr="All"
         Hint="Amount of trophies to exchange"
         WinTop=0.875000
         WinWidth=0.100000
         WinHeight=0.050000
         bBoundToParent=True
         bScaleToParent=True
         OnActivate=oAmount.InternalActivate
         OnDeActivate=oAmount.InternalDeactivate
         OnKeyType=oAmount.InternalOnKeyType
         OnKeyEvent=oAmount.InternalOnKeyEvent
     End Object
     eb_Amount=GUIEditBox'BTGUI_Trophies.oAmount'

     Begin Object Class=GUISectionBackground Name=Render
         HeaderBase=Texture'2K4Menus.NewControls.Display99'
         Caption="Currency Details"
         WinTop=0.010000
         WinLeft=0.710000
         WinWidth=0.290000
         WinHeight=0.910000
         OnPreDraw=Render.InternalPreDraw
     End Object
     sb_Background=GUISectionBackground'BTGUI_Trophies.Render'

     Begin Object Class=GUIScrollTextBox Name=Desc
         bNoTeletype=True
         bVisibleWhenEmpty=True
         OnCreateComponent=Desc.InternalOnCreateComponent
         WinTop=0.380000
         WinLeft=0.725000
         WinWidth=0.260000
         WinHeight=0.415000
         bBoundToParent=True
         bScaleToParent=True
     End Object
     eb_Description=GUIScrollTextBox'BTGUI_Trophies.Desc'

     Begin Object Class=GUIImage Name=oRender
         ImageColor=(A=128)
         ImageStyle=ISTY_Stretched
         WinTop=0.070000
         WinLeft=0.730000
         WinWidth=0.250000
         WinHeight=0.250000
         bBoundToParent=True
         bScaleToParent=True
         OnDraw=BTGUI_Trophies.InternalOnDrawSpinnyDude
     End Object
     i_Render=GUIImage'BTGUI_Trophies.oRender'

     SpinnyDudeOffset=(X=150.000000,Y=77.000000,Z=20.000000)
     Begin Object Class=GUIImage Name=oRegion
         ImageColor=(A=128)
         ImageStyle=ISTY_Stretched
         WinTop=0.010000
         WinWidth=0.700000
         WinHeight=0.910000
         bBoundToParent=True
         bScaleToParent=True
         OnDraw=BTGUI_Trophies.InternalOnDraw
     End Object
     Region=GUIImage'BTGUI_Trophies.oRegion'

     OnKeyEvent=BTGUI_Trophies.InternalOnKeyEvent
}
