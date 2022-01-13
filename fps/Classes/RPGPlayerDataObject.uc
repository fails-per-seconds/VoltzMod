class RPGPlayerDataObject extends Object
	config(fpsData)
	PerObjectConfig;

var config string OwnerID;

var config int Level, Experience, WeaponSpeed, HealthBonus, AdrenalineMax, Attack, Defense, AmmoMax, PointsAvailable, NeededExp;
var config float ExperienceFraction;

var config array<class<RPGAbility> > Abilities;
var config array<int> AbilityLevels;

var config class<RPGAbility> BotAbilityGoal;
var config int BotGoalAbilityCurrentLevel;

struct RPGPlayerData
{
	var int Level, Experience, WeaponSpeed, HealthBonus, AdrenalineMax;
	var int Attack, Defense, AmmoMax, PointsAvailable, NeededExp;
	var array<class<RPGAbility> > Abilities;
	var array<int> AbilityLevels;
};

function AddExperienceFraction(float Amount, MutFPS RPGMut, PlayerReplicationInfo MessagePRI)
{
	ExperienceFraction += Amount;
	if (Abs(ExperienceFraction) >= 1.0)
	{
		Experience += int(ExperienceFraction);
		ExperienceFraction -= int(ExperienceFraction);
		RPGMut.CheckLevelUp(self, MessagePRI);
	}
}

function CreateDataStruct(out RPGPlayerData Data, bool bOnlyEXP)
{
	Data.Level = Level;
	Data.Experience = Experience;
	Data.NeededExp = NeededExp;
	Data.PointsAvailable = PointsAvailable;
	if (bOnlyEXP)
		return;

	Data.WeaponSpeed = WeaponSpeed;
	Data.HealthBonus = HealthBonus;
	Data.AdrenalineMax = AdrenalineMax;
	Data.Attack = Attack;
	Data.Defense = Defense;
	Data.AmmoMax = AmmoMax;
	Data.Abilities = Abilities;
	Data.AbilityLevels = AbilityLevels;
}

function InitFromDataStruct(RPGPlayerData Data)
{
	Level = Data.Level;
	Experience = Data.Experience;
	NeededExp = Data.NeededExp;
	PointsAvailable = Data.PointsAvailable;
	WeaponSpeed = Data.WeaponSpeed;
	HealthBonus = Data.HealthBonus;
	AdrenalineMax = Data.AdrenalineMax;
	Attack = Data.Attack;
	Defense = Data.Defense;
	AmmoMax = Data.AmmoMax;
	Abilities = Data.Abilities;
	AbilityLevels = Data.AbilityLevels;
}

function CopyDataFrom(RPGPlayerDataObject DataObject)
{
	OwnerID = DataObject.OwnerID;
	Level = DataObject.Level;
	Experience = DataObject.Experience;
	NeededExp = DataObject.NeededExp;
	PointsAvailable = DataObject.PointsAvailable;
	WeaponSpeed = DataObject.WeaponSpeed;
	HealthBonus = DataObject.HealthBonus;
	AdrenalineMax = DataObject.AdrenalineMax;
	Attack = DataObject.Attack;
	Defense = DataObject.Defense;
	AmmoMax = DataObject.AmmoMax;
	Abilities = DataObject.Abilities;
	AbilityLevels = DataObject.AbilityLevels;
	BotAbilityGoal = DataObject.BotAbilityGoal;
	BotGoalAbilityCurrentLevel = DataObject.BotGoalAbilityCurrentLevel;
}

defaultproperties
{
}
