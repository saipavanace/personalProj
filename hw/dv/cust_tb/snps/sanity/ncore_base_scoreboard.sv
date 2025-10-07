////////////////////////////////////////////////////////////////////////////////
//
// Author       : 
// Purpose      : Customer testbench scoreboard
// Description  :    
//
////////////////////////////////////////////////////////////////////////////////
<%
const chipletObj = obj.lib.getAllChipletRefs();
const chipletInstances = obj.lib.getAllChipletInstanceNames();
%>

<%if(process.env.ENABLE_INTERNAL_CODE){%>
    `include "ncore_predictor.sv"
    `include "ncore_comparator.sv"
<%}%>

class ncore_base_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(ncore_base_scoreboard)

    extern function new(string name="ncore_base_scoreboard", uvm_component parent=null);
    extern function void build_phase(uvm_phase phase);
    extern task run_phase(uvm_phase phase);
    extern function void extract_phase( uvm_phase phase ); 
    extern function void check_phase( uvm_phase phase );
    extern function void report_phase( uvm_phase phase ); 
    extern function void final_phase( uvm_phase phase ); 

endclass: ncore_base_scoreboard


//******************************************************************************
// Function : new
// Purpose  : 
//******************************************************************************
function ncore_base_scoreboard::new(string name="ncore_base_scoreboard", uvm_component parent=null);
    super.new(name, parent);
endfunction: new

//******************************************************************************
// Function : build_phase
// Purpose  : 
//******************************************************************************
function void ncore_base_scoreboard::build_phase(uvm_phase phase);
endfunction: build_phase

//******************************************************************************
// Function : run_phase
// Purpose  : 
//******************************************************************************
task ncore_base_scoreboard::run_phase(uvm_phase phase);
    `uvm_info("ncore_base_scoreboard Run_Phase ",$sformatf(" ----- Start ---- "), UVM_NONE);
endtask : run_phase

//******************************************************************************
// Function : extract_phase
// Purpose  : 
//******************************************************************************
function void ncore_base_scoreboard::extract_phase( uvm_phase phase );
    super.extract_phase(phase);
endfunction : extract_phase

//******************************************************************************
// Function : check_phase
// Purpose  : 
//******************************************************************************
function void ncore_base_scoreboard::check_phase( uvm_phase phase );
    super.check_phase(phase);
    `uvm_info("ncore_base_scoreboard Check_Phase ",$sformatf(" ----- "), UVM_NONE);
endfunction : check_phase

//******************************************************************************
// Function : report_phase
// Purpose  : 
//******************************************************************************
function void ncore_base_scoreboard::report_phase( uvm_phase phase );
    super.report_phase(phase);
    `uvm_info("ncore_base_scoreboard Report Phase ", $sformatf(" ----- "), UVM_DEBUG); 
endfunction : report_phase

//******************************************************************************
// Function : final_phase
// Purpose  : 
//******************************************************************************
 function void ncore_base_scoreboard::final_phase( uvm_phase phase ); 
    super.final_phase(phase);
 endfunction  : final_phase
