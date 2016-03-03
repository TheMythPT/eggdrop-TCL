# $Id: textflood.tcl,v1.6 09/03/2015 12:37:19am GMT +12 (NZST) IRCSpeed Exp $
# SYNTAX (on PartyLine/DCC/CTCP/TELnet): 
# .chanset #channel flood-chan lines:seconds
# example: .chanset #IRCSpeed flood-chan 5:2 (5lines:2seconds)

## Set the Lock Modes 
# Bot will change channel mode to the modes you will specify below in case the bot will detect text flood
# To Disable Mode change set it to "" 
set textlockmodes "mR"

## Set the time in seconds to Unlock Modes (needed even if textlockmodes are "")
# The Bot will Unlock the channel after the specified time you will set below
set unlocktime "15"

## Set the time in minutes to Unban (needed even if textlockmodes are "")
# The Bot will Unban the user after the specified time you will set below
set unbantime "60"

## Set Kick Reason
# Default kick reason is already set, using control codes to make bold/underline text.
# Remove the \002 and \037 tags if you wish to remove control codes.
set kickmsg "\037T\037\002ext\002 \037F\037\002lood\002 \037D\037\002etected\002"

# Set global exempt flags (default: ovf)
set floodglobflags ovf

# Set channel exempt flags (default: ovf)
set floodchanflags ovf

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

bind flud - pub textflood
proc textflood {nick uhost hand type chan} {
  global textlockmodes unbantime unlocktime kickmsg
  global floodglobflags floodchanflags
  if {![botisop $chan] && [matchattr [nick2hand $nick] $floodglobflags|$floodchanflags $chan]} {return}
  if {![isop $nick $chan] && ![isvoice $nick $chan]} {
   set banmask [make:banmask $uhost $nick]
     putquick "MODE $chan +b$textlockmodes $banmask"
     putquick "KICK $chan $nick :$kickmsg"
     utimer $unlocktime [list putquick "MODE $chan -$textlockmodes"]
     timer $unbantime [list putquick "MODE $chan -b $banmask"]
   }
  return
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

putlog "Loaded: textflood.tcl - istok @ IRCSpeed"
