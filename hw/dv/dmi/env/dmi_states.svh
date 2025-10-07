////////////////////////////////////////////////////////////////////////////////
//
// Type Definitions
//
////////////////////////////////////////////////////////////////////////////////
//import ConcertoPkg::*;
<%
 var wdata = obj.DmiInfo[obj.Id].interfaces.axiInt.params.wData/8;
 var smiQosEn = 0;
 var NSMIIFTX = obj.DmiInfo[obj.Id].nSmiRx;
 var NSMIIFRX = obj.DmiInfo[obj.Id].nSmiTx;
  for (var i = 0; i < NSMIIFRX; i++) {
    if(obj.DmiInfo[obj.Id].interfaces.smiTxInt[i].params.wSmiMsgQos >0){ smiQosEn = 1;}
  }
  for (var i = 0; i < NSMIIFTX; i++) {
    if(obj.DmiInfo[obj.Id].interfaces.smiRxInt[i].params.wSmiMsgQos >0){ smiQosEn = 1;}
  }
  var addressIdMap = function() {
    var arr = [];
    obj.DmiInfo[obj.Id].addressIdMap.addressBits.forEach(function(addressBits) {
        arr.push(addressBits);
    });
    return(arr);
  };
%>
<%if(obj.DutInfo.useCmc) { %>
import <%=obj.BlockId%>_ccp_agent_pkg::*;
<% } %>
import <%=obj.BlockId%>_smi_agent_pkg::*;
typedef struct {
   smi_addr_t         cache_addr;
   smi_security_t     smi_ns;
              } RttfifoEntry_t;

<%if(obj.DutInfo.useCmc) { %>

typedef struct {
               int              indx;
               ccp_ctrlop_waybusy_vec_logic_t wayn;
               } dmi_busy_index_way_t; 

typedef struct {
                   bit                       fillctrl;
                   bit                       filldata;
                   int                       index;
                   ccp_ctrlfill_security_t   secu;
                   ccp_ctrlfilldata_Id_t     Id;
                   ccp_ctrlfill_wayn_logic_t wayn;
                   ccp_ctrlfilldata_addr_t   addr;
                   } dmi_fill_addr_inflight_t; 
class ccpSPLine extends uvm_object;
    parameter NUM_BEATS_IN_CACHELINE = ((SYS_nSysCacheline*8)/WCCPDATA);
    ccp_ctrlwr_data_t  data[NUM_BEATS_IN_CACHELINE];
    ccp_data_poision_t poison[NUM_BEATS_IN_CACHELINE];

    `uvm_object_param_utils_begin  ( ccpSPLine )
        `uvm_field_sarray_int ( data, UVM_DEFAULT)
        `uvm_field_sarray_int ( poison, UVM_DEFAULT)
    `uvm_object_utils_end

    // Constructor
    function new(string name = "ccpSPLine");
      super.new(name);
    endfunction

    function string print();
      string s;
      s = $sformatf("CCP SP | Data:%0p Poison:%0p", data, poison);
      return s;
    endfunction

endclass: ccpSPLine 
<% } %>
typedef enum {
    axi_ar,
    axi_r,
    axi_aw,
    axi_w,
    axi_b
} eAxiMsgClass ;


//get which msg class is a rsp to this
// mapping is complete within dii only.
const eConcMsgClass rsp_to[eConcMsgClass] = {
    eConcMsgCmdReq  :   eConcMsgNcCmdRsp, 
    eConcMsgStrReq  :   eConcMsgStrRsp ,
    eConcMsgDtrReq  :   eConcMsgDtrRsp ,
    eConcMsgDtwReq  :   eConcMsgDtwRsp ,
    default         :   eConcMsgBAD  //rsp never outstanding
};

localparam LINE_INDEX_L     = <%=Math.log2(obj.DmiInfo[obj.Id].wData/8)%>;
localparam LINE_INDEX_H     = <%=Math.log2(Math.pow(2,obj.DutInfo.wCacheLineOffset)*8/obj.DmiInfo[obj.Id].wData)+ Math.log2(obj.DmiInfo[obj.Id].wData/8) - 1%>;
 
typedef enum bit [2:0] {MNTOP_FLUSH_BY_INDEX, MNTOP_FLUSH_BY_ADDR, MNTOP_FLUSH_BY_ADDR_RANGE,MNTOP_FLUSH_BY_INDEX_RANGE,MNTOP_DEBUG_READ, MNTOP_DEBUG_WRITE} mntop_cmd_t;

<% if (obj.DutInfo.useCmc) { %>
   localparam N_CCP_SETS   = <%=obj.DmiInfo[obj.Id].ccpParams.nSets%>;
   localparam N_CCP_WAYS   = <%=obj.DmiInfo[obj.Id].ccpParams.nWays%>;
   localparam N_DATA_BANKS = <%=obj.DmiInfo[obj.Id].ccpParams.nDataBanks%>;
<% } %>

class dmi_scb_txn extends uvm_object;
  
   dmi_env_config            m_cfg;
   int exmon_size =  <%=obj.DmiInfo[obj.Id].nExclusiveEntries%>;
   smi_seq_item              cmd_req_pkt;
   smi_seq_item              cmd_rsp_pkt;
   smi_seq_item              mrd_req_pkt;
   smi_seq_item              mrd_rsp_pkt;
   smi_seq_item              dtr_req_pkt;
   smi_seq_item              dtr_req_pkt_exp;
   smi_seq_item              dtr_rsp_pkt;
   smi_seq_item              str_req_pkt;
   smi_seq_item              str_rsp_pkt;
   smi_seq_item              dtw_req_pkt;
   smi_seq_item              dtw_rsp_pkt;
   smi_seq_item              dtw2nd_req_pkt;
   smi_seq_item              dtw2nd_rsp_pkt;
   smi_seq_item              rb_req_pkt;
   smi_seq_item              rb_rsp_pkt;
   smi_seq_item              rbrl_req_pkt;
   smi_seq_item              rbrl_rsp_pkt;
   smi_seq_item              rbu_req_pkt;
   smi_seq_item              rbu_rsp_pkt;
   axi4_read_addr_pkt_t      axi_read_addr_pkt;
   axi4_read_data_pkt_t      axi_read_data_pkt;
   axi4_read_data_pkt_t      axi_read_data_pkt_exp;
   axi4_write_addr_pkt_t     axi_write_addr_pkt;
   axi4_write_data_pkt_t     axi_write_data_pkt;
   axi4_write_resp_pkt_t     axi_write_resp_pkt;
   axi4_write_addr_pkt_t     axi2nd_write_addr_pkt;
   axi4_write_data_pkt_t     axi2nd_write_data_pkt;
   axi4_write_resp_pkt_t     axi2nd_write_resp_pkt;
   <%=obj.BlockId%>_rtl_cmd_rsp_pkt cmd_rsp_pkt_rtl;
   <%=obj.BlockId%>_rtl_cmd_rsp_pkt mrd_req_pkt_rtl;
   <%=obj.BlockId%>_read_probe_txn read_arb_pkt;
   <%=obj.BlockId%>_write_probe_txn write_arb_pkt;

   smi_addr_t                cache_addr;
   int                       cache_index;
   smi_security_t            security;
   bit                       privileged;
   smi_type_t                smi_msg_type;
   smi_type_t                cmd_msg_type;
   smi_type_t                mrd_msg_type;
   smi_type_t                dtw_msg_type;
   smi_msg_id_logic_t        smi_msg_id;
   smi_msg_id_logic_t        cmd_msg_id;
   smi_msg_id_logic_t        dtr_msg_id;
   smi_msg_id_logic_t        dtr_rmsg_id_recd;
   smi_msg_id_logic_t        dtr_rmsg_id_expd;
   smi_msg_id_logic_t        str_msg_id;
   smi_msg_id_logic_t        str_rmsg_id;
   smi_ncore_unit_id_bit_t   dtw_src_ncore_unit_id;
   smi_ncore_unit_id_bit_t   Rb_src_ncore_unit_id;
   smi_ncore_unit_id_bit_t   dtw2nd_src_ncore_unit_id;
   smi_ncore_unit_id_bit_t   dtw_targ_ncore_unit_id;
   smi_ncore_unit_id_bit_t   dtr_targ_unit_id;
   smi_ncore_unit_id_bit_t   cmd_src_unit_id;
   smi_msg_id_logic_t        rb_msg_id;
   smi_msg_id_logic_t        rbu_msg_id;
   smi_msg_id_logic_t        rbrl_msg_id;
   smi_msg_id_logic_t        dtw_msg_id;
   smi_msg_id_logic_t        dtw2nd_msg_id;
   smi_rbid_t                smi_rbid;
   smi_vz_t                  smi_vz;
   smi_ca_t                  smi_ca;
   smi_ac_t                  smi_ac;
   smi_qos_t                 smi_qos;
   smi_tm_t                  exp_smi_tm;
   smi_msg_pri_bit_t         smi_msg_pri;
   smi_ndp_aux_bit_t         smi_ndp_aux_aw;
   smi_ndp_aux_bit_t         smi_ndp_aux_ar;
   smi_ndp_aux_bit_t         smi_ndp_aux_w;
   bit [511:0]               dtr_data_exp,dtr_data_recd;
   bit [7:0]                 dtr_data_dbad_exp,dtr_data_dbad_recd;
   bit [23:0]                dtr_data_dwid_exp,dtr_data_dwid_recd;
   smi_cmstatus_t            dtr_smi_cmstatus[];
   int                       dwid_cnt;
   smi_seq_item smi_recd [eConcMsgClass] ;
   int smi_expd [eConcMsgClass];
   bit axi_expd [eAxiMsgClass] ;
   time axi_recd [eAxiMsgClass] ;  
   exmon_status_t m_exmon_status = IDLE;

<% if (obj.DutInfo.useCmc) { %>
   bit [N_CCP_WAYS-1:0]      rsvd_ways;
   // Scratchpad variables
   smi_addr_t                lower_sp_addr, upper_sp_addr, sp_addr, cache_addr_i;
   bit                       sp_ns;              
   int                       sp_data_bank;
   int                       sp_beat_num;
   int                       sp_index;
   int                       sp_way;
   bit                       sp_txn;
   bit                       sp_enabled;
   bit                       sp_atomic_wr_reqd;
   bit                       sp_atomic_wr_pending;
   ccpSPLine                 sp_read_data_pkt;
   bit                       sp_seen_ctrl_chnl;
   bit                       sp_seen_write_chnl;
   bit                       sp_seen_output_chnl;
   bit                       sp_write_through;
   ccp_sp_ctrl_pkt_t         m_sp_ctrl_pkt;
   // This 2nd SP control packet is for atomic write reqs
   ccp_sp_ctrl_pkt_t         m_sp_ctrl_pkt2;
   ccp_sp_wr_pkt_t           m_sp_wr_data_pkt;
   ccp_sp_wr_pkt_t           sp_wr_data_expd;
   ccp_sp_output_pkt_t       m_sp_rd_data_pkt;
   smi_dp_dbad_t             error_expected[];
   time                      t_sp_seen_ctrl_chnl;
   time                      t_sp_seen_wr_chnl;
   time                      t_sp_seen_rd_chnl;

   ccp_rd_rsp_pkt_t          cache_rd_data_pkt;
   ccp_fillctrl_pkt_t        cache_fill_ctrl_pkt;
   ccp_fillctrl_pkt_t        cache_fill_ctrl_pkt_exp;
   ccp_filldata_pkt_t        cache_fill_data_pkt;
   ccp_filldata_pkt_t        cache_fill_data_pkt_exp;
   ccp_ctrl_pkt_t            cache_ctrl_pkt;
   ccp_ctrl_pkt_t            cache_ctrl2nd_pkt;
   ccp_wr_data_pkt_t         cache_wr_data_pkt;
   ccp_wr_data_pkt_t         cache_wr_data_pkt_exp;
   ccp_evict_pkt_t           cache_evict_data_pkt;
   ccp_evict_pkt_t           cache_evict_data_pkt_exp;
   ccp_rd_rsp_pkt_t          cache_rd_data_pkt_exp;
   int                       fillwayn;
   int                       beatn;
   int                       beatnExp;
   bit [WCCPBEAT-1:0]        data_beat;
<% } %>

   bit                       CMD_req_recd;
   bit                       MRD_req_recd;
   bit                       MRD_req_recd_rtl;
   bit                       HNT_req_recd;
   bit                       MRD_rsp_expd;
   bit                       MRD_rsp_recd;
   bit                       HNT_rsp_expd;
   bit                       HNT_rsp_recd;
   bit                       CMD_rsp_expd;
   bit                       CMD_rsp_recd;
   bit                       CMD_rsp_recd_rtl;
   bit                       DTW_req_expd;
   bit                       DTW_req_recd;
   bit                       DTW_rsp_expd;
   bit                       DTW_rsp_recd;
   bit                       DTW2nd_req_expd;
   bit                       DTW2nd_req_recd;
   bit                       DTW2nd_rsp_expd;
   bit                       DTW2nd_rsp_recd;
   bit                       DTR_req_expd;
   bit                       DTR_req_recd;
   bit                       DTR_rsp_expd;
   bit                       DTR_rsp_recd;
   bit                       DTWrsp_DTR_rsp_expd;
   bit                       DTWrsp_DTR_rsp_recd;
   bit                       STR_req_expd;
   bit                       STR_req_recd;
   bit                       STR_rsp_expd;
   bit                       STR_rsp_recd;
   bit                       RB_req_expd;
   bit                       RB_req_recd;
   bit                       RB_rsp_expd;
   bit                       RB_rsp_recd;
   bit                       RBRL_req_recd;
   bit                       RBRL_rsp_expd;
   bit                       RBRL_rsp_recd;
   bit                       RBU_req_expd;
   bit                       RBU_req_recd;
   bit                       RBU_rsp_expd;
   bit                       RBU_rsp_recd;
   bit                       DTR_req_recd_wtt;     // for functional coverage purpose
   bit                       DTR_rsp_recd_wtt;     // for functional coverage purpose
   bit                       DTW_req_recd_rtt;         
   bit                       DTW_rsp_recd_rtt;
   bit                       RB_req_recd_rtt;
   bit                       RB_rsp_recd_rtt;
   bit                       RBU_req_recd_rtt;
   bit                       RBU_rsp_recd_rtt;

   bit                       ATM_processed;

   bit                       AXI_read_addr_expd;
   bit                       AXI_read_addr_recd;
   bit                       AXI_read_data_expd;
   bit                       AXI_read_data_recd;

   bit                       AXI_write_addr_expd;
   bit                       AXI_write_addr_recd;
   bit                       AXI_write_data_expd;
   bit                       AXI_write_data_recd;
   bit                       AXI_write_resp_expd;
   bit                       AXI_write_resp_recd;

   bit                       AXI_write_2ndaddr_expd;
   bit                       AXI_write_2ndaddr_recd;
   bit                       AXI_write_2nddata_expd;
   bit                       AXI_write_2nddata_recd;
   bit                       AXI_write_2ndresp_expd;
   bit                       AXI_write_2ndresp_recd;

   bit                          AXI_read_addr_recd_wtt;             // for functional coverage purpose
   bit                          AXI_read_data_recd_wtt;             // for functional coverage purpose
   bit                          AXI_write_addr_recd_rtt;            // for functional coverage purpose
   bit                          AXI_write_data_recd_rtt;            // for functional coverage purpose
   bit                          AXI_write_resp_recd_rtt;            // for functional coverage purpose

   // Bit to inform if AXI4 txn required?
   bit                       isRttCreated;
   bit                       isStrExpd;
   bit                       isStrRecd;
   bit                       isCacheHit;
   bit                       isCacheMiss;
   bit                       lookupExpd;
   bit                       lookupSeen;
   bit                       lookupSeen2nd;
   bit                       rdrspDataExpd;
   bit                       rdrspDataRecd;
   bit                       evictDataExpd;
   bit                       evictDataRecd;
   bit                       cacheRspExpd;
   bit                       cacheRspRecd;
   bit                       cacheWrDataExpd;
   bit                       cacheWrDataRecd;
   bit                       bypassExpd;              //
   bit                       bypassSeen;
   bit                       isEvict;
   bit                       isRdWtt;
   bit                       isWrThBypass;
   bit                       islast;
   bit                       nackuce;
   bit                       uncorr_err;
   bit                       smi_dp_last;
  
   bit                       seenAtReadArb;
   bit                       seenAtWriteArb;
   bit                       fillExpd;
   bit                       fillSeen;
   bit                       fillInvExpd;
   bit                       fillInvSeen;
   bit                       fillDataExpd;
   bit                       fillDataSeen;
   bit                       rttNoAlloc;
   bit                       rdOutstandingFlag; // used to see if this entry waits on another read
   bit                       wrOutstandingFlag;
   int                       wrOutstandingcnt;
   bit                       wrOutstanding;
   bit                       isCmdPref;
   bit                       isMrd;
   bit                       isCmd;
   bit                       isDtw;
   bit                       isNcRd;
   bit                       isNcWr;
   bit                       isCoh;
   bit                       isAtmStore;
   bit                       isAtomic;
   bit                       isAtomicCmp_match;     // set if atomic cmp value matches and swapping is performed
   bit                       isDtwMrgMrd;
   bit                       DtrRdy;
   bit                       isStale;
   bit                       isdropped;
   bit                       isReplay;
   bit                       causeEvict;
   bit                       isMerged;
   bit                       isMW;
   bit                       isAtomicProcessed;
   smi_size_t                smi_size;
   smi_mpf1_burst_type_t     smi_burst;
   smi_intfsize_t            smi_intfsize;
   // Check bits?
   //Timeout ?              
   time                      t_creation;
   time                      t_latest_update;
   time                      t_at_read_arbiter, t_at_write_arbiter;
   time                      t_mrdrsp;
   time                      t_cmdrsp;
   time                      t_lookup;
   time                      t_lookup2nd;
   time                      t_cachefillctrl;
   time                      t_cachefilldata;
   time                      t_cacheWrData;
   time                      t_cacheWrData2nd;
   time                      t_cacheRdrsp;
   time                      t_evictData;
   time                      t_evictData2nd;
   time                      t_ar;
   time                      t_r;
   time                      t_fwd;
   time                      t_dtrreq;
   time                      t_cmdreq;
   time                      t_mrdreq;
   time                      t_dtrrsp;
   time                      t_strreq;
   time                      t_strrsp;
   time                      t_dtwreq;
   time                      t_dtwrsp;
   time                      t_rbreq;
   time                      t_rbrsp;
   time                      t_rbureq;
   time                      t_rbursp;
   time                      t_rbrsrsp;  //rb reserve response
   time                      t_rbrlreq;
   time                      t_rbrlrsp;
   time                      t_rbrreq;
   time                      t_rbrrsp;
   time                      t_stale;
   time                      t_evict;
   time                      t_aw;
   time                      t_w;
   time                      t_w1;
   time                      t_b;
   time                      t_aw2nd;
   time                      t_w2nd;
   time                      t_b2nd;


   int                       i;
   int                       num_bytes;
   int                       byte_idx;
   int                       lookupcnt;
   int                       cachewrcnt;

   axi_axsize_enum_t      expd_arsize; 
   axi_axburst_enum_t     expd_arburst = AXIWRAP;
   axi_axsize_enum_t      expd_awsize;
   axi_axburst_enum_t     expd_awburst = AXIINCR;

   //Expected AxID -- CONC-13672
   int addressIdMap[] = '{<%=addressIdMap()%>};
   int wCacheLineOffset =  <%=obj.DmiInfo[obj.Id].wCacheLineOffset%>;

   bit [WSMIDPBE-1:0] be_val = (1<<(WSMIDPBE))-1;

   bit [7:0] expd_arlen = ((SYS_nSysCacheline / (<%=obj.DutInfo.wData%>/8)) - 1);
   bit [7:0] cacheline_awlen = ((SYS_nSysCacheline / (<%=obj.DutInfo.wData%>/8)) - 1);
   bit [7:0] expd_dtr_beats = (SYS_nSysCacheline /(<%=obj.DutInfo.wData%>/8));

   logic [7:0]      expd_awlen = 0;
   real             interim_expd_awlen;
   bit [WSMIMSGQOS:0] exp_eviction_qos;

   // For maint ops
   bit         isMntOp;
   int         mntop_index;
   int         mntop_way;
   int         mntop_word;
   smi_addr_t  mntop_addr; 
   int         mntop_Dataword;
   smi_addr_t  m_llc_to_mem_addr;
   bit         mntop_security;
   bit         mntop_ArrayId;// 0: TagArray, 1: DataArray
   mntop_cmd_t m_mntop_cmd_type;
   string parent;
   static int unique_id = 0;
   int unsigned txn_id;


   function new(string name = "dmi_scb_txn");
                      parent = name;
                      RB_req_expd    =0;
                      RB_req_recd    =0;
                      RB_rsp_expd    =0;
                      RB_rsp_recd    =0;
                      RBRL_rsp_expd  =0;
                      RBRL_rsp_recd  =0;
                      RBU_req_expd   =0;
                      RBU_req_recd   =0;
                      RBU_rsp_expd   =0;
                      RBU_rsp_recd   =0;
                      smi_qos        =0;
                      smi_ndp_aux_aw =0;
                      smi_ndp_aux_ar =0;
                      smi_ndp_aux_w  =0;
                      seenAtReadArb  =0;
                      seenAtWriteArb =0;
                      this.dtw_req_pkt = new();
                      $cast(expd_arsize  , $clog2(<%=obj.DutInfo.wData%>/8));
                      $cast(expd_awsize  , $clog2(<%=obj.DutInfo.wData%>/8));
      uvm_config_db#(int)::get(null, "uvm_test_top", "eviction_qos", exp_eviction_qos);
      unique_id++;
      txn_id = unique_id;
   endfunction : new


    function void print_entry(bit isPendingTxn = 0);
        string header = "";
        if(isPendingTxn)begin
          header = "PENDING TXN";
        end
        `uvm_info("<%=obj.BlockId%>:DMI_SCOREBOARD", $sformatf("------------------------------------UID[%0d]--------------------------------------------------------------",txn_id),UVM_MEDIUM)
        if(this.isCmdPref) begin
          `uvm_info("<%=obj.BlockId%>:DMI_SCOREBOARD", $sformatf("%0t:t_creation:%0t:smi_msg_id:0x%0x,addr:0x%0x,sec:0x%0x:\ttype:0x%0x msg_attr_ac:%0b,  CmdRsp:1|%0b,CmdRspRtl:1|%0b  ar:%0b|%0b,r:%0b|%0b  seenAtReadArb :%0b seenAtWriteArb :%0b",$time, this.t_creation,this.smi_msg_id,this.cache_addr, this.security,this.smi_msg_type,this.smi_ac,this.CMD_rsp_recd, this.CMD_rsp_recd_rtl, this.AXI_read_addr_expd, this.AXI_read_addr_recd, this.AXI_read_data_expd, this.AXI_read_data_recd, this.seenAtReadArb, this.seenAtWriteArb), UVM_MEDIUM)
        <% if(obj.DutInfo.useCmc) { %>
          `uvm_info("<%=obj.BlockId%>:DMI_SCOREBOARD", $sformatf("%0t:t_lookup:%0t lookup:%0b|%0b,cmcrdrsp:%0b:%0b isfillExpd:%0b|%0b isfilldataExpd :%0b|%0b isStale:%0b isdropped :%0b isCacheHit :%0b nackuce:%0b rttNoAllocated:%0b fillwayn :%0d cache_index :%0h ",$time, this.t_lookup,this.lookupExpd, this.lookupSeen, this.cacheRspExpd, this.cacheRspRecd,this.fillExpd,this.fillSeen,this.fillDataExpd,this.fillDataSeen,this.isStale,this.isdropped,this.isCacheHit,this.nackuce,this.rttNoAlloc,this.fillwayn,this.cache_index), UVM_MEDIUM)
          `uvm_info("<%=obj.BlockId%>:DMI_SCOREBOARD", $sformatf("%0t:sp_txn:%0b, sp_seen_ctrl_chnl %0b, sp_seen_write_chnl %0b, sp_seen_output_chnl %0b, t_sp_seen_ctrl_chnl:%0t t_sp_seen_wr_chnl:%0t, t_sp_seen_rd_chnl:%0t, sp_index: %0h, sp_way: %0h, sp_beat_num: %0d, sp_data_bank: %0d, sp_addr: %0h", $time, this.sp_txn, this.sp_seen_ctrl_chnl, this.sp_seen_write_chnl, this.sp_seen_output_chnl, this.t_sp_seen_ctrl_chnl, this.t_sp_seen_wr_chnl, this.t_sp_seen_rd_chnl, this.sp_index, this.sp_way, this.sp_beat_num, this.sp_data_bank, this.sp_addr), UVM_MEDIUM)
        <% } %>
        end
        else if(this.isMrd) begin
          `uvm_info("<%=obj.BlockId%>:DMI_SCOREBOARD", $sformatf("%0t:t_creation:%0t:[aiuId:0x%0x,aiu_msg_id:0x%0x],smi_msg_id:0x%0x,dtr_msg_id:%0x dtr_rmsg_id_recd:%0x addr:0x%0x,sec:0x%0x:\ttype:0x%0x isDtwMrgMrd :%0b,msg_attr_ac:%0b, msg_attr_vz:%0b, smi_size :%0d intfSize :%0x MrdReqRtl:1|%0b mrdRsp:%0b|%0b,ar:%0b|%0b,r:%0b|%0b,dtrReq:%0b|%0b,dtrRsp:%0b|%0b, wrOutstandingFlag :%0b wrCnt:%0d isCacheHit :%0b seenAtReadArb :%0b seenAtWriteArb :%0b",$time, this.t_creation, this.dtr_targ_unit_id, this.dtr_rmsg_id_expd,this.smi_msg_id,this.dtr_msg_id,this.dtr_rmsg_id_recd,this.mrd_req_pkt.smi_addr, this.mrd_req_pkt.smi_ns,this.mrd_req_pkt.smi_msg_type,this.isDtwMrgMrd,this.smi_ac,this.smi_vz,this.smi_size,this.smi_intfsize,this.MRD_req_recd_rtl,this.MRD_rsp_expd, this.MRD_rsp_recd, this.AXI_read_addr_expd, this.AXI_read_addr_recd, this.AXI_read_data_expd, this.AXI_read_data_recd, DTR_req_expd, DTR_req_recd, DTR_rsp_expd,DTR_rsp_recd,wrOutstandingFlag,wrOutstandingcnt,this.isCacheHit, this.seenAtReadArb, this.seenAtWriteArb), UVM_MEDIUM)
        <% if(obj.DutInfo.useCmc) { %>
          `uvm_info("<%=obj.BlockId%>:DMI_SCOREBOARD", $sformatf("%0t:t_lookup:%0t lookup:%0b|%0b,cmcrdrsp:%0b:%0b isfillExpd:%0b|%0b isfilldataExpd :%0b|%0b isCacheHit :%0b nackuce:%0b rttNoAllocated:%0b fillwayn :%0d cache_index :%0h ",$time, this.t_lookup,this.lookupExpd, this.lookupSeen, this.cacheRspExpd, this.cacheRspRecd,this.fillExpd,this.fillSeen,this.fillDataExpd,this.fillDataSeen,this.isCacheHit,this.nackuce,this.rttNoAlloc,this.fillwayn,this.cache_index), UVM_MEDIUM)
          `uvm_info("<%=obj.BlockId%>:DMI_SCOREBOARD", $sformatf("%0t:sp_txn:%0b, sp_seen_ctrl_chnl %0b, sp_seen_write_chnl %0b, sp_seen_output_chnl %0b, t_sp_seen_ctrl_chnl:%0t t_sp_seen_wr_chnl:%0t, t_sp_seen_rd_chnl:%0t, sp_index: %0h, sp_way: %0h, sp_beat_num: %0d, sp_data_bank: %0d, sp_addr: %0h", $time, this.sp_txn, this.sp_seen_ctrl_chnl, this.sp_seen_write_chnl, this.sp_seen_output_chnl, this.t_sp_seen_ctrl_chnl, this.t_sp_seen_wr_chnl, this.t_sp_seen_rd_chnl, this.sp_index, this.sp_way, this.sp_beat_num, this.sp_data_bank, this.sp_addr), UVM_MEDIUM)
        <% } %>
        end
        else if(this.isDtwMrgMrd & !this.DTWrsp_DTR_rsp_expd & this.RB_req_recd)begin
          `uvm_info("<%=obj.BlockId%>:DMI_SCOREBOARD", $sformatf("%0t:t_creation:%0t:[aiuId:0x%0x,aiu_msg_id:0x%0x],smi_msg_id:0x%0x,dtr_msg_id:%0x dtr_rmsg_id_recd:%0x addr:0x%0x,sec:0x%0x:\ttype:0x%0x isDtwMrgMrd :%0b,msg_attr_ac:%0b, msg_attr_vz:%0b, smi_size :%0d intfSize :%0x mrdRsp:%0b|%0b,ar:%0b|%0b,r:%0b|%0b,dtrReq:%0b|%0b,dtrRsp:%0b|%0b, wrOutstandingFlag :%0b wrCnt:%0d isCacheHit :%0b seenAtReadArb :%0b seenAtWriteArb :%0b",$time, this.t_creation, this.dtr_targ_unit_id, this.dtr_rmsg_id_expd,this.smi_msg_id,this.dtr_msg_id,this.dtr_rmsg_id_recd,this.rb_req_pkt.smi_addr, this.rb_req_pkt.smi_ns,this.dtw_req_pkt.smi_msg_type,this.isDtwMrgMrd,this.smi_ac,this.smi_vz,this.smi_size,this.smi_intfsize,this.MRD_rsp_expd, this.MRD_rsp_recd, this.AXI_read_addr_expd, this.AXI_read_addr_recd, this.AXI_read_data_expd, this.AXI_read_data_recd, DTR_req_expd, DTR_req_recd, DTR_rsp_expd,DTR_rsp_recd,wrOutstandingFlag,wrOutstandingcnt,this.isCacheHit, this.seenAtReadArb, this.seenAtWriteArb), UVM_MEDIUM)
        <% if(obj.DutInfo.useCmc) { %>
          `uvm_info("<%=obj.BlockId%>:DMI_SCOREBOARD", $sformatf("%0t:t_lookup:%0t lookup:%0b|%0b,cmcrdrsp:%0b:%0b isfillExpd:%0b|%0b isfilldataExpd :%0b|%0b isCacheHit :%0b nackuce:%0b rttNoAllocated:%0b fillwayn :%0d cache_index :%0h ",$time, this.t_lookup,this.lookupExpd, this.lookupSeen, this.cacheRspExpd, this.cacheRspRecd,this.fillExpd,this.fillSeen,this.fillDataExpd,this.fillDataSeen,this.isCacheHit,this.nackuce,this.rttNoAlloc,this.fillwayn,this.cache_index), UVM_MEDIUM)
          `uvm_info("<%=obj.BlockId%>:DMI_SCOREBOARD", $sformatf("%0t:sp_txn:%0b, sp_seen_ctrl_chnl %0b, sp_seen_write_chnl %0b, sp_seen_output_chnl %0b, t_sp_seen_ctrl_chnl:%0t t_sp_seen_wr_chnl:%0t, t_sp_seen_rd_chnl:%0t, sp_index: %0h, sp_way: %0h, sp_beat_num: %0d, sp_data_bank: %0d, sp_addr: %0h", $time, this.sp_txn, this.sp_seen_ctrl_chnl, this.sp_seen_write_chnl, this.sp_seen_output_chnl, this.t_sp_seen_ctrl_chnl, this.t_sp_seen_wr_chnl, this.t_sp_seen_rd_chnl, this.sp_index, this.sp_way, this.sp_beat_num, this.sp_data_bank, this.sp_addr), UVM_MEDIUM)
        <% } %>
        end
        else if(this.isDtwMrgMrd & !this.DTWrsp_DTR_rsp_expd & !this.RB_req_recd)begin
          `uvm_info("<%=obj.BlockId%>:DMI_SCOREBOARD", $sformatf("%0t:t_creation:%0t:[aiuId:0x%0x,aiu_msg_id:0x%0x],smi_msg_id:0x%0x,dtr_msg_id:%0x dtr_rmsg_id_recd:%0x:\ttype:0x%0x isDtwMrgMrd :%0b,msg_attr_ac:%0b, msg_attr_vz:%0b, smi_size :%0d intfSize :%0x mrdRsp:%0b|%0b,ar:%0b|%0b,r:%0b|%0b,dtrReq:%0b|%0b,dtrRsp:%0b|%0b, wrOutstandingFlag :%0b wrCnt:%0d isCacheHit :%0b seenAtReadArb :%0b seenAtWriteArb :%0b",$time, this.t_creation, this.dtr_targ_unit_id, this.dtr_rmsg_id_expd,this.smi_msg_id,this.dtr_msg_id,this.dtr_rmsg_id_recd,this.dtw_req_pkt.smi_msg_type,this.isDtwMrgMrd,this.smi_ac,this.smi_vz,this.smi_size,this.smi_intfsize,this.MRD_rsp_expd, this.MRD_rsp_recd, this.AXI_read_addr_expd, this.AXI_read_addr_recd, this.AXI_read_data_expd, this.AXI_read_data_recd, DTR_req_expd, DTR_req_recd, DTR_rsp_expd,DTR_rsp_recd,wrOutstandingFlag,wrOutstandingcnt,this.isCacheHit, this.seenAtReadArb, this.seenAtWriteArb), UVM_MEDIUM)
        <% if(obj.DutInfo.useCmc) { %>
          `uvm_info("<%=obj.BlockId%>:DMI_SCOREBOARD", $sformatf("%0t:t_lookup:%0t lookup:%0b|%0b,cmcrdrsp:%0b:%0b isfillExpd:%0b|%0b isfilldataExpd :%0b|%0b isCacheHit :%0b nackuce:%0b rttNoAllocated:%0b fillwayn :%0d cache_index :%0h ",$time, this.t_lookup,this.lookupExpd, this.lookupSeen, this.cacheRspExpd, this.cacheRspRecd,this.fillExpd,this.fillSeen,this.fillDataExpd,this.fillDataSeen,this.isCacheHit,this.nackuce,this.rttNoAlloc,this.fillwayn,this.cache_index), UVM_MEDIUM)
          `uvm_info("<%=obj.BlockId%>:DMI_SCOREBOARD", $sformatf("%0t:sp_txn:%0b, sp_seen_ctrl_chnl %0b, sp_seen_write_chnl %0b, sp_seen_output_chnl %0b, t_sp_seen_ctrl_chnl:%0t t_sp_seen_wr_chnl:%0t, t_sp_seen_rd_chnl:%0t, sp_index: %0h, sp_way: %0h, sp_beat_num: %0d, sp_data_bank: %0d, sp_addr: %0h", $time, this.sp_txn, this.sp_seen_ctrl_chnl, this.sp_seen_write_chnl, this.sp_seen_output_chnl, this.t_sp_seen_ctrl_chnl, this.t_sp_seen_wr_chnl, this.t_sp_seen_rd_chnl, this.sp_index, this.sp_way, this.sp_beat_num, this.sp_data_bank, this.sp_addr), UVM_MEDIUM)
        <% } %>
        end

        else if(this.isNcRd) begin
          `uvm_info("<%=obj.BlockId%>:DMI_SCOREBOARD", $sformatf("%0t:t_creation:%0t:[aiuId:0x%0x,aiu_msg_id:0x%0x],dtr_msg_id:%0x dtr_rmsg_id_recd:%0x addr:0x%0x,sec:0x%0x:\ttype:0x%0x msg_attr_ac:%0b, msg_attr_vz:%0b, smi_size :%0d intfSize :%0x CmdRsp:%0b|%0b,CmdRspRtl:1|%0b, StrReq:%0b|%0b, StrRsp:%0b|%0b, dtw_req:%0b|%0b dtw_rsp:%0b|%0b ar:%0b|%0b,r:%0b|%0b,dtrReq:%0b|%0b,dtrRsp:%0b|%0b, wrOutstandingFlag :%0b wrcnt:%0d isCacheHit :%0b seenAtReadArb :%0b seenAtWriteArb :%0b smi_dp_last:%0b",$time, this.t_creation,this.dtr_targ_unit_id, this.dtr_rmsg_id_expd,this.dtr_msg_id,this.dtr_rmsg_id_recd,this.cmd_req_pkt.smi_addr, this.cmd_req_pkt.smi_ns,this.cmd_req_pkt.smi_msg_type,this.smi_ac,this.smi_vz,this.smi_size,this.smi_intfsize,this.CMD_rsp_expd, this.CMD_rsp_recd,this.CMD_rsp_recd_rtl, this.STR_req_expd, this.STR_req_recd,this.STR_rsp_expd, this.STR_rsp_recd,this.DTW_req_expd,this.DTW_req_recd,this.DTW_rsp_expd, this.DTW_rsp_recd, this.AXI_read_addr_expd, this.AXI_read_addr_recd, this.AXI_read_data_expd, this.AXI_read_data_recd, DTR_req_expd, DTR_req_recd, DTR_rsp_expd,DTR_rsp_recd,wrOutstandingFlag,wrOutstandingcnt,this.isCacheHit, this.seenAtReadArb, this.seenAtWriteArb, this.smi_dp_last), UVM_MEDIUM)
        <% if(obj.DutInfo.useCmc) { %>
          `uvm_info("<%=obj.BlockId%>:DMI_SCOREBOARD", $sformatf("%0t:t_lookup:%0t lookup:%0b|%0b,cmcrdrsp:%0b:%0b isfillExpd:%0b|%0b isfilldataExpd :%0b|%0b isStale:%0b isdropped :%0b isCacheHit :%0b nackuce:%0b rttNoAllocated:%0b fillwayn :%0d cache_index:%0h smi_rbid:%0h ",$time, this.t_lookup,this.lookupExpd, this.lookupSeen, this.cacheRspExpd, this.cacheRspRecd,this.fillExpd,this.fillSeen,this.fillDataExpd,this.fillDataSeen,this.isStale,this.isdropped,this.isCacheHit,this.nackuce,this.rttNoAlloc,this.fillwayn,this.cache_index,this.smi_rbid), UVM_MEDIUM)
          `uvm_info("<%=obj.BlockId%>:DMI_SCOREBOARD", $sformatf("%0t:sp_txn:%0b, sp_seen_ctrl_chnl %0b, sp_seen_write_chnl %0b, sp_seen_output_chnl %0b, t_sp_seen_ctrl_chnl:%0t t_sp_seen_wr_chnl:%0t, t_sp_seen_rd_chnl:%0t, sp_index: %0h, sp_way: %0h, sp_beat_num: %0d, sp_data_bank: %0d, sp_addr: %0h", $time, this.sp_txn, this.sp_seen_ctrl_chnl, this.sp_seen_write_chnl, this.sp_seen_output_chnl, this.t_sp_seen_ctrl_chnl, this.t_sp_seen_wr_chnl, this.t_sp_seen_rd_chnl, this.sp_index, this.sp_way, this.sp_beat_num, this.sp_data_bank, this.sp_addr), UVM_MEDIUM)
        <% } %>
        end
        else if(this.isDtw | this.DTWrsp_DTR_rsp_expd) begin
       `uvm_info("<%=obj.BlockId%>:DMI_SCOREBOARD", $sformatf("%0t: creation:%0t:[aiuId:0x%0x,aiu_msg_id:0x%0x],addr=0x%0x,sec=%0b:\ttype:0x%0x rbid:%0h smi_size :%0d intfSize :%0x msg_attr_ac:%0b, msg_attr_vz:%0b isMW:%0b dtw_req:1|%0b dtw_rsp:%0b|%0b,dtw2nd_req:%0b|%0b dtw2nd_rsp:%0b|%0b rb_req:%0b|%0b,rb_rsp:%0b|%0b, rbrl_rsp:%0b|%0b, rbused_req:%0b|%0b,rbused_rsp:%0b|%0b,aw:%0b|%0b,w:%0b|%0b,b:%0b|%0b wrOutstanding :%0b",$time, this.t_creation,this.dtw_req_pkt.smi_src_ncore_unit_id,this.dtw_req_pkt.smi_msg_id, this.cache_addr, this.security,this.dtw_req_pkt.smi_msg_type,this.smi_rbid,this.smi_size,this.smi_intfsize,this.smi_ac,this.smi_vz,this.isMW,this.DTW_req_recd,this.DTW_rsp_expd, this.DTW_rsp_recd,this.DTW2nd_req_expd, this.DTW2nd_req_recd,this.DTW2nd_rsp_expd, this.DTW2nd_rsp_recd,this.RB_req_expd,this.RB_req_recd,this.RB_rsp_expd,this.RB_rsp_recd,this.RBRL_rsp_expd,this.RBRL_rsp_recd,this.RBU_req_expd,this.RBU_req_recd,this.RBU_rsp_expd,this.RBU_rsp_recd,this.AXI_write_addr_expd, this.AXI_write_addr_recd, this.AXI_write_data_expd, this.AXI_write_data_recd, this.AXI_write_resp_expd, this.AXI_write_resp_recd,this.wrOutstanding), UVM_MEDIUM)
        <% if(obj.DutInfo.useCmc) { %>
          `uvm_info("<%=obj.BlockId%>:DMI_SCOREBOARD", $sformatf("%0t:t_lookup:%0t t_lookup2nd:%0t lookupcnt:%0d lookup:%0b|%0b, lookupSeen2nd:%0b cacheWrDataExpd :%0b|%0b evictDataExpd :%0b|%0b  isCacheHit :%0b  nackuce:%0b  cache_index :%0h ",$time, this.t_lookup,this.t_lookup2nd,this.lookupcnt,this.lookupExpd, this.lookupSeen, this.lookupSeen2nd, this.cacheWrDataExpd, this.cacheWrDataRecd, this.evictDataExpd, this.evictDataRecd, this.isCacheHit,this.nackuce, this.cache_index), UVM_MEDIUM)
          `uvm_info("<%=obj.BlockId%>:DMI_SCOREBOARD", $sformatf("%0t:sp_txn:%0b, sp_seen_ctrl_chnl %0b, sp_seen_write_chnl %0b, sp_seen_output_chnl %0b, t_sp_seen_ctrl_chnl:%0t t_sp_seen_wr_chnl:%0t, t_sp_seen_rd_chnl:%0t, sp_index: %0h, sp_way: %0h, sp_beat_num: %0d, sp_data_bank: %0d, sp_addr: %0h", $time, this.sp_txn, this.sp_seen_ctrl_chnl, this.sp_seen_write_chnl, this.sp_seen_output_chnl, this.t_sp_seen_ctrl_chnl, this.t_sp_seen_wr_chnl, this.t_sp_seen_rd_chnl, this.sp_index, this.sp_way, this.sp_beat_num, this.sp_data_bank, this.sp_addr), UVM_MEDIUM)
        <% } %>
        end
        else if(this.RB_req_recd ) begin
       `uvm_info("<%=obj.BlockId%>:DMI_SCOREBOARD", $sformatf("%0t: creation:%0t:addr=0x%0x,sec=%0b:\ttype:0x%0x rbid:%0h smi_size:%0d intfSize :%0x msg_attr_ac:%0b, msg_attr_vz:%0b dtw_req:1|%0b dtw_rsp:%0b|%0b,rb_req:%0b|%0b,rb_rsp:%0b|%0b, rbrl_rsp:%0b|%0b, rbused_req:%0b|%0b,rbused_rsp:%0b|%0b,aw:%0b|%0b,w:%0b|%0b,b:%0b|%0b wrOutstanding :%0b",$time, this.t_creation,this.cache_addr, this.security,this.rb_req_pkt.smi_msg_type,this.smi_rbid,this.smi_size,this.smi_intfsize,this.smi_ac,this.smi_vz,this.DTW_req_recd,this.DTW_rsp_expd, this.DTW_rsp_recd,this.RB_req_expd,this.RB_req_recd,this.RB_rsp_expd,this.RB_rsp_recd,this.RBRL_rsp_expd,this.RBRL_rsp_recd,this.RBU_req_expd,this.RBU_req_recd,this.RBU_rsp_expd,this.RBU_rsp_recd,this.AXI_write_addr_expd, this.AXI_write_addr_recd, this.AXI_write_data_expd, this.AXI_write_data_recd, this.AXI_write_resp_expd, this.AXI_write_resp_recd,this.wrOutstanding), UVM_MEDIUM)
        <% if(obj.DutInfo.useCmc) { %>
          `uvm_info("<%=obj.BlockId%>:DMI_SCOREBOARD", $sformatf("%0t:t_lookup:%0t lookup:%0b|%0b, cacheWrDataExpd :%0b|%0b evictDataExpd :%0b|%0b  isCacheHit :%0b  nackuce:%0b  cache_index :%0h ",$time, this.t_lookup,this.lookupExpd, this.lookupSeen, this.cacheWrDataExpd, this.cacheWrDataRecd, this.evictDataExpd, this.evictDataRecd, this.isCacheHit,this.nackuce, this.cache_index), UVM_MEDIUM)
          `uvm_info("<%=obj.BlockId%>:DMI_SCOREBOARD", $sformatf("%0t:sp_txn:%0b, t_sp_seen_ctrl_chnl:%0t t_sp_seen_wr_chnl:%0t, t_sp_seen_rd_chnl:%0t, sp_index: %0h, sp_way: %0h, sp_beat_num: %0d, sp_data_bank: %0d, sp_addr: %0h",$time, this.sp_txn, this.sp_seen_ctrl_chnl, this.sp_seen_write_chnl, this.sp_seen_output_chnl, this.sp_index, this.sp_way, this.sp_beat_num, this.sp_data_bank, this.sp_addr), UVM_MEDIUM)
        <% } %>
        end
        <% if(obj.DutInfo.useCmc) { %>
        else if(this.isEvict) begin
         `uvm_info("<%=obj.BlockId%>:DMI_SCOREBOARD", $sformatf("%0t: creation:%0t:addr=0x%0x,sec=%0b:isEvict :%0b evictDataExpd:%0b|%0b  aw:%0b|%0b,w:%0b|%0b,b:%0b|%0b",$time, this.t_creation,this.cache_addr,this.security,this.isEvict,this.evictDataExpd,this.evictDataRecd,this.AXI_write_addr_expd, this.AXI_write_addr_recd, this.AXI_write_data_expd, this.AXI_write_data_recd, this.AXI_write_resp_expd, this.AXI_write_resp_recd), UVM_MEDIUM)
          `uvm_info("<%=obj.BlockId%>:DMI_SCOREBOARD", $sformatf("%0t:sp_txn:%0b, sp_seen_ctrl_chnl %0b, sp_seen_write_chnl %0b, sp_seen_output_chnl %0b, t_sp_seen_ctrl_chnl:%0t t_sp_seen_wr_chnl:%0t, t_sp_seen_rd_chnl:%0t, sp_index: %0h, sp_way: %0h, sp_beat_num: %0d, sp_data_bank: %0d, sp_addr: %0h", $time, this.sp_txn, this.sp_seen_ctrl_chnl, this.sp_seen_write_chnl, this.sp_seen_output_chnl, this.t_sp_seen_ctrl_chnl, this.t_sp_seen_wr_chnl, this.t_sp_seen_rd_chnl, this.sp_index, this.sp_way, this.sp_beat_num, this.sp_data_bank, this.sp_addr), UVM_MEDIUM)
        end
        <% } %>
        else if(this.isNcWr) begin
       `uvm_info("<%=obj.BlockId%>:DMI_SCOREBOARD", $sformatf("%0t: creation:%0t:[aiuId:0x%0x,aiu_msg_id:0x%0x],addr=0x%0x,sec=%0b:\t cmdtype:0x%0x dtwtype:0x%0x rbid:%0h smi_size:%0d intfSize :%0x msg_attr_ac:%0b, msg_attr_vz:%0b isNcWr :%0b isCoh :%0b dtw_req:1|%0b dtw_rsp:%0b|%0b,cmd_rsp:%0b|%0b,cmd_rspRtl:1|%0b,str_req:%0b|%0b,str_rsp:%0b|%0b,aw:%0b|%0b,w:%0b|%0b,b:%0b|%0b wrOutstanding :%0b",$time, this.t_creation,this.cmd_req_pkt.smi_src_ncore_unit_id,this.cmd_req_pkt.smi_msg_id, this.cache_addr, this.security,this.smi_msg_type,this.dtw_msg_type,this.smi_rbid,this.smi_size,this.smi_intfsize,this.smi_ac,this.smi_vz,this.isNcWr,this.isCoh,this.DTW_req_recd,this.DTW_rsp_expd, this.DTW_rsp_recd,this.CMD_rsp_expd,this.CMD_rsp_recd,this.CMD_rsp_recd_rtl,this.STR_req_expd,this.STR_req_recd,this.STR_rsp_expd,this.STR_rsp_recd,this.AXI_write_addr_expd, this.AXI_write_addr_recd, this.AXI_write_data_expd, this.AXI_write_data_recd, this.AXI_write_resp_expd, this.AXI_write_resp_recd,this.wrOutstanding), UVM_MEDIUM)
        <% if(obj.DutInfo.useCmc) { %>
          `uvm_info("<%=obj.BlockId%>:DMI_SCOREBOARD", $sformatf("%0t:t_lookup:%0t lookup:%0b|%0b, cacheWrDataExpd :%0b|%0b evictDataExpd :%0b|%0b  isCacheHit :%0b  nackuce:%0b  cache_index :%0h ",$time, this.t_lookup,this.lookupExpd, this.lookupSeen, this.cacheWrDataExpd, this.cacheWrDataRecd, this.evictDataExpd, this.evictDataRecd, this.isCacheHit,this.nackuce, this.cache_index), UVM_MEDIUM)
          `uvm_info("<%=obj.BlockId%>:DMI_SCOREBOARD", $sformatf("%0t:sp_txn:%0b, sp_seen_ctrl_chnl %0b, sp_seen_write_chnl %0b, sp_seen_output_chnl %0b, t_sp_seen_ctrl_chnl:%0t t_sp_seen_wr_chnl:%0t, t_sp_seen_rd_chnl:%0t, sp_index: %0h, sp_way: %0h, sp_beat_num: %0d, sp_data_bank: %0d, sp_addr: %0h", $time, this.sp_txn, this.sp_seen_ctrl_chnl, this.sp_seen_write_chnl, this.sp_seen_output_chnl, this.t_sp_seen_ctrl_chnl, this.t_sp_seen_wr_chnl, this.t_sp_seen_rd_chnl, this.sp_index, this.sp_way, this.sp_beat_num, this.sp_data_bank, this.sp_addr), UVM_MEDIUM)
        <% } %>
        end
      /*  if(this.isMW && this.DTW2nd_req_recd)begin
       `uvm_info("<%=obj.BlockId%>:DMI_SCOREBOARD", $sformatf("%0t: creation:%0t:addr=0x%0x,sec=%0b:\ttype:0x%0x rbid:%0h smi_size:%0d msg_attr_ac:%0b, msg_attr_vz:%0b dtw_2ndreq:1|%0b dtw_2ndrsp:%0b|%0b,aw2nd:%0b|%0b,w2nd:%0b|%0b,b2nd:%0b|%0b wrOutstanding :%0b",$time, this.t_creation,this.cache_addr, this.security,this.dtw2nd_req_pkt.smi_msg_type,this.dtw2nd_req_pkt.smi_rbid,this.smi_size,this.smi_ac,this.smi_vz,this.DTW2nd_req_recd,this.DTW2nd_rsp_expd, this.DTW2nd_rsp_recd,this.AXI_write_2ndaddr_expd, this.AXI_write_2ndaddr_recd, this.AXI_write_2nddata_expd, this.AXI_write_2nddata_recd, this.AXI_write_2ndresp_expd, this.AXI_write_2ndresp_recd,this.wrOutstanding), UVM_MEDIUM)
        <% if(obj.DutInfo.useCmc) { %>
          `uvm_info("<%=obj.BlockId%>:DMI_SCOREBOARD", $sformatf("%0t:t_lookup:%0t t_lookup2nd:%0t lookupcnt:%0d lookup:%0b|%0b, lookupSeen2nd:%0b cacheWrDataExpd :%0b|%0b bypassExpd :%0b|%0b  isCacheHit :%0b  nackuce:%0b  cache_index :%0h ",$time, this.t_lookup,this.t_lookup2nd,this.lookupcnt,this.lookupExpd, this.lookupSeen, this.lookupSeen2nd, this.cacheWrDataExpd, this.cacheWrDataRecd, this.bypassExpd, this.bypassSeen, this.isCacheHit,this.nackuce, this.cache_index), UVM_MEDIUM)
          `uvm_info("<%=obj.BlockId%>:DMI_SCOREBOARD", $sformatf("%0t:sp_txn:%0b, t_sp_seen_ctrl_chnl:%0t t_sp_seen_wr_chnl:%0t, t_sp_seen_rd_chnl:%0t, sp_index: %0h, sp_way: %0h, sp_beat_num: %0d, sp_data_bank: %0d, sp_addr: %0h",$time, this.sp_txn, this.sp_seen_ctrl_chnl, this.sp_seen_write_chnl, this.sp_seen_output_chnl, this.sp_index, this.sp_way, this.sp_beat_num, this.sp_data_bank, this.sp_addr), UVM_MEDIUM)
        <% } %>
        enid */
        `uvm_info("<%=obj.BlockId%>:DMI_SCOREBOARD",$sformatf("smi_qos :%0x smi_priority :%0b",this.smi_qos,this.smi_msg_pri),UVM_MEDIUM);
        if(this.MRD_req_recd)begin
          `uvm_info("<%=obj.BlockId%>:DMI_SCOREBOARD",$psprintf("MRD_REQ: %s",mrd_req_pkt.convert2string()),UVM_MEDIUM);
        end
        if(this.MRD_rsp_recd)begin
          `uvm_info("<%=obj.BlockId%>:DMI_SCOREBOARD",$psprintf("MRD_RSP: %s",mrd_rsp_pkt.convert2string()),UVM_MEDIUM);
        end
        if(this.RB_req_recd)begin
          `uvm_info("<%=obj.BlockId%>:DMI_SCOREBOARD",$psprintf("RB_REQ: %s",rb_req_pkt.convert2string()),UVM_MEDIUM);
        end
        if(this.RB_rsp_recd)begin
          `uvm_info("<%=obj.BlockId%>:DMI_SCOREBOARD",$psprintf("RB_RSP: %s",rb_rsp_pkt.convert2string()),UVM_MEDIUM);
        end
        if(this.CMD_req_recd)begin
          `uvm_info("<%=obj.BlockId%>:DMI_SCOREBOARD",$psprintf("CMD_REQ: %s",cmd_req_pkt.convert2string()),UVM_MEDIUM);
        end
        if(this.CMD_rsp_recd)begin
          `uvm_info("<%=obj.BlockId%>:DMI_SCOREBOARD",$psprintf("CMD_RSP: %s",cmd_rsp_pkt.convert2string()),UVM_MEDIUM);
        end
        if(this.CMD_rsp_recd_rtl)begin
          `uvm_info("<%=obj.BlockId%>:DMI_SCOREBOARD",$psprintf("CMD_RSP_RTL: %s",cmd_rsp_pkt_rtl.sprint_pkt()),UVM_MEDIUM);
        end
        if(this.MRD_req_recd_rtl)begin
          `uvm_info("<%=obj.BlockId%>:DMI_SCOREBOARD",$psprintf("MRD_REQ_RTL: %s",mrd_req_pkt_rtl.sprint_pkt()),UVM_MEDIUM);
        end
        if(this.STR_req_recd)begin
          `uvm_info("<%=obj.BlockId%>:DMI_SCOREBOARD",$psprintf("STR_REQ: %s",str_req_pkt.convert2string()),UVM_MEDIUM);
        end
        if(this.STR_rsp_recd)begin
          `uvm_info("<%=obj.BlockId%>:DMI_SCOREBOARD",$psprintf("STR_RSP: %s",str_rsp_pkt.convert2string()),UVM_MEDIUM);
        end
        if(this.DTR_req_recd)begin
          `uvm_info("<%=obj.BlockId%>:DMI_SCOREBOARD",$psprintf("DTR_REQ: %s",dtr_req_pkt.convert2string()),UVM_MEDIUM);
        end
        if(this.DTR_rsp_recd)begin
          `uvm_info("<%=obj.BlockId%>:DMI_SCOREBOARD",$psprintf("DTR_RSP: %s",dtr_rsp_pkt.convert2string()),UVM_MEDIUM);
        end
        if(this.DTW_req_recd)begin
          `uvm_info("<%=obj.BlockId%>:DMI_SCOREBOARD",$psprintf("DTW_REQ: %s",dtw_req_pkt.convert2string()),UVM_MEDIUM);
        end
        if(this.DTW_rsp_recd)begin
          `uvm_info("<%=obj.BlockId%>:DMI_SCOREBOARD",$psprintf("DTW_RSP: %s",dtw_rsp_pkt.convert2string()),UVM_MEDIUM);
        end
        if(this.AXI_read_addr_recd)begin
          `uvm_info("<%=obj.BlockId%>:DMI_SCOREBOARD",$psprintf("AXI_READ_ADDR: %s",axi_read_addr_pkt.sprint_pkt()),UVM_MEDIUM);
        end
        if(this.AXI_read_data_recd)begin
          `uvm_info("<%=obj.BlockId%>:DMI_SCOREBOARD",$psprintf("AXI_READ_DATA: %s",axi_read_data_pkt.sprint_pkt()),UVM_MEDIUM);
        end
        if(this.AXI_write_addr_recd)begin
          `uvm_info("<%=obj.BlockId%>:DMI_SCOREBOARD",$psprintf("AXI_WRITE_ADDR: %s",axi_write_addr_pkt.sprint_pkt()),UVM_MEDIUM);
        end
        if(this.AXI_write_data_recd)begin
          `uvm_info("<%=obj.BlockId%>:DMI_SCOREBOARD",$psprintf("AXI_WRITE_DATA: %s",axi_write_data_pkt.sprint_pkt()),UVM_MEDIUM);
        end
        if(this.AXI_write_resp_recd)begin
          `uvm_info("<%=obj.BlockId%>:DMI_SCOREBOARD",$psprintf("AXI_WRITE_RSP: %s",axi_write_resp_pkt.sprint_pkt()),UVM_MEDIUM);
        end
        <% if(obj.DutInfo.useCmc) { %>
        if(this.lookupSeen) begin
          if(cache_ctrl_pkt != null) begin
            `uvm_info("<%=obj.BlockId%>:DMI_SCOREBOARD",$psprintf("CACHE_CTRL_PKT: %s",cache_ctrl_pkt.sprint_pkt()),UVM_MEDIUM);
          end
          else begin
            `uvm_info("<%=obj.BlockId%>:DMI_SCOREBOARD","lookupSeen was set but cache_ctrl_pkt never receieved/assigned",UVM_MEDIUM);
          end
        end
        if(this.cacheRspRecd) begin
            `uvm_info("<%=obj.BlockId%>:DMI_SCOREBOARD",$psprintf("CACHE_RD_DATA_PKT: %s",cache_rd_data_pkt.sprint_pkt()),UVM_MEDIUM);
        end
        if(this.cacheWrDataRecd) begin
            `uvm_info("<%=obj.BlockId%>:DMI_SCOREBOARD",$psprintf("CACHE_WR_DATA_PKT: %s",cache_wr_data_pkt.sprint_pkt()),UVM_MEDIUM);
        end
        if(this.fillSeen) begin
            `uvm_info("<%=obj.BlockId%>:DMI_SCOREBOARD",$psprintf("CACHE_FILL_CTRL_PKT: %s",cache_fill_ctrl_pkt.sprint_pkt()),UVM_MEDIUM);
        end
        if(this.fillDataSeen) begin
            `uvm_info("<%=obj.BlockId%>:DMI_SCOREBOARD",$psprintf("CACHE_FILL_DATA_PKT: %s",cache_fill_data_pkt.sprint_pkt()),UVM_MEDIUM);
        end
        if(this.evictDataRecd) begin
            `uvm_info("<%=obj.BlockId%>:DMI_SCOREBOARD",$psprintf("CACHE_EVICT_DATA_PKT: %s",cache_evict_data_pkt.sprint_pkt()),UVM_MEDIUM);
        end
        if(this.sp_seen_ctrl_chnl && m_sp_ctrl_pkt!=null) begin
            `uvm_info("<%=obj.BlockId%>:DMI_SCOREBOARD",$psprintf("SP_CTRL_PKT: %s",m_sp_ctrl_pkt.sprint_pkt()),UVM_MEDIUM);
        end
        if(this.sp_seen_write_chnl && m_sp_wr_data_pkt!=null) begin
            `uvm_info("<%=obj.BlockId%>:DMI_SCOREBOARD",$psprintf("SP_WRITE_DATA_PKT: %s",m_sp_wr_data_pkt.sprint_pkt()),UVM_MEDIUM);
        end
        if(this.sp_seen_output_chnl && m_sp_rd_data_pkt!=null) begin
            `uvm_info("<%=obj.BlockId%>:DMI_SCOREBOARD",$psprintf("SP_READ_DATA_PKT: %s",m_sp_rd_data_pkt.sprint_pkt()),UVM_MEDIUM);
        end
        <% } %>
        if(this.seenAtReadArb) begin
            `uvm_info("<%=obj.BlockId%>:DMI_SCOREBOARD",$psprintf("READ_ARB_PKT: %s",read_arb_pkt.sprint_pkt()),UVM_MEDIUM);
        end
        if(this.seenAtWriteArb) begin
            `uvm_info("<%=obj.BlockId%>:DMI_SCOREBOARD",$psprintf("WRITE_ARB_PKT: %s",write_arb_pkt.sprint_pkt()),UVM_MEDIUM);
        end
    endfunction // print_entry
     
    function void print_entry_eos(bit isPendingTxn = 0);
        string header = "";
        if(isPendingTxn)begin
          header = "PENDING TXN";
        end
        if(this.isCmdPref) begin
          `uvm_info("<%=obj.BlockId%>:DMI_SCOREBOARD", $sformatf("%0t:t_creation:%0t:UID:%0d:smi_msg_id:0x%0x,addr:0x%0x,sec:0x%0x:\ttype:0x%0x msg_attr_ac:%0b,  CmdRsp:1|%0b,CmdRspRtl:1|%0b  ar:%0b|%0b,r:%0b|%0b",$time,this.t_creation,txn_id,this.smi_msg_id,this.cache_addr, this.security,this.smi_msg_type,this.smi_ac,this.CMD_rsp_recd, this.CMD_rsp_recd_rtl, this.AXI_read_addr_expd, this.AXI_read_addr_recd, this.AXI_read_data_expd, this.AXI_read_data_recd), UVM_LOW)
        <% if(obj.DutInfo.useCmc) { %>
          `uvm_info("<%=obj.BlockId%>:DMI_SCOREBOARD", $sformatf("%0t:t_lookup:%0t lookup:%0b|%0b,cmcrdrsp:%0b:%0b isfillExpd:%0b|%0b isfilldataExpd :%0b|%0b isStale:%0b isdropped :%0b isCacheHit :%0b nackuce:%0b rttNoAllocated:%0b fillwayn :%0d cache_index :%0h ",$time, this.t_lookup,this.lookupExpd, this.lookupSeen, this.cacheRspExpd, this.cacheRspRecd,this.fillExpd,this.fillSeen,this.fillDataExpd,this.fillDataSeen,this.isStale,this.isdropped,this.isCacheHit,this.nackuce,this.rttNoAlloc,this.fillwayn,this.cache_index), UVM_LOW)
          `uvm_info("<%=obj.BlockId%>:DMI_SCOREBOARD", $sformatf("%0t:sp_txn:%0b, t_sp_seen_ctrl_chnl:%0t t_sp_seen_wr_chnl:%0t, t_sp_seen_rd_chnl:%0t, sp_index: %0h, sp_way: %0h, sp_beat_num: %0d, sp_data_bank: %0d, sp_addr: %0h",$time, this.sp_txn, this.sp_seen_ctrl_chnl, this.sp_seen_write_chnl, this.sp_seen_output_chnl, this.sp_index, this.sp_way, this.sp_beat_num, this.sp_data_bank, this.sp_addr), UVM_LOW)
        <% } %>
        end
        else if(this.isMrd) begin
          `uvm_info("<%=obj.BlockId%>:DMI_SCOREBOARD", $sformatf("%0t:t_creation:%0t:UID:%0d:[aiuId:0x%0x,aiu_msg_id:0x%0x],smi_msg_id:0x%0x,dtr_msg_id:%0x dtr_rmsg_id_recd:%0x addr:0x%0x,sec:0x%0x:\ttype:0x%0x isDtwMrgMrd :%0b,msg_attr_ac:%0b, msg_attr_vz:%0b, smi_size :%0d intfSize :%0x MrdReqRtl:1|%0b mrdRsp:%0b|%0b,ar:%0b|%0b,r:%0b|%0b,dtrReq:%0b|%0b,dtrRsp:%0b|%0b, wrOutstandingFlag :%0b wrCnt:%0d isCacheHit :%0b",$time, this.t_creation, txn_id, this.dtr_targ_unit_id, this.dtr_rmsg_id_expd,this.smi_msg_id,this.dtr_msg_id,this.dtr_rmsg_id_recd,this.mrd_req_pkt.smi_addr, this.mrd_req_pkt.smi_ns,this.mrd_req_pkt.smi_msg_type,this.isDtwMrgMrd,this.smi_ac,this.smi_vz,this.smi_size,this.smi_intfsize,this.MRD_req_recd_rtl,this.MRD_rsp_expd, this.MRD_rsp_recd, this.AXI_read_addr_expd, this.AXI_read_addr_recd, this.AXI_read_data_expd, this.AXI_read_data_recd, DTR_req_expd, DTR_req_recd, DTR_rsp_expd,DTR_rsp_recd,wrOutstandingFlag,wrOutstandingcnt,this.isCacheHit), UVM_LOW)
        <% if(obj.DutInfo.useCmc) { %>
          `uvm_info("<%=obj.BlockId%>:DMI_SCOREBOARD", $sformatf("%0t:t_lookup:%0t lookup:%0b|%0b,cmcrdrsp:%0b:%0b isfillExpd:%0b|%0b isfilldataExpd :%0b|%0b isCacheHit :%0b nackuce:%0b rttNoAllocated:%0b fillwayn :%0d cache_index :%0h ",$time, this.t_lookup,this.lookupExpd, this.lookupSeen, this.cacheRspExpd, this.cacheRspRecd,this.fillExpd,this.fillSeen,this.fillDataExpd,this.fillDataSeen,this.isCacheHit,this.nackuce,this.rttNoAlloc,this.fillwayn,this.cache_index), UVM_LOW)
          `uvm_info("<%=obj.BlockId%>:DMI_SCOREBOARD", $sformatf("%0t:sp_txn:%0b, t_sp_seen_ctrl_chnl:%0t t_sp_seen_wr_chnl:%0t, t_sp_seen_rd_chnl:%0t, sp_index: %0h, sp_way: %0h, sp_beat_num: %0d, sp_data_bank: %0d, sp_addr: %0h",$time, this.sp_txn, this.sp_seen_ctrl_chnl, this.sp_seen_write_chnl, this.sp_seen_output_chnl, this.sp_index, this.sp_way, this.sp_beat_num, this.sp_data_bank, this.sp_addr), UVM_LOW)
        <% } %>
        end
        else if(this.isDtwMrgMrd & !this.DTWrsp_DTR_rsp_expd & this.RB_req_recd)begin
          `uvm_info("<%=obj.BlockId%>:DMI_SCOREBOARD", $sformatf("%0t:t_creation:%0t:UID:%0d:[aiuId:0x%0x,aiu_msg_id:0x%0x],smi_msg_id:0x%0x,dtr_msg_id:%0x dtr_rmsg_id_recd:%0x addr:0x%0x,sec:0x%0x:\ttype:0x%0x isDtwMrgMrd :%0b,msg_attr_ac:%0b, msg_attr_vz:%0b, smi_size :%0d intfSize :%0x mrdRsp:%0b|%0b,ar:%0b|%0b,r:%0b|%0b,dtrReq:%0b|%0b,dtrRsp:%0b|%0b, wrOutstandingFlag :%0b wrCnt:%0d isCacheHit :%0b",$time, this.t_creation, txn_id, this.dtr_targ_unit_id, this.dtr_rmsg_id_expd,this.smi_msg_id,this.dtr_msg_id,this.dtr_rmsg_id_recd,this.rb_req_pkt.smi_addr, this.rb_req_pkt.smi_ns,this.dtw_req_pkt.smi_msg_type,this.isDtwMrgMrd,this.smi_ac,this.smi_vz,this.smi_size,this.smi_intfsize,this.MRD_rsp_expd, this.MRD_rsp_recd, this.AXI_read_addr_expd, this.AXI_read_addr_recd, this.AXI_read_data_expd, this.AXI_read_data_recd, DTR_req_expd, DTR_req_recd, DTR_rsp_expd,DTR_rsp_recd,wrOutstandingFlag,wrOutstandingcnt,this.isCacheHit), UVM_LOW)
        <% if(obj.DutInfo.useCmc) { %>
          `uvm_info("<%=obj.BlockId%>:DMI_SCOREBOARD", $sformatf("%0t:t_lookup:%0t lookup:%0b|%0b,cmcrdrsp:%0b:%0b isfillExpd:%0b|%0b isfilldataExpd :%0b|%0b isCacheHit :%0b nackuce:%0b rttNoAllocated:%0b fillwayn :%0d cache_index :%0h ",$time, this.t_lookup,this.lookupExpd, this.lookupSeen, this.cacheRspExpd, this.cacheRspRecd,this.fillExpd,this.fillSeen,this.fillDataExpd,this.fillDataSeen,this.isCacheHit,this.nackuce,this.rttNoAlloc,this.fillwayn,this.cache_index), UVM_LOW)
          `uvm_info("<%=obj.BlockId%>:DMI_SCOREBOARD", $sformatf("%0t:sp_txn:%0b, t_sp_seen_ctrl_chnl:%0t t_sp_seen_wr_chnl:%0t, t_sp_seen_rd_chnl:%0t, sp_index: %0h, sp_way: %0h, sp_beat_num: %0d, sp_data_bank: %0d, sp_addr: %0h",$time, this.sp_txn, this.sp_seen_ctrl_chnl, this.sp_seen_write_chnl, this.sp_seen_output_chnl, this.sp_index, this.sp_way, this.sp_beat_num, this.sp_data_bank, this.sp_addr), UVM_LOW)
        <% } %>
        end
        else if(this.isNcRd) begin
          `uvm_info("<%=obj.BlockId%>:DMI_SCOREBOARD", $sformatf("%0t:t_creation:%0t:UID:%0d:[aiuId:0x%0x,aiu_msg_id:0x%0x],dtr_msg_id:%0x dtr_rmsg_id_recd:%0x addr:0x%0x,sec:0x%0x:\ttype:0x%0x msg_attr_ac:%0b, msg_attr_vz:%0b, smi_size:%0d intfSize :%0x  CmdRsp:%0b|%0b,CmdRspRtl:1|%0b, StrReq:%0b|%0b, StrRsp:%0b|%0b, dtw_req:%0b|%0b dtw_rsp:%0b|%0b ar:%0b|%0b,r:%0b|%0b,dtrReq:%0b|%0b,dtrRsp:%0b|%0b, wrOutstandingFlag :%0b wrcnt:%0d isCacheHit :%0b smi_dp_last:%0b",$time, this.t_creation,txn_id, this.dtr_targ_unit_id, this.dtr_rmsg_id_expd,this.dtr_msg_id,this.dtr_rmsg_id_recd,this.cmd_req_pkt.smi_addr, this.cmd_req_pkt.smi_ns,this.cmd_req_pkt.smi_msg_type,this.smi_ac,this.smi_vz,this.smi_size,this.smi_intfsize,this.CMD_rsp_expd, this.CMD_rsp_recd,this.CMD_rsp_recd_rtl,this.STR_req_expd, this.STR_req_recd,this.STR_rsp_expd, this.STR_rsp_recd,this.DTW_req_expd,this.DTW_req_recd,this.DTW_rsp_expd, this.DTW_rsp_recd, this.AXI_read_addr_expd, this.AXI_read_addr_recd, this.AXI_read_data_expd, this.AXI_read_data_recd, DTR_req_expd, DTR_req_recd, DTR_rsp_expd,DTR_rsp_recd,wrOutstandingFlag,wrOutstandingcnt,this.isCacheHit, this.smi_dp_last),UVM_LOW);
        <% if(obj.DutInfo.useCmc) { %>
          `uvm_info("<%=obj.BlockId%>:DMI_SCOREBOARD", $sformatf("%0t:t_lookup:%0t lookup:%0b|%0b,cmcrdrsp:%0b:%0b isfillExpd:%0b|%0b isfilldataExpd :%0b|%0b isStale:%0b isdropped :%0b isCacheHit :%0b nackuce:%0b rttNoAllocated:%0b fillwayn :%0d cache_index:%0d smi_rbid :%0x",$time, this.t_lookup,this.lookupExpd, this.lookupSeen, this.cacheRspExpd, this.cacheRspRecd,this.fillExpd,this.fillSeen,this.fillDataExpd,this.fillDataSeen,this.isStale,this.isdropped,this.isCacheHit,this.nackuce,this.rttNoAlloc,this.fillwayn,this.cache_index,this.smi_rbid), UVM_LOW)
          `uvm_info("<%=obj.BlockId%>:DMI_SCOREBOARD", $sformatf("%0t:sp_txn:%0b, t_sp_seen_ctrl_chnl:%0t t_sp_seen_wr_chnl:%0t, t_sp_seen_rd_chnl:%0t, sp_index: %0h, sp_way: %0h, sp_beat_num: %0d, sp_data_bank: %0d, sp_addr: %0h",$time, this.sp_txn, this.sp_seen_ctrl_chnl, this.sp_seen_write_chnl, this.sp_seen_output_chnl, this.sp_index, this.sp_way, this.sp_beat_num, this.sp_data_bank, this.sp_addr), UVM_LOW)
        <% } %>
        end
        else if(this.isDtw | this.DTWrsp_DTR_rsp_expd) begin
       `uvm_info("<%=obj.BlockId%>:DMI_SCOREBOARD", $sformatf("%0t:t_creation:%0t:UID:%0d:[aiuId:0x%0x,aiu_msg_id:0x%0x],addr=0x%0x,sec=%0b:\ttype:0x%0x rbid:%0h smi_size :%0d intfSize :%0x  msg_attr_ac:%0b, msg_attr_vz:%0b isMW:%0b dtw_req:1|%0b dtw_rsp:%0b|%0b,dtw2nd_req:%0b|%0b dtw2nd_rsp:%0b|%0b rb_req:%0b|%0b,rb_rsp:%0b|%0b, rbrl_rsp:%0b|%0b, rbused_req:%0b|%0b,rbused_rsp:%0b|%0b,aw:%0b|%0b,w:%0b|%0b,b:%0b|%0b wrOutstanding :%0b",$time, this.t_creation,txn_id,this.dtw_req_pkt.smi_src_ncore_unit_id,this.dtw_req_pkt.smi_msg_id, this.cache_addr, this.security,this.dtw_req_pkt.smi_msg_type,this.smi_rbid,this.smi_size,this.smi_intfsize,this.smi_ac,this.smi_vz,this.isMW,this.DTW_req_recd,this.DTW_rsp_expd, this.DTW_rsp_recd,this.DTW2nd_req_expd, this.DTW2nd_req_recd,this.DTW2nd_rsp_expd, this.DTW2nd_rsp_recd,this.RB_req_expd,this.RB_req_recd,this.RB_rsp_expd,this.RB_rsp_recd,this.RBRL_rsp_expd,this.RBRL_rsp_recd,this.RBU_req_expd,this.RBU_req_recd,this.RBU_rsp_expd,this.RBU_rsp_recd,this.AXI_write_addr_expd, this.AXI_write_addr_recd, this.AXI_write_data_expd, this.AXI_write_data_recd, this.AXI_write_resp_expd, this.AXI_write_resp_recd,this.wrOutstanding), UVM_LOW)
        <% if(obj.DutInfo.useCmc) { %>
          `uvm_info("<%=obj.BlockId%>:DMI_SCOREBOARD", $sformatf("%0t:t_lookup:%0t lookup:%0b|%0b, cacheWrDataExpd :%0b|%0b EvictDataExpd :%0b|%0b  isCacheHit :%0b  nackuce:%0b cache_index :%0h  ",$time, this.t_lookup,this.lookupExpd, this.lookupSeen, this.cacheWrDataExpd, this.cacheWrDataRecd, this.bypassExpd, this.evictDataRecd, this.isCacheHit,this.nackuce,this.cache_index), UVM_LOW);
          `uvm_info("<%=obj.BlockId%>:DMI_SCOREBOARD", $sformatf("%0t:sp_txn:%0b, t_sp_seen_ctrl_chnl:%0t t_sp_seen_wr_chnl:%0t, t_sp_seen_rd_chnl:%0t, sp_index: %0h, sp_way: %0h, sp_beat_num: %0d, sp_data_bank: %0d, sp_addr: %0h",$time, this.sp_txn, this.sp_seen_ctrl_chnl, this.sp_seen_write_chnl, this.sp_seen_output_chnl, this.sp_index, this.sp_way, this.sp_beat_num, this.sp_data_bank, this.sp_addr), UVM_LOW)
        <% } %>
      end
      else if(this.RB_req_recd) begin
       `uvm_info("<%=obj.BlockId%>:DMI_SCOREBOARD", $sformatf("%0t:t_creation:%0t:UID:%0d:addr=0x%0x,sec=%0b:\ttype:0x%0x rbid:%0h smi_size:%0d intfSize :%0x  msg_attr_ac:%0b, msg_attr_vz:%0b dtw_req:1|%0b dtw_rsp:%0b|%0b,rb_req:%0b|%0b,rb_rsp:%0b|%0b, rbrl_rsp:%0b|%0b, rbused_req:%0b|%0b,rbused_rsp:%0b|%0b,aw:%0b|%0b,w:%0b|%0b,b:%0b|%0b wrOutstanding :%0b",$time, this.t_creation,txn_id,this.cache_addr, this.security,this.rb_req_pkt.smi_msg_type,this.smi_rbid,this.smi_size,this.smi_intfsize,this.smi_ac,this.smi_vz,this.DTW_req_recd,this.DTW_rsp_expd, this.DTW_rsp_recd,this.RB_req_expd,this.RB_req_recd,this.RB_rsp_expd,this.RB_rsp_recd,this.RBRL_rsp_expd,this.RBRL_rsp_recd,this.RBU_req_expd,this.RBU_req_recd,this.RBU_rsp_expd,this.RBU_rsp_recd,this.AXI_write_addr_expd, this.AXI_write_addr_recd, this.AXI_write_data_expd, this.AXI_write_data_recd, this.AXI_write_resp_expd, this.AXI_write_resp_recd,this.wrOutstanding), UVM_LOW)
        <% if(obj.DutInfo.useCmc) { %>
          `uvm_info("<%=obj.BlockId%>:DMI_SCOREBOARD", $sformatf("%0t:t_lookup:%0t lookup:%0b|%0b, cacheWrDataExpd :%0b|%0b EvictDataExpd :%0b|%0b  isCacheHit :%0b  nackuce:%0b  cache_index :%0h ",$time, this.t_lookup,this.lookupExpd, this.lookupSeen, this.cacheWrDataExpd, this.cacheWrDataRecd, this.evictDataExpd, this.evictDataRecd, this.isCacheHit,this.nackuce, this.cache_index), UVM_LOW)
          `uvm_info("<%=obj.BlockId%>:DMI_SCOREBOARD", $sformatf("%0t:sp_txn:%0b, t_sp_seen_ctrl_chnl:%0t t_sp_seen_wr_chnl:%0t, t_sp_seen_rd_chnl:%0t, sp_index: %0h, sp_way: %0h, sp_beat_num: %0d, sp_data_bank: %0d, sp_addr: %0h",$time, this.sp_txn, this.sp_seen_ctrl_chnl, this.sp_seen_write_chnl, this.sp_seen_output_chnl, this.sp_index, this.sp_way, this.sp_beat_num, this.sp_data_bank, this.sp_addr), UVM_LOW)
        <% } %>
        end
      <% if(obj.DutInfo.useCmc) { %>
      else if(this.isEvict) begin
       `uvm_info("<%=obj.BlockId%>:DMI_SCOREBOARD", $sformatf("%0t:t_creation:%0t:UID:%0d:addr=0x%0x,sec=%0b: isEvict :%0b evictDataExpd:%0b|%0b  aw:%0b|%0b,w:%0b|%0b,b:%0b|%0b",$time, this.t_creation,txn_id,this.cache_addr,this.security,this.isEvict,this.evictDataExpd,this.evictDataRecd,this.AXI_write_addr_expd, this.AXI_write_addr_recd, this.AXI_write_data_expd, this.AXI_write_data_recd, this.AXI_write_resp_expd, this.AXI_write_resp_recd),UVM_LOW)
       `uvm_info("<%=obj.BlockId%>:DMI_SCOREBOARD", $sformatf("%0t:sp_txn:%0b, t_sp_seen_ctrl_chnl:%0t t_sp_seen_wr_chnl:%0t, t_sp_seen_rd_chnl:%0t, sp_index: %0h, sp_way: %0h, sp_beat_num: %0d, sp_data_bank: %0d, sp_addr: %0h",$time, this.sp_txn, this.sp_seen_ctrl_chnl, this.sp_seen_write_chnl, this.sp_seen_output_chnl, this.sp_index, this.sp_way, this.sp_beat_num, this.sp_data_bank, this.sp_addr), UVM_LOW)
      end
      <% } %>
      else if(this.isNcWr) begin
       `uvm_info("<%=obj.BlockId%>:DMI_SCOREBOARD", $sformatf("%0t:t_creation:%0t:UID:%0d:[aiuId:0x%0x,aiu_msg_id:0x%0x],addr=0x%0x,sec=%0b:\tcmdtye:%0x dtwtype:0x%0x rbid:%0h smi_size:%0d intfSize :%0x msg_attr_ac:%0b, msg_attr_vz:%0b isNcWr:%0b isCoh :%0b dtw_req:1|%0b dtw_rsp:%0b|%0b,cmd_rsp:%0b|%0b,cmd_rspRtl:1|%0b,str_req:%0b|%0b,str_rsp:%0b|%0b,aw:%0b|%0b,w:%0b|%0b,b:%0b|%0b",$time, this.t_creation,txn_id,this.cmd_req_pkt.smi_src_ncore_unit_id,this.cmd_req_pkt.smi_msg_id, this.cache_addr, this.security,this.smi_msg_type,this.dtw_msg_type,this.smi_rbid,this.smi_size,this.smi_intfsize,this.smi_ac,this.smi_vz,this.isNcWr,this.isCoh,this.DTW_req_recd,this.DTW_rsp_expd, this.DTW_rsp_recd,this.CMD_rsp_expd,this.CMD_rsp_recd,this.CMD_rsp_recd_rtl,this.STR_req_expd,this.STR_req_recd,this.STR_rsp_expd,this.STR_rsp_recd,this.AXI_write_addr_expd, this.AXI_write_addr_recd, this.AXI_write_data_expd, this.AXI_write_data_recd, this.AXI_write_resp_expd, this.AXI_write_resp_recd),UVM_LOW);
        <% if(obj.DutInfo.useCmc) { %>
          `uvm_info("<%=obj.BlockId%>:DMI_SCOREBOARD", $sformatf("%0t:t_lookup:%0t lookup:%0b|%0b, cacheWrDataExpd :%0b|%0b EvictDataExpd :%0b|%0b  isCacheHit :%0b  nackuce:%0b cache_index :%0h  ",$time, this.t_lookup,this.lookupExpd, this.lookupSeen, this.cacheWrDataExpd, this.cacheWrDataRecd, this.evictDataExpd, this.evictDataRecd, this.isCacheHit,this.nackuce,this.cache_index), UVM_LOW);
          `uvm_info("<%=obj.BlockId%>:DMI_SCOREBOARD", $sformatf("%0t:sp_txn:%0b, t_sp_seen_ctrl_chnl:%0t t_sp_seen_wr_chnl:%0t, t_sp_seen_rd_chnl:%0t, sp_index: %0h, sp_way: %0h, sp_beat_num: %0d, sp_data_bank: %0d, sp_addr: %0h",$time, this.sp_txn, this.sp_seen_ctrl_chnl, this.sp_seen_write_chnl, this.sp_seen_output_chnl, this.sp_index, this.sp_way, this.sp_beat_num, this.sp_data_bank, this.sp_addr), UVM_LOW)
        <% } %>
      end
      /*
        if(this.isMW && this.DTW2nd_req_recd)begin
       `uvm_info("<%=obj.BlockId%>:DMI_SCOREBOARD", $sformatf("%0t: creation:%0t:addr=0x%0x,sec=%0b:\ttype:0x%0x rbid:%0h smi_size:%0d msg_attr_ac:%0b, msg_attr_vz:%0b dtw_2ndreq:1|%0b dtw_2ndrsp:%0b|%0b,aw2nd:%0b|%0b,w2nd:%0b|%0b,b2nd:%0b|%0b wrOutstanding :%0b",$time, this.t_creation,this.cache_addr, this.security,this.dtw2nd_req_pkt.smi_msg_type,this.dtw2nd_req_pkt.smi_rbid,this.smi_size,this.smi_ac,this.smi_vz,this.DTW2nd_req_recd,this.DTW2nd_rsp_expd, this.DTW2nd_rsp_recd,this.AXI_write_2ndaddr_expd, this.AXI_write_2ndaddr_recd, this.AXI_write_2nddata_expd, this.AXI_write_2nddata_recd, this.AXI_write_2ndresp_expd, this.AXI_write_2ndresp_recd,this.wrOutstanding), UVM_LOW)
        <% if(obj.DutInfo.useCmc) { %>
          `uvm_info("<%=obj.BlockId%>:DMI_SCOREBOARD", $sformatf("%0t:t_lookup:%0t t_lookup2nd:%0t lookupcnt:%0d lookup:%0b|%0b, lookupSeen2nd:%0b cacheWrDataExpd :%0b|%0b bypassExpd :%0b|%0b  isCacheHit :%0b  nackuce:%0b  cache_index :%0h ",$time, this.t_lookup,this.t_lookup2nd,this.lookupcnt,this.lookupExpd, this.lookupSeen, this.lookupSeen2nd, this.cacheWrDataExpd, this.cacheWrDataRecd, this.bypassExpd, this.bypassSeen, this.isCacheHit,this.nackuce, this.cache_index), UVM_LOW)
          `uvm_info("<%=obj.BlockId%>:DMI_SCOREBOARD", $sformatf("%0t:sp_txn:%0b, t_sp_seen_ctrl_chnl:%0t t_sp_seen_wr_chnl:%0t, t_sp_seen_rd_chnl:%0t, sp_index: %0h, sp_way: %0h, sp_beat_num: %0d, sp_data_bank: %0d, sp_addr: %0h",$time, this.sp_txn, this.sp_seen_ctrl_chnl, this.sp_seen_write_chnl, this.sp_seen_output_chnl, this.sp_index, this.sp_way, this.sp_beat_num, this.sp_data_bank, this.sp_addr), UVM_LOW)
        <% } %>
        end
        */
        `uvm_info("<%=obj.BlockId%>:DMI_SCOREBOARD",$sformatf("smi_qos :%0x smi_priority :%0b",this.smi_qos,this.smi_msg_pri),UVM_LOW);
        if(this.MRD_req_recd)begin
          `uvm_info("<%=obj.BlockId%>:DMI_SCOREBOARD",$psprintf("MRD_REQ: %s",mrd_req_pkt.convert2string()),UVM_LOW);
        end
        if(this.MRD_rsp_recd)begin
          `uvm_info("<%=obj.BlockId%>:DMI_SCOREBOARD",$psprintf("MRD_RSP: %s",mrd_rsp_pkt.convert2string()),UVM_LOW);
        end 
        if(this.RB_req_recd)begin
          `uvm_info("<%=obj.BlockId%>:DMI_SCOREBOARD",$psprintf("RB_REQ: %s",rb_req_pkt.convert2string()),UVM_LOW);
        end
        if(this.RB_rsp_recd)begin
          `uvm_info("<%=obj.BlockId%>:DMI_SCOREBOARD",$psprintf("RB_RSP: %s",rb_rsp_pkt.convert2string()),UVM_LOW);
        end
        if(this.RBRL_req_recd)begin
          `uvm_info("<%=obj.BlockId%>:DMI_SCOREBOARD",$psprintf("RBRL_REQ: %s",rbrl_req_pkt.convert2string()),UVM_LOW);
        end
        if(this.RBRL_rsp_recd)begin
          `uvm_info("<%=obj.BlockId%>:DMI_SCOREBOARD",rb_rsp_pkt.convert2string(),UVM_LOW);
        end
        if(this.RBU_req_recd)begin
          `uvm_info("<%=obj.BlockId%>:DMI_SCOREBOARD",$psprintf("RBU_REQ: %s",rbu_req_pkt.convert2string()),UVM_LOW);
        end
        if(this.RBU_rsp_recd)begin
          `uvm_info("<%=obj.BlockId%>:DMI_SCOREBOARD",$psprintf("RBU_RSP: %s",rbu_rsp_pkt.convert2string()),UVM_LOW);
        end
        if(this.CMD_req_recd)begin
          `uvm_info("<%=obj.BlockId%>:DMI_SCOREBOARD",$psprintf("CMD_REQ: %s",cmd_req_pkt.convert2string()),UVM_LOW);
        end
        if(this.CMD_rsp_recd)begin
          `uvm_info("<%=obj.BlockId%>:DMI_SCOREBOARD",$psprintf("CMD_RSP: %s",cmd_rsp_pkt.convert2string()),UVM_LOW);
        end
        if(this.CMD_rsp_recd_rtl)begin
          `uvm_info("<%=obj.BlockId%>:DMI_SCOREBOARD",$psprintf("CMD_RSP_RTL: %s",cmd_rsp_pkt_rtl.convert2string()),UVM_LOW);
        end
        if(this.MRD_req_recd_rtl)begin
          `uvm_info("<%=obj.BlockId%>:DMI_SCOREBOARD",$psprintf("MRD_REQ_RTL: %s",mrd_req_pkt_rtl.convert2string()),UVM_LOW);
        end
        if(this.STR_req_recd)begin
          `uvm_info("<%=obj.BlockId%>:DMI_SCOREBOARD",$psprintf("STR_REQ: %s",str_req_pkt.convert2string()),UVM_LOW);
        end
        if(this.STR_rsp_recd)begin
          `uvm_info("<%=obj.BlockId%>:DMI_SCOREBOARD",$psprintf("STR_RSP: %s",str_rsp_pkt.convert2string()),UVM_LOW);
        end
        if(this.DTR_req_recd)begin
          `uvm_info("<%=obj.BlockId%>:DMI_SCOREBOARD",$psprintf("DTR_REQ: %s",dtr_req_pkt.convert2string()),UVM_LOW);
        end
        if(this.DTR_rsp_recd)begin
          `uvm_info("<%=obj.BlockId%>:DMI_SCOREBOARD",$psprintf("DTR_RSP: %s",dtr_rsp_pkt.convert2string()),UVM_LOW);
        end
        if(this.DTW_req_recd)begin
          `uvm_info("<%=obj.BlockId%>:DMI_SCOREBOARD",$psprintf("DTW_REQ: %s",dtw_req_pkt.convert2string()),UVM_LOW);
        end
        if(this.DTW_rsp_recd)begin
          `uvm_info("<%=obj.BlockId%>:DMI_SCOREBOARD",$psprintf("DTW_RSP: %s",dtw_rsp_pkt.convert2string()),UVM_LOW);
        end
        if(this.AXI_read_addr_recd)begin
          `uvm_info("<%=obj.BlockId%>:DMI_SCOREBOARD",$psprintf("AXI_READ_ADDR: %s",axi_read_addr_pkt.sprint_pkt()),UVM_LOW);
        end
        if(this.AXI_read_data_recd)begin
          `uvm_info("<%=obj.BlockId%>:DMI_SCOREBOARD",$psprintf("AXI_READ_DATA: %s",axi_read_data_pkt.sprint_pkt()),UVM_LOW);
        end
        if(this.AXI_write_addr_recd)begin
          `uvm_info("<%=obj.BlockId%>:DMI_SCOREBOARD",$psprintf("AXI_WRITE_ADDR: %s",axi_write_addr_pkt.sprint_pkt()),UVM_LOW);
        end
        if(this.AXI_write_data_recd)begin
          `uvm_info("<%=obj.BlockId%>:DMI_SCOREBOARD",$psprintf("AXI_WRITE_DATA: %s",axi_write_data_pkt.sprint_pkt()),UVM_LOW);
        end
        if(this.AXI_write_resp_recd)begin
          `uvm_info("<%=obj.BlockId%>:DMI_SCOREBOARD",$psprintf("AXI_WRITE_RSP: %s",axi_write_resp_pkt.sprint_pkt()),UVM_LOW);
        end
        <% if(obj.DutInfo.useCmc) { %>
        if(this.lookupSeen) begin
          if(cache_ctrl_pkt != null) begin
            `uvm_info("<%=obj.BlockId%>:DMI_SCOREBOARD",$psprintf("CACHE_CTRL_PKT: %s",cache_ctrl_pkt.sprint_pkt()),UVM_LOW);
          end
          else begin
            `uvm_info("<%=obj.BlockId%>:DMI_SCOREBOARD","lookupSeen was set but cache_ctrl_pkt never receieved/assigned",UVM_LOW);
          end
        end
        if(this.cacheRspRecd) begin
            `uvm_info("<%=obj.BlockId%>:DMI_SCOREBOARD",$psprintf("CACHE_RD_DATA_PKT: %s",cache_rd_data_pkt.sprint_pkt()),UVM_LOW);
        end
        if(this.cacheWrDataRecd) begin
            `uvm_info("<%=obj.BlockId%>:DMI_SCOREBOARD",$psprintf("CACHE_WR_DATA_PKT: %s",cache_wr_data_pkt.sprint_pkt()),UVM_LOW);
        end
        if(this.fillSeen) begin
            `uvm_info("<%=obj.BlockId%>:DMI_SCOREBOARD",$psprintf("CACHE_FILL_CTRL_PKT: %s",cache_fill_ctrl_pkt.sprint_pkt()),UVM_LOW);
        end
        if(this.fillDataSeen) begin
            `uvm_info("<%=obj.BlockId%>:DMI_SCOREBOARD",$psprintf("CACHE_FILL_DATA_PKT: %s",cache_fill_data_pkt.sprint_pkt()),UVM_LOW);
        end
        if(this.evictDataRecd) begin
            `uvm_info("<%=obj.BlockId%>:DMI_SCOREBOARD",$psprintf("CACHE_EVICT_DATA_PKT: %s",cache_evict_data_pkt.sprint_pkt()),UVM_LOW);
        end
        <% } %>
        if(this.seenAtReadArb) begin
            `uvm_info("<%=obj.BlockId%>:DMI_SCOREBOARD",$psprintf("READ_ARB_PKT: %s",read_arb_pkt.sprint_pkt()),UVM_LOW);
        end
        if(this.seenAtWriteArb) begin
            `uvm_info("<%=obj.BlockId%>:DMI_SCOREBOARD",$psprintf("WRITE_ARB_PKT: %s",write_arb_pkt.sprint_pkt()),UVM_LOW);
        end
    endfunction // print_entry_eos
     

   //-------------------------------------------------------------------------------------------------
   //Generation of expected AXID : CONC-13672
   //-------------------------------------------------------------------------------------------------
   function axi_arid_t gen_exp_arid(smi_addr_t m_addr);
     int bitNum = 0;
     axi_arid_t arid;

     if(addressIdMap.size() > 0 ) begin
       foreach(addressIdMap[i]) begin
         if(bitNum < WARID) begin
           arid[bitNum] = m_addr[addressIdMap[i]];
           bitNum++;
         end
       end
     end
     for(int fillBitNum = bitNum; fillBitNum < WARID; fillBitNum++) begin
       arid[fillBitNum] = m_addr[wCacheLineOffset+fillBitNum-bitNum];
     end

     return(arid);
   endfunction : gen_exp_arid

   function axi_awid_t gen_exp_awid(smi_addr_t m_addr);
      int bitNum = 0;
      axi_awid_t awid;

      if(addressIdMap.size() > 0 ) begin
        foreach(addressIdMap[i]) begin
          if(bitNum < WAWID) begin
            awid[bitNum] = m_addr[addressIdMap[i]];
            bitNum++;
          end
        end
      end
      for(int fillBitNum = bitNum; fillBitNum < WAWID; fillBitNum++) begin
        awid[fillBitNum] = m_addr[wCacheLineOffset+(fillBitNum-bitNum)];
      end

      return(awid);
   endfunction : gen_exp_awid

   function void check_entry();
      if((this.isMrd || this.isNcRd || (this.isDtwMrgMrd && !this.isDtw)) && !this.isAtmStore)begin
/////////////////////////////////////////////////////////////////////
// Check Configurable AXI fields
/////////////////////////////////////////////////////////////////////
      if (this.AXI_read_addr_recd==1) begin
//#Check.DMI.Concerto.v3.0.arlen
         if (this.axi_read_addr_pkt.arlen !== expd_arlen) begin
            `uvm_error("<%=obj.BlockId%>:DMI_SCOREBOARD", $sformatf("Unexpected value for axi.arlen expected=0x%2x,seen=0x%2x",expd_arlen,this.axi_read_addr_pkt.arlen))
         end
//#Check.DMI.Concerto.v3.0.arsize
         if (this.axi_read_addr_pkt.arsize != expd_arsize) begin
            `uvm_error("<%=obj.BlockId%>:DMI_SCOREBOARD", $sformatf("Unexpected value for axi.arsize expected=0x%2x,seen=0x%2x",expd_arsize,this.axi_read_addr_pkt.arsize))
         end
//#Check.DMI.Concerto.v3.0.arburst
         if (this.axi_read_addr_pkt.arburst != expd_arburst) begin 
            `uvm_error("<%=obj.BlockId%>:DMI_SCOREBOARD", $sformatf("Unexpected value for axi.arburst expected=0x%2x,seen=0x%2x",expd_arburst,this.axi_read_addr_pkt.arburst))
         end
      if(this.isMrd)begin
        if (this.axi_read_addr_pkt.arlock !== 0) begin
           `uvm_error("<%=obj.BlockId%>:DMI_SCOREBOARD", $sformatf("AXI arlock: %s Mrd SMI lock: 0",this.axi_read_addr_pkt.arlock))
        end
      end
      else if(this.isDtwMrgMrd)begin
        if (this.axi_read_addr_pkt.arlock !== 0) begin
           `uvm_error("<%=obj.BlockId%>:DMI_SCOREBOARD", $sformatf("AXI arlock: %s DrwMrg SMI lock: 0",this.axi_read_addr_pkt.arlock,0))
        end
      end
      else if(this.isNcRd && !this.isAtomic)begin
        if ((this.axi_read_addr_pkt.arlock !== this.cmd_req_pkt.smi_es) && (exmon_size == 0)) begin // if exmon is enabled => DMI send arlock = 0
           `uvm_error("<%=obj.BlockId%>:DMI_SCOREBOARD", $sformatf("AXI arlock: %s  NcCmd SMI lock: %s",this.axi_read_addr_pkt.arlock, this.cmd_req_pkt.smi_es))
        end
      end
        if (WUSEACECACHE) begin
         //  if (this.axi_read_addr_pkt.arcache !== axi_arcache_enum_t'(this.mrd_req_pkt.smi_cache)) begin 
         //     `uvm_error("<%=obj.BlockId%>:DMI_SCOREBOARD", $sformatf("AXI arcache: %p SMI cache: %p",this.axi_read_addr_pkt.arcache, this.mrd_req_pkt.cache))
         //  end
        end
        if (WUSEACEPROT) begin
          // if (this.axi_read_addr_pkt.arprot !== axi_axprot_t'(this.mrd_req_pkt.ace.prot)) begin 
          //    `uvm_error("<%=obj.BlockId%>:DMI_SCOREBOARD", $sformatf("AXI arprot: 0x%x SMI prot: 0x%x",this.axi_read_addr_pkt.arprot, this.mrd_req_pkt.ace.prot))
          // end
        end
        //#Check.DMI.Concerto.v3.0.arqos
<%if (obj.DmiInfo[obj.Id].fnEnableQos) { %>
           if (this.axi_read_addr_pkt.arqos !== this.smi_qos) begin
             `uvm_error("<%=obj.BlockId%>:DMI_SCOREBOARD", $sformatf("AXI ARQOS: 0x%x SMI qos: 0x%x",this.axi_read_addr_pkt.arqos, this.smi_qos))
           end
<% }else{ %>
           if (this.axi_read_addr_pkt.arqos !== 0) begin
             `uvm_error("<%=obj.BlockId%>:DMI_SCOREBOARD", $sformatf("AXI ARQOS: 0x%x SMI qos: 0",this.axi_read_addr_pkt.arqos))
           end
<% } %>
<%if (obj.wSecurityAttribute > 0) { %>
         //arprot[1] = sec
         //#Check.DMI.Concerto.v3.0.arsecurity
         if (this.axi_read_addr_pkt.arprot[1] !== this.security) begin
               `uvm_error("<%=obj.BlockId%>:DMI_SCOREBOARD", $sformatf("AXI Prot[1]: 0x%x SMI security: 0x%x",this.axi_read_addr_pkt.arprot[1], this.security))
         end
<% } %>
         //#Check.DMI.Concerto.v3.0.arprivilege
         if (this.axi_read_addr_pkt.arprot[0] !== this.privileged) begin
               `uvm_error("<%=obj.BlockId%>:DMI_SCOREBOARD", $sformatf("AXI Prot[0]: 0x%x (should be %0x)",this.axi_read_addr_pkt.arprot[0],this.privileged))
         end
         if (this.axi_read_addr_pkt.arprot[2] !== 0) begin
               `uvm_error("<%=obj.BlockId%>:DMI_SCOREBOARD", $sformatf("AXI Prot[2]: 0x%x (should be 0)",this.axi_read_addr_pkt.arprot[2]))
         end

         if (WUSEACEUSER) begin
           if(isMrd)begin
              // ARUSER should be equal to RUSER this really checks the memory model
              //#Check.DMI.Concerto.v3.0.aruser
              if (this.axi_read_addr_pkt.aruser !== axi_aruser_t'(this.mrd_req_pkt.smi_ndp_aux)) begin
                 `uvm_error("<%=obj.BlockId%>:DMI_SCOREBOARD", $sformatf("AXI aruser: 0x%0x AXI ruser: 0x%0x",this.axi_read_addr_pkt.aruser, this.mrd_req_pkt.smi_ndp_aux))
              end
           end // if (WUSEACEUSER)
         end // if (WUSEACEUSER)
      end // if (this.AXI_read_addr_recd==1)
/////////////////////////////////////////////////////////////////////
// Check MRD -> DTR type match
/////////////////////////////////////////////////////////////////////
// No CCP
// eMrdRdWithShrCln -> eDtrDataShrCln
// eMrdRdWithUnqCln -> eDtrDataUnqCln 
// eMrdRdWithUnq    -> eDtrDataUnqCl
// eMrdRdWithInv    -> eDtrDataInv
// eMrdRdFlsh       -> TBD     
// eMrdFlush        -> TBD
////////////////////////////////////////////////////////////////////
//#Check.DMI.Concerto.v3.0.DTRType     
      if(this.isMrd && !this.nackuce)begin
        if(this.mrd_req_pkt.smi_msg_type ==  MRD_RD_WITH_SHR_CLN)begin
          if(this.dtr_req_pkt.smi_msg_type !== DTR_DATA_SHR_CLN) begin
             `uvm_error("<%=obj.BlockId%>:DMI_SCOREBOARD",$sformatf("For a MRD type:eMrdRdWithShrCln:%0x, expd DTR type:eDtrDataShrCln:%0x seen DTR type:0x%0x",MRD_RD_WITH_SHR_CLN,DTR_DATA_SHR_CLN,this.dtr_req_pkt.smi_msg_type));
          end
        end
        if(this.mrd_req_pkt.smi_msg_type ==   MRD_RD_WITH_UNQ_CLN)begin
          if(this.dtr_req_pkt.smi_msg_type !== DTR_DATA_UNQ_CLN) begin
             `uvm_error("<%=obj.BlockId%>:DMI_SCOREBOARD",$sformatf("For a MRD type:eMrdRdWithUnqCln:%0x, expd DTR type:eDtrDataUnqCln:%0x seen DTR type:0x%0x",MRD_RD_WITH_UNQ_CLN,DTR_DATA_UNQ_CLN,this.dtr_req_pkt.smi_msg_type));
          end
        end
        if(this.mrd_req_pkt.smi_msg_type ==  MRD_RD_WITH_UNQ)begin
            if(this.dtr_req_pkt.smi_msg_type !== DTR_DATA_UNQ_CLN) begin
               `uvm_error("<%=obj.BlockId%>:DMI_SCOREBOARD",$sformatf("For a MRD type: eMrdRdWithUnq:%0x, expd DTR type:eDtrDataUnqCln:%0x seen DTR type:0x%0x",MRD_RD_WITH_UNQ,DTR_DATA_UNQ_CLN,this.dtr_req_pkt.smi_msg_type));
            end
        end
        if(this.mrd_req_pkt.smi_msg_type ==  MRD_RD_WITH_INV)begin
          if(this.dtr_req_pkt.smi_msg_type !== DTR_DATA_INV) begin
             `uvm_error("<%=obj.BlockId%>:DMI_SCOREBOARD",$sformatf("For a MRD type:eMrdRdWithInv:%0x, expd DTR type:eDtrDataInv:%0x seen DTR type:0x%0x",MRD_RD_WITH_INV,DTR_DATA_INV,this.dtr_req_pkt.smi_msg_type));
          end
        end
/////////////////////////////////////////////////////////////////////
// Check message types match protocol encodings
/////////////////////////////////////////////////////////////////////
      if(!(this.mrd_req_pkt.isMrdMsg())) begin
         `uvm_error("<%=obj.BlockId%>:DMI_SCOREBOARD", $sformatf("MRD_req msg type incorrect received:0x%s",this.mrd_req_pkt.smi_msg_type))
      end
      //#Check.DMI.DTRReqFields
      //#Check.DMI.DtrReqSMIFields
    if(!(this.mrd_req_pkt.smi_msg_type inside {MRD_FLUSH,MRD_INV,MRD_CLN,MRD_PREF}))begin
      if(!this.dtr_req_pkt.isDtrMsg()) begin
         `uvm_error("<%=obj.BlockId%>:DMI_SCOREBOARD", $sformatf("DTR_req msg type incorrect received=0x%s",this.mrd_req_pkt.smi_msg_type))
      end
      if (this.dtr_req_pkt.smi_targ_ncore_unit_id !== this.dtr_targ_unit_id) begin
         `uvm_error("<%=obj.BlockId%>:DMI_SCOREBOARD", $sformatf("DTR smi_targ_id : 0x%0x MRD req aiu ID: 0x%0x",this.dtr_req_pkt.smi_targ_ncore_unit_id, this.dtr_targ_unit_id))
      end
      if (this.dtr_req_pkt.smi_targ_ncore_unit_id !== this.dtr_targ_unit_id) begin
         `uvm_error("<%=obj.BlockId%>:DMI_SCOREBOARD", $sformatf("DTR smi_targ_id : 0x%0x MRD req aiu ID: 0x%0x",this.dtr_req_pkt.smi_targ_ncore_unit_id, this.dtr_targ_unit_id))
      end
      if (this.dtr_req_pkt.smi_rmsg_id !== this.dtr_rmsg_id_expd) begin
         `uvm_error("<%=obj.BlockId%>:DMI_SCOREBOARD", $sformatf("DTR smi_rmsg_id : 0x%0x MRD req smi_msg_id ID: 0x%0x",this.dtr_req_pkt.smi_rmsg_id, this.dtr_rmsg_id_expd))
      end
    end
  ////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////
// Check appropriate message types received
/////////////////////////////////////////////////////////////////////
      if((this.MRD_rsp_expd===1)&&(this.MRD_rsp_recd===0)) begin
         `uvm_error("<%=obj.BlockId%>:DMI_SCOREBOARD", $sformatf("MRD_rsp not received"))
      end
     end
////////////////////////////////////////////////////////////////
// DtwMrgMrd -> Dtr
///////////////////////////////////////////////////////////////
// eDtwMrgMRDInv -> eDtrDataInv
// eDtwMrgMrdSCln (Reserved v3.0)
// eDtwMrgMrdSDty (Reserved v3.0)
// eDtwMrgMRDUCln -> eDtrDataUnqCln
// eDtwMrgMRDUDty -> eDtrDataUnqDty
///////////////////////////////////////////////////////////////
     if(this.isDtwMrgMrd && this.DTR_req_expd && this.DTR_req_recd)begin
        if (this.dtr_req_pkt.smi_dp_data.size !== this.expd_dtr_beats) begin
           `uvm_error("<%=obj.BlockId%>:DMI_SCOREBOARD", $sformatf("DTR length:0x%0x expd:0x%0x", this.dtr_req_pkt.smi_dp_data.size,this.expd_dtr_beats ))
        end
        // Check on smi_rl field, CONC-4800
        if ((this.dtw_req_pkt.smi_rl == 'b11) ? !(this.dtr_req_pkt.smi_rl == 'b11) : !(this.dtr_req_pkt.smi_rl inside {'b01, 'b10})) begin
           `uvm_error("<%=obj.BlockId%>:DMI_SCOREBOARD", $sformatf("dtr_req_pkt.smi_rl mismatch for a DtwMrgMrd txn dtw_smi_rl %0b dtr_smi_rl %0b",
                                                                   this.dtw_req_pkt.smi_rl,this.dtr_req_pkt.smi_rl))
        end
        if(this.dtw_req_pkt.smi_msg_type ==  DTW_MRG_MRD_INV)begin
          if(this.dtr_req_pkt.smi_msg_type !== DTR_DATA_INV) begin
             `uvm_error("<%=obj.BlockId%>:DMI_SCOREBOARD",$sformatf("For a DtwMrgMrd type:eDtwMrgMRDInv:%0x, expd DTR type:eDtrDataInv:%0x seen DTR type:0x%0x",DTW_MRG_MRD_INV,DTR_DATA_INV,this.dtr_req_pkt.smi_msg_type));
          end
        end
        if(this.dtw_req_pkt.smi_msg_type ==  DTW_MRG_MRD_UCLN)begin
          if(this.dtr_req_pkt.smi_msg_type !== DTR_DATA_UNQ_CLN ) begin
             `uvm_error("<%=obj.BlockId%>:DMI_SCOREBOARD",$sformatf("For a DtwMrgMrd type:eDtwMrgMRDUCln:%0x, expd DTR type:eDtrDataUnqCln:%0x seen DTR type:0x%0x",DTW_MRG_MRD_UCLN,DTR_DATA_UNQ_CLN,this.dtr_req_pkt.smi_msg_type));
          end
        end
        if(this.dtw_req_pkt.smi_msg_type == DTW_MRG_MRD_UDTY)begin
          if(this.dtr_req_pkt.smi_msg_type !== DTR_DATA_UNQ_DTY) begin
             `uvm_error("<%=obj.BlockId%>:DMI_SCOREBOARD",$sformatf("For a DtwMrgMrd type:eDtwMrgMRDUDty:%0x, expd DTR type:eDtrDataUnqDty:%0x seen DTR type:0x%0x",DTW_MRG_MRD_UDTY,DTR_DATA_UNQ_DTY,this.dtr_req_pkt.smi_msg_type));
          end
        end
     end
     //#Check.DMI.Concerto.v3.0.NcDtrMsgType
     if(isNcRd && this.DTR_req_expd && this.DTR_req_recd)begin
        if(this.cmd_req_pkt.smi_msg_type ==  CMD_RD_NC)begin
          if(this.dtr_req_pkt.smi_msg_type !== DTR_DATA_INV) begin
             `uvm_error("<%=obj.BlockId%>:DMI_SCOREBOARD",$sformatf("For a Nc Cmd type:eCmdRdNC:%0x, expd DTR type:eDtrDataInv:%0x seen DTR type:0x%0x",CMD_RD_NC,DTR_DATA_INV,this.dtr_req_pkt.smi_msg_type));
          end
        end
     end
      if((this.AXI_read_addr_expd===1)&&(this.AXI_read_addr_recd===0)) begin
         `uvm_error("<%=obj.BlockId%>:DMI_SCOREBOARD", $sformatf("AXI_read_addr not received"))
      end
      if((this.AXI_read_data_expd===1)&&(this.AXI_read_data_recd===0)) begin
         `uvm_error("<%=obj.BlockId%>:DMI_SCOREBOARD", $sformatf("axi_read_data not received"))
      end
      if((this.DTR_req_expd===1)&&(this.DTR_req_recd===0)) begin
         `uvm_error("<%=obj.BlockId%>:DMI_SCOREBOARD", $sformatf("DTR_req not received"))
      end
      if((this.DTR_rsp_expd===1)&&(this.DTR_rsp_recd===0)) begin
         `uvm_error("<%=obj.BlockId%>:DMI_SCOREBOARD", $sformatf("DTR_rsp not received"))
      end
      if((this.cacheRspExpd===1)&&(this.cacheRspRecd===0)) begin
         `uvm_error("<%=obj.BlockId%>:DMI_SCOREBOARD", $sformatf("cacheRsp not received"))
      end
   //#Check.DMI.Concerto.v3.0.DtrReqDataIntegrity  
     if(this.DTR_req_expd && this.DTR_req_recd ) begin
         if(smi_msg_type == CMD_CMP_ATM)begin
           this.num_bytes = (2**smi_size/2);
         end
         else begin
           this.num_bytes = 2**smi_size;
         end
         `uvm_info("<%=obj.BlockId%>:DMI_SCOREBOARD", $sformatf("num_bytes :%0d",this.num_bytes),UVM_MEDIUM)
        if(this.DTR_req_expd && this.DTR_req_recd) begin
         if(this.isDtwMrgMrd) begin
           if (this.dtr_req_pkt.smi_dp_data.size !== this.expd_dtr_beats) begin
              `uvm_error("<%=obj.BlockId%>:DMI_SCOREBOARD", $sformatf("DtwMrgMrd DTR length:0x%0x expd:0x%0x", this.dtr_req_pkt.smi_dp_data.size,this.expd_dtr_beats ))
           end
         end
         if(this.isAtomic) begin
           if(this.dtr_req_pkt.smi_msg_type !== DTR_DATA_INV) begin
              `uvm_error("<%=obj.BlockId%>:DMI_SCOREBOARD",$sformatf("For a Atomic type:%0x, expd DTR type:eDtrDataInv:%0x seen DTR type:0x%0x",this.smi_msg_type,DTR_DATA_INV,this.dtr_req_pkt.smi_msg_type));
           end
         end
        //#Check.DMI.Concerto.v3.0.DtrByteSizeAtomicCmp
           if(this.dtr_req_pkt.smi_dp_data.size() != this.dtr_req_pkt_exp.smi_dp_data.size())begin
             `uvm_error("<%=obj.BlockId%>:DMI_SCOREBOARD", $sformatf("DTR length:0x%0x expd:0x%0x", this.dtr_req_pkt.smi_dp_data.size(),this.dtr_req_pkt_exp.smi_dp_data.size()))
           end
        //#Check.DMI.Concerto.v3.0.DtrDataAtomicLdCmpSwp
         dwid_cnt = 0;
           foreach(this.dtr_req_pkt.smi_dp_data[i]) begin
               this.dtr_data_recd[WXDATA*i +:WXDATA]                         = this.dtr_req_pkt.smi_dp_data[i]; 
               this.dtr_data_exp[WXDATA*i +:WXDATA]                          = this.dtr_req_pkt_exp.smi_dp_data[i]; 
               this.dtr_data_dbad_recd[(WXDATA/64)*i +:(WXDATA/64)]           = this.dtr_req_pkt.smi_dp_dbad[i]; 
               this.dtr_data_dbad_exp[(WXDATA/64)*i +:(WXDATA/64)]            = this.dtr_req_pkt_exp.smi_dp_dbad[i]; 
               this.dtr_data_dwid_recd[WSMIDPDWIDPERDW*(WXDATA/64)*i +:WSMIDPDWIDPERDW*(WXDATA/64)]  = this.dtr_req_pkt.smi_dp_dwid[i]; 
               this.dtr_data_dwid_exp[WSMIDPDWIDPERDW*(WXDATA/64)*i +:WSMIDPDWIDPERDW*(WXDATA/64)]   = this.dtr_req_pkt_exp.smi_dp_dwid[i]; 
              `uvm_info("<%=obj.BlockId%>:DMI_SCOREBOARD", $sformatf("data Beat # %0d dtr_req_pkt          :%0x dtr_req_pkt_exp       :%0x",i,this.dtr_req_pkt.smi_dp_data[i],this.dtr_req_pkt_exp.smi_dp_data[i]), UVM_MEDIUM);
              `uvm_info("<%=obj.BlockId%>:DMI_SCOREBOARD", $sformatf("data Beat # %0d dtr_data_recd        :%0x dtr_data_exp          :%0x",i,this.dtr_data_recd,this.dtr_data_exp), UVM_MEDIUM);
              `uvm_info("<%=obj.BlockId%>:DMI_SCOREBOARD", $sformatf("data Beat # %0d dtr_req_pkt_dbad     :%0x dtr_req_pkt_dbad_exp  :%0x",i,this.dtr_req_pkt.smi_dp_dbad[i],this.dtr_req_pkt_exp.smi_dp_dbad[i]), UVM_MEDIUM);
              `uvm_info("<%=obj.BlockId%>:DMI_SCOREBOARD", $sformatf("data Beat # %0d dtr_data_dbad_recd   :%0x dtr_data_dbad_exp     :%0x",i,this.dtr_data_dbad_recd,this.dtr_data_dbad_exp), UVM_MEDIUM);
              `uvm_info("<%=obj.BlockId%>:DMI_SCOREBOARD", $sformatf("data Beat # %0d dtr_req_pkt_dwid     :%0x dtr_req_pkt_dwid_exp  :%0x",i,this.dtr_req_pkt.smi_dp_dwid[i],this.dtr_req_pkt_exp.smi_dp_dwid[i]), UVM_MEDIUM);
              `uvm_info("<%=obj.BlockId%>:DMI_SCOREBOARD", $sformatf("data Beat # %0d dtr_data_dwid_recd   :%0x dtr_data_dwid_exp     :%0x",i,this.dtr_data_dwid_recd,this.dtr_data_dwid_exp), UVM_MEDIUM);
           end
// Fix for the JIRA CONC-10784, where in the the ACE stimulus at FSYS was updated to randomize the cache_addr[5:0], earlier it was hardcoded to 0
// With the updated stimulus, DMI was receiving a MRd / NcRd with unaligned address and data size less than cacheline(64B).
// byte_idx needed update based on the native intfsize and the data_size to compare only the databytes which contained the actual data.
         if((2**this.smi_intfsize > WXDATA/64) && (this.num_bytes <=(2**this.smi_intfsize*8)))begin
           if(this.smi_intfsize == 1)begin
             `uvm_info("<%=obj.BlockId%>:DMI_SCOREBOARD Print0", $sformatf("cache_addr[3:0] : %0x smi_intfsize : %0d num_bytes : %0d",cache_addr[3:0], this.smi_intfsize, this.num_bytes), UVM_MEDIUM);
             for(int id = 0; id < this.num_bytes; id++) begin
               case(this.num_bytes) 
                   1 : byte_idx = cache_addr[3:0] + id;
                   2 : byte_idx = (cache_addr[3:0] & (4'b1110)) +id;
                   4 : byte_idx = (cache_addr[3:0] & (4'b1100)) +id;
                   8 : byte_idx = (cache_addr[3:0] & (4'b1000)) +id;
                   default : byte_idx = cache_addr[3:0] + id;
               endcase
               //dwid_cnt = (cache_addr[3:0] + id)/8; 
               dwid_cnt = byte_idx/8; 
               if(this.dtr_data_dwid_recd[dwid_cnt*WSMIDPDWIDPERDW +:WSMIDPDWIDPERDW] != this.dtr_data_dwid_exp[dwid_cnt*WSMIDPDWIDPERDW +:WSMIDPDWIDPERDW])begin
                 `uvm_error("<%=obj.BlockId%>:DMI_SCOREBOARD Print0", $sformatf("dword:%0d DTR dwid Exp :%0x Recd :%0x",dwid_cnt,this.dtr_data_dwid_exp[dwid_cnt*WSMIDPDWIDPERDW +:WSMIDPDWIDPERDW],this.dtr_data_dwid_recd[dwid_cnt*WSMIDPDWIDPERDW +:WSMIDPDWIDPERDW]))
               end
               if(this.dtr_data_dbad_recd[dwid_cnt] != this.dtr_data_dbad_exp[dwid_cnt])begin
                 `uvm_info("<%=obj.BlockId%>:DMI_SCOREBOARD Print0", $sformatf("Exp:%0p Recd:%0p",this.dtr_data_dbad_exp,this.dtr_data_dbad_recd),UVM_DEBUG)
                 `uvm_error("<%=obj.BlockId%>:DMI_SCOREBOARD Print0", $sformatf("dword:%0d DTR dbad Exp :%0x Recd :%0x",dwid_cnt,this.dtr_data_dbad_exp[dwid_cnt],this.dtr_data_dbad_recd[dwid_cnt]))
               end
               if(this.dtr_data_recd[byte_idx*8+:8] == this.dtr_data_exp[byte_idx*8+:8]) begin
                  `uvm_info("<%=obj.BlockId%>:DMI_SCOREBOARD Print0", $sformatf("data matches! Byte id:%0d byte#(byte_idx):%0d dtr_data_recd :%0x dtr_data_exp :%0x",id,byte_idx,this.dtr_data_recd[byte_idx*8+:8],this.dtr_data_exp[byte_idx*8+:8]), UVM_MEDIUM)
               end
               else begin
                if(!this.dtr_data_dbad_recd[dwid_cnt])begin
                  `uvm_info("<%=obj.BlockId%>:DMI_SCOREBOARD Print0", $sformatf("dtr_data_exp :%0x dtr_data_recd :%0x",this.dtr_data_exp,this.dtr_data_recd), UVM_MEDIUM);
                  `uvm_error("<%=obj.BlockId%>:DMI_SCOREBOARD Print0", $sformatf("byte # :%0d byte#(byte_idx):%0d DTR data not matching Exp :%0x Recd :%0x",id,byte_idx,this.dtr_data_exp[byte_idx*8+:8],this.dtr_data_recd[byte_idx*8+:8]))
                end
               end
             end
           end
           else if(this.smi_intfsize == 2)begin
             `uvm_info("<%=obj.BlockId%>:DMI_SCOREBOARD Print1", $sformatf("cache_addr[4:0] : %0x smi_intfsize : %0d num_bytes : %0d",cache_addr[4:0], this.smi_intfsize, this.num_bytes), UVM_MEDIUM);
             for(int id = 0; id < this.num_bytes; id++) begin
               case(this.num_bytes) 
                  1  : byte_idx = cache_addr[4:0] + id;
                  2  : byte_idx = (cache_addr[4:0] & (5'b11110)) +id;
                  4  : byte_idx = (cache_addr[4:0] & (5'b11100)) +id;
                  8  : byte_idx = (cache_addr[4:0] & (5'b11000)) +id;
                  16 : byte_idx = (cache_addr[4:0] & (5'b10000)) +id;
                  default : byte_idx = cache_addr[4:0] + id;
               endcase
               //dwid_cnt = (cache_addr[4:0] + id)/8; 
               dwid_cnt = byte_idx/8; 
               if(this.dtr_data_dwid_recd[dwid_cnt*WSMIDPDWIDPERDW +:WSMIDPDWIDPERDW] != this.dtr_data_dwid_exp[dwid_cnt*WSMIDPDWIDPERDW +:WSMIDPDWIDPERDW])begin
                 `uvm_error("<%=obj.BlockId%>:DMI_SCOREBOARD Print1", $sformatf("dword:%0d DTR dwid Exp :%0x Recd :%0x",dwid_cnt,this.dtr_data_dwid_exp[dwid_cnt*WSMIDPDWIDPERDW +:WSMIDPDWIDPERDW],this.dtr_data_dwid_recd[dwid_cnt*WSMIDPDWIDPERDW +:WSMIDPDWIDPERDW]))
               end
               if(this.dtr_data_dbad_recd[dwid_cnt] != this.dtr_data_dbad_exp[dwid_cnt])begin
                 `uvm_info("<%=obj.BlockId%>:DMI_SCOREBOARD Print1", $sformatf("Exp:%0p Recd:%0p",this.dtr_data_dbad_exp,this.dtr_data_dbad_recd),UVM_DEBUG)
                 `uvm_error("<%=obj.BlockId%>:DMI_SCOREBOARD Print1", $sformatf("dword:%0d DTR dbad Exp :%0x Recd :%0x",dwid_cnt,this.dtr_data_dbad_exp[dwid_cnt],this.dtr_data_dbad_recd[dwid_cnt]))
               end
               if(this.dtr_data_recd[byte_idx*8+:8] == this.dtr_data_exp[byte_idx*8+:8]) begin
                  `uvm_info("<%=obj.BlockId%>:DMI_SCOREBOARD Print1", $sformatf("data matches! Byte id:%0d byte#(byte_idx):%0d dtr_data_recd :%0x dtr_data_exp :%0x",id,byte_idx,this.dtr_data_recd[byte_idx*8+:8],this.dtr_data_exp[byte_idx*8+:8]), UVM_MEDIUM)
               end
               else begin
                if(!this.dtr_data_dbad_recd[dwid_cnt])begin
                  `uvm_info("<%=obj.BlockId%>:DMI_SCOREBOARD Print1", $sformatf("dtr_data_exp :%0x dtr_data_recd :%0x",this.dtr_data_exp,this.dtr_data_recd), UVM_MEDIUM);
                  `uvm_error("<%=obj.BlockId%>:DMI_SCOREBOARD Print1", $sformatf("byte # :%0d byte#(byte_idx):%0d DTR data not matching Exp :%0x Recd :%0x",id,byte_idx,this.dtr_data_exp[byte_idx*8+:8],this.dtr_data_recd[byte_idx*8+:8]))
                end
               end
             end
           end
          end
          else begin
            if(this.num_bytes >=(2**this.smi_intfsize*8))begin
                for(int id = 0; id < this.num_bytes; id++) begin
                  dwid_cnt = id/8; 
                 if(this.dtr_data_dwid_recd[dwid_cnt*WSMIDPDWIDPERDW +:WSMIDPDWIDPERDW] != this.dtr_data_dwid_exp[dwid_cnt*WSMIDPDWIDPERDW +:WSMIDPDWIDPERDW])begin
                   `uvm_error("<%=obj.BlockId%>:DMI_SCOREBOARD Print2", $sformatf("dword:%0d DTR dwid Exp :%0x Recd :%0x",dwid_cnt,this.dtr_data_dwid_exp[dwid_cnt*WSMIDPDWIDPERDW +:WSMIDPDWIDPERDW],this.dtr_data_dwid_recd[dwid_cnt*WSMIDPDWIDPERDW +:WSMIDPDWIDPERDW]))
                 end
                  if(this.dtr_data_dbad_recd[dwid_cnt] != this.dtr_data_dbad_exp[dwid_cnt])begin
                    `uvm_info("<%=obj.BlockId%>:DMI_SCOREBOARD Print2", $sformatf("Exp:%0p Recd:%0p",this.dtr_data_dbad_exp,this.dtr_data_dbad_recd),UVM_DEBUG)
                    `uvm_error("<%=obj.BlockId%>:DMI_SCOREBOARD Print2", $sformatf("dword:%0d DTR dbad Exp :%0x Recd :%0x",dwid_cnt,this.dtr_data_dbad_exp[dwid_cnt],this.dtr_data_dbad_recd[dwid_cnt]))
                  end
                  if(this.dtr_data_recd[(id)*8+:8] == this.dtr_data_exp[(id)*8+:8]) begin
                     `uvm_info("<%=obj.BlockId%>:DMI_SCOREBOARD Print2", $sformatf("data matches! Byte id:%0d dtr_data_recd :%0x dtr_data_exp :%0x",id,this.dtr_data_recd[id*8+:8],this.dtr_data_exp[(id)*8+:8]), UVM_MEDIUM)
                  end
                  else begin
                   if(!this.dtr_data_dbad_recd[dwid_cnt])begin
                     `uvm_info("<%=obj.BlockId%>:DMI_SCOREBOARD Print2", $sformatf("dtr_data_exp :%0x dtr_data_recd :%0x",this.dtr_data_exp,this.dtr_data_recd), UVM_MEDIUM);
                     `uvm_error("<%=obj.BlockId%>:DMI_SCOREBOARD Print2", $sformatf("byte # :%0d DTR data not matching Exp :%0x Recd :%0x",id,this.dtr_data_exp[(id)*8+:8],this.dtr_data_recd[(id)*8+:8]))
                   end
                  end
                end
            end
            else begin
// Fix for the JIRA CONC-10768, where in the the CHI stimulus at FSYS was updated to randomize the cache_addr[5:0], earlier it was hardcoded to 0
// With the updated stimulus, DMI was receiving a MRd / NcRd with unaligned address and data size less than cacheline(64B).
// byte_idx needed update based on the native intfsize and the data_size to compare only the databytes which contained the actual data.
                for(int id = 0; id < this.num_bytes; id++) begin
                  dwid_cnt = id/8; 
                  if(this.smi_intfsize == 0)begin
                   byte_idx = cache_addr[2:0] + id;
                  end
                  else if(this.smi_intfsize == 1)begin
                    //byte_idx = cache_addr[3:0] +id;
                    case(this.num_bytes) 
                       1 : byte_idx = cache_addr[3:0] + id;
                       2 : byte_idx = (cache_addr[3:0] & (4'b1110)) +id;
                       4 : byte_idx = (cache_addr[3:0] & (4'b1100)) +id;
                       8 : byte_idx = (cache_addr[3:0] & (4'b1000)) +id;
                       default : byte_idx = cache_addr[3:0] + id;
                    endcase 
                  end
                  else if(this.smi_intfsize == 2)begin
                   //byte_idx = cache_addr[4:0] +id;
                    case(this.num_bytes) 
                       1  : byte_idx = cache_addr[4:0] + id;
                       2  : byte_idx = (cache_addr[4:0] & (5'b11110)) +id;
                       4  : byte_idx = (cache_addr[4:0] & (5'b11100)) +id;
                       8  : byte_idx = (cache_addr[4:0] & (5'b11000)) +id;
                       16 : byte_idx = (cache_addr[4:0] & (5'b10000)) +id;
                       default : byte_idx = cache_addr[4:0] + id;
                    endcase
                  end
                  if(this.dtr_data_dwid_recd[dwid_cnt*WSMIDPDWIDPERDW +:WSMIDPDWIDPERDW] != this.dtr_data_dwid_exp[dwid_cnt*WSMIDPDWIDPERDW +:WSMIDPDWIDPERDW])begin
                    `uvm_error("<%=obj.BlockId%>:DMI_SCOREBOARD Print3", $sformatf("dword:%0d DTR dwid Exp :%0x Recd :%0x",dwid_cnt,this.dtr_data_dwid_exp[dwid_cnt*WSMIDPDWIDPERDW +:WSMIDPDWIDPERDW],this.dtr_data_dwid_recd[dwid_cnt*WSMIDPDWIDPERDW +:WSMIDPDWIDPERDW]))
                  end
                  if(this.dtr_data_dbad_recd[dwid_cnt] != this.dtr_data_dbad_exp[dwid_cnt])begin
                    `uvm_info("<%=obj.BlockId%>:DMI_SCOREBOARD Print3", $sformatf("Exp:%0p Recd:%0p",this.dtr_data_dbad_exp,this.dtr_data_dbad_recd),UVM_DEBUG)
                    `uvm_error("<%=obj.BlockId%>:DMI_SCOREBOARD Print3", $sformatf("dword:%0d DTR dbad Exp :%0x Recd :%0x",dwid_cnt,this.dtr_data_dbad_exp[dwid_cnt],this.dtr_data_dbad_recd[dwid_cnt]))
                  end
                  if(this.dtr_data_recd[byte_idx*8+:8] == this.dtr_data_exp[byte_idx*8+:8]) begin
                     `uvm_info("<%=obj.BlockId%>:DMI_SCOREBOARD Print3", $sformatf("data matches! Byte id:%0d dtr_data_recd :%0x dtr_data_exp :%0x",byte_idx,this.dtr_data_recd[byte_idx*8+:8],this.dtr_data_exp[byte_idx*8+:8]), UVM_MEDIUM)
                  end
                  else begin
                   if(!this.dtr_data_dbad_recd[dwid_cnt])begin
                     `uvm_info("<%=obj.BlockId%>:DMI_SCOREBOARD Print3", $sformatf("cache_addr[5:0] : %0x smi_intfsize : %0d num_bytes : %0d",cache_addr[5:0], this.smi_intfsize, this.num_bytes), UVM_MEDIUM);
                     `uvm_info("<%=obj.BlockId%>:DMI_SCOREBOARD Print3", $sformatf("dtr_data_exp :%0x dtr_data_recd :%0x",this.dtr_data_exp,this.dtr_data_recd), UVM_MEDIUM);
                     `uvm_error("<%=obj.BlockId%>:DMI_SCOREBOARD Print3", $sformatf("byte # :%0d DTR data not matching Exp :%0x Recd :%0x",byte_idx,this.dtr_data_exp[byte_idx*8+:8],this.dtr_data_recd[byte_idx*8+:8]))
                   end
                  end
                end
            end
          end
       end
     end

<% if(obj.DutInfo.useCmc) { %>
      //#Check.DMI.v2.RDataMatchesFill
      
      if (this.fillDataExpd == 1 && this.fillDataSeen == 1 && !this.isAtomic ) begin
            for (i=0;i<$size(this.cache_fill_data_pkt.data);i++) begin
                   data_beat = this.cache_fill_data_pkt.addr[LINE_INDEX_H:LINE_INDEX_L]+i;
                  `uvm_info("<%=obj.BlockId%>:DMI_SCOREBOARD",$sformatf("i :%0d Expected beatn :%0d  Recd beatn :%0d",i,data_beat,this.cache_fill_data_pkt.beatn[i]),UVM_MEDIUM);
                   data_beat = this.cache_fill_data_pkt.addr[LINE_INDEX_H:LINE_INDEX_L]+i;
                  `uvm_info("<%=obj.BlockId%>:DMI_SCOREBOARD",$sformatf("i :%0d Expected beatn :%0d Recd beatn :%0d",i,data_beat,this.cache_fill_data_pkt.beatn[i]),UVM_MEDIUM);
            end
            if(beat_aligned(this.cache_addr) != beat_aligned(this.cache_fill_data_pkt.addr)) begin
              `uvm_error("<%=obj.BlockId%>:DMI_SCOREBOARD",$sformatf("addr of cache fill addr  and axi read not matching  cache_fill_data_pkt.addr  :x%0x: this.axi_read_data_pkt.araddr :x%0x",beat_aligned(this.cache_fill_data_pkt.addr),beat_aligned(this.cache_addr)));
            end
            
            for (i=0;i<$size(this.cache_fill_data_pkt.data);i++) begin
               if(this.axi_read_data_pkt.rdata[i]===this.cache_fill_data_pkt.data[i]) begin
                  `uvm_info("<%=obj.BlockId%>:DMI_SCOREBOARD", $sformatf("data matches!"), UVM_HIGH)
               end
               else begin
               // if(!uncorr_err)begin
                 if(!this.cache_fill_data_pkt.poison[i])begin
                   `uvm_error("<%=obj.BlockId%>:DMI_SCOREBOARD:1", $sformatf("Data mismatch! Fill data for burst %0d does not match that on AXI req. AXIdata=0x%0x Fill read data=0x%0x ",i,this.axi_read_data_pkt.rdata[i],this.cache_fill_data_pkt.data[i]))                  
                 end
               // end
               end
               //#Check.DMI.Concerto.v3.0.RrespErr
               if(this.axi_read_data_pkt.rresp_per_beat[i] == 2'b10 || this.axi_read_data_pkt.rresp_per_beat[i] == 2'b11 )begin
                 if(!this.cache_fill_data_pkt.poison[i])begin
                    `uvm_error("<%=obj.BlockId%>:DMI_SCOREBOARD",$sformatf("poison bit should be 1 for AXI err rresp_per_beat[i] :%b",i,this.axi_read_data_pkt.rresp_per_beat[i]));
                 end
               end
               data_beat = this.cache_fill_data_pkt.addr[LINE_INDEX_H:LINE_INDEX_L]+i;
               if(this.cache_fill_data_pkt.beatn[i] !== data_beat)begin
                  `uvm_error("<%=obj.BlockId%>:DMI_SCOREBOARD",$sformatf("cache_fill_data_pkt.addr i :%0d: Expected beatn :%0d Recd beatn :%0d",i,data_beat,this.cache_fill_data_pkt.beatn[i]));
               end
               data_beat = this.cache_fill_data_pkt.addr[LINE_INDEX_H:LINE_INDEX_L]+i;
               if(this.cache_fill_data_pkt.beatn[i] !== data_beat)begin
                  `uvm_error("<%=obj.BlockId%>:DMI_SCOREBOARD",$sformatf("axi_read_addr_pkt.araddr i :%0d: Expected beatn :%0d Recd beatn :%0d",i,data_beat,this.cache_fill_data_pkt.beatn[i]));
               end
            end
      end
<% } %>
      //Dtr BE disabled as per CONC-5411
      //BE check enable TDO satya
     // if(!uncorr_err)begin
     //   if ((this.AXI_read_data_expd === 1)) begin
     //       for (i=0;i<$size(this.dtr_req_pkt.smi_dp_be);i++) begin
     //        if(this.axi_read_data_pkt.rresp_per_beat[i] <2) begin
     //          if (&this.dtr_req_pkt.smi_dp_be[i] !== 1) begin
     //             `uvm_error("<%=obj.BlockId%>:DMI_SCOREBOARD", $sformatf("DTR smi_dp_user[%0d]:0x%0x expd:all ones",i, this.dtr_req_pkt.smi_dp_be[i]))
     //          end
     //        end else begin
     //   `ifndef BE_CHECK_DIS
     //          if (|this.dtr_req_pkt.smi_dp_be[i] !== 0) begin
     //             `uvm_error("<%=obj.BlockId%>:DMI_SCOREBOARD", $sformatf("DTR smi_dp_user[%0d]:0x%0x expd:0", i, this.dtr_req_pkt.smi_dp_be[i]))
     //          end
     //    `endif
     //        end
     //       end
     //     end
     //  end
    end // isMrd
    else if(this.isDtw || this.isNcWr || this.isAtmStore )begin

      if((this.DTW_rsp_expd===1)&&(this.DTW_rsp_recd===0)) begin
         `uvm_error("<%=obj.BlockId%>:DMI_SCOREBOARD", $sformatf("DTW_rsp not received"))
      end
      if(this.DTW_rsp_recd == 1)begin
        if(this.dtw_req_pkt.smi_src_ncore_unit_id !== this.dtw_rsp_pkt.smi_targ_ncore_unit_id)begin
          `uvm_error("<%=obj.BlockId%>:DMI_SCOREBOARD", $sformatf("unexpected dtwrsp targ_id exp:%0x recd:%0x",this.dtw_req_pkt.smi_src_ncore_unit_id,this.dtw_rsp_pkt.smi_targ_ncore_unit_id))
        end
        if(this.dtw_req_pkt.smi_targ_ncore_unit_id !== this.dtw_rsp_pkt.smi_src_ncore_unit_id)begin
          `uvm_error("<%=obj.BlockId%>:DMI_SCOREBOARD", $sformatf("unexpected dtwrsp src_id exp:%0x recd:%0x",this.dtw_req_pkt.smi_targ_ncore_unit_id,this.dtw_rsp_pkt.smi_src_ncore_unit_id))
        end
      end
      if(this.DTW2nd_rsp_recd == 1)begin
        if(this.dtw2nd_req_pkt.smi_src_ncore_unit_id !== this.dtw2nd_rsp_pkt.smi_targ_ncore_unit_id)begin
          `uvm_error("<%=obj.BlockId%>DMI_SCOREBOARD", $sformatf("unexpected dtwrsp2nd targ_id exp:%0x recd:%0x",this.dtw2nd_req_pkt.smi_src_ncore_unit_id,this.dtw2nd_rsp_pkt.smi_targ_ncore_unit_id))
        end
        if(this.dtw2nd_req_pkt.smi_targ_ncore_unit_id !== this.dtw2nd_rsp_pkt.smi_src_ncore_unit_id)begin
          `uvm_error("<%=obj.BlockId%>:DMI_SCOREBOARD", $sformatf("unexpected dtwrsp2nd src_id exp:%0x recd:%0x",this.dtw2nd_req_pkt.smi_targ_ncore_unit_id,this.dtw2nd_rsp_pkt.smi_src_ncore_unit_id))
        end
      end
      if(isCoh)begin
        if((this.RB_req_expd===1)&&(this.RB_req_recd===0)) begin
           `uvm_error("<%=obj.BlockId%>:DMI_SCOREBOARD", $sformatf("RB_req not received"))
        end
        if((this.RB_rsp_expd===1)&&(this.RB_rsp_recd===0)) begin
           `uvm_error("<%=obj.BlockId%>:DMI_SCOREBOARD", $sformatf("RB_rsp not received"))
        end
      end
      if((this.AXI_write_data_expd===1)&&(this.AXI_write_data_recd===0)) begin
         `uvm_error("<%=obj.BlockId%>:DMI_SCOREBOARD", $sformatf("axi_write_data not received"))
      end
      //#Check.DMI.NoDTwRspWithoutBResp
      //#Check.DMI.Concerto.v3.0.DtwReqDataIntegrity
      //#Check.DMI.Concerto.v3.0.DtwReqDataProt
    if(!this.isCacheHit) begin
      if((this.AXI_write_resp_expd===1)&&(this.AXI_write_resp_recd===1)) begin
          for (i=0;i<$size(this.axi_write_data_pkt.wdata);i++) begin
             for (int j=0;j<(WXDATA/64)*WSMIDPDBADPERDW;j++) begin
               if(this.dtw_req_pkt.smi_dp_dbad[i][j] !== 0) begin
                 if(this.axi_write_data_pkt.wstrb[(j*(8/WSMIDPDBADPERDW))+(8/WSMIDPDBADPERDW)]===0) begin
                    `uvm_info("<%=obj.BlockId%>:DMI_SCOREBOARD", $sformatf("wstrb matches matches DTWreq Dbad!, AXI WSTRB[%0d:%0d]=0x%0x SMI DTWreq Dbad=0x%0x",(j*(8/WSMIDPDBADPERDW)),(((j*(8/WSMIDPDBADPERDW))+(8/WSMIDPDBADPERDW))-1),this.axi_write_data_pkt.wstrb[j*(8/WSMIDPDBADPERDW)+(8/WSMIDPDBADPERDW)],this.dtw_req_pkt.smi_dp_dbad[i][j]), UVM_MEDIUM)
                 end
                 else begin
                    `uvm_error("<%=obj.BlockId%>:DMI_SCOREBOARD", $sformatf("WSTRB mismatch! AXI wstrb for burst %0d does not match SMI DTWreq Dbad value. AXI WSTRB[%0d:%0d]=0x%0x SMI DTWreq Dbad=0x%0x",i,(j*(8/WSMIDPDBADPERDW)),(((j*(8/WSMIDPDBADPERDW))+(8/WSMIDPDBADPERDW))-1),this.axi_write_data_pkt.wstrb[j*(8/WSMIDPDBADPERDW)+(8/WSMIDPDBADPERDW)],this.dtw_req_pkt.smi_dp_dbad[i][j]))
                 end
               end
               else begin
                 if(this.axi_write_data_pkt.wstrb[(j*(8/WSMIDPDBADPERDW))+(8/WSMIDPDBADPERDW)]===this.dtw_req_pkt.smi_dp_be[(j*(8/WSMIDPDBADPERDW))+(8/WSMIDPDBADPERDW)]) begin
                    `uvm_info("<%=obj.BlockId%>:DMI_SCOREBOARD", $sformatf("wstrb matches matches DTWreq BE!, AXI WSTRB[%0d:%0d]=0x%0x SMI DTWreq BE[%0d:%0d]=0x%0x",(j*(8/WSMIDPDBADPERDW)),(((j*(8/WSMIDPDBADPERDW))+(8/WSMIDPDBADPERDW))-1),this.axi_write_data_pkt.wstrb[j*(8/WSMIDPDBADPERDW)+(8/WSMIDPDBADPERDW)],(j*(8/WSMIDPDBADPERDW)),(((j*(8/WSMIDPDBADPERDW))+(8/WSMIDPDBADPERDW))-1),this.dtw_req_pkt.smi_dp_be[j*(8/WSMIDPDBADPERDW)+(8/WSMIDPDBADPERDW)]), UVM_MEDIUM)
                 end
                 else begin
                    `uvm_error("<%=obj.BlockId%>:DMI_SCOREBOARD", $sformatf("WSTRB mismatch! AXI wstrb for burst %0d does not match SMI DTWreq BE value!, AXI WSTRB[%0d:%0d]=0x%0x SMI DTWreq BE[%0d:%0d]=0x%0x",i,(j*(8/WSMIDPDBADPERDW)),(((j*(8/WSMIDPDBADPERDW))+(8/WSMIDPDBADPERDW))-1),this.axi_write_data_pkt.wstrb[j*(8/WSMIDPDBADPERDW)+(8/WSMIDPDBADPERDW)],(j*(8/WSMIDPDBADPERDW)),(((j*(8/WSMIDPDBADPERDW))+(8/WSMIDPDBADPERDW))-1),this.dtw_req_pkt.smi_dp_be[j*(8/WSMIDPDBADPERDW)+(8/WSMIDPDBADPERDW)]))
                 end
               end
             end
             //if(this.axi_write_data_pkt.wstrb[i]===this.dtw_req_pkt.smi_dp_be[i]) begin
             //   `uvm_info("<%=obj.BlockId%>:DMI_SCOREBOARD", $sformatf("wstrb matches matches req_be!"), UVM_MEDIUM)
             //end
             //else begin
             //   `uvm_error("<%=obj.BlockId%>:DMI_SCOREBOARD", $sformatf("WSTRB mismatch! AXI wstrb for burst %0d does not match SMI req_be value. AXI WSTRB=0x%0x SMI req_be=0x%0x",i,this.axi_write_data_pkt.wstrb[i],this.dtw_req_pkt.smi_dp_be[i]))
             //end
             if(this.dtw_req_pkt.smi_dp_data[i]===this.axi_write_data_pkt.wdata[i]) begin
                `uvm_info("<%=obj.BlockId%>:DMI_SCOREBOARD", $sformatf("data matches!"), UVM_HIGH)
             end
             else begin
              foreach(this.axi_write_data_pkt.wstrb[,j])begin
                if(this.axi_write_data_pkt.wstrb[i][j])begin
                 if(this.dtw_req_pkt.smi_dp_data[i][j*8+:8] != this.axi_write_data_pkt.wdata[i][j*8+:8])begin
                  `uvm_error("<%=obj.BlockId%>:DMI_SCOREBOARD", $sformatf("Data mismatch! AXI write data for burst %0d does not match that on DTW req. DTWdata=0x%0x AXIdata=0x%0x",i,this.dtw_req_pkt.smi_dp_data[i][j*8+8],this.axi_write_data_pkt.wdata[i][j*8+:8]))
                 end
                end
              end
             end
          end
      end
    end
<% if (obj.DutInfo.useCmc) { %>
  //  else begin
  //    if((this.AXI_write_resp_expd===1)&&(this.AXI_write_resp_recd===1)) begin
  //        for (i=0;i<$size(this.axi_write_data_pkt.wdata);i++) begin
  //           if(this.cache_wr_data_pkt_exp.data[i] === this.axi_write_data_pkt.wdata[i]) begin
  //              `uvm_info("<%=obj.BlockId%>:DMI_SCOREBOARD", $sformatf("data matches!"), UVM_MEDIUM)
  //           end
  //           else begin
  //              `uvm_error("<%=obj.BlockId%>:DMI_SCOREBOARD", $sformatf("Data mismatch! AXI write data for burst %0d does not match that with mergerd WrData =0x%0x AXIdata=0x%0x",i,this.cache_wr_data_pkt_exp.data[i],this.axi_write_data_pkt.wdata[i]))
  //           end
  //           if(this.axi_write_data_pkt.wstrb[i]===this.cache_wr_data_pkt_exp.byten[i]) begin
  //              `uvm_info("<%=obj.BlockId%>:DMI_SCOREBOARD", $sformatf("wstrb matches matches req_be!"), UVM_MEDIUM)
  //           end
  //           else begin
  //              `uvm_error("<%=obj.BlockId%>:DMI_SCOREBOARD", $sformatf("WSTRB mismatch! AXI wstrb for burst %0d does not match SMI req_be value. AXI WSTRB=0x%0x SMI req_be=0x%0x",i,this.axi_write_data_pkt.wstrb[i],this.cache_wr_data_pkt_exp.byten[i]))
  //           end
  //        end
  //    end
  //  end
<% } %>
<% if (obj.DutInfo.useCmc) { %>
      //#Check.DMI.
  //    if(this.cacheWrDataExpd === 1 && this.cacheWrDataRecd === 1) begin
  //      if (this.cache_wr_data_pkt_exp.data.size() == this.cache_wr_data_pkt.data.size()) begin
  //         for (i=0;i<$size(this.cache_wr_data_pkt_exp.data);i++) begin
  //            beatn    = this.cache_wr_data_pkt.beatn[i];
  //            beatnExp = this.cache_wr_data_pkt_exp.beatn[i];
  //            if(this.cache_wr_data_pkt_exp.beatn[i] !== this.cache_wr_data_pkt.beatn[i]) begin
  //               `uvm_error("<%=obj.BlockId%>:DMI_SCOREBOARD", $sformatf("Beatn not matching for i :%0d Recd beatn :%0d Expd beatn :%0d ",i,beatn,beatnExp))
  //            end
  //            if(this.cache_wr_data_pkt_exp.data[i]===this.cache_wr_data_pkt.data[i]) begin
  //               `uvm_info("<%=obj.BlockId%>:DMI_SCOREBOARD", $sformatf("data matches!"), UVM_HIGH)
  //            end
  //            else begin
  //                if(this.cache_wr_data_pkt.byten[i])begin
  //               `uvm_error("<%=obj.BlockId%>:DMI_SCOREBOARD", $sformatf("Data mismatch! CCP write data for beat %0d does not match that on DTW req. DTWdata=0x%0x CCP Wr data=0x%0x",i,this.cache_wr_data_pkt_exp.data[i],this.cache_wr_data_pkt.data[i]))
  //              end
  //            end
  //            if(this.cache_wr_data_pkt_exp.byten[i] === this.cache_wr_data_pkt.byten[i]) begin
  //               `uvm_info("<%=obj.BlockId%>:DMI_SCOREBOARD", $sformatf("i :%0d wstrb matches matches ccp wr byten!",i), UVM_MEDIUM)
  //            end
  //            else begin
  //               `uvm_error("<%=obj.BlockId%>:DMI_SCOREBOARD", $sformatf("WSTRB mismatch! CCP wr byten for beat %0d does not match SFI req_be value. CCP  Byteen=0x%0x SFI req_be=0x%0x",i,this.cache_wr_data_pkt.byten[i],this.cache_wr_data_pkt_exp.byten[i]))
  //            end
  //         end
  //       end
  //       else begin
  //         `uvm_error("<%=obj.BlockId%>:DMI_SCOREBOARD", $sformatf("Data size on CCP Wr write does not match that on DTW req"))
  //       end
  //     end
<% } %>
/////////////////////////////////////////////////////////////////////
// Check Configurable AXI fields
/////////////////////////////////////////////////////////////////////
      if(this.AXI_write_addr_recd) begin
        // if (<%=obj.BlockId + '_con'%>::WUSEACECACHE) begin
        //    if (this.axi_write_addr_pkt.awcache !== <%=obj.BlockId + '_con'%>::axi_awcache_enum_t'(this.dtw_req_pkt.ace.cache)) begin 
        //       `uvm_error("<%=obj.BlockId%>:DMI_SCOREBOARD", $sformatf("AXI awcache: %p SMI cache: %p",this.axi_write_addr_pkt.awcache, this.dtw_req_pkt.ace.cache))
        //    end
        // end
        // if (<%=obj.BlockId + '_con'%>::WUSEACEPROT) begin
        //    if (this.axi_write_addr_pkt.awprot !== <%=obj.BlockId + '_con'%>::axi_axprot_t'(this.dtw_req_pkt.ace.prot)) begin 
        //       `uvm_error("<%=obj.BlockId%>:DMI_SCOREBOARD", $sformatf("AXI awprot: 0x%x SMI prot: 0x%x",this.axi_write_addr_pkt.awprot, this.dtw_req_pkt.ace.prot))
        //    end
        // end
        // if (<%=obj.BlockId + '_con'%>::WUSEACEREGION) begin
        //    if (this.axi_write_addr_pkt.awregion !== <%=obj.BlockId + '_con'%>::axi_axregion_t'(this.dtw_req_pkt.ace.region)) begin
        //    `uvm_error("<%=obj.BlockId%>:DMI_SCOREBOARD", $sformatf("AXI awregion: 0x%0x SMI region: 0x%0x",this.axi_write_addr_pkt.awregion, this.dtw_req_pkt.ace.region))
        //    end
        // end
        // if (<%=obj.BlockId + '_con'%>::WUSEACEUSER) begin
        //   if(!this.isEvict)begin
        //    if (this.axi_write_addr_pkt.awuser !== <%=obj.BlockId + '_con'%>::axi_awuser_t'(this.dtw_req_pkt.ace.user)) begin
        //       `uvm_error("<%=obj.BlockId%>:DMI_SCOREBOARD", $sformatf("AXI awuser: 0x%0x SMI user: 0x%0x",this.axi_write_addr_pkt.awuser, this.dtw_req_pkt.ace.user))
        //    end
        //   end
        //   else  begin
        //    if(this.isEvict && !this.isRdWtt)begin
        //     if (this.axi_write_addr_pkt.awuser !== 0) begin
        //        `uvm_error("<%=obj.BlockId%>:DMI_SCOREBOARD", $sformatf("AXI awuser: 0x%0x Exp 0",this.axi_write_addr_pkt.awuser))
        //     end
        //    end 
        //   end 
        // end
<%if (obj.DmiInfo[obj.Id].fnEnableQos) { %>
         if(this.isEvict)begin
           if(exp_eviction_qos[WSMIMSGQOS]) begin
             <%if (smiQosEn) { %>
             if (this.axi_write_addr_pkt.awqos !== exp_eviction_qos[WSMIMSGQOS-1:0]) begin
               `uvm_error("<%=obj.BlockId%>:DMI_SCOREBOARD", $sformatf("AXI AWQOS: 0x%x SMI qos: 0x%0x",this.axi_write_addr_pkt.awqos,exp_eviction_qos[WSMIMSGQOS-1:0]))
             end
             <%}%>
           end
           else begin
             if (this.axi_write_addr_pkt.awqos !== 0) begin
               `uvm_error("<%=obj.BlockId%>:DMI_SCOREBOARD", $sformatf("AXI AWQOS: 0x%x SMI qos: 0x%0x",this.axi_write_addr_pkt.awqos,0))
             end
           end
         end
         else begin
           if (this.axi_write_addr_pkt.awqos !== this.smi_qos) begin
             `uvm_error("<%=obj.BlockId%>:DMI_SCOREBOARD", $sformatf("AXI AWQOS: 0x%x SMI qos: 0x%x",this.axi_write_addr_pkt.awqos, this.smi_qos))
           end
         end
<% } else { %>
           if (this.axi_write_addr_pkt.awqos !== 0) begin
             `uvm_error("<%=obj.BlockId%>:DMI_SCOREBOARD", $sformatf("AXI AWQOS: 0x%x SMI qos: 0",this.axi_write_addr_pkt.awqos,))
           end
<% } %>
<%if (obj.wSecurityAttribute > 0) { %>
         //arprot[1] = sec
         if (this.axi_write_addr_pkt.awprot[1] !== this.security) begin
               `uvm_error("<%=obj.BlockId%>:DMI_SCOREBOARD", $sformatf("AXI Prot[1]: 0x%x SMI security: 0x%x",this.axi_write_addr_pkt.awprot[1], this.dtw_req_pkt.smi_ns))
         end
<% } %>
         if (this.axi_write_addr_pkt.awprot[2] !== 0) begin
               `uvm_error("<%=obj.BlockId%>:DMI_SCOREBOARD", $sformatf("AXI Prot[2]: 0x%x (should be 0)",this.axi_write_addr_pkt.awprot[2]))
         end
         if (this.axi_write_addr_pkt.awprot[0] !== this.privileged) begin
               `uvm_error("<%=obj.BlockId%>:DMI_SCOREBOARD", $sformatf("AXI Prot[0]: 0x%x (should be %0x)",this.axi_write_addr_pkt.awprot[0],this.privileged))
         end
      end // if (this.AXI_write_addr_recd)
    end
   endfunction // check_entry

function void addToRttQ(smi_seq_item  m_rd_req_entry, int expect_axi, bit wrOutstanding,uncorr_err_en);

   t_creation      = $time;
   t_latest_update = $time;
   cache_addr      = m_rd_req_entry.smi_addr;
<% if(obj.DutInfo.useCmc == 1) { %>
   cache_index     = ncoreConfigInfo::get_set_index(m_rd_req_entry.smi_addr,<%=obj.DmiInfo[obj.Id].FUnitId%>); 
<% } %>
   smi_msg_id      = m_rd_req_entry.smi_msg_id;
   smi_msg_type    = m_rd_req_entry.smi_msg_type;
<%if (obj.wSecurityAttribute > 0) { %>
   security        = m_rd_req_entry.smi_ns;
<% } %>
   privileged      = m_rd_req_entry.smi_pr;
   smi_ac          = m_rd_req_entry.smi_ac;
   smi_vz          = m_rd_req_entry.smi_vz;
   smi_ca          = m_rd_req_entry.smi_ca;
   smi_qos         = m_rd_req_entry.smi_qos;
   smi_msg_pri     = m_rd_req_entry.smi_msg_pri;
   smi_ndp_aux_ar  = m_rd_req_entry.smi_ndp_aux;
   if(m_rd_req_entry.isMrdMsg() || m_rd_req_entry.isCmdMsg())begin
     exp_smi_tm      = m_rd_req_entry.smi_tm;
   end
   if(m_rd_req_entry.isMrdMsg())begin
     isCoh        = 1;;
     isMrd        = 1;
     mrd_msg_type = m_rd_req_entry.smi_msg_type;
     MRD_req_recd = 1;
     MRD_rsp_expd = 1;
     MRD_rsp_recd = 0;
     dtr_targ_unit_id = m_rd_req_entry.smi_mpf1_dtr_tgt_id[WSMINCOREUNITID-1:0];  
     dtr_rmsg_id_expd = m_rd_req_entry.smi_mpf2_dtr_msg_id;  
   <% if(obj.DutInfo.useCmc) { %>
     CalSPProperty();

     if (sp_txn) begin
       expect_axi = 0;
       if(m_rd_req_entry.smi_msg_type inside {MRD_FLUSH,MRD_INV,MRD_CLN,MRD_PREF})begin
         sp_seen_ctrl_chnl = 1;
         sp_seen_output_chnl = 1;
       end
     end
   <% } %>
   end
   else begin
     if(m_rd_req_entry.smi_msg_type == CMD_PREF)begin
       isCmdPref = 1;
     end
     else begin
       isNcRd = 1;
     end
   <% if(obj.DutInfo.useCmc) { %>
     CalSPProperty();
     if (sp_txn) begin
        expect_axi = 0;
       if(m_rd_req_entry.smi_msg_type inside {CMD_CLN_INV,CMD_CLN_VLD,CMD_CLN_SH_PER,CMD_MK_INV,CMD_PREF})begin
         sp_seen_ctrl_chnl = 1;
         sp_seen_output_chnl = 1;
       end
     end
   <% } %>
     if(m_rd_req_entry.isCmdMsg) CMD_req_recd = 1;
     CMD_rsp_expd = 1;
     CMD_rsp_recd = 0;
     STR_req_expd = 1;
     STR_req_recd = 0;
     STR_rsp_expd = 1;
     STR_rsp_recd = 0;
     cmd_msg_id       = m_rd_req_entry.smi_msg_id;
     cmd_msg_type     = m_rd_req_entry.smi_msg_type;
     dtr_targ_unit_id = m_rd_req_entry.smi_src_ncore_unit_id;
     dtr_rmsg_id_expd = m_rd_req_entry.smi_msg_id;  
     cmd_src_unit_id  = m_rd_req_entry.smi_src_ncore_unit_id;
   end

   if(m_rd_req_entry.isCmdAtmLoadMsg() || m_rd_req_entry.isCmdAtmStoreMsg())begin
     DTW_req_expd = 1;
     DTW_req_recd = 0;
     DTW_rsp_expd = 1;
     DTW_rsp_recd = 0;
   end
//#Check.DMI.Concerto.v3.0.NoDTRforCMOandMrdPref
//#Check.DMI.Concerto.v3.0.DtrReqCacheOps
   if((m_rd_req_entry.smi_msg_type inside {MRD_FLUSH,MRD_INV,MRD_CLN,CMD_CLN_INV,CMD_CLN_VLD,CMD_CLN_SH_PER,CMD_MK_INV,CMD_PREF,MRD_PREF}) ||
       m_rd_req_entry.isCmdAtmStoreMsg()) begin
    DTR_req_expd = 0;
    DTR_rsp_expd = 0;
   end
   else begin
    DTR_req_expd = 1;
    DTR_rsp_expd = 1;
   end
   DTR_req_recd = 0;
   DTR_rsp_recd = 0;
   if(m_rd_req_entry.smi_msg_type == CMD_CMP_ATM)begin
     if( ((2**m_rd_req_entry.smi_intfsize)/(<%=obj.DmiInfo[obj.Id].interfaces.axiInt.params.wData%>/64)) > 1) begin
       expd_dtr_beats = ((2**m_rd_req_entry.smi_intfsize)/(<%=obj.DmiInfo[obj.Id].interfaces.axiInt.params.wData%>/64));
     end
     else begin
       expd_dtr_beats = 1;
     end
   end
   else begin
     if(((2**m_rd_req_entry.smi_size)/(<%=obj.DmiInfo[obj.Id].interfaces.axiInt.params.wData%>/8)) >1)
       expd_dtr_beats = ((2**m_rd_req_entry.smi_size)/(<%=obj.DmiInfo[obj.Id].interfaces.axiInt.params.wData%>/8));
     else begin
       expd_dtr_beats = 1;
     end
   end
   smi_size           = m_rd_req_entry.smi_size;
   smi_intfsize       = m_rd_req_entry.smi_intfsize;
  <% if(!obj.DutInfo.useCmc) { %>
   expd_arlen = expd_dtr_beats-1;
  <% } else { %>
   if(isDtwMrgMrd | isAtomic) begin
     //Full CL is filled for atomics and merge computations out of the Native Read I/F
     expd_arlen =  ((2**SYS_wSysCacheline/(<%=obj.DmiInfo[obj.Id].interfaces.axiInt.params.wData/8%>))-1);
   end
   else begin
     expd_arlen = (smi_size <= $clog2(<%=obj.DmiInfo[obj.Id].interfaces.axiInt.params.wData/8%>)) ? 0 :
                          (((2**smi_size)/(<%=obj.DmiInfo[obj.Id].interfaces.axiInt.params.wData/8%>))-1);
   end

  <% } %>
   // Expecting INCR burst in those cases where WRAP is not possible, otherwise burst_type is bypassed from from agent to mem
   expd_arburst       = (expd_arlen == 0) ? AXIINCR : AXIWRAP ;
   AXI_read_addr_expd = expect_axi;
   AXI_read_addr_recd = 0;
   AXI_read_data_expd = expect_axi;
   AXI_read_data_recd = 0;

   rdOutstandingFlag = 0;
   wrOutstandingFlag = wrOutstanding;
   
<% if(obj.DutInfo.useCmc) { %>
   cacheRspExpd = 0;
   cacheRspRecd = 0;
   isCacheHit = 0;
   isCacheMiss = 0;
   fillExpd = 0;
   fillSeen = 0;
   fillDataExpd = 0;
   fillDataSeen = 0;;
   if (sp_txn) lookupExpd = 0;
   else lookupExpd = 1;
   lookupSeen    = 0;
   lookupSeen2nd = 0;
   rttNoAlloc = 0;
   isStale = 0;
   isdropped = 0;
   DtrRdy = 0;
<% } else { %>
   cacheRspExpd = 0;
   cacheRspRecd = 0;
   isCacheHit = 0;
   isCacheMiss = 0;
   fillExpd = 0;
   fillSeen = 0;
   fillDataExpd = 0;
   fillDataSeen = 0;
   lookupExpd = 0;
   lookupSeen = 0;
   isStale = 0;
   DtrRdy = 0;
<% } %>
   uncorr_err = uncorr_err_en;
endfunction // addToRttQ

function void addToWttQ(smi_seq_item  m_wr_req_entry, int expectAxi, bit wrOutstanding,evictDataExpd,uncorr_err_en,rbreq_recd=0);
   t_creation      = $time;
   t_latest_update = $time;
   if(m_wr_req_entry.isCmdMsg())begin
     isNcWr = 1;
     smi_msg_type    = m_wr_req_entry.smi_msg_type;
     cmd_src_unit_id = m_wr_req_entry.smi_src_ncore_unit_id;
     cmd_msg_id      = m_wr_req_entry.smi_msg_id; 
     cache_addr      = m_wr_req_entry.smi_addr; 
<%if (obj.wSecurityAttribute > 0) { %>
     security        = m_wr_req_entry.smi_ns; 
<% } %>
     privileged      = m_wr_req_entry.smi_pr; 
    <% if(obj.DutInfo.useCmc) { %>
     cache_index     = ncoreConfigInfo::get_set_index(m_wr_req_entry.smi_addr, <%=obj.DmiInfo[obj.Id].FUnitId%>); 
     CalSPProperty();
     if (sp_txn) expectAxi = 0;
    <% } %>
     smi_ac          = m_wr_req_entry.smi_ac; 
     smi_ca          = m_wr_req_entry.smi_ca; 
     smi_vz          = m_wr_req_entry.smi_vz; 
     smi_qos         = m_wr_req_entry.smi_qos;
     smi_msg_pri     = m_wr_req_entry.smi_msg_pri;
     smi_ndp_aux_aw  = m_wr_req_entry.smi_ndp_aux;
     smi_size        = m_wr_req_entry.smi_size; 
     smi_intfsize    = m_wr_req_entry.smi_intfsize;
     smi_burst       = m_wr_req_entry.smi_mpf1_burst_type;
     exp_smi_tm      = m_wr_req_entry.smi_tm;
     CMD_req_recd = 1;
     CMD_rsp_expd = 1;
     CMD_rsp_recd = 0;
     STR_req_expd = 1;
     STR_req_recd = 0;
     STR_rsp_expd = 1;
     STR_rsp_recd = 0;
   end
   else begin
     isDtw        = 1;
     RB_req_expd  = 1;
     RB_rsp_expd  = 1;
     dtw_msg_id   = m_wr_req_entry.smi_msg_id;
     dtw_msg_type = m_wr_req_entry.smi_msg_type;
     exp_smi_tm   = m_wr_req_entry.smi_tm;
   end
   DTW_rsp_expd = 1;
   if(!m_wr_req_entry.isCmdAtmLoadMsg()) begin
     AXI_write_addr_expd = expectAxi;
     AXI_write_addr_recd = 0;
     AXI_write_data_expd = expectAxi;
     AXI_write_data_recd = 0;
     AXI_write_resp_expd = expectAxi;
     AXI_write_resp_recd = 0;
   end

   wrOutstanding = wrOutstanding;
   islast = 0;
   uncorr_err = uncorr_err_en ;

<% if(obj.DutInfo.useCmc) { %>
   lookupExpd = 1;
   lookupSeen = 0;
   isCacheHit = 0;
   isCacheMiss = 0;
   cacheWrDataExpd = 0;
   cacheWrDataRecd = 0;
   rdrspDataExpd = 0;
   rdrspDataRecd = 0;
   evictDataExpd = 0;
   evictDataRecd = 0;
   cacheRspExpd = 0;
   cacheRspRecd = 0;
   bypassExpd = 0;
   bypassSeen = 0;
   isWrThBypass = 0;
<% } else { %>
   lookupExpd = 0;
   lookupSeen = 0;
   isCacheHit = 0;
   isCacheMiss = 0;
   cacheWrDataExpd = 0;
   cacheWrDataRecd = 0;
   rdrspDataExpd = 0;
   rdrspDataRecd = 0;
   evictDataExpd = 0;
   evictDataRecd = 0;
   cacheRspExpd = 0;
   cacheRspRecd = 0;
   bypassExpd = 0;
   bypassSeen = 0;
<% } %>
endfunction//addToWttQ

<% if(obj.DutInfo.useCmc) { %>
function void CalSPProperty();
    smi_addr_t cache_addr_i_claligned; 
    // Scratchpad transaction attributes
    if(sp_enabled) begin
      //if(cache_addr_i == 0) `uvm_error("dmi_states","Initialization error, unfortunately a rearranged cache address with interleave bits removed is needed to proceed.")
      cache_addr_i_claligned = cache_addr_i >> CCP_CL_OFFSET;
      `uvm_info("<%=obj.BlockId%>:DMI_SCOREBOARD", $sformatf
                ("DEBUG0 security: %0b, cache_addr: %0h, cache_addr_i: %0h, cache_addr_i_claligned: %0h, lower_sp_addr: %0h upper_sp_addr: %0h rsvd_ways: %0b",
                security, cache_addr, cache_addr_i, cache_addr_i_claligned, lower_sp_addr, upper_sp_addr,rsvd_ways), UVM_MEDIUM)

      if ((cache_addr_i_claligned >= lower_sp_addr) && (cache_addr_i_claligned <= upper_sp_addr) && (security==sp_ns)) begin
         `uvm_info("<%=obj.BlockId%>:DMI_SCOREBOARD", $sformatf("This is a SP txn"), UVM_MEDIUM)
         // #Check.DMI.Concerto.v3.0.OnlySPTxnsOnSPCtrlChnl
         sp_txn   = 1;
         sp_addr  = ({cache_addr_i_claligned} - lower_sp_addr) << CCP_CL_OFFSET;
         sp_index = cache_addr_i[($clog2(N_CCP_SETS/N_DATA_BANKS)+SYS_wSysCacheline-1):SYS_wSysCacheline];
        <% if (obj.DmiInfo[obj.Id].ccpParams.nDataBanks > 1) { %>
         sp_data_bank = cache_addr_i[($clog2(N_CCP_SETS)+SYS_wSysCacheline-1):
                                   ($clog2(N_CCP_SETS/N_DATA_BANKS)+SYS_wSysCacheline)];
        <% } else {%>
         sp_data_bank = 0;
        <% } %>
        <% if (obj.DmiInfo[obj.Id].ccpParams.nWays > 1) { %>
         sp_way = sp_addr[$clog2(N_CCP_SETS*N_CCP_WAYS)+SYS_wSysCacheline-1:$clog2(N_CCP_SETS)+SYS_wSysCacheline] & rsvd_ways;
        <% } else {%>
         sp_way = 0;
        <% } %>
         sp_beat_num = cache_addr_i[SYS_wSysCacheline-1:$clog2(WCCPDATA/8)];
         `uvm_info("<%=obj.BlockId%>:DMI_SCOREBOARD", $sformatf
                   ("DEBUG1 sp_addr: %0h, sp_index: %0h sp_way: %0d sp_beat_num: %0d sp_data_bank: %0d",
                    sp_addr, sp_index, sp_way, sp_beat_num, sp_data_bank), UVM_MEDIUM)
      end else begin
         // CONC-4790, Atomic Cache txns should not come if all ways are reserved for Scratchpad or Way-Partitioning
         if (this.isAtomic && (&rsvd_ways)) begin
             print_entry_eos();
             `uvm_error("Dmi states", $sformatf("Atomic Cache txns should not come if all ways are reserved for Scratchpad or Way-Partitioning. This is illegal stimulus"))
         end
      end
    end
endfunction //CalSPProperty
<% } %>
   function smi_addr_t beat_aligned(smi_addr_t addr);
      smi_addr_t beat_aligned_addr;
      beat_aligned_addr = (addr >> $clog2(<%=obj.DmiInfo[obj.Id].wData%>/8));
      return beat_aligned_addr;

   endfunction // beat_aligned

    //------------------------------------------------------------------------------
    // txn state machine
    //TODO make *_expd a state machine holding nextmsgs, rather than all remaining msgs
    //------------------------------------------------------------------------------

    //add a msg to this txn
    function add_msg(smi_seq_item msg);
        if(smi_expd[msg.smi_conc_msg_class]) begin
            smi_recd[msg.smi_conc_msg_class] = msg;
            smi_expd.delete(msg.smi_conc_msg_class);

            print_entry();
        end
        else
            `uvm_error($sformatf("%m (%s)", parent), $sformatf("msg not expd by this txn:\n%p\n%p", msg, this))
    endfunction : add_msg
    //------------------------------------------------------------------------------
    // generate expected msgs
    //  for stimulus: overwrite the nonderivative data with rand after creation
    //  deliberately not using do_copy here.  in order to ensure that every field is accounted for.
    //------------------------------------------------------------------------------

    //triage which msg to gen
    // deliberately not generating common values here.  to ensure that all content is present explicity at a single call to the constructor.
    function smi_seq_item gen_exp_smi(smi_seq_item template);
        if (template == null)
            `uvm_error($sformatf("%m (%s)", parent), "DV ERROR must specify msg type to randomize msg");

        //constraints global to dii

        //#Check.DMI.CMDreq.Ndp_protection
        //#Check.DMI.STRreq.Ndp_protection
        //#Check.DMI.DTRreq.Ndp_protection
        //#Check.DMI.DTWreq.Ndp_protection
        <% if (obj.smiObj.WSMINDPPROT_EN) { %>
        if(! (template.smi_ndp_protection inside {SMI_NDP_PROTECTION_NONE, SMI_NDP_PROTECTION_PARITY}))
            `uvm_error($sformatf("%m (%s)", parent), "disallowed smi_ndp_protection");
        <% } %>

        //#Check.DMI.DTRreq.Dp_protection
        //#Check.DMI.DTWreq.Dp_protection
        <% if (obj.smiObj.WSMIDPPROT_EN) { %>
        if(! (template.smi_dp_protection inside {SMI_DP_PROTECTION_NONE, SMI_DP_PROTECTION_PARITY}))
            `uvm_error($sformatf("%m (%s)", parent), "disallowed smi_dp_protection");
        <% } %>

        if(! (template.smi_mpf1_burst_type inside {WRAP, INCR}))
            `uvm_error($sformatf("%m (%s)", parent), "disallowed smi_mpf1_burst_type");


        case(template.smi_conc_msg_class)
            eConcMsgNcCmdRsp:	gen_exp_smi = gen_exp_smi__cmd_rsp(template) ;

            eConcMsgStrReq:		gen_exp_smi = gen_exp_smi__str_req(template) ;
            eConcMsgStrRsp:		gen_exp_smi = gen_exp_smi__str_rsp(template) ;

        //    eConcMsgDtrReq:		gen_exp_smi = gen_exp_smi__dtr_req(template) ;
            eConcMsgDtrRsp:		gen_exp_smi = gen_exp_smi__dtr_rsp(template) ;
            eConcMsgDtwRsp:		gen_exp_smi = gen_exp_smi__dtw_rsp(template) ;

            //dne v3.0
            // eConcMsgCmeRsp:     gen_exp_smi = gen_exp_smi__cme_rsp(template) ;
            // eConcMsgTreRsp:     gen_exp_smi = gen_exp_smi__tre_rsp(template) ;

            default:    `uvm_error($sformatf("%m (%s)", parent), $sformatf("invalid template class: %p", template.smi_conc_msg_class))
        endcase
    endfunction : gen_exp_smi


    //-----------------------------------



    function smi_seq_item gen_exp_smi__cmd_rsp(smi_seq_item template = null);
        if (template == null) begin
            template = new();
        //      //TODO random generation
        //      template = randomize( {constraints};)
        //      template.field =
        //      ...
         end
        
        if(!smi_recd[eConcMsgCmdReq])
            `uvm_error($sformatf("%m (%s)", parent), "precedes cmd_req");

        gen_exp_smi__cmd_rsp = smi_seq_item::type_id::create("gen_exp_smi__cmd_rsp");
        gen_exp_smi__cmd_rsp.construct_nccmdrsp(
										.smi_steer              (template.smi_steer),
                                        .smi_targ_ncore_unit_id (smi_recd[eConcMsgCmdReq].smi_src_ncore_unit_id),
                                        .smi_src_ncore_unit_id  (smi_recd[eConcMsgCmdReq].smi_targ_ncore_unit_id),
                                        .smi_msg_tier           (smi_recd[eConcMsgCmdReq].smi_msg_tier),
                                        .smi_msg_qos            (smi_recd[eConcMsgCmdReq].smi_msg_qos),
                                        .smi_msg_pri            (smi_recd[eConcMsgCmdReq].smi_msg_pri),
                                        .smi_msg_type           (NC_CMD_RSP),
                                        .smi_tm                 (smi_recd[eConcMsgCmdReq].smi_tm),
                                        .smi_msg_id             (template.smi_msg_id),
                                        .smi_msg_err            (template.smi_msg_err),

                                        .smi_cmstatus           (template.smi_cmstatus),
                                        .smi_rmsg_id            (smi_recd[eConcMsgCmdReq].smi_msg_id)
                                        );
    endfunction : gen_exp_smi__cmd_rsp



    function smi_seq_item gen_exp_smi__str_req(smi_seq_item template = null);
        if (template == null) begin
            template = new();
        //      //TODO random generation
        //      template = randomize( {constraints};)
        //      template.field =
        //      ...
         end
        
        if(!smi_recd[eConcMsgCmdReq])
            `uvm_error($sformatf("%m (%s)", parent), "precedes cmd_req");

        gen_exp_smi__str_req = smi_seq_item::type_id::create("gen_exp_smi__str_req");
        gen_exp_smi__str_req.construct_strmsg(
                                        .smi_targ_ncore_unit_id (smi_recd[eConcMsgCmdReq].smi_src_ncore_unit_id),
                                        .smi_src_ncore_unit_id  (smi_recd[eConcMsgCmdReq].smi_targ_ncore_unit_id),
                                        .smi_msg_type           (STR_STATE),
                                        .smi_msg_id             (template.smi_msg_id),
                                        .smi_msg_tier           (smi_recd[eConcMsgCmdReq].smi_msg_tier),
					.smi_steer              (template.smi_steer),
                                        .smi_msg_pri            (smi_recd[eConcMsgCmdReq].smi_msg_pri),
                                        .smi_msg_qos            (smi_recd[eConcMsgCmdReq].smi_msg_qos),
                                        .smi_msg_err            (template.smi_msg_err),

                                        .smi_cmstatus           (template.smi_cmstatus),
                                        .smi_cmstatus_so        (template.smi_cmstatus_so),
                                        .smi_cmstatus_ss        (template.smi_cmstatus_ss),
                                        .smi_cmstatus_sd        (template.smi_cmstatus_sd),
                                        .smi_cmstatus_st        (template.smi_cmstatus_st),
                                        .smi_cmstatus_state     (template.smi_cmstatus_state),
                                        .smi_cmstatus_snarf     (template.smi_cmstatus_snarf),
                                        .smi_cmstatus_exok      (template.smi_cmstatus_exok),
                                        .smi_tm                 (template.smi_tm),
                                        .smi_rbid               (template.smi_rbid),
                                        .smi_rmsg_id            (smi_recd[eConcMsgCmdReq].smi_msg_id),
                                        .smi_mpf1               (template.smi_mpf1),
                                        .smi_mpf2               (template.smi_mpf2),
                                        .smi_intfsize           ($clog2(WSMIDPBE) - 3)         // #Check.DMI.STRreq.IntfSize
        //                                .smi_ndp_aux            (template.smi_ndp_aux)
                                        );


        //#Check.DMI.STRreq.Return_buffer_id
        if(
            (smi_recd[eConcMsgCmdReq].isCmdNcWrMsg())
            && (gen_exp_smi__str_req.smi_rbid >= <%=obj.DutInfo.cmpInfo.nWttCtrlEntries%>)
        )
            `uvm_error($sformatf("%m (%s)", parent), "rbid out of range");

    endfunction : gen_exp_smi__str_req


    function smi_seq_item gen_exp_smi__str_rsp(smi_seq_item template = null);
        if (template == null) begin
            template = new();
        //      //TODO random generation
        //      template = randomize( {constraints};)
        //      template.field =
        //      ...
         end
        
        if(!smi_recd[eConcMsgStrReq])
            `uvm_error($sformatf("%m (%s)", parent), "precedes str_req");

        gen_exp_smi__str_rsp = smi_seq_item::type_id::create("gen_exp_smi__str_rsp");
        gen_exp_smi__str_rsp.construct_strrsp(
										.smi_steer              (template.smi_steer),
                                        .smi_targ_ncore_unit_id (smi_recd[eConcMsgStrReq].smi_src_ncore_unit_id),
                                        .smi_src_ncore_unit_id  (smi_recd[eConcMsgStrReq].smi_targ_ncore_unit_id),
                                        .smi_msg_tier           (smi_recd[eConcMsgStrReq].smi_msg_tier),
                                        .smi_msg_qos            (smi_recd[eConcMsgStrReq].smi_msg_qos),
                                        .smi_msg_pri            (smi_recd[eConcMsgStrReq].smi_msg_pri),
                                        .smi_msg_type           (STR_RSP),
                                        .smi_msg_id             (template.smi_msg_id),
                                        .smi_msg_err            (template.smi_msg_err),

                                        .smi_cmstatus           (template.smi_cmstatus),
                                        .smi_tm                 (smi_recd[eConcMsgStrReq].smi_tm),
                                        .smi_rmsg_id            (smi_recd[eConcMsgStrReq].smi_msg_id)
                                        );
    endfunction : gen_exp_smi__str_rsp

    function void gen_exp_smi__dtr_req(input int m_size=0, input bit assign_data=1);
       smi_dp_concuser_t       dp_concuser[];
       axi4_read_data_pkt_t    tmp_axi__r;
       smi_seq_item            dtr_req_pkt_exp;
       bit ok;
       int dtr_size = (m_size==0) ? expd_dtr_beats : m_size;
       smi_dp_data_bit_t       smi_dp_data[];
       smi_dp_dbad_t           smi_dp_dbad[];

       smi_dp_data           = new[dtr_size];
       smi_dp_dbad           = new[dtr_size];
       this.dtr_smi_cmstatus = new[dtr_size];
       for(int i =0;i<dtr_size;i++)begin
         <% if (obj.DutInfo.useCmc) { %>
         if(sp_txn)begin
           smi_dp_data[i]     = this.sp_read_data_pkt.data[i]; 
           if(this.sp_read_data_pkt.poison[i])begin
             for (int j=0;j<(WXDATA/64);j++) begin
               smi_dp_dbad[i][j]   = '1;
             end
           end
         end
         else if(isCacheHit)begin
           smi_dp_data[i]     = this.cache_rd_data_pkt.data[i]; 
           if(this.cache_rd_data_pkt.poison[i])begin
             for (int j=0;j<(WXDATA/64);j++) begin
               smi_dp_dbad[i][j]   = '1;
             end
           end
         end
         else begin
         <% } %>
          if(!this.nackuce)begin
           smi_dp_data[i]     = this.axi_read_data_pkt.rdata[i]; 
          end
          else begin
           smi_dp_data[i]     = 0; 
           <% if (obj.DutInfo.useCmc) { %>
           this.dtr_smi_cmstatus[i]            = 8'b10000100;
           <% } %>
          end

          if(!this.nackuce)begin
            if(this.axi_read_data_pkt.rresp_per_beat[i] > 1)begin
              for (int j=0;j<(WXDATA/64);j++) begin
               smi_dp_dbad[i][j]   = '1;
              end
            end
            if (exmon_size > 0 ) begin
              if (m_exmon_status == EX_PASS) begin // Case of Exclusive Read
                if(this.axi_read_data_pkt.rresp_per_beat[i] == 2'b10)begin 
                   this.dtr_smi_cmstatus[i]            = 8'b10000011;
                end
                else if(this.axi_read_data_pkt.rresp_per_beat[i] == 2'b11)begin
                   this.dtr_smi_cmstatus[i]            = 8'b10000100;
                end
                else if(this.axi_read_data_pkt.rresp_per_beat[i] == 2'b00)begin
                   this.dtr_smi_cmstatus[i]            = 8'b00000001;
                end
              end
              else 
              begin // Case of Non-Exclusive Read
                if(this.axi_read_data_pkt.rresp_per_beat[i] == 2'b10)begin 
                  this.dtr_smi_cmstatus[i]            = 8'b10000011;
                end
                else if(this.axi_read_data_pkt.rresp_per_beat[i] == 2'b11)begin
                  this.dtr_smi_cmstatus[i]            = 8'b10000100;
                end
              end
            end
            else begin
              if(this.axi_read_data_pkt.rresp_per_beat[i] == 2'b10)begin 
                this.dtr_smi_cmstatus[i]            = 8'b10000011;
              end
              else if(this.axi_read_data_pkt.rresp_per_beat[i] == 2'b11)begin
                this.dtr_smi_cmstatus[i]            = 8'b10000100;
              end
              else if(this.axi_read_data_pkt.rresp_per_beat[i] == 2'b01)begin
                this.dtr_smi_cmstatus[i]            = 8'b00000001;
              end
            end
          end 
          else begin
            for (int j=0;j<(WXDATA/64);j++) begin
              smi_dp_dbad[i][j]   = '1;
            end
          end
          <% if (obj.DutInfo.useCmc) { %>
          end
          <% } %>
       end

       this.dtr_req_pkt_exp = smi_seq_item::type_id::create("dtr_req_pkt_exp");
       this.dtr_req_pkt_exp.smi_dp_data = new[dtr_size];
       this.dtr_req_pkt_exp.smi_dp_dbad = new[dtr_size];
       this.dtr_req_pkt_exp.smi_dp_dwid = new[dtr_size];

       foreach(smi_dp_data[j])begin
         if(assign_data) begin
           this.dtr_req_pkt_exp.smi_dp_data[j] = smi_dp_data[j];
         end
         this.dtr_req_pkt_exp.smi_dp_dbad[j] = smi_dp_dbad[j];
       end
       // #Check.DMI.DTRreq.Data
       this.DtrRdy = 1;
    endfunction : gen_exp_smi__dtr_req

    function smi_seq_item gen_exp_smi__dtr_rsp(smi_seq_item template = null);
        if (template == null) begin
            template = new();
         end
        
        if(!smi_recd[eConcMsgCmdReq])
            `uvm_error($sformatf("%m (%s)", parent), "precedes cmd_req");

        gen_exp_smi__dtr_rsp = smi_seq_item::type_id::create("gen_exp_smi__dtr_rsp");
        gen_exp_smi__dtr_rsp.construct_dtrrsp(
										.smi_steer              (template.smi_steer),
                                        .smi_targ_ncore_unit_id (smi_recd[eConcMsgDtrReq].smi_src_ncore_unit_id),
                                        .smi_src_ncore_unit_id  (smi_recd[eConcMsgDtrReq].smi_targ_ncore_unit_id),
                                        .smi_msg_tier           (smi_recd[eConcMsgDtrReq].smi_msg_tier),
                                        .smi_msg_qos            (smi_recd[eConcMsgDtrReq].smi_msg_qos),
                                        .smi_msg_pri            (smi_recd[eConcMsgDtrReq].smi_msg_pri),
                                        .smi_msg_type           (DTR_RSP),
                                        .smi_msg_id             (template.smi_msg_id),
                                        .smi_msg_err            (template.smi_msg_err),

                                        .smi_cmstatus           (template.smi_cmstatus),
                                        .smi_tm                 (smi_recd[eConcMsgDtrReq].smi_tm),
//                                        .smi_rl                 (template.smi_rl),                 //TODO FIXME remove
                                        .smi_rmsg_id            (smi_recd[eConcMsgDtrReq].smi_msg_id)
                                        );
    endfunction : gen_exp_smi__dtr_rsp



    function smi_seq_item gen_exp_smi__dtw_rsp(smi_seq_item template = null);
        if (template == null) begin
            template = new();
        //      //TODO random generation
        //      template = randomize( {constraints};)
        //      template.field =
        //      ...
         end
        
        if(!smi_recd[eConcMsgDtwReq])
            `uvm_error($sformatf("%m (%s)", parent), "precedes dtw_req");
        if(smi_recd[eConcMsgCmdReq].smi_vz)
             if(!axi_recd[axi_w])
                 `uvm_error($sformatf("%m (%s)", parent), "precedes axi_w");


        gen_exp_smi__dtw_rsp = smi_seq_item::type_id::create("gen_exp_smi__dtw_rsp");
        gen_exp_smi__dtw_rsp.construct_dtwrsp(
										.smi_steer              (template.smi_steer),
                                        .smi_targ_ncore_unit_id (smi_recd[eConcMsgDtwReq].smi_src_ncore_unit_id),
                                        .smi_src_ncore_unit_id  (smi_recd[eConcMsgDtwReq].smi_targ_ncore_unit_id),
                                        .smi_msg_tier           (smi_recd[eConcMsgDtwReq].smi_msg_tier),
                                        .smi_msg_qos            (smi_recd[eConcMsgDtwReq].smi_msg_qos),
                                        .smi_msg_pri            (smi_recd[eConcMsgDtwReq].smi_msg_pri),
                                        .smi_msg_type           (DTW_RSP),
                                        .smi_msg_id             (template.smi_msg_id),
                                        .smi_msg_err            (template.smi_msg_err),

                                        .smi_cmstatus           (template.smi_cmstatus),
                                        .smi_rl                 (template.smi_rl),                 //TODO FIXME remove
                                        .smi_tm                 (smi_recd[eConcMsgDtwReq].smi_tm),                 //TODO FIXME remove
                                        .smi_rmsg_id            (smi_recd[eConcMsgDtwReq].smi_msg_id)
                                        );

        //#CheckTime.DMI.DTWrsp.Sequence
        if( (smi_recd[eConcMsgDtwReq].smi_rl) && (!axi_recd[axi_b]))
            `uvm_error($sformatf("%m (%s)", parent), $sformatf("rsp violates rsp level"))

    endfunction : gen_exp_smi__dtw_rsp


    //DNE v3.0
    // function smi_seq_item gen_exp_smi__cme_rsp(smi_seq_item template = null);
    //     if (template == null) begin
    //         template = new();
    //     //      //TODO random generation
    //     //      template = randomize( {constraints};)
    //     //      template.field =
    //     //      ...
    //      end
        
    //     gen_exp_smi__cme_rsp = smi_seq_item::type_id::create("gen_exp_smi__cme_rsp");
    //     gen_exp_smi__cme_rsp.construct_cmersp(
										// .smi_steer              (template.smi_steer),
    //                                     .smi_targ_ncore_unit_id (smi_recd[template.smi_conc_rmsg_class].smi_src_ncore_unit_id),
    //                                     .smi_src_ncore_unit_id  (smi_recd[template.smi_conc_rmsg_class].smi_targ_ncore_unit_id),
    //                                     .smi_msg_tier           (smi_recd[template.smi_conc_rmsg_class].smi_msg_tier),
    //                                     .smi_msg_qos            (smi_recd[template.smi_conc_rmsg_class].smi_msg_qos),
    //                                     .smi_msg_pri            (smi_recd[template.smi_conc_rmsg_class].smi_msg_pri),
    //                                     .smi_msg_type           (CME_RSP),
    //                                     .smi_msg_id             (template.smi_msg_id),
    //                                     .smi_msg_err            (template.smi_msg_err),

    //                                     .smi_cmstatus           (template.smi_cmstatus),
    //                                     .smi_ecmd_type          (template.smi_ecmd_type ),                                       // TODO?  already know which msg had the error?
    //                                     .smi_rmsg_id            (smi_recd[template.smi_conc_rmsg_class].smi_msg_id)
    //                                 );
    // endfunction : gen_exp_smi__cme_rsp

    // function smi_seq_item gen_exp_smi__tre_rsp(smi_seq_item template = null);
    //     if (template == null) begin
    //         template = new();
    //     //      //TODO random generation
    //     //      template = randomize( {constraints};)
    //     //      template.field =
    //     //      ...
    //      end
        
    //     gen_exp_smi__tre_rsp = smi_seq_item::type_id::create("gen_exp_smi__tre_rsp");
    //     gen_exp_smi__tre_rsp.construct_trersp(
										// .smi_steer              (template.smi_steer),
    //                                     .smi_targ_ncore_unit_id (smi_recd[template.smi_conc_rmsg_class].smi_src_ncore_unit_id),
    //                                     .smi_src_ncore_unit_id  (smi_recd[template.smi_conc_rmsg_class].smi_targ_ncore_unit_id),
    //                                     .smi_msg_tier           (smi_recd[template.smi_conc_rmsg_class].smi_msg_tier),
    //                                     .smi_msg_qos            (smi_recd[template.smi_conc_rmsg_class].smi_msg_qos),
    //                                     .smi_msg_pri            (smi_recd[template.smi_conc_rmsg_class].smi_msg_pri),
    //                                     .smi_msg_type           (TRE_RSP),
    //                                     .smi_msg_id             (template.smi_msg_id),
    //                                     .smi_msg_err            (template.smi_msg_err),

    //                                     .smi_cmstatus           (template.smi_cmstatus),
    //                                     .smi_ecmd_type          (template.smi_ecmd_type ),                                       // TODO?  already know which msg had the error?
    //                                     .smi_rmsg_id            (smi_recd[template.smi_conc_rmsg_class].smi_msg_id)
    //                                 );
    // endfunction : gen_exp_smi__tre_rsp


    function axi4_read_addr_pkt_t gen_exp_axi__ar(axi4_read_addr_pkt_t template);

        gen_exp_axi__ar          = new();

        gen_exp_axi__ar.arid     = template.arid ;
        gen_exp_axi__ar.araddr   = template.araddr ;                                      // #Check.DMI.ar.Address
        gen_exp_axi__ar.arlen    = expd_arlen;                                       // #Check.DMI.ar.Length
        gen_exp_axi__ar.arsize   = expd_arsize;                                      // #Check.DMI.ar.Size
        gen_exp_axi__ar.arburst  = expd_arburst ;                                     // #Check.DMI.ar.Burst
        if(this.isNcRd && !this.isAtomic && this.cmd_req_pkt.smi_es && this.exmon_size == 0)begin
          if (this.cmd_req_pkt.smi_es) begin
            gen_exp_axi__ar.arid     = ({WAXID{1'b0}} | {this.cmd_req_pkt.smi_mpf2[WSMIMPF2-2:0],this.cmd_req_pkt.smi_src_id[WSMISRCID-1:WSMINCOREPORTID]});
             `uvm_info("<%=obj.BlockId%>:DMI_GEM_EXP_AXI_AR_EXCL", $sformatf("SMI_MPF2: %0h, SMI_SRC_ID: %0h",this.cmd_req_pkt.smi_mpf2[WSMIMPF2-2:0], this.cmd_req_pkt.smi_src_id[WSMISRCID-1:WSMINCOREPORTID]), UVM_LOW)
          end else begin
             gen_exp_axi__ar.arid     = this.cmd_req_pkt.smi_mpf2[WSMIMPF2-1:0];
          end
        end
        else begin
        gen_exp_axi__ar.arid     = template.arid ;
        end
        if(this.isNcRd && !this.isAtomic && this.exmon_size == 0)begin
          $cast(gen_exp_axi__ar.arlock   , this.cmd_req_pkt.smi_es) ;                                       // #Check.DMI.ar.Lock
        end
        else begin
          $cast(gen_exp_axi__ar.arlock   , 0) ;                                       // #Check.DMI.ar.Lock
        end
        $cast(gen_exp_axi__ar.arcache,4'b0010);                                      // #Check.DMI.Concerto.v3.0.arcache
        gen_exp_axi__ar.arprot   = {'b0,security,privileged} ; // #Check.DMI.ar.Protection
        gen_exp_axi__ar.arqos    = smi_qos ;                                      // #Check.DMI.ar.Qos
        gen_exp_axi__ar.arregion = 0 ;                                                     // TODO .arregion
        gen_exp_axi__ar.aruser   = smi_ndp_aux_ar ;                                  // #Check.DMI.ar.User
    endfunction : gen_exp_axi__ar

    function axi4_read_data_pkt_t gen_exp_axi__r(axi4_read_data_pkt_t template);
        if(!axi_recd[axi_ar])
            `uvm_error($sformatf("%m (%s)", parent), "precedes axi_ar");

        gen_exp_axi__r                = new();

        gen_exp_axi__r.rid            = axi_read_addr_pkt.arid ;  // #Check.DMI.r.Id
        gen_exp_axi__r.rdata          = template.rdata ;
        //gen_exp_axi__r.rresp          = template.rresp ;          // TODO? dne?
        gen_exp_axi__r.rresp_per_beat = template.rresp_per_beat ;
        gen_exp_axi__r.ruser          = template.ruser ;
    endfunction : gen_exp_axi__r

    function axi4_write_addr_pkt_t gen_exp_axi__aw(axi4_write_addr_pkt_t template);

        if(this.isWrThBypass)begin
         this.expd_awlen          = <%=(64/wdata)-1%>;
        end
        else begin
          this.expd_awlen         = (smi_size <= $clog2(<%=wdata%>)) ? 0 :(((2**smi_size)/(<%=wdata%>))-1);
        end
        this.expd_awburst       = (this.expd_awlen == 0) ? AXIINCR : AXIWRAP ;


        gen_exp_axi__aw          = new();

        gen_exp_axi__aw.awaddr   = template.awaddr ;                                 // #Check.DMI.Concerto.v3.0.Awaddr
        if(this.isNcWr && this.cmd_req_pkt.smi_es && this.exmon_size == 0)begin
           gen_exp_axi__aw.awid     = ({WAXID{1'b0}} | (this.cmd_req_pkt.smi_mpf2[WSMIMPF2-2:0]<<WSMINCOREUNITID) | (this.cmd_req_pkt.smi_src_id>>WSMINCOREPORTID));
        end
        else begin
          gen_exp_axi__aw.awid     = gen_exp_awid(this.cache_addr);                  // #Check.DMI.Concerto.v3.6.awidAddrIdMapping
        end
        gen_exp_axi__aw.awlen    = expd_awlen;                                       // #Check.DMI.Concerto.v3.0.awlen
        gen_exp_axi__aw.awsize   = expd_awsize;                                      // #Check.DMI.Concerto.v3.0.awsize
        gen_exp_axi__aw.awburst  = expd_awburst;                                     // #Check.DMI.Concerto.v3.0.awburst
        if(this.isNcWr && exmon_size == 0)begin
          $cast(gen_exp_axi__aw.awlock,this.cmd_req_pkt.smi_es);                     // #Check.DMI.Concerto.v3.0.awlock 
        end
        else begin
          $cast(gen_exp_axi__aw.awlock,0);                                           // #Check.DMI.Concerto.v3.0.awlock 
        end
        $cast(gen_exp_axi__aw.awcache,4'b0010);                                      // #Check.DMI.Concerto.v3.0.awcache
        gen_exp_axi__aw.awprot   = {'b0,security,privileged} ;                       // #Check.DMI.Concerto.v3.0.awprivilege
                                                                                     // #Check.DMI.Concerto.v3.0.awsecurity
        gen_exp_axi__aw.awqos    = smi_qos ;                                         // #Check.DMI.Concerto.v3.0.awqos
        gen_exp_axi__aw.awregion = 0;                                                // #Check.DMI.Concerto.v3.0.awregion
        gen_exp_axi__aw.awuser   = smi_ndp_aux_aw;                                   // #Check.DMI.Concerto.v3.0.awuser
    endfunction : gen_exp_axi__aw


    function axi4_write_data_pkt_t gen_exp_axi__w(axi4_write_data_pkt_t template);

        gen_exp_axi__w = new();
//# Check.DMI.Concerto.v3.0.wuser

<%if(obj.DutInfo.useCmc) { %>
        if(this.isEvict)begin
         this.smi_ndp_aux_w = 0;
        end
        else begin
<%}%>
         this.smi_ndp_aux_w = dtw_req_pkt.smi_ndp_aux; 
<%if(obj.DutInfo.useCmc) { %>
        end
<%}%>
//# Check.DMI.Concerto.v3.0.wdata

        gen_exp_axi__w.wdata = new[template.wdata.size()]; 
        gen_exp_axi__w.wstrb = new[template.wdata.size()]; 
<%if(obj.DutInfo.useCmc) { %>
          if(this.isEvict || this.isWrThBypass) begin
            for (i=0;i<$size(axi_write_data_pkt.wdata);i++) begin
              if(this.evictDataExpd)begin
                if(this.cache_evict_data_pkt != null) begin
                  gen_exp_axi__w.wdata[i] = this.cache_evict_data_pkt.data[i];
                    if(this.cache_evict_data_pkt.poison[i]) begin
                      gen_exp_axi__w.wstrb[i] = 0;
                    end
                    else begin
                      gen_exp_axi__w.wstrb[i] = this.cache_evict_data_pkt.byten[i];
                    end
                end // (this.cache_evict_data_pkt != null)
                else begin
                  gen_exp_axi__w.wdata[i] = 8'h0;
                  gen_exp_axi__w.wstrb[i] = 0;
                end
              end
              else begin
                gen_exp_axi__w.wdata[i] = this.cache_rd_data_pkt.data[i];
                  if(this.cache_rd_data_pkt.poison[i]) begin
                    gen_exp_axi__w.wstrb[i] = 0;
                  end
                  else begin
                    gen_exp_axi__w.wstrb[i] = this.cache_rd_data_pkt.byten[i];
                  end
              end
            end
          end
          else if(!this.isCacheHit) begin
<%}%>
            for (i=0;i<$size(this.axi_write_data_pkt.wdata);i++) begin
              gen_exp_axi__w.wdata[i] = this.dtw_req_pkt.smi_dp_data[i];
              for (int j=0;j<(WXDATA/64);j++) begin
                gen_exp_axi__w.wstrb[i][(j*8)+:8] = this.dtw_req_pkt.smi_dp_be[i][(j*8)+:8];
                //if(this.dtw_req_pkt.smi_dp_dbad[i][j] !== 0) begin
                //  gen_exp_axi__w.wstrb[i][(j*8)+:8] = 0;
                //end
                //else begin
                //  gen_exp_axi__w.wstrb[i][(j*8)+:8] = this.dtw_req_pkt.smi_dp_be[i][(j*8)+:8];
                //end
              end
              if(this.dtw_req_pkt.smi_dp_dbad[i] !== 0) begin
                gen_exp_axi__w.wstrb[i] = 0;
              end
            end
<%if(obj.DutInfo.useCmc) { %>
          end
<%}%>

        gen_exp_axi__w.wuser = smi_ndp_aux_w;                                      
    endfunction : gen_exp_axi__w

    function axi4_write_resp_pkt_t gen_exp_axi__b(axi4_write_resp_pkt_t template);
        if(!axi_recd[axi_w])
            `uvm_error($sformatf("%m (%s)", parent), "precedes axi_w");

        gen_exp_axi__b = new();

        gen_exp_axi__b.bid   = axi_write_addr_pkt.awid ;   // #Check.DMI.b.Id
        gen_exp_axi__b.bresp = template.bresp ;
        gen_exp_axi__b.buser = template.buser ;
    endfunction : gen_exp_axi__b
    
    function bit rb_is_done();
      if(RB_req_expd & RB_req_recd & RB_rsp_expd & RB_rsp_recd) begin
        return(1);
      end
      else begin
        return(0);
      end
    endfunction

    function is_axi_AW_pending();
      bit axi_AW_pending = (AXI_write_addr_expd && !AXI_write_addr_recd);
      bit lookup_complete = (lookupExpd && lookupSeen);
      bit coh_write_complete = (isCoh && RB_req_recd && DTW_req_recd);
      bit noncoh_write_complete = (!isCoh && STR_req_recd);

      <% if(obj.DutInfo.useCmc) { %>
      if( ((lookup_complete || isEvict) && axi_AW_pending) ||
          (coh_write_complete           && axi_AW_pending) ||
          (noncoh_write_complete        && axi_AW_pending)
        ) begin
        return(1);
      end
      else begin
        return(0);
      end
      <% } else {%>
      if((noncoh_write_complete && axi_AW_pending) ||
         (coh_write_complete    && axi_AW_pending)
        ) begin
        return(1);
      end
      else begin
        return(0);
      end
      <% } %>
    endfunction

    function is_axi_W_pending();
      if( (AXI_write_data_expd && !AXI_write_data_recd) ) begin
        return(1);
      end
      else begin
        return(0);
      end
    endfunction
endclass // dmi_scb_txn



