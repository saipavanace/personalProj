namespace eval PipeAdapter {
  namespace export create_units
  namespace export set_wProt
  namespace export set_pipeForward
  namespace export set_pipeBackward
  namespace export set_simplePipe

  set version 2.0
  set Description "Maestro_PipeAdapter"

  variable home [file join [pwd] [file dirname [info script]]]
  variable created_units [list]
}

proc PipeAdapter::create_units { n name designEnv } {
  set pp [list ]
  for {set i 0} {$i < $n} {incr i} {
	set obj [create_object -type pipe_adapter -name $name$i]
	lappend pp $obj
  }
  return $pp
}

proc PipeAdapter::set_wProt { objList val } {
  foreach obj $objList {
    set pos [string last "/" $obj]
    incr pos
    set shortName [string range $obj $pos end]
    set attrKey interfaces/inInterface/params/wProt
    set_attribute -object $obj -name $attrKey -value $val
  }
}

proc PipeAdapter::set_pipeForward { objList val } {
  puts "Warning: PipeAdapter::set_pipeForward is deprecated. This parameter is always true"
  # foreach obj $objList {
  #   set pos [string last "/" $obj]
  #   incr pos
  #   set shortName [string range $obj $pos end]
  #   set attrKey pipeForward
  #   set_attribute -object $obj -name $attrKey -value $val
  # }
}

proc PipeAdapter::set_pipeBackward { objList val } {
  puts "Warning: PipeAdapter::set_pipeBackward is deprecated. This parameter is always true"
  # foreach obj $objList {
  #   set pos [string last "/" $obj]
  #   incr pos
  #   set shortName [string range $obj $pos end]
  #   set attrKey pipeBackward
  #   set_attribute -object $obj -name $attrKey -value $val
  # }
}

proc PipeAdapter::set_simplePipe { objList val } {
  puts "Warning: PipeAdapter::set_simplePipe is deprecated."
  # foreach obj $objList {
  #   set pos [string last "/" $obj]
  #   incr pos
  #   set shortName [string range $obj $pos end]
  #   set attrKey simplePipe
  #   set_attribute -object $obj -name $attrKey -value $val
  # }
}

proc PipeAdapter::set_depth { objList val } {
  foreach obj $objList {
    set attrKey depth
    set_attribute -object $obj -name $attrKey -value $val
  }
}



package provide PipeAdapter $PipeAdapter::version
package require Tcl 8.5
