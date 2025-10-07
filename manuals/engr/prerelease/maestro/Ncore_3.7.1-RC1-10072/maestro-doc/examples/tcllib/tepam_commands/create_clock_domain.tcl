tepam::procedure {create_clock_domain} {
  -category clock
  -short_description "create container for design elements sharing a common clock which can be turned off"
  -description "Clock domain is a container for design elements which share a common clock which can be turned on and off. Each clock domain is created under a parent clock region thus sharing a clock root, but each domain can be turned off separately.  Clock domain has to be associated with a correspondent power domain. Clock domain should never straddle power domain boundaries, i.e all the network elements which belong to one clock domain must also belong to one power domain"
  -example "create_clock_domain -name myClkDomain -parent $myClockRegion -gating external"
  -args {
    {
      -name
      -description "Name of the domain"
    }
    {
      -parent 
      -type string
      -description "Parent clock region object under which clock domain is created"
    }
    {
      -gating
      -choices {always_on external internal}
      -default always_on
      -description "Gating style of the clock domain. always_on means no gating, external - clock is expected to be gated outside our system, internal - clock gater is instantiated within our system " 
    }
    {
      -power_domain
      -type string
      -description "Bind clock domain with power domain, which had to be previously created" 
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
  if {[query_object -object $parent -type type] != "ClockRegion"} {
    art_print -level error -msg "Parent object '$parent' either doesnt't exist or is not a clock region"
    return -code error
  }


  # See if clock domain with such name already exists under parent region
  if {[lsearch -exact [get_objects -parent $parent -type clock_domain] $parent/$name] >= 0} {
    art_print -level error -msg "Clock domain '$name' already exists under clock region '$parent'"
    return -code error
  }
  
  # All looks good, we can now create a region and set its gating style
  set clkDomain [create_object -type clock_domain -name $name -parent $parent]
  set_attribute -object $clkDomain -name gating -value $gating


  # Bind clock domain with power domain. This way we guarantee that clock domain will not straddle multiple power domains
  # and also association of any leaf level block with clock domain will automatically associate block with power domain as well  
  if {[query_object -object $power_domain -type type] != "PowerDomain"} {
    art_print -level error -msg "'$power_domain' doesn't exist or is not a power domain"
    return -code error
  }
  update_object -name $clkDomain -bind $power_domain -type "powerDomain"

  # Return clk region object
  return $clkDomain
}

