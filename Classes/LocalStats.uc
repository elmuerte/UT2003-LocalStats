///////////////////////////////////////////////////////////////////////////////
// filename:    LocalStats.uc
// version:     107
// author:      Michiel 'El Muerte' Hendriks <elmuerte@drunksnipers.com>
// purpose:     enable local stats logging, and still make worldstats logging 
//              available
///////////////////////////////////////////////////////////////////////////////

class LocalStats extends GameStats config;

const VERSION = "107";

var string logname;
var GameStats OldGameStats;
var RemoteStats uplink;
var StatsChatLog ChatLog;

var globalconfig bool bUseRemote;
var globalconfig bool bLogChat;
var globalconfig string sLogDir;
var globalconfig bool bFixEmptyLog;
var globalconfig string sFileFormat;
var globalconfig class<RemoteStats> RemoteStatsClass;
var globalconfig bool bEndGameFix;

function NewInit()
{
  Level.Game.bLoggingGame = true;
  Level.Game.bEnableStatLogging = true;
  log("[~] Starting LocalStats version "$VERSION, 'LocalStats');
  if (Level.Game.GameStats != None) 
  {
    OldGameStats = Level.Game.GameStats;
    log("[~] Found WorldStats actor"@OldGameStats, 'LocalStats');
  }
  Level.Game.GameStats = Self;
  if (!bUseRemote)
  {
    logname = LogFilename();
	  TempLog = spawn(class 'FileLog');
  	if (TempLog!=None)
	  {
		  TempLog.OpenLog(logname);
  		log("[~] Output Game stats to: "$logname$".log", 'LocalStats');
	  }
  	else
	  {
		  log("[E] Could not spawn Temporary Stats log", 'LocalStats');
  		Destroy();
      return;
	  }
  }
  else {
  	log("[~] Spawned for remote logging", 'LocalStats');
    uplink = spawn(RemoteStatsClass);
    uplink.Init();
  }
  if (bLogChat)
  {
    ChatLog = spawn(class'StatsChatLog');
    ChatLog.statslog = Self;
    ChatLog.Init();
    if (bEndGameFix)
    {
      ChatLog.bUseRemote = bUseRemote;
      ChatLog.bFixEmptyLog = bFixEmptyLog;
      ChatLog.bShowBots = bShowBots;
      if (!bUseRemote) ChatLog.logname = logname;        
      else ChatLog.uplink = uplink;      
    }
  }
  log("[~] Michiel 'El Muerte' Hendriks - elmuerte@drunksnipers.com", 'LocalStats');
  log("[~] The Drunk Snipers - http://www.drunksnipers.com", 'LocalStats');
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

function Shutdown()
{
	super.Shutdown();
  if (bLogChat && bEndGameFix) ChatLog.EngGameLogging();
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
    if (TempLog!=None) 
    {
      TempLog.Logf(LogString);
      if (bFixEmptyLog)
      {
        TempLog.CloseLog();
        TempLog.OpenLog(logname);
      }
    }
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
  //if (OldGameStats!=None) OldGameStats.ConnectEvent(Who);
  // well add a second Connect line
  // C playerid stats_idhash stats_nick stats_passhash
  Super.ConnectEvent(Who);
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

function ChatEvent(coerce string type, PlayerReplicationInfo Who, coerce string Message)
{
  local string out;
	if ( (Who.bBot && !bShowBots) || Who.bOnlySpectator ) return;
	out = ""$Header()$type$Chr(9)$Controller(Who.Owner).PlayerNum$Chr(9)$Message;
	Logf2(out);
}

function string LogFilename()
{
  local string result;
  result = sFileFormat;
  ReplaceText(result, "%P", GetServerPort());
  ReplaceText(result, "%N", Level.Game.GameReplicationInfo.ServerName);
  ReplaceText(result, "%Y", Right("0000"$string(Level.Year), 4));
  ReplaceText(result, "%M", Right("00"$string(Level.Month), 2));
  ReplaceText(result, "%D", Right("00"$string(Level.Day), 2));
  ReplaceText(result, "%H", Right("00"$string(Level.Hour), 2));
  ReplaceText(result, "%I", Right("00"$string(Level.Minute), 2));
  ReplaceText(result, "%W", Right("0"$string(Level.DayOfWeek), 1));
  ReplaceText(result, "%S", Right("00"$string(Level.Second), 2));
  if (int(level.EngineVersion) > 2222)
  {
    if (sLogDir != "") Log("[E] sLogDir is no longer supported in UT2003 version 2222 and up", 'LocalStats');
    return result;
  }
  else return sLogDir$result;
}

defaultproperties
{
  bUseRemote=false
  bLogChat=false
  sLogDir=""
  bFixEmptyLog=false
  RemoteStatsClass=class'RemoteStats'
  sFileFormat="LocalStats_%P_%Y_%M_%D_%H_%I_%S"
  bEndGameFix=false
}