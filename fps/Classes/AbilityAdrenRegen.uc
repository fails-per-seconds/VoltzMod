class AbilityAdrenRegen extends CostRPGAbility
	abstract;

static simulated function int GetCost(RPGPlayerDataObject Data, int CurrentLevel)
{
	local int x;
	local bool gotab;

	if (Data == None)
		return 0;

	if (CurrentLevel >= 3)
	{
		gotab = false;
		for (x = 0; x < Data.Abilities.length; x++)
			if (Data.Abilities[x] == class'AbilityLoadedArtifacts' && Data.AbilityLevels[x] >= 5)
				gotab = true;
		if (!gotab)
			return 0;
	}

	return super.GetCost(Data, CurrentLevel);
}

static simulated function ModifyPawn(Pawn Other, int AbilityLevel)
{
	local RegenAdrenInv R;
	local Inventory Inv;

	if (Other.Role != ROLE_Authority)
		return;

	Inv = Other.FindInventoryType(class'RegenAdrenInv');
	if (Inv != None)
		Inv.Destroy();

	if (R == None)
	{
		R = Other.spawn(class'RegenAdrenInv', Other,,,rot(0,0,0));
		R.GiveTo(Other);
	}

	if (R != None)
	{
		if (AbilityLevel >= 3)
		{
			R.RegenAmount *= (AbilityLevel - 2);
			if (AbilityLevel > 3)
				R.bAlwaysGive = true;
			R.SetTimer(1, true);
			R.WaveBonus = 5;
		}
		else
		{
			R.SetTimer(4 - AbilityLevel, true);
			R.WaveBonus = AbilityLevel;
		}
	}
}

defaultproperties
{
     MinAdrenalineMax=125
     AdrenalineMaxStep=25
     AbilityCantBuyColor=(R=164,G=14,B=122,A=200)
     AbilityMaxColor=(R=1,G=1,B=1,A=200)
     AbilityName="Adrenal Drip"
     DescColor(0)=(R=255,G=255,B=255,A=220)
     Description(0)="Slowly drips adrenaline into your system.|At level 1 you get one adrenaline every 3 seconds.|At level 2 you get one adrenaline every 2 seconds.|At level 3 you get one adrenaline every second. |At level 4 you get two adrenaline per second.|You must spend 25 points in your Adrenaline Max stat for each level of this ability you want to purchase. |Cost (per level): 2,8,14..."
     StartingCost=2
     CostAddPerLevel=6
     MaxLevel=6
}
