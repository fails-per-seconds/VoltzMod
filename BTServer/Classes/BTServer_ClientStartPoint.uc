//=============================================================================
// Copyright 2005-2010 Eliot Van Uytfanghe. All Rights Reserved.
//=============================================================================
class BTServer_ClientStartPoint extends PlayerStart
    notplaceable;

function Reset()
{
    Destroy();
}

defaultproperties
{
     bEnabled=False
     bMayCausePain=False
     bStatic=False
     bNoDelete=False
     bCollideWhenPlacing=False
     CollisionRadius=1.000000
     CollisionHeight=1.000000
     bBlockZeroExtentTraces=False
     bBlockNonZeroExtentTraces=False
}
