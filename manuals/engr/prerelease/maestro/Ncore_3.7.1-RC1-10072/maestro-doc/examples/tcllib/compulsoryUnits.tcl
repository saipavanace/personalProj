package require Project 2.0
package require Dce 2.0

namespace eval CompulsoryUnits {
  namespace export create_obj

  set version 2.0
  set Description "Maestro_Compulsory_Units"

  variable home [file join [pwd] [file dirname [info script]]]
}

proc CompulsoryUnits::create_obj { designEnv clk } {
  set chip     [Project::get_chip]
  set topology [Project::get_topology]
  puts "CompulsoryUnits::create_obj chip = $chip topology = $topology"

  #create the GRB unit
  set grbUnit [create_object -type grb -name Grb -parent $topology]
  update_object -name $grbUnit -bind $clk -type "domain"


  #create DVE if caiu or ncaiu are present
  set caius  [get_objects -parent $chip -type caiu ]
  set ncaius [get_objects -parent $chip -type ncaiu ]
  if { [llength $caius] + [llength $ncaius] > 0 } {
    #create the DVE unit
    set dveUnit [Dve::create_obj Dve $topology [list] ]
    update_object -name $dveUnit -bind $clk -type "domain"
  }
}
  
package provide CompulsoryUnits $CompulsoryUnits::version
package require Tcl 8.5
