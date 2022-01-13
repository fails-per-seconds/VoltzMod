class IdentifyMessage extends LocalMessage;

var(Message) localized string IdentifyString, PickupString;

static function ClientReceive(PlayerController P, optional int Switch, optional PlayerReplicationInfo RelatedPRI_1,
			       optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject)
{
	if (RPGWeapon(OptionalObject) != None && RPGWeapon(OptionalObject).ModifiedWeapon != None)
		Super.ClientReceive(P, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject);
}

static function color GetConsoleColor(PlayerReplicationInfo RelatedPRI_1)
{
	return class'HUD'.default.WhiteColor;
}

static function string GetString(optional int Switch, optional PlayerReplicationInfo RelatedPRI_1,
				 optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject)
{
	RPGWeapon(OptionalObject).ConstructItemName();

	if (Switch == 0)
		return default.IdentifyString@RPGWeapon(OptionalObject).ItemName$"!";
	else
		return default.PickupString@RPGWeapon(OptionalObject).ItemName$".";
}

defaultproperties
{
     IdentifyString="Your weapon is a"
     PickupString="You got the"
     bIsUnique=True
     bFadeMessage=True
     PosY=0.800000
}
