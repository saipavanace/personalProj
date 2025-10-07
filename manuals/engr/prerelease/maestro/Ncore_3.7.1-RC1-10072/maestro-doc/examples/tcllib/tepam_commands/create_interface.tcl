tepam::procedure {create_interface} {
  -category clock
  -short_description "create interfaces"
  -description "The ncore blocks connect to the external components using the protocols specified from ARM. Here we create the native interface which abide with the ARM protocols."
  -example "create_interface -name dmi -parent $subsystem -protocolType AXI4 -count 4 -function MEMORY -role MASTER -datawidth 256 -addresswidth 44 -clock $default_clock"
  -args {
    {
      -name
      -description "Name of the interface"
    }
    {
      -protocolType
      -choices {CHI-B CHI-A CHI-E AXI4 ACE-Lite-E ACE5-Lite ACE ACE-Lite ACE5 AXI5}
      -type string
      -description "Protocol that connects to the external component"
    }
    {
      -role
      -choices {SLAVE MASTER}
      -optional
      -description "Describes how the socket or port should be used. Slave indicates it is driven by an external component. Master drives an external component"
    }
    {
      -function
      -choices {INITIATOR MULTI_INITIATOR MEMORY PERIPHERAL}
      -description "Describes the function of the external cmponent that this interface is connected to" 
    }
    {
      -wdata
      -type integer
      -description "Describes the datawidth of the interface" 
    }
    {
      -waddr
      -type integer
      -description "Describes the datawidth of the interface" 
    }
    {
      -clock
      -type string
      -description "Describes the clock subdomain it is attached to" 
    }
  }
} {
  # Actual function
  
  # See if chip exists 
  set chip [get_objects -parent root -type chip] 
  if {[llength $chip] == 0} {
    art_print -level error -msg "No chip objects found. Cannot create interface"
    return -code error
  }

  set system   [get_objects -type system -parent $chip]
  if {[llength $chip] == 0} {
    art_print -level error -msg "No object of type "system" found. Cannot create interface"
    return -code error
  }

  set subsystem [get_objects -type subsystem -parent $system]
  if {[llength $chip] == 0} {
    art_print -level error -msg "No object of type "subsystem" found. Cannot create interface"
    return -code error
  }
  
  #Now create a socket
  set sock [create_object -type socket -name $name -parent $subsystem]
  set_attribute -object $sock -value_list [list protocolType $protocolType socketFunction $function params/wAddr $waddr params/wData $wdata]
  update_object -name $sock -bind $clock -type "domain"
  
  # Return socket object
  return $sock
}

