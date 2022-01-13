class xEnergyTurret extends ONSManualGunPawn;

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

function Died(Controller Killer, class<DamageType> damageType, vector HitLocation)
{
	local PlayerController PC;
	local Controller C;

	if (bDeleteMe || Level.bLevelChange)
		return;

	if (Level.Game.PreventDeath(self, Killer, damageType, HitLocation))
	{
		Health = max(Health, 1);
		return;
	}
	Health = Min(0, Health);

	if (Controller != None)
	{
		C = Controller;
		C.WasKilledBy(Killer);
		Level.Game.Killed(Killer, C, self, damageType);
		if(C.bIsPlayer)
		{
			PC = PlayerController(C);
			if (PC != None)
				ClientKDriverLeave(PC);
			else
                		ClientClearController();
			if (bRemoteControlled && (Driver != None) && (Driver.Health > 0))
			{
				C.Unpossess();
				C.Possess(Driver);
				Driver = None;
			}
			else
				C.PawnDied(self);
		}
		else
			C.Destroy();

		if (Driver != None)
    		{
			if (!bRemoteControlled)
			{
				if (!bDrawDriverInTP && PlaceExitingDriver())
				{
					Driver.StopDriving(self);
					Driver.DrivenVehicle = self;
				}
				Driver.TearOffMomentum = Velocity * 0.25;
				Driver.Died(Controller, class'DamRanOver', Driver.Location);
        	    }
	            else
				KDriverLeave(false);
		}
	}
	else
		Level.Game.Killed(Killer, Controller(Owner), self, damageType);

	if (Killer != None)
		TriggerEvent(Event, self, Killer.Pawn);
	else
		TriggerEvent(Event, self, None);

	if (IsHumanControlled())
		PlayerController(Controller).ForceDeathUpdate();

	Explode(HitLocation);
}

simulated function Explode( vector HitLocation )
{
	if (Level.NetMode != NM_DedicatedServer)
		Spawn(class'FX_SpaceFighter_Explosion', Self,, HitLocation, Rotation);
	Destroy();
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

	if (Gun != None)
		Gun.SetOverlayMaterial(LockOverlay, 50000.0, false);
}

function EngineerUnlock()
{
	IsLockedForSelf = False;

	if (Gun != None)
		Gun.SetOverlayMaterial(LockOverlay,0.0, false);
}

function bool IsEngineerLocked()
{
	return IsLockedForSelf;
}

simulated event TeamChanged()
{
	Super(ONSWeaponPawn).TeamChanged();
}

defaultproperties
{
     LockOverlay=Shader'RedShader'
     bPowered=True
     RespawnTime=5.000000
     GunClass=Class'fps.xEnergyWeapon'
     AutoTurretControllerClass=None
}
