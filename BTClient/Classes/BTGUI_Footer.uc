class BTGUI_Footer extends GUIMultiComponent;

var automated GUILabel FooterLabel;

function SetText( coerce string newText )
{
	FooterLabel.Caption = newText;
}

defaultproperties
{
     Begin Object Class=GUILabel Name=oFooterLabel
         TextAlign=TXTA_Center
         TextColor=(B=255,G=255,R=255)
         bTransparent=False
         FontScale=FNS_Small
         StyleName="BTFooter"
         WinHeight=1.000000
         bBoundToParent=True
         bScaleToParent=True
     End Object
     FooterLabel=GUILabel'BTGUI_Footer.oFooterLabel'
}
