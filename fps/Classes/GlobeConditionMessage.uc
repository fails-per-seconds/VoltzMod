class GlobeConditionMessage extends LocalMessage;

var localized string GlobeMessage;
var localized string MadeGlobeMessage;
var localized string UnGlobeMessage;

static function string GetString(optional int Switch, optional PlayerReplicationInfo RelatedPRI_1,
				 optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject)
{
	if (Switch == 0)
	{
		if (RelatedPRI_1 == None)
			return default.GlobeMessage;
		else
			return (RelatedPRI_1.PlayerName @ default.MadeGlobeMessage);
	}
	else
		return default.UnGlobeMessage;
}

defaultproperties
{
     GlobeMessage="You are now safe from most damage!"
     MadeGlobeMessage="has made you safe from most damage!"
     UnGlobeMessage="Your damage safety has worn off!"
     bIsUnique=True
     bIsConsoleMessage=False
     bFadeMessage=True
     Lifetime=2
     DrawColor=(B=0,G=0)
     PosY=0.750000
}
