class EngineerLinkGun extends RPGLinkGun
	HideDropDown
	CacheExempt;

var config float HealTimeDelay;

defaultproperties
{
     HealTimeDelay=0.500000
     FireModeClass(0)=Class'fps.EngineerLinkProjFire'
     FireModeClass(1)=Class'fps.EngineerLinkFire'
}
