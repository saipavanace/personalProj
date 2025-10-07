
# *********************************************************************************************
#
# This script provides procedures to set parameters on the object of type "caiu". 
# 
# *********************************************************************************************
package require Project 2.0

namespace eval Caiu {
  namespace export set_createdUnits
  namespace export set_pipeEnabled
  namespace export set_pipeDepth
  namespace export set_socketFunction
  namespace export set_protocolType
  namespace export set_AxIdProcSelectBits
  namespace export set_nProcs
  namespace export set_nPerfCounters
  namespace export set_nUnitTraceBufSize
  namespace export set_fnCsrAccess
  namespace export set_OttErrInfo
  namespace export set_OttMem_memType
  namespace export set_OttMem_rtlPrefix
  namespace export add_OttMem_signal
  namespace export assign_snoopFilter

  namespace export get_pipeEnabled
  namespace export get_pipeDepth
  namespace export get_socketFunction
  namespace export get_protocolType
  namespace export get_nProcs

  namespace export set_unit_attribute
  namespace export get_unit_attribute
  namespace export get_units
  namespace export number_of_units
  namespace export get_all_units
  namespace export get_unit
  namespace export set_clock
  namespace export get_clock
  namespace export test
  namespace export set_debug
  namespace export get_debug
  namespace export add_placeholder_signal
  namespace export add_chi_async_adapter 

  set version 2.0
  set Description "Maestro_Caiu"

  variable home [file join [pwd] [file dirname [info script]]]
  variable created_units [list]
  variable debug 0
}

proc Caiu::set_createdUnits { units } {
  set Caiu::created_units $units
  return [llength $Caiu::created_units]
}

# ***********************************************************************************************************
#
# Description:  Sets the value for the parameter "Credits for Native Protocol".
#               The internal parameter name is "nNativeCredits".
# Argument:     List of objects of type "caiu" and the value for the parameter "nNativeCredits".
# Return:       The value of the parameter "nNativeCredits" for the object of type "caiu" is set.
# Example usage: Caiu::set_nNativeCredits [Caiu::get_all_units] 15
#
# ************************************************************************************************************
proc Caiu::set_nNativeCredits { objList val} {
  foreach obj $objList {
    set attrKey nNativeCredits
    set_attribute -object $obj -name $attrKey -value $val
  }
}

# ***********************************************************************************************************
#
# Description:  Sets the value for the parameter "Outstanding transaction table Entries".
#               The internal parameter name is "nOttCtrlEntries".
# Argument:     List of objects of type "caiu" and the value for the parameter "nOttCtrlEntries".
# Return:       The value of the parameter "nOttCtrlEntries" for the object of type "caiu" is set.
# Example usage: Caiu::set_nOttCtrlEntries [Caiu::get_all_units] 48
#
# ************************************************************************************************************
proc Caiu::set_nOttCtrlEntries { objList val} {
  foreach obj $objList {
    set attrKey nOttCtrlEntries
    set_attribute -object $obj -name $attrKey -value $val
  }
}

# ***********************************************************************************************************
#
# Description:  Sets the value for the parameter "Credits per DCE Command Request".
#               The internal parameter name is "nDceCmdCredits".
# Argument:     List of objects of type "caiu" and the value for the parameter "nDceCmdCredits".
# Return:       The value of the parameter "nOttCtrlEntries" for the object of type "caiu" is set.
# Example usage: Caiu::set_nDceCmdCredits [Caiu::get_all_units] 48
#
# ************************************************************************************************************
proc Caiu::set_nDceCmdCredits { objList val} {
  foreach obj $objList {
    set attrKey nDceCmdCredits
    set_attribute -object $obj -name $attrKey -value $val
  }
}

# ***********************************************************************************************************
#
# Description:  Sets the value for the parameter "Credits per DMI Command Request".
#               The internal parameter name is "nDmiCmdCredits".
# Argument:     List of objects of type "caiu" and the value for the parameter "nDmiCmdCredits".
# Return:       The value of the parameter "nDmiCmdEntries" for the object of type "caiu" is set.
# Example usage: Caiu::set_nDmiCmdCredits [Caiu::get_all_units] 8
#
# ************************************************************************************************************
proc Caiu::set_nDmiCmdCredits { objList val} {
  foreach obj $objList {
    set attrKey nDmiCmdCredits
    set_attribute -object $obj -name $attrKey -value $val
  }
}

# ***********************************************************************************************************
#
# Description:  Sets the value for the parameter "Credits per DII Command Request".
#               The internal parameter name is "nDceCmdCredits".
# Argument:     List of objects of type "caiu" and the value for the parameter "nDiiCmdCredits".
# Return:       The value of the parameter "nDiiCmdCredits" for the object of type "caiu" is set.
# Example usage: Caiu::set_nDiiCmdCredits [Caiu::get_all_units] 4
#
# ************************************************************************************************************
proc Caiu::set_nDiiCmdCredits { objList val} {
  foreach obj $objList {
    set attrKey nDiiCmdCredits
    set_attribute -object $obj -name $attrKey -value $val
  }
}

# ***********************************************************************************************************
#
# Description:  Sets the value for the parameter "Stashing Snoop Credits".
#               The internal parameter name is "nStshSnpCredits".
# Argument:     List of objects of type "caiu" and the value for the parameter "nStshSnpCredits".
# Return:       The value of the parameter "nStshSnpCredits" for the object of type "caiu" is set.
# Example usage: Caiu::set_nStshSnpCredits [Caiu::get_all_units] 4
#
# ************************************************************************************************************
proc Caiu::set_nStshSnpCredits { objList val} {
  foreach obj $objList {
    set attrKey nStshSnpCredits
    set_attribute -object $obj -name $attrKey -value $val
  }
}

# ***********************************************************************************************************
#
# Description:  Add placeholder signal to the "caiu" unit.
# Argument:     The object of type "caiu", the name for the rtlprefix, the name of the placeholder signal,
#               the width of the placeholder signal, the direction of the placeholder signal.
# Example usage: Caiu::add_placeholder_signal  [Caiu::get_units {0}] "caiu1_ph" "sig1" 4 IN
#
# ************************************************************************************************************
# proc Caiu::add_placeholder_signal { obj rtlprefix name width direction } {
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
proc Caiu::add_placeholder_signal { obj rtlprefix name width direction } {
  set pl $obj/placeholder
  set gp [create_object -type generic_port -parent $pl -name $name]
  set_attribute -object $pl -name wireRtlPrefix -value $rtlprefix
  set_attribute -object $gp -name wireWidth -value $width 
  set_attribute -object $gp -name direction -value $direction
}

# ***********************************************************************************************************
#
# Description:  Sets the value for the parameter "Number of Processors".
#               The internal parameter name is "nProcessors".
# Argument:     List of objects of type "caiu" and the value for the parameter "nProcessors".
# Return:       The value of the parameter "nProcessors" for the object of type "caiu" is set.
# Example usage: Caiu::set_nProcs [Caiu::get_all_units] 4
#
# ************************************************************************************************************
proc Caiu::set_nProcs { objList val} {
  foreach obj $objList {
    set attrKey nProcessors
    set_attribute -object $obj -name $attrKey -value $val
  }
}

# ***********************************************************************************************************
#
# Description:  Sets the value for the parameter "Number of performance counters".
#               The internal parameter name is "nPerfCounters".
# Argument:     List of objects of type "caiu" and the value for the parameter "nPerfCounters".
# Return:       The value of the parameter "nPerfCounters" for the object of type "caiu" is set.
# Example usage: Caiu::set_nPerfCounters [Caiu::get_all_units] 4
#
# ************************************************************************************************************
proc Caiu::set_nPerfCounters { objList val} {
  foreach obj $objList {
    set attrKey nPerfCounters
    set_attribute -object $obj -name $attrKey -value $val
  }
}

# ***********************************************************************************************************
#
# Description:   Sets the value for the parameter "Unit Trace Buffer Size".
#                The internal parameter name is "nUnitTraceBufSize".
# Argument:      List of objects of type "caiu" and the value for the parameter "nUnitTraceBufSize".
# Example usage: Caiu::set_nUnitTraceBufSize [Caiu::get_units {1}] 8
#
# ************************************************************************************************************

proc Caiu::set_nUnitTraceBufSize { val} {
  set obj [_getTopology]
  set attrKey nUnitTraceBufSize
  set_attribute -object $obj -name $attrKey -value $val
}

# ***********************************************************************************************************
#
# Description:  Sets the value for the parameter "Enable CSR Access".
#               The internal parameter name is "fnCsrAccess".
# Argument:     List of objects of type "caiu" and the value for the parameter "fnCsrAccess".
# Return:       The value of the parameter "fnCsrAccess" for the object of type "caiu" is set.
# Example usage: Caiu::set_fnCsrAccess [Caiu::get_all_units] true
#
# ************************************************************************************************************
proc Caiu::set_fnCsrAccess { objList val} {
  foreach obj $objList {
    set attrKey fnCsrAccess
    set_attribute -object $obj -name $attrKey -value $val
  }
}

# ***********************************************************************************************************
#
# Description:  This parameter is only set when the object of type "caiu" has a socket of protocol type "ACE".
#               The internal parameter name is "AxIdProcSelectBits". This parameter is set after the mapping stage. 
# Argument:     List of objects of type "caiu" and the value for the parameter "AxIdProcSelectBits".
# Return:       The value of the parameter "AxIdProcSelectBits" for the object of type "caiu" is set.
# Example usage: Caiu::set_AxIdProcSelectBits [Caiu::get_all_units] 4
#
# ************************************************************************************************************

proc Caiu::set_AxIdProcSelectBits { objList val} {
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey AxIdProcSelectBits
    set_attribute -object $obj -name $attrKey -value_list $val
    if {$Caiu::debug == 1} { puts "# Setting attribute 'AxIdProcSelectBits' ( $attrKey ) with value '$val' on object '$obj'" }
  }
}

# ***********************************************************************************************************
#
# Description: Assigns the snoopFilter to the object "caiu".
#               The internal reference name is "snoopFilter"
# Argument:     List of objects of type "caiu" and the Snoop Filter object.
# Return:       The value of the parameter "snoopFilter" for the object of type "caiu" is set.
# Example usage: Caiu::assign_snoopFilter [Caiu::get_units {1}] [SnoopFilter::get_units {0}]
#
# ************************************************************************************************************
proc Caiu::assign_snoopFilter { objList snoopFilter } {
  foreach obj $objList {
    update_object -name $obj -type "snoopFilter" -bind $snoopFilter
  }
}

proc Caiu::get_nNativeCredits { objList } {
  set valList [list ]
  foreach obj $objList {
    set attrKey nNativeCredits
    set v [get_parameter -object $obj -name $attrKey]
    lappend valList $v
  }
  return $valList
}

proc Caiu::get_nOttCtrlEntries { objList } {
  set valList [list ]
  foreach obj $objList {
    set attrKey nOttCtrlEntries
    set v [get_parameter -object $obj -name $attrKey]
    lappend valList $v
  }
  return $valList
}

proc Caiu::get_nDceCmdCredits { objList } {
  set valList [list ]
  foreach obj $objList {
    set attrKey nDceCmdCredits
    set v [get_parameter -object $obj -name $attrKey]
    lappend valList $v
  }
  return $valList
}

proc Caiu::get_nDmiCmdCredits { objList } {
  set valList [list ]
  foreach obj $objList {
    set attrKey nDmiCmdCredits
    set v [get_parameter -object $obj -name $attrKey]
    lappend valList $v
  }
  return $valList
}

proc Caiu::get_nDiiCmdCredits { objList } {
  set valList [list ]
  foreach obj $objList {
    set attrKey nDiiCmdCredits
    set v [get_parameter -object $obj -name $attrKey]
    lappend valList $v
  }
  return $valList
}

proc Caiu::get_nStshSnpCredits { objList } {
  set valList [list ]
  foreach obj $objList {
    set attrKey nStshSnpCredits
    set v [get_parameter -object $obj -name $attrKey]
    lappend valList $v
  }
  return $valList
}

proc Caiu::get_protocolType { obj } {
  set socket [get_objects -parent $obj -type socket]
  set attrKey protocolType
  set v [get_parameter -object $socket -name $attrKey]
  return $v
}

proc Caiu::get_nProcs { objList } {
  set valList [list ]
  foreach obj $objList {
    set attrKey nProcessors
    set v [get_parameter -object $obj -name $attrKey]
    lappend valList $v
  }
  return $valList
}

proc Caiu::set_OttMem_memType { objList val} {
  set attrKey memoryType
  foreach obj $objList {
    set memList [get_objects -parent $obj -type internal_memory -subtype OTT]
    foreach m $memList {
        set_attribute -object $m -name $attrKey -value $val
    }
  }
}

proc Caiu::set_OttMem_rtlPrefix { objList val} {
  foreach obj $objList {
    set memList [get_objects -parent $obj -type internal_memory -subtype OTT]
    set i 0
    foreach m $memList {
        rename_object -name $m -new_name $val$i
        incr i
    }
  }
}

proc Caiu::add_OttMem_signal { objList name width direction} {
  foreach obj $objList {
    set memList [get_objects -parent $obj -type internal_memory -subtype OTT]
    foreach m $memList {
        set rtlPrefix [Project::abbrev $m]
        set gp [create_object -type generic_port -parent $m -name $name]
        set_attribute -object $gp -name wireWidth -value $width
        set_attribute -object $gp -name direction -value $direction
    }
  }
}

proc Caiu::set_unit_attribute { ind procFunc value } {
  set unit [Caiu::get_unit $ind]
  if {$unit == "" } {
    return ""
  }
  set x [$procFunc $unit $value]
}

proc Caiu::get_unit_attribute { ind procFunc } {
  set unit [Caiu::get_unit $ind]
  if {$unit == "" } {
    return ""
  }
  set val [$procFunc $unit]
  return $val
}

proc Caiu::number_of_units { } {
  set caius [Caiu::get_all_units]
  set val   [llength $caius]
  return $val
}

proc Caiu::get_unit { indx } {
  set caius [Caiu::get_all_units]
  if {$indx < 0 || $indx >= [llength $caius]} {
    return ""
  }
  set val [lindex $caius $indx]
  return $val
}

proc Caiu::set_clock { objList clk } {
  foreach unit $objList {
    update_object -name $unit -bind $clk -type "domain"
  }
}

proc Caiu::get_clock { objList } {
  set clks [list]
  foreach unit $objList {
    set clk [get_objects -parent $unit -type clock_subdomain]
    lappend clks $clk
  }
  return $clks
}

proc Caiu::get_all_units { } {
  set chip     [get_objects -type chip -parent root]
  set objects [get_objects -type caiu -parent $chip]
  if {$objects == ""} {
    error "Error: There are no Caiu units created. Please create the Caiu units before assigning parameters to them."
  }
  return $objects
}

proc Caiu::get_units { list_of_indices } {
  set units [list]
  set chip     [get_objects -type chip -parent root]
  foreach indx $list_of_indices {
    set objects [get_objects -type caiu -parent $chip]
    set val [lindex $objects $indx]
    lappend units $val
  }
  return $units
}

package provide Caiu $Caiu::version
package require Tcl 8.5
