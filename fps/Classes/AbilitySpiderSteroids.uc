class AbilitySpiderSteroids extends EngineerAbility
	config(fps) 
	abstract;

var config float LevMultiplier;

static simulated function ModifyPawn(Pawn Other, int AbilityLevel)
{
	local Inventory OInv;
	local RW_EngineerLink EGun;

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
		EGun.SpiderBoost = AbilityLevel * default.LevMultiplier;
}

static simulated function ModifyConstruction(Pawn Other, int AbilityLevel)
{
	if (xDefenseSentinel(Other) != None)
		xDefenseSentinel(Other).SpiderBoostLevel = AbilityLevel * default.LevMultiplier;
}

defaultproperties
{
     LevMultiplier=0.200000
     AbilityCantBuyColor=(R=164,G=14,B=122,A=200)
     AbilityMaxColor=(R=1,G=1,B=1,A=200)
     AbilityName="Spider Steroids"
     DescColor(0)=(R=255,G=255,B=255,A=220)
     Description(0)="Allows the Engineer Link Gun to boost spider mines"
     StartingCost=5
     MaxLevel=20
}
