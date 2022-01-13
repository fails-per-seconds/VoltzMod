class ArtifactGlobePickup extends RPGArtifactPickup;

defaultproperties
{
     InventoryType=Class'fps.ArtifactGlobe'
     PickupMessage="You got the Globe!"
     PickupSound=Sound'PickupSounds.ShieldPack'
     PickupForce="ShieldPack"
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'Editor.TexPropSphere'
     bAcceptsProjectors=False
     DrawScale=0.075000
     Skins(0)=Shader'ArtifactPickupSkins.GlobeShader'
     AmbientGlow=255
}
