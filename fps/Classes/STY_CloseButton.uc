class STY_CloseButton extends STY2SquareButton;

defaultproperties
{
     KeyName="CloseButton"
     FontColors(0)=(R=255,G=255,B=255,A=255) 	//white
     FontColors(1)=(R=255,G=242,B=0,A=255)  	//yellow
     FontColors(2)=(R=255,G=127,B=39,A=255) 	//orange
     FontColors(3)=(R=255,G=39,B=39,A=255) 	//red
     FontColors(4)=(R=255,G=255,B=255,A=180) 	//white
     Images(0)=Texture'fps.btclose.bt_close'
     Images(1)=Texture'fps.btclose.bw_close'
     Images(2)=Texture'fps.btclose.bw_close'
     Images(3)=Texture'fps.btclose.bp_close'
     Images(4)=Texture'fps.btclose.bt_close'
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