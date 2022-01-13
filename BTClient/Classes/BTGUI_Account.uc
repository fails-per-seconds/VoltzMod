class BTGUI_Account extends BTGUI_TabBase;

var automated GUIButton b_TradeCurrency;
var automated GUIEditBox eb_TradePlayer, eb_TradeAmount;

function bool InternalOnClick(GUIComponent sender)
{
	PlayerOwner().ConsoleCommand("CloseDialog");
	if (sender == b_TradeCurrency)
	{
		if (eb_TradePlayer.GetText() == "")
		{
			PlayerOwner().ClientMessage("Please specifiy a player's name!");
			return false;
		}

		if (eb_TradeAmount.GetText() == "")
		{
			PlayerOwner().ClientMessage("Please enter amount of money that you want to give!");
			return false;
		}

		if (int(eb_TradeAmount.GetText()) <= 0)
		{
			PlayerOwner().ClientMessage("Please send more than 0$!");
			return false;
		}

		PlayerOwner().ConsoleCommand("TradeMoney" @ eb_TradePlayer.GetText() @ int(eb_TradeAmount.GetText()));
		return true;
	}
	return false;
}

defaultproperties
{
     Begin Object Class=GUIButton Name=oTradeCurrency
         Caption="Trade Money"
         Hint="Trade currency with the specified player."
         WinTop=0.010000
         WinWidth=0.250000
         WinHeight=0.050000
         OnClick=BTGUI_Account.InternalOnClick
         OnKeyEvent=oTradeCurrency.InternalOnKeyEvent
     End Object
     b_TradeCurrency=GUIButton'BTGUI_Account.oTradeCurrency'

     Begin Object Class=GUIEditBox Name=oTradePlayer
         Hint="Player Name"
         WinTop=0.010000
         WinLeft=0.260000
         WinWidth=0.250000
         WinHeight=0.050000
         bBoundToParent=True
         bScaleToParent=True
         OnActivate=oTradePlayer.InternalActivate
         OnDeActivate=oTradePlayer.InternalDeactivate
         OnKeyType=oTradePlayer.InternalOnKeyType
         OnKeyEvent=oTradePlayer.InternalOnKeyEvent
     End Object
     eb_TradePlayer=GUIEditBox'BTGUI_Account.oTradePlayer'

     Begin Object Class=GUIEditBox Name=oTradeAmount
         Hint="Money (20% of this will be used as fee!)"
         WinTop=0.010000
         WinLeft=0.520000
         WinWidth=0.250000
         WinHeight=0.050000
         bBoundToParent=True
         bScaleToParent=True
         OnActivate=oTradeAmount.InternalActivate
         OnDeActivate=oTradeAmount.InternalDeactivate
         OnKeyType=oTradeAmount.InternalOnKeyType
         OnKeyEvent=oTradeAmount.InternalOnKeyEvent
     End Object
     eb_TradeAmount=GUIEditBox'BTGUI_Account.oTradeAmount'
}
