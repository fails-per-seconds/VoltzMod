class FakeMonsterWeapon extends Weapon
	CacheExempt
	HideDropDown;

function DropFrom(vector StartLocation)
{
	Destroy();
}

function bool BotFire(bool bFinished, optional name FiringMode)
{
	return false;
}

event ServerStartFire(byte Mode)
{
}

function bool CanAttack(Actor Other)
{
	return false;
}

simulated function bool ReadyToFire(int Mode)
{
	return false;
}

simulated function bool IsFiring()
{
	return false;
}

function HolderDied()
{
}

function GiveTo(Pawn Other, optional Pickup Pickup)
{
	Super(Inventory).GiveTo(Other, Pickup);

	Instigator.Weapon = self;
}

function AdjustPlayerDamage( out int Damage, Pawn InstigatedBy, Vector HitLocation, out Vector Momentum, class<DamageType> DamageType)
{
	Damage = Level.Game.GameRulesModifiers.NetDamage(Damage, Damage, Instigator, InstigatedBy, HitLocation, Momentum, DamageType);
}

defaultproperties
{
     bGameRelevant=True
}
