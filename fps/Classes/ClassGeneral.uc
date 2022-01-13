class ClassGeneral extends RPGClass
	config(fps)
	abstract;

static simulated function ModifyPawn(Pawn Other, int AbilityLevel)
{
	class'ClassAdrenalineMaster'.static.ModifyPawn(Other, AbilityLevel);
}

defaultproperties
{
     AbilityName="Class: General"
     Description="This class has basic use of most abilities, but exceeds at none of them. An all-rounder.|You can not be more than one class at any time."
     BotChance=7
}
