class BTGUI_PlayerInventory extends BTGUI_StatsTab
	dependson(BTClient_ClientReplication);

var() const Texture TileMat;
var() const Texture FooterTexture;
var() const Texture CheckedTexture, UnCheckedTexture;

var automated GUITreeListBox            CategoriesListBox;
var automated GUISectionBackground      ItemsBackground, CategoriesBackground;
var automated BTGUI_PlayerItemsListBox  ItemsListBox;
var GUIContextMenu                      ItemsContextMenu;

var automated AltSectionBackground          PreviewBackground;
var automated BTGUI_PawnPreviewComponent    PawnPreview;

var() const Color RarityColor[7];
var() const name RarityTitle[7];

var automated GUIButton b_ActivateKey, b_ColorDialog;
var automated GUIEditBox eb_Key;

function InitComponent( GUIController InController, GUIComponent InOwner )
{
    super.InitComponent( InController, InOwner );
    ItemsListBox.List.OnDrawItem = InternalOnDrawItem;
    ItemsListBox.List.OnRightClick = InternalOnListRightClick;
    ItemsListBox.List.OnDblClick = InternalOnListDblClick;
    ItemsListBox.List.OnChange = InternalOnListChange;
    ItemsListBox.List.bAllowEmptyItems = true;
    ItemsListBox.ContextMenu.OnSelect = InternalOnSelect;
}

function ShowPanel( bool bShow )
{
    super.ShowPanel( bShow );

    if (bShow) {
        PawnPreview.InitPawn3D();
        if (CRI != none && CRI.PlayerItems.Length == 0)
        {
            CRI.OnPlayerItemReceived = InternalOnPlayerItemReceived;
            CRI.ServerRequestPlayerItems();

            CRI.OnPlayerItemRemoved = InternalOnPlayerItemRemoved;
            CRI.OnPlayerItemUpdated = InternalOnPlayerItemUpdated;
        }
    }
    else {
        PawnPreview.DestroyPawn3D();
    }
}

function InternalOnPlayerItemReceived( int index )
{
    // itemChecked is just a placeholder otherwise the list won't accept our item.
    ItemsListBox.List.Add( Texture'itemChecked', index, 0 );
}

// Assuming the list represents that exact order of CRI.PlayerItems
function InternalOnPlayerItemRemoved( int index )
{
    local int i;

    ItemsListBox.List.Remove( index );
    for( i = index; i < ItemsListBox.List.Elements.Length; ++ i )
    {
        -- ItemsListBox.List.Elements[i].Item;
    }
}

function InternalOnPlayerItemUpdated( int index )
{
}

function InternalOnDrawItem( Canvas C, int Item, float X, float Y, float W, float H, bool bSelected, bool bPending )
{
    local BTClient_ClientReplication.sPlayerItemClient playerItem;
    local float XL, YL;
    local GUIVertImageList list;
    local float iconSize;
    local float oldClipX, oldClipY;
    local float footerHeight;
    local Texture stateTex;

    list = ItemsListBox.List;
    X += int((float(Item - list.Top)%float(list.NoVisibleCols)))*(w+list.HorzBorder);
    Y += int(((float(Item - list.Top)/float(list.NoVisibleCols)%float(list.NoVisibleRows))))*(h+list.VertBorder);
    w -= list.HorzBorder*list.NoVisibleCols;
    h -= list.VertBorder*list.VertBorder;
    playerItem = CRI.PlayerItems[Item];

    oldClipX = C.ClipX;
    oldClipY = C.ClipY;
    C.ClipX = X + W;
    C.ClipY = Y + H;
    C.Font = Font'UT2003Fonts.jFontSmallText800x600';
    C.Style = 1;

    C.StrLen( "T", XL, YL );
    footerHeight = YL*2 + 8*2;

    // RENDER: Background
    C.DrawColor = #0xEEEEEE88;
    C.OrgX = int(X);
    C.OrgY = int(Y);
    C.SetPos( 0, 0 );
    C.DrawTileClipped( TileMat, int(w), int(h) - footerHeight, 0, 0, TileMat.MaterialUSize(), TileMat.MaterialVSize() );

    // RENDER: Icon
    if( playerItem.IconTexture != none )
    {
        C.DrawColor = class'HUD'.default.WhiteColor;
        iconSize = h - 16 - footerHeight;
        C.OrgX = X;
        C.OrgY = Y;
        C.SetPos( w*0.5 - iconSize*0.5 + 2, 12 );
        C.DrawTileClipped( playerItem.IconTexture, iconSize - 8, iconSize - 8, 0.0, 0.0, playerItem.IconTexture.MaterialUSize(), playerItem.IconTexture.MaterialVSize() );
        C.OrgX = X;
        C.OrgY = Y;
        C.ClipX = W;
    }

    if( playerItem.bEnabled )
    {
        stateTex = CheckedTexture;
    }
    else
    {
        stateTex = UnCheckedTexture;
    }

    C.SetPos( w - 16 - 8, 8 );
    C.DrawColor = class'HUD'.default.WhiteColor;
    C.Style = 5;
    C.DrawTileClipped( stateTex, 16, 16, 0, 0, stateTex.MaterialUSize(), stateTex.MaterialVSize() );
    C.Style = 1;

    // RENDER: Name
    // Footer
    C.TextSize( playerItem.Name, XL, YL );
    C.OrgX = int(X);
    C.OrgY = int(Y) + h - footerHeight;
    C.ClipX = w;
    C.SetPos( 0, 0 );
    C.DrawColor = RarityColor[playerItem.Rarity];
    C.DrawTileClipped( FooterTexture, w, footerHeight, 0, 0, 256, 64 );

    C.OrgX = X + 4;
    C.OrgY = Y + h - footerHeight;
    C.ClipX = W - 8;
    C.SetPos( 0, 8 );
    C.DrawColor = class'HUD'.default.WhiteColor;
    C.DrawTextClipped( playerItem.Name );
    C.CurX = w*0.5;
    C.CurY = YL + 8;
    C.SetPos( 0, YL + 12 );
    C.DrawColor = RarityColor[playerItem.Rarity];
    C.DrawTextClipped( RarityTitle[playerItem.Rarity] );

    C.OrgX = X-2;
    C.OrgY = Y-2;
    C.ClipX = W;
    C.ClipY = H;
    C.SetPos( 0, 0 );
    if( bSelected || bPending )
    {
        C.DrawColor = #0x8E8EFEFF;
    }
    else
    {
        C.DrawColor = #0x222222FF;
    }
    C.DrawBox( C, w, h );
    C.ClipX = oldClipX;
    C.ClipY = oldClipY;
    C.OrgX = X + W;
    C.OrgY = Y + H;
}

function InternalOnListChange( GUIComponent sender )
{
    local int i;

    i = ItemsListBox.List.GetItem();
    if( i != -1 )
    {
        PawnPreview.ApplyPlayerItem( CRI.PlayerItems[i] );
    }
}

function bool InternalOnListRightClick( GUIComponent sender )
{
    return false;
}

function bool InternalOnListDblClick( GUIComponent sender )
{
    return ToggleSelectedItem();
}

function InternalOnSelect( GUIContextMenu sender, int clickIndex )
{
    switch( clickIndex )
    {
        case 0:
            ToggleSelectedItem();
            break;

        case 1:
            EditSelectedItem();
            break;

        case 2:
            SellSelectedItem();
            break;

        case 3:
            DestroySelectedItem();
            break;
    }
}


final function bool ToggleSelectedItem()
{
    local int i;

    i = ItemsListBox.List.GetItem();
    if( i != -1 )
    {
        CRI.ServerToggleItem( CRI.PlayerItems[i].ID );
        return true;
    }
    return false;
}

final function bool EditSelectedItem()
{
    local int i;

    i = ItemsListBox.List.GetItem();
    if( i != -1 )
    {
        PlayerOwner().ConsoleCommand( "Store Edit" @ CRI.PlayerItems[i].ID );
        return true;
    }
    return false;
}

final function bool SellSelectedItem()
{
    local int i;

    i = ItemsListBox.List.GetItem();
    if( i != -1 )
    {
        CRI.ServerSellItem( CRI.PlayerItems[i].ID );
        return true;
    }
    return false;
}

final function bool DestroySelectedItem()
{
    local int i;

    i = ItemsListBox.List.GetItem();
    if( i != -1 )
    {
        CRI.ServerDestroyItem( CRI.PlayerItems[i].ID );
        return true;
    }
    return false;
}

function bool InternalOnClick( GUIComponent sender )
{
    if( sender == b_ActivateKey )
    {
        if( eb_Key.GetText() == "" )
        {
            PlayerOwner().ClientMessage( "Please input a valid key." );
            return false;
        }

        PlayerOwner().ConsoleCommand( "ActivateKey" @ eb_Key.GetText() );
        return true;
    }
    else if( Sender == b_ColorDialog )
    {
        PlayerOwner().ConsoleCommand( "PreferedColorDialog" );
        return true;
    }
    return false;
}


final static preoperator Color #( int rgbInt )
{
    local Color c;

    c.R = rgbInt >> 24;
    c.G = rgbInt >> 16;
    c.B = rgbInt >> 8;
    c.A = (rgbInt & 255);
    return c;
}

defaultproperties
{
     TileMat=Texture'itemBackground'
     FooterTexture=Texture'itemBar'
     CheckedTexture=Texture'itemChecked'
     UnCheckedTexture=Texture'itemUnChecked'
     Begin Object Class=BTGUI_PlayerItemsListBox Name=oItemsListBox
         CellStyle=CELL_FixedCount
         NoVisibleRows=4
         NoVisibleCols=4
         HorzBorder=1
         OnCreateComponent=oItemsListBox.InternalOnCreateComponent
         WinTop=0.010000
         WinLeft=0.310000
         WinWidth=0.690000
         WinHeight=0.870000
         TabOrder=0
         bBoundToParent=True
         bScaleToParent=True
     End Object
     ItemsListBox=BTGUI_PlayerItemsListBox'BTGUI_PlayerInventory.oItemsListBox'

     Begin Object Class=AltSectionBackground Name=oPreviewBackground
         Caption="Preview"
         WinTop=0.010000
         WinWidth=0.300000
         WinHeight=0.880000
         bBoundToParent=True
         bScaleToParent=True
         OnPreDraw=oPreviewBackground.InternalPreDraw
     End Object
     PreviewBackground=AltSectionBackground'BTGUI_PlayerInventory.oPreviewBackground'

     Begin Object Class=BTGUI_PawnPreviewComponent Name=oPawnPreview
         WinTop=0.010000
         WinWidth=0.300000
         WinHeight=0.880000
         bBoundToParent=True
         bScaleToParent=True
         OnRender=oPawnPreview.OnInternalRender
     End Object
     PawnPreview=BTGUI_PawnPreviewComponent'BTGUI_PlayerInventory.oPawnPreview'

     RarityColor(0)=(B=182,G=207,R=231,A=255)
     RarityColor(1)=(B=218,G=164,R=96,A=255)
     RarityColor(2)=(B=6,G=147,R=26,A=255)
     RarityColor(3)=(B=11,G=208,R=252,A=255)
     RarityColor(4)=(B=5,G=164,R=255,A=255)
     RarityColor(5)=(B=141,G=62,R=251,A=255)
     RarityColor(6)=(B=157,G=19,R=76,A=255)
     RarityTitle(0)="Basic"
     RarityTitle(1)="Fine"
     RarityTitle(2)="Uncommon"
     RarityTitle(3)="Rare"
     RarityTitle(4)="Exotic"
     RarityTitle(5)="Ascended"
     RarityTitle(6)="Legendary"
     Begin Object Class=GUIButton Name=oActivateKey
         Caption="Activate Key"
         Hint="Activate a BestTimes key"
         WinTop=0.900000
         WinWidth=0.250000
         WinHeight=0.050000
         OnClick=BTGUI_PlayerInventory.InternalOnClick
         OnKeyEvent=oActivateKey.InternalOnKeyEvent
     End Object
     b_ActivateKey=GUIButton'BTGUI_PlayerInventory.oActivateKey'

     Begin Object Class=GUIButton Name=oColorDialog
         Caption="Preferred Color"
         StyleName="LadderButtonHi"
         Hint="Edit your preferred color"
         WinTop=0.790000
         WinLeft=0.010000
         WinWidth=0.280000
         WinHeight=0.050000
         OnClick=BTGUI_PlayerInventory.InternalOnClick
         OnKeyEvent=oColorDialog.InternalOnKeyEvent
     End Object
     b_ColorDialog=GUIButton'BTGUI_PlayerInventory.oColorDialog'

     Begin Object Class=GUIEditBox Name=oKey
         Hint="A BestTimes key"
         WinTop=0.900000
         WinLeft=0.260000
         WinWidth=0.740000
         WinHeight=0.050000
         bBoundToParent=True
         bScaleToParent=True
         OnActivate=oKey.InternalActivate
         OnDeActivate=oKey.InternalDeactivate
         OnKeyType=oKey.InternalOnKeyType
         OnKeyEvent=oKey.InternalOnKeyEvent
     End Object
     eb_Key=GUIEditBox'BTGUI_PlayerInventory.oKey'

     OnKeyEvent=BTGUI_PlayerInventory.OnKeyEvent
}
