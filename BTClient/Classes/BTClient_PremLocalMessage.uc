class BTClient_PremLocalMessage extends BTClient_LocalMessage;

static final preoperator string $( Color A )
{
	return (Chr(0x1B) $ (Chr(Max( A.R, 1)) $ Chr(Max(A.G, 1)) $ Chr(Max(A.B, 1))));
}

static final preoperator string %( string A )
{
	local int i;

	while(true)
	{
		i = InStr(A, Chr(0x1B));
		if (i != -1)
		{
			A = Left(A, i) $ Mid(A, i+4);
			continue;
		}
		break;
	}
	return A;
}

static function string GetString( optional int switch,
    optional PlayerReplicationInfo MessageReceiver, optional PlayerReplicationInfo MessageInstigator,
    optional Object ReceiverClientReplication )
{
	return Repl(Super.GetString(0, MessageReceiver, MessageInstigator, ReceiverClientReplication), "%PLAYER%",
		$class'HUD'.default.WhiteColor $ class'BTClient_TrialScoreBoard'.static.GetCName(MessageInstigator) $ $GetColor(0, MessageReceiver, MessageInstigator));
}

defaultproperties
{
     Lifetime=8
     DrawColor=(G=255)
     StackMode=SM_Down
     PosY=0.150000
     FontSize=0
}
