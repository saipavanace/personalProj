package require CsrNetwork 2.0
package require MeshGenerator 2.0

namespace eval TorusGenerator {
  namespace export create_torus_locs
  namespace export generate_routes
  namespace export route_csr_networks
  namespace export verify_routes
  namespace export dump_routes
  namespace export dump_flows
  namespace export dump_mappedflows
  namespace export dump_packetroutes
  namespace export getNcores 

  set version 2.0
  set Description "Maestro_torusGenerator"

  variable home [file join [pwd] [file dirname [info script]]]
}


proc TorusGenerator::verify_routes {subsystem topology} {
  return [MeshGenerator::verify_routes $subsystem $topology]
}

proc TorusGenerator::getNcores {chip} {
  return [MeshGenerator::getNcores $chip]
}



proc TorusGenerator::create_torus_locs {} {
  return [MeshGenerator::create_mesh_locs]
}


proc TorusGenerator::generate_routes {chip topology torusSize clkSubDomain dataWidth} {

  set networks [get_objects -parent $chip -type network]
  set dataNetw [lindex [Project::getDataNetworks] 0]
  puts "Data network: $dataNetw"
  
  foreach net $networks {
    set request  [query_object -object $net -type "csr_request"]
    set response [query_object -object $net -type "csr_response"]
    puts "TorusGenerator::generate_routes $net req=$request resp=$response"
    if {$request == "true" || $response == "true"} {
      continue
    }
    
    set dw 0
    set optimizeDW 0
    if {[string compare [Project::abbrev $net] $dataNetw] == 0} {
      set dw $dataWidth
      set optimizeDW 0 ; # 1 if enabled
    }

    puts "TorusGenerator::generate_routes calling generator $net"
    set pos [string last "/" $net]
    set nam [string range $net $pos+1 end]
    set route_params [list type torus name $nam meshx $torusSize meshy $torusSize network $net dataWidth $dataWidth optimizeDataWidth $optimizeDW]
    run_generator -name "regular_topology" -topology $topology -clock $clkSubDomain -params $route_params
  }

  #----------------------------------------------------------------------
  # Auto insert adapters
  #---------------------------------------------------------------------
  run_generator -topology $topology -name "adapters"
}

package provide TorusGenerator $TorusGenerator::version
package require Tcl 8.5

