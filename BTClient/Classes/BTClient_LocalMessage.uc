class BTClient_LocalMessage extends CriticalEventPlus;

static function string GetString(optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2, optional Object Source)
{
	return BTClient_ClientReplication(Source).ClientMessage;
}

defaultproperties
{
     bIsUnique=False
}
