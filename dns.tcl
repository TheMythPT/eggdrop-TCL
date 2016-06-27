# $Id: dns.tcl,v 1.1 27/06/2016 20:55:13pm NZST (GMT+12) IRCSpeed Exp $

# Set your dns trigger here (default: !)
set dnsTrigger "!"

# Set access flags to use DNS (default: ovf|ovf - set to -|- for all)
set dnsFlags ovf|ovf

## CODE BLOCK ##
bind pub - ${dnsTrigger}dns lookup:dns

proc lookup:dns {nick uhost hand chan arg} {
  global dnsFlags
  if {![matchattr [nick2hand $nick] $dnsFlags $chan]} {return}
  if {[llength $arg] > 1} {return}
  if {[onchan $arg $chan]} {
    set hostip [eval exec host [lindex [split [getchanhost $arg $chan] @] 1]]
  } else {
  set hostip [eval exec host $arg]
  }
  foreach line [split $hostip \n] {
   puthelp "privmsg $chan :\002DNS Result\002: $line"
  }
 return 0
}

putlog ".:DNS Lookup:. Loaded - istok @ IRCSpeed"
