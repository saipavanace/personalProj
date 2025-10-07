##################
# SYNTHESIS SCRIPT
##################

# Set environment variables

source variables

if {$COMPILE == "yes"} {
set OVERCONSTRAINT 1.00
} else {
set OVERCONSTRAINT 1.00
}

set UNCERTAINTY 0.05
set INPUTDELAY 0.20
set OUTPUTDELAY 0.20
set CRITICALRANGE 0.01

set LIBRARY_PATH "/engr/dev/tools/techno/library/tsmc/$TECHNODE"
set TOP top__DRAM0

define_design_lib WORK -path work_lib

# Some compilation settings

set hdlin_preserve_sequential "true"
set compile_seqmap_enable_output_inversion "false"
set compile_delete_unloaded_sequential_cells "false"
set compile_seqmap_propagate_high_effort "false"
set compile_seqmap_propagate_constants "false"
set compile_enable_register_merging "false"
 
# Set libraries

set target_library "$LIBRARY_PATH/digital/Front_End/timing_power_noise/NLDM/$LIBRARY\_$REVISION/$LIBRARY$FFCORNER\.db"
set target_library "$LIBRARY_PATH/digital/Front_End/timing_power_noise/NLDM/$LIBRARY\_$REVISION/$LIBRARY$SSCORNER\.db $target_library"
set link_library $target_library

# Read design files

source filelist

current_design $TOP
set TOP_DESIGN $TOP

check_design

# DC Topo commands
# Set wireload model

if {$WIRELOAD == "topo"} {
source ../dc_topo
} else {
set_wire_load_model -name $WIRELOAD
set_wire_load_mode top
}

# Define clock constraints

create_clock clk -name clk -period [expr $PERIOD/$OVERCONSTRAINT]
set_ideal_network -no_propagate reset_n

set_clock_uncertainty -setup [expr $UNCERTAINTY*$PERIOD] [get_clocks]
set_clock_uncertainty -hold [expr $UNCERTAINTY*$PERIOD] [get_clocks]

# Define I/O constraints

set sfi_ports_in [get_ports sfi_* -filter {@port_direction == in}]
set sfi_ports_out [get_ports sfi_* -filter {@port_direction == out}]
set axi_ports_in [get_ports axi_* -filter {@port_direction == in}]
set axi_ports_out [get_ports axi_* -filter {@port_direction == out}]
set ocp_ports_in [get_ports ocp_* -filter {@port_direction == in}]
set ocp_ports_out [get_ports ocp_* -filter {@port_direction == out}]

set_input_delay -max [expr $INPUTDELAY*$PERIOD] -clock [get_clocks] [get_ports $sfi_ports_in]
set_output_delay -max [expr $OUTPUTDELAY*$PERIOD] -clock [get_clocks] [get_ports $sfi_ports_out]
set_input_delay -max [expr $INPUTDELAY*$PERIOD] -clock [get_clocks] [get_ports $axi_ports_in]
set_output_delay -max [expr $OUTPUTDELAY*$PERIOD] -clock [get_clocks] [get_ports $axi_ports_out]
set_input_delay -max [expr $INPUTDELAY*$PERIOD] -clock [get_clocks] [get_ports $ocp_ports_in]
set_output_delay -max [expr $OUTPUTDELAY*$PERIOD] -clock [get_clocks] [get_ports $ocp_ports_out]

# 1st Compile and write output netlist

if {$COMPILE == "yes"} {
    if {$SCAN == "yes"} {
        compile_ultra -no_seq_output_inversion -no_autoungroup -no_boundary_optimization -scan -gate_clock
    } else {
        compile_ultra -no_seq_output_inversion -no_autoungroup -no_boundary_optimization -gate_clock
    }
}

# Generating reports

sh mkdir reports
check_timing > reports/check_timing_no_flat.rpt
report_timing -delay_type max -max_paths 100 -capacitance -transition_time > reports/timing_max_no_flat.rpt
report_timing -delay_type min -max_paths 100 -capacitance -transition_time > reports/timing_min_no_flat.rpt
report_timing -slack_lesser_than 0.0 -max_paths 100 > reports/timing_violation_no_flat.rpt
report_timing -from [all_inputs] -to [all_outputs] -max_path 100 > reports/timing_io_no_flat.rpt
report_power -hierarchy -analysis_effort high > reports/power_no_flat.rpt
report_reference > reports/reference_no_flat.rpt
report_area -hierarchy > reports/area_no_flat.rpt
report_qor > reports/qor_no_flat.rpt
report_net > reports/net_no_flat.rpt
report_clock_gating -structure > reports/clock_gating_no_flat.rpt

set compile_clock_gating_through_hierarchy "false"
set power_cg_auto_identify "false"

# Set critical range

set_critical_range $CRITICALRANGE $TOP

# Optimization

set_dynamic_optimization true
set_leakage_optimization true

# Set compile-time options

set compile_delete_unloaded_sequential_cells "true"
set compile_seqmap_propagate_constants "true"

# Set operating conditions

set_operating_conditions -max $SSCORNER -min $FFCORNER

# Set power prediction

if {$WIRELOAD == "topo"} {
set_power_prediction true
}

# Flattening design

ungroup -all -flatten

# Set clock gating

set_clock_gating_style -sequential_cell latch

# 2nd Compile and write output netlist

if {$COMPILE == "yes"} {
    if {$SCAN == "yes"} {
        compile_ultra -no_seq_output_inversion -no_autoungroup -no_boundary_optimization -scan -gate_clock
    } else {
        compile_ultra -no_seq_output_inversion -no_autoungroup -no_boundary_optimization -gate_clock
    }
    optimize_netlist -area
    write_file -hierarchy -format verilog -output $TOP\_net.v
    write -format ddc -hierarchy -output $TOP\.ddc
}

# Generating reports

check_timing > reports/check_timing.rpt
report_timing -delay_type max -max_paths 100 -capacitance -transition_time > reports/timing_max.rpt
report_timing -delay_type min -max_paths 100 -capacitance -transition_time > reports/timing_min.rpt
report_timing -slack_lesser_than 0.0 -max_paths 100 > reports/timing_violation.rpt
report_timing -from [all_inputs] -to [all_outputs] -max_path 100 > reports/timing_io.rpt
report_power -hierarchy -analysis_effort high > reports/power.rpt
report_reference > reports/reference.rpt
report_area -hierarchy > reports/area.rpt
report_qor > reports/qor.rpt
report_net > reports/net.rpt
report_clock_gating -structure > reports/clock_gating.rpt

quit
