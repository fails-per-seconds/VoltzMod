//=============================================================================
// Copyright 2005-2010 Eliot Van Uytfanghe. All Rights Reserved.
//=============================================================================
class BTServer_HttpNotificator extends Object within MutBestTimes
    config(MutBestTimes);

const TrialMode = "TM";
const TrialMapName = "TMN";
const TrialMapTime = "TMT";
const TrialPlayerName = "TPN";
const TrialPlayerGUID = "TPG";
const WebBTimesUpdate = "Update";

const RSetCode = 1;
const RDelCode = 2;
const RMovCode = 3;

var() globalconfig string Host;
var() globalconfig string SecurityHash;
var() globalconfig bool bStripNameColors;

var protected HttpSock Socket;
var protected array<string> Params;

final function Free()
{
    Disconnect();
    Socket = none;
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

final function AddParam( coerce string Option, coerce string Value )
{
    local int i;

    i = Params.Length;
    Params.Length = i + 1;
    Params[i] = Option $ "=" $ Value;
}

function Send()
{
    local string URL;
    local int i;

    URL = Host;
    if( InStr( URL, "?" ) == -1 )
        URL $= "?";

    AddParam( "SH", SecurityHash );
    for( i = 0; i < Params.Length; ++ i )
    {
        URL $= Params[i];
        if( i != Params.Length - 1 )
            URL $= "&";
    }

    Socket.Get( URL );
    Params.Length = 0;

    FullLog( "HTTP:Sent" );
}

/** Notify the remote server to download the latest WebBTimes.html. */
function NotifyUpdate()
{
    AddParam( WebBTimesUpdate, "1" );
    Send();
}

/** Notify that a record was set/updated. */
function NotifyRecordSet( int mapIndex, int playerSlot, float newTime )
{
    SetCode( RSetCode );
    AddParam( TrialMode, CurMode.ModePrefix );                      // STR, GTR, RTR
    AddParam( TrialMapName, RDat.Rec[mapIndex].TMN );
    AddParam( TrialMapTime, newTime );                              // in float i.e. 61323.74
    //class'HttpUtil'.static.ReplaceChar( PDat.Player[playerSlot-1].PLNAME, "&", "&amp;");
    AddParam( TrialPlayerName, Eval( bStripNameColors, %PDat.Player[playerSlot-1].PLNAME, PDat.Player[playerSlot-1].PLNAME ) );
    AddParam( TrialPlayerGUID, PDat.Player[playerSlot-1].PLID );
    Send();
}

/** Notify that a record was completely deleted. Note:The record slot is actually re-created with empty data if it was deleted while the map was active. */
function NotifyRecordDeleted( int recSlot )
{
    SetCode( RDelCode );
    AddParam( TrialMapName, RDat.Rec[recSlot].TMN );
    Send();
}

/** Notify that a solo(not to be confused with all the records in a solo map!) record has been deleted. */
function NotifySoloRecordDeleted( int recSlot, int soloSlot )
{
    SetCode( RDelCode );
    AddParam( TrialMapName, RDat.Rec[recSlot].TMN );
    AddParam( TrialPlayerGUID, PDat.Player[RDat.Rec[recSlot].PSRL[soloSlot].PLs-1].PLID );
    Send();
}

/** Notify that the cached mapname was renamed by an admin. */
function NotifyRecordMoved( string oldName, string newName )
{
    SetCode( RMovCode );
    AddParam( "OldName", oldName );
    AddParam( "NewName", newName );
    Send();
}

final function SetCode( byte code )
{
    AddParam( "Code", code );
}

final function Connect()
{
    Socket = Spawn( class'HttpSock' );
    FullLog( "HTTP:Connected" );
}

final function Disconnect()
{
    if( Socket != none  )
    {
        Socket.Destroy();
        FullLog( "HTTP:Disconnected" );
    }
}

defaultproperties
{
}
