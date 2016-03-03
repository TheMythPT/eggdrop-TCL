# $Id: services.tcl,v1.1 04/03/2016 03:51:32am GMT +13 (NZDST) IRCSpeed Exp $

# Example of commands:
# !service nickserv set noop on|off
# !service chanserv set #channel <options> <additional argument>
# !service memoserv del all

# Set the global trigger. (default: !)
set myservtrigger "!"

# This script is risky to run. Therefore, ONLY Global Bot Master's have default flag m
set serviceflag m

# Feel free to add/delete your own services.* names, as this script could potentially be used on any network.
# Set your networks NickServ
set nickservice "nickserv@services.ircspeed.org"

# Set your networks ChanServ
set chanservice "chanserv@services.ircspeed.org"

# Set your networks MemoServ (or leave "" to not use this)
set memoservice "memoserv@services.ircspeed.org"

# Set your networks HostServ (or leave "" to not use this)
set hostservice "hostserv@services.ircspeed.org"

# ---------- CODE BEGINS ----------
proc getServiceTrig {} {
  global myservtrigger
  return $myservtrigger
}

bind pub - ${myservtrigger}service serv:pub
proc serv:pub {nick uhost hand chan arg} {
  global serviceflag nickservice chanservice memoservice hostservice
  if {[matchattr [nick2hand $nick] $serviceflag]} {
  if {[lindex [split $arg] 0] == ""} {putquick "PRIVMSG $chan :\037ERROR\037: Incorrect Parameters. \037SYNTAX\037: [getServiceTrig]service nickserv|chanserv|memoserv|hostserv <command arguments>"; return}

    if {[lindex $arg 0] == "nickserv"} {
      set nickservcmd [join [lrange [split $arg] 1 end]]
      putquick "PRIVMSG $nickservice :$nickservcmd"
      putserv "NOTICE $nick :Sent: \037$nickservcmd\037 to NickServ"
      return 0
    }

    if {[lindex $arg 0] == "chanserv"} {
      set chanservcmd [join [lrange [split $arg] 1 end]]
      putquick "PRIVMSG $chanservice :$chanservcmd"
      putserv "NOTICE $nick :Sent: \037$chanservcmd\037 to ChanServ"
      return 0
    }

    if {[lindex $arg 0] == "memoserv"} {
      set memoservcmd [join [lrange [split $arg] 1 end]]
      putquick "PRIVMSG $memoservice :$memoservcmd"
      putserv "NOTICE $nick :Sent: \037$memoservcmd\037 to MemoServ"
      return 0
    }

    if {[lindex $arg 0] == "hostserv"} {
      set hostservcmd [join [lrange [split $arg] 1 end]]
      putquick "PRIVMSG $hostservice :$hostservcmd"
      putserv "NOTICE $nick :Sent: \037$hostservcmd\037 to HostServ"
      return 0
    }
  }
}

putlog ".:Loaded:. services.tcl,v1.1 - istok @ IRCSpeed"

