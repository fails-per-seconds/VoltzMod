class MutFPSHud extends Mutator
	config(fpsUpdate);

struct InitialXPValues
{
	Var String PlayerName;
	var RPGStatsInv StatsInv;
	var int CurrentXP;
	var int InitialXP;
	var int AdditionalXP;
	var int InitialLV;
	var int NeededXP;
	var int PlayerClass;
	var int XPGained;
	var string SubClass;
	var PlayerReplicationInfo PlayerReplicationInfo;
	var int LogXPGained;
	var float StartTime;
	var int LastScore;
};
var Array<InitialXPValues> InitialXPs;

var bool bLoggedEndStats;
var bool bGameDone;
var config Class<UpgradeInv> Upgrader;

function ModifyPlayer(Pawn Other)
{
	local UpgradeInv UInv;
	local ClientHudInv Inv;
	local ClientHudInv TempCInv;
	local String PlayerName;

	super.ModifyPlayer(Other);

	if (Other != None && Other.Controller != None && Other.Controller.isA('PlayerController') && Other.PlayerReplicationInfo != None) 
	{
		Inv = ClientHudInv(Other.FindInventoryType(class'ClientHudInv'));
		if (Inv == None)
		{
			PlayerName = Other.PlayerReplicationInfo.PlayerName;
			if (Inv == None)
			{
				foreach DynamicActors(class'ClientHudInv',TempCInv)
					if (TempCInv.OwnerName == PlayerName)
						Inv = TempCInv;
			}
			if (Inv == None)
			{
				Inv = Other.spawn(class'ClientHudInv', Other,,, rot(0,0,0));
				Inv.OwnerName = PlayerName;
			}
			Inv.giveTo(Other);
		}	
	}
	if (Inv != None && Inv.HUDMut == None)
		Inv.HUDMut = self;	

	if (Other != None && Other.Controller != None && Other.Controller.IsA('PlayerController'))
	{
		UInv = UpgradeInv(Other.FindInventoryType(class'UpgradeInv'));
		if (UInv == None)
		{
			UInv = spawn(Upgrader, Other,,, rot(0,0,0));
			UInv.giveTo(Other);
		}
	}
}

function PostBeginPlay()
{
	bLoggedEndStats = false;
	bGameDone = false;
	SetTimer(5, true);
	Super.PostBeginPlay();
}

function RPGStatsInv GetStatsInvFor(Controller C, optional bool bMustBeOwner)
{
	local Inventory Inv;

	for (Inv = C.Inventory; Inv != None; Inv = Inv.Inventory)
		if (Inv.IsA('RPGStatsInv') && (!bMustBeOwner || Inv.Owner == C || Inv.Owner == C.Pawn || (Vehicle(C.Pawn) != None && Inv.Owner == Vehicle(C.Pawn).Driver)))
			return RPGStatsInv(Inv);

	if (C.Pawn != None)
	{
		Inv = C.Pawn.FindInventoryType(class'RPGStatsInv');
		if (Inv != None && (!bMustBeOwner || Inv.Owner == C || Inv.Owner == C.Pawn || (Vehicle(C.Pawn) != None && Inv.Owner == Vehicle(C.Pawn).Driver)))
			return RPGStatsInv(Inv);
	}

	return None;
}

function SetupInitDetails(int x, Controller C)
{
	local int a;

	InitialXPs[x].StatsInv = GetStatsInvFor(C, false);
	if (InitialXPs[x].StatsInv != None && InitialXPs[x].StatsInv.DataObject != None)
	{
		InitialXPs[x].InitialXP = InitialXPs[x].StatsInv.DataObject.Experience;
		InitialXPs[x].InitialLV = InitialXPs[x].StatsInv.DataObject.Level;
		InitialXPs[x].CurrentXP = InitialXPs[x].StatsInv.DataObject.Experience;
		InitialXPs[x].NeededXP = InitialXPs[x].StatsInv.DataObject.NeededExp;
		InitialXPs[x].AdditionalXP = 0;
		InitialXPs[x].SubClass = "";
		// ok now find the class, if any
		InitialXPs[x].PlayerClass = 0;
		InitialXPs[x].PlayerReplicationInfo = C.PlayerReplicationInfo;
		for (a = 0; a < InitialXPs[x].StatsInv.DataObject.Abilities.Length; a++)
		{
			if (InitialXPs[x].StatsInv.DataObject.Abilities[a] == class'ClassWeaponsMaster')
				InitialXPs[x].PlayerClass = 1;
			if (InitialXPs[x].StatsInv.DataObject.Abilities[a] == class'ClassAdrenalineMaster')
				InitialXPs[x].PlayerClass = 2;
			if (InitialXPs[x].StatsInv.DataObject.Abilities[a] == class'ClassMonsterMaster')
				InitialXPs[x].PlayerClass = 3;
			if (InitialXPs[x].StatsInv.DataObject.Abilities[a] == class'ClassEngineer')
				InitialXPs[x].PlayerClass = 4;
			if (InitialXPs[x].StatsInv.DataObject.Abilities[a] == class'ClassGeneral')
				InitialXPs[x].PlayerClass = 5;
	
			if (InitialXPs[x].StatsInv.DataObject.Abilities[a] == class'SubClass')
				if (InitialXPs[x].StatsInv.DataObject.AbilityLevels[a] > 0 && InitialXPs[x].StatsInv.DataObject.AbilityLevels[a] < class'SubClass'.default.SubClasses.length)
					InitialXPs[x].SubClass = class'SubClass'.default.SubClasses[InitialXPs[x].StatsInv.DataObject.AbilityLevels[a]];
		}
	}
	else
	{
		InitialXPs[x].InitialXP = -1;
		InitialXPs[x].PlayerClass = -1;
	}
}

function CheckDetails(int x, Controller C)
{
	local int a;

	if (InitialXPs[x].StatsInv != None && InitialXPs[x].StatsInv.DataObject != None)
	{
		for (a = 0; a < InitialXPs[x].StatsInv.DataObject.Abilities.Length; a++)
		{
			if (InitialXPs[x].StatsInv.DataObject.Abilities[a] == class'ClassWeaponsMaster')
				InitialXPs[x].PlayerClass = 1;
			if (InitialXPs[x].StatsInv.DataObject.Abilities[a] == class'ClassAdrenalineMaster')
				InitialXPs[x].PlayerClass = 2;
			if (InitialXPs[x].StatsInv.DataObject.Abilities[a] == class'ClassMonsterMaster')
				InitialXPs[x].PlayerClass = 3;
			if (InitialXPs[x].StatsInv.DataObject.Abilities[a] == class'ClassEngineer')
				InitialXPs[x].PlayerClass = 4;
			if (InitialXPs[x].StatsInv.DataObject.Abilities[a] == class'ClassGeneral')
				InitialXPs[x].PlayerClass = 5;
	
			if (InitialXPs[x].StatsInv.DataObject.Abilities[a] == class'SubClass')
				if (InitialXPs[x].StatsInv.DataObject.AbilityLevels[a] > 0 && InitialXPs[x].StatsInv.DataObject.AbilityLevels[a] < class'SubClass'.default.SubClasses.length)
					InitialXPs[x].SubClass = class'SubClass'.default.SubClasses[InitialXPs[x].StatsInv.DataObject.AbilityLevels[a]];
		}
	}
	if (InitialXPs[x].PlayerReplicationInfo != None)
	{
		InitialXPs[x].StartTime = InitialXPs[x].PlayerReplicationInfo.StartTime;
		InitialXPs[x].LastScore = InitialXPs[x].PlayerReplicationInfo.Score;
	}
}

function Timer()
{
	local int x, iNumPlayers;
	local Controller C;
	local string PlayerName;
	local RPGStatsInv StatsInv;

	if (Level.Game.bGameEnded && !bLoggedEndStats)
	{
		if (bGameDone)
		{
			if (Level.Game.IsA('Invasion'))
			{
				iNumPlayers = 0;
				for (x = 0; x < InitialXPs.Length; x++)
				{
					if (InitialXPs[x].XPGained != InitialXPs[x].LogXPGained)
						iNumPlayers++;
				}
				if (Level.Game.GameReplicationInfo.Winner == TeamGame(Level.Game).Teams[0])
					Log(">>>> End game, Invasion Won, number of players:" $ iNumPlayers);
				else
					Log(">>>> End game, Invasion lost, wave:" $ (Invasion(Level.Game).WaveNum+1) @ "number of players:" $ iNumPlayers);
			}
			else
				Log(">>>> End game, type:" $ Level.Game);
	    	
			for (x = 0; x < InitialXPs.Length; x++)
			{
				LogDetailsForPlayer(x, "End Map");
			}
			bLoggedEndStats = true;
			return;
		}
		else
			bGameDone = true;
	}

	C = Level.ControllerList;
	while (C != None)
	{
		if (C.Pawn != None && C.Pawn.PlayerReplicationInfo != None && Monster(C.Pawn) == None && xSentinelController(C) == None && xSentinelBaseController(C) == None
			&& xDefenseSentinelController(C) == None && AutoGunController(C) == None && xLightningSentinelController(C) == None && xEnergyWallController(C) == None)
		{
			StatsInv = GetStatsInvFor(C, false);
			if (StatsInv != None && StatsInv.DataObject != None)
				PlayerName = String(StatsInv.DataObject.Name);
			else
				PlayerName = C.Pawn.PlayerReplicationInfo.PlayerName;
			x = 0;
			while (x < InitialXPs.Length && InitialXPs[x].PlayerName != PlayerName)
				x++;
			if (x >= InitialXPs.Length)
			{
				x = InitialXPs.Length;
				InitialXPs.Length = x+1;
				InitialXPs[x].PlayerName = PlayerName;
				SetupInitDetails(x,C);
			}
			else
			{
				CheckDetails(x,C);
			}
			// calculate xp gained
			if (InitialXPs[x].InitialXP >= 0 && InitialXPs[x].StatsInv != None && InitialXPs[x].StatsInv.DataObject != None)
			{
				if (InitialXPs[x].InitialXP >= 0 && InitialXPs[x].InitialLV < InitialXPs[x].StatsInv.DataObject.Level)
				{
					InitialXPs[x].AdditionalXP += InitialXPs[x].NeededXP - InitialXPs[x].InitialXP;
					InitialXPs[x].InitialXP = 0;
					InitialXPs[x].InitialLV = InitialXPs[x].StatsInv.DataObject.Level;
					InitialXPs[x].NeededXP = InitialXPs[x].StatsInv.DataObject.NeededExp;
				}
				InitialXPs[x].XPGained = InitialXPs[x].StatsInv.DataObject.Experience + InitialXPs[x].AdditionalXP - InitialXPs[x].InitialXP;
			}
			// calculate current xp
			if (InitialXPs[x].CurrentXP >= 0 && InitialXPs[x].StatsInv != None && InitialXPs[x].StatsInv.DataObject != None)
			{
				if (InitialXPs[x].StatsInv == None)
				{
					SetupInitDetails(x,C);
				}
				else
				{
					if (InitialXPs[x].StatsInv.DataObject != None)
						InitialXPs[x].CurrentXP = InitialXPs[x].StatsInv.DataObject.Experience;
				}
			}
		}
		C = C.NextController;
	}
}

function LogDetailsForPlayer(int x, string sLogReason)
{
	local string PClass, SClass;
	local int iDuration, iPPH, iScore;

	if (x >= InitialXPs.Length || InitialXPs[x].XPGained == InitialXPs[x].LogXPGained)
		return;

	if (InitialXPs[x].PlayerReplicationInfo == None)
		iScore = InitialXPs[x].LastScore;
	else
	{
		iScore = InitialXPs[x].PlayerReplicationInfo.Score;
		if (InitialXPs[x].PlayerReplicationInfo.bBot)
			return;
	}

	InitialXPs[x].LogXPGained = InitialXPs[x].XPGained;

	PClass = "None";
	if (InitialXPs[x].PlayerClass == 1)
		PClass = "WeaponMaster";
	else if (InitialXPs[x].PlayerClass == 2)
		PClass = "AdrenalineMaster";
	else if (InitialXPs[x].PlayerClass == 3)
		PClass = "MonsterMaster";
	else if (InitialXPs[x].PlayerClass == 4)
		PClass = "Engineer";
	else if (InitialXPs[x].PlayerClass == 5)
		PClass = "General";

	if (Level == None || Level.Game == None ||  Level.Game.GameReplicationInfo == None)
		iPPH = 0;
	else
	{
		if (InitialXPs[x].PlayerReplicationInfo != None)
			iDuration = Level.Game.GameReplicationInfo.ElapsedTime - InitialXPs[x].PlayerReplicationInfo.StartTime;
  		else
			iDuration = Level.Game.GameReplicationInfo.ElapsedTime - InitialXPs[x].StartTime;
		if (iDuration > 5)
			iPPH = Clamp(3600* iScore/iDuration,-999,99999);
		else
			iPPH = 0;
	} 
	
	if (sLogReason == "End Map" && InitialXPs[x].PlayerReplicationInfo != None && InitialXPs[x].PlayerReplicationInfo.StartTime == 0)
		sLogReason = "Whole Map";
		
	if (InitialXPs[x].SubClass == "")
		SClass = "None";
	else
		SClass = InitialXPs[x].SubClass;
	Log(">>>> PlayerScore:" $ sLogReason @ "PlayerName:" $ InitialXPs[x].PlayerName @ "Level:" $ InitialXPs[x].InitialLV  @ "Score:" $ iScore @ "PPH:" $ iPPH @ "XP Gained:" $ InitialXPs[x].XPGained @ "Class:" $ PClass @ "SubClass:" $ SClass @ "Time:" $ iDuration @ "Gametype:" $ Level.Game @ "Map:" $ Level.Title);
}

function NotifyLogout(Controller Exiting)
{
	local string PlayerName;
	local int x;
	local RPGStatsInv StatsInv;

	if (Level.Game == None || Level.Game.bGameRestarted)
		return;

	if (Exiting == None || !Exiting.IsA('PlayerController') || Exiting.PlayerReplicationInfo == None)
		return;

	StatsInv = GetStatsInvFor(Exiting, false);
	if (StatsInv != None && StatsInv.DataObject != None)
		PlayerName = String(StatsInv.DataObject.Name);
	else
		PlayerName = Exiting.PlayerReplicationInfo.PlayerName;

	x = 0;
	while (x < InitialXPs.Length && InitialXPs[x].PlayerName != PlayerName)
		x++;

	if (x >= InitialXPs.Length)
		return;

	LogDetailsForPlayer(x, "Logout");
}

defaultproperties
{
     Upgrader=Class'fps.UpgradeInv'
     GroupName="RPGHud"
     FriendlyName="fps Hud"
     Description="show xp info on btimes scoreboard"
}
