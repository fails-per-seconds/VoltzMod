class MonsterInv extends Inventory;

var MutFPS RPGMut;
var int AbilityLevel;
var array<class<Monster> > MonsterList;
var FriendlyMonsterController CurrentMonster;

function PostBeginPlay()
{
	Super.PostBeginPlay();

	RPGMut = class'MutFPS'.static.GetRPGMutator(Level.Game);
	RPGMut.FillMonsterList();

	SetTimer(10.0, true);
}

function GiveTo(Pawn Other, optional Pickup Pickup)
{
	local Controller C;
	local FriendlyMonsterController F;

	Super.GiveTo(Other, Pickup);

	for (C = Level.ControllerList; C != None; C = C.NextController)
	{
		F = FriendlyMonsterController(C);
		if (F != None && F.Master != None && F.Master == Instigator.Controller)
		{
			CurrentMonster = F;
			return;
		}
	}

	SpawnMonster(true);
}

function Timer()
{
	if (Instigator == None || Instigator.Health <= 0 || Instigator.Controller == None)
	{
		Destroy();
		return;
	}

	if (CurrentMonster != None)
		return;

	SpawnMonster(false);
}

function SpawnMonster(bool bNearOwner)
{
	local int x, Count;
	local NavigationPoint N, BestDest;
	local float Dist, BestDist;
	local vector SpawnLocation;
	local rotator SpawnRotation;
	local FriendlyMonsterController C;
	local Monster P;
	local Inventory Inv;
	local RPGStatsInv StatsInv;

	do
	{
		x = Rand(RPGMut.MonsterList.length);
		Count++;
	} until (RPGMut.MonsterList[x].default.ScoringValue == AbilityLevel || (AbilityLevel == 8 && RPGMut.MonsterList[x].default.ScoringValue > 8) || Count > 1000)

	if (Count > 1000)
	{
		if (AbilityLevel > 0)
		{
			AbilityLevel--;
			SpawnMonster(bNearOwner);
			return;
		}
		else
		{
			AbilityLevel = 12;
			return;
		}
	}

	if (bNearOwner)
	{
		BestDist = 50000.f;
		for (N = Level.NavigationPointList; N != None; N = N.NextNavigationPoint)
		{
			Dist = VSize(N.Location - Instigator.Location);
			if (Dist < BestDist && Dist > RPGMut.MonsterList[x].default.CollisionRadius * 2)
			{
				BestDest = N;
				BestDist = VSize(N.Location - Instigator.Location);
			}
		}
	}
	else
	{
		Count = 0;
		do
		{
			BestDest = Instigator.Controller.FindRandomDest();
			Count++;
		} until (BestDest == None || (VSize(BestDest.Location - Instigator.Location) > 1000 && !FastTrace(BestDest.Location, Instigator.Location)) || Count > 1000)
	}

	if (BestDest != None)
		SpawnLocation = BestDest.Location + (RPGMut.MonsterList[x].default.CollisionHeight - BestDest.CollisionHeight) * vect(0,0,1);
	else
		SpawnLocation = Instigator.Location + RPGMut.MonsterList[x].default.CollisionHeight * vect(0,0,1.5);
	SpawnRotation.Yaw = rotator(SpawnLocation - Instigator.Location).Yaw;

	P = spawn(RPGMut.MonsterList[x],,, SpawnLocation, SpawnRotation);
	if (P == None)
	{
		return;
	}
	if (P.Controller != None)
		P.Controller.Destroy();
	C = spawn(class'FriendlyMonsterController',,, SpawnLocation, SpawnRotation);
	C.Possess(P);
	C.SetMaster(Instigator.Controller);

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
		C.Pawn.Health += StatsInv.Data.HealthBonus;
		C.Pawn.HealthMax += StatsInv.Data.HealthBonus;
		for (x = 0; x < StatsInv.Data.Abilities.length; x++)
			StatsInv.Data.Abilities[x].static.ModifyPawn(P, StatsInv.Data.AbilityLevels[x]);
		if (C.Inventory == None)
			C.Inventory = StatsInv;
		else
		{
			for (Inv = C.Inventory; Inv.Inventory != None; Inv = Inv.Inventory)
			{}
			Inv.Inventory = StatsInv;
		}
	}
	else
		Log("WARNING: Couldn't find RPGStatsInv for "$Instigator.GetHumanReadableName());

	CurrentMonster = C;
}

defaultproperties
{
}
