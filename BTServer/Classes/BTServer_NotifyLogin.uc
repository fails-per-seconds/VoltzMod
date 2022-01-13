//=============================================================================
// Copyright 2005-2010 Eliot Van Uytfanghe. All Rights Reserved.
//=============================================================================
class BTServer_NotifyLogin extends Info;

var private int Timers;
var PlayerController Player;

event PreBeginPlay()
{
    SetTimer( 0.2, false );
}

event PostBeginPlay();

event Timer()
{
    local string playerHash;

    if( Player != none )
    {
        playerHash = Player.GetPlayerIDHash();
        if( playerHash == "" && Timers < 30 ) // if more than 15 trys then drop this replication, Player probably lost connection or is really slow
        {
            ++ Timers;
            // Slow delay because we don't want to replicate CustomReplicationInfo too late i.e. after bNetInitial
            SetTimer( 0.1, false );
            return;
        }
        MutBestTimes(Owner).NotifyPostLogin( Player, playerHash );
    }
    Destroy();
    return;
}

defaultproperties
{
}
