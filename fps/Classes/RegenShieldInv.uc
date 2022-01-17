class RegenShieldInv extends Inventory
	config(fps);

var int NoDamageDelay, MaxShieldRegen, lastHealth, lastShield, ElapsedNoDamage;
var float ShieldFraction, ShieldRegenRate;

function bool HasActiveArtifact()
{
	return class'ActiveArtifactInv'.static.hasActiveArtifact(Instigator);
}

function PostBeginPlay()
{
	ShieldFraction = 0.0;
	ElapsedNoDamage = 0;

	Super.PostBeginPlay();
}

function Timer()
{
	local int NewH, NewS, AddAmt, R;

	if (Instigator == None || Instigator.Health <= 0)
	{
		Destroy();
		return;
	}

	NewH = Instigator.Health;
	NewS = Instigator.GetShieldStrength();
	if (lastHealth > NewH || lastShield > NewS)
		ElapsedNoDamage = 0;
	else
		ElapsedNoDamage++;

	if (MaxShieldRegen == 150 && xPawn(Instigator) != None)
		R = xPawn(Instigator).ShieldStrengthMax - NewS;
	else	
		R = MaxShieldRegen - NewS;

	if (R > 0 && (ElapsedNoDamage > NoDamageDelay))
	{
		ShieldFraction += ShieldRegenRate;
		AddAmt = int(ShieldFraction);
		ShieldFraction -= AddAmt;
		if (AddAmt >= 1)
		{
			if (AddAmt < R)
			{
				Instigator.AddShieldStrength(AddAmt);
			}
			else
			{
				Instigator.AddShieldStrength(R);
				ShieldFraction = 0.0;
			}
		}
	} 
	else
	{
		ShieldFraction = 0.0;
	}

	lastHealth = NewH;
	lastShield = Instigator.GetShieldStrength();
}

defaultproperties
{
     RemoteRole=ROLE_DumbProxy
}
