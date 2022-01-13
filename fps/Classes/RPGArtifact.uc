class RPGArtifact extends Powerups;

var int CostPerSec;
var float ActivatedTime, MinActivationTime;
var localized string NotEnoughAdrenalineMessage;

replication
{
	reliable if (Role < ROLE_Authority)
		TossArtifact;
}

static function bool ArtifactIsAllowed(GameInfo Game)
{
	return true;
}

function OwnerEvent(name EventName)
{
	if (EventName == 'ChangedWeapon' && AIController(Instigator.Controller) != None)
		BotConsider();

	Super.OwnerEvent(EventName);
}

function BotConsider();

simulated function bool NoArtifactsActive()
{
	local Inventory Inv;
	local int Count;

	for (Inv = Instigator.Inventory; Inv != None; Inv = Inv.Inventory)
	{
		if (RPGArtifact(Inv) != None && RPGArtifact(Inv).bActive)
			return false;
		Count++;
		if (Count > 1000)
			break;
	}

	return true;
}

function bool HandlePickupQuery(Pickup Item)
{
	if (item.InventoryType == class)
	{
		if (bCanHaveMultipleCopies)
			NumCopies++;
		else if (bDisplayableInv)
		{
			if (Item.Inventory != None)
				Charge = Max(Charge, Item.Inventory.Charge);
			else
				Charge = Max(Charge, Item.InventoryType.Default.Charge);
		}
		else
			return false;

		Item.AnnouncePickup(Pawn(Owner));
		Item.SetRespawn();
		return true;
	}
	if (Inventory == None)
		return false;

	return Inventory.HandlePickupQuery(Item);
}

exec function TossArtifact()
{
	local vector X, Y, Z;

	Instigator.NextItem();
	Velocity = Vector(Instigator.Controller.GetViewRotation());
	Velocity = Velocity * ((Instigator.Velocity Dot Velocity) + 500) + Vect(0,0,200);
	GetAxes(Instigator.Rotation, X, Y, Z);
	DropFrom(Instigator.Location + 0.8 * Instigator.CollisionRadius * X - 0.5 * Instigator.CollisionRadius * Y);
}

function DropFrom(vector StartLocation)
{
	if (bActive)
		GotoState('');

	Super.DropFrom(StartLocation);
}

function UsedUp()
{
	if (Pawn(Owner) != None)
	{
		Activate();
		Instigator.ReceiveLocalizedMessage(MessageClass, 0, None, None, Class);
	}
	Owner.PlaySound(DeactivateSound,SLOT_Interface);
}

function Activate()
{
	if (bActivatable && Instigator.Controller != None)
	{
		if (bActive && Level.TimeSeconds > ActivatedTime + MinActivationTime)
			GotoState('');
		else if (!bActive)
		{
			if (Instigator.Controller.Adrenaline >= CostPerSec * MinActivationTime)
			{
				ActivatedTime = Level.TimeSeconds;
				GotoState('Activated');
			}
			else
				Instigator.ReceiveLocalizedMessage(MessageClass, 1, None, None, Class);
		}
	}
}

static function string GetLocalString(optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2)
{
	if (Switch == 1)
		return Default.NotEnoughAdrenalineMessage;

	return Super.GetLocalString(Switch, RelatedPRI_1, RelatedPRI_2);
}

simulated function Tick(float deltaTime)
{
	if (bActive)
	{
		Instigator.Controller.Adrenaline -= deltaTime * CostPerSec;
		if (Instigator.Controller.Adrenaline <= 0.0)
		{
			Instigator.Controller.Adrenaline = 0.0;
			UsedUp();
		}
	}
}

defaultproperties
{
     MinActivationTime=2.000000
     NotEnoughAdrenalineMessage="You do not have enough adrenaline to activate this artifact."
     bCanHaveMultipleCopies=True
     bActivatable=True
     ExpireMessage="Your adrenaline has run out."
     bDisplayableInv=True
     bReplicateInstigator=True
     MessageClass=Class'UnrealGame.StringMessagePlus'
}
