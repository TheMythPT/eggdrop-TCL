# $Id: bans.tcl,v1.2 04/03/2016 05:41:42am GMT +12 (NZST) IRCSpeed Exp $

# Commands:
# !bans <=- shows channel ban list.
# !globans <=- shows global ban list.
# !addban *!*@banmask.etc reasons-for-ban <=- adds a channel ban.
# !delban *!*@banmask.etc <=- removes a channel ban.
# !gban *!*@banmask.etc reasons-for-ban <=- adds a global ban.
# !delgban *!*@banmask.etc <=- removes a global ban.

# MSGCMD: /msg botnick bans <=- shows global ban list.
# MSGCMD: /msg botnick bans #channel <=- shows channel ban list.
###################################################################

# Set global command trigger (default: !)
set banstriga "!"

# Set global access flags to use these commands (default: o)
# This global access flag is able to use: !bans, !globans, !gban, !delgban, !addban, !delban
set banglobflags o

# Set channel access flags to use these commands (default: m)
# This channel access flag is only able to use: !bans, !addban, !delban (like akick, for SOP)
set banchanflags m

proc getBanTriga {} {
  global banstriga
  return $banstriga
}

bind pub - ${banstriga}bans chan:bans
proc chan:bans {nick uhost hand chan arg} {
  global banglobflags banchanflags
  if {[matchattr [nick2hand $nick] $banglobflags|$banchanflags $chan]} {
    putquick "PRIVMSG $chan :\002BANLIST\002 for $chan sent to $nick"
    putserv "NOTICE $nick :********* \002$chan BanList\002 **********"

    foreach botban [banlist $chan] {
      putserv "NOTICE $nick :\002BOTBAN\002: $botban"
    }
   putserv "NOTICE $nick :********** \002$chan BanList \037END\037\002 **********"
  }
}

bind pub - ${banstriga}globans glo:bans
proc glo:bans {nick uhost hand chan arg} {
  global banglobflags
  if {[matchattr [nick2hand $nick] $banglobflags]} {
    putquick "PRIVMSG $chan :\002GLOBAL BANLIST\002 sent to $nick"
    putquick "NOTICE $nick :********* \002Global BanList\002 **********"
    foreach globan [banlist] {
      putquick "NOTICE $nick :\002GLOBAN\002: $globan"
    }
    putquick "NOTICE $nick :********** \002Global BanList \037END\037\002 **********"
  }
}

bind msg - bans ban:list
proc ban:list {nick uhost hand arg} {
  global banglobflags banchanflags
  if {([lindex $arg 0] == "") && ([matchattr [nick2hand $nick] $banglobflags])} {
    putquick "NOTICE $nick :********** \002Global BanList\002 **********"
    foreach globban [banlist] {
      putquick "NOTICE $nick :\002GLOBBAN\002: $globban"
    }
    putquick "NOTICE $nick :********** \002Global BanList \037END\037\002 **********"
    } else {
    set chan [strlwr [lindex $arg 0]]
    if {([lindex [split $arg] 0] != "") && ([matchattr [nick2hand $nick] $banglobflags|$banchanflags $chan])} {
      putquick "NOTICE $nick :********** \002$chan BanList\002 **********"
      foreach chanban [banlist $chan] {
        putquick "NOTICE $nick :\002CHANBAN\002: $chanban"
      }
      putquick "NOTICE $nick :********** \002$chan BanList \037END\037\002 **********"
    }
  }
}

bind pub - ${banstriga}addban banint:pub
proc banint:pub {nick uhost hand chan arg} {
  global banglobflags banchanflags
  if {![matchattr [nick2hand $nick] $banglobflags|$banchanflags $chan]} {return}
  set banmask [lindex [split $arg] 0]
  if {$banmask == ""} {putquick "NOTICE $nick \037ERROR\037: Incorrect Parameters. \037SYNTAX\037: [getBanTriga]addban *!*@banmask.etc reason-for-ban"; return}
  if {[isban $banmask $chan]} {putquick "PRIVMSG $chan :\037ERROR\037: Banmask already exists."; return}
  set banreason [join [lrange [split $arg] 1 end]]
  if {$banreason == ""} {putquick "NOTICE $nick \037ERROR\037: Incorrect Parameters. \037SYNTAX\037: [getBanTriga]addban *!*@banmask.etc reason-for-ban"; return}
  putquick "MODE $chan +b $banmask"
  newchanban "$chan" "$banmask" "$nick" "$banreason" 0
  putquick "NOTICE $nick :Successfully Added Ban: $banmask for $chan"
  return 0
}

bind pub - ${banstriga}delban unbanint:pub
proc unbanint:pub {nick uhost hand chan arg} {
  global banglobflags banchanflags
  if {![matchattr [nick2hand $nick] $banglobflags|$banchanflags $chan]} {return}
  set unbanmask [lindex [split $arg] 0]
  if {$unbanmask == ""} {putquick "NOTICE $nick \037ERROR\037: Incorrect Parameters. \037SYNTAX\037: [getBanTriga]delban *!*@banmask.etc"; return}
  if {![isban $unbanmask $chan]} {putquick "PRIVMSG $chan :\037ERROR\037: Banmask not found."; return}
  killchanban $chan $unbanmask
  putquick "NOTICE $nick :Successfully Deleted Ban: $unbanmask for $chan"
  return 0
}

bind pub - ${banstriga}gban gban:pub
proc gban:pub {nick uhost hand chan arg} {
  global banglobflags
  if {![matchattr [nick2hand $nick] $banglobflags]} {return}
  set banmask [lindex [split $arg] 0]
  if {$banmask == ""} {putquick "NOTICE $nick \037ERROR\037: Incorrect Parameters. \037SYNTAX\037: [getBanTriga]gban *!*@banmask.etc reason-for-ban"; return}
  if {[isban $banmask]} {putquick "NOTICE $nick :\037ERROR\037: Banmask already exists."; return}
  set banreason [join [lrange [split $arg] 1 end]]
  if {$banreason == ""} {putquick "NOTICE $nick \037ERROR\037: Incorrect Parameters. \037SYNTAX\037: [getBanTriga]gban *!*@banmask.etc reason-for-ban"; return}
  newban $banmask $nick $banreason 0
  putquick "NOTICE $nick :Successfully Added Global Ban: $banmask for: [channels]"
  return 0
}

bind pub - ${banstriga}delgban unbanglob:pub
proc unbanglob:pub {nick uhost hand chan arg} {
  global banglobflags
  if {![matchattr [nick2hand $nick] $banglobflags]} {return}
  set unbanmask [lindex [split $arg] 0]
  if {$unbanmask == ""} {putquick "NOTICE $nick \037ERROR\037: Incorrect Parameters. \037SYNTAX\037: [getBanTriga]delgban *!*@banmask.etc"; return}
  if {![isban $unbanmask]} {putquick "NOTICE $nick :\037ERROR\037: Banmask not Found."; return}
  killban $unbanmask
  putquick "NOTICE $nick :Successfully Deleted Global Ban: $unbanmask for: [channels]"
  return 0
}

putlog "LOADED .:Bans.tcl:. - istok @ IRCSpeed"
