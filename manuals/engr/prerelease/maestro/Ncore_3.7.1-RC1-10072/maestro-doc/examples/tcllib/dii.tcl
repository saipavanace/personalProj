# *********************************************************************************************
#
# This script provides procedures to set parameters on the object of type "dii". 
# 
# *********************************************************************************************
package require Project 2.0

namespace eval Dii {
  namespace export set_createdUnits
  namespace export set_pipeEnabled
  namespace export set_pipeDepth
  namespace export set_protocolType
  namespace export set_wLargestEndPoint
  namespace export set_nPerfCounters
  namespace export set_nAddrTransRegisters
  namespace export set_nUnitTraceBufSize
  namespace export set_readBufferDepth
  namespace export set_nRttCtrlEntries
  namespace export set_nWttCtrlEntries
  namespace export set_readBufferErrorInfo
  namespace export set_DataMem_MemType

  namespace export get_pipeEnabled
  namespace export get_pipeDepth
  namespace export get_protocolType
  namespace export get_nAddrTransRegisters
  namespace export get_wLargestEndPoint
  namespace export get_readBufferDepth
  namespace export get_nRttCtrlEntries
  namespace export get_nWttCtrlEntries
  namespace export get_readBufferErrorInfo
  namespace export get_DataMem_MemType

  namespace export set_unit_attribute
  namespace export get_unit_attribute
  namespace export get_units
  namespace export number_of_units
  namespace export get_all_units
  namespace export get_unit
  namespace export set_clock
  namespace export get_clock
  namespace export test
  namespace export add_placeholder_signal

  set version 2.0
  set Description "Maestro_Dii"

  variable home [file join [pwd] [file dirname [info script]]]
  variable created_units [list]
}


proc Dii::set_createdUnits { units } {
  set Dii::created_units $units
  return [llength $Dii::created_units]
}


# ***********************************************************************************************************
#
# Description:  Sets the value for the parameter "Number of DII write buffers".
#               The internal parameter name is "nDmiRbCredits".
# Argument:     List of objects of type "dii" and the value for the parameter "nDiiRbCredits".
# Return:       The value of the parameter "nDiiRbCredits" for the object of type "dii" is set.
# Example usage: Dii::set_nDiiRbCredits [Dii::get_all_units] 16
#
# ************************************************************************************************************
proc Dii::set_nDiiRbCredits { objList val} {
  if {[info exists ::_skip_depreciated_] && ($::_skip_depreciated_ == 1)} {return}
  foreach obj $objList {
    set attrKey nDiiRbCredits
    set_attribute -object $obj -name $attrKey -value $val
  }
}

# ***********************************************************************************************************
#
# Description:  Sets the value for the parameter "Max Outstanding read transaction".
#               The internal parameter name is "nRttCtrlEntries".
# Argument:     List of objects of type "dmi" and the value for the parameter "nRttCtrlEntries".
# Return:       The value of the parameter "nRttCtrlEntries" for the object of type "dii" is set.
# Example usage: Dii::set_nRttCtrlEntries [Dii::get_all_units] 16
#
# ************************************************************************************************************
proc Dii::set_nRttCtrlEntries { objList val} {
  if {[info exists ::_skip_depreciated_] && ($::_skip_depreciated_ == 1)} {return}
  foreach obj $objList {
    set attrKey nRttCtrlEntries
    set_attribute -object $obj -name $attrKey -value $val
  }
}

# ***********************************************************************************************************
#
# Description:  Sets the value for the parameter "Max Outstanding write transaction".
#               The internal parameter name is "nWttCtrlEntries".
# Argument:     List of objects of type "dii" and the value for the parameter "nWttCtrlEntries".
# Return:       The value of the parameter "nWttCtrlEntries" for the object of type "dii" is set.
# Example usage: Dii::set_nWttCtrlEntries [Dii::get_all_units] 16
#
# ************************************************************************************************************
proc Dii::set_nWttCtrlEntries { objList val} {
  if {[info exists ::_skip_depreciated_] && ($::_skip_depreciated_ == 1)} {return}
  foreach obj $objList {
    set attrKey nWttCtrlEntries
    set_attribute -object $obj -name $attrKey -value $val
  }
}

# ***********************************************************************************************************
#
# Description:  Add placeholder signal to the "dii" unit.
# Argument:     The object of type "dmi", the name for the rtlprefix, the name of the placeholder signal,
#               the width of the placeholder signal, the direction of the placeholder signal.
# Example usage: Dii::add_placeholder_signal  [Dii::get_units {0}] "dii1_ph" "sig1" 4 IN
#
# ************************************************************************************************************
# proc Dii::add_placeholder_signal { obj rtlprefix name width direction } {
#   set placeholders [get_objects -type placeholder -parent $obj]
#   set len   [llength $placeholders]
#   if { $len > 0 } {
#     set placeholder [lindex $placeholders 0]
#     set gp [create_object -type generic_port -parent $placeholder -name $name]
#     set_attribute -object $gp -name wireWidth -value $width 
#     set_attribute -object $gp -name direction -value $direction

#     rename_object -name $placeholder -new_name $rtlprefix
#   }
# }
proc Dii::add_placeholder_signal { obj rtlprefix name width direction } {
  set pl $obj/placeholder
  set gp [create_object -type generic_port -parent $pl -name $name]
  set_attribute -object $pl -name wireRtlPrefix -value $rtlprefix
  set_attribute -object $gp -name wireWidth -value $width 
  set_attribute -object $gp -name direction -value $direction
}

# ********************************************************************************************************
#
# Description: This proc is used to set the Size of the largest end point. 
# Argument:    List of objects of type "dii" and the value for the parameter "nLargestEndPoint".
# Example :    Dii::set_wLargestEndPoint [Dii::get_units {0}] 4
#
# ********************************************************************************************************
# $val in kb. If user has 40 bits, (2^40) / 1024 = (2^40)/(2^10) = 2^(40-10)= 1073741824 kb
proc Dii::set_wLargestEndPoint { objList val {valUnit ""} } {
  set newVal $val
  if { ($valUnit == "kb") || ($valUnit == "kB") } {
    set newVal $val
  }
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey nLargestEndPoint
    set_attribute -object $obj -name $attrKey -value $newVal
  }
}

# ***********************************************************************************************************
#
# Description:  Sets the value for the parameter "Number of performance counters".
#               The internal parameter name is "nPerfCounters".
# Argument:     List of objects of type "dii" and the value for the parameter "nPerfCounters".
# Return:       The value of the parameter "nPerfCounters" for the object of type "dii" is set.
# Example usage: Dii::set_nPerfCounters [Dii::get_all_units] 4
#
# ************************************************************************************************************
proc Dii::set_nPerfCounters { objList val} {
  foreach obj $objList {
    set attrKey nPerfCounters
    set_attribute -object $obj -name $attrKey -value $val
  }
}

# ***********************************************************************************************************
#
# Description:  Sets the value for the parameter "Total depth of the Skid Buffer".
#               The internal parameter name is "nCMDSkidBufSize".
# Argument:     List of objects of type "dmi" and the value for the parameter "nCMDSkidBufSize".
# Return:       The value of the parameter "nCMDSkidBufSize" for the object of type "dii" is set.
# Example usage: Dii::set_nCMDSkidBufSize [Dii::get_all_units] 4
#
# ************************************************************************************************************
proc Dii::set_nCMDSkidBufSize { objList val } {
  foreach obj $objList {
    set attrKey nCMDSkidBufSize
    set_attribute -object $obj -name $attrKey -value $val
  }
}

# ***********************************************************************************************************
#
# Description:  Sets the value for the parameter "Depth of skid buffer visible to arbitration".
#               The internal parameter name is "nCMDSkidBufArb".
# Argument:     List of objects of type "dmi" and the value for the parameter "nCMDSkidBufArb".
# Return:       The value of the parameter "nCMDSkidBufArb" for the object of type "dii" is set.
# Example usage: Dii::set_nCMDSkidBufArb [Dii::get_all_units] 4
#
# ************************************************************************************************************
proc Dii::set_nCMDSkidBufArb { objList val } {
  foreach obj $objList {
    set attrKey nCMDSkidBufArb
    set_attribute -object $obj -name $attrKey -value $val
  }
}

# ********************************************************************************************************
#
# Description: This proc is used to set the Number of Address Translation Registers. 
# Argument:    List of objects of type "dmi" and the value for the parameter "nAddrTransRegisters".
# Example :    Dii::set_nAddrTransRegisters [Dii::get_units {0}] 4
#
# ********************************************************************************************************
proc Dii::set_nAddrTransRegisters { objList val} {
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey ImplementationParameters/nAddrTransRegisters
    set_attribute -object $obj -name $attrKey -value $val
  }
}

# ***********************************************************************************************************
#
# Description:   Sets the value for the parameter "Unit Trace Buffer Size".
#                The internal parameter name is "nUnitTraceBufSize".
# Argument:      List of objects of type "dii" and the value for the parameter "nUnitTraceBufSize".
# Example usage: Dii::set_nUnitTraceBufSize [Dii::get_units {1}] 8
#
# ************************************************************************************************************

proc Dii::set_nUnitTraceBufSize { val} {
  set obj [_getTopology]
  set attrKey nUnitTraceBufSize
  set_attribute -object $obj -name $attrKey -value $val
}

proc Dii::set_DataMem_MemType { objList val} {
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey MemoryInterfaces/DataMem/MemType
    set_attribute -object $obj -name $attrKey -value $val
  }
}

proc Dii::set_DataMem_rtlPrefixString { objList val} {
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey MemoryInterfaces/DataMem/rtlPrefixString
    set_attribute -object $obj -name $attrKey -value $val
  }
}


proc Dii::get_wLargestEndPoint { objList } {
  set valList [list ]
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey nLargestEndPoint
    set v [get_parameter -object $obj -name $attrKey]
    lappend valList $v
  }
  return $valList
}

proc Dii::get_nAddrTransRegisters { objList } {
  set valList [list ]
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey ImplementationParameters/nAddrTransRegisters
    set v [get_parameter -object $obj -name $attrKey]
    lappend valList $v
  }
  return $valList
}

proc Dii::get_nRttCtrlEntries { objList } {
  set valList [list ]
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey nRttCtrlEntries
    set v [get_parameter -object $obj -name $attrKey]
    lappend valList $v
  }
  return $valList
}

proc Dii::get_nWttCtrlEntries { objList } {
  set valList [list ]
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey nWttCtrlEntries
    set v [get_parameter -object $obj -name $attrKey]
    lappend valList $v
  }
  return $valList
}

proc Dii::get_DataMem_MemType { objList } {
  set valList [list ]
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey DataMem_MemType
    set v [get_parameter -object $obj -name $attrKey]
    lappend valList $v
  }
  return $valList
}

proc Dii::get_DataMem_rtlPrefixString { objList } {
  set valList [list ]
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey DataMem_rtlPrefixString
    set v [get_parameter -object $obj -name $attrKey]
    lappend valList $v
  }
  return $valList
}

proc Dii::set_unit_attribute { ind procFunc value } {
  set unit [Dii::get_unit $ind]
  if {$unit == "" } {
    return ""
  }
  set x [$procFunc $unit $value]
}

proc Dii::get_unit_attribute { ind procFunc } {
  set unit [Dii::get_unit $ind]
  if {$unit == "" } {
    return ""
  }
  set val [$procFunc $unit]
  return $val
}

proc Dii::number_of_units { } {
  set units [Dii::get_all_units]
  set val [llength $units]
  return $val
}

proc Dii::get_unit { indx } {
  set units [Dii::get_all_units]
  if {$indx < 0 || $indx >= [llength $units]} {
    return ""
  }
  set val [lindex $units $indx]
  return $val
}

proc Dii::set_clock { objList clk } {
  foreach unit $objList {
    update_object -name $unit -bind $clk -type "domain"
  }
}

proc Dii::get_clock { objList } {
  set clks [list]
  foreach unit $objList {
    set clk [get_objects -parent $unit -type clock_subdomain]
    lappend clks $clk
  }
  return $clks
}

proc Dii::get_all_units { } {
  set chip     [get_objects -type chip -parent root]
  set objects [get_objects -type dii -parent $chip]
  if {$objects == "project/chip/system/subsystem/topology/cni_sys_dii/sys_dii"} {
    puts "Dii are $objects"
    puts "There are no user DII units created."
  }
  return $objects
}

proc Dii::get_units { list_of_indices } {
  set units [list]
  set chip     [get_objects -type chip -parent root]
  foreach indx $list_of_indices {
    set objects [get_objects -type dii -parent $chip]
    set val [lindex $objects $indx]
    lappend units $val
  }
  return $units
}


package provide Dii $Dii::version
package require Tcl 8.5
