class BossMessage extends CriticalEventPlus
	abstract;
	
static function string GetString(optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject)
{
	local string S;
	local Class<Monster> MC;

	MC = Class<Monster>(OptionalObject);
	if (MC == None)
	{
		if (Switch >= 1)
			S = "Initiating a";
	}
	else
	{
		S = MC.Default.MenuName;
		if (S == "")
		{
			S = string(MC);
			S = Mid(S,InStr(S,".")+1);
		}
		if (Switch == 1)
		{
			if (MC.Default.bBoss)
				S = "the"@S@"is";
			else S = Eval(ShouldUseAn(S),"an","a")@S@"is";
		}
		else S = Switch@S$"'s are";
	}
	return "Prepare!"@S@"Boss Wave!";
}

static function bool ShouldUseAn(string S)
{
	S = Left(S,1);
	return (S~="a" || S~="e" || S~="o" || S~="u" || S~="y" || S~="i");
}

defaultproperties
{
     bIsConsoleMessage=False
     DrawColor=(B=0,G=0,R=255)
     StackMode=SM_Down
     PosY=0.150000
}