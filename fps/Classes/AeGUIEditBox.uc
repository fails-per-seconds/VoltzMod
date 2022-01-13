class AeGUIEditBox extends GUIEditBox;

//var() string TextStr;		<- Holds the current string
//var() string AllowedCharSet;	<- Only Allow these characters
//var() bool bMaskText;		<- Displays the text as a *
//var() bool bIntOnly;		<- Only Allow Interger Numeric entry
//var() bool bFloatOnly;	<- Only Allow Float Numeric entry
//var() bool bIncludeSign;	<- Do we need to allow a -/+ sign
//var() bool bConvertSpaces;	<- Do we want to convert Spaces to "_"
//var() int MaxWidth;		<- Holds the maximum width (in chars) of the string - 0 = No Max
//var() eTextCase TextCase;	<- Controls forcing case, etc
//var() int BorderOffsets[4];	<- How far in from the edit is the edit area
//var() bool bReadOnly;		<- Can't actually edit this box
//var() bool bAlwaysNotify;	<- if true, send OnChange event when receive SetText(), even if text is identical
//var int CaretPos;
//var int FirstVis;
//var int LastSizeX;
//var int LastCaret, LastLength;

//var bool bAllSelected;
//var byte LastKey;
//var() float DelayTime;

defaultproperties
{
     MaxWidth=768
     LastCaret=-1
     LastLength=-1
     StyleName="AeEditBoxStyle"
     WinHeight=0.040000
     bCaptureMouse=False
     bRequiresStyle=True
     OnClickSound=CS_Edit
     OnActivate=AeGUIEditBox.InternalActivate
     OnDeActivate=AeGUIEditBox.InternalDeactivate
     OnKeyType=AeGUIEditBox.InternalOnKeyType
     OnKeyEvent=AeGUIEditBox.InternalOnKeyEvent
}
