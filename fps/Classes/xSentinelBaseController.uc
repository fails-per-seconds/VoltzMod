class xSentinelBaseController extends TurretController;

var Controller PlayerSpawner;
var float TimeSinceCheck;

var config int AttractRange;
var config int TargetRange;

function SetPlayerSpawner(Controller PlayerC)
{
	PlayerSpawner = PlayerC;
	if (PlayerSpawner.PlayerReplicationInfo != None && PlayerSpawner.PlayerReplicationInfo.Team != None)
	{
		if (PlayerReplicationInfo == None)
			PlayerReplicationInfo = spawn(class'PlayerReplicationInfo', self);
		PlayerReplicationInfo.PlayerName = PlayerSpawner.PlayerReplicationInfo.PlayerName$"'s Sentinel";
		PlayerReplicationInfo.bIsSpectator = true;
		PlayerReplicationInfo.bBot = true;
		PlayerReplicationInfo.Team = PlayerSpawner.PlayerReplicationInfo.Team;
	}
}

function bool IsTargetRelevant(Pawn Target)
{
	if ((Target != None) && (Target.Controller != None) && (Target.Health > 0) && (VSize(Target.Location-Pawn.Location) < Pawn.SightRadius*1.25) 
	     && (((TeamGame(Level.Game) != None) && !SameTeamAs(Target.Controller)) || ((TeamGame(Level.Game) == None) && (Target.Owner != PlayerSpawner))))
		return true;

	return false;
}

function Tick(float DeltaTime)
{
	local Controller C, NextC;

	super.Tick(DeltaTime);

	TimeSinceCheck+=DeltaTime;
	
	if (PlayerSpawner == None || PlayerSpawner.Pawn == None)
		return;

	if (TimeSinceCheck>1.0)
	{
		TimeSinceCheck-=1.0;
		C = Level.ControllerList;
		while (C != None)
		{
			NextC = C.NextController;

			if (C != None && C.Pawn != None && Pawn != None && C.Pawn != PlayerSpawner.Pawn && C.Pawn != Pawn && C.Pawn.Health > 0
		 	   && VSize(C.Pawn.Location - Pawn.Location) < TargetRange && FastTrace(C.Pawn.Location, Pawn.Location) 
		   	     && ((TeamGame(Level.Game) != None && !C.SameTeamAs(PlayerSpawner)) || (TeamGame(Level.Game) == None && C.Pawn.Owner != PlayerSpawner)))
			{
				SeePlayer(C.Pawn);

				if (C != None && MonsterController(C) != None && (C.Enemy == PlayerSpawner.Pawn || C.Enemy == None) && FRand() < 0.3 && VSize(C.Pawn.Location - Pawn.Location) < AttractRange)
					MonsterController(C).ChangeEnemy(Pawn, C.CanSee(Pawn));
			}
			C = NextC;
		}
	}
}

state Engaged
{
	function BeginState()
	{
		Focus = Enemy.GetAimTarget();
		Target = Enemy;
		bFire = 1;
		if (Pawn.Weapon != None)	
			Pawn.Weapon.BotFire(false);
	}
}

function Destroyed()
{
	if (PlayerReplicationInfo != None)
		PlayerReplicationInfo.Destroy();

	Super.Destroyed();
}

defaultproperties
{
     AttractRange=700
     TargetRange=1500
}
