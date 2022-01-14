class STY_MyButton extends STY2SquareButton;

defaultproperties
{
     KeyName="MyButton"
     FontColors(0)=(R=255,G=255,B=255,A=255)	//white
     FontColors(1)=(R=14,G=164,B=122,A=255)	//greeny
     FontColors(2)=(R=14,G=164,B=122,A=255)	//greeny
     FontColors(3)=(R=14,G=164,B=222,A=255)	//bluey
     FontColors(4)=(R=133,G=133,B=133,A=255)	//grey
     Images(0)=Texture'fps.btnormal.bt_black'
     Images(1)=Texture'fps.btnormal.bt_grey'
     Images(2)=Texture'fps.btnormal.bw_grey'
     Images(3)=Texture'fps.btnormal.bt_grey'
     Images(4)=Texture'fps.btnormal.bt_blank'
     ImgStyle(0)=ISTY_Scaled
     ImgStyle(1)=ISTY_Scaled
     ImgStyle(2)=ISTY_Scaled
     ImgStyle(3)=ISTY_Scaled
     ImgStyle(4)=ISTY_Scaled
}

//Description:
//     Img(0) Blurry (component has no focus at all)
//     Img(1) Watched (when Mouse is hovering over it)
//     Img(2) Focused (component is selected)
//     Img(3) Pressed (component is being pressed)
//     Img(4) Disabled (component is disabled)