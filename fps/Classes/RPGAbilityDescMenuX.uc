class RPGAbilityDescMenuX extends RPGAbilityDescMenu;

var automated GUIScrollTextBox MaxText;

defaultproperties
{
     Begin Object Class=GUIScrollTextBox Name=MaxLevelText
         CharDelay=0.002500
         EOLDelay=0.002500
         OnCreateComponent=MaxLevelText.InternalOnCreateComponent
         WinTop=0.630000
         WinLeft=0.210000
         WinWidth=0.580000
         WinHeight=0.070000
         bNeverFocus=True
     End Object
     MaxText=GUIScrollTextBox'fps.RPGAbilityDescMenuX.MaxLevelText'

     Begin Object Class=GUIScrollTextBox Name=InfoText
         CharDelay=0.002500
         EOLDelay=0.002500
         OnCreateComponent=InfoText.InternalOnCreateComponent
         WinTop=0.240000
         WinLeft=0.210000
         WinWidth=0.580000
         WinHeight=0.380000
         bNeverFocus=True
     End Object
     MyScrollText=GUIScrollTextBox'fps.RPGAbilityDescMenuX.InfoText'

     Begin Object Class=GUIButton Name=ButtonClose
         Caption="Close"
         WinTop=0.710000
         WinLeft=0.400000
         WinWidth=0.200000
         OnClick=RPGAbilityDescMenuX.CloseClick
         OnKeyEvent=ButtonClose.InternalOnKeyEvent
     End Object
     CloseButton=GUIButton'fps.RPGAbilityDescMenuX.ButtonClose'
}
