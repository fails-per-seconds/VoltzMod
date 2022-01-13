class xBallTurretPlasmaProj extends PROJ_TurretSkaarjPlasma;

simulated function ProcessTouch (Actor Other, vector HitLocation)
{
	local RPGStatsInv StatsInv, HealerStatsInv;
	local float old_xp, cur_xp, xp_each, xp_diff, xp_given_away;
	local int i, DriverLevel;
	local Controller C;

	if (Instigator != None && (Other == Instigator))
		return;

	if (Other == Owner)
		return;

	if (!Other.IsA('Projectile') || Other.bProjTarget)
	{
		if (Role == ROLE_Authority)
		{
			if (Instigator == None || Instigator.Controller == None)
				Other.SetDelayedDamageInstigatorController(InstigatorController);

			if (xBallTurret(Instigator) != None && xBallTurret(Instigator).Driver != None)
			{
				StatsInv = RPGStatsInv(xBallTurret(Instigator).Driver.FindInventoryType(class'RPGStatsInv'));
				if (StatsInv != None && StatsInv.DataObject != None)
				{
					old_xp = StatsInv.DataObject.Experience + StatsInv.DataObject.ExperienceFraction;
					DriverLevel = StatsInv.DataObject.Level;

					if (Level.TimeSeconds > xBallTurret(Instigator).LastHealTime + class'EngineerLinkGun'.default.HealTimeDelay && xBallTurret(Instigator).NumHealers > 0)
						Damage = Damage * class'RW_EngineerLink'.static.DamageIncreasedByLinkers(xBallTurret(Instigator).NumHealers);
				}
			}

			Other.TakeDamage(Damage, Instigator, HitLocation, MomentumTransfer * Normal(Velocity), MyDamageType);

			if (StatsInv != None && StatsInv.DataObject != None && DriverLevel == StatsInv.DataObject.Level)
			{
				cur_xp = StatsInv.DataObject.Experience + StatsInv.DataObject.ExperienceFraction;
				xp_diff = cur_xp - old_xp;
				if (xp_diff > 0 && xBallTurret(Instigator).NumHealers > 0)
				{
					xp_each = class'RW_EngineerLink'.static.XPForLinker(xp_diff , xBallTurret(Instigator).Healers.length);
					xp_given_away = 0;

					for(i = 0; i < xBallTurret(Instigator).Healers.length; i++)
					{
						if (xBallTurret(Instigator).Healers[i].Pawn != None && xBallTurret(Instigator).Healers[i].Pawn.Health >0)
						{
							C = xBallTurret(Instigator).Healers[i];
							if (xLinkSentinelController(C) != None)
								HealerStatsInv = xLinkSentinelController(C).StatsInv;
							else
								HealerStatsInv = RPGStatsInv(C.Pawn.FindInventoryType(class'RPGStatsInv'));
							if (HealerStatsInv != None && HealerStatsInv.DataObject != None)
								HealerStatsInv.DataObject.AddExperienceFraction(xp_each, xBallTurret(Instigator).RPGMut, xBallTurret(Instigator).Healers[i].Pawn.PlayerReplicationInfo);
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

		Explode(HitLocation, -Normal(Velocity));
	}
}

defaultproperties
{
     Damage=55.000000
     MyDamageType=Class'fps.DamTypeBallTurret'
}
