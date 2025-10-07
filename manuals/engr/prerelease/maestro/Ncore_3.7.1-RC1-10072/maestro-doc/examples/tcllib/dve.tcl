# *********************************************************************************************
#
# This script provides procedures to set parameters on the object of type "dve". 
# 
# *********************************************************************************************
package require Project 2.0

namespace eval Dve {
  namespace export set_TraceMem_memType
  namespace export add_TraceMem_signal
  namespace export set_nPerfCounters
  namespace export set_pre_map_unit_defaults
  namespace export set_unit_attribute
  namespace export get_unit_attribute
  namespace export get_units
  namespace export number_of_units
  namespace export get_all_units
  namespace export get_unit
  namespace export get_clock
  namespace export test

  set version 2.0
  set Description "Maestro_Dve"

  variable home [file join [pwd] [file dirname [info script]]]
  variable created_units [list]
}

proc Dve::set_TraceMem_memType { objList val} {
  set attrKey memoryType
  foreach obj $objList {
    set memList [get_objects -parent $obj -type internal_memory -subtype TRACE]
    foreach m $memList {
      set_attribute -object $m -name $attrKey -value $val
    }
  }
}

proc Dve::add_TraceMem_signal { objList name width direction} {
  foreach obj $objList {
    set memList [get_objects -parent $obj -type internal_memory -subtype TRACE]
    foreach m $memList {
        set rtlPrefix [Project::abbrev $m]
        set gp [create_object -type generic_port -parent $m -name $name]
        set_attribute -object $gp -name wireWidth -value $width
        set_attribute -object $gp -name direction -value $direction
    }
  }
}

# ***********************************************************************************************************
#
# Description:  Sets the value for the parameter "Number of performance counters".
#               The internal parameter name is "nPerfCounters".
# Argument:     List of objects of type "dve" and the value for the parameter "nPerfCounters".
# Return:       The value of the parameter "nPerfCounters" for the object of type "dve" is set.
# Example usage: Dve::set_nPerfCounters [Dve::get_all_units] 4
#
# ************************************************************************************************************
proc Dve::set_nPerfCounters { objList val} {
  foreach obj $objList {
    set attrKey nPerfCounters
    set_attribute -object $obj -name $attrKey -value $val
  }
}

proc Dve::set_unit_attribute { ind procFunc value } {
  set unit [Dve::get_unit $ind]
  if {$unit == "" } {
    return ""
  }
  set x [$procFunc $unit $value]
}

proc Dve::get_unit_attribute { ind procFunc } {
  set unit [Dve::get_unit $ind]
  if {$unit == "" } {
    return ""
  }
  set val [$procFunc $unit]
  return $val
}

proc Dve::number_of_units { } {
  set units [Dve::get_all_units]
  set val [llength $units]
  return $val
}

proc Dve::get_unit { indx } {
  set units [Dve::get_all_units]
  if {$indx < 0 || $indx >= [llength $units]} {
    return ""
  }
  set val [lindex $units $indx]
  return $val
}

proc Dve::get_all_units { } {
  set chip     [get_objects -type chip -parent root]
  set objects [get_objects -type dve -parent $chip]
  if {$objects == ""} {
    error "Error: There are no DVE units created. Please create the DVE units before assigning parameters to them."
  }
  return $objects
}

proc Dve::get_units { list_of_indices } {
  set units [list]
  set chip     [get_objects -type chip -parent root]
  foreach indx $list_of_indices {
    set objects [get_objects -type dve -parent $chip]
    set val [lindex $objects $indx]
    lappend units $val
  }
  return $units
}

proc Dve::get_clock { objList } {
  set clks [list]
  foreach unit $objList {
    set clk [get_objects -parent $unit -type clock_subdomain]
    lappend clks $clk
  }
  return $clks
}


package provide Dve $Dve::version
package require Tcl 8.5
