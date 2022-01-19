class AbilityShieldRegen extends CostRPGAbility
	config(fps) 
	abstract;

var config int NoDamageDelay, ShieldPerLevel;
var config float ShieldRegenRate, RegenPerLevel;

static simulated function ModifyPawn(Pawn Other, int AbilityLevel)
{
	local RegenShieldInv R;
	local Inventory Inv;
	local int MaxShield;

	if (Other == None)
		return;

	if (Other.Role != ROLE_Authority)
		return;

	Inv = Other.FindInventoryType(class'RegenShieldInv');
	if (Inv != None)
		Inv.Destroy();

	if (R == None)
	{
		R = Other.spawn(class'RegenShieldInv', Other,,,rot(0,0,0));
		R.GiveTo(Other);
	}

	if (R != None)
	{
		R.NoDamageDelay = default.NoDamageDelay;
		MaxShield = default.ShieldPerLevel*AbilityLevel;
		R.MaxShieldRegen = MaxShield;
		R.SetTimer(1, true);
		R.ShieldRegenRate = fmax(default.ShieldRegenRate,default.RegenPerLevel*float(AbilityLevel));
	}

	Other.AddShieldStrength(MaxShield);
}

defaultproperties
{
     NoDamageDelay=3
     ShieldPerLevel=10
     ShieldRegenRate=1.000000
     RegenPerLevel=0.500000
     AbilityCantBuyColor=(R=164,G=14,B=122,A=200)
     AbilityMaxColor=(R=1,G=1,B=1,A=200)
     AbilityName="Shield Regeneration"
     DescColor(0)=(R=255,G=255,B=255,A=220)
     Description(0)="Regenerates your shield at 0.5 per level per second, minimum one, provided you haven't suffered damage recently. Does not regenerate past starting shield amount.  |Cost (per level): 4,4,4,4,4,4,4,4,4,4,...."
     StartingCost=4
     BotChance=8
     MaxLevel=25
}
