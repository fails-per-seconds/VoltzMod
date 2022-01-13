class BTClient_MapVoteFooter extends MapVoteFooter;

var automated GUIButton b_Random;

delegate OnRandom();

function bool InternalOnClick(GUIComponent Sender)
{
	if (Super.InternalOnClick(sender))
		return true;

	if (Sender == b_Random)
	{
		OnRandom();
		return true;
	}
}

function bool MyOnDraw(canvas C);

defaultproperties
{
     Begin Object Class=GUIButton Name=RandomButton
         Caption="Random"
         WinLeft=0.100000
         WinWidth=0.200000
         WinHeight=0.180000
         TabOrder=1
         bBoundToParent=True
         bScaleToParent=True
         bStandardized=True
         OnClick=BTClient_MapVoteFooter.InternalOnClick
         OnKeyEvent=RandomButton.InternalOnKeyEvent
     End Object
     b_Random=GUIButton'BTClient_MapVoteFooter.RandomButton'

     Begin Object Class=AltSectionBackground Name=MapvoteFooterBackground
         bFillClient=True
         Caption="Chat"
         LeftPadding=0.010000
         RightPadding=0.010000
         WinHeight=1.000000
         bBoundToParent=True
         bScaleToParent=True
         OnPreDraw=MapvoteFooterBackground.InternalPreDraw
     End Object
     sb_Background=AltSectionBackground'BTClient_MapVoteFooter.MapvoteFooterBackground'

     Begin Object Class=GUIScrollTextBox Name=ChatScrollBox
         bNoTeletype=True
         CharDelay=0.002500
         EOLDelay=0.000000
         bVisibleWhenEmpty=True
         OnCreateComponent=ChatScrollBox.InternalOnCreateComponent
         StyleName="ServerBrowserGrid"
         WinTop=0.273580
         WinLeft=0.043845
         WinWidth=0.918970
         WinHeight=0.582534
         TabOrder=2
         bBoundToParent=True
         bScaleToParent=True
         bNeverFocus=True
     End Object
     lb_Chat=GUIScrollTextBox'BTClient_MapVoteFooter.ChatScrollBox'

     Begin Object Class=moEditBox Name=ChatEditbox
         CaptionWidth=0.150000
         Caption="Say"
         OnCreateComponent=ChatEditbox.InternalOnCreateComponent
         WinTop=0.850000
         WinLeft=0.100000
         WinWidth=0.600000
         WinHeight=0.180000
         TabOrder=0
         bBoundToParent=True
         bScaleToParent=True
         OnKeyEvent=BTClient_MapVoteFooter.InternalOnKeyEvent
     End Object
     ed_Chat=moEditBox'BTClient_MapVoteFooter.ChatEditbox'

     Begin Object Class=GUIButton Name=AcceptButton
         Caption="Accept"
         Hint="Click once you are satisfied with all settings and wish to offer no further modifications"
         WinLeft=0.300000
         WinWidth=0.200000
         WinHeight=0.180000
         TabOrder=1
         bBoundToParent=True
         bScaleToParent=True
         bVisible=False
         bStandardized=True
         OnClick=BTClient_MapVoteFooter.InternalOnClick
         OnKeyEvent=AcceptButton.InternalOnKeyEvent
     End Object
     b_Accept=GUIButton'BTClient_MapVoteFooter.AcceptButton'

     Begin Object Class=GUIButton Name=SubmitButton
         Caption="Submit"
         WinLeft=0.700000
         WinWidth=0.200000
         WinHeight=0.180000
         TabOrder=1
         bBoundToParent=True
         bScaleToParent=True
         bStandardized=True
         OnClick=BTClient_MapVoteFooter.InternalOnClick
         OnKeyEvent=SubmitButton.InternalOnKeyEvent
     End Object
     b_Submit=GUIButton'BTClient_MapVoteFooter.SubmitButton'

     Begin Object Class=GUIButton Name=CloseButton
         Caption="Close"
         WinTop=0.830000
         WinLeft=0.700000
         WinWidth=0.200000
         WinHeight=0.180000
         TabOrder=1
         bBoundToParent=True
         bScaleToParent=True
         bStandardized=True
         OnClick=BTClient_MapVoteFooter.InternalOnClick
         OnKeyEvent=CloseButton.InternalOnKeyEvent
     End Object
     b_Close=GUIButton'BTClient_MapVoteFooter.CloseButton'
}
