class BTClient_STY_ListSelection extends STY2ListSelection;

event Initialize()
{
	Super(GUIStyles).Initialize();
}

defaultproperties
{
     KeyName="BTListSelection"
     FontColors(0)=(B=255,G=255,A=255)
     FontColors(1)=(B=255,G=255)
     FontColors(2)=(B=255,G=255)
     FontColors(3)=(B=255,G=255)
     FontColors(4)=(B=100,G=100,R=100,A=200)
     ImgColors(0)=(B=34,G=34,R=34,A=230)
     ImgColors(1)=(B=51,G=51,R=51,A=242)
     ImgColors(2)=(B=51,G=51,R=51,A=236)
     ImgColors(3)=(B=51,G=51,R=51,A=236)
     ImgColors(4)=(B=0,G=10,A=248)
     Images(0)=Texture'HUD.BTScoreBoardBG'
     Images(1)=Texture'HUD.BTScoreBoardBG'
     Images(2)=Texture'HUD.BTScoreBoardBG'
     Images(3)=Texture'HUD.BTScoreBoardBG'
     Images(4)=Texture'HUD.BTScoreBoardBG'
     BorderOffsets(0)=5
     BorderOffsets(1)=5
     BorderOffsets(2)=5
     BorderOffsets(3)=5
}
