package require MeshGenerator 2.0

namespace eval Project {
  namespace export isSocketUnitMatch
  namespace export populateUnits
  namespace export create_proj
  namespace export create_clock
  namespace export get_clock_domain
  namespace export create_clock_subdomain
  namespace export get_clock_region
  namespace export create_clock_domain
  namespace export set_coherentTemplate 
  namespace export set_dce_count
  namespace export get_chip
  namespace export get_topology
  namespace export get_design_name
  namespace export verify_ncores
  namespace export verify_sockets
  namespace export verify_adapters
  namespace export getNetworkName
  namespace export getDataNetworks
  namespace export getCsrRequestNetwork
  namespace export getCsrResponseNetwork
  namespace export useSubsystem
  namespace export set_useSubsystem
  namespace export get_subsystem
  namespace export print_unit_summary
  namespace export createNcoreUnits
  namespace export create_transportSolution
  namespace export exec_file
  namespace export createFlow
  namespace export createAllFlows
  namespace export abbrev
  namespace export report_objects
  namespace export create_interrupts_and_csr_networks
  namespace export create_flow
  namespace export get_request_response_networks
  namespace export create_unit
  namespace export generate_collateral
  set version 2.0

  set Description "Maestro_Project"
  variable home [file join [pwd] [file dirname [info script] ] ]
  variable designName
  variable _useSubsystem 1
}

proc Project::isSocketUnitMatch { socket_list unit_list} {
  set n [llength $socket_list]
  if {$n == 0} {
    return 0
  }
  set isMatch 1
  if { [llength $socket_list] > [llength $unit_list]} {
    return 0
  } else {
    for {set i 0} {$i < $n} {incr i} {
      set sock [lindex $socket_list $i]
      set unit [lindex $unit_list   $i]
      set newSock [get_objects -parent $unit -type socket]
      if {[string compare $newSock $sock] != 0} {
        set isMatch  0
      }
    }
  }
  return $isMatch
}

proc Project::populateUnits { chipSocketDict } {
  set chip   [get_objects -parent root  -type chip]
  set ts     [Project::get_topology]
  set caius  [get_objects -parent $ts -type caiu]
  set ncaius [get_objects -parent $ts -type ncaiu]
  set dmis   [get_objects -parent $ts -type dmi]
  set diis   [get_objects -parent $ts -type dii]
  set dces   [get_objects -parent $ts -type dce]
  set dves   [get_objects -parent $ts -type dve]

  set sk_caius [list]
  if {[dict exist $chipSocketDict CAIU] } {
    set sk_caius    [dict get $chipSocketDict CAIU]
  }
  set sk_ncaius [list]
  if {[dict exist $chipSocketDict IOAIU] } {
    set sk_ncaius   [dict get $chipSocketDict IOAIU]
  }
  set sk_dmis [list]
  if {[dict exist $chipSocketDict DMI] } {
    set sk_dmis     [dict get $chipSocketDict DMI]
  }
  set sk_diis [list]
  if {[dict exist $chipSocketDict DII] } {
    set sk_diis     [dict get $chipSocketDict DII]
  }
  # puts "CAIU:   [llength $caius] $caius"
  # puts "skCAIU: [llength $sk_caius] $sk_caius"
  if {[Project::isSocketUnitMatch $sk_caius $caius] == 1} {
    set nu [Caiu::set_createdUnits $caius]
    Caiu::set_pre_map_unit_defaults $caius
    puts "Caiu matched $nu"
  }

  # puts "NCAIU:  [llength $ncaius] $ncaius"
  # puts "skNCAIU:[llength $sk_ncaius] $sk_ncaius"
  if {[Project::isSocketUnitMatch $sk_ncaius $ncaius] == 1} {
    set nu [Ncaiu::set_createdUnits $ncaius]
    Ncaiu::set_pre_map_unit_defaults $ncaius
    puts "Ncaiu matched $nu"
  }

  # puts "DII:   [llength $diis] $diis"
  # puts "skDII: [llength $sk_diis] $sk_diis"
  if {[Project::isSocketUnitMatch $sk_diis $diis] == 1} {
    set nu [Dii::set_createdUnits $diis]
    Dii::set_pre_map_unit_defaults $diis
    puts "Dii matched $nu"
  }

  # puts "DMI:   [llength $dmis] $dmis"
  # puts "skDMI: [llength $sk_dmis] $sk_dmis"
  if {[Project::isSocketUnitMatch $sk_dmis $dmis] == 1} {
    set nu [Dmi::set_createdUnits $dmis]
    Dmi::set_pre_map_unit_defaults $dmis
    puts "Dmi matched $nu"
  }

  # puts "DCE:   [llength $dces] $dces"
  # puts "num DCE: [llength $dces]"
  set nu [Dce::set_createdUnits $dces]
  Dce::set_pre_map_unit_defaults $dces
  puts "Dce matched $nu"

  # puts "DVE:   [llength $dves] $dves"
  # puts "num DVE: [llength $dves]"
  set nu [Dve::set_createdUnits $dves]
  Dve::set_pre_map_unit_defaults $dves
  puts "Dve matched $nu"
}

proc Project::report_objects { } {
  set chip [Project::get_chip]
  set subsystem [Project::get_subsystem]
  set topology  [Project::get_topology]
  set sockets [get_objects -parent $chip -type socket]
  foreach sk $sockets {
    puts "$sk [get_parameter -object $sk]"
  }
  set units [get_objects -parent $topology -type ncoreunit]
  foreach nc $units {
    puts "ATTR $nc [get_parameter -object $nc]"
  }
}

proc checkFile { fileName } {
  if { [file exists $fileName] == 1} {
    file delete $fileName
  }
}

proc Project::set_useSubsystem { val } {
  set Project::_useSubsystem $val
}

proc Project::useSubsystem { } {
  return $Project::_useSubsystem
}

proc Project::get_chip { } {
  set chip     [get_objects -type chip -parent root]
  return $chip
}

proc Project::get_topology { } {
  set chip     [get_objects -type chip -parent root]
  set system   [get_objects -type system -parent $chip]
  set subsystem [get_objects -type subsystem -parent $system]
  set topology [get_objects -type topology -parent $subsystem]
  return $topology
}

proc Project::get_subsystem { } {
  set chip     [get_objects -type chip -parent root]
  set system   [get_objects -type system -parent $chip]
  set subsystem [get_objects -type subsystem -parent $system]
  return $subsystem
}

proc Project::get_clock_domain { clkSubDomain } {
  return [get_objects -parent $clkSubDomain -type clock_domain]
}

proc Project::get_clock_region { clkDomain } {
  return [get_objects -parent $clkDomain -type clock_region]
}

proc Project::create_clock_subdomain { name clkdomain } {
  set subdomain [create_object -type clock_subdomain -name $name -parent $clkdomain]
  return $subdomain
}

proc Project::create_clock_domain { name clkregion } {
  set domain [create_object -type clock_domain -name $name -parent $clkregion]
  return $domain
}

proc Project::create_clock { name frequency powerdomain} {
  set chip [Project::get_chip]
  set clkrgn [create_object -type clock_region -name $name -parent $chip]
  set_attribute -object $clkrgn -name frequency -value $frequency
  set pwrrgn [get_objects -parent $powerdomain -type parent]
  # puts "pwrDomain: $powerdomain  pwrRegion: $pwrrgn"
  update_object -name $clkrgn -bind $pwrrgn -type "powerRegion"

  set clkdomain [create_object -type clock_domain -name ${name}_domain -parent $clkrgn]
  set_attribute -object $clkdomain -name gating -value always_on
  update_object -name $clkdomain -bind $powerdomain -type "powerDomain"

  set clksubdomain [create_object -type clock_subdomain -name ${name}_subdomain -parent $clkdomain]
  return $clksubdomain
}

proc Project::set_coherentTemplate { type } {
  set topology [Project::get_topology]
  set_attribute -object $topology -name coherentTemplate -value $type
}

proc Project::set_dce_count { value } {
  set subsystem [Project::get_subsystem]
  set_attribute -object $subsystem/NcoreSettings -name dceCount -value $value
}

proc Project::create_transportSolution {coherentTemplate} {
  set subsys [Project::get_subsystem]
  if {$subsys != ""} {
    set topology [create_object -type topology -name "topology" -parent $subsys]
    set_attribute -object $topology -name coherentTemplate -value $coherentTemplate
    # Project::set_coherentTemplate $coherentTemplate 
    return $topology
  }
  return ""
}

proc Project::get_design_name { } {
  return $Project::designName
}

proc Project::create_proj { design_name {license "Arteris/Dev"}} {
  puts "Using Project TclVersion $Project::version"

  checkFile ${design_name}.mpf
  set Project::designName $design_name
  set project [create_project -name $design_name -license_token $license]
  set chip    [create_object -type chip -name "chip" -parent $project]
  set system [create_object -type system -name "system" -parent $chip]
  set subsys [create_object -type subsystem -name subsystem -parent $system]
  set topology ""
}
  # lappend Project::designEnv $chip $system "" "" $topology $subsystem

proc Project::exec_file {usrEnv tclFile} {
  global env
  if { [info exists env($usrEnv)] == 1} {
    set fname2 [file join  $env($usrEnv) $tclFile]
  } else {
    set fname2 $tclFile
  }
  if { [file exists $fname2] == 1} {
    puts "Sourcing $fname2 ..."
    source $fname2
  }
}

proc Project::abbrev { nam } {
  set pos [string last "/" $nam]
  set nap [string range $nam $pos+1 end]
  return $nap
}

proc Project::generate_collateral { designName } {
  # set maestro_server /engr/dev/releases/utils/dep/m.ncore.stable/maestro-server/maestro-server
  set maestro_server ""
  global env
  set maestro_home "MAESTRO_HOME"
  # Check for the env variable "MAESTRO_HOME"
  if {[info exists env($maestro_home)]} {
    set maestro_home $env($maestro_home)
    set maestro_server [ file join [file normalize $maestro_home ] ../maestro-server/maestro-server]
  }
  # Check for MAESTRO_SERVER
  if {[file exists $maestro_server]} {
    puts "Calling gen_collateral from $maestro_server"
    gen_collateral -server_exec $maestro_server -file $designName.tgz 
  } else {
    puts "Unable to find 'maestro-server' at $maestro_server . Exiting."
    return
    # error -1 ; # MAES-1225 just return (no error) if maestro_server is not found
  }
  # Check for gen_wrapper.v file
  if {[file exist $designName.tgz] && ([file size $designName.tgz] > 0)} {
    exec tar xvfz $designName.tgz
    set gwlength [llength [glob -nocomplain output/rtl/design/*gen_wrapper.v]]
    if { $gwlength == 0 } {
      puts "Unsuccesful in generating RTL. Exiting."
      error -1
    } else {
      puts "Successful in generating RTL."
      return
    }
  }
  puts "Error in generating RTL. Exiting."
  return
  # error -1 ; # MAES-1225 just return (no error) if maestro_server is not found
}


proc debug_dump_ncores { ncores } {
  # puts "dump_ncores N=[llength $ncores]"
  foreach kee [dict keys $ncores] {
    set units [dict get $ncores $kee]
    # puts "$kee N=[llength $units]"
    foreach ncore $units {
      set clksubD   [get_objects -parent $ncore -type clock_subdomain]
      set paret     [get_objects -parent $ncore -type parent]
      set paretClk  [get_objects -parent $paret -type clock_subdomain]
      set paretType [query_object -object $paret -type type]
      set ncInSMI   [get_objects -parent $ncore -type smi -subtype in]
      set ncOutSMI  [get_objects -parent $ncore -type smi -subtype out]
      if {$kee != "dce" && $kee != "dve"} {
        set sock      [get_objects -parent $ncore -type socket]
        set func1     [get_parameter -object $sock -name socketFunction];
        set type1     [get_parameter -object $sock -name protocolType];
        puts "**** Ncore: $kee  $ncore  socket=$sock ($type1) $func1 ****"
      } else {
        puts "**** Ncore: $kee  $ncore "
      }
      puts "      ClockSubDomain= $clksubD"
      puts "       Parent= $paret ($paretType)"
      puts "        Parent ClockSubDomain= $paretClk"
      if {$kee != "atu"} {
        set sock2 [get_objects -parent $ncore -type configsocket]
        set func2 [get_parameter -object $sock2 -name socketFunction];
        set type2 [get_parameter -object $sock2 -name protocolType];
        puts "       ATU socket: $sock2 ($type2) $func2"
      }
      puts "SMI_in: [llength $ncInSMI]  SMI_out: [llength $ncOutSMI]"
      foreach smi $ncInSMI {
        set netw [get_objects -parent $smi -type network]
        puts "  SMI_in:  $smi  net=$netw"
      }
      foreach smi $ncOutSMI {
        set netw [get_objects -parent $smi -type network]
        set clk  [get_objects -parent $smi -type clock_subdomain]
        puts "  SMI_out: $smi  net=$netw"
      }

      set ncPP    [get_objects -parent $ncore -type packet_port]
      set ncInPP  [get_objects -parent $ncore -type packet_port -subtype in]
      set ncOutPP [get_objects -parent $ncore -type packet_port -subtype out]
      puts "PP_in: [llength $ncInPP]  PP_out: [llength $ncOutPP]  total: [llength $ncPP]"
      foreach pp $ncInPP {
        set netw [get_objects -parent $pp -type network]
        set dWid  [get_parameter -object $pp -name dataWidth]
        puts "  PP_in:  $pp w=$dWid netw=$netw"
      }
      foreach pp $ncOutPP {
        set netw [get_objects -parent $pp -type network]
        set dWid  [get_parameter -object $pp -name dataWidth]
        puts "  PP_out: $pp w=$dWid netw=$netw"
      }
    }; #foreach units
  }; #foreach kee
}

proc _prtUnitParams { units } {
  foreach x $units {
    set clk  [get_objects -parent $x -type clock_subdomain]
    set sock [get_objects -parent $x -type socket]
    set typ  [get_parameter -object $sock -name protocolType]
    set wDat "--"
    set wAdr "--"
    if {$typ == "CHI-A"} {
      set wDat [Socket_CHI_A::get_wData $sock]
    } elseif {$typ == "CHI-B" || $typ == "CHI-E"} {
      set wAdr [Socket_CHI_B::get_wAddr $sock]
      set wDat [Socket_CHI_B::get_wData $sock]
    } elseif {$typ == "AXI"} {
      set wAdr [Socket_AXI::get_wAddr $sock]
      set wDat [Socket_AXI::get_wData $sock]
    } elseif {$typ == "ACE"} {
      set wAdr [Socket_ACE::get_wAddr $sock]
      set wDat [Socket_ACE::get_wData $sock]
    } elseif {$typ == "ACE-Lite"} {
      set wAdr [Socket_AceLite::get_wAddr $sock]
      set wDat [Socket_AceLite::get_wData $sock]
    } elseif {$typ == "ACE5-Lite"} {
      set wAdr [Socket_AceLiteE::get_wAddr $sock]
      set wDat [Socket_AceLiteE::get_wData $sock]
    }

    puts "$sock ($typ) $wDat [Project::abbrev $clk] $wAdr [Project::abbrev $x]"
  }
}

proc _prtDataWidths2 { units } {
  foreach x $units {
    set pps [get_objects -parent $x -type packet_port]
    set clk [get_objects -parent $x -type clock_subdomain]
    puts -nonewline "$x (clk=$clk) "
    foreach pp $pps {
      set short [Project::abbrev $pp]
      set width [get_parameter -object $pp -name dataWidth]
      puts -nonewline " ($short w=$width)"
      if {$width == 0} {
        set linkseg [get_objects -parent $pp -type link_segment]
        if {$linkseg == ""} {
          continue;
        }
        set linkpps [get_objects -parent $linkseg -type packet_port]
        set fr [lindex $linkpps 0]
        puts -nonewline " (FR: $fr"
        set frWid [get_parameter -object $fr -name dataWidth]
        puts -nonewline " $frWid"
        set to [lindex $linkpps 1]
        puts -nonewline " TO: $to"
        set toWid [get_parameter -object $to -name dataWidth]
        puts -nonewline " $toWid)"
        #puts -nonewline " (FR: $fr $frWid TO: $to $toWid)"
      }
    }
    puts " "
  }
}

proc Project::verify_ncores { } {
  set chip  [Project::get_chip]
  set units [MeshGenerator::getNcores $chip]
  debug_dump_ncores $units
}

proc Project::verify_sockets { } {
  set chip  [Project::get_chip]
  set unit_dict [MeshGenerator::getNcores $chip]
  foreach kee [dict keys $unit_dict] {
    set uns [dict get $unit_dict $kee]
    # puts "$kee : N = [llength $uns]"
    if {$kee == "dce" || $kee == "dve" || $kee == "atu"} {
      continue
    }
    _prtUnitParams $uns
  }
}

proc Project::verify_adapters { } {
  set chip  [get_objects -parent root  -type chip]
  set ts    [Project::get_topology]
  set wAdap [get_objects -parent $ts -type width_adapter]
  set cAdap [get_objects -parent $ts -type clock_adapter]
  set rAdap [get_objects -parent $ts -type rate_adapter]
  set pAdap [get_objects -parent $ts -type pipe_adapter]
  puts "Width adapters: [llength $wAdap] "
  puts "Clock adapters: [llength $cAdap] "
  puts "Rate  adapters: [llength $rAdap] "
  puts "Pipe  adapters: [llength $pAdap] "

  _prtDataWidths2 $wAdap
  _prtDataWidths2 $cAdap
  _prtDataWidths2 $rAdap
  _prtDataWidths2 $pAdap
}

proc Project::getDataNetworks { } {
  set dataNetworks [list ]
  set chip [Project::get_chip]
  set ts   [Project::get_topology]
  set networks [get_objects -parent $ts -type network]
  foreach netw $networks {
    set isData "false"
    if {[string compare [Project::abbrev $netw] "dn"] == 0} {
      set isData "true"
    }
    if {[string compare [Project::abbrev $netw] "sdn"] == 0} {
      set isData "true"
    }
    if {[string compare [Project::abbrev $netw] "mdn"] == 0} {
      set isData "true"
    }
    # set isData [query_object -object $netw -type dn]
    # puts "Project::getDataNetworks: $isData $netw"
    if {$isData == "true"} {
      lappend dataNetworks $netw
    }
  }
  return $dataNetworks
}

proc Project::getNetworkName {netwAbbr} {
  set network ""
  set chip [Project::get_chip]
  set ts   [Project::get_topology]
  set networks [get_objects -parent $ts -type network]
  foreach netw $networks {
    if {[string compare [Project::abbrev $netw] $netwAbbr] == 0} {
      set network $netw
    }
  }
  return $network
}

proc Project::getCsrRequestNetwork { } {
  set chip [Project::get_chip]
  set ts   [Project::get_topology]
  set networks [get_objects -parent $ts -type network]
  foreach netw $networks {
    set isRequ [query_object -object $netw -type csr_request]
    # puts "Project::getCsrRequestNetwork: $isRequ $netw"
    if {$isRequ == "true"} {
      return $netw
    }
  }
  return ""
}

proc Project::getCsrResponseNetwork { } {
  set chip [Project::get_chip]
  set ts   [Project::get_topology]
  set networks [get_objects -parent $ts -type network]
  foreach netw $networks {
    set isResp [query_object -object $netw -type csr_response]
    # puts "Project::getCsrResponseNetwork: $isResp $netw"
    if {$isResp == "true"} {
      return $netw
    }
  }
  return ""
}

proc Project::createNcoreUnits { chipSocketDict clk} {
  set caiuSk [dict get $chipSocketDict CAIU]
  puts "CAIU: [llength $caiuSk]"
  Caiu::create $caiuSk $clk

  set ncaiuSk [dict get $chipSocketDict IOAIU]
  puts "IOAIU: [llength $ncaiuSk]"
  Ncaiu::create $ncaiuSk $clk

  set dmiSk [dict get $chipSocketDict DMI]
  puts "DMI: [llength $dmiSk]"
  Dmi::create $dmiSk $clk

  set diiSk [dict get $chipSocketDict DII]
  puts "DII: [llength $diiSk]"
  Dii::create $diiSk $clk
}


proc Project::print_unit_summary { verbose } {
  set chip [Project::get_chip]
  set ts   [Project::get_topology]
  set unitSummaryDict [dict create ]
  set caius   [get_objects -parent $ts -type caiu]
  set ncaius  [get_objects -parent $ts -type ncaiu]
  set dmis    [get_objects -parent $ts -type dmi]
  set diis    [get_objects -parent $ts -type dii]
  set dces    [get_objects -parent $ts -type dce]
  set dves    [get_objects -parent $ts -type dve]
  set grbs    [get_objects -parent $ts -type grb]
  set sysDiis [get_objects -parent $ts -type dii -subtype sys_dii]
  set atus    [get_objects -parent $ts -type atu]
  set widAds  [get_objects -parent $ts -type width_adapter]
  set clkAds  [get_objects -parent $ts -type clock_adapter]
  set sockets [get_objects -parent $ts -type socket]
  dict append unitSummaryDict caiu    [llength $caius ]
  dict append unitSummaryDict ncaiu   [llength $ncaius ]
  dict append unitSummaryDict dmi     [llength $dmis ]
  dict append unitSummaryDict dii     [llength $diis ]
  dict append unitSummaryDict dce     [llength $dces ]
  dict append unitSummaryDict dve     [llength $dves ]
  dict append unitSummaryDict grb     [llength $grbs ]
  dict append unitSummaryDict sys_dii [llength $sysDiis ]
  dict append unitSummaryDict apb_atu [llength $atus ]
  dict append unitSummaryDict widthAd [llength $widAds ]
  dict append unitSummaryDict clockAd [llength $clkAds ]
  dict append unitSummaryDict socket  [llength $sockets ]

  if {$verbose == 1} {
    foreach kee [dict keys $unitSummaryDict] {
      puts "$kee: [dict get $unitSummaryDict $kee]"
    }
  }

  return $unitSummaryDict
}

proc Project::createFlow {parent src tgt} {
  set src1 [Project::abbrev $src]
  set tgt1 [Project::abbrev $tgt]
  set name "fl_"
  append name $src1 "_" $tgt1
  # puts "Creating flow name: $name"
  set flow1 [create_object -type flow -parent $parent -name $name]
  set attr  [list "source" $src "target" $tgt]
  update_object -name $flow1 -value_list $attr
  return $flow1
}

proc Project::createAllFlows { units } {
  # set parent [get_objects -parent root -type chip]
  set parent [Project::get_subsystem]
  puts "Creating flows on $parent"
  set n [llength $units]
  for {set i 0} {$i < $n} {incr i} {
    set src [lindex $units $i]
    set i1 [expr $i + 1]
    for {set j $i1} {$j < $n} {incr j} {
      set tgt [lindex $units $j]
      createFlow $parent $src $tgt
    }
  }
}

proc Project::create_interrupts_and_csr_networks {interrupt_clock csr_clock  sysDiiLoc} {
  set chip [get_objects -parent root -type chip]
  # set ts   [get_objects -parent $chip -type topology]
  set ts   [Project::get_topology]
  
  run_generator -topology $ts -clock $interrupt_clock -name interrupt 

  create_configuration_units -topology $ts -clock $csr_clock 
  connect_request_csr_network -topology $ts -clock $csr_clock
  connect_response_csr_network -topology $ts -clock $csr_clock

  set sysDii   [get_objects -parent $ts -type dii -subtype configDii]
  set_node_position -object $sysDii -x [lindex $sysDiiLoc 0] -y [lindex $sysDiiLoc 1]

  Ts::set_maxPacketLength 1
}

proc Project::create_flow { parent source target name } {
  puts "---------Creating Flow $name ----------"
  set flow [create_object -name $name -parent $parent -type flow]
  set_attribute -object $flow -name flowType -value RD
  set_attribute -object $flow -name flowQoS  -value BANDWIDTH_SENSITIVE
  update_object -name $flow -type "source" -bind $source
  update_object -name $flow -type "destination"  -bind $target
  return $flow
}

proc Project::get_request_response_networks { topology } {
  set req_network_num 0
  set rsp_network_num 0
  set i 1001
  set req_network ""
  set rsp_network ""
  set networks [get_objects -parent $topology -type network]
  foreach netw $networks {
    set typ [query_object -object $netw -type network_type]
    if {[string compare $typ "request"] == 0} {
      set req_network $netw
      set req_network_num $i
    } elseif {[string compare $typ "response"] == 0} {
      set rsp_network $netw
      set rsp_network_num $i
    }
    incr i
  }
  puts "req_network = $req_network : $req_network_num"
  puts "rsp_network = $rsp_network : $rsp_network_num"
  set networks [list $req_network $req_network_num $rsp_network $rsp_network_num]
  return $networks
}

proc Project::create_unit { name model parent clock } {
  puts "---------Creating unit with name $name of type $model----------"
  set_context -name $parent
  set state [query_object -type userName -object $parent/$name]
  if {$state == ""} {
    set obj [create_object -name $name -type $model -parent $parent]
    update_object -name $obj -bind $clock -type "domain"
    return $obj
  }
  return $parent/$name
}

package provide Project $Project::version
package require Tcl 8.5
