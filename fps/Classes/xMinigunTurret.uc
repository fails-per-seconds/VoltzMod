class xMinigunTurret extends ASTurret_Minigun;

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

	DefaultWeaponClassName=string(class'xMiniTurretWeapon');

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

simulated function KDriverEnter(Pawn P)
{
	Super.KDriverEnter(P);

	if (Weapon != None && Driver != None && xPawn(Driver) != None && Driver.HasUDamage())
		Weapon.SetOverlayMaterial(xPawn(Driver).UDamageWeaponMaterial, xPawn(Driver).UDamageTime - Level.TimeSeconds, false);
}

simulated function bool KDriverLeave(bool bForceLeave)
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

function TakeDamage(int Damage, Pawn instigatedBy, Vector hitlocation, Vector momentum, class<DamageType> damageType)
{
	local int actualDamage;
	local bool bAlreadyDead;
	local Controller Killer;

	if (Role < ROLE_Authority)
	{
		log(self$" client damage type "$damageType$" by "$instigatedBy);
		return;
	}

	if (Level.Game == None)
		return;

	if (bSpawnProtected && instigatedBy != None && instigatedBy != Self)
		return;

	if (Level.TimeSeconds == DamLastDamageTime && instigatedBy == DamLastInstigator)
		return;

	DamLastInstigator = instigatedBy;
	DamLastDamageTime = Level.TimeSeconds;

	if (damagetype == None)
		DamageType = class'DamageType';

	Damage *= DamageType.default.VehicleDamageScaling;
	momentum *= DamageType.default.VehicleMomentumScaling * MomentumMult;
	bAlreadyDead = (Health <= 0);
	NetUpdateTime = Level.TimeSeconds - 1;

	if (Weapon != None)
		Weapon.AdjustPlayerDamage(Damage, InstigatedBy, HitLocation, Momentum, DamageType);
	if ((InstigatedBy != None) && InstigatedBy.HasUDamage())
		Damage *= 2;

	actualDamage = Level.Game.ReduceDamage(Damage, self, instigatedBy, HitLocation, Momentum, DamageType);

	if (DamageType.default.bArmorStops && (actualDamage > 0))
		actualDamage = ShieldAbsorb(actualDamage);

	if (bShowDamageOverlay && DamageType.default.DamageOverlayMaterial != None && actualDamage > 0)
		SetOverlayMaterial(DamageType.default.DamageOverlayMaterial, DamageType.default.DamageOverlayTime, true);

	Health -= actualDamage;

	if (HitLocation == vect(0,0,0))
		HitLocation = Location;
	if (bAlreadyDead)
		return;

	PlayHit(actualDamage,InstigatedBy, hitLocation, damageType, Momentum);
	if (Health <= 0)
	{
		if (Driver != None)
			KDriverLeave(false);

		if (instigatedBy != None)
			Killer = instigatedBy.GetKillerController();
		else if ((DamageType != None) && DamageType.default.bDelayedDamage)
			Killer = DelayedDamageInstigatorController;

		Health = 0;

		TearOffMomentum = momentum;

		Died(Killer, damageType, HitLocation);
	}
	else
	{
		if (Controller != None)
			Controller.NotifyTakeHit(instigatedBy, HitLocation, actualDamage, DamageType, Momentum);
	}

	MakeNoise(1.0);
}

simulated function Destroyed_HandleDriver()
{
	Driver.LastRenderTime = LastRenderTime;
	if (Role != ROLE_Authority)
		if (Driver.DrivenVehicle == self)
			Driver.StopDriving(self);
}

defaultproperties
{
     LockOverlay=Shader'RedShader'
     DefaultWeaponClassName=""
     DriverDamageMult=0.000000
}
