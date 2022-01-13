class AbilityShieldRegen extends CostRPGAbility
	config(fps) 
	abstract;

var config int NoDamageDelay, ShieldPerLevel;
var config float ShieldRegenRate, RegenPerLevel;

static simulated function ModifyPawn(Pawn Other, int AbilityLevel)
{
	local RegenInv R;
	local Inventory Inv;
	local int MaxShield;

	if (Other == None)
		return;

	if (Other.Role != ROLE_Authority)
		return;

	Inv = Other.FindInventoryType(class'RegenInv');
	if (Inv != None)
		Inv.Destroy();

	R = Other.spawn(class'RegenInv', Other,,,rot(0,0,0));
	if (R == None)
		return;
	R.bShieldRegen = true;
	R.NoDamageDelay = default.NoDamageDelay;
	MaxShield = default.ShieldPerLevel*AbilityLevel;
	R.MaxShieldRegen = MaxShield;
	R.SetTimer(1, true);
	R.ShieldRegenRate = fmax(default.ShieldRegenRate,default.RegenPerLevel*float(AbilityLevel));

	R.GiveTo(Other);

	Other.AddShieldStrength(MaxShield);
}

defaultproperties
{
     NoDamageDelay=3
     ShieldPerLevel=10
     ShieldRegenRate=1.000000
     RegenPerLevel=0.500000
     AbilityName="Shield Regeneration"
     Description="Regenerates your shield at 0.5 per level per second, minimum one, provided you haven't suffered damage recently. Does not regenerate past starting shield amount.  |Cost (per level): 4,4,4,4,4,4,4,4,4,4,...."
     StartingCost=4
     BotChance=8
     MaxLevel=25
}
