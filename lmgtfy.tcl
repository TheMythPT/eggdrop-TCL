# $Id: lmgtfy.tcl,v1.5.0 20/02/2016 04:05:22am GMT +13 (NZDST) IRCSpeed Exp $
# Let Me Google That for You

# SYNTAX:
# !lmgtfy on|off
# !lmgtfy any text that you may want to search

# Set global trigger for LMGTFY (default: !)
set lmgtfytrig "!"

# Set global LMGTFY flags to trigger command (default: ovf)
set lmgtfyglobflags ovf

# Set channel LMGTFY flags to trigger command (default: ovf)
set lmgtfychanflags ovf

## ------ DO NOT EDIT ------ ##
proc makelmgtfyTrig {} {
  global lmgtfytrig
  return $lmgtfytrig
}

setudef flag lmgtfytcl

bind pub - ${lmgtfytrig}lmgtfy lmgtfy:public
proc lmgtfy:public {nick uhost hand chan arg} {
  global lmgtfyglobflags lmgtfychanflags
  if {![matchattr [nick2hand $nick] $lmgtfyglobflags|$lmgtfychanflags $chan]} {return}

   if {[lindex [split $arg] 0] == "on"} {
    if {[channel get $chan lmgtfytcl]} {putquick "PRIVMSG $chan :\037ERROR\037: This setting is already enabled."; return}
    channel set $chan +lmgtfytcl
    putquick "PRIVMSG $chan :Enabled LMGTFY Command for $chan"
    return 0
  }

   if {[lindex [split $arg] 0] == "off"} {
    if {![channel get $chan lmgtfytcl]} {putquick "PRIVMSG $chan :\037ERROR\037: This setting is already disabled."; return}
    channel set $chan -lmgtfytcl
    putquick "PRIVMSG $chan :Disabled LMGTFY Command for $chan"
    return 0
  }

  if {![channel get $chan lmgtfytcl]} {return}
  set extra [join [lrange [split $arg] 0 end]]
  set extra [regsub -all -- {\s} "$extra" +]
  if {$extra == ""} {putquick "PRIVMSG $chan :ERROR: Incorrect Parameters. SYNTAX: [makelmgtfyTrig]lmgtfy <search argument here>"; return}
  putquick "PRIVMSG $chan :\037L\037et \037M\037e \037G\037oogle \037T\037hat \037F\037or \037Y\037ou: http://lmgtfy.com/?q=$extra"
}

putlog ".:LOADED:. \037L\037et \037M\037e \037G\037oogle \037T\037hat \037F\037or \037Y\037ou - istok @ IRCSpeed"
