class xDefenseSentinel extends ASTurret;

var int ShieldHealingLevel;
var int HealthHealingLevel;
var int AdrenalineHealingLevel;
var int ResupplyLevel;
var int ArmorHealingLevel;
var float SpiderBoostLevel;

var config float HealthHealingAmount;
var config float ShieldHealingAmount;
var config float AdrenalineHealingAmount;
var config float ResupplyAmount;
var config float ArmorHealingAmount;

function AddDefaultInventory()
{
	// do nothing.
}

defaultproperties
{
     HealthHealingAmount=1.000000
     ShieldHealingAmount=1.000000
     AdrenalineHealingAmount=1.000000
     ResupplyAmount=1.000000
     ArmorHealingAmount=1.000000
     TurretBaseClass=Class'fps.xDefenseSentinelBase'
     DefaultWeaponClassName=""
     VehicleNameString="Defense Sentinel"
     bCanBeBaseForPawns=False
     Mesh=SkeletalMesh'AS_Vehicles_M.FloorTurretGun'
     DrawScale=0.500000
     AmbientGlow=10
     CollisionRadius=0.000000
     CollisionHeight=0.000000
}
