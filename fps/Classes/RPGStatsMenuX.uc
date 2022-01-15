class RPGStatsMenuX extends RPGStatsMenu
	DependsOn(RPGStatsInv);

var GiveItemsInv GiveItems;
var class<RPGClass> curClass;
var int curLevel, curSubClasslevel;
var string sNone, curSubClass, DisplaySubClass;
var bool bAbilityTimer;

//AUD stuff
var AemoBox CreditBox;
var AeListBox StoreItem;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	Super.InitComponent(MyController, MyOwner);

	CreditBox = AemoBox(Controls[31]);
	StoreItem = AeListBox(Controls[32]);
	StoreItem.MyScrollBar.WinWidth = 0.01;

//controls
	Controls[0].Show();	//background
	Controls[1].Show();	//close
	Controls[2].Show();	//fire-rate
	Controls[3].Show();	//health
	Controls[4].Show();	//adren
	Controls[5].Hide();	//db
	Controls[6].Hide();	//dr
	Controls[7].Show();	//ammo
	Controls[8].Show();	//AP
	Controls[9].Show();	//+ firerate
	Controls[10].Show();	//+ health
	Controls[11].Show();	//+ adren
	Controls[12].Hide();	//+ db
	Controls[13].Hide();	//+ dr
	Controls[14].Show();	//+ ammo
	Controls[15].Show();	//abilitylist
	Controls[16].Show();	//buy
	Controls[17].Show();	//5 firerate
	Controls[18].Show();	//5 health
	Controls[19].Show();	//5 adren
	Controls[20].Hide();	//5 db
	Controls[21].Hide();	//5 dr
	Controls[22].Show();	//5 ammo
	Controls[23].Show();	//reset
	Controls[24].Show();	//sell
	Controls[25].Show();	//class buy
	Controls[26].Show();	//mastery buy
	Controls[27].Show();	//max
	Controls[28].Show();	//desc info
	Controls[29].Show();	//home
	Controls[30].Show();	//store
}

function bool ForcedSell()
{
	if (bAbilityTimer)
	{
		bAbilityTimer = False;
		KillTimer();
	}
	Controller.OpenMenu(string(class'RPGForcedSellPage'));
	RPGForcedSellPage(Controller.TopPage()).StatsMenu = self;
	RPGForcedSellPage(Controller.TopPage()).GiveItems = GiveItems;
	return true;
}

function bool SellClick(GUIComponent Sender)
{
	if (bAbilityTimer)
	{
		bAbilityTimer = False;
		KillTimer();
	}
	Controller.OpenMenu(string(class'RPGSellConfirmPage'));
	RPGSellConfirmPage(Controller.TopPage()).StatsMenu = self;
	RPGSellConfirmPage(Controller.TopPage()).GiveItems = GiveItems;
	return true;
}

function MyOnClose(optional bool bCanceled)
{
	if (bAbilityTimer)
	{
		bAbilityTimer = False;
		KillTimer();
	}
	if (GiveItems != None)
		GiveItems = None;
	if (curClass != None)
		curClass = None;

	Super.MyOnClose(bCanceled);
}

function InitFor2(RPGStatsInv Inv, GiveItemsInv GInv)
{
	GiveItems = GInv;
	GiveItems.ClientStatsInv = Inv;
	InitFor(Inv);
}

function InitFor(RPGStatsInv Inv)
{
	local int x, y, OldAbilityListIndex, OldAbilityListTop, MinSubClassLevel;
	local bool bGotSubClass, bAllowSubClasses;
	local int s, Price, OldStoreListIndex, OldStoreListTop;

	StatsInv = Inv;
	StatsInv.StatsMenu = self;
	curSubClasslevel = -1;

	WeaponSpeedBox.SetText(string(StatsInv.Data.WeaponSpeed));
	HealthBonusBox.SetText(string(StatsInv.Data.HealthBonus));
	AdrenalineMaxBox.SetText(string(StatsInv.Data.AdrenalineMax));
	AttackBox.SetText(string(StatsInv.Data.Attack));
	DefenseBox.SetText(string(StatsInv.Data.Defense));
	AmmoMaxBox.SetText(string(StatsInv.Data.AmmoMax));
	PointsAvailableBox.SetText(string(StatsInv.Data.PointsAvailable));
	CreditBox.SetText(string(StatsInv.Credit));
	curLevel = StatsInv.Data.Level;

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

	OldAbilityListIndex = Abilities.List.Index;
	OldAbilityListTop = Abilities.List.Top;
	Abilities.List.Clear();
	if (GiveItems != None)
	{
		curClass = None;
		curSubClass = "";
		for (y = 0; y < StatsInv.Data.Abilities.length; y++)
		{
			if (ClassIsChildOf(StatsInv.Data.Abilities[y], class'RPGClass'))
			{
				curClass = class<RPGClass>(StatsInv.Data.Abilities[y]);
			}
			else if (ClassIsChildOf(StatsInv.Data.Abilities[y], class'SubClass'))
			{
				curSubClassLevel = StatsInv.Data.AbilityLevels[y];
				if (curSubClassLevel < GiveItems.SubClasses.length)
					curSubClass = GiveItems.SubClasses[curSubClassLevel];
			}
		}

		if (curClass == None)
		{
			curSubClass = sNone;
			DisplaySubClass = sNone;
			Controls[25].MenuStateChange(MSAT_Blurry);
			Controls[26].MenuStateChange(MSAT_Disabled);
		}
		else
		{
			Controls[25].MenuStateChange(MSAT_Disabled);
			if (curSubClass == "" && StatsInv.Data.Abilities.length < 2)
				Controls[26].MenuStateChange(MSAT_Blurry);
			else
				Controls[26].MenuStateChange(MSAT_Disabled);
			if (curSubClass == "")
			{
				curSubClass = curClass.default.AbilityName;
				DisplaySubClass = sNone;
			}
			else
				DisplaySubClass = curSubClass;
		}

		if (curSubClasslevel < 0)
		{
			for (y = 0; y < GiveItems.SubClasses.length; y++)
				if (GiveItems.SubClasses[y] == curSubClass)
					curSubClasslevel = y;
			if (curSubClasslevel < 0)
				curSubClassLevel = 0;
		}

		MinSubClassLevel = 200;
		for (y = 0; y < GiveItems.SubClassConfigs.length; y++)
		{
			if (GiveItems.SubClassConfigs[y].AvailableClass == curClass)
			{
				if (MinSubClassLevel > GiveItems.SubClassConfigs[x].MinLevel)
					MinSubClassLevel = GiveItems.SubClassConfigs[x].MinLevel;
			}
		}
		if (curlevel < MinSubClassLevel)
			bAllowSubClasses = false;
		else
			bAllowSubClasses = true;

		if (!bAllowSubClasses) 
		{
			Controls[24].MenuStateChange(MSAT_Disabled);
			Controls[26].MenuStateChange(MSAT_Disabled);
		}

		if (curClass != None && curSubClass != "" && curSubClass != curClass.default.AbilityName)
		{
			bGotSubClass = false;
			for (x = 0; x < GiveItems.SubClassConfigs.length; x++)
			{
				if (GiveItems.SubClassConfigs[x].AvailableClass == curClass && GiveItems.SubClassConfigs[x].AvailableSubClass == curSubClass && GiveItems.SubClassConfigs[x].MinLevel <= curLevel)
					bGotSubClass = true;
			}
			if (!bGotSubClass)
			{
				ForcedSell();
				return;
			}
		}

		if (GiveItems.AbilityConfigs.Length == 0)
		{
			GiveItems.ServerGetAbilities(curSubClasslevel);
			SetTimer(0.1, True);
			bAbilityTimer = True;
			Abilities.List.Add("Please wait - updating list from server");
		}
		else
			UpdateAbilityList();

		if (GiveItems.InitializedAbilities)
		{
			if (OldAbilityListIndex < Abilities.ItemCount())
			{
				Abilities.List.SetIndex(OldAbilityListIndex);
				Abilities.List.SetTopItem(OldAbilityListTop);
			}
			else
			{
				Abilities.List.SetIndex(1);
				Abilities.List.SetTopItem(0);
			}
			UpdateAbilityButtons(Abilities);
		}
	}

	//store feature
	OldStoreListIndex = StoreItem.List.Index;
	OldStoreListTop = StoreItem.List.Top;
	StoreItem.List.Clear();

	for (s = 0; s < StatsInv.WeaponsList.length; s++)
	{
		Price = StatsInv.WeaponCost[s];
		StoreItem.List.Add(StatsInv.WeaponsList[s].default.ItemName@" ("$CostText@Price$")",StatsInv.WeaponsList[s],string(Price));
	}

	for (s = 0; s < StatsInv.ArtifactsList.length; s++)
	{
		Price = StatsInv.ArtifactCost[s];
		StoreItem.List.Add(StatsInv.ArtifactsList[s].default.ItemName@" ("$CostText@Price$")",StatsInv.ArtifactsList[s],string(Price));
	}

	StoreItem.List.SetIndex(OldStoreListIndex);
	StoreItem.List.SetTopItem(OldStoreListTop);
	UpdateStoreButtons(StoreItem);
}

function bool BuyStoreItem(GUIComponent Sender)
{
	GetStatsInv().ServerGiveWeapon(String(Class<Weapon>(StoreItem.List.GetObject())),Int(StoreItem.List.GetExtra()));
	GetStatsInv().ServerGiveArtifact(PlayerOwner().Pawn,String(Class<RPGArtifact>(StoreItem.List.GetObject())),Int(StoreItem.List.GetExtra()));

	return true;
}

function bool UpdateStoreButtons(GUIComponent Sender)
{
	local int Price;

	Price = int(StoreItem.List.GetExtra());
	if (Price <= 0 || Price > StatsInv.Credit)
		Controls[33].MenuStateChange(MSAT_Disabled);
	else
		Controls[33].MenuStateChange(MSAT_Blurry);

	return true;
}

function UpdateAbilityList()
{
	local RPGPlayerDataObject TempDataObject;
	local int x, y, Index, Cost, Level, MaxLevel;
	local class<CostRPGAbility> cab;

	if (!GiveItems.InitializedAbilities)
		return;

	Abilities.List.Clear();

	if (StatsInv.Role < ROLE_Authority)
	{
		TempDataObject = RPGPlayerDataObject(StatsInv.Level.ObjectPool.AllocateObject(class'RPGPlayerDataObject'));
		TempDataObject.InitFromDataStruct(StatsInv.Data);
	}
	else
	{
		TempDataObject = StatsInv.DataObject;
	}

	for (x = 0; x < StatsInv.AllAbilities.length; x++)
	{
		if (!ClassIsChildOf(StatsInv.AllAbilities[x], class'RPGClass') && !ClassIsChildOf(StatsInv.AllAbilities[x], class'SubClass') && !ClassIsChildOf(StatsInv.AllAbilities[x], class'BotAbility'))
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

			MaxLevel = GiveItems.MaxCanBuy(curSubClassLevel, StatsInv.AllAbilities[x]);
			if (MaxLevel > 0 || Level > 0)
			{
				if (Level >= MaxLevel)
				{
					Cost = 0;
					Abilities.List.Add(StatsInv.AllAbilities[x].default.AbilityName@"("$CurrentLevelText@Level@"["$MaxText$"])", StatsInv.AllAbilities[x], string(Cost));
				}
				else
				{
					if (ClassIsChildOf(StatsInv.AllAbilities[x], class'CostRPGAbility'))
					{
						cab = class<CostRPGAbility>(StatsInv.AllAbilities[x]);
						Cost = cab.static.SubClassCost(TempDataObject, Level, curSubClass);
					}
					else
						Cost =StatsInv.AllAbilities[x].static.Cost(TempDataObject, Level);

					if (Cost <= 0)
						Abilities.List.Add(StatsInv.AllAbilities[x].default.AbilityName@"("$CurrentLevelText@Level$","@CantBuyText$")", StatsInv.AllAbilities[x], string(Cost));
					else
						Abilities.List.Add(StatsInv.AllAbilities[x].default.AbilityName@"("$CurrentLevelText@Level$","@CostText@Cost$")", StatsInv.AllAbilities[x], string(Cost));
				}
			}
		}
	}

	if (StatsInv.Role < ROLE_Authority)
	{
		StatsInv.Level.ObjectPool.FreeObject(TempDataObject);
	}
}

function OnTimer(GUIComponent Sender)
{
	if (!GiveItems.InitializedAbilities)
		return;

	if (bAbilityTimer)
	{
		bAbilityTimer = False;
		KillTimer();
	}

	UpdateAbilityList();
}

function bool UpdateAbilityButtons(GUIComponent Sender)
{
	local int Cost;

	Cost = int(Abilities.List.GetExtra());
	if (Cost <= 0 || Cost > StatsInv.Data.PointsAvailable)
	{
		Controls[16].MenuStateChange(MSAT_Disabled);
		Controls[27].MenuStateChange(MSAT_Disabled);
	}
	else
	{
		Controls[16].MenuStateChange(MSAT_Blurry);
		Controls[27].MenuStateChange(MSAT_Blurry);
	}
	ShowAbilityInfo();

	return true;
}

function bool ShowAbilityInfo()
{
	local class<RPGAbility> Ability;
	local GUIScrollTextBox AbilityInfo;

	Ability = class<RPGAbility>(Abilities.List.GetObject());
	if (Ability == None)
		return true;

	AbilityInfo = GUIScrollTextBox(Controls[28]);
	AbilityInfo.MyScrollBar.WinWidth = 0.01;
	AbilityInfo.SetContent(Ability.default.Description);

	return true;
}

function bool ClassBuyClick(GUIComponent Sender)
{
	if (curClass != None)
		return false;

	DisablePlusButtons();
	Controls[16].MenuStateChange(MSAT_Disabled);
	Controls[25].MenuStateChange(MSAT_Disabled);
	Controls[26].MenuStateChange(MSAT_Disabled);

	if (bAbilityTimer)
	{
		bAbilityTimer = False;
		KillTimer();
	}
	Controller.OpenMenu(string(class'RPGBuyClassPage'));
	RPGBuyClassPage(Controller.TopPage()).StatsInv = StatsInv;
	RPGBuyClassPage(Controller.TopPage()).GiveItems = GiveItems;
	RPGBuyClassPage(Controller.TopPage()).InitFor();

	return true;
}

function bool SubClassBuyClick(GUIComponent Sender)
{
	DisablePlusButtons();
	Controls[16].MenuStateChange(MSAT_Disabled);
	Controls[25].MenuStateChange(MSAT_Disabled);
	Controls[26].MenuStateChange(MSAT_Disabled);

	if (bAbilityTimer)
	{
		bAbilityTimer = False;
		KillTimer();
	}
	Controller.OpenMenu(string(class'RPGBuySubClassPage'));
	RPGBuySubClassPage(Controller.TopPage()).StatsInv = StatsInv;
	RPGBuySubClassPage(Controller.TopPage()).GiveItems = GiveItems;
	RPGBuySubClassPage(Controller.TopPage()).curLevel = curLevel;
	RPGBuySubClassPage(Controller.TopPage()).InitFor(curClass);

	return true;
}

function bool ShowAbilityDesc(GUIComponent Sender)
{
	local class<RPGAbility> Ability;
	local int Maxl;
	local string classtext;

	Ability = class<RPGAbility>(Abilities.List.GetObject());
	if (Ability == None)
		return true;

	Controller.OpenMenu(string(class'RPGAbilityDescMenuX'));
	RPGAbilityDescMenuX(Controller.TopPage()).t_WindowTitle.Caption = Ability.default.AbilityName;
	RPGAbilityDescMenuX(Controller.TopPage()).MyScrollText.SetContent(Ability.default.Description);

	if (GiveItems != None)
	{
		MaxL = GiveItems.MaxCanBuy(curSubClassLevel, Ability);
	}
	if (curClass == None)
		classtext = "Class: None";
	else
		classtext = curClass.default.AbilityName;
	RPGAbilityDescMenuX(Controller.TopPage()).MaxText.SetContent("Max Level for" @ classtext @ "SubClass:" @ DisplaySubClass @ "is" @ string(MaxL));

	return true;
}

function bool MaxAbility(GUIComponent Sender)
{
	local int CurL, MaxL, y;
	local class<RPGAbility> Ability;

	Ability = class<RPGAbility>(Abilities.List.GetObject());
	if (Ability == None)
		return true;

	if (GiveItems != None)
		MaxL = GiveItems.MaxCanBuy(curSubClassLevel, Ability);

	CurL = 0;
	for (y = 0; y < StatsInv.Data.Abilities.length; y++)
	{
		if (Ability == StatsInv.Data.Abilities[y])
		{
			CurL = StatsInv.Data.AbilityLevels[y];
			y = StatsInv.Data.Abilities.length;
		}
	}

	DisablePlusButtons();
	Controls[16].MenuStateChange(MSAT_Disabled);

	for (y = CurL; y < MaxL; y++)
		StatsInv.ServerAddAbility(Ability);

	return true;
}

function bool HomeClick(GUIComponent Sender)
{
	Controls[0].Show();	//background
	Controls[1].Show();	//close
	Controls[2].Show();	//fire-rate
	Controls[3].Show();	//health
	Controls[4].Show();	//adren
	Controls[5].Hide();	//db
	Controls[6].Hide();	//dr
	Controls[7].Show();	//ammo
	Controls[8].Show();	//AP
	Controls[9].Show();	//+ firerate
	Controls[10].Show();	//+ health
	Controls[11].Show();	//+ adren
	Controls[12].Hide();	//+ db
	Controls[13].Hide();	//+ dr
	Controls[14].Show();	//+ ammo
	Controls[15].Show();	//abilitylist
	Controls[16].Show();	//buy
	Controls[17].Show();	//5 firerate
	Controls[18].Show();	//5 health
	Controls[19].Show();	//5 adren
	Controls[20].Hide();	//5 db
	Controls[21].Hide();	//5 dr
	Controls[22].Show();	//5 ammo
	Controls[23].Show();	//reset
	Controls[24].Show();	//sell
	Controls[25].Show();	//class buy
	Controls[26].Show();	//mastery buy
	Controls[27].Show();	//max
	Controls[28].Show();	//desc info
	Controls[29].Show();	//home
	Controls[30].Show();	//store

	InitFor(StatsInv);
	return true;
}

function bool StoreClick(GUIComponent Sender)
{
	Controls[0].Show();	//background
	Controls[1].Show();	//close
	Controls[2].Hide();	//fire-rate
	Controls[3].Hide();	//health
	Controls[4].Hide();	//adren
	Controls[5].Hide();	//db
	Controls[6].Hide();	//dr
	Controls[7].Hide();	//ammo
	Controls[8].Hide();	//AP
	Controls[9].Hide();	//+ firerate
	Controls[10].Hide();	//+ health
	Controls[11].Hide();	//+ adren
	Controls[12].Hide();	//+ db
	Controls[13].Hide();	//+ dr
	Controls[14].Hide();	//+ ammo
	Controls[15].Hide();	//abilitylist
	Controls[16].Hide();	//buy
	Controls[17].Hide();	//5 firerate
	Controls[18].Hide();	//5 health
	Controls[19].Hide();	//5 adren
	Controls[20].Hide();	//5 db
	Controls[21].Hide();	//5 dr
	Controls[22].Hide();	//5 ammo
	Controls[23].Show();	//reset
	Controls[24].Hide();	//sell
	Controls[25].Hide();	//class buy
	Controls[26].Hide();	//mastery buy
	Controls[27].Hide();	//max
	Controls[28].Hide();	//desc info
	Controls[29].Show();	//home
	Controls[30].Show();	//store

	InitFor(StatsInv);
	return true;
}

defaultproperties
{
     sNone="None"
     OnClose=RPGStatsMenuX.MyOnClose
     Begin Object Class=GUIButton Name=SellButton
         Caption="Sell"
         StyleName="MyButton"
         WinTop=0.570000
         WinLeft=0.752000
         WinWidth=0.100000
         bBoundToParent=True
         bScaleToParent=True
         OnClick=RPGStatsMenuX.SellClick
         OnKeyEvent=SellButton.InternalOnKeyEvent
     End Object
     Controls(24)=GUIButton'fps.RPGStatsMenuX.SellButton'

     Begin Object Class=GUIButton Name=ClassBuyButton
         Caption="Class"
         StyleName="MyButton"
         WinTop=0.570000
         WinLeft=0.550000
         WinWidth=0.100000
         bBoundToParent=True
         bScaleToParent=True
         OnClick=RPGStatsMenuX.ClassBuyClick
         OnKeyEvent=ClassBuyButton.InternalOnKeyEvent
     End Object
     Controls(25)=GUIButton'fps.RPGStatsMenuX.ClassBuyButton'

     Begin Object Class=GUIButton Name=SubClassBuyButton
         Caption="Mastery"
         StyleName="MyButton"
         WinTop=0.570000
         WinLeft=0.651000
         WinWidth=0.100000
         bBoundToParent=True
         bScaleToParent=True
         OnClick=RPGStatsMenuX.SubClassBuyClick
         OnKeyEvent=SubClassBuyButton.InternalOnKeyEvent
     End Object
     Controls(26)=GUIButton'fps.RPGStatsMenuX.SubClassBuyButton'

     Begin Object Class=GUIButton Name=AbilityMaxButton
         Caption="Max"
         StyleName="MyButton"
         WinTop=0.570000
         WinLeft=0.954000
         WinWidth=0.100000
         bBoundToParent=True
         bScaleToParent=True
         OnClick=RPGStatsMenuX.MaxAbility
         OnKeyEvent=AbilityBuyButton.InternalOnKeyEvent
     End Object
     Controls(27)=GUIButton'fps.RPGStatsMenuX.AbilityMaxButton'

     Begin Object Class=GUIScrollTextBox Name=DescInfo
         CharDelay=0.002500
         EOLDelay=0.002500
         OnCreateComponent=DescInfo.InternalOnCreateComponent
         StyleName="AbilityList"
         WinTop=0.627000
         WinLeft=0.163000
         WinWidth=0.938500
         WinHeight=0.223000
         bBoundToParent=True
         bScaleToParent=True
         bNeverFocus=True
     End Object
     Controls(28)=GUIScrollTextBox'fps.RPGStatsMenuX.DescInfo'

     Begin Object Class=GUIButton Name=HomeButton
         Caption="Home"
         StyleName="MyHome"
         WinTop=0.258000
         WinLeft=-0.154000
         WinWidth=0.263000
         WinHeight=0.058000
         bBoundToParent=True
         bScaleToParent=True
         OnClick=RPGStatsMenuX.HomeClick
         OnKeyEvent=HomeButton.InternalOnKeyEvent
     End Object
     Controls(29)=GUIButton'fps.RPGStatsMenuX.HomeButton'

     Begin Object Class=GUIButton Name=StoreButton
         Caption="Store"
         StyleName="MyStore"
         WinTop=0.316000
         WinLeft=-0.154000
         WinWidth=0.263000
         WinHeight=0.057000
         bBoundToParent=True
         bScaleToParent=True
         OnClick=RPGStatsMenuX.StoreClick
         OnKeyEvent=StoreButton.InternalOnKeyEvent
     End Object
     Controls(30)=GUIButton'fps.RPGStatsMenuX.StoreButton'

     Begin Object Class=AemoBox Name=CreditSelect
         CaptionWidth=0.775000
         Caption="Credits"
         OnCreateComponent=CreditSelect.InternalOnCreateComponent
         IniOption="@INTERNAL"
         WinTop=0.150000
         WinLeft=0.457000
         WinWidth=0.350000
         WinHeight=0.040000
         bBoundToParent=True
         bScaleToParent=True
     End Object
     Controls(31)=AemoBox'fps.RPGStatsMenuX.CreditSelect'

     Begin Object Class=AeListBox Name=StoreListBox
         bVisibleWhenEmpty=True
         OnCreateComponent=StoreListBox.InternalOnCreateComponent
         StyleName="AbilityList"
         Hint="available items"
         WinTop=0.239000
         WinLeft=0.501500
         WinWidth=0.600000
         WinHeight=0.330000
         bBoundToParent=True
         bScaleToParent=True
         OnClick=RPGStatsMenuX.UpdateStoreButtons
     End Object
     Controls(32)=AeListBox'fps.RPGStatsMenuX.StoreListBox'

     Begin Object Class=GUIButton Name=StoreBuyButton
         Caption="Buy"
         StyleName="MyButton"
         WinTop=0.750000
         WinLeft=0.746000
         WinWidth=0.275000
         WinHeight=0.060000
         bBoundToParent=True
         bScaleToParent=True
         OnClick=RPGStatsMenuX.BuyStoreItem
         OnKeyEvent=StoreBuyButton.InternalOnKeyEvent
     End Object
     Controls(33)=GUIButton'fps.RPGStatsMenuX.StoreBuyButton'
}
