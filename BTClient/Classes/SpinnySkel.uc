class SpinnySkel extends SpinnyWeap;

function Tick(float deltaTime)
{
	CurrentTime += deltaTime/Level.TimeDilation;

	if (bPlayRandomAnims && CurrentTime >= NextAnimTime)
		PlayNextAnim();
}

defaultproperties
{
}
