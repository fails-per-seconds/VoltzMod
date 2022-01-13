class GhostUltimaCharger extends Actor;

var xEmitter ChargeEmitter;
var float ChargeTime, Damage, DamageRadius, MomentumTransfer;
var class<DamageType> DamageType;
var AvoidMarker Fear;
var Controller InstigatorController;

function DoDamage(float Radius)
{
	local actor Victims;
	local float damageScale, dist;
	local vector dir;
	local bool gotPawn, isEnemy;

	if (Instigator == None && InstigatorController != None)
		Instigator = InstigatorController.Pawn;

	if (bHurtEntry)
		return;

	bHurtEntry = true;
	foreach VisibleCollidingActors(class 'Actor', Victims, Radius, Location)
	{
		if (Victims != self && Victims != Instigator && Victims.Role == ROLE_Authority && !Victims.IsA('FluidSurfaceInfo'))
		{
			isEnemy = true;
			if (Pawn(Victims) != None)
			{
				gotPawn = true;
				if (Pawn(Victims).Health <= 0)
					isEnemy = false;
				else if (TeamGame(Level.Game) != None && TeamGame(Level.Game).FriendlyFireScale == 0)
				{
					if (InstigatorController == None || Pawn(Victims).Controller == None || Pawn(Victims).Controller.SameTeamAs(InstigatorController)) 
						isEnemy = false;
				}
			}
			else
			{
				if (Victims.Owner != None && Pawn(Victims.Owner) != None && Pawn(Victims.Owner).Controller != None && InstigatorController != None && Pawn(Victims.Owner).Controller.SameTeamAs(InstigatorController))
					isEnemy = false;
				else
					gotPawn = false;
			}
			if (isEnemy)
			{
				if (gotPawn)
					Pawn(Victims).HitDamageType = DamageType;
				Victims.SetDelayedDamageInstigatorController(InstigatorController);

				dir = Victims.Location - Location;
				dist = FMax(1,VSize(dir));
				dir = dir/dist;
				damageScale = 1 - FMax(0,(dist - Victims.CollisionRadius)/DamageRadius);

				Victims.TakeDamage
				(
					damageScale * Damage,
					Instigator,
					Victims.Location - 0.5 * (Victims.CollisionHeight + Victims.CollisionRadius) * dir,
					(damageScale * MomentumTransfer * dir),
					DamageType
				);

				if (gotPawn && Instigator != None)
				{
					if (Victims == None || Pawn(Victims) == None || Pawn(Victims).Health <= 0)
						class'ArtifactLightningBeam'.static.AddArtifactKill(Instigator, class'WeaponUltima');
				}
	
			}
		}
	}
	bHurtEntry = false;
}

simulated function PostBeginPlay()
{
	if (Level.NetMode != NM_DedicatedServer)
		ChargeEmitter = spawn(class'UltimaChargeEmitter');

	if (Role == ROLE_Authority)
		InstigatorController = Controller(Owner);

	Super.PostBeginPlay();
}

simulated function Destroyed()
{
	if (ChargeEmitter != None)
		ChargeEmitter.Destroy();

	Super.Destroyed();
}

auto state Charging
{
Begin:
	Fear = spawn(class'AvoidMarker');
	Fear.SetCollisionSize(DamageRadius, 200);
	Fear.StartleBots();

	Sleep(ChargeTime);
	spawn(class'UltimaExplosion');
	bHidden = true;
	if (ChargeEmitter != None)
		ChargeEmitter.Destroy();
	MakeNoise(1.0);
	PlaySound(sound'WeaponSounds.redeemer_explosionsound');
	DoDamage(DamageRadius*0.125);
	Sleep(0.5);
	DoDamage(DamageRadius*0.300);
	Sleep(0.2);
	DoDamage(DamageRadius*0.475);
	Sleep(0.2);
	DoDamage(DamageRadius*0.650);
	Sleep(0.2);
	DoDamage(DamageRadius*0.825);
	Sleep(0.2);
	DoDamage(DamageRadius);

	if (Fear != None)
		Fear.Destroy();
	Destroy();
}

defaultproperties
{
     Damage=250.000000
     DamageRadius=2000.000000
     DamageType=Class'fps.DamTypeUltima'
     MomentumTransfer=200000.000000
     DrawType=DT_None
     TransientSoundVolume=1.000000
     TransientSoundRadius=5000.000000
}
