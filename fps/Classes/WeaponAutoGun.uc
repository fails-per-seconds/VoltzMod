class WeaponAutoGun extends Weapon_Sentinel
	config(user)
	HideDropDown
	CacheExempt;

defaultproperties
{
     FireModeClass(0)=Class'fps.FM_AutoGunFire'
     FireModeClass(1)=Class'fps.FM_AutoGunFire'
     ItemName="AutoGun weapon"
}
