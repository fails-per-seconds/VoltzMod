class ArtifactTripleDamage extends RPGArtifact
	config(fps);

var Weapon LastWeapon;
var config Array< class<RPGWeapon> > Invalid;

function BotConsider()
{
	if (bActive && (Instigator.Controller.Enemy == None || !Instigator.Controller.CanSee(Instigator.Controller.Enemy)))
	{
		Activate();
		return;
	}

	if (Instigator.Controller.Adrenaline < 30)
		return;

	if (bActive && (Instigator.Controller.Enemy == None || !Instigator.Controller.CanSee(Instigator.Controller.Enemy)))
		Activate();
	else if ( !bActive && Instigator.Controller.Enemy != None && Instigator.Weapon != None && Instigator.Weapon.AIRating > 0.5
		  && Instigator.Controller.Enemy.Health > 70 && Instigator.Controller.CanSee(Instigator.Controller.Enemy) && NoArtifactsActive() && FRand() < 0.7 )
		Activate();
}

function Activate()
{
	if (class'ArtifactDoubleModifier'.static.HasDoubleModifierRunning(Instigator))
		return;

	if (class'ArtifactDoubleModifier'.static.HasRodRunning(Instigator))
		return;

	if (!bActive && Instigator.HasUDamage())
		return;

	Super.Activate();
}

function bool HandlePickupQuery(Pickup Item)
{
	if (Super.HandlePickupQuery(Item))
		return true;
	if (UDamagePack(Item) != None && bActive)
		Activate();

	return false;
}

state Activated
{
	function BeginState()
	{
		local Vehicle V;

		Instigator.DamageScaling *= 1.5;
		V = Vehicle(Instigator);
		if (V != None && V.Driver != None)
		{
			V.Driver.EnableUDamage(1000000.f);
		}
		else
		{
			Instigator.EnableUDamage(1000000.f);
		}
		bActive = true;
	}

	function Tick(float deltatime)
	{
		local int i;

		if (bActive)
		{
			if (Instigator != None && Instigator.Controller != None)
			{
				Instigator.Controller.Adrenaline -= deltaTime * CostPerSec;
				if (Instigator.Controller.Adrenaline <= 0.0)
				{
					Instigator.Controller.Adrenaline = 0.0;
					UsedUp();
				}
			}
		}

		if (Instigator == None || RPGWeapon(Instigator.Weapon) == None)
		{
			return;
		}
		for(i = 0; i < Invalid.length; i++)
		{
			if (Instigator.Weapon.class == Invalid[i])
			{
				Instigator.ReceiveLocalizedMessage(MessageClass, 2906, None, None, Class);
				GotoState('');
				bActive=false;
				return;
			}
		}
	}

	function EndState()
	{
		local Vehicle V;

		if (Instigator != None)
		{
			Instigator.DamageScaling /= 1.5;
			V = Vehicle(Instigator);
			if (V != None && V.Driver != None)
			{
				V.Driver.DisableUDamage();
			}
			else
			{
				Instigator.DisableUDamage();
			}
		}
		bActive = false;
	}
}

static function string GetLocalString(optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2)
{
	if (Switch == 2906)
		return "Unable to use Triple Damage on this magic weapon type.";
	else 
		return(super.getLocalString(switch, RelatedPRI_1, RelatedPRI_2));
}

defaultproperties
{
     Invalid[0]=Class'fps.RW_Rage'
     CostPerSec=10
     PickupClass=Class'fps.ArtifactTripleDamagePickup'
     IconMaterial=Texture'ArtifactIcons.triple'
     ItemName="Triple Damage"
}
