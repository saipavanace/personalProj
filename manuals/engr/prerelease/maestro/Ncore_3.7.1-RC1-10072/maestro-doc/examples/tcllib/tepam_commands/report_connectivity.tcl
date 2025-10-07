tepam::procedure {report_connectivity} {
  -category report
  -description "Report connectivity of an instance, packetport or link segment "   
  -example "report_connectivity -object project/chip/topology/yellow/sw1
report_connectivity -object project/chip/topology/yellow/sw1/Z2
report_connectivity -object project/chip/topology/sw1_Z2__sw6_I1"
  -args {
    {
      -object
      -type string
      -description "Full hierarchical path of the object to be reported"
    }
  }
} {
  # Actual function

  set objType [query_object -object $object -type type]
  if {$objType == ""} {
    art_print -level error -msg "Object '$object' is not found!"
    return -code error
  }
  
  if {$objType == "PacketPort"} {
    set parent [get_objects -parent $object -type parent]
    if {[lsearch -exact [get_objects -parent $parent -type packet_port -subtype in] $object] == -1} {
      set direction "out"
      set connectedPortDirection "in"
      set arrow "=>"
    } else {
      set direction "in"
      set connectedPortDirection "out"
      set arrow "<="
    }
    puts "Connectivity report for '$direction' packetport $object"
    set linkSegment [get_objects -parent $object -type link_segment]
    set connectedPort [get_objects -parent $linkSegment -type packet_port -subtype $connectedPortDirection]
    puts " [lindex [split $object "/"] end] $arrow $linkSegment $arrow $connectedPort" 

  } elseif {$objType == "LinkSegment"} {
    puts "Connectivity report for link segment $object"
    set connectedPorts [get_objects -parent $object -type packet_port]
    puts " [lindex $connectedPorts 0] => [lindex [split $object "/"] end] => [lindex $connectedPorts 1]"
  } else {
    # Anything else is assumed to be a unit
    puts "Connectivity report for instance $object"
    puts "Inputs"
    foreach port [get_objects -parent $object -type packet_port -subtype in] {
      set portName [lindex [split $port "/"] end]
      set linkSegment [get_objects -parent $port -type link_segment]
      set connectedPort [get_objects -parent $linkSegment -type packet_port -subtype out]
      puts " $portName <= $linkSegment <= $connectedPort"
    }
    puts "Outputs"
    foreach port [get_objects -parent $object -type packet_port -subtype out] {
      set portName [lindex [split $port "/"] end]
      set linkSegment [get_objects -parent $port -type link_segment]
      set connectedPort [get_objects -parent $linkSegment -type packet_port -subtype in]
      puts " $portName => $linkSegment => $connectedPort"
    }
  }
}
