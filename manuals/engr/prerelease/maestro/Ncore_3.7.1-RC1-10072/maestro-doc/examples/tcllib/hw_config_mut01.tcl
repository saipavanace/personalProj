###################################################################################################
# Main
###################################################################################################
global env
set tcllib "MAESTRO_TCLLIB"
if {[info exists $env($tcllib)]} {
  set tclProcLib  $env($tcllib) 
  puts "TclLib = $tclProcLib"
  lappend auto_path "$tclProcLib"
}

# set usrEnv MAESTRO_BASE_DESIGNS
set usrEnv MAESTRO_EXAMPLES

set usrTclEnv MAESTRO_USER_TCL
set MAESTRO_USER_TCL ""
puts "MUT exists? [info exists env($usrTclEnv)]"
if {[info exists env($usrTclEnv)] == 1} {
  set MAESTRO_USER_TCL $env($usrTclEnv)
  puts "Env var $usrTclEnv = $MAESTRO_USER_TCL"
  set fname2 [file join $MAESTRO_USER_TCL config_design.tcl]
  if {[file exists $fname2]} {
    puts "Sourcing MUT $fname2"
    source $fname2
  }
} else {
  puts "Env var $usrTclEnv not set"
}

puts "Base design dir: $curDir"

#------------------------------------------------------------------------------
#Procedures to create routes
#------------------------------------------------------------------------------
proc createSwitches {netw clk swNames} {
  set switches [list ]
  set_context -name $netw
  foreach swName $swNames {
    set sw [create_object -type "switch" -name $swName]
    update_object -name $sw -bind $clk -type "domain"
    lappend switches $sw
  }
  return $switches    
}

proc addSwitchBuffer {switches switchBufferDepth } {
  foreach sw $switches {
    # set inPorts [get_objects -parent $sw -type packet_port -subtype in]
    # foreach pp $inPorts {
    #   set_attribute -object $pp -name buffers -value $switchBufferDepth
    # }
    set_attribute -object $sw -name inputBufferDepth -value $switchBufferDepth
  }
}

proc sourceRouteFile { base_config_dir MAESTRO_USER_TCL } {
  # first, if mut route tcl is found, source it only
  # if not found, look for base route tcl and source it
  # if not found, no manual route file found

  set found 0
  set route_default_name "route_netw.tcl"
  set route_file_name ""; #"route_netw.tcl"
  if {[string length $MAESTRO_USER_TCL ] > 0} {
    set ff [file join $MAESTRO_USER_TCL $route_default_name]
    global mut_manual_route_file
    puts "mut_manual_route_file exists = [info exists mut_manual_route_file] "

    if {[info exists mut_manual_route_file] } {
      puts "'$mut_manual_route_file' length = [string length $mut_manual_route_file]"
      if { [string length $mut_manual_route_file] > 0} {
        set ff [file join $MAESTRO_USER_TCL $mut_manual_route_file]
        if {[file exists $ff] } {
          set route_file_name $ff
          set found 1
        }
      }
   }

    puts "TestMUT $ff = [file exists $ff]"
    if {[file exists $ff] } {
      set route_file_name $ff
    }
  } else {
    set ff [file join $base_config_dir $route_default_name]

    puts "base_manual_route_file exists = [info exists base_manual_route_file]"
    if {[info exists base_manual_route_file] && [string length $base_manual_route_file] > 0} {
      set ff [file join $base_config_dir $base_manual_route_file]
    }
    puts "TestBASE $ff = [file exists $ff]"
    if {[file exists $ff] } {
      set route_file_name $ff
    }
  }

  if {[string length $route_file_name] > 0} {
    puts "Sourcing $route_file_name"
    source $route_file_name
  }
  return $route_file_name
}

proc addRoute {topology clk dataWidth autopipeList switchBufferDepth } {
  global base_config_dir 
  global MAESTRO_USER_TCL
 
  set dataNetworks [Project::getDataNetworks]
  set dnNetwork    [lindex $dataNetworks 0]
  set networks  [get_objects -parent $topology -type network]
  set nNetworks [llength $networks]

  for {set i 0} {$i < $nNetworks} {incr i} {
    set netw [lindex $networks $i]
    set shName [Project::abbrev $netw]
    set switches [list ]

    # set isDataNetw [get_objects -parent $netw -type dn]
    # if {$isDataNetw == 1} {}
    set dWidth 0
    if {[string compare $netw $dnNetwork] == 0} {
      set dWidth $dataWidth
    }

    set has_mutRoute 0
    set proc_addRoute mut_addRoute_$shName
    puts "Routing $shName  PROC=$proc_addRoute  EXISTS=[info procs $proc_addRoute]"
    if {[info procs $proc_addRoute] != ""} {
      puts "Routing2 $shName  PROC=$proc_addRoute  dataWidth=$dWidth"
      set switches2 [$proc_addRoute $netw $dWidth $clk $switchBufferDepth]
      foreach sw $switches2 {
        lappend switches $sw
      }
      set has_mutRoute 1
    }
    
    if {$has_mutRoute == 0} {
      set proc_addRoute base_addRoute_$shName
      puts "Routing $shName  PROC=$proc_addRoute  EXISTS=[info procs $proc_addRoute]"
      if {[info procs $proc_addRoute] != ""} {
        puts "Routing1 $shName  PROC=$proc_addRoute dataWidth=$dWidth"
        set switches [$proc_addRoute $netw $dWidth $clk $switchBufferDepth]
      }
    }

    if {[lindex $autopipeList $i] > 0} {
      Ts::addPipeAdapterBetweenSwitches $switches $clk $netw
    }
  }
}

proc trimSwitches {wid clk netw pp1 sw1 sw2} {
  # set unitParent [Project::get_unit_parent]

  set seg1 [get_objects -parent $pp1 -type link_segment]
  if {$seg1 == ""} {
    puts "No seg at: $pp1"
    return
  }
  set pps  [get_objects -parent $seg1 -type packet_port]
  if {[llength $pps] < 2} {
    puts "Seg: $seg1  $pps"
    return;
  }
  set pps1 [lindex $pps 0]
  set pps2 [lindex $pps 1]
  puts "  pps1: $pps1  pps2: $pps2"
  set swith   [get_objects -parent $pps1 -type parent]
  set pps1_sw [Project::abbrev $swith]
  set swith   [get_objects -parent $pps2 -type parent]
  set pps2_sw [Project::abbrev $swith]
  if {$pps1_sw == $sw1 && $pps2_sw == $sw2} {
    set suffix [lindex [file split $pp1] end]
    set pps1_wid [get_parameter -object $pps1 -name dataWidth]
    set pps2_wid [get_parameter -object $pps2 -name dataWidth]
    set nam  "wAdapter_"
    append nam $sw1 "_" $suffix "_" $sw2
    set wAdap1 [insert_adapter -port $pps1 -type width_adapter -name $nam]
    update_object -name $wAdap1 -bind $clk -type "domain"
    set widPPin  [get_objects -parent $wAdap1 -type packet_port -subtype in]
    set widPPout [get_objects -parent $wAdap1 -type packet_port -subtype out]
    set_attribute -object $widPPin  -name dataWidth -value $pps1_wid
    set_attribute -object $widPPout -name dataWidth -value $wid
    puts "  $wAdap1 $pps1 ($pps1_wid) $pps2 ($pps2_wid)"

    set nam  "wAdapter_"
    append nam $sw2 "_" $suffix "_" $sw1
    set wAdap2 [insert_adapter -port $pps2 -type width_adapter -name $nam]
    update_object -name $wAdap2 -bind $clk -type "domain"
    set widPPin  [get_objects -parent $wAdap2 -type packet_port -subtype in]
    set widPPout [get_objects -parent $wAdap2 -type packet_port -subtype out]
    set_attribute -object $widPPin  -name dataWidth -value $wid
    set_attribute -object $widPPout -name dataWidth -value $pps2_wid
    puts "  $wAdap2 $pps2 ($pps2_wid) $pps1 ($pps1_wid)"
  }
}

proc trimNetworkWidth { topology netw clk trims } {
  set_context -name $netw
  foreach trim $trims {
    set n   [llength $trim ]
    set wid [lindex  $trim 0]
    for {set i 1} {$i < $n} { incr i} {
      set pr  [lindex $trim $i]
      set sw1 [lindex $pr 0]
      set sw2 [lindex $pr 1]
      puts "TrimWidth: $wid $sw1 $sw2"
      set pp1  [get_objects -parent $sw1 -type packet_port -subtype out]
      foreach pp $pp1 {
        trimSwitches $wid $clk $netw $pp $sw1 $sw2
      }
      set pp2  [get_objects -parent $sw2 -type packet_port -subtype out]
      foreach pp $pp2 {
        trimSwitches $wid $clk $netw $pp $sw2 $sw1
      }
    }
  }
}


###################################################################################################
# MAIN_BODY
###################################################################################################
set autopipeList [list]

set clocksubdomains [list]
set base_config_dir [file join $curDir $base_config]

set executable_dir  [file dirname [file normalize $maestro_tcl_dir] ]
puts "Executable Directory: $executable_dir"

puts "Design Name: $designName"
set project [create_project -name $designName]

#------------------------------------------------------------------------------------------------
# Create Clocks and Power
#------------------------------------------------------------------------------------------------

set chip [create_object -type chip -name "chip" -parent $project]

if {[info proc mut_designVarsCB] != ""} {
  mut_designVarsCB
}

set myProc [info procs base_clockCB]
if {$myProc != ""} {
  set clocksubdomains [base_clockCB $chip]
}
set myProc [info procs mut_clockCB]
if {$myProc != ""} {
  set clocksubdomains2 [mut_clockCB $chip]
  foreach c $clocksubdomains2 {
    lappend clocksubdomains $c
  }
}

#-----------------------------------------------------------------------------------------------
# Create Interfaces
#-----------------------------------------------------------------------------------------------
set system [create_object -type system -name "system" -parent $chip]
set subsystem [create_object -type subsystem -name "subsystem" -parent $system] 

set myProc [info procs base_socketCB]
if {$myProc != ""} {
  base_socketCB $subsystem
}
set myProc [info procs mut_socketCB]
if {$myProc != ""} {
  mut_socketCB $subsystem
}

set_attribute -object $subsystem/NcoreSettings -name dceCount -value $nDCE_directories

#-------------------------------------------------------------------------------------------
#Memorymap
#-------------------------------------------------------------------------------------------
#create memorymap . 
# Memorymap should always be created first before creating Bootregion, CsrRegion or DMIinterleaving
set mm [create_object -type memory_map -name "mm" -parent $subsystem]


set myProc [info procs base_memoryMapCB]
if {$myProc != ""} {
  base_memoryMapCB $mm
}
set myProc [info procs mut_memoryMapCB]
if {$myProc != ""} {
  mut_memoryMapCB $mm
}
# save_project -file "configDesign.mpf"
# puts "Saving configDesign.mpf"

set default_clock  [Ts::get_interconnect_clock]
if {[CsrNetwork::get_clock] == ""} {
  CsrNetwork::set_clock $default_clock
}
set csr_clock       [CsrNetwork::get_clock]
set interrupt_clock [Ts::get_interconnect_clock]

set dbg 1
if {$dbg == 1} {
  puts "subsystem = $subsystem"
  puts "clocksubdomains = $clocksubdomains"
  puts "default_clock = $default_clock"
  puts "csr_clock = $csr_clock"
  puts "interrupt_clock = $interrupt_clock"
  puts "routing_template = $routing_template"
  set socketDict [Socket::getSocketDict]
  puts "socketDict  SIZE=[llength $socketDict]"
  foreach kee [dict keys $socketDict] {
    set socks [dict get $socketDict $kee ]
    foreach sk $socks {
      puts "$kee : $sk"
    }
  }
}



#------------------------------------------------------------------------------------------------
# Create Ncore Units
#------------------------------------------------------------------------------------------------
set topology [create_object -type topology -name "topology" -parent $subsystem ]
set_attribute -object $topology -name coherentTemplate -value $topology_template
puts "Topology template: $topology_template"

#-------------------------------------------------------------------------------------------------
# Auto generate units from interfaces
#-------------------------------------------------------------------------------------------------
run_generator -name "interface_units" -topology $topology -clock $default_clock
# save_project -file "interfaceUnits.mpf"

#-----------------------------------------------------------------------------------------------
# # add route
#----------------------------------------------------------------------------------------------
set networks [get_objects -parent $chip -type network]
foreach netw $networks {
  lappend autopipeList 0  ; # 0 = no autopipe, 1 = autopipe
}

set userAssignLocation 0
set meshX 0
set meshY 0
set myProc [info procs base_preRouteCB]
if {$myProc != ""} {
  set userAssignLocation [base_preRouteCB $chip $subsystem $topology $default_clock]
  if {$userAssignLocation == 1} {
    set siz [MeshGenerator::getMeshSize $chip $topology]
    puts "Mesh: $siz"
    set meshX [lindex $siz 0]
    set meshY [lindex $siz 1]
    puts "meshx $meshX meshy $meshY userAsssign=$userAssignLocation"
  }
}
set myProc [info procs mut_preRouteCB]
if {$myProc != ""} {
  mut_preRouteCB $chip $subsystem $topology $default_clock
}

if {[string compare $routing_template "mesh"] == 0 ||
    [string compare $routing_template "torus"] == 0} {
  if {$userAssignLocation  == 0} {
    set meshSize [MeshGenerator::create_mesh_locs]
    set meshX $meshSize
    set meshY $meshSize
    puts "meshx $meshX meshy $meshY userAsssign=$userAssignLocation"
  }
}

puts "Routing template: $routing_template"
if {[string compare $routing_template "manual"] == 0} {

  set ok 0
  set route_default_name "route_netw.tcl"
  if {[string length $MAESTRO_USER_TCL ] > 0} {
    set ff [file join $MAESTRO_USER_TCL $route_default_name]
    if {[file exists $ff] } {
      puts "Sourcing $ff"
      source $ff
      set ok 1
    }
  }
  if {$ok == 0} {
    set ff [file join $base_config_dir $route_default_name]
    if {[file exists $ff] } {
      puts "Sourcing $ff"
      source $ff
      set ok 1
    }
  }
  if {$ok == 0} {
    puts "Warning: cannot find routing file: $route_default_name"
  }

  set switchBufferDepth 2
  # set autopipe_ndn1 0 ; # 0 = no autopipe, 1 = autopipe
  # set autopipe_ndn2 0
  # set autopipe_ndn3 0
  # set autopipe_dn   0
  # set autopipeList [list $autopipe_ndn1 $autopipe_ndn2 $autopipe_ndn3 $autopipe_dn]
  puts "autopipeList = $autopipeList"

  addRoute $topology $default_clock $routing_dataWidth $autopipeList $switchBufferDepth
} else {
  if {[string compare $routing_template "ring"] == 0} {
    set meshX [RingGenerator::getNcoresNumber $topology]
  }
  set params [list clock $default_clock meshx $meshX meshy $meshY ]
  MeshGenerator::route_networks $chip $topology $routing_template $routing_dataWidth $params
}

set myProc [info procs base_postRouteCB]
if {$myProc != ""} {
  base_postRouteCB $chip $subsystem $topology $default_clock
}
set myProc [info procs mut_postRouteCB]
if {$myProc != ""} {
  mut_postRouteCB $chip $subsystem $topology $default_clock
}

# #----------------------------------------------------------------------------------------------
# # Autogenerate CSR network
# #----------------------------------------------------------------------------------------------
create_configuration_units -topology $topology -clock $csr_clock
connect_request_csr_network -topology $topology -clock $csr_clock
connect_response_csr_network -topology $topology -clock $csr_clock

#----------------------------------------------------------------------------------------------
# Generate interrupt accumulator
#----------------------------------------------------------------------------------------------
run_generator -topology $topology -clock $interrupt_clock -name "interrupt"

#----------------------------------------------------------------------
# Auto insert adapters
#----------------------------------------------------------------------
run_generator -topology $topology -name "adapters"

#----------------------------------------------------------------------------------------------
# Set Transport solution defaults
#----------------------------------------------------------------------------------------------
Ts::set_pre_map_unit_defaults


#-------------------------------------------------------------------------------------------------
# Call the user pre-map parameters
#-------------------------------------------------------------------------------------------------
set fname "pre_map_params.tcl"
# if {[info exists env($usrEnv)] == 1} {}
#   set fname2 [file join  $env($usrEnv) $base_config $fname]
if {[info exists curDir] == 1} {
  set fname2 [file join  $curDir $fname]
  if {[file exists $fname2] == 1} {
    puts "Sourcing $fname2 ..."
    source $fname2
  } else {
    puts "Warning: Cannot find $fname2"
    return
  }
}

if {$MAESTRO_USER_TCL != ""} {
  set fname2 [file join $MAESTRO_USER_TCL $fname]
  if {[file exists $fname2] == 1} {
    puts "Sourcing $fname2 ..."
    source $fname2
  }
}

#----------------------------------------------------------------------
# Generator for resiliency
#---------------------------------------------------------------------

run_generator -topology $topology -clock $default_clock -name "resiliency"

set fname "$designName.premapping.mpf"
save_project -file $fname
puts "Created MPF: $fname"

if {[info exists stopScriptBeforeMapping]} {
	return
}

#-------------------------------------------------------------------------------------------------

run_task -name move_to_next_state

#-------------------------------------------------------------------------------------------------

# Post_map parameters
Caiu::set_all_post_map_defaults
Ncaiu::set_all_post_map_defaults
Dmi::set_all_post_map_defaults
Dii::set_all_post_map_defaults
Dce::set_all_post_map_defaults
Apb_atu::set_all_post_map_defaults
Axi_atu::set_all_post_map_defaults


#-------------------------------------------------------------------------------------------------

#---------------------------------------------------------------------------------------------------
#Set individual post-map parameters
set fname "post_map_params.tcl"
# puts "$$$$ MUT: $env($usrEnv) base_config = $base_config"
# if {[info exists env($usrEnv)] == 1} {}
#   set fname2 [file join  $env($usrEnv) $base_config $fname]
if {[info exists curDir] == 1} {
  set fname2 [file join  $curDir $fname]
  if {[file exists $fname2] == 1} {
    puts "Sourcing $fname2 ..."
    source $fname2
  } else {
    puts "Warning: Cannot find $fname2"
    return    
  }
}

if {$MAESTRO_USER_TCL != ""} {
  set fname2 [file join $MAESTRO_USER_TCL $fname]
  if {[file exists $fname2] == 1} {
    puts "Sourcing $fname2 ..."
    source $fname2
  }
}

set verbose 0
if {$verbose > 0} {
  Project::print_unit_summary $verbose
}


save_project -file "$designName.postmapping.mpf"
puts "Created MPF: $designName.postmapping.mpf"

#Export json for RTL generation
exec mkdir -p "./json"
export_design -format "flat" -file "json/top.level.json"
puts "Done exporting jsons\n\n"

# set vals [MeshGenerator::verify_routes $chip $topology]
# set expectedRoutes [lindex $vals 2]; # number of mapped flows
# set actualRoutes   [lindex $vals 3]
# if {$actualRoutes != $expectedRoutes} {
#  puts "Error: Packetroutes found: $actualRoutes , expecting $expectedRoutes"
#  #exit
# }

set maestro_home "MAESTRO_HOME"
if {[info exists env($maestro_home)]} {
  set maestro_home $env($maestro_home)
  set maestro_server [ file join [file normalize $maestro_home ] ../maestro-server/maestro-server]
  if {[file exists $maestro_server]} {
    puts "Calling gen_collateral ..."
    gen_collateral -server_exec /engr/dev/releases/utils/dep/m.ncore.stable/maestro-server/maestro-server    
  }
}

set fname "grpc_connect.tcl"
if {[info exists env($usrEnv)] == 1} {
  set fname2 [file join  $env($usrEnv) $fname]
  if {[file exists $fname2] == 1} {
    puts "Sourcing $fname2 ..."
    source $fname2
  }
}

exit
