class xLinkSentinel extends ASTurret;

simulated event PostNetBeginPlay()
{
	if (TurretBaseClass != None)
	{
		if (OriginalRotation.Yaw == 0)
			TurretBase = Spawn(TurretBaseClass, Self,, Location+vect(0,0,37), OriginalRotation);
		else
			TurretBase = Spawn(TurretBaseClass, Self,, Location-vect(0,0,37), OriginalRotation);
	}

	if (TurretSwivelClass != None)
		TurretSwivel = Spawn(TurretSwivelClass, Self,, Location, OriginalRotation);

	super(ASVehicle).PostNetBeginPlay();
}

function AddDefaultInventory()
{
	// do nothing.
}

defaultproperties
{
     TurretBaseClass=Class'fps.xLinkSentinelBase'
     TurretSwivelClass=Class'fps.xLinkSentinelSwivel'
     DefaultWeaponClassName=""
     VehicleNameString="Link Sentinel"
     bCanBeBaseForPawns=False
     Mesh=SkeletalMesh'AS_Vehicles_M.FloorTurretGun'
     DrawScale=0.250000
     Skins(0)=Shader'EpicParticles.Shaders.InbisThing'
     Skins(1)=Shader'EpicParticles.Shaders.InbisThing'
     AmbientGlow=250
     CollisionRadius=0.000000
     CollisionHeight=0.000000
}
