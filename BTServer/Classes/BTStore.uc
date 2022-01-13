//=============================================================================
// Copyright 2005-2019 Eliot Van Uytfanghe and Marco Hulden. All Rights Reserved.
//=============================================================================
class BTStore extends Object within MutBestTimes
    config(BTStore);

enum ETarget
{
    T_Pawn,
    T_Vehicle,
    T_Player,
    T_Manual
};

struct sItem
{
    var() string Name;
    var() string ID;
    var() string Type;
    var() string ItemClass;
    var() int Cost;
    var() string Desc;
    var() string IMG;

    /** Deprecated! Use "Access=Admin" instead */
    var() bool bAdminGiven;
    var() bool bPassive;

    var() string Conditions;
    var() array<string> Vars;

    /** Additional dropchance added on top of the default dropchance. */
    var() private float DropChance;

    var() enum EAccess
    {
        /** Default. Standard buying. */
        Buy,

        /** Has zero cost. */
        Free,

        /** Requires admin activation or anything below this. */
        Admin,

        /** The item is for premium players only. */
        Premium,

        /** The item is exclusive. */
        Private,

        /** The item can only be found as a drop. */
        Drop,
    } Access;

    var() enum ERarity
    {
        Basic,
        Fine,
        Uncommon,
        Rare,
        Exotic,
        Ascended,
        Legendary,
    } Rarity;

    var() ETarget ApplyOn;

    var transient Material CachedIMG;
    var transient string CachedCategory;
    var transient class<Actor> CachedClass;
};

var() array<sItem> Items;
var() globalconfig array<sItem> CustomItems;
var() const float DefaultDropChance;

struct sCategory
{
    /** Name of the category. */
    var string Name;

    /** All types that belong in the category. */
    var array<string> Types;
};

var() globalconfig array<sCategory> Categories;

/** A list of selectable teams, maximum is 3. */
var() globalconfig array<struct sTeam{
    /** Name of the team. */
    var string Name;

    /** Earned points by the team. */
    var float Points;

    /** Amount of earned votes for the team. */
    var int Voters;

    /** The id of an item, which is the item needed(and activate) to be part of the team. */
    var string ItemID;
    var string BannerItemID;
}> Teams;

/** When this goal is reached by a team, all points and voters will be reset, the winning team's supporters will receive benefits. */
var() globalconfig int TeamPointsGoal;
var() globalconfig bool bEnabled;

final function Free()
{
    // Free items that potentionally hold references to other objects.
    Items.Length = 0;
}

final function int FindPlayerTeam( BTClient_ClientReplication CRI )
{
    local int i;

    for( i = 0; i < Teams.Length; ++ i )
    {
        if( PDat.IsUsingItemById( CRI.myPlayerSlot, Teams[i].ItemID ) )
        {
            return i;
        }
    }
    return -1;
}

final function bool AddPointsForTeam( MutBestTimes BT, BTClient_ClientReplication CRI, int teamIndex, float points )
{
    Teams[teamIndex].Points += points;
    MRI.Teams[teamIndex].Points = Teams[teamIndex].Points;
    SaveConfig();

    PDat.Player[CRI.myPlayerSlot].TeamPointsContribution += points;
    if( Teams[teamIndex].Points >= TeamPointsGoal )
    {
        TeamWon( BT, teamIndex );
    }
    return true;
}

final function TeamWon( MutBestTimes BT, int teamIndex )
{
    local int i;
    local Controller C;
    local PlayerController PC;
    local BTClient_ClientReplication CRI;

    for( i = 0; i < PDat.Player.Length; ++ i )
    {
        // Reward this player?
        if( !PDat.HasItem( i, Teams[teamIndex].ItemID ) )
        {
            continue;
        }

        PDat.SilentRemoveItem( BT, i, Teams[teamIndex].ItemID );
        PDat.Player[i].bPendingTeamReward = PDat.Player[i].TeamPointsContribution > 0;
    }
    SaveAll();

    for( i = 0; i < Teams.Length; ++ i )
    {
        Teams[i].Voters = 0;
        Teams[i].Points = 0.00;

        MRI.Teams[i].Voters = 0;
        MRI.Teams[i].Points = 0.0;
    }
    SaveConfig();

    Level.Game.Broadcast( Outer, Teams[teamIndex].Name @ "has won!, all players have pending rewards!");

    // Reward all players currently ingame. The rest will be rewarded upon connecting.
    for( C = Level.ControllerList; C != none; C = C.NextController )
    {
        PC = PlayerController(C);
        if( PC == none )
            continue;

        CRI = GetRep( PC );
        if( CRI == none )
            continue;

        if( !PDat.Player[CRI.myPlayerSlot].bPendingTeamReward )
            continue;

        CRI.EventTeamIndex = -1;
        RewardTeamPlayer( BT, CRI );
        PDat.Player[CRI.myPlayerSlot].bPendingTeamReward = false;
        PDat.Player[CRI.myPlayerSlot].TeamPointsContribution = 0;
    }
}

final function RewardTeamPlayer( MutBestTimes BT, BTClient_ClientReplication CRI )
{
    local int playerSlot;
    local float rewardScaling;

    playerSlot = CRI.myPlayerSlot;
    rewardScaling = PDat.Player[playerSlot].TeamPointsContribution / 10F;
    PDat.GiveCurrencyPoints( BT, playerSlot, 100*rewardScaling, true );
    PDat.AddExperience( BT, playerSlot, 200*rewardScaling );
    BTServer_TrialMode(CurMode).PerformItemDrop( PlayerController(CRI.Owner), FMin( 15.00*rewardScaling, 99.00 ) );
}

final function bool AddVoteForTeam( int teamIndex )
{
    ++ Teams[teamIndex].Voters;
    MRI.Teams[teamIndex].Voters = Teams[teamIndex].Voters;
    SaveConfig();
    return true;
}

final function bool IsTeamItem( string itemID, optional out int teamIndex )
{
    local int i;

    for( i = 0; i < Teams.Length; ++ i )
    {
        if( Teams[i].ItemID ~= itemID )
        {
            teamIndex = i;
            return true;
        }
    }
    teamIndex = -1;
    return false;
}

// Checks if player has a team item ignoring the active status.
final function bool HasATeamItem( BTClient_ClientReplication CRI )
{
    local int i;

    for( i = 0; i < Teams.Length; ++ i )
    {
        if( PDat.HasItem( CRI.myPlayerSlot, Teams[i].ItemID ) )
        {
            return true;
        }
    }
    return false;
}

final function bool Evaluate( MutBestTimes BT, int itemSlot )
{
    local array<string> conditions;
    local string prop, val;
    local int i, colon, not;
    local bool breverse;

    if( Items[itemSlot].Conditions == "" )
    {
        return true;
    }

    Split( Items[itemSlot].Conditions, "?", conditions );
    if( conditions.Length == 0 )
    {
        conditions[conditions.Length] = Items[itemSlot].Conditions;
    }

    for( i = 0; i < conditions.Length; ++ i )
    {
        colon = InStr( conditions[i], ":" );
        if( colon == -1 )
        {
            not = InStr( conditions[i], "!" );
            if( not == -1 )
            {
                continue;
            }

            colon = not;
        }

        breverse = not != -1;

        prop = Left( conditions[i], colon );
        val = Mid( conditions[i], colon );
        switch( prop )
        {
            case "game":
                if( (breverse && BT.Level.Game.GameName ~= val) || (!breverse && !(BT.Level.Game.GameName ~= val)) )
                {
                    return false;
                }
                break;

            case "map":
                if( (breverse && BT.CurrentMapName ~= val) || (!breverse && !(BT.CurrentMapName ~= val)) )
                {
                    return false;
                }
                break;
        }
    }
    return true;
}

// Load in PreBeginPlay.
final static function BTStore Load( MutBestTimes newOuter )
{
    local BTStore this;
    local int i, j;

    if( !default.bEnabled )
    {
        return none;
    }

    StaticSaveConfig();
    this = new(newOuter) default.Class;

    if( this.CustomItems.Length > 0 )
    {
        j = this.Items.Length;
        this.Items.Insert( j, this.CustomItems.Length );
        for( i = 0; i < this.CustomItems.Length; ++ i )
        {
            this.Items[j + i] = this.CustomItems[i];
            this.Items[j + i].CachedIMG = Material(DynamicLoadObject( this.Items[j + i].IMG, class'Material', true ));
        }
    }
    this.Cache();
    return this;
}

final function Cache()
{
    local int i, j;
    local string outCategoryName;

    for( i = 0; i < Items.Length; ++ i )
    {
        Items[i].CachedIMG = Material(DynamicLoadObject( Items[i].IMG, class'Material', true ));
        Items[i].CachedClass = class<Actor>(DynamicLoadObject( Items[i].ItemClass, class'Class', true ));
        if (Items[i].CachedClass == none) {
            Warn( "Failed to load ItemClass" @ Items[i].ItemClass @ "for" @ Items[i].ID );
        }
        // Cache the cateogry in which each item resists.
        // (This operation is quite expensive, takes about 100ms per request(300+ items).
        for( j = 0; j < Categories.Length; ++ j )
        {
            outCategoryName = Categories[j].Name;
            if( ItemIsInCategory( Items[i].Type, outCategoryName ) )
            {
                Items[i].CachedCategory $= "&"$Categories[j].Name;
            }
        }

        if( Items[i].bAdminGiven )
        {
            Items[i].Access = Admin;
        }

        if( Items[i].DropChance == 0.0 )
        {
            Items[i].DropChance = 1.0;
        }
    }
    AddToPackageMap( "TextureBTimes" );
}

final function int FindCategory( string categoryName )
{
    local int i;

    for( i = 0; i < Categories.Length; ++ i )
    {
        if( Categories[i].Name ~= categoryName )
        {
            return i;
        }
    }
    return -1;
}

final function bool ItemIsInCategory( string itemType, out string categoryName )
{
    local int categoryIndex, i;
    local int asterik;

    categoryIndex = FindCategory( categoryName );
    if( categoryIndex == -1 )
        return false;

    if( categoryName == "" || (categoryName ~= "All" || categoryName ~= "Admin") )
    {
        return true;
    }
    else if( ((itemType == "" || !HasCategory( itemType )) && categoryName ~= "Other") )
    {
        categoryName = "Other";
        return true;
    }

    for( i = 0; i < Categories[categoryIndex].Types.Length; ++ i )
    {
        asterik = InStr( Categories[categoryIndex].Types[i], "*" );
        if(
            Categories[categoryIndex].Types[i] ~= itemType
            ||
            (
                asterik != -1
                &&
                Left( Categories[categoryIndex].Types[i], asterik ) ~= Left( itemType, asterik )
            )
        )
        {
            return true;
        }
    }
    return false;
}

final function bool HasCategory( string itemType )
{
    local int i, j;
    local int asterik;

    for( i = 0; i < Categories.Length; ++ i )
    {
        for( j = 0; j < Categories[i].Types.Length; ++ j )
        {
            asterik = InStr( Categories[i].Types[j], "*" );
            if( Categories[i].Types[j] ~= itemType ||
                (asterik != -1 && Left( Categories[i].Types[j], asterik ) ~= Left( itemType, asterik )) )
                return true;
        }
    }
}

final function int FindItemByID( string id )
{
    local int i;

    for( i = 0; i < Items.Length; ++ i )
    {
        if( Items[i].ID ~= id )
        {
            return i;
        }
    }
    return -1;
}

final function float GetItemDropChance( int itemIndex )
{
    local float bonus;

    if( Items[itemIndex].Access == Drop )
    {
        bonus += 0.05;
    }
    return DefaultDropChance*(1.0 + bonus)*Items[itemIndex].DropChance;
}

final function int GetRandomItem()
{
    local int randomIndex, tries;

tryagain:
    randomIndex = Rand(Items.Length);
    if( Items[randomIndex].Access != Drop )
    {
        if( tries >= Items.Length )
        {
            return -1;
        }
        ++ tries;
        goto tryagain;
    }
    return randomIndex;
}

final function float GetResalePrice( int itemIndex )
{
    return Items[itemIndex].Cost*0.25;
}

/** Called when an item is activated/deactivated either through the store or via a programmatic function. */
final function ItemToggled( int playerSlot, string itemID, bool status )
{
    local PlayerController PC;
    local BTClient_ClientReplication CRI;
    local int outTeamIndex;

    PC = FindPCByPlayerSlot( playerSlot, CRI );
    if( PC != none )
    {
        switch( itemID )
        {
            case "perk_dodge_assistance":
                CRI.bAllowDodgePerk = status;
                break;

            case "perk_press_assistance":
                CRI.bAutoPress = status;
                break;

        default:
            if( IsTeamItem( itemID, outTeamIndex ) )
            {
                if( status )
                {
                    CRI.EventTeamIndex = outTeamIndex;
                }
                else
                {
                    CRI.EventTeamIndex = -1;
                }

                // Give existing supporters their banner reward!
                if( status && PDat.HasItem( playerSlot, Teams[outTeamIndex].ItemID ) && !PDat.HasItem( playerSlot, Teams[outTeamIndex].BannerItemID ) )
                {
                    PDatManager.GiveItem( CRI, Teams[outTeamIndex].BannerItemID );
                }
            }
            break;
        }
    }
    // Handle toggling of items for non-living players.
}

/** Called when an item is removed from a player either through selling or removal by an admin. */
final function ItemRemoved( int playerSlot, string itemID )
{
    switch( itemID )
    {
        case "perk_dodge_assistance":
            // Stimulate as if the item got toggled off.
            ItemToggled( playerSlot, itemID, false ); // FIXME: Dangerous code.
            break;

        case "perk_press_assistance":
            // Stimulate as if the item got toggled off.
            ItemToggled( playerSlot, itemID, false ); // FIXME: Dangerous code.
            break;
    }
}

/** Called when an item was bought by a player or through the "GiveItem" function. */
final function OnItemAcquired( BTClient_ClientReplication CRI, string itemID )
{
    local int outTeamIndex;

    if( IsTeamItem( itemID, outTeamIndex ) )
    {
        AddVoteForTeam( outTeamIndex );
        PDatManager.GiveItem( CRI, Teams[outTeamIndex].BannerItemID );
    }
}

/**
 * Called when an item becomes active either through possesing a Pawn, entering a Vehicle, or joing the game as a PlayerController.
 * @other Actor the item is supposed to get applied to.
 */
final function ItemActivated( Actor other, BTClient_ClientReplication CRI, string itemID )
{
    local LinkedReplicationInfo customRep;
    local int outTeamIndex;

    switch( itemID )
    {
        case "MNAFAccess":
            for( customRep = Controller(other).PlayerReplicationInfo.CustomReplicationInfo; customRep != none; customRep = customRep.NextReplicationInfo )
            {
                if( customRep.IsA('MNAFLinkedRep') )
                {
                    customRep.SetPropertyText( "bIsUnique", "1" );
                    break;
                }
            }
            break;

        case "perk_dodge_assistance":
            CRI.bAllowDodgePerk = true;
            break;

        case "perk_press_assistance":
            CRI.bAutoPress = true;
            break;

        default:
            if( IsTeamItem( itemID, outTeamIndex ) )
            {
                CRI.EventTeamIndex = outTeamIndex;
                Level.Game.Broadcast( Outer, Controller(other).GetHumanReadableName() @ "is supporting" @ Store.Teams[outTeamIndex].Name );
            }
            break;
    }
}

final function ModifyPawn( Pawn other, BTServer_PlayersData data, BTClient_ClientReplication CRI )
{
    ApplyOwnedItems( other, data, CRI, ETarget.T_Pawn );
}

final function ModifyVehicle( Pawn other, Vehicle v, BTServer_PlayersData data, BTClient_ClientReplication CRI )
{
    ApplyOwnedItems( v, data, CRI, ETarget.T_Vehicle );
}

final function ModifyPlayer( PlayerController other, BTServer_PlayersData data, BTClient_ClientReplication CRI )
{
    ApplyOwnedItems( other, data, CRI, ETarget.T_Player );
}

private final function ApplyOwnedItems( Actor other, BTServer_PlayersData data, BTClient_ClientReplication CRI, ETarget target )
{
    local int i, j, itemSlot, curType;
    local bool bIsKnown;
    local array<string> addedTypes;
    local int playerSlot;

    // data.BT.FullLog( "ApplyOwnedItems(" @ other @ CRI @ target @ ")" );
    playerSlot = CRI.myPlayerSlot;
    if( playerSlot == -1 ) // Replication not yet ready!
        return;

    j = data.Player[playerSlot].Inventory.BoughtItems.Length;
    for( i = 0; i < j; ++ i )
    {
        if( !data.Player[playerSlot].Inventory.BoughtItems[i].bEnabled )
        {
            continue;
        }

        itemSlot = FindItemByID( data.Player[playerSlot].Inventory.BoughtItems[i].ID );
        if( itemSlot == -1 || Items[itemSlot].ApplyOn != target )
        {
            continue;
        }

        if( Items[itemSlot].Type != "" )
        {
            for( curType = 0; curType < addedTypes.Length; ++ curType )
            {
                if( addedTypes[curType] == Items[itemSlot].Type )
                {
                    bIsKnown = true;
                    break;
                }
            }

            if( bIsKnown )
            {
                bIsKnown = false;
                continue;
            }
            addedTypes[addedTypes.Length] = Items[itemSlot].Type;
        }

        if( ActivateItem( other, itemSlot ) )
        {
            ItemActivated( other, CRI, Items[itemSlot].ID );
        }
    }
}

public final function bool ActivateItem( Actor other, int index )
{
    local class<Actor> itemClass;
    local Actor itemObject;

    // Items with no defined class should always return true e.g. Experience booster items.
    if( Items[index].ItemClass == "" )
    {
        return true;
    }

    itemClass = Items[index].CachedClass;
    if( itemClass == none )
    {
        return false;
    }

    // Apply the vars on the pawn's instance if the item's class equals the target(@other)
    if( other.Class == itemClass || ClassIsChildOf( other.Class, itemClass ) )
    {
        itemObject = other;
    }
    else
    {
        itemObject = other.Spawn( itemClass, other,, other.Location, other.Rotation );
        // Failed to spawn or it destroyed itself in BeginPlay.
        if( itemObject == none )
        {
            return false;
        }
    }
    ApplyVariablesOn( itemObject, Items[index].Vars );
    return true;
}

private final function ApplyVariablesOn( Actor other, array<string> variables )
{
    local array<string> s;
    local int i;

    for( i = 0; i < variables.Length; ++ i )
    {
        Split( variables[i], ":", s );
        switch( Locs(s[0]) )
        {
            case "overlaymat":
                other.SetOverlayMaterial( Material(DynamicLoadObject( s[1], class'Material', true )), 9999.00, true );
                break;

            default:
                other.SetPropertyText( s[0], s[1] );
                break;
        }
    }
}

final function bool CanBuyItem( PlayerController buyer, BTClient_ClientReplication CRI, int index, out string msg )
{
    local int playerSlot;

    playerSlot = CRI.myPlayerSlot;
    if( PDat.HasItem( playerSlot, Items[index].Id ) )
    {
        msg = "You do already own" @ Items[index].Name;
        return false;
    }

    if( IsTeamItem( Items[index].Id ) && HasATeamItem( CRI ) )
    {
        msg = "You have already voten for a team!";
        return false;
    }

    if( buyer.PlayerReplicationInfo.bAdmin || buyer.Level.NetMode == NM_Standalone )
        return true;

    switch( Items[index].Access )
    {
        case Buy:
            if( !PDat.HasCurrencyPoints( playerSlot, Items[index].Cost ) )
            {
                msg = "You do not have enough currency points to buy" @ Items[index].Name;
                return false;
            }
            break;

        case Free:
            break;

        case Admin:
            msg = "Sorry" @ Items[index].Name @ "can only be given by admins!";
            return false;
            break;

        case Premium:
            if( !PDat.Player[playerSlot].bHasPremium )
            {
                msg = "Sorry" @ Items[index].Name @ "is only for admins and premium players!";
                return false;
            }
            break;

        case Private:
            msg = "Sorry" @ Items[index].Name @ "is an exclusive item!";
            return false;
            break;

        case Drop:
            msg = "Sorry" @ Items[index].Name @ "is drop only item!";
            return false;
            break;
    }
    return true;
}

defaultproperties
{
     items(0)=(Name="Trailer",Id="Trailer",Type="FeetTrailer",Desc="Customizable(Colors,Texture) trailer",Access=Premium,Rarity=Ascended)
     items(1)=(Name="MNAF Plus",Id="MNAFAccess",Type="UP_MNAF",Desc="Gives you access to MNAF member options",Access=Premium,Rarity=Exotic,ApplyOn=T_Player)
     items(2)=(Name="+100% EXP Bonus",Id="exp_bonus_1",Type="UP_EXPBonus",ItemClass="",cost=1000,Desc="Get +100% EXP bonus for the next 4 play hours!",img="TextureBTimes.StoreIcons.EXPBOOST_IMAGE",bPassive=True,dropChance=0.300000,Rarity=Uncommon,ApplyOn=T_Player)
     items(3)=(Name="+200% EXP Bonus",Id="exp_bonus_2",Type="UP_EXPBonus",ItemClass="",cost=3000,Desc="Get +200% EXP bonus for the next 24 play hours!",img="TextureBTimes.StoreIcons.EXPBOOST_IMAGE2",bPassive=True,Rarity=Uncommon,ApplyOn=T_Player)
     items(4)=(Name="+200% Currency Bonus",Id="cur_bonus_1",Type="UP_CURBonus",ItemClass="",Desc="Get +200% Currency bonus for the next 24 play hours!",img="TextureBTimes.StoreIcons.CURBOOST_IMAGE",bPassive=True,Access=Premium,Rarity=Uncommon,ApplyOn=T_Player)
     items(5)=(Name="+5% Dropchance Bonus",Id="drop_bonus_1",Type="UP_DROPBonus",ItemClass="",cost=50,Desc="Get +5% Dropchance bonus for the next 24 play hours!",bPassive=True,dropChance=1.000000,Access=Drop,Rarity=Rare,ApplyOn=T_Player)
     items(6)=(Name="Grade F Skin",Id="skin_grade_f",Type="Skin",ItemClass="Engine.Pawn",cost=2000,Desc="Official Wire Skin F",img="TextureBTimes.GradeF_FB",Vars=("OverlayMat:TextureBTimes.GradeF_FB"),Access=Drop,Rarity=Fine)
     items(7)=(Name="Grade E Skin",Id="skin_grade_e",Type="Skin",ItemClass="Engine.Pawn",cost=2000,Desc="Official Wire Skin E",img="TextureBTimes.GradeE_FB",Vars=("OverlayMat:TextureBTimes.GradeE_FB"),Access=Drop,Rarity=Fine)
     items(8)=(Name="Grade D Skin",Id="skin_grade_d",Type="Skin",ItemClass="Engine.Pawn",cost=2000,Desc="Official Wire Skin D",img="TextureBTimes.GradeD",Vars=("OverlayMat:TextureBTimes.GradeD"),Access=Drop,Rarity=Fine)
     items(9)=(Name="Dodge Assistance",Id="perk_dodge_assistance",Type="Perk_Dodge",Desc="Assists the player with timing dodges",img="TextureBTimes.PerkIcons.matrix",Access=Free,ApplyOn=T_Player)
     items(10)=(Name="Press Assistance",Id="perk_press_assistance",Type="Perk_Press",Desc="Auto presses for the player upon touch of any objective",img="TextureBTimes.PerkIcons.trollface",Access=Free,ApplyOn=T_Player)
     items(11)=(Name="Golden Vehicle",Id="vskin_gold",Type="VehicleSkin",ItemClass="Engine.Vehicle",Desc="Drive around with a golden vehicle!",img="XGameShaders.PlayerShaders.PlayerShieldSh",Vars=("OverlayMat:XGameShaders.PlayerShaders.PlayerShieldSh"),Access=Premium,Rarity=Rare,ApplyOn=T_Vehicle)
     items(12)=(Name="Captain Leg",Id="mod_rfoot",Type="Mod",ItemClass="BTClient.BTItem_ChoppedLeg",Desc="Chop your right leg!",Access=Drop,Rarity=Exotic)
     DefaultDropChance=0.050000
     Categories(0)=(Name="All")
     Categories(1)=(Name="Other")
     Categories(2)=(Name="Admin")
     Categories(3)=(Name="Premium")
     Categories(4)=(Name="Trailers",Types=("Trailer","FeetTrailer"))
     Categories(5)=(Name="Upgrades",Types=("UP_*"))
     Categories(6)=(Name="Perks",Types=("Perk_*"))
     TeamPointsGoal=1000
     bEnabled=True
}
