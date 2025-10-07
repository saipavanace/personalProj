tepam::procedure {create_clock_region} {
  -category clock
  -description "Clock region is a container of design elements driven by one external clock source. In P&R all leaf clocked cells belonging to a region are expected to be balanced wrt the clock source. Each region contains one or more clock domains, which in turn contain clock subdomains"
  -example "create_clock_region -name myClkRegion -frequency 1.6GHz"
  -args {
    {
      -name
      -description "Name of the region"
    }
    {
      -frequency
      -type string
      -description  "Frequency of the clock"
    }
    {
      -parent 
      -type string
      -optional
      -description "Parent object under which clock region is created. If you omit this option and only one chip object exists, it becomes a default parent"
    }

    {
      -power_region
      -type string
      -description  "The power region this clock region is associated with."
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

  # Convert frequency to integer in MHz
  set frequencyFloat [::units::convert $frequency MHz]
  
  # Detect overflow
  if {$frequencyFloat > [expr pow(2,31)-1]} {
    art_print -level error -msg "frequency value '$frequency' can't be expressed in kHz as integer!"
    return -code error
  }

  # Detect truncation
  set frequencyInt [expr round($frequencyFloat)]
  if {$frequencyInt != $frequencyFloat} {
    art_print -level warning -msg "rounding occured while translating frequency to integer"
  }
  

  # See if clock region with such name already exists under parent
  if {[lsearch -exact [get_objects -parent $parent -type clock_region] $parent/$name] >= 0} {
    art_print -level error -msg "Clock region '$name' already exists under '$parent'"
    return -code error
  }
  
  # All looks good we can now create a region
  set clkRegion [create_object -type clock_region -name $name -parent $parent]
  set_attribute -object $clkRegion -name frequency -value $frequencyInt

  update_object -name $clkRegion -bind $power_region -type "powerRegion"
  # Return clk region object
  return $clkRegion
}

proc demo_create_clock_region {} {
  # First show help 
  create_clock_region -help

  # Try to create clock region without specifying name or frequency
  create_clock_region
  create_clock_region -name my_clock_region

  # All params are specified, notice that parent is automatically derived
  set clkRegion1 [create_clock_region -name first_clock_region -freq 1.6GHz]

  # Query the region (this is C++ command) - notice that frequency has been translated to kHz 
  get_parameter -object $clkRegion1

  # Now try to define clock region again with the same name
  create_clock_region -name first_clock_region -frequency 1.6GHz
  
  # OK, use different name but this time use scientific notation for frequency
  # Notice that this time there is not need to define Hz 
  set clkRegion2 [create_clock_region -name second_clock_region -frequency 2e9]
  get_parameter -object $clkRegion2

  # If user defined number leads to truncation - issue warning
  set clkRegion3 [create_clock_region -name third_clock_region -parent $chip -frequency 2700]
  get_parameter -object $clkRegion3

  # Finally if value can't be represented as integer 
  create_clock_region -name fourths_clock_region -parent $chip -frequency 3e12
}
