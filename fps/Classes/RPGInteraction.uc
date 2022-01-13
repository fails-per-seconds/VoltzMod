class RPGInteraction extends Interaction
	config(fps);

var MutFPS RPGMut;
var bool bDefaultBindings, bDefaultArtifactBindings;

var RPGStatsInv StatsInv;
var float LastLevelMessageTime;
var config int LevelMessagePointThreshold;

var Font TextFont;
var Color WhiteColor;
var localized string ArtifactText;

//#exec new TrueTypeFontFactory Name=NewFont FontName="Arial Rounded MT Bold" Height=12 CharactersPerPage=32
#exec new TrueTypeFontFactory Name=BerlinSans FontName="Berlin Sans FB" Height=14 CharactersPerPage=32

event Initialized()
{
	local EInputKey key;
	local string tmp;

	if (ViewportOwner.Actor.Level.NetMode != NM_Client)
		foreach ViewportOwner.Actor.DynamicActors(class'MutFPS', RPGMut)
			break;

	for (key = IK_None; key < IK_OEMClear; key = EInputKey(key + 1))
	{
		tmp = ViewportOwner.Actor.ConsoleCommand("KEYNAME"@Key);
		tmp = ViewportOwner.Actor.ConsoleCommand("KEYBINDING"@tmp);
		if (tmp ~= "rpgstatsmenu")
			bDefaultBindings = false;
		else if (tmp ~= "activateitem" || tmp ~= "nextitem" || tmp ~= "previtem")
			bDefaultArtifactBindings = false;
		if (!bDefaultBindings && !bDefaultArtifactBindings)
			break;
	}

	//TextFont = Font(DynamicLoadObject("UT2003Fonts.jFontSmall", class'Font'));
}

function bool KeyEvent(EInputKey Key, EInputAction Action, float Delta)
{
	local string tmp;

	if (Action != IST_Press)
		return false;

	if (!bDefaultBindings)
	{
		tmp = ViewportOwner.Actor.ConsoleCommand("KEYNAME"@Key);
		tmp = ViewportOwner.Actor.ConsoleCommand("KEYBINDING"@tmp);
	}

	if (tmp ~= "rpgstatsmenu" || (bDefaultBindings && Key == IK_L))
	{
		if (StatsInv == None)
			FindStatsInv();
		if (StatsInv == None)
			return false;

		ViewportOwner.GUIController.OpenMenu("fps.RPGStatsMenu");
		RPGStatsMenu(GUIController(ViewportOwner.GUIController).TopPage()).InitFor(StatsInv);
		LevelMessagePointThreshold = StatsInv.Data.PointsAvailable;
		return true;
	}
	else if (bDefaultArtifactBindings)
	{
		if (Key == IK_U)
		{
			ViewportOwner.Actor.ActivateItem();
			return true;
		}
		else if (Key == IK_LeftBracket)
		{
			ViewportOwner.Actor.PrevItem();
			return true;
		}
		else if (Key == IK_RightBracket)
		{
			if (ViewportOwner.Actor.Pawn != None)
				ViewportOwner.Actor.Pawn.NextItem();
			return true;
		}
	}

	return false;
}

function FindStatsInv()
{
	local Inventory Inv;
	local RPGStatsInv FoundStatsInv;

	for (Inv = ViewportOwner.Actor.Inventory; Inv != None; Inv = Inv.Inventory)
	{
		StatsInv = RPGStatsInv(Inv);
		if (StatsInv != None)
			return;
		else
		{
			if (Inv.Inventory == Inv)
			{
				Inv.Inventory = None;
				foreach ViewportOwner.Actor.DynamicActors(class'RPGStatsInv', FoundStatsInv)
				{
					if (FoundStatsInv.Owner == ViewportOwner.Actor || FoundStatsInv.Owner == ViewportOwner.Actor.Pawn)
					{
						StatsInv = FoundStatsInv;
						Inv.Inventory = StatsInv;
						break;
					}
				}
				return;
			}
		}
	}
}

function PostRender(Canvas Canvas)
{
	local float XL, YL;

	if (ViewportOwner.Actor.Pawn == None || ViewportOwner.Actor.Pawn.Health <= 0 || (ViewportOwner.Actor.myHud != None && ViewportOwner.Actor.myHud.bShowScoreBoard) || ViewportOwner.Actor.myHud.bHideHUD)
		return;

	if (StatsInv == None)
		FindStatsInv();
	if (StatsInv == None)
		return;

	Canvas.Font = Font'BerlinSans';
	Canvas.TextSize(ArtifactText, XL, YL);

	if (bDefaultBindings)
	{
		Canvas.SetPos(Canvas.ClipX - XL - 1, Canvas.ClipY * 0.75 - YL * 1.25);
		if (StatsInv.Data.PointsAvailable > LevelMessagePointThreshold && ViewportOwner.Actor.Level.TimeSeconds >= LastLevelMessageTime + 1.0)
		{
			ViewportOwner.Actor.ReceiveLocalizedMessage(class'LevelUpMessage', 0);
			LastLevelMessageTime = ViewportOwner.Actor.Level.TimeSeconds;
		}
		else if (StatsInv.Data.PointsAvailable < LevelMessagePointThreshold)
			LevelMessagePointThreshold = StatsInv.Data.PointsAvailable;
	}
	else if (StatsInv.Data.PointsAvailable > LevelMessagePointThreshold && ViewportOwner.Actor.Level.TimeSeconds >= LastLevelMessageTime + 1.0)
	{
		ViewportOwner.Actor.ReceiveLocalizedMessage(class'LevelUpMessage', 1);
		LastLevelMessageTime = ViewportOwner.Actor.Level.TimeSeconds;
	}
	else if (StatsInv.Data.PointsAvailable < LevelMessagePointThreshold)
		LevelMessagePointThreshold = StatsInv.Data.PointsAvailable;

	if (RPGArtifact(ViewportOwner.Actor.Pawn.SelectedItem) != None)
	{
		//set artifact hud position - 0.75 default
		Canvas.SetPos(0, Canvas.ClipY * 0.50 - YL * 5.0);
		Canvas.DrawText(ViewportOwner.Actor.Pawn.SelectedItem.ItemName);
		if (ViewportOwner.Actor.Pawn.SelectedItem.IconMaterial != None)
		{
			Canvas.SetPos(0, Canvas.ClipY * 0.50 - YL * 3.75);
			Canvas.DrawTile(ViewportOwner.Actor.Pawn.SelectedItem.IconMaterial, YL * 2, YL * 2, 0, 0, ViewportOwner.Actor.Pawn.SelectedItem.IconMaterial.MaterialUSize(), ViewportOwner.Actor.Pawn.SelectedItem.IconMaterial.MaterialVSize());
		}
		if (bDefaultArtifactBindings)
		{
			Canvas.SetPos(0, Canvas.ClipY * 0.50 - YL * 1.25);
			Canvas.DrawText(ArtifactText);
		}
	}

	Canvas.FontScaleX = Canvas.default.FontScaleX;
	Canvas.FontScaleY = Canvas.default.FontScaleY;
}

event NotifyLevelChange()
{
	FindStatsInv();
	if (StatsInv != None && StatsInv.StatsMenu != None)
		StatsInv.StatsMenu.CloseClick(None);
	StatsInv = None;

	if (RPGMut != None)
	{
		RPGMut.SaveData();
		RPGMut = None;
	}

	SaveConfig();
	Master.RemoveInteraction(self);
}

defaultproperties
{
     bDefaultBindings=True
     bDefaultArtifactBindings=True
     WhiteColor=(B=255,G=255,R=255,A=255)
     ArtifactText="U use, [ ] switch"
     bVisible=True
}
