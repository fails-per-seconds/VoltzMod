class CostRPGAbility extends RPGAbility
	abstract;

var int MinWeaponSpeed;
var int MinHealthBonus;
var int MinAdrenalineMax;
var int MinDB;
var int MinDR;
var int MinAmmo;

var int WeaponSpeedStep;
var int HealthBonusStep;
var int AdrenalineMaxStep;
var int DBStep;
var int DRStep;
var int AmmoStep;

var int MinPlayerLevel;
var int PlayerLevelStep;
var Array< int > PlayerLevelReqd;
var Array< int > LevelCost;		

var Array<class<RPGAbility> > ExcludingAbilities;
var Array<class<RPGAbility> > RequiredAbilities;

static simulated function int GetCost(RPGPlayerDataObject Data, int CurrentLevel)
{
	local int x, ab;
	local bool gotab;

	if (Data == None)
		return 0;

	if (Data.WeaponSpeed < default.MinWeaponSpeed + (CurrentLevel * default.WeaponSpeedStep))
		return 0;
	if (Data.HealthBonus < default.MinHealthBonus + (CurrentLevel * default.HealthBonusStep))
		return 0;
	if (Data.AdrenalineMax < default.MinAdrenalineMax + (CurrentLevel * default.AdrenalineMaxStep))
		return 0;
	if (Data.Attack < default.MinDB + (CurrentLevel * default.DBStep))
		return 0;
	if (Data.Defense < default.MinDR + (CurrentLevel * default.DRStep))
		return 0;
	if (Data.AmmoMax < default.MinAmmo + (CurrentLevel * default.AmmoStep))
		return 0;

	if (Data.Level < (default.MinPlayerLevel + CurrentLevel*default.PlayerLevelStep))
		return 0;

	if (default.PlayerLevelReqd.length > CurrentLevel+1)
		if (default.PlayerLevelReqd[CurrentLevel+1] > Data.Level)
			return 0;

	if (CurrentLevel >= default.MaxLevel)
		return 0;

	for (ab = 0; ab < default.ExcludingAbilities.length; ab++)
	{
		for (x = 0; x < Data.Abilities.length; x++)
			if (Data.Abilities[x] == default.ExcludingAbilities[ab])
				return 0;
	}

	for (ab = 0; ab < default.RequiredAbilities.length; ab++)
	{
		gotab = false;
		for (x = 0; x < Data.Abilities.length; x++)
			if (Data.Abilities[x] == default.RequiredAbilities[ab])
				gotab = true;
		if (!gotab)
			return 0;
	}

	if (default.LevelCost.length <= CurrentLevel)
		return default.StartingCost + default.CostAddPerLevel * CurrentLevel;
	else
		return default.LevelCost[CurrentLevel+1];
}

static simulated function int Cost(RPGPlayerDataObject Data, int CurrentLevel)
{
	return static.SubClassCost(Data, CurrentLevel, "");		
}

static simulated function int SubClassCost(RPGPlayerDataObject Data, int CurrentLevel, string curSubClass)
{
	local class<RPGClass> curClass;
	local int x, y, CostValue, curSubClasslevel;

	CostValue = static.GetCost(Data, CurrentLevel);
	if (CostValue <= 0)
		return 0;

	if (Data.OwnerID == "")
	{
		if (curSubClass == "")
		{
			return 0;
		}
		return CostValue;		
	}

	curSubClasslevel = -1;
	if (curSubClass == "")
	{
		curClass = None;
		for (y = 0; y < Data.Abilities.length; y++)
		{
			if (ClassIsChildOf(Data.Abilities[y], class'RPGClass'))
				curClass = class<RPGClass>(Data.Abilities[y]);
			else if (ClassIsChildOf(Data.Abilities[y], class'SubClass'))
				curSubClassLevel = Data.AbilityLevels[y];
		}

		if (curClass == None)
			curSubClasslevel = 0;
		else
		{
			if (curSubClass == "")
				curSubClass = curClass.default.AbilityName;								
		}
	}

	if (curSubClassLevel < 0) 
	{
		for (y = 0; y < class'SubClass'.default.SubClasses.length; y++)
			if (curSubClass == class'SubClass'.default.SubClasses[y])
				curSubClassLevel = y;
		if (curSubClasslevel < 0)
			curSubClassLevel = 0;
	}

	for (x = 0; x < class'SubClass'.default.AbilityConfigs.length; x++)
	{
		if (default.Class == class'SubClass'.default.AbilityConfigs[x].AvailableAbility)
		{
			if (class'SubClass'.default.AbilityConfigs[x].MaxLevels.Length > curSubClassLevel)
			{
				if (CurrentLevel < class'SubClass'.default.AbilityConfigs[x].MaxLevels[curSubClassLevel])
					return CostValue;
				else
					return 0;
			}
			else
				return 0;
		}
	}

	return CostValue;
}

defaultproperties
{
     MinAdrenalineMax=100
     AbilityName="Costed RPG Ability"
}
