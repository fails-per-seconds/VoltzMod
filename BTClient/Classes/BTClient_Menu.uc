class BTClient_Menu extends MidGamePanel
	config(ClientBTimes);

var automated GUITabControl c_Tabs;

struct sBTTab
{
	var() string Caption;
	var() class<BTGUI_TabBase> TabClass;
	var() string Hint;
	var() GUIStyles Style;
};

var protected array<sBTTab> BTTabs;

event Free()
{
	local int i;

	for(i = 0; i < BTTabs.Length; ++i)
	{
		BTTabs[i].Style = none;
	}
	Super.Free();
}

function InternalOnChange( GUIComponent sender );

function PostInitPanel()
{
	local int i;
	local BTGUI_TabBase tab;

	for(i = 0; i < BTTabs.Length; ++i)
	{
		tab = BTGUI_TabBase(c_Tabs.AddTab(BTTabs[i].Caption, string(BTTabs[i].TabClass),, BTTabs[i].Hint, true));
		tab.PostInitPanel();
	}
}

defaultproperties
{
     Begin Object Class=GUITabControl Name=oPageTabs
         bDockPanels=True
         bFillBackground=True
         TabHeight=0.040000
         BackgroundStyleName="TabBackground"
         BackgroundImage=FinalBlend'AW-2004Particles.Energy.BeamHitFinal'
         WinTop=0.010000
         WinLeft=0.010000
         WinWidth=0.980000
         WinHeight=0.050000
         bAcceptsInput=True
         OnActivate=oPageTabs.InternalOnActivate
         OnChange=BTClient_Menu.InternalOnChange
     End Object
     c_Tabs=GUITabControl'BTClient_Menu.oPageTabs'

     //BTTabs(0)=(Caption="Settings",TabClass=Class'BTGUI_Settings',Hint="Edit your BestTimes settings!")
     BTTabs(0)=(Caption="Trophies",TabClass=Class'BTGUI_Trophies',Hint="Claim your trophies!")
     BTTabs(1)=(Caption="Achievements",TabClass=Class'BTGUI_Achievements',Hint="View your achievements!")
     BTTabs(2)=(Caption="Inventory",TabClass=Class'BTGUI_PlayerInventory',Hint="Manage your items")
     WinTop=0.100000
     WinLeft=0.100000
     WinWidth=0.600000
     WinHeight=1.000000
}
