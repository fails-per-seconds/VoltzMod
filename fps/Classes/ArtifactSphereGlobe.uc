class ArtifactSphereGlobe extends EnhancedRPGArtifact
		config(fps);

var config int AdrenalineRequired;
var config float ExpPerDamage;
var config int AdrenalinePerSecond;
var config float EffectRadius;

var RPGRules Rules;
var vector SpawnLocation;
var Material EffectOverlay;

function BotConsider()
{
	if (bActive && (Instigator.Controller.Enemy == None || !Instigator.Controller.CanSee(Instigator.Controller.Enemy)))
	{
		Activate();
		return;
	}

	if (Instigator.Controller.Adrenaline < AdrenalineRequired)
		return;

	if ( !bActive && Instigator.Controller.Enemy != None
		   && Instigator.Controller.CanSee(Instigator.Controller.Enemy) && NoArtifactsActive() && !Instigator.Controller.bGodMode && FRand() < 0.3 )
		Activate();
}

simulated function PostBeginPlay()
{
	CostPerSec = AdrenalinePerSecond*AdrenalineUsage;

	super.PostBeginPlay();

	CheckRPGRules();
}

function EnhanceArtifact(float Adusage)
{
	Super.EnhanceArtifact(AdUsage);
	
	CostPerSec = AdrenalinePerSecond * (AdrenalineUsage + 1.0) / 2.0;
	EffectRadius = 500;
}

function CheckRPGRules()
{
	local GameRules G;

	if (Level.Game == None)
		return;

	for(G = Level.Game.GameRulesModifiers; G != None; G = G.NextGameRules)
	{
		if (G.IsA('RPGRules'))
		{
			Rules = RPGRules(G);
			break;
		}
	}

	if (Rules == None)
		Log("WARNING: Unable to find RPGRules in GameRules. EXP will not be properly awarded");
}

function SetTeamInvulnerable(vector CoreLocation)
{
	local Controller C;
	local GlobeInv Inv;

	C = Level.ControllerList;
	while (C != None)
	{
		if (C.Pawn != None && C.Pawn != Instigator && C.Pawn.Health > 0 && C.SameTeamAs(Instigator.Controller)
		     && VSize(C.Pawn.Location - CoreLocation) < EffectRadius && C.bGodMode == False && Vehicle(C.Pawn) == None && RedeemerWarhead(C.Pawn) == None)
		{
			if (GlobeInv(C.Pawn.FindInventoryType(class'GlobeInv')) == None)
			{
				Inv = spawn(class'GlobeInv', C.Pawn,,, rot(0,0,0));
				if (Inv != None)
				{
					Inv.CoreLocation = CoreLocation;
					Inv.Rules = Rules;
					Inv.ExpPerDamage = ExpPerDamage;
					Inv.EffectRadius = EffectRadius;
					Inv.InvPlayerController = Instigator.Controller;
					Inv.EstimatedRunTime = 4*Instigator.Controller.Adrenaline*AdrenalineUsage / CostPerSec;
					Inv.GiveTo(C.Pawn);
				}
			}
		}
		C = C.NextController;
	}
}

state Activated
{
	function BeginState()
	{
		local Vehicle V;
		local GlobeInv Inv;

		if (Rules == None)
			CheckRPGRules();

		if ((Instigator != None) && (Instigator.Controller != None))
		{
			if (Instigator.Controller.Adrenaline < (AdrenalineRequired*AdrenalineUsage))
			{
				Instigator.ReceiveLocalizedMessage(MessageClass, AdrenalineRequired*AdrenalineUsage, None, None, Class);
				bActive = false;
				GotoState('');
				return;
			}
		
			V = Vehicle(Instigator);
			if (V != None)
			{
				Instigator.ReceiveLocalizedMessage(MessageClass, 3000, None, None, Class);
				bActive = false;
				GotoState('');
				return;
			}

			if (GlobeInv(Instigator.FindInventoryType(class'GlobeInv')) != None)
			{
				Instigator.ReceiveLocalizedMessage(MessageClass, 4000, None, None, Class);
				bActive = false;
				GotoState('');
				return;
			}

			SpawnLocation = Instigator.Location;
			switch (EffectRadius) 
			{
				case 500:
					spawn(class'SphereGlobe500r', Instigator.Controller,,SpawnLocation);
					break;
				case 700:
					spawn(class'SphereGlobe700r', Instigator.Controller,,SpawnLocation);
					break;
				default:
					Log("ArtifactSphereGlobe invalid radius used. Should be 500");
					spawn(class'SphereGlobe500r', Instigator.Controller,,SpawnLocation);
					break;
			}

			Inv = spawn(class'GlobeInv', Instigator,,, rot(0,0,0));
			if (Inv != None)
			{
				Inv.CoreLocation = SpawnLocation;
				Inv.Rules = Rules;
				Inv.ExpPerDamage = ExpPerDamage;
				Inv.EffectRadius = EffectRadius;
				Inv.InvPlayerController = Instigator.Controller;
				Inv.EstimatedRunTime = 10*Instigator.Controller.Adrenaline*AdrenalineUsage / CostPerSec;
				Inv.GiveTo(Instigator);
			}
			bActive = true;

			SetTeamInvulnerable(SpawnLocation);
			SetTimer(0.5, true);
		}
	}
	function Timer()
	{
		if (bActive)
		{
			switch (EffectRadius) 
			{
				case 500:
					spawn(class'SphereGlobe500r', Instigator.Controller,,SpawnLocation);
					break;
				case 700:
					spawn(class'SphereGlobe700r', Instigator.Controller,,SpawnLocation);
					break;
				default:
					spawn(class'SphereGlobe500r', Instigator.Controller,,SpawnLocation);
					break;
			}
			SetTeamInvulnerable(SpawnLocation);
		}
	}
	function EndState()
	{
		local Controller C;
		local GlobeInv IInv;
		
		SetTimer(0, false);
		if (Instigator != None)
		{
			Instigator.SetOverlayMaterial(EffectOverlay, -1, true);
		}
		bActive = false;

		C = Level.ControllerList;
		while (C != None)
		{
			if (C.Pawn != None)
			{
				IInv = GlobeInv(C.Pawn.FindInventoryType(class'GlobeInv'));
				if (IInv != None && IInv.InvPlayerController == Instigator.Controller)
				{
					IInv.SwitchOffGlobe();
					IInv.Destroy();
				}
			}
			
			C = C.NextController;
		}
	}
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
	if (Switch == 3000)
		return "Cannot use this artifact inside a vehicle";
	else if (Switch == 4000)
		return "You cannot run this artifact at this time";
	else if (Switch == 0)
		return "Your adrenaline has run out.";
	else
		return switch @ "Adrenaline is required to use this artifact";
}

defaultproperties
{
     AdrenalineRequired=72
     ExpPerDamage=0.030000
     AdrenalinePerSecond=18
     EffectRadius=900.000000
     EffectOverlay=Shader'GlobeOverlay'
     CostPerSec=18
     PickupClass=Class'fps.ArtifactSphereGlobePickup'
     IconMaterial=Texture'ArtifactIcons.SphereInvulnerability'
     ItemName="Safety Sphere"
}
