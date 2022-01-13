class BTServer_TrialModeConfig extends BTServer_ModeConfig;

defaultproperties
{
     bAllowClientSpawn=True
     ConfigGroupName="BestTimes - Trials"
     ConfigProperties(0)=(Property=BoolProperty'BTServer_ModeConfig.bAllowClientSpawn',Description="Allow ClientSpawn Use",Hint="If Checked, players may use the !CP command to set a checkpoint.",Weight=1)
     ConfigProperties(1)=(Property=BoolProperty'BTServer_ModeConfig.bDisableWeaponBoosting',Description="Disable Weapon Boosting",Hint="If checked, boosting will be disabled for all players.",Weight=1)
}
