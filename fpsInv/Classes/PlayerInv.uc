class PlayerInv extends xPlayer;

var config int MaxHitSoundsPerSecond;
var config float HitSoundVolume;
var config bool bHitSounds;

var float NextHitSoundTime;

var Sound EnemyHitSound;
var Sound FriendlyHitSound;

var() bool bMeshesLoaded;
var() bool bLoadMeshes;
var() bool bLoadingStarted;

replication
{
	reliable if (Role == ROLE_Authority)
		ClientHitSound;
	reliable if (Role < Role_Authority)
		bMeshesLoaded;
}

simulated function ClientHitSound(int Damage, bool isEnemy)
{
	local Sound HitSound;
	local float pitch;

	if (!bHitSounds || Damage <= 0 || Level.TimeSeconds < NextHitSoundTime)
		return;

	if (ViewTarget != None)
	{
		if (isEnemy)
		{
			HitSound = EnemyHitSound;
			pitch = (30.0 / Damage);
		}
		else
		{
			HitSound = FriendlyHitSound;
			pitch = 1.0;
		}

		ViewTarget.PlaySound(HitSound, , FClamp(HitSoundVolume, 0, 4), , , pitch);
	}

	NextHitSoundTime = Level.TimeSeconds + (1.0 / Clamp(MaxHitSoundsPerSecond, 5, 50));
}

exec simulated function ToggleHitSounds()
{
	bHitSounds = !bHitSounds;
	SaveConfig();
	ClientMessage("Hit Sounds "$enableString(bHitSounds));
}

exec function HitSounds(String s)
{
	if (s == "")
	{
		HitSoundUsage(false);
		ClientMessage("Currently: "$Eval(bHitSounds, "on", "off")$", vol="$HitSoundVolume$", dps="$MaxHitSoundsPerSecond);

		return;
	}

	if (s ~= "on" || s ~= "off")
	{
		if ((s ~= "on" && bHitSounds) || (s ~= "off" && !bHitSounds))
			ClientMessage("Hitsounds already "$Caps(s)$".");
		else
			ToggleHitSounds();

		return;
	}

	if (s ~= "vol")
	{
		ClientMessage("Current hitsounds volume = "$HitSoundVolume);
		return;
	}

	if (Left(s, 4) ~= "vol ")
	{
		HitSoundVolume = FClamp(float(Mid(s, 4)), 0, 4);
		ClientMessage("New hitsound volume = "$HitSoundVolume);
		return;
	}

	if (s ~= "dps")
	{
		ClientMessage("Current max dinks per second = "$MaxHitSoundsPerSecond);
		return;
	}

	if (Left(s, 4) ~= "dps ")
	{
		MaxHitSoundsPerSecond = Clamp(int(Mid(s, 4)), 5, 50);
		ClientMessage("New max dinks per second = "$MaxHitSoundsPerSecond);
		return;
	}

	HitSoundUsage(true);
}

function HitSoundUsage(bool doBeep)
{
	ClientMessage("hitsounds [on-off]");
	ClientMessage("hitsounds vol [0-4]");
	ClientMessage("hitsounds dps [5-50]");

	if (doBeep)
		ViewTarget.PlaySound(Sound'MenuSounds.denied1', SLOT_None,,,,,false);
}

exec function SetHSVolume(coerce float f)
{
	HitSoundVolume = FClamp(f, 0, 4);
	SaveConfig();

	if (ViewTarget != None)
		ViewTarget.PlaySound(EnemyHitSound, , FClamp(HitSoundVolume, 0, 4), , , 0.5);
}

exec function SetHSDinks(coerce int n)
{
	MaxHitSoundsPerSecond = Clamp(n, 5, 50);
	SaveConfig();
}

function String enableString(bool b)
{
	return Eval(b, "Enabled", "Disabled");
}

function Possess(Pawn aPawn)
{
	if (PlayerReplicationInfo.bOnlySpectator)
		return;

	Super.Possess(aPawn);

	if (!bLoadingStarted && !bMeshesLoaded && bLoadMeshes && Pawn != None)
	{
		bLoadingStarted = true;
		LoadMonsterMeshes();
	}
}

simulated function LoadMonsterMeshes()
{
	Spawn(class'PreloadMesh',self);
}

defaultproperties
{
     bHitSounds=True
     MaxHitSoundsPerSecond=15
     HitSoundVolume=1.000000
     EnemyHitSound=Sound'fpsInv.HS_Enemy'
     FriendlyHitSound=Sound'fpsInv.HS_Friendly'
}