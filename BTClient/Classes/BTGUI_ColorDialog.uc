class BTGUI_ColorDialog extends FloatingWindow;

var automated GUILabel l_PreferedColor, l_Red, l_Green, l_Blue, l_Alpha;
var automated GUISlider s_Red, s_Green, s_Blue, s_Alpha;
var editconst ColorModifier SlideColor[4];

final static function Color GetPreferedColor( PlayerController PC )
{
    local LinkedReplicationInfo LRI;

    for( LRI = PC.PlayerReplicationInfo.CustomReplicationInfo; LRI != none; LRI = LRI.NextReplicationInfo )
    {
        if( LRI.IsA('BTClient_ClientReplication') )
        {
            return BTClient_ClientReplication(LRI).PreferedColor;
        }
    }
    return class'HUD'.default.WhiteColor;
}

function Free()
{
    local int i;

    for( i = 0; i < arraycount(SlideColor); ++ i )
    {
        SlideColor[i].Material = none;
        SlideColor[i].Color.R = 0;
        SlideColor[i].Color.G = 0;
        SlideColor[i].Color.B = 0;
        SlideColor[i].Color.A = 0;
        PlayerOwner().Level.ObjectPool.FreeObject( SlideColor[i] );
    }
    super.Free();
}

function Opened( GUIComponent sender )
{
    SlideColor[0] = ColorModifier(PlayerOwner().Level.ObjectPool.AllocateObject( Class'ColorModifier' ));
    SlideColor[0].Material = s_Red.FillImage;
    SlideColor[0].Color.R = 255;
    SlideColor[0].Color.G = 0;
    SlideColor[0].Color.B = 0;
    s_Red.FillImage = SlideColor[0];

    SlideColor[1] = ColorModifier(PlayerOwner().Level.ObjectPool.AllocateObject( Class'ColorModifier' ));
    SlideColor[1].Material = s_Green.FillImage;
    SlideColor[1].Color.R = 0;
    SlideColor[1].Color.G = 255;
    SlideColor[1].Color.B = 0;
    s_Green.FillImage = SlideColor[1];

    SlideColor[2] = ColorModifier(PlayerOwner().Level.ObjectPool.AllocateObject( Class'ColorModifier' ));
    SlideColor[2].Material = s_Blue.FillImage;
    SlideColor[2].Color.R = 0;
    SlideColor[2].Color.G = 0;
    SlideColor[2].Color.B = 255;
    s_Blue.FillImage = SlideColor[2];

    SlideColor[3] = ColorModifier(PlayerOwner().Level.ObjectPool.AllocateObject( Class'ColorModifier' ));
    SlideColor[3].Material = s_Alpha.FillImage;
    SlideColor[3].Color.R = 255;
    SlideColor[3].Color.G = 255;
    SlideColor[3].Color.B = 255;
    s_Alpha.FillImage = SlideColor[3];

    UpdateSliderValues( class'BTClient_Config'.static.FindSavedData().PreferedColor /*GetPreferedColor( PlayerOwner() )*/ );
}

function UpdateSliderValues( Color newValue )
{
    s_Red.SetValue( newValue.R );
    s_Green.SetValue( newValue.G );
    s_Blue.SetValue( newValue.B );
    s_Alpha.SetValue( newValue.A );
    l_PreferedColor.TextColor = newValue;
}

function bool InternalOnClick( GUIComponent sender )
{
    if( sender == s_Alpha )
    {
        SlideColor[3].Color.A = byte(s_Alpha.GetValueString());
        class'BTClient_Config'.static.FindSavedData().PreferedColor.A = SlideColor[3].Color.A;
        l_PreferedColor.TextColor.A = SlideColor[3].Color.A;
        return true;
    }
    else if( sender == s_Red )
    {
        class'BTClient_Config'.static.FindSavedData().PreferedColor.R = byte(s_Red.GetValueString());
        l_PreferedColor.TextColor.R = byte(s_Red.GetValueString());
        return true;
    }
    else if( sender == s_Green)
    {
        class'BTClient_Config'.static.FindSavedData().PreferedColor.G = byte(s_Green.GetValueString());
        l_PreferedColor.TextColor.G = byte(s_Green.GetValueString());
        return true;
    }
    else if( sender == s_Blue )
    {
        class'BTClient_Config'.static.FindSavedData().PreferedColor.B = byte(s_Blue.GetValueString());
        l_PreferedColor.TextColor.B = byte(s_Blue.GetValueString());
        return true;
    }
    return false;
}

function Closed( GUIComponent sender, bool bCancelled )
{
    local int i;

    PlayerOwner().ConsoleCommand( "UpdatePreferedColor" );

    for( i = 0; i < arraycount(SlideColor); i ++ )
    {
        if( SlideColor[i] != None )
        {
            SlideColor[i].Material = SlideColor[i].default.Material;
            SlideColor[i].Color = SlideColor[i].default.Color;
            PlayerOwner().Level.ObjectPool.FreeObject( SlideColor[i] );
            SlideColor[i] = none;
        }
    }
    super.Closed( sender, bCancelled );
}

defaultproperties
{
     Begin Object Class=GUILabel Name=ColorTitle
         Caption="Preferred Color"
         TextColor=(B=255,G=255,R=255)
         WinTop=0.050000
         WinLeft=0.020000
         WinWidth=0.960000
     End Object
     l_PreferedColor=GUILabel'BTGUI_ColorDialog.ColorTitle'

     Begin Object Class=GUILabel Name=redLabel
         Caption="Red:"
         TextColor=(B=0,R=255)
         WinTop=0.200000
         WinLeft=0.020000
         WinWidth=0.200000
     End Object
     l_Red=GUILabel'BTGUI_ColorDialog.redLabel'

     Begin Object Class=GUILabel Name=greenLabel
         Caption="Green:"
         TextColor=(B=0,G=255)
         WinTop=0.400000
         WinLeft=0.020000
         WinWidth=0.200000
     End Object
     l_Green=GUILabel'BTGUI_ColorDialog.greenLabel'

     Begin Object Class=GUILabel Name=blueLabel
         Caption="Blue:"
         TextColor=(B=255)
         WinTop=0.600000
         WinLeft=0.020000
         WinWidth=0.200000
     End Object
     l_Blue=GUILabel'BTGUI_ColorDialog.blueLabel'

     Begin Object Class=GUILabel Name=alphaLabel
         Caption="Alpha:"
         TextColor=(B=255,G=255,R=255,A=128)
         WinTop=0.800000
         WinLeft=0.020000
         WinWidth=0.200000
     End Object
     l_Alpha=GUILabel'BTGUI_ColorDialog.alphaLabel'

     Begin Object Class=GUISlider Name=Red
         MaxValue=255.000000
         Value=50.000000
         bIntSlider=True
         bShowCaption=True
         WinTop=0.200000
         WinLeft=0.220000
         WinWidth=0.760000
         OnClick=BTGUI_ColorDialog.InternalOnClick
         OnMousePressed=Red.InternalOnMousePressed
         OnMouseRelease=Red.InternalOnMouseRelease
         OnKeyEvent=Red.InternalOnKeyEvent
         OnCapturedMouseMove=Red.InternalCapturedMouseMove
     End Object
     s_Red=GUISlider'BTGUI_ColorDialog.Red'

     Begin Object Class=GUISlider Name=Green
         MaxValue=255.000000
         Value=255.000000
         bIntSlider=True
         bShowCaption=True
         WinTop=0.400000
         WinLeft=0.220000
         WinWidth=0.760000
         OnClick=BTGUI_ColorDialog.InternalOnClick
         OnMousePressed=Green.InternalOnMousePressed
         OnMouseRelease=Green.InternalOnMouseRelease
         OnKeyEvent=Green.InternalOnKeyEvent
         OnCapturedMouseMove=Green.InternalCapturedMouseMove
     End Object
     s_Green=GUISlider'BTGUI_ColorDialog.Green'

     Begin Object Class=GUISlider Name=Blue
         MaxValue=255.000000
         Value=50.000000
         bIntSlider=True
         bShowCaption=True
         WinTop=0.600000
         WinLeft=0.220000
         WinWidth=0.760000
         OnClick=BTGUI_ColorDialog.InternalOnClick
         OnMousePressed=Blue.InternalOnMousePressed
         OnMouseRelease=Blue.InternalOnMouseRelease
         OnKeyEvent=Blue.InternalOnKeyEvent
         OnCapturedMouseMove=Blue.InternalCapturedMouseMove
     End Object
     s_Blue=GUISlider'BTGUI_ColorDialog.Blue'

     Begin Object Class=GUISlider Name=Alpha
         MaxValue=255.000000
         Value=255.000000
         bIntSlider=True
         bShowCaption=True
         WinTop=0.800000
         WinLeft=0.220000
         WinWidth=0.760000
         OnClick=BTGUI_ColorDialog.InternalOnClick
         OnMousePressed=Alpha.InternalOnMousePressed
         OnMouseRelease=Alpha.InternalOnMouseRelease
         OnKeyEvent=Alpha.InternalOnKeyEvent
         OnCapturedMouseMove=Alpha.InternalCapturedMouseMove
     End Object
     s_Alpha=GUISlider'BTGUI_ColorDialog.Alpha'

     WindowName="Preferred Color Dialog"
     bAllowedAsLast=True
     WinTop=0.600000
     WinLeft=0.600000
     WinWidth=0.200000
     WinHeight=0.200000
}
