class ArtifactGlobe extends RPGArtifact;

var Material EffectOverlay;
var Controller InstigatorController;

function BotConsider()
{
	if (Instigator.Controller.Adrenaline < 30)
		return;

	if (bActive && (Instigator.Controller.Enemy == None || !Instigator.Controller.CanSee(Instigator.Controller.Enemy)))
		Activate();
	else if ( !bActive && Instigator.Controller.Enemy != None
		  && Instigator.Health < 70 && Instigator.Controller.CanSee(Instigator.Controller.Enemy) && NoArtifactsActive() && FRand() < 0.7 )
		Activate();
}

state Activated
{
	function BeginState()
	{
		if (InstigatorController != None)
		{
			Warn("A player picked up Globe while another still has the same actor active!");
			Destroy();
		}
		else
		{
			InstigatorController = Instigator.Controller;
			InstigatorController.bGodMode = true;
			Instigator.SetOverlayMaterial(EffectOverlay, Instigator.Controller.Adrenaline / CostPerSec, true);
			bActive = true;
		}
	}

	function EndState()
	{
		if (InstigatorController != None)
		{
			InstigatorController.bGodMode = false;
			InstigatorController = None;
		}
		if (Instigator != None)
		{
			Instigator.SetOverlayMaterial(EffectOverlay, -1, true);
		}
		bActive = false;
	}
}

defaultproperties
{
     EffectOverlay=Shader'GlobeOverlay'
     CostPerSec=12
     PickupClass=Class'fps.ArtifactGlobePickup'
     IconMaterial=Texture'ArtifactIcons.Globe'
     ItemName="Globe"
}
