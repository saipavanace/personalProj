<%
let computedAxiInt;
let axiIntIsArray = false;
if(Array.isArray(obj.interfaces.axiInt)){
    computedAxiInt = obj.interfaces.axiInt[0];
    axiIntIsArray = true;
}else{
    computedAxiInt = obj.interfaces.axiInt;
}
%>

`ifndef BASE_TEST 
`define BASE_TEST 
<% if(obj.testBench == 'io_aiu') { %>
 `ifdef VCS 
// Add for UVM-1.2 compatibility
class ioaiu_report_server extends uvm_default_report_server;

   function new(string name = "ioaiu_report_server");
    super.new();
   endfunction
 
   virtual function void report_summarize(UVM_FILE file = 0);
   uvm_report_server svr;
    string id;
    string name;
    string output_str;
    string q[$],q2[$];
    int m_max_quit_count,m_quit_count;
    int m_severity_count[uvm_severity];
    int m_id_count[string];
    bit enable_report_id_count_summary ='b0 ;
    uvm_severity q1[$];

    svr = uvm_report_server::get_server();
    m_max_quit_count = get_max_quit_count();
    m_quit_count = get_quit_count();

    svr.get_id_set(q2);
    foreach(q2[s])
      m_id_count[q2[s]] = svr.get_id_count(q2[s]);

    svr.get_severity_set(q1);
    foreach(q1[s])
      m_severity_count[q1[s]] = svr.get_severity_count(q1[s]);


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

  endfunction


endclass
`endif 
<% }  %>
`ifdef USE_VIP_SNPS
class master_modify_computed_parity_value_cb extends svt_amba_uvm_pkg::svt_axi_master_callback;
 
string inject_parity_err_aw_chnl,inject_parity_err_ar_chnl,inject_parity_err_w_chnl,inject_parity_err_b_chnl,inject_parity_err_r_chnl,inject_parity_err_cr_chnl,inject_parity_err_ac_chnl,inject_parity_err_rack,inject_parity_err_wack;

  function new(string name);
    super.new(name);
  endfunction

  virtual function void modify_computed_parity_value(svt_axi_master axi_master, string signal_context = "", string parity_signal = "",ref bit calculated_parity_signal_val);
    /** Sample to update user inject valid_ready parity */
    $value$plusargs("inject_parity_err_aw_chnl=%0s",inject_parity_err_aw_chnl);
   $value$plusargs("inject_parity_err_ar_chnl=%0s",inject_parity_err_ar_chnl);
   $value$plusargs("inject_parity_err_w_chnl=%0s", inject_parity_err_w_chnl);
   $value$plusargs("inject_parity_err_b_chnl=%0s", inject_parity_err_b_chnl);
   $value$plusargs("inject_parity_err_r_chnl=%0s", inject_parity_err_r_chnl);
   $value$plusargs("inject_parity_err_cr_chnl=%0s", inject_parity_err_cr_chnl);
   $value$plusargs("inject_parity_err_ac_chnl=%0s", inject_parity_err_ac_chnl);
   $value$plusargs("inject_parity_err_rack=%0s", inject_parity_err_rack);
   $value$plusargs("inject_parity_err_wack=%0s", inject_parity_err_wack);
    if(parity_signal == "AWVALIDCHK" && inject_parity_err_aw_chnl == "AWVALID_CHK") begin 
      if(signal_context == "ASSERT_AWVALID") begin
        calculated_parity_signal_val = 1;
      end else begin 
        calculated_parity_signal_val = 0;
      end
    end else if(parity_signal == "WVALIDCHK" && inject_parity_err_w_chnl == "WVALID_CHK") begin 
       if(signal_context == "ASSERT_WVALID") begin
        calculated_parity_signal_val = 1;
      end else begin 
        calculated_parity_signal_val = 0;
      end

    end else if(parity_signal == "BREADYCHK" && inject_parity_err_b_chnl == "BREADY_CHK") begin 
      calculated_parity_signal_val = 1;
    end else if(parity_signal == "ARVALIDCHK" && inject_parity_err_ar_chnl == "ARVALID_CHK") begin 
       if(signal_context == "ASSERT_ARVALID") begin
        calculated_parity_signal_val = 1;
      end else begin 
        calculated_parity_signal_val = 0;
      end
    end else if(parity_signal == "RREADYCHK" && inject_parity_err_r_chnl == "RREADY_CHK") begin 
      calculated_parity_signal_val = 1;
    end else if(parity_signal == "CRVALIDCHK" && inject_parity_err_cr_chnl == "CRVALID_CHK") begin 
     if(signal_context == "ASSERT_CRVALID") begin
      calculated_parity_signal_val = 1;
     end else begin
     calculated_parity_signal_val = 0;
     end
   end else if(parity_signal == "CRREADYCHK" && inject_parity_err_cr_chnl == "CRREADY_CHK") begin
     calculated_parity_signal_val = 1;
   end else if(parity_signal == "ACVALIDCHK" && inject_parity_err_ac_chnl == "ACVALID_CHK") begin 
     if(signal_context == "ASSERT_ACVALID") begin
      calculated_parity_signal_val = 1;
     end else begin
     calculated_parity_signal_val = 0;
     end
   end else if(parity_signal == "ACREADYCHK" && inject_parity_err_ac_chnl == "ACREADY_CHK") begin
     calculated_parity_signal_val = 1;
   end else if(parity_signal == "RACKCHK" && inject_parity_err_rack == "RACK") begin
     calculated_parity_signal_val = 1;
   end else if(parity_signal == "WACKCHK" && inject_parity_err_wack == "WACK") begin
     calculated_parity_signal_val = 1;
   end 

  endfunction

endclass : master_modify_computed_parity_value_cb
`endif 

class base_test extends uvm_test;

    `macro_perf_cnt_test_all_declarations
    `macro_connectivity_test_all_declarations

	ioaiu_unit_args m_args;

    //instatiate the aiu env
    //ioaiu_env env;
    ioaiu_multiport_env mp_env;
    common_knob_class prob_of_new_set;  
    // axi_virtual_sequencer  m_ioaiu_vseqr;		
    `ifdef USE_VIP_SNPS  
        //instantiate the config object for the ACE VIP
        svt_amba_env_class_pkg::svt_amba_env axi_system_env;
        master_modify_computed_parity_value_cb cb1;
        svt_axi_master_sequencer io_subsys_mstr_agnt_seqr_a[`NUM_IOAIU_SVT_MASTERS] ;
        cust_svt_amba_system_configuration  svt_cfg;
        //ace_env_config cfg;
        //svt_axi_cache snps_cache;
    `endif
  
    // <%if((obj.DutInfo.useCache)){%>                   
    //     ccp_agent_config  m_ccp_cfg;
    // <%}%>
    //<%if(obj.INHOUSE_APB_VIP){%>
    //    apb_agent_config  m_apb_cfg;
    //<%}%>

    //instantiate the AIU env config object
    //ioaiu_env_config m_env_cfg;

    //instantiate the SMI config object
    smi_agent_config m_smi_agent_cfg;
    <%if(obj.NO_SMI === undefined){%>   
        <%var NSMIIFTX = obj.nSmiTx;
        for(var i = 0; i < NSMIIFTX; i++){%>
            smi_port_config m_smi<%=i%>_tx_port_config;
        <%}%>
        <%var NSMIIFRX = obj.nSmiRx;
        for (var i = 0; i < NSMIIFRX; i++) { %>
            smi_port_config m_smi<%=i%>_rx_port_config;
        <%}%>
    <%}%>
    //instantiate config object for AXI agent
    //axi_agent_config m_axi_master_cfg;
    //axi_agent_config m_axi_slave_cfg;

	//HS: 3.4 MP updates
    // axi_agent_config m_axi_master_cfg[<%=obj.DutInfo.nNativeInterfacePorts%>];
    // axi_agent_config m_axi_slave_cfg[<%=obj.DutInfo.nNativeInterfacePorts%>];
    axi_agent_config m_axi_master_cfg[<%=obj.DutInfo.nNativeInterfacePorts%>];
    axi_agent_config m_axi_slave_cfg[<%=obj.DutInfo.nNativeInterfacePorts%>];
    ioaiu_env_config m_env_cfg[<%=obj.DutInfo.nNativeInterfacePorts%>];
    <%if((obj.DutInfo.useCache)){%>
        ccp_agent_config  m_ccp_cfg[<%=obj.DutInfo.nNativeInterfacePorts%>];
    <%}%>
    <%if(obj.INHOUSE_APB_VIP){%>
    <% if (obj.testBench == "emu") { %>
        apb_agent_config  m_apb_cfg[<%=obj.DutInfo.nNativeInterfacePorts%>];
    <%} else {%>
        apb_agent_config  m_apb_cfg;  
    <%}%>
    <%}%>
    virtual <%=obj.BlockId%>_axi_cmdreq_id_if axi_cmdreq_id_if[<%=obj.DutInfo.nNativeInterfacePorts%>];

    <%if(obj.NO_SYS_BFM === undefined){%>
        system_bfm_seq m_system_bfm_seq;
    <%}%>
    uvm_cmdline_processor clp = uvm_cmdline_processor::get_inst();
    uvm_event_pool ev_pool = uvm_event_pool::get_global_pool();
    <%for(let i=0; i<obj.DutInfo.nNativeInterfacePorts; i++) {%>
        uvm_event ev_<%=i%> = ev_pool.get("ev_<%=i%>");
    <%}%>
    
    ace_cache_model  m_ace_cache_model[<%=obj.DutInfo.nNativeInterfacePorts%>];


    // control knobs
    int k_prob_single_bit_tag_error           = 100;
    int k_prob_double_bit_tag_error           = 100;
    int k_prob_single_bit_data_error          = 100;
    int k_prob_double_bit_data_error          = 100;
    longint k_timeout                             = 20000000;
    int k_num_addr                            = 1;
    int k_num_read_req                        = 100;
    int k_num_write_req                       = 100;
    int k_num_eviction_req                    = 0;
    int prob_unq_cln_to_unq_dirty             = 70;
    int prob_unq_cln_to_invalid               = 10;
    int total_outstanding_coh_writes          = 10;
    int total_min_ace_cache_size              = 50;
    int total_max_ace_cache_size              = 150;
    int size_of_wr_queue_before_flush         = 10;
    int wt_expected_end_state                 = 60; 
    int wt_legal_end_state_with_sf            = 25; 
    int wt_legal_end_state_without_sf         = 15; 
    int wt_expected_start_state               = 60; 
    int wt_legal_start_state                  = 40; 
    int wt_lose_cache_line_on_snps            = 30; 
    int wt_keep_drty_cache_line_on_snps       = 50;
    int prob_respond_to_snoop_coll_with_wr    = 50; 
    int prob_was_unique_snp_resp              = 50; 
    int prob_was_unique_always0_snp_resp      = 25; 
    int prob_dataxfer_snp_resp_on_clean_hit   = 50; 
    int prob_ace_wr_ix_start_state            = 80;
    int prob_ace_rd_ix_start_state            = 80;
    int prob_cache_flush_mode_per_1k          = 100;
    int k_reorder_rsp_max                     = 0;
    int k_reorder_rsp_tmr                     = 0;
    int k_mst_req_back_pres_min               = 0;
    int k_mst_req_back_pres_max               = 1;
    int k_mst_req_burst_pct                   = 80;
    int k_mst_req_beat_xfrs_min               = 0;
    int k_mst_req_beat_xfrs_max               = 1;
    int k_mst_rsp_beat_xfrs_min               = 0;
    int k_mst_rsp_beat_xfrs_max               = 2;
    int k_mst_rsp_burst_pct                   = 80;
    int k_mst_rsp_back_pres_min               = 0;
    int k_mst_rsp_back_pres_max               = 2;
    bit k_mst_delay                           = 1;
    int k_slv_req_back_pres_min               = 0;
    int k_slv_req_back_pres_max               = 1;
    int k_slv_req_burst_pct                   = 80;
    int k_slv_req_beat_xfrs_min               = 0;
    int k_slv_req_beat_xfrs_max               = 1;
    int k_slv_rsp_beat_xfrs_min               = 0;
    int k_slv_rsp_beat_xfrs_max               = 2;
    int k_slv_rsp_burst_pct                   = 80;
    int k_slv_rsp_back_pres_min               = 0;
    int k_slv_rsp_back_pres_max               = 2;
    bit k_slv_delay                           = 1;
    int wt_cmd_cln_unq                        = 5;
    int wt_cmd_cln_vld                        = 5;
    int wt_cmd_cln_inv                        = 5;
    int wt_cmd_wr_unq_ptl                     = 10;
    int wt_cmd_wr_unq_full                    = 10;
    int wt_cmd_upd_inv                        = 5;
    int wt_cmd_upd_vld                        = 5;
    bit aiu_scb_en                            = 1;
    int wt_ace_rdnosnp                        = 5;
    int wt_ace_rdonce                         = 5;
    <% if (obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5"){%>    
        int wt_ace_rdshrd                         = -1;
        int wt_ace_rdcln                          = -1;
        int wt_ace_rdnotshrddty                   = -1;
        int wt_ace_rdunq                          = -1;
        int wt_ace_clnunq                         = -1;
        int wt_ace_mkunq                          = -1;
    <%} else {%>      
        int wt_ace_rdshrd                         = 0;
        int wt_ace_rdcln                          = 0;
        int wt_ace_rdnotshrddty                   = 0;
        int wt_ace_rdunq                          = 0;
        int wt_ace_clnunq                         = 0;
        int wt_ace_mkunq                          = 0;
    <%}%>
    int wt_ace_dvm_msg                        = -1;
    int wt_ace_dvm_sync                       = -1;
    int wt_ace_clnshrd                        = -1;
    int wt_ace_clninvl                        = -1;
    int wt_ace_mkinvl                         = -1;
    int wt_ace_wrnosnp                        = -1;
    int wt_ace_wrunq                          = -1;
    int wt_ace_wrlnunq                        = -1;
    int wt_ace_wrcln                          = -1;
    int wt_ace_wrbk                           = -1;
    int wt_ace_wrevct                         = -1;
    int wt_ace_evct                           = -1;
    int wt_ace_wr_bar                         = 0;
    int wt_ace_rd_bar                         = 0;
    int wt_ace_stash_trans                    = 0;
    int num_sets =0;
    int k_num_snp                             = 0;
   
    <%if (((obj.fnNativeInterface == "ACELITE-E" || obj.fnNativeInterface == "AXI5")) && (computedAxiInt.params.atomicTransactions == true))  {%>
        int wt_ace_atm_str                        = -1;
        int wt_ace_atm_ld                         = -1;
        int wt_ace_atm_swap                       = -1;
        int wt_ace_atm_comp                       = -1;
    <%} else {%>
        int wt_ace_atm_str                        = 0;
        int wt_ace_atm_ld                         = 0;
        int wt_ace_atm_swap                       = 0;
        int wt_ace_atm_comp                       = 0;
    <%}%>

    <%if(obj.fnNativeInterface == "ACELITE-E"){%> 
        int wt_ace_clnshrd_pers                   = -1;
        int wt_ace_rd_cln_invld                   = -1;
        int wt_ace_rd_make_invld                  = -1;
        int wt_ace_ptl_stash                      = -1;
        int wt_ace_full_stash                     = -1;
        int wt_ace_shared_stash                   = -1;
        int wt_ace_unq_stash                      = -1;
    <%}else{%>
        <%if (obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") {%>
        int wt_ace_clnshrd_pers                   = -1;
        <%}else{%>
        int wt_ace_clnshrd_pers                   = 0;
        <%}%>
        int wt_ace_rd_cln_invld                   = 0;
        int wt_ace_rd_make_invld                  = 0;
        int wt_ace_ptl_stash                      = 0;
        int wt_ace_full_stash                     = 0;
        int wt_ace_shared_stash                   = 0;
        int wt_ace_unq_stash                      = 0;
    <%}%>
    
    int wt_snp_inv                            = 0;
    int wt_snp_cln_dtr                        = 0;
    int wt_snp_inv_stsh                       = 0;
    int wt_snp_unq_stsh                       = 0;
    int wt_snp_stsh_sh                        = 0;
    int wt_snp_stsh_unq                       = 0;
    int wt_snp_vld_dtr                        = 0;
    int wt_snp_inv_dtr                        = 0;
    int wt_snp_cln_dtw                        = 0;
    int wt_snp_inv_dtw                        = 0;
    int wt_snp_nitc                           = 0;
    int wt_snp_nitcci                         = 0;
    int wt_snp_nitcmi                         = 0;
    int wt_snp_nosdint                        = 0;
    int wt_snp_dvm_msg                        = 0;
    int wt_snp_random_addr                    = 5;
    int wt_snp_stash_addr                     = 10;
    int wt_snp_prev_addr                      = 50;
    int wt_snp_cmd_req_addr                   = 50;
    int wt_snp_ott_addr                       = 50;
    int wt_exokay_set                         = 40;
    int wt_dvm_multipart_snp                  = 20;
    int wt_dvm_sync_snp                       = 20;
    int prob_multiple_dtr_for_read            = 30;
    int prob_strreq_addr_err_inj              = 0;
    int prob_strreq_data_err_inj              = 0;
    int prob_strreq_trspt_err_inj             = 0;
    int prob_dtwrsp_data_err_inj              = 0;
    int prob_dtrreq_data_err_inj              = 0;
    int prob_cmdrsp_trspt_sec_err_inj         = 0;
    int prob_upddtwrsp_trspt_sec_err_inj      = 0;
    int prob_cmdrsp_trspt_tmo_err_inj         = 0;
    int prob_upddtwrsp_trspt_tmo_err_inj      = 0;
    int prob_cmdrsp_trspt_disc_err_inj        = 0;
    int prob_upddtwrsp_trspt_disc_err_inj     = 0;
    int prob_dtrdatavis_trspt_sec_err_inj     = 0;
    int prob_dtrdatavis_trspt_tmo_err_inj     = 0;
    int prob_dtrdatavis_trspt_disc_err_inj    = 0;
    int prob_dtrdatavis_addr_err_inj          = 0;
    int dis_delay_dtr_req                     = 0;
    int dis_delay_str_req                     = 0;
    int dis_delay_slave_resp                  = 0;
    int high_system_bfm_slv_rsp_delays        = 0;
    int k_ace_master_read_addr_chnl_delay_min = 1;
    int k_ace_master_read_addr_chnl_delay_max = 3;
    int k_ace_master_read_addr_chnl_burst_pct = 80;
    int k_ace_master_read_data_chnl_delay_min = 1;
    int k_ace_master_read_data_chnl_delay_max = 3;
    int k_ace_master_read_data_chnl_burst_pct = 80;
    int k_ace_master_write_addr_chnl_delay_min= 1;
    int k_ace_master_write_addr_chnl_delay_max= 3;
    int k_ace_master_write_addr_chnl_burst_pct= 80;
    int k_ace_master_write_data_chnl_delay_min= 1;
    int k_ace_master_write_data_chnl_delay_max= 3;
    int k_ace_master_write_data_chnl_burst_pct= 80;
    int k_ace_master_write_resp_chnl_delay_min= 1;
    int k_ace_master_write_resp_chnl_delay_max= 3;
    int k_ace_master_write_resp_chnl_burst_pct= 80;
    int k_ace_master_snoop_addr_chnl_delay_min= 1;
    int k_ace_master_snoop_addr_chnl_delay_max= 3;
    int k_ace_master_snoop_addr_chnl_burst_pct= 80;
    int k_ace_master_snoop_data_chnl_delay_min= 1;
    int k_ace_master_snoop_data_chnl_delay_max= 3;
    int k_ace_master_snoop_data_chnl_burst_pct= 80;
    int k_ace_master_snoop_resp_chnl_delay_min= 1;
    int k_ace_master_snoop_resp_chnl_delay_max= 3;
    int k_ace_master_snoop_resp_chnl_burst_pct= 80;
    bit k_is_bfm_delay_changing               = 0;
    int k_bfm_delay_changing_time             = 20000;
    int k_ace_slave_read_addr_chnl_delay_min  = 1;
    int k_ace_slave_read_addr_chnl_delay_max  = 3;
    int k_ace_slave_read_addr_chnl_burst_pct  = 80;
    int k_ace_slave_read_data_chnl_delay_min  = 1;
    int k_ace_slave_read_data_chnl_delay_max  = 3;
    int k_ace_slave_read_data_chnl_burst_pct  = 80;
    int k_ace_slave_read_data_reorder_size    = 4;
    int k_ace_slave_read_data_interleave_dis  = 0;
    int k_ace_slave_write_addr_chnl_delay_min = 1;
    int k_ace_slave_write_addr_chnl_delay_max = 3;
    int k_ace_slave_write_addr_chnl_burst_pct = 80;
    int k_ace_slave_write_data_chnl_delay_min = 1;
    int k_ace_slave_write_data_chnl_delay_max = 3;
    int k_ace_slave_write_data_chnl_burst_pct = 80;
    int k_ace_slave_write_resp_chnl_delay_min = 1;
    int k_ace_slave_write_resp_chnl_delay_max = 3;
    int k_ace_slave_write_resp_chnl_burst_pct = 80;
    int k_ace_slave_snoop_addr_chnl_delay_min = 1;
    int k_ace_slave_snoop_addr_chnl_delay_max = 3;
    int k_ace_slave_snoop_addr_chnl_burst_pct = 80;
    int k_ace_slave_snoop_data_chnl_delay_min = 1;
    int k_ace_slave_snoop_data_chnl_delay_max = 3;
    int k_ace_slave_snoop_data_chnl_burst_pct = 80;
    int k_ace_slave_snoop_resp_chnl_delay_min = 1;
    int k_ace_slave_snoop_resp_chnl_delay_max = 3;
    int k_ace_slave_snoop_resp_chnl_burst_pct = 80;

    int k_sfi_cmd_rsp_delay_min               = 1;
    int k_sfi_cmd_rsp_delay_max               = 3;
    int k_sfi_cmd_rsp_burst_pct               = 80;
    int k_sfi_dtw_rsp_delay_min               = 1;
    int k_sfi_dtw_rsp_delay_max               = 3;
    int k_sfi_dtw_rsp_burst_pct               = 80;
    int k_sfi_upd_rsp_delay_min               = 1;
    int k_sfi_upd_rsp_delay_max               = 3;
    int k_sfi_upd_rsp_burst_pct               = 80;
    bit k_slow_agent                          = 0;
    bit k_slow_read_agent                     = 0;
    bit k_slow_write_agent                    = 0;
    bit k_slow_snoop_agent                    = 0;
    bit flag                                  = 0;
    int prob_ace_snp_resp_error               = 0;
    int prob_ace_rd_resp_error                = 0;
    int prob_ace_wr_resp_error                = 0;
    int prob_ace_coh_win_error                = 0;
    bit no_updates                            = 0;
    bit gen_no_non_coh_traffic                = 0;
    bit gen_no_delay_traffic                  = 0;
    int wt_illegal_op_addr                    = 0;
    bit k_smi_cov_en                          = 1;
   <% if(obj.testBench == 'io_aiu') { %>
  `ifndef VCS
    event e_tb_clk;
  `else // `ifndef VCS
    uvm_event e_tb_clk;
  `endif // `ifndef VCS ... `else ... 
  <% } else {%>
    event e_tb_clk;
  <% } %>
   
    <%if(obj.INHOUSE_APB_VIP){%>   
        int k_apb_mcmd_delay_min              = 0;
        int k_apb_mcmd_delay_max              = 1;
        int k_apb_mcmd_burst_pct              = 90;
        bit k_apb_mcmd_wait_for_scmdaccept    = 0;
        int k_apb_maccept_delay_min           = 0;
        int k_apb_maccept_delay_max           = 1;
        int k_apb_maccept_burst_pct           = 90;
        bit k_apb_maccept_wait_for_sresp      = 0;
        bit k_slow_apb_agent                  = 0;
        bit k_slow_apb_mcmd_agent             = 0;
        bit k_slow_apb_mrespaccept_agent      = 0;
    <%}%>
    string k_csr_seq = "";
    string k_csr_SMC_mntop_seq = "";
    string k_mntop_debug_read_write_seq = "";
    
    bit dvm_resp_order = $urandom_range(0,1);
    int select_core  = 0; //CONC-11666 cerr threshold only controlled by core0
    bit [<%=Math.log2(obj.AiuInfo[obj.Id].ccpParams.nDataBanks)%>-1:0]sel_bank = $urandom_range(0,<%=obj.AiuInfo[obj.Id].ccpParams.nDataBanks%>-1);
    randc ace_command_types_enum_t ioaiu_opcode_inst;
    bit [<%=(Math.log2(obj.AiuInfo[obj.Id].cmpInfo.nOttDataBanks))%>-1:0] sel_ott_bank = $urandom_range(0,<%=(obj.AiuInfo[obj.Id].cmpInfo.nOttDataBanks-1)%>);
    TRIG_TCTRLR_t    tctrlr[<%=obj.DutInfo.nTraceRegisters%>];
    TRIG_TBALR_t     tbalr[<%=obj.DutInfo.nTraceRegisters%>];
    TRIG_TBAHR_t     tbahr[<%=obj.DutInfo.nTraceRegisters%>];
    TRIG_TOPCR0_t    topcr0[<%=obj.DutInfo.nTraceRegisters%>];
    TRIG_TOPCR1_t    topcr1[<%=obj.DutInfo.nTraceRegisters%>];
    TRIG_TUBR_t      tubr[<%=obj.DutInfo.nTraceRegisters%>];
    TRIG_TUBMR_t     tubmr[<%=obj.DutInfo.nTraceRegisters%>];

    virtual <%=obj.BlockId%>_probe_if u_csr_probe_vif[<%=obj.DutInfo.nNativeInterfacePorts%>];

    `uvm_component_utils_begin(base_test)
        //`uvm_field_longint(k_timeout                             ,UVM_DEC);
        `uvm_field_int(k_num_addr                            ,UVM_DEC);
        `uvm_field_int(k_num_read_req                        ,UVM_DEC);
        `uvm_field_int(k_num_eviction_req                    ,UVM_DEC);
        `uvm_field_int(k_num_write_req                       ,UVM_DEC);
        `uvm_field_int(prob_unq_cln_to_unq_dirty             ,UVM_DEC);
        `uvm_field_int(prob_unq_cln_to_invalid               ,UVM_DEC);
        `uvm_field_int(total_outstanding_coh_writes          ,UVM_DEC);
        `uvm_field_int(total_min_ace_cache_size              ,UVM_DEC);
        `uvm_field_int(total_max_ace_cache_size              ,UVM_DEC);
        `uvm_field_int(size_of_wr_queue_before_flush         ,UVM_DEC);
        `uvm_field_int(wt_expected_end_state                 ,UVM_DEC);
        `uvm_field_int(wt_legal_end_state_with_sf            ,UVM_DEC);
        `uvm_field_int(wt_legal_end_state_without_sf         ,UVM_DEC);
        `uvm_field_int(wt_expected_start_state               ,UVM_DEC);
        `uvm_field_int(wt_legal_start_state                  ,UVM_DEC);
        `uvm_field_int(wt_lose_cache_line_on_snps            ,UVM_DEC);
        `uvm_field_int(wt_keep_drty_cache_line_on_snps       ,UVM_DEC);
        `uvm_field_int(prob_respond_to_snoop_coll_with_wr    ,UVM_DEC);
        `uvm_field_int(prob_was_unique_snp_resp              ,UVM_DEC);
        `uvm_field_int(prob_was_unique_always0_snp_resp      ,UVM_DEC);
        `uvm_field_int(prob_dataxfer_snp_resp_on_clean_hit   ,UVM_DEC);
        `uvm_field_int(prob_ace_wr_ix_start_state            ,UVM_DEC);
        `uvm_field_int(prob_ace_rd_ix_start_state            ,UVM_DEC);
        `uvm_field_int(prob_cache_flush_mode_per_1k          ,UVM_DEC);
        `uvm_field_int(k_reorder_rsp_max                     ,UVM_DEC);
        `uvm_field_int(k_reorder_rsp_tmr                     ,UVM_DEC);
        `uvm_field_int(k_mst_req_back_pres_min               ,UVM_DEC);
        `uvm_field_int(k_mst_req_back_pres_max               ,UVM_DEC);
        `uvm_field_int(k_mst_req_burst_pct                   ,UVM_DEC);
        `uvm_field_int(k_mst_req_beat_xfrs_min               ,UVM_DEC);
        `uvm_field_int(k_mst_req_beat_xfrs_max               ,UVM_DEC);
        `uvm_field_int(k_mst_rsp_beat_xfrs_min               ,UVM_DEC);
        `uvm_field_int(k_mst_rsp_beat_xfrs_max               ,UVM_DEC);
        `uvm_field_int(k_mst_rsp_burst_pct                   ,UVM_DEC);
        `uvm_field_int(k_mst_rsp_back_pres_min               ,UVM_DEC);
        `uvm_field_int(k_mst_rsp_back_pres_max               ,UVM_DEC);
        `uvm_field_int(k_mst_delay                           ,UVM_DEC);
        `uvm_field_int(k_slv_req_back_pres_min               ,UVM_DEC);
        `uvm_field_int(k_slv_req_back_pres_max               ,UVM_DEC);
        `uvm_field_int(k_slv_req_burst_pct                   ,UVM_DEC);
        `uvm_field_int(k_slv_req_beat_xfrs_min               ,UVM_DEC);
        `uvm_field_int(k_slv_req_beat_xfrs_max               ,UVM_DEC);
        `uvm_field_int(k_slv_rsp_beat_xfrs_min               ,UVM_DEC);
        `uvm_field_int(k_slv_rsp_beat_xfrs_max               ,UVM_DEC);
        `uvm_field_int(k_slv_rsp_burst_pct                   ,UVM_DEC);
        `uvm_field_int(k_slv_rsp_back_pres_min               ,UVM_DEC);
        `uvm_field_int(k_slv_rsp_back_pres_max               ,UVM_DEC);
        `uvm_field_int(k_slv_delay                           ,UVM_DEC);
        `uvm_field_int(aiu_scb_en                            ,UVM_BIN);
        `uvm_field_int(no_updates                            ,UVM_BIN);
        `uvm_field_int(wt_ace_rdnosnp                        ,UVM_DEC);
        `uvm_field_int(wt_ace_rdonce                         ,UVM_DEC);
        `uvm_field_int(wt_ace_rdshrd                         ,UVM_DEC);
        `uvm_field_int(wt_ace_rdcln                          ,UVM_DEC);
        `uvm_field_int(wt_ace_rdnotshrddty                   ,UVM_DEC);
        `uvm_field_int(wt_ace_rdunq                          ,UVM_DEC);
        `uvm_field_int(wt_ace_clnunq                         ,UVM_DEC);
        `uvm_field_int(wt_ace_mkunq                          ,UVM_DEC);
        `uvm_field_int(wt_ace_dvm_msg                        ,UVM_DEC);
        `uvm_field_int(wt_ace_dvm_sync                       ,UVM_DEC);
        `uvm_field_int(wt_ace_clnshrd                        ,UVM_DEC);
        `uvm_field_int(wt_ace_clninvl                        ,UVM_DEC);
        `uvm_field_int(wt_ace_mkinvl                         ,UVM_DEC);
        `uvm_field_int(wt_ace_rd_bar                         ,UVM_DEC);
        `uvm_field_int(wt_ace_wrnosnp                        ,UVM_DEC);
        `uvm_field_int(wt_ace_wrunq                          ,UVM_DEC);
        `uvm_field_int(wt_ace_wrlnunq                        ,UVM_DEC);
        `uvm_field_int(wt_ace_wrcln                          ,UVM_DEC);
        `uvm_field_int(wt_ace_wrbk                           ,UVM_DEC);
        `uvm_field_int(wt_ace_wrevct                         ,UVM_DEC);
        `uvm_field_int(wt_ace_evct                           ,UVM_DEC);
        `uvm_field_int(wt_ace_wr_bar                         ,UVM_DEC);
        `uvm_field_int(wt_ace_atm_str                        ,UVM_DEC);
        `uvm_field_int(wt_ace_atm_ld                         ,UVM_DEC);
        `uvm_field_int(wt_ace_atm_swap                       ,UVM_DEC);
        `uvm_field_int(wt_ace_atm_comp                       ,UVM_DEC);
        `uvm_field_int(wt_ace_ptl_stash                      ,UVM_DEC);
        `uvm_field_int(wt_ace_full_stash                     ,UVM_DEC);
        `uvm_field_int(wt_ace_shared_stash                   ,UVM_DEC);
        `uvm_field_int(wt_ace_unq_stash                      ,UVM_DEC);
        `uvm_field_int(wt_ace_stash_trans                    ,UVM_DEC);
        `uvm_field_int(k_num_snp                             ,UVM_DEC);
        `uvm_field_int(num_sets                              ,UVM_DEC);
        `uvm_field_int(wt_snp_inv                            ,UVM_DEC);
        `uvm_field_int(wt_snp_cln_dtr                        ,UVM_DEC);
        `uvm_field_int(wt_snp_inv_stsh                       ,UVM_DEC);
        `uvm_field_int(wt_snp_unq_stsh                       ,UVM_DEC);
        `uvm_field_int(wt_snp_stsh_sh                        ,UVM_DEC);
        `uvm_field_int(wt_snp_stsh_unq                       ,UVM_DEC);
        `uvm_field_int(wt_snp_vld_dtr                        ,UVM_DEC);
        `uvm_field_int(wt_snp_inv_dtr                        ,UVM_DEC);
        `uvm_field_int(wt_snp_cln_dtw                        ,UVM_DEC);
        `uvm_field_int(wt_snp_inv_dtw                        ,UVM_DEC);
        `uvm_field_int(wt_snp_nitc                           ,UVM_DEC);
        `uvm_field_int(wt_snp_nitcci                         ,UVM_DEC);
        `uvm_field_int(wt_snp_nitcmi                         ,UVM_DEC);
        `uvm_field_int(wt_snp_nosdint                        ,UVM_DEC);
        `uvm_field_int(wt_snp_dvm_msg                        ,UVM_DEC);
        `uvm_field_int(wt_snp_random_addr                    ,UVM_DEC);
        `uvm_field_int(wt_snp_stash_addr                     ,UVM_DEC);
        `uvm_field_int(wt_snp_prev_addr                      ,UVM_DEC);
        `uvm_field_int(wt_snp_cmd_req_addr                   ,UVM_DEC);
        `uvm_field_int(wt_exokay_set                         ,UVM_DEC);
        `uvm_field_int(wt_dvm_multipart_snp                  ,UVM_DEC);
        `uvm_field_int(wt_dvm_sync_snp                       ,UVM_DEC);
        `uvm_field_int(prob_multiple_dtr_for_read            ,UVM_DEC);
        `uvm_field_int(prob_strreq_addr_err_inj              ,UVM_DEC);
        `uvm_field_int(prob_strreq_data_err_inj              ,UVM_DEC);
        `uvm_field_int(prob_strreq_trspt_err_inj             ,UVM_DEC);
        `uvm_field_int(prob_dtwrsp_data_err_inj              ,UVM_DEC);
        `uvm_field_int(prob_dtrreq_data_err_inj              ,UVM_DEC);
        `uvm_field_int(prob_cmdrsp_trspt_sec_err_inj         ,UVM_DEC);
        `uvm_field_int(prob_upddtwrsp_trspt_sec_err_inj      ,UVM_DEC);
        `uvm_field_int(prob_cmdrsp_trspt_tmo_err_inj         ,UVM_DEC);
        `uvm_field_int(prob_upddtwrsp_trspt_tmo_err_inj      ,UVM_DEC);
        `uvm_field_int(prob_cmdrsp_trspt_disc_err_inj        ,UVM_DEC);
        `uvm_field_int(prob_upddtwrsp_trspt_disc_err_inj     ,UVM_DEC);
        `uvm_field_int(prob_dtrdatavis_trspt_sec_err_inj     ,UVM_DEC);
        `uvm_field_int(prob_dtrdatavis_trspt_tmo_err_inj     ,UVM_DEC);
        `uvm_field_int(prob_dtrdatavis_trspt_disc_err_inj    ,UVM_DEC);
        `uvm_field_int(prob_dtrdatavis_addr_err_inj          ,UVM_DEC);
        `uvm_field_int(dis_delay_dtr_req                     ,UVM_DEC);
        `uvm_field_int(dis_delay_str_req                     ,UVM_DEC);
        `uvm_field_int(dis_delay_slave_resp                  ,UVM_DEC);
        `uvm_field_int(high_system_bfm_slv_rsp_delays        ,UVM_DEC);
        `uvm_field_int(k_ace_master_read_addr_chnl_delay_min ,UVM_DEC);
        `uvm_field_int(k_ace_master_read_addr_chnl_delay_max ,UVM_DEC);
        `uvm_field_int(k_ace_master_read_addr_chnl_burst_pct ,UVM_DEC);
        `uvm_field_int(k_ace_master_read_data_chnl_delay_min ,UVM_DEC);
        `uvm_field_int(k_ace_master_read_data_chnl_delay_max ,UVM_DEC);
        `uvm_field_int(k_ace_master_read_data_chnl_burst_pct ,UVM_DEC);
        `uvm_field_int(k_ace_master_write_addr_chnl_delay_min,UVM_DEC);
        `uvm_field_int(k_ace_master_write_addr_chnl_delay_max,UVM_DEC);
        `uvm_field_int(k_ace_master_write_addr_chnl_burst_pct,UVM_DEC);
        `uvm_field_int(k_ace_master_write_data_chnl_delay_min,UVM_DEC);
        `uvm_field_int(k_ace_master_write_data_chnl_delay_max,UVM_DEC);
        `uvm_field_int(k_ace_master_write_data_chnl_burst_pct,UVM_DEC);
        `uvm_field_int(k_ace_master_write_resp_chnl_delay_min,UVM_DEC);
        `uvm_field_int(k_ace_master_write_resp_chnl_delay_max,UVM_DEC);
        `uvm_field_int(k_ace_master_write_resp_chnl_burst_pct,UVM_DEC);
        `uvm_field_int(k_ace_master_snoop_addr_chnl_delay_min,UVM_DEC);
        `uvm_field_int(k_ace_master_snoop_addr_chnl_delay_max,UVM_DEC);
        `uvm_field_int(k_ace_master_snoop_addr_chnl_burst_pct,UVM_DEC);
        `uvm_field_int(k_ace_master_snoop_data_chnl_delay_min,UVM_DEC);
        `uvm_field_int(k_ace_master_snoop_data_chnl_delay_max,UVM_DEC);
        `uvm_field_int(k_ace_master_snoop_data_chnl_burst_pct,UVM_DEC);
        `uvm_field_int(k_ace_master_snoop_resp_chnl_delay_min,UVM_DEC);
        `uvm_field_int(k_ace_master_snoop_resp_chnl_delay_max,UVM_DEC);
        `uvm_field_int(k_ace_master_snoop_resp_chnl_burst_pct,UVM_DEC);
        `uvm_field_int(k_is_bfm_delay_changing               ,UVM_DEC);
        `uvm_field_int(k_bfm_delay_changing_time             ,UVM_DEC);
        `uvm_field_int(k_ace_slave_read_addr_chnl_delay_min  ,UVM_DEC);
        `uvm_field_int(k_ace_slave_read_addr_chnl_delay_max  ,UVM_DEC);
        `uvm_field_int(k_ace_slave_read_addr_chnl_burst_pct  ,UVM_DEC);
        `uvm_field_int(k_ace_slave_read_data_chnl_delay_min  ,UVM_DEC);
        `uvm_field_int(k_ace_slave_read_data_chnl_delay_max  ,UVM_DEC);
        `uvm_field_int(k_ace_slave_read_data_chnl_burst_pct  ,UVM_DEC);
        `uvm_field_int(k_ace_slave_read_data_reorder_size    ,UVM_DEC);
        `uvm_field_int(k_ace_slave_read_data_interleave_dis  ,UVM_DEC);
        `uvm_field_int(k_ace_slave_write_addr_chnl_delay_min , UVM_DEC);
        `uvm_field_int(k_ace_slave_write_addr_chnl_delay_max , UVM_DEC);
        `uvm_field_int(k_ace_slave_write_addr_chnl_burst_pct , UVM_DEC);
        `uvm_field_int(k_ace_slave_write_data_chnl_delay_min , UVM_DEC);
        `uvm_field_int(k_ace_slave_write_data_chnl_delay_max , UVM_DEC);
        `uvm_field_int(k_ace_slave_write_data_chnl_burst_pct , UVM_DEC);
        `uvm_field_int(k_ace_slave_write_resp_chnl_delay_min , UVM_DEC);
        `uvm_field_int(k_ace_slave_write_resp_chnl_delay_max , UVM_DEC);
        `uvm_field_int(k_ace_slave_write_resp_chnl_burst_pct , UVM_DEC);
        `uvm_field_int(k_ace_slave_snoop_addr_chnl_delay_min , UVM_DEC);
        `uvm_field_int(k_ace_slave_snoop_addr_chnl_delay_max , UVM_DEC);
        `uvm_field_int(k_ace_slave_snoop_addr_chnl_burst_pct , UVM_DEC);
        `uvm_field_int(k_ace_slave_snoop_data_chnl_delay_min , UVM_DEC);
        `uvm_field_int(k_ace_slave_snoop_data_chnl_delay_max , UVM_DEC);
        `uvm_field_int(k_ace_slave_snoop_data_chnl_burst_pct , UVM_DEC);
        `uvm_field_int(k_ace_slave_snoop_resp_chnl_delay_min , UVM_DEC);
        `uvm_field_int(k_ace_slave_snoop_resp_chnl_delay_max , UVM_DEC);
        `uvm_field_int(k_ace_slave_snoop_resp_chnl_burst_pct , UVM_DEC);
        `uvm_field_int(k_sfi_cmd_rsp_delay_min               , UVM_DEC);
        `uvm_field_int(k_sfi_cmd_rsp_delay_max               , UVM_DEC);
        `uvm_field_int(k_sfi_cmd_rsp_burst_pct               , UVM_DEC);
        `uvm_field_int(k_sfi_dtw_rsp_delay_min               , UVM_DEC);
        `uvm_field_int(k_sfi_dtw_rsp_delay_max               , UVM_DEC);
        `uvm_field_int(k_sfi_dtw_rsp_burst_pct               , UVM_DEC);
        `uvm_field_int(k_sfi_upd_rsp_delay_min               , UVM_DEC);
        `uvm_field_int(k_sfi_upd_rsp_delay_max               , UVM_DEC);
        `uvm_field_int(k_sfi_upd_rsp_burst_pct               , UVM_DEC);
        `uvm_field_int(k_slow_agent                          , UVM_DEC);
        `uvm_field_int(k_slow_read_agent                     , UVM_DEC);
        `uvm_field_int(k_slow_write_agent                    , UVM_DEC);
        `uvm_field_int(k_slow_snoop_agent                    , UVM_DEC);
        `uvm_field_int(prob_ace_rd_resp_error                , UVM_DEC);
        `uvm_field_int(prob_ace_wr_resp_error                , UVM_DEC);
        `uvm_field_int(prob_ace_snp_resp_error               , UVM_DEC);
        `uvm_field_int(prob_ace_coh_win_error                , UVM_DEC);
        <%if(obj.INHOUSE_APB_VIP){%>
            `uvm_field_int(k_apb_mcmd_delay_min              , UVM_DEC);
            `uvm_field_int(k_apb_mcmd_delay_max              , UVM_DEC);
            `uvm_field_int(k_apb_mcmd_burst_pct              , UVM_DEC);
            `uvm_field_int(k_apb_mcmd_wait_for_scmdaccept    , UVM_DEC);
            `uvm_field_int(k_apb_maccept_delay_min           , UVM_DEC);
            `uvm_field_int(k_apb_maccept_delay_max           , UVM_DEC);
            `uvm_field_int(k_apb_maccept_burst_pct           , UVM_DEC);
            `uvm_field_int(k_apb_maccept_wait_for_sresp      , UVM_DEC);
            `uvm_field_int(k_slow_apb_agent                  , UVM_DEC);
            `uvm_field_int(k_slow_apb_mcmd_agent             , UVM_DEC);
            `uvm_field_int(k_slow_apb_mrespaccept_agent      , UVM_DEC);
        <%}%>
        `uvm_field_string(k_csr_seq                          , UVM_STRING);
        `uvm_field_string(k_csr_SMC_mntop_seq                , UVM_STRING);
        `uvm_field_string(k_mntop_debug_read_write_seq       , UVM_STRING);
    `uvm_component_utils_end
  
    uvm_report_server urs;
    int               error_count;
    int               fatal_count;
    addr_trans_mgr    m_addr_mgr;

    extern virtual function void configure_axi_agent(ref axi_agent_config cfg[<%=obj.DutInfo.nNativeInterfacePorts%>]);

    function new(string name = "base_test", uvm_component parent=null);
        super.new(name,parent);
        gen_no_non_coh_traffic = ($urandom_range(0,100) < 15);
        gen_no_delay_traffic   = ($urandom_range(0,100) < 15);


        m_addr_mgr = addr_trans_mgr::get_instance();
        m_addr_mgr.gen_memory_map();

 <% if (obj.testBench != "fsys" && obj.testBench != "emu") { %>
        <%for(let i=0; i<obj.DutInfo.nNativeInterfacePorts; i++) {%>
            m_env_cfg[<%=i%>]                       = ioaiu_env_config::type_id::create("m_env_cfg[<%=i%>]", this);
        <%}%>
          m_env_cfg[0].hasRAL = 1;
        <%for(let i=0; i<obj.DutInfo.nNativeInterfacePorts; i++) {%>
            m_env_cfg[<%=i%>].m_q_chnl_agent_cfg     = q_chnl_agent_config::type_id::create("m_q_chnl_agent_config",  this);
                m_axi_master_cfg[<%=i%>]    = axi_agent_config::type_id::create("m_axi_master_agent_cfg[<%=i%>] ", this) ;                                        
                m_axi_slave_cfg[<%=i%>]     = axi_agent_config::type_id::create("m_axi_slave_agent_cfg[<%=i%>] ", this);
                m_env_cfg[<%=i%>].m_axi_master_agent_cfg = m_axi_master_cfg[<%=i%>];
                m_env_cfg[<%=i%>].m_axi_slave_agent_cfg  = m_axi_slave_cfg[<%=i%>];
        <%}%>
            <%if(( obj.DutInfo.useCache)) { %>
                <%for(var i = 0; i < obj.DutInfo.nNativeInterfacePorts; i++){%>
                    m_ccp_cfg[<%=i%>]        = ccp_agent_config::type_id::create("m_ccp_agent_cfg[<%=i%>])", this);
                    m_ccp_cfg[<%=i%>].active = UVM_PASSIVE;
                    uvm_config_db#(ccp_agent_config)::set(this,"mp_env.m_env[<%=i%>]","ccp_agent_config",m_ccp_cfg[<%=i%>]);
                    m_env_cfg[<%=i%>].m_ccp_agent_cfg = m_ccp_cfg[<%=i%>];
                <%}%>
            <%}%>
            <%for(var i = 0; i < obj.DutInfo.nNativeInterfacePorts; i++){%>
                uvm_config_db#(ioaiu_env_config)::set(uvm_root::get(), "uvm_test_top.mp_env.m_env[<%=i%>]", "ioaiu_env_config", m_env_cfg[<%=i%>]);
                //uvm_config_db#(ioaiu_env_config)::set(uvm_root::get(), "*", "ioaiu_env_config_<%=i%>", m_env_cfg[<%=i%>]);
                uvm_config_db#(axi_agent_config)::set(this, "mp_env.m_env[<%=i%>].*", "axi_master_agent_config", m_axi_master_cfg[<%=i%>]);
                uvm_config_db#(axi_agent_config)::set(this, "mp_env.m_env[<%=i%>].*", "axi_slave_agent_config", m_axi_slave_cfg[<%=i%>]);
                if(!uvm_config_db#(virtual <%=obj.BlockId%>_axi_cmdreq_id_if)::get(uvm_root::get(), "*","<%=obj.BlockId%>_axi_cmdreq_id_vif_<%=i%>", axi_cmdreq_id_if[<%=i%>])) begin
          `uvm_fatal(get_full_name(),"Could not find m_env_cfg handle")
                end
                m_env_cfg[<%=i%>].axi_cmdreq_id_if = axi_cmdreq_id_if[<%=i%>];
            <%}%>
            <%if((obj.DutInfo.useCache)){%>
                <%for(var i = 0; i < obj.DutInfo.nNativeInterfacePorts; i++){%>
                    uvm_config_db#(ccp_agent_config)::set(this, "mp_env.m_env[<%=i%>].*", "ccp_agent_config", m_env_cfg[<%=i%>].m_ccp_agent_cfg);
                <%}%>
            <%}%>

<%}%>
    endfunction: new

    virtual function void build_phase(uvm_phase phase);
        string arg_value;
        `uvm_info("build_phase", "Entered...", UVM_LOW)

        super.build_phase(phase);
        <%if(obj.NO_SYS_BFM === undefined) { %>
            m_system_bfm_seq = system_bfm_seq::type_id::create("m_system_bfm_seq");
        <%}%>
        <%for(var i = 0; i < obj.DutInfo.nNativeInterfacePorts; i++){%>
            m_ace_cache_model[<%=i%>] = new("c<%=i%>_ace_cache_model");
	        if($test$plusargs("cache_model_dbg_en")) begin
		    m_ace_cache_model[<%=i%>].cache_model_dbg_en = 1;
	    end
        <%}%>
        //env = ioaiu_env::type_id::create("env", this) 
        mp_env = ioaiu_multiport_env::type_id::create("mp_env", this);
        uvm_config_db#(ioaiu_multiport_env)::set(uvm_root::get(), "", "mp_env",mp_env);
        `ifdef USE_VIP_SNPS  
        axi_system_env = svt_amba_env_class_pkg::svt_amba_env::type_id::create ("axi_system_env", this);
        uvm_config_db#(svt_amba_env_class_pkg::svt_amba_env)::set(uvm_root::get(), "", "axi_system_env", axi_system_env);
        svt_cfg = cust_svt_amba_system_configuration::type_id::create("svt_cfg");
        svt_cfg.set_amba_sys_config(); //supply set_amba_sys_config to downstream cfg_h
        //svt_cfg.reduce_mem_size = reduce_mem_size;
         uvm_config_db#(cust_svt_amba_system_configuration)::set(this, "axi_system_env", "svt_cfg", svt_cfg);

            /*if (cfg == null) begin
                cfg = ace_env_config::type_id::create("cfg");
            end
            cfg.m_addr_mgr = m_addr_mgr;
            cfg.set_ace_config();
            cfg.set_ace_domains();*/
            //set_type_override_by_type (svt_axi_master_transaction::get_type(), ioaiu_axi_master_transaction::get_type(),1);
            //set_inst_override_by_type ({get_full_name, ".","axi_system_env.master[0].snoop_sequencer.*"},svt_axi_master_snoop_transaction::get_type(), ioaiu_axi_master_snoop_transaction::get_type());
            //uvm_config_db#(svt_axi_system_configuration)::set(this, "axi_system_env", "cfg", cfg);
        `endif
        //m_env_cfg                       = ioaiu_env_config::type_id::create("m_env_cfg", this);
        // m_ioaiu_vseqr                   = axi_virtual_sequencer::type_id::create("m_ioaiu_vseqr", this);		
        // FIXME : Move lines below to mp_env once everything is stable
        //<%for(var i = 0; i < obj.DutInfo.nNativeInterfacePorts; i++){%>
       //     m_env_cfg[<%=i%>].m_q_chnl_agent_cfg    = q_chnl_agent_config::type_id::create("m_q_chnl_agent_config",  this);
       // <%}%>

        <%for(var i = 0; i < obj.DutInfo.nNativeInterfacePorts; i++){%>
            if(!uvm_config_db#(virtual <%=obj.BlockId%>_q_chnl_if)::get(.cntxt      ( this          ),
                                                                        .inst_name  ( ""            ),
                                                                        .field_name ( "m_q_chnl_if" ),
                                                                        .value      ( m_env_cfg[<%=i%>].m_q_chnl_agent_cfg.m_vif ))) begin
                `uvm_error("base_test", "m_q_chnl_if not found")
            end
        <%}%>
	
        //m_axi_master_cfg    = axi_agent_config::type_id::create("m_axi_master_agent_cfg", this);                                        
        //m_axi_slave_cfg     = axi_agent_config::type_id::create("m_axi_slave_agent_cfg", this);                                        
		//HS: 3.4 MP updates
		// <%for(var i = 0; i < obj.DutInfo.nNativeInterfacePorts; i++){%>
        // m_axi_master_cfg[<%=i%>]    = axi_agent_config::type_id::create("m_axi_master_agent_cfg", this);                                        
        // m_axi_slave_cfg[<%=i%>]     = axi_agent_config::type_id::create("m_axi_slave_agent_cfg", this);                                        
		// <%}%>

        m_smi_agent_cfg     = smi_agent_config::type_id::create("m_smi_agent_cfg",this);
        if(clp.get_arg_value("+k_smi_cov_en=", arg_value)) begin
            k_smi_cov_en = arg_value.atoi();
        end
        m_smi_agent_cfg.cov_en = k_smi_cov_en;
        m_smi_agent_cfg.active = UVM_ACTIVE;
        <%if(obj.NO_SMI === undefined) { %>     
            <%var NSMIIFTX = obj.nSmiRx;
            for(var i = 0; i < NSMIIFTX; i++) { %>
                m_smi<%=i%>_tx_port_config = smi_port_config::type_id::create("m_smi<%=i%>_tx_port_config",this); ;
                uvm_config_db#(virtual <%=obj.BlockId%>_smi_if)::get(.cntxt     ( uvm_root::get() ),
                                                                     .inst_name ( "" ),
                                                                     .field_name( "m_smi<%=i%>_tx_port_if" ),
                                                                     .value     ( m_smi<%=i%>_tx_port_config.m_vif));
                m_smi_agent_cfg.m_smi<%=i%>_tx_port_config = m_smi<%=i%>_tx_port_config;
            <%}%>
            <% var NSMIIFRX = obj.nSmiTx;
            for (var i = 0; i < NSMIIFRX; i++) { %>
                m_smi<%=i%>_rx_port_config = smi_port_config::type_id::create("m_smi<%=i%>_rx_port_config",this); ;
                uvm_config_db#(virtual <%=obj.BlockId%>_smi_if)::get(.cntxt     (uvm_root::get() ),
                                                                     .inst_name ( "" ),
                                                                     .field_name( "m_smi<%=i%>_rx_port_if" ),
                                                                     .value     (m_smi<%=i%>_rx_port_config.m_vif));
                m_smi_agent_cfg.m_smi<%=i%>_rx_port_config = m_smi<%=i%>_rx_port_config;  
            <%}%>
        <%}%>
        // m_env_cfg.m_axi_master_agent_cfg = mp_env.m_axi_master_cfg[<%=i%>];
        // m_env_cfg.m_axi_slave_agent_cfg  = m_axi_slave_cfg[0];

        // <%if(( obj.DutInfo.useCache)) { %>                   
        //     m_ccp_cfg        = ccp_agent_config::type_id::create("m_ccp_agent_cfg", this);
        //     m_ccp_cfg.active = UVM_PASSIVE;
        //     uvm_config_db#(ccp_agent_config)::set(this,"*","ccp_agent_config",m_ccp_cfg);
        //     m_env_cfg.m_ccp_agent_cfg = m_ccp_cfg;
        // <%}%>
        uvm_config_db#(smi_agent_config)::set(null , "", "smi_agent_config",m_smi_agent_cfg);
        // uvm_config_db#(ioaiu_env_config)::set(this, "env", "ioaiu_env_config", m_env_cfg);
        // uvm_config_db#(axi_agent_config)::set(this, "env.m_axi_master_agent", "axi_master_agent_config", mp_env.m_axi_master_cfg[<%=i%>]);
        // uvm_config_db#(axi_agent_config)::set(this, "env.m_axi_slave_agent", "axi_slave_agent_config", m_axi_slave_cfg[0]);

        <%if(obj.NO_SYS_PERF === undefined) { %>
        <% if(obj.testBench == 'io_aiu') { %>
          `ifndef VCS
            if (!uvm_config_db#(event)::get(.cntxt(uvm_root::get()), 
                                            .inst_name ( "" ), 
                                            .field_name( "e_tb_clk" ),
                                            .value(e_tb_clk))) begin
            end
          `else // `ifndef VCS
            if (!uvm_config_db#(uvm_event)::get(.cntxt(uvm_root::get()), 
                                            .inst_name ( "" ), 
                                            .field_name( "e_tb_clk" ),
                                            .value(e_tb_clk))) begin
            end
          `endif // `ifndef VCS ... `else ... 
           <% } else {%>
            if (!uvm_config_db#(event)::get(.cntxt(uvm_root::get()), 
                                            .inst_name ( "" ), 
                                            .field_name( "e_tb_clk" ),
                                            .value(e_tb_clk))) begin
            end
           <%}%>
        <%}%>

        // <%if((obj.DutInfo.useCache)){%>
        //     uvm_config_db#(ccp_agent_config)::set(this, "env.m_ccp_agent", "ccp_agent_config", m_env_cfg.m_ccp_agent_cfg);
        // <%}%>

        if(clp.get_arg_value("+k_csr_seq=", arg_value)) begin
            k_csr_seq = arg_value;
            `uvm_info("IOAIU BASE TEST", $sformatf("k_csr_seq = %s",k_csr_seq), UVM_HIGH);
            flag = 1;
        end
        if (clp.get_arg_value("+k_csr_SMC_mntop_seq=", arg_value)) begin
            k_csr_SMC_mntop_seq = arg_value;
            `uvm_info("IOAIU BASE TEST", $sformatf("k_csr_SMC_mntop_seq = %s",k_csr_SMC_mntop_seq), UVM_HIGH);
            flag = 1;
        end
        if (clp.get_arg_value("+k_mntop_debug_read_write_seq=", arg_value)) begin
            k_mntop_debug_read_write_seq = arg_value;
            `uvm_info("IOAIU BASE TEST", $sformatf("k_mntop_debug_read_write_seq = %s",k_mntop_debug_read_write_seq), UVM_HIGH);
            flag = 1;
        end

        <%if(obj.INHOUSE_APB_VIP) { %>
            // apb delay knobs
            if (clp.get_arg_value("+k_apb_mcmd_delay_min=", arg_value)) begin
                k_apb_mcmd_delay_min = arg_value.atoi();
            end
            if (clp.get_arg_value("+k_apb_mcmd_delay_max=", arg_value)) begin
                k_apb_mcmd_delay_max = arg_value.atoi();
            end
            if (clp.get_arg_value("+k_apb_mcmd_burst_pct=", arg_value)) begin
                k_apb_mcmd_burst_pct = arg_value.atoi();
            end
            if (clp.get_arg_value("+k_apb_mcmd_wait_for_scmdaccept=", arg_value)) begin
                k_apb_mcmd_wait_for_scmdaccept = arg_value.atoi();
            end
            if (clp.get_arg_value("+k_apb_maccept_delay_min=", arg_value)) begin
                k_apb_maccept_delay_min = arg_value.atoi();
            end
            if (clp.get_arg_value("+k_apb_maccept_delay_max=", arg_value)) begin
                k_apb_maccept_delay_max = arg_value.atoi();
            end
            if (clp.get_arg_value("+k_apb_maccept_burst_pct=", arg_value)) begin
                k_apb_maccept_burst_pct = arg_value.atoi();
            end
            if (clp.get_arg_value("+k_apb_maccept_wait_for_sresp=", arg_value)) begin
                k_apb_maccept_wait_for_sresp = arg_value.atoi();
            end
            flag = 0;
            if (clp.get_arg_value("+k_slow_apb_agent=", arg_value)) begin
                k_slow_apb_agent = arg_value.atoi();
                flag = 1;
            end
            if (clp.get_arg_value("+k_slow_apb_mcmd_agent=", arg_value)) begin
                k_slow_apb_mcmd_agent = arg_value.atoi();
                flag = 1;
            end
            if (clp.get_arg_value("+k_slow_apb_mrespaccept_agent=", arg_value)) begin
                k_slow_apb_mrespaccept_agent = arg_value.atoi();
                flag = 1;
            end
            if (!flag) begin
                randcase
                    70: ;
                    10: k_slow_apb_agent = 1;
                    10: k_slow_apb_mcmd_agent = 1;
                    10: k_slow_apb_mrespaccept_agent = 1;
                endcase // randcase
            end
        <%}%>
        if($test$plusargs("command_line_directed_test")) begin
            wt_ace_rdonce       = 0;
            wt_ace_rdnosnp      = 0;
            wt_ace_rdshrd       = 0;
            wt_ace_rdcln        = 0;
            wt_ace_rdnotshrddty = 0;
            wt_ace_rdunq        = 0;
            wt_ace_clnunq       = 0;
            wt_ace_mkunq        = 0;
            wt_ace_dvm_msg      = 0;
            wt_ace_dvm_sync     = 0;
            wt_ace_clnshrd      = 0;
            wt_ace_clninvl      = 0;
            wt_ace_mkinvl       = 0;
            wt_ace_rd_bar       = 0;
            wt_ace_wrunq        = 0;
            wt_ace_wrlnunq      = 0;
            wt_ace_wrcln        = 0;
            wt_ace_wrbk         = 0;
            wt_ace_evct         = 0;
            wt_ace_wrevct       = 0;
            wt_ace_wr_bar       = 0;
            wt_ace_wr_bar       = 0;
            wt_ace_rd_cln_invld = 0;
            wt_ace_rd_make_invld= 0;
            wt_ace_clnshrd_pers = 0;
            wt_ace_stash_trans  = 0;        
            wt_ace_atm_str      = 0;
            wt_ace_atm_ld       = 0;
            wt_ace_atm_swap     = 0;
            wt_ace_atm_comp     = 0;
            wt_ace_ptl_stash    = 0;
            wt_ace_full_stash   = 0;
            wt_ace_shared_stash = 0;
            wt_ace_unq_stash    = 0;
            wt_snp_cln_dtr      = -1;
            wt_snp_inv_stsh     = -1;
            wt_snp_unq_stsh     = -1;
            wt_snp_stsh_sh      = -1;
            wt_snp_stsh_unq     = -1;
            wt_snp_vld_dtr      = -1;
            wt_snp_inv_dtr      = -1;
            wt_snp_inv          = -1;
            wt_snp_cln_dtw      = -1;
            wt_snp_inv_dtw      = -1;
            wt_snp_nitc         = -1;
            wt_snp_nitcci       = -1;
            wt_snp_nitcmi       = -1;
            wt_snp_nosdint      = -1;
            wt_snp_dvm_msg      = -1;
        end
        //#Stimulus.IOAIU.OWO.RdWrAtmSnp
         <%if (obj.fnNativeInterface == "ACELITE-E" && obj.DutInfo.orderedWriteObservation == true) { %> 
            wt_ace_rdshrd       = 0;
            wt_ace_rdcln        = 0;
            wt_ace_rdnotshrddty = 0;
            wt_ace_rdunq        = 0;
            wt_ace_clnunq       = 0;
            wt_ace_mkunq        = 0;
            wt_ace_dvm_msg      = 0;
            wt_ace_dvm_sync     = 0;
            wt_ace_clnshrd      = 0;
            wt_ace_clninvl      = 0;
            wt_ace_mkinvl       = 0;
            wt_ace_rd_bar       = 0;
            wt_ace_wrlnunq      = 0;
            wt_ace_wrcln        = 0;
            wt_ace_wrbk         = 0;
            wt_ace_evct         = 0;
            wt_ace_wrevct       = 0;
            wt_ace_wr_bar       = 0;
            wt_ace_wr_bar       = 0;
            wt_ace_rd_cln_invld = 0;
            wt_ace_rd_make_invld= 0;
            wt_ace_clnshrd_pers = 0;
            wt_ace_stash_trans  = 0;        
            wt_ace_ptl_stash    = 0;
            wt_ace_full_stash   = 0;
            wt_ace_shared_stash = 0;
            wt_ace_unq_stash    = 0;
         
         <%}%> 
        if($test$plusargs("zero_out_all_native_txn_wts")) begin
            wt_ace_rdonce       = 0;
            wt_ace_rdnosnp      = 0;
            wt_ace_rdshrd       = 0;
            wt_ace_rdcln        = 0;
            wt_ace_rdnotshrddty = 0;
            wt_ace_rdunq        = 0;
            wt_ace_clnunq       = 0;
            wt_ace_mkunq        = 0;
            wt_ace_dvm_msg      = 0;
            wt_ace_dvm_sync     = 0;
            wt_ace_clnshrd      = 0;
            wt_ace_clninvl      = 0;
            wt_ace_mkinvl       = 0;
            wt_ace_rd_bar       = 0;
            wt_ace_wrunq        = 0;
            wt_ace_wrnosnp      = 0;
            wt_ace_wrlnunq      = 0;
            wt_ace_wrcln        = 0;
            wt_ace_wrbk         = 0;
            wt_ace_evct         = 0;
            wt_ace_wrevct       = 0;
            wt_ace_wr_bar       = 0;
            wt_ace_wr_bar       = 0;
            wt_ace_rd_cln_invld = 0;
            wt_ace_rd_make_invld= 0;
            wt_ace_clnshrd_pers = 0;
            wt_ace_stash_trans  = 0;        
            wt_ace_atm_str      = 0;
            wt_ace_atm_ld       = 0;
            wt_ace_atm_swap     = 0;
            wt_ace_atm_comp     = 0;
            wt_ace_ptl_stash    = 0;
            wt_ace_full_stash   = 0;
            wt_ace_shared_stash = 0;
            wt_ace_unq_stash    = 0;
        end
        if($test$plusargs("zero_out_all_snp_wts")) begin
            wt_snp_cln_dtr      = -1;
            wt_snp_inv_stsh     = -1;
            wt_snp_unq_stsh     = -1;
            wt_snp_stsh_sh      = -1;
            wt_snp_stsh_unq     = -1;
            wt_snp_vld_dtr      = -1;
            wt_snp_inv_dtr      = -1;
            wt_snp_inv          = -1;
            wt_snp_cln_dtw      = -1;
            wt_snp_inv_dtw      = -1;
            wt_snp_nitc         = -1;
            wt_snp_nitcci       = -1;
            wt_snp_nitcmi       = -1;
            wt_snp_nosdint      = -1;
            wt_snp_dvm_msg      = -1;
        end
        if (clp.get_arg_value("+k_timeout=", arg_value)) begin
            k_timeout = longint'(arg_value.atoi());
        end
        if (clp.get_arg_value("+k_num_addr=", arg_value)) begin
            k_num_addr = arg_value.atoi();
        end
        else begin
            k_num_addr = $urandom_range(1,100);
        end
        if (clp.get_arg_value("+k_reorder_rsp_max=", arg_value)) begin
            k_reorder_rsp_max = arg_value.atoi();
        end
        else begin
            k_reorder_rsp_max = $urandom_range(0,50);
        end 
        if (clp.get_arg_value("+k_reorder_rsp_tmr=", arg_value)) begin
            k_reorder_rsp_tmr = arg_value.atoi();
        end
        else begin
            k_reorder_rsp_tmr = $urandom_range(0,100);
        end 
        if (clp.get_arg_value("+k_mst_req_back_pres_min=", arg_value)) begin
            k_mst_req_back_pres_min = arg_value.atoi();
        end
        else begin
            k_mst_req_back_pres_min = $urandom_range(0,15);
        end
        if (clp.get_arg_value("+k_mst_req_back_pres_max=", arg_value)) begin
            k_mst_req_back_pres_max = arg_value.atoi();
        end
        else begin
            randcase
                70 : k_mst_req_back_pres_max = $urandom_range(k_mst_req_back_pres_min,15);
                30 : k_mst_req_back_pres_max = $urandom_range(k_mst_req_back_pres_min,100);
                5 : k_mst_req_back_pres_max = $urandom_range(k_mst_req_back_pres_min,1000);
            endcase
        end
        if (clp.get_arg_value("+k_mst_req_burst_pct=", arg_value)) begin
            k_mst_req_burst_pct = arg_value.atoi();
        end
        else begin
            k_mst_req_burst_pct = $urandom_range(5,100);
        end
        if (clp.get_arg_value("+k_mst_req_beat_xfrs_min=", arg_value)) begin
            k_mst_req_beat_xfrs_min = arg_value.atoi();
        end
        else begin
            k_mst_req_beat_xfrs_min = $urandom_range(1,15);
        end
        if (clp.get_arg_value("+k_mst_req_beat_xfrs_max=", arg_value)) begin
            k_mst_req_beat_xfrs_max = arg_value.atoi();
        end
        else begin
            randcase
                70 : k_mst_req_beat_xfrs_max = $urandom_range( k_mst_req_beat_xfrs_min,15);
                30 : k_mst_req_beat_xfrs_max = $urandom_range( k_mst_req_beat_xfrs_min,100);
                5 : k_mst_req_beat_xfrs_max = $urandom_range( k_mst_req_beat_xfrs_min,1000);
            endcase
        end
        if (clp.get_arg_value("+k_mst_rsp_beat_xfrs_min=", arg_value)) begin
            k_mst_rsp_beat_xfrs_min = arg_value.atoi();
        end
        else begin
            k_mst_rsp_beat_xfrs_min = $urandom_range(1,15);
        end
        if (clp.get_arg_value("+k_mst_rsp_beat_xfrs_max=", arg_value)) begin
            k_mst_rsp_beat_xfrs_max = arg_value.atoi();
        end
        else begin
            randcase
                70 : k_mst_rsp_beat_xfrs_max = $urandom_range(k_mst_rsp_beat_xfrs_min,15);
                30 : k_mst_rsp_beat_xfrs_max = $urandom_range(k_mst_rsp_beat_xfrs_min,100);
                5 : k_mst_rsp_beat_xfrs_max = $urandom_range(k_mst_rsp_beat_xfrs_min,1000);
            endcase
        end
        if (clp.get_arg_value("+k_mst_rsp_burst_pct=", arg_value)) begin
            k_mst_rsp_burst_pct = arg_value.atoi();
        end
        else begin
            k_mst_rsp_burst_pct = $urandom_range(5,100);
        end
        if (clp.get_arg_value("+k_mst_rsp_back_pres_min=", arg_value)) begin
            k_mst_rsp_back_pres_min = arg_value.atoi();
        end
        else begin
            k_mst_rsp_back_pres_min = $urandom_range(0,15);
        end
        if (clp.get_arg_value("+k_mst_rsp_back_pres_max=", arg_value)) begin
            k_mst_rsp_back_pres_max = arg_value.atoi();
        end
        else begin
            randcase
                70 : k_mst_rsp_back_pres_max = $urandom_range(k_mst_rsp_back_pres_min,15);
                30 : k_mst_rsp_back_pres_max = $urandom_range(k_mst_rsp_back_pres_min,100);
                5 : k_mst_rsp_back_pres_max = $urandom_range(k_mst_rsp_back_pres_min,1000);
            endcase
        end
        if (clp.get_arg_value("+k_mst_delay=", arg_value)) begin
            k_mst_delay = arg_value.atoi();
        end
        else begin
            k_mst_delay = 1'b1;
        end
        if (clp.get_arg_value("+k_slv_req_back_pres_min=", arg_value)) begin
            k_slv_req_back_pres_min = arg_value.atoi();
        end
        else begin
            k_slv_req_back_pres_min = $urandom_range(0,15);
        end
        if (clp.get_arg_value("+k_slv_req_back_pres_max=", arg_value)) begin
            k_slv_req_back_pres_max = arg_value.atoi();
        end
        else begin
            randcase
                70 : k_slv_req_back_pres_max = $urandom_range(k_slv_req_back_pres_min,15);
                30 : k_slv_req_back_pres_max = $urandom_range(k_slv_req_back_pres_min,100);
                5 : k_slv_req_back_pres_max = $urandom_range(k_slv_req_back_pres_min,1000);
            endcase
        end
        if (clp.get_arg_value("+k_slv_req_burst_pct=", arg_value)) begin
            k_slv_req_burst_pct = arg_value.atoi();
        end
        else begin
            k_slv_req_burst_pct = $urandom_range(5,100);
        end
        if (clp.get_arg_value("+k_slv_req_beat_xfrs_min=", arg_value)) begin
            k_slv_req_beat_xfrs_min = arg_value.atoi();
        end
        else begin
            k_slv_req_beat_xfrs_min = $urandom_range(1,15);
        end
        if (clp.get_arg_value("+k_slv_req_beat_xfrs_max=", arg_value)) begin
            k_slv_req_beat_xfrs_max = arg_value.atoi();
        end
        else begin
            randcase
                70 : k_slv_req_beat_xfrs_max = $urandom_range(k_slv_req_beat_xfrs_min,15);
                30 : k_slv_req_beat_xfrs_max = $urandom_range(k_slv_req_beat_xfrs_min,100);
                5 : k_slv_req_beat_xfrs_max = $urandom_range(k_slv_req_beat_xfrs_min,1000);
            endcase
        end
        if (clp.get_arg_value("+k_slv_rsp_beat_xfrs_min=", arg_value)) begin
            k_slv_rsp_beat_xfrs_min = arg_value.atoi();
        end
        else begin
            k_slv_rsp_beat_xfrs_min = $urandom_range(1,15);
        end
        if (clp.get_arg_value("+k_slv_rsp_beat_xfrs_max=", arg_value)) begin
            k_slv_rsp_beat_xfrs_max = arg_value.atoi();
        end
        else begin
            randcase
                70 : k_slv_rsp_beat_xfrs_max = $urandom_range(k_slv_rsp_beat_xfrs_min,15);
                30 : k_slv_rsp_beat_xfrs_max = $urandom_range(k_slv_rsp_beat_xfrs_min,100);
                5 : k_slv_rsp_beat_xfrs_max = $urandom_range(k_slv_rsp_beat_xfrs_min,1000);
            endcase
        end
        if (clp.get_arg_value("+k_slv_rsp_burst_pct=", arg_value)) begin
            k_slv_rsp_burst_pct = arg_value.atoi();
        end
        else begin
            k_slv_rsp_burst_pct = $urandom_range(5,100);
        end
        if (clp.get_arg_value("+ k_slv_rsp_back_pres_min=", arg_value)) begin
            k_slv_rsp_back_pres_min = arg_value.atoi();
        end
        else begin
            k_slv_rsp_back_pres_min = $urandom_range(0,15);
        end
        if (clp.get_arg_value("+k_slv_rsp_back_pres_max=", arg_value)) begin
            k_slv_rsp_back_pres_max = arg_value.atoi();
        end
        else begin
            randcase
                70 : k_slv_rsp_back_pres_max = $urandom_range( k_slv_rsp_back_pres_min,15);
                30 : k_slv_rsp_back_pres_max = $urandom_range( k_slv_rsp_back_pres_min,100);
                5 : k_slv_rsp_back_pres_max = $urandom_range( k_slv_rsp_back_pres_min,1000);
            endcase
        end
        if (clp.get_arg_value("+k_slv_delay=", arg_value)) begin
            k_slv_delay = arg_value.atoi();
        end
        else begin
            k_slv_delay = 1'b1;
        end
        if (clp.get_arg_value("+aiu_scb_en=", arg_value)) begin
            aiu_scb_en = arg_value.atoi();
        end
        if (clp.get_arg_value("+wt_ace_rdnosnp=", arg_value)) begin
            wt_ace_rdnosnp = arg_value.atoi();
        end else begin
            //if(gen_no_non_coh_traffic) begin
            //    wt_ace_rdnosnp = 0;
            //end else begin
                wt_ace_rdnosnp = (wt_ace_rdnosnp == -1 ) ? $urandom_range(1,10) : wt_ace_rdnosnp;
            //end
        end
        if (clp.get_arg_value("+wt_ace_rdonce=", arg_value)) begin
            wt_ace_rdonce = arg_value.atoi();
        end        
        else begin
            wt_ace_rdonce = (wt_ace_rdonce == -1) ? $urandom_range(1,100) : wt_ace_rdonce;
        end
        <%if(obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5"){%>    
            if (clp.get_arg_value("+wt_ace_rdshrd=", arg_value)) begin
                wt_ace_rdshrd = arg_value.atoi();
            end        
            else begin
                wt_ace_rdshrd = (wt_ace_rdshrd == -1) ? $urandom_range(1,100) : wt_ace_rdshrd;
            end
            if (clp.get_arg_value("+wt_ace_rdcln=", arg_value)) begin
                wt_ace_rdcln = arg_value.atoi();
            end        
            else begin
                wt_ace_rdcln = (wt_ace_rdcln == -1) ? $urandom_range(1,100) : wt_ace_rdcln;
            end
            if (clp.get_arg_value("+wt_ace_rdnotshrddty=", arg_value)) begin
                wt_ace_rdnotshrddty = arg_value.atoi();
            end   
            else begin
                wt_ace_rdnotshrddty = (wt_ace_rdnotshrddty == -1) ? $urandom_range(1,100) : wt_ace_rdnotshrddty;
            end
            if (clp.get_arg_value("+wt_ace_rdunq=", arg_value)) begin
                wt_ace_rdunq = arg_value.atoi();
            end        
            else begin
                wt_ace_rdunq = (wt_ace_rdunq == -1) ? $urandom_range(1,100) : wt_ace_rdunq;
            end
            if (clp.get_arg_value("+wt_ace_clnunq=", arg_value)) begin
                wt_ace_clnunq = arg_value.atoi();
            end        
            else begin
                wt_ace_clnunq = (wt_ace_clnunq == -1) ? $urandom_range(1,100) : wt_ace_clnunq;
            end
            if (clp.get_arg_value("+wt_ace_mkunq=", arg_value)) begin
                wt_ace_mkunq = arg_value.atoi();
            end        
            else begin
                wt_ace_mkunq = (wt_ace_mkunq == -1) ? $urandom_range(1,100) : wt_ace_mkunq;
            end
            if (clp.get_arg_value("+wt_ace_wrcln=", arg_value)) begin
                wt_ace_wrcln = arg_value.atoi();
            end        
            else begin
                wt_ace_wrcln = (wt_ace_wrcln == -1) ? $urandom_range(1,100) : wt_ace_wrcln;
            end
            if (clp.get_arg_value("+wt_ace_wrbk=", arg_value)) begin
                wt_ace_wrbk = arg_value.atoi();
            end        
            else begin
                wt_ace_wrbk = (wt_ace_wrbk == -1) ? $urandom_range(1,100) : wt_ace_wrbk;
            end
            if (clp.get_arg_value("+wt_ace_evct=", arg_value)) begin
                wt_ace_evct = arg_value.atoi();
            end        
            else begin
                wt_ace_evct = (wt_ace_evct == -1) ? $urandom_range(1,100) : wt_ace_evct;
            end
            if (clp.get_arg_value("+wt_ace_wrevct=", arg_value)) begin
                wt_ace_wrevct = arg_value.atoi();
            end        
            else begin
                wt_ace_wrevct = (wt_ace_wrevct == -1) ? $urandom_range(1,100) : wt_ace_wrevct;
            end
        <%}%> 
        
        <%if(computedAxiInt.params.eAc) { %>
            //grab dvm cmdline args for dvm-capable masters
            if (clp.get_arg_value("+wt_ace_dvm_sync=", arg_value)) begin
                wt_ace_dvm_sync = arg_value.atoi();
            end else begin 
                wt_ace_dvm_sync = (wt_ace_dvm_sync == -1) ? $urandom_range(1,100) : wt_ace_dvm_sync;
            end
            if (clp.get_arg_value("+wt_ace_dvm_msg=", arg_value)) begin
                wt_ace_dvm_msg = arg_value.atoi();
            end else begin 
                wt_ace_dvm_msg = (wt_ace_dvm_msg == -1) ? $urandom_range(1,100) : wt_ace_dvm_msg;
            end
        <%}else{%>
            wt_ace_dvm_sync = 0;
            wt_ace_dvm_msg = 0;
        <%}%> 
    
        <%if(obj.DutInfo.orderedWriteObservation == true) {%>
           wt_ace_clnshrd = 0; 
           wt_ace_clnshrd_pers   = 0; 
           wt_ace_clninvl = 0;
           wt_ace_mkinvl = 0;
        <%}else{%>
        if (clp.get_arg_value("+wt_ace_clnshrd=", arg_value)) begin
            wt_ace_clnshrd = arg_value.atoi();
        end        
        else begin
            wt_ace_clnshrd = (wt_ace_clnshrd == -1) ? $urandom_range(1,100) : wt_ace_clnshrd;
        end
        if (clp.get_arg_value("+wt_ace_clninvl=", arg_value)) begin
            wt_ace_clninvl = arg_value.atoi();
        end        
        else begin
            wt_ace_clninvl = (wt_ace_clninvl == -1) ? $urandom_range(1,100) : wt_ace_clninvl;
        end
        if (clp.get_arg_value("+wt_ace_mkinvl=", arg_value)) begin
            wt_ace_mkinvl = arg_value.atoi();
        end        
        else begin
            wt_ace_mkinvl = (wt_ace_mkinvl == -1) ? $urandom_range(1,100) : wt_ace_mkinvl;
        end
        <% } %>

        if (clp.get_arg_value("+wt_ace_wrlnunq=", arg_value)) begin
            wt_ace_wrlnunq = arg_value.atoi();
        end        
        else begin
            wt_ace_wrlnunq = (wt_ace_wrlnunq == -1) ? $urandom_range(1,100) : wt_ace_wrlnunq;
        end
        
        if (clp.get_arg_value("+wt_ace_clnshrd_pers=", arg_value)) begin
            wt_ace_clnshrd_pers = arg_value.atoi();
        end        
        else begin
            wt_ace_clnshrd_pers = (wt_ace_clnshrd_pers == -1) ? $urandom_range(1,100) : wt_ace_clnshrd_pers;
        end
        if (clp.get_arg_value("+wt_ace_wrnosnp=", arg_value)) begin
            wt_ace_wrnosnp = arg_value.atoi();
        end
        else begin
            wt_ace_wrnosnp = (wt_ace_wrnosnp == -1 ) ? $urandom_range(1,100) : wt_ace_wrnosnp;
        end
        if (clp.get_arg_value("+wt_ace_wrunq=", arg_value)) begin
            wt_ace_wrunq = arg_value.atoi();
        end        
        else begin
            wt_ace_wrunq = (wt_ace_wrunq == -1) ? $urandom_range(1,100) : wt_ace_wrunq;
        end

        <%if((obj.fnNativeInterface == "ACELITE-E" || obj.fnNativeInterface == "AXI5") && (computedAxiInt.params.atomicTransactions == true)) {%>
           //grab atomic txn weights from cmdline for ACE-Lite-E and AXI5
            if (clp.get_arg_value("+wt_ace_atm_str=", arg_value)) begin
                wt_ace_atm_str = arg_value.atoi();
            end else begin
                wt_ace_atm_str = (wt_ace_atm_str == -1) ? $urandom_range(0,100) : wt_ace_atm_str;
            end
            if (clp.get_arg_value("+wt_ace_atm_ld=", arg_value)) begin
                wt_ace_atm_ld = arg_value.atoi();
            end        
            else begin
                wt_ace_atm_ld = (wt_ace_atm_ld == -1) ? $urandom_range(0,100) : wt_ace_atm_ld;
            end

            if (clp.get_arg_value("+wt_ace_atm_swap=", arg_value)) begin
                wt_ace_atm_swap = arg_value.atoi();
            end        
            else begin
                wt_ace_atm_swap = (wt_ace_atm_swap == -1) ? $urandom_range(0,100) : wt_ace_atm_swap;
            end

            if (clp.get_arg_value("+wt_ace_atm_comp=", arg_value)) begin
                wt_ace_atm_comp = arg_value.atoi();
            end        
            else begin
                wt_ace_atm_comp = (wt_ace_atm_comp == -1) ? $urandom_range(0,100) : wt_ace_atm_comp;
            end
         <%}%>
        
        <%if (obj.fnNativeInterface == "ACELITE-E") { %>   
        //grab stash txn weights from cmdline for ACE-Lite-E
            if (clp.get_arg_value("+wt_ace_ptl_stash=", arg_value)) begin
                wt_ace_ptl_stash = arg_value.atoi();
            end        
            else begin
                wt_ace_ptl_stash = (wt_ace_ptl_stash == -1) ? $urandom_range(1,100) : wt_ace_ptl_stash;
            end

            if (clp.get_arg_value("+wt_ace_full_stash=", arg_value)) begin
                wt_ace_full_stash = arg_value.atoi();
            end        
            else begin
                wt_ace_full_stash = (wt_ace_full_stash == -1) ? $urandom_range(1,100) : wt_ace_full_stash;
            end

            if (clp.get_arg_value("+wt_ace_shared_stash=", arg_value)) begin
                wt_ace_shared_stash = arg_value.atoi();
            end        
            else begin
                wt_ace_shared_stash = (wt_ace_shared_stash == -1) ? $urandom_range(1,100) : wt_ace_shared_stash;
            end

            if (clp.get_arg_value("+wt_ace_unq_stash=", arg_value)) begin
                wt_ace_unq_stash = arg_value.atoi();
            end        
            else begin
                wt_ace_unq_stash = (wt_ace_unq_stash == -1) ? $urandom_range(1,100) : wt_ace_unq_stash;
            end

            //grab readoncemkinv and rdonceclninv cmdline args for ACE-Lite-E
            if (clp.get_arg_value("+wt_ace_rd_cln_invld=", arg_value)) begin
                wt_ace_rd_cln_invld = arg_value.atoi();
            end        
            else begin
                wt_ace_rd_cln_invld = (wt_ace_rd_cln_invld == -1) ? $urandom_range(1,100) : wt_ace_rd_cln_invld;
            end
            if (clp.get_arg_value("+wt_ace_rd_make_invld=", arg_value)) begin
                wt_ace_rd_make_invld = arg_value.atoi();
            end        
            else begin
                wt_ace_rd_make_invld = (wt_ace_rd_make_invld == -1) ? $urandom_range(1,100) : wt_ace_rd_make_invld;
            end
        <%}%>
        
        if (clp.get_arg_value("+wt_ace_clnshrd_pers=", arg_value)) begin
            wt_ace_clnshrd_pers = arg_value.atoi();
        end        
        else begin
            wt_ace_clnshrd_pers = (wt_ace_clnshrd_pers == -1) ? $urandom_range(1,100) : wt_ace_clnshrd_pers;
        end

        if (clp.get_arg_value("+wt_illegal_op_addr=", arg_value)) begin
            wt_illegal_op_addr = arg_value.atoi();
        end        
        else begin
            wt_illegal_op_addr = (wt_illegal_op_addr == -1) ? $urandom_range(1,100) : wt_illegal_op_addr;
        end
        
        //#Stimulus.IOAIU.OWO.RdWrAtmSnp
        <%if(((obj.fnNativeInterface == "ACELITE-E") && computedAxiInt.params.eAc) ||
                (obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") ||
                (obj.DutInfo.useCache) ||
                (obj.DutInfo.orderedWriteObservation == true)){%>
            if (clp.get_arg_value("+k_num_snoop=", arg_value)) begin
                k_num_snp = arg_value.atoi();
            end
            else begin
                k_num_snp = $urandom_range(150,1000);
            end
        <%}%>

        if(clp.get_arg_value("+k_num_read_req=", arg_value)) begin
            k_num_read_req = arg_value.atoi();
        end        
        else begin
            k_num_read_req = $urandom_range(1500,2500);
        end
        if(clp.get_arg_value("+k_num_write_req=", arg_value)) begin
            k_num_write_req = arg_value.atoi();
        end        
        else begin
            <%if(obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5"){%> 
                k_num_write_req = $urandom_range(10,200);
            <%}else{%>
                k_num_write_req = $urandom_range(1500,2500);
            <%}%>
        end
        if(clp.get_arg_value("+num_evictions=", arg_value)) begin
            k_num_eviction_req = arg_value.atoi();
        end        
        if(clp.get_arg_value("+prob_unq_cln_to_unq_dirty=", arg_value)) begin
            prob_unq_cln_to_unq_dirty = arg_value.atoi();
        end        
        else begin
            prob_unq_cln_to_unq_dirty = $urandom_range(10,95);
        end
        if (clp.get_arg_value("+prob_unq_cln_to_invalid=", arg_value)) begin
            prob_unq_cln_to_invalid = arg_value.atoi();
        end        
        else begin
            prob_unq_cln_to_invalid = $urandom_range(10,95);
        end
        if (clp.get_arg_value("+total_outstanding_coh_writes=", arg_value)) begin
            total_outstanding_coh_writes = arg_value.atoi();
        end        
        else begin
            total_outstanding_coh_writes = $urandom_range(1,15);
        end
        if (clp.get_arg_value("+total_min_ace_cache_size=", arg_value)) begin
            total_min_ace_cache_size = arg_value.atoi();
        end        
        else begin
            randcase
                50: total_min_ace_cache_size = $urandom_range(1,15);
                50: total_min_ace_cache_size = $urandom_range(100,200);
                50: total_min_ace_cache_size = $urandom_range(1,200);
            endcase
        end
        if (clp.get_arg_value("+total_max_ace_cache_size=", arg_value)) begin
            total_max_ace_cache_size = arg_value.atoi();
        end        
        else begin
            if (total_min_ace_cache_size < 16) begin
                randcase
                    50: total_max_ace_cache_size = $urandom_range(total_min_ace_cache_size, 25);
                    10: total_max_ace_cache_size = $urandom_range(total_min_ace_cache_size, 200);
                endcase
            end
            else begin
                total_max_ace_cache_size = $urandom_range(total_min_ace_cache_size,500);
            end
        end
        if (clp.get_arg_value("+size_of_wr_queue_before_flush=", arg_value)) begin
            size_of_wr_queue_before_flush = arg_value.atoi();
        end        
        else begin
            size_of_wr_queue_before_flush = $urandom_range(1,50);
        end
        if (clp.get_arg_value("+wt_expected_end_state=", arg_value)) begin
            wt_expected_end_state = arg_value.atoi();
        end        
        else begin
            wt_expected_end_state = $urandom_range(40,100);
        end
        if (clp.get_arg_value("+wt_legal_end_state_with_sf=", arg_value)) begin
            wt_legal_end_state_with_sf = arg_value.atoi();
        end        
        else begin
            wt_legal_end_state_with_sf = $urandom_range(0,100-wt_expected_end_state);
        end
        <%var aiuid, sfid, sftype;
        aiuid = 0;
        sfid = 0;
        sftype = "TAGFILTER";
        %> 
        if (clp.get_arg_value("+wt_legal_end_state_without_sf=", arg_value)) begin
            wt_legal_end_state_without_sf = arg_value.atoi();
        end        
        else begin
            <%if(sftype === "NULL"){%>
                wt_legal_end_state_without_sf = $urandom_range(0,100-wt_expected_end_state-wt_legal_end_state_with_sf);
            <%}else{%>    
                wt_legal_end_state_without_sf = 0;
            <%}%>      
        end
        if (clp.get_arg_value("+wt_expected_start_state=", arg_value)) begin
            wt_expected_start_state = arg_value.atoi();
        end        
        else begin
            wt_expected_start_state = $urandom_range(40,100);
        end
        if (clp.get_arg_value("+wt_legal_start_state=", arg_value)) begin
            wt_legal_start_state = arg_value.atoi();
        end        
        else begin
            wt_legal_start_state = $urandom_range(0,100 - wt_expected_start_state);
        end
        if (clp.get_arg_value("+wt_lose_cache_line_on_snps=", arg_value)) begin
            wt_lose_cache_line_on_snps = arg_value.atoi();
        end        
        else begin
            wt_lose_cache_line_on_snps = $urandom_range(0,100);
        end
        if (clp.get_arg_value("+wt_keep_drty_cache_line_on_snps=", arg_value)) begin
            wt_keep_drty_cache_line_on_snps = arg_value.atoi();
        end        
        else begin
            randcase
                50: wt_keep_drty_cache_line_on_snps = $urandom_range(90,100);
                20: wt_keep_drty_cache_line_on_snps = $urandom_range(0,10);
                30: wt_keep_drty_cache_line_on_snps = $urandom_range(0,100);
            endcase
        end
        if (clp.get_arg_value("+prob_respond_to_snoop_coll_with_wr=", arg_value)) begin
            prob_respond_to_snoop_coll_with_wr = arg_value.atoi();
        end        
        else begin
            prob_respond_to_snoop_coll_with_wr = $urandom_range(0,100);
        end
        if (clp.get_arg_value("+prob_was_unique_snp_resp=", arg_value)) begin
            prob_was_unique_snp_resp = arg_value.atoi();
        end        
        else begin
            prob_was_unique_snp_resp = $urandom_range(1,100);
        end
        if (clp.get_arg_value("+prob_was_unique_always0_snp_resp=", arg_value)) begin
            prob_was_unique_always0_snp_resp = arg_value.atoi();
        end        
        else begin
            prob_was_unique_always0_snp_resp = $urandom_range(0,100);
        end
        if (clp.get_arg_value("+prob_dataxfer_snp_resp_on_clean_hit=", arg_value)) begin
            prob_dataxfer_snp_resp_on_clean_hit = arg_value.atoi();
        end        
        else begin
            prob_dataxfer_snp_resp_on_clean_hit = $urandom_range(0,100);
        end
        if (clp.get_arg_value("+prob_ace_wr_ix_start_state=", arg_value)) begin
            prob_ace_wr_ix_start_state = arg_value.atoi();
        end        
        else begin
            prob_ace_wr_ix_start_state = $urandom_range(40,100);
        end
        if (clp.get_arg_value("+prob_ace_rd_ix_start_state=", arg_value)) begin
            prob_ace_rd_ix_start_state = arg_value.atoi();
        end        
        else begin
            prob_ace_rd_ix_start_state = $urandom_range(40,100);
        end
        if (clp.get_arg_value("+prob_cache_flush_mode_per_1k=", arg_value)) begin
            prob_cache_flush_mode_per_1k = arg_value.atoi();
        end        
        else begin
            prob_cache_flush_mode_per_1k = $urandom_range(10,500);
        end
         <%if(obj.fnNativeInterface != "ACELITE-E"){%>
        if (clp.get_arg_value("+wt_snp_inv=", arg_value)) begin
            wt_snp_inv = arg_value.atoi();
        end        
        else begin
            wt_snp_inv = (wt_snp_inv != -1)?$urandom_range(1,100):0;
        end
        if (clp.get_arg_value("+wt_snp_cln_dtr=", arg_value)) begin
            wt_snp_cln_dtr = arg_value.atoi();
        end       
        else begin
            wt_snp_cln_dtr = (wt_snp_cln_dtr != -1)?$urandom_range(1,100):0;
        end
        if (clp.get_arg_value("+wt_snp_inv_stsh=", arg_value)) begin
            wt_snp_inv_stsh = arg_value.atoi();
        end
        else begin
            wt_snp_inv_stsh = (wt_snp_inv_stsh != -1)?$urandom_range(1,100):0;
        end
        if (clp.get_arg_value("+wt_snp_unq_stsh=", arg_value)) begin
            wt_snp_unq_stsh = arg_value.atoi();
        end
        else begin
            wt_snp_unq_stsh =(wt_snp_unq_stsh != -1)?$urandom_range(1,100):0;
        end
        if (clp.get_arg_value("+wt_snp_stsh_sh=", arg_value)) begin
            wt_snp_stsh_sh = arg_value.atoi();
        end
        else begin
            wt_snp_stsh_sh = (wt_snp_stsh_sh != -1)?$urandom_range(1,100):0;
        end
        if (clp.get_arg_value("+wt_snp_stsh_unq=", arg_value)) begin
            wt_snp_stsh_unq = arg_value.atoi();
        end
        else begin
            wt_snp_stsh_unq = (wt_snp_stsh_unq != -1)?$urandom_range(1,100):0;
        end
        if (clp.get_arg_value("+wt_snp_vld_dtr=", arg_value)) begin
            wt_snp_vld_dtr = arg_value.atoi();
        end       
        else begin
            wt_snp_vld_dtr = (wt_snp_vld_dtr != -1)?$urandom_range(1,100):0;
        end
        if (clp.get_arg_value("+wt_snp_inv_dtr=", arg_value)) begin
            wt_snp_inv_dtr = arg_value.atoi();
        end       
        else begin
            wt_snp_inv_dtr = (wt_snp_inv_dtr != -1)?$urandom_range(1,100):0;
        end
        if (clp.get_arg_value("+wt_snp_cln_dtw=", arg_value)) begin
            wt_snp_cln_dtw = arg_value.atoi();
        end       
        else begin
            wt_snp_cln_dtw = (wt_snp_cln_dtw != -1)?$urandom_range(1,100):0;
        end
        if (clp.get_arg_value("+wt_snp_inv_dtw=", arg_value)) begin
            wt_snp_inv_dtw = arg_value.atoi();
        end       
        else begin
            wt_snp_inv_dtw = (wt_snp_inv_dtw != -1)?$urandom_range(1,100):0;
        end
        if (clp.get_arg_value("+wt_snp_nitc=", arg_value)) begin
            wt_snp_nitc = arg_value.atoi();
        end
        else begin
            wt_snp_nitc = (wt_snp_nitc != -1)?$urandom_range(1,100):0;
        end
        if (clp.get_arg_value("+wt_snp_nitcci=", arg_value)) begin
            wt_snp_nitcci = arg_value.atoi();
        end
        else begin
            wt_snp_nitcci = (wt_snp_nitcci != -1)?$urandom_range(1,100):0;
        end
        if (clp.get_arg_value("+wt_snp_nitcmi=", arg_value)) begin
            wt_snp_nitcmi = arg_value.atoi();
        end
        else begin
            wt_snp_nitcmi = (wt_snp_nitcci != -1)?$urandom_range(1,100):0;
        end
        if (clp.get_arg_value("+wt_snp_nosdint=", arg_value)) begin
            wt_snp_nosdint = arg_value.atoi();
        end
        else begin
             wt_snp_nosdint = (wt_snp_nosdint != -1)?$urandom_range(1,100):0;
        end
        if (clp.get_arg_value("+wt_snp_dvm_msg=", arg_value)) begin
            wt_snp_dvm_msg = arg_value.atoi();
        end
        else begin
              
                    
                <%if(!computedAxiInt.params.eAc){%>
                    wt_snp_dvm_msg = 0;
                <%}else{%>
                    wt_snp_dvm_msg = (wt_snp_dvm_msg != -1)?$urandom_range(1,100):0;
                <%}%>
            
        end
        <%}else{%>
        if (clp.get_arg_value("+wt_snp_dvm_msg=", arg_value)) begin
            wt_snp_dvm_msg = arg_value.atoi();
        end
        else begin
              
                    
                <%if(!computedAxiInt.params.eAc){%>
                    wt_snp_dvm_msg = 0;
                <%}else{%>
                    wt_snp_dvm_msg = (wt_snp_dvm_msg != -1)?$urandom_range(1,100):0;
                <%}%>
            
        end
            wt_snp_cln_dtr      = 0;
            wt_snp_inv_stsh     = 0;
            wt_snp_unq_stsh     = 0;
            wt_snp_stsh_sh      = 0;
            wt_snp_stsh_unq     = 0;
            wt_snp_vld_dtr      = 0;
            wt_snp_inv_dtr      = 0;
            wt_snp_inv          = 0;
            wt_snp_cln_dtw      = 0;
            wt_snp_inv_dtw      = 0;
            wt_snp_nitc         = 0;
            wt_snp_nitcci       = 0;
            wt_snp_nitcmi       = 0;
            wt_snp_nosdint      = 0;
        <%}%>
        if (clp.get_arg_value("+k_num_some_sets=", arg_value)) begin
        num_sets = arg_value.atoi();
        end else begin
         num_sets = $urandom_range(4,6);
        end
        <%if( obj.DutInfo.useCache){%>
            if (clp.get_arg_value("+wt_snp_random_addr=", arg_value)) begin
                wt_snp_random_addr = arg_value.atoi();
            end
            else begin
                wt_snp_random_addr = $urandom_range(1,5);
            end
            if (clp.get_arg_value("+wt_snp_prev_addr=", arg_value)) begin
                wt_snp_prev_addr = arg_value.atoi();
            end
            else begin
                wt_snp_prev_addr = $urandom_range(50,100);
            end
            if (clp.get_arg_value("+wt_snp_cmd_req_addr=", arg_value)) begin
                wt_snp_cmd_req_addr = arg_value.atoi();
            end
            else begin
                wt_snp_cmd_req_addr = $urandom_range(1,100);
            end
        <%}else{%>
            if (clp.get_arg_value("+wt_snp_random_addr=", arg_value)) begin
                wt_snp_random_addr = arg_value.atoi();
            end
            else begin
                wt_snp_random_addr = $urandom_range(1,5);
            end
            if (clp.get_arg_value("+wt_snp_ott_addr=", arg_value)) begin
                wt_snp_ott_addr = arg_value.atoi();
            end
            else begin
               wt_snp_ott_addr = $urandom_range(1,5);
            end
            if (clp.get_arg_value("+wt_snp_stash_addr=", arg_value)) begin
                wt_snp_stash_addr = arg_value.atoi();
            end
            else begin
                wt_snp_stash_addr = $urandom_range(1,100);
            end
            if (clp.get_arg_value("+wt_snp_prev_addr=", arg_value)) begin
                wt_snp_prev_addr = arg_value.atoi();
            end
            else begin
                wt_snp_prev_addr = $urandom_range(1,100);
            end
            if (clp.get_arg_value("+wt_snp_cmd_req_addr=", arg_value)) begin
                wt_snp_cmd_req_addr = arg_value.atoi();
            end
            else begin
                wt_snp_cmd_req_addr = $urandom_range(1,100);
            end
        <%}%>
        if (clp.get_arg_value("+wt_exokay_set=", arg_value)) begin
            wt_exokay_set = arg_value.atoi();
        end        
        else begin
            wt_exokay_set = $urandom_range(10,80);
        end
        if (clp.get_arg_value("+wt_dvm_multipart_snp=", arg_value)) begin
            wt_dvm_multipart_snp = arg_value.atoi();
        end        
        else begin
            wt_dvm_multipart_snp = $urandom_range(0,95);
        end
        if (clp.get_arg_value("+wt_dvm_sync_snp=", arg_value)) begin
            wt_dvm_sync_snp = arg_value.atoi();
        end        
        else begin
            wt_dvm_sync_snp = $urandom_range(0,95);
        end
        if (clp.get_arg_value("+prob_multiple_dtr_for_read=", arg_value)) begin
            prob_multiple_dtr_for_read = arg_value.atoi();
        end
        else begin
            prob_multiple_dtr_for_read = $urandom_range(5,95);
        end
        if (clp.get_arg_value("+prob_ace_snp_resp_error=", arg_value)) begin
            prob_ace_snp_resp_error = arg_value.atoi();
        end
        else begin
            prob_ace_snp_resp_error = 0;
        end
    
        <%if(!(obj.fnNativeInterface == "AXI4" || obj.fnNativeInterface == "AXI5")){%>
        if (clp.get_arg_value("+prob_ace_coh_win_error=", arg_value)) begin
            prob_ace_coh_win_error = arg_value.atoi();
        end
            if (clp.get_arg_value("+error_test=", arg_value) || ($urandom_range(0,100) < 5)) begin
                if (clp.get_arg_value("+prob_strreq_addr_err_inj=", arg_value)) begin
                    prob_strreq_addr_err_inj = arg_value.atoi();
                end
                else begin
                    prob_strreq_addr_err_inj = $urandom_range(0,5);
                end
                if (clp.get_arg_value("+prob_strreq_data_err_inj=", arg_value)) begin
                    prob_strreq_data_err_inj = arg_value.atoi();
                end
                else begin
                    prob_strreq_data_err_inj = $urandom_range(0,5);
                end
                if (clp.get_arg_value("+prob_strreq_trspt_err_inj=", arg_value)) begin
                    prob_strreq_trspt_err_inj = arg_value.atoi();
                end
                else begin
                    prob_strreq_trspt_err_inj = $urandom_range(0,5);
                end
                if (clp.get_arg_value("+prob_dtwrsp_data_err_inj=", arg_value)) begin
                    prob_dtwrsp_data_err_inj = arg_value.atoi();
                end
                else begin
                    prob_dtwrsp_data_err_inj = $urandom_range(0,5);
                end
                if (clp.get_arg_value("+prob_dtrreq_data_err_inj=", arg_value)) begin
                    prob_dtrreq_data_err_inj = arg_value.atoi();
                end
                else begin
                    prob_dtrreq_data_err_inj = $urandom_range(0,5);
                end
                if (clp.get_arg_value("+prob_upddtwrsp_trspt_sec_err_inj=", arg_value)) begin
                    prob_upddtwrsp_trspt_sec_err_inj = arg_value.atoi();
                end
                else begin
                    prob_upddtwrsp_trspt_sec_err_inj = $urandom_range(0,5);
                end

                if (clp.get_arg_value("+prob_dtrdatavis_trspt_sec_err_inj=", arg_value)) begin
                    prob_dtrdatavis_trspt_sec_err_inj = arg_value.atoi();
                end
                else begin
                    prob_dtrdatavis_trspt_sec_err_inj = $urandom_range(0,5);
                end

                if (clp.get_arg_value("+prob_dtrdatavis_trspt_disc_err_inj=", arg_value)) begin
                    prob_dtrdatavis_trspt_disc_err_inj = arg_value.atoi();
                end
                else begin
                    prob_dtrdatavis_trspt_disc_err_inj = $urandom_range(0,5);
                end
                if (clp.get_arg_value("+prob_dtrdatavis_trspt_tmo_err_inj=", arg_value)) begin
                    prob_dtrdatavis_trspt_tmo_err_inj = arg_value.atoi();
                end
                else begin
                    prob_dtrdatavis_trspt_tmo_err_inj = $urandom_range(0,5);
                end

                if (clp.get_arg_value("+prob_dtrdatavis_addr_err_inj=", arg_value)) begin
                    prob_dtrdatavis_addr_err_inj = arg_value.atoi();
                end
                else begin
                    prob_dtrdatavis_addr_err_inj = $urandom_range(0,5);
                end

                if (clp.get_arg_value("+prob_ace_coh_win_error=", arg_value)) begin
                    prob_ace_coh_win_error = arg_value.atoi();
                end
                else begin
                    <%if(obj.fnNativeInterface == "AXI4" || obj.fnNativeInterface == "AXI5"){%>
                        <%if(obj.DutInfo.NcMode){%>
                            prob_ace_coh_win_error = 100;
                        <%}else{%>
                            prob_ace_coh_win_error = 0;
                        <%}%>
                    <%}else{%>
	                    std::randomize(prob_ace_coh_win_error) with { prob_ace_coh_win_error dist{ 25:=60, 50:=20, 75:=20};};
                    <%}%>
                end
                if(clp.get_arg_value("+prob_ace_rd_resp_error=", arg_value)) begin
                    prob_ace_rd_resp_error = arg_value.atoi();
                end
                else begin
                    prob_ace_rd_resp_error = $urandom_range(0,5);
                end
                if (clp.get_arg_value("+prob_ace_wr_resp_error=", arg_value)) begin
                    prob_ace_wr_resp_error = arg_value.atoi();
                end
                else begin
                    prob_ace_wr_resp_error = $urandom_range(0,5);
                end
                              if (clp.get_arg_value("+prob_cmdrsp_trspt_sec_err_inj=", arg_value)) begin
                    prob_cmdrsp_trspt_sec_err_inj = arg_value.atoi();
                end
                else begin
                    prob_cmdrsp_trspt_sec_err_inj = $urandom_range(0,5);
                end
                if (clp.get_arg_value("+prob_cmdrsp_trspt_tmo_err_inj=", arg_value)) begin
                    prob_cmdrsp_trspt_tmo_err_inj = arg_value.atoi();
                end
                else begin
                    prob_cmdrsp_trspt_tmo_err_inj = $urandom_range(0,5);
                end
                if (clp.get_arg_value("+prob_cmdrsp_trspt_disc_err_inj=", arg_value)) begin
                    prob_cmdrsp_trspt_disc_err_inj = arg_value.atoi();
                end
                else begin
                    prob_cmdrsp_trspt_disc_err_inj = $urandom_range(0,5);
                end
                if (clp.get_arg_value("+prob_upddtwrsp_trspt_tmo_err_inj=", arg_value)) begin
                    prob_upddtwrsp_trspt_tmo_err_inj = arg_value.atoi();
                end
                else begin
                    prob_upddtwrsp_trspt_tmo_err_inj = $urandom_range(0,5);
                end
                if (clp.get_arg_value("+prob_upddtwrsp_trspt_disc_err_inj=", arg_value)) begin
                    prob_upddtwrsp_trspt_disc_err_inj = arg_value.atoi();
                end
                else begin
                    prob_upddtwrsp_trspt_disc_err_inj = $urandom_range(0,5);
                end
 
                if (clp.get_arg_value("+error_test=", arg_value)) begin
                    if (clp.get_arg_value("+prob_upddtwrsp_trspt_tmo_err_inj=", arg_value)) begin
                        prob_upddtwrsp_trspt_tmo_err_inj = arg_value.atoi();
                    end
                    else begin
                        prob_upddtwrsp_trspt_tmo_err_inj = 0;
                    end
                    if (clp.get_arg_value("+prob_cmdrsp_trspt_disc_err_inj=", arg_value)) begin
                        prob_cmdrsp_trspt_disc_err_inj = arg_value.atoi();
                    end
                    else begin
                        prob_cmdrsp_trspt_disc_err_inj = 0;
                    end
                    if (clp.get_arg_value("+prob_upddtwrsp_trspt_disc_err_inj=", arg_value)) begin
                        prob_upddtwrsp_trspt_disc_err_inj = arg_value.atoi();
                    end
                    else begin
                        prob_upddtwrsp_trspt_disc_err_inj = 0;
                    end
                end
            end 
        <%}else{%>
            if(clp.get_arg_value("+error_rand_test=", arg_value)) begin
                if (clp.get_arg_value("+prob_strreq_addr_err_inj=", arg_value)) begin
                    prob_strreq_addr_err_inj = arg_value.atoi();
                end
                else begin
                    prob_strreq_addr_err_inj = $urandom_range(0,5);
                end
                if (clp.get_arg_value("+prob_strreq_data_err_inj=", arg_value)) begin
                    prob_strreq_data_err_inj = arg_value.atoi();
                end
                else begin
                    prob_strreq_data_err_inj = $urandom_range(0,5);
                end
                if (clp.get_arg_value("+prob_strreq_trspt_err_inj=", arg_value)) begin
                    prob_strreq_trspt_err_inj = arg_value.atoi();
                end
                else begin
                    prob_strreq_trspt_err_inj = 0;
                end
                if (clp.get_arg_value("+prob_dtwrsp_data_err_inj=", arg_value)) begin
                    prob_dtwrsp_data_err_inj = arg_value.atoi();
                end
                else begin
                    prob_dtwrsp_data_err_inj = $urandom_range(0,5);
                end
                if (clp.get_arg_value("+prob_dtrreq_data_err_inj=", arg_value)) begin
                    prob_dtrreq_data_err_inj = arg_value.atoi();
                end
                else begin
                    prob_dtrreq_data_err_inj = $urandom_range(0,5);
                end
                if (clp.get_arg_value("+prob_upddtwrsp_trspt_sec_err_inj=", arg_value)) begin
                    prob_upddtwrsp_trspt_sec_err_inj = arg_value.atoi();
                end
                else begin
                    prob_upddtwrsp_trspt_sec_err_inj = $urandom_range(0,5);
                end

                if (clp.get_arg_value("+prob_dtrdatavis_trspt_sec_err_inj=", arg_value)) begin
                    prob_dtrdatavis_trspt_sec_err_inj = arg_value.atoi();
                end
                else begin
                    prob_dtrdatavis_trspt_sec_err_inj = $urandom_range(0,5);
                end

                if (clp.get_arg_value("+prob_dtrdatavis_trspt_disc_err_inj=", arg_value)) begin
                    prob_dtrdatavis_trspt_disc_err_inj = arg_value.atoi();
                end
                else begin
                    prob_dtrdatavis_trspt_disc_err_inj = $urandom_range(0,5);
                end
                if (clp.get_arg_value("+prob_dtrdatavis_trspt_tmo_err_inj=", arg_value)) begin
                    prob_dtrdatavis_trspt_tmo_err_inj = arg_value.atoi();
                end
                else begin
                    prob_dtrdatavis_trspt_tmo_err_inj = $urandom_range(0,5);
                end

                if (clp.get_arg_value("+prob_dtrdatavis_addr_err_inj=", arg_value)) begin
                    prob_dtrdatavis_addr_err_inj = arg_value.atoi();
                end
                else begin
                    prob_dtrdatavis_addr_err_inj = $urandom_range(0,5);
                end

                if (clp.get_arg_value("+prob_ace_coh_win_error=", arg_value)) begin
                    prob_ace_coh_win_error = arg_value.atoi();
                end
                else begin
                        prob_ace_coh_win_error = 0;
                end
                if (clp.get_arg_value("+prob_ace_rd_resp_error=", arg_value)) begin
                    prob_ace_rd_resp_error = arg_value.atoi();
                end
                else begin
                    prob_ace_rd_resp_error = $urandom_range(0,5);
                end
                if (clp.get_arg_value("+prob_ace_wr_resp_error=", arg_value)) begin
                    prob_ace_wr_resp_error = arg_value.atoi();
                end
                else begin
                    prob_ace_wr_resp_error = $urandom_range(0,5);
                end
                if (clp.get_arg_value("+prob_cmdrsp_trspt_sec_err_inj=", arg_value)) begin
                    prob_cmdrsp_trspt_sec_err_inj = arg_value.atoi();
                end
                else begin
                    prob_cmdrsp_trspt_sec_err_inj = $urandom_range(0,5);
                end
                if (clp.get_arg_value("+prob_cmdrsp_trspt_tmo_err_inj=", arg_value)) begin
                    prob_cmdrsp_trspt_tmo_err_inj = arg_value.atoi();
                end
                else begin
                    prob_cmdrsp_trspt_tmo_err_inj = $urandom_range(0,5);
                end
                if (clp.get_arg_value("+prob_cmdrsp_trspt_disc_err_inj=", arg_value)) begin
                    prob_cmdrsp_trspt_disc_err_inj = arg_value.atoi();
                end
                else begin
                    prob_cmdrsp_trspt_disc_err_inj = $urandom_range(0,5);
                end
                if (clp.get_arg_value("+prob_upddtwrsp_trspt_tmo_err_inj=", arg_value)) begin
                    prob_upddtwrsp_trspt_tmo_err_inj = arg_value.atoi();
                end
                else begin
                    prob_upddtwrsp_trspt_tmo_err_inj = $urandom_range(0,5);
                end
                if (clp.get_arg_value("+prob_upddtwrsp_trspt_disc_err_inj=", arg_value)) begin
                    prob_upddtwrsp_trspt_disc_err_inj = arg_value.atoi();
                end
                else begin
                    prob_upddtwrsp_trspt_disc_err_inj = $urandom_range(0,5);
                end
            end else if (clp.get_arg_value("+error_directed_test=", arg_value)) begin
                if (clp.get_arg_value("+prob_strreq_addr_err_inj=", arg_value)) begin
                    prob_strreq_addr_err_inj = arg_value.atoi();
                end
                else begin
                    prob_strreq_addr_err_inj = 0;
                end
                if (clp.get_arg_value("+prob_strreq_data_err_inj=", arg_value)) begin
                    prob_strreq_data_err_inj = arg_value.atoi();
                end
                else begin
                    prob_strreq_data_err_inj = 0;
                end
                if (clp.get_arg_value("+prob_strreq_trspt_err_inj=", arg_value)) begin
                    prob_strreq_trspt_err_inj = arg_value.atoi();
                end
                else begin
                    prob_strreq_trspt_err_inj = 0;
                end
                if (clp.get_arg_value("+prob_dtwrsp_data_err_inj=", arg_value)) begin
                    prob_dtwrsp_data_err_inj = arg_value.atoi();
                end
                else begin
                    prob_dtwrsp_data_err_inj = 0;
                end
                if (clp.get_arg_value("+prob_dtrreq_data_err_inj=", arg_value)) begin
                    prob_dtrreq_data_err_inj = arg_value.atoi();
                end
                else begin
                    prob_dtrreq_data_err_inj = 0;
                end
                if (clp.get_arg_value("+prob_upddtwrsp_trspt_sec_err_inj=", arg_value)) begin
                    prob_upddtwrsp_trspt_sec_err_inj = arg_value.atoi();
                end
                else begin
                    prob_upddtwrsp_trspt_sec_err_inj = 0;
                end

                if (clp.get_arg_value("+prob_dtrdatavis_trspt_sec_err_inj=", arg_value)) begin
                    prob_dtrdatavis_trspt_sec_err_inj = arg_value.atoi();
                end
                else begin
                    prob_dtrdatavis_trspt_sec_err_inj = 0;
                end

                if (clp.get_arg_value("+prob_dtrdatavis_trspt_disc_err_inj=", arg_value)) begin
                    prob_dtrdatavis_trspt_disc_err_inj = arg_value.atoi();
                end
                else begin
                    prob_dtrdatavis_trspt_disc_err_inj = 0;
                end
                if (clp.get_arg_value("+prob_dtrdatavis_trspt_tmo_err_inj=", arg_value)) begin
                    prob_dtrdatavis_trspt_tmo_err_inj = arg_value.atoi();
                end
                else begin
                    prob_dtrdatavis_trspt_tmo_err_inj = 0;
                end

                if (clp.get_arg_value("+prob_dtrdatavis_addr_err_inj=", arg_value)) begin
                    prob_dtrdatavis_addr_err_inj = arg_value.atoi();
                end
                else begin
                    prob_dtrdatavis_addr_err_inj = 0;
                end

                if (clp.get_arg_value("+prob_ace_coh_win_error=", arg_value)) begin
                    prob_ace_coh_win_error = arg_value.atoi();
                end
                else begin
                    prob_ace_coh_win_error = 0;
                end
                if (clp.get_arg_value("+prob_ace_rd_resp_error=", arg_value)) begin
                    prob_ace_rd_resp_error = arg_value.atoi();
                end
                else begin
                    prob_ace_rd_resp_error = 0;
                end
                if (clp.get_arg_value("+prob_ace_wr_resp_error=", arg_value)) begin
                    prob_ace_wr_resp_error = arg_value.atoi();
                end
                else begin
                    prob_ace_wr_resp_error = 0;
                end
                if (clp.get_arg_value("+prob_cmdrsp_trspt_sec_err_inj=", arg_value)) begin
                    prob_cmdrsp_trspt_sec_err_inj = arg_value.atoi();
                end
                else begin
                    prob_cmdrsp_trspt_sec_err_inj = 0;
                end
                if (clp.get_arg_value("+prob_cmdrsp_trspt_tmo_err_inj=", arg_value)) begin
                    prob_cmdrsp_trspt_tmo_err_inj = arg_value.atoi();
                end
                else begin
                    prob_cmdrsp_trspt_tmo_err_inj = 0;
                end
                if (clp.get_arg_value("+prob_cmdrsp_trspt_disc_err_inj=", arg_value)) begin
                    prob_cmdrsp_trspt_disc_err_inj = arg_value.atoi();
                end
                else begin
                    prob_cmdrsp_trspt_disc_err_inj = 0;
                end
                if (clp.get_arg_value("+prob_upddtwrsp_trspt_tmo_err_inj=", arg_value)) begin
                    prob_upddtwrsp_trspt_tmo_err_inj = arg_value.atoi();
                end
                else begin
                    prob_upddtwrsp_trspt_tmo_err_inj = 0;
                end
                if (clp.get_arg_value("+prob_upddtwrsp_trspt_disc_err_inj=", arg_value)) begin
                    prob_upddtwrsp_trspt_disc_err_inj = arg_value.atoi();
                end
                else begin
                    prob_upddtwrsp_trspt_disc_err_inj = 0;
                end
            end
        <%}%>
        else begin
            prob_strreq_addr_err_inj           = 0;
            prob_strreq_data_err_inj           = 0;
            prob_strreq_trspt_err_inj          = 0;
            prob_dtwrsp_data_err_inj           = 0;
            prob_dtrreq_data_err_inj           = 0;
            prob_cmdrsp_trspt_sec_err_inj      = 0;
            prob_upddtwrsp_trspt_sec_err_inj   = 0;
            prob_cmdrsp_trspt_tmo_err_inj      = 0;
            prob_upddtwrsp_trspt_tmo_err_inj   = 0;
            prob_cmdrsp_trspt_disc_err_inj     = 0;
            prob_upddtwrsp_trspt_disc_err_inj  = 0;
            prob_dtrdatavis_trspt_sec_err_inj  = 0;
            prob_dtrdatavis_trspt_tmo_err_inj  = 0;
            prob_dtrdatavis_trspt_disc_err_inj = 0;
            prob_dtrdatavis_addr_err_inj       = 0;
        end
        if (clp.get_arg_value("+dis_delay_dtr_req=", arg_value)) begin
            dis_delay_dtr_req = arg_value.atoi();
        end
        else begin
            randcase
                25: dis_delay_dtr_req = 0;
                75: dis_delay_dtr_req = 1;
            endcase
        end
        if (clp.get_arg_value("+dis_delay_str_req=", arg_value)) begin
            dis_delay_str_req = arg_value.atoi();
        end
        else begin
            randcase
                25: dis_delay_str_req = 0;
                75: dis_delay_str_req = 1;
            endcase
        end
        if (clp.get_arg_value("+dis_delay_slave_resp=", arg_value)) begin
            dis_delay_slave_resp = arg_value.atoi();
        end
        else begin
            randcase
                25: dis_delay_slave_resp = 0;
                75: dis_delay_slave_resp = 1;
            endcase
        end
        if (clp.get_arg_value("+high_system_bfm_slv_rsp_delays=", arg_value)) begin
            high_system_bfm_slv_rsp_delays = arg_value.atoi();
        end
        else begin
            randcase
                80: high_system_bfm_slv_rsp_delays = 0;
                20: high_system_bfm_slv_rsp_delays = 1;
            endcase
        end
        if (clp.get_arg_value("+k_ace_master_read_addr_chnl_delay_min=", arg_value)) begin
            k_ace_master_read_addr_chnl_delay_min = arg_value.atoi();
        end
        else begin
            k_ace_master_read_addr_chnl_delay_min = $urandom_range(1,7);
        end
        if (clp.get_arg_value("+k_ace_master_read_addr_chnl_delay_max=", arg_value)) begin
            k_ace_master_read_addr_chnl_delay_max = arg_value.atoi();
        end
        else begin
            randcase
                70 : k_ace_master_read_addr_chnl_delay_max = $urandom_range(k_ace_master_read_addr_chnl_delay_min,15);
                30 : k_ace_master_read_addr_chnl_delay_max = $urandom_range(k_ace_master_read_addr_chnl_delay_min,100);
            endcase
        end
        if (clp.get_arg_value("+k_ace_master_read_addr_chnl_burst_pct=", arg_value)) begin
            k_ace_master_read_addr_chnl_burst_pct = arg_value.atoi();
        end
        else begin
            k_ace_master_read_addr_chnl_burst_pct = ($urandom_range(0,100) < 10) ? 100 : $urandom_range(5,95);
        end
        if (clp.get_arg_value("+k_ace_master_read_data_chnl_delay_min=", arg_value)) begin
            k_ace_master_read_data_chnl_delay_min = arg_value.atoi();
        end
        else begin
            <%if( obj.DutInfo.useCache){%>
                k_ace_master_read_data_chnl_delay_min = $urandom_range(1,3);
            <%}else{%>
                k_ace_master_read_data_chnl_delay_min = $urandom_range(1,7);
            <%}%>
        end
        if (clp.get_arg_value("+k_ace_master_read_data_chnl_delay_max=", arg_value)) begin
            k_ace_master_read_data_chnl_delay_max = arg_value.atoi();
        end
        else begin
            <%if( obj.DutInfo.useCache){%>
                randcase
                    70 : k_ace_master_read_data_chnl_delay_max = $urandom_range(k_ace_master_read_data_chnl_delay_min,5);
                    30 : k_ace_master_read_data_chnl_delay_max = $urandom_range(k_ace_master_read_data_chnl_delay_min,50);
                endcase
            <%}else{%>
                randcase
                    70 : k_ace_master_read_data_chnl_delay_max = $urandom_range(k_ace_master_read_data_chnl_delay_min,15);
                    30 : k_ace_master_read_data_chnl_delay_max = $urandom_range(k_ace_master_read_data_chnl_delay_min,100);
                endcase
            <%}%>
        end

        if (clp.get_arg_value("+k_ace_master_read_data_chnl_burst_pct=", arg_value)) begin
            k_ace_master_read_data_chnl_burst_pct = arg_value.atoi();
        end
        else begin
            k_ace_master_read_data_chnl_burst_pct = ($urandom_range(0,100) < 10) ? 100 : $urandom_range(5,95);
        end
        if (clp.get_arg_value("+k_ace_master_write_addr_chnl_delay_min=", arg_value)) begin
            k_ace_master_write_addr_chnl_delay_min = arg_value.atoi();
        end
        else begin
            k_ace_master_write_addr_chnl_delay_min = $urandom_range(1,7);
        end
        if (clp.get_arg_value("+k_ace_master_write_addr_chnl_delay_max=", arg_value)) begin
            k_ace_master_write_addr_chnl_delay_max = arg_value.atoi();
        end
        else begin
            randcase
                70 : k_ace_master_write_addr_chnl_delay_max = $urandom_range(k_ace_master_write_addr_chnl_delay_min,15);
                30 : k_ace_master_write_addr_chnl_delay_max = $urandom_range(k_ace_master_write_addr_chnl_delay_min,100);
            endcase
        end
        if (clp.get_arg_value("+k_ace_master_write_addr_chnl_burst_pct=", arg_value)) begin
            k_ace_master_write_addr_chnl_burst_pct = arg_value.atoi();
        end
        else begin
            k_ace_master_write_addr_chnl_burst_pct = ($urandom_range(0,100) < 10) ? 100 :  $urandom_range(5,95);
        end
        if (clp.get_arg_value("+k_ace_master_write_data_chnl_delay_min=", arg_value)) begin
            k_ace_master_write_data_chnl_delay_min = arg_value.atoi();
        end
        else begin
            <%if( obj.DutInfo.useCache){%>
                k_ace_master_write_data_chnl_delay_min = $urandom_range(1,3);
            <%}else{%>
                k_ace_master_write_data_chnl_delay_min = $urandom_range(1,7);
            <%}%>
        end
        if (clp.get_arg_value("+k_ace_master_write_data_chnl_delay_max=", arg_value)) begin
            k_ace_master_write_data_chnl_delay_max = arg_value.atoi();
        end
        else begin
            <%if( obj.DutInfo.useCache){%>
                randcase
                    70 : k_ace_master_write_data_chnl_delay_max = $urandom_range(k_ace_master_write_data_chnl_delay_min,5);
                    30 : k_ace_master_write_data_chnl_delay_max = $urandom_range(k_ace_master_write_data_chnl_delay_min,50);
                endcase
            <%}else{%>
                randcase
                    70 : k_ace_master_write_data_chnl_delay_max = $urandom_range(k_ace_master_write_data_chnl_delay_min,15);
                    30 : k_ace_master_write_data_chnl_delay_max = $urandom_range(k_ace_master_write_data_chnl_delay_min,100);
                endcase
            <%}%>
        end
        if (clp.get_arg_value("+k_ace_master_write_data_chnl_burst_pct=", arg_value)) begin
            k_ace_master_write_data_chnl_burst_pct = arg_value.atoi();
        end
        else begin
            k_ace_master_write_data_chnl_burst_pct = ($urandom_range(0,100) < 10) ? 100 :  $urandom_range(5,95);
        end
        if (clp.get_arg_value("+k_ace_master_write_resp_chnl_delay_min=", arg_value)) begin
            k_ace_master_write_resp_chnl_delay_min = arg_value.atoi();
        end
        else begin
            k_ace_master_write_resp_chnl_delay_min = $urandom_range(1,7);
        end
        if (clp.get_arg_value("+k_ace_master_write_resp_chnl_delay_max=", arg_value)) begin
            k_ace_master_write_resp_chnl_delay_max = arg_value.atoi();
        end
        else begin
            randcase
                70 : k_ace_master_write_resp_chnl_delay_max = $urandom_range(k_ace_master_write_resp_chnl_delay_min,15);
                30 : k_ace_master_write_resp_chnl_delay_max = $urandom_range(k_ace_master_write_resp_chnl_delay_min,100);
            endcase
        end
        if (clp.get_arg_value("+k_ace_master_write_resp_chnl_burst_pct=", arg_value)) begin
            k_ace_master_write_resp_chnl_burst_pct = arg_value.atoi();
        end
        else begin
            k_ace_master_write_resp_chnl_burst_pct = ($urandom_range(0,100) < 10) ? 100 :  $urandom_range(5,95);
        end
        if (clp.get_arg_value("+k_ace_master_snoop_addr_chnl_delay_min=", arg_value)) begin
            k_ace_master_snoop_addr_chnl_delay_min = arg_value.atoi();
        end
        else begin
            k_ace_master_snoop_addr_chnl_delay_min = $urandom_range(1,7);
        end
        if (clp.get_arg_value("+k_ace_master_snoop_addr_chnl_delay_max=", arg_value)) begin
            k_ace_master_snoop_addr_chnl_delay_max = arg_value.atoi();
        end
        else begin
            randcase
                70 : k_ace_master_snoop_addr_chnl_delay_max = $urandom_range(k_ace_master_snoop_addr_chnl_delay_min,15);
                30 : k_ace_master_snoop_addr_chnl_delay_max = $urandom_range(k_ace_master_snoop_addr_chnl_delay_min,100);
            endcase
        end
        if (clp.get_arg_value("+k_ace_master_snoop_addr_chnl_burst_pct=", arg_value)) begin
            k_ace_master_snoop_addr_chnl_burst_pct = arg_value.atoi();
        end
        else begin
            k_ace_master_snoop_addr_chnl_burst_pct = ($urandom_range(0,100) < 10) ? 100 :  $urandom_range(5,95);
        end
        if (clp.get_arg_value("+k_ace_master_snoop_data_chnl_delay_min=", arg_value)) begin
            k_ace_master_snoop_data_chnl_delay_min = arg_value.atoi();
        end
        else begin
            k_ace_master_snoop_data_chnl_delay_min = $urandom_range(1,7);
        end
        if (clp.get_arg_value("+k_ace_master_snoop_data_chnl_delay_max=", arg_value)) begin
            k_ace_master_snoop_data_chnl_delay_max = arg_value.atoi();
        end
        else begin
            randcase
                70 : k_ace_master_snoop_data_chnl_delay_max = $urandom_range(k_ace_master_snoop_data_chnl_delay_min,15);
                30 : k_ace_master_snoop_data_chnl_delay_max = $urandom_range(k_ace_master_snoop_data_chnl_delay_min,100);
            endcase
        end
        if (clp.get_arg_value("+k_ace_master_snoop_data_chnl_burst_pct=", arg_value)) begin
            k_ace_master_snoop_data_chnl_burst_pct = arg_value.atoi();
        end
        else begin
            k_ace_master_snoop_data_chnl_burst_pct = ($urandom_range(0,100) < 10) ? 100 :  $urandom_range(5,95);
        end
        if (clp.get_arg_value("+k_ace_master_snoop_resp_chnl_delay_min=", arg_value)) begin
            k_ace_master_snoop_resp_chnl_delay_min = arg_value.atoi();
        end
        else begin
            k_ace_master_snoop_resp_chnl_delay_min = $urandom_range(1,7);
        end
        if (clp.get_arg_value("+k_ace_master_snoop_resp_chnl_delay_max=", arg_value)) begin
            k_ace_master_snoop_resp_chnl_delay_max = arg_value.atoi();
        end
        else begin
            randcase
                70 : k_ace_master_snoop_resp_chnl_delay_max = $urandom_range(k_ace_master_snoop_resp_chnl_delay_min,15);
                30 : k_ace_master_snoop_resp_chnl_delay_max = $urandom_range(k_ace_master_snoop_resp_chnl_delay_min,100);
            endcase
        end
        if (clp.get_arg_value("+k_ace_master_snoop_resp_chnl_burst_pct=", arg_value)) begin
            k_ace_master_snoop_resp_chnl_burst_pct = arg_value.atoi();
        end
        else begin
            k_ace_master_snoop_resp_chnl_burst_pct = ($urandom_range(0,100) < 10) ? 100 :  $urandom_range(5,95);
        end

        if (clp.get_arg_value("+k_is_bfm_delay_changing=", arg_value)) begin
            k_is_bfm_delay_changing = arg_value.atoi();
        end
        else begin
            k_is_bfm_delay_changing = ($urandom_range(0,100) < 10) ? 1 : 0;
        end
        if (clp.get_arg_value("+k_bfm_delay_changing_time=", arg_value)) begin
            k_bfm_delay_changing_time = arg_value.atoi();
        end
        else begin
            k_bfm_delay_changing_time = $urandom_range(1000,100000);
        end
        if (clp.get_arg_value("+k_ace_slave_read_addr_chnl_delay_min=", arg_value)) begin
            k_ace_slave_read_addr_chnl_delay_min = arg_value.atoi();
        end
        else begin
            k_ace_slave_read_addr_chnl_delay_min = $urandom_range(1,7);
        end
        if (clp.get_arg_value("+k_ace_slave_read_addr_chnl_delay_max=", arg_value)) begin
            k_ace_slave_read_addr_chnl_delay_max = arg_value.atoi();
        end
        else begin
            randcase
                70 : k_ace_slave_read_addr_chnl_delay_max = $urandom_range(k_ace_slave_read_addr_chnl_delay_min,15);
                30 : k_ace_slave_read_addr_chnl_delay_max = $urandom_range(k_ace_slave_read_addr_chnl_delay_min,100);
            endcase
        end
        if (clp.get_arg_value("+k_ace_slave_read_addr_chnl_burst_pct=", arg_value)) begin
            k_ace_slave_read_addr_chnl_burst_pct = arg_value.atoi();
        end
        else begin
            k_ace_slave_read_addr_chnl_burst_pct = ($urandom_range(0,100) < 10) ? 100 :  $urandom_range(5,95);
        end
        if (clp.get_arg_value("+k_ace_slave_read_data_chnl_delay_min=", arg_value)) begin
            k_ace_slave_read_data_chnl_delay_min = arg_value.atoi();
        end
        else begin
            k_ace_slave_read_data_chnl_delay_min = $urandom_range(1,7);
        end
        if (clp.get_arg_value("+k_ace_slave_read_data_chnl_delay_max=", arg_value)) begin
            k_ace_slave_read_data_chnl_delay_max = arg_value.atoi();
        end
        else begin
            randcase
                70 : k_ace_slave_read_data_chnl_delay_max = $urandom_range(k_ace_slave_read_data_chnl_delay_min,15);
                30 : k_ace_slave_read_data_chnl_delay_max = $urandom_range(k_ace_slave_read_data_chnl_delay_min,100);
            endcase
        end
        if (clp.get_arg_value("+k_ace_slave_read_data_chnl_burst_pct=", arg_value)) begin
            k_ace_slave_read_data_chnl_burst_pct = arg_value.atoi();
        end
        else begin
            k_ace_slave_read_data_chnl_burst_pct = ($urandom_range(0,100) < 10) ? 100 :  $urandom_range(5,95);
        end
        if (clp.get_arg_value("+k_ace_slave_read_data_reorder_size=", arg_value)) begin
            k_ace_slave_read_data_reorder_size = arg_value.atoi();
        end
        else begin
            k_ace_slave_read_data_reorder_size = $urandom_range(2,10);
        end
        if (clp.get_arg_value("+k_ace_slave_read_data_interleave_dis=", arg_value)) begin
            k_ace_slave_read_data_interleave_dis = arg_value.atoi();
        end
        else begin
            k_ace_slave_read_data_interleave_dis = ($urandom_range(0,100) > 25) ? 0 : 1;
        end
        if (clp.get_arg_value("+k_ace_slave_write_addr_chnl_delay_min=", arg_value)) begin
            k_ace_slave_write_addr_chnl_delay_min = arg_value.atoi();
        end
        else begin
            k_ace_slave_write_addr_chnl_delay_min = $urandom_range(1,7);
        end
        if (clp.get_arg_value("+k_ace_slave_write_addr_chnl_delay_max=", arg_value)) begin
            k_ace_slave_write_addr_chnl_delay_max = arg_value.atoi();
        end
        else begin
            randcase
                70 : k_ace_slave_write_addr_chnl_delay_max = $urandom_range(k_ace_slave_write_addr_chnl_delay_min,15);
                30 : k_ace_slave_write_addr_chnl_delay_max = $urandom_range(k_ace_slave_write_addr_chnl_delay_min,100);
            endcase
        end
        if (clp.get_arg_value("+k_ace_slave_write_addr_chnl_burst_pct=", arg_value)) begin
            k_ace_slave_write_addr_chnl_burst_pct = arg_value.atoi();
        end
        else begin
            k_ace_slave_write_addr_chnl_burst_pct = ($urandom_range(0,100) < 10) ? 100 :  $urandom_range(5,95);
        end
        if (clp.get_arg_value("+k_ace_slave_write_data_chnl_delay_min=", arg_value)) begin
            k_ace_slave_write_data_chnl_delay_min = arg_value.atoi();
        end
        else begin
            k_ace_slave_write_data_chnl_delay_min = $urandom_range(1,7);
        end
        if (clp.get_arg_value("+k_ace_slave_write_data_chnl_delay_max=", arg_value)) begin
            k_ace_slave_write_data_chnl_delay_max = arg_value.atoi();
        end
        else begin
            randcase
                70 : k_ace_slave_write_data_chnl_delay_max = $urandom_range(k_ace_slave_write_data_chnl_delay_min,15);
                30 : k_ace_slave_write_data_chnl_delay_max = $urandom_range(k_ace_slave_write_data_chnl_delay_min,100);
            endcase
        end
        if (clp.get_arg_value("+k_ace_slave_write_data_chnl_burst_pct=", arg_value)) begin
            k_ace_slave_write_data_chnl_burst_pct = arg_value.atoi();
        end
        else begin
            k_ace_slave_write_data_chnl_burst_pct = ($urandom_range(0,100) < 10) ? 100 :  $urandom_range(5,95);
        end
        if (clp.get_arg_value("+k_ace_slave_write_resp_chnl_delay_min=", arg_value)) begin
            k_ace_slave_write_resp_chnl_delay_min = arg_value.atoi();
        end
        else begin
            k_ace_slave_write_resp_chnl_delay_min = $urandom_range(1,7);
        end
        if (clp.get_arg_value("+k_ace_slave_write_resp_chnl_delay_max=", arg_value)) begin
            k_ace_slave_write_resp_chnl_delay_max = arg_value.atoi();
        end
        else begin
            randcase
                70 : k_ace_slave_write_resp_chnl_delay_max = $urandom_range(k_ace_slave_write_resp_chnl_delay_min,15);
                30 : k_ace_slave_write_resp_chnl_delay_max = $urandom_range(k_ace_slave_write_resp_chnl_delay_min,100);
            endcase
        end
        if (clp.get_arg_value("+k_ace_slave_write_resp_chnl_burst_pct=", arg_value)) begin
            k_ace_slave_write_resp_chnl_burst_pct = arg_value.atoi();
        end
        else begin
            k_ace_slave_write_resp_chnl_burst_pct = ($urandom_range(0,100) < 10) ? 100 :  $urandom_range(5,95);
        end
        if (clp.get_arg_value("+k_ace_slave_snoop_addr_chnl_delay_min=", arg_value)) begin
            k_ace_slave_snoop_addr_chnl_delay_min = arg_value.atoi();
        end
        else begin
            k_ace_slave_snoop_addr_chnl_delay_min = $urandom_range(1,7);
        end
        if (clp.get_arg_value("+k_ace_slave_snoop_addr_chnl_delay_max=", arg_value)) begin
            k_ace_slave_snoop_addr_chnl_delay_max = arg_value.atoi();
        end
        else begin
            randcase
                70 : k_ace_slave_snoop_addr_chnl_delay_max = $urandom_range(k_ace_slave_snoop_addr_chnl_delay_min,15);
                30 : k_ace_slave_snoop_addr_chnl_delay_max = $urandom_range(k_ace_slave_snoop_addr_chnl_delay_min,100);
            endcase
        end
        if (clp.get_arg_value("+k_ace_slave_snoop_addr_chnl_burst_pct=", arg_value)) begin
            k_ace_slave_snoop_addr_chnl_burst_pct = arg_value.atoi();
        end
        else begin
            k_ace_slave_snoop_addr_chnl_burst_pct = ($urandom_range(0,100) < 10) ? 100 :  $urandom_range(5,95);
        end
        if (clp.get_arg_value("+k_ace_slave_snoop_data_chnl_delay_min=", arg_value)) begin
            k_ace_slave_snoop_data_chnl_delay_min = arg_value.atoi();
        end
        else begin
            k_ace_slave_snoop_data_chnl_delay_min = $urandom_range(1,7);
        end
        if (clp.get_arg_value("+k_ace_slave_snoop_data_chnl_delay_max=", arg_value)) begin
            k_ace_slave_snoop_data_chnl_delay_max = arg_value.atoi();
        end
        else begin
            randcase
                70 : k_ace_slave_snoop_data_chnl_delay_max = $urandom_range(k_ace_slave_snoop_data_chnl_delay_min,15);
                30 : k_ace_slave_snoop_data_chnl_delay_max = $urandom_range(k_ace_slave_snoop_data_chnl_delay_min,100);
            endcase
        end
        if (clp.get_arg_value("+k_ace_slave_snoop_data_chnl_burst_pct=", arg_value)) begin
            k_ace_slave_snoop_data_chnl_burst_pct = arg_value.atoi();
        end
        else begin
            k_ace_slave_snoop_data_chnl_burst_pct = ($urandom_range(0,100) < 10) ? 100 :  $urandom_range(5,95);
        end
        if (clp.get_arg_value("+k_ace_slave_snoop_resp_chnl_delay_min=", arg_value)) begin
            k_ace_slave_snoop_resp_chnl_delay_min = arg_value.atoi();
        end
        else begin
            k_ace_slave_snoop_resp_chnl_delay_min = $urandom_range(1,7);
        end
        if (clp.get_arg_value("+k_ace_slave_snoop_resp_chnl_delay_max=", arg_value)) begin
            k_ace_slave_snoop_resp_chnl_delay_max = arg_value.atoi();
        end
        else begin
            randcase
                70 : k_ace_slave_snoop_resp_chnl_delay_max = $urandom_range(k_ace_slave_snoop_resp_chnl_delay_min,15);
                30 : k_ace_slave_snoop_resp_chnl_delay_max = $urandom_range(k_ace_slave_snoop_resp_chnl_delay_min,100);
            endcase
        end
        if (clp.get_arg_value("+k_ace_slave_snoop_resp_chnl_burst_pct=", arg_value)) begin
            k_ace_slave_snoop_resp_chnl_burst_pct = arg_value.atoi();
        end
        else begin
            k_ace_slave_snoop_resp_chnl_burst_pct = ($urandom_range(0,100) < 10) ? 100 :  $urandom_range(5,95);
        end

        if (clp.get_arg_value("+k_sfi_cmd_rsp_burst_pct=", arg_value)) begin
            k_sfi_cmd_rsp_burst_pct = arg_value.atoi();
        end
        else begin
            k_sfi_cmd_rsp_burst_pct = ($urandom_range(0,100) < 10) ? 100 :  $urandom_range(5,50);
        end

        if (clp.get_arg_value("+k_sfi_cmd_rsp_delay_min=", arg_value)) begin
            k_sfi_cmd_rsp_delay_min = arg_value.atoi();
        end
        else begin
            k_sfi_cmd_rsp_delay_min = $urandom_range(1,30);
        end
        if (clp.get_arg_value("+k_sfi_cmd_rsp_delay_max=", arg_value)) begin
            k_sfi_cmd_rsp_delay_max = arg_value.atoi();
        end
        else begin
            randcase
                70 : k_sfi_cmd_rsp_delay_max = $urandom_range(k_sfi_cmd_rsp_delay_min,100);
                30 : k_sfi_cmd_rsp_delay_max = $urandom_range(k_sfi_cmd_rsp_delay_min,500);
            endcase
        end

        if (clp.get_arg_value("+k_sfi_dtw_rsp_burst_pct=", arg_value)) begin
            k_sfi_dtw_rsp_burst_pct = arg_value.atoi();
        end
        else begin
            k_sfi_dtw_rsp_burst_pct = ($urandom_range(0,100) < 10) ? 100 :  $urandom_range(5,50);
        end

        if (clp.get_arg_value("+k_sfi_dtw_rsp_delay_min=", arg_value)) begin
            k_sfi_dtw_rsp_delay_min = arg_value.atoi();
        end
        else begin
            k_sfi_dtw_rsp_delay_min = $urandom_range(400,500);
        end
        if (clp.get_arg_value("+k_sfi_dtw_rsp_delay_max=", arg_value)) begin
            k_sfi_dtw_rsp_delay_max = arg_value.atoi();
        end
        else begin
            randcase
                70 : k_sfi_dtw_rsp_delay_max = $urandom_range(k_sfi_dtw_rsp_delay_min,100);
                30 : k_sfi_dtw_rsp_delay_max = $urandom_range(k_sfi_dtw_rsp_delay_min,500);
            endcase
        end

        if (clp.get_arg_value("+k_sfi_upd_rsp_burst_pct=", arg_value)) begin
            k_sfi_upd_rsp_burst_pct = arg_value.atoi();
        end
        else begin
            k_sfi_upd_rsp_burst_pct = ($urandom_range(0,100) < 10) ? 100 :  $urandom_range(5,50);
        end

        if (clp.get_arg_value("+k_sfi_upd_rsp_delay_min=", arg_value)) begin
            k_sfi_upd_rsp_delay_min = arg_value.atoi();
        end
        else begin
            k_sfi_upd_rsp_delay_min = $urandom_range(1,30);
        end
        if (clp.get_arg_value("+k_sfi_upd_rsp_delay_max=", arg_value)) begin
            k_sfi_upd_rsp_delay_max = arg_value.atoi();
        end
        else begin
            randcase
                70 : k_sfi_upd_rsp_delay_max = $urandom_range(k_sfi_upd_rsp_delay_min,100);
                30 : k_sfi_upd_rsp_delay_max = $urandom_range(k_sfi_upd_rsp_delay_min,500);
            endcase
        end

        flag = 0;
        if (clp.get_arg_value("+k_slow_agent=", arg_value)) begin
            k_slow_agent = arg_value.atoi();
            flag = 1;
        end
        if (clp.get_arg_value("+k_slow_read_agent=", arg_value)) begin
            k_slow_read_agent = arg_value.atoi();
            flag = 1;
        end
        if (clp.get_arg_value("+k_slow_write_agent=", arg_value)) begin
            k_slow_write_agent = arg_value.atoi();
            flag = 1;
        end
        if (clp.get_arg_value("+k_slow_snoop_agent=", arg_value)) begin
            k_slow_snoop_agent = arg_value.atoi();
            flag = 1;
        end
        if (clp.get_arg_value("+no_updates=", arg_value)) begin
            no_updates = arg_value.atoi;
        end

        if (!flag && !gen_no_delay_traffic) begin
            randcase
                65: ;
                5: k_slow_agent       = 1;
                10: k_slow_read_agent  = 1;
                10: k_slow_write_agent = 1;
                10: k_slow_snoop_agent = 1;
            endcase
        end
            
        <%if(obj.fnNativeInterface == "AXI4" || obj.fnNativeInterface == "AXI5") { %>    
            wt_ace_rdshrd                          = 0;
            wt_ace_rdcln                           = 0;
            wt_ace_rdnotshrddty                    = 0;
            wt_ace_rdunq                           = 0;
            wt_ace_clnunq                          = 0;
            wt_ace_mkunq                           = 0;
            wt_ace_dvm_msg                         = 0;
            wt_ace_clnshrd                         = 0;
            wt_ace_clninvl                         = 0;
            wt_ace_mkinvl                          = 0;
            wt_ace_rd_bar                          = 0;
            wt_ace_wrlnunq                         = 0;
            wt_ace_wrcln                           = 0;
            wt_ace_wrbk                            = 0;
            wt_ace_wrevct                          = 0;
            wt_ace_evct                            = 0;
            wt_ace_wr_bar                          = 0;
        <%}%>
        
        //#Stimulus.IOAIU.OWO.RdWrAtmSnp
        <%if((obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") ||
            (obj.DutInfo.useCache) ||
            (obj.DutInfo.orderedWriteObservation == true) ||
            (computedAxiInt.params.eAc)){%>   
            m_system_bfm_seq.k_num_snp.set_value(k_num_snp);
  	    m_system_bfm_seq.wt_snp_cln_dtr.set_value(wt_snp_cln_dtr);
            m_system_bfm_seq.wt_snp_inv_stsh.set_value(wt_snp_inv_stsh);
            m_system_bfm_seq.wt_snp_unq_stsh.set_value(wt_snp_unq_stsh);
            m_system_bfm_seq.wt_snp_stsh_sh.set_value(wt_snp_stsh_sh);
            m_system_bfm_seq.wt_snp_stsh_unq.set_value(wt_snp_stsh_unq);
            m_system_bfm_seq.wt_snp_inv.set_value(wt_snp_inv);
            m_system_bfm_seq.wt_snp_vld_dtr.set_value(wt_snp_vld_dtr);
            m_system_bfm_seq.wt_snp_inv_dtr.set_value(wt_snp_inv_dtr);
            m_system_bfm_seq.wt_snp_cln_dtw.set_value(wt_snp_cln_dtw);
            m_system_bfm_seq.wt_snp_inv_dtw.set_value(wt_snp_inv_dtw);
            m_system_bfm_seq.wt_snp_nitc.set_value(wt_snp_nitc);
            m_system_bfm_seq.wt_snp_nitcci.set_value(wt_snp_nitcci);
            m_system_bfm_seq.wt_snp_nitcmi.set_value(wt_snp_nitcmi);
            m_system_bfm_seq.wt_snp_nosdint.set_value(wt_snp_nosdint);
            m_system_bfm_seq.wt_snp_dvm_msg.set_value(wt_snp_dvm_msg);
            m_system_bfm_seq.wt_snp_prev_addr.set_value(wt_snp_prev_addr);
            m_system_bfm_seq.wt_snp_cmd_req_addr.set_value(wt_snp_cmd_req_addr);
            m_system_bfm_seq.wt_snp_random_addr.set_value(wt_snp_random_addr);
            m_system_bfm_seq.wt_snp_for_stash_random_addr.set_value(wt_snp_stash_addr);
            m_system_bfm_seq.k_num_snp_q_pending.set_value(<%=obj.DutInfo.cmpInfo.nSttCtrlEntries%>);
        <%} else { %> 
            m_system_bfm_seq.k_num_snp.set_value(0);
        <%}%>

          if($test$plusargs("constraint_traffic_to_single_core")) begin
                if((k_csr_seq ==="set_max_errthd" || k_csr_seq ==="ioaiu_csr_cecr_errInt_seq" || k_csr_seq ==="ioaiu_csr_trace_debug_seq"))begin
		select_core = 0;
		end else begin
           	select_core = $urandom_range (0, (<%=obj.DutInfo.nNativeInterfacePorts%>-1));
		end
          end
               m_system_bfm_seq.select_core = select_core;
           
    if (clp.get_arg_value("+wt_ace_wr_bar=", arg_value))
        wt_ace_wr_bar = arg_value.atoi();

    if (clp.get_arg_value("+wt_ace_rd_bar=", arg_value))
        wt_ace_rd_bar = arg_value.atoi();

        //`uvm_info(get_full_name(),$sformatf("before configure agent var:%0d act_var:%0d", m_axi_master_cfg[0].prob_ace_snp_resp_error, prob_ace_snp_resp_error),UVM_LOW);
    configure_axi_agent(m_axi_master_cfg);
        //`uvm_info(get_full_name(),$sformatf("after configure agent var:%0d act_var:%0d", m_axi_master_cfg[0].prob_ace_snp_resp_error, prob_ace_snp_resp_error),UVM_LOW);
              
        if($test$plusargs("no_smi_delay")) begin
            <%if(obj.NO_SMI === undefined){%>
                <%var NSMIIFTX = obj.nSmiTx;
                for(var i = 0; i < NSMIIFTX; i++){%>
                    m_smi_agent_cfg.m_smi<%=i%>_tx_port_config.k_delay_min.set_value(0);
                    m_smi_agent_cfg.m_smi<%=i%>_tx_port_config.k_delay_max.set_value(0);
                    m_smi_agent_cfg.m_smi<%=i%>_tx_port_config.k_burst_pct.set_value(100);
                <%}%>
                <%var NSMIIFRX = obj.nSmiRx;
                for (var i = 0; i < NSMIIFRX; i++){%>
                    m_smi_agent_cfg.m_smi<%=i%>_rx_port_config.k_delay_min.set_value(0);
                    m_smi_agent_cfg.m_smi<%=i%>_rx_port_config.k_delay_max.set_value(0);
                    m_smi_agent_cfg.m_smi<%=i%>_rx_port_config.k_burst_pct.set_value(100);
                <%}%>
            <%}%>
        end
       
        `uvm_info("IOAIU<%=obj.Id%> TEST", $psprintf("dvm_resp_order: %b", dvm_resp_order),UVM_MEDIUM)
        uvm_config_db#(int)::set(null,"<%=obj.DutInfo.strRtlNamePrefix%>_env","dvm_resp_order",dvm_resp_order);
        if(<%=obj.DutInfo.nNativeInterfacePorts%> > 1)begin
        sel_bank = 0;
        sel_ott_bank = 0;
        end
        uvm_config_db#(int)::set(null,"<%=obj.DutInfo.strRtlNamePrefix%>_env","sel_bank",sel_bank);
        <%if(!obj.DutInfo.useCache) {%>
        if(SYS_nSysCacheline >= 64)
        sel_ott_bank = 0;
        <% } %>
	uvm_config_db#(int)::set(null,"<%=obj.DutInfo.strRtlNamePrefix%>_env","sel_ott_bank",sel_ott_bank); 
        foreach(tctrlr[idx]) begin
            <%if(computedAxiInt.params.eTrace){%>
                tctrlr[idx] = 32'h1;
            <%}else{%>
                tctrlr[idx] = 32'h0;
            <%}%>
        end

        // FIXME: billc: 2021_0920: why does this tctrlr code not get executed for all trigger register sets instead of just set 0?
       <%if(!computedAxiInt.params.eTrace) {%> // if eTrace is 0 or null
            tctrlr[0].native_trace_en = 0; // can override master_trace_en plusarg
        <%}%>

        foreach(tctrlr[idx]) begin
            uvm_config_db#(int)::set(null,"<%=obj.DutInfo.strRtlNamePrefix%>_env",$sformatf("tctrlr_%0d",idx),tctrlr[idx]);
        end
        foreach(topcr0[idx]) begin
            uvm_config_db#(int)::set(null,"<%=obj.DutInfo.strRtlNamePrefix%>_env",$sformatf("topcr0_%0d",idx),topcr0[idx]);
        end
        foreach(topcr1[idx]) begin
            uvm_config_db#(int)::set(null,"<%=obj.DutInfo.strRtlNamePrefix%>_env",$sformatf("topcr1_%0d",idx),topcr1[idx]);
        end
        foreach(tubr[idx]) begin
            uvm_config_db#(int)::set(null,"<%=obj.DutInfo.strRtlNamePrefix%>_env",$sformatf("tubr_%0d",idx),tubr[idx]);
        end
        foreach(tubmr[idx]) begin
            uvm_config_db#(int)::set(null,"<%=obj.DutInfo.strRtlNamePrefix%>_env",$sformatf("tubmr_%0d",idx),tubmr[idx]);
        end
        <%for(var i = 0; i < obj.DutInfo.nNativeInterfacePorts; i++){%>
            m_env_cfg[<%=i%>].has_scoreboard = aiu_scb_en;
        <%}%>

        if ($test$plusargs("CMDrsp_delayed_test")) begin // For bring_up_test_run_out_credit_dce/dmi_dii
            `uvm_info("IOAIU<%=obj.Id%> TEST", "Delay is added on CMDrsp SMI port for credit runsout test", UVM_LOW)
            m_smi_agent_cfg.m_smi1_tx_port_config.k_burst_pct.set_value(100);
            m_smi_agent_cfg.m_smi1_tx_port_config.k_delay_min.set_value(3000);
            m_smi_agent_cfg.m_smi1_tx_port_config.k_delay_max.set_value(3100);
        end

        if ($test$plusargs("large_CMDrsp_delay")) begin // For bring_up_test_run_out_credit_dce/dmi_dii
            `uvm_info("IOAIU<%=obj.Id%> TEST", "Large Delay is added on CMDrsp SMI port for credit runsout test", UVM_LOW)
            m_smi_agent_cfg.m_smi1_tx_port_config.k_burst_pct.set_value(100);
            m_smi_agent_cfg.m_smi1_tx_port_config.k_delay_min.set_value(3000);
            m_smi_agent_cfg.m_smi1_tx_port_config.k_delay_max.set_value(3100);
        end
        
        if ($test$plusargs("smi1_tx_port_no_delay")) begin // For bring_up_test_run_out_credit_dce/dmi_dii
            m_smi_agent_cfg.m_smi1_tx_port_config.k_burst_pct.set_value(100);
            m_smi_agent_cfg.m_smi1_tx_port_config.k_delay_min.set_value(0);
            m_smi_agent_cfg.m_smi1_tx_port_config.k_delay_max.set_value(0);
        end

         //#Stimulus.IOAIU.delayedCMDrsp
        if ($test$plusargs("CMDrsp_time_out_test")) begin//run this test for only configs that do not need attach_seq. refer conc-10986 for details
            `uvm_info("IOAIU<%=obj.Id%> TEST", "Delay is added on CMDrsp SMI port for time out error test", UVM_LOW)
            m_smi_agent_cfg.m_smi1_tx_port_config.k_burst_pct.set_value(0);
            m_smi_agent_cfg.m_smi1_tx_port_config.k_delay_min.set_value(30000);
            m_smi_agent_cfg.m_smi1_tx_port_config.k_delay_max.set_value(30500);
        end
         
        //#Stimulus.IOAIU.delayedSTRreq 
        if ($test$plusargs("STRreq_time_out_test") ||  $test$plusargs("dvm_time_out_test")) begin
            `uvm_info("IOAIU<%=obj.Id%> TEST", "Delay is added on STRreq SMI port for time out error test", UVM_LOW)
            m_smi_agent_cfg.m_smi0_tx_port_config.k_burst_pct.set_value(0);
            m_smi_agent_cfg.m_smi0_tx_port_config.k_delay_min.set_value(30000);
            m_smi_agent_cfg.m_smi0_tx_port_config.k_delay_max.set_value(30500);
        end
    
	//#Stimulus.IOAIU.delayedDTWreq
        <%if(obj.DutInfo.useCache){%>
        if ($test$plusargs("CCP_eviction_time_out_test")) begin
            `uvm_info("IOAIU<%=obj.Id%> TEST", "Delay is added on DTWreq SMI port for time out error test", UVM_LOW)
            m_smi_agent_cfg.m_smi2_rx_port_config.k_burst_pct.set_value(0);
            m_smi_agent_cfg.m_smi2_rx_port_config.k_delay_min.set_value(30000);
            m_smi_agent_cfg.m_smi2_rx_port_config.k_delay_max.set_value(30500);
        end
        <% } %>
        // <%if(!obj.SFI_BFM_TEST_MODE){%>
		// 	<%for(var i = 0; i < obj.DutInfo.nNativeInterfacePorts; i++){%>
        //     if(!uvm_config_db#(virtual <%=obj.BlockId + '_axi_if'%>)::get(.cntxt( this ),
        //         .inst_name( "" ),
        //         .field_name( "axi_master_vif_<%=i%>" ),
        //         .value( m_axi_master_cfg[<%=i%>].m_vif ))) begin
        //             `uvm_error("aiu_test", "axi_master_vif not found")
        //     end
        // 	<%}%>
        // <%}%>

        // <%if(( obj.DutInfo.useCache)){%> 
        //     if (!uvm_config_db#(virtual <%=obj.BlockId%>_ccp_if)::get(.cntxt( this ),
        //                                             .inst_name( "*" ),
        //                                             .field_name("ccp<%=obj.Id + '_vif'%>"),
        //                                             .value( m_ccp_cfg.m_vif ))) begin
        //         `uvm_error("ncbu_base_test", "ccp_vif not found")
        //     end
        // <%}%>

		// <%for(var i = 0; i < obj.DutInfo.nNativeInterfacePorts; i++){%>
        //     // Setting the AXI master agent to be active
        //     m_axi_master_cfg[<%=i%>].m_intf_type  = IS_ACE_INTF;
        //     m_axi_master_cfg[<%=i%>].delay_export = 1;
        //     `ifndef USE_VIP_SNPS  
        //         m_axi_master_cfg[<%=i%>].active = UVM_ACTIVE;
        //         m_axi_slave_cfg[<%=i%>].active  = UVM_ACTIVE;
        //         `uvm_info("build_phase 1", "Exiting...", UVM_LOW)
        //     `elsif
        //         m_axi_master_cfg[<%=i%>].active = UVM_PASSIVE;
        //         m_axi_slave_cfg[<%=i%>].active  = UVM_PASSIVE;
        //         `uvm_info("build_phase 2", "Exiting...", UVM_LOW)
        //     `endif

        //     <%if(obj.SFI_BFM_TEST_MODE){%>
        //         m_axi_master_cfg[<%=i%>].active = UVM_PASSIVE;
        //         m_axi_slave_cfg[<%=i%>].active  = UVM_PASSIVE;
        //     <%}%>
        //     m_axi_slave_cfg[<%=i%>].m_intf_type  = IS_AXI4_INTF;
        //     m_axi_slave_cfg[<%=i%>].delay_export = 1;
        // <%}%>

        <%if(obj.INHOUSE_APB_VIP){%>
            m_apb_cfg = apb_agent_config::type_id::create("m_apb_cfg", this);
            if (!uvm_config_db#(virtual <%=obj.BlockId%>_apb_if)::get(.cntxt( this ),
                                        .inst_name( "*" ),
                                        .field_name( "apb_if" ),
                                        .value( m_apb_cfg.m_vif ))) begin
                `uvm_error("ioaiu_base_test", "APB if not found")
            end

`uvm_info("build_phase", "Got m_apb_cfg", UVM_NONE)
if (!m_apb_cfg )
  `uvm_info("build_phase", "Null m_apb_cfg", UVM_NONE)
if (!m_apb_cfg.m_vif )
  `uvm_info("build_phase", "Null m_apb_cfg.m_vif", UVM_NONE)
        <%}%>
        <% if((obj.testBench=="io_aiu" || obj.DutInfo.useCache) && (obj.INHOUSE_APB_VIP) && obj.testBench != "fsys" && obj.testBench != "emu") { %>
            m_env_cfg[0].m_apb_cfg = m_apb_cfg;
        <%}%>

        <%for(var i = 0; i < obj.DutInfo.nNativeInterfacePorts; i++){%>
        if(!uvm_config_db#(virtual <%=obj.BlockId%>_probe_if )::get(null,"*", "u_csr_probe_if<%=i%>",u_csr_probe_vif[<%=i%>])) begin
            `uvm_error("NOVIF",{"virtual interface must be set  for :",get_full_name(),".vif"})
        end
       <%}%>


        `uvm_info("build_phase", "Exiting...", UVM_LOW)
    endfunction: build_phase

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

        <%for(let i = 0; i < obj.DutInfo.nNativeInterfacePorts; i++){%>
            if(m_env_cfg[<%=i%>].has_scoreboard) begin
                mp_env.m_smi_demux.m_smi_scb_ap[<%=i%>].connect             ( mp_env.m_env[<%=i%>].m_scb.ioaiu_smi_port      ) ;
                mp_env.m_smi_demux. m_smi_every_beat_scb_ap[<%=i%>].connect             ( mp_env.m_env[<%=i%>].m_scb.ioaiu_smi_every_beat_port) ;
            end
        <%}%>

		if(m_env_cfg[0].hasRAL || mp_env.m_env[0].m_cfg.hasRAL) begin
           // `uvm_info(get_full_name(), "env0.m_cfg.hasRAL is asserted", UVM_LOW)
        	<%for(let i = 0; i < obj.DutInfo.nNativeInterfacePorts; i++){%>
                if (mp_env.m_env[<%=i%>].m_scb != null) begin
            		`uvm_info(get_full_name(), "env<%=i%> scb is not null", UVM_LOW)
					if(mp_env.m_env[0].m_regs !== null) begin
        		    	mp_env.m_env[<%=i%>].m_scb.m_regs = mp_env.m_env[0].m_regs;
            			`uvm_info(get_full_name(), "env<%=i%> scb m_regs is assigned", UVM_LOW)
        		    end
                    mp_env.m_env[0].m_apb_agent.m_apb_monitor.apb_req_ap.connect(mp_env.m_env[<%=i%>].m_scb.analysis_apb_port);
            		`uvm_info(get_full_name(), "env<%=i%> scb apb_port is connected", UVM_LOW)
        		end
        	<%}%>
		end
               `ifdef USE_VIP_SNPS
                cb1 = new("master_modify_computed_parity_value_cb");
               uvm_callbacks#(svt_amba_uvm_pkg::svt_axi_master, svt_amba_uvm_pkg::svt_axi_master_callback)::add(axi_system_env.amba_system_env.axi_system[0].master[0].driver,cb1);
                uvm_config_db#(svt_amba_uvm_pkg::svt_axi_master_callback)::set(this, "*", "cb1", cb1);
               `endif

    endfunction : connect_phase

    function void start_of_simulation_phase(uvm_phase phase);
        <% if(obj.testBench == 'io_aiu') { %>
         `ifdef VCS 
         ioaiu_report_server my_server = new();
          `endif
        <% } %>
        super.start_of_simulation_phase(phase);
        <% if(obj.testBench == 'io_aiu') { %>
         `ifdef VCS 
           uvm_report_server::set_server( my_server );
         `endif
         <% } %>
        heartbeat(phase);
    endfunction: start_of_simulation_phase
    task initialize_aiu_helper_var_snps();
`ifdef USE_VIP_SNPS

/*<% var ioaiu_cntr=0;   var ioaiu_idx_with_multi_core=0;
for(var pidx=0; pidx<obj.nAIUs; pidx++) {  
if(!obj.AiuInfo[pidx].fnNativeInterface.match("CHI")) { 
for(var i=0; i<obj.AiuInfo[pidx].nNativeInterfacePorts; i++) { %>
    io_subsys_mstr_agnt_seqr_a[<%=ioaiu_idx_with_multi_core%>]   = `SVT_IOAIU<%=ioaiu_cntr%>_<%=i%>_MASTER_SEQR_PATH;
    io_subsys_mstr_agnt_seqr_str[<%=ioaiu_idx_with_multi_core%>] = $psprintf("%0s",`STRINGIFY(`SVT_IOAIU<%=ioaiu_cntr%>_<%=i%>_MASTER_SEQR_PATH));
<% ioaiu_idx_with_multi_core = ioaiu_idx_with_multi_core + 1;} ioaiu_cntr = ioaiu_cntr + 1;} } %>*/

//    `uvm_info("CONCERTO_FULLSYS_TEST", $psprintf("fn:initialize_conc_helper_var_snps mstr_agnt_seqr_str - %0p", io_subsys_mstr_agnt_seqr_str), UVM_LOW);
io_subsys_mstr_agnt_seqr_a[0]   = axi_system_env.amba_system_env.axi_system[0].sequencer.master_sequencer[0];
 `endif
 
endtask: initialize_aiu_helper_var_snps

    function void end_of_elaboration_phase(uvm_phase phase);
        uvm_verbosity severity;
        `uvm_info("end_of_elaboration_phase", "Entered...", UVM_LOW)
        $cast(severity, this.get_report_verbosity_level());
        if(severity == UVM_MEDIUM) begin
            uvm_top.print_topology();
        end
         initialize_aiu_helper_var_snps();
        `uvm_info("end_of_elaboration_phase", "Exiting...", UVM_LOW)
    endfunction: end_of_elaboration_phase

    task run_phase(uvm_phase phase);
        uvm_objection uvm_obj = phase.get_objection();
        axi_master_snoop_seq m_master_snoop_seq[<%=obj.DutInfo.nNativeInterfacePorts%>];
       <% if(obj.testBench == 'io_aiu') { %>
            
       //`ifndef VCS
        //common_knob_class hit_pct = new("hit_pct",this,{100},{{40,70}});
        //prob_of_new_set = new("prob_of_new_set",this,{100},{{101,101}}); 
       //`else // `ifndef VCS
        common_knob_class hit_pct = new("hit_pct",this,{100},'{'{m_min_range:40,m_max_range:70}});
        prob_of_new_set = new("prob_of_new_set",this,{100},'{'{m_min_range:101,m_max_range:101}}); 
       //`endif // `ifndef VCS ... `else ... 
       <% } else {%>
        common_knob_class hit_pct = new("hit_pct",this,{100},{{40,70}});
        prob_of_new_set = new("prob_of_new_set",this,{100},{{101,101}}); 
       <% } %>

        `ifndef USE_VIP_SNPS
                <%if((((obj.fnNativeInterface === "ACELITE-E") || (obj.fnNativeInterface === "ACE-LITE")) && (obj.DutInfo.cmpInfo.nDvmSnpInFlight > 0)) || (obj.fnNativeInterface == "ACE")) { %>
                    <%for(let i = 0; i < obj.DutInfo.nNativeInterfacePorts; i++){%>
                        m_master_snoop_seq[<%=i%>] = axi_master_snoop_seq::type_id::create("m_master_snoop_seq[<%=i%>]");
                    <%}%>
                <%}%>
            `endif
            
           `ifndef USE_VIP_SNPS
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
        m_ace_cache_model[<%=i%>].prob_of_new_set                     = prob_of_new_set.get_value();
        //FIXME : Check if we need any guards
        <%if((((obj.fnNativeInterface === "ACELITE-E") || 
               (obj.fnNativeInterface === "ACE-LITE")) && 
               (obj.DutInfo.cmpInfo.nDvmSnpInFlight > 0)) || 
               (obj.fnNativeInterface == "ACE")){%>
                m_ace_cache_model[<%=i%>].prob_ace_snp_resp_error             = mp_env.m_env[<%=i%>].m_axi_master_agent.m_cfg.prob_ace_snp_resp_error;
                //`uvm_info(get_full_name, $sformatf("cache_model_val:%0d cfg_val:%0d", m_ace_cache_model[<%=i%>].prob_ace_snp_resp_error, mp_env.m_env[<%=i%>].m_axi_master_agent.m_cfg.prob_ace_snp_resp_error),UVM_LOW)
        <%}%>
       <%}%>

            <%if(!obj.SFI_BFM_TEST_MODE){%>
                <%for(var i = 0; i < obj.DutInfo.nNativeInterfacePorts; i++){%>
                        <%if((((obj.fnNativeInterface === "ACELITE-E") || (obj.fnNativeInterface === "ACE-LITE")) && (obj.DutInfo.cmpInfo.nDvmSnpInFlight > 0)) || (obj.fnNativeInterface == "ACE")) { %>
                        m_master_snoop_seq[<%=i%>].m_read_addr_chnl_seqr               = mp_env.m_env[<%=i%>].m_axi_master_agent.m_read_addr_chnl_seqr;
                        m_master_snoop_seq[<%=i%>].m_read_data_chnl_seqr               = mp_env.m_env[<%=i%>].m_axi_master_agent.m_read_data_chnl_seqr;
                        m_master_snoop_seq[<%=i%>].m_snoop_addr_chnl_seqr              = mp_env.m_env[<%=i%>].m_axi_master_agent.m_snoop_addr_chnl_seqr;
                        m_master_snoop_seq[<%=i%>].m_snoop_data_chnl_seqr              = mp_env.m_env[<%=i%>].m_axi_master_agent.m_snoop_data_chnl_seqr;
                        m_master_snoop_seq[<%=i%>].m_snoop_resp_chnl_seqr              = mp_env.m_env[<%=i%>].m_axi_master_agent.m_snoop_resp_chnl_seqr;
                        m_master_snoop_seq[<%=i%>].m_ace_cache_model                     = m_ace_cache_model[<%=i%>]; 
                    <%}%>
                <%}%>
            <%}%>
            `endif
       

        //`uvm_info(get_full_name(),$sformatf("entered run_phase"),UVM_LOW);
        if (aiu_scb_en && ($test$plusargs("max_event_delay") || $test$plusargs("wrong_sysrsp_target_id") || $test$plusargs("tcap_reg_prog_en"))) begin 
    	    phase.phase_done.set_drain_time(this, 1ms);
        end else begin 
            phase.phase_done.set_drain_time(this, 10us);
        end 

        fork
            begin
              m_addr_mgr.get_connectivity_if();
            end
        join_none
        

        
        <%if(obj.NO_SYS_BFM === undefined) { %>
            m_system_bfm_seq.m_smi_virtual_seqr                 = mp_env.m_smi_agent.m_smi_virtual_seqr; // FIXME : SAI MP - organize smi agent
            m_system_bfm_seq.e_tb_clk                           = e_tb_clk; 
            m_system_bfm_seq.high_system_bfm_slv_rsp_delays     = (gen_no_delay_traffic) ? 0 : high_system_bfm_slv_rsp_delays;
            <%if( obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") { %>
                m_system_bfm_seq.m_ncbu_cache_handle = mp_env.m_env[0].m_scb; // CONC-10779
            <%}%>
            <%if(obj.DutInfo.useCache ) { %>
                <%for(var i = 0; i < obj.DutInfo.nNativeInterfacePorts; i++){%>
                m_system_bfm_seq.m_ncbu_cache_handle[<%=i%>] = mp_env.m_env[<%=i%>].m_scb; // CONC-10779
                <%}%>
            <%}%>
            m_system_bfm_seq.ioaiu_scb_handle = mp_env.m_env[0].m_scb;
            m_system_bfm_seq.m_addr_mgr.set_addr_collision_pct(<%=obj.AiuInfo[obj.Id].FUnitId%>, 1, hit_pct.get_value());
            fork
                `ifndef USE_VIP_SNPS  
                 <%if((((obj.fnNativeInterface === "ACELITE-E") || (obj.fnNativeInterface === "ACE-LITE")) && (obj.DutInfo.cmpInfo.nDvmSnpInFlight > 0)) || (obj.fnNativeInterface == "ACE")) { %>
                //fork
                <%for(let i = 0; i < obj.DutInfo.nNativeInterfacePorts; i++){%>
	                m_master_snoop_seq[<%=i%>].start(null);
                <%}%>
                //join_none
            <%}%>																		  
                `endif
      		    m_system_bfm_seq.start(null);
            join_none
        <%}%>
        //`uvm_info(get_full_name(),$sformatf("exit run_phase"),UVM_LOW);

    endtask : run_phase

	function void assign_seqr_handles();
		   	mp_env.m_ioaiu_vseqr[0].m_read_addr_chnl_seqr   = mp_env.m_env[0].m_axi_master_agent.m_read_addr_chnl_seqr;
            mp_env.m_ioaiu_vseqr[0].m_read_data_chnl_seqr   = mp_env.m_env[0].m_axi_master_agent.m_read_data_chnl_seqr;
            mp_env.m_ioaiu_vseqr[0].m_write_addr_chnl_seqr  = mp_env.m_env[0].m_axi_master_agent.m_write_addr_chnl_seqr;
            mp_env.m_ioaiu_vseqr[0].m_write_data_chnl_seqr  = mp_env.m_env[0].m_axi_master_agent.m_write_data_chnl_seqr;
            mp_env.m_ioaiu_vseqr[0].m_write_resp_chnl_seqr  = mp_env.m_env[0].m_axi_master_agent.m_write_resp_chnl_seqr;
            <%if((obj.fnNativeInterface == 'ACE') || (computedAxiInt.params.eAc==1)){%>
                mp_env.m_ioaiu_vseqr[0].m_snoop_addr_chnl_seqr  = mp_env.m_env[0].m_axi_master_agent.m_snoop_addr_chnl_seqr;
                mp_env.m_ioaiu_vseqr[0].m_snoop_data_chnl_seqr  = mp_env.m_env[0].m_axi_master_agent.m_snoop_data_chnl_seqr;
                mp_env.m_ioaiu_vseqr[0].m_snoop_resp_chnl_seqr  = mp_env.m_env[0].m_axi_master_agent.m_snoop_resp_chnl_seqr;
            <%}%>
	endfunction:assign_seqr_handles
	
        task read_csr(input axi_axaddr_t addr, output bit[31:0] data);
            axi_single_rdnosnp_seq m_iordnosnp_seq;
            bit [WXDATA-1:0] rdata;
            axi_rresp_t rresp;
            int addr_mask;
            int addr_offset;

            addr_mask = (WXDATA/8)-1;
            addr_offset = addr & addr_mask;

            mp_env.m_ioaiu_vseqr[0].m_read_addr_chnl_seqr   = mp_env.m_env[0].m_axi_master_agent.m_read_addr_chnl_seqr;
            mp_env.m_ioaiu_vseqr[0].m_read_data_chnl_seqr   = mp_env.m_env[0].m_axi_master_agent.m_read_data_chnl_seqr;
            mp_env.m_ioaiu_vseqr[0].m_write_addr_chnl_seqr  = mp_env.m_env[0].m_axi_master_agent.m_write_addr_chnl_seqr;
            mp_env.m_ioaiu_vseqr[0].m_write_data_chnl_seqr  = mp_env.m_env[0].m_axi_master_agent.m_write_data_chnl_seqr;
            mp_env.m_ioaiu_vseqr[0].m_write_resp_chnl_seqr  = mp_env.m_env[0].m_axi_master_agent.m_write_resp_chnl_seqr;
            <%if((obj.fnNativeInterface == 'ACE') || (computedAxiInt.params.eAc==1)){%>
                mp_env.m_ioaiu_vseqr[0].m_snoop_addr_chnl_seqr  = mp_env.m_env[0].m_axi_master_agent.m_snoop_addr_chnl_seqr;
                mp_env.m_ioaiu_vseqr[0].m_snoop_data_chnl_seqr  = mp_env.m_env[0].m_axi_master_agent.m_snoop_data_chnl_seqr;
                mp_env.m_ioaiu_vseqr[0].m_snoop_resp_chnl_seqr  = mp_env.m_env[0].m_axi_master_agent.m_snoop_resp_chnl_seqr;
            <%}%>
            m_iordnosnp_seq        = axi_single_rdnosnp_seq::type_id::create("m_iordnosnp_seq");
            m_iordnosnp_seq.m_addr = addr;
            m_iordnosnp_seq.start(mp_env.m_ioaiu_vseqr[0]);
            rdata = (m_iordnosnp_seq.m_seq_item.m_has_data) ? m_iordnosnp_seq.m_seq_item.m_read_data_pkt.rdata[0] : 0;
            data  = rdata[(addr_offset*8)+:32];
            rresp = (m_iordnosnp_seq.m_seq_item.m_has_data) ? m_iordnosnp_seq.m_seq_item.m_read_data_pkt.rresp    : 0;

            <%if(obj.DutInfo.fnCsrAccess == 1){%>
            	if(rresp) begin
                	`uvm_error("READ_CSR",$sformatf("Act_RResp:%0p Exp_RResp:OKAY on Read Data when fnCsrAccess==1", axi_bresp_enum_t'(rresp)))
            	end
            <%} else {%>
            	if(rresp != 3) begin
                	`uvm_error("READ_CSR",$sformatf("Act_RResp:%0p Exp_RResp:DECERR on Read Data when fnCsrAccess==1", axi_bresp_enum_t'(rresp)))
            	end
            <%}%>
        endtask : read_csr

    function void heartbeat(uvm_phase phase);
        uvm_callbacks_objection cb;
        uvm_heartbeat hb;
        uvm_event e;
        uvm_component comp_q[$];
        timeout_catcher catcher;
        uvm_phase run_phase;

        e = new("e");
        run_phase = phase.find_by_name("run", 0);

        catcher                  = timeout_catcher::type_id::create("catcher", this);
        catcher.phase            = run_phase;
        <%for(var i = 0; i < obj.DutInfo.nNativeInterfacePorts; i++){%>
            catcher.env[<%=i%>]              = mp_env.m_env[<%=i%>];
        <%}%>
        catcher.m_system_bfm_seq = m_system_bfm_seq;
        
        uvm_report_cb::add(null, catcher);
    
        if(!$cast(cb, run_phase.get_objection())) begin
            `uvm_fatal("Run", "run phase objection type isn't of type uvm_callbacks_objection. you need to define UVM_USE_CALLBACKS_OBJECTION_FOR_TEST_DONE!");
        end

        hb = new("activity_heartbeat", this, cb);
        uvm_top.find_all("*", comp_q, this);
        hb.set_mode(UVM_ANY_ACTIVE);
        hb.set_heartbeat(e, comp_q);

        fork begin
            forever begin
                //`uvm_info("heartbeat",$sformatf("before trigger k_timeout=%0d", k_timeout),UVM_LOW);
                #(k_timeout*1ns) e.trigger();
                //`uvm_info("heartbeat",$sformatf("after trigger k_timeout=%0d", k_timeout),UVM_LOW);
            end
        end
        join_none
    endfunction: heartbeat

    function void set_inactivity_period(int timeout);
        k_timeout = timeout;
    endfunction: set_inactivity_period
    function void end_of_simulation_phase(uvm_phase phase);
    endfunction : end_of_simulation_phase

    function void check_phase(uvm_phase phase);
        int inj_cntl;
        bit targ_id_err;
        <%if((obj.DutInfo.ccpParams.TagErrInfo === "PARITYENTRY") || (obj.DutInfo.ccpParams.DataErrInfo === "PARITYENTRY") || (obj.DutInfo.cmpInfo.OttErrorType === "PARITYENTRY")){%>
            bit isMemoryProtParity = 1;
        <%}else{%>
            bit isMemoryProtParity = 0;
        <%}%>
        super.check_phase(phase);
        //`uvm_info(get_full_name(),$sformatf("entered check_phase"),UVM_LOW);
        $value$plusargs("inj_cntl=%d",inj_cntl);

        //#Check.IOAIU.UncorrectableErr_MissionFault
        <%if(obj.useResiliency){%>
			<%for(var i = 0; i < obj.DutInfo.nNativeInterfacePorts; i++){%>
                if(mp_env.m_env[<%=i%>].m_cfg.has_scoreboard) begin
                    if(!(inj_cntl > 1) && mp_env.m_env[<%=i%>].m_scb.hasErr == 0 && mp_env.m_env[<%=i%>].m_scb.num_smi_uncorr_err == 0 && mp_env.m_env[<%=i%>].m_scb.num_smi_parity_err == 0 && !($test$plusargs("uncorr_error_inj_pcnt") || $test$plusargs("parity_error_inj_pcnt") || $test$plusargs("test_unit_duplication") || $test$plusargs("test_placeholder_connectivity")) && mp_env.m_env[<%=i%>].m_scb.aiu_double_bit_errors_enabled == 0 && !(($test$plusargs("ccp_single_bit_ott_direct_error_test") && isMemoryProtParity) || ($test$plusargs("ccp_multi_blk_single_ott_direct_error_test") && isMemoryProtParity)) && !(($test$plusargs("ccp_single_bit_tag_direct_error_test") && isMemoryProtParity) || ($test$plusargs("ccp_multi_blk_single_tag_direct_error_test") && isMemoryProtParity) || ($test$plusargs("STRreq_time_out_test")) || ($test$plusargs("CMDrsp_time_out_test")) ||  ($test$plusargs("dvm_time_out_test")) || ($test$plusargs("CCP_eviction_time_out_test")) || ($test$plusargs("timeout_attach_sys_rsp_error")) || ($test$plusargs("timeout_detach_sys_rsp_error"))  || $test$plusargs("inject_parity_err_aw_chnl") || $test$plusargs("inject_parity_err_ar_chnl") || $test$plusargs("inject_parity_err_w_chnl") || ($test$plusargs("inject_parity_err_cr_chnl"))||($test$plusargs("wrong_cmdrsp_target_id") || $test$plusargs( "wrong_dtrreq_target_id") || $test$plusargs( "wrong_dtwrsp_target_id" ) || $test$plusargs( "wrong_strreq_target_id") ||  <%if((((obj.fnNativeInterface === "ACELITE-E") || (obj.fnNativeInterface === "ACE-LITE")) && (obj.DutInfo.cmpInfo.nDvmSnpInFlight > 0)) || (obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") || ((obj.fnNativeInterface == "AXI4" || obj.fnNativeInterface == "AXI5") && obj.DutInfo.useCache)) { %>
$test$plusargs("wrong_sysrsp_target_id")  || <%}%>  $test$plusargs("wrong_sysreq_target_id")) ) && !(($test$plusargs("ccp_single_bit_data_direct_error_test") && isMemoryProtParity) || ($test$plusargs("ccp_multi_blk_single_data_direct_error_test") && isMemoryProtParity)) && (!($test$plusargs("disable_mission_fault"))) && !$test$plusargs("enable_ev_timeout") && !$test$plusargs("event_sys_rsp_timeout_error") && k_csr_seq !="ioaiu_interface_parity_detection_seq") begin
                        if (u_csr_probe_vif[<%=i%>].fault_mission_fault == 1 || u_csr_probe_vif[<%=i%>].fault_latent_fault == 1) begin
                            `uvm_error(get_full_name(), $psprintf("mission fault:%0d latent_fault:%0d both should be zero for no error injection",u_csr_probe_vif[<%=i%>].fault_mission_fault, u_csr_probe_vif[<%=i%>].fault_latent_fault == 1))
                        end
                    end
                end
                      if(inj_cntl > 1 || u_csr_probe_vif[<%=i%>].uncorr_err_injected == 1 || isTargetIdErrorTest() || isTimeoutErrro() || isSyscoErrorTest() || $test$plusargs("dis_uedr_med_4resiliency")) begin
                string log_s = "";
                if(inj_cntl>1) begin
                    log_s = "uncorrectable error injection";
                end else if(isTargetIdErrorTest()) begin
                    //#Check.IOAIU.WrongTargetId.mission_fault
                    log_s = "wrong traget ID error injection";
                end else if(isTimeoutErrro()) begin
		    log_s = "Timeout error injection";
                end else if(isSyscoErrorTest()) begin
		    log_s = "Sysco error injection";
                end else begin
                    log_s = "CCP data/tag/ott memory uncrroctable error injection";
                end

                if(u_csr_probe_vif[<%=i%>].fault_mission_fault === 0) begin
                    `uvm_error(get_full_name(),$sformatf("mission fault should be asserted for %0s", log_s))
                end else if (u_csr_probe_vif[<%=i%>].fault_mission_fault === 1) begin
                    `uvm_info(get_full_name(),$sformatf("mission fault asserted due to %0s", log_s), UVM_NONE)
                end else if (u_csr_probe_vif[<%=i%>].fault_mission_fault === 'hx) begin
                    `uvm_error(get_full_name(),$sformatf("mission fault goes unknown for %0s", log_s))
                end
            end
          <%}%>
        <%}%>
//#Check.IOAIU.EOT.TransActv
        <%for(var i = 0; i < obj.DutInfo.nNativeInterfacePorts; i++){%>
            if(mp_env.m_env[<%=i%>].m_cfg.has_scoreboard) begin
                if(mp_env.m_env[<%=i%>].m_scb.hasErr == 0 && mp_env.m_env[<%=i%>].m_scb.num_smi_uncorr_err == 0 && mp_env.m_env[<%=i%>].m_scb.num_smi_parity_err == 0 && u_csr_probe_vif[<%=i%>].TcapBusy == 0 ) begin
                    if(u_csr_probe_vif[<%=i%>].TransActv !== 0) begin
                        `uvm_error(get_full_name(),"TransActv(DUT.ioaiu_core.t_pma_busy) should be zero at EOT")
                    end
					else begin 
                        `uvm_info(get_full_name(),"TransActv(DUT.ioaiu_core.t_pma_busy) is zero at EOT", UVM_LOW)
					end
                end
            end
        <%}%>
        
        //`uvm_info(get_full_name(),$sformatf("exit check_phase"),UVM_LOW);
    endfunction:check_phase
 
    function void report_phase(uvm_phase phase);
        string spkt;
        run_report(phase);
        urs                     = uvm_report_server::get_server();
        error_count             = urs.get_severity_count(UVM_ERROR);
        fatal_count             = urs.get_severity_count(UVM_FATAL);
        
        if ((error_count != 0) | (fatal_count != 0)) begin
        `uvm_info("TEST", "\n ===========\nUVM FAILED!\n===========", UVM_FULL);
        end else begin
        `uvm_info("TEST", "\n===========\nUVM PASSED!\n===========", UVM_FULL);
        end
    endfunction : report_phase
    //#Check.IOAIU.WrongTargetId.mission_fault
    function bit isTargetIdErrorTest();
        return $test$plusargs("wrong_updrsp_target_id") || 
               $test$plusargs("wrong_cmdrsp_target_id") || 
               $test$plusargs("wrong_dtwrsp_target_id") || 
               $test$plusargs("wrong_dtrrsp_target_id") || 
               $test$plusargs("wrong_dtrreq_target_id") || 
               $test$plusargs("wrong_strreq_target_id") || 
               $test$plusargs("wrong_snpreq_target_id") || 
               <%if((((obj.fnNativeInterface === "ACELITE-E") || (obj.fnNativeInterface === "ACE-LITE")) && (obj.DutInfo.cmpInfo.nDvmSnpInFlight > 0)) || (obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") || ((obj.fnNativeInterface == "AXI4" || obj.fnNativeInterface == "AXI5") && obj.DutInfo.useCache)) { %>
$test$plusargs("wrong_sysrsp_target_id")  || <%}%>  
               $test$plusargs("wrong_sysreq_target_id") ||
               $test$plusargs("wrong_DtwDbg_rsp_target_id");
    endfunction : isTargetIdErrorTest

    function bit isSyscoErrorTest();
        return $test$plusargs("attach_sys_rsp_error") || 
               $test$plusargs("detach_sys_rsp_error") || 
               $test$plusargs("enable_attach_error")  || 
               $test$plusargs("enable_detach_error");
    endfunction : isSyscoErrorTest

   function bit isTimeoutErrro();
       return $test$plusargs("CMDrsp_time_out_test")
	          || $test$plusargs("STRreq_time_out_test")
                  ||  $test$plusargs("dvm_time_out_test")  
                  ||  $test$plusargs("enable_ev_timeout")  
                  ||  $test$plusargs("event_sys_rsp_timeout_error") 
                <%if(obj.DutInfo.useCache){%> 
                    || $test$plusargs("CCP_eviction_time_out_test")
                <%}%>
                <%if((((obj.fnNativeInterface === "ACELITE-E") || (obj.fnNativeInterface === "ACE-LITE")) && (obj.DutInfo.cmpInfo.nDvmSnpInFlight > 0)) || (obj.fnNativeInterface == "ACE" || obj.fnNativeInterface == "ACE5") || ((obj.fnNativeInterface == "AXI4" || obj.fnNativeInterface == "AXI5") && obj.DutInfo.useCache)) { %>
                    || $test$plusargs("timeout_attach_sys_rsp_error")
                    || $test$plusargs("timeout_detach_sys_rsp_error")
	            <%}%>;
   endfunction
    

    function void final_phase(uvm_phase phase);
        uvm_report_server svr;
        `uvm_info("final_phase", "Entered...",UVM_FULL)
        super.final_phase(phase);
        `uvm_info("final_phase", "Exiting...", UVM_FULL)
    endfunction: final_phase

    function void run_report(uvm_phase phase);

    endfunction : run_report
endclass


   function void base_test::configure_axi_agent(ref axi_agent_config cfg[<%=obj.DutInfo.nNativeInterfacePorts%>]);
    	<%for(var i = 0; i < obj.DutInfo.nNativeInterfacePorts; i++){%>
            cfg[<%=i%>].wt_ace_rdnosnp                         = wt_ace_rdnosnp;
            cfg[<%=i%>].wt_ace_rdonce                          = wt_ace_rdonce;
            cfg[<%=i%>].wt_ace_rdshrd                          = wt_ace_rdshrd;
            cfg[<%=i%>].wt_ace_rdcln                           = wt_ace_rdcln;
            cfg[<%=i%>].wt_ace_rdnotshrddty                    = wt_ace_rdnotshrddty;
            cfg[<%=i%>].wt_ace_rdunq                           = wt_ace_rdunq;
            cfg[<%=i%>].wt_ace_clnunq                          = wt_ace_clnunq;
            cfg[<%=i%>].wt_ace_mkunq                           = wt_ace_mkunq;
            cfg[<%=i%>].wt_ace_dvm_msg                         = wt_ace_dvm_msg;
            cfg[<%=i%>].wt_ace_dvm_sync                        = wt_ace_dvm_sync;
            cfg[<%=i%>].wt_ace_clnshrd                         = wt_ace_clnshrd;
            cfg[<%=i%>].wt_ace_clninvl                         = wt_ace_clninvl;
            cfg[<%=i%>].wt_ace_mkinvl                          = wt_ace_mkinvl;
            cfg[<%=i%>].wt_ace_rd_bar                          = wt_ace_rd_bar;
            cfg[<%=i%>].wt_ace_wrnosnp                         = wt_ace_wrnosnp;
            cfg[<%=i%>].wt_ace_wrunq                           = wt_ace_wrunq;
            cfg[<%=i%>].wt_ace_wrlnunq                         = wt_ace_wrlnunq;
            cfg[<%=i%>].wt_ace_wrcln                           = wt_ace_wrcln;
            cfg[<%=i%>].wt_ace_wrbk                            = wt_ace_wrbk;
            cfg[<%=i%>].wt_ace_evct                            = wt_ace_evct;
            cfg[<%=i%>].wt_ace_wrevct                          = wt_ace_wrevct;
            cfg[<%=i%>].wt_ace_wr_bar                          = wt_ace_wr_bar;
            cfg[<%=i%>].wt_ace_atm_str                         = wt_ace_atm_str;
            cfg[<%=i%>].wt_ace_atm_ld                          = wt_ace_atm_ld;
            cfg[<%=i%>].wt_ace_atm_swap                        = wt_ace_atm_swap;
            cfg[<%=i%>].wt_ace_atm_comp                        = wt_ace_atm_comp;
            cfg[<%=i%>].wt_ace_ptl_stash                       = wt_ace_ptl_stash;
            cfg[<%=i%>].wt_ace_full_stash                      = wt_ace_full_stash;
            cfg[<%=i%>].wt_ace_shared_stash                    = wt_ace_shared_stash;
            cfg[<%=i%>].wt_ace_unq_stash                       = wt_ace_unq_stash;
            cfg[<%=i%>].wt_ace_stash_trans                     = wt_ace_stash_trans;
            cfg[<%=i%>].wt_ace_rd_cln_invld                    = wt_ace_rd_cln_invld;
            cfg[<%=i%>].wt_ace_rd_make_invld                   = wt_ace_rd_make_invld;     
            cfg[<%=i%>].wt_ace_clnshrd_pers                    = wt_ace_clnshrd_pers;
            cfg[<%=i%>].k_num_read_req                         = k_num_read_req;
            cfg[<%=i%>].k_num_eviction_req                         = k_num_eviction_req;
            cfg[<%=i%>].k_num_write_req                        = k_num_write_req;
            cfg[<%=i%>].num_sets                               = num_sets;
            cfg[<%=i%>].k_num_snp                              = k_num_snp;
            cfg[<%=i%>].prob_ace_snp_resp_error                = prob_ace_snp_resp_error;
            cfg[<%=i%>].k_is_bfm_delay_changing                = k_is_bfm_delay_changing;
            cfg[<%=i%>].k_bfm_delay_changing_time              = k_bfm_delay_changing_time;
            cfg[<%=i%>].k_ace_master_read_addr_chnl_delay_min.set_value(k_ace_master_read_addr_chnl_delay_min);
            cfg[<%=i%>].k_ace_master_read_addr_chnl_delay_max.set_value(k_ace_master_read_addr_chnl_delay_max);
            cfg[<%=i%>].k_ace_master_read_addr_chnl_burst_pct.set_value(k_ace_master_read_addr_chnl_burst_pct);
            cfg[<%=i%>].k_ace_master_read_data_chnl_delay_min.set_value(k_ace_master_read_data_chnl_delay_min);
            cfg[<%=i%>].k_ace_master_read_data_chnl_delay_max.set_value(k_ace_master_read_data_chnl_delay_max);
            cfg[<%=i%>].k_ace_master_read_data_chnl_burst_pct.set_value(k_ace_master_read_data_chnl_burst_pct);
            cfg[<%=i%>].k_ace_master_write_addr_chnl_delay_min.set_value(k_ace_master_write_addr_chnl_delay_min);
            cfg[<%=i%>].k_ace_master_write_addr_chnl_delay_max.set_value(k_ace_master_write_addr_chnl_delay_max);
            cfg[<%=i%>].k_ace_master_write_addr_chnl_burst_pct.set_value(k_ace_master_write_addr_chnl_burst_pct);
            cfg[<%=i%>].k_ace_master_write_data_chnl_delay_min.set_value(k_ace_master_write_data_chnl_delay_min);
            cfg[<%=i%>].k_ace_master_write_data_chnl_delay_max.set_value(k_ace_master_write_data_chnl_delay_max);
            cfg[<%=i%>].k_ace_master_write_data_chnl_burst_pct.set_value(k_ace_master_write_data_chnl_burst_pct);
            cfg[<%=i%>].k_ace_master_write_resp_chnl_delay_min.set_value(k_ace_master_write_resp_chnl_delay_min);
            cfg[<%=i%>].k_ace_master_write_resp_chnl_delay_max.set_value(k_ace_master_write_resp_chnl_delay_max);
            cfg[<%=i%>].k_ace_master_write_resp_chnl_burst_pct.set_value(k_ace_master_write_resp_chnl_burst_pct);
        <%}%>
        <% if (computedAxiInt.params.eAc) {%>
            cfg[0].k_ace_master_snoop_addr_chnl_delay_min.set_value(k_ace_master_snoop_addr_chnl_delay_min);
            cfg[0].k_ace_master_snoop_addr_chnl_delay_max.set_value(k_ace_master_snoop_addr_chnl_delay_max);
            cfg[0].k_ace_master_snoop_addr_chnl_burst_pct.set_value(k_ace_master_snoop_addr_chnl_burst_pct);
            cfg[0].k_ace_master_snoop_resp_chnl_delay_min.set_value(k_ace_master_snoop_resp_chnl_delay_min);
            cfg[0].k_ace_master_snoop_resp_chnl_delay_max.set_value(k_ace_master_snoop_resp_chnl_delay_max);
            cfg[0].k_ace_master_snoop_resp_chnl_burst_pct.set_value(k_ace_master_snoop_resp_chnl_burst_pct);
            cfg[0].k_ace_master_snoop_data_chnl_delay_min.set_value(k_ace_master_snoop_data_chnl_delay_min);
            cfg[0].k_ace_master_snoop_data_chnl_delay_max.set_value(k_ace_master_snoop_data_chnl_delay_max);
            cfg[0].k_ace_master_snoop_data_chnl_burst_pct.set_value(k_ace_master_snoop_data_chnl_burst_pct);
        <%}%>
        if($test$plusargs("no_native_intf_delay")) begin
    	    <%for(var i = 0; i < obj.DutInfo.nNativeInterfacePorts; i++){%>
                cfg[<%=i%>].k_ace_master_write_addr_chnl_delay_min.set_value(0);
                cfg[<%=i%>].k_ace_master_write_addr_chnl_delay_max.set_value(0);
                cfg[<%=i%>].k_ace_master_write_addr_chnl_burst_pct.set_value(100);
                cfg[<%=i%>].k_ace_master_write_data_chnl_delay_min.set_value(0);
                cfg[<%=i%>].k_ace_master_write_data_chnl_delay_max.set_value(0);
                cfg[<%=i%>].k_ace_master_write_data_chnl_burst_pct.set_value(100);
                cfg[<%=i%>].k_ace_master_write_resp_chnl_delay_min.set_value(0);
                cfg[<%=i%>].k_ace_master_write_resp_chnl_delay_max.set_value(0);
                cfg[<%=i%>].k_ace_master_write_resp_chnl_burst_pct.set_value(100);
                cfg[<%=i%>].k_ace_master_read_addr_chnl_delay_min.set_value(0);
                cfg[<%=i%>].k_ace_master_read_addr_chnl_delay_max.set_value(0);
                cfg[<%=i%>].k_ace_master_read_addr_chnl_burst_pct.set_value(100);
                cfg[<%=i%>].k_ace_master_read_data_chnl_delay_min.set_value(0);
                cfg[<%=i%>].k_ace_master_read_data_chnl_delay_max.set_value(0);
                cfg[<%=i%>].k_ace_master_read_data_chnl_burst_pct.set_value(100);
            <%}%>
            
            <%if(computedAxiInt.params.eAc){%>
                cfg[0].k_ace_master_snoop_addr_chnl_delay_min.set_value(0);
                cfg[0].k_ace_master_snoop_addr_chnl_delay_max.set_value(0);
                cfg[0].k_ace_master_snoop_addr_chnl_burst_pct.set_value(100);
                cfg[0].k_ace_master_snoop_resp_chnl_delay_min.set_value(0);
                cfg[0].k_ace_master_snoop_resp_chnl_delay_max.set_value(0);
                cfg[0].k_ace_master_snoop_resp_chnl_burst_pct.set_value(100);
                cfg[0].k_ace_master_snoop_data_chnl_delay_min.set_value(0);
                cfg[0].k_ace_master_snoop_data_chnl_delay_max.set_value(0);
                cfg[0].k_ace_master_snoop_data_chnl_burst_pct.set_value(100);
            <%}%>
        end

        if ($test$plusargs("ace_stress_test")) begin
    	    <%for(var i = 0; i < obj.DutInfo.nNativeInterfacePorts; i++){%>
                cfg[<%=i%>].k_ace_master_read_addr_chnl_delay_min.set_value(0);
                cfg[<%=i%>].k_ace_master_read_addr_chnl_delay_max.set_value(0);
                cfg[<%=i%>].k_ace_master_read_addr_chnl_burst_pct.set_value(100);
                cfg[<%=i%>].k_ace_master_write_addr_chnl_delay_min.set_value(0);
                cfg[<%=i%>].k_ace_master_write_addr_chnl_delay_max.set_value(0);
                cfg[<%=i%>].k_ace_master_write_addr_chnl_burst_pct.set_value(100);
                cfg[<%=i%>].k_ace_master_write_data_chnl_delay_min.set_value(0);
                cfg[<%=i%>].k_ace_master_write_data_chnl_delay_max.set_value(0);
                cfg[<%=i%>].k_ace_master_write_data_chnl_burst_pct.set_value(100);
                cfg[<%=i%>].k_ace_master_snoop_resp_chnl_delay_min.set_value(0);
                cfg[<%=i%>].k_ace_master_snoop_resp_chnl_delay_max.set_value(0);
                cfg[<%=i%>].k_ace_master_snoop_resp_chnl_burst_pct.set_value(100);
                cfg[<%=i%>].k_ace_master_snoop_data_chnl_delay_min.set_value(0);
                cfg[<%=i%>].k_ace_master_snoop_data_chnl_delay_max.set_value(0);
                cfg[<%=i%>].k_ace_master_snoop_data_chnl_burst_pct.set_value(100);
            <%}%>
        end


            <%for(var i = 0; i < obj.DutInfo.nNativeInterfacePorts; i++){%>
                // Setting the AXI master agent to be active
                m_axi_master_cfg[<%=i%>].m_intf_type  = IS_ACE_INTF;
                m_axi_master_cfg[<%=i%>].delay_export = 1;
                `ifndef USE_VIP_SNPS  
                    m_axi_master_cfg[<%=i%>].active = UVM_ACTIVE;
                    m_axi_slave_cfg[<%=i%>].active  = UVM_ACTIVE;
                `elsif
                    m_axi_master_cfg[<%=i%>].active = UVM_PASSIVE;
                    m_axi_slave_cfg[<%=i%>].active  = UVM_ACTIVE;
                `endif

                <%if(obj.SFI_BFM_TEST_MODE){%>
                    m_axi_master_cfg[<%=i%>].active = UVM_PASSIVE;
                    m_axi_slave_cfg[<%=i%>].active  = UVM_PASSIVE;
                <%}%>
                m_axi_slave_cfg[<%=i%>].m_intf_type  = IS_AXI4_INTF;
                m_axi_slave_cfg[<%=i%>].delay_export = 1;
            <%}%>
            <%if(!obj.SFI_BFM_TEST_MODE){%>
                <%for(var i = 0; i < obj.DutInfo.nNativeInterfacePorts; i++){%>
                    if(!uvm_config_db#(virtual <%=obj.BlockId + '_axi_if'%>)::get(.cntxt( this ),
                        .inst_name( "" ),
                        .field_name( "axi_master_vif_<%=i%>" ),
                        .value( m_axi_master_cfg[<%=i%>].m_vif ))) begin
                            `uvm_error("aiu_test", "axi_master_vif_<%=i%> not found")
                    end
                    <%if(( obj.DutInfo.useCache)){%> 
                        if (!uvm_config_db#(virtual <%=obj.BlockId%>_ccp_if)::get(.cntxt( this ),
                                                                .inst_name( "*" ),
                                                                .field_name("ccp<%=obj.Id + '_vif_' + i%>"),
                                                                .value( m_ccp_cfg[<%=i%>].m_vif ))) begin
                            `uvm_error("ncbu_base_test", "ccp_vif not found")
                        end

                    <%}%>
                    <%}%>
                <%}%>
      endfunction




`endif
   /*
    <%=JSON.stringify(obj,null,' ')%>
    */
