class RPGKeysInteraction extends RPGInteraction
	config(fps);

#exec new TrueTypeFontFactory Name=NewFont FontName="NewFont" Height=8 CharactersPerPage=32

var GiveItemsInv GiveItemsInv;

struct ArtifactKeyConfig
{
	var string Alias;
	var class<RPGArtifact> ArtifactClass;
};
var Array<ArtifactKeyConfig> ArtifactKeyConfigs;

var int dummyi;
var Material HealthBarMaterial;
var float BarUSize, BarVSize;
var Color RedColor, GreenColor, BlueColor, YellowColor;
var localized string PointsText, EngineerPointsText, AdrenalineText, MonsterPointsText;

var EngineerPointsInv EInv;
var MonsterPointsInv MInv;

var AwarenessEnemyList EnemyList;

event Initialized()
{
	BarUSize = HealthBarMaterial.MaterialUSize();
	BarVSize = HealthBarMaterial.MaterialVSize();
	EnemyList = ViewportOwner.Actor.Spawn(class'AwarenessEnemyList');
	Super.Initialized();
}

event NotifyLevelChange()
{
	if (EnemyList != None)
	{
		EnemyList.Destroy();
		EnemyList = None;
	}

	EInv = None;
	MInv = None;
	GiveItemsInv = None;

	Super.NotifyLevelChange();
}

function FindGiveItemsInv()
{
	local Inventory Inv;
	local GiveItemsInv FoundGiveItemsInv;

	for (Inv = ViewportOwner.Actor.Inventory; Inv != None; Inv = Inv.Inventory)
	{
		GiveItemsInv = GiveItemsInv(Inv);
		if (GiveItemsInv != None)
			return;
		else
		{
			if (Inv.Inventory == Inv)
			{
				Inv.Inventory = None;
				foreach ViewportOwner.Actor.DynamicActors(class'GiveItemsInv', FoundGiveItemsInv)
				{
					if (FoundGiveItemsInv.Owner == ViewportOwner.Actor || FoundGiveItemsInv.Owner == ViewportOwner.Actor.Pawn)
					{
						GiveItemsInv = FoundGiveItemsInv;
						Inv.Inventory = GiveItemsInv;
						break;
					}
				}
				return;
			}
		}
	}

	ForEach ViewportOwner.Actor.DynamicActors(class'GiveItemsInv',FoundGiveItemsInv)
	{
		if (FoundGiveItemsInv.Owner == ViewportOwner.Actor || FoundGiveItemsInv.Owner == ViewportOwner.Actor.Pawn)
		{
			if(GiveItemsInv == None)
			{
				GiveItemsInv = FoundGiveItemsInv;
				Log("RPGKeysInteraction found a GiveItemsInv in DynamicActors search");
			}
			else
			{
				if (FoundGiveItemsInv.Owner == None)
					Log("RPGKeysInteraction found an additional GiveItemsInv in DynamicActors search with owner None. ViewportOwner.Actor also None");
				else
					Log("RPGKeysInteraction found an additional GiveItemsInv in DynamicActors search that belonged to me");
			}
		}
		else
			Log("*RPGKeysInteraction found a GiveItemsInv, but not mine.");
	}

}

function FindEPInv()
{
	local Inventory Inv;
	local EngineerPointsInv FoundEInv;

	for (Inv = ViewportOwner.Actor.Inventory; Inv != None; Inv = Inv.Inventory)
	{
		FoundEInv = EngineerPointsInv(Inv);
		if (FoundEInv != None)
		{
			if (FoundEInv.Owner == ViewportOwner.Actor || FoundEInv.Owner == ViewportOwner.Actor.Pawn)
				EInv = FoundEInv;
			return;
		}
		else
		{
			if (Inv.Inventory == Inv)
			{
				Inv.Inventory = None;
				foreach ViewportOwner.Actor.DynamicActors(class'EngineerPointsInv', FoundEInv)
				{
					if (FoundEInv.Owner == ViewportOwner.Actor || FoundEInv.Owner == ViewportOwner.Actor.Pawn)
					{
						EInv = FoundEInv;
						Inv.Inventory = EInv;
						break;
					}
				}
				return;
			}
		}
	}
}

function FindMPInv()
{
	local Inventory Inv;
	local MonsterPointsInv FoundMInv;

	for (Inv = ViewportOwner.Actor.Inventory; Inv != None; Inv = Inv.Inventory)
	{
		FoundMInv = MonsterPointsInv(Inv);
		if (FoundMInv != None)
		{
			if (FoundMInv.Owner == ViewportOwner.Actor || FoundMInv.Owner == ViewportOwner.Actor.Pawn)
				MInv = FoundMInv;
			return;
		}
		else
		{
			if (Inv.Inventory == Inv)
			{
				Inv.Inventory = None;
				foreach ViewportOwner.Actor.DynamicActors(class'MonsterPointsInv', FoundMInv)
				{
					if (FoundMInv.Owner == ViewportOwner.Actor || FoundMInv.Owner == ViewportOwner.Actor.Pawn)
					{
						MInv = FoundMInv;
						Inv.Inventory = MInv;
						break;
					}
				}
				return;
			}
		}
	}
}

function bool KeyEvent(EInputKey Key, EInputAction Action, float Delta)
{
	local string tmp;
	local Pawn P;

	if (Action != IST_Press)
		return false;

	tmp = ViewportOwner.Actor.ConsoleCommand("KEYBINDING"@ViewportOwner.Actor.ConsoleCommand("KEYNAME"@Key));

	if (ViewportOwner.Actor.Pawn != None)
	{
		P = ViewportOwner.Actor.Pawn;
		if (tmp ~= "DropHealth") 
		{
			class'GiveItemsInv'.static.DropHealth(P.Controller);
			return true;
		}
		if (tmp ~= "DropAdrenaline") 
		{
			class'GiveItemsInv'.static.DropAdrenaline(P.Controller);
			return true;
		}
		if (tmp ~= "AttackEnemy") 
		{
			class'MonsterPointsInv'.static.AttackEnemy(P);
			return true;
		}
		else if (tmp ~= "Follow") 
		{
			class'MonsterPointsInv'.static.PetFollow(P);
			return true;
		}
		else if (tmp ~= "Stay") 
		{
			class'MonsterPointsInv'.static.PetStay(P);
			return true;
		}
		else if (tmp ~= "Lock")
		{
			class'EngineerPointsInv'.static.LockVehicle(P);
			return true;
		}
		else if (tmp ~= "Unlock")
		{
			class'EngineerPointsInv'.static.UnlockVehicle(P);
			return true;
		}
	}

	if (tmp ~= "rpgstatsmenu" || (bDefaultBindings && Key == IK_L))
	{
		if (StatsInv == None)
			FindStatsInv();
		if (StatsInv == None)
			return false;
			
		if (GiveItemsInv == None && ViewportOwner.Actor.Pawn != None && ViewportOwner.Actor.Pawn.Controller != None)
			GiveItemsInv = class'GiveItemsInv'.static.GetGiveItemsInv(ViewportOwner.Actor.Pawn.Controller);
	
		if (GiveItemsInv == None)
			FindGiveItemsInv();

		if (GiveItemsInv == None)
			return true;

		ViewportOwner.GUIController.OpenMenu(string(class'RPGStatsMenuX'));
		RPGStatsMenuX(GUIController(ViewportOwner.GUIController).TopPage()).InitFor2(StatsInv,GiveItemsInv);
		LevelMessagePointThreshold = StatsInv.Data.PointsAvailable;
		return true;
	}

	return Super.KeyEvent(Key, Action, Delta);
}

exec function SelectTriple()
{
	SelectThisArtifact("SelectTriple");
}

exec function SelectGlobe()
{
	SelectThisArtifact("SelectGlobe");
}

exec function SelectMWM()
{
	SelectThisArtifact("SelectMWM");
}

exec function SelectDouble()
{
	SelectThisArtifact("SelectDouble");
}

exec function SelectMax()
{
	SelectThisArtifact("SelectMax");
}

exec function SelectPlusOne()
{
	SelectThisArtifact("SelectPlusOne");
}

exec function SelectBolt()
{
	SelectThisArtifact("SelectBolt");
}

exec function SelectRepulsion()
{
	SelectThisArtifact("SelectRepulsion");
}

exec function SelectFreezeBomb()
{
	SelectThisArtifact("SelectFreezeBomb");
}

exec function SelectPoisonBlast()
{
	SelectThisArtifact("SelectPoisonBlast");
}

exec function SelectMegaBlast()
{
	SelectThisArtifact("SelectMegaBlast");
}

exec function SelectHealingBlast()
{
	SelectThisArtifact("SelectHealingBlast");
}

exec function SelectMedic()
{
	SelectThisArtifact("SelectMedic");
}

exec function SelectFlight()
{
	SelectThisArtifact("SelectFlight");
}

exec function SelectMagnet()
{
	SelectThisArtifact("SelectMagnet");
}

exec function SelectTeleport()
{
	SelectThisArtifact("SelectTeleport");
}

exec function SelectBeam()
{
	SelectThisArtifact("SelectBeam");
}

exec function SelectRod()
{
	SelectThisArtifact("SelectRod");
}

exec function SelectSphereInv()
{
	SelectThisArtifact("SelectSphereInv");
}

exec function SelectSphereHeal()
{
	SelectThisArtifact("SelectSphereHeal");
}

exec function SelectSphereDamage()
{
	SelectThisArtifact("SelectSphereDamage");
}

exec function SelectRemoteDamage()
{
	SelectThisArtifact("SelectRemoteDamage");
}

exec function SelectRemoteInv()
{
	SelectThisArtifact("SelectRemoteInv");
}

exec function SelectRemoteMax()
{
	SelectThisArtifact("SelectRemoteMax");
}

exec function SelectShieldBlast()
{
	SelectThisArtifact("SelectShieldBlast");
}

exec function SelectChain()
{
	SelectThisArtifact("SelectChain");
}

exec function SelectFireBall()
{
	SelectThisArtifact("SelectFireBall");
}

exec function SelectRemoteBooster()
{
	SelectThisArtifact("SelectRemoteBooster");
}

function string GetSummonFriendlyName(Inventory Inv)
{
	if (ArtifactMonsterMaster(Inv) != None)
		return ArtifactMonsterMaster(Inv).FriendlyName;

	if (Summonifact(Inv) != None)
		return Summonifact(Inv).FriendlyName;

	return "";
}

function SelectThisArtifact (string ArtifactAlias)
{
	local class<RPGArtifact> ThisArtifactClass;
	local class<RPGArtifact> InitialArtifactClass;
	local int i, Count;
	local Inventory Inv, StartInv;
	local Pawn P;
	local bool GoneRound;
	local string InitialFriendlyName, curFriendlyName;

	P = ViewportOwner.Actor.Pawn;

	ThisArtifactClass = None;
	for (i = 0; i < ArtifactKeyConfigs.length; i++)
	{
		if (ArtifactKeyConfigs[i].Alias == ArtifactAlias) 
		{
			ThisArtifactClass = ArtifactKeyConfigs[i].ArtifactClass;
			i = ArtifactKeyConfigs.length;
		}
	}
	if (ThisArtifactClass == None)
		return;

	InitialArtifactClass = None;

	if (P.SelectedItem == None)
	{
		P.NextItem();
		InitialArtifactClass = class<RPGArtifact>(P.Inventory.Class);
		InitialFriendlyName = GetSummonFriendlyName(P.Inventory);
	}
	else
	{
		InitialArtifactClass = class<RPGArtifact>(P.SelectedItem.class);
		InitialFriendlyName = GetSummonFriendlyName(P.SelectedItem);
	}

	if ((InitialArtifactClass != None) && (InitialArtifactClass == ThisArtifactClass))
		return;

	Count = 0;
	for(Inv = P.Inventory; Inv != None && Count < 500; Inv = Inv.Inventory)
	{
		if (Inv.class == InitialArtifactClass)
		{
			if (InitialFriendlyName == GetSummonFriendlyName(Inv))
			{
				StartInv = Inv;
				Count = 501;
			}
		}
		Count++;
	}
	if (Count < 501)
		StartInv = P.Inventory;

	if (StartInv == None)
		return;

	Count = 0;
	GoneRound = false;
	P.NextItem();
	for(Inv = StartInv.Inventory; Count < 500; Inv = Inv.Inventory)
	{
		if (Inv == None)
		{
			Inv = P.Inventory;
			GoneRound = true;
		}

		curFriendlyName = GetSummonFriendlyName(Inv);
		if (Inv.class == ThisArtifactClass)
		{
			return;
		}
		else if (Inv.class == InitialArtifactClass && InitialFriendlyName == curFriendlyName && GoneRound)
		{
			return;
		}
		else if (RPGArtifact(Inv) != None)
		{
			P.NextItem();
		}
		Count++;
	}
}

function PreRender(Canvas Canvas)
{
	local int i;
	local float Dist, XScale, YScale, HealthScale, ScreenX, HealthMax;
	local vector BarLoc, CameraLocation, X, Y, Z;
	local rotator CameraRotation;
	local Pawn Enemy;
	local Pawn P;
	local float ShieldMax, CurShield;
	local float HM66, HM33, MedMax, SHMax;
	local string EHealth;

	if (ViewportOwner == None || ViewportOwner.Actor == None || ViewportOwner.Actor.Pawn == None || ViewportOwner.Actor.Pawn.Health <= 0)
		return;

	if (GiveItemsInv == None && ViewportOwner.Actor.Pawn != None && ViewportOwner.Actor.Pawn.Controller != None)
		GiveItemsInv = class'GiveItemsInv'.static.GetGiveItemsInv(ViewportOwner.Actor.Pawn.Controller);
	if (GiveItemsInv == None)
		FindGiveItemsInv();
	if (GiveItemsInv == None)
		return;
//Awareness
	Canvas.GetCameraLocation(CameraLocation, CameraRotation);
	if (GiveItemsInv.AwarenessLevel > 0 && EnemyList != None)
	{
		for (i = 0; i < EnemyList.Enemies.length; i++)
		{
			Enemy = EnemyList.Enemies[i];
			if (Enemy == None || Enemy.Health <= 0 || (xPawn(Enemy) != None && xPawn(Enemy).bInvis))
				continue;
			if (Normal(Enemy.Location - CameraLocation) dot vector(CameraRotation) < 0)
				continue;
			ScreenX = Canvas.WorldToScreen(Enemy.Location).X;
			if (ScreenX < 0 || ScreenX > Canvas.ClipX)
				continue;
	 		Dist = VSize(Enemy.Location - CameraLocation);
	 		if (Dist > ViewportOwner.Actor.TeamBeaconMaxDist * FClamp(0.04 * Enemy.CollisionRadius, 1.0, 3.0))
	 			continue;
			if (!Enemy.FastTrace(Enemy.Location + Enemy.CollisionHeight * vect(0,0,1), ViewportOwner.Actor.Pawn.Location + ViewportOwner.Actor.Pawn.EyeHeight * vect(0,0,1)))
				continue;

			GetAxes(rotator(Enemy.Location - CameraLocation), X, Y, Z);
			if (Enemy.IsA('Monster'))
			{
				BarLoc = Canvas.WorldToScreen(Enemy.Location + (Enemy.CollisionHeight * 1.25 + BarVSize / 2) * vect(0,0,1) - Enemy.CollisionRadius * Y);
				EHealth = String(Enemy.Health);
			}
			else
			{
				BarLoc = Canvas.WorldToScreen(Enemy.Location + (Enemy.CollisionHeight + BarVSize / 2) * vect(0,0,1) - Enemy.CollisionRadius * Y);
				EHealth = String(Enemy.Health);
			}
			XScale = (Canvas.WorldToScreen(Enemy.Location + (Enemy.CollisionHeight + BarVSize / 2) * vect(0,0,1) + Enemy.CollisionRadius * Y).X - BarLoc.X) / BarUSize;
			YScale = FMin(0.15 * XScale, 0.50);

			HealthScale = Enemy.Health/Enemy.HealthMax;
	 		Canvas.Style = 1;
			if (GiveItemsInv.AwarenessLevel == 1)
			{
				Canvas.SetPos(BarLoc.X, BarLoc.Y);
				Canvas.DrawColor.B = 0;
				Canvas.DrawColor.A = 255;
				if (HealthScale < 0.15)
				{
					Canvas.DrawColor.G = 0;
					Canvas.DrawColor.R = 200;
				}
				else if (HealthScale < 0.65)
				{
					Canvas.DrawColor.G = 150;
					Canvas.DrawColor.R = 150;
				}
				else
				{
					Canvas.DrawColor.R = 0;
					Canvas.DrawColor.G = 125;
				}
				Canvas.DrawTile(HealthBarMaterial, BarUSize*XScale, BarVSize*YScale, 0, 0, BarUSize, BarVSize);
			}
	 		if (GiveItemsInv.AwarenessLevel == 2)
			{
				Canvas.SetPos(BarLoc.X+(BarUSize*XScale*0.25), BarLoc.Y);
				Canvas.DrawColor = class'HUD'.default.GreenColor;
				Canvas.DrawTile(HealthBarMaterial, BarUSize*XScale*0.50, BarVSize*YScale*0.50, 0, 0, BarUSize, BarVSize);
	
				if (Enemy.IsA('Monster'))
					HealthMax = Enemy.HealthMax;
				else
					HealthMax = Enemy.HealthMax + 150;

		 		Canvas.DrawColor.R = Clamp(Int(255.0 * 2 * (1.0 - HealthScale)), 0, 255);
		 		Canvas.DrawColor.G = Clamp(Int(255.0 * 2 * HealthScale), 0, 255);
				Canvas.DrawColor.B = Clamp(Int(255.0 * ((Enemy.Health - Enemy.HealthMax)/150.0)), 0, 255);
			 	Canvas.DrawColor.A = 255;

				Canvas.SetPos(BarLoc.X+(BarUSize*XScale*Fclamp(((Enemy.Health/HealthMax)/2), 0.0, 0.5)), BarLoc.Y);
				Canvas.DrawTile(HealthBarMaterial, BarUSize*XScale*Fclamp(1.0-(Enemy.Health/HealthMax), 0.0, 1.0), BarVSize*YScale, 0, 0, BarUSize, BarVSize);
				if (Enemy.ShieldStrength > 0 && xPawn(Enemy) != None)
				{
					Canvas.DrawColor = class'HUD'.default.GoldColor;
					YScale /= 2;
					Canvas.SetPos(BarLoc.X, BarLoc.Y - BarVSize * (YScale + 0.05));
					Canvas.DrawTile(HealthBarMaterial, BarUSize*XScale*Enemy.ShieldStrength/xPawn(Enemy).ShieldStrengthMax, BarVSize*YScale, 0, 0, BarUSize, BarVSize);
				}
			}
	 		if (GiveItemsInv.AwarenessLevel == 3)
			{
				Canvas.SetPos(BarLoc.X, BarLoc.Y);
				Canvas.Font = Font'NewFont';
				Canvas.DrawColor.B = 0;
				Canvas.DrawColor.A = 255;
				if (HealthScale < 0.15)
				{
					Canvas.DrawColor.G = 0;
					Canvas.DrawColor.R = 200;
				}
				else if (HealthScale < 0.65)
				{
					Canvas.DrawColor.G = 150;
					Canvas.DrawColor.R = 150;
				}
				else
				{
					Canvas.DrawColor.R = 0;
					Canvas.DrawColor.G = 125;
				}
				Canvas.DrawText(EHealth);
			}
		}
	}
	
//Engineer awareness
	if (GiveItemsInv.EngAwarenessLevel > 0 && EnemyList != None)
	{
		for (i = 0; i < EnemyList.TeamPawns.length; i++)
		{
			P = EnemyList.TeamPawns[i];
			if (P == None || P.Health <= 0 || (xPawn(P) != None && xPawn(P).bInvis))
				continue;
			if (Normal(P.Location - CameraLocation) dot vector(CameraRotation) < 0)
				continue;
			ScreenX = Canvas.WorldToScreen(P.Location).X;
			if (ScreenX < 0 || ScreenX > Canvas.ClipX)
				continue;
	 		Dist = VSize(P.Location - CameraLocation);
	 		if (Dist > ViewportOwner.Actor.TeamBeaconMaxDist * FClamp(0.04 * P.CollisionRadius, 1.0, 3.0))
	 			continue;
			if (!P.FastTrace(P.Location + P.CollisionHeight * vect(0,0,1), ViewportOwner.Actor.Pawn.Location + ViewportOwner.Actor.Pawn.EyeHeight * vect(0,0,1)))
				continue;

			GetAxes(rotator(P.Location - CameraLocation), X, Y, Z);
			if (P.IsA('Monster'))
			{
				BarLoc = Canvas.WorldToScreen(P.Location + (P.CollisionHeight * 1.25 + BarVSize / 2) * vect(0,0,1) - P.CollisionRadius * Y);
			}
			else
			{
				BarLoc = Canvas.WorldToScreen(P.Location + (P.CollisionHeight + BarVSize / 2) * vect(0,0,1) - P.CollisionRadius * Y);
			}
			XScale = (Canvas.WorldToScreen(P.Location + (P.CollisionHeight + BarVSize / 2) * vect(0,0,1) + P.CollisionRadius * Y).X - BarLoc.X) / BarUSize;
			YScale = FMin(0.15 * XScale, 0.25);

	 		Canvas.Style = 1;

			CurShield = P.ShieldStrength;
			if (xPawn(P) != None)
				ShieldMax = xPawn(P).ShieldStrengthMax;
			else
				ShieldMax = 150;
			ShieldMax = max(ShieldMax,CurShield);

			if (ShieldMax <= 0)
				continue;
			if (CurShield < 0)
				CurShield = 0;
			if (CurShield > ShieldMax)
				CurShield = ShieldMax;

			// Make the white bar
			BarLoc.Y += BarVSize*FMin(0.15 * XScale, 0.40);
			Canvas.SetPos(BarLoc.X, BarLoc.Y);
			Canvas.DrawColor = class'HUD'.default.WhiteColor;
			if (CurShield >= ShieldMax)
			{
				Canvas.DrawColor.A = 255;
				Canvas.DrawColor.B = 0;
				Canvas.DrawColor.G = 255;
				Canvas.DrawColor.R = 255;
			}
			Canvas.DrawTile(HealthBarMaterial, BarUSize*XScale, BarVSize*YScale, 0, 0, BarUSize, BarVSize);
			Canvas.DrawColor.A = 255;
			Canvas.DrawColor.B = 0;
		
			// want an orange color, with less red as it gets healthier
			Canvas.DrawColor.R = 128;
			Canvas.DrawColor.G = Clamp(Int(128*CurShield/ShieldMax), 0, 255);
			Canvas.SetPos(BarLoc.X+(BarUSize*XScale*((CurShield/ShieldMax)/2)), BarLoc.Y);
			Canvas.DrawTile(HealthBarMaterial, BarUSize*XScale*(1.00 - (CurShield/ShieldMax)), BarVSize*YScale, 0, 0, BarUSize, BarVSize);
		}
	}

//Medic awareness
	if (GiveItemsInv.MedicAwarenessLevel > 0 && EnemyList != None)
	{
		for (i = 0; i < EnemyList.TeamPawns.length; i++)
		{
			P = EnemyList.TeamPawns[i];
			if (P == None || P.Health <= 0 || (xPawn(P) != None && xPawn(P).bInvis))
				continue;
			if (Normal(P.Location - CameraLocation) dot vector(CameraRotation) < 0)
				continue;
			ScreenX = Canvas.WorldToScreen(P.Location).X;
			if (ScreenX < 0 || ScreenX > Canvas.ClipX)
				continue;
	 		Dist = VSize(P.Location - CameraLocation);
	 		if (Dist > ViewportOwner.Actor.TeamBeaconMaxDist * FClamp(0.04 * P.CollisionRadius, 1.0, 3.0))
	 			continue;
			if (!P.FastTrace(P.Location + P.CollisionHeight * vect(0,0,1), ViewportOwner.Actor.Pawn.Location + ViewportOwner.Actor.Pawn.EyeHeight * vect(0,0,1)))
				continue;

			GetAxes(rotator(P.Location - CameraLocation), X, Y, Z);
			if (P.IsA('Monster'))
			{
				BarLoc = Canvas.WorldToScreen(P.Location + (P.CollisionHeight * 1.25 + BarVSize / 2) * vect(0,0,1) - P.CollisionRadius * Y);
			}
			else
			{
				BarLoc = Canvas.WorldToScreen(P.Location + (P.CollisionHeight + BarVSize / 2) * vect(0,0,1) - P.CollisionRadius * Y);
			}
			XScale = (Canvas.WorldToScreen(P.Location + (P.CollisionHeight + BarVSize / 2) * vect(0,0,1) + P.CollisionRadius * Y).X - BarLoc.X) / BarUSize;
			YScale = FMin(0.15 * XScale, 0.40);

	 		Canvas.Style = 1;

			MedMax = P.HealthMax + 150.0;
			HM66 = P.HealthMax * 0.66;
			HM33 = P.HealthMax * 0.33;
			SHMax = P.HealthMax + 99.0;

			if (GiveItemsInv.MedicAwarenessLevel > 1)
			{
				Canvas.SetPos(BarLoc.X, BarLoc.Y);
				if(P.Health >= MedMax)
				{
					Canvas.DrawColor = class'HUD'.default.BlueColor;
					Canvas.DrawTile(HealthBarMaterial, BarUSize*XScale, BarVSize*YScale, 0, 0, BarUSize, BarVSize);
				}
				else
				{
					Canvas.DrawColor = class'HUD'.default.WhiteColor;
					Canvas.DrawTile(HealthBarMaterial, BarUSize*XScale, BarVSize*YScale, 0, 0, BarUSize, BarVSize);
					Canvas.DrawColor.A = 255;
					Canvas.DrawColor.R = Clamp(Int((1.00 - ((P.Health - HM66)/(P.HealthMax - HM66)))*255.0), 0, 255);
					Canvas.DrawColor.B = Clamp(Int(((P.Health - P.HealthMax)/(SHMax - P.HealthMax))*255.0), 0, 255);
					if (P.Health > P.HealthMax)
					{
						Canvas.DrawColor.G = Clamp(Int((1.00 - ((P.Health - SHMax)/(MedMax - SHMax)))*255.0), 0, 255);
					}
					else
					{
						Canvas.DrawColor.G = Clamp(Int(((P.Health - HM33)/(HM66 - HM33))*255.0), 0, 255);
					}
					Canvas.SetPos(BarLoc.X+(BarUSize*XScale*((P.Health/MedMax)/2)), BarLoc.Y);
					Canvas.DrawTile(HealthBarMaterial, BarUSize*XScale*(1.00 - (P.Health/MedMax)), BarVSize*YScale, 0, 0, BarUSize, BarVSize);
				}
			}
			else
			{
				if (P.Health < HM33)
				{
					Canvas.DrawColor.A = 255;
					Canvas.DrawColor.R = 200;
					Canvas.DrawColor.G = 0;
					Canvas.DrawColor.B = 0;
				}
				else if (P.Health < HM66)
				{
					Canvas.DrawColor.A = 255;
					Canvas.DrawColor.R = 150;
					Canvas.DrawColor.G = 150;
					Canvas.DrawColor.B = 0;
				}
				else if (P.Health < SHMax)
				{
					Canvas.DrawColor.A = 255;
					Canvas.DrawColor.R = 0;
					Canvas.DrawColor.G = 125;
					Canvas.DrawColor.B = 0;
				}
				else
				{
					Canvas.DrawColor.A = 255;
					Canvas.DrawColor.R = 0;
					Canvas.DrawColor.G = 0;
					Canvas.DrawColor.B = 100;
				}
				Canvas.SetPos(BarLoc.X+(BarUSize*XScale*0.25),BarLoc.Y);
				Canvas.DrawTile(HealthBarMaterial, BarUSize*XScale*0.50, BarVsize*YScale*0.50, 0, 0, BarUSize, BarVSize);
			}
		}
	}
}

function PostRender(Canvas Canvas)
{
	local float XL, YL;
	local string pText;
	local int UsedEP, TotalEP, EPLeft, iRecoveryTime;
	local int UsedMP, TotalMP, MPLeft, iNumHealers;
	local EnhancedRPGArtifact ea;
	local Summonifact Sf;
	local ArtifactMonsterMaster DMMAMS;

	if ( ViewportOwner == None || ViewportOwner.Actor == None || ViewportOwner.Actor.Pawn == None || ViewportOwner.Actor.Pawn.Health <= 0
	     || (ViewportOwner.Actor.myHud != None && ViewportOwner.Actor.myHud.bShowScoreBoard)
	     || (ViewportOwner.Actor.myHud != None && ViewportOwner.Actor.myHud.bHideHUD) )
	{
		Super.PostRender(Canvas);
		if (ViewportOwner == None || ViewportOwner.Actor == None || ViewportOwner.Actor.Pawn == None || ViewportOwner.Actor.Pawn.Health <= 0)
		{
			EInv = None;
			MInv = None;
		}
		return;
	}

	Canvas.Font = Font'BerlinSans';

// AdrenalineMaster Hud
	ea = EnhancedRPGArtifact(ViewportOwner.Actor.Pawn.SelectedItem);
	if (ea != None && ea.GetRecoveryTime() > 0)
	{
		Canvas.FontScaleX = Canvas.ClipX / 1024.f;
		Canvas.FontScaleY = Canvas.ClipY / 768.f;

		pText = "200";
		Canvas.TextSize(pText, XL, YL);

		Canvas.Style = 2;
		Canvas.DrawColor = WhiteColor;

		Canvas.SetPos(XL+11, Canvas.ClipY * 0.50 - YL * 2.5); 
		pText = String(ea.GetRecoveryTime());
		Canvas.DrawText(pText);
	}

// EngineerMaster Hud
	iNumHealers = -1;
	if (xBallTurret(ViewportOwner.Actor.Pawn) != None)
		iNumHealers = xBallTurret(ViewportOwner.Actor.Pawn).NumHealers;
	else if (xEnergyTurret(ViewportOwner.Actor.Pawn) != None)
		iNumHealers = xEnergyTurret(ViewportOwner.Actor.Pawn).NumHealers;
	else if (xIonCannon(ViewportOwner.Actor.Pawn) != None)
		iNumHealers = xIonCannon(ViewportOwner.Actor.Pawn).NumHealers;
	else if (xMinigunTurret(ViewportOwner.Actor.Pawn) != None)
		iNumHealers = xMinigunTurret(ViewportOwner.Actor.Pawn).NumHealers;
	if (iNumHealers > 0)
	{
		Canvas.FontScaleX = Canvas.default.FontScaleX;
		Canvas.FontScaleY = Canvas.default.FontScaleY;

		pText = "200";
		Canvas.TextSize(pText, XL, YL);
		Canvas.SetPos(2, Canvas.ClipY * 0.75 - YL * 7.6);
		Canvas.DrawTile(Material'HudContent.Generic.fbLinks', 64, 32, 0, 0, 128, 64);

		pText = String(iNumHealers);
		Canvas.SetPos(30, Canvas.ClipY * 0.75 - YL * 7.1);
		Canvas.DrawColor = GreenColor;
		Canvas.DrawText(pText);	
	}

	if (EInv == None)
		FindEPInv();
	if (EInv != None && EInv.IsA('EngineerPointsInv'))
	{
		UsedEP = EInv.UsedEngineerPoints;
		TotalEP = EInv.TotalEngineerPoints;
		iRecoveryTime = EInv.GetRecoveryTime();
	}
	else 
	{
		TotalEP = 0;
		iRecoveryTime = 0;
 	}

	if (TotalEP > 0)
	{
		pText = "200";
		Canvas.TextSize(pText, XL, YL);

		Canvas.Style = 2;
		Canvas.DrawColor = YellowColor;
		if (iRecoveryTime > 0)
		{
			Canvas.SetPos(XL+15, Canvas.ClipY * 0.50 - YL * 3.5); 
			pText = String(iRecoveryTime);
			Canvas.DrawText(pText);
		}

		Canvas.DrawColor = WhiteColor;
		Sf = Summonifact(ViewportOwner.Actor.Pawn.SelectedItem);
		if (Sf != None)
		{
			// draw ArtifactHud info
			Canvas.SetPos(1, Canvas.ClipY * 0.50 - YL * 6.0);
			Canvas.DrawText(Sf.FriendlyName);
//used eng points
			pText = "";
			Canvas.DrawColor = GreenColor;
			EPLeft = TotalEP-UsedEP;
//engineer points
			if (Sf.Points > EPLeft)
				Canvas.DrawColor = RedColor;
			Canvas.SetPos(1, Canvas.ClipY * 0.50 - YL * 5.0);
			Canvas.DrawText(PointsText$Sf.Points);

			Canvas.SetPos(1, Canvas.ClipY * 0.50 + YL * 0.5);
			if (iRecoveryTime > 0 || Sf.Points > EPLeft)
				Canvas.DrawColor = RedColor;
			Canvas.DrawText(EngineerPointsText $ UsedEP $ "/" $ TotalEP);
		}

		Canvas.FontScaleX = Canvas.default.FontScaleX;
		Canvas.FontScaleY = Canvas.default.FontScaleY;
	}

//MonsterMaster Hud
	Canvas.DrawColor = WhiteColor;
	if (MInv == None)
		FindMPInv();
	if (MInv != None && MInv.IsA('MonsterPointsInv'))
	{
		TotalMP = MInv.TotalMonsterPoints;
		UsedMP = MInv.UsedMonsterPoints;
	}
	else 
	{
		TotalMP = 0;
 	}

	if (TotalMP > 0)
	{
		Canvas.TextSize(PointsText, XL, YL);
		Canvas.Style = 2;
		Canvas.DrawColor = WhiteColor;
		DMMAMS = ArtifactMonsterMaster(ViewportOwner.Actor.Pawn.SelectedItem);
		if (DMMAMS != None)
		{
			Canvas.SetPos(1, Canvas.ClipY * 0.50 - YL * 7.0);
			Canvas.DrawText(DMMAMS.FriendlyName);

			Canvas.DrawColor = BlueColor;
			MPLeft = TotalMP-UsedMP;
//monster points
			if (DMMAMS.MonsterPoints > MPLeft)
				Canvas.DrawColor = RedColor;
			Canvas.SetPos(1, Canvas.ClipY * 0.50 - YL * 5.0);
			Canvas.DrawText(PointsText $ DMMAMS.MonsterPoints);
//adrenaline
			Canvas.SetPos(1, Canvas.ClipY * 0.50 - YL * 6.0);
			Canvas.DrawText(AdrenalineText $ DMMAMS.Adrenaline);
//used monsterpoints
			Canvas.DrawColor = BlueColor;
			if (DMMAMS.MonsterPoints > MPLeft)
				Canvas.DrawColor = RedColor;
			Canvas.SetPos(1, Canvas.ClipY * 0.50 + YL * 0.5);
			Canvas.DrawText(MonsterPointsText $ UsedMP $ "/" $ TotalMP);
		}

		Canvas.FontScaleX = Canvas.default.FontScaleX;
		Canvas.FontScaleY = Canvas.default.FontScaleY;
	}

	Canvas.DrawColor = WhiteColor;
	Super.PostRender(Canvas);
}

defaultproperties
{
     ArtifactKeyConfigs(0)=(Alias="SelectTriple",ArtifactClass=Class'fps.ArtifactTripleDamage')
     HealthBarMaterial=Texture'Engine.WhiteSquareTexture'
     RedColor=(B=159,G=159,R=255,A=159)
     GreenColor=(B=159,G=255,R=159,A=159)
     BlueColor=(B=255,G=159,R=159,A=159)
     YellowColor=(B=159,G=255,R=255,A=159)
     PointsText="Points: "
     EngineerPointsText="Engineer: "
     AdrenalineText="Adrenaline: "
     MonsterPointsText="Monster: "
     bRequiresTick=True
}
