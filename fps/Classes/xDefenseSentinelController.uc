class xDefenseSentinelController extends Controller
	config(fps);

var Controller PlayerSpawner;
var RPGStatsInv StatsInv;
var MutFPS RPGMut;

var config float TimeBetweenShots;
var config float TargetRadius;
var config float XPPerHit;
var config float XPPerHealing;
var config int HealFreq;

var float DamageAdjust;

var class<xEmitter> HitEmitterClass;
var class<xEmitter> ShieldEmitterClass;
var class<xEmitter> HealthEmitterClass;
var class<xEmitter> AdrenalineEmitterClass;
var class<xEmitter> ResupplyEmitterClass;
var class<xEmitter> ArmorEmitterClass;

var Material HealingOverlay;

var bool bHealing;
var int DoHealCount;

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
		if (StatsInv != None)
			TimeBetweenShots = (default.TimeBetweenShots * 100)/(100 + StatsInv.Data.WeaponSpeed);
		if (DamageAdjust > 0.1)
			TimeBetweenShots = TimeBetweenShots / DamageAdjust;
	}
	SetTimer(TimeBetweenShots, true);
}

function DoHealing()
{
	local Controller C;
	local xEmitter HitEmitter;
	local Pawn LoopP, RealP;
	local xDefenseSentinel DefPawn;
	local float NumHelped;
	local HealableDamageInv HDInv;
	local Mutator m;
	
	if (Pawn == None || Pawn.Health <= 0 || xDefenseSentinel(Pawn) == None)
		return;

	DefPawn = xDefenseSentinel(Pawn);
	if (DefPawn.ShieldHealingLevel == 0 && DefPawn.HealthHealingLevel == 0 && DefPawn.AdrenalineHealingLevel == 0 && DefPawn.ResupplyLevel == 0 && DefPawn.ArmorHealingLevel == 0)
		return;

	NumHelped = 0.0;

	if (bHealing)
	{
		Log("=================!!!!! bHealing still set ");
		return;
	}
	bHealing = true;

	foreach DynamicActors(class'Pawn', LoopP)
	{
		if (LoopP != None && VSize(LoopP.Location - DefPawn.Location) < TargetRadius && FastTrace(LoopP.Location, DefPawn.Location))
		{
			C = LoopP.Controller;
			if (C != None && DefPawn != None && LoopP != DefPawn && LoopP.Health > 0 && C.SameTeamAs(self))
			{
				RealP = LoopP;
				if (LoopP != None && LoopP.isA('Vehicle'))
					RealP = Vehicle(LoopP).Driver;

				if (RealP != None && xPawn(RealP) != None)
				{
					if (DefPawn.ShieldHealingLevel > 0 && RealP.GetShieldStrength() < RealP.GetShieldStrengthMax())
					{
						RealP.AddShieldStrength((DefPawn.ShieldHealingAmount * DefPawn.ShieldHealingLevel * RealP.GetShieldStrengthMax())/100.0);

						HitEmitter = spawn(ShieldEmitterClass,,, DefPawn.Location, rotator(RealP.Location - DefPawn.Location));
						if (HitEmitter != None)
							HitEmitter.mSpawnVecA = RealP.Location;

						if (PlayerController(C) != None)
						{
							PlayerController(C).ReceiveLocalizedMessage(class'HealShieldConditionMessage', 0, PlayerReplicationInfo);
							RealP.PlaySound(sound'PickupSounds.ShieldPack',, 2 * RealP.TransientSoundVolume,, 1.5 * RealP.TransientSoundRadius);
						}

						HDInv = HealableDamageInv(RealP.FindInventoryType(class'HealableDamageInv'));
						if (HDInv != None)
						{
							if (HDInv.Damage > (RealP.HealthMax + Class'HealableDamageGameRules'.default.MaxHealthBonus) - RealP.Health)
								HDInv.Damage = Max(0, (RealP.HealthMax + Class'HealableDamageGameRules'.default.MaxHealthBonus) - RealP.Health);
						}
						if (PlayerSpawner != C)
							NumHelped += (DefPawn.ShieldHealingLevel * 2);
					}
					else if (DefPawn.HealthHealingLevel > 0 && RealP.Health < (RealP.HealthMax + 100))
					{
						RealP.GiveHealth(max(1,(DefPawn.HealthHealingAmount * DefPawn.HealthHealingLevel * (RealP.HealthMax + 100))/100.0), RealP.HealthMax + 100);
						RealP.SetOverlayMaterial(HealingOverlay, 1.0, false);

						HitEmitter = spawn(HealthEmitterClass,,, DefPawn.Location, rotator(RealP.Location - DefPawn.Location));
						if (HitEmitter != None)
							HitEmitter.mSpawnVecA = RealP.Location;

						if (PlayerController(C) != None)
						{
							PlayerController(C).ReceiveLocalizedMessage(class'HealedConditionMessage', 0, PlayerReplicationInfo);
							RealP.PlaySound(sound'PickupSounds.HealthPack',, 2 * RealP.TransientSoundVolume,, 1.5 * RealP.TransientSoundRadius);
						}

						HDInv = HealableDamageInv(RealP.FindInventoryType(class'HealableDamageInv'));
						if (HDInv != None)
						{
							if (HDInv.Damage > (RealP.HealthMax + Class'HealableDamageGameRules'.default.MaxHealthBonus) - RealP.Health)
								HDInv.Damage = Max(0, (RealP.HealthMax + Class'HealableDamageGameRules'.default.MaxHealthBonus) - RealP.Health);
						}
						if (PlayerSpawner != C)
							NumHelped += (DefPawn.HealthHealingLevel * 3);
					}
					else if (DefPawn.AdrenalineHealingLevel > 0 && C.Adrenaline < C.AdrenalineMax && !RealP.InCurrentCombo() && !class'ActiveArtifactInv'.static.hasActiveArtifact(RealP))
					{
						C.AwardAdrenaline((DefPawn.AdrenalineHealingAmount * DefPawn.AdrenalineHealingLevel * C.AdrenalineMax)/100.0);

						HitEmitter = spawn(AdrenalineEmitterClass,,, DefPawn.Location, rotator(RealP.Location - DefPawn.Location));
						if (HitEmitter != None)
							HitEmitter.mSpawnVecA = RealP.Location;

						if (PlayerController(C) != None)
						{
							PlayerController(C).ReceiveLocalizedMessage(class'HealAdrenalineConditionMessage', 0, PlayerReplicationInfo);
							RealP.PlaySound(sound'PickupSounds.AdrenelinPickup',, 2 * RealP.TransientSoundVolume,, 1.5 * RealP.TransientSoundRadius);
						}

						if (PlayerSpawner != C)
							NumHelped += DefPawn.AdrenalineHealingLevel;
					}
					else if (DefPawn.ResupplyLevel > 0 && RealP.Weapon != None && RealP.Weapon.AmmoClass[0] != None
					     && !class'MutFPS'.static.IsSuperWeaponAmmo(RealP.Weapon.AmmoClass[0]) && !RealP.Weapon.AmmoMaxed(0))
					{
						RealP.Weapon.AddAmmo(max(1,(DefPawn.ResupplyAmount * DefPawn.ResupplyLevel * RealP.Weapon.AmmoClass[0].default.MaxAmmo)/100.0), 0);

						HitEmitter = spawn(ResupplyEmitterClass,,, DefPawn.Location, rotator(RealP.Location - DefPawn.Location));
						if (HitEmitter != None)
							HitEmitter.mSpawnVecA = RealP.Location;

						if (PlayerController(C) != None)
						{
							PlayerController(C).ReceiveLocalizedMessage(class'HealAmmoConditionMessage', 0, PlayerReplicationInfo);
							RealP.PlaySound(sound'PickupSounds.AssaultAmmoPickup',, 2 * RealP.TransientSoundVolume,, 1.5 * RealP.TransientSoundRadius);
						}

						if (PlayerSpawner != C)
							NumHelped += DefPawn.ResupplyLevel;
					}
				}
			}

			if (DefPawn != None && DefPawn.ArmorHealingLevel > 0)
			{
				if (LoopP != None && LoopP != DefPawn && LoopP.Health > 0)
				{
					if (Vehicle(LoopP) != None || xEnergyWall(LoopP) != None)
					{
						if (LoopP.GetTeamNum() == DefPawn.GetTeamNum() && LoopP.Health < LoopP.HealthMax)
						{
							LoopP.GiveHealth(max(1,(DefPawn.ArmorHealingAmount * DefPawn.ArmorHealingLevel * LoopP.HealthMax)/100.0), LoopP.HealthMax);
							HitEmitter = spawn(ArmorEmitterClass,,, DefPawn.Location, rotator(LoopP.Location - DefPawn.Location));
							if (HitEmitter != None)
								HitEmitter.mSpawnVecA = LoopP.Location;

						}
					}
				}
			}
		}
	}

	if ((XPPerHealing > 0) && (NumHelped > 0) && PlayerSpawner != None && PlayerSpawner.Pawn != None)
	{
		if (StatsInv == None)
			StatsInv = RPGStatsInv(PlayerSpawner.Pawn.FindInventoryType(class'RPGStatsInv'));

		if (RPGMut == None && Level.Game != None)
		{
			for (m = Level.Game.BaseMutator; m != None; m = m.NextMutator)
				if (MutFPS(m) != None)
				{
					RPGMut = MutFPS(m);
					break;
				}
		}
		if ((StatsInv != None) && (StatsInv.DataObject != None) && (RPGMut != None))
			StatsInv.DataObject.AddExperienceFraction(XPPerHealing * NumHelped, RPGMut, PlayerSpawner.Pawn.PlayerReplicationInfo);
	}

	bHealing = false;
}

function Timer()
{
	local Projectile P;
	local xEmitter HitEmitter;
	local Projectile ClosestP;
	local Projectile BestGuidedP;
	local Projectile BestP;
	local int ClosestPdist, BestGuidedPdist;
	local Mutator m;
	Local xDefenseSentinel DefPawn;
	local ONSMineProjectile Mine;

	if (PlayerSpawner == None || PlayerSpawner.Pawn == None || Pawn == None || Pawn.Health <= 0 || xDefenseSentinel(Pawn) == None)
		return;

	DefPawn = xDefenseSentinel(Pawn);

	ClosestP = None;
	BestGuidedP = None;
	ClosestPdist = TargetRadius+1;
	BestGuidedPdist = TargetRadius+1;
	ForEach DynamicActors(class'Projectile',P)
	{
		if (P != None && FastTrace(P.Location, Pawn.Location) && TranslocatorBeacon(P) == None && VSize(Pawn.Location - P.Location) <= TargetRadius)
		{
			if ((P.InstigatorController == None || (P.InstigatorController != None && ((TeamGame(Level.Game) != None && !P.InstigatorController.SameTeamAs(PlayerSpawner))
			     || (TeamGame(Level.Game) == None && P.InstigatorController != PlayerSpawner)))))
			{
				if (BestGuidedPdist > VSize(Pawn.Location - P.Location) && P.bNetTemporary == false && !P.bDeleteMe)
				{
					BestGuidedP = P;
					BestGuidedPdist = VSize(Pawn.Location - P.Location);
				}
				if (ClosestPdist > VSize(Pawn.Location - P.Location) && !P.bDeleteMe)
				{
					ClosestP = P;
					ClosestPdist = VSize(Pawn.Location - P.Location);
				}
			}
			else
			{
				if (DefPawn.SpiderBoostLevel > 0 && DefPawn.ResupplyLevel > 0 && ONSMineProjectile(P) != None)
				{
					Mine = ONSMineProjectile(P);
					if (Mine.Damage < ((1 + DefPawn.SpiderBoostLevel) * Mine.default.Damage))
					{
						class'EngineerLinkFire'.static.BoostMine(Mine,(10.0 + DefPawn.ResupplyLevel)/10.0);
						HitEmitter = spawn(ResupplyEmitterClass,,, DefPawn.Location, rotator(P.Location - DefPawn.Location));
						if (HitEmitter != None)
							HitEmitter.mSpawnVecA = P.Location;
					}
				}
			}
		}
	}
	if (BestGuidedP != None)
		BestP = BestGuidedP;
	else
		BestP = ClosestP;

	if (BestP != None && !BestP.bDeleteMe)
	{
		HitEmitter = spawn(HitEmitterClass,,, Pawn.Location, rotator(BestP.Location - Pawn.Location));
		if (HitEmitter != None)
			HitEmitter.mSpawnVecA = BestP.Location;

		BestP.NetUpdateTime = Level.TimeSeconds - 1;
		BestP.bHidden = true;
		if (BestP.Physics != PHYS_None)
		{
			BestP.Explode(BestP.Location,vect(0,0,0));
			if (StatsInv == None && PlayerSpawner != None && PlayerSpawner.Pawn != None)
				StatsInv = RPGStatsInv(PlayerSpawner.Pawn.FindInventoryType(class'RPGStatsInv'));
			if (RPGMut == None && Level.Game != None)
			{
				for (m = Level.Game.BaseMutator; m != None; m = m.NextMutator)
					if (MutFPS(m) != None)
					{
						RPGMut = MutFPS(m);
						break;
					}
			}
			if ((XPPerHit > 0) && (StatsInv != None) && (StatsInv.DataObject != None) && (RPGMut != None) && (PlayerSpawner != None) && (PlayerSpawner.Pawn != None))
				StatsInv.DataObject.AddExperienceFraction(XPPerHit, RPGMut, PlayerSpawner.Pawn.PlayerReplicationInfo);
		}
	}
	else
	{
		if ((TeamGame(Level.Game) != None))
		{
			DoHealCount++;
			if (DoHealCount >= HealFreq)
			{
				DoHealCount = 0;
				DoHealing();
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
     TimeBetweenShots=0.600000
     TargetRadius=700.000000
     XPPerHit=0.066000
     XPPerHealing=0.020000
     HealFreq=4
     DamageAdjust=1.000000
     HitEmitterClass=Class'fps.DefenseBoltEmitter'
     ShieldEmitterClass=Class'fps.GoldBoltEmitter'
     HealthEmitterClass=Class'fps.LightningBeamEmitter'
     AdrenalineEmitterClass=Class'fps.LightningBoltEmitter'
     ResupplyEmitterClass=Class'fps.RedBoltEmitter'
     ArmorEmitterClass=Class'fps.BronzeBoltEmitter'
     HealingOverlay=Shader'BlueShader'
}
