
# *********************************************************************************************
#
# This script provides procedures to set parameters on the object of type "clock". 
# 
# *********************************************************************************************
namespace eval Clock {
  namespace export create
  namespace export set_external_gating
  namespace export set_unit_gating
  namespace export create_region
  namespace export create_domain
  namespace export get_by_freq

  set version 2.0
  set Description "Maestro_Clock"

  variable home [file join [pwd] [file dirname [info script]]]
}

# **************************************************************************************************************
#
# Description: This procedure is used to create a clock.
# Argument:    The name for the object of "clock_region", the name for "clock_domain", the name for "clock_subdomain",
#               the frequency for the "clock_region".
# Returns:      Returns an object of type "clock_subdomain"
# Example usage: Clock::create "clk_reg_a" "clkdom_a" "clksubdom_a" "1.6GHz"
# ****************************************************************************************************************
proc Clock::create { region domain subdomain frequency } {
    puts "---------Creating clock with name $region/$domain/$subdomain----------"
    set chip [Project::get_chip]
    set pwrregion [Power::get_region]
    set pwrdomain [Power::get_domain]
    set clkRegion $chip/$region
    set state [query_object -type userName -object $chip/$region]
    if {$state == ""} {
    	set clkRegion [create_clock_region -name $region -parent $chip -frequency $frequency -power_region $pwrregion]
    }
    set clkDomain $clkRegion/$domain
    set state [query_object -type userName -object $clkRegion/$domain]
    if {$state == ""} {
        set pwr_gating [get_parameter -object $pwrdomain -name "gating"]
        set gating "always_on"
        if {$pwr_gating == "dynamic"} {
          set gating "external"
	      }
	  set clkDomain [create_clock_domain -name $domain -parent $clkRegion -gating $gating -power_domain $pwrdomain]
    }
    set clkSubdomain $clkDomain/$subdomain
    set state [query_object -type userName -object $clkDomain/$subdomain]
    if {$state == ""} {
      set clkSubdomain [create_object -name $subdomain -type clock_subdomain -parent $clkDomain]
    }
    return $clkSubdomain
}

# ****************************************************************************************************************
#
# Description: This procedure is used to set the gating of the clock domain to be external or not.
# Argument:    The object of type "clock_subdomain" and the boolean value for the gating.
# Returns: The gating is set on the object of type "clock_subdomain"
# Example usage: Clock::set_external_gating $clock_16_GHz true
#
# ****************************************************************************************************************
proc Clock::set_external_gating { subdomain bool } {
    set clockdomain [Project::get_clock_domain $subdomain]
    set powerdmn [Power::get_domain]
    if {$bool == true} {
    	set_attribute -object $clockdomain -name gating  -value external
    } else {
      set_attribute -object $clockdomain -name gating  -value always_on
    }
}

# ****************************************************************************************************************
#
# Description: This procedure is used to set the gating at the unit level The ncore unit which has this clock associated 
#              with it has the unitClockGating enabled.
# Argument:    The object of type "clock_subdomain" and the boolean value for the gating.
# Returns:      The gating is set on the object of type "clock_subdomain"
# Example usage: Clock::set_unit_gating $clock_16_GHz true
#
# ****************************************************************************************************************
proc Clock::set_unit_gating { clksubdomain bool } {
  set clockdomain [Project::get_clock_domain $clksubdomain]
  puts "The clock domain is $clockdomain"
  set clockregion [Project::get_clock_region $clockdomain]
	set_attribute -object $clockregion -name unitClockGating -value $bool
}

# ****************************************************************************************************************
#
# Description: This procedure is used to bind the "clock_subdomain" with the "power_domain".
# Argument:    The object of type "clock_subdomain" and the object of type "power_domain"
# Example usage: Clock::set_power_domain $clock_16_GHz $pwr_domain
#
# ****************************************************************************************************************
proc Clock::set_power_domain { clksubdom pwrdomain } {
  update_object -name $clksubdom -bind $pwrdomain -type "powerDomain"
}

# ****************************************************************************************************************
#
# Description: This procedure is used to retrieve the frequency given the object of type "clock_subdomain"
# Argument:    The object of type "clock_subdomain".
# Returns:     Returns the frequency set on the object of type "clock_subdomain"
# Example usage: Clock::get_freq_from_subdomain $clock_16_GHz
#
# ****************************************************************************************************************
proc Clock::get_freq_from_subdomain { clksub } {
  set clkdom [get_objects -parent $clksub -type clock_domain]
  set clkreg [get_objects -parent $clkdom -type clock_region]
  set freqInt [get_parameter -object $clkreg -name frequency]
  return $freqInt
}

# ****************************************************************************************************************
#
# Description:   This procedure is used to retrieve a clock with the given frequency which has already been created.
# Argument:      The frequency of the clock as a string.
# Returns:       Returns the object of type "clock_subdomain" with the given frequency.
# Example usage: Clock::get_by_freq 1.6GHz
#
# ****************************************************************************************************************
proc Clock::get_by_freq { frequency } {
   set chip [Project::get_chip]
   set clksub [get_objects -parent $chip -type clock_subdomain]
   set unit ""
   foreach csub $clksub {
   	set clkdom [get_objects -parent $csub -type clock_domain]
   	set clkreg [get_objects -parent $clkdom -type clock_region]

	set frequencyFloat [::units::convert $frequency MHz]
	  
	if {$frequencyFloat > [expr pow(2,31)-1]} {
	       error "frequency value '$frequency' can't be expressed in kHz as integer!"
	}

	set frequencyInt [expr round($frequencyFloat)]
	if {$frequencyInt != $frequencyFloat} {
		puts "rounding occured while translating frequency to integer"
	}
	set freqInt [get_parameter -object $clkreg -name frequency]
	set freqKh [expr {$freqInt/1000}]
	if {$frequencyInt == $freqKh} {
        	set unit $csub
		break
	}
   }
   if {$unit == ""} {
   	error "There is no clock created with given frequency"
   } 
   return $unit
}

# ****************************************************************************************************************
#
# Description:   This procedure is used to create a clock region.
# Argument:      The frequency of the clock as an integer in MHz.
# Returns:       Returns the object of type "clock_region" with the given frequency.
# Example usage: Clock::create_region 1600
#
# ****************************************************************************************************************
proc Clock::create_region { frequency } {
  set chip [Project::get_chip]
  set pwrregion [Power::get_region]
  set clkregion [create_clock_region -name clk_reg -parent $chip -frequency $frequency -power_region $pwrregion]
  return $clkregion
}

# ****************************************************************************************************************
#
# Description:   This procedure is used to create a clock domain.
# Argument:      The frequency of the clock as an integer in MHz.
# Returns:       Returns the object of type "clock_domain" with the given frequency.
# Example usage: Clock::create_domain 1600
#
# ****************************************************************************************************************
proc Clock::create_domain { frequency } {
  set chip [Project::get_chip]
  set pwrregion [Power::get_region]
  set pwrdomain [Power::get_domain]
  set clkregion [create_clock_region -name clk_reg -parent $chip -frequency $frequency -power_region $pwrregion]
  set pwr_gating [get_parameter -object $pwrdomain -name "gating"]
  set gating "always_on"
  if {$pwr_gating == "dynamic"} {
    set gating "external"
  }
  set clkDomain [create_clock_domain -name clk_dom -parent $clkregion -gating $gating -power_domain $pwrdomain]
  return $clkregion
}


package provide Clock $Clock::version
package require Tcl 8.5
