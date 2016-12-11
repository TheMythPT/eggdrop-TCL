# $Id: autovoice.tcl,v1.1 20/02/2014 04:42:31am GMT +12 (NZST) IRCSpeed Exp $
# SYNTAX (on PartyLine/DCC/CTCP/TELnet): .chanset #channel -/+autovoicer

# PUBCMD - To Enable, type:
# !autovoice on
# !autovoice off

# MSGCMD - To Disable, type:
# /msg botnick autovoice #channel on
# /msg botnick autovoice #channel off

# NOTE: You can use any of the above methods to enable/disable. You don't have to do them all..
# For example, you can either telnet/dcc, or do the command in channel, or via /msg - The choice is yours.
# NOTE2: This doesn't set voice for user's added to the bot. It's intended to voice everyone else.
# Added user's may have their own flags, so this checks [validuser [nick2hand $nick]]

# Set your global trigger (default: !)
set autovoicetrig "!"

# Set access flags for command (default: o|o)
set autovoiceflags o|o

############# END OF EDIT ############
proc voiceTrigger {} {
  global autovoicetrig
  return $autovoicetrig
}

setudef flag autovoicer

bind join - * auto:voice
bind pub - ${autovoicetrig}autovoice autovoice:pub
bind msg - autovoice autovoice:msg

proc autovoice:pub {nick uhost hand chan arg} {
  global autovoiceflags
  if {[matchattr [nick2hand $nick] $autovoiceflags $chan]} {
    if {[lindex [split $arg] 0] == ""} {putquick "PRIVMSG $chan :\037ERROR\037: Incorrect Parameters. \037SYNTAX\037: [voiceTrigger]autovoice on|off"; return}

    if {[lindex [split $arg] 0] == "on"} {
      if {[channel get $chan autovoicer]} {putquick "PRIVMSG $chan :\037ERROR\037: This setting is already enabled."; return}
      channel set $chan +autovoicer
      puthelp "PRIVMSG $chan :Enabled AutoVoice for $chan"
      return 0
    }

    if {[lindex [split $arg] 0] == "off"} {
      if {![channel get $chan autovoicer]} {putquick "PRIVMSG $chan :\037ERROR\037: This setting is already disabled."; return}
      channel set $chan -autovoicer
      puthelp "PRIVMSG $chan :Disabled AutoVoice for $chan"
      return 0
    }
  }
}

proc autovoice:msg {nick uhost hand arg} {
  global botnick autovoiceflags
  set chan [strlwr [lindex [split $arg] 0]]
  if {[matchattr [nick2hand $nick] $autovoiceflags $chan]} {
    if {[lindex [split $arg] 0] == ""} {putquick "NOTICE $nick :\037ERROR\037: Incorrect Parameters. \037SYNTAX\037: /msg $botnick autovoice #channel on|off"; return}
    if {[lindex [split $arg] 1] == ""} {putquick "NOTICE $nick :\037ERROR\037: Incorrect Parameters. \037SYNTAX\037: /msg $botnick autovoice $chan on|off"; return}

    if {[lindex [split $arg] 1] == "on"} {
      if {[channel get $chan autovoicer]} {putquick "NOTICE $nick :\037ERROR\037: This setting is already enabled."; return}
      channel set $chan +autovoicer
      putquick "NOTICE $nick :Enabled AutoVoice for $chan"
      return 0
    }

    if {[lindex [split $arg] 1] == "off"} {
      if {![channel get $chan autovoicer]} {putquick "NOTICE $nick :\037ERROR\037: This setting is already disabled."; return}
      channel set $chan -autovoicer
      putquick "NOTICE $nick :Disabled AutoVoice for $chan"
      return 0
    }
  }
}

proc auto:voice {nick uhost hand chan} {
  if {[channel get $chan autovoicer]} {
    if {![isbotnick $nick] && [botisop $chan] && ![validuser [nick2hand $nick]]} {
      pushmode $chan +v $nick
    }
  }
}

putlog "Loaded: Autovoice.tcl,v1.1 - istok @ IRCSpeed"
