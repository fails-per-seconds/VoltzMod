Class BTClient_TrailerMenu Extends FloatingWindow;

var automated GUIButton b_Save, b_Reset;
var automated GUISlider s_Red[2], s_Green[2], s_Blue[2];
var automated GUILabel l_TrailerColor[2];
var editconst ColorModifier SlideColor[6];
var automated GUISectionBackground sbg_render;
var automated GUIImage TrailerBounds;
var editconst BTClient_TrailerInfo myTrailerInfo;
var automated GUIEditBox TrailerTex;
var() vector Trailer_Offset;
var() int Incr;
var int A;

var BTClient_PreviewTrailer TrailerCopy;

var editconst bool bCanSave;
var float LastSaveTime;

Function InitializeTrailer()
{
	local Pawn P;
	local BTClient_TrailerInfo TrailerHandler;

	P = PlayerOwner().Pawn;
	if (P != None)
	{
		foreach P.DynamicActors(class'BTClient_TrailerInfo', TrailerHandler)
		{
			if (TrailerHandler.Pawn == P)
			{
				myTrailerInfo = TrailerHandler;
				break;
			}
		}
	}

	if (myTrailerInfo == none)
		Controller.CloseMenu(true);
}

Function Opened(GUIComponent Sender)
{
	InitializeTrailer();

	SlideColor[0] = ColorModifier(PlayerOwner().Level.ObjectPool.AllocateObject(Class'ColorModifier'));
	SlideColor[0].Material = s_Red[0].FillImage;
	SlideColor[0].Color.R = 255;
	SlideColor[0].Color.G = 0;
	SlideColor[0].Color.B = 0;
	SlideColor[3].Color.A = 255;
	s_Red[0].FillImage = SlideColor[0];

	SlideColor[1] = ColorModifier(PlayerOwner().Level.ObjectPool.AllocateObject(Class'ColorModifier'));
	SlideColor[1].Material = s_Green[0].FillImage;
	SlideColor[1].Color.R = 0;
	SlideColor[1].Color.G = 255;
	SlideColor[1].Color.B = 0;
	SlideColor[3].Color.A = 255;
	s_Green[0].FillImage = SlideColor[1];

	SlideColor[2] = ColorModifier(PlayerOwner().Level.ObjectPool.AllocateObject(Class'ColorModifier'));
	SlideColor[2].Material = s_Blue[0].FillImage;
	SlideColor[2].Color.R = 0;
	SlideColor[2].Color.G = 0;
	SlideColor[2].Color.B = 255;
	SlideColor[3].Color.A = 255;
	s_Blue[0].FillImage = SlideColor[2];

	// Second one
	SlideColor[3] = ColorModifier(PlayerOwner().Level.ObjectPool.AllocateObject(Class'ColorModifier'));
	SlideColor[3].Material = s_Red[1].FillImage;
	SlideColor[3].Color.R = 255;
	SlideColor[3].Color.G = 0;
	SlideColor[3].Color.B = 0;
	SlideColor[3].Color.A = 255;
	s_Red[1].FillImage = SlideColor[3];

	SlideColor[4] = ColorModifier(PlayerOwner().Level.ObjectPool.AllocateObject(Class'ColorModifier'));
	SlideColor[4].Material = s_Green[1].FillImage;
	SlideColor[4].Color.R = 0;
	SlideColor[4].Color.G = 255;
	SlideColor[4].Color.B = 0;
	SlideColor[3].Color.A = 255;
	s_Green[1].FillImage = SlideColor[4];

	SlideColor[5] = ColorModifier(PlayerOwner().Level.ObjectPool.AllocateObject(Class'ColorModifier'));
	SlideColor[5].Material = s_Blue[1].FillImage;
	SlideColor[5].Color.R = 0;
	SlideColor[5].Color.G = 0;
	SlideColor[5].Color.B = 255;
	SlideColor[3].Color.A = 255;
	s_Blue[1].FillImage = SlideColor[5];
	Super.Opened(Sender);

	InitializePreview();
}

Function Closed(GUIComponent Sender, bool bCancelled)
{
	local int i;

	if (TrailerCopy != None)
	{
		TrailerCopy.Destroy();
		TrailerCopy = none;
	}

	for(i = 0; i < 6; ++i)
	{
		if (SlideColor[i] != None)
		{
			SlideColor[i].Material = SlideColor[i].Default.Material;
			SlideColor[i].Color = SlideColor[i].Default.Color;
			PlayerOwner().Level.ObjectPool.FreeObject(SlideColor[i]);
			SlideColor[i] = None;
		}
	}
	Super.Closed(Sender,bCancelled);
}

Function SaveData()
{
	PlayerOwner().ServerMutate("SetTrailerColor" @ s_Red[0].Value @ s_Green[0].Value @ s_Blue[0].Value @ s_Red[1].Value @ s_Green[1].Value @ s_Blue[1].Value);

	if ((myTrailerInfo != none && myTrailerInfo.RankSkin.TrailerTexture != string(TrailerCopy.Skins[0])) || myTrailerInfo == none)
		PlayerOwner().ServerMutate("SetTrailerTexture "$string(TrailerCopy.Skins[0]));
}

Function UpdateSliderValues( color newvalue[2] )
{
	local int i;

	for(i = 0; i < 2; ++i)
	{
		s_Red[i].SetValue(newvalue[i].R);
		s_Green[i].SetValue(newvalue[i].G);
		s_Blue[i].SetValue(newvalue[i].B);
	}
	UpdateSliderColors();
}

Function UpdateTrailer()
{
	local int i;

	if (TrailerCopy == None)
		return;

	for(i = 0; i < 2; ++i)
	{
		TrailerCopy.mColorRange[i].R = s_Red[i].Value;
		TrailerCopy.mColorRange[i].G = s_Green[i].Value;
		TrailerCopy.mColorRange[i].B = s_Blue[i].Value;
	}
}

Function UpdateSliderColors()
{
	SlideColor[0].Color.R = s_Red[0].Value;
	SlideColor[1].Color.G = s_Green[0].Value;
	SlideColor[2].Color.B = s_Blue[0].Value;
	SlideColor[3].Color.R = s_Red[1].Value;
	SlideColor[4].Color.G = s_Green[1].Value;
	SlideColor[5].Color.B = s_Blue[1].Value;
}

Function bool InternalOnClick(GUIComponent Sender)
{
	local int i;

	if (PlayerOwner().Level.TimeSeconds-LastSaveTime > 0.5)
		EnableComponent(b_Save);

	if (Sender == b_Save)
	{
		LastSaveTime = PlayerOwner().Level.TimeSeconds;
		SaveData();
		DisableComponent(b_Save);
		return True;
	}
	else if (Sender == b_Reset)
	{
		TrailerTex.SetText("None");
		TrailerCopy.Skins[0] = Texture'SpeedTrailTex';
		for(i = 0; i < 2; i++)
		{
			s_Red[i].Value = 255;
			s_Green[i].Value = 255;
			s_Blue[i].Value = 255;
		}
		UpdateSliderColors();
		UpdateTrailer();
		return True;
	}
	return False;
}

Function InternalOnChange( GUIComponent Sender )
{
	local Material M;

	if (Sender == TrailerTex)
	{
		if (TrailerCopy == None)
			return;

		if (TrailerTex.GetText() == "None")
			TrailerCopy.Skins[0] = Texture'SpeedTrailTex';

		M = Material(DynamicLoadObject(TrailerTex.GetText(), Class'Material', True));
		if (M != None)
			TrailerCopy.Skins[0] = M;

		return;
	}
	else if (Sender.IsA('GUISlider'))
	{
		UpdateSliderColors();
		UpdateTrailer();
		return;
	}
}

Function InitializePreview()
{
	TrailerCopy = PlayerOwner().Spawn(Class'BTClient_PreviewTrailer', None);
	if (TrailerCopy != None)
	{
		TrailerCopy.bHidden = True;
		TrailerCopy.mColorRange[0] = myTrailerInfo.RankSkin.TrailerColor[0];
		TrailerCopy.mColorRange[1] = myTrailerInfo.RankSkin.TrailerColor[1];
		TrailerCopy.Skins[0] = Material(DynamicLoadObject(myTrailerInfo.RankSkin.TrailerTexture, class'Material', true));
		TrailerTex.SetText(myTrailerInfo.RankSkin.TrailerTexture);

		UpdateSliderValues(TrailerCopy.mColorRange);
	}
}

Function UpdateTrailerOffset()
{
	if (A >= 0 && A < 20)
		Trailer_Offset.Y += Incr;

	if (A > 19 && A < 40)
		Trailer_Offset.Z += Incr;

	if (A > 39 && A < 60)
		Trailer_Offset.Y -= Incr;

	if (A > 59 && A < 80)
		Trailer_Offset.Z -= Incr;

	A++;

	if (A == 80)
		A = 0;
}

Function bool InternalOnDraw(Canvas C)
{
	local vector CamPos, X, Y, Z;
	local rotator CamRot;

	if (TrailerCopy == None)
		return false;

	C.GetCameraLocation(CamPos, CamRot);
	GetAxes(CamRot, X, Y, Z);
	UpdateTrailerOffset();
	TrailerCopy.SetLocation(CamPos + (Trailer_Offset.X * X) + (Trailer_Offset.Y * Y) + (Trailer_Offset.Z * Z));
	C.DrawActorClipped(TrailerCopy, False, TrailerBounds.ActualLeft(), TrailerBounds.ActualTop(), TrailerBounds.ActualWidth(), TrailerBounds.ActualHeight(), True);
	return True;
}

defaultproperties
{
     Begin Object Class=GUIButton Name=SaveButton
         Caption="Save"
         WinTop=0.900000
         WinLeft=0.825000
         WinWidth=0.130000
         WinHeight=0.050000
         OnClick=BTClient_TrailerMenu.InternalOnClick
         OnKeyEvent=SaveButton.InternalOnKeyEvent
     End Object
     b_Save=GUIButton'BTClient_TrailerMenu.SaveButton'

     Begin Object Class=GUIButton Name=ResetButton
         Caption="Reset"
         WinTop=0.900000
         WinLeft=0.050000
         WinWidth=0.130000
         WinHeight=0.050000
         OnClick=BTClient_TrailerMenu.InternalOnClick
         OnKeyEvent=ResetButton.InternalOnKeyEvent
     End Object
     b_Reset=GUIButton'BTClient_TrailerMenu.ResetButton'

     Begin Object Class=GUISlider Name=Red
         MaxValue=255.000000
         bIntSlider=True
         bShowCaption=True
         WinTop=0.645000
         WinLeft=0.600000
         WinWidth=0.350000
         OnClick=Red.InternalOnClick
         OnMousePressed=Red.InternalOnMousePressed
         OnMouseRelease=Red.InternalOnMouseRelease
         OnChange=BTClient_TrailerMenu.InternalOnChange
         OnKeyEvent=Red.InternalOnKeyEvent
         OnCapturedMouseMove=Red.InternalCapturedMouseMove
     End Object
     s_Red(0)=GUISlider'BTClient_TrailerMenu.Red'

     Begin Object Class=GUISlider Name=RedX
         MaxValue=255.000000
         Value=255.000000
         bIntSlider=True
         bShowCaption=True
         WinTop=0.645000
         WinLeft=0.050000
         WinWidth=0.350000
         OnClick=RedX.InternalOnClick
         OnMousePressed=RedX.InternalOnMousePressed
         OnMouseRelease=RedX.InternalOnMouseRelease
         OnChange=BTClient_TrailerMenu.InternalOnChange
         OnKeyEvent=RedX.InternalOnKeyEvent
         OnCapturedMouseMove=RedX.InternalCapturedMouseMove
     End Object
     s_Red(1)=GUISlider'BTClient_TrailerMenu.RedX'

     Begin Object Class=GUISlider Name=Green
         MaxValue=255.000000
         bIntSlider=True
         bShowCaption=True
         WinTop=0.705000
         WinLeft=0.600000
         WinWidth=0.350000
         OnClick=Green.InternalOnClick
         OnMousePressed=Green.InternalOnMousePressed
         OnMouseRelease=Green.InternalOnMouseRelease
         OnChange=BTClient_TrailerMenu.InternalOnChange
         OnKeyEvent=Green.InternalOnKeyEvent
         OnCapturedMouseMove=Green.InternalCapturedMouseMove
     End Object
     s_Green(0)=GUISlider'BTClient_TrailerMenu.Green'

     Begin Object Class=GUISlider Name=GreenX
         MaxValue=255.000000
         Value=255.000000
         bIntSlider=True
         bShowCaption=True
         WinTop=0.705000
         WinLeft=0.050000
         WinWidth=0.350000
         OnClick=GreenX.InternalOnClick
         OnMousePressed=GreenX.InternalOnMousePressed
         OnMouseRelease=GreenX.InternalOnMouseRelease
         OnChange=BTClient_TrailerMenu.InternalOnChange
         OnKeyEvent=GreenX.InternalOnKeyEvent
         OnCapturedMouseMove=GreenX.InternalCapturedMouseMove
     End Object
     s_Green(1)=GUISlider'BTClient_TrailerMenu.GreenX'

     Begin Object Class=GUISlider Name=Blue
         MaxValue=255.000000
         bIntSlider=True
         bShowCaption=True
         WinTop=0.765000
         WinLeft=0.600000
         WinWidth=0.350000
         OnClick=Blue.InternalOnClick
         OnMousePressed=Blue.InternalOnMousePressed
         OnMouseRelease=Blue.InternalOnMouseRelease
         OnChange=BTClient_TrailerMenu.InternalOnChange
         OnKeyEvent=Blue.InternalOnKeyEvent
         OnCapturedMouseMove=Blue.InternalCapturedMouseMove
     End Object
     s_Blue(0)=GUISlider'BTClient_TrailerMenu.Blue'

     Begin Object Class=GUISlider Name=BlueX
         MaxValue=255.000000
         Value=255.000000
         bIntSlider=True
         bShowCaption=True
         WinTop=0.765000
         WinLeft=0.050000
         WinWidth=0.350000
         OnClick=BlueX.InternalOnClick
         OnMousePressed=BlueX.InternalOnMousePressed
         OnMouseRelease=BlueX.InternalOnMouseRelease
         OnChange=BTClient_TrailerMenu.InternalOnChange
         OnKeyEvent=BlueX.InternalOnKeyEvent
         OnCapturedMouseMove=BlueX.InternalCapturedMouseMove
     End Object
     s_Blue(1)=GUISlider'BTClient_TrailerMenu.BlueX'

     Begin Object Class=GUILabel Name=ColorTitle
         Caption="Trailer Color Two"
         TextColor=(B=255,G=255,R=255)
         WinTop=0.585000
         WinLeft=0.600000
     End Object
     l_TrailerColor(0)=GUILabel'BTClient_TrailerMenu.ColorTitle'

     Begin Object Class=GUILabel Name=ColorTitleX
         Caption="Trailer Color One"
         TextColor=(B=255,G=255,R=255)
         WinTop=0.585000
         WinLeft=0.050000
     End Object
     l_TrailerColor(1)=GUILabel'BTClient_TrailerMenu.ColorTitleX'

     Begin Object Class=GUISectionBackground Name=Render
         HeaderBase=Texture'2K4Menus.NewControls.Display99'
         Caption="Trailer Preview"
         WinTop=0.050000
         WinLeft=0.050000
         WinWidth=0.900000
         WinHeight=0.400000
         OnPreDraw=Render.InternalPreDraw
     End Object
     sbg_render=GUISectionBackground'BTClient_TrailerMenu.Render'

     Begin Object Class=GUIImage Name=TrailerBoundsImage
         Image=Texture'2K4Menus.Controls.buttonSquare_b'
         DropShadow=Texture'2K4Menus.Controls.Shadow'
         ImageColor=(A=128)
         ImageStyle=ISTY_Stretched
         DropShadowX=4
         DropShadowY=4
         WinTop=0.050000
         WinLeft=0.050000
         WinWidth=0.900000
         WinHeight=0.400000
         RenderWeight=0.520000
         bBoundToParent=True
         bScaleToParent=True
         OnDraw=BTClient_TrailerMenu.InternalOnDraw
     End Object
     TrailerBounds=GUIImage'BTClient_TrailerMenu.TrailerBoundsImage'

     Begin Object Class=GUIEditBox Name=TrailerTexBox
         WinTop=0.500000
         WinLeft=0.050000
         WinWidth=0.900000
         WinHeight=0.050000
         bBoundToParent=True
         bScaleToParent=True
         OnActivate=TrailerTexBox.InternalActivate
         OnDeActivate=TrailerTexBox.InternalDeactivate
         OnChange=BTClient_TrailerMenu.InternalOnChange
         OnKeyType=TrailerTexBox.InternalOnKeyType
         OnKeyEvent=TrailerTexBox.InternalOnKeyEvent
     End Object
     TrailerTex=GUIEditBox'BTClient_TrailerMenu.TrailerTexBox'

     Trailer_Offset=(X=256.000000,Y=-64.000000,Z=-40.000000)
     Incr=6
     bCanSave=True
     WindowName="Trailer Configuration"
     bAllowedAsLast=True
     WinTop=0.100000
     WinLeft=0.100000
     WinWidth=0.600000
     WinHeight=0.600000
}
