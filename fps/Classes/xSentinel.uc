class xSentinel extends ASVehicle_Sentinel_Floor;

simulated event PostBeginPlay()
{
	DefaultWeaponClassName=string(class'WeaponSentinel');

	super.PostBeginPlay();
}

defaultproperties
{
     DefaultWeaponClassName=""
     bNoTeamBeacon=False
}
