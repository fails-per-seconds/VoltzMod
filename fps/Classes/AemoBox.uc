class AemoBox extends GUIMenuOption;

var(Option) bool bMaskText, bReadOnly;
var(Option) editconst noexport AeGUIBox MyEditBox;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	Super.InitComponent(MyController, MyOwner);

	MyEditBox = AeGUIBox(MyComponent);

	ReadOnly(bReadOnly || bValueReadOnly);
	MaskText(bMaskText);
}

function SetComponentValue(coerce string NewValue, optional bool bNoChange)
{
	if (bNoChange)
		bIgnoreChange = True;

	SetText(NewValue);
	bIgnoreChange = False;
}

function string GetComponentValue()
{
	return GetText();
}

function string GetText()
{
	return MyEditBox.GetText();
}

function SetText(string NewText)
{
	MyEditBox.SetText(NewText);
}

function ReadOnly(bool b)
{
	SetReadOnly(b);
}

function SetReadOnly(bool b)
{
	Super.SetReadOnly(b);
	MyEditBox.bReadOnly = b;
}

function IntOnly(bool b)
{
	MyEditBox.bIntOnly = b;
}

function FloatOnly(bool b)
{
	MyEditBox.bFloatOnly = b;
}

function MaskText(bool b)
{
	MyEditBox.bMaskText = b;
}

defaultproperties
{
     bReadOnly=True
     CaptionWidth=0.710000
     ComponentClassName="fps.AeGUIBox"
     LabelStyleName="MyLabel"
     LabelColor=(R=255,G=255,B=255,A=255)
     bNeverFocus=True
}
