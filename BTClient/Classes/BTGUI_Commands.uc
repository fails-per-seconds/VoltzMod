class BTGUI_Commands extends BTGUI_TabBase;

var automated GUIButton
    b_ShowMapInfo,
    b_ShowPlayerInfo,
    b_ShowMissingRecords,
    b_ShowBadRecords,
    b_SetClientSpawn,
    b_DeleteClientSpawn,
    b_RecentRecords,
    b_RecentMaps,
    b_RecentHistory,
    b_ToggleRanking,
    b_RevoteMap;

var automated GUIEditBox eb_ShowMapInfo, eb_ShowPlayerInfo;
var automated GUIScrollTextBox eb_Desc;

function InitComponent( GUIController InController, GUIComponent InOwner )
{
    super.InitComponent( InController,InOwner );

    eb_Desc.MyScrollText.SetContent( "You are allowed to say things in the chat as a command by prefixing it with a ! symbol.||Such as:|"
        $ "!Red, !Blue|!CP|!Revote, !Vote, !VoteMap <Filter>|!Join, !Spec|!Wager <Value>, !Title <Title>|"
    );
    eb_Desc.MyScrollBar.AlignThumb();
    eb_Desc.MyScrollBar.UpdateGripPosition( 0 );
}

function bool InternalOnClick( GUIComponent sender )
{
    PlayerOwner().ConsoleCommand( "CloseDialog" );
    if( sender == b_ShowMapInfo )
    {
        PlayerOwner().ConsoleCommand( "ShowMapInfo" @ eb_ShowMapInfo.GetText() );
        return true;
    }
    else if( sender == b_ShowPlayerInfo )
    {
        PlayerOwner().ConsoleCommand( "ShowPlayerInfo" @ eb_ShowPlayerInfo.GetText() );
        return true;
    }
    else if( sender == b_ShowMissingRecords )
    {
        PlayerOwner().ConsoleCommand( "ShowMissingRecords" );
        return true;
    }
    else if( sender == b_ShowBadRecords )
    {
        PlayerOwner().ConsoleCommand( "ShowBadRecords" );
        return true;
    }
    else if( sender == b_SetClientSpawn )
    {
        PlayerOwner().ConsoleCommand( "SetClientSpawn" );
        return true;
    }
    else if( sender == b_DeleteClientSpawn )
    {
        PlayerOwner().ConsoleCommand( "DeleteClientSpawn" );
        return true;
    }
    else if( sender == b_RecentRecords )
    {
        PlayerOwner().ConsoleCommand( "RecentRecords" );
        return true;
    }
    else if( sender == b_RecentHistory )
    {
        PlayerOwner().ConsoleCommand( "RecentHistory" );
        return true;
    }
    else if( sender == b_RecentMaps )
    {
        PlayerOwner().ConsoleCommand( "RecentMaps" );
        return true;
    }
    else if( sender == b_ToggleRanking )
    {
        PlayerOwner().ConsoleCommand( "ToggleRanking" );
        return true;
    }
    else if( sender == b_RevoteMap )
    {
        PlayerOwner().ConsoleCommand( "RevoteMap" );
        return true;
    }
    return false;
}

defaultproperties
{
     Begin Object Class=GUIButton Name=oShowMapInfo
         Caption="Show Map Info"
         Hint="Shows a dialog with info of the inputted map"
         WinTop=0.070000
         WinWidth=0.250000
         WinHeight=0.050000
         OnClick=BTGUI_Commands.InternalOnClick
         OnKeyEvent=oShowMapInfo.InternalOnKeyEvent
     End Object
     b_ShowMapInfo=GUIButton'BTGUI_Commands.oShowMapInfo'

     Begin Object Class=GUIButton Name=oShowPlayerInfo
         Caption="Show Player Info"
         Hint="Shows a dialog with info of the inputted player"
         WinTop=0.010000
         WinWidth=0.250000
         WinHeight=0.050000
         OnClick=BTGUI_Commands.InternalOnClick
         OnKeyEvent=oShowPlayerInfo.InternalOnKeyEvent
     End Object
     b_ShowPlayerInfo=GUIButton'BTGUI_Commands.oShowPlayerInfo'

     Begin Object Class=GUIButton Name=oShowMissingRecords
         Caption="Show Available Records"
         Hint="Shows a dialog with info of what solo records you haven't yet recorded"
         WinTop=0.130000
         WinWidth=0.250000
         WinHeight=0.050000
         OnClick=BTGUI_Commands.InternalOnClick
         OnKeyEvent=oShowMissingRecords.InternalOnKeyEvent
     End Object
     b_ShowMissingRecords=GUIButton'BTGUI_Commands.oShowMissingRecords'

     Begin Object Class=GUIButton Name=oShowBadRecords
         Caption="Show Bad Records"
         Hint="Shows a dialog with info of what solo records you are not in the top 3"
         WinTop=0.130000
         WinLeft=0.260000
         WinWidth=0.250000
         WinHeight=0.050000
         OnClick=BTGUI_Commands.InternalOnClick
         OnKeyEvent=oShowBadRecords.InternalOnKeyEvent
     End Object
     b_ShowBadRecords=GUIButton'BTGUI_Commands.oShowBadRecords'

     Begin Object Class=GUIButton Name=oSetClientSpawn
         Caption="Set Client Spawn"
         Hint="Sets you a new client spawn point at your present position"
         WinTop=0.190000
         WinWidth=0.250000
         WinHeight=0.050000
         OnClick=BTGUI_Commands.InternalOnClick
         OnKeyEvent=oSetClientSpawn.InternalOnKeyEvent
     End Object
     b_SetClientSpawn=GUIButton'BTGUI_Commands.oSetClientSpawn'

     Begin Object Class=GUIButton Name=oDeleteClientSpawn
         Caption="Delete Client Spawn"
         Hint="Deletes your client spawn point"
         WinTop=0.190000
         WinLeft=0.260000
         WinWidth=0.250000
         WinHeight=0.050000
         OnClick=BTGUI_Commands.InternalOnClick
         OnKeyEvent=oDeleteClientSpawn.InternalOnKeyEvent
     End Object
     b_DeleteClientSpawn=GUIButton'BTGUI_Commands.oDeleteClientSpawn'

     Begin Object Class=GUIButton Name=oRecentRecords
         Caption="Recent Records"
         Hint="Show recently set records"
         WinTop=0.870000
         WinWidth=0.250000
         WinHeight=0.050000
         OnClick=BTGUI_Commands.InternalOnClick
         OnKeyEvent=oRecentRecords.InternalOnKeyEvent
     End Object
     b_RecentRecords=GUIButton'BTGUI_Commands.oRecentRecords'

     Begin Object Class=GUIButton Name=oRecentMaps
         Caption="Recent Maps"
         Hint="Show recently new added maps"
         WinTop=0.870000
         WinLeft=0.260000
         WinWidth=0.250000
         WinHeight=0.050000
         OnClick=BTGUI_Commands.InternalOnClick
         OnKeyEvent=oRecentMaps.InternalOnKeyEvent
     End Object
     b_RecentMaps=GUIButton'BTGUI_Commands.oRecentMaps'

     Begin Object Class=GUIButton Name=oRecentHistory
         Caption="Recent History"
         Hint="Show recently history, such as records being deleted"
         WinTop=0.870000
         WinLeft=0.520000
         WinWidth=0.250000
         WinHeight=0.050000
         OnClick=BTGUI_Commands.InternalOnClick
         OnKeyEvent=oRecentHistory.InternalOnKeyEvent
     End Object
     b_RecentHistory=GUIButton'BTGUI_Commands.oRecentHistory'

     Begin Object Class=GUIButton Name=oToggleRanking
         Caption="Show Rankings"
         Hint="Show all time top rankings(F12)"
         WinTop=0.250000
         WinWidth=0.250000
         WinHeight=0.050000
         OnClick=BTGUI_Commands.InternalOnClick
         OnKeyEvent=oToggleRanking.InternalOnKeyEvent
     End Object
     b_ToggleRanking=GUIButton'BTGUI_Commands.oToggleRanking'

     Begin Object Class=GUIButton Name=oRevoteMap
         Caption="Revote Current Map"
         Hint="Revote the currently playing map"
         WinTop=0.310000
         WinWidth=0.510000
         WinHeight=0.050000
         OnClick=BTGUI_Commands.InternalOnClick
         OnKeyEvent=oRevoteMap.InternalOnKeyEvent
     End Object
     b_RevoteMap=GUIButton'BTGUI_Commands.oRevoteMap'

     Begin Object Class=GUIEditBox Name=oMapName
         Hint="Map Name"
         WinTop=0.070000
         WinLeft=0.260000
         WinWidth=0.250000
         WinHeight=0.050000
         bBoundToParent=True
         bScaleToParent=True
         OnActivate=oMapName.InternalActivate
         OnDeActivate=oMapName.InternalDeactivate
         OnKeyType=oMapName.InternalOnKeyType
         OnKeyEvent=oMapName.InternalOnKeyEvent
     End Object
     eb_ShowMapInfo=GUIEditBox'BTGUI_Commands.oMapName'

     Begin Object Class=GUIEditBox Name=oPlayerName
         Hint="Player Name"
         WinTop=0.010000
         WinLeft=0.260000
         WinWidth=0.250000
         WinHeight=0.050000
         bBoundToParent=True
         bScaleToParent=True
         OnActivate=oPlayerName.InternalActivate
         OnDeActivate=oPlayerName.InternalDeactivate
         OnKeyType=oPlayerName.InternalOnKeyType
         OnKeyEvent=oPlayerName.InternalOnKeyEvent
     End Object
     eb_ShowPlayerInfo=GUIEditBox'BTGUI_Commands.oPlayerName'

     Begin Object Class=GUIScrollTextBox Name=oDescription
         bNoTeletype=True
         OnCreateComponent=oDescription.InternalOnCreateComponent
         WinTop=0.010000
         WinLeft=0.520000
         WinWidth=0.480000
         WinHeight=0.850000
         bNeverFocus=True
     End Object
     eb_Desc=GUIScrollTextBox'BTGUI_Commands.oDescription'
}
