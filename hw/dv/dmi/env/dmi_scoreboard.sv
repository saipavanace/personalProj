<% var wFUnit = obj.DmiInfo[obj.Id].interfaces.uSysIdInt.params.wFUnitIdV[0] %>

<%  var ch_rbid  = 0;
    var NcH_rbid = 0;
        ch_rbid  = obj.DmiInfo[obj.Id].cmpInfo.nDceRbEntries; 
        Nch_rbid = obj.DmiInfo[obj.Id].cmpInfo.nDmiRbEntries; 
%>
<%
if (obj.useCmc) {
    // CCP Tag and Data Array width
    var wDataNoProt = obj.DmiInfo[obj.Id].ccpParams.wData * obj.DmiInfo[obj.Id].ccpParams.nBeatsPerBank + 1 ; // 1bit of poison
    var wCacheline  = obj.DmiInfo[obj.Id].ccpParams.wAddr - obj.DmiInfo[obj.Id].ccpParams.wCacheLineOffset;
    var wTag        = wCacheline - obj.DmiInfo[obj.Id].ccpParams.PriSubDiagAddrBits.length;
    // Only add when replacement policy is NRU
    var wRP         = (((obj.DmiInfo[obj.Id].ccpParams.nWays > 1) && (obj.DmiInfo[obj.Id].ccpParams.RepPolicy !== 'RANDOM') && (obj.DmiInfo[obj.Id].ccpParams.nRPPorts === 1)) ? 1 : 0);
    var wTagNoProt  = wTag + obj.DmiInfo[obj.Id].ccpParams.wSecurity // TagWidth
                    + obj.DmiInfo[obj.Id].ccpParams.wStateBits // State
                    + wRP;
    var wDataProt = (obj.DmiInfo[obj.Id].ccpParams.DataErrInfo == "PARITYENTRY" ? 1 : (obj.DmiInfo[obj.Id].ccpParams.DataErrInfo == "SECDED" ? (Math.ceil(Math.log2(wDataNoProt + Math.ceil(Math.log2(wDataNoProt)) + 1)) + 1):0));
    var wTagProt = (obj.DmiInfo[obj.Id].ccpParams.TagErrInfo == "PARITYENTRY" ? 1 : (obj.DmiInfo[obj.Id].ccpParams.TagErrInfo == "SECDED" ? (Math.ceil(Math.log2(wTagNoProt + Math.ceil(Math.log2(wTagNoProt)) + 1)) + 1):0));


    var wDataArrayEntry = wDataNoProt + wDataProt;
    var wTagArrayEntry = wTagNoProt + wTagProt;
}
var smiQosEn = 0;
var NSMIIFTX = obj.DmiInfo[obj.Id].nSmiRx;
var NSMIIFRX = obj.DmiInfo[obj.Id].nSmiTx;
  for (var i = 0; i < NSMIIFRX; i++) {
    if(obj.DmiInfo[obj.Id].interfaces.smiTxInt[i].params.wSmiMsgQos >0){ smiQosEn = 1;}
  }
  for (var i = 0; i < NSMIIFTX; i++) {
    if(obj.DmiInfo[obj.Id].interfaces.smiRxInt[i].params.wSmiMsgQos >0){ smiQosEn = 1;}
  }
%>
`uvm_analysis_imp_decl(_smi)
`uvm_analysis_imp_decl(_smi_every_beat)

`uvm_analysis_imp_decl(_dmi_rtl_port)
`uvm_analysis_imp_decl(_dmi_tt_port)

`uvm_analysis_imp_decl(_dmi_read_probe_port)
`uvm_analysis_imp_decl(_dmi_write_probe_port)

`uvm_analysis_imp_decl(_read_addr_chnl)
`uvm_analysis_imp_decl(_read_data_chnl)
`uvm_analysis_imp_decl(_write_addr_chnl)
`uvm_analysis_imp_decl(_write_data_chnl)
`uvm_analysis_imp_decl(_write_resp_chnl)
<% if(obj.useCmc){ %>
`uvm_analysis_imp_decl( _ccp_wr_data_chnl   )
`uvm_analysis_imp_decl( _ccp_ctrl_chnl      )
`uvm_analysis_imp_decl( _ccp_fill_ctrl_chnl )
`uvm_analysis_imp_decl( _ccp_fill_data_chnl )
`uvm_analysis_imp_decl( _ccp_rd_rsp_chnl    )
`uvm_analysis_imp_decl( _ccp_evict_chnl     )
`uvm_analysis_imp_decl( _ccp_csr_maint_chnl )
<% if(obj.useCmc && obj.DmiInfo[obj.Id].ccpParams.useScratchpad){%>
`uvm_analysis_imp_decl( _ccp_sp_ctrl_chnl   )
`uvm_analysis_imp_decl( _ccp_sp_input_chnl  )
`uvm_analysis_imp_decl( _ccp_sp_output_chnl )
<% } %>
`uvm_analysis_imp_decl( _apb_chnl )
<% } %>

//Q-channel port
`uvm_analysis_imp_decl(_q_chnl)

`undef LABEL
`undef LABEL_ERROR
`define LABEL $sformatf("<%=obj.BlockId%>_SCB")
`define LABEL_ERROR $sformatf("<%=obj.BlockId%>_SCB_ERROR")

localparam NUM_BEATS_IN_DTR = ((SYS_nSysCacheline / (<%=obj.DmiInfo[obj.Id].wData%>/8)));
localparam WDPDATA          = <%=obj.DmiInfo[obj.Id].interfaces.axiInt.params.wData%>;

<% if(obj.useCmc) { %>
localparam FLUSH_BURSTLN = ((SYS_nSysCacheline / (<%=obj.DmiInfo[obj.Id].ccpParams.wData%>/8)) - 1);
localparam NUM_BEATS_IN_CACHELINE = ((SYS_nSysCacheline*8)/WCCPDATA);

typedef bit [<%=wFUnit*obj.DmiInfo[obj.Id].nAius - 1%> :0] aiu_funit_id_t;
aiu_funit_id_t                                             aiu_funit_id;

class  replay_q;
   ccp_ctrlfilldata_addr_t   replay_addr;
   ccp_ctrlfill_security_t   ns;
   bit   [WSMIMSG-1:0]       msgType;
   bit                       isCoh;
   time                      t_create;
endclass:replay_q
<% } %>

class dmi_scoreboard extends uvm_component;

  `uvm_component_param_utils(dmi_scoreboard)
  
  virtual <%=obj.BlockId%>_stall_if sb_stall_if;  // perf monitor
  exec_mon_predictor exec_mon;
  exec_mon_event_t   exmon_clear_event_q[$];
  int                sysreq_clear_evt_q[$];
  int exmon_size =  <%=obj.DmiInfo[obj.Id].nExclusiveEntries%>;

  <% if(obj.testBench=='dmi' && obj.Id == 0|| obj.testBench == 'cust_tb')  { %> 
  <%=obj.BlockId%>_concerto_register_map_pkg::ral_sys_ncore m_regs;
  <%} else if(obj.testBench == 'fsys' || obj.testBench =='emu') { %>
  concerto_register_map_pkg::ral_sys_ncore m_regs;
  <% } %>

  `ifndef FSYS_COVER_ON
  dmi_coverage           cov;
  `endif
  smi_msg_id_bit_t       Mrd_msg_id_with_DTRrsp_cmstatus_error[$];
  smi_msg_id_bit_t       DTRrsp_rmsg_id_cmstatus_error[smi_msg_id_bit_t];
  dmi_scb_txn            rtt_q[$];    
  dmi_scb_txn            wtt_q[$];    
  smi_seq_item           rbid_pkt_q[$];
  smi_seq_item           dtw_dbg_req_q[$];
  smi_seq_item           sys_evt_q[$];
  axi4_write_addr_pkt_t  wr_addr_q[$];
  axi4_write_data_pkt_t  wr_data_q[$];
  <%=obj.BlockId%>_write_probe_txn wr_arb_q[$];
  int                    allowedIntfSize[<%=obj.DmiInfo[obj.Id].nAius%>];
  int                    allowedIntfSizeActual[<%=obj.DmiInfo[obj.Id].nAius%>];
  int                    numCmd ;
  int                    numMrdTxns ;
  int                    numMrdCMOTxns ;
  int                    numDtwMrgMrdTxns ;
  int                    numNcrdTxns ;
  int                    numCmdPrefTxns ;
  int                    numNcwrTxns ;
  int                    numAtmStoreTxns ;
  int                    numAtmLdTxns ;
  int                    numDtrTxns ;
  int                    numDtwTxns ;
  int                    numRbrsReq ;
  int                    numRbrlReq ;
  int                    fillIncnt ;
  int                    obj_fillcnt ;
  int                    obj_axirdcnt ;
  int                    obj_axiwrcnt ;
  int                    obj_mntopcnt ;
  bit                    expectSysEvtTimeout;
  bit                    uncorr_tag_err;
  bit                    uncorr_data_err;
  bit                    uncorr_wrbuffer_err;
  bit                    ccp_if_en;
  bit                    addr_space_mixed;
  bit                    exclusive_flg;
  bit                    wrng_targ_id_err;
  bit                    smi_dp_last;
  event                  smi_raise;
  event                  smi_drop;
  event                  axi_wr_raise;
  event                  axi_wr_drop;
  event                  axi_rd_raise;
  event                  axi_rd_drop;
  event                  ccp_fill_raise;
  event                  ccp_atm_fill_raise, ccp_atm_fill_drop;
  event                  ccp_fill_drop;
  event                  maint_op_raise;
  event                  maint_op_drop;
  event                  check_spad_occupancy;
  //-BEGIN PERF_MONITOR------------------------------------------------------------------------------
  bit                    previous_mrd_starv_mode;
  bit                    previous_cmd_starv_mode;
  const int              max_rtt = <%=obj.DmiInfo[obj.Id].cmpInfo.nRttCtrlEntries%>;
  const int              max_wtt = <%=obj.DmiInfo[obj.Id].cmpInfo.nWttCtrlEntries%>;
  int                    rtt_skid_size;
  int                    wtt_skid_size;
  int                    real_rtt_size;
  int                    real_wtt_size;
  bit                    force_axi_stall_en;
  //-END PERF_MONITOR---------------------------------------------------------------------------------
  uvm_event_pool ev_pool = uvm_event_pool::get_global_pool();
  uvm_event evt_addr_coll  = ev_pool.get("evt_addr_coll");
  string                 spkt;

  //-For CSRs-----------------------------------------------------------------------------------------
  bit                    lookup_en;
  bit                    alloc_en;
  bit                    ClnWrAllocDisable;
  bit                    DtyWrAllocDisable;
  bit                    RdAllocDisable;
  bit                    WrAllocDisable;
  bit                   last_recycle;
  bit                   last_coh;
  int                   agent_nUnitId_q[<%=obj.DmiInfo[obj.Id].nAius%>];
  int                   k_intfsize;
  bit                   WrDataClnPropagateEn, SysEventDisable;
  bit [WSMIMSGQOS:0]    exp_eviction_qos;
  int                   dmi_rx_counter;

  //-For qaccept/transactv modeling for when RBs arrive but no DTWs------------------------------------
  int                   num_rb_waiting_on_dtw, num_dtwmrgmrd, num_dtws_early, num_dtws_early_transactv;
  time                  t_qaccept_asserted;
  //-Begin latency checking----------------------------------------------------------------------------
  typedef time          latency_q_t[$];
  <% if(obj.useCmc) { %>
  time                  latency_cmdreq_dtrreq_hit_q[$];
  time                  latency_mrdreq_dtrreq_hit_q[$];
  latency_q_t           lat_cmdreq_dtrreq_hit_q[16]; // latency per QOS
  latency_q_t           lat_mrdreq_dtrreq_hit_q[16];
  <% } %>
  time                  latency_cmdreq_axi_ar_miss_q[$];
  time                  latency_mrdreq_axi_ar_miss_q[$];
  time                  latency_cmdreq_strreq_coh_vz_q[$];
  time                  latency_dtrreq_axi_r_q[$];
  time                  latency_dtwreq_axi_aw_q[$];
  time                  latency_dtwreq_axi_w_q[$];
  time                  latency_axi_b_dtwrsp_q[$];
  time                  latency_dtwreq_dtwrsp_q[$];
  latency_q_t           lat_cmdreq_axi_ar_miss_q[16];
  latency_q_t           lat_mrdreq_axi_ar_miss_q[16];
  latency_q_t           lat_cmdreq_strreq_coh_vz_q[16];
  latency_q_t           lat_dtrreq_axi_r_q[16];
  latency_q_t           lat_dtwreq_axi_aw_q[16];
  latency_q_t           lat_dtwreq_axi_w_q[16];
  latency_q_t           lat_axi_b_dtwrsp_q[16];
  latency_q_t           lat_dtwreq_dtwrsp_q[16];
  <% if(obj.useCmc) { %>
  int                   min_latency_cmdreq_dtrreq_hit,max_latency_cmdreq_dtrreq_hit,avg_latency_cmdreq_dtrreq_hit;
  time                  min_latency_cmdreq_dtrreq_hit_q[$],max_latency_cmdreq_dtrreq_hit_q[$],avg_latency_cmdreq_dtrreq_hit_q[$];
  int                   min_latency_mrdreq_dtrreq_hit,max_latency_mrdreq_dtrreq_hit,avg_latency_mrdreq_dtrreq_hit;
  time                  min_latency_mrdreq_dtrreq_hit_q[$],max_latency_mrdreq_dtrreq_hit_q[$],avg_latency_mrdreq_dtrreq_hit_q[$];
  int                   min_lat_cmdreq_dtrreq_hit,max_lat_cmdreq_dtrreq_hit,avg_lat_cmdreq_dtrreq_hit;
  time                  min_lat_cmdreq_dtrreq_hit_q[$],max_lat_cmdreq_dtrreq_hit_q[$],lat_cmdreq_dtrreq_hit_queue[$];
  int                   min_lat_mrdreq_dtrreq_hit,max_lat_mrdreq_dtrreq_hit,avg_lat_mrdreq_dtrreq_hit;
  time                  min_lat_mrdreq_dtrreq_hit_q[$],max_lat_mrdreq_dtrreq_hit_q[$],lat_mrdreq_dtrreq_hit_queue[$];
  <% } %>
  int                   min_latency_cmdreq_axi_ar_miss,max_latency_cmdreq_axi_ar_miss,avg_latency_cmdreq_axi_ar_miss;
  time                  min_latency_cmdreq_axi_ar_miss_q[$],max_latency_cmdreq_axi_ar_miss_q[$],avg_latency_cmdreq_axi_ar_miss_q[$];
  int                   min_latency_mrdreq_axi_ar_miss,max_latency_mrdreq_axi_ar_miss,avg_latency_mrdreq_axi_ar_miss;
  time                  min_latency_mrdreq_axi_ar_miss_q[$],max_latency_mrdreq_axi_ar_miss_q[$],avg_latency_mrdreq_axi_ar_miss_q[$];
  int                   min_latency_cmdreq_strreq_coh_vz,max_latency_cmdreq_strreq_coh_vz,avg_latency_cmdreq_strreq_coh_vz;
  time                  min_latency_cmdreq_strreq_coh_vz_q[$],max_latency_cmdreq_strreq_coh_vz_q[$],avg_latency_cmdreq_strreq_coh_vz_q[$];
  int                   min_latency_dtrreq_axi_r,max_latency_dtrreq_axi_r,avg_latency_dtrreq_axi_r;
  time                  min_latency_dtrreq_axi_r_q[$],max_latency_dtrreq_axi_r_q[$],avg_latency_dtrreq_axi_r_q[$];
  int                   min_latency_dtwreq_axi_aw,max_latency_dtwreq_axi_aw,avg_latency_dtwreq_axi_aw;
  time                  min_latency_dtwreq_axi_aw_q[$],max_latency_dtwreq_axi_aw_q[$],avg_latency_dtwreq_axi_aw_q[$];
  int                   min_latency_dtwreq_axi_w,max_latency_dtwreq_axi_w,avg_latency_dtwreq_axi_w;
  time                  min_latency_dtwreq_axi_w_q[$],max_latency_dtwreq_axi_w_q[$],avg_latency_dtwreq_axi_w_q[$];
  int                   min_latency_axi_b_dtwrsp,max_latency_axi_b_dtwrsp,avg_latency_axi_b_dtwrsp;
  time                  min_latency_axi_b_dtwrsp_q[$],max_latency_axi_b_dtwrsp_q[$],avg_latency_axi_b_dtwrsp_q[$];
  int                   min_latency_dtwreq_dtwrsp,max_latency_dtwreq_dtwrsp,avg_latency_dtwreq_dtwrsp;
  time                  min_latency_dtwreq_dtwrsp_q[$],max_latency_dtwreq_dtwrsp_q[$],avg_latency_dtwreq_dtwrsp_q[$];
  time                  clk_period = <%=obj.Clocks[0].params.period%>ps;

  int                   min_lat_cmdreq_axi_ar_miss,max_lat_cmdreq_axi_ar_miss,avg_lat_cmdreq_axi_ar_miss;
  time                  min_lat_cmdreq_axi_ar_miss_q[$],max_lat_cmdreq_axi_ar_miss_q[$],lat_cmdreq_axi_ar_miss_queue[$];
  int                   min_lat_mrdreq_axi_ar_miss,max_lat_mrdreq_axi_ar_miss,avg_lat_mrdreq_axi_ar_miss;
  time                  min_lat_mrdreq_axi_ar_miss_q[$],max_lat_mrdreq_axi_ar_miss_q[$],lat_mrdreq_axi_ar_miss_queue[$];
  int                   min_lat_cmdreq_strreq_coh_vz,max_lat_cmdreq_strreq_coh_vz,avg_lat_cmdreq_strreq_coh_vz;
  time                  min_lat_cmdreq_strreq_coh_vz_q[$],max_lat_cmdreq_strreq_coh_vz_q[$],lat_cmdreq_strreq_coh_vz_queue[$];
  int                   min_lat_dtrreq_axi_r,max_lat_dtrreq_axi_r,avg_lat_dtrreq_axi_r;
  time                  min_lat_dtrreq_axi_r_q[$],max_lat_dtrreq_axi_r_q[$],lat_dtrreq_axi_r_queue[$];
  int                   min_lat_dtwreq_axi_aw,max_lat_dtwreq_axi_aw,avg_lat_dtwreq_axi_aw;
  time                  min_lat_dtwreq_axi_aw_q[$],max_lat_dtwreq_axi_aw_q[$],lat_dtwreq_axi_aw_queue[$];
  int                   min_lat_dtwreq_axi_w,max_lat_dtwreq_axi_w,avg_lat_dtwreq_axi_w;
  time                  min_lat_dtwreq_axi_w_q[$],max_lat_dtwreq_axi_w_q[$],lat_dtwreq_axi_w_queue[$];
  int                   min_lat_axi_b_dtwrsp,max_lat_axi_b_dtwrsp,avg_lat_axi_b_dtwrsp;
  time                  min_lat_axi_b_dtwrsp_q[$],max_lat_axi_b_dtwrsp_q[$],lat_axi_b_dtwrsp_queue[$];
  int                   min_lat_dtwreq_dtwrsp,max_lat_dtwreq_dtwrsp,avg_lat_dtwreq_dtwrsp;
  time                  min_lat_dtwreq_dtwrsp_q[$],max_lat_dtwreq_dtwrsp_q[$],lat_dtwreq_dtwrsp_queue[$];
  //-End latency checking------------------------------------------------------------------------------

  static bit [7:0]   port_capture_en;
  static bit         circular_buffer_en;
  static bit [2:0]   threshold_val;

  uvm_reg_data_t mirrored_value;
  uvm_reg  my_register;

  //-Begin maint-ops-----------------------------------------------------------------------------------
  dmi_scb_txn m_mntop_q[$];    
  int mntEvictIndex;
  int mntEvictWay;
  int mntWord;
  int mntOpType;
  bit mntOpArrId;
  bit mnt_PcSecAttr;
  smi_addr_t  mntEvictAddr;
  int mntEvictRange;
  int mntDataWord; // Data to be used for debugWrite
  //-End-maint-ops-------------------------------------------------------------------------------------

  smi_ncore_port_id_bit_t    dmicmdtoportId[string];

  //-Begin Scratchpad----------------------------------------------------------------------------------
  int sp_ways;
  bit sp_enabled;
  bit sp_ns;
  smi_addr_t lower_sp_addr, upper_sp_addr;
  smi_addr_t temp_addr_low,temp_addr_high,temp_addr;
  bit [<%=obj.DmiInfo[obj.Id].wAddr%>-1:0] ScPadBaseAddr_ral;
  bit create_sp_q;
  //-End Scratchpad------------------------------------------------------------------------------------
  
  smi_ns_t wtt_time_out_err_test_sec_q[$];
  smi_addr_t wtt_time_out_err_test_addr_q[$];

  //-SMI error injection statistics--------------------------------------------------------------------
  int  res_smi_corr_err   = 0;
  int  num_smi_corr_err   = 0;
  int  num_smi_uncorr_err = 0;
  int  num_smi_parity_err = 0;  // also uncorrectable

  realtime res_smi_pkt_time_old, res_smi_pkt_time_new;
  int res_mod_dp_corr_error;
  bit res_is_pre_err_pkt;

  event kill_test;
  bit [2:0] inj_cntl;
  //-Read/Write Collision arbiter----------------------------------------------------------------------
  typedef enum { 
  READ_PRIORITY = 0,
  WRITE_PRIORITY = 1} r_w_sm_e;
  r_w_sm_e r_w_SM;

  //For address translation----------------------------------------------------------------------------
  <% if ((obj.DmiInfo[obj.Id].nAddrTransRegisters > 0) && (obj.testBench != 'fsys')) { %>
  static bit [31:0] addrTransV[4];
  static bit [31:0] addrTransFrom[4];
  static bit [31:0] addrTransTo[4];
  <% } %>

  //-CSR interface handle------------------------------------------------------------------------------
  <%if (obj.testBench != "fsys") { %>
  virtual dmi_csr_probe_if u_csr_probe_vif;
  <% } %>

  <% if(obj.useCmc) { %>
  bit [N_CCP_WAYS-1:0]      rsvd_ways;
  dmi_busy_index_way_t       busy_index_way_q[$];
  dmi_fill_addr_inflight_t   filldone_pkt;
  ccp_ctrlop_waybusy_vec_t   busyway;
  ccpCacheLine               m_dmi_cache_q[$];
  ccpSPLine                  m_dmi_sp_q[$];
  int                        spad_index_occupancy[];
  replay_q                   rply_q[$];
  ccp_ctrlfill_data_t        fill_data[];
  int                        fill_data_beats[];
  ccp_data_poision_t         fill_data_poison[];

  <% if(obj.DmiInfo[obj.Id].useWayPartitioning==1) {%>
  localparam N_WAY_PART = <%=obj.DmiInfo[obj.Id].nWayPartitioningRegisters%>;
  bit way_partition_vld[<%=obj.DmiInfo[obj.Id].nWayPartitioningRegisters%>-1:0];
  bit [9:0] way_partition_reg_id[<%=obj.DmiInfo[obj.Id].nWayPartitioningRegisters%>-1:0];
  bit [<%=obj.DmiInfo[obj.Id].ccpParams.nWays%>-1:0] way_partition_reg_way[<%=obj.DmiInfo[obj.Id].nWayPartitioningRegisters%>-1:0];
  <% } %>
  <% } %>

  int rtt_entries;
  int wtt_entries;
  <% if(obj.useCmc) { %>
  bit [N_CCP_WAYS-1:0] valid_ways, victim_way, hit_way;
  <% } %>
  int dtwmrgmrd_num = 16;
  int mrd_num = 10;
  int dtrreq_num;
  int dtw_num;
  int dtw_count = <%=obj.DmiInfo[obj.Id].cmpInfo.nDceRbEntries%> + <%=obj.DmiInfo[obj.Id].cmpInfo.nDmiRbEntries%> + 1;
  bit conc9307_test;
  
  dmi_env_config    m_cfg;
  bit EN_DMI_VSEQ;
  
  uvm_event evt_start_dtws = ev_pool.get("evt_start_dtws");
  uvm_event evt_send_dtr_rsp = ev_pool.get("evt_send_dtr_rsp");
  
  axi4_read_addr_pkt_t axi4_read_addr_pkt_q[$];
  axi4_read_data_pkt_t axi4_read_data_pkt_q[$];

  uvm_event e_check_txnq_size = ev_pool.get("e_check_txnq_size");

  <% if(obj.useCmc) { %>
  int CMDREQ_DTRREQ = 13;
  int MRDREQ_DTRREQ = 12;
  int CMDREQ_AXIAR  = 7;
  int MRDREQ_AXIAR  = 6;
  int CMDREQ_STRREQ = 3;
  int DTRREQ_AXIR   = 3;
  int DTWREQ_AXIAW  = 6;
  int DTWREQ_AXIW   = 9;
  int AXIB_DTWRSP   = 4;
  int DTWREQ_DTWRSP = 4;
  <% } else { %>
  int CMDREQ_AXIAR  = 6;
  int MRDREQ_AXIAR  = 5;
  int CMDREQ_STRREQ = 3;
  int DTRREQ_AXIR   = 3;
  int DTWREQ_AXIAW  = 5;
  int DTWREQ_AXIW   = 6;
  int AXIB_DTWRSP   = 4;
  int DTWREQ_DTWRSP = 4;
  <% } %>

  uvm_objection objection;
  uvm_analysis_imp_read_addr_chnl  #(axi4_read_addr_pkt_t, dmi_scoreboard)  analysis_read_addr_port;
  uvm_analysis_imp_read_data_chnl  #(axi4_read_data_pkt_t, dmi_scoreboard)  analysis_read_data_port;
  uvm_analysis_imp_write_addr_chnl #(axi4_write_addr_pkt_t, dmi_scoreboard) analysis_write_addr_port;
  uvm_analysis_imp_write_data_chnl #(axi4_write_data_pkt_t, dmi_scoreboard) analysis_write_data_port;
  uvm_analysis_imp_write_resp_chnl #(axi4_write_resp_pkt_t, dmi_scoreboard) analysis_write_resp_port;
  <% if(obj.useCmc) { %>
  uvm_analysis_imp_ccp_wr_data_chnl   #(ccp_wr_data_pkt_t, dmi_scoreboard)   analysis_ccp_wrdata_port;
  uvm_analysis_imp_ccp_ctrl_chnl      #(ccp_ctrl_pkt_t, dmi_scoreboard)      analysis_ccp_ctrl_port;
  uvm_analysis_imp_ccp_fill_ctrl_chnl #(ccp_fillctrl_pkt_t, dmi_scoreboard)  analysis_ccp_fill_ctrl_port;
  uvm_analysis_imp_ccp_fill_data_chnl #(ccp_filldata_pkt_t, dmi_scoreboard)  analysis_ccp_fill_data_port;
  uvm_analysis_imp_ccp_rd_rsp_chnl    #(ccp_rd_rsp_pkt_t, dmi_scoreboard)    analysis_ccp_rd_rsp_port;
  uvm_analysis_imp_ccp_evict_chnl     #(ccp_evict_pkt_t, dmi_scoreboard)     analysis_ccp_evict_port;
  uvm_analysis_imp_ccp_csr_maint_chnl #(ccp_csr_maint_pkt_t, dmi_scoreboard) analysis_ccp_csr_maint_port;
  <% if(obj.useCmc && obj.DmiInfo[obj.Id].ccpParams.useScratchpad){%>
  uvm_analysis_imp_ccp_sp_ctrl_chnl   #(ccp_sp_ctrl_pkt_t, dmi_scoreboard)   analysis_ccp_sp_ctrl_port;
  uvm_analysis_imp_ccp_sp_input_chnl  #(ccp_sp_wr_pkt_t, dmi_scoreboard)     analysis_ccp_sp_input_port;
  uvm_analysis_imp_ccp_sp_output_chnl #(ccp_sp_output_pkt_t, dmi_scoreboard) analysis_ccp_sp_output_port;
  <% } %>
  uvm_analysis_imp_apb_chnl #(apb_pkt_t, dmi_scoreboard) analysis_apb_port;
  <% } %>
  uvm_analysis_imp_q_chnl #(q_chnl_seq_item , dmi_scoreboard) analysis_q_chnl_port;
  uvm_analysis_imp_smi #(smi_seq_item, dmi_scoreboard) analysis_smi;
  uvm_analysis_imp_smi_every_beat #(smi_seq_item, dmi_scoreboard) analysis_smi_every_beat;
  uvm_analysis_imp_dmi_rtl_port #(<%=obj.BlockId%>_rtl_cmd_rsp_pkt, dmi_scoreboard) analysis_dmi_rtl_port;
  uvm_analysis_imp_dmi_tt_port #(<%=obj.BlockId%>_tt_alloc_pkt, dmi_scoreboard) analysis_dmi_tt_port;
  uvm_analysis_imp_dmi_read_probe_port #(<%=obj.BlockId%>_read_probe_txn, dmi_scoreboard) analysis_dmi_read_probe_port;
  uvm_analysis_imp_dmi_write_probe_port #(<%=obj.BlockId%>_write_probe_txn, dmi_scoreboard) analysis_dmi_write_probe_port;

  function new(string name = "dmi_scoreboard", uvm_component parent = null); 
    super.new(name, parent);
    t_qaccept_asserted = $time;
    if($test$plusargs("EN_DMI_VSEQ")) begin
      EN_DMI_VSEQ = 1;
    end
    <% if(obj.useCmc) { %>
    if($test$plusargs("double_bit_tag_error_test")|| $test$plusargs("uncorr_error_test")) begin
      uncorr_tag_err  = 1; 
    end
    else begin
      uncorr_tag_err  = 0; 
    end
    if($test$plusargs("double_bit_data_error_test")|| $test$plusargs("uncorr_error_inj_test")) begin
      uncorr_data_err  = 1; 
    end
    else begin
      uncorr_data_err  = 0; 
    end
    <% } %>
    if((("<%=obj.DmiInfo[obj.Id].fnErrDetectCorrect%>" == "PARITYENTRY") && ($test$plusargs("wbuffer_single_bit_error_test") || $test$plusargs("wbuffer_multi_blk_single_bit_error_test"))) || $test$plusargs("wbuffer_double_bit_error_test") || $test$plusargs("wbuffer_multi_blk_single_double_bit_error_test") || $test$plusargs("wbuffer_multi_blk_double_bit_error_test")) begin
      uncorr_wrbuffer_err = 1;
    end
    else begin
      uncorr_wrbuffer_err = 0;
    end
    if($test$plusargs("k_coh_noncoh_collision"))begin
       addr_space_mixed = 1;
    end
    if($test$plusargs("nc_ex_test"))begin
      exclusive_flg          = 1;
    end
    else begin
      exclusive_flg          = 1;
    end
    if($test$plusargs("ccp_if_disable")) begin
      ccp_if_en = 0;  
    end
    else begin
      ccp_if_en = 1;
    end
    `ifndef FSYS_COVER_ON
     cov = new();
    `endif
    numCmd = 0;
    fillIncnt = 0;
    obj_fillcnt = 0;
    smi_dp_last = 0;
    <% for (var i = 0; i < obj.DmiInfo[obj.Id].smiPortParams.tx.length; i++) { %>
      <% for (var j = 0; j < obj.DmiInfo[obj.Id].smiPortParams.tx[i].params.fnMsgClass.length; j++) { %>
    dmicmdtoportId["<%=obj.DmiInfo[obj.Id].smiPortParams.tx[i].params.fnMsgClass[j]%>"] = <%=obj.DmiInfo[obj.Id].smiPortParams.tx[i].params.fPortId[j]%>;  //"JS Highlighter Fix
      <% } %>
    <% } %>
    <% for (var i = 0; i < obj.DmiInfo[obj.Id].smiPortParams.rx.length; i++) { %>
      <% for (var j = 0; j < obj.DmiInfo[obj.Id].smiPortParams.rx[i].params.fnMsgClass.length; j++) { %>
    dmicmdtoportId["<%=obj.DmiInfo[obj.Id].smiPortParams.rx[i].params.fnMsgClass[j]%>"] = <%=obj.DmiInfo[obj.Id].smiPortParams.rx[i].params.fPortId[j]%>; //"JS Highlighter Fix
      <% } %>
    <% } %>
    <%for( var i=0;i<obj.DmiInfo[obj.Id].nAius;i++){%>
    agent_nUnitId_q[<%=obj.AiuInfo[i].FUnitId%>]= <%=obj.AiuInfo[i].nUnitId%>;
    <%}%>
    <% if (obj.testBench != "fsys") { %>
    <% var j=0 ;for( var i=0;i<obj.DmiInfo[obj.Id].nAius;i++){%>
    `ifdef DATA_DROP
      allowedIntfSize[<%=i%>] = <%=j%>;
    `else 
      allowedIntfSize[<%=i%>] = <%=Math.log2(obj.AiuInfo[i].wData/64)%>;
    `endif
    allowedIntfSizeActual[<%=i%>] = <%=Math.log2(obj.AiuInfo[i].wData/64)%>;
    <%j++;
      if(j>2){
        j=0;
      }
    } %>
    <% } else {%>
      <% for( var i=0;i<obj.DmiInfo[obj.Id].nAius;i++){%>
    allowedIntfSize[<%=obj.AiuInfo[i].FUnitId%>] = <%=Math.log2(obj.AiuInfo[i].wData/64)%>;
      <% } %>
    <% } %>
    this.k_intfsize = 8;
    if($test$plusargs("conc9307_test")) conc9307_test = 1;
    if (exmon_size > 0) begin
      exec_mon = new();
    end

  endfunction : new

  function void initialize_knobs();
    //Get knobs
    <%if (obj.testBench != "fsys") { %>
    if(!uvm_config_db#(virtual dmi_csr_probe_if )::get(null, get_full_name(), "u_csr_probe_if",u_csr_probe_vif)) begin
       `uvm_error("NOVIF",{"virtual interface must be set  for :",get_full_name(),".vif"})
    end
    <% } %>

    <% if(obj.useCmc && obj.DmiInfo[obj.Id].useWayPartitioning==1) {%>
    if (!uvm_config_db#(aiu_funit_id_t)::get(this,
                                   .inst_name ( "" ),
                                   .field_name( "aiu_funit_id" ),
                                   .value( aiu_funit_id ))) begin
        `uvm_error( `LABEL_ERROR, "aiu_funit_id not found" )
    end
    else begin
      `uvm_info( `LABEL,$sformatf("aiu_funit_id found %0b",aiu_funit_id),UVM_MEDIUM)
    end
    <% } %>
    if(EN_DMI_VSEQ) begin
      if(!uvm_config_db#(dmi_env_config)::get(.cntxt( null ),
                                        .inst_name( get_full_name() ),
                                        .field_name( "dmi_env_config" ),
                                        .value( m_cfg ))) begin
        `uvm_error("DMI_SCB", "dmi_env_config handle not found")
      end
      //Override Interface Sizing to match transaction production values and avoid misalignments
      allowedIntfSize = m_cfg.allowedIntfSize;
      allowedIntfSizeActual = m_cfg.allowedIntfSizeActual;
      if(m_cfg.m_args.k_shared_c_nc_addressing) begin
        addr_space_mixed = 1;
      end
    end
  endfunction : initialize_knobs

  function void initialize_csr();
  <% if(obj.testBench=='dmi' && obj.Id == 0|| obj.testBench == 'cust_tb')  { %> 
        if(m_regs == null) begin
           `uvm_info(get_type_name(),"m_regs at sb is null",UVM_NONE);
        end
     <% if(obj.useCmc){%>
        if(!uncorr_wrbuffer_err) begin
          lookup_en           = m_regs.<%=obj.BlockId%>.DMIUSMCTCR.LookupEn.get();
          alloc_en            = m_regs.<%=obj.BlockId%>.DMIUSMCTCR.AllocEn.get();
          ClnWrAllocDisable   = m_regs.<%=obj.BlockId%>.DMIUSMCAPR.ClnWrAllocDisable.get();
          DtyWrAllocDisable   = m_regs.<%=obj.BlockId%>.DMIUSMCAPR.DtyWrAllocDisable.get();
          RdAllocDisable      = m_regs.<%=obj.BlockId%>.DMIUSMCAPR.RdAllocDisable.get();
          WrAllocDisable      = m_regs.<%=obj.BlockId%>.DMIUSMCAPR.WrAllocDisable.get();

     <%if(obj.useCmc && obj.DmiInfo[obj.Id].ccpParams.useScratchpad){%>
     <% if((obj.DmiInfo[obj.Id].wAddr-obj.wCacheLineOffset) > 32) {%>
          temp_addr_low       = m_regs.<%=obj.BlockId%>.DMIUSMCSPBR0.ScPadBaseAddr.get() ; 
          temp_addr_high      = m_regs.<%=obj.BlockId%>.DMIUSMCSPBR1.ScPadBaseAddrHi.get() ; 
          ScPadBaseAddr_ral   = {temp_addr_high[<%=obj.DmiInfo[obj.Id].wAddr-obj.wCacheLineOffset-33%>:0],temp_addr_low[31:0]};
          temp_addr           = ScPadBaseAddr_ral << <%=obj.wCacheLineOffset%>; 
          lower_sp_addr       = ncoreConfigInfo::gen_spad_intrlv_rmvd_addr(temp_addr,<%=obj.DmiInfo[obj.Id].nUnitId%>) >> <%=obj.wCacheLineOffset%>;
          sp_ns               = temp_addr_high[<%=obj.DmiInfo[obj.Id].wAddr-obj.wCacheLineOffset-32%>]; 
     <%}else{%>
          temp_addr_low       = m_regs.<%=obj.BlockId%>.DMIUSMCSPBR0.ScPadBaseAddr.get() ; 
          temp_addr           = temp_addr_low << <%=obj.wCacheLineOffset%>; 
          lower_sp_addr       = ncoreConfigInfo::gen_spad_intrlv_rmvd_addr(temp_addr,<%=obj.DmiInfo[obj.Id].nUnitId%>) >> <%=obj.wCacheLineOffset%>;
          sp_ns               = temp_addr_low[<%=obj.DmiInfo[obj.Id].wAddr-obj.wCacheLineOffset%>]; 
     <%}%>
          sp_ways             = m_regs.<%=obj.BlockId%>.DMIUSMCSPCR0.NumScPadWays.get()+1; 
          sp_enabled          = m_regs.<%=obj.BlockId%>.DMIUSMCSPCR0.ScPadEn.get();
     <% } %>

       <% if(obj.DmiInfo[obj.Id].useWayPartitioning==1) {%>
       <%for( var i=0;i<obj.DmiInfo[obj.Id].nWayPartitioningRegisters;i++){%>
          way_partition_vld[<%=i%>]     = m_regs.<%=obj.BlockId%>.DMIUSMCWPCR0<%=i%>.Valid.get(); 
          way_partition_reg_id[<%=i%>]  = m_regs.<%=obj.BlockId%>.DMIUSMCWPCR0<%=i%>.WpAgentId.get(); 
          way_partition_reg_way[<%=i%>] = m_regs.<%=obj.BlockId%>.DMIUSMCWPCR1<%=i%>.WpWayVector.get(); 
        <%}%>
        <%}%>
      end
     <%}%>
  <% } %>
  endfunction : initialize_csr

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    analysis_smi = new ("analysis_smi", this);
    analysis_smi_every_beat = new ("analysis_smi_every_beat", this);

    analysis_dmi_rtl_port    = new ("analysis_dmi_rtl_port", this);
    analysis_dmi_tt_port     = new ("analysis_dmi_tt_port", this);

    analysis_dmi_read_probe_port  = new ("analysis_dmi_read_probe_port", this);
    analysis_dmi_write_probe_port  = new ("analysis_dmi_write_probe_port", this);

    analysis_read_addr_port  = new ("analysis_read_addr_port", this);
    analysis_read_data_port  = new ("analysis_read_data_port", this);
    analysis_write_addr_port = new ("analysis_write_addr_port", this);
    analysis_write_data_port = new ("analysis_write_data_port", this);
    analysis_write_resp_port = new ("analysis_write_resp_port", this);
    <% if(obj.useCmc) { %>
    analysis_ccp_wrdata_port    = new("analysis_ccp_wrdata_port",this) ;
    analysis_ccp_ctrl_port      = new("analysis_ccp_ctrl_port",this) ;
    analysis_ccp_fill_ctrl_port = new("analysis_ccp_fill_ctrl_port",this) ;
    analysis_ccp_fill_data_port = new("analysis_ccp_fill_data_port",this) ;
    analysis_ccp_rd_rsp_port    = new("analysis_ccp_rd_rsp_port",this) ;
    analysis_ccp_evict_port     = new("analysis_ccp_evict_port",this) ;
    analysis_ccp_csr_maint_port = new("analysis_ccp_csr_maint_port",this) ;
    <% if(obj.useCmc && obj.DmiInfo[obj.Id].ccpParams.useScratchpad){%>
    analysis_ccp_sp_ctrl_port   = new("analysis_ccp_sp_ctrl_port",this) ;
    analysis_ccp_sp_input_port  = new("analysis_ccp_sp_input_port",this) ;
    analysis_ccp_sp_output_port = new("analysis_ccp_sp_output_port",this) ;
    <% } %>
    analysis_apb_port = new("analysis_apb_port",this) ;
    <% } %>
    analysis_q_chnl_port = new("analysis_q_chnl_port",this);
   
    // perf monitor:Bound stall_if Interface
    if (!uvm_config_db#(virtual <%=obj.BlockId%>_stall_if)::get(null, "", "<%=obj.BlockId%>_m_top_stall_if", sb_stall_if)) begin
     `uvm_fatal("dmi_scoreboard", "Virtual interface must be set for stall_if");
    end
  endfunction : build_phase

  function void report_phase(uvm_phase phase);
    if($test$plusargs("pref_test"))begin
      calculate_min_max_avg_latency();
    end
    if($test$plusargs("report_qos_latency"))begin
      calculate_min_max_avg_latency_per_qos();
    end
    if(sys_evt_q.size() != 0 && !$test$plusargs("sys_rsp_timeout")) begin
      `uvm_error({"sys_evt_check_",get_name()},$sformatf("sys_evt_q is not empty size=%0d", sys_evt_q.size()))
    end
    <% if(obj.testBench == "dmi") { %>
    //#Check.DMI.SysReqOnExClear
    if((exmon_clear_event_q.size() != sysreq_clear_evt_q.size()) && (exmon_size >0) && !$test$plusargs("sys_rsp_timeout")) begin
      `uvm_error({"sys_evt_check_",get_name()},$sformatf("Exclusive monitor clear events predicted and received mismatch. (exp=%0d, rcvd=%0d)",exmon_clear_event_q.size,sysreq_clear_evt_q.size))
    end
    <% } %>
    <% if(obj.useResiliency) { %>
    `uvm_info($sformatf("%m"), $sformatf("Error Injection: corr=%0d, uncorr=%0d, parity=%0d", num_smi_corr_err, num_smi_uncorr_err, num_smi_parity_err), UVM_LOW)
    <% } %>
    <% if ((obj.useResiliency) && (obj.testBench != "fsys")) { %>
    if($test$plusargs("expect_mission_fault")) begin
      if (u_csr_probe_vif.fault_mission_fault == 0) begin
        `uvm_error({"fault_injector_checker_",get_name()},
                     $sformatf({"expect_mission_fault argument is passed from command line & observed mission_fault=%0d"},
                     u_csr_probe_vif.fault_mission_fault))
      end else begin
        `uvm_info(get_name(),
                  $sformatf({"expect_mission_fault argument is passed from command line & observed mission_fault=%0d"},
                  u_csr_probe_vif.fault_mission_fault),UVM_LOW)
      end
    end
    <% } %>

    //#Check.DMI.Concerto.v3.0.DmiunitId  
    //Check interrupt for regular tests 
    <% if (obj.testBench != "fsys") { %>
    if(!(($test$plusargs("k_dir_error_test") || wrng_targ_id_err || uncorr_tag_err || uncorr_data_err || uncorr_wrbuffer_err || 
          $test$plusargs("err_interrupt_check_ignore") || u_csr_probe_vif.dmi_corr_uncorr_flag))) begin
      if(!u_csr_probe_vif.check_irqc && !u_csr_probe_vif.check_irquc) begin
         `uvm_info("INTR_INJ",$sformatf("Interrupt is not been passed for corrected = %0d or uncorrected = %0d",u_csr_probe_vif.check_irqc , u_csr_probe_vif.check_irquc),UVM_LOW);
      end else begin
        `uvm_error("INTR_INJ",$sformatf({"Interrupt has been passed for corrected = %0d or uncorrected = %0d "},u_csr_probe_vif.check_irqc,u_csr_probe_vif.check_irquc));
      end
    end else begin
      `uvm_info("ERR_INJ",$sformatf("Error Test has been implemented"),UVM_LOW)
    end
    <% } %>
  endfunction : report_phase

  <% if(obj.useCmc){ %>
  extern function void      set_word_tag_array  (int set, int way, bit[5:0] word, bit[31:0] worddata);
  extern function void      set_word_data_array (int set, int way, bit[5:0] word, bit[31:0] worddata);
  extern function bit[31:0] get_word_tag_array  (int set, int way, bit[5:0] word);
  extern function bit[31:0] get_word_data_array (int set, int way, int beat, int word);
  extern function bit[<%=wTag-1%>:0] get_tag_from_cacheline (bit[<%=wCacheline-1%>:0] cacheline);
  extern function bit[<%=wCacheline-1%>:0] get_cacheline_from_tag (bit[<%=wTag-1%>:0] tag, bit[<%=obj.DmiInfo[obj.Id].ccpParams.PriSubDiagAddrBits.length-1%>:0] index);
  <% } %>

  extern function void calculate_dmi_latency_data(int idx, string queue_type);
  extern function void calculate_dmi_latency_data_per_qos(int idx, string queue_type);
  extern function void calculate_min_max_avg_latency();
  extern function void calculate_min_max_avg_latency_per_qos();
  extern function void check_latency_with_expected_values();
  extern function void update_rx_counter();
  extern function void write_smi(smi_seq_item m_pkt);
  extern function void write_smi_every_beat(smi_seq_item m_pkt);

  extern function void write_dmi_rtl_port(<%=obj.BlockId%>_rtl_cmd_rsp_pkt m_pkt);
  extern function void write_dmi_tt_port(<%=obj.BlockId%>_tt_alloc_pkt m_pkt);

  extern function void write_dmi_read_probe_port(<%=obj.BlockId%>_read_probe_txn pkt);
  extern function void write_dmi_write_probe_port(<%=obj.BlockId%>_write_probe_txn pkt);

  extern function void write_read_addr_chnl(axi4_read_addr_pkt_t m_pkt);
  extern function void write_read_data_chnl(axi4_read_data_pkt_t m_pkt);
  extern function void write_write_addr_chnl(axi4_write_addr_pkt_t m_pkt);
  extern function void write_write_data_chnl(axi4_write_data_pkt_t m_pkt);
  extern function void write_write_resp_chnl(axi4_write_resp_pkt_t m_pkt);

  <% if(obj.useCmc) { %>
  extern function void delete_mnt_op_cache_line(ccp_ctrl_pkt_t m_packet);
  extern function void add_mnt_op_cache_line(dmi_scb_txn txn);
  extern function void write_ccp_wr_data_chnl   ( ccp_wr_data_pkt_t    m_pkt  ) ;
  extern function void write_ccp_ctrl_chnl      ( ccp_ctrl_pkt_t       m_pkt  ) ;
  extern function void write_ccp_fill_ctrl_chnl ( ccp_fillctrl_pkt_t   m_pkt  ) ;
  extern function void write_ccp_fill_data_chnl ( ccp_filldata_pkt_t   m_pkt  ) ;
  extern function void write_ccp_rd_rsp_chnl    ( ccp_rd_rsp_pkt_t     m_pkt  ) ;
  extern function void write_ccp_evict_chnl     ( ccp_evict_pkt_t      m_pkt  ) ;
  extern function void write_ccp_csr_maint_chnl ( ccp_csr_maint_pkt_t  m_pkt  ) ;
  extern function void write_apb_chnl      ( apb_pkt_t            m_pkt  ) ;

  extern function void process_atomic_op(ref dmi_scb_txn txn,input int idx, bit ScratchPad = 0);
  extern function ccp_ctrlop_waybusy_vec_t get_busy_way(ccp_ctrlop_addr_t addr);  
  extern function void update_index_way(dmi_fill_addr_inflight_t  filldone_pkt,bit set_flg);
  extern function bit [N_WAY-1:0] onehot_to_binary(bit [N_WAY-1:0] in_word);
  extern function void create_exp_fillCtrl(ccp_ctrl_pkt_t cache_ctrl_pkt,ref dmi_scb_txn scb_pkt);
  extern function axi_axaddr_t shift_addr(
                       input axi_axaddr_t in_addr
                       );

  extern function void convert_axi_to_fill_data( 
                      ref dmi_scb_txn scb_pkt,
                      output ccp_ctrlfill_data_t fill_data[],
                      output int                 fill_data_beats[],
                      output ccp_data_poision_t  fill_data_poison[]
                      );

  extern function void convert_dtw_to_ccp_data( 
                       dmi_scb_txn scb_pkt,
                       output ccp_ctrlwr_data_t         ccp_data[],
                       output int                       ccp_data_beat[],
                       output ccp_data_poision_t        fill_data_poison[]
                       );
  extern function void processCacheRd(ccp_ctrl_pkt_t cache_ctrl_pkt);
  extern function void processMaintop(ccp_ctrl_pkt_t cpy_pkt);
  extern function void update_raw_dependency(smi_addr_t m_addr);
  extern function void processCacheWr(ccp_ctrl_pkt_t cache_ctrl_pkt);
  extern function void processCacheWrData(ccp_wr_data_pkt_t cache_wr_data);
  extern function void processCacheRdRsp(ccp_rd_rsp_pkt_t cache_rd_rsp);
  extern function void processRdrspAddr(ccp_ctrl_pkt_t cache_ctrl_pkt,smi_qos_t smi_qos=0,dmi_scb_txn txn = null);
  //extern function void processRdrspWrData(ccp_rd_rsp_pkt_t cache_rdrsp_data);
  extern function void processEvictAddr(ccp_ctrl_pkt_t cache_ctrl_pkt);
  extern function void processEvictData(ccp_evict_pkt_t cache_evict_data);
  extern function void processCacheFillCtrl(ccp_fillctrl_pkt_t cache_fill_ctrl);
  extern function void processCacheFillData(ccp_filldata_pkt_t cache_fill_data);
  extern function void processApbReq(apb_pkt_t apb_entry);
  <% } %>
  <% if(obj.useCmc && obj.DmiInfo[obj.Id].ccpParams.useScratchpad){%>
  extern task create_SP_q();
  extern function void write_ccp_sp_ctrl_chnl(ccp_sp_ctrl_pkt_t    m_pkt);
  extern function void write_ccp_sp_input_chnl(ccp_sp_wr_pkt_t      m_pkt);
  extern function void write_ccp_sp_output_chnl(ccp_sp_output_pkt_t  m_pkt);
  extern function void processSPCtrl(ccp_sp_ctrl_pkt_t sp_ctrl_entry);
  extern function void processSPCtrlWr(dmi_scb_txn matched_entry);
  extern function void processSPCtrlRd(dmi_scb_txn matched_entry);
  extern function void processSPWr(ccp_sp_wr_pkt_t sp_wr_entry);
  extern function void processSPWrTxn(dmi_scb_txn matched_entry);
  extern function void processSPOutput(ccp_sp_output_pkt_t sp_rd_entry);
  <% } %>
  extern function void write_q_chnl(q_chnl_seq_item m_pkt) ;
  extern function void compute_pma_exceptions(time t_last_asserted);
  extern function void processMrdReq(smi_seq_item mrd_req_pkt,bit isDtwMrgMrd = 0,dmi_scb_txn scb_pkt = null);
  extern function void processMrdRsp(smi_seq_item mrd_rsp_pkt);
  extern function void processDtrReq(smi_seq_item dtr_req_pkt);
  extern function void processDtrRsp(smi_seq_item dtr_rsp_pkt);
  extern function void processDtwReq(smi_seq_item dtw_req_pkt);
  extern function void processDtwRsp(smi_seq_item dtw_rsp_pkt);
  extern function void processDtwDbgReqMsg(smi_seq_item dtw_dbg_req_pkt);
  extern function void processDtwDbgRspMsg(smi_seq_item dtw_dbg_rsp_pkt);
  extern function void processRbReq(smi_seq_item rb_req_pkt);
  extern function void processRbRsp(smi_seq_item rb_rsp_pkt);
  extern function void processCmdReq(smi_seq_item cmd_req_pkt);
  extern function void processCmdRsp(smi_seq_item cmd_rsp_pkt);
  extern function void processStrReq(smi_seq_item str_req_pkt);
  extern function void processStrRsp(smi_seq_item str_rsp_pkt);
  extern function void processSysReq(smi_seq_item pkt);
  extern function void processSysRsp(smi_seq_item pkt);
  extern function void processArChnl(axi4_read_addr_pkt_t m_pkt);
  extern function void processRChnl(axi4_read_data_pkt_t m_pkt);
  extern function void processAwChnl(axi4_write_addr_pkt_t m_pkt);
  extern function void processWChnl(axi4_write_data_pkt_t m_pkt);
  extern function void processBChnl(axi4_write_resp_pkt_t m_pkt);
  extern function void updateRttentry(dmi_scb_txn txn,int idx);
  extern function void updateWttentry(dmi_scb_txn txn,int idx);
  extern function void updateWttOnIntRbRelease(int idx, smi_seq_item m_pkt, string label, int line);
  extern function void updateWttOnRbReq(int idx_q[$], smi_seq_item m_pkt, string label, int line);
  extern function bit isDtwMsg(smi_msg_type_logic_t msgType);
  extern function bit isCmdNcWrMsg(smi_msg_type_logic_t msgType);
  extern function bit isAtomicMsg(smi_msg_type_logic_t msgType);
  extern function bit isdtwmrgmrd(smi_msg_type_logic_t msgType);
  extern function bit isCohCmd(MsgType_t msgType);
  extern function bit isNcCohCmd(MsgType_t msgType);
  extern function void print_rtt_q();
  extern function bit  print_rtt_q_eos();
  extern function void print_wtt_q();
  extern function bit  print_wtt_q_eos();
  extern function print_pending_txns(input bit trigger_from_error=0);
  extern function enforce_unique_rbids();
  extern function clear_pending_rb_release();
  extern function void MrgMrddata(ref dmi_scb_txn scb_txn);
  <% if(obj.useCmc) { %>
  extern function int calBurstLength(dmi_scb_txn sb_entry);
  extern function int isWeirdWrap(dmi_scb_txn sb_entry);
  <% } %>
  extern function void   merge_mw_data(input  int index);
  extern function void   rearrangedtwdata(ref dmi_scb_txn scb_txn);
  extern function void   rearrangedtrdata(ref dmi_scb_txn scb_txn);
  extern function smi_addr_t axi4_addr_trans_addr( smi_addr_t smi_addr );
  //extern function smi_seq_item  expecdtrpkt(smi_seq_item dp_req_pkt);
  extern virtual function void update_resiliency_ce_cnt(const ref smi_seq_item m_item);
  <% if (obj.useCmc) { %>
  extern function void merge_write_data(
                       input  int index,
                       input  smi_seq_item  dtw_req_pkt,           
                       input  bit   SV
                       );

  <% } %>
  task run_phase(uvm_phase phase);
    <% if ((obj.useResiliency) && (obj.testBench != "fsys")) { %>
    bit test_unit_duplication_uecc;
    <% } %>
    super.run_phase(phase);
    objection = phase.get_objection();
    if (! $value$plusargs("inj_cntl=%d", inj_cntl)) begin
       inj_cntl = 0;
    end
    initialize_knobs();
    fork
      <% if(obj.useCmc && obj.DmiInfo[obj.Id].ccpParams.useScratchpad){%>
      begin
        wait(check_spad_occupancy.triggered);
       `uvm_info("<%=obj.BlockId%>_scb", $sformatf("Scratchpad checking for occupancy SP Ways:%0d Size:%0d", sp_ways, spad_index_occupancy.size()),UVM_LOW)
        if(sp_ways !=0) begin
          do begin
            #500ns;
            `uvm_info("<%=obj.BlockId%>_scb", $sformatf("Scratchpad checking for occupancy Occupancy:%0d Size:%0d", (spad_index_occupancy.sum with (int'(item))),spad_index_occupancy.size()),UVM_LOW)
          end while((spad_index_occupancy.sum with (int'(item))) != spad_index_occupancy.size());
          `uvm_info("<%=obj.BlockId%>_scb", $sformatf("Scratchpad occupancy hit %0d(size=%0d)",(spad_index_occupancy.sum with (int'(item))), spad_index_occupancy.size()),UVM_LOW)
          `ifndef FSYS_COVER_ON
          cov.collect_sp_occupancy(1);
          `endif
        end
      end
      <% }%>
      <% if( (obj.strProjectName != 'hw_config_22') && ((obj.testBench=='dmi' && obj.Id == 0)| obj.testBench == 'cust_tb'||obj.testBench == 'fsys' || obj.testBench =='emu')) { %>
      begin //RAL mirrored value
       #3500ns;
       if(m_regs == null) begin
           `uvm_info(get_type_name(),"m_regs at sb is null",UVM_LOW);
       end
       my_register = m_regs.get_reg_by_name("DMIUUELR0");
       mirrored_value = my_register.get_mirrored_value();
       `uvm_info("SB",$sformatf("The mirrored value in SB of DMIUUELR0 is %0h",mirrored_value),UVM_LOW)
      end 
      <% } %>
      begin
         forever begin
           @smi_raise;
           phase.raise_objection(this, "Raise smi objection in DMI scb");
         end
      end
      begin
         forever begin
            @smi_drop;
           phase.drop_objection(this, "Drop smi objection in DMI scb");
         end
      end
      begin
         forever begin
            @axi_wr_raise;
            phase.raise_objection(this, "Raise axi wr objection in DMI scb");
            obj_axiwrcnt++;
         end
      end
      begin
         forever begin
            @axi_wr_drop;
            phase.drop_objection(this, "Drop axi wr objection in DMI scb");
            obj_axiwrcnt--;
         end
      end
      begin
         forever begin
            @axi_rd_raise;
            phase.raise_objection(this, "Raise axi rd slv objection in DMI scb");
            obj_axirdcnt++;
         end
      end
      begin
         forever begin
            @axi_rd_drop;
            phase.drop_objection(this, "Drop axi rd objection in DMI scb");
            obj_axirdcnt--;
         end
      end
      begin
         forever begin
            @ccp_fill_raise;
            phase.raise_objection(this, "Raise ccp fill objection in DMI scb");
            obj_fillcnt++;
         end
      end
      begin
         forever begin
            @ccp_atm_fill_raise;
            phase.raise_objection(this, "Raise atm ccp fill objection in DMI scb");
            obj_fillcnt++;
         end
      end
      begin
         forever begin
            @ccp_atm_fill_drop;
            phase.drop_objection(this, "Drop atm ccp fill objection in DMI scb");
            obj_fillcnt--;
         end
      end

      begin
         forever begin
            @ccp_fill_drop;
            phase.drop_objection(this, "Drop ccp fill objection in DMI scb");
            obj_fillcnt--;
         end
      end
      begin
         forever begin
            @maint_op_raise;
            phase.raise_objection(this, "Raise maint op objection in DMI scb");
            obj_mntopcnt++;
         end
      end
      begin
         forever begin
            @maint_op_drop;
            phase.drop_objection(this, "Drop maint op objection in DMI scb");
            obj_mntopcnt--;
         end
      end
      begin
         forever begin:addr_collision
            evt_addr_coll.wait_trigger();
            sb_stall_if.perf_count_events["Address_Collisions"].push_back(1); 
         end
      end
      // END PERF MONITOR 
    join_none

    `uvm_info($sformatf("%m"), $sformatf("useRsiliency=%0d, testBenchName=%s", <%=obj.useResiliency%>, "<%=obj.testBench%>"), UVM_LOW)
    <% if ((obj.useResiliency) && (obj.testBench != "fsys")) { %>
    if ($test$plusargs("expect_mission_fault")) begin
    fork
      if(!$test$plusargs("test_unit_duplication")) begin
        begin
          forever begin
             #(100*1ns);
             if (u_csr_probe_vif.fault_mission_fault == 0) begin
                @u_csr_probe_vif.fault_mission_fault;
             end
             #(500*1ns);  // make sure enough time elapsed so we can ensure the errored request is dropped
             `uvm_info($sformatf("%m"), $sformatf("<%=obj.BlockId%> saw mission fault. Kill test"), UVM_LOW)
             -> kill_test;   // otherwise the test will hang and timeout
             `uvm_info($sformatf("%m"), $sformatf("<%=obj.BlockId%> saw mission fault. Jump to report phase"), UVM_LOW)
             phase.jump(uvm_report_phase::get());
          end
        end
      end else begin
        begin
          forever begin
            #(100*1ns);
            uvm_config_db#(bit)::wait_modified(this, "", "test_unit_duplication_uecc");
            `uvm_info(get_name(), "modified value of test_unit_duplication_uecc", UVM_LOW)
            uvm_config_db#(bit)::get(this, "", "test_unit_duplication_uecc", test_unit_duplication_uecc);
            if(test_unit_duplication_uecc) begin
              if(u_csr_probe_vif.fault_mission_fault == 0) begin
                 @u_csr_probe_vif.fault_mission_fault;
              end
              #(500*1ns);  // make sure enough time elapsed so we can ensure the errored request is dropped
              `uvm_info($sformatf("%m"), $sformatf("<%=obj.BlockId%> saw mission fault. Kill test"), UVM_LOW)
              -> kill_test;   // otherwise the test will hang and timeout
              `uvm_info($sformatf("%m"), $sformatf("<%=obj.BlockId%> saw mission fault. Jump to report phase"), UVM_LOW)
              phase.jump(uvm_report_phase::get());
            end
          end
        end
      end
    join_none
    end
    <% } %>
     
    `uvm_info($sformatf("%m"), $sformatf(" testBenchName=%s",  "<%=obj.testBench%>"), UVM_LOW)
    // Check interrupt for regular tests    
    <% if (obj.testBench != "fsys") { %>
    if (!($test$plusargs("k_dir_error_test") || wrng_targ_id_err || uncorr_tag_err || uncorr_data_err || uncorr_wrbuffer_err  || $test$plusargs("err_interrupt_check_ignore"))) begin
    fork
      begin
        forever begin
          @(posedge u_csr_probe_vif.clk);
          if (u_csr_probe_vif.check_irqc == 1) begin 
            @u_csr_probe_vif.IRQ_C;
            `uvm_info($sformatf("%m"), $sformatf("<%=obj.BlockId%> saw mission fault. Kill test"), UVM_LOW)
            -> kill_test;   // otherwise the test will hang and timeout
            `uvm_info($sformatf("%m"), $sformatf("<%=obj.BlockId%> saw mission fault. Jump to report phase"), UVM_LOW)
            phase.jump(uvm_report_phase::get());
          end
          if (u_csr_probe_vif.check_irquc == 1) begin 
            @u_csr_probe_vif.IRQ_UC;
            `uvm_info($sformatf("%m"), $sformatf("<%=obj.BlockId%> saw mission fault. Kill test"), UVM_LOW)
            -> kill_test;   // otherwise the test will hang and timeout
            `uvm_info($sformatf("%m"), $sformatf("<%=obj.BlockId%> saw mission fault. Jump to report phase"), UVM_LOW)
            phase.jump(uvm_report_phase::get());
          end             
        end
      end
    join_none
    end
    <% } %>
  endtask : run_phase////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  <%if (obj.DmiInfo[obj.Id].fnEnableQos) { %>
  function int  got_entry_asper_qos(bit isCoh,bit isRd,int indx =0); 
    int idx,tmp_q[$], tmp_q0[$];
    bit [15:0] prio;
    idx = 0;
    if(isRd)begin
      if(isCoh)begin
        <% if(obj.DmiInfo[obj.Id].concMuxMsgParams.rx.mrdReq.enablePipe == 1) {%>
        tmp_q0  = rtt_q.find_index with ((item.isMrd) &&
                                         (item.MRD_req_recd_rtl == 0)&&
                                         (item.t_creation < ($time-10)));
        if(tmp_q0.size() == 1) begin
           tmp_q  = rtt_q.find_index with ((item.isMrd) &&
                                           (item.t_creation < ($time-10)) &&
                                           (item.MRD_req_recd_rtl == 0));
        end
        else begin
           tmp_q  = rtt_q.find_index with ((item.isMrd) && 
                                        (item.t_creation < ($time-1010)) &&
                                        (item.MRD_req_recd_rtl == 0));
        end
        <% } else {%>
        tmp_q  = rtt_q.find_index with ((item.isMrd) && 
                                        (item.t_creation < ($time-10)) &&
                                       (item.MRD_req_recd_rtl == 0));
        <% } %>
      end
      else begin
        <% if(obj.DmiInfo[obj.Id].concMuxMsgParams.rx.cmdReq.enablePipe == 1) {%>
        tmp_q0  = rtt_q.find_index with ((item.isNcRd || item.isCmdPref || item.isAtomic) && 
                                        (item.t_creation < ($time-10)) &&
                                        (item.CMD_rsp_recd_rtl == 0));
        if(tmp_q0.size() == 1) begin
           tmp_q  = rtt_q.find_index with ((item.isNcRd || item.isCmdPref || item.isAtomic) &&
                                           (item.t_creation < ($time-10)) &&
                                           (item.CMD_rsp_recd_rtl == 0));
        end
        else begin
          tmp_q  = rtt_q.find_index with ((item.isNcRd || item.isCmdPref || item.isAtomic) &&
                                         (item.t_creation < ($time-1010)) &&
                                         (item.CMD_rsp_recd_rtl == 0));
        end
        <% } else { %>
          tmp_q  = rtt_q.find_index with ((item.isNcRd || item.isCmdPref || item.isAtomic) &&
                                           (item.t_creation < ($time-10)) &&
                                           (item.CMD_rsp_recd_rtl == 0));
        <% } %>
      end

      if(tmp_q.size()>1)begin
        if(isCoh)begin
          prio =  ncoreConfigInfo::qos_mapping(rtt_q[indx].smi_qos);
          idx  = indx;
        end
        else begin
          prio =  ncoreConfigInfo::qos_mapping(rtt_q[tmp_q[0]].smi_qos);
          idx = tmp_q[0];
        end
        foreach(tmp_q[i])begin
          if(prio > ncoreConfigInfo::qos_mapping(rtt_q[tmp_q[i]].smi_qos))begin
              prio =  ncoreConfigInfo::qos_mapping(rtt_q[tmp_q[i]].smi_qos);
              idx = tmp_q[i];
          end
        end
      end
      else begin
        if(isCoh)begin
          idx = indx;
        end
        else begin
          idx = tmp_q[0];
        end
      end
    end
    else begin
       if(!isCoh)begin
         <% if(obj.DmiInfo[obj.Id].concMuxMsgParams.rx.cmdReq.enablePipe == 1) {%>
         tmp_q0  = wtt_q.find_index with ((item.isNcWr) &&
                                        (item.t_creation < ($time-10)) &&
                                        (item.CMD_rsp_recd_rtl == 0));
         if(tmp_q0.size() == 1) begin
            tmp_q  = wtt_q.find_index with ((item.isNcWr) &&
                                            (item.t_creation < ($time-10)) &&
                                            (item.CMD_rsp_recd_rtl == 0));
         end
         else begin
            tmp_q  = wtt_q.find_index with ((item.isNcWr) &&
                                            (item.t_creation < ($time-1010)) &&
                                            (item.CMD_rsp_recd_rtl == 0));
         end
         <% } else {%>
         tmp_q  = wtt_q.find_index with ((item.isNcWr) && 
                                         (item.t_creation < ($time-10)) &&
                                        (item.CMD_rsp_recd_rtl == 0));
        <% } %>
         if(tmp_q.size()>1)begin
           prio =  ncoreConfigInfo::qos_mapping(wtt_q[tmp_q[0]].smi_qos);
           idx = tmp_q[0];
           foreach(tmp_q[i])begin
             if(prio > ncoreConfigInfo::qos_mapping(wtt_q[tmp_q[i]].smi_qos))begin
             //  if(!((beat_aligned(wtt_q[tmp_q[i]].cache_addr) == beat_aligned(wtt_q[idx].cache_addr)) && (wtt_q[tmp_q[i]].security == wtt_q[idx].security) && (wtt_q[tmp_q[i]].cmd_src_unit_id == wtt_q[idx].cmd_src_unit_id)))begin
                 prio =  ncoreConfigInfo::qos_mapping(wtt_q[tmp_q[i]].smi_qos);
                 idx = tmp_q[i];
             //  end
             end
           end
         end
         else begin
           idx = tmp_q[0];
         end
       end
    end

    return(idx);
  endfunction : got_entry_asper_qos//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  <% } %>

  function smi_addr_t cl_aligned(smi_addr_t addr);
    smi_addr_t cl_aligned_addr;
    cl_aligned_addr = (addr >> $clog2(SYS_nSysCacheline));
    return cl_aligned_addr;
  endfunction : cl_aligned///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  function string smi_type_string(smi_type_t msg_type);
    smi_msg_type_e _type;
    string _s, _sfx;
    _type = smi_msg_type_e'(msg_type);
    _sfx  = $sformatf("%0s",_type.name);
    _s    = _sfx.substr(0,_sfx.len()-3);
    return(_s);
  endfunction : smi_type_string//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  function bit size_aligned(smi_addr_t addr,bit [2:0] axsize, bit [7:0] axlen);
    bit aligned = 0;
    int txn_size;

    if(2**axsize >= WDPDATA/8 )begin
      aligned =  (addr[$clog2(WDPDATA/8)-1:0] == 0);
    end
    else  begin
      aligned = 1;
    end

    return(aligned);
  endfunction : size_aligned/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  function smi_addr_t beat_aligned(smi_addr_t addr);
    smi_addr_t beat_aligned_addr;
    beat_aligned_addr = (addr >> $clog2(WDPDATA/8));
    return beat_aligned_addr;
  endfunction : beat_aligned/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  function int security_match(smi_security_t sec1, smi_security_t sec2);
    if(sec1 === sec2) begin
      return 1;
    end else begin
      return 0;
    end
  endfunction : security_match///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  function smi_addr_t isSpAddr(smi_addr_t addr);
    smi_addr_t cl_aligned_addr;
     if(  sp_enabled 
       && (cl_aligned(ncoreConfigInfo::gen_spad_intrlv_rmvd_addr(addr,<%=obj.DmiInfo[obj.Id].nUnitId%>)) >= lower_sp_addr) 
       && (cl_aligned(ncoreConfigInfo::gen_spad_intrlv_rmvd_addr(addr,<%=obj.DmiInfo[obj.Id].nUnitId%>)) <= upper_sp_addr)) begin
      return 1;
    end
    else begin
      return 0;
    end
  endfunction: isSpAddr//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  function bit isReadMsg(smi_msg_type_bit_t _type);
    return ( _type inside {CMD_RD_CLN,CMD_RD_NC,[MRD_RD_CLN:MRD_PREF],CMD_RD_ATM,CMD_WR_ATM,CMD_SW_ATM,CMD_CMP_ATM});
  endfunction : isReadMsg
  ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  // Function to find oldest entry in the rtt queue with certain criteria
  ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  function int find_oldest_entry_in_rtt_q (int m_tmp_q[$]);
      time t_tmp_time;
      int  m_tmp_indx;
      t_tmp_time = rtt_q[m_tmp_q[0]].t_creation;
      m_tmp_indx = m_tmp_q[0];
      for (int i = 1; i < m_tmp_q.size(); i++) begin
          if (t_tmp_time > rtt_q[m_tmp_q[i]].t_creation) begin
              t_tmp_time = rtt_q[m_tmp_q[i]].t_creation;
              m_tmp_indx = m_tmp_q[i];
          end
          // Sanity check below
          else if (t_tmp_time === rtt_q[m_tmp_q[i]].t_creation) begin
              rtt_q[m_tmp_indx].print_entry();
              rtt_q[i].print_entry();
              `uvm_error(`LABEL_ERROR, $sformatf("Above two transactions cannot have same creation time"))
          end
      end
      return m_tmp_indx;
  endfunction : find_oldest_entry_in_rtt_q///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  // Function to find oldest entry in the wtt queue with certain criteria
  ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  function int find_oldest_entry_in_wtt_q (int m_tmp_q[$]);
      time t_tmp_time;
      int  m_tmp_indx;
      t_tmp_time = wtt_q[m_tmp_q[0]].t_creation;
      m_tmp_indx = m_tmp_q[0];
      for (int i = 1; i < m_tmp_q.size(); i++) begin
          if (t_tmp_time > wtt_q[m_tmp_q[i]].t_creation) begin
              t_tmp_time = wtt_q[m_tmp_q[i]].t_creation;
              m_tmp_indx = m_tmp_q[i];
          end
          // Sanity check below
          else if (t_tmp_time === wtt_q[m_tmp_q[i]].t_creation) begin
              wtt_q[m_tmp_indx].print_entry();
              wtt_q[i].print_entry();
              `uvm_error(`LABEL_ERROR, $sformatf("Above two transactions cannot have same creation time"))
          end
      end
      return m_tmp_indx;
  endfunction : find_oldest_entry_in_wtt_q///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  
  ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  //Arbitrate which transaction gets priority when read and write appear at their respective arbiters at the same time
  //When the first r-w collision happens write gets priority, on the consequent one read does. Cycle through.
  ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  function int arbitrate_read_write_collision(int match_q[$]);
    int m_idx;
    case(r_w_SM)
      READ_PRIORITY: begin
        r_w_SM = WRITE_PRIORITY;
      end
      WRITE_PRIORITY: begin
        r_w_SM = READ_PRIORITY;
      end
    endcase
    `uvm_info("arbitrate_read_write_collision", $sformatf("Promoting %0s",r_w_SM.name),UVM_LOW)
    if(match_q.size() > 2 || match_q.size() == 0) begin
      `uvm_error("arbitrate_read_write_collision",$sformatf("Collision should only between two RTT elements, not more.(matches=%0d)",match_q.size))
    end
    else begin
      foreach(match_q[i])begin
        if(rtt_q[match_q[i]].seenAtWriteArb && WRITE_PRIORITY)begin
          m_idx = match_q[i];
        end
        else if(rtt_q[match_q[i]].seenAtReadArb && READ_PRIORITY) begin
          m_idx = match_q[i];
        end
        else begin
          `uvm_info("arbitrate_read_write_collision",$sformatf("For i:%0d Addr:%0h seenAtReadArb:%0b seenAtWriteArb:%0b", i, rtt_q[match_q[i]].cache_addr, rtt_q[match_q[i]].seenAtReadArb, rtt_q[match_q[i]].seenAtWriteArb),UVM_DEBUG)
        end
      end
    end
    return (m_idx);
  endfunction : arbitrate_read_write_collision////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  
  <% if(obj.useCmc) { %>
  ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  // Function to find oldest wtt entry already processed on SP ctrl channel
  ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  function int find_oldest_sp_lookup_in_wtt_q(int m_tmp_q[$]);
    time t_tmp_time;
    int  m_tmp_indx;
    t_tmp_time = wtt_q[m_tmp_q[0]].t_sp_seen_ctrl_chnl;
    m_tmp_indx = m_tmp_q[0];
    for(int i = 1; i < m_tmp_q.size(); i++) begin
      if(t_tmp_time > wtt_q[m_tmp_q[i]].t_sp_seen_ctrl_chnl) begin
        t_tmp_time = wtt_q[m_tmp_q[i]].t_sp_seen_ctrl_chnl;
        m_tmp_indx = m_tmp_q[i];
      end
      // Sanity check below
      else if (t_tmp_time == wtt_q[m_tmp_q[i]].t_sp_seen_ctrl_chnl) begin
         wtt_q[m_tmp_indx].print_entry();
         wtt_q[i].print_entry();
         `uvm_error(`LABEL_ERROR, $sformatf("Above two requests came on sp command interface at the same time"))
      end
    end
    return(m_tmp_indx);
  endfunction : find_oldest_sp_lookup_in_wtt_q///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  // Function to find oldest rtt entry already processed on SP ctrl channel
  ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  function int find_oldest_sp_lookup_in_rtt_q(int m_tmp_q[$]);
    time t_tmp_time;
    int  m_tmp_indx;
    t_tmp_time = rtt_q[m_tmp_q[0]].t_sp_seen_ctrl_chnl;
    m_tmp_indx = m_tmp_q[0];
    for(int i = 1; i < m_tmp_q.size(); i++) begin
      if(t_tmp_time > rtt_q[m_tmp_q[i]].t_sp_seen_ctrl_chnl) begin
        t_tmp_time = rtt_q[m_tmp_q[i]].t_sp_seen_ctrl_chnl;
        m_tmp_indx = m_tmp_q[i];
      end
      // Sanity check below
      else if (t_tmp_time == rtt_q[m_tmp_q[i]].t_sp_seen_ctrl_chnl) begin
        rtt_q[m_tmp_indx].print_entry();
        rtt_q[i].print_entry();
        `uvm_error(`LABEL_ERROR, $sformatf("Above two requests came on sp command interface at the same time"))
      end
    end
    return(m_tmp_indx);
  endfunction : find_oldest_sp_lookup_in_rtt_q///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  <% } %>
endclass : dmi_scoreboard
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

function bit dmi_scoreboard::isDtwMsg(smi_msg_type_logic_t msgType);
  eMsgDTW       eMsg1;
  eMsgDTWMrgMRD eMsg2;
  return (((msgType >= eMsg1.first()) && (msgType <= eMsg1.last())) ||
  ((msgType >= eMsg2.first()) && (msgType <= eMsg2.last()))); 
endfunction

function bit dmi_scoreboard::isCmdNcWrMsg(smi_msg_type_logic_t msgType);
  return ((msgType == CMD_WR_NC_PTL) || (msgType == CMD_WR_NC_FULL)); 
endfunction : isCmdNcWrMsg


function bit dmi_scoreboard::isAtomicMsg(smi_msg_type_logic_t msgType);
  return ((msgType == CMD_WR_ATM) || (msgType == CMD_RD_ATM) || (msgType == CMD_CMP_ATM) || (msgType == CMD_SW_ATM) ); 
endfunction : isAtomicMsg

function bit dmi_scoreboard::isdtwmrgmrd(smi_msg_type_logic_t msgType);
  eMsgDTWMrgMRD eMsg;
  return ((msgType >= eMsg.first()) && (msgType <= eMsg.last())); 
endfunction: isdtwmrgmrd

function bit dmi_scoreboard::isCohCmd(MsgType_t msgType);
  eMsgMRD eMsg;
  eMsgDTW eMsg1;
  eMsgDTWMrgMRD eMsg2;
  return (((msgType >= eMsg.first()) && (msgType <= eMsg.last()))|| ((msgType >= eMsg1.first()) && (msgType <= eMsg1.last())) || ((msgType >= eMsg2.first()) && (msgType <= eMsg2.last()))); 
endfunction: isCohCmd

function bit dmi_scoreboard::isNcCohCmd(MsgType_t msgType);
  return (msgType inside {CMD_RD_NC,CMD_WR_NC_PTL,CMD_WR_NC_FULL,CMD_CLN_INV,CMD_CLN_VLD,CMD_CLN_SH_PER,CMD_MK_INV,CMD_PREF,CMD_RD_ATM,CMD_WR_ATM,CMD_CMP_ATM,CMD_SW_ATM}); 
endfunction: isNcCohCmd

<% if(obj.useCmc) { %>
function void dmi_scoreboard::add_mnt_op_cache_line(dmi_scb_txn txn);
  int tmp_q_cache_hit[$];
  int tmp_q_CacheHit[$];
  int tmp_q_CacheHit_cmo[$];
  ccpCacheLine cache_line;

  tmp_q_cache_hit = {};
  tmp_q_CacheHit = {};

  if (txn.fillSeen) begin
    if (txn.isCacheHit) begin
      tmp_q_cache_hit = m_dmi_cache_q.find_index with (cl_aligned(item.addr) == cl_aligned(txn.cache_fill_ctrl_pkt.addr) &&
                                                       item.security == txn.cache_fill_ctrl_pkt.security);
      if (tmp_q_cache_hit.size() > 1) begin
        foreach (tmp_q_cache_hit[i]) begin
          m_dmi_cache_q[tmp_q_cache_hit[i]].print();
        end
        `uvm_error("<%=obj.BlockId%>:add_mnt_op_cache_line:Cache Hit during fill:1",$sformatf("Found multiple cache line hit for addr = 0x%0x & security = 0x%0x", txn.cache_fill_ctrl_pkt.addr, txn.cache_fill_ctrl_pkt.security))
      end
      if (tmp_q_cache_hit.size() == 0) begin
        foreach(m_dmi_cache_q[i]) begin
          m_dmi_cache_q[i].print();
        end
        `uvm_error("<%=obj.BlockId%>:add_mnt_op_cache_line:Cache Hit during fill:2", $sformatf("Found no cache line for addr = 0x%0x & security = 0x%0x", txn.cache_fill_ctrl_pkt.addr, txn.cache_fill_ctrl_pkt.security))
      end 
      if (tmp_q_cache_hit.size() == 1) begin
        `uvm_info("<%=obj.BlockId%>:add_mnt_op_cache_line",$sformatf("Updating Cache line due to Cache fill Hit for addr = 0x%0x, security = 0x%0x",txn.cache_fill_ctrl_pkt.addr,txn.cache_fill_ctrl_pkt.security),UVM_MEDIUM)
        m_dmi_cache_q[tmp_q_cache_hit[0]].state = txn.cache_fill_ctrl_pkt.state;
        m_dmi_cache_q[tmp_q_cache_hit[0]].isHitupgrade = 1'b1;
        m_dmi_cache_q[tmp_q_cache_hit[0]].t_last_update = $time;
      end
    end else begin
      tmp_q_cache_hit = m_dmi_cache_q.find_index with (cl_aligned(item.addr) == cl_aligned(txn.cache_fill_ctrl_pkt.addr) &&
                                                                    item.security == txn.cache_fill_ctrl_pkt.security);
      if (tmp_q_cache_hit.size() == 1) begin //if cache hit during write, update tag state only
        `uvm_info("<%=obj.BlockId%>:add_mnt_op_cache_line",$sformatf("Updating Cache line state due to Cache Hit due to previous cache write for addr = 0x%0x, security = 0x%0x",txn.cache_fill_ctrl_pkt.addr,txn.cache_fill_ctrl_pkt.security),UVM_MEDIUM)
        m_dmi_cache_q[tmp_q_cache_hit[0]].state = txn.cache_fill_ctrl_pkt.state;
        m_dmi_cache_q[tmp_q_cache_hit[0]].isHitupgrade = 1'b1;
        m_dmi_cache_q[tmp_q_cache_hit[0]].t_last_update = $time;
      end else begin
        cache_line = new();
        cache_line.addr = txn.cache_fill_ctrl_pkt.addr;
        cache_line.Index = ncoreConfigInfo::get_set_index(txn.cache_fill_ctrl_pkt.addr,<%=obj.DmiInfo[obj.Id].FUnitId%>); 
        cache_line.tag = mapAddrToCCPTag(txn.cache_fill_ctrl_pkt.addr);
        cache_line.security = txn.cache_fill_ctrl_pkt.security;
        cache_line.way = txn.cache_fill_ctrl_pkt.wayn;
        cache_line.state = txn.cache_fill_ctrl_pkt.state;
        cache_line.isPending = 0;
        cache_line.t_creation = $time;
        cache_line.t_last_update = $time;
        cache_line.data = new[CCP_BEATN];
        cache_line.dataErrorPerBeat = new[CCP_BEATN];
        `uvm_info("<%=obj.BlockId%>:add_mnt_op_cache_line",$sformatf("Adding Cache line due to Cache fill for addr = 0x%0x, security = 0x%0x",cache_line.addr,cache_line.security),UVM_MEDIUM)
        m_dmi_cache_q.push_back(cache_line);
      end
    end
  end else if(txn.lookupSeen && txn.cache_ctrl_pkt.tagstateup === 1)begin
    if(txn.isCacheHit)begin
      tmp_q_CacheHit = m_dmi_cache_q.find_index with (cl_aligned(item.addr) == cl_aligned(txn.cache_ctrl_pkt.addr) &&
                                                      item.security == txn.cache_ctrl_pkt.security);
      if (tmp_q_CacheHit.size() > 1) begin
        foreach (tmp_q_CacheHit[i]) begin
          m_dmi_cache_q[tmp_q_CacheHit[i]].print();
        end
        `uvm_error("<%=obj.BlockId%>:add_mnt_op_cache_line:Cache Hit during write:1",$sformatf("Found multiple cache line hit for addr = 0x%0x & security = 0x%0x", txn.cache_ctrl_pkt.addr, txn.cache_ctrl_pkt.security))
      end
      if (tmp_q_CacheHit.size() == 0) begin
        foreach(m_dmi_cache_q[i]) begin
          m_dmi_cache_q[i].print();
        end
        `uvm_error("<%=obj.BlockId%>:add_mnt_op_cache_line:Cache Hit during write:2", $sformatf("Found no cache line for addr = 0x%0x & security = 0x%0x", txn.cache_ctrl_pkt.addr, txn.cache_ctrl_pkt.security))
      end 
      if (tmp_q_CacheHit.size() == 1) begin
        `uvm_info("<%=obj.BlockId%>:add_mnt_op_cache_line",$sformatf("Updating Cache line due to Cache write Hit for addr = 0x%0x, security = 0x%0x",txn.cache_ctrl_pkt.addr,txn.cache_ctrl_pkt.security),UVM_MEDIUM)
        m_dmi_cache_q[tmp_q_CacheHit[0]].state = txn.cache_ctrl_pkt.state;
        m_dmi_cache_q[tmp_q_CacheHit[0]].isHitupgrade = 1'b1;
        m_dmi_cache_q[tmp_q_CacheHit[0]].t_last_update = $time;
      end
    end else begin
      tmp_q_CacheHit = m_dmi_cache_q.find_index with (cl_aligned(item.addr) == cl_aligned(txn.cache_ctrl_pkt.addr) &&
                                                                  item.security == txn.cache_ctrl_pkt.security);
      if (tmp_q_CacheHit.size() == 1) begin
        `uvm_info("<%=obj.BlockId%>:add_mnt_op_cache_line",$sformatf("Updating Cache line state due to Cache Hit due to previous cache fill for addr = 0x%0x, security = 0x%0x",txn.cache_ctrl_pkt.addr,txn.cache_ctrl_pkt.security),UVM_MEDIUM)
        m_dmi_cache_q[tmp_q_CacheHit[0]].state = txn.cache_ctrl_pkt.state;
        m_dmi_cache_q[tmp_q_CacheHit[0]].isHitupgrade = 1'b1;
        m_dmi_cache_q[tmp_q_CacheHit[0]].t_last_update = $time;
      end else begin
        cache_line = new();
        cache_line.addr = txn.cache_ctrl_pkt.addr;
        cache_line.Index = ncoreConfigInfo::get_set_index(txn.cache_ctrl_pkt.addr,<%=obj.DmiInfo[obj.Id].FUnitId%>); 
        cache_line.tag = mapAddrToCCPTag(txn.cache_ctrl_pkt.addr);
        cache_line.security = txn.cache_ctrl_pkt.security;
        cache_line.way = txn.cache_ctrl_pkt.wayn;
        cache_line.state = txn.cache_ctrl_pkt.state;
        cache_line.isPending = 0;
        cache_line.t_creation = $time;
        cache_line.t_last_update = $time;
        cache_line.data = new[CCP_BEATN];
        cache_line.dataErrorPerBeat = new[CCP_BEATN];
        `uvm_info("<%=obj.BlockId%>:add_mnt_op_cache_line",$sformatf("Adding Cache line due to Cache write for addr = 0x%0x, security = 0x%0x",cache_line.addr,cache_line.security),UVM_MEDIUM)
        m_dmi_cache_q.push_back(cache_line);
      end
    end
  end else if(!txn.cache_ctrl_pkt.isMntOp && txn.isRdWtt && txn.isEvict && txn.cache_ctrl_pkt.tagstateup === 1)begin
      tmp_q_CacheHit_cmo = m_dmi_cache_q.find_index with (cl_aligned(item.addr) == cl_aligned(txn.cache_ctrl_pkt.addr) &&
                                                          item.security == txn.cache_ctrl_pkt.security);
      if (tmp_q_CacheHit_cmo.size() == 1) begin
        `uvm_info("<%=obj.BlockId%>:add_mnt_op_cache_line",$sformatf("Updating Cache line state due to CMO addr = 0x%0x, security = 0x%0x",txn.cache_ctrl_pkt.addr,txn.cache_ctrl_pkt.security),UVM_MEDIUM)
        m_dmi_cache_q[tmp_q_CacheHit_cmo[0]].state = txn.cache_ctrl_pkt.state;
        m_dmi_cache_q[tmp_q_CacheHit_cmo[0]].isHitupgrade = 1'b1;
        m_dmi_cache_q[tmp_q_CacheHit_cmo[0]].t_last_update = $time;
      end
  end
  
endfunction:add_mnt_op_cache_line//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

function void dmi_scoreboard::delete_mnt_op_cache_line(ccp_ctrl_pkt_t m_packet);
  int tmp_q_del1[$],tmp_q_del2[$];
  if(m_packet.alloc  && m_packet.evictvld === 1 && !m_packet.isMntOp)begin
    tmp_q_del1 = m_dmi_cache_q.find_index with (cl_aligned(item.addr) == cl_aligned(m_packet.evictaddr) &&
                                                 item.security == m_packet.evictsecurity);
    if(tmp_q_del1.size() > 1)begin
      foreach (tmp_q_del1[i])begin
        m_dmi_cache_q[tmp_q_del1[i]].print();
      end
      `uvm_error("SMC_Cache_line_delete:1","Matched more than 1 cache line entry for eviction")
    end
    if(tmp_q_del1.size() == 1)begin
      `uvm_info("delete_mnt_op_cache_line",$sformatf("Deleting cache line for evictaddr = 0x%0x, evictsec = 0x%0x", m_packet.evictaddr, m_packet.evictsecurity),UVM_MEDIUM);
      m_dmi_cache_q.delete(tmp_q_del1[0]);
    end
  end
  if(m_packet.tagstateup === 1 && m_packet.state === IX && !m_packet.isMntOp)begin
    tmp_q_del2 = m_dmi_cache_q.find_index with (cl_aligned(item.addr) == cl_aligned(m_packet.addr) &&
                                                 item.security == m_packet.security);
    if(tmp_q_del2.size() > 1)begin
      foreach (tmp_q_del2[i])begin
        m_dmi_cache_q[tmp_q_del2[i]].print();
      end
      `uvm_error("SMC_Cache_line_delete:2","Matched more than 1 cache line entry for eviction")
    end
    if(tmp_q_del2.size() == 1)begin
      `uvm_info("delete_mnt_op_cache_line",$sformatf("Deleting cache line for addr = 0x%0x, sec = 0x%0x", m_packet.addr, m_packet.security),UVM_MEDIUM);
      m_dmi_cache_q.delete(tmp_q_del2[0]);
    end
  end
endfunction: delete_mnt_op_cache_line//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Purpose : To set word in tag of cache_q for debug_Wr MntOp
function void      dmi_scoreboard::set_word_tag_array  (int set, int way, bit[5:0] word, bit[31:0] worddata);
  int m_find_q[$];
  bit[<%=wTagArrayEntry-1%>:0] TagEntry;
  <%if(wTagProt){%>
  bit[<%=wTagProt-1%>:0] dummy_ecc={<%=wTagProt%>{1'h1}};<%}%> // should be 6:0
  bit[<%=wTag-1%>:0] tag;
  bit dummy_bit;

  m_find_q = m_dmi_cache_q.find_index() with (
                                      item.Index  == set    &&
                                      item.way    == way    
                                      );
  // Tag is not actually tag, it only removed 6 cachebits, Removing pribits now
  tag = get_tag_from_cacheline(m_dmi_cache_q[m_find_q[0]].tag);
  if(m_find_q.size() == 1) begin
    TagEntry = { m_dmi_cache_q[m_find_q[0]].security, tag, m_dmi_cache_q[m_find_q[0]].state <% if(wRP) {%>, 1'b1<% } if(wTagProt){%>,dummy_ecc<%}%>};
    <% if(Math.ceil(wTagArrayEntry/32)-1) { %>
    if(word == <%=Math.ceil(wTagArrayEntry/32)-1%> ) begin
        TagEntry[(word*32)+:<%=(wTagArrayEntry%32)%>] = worddata[0+:<%=(wTagArrayEntry%32)%>];
    end else <% } %>
        TagEntry[(word*<%=wTagArrayEntry%>)+:<%=wTagArrayEntry%>] = worddata;
    { m_dmi_cache_q[m_find_q[0]].security, tag, m_dmi_cache_q[m_find_q[0]].state <% if(wRP) {%>, dummy_bit<% } if(wTagProt){%>,dummy_ecc<%}%>} = TagEntry;
    m_dmi_cache_q[m_find_q[0]].tag = get_cacheline_from_tag(tag,m_dmi_cache_q[m_find_q[0]].Index);
  end else begin
    `uvm_error("<%=obj.DutInfo.strRtlNamePrefix%> SCB ERROR", $sformatf("set_word_tag_array : unable to find cacheline in Cache_q"))  
  end
endfunction : set_word_tag_array

// Purpose : To set word in data of cache_q for debug_Wr MntOp
function void dmi_scoreboard::set_word_data_array (int set, int way, bit[5:0] word, bit[31:0] worddata);
  int m_find_q[$];
  bit[<%=wDataArrayEntry-1%>:0] DataEntry;
  <%if(wDataProt){%>
  bit[<%=wDataProt-1%>:0] dummy_ecc={<%=wDataProt%>{1'h1}};<%}%>
  int beat;
  <%if( (obj.DmiInfo[obj.Id].ccpParams.nBeatsPerBank == 2 && obj.DmiInfo[obj.Id].ccpParams.wData == 128) ||
        (obj.DmiInfo[obj.Id].ccpParams.nBeatsPerBank == 1 && obj.DmiInfo[obj.Id].ccpParams.wData == 256) ){%>
  beat = word[4:4];
  word[5:4] = 0;
  <%}else if( obj.DmiInfo[obj.Id].ccpParams.nBeatsPerBank == 1 && obj.DmiInfo[obj.Id].ccpParams.wData == 128) {%>
  beat = word[4:3];
  word[5:3] = 0;
  <%}else {%>
  beat = word[5:5];
  word[5:5] = 0;
  <%}%>

  `uvm_info("MntOpWrData",$sformatf("Writing to Set:%0h Way:%0d Beat:%0d Word:%0d Data:0x%0h",set, way, beat, word, worddata),UVM_DEBUG)
  m_find_q = m_dmi_cache_q.find_index() with (
                                      item.Index  == set    &&
                                      item.way    == way    
                                      );
  if(m_find_q.size() == 1) begin
    <% if(obj.DmiInfo[obj.Id].ccpParams.nBeatsPerBank == 2) { %>
    <% if(obj.DmiInfo[obj.Id].ccpParams.wData == 128) { %>
    if(beat==1) beat=2; <% } %>
    DataEntry = {m_dmi_cache_q[m_find_q[0]].dataErrorPerBeat[beat], m_dmi_cache_q[m_find_q[0]].data[beat+1], m_dmi_cache_q[m_find_q[0]].data[beat]<%if(wDataProt){%>,dummy_ecc<%}%>};
    <%}else{%>
    DataEntry = {m_dmi_cache_q[m_find_q[0]].dataErrorPerBeat[beat],    m_dmi_cache_q[m_find_q[0]].data[beat]<%if(wDataProt){%>,dummy_ecc<%}%>};
    <%}%>
    if(word == <%=Math.ceil(wDataArrayEntry/32)-1%> ) begin
        DataEntry[(word *32)+:<%=(wDataArrayEntry%32)%>] = worddata[0+:<%=(wDataArrayEntry%32)%>];
    end else begin
        DataEntry[(word *32)+:32] = worddata;
    end
    <% if(obj.DmiInfo[obj.Id].ccpParams.nBeatsPerBank == 2) { %> 
    {m_dmi_cache_q[m_find_q[0]].data[beat]<%if(wDataProt){%>,dummy_ecc<%}%>} = DataEntry[<%=obj.DmiInfo[obj.Id].ccpParams.wData+wDataProt-1%>:0];
    {m_dmi_cache_q[m_find_q[0]].dataErrorPerBeat[beat],    m_dmi_cache_q[m_find_q[0]].data[beat+1]} = DataEntry[<%=wDataArrayEntry-1%>:<%=obj.DmiInfo[obj.Id].ccpParams.wData+wDataProt%>];
    <%}else{%>
    {m_dmi_cache_q[m_find_q[0]].dataErrorPerBeat[beat],    m_dmi_cache_q[m_find_q[0]].data[beat]<%if(wDataProt){%>,dummy_ecc<%}%>} = DataEntry;
    <%}%>
    `uvm_info("MntOpWrData",$sformatf("Data:%0p DataEntry:%0h",m_dmi_cache_q[m_find_q[0]].data, DataEntry),UVM_DEBUG)
  end else begin
    `uvm_error("<%=obj.DutInfo.strRtlNamePrefix%> SCB ERROR", $sformatf("set_word_data_array : unable to find cacheline in Cache_q")) 
  end
endfunction : set_word_data_array//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// Purpose : To get word from tag of cache_q for debug_Rd MntOp
function bit[31:0] dmi_scoreboard::get_word_tag_array  (int set, int way, bit[5:0] word);
  int m_find_q[$];
  bit[<%=wTagArrayEntry-1%>:0] TagEntry;
  <%if(wTagProt){%>
  bit[<%=wTagProt-1%>:0] dummy_ecc={<%=wTagProt%>{1'h1}};<%}%> // should be 6:0
  bit[<%=wTag-1%>:0] tag;
  bit dummy_bit;
  bit[31:0] worddata ;

  m_find_q = m_dmi_cache_q.find_index() with (
                                      item.Index  == set    &&
                                      item.way    == way    
                                      );
  // Tag is not actually tag, it only removed 6 cachebits, Removing pribits now
  tag = get_tag_from_cacheline(m_dmi_cache_q[m_find_q[0]].tag);
  if(m_find_q.size() == 1) begin
      TagEntry = { m_dmi_cache_q[m_find_q[0]].security, tag, m_dmi_cache_q[m_find_q[0]].state <% if(wRP) {%>, 1'b1<% } if(wTagProt){%>,dummy_ecc<%}%>};
      <% if(Math.ceil(wTagArrayEntry/32)-1) { %>
      if(word == <%=Math.ceil(wTagArrayEntry/32)-1%> ) begin
          worddata[0+:<%=(wTagArrayEntry%32)%>] = TagEntry[(word*32)+:<%=(wTagArrayEntry%32)%>];
      end else <% } %>
          worddata = TagEntry[(word*<%=wTagArrayEntry%>)+:<%=wTagArrayEntry%>];
  end else begin
      `uvm_error("<%=obj.DutInfo.strRtlNamePrefix%> SCB ERROR", $sformatf("get_word_tag_array : unable to find cacheline in Cache_q"))
  end
  return worddata;
endfunction : get_word_tag_array//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// Purpose : To get word from data of cache_q for debug_Rd MntOp
function bit[31:0] dmi_scoreboard::get_word_data_array (int set, int way, int beat, int word);
  int m_find_q[$];
  bit[31:0] worddata ;
  bit[<%=wDataArrayEntry-1%>:0] DataEntry;
  <%if(wDataProt){%>
  bit[<%=wDataProt-1%>:0] dummy_ecc={<%=wDataProt%>{1'h1}};<%}%>

  m_find_q = m_dmi_cache_q.find_index() with (
                                        item.Index  == set    &&
                                        item.way    == way    
                                        );  
  `uvm_info("MntOpRdData",$sformatf("Reading from Set:%0h Way:%0d Beat:%0d Word:%0d",set, way, beat, word),UVM_DEBUG)
  if(m_find_q.size() == 1) begin
      <% if(obj.DmiInfo[obj.Id].ccpParams.nBeatsPerBank == 2) { %>
      <% if(obj.DmiInfo[obj.Id].ccpParams.wData == 128) { %>
      if(beat == 1) beat = 2; <%}%>
      //Pack beats together for slow sram configuration
      DataEntry = {m_dmi_cache_q[m_find_q[0]].dataErrorPerBeat[beat], m_dmi_cache_q[m_find_q[0]].data[beat+1], m_dmi_cache_q[m_find_q[0]].data[beat]<%if(wDataProt){%>,dummy_ecc<%}%>};
      <%}else{%>
      DataEntry = {m_dmi_cache_q[m_find_q[0]].dataErrorPerBeat[beat],    m_dmi_cache_q[m_find_q[0]].data[beat]<%if(wDataProt){%>,dummy_ecc<%}%>};
      <%}%>
      if(word == <%=Math.ceil(wDataArrayEntry/32)-1%> ) begin
          worddata[0+:<%=(wDataArrayEntry%32)%>] = DataEntry[(word*32)+:<%=(wDataArrayEntry%32)%>];
      end else begin
          worddata = DataEntry[(word*32)+:32];
      end
      `uvm_info("MntOpRdData",$sformatf("Data:%0p DataEntry:%0h WordData:%0h",m_dmi_cache_q[m_find_q[0]].data, DataEntry, worddata),UVM_DEBUG)
  end else begin
      `uvm_error("<%=obj.DutInfo.strRtlNamePrefix%> SCB ERROR", $sformatf("get_word_data_array : unable to find cacheline in Cache_q"))
  end
  return worddata;
endfunction : get_word_data_array//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// Purpose : To get Tag from cacheline Addr
function bit[<%=wTag-1%>:0] dmi_scoreboard::get_tag_from_cacheline (bit[<%=wCacheline-1%>:0] cacheline);
  bit[<%=wTag-1%>:0] tag; 
  for(int i=0,j=0; i< <%=wCacheline%> ;i++) begin
     if(!(i inside {<% for(var idx=0;idx<obj.DmiInfo[obj.Id].ccpParams.PriSubDiagAddrBits.length;idx++) {%> <%=obj.DmiInfo[obj.Id].ccpParams.PriSubDiagAddrBits[idx]-wCacheLineOffset%><%if(idx<obj.DmiInfo[obj.Id].ccpParams.PriSubDiagAddrBits.length-1){%>,<%}}%>} )) begin
        tag[j] = cacheline[i];
        j++;
     end
  end
  //$display("Debug inCacheLineAddr:%0x outTag:%0x",cacheline, tag);
  return tag;
endfunction : get_tag_from_cacheline

// Purpose : To get cacheline Addr from Tag and Index
function bit[<%=wCacheline-1%>:0] dmi_scoreboard::get_cacheline_from_tag (bit[<%=wTag-1%>:0] tag, bit[<%=obj.DmiInfo[obj.Id].ccpParams.PriSubDiagAddrBits.length-1%>:0] index);
  bit[<%=wCacheline-1%>:0] cacheline; 
  for(int i=0,j=0,k=0; i< <%=wCacheline%> ;i++) begin
     if(i inside {<% for(var idx=0;idx<obj.DmiInfo[obj.Id].ccpParams.PriSubDiagAddrBits.length;idx++) {%> <%=obj.DmiInfo[obj.Id].ccpParams.PriSubDiagAddrBits[idx]-wCacheLineOffset%><%if(idx<obj.DmiInfo[obj.Id].ccpParams.PriSubDiagAddrBits.length-1){%>,<%}}%>} )
        cacheline[i] = index[k++];
     else
        cacheline[i] = tag[j++];
  end
  //$display("Debug inTag:%0x inIndex:%0x OutCacheLineAddr:%0x",tag, index, cacheline);
  return cacheline;
endfunction : get_cacheline_from_tag
<% } %>
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Latency data calculation
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function void dmi_scoreboard::calculate_dmi_latency_data(int idx, string queue_type);
  <%if(obj.useCmc) {%>
  if(queue_type == "rtt") begin
    if(rtt_q[idx].CMD_req_recd && rtt_q[idx].DTR_req_recd && rtt_q[idx].cache_ctrl_pkt.currstate != IX) begin 
        `uvm_info("calculate_dmi_latency_data",$sformatf("pushing latency for cmdreq to dtrreq. t_dtrreq %0t t_cmdreq %0t latency %0d", 
                    rtt_q[idx].t_dtrreq, rtt_q[idx].t_cmdreq, (rtt_q[idx].t_dtrreq - rtt_q[idx].t_cmdreq)/clk_period), UVM_MEDIUM)
        latency_cmdreq_dtrreq_hit_q.push_back(rtt_q[idx].t_dtrreq - rtt_q[idx].t_cmdreq);
    end
    if(rtt_q[idx].MRD_req_recd && rtt_q[idx].DTR_req_recd && rtt_q[idx].cache_ctrl_pkt.currstate != IX) begin 
        `uvm_info("calculate_dmi_latency_data",$sformatf("pushing latency for mrdreq to dtrreq. t_dtrreq %0t t_mrdreq %0t latency %0d", 
                    rtt_q[idx].t_dtrreq, rtt_q[idx].t_mrdreq, (rtt_q[idx].t_dtrreq - rtt_q[idx].t_mrdreq)/clk_period), UVM_MEDIUM)
        latency_mrdreq_dtrreq_hit_q.push_back(rtt_q[idx].t_dtrreq - rtt_q[idx].t_mrdreq);
    end
    if(rtt_q[idx].CMD_req_recd && rtt_q[idx].AXI_read_addr_recd && rtt_q[idx].cache_ctrl_pkt.currstate == IX) begin
        `uvm_info("calculate_dmi_latency_data",$sformatf("pushing latency for axi_ar to cmdreq. t_ar %0t t_cmdreq %0t latency %0d", 
                    rtt_q[idx].t_ar, rtt_q[idx].t_cmdreq, (rtt_q[idx].t_ar - rtt_q[idx].t_cmdreq)/clk_period), UVM_MEDIUM)
        latency_cmdreq_axi_ar_miss_q.push_back(rtt_q[idx].t_ar - rtt_q[idx].t_cmdreq);
    end
    if(rtt_q[idx].MRD_req_recd && rtt_q[idx].AXI_read_addr_recd && rtt_q[idx].cache_ctrl_pkt.currstate == IX) begin 
        `uvm_info("calculate_dmi_latency_data",$sformatf("pushing latency for mrdreq to axi_ar. t_ar %0t t_mrdreq %0t latency %0d", 
                    rtt_q[idx].t_ar, rtt_q[idx].t_mrdreq, (rtt_q[idx].t_ar - rtt_q[idx].t_mrdreq)/clk_period), UVM_MEDIUM)
        latency_mrdreq_axi_ar_miss_q.push_back(rtt_q[idx].t_ar - rtt_q[idx].t_mrdreq);
    end
    if(rtt_q[idx].CMD_req_recd && rtt_q[idx].STR_req_recd && rtt_q[idx].smi_vz == 0) begin 
        `uvm_info("calculate_dmi_latency_data",$sformatf("pushing latency for cmdreq to strreq. t_strreq %0t t_cmdreq %0t latency %0d", 
                    rtt_q[idx].t_strreq, rtt_q[idx].t_cmdreq, (rtt_q[idx].t_strreq - rtt_q[idx].t_cmdreq)/clk_period), UVM_MEDIUM)
        latency_cmdreq_strreq_coh_vz_q.push_back(rtt_q[idx].t_strreq - rtt_q[idx].t_cmdreq);
    end
    if(rtt_q[idx].AXI_read_data_expd && rtt_q[idx].DTR_req_recd && rtt_q[idx].cache_ctrl_pkt.currstate == IX) begin 
        `uvm_info("calculate_dmi_latency_data",$sformatf("pushing latency for dtrreq to axi_r. t_dtrreq %0t t_r %0t latency %0d",
                    rtt_q[idx].t_dtrreq, rtt_q[idx].t_r, (rtt_q[idx].t_dtrreq - rtt_q[idx].t_r)/clk_period), UVM_MEDIUM)
        latency_dtrreq_axi_r_q.push_back(rtt_q[idx].t_dtrreq - rtt_q[idx].t_r);
    end
    if(rtt_q[idx].DTW_req_recd && rtt_q[idx].AXI_write_addr_recd) begin 
        `uvm_info("calculate_dmi_latency_data",$sformatf("pushing latency for dtwreq to axi_aw. t_aw %0t t_dtwreq %0t latency %0d",
                    rtt_q[idx].axi_write_addr_pkt.t_pkt_seen_on_intf, rtt_q[idx].dtw_req_pkt.t_smi_ndp_ready, (rtt_q[idx].axi_write_addr_pkt.t_pkt_seen_on_intf - rtt_q[idx].dtw_req_pkt.t_smi_ndp_ready)/clk_period), UVM_MEDIUM)
        latency_dtwreq_axi_aw_q.push_back(rtt_q[idx].axi_write_addr_pkt.t_pkt_seen_on_intf - rtt_q[idx].dtw_req_pkt.t_smi_ndp_ready);
    end
    if(rtt_q[idx].DTW_req_recd && rtt_q[idx].AXI_write_data_recd) begin 
        `uvm_info("calculate_dmi_latency_data",$sformatf("pushing latency for dtwreq to axi_w. t_w %0t t_dtwreq %0t latency %0d",
                    rtt_q[idx].axi_write_data_pkt.t_wtime[rtt_q[idx].axi_write_data_pkt.t_wtime.size()-1], rtt_q[idx].t_dtwreq, (rtt_q[idx].axi_write_data_pkt.t_wtime[rtt_q[idx].axi_write_data_pkt.t_wtime.size()-1] - rtt_q[idx].t_dtwreq)/clk_period), UVM_MEDIUM)
        latency_dtwreq_axi_w_q.push_back(rtt_q[idx].axi_write_data_pkt.t_wtime[rtt_q[idx].axi_write_data_pkt.t_wtime.size()-1] - rtt_q[idx].t_dtwreq);
    end
    if(rtt_q[idx].DTW_rsp_recd && rtt_q[idx].AXI_write_resp_recd && rtt_q[idx].smi_vz == 1) begin 
        `uvm_info("calculate_dmi_latency_data",$sformatf("pushing latency for dtwrsp to axi_b. t_dtwrsp %0t t_b %0t latency %0d",
                    rtt_q[idx].t_dtwrsp, rtt_q[idx].t_b, (rtt_q[idx].t_dtwrsp - rtt_q[idx].t_b)/clk_period), UVM_MEDIUM)
        latency_axi_b_dtwrsp_q.push_back(rtt_q[idx].t_dtwrsp - rtt_q[idx].t_b);
    end
    if(rtt_q[idx].DTW_req_recd && rtt_q[idx].DTW_rsp_recd && rtt_q[idx].smi_vz == 0) begin 
        `uvm_info("calculate_dmi_latency_data",$sformatf("pushing latency for dtwrsp to dtwreq. t_dtwrsp %0t t_dtwreq %0t latency %0d",
                    rtt_q[idx].t_dtwrsp, rtt_q[idx].t_dtwreq, (rtt_q[idx].t_dtwrsp - rtt_q[idx].t_dtwreq)/clk_period), UVM_MEDIUM)
        latency_dtwreq_dtwrsp_q.push_back(rtt_q[idx].t_dtwrsp - rtt_q[idx].t_dtwreq);
    end
  end
  else if(queue_type == "wtt") begin
    if(wtt_q[idx].CMD_req_recd && wtt_q[idx].DTR_req_recd && wtt_q[idx].cache_ctrl_pkt.currstate != IX) begin 
        `uvm_info("calculate_dmi_latency_data",$sformatf("pushing latency for cmdreq to dtrreq. t_dtrreq %0t t_cmdreq %0t latency %0d", 
                    wtt_q[idx].t_dtrreq, wtt_q[idx].t_cmdreq, (wtt_q[idx].t_dtrreq - wtt_q[idx].t_cmdreq)/clk_period), UVM_MEDIUM)
        latency_cmdreq_dtrreq_hit_q.push_back(wtt_q[idx].t_dtrreq - wtt_q[idx].t_cmdreq);
    end
    if(wtt_q[idx].MRD_req_recd && wtt_q[idx].DTR_req_recd && wtt_q[idx].cache_ctrl_pkt.currstate != IX) begin 
        `uvm_info("calculate_dmi_latency_data",$sformatf("pushing latency for mrdreq to dtrreq. t_dtrreq %0t t_mrdreq %0t latency %0d", 
                    wtt_q[idx].t_dtrreq, wtt_q[idx].t_mrdreq, (wtt_q[idx].t_dtrreq - wtt_q[idx].t_mrdreq)/clk_period), UVM_MEDIUM)
        latency_mrdreq_dtrreq_hit_q.push_back(wtt_q[idx].t_dtrreq - wtt_q[idx].t_mrdreq);
    end
    if(wtt_q[idx].CMD_req_recd && wtt_q[idx].AXI_read_addr_recd && wtt_q[idx].cache_ctrl_pkt.currstate == IX) begin
        `uvm_info("calculate_dmi_latency_data",$sformatf("pushing latency for axi_ar to cmdreq. t_ar %0t t_cmdreq %0t latency %0d", 
                    wtt_q[idx].t_ar, wtt_q[idx].t_cmdreq, (wtt_q[idx].t_ar - wtt_q[idx].t_cmdreq)/clk_period), UVM_MEDIUM)
        latency_cmdreq_axi_ar_miss_q.push_back(wtt_q[idx].t_ar - wtt_q[idx].t_cmdreq);
    end
    if(wtt_q[idx].MRD_req_recd && wtt_q[idx].AXI_read_addr_recd && wtt_q[idx].cache_ctrl_pkt.currstate == IX) begin 
        `uvm_info("calculate_dmi_latency_data",$sformatf("pushing latency for mrdreq to axi_ar. t_ar %0t t_mrdreq %0t latency %0d", 
                    wtt_q[idx].t_ar, wtt_q[idx].t_mrdreq, (wtt_q[idx].t_ar - wtt_q[idx].t_mrdreq)/clk_period), UVM_MEDIUM)
        latency_mrdreq_axi_ar_miss_q.push_back(wtt_q[idx].t_ar - wtt_q[idx].t_mrdreq);
    end
    if(wtt_q[idx].CMD_req_recd && wtt_q[idx].STR_req_recd && wtt_q[idx].smi_vz == 0) begin 
        `uvm_info("calculate_dmi_latency_data",$sformatf("pushing latency for cmdreq to strreq. t_strreq %0t t_cmdreq %0t latency %0d", 
                    wtt_q[idx].t_strreq, wtt_q[idx].t_cmdreq, (wtt_q[idx].t_strreq - wtt_q[idx].t_cmdreq)/clk_period), UVM_MEDIUM)
        latency_cmdreq_strreq_coh_vz_q.push_back(wtt_q[idx].t_strreq - wtt_q[idx].t_cmdreq);
    end
    if(wtt_q[idx].AXI_read_data_expd && wtt_q[idx].DTR_req_recd && wtt_q[idx].cache_ctrl_pkt.currstate == IX) begin 
        `uvm_info("calculate_dmi_latency_data",$sformatf("pushing latency for dtrreq to axi_r. t_dtrreq %0t t_r %0t latency %0d",
                    wtt_q[idx].t_dtrreq, wtt_q[idx].t_r, (wtt_q[idx].t_dtrreq - wtt_q[idx].t_r)/clk_period), UVM_MEDIUM)
        latency_dtrreq_axi_r_q.push_back(wtt_q[idx].t_dtrreq - wtt_q[idx].t_r);
    end
    if(wtt_q[idx].DTW_req_recd && wtt_q[idx].AXI_write_addr_recd) begin 
        `uvm_info("calculate_dmi_latency_data",$sformatf("pushing latency for dtwreq to axi_aw. t_aw %0t t_dtwreq %0t latency %0d",
                    wtt_q[idx].axi_write_addr_pkt.t_pkt_seen_on_intf, wtt_q[idx].dtw_req_pkt.t_smi_ndp_ready, (wtt_q[idx].axi_write_addr_pkt.t_pkt_seen_on_intf - wtt_q[idx].dtw_req_pkt.t_smi_ndp_ready)/clk_period), UVM_MEDIUM)
        latency_dtwreq_axi_aw_q.push_back(wtt_q[idx].axi_write_addr_pkt.t_pkt_seen_on_intf - wtt_q[idx].dtw_req_pkt.t_smi_ndp_ready);
    end
    if(wtt_q[idx].DTW_req_recd && wtt_q[idx].AXI_write_data_recd) begin 
        `uvm_info("calculate_dmi_latency_data",$sformatf("pushing latency for dtwreq to axi_w. t_w %0t t_dtwreq %0t latency %0d",
                    wtt_q[idx].axi_write_data_pkt.t_wtime[wtt_q[idx].axi_write_data_pkt.t_wtime.size()-1], wtt_q[idx].t_dtwreq, (wtt_q[idx].axi_write_data_pkt.t_wtime[wtt_q[idx].axi_write_data_pkt.t_wtime.size()-1] - wtt_q[idx].t_dtwreq)/clk_period), UVM_MEDIUM)
        latency_dtwreq_axi_w_q.push_back(wtt_q[idx].axi_write_data_pkt.t_wtime[wtt_q[idx].axi_write_data_pkt.t_wtime.size()-1] - wtt_q[idx].t_dtwreq);
    end
    if(wtt_q[idx].DTW_rsp_recd && wtt_q[idx].AXI_write_resp_recd && wtt_q[idx].smi_vz == 1) begin 
        `uvm_info("calculate_dmi_latency_data",$sformatf("pushing latency for dtwrsp to axi_b. t_dtwrsp %0t t_b %0t latency %0d",
                    wtt_q[idx].t_dtwrsp, wtt_q[idx].t_b, (wtt_q[idx].t_dtwrsp - wtt_q[idx].t_b)/clk_period), UVM_MEDIUM)
        latency_axi_b_dtwrsp_q.push_back(wtt_q[idx].t_dtwrsp - wtt_q[idx].t_b);
    end
    if(wtt_q[idx].DTW_req_recd && wtt_q[idx].DTW_rsp_recd && wtt_q[idx].smi_vz == 0) begin 
        `uvm_info("calculate_dmi_latency_data",$sformatf("pushing latency for dtwrsp to dtwreq. t_dtwrsp %0t t_dtwreq %0t latency %0d",
                    wtt_q[idx].t_dtwrsp, wtt_q[idx].t_dtwreq, (wtt_q[idx].t_dtwrsp - wtt_q[idx].t_dtwreq)/clk_period), UVM_MEDIUM)
        latency_dtwreq_dtwrsp_q.push_back(wtt_q[idx].t_dtwrsp - wtt_q[idx].t_dtwreq);
    end
  end
  <% } else {%>
  if(queue_type == "rtt") begin
    if(rtt_q[idx].CMD_req_recd && rtt_q[idx].AXI_read_addr_recd) begin
        `uvm_info("calculate_dmi_latency_data",$sformatf("pushing latency for axi_ar to cmdreq. t_ar %0t t_cmdreq %0t latency %0d", 
                    rtt_q[idx].t_ar, rtt_q[idx].t_cmdreq, (rtt_q[idx].t_ar - rtt_q[idx].t_cmdreq)/clk_period), UVM_MEDIUM)
        latency_cmdreq_axi_ar_miss_q.push_back(rtt_q[idx].t_ar - rtt_q[idx].t_cmdreq);
    end
    if(rtt_q[idx].MRD_req_recd && rtt_q[idx].AXI_read_addr_recd) begin 
        `uvm_info("calculate_dmi_latency_data",$sformatf("pushing latency for mrdreq to axi_ar. t_ar %0t t_mrdreq %0t latency %0d", 
                    rtt_q[idx].t_ar, rtt_q[idx].t_mrdreq, (rtt_q[idx].t_ar - rtt_q[idx].t_mrdreq)/clk_period), UVM_MEDIUM)
        latency_mrdreq_axi_ar_miss_q.push_back(rtt_q[idx].t_ar - rtt_q[idx].t_mrdreq);
    end
    if(rtt_q[idx].CMD_req_recd && rtt_q[idx].STR_req_recd && rtt_q[idx].smi_vz == 0) begin 
        `uvm_info("calculate_dmi_latency_data",$sformatf("pushing latency for cmdreq to strreq. t_strreq %0t t_cmdreq %0t latency %0d", 
                    rtt_q[idx].t_strreq, rtt_q[idx].t_cmdreq, (rtt_q[idx].t_strreq - rtt_q[idx].t_cmdreq)/clk_period), UVM_MEDIUM)
        latency_cmdreq_strreq_coh_vz_q.push_back(rtt_q[idx].t_strreq - rtt_q[idx].t_cmdreq);
    end
    if(rtt_q[idx].AXI_read_data_expd && rtt_q[idx].DTR_req_recd) begin 
        `uvm_info("calculate_dmi_latency_data",$sformatf("pushing latency for dtrreq to axi_r. t_dtrreq %0t t_r %0t latency %0d",
                    rtt_q[idx].t_dtrreq, rtt_q[idx].t_r, (rtt_q[idx].t_dtrreq - rtt_q[idx].t_r)/clk_period), UVM_MEDIUM)
        latency_dtrreq_axi_r_q.push_back(rtt_q[idx].t_dtrreq - rtt_q[idx].t_r);
    end
    if(rtt_q[idx].DTW_req_recd && rtt_q[idx].AXI_write_addr_recd) begin 
        `uvm_info("calculate_dmi_latency_data",$sformatf("pushing latency for dtwreq to axi_aw. t_aw %0t t_dtwreq %0t latency %0d",
                    rtt_q[idx].axi_write_addr_pkt.t_pkt_seen_on_intf, rtt_q[idx].dtw_req_pkt.t_smi_ndp_ready, (rtt_q[idx].axi_write_addr_pkt.t_pkt_seen_on_intf - rtt_q[idx].dtw_req_pkt.t_smi_ndp_ready)/clk_period), UVM_MEDIUM)
        latency_dtwreq_axi_aw_q.push_back(rtt_q[idx].axi_write_addr_pkt.t_pkt_seen_on_intf - rtt_q[idx].dtw_req_pkt.t_smi_ndp_ready);
    end
    if(rtt_q[idx].DTW_req_recd && rtt_q[idx].AXI_write_data_recd) begin 
        `uvm_info("calculate_dmi_latency_data",$sformatf("pushing latency for dtwreq to axi_w. t_w %0t t_dtwreq %0t latency %0d",
                    rtt_q[idx].axi_write_data_pkt.t_wtime[rtt_q[idx].axi_write_data_pkt.t_wtime.size()-1], rtt_q[idx].t_dtwreq, (rtt_q[idx].axi_write_data_pkt.t_wtime[rtt_q[idx].axi_write_data_pkt.t_wtime.size()-1] - rtt_q[idx].t_dtwreq)/clk_period), UVM_MEDIUM)
        latency_dtwreq_axi_w_q.push_back(rtt_q[idx].axi_write_data_pkt.t_wtime[rtt_q[idx].axi_write_data_pkt.t_wtime.size()-1] - rtt_q[idx].t_dtwreq);
    end
    if(rtt_q[idx].DTW_rsp_recd && rtt_q[idx].AXI_write_resp_recd && rtt_q[idx].smi_vz == 1) begin 
        `uvm_info("calculate_dmi_latency_data",$sformatf("pushing latency for dtwrsp to axi_b. t_dtwrsp %0t t_b %0t latency %0d",
                    rtt_q[idx].t_dtwrsp, rtt_q[idx].t_b, (rtt_q[idx].t_dtwrsp - rtt_q[idx].t_b)/clk_period), UVM_MEDIUM)
        latency_axi_b_dtwrsp_q.push_back(rtt_q[idx].t_dtwrsp - rtt_q[idx].t_b);
    end
    if(rtt_q[idx].DTW_req_recd && rtt_q[idx].DTW_rsp_recd && rtt_q[idx].smi_vz == 0) begin 
        `uvm_info("calculate_dmi_latency_data",$sformatf("pushing latency for dtwrsp to dtwreq. t_dtwrsp %0t t_dtwreq %0t latency %0d",
                    rtt_q[idx].t_dtwrsp, rtt_q[idx].t_dtwreq, (rtt_q[idx].t_dtwrsp - rtt_q[idx].t_dtwreq)/clk_period), UVM_MEDIUM)
        latency_dtwreq_dtwrsp_q.push_back(rtt_q[idx].t_dtwrsp - rtt_q[idx].t_dtwreq);
    end
  end
  else if(queue_type == "wtt") begin
    if(wtt_q[idx].CMD_req_recd && wtt_q[idx].AXI_read_addr_recd) begin
        `uvm_info("calculate_dmi_latency_data",$sformatf("pushing latency for axi_ar to cmdreq. t_ar %0t t_cmdreq %0t latency %0d", 
                    wtt_q[idx].t_ar, wtt_q[idx].t_cmdreq, (wtt_q[idx].t_ar - wtt_q[idx].t_cmdreq)/clk_period), UVM_MEDIUM)
        latency_cmdreq_axi_ar_miss_q.push_back(wtt_q[idx].t_ar - wtt_q[idx].t_cmdreq);
    end
    if(wtt_q[idx].MRD_req_recd && wtt_q[idx].AXI_read_addr_recd) begin 
        `uvm_info("calculate_dmi_latency_data",$sformatf("pushing latency for mrdreq to axi_ar. t_ar %0t t_mrdreq %0t latency %0d", 
                    wtt_q[idx].t_ar, wtt_q[idx].t_mrdreq, (wtt_q[idx].t_ar - wtt_q[idx].t_mrdreq)/clk_period), UVM_MEDIUM)
        latency_mrdreq_axi_ar_miss_q.push_back(wtt_q[idx].t_ar - wtt_q[idx].t_mrdreq);
    end
    if(wtt_q[idx].CMD_req_recd && wtt_q[idx].STR_req_recd && wtt_q[idx].smi_vz == 0) begin 
        `uvm_info("calculate_dmi_latency_data",$sformatf("pushing latency for cmdreq to strreq. t_strreq %0t t_cmdreq %0t latency %0d", 
                    wtt_q[idx].t_strreq, wtt_q[idx].t_cmdreq, (wtt_q[idx].t_strreq - wtt_q[idx].t_cmdreq)/clk_period), UVM_MEDIUM)
        latency_cmdreq_strreq_coh_vz_q.push_back(wtt_q[idx].t_strreq - wtt_q[idx].t_cmdreq);
    end
    if(wtt_q[idx].AXI_read_data_expd && wtt_q[idx].DTR_req_recd) begin 
        `uvm_info("calculate_dmi_latency_data",$sformatf("pushing latency for dtrreq to axi_r. t_dtrreq %0t t_r %0t latency %0d",
                    wtt_q[idx].t_dtrreq, wtt_q[idx].t_r, (wtt_q[idx].t_dtrreq - wtt_q[idx].t_r)/clk_period), UVM_MEDIUM)
        latency_dtrreq_axi_r_q.push_back(wtt_q[idx].t_dtrreq - wtt_q[idx].t_r);
    end
    if(wtt_q[idx].DTW_req_recd && wtt_q[idx].AXI_write_addr_recd) begin 
        `uvm_info("calculate_dmi_latency_data",$sformatf("pushing latency for dtwreq to axi_aw. t_aw %0t t_dtwreq %0t latency %0d",
                    wtt_q[idx].axi_write_addr_pkt.t_pkt_seen_on_intf, wtt_q[idx].dtw_req_pkt.t_smi_ndp_ready, (wtt_q[idx].axi_write_addr_pkt.t_pkt_seen_on_intf - wtt_q[idx].dtw_req_pkt.t_smi_ndp_ready)/clk_period), UVM_MEDIUM)
        latency_dtwreq_axi_aw_q.push_back(wtt_q[idx].axi_write_addr_pkt.t_pkt_seen_on_intf - wtt_q[idx].dtw_req_pkt.t_smi_ndp_ready);
    end
    if(wtt_q[idx].DTW_req_recd && wtt_q[idx].AXI_write_data_recd) begin 
        `uvm_info("calculate_dmi_latency_data",$sformatf("pushing latency for dtwreq to axi_w. t_w %0t t_dtwreq %0t latency %0d",
                    wtt_q[idx].axi_write_data_pkt.t_wtime[wtt_q[idx].axi_write_data_pkt.t_wtime.size()-1], wtt_q[idx].t_dtwreq, (wtt_q[idx].axi_write_data_pkt.t_wtime[wtt_q[idx].axi_write_data_pkt.t_wtime.size()-1] - wtt_q[idx].t_dtwreq)/clk_period), UVM_MEDIUM)
        latency_dtwreq_axi_w_q.push_back(wtt_q[idx].axi_write_data_pkt.t_wtime[wtt_q[idx].axi_write_data_pkt.t_wtime.size()-1] - wtt_q[idx].t_dtwreq);
    end
    if(wtt_q[idx].DTW_rsp_recd && wtt_q[idx].AXI_write_resp_recd && wtt_q[idx].smi_vz == 1) begin 
        `uvm_info("calculate_dmi_latency_data",$sformatf("pushing latency for dtwrsp to axi_b. t_dtwrsp %0t t_b %0t latency %0d",
                    wtt_q[idx].t_dtwrsp, wtt_q[idx].t_b, (wtt_q[idx].t_dtwrsp - wtt_q[idx].t_b)/clk_period), UVM_MEDIUM)
        latency_axi_b_dtwrsp_q.push_back(wtt_q[idx].t_dtwrsp - wtt_q[idx].t_b);
    end
    if(wtt_q[idx].DTW_req_recd && wtt_q[idx].DTW_rsp_recd && wtt_q[idx].smi_vz == 0) begin 
        `uvm_info("calculate_dmi_latency_data",$sformatf("pushing latency for dtwrsp to dtwreq. t_dtwrsp %0t t_dtwreq %0t latency %0d",
                    wtt_q[idx].t_dtwrsp, wtt_q[idx].t_dtwreq, (wtt_q[idx].t_dtwrsp - wtt_q[idx].t_dtwreq)/clk_period), UVM_MEDIUM)
        latency_dtwreq_dtwrsp_q.push_back(wtt_q[idx].t_dtwrsp - wtt_q[idx].t_dtwreq);
    end
  end
  <% } %>
endfunction : calculate_dmi_latency_data////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

function void dmi_scoreboard::calculate_dmi_latency_data_per_qos(int idx, string queue_type);
  <%if(obj.useCmc) {%>
  if(queue_type == "rtt") begin
    if(rtt_q[idx].CMD_req_recd && rtt_q[idx].DTR_req_recd && rtt_q[idx].cache_ctrl_pkt.currstate != IX) begin 
        `uvm_info("calculate_dmi_latency_data_per_qos",$sformatf("pushing latency for cmdreq to dtrreq QOS %0d. t_dtrreq %0t t_cmdreq %0t latency %0d", 
                    rtt_q[idx].smi_qos, rtt_q[idx].t_dtrreq, rtt_q[idx].t_cmdreq, (rtt_q[idx].t_dtrreq - rtt_q[idx].t_cmdreq)/clk_period), UVM_MEDIUM)
        lat_cmdreq_dtrreq_hit_q[int'(rtt_q[idx].smi_qos)].push_back(rtt_q[idx].t_dtrreq - rtt_q[idx].t_cmdreq);
    end
    if(rtt_q[idx].MRD_req_recd && rtt_q[idx].DTR_req_recd && rtt_q[idx].cache_ctrl_pkt.currstate != IX) begin 
        `uvm_info("calculate_dmi_latency_data_per_qos",$sformatf("pushing latency for mrdreq to dtrreq QOS %0d. t_dtrreq %0t t_mrdreq %0t latency %0d", 
                    rtt_q[idx].smi_qos, rtt_q[idx].t_dtrreq, rtt_q[idx].t_mrdreq, (rtt_q[idx].t_dtrreq - rtt_q[idx].t_mrdreq)/clk_period), UVM_MEDIUM)
        lat_mrdreq_dtrreq_hit_q[int'(rtt_q[idx].smi_qos)].push_back(rtt_q[idx].t_dtrreq - rtt_q[idx].t_mrdreq);
    end
    if(rtt_q[idx].CMD_req_recd && rtt_q[idx].AXI_read_addr_recd && rtt_q[idx].cache_ctrl_pkt.currstate == IX) begin
        `uvm_info("calculate_dmi_latency_data_per_qos",$sformatf("pushing latency for axi_ar to cmdreq QOS %0d. t_ar %0t t_cmdreq %0t latency %0d", 
                    rtt_q[idx].smi_qos, rtt_q[idx].t_ar, rtt_q[idx].t_cmdreq, (rtt_q[idx].t_ar - rtt_q[idx].t_cmdreq)/clk_period), UVM_MEDIUM)
        lat_cmdreq_axi_ar_miss_q[int'(rtt_q[idx].smi_qos)].push_back(rtt_q[idx].t_ar - rtt_q[idx].t_cmdreq);
    end
    if(rtt_q[idx].MRD_req_recd && rtt_q[idx].AXI_read_addr_recd && rtt_q[idx].cache_ctrl_pkt.currstate == IX) begin 
        `uvm_info("calculate_dmi_latency_data_per_qos",$sformatf("pushing latency for mrdreq to axi_ar QOS %0d. t_ar %0t t_mrdreq %0t latency %0d", 
                    rtt_q[idx].smi_qos, rtt_q[idx].t_ar, rtt_q[idx].t_mrdreq, (rtt_q[idx].t_ar - rtt_q[idx].t_mrdreq)/clk_period), UVM_MEDIUM)
        lat_mrdreq_axi_ar_miss_q[int'(rtt_q[idx].smi_qos)].push_back(rtt_q[idx].t_ar - rtt_q[idx].t_mrdreq);
    end
    if(rtt_q[idx].CMD_req_recd && rtt_q[idx].STR_req_recd && rtt_q[idx].smi_vz == 0) begin 
        `uvm_info("calculate_dmi_latency_data_per_qos",$sformatf("pushing latency for cmdreq to strreq QOS %0d. t_strreq %0t t_cmdreq %0t latency %0d", 
                    rtt_q[idx].smi_qos, rtt_q[idx].t_strreq, rtt_q[idx].t_cmdreq, (rtt_q[idx].t_strreq - rtt_q[idx].t_cmdreq)/clk_period), UVM_MEDIUM)
        lat_cmdreq_strreq_coh_vz_q[int'(rtt_q[idx].smi_qos)].push_back(rtt_q[idx].t_strreq - rtt_q[idx].t_cmdreq);
    end
    if(rtt_q[idx].AXI_read_data_expd && rtt_q[idx].DTR_req_recd && rtt_q[idx].cache_ctrl_pkt.currstate == IX) begin 
        `uvm_info("calculate_dmi_latency_data_per_qos",$sformatf("pushing latency for dtrreq to axi_r QOS %0d. t_dtrreq %0t t_r %0t latency %0d",
                    rtt_q[idx].smi_qos, rtt_q[idx].t_dtrreq, rtt_q[idx].t_r, (rtt_q[idx].t_dtrreq - rtt_q[idx].t_r)/clk_period), UVM_MEDIUM)
        lat_dtrreq_axi_r_q[int'(rtt_q[idx].smi_qos)].push_back(rtt_q[idx].t_dtrreq - rtt_q[idx].t_r);
    end
    if(rtt_q[idx].DTW_req_recd && rtt_q[idx].AXI_write_addr_recd) begin 
        `uvm_info("calculate_dmi_latency_data_per_qos",$sformatf("pushing latency for dtwreq to axi_aw QOS %0d. t_aw %0t t_dtwreq %0t latency %0d",
                    rtt_q[idx].smi_qos, rtt_q[idx].axi_write_addr_pkt.t_pkt_seen_on_intf, rtt_q[idx].dtw_req_pkt.t_smi_ndp_ready, (rtt_q[idx].axi_write_addr_pkt.t_pkt_seen_on_intf - rtt_q[idx].dtw_req_pkt.t_smi_ndp_ready)/clk_period), UVM_MEDIUM)
        lat_dtwreq_axi_aw_q[int'(rtt_q[idx].smi_qos)].push_back(rtt_q[idx].axi_write_addr_pkt.t_pkt_seen_on_intf - rtt_q[idx].dtw_req_pkt.t_smi_ndp_ready);
    end
    if(rtt_q[idx].DTW_req_recd && rtt_q[idx].AXI_write_data_recd) begin 
        `uvm_info("calculate_dmi_latency_data_per_qos",$sformatf("pushing latency for dtwreq to axi_w QOS %0d. t_w %0t t_dtwreq %0t latency %0d",
                    rtt_q[idx].smi_qos, rtt_q[idx].axi_write_data_pkt.t_wtime[rtt_q[idx].axi_write_data_pkt.t_wtime.size()-1], rtt_q[idx].t_dtwreq, (rtt_q[idx].axi_write_data_pkt.t_wtime[rtt_q[idx].axi_write_data_pkt.t_wtime.size()-1] - rtt_q[idx].t_dtwreq)/clk_period), UVM_MEDIUM)
        lat_dtwreq_axi_w_q[int'(rtt_q[idx].smi_qos)].push_back(rtt_q[idx].axi_write_data_pkt.t_wtime[rtt_q[idx].axi_write_data_pkt.t_wtime.size()-1] - rtt_q[idx].t_dtwreq);
    end
    if(rtt_q[idx].DTW_rsp_recd && rtt_q[idx].AXI_write_resp_recd && rtt_q[idx].smi_vz == 1) begin 
        `uvm_info("calculate_dmi_latency_data_per_qos",$sformatf("pushing latency for dtwrsp to axi_b QOS %0d. t_dtwrsp %0t t_b %0t latency %0d",
                    rtt_q[idx].smi_qos, rtt_q[idx].t_dtwrsp, rtt_q[idx].t_b, (rtt_q[idx].t_dtwrsp - rtt_q[idx].t_b)/clk_period), UVM_MEDIUM)
        lat_axi_b_dtwrsp_q[int'(rtt_q[idx].smi_qos)].push_back(rtt_q[idx].t_dtwrsp - rtt_q[idx].t_b);
    end
    if(rtt_q[idx].DTW_req_recd && rtt_q[idx].DTW_rsp_recd && rtt_q[idx].smi_vz == 0) begin 
        `uvm_info("calculate_dmi_latency_data_per_qos",$sformatf("pushing latency for dtwrsp to dtwreq QOS %0d. t_dtwrsp %0t t_dtwreq %0t latency %0d",
                    rtt_q[idx].smi_qos, rtt_q[idx].t_dtwrsp, rtt_q[idx].t_dtwreq, (rtt_q[idx].t_dtwrsp - rtt_q[idx].t_dtwreq)/clk_period), UVM_MEDIUM)
        lat_dtwreq_dtwrsp_q[int'(rtt_q[idx].smi_qos)].push_back(rtt_q[idx].t_dtwrsp - rtt_q[idx].t_dtwreq);
    end
  end
  else if(queue_type == "wtt") begin
    if(wtt_q[idx].CMD_req_recd && wtt_q[idx].DTR_req_recd && wtt_q[idx].cache_ctrl_pkt.currstate != IX) begin 
        `uvm_info("calculate_dmi_latency_data_per_qos",$sformatf("pushing latency for cmdreq to dtrreq QOS %0d. t_dtrreq %0t t_cmdreq %0t latency %0d", 
                    wtt_q[idx].smi_qos, wtt_q[idx].t_dtrreq, wtt_q[idx].t_cmdreq, (wtt_q[idx].t_dtrreq - wtt_q[idx].t_cmdreq)/clk_period), UVM_MEDIUM)
        lat_cmdreq_dtrreq_hit_q[int'(wtt_q[idx].smi_qos)].push_back(wtt_q[idx].t_dtrreq - wtt_q[idx].t_cmdreq);
    end
    if(wtt_q[idx].MRD_req_recd && wtt_q[idx].DTR_req_recd && wtt_q[idx].cache_ctrl_pkt.currstate != IX) begin 
        `uvm_info("calculate_dmi_latency_data_per_qos",$sformatf("pushing latency for mrdreq to dtrreq QOS %0d. t_dtrreq %0t t_mrdreq %0t latency %0d", 
                    wtt_q[idx].smi_qos, wtt_q[idx].t_dtrreq, wtt_q[idx].t_mrdreq, (wtt_q[idx].t_dtrreq - wtt_q[idx].t_mrdreq)/clk_period), UVM_MEDIUM)
        lat_mrdreq_dtrreq_hit_q[int'(wtt_q[idx].smi_qos)].push_back(wtt_q[idx].t_dtrreq - wtt_q[idx].t_mrdreq);
    end
    if(wtt_q[idx].CMD_req_recd && wtt_q[idx].AXI_read_addr_recd && wtt_q[idx].cache_ctrl_pkt.currstate == IX) begin
        `uvm_info("calculate_dmi_latency_data_per_qos",$sformatf("pushing latency for axi_ar to cmdreq QOS %0d. t_ar %0t t_cmdreq %0t latency %0d", 
                    wtt_q[idx].smi_qos, wtt_q[idx].t_ar, wtt_q[idx].t_cmdreq, (wtt_q[idx].t_ar - wtt_q[idx].t_cmdreq)/clk_period), UVM_MEDIUM)
        lat_cmdreq_axi_ar_miss_q[int'(wtt_q[idx].smi_qos)].push_back(wtt_q[idx].t_ar - wtt_q[idx].t_cmdreq);
    end
    if(wtt_q[idx].MRD_req_recd && wtt_q[idx].AXI_read_addr_recd && wtt_q[idx].cache_ctrl_pkt.currstate == IX) begin 
        `uvm_info("calculate_dmi_latency_data_per_qos",$sformatf("pushing latency for mrdreq to axi_ar QOS %0d. t_ar %0t t_mrdreq %0t latency %0d", 
                    wtt_q[idx].smi_qos, wtt_q[idx].t_ar, wtt_q[idx].t_mrdreq, (wtt_q[idx].t_ar - wtt_q[idx].t_mrdreq)/clk_period), UVM_MEDIUM)
        lat_mrdreq_axi_ar_miss_q[int'(wtt_q[idx].smi_qos)].push_back(wtt_q[idx].t_ar - wtt_q[idx].t_mrdreq);
    end
    if(wtt_q[idx].CMD_req_recd && wtt_q[idx].STR_req_recd && wtt_q[idx].smi_vz == 0) begin 
        `uvm_info("calculate_dmi_latency_data_per_qos",$sformatf("pushing latency for cmdreq to strreq QOS %0d. t_strreq %0t t_cmdreq %0t latency %0d", 
                    wtt_q[idx].smi_qos, wtt_q[idx].t_strreq, wtt_q[idx].t_cmdreq, (wtt_q[idx].t_strreq - wtt_q[idx].t_cmdreq)/clk_period), UVM_MEDIUM)
        lat_cmdreq_strreq_coh_vz_q[int'(wtt_q[idx].smi_qos)].push_back(wtt_q[idx].t_strreq - wtt_q[idx].t_cmdreq);
    end
    if(wtt_q[idx].AXI_read_data_expd && wtt_q[idx].DTR_req_recd && wtt_q[idx].cache_ctrl_pkt.currstate == IX) begin 
        `uvm_info("calculate_dmi_latency_data_per_qos",$sformatf("pushing latency for dtrreq to axi_r QOS %0d. t_dtrreq %0t t_r %0t latency %0d",
                    wtt_q[idx].smi_qos, wtt_q[idx].t_dtrreq, wtt_q[idx].t_r, (wtt_q[idx].t_dtrreq - wtt_q[idx].t_r)/clk_period), UVM_MEDIUM)
        lat_dtrreq_axi_r_q[int'(wtt_q[idx].smi_qos)].push_back(wtt_q[idx].t_dtrreq - wtt_q[idx].t_r);
    end
    if(wtt_q[idx].DTW_req_recd && wtt_q[idx].AXI_write_addr_recd) begin 
        `uvm_info("calculate_dmi_latency_data_per_qos",$sformatf("pushing latency for dtwreq to axi_aw QOS %0d. t_aw %0t t_dtwreq %0t latency %0d",
                    wtt_q[idx].smi_qos, wtt_q[idx].axi_write_addr_pkt.t_pkt_seen_on_intf, wtt_q[idx].dtw_req_pkt.t_smi_ndp_ready, (wtt_q[idx].axi_write_addr_pkt.t_pkt_seen_on_intf - wtt_q[idx].dtw_req_pkt.t_smi_ndp_ready)/clk_period), UVM_MEDIUM)
        lat_dtwreq_axi_aw_q[int'(wtt_q[idx].smi_qos)].push_back(wtt_q[idx].axi_write_addr_pkt.t_pkt_seen_on_intf - wtt_q[idx].dtw_req_pkt.t_smi_ndp_ready);
    end
    if(wtt_q[idx].DTW_req_recd && wtt_q[idx].AXI_write_data_recd) begin 
        `uvm_info("calculate_dmi_latency_data_per_qos",$sformatf("pushing latency for dtwreq to axi_w QOS %0d. t_w %0t t_dtwreq %0t latency %0d",
                    wtt_q[idx].smi_qos, wtt_q[idx].axi_write_data_pkt.t_wtime[wtt_q[idx].axi_write_data_pkt.t_wtime.size()-1], wtt_q[idx].t_dtwreq, (wtt_q[idx].axi_write_data_pkt.t_wtime[wtt_q[idx].axi_write_data_pkt.t_wtime.size()-1] - wtt_q[idx].t_dtwreq)/clk_period), UVM_MEDIUM)
        lat_dtwreq_axi_w_q[int'(wtt_q[idx].smi_qos)].push_back(wtt_q[idx].axi_write_data_pkt.t_wtime[wtt_q[idx].axi_write_data_pkt.t_wtime.size()-1] - wtt_q[idx].t_dtwreq);
    end
    if(wtt_q[idx].DTW_rsp_recd && wtt_q[idx].AXI_write_resp_recd && wtt_q[idx].smi_vz == 1) begin 
        `uvm_info("calculate_dmi_latency_data_per_qos",$sformatf("pushing latency for dtwrsp to axi_b QOS %0d. t_dtwrsp %0t t_b %0t latency %0d",
                    wtt_q[idx].smi_qos, wtt_q[idx].t_dtwrsp, wtt_q[idx].t_b, (wtt_q[idx].t_dtwrsp - wtt_q[idx].t_b)/clk_period), UVM_MEDIUM)
        lat_axi_b_dtwrsp_q[int'(wtt_q[idx].smi_qos)].push_back(wtt_q[idx].t_dtwrsp - wtt_q[idx].t_b);
    end
    if(wtt_q[idx].DTW_req_recd && wtt_q[idx].DTW_rsp_recd && wtt_q[idx].smi_vz == 0) begin 
        `uvm_info("calculate_dmi_latency_data_per_qos",$sformatf("pushing latency for dtwrsp to dtwreq QOS %0d. t_dtwrsp %0t t_dtwreq %0t latency %0d",
                    wtt_q[idx].smi_qos, wtt_q[idx].t_dtwrsp, wtt_q[idx].t_dtwreq, (wtt_q[idx].t_dtwrsp - wtt_q[idx].t_dtwreq)/clk_period), UVM_MEDIUM)
        lat_dtwreq_dtwrsp_q[int'(wtt_q[idx].smi_qos)].push_back(wtt_q[idx].t_dtwrsp - wtt_q[idx].t_dtwreq);
    end
  end
  <% } else {%>
  if(queue_type == "rtt") begin
    if(rtt_q[idx].CMD_req_recd && rtt_q[idx].AXI_read_addr_recd) begin
        `uvm_info("calculate_dmi_latency_data_per_qos",$sformatf("pushing latency for axi_ar to cmdreq QOS %0d. t_ar %0t t_cmdreq %0t latency %0d", 
                    rtt_q[idx].smi_qos, rtt_q[idx].t_ar, rtt_q[idx].t_cmdreq, (rtt_q[idx].t_ar - rtt_q[idx].t_cmdreq)/clk_period), UVM_MEDIUM)
        lat_cmdreq_axi_ar_miss_q[int'(rtt_q[idx].smi_qos)].push_back(rtt_q[idx].t_ar - rtt_q[idx].t_cmdreq);
    end
    if(rtt_q[idx].MRD_req_recd && rtt_q[idx].AXI_read_addr_recd) begin 
        `uvm_info("calculate_dmi_latency_data_per_qos",$sformatf("pushing latency for mrdreq to axi_ar QOS %0d. t_ar %0t t_mrdreq %0t latency %0d", 
                    rtt_q[idx].smi_qos, rtt_q[idx].t_ar, rtt_q[idx].t_mrdreq, (rtt_q[idx].t_ar - rtt_q[idx].t_mrdreq)/clk_period), UVM_MEDIUM)
        lat_mrdreq_axi_ar_miss_q[int'(rtt_q[idx].smi_qos)].push_back(rtt_q[idx].t_ar - rtt_q[idx].t_mrdreq);
    end
    if(rtt_q[idx].CMD_req_recd && rtt_q[idx].STR_req_recd && rtt_q[idx].smi_vz == 0) begin 
        `uvm_info("calculate_dmi_latency_data_per_qos",$sformatf("pushing latency for cmdreq to strreq QOS %0d. t_strreq %0t t_cmdreq %0t latency %0d", 
                    rtt_q[idx].smi_qos, rtt_q[idx].t_strreq, rtt_q[idx].t_cmdreq, (rtt_q[idx].t_strreq - rtt_q[idx].t_cmdreq)/clk_period), UVM_MEDIUM)
        lat_cmdreq_strreq_coh_vz_q[int'(rtt_q[idx].smi_qos)].push_back(rtt_q[idx].t_strreq - rtt_q[idx].t_cmdreq);
    end
    if(rtt_q[idx].AXI_read_data_expd && rtt_q[idx].DTR_req_recd) begin 
        `uvm_info("calculate_dmi_latency_data_per_qos",$sformatf("pushing latency for dtrreq to axi_r QOS %0d. t_dtrreq %0t t_r %0t latency %0d",
                    rtt_q[idx].smi_qos, rtt_q[idx].t_dtrreq, rtt_q[idx].t_r, (rtt_q[idx].t_dtrreq - rtt_q[idx].t_r)/clk_period), UVM_MEDIUM)
        lat_dtrreq_axi_r_q[int'(rtt_q[idx].smi_qos)].push_back(rtt_q[idx].t_dtrreq - rtt_q[idx].t_r);
    end
    if(rtt_q[idx].DTW_req_recd && rtt_q[idx].AXI_write_addr_recd) begin 
        `uvm_info("calculate_dmi_latency_data_per_qos",$sformatf("pushing latency for dtwreq to axi_aw QOS %0d. t_aw %0t t_dtwreq %0t latency %0d",
                    rtt_q[idx].smi_qos, rtt_q[idx].axi_write_addr_pkt.t_pkt_seen_on_intf, rtt_q[idx].dtw_req_pkt.t_smi_ndp_ready, (rtt_q[idx].axi_write_addr_pkt.t_pkt_seen_on_intf - rtt_q[idx].dtw_req_pkt.t_smi_ndp_ready)/clk_period), UVM_MEDIUM)
        lat_dtwreq_axi_aw_q[int'(rtt_q[idx].smi_qos)].push_back(rtt_q[idx].axi_write_addr_pkt.t_pkt_seen_on_intf - rtt_q[idx].dtw_req_pkt.t_smi_ndp_ready);
    end
    if(rtt_q[idx].DTW_req_recd && rtt_q[idx].AXI_write_data_recd) begin 
        `uvm_info("calculate_dmi_latency_data_per_qos",$sformatf("pushing latency for dtwreq to axi_w QOS %0d. t_w %0t t_dtwreq %0t latency %0d",
                    rtt_q[idx].smi_qos, rtt_q[idx].axi_write_data_pkt.t_wtime[rtt_q[idx].axi_write_data_pkt.t_wtime.size()-1], rtt_q[idx].t_dtwreq, (rtt_q[idx].axi_write_data_pkt.t_wtime[rtt_q[idx].axi_write_data_pkt.t_wtime.size()-1] - rtt_q[idx].t_dtwreq)/clk_period), UVM_MEDIUM)
        lat_dtwreq_axi_w_q[int'(rtt_q[idx].smi_qos)].push_back(rtt_q[idx].axi_write_data_pkt.t_wtime[rtt_q[idx].axi_write_data_pkt.t_wtime.size()-1] - rtt_q[idx].t_dtwreq);
    end
    if(rtt_q[idx].DTW_rsp_recd && rtt_q[idx].AXI_write_resp_recd && rtt_q[idx].smi_vz == 1) begin 
        `uvm_info("calculate_dmi_latency_data_per_qos",$sformatf("pushing latency for dtwrsp to axi_b QOS %0d. t_dtwrsp %0t t_b %0t latency %0d",
                    rtt_q[idx].smi_qos, rtt_q[idx].t_dtwrsp, rtt_q[idx].t_b, (rtt_q[idx].t_dtwrsp - rtt_q[idx].t_b)/clk_period), UVM_MEDIUM)
        lat_axi_b_dtwrsp_q[int'(rtt_q[idx].smi_qos)].push_back(rtt_q[idx].t_dtwrsp - rtt_q[idx].t_b);
    end
    if(rtt_q[idx].DTW_req_recd && rtt_q[idx].DTW_rsp_recd && rtt_q[idx].smi_vz == 0) begin 
        `uvm_info("calculate_dmi_latency_data_per_qos",$sformatf("pushing latency for dtwrsp to dtwreq QOS %0d. t_dtwrsp %0t t_dtwreq %0t latency %0d",
                    rtt_q[idx].smi_qos, rtt_q[idx].t_dtwrsp, rtt_q[idx].t_dtwreq, (rtt_q[idx].t_dtwrsp - rtt_q[idx].t_dtwreq)/clk_period), UVM_MEDIUM)
        lat_dtwreq_dtwrsp_q[int'(rtt_q[idx].smi_qos)].push_back(rtt_q[idx].t_dtwrsp - rtt_q[idx].t_dtwreq);
    end
  end
  else if(queue_type == "wtt") begin
    if(wtt_q[idx].CMD_req_recd && wtt_q[idx].AXI_read_addr_recd) begin
        `uvm_info("calculate_dmi_latency_data_per_qos",$sformatf("pushing latency for axi_ar to cmdreq QOS %0d. t_ar %0t t_cmdreq %0t latency %0d", 
                    wtt_q[idx].smi_qos, wtt_q[idx].t_ar, wtt_q[idx].t_cmdreq, (wtt_q[idx].t_ar - wtt_q[idx].t_cmdreq)/clk_period), UVM_MEDIUM)
        lat_cmdreq_axi_ar_miss_q[int'(wtt_q[idx].smi_qos)].push_back(wtt_q[idx].t_ar - wtt_q[idx].t_cmdreq);
    end
    if(wtt_q[idx].MRD_req_recd && wtt_q[idx].AXI_read_addr_recd) begin 
        `uvm_info("calculate_dmi_latency_data_per_qos",$sformatf("pushing latency for mrdreq to axi_ar QOS %0d. t_ar %0t t_mrdreq %0t latency %0d", 
                    wtt_q[idx].smi_qos, wtt_q[idx].t_ar, wtt_q[idx].t_mrdreq, (wtt_q[idx].t_ar - wtt_q[idx].t_mrdreq)/clk_period), UVM_MEDIUM)
        lat_mrdreq_axi_ar_miss_q[int'(wtt_q[idx].smi_qos)].push_back(wtt_q[idx].t_ar - wtt_q[idx].t_mrdreq);
    end
    if(wtt_q[idx].CMD_req_recd && wtt_q[idx].STR_req_recd && wtt_q[idx].smi_vz == 0) begin 
        `uvm_info("calculate_dmi_latency_data_per_qos",$sformatf("pushing latency for cmdreq to strreq QOS %0d. t_strreq %0t t_cmdreq %0t latency %0d", 
                    wtt_q[idx].smi_qos, wtt_q[idx].t_strreq, wtt_q[idx].t_cmdreq, (wtt_q[idx].t_strreq - wtt_q[idx].t_cmdreq)/clk_period), UVM_MEDIUM)
        lat_cmdreq_strreq_coh_vz_q[int'(wtt_q[idx].smi_qos)].push_back(wtt_q[idx].t_strreq - wtt_q[idx].t_cmdreq);
    end
    if(wtt_q[idx].AXI_read_data_expd && wtt_q[idx].DTR_req_recd) begin 
        `uvm_info("calculate_dmi_latency_data_per_qos",$sformatf("pushing latency for dtrreq to axi_r QOS %0d. t_dtrreq %0t t_r %0t latency %0d",
                    wtt_q[idx].smi_qos, wtt_q[idx].t_dtrreq, wtt_q[idx].t_r, (wtt_q[idx].t_dtrreq - wtt_q[idx].t_r)/clk_period), UVM_MEDIUM)
        lat_dtrreq_axi_r_q[int'(wtt_q[idx].smi_qos)].push_back(wtt_q[idx].t_dtrreq - wtt_q[idx].t_r);
    end
    if(wtt_q[idx].DTW_req_recd && wtt_q[idx].AXI_write_addr_recd) begin 
        `uvm_info("calculate_dmi_latency_data_per_qos",$sformatf("pushing latency for dtwreq to axi_aw QOS %0d. t_aw %0t t_dtwreq %0t latency %0d",
                    wtt_q[idx].smi_qos, wtt_q[idx].axi_write_addr_pkt.t_pkt_seen_on_intf, wtt_q[idx].dtw_req_pkt.t_smi_ndp_ready, (wtt_q[idx].axi_write_addr_pkt.t_pkt_seen_on_intf - wtt_q[idx].dtw_req_pkt.t_smi_ndp_ready)/clk_period), UVM_MEDIUM)
        lat_dtwreq_axi_aw_q[int'(wtt_q[idx].smi_qos)].push_back(wtt_q[idx].axi_write_addr_pkt.t_pkt_seen_on_intf - wtt_q[idx].dtw_req_pkt.t_smi_ndp_ready);
    end
    if(wtt_q[idx].DTW_req_recd && wtt_q[idx].AXI_write_data_recd) begin 
        `uvm_info("calculate_dmi_latency_data_per_qos",$sformatf("pushing latency for dtwreq to axi_w QOS %0d. t_w %0t t_dtwreq %0t latency %0d",
                    wtt_q[idx].smi_qos, wtt_q[idx].axi_write_data_pkt.t_wtime[wtt_q[idx].axi_write_data_pkt.t_wtime.size()-1], wtt_q[idx].t_dtwreq, (wtt_q[idx].axi_write_data_pkt.t_wtime[wtt_q[idx].axi_write_data_pkt.t_wtime.size()-1] - wtt_q[idx].t_dtwreq)/clk_period), UVM_MEDIUM)
        lat_dtwreq_axi_w_q[int'(wtt_q[idx].smi_qos)].push_back(wtt_q[idx].axi_write_data_pkt.t_wtime[wtt_q[idx].axi_write_data_pkt.t_wtime.size()-1] - wtt_q[idx].t_dtwreq);
    end
    if(wtt_q[idx].DTW_rsp_recd && wtt_q[idx].AXI_write_resp_recd && wtt_q[idx].smi_vz == 1) begin 
        `uvm_info("calculate_dmi_latency_data_per_qos",$sformatf("pushing latency for dtwrsp to axi_b QOS %0d. t_dtwrsp %0t t_b %0t latency %0d",
                    wtt_q[idx].smi_qos, wtt_q[idx].t_dtwrsp, wtt_q[idx].t_b, (wtt_q[idx].t_dtwrsp - wtt_q[idx].t_b)/clk_period), UVM_MEDIUM)
        lat_axi_b_dtwrsp_q[int'(wtt_q[idx].smi_qos)].push_back(wtt_q[idx].t_dtwrsp - wtt_q[idx].t_b);
    end
    if(wtt_q[idx].DTW_req_recd && wtt_q[idx].DTW_rsp_recd && wtt_q[idx].smi_vz == 0) begin 
        `uvm_info("calculate_dmi_latency_data_per_qos",$sformatf("pushing latency for dtwrsp to dtwreq QOS %0d. t_dtwrsp %0t t_dtwreq %0t latency %0d",
                    wtt_q[idx].smi_qos, wtt_q[idx].t_dtwrsp, wtt_q[idx].t_dtwreq, (wtt_q[idx].t_dtwrsp - wtt_q[idx].t_dtwreq)/clk_period), UVM_MEDIUM)
        lat_dtwreq_dtwrsp_q[int'(wtt_q[idx].smi_qos)].push_back(wtt_q[idx].t_dtwrsp - wtt_q[idx].t_dtwreq);
    end
  end
  <% } %>
endfunction : calculate_dmi_latency_data_per_qos////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

function void dmi_scoreboard::calculate_min_max_avg_latency();
  <%if(obj.useCmc) {%>
  min_latency_cmdreq_dtrreq_hit_q = latency_cmdreq_dtrreq_hit_q.min();
  max_latency_cmdreq_dtrreq_hit_q = latency_cmdreq_dtrreq_hit_q.max();
  min_latency_cmdreq_dtrreq_hit = min_latency_cmdreq_dtrreq_hit_q[0]/clk_period;
  max_latency_cmdreq_dtrreq_hit = max_latency_cmdreq_dtrreq_hit_q[0]/clk_period;
  avg_latency_cmdreq_dtrreq_hit = (latency_cmdreq_dtrreq_hit_q.sum()/latency_cmdreq_dtrreq_hit_q.size())/clk_period;

  min_latency_mrdreq_dtrreq_hit_q = latency_mrdreq_dtrreq_hit_q.min();
  max_latency_mrdreq_dtrreq_hit_q = latency_mrdreq_dtrreq_hit_q.max();
  min_latency_mrdreq_dtrreq_hit = min_latency_mrdreq_dtrreq_hit_q[0]/clk_period;
  max_latency_mrdreq_dtrreq_hit = max_latency_mrdreq_dtrreq_hit_q[0]/clk_period;
  avg_latency_mrdreq_dtrreq_hit = (latency_mrdreq_dtrreq_hit_q.sum()/latency_mrdreq_dtrreq_hit_q.size())/clk_period;
  <% } %>

  min_latency_cmdreq_axi_ar_miss_q = latency_cmdreq_axi_ar_miss_q.min();
  max_latency_cmdreq_axi_ar_miss_q = latency_cmdreq_axi_ar_miss_q.max();
  min_latency_cmdreq_axi_ar_miss = min_latency_cmdreq_axi_ar_miss_q[0]/clk_period;
  max_latency_cmdreq_axi_ar_miss = max_latency_cmdreq_axi_ar_miss_q[0]/clk_period;
  avg_latency_cmdreq_axi_ar_miss = (latency_cmdreq_axi_ar_miss_q.sum()/latency_cmdreq_axi_ar_miss_q.size())/clk_period;

  min_latency_mrdreq_axi_ar_miss_q = latency_mrdreq_axi_ar_miss_q.min();
  max_latency_mrdreq_axi_ar_miss_q = latency_mrdreq_axi_ar_miss_q.max();
  min_latency_mrdreq_axi_ar_miss = min_latency_mrdreq_axi_ar_miss_q[0]/clk_period;
  max_latency_mrdreq_axi_ar_miss = max_latency_mrdreq_axi_ar_miss_q[0]/clk_period;
  avg_latency_mrdreq_axi_ar_miss = (latency_mrdreq_axi_ar_miss_q.sum()/latency_mrdreq_axi_ar_miss_q.size())/clk_period;

  min_latency_cmdreq_strreq_coh_vz_q = latency_cmdreq_strreq_coh_vz_q.min();
  max_latency_cmdreq_strreq_coh_vz_q = latency_cmdreq_strreq_coh_vz_q.max();
  min_latency_cmdreq_strreq_coh_vz = min_latency_cmdreq_strreq_coh_vz_q[0]/clk_period;
  max_latency_cmdreq_strreq_coh_vz = max_latency_cmdreq_strreq_coh_vz_q[0]/clk_period;
  avg_latency_cmdreq_strreq_coh_vz = (latency_cmdreq_strreq_coh_vz_q.sum()/latency_cmdreq_strreq_coh_vz_q.size())/clk_period;

  min_latency_dtrreq_axi_r_q = latency_dtrreq_axi_r_q.min();
  max_latency_dtrreq_axi_r_q = latency_dtrreq_axi_r_q.max();
  min_latency_dtrreq_axi_r = min_latency_dtrreq_axi_r_q[0]/clk_period;
  max_latency_dtrreq_axi_r = max_latency_dtrreq_axi_r_q[0]/clk_period;
  avg_latency_dtrreq_axi_r = (latency_dtrreq_axi_r_q.sum()/latency_dtrreq_axi_r_q.size())/clk_period;

  min_latency_dtwreq_axi_aw_q = latency_dtwreq_axi_aw_q.min();
  max_latency_dtwreq_axi_aw_q = latency_dtwreq_axi_aw_q.max();
  min_latency_dtwreq_axi_aw = min_latency_dtwreq_axi_aw_q[0]/clk_period;
  max_latency_dtwreq_axi_aw = max_latency_dtwreq_axi_aw_q[0]/clk_period;
  avg_latency_dtwreq_axi_aw = (latency_dtwreq_axi_aw_q.sum()/latency_dtwreq_axi_aw_q.size())/clk_period;

  min_latency_dtwreq_axi_w_q = latency_dtwreq_axi_w_q.min();
  max_latency_dtwreq_axi_w_q = latency_dtwreq_axi_w_q.max();
  min_latency_dtwreq_axi_w = min_latency_dtwreq_axi_w_q[0]/clk_period;
  max_latency_dtwreq_axi_w = max_latency_dtwreq_axi_w_q[0]/clk_period;
  avg_latency_dtwreq_axi_w = (latency_dtwreq_axi_w_q.sum()/latency_dtwreq_axi_w_q.size())/clk_period;

  min_latency_axi_b_dtwrsp_q = latency_axi_b_dtwrsp_q.min();
  max_latency_axi_b_dtwrsp_q = latency_axi_b_dtwrsp_q.max();
  min_latency_axi_b_dtwrsp = min_latency_axi_b_dtwrsp_q[0]/clk_period;
  max_latency_axi_b_dtwrsp = max_latency_axi_b_dtwrsp_q[0]/clk_period;
  avg_latency_axi_b_dtwrsp = (latency_axi_b_dtwrsp_q.sum()/latency_axi_b_dtwrsp_q.size())/clk_period;

  min_latency_dtwreq_dtwrsp_q = latency_dtwreq_dtwrsp_q.min();
  max_latency_dtwreq_dtwrsp_q = latency_dtwreq_dtwrsp_q.max();
  min_latency_dtwreq_dtwrsp = min_latency_dtwreq_dtwrsp_q[0]/clk_period;
  max_latency_dtwreq_dtwrsp = max_latency_dtwreq_dtwrsp_q[0]/clk_period;
  avg_latency_dtwreq_dtwrsp = (latency_dtwreq_dtwrsp_q.sum()/latency_dtwreq_dtwrsp_q.size())/clk_period;

  <% if(obj.useCmc) {%>
  `uvm_info(`LABEL, $psprintf("latency_cmdreq_dtrreq_hit: Num of commands %0d, Latency cycle Min : %0d, Max : %0d, Average : %0d",latency_cmdreq_dtrreq_hit_q.size(),min_latency_cmdreq_dtrreq_hit,max_latency_cmdreq_dtrreq_hit,avg_latency_cmdreq_dtrreq_hit), UVM_LOW)
  `uvm_info(`LABEL, $psprintf("latency_mrdreq_dtrreq_hit: Num of commands %0d, Latency cycle Min : %0d, Max : %0d, Average : %0d",latency_mrdreq_dtrreq_hit_q.size(),min_latency_mrdreq_dtrreq_hit,max_latency_mrdreq_dtrreq_hit,avg_latency_mrdreq_dtrreq_hit), UVM_LOW)
  <% } %>
  `uvm_info(`LABEL, $psprintf("latency_cmdreq_axi_ar_miss: Num of commands %0d, Latency cycle Min : %0d, Max : %0d, Average : %0d",latency_cmdreq_axi_ar_miss_q.size(),min_latency_cmdreq_axi_ar_miss,max_latency_cmdreq_axi_ar_miss,avg_latency_cmdreq_axi_ar_miss), UVM_LOW)
  `uvm_info(`LABEL, $psprintf("latency_mrdreq_axi_ar_miss: Num of commands %0d, Latency cycle Min : %0d, Max : %0d, Average : %0d",latency_mrdreq_axi_ar_miss_q.size(),min_latency_mrdreq_axi_ar_miss,max_latency_mrdreq_axi_ar_miss,avg_latency_mrdreq_axi_ar_miss), UVM_LOW)
  `uvm_info(`LABEL, $psprintf("latency_cmdreq_strreq_coh_vz: Num of commands %0d, Latency cycle Min : %0d, Max : %0d, Average : %0d",latency_cmdreq_strreq_coh_vz_q.size(),min_latency_cmdreq_strreq_coh_vz,max_latency_cmdreq_strreq_coh_vz,avg_latency_cmdreq_strreq_coh_vz), UVM_LOW)
  `uvm_info(`LABEL, $psprintf("latency_dtrreq_axi_r: Num of commands %0d, Latency cycle Min : %0d, Max : %0d, Average : %0d",latency_dtrreq_axi_r_q.size(),min_latency_dtrreq_axi_r,max_latency_dtrreq_axi_r,avg_latency_dtrreq_axi_r), UVM_LOW)
  `uvm_info(`LABEL, $psprintf("latency_dtwreq_axi_aw: Num of commands %0d, Latency cycle Min : %0d, Max : %0d, Average : %0d",latency_dtwreq_axi_aw_q.size(),min_latency_dtwreq_axi_aw,max_latency_dtwreq_axi_aw,avg_latency_dtwreq_axi_aw), UVM_LOW)
  `uvm_info(`LABEL, $psprintf("latency_dtwreq_axi_w: Num of commands %0d, Latency cycle Min : %0d, Max : %0d, Average : %0d",latency_dtwreq_axi_w_q.size(),min_latency_dtwreq_axi_w,max_latency_dtwreq_axi_w,avg_latency_dtwreq_axi_w), UVM_LOW)
  `uvm_info(`LABEL, $psprintf("latency_axi_b_dtwrsp: Num of commands %0d, Latency cycle Min : %0d, Max : %0d, Average : %0d",latency_axi_b_dtwrsp_q.size(),min_latency_axi_b_dtwrsp,max_latency_axi_b_dtwrsp,avg_latency_axi_b_dtwrsp), UVM_LOW)
  `uvm_info(`LABEL, $psprintf("latency_dtwreq_dtwrsp: Num of commands %0d, Latency cycle Min : %0d, Max : %0d, Average : %0d",latency_dtwreq_dtwrsp_q.size(),min_latency_dtwreq_dtwrsp,max_latency_dtwreq_dtwrsp,avg_latency_dtwreq_dtwrsp), UVM_LOW)

  if($test$plusargs("latency_check")) check_latency_with_expected_values();
endfunction : calculate_min_max_avg_latency////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

function void dmi_scoreboard::calculate_min_max_avg_latency_per_qos();
  <%if(obj.useCmc) {%>
  for(int k = 0; k < 16; k++) begin
    while(lat_cmdreq_dtrreq_hit_q[k].size() != 0) begin
       lat_cmdreq_dtrreq_hit_queue.push_back(lat_cmdreq_dtrreq_hit_q[k].pop_front());
    end

    if(lat_cmdreq_dtrreq_hit_queue.size() != 0) begin
       min_lat_cmdreq_dtrreq_hit_q = lat_cmdreq_dtrreq_hit_queue.min();
       max_lat_cmdreq_dtrreq_hit_q = lat_cmdreq_dtrreq_hit_queue.max();
       min_lat_cmdreq_dtrreq_hit = min_lat_cmdreq_dtrreq_hit_q[0]/clk_period;
       max_lat_cmdreq_dtrreq_hit = max_lat_cmdreq_dtrreq_hit_q[0]/clk_period;
       avg_lat_cmdreq_dtrreq_hit = (lat_cmdreq_dtrreq_hit_queue.sum()/lat_cmdreq_dtrreq_hit_queue.size())/clk_period;
     `uvm_info(`LABEL, $psprintf("lat_cmdreq_dtrreq_hit QOS %0d: Num of commands %0d, Latency cycle Min : %0d, Max : %0d, Average : %0d",k,lat_cmdreq_dtrreq_hit_queue.size(),min_lat_cmdreq_dtrreq_hit,max_lat_cmdreq_dtrreq_hit,avg_lat_cmdreq_dtrreq_hit), UVM_LOW)
      lat_cmdreq_dtrreq_hit_queue.delete();
    end

    while(lat_mrdreq_dtrreq_hit_q[k].size() != 0) begin
       lat_mrdreq_dtrreq_hit_queue.push_back(lat_mrdreq_dtrreq_hit_q[k].pop_front());
    end

    if(lat_mrdreq_dtrreq_hit_queue.size() != 0) begin
       min_lat_mrdreq_dtrreq_hit_q = lat_mrdreq_dtrreq_hit_queue.min();
       max_lat_mrdreq_dtrreq_hit_q = lat_mrdreq_dtrreq_hit_queue.max();
       min_lat_mrdreq_dtrreq_hit = min_lat_mrdreq_dtrreq_hit_q[0]/clk_period;
       max_lat_mrdreq_dtrreq_hit = max_lat_mrdreq_dtrreq_hit_q[0]/clk_period;
       avg_lat_mrdreq_dtrreq_hit = (lat_mrdreq_dtrreq_hit_queue.sum()/lat_mrdreq_dtrreq_hit_queue.size())/clk_period;
     `uvm_info(`LABEL, $psprintf("lat_mrdreq_dtrreq_hit QOS %0d: Num of commands %0d, Latency cycle Min : %0d, Max : %0d, Average : %0d",k,lat_mrdreq_dtrreq_hit_queue.size(),min_lat_mrdreq_dtrreq_hit,max_lat_mrdreq_dtrreq_hit,avg_lat_mrdreq_dtrreq_hit), UVM_LOW)
      lat_mrdreq_dtrreq_hit_queue.delete();
    end
  end
  <% } %>

  for(int j = 0; j < 16; j++) begin
    while(lat_cmdreq_axi_ar_miss_q[j].size() != 0) begin
       lat_cmdreq_axi_ar_miss_queue.push_back(lat_cmdreq_axi_ar_miss_q[j].pop_front());
    end

    if(lat_cmdreq_axi_ar_miss_queue.size() != 0) begin
       min_lat_cmdreq_axi_ar_miss_q = lat_cmdreq_axi_ar_miss_queue.min();
       max_lat_cmdreq_axi_ar_miss_q = lat_cmdreq_axi_ar_miss_queue.max();
       min_lat_cmdreq_axi_ar_miss = min_lat_cmdreq_axi_ar_miss_q[0]/clk_period;
       max_lat_cmdreq_axi_ar_miss = max_lat_cmdreq_axi_ar_miss_q[0]/clk_period;
       avg_lat_cmdreq_axi_ar_miss = (lat_cmdreq_axi_ar_miss_queue.sum()/lat_cmdreq_axi_ar_miss_queue.size())/clk_period;
     `uvm_info(`LABEL, $psprintf("lat_cmdreq_axi_ar_miss QOS %0d: Num of commands %0d, Latency cycle Min : %0d, Max : %0d, Average : %0d",j,lat_cmdreq_axi_ar_miss_queue.size(),min_lat_cmdreq_axi_ar_miss,max_lat_cmdreq_axi_ar_miss,avg_lat_cmdreq_axi_ar_miss), UVM_LOW)
      lat_cmdreq_axi_ar_miss_queue.delete();
    end

    while(lat_mrdreq_axi_ar_miss_q[j].size() != 0) begin
       lat_mrdreq_axi_ar_miss_queue.push_back(lat_mrdreq_axi_ar_miss_q[j].pop_front());
    end

    if(lat_mrdreq_axi_ar_miss_queue.size() != 0) begin
       min_lat_mrdreq_axi_ar_miss_q = lat_mrdreq_axi_ar_miss_queue.min();
       max_lat_mrdreq_axi_ar_miss_q = lat_mrdreq_axi_ar_miss_queue.max();
       min_lat_mrdreq_axi_ar_miss = min_lat_mrdreq_axi_ar_miss_q[0]/clk_period;
       max_lat_mrdreq_axi_ar_miss = max_lat_mrdreq_axi_ar_miss_q[0]/clk_period;
       avg_lat_mrdreq_axi_ar_miss = (lat_mrdreq_axi_ar_miss_queue.sum()/lat_mrdreq_axi_ar_miss_queue.size())/clk_period;
     `uvm_info(`LABEL, $psprintf("lat_mrdreq_axi_ar_miss QOS %0d: Num of commands %0d, Latency cycle Min : %0d, Max : %0d, Average : %0d",j,lat_mrdreq_axi_ar_miss_queue.size(),min_lat_mrdreq_axi_ar_miss,max_lat_mrdreq_axi_ar_miss,avg_lat_mrdreq_axi_ar_miss), UVM_LOW)
      lat_mrdreq_axi_ar_miss_queue.delete();
    end

    while(lat_cmdreq_strreq_coh_vz_q[j].size() != 0) begin
       lat_cmdreq_strreq_coh_vz_queue.push_back(lat_cmdreq_strreq_coh_vz_q[j].pop_front());
    end

    if(lat_cmdreq_strreq_coh_vz_queue.size() != 0) begin
       min_lat_cmdreq_strreq_coh_vz_q = lat_cmdreq_strreq_coh_vz_queue.min();
       max_lat_cmdreq_strreq_coh_vz_q = lat_cmdreq_strreq_coh_vz_queue.max();
       min_lat_cmdreq_strreq_coh_vz = min_lat_cmdreq_strreq_coh_vz_q[0]/clk_period;
       max_lat_cmdreq_strreq_coh_vz = max_lat_cmdreq_strreq_coh_vz_q[0]/clk_period;
       avg_lat_cmdreq_strreq_coh_vz = (lat_cmdreq_strreq_coh_vz_queue.sum()/lat_cmdreq_strreq_coh_vz_queue.size())/clk_period;
     `uvm_info(`LABEL, $psprintf("lat_cmdreq_strreq_coh_vz QOS %0d: Num of commands %0d, Latency cycle Min : %0d, Max : %0d, Average : %0d",j,lat_cmdreq_strreq_coh_vz_queue.size(),min_lat_cmdreq_strreq_coh_vz,max_lat_cmdreq_strreq_coh_vz,avg_lat_cmdreq_strreq_coh_vz), UVM_LOW)
      lat_cmdreq_strreq_coh_vz_queue.delete();
    end

    while(lat_dtrreq_axi_r_q[j].size() != 0) begin
       lat_dtrreq_axi_r_queue.push_back(lat_dtrreq_axi_r_q[j].pop_front());
    end

    if(lat_dtrreq_axi_r_queue.size() != 0) begin
       min_lat_dtrreq_axi_r_q = lat_dtrreq_axi_r_queue.min();
       max_lat_dtrreq_axi_r_q = lat_dtrreq_axi_r_queue.max();
       min_lat_dtrreq_axi_r = min_lat_dtrreq_axi_r_q[0]/clk_period;
       max_lat_dtrreq_axi_r = max_lat_dtrreq_axi_r_q[0]/clk_period;
       avg_lat_dtrreq_axi_r = (lat_dtrreq_axi_r_queue.sum()/lat_dtrreq_axi_r_queue.size())/clk_period;
     `uvm_info(`LABEL, $psprintf("lat_dtrreq_axi_r QOS %0d: Num of commands %0d, Latency cycle Min : %0d, Max : %0d, Average : %0d",j,lat_dtrreq_axi_r_queue.size(),min_lat_dtrreq_axi_r,max_lat_dtrreq_axi_r,avg_lat_dtrreq_axi_r), UVM_LOW)
      lat_dtrreq_axi_r_queue.delete();
    end

    while(lat_dtwreq_axi_aw_q[j].size() != 0) begin
       lat_dtwreq_axi_aw_queue.push_back(lat_dtwreq_axi_aw_q[j].pop_front());
    end

    if(lat_dtwreq_axi_aw_queue.size() != 0) begin
       min_lat_dtwreq_axi_aw_q = lat_dtwreq_axi_aw_queue.min();
       max_lat_dtwreq_axi_aw_q = lat_dtwreq_axi_aw_queue.max();
       min_lat_dtwreq_axi_aw = min_lat_dtwreq_axi_aw_q[0]/clk_period;
       max_lat_dtwreq_axi_aw = max_lat_dtwreq_axi_aw_q[0]/clk_period;
       avg_lat_dtwreq_axi_aw = (lat_dtwreq_axi_aw_queue.sum()/lat_dtwreq_axi_aw_queue.size())/clk_period;
     `uvm_info(`LABEL, $psprintf("lat_dtwreq_axi_aw QOS %0d: Num of commands %0d, Latency cycle Min : %0d, Max : %0d, Average : %0d",j,lat_dtwreq_axi_aw_queue.size(),min_lat_dtwreq_axi_aw,max_lat_dtwreq_axi_aw,avg_lat_dtwreq_axi_aw), UVM_LOW)
      lat_dtwreq_axi_aw_queue.delete();
    end

    while(lat_dtwreq_axi_w_q[j].size() != 0) begin
       lat_dtwreq_axi_w_queue.push_back(lat_dtwreq_axi_w_q[j].pop_front());
    end

    if(lat_dtwreq_axi_w_queue.size() != 0) begin
       min_lat_dtwreq_axi_w_q = lat_dtwreq_axi_w_queue.min();
       max_lat_dtwreq_axi_w_q = lat_dtwreq_axi_w_queue.max();
       min_lat_dtwreq_axi_w = min_lat_dtwreq_axi_w_q[0]/clk_period;
       max_lat_dtwreq_axi_w = max_lat_dtwreq_axi_w_q[0]/clk_period;
       avg_lat_dtwreq_axi_w = (lat_dtwreq_axi_w_queue.sum()/lat_dtwreq_axi_w_queue.size())/clk_period;
     `uvm_info(`LABEL, $psprintf("lat_dtwreq_axi_w QOS %0d: Num of commands %0d, Latency cycle Min : %0d, Max : %0d, Average : %0d",j,lat_dtwreq_axi_w_queue.size(),min_lat_dtwreq_axi_w,max_lat_dtwreq_axi_w,avg_lat_dtwreq_axi_w), UVM_LOW)
      lat_dtwreq_axi_w_queue.delete();
    end

    while(lat_axi_b_dtwrsp_q[j].size() != 0) begin
       lat_axi_b_dtwrsp_queue.push_back(lat_axi_b_dtwrsp_q[j].pop_front());
    end

    if(lat_axi_b_dtwrsp_queue.size() != 0) begin
       min_lat_axi_b_dtwrsp_q = lat_axi_b_dtwrsp_queue.min();
       max_lat_axi_b_dtwrsp_q = lat_axi_b_dtwrsp_queue.max();
       min_lat_axi_b_dtwrsp = min_lat_axi_b_dtwrsp_q[0]/clk_period;
       max_lat_axi_b_dtwrsp = max_lat_axi_b_dtwrsp_q[0]/clk_period;
       avg_lat_axi_b_dtwrsp = (lat_axi_b_dtwrsp_queue.sum()/lat_axi_b_dtwrsp_queue.size())/clk_period;
     `uvm_info(`LABEL, $psprintf("lat_axi_b_dtwrsp QOS %0d: Num of commands %0d, Latency cycle Min : %0d, Max : %0d, Average : %0d",j,lat_axi_b_dtwrsp_queue.size(),min_lat_axi_b_dtwrsp,max_lat_axi_b_dtwrsp,avg_lat_axi_b_dtwrsp), UVM_LOW)
      lat_axi_b_dtwrsp_queue.delete();
    end

    while(lat_dtwreq_dtwrsp_q[j].size() != 0) begin
       lat_dtwreq_dtwrsp_queue.push_back(lat_dtwreq_dtwrsp_q[j].pop_front());
    end

    if(lat_dtwreq_dtwrsp_queue.size() != 0) begin
       min_lat_dtwreq_dtwrsp_q = lat_dtwreq_dtwrsp_queue.min();
       max_lat_dtwreq_dtwrsp_q = lat_dtwreq_dtwrsp_queue.max();
       min_lat_dtwreq_dtwrsp = min_lat_dtwreq_dtwrsp_q[0]/clk_period;
       max_lat_dtwreq_dtwrsp = max_lat_dtwreq_dtwrsp_q[0]/clk_period;
       avg_lat_dtwreq_dtwrsp = (lat_dtwreq_dtwrsp_queue.sum()/lat_dtwreq_dtwrsp_queue.size())/clk_period;
     `uvm_info(`LABEL, $psprintf("lat_dtwreq_dtwrsp QOS %0d: Num of commands %0d, Latency cycle Min : %0d, Max : %0d, Average : %0d",j,lat_dtwreq_dtwrsp_queue.size(),min_lat_dtwreq_dtwrsp,max_lat_dtwreq_dtwrsp,avg_lat_dtwreq_dtwrsp), UVM_LOW)
      lat_dtwreq_dtwrsp_queue.delete();
    end
   end

  //if($test$plusargs("latency_check")) check_latency_with_expected_values();
endfunction : calculate_min_max_avg_latency_per_qos/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// 

//#Check.DMI.QosHPLatency
//#Check.DMI.QosLPLatency
function void dmi_scoreboard::check_latency_with_expected_values();
    <% if(obj.useCmc) { %>
        if(min_latency_cmdreq_dtrreq_hit != CMDREQ_DTRREQ) `uvm_error(`LABEL_ERROR, "cmdreq to dtrreq latency doesn't match")
        if(min_latency_mrdreq_dtrreq_hit != MRDREQ_DTRREQ) `uvm_error(`LABEL_ERROR, "mrdreq to dtrreq latency doesn't match")
        if(min_latency_cmdreq_axi_ar_miss != CMDREQ_AXIAR) `uvm_error(`LABEL_ERROR, "cmdreq to axi ar latency doesn't match")
        if(min_latency_mrdreq_axi_ar_miss != MRDREQ_AXIAR) `uvm_error(`LABEL_ERROR, "mrdreq to axi ar latency doesn't match")
        if(min_latency_cmdreq_strreq_coh_vz != CMDREQ_STRREQ) `uvm_error(`LABEL_ERROR, "cmdreq to strreq latency doesn't match")
        if(min_latency_dtrreq_axi_r != DTRREQ_AXIR) `uvm_error(`LABEL_ERROR, "dtrreq to axi r latency doesn't match")
        if(min_latency_dtwreq_axi_aw != DTWREQ_AXIAW) `uvm_error(`LABEL_ERROR, "dtwreq to axi aw latency doesn't match")
        if(min_latency_dtwreq_axi_w != DTWREQ_AXIW) `uvm_error(`LABEL_ERROR, "dtwreq to axi w latency doesn't match")
        if(min_latency_axi_b_dtwrsp != AXIB_DTWRSP) `uvm_error(`LABEL_ERROR, "dtwrsp to axi b latency doesn't match")
        if(min_latency_dtwreq_dtwrsp != DTWREQ_DTWRSP) `uvm_error(`LABEL_ERROR, "dtwreq to dtwrsp latency doesn't match")
    <% } else {%>
        if(min_latency_cmdreq_axi_ar_miss != CMDREQ_AXIAR) `uvm_error(`LABEL_ERROR, "cmdreq to axi ar latency doesn't match")
        if(min_latency_mrdreq_axi_ar_miss != MRDREQ_AXIAR) `uvm_error(`LABEL_ERROR, "mrdreq to axi ar latency doesn't match")
        if(min_latency_cmdreq_strreq_coh_vz != CMDREQ_STRREQ) `uvm_error(`LABEL_ERROR, "cmdreq to strreq latency doesn't match")
        if(min_latency_dtrreq_axi_r != DTRREQ_AXIR) `uvm_error(`LABEL_ERROR, "dtrreq to axi r latency doesn't match")
        if(min_latency_dtwreq_axi_aw != DTWREQ_AXIAW) `uvm_error(`LABEL_ERROR, "dtwreq to axi aw latency doesn't match")
        if(min_latency_dtwreq_axi_w != DTWREQ_AXIW) `uvm_error(`LABEL_ERROR, "dtwreq to axi w latency doesn't match")
        if(min_latency_axi_b_dtwrsp != AXIB_DTWRSP) `uvm_error(`LABEL_ERROR, "dtwrsp to axi b latency doesn't match")
        if(min_latency_dtwreq_dtwrsp != DTWREQ_DTWRSP) `uvm_error(`LABEL_ERROR, "dtwreq to dtwrsp latency doesn't match")
    <% } %>
    `uvm_info(`LABEL, "latency check passed!!!!!", UVM_MEDIUM)
endfunction : check_latency_with_expected_values


function void dmi_scoreboard::update_rx_counter();
  int count_q[$];
  count_q = wtt_q.find_index with (item.is_axi_AW_pending());
  dmi_rx_counter = count_q.size();
endfunction
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// 
// SMI interface channels
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// 
function void dmi_scoreboard::write_smi(smi_seq_item m_pkt);
  smi_seq_item  m_packet, dtw_pkt, ex_pkt;
  uvm_event ev_wrong_targ_id = ev_pool.get("ev_wrong_targ_id");
  initialize_csr();
    <% if(obj.useCmc){%>
    <% if(obj.useCmc && obj.DmiInfo[obj.Id].ccpParams.useScratchpad){%>
       if(create_sp_q == 0)begin
          create_SP_q();
          create_sp_q =1;
        end
    <%}%>
    <%}%>
  m_packet = new();
  m_packet.do_copy(m_pkt);

  `uvm_info("<%=obj.BlockId%>:write_smi", $sformatf("Entered..."), UVM_MEDIUM)
  `uvm_info("<%=obj.BlockId%>:write_smi", $sformatf("%1p",m_pkt), UVM_MEDIUM)
  `ifndef FSYS_COVER_ON
  cov.collect_wr_inflight(wtt_q, m_packet);
  cov.collect_rd_inflight(rtt_q, m_packet);
  `endif
  // get error statistics
  if(m_pkt.ndp_corr_error || m_pkt.hdr_corr_error || m_pkt.dp_corr_error) begin
    update_resiliency_ce_cnt(m_pkt);
  end
  num_smi_corr_err    += m_pkt.ndp_corr_error + m_pkt.hdr_corr_error + m_pkt.dp_corr_error;
  num_smi_uncorr_err  += m_pkt.ndp_uncorr_error + m_pkt.hdr_uncorr_error + m_pkt.dp_uncorr_error;
  num_smi_parity_err  += m_pkt.ndp_parity_error + m_pkt.hdr_uncorr_error + m_pkt.dp_parity_error;
  /////////////////////////////////////////////////////
  //#Check.DMI.Concerto.v3.0.DmiFunitId
  //#Check.DMI.Concerto.v3.0.MrdReqDmiunitId
  //#Check.DMI.Concerto.v3.0.DtrRspDmiunitId
  //#Check.DMI.Concerto.v3.0.DtwReqDmiunitId
  //#Check.DMI.Concerto.v3.0.RbReqDmiunitId
  //#Check.DMI.Concerto.v3.0.MrdReqWrongDmiunitId
  ///////////////////////////////////////////////////
  if((m_pkt.isMrdMsg() || m_pkt.isDtwMsg() || m_pkt.isDtrRspMsg() || m_pkt.isRbMsg() || m_pkt.isRbUseRspMsg() || m_pkt.isCmdMsg() || m_pkt.isStrRspMsg() || m_pkt.isDtwDbgRspMsg()) &&  (m_pkt.smi_targ_ncore_unit_id != <%=obj.DmiInfo[obj.Id].FUnitId%>) )begin
    `uvm_info("<%=obj.BlockId%>:write_smi", $sformatf("DMI received txn with wrong targ_ncore_unit_id Expected: <%=obj.DmiInfo[obj.Id].FUnitId%> Received:%0x",m_pkt.smi_targ_ncore_unit_id), UVM_LOW)
    `uvm_info("<%=obj.BlockId%>:write_smi", $sformatf("DMI will drop this txn, if TransErrDetEn=1 Dmi will log it "), UVM_LOW)
    if(m_cfg.m_args.k_wrong_target_id) begin
      wrng_targ_id_err = 1;
      ev_wrong_targ_id.trigger(m_pkt);
    end
  end
  else if((m_pkt.ndp_uncorr_error || m_pkt.hdr_uncorr_error || m_pkt.dp_uncorr_error || uncorr_wrbuffer_err) ||
         (m_pkt.ndp_parity_error || m_pkt.hdr_parity_error || m_pkt.dp_parity_error))  begin
    `uvm_info($sformatf("%m"), $sformatf("WRITE SMI input\n%p\n has UNcorrectable error, and is dropped", m_pkt), UVM_LOW)
    //-> kill_test;
  end 
  else if(m_pkt.isMrdMsg())begin
    processMrdReq(m_packet);
    numCmd++;
    //->smi_raise;
  end
  else if(m_pkt.isMrdRspMsg())begin
    processMrdRsp(m_packet);
  end
  else if(m_pkt.isDtrMsg()) begin
    processDtrReq(m_packet);
    numDtrTxns++;
  end
  else if(m_pkt.isDtrRspMsg()) begin
    processDtrRsp(m_packet);
  end
  else if(m_pkt.isDtwMsg()) begin
    numDtwTxns++;
    //`ifdef DATA_ADEPT
    //   dtw_pkt = rearrangedtwdata(m_packet);
    //`else 
    //   dtw_pkt = m_packet;
    //`endif
    processDtwReq(m_packet);
  end
  else if(m_pkt.isDtwRspMsg() && uncorr_wrbuffer_err == 0) begin
    processDtwRsp(m_packet);
  end
  //#Check.DMI.Concerto.v3.0.RbReqType
  else if(m_pkt.isRbMsg()) begin
    processRbReq(m_packet);
  end
  else if(m_pkt.isRbRspMsg()) begin
    processRbRsp(m_packet);
  end
  else if(m_pkt.isCmdMsg())begin
    processCmdReq(m_packet);
    numCmd++;
    //->smi_raise;
  end
  else if(m_pkt.isNcCmdRspMsg())begin
    processCmdRsp(m_packet);
  end
  else if(m_pkt.isStrMsg())begin
    processStrReq(m_packet);
  end
  else if(m_pkt.isStrRspMsg())begin
    processStrRsp(m_packet);
  end 
  else if(m_pkt.isDtwDbgReqMsg())begin
    processDtwDbgReqMsg(m_packet); 
  end
  else if(m_pkt.isDtwDbgRspMsg())begin
    processDtwDbgRspMsg(m_packet);
  end
  else if(m_pkt.isSysReqMsg())begin
    processSysReq(m_packet);
  end
  else if(m_pkt.isSysRspMsg())begin
    processSysRsp(m_packet);
  end
  else if (uncorr_wrbuffer_err == 0) begin
     if (!force_axi_stall_en) begin:perfmon_disable_err_check// disable this check for some special perfmon testcases
    `uvm_error("<%=obj.BlockId%>-SCB", $sformatf("Unknown message type is received on write_smi port smi_msg_type:%0h", m_pkt.smi_msg_type))
    end
  end
  update_rx_counter();
  `ifndef FSYS_COVER_ON
        cov.collect_smi_seq_item(m_packet);
  `endif
endfunction : write_smi

///////////////////////////////////////////////
// Getting every DP beat
//////////////////////////////////////////////
function void dmi_scoreboard::write_smi_every_beat(smi_seq_item m_pkt);
  int tmp_q[$];
  smi_seq_item  m_packet;
  m_packet = new();
  m_packet.do_copy(m_pkt);

  `uvm_info("<%=obj.BlockId%>:write_smi_every_beat", $sformatf("%1p",m_pkt), UVM_MEDIUM)
  tmp_q = {};
  tmp_q = rtt_q.find_index with((item.smi_rbid == m_pkt.smi_rbid) &&
                               (item.STR_req_recd == 1) &&
                               (item.DTW_req_recd == 0) &&
                               (item.smi_msg_type inside {CMD_RD_ATM,CMD_WR_ATM,CMD_CMP_ATM,CMD_SW_ATM}));

  if(m_pkt.isDtwMsg()) begin
    if(!smi_dp_last && !m_packet.smi_dp_last)begin
      processDtwReq(m_packet);
      smi_dp_last = 1;
    end
  end
  if(m_packet.smi_dp_last || (m_packet.smi_msg_type == DTW_NO_DATA))begin
    smi_dp_last = 0;
  end
endfunction : write_smi_every_beat
///////////////////////////////////////////////
// Getting every DP beat
//////////////////////////////////////////////
function void dmi_scoreboard::write_dmi_rtl_port(<%=obj.BlockId%>_rtl_cmd_rsp_pkt m_pkt);
  int tmp_q[$],tmp_q1[$],tmp_q2[$],idx;
  dmi_scb_txn txn;
  <%=obj.BlockId%>_rtl_cmd_rsp_pkt m_packet;
  m_packet = new();
  m_packet.copy(m_pkt);
  
  `uvm_info("<%=obj.BlockId%>:write_dmi_rtl_port", $sformatf("%1p",m_packet), UVM_MEDIUM)
  if(m_packet.isCmd)begin
  tmp_q  = rtt_q.find_index with ((item.isNcRd || item.isCmdPref || item.isAtomic) && 
                                  (item.cmd_src_unit_id == m_packet.cmd_rsp_push_targ_id) && 
                                  (item.cmd_msg_id== m_packet.cmd_rsp_push_rmsg_id) && 
                                  (item.CMD_rsp_recd_rtl == 0));

  tmp_q1 = wtt_q.find_index with ((item.isNcWr) && 
                                  (item.cmd_src_unit_id == m_packet.cmd_rsp_push_targ_id) && 
                                  (item.cmd_msg_id== m_packet.cmd_rsp_push_rmsg_id) && 
                                  (item.CMD_rsp_recd_rtl == 0));
  end
  else if(m_packet.isMrd)begin
    tmp_q  = rtt_q.find_index with ((item.isMrd) && 
                                    (cl_aligned(item.cache_addr) === cl_aligned(m_packet.mrd_pop_addr)) && 
                                    security_match(item.security, m_packet.mrd_pop_ns) &&
                                    item.mrd_req_pkt.smi_msg_id == m_packet.mrd_pop_msg_id &&
                                    item.mrd_req_pkt.smi_src_ncore_unit_id== m_packet.mrd_pop_initiator_id &&
                                    (item.MRD_req_recd_rtl == 0 )); 
  end
  else begin
    `uvm_error("<%=obj.BlockId%>:write_dmi_rtl_port",$sformatf("unexpected packet isCmd:%0b isMrd:%0b",m_packet.isCmd,m_packet.isMrd))
  end

  if ((tmp_q.size +tmp_q1.size) == 0) begin
     `uvm_info("<%=obj.BlockId%>:dmi_rtl_port", $sformatf("%1p",m_packet), UVM_LOW)
     if(m_packet.isCmd)begin
        `uvm_error("<%=obj.BlockId%>:dmi_rtl_port", "smi_msg_id for CMDrsp not found")
     end
     else begin
        `uvm_error("<%=obj.BlockId%>:dmi_rtl_port", "smi_msg_id for MrdReq not found")
     end
  end
  else if ((tmp_q.size+tmp_q1.size) > 1) begin
     `uvm_info("<%=obj.BlockId%>:dmi_rtl_port", $sformatf("%1p",m_packet), UVM_LOW)
    foreach(tmp_q[i]) begin
      rtt_q[tmp_q[i]].print_entry();
    end
     if(m_packet.isCmd)begin
       `uvm_error("<%=obj.BlockId%>:dmi_rtl_port", "smi_rmsg_id for Cmdrsp matches multiple outstanding requests from same source")
     end
     else begin
       `uvm_error("<%=obj.BlockId%>:dmi_rtl_port", "smi_rmsg_id for MrdReq matches multiple outstanding requests from same source")
     end
  end
  else begin
    if(m_packet.isCmd)begin
      if(tmp_q.size == 1)begin
        txn = rtt_q[tmp_q[0]];
        tmp_q2  = wtt_q.find_index with ((item.isNcWr) && 
                                     (cl_aligned((item.cache_addr)) === cl_aligned(txn.cache_addr)) && 
                                     security_match(item.security, txn.security) &&
                                     (item.CMD_rsp_recd_rtl == 1) &&
                                     (item.AXI_write_resp_expd == 1 && !(item.AXI_write_resp_recd))); 
        <% if(obj.useCmc) { %>
        txn.wrOutstandingcnt = tmp_q2.size();
        if(txn.smi_msg_type inside {CMD_CLN_INV,CMD_CLN_VLD,CMD_MK_INV,CMD_CLN_SH_PER})begin
          if(tmp_q2.size()>0 && txn.smi_vz )begin
            txn.wrOutstandingFlag = 1;
          end
        end
        <% } %>
        <%if (obj.DmiInfo[obj.Id].fnEnableQos) { %>
        if(m_packet.cmd_starv_mode && !previous_cmd_starv_mode) begin 
          sb_stall_if.perf_count_events["Number_of_QoS_Starvations"].push_back(1);
          previous_cmd_starv_mode = 1;
        end
        if (!m_packet.cmd_starv_mode) previous_cmd_starv_mode=0;
        `ifdef QOS_CHK_EN
        if(!m_packet.cmd_starv_mode)begin 
          tmp_q2  = rtt_q.find_index with((item.isNcRd || item.isCmdPref || item.isAtomic) && (item.CMD_rsp_recd_rtl == 0));
          if(tmp_q2.size()>1)begin
            idx  = got_entry_asper_qos(0,1); 
            if(idx != tmp_q[0])begin
              `uvm_info("<%=obj.BlockId%>:dmi_rtl_port", $sformatf("%1p",m_packet), UVM_LOW)
              `uvm_info("<%=obj.BlockId%>:dmi_rtl_port",$sformatf("tmp_q[0] :%0d",tmp_q[0]),UVM_LOW);
              rtt_q[tmp_q[0]].print_entry_eos();
              `uvm_info("<%=obj.BlockId%>:dmi_rtl_port",$sformatf("idx      :%0d",idx),UVM_LOW);
              rtt_q[idx].print_entry_eos();
             `uvm_error("<%=obj.BlockId%>:dmi_rtl_port",$sformatf("NcRd Rtt entry not matching as per Qos RTL prio:%0x, Tb prio:%0x",ncoreConfigInfo::qos_mapping(rtt_q[tmp_q[0]].smi_qos),ncoreConfigInfo::qos_mapping(rtt_q[idx].smi_qos)))
            end
          end
        end
        `endif
        <% } %>
      end
      else begin
        txn = wtt_q[tmp_q1[0]];
        <%if (obj.DmiInfo[obj.Id].fnEnableQos) { %>
        if(m_packet.cmd_starv_mode && !previous_cmd_starv_mode) begin 
          sb_stall_if.perf_count_events["Number_of_QoS_Starvations"].push_back(1);
          previous_cmd_starv_mode = 1;
        end
        if (!m_packet.cmd_starv_mode) previous_cmd_starv_mode=0;
        `ifdef QOS_CHK_EN
        if(!m_packet.cmd_starv_mode)begin 
          tmp_q2  = wtt_q.find_index with ((item.isNcWr ) && (item.CMD_rsp_recd_rtl == 0));
          if(tmp_q2.size()>1)begin
            idx  = got_entry_asper_qos(0,0); 
            if(idx != tmp_q1[0])begin
              `uvm_info("<%=obj.BlockId%>:dmi_rtl_port",$sformatf("tmp_q1[0] :%0d",tmp_q1[0]),UVM_LOW);
              wtt_q[tmp_q1[0]].print_entry_eos();
              `uvm_info("<%=obj.BlockId%>:dmi_rtl_port",$sformatf("idx      :%0d",idx),UVM_LOW);
              wtt_q[idx].print_entry_eos();
              `uvm_error("<%=obj.BlockId%>:dmi_rtl_port",$sformatf("NcWr Wtt entry not matching as per Qos RTL prio:%0x, Tb prio:%0x",ncoreConfigInfo::qos_mapping(wtt_q[tmp_q1[0]].smi_qos),ncoreConfigInfo::qos_mapping(wtt_q[idx].smi_qos)))
            end
          end
        end
        `endif
        <% } %>
      end
      txn.cmd_rsp_pkt_rtl   = m_packet;
      txn.CMD_rsp_recd_rtl  = 1;
      txn.t_creation     = $time;
    end
    else begin
      txn = rtt_q[tmp_q[0]];
      <%if (obj.DmiInfo[obj.Id].fnEnableQos) { %>
      if(m_packet.mrd_starv_mode && !previous_mrd_starv_mode) begin 
        sb_stall_if.perf_count_events["Number_of_QoS_Starvations"].push_back(1);
        previous_mrd_starv_mode = 1;
      end
      if (!m_packet.mrd_starv_mode) previous_mrd_starv_mode=0;
      `ifdef QOS_CHK_EN
      if(!m_packet.mrd_starv_mode)begin 
        tmp_q2  = rtt_q.find_index with ((item.isMrd) && (item.MRD_req_recd_rtl == 0));
        if(tmp_q2.size()>1)begin
          idx  = got_entry_asper_qos(1,1,tmp_q[0]); 
          if(idx != tmp_q[0])begin
            `uvm_info("<%=obj.BlockId%>:dmi_rtl_port",$sformatf("tmp_q[0] :%0d",tmp_q[0]),UVM_LOW);
            rtt_q[tmp_q[0]].print_entry_eos();
            `uvm_info("<%=obj.BlockId%>:dmi_rtl_port",$sformatf("idx      :%0d",idx),UVM_LOW);
            rtt_q[idx].print_entry_eos();
            `uvm_error("<%=obj.BlockId%>:dmi_rtl_port",$sformatf("Mrd Rtt entry not matching as per Qos RTL prio:%0x, Tb prio:%0x",ncoreConfigInfo::qos_mapping(rtt_q[tmp_q[0]].smi_qos),ncoreConfigInfo::qos_mapping(rtt_q[idx].smi_qos)))
          end
        end
      end
      `endif
      <% } %>
      txn.mrd_req_pkt_rtl   = m_packet;
      txn.MRD_req_recd_rtl  = 1;
      txn.t_creation     = $time;
    end
  end
endfunction : write_dmi_rtl_port///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

function void dmi_scoreboard::write_dmi_tt_port(<%=obj.BlockId%>_tt_alloc_pkt m_pkt); 
  <%=obj.BlockId%>_tt_alloc_pkt m_packet;
  m_packet = new();
  m_packet.copy(m_pkt);

 `uvm_info("<%=obj.BlockId%>:dmi_tt_port", $sformatf("%1p", m_packet.sprint_pkt()), UVM_MEDIUM) 

  if(m_packet.isRtt && m_packet.dealloc_vld) begin
    rtt_entries--;
    sb_stall_if.perf_count_events["Active_RTT_entries"].push_back(rtt_entries);
  end
  if(m_packet.isWtt && m_packet.dealloc_vld) begin
    wtt_entries--;
    sb_stall_if.perf_count_events["Active_WTT_entries"].push_back(wtt_entries);
  end
  if(m_packet.isRtt && m_packet.alloc_valid) begin
    rtt_entries++;
    sb_stall_if.perf_count_events["Active_RTT_entries"].push_back(rtt_entries);
  end
  if(m_packet.isWtt && m_packet.alloc_valid) begin
    wtt_entries++;
    sb_stall_if.perf_count_events["Active_WTT_entries"].push_back(wtt_entries);
  end

endfunction : write_dmi_tt_port
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Write Arbiter Probe (although whiteboxing is not the preferred way, it's unavoidable in this case)
// To maintain integrity, do not model any checks relying on this interface.
//
// This probe observes the arbiter inputs and tracks write transactions that lead to a read on the AR/R channel
// Based on the observed transaction, a valid match is found in transaction table and the time at the arbiter is recorded.
// If not matches are found(the transaction has arrived earlier than a TT element is created in DV), push it into a queue, match later.
// The time at the arbiter is used to order the reads received at the native I/F for the AR/R channel. 
// Oldest, first.
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function void dmi_scoreboard::write_dmi_write_probe_port(<%=obj.BlockId%>_write_probe_txn pkt);
  int rd_match_q[$],wr_match_q[$];
  <%=obj.BlockId%>_write_probe_txn m_pkt;
  m_pkt = new();
  m_pkt.copy(pkt);
  
  rd_match_q = rtt_q.find_index with(
                                  ( (item.isDtwMrgMrd 
                                    && (item.dtw_req_pkt.smi_mpf2 == m_pkt.rmsg_id)
                                    && (item.dtw_req_pkt.smi_msg_type == m_pkt.cmd_type))
                                    && (m_pkt.dtw_aiu_id>>1) == item.dtw_req_pkt.smi_src_ncore_unit_id
                                  ||(item.isAtomic
                                    && item.DTW_req_recd
                                    && (item.dtw_req_pkt.smi_msg_id == m_pkt.rmsg_id)
                                    && (item.cmd_req_pkt.smi_msg_type == m_pkt.cmd_type))
                                    && (m_pkt.aiu_id>>1) == item.dtw_req_pkt.smi_src_ncore_unit_id
                                  )
                                  && item.cache_addr == m_pkt.addr
                                  && security_match(item.security,m_pkt.ns)
                                  && !item.seenAtWriteArb && !item.isCacheHit
                                  );
  wr_match_q = wtt_q.find_index with(
                                  item.cache_addr == m_pkt.addr
                                  && item.dtw_req_pkt.smi_mpf2 == m_pkt.rmsg_id
                                  && security_match(item.security,m_pkt.ns)
                                  && !item.seenAtWriteArb
                                  );

  if(rd_match_q.size() == 0)begin
    rd_match_q = rtt_q.find_index with(item.isDtwMrgMrd);
    wr_arb_q.push_back(m_pkt);
    `uvm_info("write_dmi_write_probe_port", $sformatf("Pushing into wr_arb_q | Addr:%0h CmdType:%0h | RTT(size=%0d) || write match:%0d in WTT(size=%0d) wr_arb_q=%0d", m_pkt.addr, m_pkt.cmd_type, rtt_q.size, wr_match_q.size, wtt_q.size, wr_arb_q.size),UVM_MEDIUM)
  end
  else if(rd_match_q.size() > 1) begin
    `uvm_info("write_dmi_write_probe_port", $sformatf("----------------------------------------------------------------------------------------------BEGIN"),UVM_MEDIUM)
    foreach(rd_match_q[i])begin
     //For corner case debug. Remove once regressions are stable TODO: VIK
      rtt_q[rd_match_q[i]].print_entry();
      `uvm_info("write_dmi_write_probe_port",$sformatf("RTT --- CmdType:%0h Addr:%0h AiuId:%0h RmsgId:%0h MsgId:%0h NS:%0d (flg-%0b|%0b|%0b)", 
      rtt_q[rd_match_q[i]].smi_msg_type, rtt_q[rd_match_q[i]].cache_addr, rtt_q[rd_match_q[i]].dtw_req_pkt.smi_src_ncore_unit_id, rtt_q[rd_match_q[i]].dtw_req_pkt.smi_mpf2_dtr_msg_id, 
      rtt_q[rd_match_q[i]].dtw_req_pkt.smi_msg_id, rtt_q[rd_match_q[i]].security, rtt_q[rd_match_q[i]].seenAtWriteArb, rtt_q[rd_match_q[i]].isCoh,rtt_q[rd_match_q[i]].isAtomic),UVM_MEDIUM);
      `uvm_info("write_dmi_write_probe_port",$sformatf("PKT --- CmdType:%0h Addr:%0h AiuId:%0h RmsgId:%0h NS:%0d", m_pkt.cmd_type, m_pkt.addr, m_pkt.aiu_id, m_pkt.rmsg_id, m_pkt.ns),UVM_MEDIUM);
    end
    `uvm_info("write_dmi_write_probe_port", $sformatf("----------------------------------------------------------------------------------------------END"),UVM_MEDIUM)

    `uvm_info("write_dmi_write_probe_port", $sformatf("|-INT_RD_M_ERR-|Code incremental filters. Found multiple matches for Addr:%0h CmdType:%0h in RTT(size=%0d)", m_pkt.addr, m_pkt.cmd_type, rtt_q.size),UVM_LOW)
  end
  else begin
     `uvm_info("write_dmi_write_probe_port", $sformatf("Found a match"),UVM_MEDIUM)
     rtt_q[rd_match_q[0]].t_at_write_arbiter = m_pkt.t_pkt;
     rtt_q[rd_match_q[0]].seenAtWriteArb = 1;
     rtt_q[rd_match_q[0]].write_arb_pkt = m_pkt;
     rtt_q[rd_match_q[0]].print_entry();
     `uvm_info("DMI_SCB", $psprintf("DMI_UID:%0d: WRITE_PROBE_FOR_AXI: %s", rtt_q[rd_match_q[0]].txn_id, m_pkt.sprint_pkt()), UVM_LOW)
     updateRttentry(rtt_q[rd_match_q[0]], rd_match_q[0]);
  end
endfunction

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Read Arbiter Probe (although whiteboxing is not the preferred way, it's unavoidable in this case)
// To maintain integrity, do not model any checks relying on this interface.
//
// This probe observes the arbiter inputs and tracks read transactions that lead to activity on the AR/R channel
// Based on the observed transaction, a valid match is found in read transaction table and the time at the arbiter is recorded
// Cache management operations are skipped and any atomics or merge writes.
// The time at the arbiter is used to order the reads received at the native I/F for the AR/R channel. 
// Oldest, first.
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

function void dmi_scoreboard::write_dmi_read_probe_port(<%=obj.BlockId%>_read_probe_txn pkt);
   int match_q[$], coh_q[$], noncoh_q[$], m1[$],m2[$],m3[$];
   int match_cnt, is_coh_rd = 4'hF;
   <%=obj.BlockId%>_read_probe_txn m_pkt;
   m_pkt = new();
   m_pkt.copy(pkt);
   match_q = rtt_q.find_index with((item.cache_addr == pkt.addr)
                                   && security_match(item.security,pkt.ns)
                                   && !item.seenAtReadArb
                                   && item.smi_msg_type == pkt.cmd_type
                                  );
   match_cnt = match_q.size;
   if(m_pkt.cmd_type inside {CMD_CLN_INV,CMD_CLN_VLD,CMD_CLN_SH_PER,CMD_MK_INV} || isAtomicMsg(m_pkt.cmd_type) || isdtwmrgmrd(m_pkt.cmd_type) )begin
    return;
   end
   if(m_pkt.cmd_type inside {MRD_RD_CLN,MRD_RD_WITH_SHR_CLN,MRD_RD_WITH_UNQ_CLN,MRD_RD_WITH_UNQ,MRD_RD_WITH_INV}) begin
     is_coh_rd = 1;
     coh_q = rtt_q.find_index with((item.cache_addr == m_pkt.addr)
                                   && security_match(item.security,m_pkt.ns)
                                   && !item.seenAtReadArb
                                   && item.isCoh
                                   && item.smi_msg_type == m_pkt.cmd_type
                                   && ((item.mrd_req_pkt != null) ? (item.mrd_req_pkt.smi_mpf2_dtr_msg_id == m_pkt.rmsg_id) : 1)
                                  );
     match_q = coh_q;
   end
   else if(m_pkt.cmd_type inside {MRD_PREF,MRD_CLN,MRD_INV,MRD_FLUSH}) begin 
     //Cache management operations that can trigger a read. Match conditions differ from other MRDs
     is_coh_rd = 1;
     coh_q = rtt_q.find_index with((item.cache_addr == m_pkt.addr)
                                   && security_match(item.security,m_pkt.ns)
                                   && !item.seenAtReadArb
                                   && item.isCoh
                                   && item.smi_msg_type == m_pkt.cmd_type
                                   && (item.mrd_req_pkt.smi_msg_id == m_pkt.rmsg_id)
                                   && (m_pkt.aiu_id>>1) == item.mrd_req_pkt.smi_src_ncore_unit_id
                                  );
     match_q = coh_q;
   end
   else begin
     is_coh_rd = 0;
     noncoh_q = rtt_q.find_index with((item.cache_addr == m_pkt.addr)
                                      && security_match(item.security,m_pkt.ns)
                                      && !item.seenAtReadArb
                                      && !item.isCoh
                                      && item.smi_msg_type == m_pkt.cmd_type
                                      && ((item.cmd_req_pkt != null) ? (item.cmd_req_pkt.smi_msg_id == m_pkt.rmsg_id) : 1)
                                      && (m_pkt.aiu_id >> 1) == item.cmd_req_pkt.smi_src_ncore_unit_id
                                    );
     match_q = noncoh_q;
   end

   if(match_q.size() == 0) begin
     `uvm_info("write_dmi_read_probe_port", $sformatf("--------------------------------------------------------------------------------BEGIN"),UVM_MEDIUM)
     foreach(rtt_q[i])begin
       rtt_q[i].print_entry();
       if(rtt_q[i].cmd_req_pkt !=null) begin
         `uvm_info("write_dmi_read_probe_port",$sformatf("RTT --- CmdType:%0h Addr:%0h AiuId:%0h MsgId:%0h  NS:%0d (flg-%0b|%0b)", rtt_q[i].smi_msg_type, rtt_q[i].cache_addr, rtt_q[i].cmd_req_pkt.smi_src_ncore_unit_id, rtt_q[i].cmd_req_pkt.smi_msg_id, rtt_q[i].security, rtt_q[i].seenAtReadArb, rtt_q[i].isCoh),UVM_MEDIUM);
         `uvm_info("write_dmi_read_probe_port",$sformatf("PKT --- CmdType:%0h Addr:%0h AiuId:%0h RmsgId:%0h NS:%0d ", m_pkt.cmd_type, m_pkt.addr, m_pkt.aiu_id, m_pkt.rmsg_id, m_pkt.ns),UVM_MEDIUM);
       end
       else begin
         `uvm_info("write_dmi_read_probe_port",$sformatf("RTT --- CmdType:%0h Addr:%0h AiuId:%0h RmsgId:%0h MsgId:%0h NS:%0d (flg-%0b|%0b)", rtt_q[i].smi_msg_type, rtt_q[i].cache_addr, rtt_q[i].mrd_req_pkt.smi_src_ncore_unit_id, rtt_q[i].mrd_req_pkt.smi_mpf2_dtr_msg_id, rtt_q[i].mrd_req_pkt.smi_msg_id, rtt_q[i].security, rtt_q[i].seenAtReadArb, rtt_q[i].isCoh),UVM_MEDIUM);
         `uvm_info("write_dmi_read_probe_port",$sformatf("PKT --- CmdType:%0h Addr:%0h AiuId:%0h RmsgId:%0h NS:%0d ", m_pkt.cmd_type, m_pkt.addr, m_pkt.aiu_id, m_pkt.rmsg_id, m_pkt.ns),UVM_MEDIUM);
       end
       rtt_q[i].print_entry();
     end
     `uvm_info("write_dmi_read_probe_port", $sformatf("----------------------------------------------------------------------------------END"),UVM_MEDIUM)
     `uvm_error("write_dmi_read_probe_port", $sformatf("Found no matches for Addr:%0h CmdType:%0h in RTT(size=%0d)(coh:%0d|noncoh:%0d)", m_pkt.addr, m_pkt.cmd_type, rtt_q.size, coh_q.size, noncoh_q.size))
   end
   else begin
     `uvm_info("write_dmi_read_probe_port", $sformatf("Found %0d matches %0d coh matches %0d non-coh matches for Addr:%0h CmdType:%0h in RTT(size=%0d)", match_q.size, coh_q.size, noncoh_q.size, m_pkt.addr, m_pkt.cmd_type, rtt_q.size), UVM_MEDIUM)
     if(match_q.size() != 1) begin
       `uvm_info("write_dmi_read_probe_port", $sformatf("Picking based on coherency flag:%0d. Matches found:%0d", is_coh_rd, match_q.size), UVM_MEDIUM)
       if(match_q.size == 0)begin
         match_q = rtt_q.find_index with  ( item.cache_addr[31:0] == m_pkt.addr
                                         && !item.seenAtReadArb
                                         && item.smi_msg_type == m_pkt.cmd_type
                                         && security_match(item.security,m_pkt.ns));
         `uvm_info("write_dmi_read_probe_port", $sformatf("-----------------------------------------------------------------------------BEGIN"),UVM_MEDIUM)
         foreach(match_q[i])begin
           rtt_q[match_q[i]].print_entry;
         end
         `uvm_info("write_dmi_read_probe_port", $sformatf("-----------------------------------------------------------------------------END"),UVM_MEDIUM)
         `uvm_error("write_dmi_read_probe_port", $sformatf("Failed to refine matches with RMSG ID, matches without matching ID were %0d", match_cnt))
       end
       if(match_q.size > 1 ) begin
         int match = find_oldest_entry_in_rtt_q(match_q);
         match_q[0] = match;
         `uvm_info("write_dmi_read_probe_port", $sformatf("Found %0d matches for Addr:%0h CmdType:%0h. Picking the oldest one at %0t.", match_q.size, m_pkt.addr, m_pkt.cmd_type, rtt_q[match].t_creation),UVM_MEDIUM)
       end
     end
     rtt_q[match_q[0]].t_at_read_arbiter = m_pkt.t_pkt;
     rtt_q[match_q[0]].seenAtReadArb = 1;
     rtt_q[match_q[0]].read_arb_pkt = m_pkt;
     rtt_q[match_q[0]].print_entry;
     `uvm_info("DMI_SCB", $psprintf("DMI_UID:%0d: READ_PROBE_FOR_AXI: %s", rtt_q[match_q[0]].txn_id, m_pkt.sprint_pkt()), UVM_LOW)
     updateRttentry(rtt_q[match_q[0]], match_q[0]);
   end
endfunction : write_dmi_read_probe_port
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// ACE Read Address Channel
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function void dmi_scoreboard::write_read_addr_chnl(axi4_read_addr_pkt_t m_pkt);
   axi4_read_addr_pkt_t m_packet;
   m_packet = new();
   m_packet.copy(m_pkt);
   `uvm_info("write_read_addr_chnl", $sformatf("Entered..."), UVM_MEDIUM)
  if(!uncorr_wrbuffer_err) begin
    processArChnl(m_packet);
    ->axi_rd_raise;
  end
endfunction : write_read_addr_chnl
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// ACE Read Data Channel
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function void dmi_scoreboard::write_read_data_chnl(axi4_read_data_pkt_t m_pkt);
  int i;
  axi4_read_data_pkt_t m_packet;
  m_packet = new();
  m_packet.copy(m_pkt);

  `uvm_info("<%=obj.BlockId%>:write_read_data_chnl", $sformatf("Entered..."), UVM_HIGH)
  if(!uncorr_wrbuffer_err) begin
    processRChnl(m_packet);
    ->axi_rd_drop;
  end
endfunction : write_read_data_chnl
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// ACE Write Address Channel
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function void dmi_scoreboard::write_write_addr_chnl(axi4_write_addr_pkt_t m_pkt);
  axi4_write_addr_pkt_t m_packet;
  m_packet = new();
  m_packet.copy(m_pkt);

  `uvm_info("<%=obj.BlockId%>:write_write_addr_chnl", $sformatf("Entered..."), UVM_HIGH)
  if(!uncorr_wrbuffer_err) begin
    processAwChnl(m_packet);
  end
endfunction : write_write_addr_chnl
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// ACE Write Data Channel
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function void dmi_scoreboard::write_write_data_chnl(axi4_write_data_pkt_t m_pkt);
  axi4_write_data_pkt_t m_packet;
  m_packet = new();
  m_packet.copy(m_pkt);

  `uvm_info("<%=obj.BlockId%>:write_write_data_chnl", $sformatf("Entered..."), UVM_HIGH)
  if(!uncorr_wrbuffer_err) begin
    processWChnl(m_packet);
    ->axi_wr_raise;
  end
endfunction : write_write_data_chnl
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// ACE Write Resp Channel
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function void dmi_scoreboard::write_write_resp_chnl(axi4_write_resp_pkt_t m_pkt);
  axi4_write_resp_pkt_t m_packet;
  m_packet = new();
  m_packet.copy(m_pkt);

  `uvm_info("<%=obj.BlockId%>:write_write_resp_chnl", $sformatf("Entered..."), UVM_HIGH)
  if(!uncorr_wrbuffer_err) begin
    processBChnl(m_packet);
    ->axi_wr_drop;
  end
endfunction : write_write_resp_chnl
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Compute if for Q Channel exception scenarios are being hit
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function void dmi_scoreboard::compute_pma_exceptions(time t_last_asserted);
  num_dtws_early = 0;
  num_dtws_early_transactv = 0;
  num_rb_waiting_on_dtw = 0;
  num_dtwmrgmrd = 0;
  enforce_unique_rbids();
  `uvm_info("compute_pma_exceptions", $sformatf("Calculating exception scenarios when transactv could stay high t_last_asserted:%0t", t_last_asserted), UVM_MEDIUM)
  foreach(wtt_q[i]) begin
    if((wtt_q[i].RB_req_expd  &&  wtt_q[i].RB_req_recd ) &&
       (wtt_q[i].RB_rsp_expd  && !wtt_q[i].RB_rsp_recd ) &&
       (wtt_q[i].DTW_req_expd && !wtt_q[i].DTW_req_recd)) begin
       num_rb_waiting_on_dtw++;
    end
    if((wtt_q[i].RB_req_expd  &&  wtt_q[i].RB_req_recd ) &&
       (wtt_q[i].RB_rsp_expd  && !wtt_q[i].RB_rsp_recd ) &&
       (wtt_q[i].DTW_req_expd &&  wtt_q[i].DTW_req_recd)) begin
       if(wtt_q[i].dtw_req_pkt.t_smi_ndp_valid > t_last_asserted) begin
         num_dtws_early++;
       end
     end
    if((wtt_q[i].RB_req_expd  &&  wtt_q[i].RB_req_recd ) &&
       (wtt_q[i].RB_rsp_expd  && !wtt_q[i].RB_rsp_recd ) &&
        wtt_q[i].DTW_req_recd) begin
       if(wtt_q[i].dtw_req_pkt.t_smi_ndp_valid <= t_last_asserted) begin
        num_dtws_early_transactv++;
       end
    end
  end
  foreach(rtt_q[i])begin
    if(rtt_q[i].isDtwMrgMrd) num_dtwmrgmrd++;
  end
endfunction
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Q Channel
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function void dmi_scoreboard::write_q_chnl(q_chnl_seq_item m_pkt);
  q_chnl_seq_item m_packet;
  q_chnl_seq_item m_packet_tmp;
  dmi_scb_txn     txn;

  m_packet = new();

  $cast(m_packet_tmp, m_pkt);
  m_packet.copy(m_packet_tmp);
    `uvm_info("<%=obj.BlockId%>:Q_Channel_resp_chnl", $sformatf("Entered..."), UVM_HIGH)
  if(m_packet.QACCEPTn && m_packet.QREQn && !m_packet.QDENY && !m_packet.QACTIVE) begin
    t_qaccept_asserted = $time;
  end
  //If power_down request has been accepted, at that time no outstanding transaction should be there
  if(m_packet.QACCEPTn == 'b0 && m_packet.QREQn == 'b0 && m_packet.QACTIVE == 'b0) begin
    `uvm_info("<%=obj.BlockId%>:Q_Channel_resp_chnl", $sformatf("Q_Channel : Checking WTT and RTT Queue should be empty when Q Channel Req receives Accept."), UVM_HIGH)
    //WTT Queue
    if (wtt_q.size != 0) begin
      compute_pma_exceptions(t_qaccept_asserted);
      if( wtt_q.size != num_rb_waiting_on_dtw && wtt_q.size != num_dtws_early ) begin
        `uvm_error("<%=obj.BlockId%>:print_wtt_q", $sformatf("WTT queue is not empty when dmi asserted QACCEPTn. %0d != %0d", wtt_q.size, num_rb_waiting_on_dtw))
      end
      else
        `uvm_info("<%=obj.BlockId%>:print_wtt_q", $sformatf("WTT has %0d pending entries but they're marked as RbReq with no DTW rcvd", wtt_q.size), UVM_MEDIUM)
    end
    else begin
      `uvm_info("<%=obj.BlockId%>:print_wtt_q", $sformatf("WTT queue is empty"), UVM_MEDIUM)
    end
    //RTT Queue
    if (rtt_q.size != 0) begin
      compute_pma_exceptions(t_qaccept_asserted);
      if(num_dtws_early != num_dtwmrgmrd) begin
        `uvm_error("<%=obj.BlockId%>:print_rtt_q", $sformatf("RTT queue has pending entries when dmi asserted QACCEPTn but they are due to pending DTWs created on a DTWMrgMrd %0d != %0d", num_dtwmrgmrd, num_dtws_early))
      end
      else begin
        `uvm_info("<%=obj.BlockId%>:print_rtt_q", $sformatf("RTT queue has %0d pending entries when dmi asserted QACCEPTn but they are due to pending DTWs created on a DTWMrgMrd", rtt_q.size), UVM_MEDIUM)
      end
    end
    else begin
      `uvm_info("<%=obj.BlockId%>:print_rtt_q", $sformatf("RTT queue is empty"), UVM_MEDIUM)
    end
  end
endfunction : write_q_chnl
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Create mrdtable entry for new MRD request
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function void dmi_scoreboard::processMrdReq(smi_seq_item  mrd_req_pkt,bit isDtwMrgMrd = 0,dmi_scb_txn scb_pkt = null);
  int tmp_q[$],tmp_q1[$];
  dmi_scb_txn  m_mrd_entry,txn;
  int uid_match;
  m_mrd_entry = new();

  `uvm_info("<%=obj.BlockId%>:processMrdReq",$sformatf("Addr:'h%0h",mrd_req_pkt.smi_addr), UVM_MEDIUM)
  if(isDtwMrgMrd)begin
    tmp_q  = rtt_q.find_index with ((item.isMrd) && 
                                    (cl_aligned((item.cache_addr)) === cl_aligned(mrd_req_pkt.smi_addr)) && 
                                    security_match(item.security, mrd_req_pkt.smi_ns) &&
                                    (item.DTR_req_expd == 1 && item.DTR_req_recd == 0)); 

    tmp_q1  = wtt_q.find_index with ((item.isDtw) && 
                                  (cl_aligned((item.cache_addr)) === cl_aligned(mrd_req_pkt.smi_addr)) && 
                                  security_match(item.security, mrd_req_pkt.smi_ns) &&
                                  (item.AXI_write_resp_expd == 1 && !(item.AXI_write_resp_recd)) &&
                                  (item.RB_req_expd && item.RB_req_recd) &&
                                  (item.DTR_req_expd == 1 && item.DTR_req_recd == 0)); 
  end
  else begin
    tmp_q  = rtt_q.find_index with ((item.isMrd) && 
                                    (cl_aligned((item.cache_addr)) === cl_aligned(mrd_req_pkt.smi_addr)) && 
                                    security_match(item.security, mrd_req_pkt.smi_ns) &&
                                    (item.DTR_req_expd == 1 && item.DTR_req_recd == 0)); 
    tmp_q1  = wtt_q.find_index with ((item.isDtw) && 
                                  (cl_aligned((item.cache_addr)) === cl_aligned(mrd_req_pkt.smi_addr)) && 
                                  security_match(item.security, mrd_req_pkt.smi_ns) &&
                                  (item.RB_req_expd && item.RB_req_recd) &&
                                  (item.AXI_write_resp_expd == 1 && !(item.AXI_write_resp_recd))); 
  end
  <% if(obj.useCmc && obj.DmiInfo[obj.Id].ccpParams.useScratchpad){%>
  m_mrd_entry.lower_sp_addr = lower_sp_addr;
  m_mrd_entry.upper_sp_addr = upper_sp_addr;
  m_mrd_entry.cache_addr_i  = ncoreConfigInfo::gen_spad_intrlv_rmvd_addr(mrd_req_pkt.smi_addr,<%=obj.DmiInfo[obj.Id].nUnitId%>);
  m_mrd_entry.sp_enabled    = sp_enabled;
  m_mrd_entry.sp_ns         = sp_ns;
  m_mrd_entry.rsvd_ways     = (2**$clog2(sp_ways)) - 1;
  <% } %>

  if(mrd_req_pkt.smi_msg_type inside {MRD_FLUSH,MRD_CLN,MRD_INV})begin
    numMrdCMOTxns++;
  end
  else begin
    numMrdTxns++;
  end
  if(tmp_q.size() != 0) begin
    if(rtt_q[tmp_q[0]].smi_msg_type != MRD_PREF)begin
      print_rtt_q();
      `uvm_info("<%=obj.BlockId%>:processMrdReq", $sformatf("matchSize=%0d, %1p",tmp_q.size(), mrd_req_pkt), UVM_MEDIUM)
      rtt_q[tmp_q[0]].print_entry();
      `uvm_error("<%=obj.BlockId%>:processMrdReq", $sformatf("Cache addr on mrd req above matches existing mrd queue entry. This is illegal stimulus"))
    end
  end
  if(tmp_q1.size()>0)begin
    m_mrd_entry.addToRttQ(mrd_req_pkt,1,1,0);
  end
  else begin
    m_mrd_entry.addToRttQ(mrd_req_pkt,1,0,0);
  end
    uid_match = m_mrd_entry.txn_id; 

  <% if(obj.useCmc) { %>
  // If lookup_en CSR is set to 0
  if(!lookup_en) m_mrd_entry.lookupExpd = 0;


  if(mrd_req_pkt.smi_msg_type == MRD_PREF && !lookup_en)begin
    m_mrd_entry.AXI_read_addr_expd = 0;
    m_mrd_entry.AXI_read_data_expd = 0;
  end
  <% } %>
  ////////////////////////////////////////////////
  //#Check.DMI.Concerto.v3.0.MrdReqRL
  ///////////////////////////////////////////////
  if(mrd_req_pkt.smi_msg_type inside {MRD_FLUSH,MRD_CLN,MRD_INV})begin
    if(mrd_req_pkt.smi_rl !== 2'b10)begin
      `uvm_error("<%=obj.BlockId%>:processMrdReq", $sformatf("mrd_req_pkt.smi_rl mismatch for MRD_FLUSH,MRD_CLN,MRD_INV exp :2'b10 recd:%0b",mrd_req_pkt.smi_rl))
    end
    m_mrd_entry.AXI_read_addr_expd = 0;
    m_mrd_entry.AXI_read_data_expd = 0;
  end
  if(mrd_req_pkt.smi_msg_type inside {MRD_RD_WITH_UNQ,MRD_RD_WITH_INV})begin
    if(mrd_req_pkt.smi_rl !== 2'b01)begin
      `uvm_error("<%=obj.BlockId%>:processMrdReq", $sformatf("mrd_req_pkt.smi_rl mismatch for MRD_FLUSH,MRD_CLN,MRD_INV exp :2'b01 recd:%0b",mrd_req_pkt.smi_rl))
    end
  end
  if(mrd_req_pkt.smi_msg_type == MRD_FLUSH && mrd_req_pkt.smi_rl == 2'b10)begin
     m_mrd_entry.wrOutstandingFlag = 0;
  end
  if(isDtwMrgMrd)begin
    int arb_match[$];
    arb_match = wr_arb_q.find_index with (
                                         (item.addr == m_mrd_entry.cache_addr) &&
                                         security_match(item.ns,m_mrd_entry.security) &&
                                         (item.cmd_type == scb_pkt.dtw_req_pkt.smi_msg_type) &&
                                         (item.rmsg_id == scb_pkt.dtw_req_pkt.smi_mpf2)
                                          );
    if(arb_match.size > 0) begin
      if(arb_match.size > 1) begin
        `uvm_error("<%=obj.BlockId%>:processMrdReq",$sformatf("Found %0d matches for Addr:%0h NS:%0b CmdType:%0h RmsgId:%0h", arb_match.size, m_mrd_entry.cache_addr, m_mrd_entry.security, scb_pkt.dtw_req_pkt.smi_msg_type, scb_pkt.dtw_req_pkt.smi_mpf2))
      end
      `uvm_info("<%=obj.BlockId%>:processMrdReq", $sformatf("Adding write arbiter packet to MRD entry :: Addr:%0h t_at_write_arbiter:%0t | Found matches %0d (size=%0d)", wr_arb_q[arb_match[0]].addr,  wr_arb_q[arb_match[0]].t_pkt, arb_match.size, wr_arb_q.size), UVM_HIGH)
      m_mrd_entry.t_at_write_arbiter = wr_arb_q[arb_match[0]].t_pkt;
      m_mrd_entry.seenAtWriteArb = 1 ;
      m_mrd_entry.write_arb_pkt = wr_arb_q[arb_match[0]];
      wr_arb_q.delete(arb_match[0]);
    end
    m_mrd_entry.isDtwMrgMrd = 1;
    m_mrd_entry.isCoh       = 1;
    m_mrd_entry.isNcRd      = 0;
    <% if(obj.useCmc) { %>
    if (!m_mrd_entry.sp_txn && lookup_en) begin
      m_mrd_entry.lookupExpd       = 1;
      m_mrd_entry.lookupSeen       = 1;
      m_mrd_entry.t_lookup         = $time;
      m_mrd_entry.cache_ctrl_pkt   = scb_pkt.cache_ctrl_pkt;
      if(scb_pkt.cache_ctrl_pkt.alloc)begin
        m_mrd_entry.fillwayn       = scb_pkt.cache_ctrl_pkt.wayn;
        m_mrd_entry.fillExpd       = 1;
        m_mrd_entry.fillDataExpd   = 1;
        create_exp_fillCtrl(scb_pkt.cache_ctrl_pkt,m_mrd_entry);
        m_mrd_entry.cache_fill_ctrl_pkt_exp.state     = UD;
        ->ccp_fill_raise;
      end
    end
    <% } %>
    m_mrd_entry.CMD_rsp_expd     = 0;
    m_mrd_entry.STR_req_expd     = 0;
    m_mrd_entry.STR_rsp_expd     = 0;
    m_mrd_entry.dtw_req_pkt      = scb_pkt.dtw_req_pkt;
    m_mrd_entry.rb_req_pkt       = scb_pkt.rb_req_pkt;
    m_mrd_entry.smi_rbid         = scb_pkt.rb_req_pkt.smi_rbid;
    m_mrd_entry.dtr_targ_unit_id = scb_pkt.dtw_req_pkt.smi_mpf1[WSMINCOREUNITID-1:0];
    m_mrd_entry.dtr_rmsg_id_expd = scb_pkt.dtw_req_pkt.smi_mpf2;
    m_mrd_entry.smi_intfsize     = scb_pkt.dtw_req_pkt.smi_intfsize;
    m_mrd_entry.exp_smi_tm       = scb_pkt.dtw_req_pkt.smi_tm;
    m_mrd_entry.smi_size         = 6;
    if(scb_pkt.dtw_req_pkt.smi_dp_last)begin
      m_mrd_entry.DTW_req_recd   = 1;
    end

    if(scb_pkt.isCacheHit)begin
      <% if(obj.useCmc) { %>
      if(scb_pkt.cache_ctrl_pkt.bypass)begin
        m_mrd_entry.cacheRspExpd       = 1;
      end
      m_mrd_entry.isCacheHit         = 1;
      <% } %>
      m_mrd_entry.AXI_read_addr_expd = 0;
      m_mrd_entry.AXI_read_data_expd = 0;
    end
    m_mrd_entry.expd_dtr_beats = NUM_BEATS_IN_DTR;
    m_mrd_entry.expd_arlen     = NUM_BEATS_IN_DTR-1;
    m_mrd_entry.expd_arburst   = AXIWRAP;
  end
  <% if(!obj.useCmc) { %>
  if(mrd_req_pkt.smi_msg_type == MRD_PREF)begin
    m_mrd_entry.AXI_read_addr_expd = 0;
    m_mrd_entry.AXI_read_data_expd = 0;
  end
  <% } else { %>
  if(tmp_q.size() != 0) begin
    if(rtt_q[tmp_q[0]].smi_msg_type == MRD_PREF && (rtt_q[tmp_q[0]].AXI_read_addr_expd ==1))begin
       m_mrd_entry.AXI_read_addr_expd = 0;
       m_mrd_entry.AXI_read_data_expd = 0;
    end
  end
  <% } %>
  m_mrd_entry.t_mrdreq = $time;
  m_mrd_entry.wrOutstandingcnt = tmp_q1.size();
  m_mrd_entry.mrd_req_pkt = mrd_req_pkt;
  rtt_q.push_back(m_mrd_entry);
  `uvm_info("DMI_SCB", $psprintf("DMI_UID:%0d: MRD_REQ: %s", uid_match, mrd_req_pkt.convert2string()), UVM_LOW);
  
endfunction : processMrdReq
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Update mrdtable entry with MRDrsp
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function void dmi_scoreboard::processMrdRsp(smi_seq_item mrd_rsp_pkt);
  int idx,tmp_q[$];
  int tmp_q_cmstatus_error[$];
  dmi_scb_txn txn;
  bit found = 0;

  tmp_q = {};
  `uvm_info("<%=obj.BlockId%>:processMrdRsp:0",$sformatf("Addr:'h%0h",mrd_rsp_pkt.smi_addr), UVM_MEDIUM)
  //#Check.DMI.MRDRspFields   //#Check.DMI.SMIImsgIDFieldCorrect
  //#Check.DMI.Concerto.v3.0.MrdRspRMessageId
  tmp_q = rtt_q.find_index with ((item.isMrd) && 
                                 (item.mrd_req_pkt.smi_msg_id == mrd_rsp_pkt.smi_rmsg_id) && 
                                 (item.mrd_req_pkt.smi_src_ncore_unit_id == mrd_rsp_pkt.smi_targ_ncore_unit_id) && 
                                 (item.MRD_rsp_recd == 0));

  if(tmp_q.size == 0) begin
    `uvm_info("<%=obj.BlockId%>:processMrdRsp", $sformatf("%1p",mrd_rsp_pkt), UVM_MEDIUM)
    `uvm_error("<%=obj.BlockId%>:processMrdRsp", "smi_msg_id for MRDrsp not found")
  end
  else if (tmp_q.size > 1) begin
    `uvm_info("<%=obj.BlockId%>:processMrdRsp", $sformatf("%1p",mrd_rsp_pkt), UVM_MEDIUM)
    `uvm_error("<%=obj.BlockId%>:processMrdRsp", "smi_rmsg_id for MRDrsp matches multiple outstanding requests")
  end
  else begin
    rtt_q[tmp_q[0]].MRD_rsp_recd = 1;
    rtt_q[tmp_q[0]].mrd_rsp_pkt  = mrd_rsp_pkt;
    rtt_q[tmp_q[0]].t_mrdrsp      = $time;
    rtt_q[tmp_q[0]].t_latest_update = $time;
    rtt_q[tmp_q[0]].print_entry();
    ///////////////////////////////////////////////////////////////
    //#Check.DMI.Concerto.v3.0.MrdFlushMrdClnCollideDtwInflight
    //#Check.DMI.Concerto.v3.0.MrdRspTiming_0
    //////////////////////////////////////////////////////////////
    if((rtt_q[tmp_q[0]].smi_msg_type inside {MRD_FLUSH,MRD_CLN}) && rtt_q[tmp_q[0]].wrOutstandingFlag == 1)begin
       `uvm_error("<%=obj.BlockId%>:processMrdRsp", "MRDrsp for MrdFlsh/MrdCln should not sent with WrOutstandinFlg == 1")
    end
    //#Check.DMI.Concerto.v3.0.MrdRspTiming_1
    <% if(obj.useCmc) { %>
    if(lookup_en)begin
      if((rtt_q[tmp_q[0]].smi_msg_type inside {MRD_INV}) && !rtt_q[tmp_q[0]].lookupSeen && !rtt_q[tmp_q[0]].sp_txn)begin
        `uvm_error("<%=obj.BlockId%>:processMrdRsp", "MRDrsp for MrdInv should not sent without cache lookup")
      end
    end
    <% } %>
    //#Check.DMI.Concerto.v3.0.MrdRspforMrdReqRL11
    // As per CONC-5883
    if((rtt_q[tmp_q[0]].smi_msg_type inside {MRD_RD_WITH_INV,MRD_RD_WITH_SHR_CLN,MRD_RD_WITH_UNQ_CLN,MRD_RD_WITH_UNQ}) && (rtt_q[tmp_q[0]].mrd_req_pkt.smi_rl == 'b11))begin  
      if(!rtt_q[tmp_q[0]].DTR_rsp_recd)begin
        `uvm_error("<%=obj.BlockId%>:processMrdRsp", "MRDrsp for NonCmo Mrd with smi_rl = 'b11 should sent after receiving DTR_rsp")
      end
    end
    txn = rtt_q[tmp_q[0]];
    if(txn.exp_smi_tm != mrd_rsp_pkt.smi_tm) begin
      `uvm_error("<%=obj.BlockId%>:processMrdRsp", $sformatf("smi_tm not matching. Expd %0b Actual %0b", txn.exp_smi_tm, mrd_rsp_pkt.smi_tm))
    end
    `uvm_info("DMI_SCB", $psprintf("DMI_UID:%0d: MRD_RSP: %s", rtt_q[tmp_q[0]].txn_id, mrd_rsp_pkt.convert2string()), UVM_LOW);
    updateRttentry(txn,tmp_q[0]);
  end // else: !if(tmp_q.size > 1)
endfunction // processMrdRsp
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Update mrdtable entry with DTRreq
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function void dmi_scoreboard::processDtrReq(smi_seq_item dtr_req_pkt);
  int tmp_q[$],tmp_q1[$],tmp_q2[$],tmp_q3[$],tmp_q4[$],tmp_q5[$],tmp_qHP[$];
  bit poison;
  dmi_scb_txn txn;
  int AddrDataIDmatch=1;

  `uvm_info("<%=obj.BlockId%>:processDtrReq:0", $sformatf("%1p",dtr_req_pkt), UVM_MEDIUM)
  tmp_q = {};
  tmp_q = rtt_q.find_index with ((item.DTR_req_expd == 1) &&(item.DTR_req_recd == 1) && (item.DTR_rsp_recd == 0));

  // DTR smi_msg_id already in use
  //#Check.DMI.DtrReqSMImsgId
  if(tmp_q.size > 0) begin
    tmp_q1 = {};
    tmp_q1 = rtt_q.find_index with ((item.DTR_req_recd == 1) && (item.dtr_msg_id === dtr_req_pkt.smi_msg_id) && (item.DTR_rsp_recd == 0));
  end
  if(tmp_q1.size > 0) begin
    `uvm_info("<%=obj.BlockId%>:processDtrReq:1", $sformatf("%1p",dtr_req_pkt), UVM_LOW)
    foreach (tmp_q1[i]) begin
      rtt_q[tmp_q1[i]].print_entry();
    end
    `uvm_error("<%=obj.BlockId%>:processDtrReq:2", "Above dtr req entry has smi_msg_id matching DTRreq already in flight. Also printed are these matching transactions")
  end

  if(tmp_q1.size > 0) begin
    `uvm_info("<%=obj.BlockId%>:processDtrReq:3", $sformatf("%1p",dtr_req_pkt), UVM_LOW)
    foreach (tmp_q1[i]) begin
      wtt_q[tmp_q1[i]].print_entry();
    end
    `uvm_error("<%=obj.BlockId%>:processDtrReq:4", "Above dtr req entry has smi_msg_id matching DTRreq already in flight. Also printed are these matching transactions")
  end
  //#Check.DMI.Concerto.v3.0.DtrReqReadInflight

  tmp_q = {};
  //#Check.DMI.Concerto.v3.0.AiuIdDtwMrgMrd
  tmp_q = rtt_q.find_index with ((item.isMrd || item.isNcRd || item.isDtwMrgMrd ) && 
                                 (item.dtr_targ_unit_id === dtr_req_pkt.smi_targ_ncore_unit_id) && 
                                 (item.dtr_rmsg_id_expd === dtr_req_pkt.smi_rmsg_id) && 
                                 (item.DTR_req_expd == 1) &&
                                 (item.DTR_req_recd==0));
  //#Check.DMI.Concerto.v3.0.DTRfields
  if(tmp_q.size  == 0) begin
    `uvm_info("<%=obj.BlockId%>:processDtrReq:5", $sformatf("%1p",dtr_req_pkt), UVM_LOW)
    `uvm_info("<%=obj.BlockId%>:processDtrReq:6", $sformatf("aiuid:0x%0x aiutransid:0x%0x",dtr_req_pkt.smi_targ_ncore_unit_id,dtr_req_pkt.smi_rmsg_id), UVM_LOW)
    `uvm_error("<%=obj.BlockId%>:processDtrReq:7", "MRDreq,DtwMrgMrd OR NC Rd with matching AIU ID, AIU msgID not found for received DTRreq")
  end
  else if (tmp_q.size  > 1) begin
    `uvm_info("<%=obj.BlockId%>:processDtrReq:8", $sformatf("%1p",dtr_req_pkt), UVM_LOW)
    `uvm_info("<%=obj.BlockId%>:processDtrReq:8", $sformatf("***********************************************"), UVM_LOW)
    foreach(tmp_q[i])begin
      rtt_q[tmp_q[i]].print_entry();
    end
    `uvm_info("<%=obj.BlockId%>:processDtrReq:9", $sformatf("***********************************************"), UVM_LOW)
    `uvm_error("<%=obj.BlockId%>:processDtrReq10", "Multiple MRDreq,DtwMrgMrd Or NC Rd with matching AIU ID, AIU msgID found for received DTRreq")
  end
  else begin
    txn                  = rtt_q[tmp_q[0]];
    txn.dtr_req_pkt      = dtr_req_pkt;
    txn.dtr_msg_id       = dtr_req_pkt.smi_msg_id;
    txn.dtr_rmsg_id_recd = dtr_req_pkt.smi_rmsg_id;
    txn.DTR_req_recd = 1;
    txn.t_dtrreq = $time;
    txn.t_latest_update = $time;
    txn.print_entry();
    `uvm_info("DMI_SCB", $psprintf("DMI_UID:%0d: DTR_REQ: %s", rtt_q[tmp_q[0]].txn_id, dtr_req_pkt.convert2string()), UVM_LOW);
    //#Check.DMI.Concerto.v3.0.DtrReqRL
    if(txn.isDtwMrgMrd)begin
    //#Check.DMI.Concerto.v3.0.DTRTypeVsDtwMrgMrd  //CONC-7044
      if(dtr_req_pkt.smi_rl inside {2'b10,2'b01})begin
        if(dtr_req_pkt.smi_rl !== 2'b01)begin
          `uvm_error("<%=obj.BlockId%>:processDtrReq:11", $sformatf("Not matching DtwMrgMrd smi_rl  expd :2'b01 recd :%0b",dtr_req_pkt.smi_rl))
        end
      end
      else if(dtr_req_pkt.smi_rl == 2'b11)begin
        if(dtr_req_pkt.smi_rl !== 2'b11)begin
          `uvm_error("<%=obj.BlockId%>:processDtrReq:11", $sformatf("Not matching DtwMrgMrd smi_rl  expd :2'b11 recd :%0b",dtr_req_pkt.smi_rl))
        end
      end
    end
    else if(txn.isMrd) begin
      if(dtr_req_pkt.smi_rl !== txn.mrd_req_pkt.smi_rl)begin
        `uvm_error("<%=obj.BlockId%>:processDtrReq:12", $sformatf("Not matching Mrd smi_rl  expd :%0b recd :%0b",txn.mrd_req_pkt.smi_rl,dtr_req_pkt.smi_rl))
      end
    end
    else begin
      if(dtr_req_pkt.smi_rl !==2'b01)begin
        `uvm_error("<%=obj.BlockId%>:processDtrReq:13", $sformatf("Not matching NcRd smi_rl  expd :2'b01 recd :%0b",dtr_req_pkt.smi_rl))
      end
    end
    <%if (obj.DmiInfo[obj.Id].fnEnableQos) { %>
    if(dtr_req_pkt.smi_msg_pri != ncoreConfigInfo::qos_mapping(txn.smi_qos))begin
      `uvm_error("<%=obj.BlockId%>:processDtrReq:14",$sformatf("Priority for smi_qos :%0x Exp :%0x Recd :%0x DMI_UID:%0d:",txn.smi_qos,ncoreConfigInfo::qos_mapping(txn.smi_qos),dtr_req_pkt.smi_msg_pri,txn.txn_id))
    end
    <% } %>
    <% if(obj.useCmc) { %>
    if(txn.isCacheHit)begin
      if(txn.cacheRspExpd == 1 && txn.cacheRspRecd == 0 && !txn.isAtomic)begin
         `uvm_error("<%=obj.BlockId%>:processDtrReq:15", "The DTR req above hasn't received data from the CCP channel. This transaction shouldn't see a DTR request.")
      end
    end
    <% } %>
    //#Check.DMI.Concerto.v3.0.AddrRegionCohNonCoh
    if((txn.AXI_read_data_expd==1 &&  txn.AXI_read_data_recd==0 && !txn.isAtomic)) begin
      txn.print_entry();
      `uvm_error("<%=obj.BlockId%>:processDtrReq:16", "HxP -- The DTR req above hasn't received data from the R channel. This transaction shouldn't see a DTR request.")
    end
    <% if(obj.useCmc) { %>
    // #Check.DMI.Concerto.v3.0.DTRDataByteEnPoison
    if(!txn.DtrRdy && !txn.isAtomic )begin
      txn.gen_exp_smi__dtr_req();
    end
    <% } else { %>
    if(!txn.DtrRdy && !txn.isAtomic)begin
      txn.gen_exp_smi__dtr_req();
    end
    <% } %>
    if(txn.DtrRdy && !txn.isAtomic)begin
      rearrangedtrdata(txn);
    end
    if(txn.isCacheHit)begin
      <% if(obj.useCmc) { %>
      if(exclusive_flg && txn.isNcRd && !txn.isAtomic)begin
        if(txn.cmd_req_pkt.smi_es)begin
          if(txn.cache_rd_data_pkt !=null) begin
            if(txn.expd_dtr_beats != txn.dtr_req_pkt.smi_dp_data.size) begin
              `uvm_info("<%=obj.BlockId%>:processDtrReq", $sformatf("Poison based CMSTATUS reporting will be dropped due to an inserted dummy beat. Expected DTR Beats:%0d Received DTR Beats:%0d", txn.expd_dtr_beats,txn.dtr_req_pkt.smi_dp_data.size), UVM_LOW)
            end
            if( (txn.expd_dtr_beats == txn.dtr_req_pkt.smi_dp_data.size) && (txn.cache_rd_data_pkt.poison[0] != 0) && (txn.dtr_req_pkt.smi_cmstatus != 8'b1000_0011)) begin //Data Error. Addr Error check is below
             `uvm_error("<%=obj.BlockId%>:processDtrReq",$sformatf("Exp smi_cmstatus: 8'b1000_0011 in DTRreq due To Data error for Exclusive NcRd, Actual smi_cmstatus: 'b%0b",txn.dtr_req_pkt.smi_cmstatus))
            end
            else if(exmon_size > 0 && txn.dtr_req_pkt.smi_cmstatus == 8'b0000_0000) begin
              `uvm_error("<%=obj.BlockId%>:processDtrReq",$sformatf("Exp smi_cmstatus: 8'b0000_0001 in DTRreq due To cacheHit for Exclusive NcRd, Actual smi_cmstatus: 'b%0b",txn.dtr_req_pkt.smi_cmstatus))
            end
             else if(exmon_size == 0 && txn.dtr_req_pkt.smi_cmstatus == 8'b0000_0001) begin
              `uvm_error("<%=obj.BlockId%>:processDtrReq",$sformatf("Exp smi_cmstatus: 8'b0000_0000 in DTRreq due To cacheHit for Exclusive NcRd, Actual smi_cmstatus: 'b%0b",txn.dtr_req_pkt.smi_cmstatus))
            end
          end
          else begin
            if(txn.dtr_req_pkt.smi_cmstatus == 8'b1000_0011) begin //Data Error. Addr Error check is below
             `uvm_info("<%=obj.BlockId%>:processDtrReq",$sformatf("CCP cache read response handshake incomplete but smi_cmstatus: 8'b1000_0011 in DTRreq due To Data error for Exclusive NcRd"), UVM_MEDIUM)
            end
             else if(exmon_size > 0 && txn.dtr_req_pkt.smi_cmstatus == 8'b0000_0000) begin
              `uvm_error("<%=obj.BlockId%>:processDtrReq",$sformatf("Exp smi_cmstatus: 8'b0000_0001 in DTRreq due To cacheHit for Exclusive NcRd, Actual smi_cmstatus: 'b%0b",txn.dtr_req_pkt.smi_cmstatus))
            end
             else if(exmon_size == 0 && txn.dtr_req_pkt.smi_cmstatus == 8'b0000_0001) begin
              `uvm_error("<%=obj.BlockId%>:processDtrReq",$sformatf("Exp smi_cmstatus: 8'b0000_0000 in DTRreq due To cacheHit for Exclusive NcRd, Actual smi_cmstatus: 'b%0b",txn.dtr_req_pkt.smi_cmstatus))
            end
          end
        end
      end
      <%}%>
    end
    else begin
      if(exclusive_flg && txn.isNcRd && !txn.isAtomic)begin
        if(txn.axi_read_data_pkt != null) begin 
          if ((txn.dtr_req_pkt_exp.smi_cmstatus !== dtr_req_pkt.smi_cmstatus) && !((dtr_req_pkt.smi_cmstatus == 1) && (exmon_size > 0))) begin //Data Error
             `uvm_error(get_full_name(),$sformatf("v1-dtr_req_pkt_exp.smi_cmstatus = %0h , dtr_req_pkt.smi_cmstatus = %0h",txn.dtr_req_pkt_exp.smi_cmstatus,dtr_req_pkt.smi_cmstatus));
          end
          if(exclusive_flg && txn.axi_read_addr_pkt.arlock)begin
            if((txn.axi_read_data_pkt.rresp_per_beat[0] == OKAY) && txn.dtr_req_pkt.smi_cmstatus[0] !== 1'b0) begin
              `uvm_error("<%=obj.BlockId%>:processDtrReq",$sformatf("Exp smi_cmstatus: 1'b0 in DTRreq due rresp for Exclusive NcRd, Actual smi_cmstatus: 'b%0b and rresp = 'b%0b",txn.dtr_req_pkt.smi_cmstatus,txn.axi_read_data_pkt.rresp_per_beat[0]))
            end
            if((txn.axi_read_data_pkt.rresp_per_beat[0] == EXOKAY) && txn.dtr_req_pkt.smi_cmstatus[0] !== 1'b1) begin
              `uvm_error("<%=obj.BlockId%>:processDtrReq",$sformatf("Exp smi_cmstatus: 1'b1 in DTRreq due rresp for Exclusive NcRd, Actual smi_cmstatus: 'b%0b and rresp = 'b%0b",txn.dtr_req_pkt.smi_cmstatus,txn.axi_read_data_pkt.rresp_per_beat[0]))
            end
          end
        end
      end
    end
  //#Check.DMI.Concerto.v3.0.DtrReqTM 
  if(dtr_req_pkt.smi_tm != txn.exp_smi_tm)begin
     txn.print_entry();
    `uvm_error("<%=obj.BlockId%>:processDtrReq",$sformatf("Exp smi_tm :%0b Received in DTR :%0b",txn.exp_smi_tm,dtr_req_pkt.smi_tm));
  end


  <%if(obj.useCmc){%>
  //////////////////////////////////////////
  //#Check.DMI.Concerto.v3.0.DTRCmStatus
  /////////////////////////////////////////
  
  //if(txn.nackuce)begin
  //  if(dtr_req_pkt.smi_cmstatus !== 8'b10000100) begin //Address Error
  //    `uvm_error(get_full_name(),$sformatf("cm_status with Address Error (0x10000100) should be present for nackuce, smi_cmstatus = %0h",dtr_req_pkt.smi_cmstatus));
  //  end
  //end
  <% } %>
  if ($test$plusargs("prob_ace_rd_resp_error")) begin
    if ((txn.axi_read_data_pkt != null) && !txn.isAtomic) begin //CMStatus (in ndp) will only carries first beat error information. CONC-5507
      if((txn.dtr_req_pkt_exp.smi_cmstatus !== dtr_req_pkt.smi_cmstatus)&& !((dtr_req_pkt.smi_cmstatus == 1) && (exmon_size > 0))) begin //Data Error
        `uvm_error(get_full_name(),$sformatf("v2-dtr_req_pkt_exp.smi_cmstatus = %0h , dtr_req_pkt.smi_cmstatus = %0h",txn.dtr_req_pkt_exp.smi_cmstatus,dtr_req_pkt.smi_cmstatus));
      end
    end
  end
  end
  if(conc9307_test) begin
    dtrreq_num++;
    `uvm_info("dmi_scoreboard", $sformatf("dtrreq_num %0d dtwmrgmrd_num %0d mrd_num %0d", dtrreq_num, dtwmrgmrd_num, mrd_num), UVM_DEBUG)
    if(dtrreq_num == dtwmrgmrd_num) begin
      evt_start_dtws.trigger();
    end
    if(dtrreq_num == (dtwmrgmrd_num + mrd_num)) begin
      `uvm_info("dmi_scoreboard","triggering evt_send_dtr_rsp", UVM_DEBUG)
      evt_send_dtr_rsp.trigger();
    end
  end
endfunction // processDtrReq
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Update mrdtable entry with DTRrsp
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function void dmi_scoreboard::processDtrRsp(smi_seq_item dtr_rsp_pkt);
  int tmp_q[$],tmp_q1[$],idx,tmp_q2[$];
  dmi_scb_txn txn;
  `uvm_info("<%=obj.BlockId%>:processDtrRsp", $sformatf("%1p",dtr_rsp_pkt), UVM_MEDIUM)
  tmp_q1 = {};
  tmp_q1 = rtt_q.find_index with ((item.DTR_req_recd == 1) && (item.DTR_rsp_recd == 0));

  if(tmp_q1.size() >0)begin
    //#Check.DMI.Concerto.v3.0.DtrRspRMessageId
    tmp_q = {};
    tmp_q = rtt_q.find_index with ((item.dtr_msg_id == dtr_rsp_pkt.smi_rmsg_id) && 
                                   (item.DTR_req_recd == 1) && 
                                   (item.DTR_rsp_recd == 0));
  end
  else begin
    `uvm_info("<%=obj.BlockId%>:processDtrRsp", $sformatf("%1p",dtr_rsp_pkt), UVM_LOW)
    `uvm_error("<%=obj.BlockId%>:processDtrRsp", "No DTR waiting for  DTRrsp")
  end

  if(tmp_q.size()  == 0) begin
    `uvm_info("<%=obj.BlockId%>:processDtrRsp", $sformatf("%1p",dtr_rsp_pkt), UVM_LOW)
    `uvm_error("<%=obj.BlockId%>:processDtrRsp", "SMI Msg Id matching incoming DTRrsp not found")
  end
  else if (tmp_q.size()  > 1) begin
    `uvm_info("<%=obj.BlockId%>:processDtrRsp", $sformatf("%1p",dtr_rsp_pkt), UVM_LOW)
    foreach (tmp_q[i]) begin
      rtt_q[tmp_q[i]].print_entry();
    end
    `uvm_error("<%=obj.BlockId%>:processDtrRsp", "smi_rmsg_id of DTRrsp matches multiple outstanding requests. Entries printed above")
  end
  else begin
    //#Check.DMI.Concerto.v3.0.DTWMrgMrdProtocolFlow   
    if(rtt_q[tmp_q[0]].isDtwMrgMrd && (rtt_q[tmp_q[0]].dtw_req_pkt.smi_rl == 'b11))begin
      tmp_q2 = {};
      tmp_q2 = wtt_q.find_index with (isdtwmrgmrd(item.dtw_req_pkt.smi_msg_type)  && 
                                     (item.dtw_req_pkt.smi_mpf1[WSMINCOREUNITID-1:0] === rtt_q[tmp_q[0]].dtr_req_pkt.smi_targ_ncore_unit_id) && 
                                     (item.dtw_req_pkt.smi_mpf2 === rtt_q[tmp_q[0]].dtr_req_pkt.smi_rmsg_id) &&
                                     (item.cache_addr === rtt_q[tmp_q[0]].cache_addr) &&
                                     (item.security   === rtt_q[tmp_q[0]].security) &&
                                     (item.dtw_req_pkt.smi_rbid === rtt_q[tmp_q[0]].dtw_req_pkt.smi_rbid) &&
                                     (item.DTWrsp_DTR_rsp_recd == 0));
       if(!tmp_q2.size())begin
         `uvm_error("<%=obj.BlockId%>:processDtrRsp", "smi_rmsg_id of DTRrsp for DtwMrgMrd not matching any of pending DtwRsp")
       end
       else begin
         wtt_q[tmp_q2[0]].DTWrsp_DTR_rsp_recd = 1;
       end
     end
     txn = rtt_q[tmp_q[0]];
     idx = tmp_q[0];
     txn.DTR_rsp_recd = 1;
     txn.dtr_rsp_pkt  = dtr_rsp_pkt;
     txn.t_dtrrsp = $time;
     txn.t_latest_update = $time;
     txn.print_entry();
     if(txn.exp_smi_tm != dtr_rsp_pkt.smi_tm) begin
       `uvm_error("<%=obj.BlockId%>:processDtrRsp", $sformatf("smi_tm not matching. Expd %0b Actual %0b", txn.exp_smi_tm, dtr_rsp_pkt.smi_tm))
     end
     `uvm_info("DMI_SCB", $psprintf("DMI_UID:%0d: DTR_RSP: %s", rtt_q[tmp_q[0]].txn_id, dtr_rsp_pkt.convert2string()), UVM_LOW);
     updateRttentry(txn,idx);
  end
endfunction // processDtrRsp
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Processing DTWReq
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//#Check.DMI.Concerto.v3.0.DMIoperationforDtw
//#Check.DMI.Concerto.v3.0.DTWProtocolFlow
function void dmi_scoreboard::processDtwReq(smi_seq_item dtw_req_pkt);
  int tmp_q[$],tmp_q1[$],tmp_q2[$],tmp_q3[$],tmp_q4[$],tmp_q5[$],tmp_q6[$];
  dmi_scb_txn  m_dtw_entry,txn;
  int test_q[$];
  ////////////////////////////////////////////////////////////////////////////////////////// 
  // check any rbid  matching any of the atomic in RTT   
  //////////////////////////////////////////////////////////////////////////////////////////
  tmp_q = {};
  tmp_q = rtt_q.find_index with((item.smi_rbid == dtw_req_pkt.smi_rbid) &&
                                (item.STR_req_recd == 1 ) && 
                                (item.smi_msg_type inside {CMD_RD_ATM,CMD_WR_ATM,CMD_SW_ATM,CMD_CMP_ATM}) &&
                                ((item.DTW_req_recd == 0) || (item.DTW_req_recd && !item.smi_dp_last)));

  test_q = rtt_q.find_index with(
                                (item.smi_rbid == dtw_req_pkt.smi_rbid) &&
                                (item.STR_req_recd) && 
                                (item.smi_msg_type inside {CMD_RD_ATM,CMD_WR_ATM,CMD_SW_ATM,CMD_CMP_ATM}) &&
                                ( (item.DTW_req_recd ==0) || ((item.DTW_req_recd==1) && (item.smi_dp_last==0)) )
                                );

  ////////////////////////////////////////////////////////////////////////////////////////// 
  // check any rbid waiting  matching   
  //////////////////////////////////////////////////////////////////////////////////////////
  tmp_q1 = {};
  tmp_q1 = wtt_q.find_index with((item.smi_rbid == dtw_req_pkt.smi_rbid) &&
                                 ((((item.isCoh == 1 && item.RB_req_recd == 1 && item.RB_rsp_expd && !item.RB_rsp_recd) ||(item.isNcWr && item.STR_req_recd == 1 )) && item.DTW_req_recd == 0) ||
                                 (item.DTW_req_recd == 1 && !item.smi_dp_last)));
  ////////////////////////////////////////////////////////////////////////////////////////// 
  // check any rbid  matching any of the atomic in RTT   
  //////////////////////////////////////////////////////////////////////////////////////////
  tmp_q3 = {};
  tmp_q3 = rtt_q.find_index with((item.smi_rbid == dtw_req_pkt.smi_rbid) &&
                                (item.isDtwMrgMrd == 1 ) && 
                                item.DTW_req_recd == 0);

  ////////////////////////////////////////////////////////////////////////////////////////// 
  // check any rbid  matching any of the wtt 
  //////////////////////////////////////////////////////////////////////////////////////////
  tmp_q4 = {};
  tmp_q4 = wtt_q.find_index with(((item.smi_rbid == dtw_req_pkt.smi_rbid) &&
                                  item.DTW_req_recd == 1 && 
                                  !item.isNcWr          &&
                                  item.smi_dp_last  == 1  &&
                                  item.DTW2nd_req_expd == 1 &&
                                  item.DTW2nd_req_recd == 0 )||
                                  ((item.smi_rbid == dtw_req_pkt.smi_rbid)&&
                                  item.DTW_req_recd == 1 &&
                                  !item.isNcWr          &&
                                  item.smi_dp_last == 1 &&
                                  dtw_req_pkt.smi_prim == 1 &&
                                  !item.RB_req_recd));
  //#Check.DMI.Concerto.v3.0.AiuIdDtwReq
  ////////////////////////////////////////////////////////////////////////////////////////// 
  // check any nonCoh rbid  matching any of the NonCoh cmd inflight
  //////////////////////////////////////////////////////////////////////////////////////////
  tmp_q5 = {};
  tmp_q5 = wtt_q.find_index with((item.smi_rbid == dtw_req_pkt.smi_rbid) &&
                                  item.isNcWr == 1 &&
                                 ((item.STR_req_recd == 1 && item.DTW_req_recd == 0) ||
                                  (item.DTW_req_recd == 1 && !item.smi_dp_last)));

  ////////////////////////////////////////////////////////////////////////////////////////
  `uvm_info("<%=obj.BlockId%>:processDtwReq", $sformatf("Cache Rbid %0x of dtw req matching req wtt_q tmp_q1 :%0d,tmp_q4 :%0d,RTT tmp_q :%0d(%0d),tmp_q3 :%0d",dtw_req_pkt.smi_rbid,tmp_q1.size(),tmp_q4.size(),tmp_q.size(),test_q.size(),tmp_q3.size()),UVM_MEDIUM)

  if(dtw_req_pkt.smi_rbid[WSMIRBID-2:0] >= <%=obj.DmiInfo[obj.Id].cmpInfo.nDceRbEntries%> )begin
    if(!(tmp_q.size()+tmp_q5.size()))begin
      `uvm_error("<%=obj.BlockId%>:processDtwReq", $sformatf("dtw_req_pkt.smi_rbid :%0d not matching any pending NcCmd",dtw_req_pkt.smi_rbid))
    end
  end
  //#Check.DMI.Concerto.v3.0.DtwReqRL
  if(dtw_req_pkt.smi_msg_type inside {DTW_MRG_MRD_INV,DTW_MRG_MRD_SCLN,DTW_MRG_MRD_SDTY,DTW_MRG_MRD_UCLN,DTW_MRG_MRD_UDTY}) begin
    if(dtw_req_pkt.smi_rl != 'b01 && dtw_req_pkt.smi_rl != 'b11) begin
      `uvm_error("<%=obj.BlockId%>:processDtwReq", $sformatf("DtwMrgMrd should have RL 01 or 11. Got %0b",dtw_req_pkt.smi_rl))
    end
  end else begin
    if(dtw_req_pkt.smi_rl != 'b10) begin
      `uvm_error("<%=obj.BlockId%>:processDtwReq", $sformatf("Dtw should have RL 10. Got %0b",dtw_req_pkt.smi_rl))
    end
  end

  if(tmp_q3.size() >0)begin
    if(dtw_req_pkt.smi_dp_last)begin
      `uvm_info("<%=obj.BlockId%>:processDtwReq", $sformatf("Cache Rbid of dtw req  matching RTT updating for DtwMrgMrd "),UVM_MEDIUM)
      rtt_q[tmp_q3[0]].dtw_req_pkt.do_copy(dtw_req_pkt);
      rtt_q[tmp_q3[0]].smi_intfsize             = dtw_req_pkt.smi_intfsize;
      rtt_q[tmp_q3[0]].DTW_req_recd             = 1;
      rtt_q[tmp_q3[0]].t_dtwreq                 = $time;
      `uvm_info("DMI_SCB", $psprintf("DMI_UID:%0d: DTW_REQ: %s", rtt_q[tmp_q3[0]].txn_id, rtt_q[tmp_q3[0]].dtw_req_pkt.convert2string()), UVM_LOW) 
      if(rtt_q[tmp_q3[0]].exp_smi_tm != dtw_req_pkt.smi_tm) begin
        `uvm_error("<%=obj.BlockId%>:processDtwReq_0", $sformatf("smi_tm not matching. Expd %0b Actual %0b", rtt_q[tmp_q[0]].exp_smi_tm, dtw_req_pkt.smi_tm))
      end
     `uvm_info("<%=obj.BlockId%>:processDtwReq", $sformatf("Calling rearrangedtwdata to rearrange the dtw "),UVM_MEDIUM)
      rearrangedtwdata(rtt_q[tmp_q3[0]]);
      rtt_q[tmp_q3[0]].print_entry();
      if((rtt_q[tmp_q3[0]].AXI_read_data_expd ==1 && rtt_q[tmp_q3[0]].AXI_read_data_recd ==1) || (rtt_q[tmp_q3[0]].DTR_req_recd == 1))begin
        MrgMrddata(rtt_q[tmp_q3[0]]);
        if(rtt_q[tmp_q3[0]].DTR_req_recd == 1)begin
         rearrangedtrdata(rtt_q[tmp_q3[0]]);
        end
      end
    end
  end

  if(tmp_q4.size() >1)begin
   `uvm_error("<%=obj.BlockId%>:processDtwReq", $sformatf("Cache Rbid %0x of dtw req matching multiple req wtt_q :%0d",dtw_req_pkt.smi_rbid,tmp_q4.size()))
  end
  //#Check.DMI.Concerto.v3.0.RbUreqTiming_1
  else if(tmp_q4.size() == 1)begin
    if(!(!wtt_q[tmp_q4[0]].dtw_req_pkt.smi_prim && dtw_req_pkt.smi_prim) && dtw_req_pkt.smi_dp_last)begin
      wtt_q[tmp_q4[0]].print_entry();
      `uvm_info("<%=obj.BlockId%>:processDtwReq", $sformatf("wtt_q[tmp_q4[0]].dtw_req_pkt.smi_prim :%0b dtw_req_pkt.smi_prim :%0b",wtt_q[tmp_q4[0]].dtw_req_pkt.smi_prim,dtw_req_pkt.smi_prim),UVM_LOW)
      `uvm_error("<%=obj.BlockId%>:processDtwReq", $sformatf("DMI should receive secondary DTW before primary"))
    end
    else begin
      //if(dtw_req_pkt.smi_dp_last)begin
          //#Check.DMI.Concerto.v3.0.DtwReqTM
          if(wtt_q[tmp_q4[0]].exp_smi_tm != dtw_req_pkt.smi_tm) begin
              `uvm_error("<%=obj.BlockId%>:processDtwReq_2", $sformatf("smi_tm not matching. Expd %0b Actual %0b", wtt_q[tmp_q4[0]].exp_smi_tm, dtw_req_pkt.smi_tm))
          end
          tmp_q6 = {};
          tmp_q6 = wtt_q.find_index with( (item.smi_rbid == dtw_req_pkt.smi_rbid)&&
                                          (item.DTW_req_recd  == 1) &&
                                          (!item.isNcWr) &&
                                          (item.smi_dp_last == 0) &&
                                          (item.RBU_req_recd == 0));
          
          if(tmp_q6.size()) m_dtw_entry = wtt_q[tmp_q6[0]];
          else m_dtw_entry = new();

          //m_dtw_entry = new();
          m_dtw_entry.addToWttQ(dtw_req_pkt, !((dtw_req_pkt.smi_msg_type === DTW_DATA_CLN && ! WrDataClnPropagateEn) | dtw_req_pkt.smi_msg_type == DTW_NO_DATA | dtw_req_pkt.smi_msg_type == DTW_MRG_MRD_UDTY ), 0,0,uncorr_data_err);
          `uvm_info("DMI_SCB", $psprintf("DMI_UID:%0d: DTW_REQ: %s", m_dtw_entry.txn_id,dtw_req_pkt.convert2string()), UVM_LOW) 
          <%if(obj.useCmc){%>
          if (lookup_en) begin
             if(dtw_req_pkt.smi_msg_type == DTW_NO_DATA)begin
               m_dtw_entry.lookupExpd = 0;
             end
             //#Check.DMI.Concerto.v3.6.EnforceCleanWritePropagation
             if(!(dtw_req_pkt.smi_msg_type === DTW_DATA_CLN &&  WrDataClnPropagateEn)) begin
               m_dtw_entry.AXI_write_addr_expd      = 0;
               m_dtw_entry.AXI_write_data_expd      = 0;
               m_dtw_entry.AXI_write_resp_expd      = 0;
             end
          end else begin
             m_dtw_entry.lookupExpd = 0;
          end
          <%}%>
          m_dtw_entry.dtw_req_pkt.do_copy(dtw_req_pkt);
          m_dtw_entry.dtw_msg_id               = dtw_req_pkt.smi_msg_id;
          m_dtw_entry.dtw_src_ncore_unit_id    = dtw_req_pkt.smi_src_ncore_unit_id;
          m_dtw_entry.smi_rbid                 = dtw_req_pkt.smi_rbid;
          m_dtw_entry.smi_dp_last              = dtw_req_pkt.smi_dp_last;
          //m_dtw_entry.smi_intfsize             = dtw_req_pkt.smi_intfsize;
          m_dtw_entry.isCoh                    = 1;
          m_dtw_entry.DTW_req_recd             = 1;
          m_dtw_entry.RB_rsp_expd              = 0;
          m_dtw_entry.wrOutstanding            = !(dtw_req_pkt.smi_msg_type == DTW_MRG_MRD_UDTY);
          if((dtw_req_pkt.smi_msg_type == DTW_MRG_MRD_UDTY) && dtw_req_pkt.smi_dp_last)begin
            m_dtw_entry.isDtwMrgMrd  = 1;
            m_dtw_entry.isDtw        = 0;
            if(dtw_req_pkt.smi_rl == 2'b11)begin
              m_dtw_entry.DTWrsp_DTR_rsp_expd = 1;
            end
          end
          if(wtt_q[tmp_q4[0]].RB_req_recd)begin
            m_dtw_entry.rb_req_pkt               = new(); 
            m_dtw_entry.rb_req_pkt.do_copy(wtt_q[tmp_q4[0]].rb_req_pkt); 
            m_dtw_entry.cache_addr               = wtt_q[tmp_q4[0]].rb_req_pkt.smi_addr; 
            <%if (obj.wSecurityAttribute > 0) { %>
            m_dtw_entry.security                 = wtt_q[tmp_q4[0]].rb_req_pkt.smi_ns; 
            <% } %>
            m_dtw_entry.privileged               = wtt_q[tmp_q4[0]].rb_req_pkt.smi_pr; 
            m_dtw_entry.smi_size                 = wtt_q[tmp_q4[0]].rb_req_pkt.smi_size; 
            m_dtw_entry.smi_vz                   = wtt_q[tmp_q4[0]].rb_req_pkt.smi_vz; 
            m_dtw_entry.smi_qos                  = wtt_q[tmp_q4[0]].rb_req_pkt.smi_qos; 
            m_dtw_entry.smi_ac                   = wtt_q[tmp_q4[0]].rb_req_pkt.smi_ac; 
            m_dtw_entry.smi_ndp_aux_aw           = wtt_q[tmp_q4[0]].rb_req_pkt.smi_ndp_aux;
            m_dtw_entry.exp_smi_tm               = wtt_q[tmp_q4[0]].exp_smi_tm;
            //m_dtw_entry.isMW                   = wtt_q[tmp_q4[0]].rb_req_pkt.smi_mw; 
            m_dtw_entry.RB_req_recd              = 1;
            if(dtw_req_pkt.smi_dp_last)begin 
              `uvm_info("<%=obj.BlockId%>:processDtwReq", $sformatf("Calling rearrangedtwdata to rearrange the dtw "),UVM_MEDIUM)
              rearrangedtwdata(m_dtw_entry);
            end
            <% if(obj.useCmc && obj.DmiInfo[obj.Id].ccpParams.useScratchpad){%>
            m_dtw_entry.cache_index              = ncoreConfigInfo::get_set_index(wtt_q[tmp_q4[0]].rb_req_pkt.smi_addr,<%=obj.DmiInfo[obj.Id].FUnitId%>); 
            m_dtw_entry.lower_sp_addr            = lower_sp_addr;
            m_dtw_entry.upper_sp_addr            = upper_sp_addr;
            m_dtw_entry.sp_enabled               = sp_enabled;
            m_dtw_entry.sp_ns                    = sp_ns;
            m_dtw_entry.rsvd_ways                = (2**$clog2(sp_ways)) - 1;
            m_dtw_entry.cache_addr_i             = ncoreConfigInfo::gen_spad_intrlv_rmvd_addr(m_dtw_entry.cache_addr,<%=obj.DmiInfo[obj.Id].nUnitId%>);
            m_dtw_entry.CalSPProperty();
            if(m_dtw_entry.sp_txn) begin 
               m_dtw_entry.lookupExpd = 0;
               m_dtw_entry.AXI_write_addr_expd   = 0;
               m_dtw_entry.AXI_write_data_expd   = 0;
               m_dtw_entry.AXI_write_resp_expd   = 0;
               if(dtw_req_pkt.smi_msg_type == DTW_NO_DATA)begin
                 //SP txn with Null Data is never seen on the SP channel
                 m_dtw_entry.sp_seen_ctrl_chnl = 1;
                 m_dtw_entry.sp_seen_write_chnl = 1;
               end
            end
            if(!lookup_en) begin
              m_dtw_entry.lookupExpd = 0;
            end
            <% } %>
            <% if(!obj.useCmc) { %>
            if(wtt_q[tmp_q4[0]].RB_req_recd)begin
                 if((dtw_req_pkt.smi_msg_type == DTW_MRG_MRD_UDTY) && wtt_q[tmp_q4[0]].RB_req_recd && !wtt_q[tmp_q4[0]].isRttCreated )begin
                 processMrdReq(wtt_q[tmp_q4[0]].rb_req_pkt,1,m_dtw_entry);
                 m_dtw_entry.isRttCreated = 1;
                 wtt_q[tmp_q4[0]].isRttCreated = 1;
                  numDtwMrgMrdTxns++;
               end
            end
            <% } %>
          end
          if(!lookup_en) begin
            if(isdtwmrgmrd(dtw_req_pkt.smi_msg_type) && m_dtw_entry.RB_req_recd && !m_dtw_entry.isRttCreated)begin
              processMrdReq(m_dtw_entry.rb_req_pkt,1,m_dtw_entry);
              m_dtw_entry.isRttCreated = 1;
              m_dtw_entry.lookupExpd = 0;
              numDtwMrgMrdTxns++;
            end
          end
          m_dtw_entry.t_dtwreq                 = $time;
          if(!tmp_q6.size()) begin 
            wtt_q.push_back(m_dtw_entry);
            `uvm_info("DMI_SCB", $psprintf("DMI_UID:%0d: DTW_REQ: %s", m_dtw_entry.txn_id, m_dtw_entry.dtw_req_pkt.convert2string()), UVM_LOW) 
          end
          wtt_q[tmp_q4[0]].RBU_req_expd        = 0;
          wtt_q[tmp_q4[0]].RBU_rsp_expd        = 0;
          wtt_q[tmp_q4[0]].DTW2nd_req_recd     = 1;
          wtt_q[tmp_q4[0]].print_entry();
          //print_wtt_q(); //VDEL
          updateWttentry(wtt_q[tmp_q4[0]],tmp_q4[0]);
      //end
    end
  end
  else if(tmp_q.size()+tmp_q1.size() >1)begin
    `uvm_error("<%=obj.BlockId%>:processDtwReq", $sformatf("Cache Rbid %0x of dtw req matching multiple req rtt_q :%0d wtt_q :%0d",dtw_req_pkt.smi_rbid,tmp_q.size(),tmp_q1.size()))
  end
  else if(tmp_q.size()>0)begin
    `uvm_info("<%=obj.BlockId%>:processDtwReq", $sformatf("Cache Rbid of dtw req  matching RTT updating "),UVM_MEDIUM)
    rtt_q[tmp_q[0]].dtw_req_pkt.do_copy(dtw_req_pkt);
    rtt_q[tmp_q[0]].dtw_msg_type             = dtw_req_pkt.smi_msg_type;
    rtt_q[tmp_q[0]].dtw_msg_id               = dtw_req_pkt.smi_msg_id;
    rtt_q[tmp_q[0]].dtw_src_ncore_unit_id    = dtw_req_pkt.smi_src_ncore_unit_id;
    rtt_q[tmp_q[0]].smi_dp_last              = dtw_req_pkt.smi_dp_last;
    //rtt_q[tmp_q[0]].exp_smi_tm               = dtw_req_pkt.smi_tm;
    rtt_q[tmp_q[0]].DTW_req_recd             = 1;
    rtt_q[tmp_q[0]].t_dtwreq                 = $time;
    `ifndef FSYS_COVER_ON
    cov.matched_cmd_req_item                 = rtt_q[tmp_q[0]].cmd_req_pkt;
    `endif
    if(rtt_q[tmp_q[0]].exp_smi_tm != dtw_req_pkt.smi_tm) begin
      `uvm_error("<%=obj.BlockId%>:processDtwReq_1", $sformatf("smi_tm not matching. Expd %0b Actual %0b", rtt_q[tmp_q[0]].exp_smi_tm, dtw_req_pkt.smi_tm))
    end
    if(dtw_req_pkt.smi_dp_last)begin
      rtt_q[tmp_q[0]].smi_dp_last            = 1;
      `uvm_info("<%=obj.BlockId%>:processDtwReq", $sformatf("Calling rearrangedtwdata to rearrange the dtw "),UVM_MEDIUM)
      rearrangedtwdata(rtt_q[tmp_q[0]]);
    end
    rtt_q[tmp_q[0]].print_entry();
    <%if(obj.useCmc){%>
    if((rtt_q[tmp_q[0]].cacheRspExpd && rtt_q[tmp_q[0]].cacheRspRecd) ||
       (rtt_q[tmp_q[0]].AXI_read_data_expd && rtt_q[tmp_q[0]].AXI_read_data_recd) ||
       (rtt_q[tmp_q[0]].sp_txn && rtt_q[tmp_q[0]].sp_seen_output_chnl) &&
        rtt_q[tmp_q[0]].smi_msg_type inside {CMD_RD_ATM,CMD_CMP_ATM,CMD_SW_ATM,CMD_WR_ATM}) begin
       process_atomic_op(rtt_q[tmp_q[0]],tmp_q[0]);
    end
    if(dtw_req_pkt.smi_dp_last)begin
      `uvm_info("DMI_SCB", $psprintf("DMI_UID:%0d: DTW_REQ: %s", rtt_q[tmp_q[0]].txn_id, rtt_q[tmp_q[0]].dtw_req_pkt.convert2string()), UVM_LOW);
      updateRttentry(rtt_q[tmp_q[0]],tmp_q[0]);
    end
    <%}%>
  end
  else if(!tmp_q1.size())begin
    `uvm_info("<%=obj.BlockId%>:processDtwReq", $sformatf("Cache Rbid of dtw req not matching any WTT, creating new entry "),UVM_MEDIUM)
    m_dtw_entry = new();
    m_dtw_entry.addToWttQ(dtw_req_pkt, !((dtw_req_pkt.smi_msg_type === DTW_DATA_CLN && !WrDataClnPropagateEn) | dtw_req_pkt.smi_msg_type == DTW_NO_DATA | dtw_req_pkt.smi_msg_type == DTW_MRG_MRD_UDTY), 0,0,uncorr_data_err);
    <%if(obj.useCmc){%>
    if (lookup_en) begin
       if(dtw_req_pkt.smi_msg_type == DTW_NO_DATA)begin
         m_dtw_entry.lookupExpd = 0;
       end
       //#Check.DMI.Concerto.v3.6.EnforceCleanWritePropagation
       if(!(dtw_req_pkt.smi_msg_type === DTW_DATA_CLN && WrDataClnPropagateEn)) begin
         m_dtw_entry.AXI_write_addr_expd      = 0;
         m_dtw_entry.AXI_write_data_expd      = 0;
         m_dtw_entry.AXI_write_resp_expd      = 0;
       end
    end else begin
       m_dtw_entry.lookupExpd = 0;
    end
    <%}%>
    m_dtw_entry.dtw_req_pkt.do_copy(dtw_req_pkt);
    m_dtw_entry.dtw_msg_id               = dtw_req_pkt.smi_msg_id;
    m_dtw_entry.dtw_src_ncore_unit_id    = dtw_req_pkt.smi_src_ncore_unit_id;
    m_dtw_entry.smi_rbid                 = dtw_req_pkt.smi_rbid;
    //m_dtw_entry.smi_intfsize             = dtw_req_pkt.smi_intfsize;
    m_dtw_entry.smi_dp_last              = dtw_req_pkt.smi_dp_last;
    m_dtw_entry.DTW_req_recd             = 1;
    m_dtw_entry.t_dtwreq                 = $time;
    if(isdtwmrgmrd(dtw_req_pkt.smi_msg_type) && dtw_req_pkt.smi_dp_last)begin
      m_dtw_entry.isDtwMrgMrd  = 1;
      m_dtw_entry.isDtw        = 0;
      if(dtw_req_pkt.smi_rl == 2'b11)begin
        m_dtw_entry.DTWrsp_DTR_rsp_expd = 1;
      end
    end
    wtt_q.push_back(m_dtw_entry);
    `uvm_info("DMI_SCB", $psprintf("DMI_UID:%0d: DTW_REQ: %s", wtt_q[$].txn_id, wtt_q[$].dtw_req_pkt.convert2string()), UVM_LOW);

    // ->smi_raise;
  end
  else if(tmp_q1.size() >0) begin
    `uvm_info("<%=obj.BlockId%>:processDtwReq", $sformatf("Cache Rbid of dtw req  matching WTT updating "),UVM_MEDIUM)
    // tmp_q2 = wtt_q.find_index with ( (item.cache_addr == wtt_q[tmp_q1[0]].cache_addr) && 
    //                                  (item.security   == wtt_q[tmp_q1[0]].security) && 
    //                                  (item.dtw_msg_type == dtw_req_pkt.smi_msg_type)&&
    //                                  (item.dtw_msg_type == DTW_DATA_CLN )&&
    //                                  (item.smi_ac      == 1) &&
    //                                  (item.lookupExpd == 1) && 
    //                                  (item.lookupSeen == 1));

    if(tmp_q2.size()>0)begin
      `uvm_info("<%=obj.BlockId%>:processDtwReq",$sformatf("DTW_DATA_CLN colliding  DTW_DATA_CLN inflight with ac =1"),UVM_MEDIUM);
    end
    
    if(wtt_q[tmp_q1[0]].isNcWr || wtt_q[tmp_q1[0]].RB_req_recd) begin
      if(wtt_q[tmp_q1[0]].exp_smi_tm != dtw_req_pkt.smi_tm) begin
         `uvm_error("<%=obj.BlockId%>:processDtwReq_3",$sformatf("smi_tm not matching. Expd %0b Actual %0b", wtt_q[tmp_q1[0]].exp_smi_tm, dtw_req_pkt.smi_tm))
      end
    end

    `ifndef FSYS_COVER_ON
    if(wtt_q[tmp_q1[0]].isNcWr) cov.matched_cmd_req_item = wtt_q[tmp_q1[0]].cmd_req_pkt;
    `endif

    if(!wtt_q[tmp_q1[0]].isNcWr)begin
      if(!wtt_q[tmp_q1[0]].DTW_req_recd)begin
        //#Check.DMI.Concerto.v3.6.EnforceCleanWritePropagation
        wtt_q[tmp_q1[0]].addToWttQ(dtw_req_pkt, !((dtw_req_pkt.smi_msg_type === DTW_DATA_CLN && !WrDataClnPropagateEn) | dtw_req_pkt.smi_msg_type == DTW_NO_DATA | dtw_req_pkt.smi_msg_type == DTW_MRG_MRD_UDTY), 0,0,uncorr_data_err);
        `uvm_info("DMI_SCB", $psprintf("DMI_UID:%0d: DTW_REQ: %s", wtt_q[tmp_q1[0]].txn_id, dtw_req_pkt.convert2string()), UVM_LOW);
      end
    end
    <% if(!obj.useCmc) { %>
    else if(wtt_q[tmp_q1[0]].isNcWr)begin
      if ((wtt_q[tmp_q1[0]].m_exmon_status != EX_FAIL && exmon_size > 0) || exmon_size == 0) begin
        wtt_q[tmp_q1[0]].AXI_write_addr_expd = !((dtw_req_pkt.smi_msg_type === DTW_DATA_CLN && ! WrDataClnPropagateEn)| dtw_req_pkt.smi_msg_type == DTW_NO_DATA);
        wtt_q[tmp_q1[0]].AXI_write_data_expd = !((dtw_req_pkt.smi_msg_type === DTW_DATA_CLN && ! WrDataClnPropagateEn)| dtw_req_pkt.smi_msg_type == DTW_NO_DATA);
        wtt_q[tmp_q1[0]].AXI_write_resp_expd = !((dtw_req_pkt.smi_msg_type === DTW_DATA_CLN && ! WrDataClnPropagateEn)| dtw_req_pkt.smi_msg_type == DTW_NO_DATA);
      end
    end
    <% } else { %>
    else if(wtt_q[tmp_q1[0]].isNcWr && !lookup_en)begin
      if ((wtt_q[tmp_q1[0]].m_exmon_status != EX_FAIL && exmon_size > 0) || exmon_size == 0) begin
        wtt_q[tmp_q1[0]].AXI_write_addr_expd = !((dtw_req_pkt.smi_msg_type === DTW_DATA_CLN && ! WrDataClnPropagateEn)| dtw_req_pkt.smi_msg_type == DTW_NO_DATA);
        wtt_q[tmp_q1[0]].AXI_write_data_expd = !((dtw_req_pkt.smi_msg_type === DTW_DATA_CLN && ! WrDataClnPropagateEn)| dtw_req_pkt.smi_msg_type == DTW_NO_DATA);
        wtt_q[tmp_q1[0]].AXI_write_resp_expd = !((dtw_req_pkt.smi_msg_type === DTW_DATA_CLN && ! WrDataClnPropagateEn)| dtw_req_pkt.smi_msg_type == DTW_NO_DATA);
      end
    end
    //#Check.DMI.Concerto.v3.6.EnforceCleanWritePropagation
    if(!wtt_q[tmp_q1[0]].lookupSeen && lookup_en && !(dtw_req_pkt.smi_msg_type === DTW_DATA_CLN & WrDataClnPropagateEn))begin
      wtt_q[tmp_q1[0]].AXI_write_addr_expd = 0;
      wtt_q[tmp_q1[0]].AXI_write_data_expd = 0;
      wtt_q[tmp_q1[0]].AXI_write_resp_expd = 0;
    end


    if(dtw_req_pkt.smi_msg_type == DTW_NO_DATA || (dtw_req_pkt.smi_msg_type === DTW_DATA_CLN && (wtt_q[tmp_q1[0]].isNcWr || wtt_q[tmp_q1[0]].RB_req_recd) && !WrDataClnPropagateEn && !wtt_q[tmp_q1[0]].smi_ac) || !lookup_en)begin
      if(!wtt_q[tmp_q1[0]].lookupSeen)begin
        wtt_q[tmp_q1[0]].lookupExpd = 0;
      end
    end
    else begin
      // Not required to lookup for a SP txn
      if(exmon_size > 0) begin
        if(!wtt_q[tmp_q1[0]].sp_txn && (wtt_q[tmp_q1[0]].m_exmon_status != EX_FAIL)) wtt_q[tmp_q1[0]].lookupExpd = 1;
        else wtt_q[tmp_q1[0]].lookupExpd = 0;
      end else begin
        if(!wtt_q[tmp_q1[0]].sp_txn) wtt_q[tmp_q1[0]].lookupExpd = 1;
        else wtt_q[tmp_q1[0]].lookupExpd = 0;
      end   
    end
    // From the micro-arch, ==DTW_NO_DATA and CLN to Scratchpad are always dropped: CONC-4437==
    // #Check.DMI.Concerto.v3.0.DropDtwNoDataAndDtwCln
    if(wtt_q[tmp_q1[0]].sp_txn && (dtw_req_pkt.smi_msg_type inside {DTW_NO_DATA, DTW_DATA_CLN})) begin
      `uvm_info("<%=obj.BlockId%>:processDtwReq", $psprintf("Got DTW packet with DTW_DATA_CLN msg for a SP txn, so dropping this data and this txn is not supposed to go on SP control channel now" ),UVM_MEDIUM)
      wtt_q[tmp_q1[0]].sp_seen_ctrl_chnl  = 1;
      wtt_q[tmp_q1[0]].sp_seen_write_chnl = 1;
    end
    if(wtt_q[tmp_q1[0]].sp_txn)begin
      wtt_q[tmp_q1[0]].AXI_write_addr_expd = 0;
      wtt_q[tmp_q1[0]].AXI_write_data_expd = 0;
      wtt_q[tmp_q1[0]].AXI_write_resp_expd = 0;
    end
    <% } %>
    // Secondary dtw with isMW = 1 should be full cacheline
    //#Check.DMI.Concerto.v3.0.DtwMrgMrdDataSize
    if(!dtw_req_pkt.smi_prim && !isdtwmrgmrd(dtw_req_pkt.smi_msg_type) && wtt_q[tmp_q1[0]].isMW) begin
      wtt_q[tmp_q1[0]].smi_size = 6;
    end

    wtt_q[tmp_q1[0]].dtw_req_pkt.do_copy(dtw_req_pkt);
    if(wtt_q[tmp_q1[0]].dtw_req_pkt.smi_dp_last)begin
       `uvm_info("DMI_SCB", $psprintf("DMI_UID:%0d: DTW_REQ: %s", wtt_q[tmp_q1[0]].txn_id, wtt_q[tmp_q1[0]].dtw_req_pkt.convert2string()), UVM_LOW)
    end
    if(wtt_q[tmp_q1[0]].isNcWr || (!wtt_q[tmp_q1[0]].isNcWr && wtt_q[tmp_q1[0]].RB_req_recd))begin
      if(dtw_req_pkt.smi_dp_last)begin 
        `uvm_info("<%=obj.BlockId%>:processDtwReq", $sformatf("Calling rearrangedtwdata to rearrange the dtw "),UVM_MEDIUM)
        rearrangedtwdata(wtt_q[tmp_q1[0]]);
      end
    end
    <% if(!obj.useCmc) { %>
    if(isdtwmrgmrd(dtw_req_pkt.smi_msg_type) && wtt_q[tmp_q1[0]].RB_req_recd && !wtt_q[tmp_q1[0]].isRttCreated)begin
      processMrdReq(wtt_q[tmp_q1[0]].rb_req_pkt,1,wtt_q[tmp_q1[0]]);
      wtt_q[tmp_q1[0]].isRttCreated = 1;
      numDtwMrgMrdTxns++;
    end
    <% } else {%>
   if(!lookup_en)begin
     if(isdtwmrgmrd(dtw_req_pkt.smi_msg_type) && wtt_q[tmp_q1[0]].RB_req_recd && !wtt_q[tmp_q1[0]].isRttCreated)begin
       processMrdReq(wtt_q[tmp_q1[0]].rb_req_pkt,1,wtt_q[tmp_q1[0]]);
       wtt_q[tmp_q1[0]].isRttCreated = 1;
       numDtwMrgMrdTxns++;
     end
   end
   <% } %>
     
   //#Check.DMI.Concerto.v3.0.MWdtwSecondarySize
   /*if(wtt_q[tmp_q1[0]].RB_req_recd)begin
      if(!wtt_q[tmp_q1[0]].isMW && !dtw_req_pkt.smi_prim)begin
        if(2**wtt_q[tmp_q1[0]].smi_size != SYS_nSysCacheline)begin
          `uvm_error("process_dtwreq",$sformatf(" if RbReq MW = 0, and primary bit = 0 ,then size of Dtw data will be coherency granule"));
        end
      end
    end*/

   if(isdtwmrgmrd(dtw_req_pkt.smi_msg_type) && !wtt_q[tmp_q1[0]].isDtwMrgMrd)begin
      wtt_q[tmp_q1[0]].isDtwMrgMrd         = 1;
      wtt_q[tmp_q1[0]].isDtw               = 0;
      if(dtw_req_pkt.smi_rl == 2'b11)begin
        wtt_q[tmp_q1[0]].DTWrsp_DTR_rsp_expd = 1;
      end
   end
   //#Check.DMI.Concerto.v3.0.MWdtwOrdering
   if(!dtw_req_pkt.smi_prim && !isdtwmrgmrd(dtw_req_pkt.smi_msg_type) && wtt_q[tmp_q1[0]].isMW) begin
     wtt_q[tmp_q1[0]].DTW2nd_req_expd = 1;
     wtt_q[tmp_q1[0]].smi_size        = 6;
   end
   wtt_q[tmp_q1[0]].dtw_msg_type             = dtw_req_pkt.smi_msg_type;
   wtt_q[tmp_q1[0]].dtw_msg_id               = dtw_req_pkt.smi_msg_id;
   wtt_q[tmp_q1[0]].dtw_src_ncore_unit_id    = dtw_req_pkt.smi_src_ncore_unit_id;
   wtt_q[tmp_q1[0]].smi_dp_last              = dtw_req_pkt.smi_dp_last;
   wtt_q[tmp_q1[0]].DTW_req_recd             = 1;
   wtt_q[tmp_q1[0]].t_dtwreq                 = $time;
   
   if(wtt_q[tmp_q1[0]].RB_req_recd)begin
     wtt_q[tmp_q1[0]].print_entry();
   end

   if(wtt_q[tmp_q1[0]].RB_req_recd && wtt_q[tmp_q1[0]].isMW ||(wtt_q[tmp_q1[0]].DTW_rsp_recd && wtt_q[tmp_q1[0]].smi_dp_last))begin
     updateWttentry(wtt_q[tmp_q1[0]],tmp_q1[0]);
   end
  end
  if(dtw_req_pkt.smi_dp_last && conc9307_test) begin
    if(isDtwMsg(dtw_req_pkt.smi_msg_type) && !isdtwmrgmrd(dtw_req_pkt.smi_msg_type)) dtw_num++;
    `uvm_info("dmi_scoreboard", $sformatf("dtw_count %0d dtw_num %0d", dtw_count, dtw_num), UVM_DEBUG)
    if(dtw_num == dtw_count) begin
      `uvm_info("dmi_scoreboard","triggering evt_send_dtr_rsp", UVM_DEBUG)
      evt_send_dtr_rsp.trigger();
    end
  end
endfunction //processDtwReq/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

function void dmi_scoreboard::processDtwRsp(smi_seq_item dtw_rsp_pkt);
  int tmp_q[$],tmp_q1[$];
  int tmp_q_dbad[$];
  dmi_scb_txn txn;
  tmp_q = {};
  tmp_q_dbad = {};
  //#Check.DMI.SMImsgIDFieldCorrect
  //#Check.DMI.DTWRspFields
  `uvm_info("<%=obj.BlockId%>:processDtwRsp", $sformatf("%1p",dtw_rsp_pkt), UVM_MEDIUM)
  tmp_q = wtt_q.find_index with ((item.dtw_msg_id == dtw_rsp_pkt.smi_rmsg_id) && 
                                 (item.dtw_src_ncore_unit_id == dtw_rsp_pkt.smi_targ_ncore_unit_id) && 
                                 (item.DTW_req_recd == 1) && 
                                 (item.DTW_rsp_recd == 0));


  tmp_q1 = rtt_q.find_index with ((item.dtw_msg_id == dtw_rsp_pkt.smi_rmsg_id) && 
                                 (item.dtw_src_ncore_unit_id == dtw_rsp_pkt.smi_targ_ncore_unit_id) &&
                                 (item.DTW_req_recd == 1) &&
                                 (item.DTW_rsp_recd == 0));
  //#Check.DMI.Concerto.v3.0.DtwRspRMessageId
  if(tmp_q.size + tmp_q1.size == 0) begin
    `uvm_info("<%=obj.BlockId%>:processDtwRsp", $sformatf("%1p",dtw_rsp_pkt), UVM_LOW)
    `uvm_error("<%=obj.BlockId%>:processDtwRsp", " Any Dtw with smi_msg_id not matching dtw_rsp.smi_rmsg_id")
  end
  else if (tmp_q.size +tmp_q1.size > 1) begin
    `uvm_info("<%=obj.BlockId%>:processDtwRsp", $sformatf("%1p",dtw_rsp_pkt), UVM_MEDIUM)
    `uvm_error("<%=obj.BlockId%>:processDtwRsp", $sformatf("smi_rmsg_id matching  multiple outstanding requests dtw wtt_q :%0d rtt_q :%0d",tmp_q.size,tmp_q1.size))
  end
  else begin
    `uvm_info("<%=obj.BlockId%>:processDtwRsp", $sformatf("%1p",dtw_rsp_pkt), UVM_MEDIUM)
    if(tmp_q.size == 1)begin
      `uvm_info("<%=obj.BlockId%>:processDtwRsp","WTT entry matching",UVM_MEDIUM)
      txn = wtt_q[tmp_q[0]];
    end
    else begin
      `uvm_info("<%=obj.BlockId%>:processDtwRsp","RTT entry matching",UVM_MEDIUM)
      txn = rtt_q[tmp_q1[0]];
    end
    //#Check.DMI.Concerto.v3.0.DtwRspAfterDtrRsp
    if(txn.isDtwMrgMrd)begin
      if((txn.dtw_req_pkt.smi_rl == 'b11) && !txn.DTWrsp_DTR_rsp_recd)begin
        txn.print_entry();
        `uvm_error("<%=obj.BlockId%>:processDtwRsp", "for DtwMrgMrd DTR_rsp should be received before sending the DTW_rsp")
      end
    end
    txn.DTW_rsp_recd = 1;
    txn.dtw_rsp_pkt = dtw_rsp_pkt;
    txn.t_dtwrsp = $time;
    txn.t_latest_update = $time;
    txn.print_entry();
    
    if(txn.exp_smi_tm != dtw_rsp_pkt.smi_tm) begin
      `uvm_error("<%=obj.BlockId%>:processDtwRsp",$sformatf("smi_tm not matching. Expd %0b Actual %0b DMI_UID:%0d:", txn.exp_smi_tm, dtw_rsp_pkt.smi_tm, txn.txn_id))
    end 

    <%if (obj.DmiInfo[obj.Id].fnEnableQos) { %>
    if(dtw_rsp_pkt.smi_msg_pri != ncoreConfigInfo::qos_mapping(txn.smi_qos))begin
      `uvm_error("<%=obj.BlockId%>:processDtwRsp",$sformatf("Priority for smi_qos :%0x Exp :%0x Recd :%0x DMI_UID:%0d:",txn.smi_qos,ncoreConfigInfo::qos_mapping(txn.smi_qos),dtw_rsp_pkt.smi_msg_pri, txn.txn_id))
    end
    <% } %>
    if(txn.DTW_rsp_recd)begin
      <% if (obj.useCmc) { %>
      //  Check disabled as per implementaion cache hit will be write through, so cmstatus as per bresp
      // if(txn.isCacheHit)begin
      //   if(exclusive_flg && txn.isNcWr)begin
      //     if(txn.cmd_req_pkt.smi_es)begin
      //       if(txn.dtw_rsp_pkt.smi_cmstatus[0] !== 1'b0) begin
      //         `uvm_error("<%=obj.BlockId%>:processDtwRsp",$sformatf("Exp smi_cmstatus: 1'b0 in DTWrsp due To cacheHit for Exclusive NcWr, Actual smi_cmstatus: 'b%0b",txn.dtw_rsp_pkt.smi_cmstatus))
      //       end
      //     end
      //   end
      // end
      <% } %>
      if((txn.smi_vz) && !(txn.isDtwMrgMrd))begin
        <% if (obj.useCmc) { %>
        // TODO: CONC-4437, need to confirm, in case of atomic txn, smi_vz signal is not significant
        if(txn.sp_txn && !txn.sp_seen_write_chnl) begin
            txn.print_entry();
           `uvm_error("<%=obj.BlockId%>:processDtwRsp","Dtw_rsp sent for the SP txn without sending data on SP wr data channel for system Viz")
        end
        <% } %>

        if(txn.AXI_write_resp_expd && !txn.AXI_write_resp_recd) begin
          `uvm_info("<%=obj.BlockId%>:processDtwRsp", $sformatf("start printing"), UVM_MEDIUM)
          txn.print_entry();
          `uvm_info("<%=obj.BlockId%>:processDtwRsp", $sformatf("End printing"), UVM_MEDIUM)
          `uvm_error("<%=obj.BlockId%>:processDtwRsp","Dtw_rsp sent without receiving AXI_write_resp_recd for system Viz")
        end
        if((exmon_size > 0) && (txn.isNcWr == 1)) begin
          smi_cmstatus_t    m_smi_cmstatus;
          `uvm_info("<%=obj.BlockId%>:processDtwRsp", $sformatf("DEBUG cmd_req %1p",txn.cmd_req_pkt), UVM_DEBUG)
          `uvm_info("<%=obj.BlockId%>:processDtwRsp", $sformatf("DEBUG dtw_req_pkt %1p",txn.dtw_req_pkt), UVM_DEBUG)
          `uvm_info("<%=obj.BlockId%>:processDtwRsp", $sformatf("DEBUG dtw_rsp_pkt %1p",dtw_rsp_pkt), UVM_DEBUG)

          if(txn.cmd_req_pkt.smi_es == 1) begin
            //#Check.DMI.ExMon.ExFailEarly
            if (txn.m_exmon_status == EX_FAIL) begin

              m_smi_cmstatus = 8'b0000_0000;
            end
            //#Check.DMI.ExMon.ExPassLate
            else if (txn.m_exmon_status == EX_PASS) begin
               //EX Satus = Pass // Native = SLVERR or Native = DECERR

              if(txn.AXI_write_resp_recd) begin
                if ((txn.axi_write_resp_pkt.bresp == SLVERR) || (txn.axi_write_resp_pkt.bresp == DECERR)) begin
                   m_smi_cmstatus = 8'b10000000 | ((txn.axi_write_resp_pkt.bresp == SLVERR)?3'b011:3'b100); 

                end
                //EX Satus = Pass // Native = OKAY
                else begin
                
                  m_smi_cmstatus = 8'b0000_0001;
                end
              end else if(txn.AXI_write_resp_expd && !txn.AXI_write_resp_recd)begin
                `uvm_error("<%=obj.BlockId%>:processDtwRsp Exmon",$sformatf("DtwRsp received before receiving the response from the Native interface for Exclusive store with %s status ",txn.m_exmon_status.name()))
              end
            end
            else  begin
              `uvm_error($sformatf("%m"), $sformatf("Exlusive Monitor status Unknowen for exclusive NC Write :  Exmon_status = %s",txn.m_exmon_status.name()))
            end
            if(m_smi_cmstatus != dtw_rsp_pkt.smi_cmstatus) begin
              `uvm_error("<%=obj.BlockId%>:processDtwRsp",$sformatf("Exclusive Monitor Enabled : Exclusive store : Exp smi_cmstatus: 'b%0b in DTWrsp, Actual smi_cmstatus: 'b%0b",m_smi_cmstatus,dtw_rsp_pkt.smi_cmstatus))
            end
          end else begin  //Non-exclusive NC Store
            if(txn.AXI_write_resp_expd && txn.AXI_write_resp_recd) begin
              if(txn.axi_write_resp_pkt.bresp === 0 && dtw_rsp_pkt.smi_cmstatus[0] !== 1'b0) begin
                 `uvm_error("<%=obj.BlockId%>:processDtwRsp",$sformatf("Exclusive Monitor Enabled : Non-Exclusive store : Exp smi_cmstatus: 1'b0 in DTWrsp due bresp fo NcWr, Actual smi_cmstatus: 'b%0b and bresp = 'b%0b",dtw_rsp_pkt.smi_cmstatus,txn.axi_write_resp_pkt.bresp))
              end
              //#Cover.DMI.Concerto.v3.0.DtwrRspspCmstatus
              if(txn.axi_write_resp_pkt.bresp === 2 && dtw_rsp_pkt.smi_cmstatus !== 8'b1000_0011) begin
                `uvm_error("<%=obj.BlockId%>:processDtwRsp",$sformatf("Exclusive Monitor Enabled : Non-Exclusive store : Exp smi_cmstatus: 8'b1000_0011 in DTWrsp due to SLVERR in bresp for non EWA, Actual smi_cmstatus: 'b%0b and bresp = 'b%0b",dtw_rsp_pkt.smi_cmstatus,txn.axi_write_resp_pkt.bresp))
              end
              else if(txn.axi_write_resp_pkt.bresp === 3 && dtw_rsp_pkt.smi_cmstatus !== 8'b1000_0100) begin
                `uvm_error("<%=obj.BlockId%>:processDtwRsp",$sformatf("Exclusive Monitor Enabled : Non-Exclusive store : Exp smi_cmstatus: 8'b1000_0100 in DTWrsp due to DECERR in bresp for non EWA, Actual smi_cmstatus: 'b%0b and bresp = 'b%0b",dtw_rsp_pkt.smi_cmstatus,txn.axi_write_resp_pkt.bresp))        
              end
            end
          end 
        end
        else begin
          if(txn.AXI_write_resp_expd && txn.AXI_write_resp_recd) begin
            //#Check.DMI.Concerto.v3.0.brespErr
            if(exclusive_flg && txn.axi_write_addr_pkt.awlock)begin
              if(txn.axi_write_resp_pkt.bresp === 0 && txn.dtw_rsp_pkt.smi_cmstatus[0] !== 1'b0) begin
                `uvm_error("<%=obj.BlockId%>:processDtwRsp",$sformatf("Exp smi_cmstatus: 1'b0 in DTWrsp due bresp for Exclusive NcWr, Actual smi_cmstatus: 'b%0b and bresp = 'b%0b",txn.dtw_rsp_pkt.smi_cmstatus,txn.axi_write_resp_pkt.bresp))
              end
              if(txn.axi_write_resp_pkt.bresp === 1 && txn.dtw_rsp_pkt.smi_cmstatus[0] !== 1'b1) begin
                `uvm_error("<%=obj.BlockId%>:processDtwRsp",$sformatf("Exp smi_cmstatus: 1'b1 in DTWrsp due bresp for Exclusive NcWr, Actual smi_cmstatus: 'b%0b and bresp = 'b%0b",txn.dtw_rsp_pkt.smi_cmstatus,txn.axi_write_resp_pkt.bresp))
              end
            end
            //#Cover.DMI.Concerto.v3.0.DtwrRspspCmstatus
            if(txn.axi_write_resp_pkt.bresp === 2 && txn.dtw_rsp_pkt.smi_cmstatus !== 8'b1000_0011) begin
              `uvm_error("<%=obj.BlockId%>:processDtwRsp",$sformatf("Exp smi_cmstatus: 8'b1000_0011 in DTWrsp due to SLVERR in bresp for non EWA, Actual smi_cmstatus: 'b%0b and bresp = 'b%0b",txn.dtw_rsp_pkt.smi_cmstatus,txn.axi_write_resp_pkt.bresp))
            end
            else if(txn.axi_write_resp_pkt.bresp === 3 && txn.dtw_rsp_pkt.smi_cmstatus !== 8'b1000_0100) begin
              `uvm_error("<%=obj.BlockId%>:processDtwRsp",$sformatf("Exp smi_cmstatus: 8'b1000_0100 in DTWrsp due to DECERR in bresp for non EWA, Actual smi_cmstatus: 'b%0b and bresp = 'b%0b",txn.dtw_rsp_pkt.smi_cmstatus,txn.axi_write_resp_pkt.bresp))
            end
          end
        end
      end
     end
     if(tmp_q.size == 1)begin
       if(txn.wrOutstanding == 0) begin
         `uvm_info("DMI_SCB", $psprintf("DMI_UID:%0d: DTW_RSP: %s", txn.txn_id, txn.dtw_rsp_pkt.convert2string()), UVM_LOW);
         updateWttentry(txn,tmp_q[0]);
       end
       else begin
         if(txn.dtw_req_pkt.smi_msg_type == DTW_NO_DATA) begin
           txn.wrOutstanding = 0;
           `uvm_info("DMI_SCB", $psprintf("DMI_UID:%0d: DTW_RSP: %s", txn.txn_id, txn.dtw_rsp_pkt.convert2string()), UVM_LOW);
           updateWttentry(txn,tmp_q[0]);
         end
       end
     end
     else begin
         `uvm_info("DMI_SCB", $psprintf("DMI_UID:%0d: DTW_RSP: %s", txn.txn_id, txn.dtw_rsp_pkt.convert2string()), UVM_LOW);
         updateRttentry(txn,tmp_q1[0]);
     end
   end
endfunction //processDtwRsp///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

function void dmi_scoreboard::processDtwDbgReqMsg(smi_seq_item dtw_dbg_req_pkt);
  int tmp_q[$];

  `uvm_info("<%=obj.BlockId%>:processDtwDbgReq", $sformatf("%1p",dtw_dbg_req_pkt), UVM_MEDIUM)
  
  tmp_q = dtw_dbg_req_q.find_index with ((item.smi_msg_id == dtw_dbg_req_pkt.smi_msg_id));

  if(tmp_q.size()) `uvm_error("<%=obj.BlockId%>:processDtwDbgReq","smi_msg_id has to be unique")

  if(dtw_dbg_req_pkt.smi_rl != 1'b1) `uvm_error("<%=obj.BlockId%>:processDtwDbgReq","smi_rl should have value 1'b1")

  if(dtw_dbg_req_pkt.smi_cmstatus != 1'b0) `uvm_error("<%=obj.BlockId%>:processDtwDbgReq","smi_cmstatus should have value 1'b0") 

  if(dtw_dbg_req_pkt.smi_tm != 1'b0) `uvm_error("<%=obj.BlockId%>:processDtwDbgReq","smi_tm should have value 1'b0")

  dtw_dbg_req_q.push_back(dtw_dbg_req_pkt);

endfunction : processDtwDbgReqMsg////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

function void dmi_scoreboard::processDtwDbgRspMsg(smi_seq_item dtw_dbg_rsp_pkt);
    int tmp_q[$];

    `uvm_info("<%obj.BlockId%>:processDtwDbgRsp", $sformatf("%1p",dtw_dbg_rsp_pkt), UVM_MEDIUM)

   tmp_q = dtw_dbg_req_q.find_index with ((item.smi_msg_id == dtw_dbg_rsp_pkt.smi_rmsg_id));
    
    if(tmp_q.size() == 0) begin
        `uvm_error("<%obj.BlockId%>:processDtwDbgRsp", "there are no matching dtwdbgreq")
    end
    else if(tmp_q.size() >1) begin
        `uvm_error("<%obj.BlockId%>:processDtwDbgRsp", "there more than one matching dtwdbgreq")
    end
    else begin
        if(dtw_dbg_rsp_pkt.smi_rl != 1'b0) `uvm_error("<%obj.BlockId%>:processDtwDbgRsp","smi_rl value should be 1'b0")
        dtw_dbg_req_q.delete(tmp_q[0]);
    end

endfunction : processDtwDbgRspMsg////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

function void dmi_scoreboard::updateWttOnIntRbRelease(int idx, smi_seq_item m_pkt, string label, int line);
  string line_s, func_line;
  line_s.itoa(line);
  func_line = $sformatf("%0s,(%0s)",label,line_s);
  wtt_q[idx].RBRL_req_recd       = 1;
  //#Check.DMI.Concerto.v3.6.EnforceRelease
  wtt_q[idx].RBRL_rsp_expd       = 1;
  wtt_q[idx].t_rbrlreq           = $time;
  <% if (obj.useCmc) { %>
  wtt_q[idx].sp_txn              = 0;
  <% } %>
  wtt_q[idx].rbrl_req_pkt        = m_pkt;
  wtt_q[idx].rbrl_msg_id         = m_pkt.smi_msg_id;
  wtt_q[idx].smi_qos             = m_pkt.smi_qos;
  wtt_q[idx].smi_ndp_aux_aw      = m_pkt.smi_ndp_aux;
  wtt_q[idx].Rb_src_ncore_unit_id    = m_pkt.smi_src_ncore_unit_id; 
  wtt_q[idx].DTW_req_expd        = 0;
  wtt_q[idx].DTW_rsp_expd        = 0;
  wtt_q[idx].lookupExpd          = 0;
  wtt_q[idx].wrOutstanding       = 0;
  wtt_q[idx].AXI_write_addr_expd = 0;
  wtt_q[idx].AXI_write_addr_expd = 0;
  wtt_q[idx].AXI_write_data_expd = 0;
  wtt_q[idx].AXI_write_resp_expd = 0;
  `uvm_info("DMI_SCB", $sformatf("DMI_UID:%0d: RBREQ_IntRls: %s",wtt_q[idx].txn_id,m_pkt.convert2string()), UVM_MEDIUM)

endfunction/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

function void dmi_scoreboard::processRbReq(smi_seq_item rb_req_pkt);
  int tmp_q[$], tmp_q1[$], tmp_q2[$],tmp_q3[$],tmp_q4[$];
  dmi_scb_txn  m_dtw_entry, txn;
  bit exp_release, curr_gid, prev_gid;
  numCmd++;
  numRbrsReq++;
  tmp_q = {};
  tmp_q = wtt_q.find_index with ((item.smi_rbid  === rb_req_pkt.smi_rbid) &&                            
                                  (item.DTW_req_recd == 1) &&
                                  (item.RB_req_expd == 1) &&
                                  (item.RB_req_recd == 0));
  `uvm_info("<%=obj.BlockId%>:processRbReq", $sformatf("%p",rb_req_pkt), UVM_DEBUG)

  //#Check.DMI.Concerto.v3.0.RbReqRL
  if(rb_req_pkt.smi_rl != 'b10) begin
    `uvm_error("<%=obj.BlockId%>:processRbReq", $sformatf("RbReq should have RL 10. Got %0b",rb_req_pkt.smi_rl))
  end

  tmp_q1 = rtt_q.find_index with (item.isMrd && 
                                 (cl_aligned((item.cache_addr)) == cl_aligned(rb_req_pkt.smi_addr)) &&
                                 (item.security  == rb_req_pkt.smi_ns) && 
                                 (item.DTR_req_expd == 1 && item.DTR_req_recd == 0) &&
                                 !item.wrOutstandingFlag);
  //if(tmp_q1.size()>0)begin
  //  `uvm_info("<%=obj.BlockId%>:processRbReq", $sformatf("%1p",rb_req_pkt), UVM_LOW)
  //  `uvm_error("<%=obj.BlockId%>:processRbReq", $sformatf("wr addr :%0x and security :%0b matching Mrd Inflight Tb Error",rb_req_pkt.smi_addr,rb_req_pkt.smi_ns))
  //end
                                  
  tmp_q4 = {};
  tmp_q4 = wtt_q.find_index with ((item.smi_rbid  === rb_req_pkt.smi_rbid) &&                            
                                  (item.RBU_req_expd == 1) &&
                                  (item.RBU_req_recd == 0));
  //Find all possible RB matches, Release and AIU Writes
  tmp_q3 = {};
  tmp_q3 = wtt_q.find_index with ((item.smi_rbid[WSMIRBID-2:0] === rb_req_pkt.smi_rbid[WSMIRBID-2:0]) &&
                                  ((item.RB_req_expd && !item.RB_req_recd)||
                                   (item.DTW_req_expd && !item.DTW_req_recd))
                                 );
   
  if(tmp_q3.size() == 2) begin 
    //Entry gets created if DTW arrives earlier for 2nd request, if not create a new entry and then process a release as well
    curr_gid =  wtt_q[tmp_q3[0]].smi_rbid[WSMIRBID-1];
    prev_gid =  wtt_q[tmp_q3[1]].smi_rbid[WSMIRBID-1];
    if(curr_gid == prev_gid) begin
      //#Check.DMI.Concerto.v3.6.RBAliveforWrites
      `uvm_error("<%=obj.BlockId%>:processRbReq", $sformatf("Duplicate RBID entry %0h", wtt_q[tmp_q3[0]].smi_rbid))
    end 
    else begin
      exp_release = 1;
    end
  end
  else if(tmp_q3.size() == 1 && tmp_q.size() == 0) begin 
    //Pure release scenario, no DTWs received 
    curr_gid =  rb_req_pkt.smi_rbid[WSMIRBID-1];
    prev_gid =  wtt_q[tmp_q3[0]].smi_rbid[WSMIRBID-1];
    if(curr_gid == prev_gid) begin
      //#Check.DMI.Concerto.v3.6.RBAliveforWrites
      `uvm_error("<%=obj.BlockId%>:processRbReq", $sformatf("Duplicate RBID entry %0h", wtt_q[tmp_q3[0]].smi_rbid))
     end 
     else begin
      //Block setting release for cases when an early DTW created a WTT entry
      if(!(wtt_q[tmp_q3[0]].DTW_req_recd && !wtt_q[tmp_q3[0]].RB_req_recd)) begin
        exp_release = 1;
       end
     end
  end
  else if(tmp_q3.size() > 2)begin
    `uvm_error("<%=obj.BlockId%>:processRbReq", $sformatf("Duplicate RBID %0h entries %0p", rb_req_pkt.smi_rbid, tmp_q3))
  end

  tmp_q4 = {};
  tmp_q4 = wtt_q.find_index with ((item.smi_rbid  === rb_req_pkt.smi_rbid) &&                            
                                  (item.RB_req_expd == 1) &&
                                  (item.RB_req_recd == 1) &&
                                  (item.RB_rsp_expd == 1) &&
                                  (item.RB_rsp_recd == 0));

  `uvm_info("<%=obj.BlockId%>:processRbReq",$sformatf("tmp_q :%0d tmp_q2:%0d tmp_q3 :%0d tmp_q4 :%0d | Expect Release: %0b",tmp_q.size,tmp_q2.size,tmp_q3.size,tmp_q4.size, exp_release),UVM_MEDIUM);
  //#Check.DMI.Concerto.v3.6.UniqueRBID
  if(tmp_q4.size()>0)begin
      `uvm_info("<%=obj.BlockId%>:processRbReq", $sformatf("%1p",rb_req_pkt), UVM_LOW)
       foreach(tmp_q4[i])begin
        wtt_q[tmp_q4[i]].print_entry();
       end
      `uvm_error("<%=obj.BlockId%>:processRbReq", $sformatf("smi_rbid :%0x matching Rbid Inflight CCMP protocol violation",rb_req_pkt.smi_rbid))
  end
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  // Commented as per CONC-6162, RBreq can collide with Mrd,but DtwReq will not receive for this Rbreq, Rbreq(release will be received
  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  //#Check.DMI.Concerto.v3.0.DtwMrdMrdinflight
  // if(tmp_q1.size()>0 && rb_req_pkt.smi_rtype)begin
  //    `uvm_info("<%=obj.BlockId%>:processRbReq", $sformatf("%1p",rb_req_pkt), UVM_LOW)
  //    `uvm_error("<%=obj.BlockId%>:processRbReq", $sformatf("wr addr :%0x and security :%0b matching Mrd Inflight CCMP protocol violation",rb_req_pkt.smi_addr,rb_req_pkt.smi_ns))
  // end

  if(tmp_q3.size() == 1 && exp_release)begin
    //Received an RbReq. Second request releases the previous one, mark released
    if(wtt_q[tmp_q3[0]].DTW_req_recd && wtt_q[tmp_q3[0]].RB_req_recd && (wtt_q[tmp_q3[0]].smi_rbid[WSMIRBID-1] != rb_req_pkt.smi_rbid[WSMIRBID-1])) begin
      //#Check.DMI.Concerto.v3.6.RBAliveforRelease
      `uvm_error("<%=obj.BlockId%>:processRbReq", $sformatf("Releasing RB:%0h but intervention DTW was marked received",rb_req_pkt.smi_rbid[WSMIRBID-1:0]))
    end
    updateWttOnIntRbRelease(tmp_q3[0], rb_req_pkt, "<%=obj.BlockId%>:processRbReq", `__LINE__);
    numRbrlReq++;
    numRbrsReq--;
    //Second request could also be a reservation for a DTW or another release condition
    m_dtw_entry = new();
    m_dtw_entry.rb_req_pkt  = rb_req_pkt; 
    m_dtw_entry.cache_addr  = rb_req_pkt.smi_addr; 
    m_dtw_entry.security    = rb_req_pkt.smi_ns; 
    m_dtw_entry.privileged  = rb_req_pkt.smi_pr; 
    m_dtw_entry.isMW        = rb_req_pkt.smi_mw; 
    <% if(obj.useCmc && obj.DmiInfo[obj.Id].ccpParams.useScratchpad){%>
    m_dtw_entry.cache_index   = ncoreConfigInfo::get_set_index(rb_req_pkt.smi_addr,<%=obj.DmiInfo[obj.Id].FUnitId%>); 
    m_dtw_entry.lower_sp_addr = lower_sp_addr;
    m_dtw_entry.upper_sp_addr = upper_sp_addr;
    m_dtw_entry.sp_enabled    = sp_enabled;
    m_dtw_entry.sp_ns         = sp_ns;
    m_dtw_entry.rsvd_ways     = (2**$clog2(sp_ways)) - 1;
    m_dtw_entry.cache_addr_i  = ncoreConfigInfo::gen_spad_intrlv_rmvd_addr(m_dtw_entry.cache_addr,<%=obj.DmiInfo[obj.Id].nUnitId%>);
    m_dtw_entry.CalSPProperty();
    if(m_dtw_entry.sp_txn || !lookup_en ) begin 
       m_dtw_entry.lookupExpd            = 0;
       m_dtw_entry.AXI_write_addr_expd   = 0;
       m_dtw_entry.AXI_write_data_expd   = 0;
       m_dtw_entry.AXI_write_resp_expd   = 0;
    end
    <% } %>
    m_dtw_entry.smi_rbid     = rb_req_pkt.smi_rbid; 
    m_dtw_entry.smi_ac       = rb_req_pkt.smi_ac; 
    m_dtw_entry.smi_vz       = rb_req_pkt.smi_vz; 
    m_dtw_entry.smi_ca       = rb_req_pkt.smi_ca; 
    m_dtw_entry.smi_qos      = rb_req_pkt.smi_qos;
    m_dtw_entry.exp_smi_tm   = rb_req_pkt.smi_tm;
    m_dtw_entry.smi_ndp_aux_aw      = rb_req_pkt.smi_ndp_aux;
    m_dtw_entry.rb_msg_id    = rb_req_pkt.smi_msg_id; 
    m_dtw_entry.Rb_src_ncore_unit_id    = rb_req_pkt.smi_src_ncore_unit_id; 
    m_dtw_entry.smi_size     = rb_req_pkt.smi_size; 
    m_dtw_entry.isCoh        = 1;
    m_dtw_entry.RB_req_expd  = 1;
    m_dtw_entry.RB_rsp_expd  = 1;
    m_dtw_entry.RB_req_recd  = 1;
    if(!(tmp_q4.size() > 0))begin
       m_dtw_entry.DTW_req_expd = 1;
       m_dtw_entry.DTW_rsp_expd = 1;
    end
    m_dtw_entry.t_creation   = $time;
    wtt_q.push_back(m_dtw_entry);
    `uvm_info("DMI_SCB", $sformatf("DMI_UID:%0d: RB_REQ: %s",m_dtw_entry.txn_id,rb_req_pkt.convert2string()), UVM_MEDIUM)

  end
  else if(tmp_q3.size() == 2 && exp_release) begin
    //There are two matches, 1 can be of dtw and 1 release
    //Both can be release
    //This happens when DTW arrived early, so do not repopulate but update
    //Ensure multiple DTWs are expected. Possible it got created because of an early DTW
    //print_wtt_q();
    //TODO add check
    //if(wtt_q[tmp_q3[0]].DTW_req_recd &&
    //   (!(!wtt_q[tmp_q[0]].dtw_req_pkt.smi_prim && wtt_q[tmp_q[1]].dtw_req_pkt.smi_prim && rb_req_pkt.smi_mw))) begin
    //    `uvm_info("<%=obj.BlockId%>:processRbReq", $sformatf("%0p",rb_req_pkt), UVM_MEDIUM)
    //    `uvm_error("<%=obj.BlockId%>:processRbReq", "SMI msg ID && smi_targ_ncore_unit_id matching  multiple outstanding requests")    
    //end
     
    foreach(tmp_q3[itr]) begin
      if(!wtt_q[tmp_q3[itr]].DTW_req_recd && (wtt_q[tmp_q3[itr]].smi_rbid[WSMIRBID-1] != rb_req_pkt.smi_rbid[WSMIRBID-1])) begin //If the GID flipped
        //Release the packet that hasn't received a DTW (Internal Release)
        //#Check.DMI.Concerto.v3.6.RBAliveforRelease
        updateWttOnIntRbRelease(tmp_q3[itr], rb_req_pkt, "<%=obj.BlockId%>:processRbReq", `__LINE__);
        numRbrlReq++;
        numRbrsReq--;
      end
      else begin
        //Update the packet which received a DTW with the new RBReq
        foreach(tmp_q1[i]) begin
         if(rtt_q[tmp_q3[itr]].t_dtwreq  < rtt_q[tmp_q1[i]].t_mrdreq ) begin
           `uvm_info("<%=obj.BlockId%>:processRbReq", $sformatf("Setting write outstanding flag on addr:%0h", rtt_q[tmp_q[itr]].cache_addr),UVM_MEDIUM)
           rtt_q[tmp_q1[i]].wrOutstandingFlag = 1;
           rtt_q[tmp_q1[i]].wrOutstandingcnt = 1;
         end
        end
        updateWttOnRbReq({tmp_q3[itr]}, rb_req_pkt,  "<%=obj.BlockId%>:processRbReq", `__LINE__);
      end
    end
  end
  else if (tmp_q.size == 0) begin
    `uvm_info("<%=obj.BlockId%>:processRbReq", "None of the dtw matching rbreq rbid",UVM_MEDIUM)
     m_dtw_entry = new();
     m_dtw_entry.rb_req_pkt  = rb_req_pkt; 
     m_dtw_entry.cache_addr  = rb_req_pkt.smi_addr; 
     m_dtw_entry.security    = rb_req_pkt.smi_ns; 
     m_dtw_entry.privileged  = rb_req_pkt.smi_pr; 
     m_dtw_entry.isMW        = rb_req_pkt.smi_mw; 
     <% if(obj.useCmc && obj.DmiInfo[obj.Id].ccpParams.useScratchpad){%>
     m_dtw_entry.cache_index   = ncoreConfigInfo::get_set_index(rb_req_pkt.smi_addr,<%=obj.DmiInfo[obj.Id].FUnitId%>); 
     m_dtw_entry.lower_sp_addr = lower_sp_addr;
     m_dtw_entry.upper_sp_addr = upper_sp_addr;
     m_dtw_entry.sp_enabled    = sp_enabled;
     m_dtw_entry.sp_ns         = sp_ns;
     m_dtw_entry.rsvd_ways     = (2**$clog2(sp_ways)) - 1;
     m_dtw_entry.cache_addr_i  = ncoreConfigInfo::gen_spad_intrlv_rmvd_addr(m_dtw_entry.cache_addr,<%=obj.DmiInfo[obj.Id].nUnitId%>);
     m_dtw_entry.CalSPProperty();
     if(m_dtw_entry.sp_txn || !lookup_en ) begin 
        m_dtw_entry.lookupExpd            = 0;
        m_dtw_entry.AXI_write_addr_expd   = 0;
        m_dtw_entry.AXI_write_data_expd   = 0;
        m_dtw_entry.AXI_write_resp_expd   = 0;
     end
     <% } %>
     m_dtw_entry.smi_rbid     = rb_req_pkt.smi_rbid; 
     m_dtw_entry.smi_ac       = rb_req_pkt.smi_ac; 
     m_dtw_entry.smi_vz       = rb_req_pkt.smi_vz; 
     m_dtw_entry.smi_ca       = rb_req_pkt.smi_ca; 
     m_dtw_entry.smi_qos      = rb_req_pkt.smi_qos;
     m_dtw_entry.exp_smi_tm   = rb_req_pkt.smi_tm;
     m_dtw_entry.smi_ndp_aux_aw      = rb_req_pkt.smi_ndp_aux;
     m_dtw_entry.rb_msg_id    = rb_req_pkt.smi_msg_id; 
     m_dtw_entry.Rb_src_ncore_unit_id    = rb_req_pkt.smi_src_ncore_unit_id; 
     m_dtw_entry.smi_size     = rb_req_pkt.smi_size; 
     m_dtw_entry.isCoh        = 1;
     m_dtw_entry.RB_req_expd  = 1;
     m_dtw_entry.RB_rsp_expd  = 1;
     m_dtw_entry.RB_req_recd  = 1;
     if(!(tmp_q4.size() > 0))begin
       m_dtw_entry.DTW_req_expd = 1;
       m_dtw_entry.DTW_rsp_expd = 1;
     end
     m_dtw_entry.t_creation   = $time;
     wtt_q.push_back(m_dtw_entry);
     `uvm_info("DMI_SCB", $sformatf("DMI_UID:%0d: RB_REQ: %s",m_dtw_entry.txn_id,rb_req_pkt.convert2string()), UVM_MEDIUM)
     //numRbrsReq++;
     /// ->smi_raise;
  end
  //#Check.DMI.Concerto.v3.0.DceunitId
  else if (tmp_q.size > 0) begin
    if(tmp_q.size>2)begin
    `uvm_info("<%=obj.BlockId%>:processRbReq", $sformatf("%1p",rb_req_pkt), UVM_MEDIUM)
    `uvm_error("<%=obj.BlockId%>:processRbReq", "SMI msg ID && smi_targ_ncore_unit_id matching  multiple outstanding requests")
    end
    if(tmp_q.size == 2)begin
      if(!(!wtt_q[tmp_q[0]].dtw_req_pkt.smi_prim && wtt_q[tmp_q[1]].dtw_req_pkt.smi_prim && rb_req_pkt.smi_mw))begin
      `uvm_info("<%=obj.BlockId%>:processRbReq", $sformatf("%1p",rb_req_pkt), UVM_MEDIUM)
      `uvm_error("<%=obj.BlockId%>:processRbReq", "SMI msg ID && smi_targ_ncore_unit_id matching  multiple outstanding requests")
      end
    end
    //#Check.DMI.Concerto.v3.0.MWdtwSecondarySize
    ////////////////////////////////////////////////////////////////////////////
    //Commented as per JIRA-6182, rbReq will carry only primary dtw information
    ///////////////////////////////////////////////////////////////////////////
    /*if(wtt_q[tmp_q[i]].DTW_req_recd)begin
       if(!wtt_q[tmp_q[i]].dtw_req_pkt.smi_prim && !rb_req_pkt.smi_mw)begin
         if(2**rb_req_pkt.smi_size != SYS_nSysCacheline)begin
            wtt_q[tmp_q[i]].print_entry();
           `uvm_error("<%=obj.BlockId%>:processRbReq",$sformatf(" if RbReq MW = 0, and primary bit = 0 ,then size of Dtw data will be coherency granule"));
         end
       end
      end 
    */
    updateWttOnRbReq(tmp_q, rb_req_pkt, "<%=obj.BlockId%>:processRbReq", `__LINE__);
  end
  else `uvm_error("<%=obj.BlockId%>:processRbReq", "Didn't match any scenarios")
endfunction //processRbReq///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

function void dmi_scoreboard::updateWttOnRbReq(int idx_q[$], smi_seq_item m_pkt, string label, int line);
  string line_s, func_line;
  line_s.itoa(line);
  func_line = $sformatf("%0s,(%0s)",label,line_s);
  foreach(idx_q[i]) begin
    wtt_q[idx_q[i]].RB_rsp_expd  = 1;
    wtt_q[idx_q[i]].RB_req_recd  = 1;
    wtt_q[idx_q[i]].isCoh        = 1;
    wtt_q[idx_q[i]].rb_req_pkt   = m_pkt;
    wtt_q[idx_q[i]].cache_addr   = m_pkt.smi_addr; 

    if(idx_q.size() == 2 && i == 0)begin
      wtt_q[idx_q[i]].smi_size    = 6;
    end
    else begin
      wtt_q[idx_q[i]].smi_size    = m_pkt.smi_size;
    end
    
    if(wtt_q[idx_q[i]].exp_smi_tm != m_pkt.smi_tm) begin
       `uvm_error(func_line,$sformatf("smi_tm not matching. Expd %0b Actual %0b", wtt_q[idx_q[i]].exp_smi_tm, m_pkt.smi_tm))
    end

    if(i == 0)begin
      if(m_pkt.smi_mw && !wtt_q[idx_q[i]].dtw_req_pkt.smi_prim)begin 
       wtt_q[idx_q[i]].DTW2nd_req_expd = 1;
       wtt_q[idx_q[i]].smi_size        = 6;
      end
    end
    if(wtt_q[idx_q[i]].dtw_req_pkt.smi_dp_last)begin
      `uvm_info(func_line, $sformatf("Calling rearrangedtwdata to rearrange the dtw itr :%0d ",i),UVM_MEDIUM)
      rearrangedtwdata(wtt_q[idx_q[i]]);
    end
    <%if (obj.wSecurityAttribute > 0) { %>
    wtt_q[idx_q[i]].security      = m_pkt.smi_ns; 
    <% } %>
    wtt_q[idx_q[i]].privileged    = m_pkt.smi_pr; 
    wtt_q[idx_q[i]].isMW          = m_pkt.smi_mw; 
    <% if(obj.useCmc && obj.DmiInfo[obj.Id].ccpParams.useScratchpad){%>
    wtt_q[idx_q[i]].cache_index   = ncoreConfigInfo::get_set_index(m_pkt.smi_addr,<%=obj.DmiInfo[obj.Id].FUnitId%>);; 
    wtt_q[idx_q[i]].lower_sp_addr = lower_sp_addr;
    wtt_q[idx_q[i]].upper_sp_addr = upper_sp_addr;
    wtt_q[idx_q[i]].sp_enabled    = sp_enabled;
    wtt_q[idx_q[i]].sp_ns         = sp_ns;
    wtt_q[idx_q[i]].rsvd_ways     = (2**$clog2(sp_ways)) - 1;
    wtt_q[idx_q[i]].cache_addr_i  = ncoreConfigInfo::gen_spad_intrlv_rmvd_addr(m_pkt.smi_addr,<%=obj.DmiInfo[obj.Id].nUnitId%>);
    wtt_q[idx_q[i]].CalSPProperty();

    if(wtt_q[idx_q[i]].sp_txn) begin 
      wtt_q[idx_q[i]].AXI_write_addr_expd   = 0;
      wtt_q[idx_q[i]].AXI_write_data_expd   = 0;
      wtt_q[idx_q[i]].AXI_write_resp_expd   = 0;
    end
  
    // From the micro-arch, ==DTW_NO_DATA and CLN to Scratchpad are always dropped: CONC-4437==
    // #Check.DMI.Concerto.v3.0.DropDtwNoDataAndDtwCln
    if(wtt_q[idx_q[i]].sp_txn && (wtt_q[idx_q[i]].dtw_req_pkt.smi_msg_type inside {DTW_NO_DATA, DTW_DATA_CLN})) begin
        `uvm_info(func_line, $psprintf("Got DTW packet with DTW_DATA_CLN msg for a SP txn, so dropping this data",
                                              " and this txn is not supposed to go on SP control channel now" ),UVM_MEDIUM)
        wtt_q[idx_q[i]].sp_seen_ctrl_chnl  = 1;
        wtt_q[idx_q[i]].sp_seen_write_chnl = 1;
    end
    <%  } %>
    <% if(!obj.useCmc) { %>
    if(isdtwmrgmrd(wtt_q[idx_q[i]].dtw_req_pkt.smi_msg_type) && !wtt_q[idx_q[i]].isRttCreated)begin
      processMrdReq(wtt_q[idx_q[i]].rb_req_pkt,1,wtt_q[idx_q[i]]);
      wtt_q[idx_q[i]].isRttCreated = 1;
      numDtwMrgMrdTxns++;
      wtt_q[idx_q[i]].print_entry();
    end
    <%  } else { %>
    if(!lookup_en)begin
      if(isdtwmrgmrd(wtt_q[idx_q[i]].dtw_req_pkt.smi_msg_type) && !wtt_q[idx_q[i]].isRttCreated)begin
        processMrdReq(wtt_q[idx_q[i]].rb_req_pkt,1,wtt_q[idx_q[i]]);
        wtt_q[idx_q[i]].isRttCreated = 1;
        numDtwMrgMrdTxns++;
        wtt_q[idx_q[i]].print_entry();
     end
    end
    <%  } %>
    <% if(obj.useCmc) { %>
    wtt_q[idx_q[i]].cache_index = ncoreConfigInfo::get_set_index(m_pkt.smi_addr,<%=obj.DmiInfo[obj.Id].FUnitId%>);; 
    <%  } %>
    wtt_q[idx_q[i]].smi_ac      = m_pkt.smi_ac; 
    wtt_q[idx_q[i]].smi_vz      = m_pkt.smi_vz; 
    wtt_q[idx_q[i]].smi_ca      = m_pkt.smi_ca; 
    wtt_q[idx_q[i]].smi_qos     = m_pkt.smi_qos; 
    wtt_q[idx_q[i]].smi_ndp_aux_aw      = m_pkt.smi_ndp_aux;
    wtt_q[idx_q[i]].rb_msg_id   = m_pkt.smi_msg_id;
    wtt_q[idx_q[i]].Rb_src_ncore_unit_id    = m_pkt.smi_src_ncore_unit_id; 
    if(i == 1)begin
      wtt_q[idx_q[i]].RB_rsp_expd  = 0;
    end
    else begin
    end
    <% if(obj.useCmc) { %>
    //#Check.DMI.Concerto.v3.6.EnforceCleanWritePropagation
    if(wtt_q[idx_q[i]].dtw_req_pkt.smi_msg_type == DTW_NO_DATA || ((wtt_q[idx_q[i]].dtw_req_pkt.smi_msg_type === DTW_DATA_CLN && !m_pkt.smi_ac) && !WrDataClnPropagateEn) || !lookup_en)begin
      wtt_q[idx_q[i]].lookupExpd  = 0;
    end
    else begin
      // Not required to lookup for a SP txn
      if (!wtt_q[idx_q[i]].sp_txn) wtt_q[idx_q[i]].lookupExpd  = 1;
      else wtt_q[idx_q[i]].lookupExpd  = 0;
    end
    <%  } %>
    wtt_q[idx_q[i]].t_rbreq     = $time;
    //wtt_q[idx_q[i]].print_entry(); //VDEL
    `uvm_info("DMI_SCB", $sformatf("DMI_UID:%0d: RBREQ: %s",wtt_q[idx_q[i]].txn_id,m_pkt.convert2string()), UVM_MEDIUM) 

  end
endfunction//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

function void dmi_scoreboard::processRbRsp(smi_seq_item rb_rsp_pkt);
  int tmp_q[$],tmp_q1[$];
  dmi_scb_txn  txn;
  tmp_q = {};
  tmp_q = wtt_q.find_index with (((item.smi_rbid  == rb_rsp_pkt.smi_rbid) &&                            
                                  (item.Rb_src_ncore_unit_id  == rb_rsp_pkt.smi_targ_ncore_unit_id) &&
                                  (item.RB_req_recd == 1) &&
                                  (item.RB_rsp_expd == 1) &&
                                  (item.RB_rsp_recd == 0)));

  //#Check.DMI.Concerto.v3.0.RbRspRMessageId
  if(tmp_q.size == 0) begin
    `uvm_info("<%=obj.BlockId%>:processRbRsp", $sformatf("%1p",rb_rsp_pkt), UVM_LOW)
    tmp_q = wtt_q.find_index with((item.smi_rbid == rb_rsp_pkt.smi_rbid));
    if(tmp_q.size()>0) begin
      `uvm_info("<%=obj.BlockId%>:processRbRsp", $sformatf("WTTQ match for RBRsp RBID: %0h , wtt_entry:%0p matches:%0d | WTT SRC_ID: %0x  ReqRcvd: %0b RspExpd: %0b RspRcvd: %0b | RbRsp TARG_ID:%0h ",rb_rsp_pkt.smi_rbid, tmp_q, tmp_q.size(), wtt_q[tmp_q[0]].Rb_src_ncore_unit_id,
      wtt_q[tmp_q[0]].RB_req_recd, wtt_q[tmp_q[0]].RB_rsp_expd, wtt_q[tmp_q[0]].RB_rsp_recd, rb_rsp_pkt.smi_targ_ncore_unit_id), UVM_DEBUG)
    end
    `uvm_error("<%=obj.BlockId%>:processRbRsp", $sformatf("No rbId match found for rbrsp not found, rbid: %0x",rb_rsp_pkt.smi_rbid))
  end
  else if (tmp_q.size  == 2 && !(wtt_q[tmp_q[0]].RB_req_recd &&  wtt_q[tmp_q[1]].RBRL_req_recd &&  (wtt_q[tmp_q[0]].rb_req_pkt.smi_rbid == wtt_q[tmp_q[1]].rbrl_req_pkt.smi_rbid))) begin
    ////////////////////////////////////////////////////////////////////////////
    //CONC-6236 RbReq Rs and RbReq Rl for same rbid can reuse smi_msg_id
    ////////////////////////////////////////////////////////////////////////////
    `uvm_info("<%=obj.BlockId%>:processRbRsp", $sformatf("%1p",rb_rsp_pkt), UVM_LOW)
    `uvm_info("<%=obj.BlockId%>:processRbRsp", $sformatf("outstanidng RbreqRS :%0d",tmp_q.size()), UVM_LOW)
    if(tmp_q.size()>0)begin
      foreach(tmp_q[i])begin
        wtt_q[tmp_q[i]].print_entry();
      end
    end
    `uvm_error("<%=obj.BlockId%>:processRbRsp", " Rbsp smi_rbid matching  multiple outstanding rbreq")
  end
  else if (tmp_q.size  > 2) begin
    `uvm_info("<%=obj.BlockId%>:processRbRsp", $sformatf("%1p",rb_rsp_pkt), UVM_LOW)
    `uvm_info("<%=obj.BlockId%>:processRbRsp", $sformatf("Outstanding RbreqRS || RbreqRL :%0d",tmp_q.size()), UVM_LOW)
    if(tmp_q.size()>0)begin
      foreach(tmp_q[i])begin
        wtt_q[tmp_q[i]].print_entry();
      end
    end
    `uvm_error("<%=obj.BlockId%>:processRbRsp", " Rbsp smi_rbid matching  multiple outstanding rbreq")
  end
  else begin
    `uvm_info("<%=obj.BlockId%>:processRbRsp", $sformatf("%1p",rb_rsp_pkt), UVM_MEDIUM)
    if(wtt_q[tmp_q[0]].RB_req_recd &&  !wtt_q[tmp_q[0]].RB_rsp_recd)begin
      txn = wtt_q[tmp_q[0]];
      if(wtt_q[tmp_q[0]].rb_req_pkt.smi_src_ncore_unit_id !== rb_rsp_pkt.smi_targ_ncore_unit_id)begin
        `uvm_error("<%=obj.BlockId%>:processRbRsp", $sformatf("Not matching  targ unit id rb_req_pkt.smi_src_ncore_unit_id :%0x rb_rsp_pkt.smi_targ_ncore_unit_id :%0x",wtt_q[tmp_q[0]].rb_req_pkt.smi_src_ncore_unit_id,rb_rsp_pkt.smi_targ_ncore_unit_id))
      end   
      if(wtt_q[tmp_q[0]].rb_req_pkt.smi_targ_ncore_unit_id !== rb_rsp_pkt.smi_src_ncore_unit_id)begin
        `uvm_error("<%=obj.BlockId%>:processRbRsp", $sformatf("Not matching src unit id rb_req_pkt.smi_targ_ncore_unit_id :%0x rb_rsp_pkt.smi_src_ncore_unit_id :%0x",wtt_q[tmp_q[0]].rb_req_pkt.smi_targ_ncore_unit_id,rb_rsp_pkt.smi_src_ncore_unit_id))
      end   
      wtt_q[tmp_q[0]].RB_rsp_recd = 1;
      wtt_q[tmp_q[0]].rb_rsp_pkt = rb_rsp_pkt;
      wtt_q[tmp_q[0]].t_rbrsrsp = $time;
      if(wtt_q[tmp_q[0]].RBRL_rsp_expd && !wtt_q[tmp_q[0]].RBRL_rsp_recd) begin
        wtt_q[tmp_q[0]].RBRL_rsp_recd = 1;
        wtt_q[tmp_q[0]].t_rbrlrsp = $time;
      end
       `uvm_info("DMI_SCB", $psprintf("DMI_UID:%0d: RB_RSP: %s", txn.txn_id, wtt_q[tmp_q[0]].rb_rsp_pkt.convert2string()), UVM_LOW)
    end
    else begin
      txn = wtt_q[tmp_q[0]];
      if(wtt_q[tmp_q[0]].rbrl_req_pkt.smi_src_ncore_unit_id !== rb_rsp_pkt.smi_targ_ncore_unit_id)begin
        `uvm_error("<%=obj.BlockId%>:processRbRsp", $sformatf("Not matching  targ unit id rbrl_req_pkt.smi_src_ncore_unit_id :%0x rb_rsp_pkt.smi_targ_ncore_unit_id :%0x",wtt_q[tmp_q[0]].rbrl_req_pkt.smi_src_ncore_unit_id,rb_rsp_pkt.smi_targ_ncore_unit_id))
      end   
      if(wtt_q[tmp_q[0]].rbrl_req_pkt.smi_targ_ncore_unit_id !== rb_rsp_pkt.smi_src_ncore_unit_id)begin
        `uvm_error("<%=obj.BlockId%>:processRbRsp", $sformatf("Not matching src unit id rbrl_req_pkt.smi_targ_ncore_unit_id :%0x rb_rsp_pkt.smi_src_ncore_unit_id :%0x",wtt_q[tmp_q[0]].rbrl_req_pkt.smi_targ_ncore_unit_id,rb_rsp_pkt.smi_src_ncore_unit_id))
      end   
      wtt_q[tmp_q[0]].RBRL_rsp_recd = 1;
      wtt_q[tmp_q[0]].rbrl_rsp_pkt = rb_rsp_pkt;
      wtt_q[tmp_q[0]].t_rbrlrsp = $time;
      `uvm_info("DMI_SCB", $psprintf("DMI_UID:%0d: RB_RSP: %s", txn.txn_id, wtt_q[tmp_q[0]].rb_rsp_pkt.convert2string()), UVM_LOW)
    end
    txn.t_rbrsp = $time;
    txn.print_entry();
    <%if (obj.DmiInfo[obj.Id].fnEnableQos) { %>
    if(rb_rsp_pkt.smi_msg_pri != ncoreConfigInfo::qos_mapping(txn.smi_qos))begin
      `uvm_error("<%=obj.BlockId%>:processRbRsp",$sformatf("Priority for smi_qos :%0x Exp :%0x Recd :%0x",txn.smi_qos,ncoreConfigInfo::qos_mapping(txn.smi_qos),rb_rsp_pkt.smi_msg_pri))
    end
    <% } %>
    if(txn.wrOutstanding == 0) begin
      if(tmp_q.size == 1)begin
        updateWttentry(txn,tmp_q[0]);
      end
    //else begin
    //  updateWttentry(txn,tmp_q1[0]);
    //end
    end
  end
endfunction //processRbRsq
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Create Nc cmd entry for new cmd request
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function void dmi_scoreboard::processCmdReq(smi_seq_item  cmd_req_pkt);
  int tmp_q[$],tmp_q1[$],tmp_q2[$],tmp_q3[$];
  dmi_scb_txn  m_cmd_entry;
  m_cmd_entry = new();

  tmp_q  = rtt_q.find_index with ((!item.isCoh) && 
                                  (item.cmd_src_unit_id == cmd_req_pkt.smi_src_ncore_unit_id) && 
                                  (item.cmd_msg_id== cmd_req_pkt.smi_msg_id) && 
                                  (item.CMD_rsp_recd == 0));

  tmp_q1  = wtt_q.find_index with ((!item.isCoh) && 
                                  (item.cmd_src_unit_id == cmd_req_pkt.smi_src_ncore_unit_id) && 
                                  (item.cmd_msg_id== cmd_req_pkt.smi_msg_id) && 
                                  (item.CMD_rsp_recd == 0));

  tmp_q2  = wtt_q.find_index with ((!item.isCoh) && 
                                  (cl_aligned((item.cache_addr)) === cl_aligned(cmd_req_pkt.smi_addr)) && 
                                  security_match(item.security, cmd_req_pkt.smi_ns) &&
                                  (item.AXI_write_resp_expd == 1 && !(item.AXI_write_resp_recd))); 

  tmp_q3  = rtt_q.find_index with ((item.isMrd) && 
                                  (cl_aligned((item.cache_addr)) === cl_aligned(cmd_req_pkt.smi_addr)) && 
                                  security_match(item.security, cmd_req_pkt.smi_ns) &&
                                  (item.DTR_req_expd == 1 && item.DTR_req_recd == 0));

  //#Check.DMI.Concerto.v3.0.CmdReqCoherentAccess
  //if(cmd_req_pkt.smi_ch) `uvm_error("<%=obj.BlockId%>:processCmdReq","DMI recieved a coherent CMDreq")

  //#Check.DMI.Concerto.v3.0.CmdReqRL01
  if(cmd_req_pkt.smi_msg_type inside {CMD_CLN_INV,CMD_CLN_VLD,CMD_CLN_SH_PER,CMD_MK_INV})begin
    if(cmd_req_pkt.smi_rl != 'b10) begin
      `uvm_error("<%=obj.BlockId%>:processCmdReq",$sformatf("expected response level for cmo is 10 got %0b (refer to CONC-7606)",cmd_req_pkt.smi_rl))
    end
  end
  if(cmd_req_pkt.smi_msg_type inside {CMD_RD_NC,CMD_WR_NC_PTL,CMD_WR_NC_FULL})begin
    if(cmd_req_pkt.smi_rl != 'b01) begin
       `uvm_error("<%=obj.BlockId%>:processCmdReq",$sformatf("expected response level for non-cmo is 01 got %0b",cmd_req_pkt.smi_rl)) 
    end
  end

  if((tmp_q.size+tmp_q1.size) > 0) begin
    `uvm_info("<%=obj.BlockId%>:processCmdReq:0", $sformatf("%1p",cmd_req_pkt), UVM_MEDIUM)
    `uvm_error("<%=obj.BlockId%>:processCmdReq:0", "cmd_req should not re-use msg_id inflight, which did not receive cmd_rsp")
  end
  //check is disabled as per CONC-7245
  //if(tmp_q3.size()>0 && (cmd_req_pkt.isCmdNcRdMsg() || cmd_req_pkt.isCmdNcWrMsg()))begin
  //  `uvm_info("<%=obj.BlockId%>:processCmdReq:1", $sformatf("%1p",cmd_req_pkt), UVM_MEDIUM)
  //  `uvm_error("<%=obj.BlockId%>:processCmdReq:1", "cmd_req should not collide with Mrdinflighti, which did not sent DTR")
  //end

  <% if(obj.useCmc && obj.DmiInfo[obj.Id].ccpParams.useScratchpad){%>
  m_cmd_entry.lower_sp_addr = lower_sp_addr;
  m_cmd_entry.upper_sp_addr = upper_sp_addr;
  m_cmd_entry.cache_addr_i  = ncoreConfigInfo::gen_spad_intrlv_rmvd_addr(cmd_req_pkt.smi_addr,<%=obj.DmiInfo[obj.Id].nUnitId%>);
  m_cmd_entry.sp_enabled    = sp_enabled;
  m_cmd_entry.sp_ns         = sp_ns;
  m_cmd_entry.rsvd_ways     = (2**$clog2(sp_ways)) - 1;
  <% } %>

  if(cmd_req_pkt.isCmdNcRdMsg())begin 
    // m_cmd_entry.wrOutstandingcnt = tmp_q2.size();
    if(cmd_req_pkt.smi_es && exclusive_flg)begin
      if(!(cmd_req_pkt.smi_vz && !cmd_req_pkt.smi_ac) && exmon_size == 0)begin
       `uvm_info("<%=obj.BlockId%>:processCmdReq:2", $sformatf("%1p",cmd_req_pkt), UVM_MEDIUM)
       `uvm_error("<%=obj.BlockId%>:processCmdReq:2", "exclusive NcRd should be non-cacheable and system visible")
      end
    end
    m_cmd_entry.cmd_req_pkt      = cmd_req_pkt;
    m_cmd_entry.t_cmdreq         = $time;
    m_cmd_entry.addToRttQ(cmd_req_pkt,1,0,0);
    if (!lookup_en) m_cmd_entry.lookupExpd = 0;
    rtt_q.push_back(m_cmd_entry);
    numNcrdTxns++;
    `uvm_info("DMI_SCB", $psprintf("DMI_UID:%0d: CMD_REQ: %s", m_cmd_entry.txn_id, cmd_req_pkt.convert2string()), UVM_LOW);
  end
  else if(cmd_req_pkt.smi_msg_type inside {CMD_CLN_INV,CMD_CLN_VLD,CMD_CLN_SH_PER,CMD_MK_INV,CMD_PREF})begin 
    m_cmd_entry.cmd_req_pkt      = cmd_req_pkt;
    m_cmd_entry.t_cmdreq         = $time;
    m_cmd_entry.addToRttQ(cmd_req_pkt,0,0,0);
    if (!lookup_en) m_cmd_entry.lookupExpd = 0;
    rtt_q.push_back(m_cmd_entry);
    `uvm_info("DMI_SCB", $psprintf("DMI_UID:%0d: CMD_REQ: %s", m_cmd_entry.txn_id, cmd_req_pkt.convert2string()), UVM_LOW);
  end
  else if(cmd_req_pkt.isCmdNcWrMsg()) begin
    m_cmd_entry.cmd_req_pkt = cmd_req_pkt;
    m_cmd_entry.t_cmdreq    = $time;
    if(cmd_req_pkt.smi_es  && exclusive_flg) begin
      if(!(cmd_req_pkt.smi_vz && !cmd_req_pkt.smi_ac) && exmon_size == 0)begin
        `uvm_info("<%=obj.BlockId%>:processCmdReq:3", $sformatf("%1p",cmd_req_pkt), UVM_MEDIUM)
        `uvm_error("<%=obj.BlockId%>:processCmdReq:3", "exclusive NcWr should be non-cacheable and system visible")
      end
    end
    m_cmd_entry.addToWttQ(cmd_req_pkt,1,1,0,uncorr_data_err);
    `uvm_info("DMI_SCB", $psprintf("DMI_UID:%0d: CMD_REQ: %s", m_cmd_entry.txn_id, cmd_req_pkt.convert2string()), UVM_LOW);
    if (!lookup_en) m_cmd_entry.lookupExpd = 0;
    wtt_q.push_back(m_cmd_entry);
    numNcwrTxns++;
  end
  else if(cmd_req_pkt.isCmdAtmStoreMsg()) begin
    <% if(obj.DmiInfo[obj.Id].useAtomic) { %>     
    m_cmd_entry.cmd_req_pkt = cmd_req_pkt;
    m_cmd_entry.t_cmdreq    = $time;
    m_cmd_entry.isAtmStore  = 1;
    m_cmd_entry.isAtomic    = 1;
    m_cmd_entry.addToRttQ(cmd_req_pkt,1,0,0);
    if (!lookup_en) m_cmd_entry.lookupExpd = 0;
    rtt_q.push_back(m_cmd_entry);
    numAtmStoreTxns++;
    `uvm_info("DMI_SCB", $psprintf("DMI_UID:%0d: CMD_REQ: %s", m_cmd_entry.txn_id, cmd_req_pkt.convert2string()), UVM_LOW);
    <% } else { %>
    `uvm_info("<%=obj.BlockId%>:processCmdReq:4", $sformatf("%1p",cmd_req_pkt), UVM_MEDIUM)
    if(!$test$plusargs("error_test")) begin
      `uvm_error("<%=obj.BlockId%>:processCmdReq:4", $sformatf("INVALID! Not able to process atomic the cmd type:%0x",cmd_req_pkt.smi_msg_type));
    end
    <% } %>
  end 
  else if(cmd_req_pkt.isCmdAtmLoadMsg()) begin
    <% if(obj.DmiInfo[obj.Id].useAtomic) { %>     
    m_cmd_entry.cmd_req_pkt      = cmd_req_pkt;
    m_cmd_entry.t_cmdreq         = $time;
    m_cmd_entry.isAtomic         = 1;
    m_cmd_entry.addToRttQ(cmd_req_pkt,1,0,0);
    if (!lookup_en) m_cmd_entry.lookupExpd = 0;
    rtt_q.push_back(m_cmd_entry);
    numAtmLdTxns++;
    `uvm_info("DMI_SCB", $psprintf("DMI_UID:%0d: CMD_REQ: %s", m_cmd_entry.txn_id, cmd_req_pkt.convert2string()), UVM_LOW);
    <% } else { %>
    `uvm_info("<%=obj.BlockId%>:processCmdReq:3", $sformatf("%1p",cmd_req_pkt), UVM_MEDIUM)
    if(!$test$plusargs("error_test")) begin
      `uvm_error("<%=obj.BlockId%>:processCmdReq:3", $sformatf("INVALID! Not able to process atomic the cmd type:%0x",cmd_req_pkt.smi_msg_type));
    end
    <% } %>
  end 
  else begin
    `uvm_info("<%=obj.BlockId%>:processCmdReq:4", $sformatf("%1p",cmd_req_pkt), UVM_MEDIUM)
    `uvm_error("<%=obj.BlockId%>:processCmdReq:4", $sformatf("Not able to recognize the cmd type:%0x",cmd_req_pkt.smi_msg_type));
  end
endfunction : processCmdReq

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// process cmd rsp
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function void dmi_scoreboard::processCmdRsp(smi_seq_item  cmd_rsp_pkt);
  int tmp_q[$],tmp_q1[$],tmp_q2[$],idx;
  bit found = 0;
  dmi_scb_txn txn;

  tmp_q = {};

  //#Check.DMI.MRDRspFields   //#Check.DMI.SMIImsgIDFieldCorrect

  tmp_q  = rtt_q.find_index with ((!item.isCoh) && 
                                  (item.cmd_src_unit_id == cmd_rsp_pkt.smi_targ_ncore_unit_id) && 
                                  (item.cmd_msg_id== cmd_rsp_pkt.smi_rmsg_id) && 
                                  (item.CMD_rsp_recd == 0));

  tmp_q1 = wtt_q.find_index with ((!item.isCoh) && 
                                  (item.cmd_src_unit_id == cmd_rsp_pkt.smi_targ_ncore_unit_id) && 
                                  (item.cmd_msg_id== cmd_rsp_pkt.smi_rmsg_id) && 
                                  (item.CMD_rsp_recd == 0));
  //#Check.DMI.Concerto.v3.0.CMDRspRMessageIdAiuId
  if ((tmp_q.size +tmp_q1.size) == 0) begin
     `uvm_info("<%=obj.BlockId%>:processCmdRsp", $sformatf("%1p",cmd_rsp_pkt), UVM_MEDIUM)
     `uvm_error("<%=obj.BlockId%>:processCmdRsp", "smi_msg_id for CMDrsp not found")

  end
  else if ((tmp_q.size+tmp_q1.size) > 1) begin
     `uvm_info("<%=obj.BlockId%>:processCmdRsp", $sformatf("%1p",cmd_rsp_pkt), UVM_MEDIUM)
     `uvm_error("<%=obj.BlockId%>:processCmdRsp", "smi_rmsg_id for Cmdrsp matches multiple outstanding requests from same source")
  end
  else begin
    if(tmp_q.size == 1)begin
      txn = rtt_q[tmp_q[0]];
    end
    else begin
      txn = wtt_q[tmp_q1[0]];
    end
    txn.CMD_rsp_recd  = 1;
    txn.cmd_rsp_pkt   = cmd_rsp_pkt;
    txn.t_cmdrsp      = $time;
    txn.t_latest_update = $time;
    txn.print_entry();
    <%if (obj.DmiInfo[obj.Id].fnEnableQos) { %>
    if(cmd_rsp_pkt.smi_msg_pri != ncoreConfigInfo::qos_mapping(txn.smi_qos))begin
      `uvm_error("<%=obj.BlockId%>:processCmdRsp",$sformatf("Priority for smi_qos :%0x Exp :%0x Recd :%0x",txn.smi_qos,ncoreConfigInfo::qos_mapping(txn.smi_qos),cmd_rsp_pkt.smi_msg_pri))
    end
    <% } %>
    if(txn.exp_smi_tm != cmd_rsp_pkt.smi_tm) begin
      `uvm_error("<%=obj.BlockId%>:processCmdRsp",$sformatf("smi_tm not matching. Expd %0b Actual %0b", txn.exp_smi_tm, cmd_rsp_pkt.smi_tm))
    end
    if(tmp_q.size == 1)begin
      `uvm_info("DMI_SCB", $psprintf("DMI_UID:%0d: CMD_RSP: %s", txn.txn_id, cmd_rsp_pkt.convert2string()), UVM_LOW);
      updateRttentry(txn,tmp_q[0]);
    end
    else begin
      `uvm_info("DMI_SCB", $psprintf("DMI_UID:%0d: CMD_RSP: %s", txn.txn_id, cmd_rsp_pkt.convert2string()), UVM_LOW);
      updateWttentry(txn,tmp_q1[0]);
    end
  end // else: !if(tmp_q.size > 1)
endfunction : processCmdRsp
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// process str_req
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function void dmi_scoreboard::processStrReq(smi_seq_item  str_req_pkt);
  int tmp_q[$],tmp_q1[$],tmp_q2[$],tmp_q3[$],tmp_q4[$],tmp_q5[$],tmp_q6[$];
  bit found = 0;
  dmi_scb_txn txn;

  tmp_q = {};

  //#Check.DMI.STRReqFields   //#Check.DMI.SMIrmsgIDFieldCorrect
  `uvm_info("<%=obj.BlockId%>:processStrReq", $sformatf("%1p",str_req_pkt), UVM_MEDIUM)

  tmp_q  = rtt_q.find_index with ((!item.isCoh) && 
                                  (item.cmd_src_unit_id == str_req_pkt.smi_targ_ncore_unit_id) && 
                                  (item.cmd_msg_id== str_req_pkt.smi_rmsg_id) && 
                                  (item.STR_req_expd == 1) &&
                                  (item.STR_req_recd == 0));

  tmp_q1 = wtt_q.find_index with ((!item.isCoh) && 
                                  (item.cmd_src_unit_id == str_req_pkt.smi_targ_ncore_unit_id) && 
                                  (item.cmd_msg_id== str_req_pkt.smi_rmsg_id) && 
                                  (item.STR_req_expd == 1) &&
                                  (item.STR_req_recd == 0));

  tmp_q2 = {};
  tmp_q2 = rtt_q.find_index with((item.smi_rbid == str_req_pkt.smi_rbid) &&
                                (item.STR_req_recd == 1 ) && 
                                (item.smi_msg_type inside {CMD_RD_ATM,CMD_WR_ATM,CMD_SW_ATM,CMD_CMP_ATM}) &&
                                (item.STR_req_recd == 1) &&
                                (item.smi_dp_last == 0 ));

  tmp_q3 = wtt_q.find_index with ((!item.isCoh) && 
                                  (item.cmd_src_unit_id == str_req_pkt.smi_targ_ncore_unit_id) && 
                                  (item.cmd_msg_id== str_req_pkt.smi_rmsg_id) && 
                                  (item.STR_req_recd == 1) &&
                                  (item.smi_dp_last == 0 ));

  tmp_q4 = {};
  
  tmp_q4 = rtt_q.find_index with ((!item.isCoh) &&
                                  (item.STR_req_recd == 1) &&
                                  (item.STR_rsp_recd == 0) &&
                                  (item.str_msg_id == str_req_pkt.smi_msg_id));
  
  tmp_q5 = {};
  
  tmp_q5 = wtt_q.find_index with ((!item.isCoh) &&
                                  (item.STR_req_recd == 1) &&
                                  (item.STR_rsp_recd == 0) &&
                                  (item.str_msg_id == str_req_pkt.smi_msg_id));
  
  tmp_q6 = {};
  
  tmp_q6 = wtt_q.find_index with ((!item.isCoh) &&
                                  (item.STR_req_recd == 1) &&
                                  (item.smi_rbid == str_req_pkt.smi_rbid) &&
                                  (item.DTW_req_recd == 0));
  
  
  if(tmp_q4.size() || tmp_q5.size()) begin
      `uvm_error("<%=obj.BlockId%>:processStrReq",$sformatf("There is already a STR inflight. size of tmp_q4 is %d and tmp_q5 is %d",tmp_q4.size(),tmp_q5.size()))
  end
  
  if(tmp_q6.size()) begin
     //`uvm_error("<%=obj.BlockId%>:processStrReq",$sformatf("Found an entry with matching RBID in wtt for which DTWreq is not recieved. RBID will not be released until dtw is recieved. size of tmp_q6 is %d",tmp_q6.size()))
  end

  if(str_req_pkt.smi_rbid < <%=ch_rbid%>) begin
     `uvm_info("<%=obj.BlockId%>:processStrReq", $sformatf("%1p",str_req_pkt), UVM_LOW)
     `uvm_error("<%=obj.BlockId%>:processStrReq",$sformatf("StrReq rbid:%0d using from coh pool,it should be within range [<%=ch_rbid%>:<%=ch_rbid+Nch_rbid-1%>]",str_req_pkt.smi_rbid))
  end

  if((tmp_q.size +tmp_q1.size) == 0) begin
    `uvm_info("<%=obj.BlockId%>:processStrReq", $sformatf("%1p",str_req_pkt), UVM_LOW)
    `uvm_error("<%=obj.BlockId%>:processStrReq", " Any Nc Wr/Rd cmd for StrReq with smi_rmsg_id not found")
  end
  else if ((tmp_q2.size+tmp_q3.size) > 1) begin
    `uvm_info("<%=obj.BlockId%>:processStrReq", $sformatf("%1p",str_req_pkt), UVM_LOW)
    `uvm_error("<%=obj.BlockId%>:processStrReq",$sformatf("Str req with rbid :%0d matching multiple outstanding Nc Wr/Rd requests tmp_q2.size:%0d tmp_q3.size:%0d",str_req_pkt.smi_rbid,tmp_q2.size,tmp_q3.size))
  end
  //#Check.DMI.Concerto.v3.0.STRreqMessageIdAiuId
  else if ((tmp_q.size+tmp_q1.size) > 1) begin
    `uvm_info("<%=obj.BlockId%>:processStrReq", $sformatf("%1p",str_req_pkt), UVM_LOW)
    `uvm_error("<%=obj.BlockId%>:processStrReq", "Str req with smi_rmsg_id matching multiple outstanding Nc Wr/Rd requests")
  end
  else begin
    if(tmp_q.size == 1)begin
      txn = rtt_q[tmp_q[0]];
      txn.smi_rbid       = str_req_pkt.smi_rbid ;
      `ifdef NC_CMD_RSP_CHK
      //#Check.DMI.Concerto.v3.0.STRreqProcessOrder
      if((rtt_q[tmp_q[0]].smi_msg_type inside {CMD_CLN_INV,CMD_CLN_VLD,CMD_MK_INV,CMD_CLN_SH_PER}) && rtt_q[tmp_q[0]].wrOutstandingFlag == 1)begin
        txn.print_entry();
        `uvm_error("<%=obj.BlockId%>:processStrReq", "StrReq for CMD_CLN_INV,CMD_CLN_VLD,CMD_MK_INV,CMD_CLN_SH_PER should not sent with WrOutstandinFlg == 1")
      end
      `endif
      // Get Load CmdReq to be input of exmon
      // DMI : CONC-13190 : all atomics are considered to be writes. So an atomic reaching the monitor should behave like a non exclusive NC write.
      if((txn.cmd_req_pkt.isCmdNcRdMsg() || txn.cmd_req_pkt.isCmdAtmStoreMsg() || txn.cmd_req_pkt.isCmdAtmLoadMsg()) && exmon_size > 0)begin 
        exec_mon_result_t m_exmon_result ;
        //#Check.DMI.ExMon.Func
        m_exmon_result = exec_mon.predict_exmon(txn.cmd_req_pkt) ;   //store exclusive monitor status
        rtt_q[tmp_q[0]].m_exmon_status = m_exmon_result.exmon_status;
        if(m_exmon_result.exmon_event.event_trig == 1 && !SysEventDisable) begin
          `uvm_info("<%=obj.BlockId%>:processStrReq", $sformatf("Registered an exclusive monitor clear event."),UVM_MEDIUM)
          exmon_clear_event_q.push_back(m_exmon_result.exmon_event);
        end
      end
    end
    else begin
      txn = wtt_q[tmp_q1[0]];
      txn.smi_rbid       = str_req_pkt.smi_rbid ;
      // Get Store CmdReq to be input of exmon
      if(txn.cmd_req_pkt.isCmdNcWrMsg() && exmon_size > 0) begin 
        exec_mon_result_t m_exmon_result ;
        //#Check.DMI.ExMon.Func
        m_exmon_result = exec_mon.predict_exmon(txn.cmd_req_pkt) ;   //store exclusive monitor status
        wtt_q[tmp_q1[0]].m_exmon_status = m_exmon_result.exmon_status;
        //#Check.DMI.ExMon.ExFailDropped
        if (wtt_q[tmp_q1[0]].m_exmon_status == EX_FAIL)  begin
          wtt_q[tmp_q1[0]].lookupExpd = 0;
          wtt_q[tmp_q1[0]].AXI_write_addr_expd = 0;
          wtt_q[tmp_q1[0]].AXI_write_data_expd = 0;
          wtt_q[tmp_q1[0]].AXI_write_resp_expd = 0;
          <% if(obj.useCmc) { %>
          if(wtt_q[tmp_q1[0]].sp_txn) begin
            wtt_q[tmp_q1[0]].sp_seen_write_chnl = 1;
            wtt_q[tmp_q1[0]].sp_seen_ctrl_chnl = 1;
          end
          <%}%>
        end
        if(m_exmon_result.exmon_event.event_trig == 1 && !SysEventDisable) begin
          `uvm_info("<%=obj.BlockId%>:processStrReq", $sformatf("Registered an exclusive monitor clear event."), UVM_MEDIUM)
          exmon_clear_event_q.push_back(m_exmon_result.exmon_event);
        end
      end
    end
    txn.STR_req_recd   = 1;
    txn.str_msg_id     = str_req_pkt.smi_msg_id ;
    txn.str_req_pkt    = str_req_pkt;
    txn.t_strreq       = $time;
    txn.t_latest_update = $time;
    txn.print_entry();
    `uvm_info("DMI_SCB", $psprintf("DMI_UID:%0d: STR_REQ: %s", txn.txn_id, str_req_pkt.convert2string()), UVM_LOW);
    //#Check.DMI.Concerto.v3.0.STRreqQOS
    <%if (obj.DmiInfo[obj.Id].fnEnableQos) { %>
    if(str_req_pkt.smi_msg_pri != ncoreConfigInfo::qos_mapping(txn.smi_qos))begin
      `uvm_error("<%=obj.BlockId%>:processStrReq",$sformatf("Priority for smi_qos :%0x Exp :%0x Recd :%0x DMI_UID:%0d:",txn.smi_qos,ncoreConfigInfo::qos_mapping(txn.smi_qos),str_req_pkt.smi_msg_pri,txn.txn_id))
    end
    <% } %>
    //#Check.DMI.Concerto.v3.0.STRreqTM
    if(txn.exp_smi_tm != str_req_pkt.smi_tm) begin
      `uvm_error("<%=obj.BlockId%>:processStrReq",$sformatf("smi_tm bit not matching. Expd %0b Actual %0b DMI_UID:%0d:", txn.exp_smi_tm, str_req_pkt.smi_tm,txn.txn_id)) 
    end
  end // else: !if(tmp_q.size > 1)
endfunction : processStrReq
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// process str_rsp
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function void dmi_scoreboard::processStrRsp(smi_seq_item  str_rsp_pkt);
  int tmp_q[$],tmp_q1[$];
  bit found = 0;
  dmi_scb_txn txn;

  tmp_q = {};

  //#Check.DMI.Concerto.v3.0.STRRspRmessageId
  `uvm_info("<%=obj.BlockId%>:processStrRsp", $sformatf("%1p",str_rsp_pkt), UVM_MEDIUM)
  tmp_q  = rtt_q.find_index with ((!item.isCoh) && 
                                  (item.cmd_src_unit_id == str_rsp_pkt.smi_src_ncore_unit_id) && 
                                  (item.str_msg_id== str_rsp_pkt.smi_rmsg_id) && 
                                  (item.STR_req_recd == 1) &&
                                  (item.STR_rsp_recd == 0));

  tmp_q1 = wtt_q.find_index with ((!item.isCoh) && 
                                  (item.cmd_src_unit_id == str_rsp_pkt.smi_src_ncore_unit_id) && 
                                  (item.str_msg_id== str_rsp_pkt.smi_rmsg_id) && 
                                  (item.STR_req_recd == 1) &&
                                  (item.STR_rsp_recd == 0));
  //#Check.DMI.Concerto.v3.0.DmiunitId
  if ((tmp_q.size +tmp_q1.size) == 0) begin
    `uvm_error("<%=obj.BlockId%>:processStrRsp", "Any str_req for StrRsp with smi_rmsg_id not found")
  end
  else if ((tmp_q.size+tmp_q1.size) > 1) begin
    `uvm_error("<%=obj.BlockId%>:processStrRsp", "Str rsp with smi_rmsg_id matching multiple outstanding str_req requests")
  end
  else begin
    if(tmp_q.size == 1)begin
     txn = rtt_q[tmp_q[0]];
    end
    else begin
     txn = wtt_q[tmp_q1[0]];
    end
     txn.STR_rsp_recd    = 1;
     txn.str_rsp_pkt     = str_rsp_pkt;
     txn.t_strrsp        = $time;
     txn.t_latest_update = $time;
     txn.print_entry();
     if(txn.exp_smi_tm != str_rsp_pkt.smi_tm) begin
       `uvm_error("<%=obj.BlockId%>:processStrRsp",$sformatf("smi_tm bit not matching. Expd %0b Actual %0b", txn.exp_smi_tm, str_rsp_pkt.smi_tm))
     end
    if(tmp_q.size == 1)begin
      `uvm_info("DMI_SCB", $psprintf("DMI_UID:%0d: STR_RSP: %s", txn.txn_id, str_rsp_pkt.convert2string()), UVM_LOW);
      updateRttentry(txn,tmp_q[0]);
    end
    else begin
      `uvm_info("DMI_SCB", $psprintf("DMI_UID:%0d: STR_RSP: %s", txn.txn_id, str_rsp_pkt.convert2string()), UVM_LOW);
      updateWttentry(txn,tmp_q1[0]);
    end

  end // else: !if(tmp_q.size > 1)
endfunction : processStrRsp
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// System Event handling for requests
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function void dmi_scoreboard::processSysReq(smi_seq_item pkt);
  `uvm_info("<%=obj.BlockId%>:processSysReq", $sformatf("%1p",pkt), UVM_MEDIUM)
  if(SysEventDisable) begin
    `uvm_error("<%=obj.BlockId%>:processSysReq", "Received a system request on interface with system event disabled in CSR")
  end
  else begin
    int match_q[$];
    match_q = sys_evt_q.find_index with ( (item.smi_src_id == pkt.smi_src_id) &&
                                          (item.smi_targ_id == pkt.smi_targ_id)
                                        );
    if((match_q.size() == 0) || (match_q.size() > 0 && $test$plusargs("sys_rsp_timeout")))begin
      sysreq_clear_evt_q.push_back(1);  
      sys_evt_q.push_back(pkt);
      expectSysEvtTimeout = 1;
    end
    else begin
      //Only one SysReq should be active per source/target
      `uvm_info("<%=obj.BlockId%>:processSysReq", "------Start printing all matching system events", UVM_MEDIUM)
      foreach(match_q[i]) begin
        `uvm_info("<%=obj.BlockId%>:processSysReq", $sformatf("%1p",sys_evt_q[match_q[i]]), UVM_MEDIUM)
      end
      `uvm_info("<%=obj.BlockId%>:processSysReq", "------End printing all matching system events", UVM_MEDIUM)
      `uvm_error("<%=obj.BlockId%>:processSysReq","Found an incomplete SysReq event. Only one SysReq should be active per source/target pair");
    end
  end
endfunction
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// System Event handling for response
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function void dmi_scoreboard::processSysRsp(smi_seq_item pkt);
  `uvm_info("<%=obj.BlockId%>:processSysRsp", $sformatf("%1p",pkt), UVM_MEDIUM)
  if(SysEventDisable) begin
    `uvm_error("<%=obj.BlockId%>:processSysRsp", "Received a system response on interface with system event disabled in CSR")
  end
  else begin
    int match_q[$];
    match_q = sys_evt_q.find_index with ((item.smi_src_id == pkt.smi_targ_id) &&
                                         (item.smi_targ_id == pkt.smi_src_id) &&
                                         (item.smi_rmsg_id == pkt.smi_rmsg_id)
                                        );
    if(match_q.size() == 0) begin
      `uvm_error("<%=obj.BlockId%>:processSysRsp", $sformatf("Received a system response with no match in sys_evt_q(%0d)", sys_evt_q.size()))
    end
    else if(match_q.size() > 1 && !($test$plusargs("sys_rsp_timeout")))begin
      `uvm_info("<%=obj.BlockId%>:processSysRsp", "------Start printing all matching system events", UVM_MEDIUM)
      foreach(match_q[i]) begin
        `uvm_info("<%=obj.BlockId%>:processSysRsp", $sformatf("%1p",sys_evt_q[match_q[i]]), UVM_MEDIUM)
      end
      `uvm_info("<%=obj.BlockId%>:processSysRsp", "------End printing all matching system events", UVM_MEDIUM)
      `uvm_error("<%=obj.BlockId%>:processSysRsp", $sformatf("Found %0d SysReq matches for current SysRsp",match_q.size()))
    end
    else begin
      sys_evt_q.delete(match_q[0]);
    end
  end
endfunction
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Process AR Channel
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function void dmi_scoreboard::processArChnl(axi4_read_addr_pkt_t m_pkt);
  smi_addr_t     addr;
  smi_security_t arsecurity;
  dmi_scb_txn    txn;
  int tmp_q[$], tmp_q1[$], tmp_q2[$], tmp_q4[$];
  int collision_q[$];
  int match; 
  int arid_full_width, arid_sliced_no_of_bits;
  time oldest;
  bit ok, use_collision;
  
  axi4_read_addr_pkt_t m_packet;
  m_packet = new();
  m_packet.copy(m_pkt);

  `uvm_info("<%=obj.BlockId%>:processArChnl", $sformatf("HxP1:: %s",m_packet.sprint_pkt()), UVM_MEDIUM)
  $cast(addr, m_packet.araddr);

  if(m_packet.arcache != 4'b0010)begin
  `uvm_info("<%=obj.BlockId%>:processArChnl", $sformatf("HxP2:: %s",m_packet.sprint_pkt()), UVM_LOW)
  `uvm_error("<%=obj.BlockId%>:processArChnl", $sformatf("recd arcache 0x%0x  expected arcache :4'b0010 (Normal Non-cacheable Non -bufferable)",m_packet.arcache))
  end

  /////////////////////////////////////////////////////
  //#Check.DMI.Concerto.v3.0.security
  ////////////////////////////////////////////////////
  $cast(arsecurity, m_packet.arprot[1]);

  if(!size_aligned(addr,m_packet.arsize,m_packet.arlen)) begin
    `uvm_error("<%=obj.BlockId%>:processArChnl", $sformatf("Addr 0x%0x isn't size aligned to data arsize :0x%0d Bytes", addr,m_packet.arsize))
  end

  <% if(obj.useCmc) { %>
  if(lookup_en)begin
    tmp_q = {};
    tmp_q = rtt_q.find_index with ((item.isMrd || item.isNcRd || item.isCmdPref || item.isDtwMrgMrd ) && 
                                   (beat_aligned(axi4_addr_trans_addr(item.cache_addr)) == beat_aligned(addr)) && 
                                    security_match(item.security, arsecurity) && 
                                    (item.lookupExpd ? (item.lookupSeen == 1):(item.lookupSeen == 0)) && 
                                    (item.seenAtReadArb || item.seenAtWriteArb) &&
                                    (item.AXI_read_addr_expd == 1) && 
                                    (item.AXI_read_addr_recd == 0)); 
    tmp_q1 = {};
    tmp_q1 = rtt_q.find_index with ((item.isMrd) && 
                                   (cl_aligned(axi4_addr_trans_addr(item.cache_addr)) == cl_aligned(addr)) && 
                                    security_match(item.security, arsecurity) && 
                                    (item.lookupExpd ? (item.lookupSeen == 1):(item.lookupSeen == 0)) && 
                                    item.seenAtReadArb &&
                                    (item.AXI_read_addr_expd == 1) && 
                                    (item.AXI_read_addr_recd == 0)); 
  end
  else begin
    tmp_q = {};
    tmp_q = rtt_q.find_index with ((item.isMrd || item.isNcRd || item.isCmdPref || item.isDtwMrgMrd ) && 
                                   (beat_aligned(axi4_addr_trans_addr(item.cache_addr)) == beat_aligned(addr)) && 
                                    security_match(item.security, arsecurity) && 
                                    (item.isCoh ? 1 : item.CMD_rsp_recd_rtl ) &&
                                    (item.seenAtReadArb || item.seenAtWriteArb) &&
                                    (item.AXI_read_addr_expd == 1) && 
                                    (item.AXI_read_addr_recd == 0)); 
    tmp_q1 = {};
    tmp_q1 = rtt_q.find_index with ((item.isMrd) && 
                                   (cl_aligned(axi4_addr_trans_addr(item.cache_addr)) == cl_aligned(addr)) && 
                                    security_match(item.security, arsecurity) && 
                                    item.seenAtReadArb &&
                                    (item.AXI_read_addr_expd == 1) && 
                                    (item.AXI_read_addr_recd == 0)); 
    tmp_q2 = {};
    tmp_q2 = rtt_q.find_index with ((item.isCmdPref) && (cl_aligned(axi4_addr_trans_addr(item.cache_addr)) == cl_aligned(addr)) && 
                                                  security_match(item.security, arsecurity) && 
                                                  item.seenAtReadArb &&
                                                  (item.AXI_read_addr_expd == 1) && 
                                                  (item.AXI_read_addr_recd == 0)); 
  end
  <% } else { %>
  tmp_q = {};
  tmp_q = rtt_q.find_index with ((item.isMrd || item.isNcRd || item.isCmdPref || item.isDtwMrgMrd ) && 
                                 (beat_aligned(axi4_addr_trans_addr(item.cache_addr)) == beat_aligned(addr)) && 
                                  security_match(item.security, arsecurity) && 
                                  (item.isCoh ? 1 : item.CMD_rsp_recd_rtl ) &&
                                  (item.seenAtReadArb || item.seenAtWriteArb) &&
                                  (item.AXI_read_addr_expd == 1) && 
                                  (item.AXI_read_addr_recd == 0)); 
  tmp_q1 = {};
  tmp_q1 = rtt_q.find_index with ((item.isMrd) && 
                                 (cl_aligned(axi4_addr_trans_addr(item.cache_addr)) == cl_aligned(addr)) && 
                                  security_match(item.security, arsecurity) && 
                                  item.seenAtReadArb &&
                                  (item.AXI_read_addr_expd == 1) && 
                                  (item.AXI_read_addr_recd == 0)); 
  tmp_q2 = {};
  tmp_q2 = rtt_q.find_index with ((item.isCmdPref) && (cl_aligned(axi4_addr_trans_addr(item.cache_addr)) == cl_aligned(addr)) && 
                                                security_match(item.security, arsecurity) && 
                                                item.seenAtReadArb &&
                                                (item.AXI_read_addr_expd == 1) && 
                                                (item.AXI_read_addr_recd == 0)); 
  <% } %>

  // if one, update rtt queue with info after checking that axi transactions are expected for said entry
  /////////////////////////////////////////////
  //#Check.DMI.Concerto.v3.0.Araddr
  ////////////////////////////////////////////
  if((tmp_q.size  == 0)) begin
     `uvm_error("<%=obj.BlockId%>:processArChnl", $sformatf("Cache Addr matching AXI araddr not found in rtt queue 0x%0h",addr))
  end
  else begin 
  if (tmp_q1.size  > 1) begin
    if (!(rtt_q[tmp_q1[0]].smi_msg_type == MRD_PREF)) begin
      `uvm_error("<%=obj.BlockId%>:processArChnl", $sformatf("Multiple Mrd match AXI araddr 0x%0h", addr))
    end
  end

  match = 0;

  if(tmp_q.size  > 1) begin
    `uvm_info("<%=obj.BlockId%>:processArChnl", $sformatf("Multiple rtt matching for this addr 0x%0h :%0d", addr,tmp_q.size),UVM_MEDIUM);
    <% if(obj.useCmc) {%>
    if(lookup_en)begin
      oldest = rtt_q[tmp_q[0]].t_lookup ;
      foreach (tmp_q[i]) begin
        if(rtt_q[tmp_q[i]].t_lookup < oldest) begin
          oldest = rtt_q[tmp_q[i]].t_lookup;
          match = i;
        end
      end
    end
    else begin
      int  oldest_match;
      oldest = rtt_q[tmp_q[0]].isDtwMrgMrd ? rtt_q[tmp_q[0]].t_at_write_arbiter : rtt_q[tmp_q[0]].t_at_read_arbiter ;
      foreach (tmp_q[i]) begin
        time cmp_time;
        cmp_time =  rtt_q[tmp_q[i]].isDtwMrgMrd ? rtt_q[tmp_q[i]].t_at_write_arbiter : rtt_q[tmp_q[i]].t_at_read_arbiter;
        if (cmp_time < oldest) begin
           oldest = cmp_time;
           match = i;
        end
        if((cmp_time == oldest) && (i!=0)&& (match!=i)) begin
          collision_q.push_back(tmp_q[match]);
          collision_q.push_back(tmp_q[i]);
        end
      end
      if(collision_q.size > 1) begin
       match = arbitrate_read_write_collision(collision_q);
       use_collision = 1;
      end
      oldest_match = match;
      txn = rtt_q[tmp_q[oldest_match]];
    end
    <% }else{ %>
    oldest = rtt_q[tmp_q[0]].isDtwMrgMrd ? rtt_q[tmp_q[0]].t_at_write_arbiter : rtt_q[tmp_q[0]].t_at_read_arbiter ;
    foreach (tmp_q[i]) begin
      time cmp_time;
      cmp_time =  rtt_q[tmp_q[i]].isDtwMrgMrd ? rtt_q[tmp_q[i]].t_at_write_arbiter : rtt_q[tmp_q[i]].t_at_read_arbiter;
      if (cmp_time < oldest) begin
         oldest = cmp_time;
         match = i;
      end
      if((cmp_time == oldest) && (i!=0) && (match!=i)) begin
        collision_q.push_back(tmp_q[match]);
        collision_q.push_back(tmp_q[i]);
      end
    end
    if(collision_q.size > 1) begin
      match = arbitrate_read_write_collision(collision_q);
      use_collision = 1;
    end
    <% } %>
  end
  if(use_collision) begin
    txn = rtt_q[match];
  end
  else begin
    txn = rtt_q[tmp_q[match]];
  end
  `uvm_info("DMI_SCB", $psprintf("DMI_UID:%0d: ARADDR: %s", txn.txn_id, m_packet.sprint_pkt()), UVM_LOW);
  
  ok = txn.gen_exp_axi__ar(m_packet).do_compare_pkts(m_packet);
  if(!ok) `uvm_error($sformatf("<%=obj.BlockId%>:processArChnl"), $sformatf("axi_read_addr_pkt mismatch: see ERROR above queue print"))
  ///////////////////////////////////////////////////////////////
  //#Check.DMI.Concerto.v3.0.MrdCollideDtwInflight
  //#Check.DMI.Concerto.v3.0.MrdCollideWTT
  //#Check.DMI.Concerto.v3.0.MrdFlushMrdClnCollideWTT
  //////////////////////////////////////////////////////////////
  if(txn.wrOutstandingFlag || txn.isCacheHit) begin
    `uvm_error("<%=obj.BlockId%>:processArChnl", $sformatf("0:AXI req seen with rdOutstandingFlag:%0b wrOutstandingFlag:%0b cacheHit:%0b",txn.rdOutstandingFlag, txn.wrOutstandingFlag, txn.isCacheHit))
  end
  txn.axi_read_addr_pkt = m_packet;
  txn.AXI_read_addr_recd = 1;
  txn.t_ar = $time;
  txn.t_latest_update = $time;
  txn.print_entry();


  if(txn.isNcRd && !txn.isAtomic && exclusive_flg && this.exmon_size == 0)begin
    if(txn.cmd_req_pkt.smi_es)begin
      axi_arid_t my_arid;
      smi_mpf2_t arid_smi_mpf2;
      my_arid = ({WAXID{1'b0}} | (txn.cmd_req_pkt.smi_mpf2[WSMIMPF2-2:0]<<WSMINCOREUNITID) | (txn.cmd_req_pkt.smi_src_id>>WSMINCOREPORTID));
      arid_smi_mpf2 = txn.cmd_req_pkt.smi_mpf2;
      if (my_arid != txn.axi_read_addr_pkt.arid) begin
         `uvm_error("<%=obj.BlockId%>:processArChnl", $sformatf("arid :%0x not matching with smi_mpf2.arid :%0x for NcWr Exclusive",txn.axi_read_addr_pkt.arid,my_arid))
      end
    end
  end
  `uvm_info("<%=obj.BlockId%>:processArChnl", $sformatf("0:Packet with ARID=0x%x updated",m_packet.arid), UVM_MEDIUM)
  end

  `ifndef FSYS_COVER_ON
  cov.collect_axi_read_addr_pkt(m_packet);
  `endif
endfunction // processArChnl
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Process R Channel
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function void dmi_scoreboard::processRChnl(axi4_read_data_pkt_t m_pkt);
  axi4_read_data_pkt_t m_packet;
  int tmp_q[$],tmp_q2[$];
  int match; 
  uvm_event ev_rresp = ev_pool.get("ev_rresp");
  time oldest;
  dmi_scb_txn txn;
  m_packet = new();
  m_packet.copy(m_pkt);

  `uvm_info("<%=obj.BlockId%>:processRChnl", $sformatf("%1p",m_packet), UVM_MEDIUM)
  // HNT: ARID can match exactly one hint or read even if address matches multiple
  tmp_q = {};
  tmp_q = rtt_q.find_index with ((item.AXI_read_addr_recd==1) && (item.AXI_read_data_recd==0) && (item.axi_read_addr_pkt.arid === m_packet.rid));

  if((tmp_q.size == 0)) begin
    `uvm_error("<%=obj.BlockId%>:processRChnl", "AXI ARID matching AXI RID not found")
  end
  else begin 
    match = 0;
    oldest = rtt_q[tmp_q[0]].t_ar ;
    if(tmp_q.size >1)begin
      `uvm_info("<%=obj.BlockId%>:processRChnl",$sformatf("Multiple Addr matching with arid tmp_q.size :%0d",tmp_q.size()),UVM_MEDIUM);
      foreach(tmp_q[i])begin
        if(rtt_q[tmp_q[i]].t_ar < oldest) begin
          oldest = rtt_q[tmp_q[i]].t_ar;
          match = i;
        end
      end
    end
    txn = rtt_q[tmp_q[match]];

    // Entry shouldn't have rd/wr outstanding flags sets
    if(txn.wrOutstandingFlag) begin
      txn.print_entry();
      `uvm_error("<%=obj.BlockId%>:processRChnl","Data is received for an entry that has wr outstanding set. Doesn't seem right")
    end
    txn.axi_read_data_pkt = m_packet;
    txn.AXI_read_data_recd = 1;
    txn.t_latest_update = $time;
    txn.t_r = $time;
    txn.print_entry();
    `uvm_info("DMI_SCB", $psprintf("DMI_UID:%0d: RRESP: %s", txn.txn_id, m_packet.sprint_pkt()), UVM_LOW);
    foreach(m_packet.rresp_per_beat[i])begin
      //Pass ARADDR to CSR sequence when rresp = 2/3
      if(m_packet.rresp_per_beat[i] == 2 || m_packet.rresp_per_beat[i] == 3) begin
        ev_rresp.trigger(txn);
      end
    end
    <% if(obj.useCmc) { %>
    if(txn.isAtomic && txn.fillExpd && txn.DTW_req_recd &&  txn.smi_dp_last)begin
      `uvm_info("<%=obj.BlockId%>:processRChnl","processing atomic operation",UVM_MEDIUM);
      process_atomic_op(txn,tmp_q[match]);
    end
    else if(!txn.isAtomic && txn.fillExpd) begin
      `uvm_info("<%=obj.BlockId%>:processRChnl","creating  non atomic fill pkt",UVM_MEDIUM);
       convert_axi_to_fill_data(txn,fill_data,fill_data_beats,fill_data_poison);
    end
    <% } %>
    if(txn.isDtwMrgMrd)begin
      if(txn.dtw_req_pkt.smi_dp_last)begin
        MrgMrddata(txn);
       `uvm_info("<%=obj.BlockId%>:processRChnl", $sformatf(" after merge data:%1p",txn.axi_read_data_pkt), UVM_MEDIUM);
      end
    end
  end // if ((tmp_q.size == 1) && (tmp_q2.size == 0))

  `ifndef FSYS_COVER_ON
   cov.collect_axi_read_data_pkt(m_packet);
  `endif
endfunction // processRChnl
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Update dtwtable entry with AXI_write_addr_channel
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function void dmi_scoreboard::processAwChnl(axi4_write_addr_pkt_t m_pkt);
  smi_addr_t     addr;
  smi_security_t awsecurity;
  int tmp_q[$], cov_q[$],tmp_q1[$], tmp_q_nc[$], tmp_q_all[$];
  int match;
  int awid_full_width, awid_sliced_no_of_bits;
  bit ok;
  time oldest;
  bit aw_flag, w_flag;
  axi4_write_data_pkt_t tmp_data_pkt;
  axi4_write_addr_pkt_t m_packet;
  m_packet = new();
  m_packet.copy(m_pkt);


  tmp_q = {};
  $cast(addr, m_packet.awaddr);
  $cast(awsecurity, m_packet.awprot[1]);
  //m_packet.sprint_pkt();
  
  `uvm_info("<%=obj.BlockId%>:processAwChnl", $sformatf("awaddr_pkt :%p",m_packet), UVM_MEDIUM)

  tmp_q1 = {}; 
  tmp_q1 = wtt_q.find_index with ((cl_aligned(axi4_addr_trans_addr(item.cache_addr)) == cl_aligned(addr)) && security_match(item.security, awsecurity) && (item.AXI_write_addr_recd == 1));

  if(!m_packet.awlock)begin
    if(tmp_q1.size()>1)begin
      foreach(tmp_q1[i])begin
       if(wtt_q[tmp_q1[i]].isNcWr)begin
         if(!wtt_q[tmp_q1[i]].cmd_req_pkt.smi_es)begin
           if(wtt_q[tmp_q1[i]].axi_write_addr_pkt.awid != m_packet.awid)begin
            `uvm_error("<%=obj.BlockId%>:processAwChnl", "all write in flight should use same awid for same addr and security")
           end 
         end 
       end
       else begin
         if(wtt_q[tmp_q1[i]].axi_write_addr_pkt.awid != m_packet.awid)begin
          `uvm_error("<%=obj.BlockId%>:processAwChnl", "all write in flight should use same awid for same addr and security")
         end 
       end
      end
    end
  end

  if(m_packet.awcache != 4'b0010)begin
  `uvm_info("<%=obj.BlockId%>:processAwChnl", $sformatf("%s",m_packet.sprint_pkt()), UVM_LOW)
  `uvm_error("<%=obj.BlockId%>:processAwChnl", $sformatf("recd awcache 0x%0x  expected awcache :4'b0010 (Normal Non-cacheable Non -bufferable)",m_packet.awcache))
  end

  // Address needs to be aligned to beat boundary
  if (!size_aligned(addr,m_packet.awsize,m_packet.awlen)) begin
     `uvm_error("<%=obj.BlockId%>:processAwChnl", $sformatf("Addr 0x%0x isn't size aligned to data arsize :0x%0d Bytes", addr,m_packet.awsize))
  end

  // check if there is no data packet. If so, put addr packet in addr q.
  if (wr_data_q.size() === 0) begin
     wr_addr_q.push_back(m_packet);
     `uvm_info("<%=obj.BlockId%>:processAwChnl", $sformatf("write addr written to wr_addr_q"), UVM_MEDIUM)
  end
  else begin
    tmp_data_pkt = wr_data_q.pop_front();
    <% if(obj.useCmc) { %>
    if(lookup_en)begin
      tmp_q = wtt_q.find_index with ((beat_aligned(axi4_addr_trans_addr(item.cache_addr)) == beat_aligned(addr)) && 
                                     security_match(item.security, awsecurity) && 
                                     ((item.lookupExpd ? (item.lookupSeen == 1):(item.lookupSeen == 0))||item.isEvict) && 
                                     ((item.AXI_write_addr_expd == 1) && (item.AXI_write_addr_recd == 0)));
    end
    else begin
      tmp_q = wtt_q.find_index with ((beat_aligned(axi4_addr_trans_addr(item.cache_addr)) == beat_aligned(addr)) && 
                                     security_match(item.security, awsecurity) &&
                                     (item.isCoh ?(item.RB_req_recd && item.DTW_req_recd) : item.STR_req_recd ) &&
                                     ((item.AXI_write_addr_expd == 1) && (item.AXI_write_addr_recd == 0)));
      tmp_q_all = tmp_q;
      tmp_q_nc = wtt_q.find_index with ((beat_aligned(axi4_addr_trans_addr(item.cache_addr)) == beat_aligned(addr)) && 
                                       security_match(item.security, awsecurity) &&
                                       (!item.isCoh && item.STR_req_recd ) &&
                                       ((item.AXI_write_addr_expd == 1) && (item.AXI_write_addr_recd == 0)));

      if(tmp_q.size()>1)begin
         tmp_q = {};
         tmp_q = wtt_q.find_index with ((beat_aligned(axi4_addr_trans_addr(item.cache_addr)) == beat_aligned(addr)) && 
                                        security_match(item.security, awsecurity) &&
                                        (item.isCoh ? 1 : item.STR_req_recd ) &&
                                        (item.isCoh ? 1 : item.CMD_rsp_recd_rtl ) &&
                                        ((item.AXI_write_addr_expd == 1) && (item.AXI_write_addr_recd == 0)));
      end
    end
    <% } else { %>
    tmp_q = wtt_q.find_index with ((beat_aligned(axi4_addr_trans_addr(item.cache_addr)) == beat_aligned(addr)) && 
                                   security_match(item.security, awsecurity) &&
                                   (item.isCoh ?(item.RB_req_recd && item.DTW_req_recd) : item.STR_req_recd ) &&
                                   ((item.AXI_write_addr_expd == 1) && (item.AXI_write_addr_recd == 0)));

    if(tmp_q.size()>1)begin
       tmp_q = {};
       tmp_q = wtt_q.find_index with ((beat_aligned(axi4_addr_trans_addr(item.cache_addr)) == beat_aligned(addr)) && 
                                      security_match(item.security, awsecurity) &&
                                      (item.isCoh ? 1 : item.STR_req_recd ) &&
                                      (item.isCoh ? 1 : item.CMD_rsp_recd_rtl ) &&
                                      ((item.AXI_write_addr_expd == 1) && (item.AXI_write_addr_recd == 0)));
    end
    <% } %>
    if(tmp_q.size == 0) begin
      `uvm_error("<%=obj.BlockId%>:processAwChnl", $sformatf("Cache Addr matching AXI awaddr not found"))
    end
    else begin
      `uvm_info("<%=obj.BlockId%>:processAwChnl", $sformatf("Write addr found match in write data queue"), UVM_MEDIUM)
      match = 0;
      if(!addr_space_mixed) begin
        if(tmp_q.size()>1)begin
          <% if(obj.useCmc) { %>
          if(lookup_en)begin
            if(!wtt_q[tmp_q[0]].isEvict)begin
              oldest = wtt_q[tmp_q[0]].t_lookup;
            end
          else begin
             oldest = wtt_q[tmp_q[0]].t_creation;
          end
          foreach (tmp_q[i]) begin
            if(!wtt_q[tmp_q[i]].isEvict)begin
              if(wtt_q[tmp_q[i]].t_lookup < oldest) begin
                oldest = wtt_q[tmp_q[i]].t_lookup;
                match = i;
              end
            end
            else begin
              if(wtt_q[tmp_q[i]].t_creation < oldest) begin
                oldest = wtt_q[tmp_q[i]].t_creation;
                match = i;
              end
            end
          end
        end
        else begin
          oldest = wtt_q[tmp_q[0]].t_creation;
          foreach (tmp_q[i]) begin
            if (wtt_q[tmp_q[i]].t_creation < oldest) begin
              oldest = wtt_q[tmp_q[i]].t_creation;
              match = i;
            end
          end
          if(tmp_q_all.size > 1 && tmp_q_nc.size > 0 && tmp_q_all.size != tmp_q_nc.size) begin
            //If address in WTT is live with both coh+noncoh transactions, ordering is not guaranteed
            foreach(tmp_q[i]) begin 
              wtt_q[tmp_q[i]].axi_write_data_pkt  = tmp_data_pkt;
              wtt_q[tmp_q[i]].axi_write_addr_pkt  = m_packet;
              aw_flag  = wtt_q[tmp_q[i]].gen_exp_axi__aw(m_packet).do_compare_pkts(m_packet);
              w_flag   = wtt_q[tmp_q[i]].gen_exp_axi__w(tmp_data_pkt).do_compare_pkts_per_byte(tmp_data_pkt);
              if(aw_flag && w_flag) begin
                match = i;
                break;
              end
              wtt_q[tmp_q[i]].axi_write_data_pkt  = null;
              wtt_q[tmp_q[i]].axi_write_addr_pkt  = null;
            end
          end
        end
        <% }else { %>
        oldest = wtt_q[tmp_q[0]].t_creation;
        foreach(tmp_q[i]) begin
          if(wtt_q[tmp_q[i]].t_creation < oldest) begin
            oldest = wtt_q[tmp_q[i]].t_creation;
            match = i;
          end
        end
        <% } %>
        end
      end
      else begin                          //addr space mixed
        foreach(tmp_q[i]) begin 
          wtt_q[tmp_q[i]].axi_write_data_pkt  = tmp_data_pkt;
          wtt_q[tmp_q[i]].axi_write_addr_pkt  = m_packet;
          aw_flag  = wtt_q[tmp_q[i]].gen_exp_axi__aw(m_packet).do_compare_pkts(m_packet);
          w_flag   = wtt_q[tmp_q[i]].gen_exp_axi__w(tmp_data_pkt).do_compare_pkts_per_byte(tmp_data_pkt);
          if(aw_flag && w_flag) begin
             match = i;
             break;
          end
          wtt_q[tmp_q[i]].axi_write_data_pkt  = null;
          wtt_q[tmp_q[i]].axi_write_addr_pkt  = null;
        end
      end
      //Check if there is no data packet. If so, put addr packet in addr q.
      wtt_q[tmp_q[match]].axi_write_data_pkt = tmp_data_pkt;
      wtt_q[tmp_q[match]].axi_write_addr_pkt = m_packet;
      wtt_q[tmp_q[match]].AXI_write_addr_recd = 1;
      wtt_q[tmp_q[match]].AXI_write_data_recd = 1;
      wtt_q[tmp_q[match]].t_aw = $time;
      wtt_q[tmp_q[match]].t_w  = $time;
      wtt_q[tmp_q[match]].t_w1  = tmp_data_pkt.t_wtime[0];
      wtt_q[tmp_q[match]].t_latest_update = $time;
      wtt_q[tmp_q[match]].print_entry();
      `uvm_info("DMI_SCB", $psprintf("DMI_UID:%0d: AWADDR: %s ", wtt_q[tmp_q[match]].txn_id, m_packet.sprint_pkt()), UVM_LOW);
      `uvm_info("DMI_SCB", $psprintf("DMI_UID:%0d: WDATA: %s ",  wtt_q[tmp_q[match]].txn_id, tmp_data_pkt.sprint_pkt()), UVM_LOW);
      ok = wtt_q[tmp_q[match]].gen_exp_axi__aw(m_packet).do_compare_pkts(m_packet);
      if(!ok) `uvm_error($sformatf("<%=obj.BlockId%>:processAwChnl"), $sformatf("axi_write_addr_pkt mismatch: see ERROR above queue print"))

      ok = wtt_q[tmp_q[match]].gen_exp_axi__w(tmp_data_pkt).do_compare_pkts_per_byte(tmp_data_pkt);
      if(!ok && !uncorr_wrbuffer_err) `uvm_error($sformatf("<%=obj.BlockId%>:processAwChnl"), $sformatf("axi_write_data_pkt mismatch: see ERROR above queue print"))

      if(wtt_q[tmp_q[match]].isNcWr && exclusive_flg && this.exmon_size == 0)begin
        if(wtt_q[tmp_q[match]].cmd_req_pkt.smi_es)begin
           axi_awid_t my_awid;
           smi_mpf2_t awid_smi_mpf2;
           my_awid = ({WAXID{1'b0}} | (wtt_q[tmp_q[match]].cmd_req_pkt.smi_mpf2[WSMIMPF2-2:0]<<WSMINCOREUNITID) | (wtt_q[tmp_q[match]].cmd_req_pkt.smi_src_id>>WSMINCOREPORTID));
           awid_smi_mpf2 = wtt_q[tmp_q[match]].cmd_req_pkt.smi_mpf2;
          if(my_awid != wtt_q[tmp_q[match]].axi_write_addr_pkt.awid)begin
            `uvm_error("<%=obj.BlockId%>:processAwChnl", $sformatf("awid :%0x not matching with smi_mpf2 :%0x for NcWr Exclusive",wtt_q[tmp_q[match]].axi_write_addr_pkt.awid,my_awid))
          end
          /*awid_full_width = WSMINCOREUNITID + WSMIMPF2 - 1; // total width of mpf2 + ncore funit id minus the mpf2 valid bit
          if(WAXID < awid_full_width) begin
             awid_sliced_no_of_bits = awid_full_width - WAXID;
             for(int i = WSMIMPF2-2; i>WSMIMPF2-awid_sliced_no_of_bits-2; i--) begin
                if(awid_smi_mpf2[i])
                  `uvm_error("<%=obj.BlockId%>:processAwChnl", $sformatf("The sliced bit %0d of awid-mpf2:%0x is non-zero", i, awid_smi_mpf2))
             end
          end*/
        end
      end
      if ($test$plusargs("wtt_time_out_error_test") && wtt_q[tmp_q[match]].isCoh == 0 && wtt_q[tmp_q[match]].cmd_req_pkt != null && wtt_q[tmp_q[match]].cmd_req_pkt.isCmdNcWrMsg()) begin
        wtt_time_out_err_test_sec_q.push_back(wtt_q[tmp_q[match]].cmd_req_pkt.smi_ns);
        wtt_time_out_err_test_addr_q.push_back(wtt_q[tmp_q[match]].cmd_req_pkt.smi_addr);
      end else if ($test$plusargs("wtt_time_out_error_test") && wtt_q[tmp_q[match]].isCoh && wtt_q[tmp_q[match]].rb_req_pkt != null) begin
        wtt_time_out_err_test_sec_q.push_back(wtt_q[tmp_q[match]].rb_req_pkt.smi_ns);
        wtt_time_out_err_test_addr_q.push_back(wtt_q[tmp_q[match]].rb_req_pkt.smi_addr);
      end
    end // else: !if(tmp_q.size > 1)
    tmp_q = {};
  end
  `ifndef FSYS_COVER_ON
    cov.collect_axi_write_addr_pkt(m_packet);
  `endif
endfunction // processAwChnl
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Update dtw entry with AXI_write_data_channel
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function void dmi_scoreboard::processWChnl(axi4_write_data_pkt_t m_pkt);
  smi_addr_t     addr;
  smi_security_t awsecurity;
  int tmp_q[$], cov_q[$],match,tmp_q1[$],tmp_q_nc[$], tmp_q_all[$];
  time oldest;
  bit ok;
  bit aw_flag, w_flag;
  axi4_write_addr_pkt_t tmp_addr_pkt;
  axi4_write_data_pkt_t m_packet;
  m_packet = new();
  m_packet.copy(m_pkt);

   `uvm_info("<%=obj.BlockId%>:processwChnl:0", $sformatf("%1p",m_packet), UVM_MEDIUM)
  // check if there is no addr packet. If so, put data packet in data q.
  if (wr_addr_q.size() === 0) begin
     wr_data_q.push_back(m_packet);
     `uvm_info("<%=obj.BlockId%>:processwChnl:1", $sformatf("write data written to wr_data_q"), UVM_MEDIUM)
  end
  else begin
    tmp_addr_pkt = wr_addr_q.pop_front();
    $cast(addr, tmp_addr_pkt.awaddr);
    $cast(awsecurity, tmp_addr_pkt.awprot[1]);

    if(!size_aligned(addr,tmp_addr_pkt.awsize,tmp_addr_pkt.awlen)) begin
      `uvm_error("<%=obj.BlockId%>:processwChnl:1 ", $sformatf("Addr 0x%0x isn't size aligned to data arsize :0x%0d Bytes", addr,tmp_addr_pkt.awsize))
    end

    tmp_q = {};
    <% if(obj.useCmc) { %>
    if(lookup_en)begin
      tmp_q = wtt_q.find_index with (((item.lookupExpd ? (item.lookupSeen == 1):(item.lookupSeen == 0))||item.isEvict) && 
                                    (beat_aligned(axi4_addr_trans_addr(item.cache_addr)) == beat_aligned(addr)) && 
                                    security_match(item.security, awsecurity) && 
                                    ((item.AXI_write_data_expd == 1) && (item.AXI_write_data_recd == 0)));
    end
    else begin
      tmp_q = wtt_q.find_index with (beat_aligned(axi4_addr_trans_addr(item.cache_addr)) == beat_aligned(addr) && 
                                     security_match(item.security, awsecurity) && 
                                      item.DTW_req_recd &&
                                     (item.isCoh ? 1 : item.STR_req_recd ) &&
                                     ((item.AXI_write_data_expd == 1) && (item.AXI_write_data_recd == 0)));
                                  
      tmp_q_all = tmp_q;
      tmp_q_nc = wtt_q.find_index with (beat_aligned(axi4_addr_trans_addr(item.cache_addr)) == beat_aligned(addr) && 
                                     security_match(item.security, awsecurity) && 
                                      item.DTW_req_recd &&
                                     !item.isCoh && 
                                      item.STR_req_recd  &&
                                     ((item.AXI_write_data_expd == 1) && (item.AXI_write_data_recd == 0)));
      if(tmp_q.size()>1)begin
        tmp_q = {};
        tmp_q = wtt_q.find_index with ((beat_aligned(axi4_addr_trans_addr(item.cache_addr)) == beat_aligned(addr)) && 
                                       security_match(item.security, awsecurity) &&
                                       (item.isCoh ? 1 : item.STR_req_recd ) &&
                                       (item.isCoh ? 1 : item.CMD_rsp_recd_rtl ) &&
                                       ((item.AXI_write_data_expd == 1) && (item.AXI_write_data_recd == 0)));
      end
    end
    <% } else { %>
    tmp_q = wtt_q.find_index with (beat_aligned(axi4_addr_trans_addr(item.cache_addr)) == beat_aligned(addr) && 
                                   security_match(item.security, awsecurity) && 
                                    item.DTW_req_recd &&
                                   (item.isCoh ? 1 : item.STR_req_recd ) &&
                                   ((item.AXI_write_data_expd == 1) && (item.AXI_write_data_recd == 0)));
                                 

    if(tmp_q.size()>1)begin
      tmp_q = {};
      tmp_q = wtt_q.find_index with ((beat_aligned(axi4_addr_trans_addr(item.cache_addr)) == beat_aligned(addr)) && 
                                     security_match(item.security, awsecurity) &&
                                     (item.isCoh ? 1 : item.STR_req_recd ) &&
                                     (item.isCoh ? 1 : item.CMD_rsp_recd_rtl ) &&
                                     ((item.AXI_write_data_expd == 1) && (item.AXI_write_data_recd == 0)));
    end
    <% } %>

    if(tmp_q.size  == 0) begin
      `uvm_error("<%=obj.BlockId%>:processwChnl:2", $sformatf("Cache Addr matching AXI awaddr=0x%x, security :%0b  beat_aligned = 0x%x not found", addr,awsecurity,beat_aligned(addr)))
    end
    else begin
      `uvm_info("<%=obj.BlockId%>:processwChnl:2", $sformatf("write data found match in write addr queue tmp_q=%0d",$size(tmp_q)), UVM_MEDIUM)
      match = 0;
      if(!addr_space_mixed) begin
        if(tmp_q.size()>1)begin
          <% if(obj.useCmc) { %>
          if(lookup_en)begin
            if(!wtt_q[tmp_q[0]].isEvict)begin
               oldest = wtt_q[tmp_q[0]].t_lookup;
            end
            else begin
               oldest = wtt_q[tmp_q[0]].t_creation;
            end
            foreach (tmp_q[i]) begin
              if(!wtt_q[tmp_q[i]].isEvict)begin
                if(wtt_q[tmp_q[i]].t_lookup < oldest) begin
                  oldest = wtt_q[tmp_q[i]].t_lookup;
                  match = i;
                end
              end
              else begin
                if(wtt_q[tmp_q[i]].t_creation < oldest) begin
                  oldest = wtt_q[tmp_q[i]].t_creation;
                  match = i;
                end
              end
            end
          end
          else begin
            oldest = wtt_q[tmp_q[0]].t_creation;
            foreach (tmp_q[i]) begin
              if(wtt_q[tmp_q[i]].t_creation < oldest) begin
                oldest = wtt_q[tmp_q[i]].t_creation;
                match = i;
              end
            end
            if(tmp_q_all.size > 1 && tmp_q_nc.size > 0 && tmp_q_all.size != tmp_q_nc.size) begin
              foreach(tmp_q[i]) begin
                //If address in WTT is live with both coh+noncoh transactions, ordering is not guaranteed
                wtt_q[tmp_q[i]].axi_write_data_pkt  = m_packet;
                wtt_q[tmp_q[i]].axi_write_addr_pkt  = tmp_addr_pkt;
                aw_flag  = wtt_q[tmp_q[i]].gen_exp_axi__aw(tmp_addr_pkt).do_compare_pkts(tmp_addr_pkt);
                w_flag   = wtt_q[tmp_q[i]].gen_exp_axi__w(m_packet).do_compare_pkts_per_byte(m_packet);
                if(aw_flag && w_flag) begin
                  match = i;
                  break;
                end
                wtt_q[tmp_q[i]].axi_write_data_pkt  = null;
                wtt_q[tmp_q[i]].axi_write_addr_pkt  = null;
              end
            end
          end
          <% }else { %>
          oldest = wtt_q[tmp_q[0]].t_creation;
          foreach (tmp_q[i]) begin
            if (wtt_q[tmp_q[i]].t_creation < oldest) begin
              oldest = wtt_q[tmp_q[i]].t_creation;
              match = i;
            end
          end
          <% } %>
        end
      end 
      else begin                          //addr space mixed
        foreach(tmp_q[i]) begin
          wtt_q[tmp_q[i]].axi_write_data_pkt  = m_packet;
          wtt_q[tmp_q[i]].axi_write_addr_pkt  = tmp_addr_pkt;
          aw_flag  = wtt_q[tmp_q[i]].gen_exp_axi__aw(tmp_addr_pkt).do_compare_pkts(tmp_addr_pkt);
          w_flag   = wtt_q[tmp_q[i]].gen_exp_axi__w(m_packet).do_compare_pkts_per_byte(m_packet);
          if(aw_flag && w_flag) begin
               match = i;
               break;
          end
          wtt_q[tmp_q[i]].axi_write_data_pkt  = null;
          wtt_q[tmp_q[i]].axi_write_addr_pkt  = null;
        end
      end
      wtt_q[tmp_q[match]].axi_write_data_pkt  = m_packet;
      wtt_q[tmp_q[match]].axi_write_addr_pkt  = tmp_addr_pkt;
      wtt_q[tmp_q[match]].AXI_write_addr_recd = 1;
      wtt_q[tmp_q[match]].AXI_write_data_recd = 1;
      wtt_q[tmp_q[match]].t_aw = $time;
      wtt_q[tmp_q[match]].t_w  = $time;
      wtt_q[tmp_q[match]].t_w1  = m_packet.t_wtime[0];
      wtt_q[tmp_q[match]].t_latest_update = $time;
      wtt_q[tmp_q[match]].print_entry();
      `uvm_info("DMI_SCB", $psprintf("DMI_UID:%0d: AWADDR: %s ", wtt_q[tmp_q[match]].txn_id, tmp_addr_pkt.sprint_pkt()), UVM_LOW);
      `uvm_info("DMI_SCB", $psprintf("DMI_UID:%0d: WDATA: %s ", wtt_q[tmp_q[match]].txn_id,  m_packet.sprint_pkt()), UVM_LOW);

      ok = wtt_q[tmp_q[match]].gen_exp_axi__aw(tmp_addr_pkt).do_compare_pkts(tmp_addr_pkt);
      if(!ok) `uvm_error($sformatf("<%=obj.BlockId%>:processwChnl"), $sformatf("axi_write_addr_pkt  mismatch: see ERROR above queue print"))

      ok = wtt_q[tmp_q[match]].gen_exp_axi__w(m_packet).do_compare_pkts_per_byte(m_packet);
      if(!ok && !uncorr_wrbuffer_err) `uvm_error($sformatf("<%=obj.BlockId%>:processwChnl"), $sformatf("axi_write_data_pkt mismatch: see ERROR above queue print"))

      /*if(wtt_q[tmp_q[match]].isNcWr && exclusive_flg)begin
        if(wtt_q[tmp_q[match]].cmd_req_pkt.smi_es)begin
           axi_awid_t my_awid;
           my_awid = ({WAXID{1'b0}} | (wtt_q[tmp_q[match]].cmd_req_pkt.smi_mpf2[WSMIMPF2-2:0]<<WSMINCOREUNITID) | (wtt_q[tmp_q[match]].cmd_req_pkt.smi_src_id>>WSMINCOREPORTID));
          if(my_awid != wtt_q[tmp_q[match]].axi_write_addr_pkt.awid)begin
            `uvm_error("<%=obj.BlockId%>:processWChnl", $sformatf("awid :%0x not matching with smi_mpf2 :%0x for NcWr Exclusive",wtt_q[tmp_q[match]].axi_write_addr_pkt.awid,my_awid))
          end
        end
      end*/
      if ($test$plusargs("wtt_time_out_error_test") && wtt_q[tmp_q[match]].isCoh == 0 && wtt_q[tmp_q[match]].cmd_req_pkt != null && wtt_q[tmp_q[match]].cmd_req_pkt.isCmdNcWrMsg()) begin
        wtt_time_out_err_test_sec_q.push_back(wtt_q[tmp_q[match]].cmd_req_pkt.smi_ns);
        wtt_time_out_err_test_addr_q.push_back(wtt_q[tmp_q[match]].cmd_req_pkt.smi_addr);
      end else if ($test$plusargs("wtt_time_out_error_test") && wtt_q[tmp_q[match]].isCoh && wtt_q[tmp_q[match]].rb_req_pkt != null) begin
        wtt_time_out_err_test_sec_q.push_back(wtt_q[tmp_q[match]].rb_req_pkt.smi_ns);
        wtt_time_out_err_test_addr_q.push_back(wtt_q[tmp_q[match]].rb_req_pkt.smi_addr);
      end
    end // else: !if(tmp_q.size > 1)
  end // else: !if(wr_addr_q.size() === 0)
  `ifndef FSYS_COVER_ON
  cov.collect_axi_write_data_pkt(m_packet);
  `endif
endfunction // processWChnl
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Update dtwtable entry with AXI_write_resp_channel
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function void dmi_scoreboard::processBChnl(axi4_write_resp_pkt_t m_pkt);
  int tmp_q[$],tmp_q2[$],tmp_q3[$],tmp_q4[$];
  int match;
  uvm_event ev_bresp = ev_pool.get("ev_bresp");
  time oldest;
  axi4_write_resp_pkt_t m_packet;
  m_packet = new();
  m_packet.copy(m_pkt);

  match = 0;
  tmp_q = {};

  `uvm_info("<%=obj.BlockId%>:processBChnl", $sformatf("%1p",m_packet), UVM_MEDIUM)
   
  <% if(obj.useCmc) { %>
  tmp_q = wtt_q.find_index with (((item.lookupExpd ? (item.lookupSeen == 1):(item.lookupSeen == 0))||item.isEvict) && 
                                 (item.AXI_write_addr_recd == 1 && item.AXI_write_data_recd == 1) && 
                                 ((item.axi_write_addr_pkt.awid == m_packet.bid) && (item.AXI_write_resp_recd == 0)));
  <% } else { %>
  tmp_q = wtt_q.find_index with ((item.AXI_write_addr_recd == 1 && item.AXI_write_data_recd == 1) && 
                                 ((item.axi_write_addr_pkt.awid == m_packet.bid) && (item.AXI_write_resp_recd == 0)));
  <% } %>


  if(tmp_q.size == 0) begin
    `uvm_error("<%=obj.BlockId%>:processBChnl", $sformatf("AXI AWID matching AXI BID not found"))
  end
  else begin
    if(tmp_q.size > 1) begin
      `uvm_info("<%=obj.BlockId%>:processBChnl", $sformatf("AXI AWID matches AXI BID for multiple outstanding requests"), UVM_MEDIUM)
      foreach(tmp_q[i])begin
       `uvm_info("<%=obj.BlockId%>:processBChnl", $sformatf("%1p t_aw:%t",wtt_q[tmp_q[i]].axi_write_addr_pkt,wtt_q[tmp_q[i]].t_aw), UVM_MEDIUM)
      end
      oldest = wtt_q[tmp_q[0]].t_aw;
      foreach (tmp_q[i]) begin
        if(wtt_q[tmp_q[i]].t_aw < oldest) begin
          oldest = wtt_q[tmp_q[i]].t_aw;
          match = i;
        end
      end
    end
    // Extra check for hnt entry that arrived at this clock cycle and matches response
    wtt_q[tmp_q[match]].axi_write_resp_pkt = m_packet;
    wtt_q[tmp_q[match]].AXI_write_resp_recd = 1;
    wtt_q[tmp_q[match]].t_b = $time;
    wtt_q[tmp_q[match]].t_latest_update = $time;
    wtt_q[tmp_q[match]].print_entry();
    `uvm_info("DMI_SCB", $psprintf("DMI_UID:%0d: BRESP: %s", wtt_q[tmp_q[match]].txn_id, m_packet.sprint_pkt()), UVM_LOW);
    `ifndef FSYS_COVER_ON
     cov.t_wr_data = wtt_q[tmp_q[match]].axi_write_data_pkt.t_pkt_seen_on_intf;  
     cov.t_wr_addr = wtt_q[tmp_q[match]].axi_write_addr_pkt.t_pkt_seen_on_intf;
     `endif
    //Pass awaddr to CSR sequence when bresp = 2/3
    if(m_packet.bresp == 2 || m_packet.bresp == 3) begin
      ev_bresp.trigger(wtt_q[tmp_q[match]]);
    end
  end
  `ifndef FSYS_COVER_ON
  cov.collect_axi_write_resp_pkt(m_packet);
  `endif
  //#Check.DMI.v3.FlushRspWaitsTillAllOutstandingBresp 
  tmp_q2 = {};
  tmp_q2 = wtt_q.find_index with ((cl_aligned(item.cache_addr) == cl_aligned(wtt_q[tmp_q[match]].cache_addr)) && 
                                   security_match(item.security, wtt_q[tmp_q[match]].security) && 
                                   (item.AXI_write_resp_expd == 1) && 
                                   (item.AXI_write_resp_recd == 0));
 
  tmp_q3 = {};
  tmp_q3 = rtt_q.find_index with ((cl_aligned(item.cache_addr) == cl_aligned(wtt_q[tmp_q[match]].cache_addr)) && 
                                   security_match(item.security, wtt_q[tmp_q[match]].security) && 
                                   (item.wrOutstandingFlag == 1));

  wtt_q[tmp_q[match]].wrOutstanding = 0;
  foreach(tmp_q3[i])begin
    rtt_q[tmp_q3[i]].wrOutstandingcnt--;
    if(!rtt_q[tmp_q3[i]].wrOutstandingcnt)begin
      rtt_q[tmp_q3[i]].wrOutstandingFlag = 0;
    end
  end
 
  if(wtt_q[tmp_q[match]].wrOutstanding == 0) begin
    updateWttentry(wtt_q[tmp_q[match]],tmp_q[match]);
  end
endfunction // processBChnl
<% if(obj.useCmc){ %>
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Function: write_ccp_din_chnl 
// Purpose: 
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function void dmi_scoreboard::write_ccp_wr_data_chnl(ccp_wr_data_pkt_t m_pkt);
  ccp_wr_data_pkt_t m_packet;
  m_packet = new();
  m_packet.copy(m_pkt);
  `uvm_info("dmi_Sb:write_ccp_wr_data_chnl", $sformatf("%t: ccp_wr_data_pkt: %s", $time, m_pkt.sprint_pkt()), UVM_MEDIUM);
  if(!uncorr_wrbuffer_err) begin
    processCacheWrData(m_packet);
  end
endfunction
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Function: write_ccp_ctrl_chnl 
// Purpose: 
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function void dmi_scoreboard::write_ccp_ctrl_chnl(ccp_ctrl_pkt_t m_pkt);
  ccp_ctrl_pkt_t m_packet;
  dmi_scb_txn txn;
  int tmp_q[$],tmp_q1[$],tmp_q2[$],tmp_q3[$];
  int index;
  bit sp_txn;
  replay_q  tmp_rply_pkt;
  uvm_event ev_nackce_nackuce = ev_pool.get("ev_nackce_nackuce");
  m_packet = new();
  m_packet.copy(m_pkt);
  
  if(!uncorr_wrbuffer_err) begin
    `uvm_info("<%=obj.BlockId%>:write_ccp_ctrl_chnl", $sformatf("%t: ccp_ctrl_pkt_t: %s rply_q.size :%0d ", $time, m_packet.sprint_pkt(), rply_q.size()), UVM_MEDIUM);
    <%if(obj.DmiInfo[obj.Id].ccpParams.RepPolicy == 'PLRU') { %>
    if(m_pkt.rp_update) begin
      valid_ways = ~m_pkt.waypbusy_vec;
      victim_way = m_pkt.wayn;
      if($countones(valid_ways) != N_CCP_WAYS)begin
        `uvm_info("<%=obj.BlockId%>:write_ccp_ctrl_chnl",$sformatf("PLRU_EVICT - Valid ways must be all 1s while evicting a victim %0b %0d !=%0d", valid_ways,$countones(valid_ways),N_CCP_WAYS),UVM_HIGH)
      end
      `ifndef FSYS_COVER_ON
      cov.collect_ccp_plru_eviction(victim_way,ncoreConfigInfo::get_set_index(m_packet.addr,<%=obj.DmiInfo[obj.Id].FUnitId%>));
      `endif
    end
    <%}%>

    if(m_packet.toReplay) begin
      sb_stall_if.perf_count_events["Cache_replay"].push_back(1);
    end

    if(m_packet.noways2alloc) begin
      sb_stall_if.perf_count_events["Cache_no_ways_to_allocate"].push_back(1);
    end

    if (m_packet.nackce || m_packet.nackuce) begin
      ev_nackce_nackuce.trigger(m_packet);
    end

    if(last_recycle && !m_packet.toReplay)begin
      if(!m_packet.isRecycleFailed) begin
        last_recycle= 0;
        `uvm_info("<%=obj.BlockId%>:write_ccp_ctrl_chnl",$sformatf("Recycle transaction addr:%0h overriding isCoh:%0b with last_coh:%0b",m_pkt.addr,m_pkt.isCoh,last_coh),UVM_DEBUG)
        m_packet.isCoh = last_coh;
      end
      else begin
        `uvm_info("<%=obj.BlockId%>:write_ccp_ctrl_chnl",$sformatf("Recycle transaction failure addr:%0h | Retaining isCoh:%0b and last_recycle:1",m_pkt.addr,last_coh),UVM_DEBUG)
      end
    end
    else if(m_packet.isReplay && !m_packet.toReplay)begin
      `uvm_info("<%=obj.BlockId%>:write_ccp_ctrl_chnl", $sformatf("Marked as being replayed addr:%0x | rply_q(size:%0d)",m_packet.addr, rply_q.size()), UVM_HIGH)
      if(rply_q.size()>0 && m_packet.isRplyVld && (m_packet.msgType_p0 inside {DTW_DATA_CLN,DTW_DATA_PTL,DTW_DATA_DTY,DTW_MRG_MRD_UCLN,DTW_MRG_MRD_UDTY,DTW_MRG_MRD_INV}))begin

        tmp_q3 = rply_q.find_index with (item.replay_addr  == m_packet.addr &&
                                         item.ns           == m_packet.security &&
                                         item.msgType      == m_packet.msgType_p0);
        if(!tmp_q3.size())begin
          `uvm_error("<%=obj.BlockId%>:write_ccp_ctrl_chnl",$sformatf("replay_q addr not matching with ccp packet"));
        end
        else begin
          `uvm_info("<%=obj.BlockId%>:write_ccp_ctrl_chnl", $sformatf("Found addr:%0x in rply_q(size:%0d)",m_packet.addr, rply_q.size()-1), UVM_HIGH)
          m_packet.isCoh   = rply_q[tmp_q3[0]].isCoh;
          rply_q.delete(tmp_q3[0]);
        end
      end
    end
    sp_txn = 0;
    <% if(obj.useCmc && obj.DmiInfo[obj.Id].ccpParams.useScratchpad){%>
    if((m_packet.security == sp_ns) && isSpAddr(m_packet.addr)) begin
      `uvm_info("<%=obj.BlockId_%>DMI_SCOREBOARD", $sformatf("this is a sp txn on ccp control channel lower_sp_addr:0x%0h upper_sp_addr:0x%0h cache_addr:0x%0h cache_addr_i:0x%0h NS:%0b",
                                                                                                      lower_sp_addr,upper_sp_addr,(m_packet.addr>>CACHELINE_OFFSET),ncoreConfigInfo::gen_spad_intrlv_rmvd_addr(m_packet.addr,<%=obj.DmiInfo[obj.Id].nUnitId%>),sp_ns), UVM_MEDIUM)
      sp_txn = 1;
    end
    <% } %>

    // if (!sp_txn) begin
    //    `uvm_error("<%=obj.BlockId%>:write_ccp_ctrl_chnl",$sformatf("A transaction is looking up in cache even when lookup_en is 0"));
    // end

    //#Check.DMI.Concerto.v3.0.AllocDisbale
    if(!alloc_en && m_packet.alloc) begin
      `uvm_error("<%=obj.BlockId%>:write_ccp_ctrl_chnl",$sformatf("A transaction is allocated in cache even when alloc_en is 0"));
    end

    if(sp_txn)begin
      if (sp_txn && (m_packet.currstate != IX) && !uncorr_tag_err) begin
         `uvm_error("<%=obj.BlockId%>:write_ccp_ctrl_chnl",$sformatf("ccp current state:%s is not IX for the sp txn addr",m_packet.currstate));
      end
      if(m_packet.alloc |
         m_packet.rd_data |
         m_packet.wr_data |
         m_packet.bypass |
         m_packet.tagstateup |
         m_packet.setway_debug |
         m_packet.rp_update) begin
         `uvm_info("<%=obj.BlockId%>:write_ccp_ctrl_chnl", $sformatf("%1p",m_packet), UVM_LOW)
         `uvm_error("<%=obj.BlockId%>:write_ccp_ctrl_chnl",
                    $sformatf(" NEW CHECK {allocate_p2|rd_data|wr_data|bypass|tagstateup|setwaydebug|rp_update}:%0b%0b%0b %0b%0b%0b %0b  expd: all zeros",
                              m_packet.alloc,
                              m_packet.rd_data,
                              m_packet.wr_data,
                              m_packet.bypass,
                              m_packet.tagstateup,
                              m_packet.setway_debug,
                              m_packet.rp_update))
      end
    end

    // if it's a scratchpad txn, then, no need to execute the further code
    if (sp_txn) return;

    //if(m_pkt.msgType_p0 == DTW_DATA_CLN && m_pkt.nacknoalloc && m_packet.nack && !m_packet.isRecycle && !m_packet.isRecycle_p1 && !m_packet.toReplay) begin
    if(m_packet.isRecycleFailed) `uvm_info("<%=obj.BlockId%>:write_ccp_ctrl_chnl", $sformatf("Recycle failed recorded on addr:%0x", m_packet.addr),UVM_MEDIUM)
    if(m_pkt.msgType_p0 == DTW_DATA_CLN && m_pkt.nacknoalloc && m_packet.nack && !m_packet.toReplay ) begin
      `uvm_info("<%=obj.BlockId%>:write_ccp_ctrl_chnl",$sformatf("Hit condition for addr:%0h", m_packet.addr),UVM_DEBUG);
    end
    
    if(m_pkt.msgType_p0 == DTW_DATA_CLN && m_pkt.nacknoalloc && m_packet.nack && !m_packet.toReplay && !WrDataClnPropagateEn) begin
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // If nacknoAlloc is asserted for DTW_DATA_CLN it will be dropped except when DMIUWRDATACLN is enabled to write through data to memory 
    // As per implementation
    // TB should not retire DTW_DATA_CLN at p2 if it was already sent to replay at p1 (m_packet.toReplay indicates if the request is put in replay queue)
    // If a request in p2 is recycled then the request in p1 goes to replay queue (m_packet.isRecycle_p1 indicates if the previous request got recycled)
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
      tmp_q1 = {};
      tmp_q1 = wtt_q.find_index with ( item.dtw_msg_type == DTW_DATA_CLN &&
                                    (item.cache_addr == m_packet.addr) && 
                                    (item.security   == m_packet.security) && 
                                    (item.lookupExpd == 1) && 
                                    (item.lookupSeen == 0));
      if(tmp_q1.size()>0)begin
        wtt_q[tmp_q1[0]].lookupSeen = 1;
        wtt_q[tmp_q1[0]].t_lookup   = $time;
        txn = wtt_q[tmp_q1[0]];
        `uvm_info("DMI_SCB", $psprintf("DMI_UID:%0d: WRITE_CCP_CTRL_CHNL: %s", txn.txn_id, m_pkt.sprint_pkt()), UVM_LOW)
        updateWttentry(txn,tmp_q1[0]);
      end
    end
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // As per discussion with Steve And Boon cache state is valid with Nack, and Dmi Controler will drop DTW_DATA_CLN
    // when addr is hit in cache with nack
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////
    else if(!(m_packet.toReplay |  m_packet.nack | m_packet.isRecycleFailed) || (m_packet.nack && !m_packet.toReplay && !m_packet.isRecycleFailed && (m_packet.msgType_p0 == DTW_DATA_CLN) && (m_packet.currstate != IX || (ClnWrAllocDisable && !WrDataClnPropagateEn) || (WrAllocDisable &&!WrDataClnPropagateEn)))) begin
    
      index = ncoreConfigInfo::get_set_index(m_packet.addr,<%=obj.DmiInfo[obj.Id].FUnitId%>); 
      
      if(m_packet.evictvld) begin
        sb_stall_if.perf_count_events["Cache_eviction"].push_back(1);
      end
    
      // choose call based on rd or wr
      if(m_packet.isMntOp)begin
        `uvm_info("<%=obj.BlockId%>:write_ccp_ctrl_chnl",$sformatf("calling processMaintop"),UVM_MEDIUM);
         processMaintop(m_packet);
      end
      else if(isDtwMsg(m_packet.msgType_p0) || isCmdNcWrMsg(m_packet.msgType_p0))begin
        //perfmon events
        if(m_packet.currstate != IX)
          sb_stall_if.perf_count_events["Cache_write_hit"].push_back(1);
        else 
          sb_stall_if.perf_count_events["Cache_write_miss"].push_back(1);
        //
        `uvm_info("<%=obj.BlockId%>:write_ccp_ctrl_chnl",$sformatf("calling processCacheWr"),UVM_MEDIUM);
        processCacheWr(m_packet);
        <% if(obj.testBench == "dmi" && obj.useCmc) { %>
        delete_mnt_op_cache_line(m_packet);
        <% } %>
      end
      else begin
        `uvm_info("<%=obj.BlockId%>:write_ccp_ctrl_chnl",$sformatf("calling processCacheRd"),UVM_MEDIUM);
        if(lookup_en)begin
          processCacheRd(m_packet);
          <% if(obj.testBench == "dmi" && obj.useCmc) { %>
          delete_mnt_op_cache_line(m_packet);
          <% } %>
        end
      end
    end
    else if((m_packet.nack && !m_packet.toReplay)|| (m_packet.isRecycleFailed))begin
      last_recycle = 1;
      if(!m_packet.isRecycleFailed) begin
        last_coh     = m_packet.isCoh;
        `uvm_info("<%=obj.BlockId%>:write_ccp_ctrl_chnl",$sformatf("Recycle transaction addr:%0h isCoh:%0b",m_pkt.addr,last_coh),UVM_DEBUG)
      end
      else begin
        `uvm_info("<%=obj.BlockId%>:write_ccp_ctrl_chnl",$sformatf("Recycle transaction failure addr:%0h | Retaining isCoh:%0b",m_pkt.addr,last_coh),UVM_DEBUG)
      end
    end
    else if(m_packet.toReplay | m_packet.nack) begin
      if((m_packet.toReplay && !m_packet.isRplyVld) && (m_packet.msgType_p0 inside {DTW_DATA_CLN,DTW_DATA_PTL,DTW_DATA_DTY,DTW_MRG_MRD_UCLN,DTW_MRG_MRD_UDTY,DTW_MRG_MRD_INV})) begin
        replay_q  rply_pkt = new();
        rply_pkt.replay_addr = m_packet.addr;
        rply_pkt.ns          = m_packet.security;
        rply_pkt.isCoh       = m_packet.isCoh;
        rply_pkt.msgType     = m_packet.msgType_p0;
        rply_pkt.t_create     = $time;
        `uvm_info("<%=obj.BlockId%>:write_ccp_ctrl_chnl",$sformatf("pushing rply_pkt :%p",rply_pkt),UVM_MEDIUM);
        rply_q.push_back(rply_pkt); 
      end
    end
    if(m_packet.evictvld == 1 && m_packet.rd_data == 1) begin
      processEvictAddr(m_packet);
    end
  end //wrbuffer_uncorr_error

  `ifndef FSYS_COVER_ON
  cov.collect_ccp_ctrl_pkt(m_packet);
  cov.collect_ccp_alloc_field(alloc_en, ClnWrAllocDisable, DtyWrAllocDisable, RdAllocDisable, WrAllocDisable, WrDataClnPropagateEn);
  `endif
endfunction
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Function: write_ccp_fill_ctrl_chnl 
// Purpose: 
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function void dmi_scoreboard::write_ccp_fill_ctrl_chnl(ccp_fillctrl_pkt_t m_pkt);
  ccp_fillctrl_pkt_t m_packet;
 if(!uncorr_wrbuffer_err) begin
   m_packet = new();
   m_packet.copy(m_pkt);

   processCacheFillCtrl(m_packet);
 end //wrbuffer_uncorr_error
endfunction
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Function: write_ccp_fill_ctrl_chnl 
// Purpose: 
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function void dmi_scoreboard::write_ccp_fill_data_chnl(ccp_filldata_pkt_t m_pkt);
  ccp_filldata_pkt_t m_packet;
 if(!uncorr_wrbuffer_err) begin
   m_packet = new();
   m_packet.copy(m_pkt);
   if(m_pkt.scratchpad) begin
     m_packet.addr = ncoreConfigInfo::gen_full_cache_addr_from_spad_addr(m_pkt.addr,<%=obj.DmiInfo[obj.Id].nUnitId%>);
   end
   processCacheFillData(m_packet);
 end //wrbuffer_uncorr_error
endfunction
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Function: write_ccp_dout_chnl 
// Purpose: 
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function void dmi_scoreboard::write_ccp_rd_rsp_chnl(ccp_rd_rsp_pkt_t m_pkt);
  ccp_rd_rsp_pkt_t m_packet;
 if(!uncorr_wrbuffer_err) begin
   m_packet = new();
   m_packet.copy(m_pkt);

   processCacheRdRsp(m_packet);
 end //wrbuffer_uncorr_error
endfunction
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Function: write_ccp_dout_chnl 
// Purpose: 
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function void dmi_scoreboard::write_ccp_evict_chnl(ccp_evict_pkt_t m_pkt);
  ccp_evict_pkt_t m_packet;
 if(!uncorr_wrbuffer_err) begin
   m_packet = new();
   m_packet.copy(m_pkt);

   processEvictData(m_packet);
 end //wrbuffer_uncorr_error
endfunction
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Function: write_ccp_sp_ctrl_chnl 
// Purpose: 
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
<% if(obj.useCmc && obj.DmiInfo[obj.Id].ccpParams.useScratchpad) { %>
function void dmi_scoreboard::write_ccp_sp_ctrl_chnl(ccp_sp_ctrl_pkt_t m_pkt);
  ccp_sp_ctrl_pkt_t m_packet;
  if(!uncorr_wrbuffer_err) begin
    m_packet = new();
    m_packet.copy(m_pkt);
    processSPCtrl(m_packet);
  end //wrbuffer_uncorr_error
  `ifndef FSYS_COVER_ON
  cov.collect_sp_ctrl_pkt(m_packet);
  `endif
endfunction
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Function: write_ccp_sp_input_chnl 
// Purpose: 
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function void dmi_scoreboard::write_ccp_sp_input_chnl(ccp_sp_wr_pkt_t m_pkt);
  ccp_sp_wr_pkt_t m_packet;
 if(!uncorr_wrbuffer_err) begin
   m_packet = new();
   m_packet.copy(m_pkt);

   processSPWr(m_packet);
 end //wrbuffer_uncorr_error
endfunction
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Function: write_ccp_sp_output_chnl 
// Purpose: 
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function void dmi_scoreboard::write_ccp_sp_output_chnl(ccp_sp_output_pkt_t m_pkt);
  ccp_sp_output_pkt_t m_packet;
 if(!uncorr_wrbuffer_err) begin
   m_packet = new();
   m_packet.copy(m_pkt);

   processSPOutput(m_packet);
 end //wrbuffer_uncorr_error
endfunction
<% } %>
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Function: write_ccp_sp_output_chnl 
// Purpose: 
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function void dmi_scoreboard::write_apb_chnl(apb_pkt_t m_pkt);
  apb_pkt_t m_packet;
  m_packet = new();
  m_packet.copy(m_pkt);
    
  processApbReq(m_packet);
endfunction
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Process the Read Request
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function void dmi_scoreboard::processCacheRd(ccp_ctrl_pkt_t cache_ctrl_pkt);
  int tmp_q[$],tmp_q1[$],tmp_q2[$],tmp_q3[$],tmp_q4[$],tmp_q5[$],
               tmp_q6[$],tmp_q7[$],tmp_q8[$],cov_q[$],tmp_q9[$],tmp_q2_check[$];
  bit [8:0] cachevector;
  dmi_scb_txn txn;
  dmi_fill_addr_inflight_t fill_addr_inflight_pkt;
  ccp_ctrlop_waybusy_vec_t m_busyway;
  int aiu_no;
  bit agent_id_match;
  int match; 
  time oldest;

  `uvm_info("dmi_Sb:processCacheRd", $sformatf("%t: ccp_ctrl_pkt_t: %s", $time,  cache_ctrl_pkt.sprint_pkt()), UVM_MEDIUM);
  match = 0;
  if(isNcCohCmd(cache_ctrl_pkt.msgType_p0))begin
    tmp_q = {};
    tmp_q = rtt_q.find_index with (!(item.isCoh) &&
                                   (beat_aligned((item.cache_addr)) == beat_aligned(cache_ctrl_pkt.addr)) && 
                                   (item.security == cache_ctrl_pkt.security) && 
                                   (item.CMD_rsp_recd_rtl == 1) && 
                                   (item.lookupExpd == 1) && 
                                   (item.lookupSeen == 0));
    if(tmp_q.size()>1)begin
      oldest = rtt_q[tmp_q[0]].t_creation ;
      foreach (tmp_q[i]) begin
        if (rtt_q[tmp_q[i]].t_creation < oldest) begin
          oldest = rtt_q[tmp_q[i]].t_creation;
          match = i;
        end
      end
    end
    //  if(tmp_q.size()>0)begin
    //    if((rtt_q[tmp_q[match]].isCmdPref) && !(cache_ctrl_pkt.msgType_p0 == CMD_PREF))begin
    //      tmp_q = {};
    //      tmp_q = rtt_q.find_index with (!(item.isCmdPref) &&
    //                                     (beat_aligned((item.cache_addr)) == beat_aligned(cache_ctrl_pkt.addr)) && 
    //                                     (item.security == cache_ctrl_pkt.security) && 
    //                                     (item.lookupExpd == 1) && 
    //                                     (item.lookupSeen == 0));
    //    end
    //    else if(cache_ctrl_pkt.msgType_p0 == CMD_PREF)begin
    //      tmp_q = {};
    //      tmp_q = rtt_q.find_index with (item.isCmdPref &&
    //                                     (beat_aligned((item.cache_addr)) == beat_aligned(cache_ctrl_pkt.addr)) && 
    //                                     (item.security == cache_ctrl_pkt.security) && 
    //                                     (item.lookupExpd == 1) && 
    //                                     (item.lookupSeen == 0));
    //    end
    //  end
  end
  else begin
    tmp_q = {};
    tmp_q = rtt_q.find_index with (item.isCoh &&
                                   !item.isDtwMrgMrd &&
                                   (beat_aligned((item.cache_addr)) == beat_aligned(cache_ctrl_pkt.addr)) && 
                                   (item.security == cache_ctrl_pkt.security) && 
                                   (item.lookupExpd == 1) && 
                                   (item.lookupSeen == 0));
    if(tmp_q.size()>1)begin
      if((rtt_q[tmp_q[match]].smi_msg_type == MRD_PREF) && !(cache_ctrl_pkt.msgType_p0 == MRD_PREF))begin
        tmp_q = {};
        tmp_q = rtt_q.find_index with (!(item.smi_msg_type == MRD_PREF) &&
                                       (beat_aligned((item.cache_addr)) == beat_aligned(cache_ctrl_pkt.addr)) && 
                                       (item.security == cache_ctrl_pkt.security) && 
                                       (item.MRD_req_recd_rtl == 1) && 
                                       (item.lookupExpd == 1) && 
                                       (item.lookupSeen == 0));
      end
      else if(cache_ctrl_pkt.msgType_p0 == MRD_PREF)begin
        tmp_q = {};
        tmp_q = rtt_q.find_index with ( item.smi_msg_type == MRD_PREF &&
                                       (beat_aligned((item.cache_addr)) == beat_aligned(cache_ctrl_pkt.addr)) && 
                                       (item.security == cache_ctrl_pkt.security) && 
                                       (item.MRD_req_recd_rtl == 1) && 
                                       (item.lookupExpd == 1) && 
                                       (item.lookupSeen == 0));
         if(!tmp_q.size())begin
           tmp_q = {};
           tmp_q = rtt_q.find_index with ( item.smi_msg_type == MRD_PREF &&
                                          (beat_aligned((item.cache_addr)) == beat_aligned(cache_ctrl_pkt.addr)) && 
                                          (item.security == cache_ctrl_pkt.security) && 
                                          (item.lookupExpd == 1) && 
                                          (item.lookupSeen == 0));
         end
         if(tmp_q.size()>1)begin
           oldest = rtt_q[tmp_q[0]].t_creation ;
           foreach (tmp_q[i]) begin
             if(rtt_q[tmp_q[i]].t_creation < oldest) begin
               oldest = rtt_q[tmp_q[i]].t_creation;
               match = i;
             end
           end
         end
      end
    end
  end

  tmp_q1 = wtt_q.find_index with ((item.AXI_write_addr_expd == 1) && 
                                  (item.AXI_write_addr_recd == 0) && 
                                  (item.lookupExpd === 1) && 
                                  (item.lookupSeen === 1));

  tmp_q5 = {};
  tmp_q5 = wtt_q.find_index with (((cl_aligned((item.cache_addr)) == cl_aligned(cache_ctrl_pkt.addr)) && 
                                    security_match(item.security,cache_ctrl_pkt.security)) && 
                                   ((item.lookupExpd ==1  && item.lookupSeen ==1) ||(item.isEvict == 1) ) && 
                                   item.AXI_write_resp_expd  &&
                                   !item.AXI_write_resp_recd ); 

  
  tmp_q7 = {};
  tmp_q7 = rtt_q.find_index with (item.isCoh &&
                                 (cl_aligned((item.cache_addr)) == cl_aligned(cache_ctrl_pkt.addr)) && 
                                 (item.security == cache_ctrl_pkt.security) && 
                                 (item.lookupExpd == 1) && 
                                 (item.lookupSeen == 0));

  if(tmp_q.size() >0)begin
    tmp_q8 = {};
    tmp_q8 = rtt_q.find_index with (item.smi_msg_type == MRD_PREF &&
                                   (cl_aligned((item.cache_addr)) == cl_aligned(cache_ctrl_pkt.addr)) && 
                                   (item.security == cache_ctrl_pkt.security) && 
                                   (item.lookupExpd == 1) && 
                                   (item.lookupSeen == 1) &&
                                   (item.fillExpd == 1) &&
                                   (item.fillSeen == 0));
  end

  //ordering check
  tmp_q9 = {};
  tmp_q9 = wtt_q.find_index with ((item.isCoh == rtt_q[tmp_q[match]].isCoh) &&
                                  (beat_aligned((item.cache_addr)) == beat_aligned(rtt_q[tmp_q[match]].cache_addr)) &&
                                  (item.security == rtt_q[tmp_q[match]].security) &&
                                  ((item.isCoh)? 1 : item.CMD_rsp_recd_rtl) &&
                                  (item.t_creation < rtt_q[tmp_q[match]].t_creation) &&
                                  (item.lookupExpd == 1) && 
                                  (item.lookupSeen == 0));
  if(tmp_q9.size() > 0) begin
    foreach(tmp_q9[i]) begin
      wtt_q[tmp_q9[i]].print_entry;
    end
    `uvm_error("<%=obj.BlockId%>:processCacheRd:ordercheck", $sformatf("read txn came on CCP ctrl channel before the above old write transaction"));
  end

  //#Check.DMI.Concerto.v3.0.MrdTable5and7
  cachevector = {cache_ctrl_pkt.alloc,cache_ctrl_pkt.rd_data,cache_ctrl_pkt.wr_data,
                 cache_ctrl_pkt.evictvld,cache_ctrl_pkt.bypass,cache_ctrl_pkt.rp_update,
                 cache_ctrl_pkt.tagstateup,cache_ctrl_pkt.setway_debug};
  `ifndef FSYS_COVER_ON
  cov.collect_ccp_rd_inflight(rtt_q, cache_ctrl_pkt);
  `endif
  if(cache_ctrl_pkt.alloc && cache_ctrl_pkt.nackuce) begin
    fill_addr_inflight_pkt.addr = cache_ctrl_pkt.addr;
    fill_addr_inflight_pkt.secu = cache_ctrl_pkt.security;
    fill_addr_inflight_pkt.wayn = cache_ctrl_pkt.wayn;
    update_index_way(fill_addr_inflight_pkt,1);
  end
  //#Check.DMI.Concerto.v3.0.DTWMrgMrdHit
  if(tmp_q.size() === 0) begin
    `uvm_info("<%=obj.BlockId%>:processCacheRd:1", $sformatf("%1p",cache_ctrl_pkt), UVM_LOW)
    print_rtt_q();
    `uvm_error("<%=obj.BlockId%>:processCacheRd:1","Above packet has no matching MRD/NC_RD")
  end
  else if (tmp_q7.size() > 1 && !(isAtomicMsg(cache_ctrl_pkt.msgType_p0) || (cache_ctrl_pkt.msgType_p0 inside {CMD_RD_NC}) || (rtt_q[tmp_q7[0]].smi_msg_type == MRD_PREF))) begin
    `uvm_info("<%=obj.BlockId%>:processCacheRd:2", $sformatf("%1p",cache_ctrl_pkt), UVM_LOW)
    print_rtt_q();
    `uvm_error("<%=obj.BlockId%>:processCacheRd:2","Above packet matches more than one MRD/NC_RD")
  end
  else begin
    if(rtt_q[tmp_q[match]].smi_msg_type != cache_ctrl_pkt.msgType_p0)begin
      `uvm_info("<%=obj.BlockId%>:processCacheRd:3", $sformatf("%1p",cache_ctrl_pkt), UVM_LOW)
      print_rtt_q();
      `uvm_error("<%=obj.BlockId%>:processCacheRd:3","Unexpected Msg type recd at CCP IF for lookup")
    end
    if(!(ccp_if_en))begin
      if(cache_ctrl_pkt.alloc |
         cache_ctrl_pkt.rd_data |
         cache_ctrl_pkt.wr_data |
         cache_ctrl_pkt.bypass |
         cache_ctrl_pkt.tagstateup |
         cache_ctrl_pkt.setway_debug |
         cache_ctrl_pkt.rp_update) begin
         `uvm_info("<%=obj.BlockId%>:processCacheRd:4", $sformatf("%1p",cache_ctrl_pkt), UVM_LOW)
         `uvm_error("<%=obj.BlockId%>:processCacheRd:4",
                    $sformatf("{allocate_p2|rd_data|wr_data|bypass|tagstateup|setwaydebug|rp_update}:%0b%0b%0b %0b%0b%0b %0b  expd: all zeros",
                              cache_ctrl_pkt.alloc,
                              cache_ctrl_pkt.rd_data,
                              cache_ctrl_pkt.wr_data,
                              cache_ctrl_pkt.bypass,
                              cache_ctrl_pkt.tagstateup,
                              cache_ctrl_pkt.setway_debug,
                              cache_ctrl_pkt.rp_update))
      end
      // Busy vector check
      m_busyway = get_busy_way(cache_ctrl_pkt.addr);
      `uvm_info("<%=obj.BlockId%>:processCacheRd:00",$sformatf("m_busyway :%0b sp_ways :%0b sp_enabled :%0b",m_busyway,sp_ways,sp_enabled),UVM_MEDIUM);
      if(sp_enabled)begin
        rsvd_ways     = (2**sp_ways) - 1;
        m_busyway = m_busyway | rsvd_ways;
      end
      else begin
        m_busyway = m_busyway ;
      end
      `uvm_info("<%=obj.BlockId%>:processCacheRd:01",$sformatf("m_busyway :%0b",m_busyway),UVM_MEDIUM);
      for (int i=0; i< <%=obj.DmiInfo[obj.Id].nAius%>; i++) begin
         if(isNcCohCmd(cache_ctrl_pkt.msgType_p0))begin
            if (aiu_funit_id[(<%=wFUnit%>*(i+1)-1)-:<%=wFUnit%>] == rtt_q[tmp_q[match]].cmd_req_pkt.smi_src_ncore_unit_id) begin
               aiu_no = i;
               break;
            end
         end else begin
            if (aiu_funit_id[(<%=wFUnit%>*(i+1)-1)-:<%=wFUnit%>] == rtt_q[tmp_q[match]].mrd_req_pkt.smi_src_ncore_unit_id) begin
               aiu_no = i;
               break;
            end
         end
      end
      `uvm_info("<%=obj.BlockId%>:processCacheRd:02",$sformatf("aiu_funit_id :%0b aiu_no :%0d ",aiu_funit_id,aiu_no),UVM_MEDIUM);
      <% if(obj.useCmc && obj.DmiInfo[obj.Id].useWayPartitioning==1) {%>
      for(int i=0; i < N_WAY_PART; i++) begin
        if((aiu_no == way_partition_reg_id[i]) && way_partition_vld[i] && !agent_id_match) begin
          m_busyway = ~way_partition_reg_way[i];
          agent_id_match = 1;
        end else if ((aiu_no == way_partition_reg_id[i]) && way_partition_vld[i] && agent_id_match) begin
          `uvm_error(`LABEL_ERROR,$sformatf("two source ids of way partitionig registers are same"));
        end
      end

      `uvm_info("<%=obj.BlockId%>:processCacheRd:03",$sformatf("m_busyway :%0b agent_id_match:%0b",m_busyway,agent_id_match),UVM_MEDIUM);
      if(agent_id_match == 0) begin
        for(int i=0; i < N_WAY_PART; i++) begin
          if(way_partition_vld[i]) m_busyway = m_busyway | way_partition_reg_way[i];
        end
      end
      if($countbits(m_busyway,1) == N_WAY)begin
        if(cache_ctrl_pkt.alloc)begin
          `uvm_error("<%=obj.BlockId%>:processCacheRd",$sformatf("alloc should not assert if all ways are busy m_busyway :%0b alloc :%0b",m_busyway,cache_ctrl_pkt.alloc));
        end
      end
      <%}%>
      `uvm_info("<%=obj.BlockId%>:processCacheRd:04",$sformatf("m_busyway :%0b",m_busyway),UVM_MEDIUM);

      // TODO: Fix this check for atomic transactions (CONC-5037)
      if (!$test$plusargs("add_atomic")) begin
        foreach(m_busyway[i])begin
          if(m_busyway[i] & !cache_ctrl_pkt.waypbusy_vec[i])begin
             `uvm_error("<%=obj.BlockId%>:processCacheRd",$sformatf("m_busyway way :%0d Expected :%0b Got :%0b",i,m_busyway,cache_ctrl_pkt.waypbusy_vec));
          end
        end
      end

      rtt_q[tmp_q[match]].lookupSeen = 1;
      if (rtt_q[tmp_q[match]].isCmdPref || (rtt_q[tmp_q[match]].smi_msg_type == MRD_PREF)) begin
        rtt_q[tmp_q[match]].AXI_read_addr_expd = 0;
        rtt_q[tmp_q[match]].AXI_read_data_expd = 0;
      end
    end
    else if(cache_ctrl_pkt.nackuce)begin
      if(cache_ctrl_pkt.rd_data |
         cache_ctrl_pkt.wr_data |
         cache_ctrl_pkt.bypass |
         cache_ctrl_pkt.tagstateup |
         cache_ctrl_pkt.setway_debug |
         cache_ctrl_pkt.rp_update) begin
         `uvm_info("<%=obj.BlockId%>:processCacheRd:5", $sformatf("%1p",cache_ctrl_pkt), UVM_LOW)
         `uvm_error("<%=obj.BlockId%>:processCacheRd:5",
                    $sformatf("{rd_data|wr_data|bypass|tagstateup|setwaydebug|rp_update}:%0b%0b%0b %0b%0b%0b  expd: all zeros",
                              cache_ctrl_pkt.rd_data,
                              cache_ctrl_pkt.wr_data,
                              cache_ctrl_pkt.bypass,
                              cache_ctrl_pkt.tagstateup,
                              cache_ctrl_pkt.setway_debug,
                              cache_ctrl_pkt.rp_update))
      end
      rtt_q[tmp_q[match]].lookupSeen = 1;
      rtt_q[tmp_q[match]].nackuce = 1;
      rtt_q[tmp_q[match]].cache_ctrl_pkt = cache_ctrl_pkt;
      rtt_q[tmp_q[match]].AXI_read_addr_expd = 0;
      rtt_q[tmp_q[match]].AXI_read_data_expd = 0;
      ///////////////////////////////////////////////////////////////
      //#Check.DMI.Concerto.v3.0.NoDTRforCMOandMrdPref
      //#Check.DMI.Concerto.v3.0.DtrReqCacheOps
      //////////////////////////////////////////////////////////////
      if(!(rtt_q[tmp_q[match]].smi_msg_type inside {MRD_FLUSH,MRD_INV,MRD_CLN,CMD_CLN_INV,CMD_CLN_VLD,CMD_CLN_SH_PER,CMD_MK_INV,CMD_PREF,MRD_PREF}))begin
        rtt_q[tmp_q[match]].DTR_req_expd = 1;
        rtt_q[tmp_q[match]].DTR_rsp_expd = 1;
      end
    end
    else begin
      if(!cache_ctrl_pkt.nackuce)begin
        //#Check.DMI.CMCActionsForMRDReqReadMessages
        if (rtt_q[tmp_q[match]].isMrd || rtt_q[tmp_q[match]].isNcRd || rtt_q[tmp_q[match]].isCmdPref || isAtomicMsg(rtt_q[tmp_q[match]].smi_msg_type)) begin
         // if miss allocate based on attribute
         // if miss allocate based on attribute
         if(cache_ctrl_pkt.currstate === IX) begin
           // check that allocate_p2 is 0
           // readdata, writedata, bypass, tagstate, setwaydebug, cancel, rp_update, evict are 0
           if(isAtomicMsg(rtt_q[tmp_q[match]].smi_msg_type))begin
             if(!alloc_en)begin
               if (cachevector !== 8'b00000000) begin
                 `uvm_info("<%=obj.BlockId%>:processCacheRd:ATM:0", $sformatf("%1p",cache_ctrl_pkt), UVM_LOW)
                  rtt_q[tmp_q[match]].print_entry();
                 `uvm_error("<%=obj.BlockId%>:processCacheRd:ATM:0",
                            $sformatf("{allocate_p2|rd_data|wr_data|evictvld|bypass|rp_update|tagstateup|setwaydebug|}:%0b%0b%0b %0b%0b%0b %0b%0b expd:8'b11010000",
                                          cache_ctrl_pkt.alloc, cache_ctrl_pkt.rd_data, cache_ctrl_pkt.wr_data,
                                          cache_ctrl_pkt.evictvld, cache_ctrl_pkt.bypass, cache_ctrl_pkt.rp_update,
                                          cache_ctrl_pkt.tagstateup, cache_ctrl_pkt.setway_debug))
               end
             end 
             else if(cache_ctrl_pkt.evictvld ==1 && cache_ctrl_pkt.evictstate == UD)begin
               if (cachevector !== 8'b11010000) begin
                 `uvm_info("<%=obj.BlockId%>:processCacheRd:ATM:1", $sformatf("%1p",cache_ctrl_pkt), UVM_LOW)
                  rtt_q[tmp_q[match]].print_entry();
                 `uvm_error("<%=obj.BlockId%>:processCacheRd:ATM:1",
                            $sformatf("{allocate_p2|rd_data|wr_data|evictvld|bypass|rp_update|tagstateup|setwaydebug|}:%0b%0b%0b %0b%0b%0b %0b%0b expd:8'b11010000",
                                          cache_ctrl_pkt.alloc, cache_ctrl_pkt.rd_data, cache_ctrl_pkt.wr_data,
                                          cache_ctrl_pkt.evictvld, cache_ctrl_pkt.bypass, cache_ctrl_pkt.rp_update,
                                          cache_ctrl_pkt.tagstateup, cache_ctrl_pkt.setway_debug))
               end
             end 
             else if(cache_ctrl_pkt.evictvld ==1 && cache_ctrl_pkt.evictstate == SC)begin
               if (cachevector !== 8'b10010000) begin
                 `uvm_info("<%=obj.BlockId%>:processCacheRd:ATM:2", $sformatf("%1p",cache_ctrl_pkt), UVM_LOW)
                  rtt_q[tmp_q[match]].print_entry();
                 `uvm_error("<%=obj.BlockId%>:processCacheRd:ATM:2",
                            $sformatf("{allocate_p2|rd_data|wr_data|evictvld|bypass|rp_update|tagstateup|setwaydebug|}:%0b%0b%0b %0b%0b%0b %0b%0b expd:8'b10010000",
                                          cache_ctrl_pkt.alloc, cache_ctrl_pkt.rd_data, cache_ctrl_pkt.wr_data,
                                          cache_ctrl_pkt.evictvld, cache_ctrl_pkt.bypass, cache_ctrl_pkt.rp_update,
                                          cache_ctrl_pkt.tagstateup, cache_ctrl_pkt.setway_debug))
               end
             end
             else begin
               if(!$test$plusargs("error_test"))begin
               if (cachevector !== 8'b10000000) begin
                 `uvm_info("<%=obj.BlockId%>:processCacheRd:ATM:3", $sformatf("%1p",cache_ctrl_pkt), UVM_LOW)
                  rtt_q[tmp_q[match]].print_entry();
                 `uvm_error("<%=obj.BlockId%>:processCacheRd:ATM:3",
                            $sformatf("{allocate_p2|rd_data|wr_data|evictvld|bypass|rp_update|tagstateup|setwaydebug|}:%0b%0b%0b %0b%0b%0b %0b%0b expd:8'b10000000",
                                          cache_ctrl_pkt.alloc, cache_ctrl_pkt.rd_data, cache_ctrl_pkt.wr_data,
                                          cache_ctrl_pkt.evictvld, cache_ctrl_pkt.bypass, cache_ctrl_pkt.rp_update,
                                          cache_ctrl_pkt.tagstateup, cache_ctrl_pkt.setway_debug))
               end
               end
             end
              rtt_q[tmp_q[match]].AXI_read_addr_expd = 1;
              rtt_q[tmp_q[match]].AXI_read_data_expd = 1;
              rtt_q[tmp_q[match]].fillExpd           = alloc_en;
              rtt_q[tmp_q[match]].fillDataExpd       = alloc_en;
              rtt_q[tmp_q[match]].cacheRspExpd       = 0;
              rtt_q[tmp_q[match]].isCacheHit         = 0;
              if (alloc_en) ->ccp_fill_raise;
           end
           //#Check.DMI.Concerto.v3.0.RdAllocationDisable
           else if(!(alloc_en && !RdAllocDisable) && !(rtt_q[tmp_q[match]].isCmdPref || rtt_q[tmp_q[match]].smi_msg_type === MRD_PREF)) begin
             if(cache_ctrl_pkt.alloc |
                cache_ctrl_pkt.rd_data |
                cache_ctrl_pkt.wr_data |
                cache_ctrl_pkt.bypass |
                cache_ctrl_pkt.tagstateup |
                cache_ctrl_pkt.setway_debug |
                cache_ctrl_pkt.rp_update) begin
                `uvm_info("<%=obj.BlockId%>:processCacheRd:6", $sformatf("%1p",cache_ctrl_pkt), UVM_LOW)
                `uvm_error("<%=obj.BlockId%>:processCacheRd:6",
                           $sformatf("{allocate_p2|rd_data|wr_data|bypass|tagstateup|setwaydebug|rp_update}:%0b%0b%0b %0b%0b%0b %0b  expd: all zeros",
                                     cache_ctrl_pkt.alloc,
                                     cache_ctrl_pkt.rd_data,
                                     cache_ctrl_pkt.wr_data,
                                     cache_ctrl_pkt.bypass,
                                     cache_ctrl_pkt.tagstateup,
                                     cache_ctrl_pkt.setway_debug,
                                     cache_ctrl_pkt.rp_update))
             end
            end
            else begin
             if((rtt_q[tmp_q[match]].smi_ac == 1 && 
                (rtt_q[tmp_q[match]].smi_msg_type === MRD_RD_WITH_SHR_CLN ||
                rtt_q[tmp_q[match]].smi_msg_type === MRD_RD_WITH_UNQ_CLN ||
                rtt_q[tmp_q[match]].smi_msg_type === MRD_RD_WITH_INV || 
                rtt_q[tmp_q[match]].smi_msg_type === MRD_PREF || 
                rtt_q[tmp_q[match]].smi_msg_type === CMD_RD_NC ) &&
                rtt_q[tmp_q[match]].smi_size     === SYS_wSysCacheline) ||
                (rtt_q[tmp_q[match]].smi_ac       === 1 &&
                rtt_q[tmp_q[match]].smi_msg_type === CMD_PREF)) begin
                //#Check.DMI.MrdALNoAllocCondition
                //  if(cache_ctrl_pkt.nacknoalloc ||  cache_ctrl_pkt.isWttfull ||  cache_ctrl_pkt.isWttanyfull || cache_ctrl_pkt.isRttfull || !cache_ctrl_pkt.wr_addr_fifo_full )begin v2.X check hase to review 
                if(cache_ctrl_pkt.nacknoalloc || !alloc_en || (alloc_en && RdAllocDisable && !(rtt_q[tmp_q[match]].isCmdPref || rtt_q[tmp_q[match]].smi_msg_type === MRD_PREF)))begin
                  if(cachevector[6:0] !== 7'b0000000) begin
                    rtt_q[tmp_q[match]].print_entry();
                   `uvm_error("<%=obj.BlockId%>:processCacheRd:7",
                              $sformatf("{rd_data|wr_data|evictvld|bypass|rp_update|tagstateup|setwaydebug|}:%0b%0b%0b %0b%0b%0b %0b expd:7'b0000000 || 7'b0000000 ",
                                            cache_ctrl_pkt.rd_data, cache_ctrl_pkt.wr_data,
                                            cache_ctrl_pkt.evictvld, cache_ctrl_pkt.bypass, cache_ctrl_pkt.rp_update,
                                            cache_ctrl_pkt.tagstateup, cache_ctrl_pkt.setway_debug))
                 end
                  rtt_q[tmp_q[match]].isCacheHit = 0;
                  rtt_q[tmp_q[match]].fillExpd     = 0;
                  rtt_q[tmp_q[match]].fillDataExpd = 0;
                  rtt_q[tmp_q[match]].cacheRspExpd = 0;
               end
               else begin
                 if(cache_ctrl_pkt.evictvld ==1 && cache_ctrl_pkt.evictstate == UD)begin
                   if (cachevector !== 8'b11010000) begin
                     `uvm_info("<%=obj.BlockId%>:processCacheRd:8", $sformatf("%1p",cache_ctrl_pkt), UVM_LOW)
                      rtt_q[tmp_q[match]].print_entry();
                     `uvm_error("<%=obj.BlockId%>:processCacheRd:8",
                                $sformatf("{allocate_p2|rd_data|wr_data|evictvld|bypass|rp_update|tagstateup|setwaydebug|}:%0b%0b%0b %0b%0b%0b %0b%0b expd:8'b11010000",
                                              cache_ctrl_pkt.alloc, cache_ctrl_pkt.rd_data, cache_ctrl_pkt.wr_data,
                                              cache_ctrl_pkt.evictvld, cache_ctrl_pkt.bypass, cache_ctrl_pkt.rp_update,
                                              cache_ctrl_pkt.tagstateup, cache_ctrl_pkt.setway_debug))
                   end
                 end 
                 else if(cache_ctrl_pkt.evictvld ==1 && cache_ctrl_pkt.evictstate == SC)begin
                   if (cachevector !== 8'b10010000) begin
                     `uvm_info("<%=obj.BlockId%>:processCacheRd:9", $sformatf("%1p",cache_ctrl_pkt), UVM_LOW)
                      rtt_q[tmp_q[match]].print_entry();
                     `uvm_error("<%=obj.BlockId%>:processCacheRd:9",
                                $sformatf("{allocate_p2|rd_data|wr_data|evictvld|bypass|rp_update|tagstateup|setwaydebug|}:%0b%0b%0b %0b%0b%0b %0b%0b expd:8'b10010000",
                                              cache_ctrl_pkt.alloc, cache_ctrl_pkt.rd_data, cache_ctrl_pkt.wr_data,
                                              cache_ctrl_pkt.evictvld, cache_ctrl_pkt.bypass, cache_ctrl_pkt.rp_update,
                                              cache_ctrl_pkt.tagstateup, cache_ctrl_pkt.setway_debug))
                   end
                 end
                 else begin
                   if(cachevector !== 8'b10000000) begin
                     `uvm_info("<%=obj.BlockId%>:processCacheRd:10", $sformatf("%1p",cache_ctrl_pkt), UVM_LOW)
                      rtt_q[tmp_q[match]].print_entry();
                     `uvm_error("<%=obj.BlockId%>:processCacheRd:10",
                                $sformatf("{allocate_p2|rd_data|wr_data|evictvld|bypass|rp_update|tagstateup|setwaydebug|}:%0b%0b%0b %0b%0b%0b %0b%0b expd:8'b10000000",
                                              cache_ctrl_pkt.alloc, cache_ctrl_pkt.rd_data, cache_ctrl_pkt.wr_data,
                                              cache_ctrl_pkt.evictvld, cache_ctrl_pkt.bypass, cache_ctrl_pkt.rp_update,
                                              cache_ctrl_pkt.tagstateup, cache_ctrl_pkt.setway_debug))
                   end
                 end
                 if(rtt_q[tmp_q[match]].isCmdPref || rtt_q[tmp_q[match]].smi_msg_type === MRD_PREF) begin
                  rtt_q[tmp_q[match]].fillExpd      = ~cache_ctrl_pkt.nacknoalloc & alloc_en ;
                  rtt_q[tmp_q[match]].fillDataExpd  = ~cache_ctrl_pkt.nacknoalloc & alloc_en ;
                 end
                 else begin
                 //#Check.DMI.Concerto.v3.0.NcAllocate
                 if(!tmp_q8.size())begin
                   rtt_q[tmp_q[match]].fillExpd      = ~cache_ctrl_pkt.nacknoalloc & alloc_en & !RdAllocDisable ;
                   rtt_q[tmp_q[match]].fillDataExpd  = ~cache_ctrl_pkt.nacknoalloc & alloc_en & !RdAllocDisable;
                 end
                 end
                  rtt_q[tmp_q[match]].cacheRspExpd = 0;
                  rtt_q[tmp_q[match]].isCacheHit = 0;
                  ->ccp_fill_raise;
               end
               if(((rtt_q[tmp_q[match]].isCmdPref || rtt_q[tmp_q[match]].smi_msg_type === MRD_PREF) && (!alloc_en || cache_ctrl_pkt.nacknoalloc)) || (tmp_q8.size() == 1))begin
                 rtt_q[tmp_q[match]].AXI_read_addr_expd = 0;
                 rtt_q[tmp_q[match]].AXI_read_data_expd = 0;
               end
               else begin
                 rtt_q[tmp_q[match]].AXI_read_addr_expd = 1;
                 rtt_q[tmp_q[match]].AXI_read_data_expd = 1;
               end
             end
             else begin
               if(cache_ctrl_pkt.alloc |
                  cache_ctrl_pkt.rd_data |
                  cache_ctrl_pkt.wr_data |
                  cache_ctrl_pkt.bypass |
                  cache_ctrl_pkt.tagstateup |
                  cache_ctrl_pkt.setway_debug |
                  cache_ctrl_pkt.rp_update) begin
                  `uvm_info("<%=obj.BlockId%>:processCacheRd:11", $sformatf("%1p",cache_ctrl_pkt), UVM_LOW)
                  `uvm_error("<%=obj.BlockId%>:processCacheRd:11",
                             $sformatf("{allocate_p2|rd_data|wr_data|bypass|tagstateup|setwaydebug|rp_update}:%0b%0b%0b %0b%0b%0b %0b  expd: all zeros",
                                       cache_ctrl_pkt.alloc,
                                       cache_ctrl_pkt.rd_data,
                                       cache_ctrl_pkt.wr_data,
                                       cache_ctrl_pkt.bypass,
                                       cache_ctrl_pkt.tagstateup,
                                       cache_ctrl_pkt.setway_debug,
                                       cache_ctrl_pkt.rp_update))
               end
             end
           end
           rtt_q[tmp_q[match]].cache_ctrl_pkt = cache_ctrl_pkt;
           if(rtt_q[tmp_q[match]].smi_msg_type inside {MRD_FLUSH,MRD_CLN,MRD_INV,CMD_CLN_INV,CMD_CLN_VLD,CMD_MK_INV,CMD_CLN_SH_PER} ||
              (rtt_q[tmp_q[match]].smi_msg_type inside {CMD_PREF,MRD_PREF} && (rtt_q[tmp_q[match]].smi_ac == 0 || !alloc_en || (sp_ways == <%=obj.DmiInfo[obj.Id].ccpParams.nWays%> && sp_enabled) ||
              tmp_q8.size() == 1)))begin
             rtt_q[tmp_q[match]].AXI_read_addr_expd = 0;
             rtt_q[tmp_q[match]].AXI_read_data_expd = 0;
             rtt_q[tmp_q[match]].fillExpd = 0;
             rtt_q[tmp_q[match]].fillDataExpd = 0;
             rtt_q[tmp_q[match]].isCacheHit = 0;
             rtt_q[tmp_q[match]].cacheRspExpd = 0;
             if(!(rtt_q[tmp_q[match]].smi_msg_type inside {CMD_PREF,MRD_PREF}))begin
               rtt_q[tmp_q[match]].wrOutstandingcnt = tmp_q5.size();
               //#Check.DMI.Concerto.v3.0.MrdRspTiming_1
               if(tmp_q5.size()>0 && rtt_q[tmp_q[match]].smi_vz )begin
                 rtt_q[tmp_q[match]].wrOutstandingFlag = 1;
               end
             end
           end
           else begin
             if(tmp_q8.size() == 1)begin
               rtt_q[tmp_q[match]].AXI_read_addr_expd = 1;
               rtt_q[tmp_q[match]].AXI_read_data_expd = 1;
               rtt_q[tmp_q[match]].isCacheMiss = 1;
             end
           end
           if(!(rtt_q[tmp_q[match]].smi_msg_type !== MRD_PREF && tmp_q8.size() == 1))begin
             rtt_q[tmp_q[match]].lookupSeen = 1;
             rtt_q[tmp_q[match]].t_lookup = $time;
             rtt_q[tmp_q[match]].t_latest_update = $time;
             rtt_q[tmp_q[match]].print_entry();
           end
          end
          else begin
             //#Check.DMI.CMC.MrdHitCollRtt
             tmp_q2 = rtt_q.find_index with (item.isMrd &&(item.cache_addr == cache_ctrl_pkt.addr) && 
                                                          (item.security == cache_ctrl_pkt.security) && 
                                                          (item.AXI_read_data_recd == 1) && 
                                                           !item.DTR_req_recd);

             if(tmp_q2.size()==1) begin
               tmp_q2_check = rtt_q.find_index with (item.isCmd && (item.cache_addr == cache_ctrl_pkt.addr) &&
                                                                   (item.security == cache_ctrl_pkt.security) && 
                                                                   (item.AXI_read_data_recd == 1) && 
                                                                    !item.DTR_req_recd);
               `uvm_info("<%=obj.BlockId%>:processCacheRd:12.1", $sformatf("MRD and CMD trans with same Addr -> %0h",cache_ctrl_pkt.addr), UVM_LOW)
               if (tmp_q2_check.size()==0)  tmp_q2.delete();
             end 

             if(tmp_q2.size() > 0 && (!(cache_ctrl_pkt.msgType_p0 inside {MRD_PREF,CMD_PREF}))) begin
               `uvm_info("<%=obj.BlockId%>:processCacheRd:12", $sformatf("%1p",cache_ctrl_pkt), UVM_LOW)
               `uvm_error("<%=obj.BlockId%>:processCacheRd:12","Data for this cache hit is already in RTT. This should not be possible. Refer to CONC-9198")
             end
             // allocate_p2, writedata, bypass, setwaydebug, cancel, are 0, port_sel is 0
             if(cache_ctrl_pkt.alloc |
                cache_ctrl_pkt.wr_data |
                cache_ctrl_pkt.bypass |
                cache_ctrl_pkt.evictvld |
                cache_ctrl_pkt.setway_debug) begin
                `uvm_info("<%=obj.BlockId%>:processCacheRd:13", $sformatf("%1p",cache_ctrl_pkt), UVM_LOW)
                `uvm_error("<%=obj.BlockId%>:processCacheRd:13",
                           $sformatf("{allocate_p2|wr_data|bypass|evictvld|setwaydebug}:%0b%0b%0b%0b %0b expd: all zeros",
                                     cache_ctrl_pkt.alloc,
                                     cache_ctrl_pkt.wr_data,
                                     cache_ctrl_pkt.bypass,
                                     cache_ctrl_pkt.evictvld,
                                     cache_ctrl_pkt.setway_debug))
             end
             if(!((rtt_q[tmp_q[match]].smi_msg_type inside {MRD_FLUSH,MRD_INV,MRD_CLN,CMD_CLN_INV,CMD_MK_INV,CMD_CLN_VLD,CMD_CLN_SH_PER,CMD_PREF,MRD_PREF}) || rtt_q[tmp_q[match]].smi_msg_type == MRD_RD_WITH_UNQ))begin
               if((cache_ctrl_pkt.tagstateup == 1) ||
                 (cache_ctrl_pkt.rd_data !== 1) ||
                 (cache_ctrl_pkt.rp_update !== 1)) begin
                  rtt_q[tmp_q[match]].print_entry();
                 `uvm_info("<%=obj.BlockId%>:processCacheRd:14", $sformatf("%1p",cache_ctrl_pkt), UVM_LOW)
                 `uvm_error("<%=obj.BlockId%>:processCacheRd:14",
                            $sformatf("{tagstateupdate|rd_data|rp_update}:%0b%0b%0b expd:011 ",
                                      cache_ctrl_pkt.tagstateup,
                                      cache_ctrl_pkt.rd_data,
                                      cache_ctrl_pkt.rp_update))
               end
             end

             if(rtt_q[tmp_q[match]].smi_msg_type == MRD_RD_WITH_UNQ)begin
               if((cache_ctrl_pkt.rd_data != 1) ||
                  (cache_ctrl_pkt.rp_update !== 1)) begin
                  rtt_q[tmp_q[match]].print_entry();
                 `uvm_info("<%=obj.BlockId%>:processCacheRd:15", $sformatf("%1p",cache_ctrl_pkt), UVM_LOW)
                 `uvm_error("<%=obj.BlockId%>:processCacheRd:15",
                            $sformatf("{rd_data|rp_update}:%0b%0b expd:11 ",
                                      cache_ctrl_pkt.rd_data,
                                      cache_ctrl_pkt.rp_update))
               end
             end

             if(((rtt_q[tmp_q[match]].smi_msg_type inside {MRD_CLN,CMD_CLN_VLD,CMD_CLN_SH_PER}) &&  cache_ctrl_pkt.currstate == SC))begin
               if((cache_ctrl_pkt.tagstateup != 0) ||
                  (cache_ctrl_pkt.rd_data != 0) ||
                  (cache_ctrl_pkt.rp_update != 0)) begin
                  rtt_q[tmp_q[match]].print_entry();
                 `uvm_info("<%=obj.BlockId%>:processCacheRd:16", $sformatf("%1p",cache_ctrl_pkt), UVM_LOW)
                 `uvm_error("<%=obj.BlockId%>:processCacheRd:16",
                            $sformatf("{tagstateupdate|rd_data|rp_update}:%0b%0b%b expd:000 ",
                                      cache_ctrl_pkt.tagstateup,
                                      cache_ctrl_pkt.rd_data,
                                      cache_ctrl_pkt.rp_update))
               end
             end

             if(((rtt_q[tmp_q[match]].smi_msg_type inside {CMD_CLN_INV}) &&  cache_ctrl_pkt.currstate == SC))begin
               if((cache_ctrl_pkt.tagstateup != 1) ||
                  (cache_ctrl_pkt.rd_data != 0) ||
                  (cache_ctrl_pkt.rp_update != 0)) begin
                  rtt_q[tmp_q[match]].print_entry();
                 `uvm_info("<%=obj.BlockId%>:processCacheRd:17", $sformatf("%1p",cache_ctrl_pkt), UVM_LOW)
                 `uvm_error("<%=obj.BlockId%>:processCacheRd:17",
                            $sformatf("{tagstateupdate|rd_data|rp_update}:%0b%0b%b expd:000 ",
                                      cache_ctrl_pkt.tagstateup,
                                      cache_ctrl_pkt.rd_data,
                                      cache_ctrl_pkt.rp_update))
               end
             end

            //#Check.DMI.CMCActionsForMRDReqFlushMessages
             if(((rtt_q[tmp_q[match]].smi_msg_type inside {MRD_FLUSH,MRD_CLN,CMD_CLN_VLD,CMD_CLN_INV,CMD_CLN_SH_PER}) &&  cache_ctrl_pkt.currstate == UD))begin
                 if(cachevector != 8'b01000010)begin
                    rtt_q[tmp_q[match]].print_entry();
                   `uvm_info("<%=obj.BlockId%>:processCacheRd:18", $sformatf("%1p",cache_ctrl_pkt), UVM_LOW)
                   `uvm_error("<%=obj.BlockId%>:processCacheRd:18",
                              $sformatf("{alloc|rd_data|wr_data|evictvld|bypass|rp_update|tagstatup|setway_debug}:%0b expd:'b01000010 ",
                                        cachevector))
                 end
                 if(rtt_q[tmp_q[match]].smi_msg_type inside {MRD_FLUSH,MRD_CLN})begin
                    if(rtt_q[tmp_q[match]].mrd_req_pkt.smi_rl == 'b10)begin
                      rtt_q[tmp_q[match]].wrOutstandingFlag = 1;
                    end
                 end else begin
                    if(rtt_q[tmp_q[match]].cmd_req_pkt.smi_rl == 'b10)begin
                      rtt_q[tmp_q[match]].wrOutstandingFlag = 1;
                    end
                 end
                 if(rtt_q[tmp_q[match]].smi_msg_type inside {MRD_FLUSH,CMD_CLN_INV})begin
                   if(cache_ctrl_pkt.state  !== IX)begin
                     `uvm_info("<%=obj.BlockId%>:processCacheRd:19",$sformatf("%1p",cache_ctrl_pkt), UVM_LOW)
                     `uvm_error("<%=obj.BlockId%>:processCacheRd:19",$sformatf("updated state:%s expd:IX ",cache_ctrl_pkt.state))
                   end
                 end
                 else if(rtt_q[tmp_q[match]].smi_msg_type inside {CMD_CLN_VLD,CMD_CLN_SH_PER,MRD_CLN})begin
                   if(cache_ctrl_pkt.state  !== SC)begin
                     `uvm_info("<%=obj.BlockId%>:processCacheRd:20",$sformatf("%1p",cache_ctrl_pkt), UVM_LOW)
                     `uvm_error("<%=obj.BlockId%>:processCacheRd:20",$sformatf("updated state:%s expd:SC ",cache_ctrl_pkt.state))
                   end
                 end
                 rtt_q[tmp_q[match]].isRdWtt = 1;
                 rtt_q[tmp_q[match]].wrOutstandingcnt = tmp_q5.size()+1;
                 processRdrspAddr(cache_ctrl_pkt,rtt_q[tmp_q[match]].smi_qos,rtt_q[tmp_q[match]]);
                if(cache_ctrl_pkt.burstln !== FLUSH_BURSTLN)begin
                 rtt_q[tmp_q[match]].print_entry();
                  `uvm_error("<%=obj.BlockId%>:processCacheRd:21",$sformatf("burstln for MRD_FLUSH/MRD_CLN/CMD_CLN_VLD/CMD_CLN_SH_PER should be full cacheline expected :%0d actual :%0d",FLUSH_BURSTLN,cache_ctrl_pkt.burstln)); 
                end
             end

            if(rtt_q[tmp_q[match]].smi_msg_type == MRD_RD_WITH_UNQ) begin
                if((cache_ctrl_pkt.tagstateup != 0) ||
                  (cache_ctrl_pkt.state  !== IX) ||
                  (cache_ctrl_pkt.rp_update != 1)) begin
                  rtt_q[tmp_q[match]].print_entry();
                 `uvm_info("<%=obj.BlockId%>:processCacheRd:22", $sformatf("%1p",cache_ctrl_pkt), UVM_LOW)
                 `uvm_error("<%=obj.BlockId%>:processCacheRd:22",
                            $sformatf("{tagstateupdate|rp_update}:%0b%0b expd:01 exp state :IX recd :%s ",
                                      cache_ctrl_pkt.tagstateup,
                                      cache_ctrl_pkt.rp_update,
                                      cache_ctrl_pkt.state))
               end
            end
            //#Check.DMI.Concerto.v3.0.MrdFlushMrdInv
             if(rtt_q[tmp_q[match]].smi_msg_type inside {MRD_FLUSH,MRD_INV})begin
               if((cache_ctrl_pkt.tagstateup != 1) ||
                  (cache_ctrl_pkt.state  !== IX) ||
                  (cache_ctrl_pkt.rp_update != 0)) begin
                  rtt_q[tmp_q[match]].print_entry();
                 `uvm_info("<%=obj.BlockId%>:processCacheRd:22", $sformatf("%1p",cache_ctrl_pkt), UVM_LOW)
                 `uvm_error("<%=obj.BlockId%>:processCacheRd:22",
                            $sformatf("{tagstateupdate|rp_update}:%0b%0b expd:10 exp state :IX recd :%s ",
                                      cache_ctrl_pkt.tagstateup,
                                      cache_ctrl_pkt.rp_update,
                                      cache_ctrl_pkt.state))
               end
             end
             if(rtt_q[tmp_q[match]].smi_msg_type inside {CMD_PREF,MRD_PREF})begin
               if(cachevector != 8'b00000100)begin
                  rtt_q[tmp_q[match]].print_entry();
                 `uvm_info("<%=obj.BlockId%>:processCacheRd:23", $sformatf("%1p",cache_ctrl_pkt), UVM_LOW)
                 `uvm_error("<%=obj.BlockId%>:processCacheRd:23",
                            $sformatf("{alloc|rd_data|wr_data|evictvld|bypass|rp_update|tagstatup|setway_debug}:%0b expd:'b00000100 ",
                                      cachevector))
               end
             end
             rtt_q[tmp_q[match]].cache_ctrl_pkt = cache_ctrl_pkt;
             rtt_q[tmp_q[match]].lookupSeen = 1;
             rtt_q[tmp_q[match]].isCacheHit = 1;
             if(!(rtt_q[tmp_q[match]].smi_msg_type inside {MRD_FLUSH,MRD_INV,MRD_CLN,CMD_CLN_INV,CMD_CLN_VLD,CMD_CLN_SH_PER,CMD_MK_INV,CMD_PREF,MRD_PREF}))begin
               rtt_q[tmp_q[match]].cacheRspExpd = 1;
             end
             //#Check.DMI.v2.NoArwithCmcHit
             rtt_q[tmp_q[match]].AXI_read_addr_expd = 0;
             rtt_q[tmp_q[match]].AXI_read_data_expd = 0;
             rtt_q[tmp_q[match]].t_lookup = $time;
             rtt_q[tmp_q[match]].t_latest_update = $time;
             rtt_q[tmp_q[match]].print_entry();

          end
          // TODO:if no allocate, proceed normally
       end // if (rtt_q[tmp_q[match]].isMrd)
      end 
      else begin
            rtt_q[tmp_q[match]].lookupSeen = 1;
            rtt_q[tmp_q[match]].isReplay   = 0;
            rtt_q[tmp_q[match]].AXI_read_addr_expd = 0;
            rtt_q[tmp_q[match]].AXI_read_data_expd = 0;
            rtt_q[tmp_q[match]].t_lookup = $time;
            rtt_q[tmp_q[match]].t_latest_update = $time;
            rtt_q[tmp_q[match]].print_entry();
      end
    end
    if(rtt_q[tmp_q[match]].fillDataExpd)begin
      rtt_q[tmp_q[match]].fillwayn = cache_ctrl_pkt.wayn;
    end
    if(rtt_q[tmp_q[match]].isAtomic && rtt_q[tmp_q[match]].isCacheHit)begin
      rtt_q[tmp_q[match]].fillwayn = onehot_to_binary(cache_ctrl_pkt.hitwayn);
    end
    if(rtt_q[tmp_q[match]].fillExpd && !rtt_q[tmp_q[match]].isAtomic)begin
      create_exp_fillCtrl(cache_ctrl_pkt,rtt_q[tmp_q[match]]);
    end
    txn = rtt_q[tmp_q[match]];
    <% if(obj.testBench == 'dmi' || (obj.testBench == "fsys")) { %>
    `ifndef VCS
    `uvm_info("DMI_SCB", $psprintf("DMI_UID:%0d: CACHE_RD: %s", txn.txn_id, cache_ctrl_pkt.sprint_pkt()), UVM_LOW)
    updateRttentry(txn,tmp_q[match]);
    // Full line needs to be read from memory in case of cacheline allocation in cache
    if(rtt_q[tmp_q[match]].AXI_read_addr_expd && rtt_q[tmp_q[match]].fillExpd) begin
       rtt_q[tmp_q[match]].expd_arlen   = ((SYS_nSysCacheline*8)/<%=obj.DmiInfo[obj.Id].ccpParams.wData%>)-1;
       rtt_q[tmp_q[match]].expd_arburst = AXIWRAP;
    end
    `else // `ifndef VCS
    // Full line needs to be read from memory in case of cacheline allocation in cache
    if(rtt_q[tmp_q[match]].AXI_read_addr_expd && rtt_q[tmp_q[match]].fillExpd) begin
       rtt_q[tmp_q[match]].expd_arlen   = ((SYS_nSysCacheline*8)/<%=obj.DmiInfo[obj.Id].ccpParams.wData%>)-1;
       rtt_q[tmp_q[match]].expd_arburst = AXIWRAP;
    end
    `uvm_info("DMI_SCB", $psprintf("DMI_UID:%0d: CACHE_RD: %s", txn.txn_id, cache_ctrl_pkt.sprint_pkt()), UVM_LOW)
    updateRttentry(txn,tmp_q[match]);
    `endif // `ifndef VCS ... `else ... 
    <% } else {%>
    `uvm_info("DMI_SCB", $psprintf("DMI_UID:%0d: CACHE_RD: %s", txn.txn_id, cache_ctrl_pkt.sprint_pkt()), UVM_LOW)
    updateRttentry(txn,tmp_q[match]);
    // Full line needs to be read from memory in case of cacheline allocation in cache
    if(rtt_q[tmp_q[match]].AXI_read_addr_expd && rtt_q[tmp_q[match]].fillExpd) begin
       rtt_q[tmp_q[match]].expd_arlen   = ((SYS_nSysCacheline*8)/<%=obj.DmiInfo[obj.Id].ccpParams.wData%>)-1;
       rtt_q[tmp_q[match]].expd_arburst = AXIWRAP;
    end
    <% } %>
  end
  `uvm_info("<%=obj.BlockId%>:processCacheRd:24", $sformatf("Exiting processCacheRd----------------------------"),UVM_MEDIUM);
endfunction // processCacheRd
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Process MRD maintenace OP Cache Control Channel
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function void dmi_scoreboard::processMaintop(ccp_ctrl_pkt_t cpy_pkt);
  dmi_scb_txn temp_mntop_pkt;
  dmi_scb_txn m_scb_txn;
  int offset = SYS_wSysCacheline;
  bit isAXIReqNeeded;
  int m_find_q[$];

  if(!(ccp_if_en))begin
    if(cpy_pkt.alloc |
       cpy_pkt.rd_data |
       cpy_pkt.wr_data |
       cpy_pkt.bypass |
       cpy_pkt.tagstateup |
       cpy_pkt.setway_debug |
       cpy_pkt.rp_update) begin
       `uvm_info("<%=obj.BlockId%>:processMaintop:0", $sformatf("%1p",cpy_pkt), UVM_LOW)
       `uvm_error("<%=obj.BlockId%>:processMaintop:0",
                  $sformatf("{allocate_p2|rd_data|wr_data|bypass|tagstateup|setwaydebug|rp_update}:%0b%0b%0b %0b%0b%0b %0b  expd: all zeros",
                            cpy_pkt.alloc,
                            cpy_pkt.rd_data,
                            cpy_pkt.wr_data,
                            cpy_pkt.bypass,
                            cpy_pkt.tagstateup,
                            cpy_pkt.setway_debug,
                            cpy_pkt.rp_update))
    end
  end
  else if(cpy_pkt.nackuce)begin
    if(cpy_pkt.alloc |
       cpy_pkt.rd_data |
       cpy_pkt.wr_data |
       cpy_pkt.bypass |
       cpy_pkt.tagstateup |
       cpy_pkt.setway_debug |
       cpy_pkt.rp_update) begin
       `uvm_info("<%=obj.BlockId%>:processMaintop:1", $sformatf("%1p",cpy_pkt), UVM_LOW)
       `uvm_error("<%=obj.BlockId%>:processMaintop:1",
                  $sformatf("{allocate_p2|rd_data|wr_data|bypass|tagstateup|setwaydebug|rp_update}:%0b%0b%0b %0b%0b%0b %0b  expd: all zeros",
                            cpy_pkt.alloc,
                            cpy_pkt.rd_data,
                            cpy_pkt.wr_data,
                            cpy_pkt.bypass,
                            cpy_pkt.tagstateup,
                            cpy_pkt.setway_debug,
                            cpy_pkt.rp_update))
    end
   end
   else if(cpy_pkt.ccp_tt_full_p2)begin
     if(cpy_pkt.setway_debug) begin
       if(cpy_pkt.opcode != 'h5)begin
        `uvm_info("<%=obj.BlockId%>:processMaintop:2", $sformatf("%1p",cpy_pkt), UVM_LOW)
        `uvm_error("<%=obj.BlockId%>:processMaintop:2", $sformatf("Exp mnt opcode :'h5 recd:%0x",cpy_pkt.opcode))
       end
     end
     else begin
       if(!(cpy_pkt.opcode == 'h4 || cpy_pkt.opcode == 'h6 ))begin
        `uvm_info("<%=obj.BlockId%>:processMaintop:3", $sformatf("%1p",cpy_pkt), UVM_LOW)
        `uvm_error("<%=obj.BlockId%>:processMaintop:3", $sformatf("Exp mnt opcode :'h4 or 'h6 recd:%0x",cpy_pkt.opcode))
       end
     end 
   end
   else begin
   //#Check.DMI.CMC.EvictionOnDty
    if(cpy_pkt.currstate === UD)begin
      if(cpy_pkt.opcode == 'hC || cpy_pkt.opcode == 'hE)begin
        if((cpy_pkt.tagstateup == 1 & !cpy_pkt.ccp_tt_full_p2 & !cpy_pkt.flush_fail_p2) ||
           (cpy_pkt.rd_data == 0 & !cpy_pkt.ccp_tt_full_p2 & !cpy_pkt.flush_fail_p2) ||
           (cpy_pkt.rp_update == 1 & !cpy_pkt.flush_fail_p2) ||
           (cpy_pkt.burstln !== FLUSH_BURSTLN & !cpy_pkt.flush_fail_p2) ||
           (cpy_pkt.state !== IX)) begin
           `uvm_info("<%=obj.BlockId%>:processMaintop:4", $sformatf("%1p",cpy_pkt), UVM_LOW)
           `uvm_error("<%=obj.BlockId%>:processMaintop:4",
                      $sformatf("{tagstateupdate|rd_data|rp_update}:%0b%0b%0b expd:010 state:%s expd:IX burstln :%0d expd :%0d",
                                cpy_pkt.tagstateup,
                                cpy_pkt.rd_data,
                                cpy_pkt.rp_update,
                                cpy_pkt.state,
                                cpy_pkt.burstln,
                                FLUSH_BURSTLN))
        end
      end else begin
        if((cpy_pkt.tagstateup == 0 & !cpy_pkt.ccp_tt_full_p2 & !cpy_pkt.flush_fail_p2) ||
           (cpy_pkt.rd_data == 0 & !cpy_pkt.ccp_tt_full_p2 & !cpy_pkt.flush_fail_p2) ||
           (cpy_pkt.rp_update == 1 & !cpy_pkt.flush_fail_p2 & !cpy_pkt.flush_fail_p2) ||
           (cpy_pkt.burstln !== FLUSH_BURSTLN & !cpy_pkt.flush_fail_p2) ||
           (cpy_pkt.state !== IX)) begin
           `uvm_info("<%=obj.BlockId%>:processMaintop:4_else", $sformatf("%1p",cpy_pkt), UVM_LOW)
           `uvm_error("<%=obj.BlockId%>:processMaintop:4",
                      $sformatf("{tagstateupdate|rd_data|rp_update}:%0b%0b%0b expd:110 state:%s expd:IX burstln :%0d expd :%0d",
                                cpy_pkt.tagstateup,
                                cpy_pkt.rd_data,
                                cpy_pkt.rp_update,
                                cpy_pkt.state,
                                cpy_pkt.burstln,
                                FLUSH_BURSTLN))
        end
      end 
      if (!cpy_pkt.flush_fail_p2) processRdrspAddr(cpy_pkt);
    end
    else begin
      if(cpy_pkt.opcode == 'hC || cpy_pkt.opcode == 'hE)begin
        if((cpy_pkt.tagstateup == 1 & !cpy_pkt.ccp_tt_full_p2 & !cpy_pkt.flush_fail_p2) ||
           (cpy_pkt.rd_data == 1 & !cpy_pkt.flush_fail_p2) ||
           (cpy_pkt.rp_update == 1 & !cpy_pkt.flush_fail_p2) ||
           (cpy_pkt.state !== IX)) begin
           `uvm_info("<%=obj.BlockId%>:processMaintop:5", $sformatf("%1p",cpy_pkt), UVM_LOW)
           `uvm_error("<%=obj.BlockId%>:processMaintop:5",
                      $sformatf("{tagstateupdate|rd_data|rp_update}:%0b%0b%0b expd:000 state:%s expd:IX",
                                cpy_pkt.tagstateup,
                                cpy_pkt.rd_data,
                                cpy_pkt.rp_update,
                                cpy_pkt.state))
        end
      end else begin
        if((cpy_pkt.tagstateup == 0 & !cpy_pkt.ccp_tt_full_p2 & !cpy_pkt.flush_fail_p2) ||
           (cpy_pkt.rd_data == 1 & !cpy_pkt.flush_fail_p2) ||
           (cpy_pkt.rp_update == 1 & !cpy_pkt.flush_fail_p2) ||
           (cpy_pkt.state !== IX)) begin
           `uvm_info("<%=obj.BlockId%>:processMaintop:5_else", $sformatf("%1p",cpy_pkt), UVM_LOW)
           `uvm_error("<%=obj.BlockId%>:processMaintop:5",
                      $sformatf("{tagstateupdate|rd_data|rp_update}:%0b%0b%0b expd:100 state:%s expd:IX",
                                cpy_pkt.tagstateup,
                                cpy_pkt.rd_data,
                                cpy_pkt.rp_update,
                                cpy_pkt.state))
        end
      end
    end
     //#Check.DMI.v2.MaintActvCheck
     if(cpy_pkt.isMntOp) begin
       if(!cpy_pkt.active)begin
         `uvm_info("<%=obj.BlockId%>:processMaintop:7", $sformatf("%1p",cpy_pkt), UVM_LOW)
         `uvm_error("<%=obj.BlockId%>:processMaintop:7", $sformatf("maint Active should be high "))
       end
       if(cpy_pkt.setway_debug) begin
         if(cpy_pkt.opcode != 'h5 && cpy_pkt.opcode != 'hC && cpy_pkt.opcode != 'hE)begin
           `uvm_info("<%=obj.BlockId%>:processMaintop:8", $sformatf("%1p",cpy_pkt), UVM_LOW)
           `uvm_error("<%=obj.BlockId%>:processMaintop:8", $sformatf("Exp mnt opcode :'h5 recd:%0x",cpy_pkt.opcode))
         end
       end
       else begin
         if(!(cpy_pkt.opcode == 'h4 || cpy_pkt.opcode == 'h6 ))begin
           `uvm_info("<%=obj.BlockId%>:processMaintop:9", $sformatf("%1p",cpy_pkt), UVM_LOW)
           `uvm_error("<%=obj.BlockId%>:processMaintop:9", $sformatf("Exp mnt opcode :'h4 or 'h6 recd:%0x",cpy_pkt.opcode))
         end
       end 
     end
   end

   if(cpy_pkt.isMntOp && (!cpy_pkt.nack || cpy_pkt.nackuce)) begin
     //Flush All operation
     `uvm_info("<%=obj.BlockId%>:processMaintop:10", $psprintf("MntOp_q size %d",m_mntop_q.size()), UVM_MEDIUM)
     `uvm_info("<%=obj.BlockId%>:processMaintop:10", $psprintf("MntOptype %d",mntOpType), UVM_MEDIUM)

     if(cpy_pkt.rp_update | cpy_pkt.alloc | cpy_pkt.wr_data | cpy_pkt.evictvld) begin
       spkt = { "ctrlop_rp_update/alloc/wr_data signals should not be asserted for a maintenance txn \n rp_update %0b alloc %0b wr_data %0b evictvld %0b"};
       `uvm_error("<%=obj.BlockId%>:processMaintop:11", $psprintf(spkt, cpy_pkt.rp_update, cpy_pkt.alloc, cpy_pkt.wr_data, cpy_pkt.evictvld))
     end

     if(mntOpType == 'h4) begin
       if(cpy_pkt.opcode != 'h5)begin
         `uvm_info("<%=obj.BlockId%>:processMaintop:12", $sformatf("%1p",cpy_pkt), UVM_LOW)
         `uvm_error("<%=obj.BlockId%>:processMaintop:12", $sformatf("Opcode mismatch Exp mnt opcode :'h4 recd:%0x",cpy_pkt.opcode))
       end
     end
     else if ((mntOpType == 'h5) || (mntOpType == 'h8)) begin
       if(cpy_pkt.opcode != 'h5) begin
         `uvm_info("<%=obj.BlockId%>:processMaintop:13", $sformatf("%1p",cpy_pkt), UVM_LOW)
         `uvm_error("<%=obj.BlockId%>:processMaintop:13", $sformatf("Opcode mismatch Exp mnt opcode :'h5 recd:%0x",cpy_pkt.opcode))
       end
     end
     else if ((mntOpType == 'h6) || (mntOpType == 'h7)) begin
       if(cpy_pkt.opcode != 'h6)begin
          `uvm_info("<%=obj.BlockId%>:processMaintop:14", $sformatf("%1p",cpy_pkt), UVM_LOW)
          `uvm_error("<%=obj.BlockId%>:processMaintop:14", $sformatf("Opcode mismatch Exp mnt opcode :'h6 recd:%0x",cpy_pkt.opcode))
       end
     end
     if(((mntOpType == 'h4) || (mntOpType == 'h5) || (mntOpType == 'h6) || (mntOpType == 'h7) || (mntOpType == 'h8) || (mntOpType == 'hC) || (mntOpType == 'hE)) && !cpy_pkt.flush_fail_p2) begin
       if(m_mntop_q.size()>0) begin
         temp_mntop_pkt = m_mntop_q.pop_front();
         temp_mntop_pkt.t_latest_update = $time;
         `uvm_info("<%=obj.BlockId%>:processMaintop:15", $psprintf("MntOp_q size %d",m_mntop_q.size()), UVM_MEDIUM)
         if (m_mntop_q.size() == 0) begin
           -> maint_op_drop; // Drop only once although raised objections multiple times since objections are raised in a 0 time for mnt_op = 7/8/4
         end
       end
       else begin
         `uvm_error("<%=obj.BlockId%>:processMaintop:15", $psprintf("Received an unexpected MntOp txn MntOpType:%0d",mntOpType))
       end

       if(cpy_pkt.nackuce == 0) begin
         if(((mntOpType != 'h6) && (mntOpType != 'h7)) && ~cpy_pkt.setway_debug) begin
           `uvm_error("<%=obj.BlockId%>:processMaintop:16", $psprintf("Expected the ctrlop_setway_debug to be set for MntOp txn"))
         end

         if(((mntOpType == 'h6) || (mntOpType == 'h7)) && cpy_pkt.setway_debug) begin
           `uvm_error("<%=obj.BlockId%>:processMaintop:16", $psprintf("For Flush by Addr ctrlop_setway_debug shouldn't be set"))
         end

         if((mntOpType == 'h6) || (mntOpType == 'h7)) begin
           if(!cpy_pkt.tagstateup || (cpy_pkt.state != IX)) begin
             spkt = {"Expected the tagstateup signal to be set and state signal to be set to IX for address flush operation"};
             `uvm_error("<%=obj.BlockId%>:processMaintop:17", spkt)
           end
         end 
         if(!cpy_pkt.tagstateup && mntOpType !== 'hC && mntOpType !== 'hE) begin
           spkt = {"Expected the tagstateup signal to be set for a set-way/address flush operation"};
           `uvm_error("<%=obj.BlockId%>:processMaintop:18", spkt)
         end

         if((mntOpType == 'h6) || (mntOpType == 'h7)) begin
           if((cpy_pkt.addr != (temp_mntop_pkt.mntop_addr<<offset)) || (cpy_pkt.security != mnt_PcSecAttr)) begin
             spkt = {"Expected MntOp to perform a flush for Exp Addr:%0h but Got Addr:%0h",
                     " Exp Security:%0d and Got Security:%0d"};
             `uvm_error("<%=obj.BlockId%>:processMaintop:19",
                        $psprintf(spkt, (temp_mntop_pkt.mntop_addr<<offset), cpy_pkt.addr, mnt_PcSecAttr, cpy_pkt.security))
           end
         end 
         else if (mntOpType !== 'hC && mntOpType !== 'hE) begin
           if((ncoreConfigInfo::get_set_index(cpy_pkt.addr,<%=obj.DmiInfo[obj.Id].FUnitId%>) != temp_mntop_pkt.mntop_index) ||
              (onehot_to_binary(cpy_pkt.mntwayn) != temp_mntop_pkt.mntop_way && mntOpType != 'h4 && mntOpType != 'h5 && mntOpType != 'h8)) begin //Disabled hit_way check for set_way_flush operation as per JIRA CONC-6216
             spkt = {"Expected MntOp to perform a flush for Exp Index:%0h and Way %0h but Got Index:%0h and Way %0h"};
             `uvm_error("<%=obj.BlockId%>:processMaintop:20",
                        $psprintf(spkt, temp_mntop_pkt.mntop_index, temp_mntop_pkt.mntop_way, (ncoreConfigInfo::get_set_index(cpy_pkt.addr,<%=obj.DmiInfo[obj.Id].FUnitId%>)),
                                  onehot_to_binary(cpy_pkt.mntwayn)))
           end
         end

         m_scb_txn = new();

         if(((mntOpType == 'hC) || (mntOpType == 'hE)) && (cpy_pkt.arraysel!=temp_mntop_pkt.mntop_ArrayId || cpy_pkt.word!=temp_mntop_pkt.mntop_word)) begin
           spkt = {"Expected ArrySel:0x%x and Word:0x%0x for MntOp DebugRd/DebugWr, Act: ArraySel:0x%0x Word:0x%0x"};
           `uvm_error("<%=obj.BlockId%>:processMaintop:20_1", $sformatf(spkt,temp_mntop_pkt.mntop_ArrayId,temp_mntop_pkt.mntop_word,cpy_pkt.arraysel,cpy_pkt.word))
         end

         // Check Wrdata/reqdata
         if((mntOpType == 'hE) && (cpy_pkt.wrdata !== temp_mntop_pkt.mntop_Dataword)) begin
           spkt = {"Expected Mnt_ReqData = 0x%0x but got 0x%0x"};
           `uvm_error("<%=obj.BlockId%>:processMaintop:20_2", $sformatf(spkt,temp_mntop_pkt.mntop_Dataword,cpy_pkt.wrdata))
         end

         `uvm_info("<%=obj.BlockId%>:processMaintop:21", $sformatf("Evict for address 0x%0x", cpy_pkt.evictaddr), UVM_MEDIUM)
         m_scb_txn.t_lookup = $time;
         if((mntOpType == 'h6) || (mntOpType == 'h7)) begin
           cpy_pkt.evictstate    = cpy_pkt.currstate;
           cpy_pkt.evictaddr     = cpy_pkt.addr;
           cpy_pkt.evictsecurity = cpy_pkt.security;
         end

         //if(cpy_pkt.evictvld & cpy_pkt.rd_data) processEvictAddr(cpy_pkt);
         //-> maint_op_raise;
         isAXIReqNeeded = (cpy_pkt.currstate == UD);

         if(isAXIReqNeeded) begin
           if(~cpy_pkt.rd_data) begin
             spkt = {"For MntOp Evict expected the ctrlop_read_data_p2",
                     " signal to be set"};
             `uvm_error("<%=obj.BlockId%>:processMaintop:22", $psprintf(spkt))
           end

           if(~cpy_pkt.rsp_evict_sel) begin
             spkt = {"For MntOp Evict expected the ctrlop_port_sel_p2",
                     " signal to be set"};
             `uvm_error("<%=obj.BlockId%>:processMaintop:23", $psprintf(spkt))
           end

           if(cpy_pkt.bypass) begin
             spkt = {"For MntOp Evict expected the ctrlop_bypass_p2",
                     " signal to be not set"};
             `uvm_error("<%=obj.BlockId%>:processMaintop:24", $psprintf(spkt))
           end
         end 
         else begin
           if(cpy_pkt.rsp_evict_sel || cpy_pkt.bypass) begin
             spkt = {"For MntOp Evict where no Downstream req is reqd ",
                     " expected the ctrlop_port_sel_p2 and ctrl_op_bypass_p2",
                     " signal to be not-set"};
             `uvm_error("<%=obj.BlockId%>:processMaintop:25", $psprintf(spkt))
           end

           if(cpy_pkt.rd_data) begin
             spkt = {"For MntOp Evict where no DTW req is reqd ",
                     " expected the ctrlop_read_data_p2",
                     " signal to be not-set"};
             `uvm_error("<%=obj.BlockId%>:processMaintop:26", $psprintf(spkt))
           end
         end

         if((mntOpType == 'h5) || (mntOpType == 'h8)|| (mntOpType == 'h4)) begin
           m_find_q = {};
           m_find_q = m_dmi_cache_q.find_index() with (
                                               item.Index == temp_mntop_pkt.mntop_index &&
                                               item.way   == temp_mntop_pkt.mntop_way
                                               );
           if(m_find_q.size()==1) begin
             `uvm_info("<%=obj.BlockId%>:processMaintop:27",$sformatf("In flush operation: Index: %h Way: %h ",
                             temp_mntop_pkt.mntop_index, temp_mntop_pkt.mntop_way),UVM_LOW)
             if ((cpy_pkt.evictstate != m_dmi_cache_q[m_find_q[0]].state) ||
                 (cpy_pkt.currstate  != m_dmi_cache_q[m_find_q[0]].state)) begin
                 `uvm_error("<%=obj.BlockId%>:processMaintop:28",$sformatf("In flush operation evictstate mismatch Got: %s Exp: %s",
                                  cpy_pkt.evictstate, m_dmi_cache_q[m_find_q[0]].state));
             end

             //Disabled hit_way check for set_way_flush operation as per JIRA CONC-6216
             //if (onehot_to_binary(cpy_pkt.hitwayn) != m_dmi_cache_q[m_find_q[0]].way) begin
             //    `uvm_error("<%=obj.BlockId%>:processMaintop:29",$sformatf("In flush operation hitway mismatch Got: %0b Exp: %0b",
             //                     onehot_to_binary(cpy_pkt.hitwayn), m_dmi_cache_q[m_find_q[0]].way));
             //end

             // Locked caheline should not be evicted
             if (m_dmi_cache_q[m_find_q[0]].isPending) begin
                 `uvm_error ("<%=obj.BlockId%>:processMaintop:30",$sformatf("Cacheline evicted for which fill is pending"));
             end

             `uvm_info("<%=obj.BlockId%>:processMaintop:31","Deleting cacheline from cache model",UVM_LOW)
             m_dmi_cache_q[m_find_q[0]].print();
             m_dmi_cache_q.delete(m_find_q[0]);
             //#Check.DMI.Concerto.v3.0.AiuWayCollison
           end 
           else if (m_find_q.size()>1) begin
             `uvm_error ("<%=obj.BlockId%>:processMaintop:32",$sformatf("More than one cacheline found with same index and way"));
           end
           else begin
             if ((cpy_pkt.evictstate != IX) ||(cpy_pkt.currstate != IX)) begin
                `uvm_error("<%=obj.BlockId%>:processMaintop:33",$sformatf("In flush operation evictstate mismatch Got: %s Exp: IX",
                 cpy_pkt.evictstate ));
             end
           end
         end
         else if ((mntOpType == 'h6) || (mntOpType == 'h7)) begin
           m_find_q = {};
           m_find_q = m_dmi_cache_q.find_index() with (
                                               cl_aligned(item.addr)  == cl_aligned(cpy_pkt.addr)   &&
                                               item.security  == cpy_pkt.security
                                               );
           if(m_find_q.size()==1) begin
             if((cpy_pkt.evictstate != m_dmi_cache_q[m_find_q[0]].state) ||
                (cpy_pkt.currstate  != m_dmi_cache_q[m_find_q[0]].state)) begin
                `uvm_error("<%=obj.BlockId%>:processMaintop:34",$sformatf("In flush operation evictstate mismatch Got: %s Exp: %s",
                 cpy_pkt.evictstate, m_dmi_cache_q[m_find_q[0]].state));
             end
             if(onehot_to_binary(cpy_pkt.hitwayn) != m_dmi_cache_q[m_find_q[0]].way) begin
               `uvm_error("<%=obj.BlockId%>:processMaintop:35",$sformatf("In flush operation hitway mismatch Got: %0b Exp: %0b",
                                  onehot_to_binary(cpy_pkt.hitwayn), m_dmi_cache_q[m_find_q[0]].way));
             end

             // Locked caheline should not be evicted
             if(m_dmi_cache_q[m_find_q[0]].isPending) begin
                `uvm_error ("<%=obj.BlockId%>:processMaintop:36",$sformatf("Cacheline evicted for which fill is pending"));
             end

             m_dmi_cache_q[m_find_q[0]].print();
             m_dmi_cache_q.delete(m_find_q[0]);
             end
             else if (m_find_q.size()>1) begin
               `uvm_error ("<%=obj.BlockId%>:processMaintop:37",$sformatf("More than one cacheline found with same index and way"));
             end
             else begin
               if ((cpy_pkt.evictstate != IX) ||(cpy_pkt.currstate != IX)) begin
                  `uvm_error("<%=obj.BlockId%>:processMaintop:38",$sformatf("In flush operation evictstate mismatch Got: %s Exp: IX",
                   cpy_pkt.evictstate ));
               end
             end
           end //m_find_q.size()==1
         end//mntOpType
       end//Flush fail p2
     end//Flush all

   if(!cpy_pkt.isMntOp && !cpy_pkt.isRead && !cpy_pkt.isWrite &&
      !cpy_pkt.isSnoop && !cpy_pkt.isRead_Wakeup && !cpy_pkt.isWrite_Wakeup &&
      !cpy_pkt.nack
      ) begin

      //Ensure no control signal are asserted when there is no valid txn.
      // Tb is unable to determine whether it is a Read/Write/Snoop or MntOp
      if(cpy_pkt.tagstateup) begin
        spkt = { "ctrlop_tagstateup signal should not be asserted for a txn",
                 " whose valid is not asserted i.e isRead,isWrite,isSnoop or ",
                 " isMntOp is not asserted "};
        `uvm_error("<%=obj.BlockId%>:processMaintop:39", $psprintf(spkt))
      end

      //Removed based on boon and parimal request that since setway_debug
      // is a timing sensitive signal so it will be asserted randomly but
      // ctrl signal associated with it won't be asserted.
      //if(cpy_pkt.setway_debug) begin
      //    spkt = { "ctrlop_setway_debug signal should not be asserted for a txn",
      //             " whose valid is not asserted i.e isRead,isWrite,isSnoop or ",
      //             " isMntOp is not asserted "};
      //    `uvm_error(`LABEL_ERROR, $psprintf(spkt))
      //end

      if(cpy_pkt.rp_update) begin
        spkt = { "ctrlop_rp_update signal should not be asserted for a txn",
                 " whose valid is not asserted i.e isRead,isWrite,isSnoop or ",
                 " isMntOp is not asserted "};
        `uvm_error("<%=obj.BlockId%>:processMaintop:40", $psprintf(spkt))
      end

      if(cpy_pkt.rd_data) begin
        spkt = { "ctrlop_rd_data signal should not be asserted for a txn",
                 " whose valid is not asserted i.e isRead,isWrite,isSnoop or ",
                 " isMntOp is not asserted "};
        `uvm_error("<%=obj.BlockId%>:processMaintop:41", $psprintf(spkt))
      end

      if(cpy_pkt.wr_data) begin
        spkt = { "ctrlop_wr_data signal should not be asserted for a txn",
                 " whose valid is not asserted i.e isRead,isWrite,isSnoop or ",
                 " isMntOp is not asserted "};
        `uvm_error("<%=obj.BlockId%>:processMaintop:42", $psprintf(spkt))
      end

      if(cpy_pkt.alloc) begin
        spkt = { "ctrlop_alloc signal should not be asserted for a txn",
                 " whose valid is not asserted i.e isRead,isWrite,isSnoop or ",
                 " isMntOp is not asserted "};
        `uvm_error("<%=obj.BlockId%>:processMaintop:43", $psprintf(spkt))
      end
    end

    //Ensure tag is never updated for this condition
    if(cpy_pkt.nack || cpy_pkt.nackuce) begin
      if(cpy_pkt.tagstateup) begin
        spkt = { "ctrlop_tagstateup signal should not be asserted for a txn",
                 " whose valid is not asserted i.e isRead,isWrite,isSnoop or ",
                 " isMntOp is not asserted "};
        `uvm_error("<%=obj.BlockId%>:processMaintop:44", $psprintf(spkt))
      end
    end

    `uvm_info("<%=obj.BlockId%>:processMaintop", $psprintf("ccp_control_channel finish"),UVM_MEDIUM)

endfunction // processMaintop//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

function void dmi_scoreboard::update_raw_dependency(smi_addr_t m_addr);
    int tmp_q[$];
    tmp_q = rtt_q.find_index with ( (item.isMrd)  &&
                                    item.wrOutstandingFlag &&
                                    (cl_aligned((item.cache_addr)) === cl_aligned(m_addr)));
    foreach(tmp_q[i])begin
      `uvm_info("UPDATE_RTT_RAW",$sformatf("Received a write cache hit on Addr:%0h ,clearing write outstanding flag on read Addr:%0h", m_addr, rtt_q[tmp_q[i]].cache_addr),UVM_MEDIUM)
      rtt_q[tmp_q[i]].wrOutstandingFlag = 0;
    end
endfunction//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

function void dmi_scoreboard::processCacheWr(ccp_ctrl_pkt_t cache_ctrl_pkt);
  int tmp_q[$],tmp_q1[$], tmp_q2[$],tmp_q3[$],tmp_q4[$],tmp_q5[$],cov_q[$],tmp_q9[$];

  bit [8:0] cachevector;
  ccp_ctrlop_waybusy_vec_t m_busyway;
  ccp_wr_data_pkt_t cache_wr_data_pkt_exp;
  int aiu_no,initiator_agent_id;
  bit agent_id_match;
  int match;
  time oldest;
  `uvm_info("<%=obj.BlockId%>:processCacheWr", $sformatf("ccp_ctrl_pkt_t: %s ",cache_ctrl_pkt.sprint_pkt()), UVM_MEDIUM);
  tmp_q = {};
  tmp_q1 = {};

  match = 0;

  if(cache_ctrl_pkt.isCoh)begin
    tmp_q = wtt_q.find_index with (item.isCoh &&
                                   (item.cache_addr == cache_ctrl_pkt.addr) && 
                                   (item.security   == cache_ctrl_pkt.security) && 
                                   (item.DTW_req_recd == 1) && 
                                   (item.lookupExpd == 1) && 
                                   (item.lookupSeen == 0));
  end
  else begin
    tmp_q = wtt_q.find_index with (!item.isCoh &&
                                   (item.cache_addr == cache_ctrl_pkt.addr) && 
                                   (item.security   == cache_ctrl_pkt.security) && 
                                   (item.DTW_req_recd == 1) && 
                                   (item.lookupExpd == 1) && 
                                   (item.lookupSeen == 0));
    if(tmp_q.size()>1)begin
      tmp_q = wtt_q.find_index with (!item.isCoh &&
                                     (item.cache_addr == cache_ctrl_pkt.addr) && 
                                     (item.security   == cache_ctrl_pkt.security) && 
                                     (item.DTW_req_recd == 1) && 
                                     (item.CMD_rsp_recd_rtl == 1) && 
                                     (item.lookupExpd == 1) && 
                                     (item.lookupSeen == 0));

      oldest = wtt_q[tmp_q[0]].t_creation;
      if(tmp_q.size()>1)begin
        foreach (tmp_q[i]) begin
          if (wtt_q[tmp_q[i]].t_creation < oldest) begin
            oldest = wtt_q[tmp_q[i]].t_creation;
            match = i;
          end
        end
      end
    end
  end

  //tmp_q = wtt_q.find_index with  ((item.cache_addr == cache_ctrl_pkt.addr) && 
  //                               (item.security   == cache_ctrl_pkt.security) && 
  //                               (item.DTW_req_recd == 1) && 
  //                               (item.lookupExpd == 1) && 
  //                               (item.lookupSeen == 0));
  //

  tmp_q9 = {};
  tmp_q9 = rtt_q.find_index with ((item.isCoh == wtt_q[tmp_q[match]].isCoh) &&
                                  (beat_aligned((item.cache_addr)) == beat_aligned(wtt_q[tmp_q[match]].cache_addr)) &&
                                  (item.security == wtt_q[tmp_q[match]].security) &&
                                  ((item.isCoh)?item.MRD_req_recd_rtl:item.CMD_rsp_recd_rtl) &&
                                  (item.t_creation < wtt_q[tmp_q[match]].t_creation) && 
                                  (item.lookupExpd == 1) &&
                                  (item.lookupSeen == 0));
  
  if(tmp_q9.size() > 0) begin
    foreach(tmp_q9[i]) begin
      rtt_q[tmp_q9[i]].print_entry;
    end
    `uvm_error("<%=obj.BlockId%>:processCacheWr:ordercheck", $sformatf("write txn came on CCP ctrl channel before the above old read transaction"));
  end

  `ifndef FSYS_COVER_ON
  cov.collect_ccp_wr_inflight(wtt_q, cache_ctrl_pkt);
  `endif
  if(tmp_q.size() === 0) begin
    `uvm_info("<%=obj.BlockId%>:processCacheWr:00", $sformatf("%1p",cache_ctrl_pkt), UVM_LOW)
    `uvm_error("<%=obj.BlockId%>:processCacheWr:00"," Above packet has no matching DTW")
  end
  else begin
    // Busy vector check
    m_busyway = get_busy_way(cache_ctrl_pkt.addr);
    `uvm_info("<%=obj.BlockId%>:processCacheWr:01",$sformatf("m_busyway :%0b sp_ways :%0b sp_enabled :%0b",m_busyway,sp_ways,sp_enabled),UVM_MEDIUM);
    if(sp_enabled)begin
      rsvd_ways     = (2**sp_ways) - 1;
      m_busyway = m_busyway | sp_ways;
    end
    else begin
      m_busyway = m_busyway ;
    end

    <% if(obj.useCmc && obj.DmiInfo[obj.Id].useWayPartitioning==1) {%>
    if(isdtwmrgmrd(wtt_q[tmp_q[match]].dtw_msg_type))begin
      initiator_agent_id =  wtt_q[tmp_q[match]].dtw_req_pkt.smi_mpf1[WSMINCOREUNITID-1:0];
    end
    else begin
      initiator_agent_id = wtt_q[tmp_q[match]].dtw_req_pkt.smi_src_ncore_unit_id;
    end

    `uvm_info("<%=obj.BlockId%>:processCacheWr:02",$sformatf("initiator_agent_id :%0d  m_busyway :%0b",initiator_agent_id,m_busyway),UVM_MEDIUM);
    for(int i=0; i<  <%=obj.DmiInfo[obj.Id].nAius%>; i++) begin
      if(aiu_funit_id[(<%=wFUnit%>*(i+1)-1)-:<%=wFUnit%>] == initiator_agent_id) begin
        aiu_no = i;
        break;
      end
    end

    `uvm_info("<%=obj.BlockId%>:processCacheWr:03",$sformatf("aiu_funit_id :%0b m_busyway :%0b",aiu_funit_id,m_busyway),UVM_MEDIUM);
    //#Check.DMI.Concerto.v3.0.WayPartionWayBusyvec
    for(int i=0; i < N_WAY_PART; i++) begin
      if((aiu_no == way_partition_reg_id[i]) && way_partition_vld[i] && !agent_id_match) begin
        m_busyway = ~way_partition_reg_way[i];
        agent_id_match = 1;
      end
      else if ((aiu_no == way_partition_reg_id[i]) && way_partition_vld[i] && agent_id_match) begin
        `uvm_error("<%=obj.BlockId%>:processCacheWr:04",$sformatf("two source ids of way partitionig registers are same"));
      end
    end

    `uvm_info("<%=obj.BlockId%>:processCacheWr:05",$sformatf("aiu_no :%0d",aiu_no),UVM_MEDIUM);
    if(agent_id_match == 0) begin
      for(int i=0; i < N_WAY_PART; i++) begin
        if (way_partition_vld[i]) m_busyway = m_busyway | way_partition_reg_way[i];
      end
    end
    <%}%>

    `uvm_info("<%=obj.BlockId%>:processCacheWr:06",$sformatf("m_busyway :%0b",m_busyway),UVM_MEDIUM);
    // TODO: Fix this check for atomic transactions (CONC-5037)
    if(!$test$plusargs("add_atomic") && uncorr_wrbuffer_err == 0) begin
      foreach(m_busyway[i])begin
        if(m_busyway[i] & !cache_ctrl_pkt.waypbusy_vec[i])begin
          `uvm_error("<%=obj.BlockId%>:processCacheWr:07",$sformatf("m_busyway way :%0d Expected :%0b Got :%0b",i,m_busyway,cache_ctrl_pkt.waypbusy_vec));
        end
      end
    end

    cachevector = {cache_ctrl_pkt.alloc,cache_ctrl_pkt.rd_data,cache_ctrl_pkt.wr_data,
                   cache_ctrl_pkt.bypass,cache_ctrl_pkt.rp_update,
                   cache_ctrl_pkt.tagstateup,cache_ctrl_pkt.setway_debug};
    if(!ccp_if_en)begin
      if(cache_ctrl_pkt.currstate !== IX)begin
        `uvm_info("<%=obj.BlockId%>:processCacheWr:08",$sformatf("%1p",cache_ctrl_pkt), UVM_LOW)
        `uvm_error("<%=obj.BlockId%>:processCacheWr:08",$sformatf("currstate:%0s  expd: IX",cache_ctrl_pkt.currstate.name()))
      end
    end
    //#Check.DMI.Concerto.v3.0.Dtwtable6
    if(!cache_ctrl_pkt.nackuce)begin
      if(cache_ctrl_pkt.currstate !== IX && cache_ctrl_pkt.wr_data && cache_ctrl_pkt.bypass)begin
        wtt_q[tmp_q[match]].isWrThBypass = 1;
      end
      case(wtt_q[tmp_q[match]].dtw_req_pkt.smi_msg_type)
        DTW_DATA_PTL: begin
                       // if miss
                        if(cache_ctrl_pkt.currstate === IX) begin
                          // check that allocate_p2 is 0
                          // readdata, writedata, bypass, tagstate, setwaydebug, cancel, rp_update, evict are 0
                          if(cache_ctrl_pkt.alloc |
                             cache_ctrl_pkt.rd_data |
                             cache_ctrl_pkt.wr_data |
                             cache_ctrl_pkt.tagstateup |
                             cache_ctrl_pkt.setway_debug |
                             cache_ctrl_pkt.rp_update)begin
                             `uvm_info("<%=obj.BlockId%>:processCacheWr:2", $sformatf("%1p",cache_ctrl_pkt), UVM_LOW)
                             `uvm_error("<%=obj.BlockId%>:processCacheWr:2",
                                        $sformatf("{allocate_p2|rd_data|wr_data|tagstateup|setwaydebug|rp_update}:%0b%0b%0b %0b%0b%0b  expd: all zeros",
                                                  cache_ctrl_pkt.alloc,
                                                  cache_ctrl_pkt.rd_data,
                                                  cache_ctrl_pkt.wr_data,
                                                  cache_ctrl_pkt.tagstateup,
                                                  cache_ctrl_pkt.setway_debug,
                                                  cache_ctrl_pkt.rp_update))
                          end
                          if(cache_ctrl_pkt.bypass == 0) begin
                             `uvm_info("<%=obj.BlockId%>:processCacheWr:3", $sformatf("%1p",cache_ctrl_pkt), UVM_LOW)
                             `uvm_error("<%=obj.BlockId%>:processCacheWr:3",
                                        $sformatf("{bypass}:%0b  expd: 1",cache_ctrl_pkt.bypass))
                          end
                          // burst_len matches what? busy vec?
                          // what is rsp_evict? ?
                          //merge_write_data(tmp_q[match],wtt_q[tmp_q[match]].dtw_req_pkt,1);
                          // DV: set lookupSeen = 1
                          wtt_q[tmp_q[match]].bypassExpd = cache_ctrl_pkt.bypass;
                          if(!cache_ctrl_pkt.rsp_evict_sel) begin
                            wtt_q[tmp_q[match]].cacheRspExpd  =  cache_ctrl_pkt.bypass;
                          end else begin
                            wtt_q[tmp_q[match]].evictDataExpd =  cache_ctrl_pkt.bypass;
                          end
                          wtt_q[tmp_q[match]].cacheWrDataExpd = 1;
                          wtt_q[tmp_q[match]].AXI_write_addr_expd = 1;
                          wtt_q[tmp_q[match]].AXI_write_data_expd = 1;
                          wtt_q[tmp_q[match]].AXI_write_resp_expd = 1;
                          wtt_q[tmp_q[match]].cache_ctrl_pkt = cache_ctrl_pkt;
                          wtt_q[tmp_q[match]].lookupSeen = 1;
                          wtt_q[tmp_q[match]].isCacheMiss = 1;
                          wtt_q[tmp_q[match]].t_lookup = $time;
                          wtt_q[tmp_q[match]].t_latest_update = $time;
                          wtt_q[tmp_q[match]].print_entry();
                        end // if (cache_ctrl_pkt.currstate === IX)
                        else begin
                          //#Check.DMI.v2.DTWCacheDtwDataPtlAlloc
                          //#Check.DMI.v2.DTWCacheDtwDataPtlVisible
                           // if hit and SV
                           // if hit and CV
                          if(((wtt_q[tmp_q[match]].smi_vz)^(cache_ctrl_pkt.bypass))) begin // bypass if SV, no bypass if CV
                               `uvm_info("<%=obj.BlockId%>:processCacheWr:4", $sformatf("%1p",cache_ctrl_pkt), UVM_LOW)
                               `uvm_error("<%=obj.BlockId%>:processCacheWr:4",
                                          $sformatf("{attr|bypass}:%0b%0b  expd: SV -> bypass; CV -> no bypass",
                                                    wtt_q[tmp_q[match]].smi_vz,
                                                    cache_ctrl_pkt.bypass))
                          end

                          if(!(cache_ctrl_pkt.wr_data && cache_ctrl_pkt.rp_update)) begin
                             `uvm_info("<%=obj.BlockId%>:processCacheWr:5", $sformatf("%1p",cache_ctrl_pkt), UVM_LOW)
                             `uvm_error("<%=obj.BlockId%>:processCacheWr:5",
                                        $sformatf("{wr_data|rp_update}:%0b%0b expd: 11 ",
                                                  cache_ctrl_pkt.wr_data,
                                                  cache_ctrl_pkt.rp_update))
                          end

                          if(wtt_q[tmp_q[match]].smi_vz) begin
                            if(cache_ctrl_pkt.currstate == UD) begin
                               if(!(cache_ctrl_pkt.tagstateup &&  (cache_ctrl_pkt.state == SC))) begin
                                  `uvm_info("<%=obj.BlockId%>:processCacheWr:6", $sformatf("%1p",cache_ctrl_pkt), UVM_LOW)
                                  `uvm_error("<%=obj.BlockId%>:processCacheWr:6",
                                             $sformatf("{tagstateup}:%0b expd: 1 exp state :SC state :%0s ",
                                                       cache_ctrl_pkt.tagstateup, cache_ctrl_pkt.state.name()))
                               end
                            end
                            else begin
                               if(cache_ctrl_pkt.tagstateup) begin
                                 if(cache_ctrl_pkt.state !== SC) begin
                                    `uvm_info("<%=obj.BlockId%>:processCacheWr:7", $sformatf("%1p",cache_ctrl_pkt), UVM_LOW)
                                    `uvm_error("<%=obj.BlockId%>:processCacheWr:7",
                                               $sformatf("{tagstateup}:%0b expd: 1 exp state :SC state :%0s ",
                                                         cache_ctrl_pkt.tagstateup, cache_ctrl_pkt.state.name()))
                                 end
                               end
                            end
                          end
                          else begin
                            if(cache_ctrl_pkt.currstate == SC) begin
                               if(!(cache_ctrl_pkt.tagstateup &&  (cache_ctrl_pkt.state == UD))) begin
                                  `uvm_info("<%=obj.BlockId%>:processCacheWr:8", $sformatf("%1p",cache_ctrl_pkt), UVM_LOW)
                                  `uvm_error("<%=obj.BlockId%>:processCacheWr:8",
                                             $sformatf("{tagstateup}:%0b expd: 1 exp state :UD state :%0s ",
                                                       cache_ctrl_pkt.tagstateup, cache_ctrl_pkt.state.name()))
                               end
                            end
                            else begin
                               if(cache_ctrl_pkt.tagstateup) begin
                                 if(cache_ctrl_pkt.state !== UD) begin
                                    `uvm_info("<%=obj.BlockId%>:processCacheWr:9", $sformatf("%1p",cache_ctrl_pkt), UVM_LOW)
                                    `uvm_error("<%=obj.BlockId%>:processCacheWr:9",
                                               $sformatf("{tagstateup}:%0b expd: 1 exp state :UD state :%0s ",
                                                         cache_ctrl_pkt.tagstateup, cache_ctrl_pkt.state.name()))
                                 end
                               end
                            end
                          end

                          if(cache_ctrl_pkt.alloc |
                             cache_ctrl_pkt.rd_data |
                             cache_ctrl_pkt.setway_debug) begin
                             `uvm_info("<%=obj.BlockId%>:processCacheWr:10", $sformatf("%1p",cache_ctrl_pkt), UVM_LOW)
                             `uvm_error("<%=obj.BlockId%>:processCacheWr:10",
                                        $sformatf("{allocate_p2|rd_data|setwaydebug}:%0b%0b%0b expd: all zeros",
                                                  cache_ctrl_pkt.alloc,
                                                  cache_ctrl_pkt.rd_data,
                                                  cache_ctrl_pkt.setway_debug))
                          end
                          
                          wtt_q[tmp_q[match]].cacheWrDataExpd = 1;
                          wtt_q[tmp_q[match]].bypassExpd = cache_ctrl_pkt.bypass;
                          if(!cache_ctrl_pkt.rsp_evict_sel) begin
                            wtt_q[tmp_q[match]].cacheRspExpd  =  cache_ctrl_pkt.bypass;
                          end
                          else begin
                            wtt_q[tmp_q[match]].evictDataExpd =  cache_ctrl_pkt.bypass;
                          end

                          if(!cache_ctrl_pkt.bypass)begin
                            wtt_q[tmp_q[match]].AXI_write_addr_expd = 0;
                            wtt_q[tmp_q[match]].AXI_write_data_expd = 0;
                            wtt_q[tmp_q[match]].AXI_write_resp_expd = 0;
                          end
                          else begin
                            wtt_q[tmp_q[match]].AXI_write_addr_expd = 1;
                            wtt_q[tmp_q[match]].AXI_write_data_expd = 1;
                            wtt_q[tmp_q[match]].AXI_write_resp_expd = 1;
                          end
                          wtt_q[tmp_q[match]].cache_ctrl_pkt = cache_ctrl_pkt;
                          wtt_q[tmp_q[match]].lookupSeen = 1;
                          wtt_q[tmp_q[match]].isCacheHit = 1;
                          wtt_q[tmp_q[match]].t_lookup = $time;
                          wtt_q[tmp_q[match]].t_latest_update = $time;
                          wtt_q[tmp_q[match]].print_entry();
                        end // else: !if(cache_ctrl_pkt.currstate === IX)
                      end // case: DTW_DATA_PTL
        DTW_DATA_DTY: begin
                        if(cache_ctrl_pkt.currstate === IX) begin //If Dirty
                          //#Check.DMI.Concerto.v3.0.WriteDtyAllocDisable
                          //#Check.DMI.Concerto.v3.0.WrAllocationDisbale
                          if(!(!DtyWrAllocDisable && alloc_en && !WrAllocDisable) || !lookup_en) begin 
                            if(cachevector !== 7'b0001000) begin
                              `uvm_info("<%=obj.BlockId%>:processCacheWr:11", $sformatf("%1p",cache_ctrl_pkt), UVM_LOW)
                               wtt_q[tmp_q[match]].print_entry();
                              `uvm_error("<%=obj.BlockId%>:processCacheWr:11",
                                         $sformatf("{allocate_p2|rd_data|wr_data|bypass|rp_update|tagstateup|setwaydebug|}:%0b%0b%0b %0b%0b%0b %0b expd: 7'b0001000",
                                                 cache_ctrl_pkt.alloc, cache_ctrl_pkt.rd_data, cache_ctrl_pkt.wr_data,
                                                 cache_ctrl_pkt.bypass, cache_ctrl_pkt.rp_update,
                                                 cache_ctrl_pkt.tagstateup, cache_ctrl_pkt.setway_debug))
                            end
                            wtt_q[tmp_q[match]].AXI_write_addr_expd = 1;
                            wtt_q[tmp_q[match]].AXI_write_data_expd = 1;
                            wtt_q[tmp_q[match]].AXI_write_resp_expd = 1;
                          end
                          else begin
                           if(wtt_q[tmp_q[match]].smi_vz == 1 || !ccp_if_en) begin
                            // if miss and SV
                             if(cachevector !== 7'b0001000) begin
                               `uvm_info("<%=obj.BlockId%>:processCacheWr:12", $sformatf("%1p",cache_ctrl_pkt), UVM_LOW)
                                wtt_q[tmp_q[match]].print_entry();
                               `uvm_error("<%=obj.BlockId%>:processCacheWr:12",
                                          $sformatf("{allocate_p2|rd_data|wr_data|bypass|rp_update|tagstateup|setwaydebug|}:%0b%0b%0b %0b%0b%0b %0b expd:7'b0001000",
                                                    cache_ctrl_pkt.alloc, cache_ctrl_pkt.rd_data, cache_ctrl_pkt.wr_data,
                                                    cache_ctrl_pkt.bypass, cache_ctrl_pkt.rp_update,
                                                    cache_ctrl_pkt.tagstateup, cache_ctrl_pkt.setway_debug))
                             end
                             wtt_q[tmp_q[match]].AXI_write_addr_expd = 1;
                             wtt_q[tmp_q[match]].AXI_write_data_expd = 1;
                             wtt_q[tmp_q[match]].AXI_write_resp_expd = 1;
                           end // if (wtt_q[tmp_q[match]].dtw_req_pkt.dtw_req.msg_attr[0] == 0)
                           else begin
                             //if miss and CV
                             //if((wtt_q[tmp_q[match]].smi_ac == 0) || (wtt_q[tmp_q[match]].smi_size < SYS_wSysCacheline)) begin
                             if(wtt_q[tmp_q[match]].smi_ac == 0) begin
                               // if NA
                               if(cachevector !== 7'b0001000) begin
                                 `uvm_info("<%=obj.BlockId%>:processCacheWr:13", $sformatf("%1p",cache_ctrl_pkt), UVM_LOW)
                                  wtt_q[tmp_q[match]].print_entry();
                                 `uvm_error("<%=obj.BlockId%>:processCacheWr:13",
                                            $sformatf("{allocate_p2|rd_data|wr_data|bypass|rp_update|tagstateup|setwaydebug|}:%0b%0b%0b %0b%0b%0b %0b expd: 7'b0001000",
                                                    cache_ctrl_pkt.alloc, cache_ctrl_pkt.rd_data, cache_ctrl_pkt.wr_data,
                                                    cache_ctrl_pkt.bypass, cache_ctrl_pkt.rp_update,
                                                    cache_ctrl_pkt.tagstateup, cache_ctrl_pkt.setway_debug))
                               end
                               wtt_q[tmp_q[match]].AXI_write_addr_expd = 1;
                               wtt_q[tmp_q[match]].AXI_write_data_expd = 1;
                               wtt_q[tmp_q[match]].AXI_write_resp_expd = 1;
                             end
                             else begin
                             // if AL
                             if(!(cache_ctrl_pkt.nacknoalloc || cache_ctrl_pkt.isWttanyfull || cache_ctrl_pkt.isWttfull || cache_ctrl_pkt.isWrfifofull))begin
                               if((cache_ctrl_pkt.evictvld && cache_ctrl_pkt.evictstate !== UD))begin
                                 if(cachevector !== 7'b1010110) begin
                                   `uvm_info("<%=obj.BlockId%>:processCacheWr:14", $sformatf("%1p",cache_ctrl_pkt), UVM_LOW)
                                   `uvm_error("<%=obj.BlockId%>:processCacheWr:14",
                                              $sformatf("{allocate_p2|rd_data|wr_data|bypass|rp_update|tagstateup|setwaydebug|}:%0b%0b%0b %0b%0b%0b %0b expd: 7'b1010110",
                                                      cache_ctrl_pkt.alloc, cache_ctrl_pkt.rd_data, cache_ctrl_pkt.wr_data,
                                                      cache_ctrl_pkt.bypass, cache_ctrl_pkt.rp_update,
                                                      cache_ctrl_pkt.tagstateup, cache_ctrl_pkt.setway_debug))
                                 end
                               end
                               else if(!cache_ctrl_pkt.evictvld )begin
                                 if(cachevector !== 7'b1010110) begin
                                   `uvm_info("<%=obj.BlockId%>:processCacheWr:15", $sformatf("%1p",cache_ctrl_pkt), UVM_LOW)
                                    wtt_q[tmp_q[match]].print_entry();
                                   `uvm_error("<%=obj.BlockId%>:processCacheWr:15",
                                              $sformatf("{allocate_p2|rd_data|wr_data|bypass|rp_update|tagstateup|setwaydebug|}:%0b%0b%0b %0b%0b%0b %0b expd: 7'b1010110",
                                                      cache_ctrl_pkt.alloc, cache_ctrl_pkt.rd_data, cache_ctrl_pkt.wr_data,
                                                      cache_ctrl_pkt.bypass, cache_ctrl_pkt.rp_update,
                                                      cache_ctrl_pkt.tagstateup, cache_ctrl_pkt.setway_debug))
                                 end
                               end
                               else  begin
                                 if(cachevector !== 7'b1110110) begin
                                   `uvm_info("<%=obj.BlockId%>:processCacheWr:16", $sformatf("%1p",cache_ctrl_pkt), UVM_LOW)
                                   `uvm_error("<%=obj.BlockId%>:processCacheWr:16",
                                              $sformatf("{allocate_p2|rd_data|wr_data|bypass|rp_update|tagstateup|setwaydebug|}:%0b%0b%0b %0b%0b%0b %0b expd: 7'b1110110",
                                                     cache_ctrl_pkt.alloc, cache_ctrl_pkt.rd_data, cache_ctrl_pkt.wr_data,
                                                     cache_ctrl_pkt.bypass, cache_ctrl_pkt.rp_update,
                                                     cache_ctrl_pkt.tagstateup, cache_ctrl_pkt.setway_debug))
                                 end
                               end
                               if(cache_ctrl_pkt.tagstateup)begin
                                 if (!(cache_ctrl_pkt.state == UD)) begin
                                   `uvm_info("<%=obj.BlockId%>:processCacheWr:17", $sformatf("%1p",cache_ctrl_pkt), UVM_LOW)
                                     wtt_q[tmp_q[match]].print_entry();
                                   `uvm_error("<%=obj.BlockId%>:processCacheWr:17",$sformatf("cache_ctrl_pkt.state should be UD"));
                                 end
                               end
                               wtt_q[tmp_q[match]].AXI_write_addr_expd = 0;
                               wtt_q[tmp_q[match]].AXI_write_data_expd = 0;
                               wtt_q[tmp_q[match]].AXI_write_resp_expd = 0;
                             end
                             else begin
                               if(cachevector[5:0] !== 6'b001000) begin
                                 `uvm_info("<%=obj.BlockId%>:processCacheWr:18", $sformatf("%1p",cache_ctrl_pkt), UVM_LOW)
                                  wtt_q[tmp_q[match]].print_entry();
                                 `uvm_error("<%=obj.BlockId%>:processCacheWr:18",
                                            $sformatf("{rd_data|wr_data|bypass|rp_update|tagstateup|setwaydebug|}:%0b%0b%0b %0b%0b%0b expd: 6'b001000",
                                                    cache_ctrl_pkt.rd_data, cache_ctrl_pkt.wr_data,
                                                    cache_ctrl_pkt.bypass, cache_ctrl_pkt.rp_update,
                                                    cache_ctrl_pkt.tagstateup, cache_ctrl_pkt.setway_debug))
                               end
                               wtt_q[tmp_q[match]].AXI_write_addr_expd = 1;
                               wtt_q[tmp_q[match]].AXI_write_data_expd = 1;
                               wtt_q[tmp_q[match]].AXI_write_resp_expd = 1;
                             end
                            end // else: !if(wtt_q[tmp_q[match]].smi_ac == 1)
                           end // else: !if(wtt_q[tmp_q[match]].smi_vz == 1)
                          end
                           wtt_q[tmp_q[match]].cache_ctrl_pkt = cache_ctrl_pkt;
                           wtt_q[tmp_q[match]].lookupSeen = 1;
                           wtt_q[tmp_q[match]].isCacheMiss = 1;
                           wtt_q[tmp_q[match]].cacheWrDataExpd = 1;
                           wtt_q[tmp_q[match]].bypassExpd = cache_ctrl_pkt.bypass;
                           if(!cache_ctrl_pkt.rsp_evict_sel) begin
                             wtt_q[tmp_q[match]].cacheRspExpd  =  cache_ctrl_pkt.bypass;
                           end else begin
                             wtt_q[tmp_q[match]].evictDataExpd =  cache_ctrl_pkt.bypass;
                           end
                           wtt_q[tmp_q[match]].t_lookup = $time;
                           wtt_q[tmp_q[match]].t_latest_update = $time;
                           wtt_q[tmp_q[match]].print_entry();
                         end // if (cache_ctrl_pkt.currstate === IX)
                         else begin
                          if(!(cache_ctrl_pkt.wr_data && cache_ctrl_pkt.rp_update)) begin
                             `uvm_info("<%=obj.BlockId%>:processCacheWr:19", $sformatf("%1p",cache_ctrl_pkt), UVM_LOW)
                             `uvm_error("<%=obj.BlockId%>:processCacheWr:19",
                                        $sformatf("{wr_data|rp_update}:%0b%0b expd: 11 ",
                                                  cache_ctrl_pkt.wr_data,
                                                  cache_ctrl_pkt.rp_update))
                          end
                           // if hit and SV
                          if(wtt_q[tmp_q[match]].smi_vz) begin
                            if(cache_ctrl_pkt.currstate == UD) begin
                               if(!(cache_ctrl_pkt.tagstateup &&  (cache_ctrl_pkt.state == SC))) begin
                                  `uvm_info("<%=obj.BlockId%>:processCacheWr:20", $sformatf("%1p",cache_ctrl_pkt), UVM_LOW)
                                  `uvm_error("<%=obj.BlockId%>:processCacheWr:20",
                                             $sformatf("{tagstateup}:%0b expd: 1 exp state :SC state :%0s ",
                                                       cache_ctrl_pkt.tagstateup, cache_ctrl_pkt.state.name()))
                               end
                            end
                            else begin
                               if(cache_ctrl_pkt.tagstateup) begin
                                 if(cache_ctrl_pkt.state !== SC) begin
                                    `uvm_info("<%=obj.BlockId%>:processCacheWr:21", $sformatf("%1p",cache_ctrl_pkt), UVM_LOW)
                                    `uvm_error("<%=obj.BlockId%>:processCacheWr:21",
                                               $sformatf("{tagstateup}:%0b expd: 1 exp state :SC state :%0s ",
                                                         cache_ctrl_pkt.tagstateup, cache_ctrl_pkt.state.name()))
                                 end
                               end
                            end
                            wtt_q[tmp_q[match]].AXI_write_addr_expd = 1;
                            wtt_q[tmp_q[match]].AXI_write_data_expd = 1;
                            wtt_q[tmp_q[match]].AXI_write_resp_expd = 1;
                          end
                          else begin
                            if(cache_ctrl_pkt.currstate == SC) begin
                               if(!(cache_ctrl_pkt.tagstateup &&  (cache_ctrl_pkt.state == UD))) begin
                                  `uvm_info("<%=obj.BlockId%>:processCacheWr:22", $sformatf("%1p",cache_ctrl_pkt), UVM_LOW)
                                  `uvm_error("<%=obj.BlockId%>:processCacheWr:22",
                                             $sformatf("{tagstateup}:%0b expd: 1 exp state :UD state :%0s ",
                                                       cache_ctrl_pkt.tagstateup, cache_ctrl_pkt.state.name()))
                               end
                            end
                            else begin
                               if(cache_ctrl_pkt.tagstateup) begin
                                 if(cache_ctrl_pkt.state !== UD) begin
                                    `uvm_info("<%=obj.BlockId%>:processCacheWr:23", $sformatf("%1p",cache_ctrl_pkt), UVM_LOW)
                                    `uvm_error("<%=obj.BlockId%>:processCacheWr:23",
                                               $sformatf("{tagstateup}:%0b expd: 1 exp state :UD state :%0s ",
                                                         cache_ctrl_pkt.tagstateup, cache_ctrl_pkt.state.name()))
                                 end
                               end
                            end
                            wtt_q[tmp_q[match]].AXI_write_addr_expd = 0;
                            wtt_q[tmp_q[match]].AXI_write_data_expd = 0;
                            wtt_q[tmp_q[match]].AXI_write_resp_expd = 0;
                          end
                           wtt_q[tmp_q[match]].cache_ctrl_pkt = cache_ctrl_pkt;
                           wtt_q[tmp_q[match]].lookupSeen = 1;
                           wtt_q[tmp_q[match]].isCacheHit = 1;
                           wtt_q[tmp_q[match]].cacheWrDataExpd = 1;
                           wtt_q[tmp_q[match]].bypassExpd = cache_ctrl_pkt.bypass;
                           if(!cache_ctrl_pkt.rsp_evict_sel) begin
                             wtt_q[tmp_q[match]].cacheRspExpd  =  cache_ctrl_pkt.bypass;
                           end else begin
                             wtt_q[tmp_q[match]].evictDataExpd =  cache_ctrl_pkt.bypass;
                           end
                           wtt_q[tmp_q[match]].t_lookup = $time;
                           wtt_q[tmp_q[match]].t_latest_update = $time;
                           wtt_q[tmp_q[match]].print_entry();
                       end // else: !if(cache_ctrl_pkt.currstate === IX)
        end // case: DTW_DATA_DTY
        DTW_DATA_CLN: begin
                      bit nack_miss_alloc = 0;
                      //If Clean
                      if(ccp_if_en == 1 && lookup_en)begin
                        if(cache_ctrl_pkt.currstate !== IX) begin
                        // hit, drop
                          if(cache_ctrl_pkt.nack)begin
                            if(cachevector[5:0] !== 6'b000000) begin
                              `uvm_info("<%=obj.BlockId%>:processCacheWr:24", $sformatf("%1p",cache_ctrl_pkt), UVM_LOW)
                               wtt_q[tmp_q[match]].print_entry();
                              `uvm_error("<%=obj.BlockId%>:processCacheWr:24",
                                         $sformatf("{rd_data|wr_data|bypass|rp_update|tagstateup|setwaydebug|}:%0b%0b%0b %0b%0b%0b expd: 6'b0000000 ",
                                                   cache_ctrl_pkt.rd_data, cache_ctrl_pkt.wr_data,
                                                   cache_ctrl_pkt.bypass, cache_ctrl_pkt.rp_update,
                                                   cache_ctrl_pkt.tagstateup, cache_ctrl_pkt.setway_debug))
                            end
                          end
                          else begin 
                           if(cachevector[5:0] !== 6'b000100) begin
                             `uvm_info("<%=obj.BlockId%>:processCacheWr:25", $sformatf("%1p",cache_ctrl_pkt), UVM_LOW)
                              wtt_q[tmp_q[match]].print_entry();
                             `uvm_error("<%=obj.BlockId%>:processCacheWr:25",
                                        $sformatf("{rd_data|wr_data|bypass|rp_update|tagstateup|setwaydebug|}:%0b%0b%0b %0b%0b%0b expd: 6'b0000100 ",
                                                  cache_ctrl_pkt.rd_data, cache_ctrl_pkt.wr_data,
                                                  cache_ctrl_pkt.bypass, cache_ctrl_pkt.rp_update,
                                                  cache_ctrl_pkt.tagstateup, cache_ctrl_pkt.setway_debug))
                           end
                          end
                          wtt_q[tmp_q[match]].cacheWrDataExpd = 0;
                          wtt_q[tmp_q[match]].isCacheHit = 1;
                          update_raw_dependency(wtt_q[tmp_q[match]].cache_addr);
                        end
                        else begin
                          //#Check.DMI.Concerto.v3.0.WriteClnAllocDisable
                          //#Check.DMI.Concerto.v3.0.WrAllocationDisbale
                          if(wtt_q[tmp_q[match]].smi_ac == 1 && !ClnWrAllocDisable && !WrAllocDisable && alloc_en ) begin
                            // if AL and miss
                            if((wtt_q[tmp_q[match]].smi_size == SYS_wSysCacheline)) begin 
                              if(!(cache_ctrl_pkt.nacknoalloc || cache_ctrl_pkt.isWttanyfull || cache_ctrl_pkt.isWttfull || cache_ctrl_pkt.isWrfifofull))begin
                                if(cache_ctrl_pkt.evictvld == 1 && cache_ctrl_pkt.evictstate === UD) begin    
                                  if(cachevector !== 7'b1110110) begin
                                    `uvm_info("<%=obj.BlockId%>:processCacheWr:26", $sformatf("%1p",cache_ctrl_pkt), UVM_LOW)
                                     wtt_q[tmp_q[match]].print_entry();
                                    `uvm_error("<%=obj.BlockId%>:processCacheWr:26",
                                               $sformatf("{allocate_p2|rd_data|wr_data|bypass|rp_update|tagstateup|setwaydebug|}:%0b%0b%0b %0b%0b%0b %0b expd: 7'b1110110 ",
                                                         cache_ctrl_pkt.alloc, cache_ctrl_pkt.rd_data, cache_ctrl_pkt.wr_data,
                                                         cache_ctrl_pkt.bypass, cache_ctrl_pkt.rp_update,
                                                         cache_ctrl_pkt.tagstateup, cache_ctrl_pkt.setway_debug))
                                  end
                                end else begin
                                  if(cachevector !== 7'b1010110) begin
                                    `uvm_info("<%=obj.BlockId%>:processCacheWr:27", $sformatf("%1p",cache_ctrl_pkt), UVM_LOW)
                                     wtt_q[tmp_q[match]].print_entry();
                                    `uvm_error("<%=obj.BlockId%>:processCacheWr:27",
                                               $sformatf("{allocate_p2|rd_data|wr_data|bypass|rp_update|tagstateup|setwaydebug|}:%0b%0b%0b %0b%0b%0b %0b expd: 7'b1010110 ",
                                                         cache_ctrl_pkt.alloc, cache_ctrl_pkt.rd_data, cache_ctrl_pkt.wr_data,
                                                         cache_ctrl_pkt.bypass, cache_ctrl_pkt.rp_update,
                                                         cache_ctrl_pkt.tagstateup, cache_ctrl_pkt.setway_debug))
                                  end
                                end
                                wtt_q[tmp_q[match]].cacheWrDataExpd = 1;
                              end
                              else begin
                                if(cachevector[5:0] === 6'b001000 && WrDataClnPropagateEn) begin
                                  wtt_q[tmp_q[match]].evictDataExpd   = 1;
                                  wtt_q[tmp_q[match]].cacheWrDataExpd = 1;
                                  nack_miss_alloc = 1;
                                end
                                else if(cachevector[5:0] !== 6'b000000) begin
                                  `uvm_info("<%=obj.BlockId%>:processCacheWr:28", $sformatf("%1p",cache_ctrl_pkt), UVM_LOW)
                                   wtt_q[tmp_q[match]].print_entry();
                                  `uvm_error("<%=obj.BlockId%>:processCacheWr:28",
                                             $sformatf("{rd_data|wr_data|bypass|rp_update|tagstateup|setwaydebug|}:%0b%0b%0b %0b%0b%0b expd: 6'b0000000 ",
                                                       cache_ctrl_pkt.rd_data, cache_ctrl_pkt.wr_data,
                                                       cache_ctrl_pkt.bypass, cache_ctrl_pkt.rp_update,
                                                       cache_ctrl_pkt.tagstateup, cache_ctrl_pkt.setway_debug))
                                end
                              end
                            end
                          end // !if(wtt_q[tmp_q[match].smi_ac = 1)
                          else begin
                            if(cachevector[5:0] === 6'b001000 && WrDataClnPropagateEn) begin 
                              //CONC-12515 propagate writes downstream if register is set
                              wtt_q[tmp_q[match]].cacheWrDataExpd = 1;
                              wtt_q[tmp_q[match]].evictDataExpd   = 1; //Because bypass is set to 1
                            end
                            else if(cachevector !== 7'b0000000) begin
                              `uvm_info("<%=obj.BlockId%>:processCacheWr:29_0", $sformatf("%1p",cache_ctrl_pkt), UVM_LOW)
                               wtt_q[tmp_q[match]].print_entry();
                              `uvm_error("<%=obj.BlockId%>:processCacheWr:29_0",
                                         $sformatf("{allocate_p2|rd_data|wr_data|bypass|rp_update|tagstateup|setwaydebug|}:%0b%0b%0b %0b%0b%0b %0b expd: 7'b0000000 ",
                                                   cache_ctrl_pkt.alloc, cache_ctrl_pkt.rd_data, cache_ctrl_pkt.wr_data,
                                                   cache_ctrl_pkt.bypass, cache_ctrl_pkt.rp_update,
                                                   cache_ctrl_pkt.tagstateup, cache_ctrl_pkt.setway_debug))
                            end
                          end
                        end //  !if(cache_ctrl_pkt.currstate !== IX)
                        wtt_q[tmp_q[match]].cache_ctrl_pkt = cache_ctrl_pkt;
                        wtt_q[tmp_q[match]].lookupSeen = 1;
                        wtt_q[tmp_q[match]].cacheRspExpd        = 0;
                        if(!WrDataClnPropagateEn || (wtt_q[tmp_q[match]].smi_ac && !nack_miss_alloc && !ClnWrAllocDisable && !WrAllocDisable && alloc_en) || wtt_q[tmp_q[match]].isCacheHit) begin //#Check.DMI.Concerto.v3.6.EnforceCleanWritePropagation
                          `uvm_info("<%=obj.BlockId%>:processCacheWr:30",$sformatf("WrDataClnPropagetEn %0b smi_ac:%0b nack_miss_alloc:%0b CacheHit:%0b", WrDataClnPropagateEn , wtt_q[tmp_q[match]].smi_ac , nack_miss_alloc, wtt_q[tmp_q[match]].isCacheHit), UVM_DEBUG)
                          wtt_q[tmp_q[match]].evictDataExpd       = 0;
                          wtt_q[tmp_q[match]].wrOutstanding       = 0;
                          wtt_q[tmp_q[match]].AXI_write_addr_expd = 0;
                          wtt_q[tmp_q[match]].AXI_write_data_expd = 0;
                          wtt_q[tmp_q[match]].AXI_write_resp_expd = 0;
                        end
                        wtt_q[tmp_q[match]].t_lookup = $time;
                        wtt_q[tmp_q[match]].t_latest_update = $time;
                        wtt_q[tmp_q[match]].print_entry();
                      end // !if(lookup_en)
                    end // case: DTW_DATA_CLN
         DTW_MRG_MRD_INV,DTW_MRG_MRD_SCLN,DTW_MRG_MRD_UCLN: begin
                          //Hit in cache
                          wtt_q[tmp_q[match]].cache_ctrl_pkt = cache_ctrl_pkt;
                         if(cache_ctrl_pkt.currstate !== IX) begin
                           if(cache_ctrl_pkt.nack)begin
                             if(cachevector[5:0] !== 6'b000000) begin
                               `uvm_info("<%=obj.BlockId%>:processCacheWr:31", $sformatf("%1p",cache_ctrl_pkt), UVM_LOW)
                                wtt_q[tmp_q[match]].print_entry();
                               `uvm_error("<%=obj.BlockId%>:processCacheWr:31",
                                          $sformatf("{rd_data|wr_data|bypass|rp_update|tagstateup|setwaydebug|}:%0b%0b%0b %0b%0b%0b expd: 6'b000000 ",
                                                    cache_ctrl_pkt.rd_data, cache_ctrl_pkt.wr_data,
                                                    cache_ctrl_pkt.bypass, cache_ctrl_pkt.rp_update,
                                                    cache_ctrl_pkt.tagstateup, cache_ctrl_pkt.setway_debug))
                             end
                           end
                           else begin
                            if(cache_ctrl_pkt.currstate == SC)begin 
                              if(cachevector[5:0] !== 6'b011110) begin
                                `uvm_info("<%=obj.BlockId%>:processCacheWr:32", $sformatf("%1p",cache_ctrl_pkt), UVM_LOW)
                                 wtt_q[tmp_q[match]].print_entry();
                                `uvm_error("<%=obj.BlockId%>:processCacheWr:32",
                                           $sformatf("{rd_data|wr_data|bypass|rp_update|tagstateup|setwaydebug|}:%0b%0b%0b %0b%0b%0b expd: 6'b011110 ",
                                                     cache_ctrl_pkt.rd_data, cache_ctrl_pkt.wr_data,
                                                     cache_ctrl_pkt.bypass, cache_ctrl_pkt.rp_update,
                                                     cache_ctrl_pkt.tagstateup, cache_ctrl_pkt.setway_debug))
                              end
                              if(cache_ctrl_pkt.state !== UD)begin 
                                `uvm_info("<%=obj.BlockId%>:processCacheWr:33", $sformatf("%1p",cache_ctrl_pkt), UVM_LOW)
                                `uvm_error("<%=obj.BlockId%>:processCacheWr:33",$sformatf("update state should be UD, received :%s",cache_ctrl_pkt.state));
                              end
                            end
                            else begin
                              if(cachevector[5:0] !== 6'b011100) begin
                                `uvm_info("<%=obj.BlockId%>:processCacheWr:34", $sformatf("%1p",cache_ctrl_pkt), UVM_LOW)
                                 wtt_q[tmp_q[match]].print_entry();
                                `uvm_error("<%=obj.BlockId%>:processCacheWr:34",
                                           $sformatf("{rd_data|wr_data|bypass|rp_update|tagstateup|setwaydebug|}:%0b%0b%0b %0b%0b%0b expd: 6'b011100 ",
                                                     cache_ctrl_pkt.rd_data, cache_ctrl_pkt.wr_data,
                                                     cache_ctrl_pkt.bypass, cache_ctrl_pkt.rp_update,
                                                     cache_ctrl_pkt.tagstateup, cache_ctrl_pkt.setway_debug))
                              end
                            end
                           end
                           wtt_q[tmp_q[match]].isCacheHit = 1;
                         end
                         //miss in cache
                         else begin
                           // if(!WrAllocDisable && !ClnWrAllocDisable && alloc_en && (wtt_q[tmp_q[match]].smi_ac == 1) && (wtt_q[tmp_q[match]].smi_size == SYS_wSysCacheline)) begin 
                           //if(!WrAllocDisable && !ClnWrAllocDisable && alloc_en && (wtt_q[tmp_q[match]].smi_ac == 1)) begin  
                           if(!RdAllocDisable && alloc_en && (wtt_q[tmp_q[match]].smi_ac == 1)) begin      //DTWMrgMrds are always treated as read. Should be checked with RdAllocDisable (mico-arch 6.2.3.9) 
                             // if AL and miss
                             if(!(cache_ctrl_pkt.nacknoalloc || cache_ctrl_pkt.isWttanyfull || cache_ctrl_pkt.isWttfull || cache_ctrl_pkt.isWrfifofull))begin
                               if(cache_ctrl_pkt.evictvld == 1 && cache_ctrl_pkt.evictstate === UD) begin    
                                 if(cachevector !== 7'b1100000) begin
                                   `uvm_info("<%=obj.BlockId%>:processCacheWr:35", $sformatf("%1p",cache_ctrl_pkt), UVM_LOW)
                                    wtt_q[tmp_q[match]].print_entry();
                                   `uvm_error("<%=obj.BlockId%>:processCacheWr:35",
                                              $sformatf("{allocate_p2|rd_data|wr_data|bypass|rp_update|tagstateup|setwaydebug|}:%0b%0b%0b %0b%0b%0b %0b expd: 7'b1100000",
                                                        cache_ctrl_pkt.alloc, cache_ctrl_pkt.rd_data, cache_ctrl_pkt.wr_data,
                                                        cache_ctrl_pkt.bypass, cache_ctrl_pkt.rp_update,
                                                        cache_ctrl_pkt.tagstateup, cache_ctrl_pkt.setway_debug))
                                 end
                               end else begin
                                 if(cachevector !== 7'b1000000) begin
                                   `uvm_info("<%=obj.BlockId%>:processCacheWr:36", $sformatf("%1p",cache_ctrl_pkt), UVM_LOW)
                                    wtt_q[tmp_q[match]].print_entry();
                                   `uvm_error("<%=obj.BlockId%>:processCacheWr:36",
                                              $sformatf("{allocate_p2|rd_data|wr_data|bypass|rp_update|tagstateup|setwaydebug|}:%0b%0b%0b %0b%0b%0b %0b expd: 7'b1010110 ",
                                                        cache_ctrl_pkt.alloc, cache_ctrl_pkt.rd_data, cache_ctrl_pkt.wr_data,
                                                        cache_ctrl_pkt.bypass, cache_ctrl_pkt.rp_update,
                                                        cache_ctrl_pkt.tagstateup, cache_ctrl_pkt.setway_debug))
                                 end

                               end
                             end
                             else begin
                               if(cachevector[5:0] !== 6'b001000) begin
                                 `uvm_info("<%=obj.BlockId%>:processCacheWr:37", $sformatf("%1p",cache_ctrl_pkt), UVM_LOW)
                                  wtt_q[tmp_q[match]].print_entry();
                                 `uvm_error("<%=obj.BlockId%>:processCacheWr:37",
                                            $sformatf("{rd_data|wr_data|bypass|rp_update|tagstateup|setwaydebug|}:%0b%0b%0b %0b%0b%0b expd: 6'b0010000 ",
                                                      cache_ctrl_pkt.rd_data, cache_ctrl_pkt.wr_data,
                                                      cache_ctrl_pkt.bypass, cache_ctrl_pkt.rp_update,
                                                      cache_ctrl_pkt.tagstateup, cache_ctrl_pkt.setway_debug))
                               end
                             end
                              `uvm_info("<%=obj.BlockId%>:processCacheWr:38",$sformatf("Cache_addr:0x%0h || cache miss with allocate on a DTW merge, only expecting a read and no writes on AXI.",wtt_q[tmp_q[match]].cache_addr),UVM_DEBUG)
                               wtt_q[tmp_q[match]].AXI_write_addr_expd = 0;
                               wtt_q[tmp_q[match]].AXI_write_data_expd = 0;
                               wtt_q[tmp_q[match]].AXI_write_resp_expd = 0;
                           end
                           else begin
                           if(cachevector[5:0] !== 6'b001000) begin
                             `uvm_info("<%=obj.BlockId%>:processCacheWr:39", $sformatf("%1p",cache_ctrl_pkt), UVM_LOW)
                              wtt_q[tmp_q[match]].print_entry();
                             `uvm_error("<%=obj.BlockId%>:processCacheWr:39",
                                        $sformatf("{rd_data|wr_data|bypass|rp_update|tagstateup|setwaydebug|}:%0b%0b%0b %0b%0b%0b expd: 6'b0010000 ",
                                                  cache_ctrl_pkt.rd_data, cache_ctrl_pkt.wr_data,
                                                  cache_ctrl_pkt.bypass, cache_ctrl_pkt.rp_update,
                                                  cache_ctrl_pkt.tagstateup, cache_ctrl_pkt.setway_debug))
                           end
                         end
                         wtt_q[tmp_q[match]].evictDataExpd =  cache_ctrl_pkt.bypass;
                         wtt_q[tmp_q[match]].isCacheMiss   = 1;
                       end // !if(cache_ctrl_pkt.currstate !== IX)
                       wtt_q[tmp_q[match]].bypassExpd      = 0;
                       wtt_q[tmp_q[match]].lookupSeen      = 1;
                       wtt_q[tmp_q[match]].cacheWrDataExpd = cache_ctrl_pkt.bypass;
                       wtt_q[tmp_q[match]].t_lookup = $time;
                       wtt_q[tmp_q[match]].t_latest_update = $time;
                       wtt_q[tmp_q[match]].print_entry();
                     end // case: DTW_MRG_MRD_INV,DTW_MRG_MRD_SCLN,DTW_MRG_MRD_UCLN
          DTW_MRG_MRD_UDTY: begin  //Hit in cache
                           wtt_q[tmp_q[match]].cache_ctrl_pkt = cache_ctrl_pkt;
                           if(cache_ctrl_pkt.currstate !== IX) begin
                             if(cache_ctrl_pkt.nack)begin
                               if(cachevector[5:0] !== 6'b000000) begin
                                 `uvm_info("<%=obj.BlockId%>:processCacheWr:40", $sformatf("%1p",cache_ctrl_pkt), UVM_LOW)
                                  wtt_q[tmp_q[match]].print_entry();
                                 `uvm_error("<%=obj.BlockId%>:processCacheWr:40",
                                             $sformatf("{rd_data|wr_data|bypass|rp_update|tagstateup|setwaydebug|}:%0b%0b%0b %0b%0b%0b expd: 6'b000000 ",
                                                       cache_ctrl_pkt.rd_data, cache_ctrl_pkt.wr_data,
                                                       cache_ctrl_pkt.bypass, cache_ctrl_pkt.rp_update,
                                                       cache_ctrl_pkt.tagstateup, cache_ctrl_pkt.setway_debug))
                               end
                             end
                             else begin
                               if(cachevector !== 7'b0011010) begin
                                 `uvm_info("<%=obj.BlockId%>:processCacheWr:41", $sformatf("%1p",cache_ctrl_pkt), UVM_LOW)
                                  wtt_q[tmp_q[match]].print_entry();
                                 `uvm_error("<%=obj.BlockId%>:processCacheWr:41",
                                            $sformatf("{allocate_p2|rd_data|wr_data|bypass|rp_update|tagstateup|setwaydebug|}:%0b%0b%0b %0b%0b%0b %0b expd: 7'b0011010",
                                                      cache_ctrl_pkt.alloc, cache_ctrl_pkt.rd_data, cache_ctrl_pkt.wr_data,
                                                      cache_ctrl_pkt.bypass, cache_ctrl_pkt.rp_update,
                                                      cache_ctrl_pkt.tagstateup, cache_ctrl_pkt.setway_debug))
                               end
                               if(cache_ctrl_pkt.state !== IX)begin 
                                 `uvm_info("<%=obj.BlockId%>:processCacheWr:42", $sformatf("%1p",cache_ctrl_pkt), UVM_LOW)
                                 `uvm_error("<%=obj.BlockId%>:processCacheWr:42",$sformatf("update state should be IX, received :%s",cache_ctrl_pkt.state));
                               end
                             end
                             wtt_q[tmp_q[match]].isCacheHit      = 1;
                             wtt_q[tmp_q[match]].cacheWrDataExpd = 1;
                           end
                           //miss in cache
                           else begin
                             if(cache_ctrl_pkt.alloc && cachevector[5:0] !==6'b001000) begin
                               `uvm_info("<%=obj.BlockId%>:processCacheWr:43", $sformatf("%1p",cache_ctrl_pkt), UVM_LOW)
                                wtt_q[tmp_q[match]].print_entry();
                               `uvm_error("<%=obj.BlockId%>:processCacheWr:43",
                                          $sformatf("{rd_data|wr_data|bypass|rp_update|tagstateup|setwaydebug|}:%0b%0b%0b %0b%0b%0b expd: 6'b001000 ",
                                                    cache_ctrl_pkt.rd_data, cache_ctrl_pkt.wr_data,
                                                    cache_ctrl_pkt.bypass, cache_ctrl_pkt.rp_update,
                                                    cache_ctrl_pkt.tagstateup, cache_ctrl_pkt.setway_debug))
                             end
                             else if(cachevector[5:0] !== 6'b000000) begin
                               `uvm_info("<%=obj.BlockId%>:processCacheWr:44", $sformatf("%1p",cache_ctrl_pkt), UVM_LOW)
                                wtt_q[tmp_q[match]].print_entry();
                               `uvm_error("<%=obj.BlockId%>:processCacheWr:44",
                                          $sformatf("{rd_data|wr_data|bypass|rp_update|tagstateup|setwaydebug|}:%0b%0b%0b %0b%0b%0b expd: 6'b000000 ",
                                                    cache_ctrl_pkt.rd_data, cache_ctrl_pkt.wr_data,
                                                    cache_ctrl_pkt.bypass, cache_ctrl_pkt.rp_update,
                                                    cache_ctrl_pkt.tagstateup, cache_ctrl_pkt.setway_debug))
                             end
                             wtt_q[tmp_q[match]].isCacheMiss   = 1;
                           end // !if(cache_ctrl_pkt.currstate !== IX)
                           wtt_q[tmp_q[match]].lookupSeen      = 1;
                           wtt_q[tmp_q[match]].t_lookup        = $time;
                           wtt_q[tmp_q[match]].t_latest_update = $time;
                           wtt_q[tmp_q[match]].print_entry();
                         end // case: DTW_MRG_MRD_UDTY
      endcase // case (wtt_q[tmp_q[match]].dtw_req_pkt.smi_msg_type)
      <% if(obj.testBench == 'dmi') { %>
      add_mnt_op_cache_line(wtt_q[tmp_q[match]]);
      <% } %> 
      if(isdtwmrgmrd(wtt_q[tmp_q[match]].dtw_msg_type) && !wtt_q[tmp_q[match]].isRttCreated)begin
          processMrdReq(wtt_q[tmp_q[match]].rb_req_pkt,1,wtt_q[tmp_q[match]]);
          wtt_q[tmp_q[match]].isRttCreated = 1;
          numDtwMrgMrdTxns++;
        if(wtt_q[tmp_q[match]].isCacheHit || wtt_q[tmp_q[match]].dtw_msg_type == DTW_MRG_MRD_UDTY)begin
          wtt_q[tmp_q[match]].wrOutstanding       = 0;
          wtt_q[tmp_q[match]].AXI_write_addr_expd = 0;
          wtt_q[tmp_q[match]].AXI_write_data_expd = 0;
          wtt_q[tmp_q[match]].AXI_write_resp_expd = 0;
        end
        else if(!cache_ctrl_pkt.alloc && cache_ctrl_pkt.bypass)begin
          wtt_q[tmp_q[match]].wrOutstanding       = 1;
          wtt_q[tmp_q[match]].AXI_write_addr_expd = 1;
          wtt_q[tmp_q[match]].AXI_write_data_expd = 1;
          wtt_q[tmp_q[match]].AXI_write_resp_expd = 1;
        end
      end
    end
    else begin 
      wtt_q[tmp_q[match]].lookupSeen          = 1;
      wtt_q[tmp_q[match]].nackuce             = 1;
      wtt_q[tmp_q[match]].cacheWrDataExpd     = 0;
      wtt_q[tmp_q[match]].cacheRspExpd        = 0;
      wtt_q[tmp_q[match]].AXI_write_addr_expd = 0;
      wtt_q[tmp_q[match]].AXI_write_data_expd = 0;
      wtt_q[tmp_q[match]].AXI_write_resp_expd = 0;
      wtt_q[tmp_q[match]].t_lookup            = $time;
      wtt_q[tmp_q[match]].t_latest_update     = $time;
      wtt_q[tmp_q[match]].print_entry();
    end //nachuce
    `uvm_info("DMI_SCB", $psprintf("DMI_UID:%0d: CACHE_WR: %s", wtt_q[tmp_q[match]].txn_id, cache_ctrl_pkt.sprint_pkt()), UVM_LOW)
    updateWttentry(wtt_q[tmp_q[match]],tmp_q[match]);
  end
endfunction // processCacheWr
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Update MRD Entry With Cache Read Response Channel
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function void dmi_scoreboard::processCacheRdRsp(ccp_rd_rsp_pkt_t cache_rd_rsp);
  int tmp_q[$], tmp_q2[$], tmp_q3[$] ;
  int match;
  time oldest;

  `uvm_info("<%=obj.BlockId%>:processCacheRdRsp", $sformatf("cache_rd_rsp: %s ",cache_rd_rsp.sprint_pkt()), UVM_MEDIUM);
  //find oldest entry in rtt q expecting cache rd rsp and assign this data to that.
  tmp_q = {};

  tmp_q = rtt_q.find_index with ((item.isCacheHit === 1) && 
                                  (item.cacheRspExpd === 1) && 
                                  (item.cacheRspRecd === 0));


  if(tmp_q.size() === 0) begin
    `uvm_info("<%=obj.BlockId%>:processCacheRdRsp", $sformatf("%1p",cache_rd_rsp), UVM_LOW)
    print_rtt_q();
    `uvm_error("<%=obj.BlockId%>:processCacheRdRsp","Above packet has no matching MRD")
  end
  else begin
    match = 0;
    oldest = rtt_q[tmp_q[0]].t_lookup;
    foreach (tmp_q[i]) begin
       if (rtt_q[tmp_q[i]].t_lookup < oldest) begin
          oldest = rtt_q[tmp_q[i]].t_lookup;
          match = i;
       end
    end

    tmp_q2 = wtt_q.find_index with (item.cacheRspExpd === 1 && 
                                    item.cacheRspRecd === 0 &&
                                    item.cache_addr == rtt_q[tmp_q[match]].cache_addr &&
                                    security_match(item.security,rtt_q[tmp_q[match]].security) &&
                                    item.t_lookup < rtt_q[tmp_q[match]].t_lookup);

    if(tmp_q2.size() >0)begin
      wtt_q[tmp_q2[0]].cache_rd_data_pkt = cache_rd_rsp;
      wtt_q[tmp_q2[0]].cacheRspRecd  = 1;
      wtt_q[tmp_q2[0]].t_cacheRdrsp = $time;
      wtt_q[tmp_q2[0]].t_latest_update = $time;
      wtt_q[tmp_q2[0]].print_entry();
      `uvm_info("DMI_SCB", $psprintf("DMI_UID:%0d: CACHE_RD_RSP: %s", wtt_q[tmp_q2[0]].txn_id, cache_rd_rsp.sprint_pkt()), UVM_LOW)
    end
    else begin
      rtt_q[tmp_q[match]].cache_rd_data_pkt = cache_rd_rsp;
      rtt_q[tmp_q[match]].cacheRspRecd = 1;
      rtt_q[tmp_q[match]].t_cacheRdrsp = $time;
      rtt_q[tmp_q[match]].t_latest_update = $time;
      rtt_q[tmp_q[match]].print_entry();
      `uvm_info("DMI_SCB", $psprintf("DMI_UID:%0d: CACHE_RD_RSP: %s", rtt_q[tmp_q[match]].txn_id, cache_rd_rsp.sprint_pkt()), UVM_LOW)
      if(rtt_q[tmp_q[match]].smi_msg_type inside {CMD_RD_ATM,CMD_CMP_ATM,CMD_SW_ATM,CMD_WR_ATM} && rtt_q[tmp_q[match]].DTW_req_recd &&  rtt_q[tmp_q[match]].smi_dp_last)begin
        process_atomic_op(rtt_q[tmp_q[match]],tmp_q[match]);
        updateRttentry(rtt_q[tmp_q[match]],tmp_q[match]);
      end
      else if(rtt_q[tmp_q[match]].isDtwMrgMrd)begin
       MrgMrddata(rtt_q[tmp_q[match]]);
       `uvm_info("<%=obj.BlockId%>:processCacheRdRsp", $sformatf(" After Merge cache_rd_rsp: %s ",rtt_q[tmp_q[match]].cache_rd_data_pkt.sprint_pkt()), UVM_MEDIUM);
      end
    end
  end
endfunction // processCacheRdRsp
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Update MRD Entry With Cache Wrire Data Channel
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function void dmi_scoreboard::processCacheWrData(ccp_wr_data_pkt_t cache_wr_data);
  int tmp_q[$],tmp_q1[$],tmp_q2[$],tmp_q_mntop[$], tmp_q_rtt[$];
  int match;
  time oldest;
  bit [<%=(Math.log2(512/obj.DmiInfo[obj.Id].ccpParams.wData)-1)%>:0] beat_offset;

  `uvm_info("<%=obj.BlockId%>:processCacheWrData", $sformatf("cache_wr_data: %s ",cache_wr_data.sprint_pkt()), UVM_MEDIUM);

  //find oldest entry in rtt q expecting cache rd rsp and assign this data to that.
  tmp_q = {};
  tmp_q_mntop = {};

  tmp_q = wtt_q.find_index with ((item.lookupExpd ==1 && item.lookupSeen == 1) && 
                                 (item.cacheWrDataExpd === 1) && 
                                 (item.cacheWrDataRecd === 0));
  if(tmp_q.size() === 0) begin
    `uvm_info("<%=obj.BlockId%>:processCacheWrData", $sformatf("%1p",cache_wr_data), UVM_LOW)
    `uvm_error("<%=obj.BlockId%>:processCacheWrData","CCP WR Data packet has no matching DTW")
  end
  else begin
    wtt_q[tmp_q[0]].print_entry();
    match = 0;
    oldest = wtt_q[tmp_q[0]].t_lookup;
    foreach (tmp_q[i]) begin
       if (wtt_q[tmp_q[i]].t_lookup < oldest) begin
          oldest = wtt_q[tmp_q[i]].t_lookup;
          match = i;
       end
    end

    // if(wtt_q[tmp_q[match]].dtw_req_pkt.smi_msg_type == DTW_DATA_PTL)begin
    //    `uvm_info("<%=obj.BlockId%>:SATYA:0", $sformatf("%1p",wtt_q[tmp_q[match]].dtw_req_pkt), UVM_MEDIUM)
    //   if(wtt_q[tmp_q[match]].isCacheMiss)begin
    //    merge_write_data(tmp_q[match],wtt_q[match].dtw_req_pkt,1);
    //   end
    //   else if(wtt_q[tmp_q[0]].isCacheHit)begin
    //    merge_write_data(tmp_q[match],wtt_q[tmp_q[match]].dtw_req_pkt,~wtt_q[tmp_q[match]].dtw_req_pkt.smi_vz);
    //   end
    // end
    if($test$plusargs("random_dbad_on_DTWreq")) begin
      for (int i=0; i < wtt_q[tmp_q[match]].dtw_req_pkt.smi_dp_data.size(); i++) begin
        if (wtt_q[tmp_q[match]].dtw_req_pkt.smi_dp_dbad[i] !== 0) begin
          if (cache_wr_data.poison[i] !== 1) begin
            `uvm_error(get_full_name(),$sformatf("Dbad not propagated into CCP data, poison[%0d] = %0b",i,cache_wr_data.poison[i]))
          end
        end
      end
    end
      
    merge_write_data(tmp_q[match],wtt_q[tmp_q[match]].dtw_req_pkt,wtt_q[tmp_q[match]].smi_vz);
    wtt_q[tmp_q[match]].cache_wr_data_pkt = cache_wr_data;
    wtt_q[tmp_q[match]].cacheWrDataRecd = 1;
    if(!(wtt_q[tmp_q[match]].cacheRspExpd | wtt_q[tmp_q[match]].evictDataExpd))begin
      wtt_q[tmp_q[match]].wrOutstanding = 0;
      update_raw_dependency(wtt_q[tmp_q[match]].cache_addr);
    end
    wtt_q[tmp_q[match]].t_cacheWrData = $time;
    wtt_q[tmp_q[match]].t_latest_update = $time;
    wtt_q[tmp_q[match]].print_entry();
    beat_offset = wtt_q[tmp_q[match]].cache_ctrl_pkt.addr[SYS_wSysCacheline-1:WLOGXDATA];
    tmp_q_mntop = m_dmi_cache_q.find_index with (cl_aligned(item.addr) == cl_aligned(wtt_q[tmp_q[match]].cache_ctrl_pkt.addr) &&
                                                 item.security == wtt_q[tmp_q[match]].cache_ctrl_pkt.security);
    if(tmp_q_mntop.size() == 1) begin
      if(m_dmi_cache_q[tmp_q_mntop[0]].data.size() == 1'b0) begin
        m_dmi_cache_q[tmp_q_mntop[0]].data = new[CCP_BEATN];
        m_dmi_cache_q[tmp_q_mntop[0]].dataErrorPerBeat = new[CCP_BEATN];
        foreach(cache_wr_data.data[i]) begin
          m_dmi_cache_q[tmp_q_mntop[0]].data[beat_offset] = cache_wr_data.data[i];
          m_dmi_cache_q[tmp_q_mntop[0]].dataErrorPerBeat[beat_offset] = cache_wr_data.poison[i];
          beat_offset++;
        end
      end else begin //Data merge for already available cache
        foreach(cache_wr_data.data[i]) begin
          foreach(cache_wr_data.byten[i][j]) begin
            if(cache_wr_data.byten[i][j] == 1) begin
              m_dmi_cache_q[tmp_q_mntop[0]].data[cache_wr_data.beatn[i]][(j*8)+:8] = cache_wr_data.data[i][(j*8)+:8];
            end
          end
        end
      end
    end
    
    if (!uncorr_wrbuffer_err && !uncorr_data_err) begin
      if(isWeirdWrap(wtt_q[tmp_q[match]])) begin
        foreach(cache_wr_data.byten[i]) begin
          if(cache_wr_data.byten[i] == 0 && $test$plusargs("random_dbad_on_DTWreq")) begin
            cache_wr_data.poison[i] = 0;
          end
        end
      end
      if(!wtt_q[tmp_q[match]].cache_wr_data_pkt_exp.do_compare_pkts(cache_wr_data))begin
        `uvm_error("<%=obj.BlockId%>:processCacheWrData","ccp_wr_data not matching with expected") 
      end
    end
    `uvm_info("DMI_SCB", $psprintf("DMI_UID:%0d: CACHE_WR_DATA: %s", wtt_q[tmp_q[match]].txn_id,cache_wr_data.sprint_pkt()), UVM_LOW)
    updateWttentry(wtt_q[tmp_q[match]],tmp_q[match]);
  end
endfunction // processCacheWrData
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Update DTW Entry with Cache Evict Channel
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function void dmi_scoreboard::processEvictData(ccp_evict_pkt_t cache_evict_data);
  int tmp_q[$], tmp_q2[$];
  int match;
  time oldest;

  `uvm_info("<%=obj.BlockId%>:processCacheEvictData", $sformatf("cache_evict_data: %s ",cache_evict_data.sprint_pkt()), UVM_MEDIUM);
  //find oldest entry in wtt q expecting evict data and assign this data to that.

  tmp_q = {};

  tmp_q = wtt_q.find_index with ((item.isEvict ==1 || 
                                 (item.lookupExpd ==1 && item.lookupSeen == 1)) && 
                                 (item.evictDataExpd == 1) && (item.evictDataRecd == 0));

  if(tmp_q.size() === 0) begin
    `uvm_info("<%=obj.BlockId%>:processCacheEvictData", $sformatf("%1p",cache_evict_data), UVM_LOW)
    `uvm_error("<%=obj.BlockId%>:processCacheEvictData","Above packet has no matching evict entry")
  end
  else begin
    `uvm_info("<%=obj.BlockId%>:processCacheEvictData", $sformatf("Found %0d matches in the WTT", $size(tmp_q)), UVM_DEBUG);
    match = 0;
      if(!wtt_q[tmp_q[0]].isEvict)begin
        oldest = wtt_q[tmp_q[0]].t_lookup;
      end
      else begin
        oldest = wtt_q[tmp_q[0]].t_creation;
      end
    if(tmp_q.size() >1)begin
      foreach (tmp_q[i]) begin
        if(!wtt_q[tmp_q[i]].isEvict)begin
         if (wtt_q[tmp_q[i]].t_lookup < oldest) begin
            oldest = wtt_q[tmp_q[i]].t_lookup;
            match = i;
         end
        end
        else begin
         if (wtt_q[tmp_q[i]].t_creation < oldest) begin
            oldest = wtt_q[tmp_q[i]].t_creation;
            match = i;
         end
        end
      end
    end
    wtt_q[tmp_q[match]].cache_evict_data_pkt = cache_evict_data;
    wtt_q[tmp_q[match]].evictDataRecd = 1;
    wtt_q[tmp_q[match]].t_evictData = $time;
    wtt_q[tmp_q[match]].t_latest_update = $time;
    wtt_q[tmp_q[match]].print_entry();
    `uvm_info("DMI_SCB", $psprintf("DMI_UID:%0d: EVICT_DATA: %s", wtt_q[tmp_q[match]].txn_id,wtt_q[tmp_q[match]].cache_evict_data_pkt.sprint_pkt()), UVM_LOW)
    
    //if(!wtt_q[tmp_q[match]].cache_evict_data_pkt_exp.do_compare_pkts(cache_evict_data)) begin 
    //  spkt = {"Read Response Mismatch Addr :0x%0x Security :%0b Exp:%s but Got:%s"};
    //  `uvm_error("<%=obj.BlockId%>:processCacheEvictData", $psprintf(spkt, wtt_q[tmp_q[match]].cache_addr,wtt_q[tmp_q[match]].security,wtt_q[tmp_q[match]].cache_evict_data_pkt_exp.sprint_pkt(),
    //             cache_evict_data.sprint_pkt()))
    //end 
   end
endfunction // processEvictData
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Update RTT Entry With Cache Fill Control Channel
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function void dmi_scoreboard::processCacheFillCtrl(ccp_fillctrl_pkt_t cache_fill_ctrl);
  ccp_fillctrl_pkt_t m_cache_fill_ctrl;
  int tmp_q[$], tmp_q2[$],tmp_q3[$],tmp_q4[$];
  int match;
  time oldest;
  dmi_fill_addr_inflight_t temp_fill_rsp_pkt; 
  dmi_scb_txn txn;

  m_cache_fill_ctrl = new();
  m_cache_fill_ctrl = cache_fill_ctrl;
  tmp_q2 = {};
  `uvm_info("<%=obj.BlockId%>:processCacheFillCtrl:0", $sformatf("cache_fill_ctrl: %s ",cache_fill_ctrl.sprint_pkt()), UVM_MEDIUM);
  tmp_q = rtt_q.find_index with ((item.lookupSeen ==1 ) && 
                                  (item.fillExpd === 1) && 
                                  (item.fillSeen === 0) &&  
                                  (beat_aligned(m_cache_fill_ctrl.addr) == beat_aligned((item.cache_addr))) && 
                                  (security_match(m_cache_fill_ctrl.security,item.security)));

  if(!tmp_q.size())begin
    tmp_q = rtt_q.find_index with ( item.isAtomic &&
                                   (item.lookupSeen ==1 ) && 
                                   (item.isAtomicProcessed == 1 ? item.fillExpd == 1 : 1) &&
                                   (item.fillSeen === 0) &&  
                                   (beat_aligned(m_cache_fill_ctrl.addr) == beat_aligned((item.cache_addr))) && 
                                   (security_match(m_cache_fill_ctrl.security,item.security)));
  end

  if(tmp_q.size()  == 0) begin
    `uvm_info("<%=obj.BlockId%>:processCacheFillCtrl:1", $sformatf("%1p",m_cache_fill_ctrl), UVM_LOW)
    print_rtt_q();
    `uvm_error("<%=obj.BlockId%>:processCacheFillCtrl:1",$sformatf("Above packet has no matching  Mrd or Scratchpad Atomic write tmp_q.size :%0d ",tmp_q.size()))
  end
  else begin 
    if(tmp_q.size()>1)begin
      `uvm_info("<%=obj.BlockId%>:processCacheFillCtrl:2", $sformatf("%1p",m_cache_fill_ctrl), UVM_LOW)
      foreach(tmp_q[i])begin
       rtt_q[tmp_q[i]].print_entry();
      end
      `uvm_error("<%=obj.BlockId%>:processCacheFillCtrl:2",$sformatf("if 2 RTT entry matching then "))
    end
      
    txn = rtt_q[tmp_q[0]];
    if(txn.fillExpd && !addr_space_mixed)begin
      if(!(txn.cache_fill_ctrl_pkt_exp.do_compare_pkts(m_cache_fill_ctrl)))begin
        `uvm_info("<%=obj.BlockId%>:processCacheFillCtrl:3", $sformatf("%1p",m_cache_fill_ctrl), UVM_LOW)
        print_rtt_q();
        `uvm_error("<%=obj.BlockId%>:processCacheFillCtrl:3","fill pkt not matching")
      end
    end
    txn.cache_fill_ctrl_pkt = m_cache_fill_ctrl;
    txn.fillSeen = 1;
    txn.t_cachefillctrl = $time;
    txn.t_latest_update = $time;
    if(txn.fillDataSeen) begin
      int mntop_idx_q[$];
      int beat_offset;
      temp_fill_rsp_pkt.addr = m_cache_fill_ctrl.addr;
      temp_fill_rsp_pkt.secu = m_cache_fill_ctrl.security;
      temp_fill_rsp_pkt.wayn = m_cache_fill_ctrl.wayn; 
      update_index_way(temp_fill_rsp_pkt,0);
      <% if(obj.testBench == "dmi" && obj.useCmc) { %>
      add_mnt_op_cache_line(txn);
      beat_offset = m_cache_fill_ctrl.addr[SYS_wSysCacheline-1:WLOGXDATA];
      mntop_idx_q = m_dmi_cache_q.find_index with ( cl_aligned(item.addr)==cl_aligned(m_cache_fill_ctrl.addr) && 
                                                    item.security== m_cache_fill_ctrl.security);
      `uvm_info("<%=obj.BlockId%>:processCacheFillCtrl",$sformatf("mntop_idx_q.size:%0d",mntop_idx_q.size),UVM_DEBUG)
      if(mntop_idx_q.size() == 1) begin
        m_dmi_cache_q[mntop_idx_q[0]].data = new[CCP_BEATN];
        m_dmi_cache_q[mntop_idx_q[0]].dataErrorPerBeat = new[CCP_BEATN];
        `uvm_info("<%=obj.BlockId%>:processCacheFillCtrl",$sformatf("Data :%0p beat_offset:%0d", txn.cache_fill_data_pkt.data,beat_offset),UVM_DEBUG)
        foreach(txn.cache_fill_data_pkt.data[i]) begin
          m_dmi_cache_q[mntop_idx_q[0]].data[beat_offset] = txn.cache_fill_data_pkt.data[i];
          m_dmi_cache_q[mntop_idx_q[0]].dataErrorPerBeat[beat_offset] = txn.cache_fill_data_pkt.poison[i];
          beat_offset++;
          if(beat_offset == CCP_BEATN) beat_offset=0;
        end
      end
      else begin
        `uvm_error("<%=obj.BlockId%>:processCacheFillCtrl",$sformatf(">1 address matches from m_dmi_cahe_q | mntop_idx_q.size:%0d",mntop_idx_q.size))
      end
      <%}%>
    end

    if(tmp_q2.size()>0)begin
      `uvm_info("DMI_SCB", $psprintf("DMI_UID:%0d: CACHE_FILL_CTRL: %s", txn.txn_id, cache_fill_ctrl.sprint_pkt()), UVM_LOW);
      updateWttentry(txn,tmp_q2[0]);
    end 
    else begin
      if(txn.fillExpd)begin
       `uvm_info("DMI_SCB", $psprintf("DMI_UID:%0d: CACHE_FILL_CTRL: %s", txn.txn_id, cache_fill_ctrl.sprint_pkt()), UVM_LOW);
       updateRttentry(txn,tmp_q[0]);
      end
    end
  end
endfunction // processCacheFillCtrl
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Update RTT Entry With Cache Fill Data Channel
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function void dmi_scoreboard::processCacheFillData(ccp_filldata_pkt_t cache_fill_data);
  ccp_filldata_pkt_t m_cache_fill_data;
  int tmp_q[$], tmp_q2[$], tmp_q3[$], tmp_q_mntop[$], tmp_q5[$], tmp_q6[$];
  int match;
  int exp_way;
  time oldest;
  dmi_fill_addr_inflight_t temp_fill_rsp_pkt; 
  dmi_scb_txn txn;
  bit [<%=(Math.log2(512/obj.DmiInfo[obj.Id].ccpParams.wData)-1)%>:0] beat_offset;

  m_cache_fill_data = new();
  m_cache_fill_data = cache_fill_data;
  match = 0;
  tmp_q2 = {};
  tmp_q_mntop = {};
  `uvm_info("<%=obj.BlockId%>:processCacheFillData", $sformatf("cache_fill_data: %s ",cache_fill_data.sprint_pkt()), UVM_MEDIUM);
  tmp_q = rtt_q.find_index with ((item.lookupSeen ==1 ) && 
                                 (item.fillDataExpd == 1) && 
                                 (item.fillDataSeen == 0) &&  
                                 (item.fillwayn == m_cache_fill_data.wayn) &&  
                                 (beat_aligned(m_cache_fill_data.addr) == beat_aligned((item.cache_addr)))); 
  // For Scratchpad atomic write
  tmp_q3 = rtt_q.find_index with (item.isAtomic && (item.sp_txn                          === 1) && 
                                                   (item.sp_seen_ctrl_chnl               === 1) && 
                                                   (item.isAtomicProcessed == 1 ? item.fillDataExpd == 1 : 1) &&
                                                   (item.fillDataSeen == 0) &&  
                                                   (beat_aligned(m_cache_fill_data.addr) === beat_aligned(item.cmd_req_pkt.smi_addr)) && 
                                                   (item.sp_way                          === m_cache_fill_data.wayn));
  if((tmp_q.size()+tmp_q3.size()) === 0) begin
    tmp_q = rtt_q.find_index with ( item.isAtomic &&
                                   (item.lookupSeen ==1 ) && 
                                   (item.fillDataSeen == 0) &&  
                                   (item.isAtomicProcessed == 1 ? item.fillDataExpd == 1 : 1) &&
                                   (item.fillwayn == m_cache_fill_data.wayn) &&  
                                   (beat_aligned(m_cache_fill_data.addr) == beat_aligned((item.cache_addr)))); 
  end
  if((tmp_q.size()+tmp_q3.size()) === 0) begin
    `uvm_info("<%=obj.BlockId%>:processCacheFillData:0", $sformatf("%1p",m_cache_fill_data), UVM_LOW)
    print_rtt_q();
    `uvm_error("<%=obj.BlockId%>:processCacheFillData:0","Above packet has no matching Mrd or NcRd")
  end
  else begin
    if(tmp_q.size() >1)begin
      if(rtt_q[tmp_q[0]].security == rtt_q[tmp_q[1]].security)begin
        `uvm_info("<%=obj.BlockId%>:processCacheFillData:2", $sformatf("%1p",m_cache_fill_data), UVM_LOW)
        foreach(tmp_q[i])begin
          rtt_q[tmp_q[i]].print_entry();
        end
        `uvm_error("<%=obj.BlockId%>:processCacheFillData:2",$sformatf("there should not be two fill"))
      end
    end
    if(tmp_q3.size()>1)begin
      `uvm_info("<%=obj.BlockId%>:processCacheFillData:2", $sformatf("%1p",m_cache_fill_data), UVM_LOW)
        foreach(tmp_q3[i])begin
         rtt_q[tmp_q3[i]].print_entry();
        end
      `uvm_error("<%=obj.BlockId%>:processCacheFillData:2",$sformatf(" there should not be two Atomic requests in flight for same address:%0d",tmp_q3.size()))
    end
    if((tmp_q3.size()>0) && ((tmp_q.size() )>0))begin
      `uvm_info("<%=obj.BlockId%>:processCacheFillData:2", $sformatf("%1p",m_cache_fill_data), UVM_LOW)
      print_rtt_q();
      `uvm_error("<%=obj.BlockId%>:processCacheFillData:2",
                 $sformatf("TB Error: For a fill data request, both the tmp_q3:%0d and tmp_q:%0d should not be high, \nas one is for cache accesses and the other one for scratchpad",tmp_q3.size(), tmp_q.size()))
    end

    if(tmp_q.size() == 1)begin
      txn = rtt_q[tmp_q[match]];
    end else  begin
      txn = rtt_q[tmp_q3[0]];
    end

    exp_way = txn.sp_txn ? txn.sp_way : txn.fillwayn;

    //#Check.DMI.Concerto.v3.0.NoWayResrve
    if(m_cache_fill_data.wayn != exp_way)begin
      `uvm_info("<%=obj.BlockId%>:processCacheFillData:3", $sformatf("%1p",m_cache_fill_data), UVM_LOW)
      print_rtt_q();
      `uvm_error("<%=obj.BlockId%>:processCacheFillData:3",$sformatf("fill data wayn :%0d alloc wayn :%0dmismatch ",
                                                                     m_cache_fill_data.wayn,exp_way))
    end
    txn.cache_fill_data_pkt = m_cache_fill_data;
    txn.cache_fill_data_pkt.addr = txn.cache_fill_data_pkt.addr;
    txn.fillDataSeen = 1;
    txn.t_cachefilldata = $time;
    txn.t_latest_update = $time;
    if(tmp_q.size() == 1)begin
      if(txn.fillSeen)begin
        temp_fill_rsp_pkt.addr = txn.cache_fill_ctrl_pkt.addr;
        temp_fill_rsp_pkt.secu = txn.cache_fill_ctrl_pkt.security;
        temp_fill_rsp_pkt.wayn = txn.cache_fill_ctrl_pkt.wayn; 
        update_index_way(temp_fill_rsp_pkt,0);
        <% if(obj.testBench == "dmi" && obj.useCmc) { %>
        add_mnt_op_cache_line(txn);
        beat_offset = txn.cache_fill_ctrl_pkt.addr[SYS_wSysCacheline-1:WLOGXDATA];
        tmp_q_mntop = m_dmi_cache_q.find_index with (cl_aligned(item.addr) == cl_aligned(txn.cache_fill_ctrl_pkt.addr) &&
                                                     item.security == txn.cache_fill_ctrl_pkt.security);
        if (tmp_q_mntop.size() == 1) begin
          m_dmi_cache_q[tmp_q_mntop[0]].data = new[CCP_BEATN];
          m_dmi_cache_q[tmp_q_mntop[0]].dataErrorPerBeat = new[CCP_BEATN];
          foreach(m_cache_fill_data.data[i]) begin
            m_dmi_cache_q[tmp_q_mntop[0]].data[beat_offset] = m_cache_fill_data.data[i];
            m_dmi_cache_q[tmp_q_mntop[0]].dataErrorPerBeat[beat_offset] = m_cache_fill_data.poison[i];
            beat_offset++;
          end
        end
        <% } %> 
      end//FillSeen
    end//tmp_q.size()==1
    txn.print_entry();
    <% if(obj.useCmc && obj.DmiInfo[obj.Id].ccpParams.useScratchpad){%>
    // Not required to update the cacheline in SP txn's case as it's already done in sp_rdrsp funstion
    if(txn.sp_txn) begin
      txn.sp_atomic_wr_pending = 0;
      //This is a pre-emptive call to avoid race condition
      processSPCtrlWr(txn);
    end
    <%}%>

    if(txn.fillDataExpd)begin
      if(!txn.cache_fill_data_pkt_exp.do_compare_data(cache_fill_data))begin
        `uvm_info("<%=obj.BlockId%>:processCacheFillData:4", $sformatf("cache_fill_data :%1p",cache_fill_data), UVM_LOW)
        `uvm_info("<%=obj.BlockId%>:processCacheFillData:4", $sformatf("cache_fill_data_pkt_exp: %1p", txn.cache_fill_data_pkt_exp), UVM_LOW)
        `uvm_error("<%=obj.BlockId%>:processCacheFillData:4",$sformatf("fill data compare failed"))
      end
    end

    if(tmp_q.size() == 1)begin
      if(txn.fillDataExpd)begin
        `uvm_info("DMI_SCB", $psprintf("DMI_UID:%0d: CACHE_FILL_DATA: %s", txn.txn_id, cache_fill_data.sprint_pkt()), UVM_LOW)
        updateRttentry(txn,tmp_q[match]);
        ->ccp_fill_drop;
      end
    end else begin
      if(txn.fillDataExpd)begin
        `uvm_info("DMI_SCB", $psprintf("DMI_UID:%0d: CACHE_FILL_DATA: %s", txn.txn_id, cache_fill_data.sprint_pkt()), UVM_LOW);
        updateRttentry(txn,tmp_q3[0]);
        ->ccp_fill_drop;
      end
    end
  end
endfunction // processCacheFillData
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Update DTW Entry With Evict Address Channel
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function void dmi_scoreboard::processEvictAddr(ccp_ctrl_pkt_t cache_ctrl_pkt);
  int tmp_q[$], tmp_q2[$];
  dmi_scb_txn  m_dtw_entry;

  m_dtw_entry = new();

  uvm_config_db#(int)::get(null, "uvm_test_top", "eviction_qos", exp_eviction_qos);

  //if(!cache_ctrl_pkt.evictvld && !(WrDataClnPropagateEn && cache_ctrl_pkt.bypass && !cache_ctrl_pkt.rd_data && !cache_ctrl_pkt.wr_data &&  !cache_ctrl_pkt.rp_update && !cache_ctrl_pkt.tagstateup && !cache_ctrl_pkt.setway_debug)) begin
  if(!cache_ctrl_pkt.evictvld) begin
    `uvm_error("<%=obj.BlockId%>:processEvictAddr","Don't call this function if evictvld is not set!")
  end
  //Check address doesn't match existing address in rtt/wtt
  tmp_q = rtt_q.find_index with ((cl_aligned((item.cache_addr)) === cl_aligned(cache_ctrl_pkt.evictaddr))&& 
                                  security_match(item.security, cache_ctrl_pkt.evictsecurity) && 
                                  item.lookupExpd == 1 && 
                                  item.lookupSeen ==1 && 
                                  item.AXI_read_data_expd == 1 &&
                                  item.AXI_read_data_recd == 0 &&
                                  !item.isStale && 
                                  !item.DTR_req_recd);

  if(tmp_q.size() > 0 && !(rtt_q[tmp_q[0]].smi_msg_type == MRD_FLUSH || cache_ctrl_pkt.isMntOp == 1)) begin
    `uvm_info("<%=obj.BlockId%>:processEvictAddr",$sformatf("%p",cache_ctrl_pkt),UVM_LOW)
    print_rtt_q();
    `uvm_error("<%=obj.BlockId%>:processEvictAddr","Above Evict address matched existing RTT entry. Is this legal?")
  end

  tmp_q = {};
  tmp_q = wtt_q.find_index with ((cl_aligned((item.cache_addr)) === cl_aligned(cache_ctrl_pkt.evictaddr))&& 
                                  security_match(item.security, cache_ctrl_pkt.evictsecurity) && 
                                  item.AXI_write_addr_expd == 1 && 
                                  ((item.lookupExpd == 1 && item.lookupSeen ==1)|| item.isEvict));

  `ifndef FSYS_COVER_ON
  cov.collect_ccp_evict_addr(cache_ctrl_pkt);
  `endif
  m_dtw_entry.cache_ctrl_pkt = cache_ctrl_pkt;

  m_dtw_entry.cache_addr   = cache_ctrl_pkt.evictaddr;
  m_dtw_entry.security     = cache_ctrl_pkt.evictsecurity;
  m_dtw_entry.cache_index   = ncoreConfigInfo::get_set_index(m_dtw_entry.cache_addr,<%=obj.DmiInfo[obj.Id].FUnitId%>); 
  m_dtw_entry.isEvict      = 1;
  <%if(smiQosEn) {%>
  if(exp_eviction_qos[WSMIMSGQOS]) begin
    m_dtw_entry.smi_qos      = exp_eviction_qos[WSMIMSGQOS-1:0];
  end
  <%}%>
  m_dtw_entry.smi_size     = 6;
  m_dtw_entry.DTW_rsp_expd = 0;
  m_dtw_entry.DTW_rsp_recd = 0;
  m_dtw_entry.evictDataExpd = 1;
  m_dtw_entry.evictDataRecd = 0;
  m_dtw_entry.AXI_write_addr_expd = 1;
  m_dtw_entry.AXI_write_addr_recd = 0;
  m_dtw_entry.AXI_write_data_expd = 1;
  m_dtw_entry.AXI_write_data_recd = 0;
  m_dtw_entry.AXI_write_resp_expd = 1;
  m_dtw_entry.AXI_write_resp_recd = 0;
  m_dtw_entry.t_creation      = $time;
  m_dtw_entry.wrOutstanding = 1;
  m_dtw_entry.t_latest_update = $time;
  wtt_q.push_back(m_dtw_entry);
  m_dtw_entry.print_entry();
  `uvm_info("DMI_SCB", $psprintf("DMI_UID:%0d: EVICT_ADDR: %s", m_dtw_entry.txn_id,m_dtw_entry.cache_ctrl_pkt.sprint_pkt()), UVM_LOW)
endfunction // processEvictAddr
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Update DTW Entry with MrdCln addr when cacheline is dirty
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function void dmi_scoreboard::processRdrspAddr(ccp_ctrl_pkt_t cache_ctrl_pkt,smi_qos_t smi_qos,dmi_scb_txn txn);
  int tmp_q[$], tmp_q2[$];
  dmi_scb_txn  dtw_entry;

  dtw_entry = new();

  uvm_config_db#(int)::get(null, "uvm_test_top", "eviction_qos", exp_eviction_qos);
  if(!cache_ctrl_pkt.isMntOp)begin
    tmp_q = wtt_q.find_index with ((cl_aligned((item.cache_addr)) === cl_aligned(cache_ctrl_pkt.addr)) && 
                                    security_match(item.security, cache_ctrl_pkt.security) && 
                                    item.AXI_write_addr_expd == 1 && 
                                    ((item.lookupExpd == 1 && item.lookupSeen ==1)|| item.isEvict));
  end
  else begin
    tmp_q = wtt_q.find_index with ((cl_aligned((item.cache_addr)) === cl_aligned(cache_ctrl_pkt.evictaddr))&& 
                                    security_match(item.security,cache_ctrl_pkt.evictsecurity) && 
                                    item.AXI_write_addr_expd == 1 && 
                                    item.isEvict);
  end
  dtw_entry.cache_ctrl_pkt = cache_ctrl_pkt;
  if(cache_ctrl_pkt.isMntOp)begin
    if(!cache_ctrl_pkt.setway_debug)begin
      dtw_entry.cache_addr   = cache_ctrl_pkt.addr;
      dtw_entry.security     = cache_ctrl_pkt.security;
    end
    else begin
      dtw_entry.cache_addr   = cache_ctrl_pkt.evictaddr;
      dtw_entry.security     = cache_ctrl_pkt.evictsecurity;
    end
    <%if(smiQosEn) {%>
    if(cache_ctrl_pkt.rsp_evict_sel == 1 && cache_ctrl_pkt.rd_data == 1 && exp_eviction_qos[WSMIMSGQOS])begin
      smi_qos      = exp_eviction_qos[WSMIMSGQOS-1:0];
    end
    <%}%>
  end
  else begin
    dtw_entry.cache_addr   = cache_ctrl_pkt.addr;
    dtw_entry.security     = cache_ctrl_pkt.security;
  end
  if(txn != null)begin
    dtw_entry.privileged       = txn.privileged; 
    dtw_entry.smi_ndp_aux_aw   = txn.smi_ndp_aux_ar;  //CMO aux_r passed to wr due to eviction CONC-6800
  end
  dtw_entry.isEvict      = 1;
  dtw_entry.isRdWtt      = 1;
  dtw_entry.smi_size     = 6;
  dtw_entry.smi_qos      = smi_qos;
  dtw_entry.DTW_rsp_expd = 0;
  dtw_entry.DTW_rsp_recd = 0;
  if(!cache_ctrl_pkt.rsp_evict_sel) begin
    dtw_entry.cacheRspExpd = 1;
  end else begin
    dtw_entry.evictDataExpd = 1;
  end
  dtw_entry.rdrspDataRecd = 0;
  dtw_entry.AXI_write_addr_expd = 1;
  dtw_entry.AXI_write_addr_recd = 0;
  dtw_entry.AXI_write_data_expd = 1;
  dtw_entry.AXI_write_data_recd = 0;
  dtw_entry.AXI_write_resp_expd = 1;
  dtw_entry.AXI_write_resp_recd = 0;
  <% if(obj.testBench == "dmi") { %>
  add_mnt_op_cache_line(dtw_entry);
  <% } %> 
  dtw_entry.t_creation      = $time;
  dtw_entry.wrOutstanding = 1;
  dtw_entry.t_latest_update = $time;
  wtt_q.push_back(dtw_entry);
  dtw_entry.print_entry();
endfunction // processRdrspAddr
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Process the APB channel packet
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function void dmi_scoreboard::processApbReq (apb_pkt_t apb_entry);
  string spkt;
  dmi_scb_txn m_mntop_pkt;
  bit[31:0] mask = 32'hFFFF_FFFF;
  `uvm_info("processApbReq", $psprintf("Got_ApbReqPkt: %s",apb_entry.sprint_pkt() ),UVM_MEDIUM)

  if(apb_entry.paddr == 'h348) begin
    mntEvictIndex = apb_entry.pwdata[19:0];
    mntEvictWay   = apb_entry.pwdata[25:20];
    mntWord       = apb_entry.pwdata[31:26];
    mntEvictAddr  = apb_entry.pwdata;
  end
  else if(apb_entry.paddr == 'h34C) begin
    <% if((obj.DmiInfo[obj.Id].wAddr-obj.wCacheLineOffset) > 32) {%>
    mntEvictAddr  = {apb_entry.pwdata[15:0],mntEvictAddr[31:0]}; <%}%>
    mntEvictRange = apb_entry.pwdata[31:16];
  end
  else if(apb_entry.paddr == 'h350) begin  //
    if(apb_entry.pwrite) mntDataWord   = apb_entry.pwdata;
    else begin
      int locWord;
      <%if( (obj.DmiInfo[obj.Id].ccpParams.nBeatsPerBank == 2 && obj.DmiInfo[obj.Id].ccpParams.wData == 128) ||
            (obj.DmiInfo[obj.Id].ccpParams.nBeatsPerBank == 1 && obj.DmiInfo[obj.Id].ccpParams.wData == 256) ){%>
      locWord= mntWord[3:0];
      <%}else if( obj.DmiInfo[obj.Id].ccpParams.nBeatsPerBank == 1 && obj.DmiInfo[obj.Id].ccpParams.wData == 128) {%>
      locWord= mntWord[2:0];
      <%}else {%>
      locWord= mntWord[4:0];
      <%}%>
      // Commented the check, rddata_en and rddata takes time and not available in p2 cycle CONC-7152
      //if(mntRdDataWord !== apb_entry.prdata) begin
      if(mntOpArrId) begin
        mask &= ((locWord ) == <%=Math.ceil(wDataArrayEntry/32)-1%> ) ? ((32'h1 << <%=((wDataArrayEntry%32)-1)%>)-32'h1):
               (((locWord ) == 0) ? ((32'h1 << <%=(32-wDataProt)%>)-32'h1)<< <%=wDataProt%> :  mask); // Mask 1 bit as SCB unable to calculate ECC
      end else begin
        <% if (Math.ceil(wTagArrayEntry/32)-1) { %> 
        mask &= (locWord == <%=(obj.DmiInfo[obj.Id].ccpParams.wData/32)*obj.DmiInfo[obj.Id].ccpParams.nBeatsPerBank%> ) ? ((32'h1 << <%=(wTagArrayEntry%32)%>)-32'h1): 
               ((locWord == 0) ? ((32'h1 << <%=(32-wTagProt-1)%>)-32'h1)<< <%=wTagProt+1%> :mask); // Compare only Tag+State, skip RP and ECC
        <% } else if (wTagArrayEntry == 32) { %>
        mask &= ((32'h1 << <%=(32 - wTagProt - wRP)%>)-32'h1) << <%=wTagProt+wRP%>; // Compare only Tag+State, skip RP and ECC
        <% } else { %>
        mask &= ((32'h1 << <%=((wTagArrayEntry - wTagProt - wRP)%32)%>)-32'h1) << <%=wTagProt+wRP%>; // Compare only Tag+State, skip RP and ECC
        <% } %>
      end
      if(!mntOpArrId) begin // TagArray
      `uvm_info("MntOpDebugRd",$sformatf("Tag Array check mask:%0h Type:%0h index:%0h way:%0h word:%0h",mask,mntOpType,mntEvictIndex,mntEvictWay,mntWord),UVM_DEBUG)
        if((mntOpType == 'hC)&&((get_word_tag_array(mntEvictIndex, mntEvictWay, mntWord) & mask) !== (apb_entry.prdata & mask))) begin // DebugRd on TagArray
  	      `uvm_info("MaintOpTagArrayError",$sformatf("Got MntOpRddata:0x%0x Exp: 0x%0x mask: 0x%0x",apb_entry.prdata,get_word_tag_array(mntEvictIndex, mntEvictWay, mntWord),mask),UVM_NONE)
  	      `uvm_error("MaintOpTagArrayError",$sformatf("Got MntOpRddata:0x%0x Exp: 0x%0x mask: 0x%0x",apb_entry.prdata,get_word_tag_array(mntEvictIndex, mntEvictWay, mntWord),mask))
        end
        else begin
          `ifndef FSYS_COVER_ON
          cov.collect_CMO_entry(mntWord);
          `endif
        end
      end
      else begin // DataArray
        int localWord, localBeat;
        <%if( (obj.DmiInfo[obj.Id].ccpParams.nBeatsPerBank == 2 && obj.DmiInfo[obj.Id].ccpParams.wData == 128) ||
              (obj.DmiInfo[obj.Id].ccpParams.nBeatsPerBank == 1 && obj.DmiInfo[obj.Id].ccpParams.wData == 256) ){%>
        localWord = mntWord[3:0];
        localBeat = mntWord[4:4];
        <%}else if( obj.DmiInfo[obj.Id].ccpParams.nBeatsPerBank == 1 && obj.DmiInfo[obj.Id].ccpParams.wData == 128) {%>
        localWord = mntWord[2:0];
        localBeat = mntWord[4:3];
        <%}else {%>
        localWord = mntWord[4:0];
        localBeat = mntWord[5:5];
        <%}%>

        `uvm_info("MntOpDebugRd",$sformatf("Data Array check mask:%0h Type:%0h index:%0h way:%0h word:%0h",mask,mntOpType,mntEvictIndex,mntEvictWay,mntWord),UVM_DEBUG)
        if((mntOpType == 'hC)&&((get_word_data_array(mntEvictIndex, mntEvictWay, localBeat, localWord) & mask) !== (apb_entry.prdata & mask))) begin // DebugRd on DataArray
          bit[5:0] literalWord=0;
          int i = 0;
          for(i =0;i<4;i++) begin
            if(i % <%=obj.DmiInfo[obj.Id].ccpParams.nBeatsPerBank%> == 0) begin
              if((get_word_data_array(mntEvictIndex, mntEvictWay, i,localWord) & mask) == (apb_entry.prdata & mask)) begin
                literalWord = {i,localWord};
                localBeat = i;
                localWord = localWord;
                break;
              end
            end
          end
	        `uvm_info("MaintOpDataArrayError",$sformatf("Got MntOpRddata:0x%0x Exp: 0x%0x mask: 0x%0x MntWord:%0x beat:%0x word:%0x literalWord:%0x",apb_entry.prdata,get_word_data_array(mntEvictIndex, mntEvictWay, localBeat, localWord),mask,mntWord,localBeat,localWord,literalWord),UVM_LOW)
	        `uvm_error("MaintOpDataArrayError",$sformatf("Got MntOpRddata:0x%0x Exp: 0x%0x mask: 0x%0x MntWord:%0x beat:%0x word:%0x literalWord:%0x",apb_entry.prdata,get_word_data_array(mntEvictIndex, mntEvictWay, localBeat, localWord),mask,mntWord,localBeat,localWord,literalWord))
        end
        else begin
          `ifndef FSYS_COVER_ON
          cov.collect_CMO_entry(mntWord);
          `endif
        end
      end
    end
  end 
  else if (apb_entry.paddr == 'h340) begin
    mntOpType = apb_entry.pwdata[3:0];
    mnt_PcSecAttr = apb_entry.pwdata[22];
    mntOpArrId = apb_entry.pwdata[21:16];
    if(mntOpType == 'h6) begin
      m_mntop_pkt                  = new();
      m_mntop_pkt.isMntOp          = 1;
      m_mntop_pkt.mntop_addr       = mntEvictAddr;
      m_mntop_pkt.mntop_security   = mnt_PcSecAttr;
      m_mntop_pkt.m_mntop_cmd_type = MNTOP_FLUSH_BY_ADDR;
      m_mntop_pkt.t_creation       = $time;
      m_mntop_pkt.t_latest_update  = $time;
      m_mntop_q.push_back(m_mntop_pkt);
      ->maint_op_raise;

      spkt = {"FlushAddr:%0h MntOpType:%0d, Security:%0d"};
      `uvm_info("GOT_MNT_OP_BY_ADDR", $psprintf(spkt,mntEvictAddr,mntOpType,mnt_PcSecAttr),UVM_MEDIUM)
    end
    else if(mntOpType == 'h7) begin
      for (int i=0; i<=mntEvictRange; i++) begin
          m_mntop_pkt                  = new();
          m_mntop_pkt.isMntOp          = 1;
          m_mntop_pkt.mntop_addr       = mntEvictAddr;
          m_mntop_pkt.mntop_security   = mnt_PcSecAttr;
          m_mntop_pkt.m_mntop_cmd_type = MNTOP_FLUSH_BY_ADDR_RANGE;
          m_mntop_pkt.t_creation       = $time;
          m_mntop_pkt.t_latest_update  = $time;
          m_mntop_q.push_back(m_mntop_pkt);
          ->maint_op_raise;
          mntEvictAddr = mntEvictAddr + 1'b1;
      end

      spkt = {"FlushAddr:%0h MntOpType:%0d, Security:%0d, Range: %d"};
      `uvm_info("GOT_MNT_OP_BY_ADDR_RANGE", $psprintf(spkt,mntEvictAddr,mntOpType,mnt_PcSecAttr,
                 mntEvictRange),UVM_LOW)
    end
    else if(mntOpType == 'h8) begin
      for(int i=0; i<=mntEvictRange; i++) begin
        m_mntop_pkt = new();
        m_mntop_pkt.isMntOp = 1;
        m_mntop_pkt.mntop_index = mntEvictIndex;
        m_mntop_pkt.mntop_way   = mntEvictWay;
        m_mntop_pkt.m_mntop_cmd_type = MNTOP_FLUSH_BY_INDEX_RANGE;
        m_mntop_pkt.t_creation     = $time;
        m_mntop_pkt.t_latest_update = $time;
        m_mntop_q.push_back(m_mntop_pkt);
        ->maint_op_raise;
        mntEvictWay  = mntEvictWay  + 1'b1;

        if(mntEvictWay == <%=obj.DmiInfo[obj.Id].ccpParams.nWays%>) begin
          mntEvictWay   = 0;
          mntEvictIndex = mntEvictIndex + 1;
        end

        if(mntEvictIndex == <%=obj.DmiInfo[obj.Id].ccpParams.nSets%>) begin
          mntEvictIndex = 0;
        end
      end
      spkt = {"FlushIndex:%0d FlushWay:%0d MntOpType:%0d, Range: %d"};
      `uvm_info("GOT_MNT_OP_BY_INDEX_RANGE", $psprintf(spkt,mntEvictIndex,mntEvictWay,mntOpType,
                 mntEvictRange),UVM_LOW)
    end
    else if (mntOpType == 'h5) begin
      m_mntop_pkt = new();
      m_mntop_pkt.isMntOp = 1;
      m_mntop_pkt.mntop_index = mntEvictIndex;
      m_mntop_pkt.mntop_way   = mntEvictWay;
      m_mntop_pkt.m_mntop_cmd_type = MNTOP_FLUSH_BY_INDEX;
      m_mntop_pkt.t_creation     = $time;
      m_mntop_pkt.t_latest_update = $time;
      m_mntop_q.push_back(m_mntop_pkt);
      ->maint_op_raise;

      spkt = {"FlushIndex:%0d FlushWay:%0d MntOpType:%0d"};
      `uvm_info("GOT_FLUSH_BY_INDEX", $psprintf(spkt,mntEvictIndex,mntEvictWay,mntOpType),UVM_MEDIUM)
    end
    else if (mntOpType == 'hC) begin 
      m_mntop_pkt = new();
      m_mntop_pkt.isMntOp = 1;
      m_mntop_pkt.mntop_index = mntEvictIndex;
      m_mntop_pkt.mntop_way   = mntEvictWay;
      m_mntop_pkt.mntop_word  = mntWord;
      m_mntop_pkt.mntop_ArrayId = mntOpArrId;
      m_mntop_pkt.m_mntop_cmd_type = MNTOP_DEBUG_READ;
      m_mntop_pkt.t_creation     = $time;
      m_mntop_pkt.t_latest_update = $time;
      m_mntop_q.push_back(m_mntop_pkt);
      ->maint_op_raise;

      spkt = {"ReadIndex:%0d ReadWay:%0d ReadWord:%0d MntOpType:%0d"};
      `uvm_info("GOT_DEBUG_READ", $psprintf(spkt,mntEvictIndex,mntEvictWay,mntWord,mntOpType),UVM_MEDIUM)
    end 
    else if (mntOpType == 'hE) begin
      m_mntop_pkt = new();
      m_mntop_pkt.isMntOp = 1;
      m_mntop_pkt.mntop_index = mntEvictIndex;
      m_mntop_pkt.mntop_way   = mntEvictWay;
      m_mntop_pkt.mntop_word  = mntWord;
      m_mntop_pkt.mntop_ArrayId = mntOpArrId;
      m_mntop_pkt.mntop_Dataword  = mntDataWord;
      m_mntop_pkt.m_mntop_cmd_type = MNTOP_DEBUG_WRITE;
      m_mntop_pkt.t_creation     = $time;
      m_mntop_pkt.t_latest_update = $time;
      m_mntop_q.push_back(m_mntop_pkt);
      ->maint_op_raise;
      spkt = {"WriteIndex:%0d WriteWay:%0d WriteWord:%0d MntOpType:%0d"};
      `uvm_info("GOT_DEBUG_WRITE", $psprintf(spkt,mntEvictIndex,mntEvictWay,mntWord,mntOpType),UVM_MEDIUM)
      if(!mntOpArrId) begin // TagArray
        if (!$test$plusargs("disable_mnt_op_set_word_tag_and_data_methods")) begin
          set_word_tag_array(mntEvictIndex, mntEvictWay, mntWord, mntDataWord); // DebugWr on TagArray
        end
      end else begin // DataArray
        if (!$test$plusargs("disable_mnt_op_set_word_tag_and_data_methods")) begin
          set_word_data_array(mntEvictIndex, mntEvictWay, mntWord, mntDataWord); // DebugWr on DataArray
        end
      end
    end
    else if(mntOpType == 'h4) begin
      for(int i=0; i<<%=obj.DmiInfo[obj.Id].ccpParams.nSets%>; i++) begin
        for(int m=0; m< <%=obj.DmiInfo[obj.Id].ccpParams.nWays%>; m++) begin
           m_mntop_pkt = new();
           m_mntop_pkt.isMntOp = 1;
           m_mntop_pkt.mntop_index = i;
           m_mntop_pkt.mntop_way   = m;
           m_mntop_pkt.m_mntop_cmd_type = MNTOP_FLUSH_BY_INDEX;
           m_mntop_pkt.t_creation     = $time;
           m_mntop_pkt.t_latest_update = $time;
           m_mntop_q.push_back(m_mntop_pkt);
           ->maint_op_raise;
        end
      end
      spkt = {"MntOp Flush All operation programmed"};
      `uvm_info("GOT_MNT_OP_FLUSH_ALL",spkt,UVM_MEDIUM)
    end 
  end
endfunction // processApbReq

////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Function: write_ccp_csr_maint_chnl 
// Purpose: 
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function void dmi_scoreboard::write_ccp_csr_maint_chnl(ccp_csr_maint_pkt_t m_pkt);
  ccp_csr_maint_pkt_t m_packet;
  m_packet = new();
  m_packet.copy(m_pkt);
  `uvm_info("<%=obj.BlockId%>:write_ccp_csr_main", $sformatf("ccp_csr_maint_pkt: %s ",m_packet.sprint_pkt()), UVM_MEDIUM);
endfunction
<% } %>

function void dmi_scoreboard::MrgMrddata(ref dmi_scb_txn scb_txn);
  foreach(scb_txn.dtw_req_pkt.smi_dp_data[i])begin 
    foreach(scb_txn.dtw_req_pkt.smi_dp_be[i][j])begin
      if(scb_txn.dtw_req_pkt.smi_dp_be[i][j])begin
        <% if (obj.useCmc) { %>
        if(!scb_txn.isCacheHit)begin// for CacheHit data will be merged by CCP , no external merge
        <% } %>
        if(scb_txn.AXI_read_data_recd) begin
          scb_txn.axi_read_data_pkt.rdata[i][8*j+:8] = scb_txn.dtw_req_pkt.smi_dp_data[i][8*j+:8];
        end
        <% if (obj.useCmc) { %>
        end
        <% } %>
      end
    end 
  end
  scb_txn.dtr_req_pkt_exp = new();
  scb_txn.dtr_req_pkt_exp.smi_dp_data = new[scb_txn.expd_dtr_beats];
  scb_txn.dtr_req_pkt_exp.smi_dp_dbad = new[scb_txn.expd_dtr_beats];
  scb_txn.dtr_req_pkt_exp.smi_dp_dwid = new[scb_txn.expd_dtr_beats];
  scb_txn.dtr_smi_cmstatus            = new[scb_txn.expd_dtr_beats];
  for(int i =0;i<scb_txn.expd_dtr_beats;i++)begin
    <% if (obj.useCmc) { %>
    if(scb_txn.isCacheHit)begin
      scb_txn.dtr_req_pkt_exp.smi_dp_data[i]     = scb_txn.cache_rd_data_pkt.data[i]; 
      if((scb_txn.cache_rd_data_pkt.poison[i]) || (scb_txn.dtw_req_pkt.smi_dp_dbad[i] != 0))begin
        for (int j=0;j<(WXDATA/64);j++) begin
          scb_txn.dtr_req_pkt_exp.smi_dp_dbad[i][j]  = 1;
        end
      end
      `uvm_info("MrgMrdDataPoison",$sformatf("::CACHE_HIT:: %0p = %0p || %0p ",scb_txn.dtr_req_pkt_exp.smi_dp_dbad, scb_txn.cache_rd_data_pkt.poison, scb_txn.dtw_req_pkt.smi_dp_dbad),UVM_DEBUG) 
    end
    else if (!scb_txn.sp_txn) begin
    <% } %>
      scb_txn.dtr_req_pkt_exp.smi_dp_data[i]     = scb_txn.axi_read_data_pkt.rdata[i]; 
      if((scb_txn.axi_read_data_pkt.rresp_per_beat[i] > 1) || (scb_txn.dtw_req_pkt.smi_dp_dbad[i] != 0))begin
        for (int j=0;j<(WXDATA/64);j++) begin
          scb_txn.dtr_req_pkt_exp.smi_dp_dbad[i][j]     = 1;
        end
      end
      if(scb_txn.axi_read_data_pkt.rresp_per_beat[i] == 2'b10)begin 
        scb_txn.dtr_smi_cmstatus[i]            = 8'b10000011;
      end
      else if(scb_txn.axi_read_data_pkt.rresp_per_beat[i] == 2'b11)begin
        scb_txn.dtr_smi_cmstatus[i]            = 8'b10000100;
      end
      `uvm_info("MrgMrdDataPoison",$sformatf("::CACHE_MISS:: %0p = %0p || %0p ",scb_txn.dtr_req_pkt_exp.smi_dp_dbad, scb_txn.axi_read_data_pkt.rresp_per_beat,scb_txn.dtw_req_pkt.smi_dp_dbad),UVM_DEBUG)
    <% if (obj.useCmc) { %>
    end
    else if(scb_txn.sp_txn) begin
      scb_txn.dtr_req_pkt_exp.smi_dp_dbad[i] = scb_txn.error_expected[i];
      scb_txn.dtr_req_pkt_exp.smi_dp_data[i] = (scb_txn.error_expected[i] != 0) ? 0 : scb_txn.sp_read_data_pkt.data[i];
      `uvm_info("MrgMrdDataPoison",$sformatf("::SP_TXN:: DTR Exp[%0d] Data:%0p Poison:%0p", i, scb_txn.dtr_req_pkt_exp.smi_dp_data[i], scb_txn.dtr_req_pkt_exp.smi_dp_dbad[i]),UVM_DEBUG)
    end
    <% } %>
  end
  <% if (obj.useCmc) { %>
  if(scb_txn.fillDataExpd)begin
    for(int i =0;i<scb_txn.axi_read_data_pkt.rdata.size();i++)begin
      scb_txn.cache_fill_data_pkt_exp.data[i]    =  scb_txn.axi_read_data_pkt.rdata[i]; 
      if((scb_txn.axi_read_data_pkt.rresp_per_beat[i] > 1) || (scb_txn.dtw_req_pkt.smi_dp_dbad[i] != 0))begin
        scb_txn.cache_fill_data_pkt_exp.poison[i]     = 1;
      end
    end
  end
  <% } %>
  scb_txn.DtrRdy    = 1;
endfunction:MrgMrddata
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Function: merge_write_data 
// Purpose: 
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function void dmi_scoreboard::merge_mw_data(input  int index);
  smi_addr_t                       addr,m_start_addr,start_addr,m_lower_wrapped_boundary,m_upper_wrapped_boundary;
  bit [$clog2(NUM_BEATS_IN_DTR)-1:0] data_beat;
  int no_of_bytes;
  int burst_length;
  int data_size;
  int dt_size;
  int dtw_req_bytes;

  addr                         = wtt_q[index].cache_addr;
  data_size                    = wtt_q[index].dtw_req_pkt.smi_dp_data.size(); 

  dtw_req_bytes                = (2**wtt_q[index].rb_req_pkt.smi_size); 

  no_of_bytes                  = (WDPDATA/8);
  if(dtw_req_bytes%no_of_bytes > 0)begin
    burst_length               = (dtw_req_bytes/no_of_bytes)+1;
  end 
  else begin
    burst_length               = dtw_req_bytes/no_of_bytes;
  end

  dt_size                      = no_of_bytes * burst_length;
  m_start_addr                 = ((addr/(WDPDATA/8)) * (WDPDATA/8));
  m_lower_wrapped_boundary     = ((addr/(dt_size)) * (dt_size)); 
  m_upper_wrapped_boundary     = m_lower_wrapped_boundary + (dt_size); 

  for(int i=0; i<burst_length;i++) begin
    if(wtt_q[index].smi_burst == 'b00 && (m_start_addr >= m_upper_wrapped_boundary)) begin
      data_beat = m_lower_wrapped_boundary[LINE_INDEX_H:LINE_INDEX_L];
    end 
    
    if((wtt_q[index].smi_burst == 'b00) && (m_start_addr >= m_upper_wrapped_boundary) ) begin
      m_start_addr = m_lower_wrapped_boundary;
    end
    else begin
      m_start_addr = m_start_addr + no_of_bytes;
    end

    for(int index_bit=0; index_bit<no_of_bytes;index_bit++) begin
      if(wtt_q[index].dtw2nd_req_pkt.smi_dp_be[i][index_bit] == 1'b1) begin
        wtt_q[index].dtw_req_pkt.smi_dp_data[data_beat][(8*index_bit) +: 8] =  wtt_q[index].dtw2nd_req_pkt.smi_dp_data[i][(8*index_bit) +: 8];
      end
    end
    data_beat = data_beat +  1'b1;
  end
endfunction: merge_mw_data

<% if (obj.useCmc) { %>
function void dmi_scoreboard::merge_write_data(input  int index, input  smi_seq_item   dtw_req_pkt, input  bit   SV);
  smi_dp_data_bit_t                exp_data[];
  smi_addr_t                       addr,m_start_addr,start_addr,m_lower_wrapped_boundary,m_upper_wrapped_boundary;
  bit [$clog2(NUM_BEATS_IN_DTR)-1:0] data_beat;
  bit [$clog2(NUM_BEATS_IN_DTR)-1:0] beatn;
  bit [$clog2(NUM_BEATS_IN_DTR)-1:0] ccp_data_beat[];
  int no_of_bytes;
  int burst_length;
  int data_size;
  int dt_size;
  int dtw_req_bytes;
  int beat_count = 0;
  bit weird_wrap = 0;


  addr                         = wtt_q[index].cache_addr;
  data_size                    = wtt_q[index].dtw_req_pkt.smi_dp_data.size(); 
  no_of_bytes                  = (WDPDATA/8);

  if(wtt_q[index].dtw_req_pkt.smi_prim)begin
   dtw_req_bytes                = (2**wtt_q[index].smi_size); 
  end
  else begin
   dtw_req_bytes               = data_size*no_of_bytes; 
  end

  if(dtw_req_bytes%no_of_bytes > 0)begin
    burst_length               = (dtw_req_bytes/no_of_bytes)+1;
  end 
  else begin
    burst_length               = dtw_req_bytes/no_of_bytes;
  end

  //Caclulate the Wrap address based on the AXI spec
  dt_size                      = no_of_bytes * burst_length;
  m_start_addr                 = ((addr/(WDPDATA/8)) * (WDPDATA/8));
  start_addr                   = m_start_addr;
  m_lower_wrapped_boundary     = ((addr/(dt_size)) * (dt_size)); 
  m_upper_wrapped_boundary     = m_lower_wrapped_boundary + (dt_size); 
  ccp_data_beat                = new[data_size];

  // `uvm_info("merge_write_data",$sformatf("data_size :%d m_lower_wrapped_boundary :%0x m_start_add :%0x",dt_size,m_lower_wrapped_boundary,m_start_addr),UVM_LOW);

  if(wtt_q[index].smi_burst == 'b00)begin
    if(dt_size < SYS_nSysCacheline &&  m_lower_wrapped_boundary < m_start_addr)begin
      int j = 0;
      weird_wrap = 1;
     `uvm_info("merge_write_data",$sformatf("weird wrap hit data_size :%d m_lower_wrapped_boundary :%0x m_start_add :%0x",dt_size,m_lower_wrapped_boundary,m_start_addr),UVM_DEBUG);
       
      for (int i = 0; i < data_size; i++) begin 
        ccp_data_beat[i] = start_addr[LINE_INDEX_H:LINE_INDEX_L];
        start_addr = start_addr + no_of_bytes;
        if (start_addr >= m_upper_wrapped_boundary) begin
         start_addr = m_lower_wrapped_boundary;
        end
      end
      for (int i = 0; i < data_size; i++) begin 
        m_start_addr = m_start_addr + no_of_bytes;
        if (m_start_addr >= m_upper_wrapped_boundary && beat_count === 0) begin
          beat_count = burst_length - i;
        end
      end
      for (int i = data_size - beat_count; i < data_size; i++) begin
        wtt_q[index].dtw_req_pkt.smi_dp_data[i] = wtt_q[index].dtw_req_pkt.smi_dp_data[data_size - beat_count + j];
        wtt_q[index].dtw_req_pkt.smi_dp_be[i]   = wtt_q[index].dtw_req_pkt.smi_dp_be[data_size - beat_count + j];
       `uvm_info("merge_write_data",$sformatf("i :%0d beat_count :%0d data:%0x",i,beat_count,wtt_q[index].dtw_req_pkt.smi_dp_data[dtw_req_pkt.smi_dp_data.size() - beat_count + j]),UVM_DEBUG);
       `uvm_info("merge_write_data",$sformatf("i :%0d beat_count :%0d data:%0x",i,beat_count,wtt_q[index].dtw_req_pkt.smi_dp_data[dtw_req_pkt.smi_dp_be.size() - beat_count + j]),UVM_DEBUG);
       `uvm_info("merge_write_data",$sformatf("J :%0d ccp_beatn :%d data :%0x be:%0x",j,ccp_data_beat[i],wtt_q[index].dtw_req_pkt.smi_dp_data[i],wtt_q[index].dtw_req_pkt.smi_dp_be[i]),UVM_DEBUG);
        j++;
      end
    end
    else begin
    for (int i = 0; i < data_size; i++) begin 
      ccp_data_beat[i] = start_addr[LINE_INDEX_H:LINE_INDEX_L];
      start_addr = start_addr + no_of_bytes;
     `uvm_info("merge_write_data",$sformatf("ccp_beatn :%d data :%0x be:%0x",ccp_data_beat[i],wtt_q[index].dtw_req_pkt.smi_dp_data[i],wtt_q[index].dtw_req_pkt.smi_dp_be[i]),UVM_DEBUG);
    end
    end
  end
  else begin
    for (int i = 0; i < data_size; i++) begin 
      ccp_data_beat[i] = start_addr[LINE_INDEX_H:LINE_INDEX_L];
      start_addr = start_addr + no_of_bytes;
     `uvm_info("merge_write_data",$sformatf("ccp_beatn :%d data :%0x be:%0x",ccp_data_beat[i],wtt_q[index].dtw_req_pkt.smi_dp_data[i],wtt_q[index].dtw_req_pkt.smi_dp_be[i]),UVM_DEBUG);
    end
  end
  if(wtt_q[index].isWrThBypass && weird_wrap)begin
     data_size = (SYS_nSysCacheline*8)/WDPDATA;
  end
  <% if (obj.useCmc) { %>
  wtt_q[index].cache_wr_data_pkt_exp = new();
  wtt_q[index].cache_wr_data_pkt_exp.data    = new[data_size];
  wtt_q[index].cache_wr_data_pkt_exp.beatn   = new[data_size];
  wtt_q[index].cache_wr_data_pkt_exp.byten   = new[data_size];
  wtt_q[index].cache_wr_data_pkt_exp.poison = new[data_size];
  if(wtt_q[index].isWrThBypass && weird_wrap)begin 
    for(int i = 0; i < data_size; i++) begin 
      beatn = start_addr[LINE_INDEX_H:LINE_INDEX_L];
      start_addr = start_addr + no_of_bytes;
      wtt_q[index].cache_wr_data_pkt_exp.data[i]  = 0;
      wtt_q[index].cache_wr_data_pkt_exp.byten[i] = 0;
      wtt_q[index].cache_wr_data_pkt_exp.beatn[i] = beatn;
    end
    foreach(ccp_data_beat[i])begin
      foreach(wtt_q[index].cache_wr_data_pkt_exp.data[j])begin
        if(wtt_q[index].cache_wr_data_pkt_exp.beatn[j] == ccp_data_beat[i])begin
          wtt_q[index].cache_wr_data_pkt_exp.data[j]  = wtt_q[index].dtw_req_pkt.smi_dp_data[i];
          wtt_q[index].cache_wr_data_pkt_exp.byten[j] = wtt_q[index].dtw_req_pkt.smi_dp_be[i];
          if(wtt_q[index].dtw_req_pkt.smi_dp_dbad[i] !== 0)begin
           wtt_q[index].cache_wr_data_pkt_exp.poison[j] = 1;
          end
        end
      end 
    end
  end
  else begin
    for(int i = 0; i < data_size; i++) begin 
      wtt_q[index].cache_wr_data_pkt_exp.data[i]  = wtt_q[index].dtw_req_pkt.smi_dp_data[i];
      wtt_q[index].cache_wr_data_pkt_exp.byten[i] = wtt_q[index].dtw_req_pkt.smi_dp_be[i];
      wtt_q[index].cache_wr_data_pkt_exp.beatn[i] = ccp_data_beat[i];
      if(wtt_q[index].dtw_req_pkt.smi_dp_dbad[i] !== 0)begin
       wtt_q[index].cache_wr_data_pkt_exp.poison[i] = 1;
      end
    end 
  end
  for (int i = 0; i < data_size; i++) begin 
    `uvm_info("merge_write_data",$sformatf("beatn :%0d  data :%0x be:%0x poison:%0x",wtt_q[index].cache_wr_data_pkt_exp.beatn[i],wtt_q[index].cache_wr_data_pkt_exp.data[i],wtt_q[index].cache_wr_data_pkt_exp.byten[i], wtt_q[index].cache_wr_data_pkt_exp.poison[i]),UVM_DEBUG);
  end
  <% } %>
endfunction

function axi_axaddr_t dmi_scoreboard::shift_addr(input axi_axaddr_t in_addr);
    axi_axaddr_t out_addr;
    out_addr = in_addr[WAXADDR - 1:SYS_wSysCacheline];
    return out_addr;
endfunction
<% } %>


//-------------------------------------------Begin Scratchpad-------------------------------------------------------------------------
<% if(obj.useCmc && obj.DmiInfo[obj.Id].ccpParams.useScratchpad){%>
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// process/check the SP control channel packet and predict the txn's further behaviour
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function void dmi_scoreboard::processSPCtrl(ccp_sp_ctrl_pkt_t sp_ctrl_entry);
  int         coh_wr_match_q[$], non_coh_wr_match_q[$], m_tmp2_q[$], m_tmp3_q[$], m_tmp4_q[$], m_tmp5_q[$],m_tmp_q[$],m_tmp6_q[$];
  dmi_scb_txn matched_entry, oldest_coh_entry, oldest_noncoh_entry;
  string      spkt;
  smi_addr_t  addr;
  int         no_of_bytes;
  int         index;
  int         burst_length;
  longint     m_lower_wrapped_boundary;
  longint     m_upper_wrapped_boundary;
  longint     m_start_addr;
  int         exp_burst_len;
  parameter NUM_BEATS_IN_CACHELINE = ((SYS_nSysCacheline*8)/WCCPDATA);
  bit [$clog2(NUM_BEATS_IN_CACHELINE)-1:0] beat_offset=0;

  `uvm_info("ProcessSPCtrl", $psprintf("Got_SPCtrlPkt: %s",sp_ctrl_entry.sprint_pkt() ),UVM_MEDIUM)

  // #Check.DMI.Concerto.v3.0.OnlySPTxnsOnSPCtrlChnl
  // #Check.DMI.Concerto.v3.0.SPCtrlInterfaceSignals

  coh_wr_match_q = {};
  coh_wr_match_q = wtt_q.find_index() with (item.sp_txn            == 1                              &&
                                      item.sp_seen_ctrl_chnl == 0                              &&
                                      item.sp_data_bank      == sp_ctrl_entry.sp_op_data_bank  &&
                                      item.sp_index          == sp_ctrl_entry.sp_op_index_addr &&
                                      item.sp_way            == sp_ctrl_entry.sp_op_way_num    &&
                                      item.sp_beat_num       == sp_ctrl_entry.sp_op_beat_num   &&
                                      item.DTW_req_recd &&
                                      item.isCoh             == 1
                                     );
  non_coh_wr_match_q = {};
  non_coh_wr_match_q = wtt_q.find_index() with (item.sp_txn            == 1                              &&
                                      item.sp_seen_ctrl_chnl == 0                              &&
                                      item.sp_data_bank      == sp_ctrl_entry.sp_op_data_bank  &&
                                      item.sp_index          == sp_ctrl_entry.sp_op_index_addr &&
                                      item.sp_way            == sp_ctrl_entry.sp_op_way_num    &&
                                      item.sp_beat_num       == sp_ctrl_entry.sp_op_beat_num   &&
                                      item.isCoh             == 0                              &&
                                      item.CMD_rsp_recd_rtl  == 1
                                     );

  if(sp_ctrl_entry.sp_op_msg_type inside {CMD_CLN_INV,CMD_CLN_VLD,CMD_CLN_SH_PER,CMD_MK_INV,CMD_RD_NC,CMD_RD_ATM,CMD_WR_ATM,CMD_SW_ATM,CMD_CMP_ATM})begin 
    m_tmp2_q = {};
    m_tmp2_q = rtt_q.find_index() with (item.sp_txn            == 1                              &&
                                        item.sp_seen_ctrl_chnl == 0                              &&
                                        item.isCoh             == 0                              &&
                                        item.sp_data_bank      == sp_ctrl_entry.sp_op_data_bank  &&
                                        item.sp_index          == sp_ctrl_entry.sp_op_index_addr &&
                                        item.sp_way            == sp_ctrl_entry.sp_op_way_num    &&
                                        item.sp_beat_num       == sp_ctrl_entry.sp_op_beat_num   &&
                                        item.CMD_rsp_recd_rtl  == 1
                                       );
   end
   else begin
     m_tmp2_q = {};
     m_tmp2_q = rtt_q.find_index() with (item.sp_txn            == 1                              &&
                                         item.sp_seen_ctrl_chnl == 0                              &&
                                         item.isCoh             == 1                              &&
                                         item.sp_data_bank      == sp_ctrl_entry.sp_op_data_bank  &&
                                         item.sp_index          == sp_ctrl_entry.sp_op_index_addr &&
                                         item.sp_way            == sp_ctrl_entry.sp_op_way_num    &&
                                         item.sp_beat_num       == sp_ctrl_entry.sp_op_beat_num   &&
                                         item.MRD_req_recd_rtl  == 1
                                        );
   end

   m_tmp4_q = {};
   m_tmp4_q = rtt_q.find_index() with (item.sp_txn                == 1                              &&
                                        item.sp_atomic_wr_pending  == 1                              &&
                                        item.sp_data_bank          == sp_ctrl_entry.sp_op_data_bank  &&
                                        item.sp_index              == sp_ctrl_entry.sp_op_index_addr &&
                                        item.sp_way                == sp_ctrl_entry.sp_op_way_num
                                       );

  // If an atomic req is pending for a cacheline, then no other req 
  // can come for same cacheline address until atomic write finishes
  // #Check.DMI.Concerto.v3.0.NoTxnWhenAtomicPending
  if(sp_ctrl_entry.sp_op_rd_data || sp_ctrl_entry.sp_op_wr_data) begin
    if(m_tmp4_q.size()>0) begin
      rtt_q[m_tmp4_q[0]].print_entry;
      `uvm_error(`LABEL_ERROR,$sformatf("Trying to access the memory on which atomic transaction is pending,Pending atomic transaction printed above"));
    end
  end
  if(sp_ctrl_entry.sp_op_wr_data) begin
    if(non_coh_wr_match_q.size() == 0 && coh_wr_match_q.size() == 0) begin
      `uvm_error(`LABEL_ERROR, $sformatf("no corresponding write txn found in TB,for received SP ctrl packet"));
    end else begin
      bit found_match = 0;
      int oldest_idx_coh, oldest_idx_noncoh;
      if(sp_ctrl_entry.sp_op_rd_data == 1) begin
        //Filter for merge writes when both rd/wr data flags are set on SP control channel        
        coh_wr_match_q = {};
        coh_wr_match_q = wtt_q.find_index() with (item.sp_txn== 1                              &&
                                      item.sp_seen_ctrl_chnl == 0                              &&
                                      item.sp_data_bank      == sp_ctrl_entry.sp_op_data_bank  &&
                                      item.sp_index          == sp_ctrl_entry.sp_op_index_addr &&
                                      item.sp_way            == sp_ctrl_entry.sp_op_way_num    &&
                                      item.sp_beat_num       == sp_ctrl_entry.sp_op_beat_num   &&
                                      item.DTW_req_recd      &&
                                      item.isDtwMrgMrd       &&
                                      item.isCoh             == 1
                                     );
      end
      if(coh_wr_match_q.size()>0) begin
        oldest_idx_coh = find_oldest_entry_in_wtt_q(coh_wr_match_q);
        oldest_coh_entry = wtt_q[oldest_idx_coh];
        if(oldest_coh_entry.dtw_msg_type == sp_ctrl_entry.sp_op_msg_type) begin
          matched_entry = oldest_coh_entry;
          found_match = 1;
        end
      end
      if(non_coh_wr_match_q.size()>0) begin 
        oldest_idx_noncoh = find_oldest_entry_in_wtt_q(non_coh_wr_match_q);
        oldest_noncoh_entry = wtt_q[oldest_idx_noncoh];
        if(oldest_noncoh_entry.dtw_msg_type == sp_ctrl_entry.sp_op_msg_type) begin
          matched_entry = oldest_noncoh_entry;
          found_match = 1;
        end
      end
      if(!found_match) begin
        `uvm_info(`LABEL_ERROR,$sformatf("Matches found coh_wr_match_q:%0d non_coh_wr_match_q:%0d oldest_idx:: coh:%0d noncoh:%0d",
                                        coh_wr_match_q.size(),non_coh_wr_match_q.size(),wtt_q[oldest_idx_coh].txn_id,wtt_q[oldest_idx_noncoh].txn_id),UVM_MEDIUM)
        if(coh_wr_match_q.size() > 0) begin
          `uvm_info(`LABEL_ERROR,"Coherent entry matches below", UVM_MEDIUM)
          foreach(coh_wr_match_q[i]) begin
            wtt_q[coh_wr_match_q[i]].print_entry();
          end
          `uvm_info(`LABEL_ERROR,"-------------------------------------------------", UVM_MEDIUM)
        end
        if(non_coh_wr_match_q.size() > 0) begin
          `uvm_info(`LABEL_ERROR,"Non-Coherent entry matches below", UVM_MEDIUM)
          foreach(non_coh_wr_match_q[i]) begin
            wtt_q[non_coh_wr_match_q[i]].print_entry();
          end
          `uvm_info(`LABEL_ERROR,"-------------------------------------------------", UVM_MEDIUM)
        end
        `uvm_error(`LABEL_ERROR, $sformatf("Oldest entry doesn't match scratchpad MsgType:%0h", sp_ctrl_entry.sp_op_msg_type))
      end
      matched_entry.m_sp_ctrl_pkt = new();
      matched_entry.m_sp_ctrl_pkt = sp_ctrl_entry;
      matched_entry.sp_write_through = sp_ctrl_entry.sp_op_wr_data & sp_ctrl_entry.sp_op_rd_data;
      `uvm_info("DMI_SCB", $psprintf("DMI_UID:%0d: SP_CTRL: %s", matched_entry.txn_id, sp_ctrl_entry.sprint_pkt()), UVM_LOW)
      // In case of DtwMergeMrd transaction, sp_op_rd_data should also be high
      // #Check.DMI.Concerto.v3.0.BothRdWrHighForDtwMrgMrd
      if(isdtwmrgmrd(matched_entry.dtw_msg_type) ^ sp_ctrl_entry.sp_op_rd_data) begin
        matched_entry.print_entry();
        `uvm_error(`LABEL_ERROR,$sformatf("sp_op_rd_data is not high for DtwMergeMrd transaction or high for,non-DtwMergeMrd transaction isTxnDtwMergeMrd %0b sp_op_rd_data %0b", isdtwmrgmrd(matched_entry.dtw_msg_type), sp_ctrl_entry.sp_op_rd_data));
      end

      if(isdtwmrgmrd(matched_entry.dtw_msg_type) && !matched_entry.isRttCreated) begin
        // Creating new RTT entry for the Merged Read
        processMrdReq(matched_entry.rb_req_pkt,1,matched_entry);
        rtt_q[$].sp_seen_ctrl_chnl   = 1;
        rtt_q[$].t_sp_seen_ctrl_chnl = $time;
        rtt_q[$].m_sp_ctrl_pkt       = sp_ctrl_entry;
      end
      else if (isdtwmrgmrd(matched_entry.dtw_msg_type) && matched_entry.isRttCreated) begin
        m_tmp6_q = {};
        m_tmp6_q = rtt_q.find_index with (item.isDtwMrgMrd  &&
                                         (item.dtw_req_pkt.smi_mpf1[WSMINCOREUNITID-1:0] === matched_entry.dtw_req_pkt.smi_mpf1[WSMINCOREUNITID-1:0]) &&
                                         (item.dtw_req_pkt.smi_mpf2 === matched_entry.dtw_req_pkt.smi_mpf2) &&
                                         (item.DTR_req_recd==0));
        if(m_tmp6_q.size() == 0) `uvm_error(`LABEL_ERROR, "No rtt entry found")
        else if(m_tmp6_q.size() > 1) `uvm_error(`LABEL_ERROR, "More than 1 rtt entry found")
        else begin
          rtt_q[m_tmp6_q[0]].sp_seen_ctrl_chnl   = 1;
          rtt_q[m_tmp6_q[0]].t_sp_seen_ctrl_chnl = $time;
          rtt_q[m_tmp6_q[0]].m_sp_ctrl_pkt       = sp_ctrl_entry;
        end
      end
      // Ordering check, confirmed with Satya that if a write comes on SP ctrl chnl,then there shouldn't
      // be any read which has come before this write for same address and yet to arrive on SP ctrl chnl
      // Also, only need to check coh txns with coh and non-coh to non-coh
      // #Check.DMI.Concerto.v3.0.OrderingCheckOnSPCtrlChnl
      m_tmp_q = {};
      m_tmp_q = rtt_q.find_index() with (cl_aligned((item.cache_addr)) == cl_aligned(matched_entry.cache_addr) &&
                                         item.sp_txn                 == 1                                      &&
                                         item.sp_seen_ctrl_chnl      == 0                                      &&
                                         item.isCoh                  == matched_entry.isCoh                    &&
                                         (item.isCoh ? item.MRD_req_recd_rtl: item.CMD_rsp_recd_rtl)
                                        );
      if(m_tmp_q.size() > 0) begin
        m_tmp_q[0] = find_oldest_entry_in_rtt_q(m_tmp_q);
        if(rtt_q[m_tmp_q[0]].t_creation < matched_entry.t_creation) begin
          rtt_q[m_tmp_q[0]].print_entry;
          `uvm_error(`LABEL_ERROR, $sformatf("write txn came on SP ctrl channel before,the above old read transaction"));
        end
      end
    end
    matched_entry.sp_seen_ctrl_chnl = 1;
    matched_entry.t_sp_seen_ctrl_chnl = $time;
    burst_length = calBurstLength(matched_entry);
    // CONC-4511, full cacheline needs to be written/read in below case
    if((isWeirdWrap(matched_entry) & isdtwmrgmrd(matched_entry.dtw_msg_type)) ||(matched_entry.isMW & !matched_entry.dtw_req_pkt.smi_prim)) begin
      exp_burst_len = NUM_BEATS_IN_CACHELINE-1;
    end else begin
      exp_burst_len = burst_length - 1;
    end

    // #Check.DMI.Concerto.v3.0.SPCtrlBurstTypeAndLength
    // Burst type check
    /*if(sp_ctrl_entry.sp_op_burst_type != matched_entry.smi_burst) begin
        `uvm_error(`LABEL_ERROR,$sformatf("burst length type on sp ctrl channel expected: 0%0d got: 0%0d",
                                   matched_entry.smi_burst, sp_ctrl_entry.sp_op_burst_type));
    end*/
    // Burst length check
    if(sp_ctrl_entry.sp_op_burst_len != exp_burst_len) begin
      `uvm_error(`LABEL_ERROR, $sformatf("burst length mismatch on sp ctrl channel expected: 0%0d got: 0%0d",
                                   exp_burst_len, sp_ctrl_entry.sp_op_burst_len));
    end
    //will update the ref model when the data is received on SP wr data chnl
    //as it is possible that complete data has not yet received on DTW channel
    //processSPCtrlWr(matched_entry);
  end
  else if(sp_ctrl_entry.sp_op_rd_data) begin
    if(m_tmp2_q.size() == 0) begin
      //print_rtt_q(); VDEL
      //print_wtt_q(); VDEL
      `uvm_error(`LABEL_ERROR, $sformatf("no corresponding read txn found in TB,for received SP ctrl packet"));
    end
    else begin
      m_tmp2_q[0] = find_oldest_entry_in_rtt_q(m_tmp2_q);
      matched_entry = rtt_q[m_tmp2_q[0]];

      // Ordering check, confirmed with Satya that if a read comes on SP ctrl chnl,then there shouldn't
      // be any write which has come before this read on DMI for same address and yet to arrive on SP ctrl chnl
      // Also, only need to check coh txns with coh and non-coh to non-coh
      // #Check.DMI.Concerto.v3.0.OrderingCheckOnSPCtrlChnl
      m_tmp_q = {};
      m_tmp_q = wtt_q.find_index() with (cl_aligned((item.cache_addr)) == cl_aligned(matched_entry.cache_addr) &&
                                         item.sp_txn                 == 1                                      &&
                                         item.sp_seen_ctrl_chnl      == 0                                      &&
                                         item.isCoh                  == matched_entry.isCoh                    &&
                                         (item.isCoh? 1 : item.CMD_rsp_recd_rtl)
                                        );
      if (m_tmp_q.size() > 0) begin
          m_tmp_q[0] = find_oldest_entry_in_wtt_q(m_tmp_q);
          if(wtt_q[m_tmp_q[0]].t_creation < matched_entry.t_creation) begin
            if( wtt_q[m_tmp_q[0]].isCoh && 
               (wtt_q[m_tmp_q[0]].RB_req_expd  &&  wtt_q[m_tmp_q[0]].RB_req_recd ) &&
               (wtt_q[m_tmp_q[0]].RB_rsp_expd  && !wtt_q[m_tmp_q[0]].RB_rsp_recd ) &&
               (wtt_q[m_tmp_q[0]].DTW_req_expd && !wtt_q[m_tmp_q[0]].DTW_req_recd && !wtt_q[m_tmp_q[0]].DTW_rsp_recd)) begin
               `uvm_info("ProcessSPCtrl", $sformatf("Received a coherent SP read on addr:%0h with a pending RB and no DTW activity",wtt_q[m_tmp_q[0]].cache_addr),UVM_MEDIUM)
            end
            else if( !wtt_q[m_tmp_q[0]].isCoh && 
               (wtt_q[m_tmp_q[0]].RB_req_expd  &&  wtt_q[m_tmp_q[0]].RB_req_recd ) &&
               (wtt_q[m_tmp_q[0]].RB_rsp_expd  && !wtt_q[m_tmp_q[0]].RB_rsp_recd ) &&
               (wtt_q[m_tmp_q[0]].DTW_req_expd && wtt_q[m_tmp_q[0]].DTW_req_recd && !wtt_q[m_tmp_q[0]].DTW_rsp_recd)) begin
               `uvm_info("ProcessSPCtrl", $sformatf("Received a non-coherent SP read on addr:%0h with a pending RB and DTWRsp pending",wtt_q[m_tmp_q[0]].cache_addr),UVM_MEDIUM)
            end
            else begin
               wtt_q[m_tmp_q[0]].print_entry;
               `uvm_error(`LABEL_ERROR, $sformatf("read txn came on SP ctrl channel before the above old write transaction"));
            end
          end
      end

      matched_entry.sp_seen_ctrl_chnl = 1;
      if (matched_entry.isAtomic) matched_entry.sp_atomic_wr_pending = 1;
      matched_entry.t_sp_seen_ctrl_chnl = $time;
      matched_entry.m_sp_ctrl_pkt = new();
      matched_entry.m_sp_ctrl_pkt = sp_ctrl_entry;
      `uvm_info("DMI_SCB", $psprintf("DMI_UID:%0d: SP_CTRL: %s", matched_entry.txn_id, sp_ctrl_entry.sprint_pkt()), UVM_LOW)

      burst_length = calBurstLength(matched_entry);
      exp_burst_len = burst_length-1;

      // #Check.DMI.Concerto.v3.0.SPCtrlBurstTypeAndLength
      /*// Burst type check
      if (sp_ctrl_entry.sp_op_burst_type != !matched_entry.smi_burst) begin
          `uvm_error(`LABEL_ERROR,
                           $sformatf("burst length type on sp ctrl channel expected: 0%0d got: 0%0d",matched_entry.smi_burst, sp_ctrl_entry.sp_op_burst_type));
      end*/

      if(sp_ctrl_entry.sp_op_burst_len != exp_burst_len) begin
          spkt = {"For a SP read txn Got BL:0x%0d but expected BL:0x%0d"};
          `uvm_error(`LABEL_ERROR, $psprintf(spkt,sp_ctrl_entry.sp_op_burst_len, exp_burst_len))
      end

      // Read from ref model and make expected pakcet only if there is no pending writes
      m_tmp4_q = {};
      m_tmp4_q = wtt_q.find_index() with (item.sp_txn             == 1                              &&
                                          item.sp_seen_ctrl_chnl  == 1                              &&
                                          item.sp_seen_write_chnl == 0                              &&
                                          item.sp_data_bank       == sp_ctrl_entry.sp_op_data_bank  &&
                                          item.sp_index           == sp_ctrl_entry.sp_op_index_addr &&
                                          item.sp_way             == sp_ctrl_entry.sp_op_way_num
                                         );

      if (m_tmp4_q.size()==0) processSPCtrlRd(matched_entry);
    end
  end
endfunction // processSPCtrl

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// process/check the SP write channel packet
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function void dmi_scoreboard::processSPWr(ccp_sp_wr_pkt_t sp_wr_entry);
  int m_tmp1_q[$], m_tmp2_q[$], m_tmp3_q[$], m_tmp4_q[$], m_tmp_q[$];
  dmi_scb_txn matched_entry;
  time next_wr_entry_t_sp_seen_ctrl_chnl;
  `uvm_info("processSPWr", $psprintf("Got_SPWrPkt: %s",sp_wr_entry.sprint_pkt() ),UVM_MEDIUM)

  m_tmp1_q = {};
  m_tmp1_q = wtt_q.find_index() with (item.sp_txn             == 1 &&
                                      item.sp_seen_ctrl_chnl  == 1 &&
                                      item.sp_seen_write_chnl == 0 &&
                                      item.DTW_req_recd       == 1
                                     );

  if (m_tmp1_q.size() == 0) begin
      //print_wtt_q();//VDEL
      //print_rtt_q();//VDEL
      `uvm_error("processSPWr", $sformatf("no corresponding txn found in TB for received txn on sp input channel"));
  end
  else begin
    m_tmp1_q[0] = find_oldest_sp_lookup_in_wtt_q(m_tmp1_q);
    matched_entry = wtt_q[m_tmp1_q[0]];
    matched_entry.sp_seen_write_chnl = 1;
    matched_entry.t_sp_seen_wr_chnl = $time;
    matched_entry.m_sp_wr_data_pkt   = new();
    matched_entry.m_sp_wr_data_pkt   = sp_wr_entry;

    // Updating the ref model with write data
    processSPWrTxn(matched_entry);
    processSPCtrlWr(matched_entry);

    // Read from reference model for the pending read transactions to check the data on sp_output chnl
    m_tmp3_q = {};
    m_tmp3_q = wtt_q.find_index() with (item.sp_txn             == 1 &&
                                        item.sp_seen_ctrl_chnl  == 1 &&
                                        item.sp_seen_write_chnl == 0 &&
                                        item.sp_data_bank       == matched_entry.sp_data_bank &&
                                        item.sp_index           == matched_entry.sp_index     &&
                                        item.sp_way             == matched_entry.sp_way      
                                       );

    m_tmp_q = {};
    m_tmp_q = rtt_q.find_index() with (item.sp_txn              == 1                          &&
                                       item.sp_seen_ctrl_chnl   == 1                          &&
                                       item.sp_seen_output_chnl == 0                          &&
                                       item.sp_data_bank        == matched_entry.sp_data_bank &&
                                       item.sp_index            == matched_entry.sp_index     &&
                                       item.sp_way              == matched_entry.sp_way      
                                      );

    if (m_tmp3_q.size() > 0) begin
        m_tmp3_q[0] = find_oldest_sp_lookup_in_wtt_q(m_tmp3_q);
        next_wr_entry_t_sp_seen_ctrl_chnl = wtt_q[m_tmp3_q[0]].t_sp_seen_ctrl_chnl;
    end

    if (m_tmp_q.size() > 0) begin
       foreach (m_tmp_q[i]) begin
          if ((m_tmp3_q.size() > 0)) begin
             // = sign below to cover DtwMergeMrd case as the entry would have been created at the
             // same time the write appeared on SP control channel
             if ((rtt_q[m_tmp_q[i]].t_sp_seen_ctrl_chnl >= matched_entry.t_sp_seen_ctrl_chnl) &&
                 (rtt_q[m_tmp_q[i]].t_sp_seen_ctrl_chnl < next_wr_entry_t_sp_seen_ctrl_chnl)) begin
                processSPCtrlRd(rtt_q[m_tmp_q[i]]);
             end
          end else begin
             if (rtt_q[m_tmp_q[i]].t_sp_seen_ctrl_chnl >= matched_entry.t_sp_seen_ctrl_chnl) begin
                processSPCtrlRd(rtt_q[m_tmp_q[i]]);
             end
          end
       end
    end

    if (!matched_entry.isAtomic) begin
         matched_entry.wrOutstanding = 0; 
    end
    if (matched_entry.DTW_rsp_recd) begin
       if (!matched_entry.isAtomic) begin
         `uvm_info("DMI_SCB", $psprintf("DMI_UID:%0d: SP_WR: %s", matched_entry.txn_id, sp_wr_entry.sprint_pkt()), UVM_LOW)
         updateWttentry(matched_entry, m_tmp1_q[0]);
       end
       else begin
         `uvm_info("DMI_SCB", $psprintf("DMI_UID:%0d: SP_WR: %s", matched_entry.txn_id, sp_wr_entry.sprint_pkt()), UVM_LOW)
         updateRttentry(matched_entry, m_tmp2_q[0]);
       end
    end
  end
endfunction // processSPWr

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Process & Check the SP Output Channel Packet
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function void dmi_scoreboard::processSPOutput(ccp_sp_output_pkt_t sp_rd_entry);

  int m_tmp_q[$];
  string spkt;
  smi_addr_t addr;
  int no_of_bytes;
  int index;
  int burst_length;
  longint m_lower_wrapped_boundary;
  longint m_upper_wrapped_boundary;
  longint m_start_addr;
  parameter NUM_BEATS_IN_CACHELINE = ((SYS_nSysCacheline*8)/WCCPDATA);
  bit [$clog2(NUM_BEATS_IN_CACHELINE)-1:0] beat_offset=0;
  bit [$clog2(NUM_BEATS_IN_CACHELINE)-1:0] beat = 0;

  `uvm_info("processSPOutput", $psprintf("Got_SPRdRspPkt: %s",sp_rd_entry.sprint_pkt() ),UVM_MEDIUM)

  m_tmp_q = {};
  m_tmp_q = rtt_q.find_index() with (item.sp_txn              == 1 &&
                                     item.sp_seen_ctrl_chnl   == 1 &&
                                     item.sp_seen_output_chnl == 0
                                    );

  if(m_tmp_q.size() == 0) begin
    for (int i=0;i<rtt_q.size();i++) begin
        rtt_q[i].print();
    end
    `uvm_error("processSPOutput", $sformatf("No corresponding txn found in TB for rcvd txn on sp rd_rsp channel"));
  end
  else begin
    m_tmp_q[0] = find_oldest_sp_lookup_in_rtt_q(m_tmp_q);
    `uvm_info("processSPOutput",
              $psprintf("Corresponding_SPCtrlPkt: %s",rtt_q[m_tmp_q[0]].m_sp_ctrl_pkt.sprint_pkt()),UVM_MEDIUM)
    rtt_q[m_tmp_q[0]].sp_seen_output_chnl = 1;
    rtt_q[m_tmp_q[0]].t_sp_seen_rd_chnl   = $time;
    rtt_q[m_tmp_q[0]].error_expected      = new[NUM_BEATS_IN_CACHELINE];
    rtt_q[m_tmp_q[0]].m_sp_rd_data_pkt    = new();
    rtt_q[m_tmp_q[0]].m_sp_rd_data_pkt    = sp_rd_entry;

    if (rtt_q[m_tmp_q[0]].isDtwMrgMrd) begin
        burst_length         = NUM_BEATS_IN_CACHELINE;
    end else begin
        burst_length         = calBurstLength(rtt_q[m_tmp_q[0]]);
    end

    if(sp_rd_entry.data.size()>0) begin
      if(sp_rd_entry.data.size() != burst_length) begin
        `uvm_error("processSPOutput", $sformatf("Mismatch between received read data size on sp rd_rsp channel, expected: 0%0d got: 0%0d",
                                                    burst_length, sp_rd_entry.data.size()));
      end 
      else begin
        no_of_bytes              = (WCCPDATA/8);
        addr                     = rtt_q[m_tmp_q[0]].cache_addr;
        beat_offset              = addr[LINE_INDEX_H : LINE_INDEX_L];
        m_start_addr             = (addr/(no_of_bytes)) * (no_of_bytes);
        m_lower_wrapped_boundary = (addr/(no_of_bytes * burst_length)) * (no_of_bytes*burst_length);
        m_upper_wrapped_boundary = m_lower_wrapped_boundary + (no_of_bytes * burst_length);

        for(int i=0; i < burst_length; i++) begin
          if((rtt_q[m_tmp_q[0]].smi_burst == 'h0) && (m_start_addr >= m_upper_wrapped_boundary)) begin
            beat_offset  = m_lower_wrapped_boundary[LINE_INDEX_H:LINE_INDEX_L];
            m_start_addr = m_lower_wrapped_boundary;
          end
          else begin
            m_start_addr = m_start_addr + no_of_bytes;
          end
          // #Check.DMI.Concerto.v3.0.SPRdInterfaceSignals
          if((rtt_q[m_tmp_q[0]].sp_read_data_pkt.data[i] != sp_rd_entry.data[i]) &&
             !sp_rd_entry.poison[i]) begin
             `uvm_error("processSPOutput", $sformatf("Mismatch in received read data on sp rd_rsp channel expected: 0%0h got: 0%0h",
                                                         rtt_q[m_tmp_q[0]].sp_read_data_pkt.data[i], sp_rd_entry.data[i]));
          end

          if(rtt_q[m_tmp_q[0]].sp_read_data_pkt.poison[i] != sp_rd_entry.poison[i]) begin
            if(uncorr_data_err) begin
              `uvm_info("processSPOutput",$sformatf("Exp Poison :%0p Got Poison:%0p Error#:%0d",rtt_q[m_tmp_q[0]].sp_read_data_pkt.poison, sp_rd_entry.poison,i),UVM_NONE)
              `uvm_info("processSPOutput",$sformatf("message type : %0s, writeThrough : %0h",smi_type_string(rtt_q[m_tmp_q[0]].smi_msg_type), rtt_q[m_tmp_q[0]].sp_write_through),UVM_NONE)
              `uvm_error("processSPOutput","Poison field mismatch between SP read response vs SP model due to uncorrectable error")
            end
            else begin
              rtt_q[m_tmp_q[0]].print_entry();
              `uvm_info("processSPOutput",$sformatf("Exp Poison : %0p Got Poison:%0p Error#:%0d",rtt_q[m_tmp_q[0]].sp_read_data_pkt.poison, sp_rd_entry.poison,i),UVM_NONE)
              `uvm_info("processSPOutput",$sformatf("message type : %0s, writeThrough : %0h",smi_type_string(rtt_q[m_tmp_q[0]].smi_msg_type), rtt_q[m_tmp_q[0]].sp_write_through),UVM_NONE)
              `uvm_error("processSPOutput","Poison field mismatch between SP read response vs SP model")
            end
          end
          if (sp_rd_entry.poison[i]) begin
            for(int j=0; j < WXDATA/64; j++) begin
              if((i+1)*j < burst_length*2) begin //Burst length is in bytes, poison is assigned per nibble.
                rtt_q[m_tmp_q[0]].error_expected[i][j*WSMIDPDBADPERDW+:WSMIDPDBADPERDW] = sp_rd_entry.poison[i];
              end
              `uvm_info("processSPOutput",$sformatf("::poison_sizing:: burst_length:%0d beat_offset:%0d [i,j:%0d,%0d] | error_expected:%0h", burst_length, beat_offset,i,j,rtt_q[m_tmp_q[0]].error_expected[i]),UVM_DEBUG)
            end
          end

          if (sp_rd_entry.poison[i]) rtt_q[m_tmp_q[0]].error_expected[beat_offset] = '1;
          beat_offset = beat_offset + 1'b1;
        end
      end
    end 
    else begin
      `uvm_error("processSPOutput", $sformatf("No data received from monitor corresponding to sp rd_rsp transaction"));
    end

    // Run atomic operations on the read data and see if the fill (write back) is required
    if(rtt_q[m_tmp_q[0]].smi_msg_type inside {CMD_RD_ATM,CMD_CMP_ATM,CMD_SW_ATM,CMD_WR_ATM} && rtt_q[m_tmp_q[0]].DTW_req_recd && rtt_q[m_tmp_q[0]].smi_dp_last) begin
      process_atomic_op(rtt_q[m_tmp_q[0]],m_tmp_q[0]);
      // following code has been shifted to process_atomic_op function
      //if (rtt_q[m_tmp_q[0]].fillDataExpd) begin
      //    processSPCtrlWr(rtt_q[m_tmp_q[0]]);
      //end else begin
      //    rtt_q[m_tmp_q[0]].sp_atomic_wr_pending = 0;
      //end
    end

    // checking the DTR data if it has been seen on the DTR channel,
    // if not then this data will be checked on DTR channel
    // #Check.DMI.Concerto.v3.0.DTRDataByteEnPoison
    if(rtt_q[m_tmp_q[0]].DTR_req_recd) begin
      int burst_length_no_padding = -1;
      no_of_bytes              = (WCCPDATA/8);
      if(rtt_q[m_tmp_q[0]].isDtwMrgMrd) begin
        burst_length         = NUM_BEATS_IN_CACHELINE;
      end
      else begin
        //Account for data padding
        //if(rtt_q[m_tmp_q[0]].smi_msg_type == CMD_CMP_ATM) begin
        if(rtt_q[m_tmp_q[0]].isAtomic) begin
          burst_length_no_padding = calBurstLength(rtt_q[m_tmp_q[0]]);
          burst_length =  ((2**rtt_q[m_tmp_q[0]].smi_intfsize)/(WCCPDATA/64));
        end
        else begin
          burst_length = ((2**rtt_q[m_tmp_q[0]].smi_size)*8)/WCCPDATA;
        end
        if(burst_length==0) burst_length = 1;
      end
      addr                     = rtt_q[m_tmp_q[0]].cache_addr;
      beat_offset              = addr[LINE_INDEX_H : LINE_INDEX_L];
      m_start_addr             = (addr/(no_of_bytes)) * (no_of_bytes);
      m_lower_wrapped_boundary = (addr/(no_of_bytes * burst_length)) * (no_of_bytes*burst_length);
      m_upper_wrapped_boundary = m_lower_wrapped_boundary + (no_of_bytes * burst_length);

      if(rtt_q[m_tmp_q[0]].dtr_req_pkt.smi_dp_data.size() != burst_length) begin
         rtt_q[m_tmp_q[0]].print();
         `uvm_error("processSPOutput", $sformatf("Mismatch in burst length and the data pkts coming out| Exp data pkts:%0d; Received data pkts :%0d (MsgType:%0h)", 
                                             burst_length, rtt_q[m_tmp_q[0]].dtr_req_pkt.smi_dp_data.size(), rtt_q[m_tmp_q[0]].smi_msg_type));
      end

      for(int i=0; i < burst_length; i++) begin
        if((rtt_q[m_tmp_q[0]].smi_burst == 'h0) && (m_start_addr >= m_upper_wrapped_boundary)) begin
          beat_offset  = m_lower_wrapped_boundary[LINE_INDEX_H:LINE_INDEX_L];
          m_start_addr = m_lower_wrapped_boundary;
        end
        else begin
          m_start_addr = m_start_addr + no_of_bytes;
        end

        //#Check.DMI.Concerto.v3.0.DTRDataByteEnPoison
        if(rtt_q[m_tmp_q[0]].error_expected[i] !==
          rtt_q[m_tmp_q[0]].dtr_req_pkt.smi_dp_dbad[i]) begin
          if( (burst_length_no_padding != -1) && (i < burst_length_no_padding)) begin
            //Padded data has BE always set to 0. This qualification on data check isn't necessary.
            rtt_q[m_tmp_q[0]].print_entry();
            `uvm_error("processSPOutput", $sformatf("Mismatch in rresp coming out for a SP txn | Exp resp :%0h; Received resp :%0h; beat :%0d offset:%0d",
                                                   rtt_q[m_tmp_q[0]].error_expected[i],rtt_q[m_tmp_q[0]].dtr_req_pkt.smi_dp_dbad[i], i, beat_offset));
          end
        end

        // Not checking the read data if it has been poisoned
        if(rtt_q[m_tmp_q[0]].dtr_req_pkt.smi_dp_dbad[i] == 'h0) begin
          if(rtt_q[m_tmp_q[0]].sp_read_data_pkt.data[i] !=
            rtt_q[m_tmp_q[0]].dtr_req_pkt.smi_dp_data[i]) begin
            if(!(rtt_q[m_tmp_q[0]].smi_msg_type inside {CMD_RD_ATM,CMD_CMP_ATM,CMD_SW_ATM,CMD_WR_ATM})) begin   //requested bytes should be correct. Other bytes can be junk. Check done in dmi_states
                `uvm_error("processSPOutput", $sformatf("Mismatch in DTR data coming out for SP txn | Exp data :%0h; Received data :%0h; beat :%0d",
                                                     rtt_q[m_tmp_q[0]].sp_read_data_pkt.data[i],
                                                     rtt_q[m_tmp_q[0]].dtr_req_pkt.smi_dp_data[i], i));
            end
          end
          // disabled as per CONC-5411
          // if(&rtt_q[m_tmp_q[0]].dtr_req_pkt.smi_dp_be[i] !== 1) begin
          //      `uvm_error("processSPOutput", $sformatf("Mismatch in DTR byte enables coming out for SP txn; ",
          //                                               "Exp :%0h; Received :%0h; beat :%0d",
          //                                               '1, rtt_q[m_tmp_q[0]].dtr_req_pkt.smi_dp_be[i], i));
          // end
        end
        beat_offset = beat_offset + 1'b1;
      end
    end
    `uvm_info("DMI_SCB", $psprintf("DMI_UID:%0d: SP_OUTPUT: %s", rtt_q[m_tmp_q[0]].txn_id,sp_rd_entry.sprint_pkt()), UVM_LOW)
    updateRttentry(rtt_q[m_tmp_q[0]], m_tmp_q[0]);
   end
endfunction // processSPOutput///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

function void dmi_scoreboard::processSPCtrlWr(dmi_scb_txn matched_entry);
  int burst_length, merge;
  ccp_sp_wr_pkt_t wr_packet;
  int num_of_beats  = (SYS_nSysCacheline*8)/WCCPDATA;
  int num_of_bytes  = (WCCPDATA/8);
  int index         = matched_entry.sp_addr >> SYS_wSysCacheline;

  `uvm_info("processSPCtrlWr",$sformatf("Processing sp_addr:0x%0h sp_index:%0h cache_addr:0x%0h burst_length:%0d", matched_entry.sp_addr, index, matched_entry.cache_addr, burst_length),UVM_DEBUG)
  //Every data update is either an atomic using the cache fill interface or a write using the SP write interface
  if(!matched_entry.isAtomic) begin
    foreach(matched_entry.m_sp_wr_data_pkt.data[i]) begin
      burst_length+=1;
    end
    wr_packet = new();
    wr_packet.beatn  = new[burst_length];
    wr_packet.byten  = new[burst_length];
    wr_packet.data   = new[burst_length];
    wr_packet.poison = new[burst_length];
    for(int i=0; i < burst_length; i++) begin
      wr_packet.beatn[i] = matched_entry.m_sp_wr_data_pkt.beatn[i];
      wr_packet.byten[i] = matched_entry.m_sp_wr_data_pkt.byten[i];
      wr_packet.data[i]  = matched_entry.m_sp_wr_data_pkt.data[i];
      wr_packet.poison[i]= matched_entry.m_sp_wr_data_pkt.poison[i];
    end
  end
  else begin
    ccp_filldata_pkt_t fill_data;
    if(matched_entry.fillDataExpd) begin
      fill_data = matched_entry.cache_fill_data_pkt_exp;
    end
    else if(matched_entry.fillDataSeen && matched_entry.sp_seen_ctrl_chnl && !matched_entry.sp_seen_output_chnl) begin
      //Typically SP atomic reads are committed to the model when atomics are processed after SP output channel event
      `uvm_info("processSPCtrlWr",$sformatf("To avoid reading incorrect data before sp_seen_output_chnl is set, updating the SP model with the fill data received | sp_addr:%0x",matched_entry.sp_addr),UVM_HIGH)
      fill_data = matched_entry.cache_fill_data_pkt;
    end
    foreach(fill_data.data[i]) begin
      burst_length+=1;
    end
    wr_packet = new();
    wr_packet.beatn  = new[burst_length];
    wr_packet.byten  = new[burst_length];
    wr_packet.data   = new[burst_length];
    wr_packet.poison = new[burst_length];
    for(int i=0; i < burst_length; i++) begin
      wr_packet.beatn[i] = fill_data.beatn[i] ;
      wr_packet.byten[i] = fill_data.byten[i] ;
      wr_packet.data[i] =  fill_data.data[i];
      wr_packet.poison[i]= fill_data.poison[i];
    end
  end
  `uvm_info("DMI_SCB", $psprintf("DMI_UID:%0d: SP_CTRL_WR: %s", matched_entry.txn_id, wr_packet.sprint_pkt()), UVM_LOW);

  <%if ((obj.DmiInfo[obj.Id].ccpParams.nBeatsPerBank == 2) & (obj.DmiInfo[obj.Id].ccpParams.wData == 256)){ %>
  if (burst_length == 1) begin //1 beat writes are always RMW
    //1RMW
    merge[0] =1;
  end else if (wr_packet.beatn[0]%2 == 0) begin
    //1W
    merge[0] = ! (&wr_packet.byten[0] & (&wr_packet.byten[1]));
    merge[1] = ! (&wr_packet.byten[0] & (&wr_packet.byten[1]));
  end else begin
    //2RMW
    merge[0] = 1;
    merge[1] = 1;
  end
  <% } %>
  <%if ((obj.DmiInfo[obj.Id].ccpParams.nBeatsPerBank == 2) & (obj.DmiInfo[obj.Id].ccpParams.wData == 128)){ %>
  if (burst_length == 1) begin //1 beat writes are always RMW //TODO VIK: add a coverpoint for merge scenarios
    //1RMW
    merge[0] =1;
  end else if (burst_length == 2) begin
    if (wr_packet.beatn[0]%2 == 0) begin
    //1W
      merge[0] = ! (&wr_packet.byten[0] & (&wr_packet.byten[1]));
      merge[1] = ! (&wr_packet.byten[0] & (&wr_packet.byten[1]));
    end else begin
    //2RMW
      merge[0] = 1;
      merge[1] = 1;
    end
  end else if (burst_length == 3) begin
    if (wr_packet.beatn[0]%2 == 0) begin
    //1W-1RMW
      merge[0] = ! (&wr_packet.byten[0] & (&wr_packet.byten[1]));
      merge[1] = ! (&wr_packet.byten[0] & (&wr_packet.byten[1]));
      merge[2] = 1;
    end else begin
    //1RMW-1W
      merge[0] = 1;
      merge[1] = ! (&wr_packet.byten[1] & (&wr_packet.byten[2]));
      merge[2] = ! (&wr_packet.byten[1] & (&wr_packet.byten[2]));
    end
  end else begin
    if (wr_packet.beatn[0]%2 == 0) begin
    //2W
      merge[0] = ! (&wr_packet.byten[0] & (&wr_packet.byten[1]));
      merge[1] = ! (&wr_packet.byten[0] & (&wr_packet.byten[1]));
      merge[2] = ! (&wr_packet.byten[2] & (&wr_packet.byten[3]));
      merge[3] = ! (&wr_packet.byten[2] & (&wr_packet.byten[3]));
    end else begin
    //1RMW-1W-1RMW
      merge[0] = ! (matched_entry.dtw_req_pkt.smi_msg_type == DTW_DATA_CLN || matched_entry.dtw_req_pkt.smi_msg_type == DTW_DATA_DTY);
      merge[1] = ! (&wr_packet.byten[1] & (&wr_packet.byten[2]));
      merge[2] = ! (&wr_packet.byten[1] & (&wr_packet.byten[2]));
      merge[3] = 1;
    end
  end
  `uvm_info("processSPCtrlWr",$sformatf("::DEBUG::: burst_length:%0d byten:%0p beatn:%0p merge:%0h data:%0p poison:%0p",burst_length, wr_packet.byten, wr_packet.beatn, merge, wr_packet.data, wr_packet.poison),UVM_DEBUG)
  <% } %>

  for(int i=0; i < burst_length; i++) begin
    for(int index_bit=0; index_bit < num_of_bytes; index_bit++) begin
      if(wr_packet.byten[i][index_bit] == 1'b1) begin
        m_dmi_sp_q[index].data[wr_packet.beatn[i]][(8*index_bit) +: 8] = wr_packet.data[i][(8*index_bit) +: 8];
      end
    end
    <%if (obj.DmiInfo[obj.Id].ccpParams.nBeatsPerBank == 1){ %>
    //Do not merge if all byte enables are set
    m_dmi_sp_q[index].poison[wr_packet.beatn[i]] = ( (& wr_packet.byten[i]) ? 0 : m_dmi_sp_q[index].poison[wr_packet.beatn[i]] ) | wr_packet.poison[i];
    <% } else { %>
    //Do not merge if all byte enable are set and is a full write, merge otherwise wr_packet.beatn[i]-(wr_packet.beatn[i]%2)*2+1 takes {0,1,2,3} into {1,0,3,2}
    //Need to merge with  beat 0 and 1  or 2 and 3 from the model depending on beatn
    `uvm_info("processSPCtrlWr",$sformatf("::DEBUG::: Before processing the following write to scratchpad i: %0d, wr_packet.beatn[i] : %0h, m_dmi_sp_q[index].poison[wr_packet.beatn[i]]: %0h",i,wr_packet.beatn[i],m_dmi_sp_q[index].poison[wr_packet.beatn[i]]),UVM_DEBUG)
    m_dmi_sp_q[index].poison[wr_packet.beatn[i]] = (!(merge[i]) ? 0 : m_dmi_sp_q[index].poison[wr_packet.beatn[i]] | m_dmi_sp_q[index].poison[wr_packet.beatn[i]-(wr_packet.beatn[i]%2)*2+1] ) | 
                                                                      wr_packet.poison[i];
    `uvm_info("processSPCtrlWr",$sformatf("::DEBUG::: Processing the following write to scratchpad i: %0d, merge[i]: %0h,wr_packet.beatn[i]: %0h,wr_packet.beatn[i]-(wr_packet.beatn[i]/2)*2+1 : %0h, m_dmi_sp_q[index].poison[wr_packet.beatn[i]]: %0h",i, merge[i],wr_packet.beatn[i],wr_packet.beatn[i]-(wr_packet.beatn[i]%2)*2+1, m_dmi_sp_q[index].poison[wr_packet.beatn[i]]),UVM_DEBUG)
    <% } %>
  end
  spad_index_occupancy[index] = 1;
  <%if (obj.DmiInfo[obj.Id].ccpParams.nBeatsPerBank == 2){ %>
  //Merging packed poison for multicycle if not a write through, the write thorugh case will be done after the read function.
  if(!matched_entry.sp_write_through | matched_entry.isAtomic) begin
    for(int i=0; i < num_of_beats-1; i=i+2) begin
      m_dmi_sp_q[index].poison[i] |= m_dmi_sp_q[index].poison[i+1];
      m_dmi_sp_q[index].poison[i+1] =m_dmi_sp_q[index].poison[i]; 
    end
  end 

  //Merge everything that is not the first beat, because they are either the second RMW or the first/second beat of a W. Only first beat resets the expectation, the second beat always is merged with result from the first
  //Two beats from a W will always have the same poison
  //The second RMW will always see the result of the first RMW.
  //The read residue of a RMW will always see the result of the RMW.
  //For the case with 2 RMW, the remaining portion that is read will always have the same results and also needs updating before the read.

  `uvm_info("processSPCtrlWr",$sformatf("Processing sp_addr:0x%0h sp_index:%0h cache_addr:0x%0h burst_length:%0d", matched_entry.sp_addr, index, matched_entry.cache_addr, burst_length),UVM_DEBUG)
  `uvm_info("processSPCtrlWr",$sformatf("::DEBUG::: matched_entry.smi_msg_type: %0s, matched_entry.sp_write_through: %0h",smi_type_string(matched_entry.smi_msg_type),matched_entry.sp_write_through),UVM_DEBUG)

  if(matched_entry.sp_write_through) begin
    for(int i=0; i < num_of_beats; i=i+1) begin
      if (!(i==wr_packet.beatn[0]) | (wr_packet.beatn[0]%2 == 0) ) begin
        m_dmi_sp_q[index].poison[i] |= m_dmi_sp_q[index].poison[i-(i%2)*2+1];
        `uvm_info("processSPCtrlWr",$sformatf("::DEBUG::: Merging entries that need to be merged before the read for write through i: %0h, m_dmi_sp_q[index].poison[i]: %0h,m_dmi_sp_q[index].poison[i-(i/2)*2+1]: %0h",i,m_dmi_sp_q[index].poison[i],m_dmi_sp_q[index].poison[i-(i%2)*2+1]),UVM_DEBUG)
      end 
    end
  end 
  <% } %>
endfunction////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

function void dmi_scoreboard::processSPCtrlRd(dmi_scb_txn matched_entry);
  smi_addr_t addr;
  int        no_of_bytes;
  int        index;
  int        burst_length;
  longint    m_lower_wrapped_boundary;
  longint    m_upper_wrapped_boundary;
  longint    m_start_addr;
  parameter  NUM_BEATS_IN_CACHELINE = ((SYS_nSysCacheline*8)/WCCPDATA);
  bit [$clog2(NUM_BEATS_IN_CACHELINE)-1:0] beat_offset=0;
  bit poisoned_line;
  bit [NUM_BEATS_IN_CACHELINE-1:0] packed_poison;
  no_of_bytes              = (WCCPDATA/8);
  if (matched_entry.isDtwMrgMrd) begin
      burst_length         = NUM_BEATS_IN_CACHELINE;
  end else begin
      burst_length         = calBurstLength(matched_entry);
  end
  addr                     = matched_entry.cache_addr;
  beat_offset              = addr[LINE_INDEX_H : LINE_INDEX_L];
  m_start_addr             = (addr/(no_of_bytes)) * (no_of_bytes);
  m_lower_wrapped_boundary = (addr/(no_of_bytes * burst_length)) * (no_of_bytes*burst_length);
  m_upper_wrapped_boundary = m_lower_wrapped_boundary + (no_of_bytes * burst_length);
  index                    = matched_entry.sp_addr >> SYS_wSysCacheline;

  `uvm_info("processSPCtrlRd",$sformatf("Processing sp_addr:0x%0h sp_index:%0h cache_addr:0x%0h burst_length:%0d", matched_entry.sp_addr, index, matched_entry.cache_addr, burst_length),UVM_DEBUG)
  `uvm_info("processSPCtrlRd",$sformatf("beat_offset:0x%0h start_addr:0x%0h Lower:0x%0h Upper:0x%0h", beat_offset, m_start_addr, m_lower_wrapped_boundary,m_upper_wrapped_boundary),UVM_DEBUG)
  // For end-to-end SP read data checking
  matched_entry.sp_read_data_pkt = new();
  for(int i=0; i < burst_length; i++) begin
    if((matched_entry.smi_burst == 'h0) && (m_start_addr >= m_upper_wrapped_boundary)) begin
      beat_offset  = m_lower_wrapped_boundary[LINE_INDEX_H : LINE_INDEX_L];
      m_start_addr = m_lower_wrapped_boundary;
    end
    else begin
      m_start_addr = m_start_addr + no_of_bytes;
    end
    matched_entry.sp_read_data_pkt.data[i]   = m_dmi_sp_q[index].data[beat_offset];
    matched_entry.sp_read_data_pkt.poison[i] = m_dmi_sp_q[index].poison[beat_offset];
    beat_offset = beat_offset + 1'b1;
  end
  
  <%if (obj.DmiInfo[obj.Id].ccpParams.nBeatsPerBank == 2){ %>
  //Merging packed poison for multicycle after the read for a write thorugh 
  for(int i=0; i < NUM_BEATS_IN_CACHELINE-1; i=i+2) begin
    m_dmi_sp_q[index].poison[i] |= m_dmi_sp_q[index].poison[i+1];
    m_dmi_sp_q[index].poison[i+1] =m_dmi_sp_q[index].poison[i]; 
  end
  <% } %>
  `uvm_info("DMI_SCB", $psprintf("DMI_UID:%0d: SP_CTRL_RD: %s", matched_entry.txn_id, matched_entry.sp_read_data_pkt.print()), UVM_LOW)
endfunction///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

function void dmi_scoreboard::processSPWrTxn(dmi_scb_txn matched_entry);
  ccp_sp_wr_pkt_t sp_wr_entry;
  ccp_sp_wr_pkt_t exp_sp_wr_entry;

  smi_addr_t addr;
  int        no_of_bytes;
  int        index;
  int        burst_length;
  int        exp_data_beats;
  int        pseudo_beat_count=0;
  longint    m_lower_wrapped_boundary;
  longint    m_upper_wrapped_boundary;
  longint    m_start_addr;
  parameter  NUM_BEATS_IN_CACHELINE = ((SYS_nSysCacheline*8)/WCCPDATA);
  bit [$clog2(NUM_BEATS_IN_CACHELINE)-1:0] beat_offset=0;

  no_of_bytes              = (WCCPDATA/8);
  burst_length             = calBurstLength(matched_entry);
  addr                     = matched_entry.cache_addr;
  beat_offset              = addr[LINE_INDEX_H : LINE_INDEX_L];
  m_start_addr             = (addr/(no_of_bytes)) * (no_of_bytes);
  m_lower_wrapped_boundary = (addr/(no_of_bytes * burst_length)) * (no_of_bytes*burst_length);
  m_upper_wrapped_boundary = m_lower_wrapped_boundary + (no_of_bytes * burst_length);
  sp_wr_entry              = matched_entry.m_sp_wr_data_pkt;
  `uvm_info("processSPWrTxn", $sformatf("addr %0h start_addr %0h lower %0h upper %0h",
                               addr, m_start_addr, m_lower_wrapped_boundary, m_upper_wrapped_boundary), UVM_HIGH)

  if (isWeirdWrap(matched_entry) & matched_entry.isDtwMrgMrd) begin
      exp_data_beats = NUM_BEATS_IN_CACHELINE;
  end else begin
      exp_data_beats = calBurstLength(matched_entry);
  end
  if(sp_wr_entry.data.size()>0) begin
    if(sp_wr_entry.data.size() != exp_data_beats) begin
      `uvm_error("processSPWrTxn", $sformatf("Mismatch in received data beats on sp write data channel, expected: 0%0d got: 0%0d",
                                         exp_data_beats, sp_wr_entry.data.size()));
    end
    else begin
      exp_sp_wr_entry       = new();
      exp_sp_wr_entry.beatn = new[sp_wr_entry.data.size()];
      exp_sp_wr_entry.byten = new[sp_wr_entry.data.size()];
      exp_sp_wr_entry.data  = new[sp_wr_entry.data.size()];
      exp_sp_wr_entry.poison= new[sp_wr_entry.data.size()];

      /*CONC-4511: If the burst length is 2 beats for a DTWMergeMrd, then there are 2 cases:
       1. If the 2 write beats don't require a wrap, then the scratch_op burst length is set to 1, 2 beats go in for a write,
         and full cacheline comes out for the read.
       2. If the 2 write beats require a wrap, then the scratch_op burst length is set to 3, 4 beats go in for the write
          (using blanks when there is no write data), and full cacheline comes out for the read.*/
      if(!(isWeirdWrap(matched_entry) & matched_entry.isDtwMrgMrd)) begin
        for(int i=0; i < exp_data_beats; i++) begin
          if((matched_entry.smi_burst == 'h0) && (m_start_addr >= m_upper_wrapped_boundary)) begin
            beat_offset  = m_lower_wrapped_boundary[LINE_INDEX_H:LINE_INDEX_L];
            m_start_addr = m_lower_wrapped_boundary;
          end 
          else begin
            m_start_addr = m_start_addr + no_of_bytes;
          end
          exp_sp_wr_entry.byten[i] = matched_entry.dtw_req_pkt.smi_dp_be[i];
          exp_sp_wr_entry.data[i]  = matched_entry.dtw_req_pkt.smi_dp_data[i];
          exp_sp_wr_entry.beatn[i] = beat_offset;
          exp_sp_wr_entry.poison[i] = (matched_entry.dtw_req_pkt.smi_dp_dbad[i] !==0) ? 1 : 0;
          if(beat_offset == NUM_BEATS_IN_CACHELINE) beat_offset = 0;
          else beat_offset++;
        end
      end
      else begin
        for (int i=0; i < burst_length; i++) begin
           if((matched_entry.smi_burst == 'h0) && (m_start_addr >= m_upper_wrapped_boundary)) begin
             for(int j=i; j < (NUM_BEATS_IN_CACHELINE-burst_length+i); j++) begin
               exp_sp_wr_entry.byten[j] = 'b0;
               exp_sp_wr_entry.beatn[j] = beat_offset;
               if(beat_offset == NUM_BEATS_IN_CACHELINE) beat_offset = 0;
               else beat_offset++;
               pseudo_beat_count = j+1;
             end
             beat_offset  = m_lower_wrapped_boundary[LINE_INDEX_H:LINE_INDEX_L];
             m_start_addr = m_lower_wrapped_boundary;
           end else begin
               m_start_addr = m_start_addr + no_of_bytes;
           end
           exp_sp_wr_entry.byten[pseudo_beat_count] = matched_entry.dtw_req_pkt.smi_dp_be[i];
           exp_sp_wr_entry.data[pseudo_beat_count]  = matched_entry.dtw_req_pkt.smi_dp_data[i];
           exp_sp_wr_entry.poison[pseudo_beat_count] = (matched_entry.dtw_req_pkt.smi_dp_dbad[i] !==0) ? 1 : 0;
           exp_sp_wr_entry.beatn[pseudo_beat_count] = beat_offset;
           if(beat_offset == NUM_BEATS_IN_CACHELINE) beat_offset = 0;
           else beat_offset++;
           pseudo_beat_count++;
         end
       end
       `uvm_info("processSPWrTxn", $psprintf("Exp_SPWrPkt: %s",exp_sp_wr_entry.sprint_pkt() ),UVM_MEDIUM)

       // #Check.DMI.Concerto.v3.0.SPWrInterfaceSignals
       foreach (sp_wr_entry.poison[i]) begin
         if((exp_sp_wr_entry.poison[i] !== sp_wr_entry.poison[i]) && (sp_wr_entry.byten[i] != 'b0)) begin
           spkt = {"Incorrect SP write-hit poison bit. Poison bit shouldn't be asserted for a write-hit txn, Got Poison:0x%0x but Exp Poison:0x%0x"};
           `uvm_error("processSPWrTxn",$psprintf(spkt,sp_wr_entry.poison[i],exp_sp_wr_entry.poison[i]))
         end
       end

       for (int i=0; i < sp_wr_entry.data.size(); i++) begin
         if(exp_sp_wr_entry.beatn[i] != sp_wr_entry.beatn[i]) begin
           `uvm_error("processSPWrTxn", $sformatf("Mismatch in received beat order on sp wrdata channel, expected: 0%0d got: 0%0d",
                                                       exp_sp_wr_entry.beatn[i],
                                                       sp_wr_entry.beatn[i]));
         end

         if (exp_sp_wr_entry.byten[i] != sp_wr_entry.byten[i]) begin
             `uvm_error("processSPWrTxn", $sformatf("Mismatch in received be on sp wrdata channel, expected: 0%0h got: 0%0h",
                                                        exp_sp_wr_entry.byten[i],
                                                        sp_wr_entry.byten[i]));
         end

         // Only checking the data if the byte enables are not all zeroes
         if ((exp_sp_wr_entry.data[i] != sp_wr_entry.data[i]) && (sp_wr_entry.byten[i] != 'b0)) begin
             `uvm_error("processSPWrTxn", $sformatf("Mismatch in received data on sp wrdata channel, expected: 0%0h got: 0%0h",
                                                        exp_sp_wr_entry.data[i],
                                                        sp_wr_entry.data[i]));
         end
         beat_offset = beat_offset + 1;
       end
    end
  end
  else begin
    `uvm_error("processSPWrTxn", $sformatf("no data received from monitor for sp wr txn"));
  end
endfunction//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
task dmi_scoreboard::create_SP_q();
  upper_sp_addr = lower_sp_addr + (N_CCP_SETS*sp_ways)-1;
  spad_index_occupancy = new[(N_CCP_SETS*sp_ways)];
  ->check_spad_occupancy; 
  for (int i=0; i < (N_CCP_SETS*sp_ways); i++) begin
      ccpSPLine m_pkt = new();
      m_dmi_sp_q.push_back(m_pkt);
  end
endtask//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
<% } %> 
//-------------------------------------------End Scratchpad-------------------------------------------------------------------------

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Re-arrange Dtw data as per DwId | Eventually data rearragement is checked when there is a AXI write or cache write
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function void  dmi_scoreboard::rearrangedtwdata(ref dmi_scb_txn scb_txn);
   // #Check.DMI.Concerto.v3.0.DtwReqDwid
   bit [63:0]  tmp_dp_data   [8];
   bit [7:0]   tmp_dp_be     [8];
   bit         tmp_dp_dbad   [8];
   bit [$clog2(NUM_BEATS_IN_DTR)-1:0]    beat_idx;
   bit [2:0]    critical_dwid;
   int          dwid_l,dwid_h,dwid;
   int          total_beats,no_of_bytes_per_beat,dtw_req_bytes,req_data_size,min_dwid_bytes;
   int          burst_length;
   int          req_total_beats;
   int          max_dwid;
   int          aiu_intfsize;
   smi_addr_t  critical_smi_addr,tmp_smi_addr;

   smi_seq_item dp_pkt = new();

   total_beats                    = scb_txn.dtw_req_pkt.smi_dp_data.size(); 
   no_of_bytes_per_beat           = (WDPDATA/8);

   if(scb_txn.dtw_req_pkt.smi_prim)begin
     if(scb_txn.isAtomic || scb_txn.isNcWr)begin
       dtw_req_bytes                = (2**(scb_txn.cmd_req_pkt.smi_size)); 
       req_data_size                = scb_txn.cmd_req_pkt.smi_size;
     end
     else begin
       dtw_req_bytes                = (2**(scb_txn.rb_req_pkt.smi_size)); 
       req_data_size                = scb_txn.rb_req_pkt.smi_size;
     end
   end
   else begin
     dtw_req_bytes               = total_beats*no_of_bytes_per_beat; 
     scb_txn.smi_size            = 6; 
   end

   if(dtw_req_bytes%no_of_bytes_per_beat > 0)begin
     burst_length               = (dtw_req_bytes/no_of_bytes_per_beat)+1;
   end 
   else begin
     burst_length               = dtw_req_bytes/no_of_bytes_per_beat;
   end

   if(k_intfsize >2)begin
     aiu_intfsize = allowedIntfSize[scb_txn.dtw_req_pkt.smi_src_ncore_unit_id];    
     <% if (obj.testBench == "dmi") { %>
     if(scb_txn.smi_msg_type == CMD_CMP_ATM) begin //Maintaining legal interface size commitment for atomic compares to accommodate accurate data padding checks
       aiu_intfsize = allowedIntfSizeActual[scb_txn.dtw_req_pkt.smi_src_ncore_unit_id];
     end
     <%}%>
     `uvm_info("rearrangedtwdata:0",$sformatf("aiu_intfsize :%0d k_intfsize :%0d src_unit_id:%0d",aiu_intfsize,k_intfsize,scb_txn.dtw_req_pkt.smi_src_ncore_unit_id),UVM_MEDIUM);
   end
   else begin
     aiu_intfsize = k_intfsize;
     `uvm_info("rearrangedtwdata:1",$sformatf("aiu_intfsize :%0d k_intfsize :%0d src_unit_id:%0d",aiu_intfsize,k_intfsize,scb_txn.dtw_req_pkt.smi_src_ncore_unit_id),UVM_MEDIUM);
   end

   if($clog2(WDPDATA/64) > aiu_intfsize)begin
     if(dtw_req_bytes <=  (2**aiu_intfsize)*8)begin
       max_dwid = 2**aiu_intfsize;
     end
     else if(dtw_req_bytes < WDPDATA/8) begin
       max_dwid = dtw_req_bytes/8;
     end
     else begin
       max_dwid = WDPDATA/64;
     end
   end
   else begin
     max_dwid = WDPDATA/64;
   end

   dp_pkt.do_copy(scb_txn.dtw_req_pkt);

   `uvm_info("rearrangedtwdata",$sformatf("total_beats :%0d no_of_bytes_per_beat :%0d dtw_req_bytes :%0d  burst_length  :%0d ",total_beats,no_of_bytes_per_beat,dtw_req_bytes,burst_length),UVM_MEDIUM);
   `uvm_info("rearrangedtwdata",$sformatf("max_dwid :%0d initator intf_size :%0d smi_src_ncore_unit_id :%0d",max_dwid,aiu_intfsize,scb_txn.dtw_req_pkt.smi_src_ncore_unit_id),UVM_MEDIUM);

   foreach(scb_txn.dtw_req_pkt.smi_dp_data[i])begin
     for(int j = 0; j< WXDATA/64;j++)begin
       `uvm_info("rearrangedtwdata",$sformatf("beatn :%0d dw : %0d dp_req_pkt.smi_dp_be   :%0x",i, j,scb_txn.dtw_req_pkt.smi_dp_be[i][j*8+:8]),UVM_MEDIUM);
       if(j < max_dwid)begin 
         if(|scb_txn.dtw_req_pkt.smi_dp_be[i][j*8+:8])begin
           tmp_dp_data[scb_txn.dtw_req_pkt.smi_dp_dwid[i][j*WSMIDPDWIDPERDW +: WSMIDPDWIDPERDW]] = scb_txn.dtw_req_pkt.smi_dp_data[i][j*64+:64];     
           tmp_dp_be[scb_txn.dtw_req_pkt.smi_dp_dwid[i][j*WSMIDPDWIDPERDW +: WSMIDPDWIDPERDW]]   = scb_txn.dtw_req_pkt.smi_dp_be[i][j*8+:8];     
           tmp_dp_dbad[scb_txn.dtw_req_pkt.smi_dp_dwid[i][j*WSMIDPDWIDPERDW +: WSMIDPDWIDPERDW]] = scb_txn.dtw_req_pkt.smi_dp_dbad[i][j*WSMIDPDBADPERDW+:WSMIDPDBADPERDW];     
           dwid                                                                         = scb_txn.dtw_req_pkt.smi_dp_dwid[i][j*WSMIDPDWIDPERDW +: WSMIDPDWIDPERDW]; 
         end
       end
       `uvm_info("rearrangedtwdata:0",$sformatf("beatn :%0d dtw_req_pkt.smi_dp_data :%0x",i,scb_txn.dtw_req_pkt.smi_dp_data[i][j*64+:64]),UVM_MEDIUM);
       `uvm_info("rearrangedtwdata:0",$sformatf("beatn :%0d dtw_req_pkt.smi_dp_be   :%0b",i,scb_txn.dtw_req_pkt.smi_dp_be[i][j*8+:8]),UVM_MEDIUM);
       `uvm_info("rearrangedtwdata:0",$sformatf("beatn :%0d dtw_req_pkt.smi_dp_dbad :%0b",i,scb_txn.dtw_req_pkt.smi_dp_dbad[i][j*WSMIDPDBADPERDW+:WSMIDPDBADPERDW]),UVM_MEDIUM);
       `uvm_info("rearrangedtwdata:0",$sformatf("dtw_req_pkt.smi_dp_dwid :%0d",scb_txn.dtw_req_pkt.smi_dp_dwid[i][j*WSMIDPDWIDPERDW +: WSMIDPDWIDPERDW]),UVM_MEDIUM);
       `uvm_info("rearrangedtwdata:0",$sformatf("dwid :%0d",dwid),UVM_MEDIUM);
       `uvm_info("rearrangedtwdata:0",$sformatf("tmp_dp_data :%0x",tmp_dp_data[dwid]),UVM_MEDIUM);
       `uvm_info("rearrangedtwdata:0",$sformatf("tmp_dp_be   :%0b",tmp_dp_be[dwid]),UVM_MEDIUM);
       `uvm_info("rearrangedtwdata:0",$sformatf("tmp_dp_dbad :%b" ,tmp_dp_dbad[dwid]),UVM_MEDIUM);
      end
    end
   
    critical_smi_addr = (scb_txn.cache_addr >> $clog2(no_of_bytes_per_beat) << $clog2(no_of_bytes_per_beat));
    dwid = critical_smi_addr[5:3]; 

    if(scb_txn.dtw_req_pkt.smi_prim)begin
      if((2**req_data_size) > 8)begin
        tmp_smi_addr  = ((scb_txn.cache_addr >>req_data_size)<<req_data_size);
        `uvm_info("rearrangedtwdata chooseBid",$sformatf("smi_addr :%0x tmp_smi_addr :%0x req_data_size :%0d intfsize :%0d ",scb_txn.cache_addr,tmp_smi_addr,req_data_size,WXDATA),UVM_MEDIUM);
        dwid_l = tmp_smi_addr[5:3];
        dwid_h = dwid_l+((2**req_data_size)/8)-1;
      end
    end 
    else begin
      tmp_smi_addr  = ((scb_txn.cache_addr >>6)<<6);
      dwid_l = tmp_smi_addr[5:3];
      dwid_h = dwid_l+7;
    end

    `uvm_info("rearrangedtwdata",$sformatf("dwid :%0d dwid_l :%0d dwid_h :%0d",dwid,dwid_l,dwid_h),UVM_MEDIUM);
    scb_txn.dtw_req_pkt.smi_dp_data   = new[burst_length];
    scb_txn.dtw_req_pkt.smi_dp_be     = new[burst_length];
    scb_txn.dtw_req_pkt.smi_dp_dbad   = new[burst_length];

    foreach(scb_txn.dtw_req_pkt.smi_dp_data[i])begin
      for(int j = 0; j< WXDATA/64;j++)begin
        `uvm_info("rearrangeddtwdata",$sformatf("dwid :%0d |tmp_dp_be[dwid] :%0b",dwid,|tmp_dp_be[dwid]),UVM_MEDIUM);
        if(|tmp_dp_be[dwid] == 1'b1)begin
          scb_txn.dtw_req_pkt.smi_dp_data[i][j*64+:64]                                  =       tmp_dp_data[dwid]; 
          scb_txn.dtw_req_pkt.smi_dp_be[i][j*8+:8]                                      =       tmp_dp_be[dwid]; 
          scb_txn.dtw_req_pkt.smi_dp_dbad[i][j*WSMIDPDBADPERDW+:WSMIDPDBADPERDW]        =       tmp_dp_dbad[dwid];      
         `uvm_info("rearrangedtwdata",$sformatf("beatn :%0d scb_txn.dtw_req_pkt.smi_dp_data     :%0x  tmp_dp_data[%0d]  %0x ",i,scb_txn.dtw_req_pkt.smi_dp_data[i],dwid,tmp_dp_data[dwid]),UVM_MEDIUM);
         `uvm_info("rearrangedtwdata",$sformatf("beatn :%0d scb_txn.dtw_req_pkt.smi_dp_be       :%0x  tmp_dp_be[%0d]    %0x ",i,scb_txn.dtw_req_pkt.smi_dp_be[i],dwid,tmp_dp_be[dwid]),UVM_MEDIUM);
         `uvm_info("rearrangedtwdata",$sformatf("beatn :%0d scb_txn.dtw_req_pkt.smi_dp_dbad     :%0x  tmp_dp_dbad[%0d]  %0x ",i,scb_txn.dtw_req_pkt.smi_dp_dbad[i],dwid,tmp_dp_dbad[dwid]),UVM_MEDIUM);
        end
        dwid++;
      end
      if(dwid > dwid_h)begin
        dwid = dwid_l;
      end
    end
  //end
  foreach(scb_txn.dtw_req_pkt.smi_dp_data[i])begin
    `uvm_info("rearrangedtwdata",$sformatf("beatn :%0d dp_pkt.smi_dp_data     :%0x",i,dp_pkt.smi_dp_data[i]),UVM_MEDIUM);
    `uvm_info("rearrangedtwdata",$sformatf("beatn :%0d dp_pkt.smi_dp_be       :%0x",i,dp_pkt.smi_dp_be[i]),UVM_MEDIUM);
    `uvm_info("rearrangedtwdata",$sformatf("beatn :%0d dp_pkt.smi_dp_dbad     :%0x",i,dp_pkt.smi_dp_dbad[i]),UVM_MEDIUM);
    `uvm_info("rearrangedtwdata",$sformatf("beatn :%0d dp_pkt.smi_dp_dwid     :%0x",i,dp_pkt.smi_dp_dwid[i]),UVM_MEDIUM);
    `uvm_info("rearrangedtwdata",$sformatf("beatn :%0d dtw_req_pkt.smi_dp_data :%0x",i,scb_txn.dtw_req_pkt.smi_dp_data[i]),UVM_MEDIUM);
    `uvm_info("rearrangedtwdata",$sformatf("beatn :%0d dtw_req_pkt.smi_dp_be   :%0x",i,scb_txn.dtw_req_pkt.smi_dp_be[i]),UVM_MEDIUM);
    `uvm_info("rearrangedtwdata",$sformatf("beatn :%0d dtw_req_pkt.smi_dp_dbad :%0x",i,scb_txn.dtw_req_pkt.smi_dp_dbad[i]),UVM_MEDIUM);
    `uvm_info("rearrangedtwdata",$sformatf("beatn :%0d dtw_req_pkt.smi_dp_dwid :%0x",i,scb_txn.dtw_req_pkt.smi_dp_dwid[i]),UVM_MEDIUM);
  end
endfunction
//////////////////////////////////////////////////////////////////////////////////
// Expected Dtr Pkt
/////////////////////////////////////////////////////////////////////////////////
function void  dmi_scoreboard::rearrangedtrdata(ref dmi_scb_txn scb_txn);
  bit [63:0]  tmp_dp_data[8];
  bit [7:0]   tmp_dp_be[8];
  bit         tmp_dp_dbad[8];
  bit [7:0]   tmp_smi_cmstatus[8];
  bit [$clog2(NUM_BEATS_IN_DTR)-1:0]    beat_idx;
  bit [2:0]    critical_dwid;
  int          dwid,dwid_l,dwid_h;
  int          byte_cnt;
  bit [2:0]    req_byte;
  smi_addr_t  tmp_smi_addr;
  smi_addr_t  critical_smi_addr;
  smi_seq_item dp_pkt = new();
   
  critical_dwid = scb_txn.cache_addr[5:3]; 

  beat_idx = critical_dwid[2:3-$clog2(NUM_BEATS_IN_DTR)];

  if((2**scb_txn.smi_size) > WDPDATA/8)begin
    tmp_smi_addr  = ((scb_txn.cache_addr >>scb_txn.smi_size)<<scb_txn.smi_size);
   `uvm_info("rearrangedtrdata chooseBid",$sformatf("smi_addr :%0x tmp_smi_addr :%0x smi_size :%0d intfsize :%0d ",scb_txn.cache_addr,tmp_smi_addr,scb_txn.smi_size,scb_txn.smi_intfsize),UVM_MEDIUM);

    dwid_l = tmp_smi_addr[5:3];
    dwid_h = dwid_l+((2**scb_txn.smi_size)/8)-1;
  end
  else begin
    tmp_smi_addr  = ((scb_txn.cache_addr >>$clog2(WDPDATA/8))<<$clog2(WDPDATA/8));
   `uvm_info("rearrangedtrdata chooseBid",$sformatf("smi_addr :%0x tmp_smi_addr :%0x smi_size :%0d intfsize :%0d ",scb_txn.cache_addr,tmp_smi_addr,WDPDATA/8,scb_txn.smi_intfsize),UVM_MEDIUM);

    dwid_l = tmp_smi_addr[5:3];
    dwid_h = dwid_l+(WDPDATA/64)-1;
  end

  dwid                = beat_idx*(WXDATA/64);

  foreach(scb_txn.dtr_req_pkt_exp.smi_dp_data[i])begin
    for(int j = 0; j< WXDATA/64;j++)begin
   `uvm_info("rearrangedtrdata",$sformatf("beatn :%0d dp_req_pkt.smi_dp_be   :%0x",beat_idx,scb_txn.dtr_req_pkt_exp.smi_dp_be[i][j*8+:8]),UVM_MEDIUM);
         tmp_dp_data[dwid]      = scb_txn.dtr_req_pkt_exp.smi_dp_data[i][j*64+:64];     
         tmp_dp_dbad[dwid]      = scb_txn.dtr_req_pkt_exp.smi_dp_dbad[i][j*WSMIDPDBADPERDW+:WSMIDPDBADPERDW];     
         tmp_dp_be[dwid]        = scb_txn.dtr_req_pkt_exp.smi_dp_be[i][j*8+:8];     
         tmp_smi_cmstatus[dwid] = scb_txn.dtr_smi_cmstatus[i]; 
       `uvm_info("rearrangeddtrdata:1",$sformatf("beatn :%0d dp_req_pkt.smi_dp_data :%0x",i,scb_txn.dtr_req_pkt_exp.smi_dp_data[i][j*64+:64]),UVM_MEDIUM);
       `uvm_info("rearrangeddtrdata:1",$sformatf("beatn :%0d dp_req_pkt.smi_dp_be   :%0b",i,scb_txn.dtr_req_pkt_exp.smi_dp_be[i][j*8+:8]),UVM_MEDIUM);
       `uvm_info("rearrangeddtrdata:1",$sformatf("beatn :%0d dp_req_pkt.smi_dp_dbad :%0b",i,scb_txn.dtr_req_pkt_exp.smi_dp_dbad[i][j*WSMIDPDBADPERDW+:WSMIDPDBADPERDW]),UVM_MEDIUM);
       `uvm_info("rearrangeddtrdata:1",$sformatf("dp_req_pkt.smi_dp_dwid :%0d",dwid),UVM_MEDIUM);
       `uvm_info("rearrangeddtrdata:1",$sformatf("tmp_dp_data :%0x",tmp_dp_data[dwid]),UVM_MEDIUM);
       `uvm_info("rearrangeddtrdata:1",$sformatf("tmp_dp_dbad :%b" ,tmp_dp_dbad[dwid]),UVM_MEDIUM);
       `uvm_info("rearrangeddtrdata:1",$sformatf("tmp_smi_cmstatus :%b" ,tmp_smi_cmstatus[dwid]),UVM_MEDIUM);
        dwid++;
    end
    if(dwid > dwid_h)begin
      dwid = dwid_l;
    end
    beat_idx++;
  end

  critical_smi_addr = (scb_txn.cache_addr >> (scb_txn.smi_intfsize+3) << (scb_txn.smi_intfsize+3));
  dwid   = critical_smi_addr[5:3];
  `uvm_info("rearrangedtrdata",$sformatf("scb_txn.cache_add :%0x critical_smi_addr :%0x dwid :%0d intfsize :%0d ",scb_txn.cache_addr,critical_smi_addr,dwid,scb_txn.smi_intfsize),UVM_MEDIUM); 

  byte_cnt = 0;
  `uvm_info("rearrangedtrdata",$sformatf("dwid :%0d dwid_l :%0d dwid_h :%0d",dwid,dwid_l,dwid_h),UVM_MEDIUM);

  if(((2**scb_txn.smi_intfsize)*64) >WXDATA)begin
    if((2**scb_txn.smi_size) < (2**scb_txn.smi_intfsize)*8)begin
      scb_txn.dtr_req_pkt_exp.smi_dp_data      =      new[((2**scb_txn.smi_intfsize)*64)/WXDATA] ; 
      scb_txn.dtr_req_pkt_exp.smi_dp_dbad      =      new[((2**scb_txn.smi_intfsize)*64)/WXDATA] ;      
      scb_txn.dtr_req_pkt_exp.smi_dp_be        =      new[((2**scb_txn.smi_intfsize)*64)/WXDATA] ;      
      scb_txn.dtr_req_pkt_exp.smi_dp_dwid      =      new[((2**scb_txn.smi_intfsize)*64)/WXDATA] ;
      tmp_smi_addr  = ((scb_txn.cache_addr >>scb_txn.smi_size)<<scb_txn.smi_size);
      //  dwid          = tmp_smi_addr[5:3];
      dwid_l        = critical_smi_addr[5:3];
      dwid_h        = dwid_l+(2**scb_txn.smi_intfsize)-1;
    end
    else begin
      scb_txn.dtr_req_pkt_exp.smi_dp_data      =      new[((2**scb_txn.smi_size)*8)/WXDATA] ; 
      scb_txn.dtr_req_pkt_exp.smi_dp_dbad      =      new[((2**scb_txn.smi_size)*8)/WXDATA] ;      
      scb_txn.dtr_req_pkt_exp.smi_dp_be        =      new[((2**scb_txn.smi_size)*8)/WXDATA] ;      
      scb_txn.dtr_req_pkt_exp.smi_dp_dwid      =      new[((2**scb_txn.smi_size)*8)/WXDATA] ;
    end
    `uvm_info("rearrangedtrdata chooseBid:1",$sformatf("dwid :%0d dwid_l :%0d dwid_h :%0d",dwid,dwid_l,dwid_h),UVM_MEDIUM);
  end
  else if((((2**scb_txn.smi_intfsize)*64) == WXDATA ) && ((2**scb_txn.smi_size) <= (WXDATA/8)))begin 
    dwid_l        = critical_smi_addr[5:3];
    dwid_h        = dwid_l+(WXDATA/64)-1;
    `uvm_info("rearrangedtrdata chooseBid:2",$sformatf("dwid :%0d dwid_l :%0d dwid_h :%0d",dwid,dwid_l,dwid_h),UVM_MEDIUM);
  end
  else if((((2**scb_txn.smi_intfsize)*64) < WXDATA  ) && (((2**scb_txn.smi_size) <= (2**scb_txn.smi_intfsize)*8)))begin
    dwid_l        = critical_smi_addr[5:3];
    dwid_h        = dwid_l+(2**scb_txn.smi_intfsize)-1;
    `uvm_info("rearrangedtrdata chooseBid:3",$sformatf("dwid :%0d dwid_l :%0d dwid_h :%0d",dwid,dwid_l,dwid_h),UVM_MEDIUM);
  end
  else if((((2**scb_txn.smi_intfsize)*64) < WXDATA  ) && (((2**scb_txn.smi_size) > (2**scb_txn.smi_intfsize)*8)))begin
    tmp_smi_addr  = ((scb_txn.cache_addr >>scb_txn.smi_size)<<scb_txn.smi_size);
    dwid_l        = tmp_smi_addr[5:3];
    dwid_h        = dwid_l+((2**scb_txn.smi_size)/8)-1;
    `uvm_info("rearrangedtrdata chooseBid:3",$sformatf("dwid :%0d dwid_l :%0d dwid_h :%0d",dwid,dwid_l,dwid_h),UVM_MEDIUM);
  end

  `uvm_info("rearrangedtrdata chooseBid:4",$sformatf("dwid :%0d dwid_l :%0d dwid_h :%0d",dwid,dwid_l,dwid_h),UVM_MEDIUM);

  foreach(scb_txn.dtr_req_pkt_exp.smi_dp_data[i])begin
    for(int j = 0; j< WXDATA/64;j++)begin
      `uvm_info("rearrangedtrdata chooseBid:4",$sformatf("dwid :%0d dwid_l :%0d dwid_h :%0d",dwid,dwid_l,dwid_h),UVM_MEDIUM);
      scb_txn.dtr_req_pkt_exp.smi_dp_data[i][j*64+:64]                                  =       tmp_dp_data[dwid]; 
      scb_txn.dtr_req_pkt_exp.smi_dp_dbad[i][j*WSMIDPDBADPERDW+:WSMIDPDBADPERDW]        =       tmp_dp_dbad[dwid];      
      scb_txn.dtr_req_pkt_exp.smi_dp_be[i][j*8+:8]                                      =       tmp_dp_be[dwid]; 
      scb_txn.dtr_req_pkt_exp.smi_dp_dwid[i][j*WSMIDPDWIDPERDW +: WSMIDPDWIDPERDW]      =       dwid;
      if(i == 0  && tmp_smi_cmstatus[dwid] > scb_txn.dtr_req_pkt_exp.smi_cmstatus)begin
        scb_txn.dtr_req_pkt_exp.smi_cmstatus = tmp_smi_cmstatus[dwid] ;
      end
      else if((scb_txn.dtr_req_pkt_exp.smi_cmstatus == 'b0) && (tmp_smi_cmstatus[dwid] == 7'b0000001 ) )begin
        scb_txn.dtr_req_pkt_exp.smi_cmstatus = tmp_smi_cmstatus[dwid] ;
      end

      dwid++;
      byte_cnt = byte_cnt+8;
      if(dwid > dwid_h)begin
        dwid = dwid_l;
      end
    end
  end
  if(scb_txn.dtr_req_pkt_exp.smi_cmstatus == 1 && scb_txn.dtr_smi_cmstatus[0] == 0) begin
    //CONC-17020
    `uvm_info("rearrangedtrdata",$sformatf("Received DTR CMStatus:%0p, first beat not EXOKAY, overriding", scb_txn.dtr_smi_cmstatus),UVM_MEDIUM)
    scb_txn.dtr_req_pkt_exp.smi_cmstatus = 0;
  end
  foreach(scb_txn.dtr_req_pkt_exp.smi_dp_data[i])begin
      `uvm_info("rearrangedtrdata",$sformatf("beatn :%0d dp_pkt.smi_dp_data     :%0x  ",i,scb_txn.dtr_req_pkt_exp.smi_dp_data[i]),UVM_MEDIUM);
      `uvm_info("rearrangedtrdata",$sformatf("beatn :%0d dp_pkt.smi_dp_dbad     :%0x  ",i,scb_txn.dtr_req_pkt_exp.smi_dp_dbad[i]),UVM_MEDIUM);
      `uvm_info("rearrangedtrdata",$sformatf("beatn :%0d dp_pkt.smi_dp_be       :%0x  ",i,scb_txn.dtr_req_pkt_exp.smi_dp_be[i]),UVM_MEDIUM);
      `uvm_info("rearrangedtrdata",$sformatf("beatn :%0d dp_pkt.smi_dp_dwid     :%0x  ",i,scb_txn.dtr_req_pkt_exp.smi_dp_dwid[i]),UVM_MEDIUM);
  end
  `uvm_info("rearrangedtrdata",$sformatf("beatn :%0d dp_pkt.smi_cmstatus    :%0x  ",0,scb_txn.dtr_req_pkt_exp.smi_cmstatus),UVM_MEDIUM);
endfunction///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


function void dmi_scoreboard::updateRttentry(dmi_scb_txn txn, int idx);
  //////////////// adding the below logic for functional coverage purpose ////////////////////
  int tmp_q[$];
  //#Check.DMI.Concerto.v3.0.DTWMrgMrdNoAlloc
  //#Check.DMI.Concerto.v3.0.DTWMrgMrdmisswithAlloc
  tmp_q = wtt_q.find_index with   (item.isDtwMrgMrd &&
                                  (cl_aligned(item.cache_addr)==cl_aligned(txn.cache_addr)) &&
                                  (security_match(item.security, txn.security)) &&
                                  (item.smi_rbid == txn.smi_rbid));

  if(tmp_q.size() == 1) begin
    wtt_q[tmp_q[0]].AXI_read_addr_recd_wtt = txn.AXI_read_addr_recd;
    wtt_q[tmp_q[0]].AXI_read_data_recd_wtt = txn.AXI_read_data_recd;
    wtt_q[tmp_q[0]].DTR_req_recd_wtt = txn.DTR_req_recd;
    wtt_q[tmp_q[0]].DTR_rsp_recd_wtt = txn.DTR_rsp_recd;
  end
  ////////////////////////////////////////////////////////////////////////////////////////////
  // txn.print_entry();
  // $display("idx :%0d",idx);
  // $display("AXI_read_data_expd:%0b AXI_write_data_recd:%0b",txn.AXI_read_data_expd,txn.AXI_write_data_recd);
  if((txn.CMD_rsp_expd===1)&&(txn.CMD_rsp_recd===0)) begin
     `uvm_info("<%=obj.BlockId%>:processRTTentry","Not deleting as CMD_rsp_expd transactions expected",UVM_MEDIUM)
  end
  else if((txn.MRD_rsp_expd===1)&&(txn.MRD_rsp_recd===0)) begin
     `uvm_info("<%=obj.BlockId%>:updateRttentry","Not deleting as MRD_rsp_expd transactions expected",UVM_MEDIUM)
  end
  else if((txn.AXI_read_data_expd===1) && (txn.AXI_read_data_recd===0)) begin // check and delete only if txn is really done
     `uvm_info("<%=obj.BlockId%>:updateRttentry","Not deleting as AXI data transactions expected",UVM_MEDIUM)
  end
  else if((txn.lookupExpd ===1)&&(txn.lookupSeen ===0)) begin
     `uvm_info("<%=obj.BlockId%>:processRttentry","Not deleting as LookupExpd transactions expected",UVM_MEDIUM)
  end
  else if((txn.fillExpd ===1)&&(txn.fillSeen===0)) begin
     `uvm_info("<%=obj.BlockId%>:updateRttentry","Not deleting as FillCtrl transactions expected",UVM_MEDIUM)
  end
  else if((txn.fillDataExpd ===1)&&(txn.fillDataSeen === 0)) begin
     `uvm_info("<%=obj.BlockId%>:updateRttentry","Not deleting as FillData transactions expected",UVM_MEDIUM)
  end
  else if((txn.STR_rsp_expd===1)&&(txn.STR_rsp_recd===0)) begin
     `uvm_info("<%=obj.BlockId%>:updateRttentry","Not deleting as STR_rsp_expd transactions expected",UVM_MEDIUM)
  end
  else if((txn.DTR_req_expd===1)&&(txn.DTR_req_recd===0)) begin
     `uvm_info("<%=obj.BlockId%>:updateRttentry","Not deleting as DTR_req_expd transactions expected",UVM_MEDIUM)
  end
  else if((txn.DTW_rsp_expd===1)&&(txn.DTW_rsp_recd===0)) begin
     `uvm_info("<%=obj.BlockId%>:updateRttentry","Not deleting as DTW_rsp_expd transactions expected",UVM_MEDIUM)
  end
  else if((txn.DTW_rsp_expd===1)&&(txn.smi_dp_last ==0)) begin
     `uvm_info("<%=obj.BlockId%>:updateRttentry","Not deleting waiting for last beat transactions expected",UVM_MEDIUM)
  end
  else if((txn.cacheRspExpd===1)&&(txn.cacheRspRecd===0)) begin
     `uvm_info("<%=obj.BlockId%>:updateRttentry","Not deleting as cacheRspExpd transactions expected",UVM_MEDIUM)
  end
  else if((txn.DTR_rsp_expd===1)&&(txn.DTR_rsp_recd===0)) begin
     `uvm_info("<%=obj.BlockId%>:updateRttentry","Not deleting as DTR_rsp_expd transactions expected",UVM_MEDIUM)
  <% if(obj.useCmc) { %>
  end else if ((txn.sp_txn===1) &&
               ((txn.sp_seen_ctrl_chnl===0)||(txn.sp_seen_output_chnl===0))) begin
   `uvm_info("<%=obj.BlockId%>:updateRttentry","Not deleting as txn is yet to be received on sp rdrsp channel",UVM_MEDIUM)
  <% } %>
  end
  else if(!txn.seenAtReadArb && !txn.isDtwMrgMrd && !isAtomicMsg(txn.smi_msg_type) && !(txn.smi_msg_type inside {CMD_CLN_INV,CMD_CLN_VLD,CMD_CLN_SH_PER,CMD_MK_INV})) begin
    `uvm_info("<%=obj.BlockId%>:updateRttentry","Not deleting as txn is yet to be received on the read arbiter in protocol control",UVM_MEDIUM)
  end
  else if(!txn.seenAtWriteArb && (txn.isDtwMrgMrd || txn.isAtomic)) begin
    `uvm_info("<%=obj.BlockId%>:updateRttentry","Not deleting as txn is yet to be received on the write arbiter in protocol control",UVM_MEDIUM)
  end
  else begin
    `uvm_info("<%=obj.BlockId%>:updateRttentry",$sformatf("DMI_UID:%0d Deleting RTT entry",rtt_q[idx].txn_id),UVM_MEDIUM)
    
    if($test$plusargs("pref_test"))begin
      calculate_dmi_latency_data(idx,"rtt");
    end
   
    if($test$plusargs("report_qos_latency")) begin
        calculate_dmi_latency_data_per_qos(idx,"rtt");
    end
    
    `ifndef FSYS_COVER_ON
    cov.collect_rtt_entry(txn);
    `endif
    txn.check_entry();
        
    // PERF MONITOR before delete the transactions check status and generate event
    begin:rtt_perf_mon_catch_evt
    eMsgCMD cmd_msg=eMsgCMD'(rtt_q[idx].cmd_msg_type);
    eMsgMRD mrd_msg=eMsgMRD'(rtt_q[idx].mrd_msg_type);
    string cmd_str= (cmd_msg)?cmd_msg.name:"null";
    string mrd_str= (mrd_msg)?mrd_msg.name:"null";
    if(rtt_q[idx].smi_vz == SMI_VZ_SYSTEM_DOMAIN) sb_stall_if.perf_count_events["Number_of_System_visible_Txn"].push_back(1);
      <% if(obj.useCmc) { %>
      if (!uvm_re_match("CmdRd",cmd_str) || !uvm_re_match("MrdRd",mrd_str)) begin   // !!umv_re_match =0 => match!!
           if (rtt_q[idx].isCacheHit) sb_stall_if.perf_count_events["Cache_read_hit"].push_back(1);
           if (rtt_q[idx].isCacheMiss || !rtt_q[idx].isCacheHit) sb_stall_if.perf_count_events["Cache_read_miss"].push_back(1);
      end 
      if (!uvm_re_match("(CmdMk|CmdCln)",cmd_str) || !uvm_re_match("(MrdCln|MrdInv|MrdFlush)",mrd_str)) begin // !! uvm_re_match=0 => match!!!
         if (rtt_q[idx].isCacheMiss || !rtt_q[idx].isCacheHit) sb_stall_if.perf_count_events["Cache_CMO_miss"].push_back(1);
         if (rtt_q[idx].isCacheHit) sb_stall_if.perf_count_events["Cache_CMO_hit"].push_back(1);
      end
      <% } %>
    end:rtt_perf_mon_catch_evt
    rtt_q.delete(idx);
    e_check_txnq_size.trigger();
    //->smi_drop;
  end
endfunction //updateRttentry
function void dmi_scoreboard::updateWttentry(dmi_scb_txn txn, int idx);
  //////////////// adding the below logic for functional coverage purpose //////////////////////      
  int tmp_q[$], arb_match_q[$];
  
  tmp_q = rtt_q.find_index with (item.isDtwMrgMrd && 
                                (cl_aligned(item.cache_addr)==cl_aligned(txn.cache_addr)) &&
                                (security_match(item.security, txn.security)) &&
                                (item.smi_rbid == txn.smi_rbid));
  if(tmp_q.size() == 1) begin
    rtt_q[tmp_q[0]].AXI_write_addr_recd_rtt = txn.AXI_write_addr_recd;
    rtt_q[tmp_q[0]].AXI_write_data_recd_rtt = txn.AXI_write_data_recd;
    rtt_q[tmp_q[0]].AXI_write_resp_recd_rtt = txn.AXI_write_resp_recd;
    rtt_q[tmp_q[0]].DTW_req_recd_rtt        = txn.DTW_req_recd;   
    rtt_q[tmp_q[0]].DTW_rsp_recd_rtt        = txn.DTW_rsp_recd;
    rtt_q[tmp_q[0]].RB_req_recd_rtt         = txn.RB_req_recd;
    rtt_q[tmp_q[0]].RB_rsp_recd_rtt         = txn.RB_rsp_recd;
    rtt_q[tmp_q[0]].RBU_req_recd_rtt        = txn.RBU_req_recd;
    rtt_q[tmp_q[0]].RBU_rsp_recd_rtt        = txn.RBU_rsp_recd;
  end
  //////////////////////////////////////////////////////////////////////////////////////////////
  if((txn.CMD_rsp_expd===1)&&(txn.CMD_rsp_recd===0)) begin
    `uvm_info("<%=obj.BlockId%>:updateWttentry","Not deleting as CMD_rsp_expd transactions expected",UVM_MEDIUM)
  end
  else if((txn.STR_rsp_expd===1)&&(txn.STR_rsp_recd===0)) begin
    `uvm_info("<%=obj.BlockId%>:updateWttentry","Not deleting as STR_rsp_expd transactions expected",UVM_MEDIUM)
  end
  else if((txn.AXI_write_resp_expd===1) && (txn.AXI_write_resp_recd===0)) begin 
    `uvm_info("<%=obj.BlockId%>:updateWttentry","Not deleting as AXI brsp transactions expected",UVM_MEDIUM)
  end
  else if((txn.AXI_read_data_expd===1) && (txn.AXI_read_data_recd===0)) begin 
    `uvm_info("<%=obj.BlockId%>:updateWttentry","Not deleting as AXI rdata transactions expected",UVM_MEDIUM)
  end
  else if((txn.fillExpd ===1)&&(txn.fillSeen===0)) begin
    `uvm_info("<%=obj.BlockId%>:updateWttentry","Not deleting as FillCtrl transactions expected",UVM_MEDIUM)
  end
  else if((txn.fillDataExpd ===1)&&(txn.fillDataSeen === 0)) begin
    `uvm_info("<%=obj.BlockId%>:updateWttentry","Not deleting as FillData transactions expected",UVM_MEDIUM)
  end
  else if((txn.evictDataExpd ===1)&&(txn.evictDataRecd === 0)) begin
    `uvm_info("<%=obj.BlockId%>:updateWttentry","Not deleting as evictDataExpd transactions expected",UVM_MEDIUM)
  end
  else if((txn.cacheRspExpd ===1)&&(txn.cacheRspRecd === 0)) begin
    `uvm_info("<%=obj.BlockId%>:updateWttentry","Not deleting as cacheRspExpd transactions expected",UVM_MEDIUM)
  end
  else if((txn.RB_req_expd===1)&&(txn.RB_req_recd===0)) begin
    `uvm_info("<%=obj.BlockId%>:updateWttentry","Not deleting as RB_req_expd transactions expected",UVM_MEDIUM)
  end
  else if((txn.RB_rsp_expd===1)&&(txn.RB_rsp_recd===0)) begin
    `uvm_info("<%=obj.BlockId%>:updateWttentry","Not deleting as RB_rsp_expd transactions expected",UVM_MEDIUM)
  end
  else if((txn.RBRL_rsp_expd===1)&&(txn.RBRL_rsp_recd===0)) begin
    `uvm_info("<%=obj.BlockId%>:updateWttentry","Not deleting as RBRL_rsp_expd transactions expected",UVM_MEDIUM)
  end
  else if((txn.cacheWrDataExpd ===1)&&(txn.cacheWrDataRecd ===0)) begin
    `uvm_info("<%=obj.BlockId%>:updateWttentry","Not deleting as cacheWrDataExpd transactions expected",UVM_MEDIUM)
  end
  else if((txn.lookupExpd ===1)&&(txn.lookupSeen ===0)) begin
    `uvm_info("<%=obj.BlockId%>:updateWttentry","Not deleting as LookupExpd transactions expected",UVM_MEDIUM)
  end
  else if((txn.DTR_req_expd===1)&&(txn.DTR_req_recd===0)) begin
    `uvm_info("<%=obj.BlockId%>:updateWttentry","Not deleting as DTR_req_expd transactions expected",UVM_MEDIUM)
  end
  else if((txn.DTR_rsp_expd===1)&&(txn.DTR_rsp_recd===0)) begin
    `uvm_info("<%=obj.BlockId%>:updateWttentry","Not deleting as DTR_rsp_rxpd transactions expected",UVM_MEDIUM)
  end
  else if((txn.DTW2nd_req_expd===1)&&(txn.DTW2nd_req_recd===0)) begin
    `uvm_info("<%=obj.BlockId%>:updateWttentry","Not deleting as DTW2nd_req_expd transactions expected",UVM_MEDIUM)
  end
  else if((txn.DTW_rsp_expd===1)&&(txn.smi_dp_last ==0)) begin
    `uvm_info("<%=obj.BlockId%>:updateWttentry","Not deleting waiting for last beat",UVM_MEDIUM)
  end
  else if((txn.DTW_rsp_expd===1)&&(txn.DTW_rsp_recd===0)) begin
    `uvm_info("<%=obj.BlockId%>:updateWttentry","Not deleting as DTW_rsp_expd transactions expected",UVM_MEDIUM)
  <% if(obj.useCmc) { %>
  end else if ((txn.sp_txn===1) &&
              ((txn.sp_seen_ctrl_chnl===0) || (txn.sp_seen_write_chnl===0))) begin
    `uvm_info("<%=obj.BlockId%>:updateWttentry","Not deleting as txn is yet to be received on sp write channel",UVM_MEDIUM)
  <% } %>
  end
  else begin
    `uvm_info("<%=obj.BlockId%>:updateWttentry",$sformatf("DMI_UID:%0d Deleting WTT entry",wtt_q[idx].txn_id),UVM_MEDIUM)
    txn.print_entry();
    if(!txn.RBRL_rsp_expd) begin
      txn.check_entry();
    end
    if($test$plusargs("pref_test"))begin
      calculate_dmi_latency_data(idx,"wtt");
    end
    if($test$plusargs("report_qos_latency"))begin
      calculate_dmi_latency_data_per_qos(idx,"wtt");
    end
    `ifndef FSYS_COVER_ON
    cov.collect_wtt_entry(txn);
    `endif 
    // PERF MONITOR before delete the transactions check status and generate event 
    begin:wtt_perf_mon_catch_evt
      eMsgCMD cmd_msg=eMsgCMD'(wtt_q[idx].cmd_msg_type);
      eMsgMRD mrd_msg=eMsgMRD'(wtt_q[idx].mrd_msg_type);
      if (wtt_q[idx].smi_vz == SMI_VZ_SYSTEM_DOMAIN) sb_stall_if.perf_count_events["Number_of_System_visible_Txn"].push_back(1);
      if (wtt_q[idx].isDtwMrgMrd) sb_stall_if.perf_count_events["Number_of_Merge_events"].push_back(1);
      <% if(obj.useCmc) { %>
      //if (!uvm_re_match("Evict",cmd_msg.name) || wtt_q[idx].isEvict || wtt_q[idx].causeEvict) sb_stall_if.perf_count_events["Cache_eviction"].push_back(1); // !! uvm_re_match =0 when matching
      <% } %>
    end:wtt_perf_mon_catch_evt
    wtt_q.delete(idx);
    e_check_txnq_size.trigger();
    //->smi_drop;
  end
endfunction //updateWttentry
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
<% if(obj.useCmc) { %>
function void dmi_scoreboard::create_exp_fillCtrl(ccp_ctrl_pkt_t  cache_ctrl_pkt, ref dmi_scb_txn scb_pkt);
  scb_pkt.cache_fill_ctrl_pkt_exp = new();
  scb_pkt.cache_fill_ctrl_pkt_exp.addr      = cache_ctrl_pkt.addr;
  scb_pkt.cache_fill_ctrl_pkt_exp.security  = cache_ctrl_pkt.security;
  scb_pkt.cache_fill_ctrl_pkt_exp.wayn      = cache_ctrl_pkt.wayn;
  scb_pkt.cache_fill_ctrl_pkt_exp.state     = SC;
endfunction


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Function: convert_axi_to_ccp_data 
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function void dmi_scoreboard::convert_axi_to_fill_data( 
                      ref   dmi_scb_txn         scb_pkt,
                      output ccp_ctrlfill_data_t fill_data[],
                      output int                 fill_data_beats[],
                      output ccp_data_poision_t  fill_data_poison[]
                      );


  axi_xdata_t  axi_rd_data[];
  axi_axaddr_t araddr;

  bit [(LINE_INDEX_H-LINE_INDEX_L):0] beat_offset;
  string spkt;

  axi_rd_data  = scb_pkt.axi_read_data_pkt.rdata;
  araddr       = scb_pkt.axi_read_addr_pkt.araddr;
  
  beat_offset = araddr[LINE_INDEX_H:LINE_INDEX_L];
  scb_pkt.cache_fill_data_pkt_exp = new(); 

  if(axi_rd_data.size()>0) begin
    fill_data        = new[axi_rd_data.size()];
    fill_data_beats  = new[axi_rd_data.size()];
    fill_data_poison = new[axi_rd_data.size()];
    scb_pkt.cache_fill_data_pkt_exp.data   = new[axi_rd_data.size()]; 
    scb_pkt.cache_fill_data_pkt_exp.poison = new[axi_rd_data.size()];
    scb_pkt.cache_fill_data_pkt_exp.beatn  = new[axi_rd_data.size()];
    scb_pkt.cache_fill_data_pkt_exp.byten   = new[axi_rd_data.size()];

    for(int i=0; i<axi_rd_data.size();i++) begin
        fill_data[i]       = axi_rd_data[i];
        fill_data_beats[i] = beat_offset;

        if (scb_pkt.axi_read_data_pkt.rresp_per_beat[i] !== 0) begin
            fill_data_poison[i] = 1'b1;
        end else begin
            fill_data_poison[i] = 1'b0;
        end
       scb_pkt.cache_fill_data_pkt_exp.data[i]    = axi_rd_data[i]; 
       scb_pkt.cache_fill_data_pkt_exp.poison[i]  = fill_data_poison[i] ;
       scb_pkt.cache_fill_data_pkt_exp.beatn[i]   = beat_offset;
       scb_pkt.cache_fill_data_pkt_exp.byten[i]   = (1<<(WSMIDPBE))-1;

       beat_offset = beat_offset + 1;
    end
  end
  else begin
    spkt = {"In function convert_axi_to_fill_data input data size is null can't convert axi packet to fill data packet"};
    `uvm_error(`LABEL_ERROR,spkt)
  end

endfunction

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Function: convert_dtw_to_ccp_data 
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function void dmi_scoreboard::convert_dtw_to_ccp_data( 
                      input  dmi_scb_txn         scb_pkt,
                      output ccp_ctrlwr_data_t   ccp_data[],
                      output int                 ccp_data_beat[],
                      output ccp_data_poision_t        fill_data_poison[]
                      );


  bit [(LINE_INDEX_H-LINE_INDEX_L):0] beat_offset;
  string spkt;
  smi_dp_data_bit_t   smi_dp_data[];
  
  beat_offset                  = scb_pkt.cache_addr[LINE_INDEX_H:LINE_INDEX_L];
  smi_dp_data                  = scb_pkt.dtw_req_pkt.smi_dp_data;
  //Caclulate the Wrap address based on the AXI spec
  if(smi_dp_data.size()>0) begin
    foreach(scb_pkt.dtw_req_pkt.smi_dp_data[i])begin
      ccp_data[i]      = smi_dp_data[i];
      ccp_data[i]      = scb_pkt.dtw_req_pkt.smi_dp_be[i];
      ccp_data_beat[i] = beat_offset;
      beat_offset      = beat_offset + 1'b1;
    end
  end
  else begin
    spkt = {"In function convert_agent_data_to_ccp_data input data size is null can't convert dtw packet to ccp data packet"};
    `uvm_error(`LABEL_ERROR,spkt)
  end
endfunction//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

function void dmi_scoreboard::process_atomic_op(ref dmi_scb_txn txn,input int idx, bit ScratchPad = 0);
  //#Check.DMI.Concerto.v3.0.AtomicEngine
  bit atm_str;
  bit atm_ld;
  bit atm_cmp;
  bit atm_swp;
  bit swp_flag;

  bit upd_cache_on_hit;

  smi_mpf1_argv_t opcode;
  smi_dp_be_t byte_en;

  smi_size_t smi_size;
  smi_size_t smi_size_div_by_2;

  smi_addr_t smi_addr;
  smi_addr_t smi_addr_swp;
  smi_addr_t byte_addr;
  smi_addr_t byte_addr_swp;
  smi_addr_t swp_byte_addr;

  int burst_len;
  int num_bytes;
  int num_bytes_per_beat;
  int numbeat;
  int cmp_beat, swp_beat;

  bit [(LINE_INDEX_H-LINE_INDEX_L):0] beatn;

  bit [WSMIDPBE*8-1:0] m_data;
  bit [WSMIDPBE*8-1:0] s_data;
  bit [WSMIDPBE*8-1:0] m_data_tmp;
  bit [WSMIDPBE*8-1:0] s_data_tmp;
  bit [WSMIDPBE*8-1:0] swp_data[];
  bit [WSMIDPBE*8-1:0] o_data[];
  bit [WSMIDPBE*8-1:0] cmp_data[];
  bit [WSMIDPBE*8-1:0] m_cmp_data[];
  bit [WSMIDPBE-1:0]   Expd_byte_en;
  bit [WSMIDPDBADPERDW-1:0] o_data_dbad[];

  atm_str = (txn.smi_msg_type == CMD_WR_ATM);
  atm_ld  = (txn.smi_msg_type == CMD_RD_ATM);
  atm_swp = (txn.smi_msg_type == CMD_SW_ATM);
  atm_cmp = (txn.smi_msg_type == CMD_CMP_ATM);

  opcode  = txn.cmd_req_pkt.smi_mpf1_argv[2:0];
  smi_size = txn.cmd_req_pkt.smi_size;
  //smi_size_div_by_2 = smi_size >> 1; // for AtomicCompare
  num_bytes = atm_cmp ? (2**smi_size)/2 : 2**smi_size;

  smi_addr = txn.cmd_req_pkt.smi_addr;
  smi_addr_swp = smi_addr;
  smi_addr_swp[$clog2(num_bytes)] = ~smi_addr[$clog2(num_bytes)];

  `uvm_info("<%=obj.BlockId%>:process_atomic_op", $sformatf("smi_msg_type :%0s opcode  :%0x smi_addr_swp :%0x num_bytes :%0d",smi_type_string(txn.smi_msg_type),opcode,smi_addr_swp,num_bytes),UVM_MEDIUM)

  num_bytes_per_beat = WXDATA/8; // or WSMIDPBE
  beatn = smi_addr[LINE_INDEX_H:LINE_INDEX_L]; // assuming single beat

  if(num_bytes > num_bytes_per_beat)begin
    numbeat = (num_bytes/num_bytes_per_beat);
    num_bytes = num_bytes_per_beat;
  end
  else begin
    numbeat = 1;
  end

  Expd_byte_en = (1<<(WSMIDPBE))-1;
  txn.ATM_processed = 1;

  txn.cache_fill_ctrl_pkt_exp = new();
  txn.cache_fill_data_pkt_exp = new();
  txn.cache_fill_data_pkt_exp.data = new[numbeat];
  txn.cache_fill_data_pkt_exp.beatn = new[numbeat];
  txn.cache_fill_data_pkt_exp.byten = new[numbeat];
  txn.cache_fill_data_pkt_exp.poison = new[numbeat];
 
  foreach(txn.dtw_req_pkt.smi_dp_data[i])begin
    `uvm_info("<%=obj.BlockId%>:process_atomic_op", $sformatf("txn.dtw_req_pkt.smi_dp_data[%0d] = %0h",i,txn.dtw_req_pkt.smi_dp_data[i]), UVM_MEDIUM)
    if(txn.cacheRspRecd)begin
      `uvm_info("<%=obj.BlockId%>:process_atomic_op", $sformatf("txn.cache_rd_data_pkt.data[%0d] = %0h",i,txn.cache_rd_data_pkt.data[i]), UVM_MEDIUM)
    end
    if(txn.AXI_read_data_recd)begin
      `uvm_info("<%=obj.BlockId%>:process_atomic_op", $sformatf("txn.axi_read_data_pkt.rdata[%0d] = %0h",i,txn.axi_read_data_pkt.rdata[i]), UVM_MEDIUM)
    end
  end

  cmp_data   = new[numbeat];  
  swp_data   = new[numbeat];  
  m_cmp_data = new[numbeat];  
  o_data     = new[numbeat];  
  o_data_dbad= new[numbeat];

  // smi_size is total number of bytes in the transaction
  // AtomicCompare has 2 parts - atm_cmp data and swap data
  // smi_size represents both size of atm_cmp and swap data
  cmp_beat = (smi_addr[LINE_INDEX_H:LINE_INDEX_L]<smi_addr_swp[LINE_INDEX_H:LINE_INDEX_L])? 0 : (smi_addr[LINE_INDEX_H:LINE_INDEX_L]-smi_addr_swp[LINE_INDEX_H:LINE_INDEX_L]);
  swp_beat = (smi_addr_swp[LINE_INDEX_H:LINE_INDEX_L]<smi_addr[LINE_INDEX_H:LINE_INDEX_L])? 0 : (smi_addr_swp[LINE_INDEX_H:LINE_INDEX_L]-smi_addr[LINE_INDEX_H:LINE_INDEX_L]);
  byte_addr = 'h0;
  byte_en = txn.dtw_req_pkt.smi_dp_be[0];
  if(atm_swp || atm_cmp) begin
    foreach(swp_data[i])begin
      swp_data[i] = 'h0;
      byte_en = txn.dtw_req_pkt.smi_dp_be[i];
      // TODO: for num_bytes=8 bytes each of atm_cmp and swap data
      for(int id = 0; id < num_bytes; id++) begin
        if(atm_cmp)begin
          byte_addr_swp = smi_addr_swp[LINE_INDEX_L-1:0]  + id;
          byte_addr     = smi_addr[LINE_INDEX_L-1:0]  + id;
        end 
        else begin
          byte_addr = smi_addr[LINE_INDEX_L-1:0]  + id;
          byte_addr_swp = byte_addr;
        end
        if(byte_en[byte_addr])begin
          swp_data[i][byte_addr*8+:8] = txn.dtw_req_pkt.smi_dp_data[swp_beat][byte_addr_swp*8+:8];
          `uvm_info("<%=obj.BlockId%>:process_atomic_op", $sformatf("swp_data[%0d] = %0h",i,swp_data[i]), UVM_MEDIUM)
        end
      end
      `uvm_info("<%=obj.BlockId%>:process_atomic_op", $sformatf("swp_data[%0d] = %0h byte_en :%0x",i, swp_data[i],byte_en), UVM_MEDIUM)
    end
  end
  //#Check.DMI.Concerto.v3.0.AtomicAddrDataAlignment
  if(atm_cmp) begin
    // TODO: for num_bytes=8 bytes each of atm_cmp and swap data
    foreach(cmp_data[i])begin
      byte_en = txn.dtw_req_pkt.smi_dp_be[i];
      cmp_data[i] = 'h0;
      byte_addr[i]  = 'h0;
      for(int id = 0; id < num_bytes; id++) begin
        byte_addr = smi_addr[LINE_INDEX_L-1:0]  + id;
        if(byte_en[byte_addr])begin
          cmp_data[i][byte_addr*8+:8] = txn.dtw_req_pkt.smi_dp_data[cmp_beat][byte_addr*8+:8];
        end
        `uvm_info("<%=obj.BlockId%>:process_atomic_op", $sformatf("cmp_data[%0d] = %0h", i, cmp_data[i]), UVM_MEDIUM)
      end
    end
  end

  s_data = 'h0;
  byte_addr = 'h0;
  for(int id = 0; id < num_bytes; id++) begin
    byte_addr = smi_addr[LINE_INDEX_L-1:0] + id;
    if(byte_en[byte_addr])begin
      s_data[byte_addr*8+:8] = txn.dtw_req_pkt.smi_dp_data[0][byte_addr*8+:8];
      `uvm_info("<%=obj.BlockId%>:process_atomic_op", $sformatf("byte_en[%0d]:%0b,s_data[%0d] = %0h",byte_addr,byte_en[byte_addr], byte_addr, s_data[byte_addr*8+:8]), UVM_MEDIUM)
    end
  end

  m_data = 'h0;
  byte_addr = 'h0;
  for(int id = 0; id < num_bytes; id++) begin
    byte_addr = smi_addr[LINE_INDEX_L-1:0] + id;
    m_data[byte_addr*8+:8] =
    txn.sp_txn ? txn.m_sp_rd_data_pkt.data[0][byte_addr*8+:8] :
    (txn.isCacheHit ?
     txn.cache_rd_data_pkt.data[0][byte_addr*8+:8] :
     txn.axi_read_data_pkt.rdata[0][byte_addr*8+:8]);
    `uvm_info("<%=obj.BlockId%>:process_atomic_op", $sformatf("m_data[%0d] = %0h", id, m_data[byte_addr*8+:8]), UVM_MEDIUM)
  end

  if(atm_cmp) begin
    foreach(cmp_data[i])begin
      m_cmp_data[i] = 'h0;
      byte_addr[i]  = 'h0;
      for(int id = 0; id < num_bytes; id++) begin
        byte_addr = smi_addr[LINE_INDEX_L-1:0] + id;
        m_cmp_data[i][byte_addr*8+:8] =
        txn.sp_txn ? txn.m_sp_rd_data_pkt.data[i][byte_addr*8+:8] :
        (txn.isCacheHit ?
         txn.cache_rd_data_pkt.data[i][byte_addr*8+:8] :
         txn.axi_read_data_pkt.rdata[i][byte_addr*8+:8]);
      end
      `uvm_info("<%=obj.BlockId%>:process_atomic_op", $sformatf("m_cmp_data[%0d] = %0h", i, m_cmp_data[i]), UVM_MEDIUM)
    end
  end

  foreach(txn.dtw_req_pkt.smi_dp_dbad[i]) begin
    if(txn.dtw_req_pkt.smi_dp_dbad[i] != 0)  begin 
        o_data_dbad[i] = 1;
    end
  end

  upd_cache_on_hit = 1'b1;
  swp_flag = 1;
  if(atm_swp) begin
    o_data[0] = swp_data[0];
  end
  else if(atm_cmp) begin
    txn.isAtomicCmp_match = 1;
    foreach(cmp_data[i])begin
      if(m_cmp_data[i] != cmp_data[i])begin
        `uvm_info("<%=obj.BlockId%>:process_atomic_op", $sformatf("m_cmp_data[%0d] = %0h cmp_data[%0d] = %0h", i, m_cmp_data[i], i, cmp_data[i]), UVM_DEBUG)
        swp_flag = 0;
        upd_cache_on_hit = 1'b0;
        txn.isAtomicCmp_match = 0;
      end
    end
    `uvm_info("<%=obj.BlockId%>:process_atomic_op", $sformatf("Atomic Compare Match:%0d", txn.isAtomicCmp_match),UVM_DEBUG)
    foreach(cmp_data[i])begin
      o_data[i] = !swp_flag ? m_cmp_data[i] : swp_data[i];
    end
    <% if(obj.DmiInfo[obj.Id].useAtomic) { %>    
    `ifndef FSYS_COVER_ON
      cov.collect_atomic_rw_semantics(txn.smi_msg_type, 0, swp_flag);
    `endif
    <% } %>
  end
  else if(atm_ld || atm_str) begin
    byte_addr = smi_addr[LINE_INDEX_L-1:0] ;
    s_data_tmp = s_data <<(WSMIDPBE - num_bytes -  byte_addr )*8;
    m_data_tmp = m_data <<(WSMIDPBE - num_bytes -  byte_addr )*8;
    case(opcode)
      0: o_data[0] = m_data +  s_data;
      1: o_data[0] = m_data & ~s_data;
      2: o_data[0] = m_data ^  s_data;
      3: o_data[0] = m_data |  s_data;
      4: begin
           o_data[0] = ($signed(s_data_tmp) > $signed(m_data_tmp)) ? s_data : m_data;
           upd_cache_on_hit = ($signed(s_data_tmp) > $signed(m_data_tmp)) ? 1'b1 : 1'b0;
         end
      5: begin
           o_data[0] = ($signed(s_data_tmp) < $signed(m_data_tmp)) ? s_data : m_data;
           upd_cache_on_hit = ($signed(s_data_tmp) < $signed(m_data_tmp)) ? 1'b1 : 1'b0;
         end
      6: begin
           o_data[0] = (s_data > m_data) ? s_data : m_data;
           upd_cache_on_hit = (s_data > m_data) ? 1'b1 : 1'b0;
         end
      7: begin
           o_data[0] = (s_data < m_data) ? s_data : m_data;
           upd_cache_on_hit = (s_data < m_data) ? 1'b1 : 1'b0;
         end
    endcase
    `uvm_info("<%=obj.BlockId%>:process_atomic_op", $sformatf("Is Atomic %0s with upd_cache_on_hit:%0b", (atm_ld ? "LOAD" :"STORE"),upd_cache_on_hit),UVM_HIGH)
    <% if(obj.DmiInfo[obj.Id].useAtomic) { %>    
    `ifndef FSYS_COVER_ON
      cov.collect_atomic_rw_semantics(txn.smi_msg_type, opcode, upd_cache_on_hit);
    `endif
    <% } %>
  end

  foreach(o_data[i])begin
    `uvm_info("<%=obj.BlockId%>:process_atomic_op", $sformatf("o_data[%0d] = %0h",i, o_data[i]), UVM_MEDIUM)
  end

  // TODO beatn, beatnExp - both txn and cache_fill_data_pkt_exp have this
  // if cache hit, it is partially updated only when there is txn_data
  // if cache miss, it is fully updated always
  beatn = smi_addr[LINE_INDEX_H:LINE_INDEX_L]; // assuming single beat
  byte_addr = 'h0;
  txn.fillExpd = 1'b0;
  txn.fillDataExpd = 1'b0;
  //#Check.DMI.Concerto.v3.0.AtomcHit
  if(txn.isCacheHit || txn.sp_txn) begin
    // Partial update
    if(txn.sp_txn == 1'b0) begin
      if(upd_cache_on_hit == 1'b1) begin
        `uvm_info("<%=obj.BlockId%>:process_atomic_op", $sformatf("Registered Atomic Cache Hit for non-SP"),UVM_HIGH)
        txn.fillExpd = 1'b1;
        txn.fillDataExpd = 1'b1;
        ->ccp_atm_fill_raise;
        txn.beatnExp = beatn;
        for(int i = 0;i<txn.cache_rd_data_pkt.data.size();i++)begin
         txn.cache_fill_data_pkt_exp.beatn[i]    = beatn;
         txn.cache_fill_data_pkt_exp.data[i]     = txn.cache_rd_data_pkt.data[i];
         txn.cache_fill_data_pkt_exp.byten[i]    = Expd_byte_en;
         if(i < o_data.size())begin
            txn.cache_fill_data_pkt_exp.poison[i] |= o_data_dbad[i] | txn.cache_rd_data_pkt.poison[i];
            for(int id = 0; id < num_bytes; id++) begin
              byte_addr = smi_addr[LINE_INDEX_L-1:0]  + id;
              txn.cache_fill_data_pkt_exp.data[i][byte_addr*8+:8] = o_data[i][byte_addr*8+:8];
              `uvm_info("<%=obj.BlockId%>:process_atomic_op", $sformatf("txn.cache_fill_data_pkt_exp.data[%0d] = %0h Poison = %0h",
                                                                        i,txn.cache_fill_data_pkt_exp.data[i],txn.cache_fill_data_pkt_exp.poison[i]), UVM_MEDIUM)
            end
            beatn = beatn+1;
          end
        end
      end
      txn.fillwayn                     = onehot_to_binary(txn.cache_ctrl_pkt.hitwayn);
      txn.cache_fill_ctrl_pkt_exp.wayn = onehot_to_binary(txn.cache_ctrl_pkt.hitwayn);
    end 
    else begin
      // Scratchpad transactions also come under Hit category
      if(upd_cache_on_hit == 1'b1) begin
        // For Scratchpad, no fill control packet CONC-4437
        // TODO: poison bit should be set high in case atomic read is poisoned
        `uvm_info("<%=obj.BlockId%>:process_atomic_op", $sformatf("Registered Atomic Cache Hit for SP"),UVM_HIGH)
        txn.fillExpd = 1'b0;
        txn.fillDataExpd = 1'b1;
        ->ccp_atm_fill_raise;
        txn.beatnExp = beatn;
        for(int i = 0;i<txn.m_sp_rd_data_pkt.data.size();i++)begin
         txn.cache_fill_data_pkt_exp.beatn[i] = beatn;
         txn.cache_fill_data_pkt_exp.data[i]  = txn.m_sp_rd_data_pkt.data[i];
         txn.cache_fill_data_pkt_exp.byten[i] = Expd_byte_en;
         if(i < o_data.size())begin
            txn.cache_fill_data_pkt_exp.poison[i] |= o_data_dbad[i] | txn.m_sp_rd_data_pkt.poison[i];
            for(int id = 0; id < num_bytes; id++) begin
              byte_addr = smi_addr[LINE_INDEX_L-1:0]  + id;
              txn.cache_fill_data_pkt_exp.data[i][byte_addr*8+:8] = o_data[i][byte_addr*8+:8];
              `uvm_info("<%=obj.BlockId%>:process_atomic_op", $sformatf("txn.cache_fill_data_pkt_exp.data[%0d] = %0h  Poison = %0h",
                                                                        i,txn.cache_fill_data_pkt_exp.data[i],txn.cache_fill_data_pkt_exp.poison[i]), UVM_MEDIUM)
            end
            beatn = beatn+1;
          end
        end
      end
    end
  end
  else begin
    //#Check.DMI.Concerto.v3.0.AtomcMiss
    // if it is miss, it is always write and full cache write
    txn.fillExpd = 1'b1;
    txn.fillDataExpd = 1'b1;
    txn.beatnExp = beatn;
    `uvm_info("<%=obj.BlockId%>:process_atomic_op", $sformatf("Registered Atomic Miss"),UVM_HIGH)
    // TODO: confirm what to write in remaining bytes
    txn.cache_fill_data_pkt_exp.data   = new[BURSTLN];
    txn.cache_fill_data_pkt_exp.beatn  = new[BURSTLN];
    txn.cache_fill_data_pkt_exp.byten  = new[BURSTLN];
    txn.cache_fill_data_pkt_exp.poison = new[BURSTLN];
    for(int i = 0;i<txn.axi_read_data_pkt.rdata.size();i++)begin
      txn.cache_fill_data_pkt_exp.beatn[i] = beatn;
      txn.cache_fill_data_pkt_exp.data[i]  = txn.axi_read_data_pkt.rdata[i];
      txn.cache_fill_data_pkt_exp.byten[i] = Expd_byte_en;
      if((txn.axi_read_data_pkt.rresp_per_beat[i] !== 0) || ( txn.dtw_req_pkt.smi_dp_dbad.or() && i==0)) begin
        if(txn.dtw_req_pkt.smi_dp_dbad.or() && i==0) begin
          `uvm_info("<%=obj.BlockId%>:process_atomic_op", $sformatf("CONC-15324::txn.cache_fill_data_pkt_exp.data[%0d]= Dtw Dbad:%0p", i, txn.cache_fill_data_pkt_exp.poison[i], txn.dtw_req_pkt.smi_dp_dbad),UVM_DEBUG)
        end
        txn.cache_fill_data_pkt_exp.poison[i] = 1;
      end else begin
        txn.cache_fill_data_pkt_exp.poison[i] = 0;
      end
      if(i < o_data.size())begin
        for(int id = 0; id < num_bytes; id++) begin
          byte_addr = smi_addr[LINE_INDEX_L-1:0]  + id;
          txn.cache_fill_data_pkt_exp.data[i][byte_addr*8+:8] = o_data[i][byte_addr*8+:8]; 
          txn.cache_fill_data_pkt_exp.poison[i] |= o_data_dbad[i];
          `uvm_info("<%=obj.BlockId%>:process_atomic_op", $sformatf("txn.cache_fill_data_pkt_exp.data[%0d] = %0h Poison = %0h",
                                                                      i,txn.cache_fill_data_pkt_exp.data[i],txn.cache_fill_data_pkt_exp.poison[i]), UVM_MEDIUM)
        end
      end
      beatn = beatn+1;
    end
    txn.fillwayn                     = txn.cache_ctrl_pkt.wayn;
    txn.cache_fill_ctrl_pkt_exp.wayn = txn.cache_ctrl_pkt.wayn;
  end
  //#Check.DMI.Concerto.v3.0.AtomicNonSPAllwayResSP
  <% if(obj.useCmc && obj.DmiInfo[obj.Id].ccpParams.useScratchpad){%>
  if(txn.sp_txn && txn.sp_seen_output_chnl) begin
    if(txn.fillDataExpd == 0) txn.sp_atomic_wr_pending = 0;
    else processSPCtrlWr(txn);
  end
  <%}%>

  `uvm_info("<%=obj.BlockId%>:process_atomic_op",
            $sformatf("txn.cache_fill_data_pkt_exp = %p",
                      txn.cache_fill_data_pkt_exp), UVM_MEDIUM)

  txn.cache_fill_ctrl_pkt_exp.addr = txn.cache_addr;
  txn.cache_fill_ctrl_pkt_exp.security = txn.security;
  if(upd_cache_on_hit)begin
    txn.cache_fill_ctrl_pkt_exp.state = UD;
  end
  else begin
    txn.cache_fill_ctrl_pkt_exp.state = SC;
  end
  txn.gen_exp_smi__dtr_req(.m_size(numbeat),.assign_data(0)); //Initialize expected DTR packet 
  foreach(o_data[i])begin
    for(int id = 0; id < num_bytes; id++) begin
       byte_addr = smi_addr[LINE_INDEX_L-1:0]  + id;
       if(atm_cmp)begin
         txn.dtr_req_pkt_exp.smi_dp_data[i][byte_addr*8+:8] = m_cmp_data[i][byte_addr*8+:8];
       end
       else begin
         txn.dtr_req_pkt_exp.smi_dp_data[i][byte_addr*8+:8] = m_data[byte_addr*8+:8];
       end
       txn.dtr_req_pkt_exp.smi_dp_be[i][byte_addr]    = 1;
       txn.DtrRdy    = 1;
     end
  end
  //#Check.DMI.Concerto.v3.0.NoDtrAtomicStore
  if(!atm_str) txn.DTR_req_expd = 1'b1;

  txn.isAtomicProcessed   = 1'b1;

  if(txn.fillExpd && txn.fillSeen)begin
     if(!(txn.cache_fill_ctrl_pkt_exp.do_compare_pkts(txn.cache_fill_ctrl_pkt)))begin
        print_rtt_q();
        `uvm_info("<%=obj.BlockId%>:process_atomic_op", $sformatf("cache_fill_ctrl_pkt_exp: %1p",
                                                                       txn.cache_fill_ctrl_pkt_exp), UVM_LOW)
        
        `uvm_info("<%=obj.BlockId%>:process_atomic_op", $sformatf("cache_fill_ctrl_pkt_pkt: %1p",
                                                                       txn.cache_fill_ctrl_pkt), UVM_LOW)

        `uvm_error("<%=obj.BlockId%>:process_atomic_op","fill pkt not matching")
     end
    updateRttentry(txn,idx);
  end

  if(txn.fillDataExpd && txn.fillDataSeen)begin
    if(!txn.cache_fill_data_pkt_exp.do_compare_data(txn.cache_fill_data_pkt))begin
      `uvm_info("<%=obj.BlockId%>:process_atomic_op", $sformatf("cache_fill_data_pkt_exp: %1p",
                                                                     txn.cache_fill_data_pkt_exp), UVM_LOW)
      
      `uvm_info("<%=obj.BlockId%>:process_atomic_op", $sformatf("cache_fill_data_pkt_pkt: %1p",
                                                                         txn.cache_fill_data_pkt), UVM_LOW)
      `uvm_error("<%=obj.BlockId%>:process_atomic_op",$sformatf("fill data compare failed"))
    end
    updateRttentry(txn,idx);
     ->ccp_atm_fill_drop;
  end

  if(txn.DtrRdy)begin
    rearrangedtrdata(txn);
  end
  `uvm_info("<%=obj.BlockId%>:process_atomic_op", $sformatf("atm_str = %0d ; atm_ld = %0d ; opcode = %0d",
                                           atm_str, atm_ld, opcode), UVM_MEDIUM)
  `uvm_info("<%=obj.BlockId%>:process_atomic_op", $sformatf("atm_cmp = %0d ; atm_swp = %0d",
                                           atm_cmp, atm_swp), UVM_MEDIUM)

  `uvm_info("<%=obj.BlockId%>:process_atomic_op", $sformatf("isCacheHit = %0d", txn.isCacheHit), UVM_MEDIUM)

  `uvm_info("<%=obj.BlockId%>:process_atomic_op", $sformatf("fillExpd = %0d ; fillDataExpd = %0d",
                                           txn.fillExpd, txn.fillDataExpd), UVM_MEDIUM)
  `uvm_info("<%=obj.BlockId%>:process_atomic_op", $sformatf("AXI_read_data_expd = %0d", txn.AXI_read_data_expd), UVM_MEDIUM)
  `uvm_info("<%=obj.BlockId%>:process_atomic_op", $sformatf("DTR_req_expd = %0d", txn.DTR_req_expd), UVM_MEDIUM)

endfunction // process_atomic_op

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Scoreboard to keep track of busy way
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function void dmi_scoreboard::update_index_way(dmi_fill_addr_inflight_t filldone_pkt, bit set_flg);
  int bwy_idx_q[$];
  int done_idx;
  ccp_ctrlop_waybusy_vec_t tmp_way;
  dmi_busy_index_way_t           busy_index_way_pkt;
  done_idx =  ncoreConfigInfo::get_set_index(filldone_pkt.addr,<%=obj.DmiInfo[obj.Id].FUnitId%>);
  bwy_idx_q = {};
  bwy_idx_q = busy_index_way_q.find_index() with (item.indx == done_idx); 

  <%if(obj.DmiInfo[obj.Id].ccpParams.nWays >1) {  %>
  if(!set_flg) begin
    if(!bwy_idx_q.size()) begin
      //`uvm_error("<%=obj.BlockId%>","update_index_way: unexpected cache_fill_addr generated")   
    end else begin
       tmp_way = busy_index_way_q[bwy_idx_q[0]].wayn;
       tmp_way[filldone_pkt.wayn] = set_flg;
       busy_index_way_q[bwy_idx_q[0]].wayn = tmp_way; 
    end 
  end else begin
    if(!bwy_idx_q.size()) begin
      busy_index_way_pkt.indx = done_idx;
      busy_index_way_pkt.wayn[filldone_pkt.wayn] = set_flg;  
      busy_index_way_q.push_back(busy_index_way_pkt);
    end else begin
       busy_index_way_q[bwy_idx_q[0]].wayn[filldone_pkt.wayn] = set_flg; 
    end 
  end
  <% } else { %>
  if(!set_flg) begin
    if(!bwy_idx_q.size()) begin
      //`uvm_error("<%=obj.BlockId%>","update_index_way: unexpected cache_fill_addr generated")   
    end else begin
       busy_index_way_q[bwy_idx_q[0]].wayn = set_flg; 
    end 
  end else begin
    if(!bwy_idx_q.size()) begin
      busy_index_way_pkt.indx = done_idx;
      busy_index_way_pkt.wayn = set_flg;  
      busy_index_way_q.push_back(busy_index_way_pkt);
    end else begin
       busy_index_way_q[bwy_idx_q[0]].wayn = set_flg; 
    end 
  end
  <% } %>
  `uvm_info("<%=obj.BlockId%>: update_index_way",$sformatf("done_idx :%0d addr :%0x set_flg :%0b wayn:%0b",done_idx,filldone_pkt.addr,set_flg,busy_index_way_q[bwy_idx_q[0]].wayn),UVM_MEDIUM);
endfunction:update_index_way
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// function to get busy way
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function  ccp_ctrlop_waybusy_vec_t dmi_scoreboard::get_busy_way(ccp_ctrlop_addr_t addr);  
   int bwy_idx_q0[$];
   int idx;
   dmi_busy_index_way_t           item;
   ccp_ctrlop_waybusy_vec_t tmp_way;
   idx =  ncoreConfigInfo::get_set_index(addr,<%=obj.DmiInfo[obj.Id].FUnitId%>);
   bwy_idx_q0 = {};
   bwy_idx_q0 = busy_index_way_q.find_index() with (item.indx == idx); 
   if(!bwy_idx_q0.size()) begin
     tmp_way = 0;
   end else begin
     tmp_way = busy_index_way_q[bwy_idx_q0[0]].wayn;
   end
  `uvm_info("<%=obj.BlockId%>:get_busy_way",$sformatf("addr :%0x index :%0d busyway :%0b",addr,idx,tmp_way),UVM_MEDIUM);
  return(tmp_way);
endfunction:get_busy_way

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Function to convert one-hot vector to int 
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function bit [N_WAY-1:0] dmi_scoreboard::onehot_to_binary(bit [N_WAY-1:0] in_word);
  bit [N_WAY-1:0] position;
  position = '1;
  for(int i=0; i<$size(in_word); i++) begin
      if(in_word[i] == 1) begin
          position = i;
          break;
      end
  end
  return position;
endfunction

function int dmi_scoreboard::calBurstLength(dmi_scb_txn sb_entry);
  int burst_length;
  burst_length = (sb_entry.smi_msg_type == CMD_CMP_ATM) ?
                 (((2**(sb_entry.smi_size-1))*8)/WCCPDATA):
                 (((2**sb_entry.smi_size)*8)/WCCPDATA);
  if (burst_length == 0) burst_length = 1;
  return burst_length;
endfunction

function int dmi_scoreboard::isWeirdWrap(dmi_scb_txn sb_entry);
  smi_addr_t addr;
  int no_of_bytes;
  int dt_size;
  int burst_length;
  longint m_lower_wrapped_boundary;
  longint m_upper_wrapped_boundary;
  longint m_start_addr;
  bit weird_wrap;

  no_of_bytes              = (WCCPDATA/8);
  burst_length             = calBurstLength(sb_entry);
  addr                     = sb_entry.cache_addr;
  dt_size                  = no_of_bytes * burst_length;
  m_start_addr             = (addr/(no_of_bytes)) * (no_of_bytes);
  m_lower_wrapped_boundary = (addr/(no_of_bytes * burst_length)) * (no_of_bytes*burst_length);
  if((sb_entry.smi_burst == 'h0) && (dt_size < SYS_nSysCacheline) &&  (m_lower_wrapped_boundary < m_start_addr)) begin
    weird_wrap = 1;
  end
    return weird_wrap;
endfunction
<% } %>
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function smi_addr_t dmi_scoreboard::axi4_addr_trans_addr( smi_addr_t smi_addr );
  bit found;
  smi_addr_t adjusted_smi_addr, adjusted_from_addr, adjusted_to_addr, adjusted_smi_to_addr;
  bit transV;
  bit [3:0] mask;
  int idx;
  found = 0;
  <% if ( (obj.DmiInfo[obj.Id].nAddrTransRegisters > 0) && (obj.testBench != "fsys") ) { %>
  for (int i=0; i < <%=obj.DmiInfo[obj.Id].nAddrTransRegisters%>; i++) begin
    //#Check.DMI.Concerto.v3.0.AddressTranlation
    transV               = (addrTransV[i] >> 31);            
    //#Cover.DMI.Concerto.v3.0.AddressTranlationMaskbit
    mask                 = (addrTransV[i] & 4'hf);
    adjusted_smi_addr    = (smi_addr >> (20 + mask));
    adjusted_from_addr   = (addrTransFrom[i] >> mask);
    adjusted_to_addr     = ((addrTransTo[i] >> mask) << (20+mask));
    adjusted_smi_to_addr = (smi_addr & ((1<<(20+mask))-1));
    //#Cover.DMI.Concerto.v3.0.AddressTranlationFAR
    if (transV && (adjusted_smi_addr == adjusted_from_addr)) begin
       axi4_addr_trans_addr = (((addrTransTo[i] >> mask) << (20+mask)) | (smi_addr & ((1 << (20+mask))-1)));
       axi4_addr_trans_addr &= ((1 << WAXADDR)-1);
       `uvm_info($sformatf("%m"), $sformatf("AddrTrans: i=%0d V=%0h from=%08h (adjusted=%08h) to=%08h (adjusted=%08h) smi_addr=%p (adjusted=%08h) new smi_addr=%08h",
                                            i,addrTransV[i],addrTransFrom[i],adjusted_from_addr,
                                            addrTransTo[i],adjusted_to_addr,smi_addr,adjusted_smi_addr,adjusted_to_addr|adjusted_smi_to_addr), UVM_LOW)
      idx = i;
      found = 1;
      break;
    end else begin
      `uvm_info($sformatf("%m"), $sformatf("AddrTrans:Not found yet interation%0d V=%0d smi_addr adj=%p from_addr_adj=%p", i,transV,adjusted_smi_addr,adjusted_from_addr), UVM_LOW)
    end
  end
  `ifndef FSYS_COVER_ON
  cov.collect_addrtrans_pkt(addrTransV, mask, found, idx);
  `endif
  <% } %>
  if(found == 0) begin
    axi4_addr_trans_addr = smi_addr;
    <% if ( (obj.DmiInfo[obj.Id].nAddrTransRegisters > 0) && (obj.testBench != "fsys") ) { %>
    `uvm_info($sformatf("%m"), $sformatf("AddrTrans: No translation is performed"), UVM_LOW)
    `uvm_info("AddrTrans", $sformatf("ATEV:%p, ATEFR:%p, ATET %p; smi_addr:%p", addrTransV, addrTransFrom,
                                     addrTransTo, smi_addr), UVM_HIGH)
    <% } %>
  end
endfunction : axi4_addr_trans_addr//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

function void dmi_scoreboard::update_resiliency_ce_cnt(const ref smi_seq_item m_item);
  <% if ((obj.useResiliency) && (obj.testBench != "fsys")) { %>
  int tmp_dp_corr_error;
  string func_s = "update_resiliency_ce_cnt";

  `uvm_info({func_s}, $sformatf("time1 new=%0t, old=%0t", res_smi_pkt_time_new, res_smi_pkt_time_old), UVM_DEBUG);
  res_smi_pkt_time_new = $realtime;
  if(res_smi_pkt_time_new != res_smi_pkt_time_old) begin
    // get error statistics
    if(m_item.ndp_corr_error || m_item.hdr_corr_error || m_item.dp_corr_error_eb) begin
      res_smi_corr_err++;
      if(m_item.dp_corr_error_eb) begin
        res_smi_corr_err = res_smi_corr_err + (m_item.dp_corr_error_eb-1);
        res_mod_dp_corr_error = m_item.dp_corr_error_eb;
        `uvm_info({func_s}, $sformatf("(if/if)tmp_dp_corr_error=%0d, this.res_mod_dp_corr_error=%0d", tmp_dp_corr_error, this.res_mod_dp_corr_error), UVM_DEBUG);
      end
      res_is_pre_err_pkt = 1'b1;
      `uvm_info({func_s}, $sformatf("new smi_pkt(if). res_smi_corr_err=%0d, res_is_pre_err_pkt=%0d", res_smi_corr_err, res_is_pre_err_pkt), UVM_DEBUG);
    end
    else begin
      res_is_pre_err_pkt = 1'b0;
    end
    `uvm_info({func_s}, $sformatf("time2 new=%0t, old=%0t", res_smi_pkt_time_new, res_smi_pkt_time_old), UVM_DEBUG);
  end
  else begin
    if(res_is_pre_err_pkt) begin
      if(m_item.dp_corr_error_eb) begin
        tmp_dp_corr_error = m_item.dp_corr_error_eb - this.res_mod_dp_corr_error;
        if(tmp_dp_corr_error < 0)
          tmp_dp_corr_error = 1'b0;
        else
          this.res_mod_dp_corr_error = this.res_mod_dp_corr_error + tmp_dp_corr_error;
        `uvm_info({func_s}, $sformatf("(else/if)tmp_dp_corr_error=%0d, this.res_mod_dp_corr_error=%0d", tmp_dp_corr_error, this.res_mod_dp_corr_error), UVM_DEBUG);
        res_smi_corr_err = res_smi_corr_err + tmp_dp_corr_error;
      end
      `uvm_info({func_s}, $sformatf("new smi_pkt(else/if). res_smi_corr_err=%0d, res_is_pre_err_pkt=%0d", res_smi_corr_err, res_is_pre_err_pkt), UVM_DEBUG);
    end
    else begin
      if(m_item.ndp_corr_error || m_item.hdr_corr_error || m_item.dp_corr_error_eb) begin
        res_smi_corr_err++;
        if(m_item.dp_corr_error_eb) begin
          res_smi_corr_err = res_smi_corr_err + (m_item.dp_corr_error_eb-1);
          res_mod_dp_corr_error = m_item.dp_corr_error_eb;
          `uvm_info({func_s}, $sformatf("(else/else)tmp_dp_corr_error=%0d, this.res_mod_dp_corr_error=%0d", tmp_dp_corr_error, this.res_mod_dp_corr_error), UVM_DEBUG);
        end
        res_is_pre_err_pkt = 1'b1;
      end
      `uvm_info({func_s}, $sformatf("new smi_pkt(else/else). res_smi_corr_err=%0d, res_is_pre_err_pkt=%0d", res_smi_corr_err, res_is_pre_err_pkt), UVM_DEBUG);
    end
    `uvm_info({func_s}, $sformatf("time3 new=%0t, old=%0t", res_smi_pkt_time_new, res_smi_pkt_time_old), UVM_DEBUG);
  end
  res_smi_pkt_time_old = res_smi_pkt_time_new;
  `uvm_info({func_s}, $sformatf("time4 new=%0t, old=%0t", res_smi_pkt_time_new, res_smi_pkt_time_old), UVM_DEBUG);
  <% } %>
endfunction : update_resiliency_ce_cnt

/////////////////////////////////////////////////////////////////////Prints End Of Test//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function void dmi_scoreboard::print_rtt_q();
  `uvm_info("<%=obj.BlockId%>:print_rtt_q", $sformatf("****************************Print contents of RTT queue**********************************************************************"), UVM_MEDIUM)
  if(rtt_q.size != 0) begin
    foreach (rtt_q[i]) begin
     `uvm_info("<%=obj.BlockId%>:print_rtt_q", $sformatf("*************************************************RTT[%0d]***************************************************",i), UVM_MEDIUM)
     rtt_q[i].print_entry();
    end
  end
  else begin
    `uvm_info("<%=obj.BlockId%>:print_rtt_q", $sformatf("RTT queue is empty"), UVM_MEDIUM)
  end
endfunction

function bit dmi_scoreboard::print_rtt_q_eos();
  `uvm_info("<%=obj.BlockId%>:print_rtt_q", $sformatf("============================================================================================================================"), UVM_NONE)
  `uvm_info("<%=obj.BlockId%>:print_rtt_q", $sformatf("Print contents of RTT queue"), UVM_NONE)
  `uvm_info("<%=obj.BlockId%>:print_rtt_q", $sformatf("numMrdTxns sent  :%0d numMrdCMOTxns :%0d numNcrdTxns :%0d numAtmLdTxns :%0d numAtmStoreTxns :%0d numDtwMrgMrd :%0d numDtrTxns recd :%0d",numMrdTxns,numMrdCMOTxns,numNcrdTxns,numAtmLdTxns,numAtmStoreTxns,numDtwMrgMrdTxns,numDtrTxns), UVM_NONE)
  `uvm_info("<%=obj.BlockId%>:print_rtt_q", $sformatf("obj_fillcnt  :%0d obj_axirdcnt :%0d obj_axiwrcnt :%0d  obj_mntopcnt %0d",obj_fillcnt,obj_axirdcnt,obj_axiwrcnt, obj_mntopcnt), UVM_NONE)
  if(rtt_q.size != 0) begin
    foreach (rtt_q[i]) begin
      if(!((rtt_q[i].isCmdPref && rtt_q[i].CMD_rsp_recd && rtt_q[i].STR_req_recd && rtt_q[i].STR_rsp_recd)))begin
        `uvm_info("<%=obj.BlockId%>:print_rtt_q", $sformatf("*************************************************RTT_Q[%0d]***************************************************",i), UVM_LOW)
        rtt_q[i].print_entry_eos();
      end
    end
    return 1;
  end
  else begin
    `uvm_info("<%=obj.BlockId%>:print_rtt_q", $sformatf("RTT queue is empty"), UVM_NONE)
    return 0;
  end
endfunction

function void dmi_scoreboard::print_wtt_q();
  `uvm_info("<%=obj.BlockId%>:print_wtt_q", $sformatf("Print contents of wtt queue"), UVM_MEDIUM)
  if(wtt_q.size != 0) begin
    foreach (wtt_q[i]) begin
      `uvm_info("<%=obj.BlockId%>:print_wtt_q", $sformatf("*************************************************WTT[%0d]*****************************************************",i), UVM_MEDIUM)
      wtt_q[i].print_entry();
    end
  end
  else begin
    `uvm_info("<%=obj.BlockId%>:print_wtt_q", $sformatf("WTT queue is empty"), UVM_MEDIUM)
  end
endfunction

function bit dmi_scoreboard::print_wtt_q_eos();
  `uvm_info("<%=obj.BlockId%>:print_rtt_q", $sformatf("============================================================================================================================"), UVM_NONE)
  `uvm_info("<%=obj.BlockId%>:print_wtt_q", $sformatf("Print contents of wtt queue"), UVM_NONE)
  `uvm_info("<%=obj.BlockId%>:print_wtt_q", $sformatf("numDtwTxns sent  :%0d  numNcwrTxns :%0d ",numDtwTxns,numNcwrTxns), UVM_NONE)
  `uvm_info("<%=obj.BlockId%>:print_wtt_q", $sformatf("numRbrsReq sent  :%0d  numRbrlReq :%0d ",numRbrsReq,numRbrlReq), UVM_NONE)
  if (wtt_q.size != 0) begin
    foreach (wtt_q[i]) begin
      `uvm_info("<%=obj.BlockId%>:print_wtt_q", $sformatf("****************************************Print contents of WTT_Q[%0d]*********************************************",i), UVM_LOW)
      wtt_q[i].print_entry_eos();
    end
    return 1;
  end
  else begin
    `uvm_info("<%=obj.BlockId%>:print_wtt_q", $sformatf("wtt queue is empty"), UVM_NONE)
    return 0;
  end
endfunction
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Print contents of pending txns
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
function dmi_scoreboard::print_pending_txns(input bit trigger_from_error=0);
   bit [1:0] q_non_empty; // stores return value indicating pending transactions
  `uvm_info("<%=obj.BlockId%>_SB", $sformatf("Printing DMI  pending txn"), UVM_NONE)
  `uvm_info("<%=obj.BlockId%>_SB", $sformatf("fill raise cnt :%0d",obj_fillcnt), UVM_NONE)
  <% if (obj.testBench == "fsys") { %> 
  if(!trigger_from_error) begin
    clear_pending_rb_release();
  end
  <% } %>
  q_non_empty[0] = print_rtt_q_eos();
  q_non_empty[1] = print_wtt_q_eos();
  if(q_non_empty == 2'b0) return 0;
  else                    return 1;
endfunction

function dmi_scoreboard::enforce_unique_rbids();
  smi_rbid_t unique_rbid[*];

  foreach(wtt_q[i]) begin //Ensure RBID is unique
    if(unique_rbid.exists(wtt_q[i].smi_rbid[WSMIRBID-2:0])) begin
      print_wtt_q();
      `uvm_error("enforce_unique_rbids",$sformatf("DMI_UID:%0d RBID:%0h has multiple entries in the wtt_q",wtt_q[i].txn_id,wtt_q[i].smi_rbid[WSMIRBID-2:0]))
    end
    else if( !wtt_q[i].rb_is_done ) begin
      unique_rbid[wtt_q[i].smi_rbid[WSMIRBID-2:0]] = 1;
    end
  end
endfunction

function dmi_scoreboard::clear_pending_rb_release();
  //If the last RBReq to DMI on a RBID was a release then it will be pending
  enforce_unique_rbids();
  for(int i = (wtt_q.size()-1); i >= 0; i--) begin
    if((wtt_q[i].RB_req_expd  &&  wtt_q[i].RB_req_recd ) &&
       (wtt_q[i].RB_rsp_expd  && !wtt_q[i].RB_rsp_recd ) &&
       (wtt_q[i].DTW_req_expd && !wtt_q[i].DTW_rsp_recd)) begin
      `uvm_info("clear_pending_rb_release",$sformatf("DMI_UID:%0d Deleting WTT entry %0d",wtt_q[i].txn_id,i),UVM_LOW)
      wtt_q.delete(i);
    end
  end
endfunction
