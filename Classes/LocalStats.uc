///////////////////////////////////////////////////////////////////////////////
// filename:    LocalStats.uc
// version:     102
// author:      Michiel 'El Muerte' Hendriks <elmuerte@drunksnipers.com>
// purpose:     enable local stats logging, and still make worldstats logging 
//              available
///////////////////////////////////////////////////////////////////////////////

class LocalStats extends GameStats config;

const VERSION = "102";

var string logname;
var GameStats OldGameStats;
var globalconfig bool bUseRemote;
var RemoteStats uplink;

function NewInit()
{
  Level.Game.bLoggingGame = true;
  Level.Game.bEnableStatLogging = true;
  log("[~] Starting LocalStats version "$VERSION);
  if (Level.Game.GameStats != None) OldGameStats = Level.Game.GameStats;
  Level.Game.GameStats = Self;
  if (!bUseRemote)
  {
    logname = "LocalStats_"$GetServerPort()$"_"$Level.Year$"_"$Level.Month$"_"$Level.Day$"_"$Level.Hour$"_"$Level.Minute$"_"$Level.Second;
	  TempLog = spawn(class 'FileLog');
  	if (TempLog!=None)
	  {
		  TempLog.OpenLog(logname);
  		log("[~] Output Game stats to: "$logname$".txt");
	  }
  	else
	  {
		  log("[E] Could not spawn Temporary Stats log");
  		Destroy();
	  }
  }
  else {
  	log("[~] Spawned for remote logging");
    uplink = spawn(class'RemoteStats');
    uplink.Init();
  }
  log("[~] Michiel 'El Muerte' Hendriks - elmuerte@drunksnipers.com");
  log("[~] The Drunk Snipers - http://www.drunksnipers.com");
}

function Init()
{
  // don't do anything
}

// Return the server's port number.
function string GetServerPort()
{
    local string S;
    local int i;

    // Figure out the server's port.
    S = Level.GetAddressURL();
    i = InStr( S, ":" );
    assert(i>=0);
    return Mid(S,i+1);
}

function Logf(string LogString)
{
	Logf2(LogString);
  if (OldGameStats!=None) OldGameStats.Logf(LogString);
} 

function Logf2(string LogString)
{
  if (uplink == None)
  {
    if (TempLog!=None) TempLog.Logf(LogString);
  }
  else {
  	uplink.RemoteLogf(LogString);
  }
}

// Connect Events get fired every time a player connects to a server
function ConnectEvent(PlayerReplicationInfo Who)
{
	local string out;
	if ( (Who.bBot && !bShowBots) || Who.bOnlySpectator )			// Spectators should never show up in stats!
		return;

  // C 0 PlayerName
	out = ""$Header()$"C"$Chr(9)$Controller(Who.Owner).PlayerNum$Chr(9)$Who.PlayerName;

	Logf2(out);
  if (OldGameStats!=None) OldGameStats.ConnectEvent(Who);
}

// has to be called before the game starts
event PreBeginPlay()
{
	Super.PreBeginPlay();
  if (uplink == None)
  {
  	NewInit();
  }
}

defaultproperties
{
  bUseRemote=false;
}