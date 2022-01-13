class LevelUpMessage extends LocalMessage;

var(Message) localized string LevelUpString, PressLString;
var(Message) color YellowColor;

static function color GetColor(
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2
	)
{
	return default.YellowColor;
}

static function string GetString(
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	if (Switch == 0)
		return default.LevelUpString@default.PressLString;
	else
		return default.LevelUpString;
}

defaultproperties
{
     LevelUpString="You got AP to spend!"
     PressLString="(Press L)"
     YellowColor=(G=125,A=255)
     bIsUnique=True
     bIsConsoleMessage=False
     bFadeMessage=True
     Lifetime=1
     DrawColor=(G=160,R=0)
     StackMode=SM_Down
     PosY=0.100000
     FontSize=1
}
