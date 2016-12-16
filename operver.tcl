# $Id: operVersion.tcl,v1.OH 17/12/2016 02:26:13am GMT +13 (NZ-DST) istok Exp $

# Set the global trigger you wish to use (default: !)
set operVerTrig "!"

# Set channel you wish to relay the version info to (default: #services)
set operVerReply "#services"

### ----- NO NEED TO EDIT ----- ###
set operVershion "v1.OH"

proc getOperVer {} {
  global operVerTrig
  return $operVerTrig
}

bind raw - NOTICE operVersion:proc
bind ctcr - VERSION operVersion:reply

proc operVersion:proc {from keyword text} {
   global temp
    if {[string match -nocase "*Client connecting on*" $text]} {
     set operVertemp(who) [lindex [split $text] 9]
     if {$operVertemp(who) == ""} {putquick "PRIVMSG $chan :\037ERROR\037: Incorrect Parameters. \037SYNTAX\037: [getOperVer]version <nickname>"; return}
     putquick "PRIVMSG $operVertemp(who) :\001VERSION\001"
     return 0
   }

   if {[string match -nocase "*Client connecting at*" $text]} {
    set operVertemp(who) [lindex [split $text] 8]
    if {$operVertemp(who) == ""} {putquick "PRIVMSG $chan :\037ERROR\037: Incorrect Parameters. \037SYNTAX\037: [getOperVer]version <nickname>"; return}
    putquick "PRIVMSG $operVertemp(who) :\001VERSION\001"
    return 0
  }
}

proc operVersion:reply {nick uhost hand dest key vers} {
   global operVertemp operVerReply
   foreach operVerline $vers {
   putserv "PRIVMSG $operVerReply :$operVertemp(who) is using: [join [lrange [split $operVerline] 0 end]]"
  }
}

putlog ".:LOADED:. - Oper Version - .:$operVershion:."
