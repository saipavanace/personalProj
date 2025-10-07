# *********************************************************************************************
#
# This script provides procedures to set the parameters on the object of type "boot_region". 
# 
#**********************************************************************************************

namespace eval BootRegion {
  namespace export print_parameters
  namespace export create_unit
  namespace export set_baseAddress
  namespace export set_memorySize
  namespace export set_Home_Unit
  namespace export set_Home_Unit_Type
  namespace export set_Home_Unit_Identifier2

  set version 2.0
  set Description "Maestro_BootRegion"

  variable home [file join [pwd] [file dirname [info script]]]
  variable boot_region_type
}

# *********************************************************************************************************
#
# Description: Retrieves a memory_map object
# Return:      Returns the object of type "memory_map" which has been created.
# 
# **********************************************************************************************************
proc _getMemoryMap { } {
  set chip     [get_objects -type chip -parent root]
  set system   [get_objects -type system -parent $chip]
  set subsystem [get_objects -type subsystem -parent $system]
  set mm [get_objects -type memory_map -parent $subsystem]
  return $mm
}

# ********************************************************************************************************
#
# Description: Creates a bootregion object with the given name
# Argument:    Name of the bootregion to be created
# Return  :    Returns the object of type "boot_region" with the given name
# Example :    BootRegion::create_unit "boot1"
#
# ********************************************************************************************************
proc BootRegion::create_unit { name } {
  set mm     [_getMemoryMap]
  set unit   [create_object -type boot_region -parent $mm -name $name]
  return $unit
}

# *********************************************************************************************************
#
# Description: Retrieves a bootregion object
# Return:      Returns the object of type "boot_region" which has been created.
#              If an object of type "bootregion" does not exist, an object of type "boot_region" with the given name is created.
# 
# **********************************************************************************************************
proc _getBootRegion { } {
  set mm [_getMemoryMap]
  set boot_region [get_objects -parent $mm -type boot_region]
  if {$boot_region == ""} {
    set boot_region [BootRegion::create_unit "bootregion"]    
  }
  # puts "_getBootRegion: $mm $boot_region"
  return $boot_region
}

# ***********************************************************************************************************
#
# Description:  Sets the parameter "baseAddress" on a bootregion object with the given value.
#               Retrives an existing object of "boot_region" which has been created previously.
#               Sets the parameter "baseAddress" with the value provided in the Argument.
# Argument:     Value of the base Address of the bootregion in Hex.
# Return:       The value of the baseAddress for the object of type "boot_region" is set.
#
# ************************************************************************************************************
proc convertToDecimal { val  } {
  set hexa [string first "'h" $val]
  set addr [string first "0x" $val]
  # puts "convertToDecimal $val hexa=$hexa addr=$addr"
  set decVal $val
  if {$hexa == 0} {
    set newVal2 [string trim $val "'h"]
    set decVal  [expr 0x$newVal2]
  }
  # puts "  decVal= $decVal"
  return $decVal
}

proc convertToBytes { val baseUnit } {
  set bytes [convertToDecimal $val]
  if {$baseUnit == "kb" || $baseUnit == "kB"} {
    set bytes [expr $bytes * 1024]
  }
  # puts "  bytes=  $bytes"
  return $bytes
}

proc BootRegion::set_baseAddress { val {baseUnit ""} } {
  set boot [_getBootRegion]

  set bytes [convertToBytes $val $baseUnit]
  puts "BootRegion::set_baseAddress (memoryBase) $bytes"
  set_attribute -object $boot -name memoryBase -value [expr $bytes]
}


# ***********************************************************************************************************
#
# Description:  Sets the parameter "memorySize" on a bootregion object with the given value.
#               Retrives an existing object of "boot_region" which has been created previously.
#               Sets the parameter "memorySize" with the value provided in the Argument.
# Argument:     Value of the size of memory of the bootregion in Hex.
# Return:       The value of the "memorySize" for the object of type "boot_region" is set.
# Example usage: BootRegion::set_memorySize "0x0"
#
# ************************************************************************************************************
proc BootRegion::set_memorySize { val {unit  ""} } {
  set boot [_getBootRegion]
  set newVal [convertToDecimal $val]

  if {$unit == "kb" || $unit == "kB"} {
    set_attribute -object $boot -name memorySize -value [expr $newVal]
  } elseif {$unit == ""} {
    set_attribute -object $boot -name memorySize -value [expr $newVal]
    # set sz [get_parameter -object $boot -name memorySize]
    # puts "hx $val : $newVal = $sz"
  } else { ; # unknown unit
    puts "Error: BootRegion::set_memorySize - unknown unit value: $unit . Command ignored."
  }
}

# ***********************************************************************************************************
#
# Description:   This procedure provides access to the Bootregion either through the system memory (DMI) or
#                the peripheral memory (DII).
# Argument:      Either a DMI or DII
# Example usage: BootRegion::set_Home_Unit_Type "DMI"
#
# ************************************************************************************************************
proc BootRegion::set_Home_Unit_Type { val } {
   if {$val == "DMI"} {
   	puts "Boot region is accessed via system memory"
   } elseif {$val == "DII"} {
   	puts "Boot region is accessed via peripheral memory"
   } else {
   	error "Please select either DMI or DII for Home Unit Type"
   }
   #  puts "BootRegion::boot_region_type = $val"
   set BootRegion::boot_region_type $val
}


# ***********************************************************************************************************
#
# Description:   This procedure provides an Id for the Memory Group or DII whichever is selected.
# Argument:      The Id of the Dynamic Memory Group if DMI is Home_unit_type or Id of the DII if DII is the 
#                Home_Unit_Type.
# Example usage: BootRegion::set_Home_Unit_Identifier 0
#
# ************************************************************************************************************
proc BootRegion::set_Home_Unit { unit } {
   set boot [_getBootRegion]

   if {[string compare $BootRegion::boot_region_type "DII"] == 0} {
    update_object -name $boot -type "physicalChannel" -bind $unit
   } elseif {[string compare $BootRegion::boot_region_type  "DMI"] == 0} {
    update_object -name $boot -type "memoryGroup" -bind $unit
   }
}

proc BootRegion::set_Home_Unit_Identifier { val } {
   set boot [_getBootRegion]

   if {[string compare $BootRegion::boot_region_type "DII"] == 0} {
   	set chip     [get_objects -type chip -parent root]
    set system   [get_objects -type system -parent $chip]
    set subsystem [get_objects -type subsystem -parent $system]

    set name dii$val
    set unit $subsystem/$name
    set_Home_Unit $unit
   } elseif {[string compare $BootRegion::boot_region_type  "DMI"] == 0} {
    set object [Interleaving::get_group_MemorySet0 $val]
    set_Home_Unit $object
   }
}

package provide BootRegion $BootRegion::version
package require Tcl 8.5
