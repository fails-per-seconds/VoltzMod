class BTGUI_ScoreboardBase extends FloatingWindow;

// Removed i_FrameBG access
function InitComponent( GUIController MyController, GUIComponent MyOwner )
{
	super(PopupPageBase).InitComponent( MyController, MyOwner );
	t_WindowTitle.SetCaption(WindowName);
	if ( bMoveAllowed )
	{
		t_WindowTitle.bAcceptsInput = true;
		t_WindowTitle.MouseCursorIndex = HeaderMouseCursorIndex;
	}
	AddSystemMenu();
}

// Removed i_FrameBG access
function bool AlignFrame(Canvas C)
{
	return bInit;
}

function AddSystemMenu()
{
	b_ExitButton = GUIButton(t_WindowTitle.AddComponent( "XInterface.GUIButton" ));
	b_ExitButton.Style = Controller.GetStyle( "BTCloseButton", t_WindowTitle.FontScale );
	b_ExitButton.OnClick = XButtonClicked;
	b_ExitButton.bNeverFocus=true;
	b_ExitButton.FocusInstead = t_WindowTitle;
	b_ExitButton.RenderWeight=1.0;
	b_ExitButton.bScaleToParent=false;
	b_ExitButton.bAutoShrink=false;
	b_ExitButton.OnPreDraw = SystemMenuPreDraw;
	b_ExitButton.Caption = "X";

	// Do not want OnClick() called from MousePressed()
	b_ExitButton.bRepeatClick = False;
}

function bool SystemMenuPreDraw(canvas Canvas)
{
    BackgroundColor = class'BTClient_Config'.static.FindSavedData().CTable;
	b_ExitButton.SetPosition( t_WindowTitle.ActualLeft() + t_WindowTitle.ActualWidth() - b_ExitButton.ActualWidth(), t_WindowTitle.ActualTop(), t_WindowTitle.ActualHeight(), t_WindowTitle.ActualHeight(), true);
	return true;
}

defaultproperties
{
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
         OnMousePressed=BTGUI_ScoreboardBase.FloatingMousePressed
         OnMouseRelease=BTGUI_ScoreboardBase.FloatingMouseRelease
     End Object
     t_WindowTitle=GUIHeader'BTGUI_ScoreboardBase.TitleBar'

     i_FrameBG=None

     Background=Texture'HUD.BTScoreBoardBG'
     BackgroundRStyle=MSTY_Normal
}
