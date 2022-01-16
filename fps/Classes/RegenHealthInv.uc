class RegenHealthInv extends Inventory
	config(fps);

var config int RegenAmount;

function bool HasActiveArtifact()
{
	return class'ActiveArtifactInv'.static.hasActiveArtifact(Instigator);
}

function Timer()
{
	if (Instigator == None || Instigator.Health <= 0)
	{
		Destroy();
		return;
	}

	Instigator.GiveHealth(RegenAmount, Instigator.HealthMax);
}

defaultproperties
{
     RegenAmount=1
     RemoteRole=ROLE_DumbProxy
}
