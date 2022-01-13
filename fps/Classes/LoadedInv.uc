class LoadedInv extends Inventory;

var bool bGotLoadedWeapons;
var bool bGotLoadedArtifacts;
var bool bGotLoadedMonsters;
var bool bGotLoadedEngineer;

var int LWAbilityLevel;
var int LAAbilityLevel;
var int LMAbilityLevel;
var int LEAbilityLevel;

var bool ProtectArtifacts;
var bool DirectMonsters;

defaultproperties
{
     bOnlyRelevantToOwner=False
     bAlwaysRelevant=True
     bReplicateInstigator=True
     RemoteRole=ROLE_DumbProxy
}
