/*
 *creating a stand alone testcase as testing for the features
 *related to unit duplication is done using force mechanism.
 */
class resiliency_unitduplication_test extends bring_up_test;

  `uvm_component_utils(resiliency_unitduplication_test)

<% if(obj.testBench == 'io_aiu') { %>
`ifndef VCS
  event raise_obj_for_resiliency_test;
  event drop_obj_for_resiliency_test;
`else // `ifndef VCS
  uvm_event raise_obj_for_resiliency_test;
  uvm_event drop_obj_for_resiliency_test;
`endif // `ifndef VCS
<% } else {%>
  event raise_obj_for_resiliency_test;
  event drop_obj_for_resiliency_test;
<% } %>

  function new(string name = "resiliency_unitduplication_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction : new

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    // m_env_cfg.has_scoreboard = 0;
  endfunction : build_phase

  virtual task run_phase(uvm_phase phase);

<% if(obj.testBench == 'io_aiu') { %>
`ifndef VCS
    if(!uvm_config_db#(event)::get(this, "", "raise_obj_for_resiliency_test", raise_obj_for_resiliency_test)) begin
      `uvm_error( "dii_test run_phase", "raise_obj_for_resiliency_test event not found" )
    end

    if(!uvm_config_db#(event)::get(this, "", "drop_obj_for_resiliency_test", drop_obj_for_resiliency_test)) begin
      `uvm_error( "dii_test run_phase", "drop_obj_for_resiliency_test event not found" )
    end
`else // `ifndef VCS
    if(!uvm_config_db#(uvm_event)::get(this, "", "raise_obj_for_resiliency_test", raise_obj_for_resiliency_test)) begin
      `uvm_error( "dii_test run_phase", "raise_obj_for_resiliency_test event not found" )
    end

    if(!uvm_config_db#(uvm_event)::get(this, "", "drop_obj_for_resiliency_test", drop_obj_for_resiliency_test)) begin
      `uvm_error( "dii_test run_phase", "drop_obj_for_resiliency_test event not found" )
    end
`endif // `ifndef VCS
<% } else {%>
    if(!uvm_config_db#(event)::get(this, "", "raise_obj_for_resiliency_test", raise_obj_for_resiliency_test)) begin
      `uvm_error( "dii_test run_phase", "raise_obj_for_resiliency_test event not found" )
    end

    if(!uvm_config_db#(event)::get(this, "", "drop_obj_for_resiliency_test", drop_obj_for_resiliency_test)) begin
      `uvm_error( "dii_test run_phase", "drop_obj_for_resiliency_test event not found" )
    end
<% } %>

    phase.raise_objection(this, $sformatf("raise_objection from{%0s} in phase{%0s}",this.get_name(), phase.get_domain_name()));
    fork
      begin
        `uvm_info("run_main", "Waiting for random time units 2us", UVM_NONE)
        #2us;
      end
      begin
         `uvm_info("run_main", "waiting for raise_obj_for_resiliency_test event to trigger",UVM_NONE)
          <% if(obj.testBench == 'io_aiu') { %>
         `ifndef VCS
         @raise_obj_for_resiliency_test;
         `else // `ifndef VCS
         raise_obj_for_resiliency_test.wait_trigger();
         `endif // `ifndef VCS
         <% } else {%>
         @raise_obj_for_resiliency_test;
         <% } %>
         `uvm_info("run_main", "waiting done for raise_obj_for_resiliency_test event to trigger",UVM_NONE)
         phase.raise_objection(this, "raising objection for resiliency test");
 
         `uvm_info("run_main", "waiting for drop_obj_for_resiliency_test event to trigger",UVM_NONE)
          <% if(obj.testBench == 'io_aiu') { %>
         `ifndef VCS
         @drop_obj_for_resiliency_test;
         `else // `ifndef VCS
         drop_obj_for_resiliency_test.wait_trigger();
         `endif // `ifndef VCS
         <% } else {%>
         @drop_obj_for_resiliency_test;
         <% } %>
         `uvm_info("run_main", "waiting done for drop_obj_for_resiliency_test event to trigger",UVM_NONE)
         phase.drop_objection(this, "dropping resiliency test objection");
      end
    join
    phase.drop_objection(this, $sformatf("drop_objection from{%0s} in phase{%0s}",this.get_name(), phase.get_domain_name()));

  endtask : run_phase

  // avoiding any logic in the base class for the clean-up phase
  virtual function void pre_abort();
  endfunction
  virtual function void extract_phase(uvm_phase phase);
  endfunction
  virtual function void check_phase(uvm_phase phase);
  endfunction
  virtual function void report_phase(uvm_phase phase);
  endfunction

endclass : resiliency_unitduplication_test
