namespace eval Qos {
  namespace export set_fnEnableQos
  namespace export set_qosMap
  namespace export set_qosEventThreshold

  namespace export get_fnEnableQos
  namespace export get_qosMap
  namespace export get_qosEventThreshold

  set version 2.0
  set Description "Maestro_Qos"

  variable home [file join [pwd] [file dirname [info script]]]
  variable created_units [list]
}

proc _getTopology {} {
  set chip     [get_objects -type chip -parent root]
  set system   [get_objects -type system -parent $chip]
  set subsystem [get_objects -type subsystem -parent $system]
  set topology [get_objects -type topology -parent $subsystem]
  return $topology
}


proc Qos::set_fnEnableQos { val} {
  set obj [_getTopology]
  set attrKey qosEnabled
  set_attribute -object $obj -name $attrKey -value $val
}

proc Qos::set_qosMap { val} {
  set obj [_getTopology]
  set attrKey qosMap
  set_attribute -object $obj -name $attrKey -value_list $val
}

proc Qos::set_qosEventThreshold { val} {
  set obj [_getTopology]
  set attrKey qosEventThreshold
  set_attribute -object $obj -name $attrKey -value $val
}

proc Qos::get_fnEnableQos { obj } {
  set obj [_getTopology]
  set attrKey qosEnabled
  set v [get_parameter -object $obj -name $attrKey]
  return $v
}

proc Qos::get_qosMap { obj } {
  set obj [_getTopology]
  set attrKey qosMap
  set v [get_parameter -object $obj -name $attrKey]
  return $v
}

proc Qos::get_qosEventThreshold { obj } {
  set obj [_getTopology]
  set attrKey qosEventThreshold
  set v [get_parameter -object $obj -name $attrKey]
  return $v
}

package provide Qos $Qos::version
package require Tcl 8.5
