class AbilityUltima extends RPGDeathAbility
	abstract;

static function bool AbilityIsAllowed(GameInfo Game, MutFPS RPGMut)
{
	return true;
}

static function PotentialDeathPending(Pawn Killed, Controller Killer, class<DamageType> DamageType, vector HitLocation, int AbilityLevel)
{
	local GhostUltimaCharger guc;

	if (Vehicle(Killed) != None)
		return;
	else if (!Killed.Level.Game.IsA('ASGameInfo') && Killed.Location.Z > Killed.Region.Zone.KillZ && Killed.FindInventoryType(class'KillMarker') != None)
	{
		guc = Killed.spawn(class'GhostUltimaCharger', Killed.Controller);
		if (guc != None)
		{
			guc.ChargeTime = 4.0 / AbilityLevel;
			guc.Damage = guc.default.Damage * (AbilityLevel+2) / 3.0;
			guc.DamageRadius = guc.default.DamageRadius * (AbilityLevel+2) / 4.0;
		}
	} 
  
	return;
}

static function ScoreKill(Controller Killer, Controller Killed, bool bOwnedByKiller, int AbilityLevel)
{
        if (!Killed.Level.Game.IsA('ASGameInfo'))
	{
		if (bOwnedByKiller && Killer.Pawn != None && (Killed.Pawn == None || Killed.Pawn.HitDamageType != class'DamTypeUltima') && Killer.Pawn.FindInventoryType(class'KillMarker') == None)
			Killer.Pawn.spawn(class'KillMarker', Killer.Pawn).GiveTo(Killer.Pawn);
	}
}

defaultproperties
{
     AbilityCantBuyColor=(R=164,G=14,B=122,A=200)
     AbilityMaxColor=(R=1,G=1,B=1,A=200)
     AbilityName="Ultima"
     DescColor(0)=(R=255,G=255,B=255,A=220)
     Description(0)="This ability causes your body to release energy when you die. The energy will collect at a single point which will then cause a Redeemer-like nuclear explosion. Level 2 of this ability causes the energy to collect for the explosion in half the time. The ability will only trigger if you have killed at least one enemy during your life. You need to have a Damage Bonus stat of at least 80 to purchase this ability. (Max Level: 2)|Cost (per level): 50,50"
     StartingCost=50
     MaxLevel=4
}
