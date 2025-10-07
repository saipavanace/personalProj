

namespace eval Socket {
  namespace export create
  namespace export create2
  namespace export create_socket
  namespace export create_debug_apb_socket
  namespace export set_attr
  namespace export getSocketDict
  namespace export set_wAddr
  namespace export get_wAddr
  namespace export set_wData
  namespace export get_wData
  namespace export set_eAc
  namespace export set_enableDVM
  namespace export get_eAc
  namespace export set_wArId
  namespace export get_wArId
  namespace export set_wAwId
  namespace export get_wAwId
  namespace export set_wAwUser
  namespace export set_wUser
  namespace export get_wAwUser
  namespace export set_wArUser
  namespace export get_wArUser
  namespace export set_enPoison
  namespace export get_enPoison
  namespace export set_REQ_RSVDC
  namespace export get_REQ_RSVDC
  namespace export set_NodeID_Width
  namespace export set_socketFunction
  namespace export get_socketFunction
  namespace export set_protocolType
  namespace export get_protocolType
  namespace export createNcoreMap
  namespace export get_initiatorSockets
  namespace export get_memorySockets
  namespace export get_peripheralSockets
  namespace export get_debugApbSocket
  namespace export set_debugApbSocketClock
  namespace export get_debugApbSocketClock

  namespace export test

  set version 2.0
  set Description "Maestro_Socket"
  variable created_units [list]
  variable chipSocketDict [dict create ]
  variable debugAPBSocketClock ""

  variable home [file join [pwd] [file dirname [info script]]]
}

proc Socket::test {hdr} {
  puts "Socket version: Socket::version -- $hdr"
}

proc _getSocketByType {subsystem socketType} {
  set returnSockets [list ]
  set sockets   [get_objects -parent $subsystem -type "socket"]
  foreach sk $sockets {
    set func [get_parameter -object $sk -name socketFunction]
    if {$func == $socketType} {
      lappend returnSockets $sk
    }
  }
  return $returnSockets
}

proc Socket::get_debugApbSocket { subsystem } {
  return [_getSocketByType $subsystem  "EXTERNAL_DEBUG"]
}

proc Socket::get_initiatorSockets { subsystem } {
  return [_getSocketByType $subsystem  "INITIATOR"]
}


proc Socket::get_memorySockets { subsystem } {
  return [_getSocketByType $subsystem  "MEMORY"]
}

proc Socket::get_peripheralSockets { subsystem } {
  return [_getSocketByType $subsystem  "PERIPHERAL"]
}

proc Socket::set_debugApbSocketClock { subsystem clock} {
  set Socket::debugAPBSocketClock $clock
  set sk_debugAPB [get_debugApbSocket $subsystem]
  if {[llength $sk_debugAPB] == 1} {
    update_object -name [list $sk_debugAPB 0] -bind $clock -type domain
    return 1
  }
  return 0
}

proc Socket::get_debugApbSocketClock { subsystem } {
  if {$Socket::debugAPBSocketClock != ""} {
    return $Socket::debugAPBSocketClock
  }
  set chip [get_objects -parent project -type chip]
  set clkSubdomains [get_objects -parent $chip -type clock_subdomain]
  if {[llength $clkSubdomains] > 0} {
    return [lindex $clkSubdomains 0]
  }
  return ""
}

proc Socket::addToDict { kee obj} {
  if { [dict exist $Socket::chipSocketDict $kee] } {
    set myList [dict get $Socket::chipSocketDict $kee]
    lappend myList $obj
    dict set Socket::chipSocketDict $kee $myList
  } else {
    dict append Socket::chipSocketDict $kee [list $obj]
  }
}

proc Socket::create_socket { system nameVal clkVal protocolVal roleVal functionVal wDataVal wAddrVal idw } {
  # puts "Socket::create_socket $nameVal"
  # not_used $system 
  set sk [Socket::create -name $nameVal -protocolType $protocolVal -function $functionVal -role $roleVal \
                         -wdata $wDataVal -waddr $wAddrVal -clock $clkVal]
  if {$protocolVal == "AXI4"} {
    set_attribute -object $sk -name params/wArId -value $idw
    set_attribute -object $sk -name params/wAwId -value $idw
    set_attribute -object $sk -name params/wAwUser -value 4
    set_attribute -object $sk -name params/wArUser -value 4
  } elseif {$protocolVal == "APB"} {
    set_attribute -object $sk -name params/wPSlverr -value 1 
    set_attribute -object $sk -name params/wAddr -value 14
  }
  return $sk
}

proc Socket::create_debug_apb_socket { subsystem subsystemVal name nameVal clk clkVal } {
  # puts "Socket::create_debug_apb_socket $subsystem $nameVal"

  set sock [create_object -type socket -name $nameVal -parent $subsystemVal]
  set_attribute -object $sock -name socketFunction -value "EXTERNAL_DEBUG"
  update_object -name $sock -bind $clkVal -type "domain"

  return $sock
}

proc Socket::create { name nameVal protocol protocolVal function functionVal role roleVal wData wDataVal wAddr wAddrVal clk clkVal } {
  # puts "Socket::create $nameVal"
  set sk [create_interface $name $nameVal $protocol $protocolVal $function $functionVal $role $roleVal $wData $wDataVal $wAddr $wAddrVal $clk $clkVal]
  set addrVal  [Socket::get_wAddr $sk]
  set dataVal  [Socket::get_wData $sk]
  set protocol [get_parameter -object $sk -name protocolType]

  if {[string compare $protocol "AXI4"] == 0} {
    set func [get_parameter -object $sk -name socketFunction]
    if {[string compare $func "INITIATOR"] == 0} {
      Socket::addToDict $protocol $sk
    } else {
      Socket::addToDict $func $sk
    }
  } else {
    Socket::addToDict $protocol $sk
  }

  return $sk
}

proc Socket::create2 { list_of_protocols name parentUnit clk ncoreType } {
  puts "type: $ncoreType clk: $clk"
  set n 0
  set len             [llength $list_of_protocols]
  for {set i 0} {$i < $len} {incr i} {
    set protocol [lindex $list_of_protocols $i];  incr i
    set nUnits   [lindex $list_of_protocols $i]
    for {set j 0} {$j < $nUnits} {incr j} {
      set nam ""; append nam $name $n;  incr n
      set sock [create_object -name $nam -type socket -parent $parentUnit]
      set_attribute -object $sock -value_list [list protocolType $protocol]

      if {[string compare $ncoreType "CAIU"] == 0} {
        set params [list socketFunction INITIATOR]
        set_attribute -object $sock -value_list $params
      } elseif {[string compare $ncoreType "IOAIU"] == 0} {
        set params [list socketFunction INITIATOR]
        set_attribute -object $sock -value_list $params
      } elseif {[string compare $ncoreType "DMI"] == 0} {
        set params [list socketFunction MEMORY]
        set_attribute -object $sock -value_list $params
      } elseif {[string compare $ncoreType "DII"] == 0} {
        set params [list socketFunction PERIPHERAL]
        set_attribute -object $sock -value_list $params
      }

      update_object -name $sock -bind $clk -type "domain"

      lappend newSockets $sock
    }
  }
  dict append Socket::chipSocketDict $ncoreType $newSockets
  return $newSockets
}

proc Socket::getSocketDict { } {
  return $Socket::chipSocketDict
}

proc Socket::set_attr { objs params } {
	foreach unit $objs {
		set_attribute -object $unit -value_list $params
	}
}

# ***********************************************************************************************************
#
# Description:   This procedure is used to set the address width on the interface.
#                The internal parameter name is "wAddr".
# Argument:      List of objects of type "socket".
# Example usage: Socket::set_wAddr [Socket::get_by_name [list "ncaiu0"]] 48
#
# ************************************************************************************************************
proc Socket::set_wAddr { objs val} {
  set attrKey params/wAddr
  foreach obj $objs {
    set_attribute -object $obj -name $attrKey -value $val
  }
}

proc Socket::get_wAddr { objs } {
  set vals [list ]
  set attrKey params/wAddr
  foreach obj $objs {
    set v [get_parameter -object $obj -name $attrKey]
    lappend vals $v
  }
  return $vals
}

# ***********************************************************************************************************
#
# Description:   This procedure is used to set the data width on the interface.
#                The internal parameter name is "wData".
# Argument:      List of objects of type "socket".
# Example usage: Socket::set_wData [Socket::get_by_name [list "ncaiu0"]] 128
#
# ************************************************************************************************************
proc Socket::set_wData { objs val} {
  set attrKey params/wData
  foreach obj $objs {
    set_attribute -object $obj -name $attrKey -value $val
  }
}

proc Socket::get_wData { objs } {
  set vals [list ]
  set attrKey params/wData
  foreach obj $objs {
    set v [get_parameter -object $obj -name $attrKey]
    lappend vals $v
  }
  return $vals
}

# ***********************************************************************************************************
#
# Description:   This procedure is used to Enable DVM support on the ACE-lite and ACE5-Lite interface.
#                The internal parameter name is "eAc". 
# Argument:      List of objects of type "socket" with function "INITIATOR" and protocolType "ACE-Lite" or "ACE5-Lite"
# Example usage: Socket::set_enableDVM [Socket::get_by_name [list "ncaiu2"]] false
#
# ************************************************************************************************************

proc Socket::set_enableDVM { objs val} {
  set attrKey params/enableDVM
  foreach obj $objs {
    set_attribute -object $obj -name $attrKey -value $val
  }
}

# ***********************************************************************************************************
#
# Description:   This procedure is used to SET. When set disables read data interleaving across different AXI IDs.
# Argument:      List of objects of type "socket" with function "INITIATOR" and protocolType "AXI4" or "ACE-Lite" or "ACE5-Lite"
# Example usage: Socket::set_fnDisableRdInterleave [Socket::get_by_name [list "ncaiu2"]] true
#
# ************************************************************************************************************

proc Socket::set_fnDisableRdInterleave { objs val} {
  set attrKey fnDisableRdInterleave
  foreach obj $objs {
    set_attribute -object $obj -name $attrKey -value $val
  }
}

proc Socket::get_fnDisableRdInterleave { objs {val ""} } {
  set attrKey fnDisableRdInterleave
  set vals [list ]
  foreach obj $objs {
  set v [get_parameter -object $obj -name $attrKey]
  lappend vals $v
  }
  return $vals
}

proc Socket::set_eAc { objs val} {
  puts "set_eAc is deprecated. Use set_enableDVM instead. set_enableDVM accepts true/false."
  set value false
  if {$val == 1} {
    set value true
  }
  set_enableDVM $objs $value
}

proc Socket::get_eAc { objs {val ""} } {
  set attrKey params/eAc
  set vals [list ]
  foreach obj $objs {
  set v [get_parameter -object $obj -name $attrKey]
  lappend vals $v
  }
  return $vals
}

# ***********************************************************************************************************
#
# Description:   This procedure is used to set the "width of Ar Id" on the interface.
#                The internal parameter name is "wArId".
# Argument:      List of objects of type "socket" which do not have protocolType "CHI-B", "CHI-A" or "CHI-E"
# Example usage: Socket::set_wArId [Socket::get_by_name [list "ncaiu0"]] 10
#
# ************************************************************************************************************
proc Socket::set_wArId { objs val} {
  set attrKey params/wArId
  foreach obj $objs {
    set_attribute -object $obj -name $attrKey -value $val
  }
}

proc Socket::get_wArId { objs {val ""} } {
  set attrKey params/wArId
  set vals [list ]
  foreach obj $objs {
  set v [get_parameter -object $obj -name $attrKey]
  lappend vals $v
  }
  return $vals
}

# ***********************************************************************************************************
#
# Description:   This procedure is used to set the "width of Aw Id" on the interface.
#                The internal parameter name is "wAwId".
# Argument:      List of objects of type "socket" which do not have protocolType "CHI-B", "CHI-A" or "CHI-E"
# Example usage: Socket::set_wAwId [Socket::get_by_name [list "ncaiu0"]] 10
#
# ************************************************************************************************************
proc Socket::set_wAwId { objs val} {
  set attrKey params/wAwId
  foreach obj $objs {
    set_attribute -object $obj -name $attrKey -value $val
  }
}

proc Socket::get_wAwId { objs {val ""} } {
  set attrKey params/wAwId
  set vals [list ]
  foreach obj $objs {
  set v [get_parameter -object $obj -name $attrKey]
  lappend vals $v
  }
  return $vals
}

proc Socket::set_wUser { objs val} {
  puts "WARNING: This API "Socket::set_wUser" is not supported anymore"
}

# ***********************************************************************************************************
#
# Description:   This procedure is used to set the "width of Aw User" on the interface.
#                The internal parameter name is "wAwUser".
# Argument:      List of objects of type "socket" which do not have protocolType "CHI-B", "CHI-A" or "CHI-E"
# Example usage: Socket::set_wAwUser [Socket::get_by_name [list "ncaiu0"]] 0
#
# ************************************************************************************************************
proc Socket::set_wAwUser { objs val} {
  set attrKey params/wAwUser
  foreach obj $objs {
    set_attribute -object $obj -name $attrKey -value $val
  }
}

proc Socket::get_wAwUser { objs {val ""} } {
  set attrKey params/wAwUser
  set vals [list ]
  foreach obj $objs {
  set v [get_parameter -object $obj -name $attrKey]
  lappend vals $v
  }
  return $vals
}

# ***********************************************************************************************************
#
# Description:   This procedure is used to set the "width of Ar User" on the interface.
#                The internal parameter name is "wArUser".
# Argument:      List of objects of type "socket" which do not have protocolType "CHI-B", "CHI-A" or "CHI-E"
# Example usage: Socket::set_wArUser [Socket::get_by_name [list "ncaiu0"]] 0
#
# ************************************************************************************************************
proc Socket::set_wArUser { objs val} {
  set attrKey params/wArUser
  foreach obj $objs {
    set_attribute -object $obj -name $attrKey -value $val
  }
}

proc Socket::get_wArUser { objs {val ""} } {
  set attrKey params/wArUser
  set vals [list ]
  foreach obj $objs {
  set v [get_parameter -object $obj -name $attrKey]
  lappend vals $v
  }
  return $vals
}

# ***********************************************************************************************************
#
# Description:   This procedure is used to set the "Enable Poison Bits" on the CHI interface.
#                The internal parameter name is "enPoison".
# Argument:      List of objects of type "socket" with protocolType "CHI-B" or "CHI-E" and function "INITIATOR"
# Example usage: Socket::set_enPoison [Socket::get_by_name [list "caiu0"]] 0
#
# ************************************************************************************************************
proc Socket::set_enPoison { objs val} {
  set attrKey params/enPoison
  foreach obj $objs {
    set_attribute -object $obj -name $attrKey -value $val
  }
}

proc Socket::get_enPoison { objs {val ""} } {
  set attrKey params/enPoison
  set vals [list ]
  foreach obj $objs {
  set v [get_parameter -object $obj -name $attrKey]
  lappend vals $v
  }
  return $vals
}

# ***********************************************************************************************************
#
# Description:   This procedure is used to set the "Width of the Request RSVDC" on the CHI interface.
#                The internal parameter name is "REQ_RSVDC".
# Argument:      List of objects of type "socket" with protocolType "CHI-B" or "CHI-E" and function "INITIATOR"
# Example usage: Socket::set_REQ_RSVDC [Socket::get_by_name [list "caiu0"]] 0
#
# ************************************************************************************************************
proc Socket::set_REQ_RSVDC { objs val} {
  set attrKey params/REQ_RSVDC
  foreach obj $objs {
    set_attribute -object $obj -name $attrKey -value $val
  }
}

proc Socket::get_REQ_RSVDC { objs {val ""} } {
  set attrKey params/REQ_RSVDC
  set vals [list ]
  foreach obj $objs {
  set v [get_parameter -object $obj -name $attrKey]
  lappend vals $v
  }
  return $vals
}

# ***********************************************************************************************************
#
# Description:   This procedure is used to set the "Width of the Node Id" on the CHI interface.
#                The internal parameter name is "NodeID_Width".
# Argument:      List of objects of type "socket" with protocolType "CHI-B" or "CHI-E" and function "INITIATOR"
# Example usage: Socket::set_NodeID_Width [Socket::get_by_name [list "caiu0"]] 7
#
# ************************************************************************************************************
proc Socket::set_NodeID_Width {objs val} {
  set attrKey params/NodeID_Width
  foreach obj $objs {
    set_attribute -object $obj -name $attrKey -value $val
  }
}

proc Socket::set_wRegion { objs val} {
  set attrKey params/wRegion
  foreach obj $objs {
    set_attribute -object $obj -name $attrKey -value $val
  }
}

proc Socket::get_wRegion { objs {val ""} } {
   set attrKey params/wRegion
   set vals [list ]
   foreach obj $objs {
        set v [get_parameter -object $obj -name $attrKey]
	lappend vals $v
   }
   return $vals
}

# ***********************************************************************************************************
#
# Description:   This procedure is used to retrieve a socket by its name.
# Argument:      Names of objects of type "socket"
# Reteuns:       Returns the object of type "socket" with the given name.
# Example usage: Socket::get_by_name [list "caiu0"]
#
# ************************************************************************************************************
proc Socket::get_by_name { objList } {
  set chip     [get_objects -type chip -parent root]
  set system   [get_objects -type system -parent $chip]
  set subsystem [get_objects -type subsystem -parent $system]
  set sockets [list]
  foreach name $objList {
    set socket $subsystem/$name
    lappend sockets $socket
  }
  return $sockets
}

proc Socket::set_protocolType { objs val} {
  set attrKey protocolType
  foreach obj $objs {
    set_attribute -object $obj -name $attrKey -value $val

    if {[string compare $val "CHI-A"] == 0} {
      Socket_CHI_A::set_pre_map_unit_defaults $sock
    } elseif {[string compare $val "CHI-B"] == 0} {
      Socket_CHI_B::set_pre_map_unit_defaults $sock
    } elseif {[string compare $val "CHI-E"] == 0} {
      Socket_CHI_E::set_pre_map_unit_defaults $sock
    } elseif {[string compare $val "AXI4"] == 0} {
      Socket_AXI::set_pre_map_unit_defaults $sock
    } elseif {[string compare $val "ACE"] == 0} {
      Socket_ACE::set_pre_map_unit_defaults $sock
    } elseif {[string compare $val "ACE-Lite"] == 0} {
      Socket_AceLite::set_pre_map_unit_defaults $sock
    } elseif {[string compare $val "ACE5-Lite"] == 0} {
      Socket_AceLiteE::set_pre_map_unit_defaults $sock
    # } else {
    #   set_attribute -object $obj -name $attrKey -value $val
    }
  }
}

proc Socket::get_protocolType { objs } {
  set attrKey protocolType
  set vals [list ]
  foreach obj $objs {
    set v [get_parameter -object $obj -name $attrKey]
    lappend vals $v
  }
  return $vals
}

proc Socket::set_socketFunction { objs val} {
  set attrKey socketFunction
  foreach obj $objs {
    set_attribute -object $obj -name $attrKey -value $val
  }
}

proc Socket::get_socketFunction { objs } {
  set attrKey socketFunction
  set vals [list ]
  foreach obj $objs {
    set v [get_parameter -object $obj -name $attrKey]
    lappend vals $v
  }
  return $vals
}

proc Socket::set_wData { objs val} {
  set attrKey params/wData
  foreach obj $objs {
    set_attribute -object $obj -name $attrKey -value $val
  }
}

proc Socket::get_wData { objs } {
  set vals [list ]
  set attrKey params/wData
  foreach obj $objs {
    set v [get_parameter -object $obj -name $attrKey]
    lappend vals $v
  }
  return $vals
}
package provide Socket $Socket::version
package require Tcl 8.5
