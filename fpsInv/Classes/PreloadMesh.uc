class PreloadMesh extends Actor;

var() int MeshNumber;
var() int MeshCount;
var() Controller OwnerController;

simulated function Tick(float DeltaTime)
{
	local vector X, Y, Z;

	if (Controller(Owner) != None && Controller(Owner).Pawn != None)
	{
		OwnerController = Controller(Owner);
		SetOwner(Controller(Owner).Pawn);
	}
	else if (Pawn(Owner) != None)
	{
		GetAxes(Pawn(Owner).GetViewRotation(),X,Y,Z);
		SetLocation((Pawn(Owner).Location + vect(0,0,25)) + 75 * X);
	}
}

Auto State Preloading
{
	simulated function BeginState()
	{
		MeshCount = class'Fails'.default.MonsterTable.Length;
		SetDrawType(DT_Mesh);
	}

	simulated function SwapMesh()
	{
		local Class<Monster> M;
		local Mesh MMesh;

		if (MeshNumber < MeshCount)
		{
			if (class'Fails'.default.MonsterTable[MeshNumber].MonsterClass != "" && class'Fails'.default.MonsterTable[MeshNumber].MonsterClass != "None")
			{
				M = Class<Monster>(DynamicLoadObject(class'Fails'.default.MonsterTable[MeshNumber].MonsterClass, class'class',true));
				if (M != None)
				{
					MMesh = Mesh(DynamicLoadObject(string(M.default.Mesh), class'Mesh',true));
					if (MMesh != None)
					{
						LinkMesh(MMesh);
					}
				}
			}

			MeshNumber++;
		}
		else
		{
			Disable('Tick');
			Destroy();
		}
	}

Begin:
	Sleep(1.5);
	GoTo('Initialize');

Initialize:
	SwapMesh();
	Sleep(0.175);
	GoTo('Initialize');
}

defaultproperties
{
     DrawType=DT_StaticMesh
     bOnlyOwnerSee=True
     bAcceptsProjectors=False
     LifeSpan=60.000000
     DrawScale=0.250000
     Skins(0)=Texture'InvisTex'
     Skins(1)=Texture'InvisTex'
     Skins(2)=Texture'InvisTex'
     Skins(3)=Texture'InvisTex'
     Skins(4)=Texture'InvisTex'
     Skins(5)=Texture'InvisTex'
     Skins(6)=Texture'InvisTex'
     Skins(7)=Texture'InvisTex'
     Skins(8)=Texture'InvisTex'
     bUnlit=True
     bHardAttach=True
     CollisionRadius=0.000000
     CollisionHeight=0.000000
     bBlockZeroExtentTraces=False
     bBlockNonZeroExtentTraces=False
}