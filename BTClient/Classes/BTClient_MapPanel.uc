class BTClient_MapPanel extends GUIPanel;

var automated GUIImage MapScreenshot;
var automated GUILabel MapLabel;
var automated GUIMultiColumnListBox MapData;

var private array<struct sMapKey
{
	var string Key;
	var string Value;
}> MapKeys;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	super.Initcomponent(MyController, MyOwner);
	MapData.List.Style = Controller.GetStyle("BTMultiColumnList", MapData.List.FontScale);
	MapData.List.GetItemHeight = InternalGetItemHeight;
	MapData.List.OnDrawItem = InternalOnDrawMapValue;
	MapData.List.OnDblClick = InternalOnViewMapValue;
}

function float InternalGetItemHeight(Canvas C)
{
	local float xl, yl;

	MapData.List.Style.TextSize(C, MapData.List.MenuState, "T", xl, yl, MapData.List.FontScale);
	return yl + 8;
}

delegate OnMapSelected(GUIComponent sender, string mapName);

function InternalOnMapSelected(GUIComponent sender, string mapName)
{
	local LevelInfo mapInfo;
	local CacheManager.MapRecord mapRecord;
	local string mapTitle;

	Clear();
	mapRecord = class'CacheManager'.static.GetMapRecord(mapName);
	if (mapRecord.MapName == "")
	{
		mapInfo = LevelInfo(DynamicLoadObject(mapName$".LevelInfo0", class'LevelInfo', true));
		if (mapInfo == none)
		{
			MapLabel.Caption = "N/A";
			MapScreenshot.Image = none;
			return;
		}

		mapTitle = mapInfo.Title;
		MapScreenshot.Image = mapInfo.Screenshot;
		AddValue("Author", mapInfo.Author);
		AddValue("Desc", mapInfo.Description);
		AddValue("LCA", Eval(Actor(DynamicLoadObject(mapName$".LevelConfigActor0", class'Actor', true)) != none, "True", "False"));
	}
	else
	{
		mapTitle = mapRecord.FriendlyName;
		MapScreenshot.Image = Material(DynamicLoadObject(mapRecord.ScreenShotRef, class'Material', true));
		AddValue("Author", mapRecord.Author);
		AddValue("Desc", mapRecord.Description);
		AddValue("Scale", mapRecord.PlayerCountMin @ "-" @ mapRecord.PlayerCountMax);
		AddValue("Extra", mapRecord.ExtraInfo);
	}
	MapLabel.Caption = mapTitle;
}

function InternalOnDrawMapValue(Canvas C, int i, float X, float Y, float W, float H, bool bSelected, bool bPending)
{
	local GUIStyles drawStyle;
	local float CellLeft, CellWidth;

	Y += 2;
	H -= 2;

	C.Style = 1;
	C.SetPos(X, Y);
	if (bSelected)
		C.DrawColor = #0x33333394;
	else
		C.DrawColor = #0x22222282;

	C.DrawTile(Texture'BTScoreBoardBG', W, H, 0, 0, 256, 256);

	drawStyle = MapData.List.Style;
	MenuState = MSAT_Blurry;
	if (bSelected)
	{
		MenuState = MSAT_Focused;
	}

	MapData.List.GetCellLeftWidth(0, CellLeft, CellWidth);
	drawStyle.DrawText(C, MenuState, CellLeft, Y, CellWidth, H, TXTA_Left, MapKeys[i].Key, MapData.List.FontScale);

	MapData.List.GetCellLeftWidth(1, CellLeft, CellWidth);
	drawStyle.DrawText(C, MenuState, CellLeft, Y, CellWidth, H, TXTA_Left, MapKeys[i].Value, MapData.List.FontScale);
}

function bool InternalOnViewMapValue(GUIComponent sender)
{
	local string value;

	if (MapData.List.Index == -1)
		return false;

	value = MapKeys[MapData.List.Index].Value;
	if (value == "")
		return false;

	Controller.OpenMenu("GUI2K4.GUI2K4QuestionPage");
 	GUIQuestionPage(Controller.TopPage()).SetPosition(0.05, 0.1, 0.9, 0.8, true);
	GUIQuestionPage(Controller.TopPage()).SetupQuestion(value, QBTN_Ok, QBTN_Ok);
	return true;
}

final function Clear()
{
	MapData.List.Clear();
	MapKeys.Length = 0;
}

final function AddValue(coerce string key, coerce string value)
{
	local int i;

	i = MapKeys.Length;
	MapKeys.Length = i + 1;
	MapKeys[i].Key = key;
	MapKeys[i].Value = value;
	MapData.List.AddedItem();
}

final static preoperator Color #( int rgbInt )
{
	local Color c;

	c.R = rgbInt >> 24;
	c.G = rgbInt >> 16;
	c.B = rgbInt >> 8;
	c.A = (rgbInt & 255);
	return c;
}

defaultproperties
{
     Begin Object Class=GUIImage Name=oMapScreenshot
         ImageStyle=ISTY_Scaled
         ImageRenderStyle=MSTY_Normal
         WinWidth=0.500000
         WinHeight=1.000000
         RenderWeight=0.200000
         bBoundToParent=True
         bScaleToParent=True
     End Object
     MapScreenshot=GUIImage'BTClient_MapPanel.oMapScreenshot'

     Begin Object Class=GUILabel Name=oMapLabel
         Caption="N/A"
         TextAlign=TXTA_Center
         TextColor=(B=255,G=255,R=255)
         WinTop=0.010000
         WinWidth=0.500000
         WinHeight=0.200000
         bBoundToParent=True
         bScaleToParent=True
     End Object
     MapLabel=GUILabel'BTClient_MapPanel.oMapLabel'

     Begin Object Class=GUIMultiColumnListBox Name=oGUIMultiColumnListBox
         Begin Object Class=BTClient_MultiColumnListHeader Name=oHeader
             BarStyleName=""
             OnDraw=oHeader.InternalOnDraw
         End Object

         HeaderColumnPerc(0)=0.280000
         HeaderColumnPerc(1)=0.720000
         ColumnHeadings(0)="Key"
         ColumnHeadings(1)="Value"
         bVisibleWhenEmpty=True
         OnCreateComponent=oGUIMultiColumnListBox.InternalOnCreateComponent
         WinLeft=0.520000
         WinWidth=0.480000
         WinHeight=0.990000
         bBoundToParent=True
         bScaleToParent=True
     End Object
     MapData=GUIMultiColumnListBox'BTClient_MapPanel.oGUIMultiColumnListBox'

     OnMapSelected=BTClient_MapPanel.InternalOnMapSelected
     StyleName="BTHUD"
}
