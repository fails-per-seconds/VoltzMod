class Exec extends info;

//Import resources
#exec obj load file="Resources\FailsInvRC.u" package="fpsInv"
#exec obj load file="InterfaceContent.utx"
#exec obj load file="AS_FX_TX.utx"

#exec audio import file="Resources\HitSoundFriendly.wav" name="HS_Friendly"
#exec audio import file="Resources\HitSound.wav" name="HS_Enemy"

defaultproperties
{
}
