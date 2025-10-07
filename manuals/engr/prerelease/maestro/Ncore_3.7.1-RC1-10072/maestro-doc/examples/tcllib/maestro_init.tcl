# This maestro_init.tcl sources all tcl files from ./tepam_commands folder

set maestroInit_curDir [ file dirname [ file normalize [ info script ] ] ]

foreach filePath [glob -directory "$maestroInit_curDir/tepam_commands" "*.tcl"] {
  # puts "Sourcing tcllib $filePath"
  source $filePath
}
