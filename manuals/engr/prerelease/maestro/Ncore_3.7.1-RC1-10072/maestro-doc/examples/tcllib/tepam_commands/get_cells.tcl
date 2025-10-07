tepam::procedure {get_cells} {
  -category clock
  -description "Return a list of network elements"
  -example "get_cells\nget_cells -parent project/chip/topology -types \"ncoreunit switch\""
  -args {  
    {
      -parent 
      -type string
      -optional
      -description "Object in the design hierarchy under which the search for matching network elements is performed. Default - chip"
    }
    {
      -types
      -optional
      -default "ncoreunit packetizer depacketizer switch pipe_adapter width_adapter clock_adapter"
    }
  }
} {
  # Actual function
  
  # See if chip exists 
  set chips [get_objects -parent root -type chip] 
  if {[llength $chips] == 0} {
    art_print -level error -msg "No chip objects found"
    return -code error
  }

  # If parent was not defined by the user - see if there is only one chip and if yes - it's the parent
  if {![info exists parent]} {
    if {[llength $chips] > 1} {
      art_print -level error -msg "Can't automatically determine the parent object, because more than one chip exists. Use -parent option to choose. To see a list of available chips do: 'get_objects -parent root -type chip'"
      return -code error
    } 
    set parent $chips
    art_print -level debug -msg "picked '$parent' as a parent object" 
  }

  # Check that parent exists
  if {[query_object -object $parent -type type] == ""} {
    art_print -level error -msg "Parent object '$parent' is not found"
    return -code error
  }

  # Construct and return a list of cells
  set cells {}
  foreach type $types {
    set cells [concat $cells [get_objects -parent $parent -type $type]]
  } 
  return $cells
}
