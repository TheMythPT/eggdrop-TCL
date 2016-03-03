# Restricted TCL - istok @ IRCSpeed
# $Id: restricted.tcl,v1 14/08/2010 02:37:42am GMT +12 (NZST) IRCSpeed Exp $

# RECOMMENDED
# Please add services to your bot, if you haven't already. (via dcc)
# SYNTAX: .+user serv *!*@services.network.etc
# SYNTAX: .chattr serv +f
# and possibly add a few extra masks...
# SYNTAX: .+host serv nickserv!*@*
# SYNTAX: .+host serv chanserv!*@*

# COMMANDS
# --------
# !restricted on|off <- public command
# /msg botnick restricted #channel on|off <- private command

# Set Global trigger here.
set restricttrig "!"

# Set Global Triggering flags here (default +o (Global Operator))
set restricttrigglobflags o

# Set Global Triggering flags here (default +n (Channel Owner))
set restricttrigchanflags n

# Set Global Exempt flags here (default +of (Global Operator, Friend, and above))
set restrictglobflags of

# Set Channel Exempt flags here (default +ovfb (Channel Operator, Voice, Friend, Bot, and above))
set restrictchanflags ovfb

# Set the banmask to use in banning the IPs  
# Default banmask is set to 1
# 1 - *!*@some.domain.com
# 2 - *!*@*.domain.com
# 3 - *!*ident@some.domain.com
# 4 - *!*ident@*.domain.com
# 5 - *!*ident*@some.domain.com
# 6 - *nick*!*@*.domain.com
# 7 - *nick*!*@some.domain.com
# 8 - nick!ident@some.domain.com
# 9 - nick!ident@*.host.com
# 10 - *!*ident*@*
set bantype 1

# ---------- No need to edit anything else *YAY* ----------
bind pub - ${restricttrig}restricted restrict:pub
bind msg - restricted restrict:msg
bind join - * restrict:join

proc makeRestrictTrig {} {
  global restricttrig
  return $restricttrig
}

setudef flag restricted

proc restrict:pub {nick uhost hand chan arg} {
  global restricttrigglobflags restricttrigchanflags
  if {[matchattr [nick2hand $nick] $restricttrigglobflags|$restricttrigchanflags $chan]} {
    if {[lindex [split $arg] 0] == ""} {putquick "PRIVMSG $chan :ERROR: Incorrect Parameters. SYNTAX: [makeRestrictTrig]restricted on|off"; return}

    if {[lindex [split $arg] 0] == "on"} {
      if {[channel get $chan restricted]} {putquick "PRIVMSG $chan :ERROR: This setting is already enabled."; return}
      channel set $chan +restricted
      puthelp "PRIVMSG $chan :Enabled Restriction of Users for $chan"
      restrict:chan $chan
      return 0
    }

    if {[lindex [split $arg] 0] == "off"} {
      if {![channel get $chan restricted]} {putquick "PRIVMSG $chan :ERROR: This setting is already disabled."; return}
      channel set $chan -restricted
      puthelp "PRIVMSG $chan :Disabled Restriction of Users for $chan"
      return 0
    }
  }
}

proc restrict:msg {nick uhost hand arg} {
  global botnick restricttrigglobflags restricttrigchanflags
  set chan [strlwr [lindex $arg 0]]
  if {[matchattr [nick2hand $nick] $restricttrigglobflags|$restricttrigchanflags $chan]} {
    if {[lindex [split $arg] 0] == ""} {putquick "NOTICE $nick :\037ERROR\037: Incorrect Parameters. \037SYNTAX\037: /msg $botnick restricted #channel on|off"; return}
    if {[lindex [split $arg] 1] == ""} {putquick "NOTICE $nick :\037ERROR\037: Incorrect Parameters. \037SYNTAX\037: /msg $botnick restricted $chan on|off"; return}

    if {[lindex [split $arg] 1] == "on"} {
      if {[channel get $chan restricted]} {putquick "NOTICE $nick :\037ERROR\037: This setting is already enabled."; return}
      channel set $chan +restricted
      putquick "NOTICE $nick :Enabled Restriction of Users for $chan"
      restrict:chan $chan
      return 0
    }

    if {[lindex [split $arg] 1] == "off"} {
      if {![channel get $chan restricted]} {putquick "NOTICE $nick :\037ERROR\037: This setting is already disabled."; return}
      channel set $chan -restricted
      putquick "NOTICE $nick :Disabled Restriction of Users for $chan"
      return 0
    }
  }
}

proc restrict:chan {chan} {
  global restrictglobflags restrictchanflags
  foreach nick [chanlist $chan] {
    if {![isbotnick $nick] && ![matchattr [nick2hand $nick] $restrictglobflags|$restrictchanflags $chan] && [channel get $chan restricted] && [onchan $nick $chan]} {
      set uhost [getchanhost $nick $chan]
      set banmask [restrict:mask $uhost $nick]
      pushmode $chan +b $banmask
      putquick "KICK $chan $nick :This Channel has been set \002Restricted\002 - You are now Unwelcome."
    }
  }
  flushmode $chan
}

proc restrict:join {nick uhost hand chan} {
  global restrictglobflags restrictchanflags
  if {![isbotnick $nick] && ![matchattr [nick2hand $nick] $restrictglobflags|$restrictchanflags $chan] && [channel get $chan restricted] && [onchan $nick $chan]} {
    set banmask [restrict:mask $uhost $nick]
    putquick "MODE $chan +b $banmask"
    putquick "KICK $chan $nick :This is a \002Restricted\002 Channel."
  }
}

proc restrict:mask {uhost nick} {
  global bantype
  switch -- $bantype {
    1 { set mask "*!*@[lindex [split $uhost @] 1]" }
    2 { set mask "*!*@[lindex [split [maskhost $uhost] "@"] 1]" }
    3 { set mask "*!*$uhost" }
    4 { set mask "*!*[lindex [split [maskhost $uhost] "!"] 1]" }
    5 { set mask "*!*[lindex [split $uhost "@"] 0]*@[lindex [split $uhost "@"] 1]" }
    6 { set mask "*$nick*!*@[lindex [split [maskhost $uhost] "@"] 1]" }
    7 { set mask "*$nick*!*@[lindex [split $uhost "@"] 1]" }
    8 { set mask "$nick![lindex [split $uhost "@"] 0]@[lindex [split $uhost @] 1]" }
    9 { set mask "$nick![lindex [split $uhost "@"] 0]@[lindex [split [maskhost $uhost] "@"] 1]" }
    10 { set mask "*!*[lindex [split $uhost "@"] 0]*@*" }
    default { set mask "*!*@[lindex [split $uhost @] 1]" }
    return $mask
  }
}

putlog ".:LOADED:. Restricted.TCL - istok @ IRCSpeed"
