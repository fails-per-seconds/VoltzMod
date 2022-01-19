class AbilityVehicleEject extends RPGDeathAbility
	abstract
	config(fps);

var config int BigSeconds;

static function bool PrePreventDeath(Pawn Killed, Controller Killer, class<DamageType> DamageType, vector HitLocation, int AbilityLevel)
{
	local Pawn Driver;
	local Vehicle Vehicle;
	local EjectedInv ejected;
	local bool DestroyVehicle, SavedPlayer;

	destroyVehicle = false;

	Vehicle = Vehicle(Killed);
	if (Vehicle == None)
	{
		if (Killed.DrivenVehicle != None)
		{
			Driver = Killed;
			Vehicle = Killed.DrivenVehicle;

			DestroyVehicle = true;

			SavedPlayer = true;
		}		
		else
			return false;
	}
	else	
		Driver = Vehicle.Driver;

	if (Driver == None)
		return false;

	if (Killed.IsA('ASVehicle_SpaceFighter') || (Killed.DrivenVehicle != None && Killed.DrivenVehicle.IsA('ASVehicle_SpaceFighter')))
		return false;

	ejected =  EjectedInv(Driver.FindInventoryType(class'EjectedInv'));
	if (ejected != None)
		return false;

	if (Driver.Health <= 0)
		Driver.Health = 1;

	if (Vehicle.EjectMomentum <= 0)
		Vehicle.EjectMomentum = class'ONSHoverBike'.default.EjectMomentum;

	Vehicle.EjectDriver();

	ejected = Driver.spawn(class'EjectedInv', Driver,,, rot(0,0,0));
	ejected.lifespan = default.BigSeconds/AbilityLevel;
	ejected.GiveTo(Driver);
		
	if (SavedPlayer)
		return true;
	else
		return false;
}

defaultproperties
{
     BigSeconds=120
     AbilityCantBuyColor=(R=164,G=14,B=122,A=200)
     AbilityMaxColor=(R=1,G=1,B=1,A=200)
     AbilityName="Vehicle Ejector Button"
     DescColor(0)=(R=255,G=255,B=255,A=220)
     Description(0)="You will be automatically ejected from a destroyed vehicle. Depending upon your level of this skill, it will activate once every 120, 60, 40, or 30 seconds.|Cost (per level): 5,10,15,20"
     StartingCost=5
     CostAddPerLevel=5
     MaxLevel=4
}
