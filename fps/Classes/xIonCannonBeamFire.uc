class xIonCannonBeamFire extends FX_Turret_IonCannon_BeamFire;

simulated function HurtRadius( float DamageAmount, float DamageRadius, class<DamageType> DamageType, float Momentum, vector HitLocation )
{
	local actor Victims;
	local float damageScale, dist;
	local vector dir;
	local RPGStatsInv StatsInv, HealerStatsInv;
	local float old_xp, cur_xp, xp_each, xp_diff, xp_given_away;
	local int i, DriverLevel;
	local Pawn P;
	local bool bSameTeam;
	local Controller C;

	if (bHurtEntry)
		return;

	if (Role != ROLE_Authority)
		return;

	bHurtEntry = true;

	if (xIonCannon(Instigator) != None && xIonCannon(Instigator).Driver != None)
	{
		StatsInv = RPGStatsInv(xIonCannon(Instigator).Driver.FindInventoryType(class'RPGStatsInv'));
		if (StatsInv != None && StatsInv.DataObject != None)
		{
			old_xp = StatsInv.DataObject.Experience + StatsInv.DataObject.ExperienceFraction;
			DriverLevel = StatsInv.DataObject.Level;
			
			if (Level.TimeSeconds > xIonCannon(Instigator).LastHealTime + class'EngineerLinkGun'.default.HealTimeDelay && xIonCannon(Instigator).NumHealers > 0)
				DamageAmount *= class'RW_EngineerLink'.static.DamageIncreasedByLinkers(xIonCannon(Instigator).NumHealers);
		}
	}
		
	foreach VisibleCollidingActors(class 'Actor', Victims, DamageRadius, HitLocation)
	{
		if ((Victims != instigator) && (Victims != self) && (Victims.Role == ROLE_Authority) && (!Victims.IsA('FluidSurfaceInfo')))
		{
			dir = Victims.Location - HitLocation;
			dist = FMax(1,VSize(dir));
			dir = dir/dist;
			damageScale = 1 - FMax(0,(dist - Victims.CollisionRadius)/DamageRadius);
			bSameTeam = false;
			P = Pawn(Victims);
			if (P != None && P.Controller != None && P.Health > 0 && Instigator != None && P.Controller.SameTeamAs(Instigator.Controller))
				bSameTeam = true;
			if (!bSameTeam)
			{
				Victims.TakeDamage
				(
					damageScale * DamageAmount,
					Instigator,
					Victims.Location - 0.5 * (Victims.CollisionHeight + Victims.CollisionRadius) * dir,
					(damageScale * Momentum * dir),
					DamageType
				);

				if (Instigator != None && Vehicle(Victims) != None && Vehicle(Victims).Health > 0)
					Vehicle(Victims).DriverRadiusDamage(DamageAmount, DamageRadius, Instigator.Controller, DamageType, Momentum, HitLocation);
			}
		}
	}

	if (StatsInv != None && StatsInv.DataObject != None && DriverLevel == StatsInv.DataObject.Level)
	{
		cur_xp = StatsInv.DataObject.Experience + StatsInv.DataObject.ExperienceFraction;
		xp_diff = cur_xp - old_xp;
		if (xp_diff > 0 && xIonCannon(Instigator).NumHealers > 0)
		{
			xp_each = class'RW_EngineerLink'.static.XPForLinker(xp_diff , xIonCannon(Instigator).Healers.length);
			xp_given_away = 0;

			for(i = 0; i < xIonCannon(Instigator).Healers.length; i++)
			{
				if (xIonCannon(Instigator).Healers[i].Pawn != None && xIonCannon(Instigator).Healers[i].Pawn.Health >0)
				{
					C = xIonCannon(Instigator).Healers[i];
					if (xLinkSentinelController(C) != None)
						HealerStatsInv = xLinkSentinelController(C).StatsInv;
					else
						HealerStatsInv = RPGStatsInv(C.Pawn.FindInventoryType(class'RPGStatsInv'));
					if (HealerStatsInv != None && HealerStatsInv.DataObject != None)
						HealerStatsInv.DataObject.AddExperienceFraction(xp_each, xIonCannon(Instigator).RPGMut, xIonCannon(Instigator).Healers[i].Pawn.PlayerReplicationInfo);
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

	bHurtEntry = false;
}

defaultproperties
{
     MinRange=700.000000
     Damage=120
     DamageRadius=1700.000000
}
