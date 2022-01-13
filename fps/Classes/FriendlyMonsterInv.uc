class FriendlyMonsterInv extends Inventory;

var PlayerReplicationInfo MasterPRI;
var float Skill;
var MonsterPointsInv MonsterPointsInv;

function GiveTo(Pawn Other, optional Pickup Pickup)
{
	SetTimer(2.0, false);
	super.giveTo(Other);
}

function destroyed()
{
	MonsterPointsInv = None;
	super.destroyed();
}

function Timer()
{
	if (Instigator != None && Instigator.Controller != None && MonsterController(Instigator.Controller) != None)
		MonsterController(Instigator.Controller).InitializeSkill(Skill);
}

defaultproperties
{
     RemoteRole=ROLE_DumbProxy
}
