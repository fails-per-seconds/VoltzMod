class SubClass extends RPGAbility
	config(fps)
	abstract;

var config Array<string> SubClasses;

struct SubClassAvailability
{
	var class<RPGClass> AvailableClass;
	var string AvailableSubClass;
	var int MinLevel;
};
var config Array<SubClassAvailability> SubClassConfigs;

struct AbilityConfig
{
	var class<RPGAbility> AvailableAbility;
	var Array<int> MaxLevels;
};
var config Array<AbilityConfig> AbilityConfigs;

static simulated function int Cost(RPGPlayerDataObject Data, int CurrentLevel)
{
	if (Data != None && Data.OwnerID == "Bot")
		return 0;

	if (CurrentLevel == 0)
		return 1;
	else
		return 0;
}

static function int BotBuyChance(Bot B, RPGPlayerDataObject Data, int CurrentLevel)
{
	return 0;
}

defaultproperties
{
     SubClasses(0)="None"
     SubClasses(1)="AM/WM hybrid"
     SubClasses(2)="AM/MM hybrid"
     SubClasses(3)="AM/Eng hybrid"
     SubClasses(4)="WM/MM hybrid"
     SubClasses(5)="WM/Eng hybrid"
     SubClasses(6)="MM/Eng hybrid"
     SubClasses(7)="Extreme AM"
     SubClasses(8)="Extreme WM"
     SubClasses(9)="Extreme Medic"
     SubClasses(10)="Extreme Monsters"
     SubClasses(11)="Extreme Engineer"
     SubClasses(12)="Berserker"
     SubClasses(13)="Class: Adrenaline Master"
     SubClasses(14)="Class: Weapons Master"
     SubClasses(15)="Class: Monster/Medic Master"
     SubClasses(16)="Class: Engineer"
     SubClasses(17)="Class: General"
     SubClasses(18)="Skilled Weapons"
     SubClasses(19)="Tank"
     SubClasses(20)="Turret Specialist"
     SubClasses(21)="Vehicle Specialist"
     SubClasses(22)="Sentinel Specialist"
     SubClasses(23)="Base Specialist"
     SubClassConfigs(0)=(AvailableClass=Class'fps.ClassAdrenalineMaster',AvailableSubClass="AM/WM hybrid",MinLevel=80)
     SubClassConfigs(1)=(AvailableClass=Class'fps.ClassAdrenalineMaster',AvailableSubClass="AM/MM hybrid",MinLevel=80)
     SubClassConfigs(2)=(AvailableClass=Class'fps.ClassAdrenalineMaster',AvailableSubClass="AM/Eng hybrid",MinLevel=80)
     SubClassConfigs(3)=(AvailableClass=Class'fps.ClassAdrenalineMaster',AvailableSubClass="Extreme AM",MinLevel=130)
     SubClassConfigs(4)=(AvailableClass=Class'fps.ClassWeaponsMaster',AvailableSubClass="AM/WM hybrid",MinLevel=80)
     SubClassConfigs(5)=(AvailableClass=Class'fps.ClassWeaponsMaster',AvailableSubClass="WM/MM hybrid",MinLevel=80)
     SubClassConfigs(6)=(AvailableClass=Class'fps.ClassWeaponsMaster',AvailableSubClass="WM/Eng hybrid",MinLevel=80)
     SubClassConfigs(7)=(AvailableClass=Class'fps.ClassWeaponsMaster',AvailableSubClass="Extreme WM",MinLevel=130)
     SubClassConfigs(8)=(AvailableClass=Class'fps.ClassWeaponsMaster',AvailableSubClass="Berserker",MinLevel=150)
     SubClassConfigs(9)=(AvailableClass=Class'fps.ClassMonsterMaster',AvailableSubClass="AM/MM hybrid",MinLevel=80)
     SubClassConfigs(10)=(AvailableClass=Class'fps.ClassMonsterMaster',AvailableSubClass="WM/MM hybrid",MinLevel=80)
     SubClassConfigs(11)=(AvailableClass=Class'fps.ClassMonsterMaster',AvailableSubClass="MM/Eng hybrid",MinLevel=80)
     SubClassConfigs(12)=(AvailableClass=Class'fps.ClassMonsterMaster',AvailableSubClass="Extreme Medic",MinLevel=130)
     SubClassConfigs(13)=(AvailableClass=Class'fps.ClassMonsterMaster',AvailableSubClass="Extreme Monsters",MinLevel=130)
     SubClassConfigs(14)=(AvailableClass=Class'fps.ClassEngineer',AvailableSubClass="AM/Eng hybrid",MinLevel=80)
     SubClassConfigs(15)=(AvailableClass=Class'fps.ClassEngineer',AvailableSubClass="WM/Eng hybrid",MinLevel=80)
     SubClassConfigs(16)=(AvailableClass=Class'fps.ClassEngineer',AvailableSubClass="MM/Eng hybrid",MinLevel=80)
     SubClassConfigs(17)=(AvailableClass=Class'fps.ClassGeneral',AvailableSubClass="AM/WM hybrid",MinLevel=80)
     SubClassConfigs(18)=(AvailableClass=Class'fps.ClassGeneral',AvailableSubClass="AM/MM hybrid",MinLevel=80)
     SubClassConfigs(19)=(AvailableClass=Class'fps.ClassGeneral',AvailableSubClass="AM/Eng hybrid",MinLevel=80)
     SubClassConfigs(20)=(AvailableClass=Class'fps.ClassGeneral',AvailableSubClass="WM/MM hybrid",MinLevel=80)
     SubClassConfigs(21)=(AvailableClass=Class'fps.ClassGeneral',AvailableSubClass="WM/Eng hybrid",MinLevel=80)
     SubClassConfigs(22)=(AvailableClass=Class'fps.ClassGeneral',AvailableSubClass="MM/Eng hybrid",MinLevel=80)
     SubClassConfigs(23)=(AvailableClass=Class'fps.ClassWeaponsMaster',AvailableSubClass="Skilled Weapons",MinLevel=150)
     SubClassConfigs(24)=(AvailableClass=Class'fps.ClassWeaponsMaster',AvailableSubClass="Tank",MinLevel=150)
     SubClassConfigs(25)=(AvailableClass=Class'fps.ClassEngineer',AvailableSubClass="Turret Specialist",MinLevel=150)
     SubClassConfigs(26)=(AvailableClass=Class'fps.ClassEngineer',AvailableSubClass="Vehicle Specialist",MinLevel=150)
     SubClassConfigs(27)=(AvailableClass=Class'fps.ClassEngineer',AvailableSubClass="Sentinel Specialist",MinLevel=150)
     SubClassConfigs(28)=(AvailableClass=Class'fps.ClassEngineer',AvailableSubClass="Base Specialist",MinLevel=130)
     AbilityConfigs(0)=(AvailableAbility=Class'fps.AbilityLoadedArtifacts',MaxLevels=(0,3,2,2,0,0,0,5,0,0,0,0,0,4,0,0,0,1,0,0,0,0,0,0))
     AbilityConfigs(1)=(AvailableAbility=Class'fps.AbilityAdrenSurge',MaxLevels=(0,1,1,1,0,0,0,2,0,0,0,0,0,2,0,0,0,0,0,0,0,0,0,0))
     AbilityConfigs(2)=(AvailableAbility=Class'fps.AbilityAdrenLeech',MaxLevels=(0,5,0,0,0,0,0,2,0,0,0,0,0,5,0,0,0,3,0,0,0,0,0,0))
     AbilityConfigs(3)=(AvailableAbility=Class'fps.AbilityAdrenShield',MaxLevels=(0,0,0,2,0,0,0,3,0,0,0,0,0,2,0,0,0,0,0,0,0,0,0,0))
     AbilityConfigs(4)=(AvailableAbility=Class'fps.AbilityLoadedWeapons',MaxLevels=(0,2,0,0,2,2,0,0,6,0,0,0,5,0,5,0,0,1,2,5,0,0,0,0))
     AbilityConfigs(5)=(AvailableAbility=Class'fps.AbilityVampire',MaxLevels=(0,4,0,0,5,5,0,0,15,0,0,0,10,0,10,0,0,2,10,10,0,0,0,0))
     AbilityConfigs(6)=(AvailableAbility=Class'fps.AbilityEnhancedDamage',MaxLevels=(0,5,0,0,5,5,0,0,10,0,0,0,0,0,10,0,0,2,0,0,0,0,0,0))
     AbilityConfigs(7)=(AvailableAbility=Class'fps.AbilityBerserkerDamage',MaxLevels=(0,0,0,0,0,0,0,0,0,0,0,0,20,0,0,0,0,0,0,0,0,0,0,0))
     AbilityConfigs(8)=(AvailableAbility=Class'fps.AbilityWeaponsProficiency',MaxLevels=(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,10,0,0,0,0,0))
     AbilityConfigs(9)=(AvailableAbility=Class'fps.AbilityIncreasedDamage',MaxLevels=(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,10,0,0,0,0))
     AbilityConfigs(10)=(AvailableAbility=Class'fps.AbilityIncreasedProtection',MaxLevels=(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,10,0,0,0,0))
     AbilityConfigs(11)=(AvailableAbility=Class'fps.AbilityLoadedHealing',MaxLevels=(0,0,2,0,2,0,3,0,0,4,1,0,0,0,0,3,0,2,0,0,0,0,0,0))
     AbilityConfigs(12)=(AvailableAbility=Class'fps.AbilityExpHealing',MaxLevels=(0,0,4,0,4,0,9,0,0,20,0,0,0,0,0,9,0,0,0,0,0,0,0,0))
     AbilityConfigs(13)=(AvailableAbility=Class'fps.AbilityMedicAwareness',MaxLevels=(0,0,2,0,2,0,2,0,0,2,1,0,0,0,0,2,0,2,0,0,0,0,0,0))
     AbilityConfigs(14)=(AvailableAbility=Class'fps.AbilityLoadedMonsters',MaxLevels=(0,0,5,0,5,0,0,0,0,0,20,0,0,0,0,15,0,0,0,0,0,0,0,0))
     AbilityConfigs(15)=(AvailableAbility=Class'fps.AbilityMonsterHealthBonus',MaxLevels=(0,0,0,0,0,0,0,0,0,0,10,0,0,0,0,10,0,0,0,0,0,0,0,0))
     AbilityConfigs(16)=(AvailableAbility=Class'fps.AbilityMonsterPoints',MaxLevels=(0,0,6,0,6,0,0,0,0,0,30,0,0,0,0,20,0,0,0,0,0,0,0,0))
     AbilityConfigs(17)=(AvailableAbility=Class'fps.AbilityMonsterSkill',MaxLevels=(0,0,2,0,2,0,0,0,0,0,7,0,0,0,0,7,0,0,0,0,0,0,0,0))
     AbilityConfigs(18)=(AvailableAbility=Class'fps.AbilityMonsterDamage',MaxLevels=(0,0,0,0,0,0,0,0,0,0,20,0,0,0,0,0,0,0,0,0,0,0,0,0))
     AbilityConfigs(19)=(AvailableAbility=Class'fps.AbilityEnhancedReduction',MaxLevels=(0,0,5,0,5,0,10,0,0,10,10,0,0,0,0,10,0,2,0,0,0,0,0,0))
     AbilityConfigs(20)=(AvailableAbility=Class'fps.AbilityLoadedEngineer',MaxLevels=(0,0,0,8,0,8,0,0,0,0,0,0,0,0,0,0,15,5,0,0,0,0,0,0))
     AbilityConfigs(21)=(AvailableAbility=Class'fps.AbilityMedicEngineer',MaxLevels=(0,0,0,0,0,0,15,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0))
     AbilityConfigs(22)=(AvailableAbility=Class'fps.AbilityExtremeEngineer',MaxLevels=(0,0,0,0,0,0,0,0,0,0,0,15,0,0,0,0,0,0,0,0,0,0,0,0))
     AbilityConfigs(23)=(AvailableAbility=Class'fps.AbilityTurretSpecialist',MaxLevels=(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,20,0,0,0))
     AbilityConfigs(24)=(AvailableAbility=Class'fps.AbilityVehicleSpecialist',MaxLevels=(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,20,0,0))
     AbilityConfigs(25)=(AvailableAbility=Class'fps.AbilitySentinelSpecialist',MaxLevels=(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,20,0))
     AbilityConfigs(26)=(AvailableAbility=Class'fps.AbilityBaseSpecialist',MaxLevels=(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,20))
     AbilityConfigs(27)=(AvailableAbility=Class'fps.AbilityShieldRegen',MaxLevels=(0,0,0,7,0,7,15,0,0,0,0,0,0,0,0,0,15,5,0,15,0,0,0,15))
     AbilityConfigs(28)=(AvailableAbility=Class'fps.AbilityShieldHealing',MaxLevels=(0,0,0,1,0,1,3,0,0,0,0,1,0,0,0,0,3,1,0,0,1,1,1,3))
     AbilityConfigs(29)=(AvailableAbility=Class'fps.AbilityVehicleRegen',MaxLevels=(0,0,0,2,0,2,0,0,0,0,0,5,0,0,0,0,5,0,0,0,5,5,5,0))
     AbilityConfigs(30)=(AvailableAbility=Class'fps.AbilityVehicleVamp',MaxLevels=(0,0,0,5,0,5,0,0,0,0,0,15,0,0,0,0,10,0,0,0,15,15,10,0))
     AbilityConfigs(31)=(AvailableAbility=Class'fps.AbilityConstructionHealthBonus',MaxLevels=(0,0,0,6,0,6,6,0,0,0,0,15,0,0,0,0,10,3,0,0,15,15,15,15))
     AbilityConfigs(32)=(AvailableAbility=Class'fps.AbilityEngineerAwareness',MaxLevels=(0,0,0,1,0,1,1,0,0,0,0,1,0,0,0,0,1,1,0,0,1,1,1,1))
     AbilityConfigs(33)=(AvailableAbility=Class'fps.AbilityRapidBuild',MaxLevels=(0,0,0,0,0,0,0,0,0,0,0,10,0,0,0,0,5,0,0,0,10,10,10,10))
     AbilityConfigs(34)=(AvailableAbility=Class'fps.AbilityAmmoRegen',MaxLevels=(0,4,2,2,2,2,0,1,5,0,0,0,4,4,4,0,0,2,5,3,0,0,0,0))
     AbilityConfigs(35)=(AvailableAbility=Class'fps.AbilityAwareness',MaxLevels=(0,3,3,3,3,3,0,3,3,0,0,0,3,3,3,0,0,3,3,3,0,0,0,0))
     AbilityConfigs(36)=(AvailableAbility=Class'fps.AbilityDenial',MaxLevels=(0,2,0,0,0,0,0,0,0,0,0,0,0,3,2,0,0,0,2,2,0,0,0,0))
     AbilityConfigs(37)=(AvailableAbility=Class'fps.AbilityRegen',MaxLevels=(0,3,3,0,5,3,3,0,0,5,2,0,0,0,5,5,0,3,5,5,0,0,0,0))
     AbilityConfigs(38)=(AvailableAbility=Class'fps.AbilityAdrenRegen',MaxLevels=(0,0,3,2,1,0,3,4,0,2,2,0,0,3,0,3,0,3,0,0,0,0,0,0))
     AbilityConfigs(39)=(AvailableAbility=Class'fps.AbilityVehicleEject',MaxLevels=(0,1,1,1,1,1,1,0,0,0,0,4,0,1,1,1,4,1,1,1,4,4,4,4))
     AbilityConfigs(40)=(AvailableAbility=Class'fps.AbilityWheeledVehicleStunts',MaxLevels=(0,1,1,1,1,1,1,0,0,0,0,3,0,1,1,1,3,1,1,1,3,3,3,3))
     AbilityConfigs(41)=(AvailableAbility=Class'fps.AbilityGhost',MaxLevels=(3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3))
     AbilityConfigs(42)=(AvailableAbility=Class'fps.AbilityUltima',MaxLevels=(2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,3,2,2,2,2))
     AbilityConfigs(43)=(AvailableAbility=Class'fps.AbilityCounterShove',MaxLevels=(5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5))
     AbilityConfigs(44)=(AvailableAbility=Class'fps.AbilityRetaliate',MaxLevels=(10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10))
     AbilityConfigs(45)=(AvailableAbility=Class'fps.AbilityJumpZ',MaxLevels=(3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,0,3,3,3,3))
     AbilityConfigs(46)=(AvailableAbility=Class'fps.AbilityIronLegs',MaxLevels=(4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,0,4,4,4,4))
     AbilityConfigs(47)=(AvailableAbility=Class'fps.AbilitySpeed',MaxLevels=(5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,0,5,5,5,5))
     AbilityConfigs(48)=(AvailableAbility=Class'fps.AbilityShieldStrength',MaxLevels=(4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4))
     AbilityConfigs(49)=(AvailableAbility=Class'fps.AbilityCautiousness',MaxLevels=(5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5))
     AbilityConfigs(50)=(AvailableAbility=Class'fps.AbilitySmartHealing',MaxLevels=(4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4))
     AbilityConfigs(51)=(AvailableAbility=Class'fps.AbilityAirControl',MaxLevels=(4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,0,4,4,4,4))
     AbilityConfigs(52)=(AvailableAbility=Class'fps.AbilityFastSwitch',MaxLevels=(2,2,2,2,2,2,2,0,2,2,2,1,2,2,2,2,2,2,2,0,1,1,1,1))
     AbilityConfigs(54)=(AvailableAbility=Class'fps.AbilityLifeSurge',MaxLevels=(0,5,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,0,0,0,0,0,0))
     AbilityConfigs(55)=(AvailableAbility=Class'fps.AbilityDefenseSentinelResupply',MaxLevels=(0,0,0,0,0,5,0,0,0,0,0,0,0,0,0,0,0,2,0,0,0,0,0,2))
     AbilityConfigs(56)=(AvailableAbility=Class'fps.AbilityDefenseSentinelHealing',MaxLevels=(0,0,0,0,0,0,5,0,0,0,0,0,0,0,0,0,0,2,0,0,0,0,0,2))
     AbilityConfigs(57)=(AvailableAbility=Class'fps.AbilityDefenseSentinelShields',MaxLevels=(0,0,0,0,0,0,5,0,0,0,0,5,0,0,0,0,0,2,0,0,0,0,5,5))
     AbilityConfigs(58)=(AvailableAbility=Class'fps.AbilityDefenseSentinelEnergy',MaxLevels=(0,0,0,5,0,0,0,0,0,0,0,0,0,0,0,0,0,2,0,0,0,0,0,2))
     AbilityConfigs(59)=(AvailableAbility=Class'fps.AbilityDefenseSentinelArmor',MaxLevels=(0,0,0,0,0,0,5,0,0,0,0,5,0,0,0,0,0,2,0,0,0,0,5,5))
     AbilityConfigs(60)=(AvailableAbility=Class'fps.AbilitySpiderSteroids',MaxLevels=(0,0,0,0,0,10,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0))
     BotChance=1
}
