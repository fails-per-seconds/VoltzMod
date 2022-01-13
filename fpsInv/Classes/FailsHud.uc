class FailsHud extends HudInvasion //HudCTeamDeathMatch
	config(fpsInv);

//timer
var FailsGRI GRI;
var localized string BossTimeString, KillZoneString;
var localized string MonsCountString, BossCountString;
var float fBlink, fPulse;

//radar
var PlayerController PC;
var Color RadarColor;
var Color PulseColor;
var Color OutlineColor;

//preload
var localized string PreloadString;
var bool bDrawPreloading, bMeshesLoaded, bLoadingStarted;
var Color LoadingContainerColor;
var Material LoadingContainerImage;
var Material LoadingContainerCompanionImage;
var Material LoadingBarImage;
var float LoadingBarSizeX, LoadingBarSpread;
var Font LoadingFont;

simulated function UpdatePrecacheMaterials()
{
	Level.AddPrecacheMaterial(Material'InterfaceContent.HUD.SkinA');
	Level.AddPrecacheMaterial(Material'AS_FX_TX.AssaultRadar');
	Super.UpdatePrecacheMaterials();
}

simulated function ShowTeamScorePassA(Canvas C)
{
	local float RadarWidth, PulseWidth, PulseBrightness;

	RadarScale = Default.RadarScale * HUDScale;
	RadarWidth = 0.5 * RadarScale * C.ClipX;
	PulseWidth = RadarScale * C.ClipX;
	C.DrawColor = OutlineColor;
	C.Style = ERenderStyle.STY_Translucent;

	PulseBrightness = FMax(0,(1 - 2*RadarPulse) * 255.0);
	C.DrawColor.G = PulseBrightness;
	C.SetPos(RadarPosX*C.ClipX - 0.5*PulseWidth,RadarPosY*C.ClipY+RadarWidth-0.5*PulseWidth);
	C.DrawTile(Material'InterfaceContent.SkinA', PulseWidth, PulseWidth, 0, 880, 142, 142);

	PulseWidth = RadarPulse * RadarScale * C.ClipX;
	C.DrawColor = PulseColor;
	C.SetPos(RadarPosX*C.ClipX - 0.5*PulseWidth,RadarPosY*C.ClipY+RadarWidth-0.5*PulseWidth);
	C.DrawTile(Material'InterfaceContent.SkinA', PulseWidth, PulseWidth, 0, 880, 142, 142);

	C.Style = ERenderStyle.STY_Alpha;
	C.DrawColor = RadarColor;
	C.SetPos(RadarPosX*C.ClipX - RadarWidth,RadarPosY*C.ClipY+RadarWidth);
	C.DrawTile(Material'AS_FX_TX.AssaultRadar', RadarWidth, RadarWidth, 0, 512, 512, -512);
	C.SetPos(RadarPosX*C.ClipX,RadarPosY*C.ClipY+RadarWidth);
	C.DrawTile(Material'AS_FX_TX.AssaultRadar', RadarWidth, RadarWidth, 512, 512, -512, -512);
	C.SetPos(RadarPosX*C.ClipX - RadarWidth,RadarPosY*C.ClipY);
	C.DrawTile(Material'AS_FX_TX.AssaultRadar', RadarWidth, RadarWidth, 0, 0, 512, 512);
	C.SetPos(RadarPosX*C.ClipX,RadarPosY*C.ClipY);
	C.DrawTile(Material'AS_FX_TX.AssaultRadar', RadarWidth, RadarWidth, 512, 0, -512, 512);
}

simulated function ShowTeamScorePassC(Canvas C)
{
	local Pawn P;
	local float Dist, MaxDist, RadarWidth, PulseBrightness, Angle, DotSize, OffsetY, OffsetScale;
	local rotator Dir;
	local vector Start;
	local BossInv BInv;
	//RPG added
	local FriendlyMonsterEffect Effect;
	local bool bPet, bMyPet;
	local int DeltaHealth;

	if (PC == None)
		PC = Level.GetLocalPlayerController();

	LastDrawRadar = Level.TimeSeconds;
	RadarWidth = 0.5 * RadarScale * C.ClipX;
	DotSize = 24*C.ClipX*HUDScale/1600;
	if (PawnOwner == None)
		Start = PlayerOwner.Location;
	else
		Start = PawnOwner.Location;

	//preload
	if (GRI != None)
	{
		if (!bMeshesLoaded && bDrawPreloading)
			DrawLoading(C);
	}

	//radar
	MaxDist = 3000 * RadarPulse;
	C.Style = ERenderStyle.STY_Translucent;
	OffsetY = RadarPosY + RadarWidth/C.ClipY;
	MinEnemyDist = 3000;
	foreach DynamicActors(class'Pawn',P)
	{
		if (P.Health > 0)
		{
			Dist = VSize(Start - P.Location);
			if (Dist < 3000)
			{
				if (Dist < MaxDist)
					PulseBrightness = 255 - 255*Abs(Dist*0.00033 - RadarPulse);
				else
					PulseBrightness = 255 - 255*Abs(Dist*0.00033 - RadarPulse - 1);
				if (Monster(P) != None)
				{
					bPet = false;
					bMyPet = false;
					foreach DynamicActors(class'FriendlyMonsterEffect', Effect)
					{
				        	if (Effect.Base != None)
						{
							if (Monster(Effect.Base) == Monster(P))
							{
								bPet = true;
								if (PC != None && PC.PlayerReplicationInfo != None && PC.PlayerReplicationInfo == Effect.MasterPRI)
									bMyPet = true;
							}
						}
					}
					if (bPet)
					{
						if (bMyPet)
						{
							C.DrawColor.R = 0;
							C.DrawColor.G = FMin(PulseBrightness*2, 255);
							C.DrawColor.B = 0;
						}
						else
						{
							C.DrawColor.R = 0;
							C.DrawColor.G = FMin(PulseBrightness*2, 255);
							C.DrawColor.B = FMin(PulseBrightness*2, 255);
						}
					}
					else
					{
						MinEnemyDist = FMin(MinEnemyDist, Dist);
						if (PawnOwner == None)
						{
							C.DrawColor.R = PulseBrightness;
							C.DrawColor.G = 0;
							C.DrawColor.B = 0;
						}
						else
						{
							DeltaHealth = Max(Min(PawnOwner.Health - P.Health, 255), -255);

							C.DrawColor.R = ((-1 * DeltaHealth) / 2 + 128) * (PulseBrightness / 255.0);
							C.DrawColor.G = (DeltaHealth / 2 + 128) * (PulseBrightness / 255.0);
							C.DrawColor.B = 0;
						}
	 				}
					//bossinv purple icons
					foreach DynamicActors(class'BossInv', BInv)
					{
						MinEnemyDist = FMin(MinEnemyDist, Dist);
						C.DrawColor.R = PulseBrightness;
						C.DrawColor.G = 0;
						C.DrawColor.B = PulseBrightness;
					}
				}
				else
				{
					C.DrawColor.R = 0;
					C.DrawColor.G = PulseBrightness;
					C.DrawColor.B = 0;
				}
				Dir = rotator(P.Location - Start);
				OffsetScale = RadarScale*Dist*0.000167;
				if (PawnOwner == None)
					Angle = ((Dir.Yaw - PlayerOwner.Rotation.Yaw) & 65535) * 6.2832/65536;
				else
					Angle = ((Dir.Yaw - PawnOwner.Rotation.Yaw) & 65535) * 6.2832/65536;
				C.SetPos(RadarPosX * C.ClipX + OffsetScale * C.ClipX * sin(Angle) - 0.5*DotSize,
						OffsetY * C.ClipY - OffsetScale * C.ClipX * cos(Angle) - 0.5*DotSize);
				C.DrawTile(Material'InterfaceContent.Hud.SkinA',DotSize,DotSize,838,238,144,144);
			}
		}
	}

	DrawBossTime(C);
	DrawKillZone(C);
}

simulated function DrawTextWithBackground(Canvas C, String Text, Color TextColor, float XO, float YO)
{
	local float XL, YL, XL2, YL2;

	C.StrLen(Text, XL, YL);

	XL2 = XL + 64 * ResScaleX;
	YL2 = YL +  8 * ResScaleY;

	C.DrawColor = C.MakeColor(0, 0, 0, 150);
	C.SetPos(XO - XL2*0.5, YO - YL2*0.5);
	C.DrawTile(Texture'HudContent.Generic.HUD', XL2, YL2, 168, 211, 166, 44);

	C.DrawColor = TextColor;
	C.SetPos(XO - XL*0.5, YO - YL*0.5);
	C.DrawText(Text, false);
}

simulated function Timer()
{
	Super.Timer();

	LoadingBarSpread = (FClamp (0.625 / GRI.MonsterPreloads, 0.001, 0.625)) / 10;
	if (LoadingBarSizeX < 0.625)
	{
		LoadingBarSizeX = Fmin(LoadingBarSizeX + LoadingBarSpread ,0.625);
	}
	else
	{
		SetTimer(0.0,false);
		bMeshesLoaded = true;
		PlayerInv(PlayerOwner).bMeshesLoaded = true;
	}
}

simulated function Tick(float DeltaTime)
{
	Super.Tick(DeltaTime);

	RadarPulse = RadarPulse + 0.5 * DeltaTime;
	if (RadarPulse >= 1)
	{
		if (!bNoRadarSound && (Level.TimeSeconds - LastDrawRadar < 0.2))
			PlayerOwner.ClientPlaySound(Sound'RadarPulseSound',true,FMin(1.0,300/MinEnemyDist));
		RadarPulse = RadarPulse - 1;
	}

	fBlink += DeltaTime;
	while (fBlink > 0.5)
		fBlink -= 0.5;

	fPulse = Abs(1.f - 4*fBlink);

	if (GRI == None && PlayerOwner.GameReplicationInfo != None)
		GRI = FailsGRI(PlayerOwner.GameReplicationInfo);
}

simulated function DrawBossTime(Canvas C)
{
	local Color myColor;
	local float Seconds;
	local int BC;

	if (PlayerOwner == None || GRI == None || ScoreBoard == None || GRI.BossTimeLimit <= 0)
		return;

	C.Font	= GetFontSizeIndex(C, 0);
	C.Style = ERenderStyle.STY_Alpha;
	if (GRI.BossTimeLimit < 61)
		myColor = RedColor*(1.f-fPulse) + WhiteColor * fPulse;
	else if (GRI.BossTimeLimit < 121)
		myColor = GoldColor*(1.f-fPulse) + WhiteColor * fPulse;
	else if (GRI.BossTimeLimit < 181)
		myColor = GreenColor*(1.f-fPulse) + WhiteColor * fPulse;
	Seconds = Max(0, GRI.BossTimeLimit);
	BC = GRI.NumBoss;

	DrawTextWithBackground(C, BossTimeString@ScoreBoard.FormatTime(Seconds), myColor, C.ClipX*0.5, C.ClipY*0.15);

	C.Font	= GetFontSizeIndex(C, -2);
	C.Style = ERenderStyle.STY_Alpha;
	myColor = RedColor;
	DrawTextWithBackground(C, BossCountString@BC, myColor, C.ClipX*0.5, C.ClipY*0.20);
}

simulated function DrawKillZone(Canvas C)
{
	local Color myColor;
	local float Seconds;
	local int MC;

	if (PlayerOwner == None || GRI == None || ScoreBoard == None || GRI.KillZoneLimit <= 0)
		return;

	C.Font	= GetFontSizeIndex(C, 0);
	C.Style = ERenderStyle.STY_Alpha;
	if (GRI.KillZoneLimit < 21)
		myColor = RedColor*(1.f-fPulse) + WhiteColor * fPulse;
	else if (GRI.KillZoneLimit < 41)
		myColor = GoldColor*(1.f-fPulse) + WhiteColor * fPulse;
	else if (GRI.KillZoneLimit < 61)
		myColor = GreenColor*(1.f-fPulse) + WhiteColor * fPulse;
	Seconds = Max(0, GRI.KillZoneLimit);
	MC = GRI.NumMons;

	DrawTextWithBackground(C, KillZoneString@ScoreBoard.FormatTime(Seconds), myColor, C.ClipX*0.5, C.ClipY*0.15);

	C.Font	= GetFontSizeIndex(C, -2);
	C.Style = ERenderStyle.STY_Alpha;
	myColor = RedColor;
	DrawTextWithBackground(C, MonsCountString@MC, myColor, C.ClipX*0.5, C.ClipY*0.20);
}

simulated function DrawLoading(Canvas C)
{
	DrawLoadingContainer(C);
	DrawLoadingBar(C);

	if (!bLoadingStarted)
	{
		SetTimer(0.0175,true);
		bLoadingStarted = true;
	}
}

simulated function DrawLoadingContainer(Canvas C)
{
	C.Reset();
	C.Style = ERenderStyle.STY_Translucent;
	C.DrawColor = LoadingContainerColor;
	C.SetPos(0.5 * C.ClipX - ((0.625 * C.ClipY)/2), 0.85 * C.ClipY);
	C.DrawTilePartialStretched(LoadingContainerImage, 0.625 * C.ClipY, 16);
	C.DrawColor = WhiteColor;
	C.SetPos(0.5 * C.ClipX - ((0.625 * C.ClipY)/2), 0.85 * C.ClipY);
	C.DrawTilePartialStretched(LoadingContainerCompanionImage, 0.625 * C.ClipY, 16);
	C.DrawColor = WhiteColor;
	C.Font = GetFontSizeIndex(C, -4 + int(HudScale * 1.25));
	C.DrawScreenText(PreloadString, 0.5, 0.9, DP_MiddleMiddle);
}

simulated function DrawLoadingBar(Canvas C)
{
	C.Reset();
	C.Style = ERenderStyle.STY_Normal;
	C.DrawColor = WhiteColor;
	C.SetPos(0.5 * C.ClipX - ((LoadingBarSizeX * C.ClipY)/2), 0.85 * C.ClipY);
	C.DrawTilePartialStretched(LoadingBarImage, LoadingBarSizeX * C.ClipY, 15);
}

function bool CustomCrosshairsAllowed()
{
	return true;
}

function bool CustomCrosshairColorAllowed()
{
	return true;
}

function bool CustomHUDColorAllowed()
{
	return true;
}

defaultproperties
{
     bDrawPreloading=True
     BossTimeString="Boss Time:"
     KillZoneString="Kill Zone:"
     MonsCountString="Monsters:"
     BossCountString="Bosses:"
     PreloadString="Preloading:"
     RadarScale=0.250000
     RadarPosX=0.934900
     RadarPosY=0.050000
     RadarColor=(R=0,G=0,B=0,A=220)
     PulseColor=(R=100,G=100,B=100,A=255)
     OutlineColor=(R=0,G=255,B=0,A=255)
     LoadingContainerColor=(R=255,G=255,B=255,A=255)
     LoadingBarSizeX=0.001000
     LoadingFont=Font'2k4Fonts.Verdana24'
     LoadingContainerImage=Texture'2K4Menus.NewControls.ComboTickWatched'
     LoadingContainerCompanionImage=Shader'XGameShaders.BRShaders.BombIconBS'
     LoadingBarImage=Texture'2K4Menus.NewControls.GradientButtonFocused'
     YouveLostTheMatch="The Invasion Continues"
}