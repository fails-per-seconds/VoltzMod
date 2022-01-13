class AbilityEngineerAwareness extends CostRPGAbility
	abstract;

static simulated function ModifyPawn(Pawn Other, int AbilityLevel)
{
	local GiveItemsInv GIInv;

	if (Other == None || Other.Controller == None || !Other.Controller.IsA('PlayerController'))
		return;

	GIInv = class'GiveItemsInv'.static.GetGiveItemsInv(Other.Controller);
	if (GIInv != None)
	{
		GIInv.EngAwarenessLevel = AbilityLevel;
		return;
	}
}

static function int BotBuyChance(Bot B, RPGPlayerDataObject Data, int CurrentLevel)
{
	return 0;
}

defaultproperties
{
     RequiredAbilities(0)=Class'fps.AbilityShieldHealing'
     AbilityName="Engineer Awareness"
     Description="Informs you of your friends' shield strength with a display over their heads. You get a large, brightly colored health bar with a white background, that shrinks and changes color as the target shield gains health. The bar will turn a full solid yellow if the shield is fully healed. You need to have Shield Healing to purchase this skill. Cost per level: 10. "
     StartingCost=10
     CostAddPerLevel=5
     BotChance=0
     MaxLevel=1
}