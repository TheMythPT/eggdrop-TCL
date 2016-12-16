# $Id: publicVersion.tcl,v1.OH 17/12/2016 02:27:38am GMT +13 (NZ-DST) istok Exp $

# Set the global trigger you wish to use (default: !)
set pubVerTrig "!"

# Set the flags needed to trigger version command
set pubVerFlags o|m

### ----- NO NEED TO EDIT ----- ###
set pubVershion "v1.OH"

proc getPubVer {} {
  global pubVerTrig
  return $pubVerTrig
}

bind pub - ${pubVerTrig}version pubVersion:proc
bind ctcr - VERSION pubVersion:reply

proc pubVersion:proc {nick uhost hand chan arg} {
   global pubVerFlags pubVertemp 
   if {![matchattr [nick2hand $nick] $pubVerFlags $chan]} {return}
   set pubVertemp(who) [lindex [split $arg] 0]
   if {$pubVertemp(who) == ""} {putquick "PRIVMSG $chan :ERROR: Incorrect Parameters. SYNTAX: [getPubVer]version <nickname>"; return}
   set pubVertemp(chan) $chan
   putquick "PRIVMSG $pubVertemp(who) :\001VERSION\001"
}

proc pubVersion:reply {nick uhost hand dest key vers} {
   global pubVertemp
   foreach pubVerline $vers {
   putserv "PRIVMSG $pubVertemp(chan) :$pubVertemp(who) is using: [join [lrange [split $pubVerline] 0 end]]"
  }
}

putlog ".:LOADED:. - Public Version .:$pubVershion:."
