Class BTClient_TransTrailer Extends TransTrail;

Simulated Function Tick(float dt)
{
	if (xPawn(Owner) == None || xPawn(Owner).bDeRes || xPawn(Owner).bDeleteMe)
	{
		Destroy();
		return;
	}

	if (!mRegen)
		mRegen = True;
}

defaultproperties
{
}
