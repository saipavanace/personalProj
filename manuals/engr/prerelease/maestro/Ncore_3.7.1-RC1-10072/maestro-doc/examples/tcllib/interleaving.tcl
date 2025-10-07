namespace eval Interleaving {
  namespace export print_parameters
  namespace export set_DCE_PrimarySelBits
  namespace export set_PrimaryBits 
  namespace export set_SecondaryBits
  namespace export createMemorySet
  namespace export set_group_to_memorySet
  namespace export set_groups_MemorySet
  namespace export set_groups_MemorySet0
  namespace export set_groups_MemorySet1
  namespace export create_function
  namespace export set_initiator_group

  set version 2.0
  set Description "Maestro_Interleaving"

  variable home [file join [pwd] [file dirname [info script]]]
  variable created_units [list]
}

# ***********************************************************************************************************
#
# Description:   This procedure is used to access the memory map.
# Return :       Retunrs the existing object of type "memory_map"
# Example usage:  set mm    [_getMemoryMap]
#
# ************************************************************************************************************
proc _getMemoryMap { } {
  set chip     [get_objects -type chip -parent root]
  set system   [get_objects -type system -parent $chip]
  set subsystem [get_objects -type subsystem -parent $system]
  set mm [get_objects -type memory_map -parent $subsystem -silent]
  return $mm
}

# ***********************************************************************************************************
#
# Description:   Sets the value for the parameter "System Directory Primary Set select bits".
#                The internal parameter name is "dceInterleavingBits ".
# Argument:      The value for the parameter "dceInterleavingBits ".
# Example usage: Interleaving::set_DCE_PrimarySelBits [list 1 2 3]
#
# ************************************************************************************************************
proc Interleaving::set_DCE_PrimarySelBits { val } {
  set obj [_getMemoryMap]
  set attrKey dceInterleavingBits 
  set_attribute -object $obj -name $attrKey -value_list $val
}

# ***********************************************************************************************************
#
# Description:   This procedure is used to set the Dynamic Memory Groups for the Memory Set.
# Argument:      The list of MEMORY sockets grouped into list, the name of the object of type "memory_set" 
# Example usage: Interleaving::set_groups_MemorySet [list [list "dmi0" "dmi1"] [list "dmi2"]] "ms0"
#
# ************************************************************************************************************
proc Interleaving::set_groups_MemorySet { list_dmis memorySetName} {
  
  set chip     [get_objects -type chip -parent root]
  set system   [get_objects -type system -parent $chip]
  set subsystem [get_objects -type subsystem -parent $system]
  set mm [get_objects -type memory_map -parent $subsystem]
  set memorySet [create_object -type memory_set -parent $mm -name $memorySetName]

  set MemorySet0 $list_dmis
  for {set j 0} {$j < [llength $MemorySet0]} {incr j} {
    set (memoryGroup$j) [create_object -type dynamic_memory_group -parent $memorySet -name mg$j]
    
    set dmis_group [lindex $MemorySet0 $j]
    set dmi_list [list]
    foreach dmi_name $dmis_group {
      set socket $subsystem/$dmi_name
      lappend dmi_list $socket
    }
    update_object -name $(memoryGroup$j) -value_list $dmi_list -type physicalChannels
  }
  return $memorySet
}

# ***********************************************************************************************************
#
# Description:   This procedure creates an InitiatorGroup under the MemoryMap.
# Argument:      The list of INITIATOR sockets grouped into list, the interleaving bits for the group, and the name of the object of type "initiator_group" 
# Example usage: Interleaving::set_initiator_group [list $aiu0 $aiu1 $aiu2 $aiu3] [list 6 7] "ig0"
#         where: $aiu0 contains the full path to an initiator socket (eg. project/chip/system/subsystem/aiu0)
#
# ************************************************************************************************************
proc Interleaving::set_initiator_group { list_sockets list_bits initiatorGroupName } {
  set mm [_getMemoryMap]
  set ig [create_object -type initiator_group -parent $mm -name $initiatorGroupName]
  update_object -name $ig -value_list $list_sockets -type initiators
  set_attribute -object $ig -name interleavingBits -value_list $list_bits
  return $ig
}

proc Interleaving::set_groups_MemorySet0 { list_dmis } {
  return [Interleaving::set_groups_MemorySet $list_dmis "memorySet0"]
}

proc Interleaving::set_groups_MemorySet1 { list_dmis } {
  return [Interleaving::set_groups_MemorySet $list_dmis "memorySet1"]
}

proc getMemGroupSizes { } {
  set mmap [_getMemoryMap]
  set memSets [get_objects -parent $mmap -type memory_set]
  # puts "MemoryMap $mmap  Sets=[llength $memSets]"
  set groupSizes [list ]
  foreach memSet $memSets {
    set mgrps [get_objects -parent $memSet -type dynamic_memory_group]
    # puts "#### MemSetGetGrpSize:  $memSet (groups=[llength mgrps])"
    foreach mgrp $mgrps {
      set objs [get_objects -parent $mgrp -type socket]
      set siz [llength $objs]
      lappend groupSizes $siz
      # puts "MemGrp $mgrp : ($siz) $objs"
    }
  }
  # puts "Before: $groupSizes"
  set sorted [lsort -unique $groupSizes]  
  return $sorted
}

# ***********************************************************************************************************
#
# Description:   This procedure is used to access all the Dynamic Mmemory Groups in the first Memory Set.
# Returns:       Returns the list of all the objects of type "Dynamic Memory Group" under the first "memory_set".
# Example usage: Interleaving::get_all_groups_MemorySet0 
#
# ************************************************************************************************************
proc Interleaving::get_all_groups_MemorySet0 { } {
  set mm    [_getMemoryMap]
  set msets [get_objects -parent $mm -type memory_set]
  set ms0 [lindex $msets 0]
  set mgrps [get_objects -parent $ms0 -type dynamic_memory_group]
  return $mgrps
}

# ***********************************************************************************************************
#
# Description:   This procedure is used to access a particular Dynamic Mmemory Groups in the first Memory Set.
# Returns:       Returns the object of type "Dynamic Memory Group" under the first "memory_set" with the given index.
# Example usage: Interleaving::get_group_MemorySet0 1
#
# ************************************************************************************************************
proc Interleaving::get_group_MemorySet0 { index } {
  set mm    [_getMemoryMap]
  set msets [get_objects -parent $mm -type memory_set]
  set ms0 [lindex $msets 0]
  set mgrps [get_objects -parent $ms0 -type dynamic_memory_group]
  if {$index > [llength $mgrps] || $index == [llength $mgrps]} {
    error "The value of the Home Unit Identifier is $index which is greater than the number of groups in MemorySet0 i.e [llength $mgrps]"
  }
  set my_grp [lindex $mgrps $index]
  return $my_grp
}

# ***********************************************************************************************************
#
# Description:   This procedure is used to create the "Memory Interleaving Function"
# Example usage: Interleaving::create_function "two_way_func1" 2
#
# ************************************************************************************************************
proc Interleaving::create_function { name groupsize } {
  set mm         [_getMemoryMap]
  if {[query_object -object $mm/$name -type userName] == ""} {
    set unit   [create_object -type memory_interleave_function -parent $mm -name $name]
  } else {
    set unit  $mm/$name
  }
  return $unit
}

# ***********************************************************************************************************
#
# Description:   This procedure is used to set the Primary Bits on the Memory Interleaving Function object.
# Argument:      The name of the object of type "Memory Interleaving Function", the bits used for selection. 
# Example usage: Interleaving::set_PrimaryBits   "twowayFunc1" {9}
#                Interleaving::set_PrimaryBits   "twowayFunc1" {12 14}
#
# ************************************************************************************************************
proc Interleaving::set_PrimaryBits { name bits } {
  set mm        [_getMemoryMap]
  if {[query_object -object $mm/$name -type userName] != ""} {
    if {[llength $bits] == 1} {
      set_attribute -object $mm/$name -name primaryInterleavingBitOne -value [lindex $bits 0]
    } elseif {[llength $bits] == 2} {
      set_attribute -object $mm/$name -name primaryInterleavingBitOne -value [lindex $bits 0]
      set_attribute -object $mm/$name -name primaryInterleavingBitTwo -value [lindex $bits 1]
    } elseif {[llength $bits] == 3} {
      set_attribute -object $mm/$name -name primaryInterleavingBitOne -value [lindex $bits 0]
      set_attribute -object $mm/$name -name primaryInterleavingBitTwo -value [lindex $bits 1]
      set_attribute -object $mm/$name -name primaryInterleavingBitThree -value [lindex $bits 2]
    } elseif {[llength $bits] == 4} {
      set_attribute -object $mm/$name -name primaryInterleavingBitOne -value [lindex $bits 0]
      set_attribute -object $mm/$name -name primaryInterleavingBitTwo -value [lindex $bits 1]
      set_attribute -object $mm/$name -name primaryInterleavingBitThree -value [lindex $bits 2]
      set_attribute -object $mm/$name -name primaryInterleavingBitFour -value [lindex $bits 3]
    }
  } else {
    error "MemoryInterleavingFunction not created"
  }
}

proc Interleaving::associate_InterleavingBits { group function1 {function2 ""} } {
  puts "  Deprecated: The Interleaving::associate_InterleavingBits is deprecated. "
}

proc Interleaving::set_SecondaryBits { name bits } {
  puts "  Deprecated: The Interleaving::set_SecondaryBits is deprecated. Cannot set secondary bits"
}

package provide Interleaving $Interleaving::version
package require Tcl 8.5
