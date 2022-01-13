class ArtifactKillAllPets extends RPGArtifact;

function Activate()
{
	local MonsterPointsInv Inv;

	Inv = MonsterPointsInv(Instigator.FindInventoryType(class'MonsterPointsInv'));
	if (Inv != None)
		Inv.KillAllMonsters();

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
     IconMaterial=Texture'KillSummoningCharmIcon'
     ItemName="Kill All Pets"
}
