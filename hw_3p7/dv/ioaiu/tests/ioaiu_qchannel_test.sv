`ifndef USE_VIP_SNPS
`include "base_test.sv"
<%
    //all csr sequences
    var csr_seqs = [
        "ioaiu_csr_uuedr_MemErrDetEn_seq",
        "io_aiu_csr_caiuuedr_TransErrDetEn_seq"
    ];
%>


class ioaiu_qchannel_test extends base_test;

  `uvm_component_utils(ioaiu_qchannel_test)

  ace_cache_model  m_ace_cache_model[<%=obj.DutInfo.nNativeInterfacePorts%>];
  axi_memory_model m_axi_memory_model;
  uvm_event         e_agent_isolation_mode_complete;
  uvm_reg_sequence csr_seq[<%=obj.DutInfo.nNativeInterfacePorts%>];
  <%for(var i = 0; i < obj.DutInfo.nNativeInterfacePorts; i++){%>
  io_aiu_default_reset_seq_<%=i%> default_seq_<%=i%>;
  <%}%>
  virtual <%=obj.BlockId%>_q_chnl_if qc_if; 
  q_chnl_seq m_q_chnl_seq;
  uvm_event toggle_rstn;

  function new(string name = "ioaiu_qchannel_test", uvm_component parent=null);
    super.new(name,parent);
    uvm_config_db#(virtual <%=obj.BlockId%>_q_chnl_if )::get(.cntxt(null),
                                        .inst_name( "" ),
                                        .field_name( "m_q_chnl_if" ),
                                        .value(qc_if ));
  endfunction: new

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    toggle_rstn = new("toggle_rstn");
    if (!uvm_config_db#(uvm_event)::get( .cntxt(null),
                                    .inst_name(""),
                                    .field_name( "toggle_rstn" ),
                                    .value( toggle_rstn ))) begin
       `uvm_error("Q-chnl test", "Event toggle_rstn is not found")
    end
  m_q_chnl_seq = q_chnl_seq::type_id::create("m_q_chnl_seq");
<% if(obj.BLK_SNPS_ACE_VIP) { %>
    //override the base test default sequence
    <%for(var i = 0; i < obj.DutInfo.nNativeInterfacePorts; i++){%>
    uvm_config_db#(uvm_object_wrapper)::set(this, 
                                            "mp_env.m_env[<%=i%>].axi_system_env.sequencer.main_phase", 
                                            "default_sequence", 
                                            directed_seq0::type_id::get());

    uvm_config_db#(int unsigned)::set(this, 
                                      "mp_env.m_env[<%=i%>].axi_system_env.sequencer.directed_seq_read", 
                                      "sequence_length", 
                                      1);
<% } %>
<% } %>
    //uvm_config_db#(ioaiu_env)::set(this,"*","env_handle",mp_env.m_env[<%=i%>]);
<% if(!obj.BLK_SNPS_ACE_VIP) { %>
    <%for(var i = 0; i < obj.DutInfo.nNativeInterfacePorts; i++){%>
    m_ace_cache_model[<%=i%>] = new();
    <%}%>
<% } %>
<% if(!obj.PSEUDO_SYS_TB) { %>
    m_axi_memory_model = new();
<% } %>
   //instantiate the csr seq
  <% if (obj.INHOUSE_APB_VIP) { %>
    <%for(var i = 0; i < obj.DutInfo.nNativeInterfacePorts; i++){%>
    default_seq_<%=i%> = io_aiu_default_reset_seq_<%=i%>::type_id::create("default_seq_<%=i%>");

    <%}%>
    <% if(obj.testBench == 'io_aiu') { %>
    `ifndef VCS
     if (k_csr_seq) begin
    `else // `ifndef VCS
     if (k_csr_seq != "") begin
    `endif // `ifndef VCS ... `else ... 
    <% } else {%>
     if (k_csr_seq) begin
    <% } %>
    <% for (i in csr_seqs) { %>
        if (k_csr_seq == "<%=csr_seqs[i]%>")
            <%for (let j=0; j<obj.DutInfo.nNativeInterfacePorts; j++) {%>
            csr_seq[<%=j%>] = <%=csr_seqs[i]%>_<%=j%>::type_id::create("csr_seq_<%=j%>");
            <%}%>
    <% } %>
    end
  <% } %>
<%for(var i = 0; i < obj.DutInfo.nNativeInterfacePorts; i++){%>
    m_axi_master_cfg[0].k_ace_master_write_addr_chnl_delay_min.set_value(100);
    m_axi_master_cfg[0].k_ace_master_write_addr_chnl_delay_max.set_value(500);
    m_axi_master_cfg[0].k_ace_master_write_addr_chnl_burst_pct.set_value(100);
    m_axi_master_cfg[0].k_ace_master_write_data_chnl_delay_min.set_value(100);
    m_axi_master_cfg[0].k_ace_master_write_data_chnl_delay_max.set_value(500);
    m_axi_master_cfg[0].k_ace_master_write_data_chnl_burst_pct.set_value(100);
    m_axi_master_cfg[0].k_ace_master_write_resp_chnl_delay_min.set_value(100);
    m_axi_master_cfg[0].k_ace_master_write_resp_chnl_delay_max.set_value(500);
    m_axi_master_cfg[0].k_ace_master_write_resp_chnl_burst_pct.set_value(100);
<% } %>
  <%if(obj.NO_SMI === undefined) { %>
    <% var NSMIIFTX = obj.DutInfo.nSmiTx;
    for (var i = 0; i < NSMIIFTX; i++) { %>
         m_smi_agent_cfg.m_smi<%=i%>_tx_port_config.k_delay_min.set_value(100);
         m_smi_agent_cfg.m_smi<%=i%>_tx_port_config.k_delay_max.set_value(500);
         m_smi_agent_cfg.m_smi<%=i%>_tx_port_config.k_burst_pct.set_value(100);
    <% } %>
    <% var NSMIIFRX = obj.DutInfo.nSmiRx;
    for (var i = 0; i < NSMIIFRX; i++) { %>
         m_smi_agent_cfg.m_smi<%=i%>_rx_port_config.k_delay_min.set_value(100);
         m_smi_agent_cfg.m_smi<%=i%>_rx_port_config.k_delay_max.set_value(500);
         m_smi_agent_cfg.m_smi<%=i%>_rx_port_config.k_burst_pct.set_value(100);
    <% } %>
  <% } %>

  endfunction : build_phase

  task run_phase (uvm_phase phase);

`ifndef USE_VIP_SNPS
      axi_master_pipelined_seq m_master_pipelined_seq[<%=obj.DutInfo.nNativeInterfacePorts%>];
      axi_master_snoop_seq m_master_snoop_seq;

<%for(var i = 0; i < obj.DutInfo.nNativeInterfacePorts; i++){%>
      m_master_pipelined_seq[<%=i%>] = axi_master_pipelined_seq::type_id::create("m_master_pipelined_seq_<%=i%>");
<% } %>

        <%if((((obj.DutInfo.fnNativeInterface === "ACELITE-E") || (obj.DutInfo.fnNativeInterface === "ACE-LITE")) && (obj.DutInfo.cmpInfo.nDvmSnpInFlight > 0)) || (obj.DutInfo.fnNativeInterface == "ACE")) { %>
                m_master_snoop_seq = axi_master_snoop_seq::type_id::create("m_master_snoop_seq");
        <%}%>



<% if(!obj.PSEUDO_SYS_TB) { %>
/*DCTODO BYPASSCHK      axi_slave_read_seq   m_slave_read_seq   = axi_slave_read_seq::type_id::create("slave_read_seq");
      axi_slave_write_seq  m_slave_write_seq  = axi_slave_write_seq::type_id::create("slave_write_seq");
 */
<% } %>
`else
      snps_axi_master_pipelined_seq m_master_pipelined_seq[<%=obj.DutInfo.nNativeInterfacePorts%>];
<%for(var i = 0; i < obj.DutInfo.nNativeInterfacePorts; i++){%>
      m_master_pipelined_seq[<%=i%>] = snps_axi_master_pipelined_seq::type_id::create("m_master_pipelined_seq_<%=i%>");
<% } %>
`endif
      super.run_phase(phase);
<% if(!obj.BLK_SNPS_ACE_VIP) { %>
<%for(var i = 0; i < obj.DutInfo.nNativeInterfacePorts; i++){%>
      m_ace_cache_model[<%=i%>].prob_unq_cln_to_unq_dirty           = prob_unq_cln_to_unq_dirty;
      m_ace_cache_model[<%=i%>].prob_unq_cln_to_invalid             = prob_unq_cln_to_invalid;
      m_ace_cache_model[<%=i%>].total_outstanding_coh_writes        = total_outstanding_coh_writes;
      m_ace_cache_model[<%=i%>].total_min_ace_cache_size            = total_min_ace_cache_size;
      m_ace_cache_model[<%=i%>].total_max_ace_cache_size            = total_max_ace_cache_size;
      m_ace_cache_model[<%=i%>].size_of_wr_queue_before_flush       = size_of_wr_queue_before_flush;
      m_ace_cache_model[<%=i%>].wt_expected_end_state               = wt_expected_end_state;
      m_ace_cache_model[<%=i%>].wt_legal_end_state_with_sf          = wt_legal_end_state_with_sf;
      m_ace_cache_model[<%=i%>].wt_legal_end_state_without_sf       = wt_legal_end_state_without_sf;
      m_ace_cache_model[<%=i%>].wt_expected_start_state             = wt_expected_start_state;
      m_ace_cache_model[<%=i%>].wt_legal_start_state                = wt_legal_start_state;
      m_ace_cache_model[<%=i%>].wt_lose_cache_line_on_snps          = wt_lose_cache_line_on_snps;
      m_ace_cache_model[<%=i%>].wt_keep_drty_cache_line_on_snps     = wt_keep_drty_cache_line_on_snps;
      m_ace_cache_model[<%=i%>].prob_respond_to_snoop_coll_with_wr  = prob_respond_to_snoop_coll_with_wr;
      m_ace_cache_model[<%=i%>].prob_was_unique_snp_resp            = prob_was_unique_snp_resp;
      m_ace_cache_model[<%=i%>].prob_was_unique_always0_snp_resp    = prob_was_unique_always0_snp_resp;
      m_ace_cache_model[<%=i%>].prob_dataxfer_snp_resp_on_clean_hit = prob_dataxfer_snp_resp_on_clean_hit;
      m_ace_cache_model[<%=i%>].prob_ace_wr_ix_start_state          = prob_ace_wr_ix_start_state;
      m_ace_cache_model[<%=i%>].prob_ace_rd_ix_start_state          = prob_ace_rd_ix_start_state;
      m_ace_cache_model[<%=i%>].prob_cache_flush_mode_per_1k        = prob_cache_flush_mode_per_1k;
      m_ace_cache_model[<%=i%>].prob_ace_coh_win_error              = prob_ace_coh_win_error;
<% } %>
<% if (!obj.SFI_BFM_TEST_MODE) { %>
`ifndef USE_VIP_SNPS
<%for(var i = 0; i < obj.DutInfo.nNativeInterfacePorts; i++){%>
      m_master_pipelined_seq[<%=i%>].m_read_addr_chnl_seqr          = mp_env.m_env[<%=i%>].m_axi_master_agent.m_read_addr_chnl_seqr;
      m_master_pipelined_seq[<%=i%>].m_read_data_chnl_seqr          = mp_env.m_env[<%=i%>].m_axi_master_agent.m_read_data_chnl_seqr;
      m_master_pipelined_seq[<%=i%>].m_write_addr_chnl_seqr         = mp_env.m_env[<%=i%>].m_axi_master_agent.m_write_addr_chnl_seqr;
      m_master_pipelined_seq[<%=i%>].m_write_data_chnl_seqr         = mp_env.m_env[<%=i%>].m_axi_master_agent.m_write_data_chnl_seqr;
      m_master_pipelined_seq[<%=i%>].m_write_resp_chnl_seqr         = mp_env.m_env[<%=i%>].m_axi_master_agent.m_write_resp_chnl_seqr;
<% } %>
<%if((((obj.DutInfo.fnNativeInterface === "ACELITE-E") || (obj.DutInfo.fnNativeInterface === "ACE-LITE")) && (obj.DutInfo.cmpInfo.nDvmSnpInFlight > 0)) || (obj.DutInfo.fnNativeInterface == "ACE")) { %>
                        m_master_snoop_seq.m_read_addr_chnl_seqr               = mp_env.m_env[0].m_axi_master_agent.m_read_addr_chnl_seqr;
                        m_master_snoop_seq.m_read_data_chnl_seqr               = mp_env.m_env[0].m_axi_master_agent.m_read_data_chnl_seqr;
                        m_master_snoop_seq.m_snoop_addr_chnl_seqr              = mp_env.m_env[0].m_axi_master_agent.m_snoop_addr_chnl_seqr;
                        m_master_snoop_seq.m_snoop_data_chnl_seqr              = mp_env.m_env[0].m_axi_master_agent.m_snoop_data_chnl_seqr;
                        m_master_snoop_seq.m_snoop_resp_chnl_seqr              = mp_env.m_env[0].m_axi_master_agent.m_snoop_resp_chnl_seqr;
                        m_master_snoop_seq.m_ace_cache_model                     = m_ace_cache_model[0]; 
    <%}%>
`endif
<%for(var i = 0; i < obj.DutInfo.nNativeInterfacePorts; i++){%>
      m_master_pipelined_seq[<%=i%>].m_ace_cache_model              = m_ace_cache_model[<%=i%>];
      m_master_pipelined_seq[<%=i%>].wt_ace_rdnosnp                 = mp_env.m_env[<%=i%>].m_axi_master_agent.m_cfg.wt_ace_rdnosnp;
      m_master_pipelined_seq[<%=i%>].wt_ace_rdonce                  = mp_env.m_env[<%=i%>].m_axi_master_agent.m_cfg.wt_ace_rdonce;
      m_master_pipelined_seq[<%=i%>].wt_ace_rdshrd                  = mp_env.m_env[<%=i%>].m_axi_master_agent.m_cfg.wt_ace_rdshrd;
      m_master_pipelined_seq[<%=i%>].wt_ace_rdcln                   = mp_env.m_env[<%=i%>].m_axi_master_agent.m_cfg.wt_ace_rdcln;
      m_master_pipelined_seq[<%=i%>].wt_ace_rdnotshrddty            = mp_env.m_env[<%=i%>].m_axi_master_agent.m_cfg.wt_ace_rdnotshrddty;
      m_master_pipelined_seq[<%=i%>].wt_ace_rdunq                   = mp_env.m_env[<%=i%>].m_axi_master_agent.m_cfg.wt_ace_rdunq;
      m_master_pipelined_seq[<%=i%>].wt_ace_clnunq                  = mp_env.m_env[<%=i%>].m_axi_master_agent.m_cfg.wt_ace_clnunq;
      m_master_pipelined_seq[<%=i%>].wt_ace_mkunq                   = mp_env.m_env[<%=i%>].m_axi_master_agent.m_cfg.wt_ace_mkunq;
      m_master_pipelined_seq[<%=i%>].wt_ace_dvm_msg                 = mp_env.m_env[<%=i%>].m_axi_master_agent.m_cfg.wt_ace_dvm_msg;
      m_master_pipelined_seq[<%=i%>].wt_ace_clnshrd                 = mp_env.m_env[<%=i%>].m_axi_master_agent.m_cfg.wt_ace_clnshrd;
      m_master_pipelined_seq[<%=i%>].wt_ace_clninvl                 = mp_env.m_env[<%=i%>].m_axi_master_agent.m_cfg.wt_ace_clninvl;
      m_master_pipelined_seq[<%=i%>].wt_ace_mkinvl                  = mp_env.m_env[<%=i%>].m_axi_master_agent.m_cfg.wt_ace_mkinvl;
      m_master_pipelined_seq[<%=i%>].wt_ace_rd_bar                  = mp_env.m_env[<%=i%>].m_axi_master_agent.m_cfg.wt_ace_rd_bar;
      m_master_pipelined_seq[<%=i%>].wt_ace_wrnosnp                 = mp_env.m_env[<%=i%>].m_axi_master_agent.m_cfg.wt_ace_wrnosnp;
      m_master_pipelined_seq[<%=i%>].wt_ace_wrunq                   = mp_env.m_env[<%=i%>].m_axi_master_agent.m_cfg.wt_ace_wrunq;
      m_master_pipelined_seq[<%=i%>].wt_ace_wrlnunq                 = mp_env.m_env[<%=i%>].m_axi_master_agent.m_cfg.wt_ace_wrlnunq;
      m_master_pipelined_seq[<%=i%>].wt_ace_wrcln                   = mp_env.m_env[<%=i%>].m_axi_master_agent.m_cfg.wt_ace_wrcln;
      m_master_pipelined_seq[<%=i%>].wt_ace_wrbk                    = mp_env.m_env[<%=i%>].m_axi_master_agent.m_cfg.wt_ace_wrbk;
      m_master_pipelined_seq[<%=i%>].wt_ace_evct                    = mp_env.m_env[<%=i%>].m_axi_master_agent.m_cfg.wt_ace_evct;
      m_master_pipelined_seq[<%=i%>].wt_ace_wrevct                  = mp_env.m_env[<%=i%>].m_axi_master_agent.m_cfg.wt_ace_wrevct;
      m_master_pipelined_seq[<%=i%>].wt_ace_wr_bar                  = mp_env.m_env[<%=i%>].m_axi_master_agent.m_cfg.wt_ace_wr_bar;
      m_master_pipelined_seq[<%=i%>].k_num_read_req                 = mp_env.m_env[<%=i%>].m_axi_master_agent.m_cfg.k_num_read_req;
      m_master_pipelined_seq[<%=i%>].k_num_write_req                = mp_env.m_env[<%=i%>].m_axi_master_agent.m_cfg.k_num_write_req;
      m_master_pipelined_seq[<%=i%>].no_updates                     = mp_env.m_env[<%=i%>].m_axi_master_agent.m_cfg.no_updates;
      m_master_pipelined_seq[<%=i%>].wt_ace_atm_str                 = mp_env.m_env[<%=i%>].m_axi_master_agent.m_cfg.wt_ace_atm_str;
      m_master_pipelined_seq[<%=i%>].wt_ace_atm_ld                  = mp_env.m_env[<%=i%>].m_axi_master_agent.m_cfg.wt_ace_atm_ld;
      m_master_pipelined_seq[<%=i%>].wt_ace_atm_swap                = mp_env.m_env[<%=i%>].m_axi_master_agent.m_cfg.wt_ace_atm_swap;
      m_master_pipelined_seq[<%=i%>].wt_ace_atm_comp                = mp_env.m_env[<%=i%>].m_axi_master_agent.m_cfg.wt_ace_atm_comp;
      m_master_pipelined_seq[<%=i%>].wt_ace_ptl_stash               = mp_env.m_env[<%=i%>].m_axi_master_agent.m_cfg.wt_ace_ptl_stash;
      m_master_pipelined_seq[<%=i%>].wt_ace_full_stash              = mp_env.m_env[<%=i%>].m_axi_master_agent.m_cfg.wt_ace_full_stash;
      m_master_pipelined_seq[<%=i%>].wt_ace_shared_stash            = mp_env.m_env[<%=i%>].m_axi_master_agent.m_cfg.wt_ace_shared_stash;
      m_master_pipelined_seq[<%=i%>].wt_ace_unq_stash               = mp_env.m_env[<%=i%>].m_axi_master_agent.m_cfg.wt_ace_unq_stash;
      m_master_pipelined_seq[<%=i%>].wt_ace_stash_trans             = 0;
<% } %>
<% } %>
<% if (obj.INHOUSE_APB_VIP) { %>
  <%for(var i = 0; i < obj.DutInfo.nNativeInterfacePorts; i++){%>
  default_seq_<%=i%>.model       = mp_env.m_env[0].m_regs;
   <% if(obj.testBench == 'io_aiu') { %>
   `ifndef VCS
    if (k_csr_seq) begin
   `else // `ifndef VCS
    if (k_csr_seq != "") begin
   `endif // `ifndef VCS ... `else ... 
   <% } else {%>
    if (k_csr_seq) begin
   <% } %>
      csr_seq[<%=i%>].model       = mp_env.m_env[0].m_regs;
    end
  <% } %>
<% } %>

 <% if(obj.INHOUSE_APB_VIP) { %>
  phase.raise_objection(this, "Start default_seq");
  `uvm_info("run_main", "default_seq started",UVM_DEBUG)
  <%for(var i = 0; i < obj.DutInfo.nNativeInterfacePorts; i++){%>
  default_seq_<%=i%>.start(mp_env.m_env[0].m_apb_agent.m_apb_sequencer);
  <%}%>
  `uvm_info("run_main", "default_seq finished",UVM_DEBUG)
  #100ns;
  phase.drop_objection(this, "Finish default_seq");
 <% } %>

<%if((((obj.DutInfo.fnNativeInterface === "ACELITE-E") || (obj.DutInfo.fnNativeInterface === "ACE-LITE")) && (obj.DutInfo.cmpInfo.nDvmSnpInFlight > 0)) || (obj.DutInfo.fnNativeInterface == "ACE")) { %>
	m_master_snoop_seq.start(null);
<%}%>	

      fork 
//Sanity test
if($test$plusargs("ioaiu_qchannel_sanity_test"))begin
  begin
    phase.raise_objection(this, "Start AIU write bring up test");
    if ($test$plusargs("csr_test")) begin
      `uvm_info("run_main","Waiting for CSR seq to set the control register",UVM_DEBUG)
      fork
          begin
              <%for(let i=0; i<obj.DutInfo.nNativeInterfacePorts; i++) {%>
                  ev_<%=i%>.wait_ptrigger();
              <%}%>
          end
      join
      // ev.wait_ptrigger();
      `uvm_info("run_main","Waiting Completed for CSR seq to set the control register",UVM_DEBUG)
    end
`ifndef USE_VIP_SNPS
fork
<%for(var i = 0; i < obj.DutInfo.nNativeInterfacePorts; i++){%>
    m_master_pipelined_seq[<%=i%>].start(null);
<% } %>
join
`else
fork
<%for(var i = 0; i < obj.DutInfo.nNativeInterfacePorts; i++){%>
    m_master_pipelined_seq[<%=i%>].start(axi_system_env.sequencer);
<% } %>
join
`endif
    phase.drop_objection(this, "Finish AIU write bring up test");
    //Starting Q channel sequence
 <% if(obj.AiuInfo[obj.Id].usePma) { %>
    phase.raise_objection(this, $sformatf("Start q_cnl_seq"));
    #500ns;       
    `uvm_info("ioaiu_qchannel_sanity_test", "Q_SEQ_START",UVM_DEBUG)
    m_q_chnl_seq.start(mp_env.m_env[0].m_q_chnl_agent.m_q_chnl_seqr);
    `uvm_info("ioaiu_qchannel_sanity_test", "Q_SEQ_END",UVM_DEBUG)
    phase.drop_objection(this, $sformatf("Finish q_cnl_seq"));
 <% } %>
  end
end

//ioaiu_qchannel_req_during_cmd_test
if($test$plusargs("ioaiu_qchannel_req_during_cmd_test"))begin
   fork
     begin
       phase.raise_objection(this, "Start AIU write bring up test");
       if ($test$plusargs("csr_test")) begin
         `uvm_info("run_main","Waiting for CSR seq to set the control register",UVM_DEBUG)
         fork
            begin
                <%for(let i=0; i<obj.DutInfo.nNativeInterfacePorts; i++) {%>
                    ev_<%=i%>.wait_ptrigger();
                <%}%>
            end
        join
        //  ev.wait_ptrigger();
         `uvm_info("run_main","Waiting Completed for CSR seq to set the control register",UVM_DEBUG)
       end
`ifndef USE_VIP_SNPS
fork
<%for(var i = 0; i < obj.DutInfo.nNativeInterfacePorts; i++){%>
       m_master_pipelined_seq[<%=i%>].start(null);
<% } %>
join
`else
fork
<%for(var i = 0; i < obj.DutInfo.nNativeInterfacePorts; i++){%>
       m_master_pipelined_seq[<%=i%>].start(axi_system_env.sequencer);
<% } %>
join
`endif
       //DCTODO remove below pound delay when scoreboard is enabled and using objection mechanism
       #50000ns;
       phase.drop_objection(this, "Finish AIU write bring up test");
     end
     begin
 <% if(obj.AiuInfo[obj.Id].usePma) { %>
     repeat(5) begin
        wait(qc_if.QACTIVE);
        repeat(2)  @(posedge qc_if.clk); ///delay
        //Starting Q channel sequence
        phase.raise_objection(this, $sformatf("Start q_cnl_seq"));
        `uvm_info("ioaiu_qchannel_req_during_cmd_test", "Q_SEQ_START",UVM_DEBUG)
        m_q_chnl_seq.start(mp_env.m_env[0].m_q_chnl_agent.m_q_chnl_seqr);
        `uvm_info("ioaiu_qchannel_req_during_cmd_test", "Q_SEQ_END",UVM_DEBUG)
        phase.drop_objection(this, $sformatf("Finish q_cnl_seq"));
     end
 <% } %>
     end
   join
end

//ioaiu_qchannel_req_between_cmd_test
if($test$plusargs("ioaiu_qchannel_req_between_cmd_test"))begin
   fork
     begin
         phase.raise_objection(this, "Start AIU write bring up test");
         if ($test$plusargs("csr_test")) begin
            `uvm_info("run_main","Waiting for CSR seq to set the control register",UVM_DEBUG)
            fork
                begin
                    <%for(let i=0; i<obj.DutInfo.nNativeInterfacePorts; i++) {%>
                        ev_<%=i%>.wait_ptrigger();
                    <%}%>
                end
            join
          //  ev.wait_ptrigger();
           `uvm_info("run_main","Waiting Completed for CSR seq to set the control register",UVM_DEBUG)
         end
`ifndef USE_VIP_SNPS
fork
<%for(var i = 0; i < obj.DutInfo.nNativeInterfacePorts; i++){%>
       m_master_pipelined_seq[<%=i%>].start(null);
<% } %>
join
`else
fork
<%for(var i = 0; i < obj.DutInfo.nNativeInterfacePorts; i++){%>
       m_master_pipelined_seq[<%=i%>].start(axi_system_env.sequencer);
<% } %>
join
`endif
         //DCTODO remove below pound delay when scoreboard is enabled and using objection mechanism
         #50000ns;
         phase.drop_objection(this, "Finish AIU write bring up test");
     end
     begin
 <% if(obj.AiuInfo[obj.Id].usePma) { %>
     repeat(10) begin
         wait(!qc_if.QACTIVE);
         repeat(2)  @(posedge qc_if.clk); ///delay
         //Starting Q channel sequence
         phase.raise_objection(this, $sformatf("Start q_cnl_seq"));
         `uvm_info("ioaiu_qchannel_req_between_cmd_test", "Q_SEQ_START",UVM_DEBUG)
         m_q_chnl_seq.start(mp_env.m_env[0].m_q_chnl_agent.m_q_chnl_seqr);
         `uvm_info("ioaiu_qchannel_req_between_cmd_test", "Q_SEQ_END",UVM_DEBUG)
         phase.drop_objection(this, $sformatf("Finish q_cnl_seq"));
         wait(qc_if.QACTIVE);
     end
 <% } %>
     end
   join
end


//ioaiu_qchannel_multiple_request_test
if($test$plusargs("ioaiu_qchannel_multiple_request_test"))begin
  fork
  begin
    phase.raise_objection(this, "Start AIU write bring up test");
    if ($test$plusargs("csr_test")) begin
      `uvm_info("run_main","Waiting for CSR seq to set the control register",UVM_DEBUG)
      fork
          begin
              <%for(let i=0; i<obj.DutInfo.nNativeInterfacePorts; i++) {%>
                  ev_<%=i%>.wait_ptrigger();
              <%}%>
          end
      join
        // ev.wait_ptrigger();
      `uvm_info("run_main","Waiting Completed for CSR seq to set the control register",UVM_DEBUG)
    end
`ifndef USE_VIP_SNPS
fork
<%for(var i = 0; i < obj.DutInfo.nNativeInterfacePorts; i++){%>
       m_master_pipelined_seq[<%=i%>].start(null);
<% } %>
join
`else
fork
<%for(var i = 0; i < obj.DutInfo.nNativeInterfacePorts; i++){%>
       m_master_pipelined_seq[<%=i%>].start(axi_system_env.sequencer);
<% } %>
join
`endif
    //DCTODO remove below pound delay when scoreboard is enabled and using objection mechanism
    #50000ns;
    phase.drop_objection(this, "Finish AIU write bring up test");
  end
  begin
 <% if(obj.AiuInfo[obj.Id].usePma) { %>
  repeat(30) begin
      wait(!qc_if.QACTIVE);
      repeat(2)  @(posedge qc_if.clk); ///delay
      repeat($urandom_range(2,10)) begin
      //Starting Q channel sequence
      phase.raise_objection(this, $sformatf("Start q_cnl_seq"));
      `uvm_info("ioaiu_qchannel_multiple_request_test", "Q_SEQ_START",UVM_DEBUG)
      m_q_chnl_seq.start(mp_env.m_env[0].m_q_chnl_agent.m_q_chnl_seqr);
      `uvm_info("ioaiu_qchannel_multiple_request_test", "Q_SEQ_END",UVM_DEBUG)
      phase.drop_objection(this, $sformatf("Finish q_cnl_seq"));
      end
      wait(qc_if.QACTIVE);
   end
 <% } %>
   end
  join
end

//ioaiu_qchannel_reset_test
if($test$plusargs("ioaiu_qchannel_reset_test"))begin
   fork
     begin
         phase.raise_objection(this, "Start AIU write bring up test");
         if ($test$plusargs("csr_test")) begin
           `uvm_info("run_main","Waiting for CSR seq to set the control register",UVM_DEBUG)
            fork
                begin
                    <%for(let i=0; i<obj.DutInfo.nNativeInterfacePorts; i++) {%>
                        ev_<%=i%>.wait_ptrigger();
                    <%}%>
                end
            join
          //  ev.wait_ptrigger();
           `uvm_info("run_main","Waiting Completed for CSR seq to set the control register",UVM_DEBUG)
         end
`ifndef USE_VIP_SNPS
fork
<%for(var i = 0; i < obj.DutInfo.nNativeInterfacePorts; i++){%>
       m_master_pipelined_seq[<%=i%>].start(null);
<% } %>
join
`else
fork
<%for(var i = 0; i < obj.DutInfo.nNativeInterfacePorts; i++){%>
       m_master_pipelined_seq[<%=i%>].start(axi_system_env.sequencer);
<% } %>
join
`endif
         //DCTODO remove below pound delay when scoreboard is enabled and using objection mechanism
         #50000ns;
         phase.drop_objection(this, "Finish AIU write bring up test");
     end
     begin
 <% if(obj.AiuInfo[obj.Id].usePma) { %>
      repeat(5) begin
         wait(qc_if.QACTIVE);
         wait(!qc_if.QACTIVE);
         repeat(2)  @(posedge qc_if.clk); ///delay
         //Starting Q channel sequence
         phase.raise_objection(this, $sformatf("Start q_cnl_seq"));
         `uvm_info("ioaiu_qchannel_reset_test", "Q_SEQ_START",UVM_DEBUG)
         m_q_chnl_seq.start(mp_env.m_env[0].m_q_chnl_agent.m_q_chnl_seqr);
         `uvm_info("ioaiu_qchannel_reset_test", "Q_SEQ_END",UVM_DEBUG)
         phase.drop_objection(this, $sformatf("Finish q_cnl_seq"));
         wait(qc_if.QACTIVE);
      end
     end
     begin
      repeat(1) begin
        wait(!qc_if.QACCEPTn && !qc_if.QREQn && !qc_if.QACTIVE);
        repeat(2)@(posedge qc_if.clk); 
          toggle_rstn.trigger();
         #30ns;//repeat(3)@(posedge qc_if.clk); 
          toggle_rstn.trigger();
      end
 <% } %>
     end  
   join
end

      join
<% } %>

   endtask : run_phase

endclass: ioaiu_qchannel_test
`endif
