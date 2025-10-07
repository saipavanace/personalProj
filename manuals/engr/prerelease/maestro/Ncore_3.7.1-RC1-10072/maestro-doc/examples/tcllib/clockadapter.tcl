namespace eval ClockAdapter {
  namespace export create_units
  namespace export set_syncDepth

  set version 2.0
  set Description "Maestro_ClockAdapter"

  variable home [file join [pwd] [file dirname [info script]]]
  variable created_units [list]
}

proc ClockAdapter::create_units { n name designEnv } {
  set pp [list ]
  for {set i 0} {$i < $n} {incr i} {
	set obj [create_object -type clock_adapter -name $name$i]
	lappend pp $obj
  }
  return $pp
}

proc ClockAdapter::get_units {netw} {
  set units       [list]
  set chip        [Project::get_chip]
  set topology    [Project::get_topology]

  set network [Project::getNetworkName $netw]

  if {$network == ""} {
    error "Error: Invalid network name passed. Must be dn, ndn1, ndn2, ndn3, csr_request_nw or csr_response_nw."
  }

  set adapters [get_objects -parent $chip -type "clock_adapter"]

  foreach a $adapters {
    set anet [get_objects -parent $a -type "network"]
    if {$anet == $network} {
      lappend units $a
    }
  }
  return $units
}

proc ClockAdapter::set_syncDepth { objList val } {
  foreach obj $objList {
    set attrKey syncDepth
    set_attribute -object $obj -name $attrKey -value $val
  }
}

package provide ClockAdapter $ClockAdapter::version
package require Tcl 8.5
