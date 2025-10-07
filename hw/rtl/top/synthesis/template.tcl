############################################################
# SYNTHESIS SCRIPT
# dc_shell-t -f <%=obj.projectName%>.tcl >& synthesis.log
############################################################

# Set environment variables
set ARTERIS_INPUT_DIR [format "%s" [sh pwd]]
set ARTERIS_LINK_LIB ""

# Source technology info
<% if (obj.customerTechnoInf) { %>
source <%=obj.customerTechnoInf%>
<% } else { %>
    <% if (obj.module === 'fullsys') { %>
source $ARTERIS_INPUT_DIR/<%=obj.fullProjectName%>_parameters.inf
    <% } else { %>
source $ARTERIS_INPUT_DIR/../../<%=obj.fullProjectName%>_parameters.inf
    <% } %>
<% } %>

# Default for all signals
if {![info exists arteris_dflt_ARRIVAL_PERCENT]} {
    set arteris_dflt_ARRIVAL_PERCENT 55
}
if {![info exists arteris_dflt_REQUIRED_PERCENT]} {
    set arteris_dflt_REQUIRED_PERCENT 45
}

<% if (obj.module !== 'fullsys') { %>
# Interface specific constraints
if {![info exists INTERFACES_SFI_ARRIVAL_PERCENT]} {
    set INTERFACES_SFI_ARRIVAL_PERCENT 20
}
if {![info exists INTERFACES_SFI_REQUIRED_PERCENT]} {
    set INTERFACES_SFI_REQUIRED_PERCENT 80
}
if {![info exists INTERFACES_AXI_ARRIVAL_PERCENT]} {
    set INTERFACES_AXI_ARRIVAL_PERCENT 55
}
if {![info exists INTERFACES_AXI_REQUIRED_PERCENT]} {
    set INTERFACES_AXI_REQUIRED_PERCENT 45
}
if {![info exists INTERFACES_ACE_ARRIVAL_PERCENT]} {
    set INTERFACES_ACE_ARRIVAL_PERCENT 55
}
if {![info exists INTERFACES_ACE_REQUIRED_PERCENT]} {
    set INTERFACES_ACE_REQUIRED_PERCENT 45
}
if {![info exists INTERFACES_OCP_ARRIVAL_PERCENT]} {
    set INTERFACES_OCP_ARRIVAL_PERCENT 20
}
if {![info exists INTERFACES_OCP_REQUIRED_PERCENT]} {
    set INTERFACES_OCP_REQUIRED_PERCENT 80
}
<% } %>

# Only used for FlexNoC user signals
set arteris_comb_ARRIVAL_PERCENT 20
set arteris_comb_REQUIRED_PERCENT 40

set arteris_dflt_CLOCK_UNCERTAINTY_PERCENT 5
set ARTERIS_CRITICAL_RANGE 0.01

set LOCAL_CLOCK_GATING <%=obj.localClkGating%>
set GLOBAL_ICG_ENABLE_SETUP "100ps"
set MAX_PATHS 100
<% if (obj.module === 'fullsys') { %>
set UNGROUP_START_LEVEL 3
<% } else { %>
set UNGROUP_START_LEVEL 2
<% } %>

# Clock period declarations
<% if (obj.module === 'fullsys') { %>
<%     obj.constrainedClocks.forEach(function (clk) { %>
set <%=clk%>_P [expr <%=obj.clockFrequency[clk]%>]
<%     }); %>
<% } else { %>
set clk_P <%=obj.clkPeriod%>
<% } %>

set sh_script_stop_severity "E"
set sh_continue_on_error "false"
set sh_enable_page_mode "false"

# Library Definition
<% if (obj.module === 'fullsys') { %>
source include_dc.tcl
<% } else { %>
source ../../include_dc.tcl
<% } %>

<% if (obj.module === 'fullsys') { %>
<% obj.NocStructures.forEach(function (struct) { %>
rename arteris_gen_clock_period arteris_gen_clock
 source $ARTERIS_INPUT_DIR/../<%=struct%>/noc/tcl/gen_clock.tcl
rename arteris_gen_clock arteris_gen_clock_period
<% }); %>
<% } %>

# Include Customer Script
<% if (obj.customerIncludeTcl) { %>
source <%=obj.customerIncludeTcl%>
<% } else { %>
    <% if (obj.module === 'fullsys') { %>
if { [file exists include_customer.tcl] } {
    source include_customer.tcl
}
    <% } else { %>
if { [file exists ../../include_customer.tcl] } {
    source ../../include_customer.tcl
}
    <% } %>
<% } %>

define_design_lib WORK -path $ARTERIS_INPUT_DIR/work_lib

# Preserves unloaded cells and constaints for mapping
set hdlin_preserve_sequential "true"
set compile_seqmap_enable_output_inversion "false"
set compile_delete_unloaded_sequential_cells "false"
set compile_seqmap_propagate_high_effort "false"
set compile_seqmap_propagate_constants "false"
set compile_enable_register_merging "false"

# Set target libraries and link libraries
set target_library [eval concat $ARTERIS_TARGET_LIB]
if {[info exists ARTERIS_LINK_LIB]} {
    set link_library [eval concat "*" $ARTERIS_TARGET_LIB $ARTERIS_LINK_LIB]
} else {
    set link_library [eval concat "*" $ARTERIS_TARGET_LIB]
}

# Read in and elaborate the design
<% obj.verilogFiles.forEach(function (file) { %>
analyze -format sverilog -library WORK <%=file%>
<% }); %>

<% if (obj.module === 'fullsys') { %>
# Read in submodules
    <% obj.NocStructures.forEach(function (struct) { %>
set <%=struct%>_sub_modules [glob ../<%=struct%>/noc/<%=struct%>_*.v]
foreach {file} [split $<%=struct%>_sub_modules] {
    analyze -format sverilog -library WORK $file
}
    <% }); %>
<% } %>

# Read in optional files
<% if (obj.optionalVerilogFiles) { %>
    <% obj.optionalVerilogFiles.forEach(function (file) { %>
if { [file exists <%=file%>] } {
    analyze -format sverilog -library WORK <%=file%>
}
    <% }); %>
<% } %>

# Include additional verilog files
if {[info exists ARTERIS_PATCH_FILES]} {
    foreach {file} [split $ARTERIS_PATCH_FILES] {
        analyze -format sverilog -library WORK $file
    }
}

elaborate <%=obj.projectName%>

# Set Current Design to Top
current_design <%=obj.projectName%>
set TOP <%=obj.projectName%>

# Set Wireload Model
if {[info exists TOPOGRAPHICAL_MODE] && $TOPOGRAPHICAL_MODE} {
    extend_mw_layers
    create_mw_lib -technology $TOPO_TECH_FILE -mw_reference_library $TOPO_MW_REF $TOPO_DESIGN
    open_mw_lib $TOPO_DESIGN
    set_tlu_plus_files -max_tluplus $TOPO_MAX_TLUPLUS -min_tluplus $TOPO_MIN_TLUPLUS -tech2itf_map $TOPO_TECH2ITF_MAP

    if {[info exists MULTI_VT] && $MULTI_VT} {
        set_attribute [get_libs $MULTI_VT_RVT_NAME] default_threshold_voltage_group rvt
        set_attribute [get_libs $MULTI_VT_LVT_NAME] default_threshold_voltage_group lvt
        set_multi_vth_constraint -lvth_groups $MULTI_VT_GROUPS -lvth_percentage $MULTI_VT_PERCENTAGE
    }
} else {
    arteris_update_lib_wlm
    set_wire_load_model -name $WIRE_LOAD_MODEL
    set_wire_load_mode top
}

# Set driving cell and fanout load from library
foreach { LIBRARY LIB_CELL } [eval split $DRIVING_CELL {/}] {
    set_driving_cell -library $LIBRARY -lib_cell $LIB_CELL [all_inputs]
}
set_load 0.001 [all_outputs]

arteris_set_dont_use_lib_cell

<% if (obj.module === 'fullsys') { %>
<% obj.NocStructures.forEach(function (struct) { %>
set CUSTOMER_HIERARCHY "<%=struct%>/"
rename arteris_set_dont_touch_mapped_cell arteris_customer_cell
 source $ARTERIS_INPUT_DIR/../<%=struct%>/noc/tcl/customer_cell.tcl
rename arteris_customer_cell arteris_set_dont_touch_mapped_cell
<% }); %>

# Define clock constraints
source $ARTERIS_INPUT_DIR/tcl/clocks.tcl

# Define generated clocks for each Structure
<% obj.NocStructures.forEach(function (struct) { %>
current_instance <%=struct%>
set STRUCT_PREFIX <%=struct%>_
rename arteris_create_clock arteris_gen_clock
 source $ARTERIS_INPUT_DIR/../<%=struct%>/noc/tcl/gen_clock.tcl
rename arteris_gen_clock arteris_create_clock
rename arteris_set_clock_uncertainty arteris_gen_clock
 source $ARTERIS_INPUT_DIR/../<%=struct%>/noc/tcl/gen_clock.tcl
rename arteris_gen_clock arteris_set_clock_uncertainty
current_instance
<% }); %>

# Define reset constraints
source $ARTERIS_INPUT_DIR/tcl/resets.tcl
source $ARTERIS_INPUT_DIR/tcl/gen_resets.tcl

# Define generated resets for each Structure
<% obj.NocStructures.forEach(function (struct) { %>
current_instance <%=struct%>
set STRUCT_PREFIX <%=struct%>_
rename arteris_set_ideal_network arteris_gen_reset
 source $ARTERIS_INPUT_DIR/../<%=struct%>/noc/tcl/gen_reset.tcl
rename arteris_gen_reset arteris_set_ideal_network
rename arteris_set_ideal_network arteris_gen_reset
 source $ARTERIS_INPUT_DIR/../<%=struct%>/noc/tcl/gen_reset.tcl
rename arteris_gen_reset arteris_set_ideal_network
current_instance
<% }); %>

# Define testmode constraints
source $ARTERIS_INPUT_DIR/tcl/testmode.tcl

# Define Inter-clock constraints
<% obj.NocStructures.forEach(function (struct) { %>
set CUSTOMER_HIERARCHY "<%=struct%>/"
set STRUCT_PREFIX <%=struct%>_
rename arteris_set_inter_clock_domain_constraints arteris_inter_clock_domain
 source $ARTERIS_INPUT_DIR/../<%=struct%>/noc/tcl/inter_clock_domain.tcl
rename arteris_inter_clock_domain arteris_set_inter_clock_domain_constraints
<% }); %>

# Define Global Clock Gating constraints
<% obj.NocStructures.forEach(function (struct) { %>
set CUSTOMER_HIERARCHY "<%=struct%>/"
set STRUCT_PREFIX <%=struct%>_
rename arteris_set_clock_gating_check_setup arteris_customer_cell
 source $ARTERIS_INPUT_DIR/../<%=struct%>/noc/tcl/customer_cell.tcl
rename arteris_customer_cell arteris_set_clock_gating_check_setup
<% }); %>

# Define irq signal paths
source $ARTERIS_INPUT_DIR/tcl/irq_paths.tcl

# Use FlexNoC generated TCL files for FlexNoc User Signals
source $ARTERIS_INPUT_DIR/tcl/user_inputs.tcl
source $ARTERIS_INPUT_DIR/tcl/user_outputs.tcl

<% obj.NocStructures.forEach(function (struct) { %>
set STRUCT_PREFIX <%=struct%>_
rename arteris_set_user_input_delay arteris_input
 source $ARTERIS_INPUT_DIR/../<%=struct%>/noc/tcl/input.tcl
rename arteris_input arteris_set_user_input_delay

rename arteris_set_user_output_delay arteris_output
 source $ARTERIS_INPUT_DIR/../<%=struct%>/noc/tcl/output.tcl
rename arteris_output arteris_set_user_output_delay
<% }); %>

<% } else { %>
# Define clock and reset constraints
create_clock clk -period [expr $clk_P]
set_ideal_network -no_propagate reset_n
set_clock_uncertainty -setup [expr ($arteris_dflt_CLOCK_UNCERTAINTY_PERCENT/100.0)*$clk_P] [get_clocks]
set_clock_uncertainty -hold [expr ($arteris_dflt_CLOCK_UNCERTAINTY_PERCENT/100.0)*$clk_P] [get_clocks]
<% } %>

# Define I/O constraints
source $ARTERIS_INPUT_DIR/tcl/inputs.tcl
source $ARTERIS_INPUT_DIR/tcl/outputs.tcl

# Drive all memory test signals to zero
source $ARTERIS_INPUT_DIR/tcl/drive_zero.tcl

set sh_script_stop_severity "None"
set sh_continue_on_error "true"

# Optionally set operating conditions
if {[info exists MULTI_CORNER] && $MULTI_CORNER} {
    set_operating_conditions -max $SSCORNER -min $FFCORNER
}

# Write out generic files
exec rm -rf $ARTERIS_INPUT_DIR/reports
exec mkdir $ARTERIS_INPUT_DIR/reports
check_design > $ARTERIS_INPUT_DIR/reports/generic.check_design
link > $ARTERIS_INPUT_DIR/reports/generic.link
report_units > $ARTERIS_INPUT_DIR/reports/library.units
analyze_library -multi_vth > $ARTERIS_INPUT_DIR/reports/library.vth
write_file -hierarchy -format verilog -output generic.v
write -format ddc -hierarchy -output generic.ddc

# Map compile and write output netlist
set_app_var case_analysis_propagate_through_icg "true"

if {$LOCAL_CLOCK_GATING} {
    compile_ultra -no_seq_output_inversion -no_autoungroup -no_boundary_optimization -gate_clock
} else {
    compile_ultra -no_seq_output_inversion -no_autoungroup -no_boundary_optimization
}
compile_ultra -incremental

write_file -hierarchy -format verilog -output map.v
write -format ddc -hierarchy -output map.ddc

# Generating reports
#check_timing > $ARTERIS_INPUT_DIR/reports/map.check_timing
report_timing -delay_type max -max_paths $MAX_PATHS -significant_digits 3 -capacitance -transition_time > $ARTERIS_INPUT_DIR/reports/map.timing_max
#report_timing -delay_type min -max_paths $MAX_PATHS -significant_digits 3 -capacitance -transition_time > $ARTERIS_INPUT_DIR/reports/map.timing_min
report_timing -slack_lesser_than 0.0 -max_paths $MAX_PATHS -significant_digits 3 > $ARTERIS_INPUT_DIR/reports/map.timing_violation
report_timing -from [all_inputs] -to [all_outputs] -max_path $MAX_PATHS > $ARTERIS_INPUT_DIR/reports/map.timing_io
report_power -hierarchy -analysis_effort high > $ARTERIS_INPUT_DIR/reports/map.power
report_reference > $ARTERIS_INPUT_DIR/reports/map.reference
report_area -hierarchy > $ARTERIS_INPUT_DIR/reports/map.area
report_qor > $ARTERIS_INPUT_DIR/reports/map.qor
report_net > $ARTERIS_INPUT_DIR/reports/map.net
report_clock_gating -structure > $ARTERIS_INPUT_DIR/reports/map.clock_gating
report_constraint -significant_digits 3 > $ARTERIS_INPUT_DIR/reports/map.constraints
report_design > $ARTERIS_INPUT_DIR/reports/map.design
report_dont_touch > $ARTERIS_INPUT_DIR/reports/map.dont_touch
report_port [all_inputs] > $ARTERIS_INPUT_DIR/reports/map.input_ports
report_port [all_outputs] > $ARTERIS_INPUT_DIR/reports/map.output_ports

set compile_clock_gating_through_hierarchy "false"
set power_cg_auto_identify "false"

# Set critical range
set_critical_range $ARTERIS_CRITICAL_RANGE $TOP

# Optimization
set_dynamic_optimization true
set_leakage_optimization true

# Set compile-time options
set compile_delete_unloaded_sequential_cells "true"
set compile_seqmap_propagate_constants "true"

<% if (obj.module === 'fullsys') { %>
# Set constraints on FlexNoc special and customer cells
# See individual FlexNoc scripts for details
<% obj.NocStructures.forEach(function (struct) { %>
set CUSTOMER_HIERARCHY "<%=struct%>/"
rename arteris_special_dont_touch arteris_special
 source $ARTERIS_INPUT_DIR/../<%=struct%>/noc/tcl/special_case.tcl
rename arteris_special arteris_special_dont_touch
rename arteris_set_dont_touch_mapped_cell arteris_customer_cell
 source $ARTERIS_INPUT_DIR/../<%=struct%>/noc/tcl/customer_cell.tcl
rename arteris_customer_cell arteris_set_dont_touch_mapped_cell
rename arteris_ungroup_customer_cell arteris_customer_cell
 source $ARTERIS_INPUT_DIR/../<%=struct%>/noc/tcl/customer_cell.tcl
rename arteris_customer_cell arteris_ungroup_customer_cell
<% }); %>
<% } %>

# Flatten design
ungroup -all -start_level $UNGROUP_START_LEVEL

<% if (obj.module === 'fullsys') { %>
<% obj.NocStructures.forEach(function (struct) { %>
foreach_in_collection _inst [ filter_collection [sub_instances_of -hier <%=struct%>] "full_name =~ *CoreWrapper* || full_name =~ *CoreCell* || full_name =~ *FifoHm* || full_name =~ *RegFileHm*" ] {
  set cmd [format "set_dont_touch %s false" [get_attribute $_inst full_name] ]
  puts " launching : `$cmd'" ; eval $cmd
}
<% }); %>
<% } %>

# Set power prediction
if {[info exists TOPOGRAPHICAL_MODE] && $TOPOGRAPHICAL_MODE} {
    if {[info exists CLOCK_POWER_PREDICTION] && $CLOCK_POWER_PREDICTION} {
        set_power_prediction true
    }
}

# Optl compile and write output netlist
compile_ultra -no_seq_output_inversion -no_autoungroup -no_boundary_optimization
compile_ultra -incremental

write_file -hierarchy -format verilog -output optl.v
write -format ddc -hierarchy -output optl.ddc

# Generating reports
#check_timing > $ARTERIS_INPUT_DIR/reports/check_timing.rpt
report_timing -delay_type max -max_paths $MAX_PATHS -significant_digits 3 -capacitance -transition_time > $ARTERIS_INPUT_DIR/reports/optl.timing_max
#report_timing -delay_type min -max_paths $MAX_PATHS -significant_digits 3 -capacitance -transition_time > $ARTERIS_INPUT_DIR/reports/optl.timing_min
report_timing -slack_lesser_than 0.0 -max_paths $MAX_PATHS -significant_digits 3 > $ARTERIS_INPUT_DIR/reports/optl.timing_violation
report_timing -from [all_inputs] -to [all_outputs] -max_path $MAX_PATHS > $ARTERIS_INPUT_DIR/reports/optl.timing_io
report_power -hierarchy -analysis_effort high > $ARTERIS_INPUT_DIR/reports/optl.power
report_reference > $ARTERIS_INPUT_DIR/reports/optl.reference
report_area -hierarchy > $ARTERIS_INPUT_DIR/reports/optl.area
report_qor > $ARTERIS_INPUT_DIR/reports/optl.qor
report_net > $ARTERIS_INPUT_DIR/reports/optl.net
report_clock_gating -structure > $ARTERIS_INPUT_DIR/reports/optl.clock_gating
report_constraint -significant_digits 3 > $ARTERIS_INPUT_DIR/reports/optl.constraints
report_design > $ARTERIS_INPUT_DIR/reports/optl.design
report_dont_touch > $ARTERIS_INPUT_DIR/reports/optl.dont_touch
report_port [all_inputs] > $ARTERIS_INPUT_DIR/reports/optl.input_ports
report_port [all_outputs] > $ARTERIS_INPUT_DIR/reports/optl.output_ports

quit
