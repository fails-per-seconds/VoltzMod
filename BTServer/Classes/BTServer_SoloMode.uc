//=============================================================================
// Copyright 2005-2010 Eliot Van Uytfanghe. All Rights Reserved.
//=============================================================================
class BTServer_SoloMode extends BTServer_ASMode;

var() const bool bAllowWaging;

static function bool DetectMode( MutBestTimes M )
{
    return M.Objectives.Length == 1 || IsSolo( M.CurrentMapName );
}

static function bool IsSolo( string mapName )
{
    return Left( Mid( mapName, 3 ), 4 ) ~= default.ModeName || Left( mapName, 3 ) ~= default.ModePrefix;
}

protected function InitializeMode()
{
    local int i;

    super.InitializeMode();
    bSoloMap = true;
    MRI.bSoloMap = true;

    Tag = 'BT_SOLORECORD';
    for( i = 0; i < Objectives.Length; ++ i )
    {
        // Remove objective sounds, we got our own!
        Objectives[i].Announcer_DisabledObjective = none;
        Objectives[i].Announcer_ObjectiveInfo = none;
        Objectives[i].Announcer_DefendObjective = none;

        if( Objectives[i].IsA('LCAKeyObjective') || Objectives[i].IsA('LCA_KeyObjective') )
        {
            bKeyMap = true;
            MRI.bKeyMap = true;
        }
        else if( Objectives[i].IsA('TriggeredObjective') && !ClientSpawnCanCompleteMap() )
        {
            bAlwaysKillClientSpawnPlayersNearTriggers = true;
        }
    }

    InitializeSoloSupreme();
}

protected function InitializeSoloSupreme()
{
    local int i, mapIndex;
    local BTClient_LevelReplication myLevel;
    local string levelMapName;
    local bool isSupremeMap;

    // Maps with zero(placeholder) objectives or more than one are considered hubs which are maps with multiple levels.
    isSupremeMap = Objectives.Length != 1;
    if( isSupremeMap )
    {
        // We'll acquire them again soon. Doing this let us lose track of levels that have been removed from a map.
        RDat.Rec[UsedSlot].SubLevels.Length = 0;
    }
    for( i = 0; i < Objectives.Length; ++ i )
    {
        myLevel = Spawn( class'BTClient_LevelReplication', Objectives[i] );
        MRI.AddLevelReplication( myLevel );

        levelMapName = myLevel.GetFullName( CurrentMapName );
        mapIndex = RDat.FindRecord( levelMapName );
        if( mapIndex == -1 )
        {
            mapIndex = RDat.CreateRecord( levelMapName, RDat.MakeCompactDate( Level ) );
        }
        if( isSupremeMap )
        {
            if( UsedSlot == -1 )
            {
                Warn("UsedSlot == -1, this should not happen!");
            }
            RDat.Rec[UsedSlot].SubLevels[RDat.Rec[UsedSlot].SubLevels.Length] = mapIndex;
        }
        myLevel.MapIndex = mapIndex;
        if( RDat.Rec[mapIndex].PSRL.Length > 0 )
        {
            myLevel.NumRecords = RDat.Rec[mapIndex].PSRL.Length;
            myLevel.TopTime = GetFixedTime( RDat.Rec[mapIndex].PSRL[0].SRT ); // assumes PSRL is always sorted by lowest time.
            myLevel.TopRanks = GetRecordTopHolders( mapIndex );
        }
    }
    if( !isSupremeMap )
    {
        MRI.MapLevel = MRI.BaseLevel;
    }
    for( myLevel = MRI.BaseLevel; myLevel != none; myLevel = myLevel.NextLevel )
    {
        myLevel.InitializeLevel( MRI );
        if( myLevel.GetObjective() != none )
        {
            myLevel.GetObjective().Event = 'BT_SOLORECORD';
        }
    }
}

function ModePostBeginPlay()
{
    super.ModePostBeginPlay();
    if( CheckPointHandlerClass != none )
    {
        CheckPointHandler = Spawn( CheckPointHandlerClass, Outer );
    }
}

function ModeMatchStarting()
{
    super.ModeMatchStarting();
    if( MRI.MapLevel == none ) // = Map with multiple levels
    {
        Level.Game.GameReplicationInfo.bNoTeamSkins = true;
        Level.Game.GameReplicationInfo.bForceNoPlayerLights = true;
        Level.Game.GameReplicationInfo.bNoTeamChanges = true;
    }
}

function bool ClientExecuted( PlayerController sender, string command, array<string> params )
{
    local bool bmissed;

    switch( command )
    {
        case "resetcp":
            if( bQuickStart )
            {
                break;
            }
            ResetCheckPoint( sender );
            break;

        default:
            bmissed = true;
            break;
    }

    if( !bmissed )
    {
        return true;
    }
    return super.ClientExecuted( sender, command, params );
}

function bool ChatCommandExecuted( PlayerController sender, string command, string value )
{
    switch( command )
    {
        case "wager":
            ActivateWager( sender, value );
            return true;

        case "level":
            return CmdLevel( sender, value );

        case "ghost":
            return CmdGhost( sender, value );
    }
    return super.ChatCommandExecuted( sender, command, value );
}

private function bool CmdLevel( PlayerController sender, string value )
{
    local BTClient_ClientReplication CRI;
    local BTClient_LevelReplication myLevel;

    if( Objectives.Length < 2 )
        return false;

    CRI = GetRep( sender );
    if( value == "" )
    {
        if (CRI.PlayingLevel == none)
        {
            return false;
        }

        myLevel = CRI.PlayingLevel;
        myLevel.PlayerLeaveLevel(CRI);
    }
    else
    {
        myLevel = GetObjectiveLevelByName( value, true );
        if( myLevel == none )
        {
            return false;
        }
        myLevel.PlayerEnterLevel(CRI);
    }
    return true;
}

private function bool CmdGhost( PlayerController sender, string value )
{
    local BTClient_ClientReplication CRI;
    local BTClient_LevelReplication myLevel;
    local string ghostId;
    local int recordIndex;
    local bool isSpectating;
    local BTGhostPlayback playback;

    if( GhostManager == none )
        return false;

    if( RDat.Rec[UsedSlot].TMGhostDisabled )
    {
        SendErrorMessage( sender, "Sorry! Ghosts are disabled for this map!, try again at another time." );
        return true;
    }

    if( value == "" )
    {
        if( GhostManager.KillGhostFor( sender ) )
        {
            SendSucceedMessage( sender, "Your ghost has been deactivated!" );
            return true;
        }
    }

    CRI = GetRep( sender );
    if( CRI.PlayingLevel != none )
        myLevel = CRI.PlayingLevel;
    else if( MRI.MapLevel != none )
        myLevel = MRI.MapLevel;

    if( myLevel == none )
    {
        SendErrorMessage( sender, "Please select a level using \"!level <name>\" and try again." );
        return true;
    }

    if( int(value) <= 0 )
    {
        SendErrorMessage( sender, "Please specify a rank starting at 1, e.g. !ghost 1" );
        return true;
    }

    recordIndex = int(value) - 1;

    if (recordIndex >= RDat.Rec[myLevel.MapIndex].PSRL.Length
        || (RDat.Rec[myLevel.MapIndex].PSRL[recordIndex].Flags & 0x08/*RFLAG_GHOST*/) == 0)
    {
        SendErrorMessage( sender, "Couldn't find a ghost with the rank that you are looking for! Try another rank!" );
        return true;
    }

    ghostId = PDat.Player[RDat.Rec[myLevel.MapIndex].PSRL[recordIndex].PLs-1].PLID;
    GhostManager.KillGhostFor( sender ); // kill any previously owned ghosts.

    playback = GhostManager.SpawnCustomGhostFor( RDat.Rec[myLevel.MapIndex].TMN, ghostId, sender );
    if (playback != none) {
        isSpectating = sender.PlayerReplicationInfo.bIsSpectator || sender.PlayerReplicationInfo.bOnlySpectator;
        if (isSpectating) {
            sender.SetViewTarget(playback.Controller.Pawn);
            sender.ClientSetViewTarget(playback.Controller.Pawn);
            SendSucceedMessage( sender, "You'r now watching" @ playback.GhostName$"!");
        }
        else {
            SendSucceedMessage( sender, "Your ghost is now ready and will activate when you respawn! You can use !ghost at any time to deactivate your ghost." );
        }
    } else {
        SendErrorMessage( sender, "Your ghost couldn't be spawned!" );
    }
    return true;
}

function bool ModeValidatePlayerStart( Controller player, PlayerStart start )
{
    local BTClient_ClientReplication CRI;

    CRI = GetRep( player );
    if( CRI == none || CRI.PlayingLevel == none )
    {
        return super.ModeValidatePlayerStart( player, start );
    }
    return CRI.PlayingLevel.IsValidPlayerStart( player, start );
}

function ModeModifyPlayer( Pawn other, Controller c, BTClient_ClientReplication CRI )
{
    local int i, checkPointIndex;
    local TeamInfo attackingTeam;

    super.ModeModifyPlayer( other, c, CRI );
    // Disable all collision for players that have yet to choose a level.
    // Todo: (optimize)Apply when player changes level.
    if( MRI.MapLevel == none && ASGameInfo(Level.Game) != none )
    {
        if( CRI.PlayingLevel == none )
        {
            other.PlayerReplicationInfo.Team = TeamGame(Level.Game).Teams[1 - ASGameInfo(Level.Game).CurrentAttackingTeam];
        }
        else
        {
            attackingTeam = TeamGame(Level.Game).Teams[ASGameInfo(Level.Game).CurrentAttackingTeam];
            other.PlayerReplicationInfo.Team = attackingTeam;
        }
    }

    /**
     * @Todo    Instead of restart recording, delete the few last saved moves
     * @Todo    Don't let the timer keep counting, instead remove what has counted since the last dead
     */
    if( other.LastStartSpot.IsA( CheckPointNavigationClass.Name )
        && CheckPointHandler.HasSavedCheckPoint( c, checkPointIndex ) )
    {
        CheckPointHandler.ApplyPlayerState( other, CheckPointHandler.SavedCheckPoints[checkPointIndex].SavedStats );
        CRI.ClientSpawnPawn = other; // re-use the ClientSpawn feature for this :), with this the timer won't restart for spectators.
    }
    // Check if a clientspawn is registered, not if we spawned on one, because we don't want to reset the time if a player switches team while having a clientspawn!
    else if( GetClientSpawnIndex( c ) == -1 /**!IsClientSpawnPlayer( other )*/ )
    {
        // Start timer
        CRI.PlayerSpawned();
        if( GhostManager != none && (CRI.PlayingLevel != none || MRI.MapLevel != none) )
        {
            // Restart ghost recording!
            GhostManager.Saver.RecordPlayer( PlayerController(c) );

            // Reset ghost, if wanted
            if( !RDat.Rec[UsedSlot].TMGhostDisabled )
            {
                GhostManager.RestartGhostFor( C );
            }
        }

        // Enable waging for this run.
        if( CRI != none )
        {
            if( CRI.bWantsToWage )
            {
                CRI.BTWage = CRI.AmountToWage;
                SendSucceedMessage( PlayerController(c), "You are now waging " $ CRI.BTWage $ " currency! Everytime you die you will lose the amount you're waging!, or if you beat your personal/top record you will gain triple the amount you waged!" );

                CRI.bWantsToWage = false;
            }
            else if( CRI.AmountToWage == 0 )
            {
                CRI.BTWage = 0;
            }
        }
    }

    if( !bGroupMap )
    {
        // Respawn all my stalkers!
        for( i = 0; i < Racers.Length; ++ i )
        {
            if( Racers[i].Leader == Other.Controller
                && Racers[i].Stalker != none
                && !Racers[i].Stalker.PlayerReplicationInfo.bIsSpectator
                && !Racers[i].Stalker.PlayerReplicationInfo.bOnlySpectator )
            {
                ModeRules.RespawnPlayer( Racers[i].Stalker.Pawn );
            }
        }
    }
}

function ModePlayerKilled( Controller player )
{
    local BTClient_ClientReplication LRI;

    super.ModePlayerKilled( player );

    if( bQuickStart )
    {
        return;
    }

    LRI = GetRep(player);
    if( LRI == none || LRI.BTWage <= 0 )
    {
        return;
    }
    WageFailed( LRI, LRI.BTWage );
}

function WageFailed( BTClient_ClientReplication wager, int wagedPoints )
{
    SendErrorMessage( PlayerController(wager.Owner), "You failed your wage!" );
    PDat.GiveCurrencyPoints( Outer, wager.myPlayerSlot, -wagedPoints, true );
    if( wager.BTPoints < wagedPoints )
    {
        ActivateWager( PlayerController(wager.Owner), 0 );
    }
}

function WageSuccess( BTClient_ClientReplication wager, int wagedPoints )
{
    SendSucceedMessage( PlayerController(wager.Owner), "You succeeded your wage!" );
    PDat.GiveCurrencyPoints( Outer, wager.myPlayerSlot, wagedPoints*3, true );
    wager.BTWage = 0;
    wager.AmountToWage = 0;
    wager.bWantsToWage = false;
}

function ActivateWager( PlayerController sender, coerce int wagerAmount )
{
    local BTClient_ClientReplication LRI;

    if( !bAllowWaging )
    {
        SendErrorMessage( sender, "Waging is currently disabled on this server! " );
        return;
    }

    if( RDat.Rec[UsedSlot].PSRL.Length < 3 && !IsAdmin( sender.PlayerReplicationInfo ) )
    {
        SendErrorMessage( sender, "Waging is disabled on this map until 3 or more records are available!" );
        return;
    }

    LRI = GetRep(sender);
    if( LRI == none )
    {
        Log("LRI none when waging!!!");
        return;
    }

    if( !LRI.bIsPremiumMember && !IsAdmin( sender.PlayerReplicationInfo ) )
    {
        SendErrorMessage( sender, "Waging is only for premium members!" );
        return;
    }

    if( wagerAmount == 0 )
    {
        if( LRI.BTWage > 0 || LRI.AmountToWage > 0 )
        {
            SendSucceedMessage( sender, "Waging disabled, wage will update when you respawn!" );
            LRI.AmountToWage = 0;
            LRI.bWantsToWage = false;
        }
        else
        {
            SendSucceedMessage( sender, "Please specify a wage amount, for example: !wager 100" );
        }
        return;
    }

    wagerAmount = Min( Max( wagerAmount, 0 ), Min( LRI.BTPoints, 1000 ) );
    if( wagerAmount <= 0 )
    {
        SendErrorMessage( sender, "You cannot wage this amount!" );
        return;
    }
    SendSucceedMessage( sender, "Wage amount will become " $ wagerAmount $ " when you respawn!" );

    LRI.AmountToWage = wagerAmount;
    LRI.bWantsToWage = true;
}

function PlayerCompletedMap( PlayerController player, int playerSlot, float playSeconds )
{
    super.PlayerCompletedMap( player, playerSlot, playSeconds );

    if( bGroupMap )
    {
        // Complete a Group map
        ProcessGroupFinishAchievement( playerSlot );
        if( PDat.FindAchievementStatusByID( playerSlot, 'records_5' ) == -1 && CountRecordsNum( groupNum, playerSlot ) >= 4 )
        {
            // Group gamer
            PDatManager.ProgressAchievementByID( playerSlot, 'records_5' );
        }
        return;
    }

    if( IsCompetitiveModeActive() )
    {
        TeamFinishedMap( player, playSeconds );
    }

    if( Left( Level.Title, 13 ) == "TechChallenge" )
    {
        PDatManager.ProgressAchievementByType( playerSlot, 'FinishTech', 1 );
    }
    else if( Left( Level.Title, 9 ) == "EgyptRuin" )
    {
        PDatManager.ProgressAchievementByType( playerSlot, 'FinishRuin', 1 );
    }

    // Complete a Solo map
    PDatManager.ProgressAchievementByType( playerSlot, 'FinishSolo', 1 );

    if( Level.Hour >= 0 && Level.Hour <= 6 )
    {
        PDatManager.ProgressAchievementByID( playerSlot, 'mode_3_night' );
    }

    // Has 50 or more records.
    if( PDat.FindAchievementStatusByID( playerSlot, 'records_3' ) == -1 && CountRecordsNum( soloNum, playerSlot ) >= 50 )
    {
        // Solo gamer
        PDatManager.ProgressAchievementByID( playerSlot, 'records_3' );
    }
}

defaultproperties
{
     MinRecordTime=60.000000
     MaxRecordTime=300.000000
     ModeName="Solo"
     ModePrefix="STR"
     ExperienceBonus=5
     ConfigClass=Class'BTServer_SoloModeConfig'
}
