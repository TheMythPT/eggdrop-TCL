# $Id: partquit.tcl,v1.5.1 28/06/2016 6:14:12pm GMT +12 (NZST) IRCSpeed Exp $

# This script covers 3 factors.
# 1) quitcheck - monitors quits for abusive text, like autokills, excess floods, or spam
# 2) joinpart - monitors joins/parts to channel and will set ban if joins exceed parttime
# 3) joinquit - monitors joins/quits to channel and will set ban if quits exceed jointime

## SYNTAX:
# (these are available to Global OPs and Channel Master's and above)
# ---------
# !quitcheck on|off
# !joinpart on|off
# !joinquit on|off
# /msg yourbot quitcheck #channel on|off
# /msg yourbot joinpart #channel on|off
# /msg yourbot joinquit #channel on|off

# Set global trigger here
set trigger "!"

# Set time in sec for how long someone should have stayed joined, before they part.
set parttime "10"

# Set time in sec for how long someone should have stayed joined, before they quit.
set jointime "5"

# Set your quit match pattern below
set quitwords {
  "*excess flood*"
  "*k-line*"
  "*killed*"
  "*join #*"
  "*/server*"
}

# Set your exempt match pattern below
set exemptwords {
  "*dontbanme*"
  "*i live on IRCSpeed and all i got was this lousy k-line*"
}

# -----DONT EDIT BELOW-----
bind pub - ${trigger}quitcheck quitcheck:pub
bind pub - ${trigger}joinpart joinpart:pub
bind pub - ${trigger}joinquit joinquit:pub
bind msg - quitcheck quitcheck:msg
bind msg - joinpart joinpart:msg
bind msg - joinquit joinquit:msg
bind part - * join:part
bind sign - * join:quit
bind sign - * quit:check

setudef flag quitcheck
setudef flag joinpart
setudef flag joinquit

proc getTrigger {} {
  global trigger
  return $trigger
}

proc quitcheck:pub {nick uhost hand chan text} {
  global botnick
  if {![matchattr [nick2hand $nick] o|m $chan]} {return}
  if {([lindex [split $text] 0] == "") && (![regexp c [getchanmode $chan]]} {putquick "PRIVMSG $chan :\037ERROR\037: Incorrect Parameters. \037SYNTAX\037: [getTrigger]quitcheck on/off"; return}
  if {([lindex [split $text] 0] == "") && ([regexp c [getchanmode $chan]]} {putquick "PRIVMSG $chan :ERROR: Incorrect Parameters. SYNTAX: [getTrigger]quitcheck on/off"; return}

  if {[lindex [split $text] 0] == "on"} {
    if {[channel get $chan quitcheck] && ![regexp c [getchanmode $chan]]} {putquick "PRIVMSG $chan :\037ERROR\037: This setting is already enabled."; return}
    if {[channel get $chan quitcheck] && [regexp c [getchanmode $chan]]} {putquick "PRIVMSG $chan :ERROR: This setting is already enabled."; return}
    channel set $chan +quitcheck
    puthelp "PRIVMSG $chan :Enabled QuitCheck Protection for $chan"
    return 0
  }

  if {[lindex [split $text] 0] == "off"} {
    if {![channel get $chan quitcheck] && ![regexp c [getchanmode $chan]]} {putquick "PRIVMSG $chan :\037ERROR\037: This setting is already disabled."; return}
    if {![channel get $chan quitcheck] && [regexp c [getchanmode $chan]]} {putquick "PRIVMSG $chan :ERROR: This setting is already disabled."; return}
    channel set $chan -quitcheck
    puthelp "PRIVMSG $chan :Disabled QuitCheck Protection for $chan"
    return 0
  }
}

proc joinquit:pub {nick uhost hand chan text} {
  global botnick
  if {![matchattr [nick2hand $nick] o|m $chan]} {return}
  if {([lindex [split $text] 0] == "") && (![regexp c [getchanmode $chan]]} {putquick "PRIVMSG $chan :\037ERROR\037: Incorrect Parameters. \037SYNTAX\037: [getTrigger]joinquit on/off"; return}
  if {([lindex [split $text] 0] == "") && ([regexp c [getchanmode $chan]]} {putquick "PRIVMSG $chan :ERROR: Incorrect Parameters. SYNTAX: [getTrigger]joinquit on/off"; return}

  if {[lindex [split $text] 0] == "on"} {
    if {[channel get $chan joinquit] && ![regexp c [getchanmode $chan]]} {putquick "PRIVMSG $chan :\037ERROR\037: This setting is already enabled."; return}
    if {[channel get $chan joinquit] && [regexp c [getchanmode $chan]]} {putquick "PRIVMSG $chan :ERROR: This setting is already enabled."; return}
    channel set $chan +joinquit
    puthelp "PRIVMSG $chan :Enabled JoinQuit Protection for $chan"
    return 0
  }

  if {[lindex [split $text] 0] == "off"} {
    if {![channel get $chan joinquit] && ![regexp c [getchanmode $chan]]} {putquick "PRIVMSG $chan :\037ERROR\037: This setting is already disabled."; return}
    if {![channel get $chan joinquit] && [regexp c [getchanmode $chan]]} {putquick "PRIVMSG $chan :ERROR: This setting is already disabled."; return}
    channel set $chan -joinquit
    puthelp "PRIVMSG $chan :Disabled JoinQuit Protection for $chan"
    return 0
  }
}

proc joinpart:pub {nick uhost hand chan arg} {
  global botnick
  if {![matchattr [nick2hand $nick] o|m $chan]} {return}
  if {[lindex [split $arg] 0] == ""} {putquick "PRIVMSG $chan :\037ERROR\037: Incorrect Parameters. \037SYNTAX\037: [getTrigger]joinpart on|off"; return}

  if {[lindex [split $arg] 0] == "on"} {
    if {[channel get $chan joinpart]} {putquick "PRIVMSG $chan :\037ERROR\037: This setting is already enabled."; return}
    channel set $chan +joinpart
    puthelp "PRIVMSG $chan :Enabled JoinPart Protection for $chan"
    return 0
  }

  if {[lindex [split $arg] 0] == "off"} {
    if {![channel get $chan joinpart]} {putquick "PRIVMSG $chan :\037ERROR\037: This setting is already disabled."; return}
    channel set $chan -joinpart
    puthelp "PRIVMSG $chan :Disabled JoinPart Protection for $chan"
    return 0
  }
}

proc joinquit:msg {nick uhost hand arg} {
  global botnick
  set chan [strlwr [lindex $arg 0]]
  if {![matchattr [nick2hand $nick] o|m $chan]} {return}
  if {[lindex [split $arg] 0] == ""} {putquick "NOTICE $nick :\037ERROR\037: Incorrect Parameters. \037SYNTAX\037: /msg $botnick joinquit #channel on/off"; return}
  if {([lindex [split $arg] 1] == "") && ([string match "*#*" $chan])} {putquick "NOTICE $nick :\037ERROR\037: Incorrect Parameters. \037SYNTAX\037: /msg $botnick joinquit $chan on/off"; return}

  if {([lindex [split $arg] 1] == "on") && ([string match "*#*" $chan])} {
    if {[channel get $chan joinquit]} {putquick "NOTICE $nick :\037ERROR\037: This setting is already enabled."; return}
    channel set $chan +joinquit
    putquick "NOTICE $nick :Enabled JoinQuit Protection for $chan"
  }

  if {([lindex [split $arg] 1] == "off") && ([string match "*#*" $chan])} {
    if {![channel get $chan joinquit]} {putquick "NOTICE $nick :\037ERROR\037: This setting is already disabled."; return}
    channel set $chan -joinquit
    putquick "NOTICE $nick :Disabled JoinQuit Protection for $chan"
  }
}

proc joinpart:msg {nick uhost hand arg} {
  global botnick
  set chan [strlwr [lindex $arg 0]]
  if {![matchattr [nick2hand $nick] o|m $chan]} {return}
  if {[lindex [split $arg] 0] == ""} {putquick "NOTICE $nick :\037ERROR\037: Incorrect Parameters. \037SYNTAX\037: /msg $botnick joinpart #channel on|off"; return}
  if {[lindex [split $arg] 1] == ""} {putquick "NOTICE $nick :\037ERROR\037: Incorrect Parameters. \037SYNTAX\037: /msg $botnick joinpart $chan on|off"; return}

  if {[lindex [split $arg] 1] == "on"} {
    if {[channel get $chan joinpart]} {putquick "NOTICE $nick :\037ERROR\037: This setting is already enabled."; return}
    channel set $chan +joinpart
    putquick "NOTICE $nick :Enabled JoinPart Protection for $chan"
  }

  if {[lindex [split $arg] 1] == "off"} {
    if {![channel get $chan joinpart]} {putquick "NOTICE $nick :\037ERROR\037: This setting is already disabled."; return}
    channel set $chan -joinpart
    putquick "NOTICE $nick :Disabled JoinPart Protection for $chan"
  }
}

proc quit:check {nick uhost hand chan reason} {
  global quitwords exemptwords
  if {[channel get $chan quitcheck]} {
    foreach exempt $exemptwords {
      if {[string match -nocase $exempt $reason]} {return}
    }
    foreach quitmatch $quitwords {
      if {([botisop $chan]) || (![validuser [nick2hand $nick]]) || (![isop $nick $chan]) || (![isvoice $nick $chan])} {
        if {([string match -nocase $quitmatch $reason]) && (![string match -nocase "*ghost*" $reason]) && (![string match -nocase "*collision*" $reason]) && (![string match -nocase "*svskill*" $reason])} {
          set mask *!*@[lindex [split [getchanhost $nick $chan] @] 1]
          pushmode $chan +b $mask
        }
      }
    }
    flushmode $chan
  }
}

proc join:quit {nick uhost hand chan reason} {
  global jointime
  if {[channel get $chan joinquit] || [isbotnick $nick] || [botisop $chan] || ![isop $nick $chan] || ![isvoice $nick $chan] || ![validuser [nick2hand $nick]]} {
    set mask *!*@[lindex [split [getchanhost $nick $chan] @] 1]
    set join [getchanjoin $nick $chan]
    set quit [unixtime]
    set joinquit [expr $quit - $join]
    if {$joinquit <= $jointime} {
      pushmode $chan +b $mask
    }
  }
  flushmode $chan
}

proc join:part {nick uhost hand chan {msg ""}} {
  global jointime
  if {![channel get $chan joinpart] || [isbotnick $nick] || ![botisop $chan]} {return}
    set mask *!*@[lindex [split [getchanhost $nick $chan] @] 1]
    set join [getchanjoin $nick $chan]
    set part [unixtime]
    set joinpart [expr $part - $join]
    if {$joinpart <= $jointime} {
      pushmode $chan +b $mask
  }
  flushmode $chan
}

putlog ".:partquit.tcl:.v, 1.5.1 - istok @ IRCSpeed"
