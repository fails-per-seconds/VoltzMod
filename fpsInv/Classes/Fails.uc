class Fails extends Invasion
	config(fpsInv);

var() config int MaxAlive;
var() config bool bPreload, bHitSound;

struct MonsterInfo
{
	var int Wave;
	var float Size;
	var float Speed;
	var string MonsterClass;
	var int Health;
};
var config array<MonsterInfo> MonsterTable;

struct BossInfo
{
	var int Wave;
	var int Bosses;
	var float Size;
	var float Speed;
	var string BossClass;
	var int Health;
};
var config array<BossInfo> BossTable;

struct MonsterStruct
{
	var class<Monster> Monsters;
	var float MonsterSZ;
	var float MonsterSP;
	var int MonsterHP;
};
var array<MonsterStruct> MonsterWaveTable;

struct BossStruct
{
	var class<Monster> Boss;
	var int Bosses;
	var float BossSZ;
	var float BossSP;
	var int BossHP;
};
var array<BossStruct> BossWaveTable;

var array<Class<Monster> > MonsterClasses;
var array<Class<Monster> > BossClasses;

var bool bBossWave, bSwitchWave, bRespawn;
var int BossAlive, MaxBossAlive;

//timers
var FailsGRI GRI;
var config int BossTime, KillTime;
var int NumMons, NumBoss, BossTimeLimit, KillZoneLimit;

event PreBeginPlay()
{
	Super.PreBeginPlay();
	WaveNum = InitialWave;
	InvasionGameReplicationInfo(GameReplicationInfo).WaveNumber = WaveNum;
	InvasionGameReplicationInfo(GameReplicationInfo).BaseDifficulty = int(GameDifficulty);
	GameReplicationInfo.bNoTeamSkins = true;
	GameReplicationInfo.bForceNoPlayerLights = true;
	GameReplicationInfo.bNoTeamChanges = true;
	FailsGRI(GameReplicationInfo).MonsterPreloads = MonsterTable.length;
}

event PlayerController Login(string Portal,string Options,out string Error)
{
	local PlayerController PC;
	local Controller C;

  	if (MaxLives > 0)
	{
		for (C = Level.ControllerList; C != None; C = C.NextController)
		{
			if ((C.PlayerReplicationInfo != None) && (C.PlayerReplicationInfo.NumLives > LateEntryLives))
			{
				Options = "?SpectatorOnly=1"$Options;
				break;
			}
		}
	}

	PC = Super(UnrealMPGameInfo).Login(Portal,Options,Error);

	if (PC != None)
	{
		if (bMustJoinBeforeStart && GameReplicationInfo.bMatchHasBegun)
			UnrealPlayer(PC).bLatecomer = true;

		if (Level.NetMode == NM_Standalone)
		{
			if (PC.PlayerReplicationInfo.bOnlySpectator)
			{
				if (!bCustomBots && (bAutoNumBots || (bTeamGame && (InitialBots%2 == 1))))
					InitialBots++;
			}
			else
				StandalonePlayer = PC;
		}

		for(C = Level.ControllerList; C != None; C = C.NextController)
		{
			if ((C.PlayerReplicationInfo != None) && C.PlayerReplicationInfo.bOutOfLives && !C.PlayerReplicationInfo.bOnlySpectator)
			{
				PC.PlayerReplicationInfo.bOutOfLives = true;
				PC.PlayerReplicationInfo.NumLives = 0;
			}
		}

		if (PlayerInv(PC) != None)
			PlayerInv(PC).bLoadMeshes = bPreload;
	}

	return PC;
}

function int ReduceDamage(int Damage, pawn injured, pawn instigatedBy, vector HitLocation, out vector Momentum, class<DamageType> DamageType)
{
	local float InstigatorSkill, result;
	local PlayerInv PInv;
	local bool sameTeam;

	if (instigatedBy == None)
		return Super.ReduceDamage(Damage,injured,instigatedBy,HitLocation,Momentum,DamageType);

	if (bHitSound && (instigatedBy != None) && (PlayerInv(instigatedBy.Controller) != None) && ((Class<WeaponDamageType>(DamageType) != None) || (Class<VehicleDamageType>(DamageType) != None)))
	{
		PInv = PlayerInv(instigatedBy.Controller);
		if (instigatedBy.IsPlayerPawn() && (injured != instigatedBy))
		{
			sameTeam = (Level.Game.bTeamGame && injured.GetTeamNum() == instigatedBy.GetTeamNum());
			if (bHitSound)
				PInv.ClientHitSound(Damage, !sameTeam);
		}
	}

	if (instigatedby != None && instigatedBy.Controller != None)
	{
		if (injured != None && injured.Controller != None)
		{
			if (Monster(Injured) != None && Monster(instigatedBy) != None && CompareControllers(Injured.Controller, instigatedBy.Controller))
				Damage = 0;
		}

		if (Monster(Injured) == None && MonsterController(instigatedBy.Controller) == None && !InstigatedBy.Controller.IsA('SMPNaliFighterController'))
		{
			if (ClassIsChildOf(DamageType, class'DamTypeRoadkill'))
				Damage = 0;
		}
	}

	if (MonsterController(InstigatedBy.Controller) != None)
	{
		InstigatorSkill = MonsterController(instigatedBy.Controller).Skill;
		if (NumPlayers > 4)
			InstigatorSkill += 1.0;
		if ((InstigatorSkill < 7) && (Monster(Injured) == None))
		{
			if (InstigatorSkill <= 3)
				Damage = Damage * (0.25 + 0.05 * InstigatorSkill);
			else
				Damage = Damage * (0.4 + 0.1 * (InstigatorSkill - 3));
		}
	}
	else if (injured == instigatedBy)
		Damage = Damage * 0.5;
	if (InvasionBot(injured.Controller) != None)
	{
		if (!InvasionBot(injured.controller).bDamagedMessage && (injured.Health - Damage < 50))
		{
			InvasionBot(injured.controller).bDamagedMessage = true;
			if (FRand() < 0.5)
				injured.Controller.SendMessage(None, 'OTHER', 4, 12, 'TEAM');
			else
				injured.Controller.SendMessage(None, 'OTHER', 13, 12, 'TEAM');
		}
		if (GameDifficulty <= 3)
		{
			if (injured.IsPlayerPawn() && (injured == instigatedby) && (Level.NetMode == NM_Standalone))
				Damage *= 0.5;

			if (MonsterController(InstigatedBy.Controller) != None)
			{
				if (InstigatorSkill <= 3)
					Damage = Damage * (0.25 + 0.15 * InstigatorSkill);
			}
		}
	}
	result = Super.ReduceDamage(Damage,injured,instigatedBy,HitLocation,Momentum,DamageType);
	return result;
}

function Killed(Controller Killer, Controller Killed, Pawn KilledPawn, class<DamageType> DamageType)
{
	Super.Killed(Killer, Killed, KilledPawn, DamageType);
	if ((MonsterController(Killed) != None) || (Monster(KilledPawn) != None))
	{
		MonsterController(Killed).Destroy();
		Monster(KilledPawn).Destroy();
	}
}

function PostBeginPlay()
{
	Super.PostBeginPlay();
	GRI = FailsGRI(GameReplicationInfo);
}

function int MonsterCount()
{
	local MonsInv MInv;
	local int MCount;

	foreach DynamicActors(class'MonsInv', MInv)
		MCount++;

	NumMonsters = MCount;
	return MCount;
}

function int BossCount()
{
	local BossInv BInv;
	local int BCount;

	foreach DynamicActors(class'BossInv', BInv)
		BCount++;

	NumMonsters = BCount;
	return BCount;
}

function UpdateGRI()
{
	GRI.NumMons = MonsterCount();
	GRI.NumBoss = BossCount();
}

function Actor GetMonsterTarget()
{
	local Controller C;

	for(C = Level.ControllerList; C != None; C = C.NextController)
		if (C.IsA('PlayerController') && (C.Pawn != None))
			return C.Pawn;
}

function bool ShouldMonsterAttack(Actor CurrentTarget, Controller C)
{
	if (CurrentTarget != None && C != None)
	{
		if (Pawn(CurrentTarget) != None && Pawn(CurrentTarget).Controller != None)
		{
			if (Pawn(CurrentTarget).Controller.IsA('PetController') || Pawn(CurrentTarget).Controller.IsA('AnimalController'))
			{
				return false;
			}
			else if (C.IsA('MonsterController'))
			{
				if (Pawn(CurrentTarget).Controller.IsA('PlayerController') || Pawn(CurrentTarget).Controller.IsA('FriendlyMonsterController'))
					return true;
				else
					return false;
			}
			else if (C.IsA('FriendlyMonsterController'))
			{
				if (Pawn(CurrentTarget).Controller.IsA('PlayerController') || Pawn(CurrentTarget).Controller.IsA('FriendlyMonsterController'))
					return false;
				else
					return true;
			}
		}
	}

	return false;
}

function bool CompareControllers(Controller B, Controller C)
{
	if (B.Class == C.Class)
		return true;

	if ((!B.IsA('FriendlyMonsterController') && B.IsA('MonsterController') && C.IsA('SMPNaliFighterController')) || (B.IsA('SMPNaliFighterController') && !C.IsA('FriendlyMonsterController') && C.IsA('MonsterController')))
		return true;

	if (B.IsA('PetController') || C.IsA('PetController'))
		return true;

	if ((B.IsA('FriendlyMonsterController') && C.IsA('PlayerController')) || (B.IsA('PlayerController') && C.IsA('FriendlyMonsterController')))
		return true;

	return false;
}

function AddMonster()
{
	local NavigationPoint StartSpot;
	local Monster NewMonster;
	local Class<Monster> MClass;
	local MonsInv Inv;
	local int x, m;

	//test to prevent attacking each other
	foreach DynamicActors(class'MonsInv', Inv)
	{
		if (NewMonster.Controller != None && !NewMonster.Controller.IsA('FriendlyMonsterController'))
		{
			if (NewMonster.Controller.Target != None)
			{
				if (!ShouldMonsterAttack(NewMonster.Controller.Target, NewMonster.Controller))
					NewMonster.Controller.Target = GetMonsterTarget();
			}
		}
	}
		
	for(x = 0; x < fmax(5,(Level.GRI.PRIArray.Length-1)); x++) //5 per spawn seconds
	{
		StartSpot = FindPlayerStart(None,1);
		if (StartSpot == None)
			return;

		m = Rand(MonsterWaveTable.length);
		MClass = MonsterWaveTable[m].Monsters;

		NewMonster = Spawn(MClass,,,StartSpot.Location+(MClass.Default.CollisionHeight - StartSpot.CollisionHeight) * vect(0,0,1),StartSpot.Rotation);
		if (NewMonster ==  None)
			NewMonster = Spawn(MClass,,,StartSpot.Location+(MClass.Default.CollisionHeight - StartSpot.CollisionHeight) * vect(0,0,1),StartSpot.Rotation);
		if (NewMonster != None)
		{
			Inv = Spawn(class'MonsInv', NewMonster);
			if (Inv != None)
				Inv.GiveTo(NewMonster);

			if (MonsterWaveTable[m].MonsterSZ <= 0)
			{
				NewMonster.SetDrawScale(NewMonster.default.DrawScale);
				NewMonster.SetCollisionSize(NewMonster.default.CollisionRadius, NewMonster.default.CollisionHeight);
				NewMonster.Prepivot.X = NewMonster.default.Prepivot.X;
				NewMonster.Prepivot.Y = NewMonster.default.Prepivot.Y;
				NewMonster.Prepivot.Z = NewMonster.default.Prepivot.Z;
			}
			else
			{
				NewMonster.SetDrawScale(MonsterWaveTable[m].MonsterSZ);
				NewMonster.SetCollisionSize(NewMonster.default.CollisionRadius * MonsterWaveTable[m].MonsterSZ, NewMonster.default.CollisionHeight * MonsterWaveTable[m].MonsterSZ);
				NewMonster.Prepivot.X = NewMonster.default.Prepivot.X * MonsterWaveTable[m].MonsterSZ;
				NewMonster.Prepivot.Y = NewMonster.default.Prepivot.Y * MonsterWaveTable[m].MonsterSZ;
				NewMonster.Prepivot.Z = NewMonster.default.Prepivot.Z * MonsterWaveTable[m].MonsterSZ;
			}

			if (MonsterWaveTable[m].MonsterSP <= 0)
			{
				NewMonster.GroundSpeed = NewMonster.default.GroundSpeed;
				NewMonster.JumpZ = NewMonster.default.JumpZ;
				NewMonster.WaterSpeed = NewMonster.default.WaterSpeed;
				NewMonster.AirSpeed = NewMonster.default.AirSpeed;
			}
			else
			{
				NewMonster.GroundSpeed = NewMonster.default.GroundSpeed * MonsterWaveTable[m].MonsterSP;
				NewMonster.JumpZ = NewMonster.default.JumpZ * MonsterWaveTable[m].MonsterSP;
				NewMonster.WaterSpeed = NewMonster.default.WaterSpeed * MonsterWaveTable[m].MonsterSP;
				NewMonster.AirSpeed = NewMonster.default.AirSpeed * MonsterWaveTable[m].MonsterSP;
			}

			NewMonster.Health = MonsterWaveTable[m].MonsterHP;
			NewMonster.HealthMax = NewMonster.Health;
			WaveMonsters++;
			NumMonsters++;
		}
	}
}

function AddBoss()
{
	local NavigationPoint StartSpot;
	local Monster NewMonster;
	local Class<Monster> BClass;
	local BossInv Inv;
	local int i;

	//test to prevent attacking each other
	foreach DynamicActors(class'BossInv', Inv)
	{
		if (NewMonster.Controller != None && !NewMonster.Controller.IsA('FriendlyMonsterController'))
		{
			if (NewMonster.Controller.Target != None)
			{
				if (!ShouldMonsterAttack(NewMonster.Controller.Target, NewMonster.Controller))
					NewMonster.Controller.Target = GetMonsterTarget();
			}
		}
	}
				
	for(i = 0; i < BossWaveTable.length; i++)
	{
		StartSpot = FindPlayerStart(None,1);
		if (StartSpot == None)
			return;

		BClass = BossWaveTable[i].Boss;
		if (BClass != None)
			NewMonster = Spawn(BClass,,,StartSpot.Location+(BClass.Default.CollisionHeight - StartSpot.CollisionHeight) * vect(0,0,1),StartSpot.Rotation);
		if (NewMonster != None)
		{
			Inv = Spawn(Class'BossInv',NewMonster);
			if (Inv != None)
				Inv.GiveTo(NewMonster);

			if (BossWaveTable[i].BossSZ <= 0)
			{
				NewMonster.SetDrawScale(NewMonster.default.DrawScale);
				NewMonster.SetCollisionSize(NewMonster.default.CollisionRadius, NewMonster.default.CollisionHeight);
				NewMonster.Prepivot.X = NewMonster.default.Prepivot.X;
				NewMonster.Prepivot.Y = NewMonster.default.Prepivot.Y;
				NewMonster.Prepivot.Z = NewMonster.default.Prepivot.Z;
			}
			else
			{
				NewMonster.SetDrawScale(BossWaveTable[i].BossSZ);
				NewMonster.SetCollisionSize(NewMonster.default.CollisionRadius * BossWaveTable[i].BossSZ, NewMonster.default.CollisionHeight * BossWaveTable[i].BossSZ);
				NewMonster.Prepivot.X = NewMonster.default.Prepivot.X * BossWaveTable[i].BossSZ;
				NewMonster.Prepivot.Y = NewMonster.default.Prepivot.Y * BossWaveTable[i].BossSZ;
				NewMonster.Prepivot.Z = NewMonster.default.Prepivot.Z * BossWaveTable[i].BossSZ;
			}

			if (BossWaveTable[i].BossSP <= 0)
			{
				NewMonster.GroundSpeed = NewMonster.default.GroundSpeed;
				NewMonster.JumpZ = NewMonster.default.JumpZ;
				NewMonster.WaterSpeed = NewMonster.default.WaterSpeed;
				NewMonster.AirSpeed = NewMonster.default.AirSpeed;
			}
			else
			{
				NewMonster.GroundSpeed = NewMonster.default.GroundSpeed * BossWaveTable[i].BossSP;
				NewMonster.JumpZ = NewMonster.default.JumpZ * BossWaveTable[i].BossSP;
				NewMonster.WaterSpeed = NewMonster.default.WaterSpeed * BossWaveTable[i].BossSP;
				NewMonster.AirSpeed = NewMonster.default.AirSpeed * BossWaveTable[i].BossSP;
			}

			NewMonster.Health = BossWaveTable[i].BossHP;
			NewMonster.HealthMax = NewMonster.Health;
			WaveMonsters++;
			NumMonsters++;
		}
	}
}

function KillZone()
{
	local Controller C;

	if (Level.TimeSeconds > WaveEndTime + KillTime && KillTime <= 0)
	{
		for(C = Level.ControllerList; C != None; C = C.NextController)
		{
			if (C.bIsPlayer && (C.Pawn != None))
			{
				if (C.PlayerReplicationInfo != None)
					C.PlayerReplicationInfo.NumLives = 0;
				C.Pawn.Spawn(class'NewIonEffect').RemoteRole = ROLE_SimulatedProxy;
				C.Pawn.KilledBy(C.Pawn);
				break;
			}
		}
	}
	else
	{
		KillTime--;
		GRI.KillZoneLimit = KillTime;
		if (GRI.KillZoneLimit <= 10)
			BroadcastLocalizedMessage(class'TimedMessage',GRI.KillZoneLimit);

		if (MonsterCount() <= 0)
		{
			bWaveInProgress = false;
			WaveCountDown = 15;
			WaveNum++;
			GRI.KillZoneLimit = 0;
		}
	}
}

function bool BossWaveBegin()
{
	AddBoss();
	return true;
}

function bool KillZoneBegin()
{
	if (Invasion(Level.Game).WaveNum > 9)
		return true;

	return false;
}

function SetupWave()
{
	local int x, m; //monsters
	local int i, b; //bosses

	BossWaveTable.length = 0;
	MaxBossAlive = 0;
	for(i = 0; i < BossTable.length; i++)
	{
		if ((WaveNum + 1) == BossTable[i].Wave)
		{
			b = BossWaveTable.length;
			BossWaveTable.length = b + 1;
			BossWaveTable[b].Boss = Class<Monster>(DynamicLoadObject(BossTable[i].BossClass,Class'Class',false));
			BossWaveTable[b].Bosses = BossTable[i].Bosses;
			BossWaveTable[b].BossSZ = BossTable[i].Size;
			BossWaveTable[b].BossSP = BossTable[i].Speed;
			BossWaveTable[b].BossHP = BossTable[i].Health;
			MaxBossAlive = BossWaveTable[b].Bosses;
		}
	}

	MonsterWaveTable.length = 0;
	for(x = 0; x < MonsterTable.length; x++)
	{
		if ((WaveNum + 1) == MonsterTable[x].Wave)
		{
			m = MonsterWaveTable.length;
			MonsterWaveTable.length = m + 1;
			MonsterWaveTable[m].Monsters = Class<Monster>(DynamicLoadObject(MonsterTable[x].MonsterClass,Class'Class',false));
			MonsterWaveTable[m].MonsterSZ = MonsterTable[x].Size;
			MonsterWaveTable[m].MonsterSP = MonsterTable[x].Speed;
			MonsterWaveTable[m].MonsterHP = MonsterTable[x].Health;
		}
	}

	WaveMonsters = 0;
	WaveNumClasses = 0;
	MaxMonsters = 400;
	WaveEndTime = Level.TimeSeconds + 110; //110 + 5(temp pause)
	AdjustedDifficulty = GameDifficulty + Waves[WaveNum].WaveDifficulty;
	BossTime = 180;
	KillTime = 60 + (3 * WaveNum) - (2 * NumPlayers);
}

State MatchInProgress
{
	function Timer()
	{
		local Controller C;
		local bool bOneMessage;
		local Bot B;

		Super(xTeamGame).Timer();
		UpdateGRI();

		if (bBossWave)
		{
			if (BossAlive < MaxBossAlive)
			{
				if (BossWaveBegin())
					BossAlive++;
				else if (WaveEndTime < Level.TimeSeconds)
					BossAlive = MaxBossAlive;

				if (BossAlive == MaxBossAlive)
					GRI.BossTimeLimit = BossTime;
			}
			else
			{
				if (BossTime <= 0)
				{
					for(C = Level.ControllerList; C != None; C = C.NextController)
					{
						if (C.bIsPlayer && (C.Pawn != None))
						{
							if (C.PlayerReplicationInfo != None)
								C.PlayerReplicationInfo.NumLives = 0;
							C.Pawn.Spawn(class'NewIonEffect').RemoteRole = ROLE_SimulatedProxy;
							C.Pawn.KilledBy(C.Pawn);
							break;
						}
					}
				}
				else
				{
					BossTime--;
					GRI.BossTimeLimit = BossTime;
					if (GRI.BossTimeLimit <= 10)
						BroadcastLocalizedMessage(class'TimedMessage',GRI.BossTimeLimit);

					if (BossCount() <= 0)
					{
						bWaveInProgress = false;
						bBossWave = false;
						WaveCountDown = 15;
						bSwitchWave = false;
						GRI.BossTimeLimit = 0;
					}
				}
			}
		}
		else if (bWaveInProgress)
		{
			bSwitchWave = true;
			if (Level.TimeSeconds > WaveEndTime)
			{
				if (KillZoneBegin())
				{
					KillZone();
				}
				else
				{
					if (MonsterCount() <= 0)
					{
						bWaveInProgress = false;
						WaveCountDown = 15;
						WaveNum++;
					}
				}
			}
			else
			{
				if (MonsterCount() <= MaxMonsters)
					if (MonsterCount() < default.MaxAlive)
						AddMonster();
			}
		}
		else if (MonsterCount() <= 0)
		{
			if (WaveNum >= FinalWave)
			{
				EndGame(None,"TimeLimit");
				return;
			}
			if (bSwitchWave && BossWaveTable.length > 0)
			{
				if (WaveCountDown == 15)
				{
					for(C = Level.ControllerList; C != None; C = C.NextController)
					{
						if (C.PlayerReplicationInfo != None)
						{
							if (!C.PlayerReplicationInfo.bOutOfLives)
								C.PlayerReplicationInfo.NumLives = MaxLives;
							if (C.Pawn != None)
								ReplenishWeapons(C.Pawn);
							else if ((C.Pawn == None) && !C.PlayerReplicationInfo.bOnlySpectator)
							{
								if (bRespawn)
								{
									C.PlayerReplicationInfo.bOutOfLives = false;
									C.PlayerReplicationInfo.NumLives = MaxLives;
									if (PlayerController(C) != None)
										C.GotoState('PlayerWaiting');
								}
								else if (C.PlayerReplicationInfo.bOutOfLives)
									C.PlayerReplicationInfo.NumLives = 0;
							}
						}
					}
				}
				if (WaveCountDown >= 5)
				{
					BroadcastLocalizedMessage(class'BossMessage',MaxBossAlive,,,);
					BossAlive = 0;
				}
				WaveCountDown--;
				if (WaveCountDown <= 1)
				{
					bBossWave = true;
					bWaveInProgress = true;
					WaveEndTime = Level.TimeSeconds;
				}
				if (WaveCountDown == 14)
					Log("Startup wave"@WaveNum@"-BossWave!");
				return;
			}
			bSwitchWave = false;
			WaveCountDown--;
			if (WaveCountDown == 14)
			{
				for(C = Level.ControllerList; C != None; C = C.NextController)
				{
					if (C.PlayerReplicationInfo != None)
					{
						C.PlayerReplicationInfo.bOutOfLives = false;
						C.PlayerReplicationInfo.NumLives = 0;
						if (C.Pawn != None)
							ReplenishWeapons(C.Pawn);
						else if (!C.PlayerReplicationInfo.bOnlySpectator && (PlayerController(C) != None))
							C.GotoState('PlayerWaiting');
					}
				}
			}
			if (WaveCountDown == 13)
			{
				InvasionGameReplicationInfo(GameReplicationInfo).WaveNumber = WaveNum;
				for(C = Level.ControllerList; C != None; C = C.NextController)
				{
					if (PlayerController(C) != None)
					{
						PlayerController(C).PlayStatusAnnouncement('Next_wave_in',1,true);
						if ((C.Pawn == None) && !C.PlayerReplicationInfo.bOnlySpectator)
							PlayerController(C).SetViewTarget(C);
					}
					if (C.PlayerReplicationInfo != None)
					{
						C.PlayerReplicationInfo.bOutOfLives = false;
						C.PlayerReplicationInfo.NumLives = 0;
						if ((C.Pawn == None) && !C.PlayerReplicationInfo.bOnlySpectator)
							C.ServerReStartPlayer();
					}
				}
			}
			else if ((WaveCountDown > 1) && (WaveCountDown < 12))
				BroadcastLocalizedMessage(class'TimerMessage', WaveCountDown-1);
			else if (WaveCountDown <= 1)
			{
				bWaveInProgress = true;
				SetupWave();
				for(C = Level.ControllerList; C != None; C = C.NextController)
					if (PlayerController(C) != None)
						PlayerController(C).LastPlaySpeech = 0;
				for(C = Level.ControllerList; C != None; C = C.NextController)
				{
					if (Bot(C) != None)
					{
						B = Bot(C);
						InvasionBot(B).bDamagedMessage = false;
						B.bInitLifeMessage = false;
						if (!bOneMessage && (FRand() < 0.65))
						{
							bOneMessage = true;
							if ((B.Squad.SquadLeader != None) && B.Squad.CloseToLeader(C.Pawn))
							{
								B.SendMessage(B.Squad.SquadLeader.PlayerReplicationInfo, 'OTHER', B.GetMessageIndex('INPOSITION'), 20, 'TEAM');
								B.bInitLifeMessage = false;
							}
						}
					}
				}
 			}
		}
	}

	function BeginState()
	{
		Super.BeginState();
		WaveNum = InitialWave;
		InvasionGameReplicationInfo(GameReplicationInfo).WaveNumber = WaveNum;
	}
}

static function PrecacheGameTextures(LevelInfo myLevel)
{
	local Class<Monster> PClass;
	local int i, k;

	class'xTeamGame'.static.PrecacheGameTextures(myLevel);

	myLevel.AddPrecacheMaterial(Material'SkaarjPackSkins.jBrute2');
	myLevel.AddPrecacheMaterial(Material'SkaarjPackSkins.jBrute1');
	myLevel.AddPrecacheMaterial(Material'SkaarjPackSkins.eKrall');
	myLevel.AddPrecacheMaterial(Material'SkaarjPackSkins.Skaarjw3');
	myLevel.AddPrecacheMaterial(Material'SkaarjPackSkins.Gasbag1');
	myLevel.AddPrecacheMaterial(Material'SkaarjPackSkins.Gasbag2');
	myLevel.AddPrecacheMaterial(Material'SkaarjPackSkins.Skaarjw2');
	myLevel.AddPrecacheMaterial(Material'SkaarjPackSkins.JManta1');
	myLevel.AddPrecacheMaterial(Material'SkaarjPackSkins.JFly1');
	myLevel.AddPrecacheMaterial(Material'SkaarjPackSkins.Skaarjw1');
	myLevel.AddPrecacheMaterial(Material'SkaarjPackSkins.JPupae1');
	myLevel.AddPrecacheMaterial(Material'SkaarjPackSkins.JWarlord1');
	myLevel.AddPrecacheMaterial(Material'SkaarjPackSkins.jkrall');
	myLevel.AddPrecacheMaterial(Material'InterfaceContent.HUD.SkinA');
	myLevel.AddPrecacheMaterial(Material'AS_FX_TX.AssaultRadar');

	if (default.bPreload)
	{
		for(i = 0; i < class'Fails'.default.MonsterTable.Length; i++)
		{
			if (class'Fails'.default.MonsterTable[i].MonsterClass != "" && class'Fails'.default.MonsterTable[i].MonsterClass != "None")
			{
				PClass = Class<Monster>(DynamicLoadObject(class'Fails'.default.MonsterTable[i].MonsterClass,Class'Class',true));
				if (PClass != None)
				{
					for(k = 0; k < PClass.default.Skins.Length; k++)
						myLevel.AddPrecacheMaterial(PClass.default.Skins[k]);
				}
			}
		}
	}
}

function AddGameSpecificInventory(Pawn P)
{
	if (AllowTransloc())
		P.CreateInventory("fpsInv.GTranslauncher");
	Super(UnrealMPGameInfo).AddGameSpecificInventory(P);
}

function GetServerInfo (out ServerResponseLine ServerState)
{
	Super(xTeamGame).GetServerInfo(ServerState);
	ServerState.GameType = "Invasion";
}

function GetServerDetails(out ServerResponseLine ServerState)
{
	local Mutator M;
	local GameRules G;
	local int i, Len, NumMutators;
	local string MutatorName;
	local bool bFound;

	AddServerDetail(ServerState, "ServerMode", Eval(Level.NetMode == NM_ListenServer, "non-dedicated", "dedicated"));
	AddServerDetail(ServerState, "AdminName", GameReplicationInfo.AdminName);
	AddServerDetail(ServerState, "AdminEmail", GameReplicationInfo.AdminEmail);
	AddServerDetail(ServerState, "ServerVersion", Level.EngineVersion);
	AddServerDetail(ServerState, "CurrentWave", (WaveNum + 1)$"/"$FinalWave);

	if (AccessControl != None && AccessControl.RequiresPassword())
		AddServerDetail(ServerState, "GamePassword", "True");

	AddServerDetail(ServerState, "GameStats", GameStats != None);

	if (AllowGameSpeedChange() && (GameSpeed != 1.0))
		AddServerDetail(ServerState, "GameSpeed", int(GameSpeed*100)/100.0);

	AddServerDetail(ServerState, "FriendlyFireScale", int(FriendlyFireScale*100) $ "%");
	AddServerDetail(ServerState, "MaxSpectators", MaxSpectators);
	AddServerDetail(ServerState, "Translocator", bAllowTrans);
	AddServerDetail(ServerState, "WeaponStay", bWeaponStay);
	AddServerDetail(ServerState, "ForceRespawn", bForceRespawn);

	if (VotingHandler != None)
		VotingHandler.GetServerDetails(ServerState);

	for(M = BaseMutator; M != None; M = M.NextMutator)
	{
		M.GetServerDetails(ServerState);
		NumMutators++;
	}

	for(G = GameRulesModifiers; G != None; G = G.NextGameRules)
		G.GetServerDetails(ServerState);

	for(i = 0; i < ServerState.ServerInfo.Length; i++)
		if (ServerState.ServerInfo[i].Key ~= "Mutator")
			NumMutators--;

	if (NumMutators > 1)
	{
		for(M = BaseMutator.NextMutator; M != None; M = M.NextMutator)
		{
			MutatorName = M.GetHumanReadableName();
			for(i = 0; i < ServerState.ServerInfo.Length; i++)
			{
				if ((ServerState.ServerInfo[i].Value ~= MutatorName) && (ServerState.ServerInfo[i].Key ~= "Mutator"))
				{
					bFound = true;
					break;
				}
			}
			if (!bFound)
			{
				Len = ServerState.ServerInfo.Length;
				ServerState.ServerInfo.Length = Len+1;
				ServerState.ServerInfo[i].Key = "Mutator";
				ServerState.ServerInfo[i].Value = MutatorName;
			}
		}
	}
}

static event bool AcceptPlayInfoProperty(string PropertyName)
{
	if ((PropertyName == "bBalanceTeams") || (PropertyName == "bPlayersBalanceTeams") || (PropertyName == "GoalScore"))
		return false;

	return Super.AcceptPlayInfoProperty(PropertyName);
}

defaultproperties
{
     MaxAlive=26
     bRespawn=True
     bPreload=True
     bHitSound=True
     bAllowTaunts=False
     bAllowTrans=True
     bAllowVehicles=True
     bPlayersMustBeReady=False
     SpawnProtectionTime=0.000000
     WaveConfigMenu="fpsInv.Fails"
     ScoreBoardType="fpsInv.FailsSB"
     HUDType="fpsInv.FailsHud"
     PlayerControllerClassName="fpsInv.PlayerInv"
     GameReplicationInfoClass=Class'fpsInv.FailsGRI'
     GameName="Fails Invasion"
     Description="FPS - Fails Per Seconds - Fails Invasion. voltz"
     Acronym="FPS Inv"
}
