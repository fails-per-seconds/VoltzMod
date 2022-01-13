class ArtifactEngVehicle extends Summonifact
	config(fps);

function bool SpawnIt(TranslocatorBeacon Beacon, Pawn P, EngineerPointsInv epi)
{
	local Vehicle NewVehicle;
	local Vector SpawnLoc;

	SpawnLoc = Beacon.Location;
	SpawnLoc.z += 30;
	if (!CheckSpace(SpawnLoc,700,400))
	{
		Instigator.ReceiveLocalizedMessage(MessageClass, 6000, None, None, Class);
		bActive = false;
		GotoState('');
		return false;
	}
	NewVehicle = epi.SummonVehicle(SummonItem, Points, P, SpawnLoc);
	if (NewVehicle == None)
		return false;
		
	if (xGoliath(NewVehicle) != None)
		xGoliath(NewVehicle).SetPlayerSpawner(Instigator.Controller);
	else if (xHellBender(NewVehicle) != None)
		xHellBender(NewVehicle).SetPlayerSpawner(Instigator.Controller);
	else if (xScorpion(NewVehicle) != None)
		xScorpion(NewVehicle).SetPlayerSpawner(Instigator.Controller);
	else if (xPaladin(NewVehicle) != None)
		xPaladin(NewVehicle).SetPlayerSpawner(Instigator.Controller);
	else if (xManta(NewVehicle) != None)
		xManta(NewVehicle).SetPlayerSpawner(Instigator.Controller);
	else if (xIonTank(NewVehicle) != None)
		xIonTank(NewVehicle).SetPlayerSpawner(Instigator.Controller);
	else if (xTC(NewVehicle) != None)
		xTC(NewVehicle).SetPlayerSpawner(Instigator.Controller);

	SetStartHealth(NewVehicle);

	NewVehicle.MomentumMult *= 0.25;

	ApplyStatsToConstruction(NewVehicle,Instigator);

	return true;
}

function BotConsider()
{
	return;
}

defaultproperties
{
     IconMaterial=Texture'ArtifactIcons.SummonVehicleIcon'
     ItemName=""
}
