class ArtifactMaxModifier extends RPGArtifact;

var Pawn RealInstigator;
var RPGWeapon Weapon;
var bool needsIdentify;

function BotConsider()
{
	if (Instigator.Controller.Adrenaline < getCost())
		return;

	Weapon = RPGWeapon(Instigator.Weapon);
	if (Weapon == None || Weapon.Modifier >= Weapon.MaxModifier)
		return;

	if ( !bActive && NoArtifactsActive() && FRand() < 0.7 )
		Activate();
}

function PostBeginPlay()
{
	super.PostBeginPlay();
	disable('Tick');
}

function Activate()
{
	local Vehicle V;

	if (Instigator != None)
	{
		if (Instigator.Controller.Adrenaline < getCost())
		{
			Instigator.ReceiveLocalizedMessage(MessageClass, getCost(), None, None, Class);
			bActive = false;
			GotoState('');
			return;
		}

		V = Vehicle(Instigator);
		if (V != None && V.Driver != None)
			RealInstigator = V.Driver;
		else
			RealInstigator = Instigator;

		Weapon = RPGWeapon(RealInstigator.Weapon);
		if (Weapon != None)
		{
			if (Weapon.Modifier >= Weapon.MaxModifier)
			{
				Instigator.ReceiveLocalizedMessage(MessageClass, 3000, None, None, Class);
				bActive = false;
				GotoState('');
				return;
			}

			Weapon.Modifier = Weapon.MaxModifier;
			needsIdentify = true;
			SetTimer(1, true);

			if (Weapon.IsA('RW_Speedy'))
				(RW_Speedy(Weapon)).deactivate();
			Instigator.Controller.Adrenaline -= getCost();

			bActive = false;
			GotoState('');
			return;			
		}
		else
		{
			Instigator.ReceiveLocalizedMessage(MessageClass, 2000, None, None, Class);
			bActive = false;
			GotoState('');
			return;
		}
	}
	else
	{
		Instigator.ReceiveLocalizedMessage(MessageClass, 2000, None, None, Class);
		bActive = false;
		GotoState('');
		return;
	}
}

function Timer()
{
	if (needsIdentify && Weapon != None)
	{
		Weapon.Identify();
		needsIdentify=false;
	}
	SetTimer(0, false);
}

exec function TossArtifact()
{
	//do nothing.
}

function DropFrom(vector StartLocation)
{
	if (bActive)
		GotoState('');
	bActive = false;

	Destroy();
	Instigator.NextItem();
}

static function string GetLocalString(optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2)
{
	if (Switch == 2000)
		return "Unable to modify magic weapon";
	if (Switch == 3000)
		return "Magic weapon is already at or above the maximum modifier.";
	else
		return switch @ "Adrenaline is required to generate a magic weapon";
}

function int getCost()
{
	return 150;
}

defaultproperties
{
     CostPerSec=1
     MinActivationTime=0.000001
     IconMaterial=FinalBlend'XGameTextures.SuperPickups.UDamageC'
     ItemName="Max Modifier"
}
