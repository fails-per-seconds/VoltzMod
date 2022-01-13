class BTGUI_PlayerRankingsReplicationInfo extends BTGUI_ScoreboardReplicationInfo;

struct sPlayerRank
{
	// sPlayerItem; extending sPlayerItem causes crashes on runtime :(
    var int PlayerId;
    var string CountryCode;
    var transient Texture CountryFlag;
    var string Name;
    var float Points;
	var float PointsChange;

    var int AP;
    var int Hijacks; // Masked: Records/Stars
};

var() array<sPlayerRank> PlayerRanks;

var editconst int CurrentPageIndex;
var() const byte RanksId;

replication
{
	reliable if( Role == ROLE_Authority )
		ClientCleanPlayerRanks,
		ClientDonePlayerRanks,
		ClientAddPlayerRank,
		ClientUpdatePlayerRank;
}

simulated event PostNetBeginPlay()
{
	if( CRI != none && (bNetOwner || Role == ROLE_Authority) )
	{
		CRI.Rankings[RanksId] = self;
	}
	super.PostNetBeginPlay();
}

// UI hooks
delegate OnPlayerRankReceived( int index, BTGUI_PlayerRankingsReplicationInfo source );
delegate OnPlayerRankUpdated( int index, BTGUI_PlayerRankingsReplicationInfo source );
delegate OnPlayerRanksDone( BTGUI_PlayerRankingsReplicationInfo source, bool bAll );

simulated function QueryPlayerRanks( int pageIndex )
{
	CRI.ServerRequestPlayerRanks( pageIndex, RanksId );
}

simulated function QueryNextPlayerRanks()
{
	QueryPlayerRanks( ++ CurrentPageIndex );
}

simulated function ClientCleanPlayerRanks()
{
    PlayerRanks.Length = 0;
}

simulated function ClientDonePlayerRanks( optional bool bAll )
{
	OnPlayerRanksDone( self, bAll );
}

simulated function ClientAddPlayerRank( sPlayerRank playerRank )
{
    PlayerRanks[PlayerRanks.Length] = playerRank;
    OnPlayerRankReceived( PlayerRanks.Length - 1, self );
}

simulated function ClientUpdatePlayerRank( sPlayerRank playerRank, byte index )
{
    PlayerRanks[index] = playerRank;
    OnPlayerRankUpdated( index, self );
}

defaultproperties
{
     CurrentPageIndex=-1
}
