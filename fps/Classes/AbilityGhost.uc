class AbilityGhost extends RPGDeathAbility
	abstract;

static function bool GenuinePreventDeath(Pawn Killed, Controller Killer, class<DamageType> DamageType, vector HitLocation, int AbilityLevel)
{
	local GhostInv Inv;
	local Vehicle V;
	local NullEntropyInv NInv;
	local KnockbackInv KInv;
	local DamageInv DInv;
	local GlobeInv IInv;

	if (Killed.IsA('ASVehicle_SpaceFighter') || (Killed.DrivenVehicle != None && Killed.DrivenVehicle.IsA('ASVehicle_SpaceFighter')))
		return false;

	if (Killed.IsA('Monster') || xEnergyWall(Killed) != None || (ASVehicle(Killed) != None && ASVehicle(Killed).bNonHumanControl))
		return false;

	if (Killed.bStationary || Killed.IsA('SVehicle'))
	{
		V = Vehicle(Killed);
		if (V != None && !V.bRemoteControlled && !V.bEjectDriver && V.Driver != None)
			V.Driver.Died(Killer, DamageType, HitLocation);
		return false;
	}

	Inv = GhostInv(Killed.FindInventoryType(class'GhostInv'));
	if (Inv != None)
		return false;

	if (Killed.DrivenVehicle != None)
	{
		Killed.Health = 1;
		Killed.DrivenVehicle.KDriverLeave(true);
	}

	KInv = KnockbackInv(Killed.FindInventoryType(class'KnockbackInv'));
	if (KInv != None)
	{
		KInv.PawnOwner = None;
		KInv.Destroy();
	}
	NInv = NullEntropyInv(Killed.FindInventoryType(class'NullEntropyInv'));
	if (NInv != None)
	{
		NInv.PawnOwner = None;
		NInv.Destroy();
	}	
	DInv = DamageInv(Killed.FindInventoryType(class'DamageInv'));
	if (DInv != None)
	{
		DInv.SwitchOffDamage();
		DInv.Destroy();
	}	
	IInv = GlobeInv(Killed.FindInventoryType(class'GlobeInv'));
	if (IInv != None)
	{
		IInv.SwitchOffGlobe();
		IInv.Destroy();
	}	

	Inv = Killed.spawn(class'GhostInv', Killed,,, rot(0,0,0));
	Inv.OwnerAbilityLevel = AbilityLevel;
	Inv.GiveTo(Killed);
	return true;
}

static function bool PreventSever(Pawn Killed, name boneName, int Damage, class<DamageType> DamageType, int AbilityLevel)
{
	local GhostInv Inv;

	Inv = GhostInv(Killed.FindInventoryType(class'GhostInv'));
	if (Inv != None)
		return false;

	return true;
}

defaultproperties
{
     MinHealthBonus=200
     MinDR=50
     LevelCost(1)=40
     LevelCost(2)=25
     LevelCost(3)=20
     ExcludingAbilities(0)=Class'fps.AbilityUltima'
     ExcludingAbilities(1)=Class'fps.AbilityGhost'
     AbilityName="Ghost"
     Description="The first time each spawn that you take damage that would kill you, instead of dying you will become non-corporeal and move to a new location, where you will continue your life. At level 1 you will move slowly as a ghost and return with a health of 1. At level 2 you will move somewhat more quickly and will return with 100 health. At level 3 you will move fastest and will return with your normal starting health. You need to have at least 200 Health Bonus and 50 Damage Reduction to purchase this ability. |Cost (per level): 40,25,20"
     MaxLevel=3
}
