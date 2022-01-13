class ArtifactRepulsion extends EnhancedRPGArtifact
	config(fps);

var config int AdrenalineRequired;
var config float BlastRadius;
var config float MaxKnockbackTime;
var config float MaxKnockbackMomentum;
var config float MinKnockbackMomentum;

var Sound KnockbackSound;
var Material KnockbackOverlay;

function BotConsider()
{
	return;
}

function PostBeginPlay()
{
	super.PostBeginPlay();
	disable('Tick');
}

function Activate()
{
	local float dist, KnockbackScale, KnockbackAmount;
	local vector dir;
	local Controller C, NextC;
	local KnockbackInv InvKnock;
	local Vector newLocation;
	local Vehicle V;

	if (Instigator == None)
		return;

	if (Instigator.Controller.Adrenaline < AdrenalineRequired*AdrenalineUsage)
	{
		Instigator.ReceiveLocalizedMessage(MessageClass, AdrenalineRequired*AdrenalineUsage, None, None, Class);
		bActive = false;
		GotoState('');
		return;
	}
		
	V = Vehicle(Instigator);
	if (V != None)
	{
		Instigator.ReceiveLocalizedMessage(MessageClass, 3000, None, None, Class);
		bActive = false;
		GotoState('');
		return;
	}

	spawn(class'RepulsionExplosion', Instigator.Controller,,Instigator.Location);
	C = Level.ControllerList;
	while (C != None)
	{
		NextC = C.NextController;
		if (C.Pawn != None && C.Pawn != Instigator && C.Pawn.Health > 0 && !C.SameTeamAs(Instigator.Controller)
		     && VSize(C.Pawn.Location - Instigator.Location) < BlastRadius && FastTrace(C.Pawn.Location, Instigator.Location) && !C.Pawn.isA('Vehicle'))
		{
			if (class'RW_Freeze'.static.canTriggerPhysics(C.Pawn) && (C.Pawn.FindInventoryType(class'NullEntropyInv') == None))
			{
				if (C.Pawn.FindInventoryType(class'KnockbackInv') == None)
				{
					InvKnock = spawn(class'KnockbackInv', C.Pawn,,, rot(0,0,0));
					if (InvKnock != None)
					{
						dir = C.Pawn.Location - Instigator.Location;
						dist = FMax(1,VSize(dir));
						dir = dir/dist;
						KnockbackScale = 1 - FMax(0,dist/BlastRadius);

						if (C.Pawn.Physics != PHYS_Walking && C.Pawn.Physics != PHYS_Falling && C.Pawn.Physics != PHYS_Hovering)
							C.Pawn.SetPhysics(PHYS_Hovering);

						if (C.Pawn.Physics == PHYS_Walking)
						{
							newLocation = C.Pawn.Location;
							newLocation.z += 10;
							C.Pawn.SetLocation(newLocation);
						}
						KnockbackAmount = (KnockbackScale*(MaxKnockbackMomentum-MinKnockbackMomentum)) + MinKnockbackMomentum;
						C.Pawn.TakeDamage(1, Instigator, C.Pawn.Location, KnockbackAmount*dir*0.8*C.Pawn.Mass, class'Fell');

						InvKnock.LifeSpan = (KnockbackScale*(MaxKnockbackTime-1))+1;
						InvKnock.Modifier = 4;
						InvKnock.GiveTo(C.Pawn);
						C.Pawn.SetOverlayMaterial(KnockbackOverlay, 1.0, false);
						if (PlayerController(C) != None)
					 		PlayerController(C).ReceiveLocalizedMessage(class'KnockbackConditionMessage', 0);
						C.Pawn.PlaySound(KnockbackSound,,1.5 * C.Pawn.TransientSoundVolume,,C.Pawn.TransientSoundRadius);
					}
				}
			}
		}
		C = NextC;
	}
	Instigator.Controller.Adrenaline -= AdrenalineRequired*AdrenalineUsage;
	if (Instigator.Controller.Adrenaline < 0)
		Instigator.Controller.Adrenaline = 0;
}

exec function TossArtifact()
{
	//do nothing.
}

function DropFrom(vector StartLocation)
{
	if (bActive)
		GotoState('');
	bActive = false;

	Destroy();
	Instigator.NextItem();
}

static function string GetLocalString(optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2)
{
	if (Switch == 3000)
		return "Cannot use this artifact inside a vehicle";
	else
		return switch @ "Adrenaline is required to use this artifact";
}

defaultproperties
{
     AdrenalineRequired=50
     BlastRadius=2500.000000
     MaxKnockbackTime=5.000000
     MaxKnockbackMomentum=3000.000000
     MinKnockbackMomentum=1000.000000
     KnockbackSound=Sound'WeaponSounds.Misc.ballgun_launch'
     KnockbackOverlay=Shader'RedShader'
     CostPerSec=1
     MinActivationTime=0.000001
     PickupClass=Class'fps.ArtifactRepulsionPickup'
     IconMaterial=Texture'XGame.Water.xCausticRing2'
     ItemName="Repulsion"
}