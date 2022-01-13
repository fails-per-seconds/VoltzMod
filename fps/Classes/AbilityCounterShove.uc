class AbilityCounterShove extends CostRPGAbility
	abstract;

static function HandleDamage(int Damage, Pawn Injured, Pawn Instigator, out vector Momentum, class<DamageType> DamageType, bool bOwnedByInstigator, int AbilityLevel)
{
	local float MomentumMod;
	local vector CounterShoveValue;

	if (bOwnedByInstigator || DamageType == class'DamTypeRetaliation' || Injured == Instigator || Instigator == None || Injured == None ||  VSize(Momentum) == 0)
		return;

	if (Instigator.Controller == None || Injured.Controller == None)
		return;

	if (Instigator.Health <= 0)
		return;

	if (TeamGame(Injured.Level.Game) != None && TeamGame(Injured.Level.Game).FriendlyFireScale == 0 && Instigator.Controller.SameTeamAs(Injured.Controller))
	 		return;

	MomentumMod = - (200 * (AbilityLevel+1));

	CounterShoveValue = (Normal(Momentum) * Instigator.Mass * MomentumMod);

	if (TeamGame(Injured.Level.Game) != None && Instigator.Controller.SameTeamAs(Injured.Controller) && TeamGame(Injured.Level.Game).FriendlyFireScale > 0)
		CounterShoveValue *= TeamGame(Injured.Level.Game).FriendlyFireScale;

	Instigator.TakeDamage(0, Injured, Instigator.Location, CounterShoveValue, class'DamTypeRetaliation');
}

static function int BotBuyChance(Bot B, RPGPlayerDataObject Data, int CurrentLevel)
{
	return 0;
}

defaultproperties
{
     MinDR=50
     AbilityName="CounterShove"
     Description="Whenever you are damaged by another player, some of the momentum per level is also done to the player who hurt you. Will not CounterShove a CounterShove. You must have a Damage Reduction of at least 50 to purchase this ability. (Max Level: 5)"
     StartingCost=15
     MaxLevel=5
}
