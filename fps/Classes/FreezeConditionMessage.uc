class FreezeConditionMessage extends LocalMessage;

var localized string FreezeMessage;

static function string GetString(optional int Switch, optional PlayerReplicationInfo RelatedPRI_1,
				 optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject)
{
	return default.FreezeMessage;
}

defaultproperties
{
     FreezeMessage="You are frozen"
     bIsUnique=True
     bIsConsoleMessage=False
     bFadeMessage=True
     Lifetime=2
     DrawColor=(B=128,G=128,R=128)
     PosY=0.750000
}
