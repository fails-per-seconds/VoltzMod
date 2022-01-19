class AbilityExpHealing extends CostRPGAbility
	config(fps)
	abstract;

var config float EXPBonusPerLevel;
var config int MaxNormalLevel;

static function ModifyPawn(Pawn Other, int AbilityLevel)
{
	local ArtifactMakeSuperHealer AMSH;

	if (Monster(Other) != None)
		return;

	AMSH = ArtifactMakeSuperHealer(Other.FindInventoryType(class'ArtifactMakeSuperHealer'));
	if (AMSH == None)
	{
		AMSH = Other.spawn(class'ArtifactMakeSuperHealer', Other,,, rot(0,0,0));
		if (AMSH == None)
			return;

		AMSH.giveTo(Other);
	}
	AMSH.EXPMultiplier = class'RW_Healer'.default.EXPMultiplier + (Default.EXPBonusPerLevel * AbilityLevel);
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
     EXPBonusPerLevel=0.010000
     MaxNormalLevel=9
     RequiredAbilities(0)=Class'fps.AbilityLoadedHealing'
     AbilityCantBuyColor=(R=164,G=14,B=122,A=200)
     AbilityMaxColor=(R=1,G=1,B=1,A=200)
     AbilityName="Experienced Healing"
     DescColor(0)=(R=255,G=255,B=255,A=220)
     Description(0)="Allows you to gain additional experience for healing others with the Medic Gun.|Each level allows you to gain an additional 1% experience from healing. |You must have Loaded Medic to purchase this skill.|Cost (per level): 5,8,11,14,17,20,23,26,29..."
     StartingCost=5
     CostAddPerLevel=3
     MaxLevel=20
}
