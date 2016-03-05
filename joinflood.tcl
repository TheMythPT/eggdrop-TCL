# $Id: joinflood.tcl,v1.3 09/03/2015 12:45:27am GMT +12 (NZST) IRCSpeed Exp $
# SYNTAX (on PartyLine/DCC/CTCP/TELnet): 
# .chanset #channel flood-join lines:seconds
# example: .chanset #IRCSpeed flood-join 15:2 (15joins:2seconds)

## Set the Lock Modes 
# Bot will change channel mode to the modes you will specify below in case the bot will detect join flood
# To Disable Mode change set it to "" 
set joinlockmodes "mR"

## Set the time in seconds to Unlock Modes (needed even if textlockmodes are "")
# The Bot will Unlock the channel after the specified time you will set below
set unlocktime "45"

## Set the time in minutes to Unban (needed even if textlockmodes are "")
# The Bot will Unban the user after the specified time you will set below
set unbantime "60"

## Set here the Kick Reason you want for flooding user's.
set jfloodreason "\037J\037\002oin\002 \037F\037\002lood\002 \037D\037\002etected\002."

## Set the Global access flags that are exempt from this check (default: of)
set jfloodglobflags of

## Set the Channel access flags that are exempt from this check (default: ovf)
set jfloodchanflags ovf

# BAN Types are given below;
# 1 - *!*@some.domain.com 
# 2 - *!*@*.domain.com
# 3 - *!*ident@some.domain.com
# 4 - *!*ident@*.domain.com
# 5 - *!*ident*@some.domain.com
# 6 - *nick*!*@*.domain.com
# 7 - *nick*!*@some.domain.com
# 8 - nick!ident@some.domain.com
# 9 - nick!ident@*.host.com
set bantype 1

###########################
# CONFIGURATION ENDS HERE #
###########################

bind flud - join joinflood
proc joinflood {nick uhost hand type chan} {
  global joinlockmodes unbantime unlocktime jfloodreason jfloodglobflags jfloodchanflags
  if {![botisop $chan] && [matchattr [nick2hand $nick] $jfloodglobflags|$jfloodchanflags $chan]} {return}
  if {![isop $nick $chan] && ![isvoice $nick $chan]} {
   set banmask [make:banmask $uhost $nick]
    putquick "MODE $chan +$joinlockmodes"
    pushmode $chan +b $banmask
    putquick "KICK $chan $nick :$jfloodreason"
    utimer $unlocktime [list putquick "MODE $chan -$joinlockmodes"]
    timer $unbantime [list pushmode $chan -b $banmask]
   }
  return 0
}

proc make:banmask {uhost nick} {
 global bantype
  switch -- $bantype {
   1 { set banmask "*!*@[lindex [split $uhost @] 1]" }
   2 { set banmask "*!*@[lindex [split [maskhost $uhost] "@"] 1]" }
   3 { set banmask "*!*$uhost" }
   4 { set banmask "*!*[lindex [split [maskhost $uhost] "!"] 1]" }
   5 { set banmask "*!*[lindex [split $uhost "@"] 0]*@[lindex [split $uhost "@"] 1]" }
   6 { set banmask "*$nick*!*@[lindex [split [maskhost $uhost] "@"] 1]" }
   7 { set banmask "*$nick*!*@[lindex [split $uhost "@"] 1]" }
   8 { set banmask "$nick![lindex [split $uhost "@"] 0]@[lindex [split $uhost @] 1]" }
   9 { set banmask "$nick![lindex [split $uhost "@"] 0]@[lindex [split [maskhost $uhost] "@"] 1]" }
   default { set banmask "*!*@[lindex [split $uhost @] 1]" }
   return $banmask
  }
}

putlog "Loaded: joinflood.tcl,v1.3 - istok @ IRCSpeed"
