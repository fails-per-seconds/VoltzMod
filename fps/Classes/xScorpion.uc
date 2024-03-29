class xScorpion extends ONSRV;

var bool IsLockedForSelf;
var Controller PlayerSpawner;
var Material LockOverlay;

function SetPlayerSpawner(Controller PlayerC)
{
	PlayerSpawner = PlayerC;
}

function bool TryToDrive(Pawn P)
{
	if ((P.Controller == None) || !P.Controller.bIsPlayer || Health <= 0)
		return false;

	if (IsEngineerLocked() && P.Controller != PlayerSpawner)
	{
		if (PlayerController(P.Controller) != None)
		{
			if (PlayerSpawner != None)
				PlayerController(P.Controller).ReceiveLocalizedMessage(class'EngLockedMessage', 0, PlayerSpawner.PlayerReplicationInfo);
			else
				PlayerController(P.Controller).ReceiveLocalizedMessage(class'EngLockedMessage', 0);
		}
		return false;
	}
	else
	{
		return super.TryToDrive(P);
	}
}

function EngineerLock()
{
	IsLockedForSelf = True;
	SetOverlayMaterial(LockOverlay, 50000.0, false);
}

function EngineerUnlock()
{
	IsLockedForSelf = False;
	SetOverlayMaterial(LockOverlay, 0.0, false);
}

function bool IsEngineerLocked()
{
	return IsLockedForSelf;
}

defaultproperties
{
     LockOverlay=Shader'RedShader'
}
