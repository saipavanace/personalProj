`ifndef DMI_BASE_SEQ
`define DMI_BASE_SEQ
//////////////////////////////////////////////////////////////////////
//Thoughts on enhancements 
//Derived sequences from smi_seq_item for different CmdTypes 
  //  1. Should enable a more cleaner approach on randomization and enforcing rules
  //  2. Move all value setting per sequence item, this should make it more modular to control from a new seq/virtual sequence if needed
  //
//A better waiting mechanism
  //  1. Current wait for #10ns until a resource is available is blocking delay control and in general adding unwanted delays when the resource is already available
  //  2. Design a non-blocking wait mechanism that randomizes and injects the seqeuence item in a queue if readily available. 
  //  3. Remove everything that interrupts delay controlf from I/F. Control delays from SMI I/F and testlist instead
//Is Iterative choice the only option?
  //  1. Move back to back type case statetment with a for loop into a randomized queue of choices.
  //  2. Constrain this queue based on a granularity of 2->n to either mix or send back to back requests
  //  3. Layer the constraint, use the queue to dispatch a sequence of transactions. This way, avoid all the loop-y recalculation
//////////////////////////////////////////////////////////////////////
typedef uvm_sequence #(uvm_sequence_item) uvm_virtual_sequence;
typedef class dmi_base_seq;
<%  var ch_rbid  = obj.DmiInfo[obj.Id].cmpInfo.nDceRbEntries;
    var Nch_rbid = obj.DmiInfo[obj.Id].cmpInfo.nDmiRbEntries;
    var nDce     = obj.DceInfo.length;
%>

localparam int TRANS_ID_WIDTH  = <%=obj.DmiInfo[obj.Id].concParams.hdrParams.wMsgId%>;
localparam int MAX_TRANS_ID_Q  = (2**TRANS_ID_WIDTH)*<%=obj.DmiInfo[obj.Id].nAius%>;

localparam int nSysCacheline = 64; //TBD satya
localparam int nAius         = <%=obj.DmiInfo[obj.Id].nAius%>;  // TBD satya


<% if(obj.DutInfo.useCmc) { %>
 localparam CCP_SETS_MAX     = <%=obj.DmiInfo[obj.Id].ccpParams.nSets%>;
 localparam CCP_WAYS_MAX     = <%=obj.DmiInfo[obj.Id].ccpParams.nWays%>;
<% } %>



class dmi_base_seq extends uvm_sequence;

   `uvm_object_utils(dmi_base_seq);
   `uvm_declare_p_sequencer(smi_virtual_sequencer);

   dmi_env_config        m_cfg;
   smi_seq              m_smi_tx_cmd_req_seq;
   smi_seq              m_smi_tx_dtw_req_seq;
   smi_seq              m_smi_tx_rb_req_seq;
   smi_seq              m_smi_rx_dtr_req_seq;
   smi_seq              m_smi_rx_str_req_seq;
   smi_seq              m_smi_tx_rsp_seq;
   smi_seq              m_smi_rx_rsp_seq;
   bit [6:0]            random_cmstatus_error_payload;
   rand bit [3:0]       dmi_qos_th_val;
   int                  evict_addr_idx, sp_edges_idx;
   ncoreConfigInfo::addrq  evict_addr_q, sp_addr_edges_q;
   bit                  rb_release_scenario = 0;
   int                  numRbRsp, numDtwRsp;
   smi_dp_data_bit_t    nonrandom_DPdata;
   // control knobs for command selection based on specified weightage
   int agent_id = <%=obj.DmiInfo[obj.Id].FUnitId%>;
   int sp_ways;
   smi_addr_t k_sp_base_addr, k_sp_max_addr; //VIK SP FIXME
   bit clear_pending_rbs, conclude_sending_rbrelease;
    const int            m_weights_for_wt_pref_read[1] = {100};
<% if(obj.testBench == 'dmi' || (obj.testBench == "fsys")) { %>
   `ifndef VCS
    const t_minmax_range m_minmax_for_wt_pref_read[1]  = {{0,0}};
   `else // `ifndef VCS
    const t_minmax_range m_minmax_for_wt_pref_read[1]  = '{'{m_min_range:0,m_max_range:0}};
   `endif // `ifndef VCS ... `else ... 
<% } else {%>
    const t_minmax_range m_minmax_for_wt_pref_read[1]  = {{0,0}};
<% } %>
   common_knob_class wt_reuse_addr          = new ("wt_reuse_addr"         , this , m_weights_for_weight_knobs , m_minmax_for_weight_knobs);
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
   common_knob_class wt_dtw_intervention    = new("wt_dtw_intervention"    , this , m_weights_for_weight_knobs , m_minmax_for_weight_knobs);

   //  Atomic cmd wt
   common_knob_class wt_cmd_rd_atm          = new("wt_cmd_rd_atm"          , this , m_weights_for_weight_knobs , m_minmax_for_weight_knobs);
   common_knob_class wt_cmd_wr_atm          = new("wt_cmd_wr_atm"          , this , m_weights_for_weight_knobs , m_minmax_for_weight_knobs);
   common_knob_class wt_cmd_swap_atm        = new("wt_cmd_swap_atm"        , this , m_weights_for_weight_knobs , m_minmax_for_weight_knobs);
   common_knob_class wt_cmd_cmp_atm         = new("wt_cmd_cmp_atm"         , this , m_weights_for_weight_knobs , m_minmax_for_weight_knobs);
   common_knob_class wt_sp_addr_range       = new("wt_sp_addr_range"       , this , m_weights_for_weight_knobs , m_minmax_for_weight_knobs);
   common_knob_class wt_addr_reused_q       = new("wt_addr_reused_q"       , this , m_weights_for_weight_knobs , m_minmax_for_weight_knobs);

   uvm_event_pool ev_pool = uvm_event_pool::get_global_pool();
   uvm_event evt_start_dtws = ev_pool.get("evt_start_dtws");
   uvm_event evt_send_dtr_rsp = ev_pool.get("evt_send_dtr_rsp");
   uvm_event evt_assert_dtw_rsp_ready = ev_pool.get("evt_assert_dtw_rsp_ready");
   
   // Weight for High priority packets based on QOS threshold
   common_knob_class wt_dmi_qos_hp_pkt     = new("wt_dmi_qos_hp_pkt"       , this , m_weights_for_weight_knobs , m_minmax_for_weight_knobs);
   
   common_knob_class wt_coh_noncoh_addr_collision   = new("wt_coh_noncoh_addr_collision", this, m_weights_for_weight_knobs, m_minmax_for_weight_knobs);

    //weight of exclusive CMD 
    common_knob_class wt_cmd_exclusive      = new ("wt_cmd_exclusive"      , this , m_weights_for_weight_knobs , m_minmax_for_weight_knobs);
    common_knob_class wt_exclusive_sequence  = new ("wt_exclusive_sequence"      , this , m_weights_for_weight_knobs , m_minmax_for_weight_knobs);

   int   k_num_addr              = 1;
   int   k_num_cmd               = 1;

   int   n_pending_txn_mode      = 0; // functional coverage
   int   full_cl_writes_only     = 0; // throughput test

   int   k_back_to_back_types    = 999;
   int   k_back_to_back_chains   = 1;

   bit   k_force_allocate        = 0; 

   int   k_atomic_opcode         = 0;
   int   k_intfsize              = 8;
   bit   k_addr_trans_hit        = 0;
   bit   k_atomic_directed       = 0;

   int   use_last_dealloc        = 0;
   int   use_adj_addr            = 0;
   int   mrd_use_last_mrd_pref        = 0;
   bit   sp_enabled              = 0;

   int   tb_delay                = 0;

   int   k_min_reuse_q_size     = 2;
   int   k_max_reuse_q_size     = 20;
   int   k_reuse_q_pct          = 50;

   int   k_full_cl_only         = 0;
   int   k_force_size           = 0;
   int   k_force_mw             = 0;
   bit   fixed_set_flg          = 0;
   int   fset                   = 0;
   bit   addr_reused_flg        = 0;
   bit   random_addr_flg        = 0;
   bit   addr_reused_toggle_ns_flg = 0;
   bit   cache_warmup_flg       = 0;
   bit   mrd_pref_flg           = 0;
   bit   warmup_done            = 0;  

   bit   k_use_all_str_msg_id   = 0;

   int   slow                   = 1; // used to calculate drain time

   int   smi_txn_count          = 0; // use for delaying quit
   int   aiu_txn_count          = 0; // use for delaying quit

   int   addr_cnt               = 0;
   int   error_addr_cnt         = 0;
   bit   uncorr_error_test      = 0;
   bit   error_test_flg         = 0;
   bit   toggle_flg             = 0; 
   int   allowedIntfSize[<%=obj.DmiInfo[obj.Id].nAius%>];
   int   allowedIntfSizeActual[<%=obj.DmiInfo[obj.Id].nAius%>];
   int   dcefunitId[<%=nDce%>];
   int   Initiator_Intfsize;

   int   dmiTmBit4Smi0          = 0; // Parm to use for DMI SMI0
   int   dmiTmBit4Smi2          = 0; // Parm to use for DMI SMI2
   int   dmiTmBit4Smi3          = 0; // Parm to use for DMI SMI3

   // this is our table for AIU Txn IDs
   bit                         aiu_table [aiu_id_queue_t];
   bit                         aiu_table_nc [aiu_id_queue_t];
   //AIUmsgIDTableEntry_t        aiu_table_wr[<%=obj.DmiInfo[obj.Id].cmpInfo.nNcCmdInFlightToDmi%>*nAius];
   AIUmsgIDTableEntry_t        aiu_table_wr[<%=obj.DmiInfo[obj.Id].nCMDSkidBufSize%>*nAius];

   // similar table for SMI txns
   SMImsgIDTableEntry_t   smi_table [$]; 
   smi_msg_id_t           smi_msg_id; 

   axi_memory_model       m_axi_memory_model;
   //ace_cache_line_model   m_cache[$];
   bit                    primary;
   bit                    used_cohrbid_q[*];
   bit [<%=ch_rbid%>-1:0] gid0_rb_status, gid1_rb_status, gid_rb_status;
   typedef struct packed{
    smi_rbid_t rbid;
    smi_tm_t   tm;
   } rb_rl_t;
   rb_rl_t                rbid_release_q[$], tm_release_q[$];
   bit [63:0]             m_ort_addr_q[$];
   bit                    lookup_en;
   bit                    alloc_en;
   bit                    ClnWrAllocDisable;
   bit                    DtyWrAllocDisable;
   bit                    RdAllocDisable;
   bit                    WrAllocDisable;
   smi_type_t             smi_msg_type;

   MRDInfo_t              mrd_info[$]; // keep track of mrd related information
   NcRDInfo_t             NcRd_info[$]; // keep track of mrd related information
   AtmLoadInfo_t          AtmLd_info[$]; // keep track of NcLoad related information
   NcWRInfo_t             NcWr_info[$]; // keep track of mrd related information
   DTWInfo_t              dtw_info[$];
   AddrQ_t                reuseQ[$];

   MRDInfo_t              mrd_packet;
   DTWInfo_t              dtw_packet;
   NcRDInfo_t             ncrd_packet;
   AtmLoadInfo_t          AtmLd_packet;
   NcWRInfo_t             ncwr_packet;
   Addr_t                 cache_addr_list [$];
   Addr_t                 cache_addr_list_entry;

   event                  e_smi_cmd_req_q;
   event                  e_smi_dtw_req_q;
   event                  e_smi_rb_req_q;
   event                  e_smi_tx_rsp_q;
   event                  e_smi_rx_rsp_q;
   event                  e_smi_id_clean;
   event                  e_mrd_smi_id_clean;
   event                  e_aiusmi_id_clean;
   event                  e_aiusmi_id_clean_nc;
   smi_seq_item           m_smi_tx_cmd_req_q[$];
   smi_seq_item           m_smi_cmd_rsp_q[$];
   smi_seq_item           m_smi_tx_rb_req_q[$];
   smi_seq_item           m_smi_tx_dtw_req_q[$];
   smi_seq_item           m_smi_tx_dtw_req_2nd_q[$];
   smi_seq_item           m_smi_str_req_q[$];
   smi_seq_item           m_smi_rx_rsp_q[$];
   smi_seq_item           m_smi_dtwdbg_q[$];
   smi_sequencer          m_smi_seqr_rx_hash[string];
   smi_sequencer          m_smi_seqr_tx_hash[string];

   int                    mrd_in_flight_cnt;
   int                    Nctxns_in_flight;

   smi_addr_t             cache_addr_list_q[$], conc_15195_addr_q[$];
   Addr_t                 mrd_pref_addr_list_q[$];
   AIUID_t                req_aiu_id;

   smi_ncore_unit_id_bit_t home_dce_unit_id;
   int                     home_dmi_unit_id;
   smi_msg_id_bit_t        req_aiu_msg_id;

   MsgType_t             cmd_msg_type;
   MsgType_t             conc_15195_msgtype_q[$];

   smi_addr_t            lastHntAddr;
   smi_security_t        lastHntSec;
   smi_rbid_t            smi_rbid; 
   smi_tm_t              smi_tm;

   axi_awid_t           axi_axid;
   smi_addr_t           axi_width_mask;

    smi_qos_t           smi_qos_rb;
    
    smi_seq_item        m_str_rsp_q[$];
    smi_seq_item        m_str_rsp_delayed;

   int   timeout_count;
   bit [1:0]  this_type = 0;

   int   size_count;

   int   dtwmrgmrd_count = 16;
   int   dtw_count = <%=obj.DmiInfo[obj.Id].cmpInfo.nDceRbEntries%> + <%=obj.DmiInfo[obj.Id].cmpInfo.nDmiRbEntries%> + 1; //size of the fifo in dtw_rsp_mux plus one
   bit   first_dtw = 1;
   bit   buffer_on = 1;
   int   num_trigger;
   smi_seq_item     m_smi_rx_rsp_delayed_q[$];
   
   // Maybe deprecated
   int   num_cycles = nSysCacheline*8/(WDATA); // 4
   int   numDtwCycles ;
   int   numDtwCyclesSmi ;

   // For DTW WRAP addr alignment is to width
   // For DTW INCR addr alignment is 4 bytes
   int   clSizeInBytes = SYS_nSysCacheline;
   int   MINALIGN      =  <%=obj.DmiInfo[0].wData/8%>; // Addresses are 4 byte aligned
   int   INCRALIGN     = $clog2(MINALIGN);
   int   beatn;

   //int   MAX_MRD_IN_FLIGHT      = <%=obj.DmiInfo[obj.Id].cmpInfo.nMrdInFlight%>; //TBD satya
   int   MAX_MRD_IN_FLIGHT      = <%=obj.DmiInfo[obj.Id].nMrdSkidBufSize%>; //TBD satya
   //int   MAX_NCMSGID_IN_FLIGHT  = <%=obj.DmiInfo[obj.Id].cmpInfo.nNcCmdInFlightToDmi%> ;
   int   MAX_NCMSGID_IN_FLIGHT  = <%=obj.DmiInfo[obj.Id].nCMDSkidBufSize%> ;
   int   MAX_RBID_IN_FLIGHT     = <%=obj.DmiInfo[obj.Id].cmpInfo.nDceRbEntries%>;
   int   MAX_NCRBID_IN_FLIGHT   = <%=obj.DmiInfo[obj.Id].cmpInfo.nDmiRbEntries%>;
   int   WSTRREQMSGID           = <%=obj.DmiInfo[obj.Id].concParams.strReqParams.wMsgId%>;

    <% for (var i = 0; i < obj.nSmiTx; i++) { %>
        <% for (var j = 0; j < obj.DmiInfo[obj.Id].smiPortParams.tx[i].params.fnMsgClass.length; j++) { %>
            <% if(obj.DmiInfo[0].smiPortParams.tx[i].params.fnMsgClass[j] == "dtr_req_"){%>
   smi_ncore_port_id_bit_t       smi_dtr_ncore_port_id = <%=obj.DmiInfo[0].smiPortParams.tx[i].params.fPortId[j]%>;
            <% } %>
        <% } %>
    <% } %>

   int   strrsp_bp_count;
   int   index;
   bit   bw_test                = 0;
   bit   mrd_bwtest             = 0;
   bit   mrd_bw_flg             = 0;
   bit   perf_test_flg          = 0;
   bit   dtw_bw_flg             = 0;
   bit   smi_dtw_err            = 0;
   bit   force_alternate_be     = 0;
   bit   [2:0] msg_attr ;
   bit   uncorr_wrbuffer_err;
   bit   exclusive_flg          = 0;
   bit   mix_exclusives_flg     = 0;
   bit   pick_q;
   bit   k_sp_ns                = 0;
   bit   k_force_ns             = 0;
   bit   k_send_data_on_dtw_ptl = 0;
   bit   use_evict_addr_flg     = 0;
   bit   target_sp_addr_edges_flg = 0;
   bit   conc_15195_flg = 0;
   bit [($clog2(SYS_nSysCacheline)-1):0]        addr_offset_counter = 0;
   smi_size_t                                   size_counter = 0;
   smi_intfsize_t                               intfsize_counter = 0;
   bit                                          smi_mw;

   bit                                          single_step;
  
   //uvm_event_pool ev_pool = uvm_event_pool::get_global_pool();
   uvm_event inject_err = ev_pool.get("inject_err");
   uvm_event e_check_txnq_size = ev_pool.get("e_check_txnq_size");
   dmi_scoreboard                               m_scb;

<% if ((obj.DmiInfo[obj.Id].nAddrTransRegisters > 0) && (obj.testBench != 'fsys')) { %>
    static bit [31:0] addrTransV[4];
    static bit [31:0] addrTransFrom[4];
    static bit [31:0] addrTransTo[4];
<% } %>

   smi_addr_t             coh_noncoh_addr_collision_q [$];
     dmi_exclusive_c  exclusive_q[$];
   dmi_exclusive_c  load_exclusive_q[$];
   int exmon_size =  <%=obj.DmiInfo[obj.Id].nExclusiveEntries%>;
   extern function new(string name = "dmi_base_seq");
   extern function initialize();
   extern task body;
   extern virtual task disable_body;
   extern function process_AIUmsgIDs(smi_seq_item  m_pkt);
   extern function clean_AIUmsgIDs(aiu_id_queue_t aiu_queue_entry, bit Coh,bit isMrgMrd = 0);
   extern function clean_SMIMsgIDs(smi_seq_item  seq_item);
   extern function bit check_And_Set_TmBit(smi_seq_item req_item);
   extern function print_smi_table();
   extern function print_aiu_table();
   extern function print_mrd_info_q(bit debug = 1);
   extern function print_NcRd_info_q(bit debug = 1);
   extern function print_NcWr_info_q(bit debug = 1 );
   extern function print_AtmLd_info_q(bit debug = 1 );
   extern function print_dtw_info_q(bit debug = 1);
   extern function print_pending_q();

   function clear_pending_rb_release();
     //If the last RBReq to DMI on a RBID was a release then it will be pending
     smi_rbid_t unique_rbid[*];

     foreach(dtw_info[i]) begin //Ensure RBID is unique
       if(unique_rbid.exists(dtw_info[i].smi_rbid[WSMIRBID-2:0])) begin
         print_dtw_info_q();
         `uvm_error("clear_pending_rb_release",$sformatf("RBID:%0h has multiple entries in dtw_info", dtw_info[i].smi_rbid[WSMIRBID-2:0]))
       end
       else unique_rbid[dtw_info[i].smi_rbid[WSMIRBID-2:0]] = 1;
     end

     for(int i = (dtw_info.size()-1); i >= 0; i--) begin
       if((!dtw_info[i].rb_rsp_recd  && !dtw_info[i].rb_rl_rsp_expd && !dtw_info[i].rb_rl_rsp_recd) &&
          (!dtw_info[i].dtw_rsp_recd && dtw_info[i].dtws_expd == 0)) begin
         `uvm_info("clear_pending_rb_release",$sformatf("Deleting DTW Info RBID:%0h entry, final RB with no activity to follow",dtw_info[i].smi_rbid),UVM_LOW)
         dtw_info.delete(i);
       end
     end
   endfunction
  
   function smi_addr_t isSpAddrAfterTranslate(smi_addr_t addr);
     smi_addr_t translated_addr;
     translated_addr = ncoreConfigInfo::gen_spad_intrlv_rmvd_addr(addr,<%=obj.DmiInfo[obj.Id].nUnitId%>);
     if(isSpAddr(translated_addr)) begin
       return 1;
     end
     else begin
       return 0;
     end
   endfunction

   function smi_addr_t isSpAddr(smi_addr_t addr);
     smi_addr_t cl_aligned_addr;
     if(   (cl_aligned(addr) >= cl_aligned(m_cfg.sp_base_addr_i)) 
        && (cl_aligned(addr) <= cl_aligned(m_cfg.sp_roof_addr_i))) begin
       return 1;
     end
     else begin
       return 0;
     end
   endfunction

   function smi_addr_t cl_aligned(smi_addr_t addr);
      smi_addr_t cl_aligned_addr;
      cl_aligned_addr = (addr >> $clog2(SYS_nSysCacheline));
      return cl_aligned_addr;

   endfunction // cl_aligned

   function smi_addr_t beat_aligned(smi_addr_t addr,int interfacesize);
      smi_addr_t beat_aligned_addr;
      beat_aligned_addr = (addr >> $clog2(interfacesize))<<$clog2(interfacesize);
      
      return beat_aligned_addr;

   endfunction // cl_aligned

   function int mrds_in_flight();
      int size_q[$];
      size_q = {};

      // Find number of transactions without response
      size_q = mrd_info.find_index with (item.cmd_rsp_recd == 0);
      return size_q.size();

   endfunction // mrds_in_flight

//////////////////////////////////////////////////////////////////////////////////
// Init functions
//////////////////////////////////////////////////////////////////////////////////
   function smi_addr_t  genCacheAddresses(smi_type_t smi_msg_type);

      smi_addr_t           cache_addr;
      smi_addr_t           cpy_addr;
      smi_addr_t           addr, sp_addr;
      smi_addr_t           dmi_perf_addr;
      int                  endpoints[$];

      smi_addr_t           indexbits;
      bit                  spAddrFlag = 0;
      bit                  is_coh_atomics;
      int                  used_spaddr_idx_q[$];
      int timeout = 1000;
    `ifdef ADDR_MGR
      addr_trans_mgr       m_addr_mgr;
    `endif

     `uvm_info("dmi_base_seq", $sformatf("Generating %0d cache addresses",k_num_addr),UVM_DEBUG)
  <% if(obj.DutInfo.useCmc && obj.DmiInfo[obj.Id].ccpParams.useScratchpad) { %>
     if(sp_enabled & !exclusive_flg)begin
       if(((smi_msg_type inside {CMD_RD_ATM,CMD_WR_ATM,CMD_SW_ATM,CMD_CMP_ATM}) && (sp_ways == CCP_WAYS_MAX)))begin
          spAddrFlag = 1;
       end 
       else if(m_cfg.sp_exists && (wt_sp_addr_range.get_value() >0))begin
         spAddrFlag =  ($urandom_range(1,100) <= wt_sp_addr_range.get_value());
       end
     end
     else begin
          spAddrFlag = 0;
     end
     `uvm_info("genCacheAddresses", $sformatf("Scratchpad | base_addr:'h%0h  roof_addr :'h%0h sp_flag :%0b sp_exists :%0b",cl_aligned(m_cfg.sp_base_addr_i),cl_aligned(m_cfg.sp_roof_addr_i),spAddrFlag,m_cfg.sp_exists),UVM_DEBUG)
  <% } %>
     do
      begin
        if(random_addr_flg) begin
          cache_addr = $urandom_range(0,2**(<%=obj.wSysAddr%>)-1);   //DEBUG random addr in address space as alternative to addrmgr
          cache_addr = cache_addr & axi_width_mask;
        end
        else if(!addr_reused_flg)begin
          if(!spAddrFlag)begin
            m_addr_mgr = addr_trans_mgr::get_instance();
            if($test$plusargs("conc_13671")) begin
              if(isAtomics(smi_msg_type))begin
                m_addr_mgr.set_addr_collision_pct(home_dmi_unit_id, 1, 100);
              end
              else begin
                m_addr_mgr.set_addr_collision_pct(home_dmi_unit_id, 1, 1);
              end
            end
            else if($test$plusargs("conc_13717")) begin
              if(isAtomics(smi_msg_type) | smi_msg_type == DTW_MRG_MRD_UCLN | smi_msg_type == MRD_RD_WITH_INV) begin
                m_addr_mgr.set_addr_collision_pct(home_dmi_unit_id, 1, 100);
              end
              else begin
                m_addr_mgr.set_addr_collision_pct(home_dmi_unit_id, 1, 1);
              end
            end
            else begin
              m_addr_mgr.set_addr_collision_pct(home_dmi_unit_id, 1, wt_reuse_addr.get_value());
            end
            is_coh_atomics = ($test$plusargs("all_coh_atomics")) ? 1 : $urandom();

            if(isAtomics(smi_msg_type)) begin
                if(!is_coh_atomics)begin
                    cache_addr = m_addr_mgr.get_noncoh_addr(home_dmi_unit_id,1);
                end
                else begin
                    cache_addr = m_addr_mgr.get_coh_addr(home_dmi_unit_id, 1);
                end
            end
            else begin
                if(isNcCmd(smi_msg_type))begin
                    cache_addr = m_addr_mgr.get_noncoh_addr(home_dmi_unit_id,1);
                end
                else begin
                    cache_addr = m_addr_mgr.get_coh_addr(home_dmi_unit_id, 1);
                end
            end
            ////////////////////////////////////To make sure dmi doesn't hang////////////////////////////////////////
            if ($test$plusargs("k_coh_noncoh_collision")) begin
                if(!(cache_addr inside {coh_noncoh_addr_collision_q}))
                    coh_noncoh_addr_collision_q.push_back(cache_addr);
                if(coh_noncoh_addr_collision_q.size()>0 && ($urandom_range(1,100) <= wt_coh_noncoh_addr_collision.get_value()) > 0) begin
                    cache_addr = coh_noncoh_addr_collision_q[$urandom_range(0,coh_noncoh_addr_collision_q.size()-1)];
                end
            end
            //////////////////////////////////////////////////////////////////////////////////////////////////////////
          end
          else begin
            if(WSMIADDR >32) begin
              sp_addr = {$urandom_range(m_cfg.sp_base_addr_i[WSMIADDR-1:32],m_cfg.sp_roof_addr_i[WSMIADDR-1:32]), $urandom_range(m_cfg.sp_base_addr_i[31:0],m_cfg.sp_roof_addr_i[31:0])};
            end
            else begin
              sp_addr = $urandom_range(m_cfg.sp_base_addr_i,m_cfg.sp_roof_addr_i);
            end
            sp_addr = sp_addr & axi_width_mask;
          end
        end
        else begin
          cache_addr = $urandom_range(0,2**(<%=obj.wSysAddr%>)-1);   //DEBUG random addr in address space as alternative to addrmgr
          cache_addr = cache_addr & axi_width_mask;
        end
        timeout--;
      end while (spAddrFlag && !(isSpAddr(sp_addr)) && timeout!=0);
      if(spAddrFlag) begin
        cache_addr = ncoreConfigInfo::gen_full_cache_addr_from_spad_addr(sp_addr,<%=obj.DmiInfo[obj.Id].nUnitId%>);
      end
      else if(m_cfg.sp_exists) begin
        smi_addr_t caddy;
        //Reset the interleaved dmi field. Avoid same CL collisions by not sending illegal addresses.
        caddy = ncoreConfigInfo::gen_spad_intrlv_rmvd_addr(cache_addr,<%=obj.DmiInfo[obj.Id].nUnitId%>);
        cache_addr = ncoreConfigInfo::gen_full_cache_addr_from_spad_addr(caddy,<%=obj.DmiInfo[obj.Id].nUnitId%>);
      end
      <% if(obj.DutInfo.useCmc) { %>
      if(fixed_set_flg && !spAddrFlag)begin
         cache_addr = ncoreConfigInfo::set_dmi_index_bits(cache_addr,fset,<%=obj.DmiInfo[obj.Id].FUnitId%>); // Have to look once AddrMgr up
      end
      <% } %>
      if(spAddrFlag) begin
        `uvm_info("genCacheAddresses", $sformatf("spaddr:'h%0h addr:'h%0h axi_width_mask :%0d bits",sp_addr,cache_addr,$countones(axi_width_mask)),UVM_DEBUG)
      end
      else begin
        `uvm_info("genCacheAddresses", $sformatf("addr:'h%0h axi_width_mask :%0d bits",cache_addr,$countones(axi_width_mask)),UVM_DEBUG)
      end

      return cache_addr;

   endfunction // genCacheAddresses

   function void genEvictAddrq();
      addr_trans_mgr       m_addr_mgr;
      m_addr_mgr = addr_trans_mgr::get_instance();
      m_addr_mgr.set_dmi_smc_fix_index_in_user_addrq(<%=obj.DmiInfo[obj.Id].nUnitId%>, ncoreConfigInfo::user_addrq[ncoreConfigInfo::COH], 1);
      evict_addr_q = ncoreConfigInfo::user_addrq[ncoreConfigInfo::COH];
     `uvm_info("genEvictAddrq",$sformatf("Generated a cache address queue of size %0d to target eviction in SMC", evict_addr_q.size()),UVM_LOW)
   endfunction
   
   function void genSpAddrEdgesq();
     sp_addr_edges_q= {(cl_aligned(m_cfg.sp_base_addr)-1) <<  $clog2(SYS_nSysCacheline),
                       (cl_aligned(m_cfg.sp_base_addr)  ) <<  $clog2(SYS_nSysCacheline),
                       (cl_aligned(m_cfg.sp_base_addr)+1) <<  $clog2(SYS_nSysCacheline),
                       (cl_aligned(m_cfg.sp_roof_addr)-1) <<  $clog2(SYS_nSysCacheline),
                       (cl_aligned(m_cfg.sp_roof_addr)  ) <<  $clog2(SYS_nSysCacheline),
                       (cl_aligned(m_cfg.sp_roof_addr)+1) <<  $clog2(SYS_nSysCacheline)};
   endfunction

   function  void  genCacheAddrq();
      smi_addr_t           cache_addr;
      smi_addr_t           cpy_addr;
      smi_addr_t           addr;
      smi_addr_t           dmi_perf_addr;
   //   dmi_perf_addr = $urandom_range(2**(<%=obj.wSysAddr%>)-1);   //DEBUG random addr in address space as alternative to addrmgr
   //   dmi_perf_addr = dmi_perf_addr & axi_width_mask;
      for(int i =0; i<<%=obj.DmiInfo[obj.Id].ccpParams.nSets%>;i++) begin
        for(int m=0; m<<%=obj.DmiInfo[obj.Id].ccpParams.nWays%>;m++) begin
          assert(std::randomize(dmi_perf_addr));
        <% if(obj.DmiInfo[obj.Id].ccpParams.nSets>1) {%>
         cache_addr = ncoreConfigInfo::set_dmi_index_bits(dmi_perf_addr,i,<%=obj.DmiInfo[obj.Id].FUnitId%>); // Have to look once AddrMgr up
        <%}else{%>
         cache_addr = dmi_perf_addr;
        <%}%>
          cache_addr  = (cache_addr/64)*64;
          cache_addr_list_q.push_back(cache_addr);
         `uvm_info("genCacheAddrq", $sformatf("addr:0x%x  axi_width_mask :%0b",cache_addr,axi_width_mask),UVM_DEBUG)
        end
      end
   endfunction // genCacheAddrq

   function void genConc15195Addrq();
     MsgType_t pattern_q[$];
     smi_addr_t cache_addr;
     typedef enum int { READ_MISS_ALLOCATE,WRITE_FULL_MISS_ALLOCATE,WRITE_HIT_FULL} poison_pattern_t;
     poison_pattern_t seq_type;
     if(!std::randomize(seq_type)) begin
       `uvm_error("genConc15195Addrq","Failed to randomize sequence type")
     end
     case(seq_type) //CMD_PREF and CMD_WR_NC_PTL will fill all ways of a set.
       READ_MISS_ALLOCATE: begin //Read Miss Allocate - Force an evict
         pattern_q = {CMD_PREF, CMD_WR_NC_PTL, CMD_RD_NC, CMD_RD_NC};
       end
       WRITE_FULL_MISS_ALLOCATE: begin //Write Full Miss Allocate - Force an evict
         pattern_q = {CMD_PREF, CMD_WR_NC_PTL, CMD_WR_NC_FULL, CMD_RD_NC};
       end
       WRITE_HIT_FULL: begin //Write Hit Full - Use allocated adress for NC_FULL and RD_NC
         pattern_q = {CMD_PREF, CMD_WR_NC_PTL, CMD_WR_NC_FULL, CMD_RD_NC};
       end
     endcase
     `uvm_info("genConc15195Addrq",$sformatf("%0s to replace poisoned line",seq_type.name),UVM_MEDIUM)
     do begin
       foreach(pattern_q[i]) begin
         for(int m=0; m<<%=obj.DmiInfo[obj.Id].ccpParams.nWays%>;m++) begin
           if(fixed_set_flg) begin
             cache_addr = ncoreConfigInfo::set_dmi_index_bits(0,fset,<%=obj.DmiInfo[obj.Id].FUnitId%>);
           end
           if(pattern_q[i] inside {CMD_PREF,CMD_WR_NC_PTL}) begin
             cache_addr  = cache_addr + (SYS_nSysCacheline/2) + (m<<20);
             conc_15195_msgtype_q.push_back(pattern_q[i]);
             conc_15195_addr_q.push_back(cache_addr);
             `uvm_info("genConc15195Addrq", $sformatf("msg_type:%0h addr:0x%h %0h",pattern_q[i], cache_addr,(SYS_nSysCacheline/2)),UVM_DEBUG)
           end 
           else begin
             if(seq_type == WRITE_HIT_FULL) begin 
               cache_addr  = cache_addr + (SYS_nSysCacheline/2) + (m<<20);
             end
             else begin
               cache_addr  = cache_addr + (SYS_nSysCacheline/2) + ((32)<<20);
             end
             if(m < 2) begin
               conc_15195_msgtype_q.push_back(pattern_q[i]);
               conc_15195_addr_q.push_back(cache_addr);
               `uvm_info("genConc15195Addrq", $sformatf("msg_type:%0h addr:0x%h %0h",pattern_q[i], cache_addr,(SYS_nSysCacheline/2)),UVM_DEBUG)
             end
           end
         end
       end
     end while(conc_15195_addr_q.size() < k_num_cmd);
   endfunction

//   function void genSmimsgIds();
//      smi_msg_id_bit_t  msg_id;
//      int tmp_q[$];
//      `uvm_info("dmi_base_seq", 
//                $sformatf("Generating %0d SMI Msg IDs",k_num_smi_msg_id),UVM_DEBUG)
//      for (int i = 0; i < k_num_smi_msg_id; i++) begin
//         do
//          begin
//            msg_id = $urandom;
//            tmp_q = smi_table.find_index with (item.smi_msg_id == msg_id);  
//          end while(tmp_q.size()>0);
//         smi_table[i].smi_msg_id = msg_id;
//         smi_table[i].inUse = 0;
//        `uvm_info("gen smi", $sformatf("0x%0x",msg_id),UVM_DEBUG)
//      end // for i
//   endfunction // genSmimsgIds


   function bit isMrd(MsgType_t msgType);
       eMsgMRD eMsg;
       return ((msgType >= eMsg.first()) && (msgType <= eMsg.last())); 
   endfunction: isMrd

   function bit isDtw(MsgType_t msgType);
       eMsgDTW eMsg;
       return ((msgType >= eMsg.first()) && (msgType <= eMsg.last())); 
   endfunction: isDtw
   function bit isNcRd(MsgType_t msgType);
       eMsgCMD eMsg;
       return (msgType == CMD_RD_NC); 
   endfunction: isNcRd
    function bit isCmdNcCacheOpsMsg(MsgType_t msgType);
        return (msgType inside {CMD_CLN_INV,CMD_CLN_VLD,CMD_CLN_SH_PER,CMD_MK_INV,CMD_PREF}); 
    endfunction : isCmdNcCacheOpsMsg

   function bit isNcWr(MsgType_t msgType);
       eMsgCMD eMsg;
       return ((msgType == CMD_WR_NC_PTL) || (msgType == CMD_WR_NC_FULL )); 
   endfunction: isNcWr

   function bit isNcCmd(MsgType_t msgType);
       eMsgCMD eMsg;
       return (msgType inside {CMD_WR_NC_PTL,CMD_WR_NC_FULL,CMD_RD_NC,CMD_CLN_INV,CMD_CLN_VLD,CMD_CLN_SH_PER,CMD_MK_INV,CMD_PREF}); 
   endfunction: isNcCmd

   function bit isAtomics(MsgType_t msgType);
        eMsgCMD eMsg;
        return (msgType inside {CMD_RD_ATM,CMD_WR_ATM,CMD_SW_ATM,CMD_CMP_ATM});
   endfunction : isAtomics

   function bit isDtwMrgMrd(MsgType_t msgType);
       eMsgDTWMrgMRD eMsg;
       return ((msgType >= eMsg.first()) && (msgType <= eMsg.last())); 
   endfunction: isDtwMrgMrd

   function bit isRbRelease(smi_rbid_t m_rbid);
     int find_q[$];
     find_q = dtw_info.find_index with ( (item.smi_rbid == m_rbid) && item.rb_rl_rsp_expd);
     if(find_q.size() != 0) return 1;
     else return 0;
   endfunction
   
   task tryReuseQueue(smi_seq_item req_item, inout reuseQFlag);
      int reuseQpct;
      int QIndex;
      reuseQFlag = 0;
      if (reuseQ.size() > k_min_reuse_q_size) begin
         reuseQpct = $urandom_range(100,0);
         if(reuseQpct >= (100 - k_reuse_q_pct)) begin
            reuseQFlag = 1;
            QIndex = $urandom_range(reuseQ.size-1,0);
            req_item.smi_addr     = reuseQ[QIndex].cache_addr;
            req_item.smi_ns       = addr_reused_toggle_ns_flg ? ~reuseQ[QIndex].security : reuseQ[QIndex].security;
            if(addr_reused_toggle_ns_flg) begin
              reuseQ[QIndex].security = req_item.smi_ns;
            end
            req_item.smi_ca       = reuseQ[QIndex].cacheable;
            //reuseQ.delete(QIndex);
            `uvm_info("fromReuseQueue",$sformatf("Choosing addr from reuseQ addr:0x%0x sec:%0b ca:%0b",req_item.smi_addr,req_item.smi_ns,req_item.smi_ca),UVM_DEBUG);
         end
      end
 <%if(obj.DutInfo.useCmc){%>
      if(((req_item.smi_msg_type inside {CMD_RD_ATM,CMD_WR_ATM,CMD_SW_ATM,CMD_CMP_ATM}) && (sp_ways == CCP_WAYS_MAX)))begin
        reuseQFlag = 0;
      end
 <% } %>
      //return reuseQFlag;
   endtask // tryReuseQueue

   function reuseQNoMatchInFlight(bit reuseQFlag, int size1, int size2);
        if((reuseQFlag == 1) && ((size1 + size2) !== 0)) begin
           printReuseQ();
           print_mrd_info_q();
           `uvm_error("dmi_base_seq",
                      $sformatf("Address from reuseQ cannot match in flight addresses sz1:%0d sz2:%0d",
                                size1, size2));
        end
   endfunction // reuseQNoMatchInFlight

   function addToReuseQ(AddrQ_t poppedItem);
      AddrQ_t addrItem;
      addrItem = new();

      addrItem = poppedItem;
      `uvm_info("addToReuseQ",$sformatf("reuseItem:%p",addrItem),UVM_DEBUG);
     if(reuseQ.size() != k_max_reuse_q_size) begin
       reuseQ.push_back(addrItem);
     end
     if(!bw_test)begin
       if (reuseQ.size() > k_max_reuse_q_size) begin
         `uvm_info("addToReuseQ",
                   $sformatf("Reuse queue size more than %0d. Popping oldest",k_max_reuse_q_size),UVM_DEBUG)
         reuseQ.pop_front();
       end
     end 
   endfunction // addToReuseQ

   function printReuseQ();
      if (reuseQ.size != 0) begin
         `uvm_info("", $sformatf("Print contents of reuse queue"), UVM_DEBUG)
         foreach (reuseQ[i]) begin
            `uvm_info("",
            $sformatf("reuseQ[%0d]:addr=0x%0x sec=%0b type=0x%0x smiId=0x%0x \
                       aiuId=0x%0x aiumsgId=0x%0x",
                      i, reuseQ[i].cache_addr, reuseQ[i].security, reuseQ[i].cmd_msg_type,
                      reuseQ[i].smi_msg_id, reuseQ[i].aiu_id, reuseQ[i].aiu_msg_id),
                      UVM_DEBUG)
         end
      end
      else begin
         `uvm_info("", $sformatf("Reuse Q is empty"), UVM_DEBUG)
      end
   endfunction // printReuseQ


/////////////////////////////////////////////////////////////////////////////////
// process_str_req
////////////////////////////////////////////////////////////////////////////////
   task process_str_req(smi_seq_item req_item);
      int tmp_q[$],tmp_q1[$],tmp_q2[$],tmp_q3[$];

      smi_seq_item  m_tmp_mst_dtw_req;          
      tmp_q = {};
      tmp_q =  NcRd_info.find_index with ((item.aiu_id == req_item.smi_targ_ncore_unit_id) &&
                                          (item.smi_msg_id == req_item.smi_rmsg_id) &&
                                          (item.str_recd == 0));
      tmp_q1 = {};
      tmp_q1 = m_smi_str_req_q.find_index with ((item.smi_src_ncore_unit_id == req_item.smi_targ_ncore_unit_id) &&
                                              (item.smi_msg_id == req_item.smi_rmsg_id));
      tmp_q2 = {};
      tmp_q2 = NcWr_info.find_index with ((item.aiu_id == req_item.smi_targ_ncore_unit_id) &&
                                     (item.smi_msg_id == req_item.smi_rmsg_id) &&
                                     (item.str_recd == 0));

      tmp_q3 = {};
      tmp_q3 = AtmLd_info.find_index with ((item.aiu_id == req_item.smi_targ_ncore_unit_id) &&
                                     (item.smi_msg_id == req_item.smi_rmsg_id) &&
                                     (item.str_recd == 0));

      `uvm_info("dmi_base_seq",$sformatf("pending Nc Rd :%0d/Wr :%0d/Atmld :%0d cmd matching str req ",tmp_q.size(),tmp_q2.size(),tmp_q3.size()),UVM_DEBUG);  

      if(!tmp_q1.size())begin
            print_NcWr_info_q();
            print_NcRd_info_q();
            print_AtmLd_info_q();
        `uvm_error("dmi_base_seq", $sformatf("None of the pending cmd matching str req aiu_id :%0x aiu_msg_id :%x",req_item.smi_targ_ncore_unit_id,req_item.smi_rmsg_id))
      end

      if(!(tmp_q.size()+tmp_q2.size() + tmp_q3.size()))begin
            print_NcWr_info_q();
            print_NcRd_info_q();
            print_AtmLd_info_q();
        // print_rd_info_q();
        `uvm_error("dmi_base_seq",$sformatf("None the pending Nc Rd/Wr or AtmLd cmd matching str req %0d ",tmp_q.size()+tmp_q2.size()+tmp_q3.size()));  
      end
      else if(!(tmp_q.size()+tmp_q2.size() + tmp_q3.size() ) >1)begin
            print_NcWr_info_q();
            print_NcRd_info_q();
            print_AtmLd_info_q();
        `uvm_error("dmi_base_seq",$sformatf("Multilpe pending Nc Rd/Wr/Atmld cmd matching str req %0d >1",tmp_q.size()+tmp_q2.size()+tmp_q3.size()));  
      end
      else begin
        if(tmp_q2.size() ==1)begin
            `uvm_info("dmi_base_seq",$sformatf("seting Rbid for dtw :%0x",req_item.smi_rbid),UVM_DEBUG);
             m_tmp_mst_dtw_req = smi_seq_item::type_id::create("tmp_mst_dtw_req");
             m_tmp_mst_dtw_req.do_copy(m_smi_str_req_q[tmp_q1[0]]);
             // recalulate BE only for No atomic store
           //  if(m_tmp_mst_dtw_req.smi_msg_type != CMD_RD_ATM)begin
           //    chooseBE(m_tmp_mst_dtw_req);
           //  end
             if(m_tmp_mst_dtw_req.smi_msg_type == CMD_WR_NC_FULL)begin
               m_tmp_mst_dtw_req.smi_msg_type = $urandom_range(0,1)? DTW_DATA_CLN : DTW_DATA_DTY;
               chooseBE(m_tmp_mst_dtw_req);
             end
             else if(m_tmp_mst_dtw_req.smi_msg_type inside {CMD_RD_ATM,CMD_WR_ATM})begin
               m_tmp_mst_dtw_req.smi_msg_type =  DTW_DATA_PTL;
             end
             else begin
               if(k_send_data_on_dtw_ptl) begin
                 m_tmp_mst_dtw_req.smi_msg_type = DTW_DATA_PTL;
               end
               else begin
                 m_tmp_mst_dtw_req.smi_msg_type = $urandom_range(0,1)? DTW_DATA_PTL: DTW_NO_DATA;
               end
               chooseBE(m_tmp_mst_dtw_req);
             end
             m_tmp_mst_dtw_req.smi_rl       = 'b10;
             m_tmp_mst_dtw_req.smi_rbid     = req_item.smi_rbid;
             m_tmp_mst_dtw_req.smi_prim     = 1;
            if ($test$plusargs("wrong_targ_id_dtw")) begin
             m_tmp_mst_dtw_req.smi_targ_ncore_unit_id   = (home_dmi_unit_id ^ {WSMINCOREUNITID{1'b1}}); 
            end
             m_smi_tx_dtw_req_q.push_back(m_tmp_mst_dtw_req);
             ->e_smi_dtw_req_q;
             m_smi_str_req_q.delete(tmp_q1[0]);
             NcWr_info[tmp_q2[0]].str_recd = 1;
        end
        else if(tmp_q3.size() ==1)begin
            `uvm_info("dmi_base_seq",$sformatf("seting Rbid for AtmLd :%0x",req_item.smi_rbid),UVM_DEBUG);
             m_tmp_mst_dtw_req = smi_seq_item::type_id::create("tmp_mst_dtw_req");
             m_tmp_mst_dtw_req.do_copy(m_smi_str_req_q[tmp_q1[0]]);
             m_tmp_mst_dtw_req.smi_msg_type = DTW_DATA_PTL;
             m_tmp_mst_dtw_req.smi_rbid     = req_item.smi_rbid;
             m_tmp_mst_dtw_req.smi_prim     = 1;
             m_tmp_mst_dtw_req.smi_mpf1_argv = $urandom_range(0,7);
             m_tmp_mst_dtw_req.smi_rl       = 'b10;
            if ($test$plusargs("wrong_targ_id_dtw")) begin
             m_tmp_mst_dtw_req.smi_targ_ncore_unit_id   = (home_dmi_unit_id ^ {WSMINCOREUNITID{1'b1}}); 
            end
             m_smi_tx_dtw_req_q.push_back(m_tmp_mst_dtw_req);
             ->e_smi_dtw_req_q;
             m_smi_str_req_q.delete(tmp_q1[0]);
             AtmLd_info[tmp_q3[0]].str_recd = 1;
        end
        else begin
            NcRd_info[tmp_q[0]].str_recd = 1;
            m_smi_str_req_q.delete(tmp_q1[0]);
        end
      end
   endtask

//////////////////////////////////////////////////////////////////////////////////
// Choose next transaction type
//////////////////////////////////////////////////////////////////////////////////
   task chooseReqType(int k);
      if (k_back_to_back_chains == 1) begin
         this_type++;
      end
      else begin
         this_type = (((k+k_back_to_back_chains)/(k_back_to_back_chains))%2); // 1 is first
      end
      `uvm_info("dmi_base_seq", $sformatf("k_back_to_back_types=%0d, k_back_to_back_chains=%0d this_type=%0d",
                                         k_back_to_back_types, k_back_to_back_chains,this_type),UVM_DEBUG)
      case (k_back_to_back_types) //TODO: 
        910: begin // MRD-MRD-DTW
           case (this_type)
             1 : cmd_msg_type = MRD_RD_WITH_SHR_CLN;
             2 : cmd_msg_type = MRD_RD_WITH_UNQ_CLN;
             3 : cmd_msg_type = DTW_DATA_DTY;
           endcase // case (this_type)
        end
        901: begin // DTW-MRD-MRD
           case (this_type)
             1 : cmd_msg_type = DTW_DATA_DTY;
             2 : cmd_msg_type = MRD_RD_WITH_SHR_CLN;
             3 : cmd_msg_type = MRD_RD_WITH_UNQ_CLN;
           endcase // case (this_type)
        end
        904: begin
          case (this_type)
            1 : cmd_msg_type = CMD_RD_NC;
            2 : cmd_msg_type = CMD_WR_NC_FULL;
          endcase
        end
        920: begin //NCCMD-NCCMD-NCWR
           case (this_type)
             1 : cmd_msg_type = CMD_RD_NC;
             2 : cmd_msg_type = CMD_RD_NC;
             3 : cmd_msg_type = CMD_WR_NC_FULL;
           endcase // case (this_type)
        end
        902: begin // MRD-DTWF
           case (this_type)
             0 : cmd_msg_type = DTW_DATA_DTY;
             1 : cmd_msg_type = MRD_RD_WITH_UNQ_CLN;
           endcase // case (this_type)
        end
        921: begin // DTWFull-HNT
           case (this_type)
             0 : cmd_msg_type = MRD_PREF;
             1 : cmd_msg_type = DTW_DATA_DTY;
           endcase // case (this_type)
        end
        912: begin // HNT-DTWF
           case (this_type)
             0 : cmd_msg_type = DTW_DATA_CLN;
             1 : cmd_msg_type = MRD_PREF;
           endcase // case (this_type)
        end
        931: begin // HNT-DTWF
           case (this_type)
             0 : cmd_msg_type = MRD_RD_WITH_SHR_CLN;
             1 : cmd_msg_type = MRD_PREF;
           endcase // case (this_type)
        end
        903: begin // HNT-HNT
           case (this_type)
             0 : cmd_msg_type = MRD_PREF;
             1 : cmd_msg_type = MRD_PREF;
           endcase // case (this_type)
        end
        941: begin
            if(dtwmrgmrd_count > 0) begin
                `uvm_info("dmi_base_seq", $sformatf("time %0t dtwmrgmrd_count %0d", $time, dtwmrgmrd_count), UVM_LOW)
                cmd_msg_type = DTW_MRG_MRD_UDTY;
                dtwmrgmrd_count--;
            end
            else if(dtw_count >= 0) begin
                `uvm_info("dmi_base_seq", $sformatf("time %0t dtw_count %0d", $time, dtw_count), UVM_LOW)
                if(first_dtw) evt_start_dtws.wait_trigger();
                cmd_msg_type = ($urandom_range(1,100) <= 50) ? DTW_DATA_DTY:DTW_DATA_PTL;
                dtw_count--;
                first_dtw = 0;
            end
            else begin
                cmd_msg_type = ($urandom_range(1,100) <= 50) ? MRD_RD_WITH_UNQ:MRD_RD_WITH_INV;
            end
        end
        default: begin
      
  <% if(obj.DutInfo.useCmc) { %>
      if(cache_warmup_flg && !warmup_done)begin
        if(mrd_pref_flg)begin
          cmd_msg_type = MRD_PREF;
        end
        else begin
          cmd_msg_type = CMD_PREF;
        end
      end
      else if(conc_15195_flg) begin
        cmd_msg_type = conc_15195_msgtype_q[addr_cnt]; 
      end
      else if(error_test_flg)begin
        if(!toggle_flg)begin
          cmd_msg_type = MRD_PREF;
        end
        else begin
        randcase
            wt_mrd_rd_with_shr_cln.get_value(): cmd_msg_type = MRD_RD_WITH_SHR_CLN;
            wt_mrd_rd_with_inv.get_value()    : cmd_msg_type = MRD_RD_WITH_INV;
        endcase // randcase
        end
      end
      else  begin
 <% } %>

     randcase
       wt_cmd_rd_nc.get_value()          : cmd_msg_type = CMD_RD_NC;
       wt_cmd_wr_nc_ptl.get_value()      : cmd_msg_type = CMD_WR_NC_PTL;
       wt_cmd_wr_nc_full.get_value()     : cmd_msg_type = CMD_WR_NC_FULL;
       wt_mrd_rd_with_shr_cln.get_value(): cmd_msg_type = MRD_RD_WITH_SHR_CLN;
       wt_mrd_rd_with_unq_cln.get_value(): cmd_msg_type = MRD_RD_WITH_UNQ_CLN;
       wt_mrd_rd_with_unq.get_value()    : cmd_msg_type = MRD_RD_WITH_UNQ;
       wt_mrd_rd_with_inv.get_value()    : cmd_msg_type = MRD_RD_WITH_INV;
       wt_mrd_flush.get_value()          : cmd_msg_type = MRD_FLUSH;
       wt_mrd_cln.get_value()            : cmd_msg_type = MRD_CLN;
       wt_mrd_inv.get_value()            : cmd_msg_type = MRD_INV;
       wt_mrd_pref.get_value()           : cmd_msg_type = MRD_PREF;
       wt_cmd_cln_inv.get_value()        : cmd_msg_type = CMD_CLN_INV;
       wt_cmd_cln_vld.get_value()        : cmd_msg_type = CMD_CLN_VLD;
       wt_cmd_cln_ShPsist.get_value()    : cmd_msg_type = CMD_CLN_SH_PER;
       wt_cmd_mk_inv.get_value()         : cmd_msg_type = CMD_MK_INV;
       wt_cmd_pref.get_value()           : cmd_msg_type = CMD_PREF;
       wt_dtw_no_dt.get_value()          : cmd_msg_type = DTW_NO_DATA;
       wt_dtw_dt_cln.get_value()         : cmd_msg_type = DTW_DATA_CLN;
       wt_dtw_dt_ptl.get_value()         : cmd_msg_type = DTW_DATA_PTL;
       wt_dtw_dt_dty.get_value()         : cmd_msg_type = DTW_DATA_DTY;
       wt_dtw_mrg_mrd_ucln.get_value()   : cmd_msg_type = DTW_MRG_MRD_UCLN;          
       wt_dtw_mrg_mrd_udty.get_value()   : cmd_msg_type = DTW_MRG_MRD_UDTY;          
       wt_dtw_mrg_mrd_inv.get_value()    : cmd_msg_type = DTW_MRG_MRD_INV;        
       <% if(obj.DmiInfo[obj.Id].useAtomic) { %>    
       wt_cmd_rd_atm.get_value()         : cmd_msg_type = CMD_RD_ATM;
       wt_cmd_wr_atm.get_value()         : cmd_msg_type = CMD_WR_ATM;
       wt_cmd_swap_atm.get_value()       : cmd_msg_type = CMD_SW_ATM;
       wt_cmd_cmp_atm.get_value()        : cmd_msg_type = CMD_CMP_ATM;
       <% } %>
       // wt_mrd_rd_cln         : cmd_msg_type = MRD_RD_CLN; Depricated
       // wt_mrd_rd_vld         : cmd_msg_type = MRD_RD_VLD;
       // wt_mrd_rd_inv         : cmd_msg_type = MRD_RD_INV;
     endcase // randcase

  <% if(obj.DutInfo.useCmc) { %>
      end
  <% } %>


           `uvm_info("dmi_base_seq", $sformatf("In chooseReqType, cmd_msg_type chosen=%0x based on weights - wt_mrd_rd_with_unq_cln=%0d, wt_mrd_rd_with_unq=%0d  wt_mrd_rd_with_shr_cln=%0d, wt_mrd_rd_with_inv=%0d, wt_mrd_flush=%0d, wt_dtw_no_dt=%0d wt_dtw_dt_ptl=%0d, wt_dtw_dt_dty=%0d, wt_dtw_dt_cln=%0d wt_cmd_rd_nc=%0d wt_cmd_wr_nc_ptl=%0d wt_cmd_wr_nc_full:%0d, wt_cmd_rd_atm=%0d,wt_cmd_wr_atm=%0d, wt_cmd_swap_atm=%0d, wt_cmd_cmp_atm=%0d, wt_dtw_mrg_mrd_udty=%0d ", cmd_msg_type, wt_mrd_rd_with_unq_cln.get_value(),wt_mrd_rd_with_unq.get_value(),wt_mrd_rd_with_shr_cln.get_value(),                        
                                           wt_mrd_rd_with_inv.get_value(),wt_mrd_flush.get_value(), wt_dtw_no_dt.get_value(),wt_dtw_dt_ptl.get_value(),
                                           wt_dtw_dt_dty.get_value(),wt_dtw_dt_cln.get_value(),wt_cmd_rd_nc.get_value(),wt_cmd_wr_nc_ptl.get_value(),
                                           wt_cmd_wr_nc_full.get_value(),wt_cmd_rd_atm.get_value(),wt_cmd_wr_atm.get_value(),
                                           wt_cmd_swap_atm.get_value(),wt_cmd_cmp_atm.get_value(),wt_dtw_mrg_mrd_udty.get_value()), UVM_DEBUG);
          `uvm_info("dmi_base_seq",$sformatf("weights wt_mrd_cln :%0d, wt_mrd_inv :%0d,  wt_mrd_pref :%0d, wt_cmd_cln_inv :%0d, wt_cmd_cln_vld :%0d, wt_cmd_cln_ShPsist :%0d wt_cmd_mk_inv :%0d, wt_cmd_pref :%0d",wt_mrd_cln.get_value(),wt_mrd_inv.get_value(),wt_mrd_pref.get_value(),wt_cmd_cln_inv.get_value(),wt_cmd_cln_vld.get_value(),wt_cmd_cln_ShPsist.get_value(),
                                                 wt_cmd_mk_inv.get_value(),wt_cmd_pref.get_value()),UVM_DEBUG);
        end
      endcase // case (k_back_to_back_types)


   endtask // chooseReqType

   task chooseAtomicReqType();
     randcase
       wt_cmd_rd_atm.get_value()         : cmd_msg_type = CMD_RD_ATM;
       wt_cmd_wr_atm.get_value()         : cmd_msg_type = CMD_WR_ATM;
       wt_cmd_swap_atm.get_value()       : cmd_msg_type = CMD_SW_ATM;
       wt_cmd_cmp_atm.get_value()        : cmd_msg_type = CMD_CMP_ATM;
     endcase
     `uvm_info("dmi_base_seq",$sformatf("Choosing Atomic txn of type %0x", cmd_msg_type), UVM_LOW)
   endtask

   // This task is for a very particular directed test
   task chooseNextReqType(int k);
      if (k< <%=obj.DmiInfo[obj.Id].cmpInfo.nWttCtrlEntries%>) begin
         cmd_msg_type = DTW_DATA_CLN;
      end
      //else if (k < <%=obj.DmiInfo[obj.Id].cmpInfo.nWttCtrlEntries + obj.DmiInfo[obj.Id].cmpInfo.nMrdInFlight%>) begin
      else if (k < <%=obj.DmiInfo[obj.Id].cmpInfo.nWttCtrlEntries + obj.DmiInfo[obj.Id].nMrdSkidBufSize%>) begin
         cmd_msg_type = MRD_RD_WITH_UNQ;
      end
   endtask // chooseNextReqType

//////////////////////////////////////////////////////////////////////////////////
// msgaction level functions
//////////////////////////////////////////////////////////////////////////////////
         // Create packet from info using lists
         // Extend these for different packet types
//////////////////////////////////////////////////////////////////////////////////////////
// Packet Details for different packets
// SFI PKT        MRD_RD_CLN          DTW_FULL(dep) DTW_DATA         Notes
//////////////////////////////////////////////////////////////////////////////////////////

   task buildPkt(smi_seq_item req_item, input bit block_dtw_addr_gen=0);
      case (cmd_msg_type)
        MRD_RD_WITH_SHR_CLN, MRD_RD_WITH_UNQ_CLN, MRD_RD_WITH_UNQ,
        MRD_RD_WITH_UNQ, MRD_RD_WITH_INV,MRD_FLUSH,MRD_CLN,MRD_INV,MRD_PREF: begin
           readsAdditionalInfo(req_item);
           genMrdPkt(req_item);
           chooseLength(req_item);
           setSrctgtId(req_item);
           getSmimsgId(req_item);
        end
        DTW_MRG_MRD_UCLN,
        DTW_MRG_MRD_UDTY,DTW_MRG_MRD_INV: begin
           if(!smi_mw) primary = $urandom;
           else primary = 1;
           setWrAdditionalInfo(req_item,primary);
           genDtwPkt(req_item);
        end
        DTW_NO_DATA,DTW_DATA_PTL, DTW_DATA_DTY, DTW_DATA_CLN:begin 
           //primary = $urandom;
           primary = 1;
           setWrAdditionalInfo(req_item,primary);
           if (!block_dtw_addr_gen) begin
           genDtwPkt(req_item);
           end
        end
        CMD_RD_NC,CMD_CLN_INV,CMD_CLN_VLD,CMD_CLN_SH_PER,CMD_MK_INV,CMD_PREF: begin
           getNcSmimsgId(req_item);
           chooseClAddr(req_item);
           chooseLength(req_item);
           setCmdAttribute(req_item);
           if ($test$plusargs("wrong_targ_id_cmd")) begin
             req_item.smi_targ_ncore_unit_id   = (home_dmi_unit_id ^ {WSMINCOREUNITID{1'b1}}); 
           end else begin
             req_item.smi_targ_ncore_unit_id   = home_dmi_unit_id; 
           end
        end
        CMD_WR_NC_FULL,CMD_WR_NC_PTL,CMD_WR_ATM: begin
           getNcSmimsgId(req_item);
           genDtwPkt(req_item);
           setCmdAttribute(req_item);
           if ($test$plusargs("wrong_targ_id_cmd")) begin
             req_item.smi_targ_ncore_unit_id   = (home_dmi_unit_id ^ {WSMINCOREUNITID{1'b1}}); 
           end else begin
             req_item.smi_targ_ncore_unit_id   = home_dmi_unit_id; 
           end
        end
        CMD_RD_ATM,CMD_SW_ATM,CMD_CMP_ATM: begin
           getNcSmimsgId(req_item);
           genDtwPkt(req_item);
           setCmdAttribute(req_item);
           if ($test$plusargs("wrong_targ_id_cmd")) begin
             req_item.smi_targ_ncore_unit_id   = (home_dmi_unit_id ^ {WSMINCOREUNITID{1'b1}}); 
           end else begin
             req_item.smi_targ_ncore_unit_id   = home_dmi_unit_id; 
           end

        end 
      endcase // case (cmd_msg_type)
   endtask // buildPkt
   
//////////////////////////////////////////////////////////////////////////////////
// MRD
//////////////////////////////////////////////////////////////////////////////////
   task genMrdPkt(smi_seq_item req_item);
      int tmp_q[$];
      int tmp_q2[$];
      int tmp_q3[$];
      int tmp_q4[$];
      int tmp_q5[$];
      int tmp_q6[$];
      bit reuseQFlag;
      bit mrd_prefHitInUseMrd;
      bit addr_search_done =0;
      int i=0; int trans_idx=0;
      int trans_idx_q[$]; 
      bit trans_flag=0;
      bit [3:0] mask;
      Addr_t  cache_addr_tmp;
      reuseQFlag = 0;
      mrd_prefHitInUseMrd = 0;
      trans_idx_q = {};
      `uvm_info("dmi_base_seq", $sformatf("MSB=0x%x LSB=0x%x",
                                         SYS_wSysAddress-1,
                                         $clog2(SYS_nSysCacheline)),UVM_DEBUG)

      timeout_count = k_num_addr*50000*slow;
      size_count = 0;
      foreach (mrd_info[i]) begin
         `uvm_info("dmi_base_seq MRD", $sformatf("MRD Info Addr [39:%0d]=0x%0x sec:%0b",
                                                $clog2(WSMIDPBE),
                                                cl_aligned(mrd_info[i].cache_addr),
                                                mrd_info[i].security),UVM_DEBUG)
      end
      do begin
         if ((mrd_use_last_mrd_pref) && (mrd_prefHitInUseMrd == 0)) begin
            req_item.smi_addr = lastHntAddr;
            req_item.smi_ns = lastHntSec;
            if (tmp_q3.size() !== 0) begin
               `uvm_info("dmi_base_seq", $sformatf("Addr is already in use for mrd_pref. Choosing again"),UVM_DEBUG)
            end
            timeout_count -= 1;
            size_count += 1;
            if((tmp_q3.size() !== 0) && (timeout_count != 0)) begin
              //`uvm_info("delay_debug","MrdPref in use",UVM_LOW);
              #1ns;
            end
         end
         else begin
            if(addr_reused_flg)begin
              tryReuseQueue(req_item, reuseQFlag);
            end
            `uvm_info("reuse",$sformatf("reuseQFlag=%0b",reuseQFlag), UVM_DEBUG);
           if (reuseQFlag == 0) begin
  <% if(obj.DutInfo.useCmc) { %>
             if(!warmup_done && cache_warmup_flg)begin
               req_item.smi_addr          = cache_addr_list_q[addr_cnt];
             end
             else if(error_test_flg)begin
               if(!toggle_flg)begin
                 req_item.smi_addr        = cache_addr_list_q[error_addr_cnt];
                 error_addr_cnt++;
                 if(error_addr_cnt == cache_addr_list_q.size())begin
                   error_addr_cnt = 0;
                 end
               end
               else begin
                   if(addr_search_done)begin
                    cache_addr_list.push_back(cache_addr_list_entry);
                   end
                   cache_addr_tmp      = cache_addr_list.pop_front();
                   req_item.smi_addr   = cache_addr_tmp.addr;
               end

             end
             else begin
  <% } %>
                req_item.smi_addr          =  genCacheAddresses(req_item.smi_msg_type);
                if(!(sp_enabled & isSpAddrAfterTranslate(req_item.smi_addr)))begin
                   req_item.smi_addr[($clog2(SYS_nSysCacheline)-1):0] = 0;
                   req_item.smi_addr          += $urandom_range(SYS_nSysCacheline-1,0);
                end
                <% if ((obj.DmiInfo[obj.Id].nAddrTransRegisters > 0) && (obj.testBench != 'fsys')) { %>
                    if(k_addr_trans_hit) begin
                       foreach(addrTransV[reg_idx]) begin
                            //$display("1.addrTransV[%0d] = %0h",reg_idx,addrTransV[reg_idx]);
                            //$display("1.addrTransFrom[%0d] = %0h", reg_idx,addrTransFrom[reg_idx]);
                            //$display("1.addrTrandTo[%0d] = %0h", reg_idx,addrTransTo[reg_idx]);
                       end
                        while(i<4) begin
                            trans_idx = $urandom_range(0,3);
                            //$display("2.trans_idx %0d", trans_idx);
                            //$display("2.addrTransV[%0d][31] = %0b",trans_idx, addrTransV[trans_idx][31]);
                            if(addrTransV[trans_idx][31] == 1) begin 
                                trans_flag = 1;
                                break;
                            end
                            i++;
                        end
                        //$display("3.trans flag %0b i = %0d", trans_flag, i);
                        if(trans_flag) begin
                            //$display("4.trans index %0d",trans_idx);
                            mask = addrTransV[trans_idx] & 4'hf;
                            //$display("4.mask %0h",mask);
                            req_item.smi_addr = ((addrTransFrom[trans_idx] >> mask)<<(20+mask));
                            //$display("4.intermediate smi_addr %0h",req_item.smi_addr);
                            req_item.smi_addr += $urandom_range((2**(20+mask))-1,0);
                            //$display("4.final smi_addr %0h",req_item.smi_addr);
                        end
                    end
                <% } %>
                 <% if(obj.DutInfo.useCmc) { %>
             end
  <% }  %>
               <%if (obj.wSecurityAttribute>0){%> 
               if(isSpAddrAfterTranslate(req_item.smi_addr)) begin
                 //NS bit propagation should be top-down based on what is configured in USMCSPBR0/1
                 req_item.smi_ns = k_sp_ns;
               end
               else begin
                 req_item.smi_ns = k_force_ns ? 1 : $urandom;
               end
               <% }else {  %>
               req_item.smi_ns      = 0;
               <% }  %>

              if((error_test_flg && !toggle_flg) || !error_test_flg )begin
                cache_addr_list_entry = new();
                cache_addr_list_entry.addr          = req_item.smi_addr;
                cache_addr_list_entry.security      = req_item.smi_ns;
                cache_addr_list.push_back(cache_addr_list_entry);
              end

  <% if(obj.DutInfo.useCmc) { %>
               if(error_test_flg && toggle_flg)begin
                 req_item.smi_ns      = cache_addr_tmp.security;
               end
  <% }  %>
             end
           `uvm_info("dmi_base_seq MRD",
                     $sformatf("Addr chosen[39:%0d]=0x%0x sec=%0b fromReuseQ=%0b",
                               $clog2(WSMIDPBE),
                               cl_aligned(req_item.smi_addr),
                               req_item.smi_ns, reuseQFlag),UVM_DEBUG)

//#Check.DMI.Concerto.v3.0.Mrdinflight
           tmp_q = mrd_info.find_index with ((cl_aligned(item.cache_addr) == cl_aligned(req_item.smi_addr)) &&
                                             (item.security === req_item.smi_ns) && (item.cmd_msg_type != MRD_PREF));
           if (tmp_q.size() !== 0) begin
              `uvm_info("dmi_base_seq MRD", $sformatf("Addr is already in use by MRD. Choosing again"),UVM_DEBUG)
              if (mrd_use_last_mrd_pref) begin
                 mrd_prefHitInUseMrd = 1;
              end
           end
           

//#Check.DMI.Concerto.v3.0.MrdCollidewithDtwreq
  //         if(!(cmd_msg_type inside { MRD_FLUSH,MRD_INV,MRD_CLN}))begin  As per Conc-4773
             tmp_q2 = dtw_info.find_index with ((cl_aligned(item.cache_addr) === cl_aligned(req_item.smi_addr)) &&
                                                 (item.security === req_item.smi_ns) &&
                                                 (item.isMrgMrd ?!(item.dtr_recd & item.dtw_rsp_recd):!item.dtw_rsp_recd));
  //         end

           if(tmp_q2.size() !== 0 && timeout_count  > ((k_num_addr*50000*slow)-1000)) begin
             `uvm_info("dmi_base_seq MRD", $sformatf("Addr is already in use by DTW. Choosing again"),UVM_DEBUG)
           end
           else begin
             `uvm_info("dmi_base_seq MRD", $sformatf("Addr is already in use by DTW. Attempting to use an internal released address"),UVM_DEBUG)
             tmp_q2 = dtw_info.find_index with ((cl_aligned(item.cache_addr) === cl_aligned(req_item.smi_addr)) &&
                                                 (item.security === req_item.smi_ns) &&
                                                 !item.rb_rl_rsp_expd &&
                                                 (item.isMrgMrd ?!(item.dtr_recd & item.dtw_rsp_recd):!item.dtw_rsp_recd));
             if(tmp_q2.size() !== 0)
               `uvm_info("dmi_base_seq MRD", $sformatf("Addr is already in use by DTW. Choosing again"),UVM_DEBUG)

           end
             tmp_q3 = AtmLd_info.find_index with ((cl_aligned(item.cache_addr) === cl_aligned(req_item.smi_addr)) &&
                                                 (item.security === req_item.smi_ns) &&
                                                 (!item.dtr_recd || !item.dtw_rsp_recd));
           if(tmp_q3.size() !== 0) begin
              `uvm_info("dmi_base_seq MRD", $sformatf("Addr is already in use by Atm :%0d. Choosing again ",tmp_q3.size()),UVM_DEBUG)
           end
            
        <% if(obj.DutInfo.useCmc) { %>
         <%  if(obj.DmiInfo[obj.Id].ccpParams.useScratchpad) { %>
           if(isSpAddrAfterTranslate(req_item.smi_addr)) begin

                tmp_q4 = NcRd_info.find_index with ((cl_aligned(item.cache_addr) === cl_aligned(req_item.smi_addr)) &&
                                                     (item.security === req_item.smi_ns) &&
                                                     (!item.dtr_recd));
                tmp_q5 = NcWr_info.find_index with ((cl_aligned(item.cache_addr) === cl_aligned(req_item.smi_addr)) &&
                                                     (item.security === req_item.smi_ns) && 
                                                     (!item.dtw_rsp_recd)); 
                tmp_q6 = AtmLd_info.find_index with ((cl_aligned(item.cache_addr) === cl_aligned(req_item.smi_addr)) &&
                                                     (item.security === req_item.smi_ns) &&
                                                     (!item.dtr_recd || !item.dtw_rsp_recd));
           end
         <% } %>
        <% } %>
         timeout_count -= 1;
         if(((tmp_q.size() + tmp_q2.size() + tmp_q3.size() +tmp_q4.size() + tmp_q5.size() + tmp_q6.size()) !== 0) && (timeout_count != 0)) begin
           //`uvm_info("delay_debug","genMRD addr in use",UVM_LOW);
           if($test$plusargs("slow_seq_delays")) begin
             #10ns;
           end
           else begin
             #1ns;
           end
         end
         end
         addr_search_done =1;
      end while (((tmp_q.size() + tmp_q2.size() + tmp_q3.size() +tmp_q4.size() + tmp_q5.size() + tmp_q6.size()) !== 0) && (timeout_count != 0)); // UNMATCHED !!

      reuseQNoMatchInFlight(reuseQFlag,tmp_q.size(),tmp_q2.size());

      if(error_test_flg)begin
        if(!(addr_cnt%8) && (addr_cnt >0))begin
          toggle_flg = ~toggle_flg;
        end
      end

      if(timeout_count == 0) begin
         `uvm_fatal("dmi_base_seq", "MRD addr choice loop timed out")
      end
      mrd_prefHitInUseMrd = 0;
      `uvm_info("genMrdPkt",$sformatf("error_test_flg :%0b error_addr_cnt :%0d toggle_flg :%0b  MRD Addr:0x%0x Sec: %0b",error_test_flg,error_addr_cnt,toggle_flg,req_item.smi_addr, req_item.smi_ns),UVM_DEBUG);
   endtask // genMrdPkt

  //////////////////////////////////////////////////////////////////////////////////
  // DTW
  //////////////////////////////////////////////////////////////////////////////////
     task chooseClAddr(smi_seq_item req_item);
        // choose addr
        int tmp_q[$];
        int tmp_q2[$];
        int tmp_q3[$];
        int tmp_q4[$];
        int tmp_q5[$];
        int tmp_q6[$];
        int tmp_q7[$];
        int rb_rls_reuse_q[$];
        int chooseFrom;
        bit reuseQFlag = 0;
  
        timeout_count = 500000*slow;
        size_count = 0;
        chooseFrom = $urandom_range(100,0);
  
  
          do begin
                 if(!bw_test)begin
                   if(addr_reused_flg)begin
                      tryReuseQueue(req_item, reuseQFlag);
                   end
                   req_item.smi_addr = req_item.smi_addr - req_item.smi_addr[$clog2(SYS_nSysCacheline):0]; // reset alignment for writes
                 end
             if(bw_test)begin
               reuseQFlag = 0;
             end

             if (reuseQFlag == 0) begin
  <% if(obj.DutInfo.useCmc) { %>
             if(!warmup_done && cache_warmup_flg)begin
               req_item.smi_addr          = cache_addr_list_q[addr_cnt];
             end
             else if (conc_15195_flg) begin
               req_item.smi_addr = conc_15195_addr_q[addr_cnt];
             end
             else begin
               if($test$plusargs("k_use_cache_addr_list_q")) begin
                    req_item.smi_addr       = cache_addr_list_q[$urandom_range(cache_addr_list_q.size()-1, 0)];
               end 
               else if(use_evict_addr_flg) begin
                 req_item.smi_addr =  evict_addr_q[evict_addr_idx];
                 if(evict_addr_idx ==  evict_addr_q.size()-1) begin
                   evict_addr_idx = 0;
                 end
                 else evict_addr_idx++;
               end
               else if(target_sp_addr_edges_flg && $urandom_range(0,1)) begin
                 req_item.smi_addr = sp_addr_edges_q[sp_edges_idx];
                 `uvm_info("SEQ",$sformatf("Choosing SP address edges q_idx[%0d] :%0h", sp_edges_idx, req_item.smi_addr),UVM_DEBUG)
                 if(sp_edges_idx == sp_addr_edges_q.size()-1) begin
                   sp_edges_idx = 0;
                 end
                 else sp_edges_idx++;
               end
               else begin
  <% } %>
               req_item.smi_addr          =  genCacheAddresses(req_item.smi_msg_type);
               if(!(sp_enabled & isSpAddrAfterTranslate(req_item.smi_addr)))begin
                 req_item.smi_addr[($clog2(SYS_nSysCacheline)-1):0] = 0;
                 req_item.smi_addr          += $urandom_range(SYS_nSysCacheline-1,0);
               end
  <% if(obj.DutInfo.useCmc) { %>
               end
             end
  <% }  %>
              cache_addr_list_entry = new();
           <%if (obj.wSecurityAttribute>0){%>
               if(isSpAddrAfterTranslate(req_item.smi_addr)) begin
                 //NS bit propagation should be top-down based on what is configured in USMCSPBR0/1
                 req_item.smi_ns = k_sp_ns;
               end
               else begin
                 req_item.smi_ns = k_force_ns ? 1 : $urandom;
               end
           <% } else { %>
                req_item.smi_ns = 0;
           <% } %>
                req_item.smi_ca      = $urandom;
                req_item.smi_pr      = $urandom;
                
                if($urandom_range(1,100) < 25)begin
                  if(mrd_pref_addr_list_q.size()>0)begin
                     cache_addr_list_entry = mrd_pref_addr_list_q.pop_back();
                     req_item.smi_addr     = cache_addr_list_entry.addr; 
                     req_item.smi_ns = cache_addr_list_entry.security;
                     `uvm_info("SEQ",$sformatf("getting last mrd_pref addr for dtw req_addr :%0x security :%0b",cache_addr_list_entry.addr,cache_addr_list_entry.security),UVM_DEBUG);
                  end
                end
                tmp_q3 = cache_addr_list.find_index with ((cl_aligned(item.addr) === cl_aligned(req_item.smi_addr)) &&
                                                  (item.security === req_item.smi_ns));
                if(!tmp_q3.size())begin
                  cache_addr_list_entry.addr          = req_item.smi_addr;
                  cache_addr_list_entry.security  = req_item.smi_ns;
                  cache_addr_list.push_back(cache_addr_list_entry);
                end
                tmp_q = {};
                print_dtw_info_q();
             end
             `uvm_info("mas_seq DTW chooseClAddr", $sformatf("cache_addr=0x%x reuseQFlag=%0b", req_item.smi_addr,reuseQFlag),UVM_DEBUG)
             if(rb_rls_reuse_q.size()!=0 && timeout_count <= ((500000*slow)-100)) begin //Never executes first 100 attempts
               int reuse_rb, gid_flip_reuse_rb, find_q[$];
               if(!isRbRelease({~req_item.smi_rbid[WSMIRBID-1],req_item.smi_rbid[WSMIRBID-2:0]}))begin
                rb_rls_reuse_q = {};
                rb_rls_reuse_q = dtw_info.find_index with ((cl_aligned(item.cache_addr) ===
                                                            cl_aligned(req_item.smi_addr)) &&
                                                            (item.security === req_item.smi_ns) &&
                                                            item.rb_rl_rsp_expd &&
                                                            (isDtw(req_item.smi_msg_type) || ( isDtwMrgMrd(req_item.smi_msg_type)))
                                                          );
               end
               foreach( rb_rls_reuse_q[i]) begin
                 reuse_rb = dtw_info[rb_rls_reuse_q[i]].smi_rbid;
                 gid_flip_reuse_rb = {~reuse_rb[WSMIRBID-1], reuse_rb[WSMIRBID-2:0]};
                 find_q = rbid_release_q.find_index with(item.rbid == reuse_rb);
                 if($size(find_q) != 0 && !used_cohrbid_q.exists(gid_flip_reuse_rb)) begin
                   home_dce_unit_id = dcefunitId[reuse_rb[WSMIRBID-2:0]/<%=obj.DceInfo[0].nRbsPerDmi%>]; 
                   rbid_release_q.delete(find_q[0]);
                   if(gid_flip_reuse_rb[WSMIRBID-1]) gid1_rb_status[gid_flip_reuse_rb[WSMIRBID-2:0]] = 1;
                   else gid0_rb_status[gid_flip_reuse_rb[WSMIRBID-2:0]] = 1;
                   `uvm_info("mas_seq RB Release",$sformatf("Overriding alloted RBID:%0h to RBID:%0h to avoid resource contention this will trigger an internal release on RBID:%0h",req_item.smi_rbid, gid_flip_reuse_rb, reuse_rb), UVM_MEDIUM)
                   release_cohrbid(req_item.smi_rbid);
                   req_item.smi_rbid = gid_flip_reuse_rb;
                   used_cohrbid_q[gid_flip_reuse_rb] = 1;
                   break;
                 end
               end
             end
             tmp_q = dtw_info.find_index with ((cl_aligned(item.cache_addr) ===
                                                cl_aligned(req_item.smi_addr)) &&
                                               (item.security === req_item.smi_ns)&&
                                               //If CL aligned address exists and the RBID chosen releases the old RBID
                                               !((item.rb_rl_rsp_expd &&
                                                 item.smi_rbid[WSMIRBID-2:0] == req_item.smi_rbid[WSMIRBID-2:0] &&
                                                 item.smi_rbid[WSMIRBID-1] != req_item.smi_rbid[WSMIRBID-1] && isDtw(req_item.smi_msg_type)) ||
                                                 (!isDtw(req_item.smi_msg_type) && item.rb_rl_rsp_expd))
                                               );
             `uvm_info("dmi_base_seq", $sformatf("tmp_q size %0d",tmp_q.size()),UVM_DEBUG)
             rb_rls_reuse_q = {};
             if (tmp_q.size() !== 0) begin
                `uvm_info("mas_seq DTW chooseClAddr",
                          $sformatf("Addr is already in use in dtw queue. Choosing again Timeout Count:%0d RBID:%0h MsgType:%0h",timeout_count, req_item.smi_rbid, req_item.smi_msg_type),UVM_DEBUG)
                if(!isRbRelease({~req_item.smi_rbid[WSMIRBID-1],req_item.smi_rbid[WSMIRBID-2:0]}))begin
                 rb_rls_reuse_q = dtw_info.find_index with ((cl_aligned(item.cache_addr) ===
                                                             cl_aligned(req_item.smi_addr)) &&
                                                             (item.security === req_item.smi_ns) &&
                                                             item.rb_rl_rsp_expd &&
                                                             (isDtw(req_item.smi_msg_type) || ( isDtwMrgMrd(req_item.smi_msg_type)))
                                                           );
                end
             end
             tmp_q2 = mrd_info.find_index with ((cl_aligned(item.cache_addr) ===
                                                 cl_aligned(req_item.smi_addr)) &&
                                                (item.security === req_item.smi_ns));
             `uvm_info("dmi_base_seq", $sformatf("tmp_q size %0d",tmp_q.size()),UVM_DEBUG)
            if(mrd_info.size()>0)begin
               foreach (mrd_info[i]) begin
                  `uvm_info("dmi_base_seq MRD", $sformatf("MRD Info Addr [39:%0d]=0x%0x sec:%0b",
                                                         $clog2(WSMIDPBE),
                                                         cl_aligned(mrd_info[i].cache_addr),
                                                         mrd_info[i].security),UVM_DEBUG)
               end
             end
             if (tmp_q2.size() >0) begin
                `uvm_info("mas_seq DTW chooseClAddr",
                          $sformatf("Addr is already in use in mrd queue. Choosing again"),UVM_DEBUG)
             end

        <% if(obj.DutInfo.useCmc) { %>
         <%  if(obj.DmiInfo[obj.Id].ccpParams.useScratchpad) { %>
           if(isSpAddrAfterTranslate(req_item.smi_addr)) begin
             if(isNcWr(req_item.smi_msg_type)||isNcRd(req_item.smi_msg_type)||isAtomics(req_item.smi_msg_type)) begin
                // 
             end else begin
               tmp_q5 = NcRd_info.find_index with ((cl_aligned(item.cache_addr) === cl_aligned(req_item.smi_addr)) &&
                                                     (item.security === req_item.smi_ns) &&
                                                     (!item.dtr_recd));
               tmp_q6 = NcWr_info.find_index with ((cl_aligned(item.cache_addr) === cl_aligned(req_item.smi_addr)) &&
                                                     (item.security === req_item.smi_ns) && 
                                                     (!item.dtw_rsp_recd)); 
               tmp_q7 = AtmLd_info.find_index with ((cl_aligned(item.cache_addr) === cl_aligned(req_item.smi_addr)) &&
                                                     (item.security === req_item.smi_ns) &&
                                                     (!item.dtr_recd || !item.dtw_rsp_recd)); 
             end
           end
         <%}%>
        <%}%>
             timeout_count -= 1;
             size_count += 1;
             if(((tmp_q.size()+tmp_q2.size() + tmp_q5.size() + tmp_q6.size() + tmp_q7.size()) !== 0) && (timeout_count != 0)) begin
               //`uvm_info("delay_debug","chooseClAddr addr in use",UVM_LOW);
               if($test$plusargs("slow_seq_delays")) begin
                 #10ns;
               end
               else begin
                 #1ns;
               end
             end
             `uvm_info("mas_seq DTW chooseClAddr", "Waiting for addresses to free up",UVM_DEBUG)
             size_count = 0;
          end while (((tmp_q.size()+tmp_q2.size() + tmp_q5.size() + tmp_q6.size() + tmp_q7.size()) !== 0) && (timeout_count != 0));

      reuseQNoMatchInFlight(reuseQFlag,tmp_q.size(),tmp_q2.size());
      if(timeout_count == 0) begin
         `uvm_fatal("mas_seq DTW chooseClAddr", "DTW addr choice loop timed out")
      end
     `uvm_info("mas_seq DTW chooseClAddr",
               $sformatf("cache_addr=0x%x fromReuseQ=%0b",
                         req_item.smi_addr,reuseQFlag),UVM_DEBUG)
     if(mrd_bw_flg || perf_test_flg || addr_reused_flg)begin
       AddrQ_t addrItem;
       addrItem = new();
       addrItem.cache_addr = req_item.smi_addr;
       addrItem.security   = req_item.smi_ns;
       addToReuseQ(addrItem);
     end
   endtask // chooseClAddr




   function chooseLength(smi_seq_item req_item, bit atomic = 0);
      // decide length
      int maxPayloadBytes, numPayloadBytes;
      int allowedPayloadBytes[$];
      bit increment_size_counter = 0;
    //  case (req_item.smi_burst)
    //    INCR: begin
    //       maxPayloadBytes = clSizeInBytes +
    //       (cl_aligned(req_item.smi_addr) << $clog2(nSysCacheline)) - req_item.smi_addr;
    //       numPayloadBytes = ($urandom_range(maxPayloadBytes/MINALIGN,1) << INCRALIGN);
    //       numDtwCycles = $ceil(real'((beatn % (2**BEAT_INDEX_LOW)) + numPayloadBytes) /
    //                            real '(2**BEAT_INDEX_LOW));
    //       `uvm_info("mas_seq DTW chooseLength",
    //                 $sformatf("addr:0x%0x maxPayloadBytes:0x%0x numPayloadBytes:0x%0x \
    //numDtwCycles:%0d length:0x%x Cacheline:0x%x WDATA:0x%x",
    //                           req_item.smi_addr, maxPayloadBytes, numPayloadBytes,
    //                           numDtwCycles, req_item.smi_size,nSysCacheline,
    //                           <%=obj.DmiInfo[0].wData%>),UVM_DEBUG)
    //        req_item.smi_mpf1_burst_type = 2'b01;
    //    end
    //    WRAP: begin
<%      switch(true) {
         case((obj.DmiInfo[0].wData/8) == 32): %>
           allowedPayloadBytes = {64};
           numPayloadBytes = allowedPayloadBytes[0];
<%         break;
         case((obj.DmiInfo[0].wData/8) == 16): %>
           allowedPayloadBytes = {32,64};
           numPayloadBytes = allowedPayloadBytes[$urandom_range(1,0)];
<%         break;
         case((obj.DmiInfo[0].wData/8) == 8): %>
           allowedPayloadBytes = {16,32,64};
           numPayloadBytes = allowedPayloadBytes[$urandom_range(2,0)];
<%         break;
} %>

          numDtwCycles = numPayloadBytes / <%=(obj.DmiInfo[0].wData/8)%>;
          req_item.smi_mpf1_burst_type = 2'b00;

    //    end
    //  endcase // case (req_item.req_burst)
      if(req_item.smi_msg_type inside {DTW_DATA_CLN,DTW_DATA_DTY,CMD_WR_NC_FULL}) begin
         numPayloadBytes = 64;
         numDtwCycles = numPayloadBytes / <%=(obj.DmiInfo[0].wData/8)%>;
      end
      if(isMrd(req_item.smi_msg_type))begin
         allowedPayloadBytes = {1,2,4,8,16,32,64};
         numPayloadBytes = allowedPayloadBytes[$urandom_range(6,0)];
         //numPayloadBytes = 64;
      end

      if(req_item.smi_msg_type inside {MRD_PREF,CMD_PREF})begin
        numPayloadBytes = 64;
      end
      else if(isDtwMrgMrd(req_item.smi_msg_type) && req_item.smi_prim)begin
         allowedPayloadBytes = {1,2,4,8,16,32,64};
         numPayloadBytes = allowedPayloadBytes[$urandom_range(6,0)];
         //numPayloadBytes = 64;
      end
      else if(isDtwMrgMrd(req_item.smi_msg_type) && !req_item.smi_prim)begin
        numPayloadBytes = 64;
      end
      else if(req_item.smi_msg_type == DTW_DATA_PTL || req_item.smi_msg_type == CMD_WR_NC_PTL)begin
         allowedPayloadBytes = {1,2,4,8,16,32,64};
         numPayloadBytes = allowedPayloadBytes[$urandom_range(6,0)];    
      end
      else if (isNcRd(req_item.smi_msg_type)) begin
         allowedPayloadBytes = {1,2,4,8,16,32,64};
         numPayloadBytes = allowedPayloadBytes[$urandom_range(6,0)];
         //numPayloadBytes = 64;
      end
      else if(req_item.smi_msg_type inside {CMD_WR_ATM,CMD_RD_ATM,CMD_SW_ATM})begin
         allowedPayloadBytes = {1,2,4,8};
         numPayloadBytes = allowedPayloadBytes[$urandom_range(3,0)];    
      end
      else if(req_item.smi_msg_type == CMD_CMP_ATM)begin
         allowedPayloadBytes = {2,4,8,16,32};
         if(k_atomic_directed) begin
            numPayloadBytes = allowedPayloadBytes[size_counter];
         end 
         else begin
            numPayloadBytes = allowedPayloadBytes[$urandom_range(4,0)];
         end
      end

      //directed atomic testcase
      if(k_atomic_directed && req_item.smi_msg_type == CMD_CMP_ATM) begin
        req_item.smi_addr[($clog2(SYS_nSysCacheline)-1):0] = '0;
        req_item.smi_addr[($clog2(SYS_nSysCacheline)-1):0] = addr_offset_counter;
        if(addr_offset_counter + 2**size_counter >= 64) begin
            increment_size_counter = 1;
        end
        addr_offset_counter += 2**size_counter;
        if(increment_size_counter) size_counter++;
        if(increment_size_counter && size_counter>=5) begin
            size_counter=0;
            intfsize_counter++;
        end
      end
    
      if(k_full_cl_only && !(req_item.smi_msg_type inside {CMD_WR_ATM, CMD_RD_ATM, CMD_SW_ATM, CMD_CMP_ATM}))begin
         numPayloadBytes = 64;
      end

      if(k_force_size>0)begin
         numPayloadBytes = k_force_size;
      end

      beatn   = (req_item.smi_addr[BEAT_INDEX_HIGH:BEAT_INDEX_LOW])<<BEAT_INDEX_LOW;

      numDtwCyclesSmi = $ceil(real'((beatn % (2**BEAT_INDEX_LOW)) + numPayloadBytes) /
                           real '(2**BEAT_INDEX_LOW));

      req_item.smi_size       = $clog2(numPayloadBytes);

      Initiator_Intfsize      = (2**req_item.smi_intfsize)*8;

      if(numPayloadBytes <= Initiator_Intfsize) begin
        numDtwCycles = 1;
      end
      else begin
        numDtwCycles = numPayloadBytes/Initiator_Intfsize;
      end
    
      `uvm_info("mas_seq chooseLength:0",$sformatf("Initiator_Intfsize :%0d,numPayloadBytes:%0d",Initiator_Intfsize,numPayloadBytes),UVM_DEBUG);

      if(req_item.smi_msg_type == CMD_CMP_ATM)begin
         numPayloadBytes         = 2**req_item.smi_size;
         if(!k_atomic_directed) begin
            req_item.smi_addr       = (req_item.smi_addr/numPayloadBytes)*numPayloadBytes;
         end
      end
      else if(numPayloadBytes >= Initiator_Intfsize) begin //Align to interface only if accesses are not exclusive
        req_item.smi_addr       = (req_item.smi_addr/Initiator_Intfsize)*(Initiator_Intfsize);
      end
      else begin
        req_item.smi_addr       = (req_item.smi_addr/numPayloadBytes)*numPayloadBytes;
      end
      //#Stimulus.DMI.CMDreq.Excel.Asize
      req_item.smi_mpf1_asize = $clog2(numPayloadBytes);
      req_item.smi_mpf1_alength = 0;
         `uvm_info("mas_seq chooseLength",
                $sformatf("addr:0x%0x numPayloadBytes:0x%0x numDtwCycles:%0d numDtwCyclesSmi:%0d beatn :%0b\
                           length:0x%x Cacheline:0x%x WDATA:0x%x", req_item.smi_addr, numPayloadBytes,
                          numDtwCycles,numDtwCyclesSmi,beatn,req_item.smi_size,nSysCacheline,
                          <%=obj.DmiInfo[0].wData%>),UVM_DEBUG)
   endfunction // chooseLength

`ifdef DATA_DROP
   function chooseBE(smi_seq_item req_item);
      bit [7:0]                      tmp_dp_be     [8];
      bit                            tmp_dp_dbad   [8];
      bit [WSMIDPDWIDPERDW:0]        tmp_dp_dwid   [8];
      bit [63:0]                     tmp_dp_data   [8];
      bit [63:0]                     tmp_data;
      smi_addr_t  tmp_smi_addr,initiator_beat_aligned_addr;
      int min_be_bit = 0;
      int max_be_bit = 0;
      int be_counter = 0;
      int dwid_counter,dwid_counter_max;
      int numPayloadBytes;
      int smi_dp_size;
      bit deassert_be = 0;
      bit last_be = $urandom_range(1,0);
      int  dwid;
      int  dwid_l;
      int  dwid_h;

      int                   num_cmp_bytes;
      smi_addr_t            swap_addr;
      int                   swap_min_be_bit, cmp_min_be_bit;
      int                   atm_cmp_dtw_cycles;
      smi_addr_t            min_addr;
      smi_addr_t            min_addr_beat_aligned;
      axi_axaddr_security_t axi_addr_sec;
      axi_axaddr_security_t cacheline_aligned_addr_sec;
      axi_axlen_t           axi_len;
      axi_axsize_t          axi_size;
      axi_xdata_t           axi_data[];
      int                   start_byte_addr, end_byte_addr;
      int                   start_index;
      int                   dw_index, dw_byte_addr, axi_data_beat_index, axi_byte_addr;

      // choose BE bits
      initiator_beat_aligned_addr = beat_aligned(req_item.smi_addr,(2**req_item.smi_intfsize)*8);
      `uvm_info("mas_seq DTW chooseBE",$sformatf("initiator_beat_aligned_addr :%0x",initiator_beat_aligned_addr),UVM_DEBUG)

      min_be_bit = (req_item.smi_addr - initiator_beat_aligned_addr);
                     //<< $clog2(WSMIDPBE))); // addr % beat align
      max_be_bit = min_be_bit + (2**req_item.smi_size); // min + req_length
     
      //directed atomic testcase
      if(k_atomic_directed && req_item.smi_msg_type == CMD_CMP_ATM) begin
        num_cmp_bytes = (2**req_item.smi_size)/2;  
        swap_addr     = req_item.smi_addr;
        swap_addr[$clog2(num_cmp_bytes)] = ~req_item.smi_addr[$clog2(num_cmp_bytes)];
        swap_min_be_bit = swap_addr - initiator_beat_aligned_addr;
        cmp_min_be_bit  = req_item.smi_addr  - initiator_beat_aligned_addr;
        if((2**req_item.smi_size) <= ((2**req_item.smi_intfsize)*8)) begin
            min_be_bit = (swap_min_be_bit<cmp_min_be_bit)? swap_min_be_bit : cmp_min_be_bit;
            max_be_bit = min_be_bit + (2**req_item.smi_size);
        end
        else begin
            atm_cmp_dtw_cycles = (2**req_item.smi_size)/((2**req_item.smi_intfsize)*8);
            min_addr = (swap_addr<req_item.smi_addr)? swap_addr:req_item.smi_addr;
            min_addr_beat_aligned = beat_aligned(min_addr, (2**req_item.smi_intfsize)*8);
            min_be_bit = min_addr - min_addr_beat_aligned;
            max_be_bit = min_be_bit + atm_cmp_dtw_cycles*((2**req_item.smi_intfsize)*8);
        end
      end
      //

      be_counter = 0;
      dwid_counter_max = 0;
      `uvm_info("mas_seq DTW chooseBE",
                $sformatf("length:0x%0x addr:0x%0x beat_addr:0x%0x min_be_bit:0x%0d max_be_bit:0x%0d smi_msg_type :%0x",
                          req_item.smi_size,req_item.smi_addr,
                          beat_aligned(req_item.smi_addr,(2**req_item.smi_intfsize)*8),min_be_bit,max_be_bit,req_item.smi_msg_type), UVM_DEBUG)

      Initiator_Intfsize  = (2**req_item.smi_intfsize)*8;
      numPayloadBytes     = 2**req_item.smi_mpf1_asize;

      if(numPayloadBytes <= Initiator_Intfsize) begin
        numDtwCycles = 1;
      end
      else begin
        numDtwCycles = numPayloadBytes/Initiator_Intfsize;
      end

      `uvm_info("mas_seq chooseLength:1",$sformatf("Initiator_Intfsize :%0d,numPayloadBytes:%0d",Initiator_Intfsize,numPayloadBytes),UVM_DEBUG);
   //   tmp_dp_be    = new[numDtwCycles*(2**req_item.smi_intfsize)];
   //   tmp_dp_dbad  = new[numDtwCycles*(2**req_item.smi_intfsize)];
      dwid   = (initiator_beat_aligned_addr/8)%8;
      if((2**req_item.smi_size) > Initiator_Intfsize)begin
        tmp_smi_addr  = ((req_item.smi_addr >>req_item.smi_size)<<req_item.smi_size);
       `uvm_info("mas_seq DTW chooseBid",$sformatf("smi_addr :%0x tmp_smi_addr :%0x smi_size :%0d ",req_item.smi_addr,tmp_smi_addr,req_item.smi_size),UVM_DEBUG);

        dwid_l = tmp_smi_addr[5:3];
        dwid_h = dwid_l+((2**req_item.smi_size)/8)-1;
        //req_item.smi_addr = tmp_smi_addr;
        //`uvm_info("mas_seq DTW alignAddr",$sformatf("smi_addr :%0x ",req_item.smi_addr),UVM_DEBUG);
      end
      else begin
        tmp_smi_addr  = ((req_item.smi_addr >>(3+req_item.smi_intfsize))<<(3+req_item.smi_intfsize));
       `uvm_info("mas_seq DTW chooseBid",$sformatf("smi_addr :%0x tmp_smi_addr :%0x smi_size :%0d ",req_item.smi_addr,tmp_smi_addr,req_item.smi_intfsize),UVM_DEBUG);

        dwid_l = tmp_smi_addr[5:3];
        dwid_h = dwid_l+(2**req_item.smi_intfsize)-1;
        //req_item.smi_addr = tmp_smi_addr;
        //`uvm_info("mas_seq DTW alignAddr",$sformatf("smi_addr :%0x ",req_item.smi_addr),UVM_DEBUG);
      end

      `uvm_info("mas_seq DTW chooseBid",$sformatf("dwid :%0d dwid_l :%0d dwid_h :%0d",dwid,dwid_l,dwid_h),UVM_DEBUG);
      dwid_counter_max = 0;

      for (int i=0; i < numDtwCycles; i++) begin
        for (int k= 0; k< 2**req_item.smi_intfsize;k++)begin
           deassert_be = $urandom_range(1,100) < 10 && smi_dtw_err;
           `uvm_info("dmi_base_seq",$sformatf("for DTW_DATA_CLN,DTW_DATA_DTY  deassert_be :%b",deassert_be),UVM_DEBUG);
           ///////////////////////////////////////////////////
           // setting BE for write data
           //////////////////////////////////////////////////
           for (int j=0; j < 8; j++) begin
              if(req_item.smi_msg_type inside {DTW_NO_DATA}) begin
                 tmp_dp_be[dwid_counter_max][j] = 0;
              end
              else if(req_item.smi_msg_type inside {DTW_DATA_CLN,DTW_DATA_DTY}) begin
                if(deassert_be) begin 
                   tmp_dp_be[dwid_counter_max][j] = 0;
                end
                else begin
                   tmp_dp_be[dwid_counter_max][j] = 1;
                end
              end
              else begin
                 if ((be_counter >= min_be_bit) && (be_counter < max_be_bit)) begin // be bit is in allowed range
                   if(!force_alternate_be)begin
                     if(!$test$plusargs("all_byte_enables_on"))begin
                       if((req_item.smi_msg_type == DTW_DATA_PTL || isDtwMrgMrd(req_item.smi_msg_type)) && (req_item.smi_size >2))begin
                        tmp_dp_be[dwid_counter_max][j] = $urandom_range(1,0);
                       end
                       else begin
                        tmp_dp_be[dwid_counter_max][j] = 1;
                       end
                     end
                     else begin
                       tmp_dp_be[dwid_counter_max][j] = 1;
                     end
                   end
                   else begin
                    tmp_dp_be[dwid_counter_max][j] = ~last_be;
                    last_be = tmp_dp_be[dwid_counter_max][j];
                   end
                end
                else begin
                   tmp_dp_be[dwid_counter_max][j] = 0;
                end
              end
              if ($test$plusargs("random_dbad_on_DTWreq")) begin
                tmp_dp_dbad[i+k] = $random;
                `uvm_info("mas_seq DTW Dbad",
                        $sformatf("Dbad[%0d]=0x%0x",dwid_counter_max, tmp_dp_dbad[dwid_counter_max]), UVM_DEBUG)
              end
              else if ($test$plusargs("dbad_on_DTW_PTL") && (req_item.smi_msg_type ==DTW_DATA_PTL)) begin
                tmp_dp_dbad[i+k] = 1;
                `uvm_info("mas_seq DTW PTL Dbad",
                        $sformatf("Dbad[%0d]=0x%0x",dwid_counter_max, tmp_dp_dbad[dwid_counter_max]), UVM_DEBUG)
              end
              be_counter += 1;
              `uvm_info("mas_seq DTW chooseBE",
                        $sformatf("be_counter=0x%0d be[%0d][%0d]=0x%0x", be_counter, dwid_counter_max,j,
                                  tmp_dp_be[dwid_counter_max][j]), UVM_DEBUG)
           end
           `uvm_info("mas_seq DTW chooseBE",
                     $sformatf("be[%0d]=0x%0x dwid_counter_max :%0d", dwid_counter_max, tmp_dp_be[dwid_counter_max],dwid_counter_max), UVM_DEBUG)
            dwid_counter_max++;
            ///////////////////////////////////////////////////
            // setting Dwid for write data
            //////////////////////////////////////////////////
            if(dwid_counter < dwid_counter_max)begin
              assert(std::randomize(tmp_data))
                else begin
                   uvm_report_error("SYS BFM SEQ", "Failure to randomize tmp", UVM_DEBUG);
                end
              tmp_dp_dwid[i*(2**req_item.smi_intfsize)+k]  = dwid;
              if($test$plusargs("static_dp_data"))
                tmp_dp_data[i*(2**req_item.smi_intfsize)+k]  = nonrandom_DPdata; 
              else
                tmp_dp_data[i*(2**req_item.smi_intfsize)+k]  = tmp_data; 
              dwid++;
              dwid_counter++;
              if((2**req_item.smi_size) > 8)begin
                if(dwid >dwid_h)begin
                  dwid = dwid_l; 
                end
              end
             `uvm_info("mas_seq DTW chooseBid",
                       $sformatf("dwid[%0d][%0d]=0x%0x", i,k,tmp_dp_dwid[i*(2**req_item.smi_intfsize)+k]), UVM_DEBUG)
            end
         end
       end

      if((2**req_item.smi_size) < Initiator_Intfsize)begin
        if(req_item.smi_msg_type == CMD_CMP_ATM && !k_atomic_directed)begin
           numPayloadBytes = (2**req_item.smi_size)/2;
           req_item.smi_addr[$clog2(numPayloadBytes)] = $urandom_range(0,1);
        end
      end

      //directed atomic testcase
      if(req_item.smi_msg_type == CMD_CMP_ATM && k_atomic_directed) begin
        axi_addr_sec = {req_item.smi_ns, req_item.smi_addr};
        axi_len = (SYS_nSysCacheline/(WXDATA/8))-1;
        axi_size = $clog2(WXDATA/8);
        cacheline_aligned_addr_sec = axi_addr_sec;
        cacheline_aligned_addr_sec[($clog2(SYS_nSysCacheline)-1):0] = '0;
        //FIXMEmem m_axi_memory_model.preload_memory(cacheline_aligned_addr_sec);
        //FIXMEmem m_axi_memory_model.read_data(cacheline_aligned_addr_sec, axi_len, axi_size, axi_data);
        start_index = (swap_addr>req_item.smi_addr)?0:(req_item.smi_addr[($clog2(SYS_nSysCacheline)-1):3]-swap_addr[($clog2(SYS_nSysCacheline)-1):3]);
        start_byte_addr = {start_index, req_item.smi_addr[2:0]};
        end_byte_addr = start_byte_addr + ((2**req_item.smi_size)/2); 

        for(int i = start_byte_addr, j=axi_addr_sec; i < end_byte_addr; i++,j++) begin
           dw_index = i[($clog2(SYS_nSysCacheline)-1):3];
           dw_byte_addr = i[2:0];
           axi_data_beat_index = j[BEAT_INDEX_HIGH:BEAT_INDEX_LOW];
           axi_byte_addr = j[BEAT_INDEX_LOW-1:0];
           tmp_dp_data[dw_index][dw_byte_addr*8+:8] = axi_data[axi_data_beat_index][axi_byte_addr*8+:8];

           `uvm_info("dmi_base_seq",$sformatf("dw_index %0h dw_byte_addr %0h axi_data_beat_index %0h axi_byte_addr %0h", dw_index, dw_byte_addr, axi_data_beat_index, axi_byte_addr), UVM_DEBUG)
        end
    end
    //

      foreach(tmp_dp_data[i])begin
        `uvm_info("dmi_base_seq",$sformatf("tmp_dp_data[%0d] :%0x",i,tmp_dp_data[i]),UVM_DEBUG);
        `uvm_info("dmi_base_seq",$sformatf("tmp_dp_be[%0d]   :%0b",i,tmp_dp_be[i]),UVM_DEBUG);
        `uvm_info("dmi_base_seq",$sformatf("tmp_dp_dwid[%0d] :%0x",i,tmp_dp_dwid[i]),UVM_DEBUG);
        `uvm_info("dmi_base_seq",$sformatf("tmp_dp_dbad[%0d] :%0x",i,tmp_dp_dbad[i]),UVM_DEBUG);
      end

        smi_dp_size = (numDtwCycles*(2**req_item.smi_intfsize)*64)/WDATA;
  
        if((numDtwCycles*(2**req_item.smi_intfsize)*64) < WDATA)begin
          smi_dp_size = 1;
        end
        `uvm_info("dmi_base_seq",$sformatf("numDtwCycles :%0d 2**req_item.smi_intfsize)*64 :%0d WDATA :%0d  smi_dp_size :%0d",numDtwCycles,(2**req_item.smi_intfsize)*64,WDATA,smi_dp_size),UVM_DEBUG);

        req_item.smi_dp_be     = new[smi_dp_size];
        req_item.smi_dp_dwid   = new[smi_dp_size];
        req_item.smi_dp_data   = new[smi_dp_size];
        req_item.smi_dp_dbad   = new[smi_dp_size];

        foreach(req_item.smi_dp_data[i])begin
         for(int j = 0; j< WDATA/64;j++)begin
          req_item.smi_dp_be[i][j*8+:8]                               =  tmp_dp_be[i*(WDATA/64)+j];
          req_item.smi_dp_dwid[i][j*WSMIDPDWIDPERDW+:WSMIDPDWIDPERDW] =  tmp_dp_dwid[i*(WDATA/64)+j];
          req_item.smi_dp_data[i][j*64+:64]                           =  tmp_dp_data[i*(WDATA/64)+j];
          req_item.smi_dp_dbad[i][j]                                  =  tmp_dp_dbad[i*(WDATA/64)+j];
          end
        end
      foreach(req_item.smi_dp_data[i])begin
        `uvm_info("dmi_base_seq",$sformatf("req_item.smi_dp_data[%0d] :%0x",i,req_item.smi_dp_data[i]),UVM_DEBUG);
        `uvm_info("dmi_base_seq",$sformatf("req_item.smi_dp_be[%0d]   :%0b",i,req_item.smi_dp_be[i]),UVM_DEBUG);
        `uvm_info("dmi_base_seq",$sformatf("req_item.smi_dp_dwid[%0d] :%0x",i,req_item.smi_dp_dwid[i]),UVM_DEBUG);
        `uvm_info("dmi_base_seq",$sformatf("req_item.smi_dp_dbad[%0d] :%0b",i,req_item.smi_dp_dbad[i]),UVM_DEBUG);
      end
      `uvm_info("dmi_base_seq",$sformatf("req_item :%0p",req_item),UVM_DEBUG);
   endfunction

`else
   function setData(smi_seq_item req_item);
      smi_dp_data_bit_t tmp;
      req_item.smi_dp_data = new[numDtwCyclesSmi];
      for (int dataindex=0;dataindex<(numDtwCyclesSmi);dataindex++) begin
         assert(std::randomize(tmp))
           else begin
              uvm_report_error("SYS BFM SEQ", "Failure to randomize tmp", UVM_DEBUG);
           end
         req_item.smi_dp_data[dataindex] = tmp;
         `uvm_info("mas_seq DTW setData",
                   $sformatf("dataindex[0x%0x]=0x%x",
                             dataindex,req_item.smi_dp_data[dataindex]),UVM_DEBUG)
      end
      `uvm_info("mas_seq DTW setData",
                $sformatf("smi_msg_id=0x%0x,cmd_msg_type=0x%0x", req_item.smi_msg_id,
                          req_item.smi_msg_type),UVM_DEBUG)
      for (int dataindex=0;dataindex<(numDtwCyclesSmi);dataindex++) begin
         `uvm_info("mas_seq DTW setData",
                   $sformatf("data[0x%0x]=0x%x", dataindex,
                             req_item.smi_dp_data[dataindex]),UVM_DEBUG)
      end
   endfunction // setData

   function chooseBE(smi_seq_item req_item);
      bit [7:0]   tmp_dp_be     [];
      bit         tmp_dp_dbad   [];
      smi_addr_t  tmp_smi_addr,initiator_beat_aligned_addr;
      int min_be_bit = 0;
      int max_be_bit = 0;
      int be_counter = 0;
      int dwid_counter,dwid_counter_max;
      int numPayloadBytes;
      bit deassert_be = 0;
      bit last_be = $urandom_range(1,0);
      bit [WSMIDPDWIDPERDW:0] dwid;
      bit [WSMIDPDWIDPERDW-1:0] dwid_l;
      bit [WSMIDPDWIDPERDW-1:0] dwid_h;
      req_item.smi_dp_be   = new[req_item.smi_dp_data.size()];
      req_item.smi_dp_dbad = new[req_item.smi_dp_data.size()];
      // choose BE bits
      initiator_beat_aligned_addr = beat_aligned(req_item.smi_addr,(2**req_item.smi_intfsize)*8);
      min_be_bit = (req_item.smi_addr - initiator_beat_aligned_addr);
                     //<< $clog2(WSMIDPBE))); // addr % beat align
      max_be_bit = min_be_bit + (2**req_item.smi_size); // min + req_length
      be_counter = 0;
      dwid_counter_max = 0;
      `uvm_info("mas_seq DTW chooseBE",
                $sformatf("length:0x%0x addr:0x%0x beat_addr:0x%0x min_be_bit:0x%0d max_be_bit:0x%0d smi_msg_type :%0x",
                          req_item.smi_size,req_item.smi_addr,
                          beat_aligned(req_item.smi_addr,(2**req_item.smi_intfsize)*8),min_be_bit,max_be_bit,req_item.smi_msg_type), UVM_DEBUG)

      Initiator_Intfsize  = (2**req_item.smi_intfsize)*8;
      numPayloadBytes     = 2**req_item.smi_mpf1_asize;

      if(numPayloadBytes <= Initiator_Intfsize) begin
        numDtwCycles = 1;
      end
      else begin
        numDtwCycles = numPayloadBytes/Initiator_Intfsize;
      end

      `uvm_info("mas_seq chooseLength:1",$sformatf("Initiator_Intfsize :%0d,numPayloadBytes:%0d",Initiator_Intfsize,numPayloadBytes),UVM_DEBUG);
      tmp_dp_be    = new[numDtwCycles*(2**req_item.smi_intfsize)];
      tmp_dp_dbad  = new[numDtwCycles*(2**req_item.smi_intfsize)];

      for (int i=0; i < numDtwCycles; i++) begin
        for (int k= 0; k< 2**req_item.smi_intfsize;k++)begin
           deassert_be = $urandom_range(1,100) < 10 && smi_dtw_err;
           `uvm_info("dmi_base_seq",$sformatf("for DTW_DATA_CLN,DTW_DATA_DTY  deassert_be :%b",deassert_be),UVM_DEBUG);
           for (int j=0; j < 8; j++) begin
              if(req_item.smi_msg_type inside {DTW_NO_DATA}) begin
                   tmp_dp_be[dwid_counter_max][j] = 0;
              end
              else if(req_item.smi_msg_type inside {DTW_DATA_CLN,DTW_DATA_DTY}) begin
                if(deassert_be) begin 
                   tmp_dp_be[dwid_counter_max][j] = 0;
                end
                else begin
                   tmp_dp_be[dwid_counter_max][j] = 1;
                end
              end
              else begin
                 if ((be_counter >= min_be_bit) && (be_counter < max_be_bit)) begin // be bit is in allowed range
                   if(!force_alternate_be)begin
                     if(req_item.smi_msg_type == DTW_DATA_PTL || isDtwMrgMrd(req_item.smi_msg_type))begin
                      tmp_dp_be[dwid_counter_max][j] = $urandom_range(1,0);
                     end
                     else begin
                      tmp_dp_be[dwid_counter_max][j] = 1;
                     end
                   end
                   else begin
                    tmp_dp_be[dwid_counter_max][j] = ~last_be;
                    last_be = tmp_dp_be[dwid_counter_max][j];
                   end
                end
                else begin
                   tmp_dp_be[dwid_counter_max][j] = 0;
                end
              end
              if ($test$plusargs("random_dbad_on_DTWreq")) begin
                tmp_dp_dbad[i+k] = $random;
                `uvm_info("mas_seq DTW Dbad",
                        $sformatf("Dbad[%0d]=0x%0x",dwid_counter_max, tmp_dp_dbad[dwid_counter_max]), UVM_DEBUG)
              end
              be_counter += 1;
              `uvm_info("mas_seq DTW chooseBE",
                        $sformatf("be_counter=0x%0d be[%0d][%0d]=0x%0x", be_counter, dwid_counter_max,j,
                                  tmp_dp_be[dwid_counter_max][j]), UVM_DEBUG)
           end
           `uvm_info("mas_seq DTW chooseBE",
                     $sformatf("be[%0d]=0x%0x dwid_counter_max :%0d", dwid_counter_max, tmp_dp_be[dwid_counter_max],dwid_counter_max), UVM_DEBUG)
            dwid_counter_max++;
        end
      end
   ///////////////////////////////////////////////////
   // setting Dbid for write data
   //////////////////////////////////////////////////
      dwid   = (initiator_beat_aligned_addr/8)%8;
      dwid_counter = 0;
      if((2**req_item.smi_size) > 8)begin
        tmp_smi_addr  = ((req_item.smi_addr >>req_item.smi_size)<<req_item.smi_size);
       `uvm_info("mas_seq DTW chooseBid",$sformatf("smi_addr :%0x tmp_smi_addr :%0x smi_size :%0d ",req_item.smi_addr,tmp_smi_addr,req_item.smi_size),UVM_DEBUG);

        dwid_l = tmp_smi_addr[5:3];
        dwid_h = dwid_l+((2**req_item.smi_size)/8)-1;
      end

      `uvm_info("mas_seq DTW chooseBid",$sformatf("dwid :%0d dwid_l :%0d dwid_h :%0d tmp_dp_be.size :%0d ",dwid,dwid_l,dwid_h,tmp_dp_be.size()),UVM_DEBUG);
      dwid_counter = 0;
      req_item.smi_dp_dwid = new[req_item.smi_dp_data.size()];
      for (int i=0; i < req_item.smi_dp_data.size(); i++) begin
         for (int j = 0; j < WDATA/64; j++) begin
          if(dwid_counter < dwid_counter_max)begin
            req_item.smi_dp_dwid[i][j*WSMIDPDWIDPERDW +: WSMIDPDWIDPERDW] = dwid;
            req_item.smi_dp_be[i][j*8+:8]                                 = tmp_dp_be[dwid_counter];
            req_item.smi_dp_dbad[i][j]                                    = tmp_dp_dbad[dwid_counter];
            dwid++;
            dwid_counter++;
            if((2**req_item.smi_size) > 8)begin
              if(dwid >dwid_h)begin
                dwid = dwid_l; 
              end
            end
           `uvm_info("mas_seq DTW chooseBid",
                     $sformatf("dwid[%0d][%0d]=0x%0x", i,j,req_item.smi_dp_dwid[i][j*WSMIDPDWIDPERDW +: WSMIDPDWIDPERDW]), UVM_DEBUG)
           `uvm_info("mas_seq DTW chooseBid",
                     $sformatf("be[%0d][%0d]=0x%0x tmp_dp_be :%0x ", i,j,req_item.smi_dp_be[i][j*8 +: 8],tmp_dp_be[dwid_counter-1]), UVM_DEBUG)
          end
         end
         `uvm_info("mas_seq DTW chooseBid",
                   $sformatf("dwid[%0d]=0x%0x", i, req_item.smi_dp_dwid[i]), UVM_DEBUG)
         `uvm_info("mas_seq DTW chooseBid",
                   $sformatf("be[%0d]=0x%0x", i, req_item.smi_dp_be[i]), UVM_DEBUG)
         `uvm_info("mas_seq DTW chooseBid",
                   $sformatf("dbad[%0d]=0x%0x", i, req_item.smi_dp_dbad[i]), UVM_DEBUG)
      end

      if(req_item.smi_msg_type == CMD_CMP_ATM)begin
         numPayloadBytes = (2**req_item.smi_size)/2;
         req_item.smi_addr[$clog2(numPayloadBytes)] = $urandom_range(0,1);
      end
   endfunction

`endif
   ////////////////////////////////////////////
   // set initiator interface size
   ////////////////////////////////////////////
   function void set_intfsize(ref smi_seq_item req_item,input aiu_id_queue_t aiu_unq_id);
   `ifdef DATA_ADEPT      
     if(k_intfsize >2)begin
       if(req_item.smi_msg_type == CMD_CMP_ATM) begin
         req_item.smi_intfsize   = this.allowedIntfSizeActual[aiu_unq_id.req_aiu_id];
       end
       else begin
         req_item.smi_intfsize   = this.allowedIntfSize[aiu_unq_id.req_aiu_id];
       end
     end
     else begin
       req_item.smi_intfsize   = k_intfsize;
     end
   `else
      req_item.smi_intfsize   = $clog2(WSMIDPBE/8);
   `endif
      this.MINALIGN             = (2**req_item.smi_intfsize)*8; // Addresses are 4 byte aligned
      this.INCRALIGN            = $clog2(MINALIGN);
      `uvm_info("dmi_base_seq", $sformatf("MINALIGN :%0d INCRALIGN :%0d k_intfsize :%0d smi_intfsize:%0d",this.MINALIGN,this.INCRALIGN, k_intfsize, req_item.smi_intfsize),UVM_DEBUG)
   endfunction: set_intfsize

   ///////////////////////////////////////////////////
   // Task generate unique aiu txn_id pair
   ///////////////////////////////////////////////////
   task getunqAiuSmiId( output aiu_id_queue_t aiu_unq_id, input Coh,bit DtrReq = 0,smi_seq_item req_item);
      int atm_cmp_aiu_id;
      int count=0;
      aiu_id_queue_t available_ids[$];
      int find_q[$];
      if(Coh)begin
      //#Check.DMI.Concerto.v3.0.DtrMsgInFlight
        //DtrReq = 1, check if there are available entries with (item.req_aiu_id != req_item.smi_src_ncore_unit_id)
        for(aiu_id_queue_t i=0; i<MAX_TRANS_ID_Q; i++) begin
            if(!(aiu_table.exists(i) || aiu_table_nc.exists(i)))begin
                available_ids.push_back(i);
            end
        end
        find_q = available_ids.find_index with (item.req_aiu_id != req_item.smi_src_ncore_unit_id);
        ////////////////////////////////////////////////////////////////////////////////////////////////////////////
        do // find unused
          begin
             `uvm_info("dmi_base_seq", $sformatf("Aiu table size=%0d(Max=%0d)",$size(aiu_table),MAX_TRANS_ID_Q),UVM_DEBUG)
             `uvm_info("dmi_base_seq", $sformatf("DtrReq(%0b) Number of available AIU Ids=%0d", DtrReq, $size(find_q)),UVM_DEBUG)
             if((($size(aiu_table)+$size(aiu_table_nc)) >= MAX_TRANS_ID_Q)||(DtrReq && !(find_q.size()))) begin // all entries full. Wait
                `uvm_info("dmi_base_seq", "Waiting for aiu entries to free up",UVM_DEBUG)
                 @e_aiusmi_id_clean;
             end
             `uvm_info("dmi_base_seq", $sformatf("Trying to choose aiu table entry.."),UVM_DEBUG)
             do
             begin
               aiu_unq_id = $urandom;
             
             end while((aiu_unq_id.req_aiu_id >= nAius) ||(DtrReq && (req_item.smi_src_ncore_unit_id == aiu_unq_id.req_aiu_id)));
              
        end 
        while (aiu_table.exists(aiu_unq_id) || aiu_table_nc.exists(aiu_unq_id));
        aiu_table[aiu_unq_id] = 1;
      end
      else begin
        //directed atomic cmp testcase 
        if(k_atomic_directed && req_item.smi_msg_type == CMD_CMP_ATM) begin
            if(intfsize_counter>2) intfsize_counter = 0;
            foreach(allowedIntfSize[i]) begin
                if(allowedIntfSize[i] == intfsize_counter) begin
                    atm_cmp_aiu_id = i;
                    break;
                end
            end
        end
        do // find unused
          begin
             `uvm_info("dmi_base_seq", $sformatf("Aiu table size=%0d",$size(aiu_table_nc)),UVM_DEBUG)
             if(($size(aiu_table_nc) >=  MAX_NCMSGID_IN_FLIGHT)||($size(aiu_table)+$size(aiu_table_nc)>= MAX_TRANS_ID_Q)) begin // all entries full. Wait
                `uvm_info("dmi_base_seq", $sformatf("AIU Table Size=%0d (Max=%0d)", $size(aiu_table), MAX_TRANS_ID_Q),UVM_DEBUG)
                `uvm_info("dmi_base_seq", "Waiting for aiu entries to free up",UVM_DEBUG)
                 @e_aiusmi_id_clean_nc;
             end
             `uvm_info("dmi_base_seq", $sformatf("Trying to choose aiu table entry.."),UVM_DEBUG)
             do
             begin
              aiu_unq_id = $urandom;
             
             end 
             while(aiu_unq_id.req_aiu_id >= nAius);
              
        end 
        //while (aiu_table_nc.exists(aiu_unq_id) || aiu_table.exists(aiu_unq_id) || ((k_atomic_directed)?(aiu_unq_id.req_aiu_id != atm_cmp_aiu_id):0));
        while (aiu_table_nc.exists(aiu_unq_id) || aiu_table.exists(aiu_unq_id));
        aiu_table_nc[aiu_unq_id] = 1;
      end
       `uvm_info("dmi_base_seq", $sformatf("getunqAiuSmiId: get coh %0b addr:%0x msg_type :%0x aiu_id :%0d aiu_msg_id :%0x",Coh,req_item.smi_addr,req_item.smi_msg_type,aiu_unq_id.req_aiu_id,aiu_unq_id.req_aiu_msg_id),UVM_DEBUG)
   endtask // getunqAiuSmiId

   ///////////////////////////////////////////////////
   // Task generate unique smi_id for aiu
   ///////////////////////////////////////////////////
   task getAiuSmiId( output aiu_id_queue_t aiu_unq_id, input smi_ncore_unit_id_bit_t  aiu_id );
        do // find unused
          begin
             `uvm_info("dmi_base_seq", $sformatf("Aiu table size=%0d",$size(aiu_table)),UVM_DEBUG)
             if($size(aiu_table) == MAX_TRANS_ID_Q) begin // all entries full. Wait
                `uvm_info("dmi_base_seq", "Waiting for aiu entries to free up",UVM_DEBUG)
                 @e_aiusmi_id_clean;
             end
             `uvm_info("dmi_base_seq", $sformatf("Trying to choose aiu table entry.."),UVM_DEBUG)
             aiu_unq_id = $urandom;
             aiu_unq_id.req_aiu_id =aiu_id;
             
        end while (aiu_table.exists(aiu_unq_id));
        aiu_table[aiu_unq_id] = 1;
   endtask // getAiuSmiId
   
   task getAiuNcSmiId( output aiu_id_queue_t aiu_unq_id, input smi_ncore_unit_id_bit_t  aiu_id );
        do // find unused
          begin
             `uvm_info("dmi_base_seq getAiuNcSmiId", $sformatf("Aiu table size=%0d",$size(aiu_table_nc)),UVM_DEBUG)
             if(($size(aiu_table_nc) >=  MAX_NCMSGID_IN_FLIGHT)||($size(aiu_table)+$size(aiu_table_nc)>= MAX_TRANS_ID_Q)) begin // all entries full. Wait
                `uvm_info("dmi_seq getAiuNcSmiId", "Waiting for aiu entries to free up",UVM_DEBUG)
                 @e_aiusmi_id_clean_nc;
             end
             `uvm_info("dmi_seq getAiuNcSmiId", $sformatf("Trying to choose aiu table entry.."),UVM_DEBUG)
             do
             begin
              aiu_unq_id = $urandom;
              aiu_unq_id.req_aiu_id =aiu_id;
             end 
             while(aiu_unq_id.req_aiu_id >= nAius);
              
        end while (aiu_table_nc.exists(aiu_unq_id) || aiu_table.exists(aiu_unq_id));
        aiu_table_nc[aiu_unq_id] = 1;
   endtask // getAiuNcSmiId
   task setWrAdditionalInfo(smi_seq_item req_item,bit primary);

        aiu_id_queue_t aiu_unq_id;
        
        if(req_item.smi_mw)begin
          getunqAiuSmiId(aiu_unq_id,1,1,req_item);
        end
        else begin
          getunqAiuSmiId(aiu_unq_id,1,0,req_item);
        end
    
        req_item.smi_src_ncore_unit_id    = aiu_unq_id.req_aiu_id;
        if ($test$plusargs("wrong_targ_id_dtw")) begin
          req_item.smi_targ_ncore_unit_id   = (home_dmi_unit_id ^ {WSMINCOREUNITID{1'b1}}); 
        end else begin
          req_item.smi_targ_ncore_unit_id   = home_dmi_unit_id; // this is encoded for one DMI/DII system
        end
         
        req_item.smi_msg_id    =           aiu_unq_id.req_aiu_msg_id;
        if(2**req_item.smi_size < nSysCacheline)begin
          if(isDtwMrgMrd(req_item.smi_msg_type)) req_item.smi_prim = primary;
          else req_item.smi_prim = 1;
        end
        else begin
          req_item.smi_prim  = primary;
        end

        set_intfsize(req_item,aiu_unq_id);

        if(isDtwMrgMrd(req_item.smi_msg_type))begin
           getunqAiuSmiId(aiu_unq_id,1,1,req_item);
           req_item.smi_mpf1  = {aiu_unq_id.req_aiu_id};
           req_item.smi_mpf2  =  aiu_unq_id.req_aiu_msg_id;
           if($test$plusargs("conc9307_test")) req_item.smi_rl = 'b11;
           else begin
             if(req_item.smi_prim) req_item.smi_rl    = ($urandom_range(1,100) <= 50) ? 'b01: 'b11; 
             else req_item.smi_rl = 'b01;
           end
        end
        else begin
          req_item.smi_rl               = 'b10;
        end
        if($test$plusargs("wt_dmi_qos_hp_pkt")) begin
           randcase
               wt_dmi_qos_hp_pkt.get_value()         : req_item.smi_qos = $urandom_range (dmi_qos_th_val, 15);
               (100 - wt_dmi_qos_hp_pkt.get_value()) : req_item.smi_qos = $urandom_range (0, (dmi_qos_th_val-1));
           endcase
         end
         else 
            req_item.smi_qos =  $urandom;

        req_item.smi_lk  = $urandom;
        req_item.smi_ndp_aux  = $urandom;
        req_item.smi_msg_pri = ncoreConfigInfo::qos_mapping(req_item.smi_qos);
       `uvm_info("dmi_base_seq",$sformatf("setWrAdditionalInfo:req_item :%p",req_item),UVM_DEBUG);
        <%  if(obj.DutInfo.wAwUser >0) { %> 
        //req_item.smi_dp_user = $urandom;
        <% } %>
   endtask // setWrAdditionalInfo

   task setCmdAttribute(smi_seq_item req_item);
        int req_bytes;
        axi_axid               = $urandom;
        if(req_item.isCmdAtmLoadMsg() || req_item.isCmdAtmStoreMsg()) begin
          req_item.smi_vz      = 0;
          req_item.smi_st      = 0; 
        end
        else begin
          req_item.smi_vz      = $urandom;
          req_item.smi_st      = $urandom; 
        end

        if($test$plusargs("k_force_coh_vz")) begin
          req_item.smi_vz      = 0;
        end
        if($test$plusargs("k_force_sys_vz")) begin
          req_item.smi_vz      = 1;
        end

          req_item.smi_ca      = $urandom;

        if(k_force_allocate == 1 || req_item.smi_msg_type == CMD_PREF) begin
          req_item.smi_ac      = 1;
          req_item.smi_ca      = 1;
        end
        else begin
          req_item.smi_ac      = $urandom;
          req_item.smi_ac      = req_item.smi_ac & req_item.smi_ca;
        end
        req_item.smi_ch        = 0;
        req_item.smi_en        = 0;
        //#Stimulus.DMI.CMDreq.Excel.CmType
        if(req_item.smi_msg_type inside {CMD_WR_NC_PTL,CMD_WR_NC_FULL,CMD_RD_NC})begin
          if(exclusive_flg)begin
              //Exclusive access performed on addresses located in SMC are invalid, avoid allocation
               if ($test$plusargs("wt_cmd_exclusive")) begin
   
                  randcase
                  (100 - wt_cmd_exclusive.get_value()) :   req_item.smi_es = 0 ;  
                  wt_cmd_exclusive.get_value()         :   req_item.smi_es = 1 ;
                  endcase
              end
              else  req_item.smi_es   = $urandom;
              req_item.smi_ac  = exmon_size > 0 ? $urandom_range(0,1) : 0;
              req_item.smi_ca  = req_item.smi_ac;
              req_item.smi_vz  = 1;
          end
          else if(mix_exclusives_flg) begin
              if($test$plusargs("wt_cmd_exclusive")) begin
                  randcase
                  (100 - wt_cmd_exclusive.get_value()) :   req_item.smi_es = 0 ;  
                  wt_cmd_exclusive.get_value()         :   req_item.smi_es = 1 ;
                  endcase
              end
              else  req_item.smi_es   = ($urandom_range(0,100) < 30) ? 1 : 0;
              if(req_item.smi_es) begin
                req_item.smi_ac  = exmon_size > 0 ? $urandom_range(0,1) : 0;
                req_item.smi_ca  = req_item.smi_ac;
                req_item.smi_vz  = 1;
              end
          end
        end
        else if(mix_exclusives_flg && isAtomics(req_item.smi_msg_type))begin
          randcase
          (100 - wt_cmd_exclusive.get_value()) :   req_item.smi_es = 0 ;  
          wt_cmd_exclusive.get_value()         :   req_item.smi_es = 1 ;
          endcase
        end
        else begin
          req_item.smi_es      = 0;
        end
        req_item.smi_pr        = $urandom;
        req_item.smi_order     = $urandom;
        req_item.smi_lk        = $urandom;
        /*if(req_item.smi_msg_type inside {CMD_CLN_INV,CMD_CLN_VLD,CMD_CLN_SH_PER,CMD_MK_INV,CMD_RD_NC})begin
            req_item.smi_rl      = 'b01;
        end else begin
            req_item.smi_rl       = $urandom();
        end*/
        
        if(req_item.smi_msg_type inside {CMD_CLN_INV,CMD_CLN_VLD,CMD_CLN_SH_PER,CMD_MK_INV})begin
            req_item.smi_rl     = 'b10;
        end else if(req_item.smi_msg_type inside {CMD_RD_NC,CMD_WR_NC_PTL,CMD_WR_NC_FULL})begin
            req_item.smi_rl     = 'b01;
        end else begin
            req_item.smi_rl     = 'b00;
        end

        // This assignment was altered to allow the user to set his/her own weight percentage.
        req_item.smi_tm        = check_And_Set_TmBit(req_item); 

        if(k_atomic_opcode == 8)begin
          req_item.smi_mpf1_argv = $urandom_range(0,7);
        end
        else 
        begin
          req_item.smi_mpf1_argv = k_atomic_opcode;
        end
        if($test$plusargs("wt_dmi_qos_hp_pkt")) begin
           randcase
               wt_dmi_qos_hp_pkt.get_value()         : req_item.smi_qos = $urandom_range (dmi_qos_th_val, 15);
               (100 - wt_dmi_qos_hp_pkt.get_value()) : req_item.smi_qos = $urandom_range (0, (dmi_qos_th_val-1));
           endcase
         end
         else 
            req_item.smi_qos =  $urandom;

        req_item.smi_msg_pri = ncoreConfigInfo::qos_mapping(req_item.smi_qos);
        // Code added for PerfMon DMI BandWidth support
        if ($test$plusargs("pmon_bw_user_bits")) begin
           req_item.smi_ndp_aux = $urandom_range(5,15);
           `uvm_info($sformatf("%m"), $sformatf("dmi seq debug Pmon bw user bits testcase is enabled"), UVM_LOW)
        end
        else
           req_item.smi_ndp_aux  = $urandom;
        //#Stimulus.DMI.CMDreq.Excel.Addr
        if(req_item.smi_es)begin
          if(req_item.smi_size>0)begin
            req_bytes = 2**req_item.smi_size;
            req_item.smi_addr = (req_item.smi_addr/req_bytes)*req_bytes;
          end
          //req_item.smi_ac  = 0;
          //req_item.smi_ca  = 0;
          //req_item.smi_vz  = 1;
        end
      req_item.smi_mpf2  = axi_axid;
      if(req_item.smi_es)begin
            req_item.smi_mpf2_flowid        = axi_axid;
            req_item.smi_mpf2_flowid_valid  = $urandom;
      end
        
        if(req_item.smi_msg_type inside {CMD_RD_ATM,CMD_SW_ATM,CMD_CMP_ATM,CMD_WR_ATM}) begin
            req_item.smi_ac = 1;
        end
        
        req_item.smi_dest_id    = $urandom;             //dest_id is a dont care for non-coherent cmdreq
        req_item.smi_tof        = $urandom;     
      
      if (req_item.smi_es && exmon_size > 0) begin
           int idx = -1;
           int exclusive_sequence;
           dmi_exclusive_c exclusive_cmd;
           dmi_exclusive_c load_exclusive_cmd;
           int exclusive_sequence_weight;
           aiu_id_queue_t aiu_unq_id;
           int find_q[$];
           exclusive_cmd            = new();
           exclusive_cmd.addr       = req_item.smi_addr;
           exclusive_cmd.src_id     = req_item.smi_src_ncore_unit_id;
           exclusive_cmd.flowid     = req_item.smi_mpf2_flowid;
           exclusive_cmd.msg_type    = req_item.smi_msg_type;
           exclusive_cmd.ns          = req_item.smi_ns;
           if (exclusive_cmd.msg_type == CMD_RD_NC) begin
                        load_exclusive_q.push_back(exclusive_cmd);
           end
            if ($test$plusargs("wt_exclusive_sequence")) begin
               exclusive_sequence_weight = wt_exclusive_sequence.get_value();
            end 
            else begin
               exclusive_sequence_weight = 0;
            end
           exclusive_sequence = $urandom_range(0,100);
          if (req_item.smi_msg_type != CMD_RD_NC) begin
            find_q = load_exclusive_q.find_index with (
            (item.addr == req_item.smi_addr ));
          end
           if ((req_item.smi_msg_type != CMD_RD_NC) && (find_q.size() > 0) && (exclusive_sequence < exclusive_sequence_weight) && load_exclusive_q.size() > 0 ) begin
                `uvm_info($sformatf("%m"), $sformatf("Exmon EXCLUSIVE seq before update smi_addr=%h smi_src_ncore_unit_id=%h smi_mpf2_flowid=%h", req_item.smi_addr ,
                req_item.smi_src_ncore_unit_id,req_item.smi_mpf2_flowid), UVM_DEBUG)
                //find_q.shuffle();
                load_exclusive_cmd = load_exclusive_q[find_q[find_q.size()-1]];
                load_exclusive_q.delete(find_q[find_q.size()-1]);
                 //load_exclusive_cmd = load_exclusive_q[find_q[0]];
                 //load_exclusive_q.delete(find_q[0]);
                //req_item.smi_addr                = load_exclusive_cmd.addr;
                if(req_item.smi_src_ncore_unit_id != load_exclusive_cmd.src_id)begin
                  aiu_id_queue_t aiu_entry; 
                  req_item.smi_src_ncore_unit_id  = load_exclusive_cmd.src_id;
                  aiu_entry.req_aiu_id = load_exclusive_cmd.src_id;
                  //Realign and rotate data packets based on the correct AIU
                  set_intfsize(req_item,aiu_entry);
                  genDtwPkt(req_item);
                end
                req_item.smi_src_ncore_unit_id   = load_exclusive_cmd.src_id;
                req_item.smi_mpf2_flowid         = load_exclusive_cmd.flowid;
                req_item.smi_ns                  = load_exclusive_cmd.ns  ;    
                //getAiuSmiId(req_item);  
                getAiuNcSmiId(aiu_unq_id,req_item.smi_src_ncore_unit_id);
                req_item.smi_msg_id    =   aiu_unq_id.req_aiu_msg_id;

                `uvm_info($sformatf("%m"), $sformatf("Exmon EXCLUSIVE seq after update smi_addr=%h smi_src_ncore_unit_id=%h smi_mpf2_flowid=%h", req_item.smi_addr ,
                req_item.smi_src_ncore_unit_id,req_item.smi_mpf2_flowid), UVM_DEBUG)
           end
        end // if (req_item.smi_es && exmon_size > 0)       
        
   endtask//setCmdAttribute

   task genDtwPkt(smi_seq_item req_item);

      chooseClAddr(req_item);
      chooseLength(req_item);
`ifndef DATA_DROP
      setData(req_item);
`endif
      chooseBE(req_item);

   endtask // genDtwPkt

   task genDtwPktMW(smi_seq_item req_item,smi_rbid_t smi_rbid);

      req_item.smi_msg_type = DTW_DATA_DTY;
      req_item.smi_rbid     = smi_rbid;
      req_item.smi_mw       = 1;
      chooseLength(req_item);
      setWrAdditionalInfo(req_item,0);
`ifndef DATA_DROP
      setData(req_item);
`endif
      chooseBE(req_item);
      setSmiPriv(req_item); 
   endtask // genDtwPktPrim



   task buildrbpkt(smi_seq_item req_rbid_item,req_item,smi_rtype_t rtype,bit mw = 0,smi_qos_t smi_qos_rb);
      bit prev_gid = req_rbid_item.smi_rbid[WSMIRBID-1];
      req_rbid_item.smi_msg_type  = RB_REQ;
      req_rbid_item.smi_src_ncore_unit_id   = home_dce_unit_id; 
      if ($test$plusargs("wrong_targ_id_rb_req")) begin
        req_rbid_item.smi_targ_ncore_unit_id   = (home_dmi_unit_id ^ {WSMINCOREUNITID{1'b1}}); 
      end else begin
        req_rbid_item.smi_targ_ncore_unit_id   = home_dmi_unit_id; 
      end
      req_rbid_item.smi_rbid                 = req_item.smi_rbid; 
      req_rbid_item.smi_size                 = req_item.smi_size; 
      req_rbid_item.smi_intfsize             = req_item.smi_intfsize; 
      req_rbid_item.smi_addr                 = req_item.smi_addr;
      req_item.smi_ca                        = $urandom;
      if(k_force_allocate == 1) begin
        req_rbid_item.smi_ac                 = 1;
        req_rbid_item.smi_ca                 = 1;
      end
      else begin
        req_rbid_item.smi_ac                 = $urandom;
        req_rbid_item.smi_ac                 = req_rbid_item.smi_ac & req_rbid_item.smi_ca;
      end
      req_rbid_item.smi_vz                   = req_item.smi_vz; 

      if($test$plusargs("k_force_sys_vz")) begin
        req_rbid_item.smi_vz      = 1;
      end
      if($test$plusargs("k_force_coh_vz")) begin
        req_rbid_item.smi_vz      = 0;
      end

      req_rbid_item.smi_ns                   = req_item.smi_ns; 
      req_rbid_item.smi_pr                   = req_item.smi_pr;
      req_rbid_item.smi_rl             = 2;
      if(k_force_mw == 1 || mw == 1)begin
        req_rbid_item.smi_mw                   = 1;  
      end
      else if(k_force_mw == 0 ||  mw == 0)begin
        req_rbid_item.smi_mw                   = 0;  
      end
      //req_rbid_item.smi_qos = $urandom;
      req_rbid_item.smi_ndp_aux = $urandom;
      req_rbid_item.smi_mpf1 = $urandom;
      req_rbid_item.smi_tof = $urandom;

      req_rbid_item.smi_tm = req_item.smi_tm;
      req_item.smi_lk  = $urandom;
      if($test$plusargs("wt_dmi_qos_hp_pkt")) begin
        randcase
            wt_dmi_qos_hp_pkt.get_value()         : req_item.smi_qos = $urandom_range (dmi_qos_th_val, 15);
            (100 - wt_dmi_qos_hp_pkt.get_value()) : req_item.smi_qos = $urandom_range (0, (dmi_qos_th_val-1));
        endcase
      end
      else 
         req_item.smi_qos =  $urandom;

      req_item.smi_ndp_aux  = $urandom;
      req_item.smi_msg_pri = ncoreConfigInfo::qos_mapping(req_item.smi_qos);
      if(!rtype) req_rbid_item.smi_qos = smi_qos_rb;
      else req_rbid_item.smi_qos = req_item.smi_qos;
      req_rbid_item.smi_msg_pri = ncoreConfigInfo::qos_mapping(req_rbid_item.smi_qos);
      setSmiPriv(req_rbid_item);
      getSmimsgId(req_rbid_item,1);
   endtask // genRbPkt


//////////////////////////////////////////////////////////////////////////////////
// Helper functions
//////////////////////////////////////////////////////////////////////////////////
   task waitForSmimsgId();
      while (mrd_in_flight_cnt >= MAX_MRD_IN_FLIGHT) begin
         `uvm_info("dmi_base_seq", "Waiting for in-flight transactions to end", UVM_DEBUG)
          @e_mrd_smi_id_clean;
      end
   endtask // waitForSmimsgId

//////////////////////////////////////////////////////////////////////////////////
// Helper functions
//////////////////////////////////////////////////////////////////////////////////
   task waitForNcSmimsgId();
      while (Nctxns_in_flight >= MAX_NCMSGID_IN_FLIGHT) begin
         `uvm_info("dmi_base_seq", "Waiting for Nc in-flight transactions to end", UVM_DEBUG)
          @e_aiusmi_id_clean_nc;
      end
   endtask // waitForNcSmimsgId
///////////////////////////////////////////////////////////////////////////////
// Find Unused SMI Msg ID
///////////////////////////////////////////////////////////////////////////////
   task  getSmimsgId(smi_seq_item req_item,bit rbid=0);
     int dceNunitId;
     int tmp_q[$];
     SMImsgIDTableEntry_t   tmp_smi_table; 
     smi_ncore_unit_id_bit_t src_id;   
           `uvm_info("dmi_base_seq", $sformatf("Trying to choose smi table entry.."),UVM_DEBUG)
     src_id = 0;
     //print_smi_table();
     //#Check.DMI.Concerto.v3.0.MrdReqSmiMsgIdInFlight
      do // find unused
        begin
           if(rbid)begin  
             src_id = req_item.smi_src_ncore_unit_id;
           end
           else begin
             dceNunitId = $urandom_range(<%=nDce-1%>, 0);
             src_id = dcefunitId[dceNunitId];
           end
           assert(std::randomize(smi_msg_id));
           tmp_q = smi_table.find_index with (item.src_id == src_id && item.smi_msg_id == smi_msg_id);
           if(tmp_q.size()>0) begin
             //`uvm_info("delay_debug","getSmimsgId blocked",UVM_LOW);
             if($test$plusargs("slow_seq_delays"))begin
               #10ns;
             end
             else begin
               #1ns;
             end
           end
      end while (tmp_q.size()>0);
      tmp_smi_table.src_id              = src_id;
      tmp_smi_table.smi_msg_id          = smi_msg_id;
      req_item.smi_msg_id               = smi_msg_id;
      req_item.smi_src_ncore_unit_id    = src_id;
      if(rbid) begin
        tmp_smi_table.smi_rbid   = req_item.smi_rbid;
        tmp_smi_table.valRb = 1;
      end
        
      `uvm_info("dmi_base_seq", $sformatf("got src_id :%0d smi_msg_id :%0x | rbid %0b val:%0x", src_id, tmp_smi_table.smi_msg_id, rbid, tmp_smi_table.smi_rbid),UVM_DEBUG)
      smi_table.push_back(tmp_smi_table);
     //print_smi_table();
   endtask // getSmimsgId
/////////////////////////////////////////////////////////////////////////////////////////////
// release unused chrbid
///////////////////////////////////////////////////////////////////////////////////////////
   function bit  release_cohrbid(smi_rbid_t smi_rbid);
      int index;
      int tmp_q[$];
      bit status; 
      int size_count = 0;
      if(used_cohrbid_q.exists(smi_rbid))begin
        `uvm_info("dmi_base_seq", $sformatf("Releasing used Rbid:%0h",smi_rbid),UVM_DEBUG);
         used_cohrbid_q.delete(smi_rbid);
         if(smi_rbid[WSMIRBID-1]) gid1_rb_status[smi_rbid[WSMIRBID-2:0]] = 0;
         else gid0_rb_status[smi_rbid[WSMIRBID-2:0]] = 0;
      end
      else if (!uncorr_wrbuffer_err) begin
        `uvm_error("dmi_base_seq",$sformatf("Used Rbid:%0h doesn't exist in used_cohrbid_q",smi_rbid));
      end
   endfunction // release_cohrbid
/////////////////////////////////////////////////////////////////////////////////////////////
// find used chrbid
///////////////////////////////////////////////////////////////////////////////////////////
   function bit  getcohrbid(smi_seq_item req_item);
      int index, gid_flip_index, release_idx;
      int NunitId;
      int tmp_q[$];
      bit status = 0; 
      /* 
      1. Check if all rbids are in use
      2. Check if RBIDs are overflowing
      3. For Regular RBID dispatch only if GID flipped RBID is not previously used
      4. For Release cases
        4.1 If an RBID in the release queue and flipped GID RBID is also being used, pick another.
        4.2 Force a release if the RBID release queue size == remaining txns to be dispatched(clear_pending_rbs)
      */
      gid_rb_status = gid0_rb_status & gid1_rb_status;
      if( ((&(gid0_rb_status | gid1_rb_status)) && rbid_release_q.size()==0 ) || (&gid_rb_status)) begin
        `uvm_info("getcohrbid",$sformatf("all coherent rbids are in use gid0_status:%0b gid1_status:%0b gid_status:%0b clear_pending_rbs=%0b", gid0_rb_status, gid1_rb_status, gid_rb_status, clear_pending_rbs),UVM_MEDIUM);
      end
      else if(((used_cohrbid_q.num >= <%=ch_rbid%>) && (rbid_release_q.size() != 0)) || clear_pending_rbs) begin
         release_idx = $urandom_range(rbid_release_q.size()-1,0);
         index = rbid_release_q[release_idx].rbid;
         gid_flip_index = {~index[WSMIRBID-1], index[WSMIRBID-2:0]};
         if(!used_cohrbid_q.exists(gid_flip_index)) begin
           tm_release_q.push_back('{gid_flip_index,rbid_release_q[release_idx].tm});
           `uvm_info("getcohrbid",$sformatf("Releasing RBID:%0h to prevent bottleneck (clear_pending_rbs:%0b)", index, clear_pending_rbs),UVM_DEBUG);
           NunitId = index[WSMIRBID-2:0]/<%=obj.DceInfo[0].nRbsPerDmi%>; 
           index = gid_flip_index;
           req_item.smi_rbid = index;
           req_item.smi_tm = rbid_release_q[release_idx].tm;
           rbid_release_q.delete(release_idx);
           status = 1;
           this.home_dce_unit_id   =  dcefunitId[NunitId]; 
         end
      end
      else begin 
        //Either find an unused one randomly or find a used one and flip it for a release, distribute this search 50/50
        if(($urandom_range(1,100) > 5) && rbid_release_q.size()!=0) begin //Release an existing RBID
          release_idx = $urandom_range(rbid_release_q.size()-1,0);
          index = rbid_release_q[release_idx].rbid;
          gid_flip_index = {~index[WSMIRBID-1], index[WSMIRBID-2:0]};
          if(!used_cohrbid_q.exists(gid_flip_index)) begin
          tm_release_q.push_back('{gid_flip_index,rbid_release_q[release_idx].tm});
          NunitId = index[WSMIRBID-2:0]/<%=obj.DceInfo[0].nRbsPerDmi%>;
          index = gid_flip_index;
          req_item.smi_rbid = index;
          req_item.smi_tm   = rbid_release_q[release_idx].tm;
          rbid_release_q.delete(release_idx);
          status = 1;
          end
        end
        else begin
          int attempt =0;
          do // find unused
          begin
             index = $urandom_range(<%=ch_rbid%>-1, 0);
             gid_flip_index = {~index[WSMIRBID-1], index[WSMIRBID-2:0]};
             NunitId = index/<%=obj.DceInfo[0].nRbsPerDmi%>; 
             req_item.smi_rbid = index;
             attempt++;
          end while ((used_cohrbid_q.exists(index) || used_cohrbid_q.exists(gid_flip_index)) && attempt <= used_cohrbid_q.num);
          if(used_cohrbid_q.exists(index) || used_cohrbid_q.exists(gid_flip_index)) begin
            `uvm_info("getcohrbid",$sformatf("Failed alloting RBID after %0d attemtps", attempt),UVM_MEDIUM)
            status = 0;
          end
          else begin
            status = 1;
          end
        end
        this.home_dce_unit_id   =  dcefunitId[NunitId]; 
      end
      if(status) begin
        used_cohrbid_q[index] = 1;
        if(index[WSMIRBID-1]) gid1_rb_status[index[WSMIRBID-2:0]] = 1;
        else gid0_rb_status[index[WSMIRBID-2:0]] = 1;
        `uvm_info("dmi_base_seq",$sformatf("RBID:%0h selected status:%0b",index,status),UVM_DEBUG);
      end
      return status;
   endfunction // getcohrbid

   function setSmiPriv(smi_seq_item req_item);
      int set_prev_tm[$];
      req_item.smi_msg_tier = $urandom;
      req_item.smi_steer    = $urandom;

      // ----------------------------------------------------------------
      // This code was added to verify CONC-9157. Needed to make sure 
      // that RTL behaves correct when a DTW_REQ got sent out with the 
      // CMSTATUS set to 8'b1000_0011.. in such case, the RTL is expected
      // to set the poison bit for that transaction.
      if (($test$plusargs("dtwreq_cmstatus")) &&
          (req_item.smi_msg_type>=8'h90 && req_item.smi_msg_type<=8'h93)) begin
           req_item.smi_cmstatus = 8'b1000_0011;
      end
      else req_item.smi_cmstatus = 0;
        
      if(!(req_item.isRbMsg() || req_item.isMrdMsg() || isDtw(req_item.smi_msg_type) || isDtwMrgMrd(req_item.smi_msg_type) || (req_item.smi_msg_type inside {CMD_CLN_INV,CMD_CLN_VLD,CMD_CLN_SH_PER,CMD_MK_INV,CMD_RD_NC,CMD_WR_NC_PTL,CMD_WR_NC_FULL})))begin
        req_item.smi_rl       = 0;
      end
      set_prev_tm = tm_release_q.find_index with(item.rbid === req_item.smi_rbid);
      if( set_prev_tm.size() == 1) begin
        req_item.smi_tm = tm_release_q[set_prev_tm[0]].tm;
        tm_release_q.delete(set_prev_tm[0]);
      end
      else if(!(req_item.isRbMsg())) begin
        // This assignment was altered to allow the user to set his/her own weight percentage.
        req_item.smi_tm        = check_And_Set_TmBit(req_item); 
      end
      setAceFields(req_item);
   endfunction // setSmiPriv


///////////////////////////////////////////////////////////////////////////////
// Set ACE fields in SFI Priv
///////////////////////////////////////////////////////////////////////////////
   function setAceFields(smi_seq_item req_item);
      <% if(obj.useSysAceCache) { %>
       //  req_item.req_smiPriv[
       //     SFI_PRIV_REQ_ACE_CACHE_MSB:SFI_PRIV_REQ_ACE_CACHE_LSB] = $urandom;
      <% } %>
      <% if(obj.useSysAceProt) { %>
       //  req_item.smi_protection  = $urandom_range(7, 0);
      <% } %>
      <% if(obj.useSysAceQos) { %>
      //   req_item.smi_qos = $urandom;
      <% } %>
      <% if(obj.useSysAceRegion) { %>
       //  req_item. = $urandom;
      <% } %>
      <% if(obj.useSysAceDomain) { %>
       //  req_item. = $urandom;
      <% } %>
      <% if(obj.useSysAceUser) { %>
      //  req_item.smi_user = $urandom;
      <% } %>
      // ACEUNIQUE is only applicable for DTW messages in DMI. This configurable value has been moved from here to a conditional one for DTW only
      <% if(obj.useSysAceCache) { %>
      if (cmd_msg_type == DTW_DATA_CLN) begin
      //  req_item = $urandom;
      end
      <% } %>
   endfunction // setAceFields

///////////////////////////////////////////////////////////////////////////////
// Additional MRD / HNT info
///////////////////////////////////////////////////////////////////////////////
   task readsAdditionalInfo(smi_seq_item req_item);
      aiu_id_queue_t aiu_unq_id;
      bit done = 0;


      if(req_item.isMrdMsg())begin
         getunqAiuSmiId(aiu_unq_id,1,0,req_item);
       req_item.smi_mpf1_dtr_tgt_id  = {aiu_unq_id.req_aiu_id};
       req_item.smi_mpf2_dtr_msg_id  =  aiu_unq_id.req_aiu_msg_id;
    end

    else begin
         req_item.smi_msg_id            = aiu_unq_id.req_aiu_msg_id;
         req_item.smi_src_ncore_unit_id = aiu_unq_id.req_aiu_id;
      end
      req_item.smi_ca        =  $urandom;
      if(k_force_allocate == 1 || (req_item.smi_msg_type == MRD_PREF)) begin
        req_item.smi_ac      = 1;
        req_item.smi_ca      = 1;
      end
      else begin
        req_item.smi_ac      = $urandom;
        req_item.smi_ac      = req_item.smi_ac & req_item.smi_ca;
      end
      //`uvm_info("dmi_base_seq", $sformatf("index=%0d",index),UVM_DEBUG)
      //`uvm_info("dmi_base_seq", $sformatf("%p",aiu_table[index]),UVM_DEBUG)
  <%  if(obj.DutInfo.wArUser >0) { %> 
  //    req_item.smi_user = $urandom;   TBD
  <% } %>
        req_item.smi_steer = $urandom;
        req_item.smi_pr    = $urandom;
        req_item.smi_ch    = 1;

      if(req_item.smi_msg_type inside {MRD_FLUSH,MRD_CLN,MRD_INV})begin
        req_item.smi_rl      = 'b10;
      end
      else if(req_item.smi_msg_type inside {MRD_RD_CLN,MRD_RD_WITH_SHR_CLN,MRD_RD_WITH_UNQ_CLN})begin
        req_item.smi_rl      = ($urandom_range(1,100) <= 50) ? 'b01: 'b11; // Mrd with smi_rl = 11 updated as per CONC-5883
      end
      else begin
        req_item.smi_rl      = 'b01; 
      end
     
     if($test$plusargs("starvation_test")) begin
       if(aiu_unq_id.req_aiu_id == 0)begin
        req_item.smi_qos =  'hF;
       end
       else begin
        req_item.smi_qos =  0;
       end
     end
     else begin
        if($test$plusargs("wt_dmi_qos_hp_pkt")) begin
        randcase
            wt_dmi_qos_hp_pkt.get_value()         : req_item.smi_qos = $urandom_range (dmi_qos_th_val, 15);
            (100 - wt_dmi_qos_hp_pkt.get_value()) : req_item.smi_qos = $urandom_range (0, (dmi_qos_th_val-1));
        endcase
      end
      else 
         req_item.smi_qos =  $urandom;
     end
     
        req_item.smi_lk  = $urandom;
        req_item.smi_msg_pri = ncoreConfigInfo::qos_mapping(req_item.smi_qos);
        req_item.smi_ndp_aux  = $urandom;
      set_intfsize(req_item,aiu_unq_id);

      `uvm_info("req_item",
                $sformatf("[aiu_id=0x%0x,aiu_msg_id=0x%0x],smi_mpf1_dtr_tgt_id :%0d,smi_msg_id=0x%0x,cmd_msg_type=0x%0x intfsize :%0d smi_rl :%0b",
                          aiu_unq_id.req_aiu_id,
                          req_item.smi_mpf2_dtr_msg_id,
                          req_item.smi_mpf1_dtr_tgt_id,
                          req_item.smi_msg_id, req_item.smi_msg_type,req_item.smi_intfsize,req_item.smi_rl),UVM_DEBUG)
   endtask // readsAdditionalInfo
///////////////////////////////////////////////////////////////////////////////
// Additional Nc Cmd info
///////////////////////////////////////////////////////////////////////////////
   task getNcSmimsgId(smi_seq_item req_item);
      aiu_id_queue_t aiu_unq_id;
      getunqAiuSmiId(aiu_unq_id,0,0,req_item);
      req_item.smi_msg_id            = aiu_unq_id.req_aiu_msg_id;
      req_item.smi_src_ncore_unit_id = aiu_unq_id.req_aiu_id;
      set_intfsize(req_item,aiu_unq_id);

      `uvm_info("req_item",
                $sformatf("[Got NcSmimsgId aiu_id=0x%0x,aiu_msg_id=0x%0x],cmd_msg_type=0x%p",
                          req_item.smi_src_ncore_unit_id,
                          req_item.smi_msg_id, req_item.smi_msg_type),UVM_DEBUG)
   endtask // getNcSmimsgId

///////////////////////////////////////////////////////////////////////////////
// Set source and target Id
///////////////////////////////////////////////////////////////////////////////

    task  setSrctgtId(smi_seq_item req_item);
          //req_item.smi_src_ncore_unit_id    = home_dce_unit_id;
          if ($test$plusargs("wrong_targ_id_mrd")) begin
            req_item.smi_targ_ncore_unit_id   = (home_dmi_unit_id ^ {WSMINCOREUNITID{1'b1}}); 
          end else begin
            req_item.smi_targ_ncore_unit_id   = home_dmi_unit_id; 
          end
    endtask //setSrctgtId
///////////////////////////////////////////////////////////////////////////////
// Info Queue function for debug / display
///////////////////////////////////////////////////////////////////////////////
   function addPktToInfoQueues(smi_seq_item req_item);
         if (req_item.isMrdMsg()) begin
            mrd_packet = new();
            mrd_packet.cmd_msg_type = req_item.smi_msg_type;
            mrd_packet.dce_id       = req_item.smi_src_ncore_unit_id;
            mrd_packet.aiu_id       = req_item.smi_mpf1_dtr_tgt_id;
            mrd_packet.aiu_msg_id   = req_item.smi_mpf2_dtr_msg_id;
            mrd_packet.smi_msg_id   = req_item.smi_msg_id;
            mrd_packet.cache_addr   = req_item.smi_addr;
            mrd_packet.security = req_item.smi_ns;
            mrd_packet.cmd_rsp_recd = 0;
            `uvm_info("dmi_base_seq", $sformatf("Adding mrd packet to mrd_info queue"),UVM_DEBUG)
            `uvm_info("", 
                      $sformatf("mrd_packet:dce_id=:%0x aiu_id=0x%0x aiu_msg_id=0x%0x \
                                smi_msg_id=0x%0x cache_addr=0x%0x",mrd_packet.dce_id,
                                mrd_packet.aiu_id, mrd_packet.aiu_msg_id,
                                mrd_packet.smi_msg_id, mrd_packet.cache_addr), UVM_DEBUG)
            mrd_info.push_back(mrd_packet);
            mrd_in_flight_cnt += 1;
         end
         else if (req_item.isDtwMsg() || isDtwMrgMrd(req_item.smi_msg_type) ) begin
            dtw_packet = new();
            dtw_packet.aiu_id       = req_item.smi_src_ncore_unit_id;
            dtw_packet.smi_msg_id   = req_item.smi_msg_id;
            dtw_packet.cache_addr   = req_item.smi_addr;
            dtw_packet.security     = req_item.smi_ns;
            dtw_packet.smi_rbid     = req_item.smi_rbid;
            dtw_packet.dtr_aiu_id   = req_item.smi_mpf1[WSMINCOREUNITID-1:0];
            dtw_packet.dtr_rmsg_id  = req_item.smi_mpf2;
            dtw_packet.isMrgMrd     = isDtwMrgMrd(req_item.smi_msg_type);
            `uvm_info("dmi_base_seq", $sformatf("Adding dtw packet to dtw_info queue"),UVM_DEBUG)
            dtw_info.push_back(dtw_packet);
         end
         else if (req_item.isCmdNcRdMsg() || req_item.isCmdCacheOpsMsg() || req_item.smi_msg_type == CMD_PREF ) begin
            ncrd_packet = new();
            ncrd_packet.cmd_msg_type = req_item.smi_msg_type;
            ncrd_packet.aiu_id       = req_item.smi_src_ncore_unit_id;
            ncrd_packet.smi_msg_id   = req_item.smi_msg_id;
            ncrd_packet.cache_addr   = req_item.smi_addr;
            ncrd_packet.security     = req_item.smi_ns;
            ncrd_packet.cmd_rsp_recd = 0;
            ncrd_packet.str_recd     = 0;
            ncrd_packet.str_rsp_sent = 0;
            ncrd_packet.dtr_recd     = 0;
            `uvm_info("dmi_base_seq", $sformatf("Adding rd packet to ncrd_info queue"),UVM_DEBUG)
            `uvm_info("dmi_base_seq", 
                      $sformatf("ncrd_packet:aiu_id=0x%0x \
                                smi_msg_id=0x%0x cache_addr=0x%0x security=%0b",
                                ncrd_packet.aiu_id, 
                                ncrd_packet.smi_msg_id, ncrd_packet.cache_addr, ncrd_packet.security), UVM_DEBUG)
            NcRd_info.push_back(ncrd_packet);
         end
         else if (req_item.isCmdAtmLoadMsg) begin
            AtmLd_packet = new();
            AtmLd_packet.cmd_msg_type = req_item.smi_msg_type;
            AtmLd_packet.aiu_id       = req_item.smi_src_ncore_unit_id;
            AtmLd_packet.smi_msg_id   = req_item.smi_msg_id;
            AtmLd_packet.cache_addr   = req_item.smi_addr;
            AtmLd_packet.security     = req_item.smi_ns;
            AtmLd_packet.cmd_rsp_recd = 0;
            AtmLd_packet.str_recd     = 0;
            AtmLd_packet.str_rsp_sent = 0;
            AtmLd_packet.dtr_recd     = 0;
            AtmLd_packet.dtw_sent      = 0;
            AtmLd_packet.dtw_rsp_recd  = 0;
            `uvm_info("dmi_base_seq", $sformatf("Adding AtmLoad to AtmLd_info queue"),UVM_DEBUG)
            `uvm_info("dmi_base_seq", 
                      $sformatf("AtmLd_packet:aiu_id=0x%0x \
                                smi_msg_id=0x%0x cache_addr=0x%0x security=%0b",
                                AtmLd_packet.aiu_id, 
                                AtmLd_packet.smi_msg_id, AtmLd_packet.cache_addr, AtmLd_packet.security), UVM_DEBUG)
            AtmLd_info.push_back(AtmLd_packet);
         end
         else if (req_item.isCmdNcWrMsg() || req_item.isCmdAtmStoreMsg() ) begin
            ncwr_packet = new();
            ncwr_packet.cmd_msg_type  = req_item.smi_msg_type;
            ncwr_packet.aiu_id        = req_item.smi_src_ncore_unit_id;
            ncwr_packet.smi_msg_id    = req_item.smi_msg_id;
            ncwr_packet.cache_addr    = req_item.smi_addr;
            ncwr_packet.security      = req_item.smi_ns;
            ncwr_packet.cmd_rsp_recd  = 0;
            ncwr_packet.str_recd      = 0;
            ncwr_packet.str_rsp_sent  = 0;
            ncwr_packet.dtw_sent      = 0;
            ncwr_packet.dtw_rsp_recd  = 0;
            `uvm_info("dmi_base_seq", $sformatf("Adding dtw packet to ncwr_info queue"),UVM_DEBUG)
            `uvm_info("dmi_base_seq", 
                      $sformatf("ncrd_packet:aiu_id=0x%0x \
                                smi_msg_id=0x%0x cache_addr=0x%0x security=%0b",
                                ncwr_packet.aiu_id, 
                                ncwr_packet.smi_msg_id, ncwr_packet.cache_addr, ncwr_packet.security), UVM_DEBUG)
            NcWr_info.push_back(ncwr_packet);
         end
            aiu_txn_count += 1;
   endfunction

   task wait_for_prev_txn;
    //`uvm_info("delay_debug","Waiting for prev_txn trigger",UVM_LOW);
     if((m_scb.wtt_q.size() + m_scb.rtt_q.size()) != 0) begin
       `uvm_info("dmi_base_seq", "waiting for e_check_txnq_size trigger", UVM_MEDIUM)
       e_check_txnq_size.wait_trigger();
       `uvm_info("dmi_base_seq", "e_check_txnq_size triggered", UVM_MEDIUM)
       wait_for_prev_txn;
     end

   endtask : wait_for_prev_txn

   task send_primary_dtw(smi_rbid_t smi_rbid);
    int tmp_q[$];
    
    tmp_q = m_smi_tx_dtw_req_2nd_q.find_index with (item.smi_rbid == smi_rbid);

    if(tmp_q.size() >1) `uvm_error("send_primary_dtw", "there are 2 entries in the 2nd dtw queue with same RBID")
    else if(tmp_q.size() == 0) `uvm_error("send_primary_dtw", "there are no entries in the 2nd dtw queue")
    else if(tmp_q.size() == 1) begin
        m_smi_tx_dtw_req_q.push_back(m_smi_tx_dtw_req_2nd_q[tmp_q[0]]);
        m_smi_tx_dtw_req_2nd_q.delete(tmp_q[0]);
        ->e_smi_dtw_req_q;
    end
   endtask : send_primary_dtw

endclass : dmi_base_seq

//------------------------------------------------------------------------------
// Constructor
//------------------------------------------------------------------------------
function dmi_base_seq::new(string name = "dmi_base_seq");
   super.new(name);
  
   $value$plusargs("dmiTmBit4Smi0=%d",dmiTmBit4Smi0);
   $value$plusargs("dmiTmBit4Smi2=%d",dmiTmBit4Smi2);
   $value$plusargs("dmiTmBit4Smi3=%d",dmiTmBit4Smi3);

   if($test$plusargs("mrd_bw_test") || $test$plusargs("dtw_bw_test"))begin
     bw_test = 1;
     msg_attr = 3'b11;
   end
   //      if((("<%=obj.DmiInfo[obj.Id].fnErrDetectCorrect%>" == "PARITYENTRY") && ($test$plusargs("wbuffer_single_bit_error_test") || $test$plusargs("wbuffer_multi_blk_single_bit_error_test"))) || $test$plusargs("wbuffer_double_bit_error_test") || $test$plusargs("wbuffer_multi_blk_single_double_bit_error_test") || $test$plusargs("wbuffer_multi_blk_double_bit_error_test")) begin
   //        uncorr_wrbuffer_err = 1;
   //      end
   //      else begin
   //        uncorr_wrbuffer_err = 0;
   //      end
   //#Cov.DMI.v2.MrdRdVldThroughput
   if($test$plusargs("mrd_bw_test"))begin
     mrd_bw_flg = 1;
   end
   if($test$plusargs("dtw_bw_test"))begin
     dtw_bw_flg = 1;
   end
   if($test$plusargs("smi_dtw_err_en"))begin
     smi_dtw_err = 1;
   end
   if($test$plusargs("k_alternate_be"))begin
     force_alternate_be = 1;
   end
   if($test$plusargs("performance_test"))begin
     perf_test_flg = 1;
   end
   // have to fix in 3.1
   if ($test$plusargs("wrong_targ_id_mrd") || $test$plusargs("wrong_targ_id_cmd") || $test$plusargs("wrong_targ_id_dtw") || $test$plusargs("inject_smi_uncorr_error") || $test$plusargs("wrong_targ_id_rb_req") ) begin
     uncorr_error_test = 1;
   end
   if($test$plusargs("k_dir_error_test"))begin
     error_test_flg = 1;
   end
   if($test$plusargs("single_step"))begin
     single_step = 1;
   end
   if($test$plusargs("use_evict_cache_addr")) begin
     use_evict_addr_flg = 1;
   end
   if($test$plusargs("target_sp_addr_edges"))begin
     target_sp_addr_edges_flg = 1;
   end
   //  m_addr_mgr = addr_trans_mgr::get_instance();
   // Constructing sequencer hash for ease of use in main sequence code
   // Reversing TX and RX directions because polarity is opposite for TB than it is for RTL
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
   }%>

   <% for( var i=0;i<nDce;i++){%>
   dcefunitId[<%=i%>] = <%=obj.DceInfo[i].FUnitId%>;
   <%}%>

   if($test$plusargs("nc_ex_test"))begin
     exclusive_flg          = 1;
   end

   if($test$plusargs("mix_exclusives"))begin
     mix_exclusives_flg   = 1;
   end

   if($test$plusargs("k_fixed_set") || (10 <$urandom_range(1,100)))begin
     fixed_set_flg      = 1;
   end

   fset                   = $urandom_range(0,<%=obj.DmiInfo[obj.Id].ccpParams.nSets-1%>);
  
   if($test$plusargs("k_reused_flg") && (wt_addr_reused_q.get_value() <$urandom_range(1,100)))begin
     addr_reused_flg            = 1;
   end
   else begin
     addr_reused_flg            = 0;
   end
   if($test$plusargs("k_random_addr")) begin
     random_addr_flg = 1;
   end
   if($test$plusargs("k_toggle_reused_ns")) begin
     addr_reused_toggle_ns_flg = 1;
   end
   if($test$plusargs("k_cache_warmup"))begin
     cache_warmup_flg =1;
   end
   else begin
     cache_warmup_flg =0;
   end

   if(50 < $urandom_range(1,100))begin
     mrd_pref_flg = 1;
   end
   else begin
     mrd_pref_flg = 0;
   end
  
   axi_width_mask = (2**<%=obj.DutInfo.wAddr%>)-1;

   if($test$plusargs("conc_15195")) begin
     conc_15195_flg = 1;
   end

   if($test$plusargs("k_force_ns")) begin
     k_force_ns = 1;
   end

   if($test$plusargs("k_send_data_on_dtw_ptl")) begin
     k_send_data_on_dtw_ptl = 1;
   end
   assert(std::randomize(nonrandom_DPdata))
     else begin
       `uvm_error("dmi_base_seq","Failed to randomize data");
     end

endfunction : new


function dmi_base_seq::print_smi_table();
   if($size(smi_table)>0)begin
      `uvm_info("dmi_base_seq", $sformatf("Print contents of print_smi_table "), UVM_DEBUG)
      foreach(smi_table[i])begin
              `uvm_info("dmi_base_seq:print_smi_table",
                        $sformatf("trying to get smi_id smi_table[%0d] :%p",i,smi_table[i]),UVM_DEBUG)
      end
   end
endfunction // print_smi_table
function dmi_base_seq::print_aiu_table();
   if($size(aiu_table)>0)begin
     `uvm_info("dmi_base_seq", $sformatf("Print contents of print aiu_table"), UVM_DEBUG)
      foreach(aiu_table[i])begin
              `uvm_info("dmi_base_seq:clean_aiu_SMI_MsgIDs",
                        $sformatf("aiu_table[%0d] :%p aiu_id :%0x aiu_msg_id :%0x",i,aiu_table[i],i.req_aiu_id,i.req_aiu_msg_id),UVM_DEBUG)
      end
   end
   if($size(aiu_table_nc)>0)begin
     `uvm_info("dmi_base_seq", $sformatf("Print contents of print aiu_table_nc"), UVM_DEBUG)
      foreach(aiu_table_nc[i])begin
              `uvm_info("dmi_base_seq:clean_aiu_SMI_MsgIDs",
                        $sformatf("aiu_table_nc[%0d] :%p aiu_id :%0x aiu_msg_id :%0x",i,aiu_table[i],i.req_aiu_id,i.req_aiu_msg_id),UVM_DEBUG)
      end
   end
endfunction // print_aiu_table

function dmi_base_seq::print_mrd_info_q( bit debug = 1);
   if (mrd_info.size != 0) begin
      `uvm_info("dmi_base_seq", $sformatf("Print contents of mrd_info queue"), UVM_DEBUG)
      foreach (mrd_info[i]) begin
        if(debug)begin
         `uvm_info("dmi_base_seq:print_mrd_info_q",
                   $sformatf("mrd_info[%0d]:dce_id:%0x aiu_id=0x%0x aiu_msg_id=0x%0x smi_msg_id=0x%0x \
                   cache_addr=0x%0x sec=%0b cmd_rsp_recd=%0d dtr_recd=%0d",
                             i,mrd_info[i].dce_id,mrd_info[i].aiu_id, mrd_info[i].aiu_msg_id,
                             mrd_info[i].smi_msg_id, mrd_info[i].cache_addr,
                             mrd_info[i].security,mrd_info[i].cmd_rsp_recd,
                             mrd_info[i].dtr_recd), UVM_DEBUG)
        end
        else begin
         `uvm_info("dmi_base_seq:print_mrd_info_q",
                   $sformatf("mrd_info[%0d]:dce_id:%0x, aiu_id=0x%0x aiu_msg_id=0x%0x smi_msg_id=0x%0x \
                   cache_addr=0x%0x sec=%0b cmd_rsp_recd=%0d dtr_recd=%0d",
                             i,mrd_info[i].dce_id,mrd_info[i].aiu_id, mrd_info[i].aiu_msg_id,
                             mrd_info[i].smi_msg_id, mrd_info[i].cache_addr,
                             mrd_info[i].security,mrd_info[i].cmd_rsp_recd,
                             mrd_info[i].dtr_recd), UVM_LOW)
       end
      end
   end
   else begin
     if(debug)begin
      `uvm_info("dmi_base_seq:print_mrd_info_q", $sformatf("MRD info q is empty"), UVM_DEBUG)
     end
     else begin
      `uvm_info("dmi_base_seq:print_mrd_info_q", $sformatf("MRD info q is empty"), UVM_LOW)
     end
   end
endfunction // print_mrd_info_q
function dmi_base_seq::print_NcRd_info_q(bit debug =1 );
   
   if (NcRd_info.size != 0) begin
     `uvm_info("dmi_base_seq", $sformatf("Print contents of NcRd_info queue"), UVM_DEBUG)
      foreach (NcRd_info[i]) begin
        if(debug)begin
         `uvm_info("dmi_base_seq:print_mrd_info_q",
                   $sformatf("NcRd_info[%0d]:aiu_id=0x%0x smi_msg_id=0x%0x \
                   cache_addr=0x%0x sec=%0b cmd_rsp_recd=%0b str_rsp_sent=%0b dtr_recd=%0b",
                             i,NcRd_info[i].aiu_id,
                             NcRd_info[i].smi_msg_id, NcRd_info[i].cache_addr,
                             NcRd_info[i].security, NcRd_info[i].cmd_rsp_recd, NcRd_info[i].str_rsp_sent,
                             NcRd_info[i].dtr_recd), UVM_DEBUG)
        end
        else begin
         `uvm_info("dmi_base_seq:print_mrd_info_q",
                   $sformatf("NcRd_info[%0d]:aiu_id=0x%0x smi_msg_id=0x%0x \
                   cache_addr=0x%0x sec=%0b cmd_rsp_recd=%0b str_rsp_sent=%0b dtr_recd=%0b",
                             i,NcRd_info[i].aiu_id,
                             NcRd_info[i].smi_msg_id, NcRd_info[i].cache_addr,
                             NcRd_info[i].security, NcRd_info[i].cmd_rsp_recd, NcRd_info[i].str_rsp_sent,
                             NcRd_info[i].dtr_recd), UVM_LOW)
       end
      end
   end
   else begin
    if(debug)begin
      `uvm_info("dmi_base_seq:print_mrd_info_q", $sformatf("MRD info q is empty"), UVM_DEBUG)
    end
    else begin
      `uvm_info("dmi_base_seq:print_mrd_info_q", $sformatf("MRD info q is empty"), UVM_LOW)
    end
   end
endfunction // print_NcRd_info_q

function dmi_base_seq::print_AtmLd_info_q(bit debug = 1 );
   if (AtmLd_info.size != 0) begin
     `uvm_info("dmi_base_seq:print_AtmLd_info_q", $sformatf("Print contents of AtmLd_info queue"), UVM_DEBUG)
      foreach (AtmLd_info[i]) begin
        if(debug)begin
         `uvm_info("dmi_base_seq:print_AtmLd_info_q",
                   $sformatf("AtmLd_info[%0d]:aiu_id=0x%0x smi_msg_id=0x%0x \
                   cache_addr=0x%0x sec=%0b cmd_rsp_recd=%0b str_rsp_sent=%0b dtw_rsp_sent=%0b dtr_recd=%0b  ",
                             i,AtmLd_info[i].aiu_id,
                             AtmLd_info[i].smi_msg_id, AtmLd_info[i].cache_addr,
                             AtmLd_info[i].security, AtmLd_info[i].cmd_rsp_recd, AtmLd_info[i].str_rsp_sent,AtmLd_info[i].dtw_rsp_recd,
                             AtmLd_info[i].dtr_recd), UVM_DEBUG)
        end
        else begin
         `uvm_info("dmi_base_seq:print_AtmLd_info_q",
                   $sformatf("AtmLd_info[%0d]:aiu_id=0x%0x smi_msg_id=0x%0x \
                   cache_addr=0x%0x sec=%0b cmd_rsp_recd=%0b str_rsp_sent=%0b dtw_rsp_sent=%0b dtr_recd=%0b  ",
                             i,AtmLd_info[i].aiu_id,
                             AtmLd_info[i].smi_msg_id, AtmLd_info[i].cache_addr,
                             AtmLd_info[i].security, AtmLd_info[i].cmd_rsp_recd, AtmLd_info[i].str_rsp_sent,AtmLd_info[i].dtw_rsp_recd,
                             AtmLd_info[i].dtr_recd), UVM_LOW)
       end
      end
   end
   else begin
    if(debug)begin
      `uvm_info("dmi_base_seq:print_AtmLd_info_q", $sformatf("AtmLd info q is empty"), UVM_DEBUG)
    end
    else begin
      `uvm_info("dmi_base_seq:print_AtmLd_info_q", $sformatf("AtmLd info q is empty"), UVM_LOW)
    end
   end
endfunction // print_AtmLd_info_q

function dmi_base_seq::print_dtw_info_q(bit debug = 1 );
   if (dtw_info.size != 0) begin
     `uvm_info("dmi_base_seq:print_dtw_info_q", $sformatf("Print contents of dtw_info queue"), UVM_DEBUG)
      foreach (dtw_info[i]) begin
        if(debug)begin
         `uvm_info("dmi_base_seq:print_dtw_info_q",
                   $sformatf("dtw_info[%0d]: aiu_id :%0x smi_msg_id=0x%0x aiu_id_2nd :%0x smi_msg_id_2nd=0x%0x dtr_aiu_id:%0d dtr_rmsg_id:%0d cache_addr=0x%0x sec=%0b dtw_rsp_recd :%0b dtr_recd :%0b isMrgMrd :%0b isMW :%0b",
                             i, dtw_info[i].aiu_id, dtw_info[i].smi_msg_id,dtw_info[i].aiu_id_2nd, dtw_info[i].smi_msg_id_2nd,dtw_info[i].dtr_aiu_id,dtw_info[i].dtr_rmsg_id, dtw_info[i].cache_addr,
                             dtw_info[i].security,dtw_info[i].dtw_rsp_recd,dtw_info[i].dtr_recd,dtw_info[i].isMrgMrd,dtw_info[i].isMW), UVM_DEBUG)
         `uvm_info("dmi_base_seq:print_dtw_info_q",
                   $sformatf("rbid :%0h rb_released:%0b rb_rsp_recd :%0b rb_rl_rsp_expd :%0b rb_rl_rsp_recd :%0b dtws_expd:%0d",dtw_info[i].smi_rbid, dtw_info[i].rb_released, dtw_info[i].rb_rsp_recd,dtw_info[i].rb_rl_rsp_expd,dtw_info[i].rb_rl_rsp_recd,dtw_info[i].dtws_expd),UVM_DEBUG)
        end
        else begin
         `uvm_info("dmi_base_seq:print_dtw_info_q",
                   $sformatf("dtw_info[%0d]: rbid:%0h aiu_id :%0x smi_msg_id=0x%0x aiu_id_2nd :%0x smi_msg_id_2nd=0x%0x  dtr_aiu_id:%0d dtr_rmsg_id:%0d cache_addr=0x%0x sec=%0b dtw_rsp_recd :%0b dtw_rsp_recd_2nd :%0b dtr_recd :%0b isMrgMrd :%0b isMW :%0b",
                             i, dtw_info[i].smi_rbid, dtw_info[i].aiu_id, dtw_info[i].smi_msg_id,dtw_info[i].aiu_id_2nd,dtw_info[i].smi_msg_id_2nd,dtw_info[i].dtr_aiu_id,dtw_info[i].dtr_rmsg_id, dtw_info[i].cache_addr,
                             dtw_info[i].security,dtw_info[i].dtw_rsp_recd,dtw_info[i].dtw_rsp_recd_2nd,dtw_info[i].dtr_recd,dtw_info[i].isMrgMrd,dtw_info[i].isMW), UVM_LOW)
         `uvm_info("dmi_base_seq:print_dtw_info_q",
                   $sformatf("rbid :%0h rb_released:%0b rb_rsp_recd :%0b rb_rl_rsp_expd :%0b rb_rl_rsp_recd :%0b dtws_expd:%0d",dtw_info[i].smi_rbid, dtw_info[i].rb_released, dtw_info[i].rb_rsp_recd,dtw_info[i].rb_rl_rsp_expd,dtw_info[i].rb_rl_rsp_recd,dtw_info[i].dtws_expd),UVM_DEBUG)
       end
      end
   end
   else begin
    if(debug)begin
      `uvm_info("dmi_base_seq:print_dtw_info_q", $sformatf("DTW info q is empty"), UVM_DEBUG)
    end
    else begin
      `uvm_info("dmi_base_seq:print_dtw_info_q", $sformatf("DTW info q is empty"), UVM_LOW)
    end
   end
endfunction // print_dtw_info_q
function dmi_base_seq::print_NcWr_info_q(bit debug = 1 );
   if (NcWr_info.size != 0) begin
     `uvm_info("dmi_base_seq:print_NcWr_info_q", $sformatf("Print contents of NcWr_info queue"), UVM_DEBUG)
      foreach (NcWr_info[i]) begin
        if(debug)begin
         `uvm_info("seq_seq:print_NcWr_info_q",
                   $sformatf("NcWr_info[%0d]:aiu_id :%0x smi_msg_id=0x%0x cache_addr=0x%0x sec=%0b",
                             i, NcWr_info[i].aiu_id, NcWr_info[i].smi_msg_id, NcWr_info[i].cache_addr,
                             NcWr_info[i].security), UVM_DEBUG)
        end
        else begin
         `uvm_info("seq_seq:print_NcWr_info_q",
                   $sformatf("NcWr_info[%0d]:aiu_id :%0x smi_msg_id=0x%0x cache_addr=0x%0x sec=%0b",
                             i, NcWr_info[i].aiu_id, NcWr_info[i].smi_msg_id, NcWr_info[i].cache_addr,
                             NcWr_info[i].security), UVM_LOW)
       end
      end
   end
   else begin
    if(debug)begin
      `uvm_info("seq_seq:print_NcWr_info_q", $sformatf("NcWr info q is empty"), UVM_DEBUG)
    end
    else begin
      `uvm_info("seq_seq:print_NcWr_info_q", $sformatf("NcWr info q is empty"), UVM_LOW)
    end
   end
endfunction // print_NcWr_info_q

function dmi_base_seq::print_pending_q();
  `uvm_info("dmi_base_seq", $sformatf("Txn not completed  aiu_txn_count=%0d",aiu_txn_count),UVM_LOW)
  `uvm_info("dmi_base_seq", $sformatf("Used coherent RBIDs still in flight=%0d", used_cohrbid_q.num),UVM_LOW)
   print_aiu_table();
   print_NcRd_info_q(0);
   print_NcWr_info_q(0);
   print_AtmLd_info_q(0);
   print_dtw_info_q(0);
endfunction // print_pending_q

function dmi_base_seq::process_AIUmsgIDs(smi_seq_item  m_pkt);
   aiu_id_queue_t aiu_queue_entry;
   int            index, size;
   int            tmp_q[$],tmp_q1[$],tmp_q2[$],tmp_q3[$];
   bit            delete_addr = 0;
   AddrQ_t        req_item;
   req_item =  new();

   // The getDTRreqEntryFromSfi function is now implemented. Add ConcertoStates to git again
   `uvm_info("process_AIU_msgIDs", "Entered clean_AIU_msgIDs",UVM_DEBUG)
   `uvm_info("process_AIU_msgIDs",$sformatf("%p",m_pkt),UVM_DEBUG)
   aiu_queue_entry.req_aiu_id       = m_pkt.smi_targ_ncore_unit_id;
   aiu_queue_entry.req_aiu_msg_id   = m_pkt.smi_rmsg_id;  //TBD

   `uvm_info("dmi_base_seq", $sformatf("aiu_queue_entry :tgt_unit_id :%0x smi_rmsg_id :%x ",aiu_queue_entry.req_aiu_id,aiu_queue_entry.req_aiu_msg_id),UVM_DEBUG)
   
   if(!uncorr_wrbuffer_err) begin
   //Match dtr req to rd
   if(m_pkt.isNcCmdRspMsg())begin
     tmp_q = NcRd_info.find_index with ((item.aiu_id == aiu_queue_entry.req_aiu_id) &&
                                    (item.smi_msg_id == aiu_queue_entry.req_aiu_msg_id) &&
                                    (item.cmd_rsp_recd == 0));
     tmp_q1 = NcWr_info.find_index with ((item.aiu_id == aiu_queue_entry.req_aiu_id) &&
                                    (item.smi_msg_id ==  aiu_queue_entry.req_aiu_msg_id) &&
                                    (item.cmd_rsp_recd == 0));

     tmp_q2 = AtmLd_info.find_index with ((item.aiu_id == aiu_queue_entry.req_aiu_id) &&
                                    (item.smi_msg_id ==  aiu_queue_entry.req_aiu_msg_id) &&
                                    (item.cmd_rsp_recd == 0));

     `uvm_info("dmi_base_seq", $sformatf("Multiple NcRd :%0d or NcWr :%0d or NcLd :%0d  matches this cmd rsq",tmp_q.size,tmp_q1.size,tmp_q2.size),UVM_DEBUG)

     if (tmp_q.size +tmp_q1.size +tmp_q2.size == 0) begin
         print_mrd_info_q();
         print_NcRd_info_q();
         print_AtmLd_info_q();
        `uvm_error("dmi_base_seq", $sformatf("No NcRd :%0d or NcWr :%0d or NcLd :%0d matches this cmd rsq",tmp_q.size,tmp_q1.size,tmp_q2.size))
     end
     else if (tmp_q.size +tmp_q1.size + tmp_q2.size > 1) begin
         print_mrd_info_q();
         print_NcRd_info_q();
         print_AtmLd_info_q();
        `uvm_error("dmi_base_seq", $sformatf("Multiple NcRd :%0d or NcWr :%0d or NcLd :%0d  matches this cmd rsq",tmp_q.size,tmp_q1.size,tmp_q2.size))
     end
     else begin
        if(tmp_q.size == 1)begin
         NcRd_info[tmp_q[0]].cmd_rsp_recd = 1;
         if ((NcRd_info[tmp_q[0]].str_rsp_sent == 1  && NcRd_info[tmp_q[0]].dtr_recd == 1)||
             (isCmdNcCacheOpsMsg(NcRd_info[tmp_q[0]].cmd_msg_type) && NcRd_info[tmp_q[0]].str_rsp_sent == 1)) begin 
           clean_AIUmsgIDs(aiu_queue_entry,0); 
           req_item.cache_addr = NcRd_info[tmp_q[0]].cache_addr; // copy before delete
           req_item.security   = NcRd_info[tmp_q[0]].security; // copy before delete
           NcRd_info.delete(tmp_q[0]);
           delete_addr = 1;
           `uvm_info("dmi_base_seq", $sformatf("Calling for NcRd"), UVM_DEBUG)
         end
        end
        else if(tmp_q1.size == 1)begin
         NcWr_info[tmp_q1[0]].cmd_rsp_recd = 1;
         if (NcWr_info[tmp_q1[0]].str_rsp_sent == 1  && NcWr_info[tmp_q1[0]].dtw_rsp_recd == 1) begin 
           clean_AIUmsgIDs(aiu_queue_entry,0); 
           req_item.cache_addr = NcWr_info[tmp_q1[0]].cache_addr; // copy before delete
           req_item.security   = NcWr_info[tmp_q1[0]].security; // copy before delete
           NcWr_info.delete(tmp_q1[0]);
           delete_addr = 1;
           `uvm_info("dmi_base_seq", $sformatf("Calling for NcWr"), UVM_DEBUG)
         end
        end
        else begin
         AtmLd_info[tmp_q2[0]].cmd_rsp_recd = 1;
         if (AtmLd_info[tmp_q2[0]].str_rsp_sent == 1  && AtmLd_info[tmp_q2[0]].dtr_recd == 1 && AtmLd_info[tmp_q2[0]].dtw_rsp_recd == 1) begin 
           clean_AIUmsgIDs(aiu_queue_entry,0); 
           req_item.cache_addr = AtmLd_info[tmp_q2[0]].cache_addr; // copy before delete
           req_item.security   = AtmLd_info[tmp_q2[0]].security; // copy before delete
           AtmLd_info.delete(tmp_q2[0]);
           delete_addr = 1;
           `uvm_info("dmi_base_seq", $sformatf("Calling for AtmLd"), UVM_DEBUG)
         end
        end
     end
    end
   else if(m_pkt.isStrMsg())begin
     tmp_q = NcRd_info.find_index with ((item.aiu_id == aiu_queue_entry.req_aiu_id) &&
                                    (item.smi_msg_id == aiu_queue_entry.req_aiu_msg_id) &&
                                    (item.str_recd == 1) &&
                                    item.str_rsp_sent == 0 );

     tmp_q1 = NcWr_info.find_index with ((item.aiu_id == aiu_queue_entry.req_aiu_id) &&
                                    (item.smi_msg_id ==  aiu_queue_entry.req_aiu_msg_id) &&
                                    (item.str_recd == 1) &&
                                    item.str_rsp_sent == 0);

     tmp_q2 = AtmLd_info.find_index with ((item.aiu_id == aiu_queue_entry.req_aiu_id) &&
                                    (item.smi_msg_id ==  aiu_queue_entry.req_aiu_msg_id) &&
                                    (item.str_recd == 1) &&
                                    item.str_rsp_sent == 0);

     `uvm_info("dmi_base_seq", $sformatf("Multiple NcRd :%0d or NcWr :%0d or NcLd :%0d  matches this str rsq",tmp_q.size,tmp_q1.size,tmp_q2.size),UVM_DEBUG)
     if (tmp_q.size +tmp_q1.size + tmp_q2.size == 0) begin
         print_mrd_info_q();
         print_NcRd_info_q();
         print_AtmLd_info_q();
        `uvm_error("dmi_base_seq", $sformatf("No NcRd :%0d or NcWr :%0d or NcLd :%0d matches this str rsq",tmp_q.size,tmp_q1.size,tmp_q2.size))
     end
     else if (tmp_q.size +tmp_q1.size + tmp_q2.size > 1) begin
         print_mrd_info_q();
         print_NcRd_info_q();
         print_AtmLd_info_q();
        `uvm_error("dmi_base_seq", $sformatf("Multiple NcRd :%0d or NcWr :%0d or NcLd :%0d  matches this str rsq",tmp_q.size,tmp_q1.size,tmp_q2.size))
     end
     else begin
        if(tmp_q.size == 1)begin
         NcRd_info[tmp_q[0]].str_rsp_sent = 1;
         if ((NcRd_info[tmp_q[0]].cmd_rsp_recd == 1 && NcRd_info[tmp_q[0]].dtr_recd == 1 && NcRd_info[tmp_q[0]].str_recd) ||
             (isCmdNcCacheOpsMsg(NcRd_info[tmp_q[0]].cmd_msg_type) && NcRd_info[tmp_q[0]].cmd_rsp_recd == 1 && NcRd_info[tmp_q[0]].str_recd == 1)) begin 
           clean_AIUmsgIDs(aiu_queue_entry,0); 
           req_item.cache_addr = NcRd_info[tmp_q[0]].cache_addr; // copy before delete
           req_item.security   = NcRd_info[tmp_q[0]].security; // copy before delete
           NcRd_info.delete(tmp_q[0]);
           delete_addr = 1;
           `uvm_info("dmi_base_seq", $sformatf("Calling for NcRd"), UVM_DEBUG)
         end
        end
        else if(tmp_q1.size == 1) begin
         NcWr_info[tmp_q1[0]].str_rsp_sent = 1;
         if (NcWr_info[tmp_q1[0]].cmd_rsp_recd == 1 && NcWr_info[tmp_q1[0]].dtw_rsp_recd == 1 && NcWr_info[tmp_q1[0]].str_recd ) begin 
           clean_AIUmsgIDs(aiu_queue_entry,0); 
           req_item.cache_addr = NcWr_info[tmp_q1[0]].cache_addr; // copy before delete
           req_item.security   = NcWr_info[tmp_q1[0]].security; // copy before delete
           NcWr_info.delete(tmp_q1[0]);
           delete_addr = 1;
           `uvm_info("dmi_base_seq", $sformatf("Calling for NcWr"), UVM_DEBUG)
         end
        end
        else  begin
          AtmLd_info[tmp_q2[0]].str_rsp_sent = 1;
         if (AtmLd_info[tmp_q2[0]].cmd_rsp_recd == 1 && AtmLd_info[tmp_q2[0]].dtw_rsp_recd == 1 && AtmLd_info[tmp_q2[0]].dtr_recd == 1 ) begin 
           clean_AIUmsgIDs(aiu_queue_entry,0); 
           req_item.cache_addr = AtmLd_info[tmp_q2[0]].cache_addr; // copy before delete
           req_item.security   = AtmLd_info[tmp_q2[0]].security; // copy before delete
           AtmLd_info.delete(tmp_q2[0]);
           delete_addr = 1;
           `uvm_info("dmi_base_seq", $sformatf("Calling for AtmNcWr"), UVM_DEBUG)
         end
        end
      end
    end
   else if(m_pkt.isDtrMsg())begin
     tmp_q = mrd_info.find_index with ((item.aiu_id == aiu_queue_entry.req_aiu_id) &&
                                    (item.aiu_msg_id == aiu_queue_entry.req_aiu_msg_id) &&
                                    (item.dtr_recd == 0));

     tmp_q1 = NcRd_info.find_index with ((item.aiu_id == aiu_queue_entry.req_aiu_id) &&
                                    (item.smi_msg_id == aiu_queue_entry.req_aiu_msg_id) &&
                                    (item.dtr_recd == 0));

     tmp_q2 = AtmLd_info.find_index with ((item.aiu_id == aiu_queue_entry.req_aiu_id) &&
                                    (item.smi_msg_id == aiu_queue_entry.req_aiu_msg_id) &&
                                    !(isCmdNcCacheOpsMsg(item.cmd_msg_type)) &&
                                    (item.dtr_recd == 0));

     tmp_q3 = dtw_info.find_index with (item.isMrgMrd  &&
                                       (item.dtr_aiu_id == aiu_queue_entry.req_aiu_id) &&
                                       (item.dtr_rmsg_id == aiu_queue_entry.req_aiu_msg_id) &&
                                       (item.dtr_recd == 0));

     if (tmp_q.size +tmp_q1.size + tmp_q2.size + tmp_q3.size == 0) begin
         print_mrd_info_q();
         print_dtw_info_q();
         print_NcRd_info_q();
         print_AtmLd_info_q();
        `uvm_error("dmi_base_seq", $sformatf("No NcRd :%0d or NcWr :%0d or NcLd :%0d matches this dtr req",tmp_q.size,tmp_q1.size,tmp_q2.size))
     end
     else if ((tmp_q.size +tmp_q1.size() + tmp_q2.size() + tmp_q3.size) > 1) begin
        `uvm_error("dmi_base_seq", $sformatf("Multiple NcRd :%0d or NcWr :%0d or NcLd :%0d  matches this dtr req",tmp_q.size,tmp_q1.size,tmp_q2.size))
     end
     else begin
        if(tmp_q.size == 1)begin
         mrd_info[tmp_q[0]].dtr_recd = 1;
         if (mrd_info[tmp_q[0]].cmd_rsp_recd == 1) begin 
           clean_AIUmsgIDs(aiu_queue_entry,1); 
           req_item.cache_addr = mrd_info[tmp_q[0]].cache_addr; // copy before delete
           req_item.security   = mrd_info[tmp_q[0]].security; // copy before delete
           req_item.isMrd      =  1;
           delete_addr = 1;
           `uvm_info("dmi_base_seq", $sformatf("Calling for Mrd"), UVM_DEBUG)
           mrd_info.delete(tmp_q[0]);
         end
        end
        else if(tmp_q1.size == 1) begin
         NcRd_info[tmp_q1[0]].dtr_recd = 1;
         if (NcRd_info[tmp_q1[0]].cmd_rsp_recd == 1 && NcRd_info[tmp_q1[0]].str_rsp_sent == 1) begin 
           clean_AIUmsgIDs(aiu_queue_entry,0); 
           req_item.cache_addr = NcRd_info[tmp_q1[0]].cache_addr; // copy before delete
           req_item.security   = NcRd_info[tmp_q1[0]].security; // copy before delete
           req_item.isNcRd      =  1;
           delete_addr = 1;
           `uvm_info("dmi_base_seq", $sformatf("Calling for NcRd"), UVM_DEBUG)
           NcRd_info.delete(tmp_q1[0]);
         end
        end
       else if(tmp_q2.size == 1) begin
         AtmLd_info[tmp_q2[0]].dtr_recd = 1;
         if (AtmLd_info[tmp_q2[0]].cmd_rsp_recd == 1 && AtmLd_info[tmp_q2[0]].str_rsp_sent == 1 && AtmLd_info[tmp_q2[0]].dtw_rsp_recd == 1 ) begin 
           clean_AIUmsgIDs(aiu_queue_entry,0); 
           req_item.cache_addr = AtmLd_info[tmp_q2[0]].cache_addr; // copy before delete
           req_item.security   = AtmLd_info[tmp_q2[0]].security; // copy before delete
           req_item.isNcRd      =  1;
           delete_addr = 1;
           `uvm_info("dmi_base_seq", $sformatf("Calling for AtmLd "), UVM_DEBUG)
           AtmLd_info.delete(tmp_q2[0]);
         end
       end
       else begin
         dtw_info[tmp_q3[0]].dtr_recd = 1;
         if(dtw_info[tmp_q3[0]].isMrgMrd)begin
           clean_AIUmsgIDs(aiu_queue_entry,1,1); 
         if(dtw_info[tmp_q3[0]].dtw_rsp_recd == 1 ) begin 
           aiu_queue_entry.req_aiu_id       = dtw_info[tmp_q3[0]].aiu_id;
           aiu_queue_entry.req_aiu_msg_id   = dtw_info[tmp_q3[0]].smi_msg_id;  //TBD
           clean_AIUmsgIDs(aiu_queue_entry,1); 
           req_item.cache_addr = dtw_info[tmp_q3[0]].cache_addr; // copy before delete
           req_item.security   = dtw_info[tmp_q3[0]].security; // copy before delete
           req_item.isNcRd      =  1;
           delete_addr = 1;
           `uvm_info("dmi_base_seq", $sformatf("Calling for dtwMrgMrd "), UVM_DEBUG)
           if(dtw_info[tmp_q3[0]].rb_rsp_recd)begin
             dtw_info.delete(tmp_q3[0]);
           end
         end
        end
       end
     end
   end
   else if(m_pkt.isDtwRspMsg())begin
     numDtwRsp++;
     tmp_q = dtw_info.find_index with ((item.aiu_id == aiu_queue_entry.req_aiu_id) &&
                                    (item.smi_msg_id == aiu_queue_entry.req_aiu_msg_id) &&
                                    (item.dtw_rsp_recd == 0));

     tmp_q3 = dtw_info.find_index with ( item.isMW &&
                                        (item.aiu_id_2nd == aiu_queue_entry.req_aiu_id) &&
                                        (item.smi_msg_id_2nd == aiu_queue_entry.req_aiu_msg_id) &&
                                        (item.dtw_rsp_recd_2nd == 0));

     tmp_q1 = NcWr_info.find_index with ((item.aiu_id == aiu_queue_entry.req_aiu_id) &&
                                    (item.smi_msg_id ==  aiu_queue_entry.req_aiu_msg_id) &&
                                    (item.str_recd == 1) &&
                                    (item.dtw_rsp_recd == 0));

     tmp_q2 = AtmLd_info.find_index with ((item.aiu_id == aiu_queue_entry.req_aiu_id) &&
                                    (item.smi_msg_id ==  aiu_queue_entry.req_aiu_msg_id) &&
                                    (item.str_recd == 1) &&
                                    (item.dtw_rsp_recd == 0));

     if (tmp_q.size + tmp_q1.size + tmp_q2.size +tmp_q3.size == 0) begin
         print_dtw_info_q();
         print_NcWr_info_q();
        `uvm_error("dmi_base_seq", $sformatf("No Ch/Nc dtw,AtmLoad  matches this Dtw rsp receiced :tgt_unit_id :%0x smi_rmsg_id :%d ",aiu_queue_entry.req_aiu_id,aiu_queue_entry.req_aiu_msg_id))
     end
     else if (tmp_q.size +tmp_q1.size + tmp_q2.size + tmp_q3.size  > 1) begin
        `uvm_error("dmi_base_seq", $sformatf("Multiple dtw  for  this Dtw rsq ChWr :%0d NcWr :%0d AtmLd :%0d",tmp_q.size,tmp_q1.size,tmp_q2.size))
     end
     else begin
       
        if(tmp_q.size == 1)begin 
           dtw_info[tmp_q[0]].dtw_rsp_recd = 1;          
           if(dtw_info[tmp_q[0]].rb_rsp_recd && !dtw_info[tmp_q[0]].rb_released) begin
             `uvm_error("dmi_base_seq", $sformatf("RBID:%0h should have been released earlier", dtw_info[tmp_q[0]].smi_rbid))
           end
           req_item.cache_addr = dtw_info[tmp_q[0]].cache_addr; // copy before delete
           req_item.security   = dtw_info[tmp_q[0]].security; // copy before delete
           req_item.isDtw      =  1;
           `uvm_info("dmi_base_seq", $sformatf("Calling for dtw"), UVM_DEBUG)
           if(dtw_info[tmp_q[0]].isMrgMrd)begin
             if(dtw_info[tmp_q[0]].dtr_recd == 1)begin
               delete_addr = 1;
               clean_AIUmsgIDs(aiu_queue_entry,1); 
               aiu_queue_entry.req_aiu_id       = m_pkt.smi_targ_ncore_unit_id;
               aiu_queue_entry.req_aiu_msg_id   = m_pkt.smi_rmsg_id; 
               if(dtw_info[tmp_q[0]].rb_rsp_recd)begin
                dtw_info.delete(tmp_q[0]);
               end
             end
           end
           else begin
             delete_addr = 1;
             clean_AIUmsgIDs(aiu_queue_entry,1); 
             if(dtw_info[tmp_q[0]].isMW)begin
               if(dtw_info[tmp_q[0]].rb_rsp_recd && dtw_info[tmp_q[0]].dtw_rsp_recd_2nd)begin
                 dtw_info.delete(tmp_q[0]);
               end
             end
             else begin
               if(dtw_info[tmp_q[0]].rb_rsp_recd)begin
                 dtw_info.delete(tmp_q[0]);
               end
             end
           end
       end
       else if(tmp_q3.size == 1)begin 
           dtw_info[tmp_q3[0]].dtw_rsp_recd_2nd = 1;
           `uvm_info("dmi_base_seq", $sformatf("Calling for dtw"), UVM_DEBUG)
            if(dtw_info[tmp_q3[0]].dtws_expd == 2) send_primary_dtw(dtw_info[tmp_q3[0]].smi_rbid);
            clean_AIUmsgIDs(aiu_queue_entry,1); 
            if(dtw_info[tmp_q3[0]].rb_rsp_recd && dtw_info[tmp_q3[0]].dtw_rsp_recd)begin
             dtw_info.delete(tmp_q3[0]);
            end
       end
       else if(tmp_q1.size() == 1) begin
           NcWr_info[tmp_q1[0]].dtw_rsp_recd = 1;
           if(NcWr_info[tmp_q1[0]].cmd_rsp_recd == 1 && NcWr_info[tmp_q1[0]].str_rsp_sent == 1)begin 
           clean_AIUmsgIDs(aiu_queue_entry,0); 
           req_item.cache_addr = NcWr_info[tmp_q1[0]].cache_addr; // copy before delete
           req_item.security   = NcWr_info[tmp_q1[0]].security; // copy before delete
           req_item.isDtw      =  1;
           delete_addr = 1;
           `uvm_info("dmi_base_seq", $sformatf("Calling for dtw"), UVM_DEBUG)
           NcWr_info.delete(tmp_q1[0]);
           end
       end
       else  begin
           AtmLd_info[tmp_q2[0]].dtw_rsp_recd = 1;
           if(AtmLd_info[tmp_q2[0]].cmd_rsp_recd == 1 && AtmLd_info[tmp_q2[0]].str_rsp_sent == 1 && AtmLd_info[tmp_q2[0]].dtr_recd == 1)begin 
           clean_AIUmsgIDs(aiu_queue_entry,0); 
           req_item.cache_addr = AtmLd_info[tmp_q2[0]].cache_addr; // copy before delete
           req_item.security   = AtmLd_info[tmp_q2[0]].security; // copy before delete
           req_item.isDtw      =  1;
           delete_addr = 1;
           `uvm_info("dmi_base_seq", $sformatf("Calling for AtmLd"), UVM_DEBUG)
           AtmLd_info.delete(tmp_q2[0]);
           end
       end
     end
   end
   else if(m_pkt.isRbRspMsg())begin
     int all_rls_q[$], all_int_wr_q[$], mixed_q[$];
     bit delete_dtw_entry, clean_smi_id;

     tmp_q  = dtw_info.find_index with ((item.smi_rbid == m_pkt.smi_rbid) &&
                                        (item.dce_id  == aiu_queue_entry.req_aiu_id ) &&
                                       (!item.rb_rsp_recd));

     if(tmp_q.size()>1) begin 
       print_dtw_info_q();
       `uvm_error("dmi_base_seq", $sformatf("Found multiple matches for RBID:%0h. Match_q: %0p", m_pkt.smi_rbid, tmp_q))
     end
     else if(tmp_q.size()==0) begin
       print_smi_table();
       `uvm_error("dmi_base_seq", $sformatf("RbRsp with smi_rbid :%0h and msg_id :%0h not matching any pending RbReq",m_pkt.smi_rbid, aiu_queue_entry.req_aiu_msg_id))
     end

     //Create three queues 

     //1. All internal release case: Release immediately, no dependency
     all_rls_q = dtw_info.find_index with ((item.smi_rbid[WSMIRBID-2:0] === m_pkt.smi_rbid[WSMIRBID-2:0]) &&
                                           (item.dce_id  == aiu_queue_entry.req_aiu_id ) &&
                                           item.rb_rl_rsp_expd && !item.rb_released);
     //2. All DTW case: Both the RBs are being used to send coherent data. Release only on receiving DtwRsp+RbRsp per entry
     all_int_wr_q =  dtw_info.find_index with((item.smi_rbid[WSMIRBID-2:0] === m_pkt.smi_rbid[WSMIRBID-2:0]) &&
                                              (item.dce_id  == aiu_queue_entry.req_aiu_id ) &&
                                              !item.rb_rl_rsp_expd && !item.rb_released);
     //3. Mixed case, wait on both RBrsp to release (rbid, flipped_rbid). Release on second RBRsp and delete both dtw_info entries
     mixed_q = dtw_info.find_index with ((item.smi_rbid[WSMIRBID-2:0] === m_pkt.smi_rbid[WSMIRBID-2:0]) &&
                                         (item.dce_id  == aiu_queue_entry.req_aiu_id ) &&
                                         (item.rb_rl_rsp_expd || item.dtws_expd > 0)&& !item.rb_released);

     print_dtw_info_q();

     if(tmp_q.size == 1)begin 
        dtw_info[tmp_q[0]].rb_rsp_recd = 1;
        req_item.cache_addr = dtw_info[tmp_q[0]].cache_addr; // copy before delete
        req_item.security   = dtw_info[tmp_q[0]].security; // copy before delete
        req_item.isDtw      =  1;
        if(dtw_info[tmp_q[0]].isMW) begin 
          if(dtw_info[tmp_q[0]].isMrgMrd)begin
            if(dtw_info[tmp_q[0]].dtw_rsp_recd && dtw_info[tmp_q[0]].dtw_rsp_recd_2nd && dtw_info[tmp_q[0]].dtw_rsp_recd && dtw_info[tmp_q[0]].dtr_recd)begin
              //TODO refine releasing cohrbid in these cases
              delete_dtw_entry = 1;
            end
          end
          else begin
            if(dtw_info[tmp_q[0]].dtw_rsp_recd && dtw_info[tmp_q[0]].dtw_rsp_recd_2nd)begin
              delete_dtw_entry = 1;
            end
          end
        end
        else if(dtw_info[tmp_q[0]].isMrgMrd && !dtw_info[tmp_q[0]].isMW) begin 
          if(dtw_info[tmp_q[0]].dtw_rsp_recd && dtw_info[tmp_q[0]].dtr_recd)begin
            delete_dtw_entry = 1; 
          end
        end
        else if(dtw_info[tmp_q[0]].isMrgMrd && dtw_info[tmp_q[0]].isMW && (dtw_info[tmp_q[0]].dtws_expd == 2)
               && dtw_info[tmp_q[0]].dtw_rsp_recd && !dtw_info[tmp_q[0]].dtw_rsp_recd_2nd) begin
           `uvm_info("dmi_base_seq","Not deleting this dtw entry, waiting on second DTWRsp",UVM_HIGH)
        end
        else begin
          if(dtw_info[tmp_q[0]].rb_rl_rsp_expd && !dtw_info[tmp_q[0]].rb_rl_rsp_recd) begin
            dtw_info[tmp_q[0]].rb_rl_rsp_recd = 1;
            delete_dtw_entry = 1;
          end
          if(dtw_info[tmp_q[0]].dtw_rsp_recd) begin
            delete_dtw_entry = 1;
          end
        end
     end

     //Decide RBID release process
     `uvm_info("dmi_base_seq",$sformatf("Matches found all_rls_q: %0d, all_int_wr_q: %0d, mixed_q: %0d tmp_q: %0d", all_rls_q.size(), all_int_wr_q.size(), mixed_q.size(), tmp_q.size()),UVM_MEDIUM)

     if(all_rls_q.size() == 2 && tmp_q.size()==1) begin
       foreach(all_rls_q[i]) begin
         if(dtw_info[all_rls_q[i]].rb_rl_rsp_recd ) begin //Process internal release when both responses are received
         aiu_queue_entry.req_aiu_id       = dtw_info[all_rls_q[i]].aiu_id;
         aiu_queue_entry.req_aiu_msg_id   = dtw_info[all_rls_q[i]].smi_msg_id; 
         clean_AIUmsgIDs(aiu_queue_entry,1); 
         release_cohrbid(dtw_info[all_rls_q[i]].smi_rbid);
         dtw_info[all_rls_q[i]].rb_released = 1;
         end
       end
     end
     else if(mixed_q.size() == 2) begin
       foreach(mixed_q[i])begin
        if(dtw_info[mixed_q[i]].rb_rsp_recd  && dtw_info[mixed_q[i]].rb_rl_rsp_expd && dtw_info[mixed_q[i]].rb_rl_rsp_recd &&
           all_rls_q.size() != 2
        ) begin //Make sure you process internal release when both transactions are received in a mixed case
         aiu_queue_entry.req_aiu_id       = dtw_info[mixed_q[i]].aiu_id;
         aiu_queue_entry.req_aiu_msg_id   = dtw_info[mixed_q[i]].smi_msg_id; 
         clean_AIUmsgIDs(aiu_queue_entry,1); 
         release_cohrbid(dtw_info[mixed_q[i]].smi_rbid);
         dtw_info[mixed_q[i]].rb_released = 1;
        end
       end
     end
     else if(all_int_wr_q.size() inside {1,2}) begin
       foreach(all_int_wr_q[i])begin
         //Early Single or Double Coherent Write from DCE
         if(( dtw_info[all_int_wr_q[i]].rb_rsp_recd &&
             !dtw_info[all_int_wr_q[i]].isMW && (dtw_info[all_int_wr_q[i]].smi_rbid == m_pkt.smi_rbid) && !dtw_info[all_int_wr_q[i]].rb_released)) begin
           print_dtw_info_q();
           release_cohrbid(dtw_info[all_int_wr_q[i]].smi_rbid);
           dtw_info[all_int_wr_q[i]].rb_released = 1;
         end
         else if((dtw_info[all_int_wr_q[i]].isMW || dtw_info[all_int_wr_q[i]].isMrgMrd) && dtw_info[all_int_wr_q[i]].rb_rsp_recd) begin
           `uvm_info("dmi_base_seq",$sformatf("Expecting a second DTW response, releasing RBID but retaining information in dtw_info"),UVM_DEBUG) //FIXME
           release_cohrbid(dtw_info[all_int_wr_q[i]].smi_rbid);
           dtw_info[all_int_wr_q[i]].rb_released = 1;
         end
       end
     end
     else begin
       `uvm_error("dmi_base_seq", $sformatf("Failed to match RbRsp to any existing DTW info items RBID:%0h", m_pkt.smi_rbid))
     end 
     if(delete_dtw_entry) begin
        dtw_info.delete(tmp_q[0]);
        `uvm_info("dmi_base_seq", $sformatf("Deleting entry %0d dtw_info size:%0d", tmp_q[0], dtw_info.size()),UVM_DEBUG);
     end
   end
   else begin
      `uvm_error("dmi_base_seq", $sformatf("Recevied unexpected cmd type or rsp received smi_msg_type :%0x Tgt AiuId :%0d msg_id :%0x r_msg_id :%0x ", m_pkt.smi_msg_type,m_pkt.smi_targ_ncore_unit_id,m_pkt.smi_msg_id,m_pkt.smi_rmsg_id))
   end
   if(delete_addr)begin
      req_item.aiu_id     = aiu_queue_entry.req_aiu_id;
      req_item.smi_msg_id = aiu_queue_entry.req_aiu_msg_id;
   end
   end
endfunction // process_AIUmsgIDs

function dmi_base_seq::clean_AIUmsgIDs(aiu_id_queue_t aiu_queue_entry, bit Coh,bit isMrgMrd = 0);
   int            index, size;
   int            tmp_q[$];
   AddrQ_t        req_item;
   req_item =  new();

   // The getDTRreqEntryFromSfi function is now implemented. Add ConcertoStates to git again

   `uvm_info("clean_AIU_msgIDs",$sformatf("isCoh :%0b aiu_queue_entry=%p",Coh,aiu_queue_entry), UVM_DEBUG)
   print_aiu_table();
   if(!uncorr_wrbuffer_err) begin
     if(Coh)begin
          if(aiu_table.exists(aiu_queue_entry))begin
                aiu_table.delete(aiu_queue_entry);
                `uvm_info("clean_AIU_msgIDs",
                    $sformatf("Match found for Coh req_aiu_id=0x%x,req_aiu_msg_id=0x%x. Marking free",
                              aiu_queue_entry.req_aiu_id, aiu_queue_entry.req_aiu_msg_id),UVM_DEBUG)
          end
          else begin
          `uvm_error("clean_AIU_msgIDs",
                    $sformatf("aiu_queue_entry not matching any aiu_table entry :%0p",aiu_queue_entry))
          end
        ->e_aiusmi_id_clean;
        ->e_aiusmi_id_clean_nc;
      end
      else begin
          if(aiu_table_nc.exists(aiu_queue_entry))begin
                aiu_table_nc.delete(aiu_queue_entry);
                `uvm_info("clean_AIU_msgIDs",
                    $sformatf("Match found for Nc req_aiu_id=0x%x,req_aiu_msg_id=0x%x. Marking free",
                              aiu_queue_entry.req_aiu_id, aiu_queue_entry.req_aiu_msg_id),UVM_DEBUG)
          end
          else begin
          `uvm_error("clean_AIU_msgIDs",
                    $sformatf("aiu_queue_entry not matching any aiu_table entry :%0p",aiu_queue_entry))
          end
        Nctxns_in_flight -= 1;
        ->e_aiusmi_id_clean_nc;
        ->e_aiusmi_id_clean;
      end
        if(!isMrgMrd)begin
          aiu_txn_count -= 1;
        end
    end
endfunction // clean_AIUmsgIDs

function dmi_base_seq::clean_SMIMsgIDs(smi_seq_item  seq_item);
   aiu_id_queue_t aiu_queue_entry;
   int            index, size;
   int            tmp_q[$],tmp_q1[$];
   smi_msg_id_t   smi_queue_entry;
   AddrQ_t        req_item;
   req_item =  new();

   `uvm_info("clean_SMI_MsgIDs", "Entered clean_SMI_MsgIDs",UVM_DEBUG)
      // free smi ID for reuse
      smi_queue_entry = seq_item.smi_rmsg_id;
      tmp_q1 = smi_table.find_index with (((item.smi_msg_id == seq_item.smi_rmsg_id & !seq_item.isRbRspMsg())||
                                           ((item.smi_rbid == seq_item.smi_rbid) & item.valRb & seq_item.isRbRspMsg())) &&
                                          item.src_id  == seq_item.smi_targ_ncore_unit_id); 

      if(!tmp_q1.size())begin
          `uvm_error("clean_SMIMsgIDs ",
                    $sformatf("smi_queue_entry not matching any src_id :%0d smi_msg_id inflight :%0p",seq_item.smi_targ_ncore_unit_id,smi_queue_entry))
      
      end
      else if(tmp_q1.size() >1)begin
        if($test$plusargs("shuffle_rb_seq")) begin
          smi_table.delete(tmp_q1[0]);
        end
        else
          `uvm_error("clean_SMIMsgIDs ",
                    $sformatf("smi_queue_entry matching multi src_id :%0d smi_msg_id inflight :%0p",seq_item.smi_targ_ncore_unit_id, smi_queue_entry))
      end
      else begin
            `uvm_info("clean_SMIMsgIDs",
                      $sformatf("Match found for src_id :%0d smi_msg_id=0x%x isUse = %0b. Marking free",
                                smi_table[tmp_q1[0]].src_id,smi_table[tmp_q1[0]].smi_msg_id,smi_table[tmp_q1[0]].inUse),UVM_DEBUG)
            smi_table.delete(tmp_q1[0]);
      end
      // Reduce number of inflight txns on smi if
      smi_txn_count  -= 1;
      if(seq_item.isMrdRspMsg())begin
        print_mrd_info_q();
        tmp_q = mrd_info.find_index with ((item.smi_msg_id == seq_item.smi_rmsg_id) &&
                                           item.dce_id    == seq_item.smi_targ_ncore_unit_id &&
                                          (item.cmd_rsp_recd == 0));
        if (tmp_q.size == 0) begin
           `uvm_info("mas_seq", $sformatf("Response seen for non-MRD transaction"), UVM_DEBUG)
        end
        else if (tmp_q.size > 1) begin
           `uvm_info("", $sformatf("SMI Msgid=0x%0x",smi_queue_entry), UVM_DEBUG)
           `uvm_error("dmi_base_seq", "SMI Msg ID for rsp matches multiple MRD requests")
        end
        else begin
           `uvm_info("dmi_base_seq", $sformatf("SMI Msgid=0x%0x Matched MRD info entry!",smi_queue_entry), UVM_DEBUG)
           mrd_info[tmp_q[0]].cmd_rsp_recd = 1;
           mrd_in_flight_cnt -= 1;
          ->e_mrd_smi_id_clean;
           if ((mrd_info[tmp_q[0]].dtr_recd == 1) || (mrd_info[tmp_q[0]].cmd_msg_type inside {MRD_FLUSH, MRD_INV, MRD_CLN,MRD_PREF})) begin // delete if dtr already seen
                `uvm_info("dmi_base_seq", $sformatf("DTR Req already seen. Deleting entry"), UVM_DEBUG)
                aiu_queue_entry.req_aiu_id       = mrd_info[tmp_q[0]].aiu_id;
                aiu_queue_entry.req_aiu_msg_id   = mrd_info[tmp_q[0]].aiu_msg_id;
                clean_AIUmsgIDs(aiu_queue_entry,1); 
                req_item.cache_addr = mrd_info[tmp_q[0]].cache_addr; // copy before delete
                req_item.security   = mrd_info[tmp_q[0]].security;
                mrd_info.delete(tmp_q[0]);
                req_item.cmd_msg_type = MRD_RD_WITH_UNQ;
                req_item.smi_msg_id = smi_queue_entry;
                `uvm_info("dmi_base_seq", $sformatf("Calling for MRD"), UVM_DEBUG)
           end
        end // else: !if(tmp_q.size > 1)
      end
      ->e_smi_id_clean;

endfunction // clean_SMIMsgIDs


// ------------------------------------------------------------------
// The function gives the user the flexibility to set the TM-Bit
// to his/her desirable weight percentage for a particular SMI...
// ------------------------------------------------------------------
function bit dmi_base_seq::check_And_Set_TmBit(smi_seq_item req_item);
  int tmpTmPerc = 0;
  
  // eConcMsgStrReq, eConcMsgCmdReq
  if (req_item.isStrMsg()==1'b1 || req_item.isCmdMsg()==1'b1) begin
     tmpTmPerc = (dmiTmBit4Smi0 != 0) ? dmiTmBit4Smi0 : $urandom_range(1,100); 
     return(($urandom_range(1,100) <= (100 - tmpTmPerc)) ? 'b0 : 'b1);
  end

  // eConcMsgRbReq, eConcMsgMrdReq
  if (req_item.isRbMsg()==1'b1 || req_item.isMrdMsg()==1'b1) begin
     tmpTmPerc = (dmiTmBit4Smi2 != 0) ? dmiTmBit4Smi2 : $urandom_range(1,100); 
     return(($urandom_range(1,100) <= (100 - tmpTmPerc)) ? 'b0 : 'b1);
  end

  // eConcMsgDtwReq, eConcMsgDtrReq
  if (req_item.isDtwMsg()==1'b1 || req_item.isDtrMsg()==1'b1) begin
     tmpTmPerc = (dmiTmBit4Smi3 != 0) ? dmiTmBit4Smi3 : $urandom_range(1,100); 
     return(($urandom_range(1,100) <= (100 - tmpTmPerc)) ? 'b0 : 'b1);
  end

  return($urandom);         // Return gracefully the original smi_tm value..

endfunction : check_And_Set_TmBit

task dmi_base_seq::disable_body;
  disable this.body;
endtask
//------------------------------------------------------------------------------
// Body Task
//------------------------------------------------------------------------------
task dmi_base_seq::body;

  aiu_id_queue_t aiu_queue_entry;
  int                 idx_sp_base;
  int                 idx_sp_max;
 
  smi_seq_item  req_item,req_item_2nd;
  smi_seq_item  req_rbid_item;
  smi_addr_t    cache_addr;

  int tmp_q[$];
  int tmp_q2[$];
  bit cmd_status;
  //TODO VIK
  //6. Write a coverpoint for address utilization, hit it.
  initialize();
  if((2**(WSTRREQMSGID))>MAX_NCMSGID_IN_FLIGHT) begin
     strrsp_bp_count = k_num_cmd/MAX_NCMSGID_IN_FLIGHT; 
  end
  else begin
     strrsp_bp_count = k_num_cmd/(2**(WSTRREQMSGID));
  end

  <% for (var i = 0; i < obj.nSmiTx; i++) { %>
  <% for (var j = 0; j < obj.DmiInfo[obj.Id].smiPortParams.tx[i].params.fnMsgClass.length; j++) { %>
  if(!$cast(m_smi_seqr_rx_hash["<%=obj.DmiInfo[obj.Id].smiPortParams.tx[i].params.fnMsgClass[j]%>"],p_sequencer.m_smi<%=i%>_rx_seqr))begin
     `uvm_error("dmi_base_seq","p_sequencer.m_smi<%=i%>_rx_seqr type missmatch");
  end
  <% } %>
  <% } %>
  //---------------------"<JS format fixer>
  <% for (var i = 0; i < obj.nSmiRx; i++) { %>
  <% for (var j = 0; j < obj.DmiInfo[obj.Id].smiPortParams.rx[i].params.fnMsgClass.length; j++) { %>
  if(!$cast(m_smi_seqr_tx_hash["<%=obj.DmiInfo[0].smiPortParams.rx[i].params.fnMsgClass[j]%>"],p_sequencer.m_smi<%=i%>_tx_seqr))begin
     `uvm_error("dmi_base_seq","p_sequencer.m_smi<%=i%>_tx_seqr type missmatch");
  end
  <% } %>
  <% } %>
  //---------------------"<JS format fixer>
  if(!$value$plusargs("k_dmi_qos_th_val=%0d", dmi_qos_th_val)) begin
     dmi_qos_th_val = $urandom_range(1,15);
  end

  m_smi_tx_cmd_req_seq           = smi_seq::type_id::create("m_smi_tx_cmd_req_seq");
  m_smi_tx_dtw_req_seq           = smi_seq::type_id::create("m_smi_tx_dtw_req_seq");
  m_smi_tx_rb_req_seq            = smi_seq::type_id::create("m_smi_tx_rb_req_seq");
  m_smi_rx_dtr_req_seq           = smi_seq::type_id::create("m_smi_rx_dtr_req_seq");
  m_smi_rx_str_req_seq           = smi_seq::type_id::create("m_smi_rx_str_req_seq");
  m_smi_tx_rsp_seq               = smi_seq::type_id::create("m_smi_tx_rsp_seq");
  m_smi_rx_rsp_seq               = smi_seq::type_id::create("m_smi_rx_rsp_seq");

  home_dmi_unit_id  = <%=obj.DmiInfo[obj.Id].FUnitId%>;
   #20ns 
  `uvm_info("dmi_base_seq", $sformatf("wt_mrd_rd_with_unq_cln=%0d wt_mrd_rd_with_shr_cln=%0d wt_mrd_rd_with_inv=%0d wt_mrd_flush=%0d wt_dtw_no_dt=%0d wt_dtw_dt_ptl=%0d wt_dtw_dt_dty=%0d wt_dtw_dt_cln=%0d",
                                      wt_mrd_rd_with_unq_cln.get_value(), wt_mrd_rd_with_shr_cln, wt_mrd_rd_with_inv.get_value(), wt_mrd_flush.get_value(),
                                      wt_dtw_no_dt.get_value(),wt_dtw_dt_ptl.get_value(), wt_dtw_dt_dty.get_value(), wt_dtw_dt_cln.get_value()),UVM_DEBUG)
  `uvm_info("dmi_base_seq_back_to_back", $sformatf("k_back_to_back_types=%0d",
                                               k_back_to_back_types),UVM_DEBUG)
  `uvm_info("dmi_base_seq_back_to_back", $sformatf("k_back_to_back_chains=%0d",
                                               k_back_to_back_chains),UVM_DEBUG)
  `uvm_info("dmi_base_seq_back_to_back", $sformatf("use_last_dealloc=%0d",
                                               use_last_dealloc),UVM_DEBUG)
  `uvm_info("dmi_base_seq_back_to_back", $sformatf("use_adj_addr=%0d",
                                               use_adj_addr),UVM_DEBUG)
  `uvm_info("dmi_base_seq", $sformatf("tb_delay=%0d",tb_delay),UVM_DEBUG)
  `uvm_info("dmi_base_seq", $sformatf("sp_ways=%0d",sp_ways),UVM_DEBUG)

   #10ns //seq_delay

  /////////////////////////////////////////////////////////////////////////
  // Generate list of cacheAddresses, AIU txn IDs and SFI txn IDs
  /////////////////////////////////////////////////////////////////////////
  if(cache_warmup_flg || error_test_flg)begin
    genCacheAddrq();
  end
  if(conc_15195_flg) begin
    genConc15195Addrq();
  end
  if(use_evict_addr_flg) begin
    genEvictAddrq();
  end
  if(target_sp_addr_edges_flg) begin
    genSpAddrEdgesq();
  end
  //genSmimsgIds();
 
  `uvm_info("dmi_base_seq", $sformatf("Generating %0d AIU Ids ( this is really number of commands to send)",k_num_cmd),UVM_DEBUG)


 /////////////////////////////////////////////////////////////////////////
 //       Produce and send txns
 /////////////////////////////////////////////////////////////////////////
 fork //Arbitrate
   begin :send_cmd_req
    forever
      begin
        smi_seq_item  m_tmp_mst_req;          
        
        if(m_smi_tx_cmd_req_q.size() == 0)begin
          @e_smi_cmd_req_q;
        end
        else begin
         `uvm_info("txn_arbiter", "sending cmd_req item...",UVM_DEBUG)
         m_smi_tx_cmd_req_seq.m_seq_item = smi_seq_item::type_id::create("m_seq_item");
         m_smi_tx_cmd_req_seq.m_seq_item.do_copy(m_smi_tx_cmd_req_q[0]);
         `uvm_info("txn_arbiter", $sformatf("sending cmd_req item...%p",m_smi_tx_cmd_req_seq.m_seq_item),UVM_DEBUG)
         if(m_smi_tx_cmd_req_seq.m_seq_item.isCmdMsg())begin 
         `uvm_info("txn_arbiter", "sending cmd_req item...",UVM_DEBUG)
            m_smi_tx_cmd_req_seq.return_response(m_smi_seqr_tx_hash[dvcmd2rtlcmd["CMDREQ"]]);
          //  m_smi_cmd_rsp_q.push_back(m_tmp_mst_req); 
         `uvm_info("txn_arbiter", "sent cmd_req item...",UVM_DEBUG)
         end
         else if(m_smi_tx_cmd_req_seq.m_seq_item.isMrdMsg())begin 
         `uvm_info("txn_arbiter", "sending Mrd_req item...",UVM_DEBUG)
            m_smi_tx_cmd_req_seq.return_response(m_smi_seqr_tx_hash[dvcmd2rtlcmd["MRDREQ"]]);
          //  m_smi_cmd_rsp_q.push_back(m_tmp_mst_req); 
         `uvm_info("txn_arbiter", "sent Mrd_req item...",UVM_DEBUG)
          end
         else begin
          `uvm_error("txn_arbiter", $sformatf("unknown smi_msg_type :%0b",m_smi_tx_cmd_req_seq.m_seq_item.smi_msg_type));
         end
           
         if(m_smi_tx_cmd_req_q[0].smi_msg_type inside {CMD_WR_NC_PTL,CMD_WR_NC_FULL,CMD_RD_NC,CMD_RD_ATM,CMD_WR_ATM,CMD_SW_ATM,CMD_CMP_ATM,CMD_CLN_INV,CMD_CLN_VLD,CMD_CLN_SH_PER,CMD_MK_INV,CMD_PREF})begin
           m_tmp_mst_req = smi_seq_item::type_id::create("m_tmp_mst_req");
           m_tmp_mst_req.do_copy(m_smi_tx_cmd_req_q[0]);
           m_smi_str_req_q.push_back(m_tmp_mst_req); 
         end
         //pushing the req to wait for response
          m_smi_tx_cmd_req_q.delete(0);
          ->e_smi_tx_rsp_q;
        end
      end
   end :send_cmd_req
   begin: send_rb_req
     forever
       begin
         smi_seq_item  m_tmp_mst_rb_req;          
         if( m_smi_tx_rb_req_q.size() == 0)begin
           @e_smi_rb_req_q;
         end
         else begin
         `uvm_info("txn_arbiter", "sending rb_req item...",UVM_DEBUG);
           m_smi_tx_rb_req_seq.m_seq_item = smi_seq_item::type_id::create("m_seq_item");
           m_smi_tx_rb_req_seq.m_seq_item.do_copy(m_smi_tx_rb_req_q[0]);
           `uvm_info("txn_arbiter", $sformatf("Sending RbReq item MSG_ID:%0h RBID:%0h", m_smi_tx_rb_req_seq.m_seq_item.smi_msg_id,m_smi_tx_rb_req_seq.m_seq_item.smi_rbid),UVM_DEBUG);
           m_smi_tx_rb_req_seq.return_response(m_smi_seqr_tx_hash[dvcmd2rtlcmd["RBRREQ"]]);
           m_smi_tx_rb_req_q.delete(0);
         end
       end
   end :send_rb_req
   begin:wait_str_req
    forever
      begin
       smi_seq_item  m_tmp_str_req;
       m_tmp_str_req = smi_seq_item::type_id::create("m_tmp_str_req");
       m_smi_seqr_rx_hash[dvcmd2rtlcmd["STRREQ"]].m_rx_analysis_fifo.get(m_tmp_str_req); 
       if(m_tmp_str_req.isStrMsg)begin
         process_str_req(m_tmp_str_req);
         //directed testcase
         if(k_use_all_str_msg_id) begin 
           m_str_rsp_q.push_back(m_tmp_str_req);
           if((m_str_rsp_q.size() == (2**(WSTRREQMSGID))) || (m_str_rsp_q.size() == MAX_NCMSGID_IN_FLIGHT)) begin
               foreach(m_str_rsp_q[i]) begin
                   m_smi_rx_rsp_q.push_back(m_str_rsp_q[i]);
               end
               m_str_rsp_q = {};
               if(strrsp_bp_count==1) k_use_all_str_msg_id = 0;
               strrsp_bp_count--;
           end
         end
           //regular logic
         else begin
           m_smi_rx_rsp_q.push_back(m_tmp_str_req);
         end
         ->e_smi_rx_rsp_q;
       end
       else begin
         if(m_tmp_str_req.isSysReqMsg) begin
           m_smi_rx_rsp_q.push_back(m_tmp_str_req);
           ->e_smi_rx_rsp_q;
         end
       end
      end
   end
   begin: send_dtw_req
     forever
       begin
         if( m_smi_tx_dtw_req_q.size() == 0)begin
           @e_smi_dtw_req_q;
         end
         else begin
         `uvm_info("txn_arbiter", $sformatf("Sending dtw_req item on RBID:%0h", m_smi_tx_dtw_req_q[0].smi_rbid),UVM_DEBUG);
            m_smi_tx_dtw_req_seq.m_seq_item = smi_seq_item::type_id::create("m_seq_item");
            m_smi_tx_dtw_req_seq.m_seq_item.do_copy(m_smi_tx_dtw_req_q[0]); 
            m_smi_tx_dtw_req_seq.m_seq_item.smi_mpf1 = m_smi_tx_dtw_req_q[0].smi_mpf1; 
            m_smi_tx_dtw_req_seq.m_seq_item.smi_mpf2 = m_smi_tx_dtw_req_q[0].smi_mpf2; 
            m_smi_tx_dtw_req_seq.return_response(m_smi_seqr_tx_hash[dvcmd2rtlcmd["DTWREQ"]]);
            m_smi_tx_dtw_req_q.delete(0);
         end
       end
   end :send_dtw_req
   begin:process_tx_cmd_rsp
     forever
       begin
         smi_seq_item m_tmp_seq_item;
         `uvm_info("txn_arbiter", "waiting for cmd_rsp item...",UVM_DEBUG);
         m_smi_seqr_rx_hash[dvcmd2rtlcmd["CMDRSP"]].m_rx_analysis_fifo.get(m_tmp_seq_item);
         `uvm_info("txn_arbiter", "processing AIU  SMIMsgIDs for cmd_rsp...",UVM_DEBUG);
         process_AIUmsgIDs(m_tmp_seq_item);
       end
   end: process_tx_cmd_rsp
   begin:process_tx_dtw_rsp
     forever
       begin
         smi_seq_item m_tmp_seq_item;
         `uvm_info("txn_arbiter", "waiting for dtw_rsp item...",UVM_DEBUG);
         m_smi_seqr_rx_hash[dvcmd2rtlcmd["DTWRSP"]].m_rx_analysis_fifo.get(m_tmp_seq_item);
         `uvm_info("txn_arbiter", "processing AIU  SMIMsgIDs for dtw_rsp...",UVM_DEBUG);
         process_AIUmsgIDs(m_tmp_seq_item);
       end
   end: process_tx_dtw_rsp
   begin:process_tx_mrd_rb_rsp
     forever
       begin
         smi_seq_item m_tmp_seq_item;
         `uvm_info("txn_arbiter", "waiting cmd_rsp item...",UVM_DEBUG);
         m_smi_seqr_rx_hash[dvcmd2rtlcmd["MRDRSP"]].m_rx_analysis_fifo.get(m_tmp_seq_item); 
         if(m_tmp_seq_item.isRbUseMsg())begin
           `uvm_error("txn_arbiter", $sformatf("Received a RBUse for RBID:%0h. Protocol not supported from 3.6",m_tmp_seq_item.smi_rbid))
         end
         else if(m_tmp_seq_item.isRbRspMsg())begin
           `uvm_info("txn_arbiter",$sformatf("Received a RBRsp RBID:%0h", m_tmp_seq_item.smi_rbid),UVM_DEBUG)
           numRbRsp++;
           clean_SMIMsgIDs(m_tmp_seq_item);
           process_AIUmsgIDs(m_tmp_seq_item);
         end
         else begin
           `uvm_info("txn_arbiter", "cleaning  SMIMsgIDs for rsp...",UVM_DEBUG);
           clean_SMIMsgIDs(m_tmp_seq_item);
         end
          
       end
   end: process_tx_mrd_rb_rsp
   begin:process_dtr_req                 //process dtr_req and dtw_dbg_req
     forever 
       begin
         smi_seq_item m_tmp_seq_item;
         `uvm_info("txn_arbiter", " Starting dtr_req item...",UVM_DEBUG);
         /////////////////////////////////////////////////////////////////////
         m_smi_seqr_rx_hash[dvcmd2rtlcmd["DTRREQ"]].m_rx_analysis_fifo.get(m_tmp_seq_item); 
         `uvm_info("txn_arbiter", "got  dtr_req item...",UVM_DEBUG);
         `uvm_info("txn_arbiter",$sformatf("%p",m_tmp_seq_item), UVM_DEBUG);
         if(m_tmp_seq_item.isDtwDbgReqMsg()) m_smi_dtwdbg_q.push_back(m_tmp_seq_item);
         else if($test$plusargs("conc9307_test") && m_tmp_seq_item.isDtrMsg() && buffer_on) m_smi_rx_rsp_delayed_q.push_back(m_tmp_seq_item);
         else m_smi_rx_rsp_q.push_back(m_tmp_seq_item);
          
         /////////////////////////////////////////////////////////////////////
         ->e_smi_rx_rsp_q;

       end
   end:process_dtr_req
   begin: buffer_dtr_req
     forever 
         begin
             evt_send_dtr_rsp.wait_trigger();
             `uvm_info("txn_arbiter", "recieved evt_send_dtr_rsp trigger", UVM_DEBUG)
              m_smi_rx_rsp_q = m_smi_rx_rsp_delayed_q;
              m_smi_rx_rsp_delayed_q = {};
              num_trigger++;
              if(num_trigger == 2) begin
                 evt_assert_dtw_rsp_ready.trigger();
                 `uvm_info("txn_arbiter", "recieved evt_send_dtr_rsp trigger for the second time. turning off dtr req buffer", UVM_DEBUG)
                 buffer_on = 0;
              end
              ->e_smi_rx_rsp_q;
         end
   end: buffer_dtr_req
   begin:process_rx_rsp
     forever 
       begin
         smi_seq_item m_tmp_seq_item;
         smi_seq_item m_rsp_seq_item;
         int m_index;
         if( m_smi_rx_rsp_q.size() == 0 && m_smi_dtwdbg_q.size() == 0)begin
           @e_smi_rx_rsp_q;
         end
         else begin
             if(m_smi_rx_rsp_q.size() > 0 && m_smi_dtwdbg_q.size() > 0) begin
                 pick_q = $urandom;
                 if(pick_q) begin
                     m_tmp_seq_item  = m_smi_dtwdbg_q.pop_front();
                 end
                 else begin
                     m_index = $urandom_range(m_smi_rx_rsp_q.size()-1,0);
                     m_tmp_seq_item = m_smi_rx_rsp_q[m_index];
                 end
             end
             else if(m_smi_dtwdbg_q.size()>0) begin
                 m_tmp_seq_item  = m_smi_dtwdbg_q.pop_front();
             end
             else begin
                 m_index = $urandom_range(m_smi_rx_rsp_q.size()-1,0);
                 m_tmp_seq_item = m_smi_rx_rsp_q[m_index];
             end
          m_smi_rx_rsp_seq.m_seq_item = smi_seq_item::type_id::create("m_seq_item");
          if (($test$plusargs("wrong_targ_id_str_rsp") && m_tmp_seq_item.isStrMsg()) || ($test$plusargs("wrong_targ_id_dtr_rsp") && m_tmp_seq_item.isDtrMsg()) ||($test$plusargs("wrong_targ_id_on_dtwdbg_rsp") && m_tmp_seq_item.isDtwDbgReqMsg())) begin
            m_smi_rx_rsp_seq.m_seq_item.smi_targ_ncore_unit_id = m_tmp_seq_item.smi_src_ncore_unit_id ^ {WSMINCOREUNITID{1'h1}}; 
          end else begin
            m_smi_rx_rsp_seq.m_seq_item.smi_targ_ncore_unit_id = m_tmp_seq_item.smi_src_ncore_unit_id;
          end
          m_smi_rx_rsp_seq.m_seq_item.smi_src_ncore_unit_id  = m_tmp_seq_item.smi_targ_ncore_unit_id;
          if(m_tmp_seq_item.isStrMsg())begin
             m_smi_rx_rsp_seq.m_seq_item.smi_msg_type =  STR_RSP;
          end
          else if(m_tmp_seq_item.isDtrMsg()) begin
             m_smi_rx_rsp_seq.m_seq_item.smi_msg_type =  DTR_RSP;
          end
          else if(m_tmp_seq_item.isDtwDbgReqMsg()) begin
             m_smi_rx_rsp_seq.m_seq_item.smi_msg_type =  DTW_DBG_RSP;
          end
          else if(m_tmp_seq_item.isSysReqMsg()) begin
            m_smi_rx_rsp_seq.m_seq_item.smi_msg_type = SYS_RSP;
          end

         m_smi_rx_rsp_seq.m_seq_item.smi_cmstatus        = 0; // This needs to be driven to non-zero for error testing
         m_smi_rx_rsp_seq.m_seq_item.smi_dp_present      = 0; // This needs to be driven to non-zero for ndp
         m_smi_rx_rsp_seq.m_seq_item.smi_msg_tier        = 0;
         m_smi_rx_rsp_seq.m_seq_item.smi_steer           = 0;
         m_smi_rx_rsp_seq.m_seq_item.smi_msg_pri         = 0;
         m_smi_rx_rsp_seq.m_seq_item.smi_cmstatus        = 0;
         m_smi_rx_rsp_seq.m_seq_item.smi_rl              = 0;
         m_smi_rx_rsp_seq.m_seq_item.smi_tm              = m_tmp_seq_item.smi_tm;
         m_smi_rx_rsp_seq.m_seq_item.smi_rmsg_id         = m_tmp_seq_item.smi_msg_id;
         m_smi_rx_rsp_seq.m_seq_item.smi_msg_id          = $urandom;
         /////////////////////////////////////////////////////////////////////
         if(m_tmp_seq_item.isStrMsg())begin
         `uvm_info("txn_arbiter", "Starting str_rsp item...",UVM_DEBUG);
           process_AIUmsgIDs(m_tmp_seq_item);
           m_smi_rx_rsp_seq.return_response(m_smi_seqr_tx_hash[dvcmd2rtlcmd["STRRSP"]]);
         end
         else if(m_tmp_seq_item.isDtrMsg()) begin
         `uvm_info("txn_arbiter", "Starting dtr_rsp item...",UVM_DEBUG);
           #1ns; //Hardcoded delay due to lack of access to clock I/F. Dtr response can never be in the same clock as dtr req with dp last
           process_AIUmsgIDs(m_tmp_seq_item);
           m_smi_rx_rsp_seq.return_response(m_smi_seqr_tx_hash[dvcmd2rtlcmd["DTRRSP"]]);
         end
         else if(m_tmp_seq_item.isRbUseMsg()) begin
         `uvm_error("txn_arbiter","Shouldn't be generating a RBUse Rsp");
         end
         else if(m_tmp_seq_item.isDtwDbgReqMsg()) begin
         `uvm_info("txn_arbiter", "Starting Dtw Dbg Rsp item....",UVM_DEBUG);
         m_smi_rx_rsp_seq.return_response(m_smi_seqr_tx_hash[dvcmd2rtlcmd["DTWDBGRSP"]]);    
         end
         else if(m_tmp_seq_item.isSysReqMsg()) begin
         `uvm_info("txn_arbiter", "Starting Sys Rsp item....",UVM_DEBUG);
           if(m_smi_seqr_tx_hash.exists("sys_rsp_rx_")) begin
             m_smi_rx_rsp_seq.return_response(m_smi_seqr_tx_hash["sys_rsp_rx_"]);    
           end
           else
             `uvm_error("txn_arbiter","Attempting to send a SysRsp on a configuration with no SysReq port")
         end
         if(!m_tmp_seq_item.isDtwDbgReqMsg()) m_smi_rx_rsp_q.delete(m_index);
        end

       end
   end:process_rx_rsp
 join_none 
endtask : body

function dmi_base_seq::initialize();
  if(!uvm_config_db#(dmi_env_config)::get(.cntxt( null ),
                                           .inst_name( get_full_name() ),
                                           .field_name( "dmi_env_config" ),
                                           .value( m_cfg ))) begin
    `uvm_error("dmi_base_seq", "dmi_env_config handle not found")
  end
endfunction
////////////////////////////////////////////////////////////////////////////////

`endif // DMI_BASE_SEQ

