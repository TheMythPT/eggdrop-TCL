# $Id: translate.tcl,v1.7 16/01/2016 09:25:31am GMT +13 (NZ-DST) IRCSpeed Exp $

# This is a google translate script, using the translate API. This requires a working API key, as google now charge for their usage.
# If you have a working key, please feel free to download/use this code, or edit it as needed.

# Commands:
# !translate on|off
# !translate langto <the language text you wish to convert>
# example: !translate en Kon'nichiwa, genkidesuka?

# Feel free to edit this setting. Change the ! to any character you would like as a trigger.
set transpubtrig "!"

# Set here what flags you wish to allow and trigger this script (leave it "" for anyone)
set transglobflags "ovf"
set transchanflags "ovf"

# Set google translate API key here.
set transapikey "your-working-API-key-here"

########## ----- NO EDITING BELOW ----- ##########
namespace eval gTranslator {
  
  proc getJson url {
    set tok [http::geturl $url]
    set res [json::json2dict [http::data $tok]]
    http::cleanup $tok
    return $res
  }
  
  proc decodeEntities str {
    set str [string map {\[ {\[} \] {\]} \$ {\$} \\ \\\\} $str]
    subst [regsub -all {&#(\d+);} $str {[format %c \1]}]
  }
  
  proc getTrig {} {
    global transpubtrig
    return $transpubtrig
  }
  
  setudef flag translator
  
  bind pub - ${transpubtrig}translate gTranslator::translate
  proc translate {nick uhost hand chan arg} {
    global transglobflags transchanflags transapikey
    package require http
    package require tls
    ::http::register https 443 ::tls::socket
    package require json
    if {![matchattr [nick2hand $nick] $transglobflags|$transchanflags $chan]} {return}
    if {$arg == ""} {
      putquick "PRIVMSG $chan :\037ERROR\037: Incorrect Parameters. \037SYNTAX\037: [getTrig]translate on|off - [getTrig]translate langto <text to translate>";
      return
    }
    set args [split $arg]
    set arg0 [lindex $args 0]
    if {$arg0 == "on"} {
      if {[channel get $chan translator]} {
        putquick "PRIVMSG $chan :\037ERROR\037: This setting is already enabled.";
        return
      }
      channel set $chan +translator
      puthelp "PRIVMSG $chan :Enabled Translator Module for $chan"
      return 0
   }
  
    if {$arg0 == "off"} {
      if {![channel get $chan translator]} {
        putquick "PRIVMSG $chan :\037ERROR\037: This setting is already disabled.";
        return
      }
      channel set $chan -translator
      puthelp "PRIVMSG $chan :Disabled Translator Module for $chan"
      return 0
   }
  
    if {![channel get $chan translator]} {
      putquick "PRIVMSG $chan :\037ERROR\037: Translator is not enabled for $chan \037SYNTAX\037: [getTrig]translate on|off";
      return
    }
    set lngto [string tolower $arg0]
    if {$lngto == ""} {
      putquick "PRIVMSG $chan :\037ERROR\037: Incorrect Parameters. \037SYNTAX\037: [getTrig]translate langto <text to translate>";
      return
    }
    set text [http::formatQuery q [join [lrange $args 1 end]]]
    set dturl "https://www.googleapis.com/language/translate/v2?key=$transapikey&target=$lngto&q=$text"
    set json [getJson $dturl]
    if {[dict exists $json error]} {
      foreach err [dict get $json error errors] {
        putserv "PRIVMSG $chan :\002Error\002 in JSON: [dict get $err message]"
      }
      return 0
    }
    set lng [dict get $json responseData language]
    if {$lng == $lngto} {
      putserv "PRIVMSG $chan :\002Error\002 translating $lng to $lngto."
      return 0
    }
    set trurl "https://www.googleapis.com/language/translate/v2?key=$transapikey&source=$lng&target=$lngto&q=$text"
    set res [getJson $trurl]
    set translated [decodeEntities [dict get $res responseData translatedText]]
    putserv "PRIVMSG $chan :\002Translated\002: [encoding convertto utf-8 $translated]"
    return 0
  }
  putlog ".:LOADED:. translate.tcl,v1.7"
}
