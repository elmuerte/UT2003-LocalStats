///////////////////////////////////////////////////////////////////////////////
// filename:    ChatLog.uc
// version:     101
// author:      Michiel 'El Muerte' Hendriks <elmuerte@drunksnipers.com>
// purpose:     log chatter
///////////////////////////////////////////////////////////////////////////////

class StatsChatLog extends BroadcastHandler;

var LocalStats statslog;
var BroadcastHandler oldHandler;

var bool bUseRemote, bFixEmptyLog, geLogging, bShowBots;
/** used to continue chat logging after gameend */
var string logname;
/** to work around the gameend chat logging */
var FileLog gelog;		
/** to work around the gameend chat logging */
var RemoteStats uplink;

function Init()
{
  if (statslog == none)
  {
    log("[E] Error initialising StatsChatLog", 'LocalStats');
    Destroy();
    return;
  }
  geLogging = false;
  oldHandler = Level.Game.BroadcastHandler;
  Level.Game.BroadcastHandler = Self;
  log("[~] Chat logging enabled", 'LocalStats');
}

function Broadcast( Actor Sender, coerce string Msg, optional name Type )
{
  if (Controller(Sender) != none) ChatEvent("V", Controller(Sender).PlayerReplicationInfo, msg);
  if (oldHandler != none) oldHandler.Broadcast(Sender, Msg, Type);
}

function BroadcastTeam( Controller Sender, coerce string Msg, optional name Type )
{
  ChatEvent("TV", Sender.PlayerReplicationInfo, msg);
  if (oldHandler != none) oldHandler.BroadcastTeam(Sender, Msg, Type);
}

// wrappers

function UpdateSentText()
{
	if (oldHandler != none) oldHandler.UpdateSentText();
}

function bool AllowsBroadcast( actor broadcaster, int Len )
{
	if (oldHandler != none) return oldHandler.AllowsBroadcast(broadcaster, len);
  return false;
}

function BroadcastText( PlayerReplicationInfo SenderPRI, PlayerController Receiver, coerce string Msg, optional name Type )
{
	if (oldHandler != none) oldHandler.BroadcastText(SenderPRI, Receiver, Msg, Type);
}

function BroadcastLocalized( Actor Sender, PlayerController Receiver, class<LocalMessage> Message, optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject )
{
	if (oldHandler != none) oldHandler.BroadcastLocalized( Sender, Receiver, Message, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject );
}

event AllowBroadcastLocalized( actor Sender, class<LocalMessage> Message, optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2, optional Object OptionalObject )
{
	if (oldHandler != none) oldHandler.AllowBroadcastLocalized( Sender, Message, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject );
}

// Functions to work around the EndGame loggign problem

function EngGameLogging()
{
  log("[~] Initializing post EndGame logging...", 'LocalStats');
  geLogging = true;
  if (!bUseRemote)
  {
    gelog = spawn(class 'FileLog');
  	if (gelog!=None)
	  {
		  gelog.OpenLog(logname);
  		log("[~] Output Game stats to: "$logname$".log", 'LocalStats');
      enable('Tick');
	  }
  	else
	  {
		  log("[E] Could not spawn Temporary Stats log", 'LocalStats');
  		Destroy();
      return;
	  }
  }  
}

function ChatEvent(coerce string type, PlayerReplicationInfo Who, coerce string Message)
{
  local string out;
  if (!geLogging) statslog.ChatEvent(type, Who, Message);
  else {
  	if ((Who.bBot && !bShowBots) || Who.bOnlySpectator ) return;
	  out = ""$Header()$type$Chr(9)$Controller(Who.Owner).PlayerNum$Chr(9)$Message;
  	Logf2(out);
  }
}

function Logf2(string LogString)
{
  if (uplink == None)
  {
    if (gelog!=None) 
    {
      gelog.Logf(LogString);
      if (bFixEmptyLog)
      {
        gelog.CloseLog();
        gelog.OpenLog(logname);
      }
    }
  }
  else {
  	uplink.RemoteLogf(LogString);
  }
}

function string TimeStamp()
{
	local string seconds;
	seconds = ""$Level.TimeSeconds;

	// Remove the centiseconds
	if( InStr(seconds,".") != -1 )
		seconds = Left( seconds, InStr(seconds,".") );

	return seconds;
}

function string Header()
{
	return ""$TimeStamp()$chr(9);
}

event Tick(float delta)
{
  if ((Level.NextURL != "") && (gelog != none))
  {
    gelog.Destroy();
    gelog = none;
  }
}