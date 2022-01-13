class ArtifactSphereDamage extends EnhancedRPGArtifact
		config(fps);

var config int AdrenalineRequired;
var config float KillXPPerc;
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

	if (Instigator.Controller.Adrenaline < AdrenalineRequired*2)
		return;

	if ( !bActive && Instigator.Controller.Enemy != None
		   && Instigator.Controller.CanSee(Instigator.Controller.Enemy) && NoArtifactsActive() && !Instigator.HasUDamage() && FRand() < 0.6 )
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

function SetTeamDamage(vector CoreLocation)
{
	local Controller C;
	local DamageInv Inv;

	C = Level.ControllerList;
	while (C != None)
	{
		if (C.Pawn != None && vehicle(C.Pawn) == None && C.Pawn != Instigator && C.Pawn.Health > 0 && C.SameTeamAs(Instigator.Controller)
		     && VSize(C.Pawn.Location - CoreLocation) < EffectRadius && !C.Pawn.HasUDamage() && RedeemerWarhead(C.Pawn) == None)
		{
			Inv = spawn(class'DamageInv', C.Pawn,,, rot(0,0,0));
			if (Inv != None)
			{
				Inv.CoreLocation = CoreLocation;
				Inv.Rules = Rules;
				Inv.KillXPPerc = KillXPPerc;
				Inv.EffectRadius = EffectRadius;
				Inv.DamagePlayerController = Instigator.Controller;
				Inv.EstimatedRunTime = 3*Instigator.Controller.Adrenaline / CostPerSec;
				Inv.GiveTo(C.Pawn);
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

			SpawnLocation = Instigator.Location;
			switch (EffectRadius) 
			{
				case 500:
					spawn(class'SphereDamage500r', Instigator.Controller,,SpawnLocation);
					break;
				case 700:
					spawn(class'SphereDamage700r', Instigator.Controller,,SpawnLocation);
					break;
				default:
					Log("ArtifactSphereDamage invalid radius used. Should be 500");
					spawn(class'SphereDamage500r', Instigator.Controller,,SpawnLocation);
					break;
			}
			Instigator.EnableUDamage(9999.0);
			Instigator.SetOverlayMaterial(EffectOverlay, 2*Instigator.Controller.Adrenaline / CostPerSec, true);
			bActive = true;

			SetTeamDamage(SpawnLocation);
			SetTimer(0.5, true);
		}
	}
	function Timer()
	{
		if (bActive)
		{
			if (Instigator.Controller == None)
			{
				bActive = false;
				if (Instigator != None)
				{
					Instigator.DisableUDamage();
					Instigator.SetOverlayMaterial(EffectOverlay, -1, true);
				}
				GotoState('');
				return;	
			}
			switch (EffectRadius) 
			{
				case 500:
					spawn(class'SphereDamage500r', Instigator.Controller,,SpawnLocation);
					break;
				case 700:
					spawn(class'SphereDamage700r', Instigator.Controller,,SpawnLocation);
					break;
				default:
					spawn(class'SphereDamage500r', Instigator.Controller,,SpawnLocation);
					break;
			}
			SetTeamDamage(SpawnLocation);
		}
	}
	function EndState()
	{
		SetTimer(0, false);
		if (Instigator != None)
		{
			Instigator.DisableUDamage();
			Instigator.SetOverlayMaterial(EffectOverlay, -1, true);
		}
		bActive = false;
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
	else if (Switch == 0)
		return "Your adrenaline has run out.";
	else
		return switch @ "Adrenaline is required to use this artifact";
}

defaultproperties
{
     AdrenalineRequired=40
     KillXPPerc=0.500000
     AdrenalinePerSecond=10
     EffectRadius=900.000000
     EffectOverlay=Shader'XGameShaders.PlayerShaders.WeaponUDamageShader'
     CostPerSec=10
     PickupClass=Class'fps.ArtifactSphereDamagePickup'
     IconMaterial=Texture'ArtifactIcons.SphereDamage'
     ItemName="Damage Sphere"
}
