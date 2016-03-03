# $Id: noctcp.tcl,v1.2 04/03/2016 04:45:10pm GMT +13 (NZDST) IRCSpeed Exp $

# This script stops people or bots/drones from doing /ctcp #yourchannel version/finger/ping/time requests.

# Commands:
# ---------
# Public: !noctcp on/off
# Message: /msg botnick noctcp #channel on|off

# Alternatively: You can also bypass this script on IRCSpeed by using /mode #yourchannel +C
# -----------------------------------------------------------------------------------------

# Set the global trigger you want to use (default: !)
set noctcptrig "!"

# Set global access flags to turn on|off command. (default: o)
set noctcpglobflags o

# Set channel access flags to turn on|off command. (default: m)
set noctcpchanflags m

################ End Settings ################

setudef flag noctcp

proc noctcpTrigger {} {
  global noctcptrig
  return $noctcptrig
}

bind pub - ${noctcptrig}noctcp noctcp:pub
bind msg - noctcp noctcp:msg
bind ctcp - * chan:ctcp

proc noctcp:pub {nick uhost hand chan text} {
  global noctcpglobflags noctcpchanflags
  if {![matchattr [nick2hand $nick] $noctcpglobflags|$noctcpchanflags $chan]} {return}
  if {[lindex [split $text] 0] == ""} {putquick "PRIVMSG $chan :\037ERROR\037: Incorrect Parameters. \037SYNTAX\037: [noctcpTrigger]noctcp on|off"; return}


  if {[lindex [split $text] 0] == "on"} {
    if {[channel get $chan noctcp]} {putquick "PRIVMSG $chan :\037ERROR\037: This setting is already enabled."; return}
    channel set $chan +noctcp
    puthelp "PRIVMSG $chan :Enabled Anti Channel CTCP for $chan"
    return 0
  }

  if {[lindex [split $text] 0] == "off"} {
    if {![channel get $chan noctcp]} {putquick "PRIVMSG $chan :\037ERROR\037: This setting is already disabled."; return}
    channel set $chan -noctcp
    puthelp "PRIVMSG $chan :Disabled Anti Channel CTCP for $chan"
    return 0
  }
}

proc noctcp:msg {nick uhost hand arg} {
  global botnick noctcpglobflags noctcpchanflags
  set chan [strlwr [lindex $arg 0]]
  if {![matchattr [nick2hand $nick] $noctcpglobflags|$noctcpchanflags $chan]} {return}
  if {[lindex [split $arg] 0] == ""} {putquick "NOTICE $nick :\037ERROR\037: Incorrect Parameters. \037SYNTAX\037: /msg $botnick noctcp #channel on|off"; return}
  if {[lindex [split $arg] 1] == ""} {putquick "NOTICE $nick :\037ERROR\037: Incorrect Parameters. \037SYNTAX\037: /msg $botnick noctcp $chan on|off"; return}

  if {[lindex [split $arg] 1] == "on"} {
    if {[channel get $chan noctcp]} {putquick "NOTICE $nick :\037ERROR\037: This setting is already enabled."; return}
    channel set $chan +noctcp
    putquick "NOTICE $nick :Enabled Anti Channel CTCP for $chan"
    return 0
  }

  if {[lindex [split $arg] 1] == "off"} {
    if {![channel get $chan noctcp]} {putquick "NOTICE $nick :\037ERROR\037: This setting is already disabled."; return}
    channel set $chan -noctcp
    putquick "NOTICE $nick :Disabled Anti Channel CTCP for $chan"
    return 0
  }
}

proc chan:ctcp {nick uhost hand dest key text} {
  global botnick
  if {![string match "*#*" $dest]} {return}
  set chan $dest
  if {[channel get $chan noctcp]} {
    if {[botisop $chan] && [onchan $nick $chan] && ![isop $nick $chan] && ![isvoice $nick $chan] && ![validuser [nick2hand $nick]]} {
      newignore *!*@[lindex [split $uhost @] 1] $botnick "NOCTCP - Autoignore on: $nick (5mins)" 5
      putquick "MODE $chan +b *!*@[lindex [split $uhost @] 1]"
      putquick "KICK $chan $nick :(\002NOCTCP\002) - You are \002NOT\002 Permitted to CTCP $chan"
      return 0
    }
  }
}

putlog "Loaded: NOCTCP Module. - istok @ IRCSpeed"
