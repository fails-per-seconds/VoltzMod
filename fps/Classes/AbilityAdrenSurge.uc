class AbilityAdrenSurge extends CostRPGAbility
	abstract;

static simulated function int GetCost(RPGPlayerDataObject Data, int CurrentLevel)
{
	local int x;
	local bool gotab;

	if (Data == None)
		return 0;

	if (CurrentLevel >= 2)
	{
		gotab = false;
		for (x = 0; x < Data.Abilities.length; x++)
			if (Data.Abilities[x] == class'AbilityLoadedArtifacts' && Data.AbilityLevels[x] >= 5)
				gotab = true;
		if (!gotab)
			return 0;
	}

	return super.GetCost(Data, CurrentLevel);
}

static function ScoreKill(Controller Killer, Controller Killed, bool bOwnedByKiller, int AbilityLevel)
{
	if (!bOwnedByKiller)
		return;

	if (Killed.Level.Game.IsA('Invasion') && Killed.Pawn != None && Killed.Pawn.IsA('Monster'))
	{
		Killer.AwardAdrenaline(float(Killed.Pawn.GetPropertyText("ScoringValue")) * 0.5 * AbilityLevel);
		return;
	}

	if ( !(!Killed.Level.Game.bTeamGame || ((Killer != None) && (Killer != Killed) && (Killed != None)
		&& (Killer.PlayerReplicationInfo != None) && (Killed.PlayerReplicationInfo != None)
		&& (Killer.PlayerReplicationInfo.Team != Killed.PlayerReplicationInfo.Team))) )
		return;

	if (UnrealPlayer(Killer) != None && UnrealPlayer(Killer).MultiKillLevel > 0)
		Killer.AwardAdrenaline(Deathmatch(Killer.Level.Game).ADR_MajorKill * 0.5 * AbilityLevel);

	if (UnrealPawn(Killed.Pawn) != None && UnrealPawn(Killed.Pawn).spree > 4)
		Killer.AwardAdrenaline(Deathmatch(Killer.Level.Game).ADR_MajorKill * 0.5 * AbilityLevel);

	if ( Killer.PlayerReplicationInfo.Kills == 1 && TeamPlayerReplicationInfo(Killer.PlayerReplicationInfo) != None
	     && TeamPlayerReplicationInfo(Killer.PlayerReplicationInfo).bFirstBlood )
		Killer.AwardAdrenaline(Deathmatch(Killer.Level.Game).ADR_MajorKill * 0.5 * AbilityLevel);

	if (Killer.bIsPlayer && Killed.bIsPlayer)
		Killer.AwardAdrenaline(Deathmatch(Killer.Level.Game).ADR_Kill * 0.5 * AbilityLevel);
}

defaultproperties
{
     MinAdrenalineMax=150
     AbilityCantBuyColor=(R=164,G=14,B=122,A=200)
     AbilityMaxColor=(R=1,G=1,B=1,A=200)
     AbilityName="Adrenal Surge"
     DescColor(0)=(R=255,G=255,B=255,A=220)
     Description(0)="For each level of this ability, you gain 50% more adrenaline from all kill related adrenaline bonuses. You must have a Damage Bonus of at least 50 and an Adrenaline Max stat at least 150 to purchase this ability. |Cost (per level): 2,8..."
     StartingCost=2
     CostAddPerLevel=6
     MaxLevel=4
}
