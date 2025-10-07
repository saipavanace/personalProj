namespace eval CsrRegion {
  namespace export print_parameters
  namespace export create_unit
  namespace export set_baseAddress
  namespace export set_memorySize
  
  set version 2.0
  set Description "Maestro_CsrRegion"

  variable home [file join [pwd] [file dirname [info script]]]
  variable created_units [list]
}

proc _getMemoryMap { } {
  set chip     [get_objects -type chip -parent root]
  set system   [get_objects -type system -parent $chip]
  set subsystem [get_objects -type subsystem -parent $system]
  set mm [get_objects -type memory_map -parent $subsystem]
  return $mm
}

proc CsrRegion::create_unit { name } {
  set mm     [_getMemoryMap]
  set unit   [create_object -type configuration_region -parent $mm -name $name]
  return $unit
}

proc _getCsrRegion { } {
  set mm     [_getMemoryMap]
  set csr_region [get_objects -parent $mm -type configuration_region]
  if {$csr_region == ""} {
    set csr_region [CsrRegion::create_unit "csrregion"]    
  }
  return $csr_region
}

proc CsrRegion::set_baseAddress { val {addrUnit ""} } {
  set csr_region [_getCsrRegion]
  set hexa [string first "'h" $val]
  set addr [string first "0x" $val]
  if {$hexa != -1} {
    set newVal [string trim $val "'h"]
    if {$addrUnit == "kb" || $addrUnit == "kB"} {
      # convert kb to bytes
      set decVal [expr 0x$newVal]
      set decVal [expr $decVal * 1024]
      set_attribute -object $csr_region -name memoryBase -value [expr $decVal]
      set newVal2 [get_parameter -object $csr_region -name memoryBase]
      puts "csrRegion::memoryBase 0 = $newVal2"
      return
    } 
    # in bytes, just convert to decimal
    set_attribute -object $csr_region -name memoryBase -value [expr 0x$newVal]
    set newVal2 [get_parameter -object $csr_region -name memoryBase]
    puts "csrRegion::memoryBase 1 = $newVal2"
    # puts "  Setting memoryBase1 [expr 0x$newVal]"
  } elseif {$addr != -1} {
    if {$addrUnit == "kb" || $addrUnit == "kB"} {
      # convert kb to bytes
      set decVal [expr 0x$val]
      set decVal [expr $decVal * 1024]
      set_attribute -object $csr_region -name memoryBase -value [expr $decVal]
      set newVal2 [get_parameter -object $csr_region -name memoryBase]
      puts "csrRegion::memoryBase 2 = $newVal2"
      return
    }
    set_attribute -object $csr_region -name memoryBase -value [expr $val]
    set newVal2 [get_parameter -object $csr_region -name memoryBase]
    puts "csrRegion::memoryBase 3 = $newVal2"
    # puts "  Setting memoryBase2 [expr $val]"
  }
  # set newVal2 [get_parameter -object $csr_region -name memoryBase]
  # puts "csrRegion::memoryBase 4 = [expr 0x$newVal]"
  # puts "Retrieved val = $newVal2  Original val = $val"
}

proc CsrRegion::set_memorySize { val } {
  puts "  Deprecated: The CsrRegion::set_memorySize call is deprecated and does nothing as the size of the CSR region is hardcoded."
#  set csr_region [_getCsrRegion]
#  set hexa [string first "'h" $val]
#  set addr [string first "0x" $val]
#  if {$hexa != -1} {
#    set newVal [string trim $val "'h"]
#    set_attribute -object $csr_region -name memorySize -value [expr 0x$newVal]
#  } elseif {$addr != -1} {
#    set_attribute -object $csr_region -name memorySize -value [expr $val]
#    # puts "  Setting memorySize2 [expr $val]"
#  }
#  set newVal2 [get_parameter -object $csr_region -name memorySize]
#  # puts "Retrieved val = $newVal2  Original val = $val"
}


package provide CsrRegion $CsrRegion::version
package require Tcl 8.5
