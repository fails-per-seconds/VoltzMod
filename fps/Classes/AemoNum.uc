class AemoNum extends GUIMenuOption;

var(Option) bool bMaskText, bReadOnly;
var(Option) editconst noexport AeGUINum MyNum;
var() string Value;
var() int MinValue;
var() int MaxValue;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	MyNum.bIntOnly = True;
	if (MinValue < 0)
		MyNum.bIncludeSign = True;

	Super.Initcomponent(MyController, MyOwner);

	MyNum = AeGUINum(MyComponent);

	MyNum.OnChange = EditOnChange;
	MyNum.SetText(Value);
	MyNum.OnKeyEvent = EditKeyEvent;
	MyNum.OnDeActivate = CheckValue;

	CalcMaxLen();

	MyNum.IniOption  = IniOption;
	MyNum.IniDefault = IniDefault;

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

	MyNum.MaxWidth = DigitCount;
}

function SetValue(int V)
{
	if (V < MinValue)
		V = MinValue;

	if (V > MaxValue)
		V = MaxValue;

	MyNum.SetText(string(Clamp(V, MinValue, MaxValue)));
}

function bool EditKeyEvent(out byte Key, out byte State, float Delta)
{
	return MyNum.InternalOnKeyEvent(Key,State,Delta);
}

function EditOnChange(GUIComponent Sender)
{
	Value = string(Clamp(int(MyNum.TextStr), MinValue, MaxValue));
	OnChange(Self);
}

function CheckValue()
{
	SetValue(int(Value));
}

function ValidateValue()
{
	local int i;

	i = int(MyNum.TextStr);
	MyNum.TextStr = string(Clamp(i, MinValue, MaxValue));
	MyNum.bHasFocus = False;
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
	return MyNum.GetText();
}

function SetText(string NewText)
{
	MyNum.SetText(NewText);
}

function ReadOnly(bool b)
{
	SetReadOnly(b);
}

function SetReadOnly(bool b)
{
	Super.SetReadOnly(b);
	MyNum.bReadOnly = b;
}

function IntOnly(bool b)
{
	MyNum.bIntOnly = b;
}

function FloatOnly(bool b)
{
	MyNum.bFloatOnly = b;
}

function MaskText(bool b)
{
	MyNum.bMaskText = b;
}

defaultproperties
{
     Value="0"
     MinValue=1
     MaxValue=9999
     bReadOnly=False
     CaptionWidth=0.010000
     ComponentClassName="fps.AeGUINum"
     LabelStyleName="MyLabel"
     LabelColor=(R=255,G=255,B=255,A=255)
     PropagateVisibility=False
     WinHeight=0.060000
     bAcceptsInput=True
}
