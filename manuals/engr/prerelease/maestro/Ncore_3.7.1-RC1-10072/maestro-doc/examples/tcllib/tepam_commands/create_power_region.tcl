tepam::procedure {create_power_region} {
  -category power
  -description "Power region is a container for design elements supplied by the same power rail. Each region contains one or more power domains"
  -example "create_power_region -name myPwrRegion -voltage 1.0V"
  -args {
    {
      -name
      -description "Name of the region"
    }
    {
      -parent 
      -type string
      -optional
      -description "Parent object under which power region is created. If you omit this option and only one chip object exists, it becomes a default parent"
    }
    {
      -voltage
      -type string
      -optional
      -default "1.0V"
      -description  "Voltage level of the supply"
    }
  }
} {
  # Actual function
  
  # See if chip exists 
  set chips [get_objects -parent root -type chip] 
  if {[llength $chips] == 0} {
    art_print -level error -msg "No chip objects found. Can't create clock region"
    return -code error
  }

  # If parent was not defined by the user - see if there is only one chip and if yes - it's the parent
  if {![info exists parent]} {
    if {[llength $chips] > 1} {
      art_print -level error -msg "Can't automatically determine the parent for the clock region, because more than one chip exists. Use -parent option to choose. To see a list of available chips do: 'get_objects -parent root -type chip'"
      return -code error
    } 
    set parent $chips
    art_print -level info -msg "picked '$parent' as a parent for the clock region" 
  }

  # Convert frequency to integer in mV
  set voltageFloat [::units::convert $voltage mV]
  
  # Detect overflow
  if {$voltageFloat > [expr pow(2,31)-1]} {
    art_print -level error -msg "voltage value '$voltage' can't be expressed in mV as integer!"
    return -code error
  }

  
  # Detect truncation
  set voltageInt [expr round($voltageFloat)]
  if {$voltageInt != $voltageFloat} {
    art_print -level warning -msg "rounding occured while translating voltage to integer"
  }
  
  # See if power region with such name already exists under parent
  if {[lsearch -exact [get_objects -parent $parent -type power_region] $parent/$name] >= 0} {
    art_print -level error -msg "Power region '$name' already exists under '$parent'"
    return -code error
  }
  
  # All looks good we can now create a region
  set pwrRegion [create_object -type power_region -name $name -parent $parent]
  set_attribute -object $pwrRegion -name voltage -value $voltageInt

  # Return pwr region object
  return $pwrRegion
}

