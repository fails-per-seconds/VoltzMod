class RW_PoisonEH extends OneDropRPGWeapon
	HideDropDown
	CacheExempt
	config(fps);

var RPGRules RPGRules;
var config int PoisonLifespan;

function PostBeginPlay()
{
	local GameRules G;

	Super.PostBeginPlay();

	for(G = Level.Game.GameRulesModifiers; G != None; G = G.NextGameRules)
	{
		if (G.IsA('RPGRules'))
		{
			RPGRules = RPGRules(G);
			break;
		}
	}

	if (RPGRules == None)
		Log("WARNING: Unable to find RPGRules in GameRules. EXP will not be properly awarded");
}

function NewAdjustTargetDamage(out int Damage, int OriginalDamage, Actor Victim, vector HitLocation, out vector Momentum, class<DamageType> DamageType)
{
	if (damage > 0)
	{
		if (Damage < (OriginalDamage * class'OneDropRPGWeapon'.default.MinDamagePercent))
			Damage = OriginalDamage * class'OneDropRPGWeapon'.default.MinDamagePercent;
	}

	Super.NewAdjustTargetDamage(Damage, OriginalDamage, Victim, HitLocation, Momentum, DamageType);
}

function AdjustTargetDamage(out int Damage, Actor Victim, Vector HitLocation, out Vector Momentum, class<DamageType> DamageType)
{
	local PoisonInvTwo Inv;
	local Pawn P;

	if (DamageType == class'DamTypePoison' || Damage <= 0)
		return;

	if (!class'OneDropRPGWeapon'.static.CheckCorrectDamage(ModifiedWeapon, DamageType))
		return;

	P = Pawn(Victim);
	if (P != None)
	{
		if (!bIdentified)
			Identify();

		Inv = PoisonInvTwo(P.FindInventoryType(class'PoisonInvTwo'));
		if (Inv == None)
		{
			Inv = spawn(class'PoisonInvTwo', P,,, rot(0,0,0));
			Inv.Modifier = Modifier;
			Inv.LifeSpan = PoisonLifespan;
			Inv.RPGRules = RPGRules;
			Inv.GiveTo(P);
		}
		else
		{
			Inv.Modifier = Modifier;
			Inv.LifeSpan = PoisonLifespan;
		}
	}
}

defaultproperties
{
     PoisonLifespan=4
     ModifierOverlay=Shader'XGameShaders.PlayerShaders.LinkHit'
     MinModifier=1
     MaxModifier=4
     AIRatingBonus=0.020000
     PrefixPos="Poisoned "
}
