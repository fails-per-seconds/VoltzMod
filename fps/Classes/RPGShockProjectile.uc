class RPGShockProjectile extends ShockProjectile;

event TakeDamage(int Damage, Pawn EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType)
{
	if (DamageType == ComboDamageType && RPGWeapon(EventInstigator.Weapon) != None)
		RPGWeapon(EventInstigator.Weapon).AdjustTargetDamage(Damage, self, HitLocation, Momentum, DamageType);

	Super.TakeDamage(Damage, EventInstigator, HitLocation, Momentum, DamageType);
}

State WaitForCombo
{
	function Tick(float DeltaTime)
	{
		if ((ComboTarget == None) || ComboTarget.bDeleteMe
			|| (Instigator == None) || (ShockRifle(Instigator.Weapon) == None && (RPGWeapon(Instigator.Weapon) == None || ShockRifle(RPGWeapon(Instigator.Weapon).ModifiedWeapon) == None)))
		{
			GotoState('');
			return;
		}

		if ((VSize(ComboTarget.Location - Location) <= 0.5 * ComboRadius + ComboTarget.CollisionRadius) || ((Velocity Dot (ComboTarget.Location - Location)) <= 0))
		{
			if (ShockRifle(Instigator.Weapon) != None)
				ShockRifle(Instigator.Weapon).DoCombo();
			else if (ShockRifle(RPGWeapon(Instigator.Weapon).ModifiedWeapon) != None && ShockRifle(RPGWeapon(Instigator.Weapon).ModifiedWeapon).bWaitForCombo)
			{
				ShockRifle(RPGWeapon(Instigator.Weapon).ModifiedWeapon).bWaitForCombo = false;
				Instigator.Weapon.StartFire(0);
			}
			GotoState('');
			return;
		}
	}
}

defaultproperties
{
}
