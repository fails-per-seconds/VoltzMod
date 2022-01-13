class PoisonInvTwo extends PoisonInv
	config(fps);

var RPGRules RPGRules;
var config float BasePercentage, Curve, AdrenLost;

static function AddHealableDamage(int Damage, Pawn Injured)
{
	local HealableDamageInv Inv;

	if (Injured == None || Injured.Controller == None || Injured.Health <= 0 || Damage < 1)
		return;

	if (Injured.IsA('Monster') && !Injured.Controller.IsA('FriendlyMonsterController'))
		return;

	Inv = HealableDamageInv(Injured.FindInventoryType(class'HealableDamageInv'));
	if (Inv == None)
	{
		Inv = Injured.spawn(class'HealableDamageInv');
		Inv.giveTo(Injured);
	}

	if (Inv == None)
		return;

	Inv.Damage += Damage;
	if (Inv.Damage > Injured.HealthMax + Class'HealableDamageGameRules'.default.MaxHealthBonus)
		Inv.Damage = Injured.HealthMax + Class'HealableDamageGameRules'.default.MaxHealthBonus;
}

simulated function Timer()
{
	local int PoisonDamage;

	if (Role == ROLE_Authority)
	{
		if (Owner == None)
		{
			Destroy();
			return;
		}

		if (PawnOwner == None)
			return;

		if (Instigator == None && InstigatorController != None)
			Instigator = InstigatorController.Pawn;

		PoisonDamage = int(float(PawnOwner.Health) * (Curve **(float(Modifier-1))*BasePercentage));
		if (PoisonDamage > 0)
		{
			if (PawnOwner.Controller != None && PawnOwner.Controller.bGodMode == False && GlobeInv(PawnOwner.FindInventoryType(class'GlobeInv')) == None)
			{
				if (PawnOwner.Controller.Adrenaline > 0)
					PawnOwner.Controller.Adrenaline -= (Modifier*AdrenLost);
				if (PawnOwner.Controller.Adrenaline < 0)
					PawnOwner.Controller.Adrenaline = 0;
					
				if (PawnOwner.Health <= PoisonDamage)
					PoisonDamage = PawnOwner.Health -1;
				PawnOwner.Health -= PoisonDamage;
				
				if (Instigator != None && Instigator != PawnOwner.Instigator)
				{
					if (RPGRules != None)
						RPGRules.AwardEXPForDamage(Instigator.Controller, RPGStatsInv(Instigator.FindInventoryType(class'RPGStatsInv')), PawnOwner, PoisonDamage);
					class'PoisonInvTwo'.static.AddHealableDamage(PoisonDamage, PawnOwner);
				}
			}
		}
	}

	if (Level.NetMode != NM_DedicatedServer && PawnOwner != None)
	{
		PawnOwner.Spawn(class'GoopSmoke');
		if (PawnOwner.IsLocallyControlled() && PlayerController(PawnOwner.Controller) != None)
			PlayerController(PawnOwner.Controller).ReceiveLocalizedMessage(class'PoisonConditionMessage', 0);
	}
}

defaultproperties
{
     BasePercentage=0.050000
     Curve=1.300000
     AdrenLost=2.000000
}
