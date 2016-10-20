set myTriga "!"

bind pub - ${myTriga}puff puff:pub
proc puff:pub {nick uhost hand chan arg} {
  global botnick
  if {[validuser [nick2hand $nick]]} {

    if {[lindex [split $arg] 0] == ""} {
      putserv "PRIVMSG $chan :\001ACTION \0033hands $nick a Bag of \0039,3*WeeD*\003\001"
      putserv "PRIVMSG $chan :\001ACTION \00314( *puff - puff* )\003\001"
      } else {
      set givenick [lindex [split $arg] 0]
      if {[isbotnick $givenick]} {putquick "PRIVMSG $chan :umm, bots don't sm0ke, you f00l!"; return}
      putserv "PRIVMSG $chan :\001ACTION \0033was asked nicely by $nick to give $givenick a Bag of \0039,3*WeeD*\003\001"
      putserv "PRIVMSG $chan :\001ACTION \00314( *puff - puff* )\003\001"
    }
    return
  }

  if {![validuser [nick2hand $nick]]} {
    if {[lindex [split $arg] 0] == ""} {
      putserv "PRIVMSG $chan :\001ACTION \0033hands $nick a Bag of \0039,3*WeeD*\003\001"
      putserv "PRIVMSG $chan :\001ACTION \00314( *puff - puff* )\003\001"
      set whom $nick
      set ignoremask *!*@[lindex [split [getchanhost $whom $chan] @] 1]
      newignore $ignoremask $botnick TempIgnore 1
      } else {
      set givenick [lindex [split $arg] 0]
      if {[isbotnick $givenick]} {putquick "PRIVMSG $chan :umm, bots don't sm0ke, you f00l!"; return}
      putserv "PRIVMSG $chan :\001ACTION \0033was asked nicely by $nick to give $givenick a Bag of \0039,3*WeeD*\003\001"
      putserv "PRIVMSG $chan :\001ACTION \00314( *puff - puff* )\003\001"
      set whom $nick
      set ignoremask *!*@[lindex [split [getchanhost $whom $chan] @] 1]
      newignore $ignoremask $botnick TempIgnore 1
    }
    return
  }
}
