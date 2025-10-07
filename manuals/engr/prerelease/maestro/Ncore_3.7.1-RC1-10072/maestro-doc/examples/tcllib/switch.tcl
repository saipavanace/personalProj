package require Project 2.0

namespace eval Switch {
  namespace export create_units
  namespace export set_inputBufferDepth
  namespace export set_bufLayer0Depth
  namespace export set_bufferingType
  namespace export set_portDataWidth
  namespace export get_portDataWidth
  namespace export get_units

  set version 2.0
  set Description "Maestro_Switch"

  variable home [file join [pwd] [file dirname [info script]]]
  variable created_units [list]
}

proc Switch::create_units { n name designEnv } {
  set switches [list ]
  for {set i 0} {$i < $n} {incr i} {
	set obj [create_object -type "switch" -name $name$i]
	lappend switches $obj
  }
  return $switches
}

proc Switch::set_bufLayer0Depth { objList val} {
  puts "Warning: set_bufLayer0Depth will be deprecated, new usage is set_inputBufferDepth"
  Switch::set_inputBufferDepth $objList $val
}

proc Switch::set_inputBufferDepth { objList val} {
  foreach obj $objList {
    set attrKey inputBufferDepth
    set_attribute -object $obj -name $attrKey -value $val
  }
}

proc Switch::set_bufferingType { objList val} {
  foreach obj $objList {
    set attrKey bufferingType
    set_attribute -object $obj -name $attrKey -value $val
  }
}

proc Switch::set_portDataWidth { objList val} {
  set attrKey portDataWidth
  foreach obj $objList {
    set_attribute -object $obj -name $attrKey -value $val
  }
}

proc Switch::get_portDataWidth { objList } {
  set attrKey portDataWidth
  set res [list ]
  foreach obj $objList {
    lappend res [get_parameter -object $obj -name $attrKey]
  }
  return $res
}

proc Switch::get_units {netw} {
  set units       [list]
  set chip        [Project::get_chip]
  set topology    [Project::get_topology]

  set network [Project::getNetworkName $netw]

  if {$network == ""} {
    error "Error: Invalid network name passed. Must be dn, ndn1, ndn2 or ndn3."
  }

  set switches [get_objects -parent $chip -type "switch"]

  foreach sw $switches {
    set swnet [get_objects -parent $sw -type "network"]
    if {$swnet == $network} {
      lappend units $sw
    }
  }
  return $units
}

package provide Switch $Switch::version
package require Tcl 8.5
