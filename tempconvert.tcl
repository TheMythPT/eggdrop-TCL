# $Id: convert.tcl,v1.4 18/01/2016 04:45:10pm GMT +13 (NZDST) IRCSpeed Exp $
# Default trigger set to "!"

# Commands
# --------

# PUBLIC
# !convtemp on|off
# !convert c/f <-/number>
# (examples: !convert c 12 <- !convert f -14 <- !convert c -23 <- !convert f 120 <-)

# PRIVMSG
# /msg botnickname convtemp #anychannelname on|off

# -----------EDIT BELOW------------

# Set this to whatever trigger you like.
set myconverttrig "!"

# Set Global trigger flags to turn on and use !convert (default: o)
set convertglobflags o

# Set Channel trigger flags to turn on and use !convert (defaut: o)
set convertchanflags o

# ------DONT TOUCH BELOW HERE!!!------
setudef flag convtemp

bind pub - ${myconverttrig}convtemp convtemp:pub
bind pub - ${myconverttrig}convert con:vert
bind msg - convtemp convtemp:msg

proc myConvertTrig {} {
  global myconverttrig
  return $myconverttrig
}

proc convtemp:pub {nick uhost hand chan text} {
  global botnick convertglobflags convertchanflags
  if {[matchattr [nick2hand $nick] $convertglobflags|$convertchanflags $chan]} {
    if {[lindex [split $text] 0] == ""} {putquick "PRIVMSG $chan :ERROR: Incorrect Parameters. SYNTAX: [myConvertTrig]convtemp on|off"; return}

    if {[lindex [split $text] 0] == "on"} {
      if {[channel get $chan convtemp]} {putquick "PRIVMSG $chan :ERROR: This setting is already enabled."; return}
      channel set $chan +convtemp
      puthelp "PRIVMSG $chan :Enabled Temperature Conversion for $chan"
      return 0
    }

    if {[lindex [split $text] 0] == "off"} {
      if {![channel get $chan convtemp]} {putquick "PRIVMSG $chan :ERROR: This setting is already disabled."; return}
      channel set $chan -convtemp
      puthelp "PRIVMSG $chan :Disabled Temperature Conversion for $chan"
      return 0
    }
  }
}

proc convtemp:msg {nick uhost hand arg} {
  global botnick convertglobflags convertchanflags
  set chan [strlwr [lindex $arg 0]]
  if {[matchattr [nick2hand $nick] $convertglobflags|$convertchanflags $chan]} {
    if {[lindex [split $arg] 0] == ""} {putquick "NOTICE $nick :\037ERROR\037: Incorrect Parameters. \037SYNTAX\037: /msg $botnick convtemp #channelname on|off"; return}
    if {([lindex [split $arg] 1] == "") && ([string match "*#*" $chan])} {putquick "NOTICE $nick :\037ERROR\037: Incorrect Parameters. \037SYNTAX\037: /msg $botnick convtemp $chan on|off"; return}

    if {([lindex [split $arg] 1] == "on") && ([string match "*#*" $chan])} {
      if {[channel get $chan convtemp]} {putquick "NOTICE $nick :\037ERROR\037: This setting is already enabled."; return}
      channel set $chan +convtemp
      putquick "NOTICE $nick :Enabled Temperature Conversion for $chan"
      return 0
    }

    if {([lindex [split $arg] 1] == "off") && ([string match "*#*" $chan])} {
      if {![channel get $chan convtemp]} {putquick "NOTICE $nick :\037ERROR\037: This setting is already disabled."; return}
      channel set $chan -convtemp
      putquick "NOTICE $nick :Disabled Temperature Conversion for $chan"
      return 0
    }
  }
}

proc con:vert {nick uhost hand chan text} {
  if {[validuser [nick2hand $nick]] || [isop $nick $chan] || [isvoice $nick $chan]} {
    if {![channel get $chan convtemp]} {putquick "PRIVMSG $chan :\037ERROR\037: Conversion Module is not currently enabled for $chan"; return}

      if {[lindex [split $text] 0] == ""} {putquick "PRIVMSG $chan :ERROR: Incorrect Parameters. SYNTAX: [myConvertTrig]convert c|f temp"; return}

      if {[lindex [split $text] 0] == "c"} {
        if {[lindex [split $text] 1] == ""} {putquick "PRIVMSG $chan :ERROR: Incorrect Parameters. SYNTAX: [myConvertTrig]convert c|f temp"; return}
        set ctemp [lindex [split $text] 1]
        if {![isnum $ctemp]} {putquick "PRIVMSG $chan :ERROR: Incorrect Parameters. SYNTAX: [myConvertTrig]convert c|f temp"; return}
        if {$ctemp == 0} {putquick "PRIVMSG $chan :Converted: 0\xB0 C equals 32\xB0 F"; return}
        if {!$ctemp == 0} {
          set calctemp [expr {$ctemp * 1.8}]
          set calcnum [expr {$calctemp + 32}]
          putquick "PRIVMSG $chan :Converted: $ctemp\xB0 C equals [expr $calcnum]\xB0 F"
          return 0
        }
      }

      if {[lindex [split $text] 0] == "f"} {
        if {[lindex [split $text] 1] == ""} {putquick "PRIVMSG $chan :ERROR: Incorrect Parameters. SYNTAX: [myConvertTrig]convert c|f temp"; return}
        set ctemp [lindex [split $text] 1]
        if {![isnum $ctemp]} {putquick "PRIVMSG $chan :ERROR: Incorrect Parameters. SYNTAX: [myConvertTrig]convert c|f temp"; return}
        if {$ctemp == 0} {putquick "PRIVMSG $chan :Converted: 0\xB0 F equals -17.77\xB0 C"; return}
        if {!$ctemp == 0} {
          set calctemp [expr {$ctemp - 32}]
          set calcnum [expr {$calctemp * 0.55555555555555555555555555555556}]
          putquick "PRIVMSG $chan :Converted: $ctemp\xB0 F equals [expr $calcnum]\xB0 C"
          return 0
      }
    }
  }
}

proc isnum {string} {
  if {[regexp {^-?\d+(\.\d+)?$} $string]} {
    return 1;
  }
  return 0;
}

putlog "Conversion Module: Loaded - istok @ IRCSpeed"
