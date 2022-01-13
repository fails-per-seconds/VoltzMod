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
     MinDB=5
     MinDR=5
     MinAmmo=5
     AbilityName="Awareness"
     Description="Informs you of your enemies' health with a display over their heads. At level 1 you get a small, dully-colored indicator (green, yellow, or red). At level 2 you get a larger colored health bar and a shield bar. You must have at least 5 points in every stat to purchase this ability. |Cost (per level): 20,25"
     StartingCost=20
     CostAddPerLevel=5
     BotChance=0
     MaxLevel=3
}
