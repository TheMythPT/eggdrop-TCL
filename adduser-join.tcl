# $Id: adduser-join.tcl,v1.6 04/03/2016 07:00:31am GMT +12 (NZST) IRCSpeed Exp $

# ----- ADDING USERS ----- (Basic User adding)
# Commands are:
# !addowner nickname
# !addmaster nickname
# !addgop nickname
# !addchanowner nickname
# !addsop nickname
# !delsop nickname
# !addaop nickname
# !delaop nickname
# !addaov nickname
# !delaov nickname

# ----- JoinModes ----- (This enforces joinmodes @/+)
# JoinModes Public Commands:
# Enable:  !joinmodes on
# Disable: !joinmodes off

# JoinModes Message Command:
# /msg botnick joinmodes #channel on|off

# -----------EDIT BELOW------------

# Set this to whatever trigger you like. (default: !)
set addusertrig "!"

# You don't need to edit the access flags. They are added like this because each command requires different access.
# This is to ensure that user's can't add/del those with more access. If you wish to edit them, edit the proc directly.

# ------EDIT COMPLETE!!------
setudef flag joinmode

proc addTrigger {} {
  global addusertrig
  return $addusertrig
}

bind join - * join:modes
bind pub - ${addusertrig}addowner addowner:pub
bind pub - ${addusertrig}addmaster addmaster:pub
bind pub - ${addusertrig}addgop addgop:pub
bind pub - ${addusertrig}addchanowner addcowner:pub
bind pub - ${addusertrig}addsop addsop:pub
bind pub - ${addusertrig}delsop delsop:pub
bind pub - ${addusertrig}addaop addaop:pub
bind pub - ${addusertrig}delaop delaop:pub
bind pub - ${addusertrig}addaov addaov:pub
bind pub - ${addusertrig}delaov delaov:pub
bind pub - ${addusertrig}joinmodes jmode:pub
bind msg - joinmodes jmode:msg

proc addowner:pub {nick uhost hand chan arg} {
  if {![matchattr [nick2hand $nick] n]} {return}
  set owneradd [lindex [split $arg] 0]
  if {[lindex [split $arg] 0] == ""} {putquick "PRIVMSG $chan :\037ERROR\037: Incorrect Parameters. \037SYNTAX\037: [addTrigger]addowner nickname"; return}
  if {[validuser [nick2hand $owneradd]]} {putquick "PRIVMSG $chan :\037ERROR\037: $owneradd is already a valid user."; return}
  if {![onchan $owneradd $chan]} {putquick "PRIVMSG $chan :\037ERROR\037: $owneradd is not even on $chan ..."; return}
  set mask *!*@[lindex [split [getchanhost $owneradd $chan] @] 1]
  adduser $owneradd $mask
  chattr $owneradd +n
  putquick "NOTICE $nick :Added $owneradd to the Global Owner List."
  putquick "NOTICE $owneradd :$nick ($hand) has added you to the Global Owner List."
}

proc addmaster:pub {nick uhost hand chan arg} {
  if {![matchattr [nick2hand $nick] n]} {return}
  set masteradd [lindex [split $arg] 0]
  if {[lindex [split $arg] 0] == ""} {putquick "PRIVMSG $chan :\037ERROR\037: Incorrect Parameters. \037SYNTAX\037: [addTrigger]addmaster nickname"; return}
  if {[validuser [nick2hand $masteradd]]} {putquick "PRIVMSG $chan :\037ERROR\037: $masteradd is already a valid user."; return}
  if {![onchan $masteradd $chan]} {putquick "PRIVMSG $chan :\037ERROR\037: $masteradd is not even on $chan ..."; return}
  set mask *!*@[lindex [split [getchanhost $masteradd $chan] @] 1]
  adduser $masteradd $mask
  chattr $masteradd +m
  putquick "NOTICE $nick :Added $masteradd to the Global Master List."
  putquick "NOTICE $masteradd :$nick ($hand) has added you to the Global Master List."
}

proc addgop:pub {nick uhost hand chan arg} {
  if {![matchattr [nick2hand $nick] m]} {return}
  set gopadd [lindex [split $arg] 0]
  if {[lindex [split $arg] 0] == ""} {putquick "PRIVMSG $chan :\037ERROR\037: Incorrect Parameters. \037SYNTAX\037: [addTrigger]addgop nickname"; return}
  if {[validuser [nick2hand $gopadd]]} {putquick "PRIVMSG $chan :\037ERROR\037: $gopadd is already a valid user."; return}
  if {![onchan $gopadd $chan]} {putquick "PRIVMSG $chan :\037ERROR\037: $gopadd is not even on $chan ..."; return}
  set mask *!*@[lindex [split [getchanhost $gopadd $chan] @] 1]
  adduser $gopadd $mask
  chattr $gopadd +o
  putquick "NOTICE $nick :Added $gopadd to the Global OP List."
  putquick "NOTICE $gopadd :$nick ($hand) has added you to the Global OP List."
}

proc addcowner:pub {nick uhost hand chan arg} {
  if {![matchattr [nick2hand $nick] o]} {return}
  set cowneradd [lindex [split $arg] 0]
  if {[lindex [split $arg] 0] == ""} {putquick "PRIVMSG $chan :\037ERROR\037: Incorrect Parameters. \037SYNTAX\037: [addTrigger]addchanowner nickname"; return}
  if {[validuser [nick2hand $cowneradd]]} {putquick "PRIVMSG $chan :\037ERROR\037: $cowneradd is already a valid user."; return}
  if {![onchan $cowneradd $chan]} {putquick "PRIVMSG $chan :\037ERROR\037: $cowneradd is not even on $chan ..."; return}
  set mask *!*@[lindex [split [getchanhost $cowneradd $chan] @] 1]
  if {[onchan $cowneradd $chan] && ![isop $cowneradd $chan]} {putquick "MODE $chan +o $cowneradd"}
  adduser $cowneradd $mask
  chattr $cowneradd -|n $chan
  putquick "NOTICE $nick :Added $cowneradd to the Channel Owner List for $chan"
  putquick "NOTICE $cowneradd :$nick ($hand) has added you to the Channel Owner List for $chan"
}

proc addsop:pub {nick uhost hand chan arg} {
  if {![matchattr [nick2hand $nick] o|n $chan]} {return}
  set sopadd [lindex [split $arg] 0]
  if {[lindex [split $arg] 0] == ""} {putquick "PRIVMSG $chan :\037ERROR\037: Incorrect Parameters. \037SYNTAX\037: [addTrigger]addsop nickname"; return}
  if {[validuser [nick2hand $sopadd]]} {putquick "PRIVMSG $chan :\037ERROR\037: $sopadd is already a valid user."; return}
  if {![onchan $sopadd $chan]} {putquick "PRIVMSG $chan :\037ERROR\037: $sopadd is not even on $chan ..."; return}
  set mask *!*@[lindex [split [getchanhost $sopadd $chan] @] 1]
  if {[onchan $sopadd $chan] && ![isop $sopadd $chan]} {putquick "MODE $chan +o $sopadd"}
  adduser $sopadd $mask
  chattr $sopadd -|m $chan
  putquick "NOTICE $nick :Added $sopadd to the SOP List for $chan"
  putquick "NOTICE $sopadd :$nick ($hand) has added you to the SOP List for $chan"
}

proc delsop:pub {nick uhost hand chan arg} {
  if {![matchattr [nick2hand $nick] o|n $chan]} {return}
  set sopdel [lindex [split $arg] 0]
  if {[lindex [split $arg] 0] == ""} {putquick "PRIVMSG $chan :\037ERROR\037: Incorrect Parameters. \037SYNTAX\037: [addTrigger]delsop nickname"; return}
  if {![validuser [nick2hand $sopdel]]} {putquick "PRIVMSG $chan :\037ERROR\037: $sopdel is not a valid user."; return}
  if {[onchan $sopdel $chan] && [isop $sopdel $chan]} {putquick "MODE $chan -o $sopdel"}
  deluser $sopdel
  putquick "NOTICE $nick :Deleted $sopdel from the SOP List for $chan"
  putquick "NOTICE $sopdel :$nick ($hand) has deleted you from the SOP List for $chan"
}

proc addaop:pub {nick uhost hand chan arg} {
  if {![matchattr [nick2hand $nick] o|m $chan]} {return}
  set opadd [lindex [split $arg] 0]
  if {[lindex [split $arg] 0] == ""} {putquick "PRIVMSG $chan :\037ERROR\037: Incorrect Parameters. \037SYNTAX\037: [addTrigger]addaop nickname"; return}
  if {[validuser [nick2hand $opadd]]} {putquick "PRIVMSG $chan :\037ERROR\037: $opadd is already a valid user."; return}
  if {![onchan $opadd $chan]} {putquick "PRIVMSG $chan :\037ERROR\037: $opadd is not even on $chan ..."; return}
  set mask *!*@[lindex [split [getchanhost $opadd $chan] @] 1]
  if {[onchan $opadd $chan] && ![isop $opadd $chan]} {putquick "MODE $chan +o $opadd"}
  adduser $opadd $mask
  chattr $opadd -|o $chan
  putquick "NOTICE $nick :Added $opadd to the AOP List for $chan"
  putquick "NOTICE $opadd :$nick ($hand) has added you to the AOP List for $chan"
}

proc delaop:pub {nick uhost hand chan arg} {
  if {![matchattr [nick2hand $nick] o|m $chan]} {return}
  set opdel [lindex [split $arg] 0]
  if {[lindex [split $arg] 0] == ""} {putquick "PRIVMSG $chan :\037ERROR\037: Incorrect Parameters. \037SYNTAX\037: [addTrigger]delaop nickname"; return}
  if {![validuser [nick2hand $opdel]]} {putquick "PRIVMSG $chan :\037ERROR\037: $opdel is not a valid user."; return}
  if {[onchan $opdel $chan] && [isop $opdel $chan]} {putquick "MODE $chan -o $opdel"}
  deluser $opdel
  putquick "NOTICE $nick :Deleted $opdel from the AOP List for $chan"
  putquick "NOTICE $opdel :$nick ($hand) has deleted you from the AOP List for $chan"
}

proc addaov:pub {nick uhost hand chan arg} {
  if {![matchattr [nick2hand $nick] o|o $chan]} {return}
  set aovadd [lindex [split $arg] 0]
  if {[lindex [split $arg] 0] == ""} {putquick "PRIVMSG $chan :\037ERROR\037: Incorrect Parameters. \037SYNTAX\037: [addTrigger]addaov nickname"; return}
  if {[validuser [nick2hand $aovadd]]} {putquick "PRIVMSG $chan :\037ERROR\037: $aovadd is already a valid user."; return}
  set mask *!*@[lindex [split [getchanhost $aovadd $chan] @] 1]
  if {[onchan $aovadd $chan] && ![isvoice $aovadd $chan]} {putquick "MODE $chan +v $aovadd"}
  adduser $aovadd $mask
  chattr $aovadd -|gv $chan
  putquick "NOTICE $nick :Added $aovadd to the AOV List for $chan"
  putquick "NOTICE $aovadd :$nick ($hand) has added you to the AOV List for $chan"
}

proc delaov:pub {nick uhost hand chan arg} {
  if {![matchattr [nick2hand $nick] o|o $chan]} {return}
  set aovdel [lindex [split $arg] 0]
  if {[lindex [split $arg] 0] == ""} {putquick "PRIVMSG $chan :\037ERROR\037: Incorrect Parameters. \037SYNTAX\037: [addTrigger]delaov nickname"; return}
  if {![validuser [nick2hand $aovdel]]} {putquick "PRIVMSG $chan :\037ERROR\037: $aovdel is not a valid user."; return}
  if {[onchan $aovdel $chan] && [isvoice $aovdel $chan]} {putquick "MODE $chan -v $aovdel"}
  deluser $aovdel
  putquick "NOTICE $nick :Deleted $aovdel from the AOV List for $chan"
  putquick "NOTICE $aovdel :$nick ($hand) has deleted you from the AOV List for $chan"
}

proc jmode:pub {nick uhost hand chan arg} {
  if {![matchattr [nick2hand $nick] o|n $chan]} {return}
  if {[lindex [split $arg] 0] == ""} {putquick "PRIVMSG $chan :\037ERROR\037: Incorrect Parameters. \037SYNTAX\037: [addTrigger]joinmodes on|off"; return}

  if {[lindex [split $arg] 0] == "on"} {
    if {[channel get $chan joinmode]} {putquick "PRIVMSG $chan :\037ERROR\037: This setting is already enabled."; return}
    channel set $chan +joinmode
    putquick "PRIVMSG $chan :Enabled Auto @/+ Modes for $chan"
    return 0
  }

  if {[lindex [split $arg] 0] == "off"} {
    if {![channel get $chan joinmode]} {putquick "PRIVMSG $chan :\037ERROR\037: This setting is already disabled."; return}
    channel set $chan -joinmode
    puthelp "PRIVMSG $chan :Disabled Auto @/+ Modes for $chan"
  }
}

proc jmode:msg {nick uhost hand arg} {
  global botnick
  set chan [strlwr [lindex $arg 0]]
  if {![matchattr [nick2hand $nick] o|n $chan]} {return}
  if {([lindex [split $arg] 0] == "") && ([string match "*#*" $arg])} {putquick "NOTICE $nick :\037ERROR\037: Incorrect Parameters. \037SYNTAX\037: /msg $botnick joinmodes #channel on|off"; return}
  if {([lindex [split $arg] 1] == "") && ([string match "*#*" $arg])} {putquick "NOTICE $nick :\037ERROR\037: Incorrect Parameters. \037SYNTAX\037: /msg $botnick joinmodes $chan on|off"; return}

  if {([lindex [split $arg] 1] == "on") && ([string match "*#*" $arg])} {
    if {[channel get $chan joinmode]} {putquick "NOTICE $nick :\037ERROR\037: This setting is already enabled."; return}
    channel set $chan +joinmode
    putquick "NOTICE $nick :Enabled Auto @/+ Modes for $chan"
    return 0
  }

  if {([lindex [split $arg] 1] == "off") && ([string match "*#*" $arg])} {
    if {![channel get $chan joinmode]} {putquick "NOTICE $nick :\037ERROR\037: This setting is already disabled."; return}
    channel set $chan -joinmode
    putquick "NOTICE $nick :Disabled Auto @/+ Modes for $chan"
    return 0
  }
}

proc join:modes {nick uhost hand chan} {
  global botnick
  if {[string tolower $nick] != [string tolower $botnick]} {
    if {[channel get $chan joinmode] && [botisop $chan]} {

      if {[matchattr [nick2hand $nick] |n $chan]} {
        putquick "MODE $chan +o $nick"
        return 0
      }

      if {[matchattr [nick2hand $nick] |m $chan]} {
        putquick "MODE $chan +o $nick"
        return 0
      }

      if {[matchattr [nick2hand $nick] |o $chan]} {
        putquick "MODE $chan +o $nick"
        return 0
      }

      if {[matchattr [nick2hand $nick] |v $chan]} {
        putquick "MODE $chan +v $nick"
        return 0
      }
    }
  }
}

putlog "AddUSER+JoinMODEs: Module LOADED! - istok @ IRCSpeed"
