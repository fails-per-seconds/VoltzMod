class RegenAdrenInv extends Inventory
	config(fps);

var config int RegenAmount;
var bool bAlwaysGive;
var int WaveNum, WaveBonus;
var config float ReplenishAdrenPercent;

function bool HasActiveArtifact()
{
	return class'ActiveArtifactInv'.static.hasActiveArtifact(Instigator);
}

function Timer()
{
	local Controller C;

	if (Instigator == None || Instigator.Health <= 0)
	{
		Destroy();
		return;
	}

	C = Instigator.Controller;
	if (C == None && Instigator.DrivenVehicle != None)
		C = Instigator.DrivenVehicle.Controller;

	if (C == None)
		return;

	if (!Instigator.InCurrentCombo() && (bAlwaysGive || !HasActiveArtifact()))
		C.AwardAdrenaline(RegenAmount);

	if (Level.Game.IsA('Invasion') && Invasion(Level.Game).WaveNum != WaveNum)
	{
		WaveNum = Invasion(Level.Game).WaveNum;
		C.AwardAdrenaline(WaveBonus * ReplenishAdrenPercent * C.AdrenalineMax);
	}
}

defaultproperties
{
     RegenAmount=1
     WaveNum=-1
     ReplenishAdrenPercent=0.100000
     RemoteRole=ROLE_DumbProxy
}
