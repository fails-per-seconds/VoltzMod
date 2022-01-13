class ArtifactMakeSuperHealer extends ArtifactMagicMaker;

var int AbilityLevel;
var int MaxHealth;
var float EXPMultiplier;
var float HealingDamage;

function BotConsider()
{
	local RW_SuperHealer RW;

	if (bActive)
		return;

	if (Instigator.Controller.Adrenaline < getCost())
		return;

	RW = RW_SuperHealer(Instigator.Weapon);
	if (RW != None)
		return;

	if ( !bActive && NoArtifactsActive() && FRand() < 0.1 )
		Activate();
}

function int getMaxHealth()
{
	if (MaxHealth == 0)
		return class'RW_Healer'.default.MaxHealth;
	else
		return MaxHealth;
}

function float getEXPMultiplier()
{
	if (EXPMultiplier == 0.0)
		return class'RW_Healer'.default.EXPMultiplier;
	else
		return EXPMultiplier;
}

function int getCost()
{
	return 10;
}

function bool shouldBreak()
{
	return false;
}

function constructionFinished(RPGWeapon result)
{
	local RW_SuperHealer SuperHealer;

	if (RW_SuperHealer(result) != None)
	{
		SuperHealer = RW_SuperHealer(Instigator.FindInventoryType(class'RW_SuperHealer'));
		if (SuperHealer != None)
		{
			SuperHealer.AMSH = None;
			if (SuperHealer.ModifiedWeapon != Result.ModifiedWeapon)
				SuperHealer.Destroy();
		}
		RW_SuperHealer(result).AMSH = Self;
		RW_SuperHealer(result).HealthBonus = RW_SuperHealer(result).default.HealthBonus*HealingDamage;
	}
}

function class<RPGWeapon> GetRandomWeaponModifier(class<Weapon> WeaponType, Pawn Other)
{
	if (class'RW_SuperHealer'.static.AllowedFor(WeaponType, Other))
		return class'RW_SuperHealer';
	return class'RPGWeapon';
}

exec function TossArtifact()
{
	//do nothing.
}

function DropFrom(vector StartLocation)
{
	if (bActive)
		GotoState('');
	bActive = false;

	Destroy();
	Instigator.NextItem();
}


function Activate()
{
	local Weapon CurWeapon;

	if (!bActive && Instigator != None)
	{
		CurWeapon = Instigator.Weapon;
		if (RPGWeapon(CurWeapon) != None)
			CurWeapon = RPGWeapon(CurWeapon).ModifiedWeapon;

		if (CurWeapon != None)
		{
			if (instr(caps(CurWeapon), "TRANSLAUNCHER") > -1 || instr(caps(CurWeapon), "LINK") > -1)
			{
				Instigator.ReceiveLocalizedMessage(MessageClass, 6000, None, None, Class);
				GotoState('');
				bActive = false;
				return;
			}
		}
	}

	Super.Activate();
}

static function string GetLocalString(optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2)
{
	if (Switch == 6000)
		return "Unable to convert that weapon type";
	else
		return Super.GetLocalString(Switch, RelatedPRI_1, RelatedPRI_2);
}

defaultproperties
{
     HealingDamage=1.000000
     IconMaterial=Combiner'XGameTextures.SuperPickups.DOMPabBc'
     ItemName="Medic Maker"
}
