class ArtifactTeleport extends RPGArtifact;

var Emitter myEmitter;
var float AdrenalineUsed;

function BotConsider()
{
	return;
}

function DoEffect();

state Activated
{
	function BeginState()
	{
		local int x;

		myEmitter = spawn(class'TeleportChargeEffect', Instigator,, Instigator.Location, Instigator.Rotation);
		myEmitter.SetBase(Instigator);
		if (Instigator.PlayerReplicationInfo != None && Instigator.PlayerReplicationInfo.Team != None && Instigator.PlayerReplicationInfo.Team.TeamIndex == 1)
			for (x = 0; x < myEmitter.Emitters[0].ColorScale.Length; x++)
				myEmitter.Emitters[0].ColorScale[x].Color = class'Hud'.default.BlueColor;

		bActive = true;
		AdrenalineUsed = CostPerSec;
	}

	simulated function Tick(float deltaTime)
	{
		local float Cost;

		Cost = FMin(AdrenalineUsed, deltaTime * CostPerSec);
		AdrenalineUsed -= Cost;
		if (AdrenalineUsed <= 0.f)
		{
			Instigator.Controller.Adrenaline -= Cost - 0.001;
			DoEffect();
		}
		else
		{
			Global.Tick(deltaTime);
		}
	}

	function DoEffect()
	{
		local NavigationPoint Dest;
		local vector PrevLocation;
		local int EffectNum;

		if (myEmitter != None)
		{
			myEmitter.SetBase(None);
			myEmitter.Kill();
			myEmitter = None;
		}

		Dest = Instigator.Controller.FindRandomDest();
		PrevLocation = Instigator.Location;
		Instigator.SetLocation(Dest.Location + vect(0,0,40));
		if (xPawn(Instigator) != None)
			xPawn(Instigator).DoTranslocateOut(PrevLocation);
		if (Instigator.PlayerReplicationInfo != None && Instigator.PlayerReplicationInfo.Team != None)
			EffectNum = Instigator.PlayerReplicationInfo.Team.TeamIndex;
		Instigator.SetOverlayMaterial(class'TransRecall'.default.TransMaterials[EffectNum], 1.0, false);
		Instigator.PlayTeleportEffect(false, false);

		GotoState('');
	}

	function EndState()
	{
		if (myEmitter != None)
			myEmitter.Destroy();
		bActive = false;
	}
}

defaultproperties
{
     CostPerSec=25
     MinActivationTime=1.000000
     PickupClass=Class'fps.ArtifactTeleportPickup'
     IconMaterial=Texture'ArtifactIcons.Teleport'
     ItemName="Teleporter"
}
