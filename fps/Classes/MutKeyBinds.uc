class MutKeyBinds extends Mutator
	config(fps);

var RPGRules rules;
var config class<RPGDamageGameRules> DamageRules;

struct ArtifactKeyConfig
{
	Var String Alias;
	var Class<RPGArtifact> ArtifactClass;
};
var config Array<ArtifactKeyConfig> ArtifactKeyConfigs;

function PostBeginPlay()
{
	Enable('Tick');
}

function ModifyPlayer(Pawn Other)
{
	local GiveItemsInv GIInv;

	super.ModifyPlayer(Other);

	if (Other == None || Other.Controller == None || !Other.Controller.IsA('PlayerController'))
		return;

	GIInv = class'GiveItemsInv'.static.GetGiveItemsInv(Other.Controller);
	if (GIInv != None)
		return;

	GIInv = Spawn(class'GiveItemsInv', Other);
	GIInv.KeysMut = self;

	GIInv.Inventory = Other.Controller.Inventory;
	Other.Controller.Inventory = GIInv;

	GIInv.SetOwner(Other.Controller);

	GIInv.InitializeKeyArray();
	GIInv.InitializeSubClasses(Other);
}

function Tick(float deltaTime)
{
	local GameRules G;
	local RPGDamageGameRules DG;

	if (rules != None)
	{
		Disable('Tick');
		return;
	}

	if (Level.Game.GameRulesModifiers == None)
		warn("Warning: There is no RPG Loaded. fps cannot function.");
	else
	{
		for(G = Level.Game.GameRulesModifiers; G != None; G = G.NextGameRules)
		{
			if (G.isA('RPGRules'))
				rules = RPGRules(G);
			if (G.NextGameRules == None)
			{
				if (rules == None)
				{
					warn("Warning: There is no RPG Loaded. fps cannot function.");
					return;
				}
			}
		}

		Log("DamageRules:" $ DamageRules);
		if (DamageRules != None)
		{
			DG = spawn(DamageRules);
			if (Level.Game.GameRulesModifiers != None && Level.Game.GameRulesModifiers.IsA('RPGRules'))
			{
				DG.NextGameRules = Level.Game.GameRulesModifiers;
				Level.Game.GameRulesModifiers = DG;
			}
			else
			{
				for(G = Level.Game.GameRulesModifiers; G != None; G = G.NextGameRules)
				{
					if (G.NextGameRules != None && G.NextGameRules.IsA('RPGRules'))
					{
						DG.NextGameRules = G.NextGameRules;
						G.NextGameRules = DG;
					}
				}
			}
			DG.xRules = RPGRules(DG.NextGameRules);
		}

		Level.Game.GameRulesModifiers.AddGameRules(spawn(class'RPGGameRules'));
		Disable('Tick');
		return;
	}
}

defaultproperties
{
     DamageRules=Class'fps.RPGDamageGameRules'
     ArtifactKeyConfigs(0)=(Alias="SelectTriple",ArtifactClass=Class'fps.ArtifactTripleDamage')
     ArtifactKeyConfigs(1)=(Alias="SelectGlobe",ArtifactClass=Class'fps.ArtifactGlobe')
     ArtifactKeyConfigs(2)=(Alias="SelectMWM",ArtifactClass=Class'fps.ArtifactMagicMaker')
     ArtifactKeyConfigs(3)=(Alias="SelectDouble",ArtifactClass=Class'fps.ArtifactDoubleModifier')
     ArtifactKeyConfigs(4)=(Alias="SelectMax",ArtifactClass=Class'fps.ArtifactMaxModifier')
     ArtifactKeyConfigs(5)=(Alias="SelectPlusOne",ArtifactClass=Class'fps.ArtifactPlusModifier')
     ArtifactKeyConfigs(6)=(Alias="SelectBolt",ArtifactClass=Class'fps.ArtifactLightningBolt')
     ArtifactKeyConfigs(7)=(Alias="SelectRepulsion",ArtifactClass=Class'fps.ArtifactRepulsion')
     ArtifactKeyConfigs(8)=(Alias="SelectFreezeBomb",ArtifactClass=Class'fps.ArtifactFreezeBomb')
     ArtifactKeyConfigs(9)=(Alias="SelectPoisonBlast",ArtifactClass=Class'fps.ArtifactPoisonBlast')
     ArtifactKeyConfigs(10)=(Alias="SelectMegaBlast",ArtifactClass=Class'fps.ArtifactMegaBlast')
     ArtifactKeyConfigs(11)=(Alias="SelectHealingBlast",ArtifactClass=Class'fps.ArtifactHealingBlast')
     ArtifactKeyConfigs(12)=(Alias="SelectMedic",ArtifactClass=Class'fps.ArtifactMakeSuperHealer')
     ArtifactKeyConfigs(13)=(Alias="SelectFlight",ArtifactClass=Class'fps.ArtifactFlight')
     ArtifactKeyConfigs(14)=(Alias="SelectMagnet",ArtifactClass=Class'fps.ArtifactMagnet')
     ArtifactKeyConfigs(15)=(Alias="SelectTeleport",ArtifactClass=Class'fps.ArtifactTeleport')
     ArtifactKeyConfigs(16)=(Alias="SelectBeam",ArtifactClass=Class'fps.ArtifactLightningBeam')
     ArtifactKeyConfigs(17)=(Alias="SelectRod",ArtifactClass=Class'fps.ArtifactLightningRod')
     ArtifactKeyConfigs(18)=(Alias="SelectSphereInv",ArtifactClass=Class'fps.ArtifactSphereGlobe')
     ArtifactKeyConfigs(19)=(Alias="SelectSphereHeal",ArtifactClass=Class'fps.ArtifactSphereHealing')
     ArtifactKeyConfigs(20)=(Alias="SelectSphereDamage",ArtifactClass=Class'fps.ArtifactSphereDamage')
     ArtifactKeyConfigs(21)=(Alias="SelectRemoteDamage",ArtifactClass=Class'fps.ArtifactRemoteDamage')
     ArtifactKeyConfigs(22)=(Alias="SelectRemoteInv",ArtifactClass=Class'fps.ArtifactRemoteGlobe')
     ArtifactKeyConfigs(23)=(Alias="SelectRemoteMax",ArtifactClass=Class'fps.ArtifactRemoteMax')
     ArtifactKeyConfigs(24)=(Alias="SelectShieldBlast",ArtifactClass=Class'fps.ArtifactShieldBlast')
     ArtifactKeyConfigs(25)=(Alias="SelectChain",ArtifactClass=Class'fps.ArtifactChainLightning')
     ArtifactKeyConfigs(26)=(Alias="SelectFireBall",ArtifactClass=Class'fps.ArtifactFireBall')
     ArtifactKeyConfigs(27)=(Alias="SelectRemoteBooster",ArtifactClass=Class'fps.ArtifactRemoteBooster')
     GroupName="FPSRules"
     FriendlyName="fps KeyBinds"
     Description="Allow users to bind keys for selecting RPG Artifacts"
     bAlwaysRelevant=True
     RemoteRole=ROLE_SimulatedProxy
}
