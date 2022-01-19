class AbilityDenial extends RPGDeathAbility
	abstract;

static function GenuineDeath(Pawn Killed, Controller Killer, class<DamageType> DamageType, vector HitLocation, int AbilityLevel)
{
	local DenialInv OldWeaponHolder;
	local Inventory inv;
	local int x;
	local Array<Weapon> Weapons;

	if (Killed.isA('Vehicle'))
	{
		Killed = Vehicle(Killed).Driver;
	}

	if (Killed == None)
	{
		return;
	}

	if (Killed.Controller == Killer)
		return;

	if (DamageType == class'Suicided')
		return;

	if (Killed.Controller != None && Killed.Weapon != None)
	{
		if (RPGWeapon(Killed.Weapon) != None)
			Killed.Controller.LastPawnWeapon = RPGWeapon(Killed.Weapon).ModifiedWeapon.Class;
		else
			Killed.Controller.LastPawnWeapon = Killed.Weapon.Class;
	}

	if (AbilityLevel == 2)
	{
		if (Killed.Weapon != None)
		{
			OldWeaponHolder = Killed.spawn(class'DenialInv',Killed.Controller);
			storeOldWeapon(Killed, Killed.Weapon, OldWeaponHolder);
		}
	}
	else if (AbilityLevel == 3)
	{
		for (Inv = Killed.Inventory; Inv != None; Inv = Inv.Inventory)
			if (Weapon(Inv) != None)
				Weapons[Weapons.length] = Weapon(Inv);

		OldWeaponHolder = Killed.spawn(class'DenialInv',Killed.Controller);

		for(x = 0; x < Weapons.length; x++)
			storeOldWeapon(Killed, Weapons[x], OldWeaponHolder);
	}

	Killed.Weapon = None;

	return;
}

static function storeOldWeapon(Pawn Killed, Weapon Weapon, DenialInv OldWeaponHolder)
{
	local DenialInv.WeaponHolder holder;

	if (Weapon == None)
		return;

	if (RPGWeapon(Weapon) != None)
	{
		if (instr(caps(string(RPGWeapon(Weapon).ModifiedWeapon.class)), "TRANSLAUNCHER") > -1)
			return;
	}
	else
	{
		if (instr(caps(string(Weapon.class)), "TRANSLAUNCHER") > -1)
			return;
	}

	Weapon.DetachFromPawn(Killed);
	holder.Weapon = Weapon;
	holder.AmmoAmounts1 = Weapon.AmmoAmount(0);
	holder.AmmoAmounts2 = Weapon.AmmoAmount(1);

	OldWeaponHolder.WeaponHolders[OldWeaponHolder.WeaponHolders.length] = holder;

	Killed.DeleteInventory(holder.Weapon);

	holder.Weapon.SetOwner(Killed.Controller); 
	if (RPGWeapon(holder.Weapon) != None)
		RPGWeapon(holder.Weapon).ModifiedWeapon.SetOwner(Killed.Controller);
}

static simulated function ModifyPawn(Pawn Other, int AbilityLevel)
{
	local DenialInv OldWeaponHolder;
	local DenialInv.WeaponHolder holder;
	local Inventory OInv;
	local Inventory SG;
	local Inventory AR;
	local bool bok;

	if (Other.Role != ROLE_Authority || AbilityLevel < 2)
		return;

	foreach Other.DynamicActors(class'DenialInv', OldWeaponHolder)
		if (OldWeaponHolder.Owner == Other.Controller)
		{
			while (OldWeaponHolder.WeaponHolders.length > 0)
			{
				Holder = oldWeaponHolder.WeaponHolders[0];
				if (Holder.Weapon != None)
				{
					if (instr(caps(Holder.Weapon.ItemName), "SHIELD GUN") > -1 || instr(caps(Holder.Weapon.ItemName), "ASSAULT RIFLE") > -1)
					{
						for (OInv = Other.Inventory ; OInv != None && !bok ; OInv = OInv.Inventory)
						{
							if (instr(caps(OInv.ItemName), "SHIELD GUN") > -1)
								SG=OInv;
							if (instr(caps(OInv.ItemName), "ASSAULT RIFLE") > -1)
								AR=OInv;
							if (SG != None && AR != None)
								bok = true;
						}
						if (instr(caps(Holder.Weapon.ItemName), "SHIELD GUN") > -1 && SG != None)
							Other.DeleteInventory(SG);
						if (instr(caps(Holder.Weapon.ItemName), "ASSAULT RIFLE") > -1 && AR != None)
							Other.DeleteInventory(AR);
					}
							
					Holder.Weapon.GiveTo(Other);
					if (Holder.Weapon == None)
						Continue;
					Holder.Weapon.AddAmmo(Holder.AmmoAmounts1 - Holder.Weapon.AmmoAmount(0), 0);
					Holder.Weapon.AddAmmo(Holder.AmmoAmounts2 - Holder.Weapon.AmmoAmount(1), 1);
				}
				OldWeaponHolder.WeaponHolders.remove(0, 1);
			}
			OldWeaponHolder.Destroy();
			return;
		}
}

defaultproperties
{
     MinPlayerLevel=25
     LevelCost(1)=15
     LevelCost(2)=20
     LevelCost(3)=20
     AbilityCantBuyColor=(R=164,G=14,B=122,A=200)
     AbilityMaxColor=(R=1,G=1,B=1,A=200)
     AbilityName="Denial"
     DescColor(0)=(R=255,G=255,B=255,A=220)
     Description(0)="The first level of this ability simply prevents you from dropping a weapon when you die (but you don't get it either). The second level allows you to respawn with the weapon and ammo you were using when you died. The third level will save all your weapons when you die. You need to be at least Level 25 to purchase this ability. |This ability does not trigger for self-inflicted death.|Cost (per level): 15,20,20"
     BotChance=1
     MaxLevel=3
}
