# *********************************************************************************************
#
# This script provides procedures to set parameters on the object of type "Snoopfilter". 
# 
# *********************************************************************************************
namespace eval SnoopFilter {
  namespace export set_nSnpFltrSets
  namespace export set_nSnpFltrWays
  namespace export set_bitEn
  namespace export set_SetSelectPrimaryBitV
  namespace export set_PrimaryBits
  namespace export set_SecondaryBits
  namespace export set_nVictimBuffers
  namespace export set_TagMem_MemType
  namespace export set_memType
  namespace export set_TagMem_rtlPrefixString
  
  namespace export get_nSnpFltrSets
  namespace export get_nSnpFltrWays
  namespace export get_bitEn
  namespace export get_SetSelectPrimaryBitV
  namespace export get_nVictimBuffers
  namespace export get_TagMem_MemType
  namespace export get_TagMem_rtlPrefixString

  namespace export print_parameters
  namespace export create_unit
  namespace export set_unit_attribute
  namespace export get_unit_attribute
  namespace export get_units
  namespace export number_of_units
  namespace export get_all_units
  namespace export get_unit
  namespace export set_clock
  namespace export get_clock
  namespace export test
  
  set version 2.0
  set Description "Maestro_SnoopFilter"

  variable home [file join [pwd] [file dirname [info script]]]
  variable created_units [list]
}


# ***********************************************************************************************************
#
# Description:   Sets the value for the parameter "Sets" in the snoopfilter.
#                The internal parameter name is "nSnpFltrSets".
# Argument:      Index of the snoopfilter and the value for the parameter "nSnpFltrSets".
# Example usage: SnoopFilter::set_nSnpFltrSets 1 1024
#
# ************************************************************************************************************
proc SnoopFilter::set_nSnpFltrSets { indx val} {
  set num_dce [Dce::number_of_units]
  foreach obj [Dce::get_all_units] {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey SnoopFilters/EO$indx/nSnpFltrSets
    set_attribute -object $obj -name $attrKey -value $val
  }
}

proc SnoopFilter::set_nSets { objList val} {
  foreach obj $objList {
    set attrKey nSets
    set_attribute -object $obj -name $attrKey -value $val
  }
}
# ***********************************************************************************************************
#
# Description:   Sets the value for the parameter "Associativity" in the snoopfilter.
#                The internal parameter name is "nSnpFltrWays".
# Argument:      Index of the snoopFilter and the value for the parameter "nSnpFltrWays".
# Example usage: SnoopFilter::set_nSnpFltrWays 1 8
#
# ************************************************************************************************************
proc SnoopFilter::set_nSnpFltrWays { indx val} {
  foreach obj [Dce::get_all_units] {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey SnoopFilters/EO$indx/nSnpFltrWays
    set_attribute -object $obj -name $attrKey -value $val
  }
}

proc SnoopFilter::set_nWays { objList val} {
  foreach obj $objList {
    set attrKey nWays
    set_attribute -object $obj -name $attrKey -value $val
  }
}

# ***********************************************************************************************************
#
# Description:   Sets the value for the parameter "Primary Set Selection" in the snoopfilter.
#                The internal parameter name is "SetSelectPrimaryBitV".
# Argument:      Index of the snoopFilter and the list of values for the parameter "SetSelectPrimaryBitV".
# Example usage: SnoopFilter::set_SetSelectPrimaryBitV 1 [list 16 17 18]
#
# ************************************************************************************************************
proc SnoopFilter::set_SetSelectPrimaryBitV { indx val} {
  error "Please use SnoopFilter::set_PrimaryBits API"
}

proc SnoopFilter::set_PrimaryBits { objList val} {
  foreach obj $objList {
    set attrKey aPrimaryBits
    set_attribute -object $obj -name $attrKey -value_list $val
  }
}

proc SnoopFilter::set_SecondaryBits { objList val} {
  foreach obj $objList {
    set attrKey aSecondaryBits
    set_attribute -object $obj -name $attrKey -value_list $val
  }
}


# ***********************************************************************************************************
#
# Description:   Sets the value for the parameter "Victim Buffer Entries" in the snoopfilter.
#                The internal parameter name is "nVictimBuffers".
# Argument:      Index of the snoopFilter and the list of values for the parameter "nVictimBuffers".
# Example usage: SnoopFilter::set_nVictimBuffers 1 8
#
# ************************************************************************************************************
proc SnoopFilter::set_nVictimBuffers { indx val} {
  error "Please use SnoopFilter::set_nVictimEntries API. Example: SnoopFilter::set_nVictimEntries [SnoopFilter::get_units {0}] 16"
}

proc SnoopFilter::set_nVictimEntries { objList val} {
  foreach obj $objList {
    set attrKey nVictimEntries
    set_attribute -object $obj -name $attrKey -value $val
  }
}
# ***********************************************************************************************************
#
# Description:   Sets the value for the parameter "Memory Type" in the snoopfilter.
#                The internal parameter name is "MemType".
# Argument:      Index of the snoopFilter and the list of values for the parameter "MemType".
# Example usage: SnoopFilter::set_TagMem_MemType 1 "NONE"
#
# ************************************************************************************************************
proc SnoopFilter::set_TagMem_MemType { indx val} {
  foreach obj [Dce::get_all_units] {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey SnoopFilters/EO$indx/MemoryInterfaces/TagMem/MemType
    set_attribute -object $obj -name $attrKey -value $val
  }
}

# ***********************************************************************************************************
#
# Description:   Sets the value for the parameter "Memory RTL name" in the snoopfilter.
#                The internal parameter name is "rtlPrefixString".
# Argument:      Index of the snoopFilter and the list of values for the parameter "rtlPrefixString".
# Example usage: SnoopFilter::set_TagMem_rtlPrefixString 1 "DCE_EOS1_tagMem"
#
# ************************************************************************************************************
proc SnoopFilter::set_TagMem_rtlPrefixString { indx val} {
  foreach obj [Dce::get_all_units] {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey SnoopFilters/EO$indx/MemoryInterfaces/TagMem/rtlPrefixString
    set_attribute -object $obj -name $attrKey -value $val
  }
}

# ***********************************************************************************************************
#
# Description:   Sets the value for the parameter "Bit Enables" in the snoopfilter.
#                The internal parameter name is "bitEn".
# Argument:      Index of the snoopfilter and the value for the parameter "bitEn".
# Example usage: SnoopFilter::set_bitEn 1 0
#
# ************************************************************************************************************
proc SnoopFilter::set_bitEn { indx val} {
  foreach obj [Dce::get_all_units] {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey SnoopFilters/EO$indx/bitEn
    set_attribute -object $obj -name $attrKey -value $val
  }
}

proc SnoopFilter::get_nSnpFltrSets { objList } {
  set valList [list ]
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey nSnpFltrSets
    set v [get_parameter -object $obj -name $attrKey]
    lappend valList $v
  }
  return $valList
}

proc SnoopFilter::get_nSnpFltrWays { objList } {
  set valList [list ]
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey nSnpFltrWays
    set v [get_parameter -object $obj -name $attrKey]
    lappend valList $v
  }
  return $valList
}

proc SnoopFilter::get_bitEn { objList } {
  set valList [list ]
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey bitEn
    set v [get_parameter -object $obj -name $attrKey]
    lappend valList $v
  }
  return $valList
}


proc SnoopFilter::get_TagFilterErrInfo { objList } {
  set valList [list ]
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey TagFilterErrInfo
    set v [get_parameter -object $obj -name $attrKey]
    lappend valList $v
  }
  return $valList
}

proc SnoopFilter::get_SetSelectPrimaryBitV { objList } {
  set valList [list ]
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey SetSelectPrimaryBitV
    set v [get_parameter -object $obj -name $attrKey]
    lappend valList $v
  }
  return $valList
}


proc SnoopFilter::get_nVictimBuffers { objList } {
  set valList [list ]
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey nVictimBuffers
    set v [get_parameter -object $obj -name $attrKey]
    lappend valList $v
  }
  return $valList
}

proc SnoopFilter::get_TagMem_MemType { objList } {
  set valList [list ]
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey TagMem_MemType
    set v [get_parameter -object $obj -name $attrKey]
    lappend valList $v
  }
  return $valList
}

proc SnoopFilter::get_TagMem_rtlPrefixString { objList } {
  set valList [list ]
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey TagMem_rtlPrefixString
    set v [get_parameter -object $obj -name $attrKey]
    lappend valList $v
  }
  return $valList
}

proc SnoopFilter::create_unit { name } {
  set chip     [get_objects -type chip -parent root]
  set system   [get_objects -type system -parent $chip]
  set subsystem [get_objects -type subsystem -parent $system]
  set topology [get_objects -type topology -parent $subsystem]
  set unit [create_object -type snoop_filter -name $name -parent $topology ]
  return $unit
}

proc SnoopFilter::set_unit_attribute { ind procFunc value } {
  set unit [lindex $SnoopFilter::created_units $ind]
  set x [$procFunc $unit $value]
}

proc SnoopFilter::get_unit_attribute { ind procFunc } {
  set unit [lindex $SnoopFilter::created_units $ind]
  set val [$procFunc $unit]
  return $val
}

proc SnoopFilter::number_of_units { } {
  set val [llength $SnoopFilter::created_units]
  return $val
}

proc SnoopFilter::get_unit { indx } {
  if {$indx < 0 || $indx >= [llength $SnoopFilter::created_units]} {
    return ""
  }
  set val [lindex $SnoopFilter::created_units $indx]
  return $val
}

proc SnoopFilter::set_clock { objList clk } {
  foreach unit $objList {
    update_object -name $unit -bind $clk -type "domain"
  }
}

proc SnoopFilter::get_clock { objList } {
  set clks [list]
  foreach unit $objList {
    set clk [get_objects -parent $unit -type clock_subdomain]
    lappend clks $clk
  }
  return $clks
}

proc SnoopFilter::get_all_units { } {
  return $SnoopFilter::created_units
}

proc SnoopFilter::get_units { list_of_indices } {
  set units [list]
  set chip     [get_objects -type chip -parent root]
  set system   [get_objects -type system -parent $chip]
  set subsystem [get_objects -type subsystem -parent $system]
  set topology [get_objects -type topology -parent $subsystem]
  foreach indx $list_of_indices {
    set objects [get_objects -type snoop_filter -parent $topology]
    set val [lindex $objects $indx]
    lappend units $val
  }
  return $units
}

proc SnoopFilter::set_TagMem_memType { objList val} {
  puts "Warning: using deprecated version of SnoopFilter::set_TagMem_memType. Using new version SnoopFilter::set_memType"
  SnoopFilter::set_memType $objList $val
}

proc SnoopFilter::set_memType {objList val} {
  set attrKey memoryType
  foreach obj $objList {
    set memList [get_objects -parent $obj -type internal_memory]
    foreach m $memList {
        set_attribute -object $m -name $attrKey -value $val
    }
  }
}

proc SnoopFilter::set_TagMem_rtlPrefix { objList val} {
  foreach obj $objList {
    set memList [get_objects -parent $obj -type internal_memory]
    set i 0
    foreach m $memList {
        rename_object -name $m -new_name $val$i
        incr i
    }
  }
}

proc SnoopFilter::add_TagMem_signal { objList name width direction} {
  puts "Warning: using deprecated version of SnoopFilter::add_TagMem_signal. Using new version SnoopFilter::add_signal"
  return [SnoopFilter::add_signal $objList $name $width $direction]
}

proc SnoopFilter::add_signal { objList name width direction} {
  foreach obj $objList {
    set memList [get_objects -parent $obj -type internal_memory]
    set objs [list ]
    foreach m $memList {
        set gp [create_object -type generic_port -parent $m -name $name]
        set_attribute -object $gp -name wireWidth -value $width
        set_attribute -object $gp -name direction -value $direction
        lappend objs $gp
    }
  }
  return $objs
}


# ****************************************************************************************
# Deprecated procedures
# ***************************************************************************************
proc SnoopFilter::set_strRtlNamePrefix { indx val} {
  puts "WARNING: SnoopFilter::set_strRtlNamePrefix is deprecated"
}

proc SnoopFilter::set_TagFilterErrInfo { indx val} {
  puts "Deprecated SnoopFilter::set_TagFilterErrInfo. Use Safety::set_MemProtectionType SECDED or PARITY in pre_map "
}

proc SnoopFilter::set_SetSelectSecondaryBitV { indx val} {
  puts "WARNING: SnoopFilter::set_SetSelectSecondaryBitV is deprecated"
}

proc SnoopFilter::get_SetSelectSecondaryBitV { objList } {
  puts "SnoopFilter::get_SetSelectSecondaryBitV is deprecated"
}

proc SnoopFilter::get_strRtlNamePrefix { objList } {
  puts "SnoopFilter::get_strRtlNamePrefix is deprecated"
}

package provide SnoopFilter $SnoopFilter::version
package require Tcl 8.5
