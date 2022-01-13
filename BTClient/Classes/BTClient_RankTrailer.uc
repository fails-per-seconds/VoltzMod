class BTClient_RankTrailer extends SpeedTrail;

var bool bSet;

simulated event PostBeginPlay()
{
	if (xPawn(Owner).DrawScale != 1.0)
	{
		mSizeRange[0] *= xPawn(Owner).DrawScale;
		mSizeRange[1] *= xPawn(Owner).DrawScale;
	}
}

simulated event Tick( float dt )
{
	if (xPawn(Owner) == None || xPawn(Owner).bDeRes || xPawn(Owner).bDeleteMe)
	{
		Destroy();
		return;
	}

	if (Abs(xPawn(Owner).Velocity.Z) >= 100)
	{
		if (!bSet)
		{
			bSet = True;
			mGrowthRate = -20.f;
			mRegenRange[0] = 25.f;
			mRegenRange[1] = 25.f;
		}
	}
	else
	{
		if (bSet)
		{
			bSet = False;
			mGrowthRate = 12.f;
			mRegenRange[0] = 10.f;
			mRegenRange[1] = 10.f;
		}
	}

	if (!mRegen)
		mRegen = True;
}

defaultproperties
{
     mRegenRange(0)=5.000000
     mRegenRange(1)=5.000000
     bSuspendWhenNotVisible=False
     mMassRange(0)=-0.300000
     mMassRange(1)=-0.300000
     mColorRange(0)=(B=150,G=0)
     mColorRange(1)=(B=0,G=150)
     bReplicateMovement=False
     Physics=PHYS_Trailer
     LifeSpan=0.000000
}
