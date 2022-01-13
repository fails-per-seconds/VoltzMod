class RegenInv extends Inventory
	config(fps);

//shield
var int NoDamageDelay, MaxShieldRegen, lastHealth, lastShield, ElapsedNoDamage;
var float ShieldFraction, ShieldRegenRate;

//adren
var bool bAlwaysGive;
var int WaveNum, WaveBonus;
var config float ReplenishAdrenPercent;

//orignal
var config int RegenAmount;
var bool bHealthRegen, bShieldRegen, bAdrenRegen, bAmmoRegen, bVehicleRegen;

function bool HasActiveArtifact()
{
	return class'ActiveArtifactInv'.static.hasActiveArtifact(Instigator);
}

function PostBeginPlay()
{
	ShieldFraction = 0.0;
	ElapsedNoDamage = 0;

	Super.PostBeginPlay();
}

function Timer()
{
	local Controller C;
	local int NewH, NewS, AddAmt, R;
	local Inventory Inv;
	local Ammunition Ammo;
	local Weapon W;
	local Vehicle v;

	if (Instigator == None || Instigator.Health <= 0)
	{
		Destroy();
		return;
	}

	if (bHealthRegen)
	{
		Instigator.GiveHealth(RegenAmount, Instigator.HealthMax);
	}

	if (bShieldRegen)
	{
		NewH = Instigator.Health;
		NewS = Instigator.GetShieldStrength();
		if (lastHealth > NewH || lastShield > NewS)
			ElapsedNoDamage = 0;
		else
			ElapsedNoDamage++;

		if (MaxShieldRegen == 150 && xPawn(Instigator) != None)
			R = xPawn(Instigator).ShieldStrengthMax - NewS;
		else	
			R = MaxShieldRegen - NewS;

		if (R > 0 && (ElapsedNoDamage > NoDamageDelay))
		{
			ShieldFraction += ShieldRegenRate;
			AddAmt = int(ShieldFraction);
			ShieldFraction -= AddAmt;
			if (AddAmt >= 1)
			{
				if (AddAmt < R)
				{
					Instigator.AddShieldStrength(AddAmt);
				}
				else
				{
					Instigator.AddShieldStrength(R);
					ShieldFraction = 0.0;
				}
			}
		} 
		else
		{
			ShieldFraction = 0.0;
		}

		lastHealth = NewH;
		lastShield = Instigator.GetShieldStrength();
	}

	if (bAdrenRegen)
	{
		C = Instigator.Controller;
		if (C == None && Instigator.DrivenVehicle != None)
			C = Instigator.DrivenVehicle.Controller;

		if (C == None)
			return;

		if (!Instigator.InCurrentCombo() && (bAlwaysGive || !HasActiveArtifact()))
			C.AwardAdrenaline(RegenAmount);

		if (Level.Game.IsA('Invasion') && Invasion(Level.Game).WaveNum != WaveNum)
		{
			WaveNum = Invasion(Level.Game).WaveNum;
			C.AwardAdrenaline(WaveBonus * ReplenishAdrenPercent * C.AdrenalineMax);
		}
	}

	if (bAmmoRegen)
	{
		for (Inv = Instigator.Inventory; Inv != None; Inv = Inv.Inventory)
		{
			W = Weapon(Inv);
			if (W != None)
			{
				if (W.bNoAmmoInstances && W.AmmoClass[0] != None && !class'MutFPS'.static.IsSuperWeaponAmmo(W.AmmoClass[0]))
				{
					W.AddAmmo(RegenAmount * (1 + W.AmmoClass[0].default.MaxAmmo / 100), 0);
					if (W.AmmoClass[0] != W.AmmoClass[1] && W.AmmoClass[1] != None)
						W.AddAmmo(RegenAmount * (1 + W.AmmoClass[1].default.MaxAmmo / 100), 1);
				}
			}
			else
			{
				Ammo = Ammunition(Inv);
				if (Ammo != None && !class'MutFPS'.static.IsSuperWeaponAmmo(Ammo.Class))
					Ammo.AddAmmo(RegenAmount * (1 + Ammo.default.MaxAmmo / 100));
			}
		}
	}

	if (bVehicleRegen)
	{
		if (Instigator.DrivenVehicle == None)
			return;

		v = Instigator.DrivenVehicle;

		if (ONSWeaponPawn(v) != None && ONSWeaponPawn(v).VehicleBase != None && !ONSWeaponPawn(v).bHasOwnHealth)
			v = ONSWeaponPawn(v).VehicleBase;

		v.GiveHealth(RegenAmount, v.HealthMax);
	}
}

defaultproperties
{
     RegenAmount=1
     WaveNum=-1
     ReplenishAdrenPercent=0.100000
     RemoteRole=ROLE_DumbProxy
}
