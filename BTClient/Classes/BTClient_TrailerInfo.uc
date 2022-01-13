class BTClient_TrailerInfo extends Info
    notplaceable;

var Pawn Pawn, OldPawn;
struct sRankData
{
	var string TrailerTexture;
	var color TrailerColor[2];
};
var sRankData RankSkin;
var Class<BTClient_RankTrailer> TrailerClass;

var const name Bones[2];

replication
{
	reliable if (bNetDirty && (Role == ROLE_Authority))
		Pawn;

	reliable if ((Role == ROLE_Authority) && bNetInitial)
		RankSkin, TrailerClass;
}

simulated event PreBeginPlay()
{
	Super.PreBeginPlay();
	if (Class'BTClient_Config'.static.FindSavedData().bNoTrailers || Class'BTClient_Config'.static.FindSavedData().bProfesionalMode)
		Destroy();
}

Simulated Function PostNetReceive()
{
	local int i;

	Super.PostNetReceive();
	if (Pawn != None && Pawn != OldPawn)
	{
		if (Pawn != none)
		{
			for(i = 0; i < Pawn.Attached.Length; ++i)
			{
				if (Pawn.Attached[i] == none || Pawn.Attached[i].Class != TrailerClass)
					continue;

				Pawn.Attached[i].Destroy();
				Pawn.Attached.Remove(i, 1);
				--i;
			}
		}

		AddRewards(Pawn);
		OldPawn = Pawn;
	}
}

Simulated Function AddRewards(Pawn Other)
{
	local xEmitter E;
	local Material M;
	local int i;

	if (Other == None)
		return;

	if (TrailerClass == None)
		TrailerClass = Default.TrailerClass;

	M = Material(DynamicLoadObject(RankSkin.TrailerTexture, Class'Material', True));
	for(i = 0; i < 2; i++)
	{
		E = Spawn(TrailerClass, Other);
		if (E != None)
		{
			if (M != None)
				E.Skins[0] = M;

			E.mColorRange[0] = RankSkin.TrailerColor[0];
			E.mColorRange[1] = RankSkin.TrailerColor[1];
			Other.AttachToBone(E, Bones[i]);
		}
	}
}

event Tick(float DeltaTime)
{
	if (Role == ROLE_Authority)
	{
		if (PlayerController(Owner) == None)
		{
			Destroy();
			return;
		}
	}
}

defaultproperties
{
     TrailerClass=Class'BTClient_RankTrailer'
     Bones(0)="lfoot"
     Bones(1)="rfoot"
     bAlwaysRelevant=True
     RemoteRole=ROLE_SimulatedProxy
     bAlwaysTick=True
     bNetNotify=True
}
