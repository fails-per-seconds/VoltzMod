class MonsterPointsInv extends Inventory
	config(fps);

var array<Monster> SummonedMonsters;
var array<int> SummonedMonsterPoints;
var int TotalMonsterPoints;
var int UsedMonsterPoints;

var config int MaxMonsters;

var localized string NotEnoughAdrenalineMessage;
var localized string NotEnoughMonsterPointsMessage;
var localized string UnableToSpawnMonsterMessage;
var localized string TooManyMonstersMessage;
var localized string PetsAttackEnemyMessage;
var localized string PetsFollowMessage;
var localized string PetsStayMessage;

//client side only
var PlayerController PC;
var Player Player;

replication
{
	reliable if (Role < ROLE_Authority)
		AttackEnemyCommand, FollowCommand, StayCommand;
	reliable if (bNetOwner && bNetDirty && Role == ROLE_Authority)
		TotalMonsterPoints, UsedMonsterPoints;
}

function PostBeginPlay()
{
	if (Level.NetMode == NM_DedicatedServer || Level.NetMode == NM_ListenServer || Level.NetMode == NM_Standalone)
		SetTimer(5, true);
	Super.PostBeginPlay();
}

simulated function PostNetBeginPlay()
{
	if (Level.NetMode != NM_DedicatedServer)
		enable('Tick');
	Super.PostNetBeginPlay();
}

function Monster SummonMonster(class<Monster> ChosenMonster, int Adrenaline, int MonsterPoints)
{
	local Monster m;
	local Vector SpawnLocation;
	local rotator SpawnRotation;
	local Inventory Inv;
	local RPGStatsInv StatsInv;
	local int x;
	local FriendlyMonsterController C;
	local FriendlyMonsterInv FriendlyInv;

	if (Instigator.Controller.Adrenaline < Adrenaline)
	{
		Instigator.ReceiveLocalizedMessage(MessageClass, 1, None, None, Class);
		return None;
	}
	if (TotalMonsterPoints - UsedMonsterPoints < MonsterPoints)
	{
		Instigator.ReceiveLocalizedMessage(MessageClass, 2, None, None, Class);
		return None;
	}

	if (SummonedMonsters.length >= MaxMonsters)
	{
		Instigator.ReceiveLocalizedMessage(MessageClass, 4, None, None, Class);
		return None;
	}

	SpawnLocation = getSpawnLocation(ChosenMonster);
	SpawnRotation = getSpawnRotator(SpawnLocation);

	M = spawn(ChosenMonster,,, SpawnLocation, SpawnRotation);
	if (M == None)
	{
		Instigator.ReceiveLocalizedMessage(MessageClass, 3, None, None, Class);
		return None;
	}
	else
	{
		if (M.Controller != None)
			M.Controller.Destroy();

		FriendlyInv = M.spawn(class'FriendlyMonsterInv');

		if (FriendlyInv == None)
		{
			Instigator.ReceiveLocalizedMessage(MessageClass, 3, None, None, Class);
			M.Died(None, class'DamageType', vect(0,0,0));
			return None;
		}
		FriendlyInv.MasterPRI = Instigator.Controller.PlayerReplicationInfo;
		FriendlyInv.giveTo(M);
		FriendlyInv.MonsterPointsInv = self;

		C = spawn(class'FriendlyMonsterController',,, SpawnLocation, SpawnRotation);
		if (C == None)
		{
			Instigator.ReceiveLocalizedMessage(MessageClass, 3, None, None, Class);
			M.Died(None, class'DamageType', vect(0,0,0));
			FriendlyInv.Destroy();
			M.Destroy();
			return None;
		}
		C.Possess(M);
		C.SetMaster(Instigator.Controller);

		M.HealthMax *= class'AbilityLoadedMonsters'.default.PetHealthFraction;
		M.Health *= class'AbilityLoadedMonsters'.default.PetHealthFraction;

		Instigator.Controller.Adrenaline -= Adrenaline;
		UsedMonsterPoints += MonsterPoints;
		SummonedMonsters[SummonedMonsters.length] = M;
		SummonedMonsterPoints[SummonedMonsterPoints.length] = MonsterPoints;

		for (Inv = Instigator.Controller.Inventory; Inv != None; Inv = Inv.Inventory)
		{
			StatsInv = RPGStatsInv(Inv);
			if (StatsInv != None)
				break;
		}
		if (StatsInv == None)
			StatsInv = RPGStatsInv(Instigator.FindInventoryType(class'RPGStatsInv'));
		if (StatsInv != None)
		{
			for (x = 0; x < StatsInv.Data.Abilities.length; x++)
			{
				if (ClassIsChildOf(StatsInv.Data.Abilities[x], class'MonsterAbility'))
					class<MonsterAbility>(StatsInv.Data.Abilities[x]).static.ModifyMonster(M, StatsInv.Data.AbilityLevels[x]);
				else
					StatsInv.Data.Abilities[x].static.ModifyPawn(M, StatsInv.Data.AbilityLevels[x]);
			}

			if (C.Inventory == None)
				C.Inventory = StatsInv;
			else
			{
				for (Inv = C.Inventory; Inv.Inventory != None; Inv = Inv.Inventory)
				{}
				Inv.Inventory = StatsInv;
			}
		}
	}

	return M;
}

function KillAllMonsters()
{
	local int i;
	
	for(i = 0; i < 1000 && SummonedMonsters.length > 0; i++)
		KillFirstMonster();
}

function KillFirstMonster()
{
	if (SummonedMonsters.length == 0)
		return;
	if (SummonedMonsters[0] != None)
	{
		SummonedMonsters[0].Health = 0;
		SummonedMonsters[0].LifeSpan = 0.1 * SummonedMonsters.length;
	}		
		
	UsedMonsterPoints -= SummonedMonsterPoints[0];
	if (UsedMonsterPoints < 0)
	{
		Warn("Monster Points less than zero!");
		UsedMonsterPoints = 0;
	}
	SummonedMonsters.remove(0, 1);
	SummonedMonsterPoints.remove(0, 1);
}

function Timer()
{
	local int i;

	for(i = 0; i < SummonedMonsters.length; i++)
	{
		if (SummonedMonsters[i] == None || SummonedMonsters[i].health <= 0)
		{
			UsedMonsterPoints -= SummonedMonsterPoints[i];
			if (UsedMonsterPoints < 0)
			{
				Warn("Monster Points less than zero!");
				UsedMonsterPoints = 0;
			}
			SummonedMonsters.remove(i, 1);
			SummonedMonsterPoints.remove(i, 1);
			i--;
		}
	}
}

function vector getSpawnLocation(Class<Monster> ChosenMonster)
{
	local float Dist, BestDist;
	local vector SpawnLocation;
	local NavigationPoint N, BestDest;

	BestDist = 50000.f;
	for (N = Level.NavigationPointList; N != None; N = N.NextNavigationPoint)
	{
		Dist = VSize(N.Location - Instigator.Location);
		if (Dist < BestDist && Dist > ChosenMonster.default.CollisionRadius * 2)
		{
			BestDest = N;
			BestDist = VSize(N.Location - Instigator.Location);
		}
	}

	if (BestDest != None)
		SpawnLocation = BestDest.Location + (ChosenMonster.default.CollisionHeight - BestDest.CollisionHeight) * vect(0,0,1);
	else
		SpawnLocation = Instigator.Location + ChosenMonster.default.CollisionHeight * vect(0,0,1.5); //is this why monsters spawn on heads?

	return SpawnLocation;	
}

function rotator getSpawnRotator(Vector SpawnLocation)
{
	local rotator SpawnRotation;

	SpawnRotation.Yaw = rotator(SpawnLocation - Instigator.Location).Yaw;
	return SpawnRotation;
}

simulated function Destroyed()
{	
	if (Level.NetMode == NM_DedicatedServer || Level.NetMode == NM_ListenServer || Level.NetMode == NM_Standalone)
	{
		KillAllMonsters();
		SetTimer(0, false);
	}

	super.Destroyed();
}

static function string GetLocalString(optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2)
{
	if (Switch == 1)
		return default.NotEnoughAdrenalineMessage;
	if (Switch == 2)
		return default.NotEnoughMonsterPointsMessage;
	if (Switch == 3)
		return default.UnableToSpawnMonsterMessage;
	if (Switch == 4)
		return default.TooManyMonstersMessage;
	if (Switch == 5)
		return default.PetsAttackEnemyMessage;
	if (Switch == 6)
		return default.PetsFollowMessage;
	if (Switch == 7)
		return default.PetsStayMessage;

	return Super.GetLocalString(Switch, RelatedPRI_1, RelatedPRI_2);
}

function bool CheckCanUseCommands()
{
	local Inventory Inv;
	local LoadedInv LI;
	local Pawn PawnOwner;

	if (SummonedMonsters.length <= 0)
		return false;

	PawnOwner = Pawn(Owner);
	if (PawnOwner == None)
		return false;

	for (Inv = PawnOwner.Controller.Inventory; Inv != None; Inv = Inv.Inventory)
	{
		LI = LoadedInv(Inv);
		if (LI != None)
			break;
	}
	if (LI == None)
		LI = LoadedInv(PawnOwner.FindInventoryType(class'LoadedInv'));
	if (LI == None || !LI.DirectMonsters)
		return false;

	return true;
}

static function AttackEnemy(Pawn P)
{
	local MonsterPointsInv MPI;

	if (P == None)
		return;

	MPI = MonsterPointsInv(P.FindInventoryType(class'MonsterPointsInv'));
	if (MPI != None)
	{
		MPI.AttackEnemyCommand();
	}
}

function AttackEnemyCommand()
{
	local Pawn PawnOwner;
	local Vector FaceDir;
	local Vector EndLocation;
	local vector HitLocation;
	local vector HitNormal;
	local Actor AHit;
	local Pawn  HitPawn;
	local Vector StartTrace;
	local int mi;

	if (!CheckCanUseCommands())
		return;

	PawnOwner = Pawn(Owner);
	if (PawnOwner == None)
		return;

	FaceDir = Vector(PawnOwner.Controller.GetViewRotation());
	StartTrace = PawnOwner.Location + PawnOwner.EyePosition();
	EndLocation = StartTrace + (FaceDir * 5000.0);

   	AHit = Trace(HitLocation, HitNormal, EndLocation, StartTrace, true);
	if ((AHit == None) || (Pawn(AHit) == None) || (Pawn(AHit).Controller == None))
		return;

	HitPawn = Pawn(AHit);
	if (HitPawn != PawnOwner && HitPawn.Health > 0 && !HitPawn.Controller.SameTeamAs(PawnOwner.Controller))
	{
		Instigator.ReceiveLocalizedMessage(MessageClass, 5, None, None, Class);
		for(mi = 0; mi < SummonedMonsters.length; mi++)
		{
			if (SummonedMonsters[mi] != None && SummonedMonsters[mi].health > 0)
			{
				if (FriendlyMonsterController(SummonedMonsters[mi].Controller) != None)
					FriendlyMonsterController(SummonedMonsters[mi].Controller).ChangeEnemy(HitPawn, true);
			}
		}
	}
}

static function PetFollow(Pawn P)
{
	local MonsterPointsInv MPI;

	if (P == None)
		return;

	MPI = MonsterPointsInv(P.FindInventoryType(class'MonsterPointsInv'));
	if (MPI != None)
	{
		MPI.FollowCommand();
	}
}

function FollowCommand()
{
	local int mi;

	if (!CheckCanUseCommands())
		return;

	Instigator.ReceiveLocalizedMessage(MessageClass, 6, None, None, Class);
	for(mi = 0; mi < SummonedMonsters.length; mi++)
	{
		if (SummonedMonsters[mi] != None && SummonedMonsters[mi].health > 0)
		{
			SummonedMonsters[mi].GroundSpeed = SummonedMonsters[mi].default.GroundSpeed;
			SummonedMonsters[mi].WaterSpeed = SummonedMonsters[mi].default.WaterSpeed;
			SummonedMonsters[mi].AirSpeed = SummonedMonsters[mi].default.AirSpeed;
		}
	}
}

static function PetStay(Pawn P)
{
	local MonsterPointsInv MPI;

	if (P == None)
		return;

	MPI = MonsterPointsInv(P.FindInventoryType(class'MonsterPointsInv'));
	if (MPI != None)
	{
		MPI.StayCommand();
	}
}

function StayCommand()
{
	local int mi;

	if (!CheckCanUseCommands())
		return;

	Instigator.ReceiveLocalizedMessage(MessageClass, 7, None, None, Class);
	for(mi = 0; mi < SummonedMonsters.length; mi++)
	{
		if (SummonedMonsters[mi] != None && SummonedMonsters[mi].health > 0)
		{
			SummonedMonsters[mi].GroundSpeed = 0;
			SummonedMonsters[mi].WaterSpeed = 0;
			SummonedMonsters[mi].AirSpeed = 0;
		}
	}
}

defaultproperties
{
     MaxMonsters=3
     NotEnoughAdrenalineMessage="You do not have enough adrenaline to summon this monster."
     NotEnoughMonsterPointsMessage="Insufficent monster points available to summon this monster."
     UnableToSpawnMonsterMessage="Unable to spawn monster."
     TooManyMonstersMessage="You have summoned too many monsters. You must kill one before you can summon another one."
     PetsAttackEnemyMessage="Pets, Attack!"
     PetsFollowMessage="Pets, Follow!"
     PetsStayMessage="Pets, Stay!"
     MessageClass=Class'UnrealGame.StringMessagePlus'
}
