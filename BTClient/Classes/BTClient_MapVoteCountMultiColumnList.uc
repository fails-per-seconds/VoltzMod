class BTClient_MapVoteCountMultiColumnList extends MapVoteCountMultiColumnList;

event InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	Super.InitComponent(MyController, MyOwner);
	Style = Controller.GetStyle("BTMultiColumnList", FontScale);
}

final static function string ParseMapName(string mapName)
{
	return class'BTClient_MapVoteMultiColumnList'.static.ParseMapName(mapName);
}

function string GetSelectedMapName()
{
	if (Index > -1)
		return ParseMapName(VRI.MapList[VRI.MapVoteCount[SortData[Index].SortItem].MapIndex].MapName);
	else
		return "";
}

function float InternalGetItemHeight(Canvas C)
{
	local float xl, yl;

	Style.TextSize(C, MenuState, "T", xl, yl, FontScale);
	return yl + 8;
}

function DrawItem(Canvas C, int i, float X, float Y, float W, float H, bool bSelected, bool bPending)
{
	local float CellLeft, CellWidth;
	local GUIStyles DrawStyle;

	if (VRI == none)
		return;

	Y += 2;
	H -= 2;

	C.Style = 1;
	C.SetPos(X, Y);
	if (bSelected)
	{
		C.DrawColor = #0x33333394;
	}
	else
	{
		C.DrawColor = #0x22222282;
	}
	C.DrawTile(Texture'BTScoreBoardBG', W, H, 0, 0, 256, 256);

	MenuState = MSAT_Blurry;
	DrawStyle = Style;
	GetCellLeftWidth(0, CellLeft, CellWidth);
	DrawStyle.DrawText(C, MenuState, CellLeft, Y, CellWidth, H, TXTA_Left, VRI.GameConfig[VRI.MapVoteCount[SortData[i].SortItem].GameConfigIndex].GameName, FontScale);

	GetCellLeftWidth(1, CellLeft, CellWidth);
	DrawStyle.DrawText(C, MenuState, CellLeft, Y, CellWidth, H, TXTA_Left, ParseMapName(VRI.MapList[VRI.MapVoteCount[SortData[i].SortItem].MapIndex].MapName), FontScale);

	GetCellLeftWidth(2, CellLeft, CellWidth);
	DrawStyle.DrawText(C, MenuState, CellLeft, Y, CellWidth, H, TXTA_Left, string(VRI.MapVoteCount[SortData[i].SortItem].VoteCount), FontScale);
}

function string GetSortString(int i)
{
	local string ColumnData[5];

	ColumnData[0] = left(Caps(VRI.GameConfig[VRI.MapVoteCount[i].GameConfigIndex].GameName),15);
	ColumnData[1] = left(Caps(ParseMapName(VRI.MapList[VRI.MapVoteCount[i].MapIndex].MapName)),20);
	ColumnData[2] = right("0000" $ VRI.MapVoteCount[i].VoteCount,4);

	return ColumnData[SortColumn] $ ColumnData[PrevSortColumn];
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
     ColumnHeadings(1)="Map Name"
     GetItemHeight=BTClient_MapVoteCountMultiColumnList.InternalGetItemHeight
     SelectedStyleName="BTListSelection"
     SelectedBKColor=(B=255)
     StyleName="BTMultiColumnList"
}
