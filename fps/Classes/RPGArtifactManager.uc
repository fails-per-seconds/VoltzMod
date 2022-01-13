class RPGArtifactManager extends Info
	config(fps);

var config int ArtifactDelay;
var config int MaxArtifacts;
var config int MaxHeldArtifacts;
var config array<class<RPGArtifact> > Artifacts;
struct ArtifactChance
{
	var class<RPGArtifact> ArtifactClass;
	var int Chance;
};
var config array<ArtifactChance> AvailableArtifacts;
var int TotalArtifactChance;
var array<RPGArtifact> CurrentArtifacts;
var array<PathNode> PathNodes;

var localized string PropsDisplayText[3];
var localized string PropsDescText[3];

function PostBeginPlay()
{
	local NavigationPoint N;
	local int x;

	Super.PostBeginPlay();

	for (x = 0; x < AvailableArtifacts.length; x++)
		if (AvailableArtifacts[x].ArtifactClass == None || !AvailableArtifacts[x].ArtifactClass.static.ArtifactIsAllowed(Level.Game))
		{
			AvailableArtifacts.Remove(x, 1);
			x--;
		}

	if (ArtifactDelay > 0 && MaxArtifacts > 0 && AvailableArtifacts.length > 0)
	{
		for (N = Level.NavigationPointList; N != None; N = N.NextNavigationPoint)
			if (PathNode(N) != None && !N.IsA('FlyingPathNode'))
				PathNodes[PathNodes.length] = PathNode(N);

		for (x = 0; x < AvailableArtifacts.length; x++)
			TotalArtifactChance += AvailableArtifacts[x].Chance;
	}
	else
		Destroy();
}

function MatchStarting()
{
	SetTimer(ArtifactDelay, true);
}

function int GetRandomArtifactIndex()
{
	local int i, Chance;

	Chance = Rand(TotalArtifactChance);
	for (i = 0; i < AvailableArtifacts.Length; i++)
	{
		Chance -= AvailableArtifacts[i].Chance;
		if (Chance < 0)
			return i;
	}
}

function Timer()
{
	local int Chance, Count, x;
	local bool bTryAgain;

	for (x = 0; x < CurrentArtifacts.length; x++)
		if (CurrentArtifacts[x] == None)
		{
			CurrentArtifacts.Remove(x, 1);
			x--;
		}

	if (CurrentArtifacts.length >= MaxArtifacts)
		return;

	if (CurrentArtifacts.length >= AvailableArtifacts.length)
	{
		Chance = GetRandomArtifactIndex();
		SpawnArtifact(Chance);
		return;
	}

	while (Count < 250)
	{
		Chance = GetRandomArtifactIndex();
		for (x = 0; x < CurrentArtifacts.length; x++)
			if (CurrentArtifacts[x].Class == AvailableArtifacts[Chance].ArtifactClass)
			{
				bTryAgain = true;
				x = CurrentArtifacts.length;
			}
		if (!bTryAgain)
		{
			SpawnArtifact(Chance);
			return;
		}
		bTryAgain = false;
		Count++;
	}
}

function SpawnArtifact(int Index)
{
	local Pickup APickup;
	local Controller C;
	local RPGArtifact Inv;
	local int NumMonsters, PickedMonster, CurrentMonster;

	if (Level.Game.IsA('Invasion'))
	{
		NumMonsters = int(Level.Game.GetPropertyText("NumMonsters"));
		if (NumMonsters <= CurrentArtifacts.length)
			return;
		do
		{
			PickedMonster = Rand(NumMonsters);
			for (C = Level.ControllerList; C != None; C = C.NextController)
				if (C.Pawn != None && C.Pawn.IsA('Monster') && !C.IsA('FriendlyMonsterController'))
				{
					if (CurrentMonster >= PickedMonster)
					{
						if (RPGArtifact(C.Pawn.Inventory) == None)
						{
							Inv = spawn(AvailableArtifacts[Index].ArtifactClass);
							Inv.GiveTo(C.Pawn);
							break;
						}
					}
					else
						CurrentMonster++;
				}
		} until (Inv != None)

		if (Inv != None)
			CurrentArtifacts[CurrentArtifacts.length] = Inv;
	}
	else
	{
		APickup = spawn(AvailableArtifacts[Index].ArtifactClass.default.PickupClass,,, PathNodes[Rand(PathNodes.length)].Location);
		if (APickup == None)
			return;
		APickup.RespawnEffect();
		APickup.RespawnTime = 0.0;
		APickup.AddToNavigation();
		APickup.bDropped = true;
		APickup.Inventory = spawn(AvailableArtifacts[Index].ArtifactClass);
		CurrentArtifacts[CurrentArtifacts.length] = RPGArtifact(APickup.Inventory);
	}
}

static function FillPlayInfo(PlayInfo PlayInfo)
{
	local int i;

	Super.FillPlayInfo(PlayInfo);

	PlayInfo.AddSetting("fps", "MaxArtifacts", default.PropsDisplayText[i++], 3, 10, "Text", "2;0:25");
	PlayInfo.AddSetting("fps", "ArtifactDelay", default.PropsDisplayText[i++], 30, 10, "Text", "3;1:100");
	PlayInfo.AddSetting("fps", "MaxHeldArtifacts", default.PropsDisplayText[i++], 0, 10, "Text", "2;0:99");
}

static function string GetDescriptionText(string PropName)
{
	switch (PropName)
	{
		case "MaxArtifacts":	return default.PropsDescText[0];
		case "ArtifactDelay":	return default.PropsDescText[1];
		case "MaxHeldArtifacts":return default.PropsDescText[2];
	}
}

static final function UpdateArtifactList()
{
	local int i;

	if (default.Artifacts.length > 0 && default.AvailableArtifacts.length == 6)
	{
		default.AvailableArtifacts.length = default.Artifacts.length;
		for (i = 0; i < default.Artifacts.length; i++)
		{
			default.AvailableArtifacts[i].ArtifactClass = default.Artifacts[i];
			default.AvailableArtifacts[i].Chance = 1;
		}
		default.Artifacts.length = 0;
		StaticSaveConfig();
	}
}

defaultproperties
{
     ArtifactDelay=0
     MaxArtifacts=0
     //AvailableArtifacts(0)=(ArtifactClass=Class'fps.ArtifactGlobe',Chance=1)
     PropsDisplayText(0)="Max Artifacts"
     PropsDisplayText(1)="Artifact Spawn Delay"
     PropsDisplayText(2)="Max Artifacts a Player Can Hold"
     PropsDescText(0)="Maximum number of artifacts in the level at once."
     PropsDescText(1)="Spawn an artifact every this many seconds. (0 disables)"
     PropsDescText(2)="The maximum number of artifacts a player can carry at once (0 for infinity)"
     bBlockZeroExtentTraces=False
     bBlockNonZeroExtentTraces=False
}
