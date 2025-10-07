`ifndef DCE_GRAPH_TEST
`define DCE_GRAPH_TEST

////////////////////////////////////////////////////////////////////////////////
//
// DCE Graph Test
//
////////////////////////////////////////////////////////////////////////////////
class dce_graph_test extends dce_test_base;

  `uvm_component_utils(dce_graph_test)

  extern function new(string name = "dce_graph_test", uvm_component parent = null);
  extern virtual function void build_phase(uvm_phase phase);
  extern virtual task          main_phase(uvm_phase phase);
  extern virtual task          run_main(uvm_phase phase);
  extern virtual function void run_report(uvm_phase phase);

endclass: dce_graph_test

//------------------------------------------------------------------------------
// Constructor
//------------------------------------------------------------------------------
function dce_graph_test::new(string name = "dce_graph_test", uvm_component parent = null);
  super.new(name, parent);
endfunction : new

//------------------------------------------------------------------------------
// Build Phase
//------------------------------------------------------------------------------
function void dce_graph_test::build_phase(uvm_phase phase);

  super.build_phase(phase);

endfunction : build_phase

//------------------------------------------------------------------------------
// Run Report
//------------------------------------------------------------------------------
function void dce_graph_test::run_report(uvm_phase phase);
  m_env.m_sb.m_csm.printStateCoverage(m_env.m_gen.unique_state_transitions);
  $display("For AIUs=%0d Concerto configuration, max unique_state_transitions=%0d", <%=obj.BlockId + '_con'%>::SYS_nSysAIUs, m_env.m_gen.unique_state_transitions);
  $display("For AIUs=%0d Concerto configuration, max        unique_test_cases=%0d", <%=obj.BlockId + '_con'%>::SYS_nSysAIUs, m_env.m_gen.unique_test_cases);
  $display("For AIUs=%0d Concerto configuration, max             legal states=%0d", <%=obj.BlockId + '_con'%>::SYS_nSysAIUs, m_env.m_gen.statesList.size());
endfunction : run_report

//------------------------------------------------------------------------------
// Main Phase
//------------------------------------------------------------------------------
task dce_graph_test::main_phase(uvm_phase phase);
  fork
    run_main(phase);
    run_watchdog_timer(phase);
  join
endtask : main_phase

task dce_graph_test::run_main(uvm_phase phase);
  uvm_objection main_done;
  dce_graph_seq  test_seq = dce_graph_seq::type_id::create("test_seq");

<% if (obj.BLK_SNPS_OCP_VIP) { %>
  ocp_master_directed_sequence  csr_seq = ocp_master_directed_sequence::type_id::create("csr_seq");
  csr_seq.sequence_length = 32;
<% } %>

  test_seq.k_num_addr         = k_num_addr;
  test_seq.k_num_cmd          = k_num_cmd;
  test_seq.k_security         = k_security;
  test_seq.k_priority         = k_priority;
  test_seq.m_csm = m_env.m_sb.m_csm;
  test_seq.m_gen = m_env.m_gen;

  phase.raise_objection(this, "Start dce_graph_test run phase");

<% if (obj.BLK_SNPS_OCP_VIP) { %>
  csr_seq.start(m_env.ocp_master_agent.df_sequencer);
<% } %>

  test_seq.m_master_sequencer = m_env.m_sfi_master_agent.m_master_sequencer;
  test_seq.m_slave_sequencer  = m_env.m_sfi_slave_agent.m_slave_sequencer;
  test_seq.start(null);

  main_done = phase.get_objection();
  main_done.set_drain_time(null, 1us);

  phase.drop_objection(this, "Finish dce_graph_test run phase");

endtask : run_main

////////////////////////////////////////////////////////////////////////////////
//
// DCE Graph Search Test
//
////////////////////////////////////////////////////////////////////////////////
class dce_graph_search_test extends dce_graph_test;

  `uvm_component_utils(dce_graph_search_test)

  extern function new(string name = "dce_graph_search_test", uvm_component parent = null);
  extern virtual task          run_main(uvm_phase phase);

endclass: dce_graph_search_test

function dce_graph_search_test::new(string name = "dce_graph_search_test", uvm_component parent = null);
  super.new(name, parent);
endfunction : new

task dce_graph_search_test::run_main(uvm_phase phase);
  uvm_objection main_done;
  dce_graph_search_seq  test_seq = dce_graph_search_seq::type_id::create("test_seq");

<% if (obj.BLK_SNPS_OCP_VIP) { %>
  ocp_master_directed_sequence  csr_seq = ocp_master_directed_sequence::type_id::create("csr_seq");
  csr_seq.sequence_length = 32;
<% } %>

  test_seq.k_num_addr         = k_num_addr;
  test_seq.k_num_cmd          = k_num_cmd;
  test_seq.k_security         = k_security;
  test_seq.k_priority         = k_priority;
  test_seq.m_csm = m_env.m_sb.m_csm;
  test_seq.m_gen = m_env.m_gen;

  phase.raise_objection(this, "Start dce_graph_search_test run phase");

<% if (obj.BLK_SNPS_OCP_VIP) { %>
  csr_seq.start(m_env.ocp_master_agent.df_sequencer);
<% } %>

  test_seq.m_master_sequencer = m_env.m_sfi_master_agent.m_master_sequencer;
  test_seq.m_slave_sequencer  = m_env.m_sfi_slave_agent.m_slave_sequencer;
  test_seq.start(null);

  main_done = phase.get_objection();
  main_done.set_drain_time(null, 1us);

  phase.drop_objection(this, "Finish dce_graph_search_test run phase");

endtask : run_main

////////////////////////////////////////////////////////////////////////////////
//
// DCE Graph List Test
//
////////////////////////////////////////////////////////////////////////////////
class dce_graph_list_test extends dce_graph_test;

  `uvm_component_utils(dce_graph_list_test)

  extern function new(string name = "dce_graph_list_test", uvm_component parent = null);
  extern virtual task          run_main(uvm_phase phase);

endclass: dce_graph_list_test

function dce_graph_list_test::new(string name = "dce_graph_list_test", uvm_component parent = null);
  super.new(name, parent);
endfunction : new

task dce_graph_list_test::run_main(uvm_phase phase);
  uvm_objection main_done;
  dce_graph_list_seq  test_seq = dce_graph_list_seq::type_id::create("test_seq");

<% if (obj.BLK_SNPS_OCP_VIP) { %>
  ocp_master_directed_sequence  csr_seq = ocp_master_directed_sequence::type_id::create("csr_seq");
  csr_seq.sequence_length = 32;
<% } %>

  test_seq.k_num_addr         = k_num_addr;
  test_seq.k_num_cmd          = k_num_cmd;
  test_seq.k_security         = k_security;
  test_seq.k_priority         = k_priority;
  test_seq.m_csm = m_env.m_sb.m_csm;
  test_seq.m_gen = m_env.m_gen;

  phase.raise_objection(this, "Start dce_graph_list_test run phase");

<% if (obj.BLK_SNPS_OCP_VIP) { %>
  csr_seq.start(m_env.ocp_master_agent.df_sequencer);
<% } %>

  test_seq.m_master_sequencer = m_env.m_sfi_master_agent.m_master_sequencer;
  test_seq.m_slave_sequencer  = m_env.m_sfi_slave_agent.m_slave_sequencer;
  test_seq.start(null);

  main_done = phase.get_objection();
  main_done.set_drain_time(null, 1us);

  phase.drop_objection(this, "Finish dce_graph_list_test run phase");

endtask : run_main

////////////////////////////////////////////////////////////////////////////////

`endif // DCE_GRAPH_TEST
