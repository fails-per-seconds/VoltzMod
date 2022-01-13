class xLinkSentinelController extends Controller
	config(fps);

var Controller PlayerSpawner;
var RPGStatsInv StatsInv;
var MutFPS RPGMut;

var config float TimeBetweenShots;
var config float LinkRadius;
var config float VehicleHealPerShot;
var class<xEmitter> TurretLinkEmitterClass;
var class<xEmitter> VehicleLinkEmitterClass;

simulated event PostBeginPlay()
{
	local Mutator m;

	super.PostBeginPlay();

	if (Level.Game != None)
		for (m = Level.Game.BaseMutator; m != None; m = m.NextMutator)
			if (MutFPS(m) != None)
			{
				RPGMut = MutFPS(m);
				break;
			}
}

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
		StatsInv = RPGStatsInv(PlayerSpawner.Pawn.FindInventoryType(class'RPGStatsInv'));
	}
	SetTimer(TimeBetweenShots, true);
}

function Timer()
{
	local Pawn LoopP;
	local Controller C;
	local xEmitter HitEmitter;

	if (Pawn == None || PlayerSpawner == None)
	    return;

	foreach DynamicActors(class'Pawn', LoopP)
	{
		if (LoopP != None && LoopP.Health > 0 && Pawn != None && VSize(LoopP.Location - Pawn.Location) < LinkRadius && FastTrace(LoopP.Location, Pawn.Location) && LoopP != Pawn)
		{
			C = LoopP.Controller;
			if (C == None || C.SameTeamAs(self))
			{
				if (Vehicle(LoopP) != None || xEnergyWall(LoopP) != None)
				{
					if (xMinigunTurret(LoopP) != None || xBallTurret(LoopP) != None || xEnergyTurret(LoopP) != None || xIonCannon(LoopP) != None)
					{
						LoopP.HealDamage(VehicleHealPerShot, self, class'DamTypeLinkShaft');
						HitEmitter = spawn(TurretLinkEmitterClass,,, Pawn.Location, rotator(LoopP.Location - Pawn.Location));
						if (HitEmitter != None)
							HitEmitter.mSpawnVecA = LoopP.Location;
					}
					else if (LoopP.Health < LoopP.HealthMax)
					{
						LoopP.GiveHealth(VehicleHealPerShot, LoopP.HealthMax);
						HitEmitter = spawn(VehicleLinkEmitterClass,,, Pawn.Location, rotator(LoopP.Location - Pawn.Location));
						if (HitEmitter != None)
							HitEmitter.mSpawnVecA = LoopP.Location;
					}
				}
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
     TimeBetweenShots=0.250000
     LinkRadius=700.000000
     VehicleHealPerShot=20.000000
     TurretLinkEmitterClass=Class'fps.xLinkSentinelBeamEffect'
     VehicleLinkEmitterClass=Class'fps.BronzeBoltEmitter'
}
