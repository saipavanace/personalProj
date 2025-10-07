////////////////////////////////////////////////////////////////////////////////
//
// DMI Environment
//
////////////////////////////////////////////////////////////////////////////////

//`include "axi_virtual_sequencer.sv"
//`include "dmi_agent.svh"
class dmi_env extends uvm_env;

  `uvm_component_param_utils(dmi_env)

   dmi_env_config         m_cfg;
   smi_agent              m_smi_agent;
 `ifdef ADDR_MGR
   addr_trans_mgr         m_addr_mgr;
 `endif

   <%=obj.BlockId%>_rtl_agent          m_dmi_rtl_agent;
   <%=obj.BlockId%>_tt_agent           m_dmi_tt_agent;
   <%=obj.BlockId%>_read_probe_agent    m_dmi_read_probe_agent;
   <%=obj.BlockId%>_write_probe_agent   m_dmi_write_probe_agent;

   q_chnl_agent  m_q_chnl_agent;

<% if(obj.useCmc) { %>
   ccp_agent           m_ccp_agent;
   ccp_scoreboard      m_scb;
<% } %>
<% if(obj.USE_VIP_SNPS) { %>
<% if(obj.testBench=='dmi') { %>
   svt_axi_system_env m_axi_system_env;
<% }} %>
   axi_slave_agent   m_axi_slave_agent;

<% if(obj.testBench=='dmi' && obj.Id == 0 || obj.testBench == 'cust_tb')  { %> 
   <%=obj.BlockId%>_concerto_register_map_pkg::ral_sys_ncore m_regs;
<%} else if(obj.testBench == 'fsys' || obj.testBench =='emu') { %>
   concerto_register_map_pkg::ral_sys_ncore m_regs;
<% } %>
   

<% if((obj.testBench=='dmi') && (obj.INHOUSE_APB_VIP)) { %>
<% if(obj.useCmc) { %>
   <%for( var i=0;i<obj.nTagBanks;i++){%>
uvm_event         injectSingleErrTag<%=i%>;
uvm_event         injectDoubleErrTag<%=i%>;
<% } %>
   <%for( var i=0;i<obj.nDataBanks;i++){%>
uvm_event         injectSingleErrData<%=i%>;
uvm_event         injectDoubleErrData<%=i%>;
<% } %>
<% } %>
   uvm_event      checkCELR;
   uvm_event      checkUELR;

<% } %>
<% if(obj.useCmc || obj.testBench=='dmi') { %>
   apb_agent                       m_apb_agent;
<% } %>

   int time_bw_Q_chnl_req;



/*`ifndef INHOUSE_AXI
   axi_slv_mem_modal  m_axi_mem_model;
`endif*/
<% if(!obj.CUSTOMER_ENV) { %>
      trace_debug_scb      m_trace_debug_scb;
      dmi_scoreboard       m_sb;
//      dmi_trace_generator  m_trc_gen;
<% } %>


  /** Class Constructor */
   function new (string name="dmi_env", uvm_component parent=null);
      super.new (name, parent);
   endfunction

  /** Build the System ENV */
   virtual function void build_phase(uvm_phase phase);
      `uvm_info("build_phase", "Entered...",UVM_LOW)

      super.build_phase(phase);


	//Initialise the address manager
  `ifdef ADDR_MGR
	m_addr_mgr = addr_trans_mgr::get_instance();
	m_addr_mgr.gen_memory_map();
  `endif

      if (!uvm_config_db#(dmi_env_config)::get
          (.cntxt( this ),
           .inst_name( "" ),
           .field_name( "dmi_env_config" ),
           .value( m_cfg ) ) ) begin
         `uvm_fatal( get_name(), "dmi_env_config not found" )
      end
<% if(obj.useCmc) { %>
    uvm_config_db#(ccp_agent_config )::set(.cntxt( this ),
                                           .inst_name( "*" ),
                                           .field_name( "ccp_agent_config" ),
                                           .value( m_cfg.ccp_agent_cfg));
    m_ccp_agent = ccp_agent::type_id::create("ccp_agent", this);
    if(m_cfg.ccp_agent_cfg.has_scoreboard) begin
        m_scb = ccp_scoreboard::type_id::create("m_scb", this);
    end
    uvm_config_db#(ccp_scoreboard)::set(uvm_root::get(), 
                                  "*", 
                                  "ccp_scb", 
                                  m_scb);
<% } %>
    uvm_config_db#(smi_agent_config )::set(.cntxt( this ),
                                           .inst_name( "*" ),
                                           .field_name( "smi_agent_config" ),
                                           .value( m_cfg.m_smi_agent_cfg));

    m_smi_agent  = smi_agent::type_id::create("m_smi_agent",this);


    uvm_config_db#(<%=obj.BlockId%>_rtl_agent_config )::set(.cntxt( this ),
                                           .inst_name( "*" ),
                                           .field_name( "m_<%=obj.BlockId%>_rtl_agent_config" ),
                                           .value( m_cfg.m_dmi_rtl_agent_cfg));

    m_dmi_rtl_agent  = <%=obj.BlockId%>_rtl_agent::type_id::create("m_dmi_rtl_agent",this);

    uvm_config_db#(<%=obj.BlockId%>_tt_agent_config )::set(.cntxt( this ),
                                           .inst_name( "*" ),
                                           .field_name( "m_<%=obj.BlockId%>_tt_agent_config" ),
                                           .value( m_cfg.m_dmi_tt_agent_cfg));

    m_dmi_tt_agent   = <%=obj.BlockId%>_tt_agent::type_id::create("m_dmi_tt_agent",this);

    uvm_config_db#(<%=obj.BlockId%>_read_probe_agent_config )::set(.cntxt( this ),
                                           .inst_name( "*" ),
                                           .field_name( "m_<%=obj.BlockId%>_read_probe_agent_config" ),
                                           .value( m_cfg.m_dmi_read_probe_agent_cfg));

    m_dmi_read_probe_agent  = <%=obj.BlockId%>_read_probe_agent::type_id::create("m_dmi_read_probe_agent",this);

    uvm_config_db#(<%=obj.BlockId%>_write_probe_agent_config )::set(.cntxt( this ),
                                           .inst_name( "*" ),
                                           .field_name( "m_<%=obj.BlockId%>_write_probe_agent_config" ),
                                           .value( m_cfg.m_dmi_write_probe_agent_cfg));

    m_dmi_write_probe_agent  = <%=obj.BlockId%>_write_probe_agent::type_id::create("m_dmi_write_probe_agent",this);

<% if(obj.USE_VIP_SNPS) { %>
<% if(obj.testBench=='dmi') { %>
      m_axi_system_env = svt_axi_system_env::type_id::create("m_axi_system_env",this);
      m_cfg.m_axi_slave_agent_cfg.active = UVM_PASSIVE; // Utilize inhouse monitors for uniform txn classes in env
<% }} %>
      uvm_config_db#(axi_agent_config )::set(.cntxt( this ),
                                             .inst_name( "m_axi_slave_agent" ),
                                             .field_name( "axi_slave_agent_config" ),
                                             .value( m_cfg.m_axi_slave_agent_cfg ));

      m_axi_slave_agent = axi_slave_agent::type_id::create("m_axi_slave_agent", this);
<% if(obj.testBench=="emu") { %>
    uvm_config_db #(virtual mgc_axi_master_if)::set(this,
    "*", "mgc_ace_m_if_caiu0", m_cfg.mgc_ace_vif);
      `uvm_info("build_phase", "Exiting...", UVM_LOW)
      <% } %> 

<% if(!obj.CUSTOMER_ENV) { %>
  if(m_cfg.has_scoreboard) begin
    m_sb = dmi_scoreboard::type_id::create("m_sb", this);
    if($test$plusargs("tcap_scb_en")) begin
      m_trace_debug_scb = trace_debug_scb::type_id::create("m_trace_debug_scb", this);
    end
  end
  <% if(obj.testBench == 'dmi') { %> 
  //    m_trc_gen = dmi_trace_generator::type_id::create("m_trc_gen",this);
  <% } %>
<% } %>
<% if((obj.testBench=='dmi' || obj.useCmc) && (obj.INHOUSE_APB_VIP)) { %>

      uvm_config_db#(apb_agent_config )::set(.cntxt( this ),
                                             .inst_name( "m_apb_agent" ),
                                             .field_name( "apb_agent_config" ),
                                             .value( m_cfg.m_apb_cfg ));

    m_apb_agent = apb_agent::type_id::create("m_apb_agent", this);
<% } %>

   <% if (obj.testBench == 'dmi') { %>
   if (! m_cfg.m_q_chnl_agent_cfg) `uvm_fatal( get_name(), "m_cfg.m_q_chnl_agent_cfg not found" )
   uvm_config_db#(q_chnl_agent_config )::set(.cntxt( this ),
       .inst_name( "m_q_chnl_agent" ),
       .field_name( "q_chnl_agent_config" ),
       .value( m_cfg.m_q_chnl_agent_cfg ));

   m_cfg.m_q_chnl_agent_cfg.time_bw_Q_chnl_req = time_bw_Q_chnl_req;
   m_q_chnl_agent = q_chnl_agent::type_id::create("m_q_chnl_agent", this);
   <% } %>

   <% if(obj.testBench=='dmi' && obj.Id==0 || obj.testBench == 'cust_tb') { %>
    m_regs = <%=obj.BlockId%>_concerto_register_map_pkg::ral_sys_ncore::type_id::create("ral_sys_ncore", this);
    m_regs.build();
    m_regs.lock_model();
<% } else if (obj.testBench == "fsys") { %>
      if(!(uvm_config_db #(concerto_register_map_pkg::ral_sys_ncore)::get(null,"","m_regs",m_regs))) `uvm_fatal( get_name(), "RAL m_regs not found for fsys");
    <%}%> 


<% if((obj.testBench=='dmi') && (obj.INHOUSE_APB_VIP)) { %>
<% if(obj.useCmc) { %>
   <%for( var i=0;i<obj.nTagBanks;i++){%>
     // if (!uvm_config_db#(uvm_event)::get( .cntxt(null),
     //                                 .inst_name( get_full_name()),
     //                                 .field_name( "injectSingleErrTag<%=i%>" ),
     //                                 .value( injectSingleErrTag<%=i%>))) begin
     //    `uvm_error("concerto_env", "Event injectSingleErrTag<%=i%> not found")
     // end
     // if (!uvm_config_db#(uvm_event)::get( .cntxt(null),
     //                                 .inst_name( get_full_name()),
     //                                 .field_name( "injectDoubleErrTag<%=i%>" ),
     //                                 .value( injectDoubleErrTag<%=i%>))) begin
     //    `uvm_error("concerto_env", "Event injectDoubleErrTag<%=i%> not found")
     // end
   <% } %>
   <%for( var i=0;i<obj.nDataBanks;i++){%>
     // if (!uvm_config_db#(uvm_event)::get( .cntxt(null),
     //                                 .inst_name( get_full_name()),
     //                                 .field_name( "injectSingleErrData<%=i%>" ),
     //                                 .value( injectSingleErrData<%=i%>))) begin
     //    `uvm_error("concerto_env", "Event injectSingleErrData<%=i%> not found")
     // end
     // if (!uvm_config_db#(uvm_event)::get( .cntxt(null),
     //                                 .inst_name( get_full_name()),
     //                                 .field_name( "injectDoubleErrData<%=i%>" ),
     //                                 .value( injectDoubleErrData<%=i%>))) begin
     //    `uvm_error("concerto_env", "Event injectDoubleErrData<%=i%> not found")
     // end
   <% } %>
 <% } %>

      if (!uvm_config_db#(uvm_event)::get( .cntxt(null),
                                      .inst_name( get_full_name()),
                                      .field_name( "checkCELR" ),
                                      .value( checkCELR ))) begin
         `uvm_error("concerto_env", "Event checkCELR not found")
      end

      if (!uvm_config_db#(uvm_event)::get( .cntxt(null),
                                      .inst_name( get_full_name()),
                                      .field_name( "checkUELR" ),
                                      .value( checkUELR ))) begin
         `uvm_error("concerto_env", "Event checkUELR not found")
      end

<% } %> 

      `uvm_info("build_phase", "Exiting...", UVM_LOW)
  endfunction

  /** Connect the AXI System ENV */
  virtual function void connect_phase(uvm_phase phase);
    //`uvm_info("connect_phase", "Entered...",UVM_LOW)
    super.connect_phase(phase);

<% if(!obj.CUSTOMER_ENV) { %>


  if(m_cfg.has_scoreboard) begin
    <% var NSMIIFTX = obj.nSmiRx;
    for (var i = 0; i < NSMIIFTX; i++) { %>
     m_smi_agent.m_smi<%=i%>_tx_monitor.smi_ap.connect(m_sb.analysis_smi);
     if($test$plusargs("tcap_scb_en")) begin
        <% if(i == (NSMIIFTX-1)) { %>
        m_smi_agent.m_smi<%=i%>_tx_monitor.smi_ndp_ap.connect(m_trace_debug_scb.analysis_smi_dntx_ndp_only_port);
        <% } %>
        m_smi_agent.m_smi<%=i%>_tx_monitor.smi_ap.connect(m_trace_debug_scb.analysis_smi<%=i%>_tx_port);
     end
    <%  if (obj.DmiInfo[obj.Id].smiPortParams.rx[i].params.fnMsgClass[0] == "dtw_req_") { %>
     m_smi_agent.m_smi<%=i%>_tx_monitor.every_beat_smi_ap.connect(m_sb.analysis_smi_every_beat);
    <% } %>
    <% } %>
    <% var NSMIIFRX = obj.nSmiTx;
    for (var i = 0; i < NSMIIFRX; i++) { %>
     m_smi_agent.m_smi<%=i%>_rx_monitor.smi_ap.connect(m_sb.analysis_smi);
     if($test$plusargs("tcap_scb_en")) begin
        <% if(i == (NSMIIFRX-1)) { %>
        m_smi_agent.m_smi<%=i%>_rx_monitor.smi_ndp_ap.connect(m_trace_debug_scb.analysis_smi_dnrx_ndp_only_port);
        <% } %>
        m_smi_agent.m_smi<%=i%>_rx_monitor.smi_ap.connect(m_trace_debug_scb.analysis_smi<%=i%>_rx_port);
     end
    <% } %>

     m_dmi_rtl_agent.m_rtl_monitor.cmd_rsp_ap.connect(m_sb.analysis_dmi_rtl_port);
     m_dmi_tt_agent.m_tt_monitor.tt_alloc_ap.connect(m_sb.analysis_dmi_tt_port);
     m_dmi_read_probe_agent.m_read_probe_monitor.ap.connect(m_sb.analysis_dmi_read_probe_port);
     m_dmi_write_probe_agent.m_write_probe_monitor.ap.connect(m_sb.analysis_dmi_write_probe_port);

     m_axi_slave_agent.read_addr_ap.connect(m_sb.analysis_read_addr_port);
     m_axi_slave_agent.read_data_ap.connect(m_sb.analysis_read_data_port);
     m_axi_slave_agent.write_addr_ap.connect(m_sb.analysis_write_addr_port);
     m_axi_slave_agent.write_data_ap.connect(m_sb.analysis_write_data_port);
     m_axi_slave_agent.write_resp_ap.connect(m_sb.analysis_write_resp_port);

<% if(obj.useCmc) { %>
     m_ccp_agent.ctrlwr_ap.connect(m_sb.analysis_ccp_wrdata_port);
     m_ccp_agent.ctrlstatus_ap.connect(m_sb.analysis_ccp_ctrl_port);
     m_ccp_agent.cachefillctrl_ap.connect(m_sb.analysis_ccp_fill_ctrl_port);
     m_ccp_agent.cachefilldata_ap.connect(m_sb.analysis_ccp_fill_data_port);
     m_ccp_agent.cacherdrsp_ap.connect(m_sb.analysis_ccp_rd_rsp_port);
     m_ccp_agent.cacheevict_ap.connect(m_sb.analysis_ccp_evict_port);
     m_ccp_agent.csr_maint_ap.connect(m_sb.analysis_ccp_csr_maint_port);

     m_apb_agent.m_apb_monitor.apb_req_ap.connect(m_sb.analysis_apb_port);

<% if(obj.useCmc && obj.DmiInfo[obj.Id].ccpParams.useScratchpad){%>
     //ccp scratchpad analysis ports connections
     m_ccp_agent.sp_ctrlstatus_ap.connect(m_sb.analysis_ccp_sp_ctrl_port);
     m_ccp_agent.sp_input_ap.connect(m_sb.analysis_ccp_sp_input_port);
     m_ccp_agent.sp_output_ap.connect(m_sb.analysis_ccp_sp_output_port);
<% } %>

    if(m_cfg.ccp_agent_cfg.has_scoreboard) begin
       m_ccp_agent.ctrlwr_ap.connect(m_scb.ccp_wr_data_port);
       m_ccp_agent.ctrlstatus_ap.connect(m_scb.ccp_ctrl_port);
       m_ccp_agent.cachefillctrl_ap.connect(m_scb.ccp_fill_ctrl_port);
       m_ccp_agent.cachefilldata_ap.connect(m_scb.ccp_fill_data_port);
       m_ccp_agent.cacherdrsp_ap.connect(m_scb.ccp_rd_rsp_port);
       m_ccp_agent.cacheevict_ap.connect(m_scb.ccp_evict_port);
     end
<% } %>
   <% if (obj.testBench == 'dmi') { %>
     m_q_chnl_agent.q_chnl_ap.connect(m_sb.analysis_q_chnl_port);
   <% } %>
  end
<% } %>

<% if((obj.testBench=='dmi' && obj.INHOUSE_APB_VIP && obj.Id=="0") || obj.testBench == 'cust_tb') { %>
    m_regs.default_map.set_auto_predict(1);
    m_regs.default_map.set_sequencer(.sequencer(m_apb_agent.m_apb_sequencer),
                                     .adapter(m_apb_agent.m_apb_reg_adapter));
<%}%> 
<% if(((obj.testBench=='dmi' && obj.Id == 0)| obj.testBench == 'cust_tb'||obj.testBench == 'fsys' || obj.testBench =='emu')){ %>
if(m_cfg.has_scoreboard) begin
   m_sb.m_regs = this.m_regs; 
end
<%}%>

endfunction

   virtual function void report_phase(uvm_phase phase);
      //`uvm_info("connect_phase", "Entered...",UVM_LOW)
      super.report_phase(phase);
<% if(!obj.CUSTOMER_ENV) { %>
      //run_report(phase);
      if (m_cfg.has_scoreboard == 1) begin
         int    i;
         //#Check.DMI.NoPktsSentFail
         if(!$test$plusargs("no_transactions")) begin
          // if(m_sb.numTxns == 0) begin
          //    `uvm_error("ENV", "No transactions seen by dmi scoreboard in test.")
          // end
         end
      end // if (m_cfg.has_scoreboard == 1)
<% } %>
   endfunction // report_phase

endclass

