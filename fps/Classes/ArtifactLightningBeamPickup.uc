class ArtifactLightningBeamPickup extends RPGArtifactPickup;

defaultproperties
{
     InventoryType=Class'fps.ArtifactLightningBeam'
     PickupMessage="You got the Lightning Beam!"
     PickupSound=Sound'PickupSounds.SniperRiflePickup'
     PickupForce="SniperRiflePickup"
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'ArtifactPickupStatics.LBeam'
     DrawScale=0.250000
     AmbientGlow=128
}
