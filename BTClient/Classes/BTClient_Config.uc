class BTClient_Config extends Object
	config(ClientBTimes)
	PerObjectConfig;

const CONFIG_NAME = "BTConfig";
const CONFIG_VERSION = 1.1;

var globalconfig float SavedWithVersion;

var() globalconfig int ScreenFontSize;

var() globalconfig bool bUseAltTimer, bShowZoneActors, bFadeTextColors, bDisplayFail;
var() globalconfig bool bDisplayNew, bBaseTimeLeftOnPersonal, bPlayTickSounds, bDisplayFullTime;
var() globalconfig bool bProfesionalMode, bAutoBehindView, bNoTrailers, bRenderPathTimers, bRenderPathTimerIndex;

var() globalconfig sound TickSound, LastTickSound, FailSound, NewSound, AchievementSound, TrophySound;

var() globalconfig Interactions.EInputKey RankingTableKey;

var() globalconfig color CTable, CGoldText, PreferedColor;

var() globalconfig string StoreFilter;

var private BTClient_Config _ConfigInstance;

final static function BTClient_Config FindSavedData()
{
	local BTClient_Config cfg;

	if (default._ConfigInstance != none)
		return default._ConfigInstance;

	cfg = BTClient_Config(FindObject("Package."$CONFIG_NAME, default.Class));
	if (cfg == none)
		cfg = new (none, CONFIG_NAME) default.Class;

	if (cfg.SavedWithVersion < CONFIG_VERSION)
	{
		PatchSavedData(cfg);
		cfg.SavedWithVersion = CONFIG_VERSION;
		cfg.SaveConfig();
	}

	default._ConfigInstance = cfg;
	return cfg;
}

private static function PatchSavedData( BTClient_Config cfg )
{
	if (cfg.SavedWithVersion < 1)
		cfg.CTable = default.CTable;

	if (cfg.SavedWithVersion < 1.1)
		cfg.ScreenFontSize = default.ScreenFontSize;
}

final static function Interactions.EInputKey ConvertToKey( string KeyStr )
{
	local int CurKey;
	local Interactions.EInputKey LastKey;
	local int LastKeyInt;

	if (KeyStr ~= "")
		return IK_None;

	LastKey = IK_OEMClear;
	LastKeyInt = int(LastKey);

	for(CurKey = 0; CurKey <= LastKey; ++CurKey)
	{
		if (KeyStr ~= class'Engine.Interactions'.static.GetFriendlyName(EInputKey(CurKey)))
			return EInputKey(CurKey);
	}

	return IK_None;
}

final function ResetSavedData()
{
	RankingTableKey		= default.RankingTableKey;
	ScreenFontSize		= default.ScreenFontSize;
	bPlayTickSounds		= default.bPlayTickSounds;
	TickSound		= default.TickSound;
	LastTickSound		= default.LastTickSound;
	bUseAltTimer		= default.bUseAltTimer;
	bShowZoneActors		= default.bShowZoneActors;
	bFadeTextColors		= default.bFadeTextColors;
	bDisplayFail		= default.bDisplayFail;
	bDisplayNew		= default.bDisplayNew;
	FailSound		= default.FailSound;
	NewSound		= default.NewSound;
	bBaseTimeLeftOnPersonal	= default.bBaseTimeLeftOnpersonal;
	bDisplayFullTime	= default.bDisplayFullTime;
	bProfesionalMode	= default.bProfesionalMode;
	bAutoBehindView		= default.bAutoBehindView;
	CTable			= default.CTable;
	CGoldText		= default.CGoldText;
	bRenderPathTimers	= default.bRenderPathTimers;
	bRenderPathTimerIndex	= default.bRenderPathTimerIndex;
	SaveConfig();
}

defaultproperties
{
     ScreenFontSize=1
     bFadeTextColors=True
     bDisplayFail=True
     bDisplayNew=True
     bPlayTickSounds=True
     bDisplayFullTime=True
     bRenderPathTimers=False
     TickSound=Sound'MenuSounds.select3'
     LastTickSound=Sound'MenuSounds.denied1'
     FailSound=Sound'GameSounds.OtherFanfares.LadderClosed'
     NewSound=Sound'GameSounds.Fanfares.UT2K3Fanfare03'
     AchievementSound=Sound'GameSounds.Fanfares.UT2K3Fanfare08'
     TrophySound=Sound'GameSounds.Fanfares.UT2K3Fanfare08'
     RankingTableKey=IK_F12
     CTable=(B=18,G=12,R=12,A=200)
     CGoldText=(G=255,R=255,A=255)
     PreferedColor=(B=255,G=255,R=255,A=255)
     storeFilter="Other"
}
