class RPGBuyClassPage extends GUIPage;

var GiveItemsInv GiveItems;
var RPGStatsInv StatsInv;

var GUIListBox Classes;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	Super.InitComponent(MyController, MyOwner);
	Classes = GUIListBox(Controls[3]);

	OnClose=MyOnClose;
}

function InitFor()
{
	local int x, Cost;
	local RPGPlayerDataObject TempDataObject;

	Controls[1].MenuStateChange(MSAT_Disabled);

	Classes.List.Clear();

	if (GiveItems == None || StatsInv == None)
		return;

	for (x = 0; x < StatsInv.Data.Abilities.length; x++)
		if (ClassIsChildOf(StatsInv.Data.Abilities[x], class'RPGClass'))
			return;

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
		if (ClassIsChildOf(StatsInv.AllAbilities[x], class'RPGClass'))
		{	
			Cost = StatsInv.AllAbilities[x].static.Cost(TempDataObject, 0);

			if (Cost <= 0)
				Classes.List.Add(StatsInv.AllAbilities[x].default.AbilityName@"("$class'RPGStatsMenuX'.default.CantBuyText$")", StatsInv.AllAbilities[x], string(Cost));
			else
				Classes.List.Add(StatsInv.AllAbilities[x].default.AbilityName@"("$class'RPGStatsMenuX'.default.CostText@Cost$")", StatsInv.AllAbilities[x], string(Cost));
		}
	}

	if (StatsInv.Role < ROLE_Authority)
	{
		StatsInv.Level.ObjectPool.FreeObject(TempDataObject);
	}
}

function bool UpdateClassButtons(GUIComponent Sender)
{
	local int Cost;

	Cost = int(Classes.List.GetExtra());
	if (Cost <= 0 || Cost > StatsInv.Data.PointsAvailable)
		Controls[1].MenuStateChange(MSAT_Disabled);
	else
		Controls[1].MenuStateChange(MSAT_Blurry);

	return true;
}

function bool BuyClass(GUIComponent Sender)
{
	local GUIController OldController;

	Controls[1].MenuStateChange(MSAT_Disabled);
	
	OldController = Controller;	
	GiveItems.AbilityConfigs.Length = 0;
	GiveItems.InitializedAbilities = False;

	StatsInv.ServerAddAbility(class<RPGAbility>(Classes.List.GetObject()));
	Controller.CloseMenu(false);
	OldController.CloseMenu(false);
	
	return true;
}

function bool CloseClick(GUIComponent Sender)
{
	Controller.CloseMenu(false);

	return true;
}


function MyOnClose(optional bool bCanceled)
{
	StatsInv = None;
	GiveItems = None;

	Super.OnClose(bCanceled);
}

defaultproperties
{
     bRenderWorld=True
     bRequire640x480=False
     Begin Object Class=GUIButton Name=QuitBackground
         WinHeight=1.000000
         bBoundToParent=True
         bScaleToParent=True
         bAcceptsInput=False
         bNeverFocus=True
         OnKeyEvent=QuitBackground.InternalOnKeyEvent
     End Object
     Controls(0)=GUIButton'fps.RPGBuyClassPage.QuitBackground'

     Begin Object Class=GUIButton Name=ClassBuyButton
         Caption="Buy"
         WinTop=0.850000
         WinLeft=0.350000
         WinWidth=0.250000
         bBoundToParent=True
         bScaleToParent=True
         OnClick=RPGBuyClassPage.BuyClass
         OnKeyEvent=ClassBuyButton.InternalOnKeyEvent
     End Object
     Controls(1)=GUIButton'fps.RPGBuyClassPage.ClassBuyButton'

     Begin Object Class=GUIButton Name=CloseButton
         Caption="Close"
         WinTop=0.850000
         WinLeft=0.700000
         WinWidth=0.250000
         bBoundToParent=True
         bScaleToParent=True
         OnClick=RPGBuyClassPage.CloseClick
         OnKeyEvent=CloseButton.InternalOnKeyEvent
     End Object
     Controls(2)=GUIButton'fps.RPGBuyClassPage.CloseButton'

     Begin Object Class=GUIListBox Name=ClassList
         bVisibleWhenEmpty=True
         OnCreateComponent=ClassList.InternalOnCreateComponent
         StyleName="AbilityList"
         Hint="These are the classes you can purchase."
         WinTop=0.250000
         WinLeft=0.200000
         WinWidth=0.600000
         WinHeight=0.500000
         bBoundToParent=True
         bScaleToParent=True
         OnClick=RPGBuyClassPage.UpdateClassButtons
     End Object
     Controls(3)=GUIListBox'fps.RPGBuyClassPage.ClassList'

     Begin Object Class=GUILabel Name=SelectText
         Caption="Choose a class:"
         TextAlign=TXTA_Center
         TextColor=(B=0,G=180,R=220)
         TextFont="UT2HeaderFont"
         WinTop=0.100000
         WinHeight=0.100000
         bBoundToParent=True
         bScaleToParent=True
     End Object
     Controls(4)=GUILabel'fps.RPGBuyClassPage.SelectText'

     WinTop=0.150000
     WinLeft=0.200000
     WinWidth=0.600000
     WinHeight=0.700000
}
