class BTUI_AchievementState extends CriticalEventPlus;

var() Material AchievementBackground;
var() Texture AchievementDefaultIcon;
var() byte BGStyle;

static function string GetString(
    optional int Switch,
    optional PlayerReplicationInfo RelatedPRI_1,
    optional PlayerReplicationInfo RelatedPRI_2,
    optional Object OptionalObject
)
{
	return BTClient_ClientReplication(OptionalObject).LastAchievementEvent.Title;
}

static function float GetLongest( float XL1, float XL2 )
{
	if (XL1 > XL2)
		return XL1;
	else
		return XL2;
}

static function RenderComplexMessage(
    Canvas C,
    out float XL,
    out float YL,
    optional String MessageString,
    optional int Switch,
    optional PlayerReplicationInfo RelatedPRI_1,
    optional PlayerReplicationInfo RelatedPRI_2,
    optional Object OptionalObject
)
{
	local float XL1, XL2, YL1, YL2;
	local float XWidth;
	local float XP, YP, icoWidth;
	local float startXP, startYP;
	local string S;
	local float backgroundYL;
	local Color lastColor;
	local BTClient_ClientReplication.sAchievementState achievement;

	achievement = BTClient_ClientReplication(OptionalObject).LastAchievementEvent;

	lastColor = C.DrawColor;

	if (achievement.Count == 0)
		S = "ACHIEVEMENT UNLOCKED!";
	else
		S = "ACHIEVEMENT PROGRESSED!";

	C.StrLen(S, XL1, YL1);
	C.StrLen(MessageString, XL2, YL2);
	XWidth = GetLongest(XL1, XL2) + 8;

	backgroundYL = (YL1 * 2) + 8 + 80;
	icoWidth = backgroundYL;
	XWidth += icoWidth + 8;
	C.CurX = C.ClipX * 0.5 - XWidth * 0.5f;
	XP = C.CurX;
	YP = C.CurY;

	startXP = XP;
	startYp = YP;

	//=== ACHIEVEMENT BACKGROUND
	C.Style = ERenderStyle.STY_Alpha;
	C.DrawColor = class'HUD'.default.WhiteColor;
	C.SetPos(XP, YP);
	C.DrawTilePartialStretched(default.AchievementBackground, XWidth, backgroundYL);

	XP += 4;

	//=== ACHIEVEMENT ICON
	C.SetPos(XP + icoWidth * 0.25f, startYP + backgroundYL * 0.5f - icoWidth * 0.25f);
	lastColor = C.DrawColor;
	if (achievement.Count == 0)
	{
		C.DrawColor = class'HUD'.default.GreenColor;
	}
	C.DrawColor.A = lastColor.A;
	C.Style = 1;
	C.DrawTile(default.AchievementDefaultIcon, icoWidth * 0.5f, icoWidth * 0.5f, 0,0,128,128);
	XP += icoWidth;
	C.DrawColor = lastColor;

	XP += 4;
	YP += 4;

	XP += 4;

	//=== TEXT
	YP += 40;

	C.DrawColor = C.MakeColor(158, 195, 79);
	C.DrawColor.A = lastColor.A;

	//=== MESSAGE
	C.Style = 1;
	XP += 4;
	C.SetPos(startXP + XWidth * 0.5f - XL1 * 0.5f, startYP + YL1 * 0.25f);
	C.DrawText(S, true);

	//=== ACHIEVEMENT TITLE
	C.StrLen(S, XWidth, YL1);
	C.SetPos(XP, YP);
	C.DrawText(MessageString, true);

	//==== ACHIEVEMENT PROGRESS
	if (achievement.Count > 0)
	{
		YP += YL2;
		C.SetPos(XP, YP);
		C.DrawColor = class'HUD'.default.BlackColor;
		C.Style = 1;
		C.DrawTile(texture'BTScoreBoardBG', (XWidth - IcoWidth * 0.5f), YL2, 0, 0, 256, 256);

		C.SetPos(XP, YP);
		C.DrawColor = class'HUD'.default.GreenColor;
		C.DrawTile(Texture'BTScoreBoardBG', (XWidth - IcoWidth * 0.5f) * (float(Min(achievement.Progress, achievement.Count)) / float(achievement.Count)), YL2, 0, 0, 256, 256);

		C.StrLen(achievement.Progress $ "/" $ achievement.Count, XL, YL);
		C.SetPos(XP + (((XWidth - IcoWidth * 0.5f) * 0.5) - (XL * 0.5)), YP);
		C.DrawColor = class'HUD'.default.WhiteColor;
		C.Style = 3;
		C.DrawTextClipped(achievement.Progress $ "/" $ achievement.Count);
		C.Style = 1;
	}

	XL = XWidth;
	YL = backgroundYL;
}

defaultproperties
{
     AchievementBackground=Texture'2K4Menus.NewControls.Display95'
     AchievementDefaultIcon=Texture'AS_FX_TX.Icons.ScoreBoard_Objective_Final'
     BGStyle=3
     bComplexString=True
     Lifetime=8
     DrawColor=(B=10,G=10,R=10,A=200)
     PosY=0.600000
     FontSize=-2
}
