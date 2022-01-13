//=============================================================================
// Copyright 2005-2018 Eliot Van Uytfanghe. All Rights Reserved.
//=============================================================================
class BTAchievements extends Object
    config(BTAchievements)
    perobjectconfig;

const CONFIG_NAME = "Custom";

/** List of categories for achievements such as "Records", "Trophies". */
var() array<BTClient_ClientReplication.sAchievementCategory> Categories;
var config array<BTClient_ClientReplication.sAchievementCategory> CustomCategories;

/** A structure that defines an earnable achievement. */
struct sAchievement
{
    /** Title of the achievement e.g. "Recwhore" */
    var string Title;

    /** Identity of the achievement, used to identifiy which achievement an user has achieved.
        Changing this will make the players that have earned this achievement obsolete. */
    var name ID;

    /** The @Id of a sCategory to bind to. */
    var string CatID;

    /**
     * A defined type to track the current achievements progress
     * - e.g. built-in "RecordsCount", or a custom defined type to be used in sync with @CompletionType.
     */
    var name Type;

    /** A defined type to progress when this achievement completes! */
    var name CompletionType;

    /** Amount of @Type's progress necessary to earn the achievement. */
    var int Count;

    /** A description of the achievement. */
    var string Description;

    /** Icon portraying the achievement. */
    var string Icon;

    /** Value of the achievement. */
    var int Points;

    /** The GUI color for the special effects. */
    var Color EffectColor;

    /** Reward to be given on completion of this achievement. Add multiple rewards by splitting with a semicolon. */
    var string ItemRewardId;
};

/** Collection of achievements that players are able to complete. */
var() array<sAchievement> Achievements;
var config array<sAchievement> CustomAchievements;

var private int LastAchievementsCount;

/** Defines a map trigger for particular achievements. */
struct sMapTrigger
{
    var string MapTitle;
    var float Time;
    var name Event;
    var name Target;
    var bool bCount;
};
var() array<sMapTrigger> MapTriggers;
var config array<sMapTrigger> CustomMapTriggers;

/** Necessary to load up the achievements collection. */
final static function BTAchievements Load()
{
    local BTAchievements achievementsManager;
    local int i, j;

    achievementsManager = new (none, CONFIG_NAME) default.Class;

    j = achievementsManager.Categories.Length;
    if( j > 0 )
    {
        achievementsManager.Categories.insert(j, achievementsManager.CustomCategories.Length);
        for( i = 0; i < achievementsManager.CustomCategories.Length; ++ i ) {
            achievementsManager.Categories[j + i] = achievementsManager.CustomCategories[i];
        }
    }

    j = achievementsManager.Achievements.Length;
    if( j > 0 )
    {
        achievementsManager.Achievements.insert(j, achievementsManager.CustomAchievements.Length);
        for( i = 0; i < achievementsManager.CustomAchievements.Length; ++ i ) {
            achievementsManager.Achievements[j + i] = achievementsManager.CustomAchievements[i];
        }
    }

    j = achievementsManager.MapTriggers.Length;
    if( j > 0 )
    {
        achievementsManager.MapTriggers.insert(j, achievementsManager.CustomMapTriggers.Length);
        for( i = 0; i < achievementsManager.CustomMapTriggers.Length; ++ i ) {
            achievementsManager.MapTriggers[j + i] = achievementsManager.CustomMapTriggers[i];
        }
    }
    return achievementsManager;
}

final function InitForMap( MutBestTimes BT, string mapName, string mapTitle )
{
    local int i;

    for( i = 0; i < MapTriggers.Length; ++ i )
    {
        if( MapTriggers[i].Event != '' && MapTriggers[i].MapTitle == mapTitle )
        {
            BT.Spawn( class'BTServer_AchievementListener', BT, MapTriggers[i].Event );
        }
    }
}

final function int FindAchievementByTitle( string title )
{
    local int i;

    for( i = 0; i < Achievements.Length; ++ i )
    {
        if( Achievements[i].Title ~= title )
        {
            return i;
        }
    }
    return -1;
}

final function int FindAchievementByID( name id )
{
    local int i;

    for( i = 0; i < Achievements.Length; ++ i )
    {
        if( Achievements[i].ID == id )
        {
            return i;
        }
    }
    return -1;
}

// Note:Do not modify the struct because it is copied not passed!
final function sAchievement GetAchievementByID( name id )
{
    return Achievements[FindAchievementByID( id )];
}

final function int FindAchievementsByType( name type, out array<int> collection )
{
    local int i;

    for( i = 0; i < Achievements.Length; ++ i )
    {
        if( Achievements[i].Type == type )
        {
            collection.Insert( 0, 1 );
            collection[0] = i;
        }
    }
    return collection.Length;
}

final function int GetCountForAchievement( name id )
{
    local int achIndex;

    achIndex = FindAchievementByID( id );
    if( achIndex == -1 )
        return 0;

    return Achievements[achIndex].Count;
}

final static function bool CmpWithAsterik(string a, string b)
{
    local int asterik;

    asterik = InStr( a, "*" );
    return a ~= b
        || (asterik != -1 && Left( a, asterik ) ~= Left( b, asterik ));
}

final function bool TestMapTrigger( out name target, string title, optional float recordTime, optional name eventStr )
{
    local int i;

    if( eventStr != '' )
    {
        for( i = 0; i < MapTriggers.Length; ++ i )
        {
            if( MapTriggers[i].Event != eventStr )
            {
                continue;
            }

            if( CmpWithAsterik( MapTriggers[i].MapTitle, title) )
            {
                target = MapTriggers[i].Target;
                return MapTriggers[i].Time <= 0 || recordTime <= MapTriggers[i].Time;
            }
        }
        return false;
    }

    for( i = 0; i < MapTriggers.Length; ++ i )
    {
        if( MapTriggers[i].Event != '' )
        {
            continue;
        }

        if( CmpWithAsterik( MapTriggers[i].MapTitle, title) )
        {
            target = MapTriggers[i].Target;
            return recordTime <= MapTriggers[i].Time || MapTriggers[i].Time == -1;
        }
    }
    return false;
}

defaultproperties
{
     Categories(0)=(Name="Trials",Id="cat_trials")
     Categories(1)=(Name="Records",Id="cat_records",ParentId="cat_trials")
     Categories(2)=(Name="Map Challenges",Id="cat_map",ParentId="cat_trials")
     Categories(3)=(Name="Daily Trophies",Id="cat_trophies",ParentId="cat_map")
     Categories(4)=(Name="Server",Id="cat_server")
     Achievements(0)=(Title="Newbie Recwhore",Id="recwhore_0",CatId="cat_records",Type="RecordsCount",Count=1,Description="Achieve one record",Points=1,EffectColor=(B=255,A=255))
     Achievements(1)=(Title="Noob Recwhore",Id="recwhore_1",CatId="cat_records",Type="RecordsCount",Count=5,Description="Achieve five records",Points=2,EffectColor=(B=255,A=255))
     Achievements(2)=(Title="Experienced Recwhore",Id="recwhore_2",CatId="cat_records",Type="RecordsCount",Count=20,Description="Achieve twenty records",Points=2,EffectColor=(B=255,A=255))
     Achievements(3)=(Title="Hardcore Recwhore",Id="recwhore_3",CatId="cat_records",Type="RecordsCount",Count=50,Description="Achieve fifty records",Points=5,EffectColor=(B=255,A=255))
     Achievements(4)=(Title="Recwhore",Id="recwhore_4",CatId="cat_records",Type="RecordsCount",Count=100,Description="Achieve a hundred records",Points=10,EffectColor=(B=255,A=255))
     Achievements(5)=(Title="TechChallenge whore",Id="map_1",CatId="cat_map",Type="FinishTech",Count=50,Description="Complete any TechChallenge map 50 times",Points=2,EffectColor=(G=165,R=255,A=255))
     Achievements(6)=(Title="Another fan",Id="map_2",CatId="cat_map",Description="Set a record on Eliot'sTrial of 4 minutes or less",Points=10,EffectColor=(G=165,R=255,A=255))
     Achievements(7)=(Title="What's a Checkpoint?",Id="checkpoint_1",CatId="cat_trials",Type="CheckPointUses",Count=10,Description="Reach 10 Checkpoints",Points=1,EffectColor=(B=128,G=128,A=255))
     Achievements(8)=(Title="Epic failer",Id="clientspawn_1",CatId="cat_trials",Description="Set a 'Client Spawn' by using 'SetClientSpawn'",Points=1,EffectColor=(B=128,G=128,A=255))
     Achievements(9)=(Title="Jani maps hater",Id="jani_1",CatId="cat_trials",Description="Insult a jani's map while playing one",Points=1,EffectColor=(B=128,G=128,A=255))
     Achievements(10)=(Title="Group lover",Id="mode_1",CatId="cat_trials",Description="Complete a Group map",Points=5,EffectColor=(B=128,G=128,A=255))
     Achievements(11)=(Title="I like it Regular",Id="mode_2",CatId="cat_trials",Description="Complete a Regular map",Points=2,EffectColor=(B=128,G=128,A=255))
     Achievements(12)=(Title="ForeverAlone.jpg",Id="mode_3",CatId="cat_trials",Type="FinishSolo",Count=20,Description="Complete a Solo map 20 times",Points=5,EffectColor=(B=128,G=128,A=255))
     Achievements(13)=(Title="Newbie",Id="level_0",CatId="cat_server",Type="LevelUp",Count=2,Description="Level up 2 times",Points=1)
     Achievements(14)=(Title="Noob",Id="level_2",CatId="cat_server",Type="LevelUp",Count=8,Description="Level up 8 times",Points=2)
     Achievements(15)=(Title="Experienced",Id="level_3",CatId="cat_server",Type="LevelUp",Count=20,Description="Level up 20 times",Points=2)
     Achievements(16)=(Title="Experience lover",Id="experience_0",CatId="cat_server",Description="Earn 64 experience from one action",Points=2)
     Achievements(17)=(Title="I bought an Item!",Id="store_0",CatId="cat_server",Description="Buy your first item from the Store",Points=1,EffectColor=(B=128,G=128,A=255))
     Achievements(18)=(Title="Dedicated noob",Id="level_4",CatId="cat_server",Description="Reach level 50",Points=5)
     Achievements(19)=(Title="Dedicated gamer",Id="level_5",CatId="cat_server",Description="Reach level 100",Points=5)
     Achievements(20)=(Title="Map loveist",Id="finish_0",CatId="cat_trials",Type="Finish",Count=200,Description="Finish 200 times any trial map",Points=5,EffectColor=(B=128,G=128,A=255))
     Achievements(21)=(Title="Lucky lucker",Id="tie_0",CatId="cat_records",Type="Tied",Count=5,Description="Tie a record on a Solo map 5 times",Points=5,EffectColor=(B=255,A=255))
     Achievements(22)=(Title="Ghoster",Id="ghost_0",CatId="cat_trials",Description="Get your first ghost",Points=5,EffectColor=(B=128,G=128,A=255))
     Achievements(23)=(Title="I'm no muffin",Id="points_0",CatId="cat_records",Description="Earn 20 points from one record",Points=2,EffectColor=(B=255,A=255))
     Achievements(24)=(Title="Loner",Id="holiday_0",CatId="cat_trials",Description="Spawn on a 'Client Spawn' on a BTimes holiday",Points=1,EffectColor=(B=128,G=128,A=255))
     Achievements(25)=(Title="Robin Hood",Id="records_0",CatId="cat_records",Type="StealRecord",Count=50,Description="Steal 50 first place records not owned by you",Points=20,EffectColor=(B=255,A=255))
     Achievements(26)=(Title="Who's bad?",Id="map_3",CatId="cat_map",Description="Set a record on Blood On The Floor",Points=10,EffectColor=(G=165,R=255,A=255))
     Achievements(27)=(Title="Classic lovelist",Id="map_5",CatId="cat_map",Description="Set a record on a RoomTrials map of 4 minutes or less",Points=5,EffectColor=(G=165,R=255,A=255))
     Achievements(28)=(Title="(no homo)",Id="sirdicky",CatId="cat_trials",Description="Find dicky and touch him(no homo)",Points=1,EffectColor=(B=128,G=128,A=255))
     Achievements(29)=(Title="Night whore",Id="mode_3_night",CatId="cat_trials",Description="Complete a Solo map at night",Points=1,EffectColor=(B=128,G=128,A=255))
     Achievements(30)=(Title="Server loveist",Id="playtime_0",CatId="cat_server",Description="Play for over 10 hours on this server",Points=2,EffectColor=(B=255,R=255,A=255))
     Achievements(31)=(Title="Home sweet home",Id="playtime_1",CatId="cat_server",Description="Play for over 1000 hours on this server",Points=10,EffectColor=(B=255,R=255,A=255))
     Achievements(32)=(Title="Fan of Haydon",Id="quality_0",CatId="cat_trials",Type="FinishQuality",Count=10,Description="Finish 10 times a map that's designed by Eliot or Haydon",Points=5,EffectColor=(B=128,G=128,A=255))
     Achievements(33)=(Title="Challenges master",Id="challenge_0",CatId="cat_trophies",Type="FinishDailyChallenge",Count=25,Description="Earn 25 trophies from daily challenges",Points=10)
     Achievements(34)=(Title="High achiever",Id="ach_0",CatId="cat_server",Description="Achieve 30 achievements",Points=5)
     Achievements(35)=(Title="Ragequitter",Id="records_1",CatId="cat_records",Description="Lose 5 records since your last visit",Points=1,EffectColor=(B=255,A=255))
     Achievements(36)=(Title="Hatist",Id="store_2",CatId="cat_server",Description="Buy 10 items",Points=2,EffectColor=(B=128,G=128,A=255))
     Achievements(37)=(Title="EgyptRuin whore",Id="map_6",CatId="cat_map",Type="FinishRuin",Count=15,Description="Complete any EgyptRuin map 15 times",Points=5,EffectColor=(G=165,R=255,A=255))
     Achievements(38)=(Title="Immune to failure",Id="records_2",CatId="cat_records",Description="Hijack a Solo record that players had failed 50 times to achieve",Points=1,EffectColor=(B=255,A=255))
     Achievements(39)=(Title="Birthday wisher",Id="eliot_0",CatId="cat_server",Description="Say Happy Birthday Eliot! on August 26th",Points=1,EffectColor=(B=128,G=128,A=255))
     Achievements(40)=(Title="Objectives farmer",Id="obj_0",CatId="cat_server",Description="Complete 10000 objectives",Points=5)
     Achievements(41)=(Title="Solo gamer",Id="records_3",CatId="cat_records",Description="Own 50 Solo records",Points=5,EffectColor=(B=255,A=255))
     Achievements(42)=(Title="Regular gamer",Id="records_4",CatId="cat_records",Description="Own 10 Regular records",Points=5,EffectColor=(B=255,A=255))
     Achievements(43)=(Title="Group gamer",Id="records_5",CatId="cat_records",Description="Own 4 Group records",Points=5,EffectColor=(B=255,A=255))
     Achievements(44)=(Title="Trials master",Id="ach_1",CatId="cat_records",Description="Earn all four gamer achievements",Points=10,EffectColor=(B=255,A=255))
     MapTriggers(0)=(MapTitle="Eliot's Trial",Time=240.000000,Target="map_2")
     MapTriggers(1)=(MapTitle="Blood On The Floor",Time=-1.000000,Target="map_3")
     MapTriggers(3)=(MapTitle="RoomTrials*",Time=240.000000,Target="map_5")
}
