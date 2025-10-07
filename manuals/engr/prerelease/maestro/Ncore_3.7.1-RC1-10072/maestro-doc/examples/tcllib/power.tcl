# *********************************************************************************************
#
# This script provides procedures to set the parameters on "power"
# 
# *********************************************************************************************
namespace eval Power {
  namespace export create_region
  namespace export create
  namespace export get_region
  namespace export get_domain

  set version 2.0
  set Description "Maestro_Power"

  variable home [file join [pwd] [file dirname [info script]]]
}

#-------------------------------------------------------------------------------------
#
# Description: This proc is used to create a power region.
# Example: Power::create_region
#
# -----------------------------------------------------------------------------------
proc Power::create_region {name voltage} {
    set chip [Project::get_chip]
	set powerreg [create_power_region -name $name -voltage $voltage -parent $chip]
	return $powerreg
}

proc Power::create {region domain voltage gating} {
	set chip [Project::get_chip]
	set pwrRegion $chip/$region
	set state [query_object -type userName -object $chip/$region]
	if {$state == ""} {
		set pwrRegion [create_power_region -name $region -voltage $voltage -parent $chip]
	}
	set pwrDomain $pwrRegion/$domain
	set state [query_object -type userName -object $pwrRegion/$domain]
	if {$state == ""} {
		if {$gating != "always_on"} {
			puts "Warning: Power domain '$domain' with gating '$gating' is not supported. Changing to always_on"
			set gating "always_on"
		}
		set pwrDomain [create_power_domain -name $domain -parent $pwrRegion -gating $gating]
	}
	return $pwrDomain
}

# ********************************************************************************************************
#
# Description: This proc is used to access the powere region created.
# Example :    Power::get_region
#
# ********************************************************************************************************
proc Power::get_region { } {
	set chip [Project::get_chip]
	set pwrregs [get_objects -type power_region -parent $chip]
	set pwrreg [lindex $pwrregs 0]
	return $pwrreg
}
 
proc Power::get_domain { } {
	set chip [Project::get_chip]
	set pwrdoms [get_objects -type power_domain -parent $chip]
	set pwrdom [lindex $pwrdoms 0]
	return $pwrdom
}

proc Power::get_domain_by_name { pwrdom } {
	set chip [Project::get_chip]
	set pwrReg [Power::get_region]
	set req_pwrdom [query_object -type userName -object $pwrReg/$pwrdom]
	set pwrdoms [get_objects -type power_domain -parent $chip]
	foreach pwr_dom $pwrdoms {
		if {"$pwr_dom" == "$req_pwrdom"} {
			return $pwr_dom
		}
	}
	error "Power domain with name $pwrdom not found"
}

package provide Power $Power::version
package require Tcl 8.5
