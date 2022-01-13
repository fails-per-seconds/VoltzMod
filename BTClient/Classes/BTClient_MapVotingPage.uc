class BTClient_MapVotingPage extends MapVotingPage;

var automated GUIButton b_Random;
var automated GUIEditBox MapNameFilter;
var automated GUILabel FilterLabel;
var automated BTClient_MapPanel MapPanel;

var automated GUILabel GameTypeFilter;
var automated BTGUI_ComboBox ComboGameType;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	Super(PopupPageBase).InitComponent(MyController, MyOwner);
	t_WindowTitle.SetCaption(WindowName);
	if (bMoveAllowed)
	{
		t_WindowTitle.bAcceptsInput = true;
		t_WindowTitle.MouseCursorIndex = HeaderMouseCursorIndex;
	}
	AddSystemMenu();

	MVRI = VotingReplicationInfo(PlayerOwner().VoteReplicationInfo);
	if (PlayerOwner() != None && PlayerOwner().Level.Pauser != None)
		PlayerOwner().SetPause(false);
}

function bool AlignFrame(Canvas C)
{
	return bInit;
}

function AddSystemMenu()
{
	b_ExitButton = GUIButton(t_WindowTitle.AddComponent("XInterface.GUIButton"));
	b_ExitButton.Style = Controller.GetStyle("BTCloseButton", t_WindowTitle.FontScale);
	b_ExitButton.OnClick = XButtonClicked;
	b_ExitButton.bNeverFocus=true;
	b_ExitButton.FocusInstead = t_WindowTitle;
	b_ExitButton.RenderWeight=1.0;
	b_ExitButton.bScaleToParent=false;
	b_ExitButton.bAutoShrink=false;
	b_ExitButton.OnPreDraw = SystemMenuPreDraw;
	b_ExitButton.Caption = "X";

	b_ExitButton.bRepeatClick = False;
}

function bool SystemMenuPreDraw(canvas Canvas)
{
	BackgroundColor = class'BTClient_Config'.static.FindSavedData().CTable;
	b_ExitButton.SetPosition(t_WindowTitle.ActualLeft() + t_WindowTitle.ActualWidth() - b_ExitButton.ActualWidth(), t_WindowTitle.ActualTop(), t_WindowTitle.ActualHeight(), t_WindowTitle.ActualHeight(), true);
	return true;
}

function bool InternalOnPanelBackgroundDraw(Canvas C)
{
	C.SetPos(MapPanel.ActualLeft(), MapPanel.ActualTop());
	C.DrawColor = class'BTClient_Config'.static.FindSavedData().CTable;
	C.DrawTile(Texture'BTScoreBoardBG', MapPanel.ActualWidth(), MapPanel.ActualHeight(), 0, 0, 256, 256);
	return false;
}

function InternalOnReceiveMapInfo(VotingHandler.MapVoteMapList mapInfo)
{
	local int l;

	if (BTClient_MapVoteMultiColumnList(lb_MapListBox.List).IsFiltered(MVRI, ComboGameType.GetIndex(), mapInfo.MapName))
		return;

	l = BTClient_MapVoteMultiColumnList(lb_MapListBox.List).MapVoteData.Length;
	BTClient_MapVoteMultiColumnList(lb_MapListBox.List).MapVoteData.Insert(l,1);
	BTClient_MapVoteMultiColumnList(lb_MapListBox.List).MapVoteData[l] = MVRI.MapList.Length - 1;
	BTClient_MapVoteMultiColumnList(lb_MapListBox.List).AddedItem();
}

function InternalOnOpen()
{
	local int i, d;

	if (MVRI == none || (MVRI != none && !MVRI.bMapVote))
	{
		Controller.OpenMenu("GUI2K4.GUI2K4QuestionPage");
		GUIQuestionPage(Controller.TopPage()).SetupQuestion(lmsgMapVotingDisabled, QBTN_Ok, QBTN_Ok);
		GUIQuestionPage(Controller.TopPage()).OnButtonClick = OnOkButtonClick;
		return;
	}

	if (MVRI.GameConfig.Length < MVRI.GameConfigCount)
	{
		Controller.OpenMenu("GUI2K4.GUI2K4QuestionPage");
		GUIQuestionPage(Controller.TopPage()).SetupQuestion(lmsgReplicationNotFinished, QBTN_Ok, QBTN_Ok);
		GUIQuestionPage(Controller.TopPage()).OnButtonClick = OnOkButtonClick;
		return;
	}

	MapPanel.OnDraw = InternalOnPanelBackgroundDraw;
	BTClient_VRI(MVRI).OnReceiveMapInfo = InternalOnReceiveMapInfo;

	for(i = 0; i < MVRI.GameConfig.Length; i++)
		ComboGameType.AddItem( MVRI.GameConfig[i].GameName, none, string(i));
	ComboGameType.List.SortList();

	d = ComboGameType.List.FindExtra(string(MVRI.CurrentGameConfig));
	if (d > -1)
		ComboGameType.SetIndex(d);

	t_WindowTitle.Caption = t_WindowTitle.Caption@"("$lmsgMode[MVRI.Mode]$")";

	lb_MapListBox.LoadList(MVRI);
	MapVoteCountMultiColumnList(lb_VoteCountListBox.List).LoadList(MVRI);

	lb_VoteCountListBox.List.OnDblClick = MapListDblClick;
	lb_VoteCountListBox.List.bDropTarget = True;

	lb_MapListBox.List.OnDblClick = MapListDblClick;
	lb_MaplistBox.List.bDropSource = True;
	lb_MaplistBox.List.OnChange = MapSelectionChanged;
	ComboGameType.OnChange = GameTypeChanged;
}

function GameTypeChanged(GUIComponent Sender)
{
	local int GameTypeIndex;

	GameTypeIndex = int(ComboGameType.GetExtra());
	if (GameTypeIndex > -1)
	{
		lb_MapListBox.ChangeGameType(GameTypeIndex);
		lb_MapListBox.List.OnDblClick = MapListDblClick;
		MapNameFilter.SetText("");
	}
}

function bool RandomClicked(GUIComponent sender)
{
	local int GameConfigIndex, randomMapIndex, generationAttempts;
	local BTClient_MapVoteMultiColumnList list;

	list = BTClient_MapVoteMultiColumnList(lb_MaplistBox.List);

	rng:
		randomMapIndex = Rand(list.MapVoteData.Length);
	if (!MVRI.MapList[list.MapVoteData[randomMapIndex]].bEnabled && !PlayerOwner().PlayerReplicationInfo.bAdmin)
	{
		if (generationAttempts >= 100)
		{
			PlayerOwner().ClientMessage(lmsgMapDisabled);
			return false;
		}

		++generationAttempts;
		goto rng;
	}

	GameConfigIndex = int(ComboGameType.GetExtra());
	if (GameConfigIndex > -1)
	{
		MVRI.SendMapVote(list.MapVoteData[randomMapIndex], GameConfigIndex);
	}
	return true;
}

function InternalOnFilterChange(GUIComponent sender)
{
	local string filter;

	filter = MapNameFilter.GetText();
	BTClient_MapVoteMultiColumnList(lb_MaplistBox.List).OnFilterVotingList(sender, filter, int(ComboGameType.GetExtra()));
}

function MapSelectionChanged(GUIComponent sender)
{
	MapPanel.OnMapSelected(sender, BTClient_MapVoteMultiColumnList(lb_MapListBox.List).GetSelectedMapName());
}

function bool AlignBK(Canvas C)
{
	return false;
}

function SendVote(GUIComponent Sender)
{
	local int MapIndex,GameConfigIndex;

	if (Sender == lb_VoteCountListBox.List)
	{
		MapIndex = MapVoteCountMultiColumnList(lb_VoteCountListBox.List).GetSelectedMapIndex();
		if (MapIndex > -1)
		{
			GameConfigIndex = MapVoteCountMultiColumnList(lb_VoteCountListBox.List).GetSelectedGameConfigIndex();
			if (MVRI.MapList[MapIndex].bEnabled || PlayerOwner().PlayerReplicationInfo.bAdmin)
				MVRI.SendMapVote(MapIndex,GameConfigIndex);
			else
				PlayerOwner().ClientMessage(lmsgMapDisabled);
		}
	}
	else
	{
		MapIndex = MapVoteMultiColumnList(lb_MapListBox.List).GetSelectedMapIndex();
		if (MapIndex > -1)
		{
			GameConfigIndex = int(ComboGameType.GetExtra());
			if (MVRI.MapList[MapIndex].bEnabled || PlayerOwner().PlayerReplicationInfo.bAdmin)
				MVRI.SendMapVote(MapIndex,GameConfigIndex);
			else
				PlayerOwner().ClientMessage(lmsgMapDisabled);
		}
	}
}

defaultproperties
{
     Begin Object Class=GUIButton Name=oRandomButton
         Caption="Random"
         StyleName="BTButton"
         WinTop=0.690000
         WinLeft=0.900000
         WinWidth=0.095000
         WinHeight=0.035000
         bBoundToParent=True
         bScaleToParent=True
         OnClick=BTClient_MapVotingPage.RandomClicked
         OnKeyEvent=oRandomButton.InternalOnKeyEvent
     End Object
     b_Random=GUIButton'BTClient_MapVotingPage.oRandomButton'

     Begin Object Class=GUIEditBox Name=oMapNameFilter
         StyleName="BTEditBox"
         WinTop=0.690000
         WinLeft=0.080000
         WinWidth=0.485000
         WinHeight=0.035000
         bBoundToParent=True
         bScaleToParent=True
         OnActivate=oMapNameFilter.InternalActivate
         OnDeActivate=oMapNameFilter.InternalDeactivate
         OnChange=BTClient_MapVotingPage.InternalOnFilterChange
         OnKeyType=oMapNameFilter.InternalOnKeyType
         OnKeyEvent=oMapNameFilter.InternalOnKeyEvent
     End Object
     MapNameFilter=GUIEditBox'BTClient_MapVotingPage.oMapNameFilter'

     Begin Object Class=GUILabel Name=oFilterLabel
         Caption="Search"
         TextAlign=TXTA_Center
         TextColor=(B=255,G=255,R=255)
         bTransparent=False
         FontScale=FNS_Small
         StyleName="BTLabel"
         WinTop=0.690000
         WinLeft=0.005000
         WinWidth=0.070000
         WinHeight=0.035000
         bBoundToParent=True
         bScaleToParent=True
     End Object
     FilterLabel=GUILabel'BTClient_MapVotingPage.oFilterLabel'

     Begin Object Class=BTClient_MapPanel Name=oMapInfo
         OnMapSelected=oMapInfo.InternalOnMapSelected
         WinTop=0.730000
         WinLeft=0.005000
         WinWidth=0.560000
         WinHeight=0.260500
         bBoundToParent=True
         bScaleToParent=True
     End Object
     MapPanel=BTClient_MapPanel'BTClient_MapVotingPage.oMapInfo'

     Begin Object Class=GUILabel Name=oGameTypeFilter
         Caption="Mode"
         TextAlign=TXTA_Center
         TextColor=(B=255,G=255,R=255)
         bTransparent=False
         FontScale=FNS_Small
         StyleName="BTLabel"
         WinTop=0.690000
         WinLeft=0.570000
         WinWidth=0.075000
         WinHeight=0.035000
         bBoundToParent=True
         bScaleToParent=True
     End Object
     GameTypeFilter=GUILabel'BTClient_MapVotingPage.oGameTypeFilter'

     Begin Object Class=BTGUI_ComboBox Name=GameTypeCombo
         bReadOnly=True
         bIgnoreChangeWhenTyping=True
         WinTop=0.690000
         WinLeft=0.650000
         WinWidth=0.245000
         WinHeight=0.035000
         bBoundToParent=True
         bScaleToParent=True
         OnKeyEvent=GameTypeCombo.InternalOnKeyEvent
     End Object
     ComboGameType=BTGUI_ComboBox'BTClient_MapVotingPage.GameTypeCombo'

     Begin Object Class=BTClient_MapVoteMultiColumnListBox Name=MapListBox
         Begin Object Class=BTClient_MultiColumnListHeader Name=oHeader
             OnDraw=oHeader.InternalOnDraw
         End Object
         Header=BTClient_MultiColumnListHeader'BTClient_MapVoteMultiColumnListBox.oHeader'

         bVisibleWhenEmpty=True
         OnCreateComponent=MapListBox.InternalOnCreateComponent
         WinTop=0.060000
         WinLeft=0.005000
         WinWidth=0.990000
         WinHeight=0.624000
         bBoundToParent=True
         bScaleToParent=True
         OnRightClick=MapListBox.InternalOnRightClick
     End Object
     lb_MapListBox=BTClient_MapVoteMultiColumnListBox'BTClient_MapVotingPage.MapListBox'

     Begin Object Class=BTClient_MapVoteCountMultiColumnListBox Name=VoteCountListBox
         Begin Object Class=BTClient_MultiColumnListHeader Name=oHeaderTwo
             OnDraw=oHeaderTwo.InternalOnDraw
         End Object
         Header=BTClient_MultiColumnListHeader'BTClient_MapVoteCountMultiColumnListBox.oHeaderTwo'

         HeaderColumnPerc(0)=0.300000
         HeaderColumnPerc(1)=0.550000
         HeaderColumnPerc(2)=0.150000
         bVisibleWhenEmpty=True
         OnCreateComponent=VoteCountListBox.InternalOnCreateComponent
         WinTop=0.730000
         WinLeft=0.570000
         WinWidth=0.425000
         WinHeight=0.260500
         bBoundToParent=True
         bScaleToParent=True
         OnRightClick=VoteCountListBox.InternalOnRightClick
     End Object
     lb_VoteCountListBox=BTClient_MapVoteCountMultiColumnListBox'BTClient_MapVotingPage.VoteCountListBox'

     co_GameType=None

     i_MapListBackground=None

     i_MapCountListBackground=None

     f_Chat=None

     Begin Object Class=GUIHeader Name=TitleBar
         Justification=TXTA_Left
         TextIndent=4
         FontScale=FNS_Large
         StyleName="BTHeader"
         WinHeight=0.040000
         RenderWeight=0.100000
         bBoundToParent=True
         bScaleToParent=True
         bAcceptsInput=True
         bNeverFocus=False
         ScalingType=SCALE_X
         OnMousePressed=BTClient_MapVotingPage.FloatingMousePressed
         OnMouseRelease=BTClient_MapVotingPage.FloatingMouseRelease
     End Object
     t_WindowTitle=GUIHeader'BTClient_MapVotingPage.TitleBar'

     i_FrameBG=None

     Background=Texture'HUD.BTScoreBoardBG'
     BackgroundRStyle=MSTY_Normal
}
