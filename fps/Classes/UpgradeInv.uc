class UpgradeInv extends Inventory
	config(fpsUpdate);

var UpgradeObj Obj;

function Tick(float deltaTime)
{
	local RPGStatsInv Inv;
	local String CurrentVersion;
	local MutFPS RPGMut;
	local Mutator m;
	local String Entry;

	if (Instigator == None || Instigator.Controller == None || PlayerController(Instigator.Controller) == None || PlayerController(Instigator.Controller).PlayerReplicationInfo == None)
	{
		super.Tick(deltaTime);
		return;
	}

	Inv = RPGStatsInv(Instigator.FindInventoryType(class'RPGStatsInv'));
	if (Inv != None)
	{
		for (m = Level.Game.BaseMutator; m != None; m = m.NextMutator)
			if (MutFPS(m) != None)
			{
				RPGMut = MutFPS(m);
				break;
			}

		if (RPGMut != None)
		{
			Entry = PlayerController(Instigator.Controller).getPlayerIDHash() @ PlayerController(Instigator.Controller).PlayerReplicationInfo.GetHumanReadableName();

			Obj = new(None, Entry) class'UpgradeObj';
			if (Obj != None)
			{
				CurrentVersion = getCurrentVersion();
				if (Obj.Version != CurrentVersion)
				{
					doUpgrade(Obj.Version, CurrentVersion, Inv);
					Obj.Version = CurrentVersion;
					Obj.saveConfig();
					Inv.DataObject.saveConfig();

					Inv.DataObject.CreateDataStruct(Inv.Data, false);
					RPGMut.ValidateData(Inv.DataObject);
					Inv.DataObject.CreateDataStruct(Inv.Data, false);
				}
				disable('Tick');
			}
		}
		
	}
	
	super.Tick(deltaTime);
}

function doUpgrade(String oldVersion, String newVersion, RPGStatsInv inv)
{
	if (newVersion == "182")
		do182Upgrade(Inv);
}

function do182Upgrade(RPGStatsInv inv)
{
	local int x, AwareIdx;
	local bool NeedAdrenalineMaster;
	local bool NeedWeaponsMaster;
	local bool FoundAdrenalineMaster;
	local bool FoundWeaponsMaster;
	local bool FoundMonsterMaster;
	local bool FoundEngineer;
	local bool GotAwareness;

	for (x = 0; x < Inv.DataObject.Abilities.length; x++)
	{
		if (Inv.DataObject.Abilities[x] == class'ClassAdrenalineMaster')
		{
			FoundAdrenalineMaster = True;
			break;
		}
		else if (Inv.DataObject.Abilities[x] == class'ClassWeaponsMaster')
		{
			FoundWeaponsMaster = True;
			break;
		}
		else if (Inv.DataObject.Abilities[x] == class'ClassMonsterMaster')
		{
			FoundMonsterMaster = True;
			NeedAdrenalineMaster = False;
			NeedWeaponsMaster = False;
		}
		else if (Inv.DataObject.Abilities[x] == class'ClassEngineer')
		{
			FoundEngineer = True;
			break;
		}
		else if (!NeedAdrenalineMaster && !NeedWeaponsMaster && !FoundMonsterMaster)
		{
			if (Inv.DataObject.Abilities[x] == class'AbilityLoadedWeapons')
				NeedWeaponsMaster = True;
			else if (Inv.DataObject.Abilities[x] == class'AbilityVampire')
				NeedWeaponsMaster = True;
			else if (Inv.DataObject.Abilities[x] == class'AbilityRegen')
				NeedWeaponsMaster = True;

			else if (Inv.DataObject.Abilities[x] == class'AbilityLoadedArtifacts')
				NeedAdrenalineMaster = True;
			else if (Inv.DataObject.Abilities[x] == class'AbilityAdrenLeech')
				NeedAdrenalineMaster = True;
			else if (Inv.DataObject.Abilities[x] == class'AbilityAdrenSurge')
				NeedAdrenalineMaster = True;
			else if (Inv.DataObject.Abilities[x] == class'AbilityAdrenRegen')
				NeedAdrenalineMaster = True;
		}
		else if (Inv.DataObject.Abilities[x] == class'AbilityAwareness')
		{
			AwareIdx = x;
			GotAwareness = True;
		}
	}

	if (FoundAdrenalineMaster || FoundWeaponsMaster || FoundEngineer)
		return;

	if (!FoundMonsterMaster && GotAwareness)
		NeedWeaponsMaster = True;

	if (FoundMonsterMaster && GotAwareness)
	{
		log(Inv.DataObject.Name@"Needed Awareness Switch");
		Inv.DataObject.Abilities[AwareIdx] = class'AbilityMedicAwareness';

		Instigator.Controller.Destroy();
	}
	else if (NeedAdrenalineMaster)
	{
		log(Inv.DataObject.Name@"Needed Adrenaline Master");

		Inv.DataObject.Abilities[Inv.DataObject.Abilities.length] = class'ClassAdrenalineMaster';
		Inv.DataObject.AbilityLevels[Inv.DataObject.AbilityLevels.length] = 1;
		Inv.ClientAddAbility(class'ClassAdrenalineMaster', 1);
	}
	else if (NeedWeaponsMaster)
	{
		log(Inv.DataObject.Name@"Needed Weapons Master");

		Inv.DataObject.Abilities[Inv.DataObject.Abilities.length] = class'ClassWeaponsMaster';
		Inv.DataObject.AbilityLevels[Inv.DataObject.AbilityLevels.length] = 1;
		Inv.ClientAddAbility(class'ClassAdrenalineMaster', 1);
	}
	log("182 Upgrade complete for"@Inv.DataObject.Name);
}

function String getCurrentVersion()
{
	return "182"; 
}

function GiveTo(Pawn Other, optional Pickup Pickup)
{
	enable('Tick');
	Super.GiveTo(Other);
}

defaultproperties
{
}
