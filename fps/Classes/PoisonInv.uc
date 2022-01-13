class PoisonInv extends Inventory;

var Controller InstigatorController;
var Pawn PawnOwner;
var int Modifier;

replication
{
	reliable if (bNetInitial && Role == ROLE_Authority)
		PawnOwner;
}

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();

	if (Instigator != None)
		InstigatorController = Instigator.Controller;

	SetTimer(1, true);
}

function GiveTo(Pawn Other, optional Pickup Pickup)
{
	local Pawn OldInstigator;

	if (InstigatorController == None)
		InstigatorController = Other.DelayedDamageInstigatorController;

	OldInstigator = Instigator;
	Super.GiveTo(Other);
	PawnOwner = Other;
	Instigator = OldInstigator;
}

simulated function Timer()
{
	if (Role == ROLE_Authority)
	{
		if (Owner == None)
		{
			Destroy();
			return;
		}

		if (Instigator == None && InstigatorController != None)
			Instigator = InstigatorController.Pawn;

		PawnOwner.DelayedDamageInstigatorController = InstigatorController;
		PawnOwner.TakeDamage(Modifier * 2, Instigator, PawnOwner.Location, vect(0,0,0), class'DamTypePoison');
	}

	if (Level.NetMode != NM_DedicatedServer && PawnOwner != None)
	{
		PawnOwner.Spawn(class'GoopSmoke');
		if (PawnOwner.IsLocallyControlled() && PlayerController(PawnOwner.Controller) != None)
			PlayerController(PawnOwner.Controller).ReceiveLocalizedMessage(class'PoisonConditionMessage', 0);
	}
}

defaultproperties
{
     bOnlyRelevantToOwner=False
}
