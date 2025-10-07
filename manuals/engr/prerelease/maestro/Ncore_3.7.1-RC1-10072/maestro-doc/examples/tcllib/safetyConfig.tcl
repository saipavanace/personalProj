  
  namespace eval Safety {
    namespace export set_TIResiliencyProtectionType
    namespace export set_MemProtectionType
    namespace export set_resilienceDisablePinPresent
    namespace export get_useResiliency
    namespace export get_TIResiliencyProtectionType
    namespace export get_MemProtectionType
    namespace export get_enableUnitDuplication
    namespace export get_resilienceDisablePinPresent
    namespace export set_safetyConfig

    set version 2.0
    set Description "Maestro_Safety"
}

proc _getSafetyConfig {} {
  set chip     [get_objects -type chip -parent root]
  set system   [get_objects -type system -parent $chip]
  set subsystem [get_objects -type subsystem -parent $system]
  set safety [get_objects -type safety_configuration -parent $subsystem]
  return $safety
}

proc Safety::set_TIResiliencyProtectionType { val} {
  set obj [_getSafetyConfig]
  set attrKey resiliencyProtectionType
  set_attribute -object $obj -name $attrKey -value $val
}

# ***********************************************************************************************************
#
# Description:   Sets the value for the parameter "Memory Protection".
#                The internal parameter name is "memoryProtectionType".
# Argument:      The value for the parameter "memoryProtectionType".
# Example usage: Safety::set_MemProtectionType SECDED
#
# ************************************************************************************************************
proc Safety::set_MemProtectionType { val} {
  set obj [_getSafetyConfig]
  set attrKey memoryProtectionType
  set_attribute -object $obj -name $attrKey -value $val
}

proc Safety::set_resilienceDisablePinPresent { val} {
  puts "WARNING: Safety::set_resilienceDisablePinPresent or TS::set_resilienceDisablePinPresent is deprecated. BistDebugDisablePin is automatically created with resiliency"
}

proc Safety::get_resilienceDisablePinPresent { } {
  puts "WARNING: Safety::get_resilienceDisablePinPresent or TS::get_resilienceDisablePinPresent is deprecated. BistDebugDisablePin is automatically created with resiliency"
}
# ***********************************************************************************************************
#
# Description:   Sets the ASIL level for the safety configuration object. Multiple parameters are affected by this
#                The internal parameter name is "memoryProtectionType".
# Argument:      The value for the parameter "memoryProtectionType".
# Details:       The following values will derive subsequent values found in the safety configuration object
#                NO_ASIL: resilienceEnabled is false, duplicationEnabled is false, memoryProtectionType is NONE and user-settable, resiliencyProtectionType is NONE and user-settable
#                ASIL_A:  resilienceEnabled is true, duplicationEnabled is false, memoryProtectionType is PARITY and user-settable, resiliencyProtectionType PARITY is user-settable
#                ASIL_B:  resilienceEnabled is true, duplicationEnabled is true, memoryProtectionType is PARITY and user-settable, resiliencyProtectionType PARITY is user-settable
#                ASIL_D:  resilienceEnabled is true, duplicationEnabled is false, memoryProtectionType is SECDED only, resiliencyProtectionType is SECDED only
# ************************************************************************************************************
proc Safety::set_safetyConfig { val } {
  set obj [_getSafetyConfig]
  set attrKey safetyConfig
  set_attribute -object $obj -name $attrKey -value $val
}

proc Safety::get_useResiliency { {obj ""} } {
  if {$obj == ""} {
    set obj [_getSafetyConfig]
  }
  set attrKey resilienceEnabled
  set v [get_parameter -object $obj -name $attrKey]
  if {$v == "true"} {
    return "true"
  }
  return "false"
}

proc Safety::get_TIResiliencyProtectionType { {obj ""} } {
  if {$obj == ""} {
    set obj [_getSafetyConfig]
  }
  set attrKey resiliencyProtectionType
  set v [get_parameter -object $obj -name $attrKey]
  return $v
}

proc Safety::get_MemProtectionType { {obj ""} } {
  if {$obj == ""} {
    set obj [_getSafetyConfig]
  }
  set attrKey memoryProtectionType
  set v [get_parameter -object $obj -name $attrKey]
  return $v
}

proc Safety::get_enableUnitDuplication { {obj ""} } {
  if {$obj == ""} {
    set obj [_getSafetyConfig]
  }
  set attrKey duplicationEnabled
  set v [get_parameter -object $obj -name $attrKey]
  if {$v == "true"} {
    return "true"
  }
  return "false"
}

package provide Safety $Safety::version
package require Tcl 8.5
