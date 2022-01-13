class ArtifactSummonCharmPickup extends RPGArtifactPickup;

defaultproperties
{
     InventoryType=Class'fps.ArtifactSummonCharm'
     PickupMessage="You got the Summoning Charm!"
     PickupSound=SoundGroup'WeaponSounds.Translocator.TranslocatorModuleRegeneration'
     PickupForce="TranslocatorModuleRegeneration"
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'ArtifactPickupStatics.MonsterSummon'
     DrawScale=0.250000
     AmbientGlow=255
}
