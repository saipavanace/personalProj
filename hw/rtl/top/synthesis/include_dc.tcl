#
# Update library in memory to include external wire load description
# arteris_update_lib_wlm (no argument - only global variable: A_LIBRARY_INFO)
#
proc arteris_update_lib_wlm {} {
 #
 global A_LIBRARY_INFO
 global ARTERIS_INPUT_DIR ARTERIS_LIB_DIR

 foreach { _lib _val } [array get A_LIBRARY_INFO] {
  upvar $_lib $_lib
  if { [info exists [format "%s(wire_load_model)" $_lib]] && ![info exists [format "%s(library_name)" $_lib]] } {
   set wireload_path [eval format "%s" [format "$%s(wireload_path)" $_lib]]
   foreach { __lib __val } [array get A_LIBRARY_INFO] {
    upvar $__lib $__lib
    if { [info exists [format "%s(library_name)" $__lib]] && ![info exists [format "%s(wire_load_table)" $__lib]] } {
     set library_name [eval format "%s" [format "$%s(library_name)" $__lib]]
     set library_path [eval format "%s" [format "$%s(library_path)" $__lib]]
     set cmd [ concat "update_lib" [eval format "%s:%s" $library_path $library_name] [eval format "%s" $wireload_path] ]
     puts " launching : `$cmd'" ; eval $cmd
    }
   }
  }
 }

}

#
### Clock definition ############################################################################################
#
# arteris_clock -name "clk_cpu" -period "$clk_cpu_P" -waveform "[expr $clk_cpu_P*0.00] [expr $clk_cpu_P*0.50]" -domain "cpu" -edge "R" -port "clk_cpu" -user_directive "MASTER; skew=340ps; skew=10%"
# arteris_gen_clock -name "internalClk100" -divide_by "2" -source "Clk" -source_period "$internalClk_P" -source_waveform "[expr $internalClk_P*0.00] [expr $internalClk_P*0.50]" -source_domain "Clk_domain" -pin "Pllmodule/Clk200/out" -user_directive ""
#
proc arteris_create_clock { args } {
 #
 global TCL2SDC PARTIAL_EXPORT
 global STRUCT_PREFIX
 if { ![info exists TCL2SDC] } { set TCL2SDC "false" }
 if { ![info exists PARTIAL_EXPORT] } { set PARTIAL_EXPORT "false" }
 #
 set state         "flag"
 set name          "void"
 set period        "void"
 set waveform      "void"
 set divide_by     "void"
 set source        "void"
 set source_period "void"
 set port_or_pin   "void"

 set cmd ""
 foreach arg $args {
  switch -- $state {
   flag {
    switch -glob -- $arg {
     -name            { set state "name"          }
     -period          { set state "period"        }
     -waveform        { set state "waveform"      }
     -divide_by       { set state "divide_by"     }
     -source          { set state "source"        }
     -source_period   { set state "source_period" }
     -source_waveform { set state "waveform"      }
     -port            { set state "port"          }
     -pin             { set state "pin"           }
     default          { set state "default"       }
    }
   }
   name {
    set temp_name $arg
    set state "flag"
   }
   period {
    set period [format "%.3f" $arg]
    set state "flag"
   }
   waveform {
    scan $arg "%f %f" w0 w1
    set waveform [format "%.3f %.3f" $w0 $w1]
    set state "flag"
   }
   divide_by {
    set divide_by [format "%.0f" $arg]
    set state "flag"
   }
   source {
    set source $arg
    set state "flag"
   }
   source_period {
    set source_period [format "%.3f" $arg]
    set state "flag"
   }
   port {
    set port_or_pin [format "\[ get_ports { %s } \]" $arg]
    set name $temp_name
    set state "flag"
   }
   pin {
    set port_or_pin [format "\[ get_pins { %s } \]" $arg]
    set name $STRUCT_PREFIX$temp_name
    if { $PARTIAL_EXPORT == "true" } {
     #separator is supposed to be /
     set port_or_pin [format "\[ get_pins { %s/%s } \]" [get_xref [file dirname $arg]] [file tail $arg] ]
    }
    set state "flag"
   }
   default { set state "flag" }
  }
 }

 if { [info procs "arteris_clock"] == "arteris_clock" } {
  set cmd [ format "create_clock -name \"%s\" -period %.3f -waveform \"%s\" %s" $name $period $waveform $port_or_pin ]

 } elseif { [info procs "arteris_virtual_clock"] == "arteris_virtual_clock" } {
  set cmd [ format "create_clock -name \"%s\" -period %.3f -waveform \"%s\"" $name $period $waveform ]

 } elseif { [info procs "arteris_gen_clock"] == "arteris_gen_clock" } {
  set cmd [ format "create_generated_clock -name \"%s\" -divide_by %.0f -source \"%s\" %s" $name $divide_by $source $port_or_pin ]

 } elseif { [info procs "arteris_gen_virtual_clock"] == "arteris_gen_virtual_clock" } {
  set cmd [ format "create_clock -name \"%s\" -period %.3f -waveform \"%s\"" $name [expr $source_period * $divide_by] $waveform ]

 } else {
  return -code error [format "function arteris_create_clock : call of pre-defined function which is not set"]
 }
 if { $TCL2SDC == "true" } { puts "$cmd" } else { puts " launching : `$cmd'" ; eval $cmd }
}

#
### clock skew insertion (fixed or percentage) ##################################################################
#
# arteris_clock -name "clk_cpu" -period "$clk_cpu_P" -waveform "[expr $clk_cpu_P*0.00] [expr $clk_cpu_P*0.50]" -domain "cpu" -edge "R" -port "clk_cpu" -user_directive "MASTER; skew=340ps; skew=10%"
#
proc arteris_set_clock_uncertainty { args } {
 #
 global library arteris_dflt_CLOCK_UNCERTAINTY_PERCENT
 global TCL2SDC
 global STRUCT_PREFIX
 if { ![info exists TCL2SDC] } { set TCL2SDC "false" }
 #
 set T_Flex2library 1.0
 if { [array exist library] && [info exist library(T_Flex2library)] } {
  set T_Flex2library $library(T_Flex2library)
 }

 set state          "flag"
 set name           "void"
 set port           "void"
 set period         "void"
 set user_directive "void"
 set divide_by       1.0

 foreach _args $args {
  switch -- $state { 
   flag {
    switch -glob -- $_args {
     -name           { set state "name"           }
     -port           { set state "port"           }
     -pin            { set state "pin"            }
     -period         { set state "period"         }
     -divide_by      { set state "divide_by"      }
     -source_period  { set state "source_period"  }
     -user_directive { set state "user_directive" }
     default         { set state "default"        }
    }
   }
   name {
    set temp_name $_args
    set state "flag"
   }
   port {
    set port $_args
    set name $temp_name
    set state "flag"
   }
   pin {
    set port $_args
    set name $STRUCT_PREFIX$temp_name
    set state "flag"
   }
   period {
    set period $_args
    set state "flag"
   }
   source_period {
    set period $_args
    set state "flag"
   }
   divide_by {
    set divide_by $_args
    set state "flag"
   }
   user_directive {
    set user_directive $_args
    set state "flag"
   }
   default { set state "flag" }
  }
 }

 set skew_percentage 0.0
 set skew_constant   0.0

 # separator in synthesis_info field is `;'
 set user_directive [string map {{ } {}} $user_directive]
 foreach _arg [split $user_directive {;}] {
  switch -glob "$_arg" {
   skew=*% {
    scan $_arg {skew=%f%s} skew_percentage str_percent
  }
   skew=*ps {
    scan $_arg {skew=%f%s} skew_constant unit
    set skew_constant [expr $skew_constant * $T_Flex2library / 1000]
  }
   skew=*ns {
    scan $_arg {skew=%f%s} skew_constant unit
    set skew_constant [expr $skew_constant * $T_Flex2library]
   }
   default { }
  }
 }

 if {$skew_percentage == 0.0 && $skew_constant == 0.0 } {
  if {![info exists arteris_dflt_CLOCK_UNCERTAINTY_PERCENT]} {
   return -code error [format "function arteris_set_clock_uncertainty : arteris_dflt_CLOCK_UNCERTAINTY_PERCENT not defined"]
  }
  set skew_percentage [expr $arteris_dflt_CLOCK_UNCERTAINTY_PERCENT]
 }

 foreach _proc [info procs "arteris_*"] {
  switch -exact $_proc {

   arteris_clock {
    set cmd [format "set_clock_uncertainty %.3f \"%s\"" [expr $skew_constant + [expr $period * ($skew_percentage/100.0)]] $name]
    if { $TCL2SDC == "true" } {
     puts "$cmd"
    } else {
     puts " launching : `$cmd' ($skew_constant + $skew_percentage % of period $period attached to master clock: $name)" ; eval $cmd
    }
   }

   arteris_gen_clock {
    set cmd [format "set_clock_uncertainty %.3f \"%s\"" [expr $skew_constant + [expr $period * $divide_by * ($skew_percentage/100.0)]] $name]
    if { $TCL2SDC == "true" } {
     puts "$cmd"
    } else {
     puts " launching : `$cmd' ($skew_constant + $skew_percentage % of period [expr $period * $divide_by] attached to derived clock: $name)" ; eval $cmd
    }
   }

  }
 }

}

#
### Timing constraint on reset port #############################################################################
#
proc arteris_set_ideal_network { args } {
 #
 global TCL2SDC PARTIAL_EXPORT
 if { ![info exists TCL2SDC] } { set TCL2SDC "false" }
 if { ![info exists PARTIAL_EXPORT] } { set PARTIAL_EXPORT "false" }
 #
 set state          "flag"
 set port_or_pin    "void"
 set port_f         "void"
 set lsb            "void"
 set msb            "void"

 set cmd ""
 foreach arg $args {
  switch -- $state {
   flag {
    switch -glob -- $arg {
     -port       { set state "port"    }
     -pin        { set state "pin"     }
     -lsb        { set state "lsb"     }
     -msb        { set state "msb"     }
     default     { set state "default" }
    }
   }
   port {
    set port_or_pin $arg
    set state "flag"
   }
   pin {
    set port_or_pin $arg
    set state "flag"
   }
   lsb {
    set lsb $arg
    set state "flag"
   }
   msb {
    set msb $arg
    set state "flag"
   }
   default { set state "flag" }
  }
 }

 if { [info procs "arteris_reset"] == "arteris_reset" } {
  set port_f "reset_port"
  if { $lsb == {} } {
   set cmd [format "set_ideal_network -no_propagate \[get_ports %s\]" $port_or_pin]
   if { $TCL2SDC == "true" } { puts "$cmd" } else { puts " launching : `$cmd'" ; eval $cmd }
  } else {
   for {set i $lsb} {$i <= $msb} {incr i 1} {
    set cmd [format "set_ideal_network -no_propagate \[get_ports %s\[%d\]\]" $port_or_pin $i]
    if { $TCL2SDC == "true" } { puts "$cmd" } else { puts " launching : `$cmd'" ; eval $cmd }
   }
  }
 } elseif { [info procs "arteris_gen_reset"] == "arteris_gen_reset" } {
  set port_f "reset_pin"
  if { $lsb == {} } {
   if { $PARTIAL_EXPORT == "true" } {
    #separator is supposed to be /
    set cmd [format "set_ideal_network -no_propagate  \[get_pin %s/%s\]" [get_xref [file dirname $port_or_pin]] [file tail $port_or_pin]]
   } else {
    set cmd [format "set_ideal_network -no_propagate  \[get_pin %s\]" $port_or_pin]
   }
   if { $TCL2SDC == "true" } { puts "$cmd" } else { puts " launching : `$cmd'" ; eval $cmd }
  } else {
   for {set i $lsb} {$i <= $msb} {incr i 1} {
    set port_or_pin [format "%s\[%d\]" $port_or_pin $i]
    if { $PARTIAL_EXPORT == "true" } {
     #separator is supposed to be /
     set cmd [format "set_ideal_network -no_propagate  \[get_pin %s/%s\]" [get_xref [file dirname $port_or_pin]] [file tail $port_or_pin]]
    } else {
     set cmd [format "set_ideal_network -no_propagate \[get_pin %s\]" $port_or_pin]
    }
    if { $TCL2SDC == "true" } { puts "$cmd" } else { puts " launching : `$cmd'" ; eval $cmd }
   }
  }
 } elseif { [info procs "arteris_testMode"] == "arteris_testMode" } {
  set port_f "test_port"
  if { $lsb == {} } {
   set cmd [format "set_ideal_network -no_propagate \[get_ports %s\]" $port_or_pin]
   if { $TCL2SDC == "true" } { puts "$cmd" } else { puts " launching : `$cmd'" ; eval $cmd }
  } else {
   for {set i $lsb} {$i <= $msb} {incr i 1} {
    set cmd [format "set_ideal_network -no_propagate \[get_ports %s\[%d\]\]" $port_or_pin $i]
    if { $TCL2SDC == "true" } { puts "$cmd" } else { puts " launching : `$cmd'" ; eval $cmd }
   }
  }
 } else {
  return -code error [format "function arteris_set_ideal_network : call of pre-defined function which is not set"]
 }

}

#
### special_case ################################################################################################
#
# arteris_special -case "dont_touch" -instance_name "Req0/BarrelShifter/IntHdrVld" -lsb "" -msb ""
#
proc arteris_special_dont_touch { args } {
 #
 set state         "flag"
 set instance_name "void"
 set case          "void"
 set lsb           "void"
 set msb           "void"

 set cmd " "

 foreach arg $args {
  switch -- $state {
   flag {
    switch -glob -- $arg {
     -case          { set state "case"          }
     -instance_name { set state "instance_name" }
     -lsb           { set state "lsb"           }
     -msb           { set state "msb"           }
     default        { set state "default"       }
    }
   }
   instance_name {
    set instance_name $arg
    set state "flag"
   }
   case {
    set case "set_dont_touch"
    set state "flag"
   }
   lsb {
    set lsb $arg
    set state "flag"
   }
   msb {
    set msb $arg
    set state "flag"
   }
   default { set state "flag" }
  }
 }

 if { $lsb == {} && $msb == {} } {
  set cmd [concat $case [format "%s_reg" $instance_name] true]
  puts " launching : `$cmd'" ; eval $cmd
 } else {
  for {set i $lsb} {$i <= $msb} {incr i 1} {
   set cmd [concat $case [format "%s_reg_%d_" $instance_name $i] true]
   puts " launching : `$cmd'" ; eval $cmd
  } 
 }
}

#
### Inter clock domain constraint ###############################################################################
#
# arteris_set_inter_clock_domain_constraints -from_clk "ClkRx" -from_clk_P "$ClkRx_P" -to_clk "ClkTx" -to_clk_P "$ClkTx_P" [-margin 0.80 (default is 1.00)]
#
# Usually Flag: PARTIAL_EXPORT is not enabled
# But: PARTIAL_EXPORT can be enabled in the optl.tcl file to proposed a bottom/up flow (separateExport directive has been enabled in this case in the pdd)
# Then: 1) submodule is first compiled in order to have submodule description
#       2) then submodule description is re-read with the top level interconnect description
#       3) and top level constraint is set on the global description
#          In this case RTL hierarchy can be not the same compared to the gate level (xref is made with A_2REG array)
#
proc arteris_set_inter_clock_domain_constraints { args } {
 #
 global TCL2SDC PARTIAL_EXPORT
 global STRUCT_PREFIX
 if { ![info exists TCL2SDC] } { set TCL2SDC "false" }
 if { ![info exists PARTIAL_EXPORT] } { set PARTIAL_EXPORT "false" }
 #
 set state          "flag"
 set from_clk       "void"
 set from_reg       "void"
 set from_port      "void"
 set from_pin       "void"
 set from_clk_P     "void"
 set from_lsb       "void"
 set from_msb       "void"
 set to_clk         "void"
 set to_reg         "void"
 set to_clk_P       "void"
 set to_lsb         "void"
 set to_msb         "void"
 set delay          "void"
 set margin          1.00

 set cmd ""
 foreach arg $args {
  switch -- $state {
   flag {
    switch -glob -- $arg {
     -from_clk   { set state "from_clk"   }
     -from_reg   { set state "from_reg"   }
     -from_port  { set state "from_port"  }
     -from_pin   { set state "from_pin"   }
     -from_clk_P { set state "from_clk_P" }
     -from_lsb   { set state "from_lsb"   }
     -from_msb   { set state "from_msb"   }
     -to_clk     { set state "to_clk"     }
     -to_reg     { set state "to_reg"     }
     -to_clk_P   { set state "to_clk_P"   }
     -to_lsb     { set state "to_lsb"     }
     -to_msb     { set state "to_msb"     }
     -delay      { set state "delay"      }
     -margin     { set state "margin"     }
     default     { set state "default"    }
    }
   }
   from_clk {
    set from_clk $STRUCT_PREFIX$arg
    set state "flag"
   }
   from_reg {
    set from_reg $arg
    set state "flag"
   }
   from_port {
    set from_port $arg
    set state "flag"
   }
   from_pin {
    set from_pin $arg
    set state "flag"
   }
   from_clk_P {
    set from_clk_P $arg
    set state "flag"
   }
   from_lsb {
    set from_lsb $arg
    set state "flag"
   }
   from_msb {
    set from_msb $arg
    set state "flag"
   }
   to_clk {
    set to_clk $STRUCT_PREFIX$arg
    set state "flag"
   }
   to_reg {
    set to_reg $arg
    set state "flag"
   }
   to_clk_P {
    set to_clk_P $arg
    set state "flag"
   }
   to_lsb {
    set to_lsb $arg
    set state "flag"
   }
   to_msb {
    set to_msb $arg
    set state "flag"
   }
   delay {
    set delay $arg
    set state "flag"
   }
   margin {
    set margin $arg
    set state "flag"
   }
   default { set state "flag" }
  }
 }

 set from_type ""
 if { $from_clk  != "void" } { set from_type "from_clk"  }
 if { $from_reg  != "void" } { set from_type "from_reg"  }
 if { $from_port != "void" } { set from_type "from_port" }
 if { $from_pin  != "void" } { set from_type "from_pin"  }
 set to_type ""
 if { $to_clk != "void" } { set to_type "to_clk" }
 if { $to_reg != "void" } { set to_type "to_reg" }
 set type [format "%s%s%s" $from_type [if {$to_type != "" && $from_type != ""} {format "_"}] $to_type]

 set delay [format "%.3f" [expr $delay * $margin]]
 switch -glob -- $type {

  from_clk {
   set cmd [format "set_max_delay %s -from \[get_clock %s\]" $delay $from_clk]
   if { $TCL2SDC == "true" } { puts "$cmd" } else { puts " launching : `$cmd'" ; eval $cmd }
  }

  from_clk_to_clk {
   set cmd [format "set_max_delay %s -from \[get_clock %s\] -to \[get_clock %s\]" $delay $from_clk $to_clk]
   if { $TCL2SDC == "true" } { puts "$cmd" } else { puts " launching : `$cmd'" ; eval $cmd }
  }

  from_clk_to_reg {
   if { $to_lsb == {} } {
    set _to_reg [format "%s_reg" $to_reg]
    if { $PARTIAL_EXPORT == "true" } {
     if { [ catch { set _to_reg [get_xref $_to_reg] } result ] } { puts $result; continue }
    }
    set cmd [format "set_max_delay %s -from \[get_clock %s\] -to \[get_cells %s\]" $delay $from_clk $_to_reg]
    if { $TCL2SDC == "true" } { puts "$cmd" } else { puts " launching : `$cmd'" ; eval $cmd }
   } else {
    for {set j $to_lsb} {$j <= $to_msb} {incr j 1} {
     set _to_reg [format "%s_reg\[%d\]" $to_reg $i]
     if { $PARTIAL_EXPORT == "true" } {
      if { [ catch { set _to_reg [get_xref $_to_reg] } result ] } { puts $result; continue }
     }
     set cmd [format "set_max_delay %s -from \[get_clock %s\] -to \[get_cells %s\]" $delay $from_clk $_to_reg]
     if { $TCL2SDC == "true" } { puts "$cmd" } else { puts " launching : `$cmd'" ; eval $cmd }
    }
   }
  }

  from_reg {
   if { $from_lsb == {} } {
    set _from_reg [format "%s_reg" $from_reg]
    if { $PARTIAL_EXPORT == "true" } {
     if { [ catch { set _from_reg [get_xref $_from_reg] } result ] } { puts $result; continue }
    }
    set cmd [format "set_max_delay %s -from \[get_cells %s\]" $delay $_from_reg]
    if { $TCL2SDC == "true" } { puts "$cmd" } else { puts " launching : `$cmd'" ; eval $cmd }
   } elseif { $from_lsb != {} } {
    for {set i $from_lsb} {$i <= $from_msb} {incr i 1} {
     set _from_reg [format "%s_reg\[%d\]" $from_reg $i]
     if { $PARTIAL_EXPORT == "true" } {
      if { [ catch { set _from_reg [get_xref $_from_reg] } result ] } { puts $result; continue }
     }
     set cmd [format "set_max_delay %s -from \[get_cells %s\]" $delay $_from_reg]
     if { $TCL2SDC == "true" } { puts "$cmd" } else { puts " launching : `$cmd'" ; eval $cmd }
    }
   }
  }

  from_reg_to_clk {
   if { $from_lsb == {} } {
    set _from_reg [format "%s_reg" $from_reg]
    if { $PARTIAL_EXPORT == "true" } {
     if { [ catch { set _from_reg [get_xref $_from_reg] } result ] } { puts $result; continue }
    }
    set cmd [format "set_max_delay %s -from \[get_cells %s\] -to \[get_clock %s\]" $delay $_from_reg $to_clk]
    if { $TCL2SDC == "true" } { puts "$cmd" } else { puts " launching : `$cmd'" ; eval $cmd }
   } else {
    for {set i $from_lsb} {$i <= $from_msb} {incr i 1} {
     set _from_reg [format "%s_reg\[%d\]" $from_reg $i]
     if { $PARTIAL_EXPORT == "true" } {
      if { [ catch { set _from_reg [get_xref $_from_reg] } result ] } { puts $result; continue }
     }
     set cmd [format "set_max_delay %s -from \[get_cells %s\] -to \[get_clock %s\]" $delay $_from_reg $to_clk]
     if { $TCL2SDC == "true" } { puts "$cmd" } else { puts " launching : `$cmd'" ; eval $cmd }
    }
   }
  }

  from_reg_to_reg {
   if { $from_lsb == {} && $to_lsb == {}  } {
    set _from_reg [format "%s_reg" $from_reg]; set _to_reg [format "%s_reg" $to_reg]
    if { $PARTIAL_EXPORT == "true" } {
      if { [ catch { set _from_reg [get_xref $_from_reg] } result ] } { puts $result; continue }
      if { [ catch { set _to_reg [get_xref $_to_reg] } result ] } { puts $result; continue }
    }
    set cmd [format "set_max_delay %s -from \[get_cells %s\] -to \[get_cells %s\]" $delay $_from_reg $_to_reg]
    if { $TCL2SDC == "true" } { puts "$cmd" } else { puts " launching : `$cmd'" ; eval $cmd }
   } elseif { $from_lsb != {} && $to_lsb == {}  } {
    set _to_reg [format "%s_reg" $to_reg]
    if { $PARTIAL_EXPORT == "true" } {
     if { [ catch { set _to_reg [get_xref $_to_reg] } result ] } { puts $result; continue }
    }
    for {set i $from_lsb} {$i <= $from_msb} {incr i 1} {
     set _from_reg [format "%s_reg\[%d\]" $from_reg $i]
     if { $PARTIAL_EXPORT == "true" } {
      if { [ catch { set _from_reg [get_xref $_from_reg] } result ] } { puts $result; continue }
     }
     set cmd [format "set_max_delay %s -from \[get_cells %s\] -to \[get_cells %s\]" $delay $_from_reg $_to_reg]
     if { $TCL2SDC == "true" } { puts "$cmd" } else { puts " launching : `$cmd'" ; eval $cmd }
    }
   } elseif { $from_lsb == {} && $to_lsb != {}  } {
    set _from_reg [format "%s_reg" $from_reg]
    if { $PARTIAL_EXPORT == "true" } {
     if { [ catch { set _from_reg [get_xref $_from_reg] } result ] } { puts $result; continue }
    }
    for {set j $to_lsb} {$j <= $to_msb} {incr j 1} {
     set _to_reg [format "%s_reg\[%d\]" $to_reg $j]
     if { $PARTIAL_EXPORT == "true" } {
      if { [ catch { set _to_reg [get_xref $_to_reg] } result ] } { puts $result; continue }
     }
     set cmd [format "set_max_delay %s -from \[get_cells %s\] -to \[get_cells %s\]" $delay $_from_reg $_to_reg] 
     if { $TCL2SDC == "true" } { puts "$cmd" } else { puts " launching : `$cmd'" ; eval $cmd }
    }
   } elseif { $from_lsb != {} && $to_lsb != {}  } {
    for {set i $from_lsb} {$i <= $from_msb} {incr i 1} {
     for {set j $to_lsb} {$j <= $to_msb} {incr j 1} {
      set _from_reg [format "%s_reg\[%d\]" $from_reg $i]; set _to_reg [format "%s_reg\[%d\]" $to_reg $j]
      if { $PARTIAL_EXPORT == "true" } {
       if { [ catch { set _from_reg [get_xref $_from_reg] } result ] } { puts $result; continue }
       if { [ catch { set _to_reg [get_xref $_to_reg] } result ] } { puts $result; continue }
      }
      set cmd [format "set_max_delay %s -from \[get_cells %s\] -to \[get_cells %s\]\]" $delay $_from_reg $_to_reg]
      if { $TCL2SDC == "true" } { puts "$cmd" } else { puts " launching : `$cmd'" ; eval $cmd }
     }
    }
   }
  }

  from_port_to_clk {
   if { $from_lsb == {} } {
    set cmd [format "set_max_delay %s -from \[get_port %s\] -to \[get_clock %s\]" $delay $from_port $to_clk]
    if { $TCL2SDC == "true" } { puts "$cmd" } else { puts " launching : `$cmd'" ; eval $cmd }
   } else {
    for {set i $from_lsb} {$i <= $from_msb} {incr i 1} {
     set cmd [format "set_max_delay %s -from \[get_port %s\[%d\]\] -to \[get_clock %s\]" $delay $from_port $i $to_clk]
     if { $TCL2SDC == "true" } { puts "$cmd" } else { puts " launching : `$cmd'" ; eval $cmd }
    }
   }
  }

  from_pin_to_clk {
   if { $from_lsb == {} } {
    set cmd [format "set_max_delay %s -from \[all_fanin -flat -startpoints_only -to %s\] -to \[get_clock %s\]" $delay $from_pin $to_clk]
    if { $TCL2SDC == "true" } { puts "$cmd" } else { puts " launching : `$cmd'" ; eval $cmd }
   } else {
    for {set i $from_lsb} {$i <= $from_msb} {incr i 1} {
     set cmd [format "set_max_delay %s -from \[all_fanin -flat -startpoints_only -to %s\[%d\]\] -to \[get_clock %s\]" $delay $from_pin $i $to_clk]
     if { $TCL2SDC == "true" } { puts "$cmd" } else { puts " launching : `$cmd'" ; eval $cmd }
    }
   }
  }

  default {
   return -code error [format "function arteris_set_inter_clock_domain_constraints : constraints type is not defined (`%s')" $type]
  }
 }
 
}

#
### setup margin for the clock-gating signal ####################################################################
#
# arteris_customer_cell -module "GaterCell_RstAsync" -type "GaterCell" -instance_name "$CUSTOMER_HIERARCHYclockGaters_datapathSwitches_002/ClockGater/usce4c71b1c0/instGaterCell" -clock "mainRegime_Cm_root" -period "$mainRegime_Cm_root_P"
#  set setup time constraint on the enable of the global clock gater (the value is a percentage control by the variable: GLOBAL_ICG_ENABLE_SETUP_PERCENT which is set in the optl.tcl file)
#
proc arteris_set_clock_gating_check_setup { args } {
 #
 global library GLOBAL_ICG_ENABLE_SETUP
 #
 set T_Flex2library 1.0
 if { [array exist library] && [info exist library(T_Flex2library)] } {
  set T_Flex2library $library(T_Flex2library)
 }
 #
 set state         "flag"
 set type          "void"
 set instance_name "void"
 set clock         "void"
 set clock_period  "void"

 set cmd " "

 foreach arg $args {
  switch -- $state {
   flag {
    switch -glob -- $arg {
     -type          { set state "type"          }
     -instance_name { set state "instance_name" }
     -clock         { set state "clock"         }
     -clock_period  { set state "clock_period"  }
     default        { set state "default"       }
    }
   }
   type {
    set type $arg
    set state "flag"
   }
   instance_name {
    set instance_name $arg
    set state "flag"
   }
   clock {
    set clock $arg
    set state "flag"
   }
   clock_period {
    set clock_period $arg
    set state "flag"
   }
   default { set state "flag" }
  }
 }

 if { $type == "GaterCell" } {

  set global_icg_enable_setup "void"
  switch -glob [string tolower [string map {{ } {}} "$GLOBAL_ICG_ENABLE_SETUP"]] {
   *% {
    scan $GLOBAL_ICG_ENABLE_SETUP {%f%s} percentage str_percent
    set global_icg_enable_setup [expr $clock_period*($percentage/100.0) * $T_Flex2library ]
    set msg [ format "setup value is %.3fps : %.0f%s of period %.3fps attached to clock: %s" $global_icg_enable_setup $percentage "%" $clock_period $clock ]
   }
   *ps {
    scan $GLOBAL_ICG_ENABLE_SETUP {%f%s} delay unit
    set global_icg_enable_setup [expr $delay * $T_Flex2library / 1000]
    set msg [ format "setup value is: %.3f" $global_icg_enable_setup ]
   }
   *ns {
    scan $GLOBAL_ICG_ENABLE_SETUP {%f%s} delay unit
    set global_icg_enable_setup [expr $delay * $T_Flex2library]
    set msg [ format "setup value is: %.3f" $global_icg_enable_setup ]
   }
   default { }
  }
  if { $global_icg_enable_setup == "void" } {
   return -code error [format "function arteris_set_clock_gating_check_setup : setup value for enable of global clock gater is not defined"]
  }

  # By convention the name of the enable at the interface of the customer cell is: EN
  set all_fanout [all_fanout -endpoints_only -flat -from $instance_name/EN]

  if { [sizeof_collection $all_fanout] > 1 } {
   return -code error [format "function arteris_set_clock_gating_check_setup : Founded more than one enable pin with the gater_cell `%s'" $instance_name]
  }

  foreach_in_collection _all_fanout $all_fanout {
   set _icg_pin [get_attribute $_all_fanout full_name]
   set cmd [format "set_clock_gating_check -setup %.3f %s" $global_icg_enable_setup $_icg_pin]
   puts " launching : `$cmd ($msg)'" ; eval $cmd
  }

 }
}

#
### set_dont_touch attribute ####################################################################################
# arteris_set_dont_touch -module "GaterCell" -type "GaterCell" -generator "niui_acc_cpu_data" -instance_name "acc_noc/niui_acc_cpu_data/Wrapped/u_1/instGaterCell" -filled "FALSE"
# arteris_customer_cell -module "securityCore_sl2" -type "CoreWrapper" -generator "sl2_fw" -instance_name "l3_noc_attila_smp_clk2_0/sl2_fw/W/Ci" -filled "TRUE"
#
#
proc arteris_set_dont_touch_mapped_cell { args } {
 #
 set state         "flag"
 set instance_name "void"
 set type          "void"

 set cmd " "

 foreach arg $args {
  switch -- $state {
   flag {
    switch -glob -- $arg {
     -type          { set state "type"          }
     -instance_name { set state "instance_name" }
     default        { set state "default"       }
    }
   }
   type {
    set type $arg
    set state "flag"
   }
   instance_name {
    set instance_name $arg
    set state "flag"
   }
   default { set state "flag" }
  }
 }

 # most of the time GaterCell, SynchronizerCell are mapped on the target technology and optimization is forbidden
 if { [string match -nocase {*GaterCell*} $type] || [string match -nocase {*SynchronizerCell*} $type] } {

  set cmd [format "set_dont_touch %s true" $instance_name]
  puts " launching : `$cmd'" ; eval $cmd

 }
}
proc arteris_ungroup_customer_cell { args } {
 #
 set state         "flag"
 set module        "void"
 set instance_name "void"
 set type          "void"

 set cmd " "

 foreach arg $args {
  switch -- $state {
   flag {
    switch -glob -- $arg {
     -type          { set state "type"          }
     -module        { set state "module"        }
     -instance_name { set state "instance_name" }
     default        { set state "default"       }
    }
   }
   type {
    set type $arg
    set state "flag"
   }
   module {
    set module $arg
    set state "flag"
   }
   instance_name {
    set instance_name $arg
    set state "flag"
   }
   default { set state "flag" }
  }
 }

 # most of the time we do not have the final description for such module (for example CoreWrapper aka Firewall)
 # so we emulate the HDL description but at the end it must be changed by the final customer description
 # these modules can also be based on hard macro (for example ClockManager, RegFileHm)
 if { [string match -nocase {*ClockManager*} $type] || [string match -nocase {*CoreWrapper*} $type] || [string match -nocase {*CoreCell*} $type] || [string match -nocase {*FifoHm*} $type] || [string match -nocase {*RegFileHm*} $type] } {

  puts "# Working on module: [get_attribute $instance_name ref_name] (instance $instance_name)"
  puts "# Warning: RTL is used as description but usually final description is based on hard macro"

  if { ![string match -nocase {*ClockManager*} $type] } {
   set cmd [format "set_dont_touch %s false" $instance_name]
   puts " launching : `$cmd'" ; eval $cmd

   set cmd [ format "current_design %s; ungroup -all -flatten; current_design %s" [get_attribute $instance_name ref_name] [get_object_name [current_design]] ]
   puts " launching : `$cmd'" ; eval $cmd
   set cmd [format "set_dont_touch %s true" $instance_name]
   puts " launching : `$cmd'" ; eval $cmd
  } else {
   set cmd [format "set_dont_touch %s true" [file dirname $instance_name]]
   puts " launching : `$cmd'" ; eval $cmd
  }
 }
}

# Function to declare gen_clock period
proc arteris_gen_clock_period {args} {
    set next "none"
    foreach arg $args {
        if {$arg == "-name"} {
            set next "name"
        } elseif {$arg == "-source_period"} {
            set next "period"
        } elseif {$arg == "-divide_by"} {
            set next "divide_by"
        } elseif {$next == "name"} {
            set name $arg
            set next "none"
        } elseif {$next == "period"} {
            set period $arg
            set next "none"
        } elseif {$next == "divide_by"} {
            set divide_by $arg
            set next "none"
        }
    }

    set temp "_P"
    set ::[concat $name$temp] [ expr $period*$divide_by ]
}

#
#arteris_input -port "ACP_Ar_Ready" -socket "ACP" -clock_domain "SysClk266_i" -clock "PLL_266_ClockManager_SysClk266" -spec_domain_clock "/PLL_266/ClockManager/SysClk266" -clock_period "$PLL_266_ClockManager_SysClk266_P" -type "SYNC" -input_delay "[expr $PLL_266_ClockManager_SysClk266_P*($arteris_dflt_ARRIVAL_PERCENT/100.0)]" -arrival_time "[expr $PLL_266_ClockManager_SysClk266_P*($arteris_dflt_ARRIVAL_PERCENT/100.0)]" -add_delay "FALSE" -lsb "" -msb "" -user_directive "input_delay=1603ps ; output_delay=20%"
#
# 3 ways are available to set the arrival time of an input:
#  .arteris_dflt_ARRIVAL_PERCENT (default value proposed during the export)
#  .setting the synthesisInfo field (FlexNoC GUI with parameter: input_delay=0.5ns [input_delay=200ps | input_delay=22% | arrival_time=1.0ns | arrival_time=12%]
#  .modifying the parameters: -input_delay (respectively -arrival_time) in the input.tcl file (modification made by hand)
#
# Precedence is: .synthesisInfo field (if used in the GUI)
#                .parameters: -input_delay (respectively -arrival_time) (compararison is made with the default value)
#                .variable: arteris_dflt_ARRIVAL_PERCENT (default value)
#
proc arteris_set_user_input_delay { args } {
 #
 global library arteris_dflt_CLOCK_UNCERTAINTY_PERCENT
 global TCL2SDC
 if { ![info exists TCL2SDC] } { set TCL2SDC "false" }
 #
 set T_Flex2library 1.0
 if { [array exist library] && [info exist library(T_Flex2library)] } {
  set T_Flex2library $library(T_Flex2library)
 }
 #
 global arteris_dflt_ARRIVAL_PERCENT
 global arteris_dflt_REQUIRED_PERCENT
 global user_inputs
 global STRUCT_PREFIX
 #
 set state          "flag"
 set add_delay      "void"
 set clock          "void"
 set clock_period   "void"
 set port           "void"
 set port_type      "void"
 set input_delay    "void"
 set arrival_time   "void"
 set user_directive "void"
 set iofile         "void"

 set cmd ""
 foreach _args $args {
  switch -- $state {
   flag {
    switch -glob -- $_args {
     -add_delay      { set state "add_delay"      }
     -clock          { set state "clock"          }
     -clock_period   { set state "clock_period"   }
     -port           { set state "port"           }
     -portType       { set state "port_type"      }
     -input_delay    { set state "input_delay"    }
     -arrival_time   { set state "arrival_time"   }
     -user_directive { set state "user_directive" }
     -iofile         { set state "iofile"         }
     default         { set state "default"        }
    }
   }
   add_delay {
    set add_delay ""
    if {$_args == "TRUE"} { set add_delay "-add_delay" }
    set state "flag"
   }
   clock {
    set clock $STRUCT_PREFIX$_args
    set state "flag"
   }
   clock_period {
    set clock_period $_args
    set state "flag"
   }
   port {
    set port $STRUCT_PREFIX$_args
    set state "flag"
   }
   port_type {
    # separator in synthesis_info field is `;'
    set port_type [string map {{ } {}} $_args]
    set state "flag"
   }
   input_delay {
    set input_delay $_args
    set state "flag"
   }
   arrival_time {
    set arrival_time $_args
    set state "flag"
   }
   user_directive {
    # catch user directives added in the specification project in the field synthesisInfo
    # separator in synthesis_info field is `;'
    if { [lsearch $user_inputs $port] > -1} {
    set user_directive [string map {{ } {}} $_args]
    foreach _arg [split $user_directive {;}] {
     # parameter -user_directive is alway the final parameter and then take precedence over previous setting for variable: -input_delay
     switch -glob "$_arg" {
      input_delay=*% {
       scan $_arg {input_delay=%f%s} input_delay_percentage str_percent
       set input_delay [expr $clock_period*($input_delay_percentage/100.0)]; set arrival_time $input_delay
      }
      input_delay=*ps {
       scan $_arg {input_delay=%f%s} input_delay str_unit
       set input_delay [expr $input_delay * $T_Flex2library / 1000]; set arrival_time $input_delay
      }
      input_delay=*ns {
       scan $_arg {input_delay=%f%s} input_delay str_unit
       set input_delay [expr $input_delay * $T_Flex2library]; set arrival_time $input_delay
      }
      arrival_time=*% {
       scan $_arg {arrival_time=%f%s} arrival_time_percentage str_percent
       set arrival_time [expr $clock_period*($arrival_time_percentage/100.0)]; set input_delay $arrival_time
      }
      arrival_time=*ps {
       scan $_arg {arrival_time=%f%s} arrival_time_delay str_unit
       set arrival_time [expr $arrival_time_delay * $T_Flex2library / 1000]; set input_delay $arrival_time
      }
      arrival_time=*ns {
       scan $_arg {arrival_time=%f%s} arrival_time_delay str_unit
       set arrival_time [expr $arrival_time_delay * $T_Flex2library]; set input_delay $arrival_time
      }
      default { }
     }
    }
    }
    set state "flag"
   }
   iofile {
    set iofile $_args
    set state "flag"
   }
   default { set state "flag" }
  }
 }

 if { [lsearch $user_inputs $port] > -1} {
 if { $clock == "NA" } {
  puts stdout [ format "# Warning: input port `%s' has no timing constraint (clock domain is unavailable)" $port ]
  return
 }
 if { $clock_period == "NA" } {
  puts stdout [ format "# Warning: output port `%s' has no timing constraint (clock domain is unavailable)" $port ]
  return
 }
 # case of modification has been introduced by hand but not equal for parameter -input_delay and -arrival_time
 if { $input_delay != $arrival_time } {
# return -code error [format "function arteris_set_input_delay : parameter input_delay=`%.3f' and arrival_time=`%.3f' are not equivalent with port `%s'" $input_delay $arrival_time $port]
 }

 if { $port_type != "void" } {
   switch -glob "$port_type" {
    "LLI_PSI;ReceiveData;DDR"  {
     # Specific constraints for LLI_PSI mode with signal: Rx_C (Receive Clock), Rx_D (Receive Data)
     #  Rx_D is captured on the rising edge and falling edge of the Rx_C clock
     #  Rx_C is an input port feeds with the transmit clock (no arrival time constraint on this port)
     puts stdout [ format "Info: input port `%s' is the receive data feeds with the transmit data coming from Tx host" $port ]
     set cmd [format "set_input_delay %.3f -clock %s %s" [expr $clock_period*0.45] $clock "\[get_ports $port\]" ]
     if { $TCL2SDC == "true" } { puts "$cmd" } else {  puts " launching : `$cmd'" ; eval $cmd }
     set cmd [format "set_input_delay %.3f -clock_fall -clock %s %s -add_delay" [expr $clock_period*0.45] $clock "\[get_ports $port\]" ]
     if { $TCL2SDC == "true" } { puts "$cmd" } else {  puts " launching : `$cmd'" ; eval $cmd }
     return
    }
    "LLI_PSI;ReceiveClock;DDR" {
     puts stdout [ format "Info: input port `%s' is the receive clock feeds with the transmit clock coming from Tx host" $port ]
     return
    }
    default { }
   }
  }

 # case of default value written by FlexNoC
 if { $input_delay == [expr $clock_period*($arteris_dflt_ARRIVAL_PERCENT/100.0)] } {
  set cmd [format "set_input_delay %.3f -clock %s %s %s" $input_delay $clock $add_delay "\[get_ports $port\]" ]

  if { $TCL2SDC == "true" } { puts "$cmd" } else { puts " launching : `$cmd'" ; eval $cmd }

 # extracted from user constraint (which can be set with parameters: -input_delay, -arrival_time or -user_directive)
 } else {
  set cmd [format "set_input_delay %.3f -clock %s %s %s" $input_delay $clock $add_delay "\[get_ports $port\]" ]
  if { $TCL2SDC == "true" } { puts "$cmd" } else { puts " launching : `$cmd'" ; eval $cmd }
 }
 }

}

#
#arteris_output -port "ACP_Ar_Addr" -socket "ACP" -clock_domain "SysClk266_i" -clock "PLL_266_ClockManager_SysClk266" -spec_domain_clock "/PLL_266/ClockManager/SysClk266" -clock_period "$PLL_266_ClockManager_SysClk266_P" -type "SYNC" -output_delay "[expr $PLL_266_ClockManager_SysClk266_P*(1-($arteris_dflt_REQUIRED_PERCENT/100.0))]" -required_time "[expr $PLL_266_ClockManager_SysClk266_P*($arteris_dflt_REQUIRED_PERCENT/100.0)]" -add_delay "FALSE" -lsb "0" -msb "31" -user_directive "input_delay=1603ps ; output_delay=10%"
#
# 3 ways are available to set the required time of an output:
#  .arteris_dflt_REQUIRED_PERCENT (default value proposed during the export)
#  .setting the synthesisInfo field (FlexNoC GUI with parameter: output_delay=0.5ns [output_delay=200ps | output_delay=22% | required_time=1.0ns | required_time=12%]
#  .modifying the parameters: -output_delay (respectively -required_time) in the output.tcl file (modification made by hand)
#
# Precedence is: .synthesisInfo field (if used in the GUI)
#                .parameters: -output_delay (respectively -required_time) (compararison is made with the default value)
#                .variable: arteris_dflt_REQUIRED_PERCENT (default value)
#
proc arteris_set_user_output_delay { args } {
 #
 global library arteris_dflt_CLOCK_UNCERTAINTY_PERCENT
 global TCL2SDC
 if { ![info exists TCL2SDC] } { set TCL2SDC "false" }
 #
 set T_Flex2library 1.0
 if { [array exist library] && [info exist library(T_Flex2library)] } {
  set T_Flex2library $library(T_Flex2library)
 }
 #

 global arteris_dflt_ARRIVAL_PERCENT
 global arteris_dflt_REQUIRED_PERCENT
 global ARTERIS_OUTPUT_DELAY
 global user_outputs
 global STRUCT_PREFIX
 #
 set state          "flag"
 set add_delay      "void"
 set clock          "void"
 set clock_period   "void"
 set port           "void"
 set port_type      "void"
 set user_directive "void"
 set output_delay   "void"
 set required_time  "void"
 set iofile         "void"

 set cmd ""
 foreach _args $args {
  switch -- $state {
   flag {
    switch -glob -- $_args {
     -add_delay      { set state "add_delay"      }
     -clock          { set state "clock"          }
     -clock_period   { set state "clock_period"   }
     -port           { set state "port"           }
     -portType       { set state "port_type"      }
     -output_delay   { set state "output_delay"   }
     -required_time  { set state "required_time"  }
     -user_directive { set state "user_directive" }
     -iofile         { set state "iofile"         }
     default         { set state "default"        }
    }
   }
   add_delay {
    set add_delay ""
    if {$_args == "TRUE"} { set add_delay "-add_delay" }
    set state "flag"
   }
   clock {
    set clock $STRUCT_PREFIX$_args
    set state "flag"
   }
   clock_period {
    set clock_period $_args
    set state "flag"
   }
   port {
    set port $STRUCT_PREFIX$_args
    set state "flag"
   }
   port_type {
    # separator in synthesis_info field is `;'
    set port_type [string map {{ } {}} $_args]
    set state "flag"
   }
   output_delay {
    set output_delay $_args
    set state "flag"
   }
   required_time {
    set required_time $_args
    set state "flag"
   }
   user_directive {
    # catch user directives added in the specification project in the field synthesisInfo
    # separator in synthesis_info field is `;'
    set user_directive [string map {{ } {}} $_args]
    foreach _arg [split $user_directive {;}] {
     # parameter -user_directive is alway the final parameter and then take precedence over previous setting for variable: -output_delay
     switch -glob "$_arg" {
      output_delay=*% {
       scan $_arg {output_delay=%f%s} output_delay_percentage str_percent
       set output_delay [expr $clock_period * ($output_delay_percentage/100.0)]; set required_time [expr $clock_period-$output_delay]
      }
      output_delay=*ps {
       scan $_arg {output_delay=%f%s} output_delay str_unit
       set output_delay [expr $output_delay * $T_Flex2library / 1000]; set required_time [expr $clock_period-$output_delay]
      }
      output_delay=*ns {
       scan $_arg {output_delay=%f%s} output_delay str_unit
       set output_delay [expr $output_delay * $T_Flex2library]; set required_time [expr $clock_period-$output_delay]
      }
      required_time=*% {
       scan $_arg {required_time=%f%s} required_time_percentage str_percent
       set required_time [expr $clock_period * ($required_time_percentage/100.0)]; set output_delay [expr $clock_period-$required_time]
      }
      required_time=*ps {
       scan $_arg {required_time=%f%s} required_time_delay str_unit
       set required_time [expr $clock_period - ($required_time_delay * $T_Flex2library / 1000)]; set output_delay [expr $clock_period-$required_time]
      }
      required_time=*ns {
       scan $_arg {required_time=%f%s} required_time_delay str_unit
       set required_time [expr $clock_period - ($required_time_delay * $T_Flex2library)]; set output_delay [expr $clock_period-$required_time]
      }
      default { }
     }
    }
    set state "flag"
   }
   iofile {
    set iofile $_args
    set state "flag"
   }
   default { set state "flag" }
  }
 }

 if { [lsearch $user_outputs $port] > -1} {
 if { $clock == "NA" } {
  puts stdout [ format "# Warning: output port `%s' has no timing constraint (clock domain is unavailable)" $port ]
  return
 }
 if { $clock_period == "NA" } {
  puts stdout [ format "# Warning: output port `%s' has no timing constraint (clock domain is unavailable)" $port ]
  return
 }
 # case of modification has been introduced by hand but not equal for parameter -output_delay and -required_time
 if { $output_delay != [expr $clock_period-$required_time] } {
# return -code error [format "function arteris_set_output_delay : parameter output_delay=`%.3f' and required_time=`%.3f' are not equivalent with port `%s'" $output_delay $required_time $port]
 }

 if { $port_type != "void" } {
   switch -glob "$port_type" {
    "LLI_PSI;TransmitData;DDR"  {
     # Specific constraints for LLI_PSI mode with signal: Tx_C (Transmit Clock), Tx_D (Transmit Data)
     #  Tx_D is launched on the rising edge
     #  Tx_C is launched on the falling edge
     puts stdout [ format "Info: output port `%s' is the transmit data going to the receive data present in the Rx host" $port ]
     set cmd [format "set_output_delay %.3f -clock %s %s" [expr $clock_period*0.95] $clock "\[get_ports $port\]" ]
     if { $TCL2SDC == "true" } { puts "$cmd" } else { puts " launching : `$cmd'" ; eval $cmd }
     return
    }
    "LLI_PSI;TransmitClock;DDR" {
     puts stdout [ format "Info: output port `%s' is the transmit clock going to the receive clock present in the Rx host" $port ]
     set cmd [format "set_output_delay %.3f -clock_fall -clock %s %s" [expr $clock_period*0.95] $clock "\[get_ports $port\]" ]
     if { $TCL2SDC == "true" } { puts "$cmd" } else { puts " launching : `$cmd'" ; eval $cmd }
     return
    }
    default { }
   }
  }

 # case of default value written by FlexNoC
 if { $output_delay == [expr $clock_period*(1-($arteris_dflt_REQUIRED_PERCENT/100.0))] } {
  set cmd [format "set_output_delay %.3f -clock %s %s %s" $output_delay $clock $add_delay "\[get_ports $port\]" ]

  if { $TCL2SDC == "true" } { puts "$cmd" } else { puts " launching : `$cmd'" ; eval $cmd }

 # extracted from user constraint (which can be set with parameters: -output_delay, -required_time or -user_directive)
 } else {
  set cmd [format "set_output_delay %.3f -clock %s %s %s" $output_delay $clock $add_delay "\[get_ports $port\]" ]
  if { $TCL2SDC == "true" } { puts "$cmd" } else { puts " launching : `$cmd'" ; eval $cmd }
 }
 }

}

# Add set_dont_use property on specific library cell to be not used
# arteris_set_dont_use_lib_cell (no argument - only global variable: A_LIBRARY_INFO)
proc arteris_set_dont_use_lib_cell {} {
 #
 global A_LIBRARY_INFO

 set dont_use_cell ""
 foreach { _lib _val } [array get A_LIBRARY_INFO] {
  upvar $_lib $_lib
  if { [info exists [format "%s(dont_use_cell)" $_lib]] } {
   lset dont_use_cell [eval format "%s" [format "$%s(dont_use_cell)" $_lib]]
   set library_name [eval format "%s" [format "$%s(library_name)" $_lib]]
   foreach c_dont_use_cell $dont_use_cell {
    set_dont_use [get_lib_cells $library_name/$c_dont_use_cell]
    set cmd [concat "set_dont_use" [format "\[get_lib_cells %s/%s\]" $library_name $c_dont_use_cell]]
    puts " launching : `$cmd'" ; eval $cmd
   }
  }
 }

}
