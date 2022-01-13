class GhostMessage extends LocalMessage;

var localized string GhostOne;

static function string GetString(optional int Switch, optional PlayerReplicationInfo RelatedPRI_1,
				 optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject)
{
	return default.GhostOne;
}

defaultproperties
{
     GhostOne="You were Ghosted!"
     bIsUnique=True
     bIsConsoleMessage=False
     bFadeMessage=True
     Lifetime=5
     DrawColor=(B=255,G=255,R=255)
     PosY=0.750000
}
