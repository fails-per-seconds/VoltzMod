class xIonCannon extends ASTurret_IonCannon;

var float LastHealTime;
var array<Controller> Healers;
var array<float> HealersLastLinkTime;
var int NumHealers;
var MutFPS RPGMut;
var bool IsLockedForSelf;
var Controller PlayerSpawner;
var Material LockOverlay;

replication
{
	reliable if (Role == ROLE_Authority)
		NumHealers;
}

simulated event PostBeginPlay()
{
	local Mutator m;
	
	NumHealers = 0;
	DefaultWeaponClassName=string(class'WeaponIonCannon');

	super.PostBeginPlay();

	if (Level.Game != None)
		for (m = Level.Game.BaseMutator; m != None; m = m.NextMutator)
			if (MutFPS(m) != None)
			{
				RPGMut = MutFPS(m);
				break;
			}
			
	if (Role == ROLE_Authority)		
		SetTimer(1, true);
}

function SetPlayerSpawner(Controller PlayerC)
{
	PlayerSpawner = PlayerC;
}

function Timer()
{
	local int i, validHealers;
	
	if (Role < ROLE_Authority)	
		return;	

	validHealers = 0;
	for(i = 0; i < Healers.length; i++)
	{
		if (HealersLastLinkTime[i] > Level.TimeSeconds-0.5)
		{
			if (i > validHealers)
			{
				HealersLastLinkTime[validHealers] = HealersLastLinkTime[i];
				Healers[validHealers] = Healers[i];
			}
			validHealers++;
		}
	}
	Healers.Length = validHealers;
	HealersLastLinkTime.length = validHealers;

	if (NumHealers != validHealers)
		NumHealers = validHealers;
}

function bool HealDamage(int Amount, Controller Healer, class<DamageType> DamageType)
{
	local int i;
	local bool gotit, healret;
	local Mutator m;

	if (RPGMut == None && Level.Game != None)
	{
		for (m = Level.Game.BaseMutator; m != None; m = m.NextMutator)
			if (MutFPS(m) != None)
			{
				RPGMut = MutFPS(m);
				break;
			}
	}

	gotit = false;
	if (Healer != None && TeamLink(Healer.GetTeamNum()))
	{	
		if (Healer.Pawn != None && ((Healer.Pawn.Weapon != None && RW_EngineerLink(Healer.Pawn.Weapon) != None) || xLinkSentinel(Healer.Pawn) != None))
		{
			for(i = 0; i < Healers.length; i++)
			{
				if (Healers[i] == Healer)
				{
					gotit = true;
					HealersLastLinkTime[i] = Level.TimeSeconds;
					i = Healers.length;
				}
			}
			if (!gotit)
			{
				Healers[Healers.length] = Healer;
				HealersLastLinkTime[HealersLastLinkTime.length] = Level.TimeSeconds;
			}
		}
	}

	healret = Super.HealDamage(Amount, Healer, DamageType);
	if (healret)
	{
		LastHealTime = Level.TimeSeconds;
	}
	return healret;
}

function bool TryToDrive(Pawn P)
{
	if ((P.Controller == None) || !P.Controller.bIsPlayer || Health <= 0)
		return false;

	if (IsEngineerLocked() && P.Controller != PlayerSpawner)
	{
		if (PlayerController(P.Controller) != None)
		{
			if (PlayerSpawner != None)
				PlayerController(P.Controller).ReceiveLocalizedMessage(class'EngLockedMessage', 0, PlayerSpawner.PlayerReplicationInfo);
			else
				PlayerController(P.Controller).ReceiveLocalizedMessage(class'EngLockedMessage', 0);
		}
		return false;
	}
	else
	{
		return super.TryToDrive(P);
	}
}

function EngineerLock()
{
	IsLockedForSelf = True;
	SetOverlayMaterial(LockOverlay, 50000.0, false);
}

function EngineerUnlock()
{
	IsLockedForSelf = False;
	SetOverlayMaterial(LockOverlay, 0.0, false);
}

function bool IsEngineerLocked()
{
	return IsLockedForSelf;
}

function KDriverEnter(Pawn P)
{
	Super.KDriverEnter(P);

	if (Weapon != None && Driver != None && xPawn(Driver) != None && Driver.HasUDamage())
		Weapon.SetOverlayMaterial(xPawn(Driver).UDamageWeaponMaterial, xPawn(Driver).UDamageTime - Level.TimeSeconds, false);
}

function bool KDriverLeave( bool bForceLeave )
{
	if (Weapon != None && Controller != None && xPawn(Controller.Pawn) != None && Controller.Pawn.HasUDamage())
		Weapon.SetOverlayMaterial(xPawn(Controller.Pawn).UDamageWeaponMaterial, 0, false);

	return Super.KDriverLeave(bForceLeave);
}

function DriverDied()
{
	if (Weapon != None && xPawn(Driver) != None && Driver.HasUDamage())
		Weapon.SetOverlayMaterial(xPawn(Driver).UDamageWeaponMaterial, 0, false);

	Super.DriverDied();
}

function bool HasUDamage()
{
	return (Driver != None && Driver.HasUDamage());
}

defaultproperties
{
     LockOverlay=Shader'RedShader'
     TurretBaseClass=Class'fps.xIonCannonBase'
     TurretSwivelClass=Class'fps.xIonCannonSwivel'
     RotPitchConstraint=(Min=12084.000000)
     CamRelLocation=(Z=100.000000)
     CamDistance=(X=-200.000000)
     DefaultWeaponClassName=""
     VehicleProjSpawnOffset=(X=110.000000,Z=30.000000)
     ExitPositions(0)=(X=0.000000,Y=100.000000,Z=100.000000)
     ExitPositions(1)=(X=0.000000,Y=-100.000000,Z=100.000000)
     EntryPosition=(X=0.000000,Y=0.000000,Z=0.000000)
     FPCamPos=(X=100.000000,Z=100.000000)
     HealthMax=900.000000
     Health=900
     DrawScale=0.150000
     CollisionRadius=52.000000
     CollisionHeight=80.000000
}