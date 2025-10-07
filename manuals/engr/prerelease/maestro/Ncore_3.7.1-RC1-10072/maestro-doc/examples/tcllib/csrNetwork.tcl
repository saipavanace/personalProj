package require Project 2.0
package require Apb_atu 2.0
package require Caiu    2.0
package require Ncaiu   2.0
package require Ts	2.0

namespace eval CsrNetwork {
  namespace export create_sysDII_unit2
  namespace export create_csr_networks
  namespace export create_sysDII_unit2
  namespace export set_clock
  namespace export get_clock

  set version 2.0
  set Description "Maestro_CsrNetwork"

  variable home [file join [pwd] [file dirname [info script]]]
  variable network_clock ""
}

proc CsrNetwork::create_sysDII_unit2 { clkSubdomain meshLoc} {
  set devName "sys_dii"
  set topology    [Project::get_topology]
  set unit_parent [Project::get_unit_parent]
  # set subsystem   [Project::get_subsystem]
  set skName "sk_$devName"
  set soc_sys_dii [create_object -type socket -name $skName -parent $unit_parent]

    # set_attribute -object $soc_sys_dii -name protocolType -value "AXI4"
    set_attribute -object $soc_sys_dii -value_list [list socketFunction CONFIG_INTERFACE protocolType AXI4]
    set_attribute -object $soc_sys_dii -name params/wAddr -value 24
    set_attribute -object $soc_sys_dii -name params/wUser -value 0
    set_attribute -object $soc_sys_dii -name params/wArId -value 4
    set_attribute -object $soc_sys_dii -name params/wAwId -value 4
    set_attribute -object $soc_sys_dii -name params/wData -value 32
    set_attribute -object $soc_sys_dii -name params/wQos  -value 0

  # create Ncore sys DII
  set sys_dii     [create_object -type DII -parent $topology -name $devName]
  update_object -name $sys_dii -bind $clkSubdomain -type "domain"
  set dataNetw    [Project::getDataNetworks]

  set packetPorts [get_objects -parent $sys_dii -type packet_port]
  foreach pp $packetPorts {
    set netw [get_objects -parent $pp -type network]
    foreach dNet $dataNetw {
      if { [string compare $netw $dNet] == 0} {
        set_attribute -object $pp -name dataWidth -value 64
     }
    }
  }
  
  set parnt [get_objects -parent $sys_dii -type parent]
  set parntPP [get_objects -parent $parnt -type packet_port]
  foreach pp $parntPP {
    set netw [get_objects -parent $pp -type network]
    foreach dNet $dataNetw {
      if { [string compare $netw $dNet] == 0} {
        set_attribute -object $pp -name dataWidth -value 64
     }
    }
  }

  set_node_position -object $sys_dii     -x [lindex $meshLoc 0] -y [lindex $meshLoc 1]
  set_attribute -object $sys_dii -name configurationDII -value true
  # puts "++++ >>>> MeshLoc $sys_dii ([lindex $meshLoc 0] , [lindex $meshLoc 1])"
  set vals [get_node_position -object $sys_dii]
  if {[llength $vals] > 0} {
    set xloc [lindex $vals 0]
    set yloc [lindex $vals 1]
  } else {
    set xloc [query_custom_attribute -object $sys_dii -name meshx]
    set yloc [query_custom_attribute -object $sys_dii -name meshy]
  }
  # puts "++++ >>>>         $sys_dii  $xloc , $yloc"

  set pUser [Project::get_powerUser]
  Project::set_powerUser 1
  set soc_sys_dii [create_object -type socket -parent $chip -name sock_sys_dii]
  Project::set_powerUser $pUser
    set_attribute -object $soc_sys_dii -name protocolType -value "AXI4"
    set_attribute -object $soc_sys_dii -name params/wAddr -value 24
    set_attribute -object $soc_sys_dii -name params/wUser -value 0
    set_attribute -object $soc_sys_dii -name params/wArId -value 4
    set_attribute -object $soc_sys_dii -name params/wAwId -value 4
    set_attribute -object $soc_sys_dii -name params/wData -value 32
    set_attribute -object $soc_sys_dii -name params/wQos -value 0

    set_attribute -object $soc_sys_dii -value_list [list socketFunction INITIATOR protocolType AXI4]
  update_object -name $sys_dii -bind $soc_sys_dii


  # set grbUnit [create_object -type grb -name $grbName -parent $topology]
  # set_node_position -object $grbUnit -x [lindex $meshLoc 0] -y [lindex $meshLoc 1]
  # update_object -name $grbUnit -bind $clkSubdomain -type "domain"

  # set unit_type  [query_object -object $sys_dii_AXI -type type]
  # puts "sys_dii_AXI: $sys_dii_AXI type: $unit_type"
  # set owner      [get_objects  -parent $sys_dii_AXI -type parent]
  # puts "sys_dii_AXI parent: $owner"
  # set owner_type [query_object -object $owner       -type type]
  # puts "SYS_DII_AXI :: $sys_dii_AXI ($unit_type) parent= $owner ($owner_type)"

  set sys_dii_list [list $sys_dii $sys_dii_ATU $soc_sys_dii $sys_dii_AXI]
  return $sys_dii_list
}

proc createNcoreUnitATU { soc_sys_dii clkSubdomain } {
  set chip [Project::get_chip]
  set CreateUnits [dict create]
  dict append CreateUnits "caiu"  [Caiu::get_all_units]
  dict append CreateUnits "ncaiu" [Ncaiu::get_all_units]
  dict append CreateUnits "dmi"   [Dmi::get_all_units]
  dict append CreateUnits "dii"   [Dii::get_all_units]
  dict append CreateUnits "dce"   [Dce::get_all_units]
  dict append CreateUnits "dve"   [Dve::get_all_units]

  set pUser [Project::get_powerUser]
  Project::set_powerUser 1
  set atuList [list]
  foreach typ [dict keys $CreateUnits] {
    set units [dict get $CreateUnits $typ]
    puts "ATU create: $typ N=[llength $units]"
    foreach unit $units {
      set pos [string last "/" $unit]
      set shortName [string range $unit $pos+1 end]
      set configFlow "confFlow_confDII_$shortName"
      set flow    [create_object -type flow -parent [Project::get_subsystem] -name $configFlow]

      set unitClk [get_objects -parent $unit -type clock_subdomain]
      set atu [create_ATU1 $unit ]; # atuSocket atuUnit
      lappend atuList $atu
      update_object -name $atu -bind $unitClk -type "domain"

      set atu_sock [get_objects -parent $unit -type configsocket]
      # puts "ATUcreation: UNIT=$unit ConfigSocket=$atu_sock ATU=$atu"
      set src_tgt [list $soc_sys_dii $atu_sock ]
      # puts "  FLOW $flow: src=$soc_sys_dii tgt=$atu_sock"
      update_object -name $flow -type "source" -bind $soc_sys_dii
      update_object -name $flow -type "destination" -bind $atu_sock
    }
  }
  Project::set_powerUser $pUser
  
  return $sys_dii
}

proc CsrNetwork::create_csr_networks { clocksubdomain meshLoc} {
  set chip [get_objects -parent root -type chip]
  set ts   [get_objects -parent $chip -type topology]
  # CsrNetwork::create_sysDII_unit2 $clocksubdomain $meshLoc
  create_configuration_units -topology $ts -clock $clocksubdomain 
  connect_request_csr_network -topology $ts -clock $clocksubdomain
  connect_response_csr_network -topology $ts -clock $clocksubdomain
  Ts::set_maxPacketLength 1
}

proc CsrNetwork::set_clock { clocksubdomain } {
  set CsrNetwork::network_clock $clocksubdomain
}

proc CsrNetwork::get_clock { } {
  return $CsrNetwork::network_clock
}

package provide CsrNetwork $CsrNetwork::version
package require Tcl 8.5
