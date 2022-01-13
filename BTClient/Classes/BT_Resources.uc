class BT_Resources extends info;

//load
#exec obj load file="2K4Menus.utx"
#exec obj load file="MenuSounds.uax"
#exec obj load file="SkaarjAnims.ukx"
#exec obj load file="UT2003Fonts.utx"

//custom load
#exec obj load file="Textures/ClientBTimes.utx" package="BTClient"
#exec obj load file="Textures/CountryFlagsUT2K4.utx" package="BTClient" group="CountryFlags"

//texture import
#exec texture import name=itemBackground file="Resources/itemBg.tga" mips=off DXT=1 LODSet=5
#exec texture import name=itemBar file="Resources/itemBar.tga" mips=off DXT=1 LODSet=5
#exec texture import name=itemUnChecked file="Resources/itemUnChecked.tga" mips=off DXT=1 LODSet=5
#exec texture import name=itemChecked file="Resources/itemChecked.tga" mips=off DXT=1 LODSet=5

//audio import
#exec audio import file="Resources/checkpoint.WAV" name="CheckPoint" group="Sounds"


defaultproperties
{
}