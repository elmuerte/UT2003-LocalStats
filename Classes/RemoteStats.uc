///////////////////////////////////////////////////////////////////////////////
// filename:    RemoteStats.uc
// version:     100
// author:      Michiel 'El Muerte' Hendriks <elmuerte@drunksnipers.com>
// purpose:     enable private stats logging on a remote server
///////////////////////////////////////////////////////////////////////////////

class RemoteStats extends TcpLink config;

const DEBUG = false;
const VERSION = "100";

var globalconfig string sHostname;
var globalconfig int iPort;
var bool bConnected;
var array< string > prebuffer;

function Init()
{
  log("[~] Starting RemoteStats version "$VERSION);
	Super.PreBeginPlay();
  bConnected = false;
	Resolve(sHostname);
}

function RemoteLogf(string LogString)
{
  if (!bConnected) {
    prebuffer.length = prebuffer.length+1;
    prebuffer[prebuffer.length-1] = LogString;
  }
  else {
  	if (prebuffer.length == 0) {
      SendText(LogString);  	
  	}
    else {
      // this should not happen, or should it
    	prebuffer.length = prebuffer.length+1;
      prebuffer[prebuffer.length-1] = LogString;
    }
  }
}

event Opened()
{
  local int i;
  local array< string > prebuffer2;
  if (DEBUG) log("[D] RemoteStats connection to "$sHostname$":"$iPort$" established");
  while (prebuffer.length > 0) {
    prebuffer2 = prebuffer;
    prebuffer.length = 0;
    for (i = 0; i < prebuffer2.length; i++) {
      SendText(prebuffer2[i]); 
    } 
  }
  bConnected = true;
}

event Closed()
{
  if (DEBUG) log("[D] RemoteStats connection to "$sHostname$":"$iPort$" closed");
}

event ReceivedLine( string Line )
{
  if (DEBUG) log("[D] RemoteStats read: "$Line);
}

event Resolved( IpAddr Addr )
{
  Addr.Port = iPort;
  if (DEBUG) log("[D] RemoteStats connecting to: "$sHostname$" ("$IpAddrToString(Addr)$")");
  BindPort();
  LinkMode = MODE_Line;
  ReceiveMode = RMODE_Event;
  Open(Addr);  
}

event ResolveFailed()
{
  log("[E] RemoteStats resolve failed, not logging");
}
