class AbilityRapidBuild extends EngineerAbility
	abstract;

var float ReduceRate;

static function ModifyPawn(Pawn Other, int AbilityLevel)
{
	local EngineerPointsInv EInv;

	EInv = class'AbilityLoadedEngineer'.static.GetEngInv(Other);
	if (EInv != None)
		EInv.FastBuildPercent = 1.0 - (AbilityLevel*Default.ReduceRate);
}

defaultproperties
{
     ReduceRate=0.100000
     AbilityCantBuyColor=(R=164,G=14,B=122,A=200)
     AbilityMaxColor=(R=1,G=1,B=1,A=200)
     AbilityName="Constructions: Rapid Build"
     DescColor(0)=(R=255,G=255,B=255,A=220)
     Description(0)="Reduces the delay before you can buld the next item. Each level takes 10% health off your recovery time. |Cost (per level): 4,5,6,7,8..."
     StartingCost=4
     CostAddPerLevel=1
     MaxLevel=10
}
