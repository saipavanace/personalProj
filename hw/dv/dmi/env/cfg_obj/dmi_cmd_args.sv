
class dmi_cmd_args extends uvm_object;

  string LABEL = "DMI_CMD_ARGS";
  `uvm_object_param_utils(dmi_cmd_args)
  uvm_cmdline_processor clp = uvm_cmdline_processor::get_inst();
  <% if(obj.testBench == 'dmi' || (obj.testBench == "fsys")) { %>
  `ifndef VCS
  const t_minmax_range m_minmax_for_wt_pref_read[1]  = {{0,0}};
  `else // `ifndef VCS
  const t_minmax_range m_minmax_for_wt_pref_read[1]  = '{'{m_min_range:0,m_max_range:0}};
  `endif // `ifndef VCS ... `else ... 
  <% } else {%>
  const t_minmax_range m_minmax_for_wt_pref_read[1]  = {{0,0}};
  <% } %>
  common_knob_class wt_reuse_addr          = new("wt_reuse_addr"          , this , m_weights_for_weight_knobs , m_minmax_for_weight_knobs);
  common_knob_class wt_cmd_rd_nc           = new("wt_cmd_rd_nc"           , this , m_weights_for_weight_knobs , m_minmax_for_weight_knobs);
  common_knob_class wt_cmd_wr_nc_ptl       = new("wt_cmd_wr_nc_ptl"       , this , m_weights_for_weight_knobs , m_minmax_for_weight_knobs);
  common_knob_class wt_cmd_wr_nc_full      = new("wt_cmd_wr_nc_full"      , this , m_weights_for_weight_knobs , m_minmax_for_weight_knobs);

  common_knob_class wt_cmd_cln_inv         = new("wt_cmd_cln_inv"         , this , m_weights_for_weight_knobs , m_minmax_for_weight_knobs);
  common_knob_class wt_cmd_cln_vld         = new("wt_cmd_cln_vld"         , this , m_weights_for_weight_knobs , m_minmax_for_weight_knobs);
  common_knob_class wt_cmd_cln_ShPsist     = new("wt_cmd_cln_ShPsist"     , this , m_weights_for_weight_knobs , m_minmax_for_weight_knobs);
  common_knob_class wt_cmd_mk_inv          = new("wt_cmd_mk_inv"          , this , m_weights_for_weight_knobs , m_minmax_for_weight_knobs);
  common_knob_class wt_cmd_pref            = new("wt_cmd_pref"            , this , m_weights_for_weight_knobs , m_minmax_for_weight_knobs);

  common_knob_class wt_mrd_rd_with_shr_cln = new("wt_mrd_rd_with_shr_cln" , this , m_weights_for_weight_knobs , m_minmax_for_weight_knobs);
  common_knob_class wt_mrd_rd_with_unq_cln = new("wt_mrd_rd_with_unq_cln" , this , m_weights_for_weight_knobs , m_minmax_for_weight_knobs);
  common_knob_class wt_mrd_rd_with_unq     = new("wt_mrd_rd_with_unq"     , this , m_weights_for_weight_knobs , m_minmax_for_weight_knobs);
  common_knob_class wt_mrd_rd_with_inv     = new("wt_mrd_rd_with_inv"     , this , m_weights_for_weight_knobs , m_minmax_for_weight_knobs);
  common_knob_class wt_mrd_flush           = new("wt_mrd_flush"           , this , m_weights_for_weight_knobs , m_minmax_for_weight_knobs);
  common_knob_class wt_mrd_cln             = new("wt_mrd_cln"             , this , m_weights_for_weight_knobs , m_minmax_for_weight_knobs);
  common_knob_class wt_mrd_inv             = new("wt_mrd_inv"             , this , m_weights_for_weight_knobs , m_minmax_for_weight_knobs);
  common_knob_class wt_mrd_pref            = new("wt_mrd_pref"            , this , m_weights_for_weight_knobs , m_minmax_for_weight_knobs);


  common_knob_class wt_dtw_no_dt           = new("wt_dtw_no_dt"           , this , m_weights_for_weight_knobs , m_minmax_for_weight_knobs);
  common_knob_class wt_dtw_dt_cln          = new("wt_dtw_dt_cln"          , this , m_weights_for_weight_knobs , m_minmax_for_weight_knobs);
  common_knob_class wt_dtw_dt_ptl          = new("wt_dtw_dt_ptl"          , this , m_weights_for_weight_knobs , m_minmax_for_weight_knobs);
  common_knob_class wt_dtw_dt_dty          = new("wt_dtw_dt_dty"          , this , m_weights_for_weight_knobs , m_minmax_for_weight_knobs);
  common_knob_class wt_rb_release          = new("wt_rb_release"          , this , m_weights_for_weight_knobs , m_minmax_for_weight_knobs);
  common_knob_class wt_dtw_dt_atm          = new("wt_dtw_dt_atm"          , this , m_weights_for_weight_knobs , m_minmax_for_weight_knobs);
  common_knob_class wt_dtw_mrg_mrd_ucln    = new("wt_dtw_mrg_mrd_ucln"    , this , m_weights_for_weight_knobs , m_minmax_for_weight_knobs);
  common_knob_class wt_dtw_mrg_mrd_udty    = new("wt_dtw_mrg_mrd_udty"    , this , m_weights_for_weight_knobs , m_minmax_for_weight_knobs);
  common_knob_class wt_dtw_mrg_mrd_inv     = new("wt_dtw_mrg_mrd_inv"     , this , m_weights_for_weight_knobs , m_minmax_for_weight_knobs);
  common_knob_class wt_noncoh_addr         = new("wt_noncoh_addr"         , this , m_weights_for_weight_knobs , m_minmax_for_weight_knobs);
  common_knob_class wt_coh_addr            = new("wt_coh_addr"            , this , m_weights_for_weight_knobs , m_minmax_for_weight_knobs);
  common_knob_class wt_dtw_intervention    = new("wt_dtw_intervention"    , this , m_weights_for_weight_knobs , m_minmax_for_weight_knobs);

  common_knob_class wt_cmd_rd_atm          = new("wt_cmd_rd_atm"          , this , m_weights_for_weight_knobs , m_minmax_for_weight_knobs);
  common_knob_class wt_cmd_wr_atm          = new("wt_cmd_wr_atm"          , this , m_weights_for_weight_knobs , m_minmax_for_weight_knobs);
  common_knob_class wt_cmd_swap_atm        = new("wt_cmd_swap_atm"        , this , m_weights_for_weight_knobs , m_minmax_for_weight_knobs);
  common_knob_class wt_cmd_cmp_atm         = new("wt_cmd_cmp_atm"         , this , m_weights_for_weight_knobs , m_minmax_for_weight_knobs);
  common_knob_class wt_sp_addr_range       = new("wt_sp_addr_range"       , this , m_weights_for_weight_knobs , m_minmax_for_weight_knobs);
  common_knob_class wt_addr_reused_q       = new("wt_addr_reused_q"       , this , m_weights_for_weight_knobs , m_minmax_for_weight_knobs);
  common_knob_class wt_ccp_evict_addr      = new("wt_ccp_evict_addr"      , this , m_weights_for_weight_knobs , m_minmax_for_weight_knobs);

  // Weight for High priority packets based on QOS threshold
  common_knob_class wt_dmi_qos_hp_pkt           = new("wt_dmi_qos_hp_pkt"           , this, m_weights_for_weight_knobs, m_minmax_for_weight_knobs);
  common_knob_class wt_coh_noncoh_addr_collision= new("wt_coh_noncoh_addr_collision", this, m_weights_for_weight_knobs, m_minmax_for_weight_knobs);

  //weight of exclusive CMD 
  common_knob_class wt_cmd_exclusive       = new ("wt_cmd_exclusive"       , this , m_weights_for_weight_knobs , m_minmax_for_weight_knobs);
  common_knob_class wt_exclusive_sequence  = new ("wt_exclusive_sequence"  , this , m_weights_for_weight_knobs , m_minmax_for_weight_knobs);
  common_knob_class wt_exclusives          = new ("wt_exclusives"          , this , m_weights_for_weight_knobs , m_minmax_for_weight_knobs);

  int ccp_scb_en;
  bit EN_DMI_VSEQ;
  int cctrlr_value;
  int dmi_scb_en;
  int k_timeout= 1000000;
  int inject_ttdebug;
  int k_addr_trans_hit;
  int k_apb_maccept_burst_pct;
  int k_apb_maccept_delay_max;
  int k_apb_maccept_delay_min;
  int k_apb_maccept_wait_for_sresp;
  int k_apb_mcmd_burst_pct;
  int k_apb_mcmd_delay_max;
  int k_apb_mcmd_delay_min;
  int k_apb_mcmd_wait_for_scmdaccept;
  int k_atomic_directed;
  int k_atomic_opcode;
  int k_back_to_back_chains;
  int k_back_to_back_types;
  int k_cmc_policy;
  int k_force_allocate,k_force_no_allocate;
  int k_force_mw = -1;
  int k_force_size;
  int k_full_cl_only;
  int k_intfsize;
  int k_max_reuse_q_size;
  int k_min_reuse_q_size;
  int k_mntop_cmd;
  int k_num_cmd;
  int k_reuse_q_pct;
  int k_slow_agent;
  int k_slow_apb_agent;
  int k_slow_apb_mcmd_agent;
  int k_slow_apb_mrespaccept_agent;
  int k_slow_read_agent;
  int k_slow_write_agent;
  int k_SysEventDisable;
  int k_use_all_str_msg_id;
  int k_WrDataClnPropagateEn;
  int mrd_use_last_mrd_pref;
  int n_pending_txn_mode;
  int use_adj_addr;
  int use_last_dealloc;
  int k_pmon_bw_user_bits;
  int k_force_coh_vz, k_force_sys_vz;
  int k_force_late_rsp = -1;
  bit k_no_exclusives;
  bit k_sp_en; //FIXME
  bit k_wrong_targ_id_cmd, k_wrong_targ_id_mrd;
  bit k_wrong_arg_id_dtr_rsp, k_wrong_targ_id_on_dtwdbg_rsp, k_wrong_targ_id_str_rsp;
  bit k_wrong_targ_id_dtw_req, k_wrong_targ_id_rb_req;
  bit k_wrong_target_id;
  bit k_alternate_be;
  bit k_smi_dtw_err;
  bit k_random_dbad_on_dtw_req;
  bit k_stimulus_debug, k_stimulus_address_debug, k_axi_debug;
  int k_force_align_addr;
  bit k_cache_warmup;
  bit k_starvation_test;
  bit k_all_byte_enables_on;
  bit k_all_internal_release;
  bit k_read_data_interleaving;
  bit k_sram_single_bit_error, k_sram_double_bit_error, k_sram_address_error;
  bit k_expect_mission_fault;
  bit k_enable_cmdline_backpressure, k_enable_suspend_axi;
  bit k_disable_axi_backpressure;
  bit axi_rw_address_chnl_backpressure;
  bit axi_wr_data_chnl_backpressure, axi_wr_resp_chnl_backpressure;
  bit axi_rd_data_chnl_backpressure, axi_rd_resp_chnl_backpressure;
  bit axi_suspend_W_resp;
  bit axi_suspend_R_resp;
  bit axi_suspend_resp;
  long_delay_mode_e k_axi_long_delay_mode=NO_LONG_DELAY;
  error_type_t k_plru_error_mode;
  bit k_MNTOP_addr_range_max;
  bit k_shared_c_nc_addressing; //Can send coherent transactions to non-coherent address regions
  int wt_randomly_streamed_exclusives=-1;
  int exclusive_monitor_size = <%=obj.DmiInfo[obj.Id].nExclusiveEntries%>;
  int k_force_ns=-1;
  int k_force_exclusive=-1;
  bit atomics_disabled;
  bit k_sys_event_disable;
  bit k_SP_warmup;
  int k_OOO_axi_response=-1;
  bit k_OOO_axi_rd_response,k_OOO_axi_wr_response;
  bit test_unit_duplication;
  bit wait_for_empty_tt;
  //Timeout Error Tests
  bit k_smc_timeout_error_test;
  bit k_wtt_timeout_error_test;
  bit k_rtt_timeout_error_test;
  //Read/Write response error injection
  int prob_ace_rd_resp_error = 10;
  int prob_ace_wr_resp_error = 10;
  //Delay Control--Begin
  int tb_delay;
  int k_seq_delay = 5000;
  int k_seq_timeout_max = 5000;
  bit k_axi_zero_delay;
  bit k_axi_long_delay;
  bit k_axi_FF_rd_beat;
  bit k_axi_rd_long_delay_en = 1;
  bit k_axi_wr_long_delay_en = 1;
  //Delay Control--End
  //Address controls--Begin
  dmi_addr_q_format_t k_addr_q_type=REGULAR;
  int k_limit_addresses = -1;
  bit k_translate_addresses;
  //Address controls--End
  //Common waiver controls--Begin
  bit sram_error_test;
  bit sram_uc_error_test;
  bit k_ungate_wait_aiu_txn;
  bit k_waive_mission_fault_eos_check;
  
  //Common waiver controls--End
  //CSR control --Begin
  bit CESR_transport_errors;
  bit CESR_skid_buffer_errors;
  //CSR control --End
  //Pattern control
  bit k_cmdline_pattern_mode, k_cmdline_user_pattern_mode, k_cmdline_super_pattern_mode;
  dmi_pattern_type_t k_pattern_type;
  dmi_super_pattern_type_t k_super_pattern_type;
  smi_type_t DMI_USER_pattern_q[$];

  //Pct value args specified from cmdline
  int k_dmiTmBit4Smi0, k_dmiTmBit4Smi2, k_dmiTmBit4Smi3;
  int k_dmi_qos_th_val = -1;
  int randval;

  //Traffic arguments for CCMP traffic control
  //Isolated Traffic modes
  bit only_traffic_mode;
  bit k_atomic_traffic_only, k_force_atomic_traffic;
  bit directed_err_test; //FIXME
  bit k_mrd_traffic_only;
  bit k_cmo_traffic_only;
  bit k_read_traffic_only;
  bit k_read_traffic_only_no_cmo;
  bit k_mrd_dtwmrgmrd_traffic_only;
  bit k_dtwmrgmrd_traffic_only;
  bit k_coh_write_traffic_only;
  bit k_noncoh_read_traffic_only;
  bit k_noncoh_write_traffic_only;
  bit k_write_traffic_only;
  bit k_write_with_data_traffic_only;
  bit k_read_write_traffic_only;
  bit k_read_write_data_traffic_only;
  bit k_all_coh_atomics_traffic_only;
  bit k_all_noncoh_atomics_traffic_only;
  bit k_cmd_mrd_traffic_only;
  //Ignore mode
  bit k_no_CMO_traffic;
  
  bit send_dtw_with_data;

  //Legacy args from dmi_test
  bit k_collect_resiliency_cov;
  bit k_expect_mission_fault;
  bit k_test_placeholder_connectivity;
  bit k_expect_mission_fault_cov;
  bit k_directed_err_test;
  bit k_dmi_mrd_only;
  bit k_dmi_cmo_only;
  bit k_dmi_rd_only;
  bit k_dmi_mrd_dtwmrgmrd_only;
  bit k_dmi_cohwr_only;
  bit k_dmi_ncrd_only;
  bit k_dmi_ncwr_only;
  bit k_dmi_wr_only;
  bit k_dmi_Rdwr_only;
  bit k_dmi_dtw_mrg_mrd_test_only;
  bit k_enable_mrd_pref;
  bit k_enable_only_atomics;
  bit k_boot_region_access;
  bit k_tcap_scb_en;
  bit k_ex_sys_evt;
  bit k_prog_dmi_qos_th_csr;
  bit k_check_corr_error_cnt;
  bit k_test_unit_duplication;
  bit k_performance_test;
  bit k_uesr_poll_err_test;
  bit k_wait_for_empty_tt;
  bit k_saturate_rbs_test;
  bit k_upd_dmi_qos_th_csr;
  bit k_check_eos_plru_err_count;
  bit k_add_dtwMrgMrd;
  bit k_dmi_2dtw_intervention_only;
  bit k_add_2dtw_intervention;
  bit k_dmi_atomic_test_only;
  bit k_add_atomic;
  
  //SMI backpressure args
  bit k_str_req_backpressure;
  bit k_rbr_rsp_backpressure;
  bit k_rbr_rsp_extreme_backpressure;
  bit k_dtr_req_backpressure;
  bit k_dtr_req_extreme_backpressure;
  bit k_dtw_rsp_backpressure;
  bit k_dtr_rsp_backpressure;
  bit k_sys_rsp_timeout;
  bit smi_backpressure;

  function new(string name="dmi_cmd_args");
    super.new(name);
    get_plusargs();
    get_traffic_args();
  endfunction

  function void get_traffic_args();
    //Only Mode//////////////////////////////
    <% if(obj.DmiInfo[obj.Id].useAtomic) { %>    
    if ($test$plusargs("k_atomic_traffic_only")) begin
      `uvm_info("traffic_pattern_seq","Atomic only mode set.", UVM_LOW)
      k_atomic_traffic_only = 1; only_traffic_mode = 1;
    end
    <% } %>
    if ($test$plusargs("k_force_atomic_traffic")) begin
      //Used to send atomic in unsupported configurations to trigger a uncorrectable error 
      `uvm_info("traffic_pattern_seq","Forcing atomic traffic.", UVM_LOW)
      k_force_atomic_traffic = 1; 
    end
    if ($test$plusargs("k_mrd_traffic_only")) begin
      `uvm_info("traffic_pattern_seq","Mrd only mode set.", UVM_LOW)
      k_mrd_traffic_only = 1; only_traffic_mode = 1;
    end
    if ($test$plusargs("k_cmo_traffic_only")) begin
      `uvm_info("traffic_pattern_seq","CMO only mode set.", UVM_LOW)
      k_cmo_traffic_only = 1; only_traffic_mode = 1;
    end
    if ($test$plusargs("k_read_traffic_only")) begin
      `uvm_info("traffic_pattern_seq","Read only mode set.", UVM_LOW)
      k_read_traffic_only = 1; only_traffic_mode = 1;
    end
    if ($test$plusargs("k_read_traffic_only_no_cmo")) begin
      `uvm_info("traffic_pattern_seq","Read only mode with no CMOs set.", UVM_LOW)
      k_read_traffic_only_no_cmo = 1; only_traffic_mode = 1;
    end
    if ($test$plusargs("k_mrd_dtwmrgmrd_traffic_only")) begin
      `uvm_info("traffic_pattern_seq","Mrd & DtwMrgMrd only mode set.", UVM_LOW)
      k_mrd_dtwmrgmrd_traffic_only = 1; only_traffic_mode = 1;
    end
    if ($test$plusargs("k_dtwmrgmrd_traffic_only")) begin
      `uvm_info("traffic_pattern_seq","DtwMrgMrd only mode set.", UVM_LOW)
      k_dtwmrgmrd_traffic_only = 1; only_traffic_mode = 1;
    end
    if ($test$plusargs("k_coh_write_traffic_only")) begin
      `uvm_info("traffic_pattern_seq","Coherent write only mode set.", UVM_LOW)
      k_coh_write_traffic_only = 1; only_traffic_mode = 1;
    end
    if ($test$plusargs("k_noncoh_read_traffic_only")) begin
      `uvm_info("traffic_pattern_seq","Non-coherent read only mode set.", UVM_LOW)
      k_noncoh_read_traffic_only = 1; only_traffic_mode = 1;
    end
    if ($test$plusargs("k_noncoh_write_traffic_only")) begin
      `uvm_info("traffic_pattern_seq","Non-coherent write only mode set.", UVM_LOW)
      k_noncoh_write_traffic_only = 1; only_traffic_mode = 1;
    end
    if ($test$plusargs("k_write_traffic_only")) begin
      `uvm_info("traffic_pattern_seq","Write only mode set.", UVM_LOW)
      k_write_traffic_only = 1; only_traffic_mode = 1;
    end
    if ($test$plusargs("k_write_with_data_traffic_only")) begin
      `uvm_info("traffic_pattern_seq","Write with data only mode set.", UVM_LOW)
      k_write_with_data_traffic_only = 1; only_traffic_mode = 1;
    end
    if ($test$plusargs("k_read_write_traffic_only")) begin
      `uvm_info("traffic_pattern_seq","Read/Write only mode set.", UVM_LOW)
      k_read_write_traffic_only = 1; only_traffic_mode = 1;
    end
    if ($test$plusargs("k_read_write_data_traffic_only")) begin
      `uvm_info("traffic_pattern_seq","Read/Write with data only mode set.", UVM_LOW)
      k_read_write_data_traffic_only = 1; only_traffic_mode = 1;
    end
    if ($test$plusargs("k_cmd_mrd_traffic_only")) begin
      `uvm_info("traffic_pattern_seq","Cmd/Mrd only mode set.", UVM_LOW)
      k_cmd_mrd_traffic_only = 1; only_traffic_mode = 1;
    end
    //End Only Mode///////////////////////////////
    if ($test$plusargs("k_all_coh_atomics_traffic_only")) begin
      `uvm_info("traffic_pattern_seq","Forcing all atomics to be coherent.", UVM_LOW)
      k_all_coh_atomics_traffic_only = 1; 
    end
    if ($test$plusargs("k_all_noncoh_atomics_traffic_only")) begin
      `uvm_info("traffic_pattern_seq","Forcing all atomics to be non-coherent.", UVM_LOW)
      k_all_noncoh_atomics_traffic_only = 1;
    end

    //End Pattern Mode///////////////////////////
    //Begin Ignore mode//////////////////////////
    if($test$plusargs("k_no_CMO_traffic"))begin
      `uvm_info("traffic_pattern_seq","Disabling CMOs",UVM_LOW)
      k_no_CMO_traffic = 1;
    end
    //End   Ignore mode//////////////////////////
  endfunction

  function void get_plusargs();
    bit flag, reuse_q_flag;
    string arg_value;
    get_smi_backpressure();
    legacy_args();
    //Delay Control--Begin
    //AXI Delay Control--Begin
    if($test$plusargs("k_disable_axi_backpressure"))begin
      k_disable_axi_backpressure = 1;
    end
    if($test$plusargs("axi_rw_address_chnl_backpressure"))begin
      axi_rw_address_chnl_backpressure = 1;
      k_enable_cmdline_backpressure = 1;
      `uvm_info(LABEL,$sformatf("Enable +axi_rw_address_chnl_backpressure"),UVM_LOW)
    end
    if($test$plusargs("axi_wr_data_chnl_backpressure"))begin
      axi_wr_data_chnl_backpressure = 1;
      k_enable_cmdline_backpressure = 1;
      `uvm_info(LABEL,$sformatf("Enable +axi_wr_data_chnl_backpressure"),UVM_LOW)
    end
    if($test$plusargs("axi_rd_data_chnl_backpressure"))begin
      axi_rd_data_chnl_backpressure = 1;
      k_enable_cmdline_backpressure = 1;
      `uvm_info(LABEL,$sformatf("Enable +axi_rd_data_chnl_backpressure"),UVM_LOW)
    end
    if($test$plusargs("axi_wr_resp_chnl_backpressure"))begin
      axi_wr_resp_chnl_backpressure = 1;
      k_enable_cmdline_backpressure = 1;
      `uvm_info(LABEL,$sformatf("Enable +axi_wr_resp_chnl_backpressure"),UVM_LOW)
    end
    if($test$plusargs("axi_rd_resp_chnl_backpressure"))begin
      axi_rd_resp_chnl_backpressure = 1;
      k_enable_cmdline_backpressure = 1;
      `uvm_info(LABEL,$sformatf("Enable +axi_rd_resp_chnl_backpressure"),UVM_LOW)
    end
    if($test$plusargs("axi_suspend_W_resp"))begin
      axi_suspend_W_resp = 1;
      k_enable_suspend_axi = 1;
      `uvm_info(LABEL,$sformatf("Enable +axi_suspend_W_resp"),UVM_LOW)
    end
    if($test$plusargs("axi_suspend_R_resp"))begin
      axi_suspend_R_resp = 1;
      k_enable_suspend_axi = 1;
      `uvm_info(LABEL,$sformatf("Enable +axi_suspend_R_resp"),UVM_LOW)
    end
    if($test$plusargs("axi_suspend_resp"))begin
      axi_suspend_resp = 1;
      k_enable_suspend_axi = 1;
      `uvm_info(LABEL,$sformatf("Enable +axi_suspend_resp"),UVM_LOW)
    end
    if(clp.get_arg_value("+k_OOO_axi_response=",arg_value)) begin
      k_OOO_axi_response = arg_value.atoi();
      `uvm_info(LABEL,$sformatf("Out of order AXI response=%0d",k_OOO_axi_response),UVM_LOW)
    end
    if($test$plusargs("k_OOO_axi_rd_response")) begin
      k_OOO_axi_rd_response = 1;
      `uvm_info(LABEL,$sformatf("Out of order AXI Read response=%0d",k_OOO_axi_rd_response),UVM_LOW)
    end
    if($test$plusargs("k_OOO_axi_wr_response")) begin
      k_OOO_axi_wr_response = 1;
      `uvm_info(LABEL,$sformatf("Out of order AXI Write response=%0d",k_OOO_axi_wr_response),UVM_LOW)
    end
    //AXI Delay Control--End
    //Delay Control--End
    if (clp.get_arg_value("+k_timeout=", arg_value)) begin
      k_timeout = arg_value.atoi();
    end
    if (clp.get_arg_value("+k_num_cmd=", arg_value)) begin
      k_num_cmd = arg_value.atoi();
    end
    else begin
      k_num_cmd = $urandom_range(500,2000);
    end
    if (clp.get_arg_value("+k_mntop_cmd=", arg_value)) begin
      k_mntop_cmd = arg_value.atoi();
    end
    else begin
       k_mntop_cmd = $urandom_range(4,6);
    end
    if (clp.get_arg_value("+k_atomic_opcode=", arg_value)) begin
       k_atomic_opcode = arg_value.atoi();
    end
    else begin
       k_atomic_opcode = 8;
    end
    if (clp.get_arg_value("+k_intfsize=", arg_value)) begin
       k_intfsize = arg_value.atoi();
    end
    else begin
       k_intfsize = 8;
    end
    if (clp.get_arg_value("+n_pending_txn_mode=", arg_value)) begin
      n_pending_txn_mode = arg_value.atoi();
    end
    if (clp.get_arg_value("+k_full_cl_only=", arg_value)) begin
      k_full_cl_only = arg_value.atoi();
    end
    if (clp.get_arg_value("+k_force_size=", arg_value)) begin
      k_force_size    = arg_value.atoi();
    end
    if (clp.get_arg_value("+k_force_mw=", arg_value)) begin
      k_force_mw    = arg_value.atoi();
    end
    if (clp.get_arg_value("+test_unit_duplication=", arg_value)) begin
      test_unit_duplication  = arg_value.atoi();
    end
    if (clp.get_arg_value("+k_back_to_back_types=", arg_value)) begin
       k_back_to_back_types = arg_value.atoi();
    end
    if (clp.get_arg_value("+k_back_to_back_chains=", arg_value)) begin
       k_back_to_back_chains = arg_value.atoi();
    end
    flag = 0;
    if (clp.get_arg_value("+k_force_allocate=", arg_value)) begin
       k_force_allocate = arg_value.atoi();
    end
    if (clp.get_arg_value("+k_force_no_allocate=", arg_value)) begin
       k_force_no_allocate = arg_value.atoi();
    end
    if (clp.get_arg_value("+k_addr_trans_hit=", arg_value)) begin
       k_addr_trans_hit = arg_value.atoi();
    end
    if (clp.get_arg_value("+use_last_dealloc=", arg_value)) begin
       use_last_dealloc = arg_value.atoi();
    end
    if (clp.get_arg_value("+use_adj_addr=", arg_value)) begin
       use_adj_addr = arg_value.atoi();
    end
    if (clp.get_arg_value("+mrd_use_last_mrd_pref=", arg_value)) begin
       mrd_use_last_mrd_pref = arg_value.atoi();
    end
    if (clp.get_arg_value("+tb_delay=", arg_value)) begin
      tb_delay = arg_value.atoi();
    end
    if (clp.get_arg_value("+dmi_scb_en=", arg_value)) begin
      dmi_scb_en = arg_value.atoi();
    end
    if (clp.get_arg_value("+ccp_scb_en=", arg_value)) begin
      ccp_scb_en = arg_value.atoi();
    end
    if (clp.get_arg_value("+EN_DMI_VSEQ=", arg_value)) begin
      EN_DMI_VSEQ = arg_value.atoi();
    end

     // reuse queue knobs
    if (clp.get_arg_value("+k_min_reuse_q_size=", arg_value)) begin
      k_min_reuse_q_size = arg_value.atoi();
      reuse_q_flag = 1;
    end
    else begin
      randval = $urandom_range(1,10);
      case(randval)
        1: begin
          k_min_reuse_q_size = 2;
        end
        2,3,4:begin
          k_min_reuse_q_size = 4;
        end
        default: begin
          k_min_reuse_q_size = 8;
        end
      endcase // case (randval)
    end
    if (clp.get_arg_value("+k_max_reuse_q_size=", arg_value)) begin
      k_max_reuse_q_size = arg_value.atoi();
      reuse_q_flag = 1;
    end
    else begin
       randval = $urandom_range(1,10);
       case(randval)
         1: begin
            k_max_reuse_q_size = k_min_reuse_q_size+1;
         end
         2,3:begin
            k_max_reuse_q_size = 10;
         end
         4,5:begin
            k_max_reuse_q_size = 15;
         end
         default: begin
            k_max_reuse_q_size = 20;
         end
       endcase // case (randval)
    end
    if (clp.get_arg_value("+k_reuse_q_pct=", arg_value)) begin
      k_reuse_q_pct = arg_value.atoi();
      reuse_q_flag = 1;
    end
    else begin
      k_reuse_q_pct = $urandom_range(2,9)*10;
    end

    if (clp.get_arg_value("+prob_ace_rd_resp_error=", arg_value)) begin
       prob_ace_rd_resp_error = arg_value.atoi();
    end
    else begin
       case($urandom_range(0,100))
         10: prob_ace_rd_resp_error = $urandom_range(0,10);
         default: prob_ace_rd_resp_error = 0;
       endcase // case ($urandom_range(0,100))
    end
    if (clp.get_arg_value("+prob_ace_wr_resp_error=", arg_value)) begin
       prob_ace_wr_resp_error = arg_value.atoi();
    end
    else begin
      case($urandom_range(0,100))
        10: prob_ace_wr_resp_error = $urandom_range(0,10);
        default: prob_ace_wr_resp_error = 0;
      endcase // case ($urandom_range(0,100))
    end

    <% if(obj.INHOUSE_APB_VIP) { %>
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
    <% } %>

    flag = 0;
    
    if (clp.get_arg_value("+inject_ttdebug=", arg_value)) begin
       inject_ttdebug = arg_value.atoi();
       flag = 1;
    end
    if (clp.get_arg_value("+k_limit_addresses=", arg_value)) begin
       k_limit_addresses = arg_value.atoi();
    end
    if (clp.get_arg_value("+k_translate_addresses=", arg_value)) begin
       k_translate_addresses = arg_value.atoi();
    end
    if($test$plusargs("k_wrdatacln_propagate")) begin
      k_WrDataClnPropagateEn = 1;
    end
    else begin
      k_WrDataClnPropagateEn = $urandom_range(0,1);
    end

    if(!$test$plusargs("ex_sys_evt")) begin
      k_SysEventDisable = 1;
    end

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

    if (clp.get_arg_value("+k_use_all_str_msg_id=", arg_value)) begin
        k_use_all_str_msg_id = arg_value.atoi();
    end
    
    if (clp.get_arg_value("+k_atomic_directed=", arg_value)) begin
        k_atomic_directed = arg_value.atoi();
    end

    if (clp.get_arg_value("+wt_randomly_streamed_exclusives=", arg_value)) begin
        wt_randomly_streamed_exclusives = arg_value.atoi();
    end

    <%if(obj.useCmc) { %>
      if(clp.get_arg_value("+k_cmc_policy_rand=", arg_value)) begin
        k_cmc_policy = arg_value.atobin();
        `uvm_info(LABEL,$sformatf("Assigned cmc_policy:%0b",k_cmc_policy),UVM_LOW)
      end
      else begin
        randcase
          90 : k_cmc_policy = 6'b000011;
          1  : k_cmc_policy = 6'b000111;
          1  : k_cmc_policy = 6'b001011;
          1  : k_cmc_policy = 6'b010011;
          1  : k_cmc_policy = 6'b100011;
          1  : k_cmc_policy = 6'b000000;
          1  : k_cmc_policy = 6'b000001;
          1  : k_cmc_policy = 6'b111100;
        endcase
        `uvm_info(LABEL,$sformatf("Randomized cmc_policy:%0b",k_cmc_policy),UVM_LOW)
      end
    <% } else { %>
      k_cmc_policy = 6'b000000;
    <% } %>
    //Pattern Mode/////////////////////////////////////////////////////
    `ifdef VCS
    if($value$plusargs("k_pattern_type=%s",arg_value)) begin
      k_cmdline_pattern_mode = 1;
      if(!dmi_pattern_type_t_wrapper::from_name(arg_value,k_pattern_type)) begin
        `uvm_error(LABEL,$sformatf("Please use a legal enum type from dmi_pattern_type_t not %0s",arg_value))
      end
      else begin
        `uvm_info(LABEL,$sformatf("Enforcing DMI Sequence pattern:%0s",k_pattern_type.name),UVM_LOW)
      end
      //TODO assemble a pattern from cmdline.
      if((k_pattern_type == DMI_USER_p)) begin
        k_cmdline_user_pattern_mode = 1;
        //DMI_USER_pattern_q = {CMD_RD_NC,CMD_WR_NC_FULL};
        if(DMI_USER_pattern_q.size == 0) begin
          `uvm_error(LABEL,$sformatf("DMI_USER_pattern_q should be specified when using +k_pattern=DMI_USER_p"))
        end
      end
    end
    if($value$plusargs("k_super_pattern_type=%s",arg_value)) begin
      k_cmdline_super_pattern_mode = 1;
      if(!dmi_super_pattern_type_t_wrapper::from_name(arg_value,k_super_pattern_type)) begin
        `uvm_error(LABEL,$sformatf("Please use a legal enum type from dmi_pattern_type_t not %0s",arg_value))
      end
      else begin
        `uvm_info(LABEL,$sformatf("Enforcing DMI Sequence super pattern:%0s",k_super_pattern_type.name),UVM_LOW)
      end
    end
    if(k_cmdline_super_pattern_mode && k_cmdline_pattern_mode) begin
      `uvm_fatal(LABEL,$sformatf("+k_pattern_type and +k_super_pattern_type are mutually exclusive"))
    end
    if($value$plusargs("k_axi_long_delay_mode=%s",arg_value)) begin
      if(!long_delay_mode_e_wrapper::from_name(arg_value,k_axi_long_delay_mode)) begin
        `uvm_error(LABEL,$sformatf("Please use a legal enum type from long_delay_mode_e not %0s",arg_value))
      end
      else begin
        `uvm_info(LABEL,$sformatf("Setting AXI long_delay_mode:%0s",k_axi_long_delay_mode.name),UVM_LOW)
      end
    end
    `endif
    //////////////////////////////////////////////////////////////////////
    $value$plusargs("dmiTmBit4Smi0=%d",k_dmiTmBit4Smi0);
    $value$plusargs("dmiTmBit4Smi2=%d",k_dmiTmBit4Smi2);
    $value$plusargs("dmiTmBit4Smi3=%d",k_dmiTmBit4Smi3);
    if(!$value$plusargs("k_dmi_qos_th_val=%0d", k_dmi_qos_th_val)) begin
      k_dmi_qos_th_val = $urandom_range(1,15);
    end
    if (clp.get_arg_value("+pmon_bw_user_bits=", arg_value)) begin
      k_pmon_bw_user_bits = arg_value.atoi();
    end
    if (clp.get_arg_value("+k_force_coh_vz=", arg_value)) begin
      k_force_coh_vz = arg_value.atoi();
    end
    if (clp.get_arg_value("+k_force_sys_vz=", arg_value)) begin
      k_force_sys_vz = arg_value.atoi();
    end
    if (clp.get_arg_value("+k_force_late_rsp=", arg_value)) begin
      k_force_late_rsp = arg_value.atoi();
    end
    if(clp.get_arg_value("+k_no_exclusives=", arg_value)) begin
      k_no_exclusives = arg_value.atobin();
    end
    if(clp.get_arg_value("+k_stimulus_debug=", arg_value)) begin
      k_stimulus_debug = arg_value.atobin();
    end
    if(clp.get_arg_value("+k_stimulus_address_debug=", arg_value)) begin
      k_stimulus_address_debug = arg_value.atobin();
    end
    if(clp.get_arg_value("+k_axi_debug=", arg_value)) begin
      k_axi_debug = arg_value.atobin();
    end
    if (clp.get_arg_value("+k_seq_timeout_max=", arg_value)) begin
      k_seq_timeout_max = arg_value.atoi();
    end
    if (clp.get_arg_value("+k_seq_delay=", arg_value)) begin
      k_seq_delay = arg_value.atoi();
    end
    if($test$plusargs("+k_alternate_be")) begin
      k_alternate_be = 1;
    end
    if($test$plusargs("+k_smi_dtw_err"))begin //FIXME-plusarg-diff-non-k
      k_smi_dtw_err = 1;
    end
    if(clp.get_arg_value("+k_random_dbad_on_dtw_req=",arg_value))begin //FIXME-plusarg-diff-non-k
      k_random_dbad_on_dtw_req = arg_value;
    end 
    else begin
      k_random_dbad_on_dtw_req = $urandom_range(0,99) < 20 ? 1 : 0;
    end
    if(k_random_dbad_on_dtw_req) begin
      `uvm_info(LABEL,"+k_random_dbad_on_dtw_req enabled. Will inject poison data",UVM_LOW)
    end
    if (clp.get_arg_value("+k_force_align_addr=", arg_value)) begin
      k_force_align_addr = arg_value.atoi();
    end
    if (clp.get_arg_value("+k_cache_warmup=", arg_value)) begin
      k_cache_warmup = arg_value.atoi();
    end
    if($test$plusargs("wrong_targ_id_cmd")) begin
      k_wrong_targ_id_cmd = 1;
      k_wrong_target_id = 1;
    end
    if($test$plusargs("wrong_targ_id_dtw")) begin
      k_wrong_targ_id_dtw_req = 1;
      k_wrong_target_id = 1;
    end
    if($test$plusargs("wrong_targ_id_rb_req")) begin
      k_wrong_targ_id_rb_req = 1;
      k_wrong_target_id = 1;
    end
    if($test$plusargs("wrong_targ_id_str_rsp")) begin
      k_wrong_targ_id_str_rsp = 1;
      k_wrong_target_id = 1;
    end
    if($test$plusargs("wrong_targ_id_dtr_rsp")) begin
      k_wrong_arg_id_dtr_rsp = 1;
      k_wrong_target_id = 1;
    end
    if($test$plusargs("wrong_targ_id_on_dtwdbg_rsp")) begin
      k_wrong_targ_id_on_dtwdbg_rsp = 1;
      k_wrong_target_id = 1;
    end
    if($test$plusargs("all_byte_enables_on"))begin
      k_all_byte_enables_on =1;
    end
    if($test$plusargs("all_internal_release"))begin
      k_all_internal_release =1;
    end
    if($test$plusargs("en_read_data_interleaving")) begin
      k_read_data_interleaving = 1;
    end
    if($test$plusargs("mntop_addr_range_max")) begin
      k_MNTOP_addr_range_max = 1;
    end
    if($test$plusargs("k_shared_c_nc_addressing")) begin
      k_shared_c_nc_addressing = 1;
      `uvm_info(LABEL,"k_shared_c_nc_addressing mode is turned ON",UVM_LOW)
    end
    if(clp.get_arg_value("k_force_ns=%s",arg_value)) begin
      k_force_ns = arg_value;
      `uvm_info(LABEL,$sformatf("k_force_ns set to %0d",k_force_ns),UVM_LOW)
    end
    if(clp.get_arg_value("k_force_exclusive=%s",arg_value)) begin
      k_force_exclusive = arg_value;
      `uvm_info(LABEL,$sformatf("k_force_exclusive set to %0d",k_force_exclusive),UVM_LOW)
    end
    if(!$test$plusargs("ex_sys_evt")) begin
       k_sys_event_disable = 1;
    end
    if($test$plusargs("k_SP_warmup")) begin
       k_SP_warmup = 1;
    end
    if($test$plusargs("sram_single_bit_err")) begin
      k_sram_single_bit_error = 1;
    end
    if($test$plusargs("sram_double_bit_err")) begin
      k_sram_double_bit_error = 1;
    end
    if($test$plusargs("sram_addr_err")) begin
      k_sram_address_error = 1;
    end
    if($test$plusargs("plru_address_error"))begin
      k_plru_error_mode = ADDRESS_ERROR;
    end
    else if($test$plusargs("plru_single_data_error"))begin
      k_plru_error_mode = SINGLE_BIT_DATA_ERROR;
    end
    else if($test$plusargs("plru_double_data_error"))begin
      k_plru_error_mode = DOUBLE_BIT_DATA_ERROR;
    end
    sram_error_test = k_sram_single_bit_error | k_sram_double_bit_error | k_sram_address_error;
    if($test$plusargs("k_reuse_addr"))begin
      k_addr_q_type = REUSE;
    end
    if($test$plusargs("ungate_wait_aiu_txn")) begin
      k_ungate_wait_aiu_txn = 1;
      `uvm_info(LABEL,"k_ungate_wait_aiu_txn is turned ON",UVM_LOW)
    end
    if($test$plusargs("waive_mission_fault_eos_check")) begin
      k_waive_mission_fault_eos_check = 1;
      `uvm_info(LABEL,"k_waive_mission_fault_eos_check is turned ON",UVM_LOW)
    end
    if($test$plusargs("k_axi_zero_delay"))begin
      k_axi_zero_delay = 1;
      `uvm_info(LABEL,"k_axi_zero_delay is turned ON",UVM_LOW)
    end
    if($test$plusargs("k_axi_long_delay"))begin
      k_axi_long_delay = 1;
      `uvm_info(LABEL,"k_axi_long_delay is turned ON",UVM_LOW)
    end
    if($test$plusargs("k_axi_rd_long_delay_only"))begin //Keep Writes Fast. Use in conjunction with +k_axi_long_delay_mode
      k_axi_wr_long_delay_en = 0;
      `uvm_info(LABEL,"k_axi_rd_long_delay_only is turned ON",UVM_LOW)
    end
    if($test$plusargs("k_axi_wr_long_delay_only"))begin //Keep Reads fast. Use in conjunction with +k_axi_long_delay_mode
      k_axi_rd_long_delay_en = 0;
      `uvm_info(LABEL,"k_axi_wr_long_delay_only is turned ON",UVM_LOW)
    end
    if($test$plusargs("k_axi_fast_first_read_beat"))begin //Fast first beat of read
      k_axi_FF_rd_beat = 1;
      `uvm_info(LABEL,"k_axi_fast_first_read_beat is turned ON",UVM_LOW)
    end
    if($test$plusargs("SMC_time_out_error_test"))begin
      k_smc_timeout_error_test = 1;
    end
    if($test$plusargs("wtt_time_out_error_test"))begin
      k_wtt_timeout_error_test = 1;
    end
    if($test$plusargs("rtt_time_out_error_test"))begin
      k_rtt_timeout_error_test = 1;
    end
    ////////////////////////////////////////////////////////////////////////////////////////////////
    get_csr_args();
    constrain_atomics();
    final_control_knobs();
  endfunction : get_plusargs

  function get_csr_args();
    //CESR--Begin
    if($test$plusargs("CESR_transport_errors")) begin
      bit[6:0] rand_inj;
      CESR_transport_errors = 1;
      if(k_wrong_target_id == 0) begin
        k_wrong_target_id = 1;
        assert(std::randomize(rand_inj) with {$countones(rand_inj)==1;})
        `uvm_info(LABEL,$sformatf("Injection vector [CmdReq,MrdReq,DtwReq,RbReq,DtrRsp,DtwDbgRsp,StrRsp]=%0b",rand_inj),UVM_LOW)
        k_wrong_targ_id_cmd = rand_inj[0] ;
        k_wrong_targ_id_mrd = rand_inj[1];
        k_wrong_targ_id_dtw_req = rand_inj[2];
        k_wrong_targ_id_rb_req = rand_inj[3];
        k_wrong_arg_id_dtr_rsp = rand_inj[4];
        k_wrong_targ_id_on_dtwdbg_rsp = rand_inj[5];
        k_wrong_targ_id_str_rsp = rand_inj[6];
      end
    end
    if($test$plusargs("CESR_skid_buffer_errors")) begin
      CESR_skid_buffer_errors = 1;
    end
    //CESR--End
  endfunction

  function get_smi_backpressure();
    if($test$plusargs("str_req_backpressure"))begin
      k_str_req_backpressure = 1;
      smi_backpressure = 1;
      `uvm_info(LABEL,"str_req_backpressure enabled",UVM_LOW)
    end
    if($test$plusargs("rbr_rsp_backpressure"))begin
      k_rbr_rsp_backpressure = 1;
      smi_backpressure = 1;
      `uvm_info(LABEL,"rbr_rsp_backpressure enabled",UVM_LOW)
    end
    if($test$plusargs("rbr_rsp_extreme_backpressure"))begin
      k_rbr_rsp_extreme_backpressure = 1;
      smi_backpressure = 1;
      `uvm_info(LABEL,"rbr_rsp_extreme_backpressure enabled",UVM_LOW)
    end
    if($test$plusargs("dtr_req_backpressure"))begin
      k_dtr_req_backpressure = 1;
      smi_backpressure = 1;
      `uvm_info(LABEL,"dtr_req_backpressure enabled",UVM_LOW)
    end
    if($test$plusargs("dtr_req_extreme_backpressure"))begin
      k_dtr_req_extreme_backpressure = 1;
      smi_backpressure = 1;
      `uvm_info(LABEL,"dtr_req_extreme_backpressure enabled",UVM_LOW)
    end
    if($test$plusargs("dtw_rsp_backpressure"))begin
      k_dtw_rsp_backpressure = 1;
      smi_backpressure = 1;
      `uvm_info(LABEL,"dtw_rsp_backpressure enabled",UVM_LOW)
    end
    if($test$plusargs("dtr_rsp_backpressure"))begin
      k_dtr_rsp_backpressure = 1;
      smi_backpressure = 1;
      `uvm_info(LABEL,"sdtr_rsp_backpressure enabled",UVM_LOW)
    end
    if($test$plusargs("sys_rsp_timeout"))begin
      k_sys_rsp_timeout = 1;
      smi_backpressure = 1;
      `uvm_info(LABEL,"sys_rsp_timeout enabled",UVM_LOW)
    end
  endfunction : get_smi_backpressure
  function legacy_args();
    if($test$plusargs("collect_resiliency_cov"))begin
      k_collect_resiliency_cov = 1;
      `uvm_info(LABEL,"collect_resiliency_cov enabled",UVM_LOW)
    end
    if($test$plusargs("expect_mission_fault"))begin
      k_expect_mission_fault = 1;
      `uvm_info(LABEL,"expect_mission_fault enabled",UVM_LOW)
    end
    if($test$plusargs("test_placeholder_connectivity"))begin
      k_test_placeholder_connectivity = 1;
      `uvm_info(LABEL,"k_test_placeholder_connectivity enabled",UVM_LOW)
    end
    if($test$plusargs("expect_mission_fault_cov"))begin
      k_expect_mission_fault_cov = 1;
      `uvm_info(LABEL,"k_expect_mission_fault_cov enabled",UVM_LOW)
    end
    if($test$plusargs("saturate_rbs_test"))begin
      k_saturate_rbs_test = 1;
      `uvm_info(LABEL,"k_saturate_rbs_test enabled",UVM_LOW)
    end
    if($test$plusargs("directed_err_test"))begin
      k_directed_err_test = 1;
      `uvm_info(LABEL,"k_directed_err_test enabled",UVM_LOW)
    end
    if($test$plusargs("dmi_mrd_only"))begin
      k_dmi_mrd_only = 1;
      `uvm_info(LABEL,"k_dmi_mrd_only enabled",UVM_LOW)
    end
    if($test$plusargs("dmi_cmo_only"))begin
      k_dmi_cmo_only = 1;
      `uvm_info(LABEL,"k_dmi_cmo_only enabled",UVM_LOW)
    end
    if($test$plusargs("dmi_rd_only"))begin
      k_dmi_rd_only = 1;
      `uvm_info(LABEL,"k_dmi_rd_only enabled",UVM_LOW)
    end
    if($test$plusargs("dmi_mrd_dtwmrgmrd_only"))begin
      k_dmi_mrd_dtwmrgmrd_only = 1;
      `uvm_info(LABEL,"k_dmi_mrd_dtwmrgmrd_only enabled",UVM_LOW)
    end
    if($test$plusargs("dmi_cohwr_only"))begin
      k_dmi_cohwr_only = 1;
      `uvm_info(LABEL,"k_dmi_cohwr_only enabled",UVM_LOW)
    end
    if($test$plusargs("dmi_ncrd_only"))begin
      k_dmi_ncrd_only = 1;
      `uvm_info(LABEL,"k_dmi_ncrd_only enabled",UVM_LOW)
    end
    if($test$plusargs("dmi_ncwr_only"))begin
      k_dmi_ncwr_only = 1;
      `uvm_info(LABEL,"k_dmi_ncwr_only enabled",UVM_LOW)
    end
    if($test$plusargs("dmi_wr_only"))begin
      k_dmi_wr_only = 1;
      `uvm_info(LABEL,"k_dmi_wr_only enabled",UVM_LOW)
    end
    if($test$plusargs("dmi_Rdwr_only"))begin
      k_dmi_Rdwr_only = 1;
      `uvm_info(LABEL,"k_dmi_Rdwr_only enabled",UVM_LOW)
    end
    if($test$plusargs("dmi_dtw_mrg_mrd_test_only"))begin
      k_dmi_dtw_mrg_mrd_test_only = 1;
      `uvm_info(LABEL,"k_dmi_dtw_mrg_mrd_test_only enabled",UVM_LOW)
    end
    if($test$plusargs("dmi_2dtw_intervention_only"))begin
      k_dmi_2dtw_intervention_only = 1;
      `uvm_info(LABEL,"k_dmi_2dtw_intervention_only enabled",UVM_LOW)
    end
    if($test$plusargs("enable_mrd_pref"))begin
      k_enable_mrd_pref = 1;
      `uvm_info(LABEL,"k_enable_mrd_pref enabled",UVM_LOW)
    end
    if($test$plusargs("enable_only_atomics"))begin
      k_enable_only_atomics = 1;
      `uvm_info(LABEL,"k_enable_only_atomics enabled",UVM_LOW)
    end
    if($test$plusargs("boot_region_access"))begin
      k_boot_region_access = 1;
      `uvm_info(LABEL,"k_boot_region_access enabled",UVM_LOW)
    end
    if($test$plusargs("tcap_scb_en"))begin
      k_tcap_scb_en = 1;
      `uvm_info(LABEL,"k_tcap_scb_en enabled",UVM_LOW)
    end
    if($test$plusargs("ex_sys_evt"))begin
      k_ex_sys_evt = 1;
      `uvm_info(LABEL,"k_ex_sys_evt enabled",UVM_LOW)
    end
    if($test$plusargs("prog_dmi_qos_th_csr"))begin
      k_prog_dmi_qos_th_csr = 1;
      `uvm_info(LABEL,"k_prog_dmi_qos_th_csr enabled",UVM_LOW)
    end
    if($test$plusargs("check_corr_error_cnt"))begin
      k_check_corr_error_cnt = 1;
      `uvm_info(LABEL,"k_check_corr_error_cnt enabled",UVM_LOW)
    end
    if($test$plusargs("test_unit_duplication"))begin
      k_test_unit_duplication = 1;
      `uvm_info(LABEL,"k_test_unit_duplication enabled",UVM_LOW)
    end
    if($test$plusargs("expect_mission_fault_cov"))begin
      k_expect_mission_fault_cov = 1;
      `uvm_info(LABEL,"k_expect_mission_fault_cov enabled",UVM_LOW)
    end
    if($test$plusargs("performance_test"))begin
      k_performance_test = 1;
      `uvm_info(LABEL,"k_performance_test enabled",UVM_LOW)
    end
    if($test$plusargs("uesr_poll_err_test"))begin
      k_uesr_poll_err_test = 1;
      `uvm_info(LABEL,"k_uesr_poll_err_test enabled",UVM_LOW)
    end
    if($test$plusargs("wait_for_empty_tt"))begin
      k_wait_for_empty_tt = 1;
      `uvm_info(LABEL,"k_wait_for_empty_tt enabled",UVM_LOW)
    end
    if($test$plusargs("upd_dmi_qos_th_csr"))begin
      k_upd_dmi_qos_th_csr = 1;
      `uvm_info(LABEL,"k_upd_dmi_qos_th_csr enabled",UVM_LOW)
    end
    if($test$plusargs("check_eos_plru_err_count"))begin
      k_check_eos_plru_err_count = 1;
      `uvm_info(LABEL,"check_eos_plru_err_count enabled",UVM_LOW)
    end
    if($test$plusargs("add_dtwMrgMrd"))begin
      k_add_dtwMrgMrd = 1;
      `uvm_info(LABEL,"k_add_dtwMrgMrd enabled",UVM_LOW)
    end
    if($test$plusargs("add_2dtw_intervention"))begin
      k_add_2dtw_intervention = 1;
      `uvm_info(LABEL,"k_add_2dtw_intervention enabled",UVM_LOW)
    end
    if($test$plusargs("dmi_atomic_test_only"))begin
      k_dmi_atomic_test_only = 1;
      `uvm_info(LABEL,"k_dmi_atomic_test_only enabled",UVM_LOW)
    end
    if($test$plusargs("add_atomic"))begin
      k_add_atomic = 1;
      `uvm_info(LABEL,"k_add_atomic enabled",UVM_LOW)
    end
  endfunction :legacy_args

  function constrain_atomics();
    atomics_disabled = ((k_cmc_policy[0] && k_cmc_policy[1]) == 0) ?  1 : 0;
    if(atomics_disabled) begin
      if(k_pattern_type inside {DMI_CMP_ATM_MATCH_p,DMI_ATM_p}) begin
        k_cmc_policy = 11;
        `uvm_info(LABEL,"Overriding k_cmc_policy to 11. Atomics require lookup and allocation enabled.",UVM_LOW)
        atomics_disabled = 0;
      end
    end
    <% if(obj.DmiInfo[obj.Id].useAtomic) { %>
    if(atomics_disabled) begin
    `uvm_info(LABEL,"Disabling atomics on this test because there is no cache",UVM_LOW)
    end
    <% } %>
  endfunction : constrain_atomics

  function final_control_knobs();
    <% if(obj.useCmc) { %>
    if(k_cache_warmup) begin
      `uvm_info(LABEL,$sformatf("Changing total commands streamed to accomodate cache warmup k_num_cmd+SET_x_WAY=%0d+%0d",k_num_cmd,SET_X_WAY),UVM_LOW)
      k_num_cmd = k_num_cmd + SET_X_WAY;
    end
    <% } %>
  endfunction : final_control_knobs
endclass
