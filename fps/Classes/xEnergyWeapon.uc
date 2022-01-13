class xEnergyWeapon extends ONSManualGun;

function TraceFire(Vector Start, Rotator Dir)
{
	local Vector X, End, HitLocation, HitNormal;
	local Actor Other;
	local RPGStatsInv StatsInv, HealerStatsInv;
	local float old_xp, cur_xp, xp_each, xp_diff, xp_given_away;
	local int i, Damage, DriverLevel;
	local Controller C;

	X = Vector(Dir);
	End = Start + TraceRange * X;

	if (ONSVehicle(Instigator) != None && ONSVehicle(Instigator).Driver != None)
	{
		ONSVehicle(Instigator).Driver.bBlockZeroExtentTraces = False;
		Other = Trace(HitLocation, HitNormal, End, Start, True);
		ONSVehicle(Instigator).Driver.bBlockZeroExtentTraces = true;
	}
	else
		Other = Trace(HitLocation, HitNormal, End, Start, True);

	if (Other != None)
	{
		if (!Other.bWorldGeometry)
		{
			Damage = (DamageMin + Rand(DamageMax - DamageMin));

			if (xEnergyTurret(Instigator) != None && xEnergyTurret(Instigator).Driver != None)
			{
				StatsInv = RPGStatsInv(xEnergyTurret(Instigator).Driver.FindInventoryType(class'RPGStatsInv'));
				if (StatsInv != None && StatsInv.DataObject != None)
				{
					old_xp = StatsInv.DataObject.Experience + StatsInv.DataObject.ExperienceFraction;
					DriverLevel = StatsInv.DataObject.Level;

					if (Level.TimeSeconds > xEnergyTurret(Instigator).LastHealTime + class'EngineerLinkGun'.default.HealTimeDelay && xEnergyTurret(Instigator).NumHealers > 0)
						Damage = Damage * class'RW_EngineerLink'.static.DamageIncreasedByLinkers(xEnergyTurret(Instigator).NumHealers);
				}
			}
	
	
			if (ONSPowerCore(Other) == None && ONSPowerNodeEnergySphere(Other) == None)
				Other.TakeDamage(Damage, Instigator, HitLocation, Momentum*X, DamageType);
			HitNormal = vect(0,0,0);
	
			if (StatsInv != None && StatsInv.DataObject != None && DriverLevel == StatsInv.DataObject.Level)
			{
				cur_xp = StatsInv.DataObject.Experience + StatsInv.DataObject.ExperienceFraction;
				xp_diff = cur_xp - old_xp;
				if (xp_diff > 0 && xEnergyTurret(Instigator).NumHealers > 0)
				{
					xp_each = class'RW_EngineerLink'.static.XPForLinker(xp_diff , xEnergyTurret(Instigator).Healers.length);
					xp_given_away = 0;
	
					for(i = 0; i < xEnergyTurret(Instigator).Healers.length; i++)
					{
						if (xEnergyTurret(Instigator).Healers[i].Pawn != None && xEnergyTurret(Instigator).Healers[i].Pawn.Health >0)
						{
							C = xEnergyTurret(Instigator).Healers[i];
							if (xLinkSentinelController(C) != None)
								HealerStatsInv = xLinkSentinelController(C).StatsInv;
							else
								HealerStatsInv = RPGStatsInv(C.Pawn.FindInventoryType(class'RPGStatsInv'));
							if (HealerStatsInv != None && HealerStatsInv.DataObject != None)
								HealerStatsInv.DataObject.AddExperienceFraction(xp_each, xEnergyTurret(Instigator).RPGMut, xEnergyTurret(Instigator).Healers[i].Pawn.PlayerReplicationInfo);
							xp_given_away += xp_each;
						}
					}

					if (xp_given_away > 0)
					{
						StatsInv.DataObject.ExperienceFraction -= xp_given_away;
						while (StatsInv.DataObject.ExperienceFraction < 0)
						{
							StatsInv.DataObject.ExperienceFraction += 1.0;
							StatsInv.DataObject.Experience -= 1;
						}
					}
	
				}
			}
		}
	}
	else
	{
		HitLocation = End;
		HitNormal = Vect(0,0,0);
	}

	HitCount++;
	LastHitLocation = HitLocation;
	SpawnHitEffects(Other, HitLocation, HitNormal);
}

defaultproperties
{
     DamageMax=40
}
