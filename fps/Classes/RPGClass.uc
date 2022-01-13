class RPGClass extends RPGDeathAbility
	config(fps) 
	abstract;

var config int LowLevel, MediumLevel;
var config float MaxXPperHit;

static simulated function int Cost(RPGPlayerDataObject Data, int CurrentLevel)
{
	local int x;

	if (CurrentLevel > 1)
		return 0;

	for (x = 0; x < Data.Abilities.length; x++)
	{
		if (ClassIsChildOf(Data.Abilities[x], Class'RPGClass') && Data.Abilities[x] != default.Class)
			return 0;
	}
	return default.StartingCost;
}

static simulated function RPGStatsInv getPlayerStats(Controller c)
{
	local GameRules G;
	local RPGRules RPG;

	for(G = C.Level.Game.GameRulesModifiers; G != None; G = G.NextGameRules)
	{
		if (G.isA('RPGRules'))
		{
			RPG = RPGRules(G);
			break;
		}
	}

	if (RPG == None)
	{
		Log("WARNING: Unable to find RPGRules in GameRules.");
		return None;
	}
	return RPG.GetStatsInvFor(C);
}

static function bool PrePreventDeath(Pawn Killed, Controller Killer, class<DamageType> DamageType, vector HitLocation, int AbilityLevel)
{
	local GlobeInv IInv;
	local float XPGained;

	if (Killed == None)
		return false;

	IInv = GlobeInv(Killed.FindInventoryType(class'GlobeInv'));
	if (IInv != None)
	{
		if (Killed == IInv.PlayerPawn)
			Killed.Health = max(IInv.PlayerHealth,10);
		else
			Killed.Health = max(10,Killed.Health);
		if (Killer != None && Killer.Pawn != None && Killed != Killer.Pawn && Killed.Controller != None && !Killed.Controller.SameTeamAs(Killer))
		{
			if (IInv.InvPlayerController != None && IInv.InvPlayerController.Pawn != None && IInv.Rules != None && IInv.InvPlayerController != Killer && IInv.InvPlayerController != Killed.Controller)
			{
				XPGained = fmin(fmax(3.0, Killed.Health*IInv.ExpPerDamage),default.MaxXPperHit);
				IInv.Rules.ShareExperience(RPGStatsInv(IInv.InvPlayerController.Pawn.FindInventoryType(class'RPGStatsInv')), XPGained);
			}
		}
		return true;
	}

	return false;
}

static function bool GenuinePreventDeath(Pawn Killed, Controller Killer, class<DamageType> DamageType, vector HitLocation, int AbilityLevel)
{
	local RPGStatsInv StatsInv;

	StatsInv = RPGStatsInv(Killed.FindInventoryType(class'RPGStatsInv'));
 	if (StatsInv != None && StatsInv.DataObject.Level <= default.MediumLevel)
 	{
		if (StatsInv.DataObject.Level <= default.LowLevel)
			return class'AbilityGhost'.static.GenuinePreventDeath(Killed, Killer, DamageType, HitLocation, 2);
		else if (StatsInv.DataObject.Level <= default.MediumLevel)
			return class'AbilityGhost'.static.GenuinePreventDeath(Killed, Killer, DamageType, HitLocation, 1);
 	}
}

static function bool PreventSever(Pawn Killed, name boneName, int Damage, class<DamageType> DamageType, int AbilityLevel)
{
	local RPGStatsInv StatsInv;
	local GlobeInv IInv;
	local int y, GhostLevel, GhostIndex;

	GhostIndex = -1;
	IInv = GlobeInv(Killed.FindInventoryType(class'GlobeInv'));
	if (IInv != None)
	{
		return true;
	}

	StatsInv = RPGStatsInv(Killed.FindInventoryType(class'RPGStatsInv'));
 	if (StatsInv != None && StatsInv.DataObject.Level <= default.MediumLevel)
 	{
 		for (y = 0; y < StatsInv.Data.Abilities.length; y++)
 		{
 			if (ClassIsChildOf(StatsInv.Data.Abilities[y], class'AbilityGhost'))
 			{
 				GhostLevel = StatsInv.Data.AbilityLevels[y];
 				GhostIndex = y;
 			}
 		}

		if (StatsInv.DataObject.Level <= default.LowLevel)
		{
			if (GhostIndex >=0)
				return StatsInv.Data.Abilities[GhostIndex].static.PreventSever(Killed, boneName, Damage, DamageType, 3);
			else
				return class'AbilityGhost'.static.PreventSever(Killed, boneName, Damage, DamageType, 3);
		}
		else if (StatsInv.DataObject.Level <= default.MediumLevel)
		{
			if (GhostIndex >=0)
				return StatsInv.Data.Abilities[GhostIndex].static.PreventSever(Killed, boneName, Damage, DamageType, Min(3, GhostLevel + 2));
			else
				return class'AbilityGhost'.static.PreventSever(Killed, boneName, Damage, DamageType, 2);
		}
 	}
}

static simulated function ModifyVehicle(Vehicle V, int AbilityLevel)
{
	local float Healthperc;

	if (V.SuperHealthMax == 199)
		return;

	Healthperc = float(V.Health) / V.HealthMax;
	V.HealthMax = V.SuperHealthMax;
	V.Health = Healthperc * V.HealthMax;
}

static function ScoreKill(Controller Killer, Controller Killed, bool bOwnedByKiller, int AbilityLevel)
{
	local DamageInv DInv;
	local float XPGained;

	if (!bOwnedByKiller)
		return;

	if (Killer == None || Killer.Pawn == None || Killed == None || Killed.Pawn == None)
		return;

	if (!Killer.Pawn.IsA('Monster') && Killer.Pawn.HasUDamage())
	{
		DInv = DamageInv(Killer.Pawn.FindInventoryType(class'DamageInv'));
		if (DInv != None)
		{
			if (DInv.DamagePlayerController != None && DInv.DamagePlayerController.Pawn != None && DInv.Rules != None && DInv.DamagePlayerController != Killer)
			{
				XPGained = DInv.KillXPPerc * float(Killed.Pawn.GetPropertyText("ScoringValue"));
				DInv.Rules.ShareExperience(RPGStatsInv(DInv.DamagePlayerController.Pawn.FindInventoryType(class'RPGStatsInv')), XPGained);
			}
		}
	}
}

static function HandleDamage(out int Damage, Pawn Injured, Pawn Instigator, out vector Momentum, class<DamageType> DamageType, bool bOwnedByInstigator, int AbilityLevel)
{
	local float OriginalDamage, XPGained;
	local GlobeInv IInv;

	if (bOwnedByInstigator || Injured == None)
		return;
		
	if (Damage > 0)
	{
		IInv = GlobeInv(Injured.FindInventoryType(class'GlobeInv'));
		if (IInv != None)
		{
			OriginalDamage = Damage;
			Damage = 0;
			Momentum = vect(0,0,0);
			if (Instigator != None && Injured != Instigator && Injured.Health > 0 && Instigator.Controller != None && Injured.Controller != None && !Injured.Controller.SameTeamAs(Instigator.Controller))
			{
				if (IInv.InvPlayerController != None && IInv.InvPlayerController.Pawn != None && IInv.Rules != None && IInv.InvPlayerController != Instigator.Controller && IInv.InvPlayerController != Injured.Controller)
				{
					XPGained = fmin(IInv.ExpPerDamage * OriginalDamage, default.MaxXPperHit);
					IInv.Rules.ShareExperience(RPGStatsInv(IInv.InvPlayerController.Pawn.FindInventoryType(class'RPGStatsInv')), XPGained);
				}
			}

			if (Injured == IInv.PlayerPawn)
			{
				IInv.PlayerHealth = Injured.Health;
			}
			else
			{
				IInv.PlayerPawn = Injured;
				IInv.PlayerHealth = Injured.Health;
			}
		}
	}
}

defaultproperties
{
     LowLevel=20
     MediumLevel=40
     MaxXPperHit=10.000000
     StartingCost=1
     MaxLevel=1
}
