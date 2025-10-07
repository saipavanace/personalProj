namespace eval Symphony {
  namespace export create_sockets
  namespace export create_clock
  namespace export create_unit
  namespace export set_nc_params
  namespace export set_apb_atu_params
  namespace export set_axi_atu_params
  namespace export set_atu_params
  namespace export set_clock_adapter_params
  namespace export set_pipe_params
  namespace export set_dw_params
  namespace export set_atu_pam
  namespace export baseName

  namespace export create_clock_adapter

  set version 2.0
  set Description "Maestro_Symphony"
  variable home [file join [pwd] [file dirname [info script]]]
}

proc Symphony::baseName { nam } {
  return [lindex [split $nam "/"] end]
}

#-------------------Creating Sockets-----------------------------
proc Symphony::create_sockets { system atus clock direction function config } {
  puts "---------Creating Sockets CONFIG is ------ $config"
  set addr [lindex $config 0]
  set i 1

  foreach atu $atus {
    puts "---------Creating Socket ------ atu = $atu"
    set type [lindex $config $i]
    incr i
    set data [lindex $config $i]
    puts "invoking - create_socket $system $atu $clock $type $direction $function $data 32 4"
    Project::create_socket $system $atu $clock $type $direction $function $data 32 4  
    incr i
  }
}

proc Symphony::create_clock {chip region domain subdomain frequency} {
  puts "---------Creating clock with name $region/$domain/$subdomain----------"
  set clkRegion $chip/$region
  set state [query_object -type userName -object $chip/$region]
  if {$state == ""} {
    set clkRegion [create_object -name $region -type clock_region -parent $chip]
    set_attribute -object $clkRegion -name frequency -value $frequency
    update_object -name $clkRegion -bind "$chip/PwrRegion" -type "powerRegion"
  }
  set clkDomain $clkRegion/$domain
  set state [query_object -type userName -object $clkRegion/$domain]
  if {$state == ""} {
    set clkDomain [create_object -name $domain -type clock_domain -parent $clkRegion]
    update_object -name $clkDomain -bind "$chip/PwrRegion/PwrDomain" -type "powerDomain"
  }
  set clkSubdomain $clkDomain/$subdomain
  set state [query_object -type userName -object $clkDomain/$subdomain]
  if {$state == ""} {
    set clkSubdomain [create_object -name $subdomain -type clock_subdomain -parent $clkDomain]
  }
  return $clkSubdomain
}

proc Symphony::create_unit { name model parent clock } {
  puts "---------Creating unit with name $name of type $model----------"
  set_context -name $parent
  set state [query_object -type userName -object $parent/$name]
  if {$state == ""} {
    set obj [create_object -name $name -type $model -parent $parent]
    update_object -name $obj -bind $clock -type "domain"
  }
  return $parent/$name
}

proc Symphony::create_clock_adapter { name parent inclock outclock } {
  puts "---------Creating clock adapter with name $name----------"
  set obj [create_object -name $name -type clock_adapter -parent $parent]
  update_object -name $obj -value_list [list inclock $inclock outclock $outclock]
  return $parent/$name
}

proc Symphony::set_nc_params { name parent width_in width_out } {
  puts "------------Setting parameters for $name---------------"
  set ports [get_objects -parent $parent -type packet_port -subtype in]
  foreach port $ports {
    set_attribute -object $port -name dataWidth -value $width_in
  }
  set ports [get_objects -parent $parent -type packet_port -subtype out]
  foreach port $ports {
    set_attribute -object $port -name dataWidth -value $width_out
  }
}

proc Symphony::set_apb_atu_params { name obj } {
  set_attribute -object $obj -name pipeLevelSmi -value 0
  set_attribute -object $obj -name pipeLevelAtp -value 2
  set_attribute -object $obj -name pipeLevelApb -value 1
  set_attribute -object $obj -name maxPduSz -value 4096
  set_attribute -object $obj -name ctlPipeReq -value 1
  set_attribute -object $obj -name ctlPipeResp -value 1
  set_attribute -object $obj -name fixedSupported -value false
  set_attribute -object $obj -name incrSupported -value false
  set_attribute -object $obj -name wrapSupported -value false
  #set_attribute -object $obj -name narrowSupported -value false
  set_attribute -object $obj -name widthAdaptionSupported -value true
  set_attribute -object $obj -name readInterleaveSupported -value true
  set_attribute -object $obj -name ctlPipeCtxt -value 0
  set_attribute -object $obj -name numPri -value 2
  set_attribute -object $obj -name pktArbType -value arb_rr1
  set_attribute -object $obj -name depktArbType -value arb_rr1
  set_attribute -object $obj -name pktArbWeights -value_list [list 1]
  set_attribute -object $obj -name depktArbWeights -value_list [list 1]
  set_attribute -object $obj -name idCompMask -value_list [list false]
  set_attribute -object $obj -name enPathLookup -value true
  set d [get_parameter -object $obj -name interfaces/apbInterface/direction]
  if { $d == "master" } { return }
  set_attribute -object $obj -name enBufWrite -value false
  set_attribute -object $obj -name enPathLookup -value false
  set_attribute -object $obj -name enSplitting -value false
  return $obj
}

proc Symphony::set_axi_atu_params { name obj pendingTransactions } {
  puts "set_axi_atu_params $name $obj $pendingTransactions"
  set_attribute -object $obj -name pipeLevelAtp -value 2
  set_attribute -object $obj -name maxPduSz -value 4096
  set_attribute -object $obj -name maxOutRd -value $pendingTransactions
  set_attribute -object $obj -name maxOutWr -value $pendingTransactions
  set_attribute -object $obj -name maxOutTotal -value $pendingTransactions
  set_attribute -object $obj -name nativeType -value axi4
  set_attribute -object $obj -name axiWrEn -value true
  set_attribute -object $obj -name axiRdEn -value true
  set_attribute -object $obj -name axiPipeR -value 1
  set_attribute -object $obj -name axiPipeB -value 1
  set_attribute -object $obj -name axiPipeW -value 1
  set_attribute -object $obj -name ctlPipeReq -value 0
  set_attribute -object $obj -name ctlPipeResp -value 0
  set_attribute -object $obj -name fixedSupported -value true
  set_attribute -object $obj -name incrSupported -value true
  set_attribute -object $obj -name wrapSupported -value true
  #set_attribute -object $obj -name narrowSupported -value true
  set_attribute -object $obj -name readInterleaveSupported -value true
  set_attribute -object $obj -name widthAdaptionSupported -value true
  set_attribute -object $obj -name qosMapMode -value 0
  set_attribute -object $obj -name crdMngrEn -value false
  set_attribute -object $obj -name crdDataUnit -value 1
  set_attribute -object $obj -name timeoutErrChk -value false
  set_attribute -object $obj -name timeoutErrCount -value 0
  set_attribute -object $obj -name ctlPipeCtxt -value 0
  set_attribute -object $obj -name numPri -value 2
  set_attribute -object $obj -name pktArbType -value arb_rr1
  set_attribute -object $obj -name depktArbType -value arb_rr1
  set_attribute -object $obj -name pktArbWeights -value_list [list 1]
  set_attribute -object $obj -name depktArbWeights -value_list [list 1]
  set_attribute -object $obj -name smiPktweights -value_list [list 1]
  set_attribute -object $obj -name smiDpkweights -value_list [list 1]
  set_attribute -object $obj -name queueDepth -value 0
  set_attribute -object $obj -name axiPipeAw -value 1
  set_attribute -object $obj -name axiPipeAr -value 1
  set_attribute -object $obj -name enPathLookup -value true
  set d [get_parameter -object $obj -name interfaces/axiInterface/direction]
  if { $d == "master" } { 
   set_attribute -object $obj -name pipeLevelSmi -value 0
   set_attribute -object $obj -name stateProtectionStyle/protection -value none
   set_attribute -object $obj -name stateProtectionStyle/scrub -value false
   set_attribute -object $obj -name stateProtectionStyle/useCorrected -value false
   set_attribute -object $obj -name stateProtectionStyle/protWidth -value 1
   set_attribute -object $obj -name registerProtectionStyle/protection -value none
   set_attribute -object $obj -name registerProtectionStyle/scrub -value false
   set_attribute -object $obj -name registerProtectionStyle/useCorrected -value false
   set_attribute -object $obj -name registerProtectionStyle/protWidth -value 1
   set_attribute -object $obj -name memoryProtectionStyle/protection -value none
   set_attribute -object $obj -name memoryProtectionStyle/scrub -value false
   set_attribute -object $obj -name memoryProtectionStyle/useCorrected -value false
   set_attribute -object $obj -name memoryProtectionStyle/protWidth -value 1
   return 
  }
  set_attribute -object $obj -name pipeLevel -value 0
  set_attribute -object $obj -name enPathLookup -value false
  set_attribute -object $obj -name beatBufferEntries -value 1
  set_attribute -object $obj -name enSplitting -value true
  #set_attribute -object $obj -name narrowSupported -value false
  set_attribute -object $obj -name enBufWrite -value false
  set_attribute -object $obj -name idCompMask -value_list [list false]
  set_attribute -object $obj -name pipeLevelPam -value 0
  return $obj
}

proc Symphony::set_atu_params { type name2 obj pendingTransactions } {
  set name [Symphony::baseName $obj]
  if {$type == "APB3" || $type == "APB4"} {
    set_apb_atu_params $name $obj
    puts "invoking set_apb_atu_params with pending = $pendingTransactions"
  } elseif {$type == "AXI"} {
    set_axi_atu_params $name $obj $pendingTransactions 
    puts "invoking set_axi_atu_params with pending = $pendingTransactions"
  }
}

proc Symphony::set_clock_adapter_params { name obj async depth} {
  set_attribute -object $obj -name async -value $async
  set_attribute -object $obj -name depth -value $depth
}

proc Symphony::set_pipe_params { name obj pipeForward pipeBackward depth} {
  set_attribute -object $obj -name pipeForward -value $pipeForward
  set_attribute -object $obj -name pipeBackward -value $pipeBackward
  set_attribute -object $obj -name depth -value $depth
  return $obj
}

proc Symphony::set_atu_pam { name obj idDict atuWidthDict } {
  puts "------------set_atu_pam for initiator $name---------------"
  set socket [get_objects -parent $obj -type socket]
    puts " object $obj has socket $socket "
  set pt [get_parameter -object $socket -name protocolType]
    puts " and type = $pt "
  set ids [debug_get_parameter -object $obj -name pamTid]
  set pamSz [list ]
  set pamTargWidth [list ]
  set pamTargMaxBurst [list ]
  set pamTargSplitWrap [list ]
  foreach tid $ids {
    lappend pamTargWidth [ expr [dict get $atuWidthDict [dict get $idDict $tid] ] / 8 ]
    set w  [expr [dict get $atuWidthDict [ dict get $idDict $tid]] * 2]
    if {  $w  < 4096 && $pt == "AXI4" } {
      lappend pamTargMaxBurst $w 
    } else {
      lappend pamTargMaxBurst 0 
    }
    set tw [dict get $atuWidthDict [ dict get $idDict $tid]]
    set iw [dict get $atuWidthDict $name ]
    if { $pt == "AXI4" } {
      lappend pamTargSplitWrap true 
    } else {
      lappend pamTargSplitWrap false 
    }
    lappend pamSz 4096
  }
  set_attribute -object $obj -name pamSz -value_list $pamSz
  set_attribute -object $obj -name pamTargWidth -value_list $pamTargWidth
  set_attribute -object $obj -name pamTargMaxBurst -value_list $pamTargMaxBurst
  set_attribute -object $obj -name pamTargSplitWrap -value_list $pamTargSplitWrap
  return $obj
}


package provide Symphony $Symphony::version
package require Tcl 8.5
