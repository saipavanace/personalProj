# *********************************************************************************************
#
# This script provides procedures to set the parameters on the object of type "ncaiu". 
# 
# *********************************************************************************************

package require Project 2.0

namespace eval Ncaiu {
  namespace export set_createdUnits
  namespace export set_useCache
  namespace export set_nPerfCounters
  namespace export set_nUnitTraceBufSize
  namespace export set_fnCsrAccess
  namespace export set_Cache_nSets
  namespace export set_Cache_nWays
  namespace export set_Cache_useScratchpad
  namespace export set_Cache_nTagBanks
  namespace export set_Cache_nDataBanks
  namespace export set_Cache_RepPolicy
  namespace export set_Cache_PriSubDiagAddrBits
  namespace export set_Cache_SecSubRows
  namespace export set_Cache_TagBankSelBits
  namespace export set_Cache_DataBankSelBits
  namespace export set_NcMode
  namespace export set_OttMem_memType
  namespace export set_OttMem_rtlPrefix
  namespace export set_DataMem_memType
  namespace export set_DataMem_rtlPrefix
  namespace export set_TagMem_memType
  namespace export set_TagMem_rtlPrefix
  namespace export assign_snoopFilter

  namespace export get_useCache
  namespace export get_protocolType
  namespace export get_Cache_nSets
  namespace export get_Cache_nWays
  namespace export get_Cache_useScratchpad
  namespace export get_Cache_nTagBanks
  namespace export get_Cache_nDataBanks
  namespace export get_Cache_TagErrInfo
  namespace export get_Cache_DataErrInfo
  namespace export get_Cache_RepPolicy
  namespace export get_Cache_PriSubDiagAddrBits
  namespace export get_Cache_SecSubRows
  namespace export get_OttMem_memType
  namespace export get_OttMem_rtlPrefix
  namespace export get_DataMem_memType
  namespace export get_DataMem_rtlPrefix
  namespace export get_TagMem_memType
  namespace export get_TagMem_rtlPrefix

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
  set Description "Maestro_Ncaiu"

  variable home [file join [pwd] [file dirname [info script]]]
  variable created_units [list]
}

proc Ncaiu::set_createdUnits { units } {
  set Ncaiu::created_units $units
  return [llength $Ncaiu::created_units]
}


# ********************************************************************************************************
#
# Description: This proc is used to enable proxy cache support.
# Argument:    List of objects of type "ncaiu" and the boolean value for the parameter "hasProxyCache".
# Example :    Ncaiu::set_Cache_DataBankSelBits [Ncaiu::get_units {0}] true
#
# ********************************************************************************************************
proc Ncaiu::set_useCache { objList val} {
  foreach obj $objList {
    set attrKey hasProxyCache
    set_attribute -object $obj -name $attrKey -value $val
  }
}

# ***********************************************************************************************************
#
# Description:  Sets the value for the parameter "Number of performance counters".
#               The internal parameter name is "nPerfCounters".
# Argument:     List of objects of type "ncaiu" and the value for the parameter "nPerfCounters".
# Return:       The value of the parameter "nPerfCounters" for the object of type "ncaiu" is set.
# Example usage: Ncaiu::set_nPerfCounters [Ncaiu::get_all_units] 4
#
# ************************************************************************************************************
proc Ncaiu::set_nPerfCounters { objList val} {
  foreach obj $objList {
    set attrKey nPerfCounters
    set_attribute -object $obj -name $attrKey -value $val
  }
}

# ***********************************************************************************************************
#
# Description:   Sets the value for the parameter "Unit Trace Buffer Size".
#                The internal parameter name is "nUnitTraceBufSize".
# Argument:      List of objects of type "ncaiu" and the value for the parameter "nUnitTraceBufSize".
# Example usage: Ncaiu::set_nUnitTraceBufSize [Ncaiu::get_units {1}] 8
#
# ************************************************************************************************************

proc Ncaiu::set_nUnitTraceBufSize { val} {
  set obj [_getTopology]
  set attrKey nUnitTraceBufSize
  set_attribute -object $obj -name $attrKey -value $val
}

# ***********************************************************************************************************
#
# Description:  Sets the value for the parameter "Enable CSR Access".
#               The internal parameter name is "fnCsrAccess".
# Argument:     List of objects of type "ncaiu" and the value for the parameter "fnCsrAccess".
# Return:       The value of the parameter "fnCsrAccess" for the object of type "ncaiu" is set.
# Example usage: Ncaiu::set_fnCsrAccess [Ncaiu::get_all_units] true
#
# ************************************************************************************************************
proc Ncaiu::set_fnCsrAccess { objList val} {
  foreach obj $objList {
    set attrKey fnCsrAccess
    set_attribute -object $obj -name $attrKey -value $val
  }
}

# ***********************************************************************************************************
#
# Description:  Sets the value for the parameter "Outstanding transaction table Entries".
#               The internal parameter name is "nOttCtrlEntries".
# Argument:     List of objects of type "ncaiu" and the value for the parameter "nOttCtrlEntries".
# Return:       The value of the parameter "nOttCtrlEntries" for the object of type "ncaiu" is set.
# Example usage: Ncaiu::set_nOttCtrlEntries [Ncaiu::get_all_units] 48
#
# ************************************************************************************************************
proc Ncaiu::set_nOttCtrlEntries { objList val} {
  foreach obj $objList {
    set attrKey nOttCtrlEntries
    set_attribute -object $obj -name $attrKey -value $val
  }
}

# ***********************************************************************************************************
#
# Description:  Sets the value for the parameter "Credits per DCE Command Request".
#               The internal parameter name is "nDceCmdCredits".
# Argument:     List of objects of type "ncaiu" and the value for the parameter "nDceCmdCredits".
# Return:       The value of the parameter "nOttCtrlEntries" for the object of type "ncaiu" is set.
# Example usage: Ncaiu::set_nDceCmdCredits [Ncaiu::get_all_units] 48
#
# ************************************************************************************************************
proc Ncaiu::set_nDceCmdCredits {objList val } {
  if {[info exists ::_skip_depreciated_] && ($::_skip_depreciated_ == 1)} {return}
    foreach obj $objList {
        set attrKey nDceCmdCredits
        set_attribute -object $obj -name $attrKey -value $val
    }
}

# ***********************************************************************************************************
#
# Description:  Sets the value for the parameter "Credits per DMI Command Request".
#               The internal parameter name is "nDmiCmdCredits".
# Argument:     List of objects of type "ncaiu" and the value for the parameter "nDmiCmdCredits".
# Return:       The value of the parameter "nDmiCmdEntries" for the object of type "ncaiu" is set.
# Example usage: Ncaiu::set_nDmiCmdCredits [Ncaiu::get_all_units] 8
#
# ************************************************************************************************************
proc Ncaiu::set_nDmiCmdCredits {objList val } {
    foreach obj $objList {
        set attrKey nDmiCmdCredits
        set_attribute -object $obj -name $attrKey -value $val
    }
}

# ***********************************************************************************************************
#
# Description:  Sets the value for the parameter "Credits per DII Command Request".
#               The internal parameter name is "nDceCmdCredits".
# Argument:     List of objects of type "ncaiu" and the value for the parameter "nDiiCmdCredits".
# Return:       The value of the parameter "nDiiCmdCredits" for the object of type "ncaiu" is set.
# Example usage: Ncaiu::set_nDiiCmdCredits [Ncaiu::get_all_units] 4
#
# ************************************************************************************************************
proc Ncaiu::set_nDiiCmdCredits {objList val } {
  if {[info exists ::_skip_depreciated_] && ($::_skip_depreciated_ == 1)} {return}
    foreach obj $objList {
        set attrKey nDiiCmdCredits
        set_attribute -object $obj -name $attrKey -value $val
    }
}

proc Ncaiu::set_nDceWrCmdCredits {objList val } {
  puts "This API Ncaiu::set_nDceWrCmdCredits is obsolete. nDceWrCmdCredits is not user-visible"
}

proc Ncaiu::set_nDmiWrCmdCredits {objList val } {
  puts "This API Ncaiu::set_nDmiWrCmdCredits is obsolete. nDmiWrCmdCredits is not user-visible"
}

proc Ncaiu::set_nDiiWrCmdCredits {objList val } {
  puts "This API Ncaiu::set_nDiiWrCmdCredits is obsolete. nDiiWrCmdCredits is not user-visible"
}

# ***********************************************************************************************************
#
# Description:  Add placeholder signal to the "ncaiu" unit.
# Argument:     The object of type "ncaiu", the name for the rtlprefix, the name of the placeholder signal,
#               the width of the placeholder signal, the direction of the placeholder signal.
# Example usage: Ncaiu::add_placeholder_signal  [Ncaiu::get_units {0}] "ncaiu1_ph" "sig1" 4 IN
#
# ************************************************************************************************************
# proc Ncaiu::add_placeholder_signal { obj rtlprefix name width direction } {
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
proc Ncaiu::add_placeholder_signal { obj rtlprefix name width direction } {
  set pl $obj/placeholder
  set gp [create_object -type generic_port -parent $pl -name $name]
  set_attribute -object $pl -name wireRtlPrefix -value $rtlprefix
  set_attribute -object $gp -name wireWidth -value $width 
  set_attribute -object $gp -name direction -value $direction
}

proc Ncaiu::set_OttErrInfo { objList val} {
  puts "Deprecated Ncaiu::set_OttErrInfo. Use Safety::set_MemProtectionType SECDED or PARITY in pre_map "
}

proc _get_object_name_from_full_path { full_path_to_object } {
  set last_separator_position [string last "/" $full_path_to_object]
  set object_name_start_position [expr $last_separator_position + 1]
  return [string range $full_path_to_object $object_name_start_position end]
}

proc _prepare_mapped_parameter_name { object_path parameter_name } {
  set object_name [_get_object_name_from_full_path $object_path]
  return $parameter_name
}

proc _is_proxy_cache_exist_in_object { object } {
  set all_object_parameters [get_parameter -object $object]
  set has_proxy_cache_index [lsearch $all_object_parameters hasProxyCache]
  if { $has_proxy_cache_index != -1 } {
    return 1
  }
  return 0
}

proc _is_proxy_cache_enabled_in_object { object } {
  if { [_is_proxy_cache_exist_in_object $object] } {
    set proxy_cache_enabled [get_parameter -object $object -name hasProxyCache -silent]
    if {$proxy_cache_enabled} {
      return 1
    }
  }
  return 0
}

proc _set_proxy_cache_postmap_parameter_for_listed_objects { obj_list \
                                                             parameter_name \
                                                             value } {
  foreach obj $obj_list {
    if { [_is_proxy_cache_enabled_in_object $obj] } {
      set_attribute -object $obj \
                    -name [_prepare_mapped_parameter_name $obj $parameter_name]\
                    -value $value
    }
  }
}

proc _set_proxy_cache_postmap_array_parameter_for_listed_objects { obj_list \
                                                                   parameter_name \
                                                                   values_list } {
  foreach obj $obj_list {
    if { [_is_proxy_cache_enabled_in_object $obj] } {
      set_attribute -object $obj \
                    -name [_prepare_mapped_parameter_name $obj $parameter_name]\
                    -value_list $values_list
    }
  }
}

# ***********************************************************************************************************
#
# Description:   Sets the value for the parameter "Number of Sets".
#                The internal parameter name is "nSets".
# Argument:      List of objects of type "ncaiu" and the value for the parameter "nSets".
# Example usage: Ncaiu::set_Cache_nSets [Ncaiu::get_units {1}] 1024
#
# ************************************************************************************************************
proc Ncaiu::set_Cache_nSets { objList val} {
  #_set_proxy_cache_postmap_parameter_for_listed_objects $objList Cache/nSets $val
  foreach obj $objList {
    set attrKey Cache/nSets
    set_attribute -object $obj -name $attrKey -value $val
  }
}

# ***********************************************************************************************************
#
# Description:   Sets the value for the parameter "Number of Ways".
#                The internal parameter name is "nWays".
# Argument:      List of objects of type "ncaiu" and the value for the parameter "nWays".
# Example usage: Ncaiu::set_Cache_nWays [Ncaiu::get_units {1}] 8
#
# ************************************************************************************************************
proc Ncaiu::set_Cache_nWays { objList val} {
  #_set_proxy_cache_postmap_parameter_for_listed_objects $objList Cache/nWays $val
  foreach obj $objList {
    set attrKey Cache/nWays
    set_attribute -object $obj -name $attrKey -value $val
  }
}

# ***********************************************************************************************************
#
# Description:   Sets the value for the parameter "Enable Scratchpad".
#                The internal parameter name is "useScratchpad".
# Argument:      List of objects of type "ncaiu" and the value for the parameter "useScratchpad".
# Example usage: Ncaiu::set_Cache_useScratchpad [Ncaiu::get_units {1}] true
#
# ************************************************************************************************************
proc Ncaiu::set_Cache_useScratchpad { objList val} {
  #_set_proxy_cache_postmap_parameter_for_listed_objects $objList Cache/useScratchpad $val
  foreach obj $objList {
    set attrKey Cache/useScratchpad
    set_attribute -object $obj -name $attrKey -value $val
  }
}

# ***********************************************************************************************************
#
# Description:   Sets the value for the parameter "Number of Tag Banks".
#                The internal parameter name is "nTagBanks".
# Argument:      List of objects of type "ncaiu" and the value for the parameter "nTagBanks".
# Example usage: Ncaiu::set_Cache_nTagBanks [Ncaiu::get_units {1}] 2
#
# ************************************************************************************************************
proc Ncaiu::set_Cache_nTagBanks { objList val} {
  foreach obj $objList {
    set attrKey nTagBanks
    set_attribute -object $obj -name $attrKey -value $val
  }
}

# ***********************************************************************************************************
#
# Description:   Sets the value for the parameter "Number of Data Banks".
#                The internal parameter name is "nDataBanks".
# Argument:      List of objects of type "ncaiu" and the value for the parameter "nDataBanks".
# Example usage: Ncaiu::set_Cache_nDataBanks [Ncaiu::get_units {1}] 4
#
# ************************************************************************************************************
proc Ncaiu::set_Cache_nDataBanks { objList val} {
  foreach obj $objList {
    set attrKey nDataBanks
    set_attribute -object $obj -name $attrKey -value $val
  }
}

# ********************************************************************************************************
#
# Description: This proc is used to set the Primary Set selection bit. 
# Argument:    List of objects of type "ncaiu" and the list of values for the parameter "PriSubDiagAddrBits".
# Example :    Ncaiu::set_Cache_PriSubDiagAddrBits [Ncaiu::get_units {1}] [list 10 11 12 13 14 15 16 17 18 19]
#
# ********************************************************************************************************
proc Ncaiu::set_Cache_PriSubDiagAddrBits { objList val} {
  #_set_proxy_cache_postmap_array_parameter_for_listed_objects \
    $objList Cache/SelectInfo/PriSubDiagAddrBits $val
  foreach obj $objList {
    set attrKey Cache/SelectInfo/PriSubDiagAddrBits
    set_attribute -object $obj -name $attrKey -value_list $val
  }
}

# ********************************************************************************************************
#
# Description: This proc is used to set the Tag bank selection bit. This bit must be one of the bits 
#              from the primary selection bits.
# Argument:    List of objects of type "ncaiu" and the list of values for the parameter "TagBankSelBits".
# Example :    Ncaiu::set_Cache_TagBankSelBits [Ncaiu::get_units {0}] [list 10]
#
# ********************************************************************************************************
proc Ncaiu::set_Cache_TagBankSelBits { objList val } {
  #_set_proxy_cache_postmap_array_parameter_for_listed_objects \
    $objList Cache/SelectInfo/TagBankSelBits $val
  foreach obj $objList {
    set attrKey Cache/SelectInfo/TagBankSelBits
    set_attribute -object $obj -name $attrKey -value_list $val
  }
}

# ********************************************************************************************************
#
# Description: This proc is used to set the Data bank selection bit. These bits must be one of the bits 
#              from the primary selection bits.
# Argument:    List of objects of type "ncaiu" and the list of values for the parameter "DataBankSelBits".
# Example :    Ncaiu::set_Cache_DataBankSelBits [Ncaiu::get_units {0}] [list 10]
#
# ********************************************************************************************************
proc Ncaiu::set_Cache_DataBankSelBits { objList val } { 
  #_set_proxy_cache_postmap_array_parameter_for_listed_objects \
    $objList Cache/SelectInfo/DataBankSelBits $val
  foreach obj $objList {
    set attrKey Cache/SelectInfo/DataBankSelBits
    set_attribute -object $obj -name $attrKey -value_list $val
  }
}

# ********************************************************************************************************
#
# Description: This proc is used to set the Replacement Policy.
# Argument:    List of objects of type "ncaiu" and the value for the parameter "RepPolicy"
# Example :    Ncaiu::set_Cache_RepPolicy [Ncaiu::get_units {0}] RANDOM
#
# ********************************************************************************************************
proc Ncaiu::set_Cache_RepPolicy { objList val} {
  foreach obj $objList {
    set attrKey cacheReplPolicy
    set_attribute -object $obj -name $attrKey -value $val
  }
}

proc Ncaiu::set_NcMode { objList val} {
  puts "WARNING: Ncaiu::set_NcMode is deprecated and should be removed. The parameter NcMode is not longer used."
}

proc Ncaiu::set_OttMem_memType { objList val} {
  set attrKey memoryType
  foreach obj $objList {
    set memList [get_objects -parent $obj -type internal_memory -subtype OTT]
    foreach m $memList {
        set_attribute -object $m -name $attrKey -value $val
    }
  }
}

proc Ncaiu::set_OttMem_rtlPrefix { objList val} {
  foreach obj $objList {
    set memList [get_objects -parent $obj -type internal_memory -subtype OTT]
    foreach m $memList {
        rename_object -name $m -new_name $val
    }
  }
}

proc Ncaiu::add_OttMem_signal { objList name width direction} {
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

proc Ncaiu::set_DataMem_memType { objList val} {
  set attrKey memoryType
  foreach obj $objList {
    set value [get_parameter -object $obj -name hasProxyCache -silent]
    if {$value != "" && $value != "false"} {
      set memList [get_objects -parent $obj -type internal_memory -subtype DATA]
      foreach m $memList {
          set_attribute -object $m -name $attrKey -value $val
      }
    }
  }
}


proc Ncaiu::get_Mem_memType { objList role} {
  set valList [list ]
  set attrKey memoryType
  foreach obj $objList {
    set val "?"
    set value [get_parameter -object $obj -name hasProxyCache -silent]
    if {$value != "" && $value != "false"} {
      set memList [get_objects -parent $obj -type internal_memory -subtype $role]
      foreach m $memList {
          set val [get_parameter -object $m -name $attrKey]
          break;
      }
    }
    lappend valList $val
  }
  return $valList
}

proc Ncaiu::get_DataMem_memType { objList } {
  return [Ncaiu::get_Mem_memType $objList "DATA"]
}

proc Ncaiu::get_TagMem_memType { objList } {
  return [Ncaiu::get_Mem_memType $objList "TAG"]
}
proc Ncaiu::get_OttMem_memType { objList } {
  return [Ncaiu::get_Mem_memType $objList "OTT"]
}

proc Ncaiu::set_DataMem_rtlPrefix { objList val} {
  foreach obj $objList {
    set value [get_parameter -object $obj -name hasProxyCache -silent]
    if {$value != "" && $value != "false"} {
      set memList [get_objects -parent $obj -type internal_memory -subtype DATA]
      set i 0
      foreach m $memList {
          rename_object -name $m -new_name $val$i
          incr i
      }
    }
  }
}

proc Ncaiu::add_DataMem_signal { objList name width direction} {
  foreach obj $objList {
    set value [get_parameter -object $obj -name hasProxyCache -silent]
    if {$value != "" && $value != "false"} {
      set memList [get_objects -parent $obj -type internal_memory -subtype DATA]
      foreach m $memList {
          set rtlPrefix [Project::abbrev $m]
          set gp [create_object -type generic_port -parent $m -name $name]
          set_attribute -object $gp -name wireWidth -value $width
          set_attribute -object $gp -name direction -value $direction
      }
    }
  }
}

proc Ncaiu::set_TagMem_memType { objList val} {
  set attrKey memoryType
  foreach obj $objList {
    set value [get_parameter -object $obj -name hasProxyCache -silent]
    if {$value != "" && $value != "false"} {
      set memList [get_objects -parent $obj -type internal_memory -subtype TAG]
      foreach m $memList {
          set_attribute -object $m -name $attrKey -value $val
      }
    }
  }
}

proc Ncaiu::set_TagMem_rtlPrefix { objList val} {
  foreach obj $objList {
    set value [get_parameter -object $obj -name hasProxyCache -silent]
    if {$value != "" && $value != "false"} {
      set memList [get_objects -parent $obj -type internal_memory]
      set i 0
      foreach m $memList {
        set memoryRole [get_parameter -object $m -name memoryRole]
        if {$memoryRole == "TAG"} {
          rename_object -name $m -new_name $val$i
          incr i
        }
      }
    }
  }
}

proc Ncaiu::add_TagMem_signal { objList name width direction} {
  foreach obj $objList {
    set value [get_parameter -object $obj -name hasProxyCache -silent]
    if {$value != "" && $value != "false"} {
      set memList [get_objects -parent $obj -type internal_memory -subtype TAG]
      foreach m $memList {
          set rtlPrefix [Project::abbrev $m]
          set gp [create_object -type generic_port -parent $m -name $name]
          set_attribute -object $gp -name wireWidth -value $width
          set_attribute -object $gp -name direction -value $direction
      }
    }
  }
}

proc Ncaiu::set_RpMem_memoryType { objList val} {
  puts "WARNING: Ncaiu::set_RpMem_memoryType should be removed. RpMem is not supported for current release"
}

proc Ncaiu::set_RpMem_strRtlNamePrefix { objList val} {
  puts "WARNING: Ncaiu::set_RpMem_strRtlNamePrefix should be removed. RpMem is not supported for current release"
}

proc Ncaiu::get_useCache { objList } {
  set valList [list ]
  foreach obj $objList {
    set attrKey hasProxyCache
    set v [get_parameter -object $obj -name $attrKey]
    lappend valList $v
  }
  return $valList
}

proc Ncaiu::get_protocolType { obj } {
  set socket [get_objects -parent $obj -type socket]
  set attrKey protocolType
  set v [get_parameter -object $socket -name $attrKey]
  return $v
}

proc Ncaiu::get_OttErrInfo { objList } {
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

proc Ncaiu::get_Cache_nSets { objList } {
  set valList [list ]
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey Cache/nSets
    set v [get_parameter -object $obj -name $attrKey]
    lappend valList $v
  }
  return $valList
}

proc Ncaiu::get_Cache_nWays { objList } {
  set valList [list ]
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey Cache/nWays
    set v [get_parameter -object $obj -name $attrKey]
    lappend valList $v
  }
  return $valList
}

proc Ncaiu::get_Cache_useScratchpad { objList } {
  set valList [list ]
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey Cache/useScratchpad
    set v [get_parameter -object $obj -name $attrKey]
    lappend valList $v
  }
  return $valList
}

proc Ncaiu::get_Cache_nTagBanks { objList } {
  set valList [list ]
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey Cache/nTagBanks
    set v [get_parameter -object $obj -name $attrKey]
    lappend valList $v
  }
  return $valList
}

proc Ncaiu::get_Cache_nDataBanks { objList } {
  set valList [list ]
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey Cache/nDataBanks
    set v [get_parameter -object $obj -name $attrKey]
    lappend valList $v
  }
  return $valList
}

proc Ncaiu::get_Cache_TagErrInfo { objList } {
  set valList [list ]
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey Cache/TagErrInfo
    set v [get_parameter -object $obj -name $attrKey]
    lappend valList $v
  }
  return $valList
}

proc Ncaiu::get_Cache_DataErrInfo { objList } {
  set valList [list ]
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey Cache/DataErrInfo
    set v [get_parameter -object $obj -name $attrKey]
    lappend valList $v
  }
  return $valList
}

proc Ncaiu::get_Cache_RepPolicy { objList } {
  set valList [list ]
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey Cache/ImplementationParameters/RepPolicy
    set v [get_parameter -object $obj -name $attrKey]
    lappend valList $v
  }
  return $valList
}

proc Ncaiu::get_Cache_PriSubDiagAddrBits { objList } {
  set valList [list ]
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey Cache/SelectInfo/PriSubDiagAddrBits
    set v [get_parameter -object $obj -name $attrKey]
    lappend valList $v
  }
  return $valList
}

proc Ncaiu::get_Cache_SecSubRows { objList } {
  set valList [list ]
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey Cache/SelectInfo/SecSubRows
    set v [get_parameter -object $obj -name $attrKey]
    lappend valList $v
  }
  return $valList
}

proc Ncaiu::set_Cache_SecSubRows { objList val} {
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey Cache/SelectInfo/SecSubRows
    set_attribute -object $obj -name $attrKey -value_list $val
  }
}

proc Ncaiu::get_NcMode { objList } {
  puts "WARNING: Ncaiu::get_NcMode is deprecated and should be removed. The parameter NcMode is no longer used. "
  return 0
}

proc Ncaiu::get_OttMem_memoryType { objList } {
  set valList [list ]
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey OttMem/Memtype
    set v [get_parameter -object $obj -name $attrKey]
    lappend valList $v
  }
  return $valList
}

proc Ncaiu::get_OttMem_strRtlNamePrefix { objList } {
  set valList [list ]
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey OttMem/rtlPrefixString
    set v [get_parameter -object $obj -name $attrKey]
    lappend valList $v
  }
  return $valList
}

proc Ncaiu::get_DataMem_memoryType { objList } {
  set valList [list ]
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey DataMem/MemType
    set v [get_parameter -object $obj -name $attrKey]
    lappend valList $v
  }
  return $valList
}

proc Ncaiu::get_DataMem_strRtlNamePrefix { objList } {
  set valList [list ]
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey DataMem/rtlPrefixString
    set v [get_parameter -object $obj -name $attrKey]
    lappend valList $v
  }
  return $valList
}

proc Ncaiu::get_TagMem_memoryType { objList } {
  set valList [list ]
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey TagMem/MemType
    set v [get_parameter -object $obj -name $attrKey]
    lappend valList $v
  }
  return $valList
}

proc Ncaiu::get_TagMem_strRtlNamePrefix { objList } {
  set valList [list ]
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey TagMem/rtlPrefixString
    set v [get_parameter -object $obj -name $attrKey]
    lappend valList $v
  }
  return $valList
}

proc Ncaiu::get_RpMem_memoryType { objList } {
  set valList [list ]
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey RpMem/MemType
    set v [get_parameter -object $obj -name $attrKey]
    lappend valList $v
  }
  return $valList
}

proc Ncaiu::get_RpMem_strRtlNamePrefix { objList } {
  set valList [list ]
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey RpMem/rtlPrefixString
    set v [get_parameter -object $obj -name $attrKey]
    lappend valList $v
  }
  return $valList
}

proc Ncaiu::get_Cache_TagBankSelBits { objList {val=""} } {
  set valList [list ]
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey Cache/SelectInfo/TagBankSelBits
    set v [get_parameter -object $obj -name $attrKey]
    lappend valList $v
  }
  return $valList
}

proc Ncaiu::get_Cache_DataBankSelBits { objList {val=""} } {
  set valList [list ]
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey Cache/SelectInfo/DataBankSelBits
    set v [get_parameter -object $obj -name $attrKey]
    lappend valList $v
  }
  return $valList
}

# ***********************************************************************************************************
#
# Description: Assigns the snoopFilter to the object "ncaiu".
#               The internal reference name is "snoopFilter"
# Argument:     List of objects of type "ncaiu" and the Snoop Filter object.
# Return:       The value of the parameter "snoopFilter" for the object of type "ncaiu" is set.
# Example usage: Ncaiu::assign_snoopFilter [Ncaiu::get_units {1}] [SnoopFilter::get_units {0}]
#
# ************************************************************************************************************
proc Ncaiu::assign_snoopFilter { objList snoopFilter } {
  foreach obj $objList {
    update_object -name $obj -type "snoopFilter" -bind $snoopFilter
  }
}

proc get_number_of_items {list_of_protocols protocol} {
  set i [lsearch $list_of_protocols $protocol]
  if {$i > -1} {
    if {$i >= 0 && $i < [llength $list_of_protocols]} {
      return [lindex $list_of_protocols $i+1]
    }
  }
}

proc Ncaiu::test { msg } {
  puts "# In test ncaiu proc: msg = $msg"
}

proc Ncaiu::set_unit_attribute { ind procFunc value } {
  set unit [Ncaiu::get_unit $ind]
  if {$unit == "" } {
    return ""
  }
  set x [$procFunc $unit $value]
}

proc Ncaiu::get_unit_attribute { ind procFunc } {
  set unit [Ncaiu::get_unit $ind]
  if {$unit == "" } {
    return ""
  }
  set val [$procFunc $unit]
  return $val
}

proc Ncaiu::number_of_units { } {
  set ncaius [Ncaiu::get_all_units]
  set val [llength $ncaius]
  return $val
}

proc Ncaiu::get_unit { indx } {
  set ncaius [Ncaiu::get_all_units]
  if {$indx < 0 || $indx >= [llength $ncaius]} {
    return ""
  }
  set val [lindex $ncaius $indx]
  return $val
}

proc Ncaiu::set_clock { objList clk } {
  foreach unit $objList {
    update_object -name $unit -bind $clk -type "domain"
  }
}

proc Ncaiu::get_clock { objList } {
  set clks [list]
  foreach unit $objList {
    set clk [get_objects -parent $unit -type clock_subdomain]
    lappend clks $clk
  }
  return $clks
}

proc Ncaiu::get_all_units { } {
  set chip     [get_objects -type chip -parent root]
  set objects [get_objects -type ncaiu -parent $chip]
  if {$objects == ""} {
    error "Error: There are no Ncaiu units created. Please create the ncaiu units before assigning parameters to them."
  }
  return $objects
}

proc Ncaiu::get_units { list_of_indices } {
  set units [list]
  set chip     [get_objects -type chip -parent root]
  foreach indx $list_of_indices {
    set objects [get_objects -type ncaiu -parent $chip]
    set val [lindex $objects $indx]
    lappend units $val
  }
  return $units
}

package provide Ncaiu $Ncaiu::version
package require Tcl 8.5
