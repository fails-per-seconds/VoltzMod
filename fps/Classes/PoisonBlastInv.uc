class PoisonBlastInv extends PoisonInv;

var RPGRules RPGRules;
var float DrainAmount;
var config float AdrenLost;

simulated function Timer()
{
	local int HealthDrained;

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

		HealthDrained = int((PawnOwner.Health * DrainAmount)/100);
		if (HealthDrained > 1)
		{
			if (PawnOwner.Controller != None && PawnOwner.Controller.bGodMode == False && GlobeInv(PawnOwner.FindInventoryType(class'GlobeInv')) == None)
		    {
				if (PawnOwner.Controller.Adrenaline > 0)
					PawnOwner.Controller.Adrenaline -= (Modifier*AdrenLost);
				if (PawnOwner.Controller.Adrenaline < 0)
					PawnOwner.Controller.Adrenaline = 0;

				PawnOwner.Health -= HealthDrained;

				if (Instigator != None && Instigator != PawnOwner.Instigator)
				{
					if (RPGRules != None)
						RPGRules.AwardEXPForDamage(Instigator.Controller, RPGStatsInv(Instigator.FindInventoryType(class'RPGStatsInv')), PawnOwner, HealthDrained);
					class'PoisonInvTwo'.static.AddHealableDamage(HealthDrained, PawnOwner);
				}
			}
		}
	}

	if (Level.NetMode != NM_DedicatedServer && PawnOwner != None)
	{
		if (PawnOwner.IsLocallyControlled() && PlayerController(PawnOwner.Controller) != None)
			PlayerController(PawnOwner.Controller).ReceiveLocalizedMessage(class'PoisonBlastConditionMessage', 0);
	}
}

defaultproperties
{
     DrainAmount=10.000000
     AdrenLost=2.000000
}
