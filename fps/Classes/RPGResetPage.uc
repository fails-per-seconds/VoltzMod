class RPGResetPage extends RPGResetConfirmPage;

function bool InternalOnClick(GUIComponent Sender)
{
	local GUIController OldController;

	if (Sender == Controls[1])
	{
		OldController = Controller;
		StatsMenu.StatsInv.ServerResetData(PlayerOwner().PlayerReplicationInfo);
		Controller.ViewportOwner.Console.DelayedConsoleCommand("Reconnect");
		Controller.CloseMenu(false);
		OldController.CloseMenu(false);
	}
	else
		Controller.CloseMenu(false);

	return true;
}

defaultproperties
{
}
