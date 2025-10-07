# *********************************************************************************************
#
# This script provides procedures to set parameters on the object of type "dce". 
# 
# *********************************************************************************************

package require Project 2.0

namespace eval Dce {
  namespace export set_createdUnits
  namespace export set_snoopFilters
  namespace export set_nAttCtrlEntries
  namespace export set_nTaggedMonitors
  namespace export set_nDceRbCredits
  namespace export set_nAiuSnpCredits
  namespace export set_nDmiMrdCredits
  namespace export set_nPerfCounters
  namespace export set_tagTiming
  namespace export set_useSramInputFlop

  namespace export get_pipeEnabled
  namespace export get_pipeDepth
  namespace export get_snoopFilters
  namespace export get_nAttCtrlEntries
  namespace export get_nTaggedMonitors
  namespace export get_wLpId

  namespace export set_unit_attribute
  namespace export get_unit_attribute
  namespace export get_units
  namespace export number_of_units
  namespace export get_all_units
  namespace export get_unit
  namespace export set_clock
  namespace export get_clock
  namespace export test
  namespace export create_snoop_filter

  set version 2.0
  set Description "Maestro_Dce"

  variable home [file join [pwd] [file dirname [info script]]]
  variable created_units [list]
}

# ********************************************************************************************************
#
# Description: This proc is used to create the number of snoopfilters in a DCE. The number of snoopfilters 
#              must be the same in all the DCEs
# Argument:    List of objects of type "dce" and the value for the parameter "snoopFilters".
#              If there are 3 snoopFilters created, the snoopIds are 0, 1, 2.
# Example :    Dce::set_snoopFilters [Dce::get_all_units] 3
#
# ********************************************************************************************************
proc Dce::set_snoopFilters { objList val} {
  foreach obj $objList {
    # set attrKey snoopFilters
    # set_attribute -object $obj -name $attrKey -value $val
    puts "WARNING: Dce::set_snoopFilters is deprecated. 'snoopFilters' parameter is no longer used. "
  }
}

# ***********************************************************************************************************
#
# Description:   Sets the value for the parameter "Number of DCE write request buffer credits".
#                The internal parameter name is "nDceRbCredits".
# Argument:      List of objects of type "dce" and the value for the parameter "nDceRbCredits".
# Example usage: Dce::set_nDceRbCredits [Dce::get_all_units] 10
#
# ************************************************************************************************************
proc Dce::set_nDceRbCredits { objList val} {
  foreach obj $objList {
    set attrKey nDceRbCredits
    set_attribute -object $obj -name $attrKey -value $val
  }
}

# ***********************************************************************************************************
#
# Description:   Sets the value for the parameter "Number of snoop Credits".
#                The internal parameter name is "nAiuSnpCredits".
# Argument:      List of objects of type "dce" and the value for the parameter "nAiuSnpCredits".
# Example usage: Dce::set_nAiuSnpCredits [Dce::get_all_units] 6
#
# ************************************************************************************************************
proc Dce::set_nAiuSnpCredits { objList val} {
  foreach obj $objList {
    set attrKey nAiuSnpCredits
    set_attribute -object $obj -name $attrKey -value $val
  }
}

# ***********************************************************************************************************
#
# Description:   Sets the value for the parameter "Number of snoop Credits".
#                The internal parameter name is "tagTiming".
# Argument:      List of objects of type "dce" and the value for the parameter "tagTiming".
# Example usage: Dce::set_tagTiming [Dce::get_all_units] "INPUT_PIPELINE
#
# ************************************************************************************************************
proc Dce::set_tagTiming { objList val} {
  foreach obj $objList {
    set attrKey tagTiming
    set_attribute -object $obj -name $attrKey -value $val
  }
}

# ***********************************************************************************************************
#
# Description:   Sets the value for the parameter "Number of snoop Credits".
#                The internal parameter name is "useSramInputFlop".
# Argument:      List of objects of type "dce" and the value for the parameter "useSramInputFlop".
# Example usage: Dce::useSramInputFlop [Dce::get_all_units] true
#
# ************************************************************************************************************
proc Dce::set_useSramInputFlop { objList val} {
  puts "WARNING: Dce::set_useSramInputFlop is deprecated. useSramInputFlop is replaced by tagTiming. "
}

# ***********************************************************************************************************
#
# Description:   Sets the value for the parameter "Number of memory read credits".
#                The internal parameter name is "nDmiMrdCredits".
# Argument:      List of objects of type "dce" and the value for the parameter "nDmiMrdCredits".
# Example usage: Dce::set_nDmiMrdCredits [Dce::get_all_units] 6
# MAES-5454 became deprecated
#
# ************************************************************************************************************
proc Dce::set_nDmiMrdCredits { objList val} {
  puts "WARNING: Dce::set_nDmiMrdCredits is deprecated. nDmiMrdCredits is no longer used. "
}

# ***********************************************************************************************************
#
# Description:  Sets the value for the parameter "Number of performance counters".
#               The internal parameter name is "nPerfCounters".
# Argument:     List of objects of type "dce" and the value for the parameter "nPerfCounters".
# Return:       The value of the parameter "nPerfCounters" for the object of type "dce" is set.
# Example usage: Dce::set_nPerfCounters [Dce::get_all_units] 4
#
# ************************************************************************************************************
proc Dce::set_nPerfCounters { objList val} {
  foreach obj $objList {
    set attrKey nPerfCounters
    set_attribute -object $obj -name $attrKey -value $val
  }
}

# ***********************************************************************************************************
#
# Description:   Sets the value for the parameter "Number of active coherent transactions".
#                The internal parameter name is "nAttCtrlCredits".
# Argument:      List of objects of type "dce" and the value for the parameter "nAttCtrlCredits".
# Example usage: Dce::set_nAttCtrlCredits [Dce::get_all_units] 6
#
# **********************************************************************************************************
proc Dce::set_nAttCtrlEntries { objList val} {
  foreach obj $objList {
    set attrKey nAttCtrlEntries
    set_attribute -object $obj -name $attrKey -value $val
  }
}

# ***********************************************************************************************************
#
# Description:   Sets the value for the parameter "Number of Tagged exclusive monitors".
#                The internal parameter name is "nTaggedMonitors".
# Argument:      List of objects of type "dce" and the value for the parameter "nTaggedMonitors".
# Example usage: Dce::set_nTaggedMonitors [Dce::get_all_units] 6
#
# **********************************************************************************************************
proc Dce::set_nTaggedMonitors { objList val} {
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey ImplementationParameters/nTaggedMonitors
    set_attribute -object $obj -name $attrKey -value $val
  }
}

# ***********************************************************************************************************
#
# Description:  Sets the value for the parameter "Total depth of the Skid Buffer".
#               The internal parameter name is "nCMDSkidBufSize".
# Argument:     List of objects of type "dmi" and the value for the parameter "nCMDSkidBufSize".
# Return:       The value of the parameter "nCMDSkidBufSize" for the object of type "dce" is set.
# Example usage: Dce::set_nCMDSkidBufSize [Dce::get_all_units] 4
#
# ************************************************************************************************************
proc Dce::set_nCMDSkidBufSize { objList val } {
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
# Return:       The value of the parameter "nCMDSkidBufArb" for the object of type "dce" is set.
# Example usage: Dce::set_nCMDSkidBufArb [Dce::get_all_units] 4
#
# ************************************************************************************************************
proc Dce::set_nCMDSkidBufArb { objList val } {
  foreach obj $objList {
    set attrKey nCMDSkidBufArb
    set_attribute -object $obj -name $attrKey -value $val
  }
}

# ********************************************************************************************************
#
# Description: This proc is used to retrive the number of snoopfilters in a DCE. The number of snoopfilters 
#              must be the same in all the DCEs
# Argument:    List of objects of type "dce".
# Example usage : Dce::get_snoopFilters [Dce::get_all_units]
# Return :     Returns the number of snoopfilters associated with the DCEs
#
# ********************************************************************************************************
proc Dce::get_snoopFilters { objList } {
  set valList [list ]
  foreach obj $objList {
    set attrKey snoopFilters
    set v [get_parameter -object $obj -name $attrKey]
    lappend valList $v
  }
  return $valList
}

# ***********************************************************************************************************
#
# Description:   Retrieves the value for the parameter "Number of DCE write request buffer credits".
#                The internal parameter name is "nDceRbCredits".
# Argument:      List of objects of type "dce".
# Example usage: Dce::get_nDceRbCredits [Dce::get_all_units]
# Return:        Returns the values for the parameter "nDceRbCredits" for the DCEs in the list.
#
# ************************************************************************************************************
proc Dce::get_nDceRbCredits { objList val} {
  foreach obj $objList {
    set attrKey nDceRbCredits
    set v [get_parameter -object $obj -name $attrKey]
    lappend valList $v
  }
  return $valList
}

# ***********************************************************************************************************
#
# Description:   Retrieves the value for the parameter "Number of snoop Credits".
#                The internal parameter name is "nAiuSnpCredits".
# Argument:      List of objects of type "dce" and the value for the parameter "nAiuSnpCredits".
# Example usage: Dce::get_nAiuSnpCredits [Dce::get_all_units]
# Return:        Returns the values for the parameter "nAiuSnpCredits" for the DCEs in the list.
#
# ************************************************************************************************************
proc Dce::get_nAiuSnpCredits { objList val} {
  foreach obj $objList {
    set attrKey nAiuSnpCredits
    set v [get_parameter -object $obj -name $attrKey]
    lappend valList $v
  }
  return $valList
}

# ***********************************************************************************************************
#
# Description:   Retrieves the value for the parameter "Number of memory read credits".
#                The internal parameter name is "nDmiMrdCredits".
# Argument:      List of objects of type "dce" and the value for the parameter "nDmiMrdCredits".
# Example usage: Dce::get_nDmiMrdCredits [Dce::get_all_units]
# Return:        Returns the values for the parameter "nDmiMrdCredits" for the DCEs in the list.
#
# ************************************************************************************************************
proc Dce::get_nDmiMrdCredits { objList val} {
  puts "WARNING: Dce::get_nDmiMrdCredits is deprecated"
  return $valList
}
# ***********************************************************************************************************
#
# Description:   Retrieves the value for the parameter "Number of active coherent transactions".
#                The internal parameter name is "nAttCtrlCredits".
# Argument:      List of objects of type "dce"
# Example usage: Dce::get_nAttCtrlCredits [Dce::get_all_units]
# Return:        Returns the values for the parameter "nAttCtrlCredits" for the DCEs in the list.
#
# **********************************************************************************************************
proc Dce::get_nAttCtrlEntries { objList } {
  set valList [list ]
  foreach obj $objList {
    set attrKey nAttCtrlEntries
    set v [get_parameter -object $obj -name $attrKey]
    lappend valList $v
  }
  return $valList
}

# ***********************************************************************************************************
#
# Description:   Retrieves the value for the parameter "Number of Tagged Exclusive Monitors".
#                The internal parameter name is "nTaggedMonitors".
# Argument:      List of objects of type "dce"
# Example usage: Dce::get_nTaggedMonitors [Dce::get_all_units]
# Return:        Returns the values for the parameter "nTaggedMonitors" for the DCEs in the list.
#
# **********************************************************************************************************
proc Dce::get_nTaggedMonitors { objList } {
  set valList [list ]
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey nTaggedMonitors
    set v [get_parameter -object $obj -name $attrKey]
    lappend valList $v
  }
  return $valList
}

proc Dce::set_unit_attribute { ind procFunc value } {
  set unit [Dce::get_unit $ind]
  if {$unit == "" } {
    return ""
  }
  set x [$procFunc $unit $value]
}

proc Dce::get_unit_attribute { ind procFunc } {
  set unit [Dce::get_unit $ind]
  if {$unit == "" } {
    return ""
  }
  set val [$procFunc $unit]
  return $val
}

proc Dce::number_of_units { } {
  set units [Dce::get_all_units]
  set val [llength $units]
  return $val
}

proc Dce::get_unit { indx } {
  set units [Dce::get_all_units]
  if {$indx < 0 || $indx >= [llength $units]} {
    return ""
  }
  set val [lindex $units $indx]
  return $val
}

proc Dce::get_all_units { } {
  set chip     [get_objects -type chip -parent root]
  set objects [get_objects -type dce -parent $chip]
  if {$objects == ""} {
    error "Error: There are no DCE units created. Please create the DCE units before assigning parameters to them."
  }
  return $objects
}

proc Dce::get_units { list_of_indices } {
  set units [list]
  set chip     [get_objects -type chip -parent root]
  foreach indx $list_of_indices {
    set objects [get_objects -type dce -parent $chip]
    set val [lindex $objects $indx]
    lappend units $val
  }
  return $units
}

proc Dce::get_clock { objList } {
  set clks [list]
  foreach unit $objList {
    set clk [get_objects -parent $unit -type clock_subdomain]
    lappend clks $clk
  }
  return $clks
}


package provide Dce $Dce::version
package require Tcl 8.5
