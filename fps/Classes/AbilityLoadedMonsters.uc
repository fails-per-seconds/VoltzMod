class AbilityLoadedMonsters extends CostRPGAbility
	config(fps)
	abstract;

struct MonsterConfig
{
	Var String FriendlyName;
	var Class<Monster> Monster;
	var int Adrenaline;
	var int MonsterPoints;
	var int Level;
};

var config Array<MonsterConfig> MonsterConfigs;

var config int MaxNormalLevel;
var config float PetHealthFraction;

static function ModifyPawn(Pawn Other, int AbilityLevel)
{
	local int i;
	local LoadedInv LoadedInv;
	local RPGArtifact Artifact;
	local bool PreciseLevel;

	LoadedInv = LoadedInv(Other.FindInventoryType(class'LoadedInv'));
	if (LoadedInv != None)
	{
		if (LoadedInv.bGotLoadedMonsters)
		{
			if (LoadedInv.LMAbilityLevel == AbilityLevel)
				return;
			PreciseLevel = true;
		}
	}
	else
	{
		LoadedInv = Other.spawn(class'LoadedInv');
		LoadedInv.giveTo(Other);
		PreciseLevel = false;
	}

	if (LoadedInv == None)
		return;

	LoadedInv.bGotLoadedMonsters = true;
	LoadedInv.LMAbilityLevel = AbilityLevel;

	for(i = 0; i < Default.MonsterConfigs.length; i++)
	{
		if (Default.MonsterConfigs[i].Monster != None)
		{
			if (PreciseLevel && Default.MonsterConfigs[i].Level != AbilityLevel)
				continue;
			if (Default.MonsterConfigs[i].Level <= AbilityLevel)
			{
				Artifact = Other.spawn(class'ArtifactMonsterMaster', Other,,, rot(0,0,0));
				if (Artifact == None)
					continue;
				ArtifactMonsterMaster(Artifact).Setup(Default.MonsterConfigs[i].FriendlyName, Default.MonsterConfigs[i].Monster, Default.MonsterConfigs[i].Adrenaline, Default.MonsterConfigs[i].MonsterPoints);
				Artifact.GiveTo(Other);
			}
		}
	}

	if (!PreciseLevel)
	{
		Artifact = Other.spawn(class'ArtifactKillAllPets', Other,,, rot(0,0,0));
		Artifact.GiveTo(Other);
	}
	
	if (AbilityLevel > default.MaxNormalLevel)
		LoadedInv.DirectMonsters = true;
	else
		LoadedInv.DirectMonsters = false;

	if (Other.SelectedItem == None)
		Other.NextItem();
}

static function HandleDamage(out int Damage, Pawn Injured, Pawn Instigator, out vector Momentum, class<DamageType> DamageType, bool bOwnedByInstigator, int AbilityLevel)
{
	local FriendlyMonsterController C;

	if (Instigator == None || Injured == None)
		return;

	if (!bOwnedByInstigator)
	{
		C = FriendlyMonsterController(injured.Controller);
		if (C != None && C.Master != None && C.Master == Instigator.Controller)
		{
			Damage *= TeamGame(injured.Level.Game).FriendlyFireScale;
		}
		return;
 	}

	if (Monster(Instigator) == None || Monster(Injured) == None)
		return;

	if (Monster(Injured).SameSpeciesAs(Instigator))
		Damage = 0;
}

static function bool OverridePickupQuery(Pawn Other, Pickup item, out byte bAllowPickup, int AbilityLevel)
{
	if (AbilityLevel <= default.MaxNormalLevel)
		return false;
	if (ClassIsChildOf(item.InventoryType, class'EnhancedRPGArtifact'))
	{
		bAllowPickup = 0;
		return true;
	}
	return false;
}

defaultproperties
{
     MonsterConfigs(0)=(FriendlyName="Pupae",Monster=Class'SkaarjPack.SkaarjPupae',Adrenaline=15,MonsterPoints=1,Level=1)
     MaxNormalLevel=15
     PetHealthFraction=0.750000
     AbilityName="Loaded Monsters"
     Description="Learn new monsters to summon with Monster Points. At each level, you can summon a better monster. |Cost (per level): 2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,.."
     StartingCost=2
     CostAddPerLevel=1
     MaxLevel=30
}
