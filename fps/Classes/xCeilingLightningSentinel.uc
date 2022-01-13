class xCeilingLightningSentinel extends ASTurret;

function AddDefaultInventory()
{
	// do nothing.
}

defaultproperties
{
     DefaultWeaponClassName=""
     VehicleNameString="Ceiling LightSentinel"
     bCanBeBaseForPawns=False
     Mesh=SkeletalMesh'AS_Vehicles_M.CeilingTurretBase'
     DrawScale=0.300000
     Skins(0)=Combiner'CeilingLightning_C'
     Skins(1)=Combiner'CeilingLightning_C'
     AmbientGlow=120
     CollisionRadius=45.000000
     CollisionHeight=60.000000
}
