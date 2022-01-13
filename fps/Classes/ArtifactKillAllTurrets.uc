class ArtifactKillAllTurrets extends RPGArtifact;

function Activate()
{
	local EngineerPointsInv Inv;

	Inv = class'AbilityLoadedEngineer'.static.GetEngInv(Instigator);
	if (Inv != None)
		Inv.KillAllTurrets();

	bActive = false;
	GotoState('');
	return;
}

exec function TossArtifact()
{
	//do nothing.
}

function PostBeginPlay()
{
	super.PostBeginPlay();
	disable('Tick');
}

function DropFrom(vector StartLocation)
{
	if (bActive)
		GotoState('');
	bActive = false;

	Destroy();
	Instigator.NextItem();
}

function BotConsider()
{
	return;
}

defaultproperties
{
     MinActivationTime=0.000000
     IconMaterial=Texture'KillSummonTurretIcon'
     ItemName="Kill All Turrets"
}
