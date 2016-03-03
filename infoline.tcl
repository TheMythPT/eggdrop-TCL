# In your eggdrop.conf file, you will have this setting, change it however you want it.
# Set here the time (in seconds) that someone must have been off-channel
# before re-displaying their info line.
#set wait-info 5

# Commands are:
# !infoline add text to add for infoline
# to add a new infoline, or replace an old one.
# NOTE: text for infoline is restricted to 120 characters. Exceeding this limit will cut the text off.

# !infoline del
# to remove set infoline.

# !infoline show
# to show current infoline.

# !greet on|off
# to enable|disable the greet setting for the channel.

# Copy/paste the code below into a new file, infoline.txt (then change *.txt to *.tcl)

# Set global trigger here
set infotriga "!"

# Set global flags allowed to use infoline and greet commands.
set infoglobflags o

# Set channel flags allowed to use infoline command.
set infochanflags vo

# Set channel flags allowed to use the greet command.
set infogreetflags m

# ----- NOTHING ELSE TO SET! -----
proc getTrigger { } {
  global infotriga
  return $infotriga
}

bind pub - ${infotriga}infoline info:line
proc info:line {nick uhost hand chan arg} {
  global infoglobflags infochanflags
  if {![matchattr [nick2hand $nick] $infoglobflags|$infochanflags $chan]} {return}
  if {[lindex [split $arg] 0] == ""} {putquick "PRIVMSG $chan :ERROR: Incorrect Parameters. SYNTAX: [getTrigger]infoline add whatever text you want - [getTrigger]infoline del - [getTrigger]infoline show"; return}

  if {[lindex [split $arg] 0] == "add"} {
    set infotext [join [lrange [split $arg] 1 end]]
    setchaninfo "[nick2hand $nick]" "$chan" "$infotext"
    if {![channel get $chan greet]} {putquick "PRIVMSG $chan :InfoLine for $nick now set to $infotext - (NOTE: Please have someone enable +greet for your infoline to become active)"; return}
    putquick "PRIVMSG $chan :InfoLine for $nick now set to $infotext"
    return 0
  }

  if {[lindex [split $arg] 0] == "del"} {
    if {[getchaninfo [nick2hand $nick] $chan] == ""} {putquick "PRIVMSG $chan :You currently have no infoline set for $chan"; return}
    setchaninfo "[nick2hand $nick]" "$chan" "none"
    putquick "PRIVMSG $chan :InfoLine for $nick has now been removed."
    return 0
  }

  if {[lindex [split $arg] 0] == "show"} {
    set showtxt [getchaninfo [nick2hand $nick] $chan]
    if {$showtxt == ""} {putquick "PRIVMSG $chan :You currently have no infoline set for $chan"; return}
    putquick "PRIVMSG $chan :InfoLine for $nick: $showtxt"
    return 0
  }
}

bind pub - ${infotriga}greet greet:pub
proc greet:pub {nick uhost hand chan arg} {
  global infoglobflags infogreetflags
  if {[matchattr [nick2hand $nick] $infoglobflags|$infogreetflags $chan]} {
    if {[lindex [split $arg] 0] == ""} {putquick "PRIVMSG $chan :ERROR: Incorrect Parameters. SYNTAX: [getTrigger]greet on|off"; return}

    if {[lindex [split $arg] 0] == "on"} {
      if {[channel get $chan greet]} {putquick "PRIVMSG $chan :ERROR: This setting is already enabled."; return}
      channel set $chan +greet
      puthelp "PRIVMSG $chan :Enabled Greets for $chan"
      return 0
    }

    if {[lindex [split $arg] 0] == "off"} {
      if {![channel get $chan greet]} {putquick "PRIVMSG $chan :ERROR: This setting is already disabled."; return}
      channel set $chan -greet
      puthelp "PRIVMSG $chan :Disabled Greets for $chan"
      return 0
    }
  }
}

putlog "Info.Line Module Loaded! - istok@IRCSpeed.org"
