class AbilityLoadedArtifacts extends RPGDeathAbility
	config(fps) 
	abstract;

var config Array< class<RPGArtifact> > Level1Artifact;
var config Array< class<RPGArtifact> > Level2Artifact;
var config Array< class<RPGArtifact> > Level3Artifact;
var config Array< class<RPGArtifact> > Level4Artifact;
var config Array< class<RPGArtifact> > Level5Artifact;

var config float WeaponDamage;
var config float AdrenalineDamage;
var config float AdrenalineUsage;

static function ModifyPawn(Pawn Other, int AbilityLevel)
{
	local int x;
	local LoadedInv LoadedInv;
	local bool Enhance;
	local RPGStatsInv StatsInv;

	LoadedInv = LoadedInv(Other.FindInventoryType(class'LoadedInv'));
	if (LoadedInv != None)
	{
		if (LoadedInv.bGotLoadedArtifacts && LoadedInv.LAAbilityLevel == AbilityLevel)
			return;
	}
	else
	{
		LoadedInv = Other.spawn(class'LoadedInv');
		LoadedInv.giveTo(Other);
	}

	if (LoadedInv == None)
		return;

	LoadedInv.bGotLoadedArtifacts = true;
	LoadedInv.LAAbilityLevel = AbilityLevel;

	if (AbilityLevel >= 2)
		LoadedInv.ProtectArtifacts = true;
	else
		LoadedInv.ProtectArtifacts = false;

	if (AbilityLevel > 4)
		Enhance = true;
	else
		Enhance = false;

	for(x = 0; x < default.Level1Artifact.length; x++)
		if (default.Level1Artifact[x] != None)
			giveArtifact(other, default.Level1Artifact[x], Enhance);

	if (AbilityLevel > 1)
		for(x = 0; x < default.Level2Artifact.length; x++)
			if (default.Level2Artifact[x] != None)
				giveArtifact(other, default.Level2Artifact[x], Enhance);

	if (AbilityLevel > 2)
		for(x = 0; x < default.Level3Artifact.length; x++)
			if (default.Level3Artifact[x] != None)
				giveArtifact(other, default.Level3Artifact[x], Enhance);

	if (AbilityLevel > 3)
		for(x = 0; x < default.Level4Artifact.length; x++)
			if (default.Level4Artifact[x] != None)
				giveArtifact(other, default.Level4Artifact[x], Enhance);

	if (AbilityLevel > 4)
	{
		for(x = 0; x < default.Level5Artifact.length; x++)
			if (default.Level5Artifact[x] != None)
				giveArtifact(other, default.Level5Artifact[x], Enhance);
		Other.Controller.Adrenaline = Other.Controller.AdrenalineMax;
	}

	if (AbilityLevel >= 2)
	{
		StatsInv = RPGStatsInv(Other.FindInventoryType(class'RPGStatsInv'));
		for (x = 0; StatsInv != None && x < StatsInv.Data.Abilities.length; x++)
		{
			if (StatsInv.Data.Abilities[x] == class'AbilityShieldHealing')
				giveArtifact(other, class'ArtifactShieldBlast', Enhance);

			if (StatsInv.Data.Abilities[x] == class'AbilityLoadedHealing' && StatsInv.Data.AbilityLevels[x] >= 2)
				giveArtifact(other, class'ArtifactHealingBlast', Enhance);
		}
	}

	if (Other.SelectedItem == None)
		Other.NextItem();
}

static function giveArtifact(Pawn other, class<RPGArtifact> ArtifactClass, bool Enhance)
{
	local RPGArtifact Artifact;

	if (Other.IsA('Monster'))
		return;
	if (Other.FindInventoryType(ArtifactClass) != None)
		return;

	Artifact = Other.spawn(ArtifactClass, Other,,, rot(0,0,0));
	if (Artifact != None)
	{
		if (Enhance && EnhancedRPGArtifact(Artifact) != None)
			EnhancedRPGArtifact(Artifact).EnhanceArtifact(default.AdrenalineUsage);
		Artifact.giveTo(Other);
	}
}

static function GenuineDeath(Pawn Killed, Controller Killer, class<DamageType> DamageType, vector HitLocation, int AbilityLevel)
{
	local Inventory inv;

	if (Killed.isA('Vehicle'))
	{
		Killed = Vehicle(Killed).Driver;
	}

	if (Killed == None)
	{
		return;
	}

	for(inv = Killed.Inventory ; inv != None ; inv = inv.Inventory)
	{
		if (ClassIsChildOf(inv.class, class'fps.RPGArtifact'))
			inv.PickupClass = None;
	}

	return;
}

static function HandleDamage(out int Damage, Pawn Injured, Pawn Instigator, out vector Momentum, class<DamageType> DamageType, bool bOwnedByInstigator, int AbilityLevel)
{
	if (!bOwnedByInstigator)
		return;
	if (Damage > 0 && AbilityLevel > 4)
	{
		if (ClassIsChildOf(DamageType, class'WeaponDamageType') || ClassIsChildOf(DamageType, class'VehicleDamageType'))
			Damage *= default.WeaponDamage;
		else
			Damage *= default.AdrenalineDamage;
	}
}

static function bool OverridePickupQuery(Pawn Other, Pickup item, out byte bAllowPickup, int AbilityLevel)
{
	if (ClassIsChildOf(item.InventoryType, class'EnhancedRPGArtifact'))
	{
		if (Other.FindInventoryType(item.InventoryType) != None)
		{
			bAllowPickup = 0;
			return true;
		}
	}
	return false;
}

defaultproperties
{
     Level1Artifact(0)=Class'fps.ArtifactFlight'
     Level1Artifact(1)=Class'fps.ArtifactTeleport'
     Level1Artifact(2)=Class'fps.ArtifactMagnet'
     Level1Artifact(3)=Class'fps.ArtifactMagicMaker'
     Level1Artifact(4)=Class'fps.ArtifactGlobe'
     Level2Artifact(0)=Class'fps.ArtifactTripleDamage'
     Level2Artifact(1)=Class'fps.ArtifactMaxModifier'
     Level2Artifact(2)=Class'fps.ArtifactFireBall'
     Level2Artifact(3)=Class'fps.ArtifactRemoteDamage'
     Level2Artifact(4)=Class'fps.ArtifactRemoteGlobe'
     Level2Artifact(5)=Class'fps.ArtifactRemoteMax'
     Level3Artifact(0)=Class'fps.ArtifactLightningRod'
     Level3Artifact(1)=Class'fps.ArtifactDoubleModifier'
     Level3Artifact(2)=Class'fps.ArtifactPlusModifier'
     Level3Artifact(3)=Class'fps.ArtifactMegaBlast'
     Level3Artifact(4)=Class'fps.ArtifactPoisonBlast'
     Level4Artifact(0)=Class'fps.ArtifactLightningBolt'
     Level4Artifact(1)=Class'fps.ArtifactLightningBeam'
     Level4Artifact(2)=Class'fps.ArtifactChainLightning'
     Level4Artifact(3)=Class'fps.ArtifactRepulsion'
     Level4Artifact(4)=Class'fps.ArtifactSphereGlobe'
     Level4Artifact(5)=Class'fps.ArtifactSphereDamage'
     WeaponDamage=0.500000
     AdrenalineDamage=2.000000
     AdrenalineUsage=0.500000
     AbilityName="Loaded Artifacts"
     Description="When you spawn:|Level 1: You are granted all slow drain artifacts, a magic weapon maker and the invulnerability globe.|Level 2: You are granted the triple, max, fireball and remote artifacts, and breakable artifacts are made unbreakable.|Level 3: You get the rod, blasts and some other artifacts.|Level 4: You get bolt, beam, chain and the spheres.|Extreme level 5 reduces adrenaline used in offensive attacks, but reduces damage from weapons|Cost (per level): 6,8,10,12,14"
     StartingCost=6
     CostAddPerLevel=2
     MaxLevel=5
}
