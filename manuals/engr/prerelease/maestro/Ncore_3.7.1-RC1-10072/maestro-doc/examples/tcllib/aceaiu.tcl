

namespace eval Aceaiu {
  namespace export set_pipeEnabled
  namespace export set_pipeDepth
  namespace export set_protocolType
  namespace export set_OttErrInfo
  namespace export set_OttMem_memoryType
  namespace export set_OttMem_strRtlNamePrefix

  namespace export get_pipeEnabled
  namespace export get_pipeDepth
  namespace export get_protocolType
  namespace export get_OttErrInfo
  namespace export get_OttMem_memoryType
  namespace export get_OttMem_strRtlNamePrefix

  namespace export set_unit_attribute
  namespace export get_unit_attribute
  namespace export get_units
  namespace export number_of_units
  namespace export get_all_units
  namespace export get_unit
  namespace export set_clock
  namespace export get_clock
  namespace export test
  namespace export set_wData_of_NativeInterface
  namespace export set_wAddr_of_NativeInterface

  set version 2.0
  set Description "Maestro_Aceaiu"

  variable home [file join [pwd] [file dirname [info script]]]
  variable created_units [list]
}

proc Aceaiu::set_protocolType { objList val} {
  foreach obj $objList {
    set attrKey protocolType
    set socket [get_objects -parent $obj -type socket]
    set_attribute -object $socket -name $attrKey -value $val
  }
}

proc Aceaiu::set_OttErrInfo { objList val} {
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey OttErrInfo
    set_attribute -object $obj -name $attrKey -value $val
  }
}

proc Aceaiu::set_OttMem_memoryType { objList val} {
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey MemoryInterfaces.OttMem.MemType
    set_attribute -object $obj -name $attrKey -value $val
  }
}

proc Aceaiu::set_OttMem_strRtlNamePrefix { objList val} {
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey MemoryInterfaces.OttMem.rtlPrefixString
    set_attribute -object $obj -name $attrKey -value $val
  }
}

proc Aceaiu::get_protocolType { obj } {
  set socket [get_objects -parent $obj -type socket]
  set attrKey protocolType
  set v [get_parameter -object $socket -name $attrKey]
  return $v
}

proc Aceaiu::get_OttErrInfo { objList } {
  set valList [list ]
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey OttErrInfo
    set v [get_parameter -object $obj -name $attrKey]
    lappend valList $v
  }
  return $valList
}

proc Aceaiu::get_OttMem_memoryType { objList } {
  set valList [list ]
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey OttMem_memoryType
    set v [get_parameter -object $obj -name $attrKey]
    lappend valList $v
  }
  return $valList
}

proc Aceaiu::get_OttMem_strRtlNamePrefix { objList } {
  set valList [list ]
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey OttMem_strRtlNamePrefix
    set v [get_parameter -object $obj -name $attrKey]
    lappend valList $v
  }
  return $valList
}

proc Aceaiu::set_unit_attribute { ind procFunc value } {
  set unit [lindex $Aceaiu::created_units $ind]
  set x [$procFunc $unit $value]
}

proc Aceaiu::get_unit_attribute { ind procFunc } {
  set unit [lindex $Aceaiu::created_units $ind]
  set val [$procFunc $unit]
  return $val
}

proc Aceaiu::number_of_units { } {
  set val [llength $Aceaiu::created_units]
  return $val
}

proc Aceaiu::get_unit { indx } {
  if {$indx < 0 || $indx >= [llength $Aceaiu::created_units]} {
    return ""
  }
  set val [lindex $Aceaiu::created_units $indx]
  return $val
}

proc Aceaiu::set_clock { objList clk } {
  foreach unit $objList {
    update_object -name $unit -bind $clk -type "domain"
  }
}

proc Aceaiu::get_clock { objList } {
  set clks [list]
  foreach unit $objList {
    set clk [get_objects -parent $unit -type clock_subdomain]
    lappend clks $clk
  }
  return $clks
}

proc Aceaiu::get_all_units { } {
  return $Aceaiu::created_units
}

proc Aceaiu::get_units { list_of_indices } {
  set units [list]
  foreach indx $list_of_indices {
    set val [lindex $Aceaiu::created_units $indx]
    lappend units $val
  }
  return $units
}

proc Aceaiu::set_wData_of_NativeInterface { objList val } {
  foreach obj $objList {
    set socket   [get_objects -parent $obj -type socket]
    set protocol [Caiu::get_protocolType $obj]
    if {$protocol == "ACE"} {
      Socket_ACE::set_wData $socket $val
    }
  }
}
proc Aceaiu::set_wAddr_of_NativeInterface {objList val} {
  foreach obj $objList {
    set socket   [get_objects -parent $obj -type socket]
    set protocol [Caiu::get_protocolType $obj]
    if {$protocol == "ACE"} {
      Socket_ACE::set_wAddr $socket $val
    }
  }
}

package provide Aceaiu $Aceaiu::version
package require Tcl 8.5
