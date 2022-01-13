class SphereHealing500r extends Emitter
	placeable;

defaultproperties
{
     Begin Object Class=MeshEmitter Name=MeshEmitter0
         StaticMesh=StaticMesh'Meshes.SphereHealing'
         RenderTwoSided=True
         UseParticleColor=True
         RespawnDeadParticles=False
         UseSizeScale=True
         UseRegularSizeScale=False
         AutomaticInitialSpawning=False
         MaxParticles=1
         SpinsPerSecondRange=(X=(Max=10.000000),Y=(Max=10.000000),Z=(Max=10.000000))
         SizeScale(0)=(RelativeSize=200.000000)
         StartSizeRange=(X=(Min=3.880000,Max=3.880000),Y=(Min=3.880000,Max=3.880000),Z=(Min=3.880000,Max=3.880000))
         InitialParticlesPerSecond=50000.000000
         DrawStyle=PTDS_AlphaBlend
         SecondsBeforeInactive=0.000000
         LifetimeRange=(Min=0.500000,Max=0.500000)
     End Object
     Emitters(0)=MeshEmitter'fps.SphereHealing500r.MeshEmitter0'

     AutoDestroy=True
     bNoDelete=False
     bNetTemporary=True
     RemoteRole=ROLE_DumbProxy
     Style=STY_Masked
     bBlockZeroExtentTraces=False
     bBlockNonZeroExtentTraces=False
     bDirectional=True
}
