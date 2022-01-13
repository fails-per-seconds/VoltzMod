class FriendlyMonsterKillMarker extends Inventory;

var Controller Killer;
var int Health;
var class<DamageType> DamageType;
var vector HitLocation;

function DropFrom(vector StartLocation)
{
	Destroy();
}

function Tick(float deltaTime)
{
	local Pawn P;

	P = Pawn(Owner);
	if (P != None)
	{
		P.LastHitBy = None;
		P.Health = Health;
		P.Died(Killer, DamageType, HitLocation);
	}

	Destroy();
}

defaultproperties
{
     RemoteRole=ROLE_None
}
