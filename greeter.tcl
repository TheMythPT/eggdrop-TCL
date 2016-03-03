# $Id: greeter.tcl,v1.1 18/01/2016 06:20:47am GMT +13 (NZDST) IRCSpeed Exp $

# This script is a simple onjoin greeter or channel message sender, posting whatever you wish to new people who join your channel(s). 
# It can be enabled/disabled per channel and so can the greetings/messages.

# To enable this script, type: !greets on
# To disable the script, type: !greets off

# Feel free to edit this setting. Change the ! to any character you would like as a trigger.
set mygreettrig "!"

# Set here what flags you wish to allow to enable/disable this script. (change them to "-" for anyone)
set greetglobflags "ovf"
set greetchanflags "ovf"

# Set here the greetings you wish to send each user that joins.
set mygreetmsgs {
  "Hi, how are you?"
  "Hi $nick!"
  "Hello $nick, welcome to $chan"
  "Hi [$nick], you have to pay 20$ to enter here :P"
}

### DONT EDIT BELOW ###
proc greetTrig {} {
  global mygreettrig
  return $mygreettrig
}

setudef flag autogreetings
 
bind join - * greet:msg
bind pub - ${mygreettrig}greets greet:pub

proc greet:msg {nick host hand chan} {
  global mygreetmsgs
  if {[validuser [nick2hand $nick]] && ![channel get $chan autogreetings]} {return}
  set greetmsg [lindex $mygreetmsgs [rand [llength $mygreetmsgs]]]
  set greetmsg [subst -nocommands $greetmsg]
   putserv "NOTICE $nick :$greetmsg"
   return 0
}

proc greet:pub {nick uhost hand chan arg} {
  global greetglobflags greetchanflags
  if {[matchattr [nick2hand $nick] $greetglobflags|$greetchanflags $chan]} {
    if {[lindex [split $arg] 0] == ""} {putquick "PRIVMSG $chan :\037ERROR\037: Incorrect Parameters. \037SYNTAX\037: [greetTrig]greets on|off"; return}

    if {[lindex [split $arg] 0] == "on"} {
      if {[channel get $chan autogreetings]} {putquick "PRIVMSG $chan :\037ERROR\037: This setting is already enabled."; return}
      channel set $chan +autogreetings
      puthelp "PRIVMSG $chan :Enabled Onjoin Greeter for $chan"
      savechannels
      return 0
    }

    if {[lindex [split $arg] 0] == "off"} {
      if {![channel get $chan autogreetings]} {putquick "PRIVMSG $chan :\037ERROR\037: This setting is already disabled."; return}
      channel set $chan -autogreetings
      puthelp "PRIVMSG $chan :Disabled Onjoin Greeter for $chan"
      savechannels
      return 0
    }
  }
}

putlog ".:greeter.tcl,v1.1:. Loaded! - istok @ IRCSpeed"

