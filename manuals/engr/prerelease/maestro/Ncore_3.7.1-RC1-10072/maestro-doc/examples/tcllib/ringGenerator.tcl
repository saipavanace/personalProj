namespace eval RingGenerator {
  namespace export create_mesh_locs
  namespace export generate_routes
  namespace export route_csr_networks
  namespace export verify_routes
  namespace export dump_routes
  namespace export dump_flows
  namespace export dump_mappedflows
  namespace export dump_packetroutes
  namespace export getNcores
  namespace export getSize

  set version 2.0
  set Description "Maestro_ringGenerator"

  variable home [file join [pwd] [file dirname [info script]]]
}

proc RingGenerator::getNcoresNumber {ts} {
  set total 0
  set unitTypes [list caiu ncaiu dmi dii dce dve atu]
  foreach u $unitTypes {
    set found [get_objects -parent $ts -type $u]
    dict append units $u $found
    set unit_total [llength $found]
    set total [expr $total+$unit_total]
  }
  return $total
}

proc RingGenerator::create_mesh_locs { {topology ""} } {
  return [RingGenerator::getSize $topology]
}

proc RingGenerator::getSize { {topology ""} } {
  set parent $topology
  if {$topology == ""} {
    set chip   [Project::get_chip]
    set parent $chip
  }

    set i 0
    # Place the units in the location
    set caius [get_objects -parent $parent -type caiu]
    foreach u $caius {
      set_node_position -object $u -x $i -y 0
      incr i
    }

    set ncaius [get_objects -parent $parent -type ncaiu]
    foreach u $ncaius {
      set_node_position -object $u -x $i -y 0
      incr i
    }
    
    set dmis [get_objects -parent $parent -type dmi]
    foreach u $dmis {
      set_node_position -object $u -x $i -y 0
        incr i
    }

    set diis [get_objects -parent $parent -type dii]
    foreach u $diis {
      set_node_position -object $u -x $i -y 0
      incr i
    }

    set dces [get_objects -parent $parent -type dce]
    foreach u $dces {
      set_node_position -object $u -x $i -y 0
      incr i
    }
    
    set atus [get_objects -parent $parent -type atu]
    foreach u $atus {
      set_node_position -object $u -x $i -y 0
      incr i
    }

    set dves [get_objects -parent $parent -type dve]
    foreach u $dves {
      set_node_position -object $u -x $i -y 0
      incr i
    }

    return $i
}

proc RingGenerator::generate_routes {topology ringSize clk datawidth} {
  set chip [get_objects -parent root -type chip]
  set networks [get_objects -parent $chip -type network]

  set netw1  [lindex $networks 1]
  set netw2  [lindex $networks 0]
  set flows1 [list ]
  set flows2 [list ]

  set myFlows [get_objects -parent [Project::get_subsystem] -type flow]


  foreach f $myFlows {
    set netw [ query_custom_attribute -object $f -name f_network]
    puts " $f : $netw "
    if { $netw == "ndn"} {
      lappend flows1 $f
    }
    if { $netw == "dn"} {
      lappend flows2 $f
    }
  }

  puts "FLOWS1: $netw1 N=[llength $flows1]"
  puts "FLOWS2: $netw2 N=[llength $flows2]"
  puts "myFlows N = [llength $myFlows]"

  lreverse $networks

  foreach net $networks {
    set pos [string last "/" $net]
    set nam [string range $net $pos+1 end]
    set route_params [list type ring name $nam meshx $ringSize network $net dataWidth $datawidth ]
    puts "RingGenerator::generate_routes params=$route_params"
    run_generator -name "regular_topology" -topology $topology -clock $clk -params $route_params

    
  }

  puts "************************************************************"
  puts "*        Packet ROUTES CREATED                             *"
  puts "************************************************************"
  set packetRoutes [get_objects -parent $topology -type packet_route]
  puts " Packet Routes Created: [llength $packetRoutes]"
  puts "************************************************************"

}

package provide RingGenerator $RingGenerator::version
package require Tcl 8.5
