class RW_Healer extends OneDropRPGWeapon
	Config(fps)
	HideDropDown
	CacheExempt;

var RPGRules rules;

var config float EXPMultiplier;
var config float DamageBonus;
var config float HealthBonus;
var config int MaxHealth;

function PreBeginPlay()
{
	local GameRules G;
	local HealableDamageGameRules SG;

	super.PreBeginPlay();

	if (Level.Game.GameRulesModifiers == None)
	{
		SG = Level.Game.Spawn(class'HealableDamageGameRules');
		if (SG == None)
			log("Warning: Unable to spawn HealableDamageGameRules for RW_Healer. Healing for EXP will not occur.");
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
					log("Warning: Unable to spawn HealableDamageGameRules for RW_Healer. Healing for EXP will not occur.");
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
	local int x;
	local class<ProjectileFire> ProjFire;

	if (Other.Level.Game.bTeamGame)
	{
		return true;
	}
	else
	{
		for (x = 0; x < NUM_FIRE_MODES; x++)
			if (!ClassIsChildOf(Weapon.default.FireModeClass[x], class'InstantFire'))
			{
				ProjFire = class<ProjectileFire>(Weapon.default.FireModeClass[x]);
				if (ProjFire == None || ProjFire.default.ProjectileClass == None || ProjFire.default.ProjectileClass.default.DamageRadius > 0)
					return true;
			}
	}

	return false;
}

function NewAdjustTargetDamage(out int Damage, int OriginalDamage, Actor Victim, vector HitLocation, out vector Momentum, class<DamageType> DamageType)
{
	local Pawn P;
	local int BestDamage, HealthGiven, localMaxHealth;

	if (!class'OneDropRPGWeapon'.static.CheckCorrectDamage(ModifiedWeapon, DamageType))
		return;

	if (damage > 0)
	{
		if (Damage < (OriginalDamage * class'OneDropRPGWeapon'.default.MinDamagePercent))
			Damage = OriginalDamage * class'OneDropRPGWeapon'.default.MinDamagePercent;

		Damage = Max(1, Damage * (1.0 + DamageBonus * Modifier));
		Momentum *= 1.0 + DamageBonus * Modifier;
	}

	BestDamage = Max(Damage, OriginalDamage);
	
	P = Pawn(Victim);
	
	if (P != None && P.isA('Vehicle') && Vehicle(P).Driver != None)
		P = Vehicle(P).Driver;

	if (P != None && BestDamage > 0)
	{
		localMaxHealth = getMaxHealthBonus();
		if (P != None && (P == Instigator || (P.GetTeam() == Instigator.GetTeam() && Instigator.GetTeam() != None)))
		{
			Momentum = vect(0,0,0);
			Damage = 0;
			
			if (!P.isA('Vehicle'))
			{
				HealthGiven = Max(1, BestDamage * (HealthBonus * Modifier));

				HealthGiven = Min((P.HealthMax + localMaxHealth) - P.Health, HealthGiven);

				if (HealthGiven > 0)
				{
					P.GiveHealth(HealthGiven, P.HealthMax + localMaxHealth);
					P.SetOverlayMaterial(ModifierOverlay, 1.0, false);
					doHealed(HealthGiven, P, localMaxHealth);
				}
			}
		}
	}

	if (HealthGiven > 0)
	{
		if (!bIdentified)
			Identify();
	}

	if (HealthGiven > 0 && P != None && PlayerController(P.Controller) != None)	
	{
		PlayerController(P.Controller).ReceiveLocalizedMessage(class'HealedConditionMessage', 0, Instigator.PlayerReplicationInfo);
		P.PlaySound(sound'PickupSounds.HealthPack',, 2 * P.TransientSoundVolume,, 1.5 * P.TransientSoundRadius);
	}

	Super.NewAdjustTargetDamage(Damage, OriginalDamage, Victim, HitLocation, Momentum, DamageType);
}

function doHealed(int HealthGiven, Pawn Victim, int localMaxHealth)
{
	local HealableDamageInv Inv;
	local int ValidHealthGiven;
	local float GrantExp;
	local RPGStatsInv StatsInv;
	local float localEXPMultiplier;
	
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
		ValidHealthGiven = Min(HealthGiven, Inv.Damage);
		if (ValidHealthGiven > 0)
		{
			StatsInv = RPGStatsInv(Instigator.FindInventoryType(class'RPGStatsInv'));
			if (StatsInv == None)
			{
				log("Warning: No stats inv found. Healing exp not granted.");
				return;
			}

			localExpMultiplier = getExpMultiplier();

			GrantExp = localEXPMultiplier * float(ValidHealthGiven);

			Inv.Damage -= ValidHealthGiven;

			rules.ShareExperience(StatsInv, GrantExp);
		}

		if (Inv.Damage > (Victim.HealthMax + Class'HealableDamageGameRules'.default.MaxHealthBonus) - Victim.Health)
			Inv.Damage = Max(0, (Victim.HealthMax + Class'HealableDamageGameRules'.default.MaxHealthBonus) - Victim.Health); //never let it go negative.
	}
}

function int getMaxHealthBonus()
{
	return MaxHealth;
}

function float getExpMultiplier()
{
	return EXPMultiplier;
}

defaultproperties
{
     EXPMultiplier=0.010000
     DamageBonus=0.010000
     HealthBonus=0.050000
     MaxHealth=50
     ModifierOverlay=Shader'BlueShader'
     MinModifier=1
     MaxModifier=3
     AIRatingBonus=0.090000
     PrefixPos="Healing "
}
