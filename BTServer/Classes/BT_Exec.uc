class BT_Exec extends info;

//load
#exec obj load file="AnnouncerSexy.uax"

//custom load
#exec obj load file="BTClient.u"
#exec obj load file="System\LibHTTP4.u" package="BTServer"

//#exec obj load file="TrialGroup.u" <- must be in MutBestTimes

defaultproperties
{
}