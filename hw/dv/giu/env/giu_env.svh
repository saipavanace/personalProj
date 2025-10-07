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

// import <%=obj.BlockId%>_concerto_register_map_pkg::*;

class giu_env extends uvm_env;
  `uvm_component_utils(giu_env)

  smi_agent m_smi_agent;
  apb_agent m_apb_agent ;
  q_chnl_agent  m_q_chnl_agent;
  giu_sb m_giu_sb;
  giu_env_config m_env_cfg;
  <%=obj.BlockId%>_clock_counter_monitor m_clock_counter_mon; 

  <% if(obj.testBench == 'giu' || obj.testBench == 'cust_tb') { %>
  <%=obj.BlockId%>_concerto_register_map_pkg:: ral_sys_ncore m_regs;

  <% } else if(obj.testBench == 'fsys' || obj.testBench == 'emu' ) { %>
  concerto_register_map_pkg::ral_sys_ncore m_regs;
  <% } %>

  int time_bw_Q_chnl_req;

  function new(string name = "giu_env", uvm_component parent);
    super.new(name, parent);
  endfunction // new

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    if(!uvm_config_db#(giu_env_config)::get(
       .cntxt(this),
       .inst_name(""),
       .field_name("giu_env_config"),
       .value(m_env_cfg)
       )
      ) begin
      `uvm_fatal("giu_env", "giu_env_config not found")
    end

       <% if (obj.testBench == 'giu') { %>
    if (! m_env_cfg.m_apb_agent_cfg) `uvm_fatal( get_name(), "m_env_cfg.m_apb_agent_cfg not found" )
       <% } %>
       uvm_config_db#(apb_agent_config )::set(.cntxt( this ),
           .inst_name( "m_apb_agent" ),
           .field_name( "apb_agent_config" ),
           .value( m_env_cfg.m_apb_agent_cfg ));

   <% if (obj.testBench == 'giu') { %>
   if (! m_env_cfg.m_q_chnl_agent_cfg) `uvm_fatal( get_name(), "m_env_cfg.m_q_chnl_agent_cfg not found" )
   uvm_config_db#(q_chnl_agent_config )::set(.cntxt( this ),
       .inst_name( "m_q_chnl_agent" ),
       .field_name( "q_chnl_agent_config" ),
       .value( m_env_cfg.m_q_chnl_agent_cfg ));

   m_env_cfg.m_q_chnl_agent_cfg.time_bw_Q_chnl_req = time_bw_Q_chnl_req;
   m_q_chnl_agent = q_chnl_agent::type_id::create("m_q_chnl_agent", this);
   <% } %>

    m_smi_agent = smi_agent::type_id::create("m_smi_agent", this);
    m_smi_agent.m_cfg = m_env_cfg.m_smi_agent_cfg;
    <% if ((obj.testBench == 'giu') || (obj.testBench == 'fsys') || (obj.testBench == 'cust_tb')) { %>
        m_apb_agent = apb_agent::type_id::create("m_apb_agent", this);
    <% } %>

    m_clock_counter_mon = <%=obj.BlockId%>_clock_counter_monitor::type_id::create("m_clock_counter_mon", this);
    m_clock_counter_mon.m_vif = m_env_cfg.m_clock_counter_vif;
     
    if(m_env_cfg.has_sb) begin
      m_giu_sb = giu_sb::type_id::create("m_giu_sb", this);
    end

   <% if(obj.testBench == 'giu' || obj.testBench == 'cust_tb') { %>
   m_regs = <%=obj.BlockId%>_concerto_register_map_pkg:: ral_sys_ncore::type_id::create("m_regs", this);
   <% } else if(obj.testBench == 'fsys') { %>
    if(!(uvm_config_db #(concerto_register_map_pkg::ral_sys_ncore)::get(null, "","m_regs",m_regs)))  `uvm_fatal("Missing in DB::", "RAL m_regs not found");
    //m_regs = concerto_register_map_pkg::ral_sys_ncore::type_id::create("m_regs", this);
   <% } %>
   <% if (obj.testBench == 'giu' || obj.testBench == 'cust_tb') { %>
    m_regs.build();
    m_regs.lock_model();
     uvm_config_db #(<%=obj.BlockId%>_concerto_register_map_pkg:: ral_sys_ncore)::set(null, "", "m_regs", m_regs);
    <% } %>

  endfunction // build_phase

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    if(m_env_cfg.has_sb) begin
<% for (var i = 0; i < obj.nSmiRx; i++) { %>
      m_smi_agent.m_smi<%=i%>_tx_port_ap.connect(m_giu_sb.smi_port);
<% } %>
<% for (var i = 0; i < obj.nSmiTx; i++) { %>
      m_smi_agent.m_smi<%=i%>_rx_port_ap.connect(m_giu_sb.smi_port);
<% } %>
//      m_smi_agent.m_smi2_tx_every_beat_port_ap.connect(m_giu_sb.m_smi2_tx_every_beat_port);
   <% if (obj.testBench == 'giu') { %>
     m_q_chnl_agent.q_chnl_ap.connect(m_giu_sb.q_chnl_port);
   <% } %>

    m_clock_counter_mon.clock_counter_ap.connect(m_giu_sb.m_clock_counter_port);
    end

   <% if (obj.testBench == 'giu' || obj.testBench == 'cust_tb') { %>
    m_regs.default_map.set_auto_predict(1);
    m_regs.default_map.set_sequencer(.sequencer(m_apb_agent.m_apb_sequencer),
                                     .adapter(m_apb_agent.m_apb_reg_adapter));
   <% } %>

  endfunction // connect_phase

    // function void report_phase(uvm_phase phase);
    //     super.report_phase(phase);
    //     uvm_report_server urs;
    //     int uvm_err_cnt, uvm_fatal_cnt;
    
    //     urs = uvm_report_server::get_server();
    //     uvm_err_cnt = urs.get_severity_count(UVM_ERROR);
    //     uvm_fatal_cnt = urs.get_severity_count(UVM_FATAL);

    //     `uvm_info(uvm_err_cnt,"ERRORS",UVM_NONE)

    //     if((uvm_err_cnt != 0) || (uvm_fatal_cnt != 0))
    //         `uvm_info(name, "\n ============ \n UVM FAILED!\n ============", UVM_NONE)
    //     else
    //         `uvm_info(name, "\n ============ \n UVM PASSED!\n ============", UVM_NONE)
    // endfunction // report_phase

endclass // giu_env
