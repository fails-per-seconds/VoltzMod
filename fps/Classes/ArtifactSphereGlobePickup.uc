class ArtifactSphereGlobePickup extends RPGArtifactPickup;

defaultproperties
{
     InventoryType=Class'fps.ArtifactSphereGlobe'
     PickupMessage="You got the Sphere of Safety!"
     PickupSound=Sound'PickupSounds.SniperRiflePickup'
     PickupForce="SniperRiflePickup"
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'Editor.TexPropSphere'
     bAcceptsProjectors=False
     DrawScale=0.075000
     Skins(0)=Shader'GreyShader'
     AmbientGlow=255
}
