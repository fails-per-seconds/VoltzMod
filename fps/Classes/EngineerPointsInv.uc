class EngineerPointsInv extends Inventory
	config(fps);

var array<Pawn> SummonedSentinels;
var array<int> SummonedSentinelPoints;

var array<Pawn> SummonedTurrets;
var array<int> SummonedTurretPoints;

var array<Pawn> SummonedVehicles;
var array<int> SummonedVehiclePoints;

var int UsedEngineerPoints, TotalEngineerPoints;

struct ItemAvailability
{
	Var int Number;
	var int Level;
};
var config Array<ItemAvailability> SentinelAvailability;
var config Array<ItemAvailability> VehicleAvailability;
var config Array<ItemAvailability> TurretAvailability;

var localized string NotEnoughPointsMessage;
var localized string UnableToSpawnMessage;
var localized string TooManyToSpawnMessage;
var localized string NotAtLevel;
var localized string TooManyExtra;

var int PlayerLevel;
var float SentinelDamageAdjust;
var float FastBuildPercent;

//client side only
var PlayerController PC;
var Player Player;
var int TimerCount;
var float RecoveryTime;

replication
{
	reliable if (bNetOwner && bNetDirty && Role == ROLE_Authority)
		UsedEngineerPoints, TotalEngineerPoints, PlayerLevel;
	reliable if (Role == ROLE_Authority)
		SetClientRecoveryTime;
	reliable if (Role < ROLE_Authority)
		LockCommand, UnlockCommand;
}

function PostBeginPlay()
{
	if (Level.NetMode == NM_DedicatedServer || Level.NetMode == NM_ListenServer || Level.NetMode == NM_Standalone)
		SetTimer(5, true);
	Super.PostBeginPlay();

	if (Level.Game != None && !Level.Game.bAllowVehicles)
		Level.Game.bAllowVehicles = true;
}

simulated function PostNetBeginPlay()
{
	if (Level.NetMode != NM_DedicatedServer)
		Enable('Tick');

	Super.PostNetBeginPlay();
}

function SetRecoveryTime(int RecoveryPeriod)
{
	RecoveryTime = Level.TimeSeconds + (RecoveryPeriod*FastBuildPercent);
	SetClientRecoveryTime(RecoveryPeriod*FastBuildPercent);
}

simulated function SetClientRecoveryTime(int RecoveryPeriod)
{
	if (Level.NetMode != NM_DedicatedServer)
		RecoveryTime = Level.TimeSeconds + RecoveryPeriod;
}

simulated function int GetRecoveryTime()
{
	 return int(RecoveryTime - Level.TimeSeconds);
}

function Vector GetSpawnHeight(Vector BeaconLocation)
{
	local vector DownEndLocation;
	local vector HitLocation;
	local vector HitNormal;
	local Actor AHit;

	DownEndLocation = BeaconLocation + vect(0,0,-300);

    	AHit = Trace(HitLocation, HitNormal, DownEndLocation, BeaconLocation, true);
	if (AHit == None || !AHit.bWorldGeometry)
		return vect(0,0,0);
	else 
		return HitLocation;
}

function Vector FindCeiling(Vector BeaconLocation)
{
	local vector UpEndLocation;
	local vector HitLocation;
	local vector HitNormal;
	local Actor AHit;

	UpEndLocation = BeaconLocation + vect(0,0,300);

    	AHit = Trace(HitLocation, HitNormal, UpEndLocation, BeaconLocation, true);
	if (AHit == None || !AHit.bWorldGeometry)
		return vect(0,0,0);
	else 
		return HitLocation;
}

simulated function bool AllowedAnotherSentinel()
{
	local int i;

	for(i = 0; i < SentinelAvailability.length; i++)
		if (PlayerLevel >= SentinelAvailability[i].Level && SummonedSentinels.length < SentinelAvailability[i].Number)
			return true;
	return false;
}

simulated function bool AllowedAnotherVehicle()
{
	local int i;

	for(i = 0; i < VehicleAvailability.length; i++)
		if (PlayerLevel >= VehicleAvailability[i].Level && SummonedVehicles.length < VehicleAvailability[i].Number)
			return true;
	return false;
}

simulated function bool AllowedAnotherTurret()
{
	local int i;

	for(i = 0; i < TurretAvailability.length; i++)
		if (PlayerLevel >= TurretAvailability[i].Level && SummonedTurrets.length < TurretAvailability[i].Number)
			return true;
	return false;
}

function ASTurret SummonBaseSentinel(class<Pawn> ChosenSentinel, int SentinelPoints, Pawn P, Vector SpawnLocation)
{
	local rotator SpawnRotation;

	SpawnRotation = getSpawnRotator(SpawnLocation);

	return SummonRotatedSentinel(ChosenSentinel, SentinelPoints, P, SpawnLocation, SpawnRotation);
}

function ASTurret SummonRotatedSentinel(class<Pawn> ChosenSentinel, int SentinelPoints, Pawn P, Vector SpawnLocation, rotator SpawnRotation)
{
	local ASTurret S;

	if (TotalEngineerPoints - UsedEngineerPoints < SentinelPoints)
	{
		P.ReceiveLocalizedMessage(MessageClass, 2, None, None, Class);
		return None;
	}

	if (!AllowedAnotherSentinel())
	{
		if (SummonedSentinels.length == 0)
			P.ReceiveLocalizedMessage(MessageClass, 5, None, None, Class);
		else
			P.ReceiveLocalizedMessage(MessageClass, 4, None, None, Class);
		return None;
	}

	S = ASTurret(spawn(ChosenSentinel,,, SpawnLocation, SpawnRotation));
	if (S == None)
	{
		P.ReceiveLocalizedMessage(MessageClass, 3, None, None, Class);
		return None;
	}

	S.SetTeamNum(P.GetTeamNum());
	if (S.Controller != None)
		S.Controller.Destroy();
	S.bAutoTurret = true;
	S.bNonHumanControl = true;

	UsedEngineerPoints += SentinelPoints;
	SummonedSentinels[SummonedSentinels.length] = S;
	SummonedSentinelPoints[SummonedSentinelPoints.length] = SentinelPoints;

	return S;
}

function xEnergyWall SummonEnergyWall(class<xEnergyWall> ChosenEWall, int SentinelPoints, Pawn P, vector SpawnLocation, vector P1Loc, vector P2Loc)
{
	local xEnergyWall E;
	local rotator SpawnRotation;
	local xEnergyWallPost Post1,Post2;

	if (TotalEngineerPoints - UsedEngineerPoints < SentinelPoints)
	{
		P.ReceiveLocalizedMessage(MessageClass, 2, None, None, Class);
		return None;
	}

	if (!AllowedAnotherSentinel())
	{
		if (SummonedSentinels.length == 0)
			P.ReceiveLocalizedMessage(MessageClass, 5, None, None, Class);
		else
			P.ReceiveLocalizedMessage(MessageClass, 4, None, None, Class);
		return None;
	}

	Post1 = spawn(ChosenEWall.default.DefaultPost,P,, P1Loc, );
	if (Post1 == None)
	{
		P1Loc = P1Loc + (10 * Normal(P2Loc - P1Loc));
		Post1 = spawn(ChosenEWall.default.DefaultPost,P,, P1Loc, );
		if (Post1 == None)
		{
			P.ReceiveLocalizedMessage(MessageClass, 3, None, None, Class);
			return None;
		}
	}
	Post2 = spawn(ChosenEWall.default.DefaultPost,P,, P2Loc, );
	if (Post2 == None)
	{
		P2Loc = P2Loc + (10 * Normal(P1Loc - P2Loc));
		Post2 = spawn(ChosenEWall.default.DefaultPost,P,, P2Loc, );
		if (Post2 == None)
		{
			Post1.Destroy();
			P.ReceiveLocalizedMessage(MessageClass, 3, None, None, Class);
			return None;
		}
	}

	SpawnRotation = getSpawnRotator(SpawnLocation);
	SpawnLocation = (P1Loc+P2Loc)/2;
	SpawnLocation.z -= 22;

	E = spawn(ChosenEWall,P,,SpawnLocation,SpawnRotation);
	if (E == None)
	{	
		Post1.Destroy();
		Post2.Destroy();
		P.ReceiveLocalizedMessage(MessageClass, 3, None, None, Class);
		return None;
	}

	E.P1Loc = P1Loc;
	E.P2Loc = P2Loc;
	E.SetTeamNum(P.GetTeamNum());
	if (E.Controller != None)
		E.Controller.Destroy();

	UsedEngineerPoints += SentinelPoints;
	SummonedSentinels[SummonedSentinels.length] = E;
	SummonedSentinelPoints[SummonedSentinelPoints.length] = SentinelPoints;

	return E;
}

function Vehicle SummonTurret(class<Pawn> ChosenTurret, int TurretPoints, Pawn P, Vector SpawnLocation)
{
	local rotator SpawnRotation;

	SpawnRotation = getSpawnRotator(SpawnLocation);
	
	return SummonRotatedTurret(ChosenTurret, TurretPoints, P, SpawnLocation, SpawnRotation);

}

function Vehicle SummonRotatedTurret(class<Pawn> ChosenTurret, int TurretPoints, Pawn P, Vector SpawnLocation, rotator SpawnRotation)
{
	local Vehicle T;

	if (TotalEngineerPoints - UsedEngineerPoints < TurretPoints)
	{
		P.ReceiveLocalizedMessage(MessageClass, 2, None, None, Class);
		return None;
	}

	if (!AllowedAnotherTurret())
	{
		if (SummonedTurrets.length == 0)
			P.ReceiveLocalizedMessage(MessageClass, 5, None, None, Class);
		else
			P.ReceiveLocalizedMessage(MessageClass, 4, None, None, Class);
		return None;
	}

	T = Vehicle(spawn(ChosenTurret,,, SpawnLocation, SpawnRotation));
	if (T == None)
	{
		P.ReceiveLocalizedMessage(MessageClass, 3, None, None, Class);
		return None;
	}

	T.SetTeamNum(P.GetTeamNum());
	if (T.Controller != None)
		T.Controller.Destroy();

	UsedEngineerPoints += TurretPoints;
	SummonedTurrets[SummonedTurrets.length] = T;
	SummonedTurretPoints[SummonedTurretPoints.length] = TurretPoints;

	return T;
}

function Vehicle SummonVehicle(class<Pawn> ChosenVehicle, int VehiclePoints, Pawn P, Vector SpawnLocation)
{
	local Vehicle V;
	local rotator SpawnRotation;

	if (TotalEngineerPoints - UsedEngineerPoints < VehiclePoints)
	{
		P.ReceiveLocalizedMessage(MessageClass, 2, None, None, Class);
		return None;
	}

	if (!AllowedAnotherVehicle())
	{
		if (SummonedVehicles.length == 0)
			P.ReceiveLocalizedMessage(MessageClass, 5, None, None, Class);
		else
			P.ReceiveLocalizedMessage(MessageClass, 4, None, None, Class);
		return None;
	}

	SpawnRotation = getSpawnRotator(SpawnLocation);

	V = Vehicle(spawn(ChosenVehicle,,, SpawnLocation, SpawnRotation));
	if (V == None)
	{
		P.ReceiveLocalizedMessage(MessageClass, 3, None, None, Class);
		return None;
	}

	V.SetTeamNum(P.GetTeamNum());

	if (V.Controller != None)
		V.Controller.Destroy();

	UsedEngineerPoints += VehiclePoints;
	SummonedVehicles[SummonedVehicles.length] = V;
	SummonedVehiclePoints[SummonedVehiclePoints.length] = VehiclePoints;

	return V;
}

function Timer()
{
	local int i;
	local RPGStatsInv StatsInv;

	for(i = 0; i < SummonedSentinels.length; i++)
	{
		if (SummonedSentinels[i] == None || SummonedSentinels[i].health <= 0)
		{
			UsedEngineerPoints -= SummonedSentinelPoints[i];
			if (UsedEngineerPoints < 0)
			{
				Warn("Sentinel Points less than zero!");
				UsedEngineerPoints = 0;
			}
			SummonedSentinels.remove(i, 1);
			SummonedSentinelPoints.remove(i, 1);
			i--;
		}
	}
	for(i = 0; i < SummonedTurrets.length; i++)
	{
		if (SummonedTurrets[i] == None || SummonedTurrets[i].health <= 0)
		{
			UsedEngineerPoints -= SummonedTurretPoints[i];
			if (UsedEngineerPoints < 0)
			{
				Warn("Turret Points less than zero!");
				UsedEngineerPoints = 0;
			}
			SummonedTurrets.remove(i, 1);
			SummonedTurretPoints.remove(i, 1);
			i--;
		}
	}
	for(i = 0; i < SummonedVehicles.length; i++)
	{
		if (SummonedVehicles[i] == None || SummonedVehicles[i].health <= 0)
		{
			UsedEngineerPoints -= SummonedVehiclePoints[i];
			if (UsedEngineerPoints < 0)
			{
				Warn("Vehicle Points less than zero!");
				UsedEngineerPoints = 0;
			}
			SummonedVehicles.remove(i, 1);
			SummonedVehiclePoints.remove(i, 1);
			i--;
		}
	}

	if (Role == ROLE_Authority && Instigator != None)
	{
		StatsInv = RPGStatsInv(Instigator.FindInventoryType(class'RPGStatsInv'));
		if (StatsInv != None && StatsInv.Data.Level > PlayerLevel)
			PlayerLevel = StatsInv.Data.Level;
	}
}

function rotator getSpawnRotator(Vector SpawnLocation)
{
	local rotator SpawnRotation;

	SpawnRotation.Yaw = rotator(SpawnLocation - Instigator.Location).Yaw;
	return SpawnRotation;
}

static function LockVehicle(Pawn P)
{
	local EngineerPointsInv EPI;
	local Pawn pd;
	local Inventory Inv;
	local int i;

	if (P == None)
		return;

	if (Vehicle(P) != None)
		pd = Vehicle(P).Driver;
	else
		pd = P;

	i = 0;
	for(Inv = pd.Inventory; Inv != None && i < 500; Inv = Inv.Inventory)
	{
		if (ClassIsChildOf(Inv.Class, class'EngineerPointsInv'))
		{
			EPI = EngineerPointsInv(Inv);
			i = 500;
		}
		i++;
	}
	if (EPI == None)
		EPI = EngineerPointsInv(pd.FindInventoryType(class'EngineerPointsInv'));
	if (EPI != None)
		EPI.LockCommand();
}

static function UnlockVehicle(Pawn P)
{
	local EngineerPointsInv EPI;
	local Pawn pd;
	local Inventory Inv;
	local int i;

	if (P == None)
		return;

	if (Vehicle(P) != None)
		pd = Vehicle(P).Driver;
	else
		pd = P;

	i = 0;
	for(Inv = pd.Inventory; Inv != None && i < 500; Inv = Inv.Inventory)
	{
		if (ClassIsChildOf(Inv.Class, class'EngineerPointsInv'))
		{
			EPI = EngineerPointsInv(Inv);
			i = 500;
		}
		i++;
	}
	if (EPI == None)
		EPI = EngineerPointsInv(pd.FindInventoryType(class'EngineerPointsInv'));
	if (EPI != None)
		EPI.UnlockCommand();
}

function UnlockThisVehicle(vehicle v)
{
	if (xMinigunTurret(v) != None)
		xMinigunTurret(v).EngineerUnlock();
	else if (xLinkTurret(v) != None)
		xLinkTurret(v).EngineerUnlock();
	else if (xBallTurret(v) != None)
		xBallTurret(v).EngineerUnlock();
	else if (xEnergyTurret(v) != None)
		xEnergyTurret(v).EngineerUnlock();
	else if (xIonCannon(v) != None)
		xIonCannon(v).EngineerUnlock();
	else if (xGoliath(v) != None)
		xGoliath(v).EngineerUnlock();
	else if (xHellBender(v) != None)
		xHellBender(v).EngineerUnlock();
	else if (xScorpion(v) != None)
		xScorpion(v).EngineerUnlock();
	else if (xPaladin(v) != None)
		xPaladin(v).EngineerUnlock();
	else if (xManta(v) != None)
		xManta(v).EngineerUnlock();
	else if (xIonTank(v) != None)
		xIonTank(v).EngineerUnlock();
	else if (xTC(v) != None)
		xTC(v).EngineerUnlock();
}

function LockThisVehicle(vehicle v)
{
	local vehicle loopv;
	local int i;

	for(i = 0; i < SummonedTurrets.length; i++)
	{
		loopv = Vehicle(SummonedTurrets[i]);
		if (loopv != None && loopv.Health > 0 && loopv != v)
			UnlockThisVehicle(loopv);
	}
	for(i = 0; i < SummonedVehicles.length; i++)
	{
		loopv = Vehicle(SummonedVehicles[i]);
		if (loopv != None && loopv.Health > 0 && loopv != v)
			UnlockThisVehicle(loopv);
	}

	if (xMinigunTurret(v) != None)
		xMinigunTurret(v).EngineerLock();
	else if (xLinkTurret(v) != None)
		xLinkTurret(v).EngineerLock();
	else if (xBallTurret(v) != None)
		xBallTurret(v).EngineerLock();
	else if (xEnergyTurret(v) != None)
		xEnergyTurret(v).EngineerLock();
	else if (xIonCannon(v) != None)
		xIonCannon(v).EngineerLock();
	else if (xGoliath(v) != None)
		xGoliath(v).EngineerLock();
	else if (xHellBender(v) != None)
		xHellBender(v).EngineerLock();
	else if (xScorpion(v) != None)
		xScorpion(v).EngineerLock();
	else if (xPaladin(v) != None)
		xPaladin(v).EngineerLock();
	else if (xManta(v) != None)
		xManta(v).EngineerLock();
	else if (xIonTank(v) != None)
		xIonTank(v).EngineerLock();
	else if (xTC(v) != None)
		xTC(v).EngineerLock();
}

function LockCommand()
{
	local Pawn PawnOwner;
	local vector FaceDir;
	local vector StartTrace;
	local vector EndLocation;
	local vector HitLocation;
	local vector HitNormal;
	local Actor AHit;
	local vehicle v, loopv;
	local int i;

	PawnOwner = Pawn(Owner);
	if (PawnOwner == None || PawnOwner.Controller == None)
		return;

	FaceDir = Vector(PawnOwner.Controller.GetViewRotation());
	StartTrace = PawnOwner.Location + PawnOwner.EyePosition();
	EndLocation = StartTrace + (FaceDir * 5000.0);

   	AHit = Trace(HitLocation, HitNormal, EndLocation, StartTrace, true);
	if ((AHit == None) || (vehicle(AHit) == None))
		return;

	v = Vehicle(AHit);
	if (v != PawnOwner && v.Health > 0)
	{
		for(i = 0; i < SummonedTurrets.length; i++)
		{
			loopv = Vehicle(SummonedTurrets[i]);
			if (loopv != None && loopv.Health > 0 && loopv == v)
				LockThisVehicle(loopv);
		}
		for(i = 0; i < SummonedVehicles.length; i++)
		{
			loopv = Vehicle(SummonedVehicles[i]);
			if (loopv != None && loopv.Health > 0 && loopv == v)
				LockThisVehicle(loopv);
		}
	}
}

function UnlockCommand()
{
	local Pawn PawnOwner;
	local vector FaceDir;
	local vector StartTrace;
	local vector EndLocation;
	local vector HitLocation;
	local vector HitNormal;
	local Actor AHit;
	local vehicle v, loopv;
	local int i;

	PawnOwner = Pawn(Owner);
	if (PawnOwner == None || PawnOwner.Controller == None)
		return;

	FaceDir = Vector(PawnOwner.Controller.GetViewRotation());
	StartTrace = PawnOwner.Location + PawnOwner.EyePosition();
	EndLocation = StartTrace + (FaceDir * 5000.0);

   	AHit = Trace(HitLocation, HitNormal, EndLocation, StartTrace, true);
	if ((AHit == None) || (vehicle(AHit) == None))
		return;

	v = Vehicle(AHit);
	if (v != PawnOwner && v.Health > 0)
	{
		for(i = 0; i < SummonedTurrets.length; i++)
		{
			loopv = Vehicle(SummonedTurrets[i]);
			if (loopv != None && loopv.Health > 0 && loopv == v)
				UnlockThisVehicle(loopv);
		}
		for(i = 0; i < SummonedVehicles.length; i++)
		{
			loopv = Vehicle(SummonedVehicles[i]);
			if (loopv != None && loopv.Health > 0 && loopv == v)
				UnlockThisVehicle(loopv);
		}
	}
}

function KillAllSentinels()
{
	local int i;
	
	for(i = 0; i < 100 && SummonedSentinels.length > 0; i++)
		KillFirstSentinel();
}

function KillFirstSentinel()
{
	if (SummonedSentinels.length == 0)
		return;
	if (SummonedSentinels[0] != None)
	{
		if (Vehicle(SummonedSentinels[0]) != None && Vehicle(SummonedSentinels[0]).Driver != None)
			Vehicle(SummonedSentinels[0]).EjectDriver();
		SummonedSentinels[0].Health = 0;
		SummonedSentinels[0].LifeSpan = 0.1 * SummonedSentinels.length;
	}		
		
	UsedEngineerPoints -= SummonedSentinelPoints[0];
	if (UsedEngineerPoints < 0)
	{
		Warn("Sentinel Points less than zero!");
		UsedEngineerPoints = 0;
	}
	SummonedSentinels.remove(0, 1);
	SummonedSentinelPoints.remove(0, 1);
}

function KillAllTurrets()
{
	local int i;

	for(i = SummonedTurrets.length; i > 0; i--)
		KillTurret(i-1);
}

function KillTurret(int i)
{
	if (SummonedTurrets.length <= i)
		return;
	if (SummonedTurrets[i] != None && Vehicle(SummonedTurrets[i]) != None && Vehicle(SummonedTurrets[i]).Driver == None)
	{
		SummonedTurrets[i].Health = 0;
		SummonedTurrets[i].LifeSpan = 0.1 * (i + 1);
		
		UsedEngineerPoints -= SummonedTurretPoints[i];
		if (UsedEngineerPoints < 0)
		{
			Warn("Turret Points less than zero!");
			UsedEngineerPoints = 0;
		}
		SummonedTurrets.remove(i, 1);
		SummonedTurretPoints.remove(i, 1);
	}
}

function KillAllVehicles()
{
	local int i;
	
	for(i = SummonedVehicles.length; i > 0; i--)
		KillVehicle(i-1);
}

function KillVehicle(int i)
{
	if (SummonedVehicles.length <= i)
		return;
	if (SummonedVehicles[i] != None && Vehicle(SummonedVehicles[i]) != None && Vehicle(SummonedVehicles[i]).Driver == None)
	{
		SummonedVehicles[i].Health = 0;
		SummonedVehicles[i].LifeSpan = 0.1 * (i + 1);
		
		UsedEngineerPoints -= SummonedVehiclePoints[i];
		if (UsedEngineerPoints < 0)
		{
			Warn("Vehicle Points less than zero!");
			UsedEngineerPoints = 0;
		}
		SummonedVehicles.remove(i, 1);
		SummonedVehiclePoints.remove(i, 1);
	}
}

simulated function Destroyed()
{	
	local int i;
	
	if (Level.NetMode == NM_DedicatedServer || Level.NetMode == NM_ListenServer || Level.NetMode == NM_Standalone)
	{
		SetTimer(0, false);
		KillAllSentinels();
		for(i = 0; i < SummonedVehicles.length; i++)
		{
			if (SummonedVehicles[i] != None)
			{
				if (Vehicle(SummonedVehicles[i]) != None && Vehicle(SummonedVehicles[i]).Driver != None)
					Vehicle(SummonedVehicles[i]).EjectDriver();
			}
		}
		KillAllVehicles();
		for(i = 0; i < SummonedTurrets.length; i++)
		{
			if(SummonedTurrets[i] != None)
			{
				if (Vehicle(SummonedTurrets[i]) != None && Vehicle(SummonedTurrets[i]).Driver != None)
					Vehicle(SummonedTurrets[i]).EjectDriver();
			}
		}
		KillAllTurrets();
	}
	
	Super.Destroyed();
}

static function string GetLocalString(optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2)
{
	if (Switch == 2)
		return Default.NotEnoughPointsMessage;
	if (Switch == 3)
		return Default.UnableToSpawnMessage;
	if (Switch == 4)
		return Default.TooManyToSpawnMessage;
	if (Switch == 5)
		return Default.NotAtLevel;
	if (Switch == 6)
		return Default.TooManyExtra;

	return Super.GetLocalString(Switch, RelatedPRI_1, RelatedPRI_2);
}

defaultproperties
{
     SentinelAvailability(0)=(Number=1,Level=15)
     SentinelAvailability(1)=(Number=2,Level=70)
     SentinelAvailability(2)=(Number=3,Level=120)
     SentinelAvailability(3)=(Number=4,Level=150)
     VehicleAvailability(0)=(Number=1,Level=20)
     VehicleAvailability(1)=(Number=2,Level=40)
     TurretAvailability(0)=(Number=1,Level=30)
     TurretAvailability(1)=(Number=2,Level=50)
     TurretAvailability(2)=(Number=3,Level=100)
     TurretAvailability(3)=(Number=4,Level=150)
     TurretAvailability(4)=(Number=5,Level=200)
     NotEnoughPointsMessage="Insufficent points available to summon this."
     UnableToSpawnMessage="Unable to spawn."
     TooManyToSpawnMessage="You have summoned too many of these. You must kill one before you can summon another one."
     NotAtLevel="You need to be a higher level to spawn one of these"
     TooManyExtra="You cannot spawn this many extra items"
     SentinelDamageAdjust=1.000000
     FastBuildPercent=1.000000
     MessageClass=Class'UnrealGame.StringMessagePlus'
}
