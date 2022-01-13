class KillMarker extends Inventory;

function DropFrom(vector StartLocation)
{
	Destroy();
}

defaultproperties
{
     RemoteRole=ROLE_DumbProxy
}
