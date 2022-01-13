class ArtifactLightningBoltPickup extends RPGArtifactPickup;

defaultproperties
{
     InventoryType=Class'fps.ArtifactLightningBolt'
     PickupMessage="You got the Lightning Bolt!"
     PickupSound=Sound'PickupSounds.SniperRiflePickup'
     PickupForce="SniperRiflePickup"
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'ArtifactPickupStatics.LBolt'
     DrawScale=0.250000
     AmbientGlow=128
}
