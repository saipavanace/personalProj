tepam::procedure {create_clock_subdomain} {
  -category clock
  -description "Clock domain can contain several subdomains - all derived from the same switchable clock of the domain, but having a different clock frequencies and/or waveforms"
  -example "create_clock_subdomain -name myClkSubdomain -parent $myClockRegion -gating external"
  -args {
    {
      -name
      -description "Name of the domain"
    }
    {
      -parent 
      -type string
      -description "Parent clock domain object under which clock subdomain is created"
    }
    {
      -divide_by
      -type integer
      -optional
      -description "Clock division factor" 
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

  # Check that specified parent is a clock rdomain
  if {[query_object -object $parent -type type] != "ClockDomain"} {
    art_print -level error -msg "Parent object '$parent' either doesnt't exist or is not a clock domain"
    return -code error
  }


  # See if clock domain with such name already exists under parent domain
  if {[lsearch -exact [get_objects -parent $parent -type clock_subdomain] $parent/$name] >= 0} {
    art_print -level error -msg "Clock subdomain '$name' already exists under clock domain '$parent'"
    return -code error
  }
  
  # All looks good, we can now create subdomain and set divideBy property
  set clkSubdomain [create_object -type clock_subdomain -name $name -parent $parent]
  if {[info exists divide_by]} {
    set_attribute -object $clkSubdomain -name divideBy -value $divide_by
  }

  # Return clk region object
  return $clkSubdomain
}

