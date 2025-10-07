# *********************************************************************************************
#
# This script provides procedures to set parameters on the object of type "dmi". 
# 
# *********************************************************************************************
package require Socket 2.0
package require Project 2.0
package require Interleaving 2.0

namespace eval Dmi {
  namespace export set_createdUnits
  namespace export set_protocolType
  namespace export set_useCache
  namespace export set_WrDataErrInfo
  namespace export set_nPerfCounters
  namespace export set_useAtomic
  namespace export set_nSets
  namespace export set_nWays
  namespace export set_nUnitTraceBufSize
  namespace export set_useScratchpad
  namespace export set_nTagBanks
  namespace export set_nDataBanks
  namespace export set_useDinBuffer
  namespace export set_useDoutBuffer
  namespace export set_RepPolicy
  namespace export set_PriSubDiagAddrBits
  namespace export set_SecSubRows
  namespace export set_TagBankSelBits
  namespace export set_DataBankSelBits
  namespace export set_nRttCtrlEntries
  namespace export set_nWttCtrlEntries
  namespace export set_useWayPartitioning
  namespace export set_nWayPartitioningRegisters
  namespace export set_useMemRspIntrlv
  namespace export set_enableReadRspInterleaving
  namespace export set_nAddrTransRegisters
  namespace export set_DmiQoSThVal
  namespace export set_nDmiWttQoSRsv
  namespace export set_nDmiRttQoSRsv
  namespace export set_TagMem_rtlPrefixString
  namespace export set_TagMem_memType
  namespace export set_RpMem_rtlPrefixString
  namespace export set_RpMem_memType
  namespace export set_DataMem_memType
  namespace export set_DataMem_rtlPrefixString
  namespace export set_WrDataMem_memType
  namespace export set_WrDataMem_rtlPrefixString
  namespace export set_RdDataMem_memType
  namespace export set_RdDataMem_rtlPrefixString

  namespace export get_protocolType
  namespace export get_WrDataErrInfo
  namespace export get_useCache
  namespace export get_useAtomic
  namespace export get_nSets
  namespace export get_nWays
  namespace export get_useScratchpad
  namespace export get_nTagBanks
  namespace export get_nDataBanks
  namespace export get_TagErrInfo
  namespace export get_DataErrInfo
  namespace export get_useDinBuffer
  namespace export get_useDoutBuffer
  namespace export get_RepPolicy
  namespace export get_PriSubDiagAddrBits
  namespace export get_SecSubRows
  namespace export get_TagBankSelBits
  namespace export get_DataBankSelBits
  namespace export get_nRttCtrlEntries
  namespace export get_nWttCtrlEntries
  namespace export get_nWayPartitioningRegisters
  namespace export get_useMemRspIntrlv
  namespace export get_enableReadRspInterleaving
  namespace export get_nAddrTransRegisters
  namespace export get_DmiQoSThVal
  namespace export get_nDmiWttQoSRsv
  namespace export get_nDmiRttQoSRsv
  namespace export get_TagMem_rtlPrefixString
  namespace export get_TagMem_MemType
  namespace export get_RpMem_rtlPrefixString
  namespace export get_RpMem_MemType
  namespace export get_DataMem_MemType
  namespace export get_DataMem_rtlPrefixString
  namespace export get_WrDataMem_MemType ; # Deprecated
  namespace export get_WrDataMem_memType
  namespace export get_WrDataMem_rtlPrefixString
  namespace export get_RdDataMem_MemType ; # Deprecated
  namespace export get_RdDataMem_memType
  namespace export get_RdDataMem_rtlPrefixString

  namespace export print_parameters
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
  set Description "Maestro_Dmi"

  variable home [file join [pwd] [file dirname [info script]]]
  variable created_units [list]
}

# ***********************************************************************************************************
#
# Description:  Sets the value for the parameter "Number of DMI write buffers".
#               The internal parameter name is "nDmiRbCredits".
# Argument:     List of objects of type "dmi" and the value for the parameter "nDmiRbCredits".
# Return:       The value of the parameter "nDmiRbCredits" for the object of type "dmi" is set.
# Example usage: Dmi::set_nDmiRbCredits [Dmi::get_all_units] 16
#
# ************************************************************************************************************
proc Dmi::set_nDmiRbCredits { objList val} {
  foreach obj $objList {
    set attrKey nDmiRbCredits
    set_attribute -object $obj -name $attrKey -value $val
  }
}

# ***********************************************************************************************************
#
# Description:  Sets the value for the parameter "Credits for Native Protocol".
#               The internal parameter name is "nNativeCredits".
# Argument:     List of objects of type "dmi" and the value for the parameter "nNativeCredits".
# Return:       The value of the parameter "nNativeCredits" for the object of type "dmi" is set.
# Example usage: Dmi::set_nNativeCredits [Dmi::get_all_units] 15
#
# ************************************************************************************************************
proc Dmi::set_nNativeCredits { objList val} {
  foreach obj $objList {
    set attrKey nNativeCredits
    set_attribute -object $obj -name $attrKey -value $val
  }
}

# ***********************************************************************************************************
#
# Description:  Sets the value for the parameter "Outstanding transaction table Entries".
#               The internal parameter name is "nOttCtrlEntries".
# Argument:     List of objects of type "dmi" and the value for the parameter "nOttCtrlEntries".
# Return:       The value of the parameter "nOttCtrlEntries" for the object of type "dmi" is set.
# Example usage: Dmi::set_nOttCtrlEntries [Dmi::get_all_units] 48
#
# ************************************************************************************************************
proc Dmi::set_nOttCtrlEntries { objList val} {
  foreach obj $objList {
    set attrKey nOttCtrlEntries
    set_attribute -object $obj -name $attrKey -value $val
  }
}

# ***********************************************************************************************************
#
# Description:  Sets the value for the parameter "Max Outstanding read transaction".
#               The internal parameter name is "nRttCtrlEntries".
# Argument:     List of objects of type "dmi" and the value for the parameter "nRttCtrlEntries".
# Return:       The value of the parameter "nRttCtrlEntries" for the object of type "dmi" is set.
# Example usage: Dmi::set_nRttCtrlEntries [Dmi::get_all_units] 16
#
# ************************************************************************************************************
proc Dmi::set_nRttCtrlEntries { objList val} {
  foreach obj $objList {
    set attrKey nRttCtrlEntries
    set_attribute -object $obj -name $attrKey -value $val
  }
}

# ***********************************************************************************************************
#
# Description:  Sets the value for the parameter "Max Outstanding write transaction".
#               The internal parameter name is "nWttCtrlEntries".
# Argument:     List of objects of type "dmi" and the value for the parameter "nWttCtrlEntries".
# Return:       The value of the parameter "nWttCtrlEntries" for the object of type "dmi" is set.
# Example usage: Dmi::set_nWttCtrlEntries [Dmi::get_all_units] 16
#
# ************************************************************************************************************
proc Dmi::set_nWttCtrlEntries { objList val} {
  foreach obj $objList {
    set attrKey nWttCtrlEntries
    set_attribute -object $obj -name $attrKey -value $val
  }
}

# ***********************************************************************************************************
#
# Description:  Add placeholder signal to the "dmi" unit.
# Argument:     The object of type "dmi", the name for the rtlprefix, the name of the placeholder signal,
#               the width of the placeholder signal, the direction of the placeholder signal.
# Example usage: Dmi::add_placeholder_signal  [Dmi::get_units {0}] "dmi1_ph" "sig1" 4 IN
#
# ************************************************************************************************************
# proc Dmi::add_placeholder_signal { obj rtlprefix name width direction } {
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
proc Dmi::add_placeholder_signal { obj rtlprefix name width direction } {
  set pl $obj/placeholder
  set gp [create_object -type generic_port -parent $pl -name $name]
  set_attribute -object $pl -name wireRtlPrefix -value $rtlprefix
  set_attribute -object $gp -name wireWidth -value $width 
  set_attribute -object $gp -name direction -value $direction
}

# ********************************************************************************************************
#
# Description: This proc is used to enable System Memory Cache in the DMI.
# Argument:    List of objects of type "dmi" and the boolean value for the parameter "useCache".
# Example :    Dmi::set_useCache [Dmi::get_units {0}] true
#
# ********************************************************************************************************
proc Dmi::set_useCache { objList val} {
  foreach obj $objList {
    set attrKey hasSysMemCache
    set_attribute -object $obj -name $attrKey -value $val
  }
}

# ***********************************************************************************************************
#
# Description:  Sets the value for the parameter "Number of performance counters".
#               The internal parameter name is "nPerfCounters".
# Argument:     List of objects of type "dmi" and the value for the parameter "nPerfCounters".
# Return:       The value of the parameter "nPerfCounters" for the object of type "dmi" is set.
# Example usage: Dmi::set_nPerfCounters [Dmi::get_all_units] 4
#
# ************************************************************************************************************
proc Dmi::set_nPerfCounters { objList val} {
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
# Return:       The value of the parameter "nCMDSkidBufSize" for the object of type "dmi" is set.
# Example usage: Dmi::set_nCMDSkidBufSize [Dmi::get_all_units] 4
#
# ************************************************************************************************************
proc Dmi::set_nCMDSkidBufSize { objList val } {
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
# Return:       The value of the parameter "nCMDSkidBufArb" for the object of type "dmi" is set.
# Example usage: Dmi::set_nCMDSkidBufArb [Dmi::get_all_units] 4
#
# ************************************************************************************************************
proc Dmi::set_nCMDSkidBufArb { objList val } {
  foreach obj $objList {
    set attrKey nCMDSkidBufArb
    set_attribute -object $obj -name $attrKey -value $val
  }
}

# ***********************************************************************************************************
#
# Description:  Sets the value for the parameter "Total depth of skid buffer for coherent DMI transactions".
#               The internal parameter name is "nMrdSkidBufSize".
# Argument:     List of objects of type "dmi" and the value for the parameter "nMrdSkidBufSize".
# Return:       The value of the parameter "nMrdSkidBufSize" for the object of type "dmi" is set.
# Example usage: Dmi::set_nMrdSkidBufSize [Dmi::get_all_units] 4
#
# ************************************************************************************************************
proc Dmi::set_nMrdSkidBufSize { objList val } {
  foreach obj $objList {
    set attrKey nMrdSkidBufSize
    set_attribute -object $obj -name $attrKey -value $val
  }
}

# ***********************************************************************************************************
#
# Description:  Sets the value for the parameter "Depth of skid buffer visible to arbitration for coherent DMI transactions".
#               The internal parameter name is "nMrdSkidBufArb".
# Argument:     List of objects of type "dmi" and the value for the parameter "nMrdSkidBufArb".
# Return:       The value of the parameter "nMrdSkidBufArb" for the object of type "dmi" is set.
# Example usage: Dmi::set_nMrdSkidBufSize [Dmi::get_all_units] 4
#
# ************************************************************************************************************
proc Dmi::set_nMrdSkidBufArb { objList val } {
  foreach obj $objList {
    set attrKey nMrdSkidBufArb
    set_attribute -object $obj -name $attrKey -value $val
  }
}

# ********************************************************************************************************
#
# Description: This proc is used to enable Atomic Engine in the DMI.
# Argument:    List of objects of type "dmi" and the boolean value for the parameter "useAtomic".
# Example :    Dmi::set_useAtomic [Dmi::get_units {0}] true
#
# ********************************************************************************************************
proc Dmi::set_useAtomic { objList val} {
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey useAtomic
    set_attribute -object $obj -name $attrKey -value $val
  }
}

# ***********************************************************************************************************
#
# Description:   Sets the value for the parameter "Number of Sets".
#                The internal parameter name is "nSets".
# Argument:      List of objects of type "dmi" and the value for the parameter "nSets".
# Example usage: Dmi::set_nSets [Dmi::get_units {1}] 1024
#
# ************************************************************************************************************
proc Dmi::set_nSets { objList val} {
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey Cache/nSets
    set_attribute -object $obj -name $attrKey -value $val
  }
}

# ***********************************************************************************************************
#
# Description:   Sets the value for the parameter "Number of Ways".
#                The internal parameter name is "nWays".
# Argument:      List of objects of type "dmi" and the value for the parameter "nWays".
# Example usage: Dmi::set_nWays [Dmi::get_units {1}] 8
#
# ************************************************************************************************************
proc Dmi::set_nWays { objList val} {
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey Cache/nWays
    set_attribute -object $obj -name $attrKey -value $val
  }
}

# ***********************************************************************************************************
#
# Description:   Sets the value for the parameter "Unit Trace Buffer Size".
#                The internal parameter name is "nUnitTraceBufSize".
# Argument:      List of objects of type "dmi" and the value for the parameter "nUnitTraceBufSize".
# Example usage: Dmi::set_nUnitTraceBufSize [Dmi::get_units {1}] 8
#
# ************************************************************************************************************

proc Dmi::set_nUnitTraceBufSize { val} {
  set obj [_getTopology]
  set attrKey nUnitTraceBufSize
  set_attribute -object $obj -name $attrKey -value $val
}

# ***********************************************************************************************************
#
# Description:   Sets the value for the parameter "Enable Scratchpad".
#                The internal parameter name is "useScratchpad".
# Argument:      List of objects of type "dmi" and the value for the parameter "useScratchpad".
# Example usage: Dmi::set_Cache_useScratchpad [Dmi::get_units {1}] true
#
# ************************************************************************************************************
proc Dmi::set_useScratchpad { objList val} {
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey Cache/useScratchpad
    set_attribute -object $obj -name $attrKey -value $val
  }
}

# ***********************************************************************************************************
#
# Description:   Sets the value for the parameter "Number of Tag Banks".
#                The internal parameter name is "nTagBanks".
# Argument:      List of objects of type "dmi" and the value for the parameter "nTagBanks".
# Example usage: Dmi::set_nTagBanks [Dmi::get_units {1}] 2
#
# ************************************************************************************************************
proc Dmi::set_nTagBanks { objList val} {
  foreach obj $objList {
    set attrKey nTagBanks
    set_attribute -object $obj -name $attrKey -value $val
  }
}

# ***********************************************************************************************************
#
# Description:   Sets the value for the parameter "Number of Data Banks".
#                The internal parameter name is "nDataBanks".
# Argument:      List of objects of type "dmi" and the value for the parameter "nDataBanks".
# Example usage: Dmi::set_nDataBanks [Dmi::get_units {1}] 4
#
# ************************************************************************************************************
proc Dmi::set_nDataBanks { objList val} {
  foreach obj $objList {
    set attrKey nDataBanks
    set_attribute -object $obj -name $attrKey -value $val
  }
}

# ********************************************************************************************************
#
# Description: This proc is used to set the Replacement Policy.
# Argument:    List of objects of type "dmi" and the value for the parameter "RepPolicy"
# Example :    Dmi::set_Cache_RepPolicy [Dmi::get_units {0}] RANDOM
#
# ********************************************************************************************************
proc Dmi::set_RepPolicy { objList val} {
  foreach obj $objList {
    set attrKey cacheReplPolicy
    set_attribute -object $obj -name $attrKey -value $val
  }
}

# ********************************************************************************************************
#
# Description: This proc is used to set the Primary Set selection bit. 
# Argument:    List of objects of type "dmi" and the list of values for the parameter "PriSubDiagAddrBits".
# Example :    Dmi::set_Cache_PriSubDiagAddrBits [Dmi::get_units {1}] [list 10 11 12 13 14 15 16 17 18 19]
#
# ********************************************************************************************************
proc Dmi::set_PriSubDiagAddrBits { objList val} {
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey Cache/SelectInfo/PriSubDiagAddrBits
    set_attribute -object $obj -name $attrKey -value_list $val
  }
}

# ********************************************************************************************************
#
# Description: This proc is used to set the Secondary selection bit. 
# Argument:    List of objects of type "dmi" and the list of values for the parameter "SecSubRows".
# Example :    Dmi::set_Cache_PriSubDiagAddrBits [Dmi::get_units {1}] [list 0xab 0xde]
#
# ********************************************************************************************************
proc Dmi::set_SecSubRows { objList val} {
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey Cache/SelectInfo/SecSubRows
    set_attribute -object $obj -name $attrKey -value_list $val
  }
}

# ********************************************************************************************************
#
# Description: This proc is used to set the Tag bank selection bit. This bit must be one of the bits 
#              from the primary selection bits.
# Argument:    List of objects of type "dmi" and the list of values for the parameter "TagBankSelBits".
# Example :    Dmi::set_TagBankSelBits [Dmi::get_units {0}] [list 10]
#
# ********************************************************************************************************
proc Dmi::set_TagBankSelBits { objList val} {
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey Cache/SelectInfo/TagBankSelBits
    set_attribute -object $obj -name $attrKey -value_list $val
  }
}

# ********************************************************************************************************
#
# Description: This proc is used to set the Data bank selection bit. These bits must be one of the bits 
#              from the primary selection bits.
# Argument:    List of objects of type "dmi" and the list of values for the parameter "DataBankSelBits".
# Example :    Dmi::set_DataBankSelBits [Dmi::get_units {0}] [list 10]
#
# ********************************************************************************************************
proc Dmi::set_DataBankSelBits { objList val} {
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey Cache/SelectInfo/DataBankSelBits
    set_attribute -object $obj -name $attrKey -value_list $val
  }
}

# ********************************************************************************************************
#
# Description: This proc is used to set the Number of Partitioning Registers.
# Argument:    List of objects of type "dmi" and the value for the parameter "nWayPartitionRegisters".
# Example :    Dmi::set_nWayPartitioningRegisters [Dmi::get_units {0}] 4
#
# ********************************************************************************************************
proc Dmi::set_nWayPartitioningRegisters { objList val} {
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey ImplementationParameters/nWayPartitioningRegisters
    set_attribute -object $obj -name $attrKey -value $val
  }
}

# ********************************************************************************************************
#
# Description: This proc is used to set the Number of Address Translation Registers. 
# Argument:    List of objects of type "dmi" and the value for the parameter "nAddrTransRegisters".
# Example :    Dmi::set_nAddrTransRegisters [Dmi::get_units {0}] 4
#
# ********************************************************************************************************
proc Dmi::set_nAddrTransRegisters { objList val} {
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey ImplementationParameters/nAddrTransRegisters
    set_attribute -object $obj -name $attrKey -value $val
  }
}

proc Dmi::set_DmiQoSThVal { objList val } {
  foreach obj $objList {
    set attrKey DmiQoSThVal
    set_attribute -object $obj -name $attrKey -value $val
  }
}

proc Dmi::set_nDmiWttQoSRsv { objList val } {
  foreach obj $objList {
    set attrKey nDmiWttQoSRsv
    set_attribute -object $obj -name $attrKey -value $val
  }
}

proc Dmi::set_nDmiRttQoSRsv { objList val } {
  foreach obj $objList {
    set attrKey nDmiRttQoSRsv
    set_attribute -object $obj -name $attrKey -value $val
  }
}

proc Dmi::set_DataMem_memType { objList val} {
  set attrKey memoryType
  foreach obj $objList {
    set value [get_parameter -object $obj -name hasSysMemCache -silent]
    if {$value != "" && $value != "false"} {
      set memList [get_objects -parent $obj -type internal_memory -subtype DATA]
      foreach m $memList {
          set_attribute -object $m -name $attrKey -value $val
      }
    }
  }
}

proc Dmi::set_DataMem_rtlPrefix { objList val} {
  foreach obj $objList {
    set value [get_parameter -object $obj -name hasSysMemCache -silent]
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

proc Dmi::add_DataMem_signal { objList name width direction} {
  foreach obj $objList {
    set value [get_parameter -object $obj -name hasSysMemCache -silent]
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

proc Dmi::set_TagMem_memType { objList val} {
  set attrKey memoryType
  foreach obj $objList {
    set value [get_parameter -object $obj -name hasSysMemCache -silent]
    if {$value != "" && $value != "false"} {
      set memList [get_objects -parent $obj -type internal_memory -subtype TAG]
      foreach m $memList {
          set_attribute -object $m -name $attrKey -value $val
      }
    }
  }
}

proc Dmi::set_TagMem_rtlPrefix { objList val} {
  foreach obj $objList {
    set value [get_parameter -object $obj -name hasSysMemCache -silent]
    if {$value != "" && $value != "false"} {
      set memList [get_objects -parent $obj -type internal_memory -subtype TAG]
      set i 0
      foreach m $memList {
          rename_object -name $m -new_name $val$i
          incr i
      }
    }
  }
}

proc Dmi::add_TagMem_signal { objList name width direction} {
  foreach obj $objList {
    set value [get_parameter -object $obj -name hasSysMemCache -silent]
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

proc Dmi::set_RpMem_memoryType { objList val} {
  puts "WARNING: RpMem is not supported for current release"
}

proc Dmi::set_RpMem_strRtlNamePrefix { objList val} {
  puts "WARNING: RpMem is not supported for current release"
}

proc Dmi::set_useDinBuffer { objList val} {
  puts "WARNING: Dmi::set_useDinBuffer is obsolete and should be removed. The parameter useDinBuffer is no longer used."
}

proc Dmi::set_useDoutBuffer { objList val} {
  puts "WARNING: Dmi::useDoutBuffer is obsolete and should be removed. The parameter useDoutBuffer is no longer used."
}

proc Dmi::set_WrDataMem_memType { objList val} {
  set attrKey memoryType
  foreach obj $objList {
    set memList [get_objects -parent $obj -type internal_memory -subtype WDATA]
    foreach m $memList {
        set_attribute -object $m -name $attrKey -value $val
    }
  }
}

proc Dmi::set_WrDataMem_strRtlNamePrefix { objList val} {
  foreach obj $objList {
    set memList [get_objects -parent $obj -type internal_memory -subtype WDATA]
    set i 0
    foreach m $memList {
        rename_object -name $m -new_name $val$i
        incr i
    }
  }
}

proc Dmi::add_WrDataMem_signal { objList name width direction} {
  foreach obj $objList {
    set memList [get_objects -parent $obj -type internal_memory -subtype WDATA]
    foreach m $memList {
        set rtlPrefix [Project::abbrev $m]
        set gp [create_object -type generic_port -parent $m -name $name]
        set_attribute -object $gp -name wireWidth -value $width
        set_attribute -object $gp -name direction -value $direction
    }
  }
}

proc Dmi::set_RdDataMem_memType { objList val} {
  set attrKey memoryType
  foreach obj $objList {
    set memList [get_objects -parent $obj -type internal_memory -subtype RDATA]
    foreach m $memList {
        set_attribute -object $m -name $attrKey -value $val
    }
  }
}

proc Dmi::set_RdDataMem_strRtlNamePrefix { objList val} {
  foreach obj $objList {
    set memList [get_objects -parent $obj -type internal_memory -subtype RDATA]
    set i 0
    foreach m $memList {
        rename_object -name $m -new_name $val$i
        incr i
    }
  }
}

proc Dmi::add_RdDataMem_signal { objList name width direction} {
  foreach obj $objList {
    set memList [get_objects -parent $obj -type internal_memory -subtype RDATA]
    foreach m $memList {
        set rtlPrefix [Project::abbrev $m]
        set gp [create_object -type generic_port -parent $m -name $name]
        set_attribute -object $gp -name wireWidth -value $width
        set_attribute -object $gp -name direction -value $direction
    }
  }
}

proc Dmi::get_useCache { objList } {
  set valList [list ]
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey useCache
    set v [get_parameter -object $obj -name $attrKey]
    lappend valList $v
  }
  return $valList
}

proc Dmi::get_WrDataErrInfo { objList } {
  set valList [list ]
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey WrDataErrInfo
    set v [get_parameter -object $obj -name $attrKey]
    lappend valList $v
  }
  return $valList
}

proc Dmi::get_useAtomic { objList } {
  set valList [list ]
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey useAtomic
    set v [get_parameter -object $obj -name $attrKey]
    lappend valList $v
  }
  return $valList
}

proc Dmi::get_nSets { objList } {
  set valList [list ]
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey nSets
    set v [get_parameter -object $obj -name $attrKey]
    lappend valList $v
  }
  return $valList
}

proc Dmi::get_nWays { objList } {
  set valList [list ]
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey nWays
    set v [get_parameter -object $obj -name $attrKey]
    lappend valList $v
  }
  return $valList
}

proc Dmi::get_useScratchpad { objList } {
  set valList [list ]
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey useScratchpad
    set v [get_parameter -object $obj -name $attrKey]
    lappend valList $v
  }
  return $valList
}

proc Dmi::get_nTagBanks { objList } {
  set valList [list ]
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey nTagBanks
    set v [get_parameter -object $obj -name $attrKey]
    lappend valList $v
  }
  return $valList
}

proc Dmi::get_nDataBanks { objList } {
  set valList [list ]
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey nDataBanks
    set v [get_parameter -object $obj -name $attrKey]
    lappend valList $v
  }
  return $valList
}

proc Dmi::get_TagErrInfo { objList } {
  set valList [list ]
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey TagErrInfo
    set v [get_parameter -object $obj -name $attrKey]
    lappend valList $v
  }
  return $valList
}

proc Dmi::get_DataErrInfo { objList } {
  set valList [list ]
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey DataErrInfo
    set v [get_parameter -object $obj -name $attrKey]
    lappend valList $v
  }
  return $valList
}

proc Dmi::get_useDinBuffer { objList } {
  set valList [list ]
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey useDinBuffer
    set v [get_parameter -object $obj -name $attrKey]
    lappend valList $v
  }
  return $valList
}

proc Dmi::get_useDoutBuffer { objList } {
  set valList [list ]
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey useDoutBuffer
    set v [get_parameter -object $obj -name $attrKey]
    lappend valList $v
  }
  return $valList
}

proc Dmi::get_RepPolicy { objList } {
  set valList [list ]
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey RepPolicy
    set v [get_parameter -object $obj -name $attrKey]
    lappend valList $v
  }
  return $valList
}

proc Dmi::get_nRPPorts { objList } {
  set valList [list ]
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey nRPPorts
    set v [get_parameter -object $obj -name $attrKey]
    lappend valList $v
  }
  return $valList
}

proc Dmi::get_PriSubDiagAddrBits { objList } {
  set valList [list ]
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey PriSubDiagAddrBits
    set v [get_parameter -object $obj -name $attrKey]
    lappend valList $v
  }
  return $valList
}

proc Dmi::get_SecSubRows { objList } {
  set valList [list ]
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey SecSubRows
    set v [get_parameter -object $obj -name $attrKey]
    lappend valList $v
  }
  return $valList
}

proc Dmi::get_TagBankSelBits { objList } {
  set valList [list ]
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey TagBankSelBits
    set v [get_parameter -object $obj -name $attrKey]
    lappend valList $v
  }
  return $valList
}

proc Dmi::get_DataBankSelBits { objList } {
  set valList [list ]
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey DataBankSelBits
    set v [get_parameter -object $obj -name $attrKey]
    lappend valList $v
  }
  return $valList
}

proc Dmi::get_nNativeCredits { objList } {
  set valList [list ]
  foreach obj $objList {
    set attrKey nNativeCredits
    set v [get_parameter -object $obj -name $attrKey]
    lappend valList $v
  }
  return $valList
}

proc Dmi::get_nOttCtrlEntries { objList } {
  set valList [list ]
  foreach obj $objList {
    set attrKey nOttCtrlEntries
    set v [get_parameter -object $obj -name $attrKey]
    lappend valList $v
  }
  return $valList
}

proc Dmi::get_nRttCtrlEntries { objList } {
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

proc Dmi::get_nWttCtrlEntries { objList } {
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

proc Dmi::get_nWayPartitioningRegisters { objList } {
  set valList [list ]
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey nWayPartitioningRegisters
    set v [get_parameter -object $obj -name $attrKey]
    lappend valList $v
  }
  return $valList
}

proc Dmi::get_useMemRspIntrlv { objList } {
  puts "WARNING: Dmi::set_useMemRspIntrlv is deprecated and should be removed. Parameter is now enableReadRspInterleaving."
  set valList [list ]
  return $valList
}

proc Dmi::get_enableReadRspInterleaving { objList } {
  set attrKey enableReadRspInterleaving
  set valList [list ]
  foreach obj $objList {
    set v [get_parameter -object $obj -name $attrKey]
    lappend valList $v
  }
  return $valList
}

proc Dmi::get_nAddrTransRegisters { objList } {
  set valList [list ]
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey nAddrTransRegisters
    set v [get_parameter -object $obj -name $attrKey]
    lappend valList $v
  }
  return $valList
}

proc Dmi::get_DmiQoSThVal { objList } {
  set valList [list ]
  foreach obj $objList {
    set attrKey DmiQoSThVal
    set v [get_parameter -object $obj -name $attrKey]
    lappend valList $v
  }
  return $valList
}

proc Dmi::get_nDmiWttQoSRsv { objList } {
  set valList [list ]
  foreach obj $objList {
    set attrKey nDmiWttQoSRsv
    set v [get_parameter -object $obj -name $attrKey]
    lappend valList $v
  }
  return $valList
}

proc Dmi::get_nDmiRttQoSRsv { objList } {
  set valList [list ]
  foreach obj $objList {
    set attrKey nDmiRttQoSRsv
    set v [get_parameter -object $obj -name $attrKey]
    lappend valList $v
  }
  return $valList
}

proc Dmi::get_TagMem_rtlPrefixString { objList } {
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

proc Dmi::get_TagMem_MemType { objList } {
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

proc Dmi::get_Mem_memType { objList role} {
  set valList [list ]
  set attrKey memoryType
  foreach obj $objList {
    set val "?"
    set value [get_parameter -object $obj -name hasSysMemCache -silent]
    if {$value != "" && $value != "false"} {
      set memList [get_objects -parent $obj -type internal_memory -subtype $role]
      foreach m $memList {
          set val [get_parameter -object $m -name $attrKey]
          break; # get the first found type
      }
    }
    lappend valList $val
  }
  return $valList
}


proc Dmi::get_DataMem_memType { objList } {
  return [Dmi::get_Mem_memType $objList "DATA"]
}

proc Dmi::get_WrDataMem_memType { objList } {
  return [Dmi::get_Mem_memType $objList "WDATA"]
}

proc Dmi::get_RdDataMem_memType { objList } {
  return [Dmi::get_Mem_memType $objList "RDATA"]
}

proc Dmi::get_TagMem_memType { objList } {
  return [Dmi::get_Mem_memType $objList "TAG"]
}

proc Dmi::get_WrDataMem_rtlPrefixString { objList } {
  set valList [list ]
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey WrDataMem/rtlPrefixString
    set v [get_parameter -object $obj -name $attrKey]
    lappend valList $v
  }
  return $valList
}

proc Dmi::get_WrDataMem_MemType { objList } {
  set valList [list ]
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey WrDataMem/MemType
    set v [get_parameter -object $obj -name $attrKey]
    lappend valList $v
  }
  return $valList
}

proc Dmi::get_RdDataMem_rtlPrefixString { objList } {
  set valList [list ]
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey RdDataMem/rtlPrefixString
    set v [get_parameter -object $obj -name $attrKey]
    lappend valList $v
  }
  return $valList
}

proc Dmi::get_RdDataMem_MemType { objList } {
  set valList [list ]
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey RdDataMem/MemType
    set v [get_parameter -object $obj -name $attrKey]
    lappend valList $v
  }
  return $valList
}

proc Dmi::get_RpMem_rtlPrefixString { objList } {
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

proc Dmi::get_RpMem_MemType { objList } {
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

proc Dmi::get_DataMem_MemType { objList } {
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

proc Dmi::get_DataMem_rtlPrefixString { objList } {
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

proc Dmi::set_unit_attribute { ind procFunc value } {
  set unit [Dmi::get_unit $ind]
  if {$unit == "" } {
    return ""
  }
  set x [$procFunc $unit $value]
}

proc Dmi::get_unit_attribute { ind procFunc } {
  set unit [Dmi::get_unit $ind]
  if {$unit == "" } {
    return ""
  }
  set val [$procFunc $unit]
  return $val
}

proc Dmi::number_of_units { } {
  set units [Dmi::get_all_units]
  set val [llength $units]
  return $val
}

proc Dmi::get_unit { indx } {
  set units [Dmi::get_all_units]
  if {$indx < 0 || $indx >= [llength $units]} {
    return ""
  }
  set val [lindex $units $indx]
  return $val
}

proc Dmi::set_clock { objList clk } {
  foreach unit $objList {
    update_object -name $unit -bind $clk -type "domain"
  }
}

proc Dmi::get_clock { objList } {
  set clks [list]
  foreach unit $objList {
    set clk [get_objects -parent $unit -type clock_subdomain]
    lappend clks $clk
  }
  return $clks
}

proc Dmi::get_all_units { } {
  set chip     [get_objects -type chip -parent root]
  set objects [get_objects -type dmi -parent $chip]
  if {$objects == ""} {
    error "Error: There are no DMI units created. Please create the DMI units before assigning parameters to them."
  }
  return $objects
}

proc Dmi::get_units { list_of_indices } {
  set units [list]
  set chip     [get_objects -type chip -parent root]
  foreach indx $list_of_indices {
    set objects [get_objects -type dmi -parent $chip]
    set val [lindex $objects $indx]
    lappend units $val
  }
  return $units
}

proc Dmi::set_useMemRspIntrlv { objList val } {
  puts "WARNING: Dmi::set_useMemRspIntrlv is deprecated and should be removed. Parameter is now enableReadRspInterleaving."
}

proc Dmi::set_enableReadRspInterleaving { objList val } {
  set attrKey enableReadRspInterleaving
  foreach obj $objList {
    set_attribute -object $obj -name $attrKey -value $val
  }
}

proc Dmi::test { msg } {
  puts "# In test dmi proc: msg = $msg"
}


proc Dmi::set_useWayPartitioning { objList val} {
  puts "WARNING: Dmi::set_useWayPartioning is deprecated and should be removed. The parameter 'useWayPartioning' is no longer used."
}

proc Dmi::set_createdUnits { units } {
  set Dmi::created_units $units
  return [llength $Dmi::created_units]
}

proc Dmi::set_nRPPorts { objList val} {
  puts "WARNING: Dmi::set_nRPorts is obsolete. The parameter nRPorts is not user-settable."
}

package provide Dmi $Dmi::version
package require Tcl 8.5

