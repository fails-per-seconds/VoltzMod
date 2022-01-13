class ClientHudInv extends Inventory;

var MutFPSHud HUDMut;
var String OwnerName;

struct CurrentXPValues
{
	var String PlayerName;
	var int PlayerClass;
	var string SubClass;
	var int InitialLV;
	var int CurrentXP;
	var int NeededXP;
	var int XPGained;
};
var Array<CurrentXPValues> CurrentXPs;

var bool XPsUpdated;
var float SumDelta;

replication
{
	reliable if (Role == ROLE_Authority)
		ClientReceiveXP;
}

simulated function PostNetBeginPlay()
{
	if (Level.NetMode != NM_DedicatedServer)
		Enable('Tick');
	Super.PostNetBeginPlay();
	SumDelta = 3;
}

simulated function Tick(float deltaTime)
{
	local Mutator m;

	SumDelta += deltaTime;
	if (SumDelta < 5)
		return;

	while (SumDelta >= 5)
		SumDelta -= 5;

	if (Level.Game == None)
		return;

	if (!Level.Game.IsA('Invasion'))
	{
		disable('Tick');
		return;
	}
    
	if (HUDMut == None)
	{
		for (m = Level.Game.BaseMutator; m != None; m = m.NextMutator)
			if (MutFPSHud(m) != None)
			{
				HUDMut = MutFPSHud(m);
				break;
			}
	}

	CopyArray();
}

function CopyArray()
{
	local int x;
	local PlayerController pc;

	if (HUDMut == None)
		return;

	if (Pawn(Owner) != None)
	{
		pc = PlayerController(Pawn(Owner).Controller);
		if (pc != None)
		{
			Pawn(Owner).DeleteInventory(self);
			SetOwner(pc); 
		}
	}

	for (x = 0; x < HUDMut.InitialXPs.Length; x++)
	{
		if (HUDMut.InitialXPs[x].PlayerName != "")
			ClientReceiveXP(x, HUDMut.InitialXPs[x].PlayerName, HUDMut.InitialXPs[x].PlayerClass, HUDMut.InitialXPs[x].SubClass, HUDMut.InitialXPs[x].InitialLV, HUDMut.InitialXPs[x].CurrentXP, HUDMut.InitialXPs[x].NeededXP, HUDMut.InitialXPs[x].XPGained);
		else
			ClientReceiveXP(x, "", 0, "", 0, 0, 0, 0);
	}
}

simulated function ClientReceiveXP(int index, string PlayerName, int PlayerClass, string SubClass, int InitialLV, int CurrentXP, int NeededXP, int XPGained)
{
	if (Level.NetMode != NM_DedicatedServer)
	{
		if (index >= 0)
		{
			if (CurrentXPs.Length <= index)
				CurrentXPs.Length = index+1;
			CurrentXPs[index].PlayerName = PlayerName;
			CurrentXPs[index].PlayerClass = PlayerClass;
			CurrentXPs[index].SubClass = SubClass;
			CurrentXPs[index].InitialLV = InitialLV;
			CurrentXPs[index].CurrentXP = CurrentXP;
			CurrentXPs[index].NeededXP = NeededXP;
			CurrentXPs[index].XPGained = XPGained;
			XPsUpdated = true;
		}
	}
}

defaultproperties
{
     RemoteRole=ROLE_DumbProxy
}
