//=============================================================================
// Copyright 2011-2019 Eliot Van Uytfanghe. All Rights Reserved.
//=============================================================================
class BTGUI_Store extends MidGamePanel;

var automated GUIImage Stats;
var automated BTStore_ItemsMultiColumnListBox lb_ItemsListBox;
var automated GUIButton b_Buy; //b_Donate
var automated GUIImage i_ItemIcon;
var automated GUISectionBackground sb_ItemBackground;
var automated GUIScrollTextBox eb_ItemDescription;
var automated moComboBox cb_Filter;

var() protected editinline BTClient_ClientReplication CRI;
var protected bool bWaitingForResponse;

var private int lastSelectedItemIndex;
var private transient int ItemsNum;

event Free()
{
    CRI = none;
    super.Free();
}

function PostInitPanel()
{
    local BTClient_Config config;

    config = class'BTClient_Config'.static.FindSavedData();
    cb_Filter.INIDefault = Eval( config.StoreFilter != "", config.StoreFilter, "Other" );
}

function ShowPanel( bool bShow )
{
    super.ShowPanel( bShow );

    if( PlayerOwner().PlayerReplicationInfo != none && CRI == none )
    {
        CRI = class'BTClient_ClientReplication'.static.getCRI( PlayerOwner().PlayerReplicationInfo );
    }

    if( bShow && CRI != none )
    {
        BTStore_ItemsMultiColumnList(lb_ItemsListBox.List).CRI = CRI;
        LoadData();
    }
}

protected function LoadData()
{
    local string storeFilter;

    // No need to request the items for this category, because we've got it cached!
    storeFilter = class'BTClient_Config'.static.FindSavedData().StoreFilter;
    if( LoadCachedCategory( storeFilter ) )
    {
        ItemsNum = CRI.Items.Length;
        BTStore_ItemsMultiColumnList(lb_ItemsListBox.List).UpdateList();
        return;
    }

    if( !bWaitingForResponse && PlayerOwner().Level.TimeSeconds > 5 )
    {
        ItemsNum = CRI.Items.Length;
        CRI.Items.Length = 0;

        bWaitingForResponse = true;
        PlayerOwner().ConsoleCommand( "Mutate BTClient_RequestStoreItems" @ Eval( cb_Filter.GetText() != "", cb_Filter.GetText(), storeFilter ) );

        DisableComponent( cb_Filter );
        SetTimer( 0.2, true );
    }
}

protected function LoadComplete()
{
    local int i;

    // Try again?
    if( CRI.Categories.Length == 0 )
    {
        CRI.bReceivedCategories = false;
    }

    if( !CRI.bReceivedCategories && CRI.Categories.Length > 0 )
    {
        for( i = CRI.Categories.Length-1; i >= 0; -- i )
        {
            cb_Filter.AddItem( CRI.Categories[i].Name );
        }
        cb_Filter.MyComboBox.List.OnChange = FilterChanged;
        i = cb_Filter.FindIndex( class'BTClient_Config'.static.FindSavedData().StoreFilter );
        if( i != -1 )
        {
            cb_Filter.SetIndex( i );
        }
        else
        {
            cb_Filter.SetIndex( 0 );
        }
        CRI.bReceivedCategories = true;
    }
    BTStore_ItemsMultiColumnList(lb_ItemsListBox.List).UpdateList();

    EnableComponent( cb_Filter );
}

event Timer()
{
    if( CRI.bItemsTransferComplete )
    {
        CRI.bItemsTransferComplete = false;
        LoadComplete();
        SetTimer( 0.0, false );
        bWaitingForResponse = false;
    }
}

function InitComponent( GUIController MyController, GUIComponent MyOwner )
{
    super.InitComponent( MyController, MyOwner );
    lb_ItemsListBox.ContextMenu.OnSelect = InternalOnSelect;
    lb_ItemsListBox.List.OnDblClick = InternalOnDblClick;
}

function bool InternalOnDblClick( GUIComponent sender )
{
    return BuySelectedItem();
}

function InternalOnSelect( GUIContextMenu sender, int clickIndex )
{
    switch( clickIndex )
    {
        case 0:
            BuySelectedItem();
            break;
    }
}

private function bool BuySelectedItem()
{
    local int i;

    i = lb_ItemsListBox.List.CurrentListId();
    if( i != -1 )
    {
        if( !PlayerOwner().PlayerReplicationInfo.bAdmin )
        {
            // 2 = Admin, 4 = Private
            if( CRI.Items[i].Access == 2 || CRI.Items[i].Access == 4 )
            {
                if( PlayerOwner().Level.NetMode == NM_Client )
                {
                    Log( "Attempt to donate for an item in progress!" );
                    BuyItemOnline( Repl( CRI.Items[i].Name, " ", "_" ), CRI.Items[i].ID );
                    return false;
                }
            }
            else if( CRI.Items[i].Cost > CRI.BTPoints )
                return false;
        }

        PlayerOwner().ConsoleCommand( "Store Buy" @ CRI.Items[i].ID );
        return true;
    }
    return false;
}

function bool InternalOnClick( GUIComponent Sender )
{
    if( Sender == b_Buy )
    {
        return BuySelectedItem();
    }
    /*
    else if( Sender == b_Donate )
    {
        BuyItemOnline( "ItemDonation", "ItemRequest" );
        return true;
    }
    */
}

private function BuyItemOnline( string itemName, string itemID )
{
    if( !PlatformIs64Bit() )
    {
        PlayerOwner().ConsoleCommand( "Minimize" );
        PlayerOwner().ConsoleCommand( "open https://www.paypal.com/paypalme2/KingCrushYT" );
    }
    else
    {
        PlayerOwner().ConsoleCommand( "open https://www.paypal.com/paypalme2/KingCrushYT" );
        PlayerOwner().ClientMessage( "Please use CTRL+V in your browser URL bar to donate!" );
    }
}

function bool InternalOnDraw( Canvas C )
{
    local int i;

    i = lb_ItemsListBox.List.CurrentListId();
    if( i == -1 )
        return true;

    if( i > CRI.Items.Length-1 )
        return true;

    // Update the list length dynamically
    if( CRI.Items.Length != ItemsNum )
    {
        ItemsNum = CRI.Items.Length;
        BTStore_ItemsMultiColumnList(lb_ItemsListBox.List).UpdateList();
        return true;
    }

    if( i != lastSelectedItemIndex || lastSelectedItemIndex == -1 )
    {
        if( !CRI.Items[i].bHasMeta && !bWaitingForResponse )
        {
            //Log( "Requesting item meta data for:" @ CRI.Items[i].ID );
            PlayerOwner().ConsoleCommand( "Mutate BTClient_RequestStoreItemMeta" @ CRI.Items[i].ID );
        }
        lastSelectedItemIndex = i;

        if( CRI.Items[i].bHasMeta )
        {
            UpdateItemDescription( i );
        }
    }

    C.SetPos( i_ItemIcon.ActualLeft(), i_ItemIcon.ActualTop()-16 );
    C.DrawColor = class'HUD'.default.WhiteColor;
    C.Font = C.SmallFont;
    C.Style = 3;
    C.DrawText( CRI.Items[i].ID );

    if( CRI.Items[i].IconTexture != none )
    {
        C.SetPos( i_ItemIcon.ActualLeft(), i_ItemIcon.ActualTop() );
        C.Style = 5;
        C.DrawTileJustified( CRI.Items[i].IconTexture, 1, i_ItemIcon.ActualWidth(), i_ItemIcon.ActualHeight() );
    }

    if( CRI.Items[i].bSync )
    {
        CRI.Items[i].bSync = false;
        UpdateItemDescription( i );
    }
    return true;
}

protected function UpdateItemDescription( int itemIndex )
{
    eb_ItemDescription.MyScrollText.SetContent( CRI.Items[itemIndex].Desc );
    eb_ItemDescription.MyScrollBar.AlignThumb();
    eb_ItemDescription.MyScrollBar.UpdateGripPosition( 0 );
}

function FilterChanged( GUIComponent sender )
{
    local BTClient_Config options;

    options = class'BTClient_Config'.static.FindSavedData();
    cb_Filter.MyComboBox.ItemChanged( sender );
    CacheCategory( options.StoreFilter );
    options.StoreFilter = cb_Filter.GetText();
    options.SaveConfig();
    LoadData();
}

private function CacheCategory( string categoryName )
{
    local int i;

    for( i = 0; i < CRI.Categories.Length; ++ i )
    {
        if( CRI.Categories[i].Name ~= categoryName )
        {
            CRI.Categories[i].CachedItems = CRI.Items;
            break;
        }
    }
}

private function bool LoadCachedCategory( string categoryName )
{
    local int i;

    for( i = 0; i < CRI.Categories.Length; ++ i )
    {
        if( CRI.Categories[i].Name ~= categoryName )
        {
            if( CRI.Categories[i].CachedItems.Length == 0 )
                return false;

            CRI.Items = CRI.Categories[i].CachedItems;
            return true;
        }
    }
    return false;
}

defaultproperties
{
     Begin Object Class=GUIImage Name=oStats
         ImageColor=(A=128)
         ImageStyle=ISTY_Stretched
         WinTop=0.010000
         WinWidth=0.700000
         WinHeight=0.025000
         bBoundToParent=True
         bScaleToParent=True
     End Object
     Stats=GUIImage'BTGUI_Store.oStats'

     Begin Object Class=BTStore_ItemsMultiColumnListBox Name=oItemsListBox
         bVisibleWhenEmpty=True
         OnCreateComponent=oItemsListBox.InternalOnCreateComponent
         WinTop=0.010000
         WinWidth=0.700000
         WinHeight=0.940000
         bBoundToParent=True
         bScaleToParent=True
     End Object
     lb_ItemsListBox=BTStore_ItemsMultiColumnListBox'BTGUI_Store.oItemsListBox'

     Begin Object Class=GUIButton Name=oBuy
         Caption="Buy"
         Hint="Buy the selected item"
         WinTop=0.875000
         WinLeft=0.800000
         WinWidth=0.120000
         WinHeight=0.080000
         OnClick=BTGUI_Store.InternalOnClick
         OnKeyEvent=oBuy.InternalOnKeyEvent
     End Object
     b_Buy=GUIButton'BTGUI_Store.oBuy'

     Begin Object Class=GUIImage Name=oItemImage
         ImageColor=(A=128)
         ImageStyle=ISTY_Stretched
         WinTop=0.120000
         WinLeft=0.730000
         WinWidth=0.250000
         WinHeight=0.250000
         bBoundToParent=True
         bScaleToParent=True
         OnDraw=BTGUI_Store.InternalOnDraw
     End Object
     i_ItemIcon=GUIImage'BTGUI_Store.oItemImage'

     Begin Object Class=GUISectionBackground Name=Render
         HeaderBase=Texture'2K4Menus.NewControls.Display99'
         Caption="Item Details"
         WinTop=0.060000
         WinLeft=0.710000
         WinWidth=0.290000
         WinHeight=0.790000
         OnPreDraw=Render.InternalPreDraw
     End Object
     sb_ItemBackground=GUISectionBackground'BTGUI_Store.Render'

     Begin Object Class=GUIScrollTextBox Name=Desc
         bNoTeletype=True
         bVisibleWhenEmpty=True
         OnCreateComponent=Desc.InternalOnCreateComponent
         WinTop=0.380000
         WinLeft=0.725000
         WinWidth=0.260000
         WinHeight=0.415000
         bBoundToParent=True
         bScaleToParent=True
     End Object
     eb_ItemDescription=GUIScrollTextBox'BTGUI_Store.Desc'

     Begin Object Class=moComboBox Name=oFilter
         bReadOnly=True
         ComponentJustification=TXTA_Left
         CaptionWidth=0.250000
         Caption="Filter"
         OnCreateComponent=oFilter.InternalOnCreateComponent
         IniDefault="Other"
         Hint="Filter items list by category"
         WinTop=0.010000
         WinLeft=0.710000
         WinWidth=0.290000
         WinHeight=0.080000
     End Object
     cb_Filter=moComboBox'BTGUI_Store.oFilter'

     lastSelectedItemIndex=-1
     WinTop=0.100000
     WinLeft=0.100000
     WinWidth=0.600000
     WinHeight=1.000000
}
