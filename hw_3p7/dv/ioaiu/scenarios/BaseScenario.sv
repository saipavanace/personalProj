class BaseScenario extends uvm_object

<%
let computedAxiInt;
let axiIntIsArray = false;
if(Array.isArray(obj.DutInfo.interfaces.axiInt)){
    computedAxiInt = obj.DutInfo.interfaces.axiInt[0];
    axiIntIsArray = true;
}else{
    computedAxiInt = obj.DutInfo.interfaces.axiInt;
}
%>

`ifndef BASE_TEST 
`define BASE_TEST 

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
        svt_axi_system_env   axi_system_env;
        ace_env_config cfg;
        svt_axi_cache snps_cache;
    `endif
  
    // <%if((obj.DutInfo.useCache)){%>                   
    //     ccp_agent_config  m_ccp_cfg;
    // <%}%>
    <%if(obj.INHOUSE_APB_VIP){%>
        apb_agent_config  m_apb_cfg;
    <%}%>

    //instantiate the AIU env config object
    //ioaiu_env_config m_env_cfg;

    //instantiate the SMI config object
    smi_agent_config m_smi_agent_cfg;
    <%if(obj.NO_SMI === undefined){%>   
        <%var NSMIIFTX = obj.DutInfo.nSmiTx;
        for(var i = 0; i < NSMIIFTX; i++){%>
            smi_port_config m_smi<%=i%>_tx_port_config;
        <%}%>
        <%var NSMIIFRX = obj.DutInfo.nSmiRx;
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

    <%if(obj.NO_SYS_BFM === undefined){%>
        system_bfm_seq m_system_bfm_seq;
    <%}%>
    uvm_cmdline_processor clp = uvm_cmdline_processor::get_inst();
    uvm_event_pool ev_pool = uvm_event_pool::get_global_pool();
    uvm_event ev = ev_pool.get("ev");

    // control knobs
    int k_prob_single_bit_tag_error           = 100;
    int k_prob_double_bit_tag_error           = 100;
    int k_prob_single_bit_data_error          = 100;
    int k_prob_double_bit_data_error          = 100;
    int k_timeout                             = 20000000;
    int k_num_addr                            = 1;
    int k_num_read_req                        = 100;
    int k_num_write_req                       = 100;
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
    `ifdef UPDREQ_TAG_TEST  
        int wt_cmd_rd_cpy                         = 0;
        int wt_cmd_rd_cln                         = 0;
        int wt_cmd_rd_vld                         = 0;
        int wt_cmd_rd_unq                         = 80;
    `else
        int wt_cmd_rd_cpy                         = 5;
        int wt_cmd_rd_cln                         = 10;
        int wt_cmd_rd_vld                         = 20;
        int wt_cmd_rd_unq                         = 20;
    `endif
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
    <%if((obj.DutInfo.fnNativeInterface == "ACE-LITE") || (obj.DutInfo.fnNativeInterface == "ACELITE-E")){%>
        int wt_ace_rdshrd                         = 0;
        int wt_ace_rdcln                          = 0;
        int wt_ace_rdnotshrddty                   = 0;
        int wt_ace_rdunq                          = 0;
        int wt_ace_clnunq                         = 0;
        int wt_ace_mkunq                          = 0;
    <%}else{%>    
        int wt_ace_rdshrd                         = -1;
        int wt_ace_rdcln                          = -1;
        int wt_ace_rdnotshrddty                   = -1;
        int wt_ace_rdunq                          = -1;
        // FIXME: Fix below weights to be non-zero
        int wt_ace_clnunq                         = -1;
        int wt_ace_mkunq                          = -1;
    <%}%>      
    int wt_ace_dvm_msg                        = -1;
    int wt_ace_dvm_sync                       = -1;
    int wt_ace_clnshrd                        = -1;
    int wt_ace_clninvl                        = -1;
    int wt_ace_mkinvl                         = -1;
    int wt_ace_rd_bar                         = -1;
    int wt_ace_wrnosnp                        = -1;
    int wt_ace_wrunq                          = -1;
    int wt_ace_wrlnunq                        = -1;
    int wt_ace_wrcln                          = -1;
    int wt_ace_wrbk                           = -1;
    int wt_ace_wrevct                         = -1;
    int wt_ace_evct                           = -1;
    int wt_ace_wr_bar                         = -1;

    <%if(((obj.DutInfo.fnNativeInterface == "ACE-LITE") || (obj.DutInfo.fnNativeInterface == "ACELITE-E")) && !computedAxiInt.params.eAc){%>
        int k_num_snp                             = 0;
    <%}else{%>    
        int k_num_snp                             = 20;
    <%}%>
    <%if((obj.DutInfo.cmpInfo.nDvmMsgInFlight > 0) ||
         (obj.DutInfo.cmpInfo.nDvmSnpInFlight > 0)){%>
        int k_snp_dvm_msg_not_sync = 100;
    <%}%>
    <%if(obj.DutInfo.fnNativeInterface == "ACELITE-E"){%>
        int wt_ace_atm_str                        = -1;
        int wt_ace_atm_ld                         = -1;
        int wt_ace_atm_swap                       = -1;
        int wt_ace_atm_comp                       = -1;
        int wt_ace_rd_cln_invld                   = -1;
        int wt_ace_rd_make_invld                  = -1;
        int wt_ace_clnshrd_pers                   = -1;
        int wt_ace_ptl_stash                      = -1;
        int wt_ace_full_stash                     = -1;
        int wt_ace_shared_stash                   = -1;
        int wt_ace_unq_stash                      = -1;
        int wt_ace_stash_trans                    = -1;
    <%}else{%>
        int wt_ace_atm_str                        = 0;
        int wt_ace_atm_ld                         = 0;
        int wt_ace_atm_swap                       = 0;
        int wt_ace_atm_comp                       = 0;
        int wt_ace_rd_cln_invld                   = 0;
        int wt_ace_rd_make_invld                  = 0;
        int wt_ace_clnshrd_pers                   = 0;
        int wt_ace_ptl_stash                      = 0;
        int wt_ace_full_stash                     = 0;
        int wt_ace_shared_stash                   = 0;
        int wt_ace_unq_stash                      = 0;
        int wt_ace_stash_trans                    = 0;
    <%}%>
    int wt_snp_inv                            = 10;
    int wt_snp_cln_dtr                        = 10;
    int wt_snp_inv_stsh                       = 10;
    int wt_snp_unq_stsh                       = 10;
    int wt_snp_stsh_sh                        = 10;
    int wt_snp_stsh_unq                       = 10;
    int wt_snp_vld_dtr                        = 10;
    int wt_snp_inv_dtr                        = 10;
    int wt_snp_cln_dtw                        = 10;
    int wt_snp_inv_dtw                        = 10;
    int wt_snp_nitc                           = 10;
    int wt_snp_nitcci                         = 10;
    int wt_snp_nitcmi                         = 10;
    int wt_snp_nosdint                        = 10;
    int wt_snp_dvm_msg                        = 10;
    int wt_snp_random_addr                    = 10;
    int wt_snp_stash_addr                     = 10;
    int wt_snp_prev_addr                      = 50;
    int wt_snp_cmd_req_addr                   = 50;
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
    event e_tb_clk;
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
    
    bit en_or_chk = $urandom_range(0,1);//CONC-5371
    bit dvm_resp_order = $urandom_range(0,1);
    randc ace_command_types_enum_t ioaiu_opcode_inst;
    TRIG_TCTRLR_t    tctrlr[<%=obj.DutInfo.nTraceRegisters%>];
    TRIG_TBALR_t     tbalr[<%=obj.DutInfo.nTraceRegisters%>];
    TRIG_TBAHR_t     tbahr[<%=obj.DutInfo.nTraceRegisters%>];
    TRIG_TOPCR0_t    topcr0[<%=obj.DutInfo.nTraceRegisters%>];
    TRIG_TOPCR1_t    topcr1[<%=obj.DutInfo.nTraceRegisters%>];
    TRIG_TUBR_t      tubr[<%=obj.DutInfo.nTraceRegisters%>];
    TRIG_TUBMR_t     tubmr[<%=obj.DutInfo.nTraceRegisters%>];

    virtual <%=obj.BlockId%>_probe_if u_csr_probe_vif;

    `uvm_component_utils_begin(base_test)
        `uvm_field_int(k_timeout                             ,UVM_DEC);
        `uvm_field_int(k_num_addr                            ,UVM_DEC);
        `uvm_field_int(k_num_read_req                        ,UVM_DEC);
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
        `uvm_field_int(wt_cmd_rd_cpy                         ,UVM_DEC);
        `uvm_field_int(wt_cmd_rd_cln                         ,UVM_DEC);
        `uvm_field_int(wt_cmd_rd_vld                         ,UVM_DEC);
        `uvm_field_int(wt_cmd_rd_unq                         ,UVM_DEC);
        `uvm_field_int(wt_cmd_cln_unq                        ,UVM_DEC);
        `uvm_field_int(wt_cmd_cln_vld                        ,UVM_DEC);
        `uvm_field_int(wt_cmd_cln_inv                        ,UVM_DEC);
        `uvm_field_int(wt_cmd_wr_unq_ptl                     ,UVM_DEC);
        `uvm_field_int(wt_cmd_wr_unq_full                    ,UVM_DEC);
        `uvm_field_int(wt_cmd_upd_inv                        ,UVM_DEC);
        `uvm_field_int(wt_cmd_upd_vld                        ,UVM_DEC);
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

    function new(string name = "base_test", uvm_component parent=null);
        super.new(name,parent);
        gen_no_non_coh_traffic = ($test$plusargs("hit_streaming_strreqs") || ($urandom_range(0,100) < 15));
        gen_no_delay_traffic   = ($test$plusargs("hit_streaming_strreqs") || (($urandom_range(0,100) < 15) && !$test$plusargs("inject_ttdebug")) || $test$plusargs("no_bfm_delays") || $test$plusargs("read_bw_test") || $test$plusargs("write_bw_test") || $test$plusargs("snoop_bw_test"));
        m_addr_mgr = addr_trans_mgr::get_instance();
        m_addr_mgr.gen_memory_map();
    endfunction: new

    virtual function void build_phase(uvm_phase phase);
        string arg_value;
        `uvm_info("build_phase", "Entered...", UVM_LOW)

        super.build_phase(phase);
        <%if(obj.NO_SYS_BFM === undefined) { %>
            m_system_bfm_seq = system_bfm_seq::type_id::create("m_system_bfm_seq");
        <%}%>
        //env = ioaiu_env::type_id::create("env", this);
        mp_env = ioaiu_multiport_env::type_id::create("mp_env", this);
        `ifdef USE_VIP_SNPS  
            axi_system_env = svt_axi_system_env::type_id::create("axi_system_env", this);
            if (cfg == null) begin
                cfg = ace_env_config::type_id::create("cfg");
            end
            cfg.m_addr_mgr = m_addr_mgr;
            cfg.set_ace_config();
            cfg.set_ace_domains();
            set_type_override_by_type (svt_axi_master_transaction::get_type(), ioaiu_axi_master_transaction::get_type(),1);
            set_inst_override_by_type ({get_full_name, ".","axi_system_env.master[0].snoop_sequencer.*"},svt_axi_master_snoop_transaction::get_type(), ioaiu_axi_master_snoop_transaction::get_type());
            uvm_config_db#(svt_axi_system_configuration)::set(this, "axi_system_env", "cfg", cfg);
        `endif
        //m_env_cfg                       = ioaiu_env_config::type_id::create("m_env_cfg", this);
        // m_ioaiu_vseqr                   = axi_virtual_sequencer::type_id::create("m_ioaiu_vseqr", this);		
        // FIXME : Move lines below to mp_env once everything is stable
        <%for(var i = 0; i < obj.DutInfo.nNativeInterfacePorts; i++){%>
            mp_env.m_env_cfg[<%=i%>].m_q_chnl_agent_cfg    = q_chnl_agent_config::type_id::create("m_q_chnl_agent_config",  this);
        <%}%>

        <%for(var i = 0; i < obj.DutInfo.nNativeInterfacePorts; i++){%>
            if(!uvm_config_db#(virtual <%=obj.BlockId%>_q_chnl_if)::get(.cntxt      ( this          ),
                                                                        .inst_name  ( ""            ),
                                                                        .field_name ( "m_q_chnl_if" ),
                                                                        .value      ( mp_env.m_env_cfg[<%=i%>].m_q_chnl_agent_cfg.m_vif ))) begin
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
            <%var NSMIIFTX = obj.DutInfo.nSmiRx;
            for(var i = 0; i < NSMIIFTX; i++) { %>
                m_smi<%=i%>_tx_port_config = smi_port_config::type_id::create("m_smi<%=i%>_tx_port_config",this); ;
                uvm_config_db#(virtual <%=obj.BlockId%>_smi_if)::get(.cntxt     ( uvm_root::get() ),
                                                                     .inst_name ( "" ),
                                                                     .field_name( "m_smi<%=i%>_tx_port_if" ),
                                                                     .value     ( m_smi<%=i%>_tx_port_config.m_vif));
                m_smi_agent_cfg.m_smi<%=i%>_tx_port_config = m_smi<%=i%>_tx_port_config;
            <%}%>
            <% var NSMIIFRX = obj.DutInfo.nSmiTx;
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
            if (!uvm_config_db#(event)::get(.cntxt(uvm_root::get()), 
                                            .inst_name ( "" ), 
                                            .field_name( "e_tb_clk" ),
                                            .value(e_tb_clk))) begin
            end
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
            wt_ace_dvm_msg      = 0;
            wt_ace_dvm_sync     = 0;
            wt_ace_stash_trans  = 0;
            wt_snp_cln_dtr      = 0;
            wt_snp_inv_stsh     = 0;
            wt_snp_unq_stsh     = 0;
            wt_snp_stsh_sh      = 0;
            wt_snp_stsh_unq     = 0;
            wt_snp_vld_dtr      = 0;
            wt_snp_inv_dtr      = 0;
            wt_snp_cln_dtw      = 0;
            wt_snp_inv_dtw      = 0;
            wt_snp_nitc         = 0;
            wt_snp_nitcci       = 0;
            wt_snp_nitcmi       = 0;
            wt_snp_nosdint      = 0;
            wt_snp_dvm_msg      = 0;
            k_num_snp           = 0;
        end
        if (clp.get_arg_value("+wt_cmd_rd_cpy=", arg_value)) begin
            wt_cmd_rd_cpy = arg_value.atoi();
        end
        else begin
            wt_cmd_rd_cpy = (wt_cmd_rd_cpy == -1) ? $urandom_range(1,100) : wt_cmd_rd_cpy;
        end
        if (clp.get_arg_value("+wt_cmd_rd_cln=", arg_value)) begin
            wt_cmd_rd_cln = arg_value.atoi();
        end
        else begin
            wt_cmd_rd_cln = (wt_cmd_rd_cln == -1) ? $urandom_range(1,100) : wt_cmd_rd_cln;
        end
        if (clp.get_arg_value("+wt_cmd_rd_vld=", arg_value)) begin
            wt_cmd_rd_vld = arg_value.atoi();
        end
        else begin
            wt_cmd_rd_vld = (wt_cmd_rd_cpy == -1) ? $urandom_range(1,100) : wt_cmd_rd_cpy;
        end
        if (clp.get_arg_value("+wt_cmd_rd_unq=", arg_value)) begin
            wt_cmd_rd_unq = arg_value.atoi();
        end
        else begin
            wt_cmd_rd_unq = (wt_cmd_rd_unq == -1) ? $urandom_range(1,100) : wt_cmd_rd_unq;
        end
        if (clp.get_arg_value("+wt_cmd_cln_unq=", arg_value)) begin
            wt_cmd_cln_unq = arg_value.atoi();
        end
        else begin
            wt_cmd_cln_unq = (wt_cmd_cln_unq == -1) ? $urandom_range(1,100) : wt_cmd_cln_unq;
        end
        if (clp.get_arg_value("+wt_cmd_cln_vld=", arg_value)) begin
            wt_cmd_cln_vld = arg_value.atoi();
        end
        else begin
            wt_cmd_cln_vld = (wt_cmd_cln_vld == -1) ? $urandom_range(1,100) : wt_cmd_cln_vld;
        end
        if (clp.get_arg_value("+wt_cmd_cln_inv=", arg_value)) begin
            wt_cmd_cln_inv = arg_value.atoi();
        end
        else begin
            wt_cmd_cln_inv = (wt_cmd_cln_inv == -1) ? $urandom_range(1,100) : wt_cmd_cln_inv;
        end
        if (clp.get_arg_value("+wt_cmd_wr_unq_ptl=", arg_value)) begin
            wt_cmd_wr_unq_ptl = arg_value.atoi();
        end
        else begin
            wt_cmd_wr_unq_ptl = (wt_cmd_wr_unq_ptl == -1) ? $urandom_range(1,100) : wt_cmd_wr_unq_ptl;
        end
        if (clp.get_arg_value("+wt_cmd_wr_unq_full=", arg_value)) begin
            wt_cmd_wr_unq_full = arg_value.atoi();
        end
        else begin
            wt_cmd_wr_unq_full = (wt_cmd_wr_unq_full == -1) ? $urandom_range(1,100) : wt_cmd_wr_unq_full;
        end
        if (clp.get_arg_value("+wt_cmd_upd_inv=", arg_value)) begin
            wt_cmd_upd_inv = arg_value.atoi();
        end
        else begin
            wt_cmd_upd_inv = (wt_cmd_upd_inv == -1) ? $urandom_range(1,100) : wt_cmd_upd_inv;
        end
        if (clp.get_arg_value("+wt_cmd_upd_vld=", arg_value)) begin
            wt_cmd_upd_vld = arg_value.atoi();
        end
        else begin
            wt_cmd_upd_vld = (wt_cmd_upd_vld == -1) ? $urandom_range(1,100) : wt_cmd_upd_vld;
        end
        if (clp.get_arg_value("+k_timeout=", arg_value)) begin
            k_timeout = arg_value.atoi();
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
        <%if(!((obj.DutInfo.fnNativeInterface == "AXI4")&&(obj.DutInfo.fnNativeInterface == "AXI5"))) { %>    
            if (clp.get_arg_value("+wt_ace_rdnosnp=", arg_value)) begin
                wt_ace_rdnosnp = arg_value.atoi();
            end else begin
                if(gen_no_non_coh_traffic) begin
                    wt_ace_rdnosnp = 0;
                end else begin
                    wt_ace_rdnosnp = (wt_ace_rdnosnp == -1 ) ? $urandom_range(1,10) : wt_ace_rdnosnp;
                end
            end
        <%}else{%>
            wt_ace_rdnosnp = 0;
        <%}%>
        if (clp.get_arg_value("+wt_ace_rdonce=", arg_value)) begin
            wt_ace_rdonce = arg_value.atoi();
        end        
        else begin
            wt_ace_rdonce = (wt_ace_rdonce == -1) ? $urandom_range(1,100) : wt_ace_rdonce;
        end
        <%if(obj.DutInfo.fnNativeInterface == "ACE"){%>    
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
        <%}%> 
        if (clp.get_arg_value("+wt_ace_dvm_sync=", arg_value)) begin
            wt_ace_dvm_sync = arg_value.atoi();
        end else begin
            wt_ace_dvm_sync = 0;
        end
        if (clp.get_arg_value("+wt_ace_dvm_msg=", arg_value)) begin
            wt_ace_dvm_msg = arg_value.atoi();
        end else begin
            <%if(obj.isDvmSend) { %>
                    wt_ace_dvm_msg = (wt_ace_dvm_msg == -1) ? $urandom_range(1,100) : wt_ace_dvm_msg;
            <%}else{%>
                    wt_ace_dvm_msg = 0;
            <%}%> 
        end
        
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
        if (clp.get_arg_value("+wt_ace_rd_bar=", arg_value)) begin
            wt_ace_rd_bar = arg_value.atoi();
        end        
        <%if(((obj.DutInfo.fnNativeInterface == "ACE-LITE") || (obj.DutInfo.fnNativeInterface == "ACELITE-E")) && obj.useBarriers == 1) { %>    
            else begin
                randcase
                    10: wt_ace_rd_bar = 0;
                    10: wt_ace_rd_bar = (wt_ace_rd_bar == -1) ? $urandom_range(1,10) : wt_ace_rd_bar;
                    5:  wt_ace_rd_bar = (wt_ace_rd_bar == -1) ? $urandom_range(10,100) : wt_ace_rd_bar;
                endcase
                //wt_ace_rd_bar = 0;
            end
        <%}else{%>    
            else begin
                // Not supported for Concerto V1
                wt_ace_rd_bar = 0;
            end
        <%}%>      
        <%if(!((obj.DutInfo.fnNativeInterface == "AXI4")&&(obj.DutInfo.fnNativeInterface == "AXI5"))) { %>    
            if (clp.get_arg_value("+wt_ace_wrnosnp=", arg_value)) begin
                wt_ace_wrnosnp = arg_value.atoi();
            end        
            else begin
                if (gen_no_non_coh_traffic) begin
                    wt_ace_wrnosnp = 0;
                end
                else begin
                    wt_ace_wrnosnp = $urandom_range(1,10);
                end
            end
        <%}else{ %>
            wt_ace_wrnosnp = 0;
        <%}%>
        if (clp.get_arg_value("+wt_ace_wrunq=", arg_value)) begin
            wt_ace_wrunq = arg_value.atoi();
        end        
        else begin
            wt_ace_wrunq = (wt_ace_wrunq == -1) ? $urandom_range(1,100) : wt_ace_wrunq;
        end
        if (clp.get_arg_value("+wt_ace_wrlnunq=", arg_value)) begin
            wt_ace_wrlnunq = arg_value.atoi();
        end        
        else begin
            wt_ace_wrlnunq = (wt_ace_wrlnunq == -1) ? $urandom_range(1,100) : wt_ace_wrlnunq;
        end
        <%if (obj.DutInfo.fnNativeInterface == "ACELITE-E") { %>   
            if (clp.get_arg_value("+wt_ace_wrunq=", arg_value)) begin
                wt_ace_wrunq = arg_value.atoi();
            end else begin
                wt_ace_wrunq = (wt_ace_wrunq == -1) ? $urandom_range(1,100) : wt_ace_wrunq;
            end
            if(clp.get_arg_value("+wt_ace_wrlnunq=", arg_value)) begin
                wt_ace_wrlnunq = arg_value.atoi();
            end else begin
                wt_ace_wrlnunq = (wt_ace_wrlnunq == -1) ? $urandom_range(1,100) : wt_ace_wrlnunq;
            end
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

            if (clp.get_arg_value("+wt_ace_stash_trans=", arg_value)) begin
                wt_ace_stash_trans = arg_value.atoi();
            end        
            else begin
                wt_ace_stash_trans = (wt_ace_stash_trans == -1) ? $urandom_range(1,100) : wt_ace_stash_trans;
            end
        <%}%>
        <%if(obj.DutInfo.fnNativeInterface == "ACE") { %>    
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
                <% if (obj.useAceUniquePort == 0) { %>    
                    wt_ace_wrevct = 0;
                <%} else { %>    
                    wt_ace_wrevct = (wt_ace_wrevct == -1) ? $urandom_range(1,100) : wt_ace_wrevct;
                <%}%> 
            end
        <%}%> 
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
        if (clp.get_arg_value("+wt_ace_clnshrd_pers=", arg_value)) begin
            wt_ace_clnshrd_pers = arg_value.atoi();
        end        
        else begin
            wt_ace_clnshrd_pers = (wt_ace_clnshrd_pers == -1) ? $urandom_range(1,100) : wt_ace_clnshrd_pers;
        end

        if (clp.get_arg_value("+wt_ace_wr_bar=", arg_value)) begin
            wt_ace_wr_bar = arg_value.atoi();
        end        
        <%if(((obj.DutInfo.fnNativeInterface == "ACE-LITE")  || (obj.DutInfo.fnNativeInterface == "ACELITE-E"))&& obj.useBarriers == 1){%>    
            else begin
                if (wt_ace_rd_bar == 0) begin
                    wt_ace_wr_bar = 0;
                end
                else begin
                    randcase
                        10: wt_ace_wr_bar = (wt_ace_wr_bar == -1) ? $urandom_range(1,10) : wt_ace_wr_bar;
                        5:  wt_ace_wr_bar = (wt_ace_wr_bar == -1) ? $urandom_range(10,100) : wt_ace_wr_bar;
                    endcase
                end
            end
        <%}else { %>    
            else begin
                // Not supported for Concerto V1
                wt_ace_wr_bar = 0;
            end
        <%}%>      
        if (clp.get_arg_value("+wt_illegal_op_addr=", arg_value)) begin
            wt_illegal_op_addr = arg_value.atoi();
        end        
        else begin
            wt_illegal_op_addr = (wt_illegal_op_addr == -1) ? $urandom_range(1,100) : wt_illegal_op_addr;
        end

        <%if(!(((obj.DutInfo.fnNativeInterface == "ACE-LITE") || (obj.DutInfo.fnNativeInterface == "ACELITE-E")) && !computedAxiInt.params.eAc) &&
                ((obj.DutInfo.fnNativeInterface == "ACE") ||
                (obj.DutInfo.useCache) ||
                (obj.DutInfo.cmpInfo.nDvmMsgInFlight > 0) ||
                (obj.DutInfo.cmpInfo.nDvmSnpInFlight > 0))){%>
            if (clp.get_arg_value("+k_num_snoop=", arg_value)) begin
                k_num_snp = arg_value.atoi();
            end
            else begin
                k_num_snp = $urandom_range(150,1000);
            end
        <%}%>

        <%if((obj.DutInfo.cmpInfo.nDvmMsgInFlight > 0) ||
             (obj.DutInfo.cmpInfo.nDvmSnpInFlight > 0)){%>
            if (clp.get_arg_value("+k_snp_dvm_msg_not_sync=", arg_value)) begin
                k_snp_dvm_msg_not_sync = arg_value.atoi();
            end
            else begin
                k_snp_dvm_msg_not_sync = $urandom_range(0,100);
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
            <%if(obj.DutInfo.fnNativeInterface == "ACE"){%> 
                k_num_write_req = $urandom_range(10,200);
            <%}else{%>
                k_num_write_req = $urandom_range(1500,2500);
            <%}%>
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
        if (clp.get_arg_value("+wt_snp_inv=", arg_value)) begin
            wt_snp_inv = arg_value.atoi();
        end        
        else begin
            wt_snp_inv = $urandom_range(1,100);
        end
        if (clp.get_arg_value("+wt_snp_cln_dtr=", arg_value)) begin
            wt_snp_cln_dtr = arg_value.atoi();
        end       
        else begin
            wt_snp_cln_dtr = $urandom_range(1,100);
        end
        if (clp.get_arg_value("+wt_snp_inv_stsh=", arg_value)) begin
            wt_snp_inv_stsh = arg_value.atoi();
        end
        else begin
            wt_snp_inv_stsh = $urandom_range(1,100);
        end
        if (clp.get_arg_value("+wt_snp_unq_stsh=", arg_value)) begin
            wt_snp_unq_stsh = arg_value.atoi();
        end
        else begin
            wt_snp_unq_stsh = $urandom_range(1,100);
        end
        if (clp.get_arg_value("+wt_snp_stsh_sh=", arg_value)) begin
            wt_snp_stsh_sh = arg_value.atoi();
        end
        else begin
            wt_snp_stsh_sh = $urandom_range(1,100);
        end
        if (clp.get_arg_value("+wt_snp_stsh_unq=", arg_value)) begin
            wt_snp_stsh_unq = arg_value.atoi();
        end
        else begin
            wt_snp_stsh_unq = $urandom_range(1,100);
        end
        if (clp.get_arg_value("+wt_snp_vld_dtr=", arg_value)) begin
            wt_snp_vld_dtr = arg_value.atoi();
        end       
        else begin
            wt_snp_vld_dtr = $urandom_range(1,100);
        end
        if (clp.get_arg_value("+wt_snp_inv_dtr=", arg_value)) begin
            wt_snp_inv_dtr = arg_value.atoi();
        end       
        else begin
            wt_snp_inv_dtr = $urandom_range(1,100);
        end
        if (clp.get_arg_value("+wt_snp_cln_dtw=", arg_value)) begin
            wt_snp_cln_dtw = arg_value.atoi();
        end       
        else begin
            wt_snp_cln_dtw = $urandom_range(1,100);
        end
        if (clp.get_arg_value("+wt_snp_inv_dtw=", arg_value)) begin
            wt_snp_inv_dtw = arg_value.atoi();
        end       
        else begin
            wt_snp_inv_dtw = $urandom_range(1,100);
        end
        if (clp.get_arg_value("+wt_snp_nitc=", arg_value)) begin
            wt_snp_nitc = arg_value.atoi();
        end
        else begin
            wt_snp_nitc = $urandom_range(1,100);
        end
        if (clp.get_arg_value("+wt_snp_nitcci=", arg_value)) begin
            wt_snp_nitcci = arg_value.atoi();
        end
        else begin
            wt_snp_nitcci = $urandom_range(1,100);
        end
        if (clp.get_arg_value("+wt_snp_nitcmi=", arg_value)) begin
            wt_snp_nitcmi = arg_value.atoi();
        end
        else begin
            wt_snp_nitcmi = $urandom_range(1,100);
        end
        if (clp.get_arg_value("+wt_snp_nosdint=", arg_value)) begin
            wt_snp_nosdint = arg_value.atoi();
        end
        else begin
            wt_snp_nosdint = $urandom_range(1,100);
        end
        if (clp.get_arg_value("+wt_snp_dvm_msg=", arg_value)) begin
            wt_snp_dvm_msg = arg_value.atoi();
        end
        else begin
            `ifdef USE_VIP_SNPS  
                wt_snp_dvm_msg = 0;
            `elsif
                <%if(!computedAxiInt.params.eAc){%>
                    wt_snp_dvm_msg = 0;
                <%}else{%>
                    wt_snp_dvm_msg = $urandom_range(1,100);
                <%}%>
            `endif
        end

        <%if( obj.DutInfo.useCache){%>
            if (clp.get_arg_value("+wt_snp_random_addr=", arg_value)) begin
                wt_snp_random_addr = arg_value.atoi();
            end
            else begin
                wt_snp_random_addr = $urandom_range(1,50);
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
                wt_snp_random_addr = $urandom_range(1,100);
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
    
        <%if(!((obj.DutInfo.fnNativeInterface == "AXI4")&&(obj.DutInfo.fnNativeInterface == "AXI5"))){%>
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
                    <%if(obj.DutInfo.fnNativeInterface == "AXI4" || obj.DutInfo.fnNativeInterface == "AXI5"){%>
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
                if (clp.get_arg_value("+prob_ace_snp_resp_error=", arg_value)) begin
                    prob_ace_snp_resp_error = arg_value.atoi();
                end
                else begin
                    prob_ace_snp_resp_error = $urandom_range(0,5);
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
                if (clp.get_arg_value("+prob_ace_snp_resp_error=", arg_value)) begin
                    prob_ace_snp_resp_error = arg_value.atoi();
                end
                else begin
                    prob_ace_snp_resp_error = $urandom_range(0,5);
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
                if (clp.get_arg_value("+prob_ace_snp_resp_error=", arg_value)) begin
                    prob_ace_snp_resp_error = arg_value.atoi();
                end
                else begin
                    prob_ace_snp_resp_error = 0;
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
        if ($test$plusargs("power_mgt_tcr_trans_en_test")) begin
            wt_ace_rdonce       = 0;
            wt_ace_rdshrd       = 0;
            wt_ace_rdcln        = 0;
            wt_ace_rdnotshrddty = 0;
            wt_ace_rdunq        = 0;
            wt_ace_clnunq       = 0;
            wt_ace_mkunq        = 0;
            wt_ace_dvm_msg      = 0;
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
            k_num_snp           = 0;
        end
        if ($test$plusargs("read_bw_test")) begin
            wt_ace_rdnosnp      = 0;
            wt_ace_rdonce       = 100;
            wt_ace_rdshrd       = 0;
            wt_ace_rdcln        = 0;
            wt_ace_rdnotshrddty = 0;
            wt_ace_rdunq        = 0;
            wt_ace_clnunq       = 0;
            wt_ace_mkunq        = 0;
            wt_ace_dvm_msg      = 0;
            wt_ace_clnshrd      = 0;
            wt_ace_clninvl      = 0;
            wt_ace_mkinvl       = 0;
            wt_ace_rd_bar       = 0;
            wt_ace_wrnosnp      = 0;
            wt_ace_wrunq        = 0;
            wt_ace_wrlnunq      = 0;
            wt_ace_wrcln        = 0;
            wt_ace_wrbk         = 0;
            wt_ace_wrevct       = 0;
            wt_ace_evct         = 0;
        end
        if ($test$plusargs("read_latency_test")) begin
            wt_ace_rdnosnp      = 0;
            <%if((obj.DutInfo.fnNativeInterface == "ACE-LITE")  || (obj.DutInfo.fnNativeInterface == "ACELITE-E")){%>
                wt_ace_rdonce       = 100;
                wt_ace_rdshrd       = 0;
                wt_dvm_multipart_snp = 0;
                wt_dvm_sync_snp      = 0;
                wt_snp_dvm_msg       = 0;
            <%}else{%>    
                wt_ace_rdonce       = 0;
                wt_ace_rdshrd       = 100;
            <%}%> 
            wt_ace_rdcln        = 0;
            wt_ace_rdnotshrddty = 0;
            wt_ace_rdunq        = 0;
            wt_ace_clnunq       = 0;
            wt_ace_mkunq        = 0;
            wt_ace_dvm_msg      = 0;
            wt_ace_clnshrd      = 0;
            wt_ace_clninvl      = 0;
            wt_ace_mkinvl       = 0;
            wt_ace_rd_bar       = 0;
            wt_ace_wrnosnp      = 0;
            wt_ace_wrunq        = 0;
            wt_ace_wrlnunq      = 0;
            wt_ace_wrcln        = 0;
            wt_ace_wrbk         = 0;
            wt_ace_wrevct       = 0;
            wt_ace_evct         = 0;
        end
        if ($test$plusargs("write_bw_test") || $test$plusargs("wrlnUnq_latency_test")) begin
            wt_ace_rdnosnp      = 0;
            wt_ace_rdonce       = 0;
            wt_ace_rdshrd       = 0;
            wt_ace_rdcln        = 0;
            wt_ace_rdnotshrddty = 0;
            wt_ace_rdunq        = 0;
            wt_ace_clnunq       = 0;
            wt_ace_mkunq        = 0;
            wt_ace_dvm_msg      = 0;
            wt_ace_clnshrd      = 0;
            wt_ace_clninvl      = 0;
            wt_ace_mkinvl       = 0;
            wt_ace_rd_bar       = 0;
            wt_ace_wrnosnp      = 0;
            wt_ace_wrunq        = 0;
            wt_ace_wrlnunq      = 100;
            wt_ace_wrcln        = 0;
            wt_ace_wrbk         = 0;
            wt_ace_wrevct       = 0;
            wt_ace_evct         = 0;
        end
    
        // For Bridge we will only get RDONCE and WRUNQ txns
        <%if(obj.DutInfo.fnNativeInterface == "AXI4" || obj.DutInfo.fnNativeInterface == "AXI5") { %>    
            wt_cmd_rd_cpy                          = 0;
            wt_cmd_rd_cln                          = 0;
            wt_cmd_rd_vld                          = 0;
            wt_cmd_rd_unq                          = 0;
            wt_cmd_cln_unq                         = 0;
            wt_cmd_cln_vld                         = 0;
            wt_cmd_cln_inv                         = 0;
            wt_cmd_wr_unq_ptl                      = 0;
            wt_cmd_wr_unq_full                     = 0;
            wt_cmd_upd_inv                         = 0;
            wt_cmd_upd_vld                         = 0;
            <%if(obj.DutInfo.NcMode){%>
                wt_ace_rdonce                          = 0;
                wt_ace_rdnosnp                         = 100;
            <%}else{%>
                wt_ace_rdonce                          = 100;
                wt_ace_rdnosnp                         = 0;
            <%}%>
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
            <%if(obj.DutInfo.NcMode){%>
                wt_ace_wrnosnp                     = 100;
                wt_ace_wrunq                       = 0;
            <%}else{%>
                wt_ace_wrnosnp                         = 0;
                wt_ace_wrunq                           = 100;
            <%}%>
            wt_ace_wrlnunq                         = 0;
            wt_ace_wrcln                           = 0;
            wt_ace_wrbk                            = 0;
            wt_ace_wrevct                          = 0;
            wt_ace_evct                            = 0;
            wt_ace_wr_bar                          = 0;
        <%}else if(obj.DutInfo.fnNativeInterface == "ACE"){%>
            wt_cmd_rd_cpy                          = 0;
            wt_cmd_rd_cln                          = 0;
            wt_cmd_rd_vld                          = 0;
            wt_cmd_rd_unq                          = 0;
            wt_cmd_cln_unq                         = 0;
            wt_cmd_cln_vld                         = 0;
            wt_cmd_cln_inv                         = 0;
            wt_cmd_wr_unq_ptl                      = 0;
            wt_cmd_wr_unq_full                     = 0;
            wt_cmd_upd_inv                         = 0;
            wt_cmd_upd_vld                         = 0;
            wt_ace_rdnosnp                         = wt_ace_rdnosnp;
            wt_ace_rdonce                          = wt_ace_rdonce;
            wt_ace_rdshrd                          = wt_ace_rdshrd;
            wt_ace_rdcln                           = wt_ace_rdcln;
            wt_ace_rdnotshrddty                    = wt_ace_rdnotshrddty;
            wt_ace_rdunq                           = wt_ace_rdunq;
            wt_ace_clnunq                          = wt_ace_clnunq;
            wt_ace_mkunq                           = wt_ace_mkunq;
            wt_ace_dvm_msg                         = wt_ace_dvm_msg;
            wt_ace_clnshrd                         = wt_ace_clnshrd;
            wt_ace_clninvl                         = wt_ace_clninvl;
            wt_ace_mkinvl                          = wt_ace_mkinvl;
            wt_ace_rd_bar                          = 0;
            wt_ace_wrnosnp                         = wt_ace_wrnosnp;
            wt_ace_wrunq                           = wt_ace_wrunq;
            wt_ace_wrlnunq                         = wt_ace_wrlnunq;
            wt_ace_wrcln                           = wt_ace_wrcln;
            wt_ace_wrbk                            = wt_ace_wrbk;
            wt_ace_wrevct                          = wt_ace_wrevct;
            wt_ace_evct                            = wt_ace_evct;
            wt_ace_wr_bar                          = 0;
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
        <%}%>
        <%if((obj.DutInfo.fnNativeInterface == "ACE") ||
            (obj.DutInfo.useCache) ||
            (computedAxiInt.params.eAc) ||
            (obj.DutInfo.cmpInfo.nDvmMsgInFlight > 0) ||
            (obj.DutInfo.cmpInfo.nDvmSnpInFlight > 0)){%>   
            m_system_bfm_seq.k_num_snp.set_value(k_num_snp);
        <%}%> 
        m_system_bfm_seq.k_num_snp_q_pending.set_value(<%=obj.DutInfo.cmpInfo.nSttCtrlEntries%>);
        if($test$plusargs("snoop_bw_test")) begin
            k_num_read_req      = 0;
            k_num_snp           = 3000;
            wt_snp_inv          = 0;
            wt_snp_cln_dtr      = 0;
            wt_snp_vld_dtr      = 0;
            wt_snp_inv_dtr      = 0;
            wt_snp_cln_dtw      = 100;
            wt_snp_inv_dtw      = 0;
            wt_snp_nitc         = 0;
            wt_snp_dvm_msg      = 0;
            wt_snp_random_addr  = 0;
            wt_snp_prev_addr    = 100;
            wt_snp_cmd_req_addr = 0;
        end
        if ($test$plusargs("ace_bringup")) begin
            m_system_bfm_seq.k_num_snp.set_value(k_num_snp);
            m_system_bfm_seq.wt_snp_cln_dtr.set_value(0); 
            m_system_bfm_seq.wt_snp_inv_stsh.set_value(0);
            m_system_bfm_seq.wt_snp_unq_stsh.set_value(0);
            m_system_bfm_seq.wt_snp_stsh_sh.set_value(0);
            m_system_bfm_seq.wt_snp_stsh_unq.set_value(0);
            m_system_bfm_seq.wt_snp_inv.set_value(wt_snp_inv); 
            m_system_bfm_seq.wt_snp_vld_dtr.set_value(0); 
            m_system_bfm_seq.wt_snp_inv_dtr.set_value(wt_snp_inv_dtr); 
            m_system_bfm_seq.wt_snp_cln_dtw.set_value(0); 
            m_system_bfm_seq.wt_snp_inv_dtw.set_value(wt_snp_inv_dtw); 
            m_system_bfm_seq.wt_snp_nitc.set_value(wt_snp_nitc);
            m_system_bfm_seq.wt_snp_nitcci.set_value(0);
            m_system_bfm_seq.wt_snp_nitcmi.set_value(0);
            m_system_bfm_seq.wt_snp_nosdint.set_value(0);
            m_system_bfm_seq.wt_snp_dvm_msg.set_value(0);
            m_system_bfm_seq.wt_snp_prev_addr.set_value(wt_snp_prev_addr);
            m_system_bfm_seq.wt_snp_cmd_req_addr.set_value(wt_snp_cmd_req_addr);
            m_system_bfm_seq.wt_snp_random_addr.set_value(wt_snp_random_addr);
            m_system_bfm_seq.wt_snp_for_stash_random_addr.set_value(0);
            wt_ace_rdnosnp                         = 100;
            wt_ace_rdonce                          = 100;
            wt_ace_rdshrd                          = 100;
            wt_ace_rdcln                           = 100;
            wt_ace_rdnotshrddty                    = 100;
            wt_ace_rdunq                           = 100;
            wt_ace_clnunq                          = 100;
            wt_ace_mkunq                           = 100;
            wt_ace_dvm_msg                         = 0;
            wt_ace_clnshrd                         = 100;
            wt_ace_clninvl                         = 100;
            wt_ace_mkinvl                          = 100;
            wt_ace_rd_bar                          = 0;
            wt_ace_wrnosnp                         = 100;
            wt_ace_wrunq                           = 100;
            wt_ace_wrlnunq                         = 100;
            wt_ace_wrcln                           = 0;
            wt_ace_wrbk                            = 0;
            wt_ace_wrevct                          = 0;
            wt_ace_evct                            = 0;
            wt_ace_wr_bar                          = 0;
        end
        if ($test$plusargs("dvm_bringup")) begin
            m_system_bfm_seq.k_num_snp.set_value(k_num_snp);
            m_system_bfm_seq.k_snp_dvm_msg_not_sync.set_value(k_snp_dvm_msg_not_sync);
            m_system_bfm_seq.wt_snp_cln_dtr.set_value(0); 
            m_system_bfm_seq.wt_snp_inv_stsh.set_value(0);
            m_system_bfm_seq.wt_snp_unq_stsh.set_value(0);
            m_system_bfm_seq.wt_snp_stsh_sh.set_value(0);
            m_system_bfm_seq.wt_snp_stsh_unq.set_value(0);
            m_system_bfm_seq.wt_snp_inv.set_value(0); 
            m_system_bfm_seq.wt_snp_vld_dtr.set_value(0); 
            m_system_bfm_seq.wt_snp_inv_dtr.set_value(0); 
            m_system_bfm_seq.wt_snp_cln_dtw.set_value(0); 
            m_system_bfm_seq.wt_snp_inv_dtw.set_value(0); 
            m_system_bfm_seq.wt_snp_nitc.set_value(0); 
            m_system_bfm_seq.wt_snp_nitcci.set_value(0); 
            m_system_bfm_seq.wt_snp_nitcmi.set_value(0); 
            m_system_bfm_seq.wt_snp_nosdint.set_value(0);
            m_system_bfm_seq.wt_snp_dvm_msg.set_value(80);
            m_system_bfm_seq.wt_snp_prev_addr.set_value(wt_snp_prev_addr);
            m_system_bfm_seq.wt_snp_cmd_req_addr.set_value(wt_snp_cmd_req_addr);
            m_system_bfm_seq.wt_snp_random_addr.set_value(wt_snp_random_addr);
            m_system_bfm_seq.wt_snp_for_stash_random_addr.set_value(0);
            wt_ace_rdnosnp      = 0;
            wt_ace_rdonce       = 0;
            wt_ace_rdshrd       = 0;
            wt_ace_rdcln        = 0;
            wt_ace_rdnotshrddty = 0;
            wt_ace_rdunq        = 0;
            wt_ace_clnunq       = 0;
            wt_ace_mkunq        = 0;
            wt_ace_dvm_msg      = 1;
            wt_ace_clnshrd      = 0;
            wt_ace_clninvl      = 0;
            wt_ace_mkinvl       = 0;
            wt_ace_rd_bar       = 0;
            wt_ace_wrnosnp      = 0;
            wt_ace_wrunq        = 0;
            wt_ace_wrlnunq      = 0;
            wt_ace_wrcln        = 0;
            wt_ace_wrbk         = 0;
            wt_ace_wrevct       = 0;
            wt_ace_evct         = 0;
        end
        if ($test$plusargs("stash_targ_id_test")) begin
            m_system_bfm_seq.k_num_snp.set_value(k_num_snp);
            m_system_bfm_seq.k_snp_dvm_msg_not_sync.set_value(k_snp_dvm_msg_not_sync);
            m_system_bfm_seq.wt_snp_cln_dtr.set_value(0); 
            m_system_bfm_seq.wt_snp_inv_stsh.set_value(0);
            m_system_bfm_seq.wt_snp_unq_stsh.set_value(0);
            m_system_bfm_seq.wt_snp_stsh_sh.set_value(0);
            m_system_bfm_seq.wt_snp_stsh_unq.set_value(0);
            m_system_bfm_seq.wt_snp_inv.set_value(0); 
            m_system_bfm_seq.wt_snp_vld_dtr.set_value(0); 
            m_system_bfm_seq.wt_snp_inv_dtr.set_value(0); 
            m_system_bfm_seq.wt_snp_cln_dtw.set_value(0); 
            m_system_bfm_seq.wt_snp_inv_dtw.set_value(0); 
            m_system_bfm_seq.wt_snp_nitc.set_value(0); 
            m_system_bfm_seq.wt_snp_nitcci.set_value(0); 
            m_system_bfm_seq.wt_snp_nitcmi.set_value(0); 
            m_system_bfm_seq.wt_snp_nosdint.set_value(0);
            m_system_bfm_seq.wt_snp_dvm_msg.set_value(0);
            m_system_bfm_seq.wt_snp_prev_addr.set_value(wt_snp_prev_addr);
            m_system_bfm_seq.wt_snp_cmd_req_addr.set_value(wt_snp_cmd_req_addr);
            m_system_bfm_seq.wt_snp_random_addr.set_value(wt_snp_random_addr);
            m_system_bfm_seq.wt_snp_for_stash_random_addr.set_value(0);
            wt_ace_rdnosnp      = 0;
            wt_ace_rdonce       = 0;
            wt_ace_rdshrd       = 0;
            wt_ace_rdcln        = 0;
            wt_ace_rdnotshrddty = 0;
            wt_ace_rdunq        = 0;
            wt_ace_clnunq       = 0;
            wt_ace_mkunq        = 0;
            wt_ace_dvm_msg      = 0;
            wt_ace_clnshrd      = 0;
            wt_ace_clninvl      = 0;
            wt_ace_mkinvl       = 0;
            wt_ace_rd_bar       = 0;
            wt_ace_wrnosnp      = 0;
            wt_ace_wrunq        = 0;
            wt_ace_wrlnunq      = 0;
            wt_ace_wrcln        = 0;
            wt_ace_wrbk         = 0;
            wt_ace_wrevct       = 0;
            wt_ace_evct         = 0;
            wt_ace_atm_str      = 0;
            wt_ace_atm_ld       = 0;
            wt_ace_atm_swap     = 0;
            wt_ace_atm_comp     = 0;
            wt_ace_ptl_stash    = 0;
            wt_ace_full_stash   = 5;
            wt_ace_shared_stash = 0;
            wt_ace_unq_stash    = 0;
            wt_ace_stash_trans  = 0;
            k_num_read_req      = 0;
            k_num_write_req     = 1;
            k_num_snp           = 0;
        end
        <%if(computedAxiInt.params.eAc &&
        (obj.DutInfo.fnNativeInterface == "ACELITE-E" ||
            obj.DutInfo.fnNativeInterface == "ACE-LITE")) { %>
            m_system_bfm_seq.k_num_snp.set_value(0); 
            m_system_bfm_seq.wt_snp_cln_dtr.set_value(0); 
            m_system_bfm_seq.wt_snp_inv_stsh.set_value(0);
            m_system_bfm_seq.wt_snp_unq_stsh.set_value(0);
            m_system_bfm_seq.wt_snp_stsh_sh.set_value(0);
            m_system_bfm_seq.wt_snp_stsh_unq.set_value(0);
            m_system_bfm_seq.wt_snp_inv.set_value(0); 
            m_system_bfm_seq.wt_snp_vld_dtr.set_value(0); 
            m_system_bfm_seq.wt_snp_inv_dtr.set_value(0); 
            m_system_bfm_seq.wt_snp_cln_dtw.set_value(0); 
            m_system_bfm_seq.wt_snp_inv_dtw.set_value(0); 
            m_system_bfm_seq.wt_snp_nitc.set_value(0); 
            m_system_bfm_seq.wt_snp_nitcci.set_value(0); 
            m_system_bfm_seq.wt_snp_nitcmi.set_value(0); 
            m_system_bfm_seq.wt_snp_nosdint.set_value(0);
            m_system_bfm_seq.wt_snp_dvm_msg.set_value(wt_snp_dvm_msg);
            m_system_bfm_seq.wt_snp_for_stash_random_addr.set_value(0);
        <%}%>
    	<%for(var i = 0; i < obj.DutInfo.nNativeInterfacePorts; i++){%>
            mp_env.m_axi_master_cfg[<%=i%>].wt_ace_rdnosnp                         = wt_ace_rdnosnp;
            mp_env.m_axi_master_cfg[<%=i%>].wt_ace_rdonce                          = wt_ace_rdonce;
            mp_env.m_axi_master_cfg[<%=i%>].wt_ace_rdshrd                          = wt_ace_rdshrd;
            mp_env.m_axi_master_cfg[<%=i%>].wt_ace_rdcln                           = wt_ace_rdcln;
            mp_env.m_axi_master_cfg[<%=i%>].wt_ace_rdnotshrddty                    = wt_ace_rdnotshrddty;
            mp_env.m_axi_master_cfg[<%=i%>].wt_ace_rdunq                           = wt_ace_rdunq;
            mp_env.m_axi_master_cfg[<%=i%>].wt_ace_clnunq                          = wt_ace_clnunq;
            mp_env.m_axi_master_cfg[<%=i%>].wt_ace_mkunq                           = wt_ace_mkunq;
            mp_env.m_axi_master_cfg[<%=i%>].wt_ace_dvm_msg                         = wt_ace_dvm_msg;
            mp_env.m_axi_master_cfg[<%=i%>].wt_ace_dvm_sync                        = wt_ace_dvm_sync;
            mp_env.m_axi_master_cfg[<%=i%>].wt_ace_clnshrd                         = wt_ace_clnshrd;
            mp_env.m_axi_master_cfg[<%=i%>].wt_ace_clninvl                         = wt_ace_clninvl;
            mp_env.m_axi_master_cfg[<%=i%>].wt_ace_mkinvl                          = wt_ace_mkinvl;
            mp_env.m_axi_master_cfg[<%=i%>].wt_ace_rd_bar                          = wt_ace_rd_bar;
            mp_env.m_axi_master_cfg[<%=i%>].wt_ace_wrnosnp                         = wt_ace_wrnosnp;
            mp_env.m_axi_master_cfg[<%=i%>].wt_ace_wrunq                           = wt_ace_wrunq;
            mp_env.m_axi_master_cfg[<%=i%>].wt_ace_wrlnunq                         = wt_ace_wrlnunq;
            mp_env.m_axi_master_cfg[<%=i%>].wt_ace_wrcln                           = wt_ace_wrcln;
            mp_env.m_axi_master_cfg[<%=i%>].wt_ace_wrbk                            = wt_ace_wrbk;
            mp_env.m_axi_master_cfg[<%=i%>].wt_ace_evct                            = wt_ace_evct;
            mp_env.m_axi_master_cfg[<%=i%>].wt_ace_wrevct                          = wt_ace_wrevct;
            mp_env.m_axi_master_cfg[<%=i%>].wt_ace_wr_bar                          = wt_ace_wr_bar;
            mp_env.m_axi_master_cfg[<%=i%>].wt_ace_atm_str                         = wt_ace_atm_str;
            mp_env.m_axi_master_cfg[<%=i%>].wt_ace_atm_ld                          = wt_ace_atm_ld;
            mp_env.m_axi_master_cfg[<%=i%>].wt_ace_atm_swap                        = wt_ace_atm_swap;
            mp_env.m_axi_master_cfg[<%=i%>].wt_ace_atm_comp                        = wt_ace_atm_comp;
            mp_env.m_axi_master_cfg[<%=i%>].wt_ace_ptl_stash                       = wt_ace_ptl_stash;
            mp_env.m_axi_master_cfg[<%=i%>].wt_ace_full_stash                      = wt_ace_full_stash;
            mp_env.m_axi_master_cfg[<%=i%>].wt_ace_shared_stash                    = wt_ace_shared_stash;
            mp_env.m_axi_master_cfg[<%=i%>].wt_ace_unq_stash                       = wt_ace_unq_stash;
            mp_env.m_axi_master_cfg[<%=i%>].wt_ace_stash_trans                     = wt_ace_stash_trans;
            mp_env.m_axi_master_cfg[<%=i%>].wt_ace_rd_cln_invld                    = wt_ace_rd_cln_invld;
            mp_env.m_axi_master_cfg[<%=i%>].wt_ace_rd_make_invld                   = wt_ace_rd_make_invld;     
            mp_env.m_axi_master_cfg[<%=i%>].wt_ace_clnshrd_pers                    = wt_ace_clnshrd_pers;
            mp_env.m_axi_master_cfg[<%=i%>].k_num_read_req                         = k_num_read_req;
            mp_env.m_axi_master_cfg[<%=i%>].k_num_write_req                        = k_num_write_req;
            mp_env.m_axi_master_cfg[<%=i%>].k_num_snp                              = k_num_snp;
            mp_env.m_axi_master_cfg[<%=i%>].prob_ace_snp_resp_error                = prob_ace_snp_resp_error;
            mp_env.m_axi_master_cfg[<%=i%>].k_is_bfm_delay_changing                = k_is_bfm_delay_changing;
            mp_env.m_axi_master_cfg[<%=i%>].k_bfm_delay_changing_time              = k_bfm_delay_changing_time;
            mp_env.m_axi_master_cfg[<%=i%>].k_ace_master_read_addr_chnl_delay_min.set_value(k_ace_master_read_addr_chnl_delay_min);
            mp_env.m_axi_master_cfg[<%=i%>].k_ace_master_read_addr_chnl_delay_max.set_value(k_ace_master_read_addr_chnl_delay_max);
            mp_env.m_axi_master_cfg[<%=i%>].k_ace_master_read_addr_chnl_burst_pct.set_value(k_ace_master_read_addr_chnl_burst_pct);
            mp_env.m_axi_master_cfg[<%=i%>].k_ace_master_read_data_chnl_delay_min.set_value(k_ace_master_read_data_chnl_delay_min);
            mp_env.m_axi_master_cfg[<%=i%>].k_ace_master_read_data_chnl_delay_max.set_value(k_ace_master_read_data_chnl_delay_max);
            mp_env.m_axi_master_cfg[<%=i%>].k_ace_master_read_data_chnl_burst_pct.set_value(k_ace_master_read_data_chnl_burst_pct);
            mp_env.m_axi_master_cfg[<%=i%>].k_ace_master_write_addr_chnl_delay_min.set_value(k_ace_master_write_addr_chnl_delay_min);
            mp_env.m_axi_master_cfg[<%=i%>].k_ace_master_write_addr_chnl_delay_max.set_value(k_ace_master_write_addr_chnl_delay_max);
            mp_env.m_axi_master_cfg[<%=i%>].k_ace_master_write_addr_chnl_burst_pct.set_value(k_ace_master_write_addr_chnl_burst_pct);
            mp_env.m_axi_master_cfg[<%=i%>].k_ace_master_write_data_chnl_delay_min.set_value(k_ace_master_write_data_chnl_delay_min);
            mp_env.m_axi_master_cfg[<%=i%>].k_ace_master_write_data_chnl_delay_max.set_value(k_ace_master_write_data_chnl_delay_max);
            mp_env.m_axi_master_cfg[<%=i%>].k_ace_master_write_data_chnl_burst_pct.set_value(k_ace_master_write_data_chnl_burst_pct);
            mp_env.m_axi_master_cfg[<%=i%>].k_ace_master_write_resp_chnl_delay_min.set_value(k_ace_master_write_resp_chnl_delay_min);
            mp_env.m_axi_master_cfg[<%=i%>].k_ace_master_write_resp_chnl_delay_max.set_value(k_ace_master_write_resp_chnl_delay_max);
            mp_env.m_axi_master_cfg[<%=i%>].k_ace_master_write_resp_chnl_burst_pct.set_value(k_ace_master_write_resp_chnl_burst_pct);
        <%}%>
        <%if (axiIntIsArray) {%>
    	    <%for(var i = 0; i < obj.DutInfo.nNativeInterfacePorts; i++){%>
                <%if (obj.DutInfo.interfaces.axiInt[i].params.eAc) {%>
                    mp_env.m_axi_master_cfg[<%=i%>].k_ace_master_snoop_addr_chnl_delay_min.set_value(k_ace_master_snoop_addr_chnl_delay_min);
                    mp_env.m_axi_master_cfg[<%=i%>].k_ace_master_snoop_addr_chnl_delay_max.set_value(k_ace_master_snoop_addr_chnl_delay_max);
                    mp_env.m_axi_master_cfg[<%=i%>].k_ace_master_snoop_addr_chnl_burst_pct.set_value(k_ace_master_snoop_addr_chnl_burst_pct);
                    mp_env.m_axi_master_cfg[<%=i%>].k_ace_master_snoop_resp_chnl_delay_min.set_value(k_ace_master_snoop_resp_chnl_delay_min);
                    mp_env.m_axi_master_cfg[<%=i%>].k_ace_master_snoop_resp_chnl_delay_max.set_value(k_ace_master_snoop_resp_chnl_delay_max);
                    mp_env.m_axi_master_cfg[<%=i%>].k_ace_master_snoop_resp_chnl_burst_pct.set_value(k_ace_master_snoop_resp_chnl_burst_pct);
                <%}%>
            <%}%>
        <%} else {%>
            mp_env.m_axi_master_cfg[0].k_ace_master_snoop_addr_chnl_delay_min.set_value(k_ace_master_snoop_addr_chnl_delay_min);
            mp_env.m_axi_master_cfg[0].k_ace_master_snoop_addr_chnl_delay_max.set_value(k_ace_master_snoop_addr_chnl_delay_max);
            mp_env.m_axi_master_cfg[0].k_ace_master_snoop_addr_chnl_burst_pct.set_value(k_ace_master_snoop_addr_chnl_burst_pct);
            mp_env.m_axi_master_cfg[0].k_ace_master_snoop_resp_chnl_delay_min.set_value(k_ace_master_snoop_resp_chnl_delay_min);
            mp_env.m_axi_master_cfg[0].k_ace_master_snoop_resp_chnl_delay_max.set_value(k_ace_master_snoop_resp_chnl_delay_max);
            mp_env.m_axi_master_cfg[0].k_ace_master_snoop_resp_chnl_burst_pct.set_value(k_ace_master_snoop_resp_chnl_burst_pct);
        <%}%>
        <%if(obj.DutInfo.fnNativeInterface == "ACE"){%>
    	    <%for(var i = 0; i < obj.DutInfo.nNativeInterfacePorts; i++){%>
                mp_env.m_axi_master_cfg[<%=i%>].k_ace_master_snoop_data_chnl_delay_min.set_value(k_ace_master_snoop_data_chnl_delay_min);
                mp_env.m_axi_master_cfg[<%=i%>].k_ace_master_snoop_data_chnl_delay_max.set_value(k_ace_master_snoop_data_chnl_delay_max);
                mp_env.m_axi_master_cfg[<%=i%>].k_ace_master_snoop_data_chnl_burst_pct.set_value(k_ace_master_snoop_data_chnl_burst_pct);
            <%}%>
        <%}%>
        if($test$plusargs("write_bw_test")) begin
    	    <%for(var i = 0; i < obj.DutInfo.nNativeInterfacePorts; i++){%>
                mp_env.m_axi_master_cfg[<%=i%>].k_ace_master_write_addr_chnl_delay_min.set_value(0);
                mp_env.m_axi_master_cfg[<%=i%>].k_ace_master_write_addr_chnl_delay_max.set_value(0);
                mp_env.m_axi_master_cfg[<%=i%>].k_ace_master_write_addr_chnl_burst_pct.set_value(100);
                mp_env.m_axi_master_cfg[<%=i%>].k_ace_master_write_data_chnl_delay_min.set_value(0);
                mp_env.m_axi_master_cfg[<%=i%>].k_ace_master_write_data_chnl_delay_max.set_value(0);
                mp_env.m_axi_master_cfg[<%=i%>].k_ace_master_write_data_chnl_burst_pct.set_value(100);
                mp_env.m_axi_master_cfg[<%=i%>].k_ace_master_write_resp_chnl_delay_min.set_value(0);
                mp_env.m_axi_master_cfg[<%=i%>].k_ace_master_write_resp_chnl_delay_max.set_value(0);
                mp_env.m_axi_master_cfg[<%=i%>].k_ace_master_write_resp_chnl_burst_pct.set_value(100);
            <%}%>
            <%if(obj.NO_SMI === undefined){%>
                <%var NSMIIFTX = obj.DutInfo.nSmiTx;
                for(var i = 0; i < NSMIIFTX; i++){%>
                    m_smi_agent_cfg.m_smi<%=i%>_tx_port_config.k_delay_min.set_value(0);
                    m_smi_agent_cfg.m_smi<%=i%>_tx_port_config.k_delay_max.set_value(0);
                    m_smi_agent_cfg.m_smi<%=i%>_tx_port_config.k_burst_pct.set_value(100);
                <%}%>
                <%var NSMIIFRX = obj.DutInfo.nSmiRx;
                for (var i = 0; i < NSMIIFRX; i++){%>
                    m_smi_agent_cfg.m_smi<%=i%>_rx_port_config.k_delay_min.set_value(0);
                    m_smi_agent_cfg.m_smi<%=i%>_rx_port_config.k_delay_max.set_value(0);
                    m_smi_agent_cfg.m_smi<%=i%>_rx_port_config.k_burst_pct.set_value(100);
                <%}%>
            <%}%>
        end

        if ($test$plusargs("ace_dvm_only_test")) begin
    	    <%for(var i = 0; i < obj.DutInfo.nNativeInterfacePorts; i++){%>
                mp_env.m_axi_master_cfg[<%=i%>].k_ace_master_read_addr_chnl_delay_min.set_value(0);
                mp_env.m_axi_master_cfg[<%=i%>].k_ace_master_read_addr_chnl_delay_max.set_value(0);
                mp_env.m_axi_master_cfg[<%=i%>].k_ace_master_read_addr_chnl_burst_pct.set_value(100);
            <%}%>
            <%var NSMIIFTX = obj.DutInfo.nSmiTx;
            for(var i = 0; i < NSMIIFTX; i++){%>
                m_smi_agent_cfg.m_smi<%=i%>_tx_port_config.k_delay_min.set_value(0);
                m_smi_agent_cfg.m_smi<%=i%>_tx_port_config.k_delay_max.set_value(5);
                m_smi_agent_cfg.m_smi<%=i%>_tx_port_config.k_burst_pct.set_value(100);
            <%}%>
            <%var NSMIIFRX = obj.DutInfo.nSmiRx;
            for(var i = 0; i < NSMIIFRX; i++){%>
                m_smi_agent_cfg.m_smi<%=i%>_rx_port_config.k_delay_min.set_value(0);
                m_smi_agent_cfg.m_smi<%=i%>_rx_port_config.k_delay_max.set_value(5);
                m_smi_agent_cfg.m_smi<%=i%>_rx_port_config.k_burst_pct.set_value(100);
            <%}%>
        end

        

        
 

        `uvm_info("build_phase", "Exiting...", UVM_LOW)
    endfunction: build_phase




endclass

`endif



endclass : BaseScenario
