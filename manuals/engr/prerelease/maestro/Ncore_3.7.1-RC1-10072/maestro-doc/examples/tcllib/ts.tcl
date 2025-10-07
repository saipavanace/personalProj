# *********************************************************************************************
#
# This script provides procedures to set system parameters 
# 
# *********************************************************************************************
package require Safety 2.0

namespace eval Ts {
  namespace export set_assertOn
  namespace export set_wSecurityAttribute
  namespace export set_useCsrProgrammedAddrRangeInfo
  namespace export set_wAuxPerDW
  namespace export set_wNdpAux
  namespace export set_useResiliency
  namespace export set_nativeIntfProtectionEnable
  namespace export set_TIResiliencyProtectionType
  namespace export set_MemProtectionType
  namespace export set_enableUnitDuplication
  namespace export set_resilienceDisablePinPresent
  namespace export set_InterUnitDelay
  namespace export set_nGPRA
  namespace export set_packetSize
  namespace export set_priorityCount
  namespace export set_maxPacketLength
  namespace export set_DCE_SecondarySelBits
  namespace export set_nDvmCmdCredits
  namespace export set_nDvmSnpCredits
  namespace export set_enableTimeOutRef
  namespace export set_enableTimeOutThreshold
  namespace export set_nMainTraceBufSize
  namespace export set_nTraceRegisters

  namespace export get_assertOn
  namespace export get_useCsrProgrammedAddrRangeInfo
  namespace export get_useResiliency
  namespace export get_nativeIntfProtectionEnable
  namespace export get_TIResiliencyProtectionType
  namespace export get_MemProtectionType
  namespace export get_enableUnitDuplication
  namespace export get_resilienceDisablePinPresent
  namespace export get_nGPRA
  namespace export get_packetSize
  namespace export get_priorityCount
  namespace export get_maxPacketLength

  namespace export set_unit_attribute
  namespace export get_unit_attribute
  namespace export number_of_units
  namespace export get_all_units
  namespace export get_unit
  namespace export set_clock
  namespace export get_clock
  namespace export test
  namespace export set_interconnect_clock
  namespace export get_interconnect_clock
  namespace export addPipeAdapterBetweenSwitches
  namespace export auto_create_node_positions

  set version 2.0
  set Description "Maestro_Ts"

  variable home [file join [pwd] [file dirname [info script]]]
  variable created_units [list]
  variable interconnect_clock ""
}

proc _getTopology {} {
  set chip     [get_objects -type chip -parent root]
  set system   [get_objects -type system -parent $chip]
  set subsystem [get_objects -type subsystem -parent $system]
  set topology [get_objects -type topology -parent $subsystem]
  return $topology
}

proc Ts::set_resilienceDisablePinPresent { val} {
  set [Safety::set_resilienceDisablePinPresent $val]
}

proc Ts::auto_create_node_positions {routingTemplate} {
  # set routing_template mesh ; # valid values: manual, mesh, torus, butterfly, full_crossbar (single switch)
  # puts "Ts::auto_create_node_positions $routingTemplate"
  if {($routingTemplate == "mesh") ||
      ($routingTemplate == "torus")} {
    set mesh [MeshGenerator::create_mesh_locs]
    return [list meshx $mesh meshy $mesh]
  } elseif {($routingTemplate == "ring") ||
            ($routingTemplate == "doubleC")} {
    set mesh [RingGenerator::create_mesh_locs]
    return [list meshx $mesh meshy 1]
  } elseif {$routingTemplate == "butterfly"} {
    set mesh [MeshGenerator::create_butterfly_locs]
    return [list meshx [lindex $mesh 0] meshy [lindex $mesh 1] ]
  } elseif {$routingTemplate == "manual"} {
    set chip [get_objects -parent root -type chip]
    set topology [get_objects -parent $chip -type topology]
    set mesh [MeshGenerator::getMeshSize $chip $topology ]
    return [list meshx [lindex $mesh 0] meshy [lindex $mesh 1] ]
  }
  return [list ]
}

proc Ts::set_assertOn { val} {
  set obj [_getTopology]
  set attrKey assertionsEnabled
  set_attribute -object $obj -name $attrKey -value $val
}

proc Ts::set_wSecurityAttribute { val} {
	puts "Error: wSecurityAttribute is always set to true for Ncore 3.0 release. Please do not invoke this command as it will soon be deprecated."
}

proc Ts::set_useCsrProgrammedAddrRangeInfo { val} {
  set obj [_getTopology]
  set attrKey useFixedAddressMap
  set_attribute -object $obj -name $attrKey -value $val
}

# ***********************************************************************************************************
#
# Description:   Sets the value for the parameter "Number of DVM command request credits".
#                The internal parameter name is "nDvmCmdCredits".
# Argument:      The value for the parameter "nDvmCmdCredits".
# Example usage: Ts::set_nDvmCmdCredits 2
#
# ************************************************************************************************************
proc Ts::set_nDvmCmdCredits { val } {
  set obj [_getTopology]
  set attrKey nDvmCmdCredits 
  set_attribute -object $obj -name $attrKey -value $val
}

# ***********************************************************************************************************
#
# Description:   Sets the value for the parameter "Number of DVM snoop request credits".
#                The internal parameter name is "nDvmSnpCredits".
# Argument:      The value for the parameter "nDvmSnpCredits".
# Example usage: Ts::set_nDvmSnpCredits 2
#
# ************************************************************************************************************
proc Ts::set_nDvmSnpCredits { val } {
  puts "WARNING: Ts::set_nDvmSnpCredits became derived parameter and now is deprecated"
}

# ***********************************************************************************************************
#
# Description:   Sets the value for the parameter "Enable external reference for time out".
#                The internal parameter name is "timeOutRefEnabled".
# Argument:      The value for the parameter "timeOutRefEnabled".
# Example usage: Ts::set_enableTimeOutRef true
#
# ************************************************************************************************************
proc Ts::set_enableTimeOutRef { val } {
  set obj [_getTopology]
  set attrKey timeOutRefEnabled
  set_attribute -object $obj -name $attrKey -value $val
}

# ***********************************************************************************************************
#
# Description:   Sets the value for the parameter "TimeOut threshold".
#                The internal parameter name is "timeOutThreshold".
# Argument:      The value for the parameter "timeOutThreshold".
# Example usage: Ts::set_timeOutThreshold 1000
#
# ************************************************************************************************************
proc Ts::set_timeOutThreshold { val } {
  set obj [_getTopology]
  set attrKey timeOutThreshold
  set_attribute -object $obj -name $attrKey -value $val
}

# ***********************************************************************************************************
#
# Description:   Sets the value for the parameter "Resilience". Enables resiliency related features.
#                The internal parameter name is "resilienceEnabled".
# Argument:      The value for the parameter "resilienceEnabled".
# Example usage: Ts::set_useResiliency 2
#
# ************************************************************************************************************
proc Ts::set_useResiliency { val} {
  puts "WARNING: Ts::set_use_Resiliency has to be replaced by Safety::set_safetyConfig. Setting resiliency via the solution has now been moved to the safety configuration object. In the future, this function will be deprecated"
}

# ***********************************************************************************************************
#
# Description:   Sets the value for the parameter "Native Interface Protection".
#                The internal parameter name is "nativeIntfProtEnabled".
# Argument:      The value for the parameter "nativeIntfProtEnabled".
# Example usage: Ts::set_nativeIntfProtectionEnable NONE
#
# ************************************************************************************************************
proc Ts::set_nativeIntfProtectionEnable { val} {
  set obj [_getTopology]
  set attrKey nativeIntfProtEnabled
  set_attribute -object $obj -name $attrKey -value $val
}

proc Ts::set_TIResiliencyProtectionType { val} {
  puts "WARNING: Ts::set_TIResiliencyProtectionType has been replaced by Safety::set_TIResiliencyProtectionType. Setting resiliency protection type via the solution has now been moved to the safety configuration object. In the future, this function will be deprecated"
}

# ***********************************************************************************************************
#
# Description:   Sets the value for the parameter "Memory Protection".
#                The internal parameter name is "memoryProtectionType".
# Argument:      The value for the parameter "memoryProtectionType".
# Example usage: Ts::set_MemProtectionType SECDED
#
# ************************************************************************************************************
proc Ts::set_MemProtectionType { val} {
  puts "WARNING: Ts::set_MemProtectionType has been replaced by Safety::set_MemProtectionType. Setting memory protection via the solution has now been moved to the safety configuration object. In the future, this function will be deprecated"
}

proc Ts::set_enableUnitDuplication { val} {
  puts "WARNING: Ts::set_enableUnitDuplication is no longer used. If you need to enable Unit duplication, use Safety::set_safetyConfig ASIL_B. Setting duplication via the solution has now been moved to the safety configuration object. In the future, this function will be deprecated"
}

proc Ts::set_InterUnitDelay { val } {
  set obj [_getTopology]
  set attrKey interUnitDelay
  set_attribute -object $obj -name $attrKey -value $val
}

# ***********************************************************************************************************
#
# Description:   Sets the value for the parameter "General Purpose Address regions".
#                The internal parameter name is "nGPRA".
# Argument:      The value for the parameter "nGPRA".
# Example usage: Ts::set_nGPRA 6
#
# ************************************************************************************************************
proc Ts::set_nGPRA { val} {
  set obj [_getTopology]
  set attrKey nGPRA
  set_attribute -object $obj -name $attrKey -value $val
}

proc Ts::set_packetSize { val} {
}

proc Ts::set_priorityCount { val} {
  if {[info exists ::_skip_depreciated_] && ($::_skip_depreciated_ == 1)} {return}
  puts "WARNING: Ts::set_priorityCount has been deprecated and should be removed. PriorityCount is not user settable in Ncore and is fixed to 8 when qos is enabled and 1 otherwise."
  #set topology [_getTopology]
  #set attrKey priorityCount

  #set networks [get_objects -parent $topology -type network]
  #foreach netw $networks {
  #  set isResp [query_object -object $netw -type "csr_response"]
  #  set isReq  [query_object -object $netw -type "csr_request"]
  #  if {$isResp != "true" && $isReq != "true"} {
  #    set_attribute -object $netw -name $attrKey -value $val
  #  }
  #}
}

proc Ts::set_maxPacketLength { val} {
  puts "WARNING: Ts::set_maxPacketLength is not user-settable. The default value is set to 1."
  # TODO Allan: This API is just added for Ncore. We need to rewrite this API to handle Symphony for per network setting case
  # set topology [_getTopology]
  # set attrKey maxPacketLength

  #set networks [get_objects -parent $topology -type network]
  #foreach netw $networks {
  #  set isResp [query_object -object $netw -type "csr_response"]
  #  set isReq  [query_object -object $netw -type "csr_request"]
  #  if {$isResp == "true" || $isReq == "true"} {
  #    set_attribute -object $netw -name $attrKey -value 4
  #  } else {
  #    set_attribute -object $netw -name $attrKey -value $val
  #  }
  # }
}

proc Ts::set_boot_regionBaseAddr { val } {
  BootRegion::set_baseAddress $val
}

proc Ts::set_boot_regionSize { val } {
  BootRegion::set_memorySize $val
}

proc Ts::set_boot_regionHut { val } {
  BootRegion::set_Home_Unit_Type $val
}

proc Ts::set_boot_regionHui { val } {
  BootRegion::set_Home_Unit_Identifier $val
}

proc Ts::set_DCE_SecondarySelBits { val } {
  puts "WARNING: Ts::set_DCE_SecondarySelBits is deprecated and should be removed. The secondary bits for DCE are not considered."
}

proc Ts::get_assertOn { {obj ""} } {
  if {$obj == ""} {
    set obj [_getTopology]
  }
  set attrKey assertionsEnabled
  set v [get_parameter -object $obj -name $attrKey]
  return $v
}


proc Ts::get_useResiliency { {obj ""} } {
  puts "WARNING: Ts::get_useResiliency has been replaced by Safety::get_useResiliency. Getting resiliency via the Transportsolution has now been moved to the safety configuration object. In the future, this function will be deprecated"
  Safety::get_useResiliency
}

proc Ts::get_useCsrProgrammedAddrRangeInfo { {obj ""} } {
  if {$obj == ""} {
    set obj [_getTopology]
  }
  set attrKey useFixedAddressMap
  set v [get_parameter -object $obj -name $attrKey]
  return $v
}

proc Ts::get_useResiliency { {obj ""} } {
  if {$obj == ""} {
    set obj [_getTopology]
  }
  set attrKey resilienceEnabled
  set v [get_parameter -object $obj -name $attrKey]
  if {$v == "true"} {
    return "true"
  }
  return "false"
}

proc Ts::get_nativeIntfProtectionEnable { {obj ""} } {
  if {$obj == ""} {
    set obj [_getTopology]
  }
  set attrKey nativeIntfProtEnabled
  set v [get_parameter -object $obj -name $attrKey]
  return $v
}


proc Ts::get_TIResiliencyProtectionType { {obj ""} } {
  puts "WARNING: Ts::TIResiliencyProtectionType has been replaced by Safety::get_TIResiliencyProtectionType. Getting resiliency protection type via the solution has now been moved to the safety configuration object. In the future, this function will be deprecated"
  Safety::get_TIResiliencyProtectionType
}

proc Ts::get_MemProtectionType { {obj ""} } {
  puts "WARNING: Ts::get_MemProtectionType has been replaced by Safety::get_MemProtectionType. Getting memory protection via the solution has now been moved to the safety configuration object. In the future, this function will be deprecated"
  Safety::get_MemProtectionType
}

proc Ts::get_enableUnitDuplication { {obj ""} } {
  puts "WARNING: Safety::get_MemProtectionType has been replaced by Safety::get_enableUnitDuplication. Getting duplication via the solution has now been moved to the safety configuration object. In the future, this function will be deprecated"
  Safety::get_enableUnitDuplication
}

proc Ts::get_resilienceDisablePinPresent { } {
  return [Safety::get_resilienceDisablePinPresent]
}

proc Ts::get_nGPRA { {obj ""} } {
  if {$obj == ""} {
    set obj [_getTopology]
  }
  set attrKey nGPRA
  set v [get_parameter -object $obj -name $attrKey]
  return $v
}

proc Ts::set_nMainTraceBufSize { val} {
  set obj [_getTopology]
  set attrKey nMainTraceBufSize
  set_attribute -object $obj -name $attrKey -value $val
}

proc Ts::set_nTraceRegisters { val} {
  set obj [_getTopology]
  set attrKey nTraceRegisters
  set_attribute -object $obj -name $attrKey -value $val
}

proc Ts::set_unit_attribute { ind procFunc value } {
  set unit [lindex $Ts::created_units $ind]
  set x [$procFunc $unit $value]
}

proc Ts::get_unit_attribute { ind procFunc } {
  set unit [lindex $Ts::created_units $ind]
  set val [$procFunc $unit]
  return $val
}

proc Ts::number_of_units { } {
  set val [llength $Ts::created_units]
  return $val
}

proc Ts::get_unit { indx } {
  if {$indx < 0 || $indx >= [llength $Ts::created_units]} {
    return ""
  }
  set val [lindex $Ts::created_units $indx]
  return $val
}

proc Ts::set_clock { indx clk } {
  if {$indx < 0 || $indx >= [llength $Ts::created_units]} {
    return
  }
  set unit [lindex $Ts::created_units $indx]
  update_object -name $unit -bind $clk -type "domain"
}

proc Ts::get_clock { indx } {
  if {$indx < 0 || $indx >= [llength $Ts::created_units]} {
    return
  }
  set unit [lindex $Ts::created_units $indx]
  set clk [get_objects -parent $unit -type clock_subdomain]
  return $clk
}

proc Ts::get_all_units { } {
  return $Ts::created_units
}

proc Ts::set_interconnect_clock { clk } {
  set Ts::interconnect_clock $clk
}

proc Ts::get_interconnect_clock { } {
  return $Ts::interconnect_clock
}

proc Ts::addPipeAdapterBetweenSwitches {switches clk netw} {
  set pipeDepth  2
  set pipeSimple true
  # puts "network=$netw"
  set unitParent $netw
  foreach sw $switches {
    set outPorts [get_objects -parent $sw -type packet_port -subtype out]
    foreach pp $outPorts {
      set linkSeg  [get_objects -parent $pp -type link_segment]
      set linkPorts [get_objects -parent $linkSeg -type packet_port]
      set upPort   [lindex $linkPorts 0]
      set upObj    [get_objects  -parent $upPort -type parent]
      set upObjTyp [query_object -object $upObj  -type type]

      set dnPort   [lindex $linkPorts 1]
      set dnObj    [get_objects -parent $dnPort -type parent]
      set dnObjTyp [query_object -object $dnObj -type type]
      set dnWid    [get_parameter -object $dnPort -name dataWidth]
      set upWid    [get_parameter -object $upPort -name dataWidth]
      # puts "UP:$upPort DN:$dnPort ($dnObjTyp)"
      if {$dnObjTyp == "Switch"} {
        set nam "pAdapter_"
        append nam [Project::abbrev $pp]
        set pipe [insert_adapter -port $pp -type pipe_adapter -name $nam]
        set_attribute -object $pipe -name depth      -value $pipeDepth
        # set_attribute -object $pipe -name simplePipe -value $pipeSimple
        update_object -name $pipe -bind $clk -type "domain"
        set widPPin  [get_objects -parent $pipe -type packet_port -subtype in]
        set widPPout [get_objects -parent $pipe -type packet_port -subtype out]
        set_attribute -object $widPPin  -name dataWidth -value $dnWid
        set_attribute -object $widPPout -name dataWidth -value $upWid
        # puts "Adding Pipe: $pp $pipe $dnPort"
      }
    }
  }
}

package provide Ts $Ts::version
package require Tcl 8.5
