class PoisonBlastConditionMessage extends LocalMessage;

var localized string PoisonBlastMessage;

static function string GetString(optional int Switch, optional PlayerReplicationInfo RelatedPRI_1,
				 optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject)
{
	if (Switch == 0)
		return default.PoisonBlastMessage;
}

defaultproperties
{
     PoisonBlastMessage="You have been poisoned!"
     bIsUnique=True
     bIsConsoleMessage=False
     bFadeMessage=True
     Lifetime=2
     DrawColor=(B=0,G=0)
     PosY=0.750000
}
