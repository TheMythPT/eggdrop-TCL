set pubtrig "!"

# Set global|channel flags to trigger commands
set sysflags o|m

bind pub - ${pubtrig}uptime uptime:pub
proc uptime:pub {nick uhost hand chan arg} {
  global uptime server sysflags
  if {([matchattr [nick2hand $nick] $sysflags]) && (![regexp c [getchanmode $chan]])} {
    puthelp "PRIVMSG $chan :\002S\002\037ystem\037: [eval exec uptime]"
    puthelp "PRIVMSG $chan :\002B\002\037ot\037 ($server): [duration [expr [unixtime] - $uptime]]"
    } else {
    if {([matchattr [nick2hand $nick] $sysflags]) && ([regexp c [getchanmode $chan]])} {
      puthelp "PRIVMSG $chan :System: [eval exec uptime]"
      puthelp "PRIVMSG $chan :Bot ($server): [duration [expr [unixtime] - $uptime]]"
    }
  }
}

bind pub - ${pubtrig}os osystem:pub
proc osystem:pub {nick uhost hand chan arg} {
  global botnick sysflags
  if {([matchattr [nick2hand $nick] $sysflags]) && (![regexp c [getchanmode $chan]])} {
    puthelp "PRIVMSG $chan :\002O\002\037perating\037 \002S\002\037ystem\037: [eval exec uname] [eval exec uname -r]"
    } else {
    if {([matchattr [nick2hand $nick] $sysflags]) && ([regexp c [getchanmode $chan]])} {
      puthelp "PRIVMSG $chan :Operating System: [eval exec uname] [eval exec uname -r]"
    }
  }
}
