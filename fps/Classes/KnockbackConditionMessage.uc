class KnockbackConditionMessage extends LocalMessage;

var localized string KnockbackMessage;

static function string GetString(optional int Switch, optional PlayerReplicationInfo RelatedPRI_1,
				 optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject)
{
	return default.KnockbackMessage;
}

defaultproperties
{
     KnockbackMessage="Knockback"
     bIsUnique=True
     bIsConsoleMessage=False
     bFadeMessage=True
     Lifetime=1
     DrawColor=(B=0,G=0)
     PosY=0.750000
}
