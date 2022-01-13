class RW_Luck extends RPGWeapon
	HideDropDown
	CacheExempt
	config(fps);

var float NextEffectTime;
var config float DamageBonus;

function Generate(RPGWeapon ForcedWeapon)
{
	Super.Generate(ForcedWeapon);

	if (RW_Luck(ForcedWeapon) != None && RW_Luck(ForcedWeapon).NextEffectTime > 0)
		NextEffectTime = RW_Luck(ForcedWeapon).NextEffectTime;
	else if (Modifier > 0)
		NextEffectTime = float(Rand(15) + 25) / (Modifier + 1);
	else
		NextEffectTime = (1.25 + FRand() * 1.25) / -(Modifier - 1);
}

function NewAdjustTargetDamage(out int Damage, int OriginalDamage, Actor Victim, vector HitLocation, out vector Momentum, class<DamageType> DamageType)
{
	if (damage > 0)
	{
		if (Damage < (OriginalDamage * class'OneDropRPGWeapon'.default.MinDamagePercent)) 
			Damage = OriginalDamage * class'OneDropRPGWeapon'.default.MinDamagePercent;
	}

	Super.NewAdjustTargetDamage(Damage, OriginalDamage, Victim, HitLocation, Momentum, DamageType);
}

function AdjustTargetDamage(out int Damage, Actor Victim, Vector HitLocation, out Vector Momentum, class<DamageType> DamageType)
{
	if (!bIdentified)
		Identify();

	if (!class'OneDropRPGWeapon'.static.CheckCorrectDamage(ModifiedWeapon, DamageType))
		return;

	if (damage > 0)
	{
		Damage = Max(1, Damage * (1.0 + DamageBonus * Modifier));
		Momentum *= 1.0 + DamageBonus * Modifier;
	}
}

simulated function WeaponTick(float dt)
{
	local Pickup P;
	local class<Pickup> ChosenClass;
	local vector HitLocation, HitNormal, EndTrace;
	local Actor A;

	Super.WeaponTick(dt);

	if (Role < ROLE_Authority)
		return;

	NextEffectTime -= dt;
	if (NextEffectTime <= 0)
	{
		if (!bIdentified)
			Identify();

		if (Modifier < 0)
		{
			foreach Instigator.CollidingActors(class'Pickup', P, 300)
				if (P.ReadyToPickup(0) && WeaponLocker(P) == None)
				{
					A = spawn(class'RocketExplosion',,, P.Location);
					if (A != None)
					{
						A.RemoteRole = ROLE_SimulatedProxy;
						A.PlaySound(sound'WeaponSounds.BExplosion3',,2.5*P.TransientSoundVolume,,P.TransientSoundRadius);
					}
					if (!P.bDropped && WeaponPickup(P) != None && WeaponPickup(P).bWeaponStay && P.RespawnTime != 0.0)
						P.GotoState('Sleeping');
					else
						P.SetRespawn();
					break;
				}
			NextEffectTime = (1.25 + FRand() * 1.25) / -(Modifier - 1);
		}
		else
		{
			ChosenClass = ChoosePickupClass();
			EndTrace = Instigator.Location + vector(Instigator.Rotation) * Instigator.GroundSpeed;
			if (Instigator.Trace(HitLocation, HitNormal, EndTrace, Instigator.Location) != None)
			{
				HitLocation -= vector(Instigator.Rotation) * 40;
				P = spawn(ChosenClass,,, HitLocation);
			}
			else
				P = spawn(ChosenClass,,, EndTrace);

			if (P == None)
				return;

			if (MiniHealthPack(P) != None)
				MiniHealthPack(P).HealingAmount *= 2;
			else if (AdrenalinePickup(P) != None)
				AdrenalinePickup(P).AdrenalineAmount *= 2;
			P.RespawnTime = 0.0;
			P.bDropped = true;
			P.GotoState('Sleeping');

			NextEffectTime = float(Rand(15) + 25) / (Modifier + 1);
		}
	}
}

function class<Pickup> ChoosePickupClass()
{
	local array<class<Pickup> > Potentials;
	local Inventory Inv;
	local Weapon W;
	local class<Pickup> AmmoPickupClass;
	local int i, Count;

	if (Instigator.Health < Instigator.HealthMax)
	{
		Potentials[i++] = class'HealthPack';
		Potentials[i++] = class'MiniHealthPack';
	}
	else
	{
		if (Instigator.Health < Instigator.HealthMax + 99)
		{
			Potentials[i++] = class'MiniHealthPack';
			Potentials[i++] = class'MiniHealthPack';
		}
		if (Instigator.ShieldStrength < 50)
			Potentials[i++] = class'ShieldPack';
	}
	for (Inv = Instigator.Inventory; Inv != None; Inv = Inv.Inventory)
	{
		W = Weapon(Inv);
		if (W != None)
		{
			if (W.NeedAmmo(0))
			{
				AmmoPickupClass = W.AmmoPickupClass(0);
				if (AmmoPickupClass != None)
					Potentials[i++] = AmmoPickupClass;
			}
			else if (W.NeedAmmo(1))
			{
				AmmoPickupClass = W.AmmoPickupClass(1);
				if (AmmoPickupClass != None)
					Potentials[i++] = AmmoPickupClass;
			}
		}
		Count++;
		if (Count > 1000)
			break;
	}
	if (FRand() < 0.015 * Modifier)
		Potentials[i++] = class'UDamagePack';
	if (i == 0 || (Instigator.Controller != None && Instigator.Controller.Adrenaline < Instigator.Controller.AdrenalineMax))
		Potentials[i++] = class'AdrenalinePickup';

	return Potentials[Rand(i)];
}

simulated function int MaxAmmo(int mode)
{
	if (bNoAmmoInstances && HolderStatsInv != None)
		return (ModifiedWeapon.MaxAmmo(mode) * (1.0 + 0.01 * HolderStatsInv.Data.AmmoMax));

	return ModifiedWeapon.MaxAmmo(mode);
}

defaultproperties
{
     DamageBonus=0.030000
     ModifierOverlay=FinalBlend'MutantSkins.Shaders.MutantGlowFinal'
     MinModifier=-1
     MaxModifier=7
     AIRatingBonus=0.025000
     PrefixPos="Lucky "
     PostfixNeg=" of Misfortune"
}
