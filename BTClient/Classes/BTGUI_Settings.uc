class BTGUI_Settings extends BTGUI_TabBase;

var automated GUIButton
    b_Save,
    b_Reset;

var automated moCheckBox
    cb_UseAltTimer,
    cb_ShowZoneActors,
    cb_FadeTextColors,
    cb_OIF,
    cb_OIN,
    cb_PT,
    cb_PTS,
    cb_DFT,
    cb_PM,
    cb_ABV,
    cb_RenderPathTimers, cb_RenderPathTimerIndexes;

var automated GUIEditBox
    eb_TickSound,
    eb_LastTickSound,
    eb_FailSound,
    eb_SucceedSound,
    eb_ToggleKey;

function InitPanel()
{
    super.InitPanel();
    LoadBTConfig();
}

function bool InternalOnClick( GUIComponent Sender )
{
    if( Sender == b_Save )
    {
        DisableComponent( b_Save );
        SaveBTConfig();
        return true;
    }
    else if( Sender == b_Reset )
    {
        DisableComponent( b_Reset );
        ResetBTConfig();
        LoadBTConfig();
        return true;
    }
    return false;
}

function InternalOnChange( GUIComponent Sender )
{
    EnableComponent( b_Save );
    EnableComponent( b_Reset );
}

private function ResetBTConfig()
{
    class'BTClient_Config'.static.FindSavedData().ResetSavedData();
}

private function LoadBTConfig()
{
    local BTClient_Config btConfig;

    btConfig = class'BTClient_Config'.static.FindSavedData();
    cb_UseAltTimer.Checked( btConfig.bUseAltTimer );
    cb_ShowZoneActors.Checked( btConfig.bShowZoneActors );
    cb_FadeTextColors.Checked( btConfig.bFadeTextColors );
    cb_OIF.Checked( btConfig.bDisplayFail );
    cb_OIN.Checked( btConfig.bDisplayNew );
    cb_PT.Checked( btConfig.bBaseTimeLeftOnPersonal );
    cb_PTS.Checked( btConfig.bPlayTickSounds );
    cb_DFT.Checked( btConfig.bDisplayFullTime );
    cb_PM.Checked( btConfig.bProfesionalMode );
    cb_ABV.Checked( btConfig.bAutoBehindView );

    eb_TickSound.SetText( string(btConfig.TickSound) );
    eb_LastTickSound.SetText( string(btConfig.LastTickSound) );
    eb_FailSound.SetText( string(btConfig.FailSound) );
    eb_SucceedSound.SetText( string(btConfig.NewSound) );
    eb_ToggleKey.SetText( class'Interactions'.static.GetFriendlyName( btConfig.RankingTableKey ) );

    cb_RenderPathTimers.Checked( btConfig.bRenderPathTimers );
    cb_RenderPathTimerIndexes.Checked( btConfig.bRenderPathTimerIndex );
}

private function SaveBTConfig()
{
    local BTClient_Config btConfig;

    btConfig = class'BTClient_Config'.static.FindSavedData();
    btConfig.bUseAltTimer = cb_UseAltTimer.IsChecked();
    btConfig.bShowZoneActors = cb_ShowZoneActors.IsChecked();
    btConfig.bFadeTextColors = cb_FadeTextColors.IsChecked();
    btConfig.bDisplayFail = cb_OIF.IsChecked();
    btConfig.bDisplayNew = cb_OIN.IsChecked();
    btConfig.bBaseTimeLeftOnPersonal = cb_PT.IsChecked();
    btConfig.bPlayTickSounds = cb_PTS.IsChecked();
    btConfig.bDisplayFullTime = cb_DFT.IsChecked();
    btConfig.bProfesionalMode = cb_PM.IsChecked();
    btConfig.bAutoBehindView = cb_ABV.IsChecked();
    btConfig.TickSound = Sound(DynamicLoadObject( eb_TickSound.GetText(), Class'Sound', True ));
    btConfig.LastTickSound = Sound(DynamicLoadObject( eb_LastTickSound.GetText(), Class'Sound', True ));
    btConfig.FailSound = Sound(DynamicLoadObject( eb_FailSound.GetText(), Class'Sound', True ));
    btConfig.NewSound = Sound(DynamicLoadObject( eb_SucceedSound.GetText(), Class'Sound', True ));
    btConfig.RankingTableKey = btConfig.static.ConvertToKey( eb_ToggleKey.GetText() );
    btConfig.bRenderPathTimers = cb_RenderPathTimers.IsChecked();
    btConfig.bRenderPathTimerIndex = cb_RenderPathTimerIndexes.IsChecked();
    btConfig.SaveConfig();

    PlayerOwner().ConsoleCommand("UpdateToggleKey");
}

defaultproperties
{
     Begin Object Class=GUIButton Name=SaveButton
         Caption="Save"
         Hint="Save all settings"
         WinTop=0.800000
         WinLeft=0.825000
         WinWidth=0.130000
         WinHeight=0.050000
         OnClick=BTGUI_Settings.InternalOnClick
         OnKeyEvent=SaveButton.InternalOnKeyEvent
     End Object
     b_Save=GUIButton'BTGUI_Settings.SaveButton'

     Begin Object Class=GUIButton Name=ResetButton
         Caption="Reset"
         Hint="Restore all settings back to their default values"
         WinTop=0.800000
         WinLeft=0.050000
         WinWidth=0.130000
         WinHeight=0.050000
         OnClick=BTGUI_Settings.InternalOnClick
         OnChange=BTGUI_Settings.InternalOnChange
         OnKeyEvent=ResetButton.InternalOnKeyEvent
     End Object
     b_Reset=GUIButton'BTGUI_Settings.ResetButton'

     Begin Object Class=moCheckBox Name=UseAltTimer
         Caption="Draw Alternative Timer"
         OnCreateComponent=UseAltTimer.InternalOnCreateComponent
         Hint="The record timer will be drawn at the bottom center of your screen"
         WinTop=0.100000
         WinLeft=0.050000
         WinWidth=0.420000
         WinHeight=0.048125
         OnChange=BTGUI_Settings.InternalOnChange
     End Object
     cb_UseAltTimer=moCheckBox'BTGUI_Settings.UseAltTimer'

     Begin Object Class=moCheckBox Name=ShowZoneActors
         Caption="Show Zone Actors"
         OnCreateComponent=ShowZoneActors.InternalOnCreateComponent
         Hint="Common invisible actors within your current zone will be drawn in wireframe or as an icon if no mesh is available"
         WinTop=0.172000
         WinLeft=0.050000
         WinWidth=0.420000
         WinHeight=0.048125
         OnChange=BTGUI_Settings.InternalOnChange
     End Object
     cb_ShowZoneActors=moCheckBox'BTGUI_Settings.ShowZoneActors'

     Begin Object Class=moCheckBox Name=FadeTextColors
         Caption="Animate Timer Colors"
         OnCreateComponent=FadeTextColors.InternalOnCreateComponent
         Hint="Timer colors will be animated"
         WinTop=0.244000
         WinLeft=0.050000
         WinWidth=0.420000
         WinHeight=0.048125
         OnChange=BTGUI_Settings.InternalOnChange
     End Object
     cb_FadeTextColors=moCheckBox'BTGUI_Settings.FadeTextColors'

     Begin Object Class=moCheckBox Name=OIF
         Caption="Play Sound"
         OnCreateComponent=OIF.InternalOnCreateComponent
         Hint="Record failure notifications will play a sound"
         WinTop=0.594000
         WinLeft=0.050000
         WinWidth=0.170000
         WinHeight=0.048125
         OnChange=BTGUI_Settings.InternalOnChange
     End Object
     cb_OIF=moCheckBox'BTGUI_Settings.OIF'

     Begin Object Class=moCheckBox Name=OIN
         Caption="Play Sound"
         OnCreateComponent=OIN.InternalOnCreateComponent
         Hint="New record notifications will play a sound"
         WinTop=0.662000
         WinLeft=0.050000
         WinWidth=0.170000
         WinHeight=0.048125
         OnChange=BTGUI_Settings.InternalOnChange
     End Object
     cb_OIN=moCheckBox'BTGUI_Settings.OIN'

     Begin Object Class=moCheckBox Name=PT
         Caption="Relative Timer"
         OnCreateComponent=PT.InternalOnCreateComponent
         Hint="The record timer will start based off of your personal record time"
         WinTop=0.100000
         WinLeft=0.530000
         WinWidth=0.425000
         WinHeight=0.048125
         OnChange=BTGUI_Settings.InternalOnChange
     End Object
     cb_PT=moCheckBox'BTGUI_Settings.PT'

     Begin Object Class=moCheckBox Name=PTS
         Caption="Play Tick Sounds"
         OnCreateComponent=PTS.InternalOnCreateComponent
         Hint="Play a tick sound for every second of the last 10 seconds"
         WinTop=0.532000
         WinLeft=0.530000
         WinWidth=0.425000
         WinHeight=0.048125
         OnChange=BTGUI_Settings.InternalOnChange
     End Object
     cb_PTS=moCheckBox'BTGUI_Settings.PTS'

     Begin Object Class=moCheckBox Name=DFT
         Caption="Render Full Timer"
         OnCreateComponent=DFT.InternalOnCreateComponent
         Hint="The record timer will render all decimals, even if they are null e.g. 00:00:10.41"
         WinTop=0.172000
         WinLeft=0.530000
         WinWidth=0.425000
         WinHeight=0.048125
         OnChange=BTGUI_Settings.InternalOnChange
     End Object
     cb_DFT=moCheckBox'BTGUI_Settings.DFT'

     Begin Object Class=moCheckBox Name=PM
         Caption="Professional Mode"
         OnCreateComponent=PM.InternalOnCreateComponent
         Hint="Hides all players and mute most player caused sounds"
         WinTop=0.388000
         WinLeft=0.530000
         WinWidth=0.425000
         WinHeight=0.048125
         OnChange=BTGUI_Settings.InternalOnChange
     End Object
     cb_PM=moCheckBox'BTGUI_Settings.PM'

     Begin Object Class=moCheckBox Name=ABV
         Caption="Auto BehindView"
         OnCreateComponent=ABV.InternalOnCreateComponent
         Hint="Will automatically switch your camera to "BehindView" on spawn"
         WinTop=0.460000
         WinLeft=0.530000
         WinWidth=0.425000
         WinHeight=0.048125
         OnChange=BTGUI_Settings.InternalOnChange
     End Object
     cb_ABV=moCheckBox'BTGUI_Settings.ABV'

     Begin Object Class=moCheckBox Name=cbRenderPathTimers
         Caption="Draw Path Timers"
         OnCreateComponent=cbRenderPathTimers.InternalOnCreateComponent
         Hint="Path Timers of the #1 Ghost's path will be drawn"
         WinTop=0.312000
         WinLeft=0.050000
         WinWidth=0.420000
         WinHeight=0.048125
         OnChange=BTGUI_Settings.InternalOnChange
     End Object
     cb_RenderPathTimers=moCheckBox'BTGUI_Settings.cbRenderPathTimers'

     Begin Object Class=moCheckBox Name=cbRenderPathTimerIndex
         Caption="Draw Path Timer Index"
         OnCreateComponent=cbRenderPathTimerIndex.InternalOnCreateComponent
         Hint="Path Timers will be drawn with their index number next to its time"
         WinTop=0.384000
         WinLeft=0.050000
         WinWidth=0.420000
         WinHeight=0.048125
         OnChange=BTGUI_Settings.InternalOnChange
     End Object
     cb_RenderPathTimerIndexes=moCheckBox'BTGUI_Settings.cbRenderPathTimerIndex'

     Begin Object Class=GUIEditBox Name=TickSound
         Hint="Path to the sound to play for timer ticks"
         WinTop=0.594000
         WinLeft=0.530000
         WinWidth=0.225000
         WinHeight=0.050000
         bBoundToParent=True
         bScaleToParent=True
         OnActivate=TickSound.InternalActivate
         OnDeActivate=TickSound.InternalDeactivate
         OnChange=BTGUI_Settings.InternalOnChange
         OnKeyType=TickSound.InternalOnKeyType
         OnKeyEvent=TickSound.InternalOnKeyEvent
     End Object
     eb_TickSound=GUIEditBox'BTGUI_Settings.TickSound'

     Begin Object Class=GUIEditBox Name=LastTickSound
         Hint="Path to the final sound to play for timer ticks"
         WinTop=0.656000
         WinLeft=0.530000
         WinWidth=0.225000
         WinHeight=0.050000
         bBoundToParent=True
         bScaleToParent=True
         OnActivate=LastTickSound.InternalActivate
         OnDeActivate=LastTickSound.InternalDeactivate
         OnChange=BTGUI_Settings.InternalOnChange
         OnKeyType=LastTickSound.InternalOnKeyType
         OnKeyEvent=LastTickSound.InternalOnKeyEvent
     End Object
     eb_LastTickSound=GUIEditBox'BTGUI_Settings.LastTickSound'

     Begin Object Class=GUIEditBox Name=FailSound
         Hint="Path to the sound to play on a record failure"
         WinTop=0.594000
         WinLeft=0.250000
         WinWidth=0.220000
         WinHeight=0.050000
         bBoundToParent=True
         bScaleToParent=True
         OnActivate=FailSound.InternalActivate
         OnDeActivate=FailSound.InternalDeactivate
         OnChange=BTGUI_Settings.InternalOnChange
         OnKeyType=FailSound.InternalOnKeyType
         OnKeyEvent=FailSound.InternalOnKeyEvent
     End Object
     eb_FailSound=GUIEditBox'BTGUI_Settings.FailSound'

     Begin Object Class=GUIEditBox Name=SucceedSound
         Hint="Path to the sound to play on a new record"
         WinTop=0.662000
         WinLeft=0.250000
         WinWidth=0.220000
         WinHeight=0.050000
         bBoundToParent=True
         bScaleToParent=True
         OnActivate=SucceedSound.InternalActivate
         OnDeActivate=SucceedSound.InternalDeactivate
         OnChange=BTGUI_Settings.InternalOnChange
         OnKeyType=SucceedSound.InternalOnKeyType
         OnKeyEvent=SucceedSound.InternalOnKeyEvent
     End Object
     eb_SucceedSound=GUIEditBox'BTGUI_Settings.SucceedSound'

     Begin Object Class=GUIEditBox Name=ToggleKey
         Hint="Key to open the leaderboards"
         WinTop=0.316000
         WinLeft=0.530000
         WinWidth=0.425000
         WinHeight=0.050000
         bBoundToParent=True
         bScaleToParent=True
         OnActivate=ToggleKey.InternalActivate
         OnDeActivate=ToggleKey.InternalDeactivate
         OnChange=BTGUI_Settings.InternalOnChange
         OnKeyType=ToggleKey.InternalOnKeyType
         OnKeyEvent=ToggleKey.InternalOnKeyEvent
     End Object
     eb_ToggleKey=GUIEditBox'BTGUI_Settings.ToggleKey'
}
