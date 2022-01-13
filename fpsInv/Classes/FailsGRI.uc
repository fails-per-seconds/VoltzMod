class FailsGRI extends InvasionGameReplicationInfo;

var int BossTimeLimit;
var int KillZoneLimit;
var int NumMons, NumBoss;
var int MonsterPreloads;

replication
{
	reliable if (Role == ROLE_Authority)
		BossTimeLimit, KillZoneLimit, NumMons, NumBoss;
	reliable if (bNetInitial && (Role == ROLE_Authority))
		MonsterPreloads;
}

defaultproperties
{
}