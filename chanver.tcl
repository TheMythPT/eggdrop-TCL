# $Id: channelVersion.tcl,v1.OH 17/12/2016 02:25:40pm GMT +13 (NZ-DST) istok Exp $

# Set the global trigger you wish to use (default: !)
set chanVerTrig "!"

# Set channel you wish to relay the version info to (default: #versionReply)
set chanVerReply "#versionReply"

# Set the flags needed to trigger version command
set chanVerFlags o|m

### ----- NO NEED TO EDIT ----- ###
set chanVershion "v1.OH"

proc getChanVer {} {
  global chanVerTrig
  return $chanVerTrig
}

bind pub - ${chanVerTrig}version chanVersion:proc
bind ctcr - VERSION chanVersion:reply

proc chanVersion:proc {nick uhost hand chan arg} {
   global chanVerFlags temp 
   if {![matchattr [nick2hand $nick] $chanVerFlags $chan]} {return}
   set chanVertemp(who) [lindex [split $arg] 0]
   if {$chanVertemp(who) == ""} {putquick "PRIVMSG $chan :\037ERROR\037: Incorrect Parameters. \037SYNTAX\037: [getChanVer]version <nickname>"; return}
   putquick "PRIVMSG $chanVertemp(who) :\001VERSION\001"
}

proc chanVersion:reply {nick uhost hand dest key vers} {
   global chanVertemp chanVerReply
   foreach chanVerline $vers {
   putserv "PRIVMSG $chanVerReply :$chanVertemp(who) is using: [join [lrange [split $chanVerline] 0 end]]"
  }
}

putlog ".:LOADED:. - Public Version .:$chanVershion:."
