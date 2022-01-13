class BTLevelCompletedMessage extends BTClient_LocalMessage;

var Color RecordStateColor[3];

/** Returns color A as a color tag. */
static final preoperator string $( Color A )
{
    return (Chr( 0x1B ) $ (Chr( Max( A.R, 1 )  ) $ Chr( Max( A.G, 1 ) ) $ Chr( Max( A.B, 1 ) )));
}

/** Strips all color tags from A. */
static final preoperator string %( string A )
{
    local int i;

    while( true )
    {
        i = InStr( A, Chr( 0x1B ) );
        if( i != -1 )
        {
            A = Left( A, i ) $ Mid( A, i + 4 );
            continue;
        }
        break;
    }
    return A;
}

static function color GetColor(
    optional int RecordState,
    optional PlayerReplicationInfo MessageReceiver,
    optional PlayerReplicationInfo MessageInstigator
    )
{
    return default.RecordStateColor[RecordState];
}

// Make a copy of the temporary ClientMessage
static function string GetString( optional int RecordState,
    optional PlayerReplicationInfo MessageReceiver, optional PlayerReplicationInfo MessageInstigator,
    optional Object ReceiverClientReplication )
{
    local string s;

    s = Repl( super.GetString(RecordState, MessageReceiver, MessageInstigator, ReceiverClientReplication), "«", $static.GetColor( RecordState, MessageReceiver, MessageInstigator ) );
    if( MessageInstigator == MessageReceiver )
        return Repl( s, "%PLAYER%", "You have" );

    return
        Repl( s, "%PLAYER%",
            $class'HUD'.default.WhiteColor
            $ class'BTClient_TrialScoreBoard'.static.GetCName(MessageInstigator)
            $ $GetColor(RecordState, MessageReceiver, MessageInstigator)
        );
}

static function RenderComplexMessage(
    Canvas Canvas,
    out float XL,
    out float YL,
    optional String MessageString,
    optional int RecordState,
    optional PlayerReplicationInfo MessageReceiver,
    optional PlayerReplicationInfo MessageInstigator,
    optional Object ReceiverClientReplication
    )
{
    local byte  alpha;
    local float iconSize;

    alpha = Canvas.ForcedAlpha;
    Canvas.bForceAlpha = true;
    Canvas.ForcedAlpha = Canvas.DrawColor.A;
    Canvas.DrawTextClipped( MessageString, false );

    iconSize = YL*2;
    Canvas.SetPos( Canvas.CurX - iconSize - YL*0.33, Canvas.CurY + YL*0.5 - iconSize*0.5 );
    Canvas.DrawColor = class'HUD'.default.WhiteColor;
    if( RecordState == 1 )
    {
        Canvas.DrawTile( Texture'AS_FX_TX.Icons.ScoreBoard_Objective_Single', iconSize, iconSize, 0, 0, 128, 128 );
    }
    else if( RecordState == 0 || RecordState == 2 )
    {
        Canvas.DrawTile( Texture'AS_FX_TX.Icons.ScoreBoard_Objective_Final', iconSize, iconSize, 0, 0, 128, 128 );
    }
    Canvas.ForcedAlpha = alpha;
    Canvas.bForceAlpha = false;
}

static simulated function ClientReceive(
    PlayerController P,
    optional int RecordState,
    optional PlayerReplicationInfo MessageReceiver,
    optional PlayerReplicationInfo MessageInstigator,
    optional Object ReceiverClientReplication
    )
{
    local BTClient_Config options;

    super.ClientReceive( P, RecordState, MessageReceiver, MessageInstigator, ReceiverClientReplication );

    options = class'BTClient_Config'.static.FindSavedData();
    if( (RecordState == 0 || RecordState == 2) && options.bDisplayFail )
    {
        P.ClientPlaySound( options.FailSound, true, 2.0, SLOT_Talk );
    }
    else if( RecordState == 1 && options.bDisplayNew )
    {
        P.ClientPlaySound( options.NewSound, true, 2.0, SLOT_Talk );
    }
}

// Taken from the canvas class. Changed to a different texture
final static function DrawHorizontal( Canvas C, float Y, float width )
{
    local float cx,cy;

    CX = C.CurX; CY = C.CurY;
    C.CurY = Y;
    C.DrawTile(Texture'ucgeneric.solidcolours.Black', width, 2, 0, 0, 2, 2);
    C.CurX = CX; C.CurY = CY;
}

// Taken from the canvas class. Changed to a different texture
final static function DrawVertical( Canvas C, float X, float height )
{
    local float cX,cY;

    CX = C.CurX; CY = C.CurY;
    C.CurX = X;
    C.DrawTile(Texture'ucgeneric.solidcolours.Black', 2, height, 0, 0, 2, 2);
    C.CurX = CX; C.CurY = CY;
}

defaultproperties
{
     RecordStateColor(0)=(R=255,A=255)
     RecordStateColor(1)=(G=255,R=255,A=255)
     RecordStateColor(2)=(B=60,G=60,R=60,A=255)
     bComplexString=True
     Lifetime=6
     DrawColor=(G=255,R=255)
     StackMode=SM_Down
     PosY=0.242000
     FontSize=-1
}
