tepam::procedure {create_power_domain} {
  -category power
  -short_description "create container for design elements sharing a common power supply which can be turned off"
  -description "Power domain is a container for design elements which share a common power supply. Each power domain is created under a parent power region thus sharing the same voltage level, but each domain can be turned off separately"
  -example "create_power_domain -name myPwrDomain -parent $myPwrRegion -gating dynamic"
  -args {
    {
      -name
      -description "Name of the domain"
    }
    {
      -parent 
      -type string
      -description "Parent power region object under which power domain is created"
    }
    {
      -gating
      -choices {always_on dynamic}
      -default always_on
      -description "Gating style of the power domain. always_on means no gating, external - power can be turned off " 
    }
  }
} {
  # Actual function
  
  # See if chip exists 
  set chips [get_objects -parent root -type chip] 
  if {[llength $chips] == 0} {
    art_print -level error -msg "No chip objects found. Can't create clock domain"
    return -code error
  }

  # Check that specified parent is a clock region
  if {[query_object -object $parent -type type] != "PowerRegion"} {
    art_print -level error -msg "Parent object '$parent' either doesnt't exist or is not a power region"
    return -code error
  }


  # See if clock domain with such name already exists under parent region
  if {[lsearch -exact [get_objects -parent $parent -type power_domain] $parent/$name] >= 0} {
    art_print -level error -msg "Power domain '$name' already exists under power region '$parent'"
    return -code error
  }
  
  # All looks good, we can now create a region and set its gating style
  set pwrDomain [create_object -type power_domain -name $name -parent $parent]

  # Temporary hack - we specify gating as 'always_on', but set_attribute expects 'alwayson'
  # regsub -all {_} $gating "" gating 


  set_attribute -object $pwrDomain -name gating -value $gating

  # Return pwr domain object
  return $pwrDomain
}

