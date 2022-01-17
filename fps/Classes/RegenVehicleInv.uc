class RegenVehicleInv extends Inventory
	config(fps);

var config int RegenAmount;

function bool HasActiveArtifact()
{
	return class'ActiveArtifactInv'.static.hasActiveArtifact(Instigator);
}

function Timer()
{
	local Vehicle v;

	if (Instigator == None || Instigator.Health <= 0)
	{
		Destroy();
		return;
	}

	if (Instigator.DrivenVehicle == None)
		return;

	v = Instigator.DrivenVehicle;

	if (ONSWeaponPawn(v) != None && ONSWeaponPawn(v).VehicleBase != None && !ONSWeaponPawn(v).bHasOwnHealth)
		v = ONSWeaponPawn(v).VehicleBase;

	v.GiveHealth(RegenAmount, v.HealthMax);
}

defaultproperties
{
     RegenAmount=1
     RemoteRole=ROLE_DumbProxy
}
