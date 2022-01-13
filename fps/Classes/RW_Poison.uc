class RW_Poison extends RPGWeapon
	HideDropDown
	CacheExempt;

function AdjustTargetDamage(out int Damage, Actor Victim, Vector HitLocation, out Vector Momentum, class<DamageType> DamageType)
{
	local PoisonInv Inv;
	local Pawn P;

	if (DamageType == class'DamTypePoison' || Damage <= 0)
		return;

	P = Pawn(Victim);
	if (P != None)
	{
		if (!bIdentified)
			Identify();

		Inv = PoisonInv(P.FindInventoryType(class'PoisonInv'));
		if (Inv != None)
			Inv.LifeSpan += Rand(Damage / 10) + 1;
		else
		{
			Inv = spawn(class'PoisonInv', P,,, rot(0,0,0));
			Inv.Modifier = Modifier;
			Inv.GiveTo(P);
			Inv.LifeSpan = Rand(Damage / 10) + 1;
		}
	}
}

defaultproperties
{
     ModifierOverlay=Shader'XGameShaders.PlayerShaders.LinkHit'
     MaxModifier=4
     AIRatingBonus=0.020000
     PrefixPos="Poisoned "
}
