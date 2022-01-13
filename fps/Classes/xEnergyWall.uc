class xEnergyWall extends ASTurret;

var config int DamagePerHit;
var config float DamageFraction;

var int MaxGap, MinGap, Height;
var int origDamage, TotalDamage, TakenDamage, MinDamage, MaxDamage;

var vector P1Loc, P2Loc;
var xEnergyWallPost Post1,Post2;
var() class<Controller> DefaultController;
var() class<xEnergyWallPost> DefaultPost;

var float vScaleY;
var float DamageAdjust;

replication
{
	reliable if (Role == ROLE_Authority)
		vScaleY;
}

simulated event PostBeginPlay()
{
	super.PostBeginPlay();
	
	if (Role == ROLE_Authority)	
	{
		if (AssignPosts())
			DrawWall();
	}

	SetCollision(true,false,false);
}

simulated function PostNetBeginPlay()
{
	super.PostNetBeginPlay();

	if (Role < ROLE_Authority)	
		ClientDrawWall();
}

function bool AssignPosts()
{
	local xEnergyWallPost P;
	
	ForEach DynamicActors(class'xEnergyWallPost',P)
	{
		if (P.wall == None && vsize(P.Location - Location) < default.MaxGap && P.Owner == Owner)
		{
			if (Post1 == None)
			{
				Post1 = P;
				P1Loc = P.Location;
				P.wall = self;
			}
			else if (Post2 == None)
			{
				Post2 = P;
				P2Loc = P.Location;
				P.wall = self;
				return true;
			}
		}
	}
	return false;
}

function DrawWall()
{
	local float wallgap;
	local vector vScale;

	vScale.X = 0.02;
	wallgap = VSize(P1Loc - P2Loc) - 20.0;
	vScale.Y = wallgap/50.0;
	if (vScale.Y < 0.1) vScale.Y = 0.1;
	vScaleY = vScale.Y;
	vScale.Z = Height/25.0;
	SetDrawScale3D(vScale);
}

simulated function ClientDrawWall()
{
	local vector cScale;

	if (Level.NetMode != NM_DedicatedServer)
	{
		cScale.X = 0.1;
		cScale.Y = vScaleY;
		cScale.Z = default.Height/25.0;
		SetDrawScale3D(cScale);
	}	
}

function AddDefaultInventory()
{
	// do nothing.
}

simulated function Destroyed()
{
	if (Post1 != None)
		Post1.Destroy();

	if (Post2 != None)
		Post2.Destroy();

	super.Destroyed();
}

simulated event touch (Actor Other)
{
	local Pawn P;
	local Controller C;
	local Controller PC;
	local int DamageToDo;

	super.touch(Other);

	if (Role < ROLE_Authority)
		return;
		
	P = Pawn(Other);
	if (P == None || P.Health <= 0)
		return;

	if (Controller == None || xEnergyWallController(Controller) == None || xEnergyWallController(Controller).PlayerSpawner == None  || xEnergyWallController(Controller).PlayerSpawner.Pawn == None)
		return; 
	PC = xEnergyWallController(Controller).PlayerSpawner;
	
	if (P == PC.Pawn)
		return;
		
	C = P.Controller;
	if (C == None)
		return;
		
	if (TeamGame(Level.Game) != None && C.SameTeamAs(PC))
		return;

	DamageToDo = DamagePerHit * DamageAdjust * ( 1.0 + (P.HealthMax - 100.0)/200.0);
	DamageToDo = min(max(DamageToDo, MinDamage * DamageAdjust),MaxDamage * DamageAdjust);
	P.TakeDamage(DamageToDo, self, P.Location, vect(0,0,0), class'DamTypeEnergyWall');

}

function TakeDamage(int Damage, Pawn instigatedBy, Vector hitlocation, Vector momentum, class<DamageType> damageType) 
{
	local int ReducedDamage;

	ReducedDamage = float(Damage)*DamageFraction;

	if (ReducedDamage <= 0 && Damage > 0)
		ReducedDamage = 1;
	momentum = vect(0,0,0);
	
	Super.TakeDamage(ReducedDamage, instigatedBy, hitlocation, momentum, damageType);
}

defaultproperties
{
     DamagePerHit=40
     DamageFraction=0.300000
     MaxGap=600
     MinGap=80
     Height=120
     DefaultController=Class'fps.xEnergyWallController'
     DefaultPost=Class'fps.xEnergyWallPost'
     MinDamage=10
     MaxDamage=150
     DamageAdjust=1.000000
     bNonHumanControl=True
     AutoTurretControllerClass=None
     VehicleNameString="Energy Wall"
     bCanBeBaseForPawns=False
     HealthMax=2000.000000
     Health=2000
     ControllerClass=None
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'Block.TestBlock'
     bReplicateMovement=False
     DrawScale=0.500000
     Skins(0)=FinalBlend'AW-ShieldShaders.Shaders.RedShieldFinal'
     Skins(1)=FinalBlend'AW-ShieldShaders.Shaders.RedShieldFinal'
     AmbientGlow=10
     bMovable=False
     bBlockActors=False
     bBlockKarma=False
     Mass=1000.000000
}
