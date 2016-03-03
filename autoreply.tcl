# $Id: autoreply.tcl,v1.7 18/01/2016 03:33:45am GMT +13 (NZDST) IRCSpeed Exp $

# Commands are; !talkz on|off
#               /msg botnick talkz #channel on|off
# Feel free to edit the trigger, the reply flags and thankstext/complaintext. Add heaps of replies, or have a few, it's up to you.

# Feel free to edit this setting. Change the ! to any character you would like as a trigger.
set replytrig "!"

# Set here what flags you wish to allow and trigger this script (leave it "" for anyone)
set replyglobflags "ovf"
set replychanflags "ovf"

# Set here the text to thank the user who voiced you.
set thankstext {
  "Thanks for the $mode $nick"
  "wow.. thanks, $nick"
  "cool, thank you! I _LOVE_ $chan!!"
}

# Set here the text to complain about being devoiced.
set complaintext {
  "awww, man! why me, $nick?!"
  "pfft, be that way, /hop"
  "wait until I tell .."
  "hmm, stop it."
}

########## ----- NO EDITING BELOW ----- ##########
proc getReplyTrig {} {
 global replytrig
 return $replytrig
}

setudef flag talkz

bind mode - "% +o" op:check
bind mode - "% -o" deop:check
bind mode - "% +v" voice:check
bind mode - "% -v" devoice:check
bind pub - ${replytrig}talkz talkz:pub
bind msg - talkz talkz:msg

proc talkz:pub {nick uhost hand chan arg} {
  global replyglobflags replychanflags
  if {[matchattr [nick2hand $nick] $replyglobflags|$replychanflags $chan]} {
    if {[lindex [split $arg] 0] == ""} {putquick "PRIVMSG $chan :\037ERROR\037: Incorrect Parameters. \037SYNTAX\037: [getReplyTrig]talkz on|off"; return}

    if {[lindex [split $arg] 0] == "on"} {
      if {[channel get $chan talkz]} {putquick "PRIVMSG $chan :\037ERROR\037: This setting is already enabled."; return}
      channel set $chan +talkz
      puthelp "PRIVMSG $chan :Enabled Autoreply Thanks System for $chan"
      return 0
    }

    if {[lindex [split $arg] 0] == "off"} {
      if {![channel get $chan talkz]} {putquick "PRIVMSG $chan :\037ERROR\037: This setting is already disabled."; return}
      channel set $chan -talkz
      puthelp "PRIVMSG $chan :Disabled Autoreply Thanks System for $chan"
      return 0
    }
  }
}

proc talkz:msg {nick uhost hand arg} {
  global botnick replyglobflags replychanflags
  set chan [strlwr [lindex [split $arg] 0]]
  if {[matchattr [nick2hand $nick] $replyglobflags|$replychanflags $chan]} {
    if {[lindex [split $arg] 0] == ""} {putquick "NOTICE $nick :\037ERROR\037: Incorrect Parameters. \037SYNTAX\037: /msg $botnick talkz #channel on|off"; return}
    if {[lindex [split $arg] 1] == ""} {putquick "NOTICE $nick :\037ERROR\037: Incorrect Parameters. \037SYNTAX\037: /msg $botnick talkz $chan on|off"; return}

    if {[lindex [split $arg] 1] == "on"} {
      if {[channel get $chan talkz]} {putquick "NOTICE $nick :\037ERROR\037: This setting is already enabled."; return}
      channel set $chan +talkz
      putquick "NOTICE $nick :Enabled Autoreply Thanks System for $chan"
      return 0
    }

    if {[lindex [split $arg] 1] == "off"} {
      if {![channel get $chan talkz]} {putquick "NOTICE $nick :\037ERROR\037: This setting is already disabled."; return}
      channel set $chan -talkz
      putquick "NOTICE $nick :Disabled Autoreply Thanks System for $chan"
      return 0
    }
  }
}

proc op:check {nick uhost hand chan mode {target ""}} {
  global botnick thankstext
  if {![channel get $chan talkz]} {return}
  if {[string match $botnick $target]} {
    set replyopmsg [lindex $thankstext [rand [llength $thankstext]]] 
    set replyopmsg [subst -nocommands $replyopmsg]
    puthelp "PRIVMSG $chan :$replyopmsg"
    return 0
  }
}

proc deop:check {nick uhost hand chan mode {target ""}} {
  global botnick complaintext
  if {![channel get $chan talkz]} {return}
  if {[string match $botnick $target]} {
    set replydeopmsg [lindex $complaintext [rand [llength $complaintext]]] 
    set replydeopmsg [subst -nocommands $replydeopmsg]
    puthelp "PRIVMSG $chan :$replydeopmsg"
    return 0
  }
}

proc voice:check {nick uhost hand chan mode {target ""}} {
  global botnick thankstext
  if {![channel get $chan talkz]} {return}
  if {[string match $botnick $target]} {
    set replyvoicemsg [lindex $thankstext [rand [llength $thankstext]]] 
    set replyvoicemsg [subst -nocommands $replyvoicemsg]
    puthelp "PRIVMSG $chan :$replyvoicemsg"
    return 0
  }
}

proc devoice:check {nick uhost hand chan mode {target ""}} {
  global botnick complaintext
  if {![channel get $chan talkz]} {return}
  if {[string match $botnick $target]} {
    set replydevoicemsg [lindex $complaintext [rand [llength $complaintext]]] 
    set replydevoicemsg [subst -nocommands $replydevoicemsg]
    puthelp "PRIVMSG $chan :$replydevoicemsg"
    return 0
  }
}

putlog ".:autoreply.tcl,v1.7:. Loaded! - istok @ IRCSpeed"
