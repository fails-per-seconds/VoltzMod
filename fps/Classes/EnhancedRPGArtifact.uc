class EnhancedRPGArtifact extends RPGArtifact
	abstract;

var float AdrenalineUsage;
var config float TimeBetweenUses;
var float LastUsedTime;
var float RecoveryTime;

replication
{
	reliable if (Role == ROLE_Authority)
		SetClientRecoveryTime;
}

function SetRecoveryTime(float RecoveryPeriod)
{
	LastUsedTime = Level.TimeSeconds;
	SetClientRecoveryTime(RecoveryPeriod);
}

simulated function SetClientRecoveryTime(int RecoveryPeriod)
{
	if (Level.NetMode != NM_DedicatedServer)
		RecoveryTime = Level.TimeSeconds + RecoveryPeriod;
}

simulated function int GetRecoveryTime()
{
	if (RecoveryTime > 0 && RecoveryTime > Level.TimeSeconds)
		return max(int(RecoveryTime - Level.TimeSeconds),1);
	else
		return 0;
}

function EnhanceArtifact(float Adusage)
{
	AdrenalineUsage = AdUsage;
}

simulated function Tick(float deltaTime)
{
	if (bActive)
	{
		if (Instigator != None && Instigator.Controller != None)
		{
			Instigator.Controller.Adrenaline -= deltaTime * CostPerSec;
			if (Instigator.Controller.Adrenaline <= 0.0)
			{
				Instigator.Controller.Adrenaline = 0.0;
				UsedUp();
			}
		}
	}
}

defaultproperties
{
     AdrenalineUsage=1.000000
}
