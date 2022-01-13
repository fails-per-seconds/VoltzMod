class BTLevelUnlockedMessage extends CriticalEventPlus;

var() const string MessageString;

static function string GetString( optional int switch,
    optional PlayerReplicationInfo MessageReceiver, optional PlayerReplicationInfo MessageInstigator,
    optional Object unlockedLevel )
{
    local string s;

	s = Repl( default.MessageString, "%LEVEL%", BTClient_LevelReplication(unlockedLevel).GetLevelName() );
    if( MessageReceiver.Level.GetLocalPlayerController().PlayerReplicationInfo == MessageReceiver )
        return Repl( s, "%PLAYER%", "You have" );
    return Repl( s, "%PLAYER%", " has" @ class'BTClient_TrialScoreBoard'.static.GetCName(MessageInstigator) );
}

static simulated function ClientReceive(
    PlayerController P,
    optional int switch,
    optional PlayerReplicationInfo MessageReceiver,
    optional PlayerReplicationInfo MessageInstigator,
    optional Object unlockedLevel
    )
{
    super.ClientReceive( P, switch, MessageReceiver, MessageInstigator, unlockedLevel );

    P.ClientPlaySound( Sound'GameSounds.Fanfares.UT2K3Fanfare04', true, 2.0, SLOT_Talk );
}

defaultproperties
{
     MessageString="%PLAYER% unlocked %LEVEL%!"
     bIsUnique=False
     Lifetime=8
     DrawColor=(B=0,G=255,R=255)
     StackMode=SM_Down
     PosY=0.342000
     FontSize=-1
}
