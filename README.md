# UT2003-LocalStats

LocalStats will create log files which can be converted to statistics just like Epic's ut2003stats.epicgames.com
LocalStats is a server actor so it will not show up in the mutator list or requires client downloads. Also with LocalStats you can still use the global stats.
LocalStats can also send the log entries to a remote host via a TCP connection.

Fixed a stupid mistake in 104, chat logging is now 100% compatible with the LocalLog format.

Note: version 105 had a bug in the year notation of the filename, this has been fixed in 106. So make sure you change your filename format again if you changed it before

# Installation

Copy the LocalStats.u file to the UT2003 System directory. Then edit you UT2003 Server Configuration file (UT2003.ini) and add the following line:

```
    [Engine.GameEngine]
    ServerActors=LocalStats.LocalStats
```

# Configurations

Since version 103 LocalStats supports some more configuration options, in your Server Configuration (UT2003.ini) file you can set the following variables:

```
  [LocalStats.LocalStats]
  bUseRemote=false
  bLogChat=false
  sLogDir=""
  bFixEmptyLog=false
  bEndGameFix=false
```

### bUseRemote
This will controll the remote logging
### bLogChat
this will enable logging of server chats
### sLogDir
Here you can specify a subdirectory (relative to the System directory) where to place the log files. It's important to include the trailing slash Note: from version 2222 and up this no longer works
### bFixEmptyLog
This will fix empty logfiles on a server shutdown. But with this enabled you will get extra lines in the server log for every stats line
### bEndGameFix
When this is enabled localstats will remain logging the chat when the game has ended. This can only be used with the chat logging enabled. Note: this might not work with some stats log processors.

To set up logging to a remote host you have to add the following lines to your server configurations:

```
    [LocalStats.LocalStats]
    bUseRemote=true

    [LocalStats.RemoteStats]
    sHostname=host where to log to
    iPort=tcp port to connect to
```

When you launch UT2003 it will open a TCP connection to that host and port and it will start sending the log entries as described below. You have to program the receiving appplication yourself, also no authentication is used at the moment.

# Usage
LocalStats will generate a seperate log file for every game, the file will be saved in the System directory with the following format:

```
    LocalStats_<GamePort>_<Year>_<Month>_<Day>_<Hour>_<Minute>_<Second>.txt
```

But this can be changed by editing the config setting sFileFormat (since version 105)
You can use the following replacements:

   - %P server Port
   - %Y current Year (4 digits since 106)
   - %M current Month
   - %Y current Day
   - %H current Hour
   - %I current mInute
   - %S current Second
   - %N server Name 

Not all characters are supported in the filename, for example '.', these will be translated to an underscore '_'

The data in the file will have the following format, fields are delimited by tabs (tabs in fields are replaced by underscores):

```
<timestamp> <event> <data>
```

`<timestamp>` is the number of seconds since the level has been loaded
`<event>` is a tag that defines what event occured, it will be one of the
following:

```
    NG New Game
    SI Server Info
    SG The game has started
    EG The game has ended
    C A player has connected
    D A player has disconnected
    S Score event
    T Team score event
    K Kill
    TK Team kille
    P Special player event, like: first blood, killing spree, type kill, multikill
    G Special game event: flag drop, name changes, etc.
    V Chat (3rd party addition)
    TV Team chat (3rd party addition) 
```

`<data>` This is depended on the event type:

   - NG: `<full time> <timezone> <map name> <map title> <map author> <game type> <game name>`
   - SI: `<server name> <timezone> <admin name> <admin email> <other server info>`
   - SG: nothing but the tag
   - EG: `<reason>`
   - C: `<player number> <player name | player stat ID>`
    note: this line will appear twice per player if worldstat logging is enabled, first with the player name then with the stat ID
   - D: `<player number>`
   - S: `<player number> <points> <description>`
   - T: `<team> <points> <description>`
   - K or TK: `<killer number> <damage type> <victim number> <vicitim weapon>`
   - S: `<player number> <description>`
    description is usualy something like: first_blood, spree_#, type_kill, multikill_#
   - G: `<event description> <player number> <description>`
    the event description is often something like:
    flag_dropped, flag_taken, flag_returned, flag_returned_timeout, flag_pickup, flag_captured, NameChange, TeamChange, bomb_droppen, bomb_taken, bomb_pickup, bomb_returned_timeout
    description is often used for the player number or team number, depends on the game event
   - V: `<player number> <message>`
   - TV: `<player number> <message>`

# Stats analysers
As I said I would not deliver any programs to receive and/or analyse the log files, but that doesn't mean nobody else will, here are a couple of programs that can do it for you.

[Unreal Tournament 2003 Stats Database](http://www.utstatsdb.com/)
The UT2003 Stats Database is a program for parsing logs from the game Unreal Tournament 2003 and storing them in a database, along with a web based stats viewer. The system is written in PHP and currently works with MySQL database, though other databases will be supported in the near future.
