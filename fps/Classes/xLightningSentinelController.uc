class xLightningSentinelController extends Controller
	config(fps);

var Controller PlayerSpawner;
var class<xEmitter> HitEmitterClass;

var config float MaxHealthMultiplier;
var config float MinHealthMultiplier;
var config int MaxDamagePerHit;
var config int MinDamagePerHit;
var config float TargetRadius;

var float DamageAdjust;

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
		PlayerReplicationInfo.RemoteRole = ROLE_None;
	}
}

function PostBeginPlay()
{
	SetTimer(1.0, true);
	Super.PostBeginPlay();
}

function Timer()
{
	local Controller C, NextC;
	local int DamageDealt;
	local xEmitter HitEmitter;
	local float damageScale, dist;
	local vector dir;

	if (PlayerSpawner == None || PlayerSpawner.Pawn == None)
		return;

	C = Level.ControllerList;
	while (C != None)
	{
		NextC = C.NextController;
			
		if (C != None && C.Pawn != None && Pawn != None && C.Pawn != Pawn && C.Pawn != PlayerSpawner.Pawn && C.Pawn.Health > 0
		  && VSize(C.Pawn.Location - Pawn.Location) < TargetRadius && FastTrace(C.Pawn.Location, Pawn.Location)
		   && ((TeamGame(Level.Game) != None && !C.SameTeamAs(PlayerSpawner)) || (TeamGame(Level.Game) == None && C.Pawn.Owner != PlayerSpawner)))
		{
			dir = C.Pawn.Location - Pawn.Location;
			dist = FMax(1,VSize(dir));
			damageScale = 1 - FMax(0,dist/TargetRadius);

			DamageDealt = C.Pawn.HealthMax * DamageAdjust * ((damageScale * (MaxHealthMultiplier-MinHealthMultiplier)) + MinHealthMultiplier);
			DamageDealt = max(MinDamagePerHit * DamageAdjust, DamageDealt);
			DamageDealt = min(MaxDamagePerHit * DamageAdjust, DamageDealt);
			C.Pawn.TakeDamage(DamageDealt, Pawn, C.Pawn.Location, vect(0,0,0), class'DamTypeLightningSent');

			if (C != None && C.Pawn != None && Pawn != None)
			{
				HitEmitter = spawn(HitEmitterClass,,, Pawn.Location, rotator(C.Pawn.Location - Pawn.Location));
				if (HitEmitter != None)
					HitEmitter.mSpawnVecA = C.Pawn.Location;
			}

			if (C != None && C.Pawn != None && MonsterController(C) != None && FriendlyMonsterController(C) == None && Pawn != None && C.Enemy != Pawn && FastTrace(Pawn.Location,C.Pawn.Location))
			{
				if (C.Enemy == None || FRand() < 0.15)
					MonsterController(C).ChangeEnemy(Pawn, C.CanSee(Pawn));
			}
		}
		C = NextC;
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
     HitEmitterClass=Class'XEffects.LightningBolt'
     MaxHealthMultiplier=0.100000
     MinHealthMultiplier=0.020000
     MaxDamagePerHit=30
     MinDamagePerHit=3
     TargetRadius=1200.000000
     DamageAdjust=1.000000
}
