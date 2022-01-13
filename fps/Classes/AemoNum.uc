class AemoNum extends GUIMenuOption;

var(Option) bool bMaskText, bReadOnly;
var(Option) editconst noexport AeGUIEditBox MyEditBox;
var() string Value;
var() int MinValue;
var() int MaxValue;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	if (MinValue < 0)
		MyEditBox.bIncludeSign = True;

	Super.Initcomponent(MyController, MyOwner);

	MyEditBox = AeGUIEditBox(MyComponent);

	MyEditBox.OnChange = EditOnChange;
	MyEditBox.SetText(Value);
	MyEditBox.OnKeyEvent = EditKeyEvent;
	MyEditBox.OnDeActivate = CheckValue;

	CalcMaxLen();

	MyEditBox.IniOption  = IniOption;
	MyEditBox.IniDefault = IniDefault;

	ReadOnly(bReadOnly || bValueReadOnly);
	MaskText(bMaskText);
}

function CalcMaxLen()
{
	local int x, DigitCount;

	DigitCount = 1;
	x = 10;
	while (x <= MaxValue)
	{
		DigitCount++;
		x*=10;
	}

	MyEditBox.MaxWidth = DigitCount;
}

function SetValue(int V)
{
	if (V < MinValue)
		V = MinValue;

	if (V > MaxValue)
		V = MaxValue;

	MyEditBox.SetText(string(Clamp(V, MinValue, MaxValue)));
}

function bool EditKeyEvent(out byte Key, out byte State, float Delta)
{
	return MyEditBox.InternalOnKeyEvent(Key,State,Delta);
}

function EditOnChange(GUIComponent Sender)
{
	Value = string(Clamp(int(MyEditBox.TextStr), MinValue, MaxValue));
	OnChange(Self);
}

function CheckValue()
{
	SetValue(int(Value));
}

function ValidateValue()
{
	local int i;

	i = int(MyEditBox.TextStr);
	MyEditBox.TextStr = string(Clamp(i, MinValue, MaxValue));
	MyEditBox.bHasFocus = False;
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
     CaptionWidth=0.010000
     ComponentClassName="fps.AeGUIEditBox"
     Value="0"
     MinValue=-9999
     MaxValue=9999
     PropagateVisibility=False
     WinHeight=0.060000
     bAcceptsInput=True
     bReadOnly=False
}
