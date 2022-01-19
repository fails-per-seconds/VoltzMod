class AbilityWheeledVehicleStunts extends CostRPGAbility
	abstract
	config(fps);

var config float MaxForce, MaxSpin, JumpChargeTime;
var config float ForceLevelMultiplier, SpinLevelMultiplier, ChargeLevelMultiplier;

static simulated function ModifyVehicle(Vehicle V, int AbilityLevel)
{
	local ONSWheeledCraft wheels;
	local VehicleStuntsInv inv;

	if (V.Level.NetMode == NM_Client)
		return;

	wheels = ONSWheeledCraft(V);
	if (wheels == None)
		return;

	inv = VehicleStuntsInv(wheels.FindInventoryType(class'VehicleStuntsInv'));
	if (Inv != None)
	{
		UnModifyVehicle(V, AbilityLevel);
	}
	
	inv = wheels.spawn(class'VehicleStuntsInv', wheels,,, rot(0,0,0));
	if (inv == None)
		return;
	inv.giveTo(wheels);

	inv.bAllowAirControl = wheels.bAllowAirControl;
	inv.bAllowChargingJump = wheels.bAllowChargingJump;
	inv.bSpecialHUD = wheels.bSpecialHUD;
	inv.MaxJumpForce = wheels.MaxJumpForce;
	inv.MaxJumpSpin = wheels.MaxJumpSpin;
	inv.JumpChargeTime = wheels.JumpChargeTime;
	inv.bHasHandbrake = wheels.bHasHandbrake;

	wheels.bAllowAirControl = true;
	wheels.bAllowChargingJump = true;
	wheels.bSpecialHUD = true;
	wheels.MaxJumpForce = default.MaxForce * ((float(AbilityLevel - 1) * default.ForceLevelMultiplier) + 1.000000);
	wheels.MaxJumpSpin = default.MaxSpin * ((float(AbilityLevel - 1) * default.SpinLevelMultiplier) + 1.000000);
	wheels.JumpChargeTime = default.JumpChargeTime * ((float(AbilityLevel - 1) * default.SpinLevelMultiplier) + 1.000000);
	wheels.bHasHandbrake = false;
}

static simulated function UnModifyVehicle(Vehicle V, int AbilityLevel)
{
	local ONSWheeledCraft wheels;
	local VehicleStuntsInv inv;

	if (V.Level.NetMode == NM_Client)
		return;

	wheels = ONSWheeledCraft(V);
	if (wheels == None)
		return;

	inv = VehicleStuntsInv(wheels.FindInventoryType(class'VehicleStuntsInv'));
	if (inv == None)
		return;

	wheels.bAllowAirControl = inv.bAllowAirControl;
	wheels.bAllowChargingJump = inv.bAllowChargingJump;
	wheels.bSpecialHUD = inv.bSpecialHUD;
	wheels.MaxJumpForce = inv.MaxJumpForce;
	wheels.MaxJumpSpin = inv.MaxJumpSpin;
	wheels.JumpChargeTime = inv.JumpChargeTime;
	wheels.bHasHandbrake = inv.bHasHandbrake;

	wheels.deleteInventory(inv);
	inv.destroy();
}

defaultproperties
{
     MaxForce=200000.000000
     ForceLevelMultiplier=1.500000
     MaxSpin=80.000000
     SpinLevelMultiplier=1.250000
     JumpChargeTime=1.000000
     ChargeLevelMultiplier=0.800000
     AbilityCantBuyColor=(R=164,G=14,B=122,A=200)
     AbilityMaxColor=(R=1,G=1,B=1,A=200)
     AbilityName="Stunt Vehicles"
     DescColor(0)=(R=255,G=255,B=255,A=220)
     Description(0)="With this skill, you can make wheeled vehicles jump.|Hold down the crouch key to charge up and then release to jump.|This ability also grants control of wheeled vehicles in mid-air.|Additional levels provide more spin, momentum, and less charge time.|Cost (per level): 5,10,15"
     StartingCost=5
     CostAddPerLevel=5
     MaxLevel=3
}
