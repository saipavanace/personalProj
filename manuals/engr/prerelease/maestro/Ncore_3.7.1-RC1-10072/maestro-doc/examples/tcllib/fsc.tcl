
namespace eval Fsc {
  namespace export postmap_defaults
  namespace export get_postmap_defaults
  namespace export print_parameters
  namespace export create_obj
  namespace export create_units
  namespace export set_pre_map_unit_defaults
  namespace export get_pre_map_unit_defaults
  namespace export set_pre_map_socket_defaults
  namespace export get_pre_map_socket_defaults
  namespace export set_all_post_map_defaults
  namespace export set_post_map_defaults
  namespace export get_post_map_defaults
  namespace export set_unit_attribute
  namespace export get_unit_attribute
  namespace export number_of_units
  namespace export get_all_units
  namespace export get_unit
  namespace export set_clock
  namespace export get_clock
  namespace export test

  set version 2.0
  set Description "Maestro_Fsc"

  variable home [file join [pwd] [file dirname [info script]]]
  variable created_units [list]
}

proc Fsc::set_pre_map_unit_defaults { obj } {
}

proc Fsc::get_pre_map_unit_defaults { obj } {
  set vals [dict create]
  return $vals
}

proc Fsc::print_pre_map_unit_defaults { unit } {
  set parms [Fsc::get_pre_map_unit_defaults $unit ]
  puts "# Fsc::pre_map_unit_defaults parameters for $unit"
  foreach kee [dict keys $parms] {
    set val [dict get $parms $kee]
    puts "#   $kee = $val"
  }
}

proc Fsc::set_pre_map_socket_defaults { obj } {
}

proc Fsc::get_pre_map_socket_defaults { obj } {
  set vals [dict create]
  return $vals
}

proc Fsc::print_pre_map_socket_defaults { unit } {
  set parms [Fsc::get_pre_map_socket_defaults $unit ]
  puts "# Fsc::pre_map_socket_defaults parameters for $unit"
  foreach kee [dict keys $parms] {
    set val [dict get $parms $kee]
    puts "#   $kee = $val"
  }
}

proc Fsc::set_post_map_defaults { obj } {
}

proc Fsc::get_post_map_defaults { obj } {
  set vals [dict create]
  return $vals
}

proc Fsc::print_post_map_defaults { unit } {
  set parms [Fsc::get_post_map_defaults $unit ]
  puts "# Fsc::post_map_defaults parameters for $unit"
  foreach kee [dict keys $parms] {
    set val [dict get $parms $kee]
    puts "#   $kee = $val"
  }
}

proc Fsc::set_all_post_map_defaults { } {
  foreach obj $Fsc::created_units {
    Fsc::set_post_map_defaults $obj
  }
}

proc Fsc::create_obj { name parent params } {
  set unit [create_object -type functional_safety_controller -name $name -parent $parent ]
  Fsc::set_pre_map_unit_defaults $unit
  if {[llength $params] > 0} {
    set_attribute -object $unit -value_list $params
  }
  lappend Fsc::created_units $unit
  return $unit
}

proc Fsc::create_unit { name } {
  set unit_parent   [Project::get_topology]
  set realName $name
  set unit [Fsc::create_obj $realName $unit_parent [list] ]
  return $Fsc::created_units
}

proc Fsc::test { msg } {
  puts "# In test Fsc proc: msg = $msg"
}

proc Fsc::set_unit_attribute { ind procFunc value } {
  set unit [lindex $Fsc::created_units $ind]
  set x [$procFunc $unit $value]
}

proc Fsc::get_unit_attribute { ind procFunc } {
  set unit [lindex $Fsc::created_units $ind]
  set val [$procFunc $unit]
  return $val
}

proc Fsc::number_of_units { } {
  set val [llength $Fsc::created_units]
  return $val
}

proc Fsc::get_unit { indx } {
  if {$indx < 0 || $indx >= [llength $Fsc::created_units]} {
    return ""
  }
  set val [lindex $Fsc::created_units $indx]
  return $val
}

proc Fsc::set_clock { objList clk } {
  foreach unit $objList {
    update_object -name $unit -bind $clk -type "domain"
  }
}

proc Fsc::get_clock { indx } {
  if {$indx < 0 || $indx >= [llength $Fsc::created_units]} {
    return
  }
  set unit [lindex $Fsc::created_units $indx]
  set clk [get_objects -parent $unit -type clock_subdomain]
  return $clk
}

proc Fsc::get_all_units { } {
  return $Fsc::created_units
}

package provide Fsc $Fsc::version
package require Tcl 8.5
