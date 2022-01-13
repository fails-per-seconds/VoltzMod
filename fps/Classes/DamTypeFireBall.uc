class DamTypeFireBall extends DamageType
	abstract;

static function GetHitEffects(out class<xEmitter> HitEffects[4], int VictemHealth)
{
	HitEffects[0] = class'HitSmoke';
}

defaultproperties
{
     DeathString="%o was fried by %k's fireball."
     FemaleSuicide="%o snuffed herself with the fireball."
     MaleSuicide="%o snuffed himself with the fireball."
     bDetonatesGoop=True
     bDelayedDamage=True
     DamageOverlayMaterial=Shader'RedShader'
     DamageOverlayTime=0.800000
}
