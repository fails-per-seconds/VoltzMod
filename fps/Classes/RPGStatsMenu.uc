class RPGStatsMenu extends GUIPage
	DependsOn(RPGStatsInv);

var RPGStatsInv StatsInv;

var AemoBox WeaponSpeedBox, HealthBonusBox, AdrenalineMaxBox, AmmoMaxBox, PointsAvailableBox;
var AemoBox AttackBox, DefenseBox; //useless
var int StatDisplayControlsOffset, ButtonControlsOffset, AmtControlsOffset;
var int NumButtonControls;
var AeListBox Abilities;
var localized string CurrentLevelText, MaxText, CostText, CantBuyText;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	Super.InitComponent(MyController, MyOwner);

	WeaponSpeedBox = AemoBox(Controls[2]);
	HealthBonusBox = AemoBox(Controls[3]);
	AdrenalineMaxBox = AemoBox(Controls[4]);
	AttackBox = AemoBox(Controls[5]);
	DefenseBox = AemoBox(Controls[6]);
	AmmoMaxBox = AemoBox(Controls[7]);
	PointsAvailableBox = AemoBox(Controls[8]);
	Abilities = AeListBox(Controls[15]);
	Abilities.MyScrollBar.WinWidth = 0.01;
}

function bool CloseClick(GUIComponent Sender)
{
	Controller.CloseMenu(false);

	return true;
}

function MyOnClose(optional bool bCanceled)
{
	if (StatsInv != None)
	{
		StatsInv.StatsMenu = None;
		StatsInv = None;
	}

	Super.OnClose(bCanceled);
}

function InitFor(RPGStatsInv Inv)
{
	local int x, y, Index, Cost, Level, OldAbilityListIndex, OldAbilityListTop;
	local RPGPlayerDataObject TempDataObject;

	StatsInv = Inv;
	StatsInv.StatsMenu = self;

	WeaponSpeedBox.SetText(string(StatsInv.Data.WeaponSpeed));
	HealthBonusBox.SetText(string(StatsInv.Data.HealthBonus));
	AdrenalineMaxBox.SetText(string(StatsInv.Data.AdrenalineMax));
	AttackBox.SetText(string(StatsInv.Data.Attack));
	DefenseBox.SetText(string(StatsInv.Data.Defense));
	AmmoMaxBox.SetText(string(StatsInv.Data.AmmoMax));
	PointsAvailableBox.SetText(string(StatsInv.Data.PointsAvailable));

	if (StatsInv.Data.PointsAvailable <= 0)
		DisablePlusButtons();
	else
		EnablePlusButtons();

	for (x = 0; x < 6; x++)
	{
		if (StatsInv.StatCaps[x] >= 0 && int(AemoBox(Controls[StatDisplayControlsOffset+x]).GetText()) >= StatsInv.StatCaps[x])
		{
			Controls[ButtonControlsOffset+x].SetVisibility(false);
			Controls[AmtControlsOffset+x].SetVisibility(false);
		}
	}

	if (StatsInv.Role < ROLE_Authority)
	{
		TempDataObject = RPGPlayerDataObject(StatsInv.Level.ObjectPool.AllocateObject(class'RPGPlayerDataObject'));
		TempDataObject.InitFromDataStruct(StatsInv.Data);
	}
	else
	{
		TempDataObject = StatsInv.DataObject;
	}

	OldAbilityListIndex = Abilities.List.Index;
	OldAbilityListTop = Abilities.List.Top;
	Abilities.List.Clear();
	for (x = 0; x < StatsInv.AllAbilities.length; x++)
	{
		Index = -1;
		for (y = 0; y < StatsInv.Data.Abilities.length; y++)
		{
			if (StatsInv.AllAbilities[x] == StatsInv.Data.Abilities[y])
			{
				Index = y;
				y = StatsInv.Data.Abilities.length;
			}
		}
		if (Index == -1)
			Level = 0;
		else
			Level = StatsInv.Data.AbilityLevels[Index];

		if (Level >= StatsInv.AllAbilities[x].default.MaxLevel)
		{
			Abilities.List.Add(StatsInv.AllAbilities[x].default.AbilityName@"("$CurrentLevelText@Level@"["$MaxText$"])", StatsInv.AllAbilities[x], string(Cost));
		}
		else
		{
			Cost = StatsInv.AllAbilities[x].static.Cost(TempDataObject, Level);
			if (Cost <= 0)
				Abilities.List.Add(StatsInv.AllAbilities[x].default.AbilityName@"("$CurrentLevelText@Level$","@CantBuyText$")", StatsInv.AllAbilities[x], string(Cost));
			else
				Abilities.List.Add(StatsInv.AllAbilities[x].default.AbilityName@"("$CurrentLevelText@Level$","@CostText@Cost$")", StatsInv.AllAbilities[x], string(Cost));
		}
	}

	Abilities.List.SetIndex(OldAbilityListIndex);
	Abilities.List.SetTopItem(OldAbilityListTop);
	UpdateAbilityButtons(Abilities);

	if (StatsInv.Role < ROLE_Authority)
	{
		StatsInv.Level.ObjectPool.FreeObject(TempDataObject);
	}
}

function bool StatPlusClick(GUIComponent Sender)
{
	local int x, SenderIndex;

	for (x = ButtonControlsOffset; x < ButtonControlsOffset + NumButtonControls; x++)
	{
		if (Controls[x] == Sender)
		{
			SenderIndex = x;
			break;
		}
	}

	SenderIndex -= ButtonControlsOffset;
	DisablePlusButtons();
	StatsInv.ServerAddPointTo(int(AemoNum(Controls[SenderIndex + AmtControlsOffset]).Value), EStatType(SenderIndex));

	return true;
}

function DisablePlusButtons()
{
	local int x;

	for (x = ButtonControlsOffset; x < ButtonControlsOffset + NumButtonControls; x++)
		Controls[x].MenuStateChange(MSAT_Disabled);
}

function EnablePlusButtons()
{
	local int x;

	for (x = ButtonControlsOffset; x < ButtonControlsOffset + NumButtonControls; x++)
		Controls[x].MenuStateChange(MSAT_Blurry);

	for (x = AmtControlsOffset; x < AmtControlsOffset + NumButtonControls; x++)
	{
		AemoNum(Controls[x]).MaxValue = StatsInv.Data.PointsAvailable;
		AemoNum(Controls[x]).CalcMaxLen();
		if (int(AemoNum(Controls[x]).Value) > StatsInv.Data.PointsAvailable)
			AemoNum(Controls[x]).SetValue(StatsInv.Data.PointsAvailable);
	}
}

function bool UpdateAbilityButtons(GUIComponent Sender)
{
	local int Cost;

	Cost = int(Abilities.List.GetExtra());
	if (Cost <= 0 || Cost > StatsInv.Data.PointsAvailable)
		Controls[16].MenuStateChange(MSAT_Disabled);
	else
		Controls[16].MenuStateChange(MSAT_Blurry);

	return true;
}

function bool BuyAbility(GUIComponent Sender)
{
	DisablePlusButtons();
	Controls[16].MenuStateChange(MSAT_Disabled);
	StatsInv.ServerAddAbility(class<RPGAbility>(Abilities.List.GetObject()));

	return true;
}

function bool ResetClick(GUIComponent Sender)
{
	if (StatsInv.Data.Level <= 15)
	{
		Controls[23].MenuStateChange(MSAT_Disabled);
		return false;
	}
	Controller.OpenMenu("fps.RPGResetConfirmPage");
	RPGResetConfirmPage(Controller.TopPage()).StatsMenu = self;
	return true;
}

defaultproperties
{
     StatDisplayControlsOffset=2
     ButtonControlsOffset=9
     AmtControlsOffset=17
     NumButtonControls=6
     CurrentLevelText="Level:"
     MaxText="Max"
     CostText="Cost:"
     CantBuyText="Can't Buy"
     bRenderWorld=True
     bAllowedAsLast=True
     OnClose=RPGStatsMenu.MyOnClose
     Begin Object Class=FloatingImage Name=FloatingFrameBackground
         Image=Texture'fps.bgtex.fpsmenu'
         DropShadow=None
         ImageColor=(A=225)
         ImageStyle=ISTY_Stretched
         ImageRenderStyle=MSTY_Normal
         WinTop=0.125000
         WinLeft=-0.250000
         WinWidth=1.500000
         WinHeight=0.750000
         RenderWeight=0.000003
     End Object
     Controls(0)=FloatingImage'fps.RPGStatsMenu.FloatingFrameBackground'

     Begin Object Class=GUIButton Name=CloseButton
         Caption=""
         StyleName="CloseButton"
         WinTop=0.131000
         WinLeft=1.104000
         WinWidth=0.042000
         WinHeight=0.020000
         bBoundToParent=True
         bScaleToParent=True
         OnClick=RPGStatsMenu.CloseClick
         OnKeyEvent=CloseButton.InternalOnKeyEvent
     End Object
     Controls(1)=GUIButton'fps.RPGStatsMenu.CloseButton'

     Begin Object Class=AemoBox Name=WeaponSpeedSelect
         Caption="Fire-Rate"
         OnCreateComponent=WeaponSpeedSelect.InternalOnCreateComponent
         IniOption="@INTERNAL"
         WinTop=0.239000
         WinLeft=0.163000
         WinWidth=0.275000
         WinHeight=0.040000
         bBoundToParent=True
         bScaleToParent=True
     End Object
     Controls(2)=AemoBox'fps.RPGStatsMenu.WeaponSpeedSelect'

     Begin Object Class=AemoBox Name=HealthBonusSelect
         Caption="Health"
         OnCreateComponent=HealthBonusSelect.InternalOnCreateComponent
         IniOption="@INTERNAL"
         WinTop=0.339000
         WinLeft=0.163000
         WinWidth=0.275000
         WinHeight=0.040000
         bBoundToParent=True
         bScaleToParent=True
     End Object
     Controls(3)=AemoBox'fps.RPGStatsMenu.HealthBonusSelect'

     Begin Object Class=AemoBox Name=AdrenalineMaxSelect
         Caption="Adrenaline"
         OnCreateComponent=AdrenalineMaxSelect.InternalOnCreateComponent
         IniOption="@INTERNAL"
         WinTop=0.439000
         WinLeft=0.163000
         WinWidth=0.275000
         WinHeight=0.040000
         bBoundToParent=True
         bScaleToParent=True
     End Object
     Controls(4)=AemoBox'fps.RPGStatsMenu.AdrenalineMaxSelect'

     Begin Object Class=AemoBox Name=AttackSelect
         Caption="Damage Bonus (0.5%)"
         OnCreateComponent=AttackSelect.InternalOnCreateComponent
         IniOption="@INTERNAL"
         WinTop=0.357448
         WinLeft=0.250000
         WinWidth=0.362500
         WinHeight=0.040000
     End Object
     Controls(5)=AemoBox'fps.RPGStatsMenu.AttackSelect'

     Begin Object Class=AemoBox Name=DefenseSelect
         Caption="Damage Reduction (0.5%)"
         OnCreateComponent=DefenseSelect.InternalOnCreateComponent
         IniOption="@INTERNAL"
         WinTop=0.437448
         WinLeft=0.250000
         WinWidth=0.362500
         WinHeight=0.040000
     End Object
     Controls(6)=AemoBox'fps.RPGStatsMenu.DefenseSelect'

     Begin Object Class=AemoBox Name=MaxAmmoSelect
         Caption="Ammunition"
         OnCreateComponent=MaxAmmoSelect.InternalOnCreateComponent
         IniOption="@INTERNAL"
         WinTop=0.539000
         WinLeft=0.163000
         WinWidth=0.275000
         WinHeight=0.040000
         bBoundToParent=True
         bScaleToParent=True
     End Object
     Controls(7)=AemoBox'fps.RPGStatsMenu.MaxAmmoSelect'

     Begin Object Class=AemoBox Name=PointsAvailableSelect
         CaptionWidth=0.775000
         Caption="Ability Points [AP]"
         OnCreateComponent=PointsAvailableSelect.InternalOnCreateComponent
         IniOption="@INTERNAL"
         WinTop=0.150000
         WinLeft=0.457000
         WinWidth=0.350000
         WinHeight=0.040000
         bBoundToParent=True
         bScaleToParent=True
     End Object
     Controls(8)=AemoBox'fps.RPGStatsMenu.PointsAvailableSelect'

     Begin Object Class=GUIButton Name=WeaponSpeedButton
         Caption="+"
         StyleName="MyButton"
         WinTop=0.270000
         WinLeft=0.440000
         WinWidth=0.040000
         bBoundToParent=True
         bScaleToParent=True
         OnClick=RPGStatsMenu.StatPlusClick
         OnKeyEvent=WeaponSpeedButton.InternalOnKeyEvent
     End Object
     Controls(9)=GUIButton'fps.RPGStatsMenu.WeaponSpeedButton'

     Begin Object Class=GUIButton Name=HealthBonusButton
         Caption="+"
         StyleName="MyButton"
         WinTop=0.370000
         WinLeft=0.440000
         WinWidth=0.040000
         bBoundToParent=True
         bScaleToParent=True
         OnClick=RPGStatsMenu.StatPlusClick
         OnKeyEvent=HealthBonusButton.InternalOnKeyEvent
     End Object
     Controls(10)=GUIButton'fps.RPGStatsMenu.HealthBonusButton'

     Begin Object Class=GUIButton Name=AdrenalineMaxButton
         Caption="+"
         StyleName="MyButton"
         WinTop=0.470000
         WinLeft=0.440000
         WinWidth=0.040000
         bBoundToParent=True
         bScaleToParent=True
         OnClick=RPGStatsMenu.StatPlusClick
         OnKeyEvent=AdrenalineMaxButton.InternalOnKeyEvent
     End Object
     Controls(11)=GUIButton'fps.RPGStatsMenu.AdrenalineMaxButton'

     Begin Object Class=GUIButton Name=AttackButton
         Caption="+"
         WinTop=0.367448
         WinLeft=0.737500
         WinWidth=0.040000
         OnClick=RPGStatsMenu.StatPlusClick
         OnKeyEvent=AttackButton.InternalOnKeyEvent
     End Object
     Controls(12)=GUIButton'fps.RPGStatsMenu.AttackButton'

     Begin Object Class=GUIButton Name=DefenseButton
         Caption="+"
         WinTop=0.447448
         WinLeft=0.737500
         WinWidth=0.040000
         OnClick=RPGStatsMenu.StatPlusClick
         OnKeyEvent=DefenseButton.InternalOnKeyEvent
     End Object
     Controls(13)=GUIButton'fps.RPGStatsMenu.DefenseButton'

     Begin Object Class=GUIButton Name=AmmoMaxButton
         Caption="+"
         StyleName="MyButton"
         WinTop=0.570000
         WinLeft=0.440000
         WinWidth=0.040000
         bBoundToParent=True
         bScaleToParent=True
         OnClick=RPGStatsMenu.StatPlusClick
         OnKeyEvent=AmmoMaxButton.InternalOnKeyEvent
     End Object
     Controls(14)=GUIButton'fps.RPGStatsMenu.AmmoMaxButton'

     Begin Object Class=AeListBox Name=AbilityList
         bVisibleWhenEmpty=True
         OnCreateComponent=AbilityList.InternalOnCreateComponent
         StyleName="AbilityList"
         Hint="available abilities"
         WinTop=0.239000
         WinLeft=0.501500
         WinWidth=0.600000
         WinHeight=0.330000
         bBoundToParent=True
         bScaleToParent=True
         OnClick=RPGStatsMenu.UpdateAbilityButtons
     End Object
     Controls(15)=AeListBox'fps.RPGStatsMenu.AbilityList'

     Begin Object Class=GUIButton Name=AbilityBuyButton
         Caption="Buy"
         StyleName="MyButton"
         WinTop=0.570000
         WinLeft=0.853000
         WinWidth=0.100000
         bBoundToParent=True
         bScaleToParent=True
         OnClick=RPGStatsMenu.BuyAbility
         OnKeyEvent=AbilityBuyButton.InternalOnKeyEvent
     End Object
     Controls(16)=GUIButton'fps.RPGStatsMenu.AbilityBuyButton'

     Begin Object Class=AemoNum Name=WeaponSpeedAmt
         Value="5"
         WinTop=0.270000
         WinLeft=0.357500
         WinWidth=0.080000
         bBoundToParent=True
         bScaleToParent=True
         OnDeActivate=WeaponSpeedAmt.ValidateValue
     End Object
     Controls(17)=AemoNum'fps.RPGStatsMenu.WeaponSpeedAmt'

     Begin Object Class=AemoNum Name=HealthBonusAmt
         Value="5"
         WinTop=0.370000
         WinLeft=0.357500
         WinWidth=0.080000
         bBoundToParent=True
         bScaleToParent=True
         OnDeActivate=HealthBonusAmt.ValidateValue
     End Object
     Controls(18)=AemoNum'fps.RPGStatsMenu.HealthBonusAmt'

     Begin Object Class=AemoNum Name=AdrenalineMaxAmt
         Value="5"
         WinTop=0.470000
         WinLeft=0.357500
         WinWidth=0.080000
         bBoundToParent=True
         bScaleToParent=True
         OnDeActivate=AdrenalineMaxAmt.ValidateValue
     End Object
     Controls(19)=AemoNum'fps.RPGStatsMenu.AdrenalineMaxAmt'

     Begin Object Class=AemoNum Name=AttackAmt
         Value="5"
         WinTop=0.357448
         WinLeft=0.645000
         WinWidth=0.080000
         bBoundToParent=True
         bScaleToParent=True
         OnDeActivate=AttackAmt.ValidateValue
     End Object
     Controls(20)=AemoNum'fps.RPGStatsMenu.AttackAmt'

     Begin Object Class=AemoNum Name=DefenseAmt
         Value="5"
         WinTop=0.437448
         WinLeft=0.645000
         WinWidth=0.080000
         bBoundToParent=True
         bScaleToParent=True
         OnDeActivate=DefenseAmt.ValidateValue
     End Object
     Controls(21)=AemoNum'fps.RPGStatsMenu.DefenseAmt'

     Begin Object Class=AemoNum Name=MaxAmmoAmt
         Value="5"
         WinTop=0.570000
         WinLeft=0.357500
         WinWidth=0.080000
         bBoundToParent=True
         bScaleToParent=True
         OnDeActivate=MaxAmmoAmt.ValidateValue
     End Object
     Controls(22)=AemoNum'fps.RPGStatsMenu.MaxAmmoAmt'

     Begin Object Class=GUIButton Name=ResetButton
         Caption="Reset"
         StyleName="MyReset"
         WinTop=0.373000
         WinLeft=-0.154000
         WinWidth=0.263000
         WinHeight=0.057500
         bBoundToParent=True
         bScaleToParent=True
         OnClick=RPGStatsMenu.ResetClick
         OnKeyEvent=ResetButton.InternalOnKeyEvent
     End Object
     Controls(23)=GUIButton'fps.RPGStatsMenu.ResetButton'

     WinLeft=0.200000
     WinWidth=0.600000
     WinHeight=1.000000
}
