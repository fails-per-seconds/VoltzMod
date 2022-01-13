class RW_EngineerLink extends RW_Infinity
	config(fps);

var config Array<float> DamageBonusFromLinks;
var config float ShieldHealingXPPercent;
var config float SpiderGrowthRate;

var int HealingLevel;
var float ShieldHealingPercent, SpiderBoost;

var RPGRules rules;

function PreBeginPlay()
{
	local GameRules G;
	local HealableDamageGameRules SG;

	Super.PreBeginPlay();

	if (Level.Game == None)
	{
		log("Warning: Game not started. Cannot add HealableDamageGameRules for RW_EngineerLink. Healing for EXP will not occur.");
		return;	
	}

	if (Level.Game.GameRulesModifiers == None)
	{
		SG = Level.Game.Spawn(class'HealableDamageGameRules');
		if (SG == None)
			log("Warning: Unable to spawn HealableDamageGameRules for RW_EngineerLink. Healing for EXP will not occur.");
		else
			Level.Game.GameRulesModifiers = SG;
	}
	else
	{
		for(G = Level.Game.GameRulesModifiers; G != None; G = G.NextGameRules)
		{
			if (G.isA('HealableDamageGameRules'))
			{
				SG = HealableDamageGameRules(G);
				break;
			}
			if (G.NextGameRules == None)
			{
				SG = Level.Game.Spawn(class'HealableDamageGameRules');
				if (SG == None)
				{
					log("Warning: Unable to spawn HealableDamageGameRules for RW_EngineerLink. Healing for EXP will not occur.");
					return;
				}

				Level.Game.GameRulesModifiers.AddGameRules(SG);
				break;
			}
		}
	}
}

function PostBeginPlay()
{
	Super.PostBeginPlay();

	setupRules();
}

function setupRules()
{
	local GameRules G;

	if (rules != None)
		return;
	if (Level.Game == None)
		return;

	if (Level.Game.GameRulesModifiers == None)
	{
		log("Unable to find RPG Rules. Will retry");
		return;
	}
	else
	{
		for(G = Level.Game.GameRulesModifiers; G != None; G = G.NextGameRules)
		{
			if (G.isA('RPGRules'))
				break;
			if (G.NextGameRules == None)
				log("Unable to find RPG Rules. Will retry");
		}
	}
	rules = RPGRules(G);
}

static function bool AllowedFor(class<Weapon> Weapon, Pawn Other)
{
	if (ClassIsChildOf(Weapon.Class,class'LinkGun'))
		return true;

	return false;
}

simulated function bool CanThrow()
{
	return false;
}

simulated function ConstructItemName()
{
	ItemName = PrefixPos$ModifiedWeapon.ItemName$PostfixPos;
}

function DropFrom(vector StartLocation)
{
	Destroy();
}

function HealShield(Pawn P, int ShieldDamage)
{
	local int ShieldGiven, CurShield, MaxShield;

	CurShield = P.GetShieldStrength();
	MaxShield = P.GetShieldStrengthMax();
	if (CurShield < MaxShield)
	{
		ShieldGiven = Max(1, ShieldDamage * HealingLevel * ShieldHealingPercent);
		ShieldGiven = Min(MaxShield - CurShield, ShieldGiven);
		P.AddShieldStrength(ShieldGiven);

		if (ShieldGiven > 0 && PlayerController(P.Controller) != None)	
		{
			PlayerController(P.Controller).ReceiveLocalizedMessage(class'HealShieldConditionMessage', 0, Instigator.PlayerReplicationInfo);
			P.PlaySound(sound'PickupSounds.ShieldPack',, 2 * P.TransientSoundVolume,, 1.5 * P.TransientSoundRadius);
		}

		doHealed(ShieldGiven, P);
	}
}

function NewAdjustTargetDamage(out int Damage, int OriginalDamage, Actor Victim, vector HitLocation, out vector Momentum, class<DamageType> DamageType)
{
	local Pawn P;
	local int BestDamage;

	if (!class'OneDropRPGWeapon'.static.CheckCorrectDamage(ModifiedWeapon, DamageType))
		return;

	if (damage > 0)
	{
		if (Damage < (OriginalDamage * class'OneDropRPGWeapon'.default.MinDamagePercent)) 
			Damage = OriginalDamage * class'OneDropRPGWeapon'.default.MinDamagePercent;

		Damage = Max(1, Damage * (1.0 + DamageBonus * Modifier));
		Momentum *= 1.0 + DamageBonus * Modifier;
	}

	P = Pawn(Victim);

	if (ClassIsChildOf(DamageType,class'DamTypeLinkShaft') && P != None && P.isA('Vehicle') && P.GetTeam() == Instigator.GetTeam() && Instigator.GetTeam() != None)
		Momentum = vect(0,0,0);

	if (!ClassIsChildOf(DamageType,class'DamTypeLinkShaft') || P == None || P.isA('Vehicle') || HealingLevel == 0)
	{
		Super.NewAdjustTargetDamage(Damage, OriginalDamage, Victim, HitLocation, Momentum, DamageType);
		return;
	}

	if (P != Instigator)
	{
		Super.NewAdjustTargetDamage(Damage, OriginalDamage, Victim, HitLocation, Momentum, DamageType);
		return;
	}

	BestDamage = Max(Damage, OriginalDamage);
	if (BestDamage == 0)
		BestDamage = 10;

	if (P != None && BestDamage > 0)
	{
		if (P.GetTeam() == Instigator.GetTeam() && Instigator.GetTeam() != None)
		{
			HealShield(P,BestDamage);

			Momentum = vect(0,0,0);
			Damage = 0;
		}
	}

	Super.NewAdjustTargetDamage(Damage, OriginalDamage, Victim, HitLocation, Momentum, DamageType);
}

function doHealed(int ShieldGiven, Pawn Victim)
{
	local HealableDamageInv Inv;
	local int ValidHealthGiven;
	local float GrantExp;
	local RPGStatsInv StatsInv;

	setupRules();
	if (rules == None)
		return;

	if (Victim.Controller != None && Victim.Controller.IsA('FriendlyMonsterController'))
		return;

	if (Instigator == Victim) 
		return;

	Inv = HealableDamageInv(Victim.FindInventoryType(class'HealableDamageInv'));
	if (Inv != None)
	{
		ValidHealthGiven = Min(ShieldGiven, Inv.Damage);
		if (ValidHealthGiven > 0)
		{
			StatsInv = RPGStatsInv(Instigator.FindInventoryType(class'RPGStatsInv'));
			if (StatsInv == None)
			{
				log("Warning: No stats inv found. Healing exp not granted.");
				return;
			}

			GrantExp = HealingLevel * ShieldHealingXPPercent * float(ValidHealthGiven);

			Inv.Damage = Max(0, Inv.Damage - ValidHealthGiven);

			rules.ShareExperience(StatsInv, GrantExp);
		}

		if (Inv.Damage > (Victim.HealthMax + Class'HealableDamageGameRules'.default.MaxHealthBonus) - Victim.Health)
			Inv.Damage = Max(0, (Victim.HealthMax + Class'HealableDamageGameRules'.default.MaxHealthBonus) - Victim.Health);
	}
}

function AdjustTargetDamage(out int Damage, Actor Victim, Vector HitLocation, out Vector Momentum, class<DamageType> DamageType)
{
	// dont need this
}

static function float DamageIncreasedByLinkers(int NumLinkers)
{
	if (NumLinkers <= 0)
		return 1.0;
		
	if (NumLinkers >= default.DamageBonusFromLinks.Length)
		return default.DamageBonusFromLinks[default.DamageBonusFromLinks.Length -1];
	else
		return default.DamageBonusFromLinks[NumLinkers];
}

static function float XPForLinker(float xpGained, int NumLinkers)
{
	local float fDamageDone, fDamageByAllLinkers, fDamagePerLinker;

	if (xpGained <= 0.0)
		return 0.0;

	fDamageDone = static.DamageIncreasedByLinkers(NumLinkers);		

	fDamageByAllLinkers = fDamageDone - 1.0;
	if (fDamageByAllLinkers <= 0.0)
		return 0.0;

	fDamagePerLinker = fDamageByAllLinkers / NumLinkers;

	return (xpGained * fDamagePerLinker)/fDamageDone;
}

defaultproperties
{
     DamageBonusFromLinks(0)=1.000000
     DamageBonusFromLinks(1)=1.750000
     DamageBonusFromLinks(2)=2.250000
     DamageBonusFromLinks(3)=2.500000
     ShieldHealingXPPercent=0.010000
     SpiderGrowthRate=1.100000
     DamageBonus=0.000000
     ModifierOverlay=Shader'ELinkShader'
     MinModifier=0
     MaxModifier=0
     PrefixPos="Engineer "
     PrefixNeg="Engineer "
     bCanThrow=False
}
