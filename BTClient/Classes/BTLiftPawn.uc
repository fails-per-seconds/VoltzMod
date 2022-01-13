class BTLiftPawn extends ReplicationInfo;

var xPawn PawnToLift;

replication
{
    reliable if (bNetInitial && Role == ROLE_Authority)
        PawnToLift;
}

event PreBeginPlay();

event PostBeginPlay()
{
    PawnToLift = xPawn(Owner);
}

simulated event PostNetBeginPlay()
{
    if (PawnToLift == none) {
        Destroy();
        return;
    }

    if (Level.NetMode != NM_DedicatedServer) {
        StartLifting();
    }
}

private simulated function StartLifting()
{
    local BodyEffect effect;

    effect = Spawn(class'BodyEffect', PawnToLift,, Location, Rotation);
    effect.DamageType = class'BTDamTypeLiftPawn';
    effect.LifeSpan = 0.3;

    PawnToLift.Velocity = vect(0,0,64);
    PawnToLift.SetPhysics(PHYS_KarmaRagdoll);
    PawnToLift.bSkeletized = true; // Set true so that PlayDying will not trigger a death sound.
    PawnToLift.StartDeRes();
}

event Destroyed()
{
    if (PawnToLift != none) {
        PawnToLift.PlayDying(class'BTDamTypeLiftPawn', vect(0,0,0));
    }
}

defaultproperties
{
     bNetTemporary=True
     LifeSpan=0.640000
}
