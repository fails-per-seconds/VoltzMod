class BTClient_Ghost extends xPawn
	config(ClientBTimes);

var Shader S, HeadS;
var FadeColor FC;

var() globalconfig color FadeColor1, FadeColor2;

simulated function TickFX( float DeltaTime )
{
	if (Skins[0] == S && Skins[1] == HeadS)
		return;

	RemoveSkins();

	FC = FadeColor(Level.ObjectPool.AllocateObject(Class'FadeColor'));
	FC.Color1 = FadeColor1;
	FC.Color2 = FadeColor2;
	FC.FadePeriod = 0.33f;
	FC.FadePhase = 0.0f;
	FC.ColorFadeType = FC_Sinusoidal;

	S = Shader(Level.ObjectPool.AllocateObject(Class'Shader'));
	S.Specular = FC;
	S.OutputBlending = OB_Brighten;

	if (Skins[0].IsA('Shader'))
		S.Diffuse = Shader(Skins[0]).Diffuse;
	else
		S.Diffuse = Skins[0];

	Skins[0] = S;

	HeadS = Shader(Level.ObjectPool.AllocateObject(Class'Shader'));
	HeadS.Specular = FC;
	HeadS.OutputBlending = OB_Brighten;

	if (Skins[1].IsA('Shader'))
		HeadS.Diffuse = Shader(Skins[1]).Diffuse;
	else
		HeadS.Diffuse = Skins[1];

	Skins[1] = HeadS;
}

simulated function RemoveSkins()
{
	if (S != none)
	{
		S.OutputBlending = S.Default.OutputBlending;
		S.Specular = S.Default.Specular;
		S.Diffuse = S.Default.Diffuse;
		Level.ObjectPool.FreeObject(S);
		S = none;
	}

	if (HeadS != none)
	{
		HeadS.OutputBlending = HeadS.Default.OutputBlending;
		HeadS.Specular = HeadS.Default.Specular;
		HeadS.Diffuse = HeadS.Default.Diffuse;
		Level.ObjectPool.FreeObject(HeadS);
		HeadS = none;
	}

	if (FC != none)
	{
		FC.Color1 = FC.Default.Color1;
		FC.Color2 = FC.Default.Color2;
		FC.FadePeriod = FC.Default.FadePeriod;
		FC.FadePhase = FC.Default.FadePhase;
		Level.ObjectPool.FreeObject(FC);
		FC = none;
	}
}

simulated function Destroyed()
{
	Super.Destroyed();
	if (Level.NetMode != NM_DedicatedServer)
		RemoveSkins();
}

function bool IsInPain()
{
	return false;
}

event Landed(vector v)
{
	SetPhysics( PHYS_Walking );
}

simulated function PostRender2D( Canvas C, float ScreenLocX, float ScreenLocY );
function AddVelocity( vector NewVelocity);
function GiveWeapon(string aClassName );
function AddDefaultInventory();
function CreateInventory(string InventoryClassName);
simulated function FootStepping(int Side);

simulated function TurnOff();
function TakeDamage(int Damage, Pawn instigatedBy, Vector hitlocation, Vector momentum, class<DamageType> damageType);
simulated function ChunkUp( Rotator HitRotation, float ChunkPerterbation );

function Suicide();
function Reset();
event FellOutOfWorld(eKillZType KillType);

simulated function bool IsPlayerPawn()
{
	return true;
}

state TimingOut
{
	function BeginState()
	{
		SetPhysics(PHYS_None);
		SetCollision(false,false,false);
		LifeSpan = 1.0;
		if (Controller != None)
			Controller.PawnDied(self);
	}
}

state Dying
{
	function BeginState()
	{
		local int i;

		SetCollision(true,false,false);
		if (bTearOff && (Level.NetMode == NM_DedicatedServer))
			LifeSpan = 1.0;
		else
			SetTimer(2.0, false);

		SetPhysics(PHYS_Falling);
		bInvulnerableBody = true;
		if (Controller != None)
			Controller.PawnDied(self);

		for (i = 0; i < Attached.length; i++)
			if (Attached[i] != None)
				Attached[i].PawnBaseDied();
	}
}

defaultproperties
{
     FadeColor1=(B=30,A=255)
     FadeColor2=(A=255)
     GruntVolume=0.000000
     FootstepVolume=0.000000
     RagImpactVolume=0.000000
     bIgnoreForces=True
     bNoVelocityUpdate=True
     bCanWalkOffLedges=True
     bSimGravityDisabled=True
     bServerMoveSetPawnRot=False
     bCanPickupInventory=False
     bAmbientCreature=True
     bScriptPostRender=True
     bAcceptsProjectors=False
     AmbientGlow=60
     bCanTeleport=False
     TransientSoundVolume=0.000000
     bProjTarget=False
     bBlockZeroExtentTraces=False
     bIgnoreOutOfWorld=True
     bIgnoreTerminalVelocity=True
}
