class BotAbility extends CostRPGAbility
	abstract;

static simulated function int Cost(RPGPlayerDataObject Data, int CurrentLevel)
{
	if (Data == None || Data.OwnerID != "Bot")
		return 0;

	return super.Cost(Data, CurrentLevel);		
}

defaultproperties
{
     AbilityName="Bot Ability"
     Description="Only for bots"
}
