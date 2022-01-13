class AwarenessEnemyList extends Actor;

var PlayerController PlayerOwner;

var array<Pawn> Enemies;
var array<Pawn> TeamPawns;

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();

	PlayerOwner = Level.GetLocalPlayerController();
	if (PlayerOwner != None)
		SetTimer(2, true);
	else
		Warn("AwarenessEnemyList spawned with no local PlayerController!");
}

simulated function Timer()
{
	local Pawn P, PlayerDriver;
	local FriendlyMonsterEffect FME;
	local bool GoodMonster;

	Enemies.length = 0;
	TeamPawns.length = 0;

	if (PlayerOwner.Pawn == None || PlayerOwner.Pawn.Health <= 0)
		return;

	if (Vehicle(PlayerOwner.Pawn) != None)
		PlayerDriver = Vehicle(PlayerOwner.Pawn).Driver;
	else
		PlayerDriver = PlayerOwner.Pawn;

	foreach DynamicActors(class'Pawn', P)
	{
		if (P != PlayerOwner.Pawn && P != PlayerDriver && Vehicle(P) == None && xEnergyWall(P) == None && RedeemerWarhead(P) == None)
		{
			if (P.IsA('Monster'))
			{
				GoodMonster = False;
				foreach DynamicActors(class'FriendlyMonsterEffect', FME)
				{
					if (P != FME.Base)
					{
						continue;
					}
					else if (FME.MasterPRI == PlayerOwner.PlayerReplicationInfo)		
					{
						GoodMonster = True;
						break;
					}
					else if (FME.MasterPRI.Team != None && FME.MasterPRI.Team == PlayerOwner.PlayerReplicationInfo.Team)
					{
						GoodMonster = True;
						break;
					}
					else
					{
						break;
					}
				}

				if (GoodMonster)
					TeamPawns[TeamPawns.length] = P;
				else
					Enemies[Enemies.length] = P;
			}
			else
			{
				if (P.GetTeamNum() == PlayerOwner.GetTeamNum() && PlayerOwner.GetTeamNum() != 255)
					TeamPawns[TeamPawns.length] = P;
				else
					Enemies[Enemies.length] = P;
			}
		}
	}
}

defaultproperties
{
     bHidden=True
     RemoteRole=ROLE_None
     bGameRelevant=True
     bBlockZeroExtentTraces=False
     bBlockNonZeroExtentTraces=False
}