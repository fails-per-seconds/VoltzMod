class BTGUI_Pawn extends xPawn;

function SetupPreview(Pawn other)
{
    if (other != none) {
        LinkMesh(other.Mesh);
        Skins = other.Skins;
    }
    SetRotation(Owner.Rotation);
    LoopAnim('RunF', 1.0/Level.TimeDilation);
}

function ClearPreview()
{
    local int i;

    for (i = 0; i < Attached.Length; ++ i) {
        if (Attached[i] == none) continue;
        Attached[i].Destroy();
    }
}

event Tick(float Delta)
{
	local rotator NewRot;

	NewRot = Rotation;
	NewRot.Yaw += Delta * 20000/Level.TimeDilation;
	SetRotation(NewRot);
}

event Destroyed()
{
    super.Destroyed();
    ClearPreview();
}

defaultproperties
{
     GruntVolume=0.000000
     FootstepVolume=0.000000
     bServerMoveSetPawnRot=False
     bUseDynamicLights=False
     bHidden=True
     Physics=PHYS_Rotating
     RemoteRole=ROLE_None
     Mesh=SkeletalMesh'SkaarjAnims.Skaarj_Skel'
     AmbientGlow=200
     MaxLights=0
     bUnlit=True
     bCanBeDamaged=False
     bOwnerNoSee=False
     bAlwaysTick=True
     bCollideActors=False
     bCollideWorld=False
     bBlockActors=False
     bProjTarget=False
     RotationRate=(Pitch=0,Yaw=2048,Roll=0)
}
