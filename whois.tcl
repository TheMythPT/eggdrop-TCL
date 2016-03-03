# $Id: whois.tcl,v1.3a 04/02/2015 06:23:31am GMT +12 (NZST) IRCSpeed Exp $

## Commands
# ----------
# !whoami - shows your own personal status info.
# !whois <nickname> - shows personal status info for <nickname>.
# /msg yourbot whois #channel <nickname>

# Set your global command trigger here (default set to ! <-)
set whoispubtrig "!"

# ----- NO EDITING -----
proc getWhoTrigger {} {
  global whoispubtrig
  return $whoispubtrig
}

bind pub - ${whoispubtrig}whoami whoami:pub
proc whoami:pub {nick uhost hand chan arg} {
  if {![validuser [nick2hand $nick]]} {putquick "NOTICE $nick :\037ERROR\037: You are NOT known to me."; return}

  if {![regexp c [getchanmode $chan]]} {
    putquick "PRIVMSG $chan :\002Nick\002: $nick ($uhost) - \002Handle\002: [nick2hand $nick] - \002Flags\002: [chattr [nick2hand $nick] $chan]"

    if {[matchattr [nick2hand $nick] n]} {
      putquick "PRIVMSG $chan :You are an \002Administrator\002 for my Bot Group"
      return 0
    }

    if {[matchattr [nick2hand $nick] m]} {
      putquick "PRIVMSG $chan :You are a \002Co Administrator\002 for my Bot Group"
      return 0
    }

    if {[matchattr [nick2hand $nick] o]} {
      putquick "PRIVMSG $chan :You are a \002Global Operator\002 for my Bot Group"
      return 0
    }

    if {[matchattr [nick2hand $nick] |n $chan]} {
      putquick "PRIVMSG $chan :You are a \002Channel Owner\002 for $chan"
      return 0
    }

    if {[matchattr [nick2hand $nick] |m $chan]} {
      putquick "PRIVMSG $chan :You are a \002Channel Master\002 for $chan"
      return 0
    }

    if {[matchattr [nick2hand $nick] |o $chan]} {
      putquick "PRIVMSG $chan :You are a \002Channel Operator\002 for $chan"
      return 0
    }

    if {[matchattr [nick2hand $nick] |v $chan]} {
      putquick "PRIVMSG $chan :You are a \002Channel Voice\002 for $chan"
      return 0
    } 
  }

  if {[regexp c [getchanmode $chan]]} {
    putquick "PRIVMSG $chan :Nick: $nick ($uhost) - Handle: [nick2hand $nick] - Flags: [chattr [nick2hand $nick] $chan]"

    if {[matchattr [nick2hand $nick] n]} {
      putquick "PRIVMSG $chan :You are an Administrator for my Bot Group"
      return 0
    }

    if {[matchattr [nick2hand $nick] m]} {
      putquick "PRIVMSG $chan :You are a Co Administrator for my Bot Group"
      return 0
    }

    if {[matchattr [nick2hand $nick] o]} {
      putquick "PRIVMSG $chan :You are a Global Operator for my Bot Group"
      return 0
    }

    if {[matchattr [nick2hand $nick] |n $chan]} {
      putquick "PRIVMSG $chan :You are a Channel Owner for $chan"
      return 0
    }

    if {[matchattr [nick2hand $nick] |m $chan]} {
      putquick "PRIVMSG $chan :You are a Channel Master for $chan"
      return 0
    }

    if {[matchattr [nick2hand $nick] |o $chan]} {
      putquick "PRIVMSG $chan :You are a Channel Operator for $chan"
      return 0
    }

    if {[matchattr [nick2hand $nick] |v $chan]} {
      putquick "PRIVMSG $chan :You are a Channel Voice for $chan"
      return 0
    } 
  }
}

bind pub - ${whoispubtrig}whois whois:pub
proc whois:pub {nick uhost hand chan arg} {
  if {![matchattr [nick2hand $nick] o|ovf $chan]} {putquick "NOTICE $nick :ERROR: You do not have access to this command."; return}
  set whoisnick [lindex [split $arg] 0]
  if {($whoisnick == "") && (![regexp c [getchanmode $chan]])} {putquick "PRIVMSG $chan :\037ERROR\037: Incorrect Parameters. \037SYNTAX\037: [getWhoTrigger]whois nickname"; return}
  if {($whoisnick == "") && ([regexp c [getchanmode $chan]])} {putquick "PRIVMSG $chan :ERROR: Incorrect Parameters. SYNTAX: [getWhoTrigger]whois nickname"; return}
  if {![validuser [nick2hand $whoisnick]] && ![regexp c [getchanmode $chan]]} {putquick "PRIVMSG $chan :\037ERROR\037: $whoisnick is an Unknown User."; return}
  if {![validuser [nick2hand $whoisnick]] && [regexp c [getchanmode $chan]]} {putquick "PRIVMSG $chan :ERROR: $whoisnick is an Unknown User."; return}
  if {![regexp c [getchanmode $chan]]} {
    putquick "PRIVMSG $chan :\002Nick\002: $whoisnick ([getchanhost $whoisnick $chan]) - \002Handle\002: [nick2hand $whoisnick] - \002Flags\002: [chattr [nick2hand $whoisnick] $chan]"

    if {[matchattr [nick2hand $whoisnick] n]} {
      putquick "PRIVMSG $chan :$whoisnick is an \002Administrator\002 for my Bot Group"
      return 0
    }

    if {[matchattr [nick2hand $whoisnick] m]} {
      putquick "PRIVMSG $chan :$whoisnick is a \002Co Administrator\002 for my Bot Group"
      return 0
    }

    if {[matchattr [nick2hand $whoisnick] o]} {
      putquick "PRIVMSG $chan :$whoisnick is a \002Global Operator\002 for my Bot Group"
      return 0
    }

    if {[matchattr [nick2hand $whoisnick] |n $chan]} {
      putquick "PRIVMSG $chan :$whoisnick is a \002Channel Owner\002 for $chan"
      return 0
    }

    if {[matchattr [nick2hand $whoisnick] |m $chan]} {
      putquick "PRIVMSG $chan :$whoisnick is a \002Channel Master\002 for $chan"
      return 0
    }

    if {[matchattr [nick2hand $whoisnick] |o $chan]} {
      putquick "PRIVMSG $chan :$whoisnick is a \002Channel Operator\002 for $chan"
      return 0
    }

    if {[matchattr [nick2hand $whoisnick] |v $chan]} {
      putquick "PRIVMSG $chan :$whoisnick is a \002Channel Voice\002 for $chan"
      return 0
    }
  }

  if {[regexp c [getchanmode $chan]]} {
    putquick "PRIVMSG $chan :Nick: $whoisnick ([getchanhost $whoisnick $chan]) - Handle: [nick2hand $whoisnick] - Flags: [chattr [nick2hand $whoisnick] $chan]"

    if {[matchattr [nick2hand $whoisnick] n]} {
      putquick "PRIVMSG $chan :$whoisnick is an Administrator for my Bot Group"
      return 0
    }

    if {[matchattr [nick2hand $whoisnick] m]} {
      putquick "PRIVMSG $chan :$whoisnick is a Co Administrator for my Bot Group"
      return 0
    }

    if {[matchattr [nick2hand $whoisnick] o]} {
      putquick "PRIVMSG $chan :$whoisnick is a Global Operator for my Bot Group"
      return 0
    }

    if {[matchattr [nick2hand $whoisnick] |n $chan]} {
      putquick "PRIVMSG $chan :$whoisnick is a Channel Owner for $chan"
      return 0
    }

    if {[matchattr [nick2hand $whoisnick] |m $chan]} {
      putquick "PRIVMSG $chan :$whoisnick is a Channel Master for $chan"
      return 0
    }

    if {[matchattr [nick2hand $whoisnick] |o $chan]} {
      putquick "PRIVMSG $chan :$whoisnick is a Channel Operator for $chan"
      return 0
    }

    if {[matchattr [nick2hand $whoisnick] |v $chan]} {
      putquick "PRIVMSG $chan :$whoisnick is a Channel Voice for $chan"
      return 0
    }
  }
}

bind msg - whois whois:msg
proc whois:msg {nick uhost hand arg} {
  global botnick
  if {![string match "*#*" $arg]} {putquick "NOTICE $nick :\037ERROR\037: Incorrect Parameters. \037SYNTAX\037: /msg $botnick whois #channel nickname"; return}
  set chan [lindex [split $arg] 0]
  if {![matchattr [hand2nick $hand] o|m $chan]} {putquick "NOTICE $nick :\037ERROR\037: You do not have access to this command."; return}
  if {$chan == ""} {putquick "NOTICE $nick :\037ERROR\037: Incorrect Parameters. \037SYNTAX\037: /msg $botnick whois #channel nickname"; return}
  set whoisnick [lindex [split $arg] 1]
  if {$whoisnick == ""} {putquick "NOTICE $nick :\037ERROR\037: Incorrect Parameters. \037SYNTAX\037: /msg $botnick whois $chan nickname"; return}
  if {![validuser [nick2hand $whoisnick]]} {putquick "NOTICE $nick :$whoisnick is an Unknown User."; return}
  putquick "NOTICE $nick :\002Nick\002: $whoisnick ([getchanhost $whoisnick $chan]) - \002Handle\002: [nick2hand $whoisnick] - \002Flags\002: [chattr [nick2hand $whoisnick] $chan]"

  if {[matchattr [nick2hand $whoisnick] n]} {
    putquick "NOTICE $nick :$whoisnick is an Administrator for my Bot Group"
    return 0
  }

  if {[matchattr [nick2hand $whoisnick] m]} {
    putquick "NOTICE $nick :$whoisnick is a Co Administrator for my Bot Group"
    return 0
  }

  if {[matchattr [nick2hand $whoisnick] o]} {
    putquick "NOTICE $nick :$whoisnick is a Global Operator for my Bot Group"
    return 0
  }

  if {[matchattr [nick2hand $whoisnick] |n $chan]} {
    putquick "NOTICE $nick :$whoisnick is a Channel Owner for $chan"
    return 0
  }

  if {[matchattr [nick2hand $whoisnick] |m $chan]} {
    putquick "NOTICE $nick :$whoisnick is a Channel Master for $chan"
    return 0
  }

  if {[matchattr [nick2hand $whoisnick] |o $chan]} {
    putquick "NOTICE $nick :$whoisnick is a Channel Operator for $chan"
    return 0
  }

  if {[matchattr [nick2hand $whoisnick] |v $chan]} {
    putquick "NOTICE $nick :$whoisnick is a Channel Voice for $chan"
    return 0
  }
}

putlog ".:LOADED:. whois.tcl,v1.3a - istok @ IRCSpeed"
