class STY_MyReset extends STY2SquareButton;

defaultproperties
{
     KeyName="MyReset"
     FontColors(0)=(R=79,G=79,B=79,A=255)
     FontColors(1)=(R=230,G=230,B=230,A=255)
     FontColors(2)=(R=79,G=79,B=79,A=255)
     FontColors(3)=(R=14,G=164,B=122,A=255)
     FontColors(4)=(R=60,G=60,B=60,A=255)
     Images(0)=Texture'fps.btreset.bt_reset'
     Images(1)=Texture'fps.btreset.bw_reset'
     Images(2)=Texture'fps.btreset.bt_reset'
     Images(3)=Texture'fps.btreset.bp_reset'
     Images(4)=Texture'fps.btnormal.bt_blank'
     ImgStyle(0)=ISTY_PartialScaled
     ImgStyle(1)=ISTY_PartialScaled
     ImgStyle(2)=ISTY_PartialScaled
     ImgStyle(3)=ISTY_PartialScaled
     ImgStyle(4)=ISTY_PartialScaled
}

//Description:
//     Img(0) Blurry (component has no focus at all)
//     Img(1) Watched (when Mouse is hovering over it)
//     Img(2) Focused (component is selected)
//     Img(3) Pressed (component is being pressed)
//     Img(4) Disabled (component is disabled)