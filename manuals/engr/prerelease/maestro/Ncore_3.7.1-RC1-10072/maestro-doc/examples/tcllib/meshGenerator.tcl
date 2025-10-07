namespace eval MeshGenerator {
  namespace export create_mesh_locs
  namespace export create_butterfly_locs
  namespace export generate_routes
  namespace export generate_routes_by_network
  namespace export generate_mesh_routes
  namespace export generate_mesh_routes_by_network
  namespace export verify_routes
  namespace export dump_routes
  namespace export dump_flows
  namespace export dump_mappedflows
  namespace export dump_packetroutes
  namespace export getNcores 
  namespace export getMeshSize

  set version 2.0
  set Description "Maestro_meshGenerator"

  variable home [file join [pwd] [file dirname [info script]]]
}

proc MeshGenerator::dump_flows {subsystem} {
  set flows  [get_objects -parent $subsystem -type flow]
  puts "Flows       = [llength $flows]"
  foreach fl $flows {
    puts "flow $fl"
    set sockets [get_objects -parent $fl -type socket]
    set frSock  [lindex $sockets 0]
    set toSock  [lindex $sockets 1]
    puts "  FR: $frSock  TO: $toSock"
    # set frOwner [get_objects -parent $frSock -type parent]
    # set toOwner [get_objects -parent $toSock -type parent]
    # set frOwnerT [query_object -object $frOwner -type type]
    # set toOwnerT [query_object -object $toOwner -type type]
    # puts "   Parents: $frOwner ($frOwnerT) $toOwner ($toOwnerT)"
  }  
}

proc MeshGenerator::dump_mappedflows {topology} {
  set mappedflows [get_objects -parent $topology -type mapped_flow]
  puts "Mappedflows = [llength $mappedflows]"
  foreach mflow $mappedflows {
    set pports [get_objects -parent $mflow -type packet_port]
    set srcPort [lindex $pports 0]
    set tgtPort [lindex $pports 1]
    puts "$srcPort  => $tgtPort MF"
    # set srcSMI  [get_objects -parent $srcPort -type smi]
    # set tgtSMI  [get_objects -parent $tgtPort -type smi]
  }
}

proc MeshGenerator::dump_packetroutes {topology} {
  set routes [get_objects -parent $topology -type packet_route]
  puts "Routes = [llength $routes]"
  foreach rte $routes {
    set packetPorts [get_objects -parent $rte -type packet_port]
    set n [llength $packetPorts]
    set last $n
    incr last -1

    set srcPort [lindex $packetPorts 0]
    # set srcSMI  [get_objects -parent $srcPort -type smi]
    set tgtPort [lindex $packetPorts $last]
    # set tgtSMI  [get_objects -parent $tgtPort -type smi]
    puts "$srcPort  => $tgtPort PR"
  }
}

proc MeshGenerator::dump_routes {subsystem topology} {
  MeshGenerator::dump_flows        $subystem
  MeshGenerator::dump_mappedflows  $topology
  MeshGenerator::dump_packetroutes $topology
}

proc MeshGenerator::verify_routes {subsystem topology} {
  set flows  [get_objects -parent $subsystem -type flow]
  set multiflows [get_objects -parent $subsystem -type multiflow]
  set mflows [get_objects -parent $topology -type mapped_flow]
  set routes [get_objects -parent $topology -type packet_route]

  puts "Flows       = [llength $flows]"
  puts "MultiFlows  = [llength $multiflows]"
  puts "Mappedflows = [llength $mflows]"
  puts "PacketRoutes = [llength $routes]"
  set vals [list [llength $flows] [llength $multiflows] [llength $mflows] [llength $routes] ]
  return $vals
}

proc MeshGenerator::getNcores {chip} {
  set units [dict create]
  set unitTypes [list caiu ncaiu atu dmi dii dce dve ]
  foreach u $unitTypes {
    set found [get_objects -parent $chip -type $u]
    dict append units $u $found
    # puts "Ncore $u=[llength $found]"
  }
  return $units;
}

proc MeshGenerator::create_butterfly_locs { } {
  set initiatorTypes [list caiu ncaiu]
  set targetTypes    [list dmi dii dve dce]
  set chip     [get_objects -parent root  -type chip]
  set topology [get_objects -parent $chip -type topology]

  set nSource 0
  set nTarget 0
  foreach typ $initiatorTypes {
    set objs [get_objects -parent $topology -type $typ]
    puts "$typ   N = [llength $objs]"
    set nSource [llength $objs]
    foreach u $objs {
      set_node_position -object $u -x 0 ; # initiator for full_crossbar
    }
  }
  foreach typ $targetTypes {
    set objs [get_objects -parent $topology -type $typ]
    puts "$typ   N = [llength $objs]"
    set nTarget [llength $objs]
    foreach u $objs {
      set_node_position -object $u -x 1 ; # target for full_crossbar
    }
  }
  return [list $nSource $nTarget]
}

proc MeshGenerator::create_mesh_locs2 {} {
  set chip [get_objects -parent root -type chip]
  # puts "CHIP: $chip"
  set topology [get_objects -parent $chip -type topology]
  # puts "FABRIC: $topology"
  set_context -name $topology

  # verify_ncores $chip
  set mostUnits 0
  set unitGroups [MeshGenerator::getNcores $topology]
  foreach kee [dict keys $unitGroups] {
    if {$kee == "atu"} {
      continue ; # after CSR, many atu created
    }
    set units [dict get $unitGroups $kee]
    set n [llength $units]
    # puts "$kee : units: $n"
    if {$n > $mostUnits} {
      set mostUnits $n
    }
  }
  # 
  puts "most : $mostUnits"

  set nd $mostUnits;
  incr nd

  set ii 1
  set units [dict get $unitGroups "caiu"]
  foreach u $units {
    set_node_position -object $u -x 0 -y $ii
    puts "$u   mesh 0 $ii"
    incr ii
  }

  set ii 1
  set units [dict get $unitGroups "ncaiu"]
  foreach u $units {
    set_node_position -object $u -x $nd -y $ii
    puts "$u   mesh $nd $ii"
    incr ii
  }

  set ii 1
  set units [dict get $unitGroups "dii"]
  foreach u $units {
    set_node_position -object $u -x $ii -y $nd
    puts "$u   mesh $ii $nd"
    incr ii
  }

  set ii 1
  set units [dict get $unitGroups "dmi"]
  foreach u $units {
    set_node_position -object $u -x $ii -y 0
    puts "$u   mesh $ii 0"
    incr ii
  }

  set level 0
  set cnt   0
  set units [dict get $unitGroups "dce"]
  foreach u $units {
    switch [expr $cnt % 4] {
      0 { 
        set x [expr 0 + $level];   set y [expr 0 + $level] ; # lft bot
      } 
      1 { 
        set x [expr $nd - $level]; set y [expr 0 + $level] ; # rht bot
      }
      2 { 
        set x [expr $nd - $level]; set y [expr $nd - $level] ; # rht top
      } 
      3 { 
        set x [expr 0 + $level];   set y [expr $nd - $level] ; # lft top
      }
      default { }
    } ; #switch
    incr cnt
    if {[expr $cnt %4] == 0} {
    	incr level
    }
    set_node_position -object $u -x $x -y $y
    puts "$u   mesh $x $y"
  }

  # max is one dve
  set ii [expr $nd / 2]
  set units [dict get $unitGroups "dve"]
  if {[llength $units] > 0} {
    set u [lindex $units 0]
    set_node_position -object $u -x $ii -y $ii
    puts "$u   mesh $ii $ii"
  }


  incr nd
  return $nd
}

proc genXY {pos gridSize} {
  set x [expr $pos / $gridSize]
  set y [expr $pos % $gridSize]
  return [list $x $y]
}

proc MeshGenerator::create_mesh_locs {} {
  set chip [get_objects -parent root -type chip]
  # puts "CHIP: $chip"
  set topology [get_objects -parent $chip -type topology]
  # puts "FABRIC: $topology"
  set_context -name $topology

  # verify_ncores $chip
  set mostUnits 0
  set totalUnits 0
  set unitGroups [MeshGenerator::getNcores $topology]
  foreach kee [dict keys $unitGroups] {
    if {$kee == "atu"} {
      continue ; # after CSR, many atu created
    }
    set units [dict get $unitGroups $kee]
    set n [llength $units]
    set totalUnits [expr $totalUnits + $n]
    # puts "$kee : units: $n"
    if {$n > $mostUnits} {
      set mostUnits $n
    }
  }
  # 
  # puts "most : $mostUnits"
  # puts "total: $totalUnits"

  set nd 2
  while {$nd*$nd < $totalUnits} {
    incr nd
  }

  puts "create_mesh_locs grid:  $nd"

  set pos 0

  set units [dict get $unitGroups "caiu"]
  foreach u $units {
    set xy [genXY $pos $nd]
    set_node_position -object $u -x [lindex $xy 0] -y [lindex $xy 1]
    incr pos
  }

  set units [dict get $unitGroups "dii"]
  foreach u $units {
    set xy [genXY $pos $nd]
    set_node_position -object $u -x [lindex $xy 0] -y [lindex $xy 1]
    incr pos
  }

  set units [dict get $unitGroups "dmi"]
  foreach u $units {
    set xy [genXY $pos $nd]
    set_node_position -object $u -x [lindex $xy 0] -y [lindex $xy 1]
    incr pos
  }

  set units [dict get $unitGroups "dce"]
  foreach u $units {
    set xy [genXY $pos $nd]
    set_node_position -object $u -x [lindex $xy 0] -y [lindex $xy 1]
    incr pos
  }

  set units [dict get $unitGroups "dve"]
  foreach u $units {
    set xy [genXY $pos $nd]
    set_node_position -object $u -x [lindex $xy 0] -y [lindex $xy 1] 
    incr pos
  }

  set units [dict get $unitGroups "ncaiu"]
  foreach u $units {
    set xy [genXY $pos $nd]
    set_node_position -object $u -x [lindex $xy 0] -y [lindex $xy 1]
    incr pos
  }

  return $nd
}

# proc MeshGenerator::route_csr_networks {chip clkSubDomain} {
#   puts "ERROR: MeshGenerator::route_csr_networks proc has been depreciated"

# }

proc _extractClock { params } {
  set clock ""
  set newParams [list ]
  set n [llength $params]
  for {set i 0} {$i < $n} {incr i} {
    set p [lindex $params $i]
    incr i
    set v [lindex $params $i]
    if {$p == "clock"} {
      set clock $v
    } else {
      lappend newParams $p $v
    }
  }
  return [list $clock $newParams]
}

proc MeshGenerator::generate_mesh_routes_by_network {chip topology net dtaWidth params} {
  set request  [query_object -object $net -type "csr_request"]
  set response [query_object -object $net -type "csr_response"]
  if {$request == "true" || $response == "true"} {
    return
  }

  set vals [_extractClock $params]
  set clk  [lindex $vals 0]
  set par2 [lindex $vals 1]

  set dw 0
  set isDataNetw [query_object -object $net -type dn]
  if {$isDataNetw == "true"} {
    set dw $dtaWidth
  }

  set nam [Project::abbrev $net]
  set route_params [list type mesh name $nam network $net dataWidth $dw]
  foreach p $par2 { lappend route_params $p }
  run_generator -name "regular_topology" -topology $topology -clock $clk -params $route_params
}

proc MeshGenerator::generate_routes_by_network {chip topology net dtaWidth params} {
  return [MeshGenerator::generate_mesh_routes_by_network $chip $topology $net $dtaWidth $params]
}

proc MeshGenerator::generate_mesh_routes {chip topology dtaWidth params} {
  set networks [get_objects -parent $chip -type network]
  foreach net $networks {
    MeshGenerator::generate_mesh_routes_by_network $chip $topology $net $dtaWidth $params
    # lappend params meshx $meshSize meshy $meshSize dataWidth $dw clock $clkSubDomain]
    # set loc [list meshx $meshSize meshy $meshSize dataWidth $dw clock $clkSubDomain optimizeDataWidth $optimizeDW]
  }
  puts "Auto insert adapters..."
  run_generator -name "adapters" -topology $topology
}

proc MeshGenerator::generate_routes {chip topology dtaWidth params} {
  return [MeshGenerator::generate_mesh_routes $chip $topology $dtaWidth $params]
}

proc MeshGenerator::route_networks {chip topology routingTemplate dtaWidth params {switchBufferDepth 0} } {
  # Ncore 4. assuming that both data networks will have same data width
  set dataNetws [Project::getDataNetworks]
  puts "DataNetworks: $dataNetws"
  # set dataNetw [lindex [Project::getDataNetworks] 0]
  # puts "DataNetwork: $dataNetw"

  set vals [_extractClock $params]
  set clk  [lindex $vals 0]
  set par2 [lindex $vals 1]

  set networks [get_objects -parent $topology -type network]
  foreach net $networks {
    set request  [query_object -object $net -type "csr_request"]
    set response [query_object -object $net -type "csr_response"]
    if {$request == "true" || $response == "true"} {
      continue
    }

    set dw 0
    foreach dnw $dataNetws {
      if {[string compare $net $dnw] == 0} {
        set dw $dtaWidth
      }
    }

    set nam [Project::abbrev $net]
    set route_params [list type $routingTemplate name $nam network $net dataWidth $dw]
    foreach p $par2 { lappend route_params $p }

    puts "# Generating regular topology"
    run_generator -name "regular_topology" -topology $topology -clock $clk -params $route_params

    set switches [get_objects -parent $topology -type "switch"]
    set netwSwitches [list ]
    foreach sw $switches {
      set nw [get_objects -parent $sw -type network]
      # puts "$sw : $nw"
      if {$nw == $net} {
        lappend netwSwitches $sw
      }
    }
    Switch::set_bufLayer0Depth $netwSwitches $switchBufferDepth
  }

  run_checker -name "deadlock-default"

  puts "Auto insert adapters..."
  run_generator -name "adapters" -topology $topology
}

proc MeshGenerator::getMeshSize {chip topology {network ""} } {
  set meshx 0
  set meshy 0
  set networks [get_objects -parent $topology -type network]
  set ncoreUnits [MeshGenerator::getNcores $topology]
  foreach kee [dict key $ncoreUnits] {
    set units [dict get $ncoreUnits $kee]
    # puts "MeshGenerator::getMeshSize  $kee N=[llength $units]"
    foreach u $units {
      if {$network != ""} {
        set pos [get_node_position -object $u -network $network]
        # puts "$u pos= $pos"
        if {[lindex $pos 0] > $meshx} {
          set meshx [lindex $pos 0]
        }
        if {[lindex $pos 1] > $meshy} {
          set meshy [lindex $pos 1]
        }
      } else {
        foreach netw $networks {
          set pos [get_node_position -object $u -network $netw]
          if {[lindex $pos 0] > $meshx} {
            set meshx [lindex $pos 0]
          }
          if {[lindex $pos 1] > $meshy} {
            set meshy [lindex $pos 1]
          }
        } ; # for netw
      }
    }
  }
  incr meshx 
  incr meshy
  return [list $meshx $meshy]
}
package provide MeshGenerator $MeshGenerator::version
package require Tcl 8.5

