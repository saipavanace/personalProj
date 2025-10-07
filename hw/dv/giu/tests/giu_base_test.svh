//--------------------------------------------------------------------------------------
// Copyright(C) 2014-2025 Arteris, Inc. and its applicable subsidiaries.
// All rights reserved.
//
// Disclaimer: This release is not provided nor intended for any chip implementations, 
//             tapeouts, or other features of production releases. 
//
// These files and associated documentation is proprietary and confidential to
// Arteris, Inc. and its applicable subsidiaries. The files and documentation
// may only be used pursuant to the terms and conditions of a signed written
// license agreement with Arteris, Inc. or one of its subsidiaries.
// All other use, reproduction, modification, or distribution of the information
// contained in the files or the associated documentation is strictly prohibited.
// This product and its technology is protected by patents and other forms of 
// intellectual property protection.
//
// License: Arteris Confidential
<%// Project: GIU
// Product: Ncore 3.8
// Author: esherk
// %> 
//--------------------------------------------------------------------------------------

//Display outstanding objections upon hbfail.
class timeout_catcher extends uvm_report_catcher;
    uvm_phase phase;
    `uvm_object_utils(timeout_catcher)

    <% if(obj.testBench == 'giu') { %>
    function new (string name="timeout_catcher",uvm_component parent=null);
        super.new (name);
    endfunction : new
     <% }  %>

    function action_e catch();
        if(get_severity() == UVM_FATAL && get_id() == "HBFAIL") begin
            uvm_objection obj = phase.get_objection();
            `uvm_error("HBFAIL", $psprintf("Heartbeat failure! Objections:"));
            obj.display_objections();
        end
        return THROW;
    endfunction : catch

endclass : timeout_catcher

<% if(obj.testBench == 'giu') { %>
class my_report_server extends uvm_default_report_server;

    extern function new(string name = "my_report_server");
    extern virtual function void report_summarize(UVM_FILE file = 0);
   
endclass

function my_report_server::new(string name = "my_report_server");
    super.new();
endfunction : new
 
function void my_report_server::report_summarize(UVM_FILE file = 0);
    uvm_report_server svr;
    string id;
    string name;
    string output_str;
    string q[$],q2[$];
    int m_max_quit_count,m_quit_count;
    int m_severity_count[uvm_severity];
    int m_id_count[string];
    bit enable_report_id_count_summary =1 ;
    uvm_severity q1[$];

    svr = uvm_report_server::get_server();
    m_max_quit_count = get_max_quit_count();
    m_quit_count = get_quit_count();

    svr.get_id_set(q2);
    foreach(q2[s]) begin
        m_id_count[q2[s]] = svr.get_id_count(q2[s]);
    end

    svr.get_severity_set(q1);
    foreach(q1[s]) begin
        m_severity_count[q1[s]] = svr.get_severity_count(q1[s]);
    end

    if ( m_severity_count[UVM_ERROR] > 0 || m_severity_count[UVM_FATAL] >0 )
        `uvm_info("EOT", "\n ============ \n UVM FAILED!\n ============", UVM_NONE)
    else
        `uvm_info("EOT", "\n ============ \n UVM PASSED!\n ============", UVM_NONE)

    uvm_report_catcher::summarize();
    q.push_back("\n--- UVM Report Summary ---\n\n");

    if(m_max_quit_count != 0) begin
        if ( m_quit_count >= m_max_quit_count )
            q.push_back("Quit count reached!\n");
            q.push_back($sformatf("Quit count : %5d of %5d\n",m_quit_count, m_max_quit_count));
    end

    q.push_back("** Report counts by severity\n");
    foreach(m_severity_count[s]) begin
        q.push_back($sformatf("%s :%5d\n", s.name(), m_severity_count[s]));
    end

    if (enable_report_id_count_summary) begin
        q.push_back("** Report counts by id\n");
        foreach(m_id_count[id])
            q.push_back($sformatf("[%s] %5d\n", id, m_id_count[id]));
    end

    `uvm_info("UVM/REPORT/SERVER",`UVM_STRING_QUEUE_STREAMING_PACK(q),UVM_NONE)

endfunction : report_summarize
<% }  %>

class giu_base_test extends uvm_test;

    uvm_cmdline_processor clp = uvm_cmdline_processor::get_inst();
    extern function new (string name = "giu_base_test", uvm_component parent = null);
    extern function void start_of_simulation_phase(uvm_phase phase);
    extern function bit plusarg_get_str(ref string field, input string name);

endclass : giu_base_test

function giu_base_test::new(string name = "giu_base_test", uvm_component parent = null);
    super.new(name,parent);
endfunction : new

function bit giu_base_test::plusarg_get_str(ref string field, input string name);
    string arg_value;
    // 
    if (clp.get_arg_value({"+",name,"="}, arg_value)) begin
        field = arg_value;
        `uvm_info("", $sformatf("plusarg got \t%s \t== \t%p",name, field), UVM_MEDIUM);
        return 1;
    end
    else
        return 0;
endfunction : plusarg_get_str

function void giu_base_test::start_of_simulation_phase(uvm_phase phase);
    <% if(obj.testBench == 'giu') { %>
    my_report_server my_server = new();
    uvm_report_server::set_server( my_server );
    <% } %>
    super.start_of_simulation_phase(phase);

endfunction : start_of_simulation_phase
