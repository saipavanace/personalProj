///////////////////////////////////////////////////////////////////////////////
//
// DII Environment
//
////////////////////////////////////////////////////////////////////////////////
<% if(obj.testBench == "dii" || obj.testBench == "cust_tb") { %> 
import <%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>_concerto_register_map_pkg::*;
<% } %> 

class dii_env extends uvm_env;

  `uvm_component_param_utils(dii_env)

    dii_env_config                   m_env_cfg;

    smi_agent m_smi_agent ;
    axi_slave_agent m_axi_slave_agent ;
    `ifndef USE_VIP_SNPS_APB
    apb_agent     m_apb_agent ;
    `endif
    dii_rtl_agent m_dii_rtl_agent ;

    q_chnl_agent  m_q_chnl_agent;
<% if(!obj.CUSTOMER_ENV) { %>
    trace_debug_scb      m_trace_debug_scb;
    dii_scoreboard       m_scb;
<% } %>

<% if(obj.testBench == "dii" || obj.testBench == "cust_tb") { %> 
   <%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>_concerto_register_map_pkg::ral_sys_ncore m_regs;
<%} else if(obj.testBench == "fsys" || obj.testBench == "emu") { %>
   concerto_register_map_pkg::ral_sys_ncore m_regs;
<% } %>


    uvm_event         system_quiesce;
    uvm_event         system_unquiesce;

   uvm_event         injectSingleErrRtt;
   uvm_event         injectDoubleErrRtt;
   uvm_event         checkCELR;
   uvm_event         checkUELR;

   int time_bw_Q_chnl_req;
<% if(obj.testBench=="dii") { %>
  `ifdef USE_VIP_SNPS
  // AMBA System ENV 
   svt_amba_system_env   amba_system_env;
  `endif // !`ifdef USE_VIP_SNPS
<% } %>  
    //-------------------------------------------------------------------------------------
  /** Class Constructor */
   function new (string name="dii_env", uvm_component parent=null);
      super.new (name, parent);
<% if(obj.testBench=='dii') { %>
       system_quiesce = new("system_quiesce");
       system_unquiesce = new("system_unquiesce");
<% } %>
<% if(obj.testBench == "dii" || obj.testBench == "cust_tb") { %>
      m_regs = <%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>_concerto_register_map_pkg::ral_sys_ncore::type_id::create("m_regs",this);
      m_regs.build();
      m_regs.lock_model();
      uvm_config_db #(<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>_concerto_register_map_pkg::ral_sys_ncore)::set(null,"","m_regs",m_regs);
<% } else if (obj.testBench == "fsys") { %>
      if(!(uvm_config_db #(concerto_register_map_pkg::ral_sys_ncore)::get(null,"","m_regs",m_regs))) `uvm_fatal( get_name(), "RAL m_regs not found for fsys");
      
<% } %>

   endfunction

    //-------------------------------------------------------------------------------------
  /** Build the System ENV */
   virtual function void build_phase(uvm_phase phase);
      `uvm_info("build_phase", "Entered...",UVM_LOW)

      super.build_phase(phase);

    
    ///////////////////////////////////////////////////////////////////////////////
    //
    // create env configs
    //
    ///////////////////////////////////////////////////////////////////////////////


      //pick toplevel config created in testcase 
      if (
            ! 
            uvm_config_db#(dii_env_config)::get(
                .cntxt( this ),
                .inst_name( "" ),
                .field_name( "dii_env_config" ),
                .value( m_env_cfg ) 
           ) 
      ) 
      begin
        `uvm_fatal( get_name(), "dii_env_config not found" )
      end


       //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
       //put configs where each dv component will look for them
       if (! m_env_cfg.m_smi_agent_cfg) `uvm_fatal( get_name(), "m_env_cfg.m_smi_agent_cfg not found" )
       uvm_config_db#(smi_agent_config )::set(.cntxt( this ),
           .inst_name( "m_smi_agent" ),
           .field_name( "smi_agent_config" ),
           .value( m_env_cfg.m_smi_agent_cfg));

       if (! m_env_cfg.m_axi_slave_agent_cfg) `uvm_fatal( get_name(), "m_env_cfg.m_axi_slave_agent_cfg not found" )
       uvm_config_db#(axi_agent_config )::set(.cntxt( this ),
           .inst_name( "m_axi_slave_agent" ),
           .field_name( "axi_slave_agent_config" ),
           .value( m_env_cfg.m_axi_slave_agent_cfg ));

       <% if (obj.testBench == 'dii') { %>
        `ifndef USE_VIP_SNPS_APB
           if (! m_env_cfg.m_apb_agent_cfg) `uvm_fatal( get_name(), "m_env_cfg.m_apb_agent_cfg not found" )
          `endif  
           if (! m_env_cfg.m_q_chnl_agent_cfg) `uvm_fatal( get_name(), "m_env_cfg.m_q_chnl_agent_cfg not found" )
       <% } %>
       `ifndef USE_VIP_SNPS_APB
       uvm_config_db#(apb_agent_config )::set(.cntxt( this ),
           .inst_name( "m_apb_agent" ),
           .field_name( "apb_agent_config" ),
           .value( m_env_cfg.m_apb_agent_cfg ));
        `endif  
       uvm_config_db#(q_chnl_agent_config )::set(.cntxt( this ),
           .inst_name( "m_q_chnl_agent" ),
           .field_name( "q_chnl_agent_config" ),
           .value( m_env_cfg.m_q_chnl_agent_cfg ));

       <% if (obj.testBench == 'dii') { %>
       m_env_cfg.m_q_chnl_agent_cfg.time_bw_Q_chnl_req = time_bw_Q_chnl_req;
       <% } %>

       if (! m_env_cfg.m_dii_rtl_agent_cfg) `uvm_fatal( get_name(), "m_env_cfg.m_dii_rtl_agent_cfg not found" )
       uvm_config_db#(dii_rtl_agent_config )::set(.cntxt( this ),
           .inst_name( "m_dii_rtl_agent" ),
           .field_name( "dii_rtl_agent_config" ),
           .value( m_env_cfg.m_dii_rtl_agent_cfg ));
        
        //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        //construct dv components
        m_smi_agent  = smi_agent::type_id::create("m_smi_agent",this);
        m_axi_slave_agent = axi_slave_agent::type_id::create("m_axi_slave_agent", this);

        <% if (obj.testBench == 'dii') { %>
          `ifndef USE_VIP_SNPS_APB
            m_apb_agent = apb_agent::type_id::create("m_apb_agent", this);
          `endif  
            m_q_chnl_agent = q_chnl_agent::type_id::create("m_q_chnl_agent", this);
        <% } %>

<% if(!obj.CUSTOMER_ENV) { %>
        if(m_env_cfg.has_scoreboard) begin
            m_dii_rtl_agent = dii_rtl_agent::type_id::create("m_dii_rtl_agent", this);
            m_scb = dii_scoreboard::type_id::create("m_scb", this);
            if(m_env_cfg.has_tcap_scb) begin
              m_trace_debug_scb = trace_debug_scb::type_id::create("m_trace_debug_scb", this);
            end
            uvm_config_db#(dii_scoreboard)::set(uvm_root::get(), 
                                  "*", 
                                  "dii_scb", 
                                  m_scb);
        end
<% } %>
 <% if(obj.testBench=="emu") { %>
    uvm_config_db #(virtual mgc_axi_master_if)::set(this,
    "*", "mgc_ace_m_if_caiu0", m_env_cfg.mgc_ace_vif);
        `uvm_info("build_phase", "Exiting...", UVM_LOW)
 <% } %>  

<% if(obj.testBench=="dii") { %>
 `ifdef USE_VIP_SNPS

  //if (!uvm_config_db#(dii_amba_env_config)::get(this, "", "m_dii_amba_env_config", dii_axi_m_dii_amba_env_configenv_config)) begin
  //  m_dii_amba_env_config = dii_amba_env_config::type_id::create("m_dii_amba_env_config");
  //  m_dii_amba_env_config.set_amba_sys_config();
  //end
//
  //  // Apply the configuration to the AMBA System ENV 
  //uvm_config_db#(svt_amba_system_configuration)::set(this, "amba_system_env", "cfg", m_dii_amba_env_config);

    // Construct the AMBA system ENV 
  amba_system_env = svt_amba_system_env::type_id::create("amba_system_env", this);

  `endif // !`ifdef USE_VIP_SNPS        
<% } %>  

  `uvm_info("build_phase", "Exiting...", UVM_LOW)

    endfunction : build_phase


    ////////////////////////////////////////////////////////////////////////////////////
    //connect phase
    ////////////////////////////////////////////////////////////////////////////////////

  /** Connect the AXI System ENV */
  virtual function void connect_phase(uvm_phase phase);
    //`uvm_info("connect_phase", "Entered...",UVM_LOW)
    super.connect_phase(phase);

<% if(!obj.CUSTOMER_ENV) { %>
    if(m_env_cfg.has_scoreboard) begin
      <%for (var i = 0; i < obj.nSmiRx; i++) { %>
      m_smi_agent.m_smi<%=i%>_rx_port_ap.connect(m_scb.analysis_smi);
      if(m_env_cfg.has_tcap_scb) begin
        <% if (i == obj.nSmiRx-1) { %>
        m_smi_agent.m_smi<%=i%>_rx_ndp_ap.connect(m_trace_debug_scb.analysis_smi_dnrx_ndp_only_port);
        <% } %>
        m_smi_agent.m_smi<%=i%>_rx_port_ap.connect(m_trace_debug_scb.analysis_smi<%=i%>_rx_port);
      end
      <% } %>
      
   
   
    <%for (var i = 0; i < obj.nSmiTx; i++) { %>
      m_smi_agent.m_smi<%=i%>_tx_port_ap.connect(m_scb.analysis_smi);
      if(m_env_cfg.has_tcap_scb) begin
      <% if (i == obj.nSmiTx-1) { %>
      m_smi_agent.m_smi<%=i%>_tx_ndp_ap.connect(m_trace_debug_scb.analysis_smi_dntx_ndp_only_port);
      <% } %>
      m_smi_agent.m_smi<%=i%>_tx_port_ap.connect(m_trace_debug_scb.analysis_smi<%=i%>_tx_port);
      end
      <% } %>
      
      m_axi_slave_agent.read_addr_ap.connect(m_scb.analysis_read_addr_port);
      m_axi_slave_agent.read_data_ap.connect(m_scb.analysis_read_data_port);
      m_axi_slave_agent.write_addr_ap.connect(m_scb.analysis_write_addr_port);
      m_axi_slave_agent.write_data_ap.connect(m_scb.analysis_write_data_port);
      m_axi_slave_agent.write_resp_ap.connect(m_scb.analysis_write_resp_port);

      m_dii_rtl_agent.axi2cmd_rtt_ap.connect(m_scb.analysis_axi2cmd_rtt_port);
      m_dii_rtl_agent.axi2cmd_wtt_ap.connect(m_scb.analysis_axi2cmd_wtt_port);
      m_dii_rtl_agent.evt_ap.connect(m_scb.analysis_evt_port);

      <% if (obj.testBench == 'dii') { %>
      m_q_chnl_agent.q_chnl_ap.connect(m_scb.analysis_q_chnl_port);
    <% } %>
  end
<% } %>
<% if (obj.testBench == 'dii' || obj.testBench == 'cust_tb') { %>
    m_regs.default_map.set_auto_predict(1);
    `ifndef USE_VIP_SNPS_APB
    m_regs.default_map.set_sequencer(.sequencer(m_apb_agent.m_apb_sequencer),
                                     .adapter(m_apb_agent.m_apb_reg_adapter));
    `endif
    
   <% } %>

endfunction


   virtual function void report_phase(uvm_phase phase);
      //`uvm_info("connect_phase", "Entered...",UVM_LOW)
      super.report_phase(phase);
   endfunction // report_phase

endclass

