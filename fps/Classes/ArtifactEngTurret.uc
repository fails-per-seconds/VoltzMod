class ArtifactEngTurret extends Summonifact
	config(fps);

function bool SpawnIt(TranslocatorBeacon Beacon, Pawn P, EngineerPointsInv epi)
{
	local Vehicle NewTurret;
	local AutoGunController AGC;
	local Vector SpawnLoc,SpawnLocCeiling;
	local rotator SpawnRotation;

	SpawnLoc = epi.GetSpawnHeight(Beacon.Location);
	if (ClassIsChildOf(SummonItem,class'AutoGun'))
	{
		SpawnLocCeiling = epi.FindCeiling(Beacon.Location);
		if (SpawnLocCeiling != vect(0,0,0) && (SpawnLoc == vect(0,0,0) || VSize(SpawnLocCeiling - Beacon.Location) < VSize(SpawnLoc - Beacon.Location)))
		{
			SpawnLoc = SpawnLocCeiling;
			SpawnLoc.z -= 36;
			if (!CheckSpace(SpawnLoc,80,-100))
			{
				Instigator.ReceiveLocalizedMessage(MessageClass, 6000, None, None, Class);
				bActive = false;
				GotoState('');
				return false;
			}

			SpawnRotation.Yaw = rotator(SpawnLoc - Instigator.Location).Yaw;
			SpawnRotation.Roll = 32768;
			NewTurret = epi.SummonRotatedTurret(SummonItem, Points, P, SpawnLoc,SpawnRotation);
		}
		else
		{
			if (SpawnLoc == vect(0,0,0))
			{
				Instigator.ReceiveLocalizedMessage(MessageClass, 4000, None, None, Class);
				bActive = false;
				GotoState('');
				return false;
			}
			SpawnLoc.z += 36;
			if (!CheckSpace(SpawnLoc,80,100))
			{
				Instigator.ReceiveLocalizedMessage(MessageClass, 6000, None, None, Class);
				bActive = false;
				GotoState('');
				return false;
			}

			NewTurret = epi.SummonTurret(SummonItem, Points, P, SpawnLoc);
		}

		if (NewTurret == None)
			return false;

		AGC = spawn(class'AutoGunController');
		if (AGC != None)
		{
			AGC.SetPlayerSpawner(Instigator.Controller);
			AGC.Possess(NewTurret);
		}
	}
	else
	{
		if (SpawnLoc == vect(0,0,0))
		{
			Instigator.ReceiveLocalizedMessage(MessageClass, 4000, None, None, Class);
			bActive = false;
			GotoState('');
			return false;
		}

		SpawnLoc.z += 30;
		if (!CheckSpace(SpawnLoc,220,200))
		{
			Instigator.ReceiveLocalizedMessage(MessageClass, 6000, None, None, Class);
			bActive = false;
			GotoState('');
			return false;
		}

		if (ClassIsChildOf(SummonItem,class'ASTurret_Minigun'))
			SpawnLoc.z += 20;
		else if (ClassIsChildOf(SummonItem,class'xEnergyTurret'))
			SpawnLoc.z += 40;
		else if (ClassIsChildOf(SummonItem,class'xIonCannon'))
			SpawnLoc.z += 60;
		else
			SpawnLoc.z += 50;

		NewTurret = epi.SummonTurret(SummonItem, Points, P, SpawnLoc);
		if (NewTurret == None)
			return false;

		NewTurret.AutoTurretControllerClass = None;

		if (xMinigunTurret(NewTurret) != None)
			xMinigunTurret(NewTurret).SetPlayerSpawner(Instigator.Controller);
		else if (xLinkTurret(NewTurret) != None)
			xLinkTurret(NewTurret).SetPlayerSpawner(Instigator.Controller);
		else if (xBallTurret(NewTurret) != None)
			xBallTurret(NewTurret).SetPlayerSpawner(Instigator.Controller);
		else if (xEnergyTurret(NewTurret) != None)
			xEnergyTurret(NewTurret).SetPlayerSpawner(Instigator.Controller);
		else if (xIonCannon(NewTurret) != None)
			xIonCannon(NewTurret).SetPlayerSpawner(Instigator.Controller);
	}

	SetStartHealth(NewTurret);

	ApplyStatsToConstruction(NewTurret,Instigator);

	return true;
}

function BotConsider()
{
	return;
}

defaultproperties
{
     IconMaterial=Texture'ArtifactIcons.SummonTurretIcon'
     ItemName=""
}
