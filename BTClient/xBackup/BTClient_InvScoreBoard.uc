class BTClient_InvScoreBoard extends ScoreBoard;

var() const string Header_Rank, Header_Name, Header_Objectives, Header_Score, Header_Deaths;
var() const string SubHeader_Time, Header_Ping, Header_PacketLoss, Header_Players, Header_Spectators, Header_ElapsedTime;

var protected const Texture BackgroundTexture;
var protected const color GrayColor, PrimaryColor, SecondaryColor;

var() protected const float XClipOffset;
var() protected const float YClipOffset;

var protected BTClient_Config BTConfig;
var protected const class<BTClient_Interaction> BTInterClass;

var protected transient string AdminSubText, ReadySubText, PremiumSubText;
var protected transient color TempColor;
var protected int SavedElapsedTime;
var protected float YOffset, NX, NXL, OX, OXL, OSize, DX, DXL, TX, TXL, PX, ETX, HX, RX, RXL, OTHERX, OTHERXL;

var protected array<PlayerReplicationInfo> SortedPlayers, SortedSpectators;

//RPG Stuff
var() const string Header_LVL, Header_EXP;
var protected float LX, LXL, EX, EXL;

static function string GetCName(PlayerReplicationInfo PRI)
{
	local LinkedReplicationInfo LRI;
	local string N;

	for(LRI = PRI.CustomReplicationInfo; LRI != None; LRI = LRI.NextReplicationInfo)
	{
		if (LRI.IsA('UTComp_PRI'))
		{
			N = LRI.GetPropertyText("ColoredName");
			if (Len(N) == 0)
				return PRI.PlayerName;

			return N;
		}
	}
	return PRI.PlayerName;
}

private static function LinkedReplicationInfo GetGRI(PlayerReplicationInfo PRI)
{
	local LinkedReplicationInfo LRI;

	for(LRI = PRI.CustomReplicationInfo; LRI != None; LRI = LRI.NextReplicationInfo)
	{
		if (LRI.IsA('GroupPlayerLinkedReplicationInfo'))
			return LRI;
	}
	return none;
}

simulated function Init()
{
	Super.Init();

	AdminSubText = #0xFF0000FF$"[Admin] "$SecondaryColor;
	ReadySubText = #0xFF8800FF$"[" $ class'ScoreBoardDeathMatch'.default.ReadyText $ "] "$SecondaryColor;
	PremiumSubText = #0x00FFFFFF$"[Premium] "$SecondaryColor;

	BTConfig = class'BTClient_Config'.static.FindSavedData();
}

simulated event DrawScoreboard(Canvas C)
{
	if (!UpdateGRI())
		return;

	UpdateScoreBoard(C);
}

function bool UpdateGRI()
{
	local int i, j;

	if (!Super.UpdateGRI())
		return false;

	SortedPlayers.Length = 0;
	SortedSpectators.Length = 0;

	j = GRI.PRIArray.Length;

	// RED
	for(i = 0; i < j; ++i)
	{
		if (GRI.PRIArray[i] == None || ((GRI.PRIArray[i].bOnlySpectator || GRI.PRIArray[i].bIsSpectator) && !GRI.PRIArray[i].bWaitingPlayer) || (GRI.PRIArray[i].Team == none || GRI.PRIArray[i].Team.TeamIndex != 0))
			continue;

		SortedPlayers[SortedPlayers.Length] = GRI.PRIArray[i];
	}

	// BLUE
	for(i = 0; i < j; ++i)
	{
		if (GRI.PRIArray[i] == None || ((GRI.PRIArray[i].bOnlySpectator || GRI.PRIArray[i].bIsSpectator) && !GRI.PRIArray[i].bWaitingPlayer) || (GRI.PRIArray[i].Team == none || GRI.PRIArray[i].Team.TeamIndex != 1))
			continue;

		SortedPlayers[SortedPlayers.Length] = GRI.PRIArray[i];
	}

	// OTHER
	for(i = 0; i < j; ++i)
	{
		if (GRI.PRIArray[i] == None || ((GRI.PRIArray[i].bOnlySpectator || GRI.PRIArray[i].bIsSpectator) && !GRI.PRIArray[i].bWaitingPlayer) || (GRI.PRIArray[i].Team != none && GRI.PRIArray[i].Team.TeamIndex <= 1))
			continue;

		SortedPlayers[SortedPlayers.Length] = GRI.PRIArray[i];
	}

	// Sort Spectators
	for(i = 0; i < j; ++i)
	{
		if (GRI.PRIArray[i] == None || ((!GRI.PRIArray[i].bOnlySpectator && !GRI.PRIArray[i].bIsSpectator) || GRI.PRIArray[i].bWaitingPlayer))
			continue;

		if (GRI.PRIArray[i].bBot)
			continue;

		SortedSpectators[SortedSpectators.Length] = GRI.PRIArray[i];
	}
	return true;
}

simulated function UpdateScoreBoard(Canvas C)
{
	local int i, j;
	local string s;
	local float X, Y, XL, YL, TY, PredictedPY, PredictedSY;
	local float rowTileX, rowTextX, rowWidth, rowHeight, rowMargin, rowSegmentHeight;

	if (GRI == none)
		return;

	C.Font = BTInterClass.static.GetScreenFont(C);
	C.StrLen("T", XL, YL);
	rowMargin = 2;
	rowHeight = YL*2 + 4;
	rowSegmentHeight = YL;

	if (SortedPlayers.Length != 0)
 	{
		PredictedPY = SortedPlayers.Length*(rowHeight + rowMargin);
	}
	PredictedPY += YL*3;

	if (SortedSpectators.Length != 0)
	{
		PredictedSY = SortedSpectators.Length*(rowHeight + rowMargin);
		if (SortedPlayers.Length == 0)
			PredictedSY += YL;
	}

	// Draw Scoreboard Table
	X = C.ClipX-(XClipOffset*2);
	rowWidth = X - 8;
	Y = Min(PredictedPY + PredictedSY + 8, C.ClipY-(YClipOffset*2) + 4);
	C.SetPos(XClipOffset, YClipOffset);
	C.DrawColor = BTConfig.CTable;
	C.DrawTile(BackgroundTexture, X, Y, 0, 0, 256, 256);

	// Draw Level Title + WaveNum
	s = "Playing:" @ Outer.Name @ " | " @ "Wave:" @ InvasionGameReplicationInfo(GRI).WaveNumber+1;
	C.StrLen(s, XL, YL);
	C.SetPos(XClipOffset, YClipOffset - YL-8-4);
	C.DrawColor = BTConfig.CTable;
	C.DrawTile(BackgroundTexture, XL+8+8, YL+8+4, 0, 0, 256, 256);

	C.DrawColor = #0x0072C688;
	BTInterClass.static.DrawColumnTile(C, XClipOffset+4, YClipOffset - YL-4-4, XL + /**COLUMN_PADDING_X*/4*2, YL+4/**COLUMN_PADDING_Y*/);
	BTInterClass.static.DrawHeaderText(C, XClipOffset+4, YClipOffset - YL-4-4, s);

	TY = YClipOffset+8;

	// Calc Rank
	HX = XClipOffset+4;
	RX = HX;
	C.StrLen(Header_Rank, RXL, YL);

	// Calc Name
	HX += 8+RXL;
	NX = HX;
	C.StrLen("WWWWWWWWWWWWWWWWWWWW", NXL, YL);

	// Calc Score
	HX += 8+NXL;
	OX = HX;
	C.StrLen("000000000", OXL, YL);

	// Calc Deaths
	HX += 8+OXL;
	DX = HX;
	C.StrLen("0000000", DXL, YL);

	// Calc RPGLev
	HX += 8+DXL;
	LX = HX;
	C.StrLen("0000000", LXL, YL);

	// Calc RPGExp
	HX += 8+LXL;
	EX = HX;
	C.StrLen("00000000000000000000", EXL, YL);

	// Calc Time
	HX += 8+EXL;
	TX = HX;
	C.StrLen("00:00:00.00", TXL, YL);

	// Calc Other
	HX += 60+TXL;
	OTHERX = HX;
	C.StrLen("WWWWWWWWWWWWWWWWWWWW", OTHERXL, YL);

	if (X+XClipOffset <= OTHERX + OTHERXL)
	{
		OTHERX = 0;
	}

	// Draw Rank Header
	C.SetPos(RX, TY);
	BTInterClass.static.DrawHeaderTile(C, RX, TY, RXL+4, YL);
	BTInterClass.static.DrawHeaderText(C, RX, TY, Header_Rank);

	// Draw Name Header
	C.SetPos(NX, TY);
	BTInterClass.static.DrawHeaderTile(C, NX, TY, NXL+4, YL);
	BTInterClass.static.DrawHeaderText(C, NX, TY, Header_Name);

	// Draw Score Header
	C.SetPos(OX, TY);
	BTInterClass.static.DrawHeaderTile(C, OX, TY, OXL+4, YL);
	BTInterClass.static.DrawHeaderText(C, OX, TY, class'ScoreBoardDeathMatch'.default.PointsText);

	// Draw Death Header
	C.SetPos(DX, TY);
	BTInterClass.static.DrawHeaderTile(C, DX, TY, DXL+4, YL);
	BTInterClass.static.DrawHeaderText(C, DX, TY, class'ScoreBoardDeathMatch'.default.DeathsText);

	// Draw RPGLevel Header
	C.SetPos(LX, TY);
 	BTInterClass.static.DrawHeaderTile(C, LX, TY, LXL+4, YL);
	BTInterClass.static.DrawHeaderText(C, LX, TY, Header_LVL);

	// Draw RPGExperience Header
	C.SetPos(EX, TY);
 	BTInterClass.static.DrawHeaderTile(C, EX, TY, EXL+4, YL);
	BTInterClass.static.DrawHeaderText(C, EX, TY, Header_EXP);

	// Draw Time Header
	C.SetPos(TX, TY);
 	BTInterClass.static.DrawHeaderTile(C, TX, TY, TXL+4, YL);
	BTInterClass.static.DrawHeaderText(C, TX, TY, Header_ElapsedTime);

	// Calc Ping
	if (Level.NetMode != NM_Standalone)
	{
		C.StrLen(class'ScoreBoardDeathMatch'.default.NetText, XL, YL);
		PX = ((XClipOffset+X)-XL);

		C.SetPos(PX - 4, TY);
		BTInterClass.static.DrawHeaderTile(C, PX-8, TY, XL+4, YL);
		BTInterClass.static.DrawHeaderText(C, PX-8, TY, class'ScoreBoardDeathMatch'.default.NetText);

		C.SetPos(PX - 4, TY+YL+2);
		C.DrawColor = SecondaryColor;
		C.DrawText("P/L");
	}

	// Get height of this font, 4 = offset from table
	C.StrLen("A", XL, YL);
	rowTileX = XClipOffset + 4;
	rowTextX = rowTileX + 4;

	YOffset = TY-4;

	// Draw Players
	j = SortedPlayers.Length;
	for(i = 0; i < j; ++i)
	{
		if (SortedPlayers[i] == None)
			continue;

		if (YOffset+YL*2+rowMargin+4 >= C.ClipY-YClipOffset)
			break;

		YOffset += YL*2+rowMargin+4;
		RenderPlayerRow(C, SortedPlayers[i], rowTileX, YOffset, rowWidth, rowHeight);
	}

	if (SortedSpectators.Length == 0)
		return;

	YOffset += 8;

	// Draw Spectators
	j = SortedSpectators.Length;
	for(i = 0; i < j; ++i)
	{
		if (SortedSpectators[i] == None)
			continue;

		if (YOffset+YL*2+rowMargin+4 >= C.ClipY-YClipOffset)
			break;

		YOffset += YL*2+rowMargin+4;
		RenderPlayerRow(C, SortedSpectators[i], rowTileX, YOffset, rowWidth, rowHeight);
	}
}

protected function RenderPlayerRow(Canvas C, PlayerReplicationInfo player, float x, float y, float rowWidth, float rowHeight)
{
	local float rowTileX, rowTileY, rowTextY, xl, yl;
	local float rowSegmentHeight;
	local string s;
	local bool isSpectator;
	local int i;
	local BTClient_ClientReplication CRI;
	local LinkedReplicationInfo GLRI;
	local ReplicationInfo other;
	local RPGStatsInv StatsInv;

	StatsInv = RPGStatsInv(Controller(Player.Owner).Pawn.FindInventoryType(class'RPGStatsInv'));

	rowTileX = x;
	rowTileY = y;
	rowTextY = rowTileY + 2;
	rowSegmentHeight = rowHeight*0.5;
	isSpectator = player.bIsSpectator || player.bOnlySpectator;

	CRI = class'BTClient_ClientReplication'.static.GetCRI(player);
	// BACKGROUND
	if (player != Controller(Owner).PlayerReplicationInfo)
		C.DrawColor = #0x22222282;
	else
		C.DrawColor = #0x4E4E3382;

	if (player.bOutOfLives)
		C.DrawColor.A = 20;

	C.SetPos(rowTileX, rowTileY);
	C.DrawTile(BackgroundTexture, rowWidth, rowHeight, 0, 0, 256, 256);

	// Draw Player Name
	C.SetPos(NX, rowTextY);
	C.DrawColor = PrimaryColor;
	C.DrawText(GetCName(player));

	// Draw Player Region
	C.SetPos(NX, rowTextY+rowSegmentHeight);
	s = "";
	if (player.bAdmin)
		s = AdminSubText;

	if (player.bReadyToPlay && !isSpectator)
		s $= ReadySubText;

	if (CRI != none && CRI.bIsPremiumMember)
		s $= PremiumSubText;

	if (isSpectator)
		s $= #0xFFFF00FF$"";
	else
		s $= SecondaryColor$"";

	s $= player.GetLocationName();
	C.DrawText(s);

	// Draw Rank
	if (CRI != none)
	{
		C.SetPos(RX+4, rowTextY);
		C.DrawColor = PrimaryColor;
		C.DrawText(Eval(CRI.Rank != 0, CRI.Rank, "N/A"), true);
	}

	// Draw Score
	if (!isSpectator)
	{
		C.SetPos(OX, rowTextY);
		C.DrawColor = PrimaryColor;
		C.DrawText(string(Min(int(player.Score), 9999)), true);

		if (ASPlayerReplicationInfo(player) != none && ASPlayerReplicationInfo(player).DisabledObjectivesCount + ASPlayerReplicationInfo(player).DisabledFinalObjective > 0)
		{
			OSize = rowSegmentHeight*1.5f;

			// Draw Objectives
			C.SetPos(OX, rowTextY - (OSize - rowSegmentHeight)*0.5f + rowSegmentHeight);
			C.DrawTile(Texture'AS_FX_TX.Icons.ScoreBoard_Objective_Final', OSize-4, OSize-4, 0.0, 0.0, 128, 128);

			s = string(ASPlayerReplicationInfo(player).DisabledObjectivesCount+ASPlayerReplicationInfo(player).DisabledFinalObjective);
			C.StrLen(s, XL, YL);
			C.SetPos(OX + OSize*0.5-XL*0.5, rowTextY + rowSegmentHeight-1);
			C.DrawColor = HUDClass.default.GoldColor;
			C.DrawText(s);
		}
	}

	if (!isSpectator)
	{
		// Draw Deaths value
		C.SetPos(DX, rowTextY);
		C.DrawColor = PrimaryColor;
		C.DrawText(string(int(player.Deaths)));

		// Draw RPGLevel value
		C.SetPos(LX, rowTextY);
		C.DrawColor = PrimaryColor;
		C.DrawText(string(StatsInv.Data.Level));

		// Draw RPGExp value
		C.SetPos(EX, rowTextY);
		C.DrawColor = PrimaryColor;
		C.DrawText(StatsInv.Data.Experience$"/"$StatsInv.Data.NeededExp);
	}

	// Draw Time
	if (CRI != none && CRI.PersonalTime > 0)
	{
		C.SetPos(TX, rowTextY+rowSegmentHeight);
		C.DrawColor = SecondaryColor;
		C.DrawText(class'BTClient_Interaction'.static.FormatTime(CRI.PersonalTime));
	}

	if ((GRI.ElapsedTime > 0 && GRI.Winner == none) || SavedElapsedTime == 0)
		SavedElapsedTime = GRI.ElapsedTime;

	C.SetPos(TX, rowTextY+2);
	C.DrawColor = PrimaryColor;
	C.DrawText(class'BTClient_Interaction'.static.StrlNoMS(Max(0, SavedElapsedTime-player.StartTime)));

	if (OTHERX != 0)
	{
		GLRI = GetGRI(player);
		if (GLRI != none)
		{
			i = int(GLRI.GetPropertyText("PlayerGroupId"));
			if (i != -1)
			{
				foreach DynamicActors(class'ReplicationInfo', other)
				{
					if (other.IsA('GroupInstance') && int(other.GetPropertyText("GroupId")) == i)
					{
						// Draw Other
						C.SetPos(OTHERX, rowTextY);
						SetPropertyText(string(Property'TempColor'.Name), other.GetPropertyText("GroupColor"));
						C.DrawColor = TempColor;
						C.DrawText(other.GetPropertyText("GroupName"));
						break;
					}
				}
			}
		}
	}

	if (Level.NetMode != NM_Standalone && !player.bBot)
	{
		s = string(Min(999, 4*player.Ping));
		C.StrLen(s, XL, YL);
		C.SetPos(rowTileX + rowWidth - XL - 4, rowTextY);
		C.DrawColor = PrimaryColor;
		C.DrawText(s);

		if (player.PacketLoss > 0)
		{
			s = string(player.PacketLoss);
			C.StrLen(s, XL, YL);
			C.SetPos(rowTileX + rowWidth - XL - 4, rowTextY+rowSegmentHeight);
			C.DrawColor = SecondaryColor;
			C.DrawText(s);
		}
	}
}

protected static function Color GetPlayerTeamColor(PlayerReplicationInfo player)
{
	local Color c;

	if (player.Team != none)
	{
		if (player.Team.TeamIndex == 0)
			c = default.HUDClass.default.RedColor;
		else if (player.Team.TeamIndex == 1)
			c = default.HUDClass.default.BlueColor;
		else
			c = default.HUDClass.default.GreenColor;
	}
	else if (player.bIsSpectator || player.bOnlySpectator)
	{
		c = default.HUDClass.default.GoldColor;
	}
	else
	{
		c = default.HUDClass.default.GreenColor;
	}
	return c;
}


final static preoperator Color #( int rgbInt )
{
	local Color c;

	c.R = rgbInt >> 24;
	c.G = rgbInt >> 16;
	c.B = rgbInt >> 8;
	c.A = (rgbInt & 255);
	return c;
}

static final preoperator string $( int A )
{
	return Chr( 0x1B ) $ (Chr( Max(byte(A >> 16), 1)  ) $ Chr( Max(byte(A >> 8), 1) ) $ Chr( Max(byte(A & 0xFF), 1) ));
}

static final preoperator string $( Color A )
{
	return (Chr( 0x1B ) $ (Chr( Max( A.R, 1 )  ) $ Chr( Max( A.G, 1 ) ) $ Chr( Max( A.B, 1 ) )));
}

static final operator(40) string $( coerce string A, Color B )
{
	return A $ $B;
}

static final operator(40) string $( Color A, coerce string B )
{
	return $A $ B;
}

static final operator(40) string @( coerce string A, Color B )
{
	return A @ $B;
}

static final operator(40) string @( Color A, coerce string B )
{
	return $A @ B;
}

defaultproperties
{
     Header_Rank="RANK"
     Header_Name="NAME"
     SubHeader_Time="Record"
     Header_Players="Players"
     Header_Spectators="Spectators"
     Header_ElapsedTime="TIME"
     Header_LVL="LEVEL"
     Header_EXP="EXPERIENCE"
     BackgroundTexture=Texture'HUD.BTScoreBoardBG'
     GrayColor=(B=100,G=100,R=100,A=255)
     PrimaryColor=(B=255,G=255,R=255,A=255)
     SecondaryColor=(B=182,G=182,R=182,A=255)
     XClipOffset=64.000000
     YClipOffset=64.000000
     BTInterClass=Class'BTClient_Interaction'
     HudClass=Class'XInterface.HudBase'
}
