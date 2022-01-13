class AutoGunController extends SentinelController;

var Controller PlayerSpawner;
var float TimeSinceCheck;

var config int AttractRange;
var config int TargetRange;

var float DamageAdjust;
var float CollisionAdjust;
var Pawn CollisionPawn;
var() sound PickupSound;

function SetPlayerSpawner(Controller PlayerC)
{
	PlayerSpawner = PlayerC;
	if (PlayerSpawner.PlayerReplicationInfo != None && (PlayerSpawner.PlayerReplicationInfo.Team != None || TeamGame(Level.Game) == None))
	{
		if (PlayerReplicationInfo == None)
			PlayerReplicationInfo = spawn(class'PlayerReplicationInfo', self);
		PlayerReplicationInfo.PlayerName = PlayerSpawner.PlayerReplicationInfo.PlayerName$"'s AutoGun";
		PlayerReplicationInfo.bIsSpectator = true;
		PlayerReplicationInfo.bBot = false;
		PlayerReplicationInfo.Team = PlayerSpawner.PlayerReplicationInfo.Team;
	}
}

function bool IsTargetRelevant(Pawn Target)
{
	if ( (Target != None) && (Target.Controller != None) 
		&& (Target.Health > 0) && (VSize(Target.Location-Pawn.Location) < Pawn.SightRadius*1.25) 
		&& (((TeamGame(Level.Game) != None) && !SameTeamAs(Target.Controller))
		|| ((TeamGame(Level.Game) == None) && (Target.Owner != PlayerSpawner))))
		return true;

	return false;
}

function Tick(float DeltaTime)
{
	local Pawn PawnOwner;
	local vector FaceDir;
	local vector StartTrace;
	local vector EndLocation;
	local vector HitLocation;
	local vector HitNormal;
	local Pawn HitPawn;
	local Actor AHit;

	super.Tick(DeltaTime);

	TimeSinceCheck+=DeltaTime;

	if (PlayerSpawner == None || PlayerSpawner.Pawn == None)
		return;
	PawnOwner = PlayerSpawner.Pawn;
	if (PawnOwner != CollisionPawn)
	{
		CollisionPawn = PawnOwner;
		CollisionAdjust = default.CollisionAdjust;
	}
	
	if (TimeSinceCheck > 0.2)
	{
		TimeSinceCheck = fmin(0.1,TimeSinceCheck - 0.2);

		if (Enemy != None && Enemy.Health > 0 && VSize(Enemy.Location - Pawn.Location) < TargetRange && FastTrace(Enemy.Location, Pawn.Location))
			return;

		FaceDir = Vector(PlayerSpawner.GetViewRotation());
		StartTrace = PawnOwner.Location + PawnOwner.EyePosition() + (FaceDir * (CollisionAdjust * PawnOwner.CollisionRadius));
		EndLocation = StartTrace + (FaceDir * TargetRange);

	   	AHit = Trace(HitLocation, HitNormal, EndLocation, StartTrace, true);
		if ((AHit == None) || (Pawn(AHit) == None) || (Pawn(AHit).Controller == None))
			return;
		HitPawn = Pawn(AHit);
		if (HitPawn == PawnOwner)
		{
			CollisionAdjust += 0.2;
			Log("********AGC Collision radius increased to:" $ CollisionAdjust @ "for pawn:" $ CollisionPawn);
		}
		else if (HitPawn.Health > 0)
		{
			 if ((TeamGame(Level.Game) != None && !HitPawn.Controller.SameTeamAs(PlayerSpawner)) || (TeamGame(Level.Game) == None && HitPawn.Owner != PlayerSpawner))
			{
				SeePlayer(HitPawn);
				PlaySound(PickupSound,SLOT_Interact);

				if ( HitPawn.Controller != None && MonsterController(HitPawn.Controller) != None && (HitPawn.Controller.Enemy == PlayerSpawner.Pawn || HitPawn.Controller.Enemy == None)
				    && FRand() < 0.2 && VSize(HitPawn.Location - Pawn.Location) < AttractRange)
					MonsterController(HitPawn.Controller).ChangeEnemy(Pawn, HitPawn.Controller.CanSee(Pawn));
			}
		}
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
     AttractRange=1000
     TargetRange=15000
     DamageAdjust=1.000000
     CollisionAdjust=1.400000
     PickupSound=Sound'PickupSounds.AdrenelinPickup'
}
