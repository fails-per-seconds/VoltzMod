class AbilityShieldHealing extends CostRPGAbility
	config(fps)
	abstract;
	
var config float ShieldHealingPercent;

static simulated function ModifyPawn(Pawn Other, int AbilityLevel)
{
	local Inventory OInv;
	local RW_EngineerLink EGun;
	local ArtifactShieldBlast ASB;
	local bool bGotAM;
	local RPGStatsInv StatsInv;
	local int x;

	if (Monster(Other) != None)
		return;

	EGun = None;
	for (OInv = Other.Inventory; OInv != None; OInv = OInv.Inventory)
	{
		if (ClassIsChildOf(OInv.Class,class'RW_EngineerLink'))
		{
			EGun = RW_EngineerLink(OInv);
			break;
		}
	}
	if (EGun != None)
	{
		EGun.HealingLevel = AbilityLevel;
		EGun.ShieldHealingPercent = default.ShieldHealingPercent;
	}

	bGotAM = false;

	StatsInv = RPGStatsInv(Other.FindInventoryType(class'RPGStatsInv'));
	for (x = 0; StatsInv != None && x < StatsInv.Data.Abilities.length; x++)
	{
		if (StatsInv.Data.Abilities[x] == class'AbilityLoadedArtifacts')
		{
			if (StatsInv.Data.AbilityLevels[x] >= 2)
				bGotAM = true;
		}
	}

	if (AbilityLevel == 3 || bGotAM)
	{
		ASB = ArtifactShieldBlast(Other.FindInventoryType(class'ArtifactShieldBlast'));
		if (ASB == None)
		{
			ASB = Other.spawn(class'ArtifactShieldBlast', Other,,, rot(0,0,0));
			if (ASB == None)
				return;
			ASB.giveTo(Other);

			if (Other.SelectedItem == None)
				Other.NextItem();
		}
	}
}

defaultproperties
{
     ShieldHealingPercent=1.000000
     AbilityName="Shield Healing"
     Description="Allows Engineers to heal other people's shields.|Level 1 enables the Engineers Link Gun. |Level 2 Gives double the experience for healing, Level 3 triple the experience, and gives the Shield Blast artifact. |Cost (per level): 10,15,20"
     StartingCost=10
     CostAddPerLevel=5
     BotChance=7
     MaxLevel=3
}
