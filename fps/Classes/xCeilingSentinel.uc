class xCeilingSentinel extends ASVehicle_Sentinel_Ceiling;

simulated function PostBeginPlay()
{
	DefaultWeaponClassName=string(class'WeaponSentinel');

	super.PostBeginPlay();
}

defaultproperties
{
     DefaultWeaponClassName=""
     bNoTeamBeacon=False
}
