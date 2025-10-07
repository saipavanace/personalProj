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
if {[info exists env($usrTclEnv)] == 1} {
  set MAESTRO_USER_TCL $env($usrTclEnv)
  puts "Env var $usrTclEnv = $MAESTRO_USER_TCL"
} else {
  puts "Env var $usrTclEnv not set"
}

#------------------------------------------------------------------------------
#Procedures to create routes
#------------------------------------------------------------------------------
proc _addSwitchBuffer {switches switchBufferDepth } {
  foreach sw $switches {
    # set inPorts [get_objects -parent $sw -type packet_port -subtype in]
    # foreach pp $inPorts {
    #   set_attribute -object $pp -name buffers -value $switchBufferDepth
    # }
    set_attribute -object $sw -name inputBufferDepth -value $switchBufferDepth
  }
}

proc _addRoute_ndn1 {netw1 width clk switchBufferDepth} {
  set switch_ndn1_yellow [list SW9 SW10 SW11 SW12 SW13 SW14 SW15 SW16]
  set switches [list ]
  set_context -name $netw1
  foreach swName $switch_ndn1_yellow {
    set sw [create_object -type "switch" -name $swName]
    update_object -name $sw -bind $clk -type "domain"
    lappend switches $sw
  }
  route_ndn1 $width $netw1
  _addSwitchBuffer $switches $switchBufferDepth
  return $switches
}

proc _addRoute_ndn2 {netw2 width clk switchBufferDepth} {
  set switch_ndn2_green  [list SW17 SW18 SW19 SW20 SW21 SW22 SW23 SW24]
  set switches [list ]
  set_context -name $netw2
  foreach swName $switch_ndn2_green {
    set sw [create_object -type "switch" -name $swName]
    update_object -name $sw -bind $clk -type "domain"
    lappend switches $sw
  }
  route_ndn2 $width $netw2
  _addSwitchBuffer $switches $switchBufferDepth
  return $switches
}

proc _addRoute_ndn3 {netw3 width clk switchBufferDepth} {
  set switch_ndn3  [list SW25 SW26 SW27 SW28 ]
  set switches [list ]
  set_context -name $netw3
  foreach swName $switch_ndn3 {
    set sw [create_object -type "switch" -name $swName]
    update_object -name $sw -bind $clk -type "domain"
    lappend switches $sw
  }
  route_ndn3 $width $netw3
  _addSwitchBuffer $switches $switchBufferDepth
  return $switches
}

proc _addRoute_dn1 {netw3 width clk switchBufferDepth} {
  set switch_dn3_blue    [list SW1  SW2  SW3  SW4  SW5  SW6  SW7  SW8  ]
  set switches [list ]
  set_context -name $netw3
  foreach swName $switch_dn3_blue {
    set sw [create_object -type "switch" -name $swName]
    update_object -name $sw -bind $clk -type "domain"
    lappend switches $sw
  }
  route_dn1 $width $netw3
  _addSwitchBuffer $switches $switchBufferDepth
  return $switches
}


proc addRoute {topology clk dataWidth autopipeList switchBufferDepth} {
  set script_dir [file dirname [file normal [info script] ] ]
  puts "Routing script dir: $script_dir"
  source $script_dir/route_netw.tcl
  set chip     [get_objects -type chip -parent root]
  set system   [get_objects -type system -parent $chip]
  set subsystem [get_objects -type subsystem -parent $system]
  set topology [get_objects -type topology -parent $subsystem]
  set networks [get_objects -parent $topology -type network]

  set ndn1 [lindex $networks 0]
  set ndn1_switches [_addRoute_ndn1 $ndn1 0 $clk $switchBufferDepth]
  if {[lindex $autopipeList 0] > 0} {
    Ts::addPipeAdapterBetweenSwitches $ndn1_switches $clk $ndn1
  }

  set ndn2 [lindex $networks 1]
  set ndn2_switches [_addRoute_ndn2 $ndn2 0 $clk $switchBufferDepth]
  if {[lindex $autopipeList 1] > 0} {
    Ts::addPipeAdapterBetweenSwitches $ndn2_switches $clk $ndn2
  }

  set ndn3 [lindex $networks 2]
  set ndn3_switches [_addRoute_ndn3 $ndn3 0 $clk $switchBufferDepth]
  if {[lindex $autopipeList 2] > 0} {
    Ts::addPipeAdapterBetweenSwitches $ndn3_switches $clk $ndn3
  }

  set dn1 [lindex $networks 3]
  set dn_switches [_addRoute_dn1 $dn1 $dataWidth $clk $switchBufferDepth]
  if {[lindex $autopipeList 3] > 0} {
    Ts::addPipeAdapterBetweenSwitches $dn_switches $clk $dn1
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

set clocksubdomains [list]

puts "Design Name: $designName"
set project [create_project -name $designName]

#------------------------------------------------------------------------------------------------
# Create Clocks and Power
#------------------------------------------------------------------------------------------------

set chip [create_object -type chip -name "chip" -parent $project]


set myProc [info procs base_clockCB]
if {$myProc != ""} {
  set clocksubdomains [base_clockCB $chip]
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
set_attribute -object $subsystem/NcoreSettings -name "dceCount" -value $nDCE_directories

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

#-------------------------------------------------------------------------------------------------
# Auto generate units from interfaces
#-------------------------------------------------------------------------------------------------
run_generator -name "interface_units" -topology $topology -clock $default_clock


#-----------------------------------------------------------------------------------------------
# # add route
#----------------------------------------------------------------------------------------------
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
  set switchBufferDepth 2
  set autopipe_ndn1 0 ; # 0 = no autopipe, 1 = autopipe
  set autopipe_ndn2 0
  set autopipe_ndn3 0
  set autopipe_dn   0
  set autopipeList [list $autopipe_ndn1 $autopipe_ndn2 $autopipe_ndn3 $autopipe_dn]
  addRoute $topology $default_clock $dataWidth $autopipeList $switchBufferDepth
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
#---------------------------------------------------------------------

run_generator -topology $topology -name "adapters"

#----------------------------------------------------------------------------------------------
# Set Transport solution defaults
#----------------------------------------------------------------------------------------------
Ts::set_pre_map_unit_defaults


#-------------------------------------------------------------------------------------------------
# Call the user pre-map parameters
#-------------------------------------------------------------------------------------------------
set fname "pre_map_params.tcl"
if {[info exists env($usrEnv)] == 1} {
  set fname2 [file join  $env($usrEnv) $base_config $fname]
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
puts "$$$$ MUT: $env($usrEnv) base_config = $base_config"
if {[info exists env($usrEnv)] == 1} {
  set fname2 [file join  $env($usrEnv) $base_config $fname]
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

set vals [MeshGenerator::verify_routes $chip $topology]
set expectedRoutes [lindex $vals 2]; # number of mapped flows
set actualRoutes   [lindex $vals 3]
if {$actualRoutes != $expectedRoutes} {
 puts "Error: Packetroutes found: $actualRoutes , expecting $expectedRoutes"
 #exit
}

set fname "grpc_connect.tcl"
if {[info exists env($usrEnv)] == 1} {
  set fname2 [file join  $env($usrEnv) $fname]
  if {[file exists $fname2] == 1} {
    puts "Sourcing $fname2 ..."
    source $fname2
  }
}

# exit
