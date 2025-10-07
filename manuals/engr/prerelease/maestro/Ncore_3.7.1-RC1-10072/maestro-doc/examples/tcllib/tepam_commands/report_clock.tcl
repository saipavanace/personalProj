tepam::procedure {report_clock} {
  -category report
  -short_description "Report clock structure"
  -description "Report clock structure of the design"   
  -example "report_clock"
  -args {
    {
      -parent
      -type string
      -optional
      -description "Name of the chip whose clock structure is to be reported"
    }
    {
      -file
      -type string
      -default stdout
      -description  "redirect report to a file"
    }
  }
} {
  # Actual function


  # See if at least one chip exists 
  set chips [get_objects -parent root -type chip] 
  if {[llength $chips] == 0} {
    art_print -level error -msg "No chip objects found"
    return -code error
  }

  # If parent was not defined by the user - see if there is only one chip and if yes - it's the parent
  if {![info exists parent]} {
    if {[llength $chips] > 1} {
      art_print -level error -msg "More than one chip exists. Use -parent option to choose. To see a list of available chips do: 'get_objects -parent root -type chip'"
      return -code error
    } 
    set parent $chips
    art_print -level debug -msg "picked '$parent' as a parent for the clock report"
  }

  # Check that parent is a chip
  set objType [query_object -object $parent -type type]
  if {$objType != "Chip"} {
    art_print -level error -msg "Object '$object' is not found or its type is not 'Chip'!"
    return -code error
  }

  # Build a hash with association between design elements and clock subdomains
  # TBD - will need to be rewritten when we'll return a list of subdomains for each unit
  array set cellCount {}
  foreach clkSubdomain [get_objects -parent $parent -type clock_subdomain] {
    set cellCount($clkSubdomain) 0
  }

  foreach cell [get_cells] {
    set clkSubdomain [get_objects -parent $cell -type clock_subdomain]
    incr cellCount($clkSubdomain) 
  }

  set rptBuf     "
**************************************************************
    Clock structure for chip '$parent'
**************************************************************
"
  foreach clkRegion [get_objects -parent $parent -type clock_region] {
    append rptBuf "clock region: $clkRegion \n"
    array set clkRegionAttrs [get_parameter -object $clkRegion]
    set freq $clkRegionAttrs(frequency)
    if {$freq >= 1000000} {
      set freq "[expr $freq/1000000.0]GHz"
    } elseif {$freq >= 1000} {
      set freq "[expr $freq/1000.0]MHz"
    }
    append rptBuf "  frequency: $freq\n"
    foreach clkDomain [get_objects -parent $clkRegion -type clock_domain] {
      array set clkDomainAttrs [get_parameter -object $clkDomain]
      append rptBuf "  clock domain: $clkDomain\n"
      append rptBuf "    gating: $clkDomainAttrs(gating)\n"
      append rptBuf "    bound to power domain: [get_objects -parent $clkDomain -type power_domain]\n"
      foreach clkSubdomain [get_objects -parent $clkDomain -type clock_subdomain] {
        append rptBuf "    clock subdomain: $clkSubdomain\n"
        append rptBuf "      cell count: $cellCount($clkSubdomain)\n"
      }
    } 
  }

  # Dump accumulated report to stdout or file
  if {$file == "stdout"} {
    puts $rptBuf
  } else {
    set fileId [open $file w]
    puts $fileId $rptBuf
    close $fileId
  }
  
}
