///////////////////////////////////////////////////////////////////////////////
// filename:    ChatLog.uc
// version:     100
// author:      Michiel 'El Muerte' Hendriks <elmuerte@drunksnipers.com>
// purpose:     log chatter
///////////////////////////////////////////////////////////////////////////////

class StatsChatLog extends BroadcastHandler;

var LocalStats statslog;
var BroadcastHandler oldHandler;

function Init()
{
  if (statslog == none)
  {
    log("[E] Error initialising StatsChatLog");
    Destroy();
    return;
  }
  oldHandler = Level.Game.BroadcastHandler;
  Level.Game.BroadcastHandler = Self;
  log("[~] Chat logging enabled");
}

function Broadcast( Actor Sender, coerce string Msg, optional name Type )
{
  if ((Controller(Sender) != none) && (statslog != none)) statslog.ChatEvent("VT", Controller(Sender).PlayerReplicationInfo, msg);
  if (oldHandler != none) oldHandler.Broadcast(Sender, Msg, Type);
}

function BroadcastTeam( Controller Sender, coerce string Msg, optional name Type )
{
  if (statslog != none) statslog.ChatEvent("VT", Sender.PlayerReplicationInfo, msg);
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