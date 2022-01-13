class RPGWeaponPickup extends UTWeaponPickup;

var MutFPS RPGMut;
var RPGWeapon DroppedWeapon;
var bool bRealWeaponStay;

function PostBeginPlay()
{
	Super(Pickup).PostBeginPlay();

	RPGMut = class'MutFPS'.static.GetRPGMutator(Level.Game);
}

simulated function PostNetBeginPlay()
{
	Super.PostNetBeginPlay();

	if (DrawType == DT_Mesh)
		bOrientOnSlope = false;
}

function FindPickupBase()
{
	local xPickupBase PBase;

	foreach RadiusActors(class'xPickupBase', PBase, 100.f)
	{
		if (PBase.Location + PBase.SpawnHeight * vect(0,0,1) == Location)
			PickupBase = PBase;
	}

	if (PickupBase != None)
	{
		Event = PickupBase.Event;
		MyMarker = PickupBase.myMarker;
		GotoState('');
		SetTimer(0.1, false);
	}
}

function Timer()
{
	MyMarker.MarkedItem = self;
	PickupBase.myPickUp = self;

	if (PickupBase.IsA('MultiPickupBase') && bool(PickupBase.GetPropertyText("bChangeOnlyOnPickup")))
		bWeaponStay = false;

	if (PickupBase.bDelayedSpawn)
	{
		GotoState('WaitingForMatch');
		myMarker.bSuperPickup = true;
	}
	else
		GotoState('Auto');
}

function SetWeaponStay()
{
	bWeaponStay = (bRealWeaponStay && Level.Game.bWeaponStay);
}

function GetPropertiesFrom(class<WeaponPickup> PickupClass)
{
	bRealWeaponStay = PickupClass.default.bWeaponStay;
	SetWeaponStay();
	PickupMessage = PickupClass.default.PickupMessage;
	InventoryType = PickupClass.default.InventoryType;
	RespawnTime = PickupClass.default.RespawnTime;
	PickupSound = PickupClass.default.PickupSound;
	PickupForce = PickupClass.default.PickupForce;
	SetDrawType(PickupClass.default.DrawType);
	if (DrawType == DT_Mesh)
		LinkMesh(PickupClass.default.Mesh);
	else
		SetStaticMesh(PickupClass.default.StaticMesh);
	Skins = PickupClass.default.Skins;
	SetDrawScale(PickupClass.default.DrawScale);
	MaxDesireability = 1.2 * class<Weapon>(InventoryType).Default.AIRating;
}

function InitDroppedPickupFor(Inventory Inv)
{
	local RPGWeapon W;

	W = RPGWeapon(Inv);
	if (W != None)
	{
		Super.InitDroppedPickupFor(W.ModifiedWeapon);
		GetPropertiesFrom(class<WeaponPickup>(W.ModifiedWeapon.PickupClass));
		DroppedWeapon = W;

		if (W.bIdentified && W.ModifierOverlay != None && W.ThirdPersonActor != None)
		{
			LinkMesh(W.ThirdPersonActor.Mesh);
			SetDrawType(W.ThirdPersonActor.DrawType);
			SetRotation(Rotation + rot(0,0,32768));
			bOrientOnSlope = false;
			SetOverlayMaterial(W.ModifierOverlay, 1000000, true);
		}
	}
	else
		Super.InitDroppedPickupFor(Inv);
}

function inventory SpawnCopy(Pawn Other)
{
	local inventory Copy;
	local RPGWeapon OldWeapon;
	local RPGStatsInv StatsInv;
	local class<RPGWeapon> NewWeaponClass;
	local int x;
	local bool bRemoveReference;

	if (Inventory != None)
		Inventory.Destroy();

	if (DroppedWeapon != None)
	{
		OldWeapon = DroppedWeapon;
		NewWeaponClass = OldWeapon.Class;
	}
	else if (bWeaponStay)
	{
		StatsInv = RPGStatsInv(Other.FindInventoryType(class'RPGStatsInv'));
		if (StatsInv != None)
			for (x = 0; x < StatsInv.OldRPGWeapons.length; x++)
				if (StatsInv.OldRPGWeapons[x].ModifiedClass == InventoryType)
				{
					OldWeapon = StatsInv.OldRPGWeapons[x].Weapon;
					if (OldWeapon == None)
					{
						StatsInv.OldRPGWeapons.Remove(x, 1);
						x--;
					}
					else
					{
						NewWeaponClass = OldWeapon.Class;
						StatsInv.OldRPGWeapons.Remove(x, 1);
						bRemoveReference = true;
						break;
					}
				}
	}
	if (NewWeaponClass == None)
		NewWeaponClass = RPGMut.GetRandomWeaponModifier(class<Weapon>(InventoryType), Other);

	Copy = spawn(NewWeaponClass,Other,,,rot(0,0,0));
	RPGWeapon(Copy).Generate(OldWeapon);
	RPGWeapon(Copy).SetModifiedWeapon(Weapon(spawn(InventoryType,Other,,,rot(0,0,0))), ((bDropped && OldWeapon != None && OldWeapon.bIdentified) || RPGMut.bNoUnidentified));

	Copy.GiveTo(Other, self);

	if (bRemoveReference)
		OldWeapon.RemoveReference();

	return Copy;
}

function Destroyed()
{
	if (DroppedWeapon != None)
		DroppedWeapon.RemoveReference();

	Super.Destroyed();
}

function float DetourWeight(Pawn Other, float PathWeight)
{
	local Weapon AlreadyHas;
	local Inventory Inv;
	local int Count;

	for (Inv = Other.Inventory; Inv != None; Inv = Inv.Inventory)
	{
		if (Inv.Class == InventoryType || (RPGWeapon(Inv) != None && RPGWeapon(Inv).ModifiedWeapon.Class == InventoryType))
		{
			AlreadyHas = Weapon(Inv);
			break;
		}
		Count++;
		if (Count > 1000)
			break;
	}

	if ((AlreadyHas != None) && (bWeaponStay || (AlreadyHas.AmmoAmount(0) > 0)))
		return 0;
	if (AIController(Other.Controller).PriorityObjective() && ((Other.Weapon.AIRating > 0.5) || (PathWeight > 400)))
		return 0;
	return class<Weapon>(InventoryType).Default.AIRating/PathWeight;
}

function float BotDesireability(Pawn Bot)
{
	local Weapon AlreadyHas;
	local float desire;
	local Inventory Inv;
	local int Count;
	local class<Pickup> AmmoPickupClass;

	desire = MaxDesireability + Bot.Controller.AdjustDesireFor(self);

	for (Inv = Bot.Inventory; Inv != None; Inv = Inv.Inventory)
	{
		if (Inv.Class == InventoryType || (RPGWeapon(Inv) != None && RPGWeapon(Inv).ModifiedWeapon.Class == InventoryType))
		{
			AlreadyHas = Weapon(Inv);
			break;
		}
		Count++;
		if (Count > 1000)
			break;
	}

	if (AlreadyHas != None)
	{
		if (Bot.Controller.bHuntPlayer)
			return 0;

		if (!AllowRepeatPickup())
			return 0;
		if ((RespawnTime < 10) && (bHidden || AlreadyHas.AmmoMaxed(0)))
			return 0;

		if (AlreadyHas.AmmoMaxed(0))
			return 0.25 * desire;

		if (AlreadyHas.AmmoAmount(0) > 0)
		{
			AmmoPickupClass = AlreadyHas.AmmoPickupClass(0);

			if (AmmoPickupClass == None)
				return 0.05;
			else
				return FMax(0.25 * desire, AmmoPickupClass.Default.MaxDesireability * FMin(1, 0.15 * AlreadyHas.MaxAmmo(0)/AlreadyHas.AmmoAmount(0)));
		}
		else
			return 0.05;
	}
	if (Bot.Controller.bHuntPlayer && (MaxDesireability * 0.833 < Bot.Weapon.AIRating - 0.1))
		return 0;

	if ((Bot.Weapon == None) || (Bot.Weapon.AIRating < 0.5))
		return 2*desire;

	return desire;
}

defaultproperties
{
     bOnlyReplicateHidden=False
     bGameRelevant=True
     MessageClass=Class'fps.EmptyMessage'
}
