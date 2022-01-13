class RPGAbilityDescMenu extends LargeWindow;

var automated GUIScrollTextBox MyScrollText;
var automated GUILabel MyLabel;
var automated GUIButton CloseButton;

function bool CloseClick(GUIComponent Sender)
{
	Controller.CloseMenu(false);

	return true;
}

defaultproperties
{
     Begin Object Class=GUIScrollTextBox Name=InfoText
         CharDelay=0.002500
         EOLDelay=0.002500
         OnCreateComponent=InfoText.InternalOnCreateComponent
         WinTop=0.300000
         WinLeft=0.210000
         WinWidth=0.580000
         WinHeight=0.390000
         bNeverFocus=True
     End Object
     MyScrollText=GUIScrollTextBox'fps.RPGAbilityDescMenu.InfoText'

     Begin Object Class=GUIButton Name=ButtonClose
         Caption="Close"
         WinTop=0.700000
         WinLeft=0.400000
         WinWidth=0.200000
         OnClick=RPGAbilityDescMenu.CloseClick
         OnKeyEvent=ButtonClose.InternalOnKeyEvent
     End Object
     CloseButton=GUIButton'fps.RPGAbilityDescMenu.ButtonClose'

     WindowName="Ability"
     bAllowedAsLast=True
}
