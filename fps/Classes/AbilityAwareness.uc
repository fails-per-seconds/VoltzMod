class AbilityAwareness extends CostRPGAbility;

static simulated function ModifyPawn(Pawn Other, int AbilityLevel)
{
	local GiveItemsInv GIInv;

	if (Other == None || Other.Controller == None || !Other.Controller.IsA('PlayerController'))
		return;

	GIInv = class'GiveItemsInv'.static.GetGiveItemsInv(Other.Controller);
	if (GIInv != None)
	{
		GIInv.AwarenessLevel = AbilityLevel;
		return;
	}
}

static function int BotBuyChance(Bot B, RPGPlayerDataObject Data, int CurrentLevel)
{
	return 0;
}

defaultproperties
{
     MinWeaponSpeed=5
     MinHealthBonus=5
     MinAdrenalineMax=105
     MinAmmo=5
     AbilityCantBuyColor=(R=164,G=14,B=122,A=200)
     AbilityMaxColor=(R=1,G=1,B=1,A=200)
     AbilityName="Awareness"
     DescColor(0)=(R=255,G=255,B=255,A=220)
     Description(0)="Informs you of your enemies' health with a display over their heads. At level 1 you get a small, dully-colored indicator (green, yellow, or red). At level 2 you get a larger colored health bar and a shield bar. You must have at least 5 points in every stat to purchase this ability. |Cost (per level): 20,25"
     StartingCost=20
     CostAddPerLevel=5
     BotChance=0
     MaxLevel=3
}
