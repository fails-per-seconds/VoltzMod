class AutoGun extends ASTurret;

static function StaticPrecache(LevelInfo L)
{
	super.StaticPrecache(L);

	L.AddPrecacheMaterial(Material'AS_Weapons_TX.Sentinels.FloorTurret');

	L.AddPrecacheStaticMesh(StaticMesh'AS_Weapons_SM.FloorTurretSwivel');
}

simulated function UpdatePrecacheStaticMeshes()
{
	Level.AddPrecacheStaticMesh(StaticMesh'AS_Weapons_SM.FloorTurretSwivel');

	super.UpdatePrecacheStaticMeshes();
}

simulated function UpdatePrecacheMaterials()
{
	Level.AddPrecacheMaterial(Material'AS_Weapons_TX.Sentinels.FloorTurret');

	super.UpdatePrecacheMaterials();
}

simulated event PostBeginPlay()
{
	DefaultWeaponClassName=string(class'WeaponAutoGun');

	super.PostBeginPlay();
}

simulated function PlayFiring(optional float Rate, optional name FiringMode)
{
	PlayAnim('Fire', 0.75);
}

defaultproperties
{
     TurretBaseClass=Class'fps.AutoGunBase'
     TurretSwivelClass=Class'fps.AutoGunSwivel'
     DefaultWeaponClassName=""
     VehicleProjSpawnOffset=(X=45.000000,Y=0.000000,Z=0.000000)
     bNonHumanControl=True
     AutoTurretControllerClass=None
     VehicleNameString="AutoGun"
     bCanBeBaseForPawns=False
     HealthMax=1000.000000
     Health=1000
     Mesh=SkeletalMesh'AS_Vehicles_M.FloorTurretGun'
     DrawScale=0.250000
     AmbientGlow=48
     TransientSoundVolume=0.750000
     TransientSoundRadius=512.000000
     CollisionRadius=0.000000
     CollisionHeight=0.000000
     bNetNotify=True
}
