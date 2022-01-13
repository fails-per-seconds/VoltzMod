class ArtifactMonsterSummon extends RPGArtifact
	abstract
	config(fps);

var() Sound BrokenSound;
var MutFPS RPGMut;

static function bool ArtifactIsAllowed(GameInfo Game)
{
	if (DynamicLoadObject("SkaarjPack.Invasion", class'Class', true) == None)
		return false;

	return true;
}

function BotConsider()
{
	if (bActive)
		return;

	if ( Instigator.Health + Instigator.ShieldStrength < 100 && Instigator.Controller.Enemy != None
	     && Instigator.Controller.Adrenaline > (40+rand(60)) && NoArtifactsActive())
		Activate();
}

function PostBeginPlay()
{
	Super.PostBeginPlay();

	if (Level.Game != None)
		RPGMut = class'MutFPS'.static.GetRPGMutator(Level.Game);
	if (RPGMut != None)
		RPGMut.FillMonsterList();
	disable('Tick');
}

function Activate()
{		
	local MonsterPointsInv Inv;
	local int AdrenalineCost, MonsterPointsUsed;
	local class<Monster> ChosenMonster;
	local Monster M;
	local float SelectedLifespan;

	Inv = MonsterPointsInv(Instigator.FindInventoryType(class'MonsterPointsInv'));
	if (Inv == None)
	{
		Inv = Instigator.spawn(class'MonsterPointsInv', Instigator,,, rot(0,0,0));
		if (Inv == None)
		{
			bActive = false;
			GotoState('');
			return;
		}

		Inv.giveTo(Instigator);
	}
	ChosenMonster = ChooseMonster(AdrenalineCost, MonsterPointsUsed, inv);
	if (ChosenMonster == None)
	{
		bActive = false;
		GotoState('');
		return;
	}

	SelectedLifespan = getMonsterLifeSpan();

	M = Inv.SummonMonster(ChosenMonster, AdrenalineCost, MonsterPointsUsed);
	if (M != None && SelectedLifespan > 0)
		M.LifeSpan = SelectedLifespan;

	if (M != None && ShouldDestroy())
	{
		if (PlayerController(Instigator.Controller) != None)
	        	PlayerController(Instigator.Controller).ClientPlaySound(BrokenSound);
		Destroy();
		Instigator.NextItem();
	}
	GotoState('');
	bActive = false;
}

function Class<Monster> chooseMonster(out int AdrenalineUsed, out int MonsterPointsUsed, MonsterPointsInv Inv);

function bool ShouldDestroy();

function float getMonsterLifeSpan();

defaultproperties
{
     BrokenSound=Sound'PlayerSounds.NewGibs.RobotCrunch3'
     CostPerSec=1
     MinActivationTime=0.000001
     IconMaterial=Texture'ArtifactIcons.MonsterSummon'
     ItemName="Summoning Charm"
}
