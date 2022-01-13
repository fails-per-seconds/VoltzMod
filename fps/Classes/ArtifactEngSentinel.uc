class ArtifactEngSentinel extends Summonifact
	config(fps);

function bool SpawnIt(TranslocatorBeacon Beacon, Pawn P, EngineerPointsInv epi)
{
	local ASTurret NewSentinel;
	local xSentinelController DSC;
	local xSentinelBaseController DBSC;
	local xLightningSentinelController DLC;
	local xDefenseSentinelController DDC;
	local xLinkSentinelController DLSC;
	local AutoGunController AGC;
	local Vector SpawnLoc, SpawnLocCeiling;
	local bool bGotSpace, bOnCeiling;
	local class<Pawn> RealSummonItem;
	local rotator SpawnRotation;

	if (ClassIsChildOf(SummonItem,class'xEnergyWall'))
		return SpawnEnergyWall(Beacon, P, epi);

	RealSummonItem = SummonItem;
	SpawnLoc = epi.GetSpawnHeight(Beacon.Location);
	bOnCeiling = false;
	if (ClassIsChildOf(SummonItem,class'AutoGun'))
	{
		SpawnLocCeiling = epi.FindCeiling(Beacon.Location);
		if (SpawnLocCeiling != vect(0,0,0) && (SpawnLoc == vect(0,0,0) || VSize(SpawnLocCeiling - Beacon.Location) < VSize(SpawnLoc - Beacon.Location)))
		{
			bOnCeiling = true;
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
			NewSentinel = epi.SummonRotatedSentinel(SummonItem, Points, P, SpawnLoc,SpawnRotation);
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

			NewSentinel = epi.SummonBaseSentinel(SummonItem, Points, P, SpawnLoc);
		}

		if (NewSentinel == None)
			return false;

		AGC = spawn(class'AutoGunController');
		if (AGC != None)
		{
			AGC.SetPlayerSpawner(Instigator.Controller);
			AGC.Possess(NewSentinel);
		}

		SetStartHealth(NewSentinel);

		ApplyStatsToConstruction(NewSentinel,Instigator);

		return true;
	}

	bGotSpace = CheckSpace(SpawnLoc,150,180);
	if (ClassIsChildOf(SummonItem,class'xSentinel') || ClassIsChildOf(SummonItem,class'xDefenseSentinel')
		 || ClassIsChildOf(SummonItem,class'xLightningSentinel') || ClassIsChildOf(SummonItem,class'xLinkSentinel'))
	{
		SpawnLocCeiling = epi.FindCeiling(Beacon.Location);
		if (SpawnLocCeiling != vect(0,0,0) && (SpawnLoc == vect(0,0,0) || VSize(SpawnLocCeiling - Beacon.Location) < VSize(SpawnLoc - Beacon.Location)))
		{
			bOnCeiling = true;
			if (ClassIsChildOf(SummonItem,class'xSentinel'))
				RealSummonItem = class'xCeilingSentinel';
			else if (ClassIsChildOf(SummonItem,class'xDefenseSentinel'))
				RealSummonItem = class'xCeilingDefenseSentinel';
			else if (ClassIsChildOf(SummonItem,class'xLightningSentinel'))
				RealSummonItem = class'xCeilingLightningSentinel';		
			SpawnLoc = SpawnLocCeiling;
			bGotSpace = CheckSpace(SpawnLoc,120,-160);
		}
	}

	if (SpawnLoc == vect(0,0,0))
	{
		Instigator.ReceiveLocalizedMessage(MessageClass, 4000, None, None, Class);
		bActive = false;
		GotoState('');
		return false;
	}
	if (!bGotSpace)
	{
		Instigator.ReceiveLocalizedMessage(MessageClass, 6000, None, None, Class);
		bActive = false;
		GotoState('');
		return false;
	}

	if (ClassIsChildOf(RealSummonItem,class'ASVehicle_Sentinel_Floor'))
	{
		SpawnLoc.z += 65;
		NewSentinel = epi.SummonBaseSentinel(RealSummonItem, Points, P, SpawnLoc);
		if (NewSentinel == None)
			return false;
		SetStartHealth(NewSentinel);

		if (Role == Role_Authority)
		{
			DSC = spawn(class'xSentinelController');
			if (DSC != None)
			{
				DSC.SetPlayerSpawner(Instigator.Controller);
				DSC.Possess(NewSentinel);
				DSC.DamageAdjust = epi.SentinelDamageAdjust;

				ApplyStatsToConstruction(NewSentinel,Instigator);
			}
		}
	}
	else if (ClassIsChildOf(RealSummonItem,class'ASVehicle_Sentinel_Ceiling'))
	{
		SpawnLoc.z -= 80;
		NewSentinel = epi.SummonBaseSentinel(RealSummonItem, Points, P, SpawnLoc);
		if (NewSentinel == None)
			return false;
		SetStartHealth(NewSentinel);

		if (Role == Role_Authority)
		{
			DSC = spawn(class'xSentinelController');
			if (DSC != None)
			{
				DSC.SetPlayerSpawner(Instigator.Controller);
				DSC.Possess(NewSentinel);
				DSC.DamageAdjust = epi.SentinelDamageAdjust;

				ApplyStatsToConstruction(NewSentinel,Instigator);
			}
		}
	}
	else if (ClassIsChildOf(RealSummonItem,class'xLightningSentinel'))
	{
		SpawnLoc.z += 30;
		NewSentinel = epi.SummonBaseSentinel(RealSummonItem, Points, P, SpawnLoc);
		if (NewSentinel == None)
			return false;
		SetStartHealth(NewSentinel);

		if (Role == Role_Authority)
		{
			DLC = spawn(class'xLightningSentinelController');
			if (DLC != None)
			{
				DLC.SetPlayerSpawner(Instigator.Controller);
				DLC.Possess(NewSentinel);
				DLC.DamageAdjust = epi.SentinelDamageAdjust;

				ApplyStatsToConstruction(NewSentinel,Instigator);
			}
		}
	}
	else if (ClassIsChildOf(RealSummonItem,class'xCeilingLightningSentinel'))
	{
		SpawnLoc.z -= 80;
		NewSentinel = epi.SummonBaseSentinel(RealSummonItem, Points, P, SpawnLoc);
		if (NewSentinel == None)
			return false;
		SetStartHealth(NewSentinel);

		if (Role == Role_Authority)
		{
			DLC = spawn(class'xLightningSentinelController');
			if (DLC != None)
			{
				DLC.SetPlayerSpawner(Instigator.Controller);
				DLC.Possess(NewSentinel);
				DLC.DamageAdjust = epi.SentinelDamageAdjust;

				ApplyStatsToConstruction(NewSentinel,Instigator);
			}
		}
	}
	else if (ClassIsChildOf(RealSummonItem,class'xCeilingDefenseSentinel'))
	{
		SpawnLoc.z -= 80;
		NewSentinel = epi.SummonBaseSentinel(RealSummonItem, Points, P, SpawnLoc);
		if (NewSentinel == None)
			return false;
		SetStartHealth(NewSentinel);

		if (Role == Role_Authority)
		{
			DDC = spawn(class'xDefenseSentinelController');
			if (DDC != None)
			{
				DDC.DamageAdjust = epi.SentinelDamageAdjust;
				DDC.SetPlayerSpawner(Instigator.Controller);
				DDC.Possess(NewSentinel);

				ApplyStatsToConstruction(NewSentinel,Instigator);
			}
		}
	}
	else if (ClassIsChildOf(RealSummonItem,class'xDefenseSentinel'))
	{
		SpawnLoc.z += 30;
		NewSentinel = epi.SummonBaseSentinel(RealSummonItem, Points, P, SpawnLoc);
		if (NewSentinel == None)
			return false;
		SetStartHealth(NewSentinel);

		if (Role == Role_Authority)
		{
			DDC = spawn(class'xDefenseSentinelController');
			if (DDC != None)
			{
				DDC.DamageAdjust = epi.SentinelDamageAdjust;
				DDC.SetPlayerSpawner(Instigator.Controller);
				DDC.Possess(NewSentinel);

				ApplyStatsToConstruction(NewSentinel,Instigator);
			}
		}
	}
	else if (ClassIsChildOf(SummonItem,class'xLinkSentinel'))
	{
		if (bOnCeiling)
		{
			SpawnLoc.z -= 70;
			SpawnRotation.Yaw = 0;
			SpawnRotation.Roll = 32768;
			NewSentinel = epi.SummonRotatedSentinel(SummonItem, Points, P, SpawnLoc,SpawnRotation);
		}
		else
		{
			SpawnLoc.z += 67;
			SpawnRotation.Yaw = 32768;
			NewSentinel =  epi.SummonRotatedSentinel(SummonItem, Points, P, SpawnLoc,SpawnRotation);
		}
		if (NewSentinel == None)
			return false;
		SetStartHealth(NewSentinel);

		if (Role == Role_Authority)
		{
			DLSC = spawn(class'xLinkSentinelController');
			if (DLSC != None)
			{
				DLSC.SetPlayerSpawner(Instigator.Controller);
				DLSC.Possess(NewSentinel);

				ApplyStatsToConstruction(NewSentinel,Instigator);
			}
		}
	}
	else
	{
		SpawnLoc.z += 60;
		NewSentinel = epi.SummonBaseSentinel(RealSummonItem, Points, P, SpawnLoc);
		if (NewSentinel == None)
			return false;
		SetStartHealth(NewSentinel);

		if (Role == Role_Authority)
		{
			DBSC = spawn(class'xSentinelBaseController');
			if (DBSC != None)
			{
				DBSC.SetPlayerSpawner(Instigator.Controller);
				DBSC.Possess(NewSentinel);

				ApplyStatsToConstruction(NewSentinel,Instigator);
			}
		}
	} 

	return true;
}

function bool SpawnEnergyWall(TranslocatorBeacon Beacon, Pawn P, EngineerPointsInv epi)
{
	local xEnergyWall NewEnergyWall;
	local xEnergyWallController EWC;
	local Actor A;
	local vector HitLocation, HitNormal;
	local vector Post1SpawnLoc, Post2SpawnLoc, SpawnLoc; 
	local vector Normalvect, XVect, YVect, ZVect;
	local class<xEnergyWall> WallSummonItem;

	WallSummonItem = class<xEnergyWall>(SummonItem);
	if (WallSummonItem == None)
	{
		bActive = false;
		GotoState('');
		return false;
	}

	SpawnLoc = epi.GetSpawnHeight(Beacon.Location);
	SpawnLoc.z += 20 + (WallSummonItem.default.Height/2);

	NormalVect = Normal(SpawnLoc-Instigator.Location);
	NormalVect.Z = 0;
	YVect = NormalVect;
	ZVect = vect(0,0,1);
	XVect = Normal(YVect cross ZVect);

	if (!FastTrace(SpawnLoc, SpawnLoc + (ZVect*WallSummonItem.default.Height)))
	{
		Instigator.ReceiveLocalizedMessage(MessageClass, 6000, None, None, Class);
		bActive = false;
		GotoState('');
		return false;
	}

	A = Trace(HitLocation, HitNormal, SpawnLoc + (XVect*WallSummonItem.default.MaxGap*0.5), SpawnLoc, true,, );
	if (A == None)
		Post1SpawnLoc = SpawnLoc + (XVect*WallSummonItem.default.MaxGap*0.5);
	else
		Post1SpawnLoc = HitLocation - 20*XVect;

	A = None;
	A = Trace(HitLocation, HitNormal, SpawnLoc - (XVect*WallSummonItem.default.MaxGap*0.5), SpawnLoc, true,, );
	if (A == None)
		Post2SpawnLoc = SpawnLoc - (XVect*WallSummonItem.default.MaxGap*0.5);
	else
		Post2SpawnLoc = HitLocation + 20*XVect;

	if ((Post1SpawnLoc == vect(0,0,0)) || (Post2SpawnLoc == vect(0,0,0)) || VSize(Post1SpawnLoc - Post2SpawnLoc) > WallSummonItem.default.MaxGap  || VSize(Post1SpawnLoc - Post2SpawnLoc) < WallSummonItem.default.MinGap)
	{
		Instigator.ReceiveLocalizedMessage(MessageClass, 4000, None, None, Class);
		bActive = false;
		GotoState('');
		return false;
	}

	NewEnergyWall = epi.SummonEnergyWall(WallSummonItem, Points, P, SpawnLoc, Post1SpawnLoc, Post2SpawnLoc);
	if (NewEnergyWall == None)
		return false;
	SetStartHealth(NewEnergyWall);
	NewEnergyWall.DamageAdjust = epi.SentinelDamageAdjust;

	if (Role == Role_Authority)
	{
		EWC = xEnergyWallController(spawn(NewEnergyWall.default.DefaultController));
		if (EWC != None)
		{
			EWC.SetPlayerSpawner(Instigator.Controller);
			EWC.Possess(NewEnergyWall);

			ApplyStatsToConstruction(NewEnergyWall,Instigator);
		}
	}
	return true;
}

defaultproperties
{
     IconMaterial=Texture'ArtifactIcons.SummonTurretIcon'
     ItemName=""
}
