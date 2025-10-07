
proc get_typed_objects_in_topology { type } {
  set chip      [get_objects -type chip -parent root]
  set system    [get_objects -type system -parent $chip]
  set subsystem [get_objects -type subsystem -parent $system]
  set topology  [get_objects -type topology -parent $subsystem]
  set objects   [get_objects -parent $topology -type $type]
  return $objects
}

proc get_typed_object_in_topology_by_index { type index } {
  set objects  [get_typed_objects_in_topology $type]
  return [lindex $objects $index]
}

proc get_packetizer { type unit_index smi_index } {
  set objects  [get_typed_objects_in_topology $type]
  set object [lindex $objects $unit_index]
  set smi "$object/smi_tx$smi_index"
  set pkt_input [get_objects -parent $smi -type boundto]
  set pkt [get_objects -parent $pkt_input -type parent]
  return "$pkt/Z0"
}

proc get_depacketizer { type unit_index smi_index } {
  set objects  [get_typed_objects_in_topology $type]
  set object [lindex $objects $unit_index]
  set smi "$object/smi_rx$smi_index"
  set dpkt_output [get_objects -parent $smi -type boundto]
  set dpkt [get_objects -parent $dpkt_output -type parent]
  return "$dpkt/I0"
}

proc find_object_path_last_separator_position {obj_path} {
    for {set index [string length $obj_path]} \
        {[string index $obj_path $index] != "/" && $index > 0} \
        {incr index -1} {
    }

    if {$index == 0 && [string index $obj_path $index] != "/"} {
        return -1
    }
    return $index
}

proc get_object_name { obj_path } {
  set obj_name_end [string length $obj_path]
  set obj_name_start [expr [find_object_path_last_separator_position $obj_path] + 1]

  return [string range $obj_path $obj_name_start $obj_name_end]
}

proc move_forw_to_state {desired_state} {
 set current_state [get_current_state]

  while {$current_state != $desired_state} {
    set now_state [get_current_state]
    run_task -name move_to_next_state
    set current_state [get_current_state]
    if {$now_state == $current_state} {
      break; # unable to advance
    }
    puts "Moving forward to state $current_state"
  }

  if {$current_state != $desired_state} {
    puts "Error: we are in $current_state, expecting to be in $desired_state"
  } else {
    puts "Passed: successfully advanced to $desired_state"
  }
}

proc move_back_to_state {desired_state} {
  set current_state [get_current_state]

  while {$current_state != $desired_state} {
    set now_state [get_current_state]
    run_task -name move_to_prev_state
    set current_state [get_current_state]
    if {$now_state == $current_state} {
      break; # unable to move back
    }
    puts "Moving backward to state $current_state"
  }

  if {$current_state != $desired_state} {
    puts "Error: we are in $current_state, expecting to be in $desired_state"
  } else {
    puts "Passed: successfully advanced to $desired_state"
  }
}

proc update_network_routes {} {
  set chip [get_objects -parent project -type chip]
  set ts   [get_objects -parent $chip   -type topology]
  set networks [get_objects -parent $ts -type network]
  foreach netw $networks {
    set isDn  [query_object -object $netw -type dn]
    set isNdn [query_object -object $netw -type ndn]
    if {$isDn == "true" || $isNdn == "true"} {
      puts "# Updating routes on network $netw"
      connect_network -name $netw
    }
  }
}

proc checkFile {fileName} {
  if {[file exists $fileName] == 1} {
    file delete $fileName
  } else {
    puts "\n$fileName does not exist"
  }
}

proc lineNum {frame_info} {
  set result [dict get [info frame $frame_info]  line]
  return $result
}

proc verifyEqual { lineNum actualValue expectedValue } {
  if {$actualValue ne $expectedValue} {
    puts "Error: found $actualValue, expecting $expectedValue at line $lineNum"
  } else {
    puts "Passed: line $lineNum Found $actualValue as expected"
  }
}
# Usage: verifyEqual [lineNum [info frame]] $actualValue $expectedValue
