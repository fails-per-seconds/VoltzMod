class RPGDamageGameRules extends GameRules
	config(fps);

var RPGRules xRules;
var config int MaxMonsterDB;
var config int MaxMonsterDR;

function ReOrderGameRules()
{
	local GameRules G, RPGG, DG;

	Warn("RPGDamageGameRules not before RPGRules.");
	for(G = Level.Game.GameRulesModifiers; G != None; G = G.NextGameRules)
	{
		if (G.IsA('RPGRules'))
		{
			if (G.isA('RPGDamageGameRules'))
			{
				if (DG != None)
					Warn("Two sets of RPGDamageGameRules in the GameModifiers list");
				DG = G;
			}
			else
			{
				if (RPGG != None)
					Warn("Two sets of RPGRules in the GameModifiers list");
				RPGG = G;
			}
		}
	}
	if (DG == None || RPGG == None)
	{
		Warn("Not running a RPGDamageGameRules or a RPGRules");
		return;
	}

	if (Level.Game.GameRulesModifiers != None && Level.Game.GameRulesModifiers.IsA('RPGRules') && !Level.Game.GameRulesModifiers.IsA('RPGDamageGameRules'))
	{
		Level.Game.GameRulesModifiers = Level.Game.GameRulesModifiers.NextGameRules;
	}
	else
	{
		for(G = Level.Game.GameRulesModifiers; G != None; G = G.NextGameRules)
		{
			if (G.NextGameRules != None && G.NextGameRules.IsA('RPGRules') && !G.NextGameRules.IsA('RPGDamageGameRules'))
			{
				G.NextGameRules = G.NextGameRules.NextGameRules;
			}
		}
	}

	RPGG.NextGameRules = DG.NextGameRules;
	DG.NextGameRules = RPGG;
	Warn("RPGDamageGameRules fixed so now before RPGRules.");
}

function int ContinueNetDamage(int OriginalDamage, int Damage, pawn injured, pawn instigatedBy, vector HitLocation, out vector Momentum, class<DamageType> DamageType)
{
	if (NextGameRules == None || RPGRules(NextGameRules) == None)
	{
		ReOrderGameRules();
		return Damage;
	}
	else
	{
		if (xRules == None)
			xRules = RPGRules(NextGameRules);
		if (NextGameRules.NextGameRules != None)
			return NextGameRules.NextGameRules.NetDamage(OriginalDamage,Damage,injured,instigatedBy,HitLocation,Momentum,DamageType);
	}

	return Damage;
}

function int NetDamage(int OriginalDamage, int Damage, pawn injured, pawn instigatedBy, vector HitLocation, out vector Momentum, class<DamageType> DamageType)
{
	local FriendlyMonsterController C;
	local RPGPlayerDataObject InjuredData, InstigatedData;
	local RPGStatsInv InjuredStatsInv, InstigatedStatsInv;
	local int x, MonsterLevel;
	local bool bZeroDamage, bCalledContinueNetDamage;

	if (xRules == None)
		return Super.NetDamage(OriginalDamage, Damage, injured, instigatedBy, HitLocation, Momentum, DamageType);		// we can't replace RPGRules, so use original

	if (injured == None || instigatedBy == None || injured.Controller == None || instigatedBy.Controller == None)
		return ContinueNetDamage(OriginalDamage, Damage, injured, instigatedBy, HitLocation, Momentum, DamageType);

	C = FriendlyMonsterController(injured.Controller);
	if (C != None && C.Master != None)
	{
		if (C.Master == instigatedBy.Controller)
			Damage = OriginalDamage;
		else if (C.SameTeamAs(instigatedBy.Controller))
			Damage *= TeamGame(Level.Game).FriendlyFireScale;
	}

	InstigatedStatsInv = xRules.GetStatsInvFor(instigatedBy.Controller);

	if (DamageType.default.bSuperWeapon || Damage >= 1000)
	{
		if (ClassIsChildOf(DamageType, class'WeaponDamageType') && RPGWeapon(InstigatedBy.Weapon) != None)
			RPGWeapon(InstigatedBy.Weapon).NewAdjustTargetDamage(Damage, OriginalDamage, Injured, HitLocation, Momentum, DamageType);
		if (InstigatedStatsInv != None)
			xRules.AwardEXPForDamage(instigatedBy.Controller, InstigatedStatsInv, injured, Damage);
		return ContinueNetDamage(OriginalDamage, Damage, injured, instigatedBy, HitLocation, Momentum, DamageType);
	}
	else if (Monster(injured) != None && FriendlyMonsterController(injured.Controller) == None && Monster(instigatedBy) != None && FriendlyMonsterController(instigatedBy.Controller) == None)
	{
		return ContinueNetDamage(OriginalDamage, Damage, injured, instigatedBy, HitLocation, Momentum, DamageType);
	}

	if (Damage <= 0)
	{
		Damage = ContinueNetDamage(OriginalDamage, Damage, injured, instigatedBy, HitLocation, Momentum, DamageType);
		bCalledContinueNetDamage = true;
		if (Damage < 0)
			return Damage;
		else if (Damage == 0)
			bZeroDamage = true;
	}

	if (InstigatedStatsInv != None)
		InstigatedData = InstigatedStatsInv.DataObject;

	InjuredStatsInv = xRules.GetStatsInvFor(injured.Controller);
	if (InjuredStatsInv != None)
		InjuredData = InjuredStatsInv.DataObject;

	if (InstigatedData == None || InjuredData == None)
	{
		if (Level.Game.IsA('Invasion'))
		{
			MonsterLevel = (Invasion(Level.Game).WaveNum + 1) * 2;
			if (xRules.RPGMut.bAutoAdjustInvasionLevel && xRules.RPGMut.CurrentLowestLevelPlayer != None)
				MonsterLevel += Max(0, xRules.RPGMut.CurrentLowestLevelPlayer.Level * xRules.RPGMut.InvasionAutoAdjustFactor);
		}
		else if (xRules.RPGMut.CurrentLowestLevelPlayer != None)
			MonsterLevel = xRules.RPGMut.CurrentLowestLevelPlayer.Level;
		else
			MonsterLevel = 1;
		if ( InstigatedData == None && ( (instigatedBy.IsA('Monster') && !instigatedBy.Controller.IsA('FriendlyMonsterController'))
						 || TurretController(instigatedBy.Controller) != None ) )
		{
			InstigatedData = RPGPlayerDataObject(Level.ObjectPool.AllocateObject(class'RPGPlayerDataObject'));
			InstigatedData.Attack = MonsterLevel / 2 * xRules.PointsPerLevel;
			if (InstigatedData.Attack > MaxMonsterDB)
				InstigatedData.Attack = MaxMonsterDB;
			InstigatedData.Defense = InstigatedData.Attack;
			if (InstigatedData.Defense > MaxMonsterDR)
				InstigatedData.Defense = MaxMonsterDR;
			InstigatedData.Level = MonsterLevel;
		}
		if ( InjuredData == None && InstigatedData != None && ( (injured.IsA('Monster') && !injured.Controller.IsA('FriendlyMonsterController'))
					      || TurretController(injured.Controller) != None ) )
		{
			InjuredData = RPGPlayerDataObject(Level.ObjectPool.AllocateObject(class'RPGPlayerDataObject'));
			InjuredData.Attack = MonsterLevel / 2 * xRules.PointsPerLevel;
			if (InjuredData.Attack > MaxMonsterDB)
				InjuredData.Attack = MaxMonsterDB;
			InjuredData.Defense = InjuredData.Attack;
			if (InjuredData.Defense > MaxMonsterDR)
				InjuredData.Defense = MaxMonsterDR;
			InjuredData.Level = MonsterLevel;
		}
	}

	if (InstigatedData == None)
	{
		Log("InstigatedData not found for "$instigatedBy.GetHumanReadableName());
		if (!bCalledContinueNetDamage)
			Damage = ContinueNetDamage(OriginalDamage, Damage, injured, instigatedBy, HitLocation, Momentum, DamageType);
		return Damage;
	}
	if (InjuredData == None)
	{
		if (InstigatedStatsInv == None && InstigatedData != None)
			Level.ObjectPool.FreeObject(InstigatedData);
		Log("InjuredData not found for "$injured.GetHumanReadableName());
		if (!bCalledContinueNetDamage)
			Damage = ContinueNetDamage(OriginalDamage, Damage, injured, instigatedBy, HitLocation, Momentum, DamageType);
		return Damage;
	}

	if (DamageType.Name == 'DamTypeSniperHeadShot' && InstigatedStatsInv != None && !instigatedBy.Controller.SameTeamAs(injured.Controller))
	{
		InstigatedData.Experience++;
		xRules.RPGMut.CheckLevelUp(InstigatedData, InstigatedBy.PlayerReplicationInfo);
	}

	Damage += int((float(Damage) * (1.0 + float(InstigatedData.Attack) * 0.005)) - (float(Damage) * (1.0 + float(InjuredData.Defense) * 0.005)));

	if (Damage < 1 && !bZeroDamage)
		Damage = 1;

	if (ClassIsChildOf(DamageType, class'WeaponDamageType') && RPGWeapon(InstigatedBy.Weapon) != None)
		RPGWeapon(InstigatedBy.Weapon).NewAdjustTargetDamage(Damage, OriginalDamage, Injured, HitLocation, Momentum, DamageType);

	if (InstigatedStatsInv != None)
	{
		for (x = 0; x < InstigatedData.Abilities.length; x++)
			InstigatedData.Abilities[x].static.HandleDamage(Damage, injured, instigatedBy, Momentum, DamageType, true, InstigatedData.AbilityLevels[x]);
	}
	else
	{
		if (InstigatedData != None)
			Level.ObjectPool.FreeObject(InstigatedData);
	}
	if (InjuredStatsInv != None)
	{
		for (x = 0; x < InjuredData.Abilities.length; x++)
			InjuredData.Abilities[x].static.HandleDamage(Damage, injured, instigatedBy, Momentum, DamageType, false, InjuredData.AbilityLevels[x]);
	}
	else
	{
		if (InjuredData != None)
			Level.ObjectPool.FreeObject(InjuredData);
	}

	if (bZeroDamage)
	{
		return 0;
	}
	else
	{
		if (InstigatedStatsInv != None)
		{
			if (InstigatedBy.HasUDamage())
			{
				xRules.AwardEXPForDamage(instigatedBy.Controller, InstigatedStatsInv, injured, Damage * 2);
			}
			else
			{
				xRules.AwardEXPForDamage(instigatedBy.Controller, InstigatedStatsInv, injured, Damage);
			}
		}
		if (!bCalledContinueNetDamage)
			Damage = ContinueNetDamage(OriginalDamage, Damage, injured, instigatedBy, HitLocation, Momentum, DamageType);
		return Damage;
	}
}

defaultproperties
{
     MaxMonsterDB=0	//374
     MaxMonsterDR=0	//250
}
