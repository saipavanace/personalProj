////////////////////////////////////////////////////////////////
// CCP  Interface
////////////////////////////////////////////////////////////////
<%
var TagPipe;
if(obj.Block === "dmi") { 
  TagPipe = obj.UseTagRamInputFlop + obj.UseTagRamOutputFlop;
} else {
  TagPipe = 0;
}
%>

import uvm_pkg::*;
`include "uvm_macros.svh"
interface <%=obj.BlockId%>_ccp_if (input clk, input rst_n);

  import <%=obj.BlockId%>_ccp_agent_pkg::*;
  //import             addr_trans_mgr_pkg::*;
    
   parameter ccp_setup_time = 1;
   parameter ccp_hold_time  = 0;

   int FILL_IF_DELAY_MIN        = 0; 
   int FILL_IF_DELAY_MAX        = 10; 
   int FILL_IF_BURST_PCT        = 80; 

   //------------------------------------------------------------
   // mailbox/Events to drive/collect data packets on all CCP if
   //------------------------------------------------------------
   ccp_filldata_pkt_t         cachefilldata_pkt_q[$]; 
<%/*if(obj.usePartialFill || obj.useCmc) { */%>
   ccp_filldata_pkt_t         cachefilldata_pkt_before_done_q[$]; 
<%/* } */%>
   ccp_fillctrl_pkt_t         fill_addr_q[$]; 
   ccp_fillctrl_pkt_t         fill_addr_pkt; 
   ccp_fillctrl_pkt_t         temp_fill_addr_pkt; 
   ccp_ctrlop_addr_t          temp_wayaddr;
   ccp_ctrlop_addr_t          temp_filladdr;
   ccp_ctrlfill_security_t    temp_secu;
   fill_addr_inflight_t       fill_addr_inflight_q[$];
   fill_addr_inflight_t       fill_addr_inflight_pkt;
   fill_addr_inflight_t       fill_rsp_pkt_q[$]; 
   fill_addr_inflight_t       temp_fill_rsp_pkt; 
   fill_addr_inflight_t       filldone_pkt;
   busy_index_way_t           busy_index_way_q[$];
   busy_index_way_t           busy_index_way_pkt;
   ccp_ctrlop_waybusy_vec_t   busyway;
   int                        core_id;
   <%if(obj.testBench === "io_aiu"){%>
    event                      e_fill_cacheline[<%=nNativeInterfacePorts%>];  
    event                      e_fill_complete[<%=nNativeInterfacePorts%>];  
    event                      e_fill_before_done_complete[<%=nNativeInterfacePorts%>];
    event                      e_ctrl_p0_complete[<%=nNativeInterfacePorts%>];  
    event                      e_ccp_ctrl_pkt[<%=nNativeInterfacePorts%>];
   <%}else {%>
    event                      e_fill_cacheline;  
    event                      e_fill_complete;  
    event                      e_fill_before_done_complete;
    event                      e_ctrl_p0_complete;  
    event                      e_ccp_ctrl_pkt;
  <%}%>
   int                        tmp_idx[$];
   int                        tmp_idxway[$];
   int                        tmp_idxp0[$];
   int                        tmp_idx_fill[$];
   int                        tmp_idx_fillc[$];
   int                        tmp_idx_done[$];
   int                        ccp_idx;
   int                        ccp_idx_q[$];
   int                        m_ccp_idx;
   int                        m_ccp_idx_q[$];
   ccp_ctrl_pkt_t             collect_ccp_ctrl_pkt_q[$];
   ccp_ctrl_pkt_t             temp_ccp_ctrl_pkt;
   bit [N_WAY-1:0]            nru_counter;
   bit                        alloc;
   bit                        rd_data;
   bit                        wr_data;
   bit                        port_sel;
   bit                        write_upgrade;
   bit                        t_pt_err;

   mailbox #(ccp_wr_data_pkt_t)                  ctrlwr_pkt           = new();
   mailbox #(ccp_ctrlstatus_seq_item)            p0_ctrlstatus_pkt    = new(1);
   mailbox #(ccp_ctrlstatus_seq_item)            p1_ctrlstatus_pkt    = new(1);
   mailbox #(ccp_ctrlstatus_seq_item)            p2_ctrlstatus_pkt    = new(1);
   mailbox #(ccp_filldata_pkt_t)                 cachefilldata_pkt    = new();
   mailbox #(ccp_fillctrl_pkt_t)                 cachefillctrl_pkt    = new();
   mailbox #(ccp_ctrl_pkt_t)                     mp00_for_mp1_ctrlstatus_pkt   = new(1);
<% for(var i= 0;i<TagPipe+2;i++){ %>
   mailbox #(ccp_ctrl_pkt_t)                     mp<%=i%>_ctrlstatus_pkt   = new(1);
<% } %>
   mailbox #(ccp_ctrl_pkt_t)                     mp11_ctrlstatus_pkt   = new(1);
   int bcnt,fbcnt,fdbcnt;
   int bnk,mbnk;
   ccp_ctrlfilldata_addr_t             fillmiss_addr;
   ccp_ctrlfilldata_wayn_t             filldata_wayn;

   ccp_ctrlop_security_t               fillmiss_security;
   //------------------------------------------------------------
   // CCP ctrl fill interface signal
   //------------------------------------------------------------
   ccp_ctrlfilldata_vld_logic_t       ctrl_filldata_vld;
   ccp_ctrlfill_data_logic_t          ctrl_fill_data;
   ccp_ctrlfilldata_Id_logic_t        ctrl_filldata_id;
   ccp_ctrlfilldata_addr_logic_t      ctrl_filldata_addr;
   ccp_ctrlfilldata_wayn_logic_t      ctrl_filldata_wayn;
   ccp_ctrlfilldata_beatn_logic_t     ctrl_filldata_beatn;

<%/*if(obj.usePartialFill || obj.useCmc) { */%>
   ccp_ctrlfilldata_byten_logic_t     ctrl_filldata_byten;
   ccp_ctrlfilldata_last_logic_t      ctrl_filldata_last;
<%/* } */%>
   ccp_cachefilldata_rdy_logic_t      cache_filldata_rdy;

   ccp_ctrlfill_vld_logic_t           ctrl_fill_vld;
   ccp_ctrlfill_addr_logic_t          ctrl_fill_addr;
   ccp_ctrlfilldata_wayn_logic_t      ctrl_fill_wayn;
   ccp_ctrlop_security_logic_t        ctrl_fill_security;
   ccp_ctrlfill_state_logic_t         ctrl_fill_state;
   ccp_cachefill_rdy_logic_t          cache_fill_rdy;
   ccp_cachefill_doneId_logic_t       cache_fill_done_id;
   ccp_cachefill_done_logic_t         cache_fill_done;

   //------------------------------------------------------------
   // CCP Evict data out interface signal
   //------------------------------------------------------------
   ccp_cache_evict_vld_logic_t        cache_evict_vld;
   ccp_cache_evict_data_logic_t       cache_evict_data;
   ccp_cache_evict_byten_t            cache_evict_byten;
   ccp_cache_evict_last_logic_t       cache_evict_last;
   ccp_cache_evict_cancel_logic_t     cache_evict_cancel;
   ccp_cache_evict_rdy_logic_t        cache_evict_rdy;

   //------------------------------------------------------------
   // CCP Read Rsp data out interface signal
   //------------------------------------------------------------
   ccp_cache_rdrsp_vld_logic_t        cache_rdrsp_vld;
   ccp_cache_rdrsp_data_logic_t       cache_rdrsp_data;
   ccp_cache_rdrsp_byten_t            cache_rdrsp_byten;
   ccp_cache_rdrsp_last_logic_t       cache_rdrsp_last;
   ccp_cache_rdrsp_cancel_logic_t     cache_rdrsp_cancel;
   ccp_cache_rdrsp_rdy_logic_t        cache_rdrsp_rdy;

   //------------------------------------------------------------
   // CCP scratchpad Read Rsp data out interface signal
   //------------------------------------------------------------
   ccp_cache_rdrsp_vld_logic_t        sp_rdrsp_vld;
   ccp_cache_rdrsp_data_logic_t       sp_rdrsp_data;
   ccp_cache_rdrsp_byten_t            sp_rdrsp_byten;
   ccp_cache_rdrsp_last_logic_t       sp_rdrsp_last;
   ccp_cache_rdrsp_rdy_logic_t        sp_rdrsp_rdy;
   ccp_cache_rdrsp_cancel_logic_t     sp_rdrsp_cancel;

   //------------------------------------------------------------
   // CCP scratchpad input interface signal
   //------------------------------------------------------------
   ccp_ctrlwr_vld_logic_t             sp_wr_vld;
   ccp_ctrlwr_data_logic_t            sp_wr_data;
   ccp_ctrlwr_byten_logic_t           sp_wr_byte_en; 
   ccp_ctrlwr_beatn_logic_t           sp_wr_beat_num;
   ccp_ctrlwr_last_logic_t            sp_wr_last;
   ccp_cachewr_rdy_logic_t            sp_wr_rdy;

   //------------------------------------------------------------
   // CCP scratchpad command interface signal
   //------------------------------------------------------------
   ccp_sp_ctrl_rdy_logic_t            sp_op_rdy;   
   ccp_sp_ctrl_vld_logic_t            sp_op_vld;   
   ccp_sp_ctrl_wr_data_logic_t        sp_op_wr_data;   
   ccp_sp_ctrl_rd_data_logic_t        sp_op_rd_data;
   ccp_sp_ctrl_index_addr_logic_t     sp_op_index_addr;
   ccp_sp_ctrl_data_bank_logic_t      sp_op_data_bank;
   ccp_sp_ctrl_way_num_logic_t        sp_op_way_num;
   ccp_sp_ctrl_beat_num_logic_t       sp_op_beat_num;
   ccp_sp_ctrl_burst_len_logic_t      sp_op_burst_len; 
   ccp_sp_ctrl_burst_type_logic_t     sp_op_burst_type;

   //------------------------------------------------------------
   // CCP Command and DataIn interface signal
   //------------------------------------------------------------
   ccp_ctrlwr_vld_logic_t             ctrl_wr_vld;
   ccp_ctrlwr_data_logic_t            ctrl_wr_data;
   ccp_ctrlwr_byten_logic_t           ctrl_wr_byte_en; 
   ccp_ctrlwr_beatn_logic_t           ctrl_wr_beat_num;
   ccp_ctrlwr_last_logic_t            ctrl_wr_last;
   ccp_cachewr_rdy_logic_t            cache_wr_rdy;

   ccp_ctrlop_vld_logic_t             ctrlop_vld;
   ccp_ctrlop_addr_logic_t            ctrlop_addr;
   ccp_ctrlop_security_t              ctrlop_security;
   ccp_cacheop_rdy_logic_t            cacheop_rdy;
   ccp_ctrlop_allocate_logic_t        ctrlop_allocate;
   ccp_ctrlop_rd_data_logic_t         ctrlop_rd_data;
   ccp_ctrlop_wr_data_logic_t         ctrlop_wr_data;
   ccp_ctrlop_port_sel_logic_t        ctrlop_port_sel;
   ccp_ctrlop_bypass_logic_t          ctrlop_bypass;
   ccp_ctrlop_rp_update_logic_t       ctrlop_rp_update;
   ccp_ctrlop_tagstateup_logic_t      ctrlop_tagstateup;
   ccp_cachestate_logic_t             ctrlop_state;
   ccp_ctrlop_burstln_logic_t         ctrlop_burstln;
   ccp_ctrlop_burstwrap_logic_t       ctrlop_burstwrap;
   ccp_ctrlop_setway_debug_logic_t    ctrlop_setway_debug;
   ccp_ctrlop_waybusy_vec_logic_t     ctrlop_waybusy_vec;
   ccp_ctrlop_waystale_vec_logic_t    ctrlop_waystale_vec;
   ccp_ctrlop_cancel_t                ctrlop_cancel;
   bit                                ctrlop_lookup_p2;
   bit                                ctrlop_retry;
   int                                ctrlop_pt_id_p2;


   ccp_cachestate_logic_t             cache_currentstate;
   ccp_cache_nru_vec_logic_t          cache_current_nru_vec;
   ccp_cache_vld_logic_t              cache_vld;
   ccp_cache_alloc_wayn_logic_t       cache_alloc_wayn;
   ccp_cache_hit_wayn_logic_t         cache_hit_wayn;

   bit [N_WAY-1:0]                    fake_hit_way;

   ccp_cache_evictvld_logic_t         cachectrl_evict_vld ;
   ccp_cache_evictaddr_logic_t        cache_evict_addr;
   ccp_cachestate_logic_t             cache_evict_state;
   ccp_cache_evictsecurity_t          cache_evict_security;
   ccp_cache_nackuce_logic_t          cache_nack_uce;
   ccp_cache_nack_logic_t             cache_nack;
   ccp_cache_nackce_logic_t           cache_nack_ce;
   ccp_cachenacknoalloc_logic_t       cache_nack_noalloc ;
   ccp_cachenoways2alloc_logic_t      cache_no_ways_2_alloc;


   csr_maint_wrdata_logic_t           maint_wrdata;
   csr_maint_req_opc_logic_t          maint_req_opcode;
   csr_maint_req_way_logic_t          maint_req_way;
   csr_maint_req_entry_logic_t        maint_req_entry;
   csr_maint_req_word_logic_t         maint_req_word;
   csr_maint_rddata_logic_t           maint_read_data;
   csr_maint_req_data_logic_t         maint_req_data;
   csr_maint_req_array_sel_logic_t    maint_req_array_sel;
   csr_maint_active_logic_t           maint_active;
   csr_maint_rddata_en_logic_t        maint_read_data_en;
   
   bit isRead;
   bit isWrite;
   bit isSnoop;
   bit isMntOp;
   bit isRead_Wakeup;
   bit isWrite_Wakeup;
   bit isSnoop_Wakeup;
   bit stale_vec_flag;


  bit   out_req_valid_p2;
  bit   read_hit;
  bit   read_miss_allocate;
  bit   write_hit;
  bit   write_miss_allocate;
  bit   snoop_hit;
  bit   write_hit_upgrade;
  bit   ccp_if_en ;  

  bit   isReplay;
  bit   toReplay;
  bit   isRecycle;
  bit   rttfull;
  bit   wttfull;
  bit   anywttfull;
  bit   cancel_p2;
  bit   wr_addr_fifo_full;
  bit   ccp_tt_full_p2;
  logic ccp_hnt_drop_p2; 
  logic [WSMIMSG-1:0] msgType_p0; 
  logic [WSMIMSG-1:0] msgType_p1; 
  logic [WSMIMSG-1:0] msgType_p2; 
  logic isCoh_p0; 
  logic isRply_vld_p0; 
  logic flush_fail_p2;

   bit isRead_p1;
   bit isWrite_p1;
   bit isSnoop_p1;
   bit isMntOp_p1;
   bit isRead_Wakeup_p1;
   bit isWrite_Wakeup_p1;
   bit isSnoop_Wakeup_p1;

   int posedge_count;
 //-----------------------------------------------------------------------
 // CCP clocking blocks
 //-----------------------------------------------------------------------

 clocking master_cb @(posedge clk);

    default input #ccp_setup_time output #ccp_hold_time;

    output  ctrl_filldata_vld;
    output  ctrl_fill_data;
    output  ctrl_filldata_id;
    output  ctrl_filldata_addr;
    output  ctrl_filldata_wayn;
    output  ctrl_filldata_beatn;
<%/*if(obj.usePartialFill || obj.useCmc) { */%>
    output  ctrl_filldata_byten;
    output  ctrl_filldata_last;
<%/* } */%>
    input   cache_filldata_rdy;
    input   cache_fill_done_id;
    input   cache_fill_done;

    output  ctrl_fill_vld;
    output  ctrl_fill_addr;
    output  ctrl_fill_wayn;
    output  ctrl_fill_security;
    output  ctrl_fill_state;
    input   cache_fill_rdy;

// scratchpad interface signals

    output  sp_rdrsp_vld;
    input   sp_rdrsp_data;
    input   sp_rdrsp_byten;
    input   sp_rdrsp_last;
    input   sp_rdrsp_rdy;
    input   sp_rdrsp_cancel;

    output  sp_wr_vld;
    output  sp_wr_data;
    output  sp_wr_byte_en; 
    output  sp_wr_beat_num;
    output  sp_wr_last;
    input   sp_wr_rdy;

    input   sp_op_rdy;   
    output  sp_op_vld;   
    output  sp_op_wr_data;   
    output  sp_op_rd_data;
    output  sp_op_index_addr;
    output  sp_op_data_bank;
    output  sp_op_way_num;
    output  sp_op_beat_num;
    output  sp_op_burst_len; 
    output  sp_op_burst_type;


   //------------------------------------------------------------
   // CCP Evict data out interface signal
   //------------------------------------------------------------
    input  cache_evict_vld;
    input  cache_evict_data;
    input  cache_evict_byten;
    input  cache_evict_last;
    input  cache_evict_cancel;
    output cache_evict_rdy;

   //------------------------------------------------------------
   // CCP Read Rsp data out interface signal
   //------------------------------------------------------------
    input  cache_rdrsp_vld;
    input  cache_rdrsp_data;
    input  cache_rdrsp_byten;
    input  cache_rdrsp_last;
    input  cache_rdrsp_cancel;
    output cache_rdrsp_rdy;

   //------------------------------------------------------------
   // CCP Command and DataIn interface signal
   //------------------------------------------------------------
    output  ctrl_wr_vld;
    output  ctrl_wr_data;
    output  ctrl_wr_byte_en; 
    output  ctrl_wr_beat_num;
    output  ctrl_wr_last;
    input   cache_wr_rdy;

    output  ctrlop_vld;
    output  ctrlop_addr;
    output  ctrlop_security;
    input   cacheop_rdy;
    output  ctrlop_allocate;
    output  ctrlop_rd_data;
    output  ctrlop_wr_data;
    output  ctrlop_port_sel;
    output  ctrlop_bypass;
    output  ctrlop_rp_update;
    output  ctrlop_tagstateup;
    output  ctrlop_state;
    output  ctrlop_burstln;
    output  ctrlop_burstwrap;
    output  ctrlop_setway_debug;
    output  ctrlop_waybusy_vec;
    output  ctrlop_waystale_vec;
    output  ctrlop_cancel;
    output  ctrlop_lookup_p2;
    output  ctrlop_retry;
    
    input   cache_currentstate;
    input   cache_vld;
    input   cache_alloc_wayn;
    input   cache_hit_wayn;
    input   fake_hit_way;
    input   cachectrl_evict_vld ;
    input   cache_evict_addr;
    input   cache_evict_security;
    input   cache_evict_state;
    input   cache_nack_uce;
    input   cache_nack;
    input   cache_nack_ce;
    input   cache_nack_noalloc ;
    input   cache_no_ways_2_alloc ;

   //------------------------------------------------------------
   // CCP CSR maintenace interface signal
   //------------------------------------------------------------
    output  maint_wrdata;
    output  maint_req_opcode;
    output  maint_req_way;
    output  maint_req_entry;
    output  maint_req_word;
    output  maint_req_data;
    output  maint_req_array_sel;
    input   maint_read_data;
    input   maint_active;
    input   maint_read_data_en;


   //------------------------------------------------------------
   // CCP Signals specific to NCBU
   //------------------------------------------------------------

    input isRead;
    input isWrite;
    input isSnoop;
    input isMntOp;

    input isRead_Wakeup;
    input isWrite_Wakeup;
    input isSnoop_Wakeup;

    input  out_req_valid_p2;
    input  read_hit;
    input  read_miss_allocate;
    input  write_hit;
    input  write_miss_allocate;
    input  snoop_hit;
    input  write_hit_upgrade;
    input  stale_vec_flag;



    input isRead_p1;
    input isWrite_p1;
    input isSnoop_p1;
    input isMntOp_p1;

    input isRead_Wakeup_p1;
    input isWrite_Wakeup_p1;
    input isSnoop_Wakeup_p1;

 endclocking:master_cb



 clocking monitor_cb @(negedge clk);

    default input #ccp_setup_time output #ccp_hold_time;

    input   nru_counter;
    input   ctrl_filldata_vld;
    input   ctrl_fill_data;
    input   ctrl_filldata_id;
    input   ctrl_filldata_addr;
    input   ctrl_filldata_wayn;
    input   ctrl_filldata_beatn;
<%/*if(obj.usePartialFill || obj.useCmc) { */%>
    input   ctrl_filldata_byten;
    input   ctrl_filldata_last;
<%/* } */%>
    input   cache_filldata_rdy;
    input   cache_fill_done_id;
    input   cache_fill_done;

    input   ctrl_fill_vld;
    input   ctrl_fill_addr;
    input   ctrl_fill_wayn;
    input   ctrl_fill_security;
    input   ctrl_fill_state;
    input   cache_fill_rdy;

//scratchpad interface signals
    input   sp_rdrsp_vld;
    input   sp_rdrsp_data;
    input   sp_rdrsp_byten;
    input   sp_rdrsp_last;
    input   sp_rdrsp_rdy;
    input   sp_rdrsp_cancel;

    input   sp_wr_vld;
    input   sp_wr_data;
    input   sp_wr_byte_en; 
    input   sp_wr_beat_num;
    input   sp_wr_last;
    input   sp_wr_rdy;

    input   sp_op_rdy;   
    input   sp_op_vld;   
    input   sp_op_wr_data;   
    input   sp_op_rd_data;
    input   sp_op_index_addr;
    input   sp_op_data_bank;
    input   sp_op_way_num;
    input   sp_op_beat_num;
    input   sp_op_burst_len; 
    input   sp_op_burst_type;
    input   msgType_p1; 
    //------------------------------------------------------------
    // CCP Evict data out interface signal
    //------------------------------------------------------------
    input  cache_evict_vld;
    input  cache_evict_data;
    input  cache_evict_byten;
    input  cache_evict_last;
    input  cache_evict_cancel;
    input  cache_evict_rdy;

    //------------------------------------------------------------
    // CCP Read Rsp data out interface signal
    //------------------------------------------------------------
    input  cache_rdrsp_vld;
    input  cache_rdrsp_data;
    input  cache_rdrsp_byten;
    input  cache_rdrsp_last;
    input  cache_rdrsp_cancel;
    input  cache_rdrsp_rdy;

    //------------------------------------------------------------
    // CCP Command and DataIn interface signal
    //------------------------------------------------------------
    input  ctrl_wr_vld;
    input  ctrl_wr_data;
    input  ctrl_wr_byte_en; 
    input  ctrl_wr_beat_num;
    input  ctrl_wr_last;
    input  cache_wr_rdy;

    input  ctrlop_vld;
    input  ctrlop_addr;
    input  ctrlop_security;
    input  cacheop_rdy;
    input  ctrlop_allocate;
    input  ctrlop_rd_data;
    input  ctrlop_wr_data;
    input  ctrlop_port_sel;
    input  ctrlop_bypass;
    input  ctrlop_rp_update;
    input  ctrlop_tagstateup;
    input  ctrlop_state;
    input  ctrlop_burstln;
    input  ctrlop_burstwrap;
    input  ctrlop_setway_debug;
    input  ctrlop_waybusy_vec;
    input  ctrlop_waystale_vec;
    input  ctrlop_cancel;
    input  ctrlop_lookup_p2;
    input  ctrlop_retry;
    input  ctrlop_pt_id_p2;
    input  cache_currentstate;
    input  cache_current_nru_vec;
    input  cache_vld;
    input  cache_alloc_wayn;
    input  cache_hit_wayn;
    input  fake_hit_way;
    input  cachectrl_evict_vld ;
    input  cache_evict_addr;
    input  cache_evict_security;
    input  cache_evict_state;
    input  cache_nack_uce;
    input  cache_nack;
    input  cache_nack_ce;
    input  cache_nack_noalloc ;
    input  cache_no_ways_2_alloc ;
    input  posedge_count;

   //------------------------------------------------------------
   // CCP CSR maintenace interface signal
   //------------------------------------------------------------
    input  maint_wrdata;
    input  maint_req_opcode;
    input  maint_req_way;
    input  maint_req_entry;
    input  maint_req_word;
    input  maint_req_data;
    input  maint_req_array_sel;
    input  maint_read_data;
    input  maint_active;
    input  maint_read_data_en;


   //------------------------------------------------------------
   // CCP Signals specific to NCBU
   //------------------------------------------------------------

    input isRead;
    input isWrite;
    input isSnoop;
    input isMntOp;

    input isRead_Wakeup;
    input isWrite_Wakeup;
    input isSnoop_Wakeup;

    input  out_req_valid_p2;
    input  read_hit;
    input  read_miss_allocate;
    input  write_hit;
    input  write_miss_allocate;
    input  snoop_hit;
    input  write_hit_upgrade;
    input  stale_vec_flag;

    input  isReplay;
    input  toReplay;
    input  isRecycle;
    input  cancel_p2;
    input  wr_addr_fifo_full;
    input  ccp_tt_full_p2;
    input  flush_fail_p2;
    input  rttfull;
    input  wttfull;
    input  anywttfull;
    input  ccp_hnt_drop_p2;
    input  msgType_p0;
    input  msgType_p2;
    input  isCoh_p0;
    input  isRply_vld_p0;

    input isRead_p1;
    input isWrite_p1;
    input isSnoop_p1;
    input isMntOp_p1;

    input isRead_Wakeup_p1;
    input isWrite_Wakeup_p1;
    input isSnoop_Wakeup_p1;
 
    input t_pt_err;

 endclocking:monitor_cb


 modport master (
    input   rst_n,
    output  ctrl_filldata_vld,
    output  ctrl_fill_data,
    output  ctrl_filldata_id,
    output  ctrl_filldata_addr,
    output  ctrl_filldata_wayn,
    output  ctrl_filldata_beatn,
<%/*if(obj.usePartialFill || obj.useCmc) { */%>
    output  ctrl_filldata_byten,
    output  ctrl_filldata_last,
<%/* } */%>
    input   cache_filldata_rdy,
    input   cache_fill_done_id,
    input   cache_fill_done,

    output  ctrl_fill_vld,
    output  ctrl_fill_addr,
    output  ctrl_fill_wayn,
    output  ctrl_fill_security,
    output  ctrl_fill_state,
    input   cache_fill_rdy,

   //------------------------------------------------------------
   // CCP Evict data out interface signal
   //------------------------------------------------------------
    input  cache_evict_vld,
    input  cache_evict_data,
    input  cache_evict_byten,
    input  cache_evict_last,
    input  cache_evict_cancel,
    output cache_evict_rdy,

   //------------------------------------------------------------
   // CCP Read Rsp data out interface signal
   //------------------------------------------------------------
    input  cache_rdrsp_vld,
    input  cache_rdrsp_data,
    input  cache_rdrsp_byten,
    input  cache_rdrsp_last,
    input  cache_rdrsp_cancel,
    output cache_rdrsp_rdy,

   //------------------------------------------------------------
   // CCP Command and DataIn interface signal
   //------------------------------------------------------------
    output  ctrl_wr_vld,
    output  ctrl_wr_data,
    output  ctrl_wr_byte_en, 
    output  ctrl_wr_beat_num,
    output  ctrl_wr_last,
    input   cache_wr_rdy,

    output  ctrlop_vld,
    output  ctrlop_addr,
    input   cacheop_rdy,
    output  ctrlop_allocate,
    output  ctrlop_rd_data,
    output  ctrlop_wr_data,
    output  ctrlop_port_sel,
    output  ctrlop_bypass,
    output  ctrlop_rp_update,
    output  ctrlop_tagstateup,
    output  ctrlop_state,
    output  ctrlop_burstln,
    output  ctrlop_burstwrap,
    output  ctrlop_setway_debug,
    output  ctrlop_waybusy_vec,
    output  ctrlop_waystale_vec,
    output  ctrlop_cancel,
    output  ctrlop_lookup_p2,
    output  ctrlop_retry,

    input   cache_currentstate,
    input   cache_current_nru_vec,
    input   cache_vld,
    input   cache_alloc_wayn,
    input   cache_hit_wayn,
    input   fake_hit_way,
    input   cachectrl_evict_vld,
    input   cache_evict_addr,
    input   cache_evict_security,
    input   cache_evict_state,
    input   cache_nack_uce,
    input   cache_nack,
    input   cache_nack_ce,
    input   cache_nack_noalloc,
    input   cache_no_ways_2_alloc,
   //------------------------------------------------------------
   // CCP CSR maintenace interface signal
   //------------------------------------------------------------
    output  maint_wrdata,
    output  maint_req_opcode,
    output  maint_req_way,
    output  maint_req_entry,
    output  maint_req_word,
    output  maint_req_data,
    output  maint_req_array_sel,
    input   maint_read_data,
    input   maint_active,
    input   maint_read_data_en,
    import aysnc_reset_ccpctrlstatus,
           aysnc_reset_ccpwr,
           aysnc_reset_ccpfillctrl,
           aysnc_reset_ccpfilldata,
           aysnc_reset_ccpctrlop_p0,
           aysnc_reset_ccpctrlstatus_p2,
           aysnc_reset_csr_maint_data,
           drive_ctrlstatus_data,
           drive_cachefill_data,
           drive_csr_maint_data,
           collect_ctrlwr_pkt,
           collect_ctrlstatus_p2_pkt,
           collect_ctrlstatus_pkt,
           collect_sp_ctrlstatus_pkt,
           collect_sp_wr_pkt,
           collect_sp_output_pkt,
           collect_filldone_pkt,
           collect_cachefilldata_pkt,
           collect_cachefilldata_before_done_pkt,
           collect_cachefillctrl_pkt,
           collect_cachefillmiss_pkt,
           collect_cacheevict_pkt,
           collect_cacherdrsp_pkt,  
           collect_cacherdrsp_per_beat_pkt,  
           collect_csr_maint_pkt
    ); 

//-----------------------------------------------------------------------
//output signal Not Unknown properties,it should not must be X or Z
//-----------------------------------------------------------------------
initial
  begin
     if($test$plusargs("ccp_if_disable")) begin
       ccp_if_en = 0;  
     end
     else begin
       ccp_if_en = 1;
     end
  end


/***********************************************************************************
Assertions: when nack | nackuce asserts, any CCP control signal should not assert

Boon mentioned on 09/14/18 that assertions on only rp_update, tag_state_up and
setway_debug are needed as other signals are ignored by CCP when nack signals assert
***********************************************************************************/

assert_rp_update_should_not_assert_when_nack_signals_asserts:
  assert property( @(posedge clk) disable iff (~rst_n)
    (cache_nack_ce | cache_nack_uce | cache_nack | (cache_nack_noalloc & ctrlop_allocate)) -> !ctrlop_rp_update)
  else `uvm_error("<%=obj.BlockId%> ERROR CCP IF", "ctrlop_rp_update asserted when nack signals are high");

assert_tagstateup_should_not_assert_when_nack_signals_asserts:
  assert property( @(posedge clk) disable iff (~rst_n)
    (cache_nack_ce | cache_nack_uce | cache_nack | (cache_nack_noalloc & ctrlop_allocate)) -> !ctrlop_tagstateup)
  else `uvm_error("<%=obj.BlockId%> ERROR CCP IF", "ctrlop_tagstateup asserted when nack signals are high");

assert_setway_debug_should_not_assert_when_nack_signals_asserts:
  assert property( @(posedge clk) disable iff (~rst_n)
    ((cache_nack_ce | cache_nack_uce | cache_nack | (cache_nack_noalloc & ctrlop_allocate)) &&
     (maint_req_opcode == 4'b1110) && (maint_req_array_sel == 1'b0)) -> !ctrlop_setway_debug)
  else `uvm_error("<%=obj.BlockId%> ERROR CCP IF", "ctrlop_setway_debug asserted when nack signals are high \
                  and Maintenance op write to tag array is going on");

// Assertions: No CCP interface signal should be unknown (X or Z) ever
assert_cachefilldata_rdy_not_x_z:
  assert property( @(posedge clk) disable iff (~rst_n)
    (!$isunknown(cache_filldata_rdy)))
  else `uvm_error("<%=obj.BlockId%> ERROR CCP IF", "cache_filldata_rdy must not be unknown.");

assert_ctrlfilldata_vld_not_x_z:
  assert property( @(posedge clk) disable iff (~rst_n)
    (!$isunknown(ctrl_filldata_vld)))
  else `uvm_error("<%=obj.BlockId%> ERROR CCP IF", "ctrl_filldata_vld must not be unknown.");

assert_ctrlfilldata_addr_not_x_z:
  assert property( @(posedge clk) disable iff (~rst_n)
    ctrl_filldata_vld |-> (!$isunknown(ctrl_filldata_addr)))
  else `uvm_error("<%=obj.BlockId%> ERROR CCP IF", "ctrl_filldata_addr must not be unknown.");

assert_ctrlfilldata_wayn_not_x_z:
  assert property( @(posedge clk) disable iff (~rst_n)
    ctrl_filldata_vld |-> (!$isunknown(ctrl_filldata_wayn)))
  else `uvm_error("<%=obj.BlockId%> ERROR CCP IF", "ctrl_filldata_wayn must not be unknown.");

assert_ctrlfilldata_id_not_x_z:
  assert property( @(posedge clk) disable iff (~rst_n)
    ctrl_filldata_vld |-> (!$isunknown(ctrl_filldata_id)))
  else `uvm_error("<%=obj.BlockId%> ERROR CCP IF", "ctrl_filldata_id must not be unknown.");

assert_ctrlfilldata_beatn_not_x_z:
  assert property( @(posedge clk) disable iff (~rst_n)
    ctrl_filldata_vld |-> (!$isunknown(ctrl_filldata_beatn)))
  else `uvm_error("<%=obj.BlockId%> ERROR CCP IF", "ctrl_filldata_beatn must not be unknown.");
<%if(obj.enPartialFill !== undefined || obj.usCmc) { %>
assert_ctrlfilldata_byten_not_x_z:
  assert property( @(posedge clk) disable iff (~rst_n)
    ctrl_filldata_vld |-> (!$isunknown(ctrl_filldata_byten)))
  else `uvm_error("<%=obj.BlockId%> ERROR CCP IF", "ctrl_filldata_byten must not be unknown.");

assert_ctrlfilldata_last_not_x_z:
  assert property( @(posedge clk) disable iff (~rst_n)
    ctrl_filldata_vld |-> (!$isunknown(ctrl_filldata_last)))
  else `uvm_error("<%=obj.BlockId%> ERROR CCP IF", "ctrl_filldata_last must not be unknown.");
<% } %>
assert_ctrlfill_data_not_x_z:
  assert property( @(posedge clk) disable iff (~rst_n)
    ctrl_filldata_vld |-> (!$isunknown(ctrl_fill_data)))
  else `uvm_error("<%=obj.BlockId%> ERROR CCP IF", "ctrl_fill_data must not be unknown.");

assert_cache_fill_done_id_not_x_z:
  assert property( @(posedge clk) disable iff (~rst_n)
    (!$isunknown(cache_fill_done_id)))
  else `uvm_error("<%=obj.BlockId%> ERROR CCP IF", "cache_fill_done_id must not be unknown.");

assert_cache_fill_done_not_x_z:
  assert property( @(posedge clk) disable iff (~rst_n)
    (!$isunknown(cache_fill_done)))
  else `uvm_error("<%=obj.BlockId%> ERROR CCP IF", "cache_fill_done must not be unknown.");

assert_cache_fill_rdy_x_z:
  assert property( @(posedge clk) disable iff (~rst_n)
    (!$isunknown(cache_fill_rdy)))
  else `uvm_error("<%=obj.BlockId%> ERROR CCP IF", "cache_fill_rdy must not be unknown.");

assert_ctrl_fill_vld_x_z:
  assert property( @(posedge clk) disable iff (~rst_n)
    (!$isunknown(ctrl_fill_vld)))
  else `uvm_error("<%=obj.BlockId%> ERROR CCP IF", "ctrl_fill_vld must not be unknown.");

assert_ctrl_fill_addr_x_z:
  assert property( @(posedge clk) disable iff (~rst_n)
    ctrl_fill_vld |-> (!$isunknown(ctrl_fill_addr)))
  else `uvm_error("<%=obj.BlockId%> ERROR CCP IF", "ctrl_fill_addr must not be unknown.");

assert_ctrl_fill_security_x_z:
  assert property( @(posedge clk) disable iff (~rst_n)
    ctrl_fill_vld |-> (!$isunknown(ctrl_fill_security)))
  else `uvm_error("<%=obj.BlockId%> ERROR CCP IF", "ctrl_fill_security must not be unknown.");

assert_ctrl_fill_wayn_x_z:
  assert property( @(posedge clk) disable iff (~rst_n)
    ctrl_fill_vld |-> (!$isunknown(ctrl_fill_wayn)))
  else `uvm_error("<%=obj.BlockId%> ERROR CCP IF", "ctrl_fill_wayn must not be unknown.");

assert_ctrl_fill_state_x_z:
  assert property( @(posedge clk) disable iff (~rst_n)
    ctrl_fill_vld |-> (!$isunknown(ctrl_fill_state)))
  else `uvm_error("<%=obj.BlockId%> ERROR CCP IF", "ctrl_fill_state must not be unknown.");

assert_cache_evict_vld_x_z:
  assert property( @(posedge clk) disable iff (~rst_n)
    (!$isunknown(cache_evict_vld)))
  else `uvm_error("<%=obj.BlockId%> ERROR CCP IF", "cache_evict_vld must not be unknown.");

assert_cache_evict_rdy_x_z:
  assert property( @(posedge clk) disable iff (~rst_n)
    (!$isunknown(cache_evict_rdy)))
  else `uvm_error("<%=obj.BlockId%> ERROR CCP IF", "cache_evict_rdy must not be unknown.");

assert_cache_evict_data_x_z:
  assert property( @(posedge clk) disable iff (~rst_n | ~ccp_if_en )
    cache_evict_vld |-> (!$isunknown(cache_evict_data)))
  else `uvm_error("<%=obj.BlockId%> ERROR CCP IF", "cache_evict_data must not be unknown.");

assert_cache_evict_byten_x_z:
  assert property( @(posedge clk) disable iff (~rst_n)
    cache_evict_vld |-> (!$isunknown(cache_evict_byten)))
  else `uvm_error("<%=obj.BlockId%> ERROR CCP IF", "cache_evict_byten must not be unknown.");

assert_cache_evict_last_x_z:
  assert property( @(posedge clk) disable iff (~rst_n)
    cache_evict_vld |-> (!$isunknown(cache_evict_last)))
  else `uvm_error("<%=obj.BlockId%> ERROR CCP IF", "cache_evict_last must not be unknown.");

assert_cache_evict_cancel_x_z:
  assert property( @(posedge clk) disable iff (~rst_n)
    cache_evict_vld |-> (!$isunknown(cache_evict_cancel)))
  else `uvm_error("<%=obj.BlockId%> ERROR CCP IF", "cache_evict_cancel must not be unknown.");

assert_cache_rdrsp_vld_x_z:
  assert property( @(posedge clk) disable iff (~rst_n)
    (!$isunknown(cache_rdrsp_vld)))
  else `uvm_error("<%=obj.BlockId%> ERROR CCP IF", "cache_rdrsp_vld must not be unknown.");

assert_cache_rdrsp_rdy_x_z:
  assert property( @(posedge clk) disable iff (~rst_n)
    (!$isunknown(cache_rdrsp_rdy)))
  else `uvm_error("<%=obj.BlockId%> ERROR CCP IF", "cache_rdrsp_rdy must not be unknown.");

assert_cache_rdrsp_data_x_z:
  assert property( @(posedge clk) disable iff (~rst_n)
    cache_rdrsp_vld |-> (!$isunknown(cache_rdrsp_data)))
  else `uvm_error("<%=obj.BlockId%> ERROR CCP IF", "cache_rdrsp_data must not be unknown.");

assert_cache_rdrsp_byten_x_z:
  assert property( @(posedge clk) disable iff (~rst_n)
    cache_rdrsp_vld |-> (!$isunknown(cache_rdrsp_byten)))
  else `uvm_error("<%=obj.BlockId%> ERROR CCP IF", "cache_rdrsp_byten must not be unknown.");

assert_cache_rdrsp_last_x_z:
  assert property( @(posedge clk) disable iff (~rst_n)
    cache_rdrsp_vld |-> (!$isunknown(cache_rdrsp_last)))
  else `uvm_error("<%=obj.BlockId%> ERROR CCP IF", "cache_rdrsp_last must not be unknown.");

assert_cache_rdrsp_cancel_x_z:
  assert property( @(posedge clk) disable iff (~rst_n)
    cache_rdrsp_vld |-> (!$isunknown(cache_rdrsp_cancel)))
  else `uvm_error("<%=obj.BlockId%> ERROR CCP IF", "cache_rdrsp_cancel must not be unknown.");

assert_cache_wr_rdy_x_z:
  assert property( @(posedge clk) disable iff (~rst_n)
    (!$isunknown(cache_wr_rdy)))
  else `uvm_error("<%=obj.BlockId%> ERROR CCP IF", "cache_wr_rdy must not be unknown.");

assert_ctrl_wr_vld_x_z:
  assert property( @(posedge clk) disable iff (~rst_n)
    (!$isunknown(ctrl_wr_vld)))
  else `uvm_error("<%=obj.BlockId%> ERROR CCP IF", "ctrl_wr_vld must not be unknown.");

assert_ctrl_wr_byte_en_x_z:
  assert property( @(posedge clk) disable iff (~rst_n)
   ctrl_wr_vld |->  (!$isunknown(ctrl_wr_byte_en)))
  else `uvm_error("<%=obj.BlockId%> ERROR CCP IF", "ctrl_wr_byte_en must not be unknown.");

assert_ctrl_wr_beat_num_x_z:
  assert property( @(posedge clk) disable iff (~rst_n)
    ctrl_wr_vld |-> (!$isunknown(ctrl_wr_beat_num)))
  else `uvm_error("<%=obj.BlockId%> ERROR CCP IF", "ctrl_wr_beat_num must not be unknown.");

assert_ctrl_wr_data_x_z:
  assert property( @(posedge clk) disable iff (~rst_n)
    ctrl_wr_vld |-> (!$isunknown(ctrl_wr_data)))
  else `uvm_error("<%=obj.BlockId%> ERROR CCP IF", "ctrl_wr_data must not be unknown.");

assert_ctrl_wr_last_x_z:
  assert property( @(posedge clk) disable iff (~rst_n)
    ctrl_wr_vld |-> (!$isunknown(ctrl_wr_last)))
  else `uvm_error("<%=obj.BlockId%> ERROR CCP IF", "ctrl_wr_last must not be unknown.");

assert_cacheop_rdy_x_z:
  assert property( @(posedge clk) disable iff (~rst_n)
    (!$isunknown(cacheop_rdy)))
  else `uvm_error("<%=obj.BlockId%> ERROR CCP IF", "cacheop_rdy must not be unknown.");

assert_cache_currentstate_x_z:
  assert property( @(posedge clk) disable iff (~rst_n | ~ccp_if_en )
    (!$isunknown(cache_currentstate)))
  else `uvm_error("<%=obj.BlockId%> ERROR CCP IF", "cache_currentstate must not be unknown.");
	
<%if (obj.useCache) {%>
<%if ((obj.AiuInfo[obj.Id].ccpParams.RepPolicy != "RANDOM") && (obj.AiuInfo[obj.Id].ccpParams.nWays>1)) {%>
  assert_cache_current_nru_vec_x_z:
  assert property( @(posedge clk) disable iff (~rst_n | ~ccp_if_en )
    (!$isunknown(cache_current_nru_vec)))
  else `uvm_error("<%=obj.BlockId%> ERROR CCP IF", "cache_current_nru_vec must not be unknown.");
<%}%>
<%}%>

assert_cache_vld_x_z:
  assert property( @(posedge clk) disable iff (~rst_n)
    (!$isunknown(cache_vld)))
  else `uvm_error("<%=obj.BlockId%> ERROR CCP IF", "cache_vld must not be unknown.");

assert_ctrlop_vld_x_z:
  assert property( @(posedge clk) disable iff (~rst_n)
    (!$isunknown(ctrlop_vld)))
  else `uvm_error("<%=obj.BlockId%> ERROR CCP IF", "ctrlop_vld must not be unknown.");

assert_ctrlop_addr_x_z:
  assert property( @(posedge clk) disable iff (~rst_n)
    ctrlop_vld |-> (!$isunknown(ctrlop_addr)))
  else `uvm_error("<%=obj.BlockId%> ERROR CCP IF", "ctrlop_addr must not be unknown.");

assert_ctrlop_security_x_z:
  assert property( @(posedge clk) disable iff (~rst_n)
    ctrlop_vld |-> (!$isunknown(ctrlop_security)))
  else `uvm_error("<%=obj.BlockId%> ERROR CCP IF", "ctrlop_security must not be unknown.");

assert_ctrlop_allocate_x_z:
  assert property( @(posedge clk) disable iff (~rst_n)
    cache_vld |-> (!$isunknown(ctrlop_allocate)))
  else `uvm_error("<%=obj.BlockId%> ERROR CCP IF", "ctrlop_allocate must not be unknown.");

assert_ctrlop_rd_data_x_z:
  assert property( @(posedge clk) disable iff (~rst_n)
    cache_vld |-> (!$isunknown(ctrlop_rd_data)))
  else `uvm_error("<%=obj.BlockId%> ERROR CCP IF", "ctrlop_rd_data must not be unknown.");

assert_ctrlop_wr_data_x_z:
  assert property( @(posedge clk) disable iff (~rst_n)
    cache_vld |-> (!$isunknown(ctrlop_wr_data)))
  else `uvm_error("<%=obj.BlockId%> ERROR CCP IF", "ctrlop_wr_data must not be unknown.");

assert_ctrlop_port_sel_x_z:
  assert property( @(posedge clk) disable iff (~rst_n)
    cache_vld |-> (!$isunknown(ctrlop_port_sel)))
  else `uvm_error("<%=obj.BlockId%> ERROR CCP IF", "ctrlop_port_sel must not be unknown.");

assert_ctrlop_bypass_x_z:
  assert property( @(posedge clk) disable iff (~rst_n)
    cache_vld |-> (!$isunknown(ctrlop_bypass)))
  else `uvm_error("<%=obj.BlockId%> ERROR CCP IF", "ctrlop_bypass must not be unknown.");

assert_ctrlop_rp_update_x_z:
  assert property( @(posedge clk) disable iff (~rst_n)
    cache_vld |-> (!$isunknown(ctrlop_rp_update)))
  else `uvm_error("<%=obj.BlockId%> ERROR CCP IF", "ctrlop_rp_update must not be unknown.");

assert_ctrlop_tagstaeup_x_z:
  assert property( @(posedge clk) disable iff (~rst_n)
    cache_vld |-> (!$isunknown(ctrlop_tagstateup)))
  else `uvm_error("<%=obj.BlockId%> ERROR CCP IF", "ctrlop_tagstateup must not be unknown.");

assert_ctrlop_state_x_z:
  assert property( @(posedge clk) disable iff (~rst_n)
    (cache_vld & ctrlop_tagstateup) |-> (!$isunknown(ctrlop_state)))
  else `uvm_error("<%=obj.BlockId%> ERROR CCP IF", "ctrlop_state must not be unknown.");

assert_ctrlop_burstln_x_z:
  assert property( @(posedge clk) disable iff (~rst_n)
    cache_vld |-> (!$isunknown(ctrlop_burstln)))
  else `uvm_error("<%=obj.BlockId%> ERROR CCP IF", "ctrlop_burstln must not be unknown.");

<% /*if(obj.Block === "dmi") { */%>
assert_ctrlop_burstwrap_x_z:
  assert property( @(posedge clk) disable iff (~rst_n)
    cache_vld |-> (!$isunknown(ctrlop_burstwrap)))
  else `uvm_error("<%=obj.BlockId%> ERROR CCP IF", "ctrlop_burstwrap must not be unknown.");
<%/* } */%>
assert_ctrlop_setway_debug_x_z:
  assert property( @(posedge clk) disable iff (~rst_n)
    cache_vld |-> (!$isunknown(ctrlop_setway_debug)))
  else `uvm_error("<%=obj.BlockId%> ERROR CCP IF", "ctrlop_setway_debug must not be unknown.");

assert_ctrlop_waybusy_vec_x_z:
  assert property( @(posedge clk) disable iff (~rst_n)
    cache_vld |-> (!$isunknown(ctrlop_waybusy_vec)))
  else `uvm_error("<%=obj.BlockId%> ERROR CCP IF", "ctrlop_waybusy_vec must not be unknown.");

assert_ctrlop_waystale_vec_x_z:
  assert property( @(posedge clk) disable iff (~rst_n)
    cache_vld |-> (!$isunknown(ctrlop_waystale_vec)))
  else `uvm_error("<%=obj.BlockId%> ERROR CCP IF", "ctrlop_waystale_vec must not be unknown.");

<% if(obj.nWays>1) { %>
assert_cache_alloc_wayn_x_z:
  assert property( @(posedge clk) disable iff (~rst_n)
    (!$isunknown(cache_alloc_wayn)))
  else `uvm_error("<%=obj.BlockId%> ERROR CCP IF", "cache_alloc_wayn must not be unknown.");
<% } %>

<% if(obj.nWays>1) { %>
assert_cache_hit_wayn_x_z:
  assert property( @(posedge clk) disable iff (~rst_n)
    (!$isunknown(cache_hit_wayn)))
  else `uvm_error("<%=obj.BlockId%> ERROR CCP IF", "cache_hit_wayn must not be unknown.");
<% } %>

<% if(obj.nWays>1) { %>
assert_fake_hit_way_x_z:
  assert property( @(posedge clk) disable iff (~rst_n)
    (!$isunknown(fake_hit_way)))
  else `uvm_error("<%=obj.BlockId%> ERROR CCP IF", "fake_hit_way must not be unknown.");
<% } %>

assert_cachectrl_evict_vld_x_z:
  assert property( @(posedge clk) disable iff (~rst_n)
    (!$isunknown(cachectrl_evict_vld)))
  else `uvm_error("<%=obj.BlockId%> ERROR CCP IF", "cachectrl_evict_vld must not be unknown.");

assert_cache_evict_addr_x_z:
  assert property( @(posedge clk) disable iff (~rst_n)
    (!$isunknown(cache_evict_addr)))
  else `uvm_error("<%=obj.BlockId%> ERROR CCP IF", "cache_evict_addr must not be unknown.");

assert_cache_evict_security_x_z:
  assert property( @(posedge clk) disable iff (~rst_n)
    (!$isunknown(cache_evict_security)))
  else `uvm_error("<%=obj.BlockId%> ERROR CCP IF", "cache_evict_security must not be unknown.");

assert_cache_evict_state_x_z:
  assert property( @(posedge clk) disable iff (~rst_n | ~ccp_if_en )
    (!$isunknown(cache_evict_state)))
  else `uvm_error("<%=obj.BlockId%> ERROR CCP IF", "cache_evict_state must not be unknown.");

assert_cache_nack_uce_x_z:
  assert property( @(posedge clk) disable iff (~rst_n)
    (!$isunknown(cache_nack_uce)))
  else `uvm_error("<%=obj.BlockId%> ERROR CCP IF", "cache_nack_uce must not be unknown.");

assert_cache_nack_x_z:
  assert property( @(posedge clk) disable iff (~rst_n)
    (!$isunknown(cache_nack)))
  else `uvm_error("<%=obj.BlockId%> ERROR CCP IF", "cache_nack must not be unknown.");

assert_cache_nack_ce_x_z:
  assert property( @(posedge clk) disable iff (~rst_n)
    (!$isunknown(cache_nack_ce)))
  else `uvm_error("<%=obj.BlockId%> ERROR CCP IF", "cache_nack_ce must not be unknown.");

assert_cache_nack_noalloc_x_z:
  assert property( @(posedge clk) disable iff (~rst_n)
    (!$isunknown(cache_nack_noalloc)))
  else `uvm_error("<%=obj.BlockId%> ERROR CCP IF", "cache_nack_noalloc must not be unknown.");

assert_maint_read_data_x_z:
  assert property( @(posedge clk) disable iff (~rst_n)
    (!$isunknown(maint_read_data)))
  else `uvm_error("<%=obj.BlockId%> ERROR CCP IF", "maint_read_data must not be unknown.");

assert_maint_active_x_z:
  assert property( @(posedge clk) disable iff (~rst_n)
    (!$isunknown(maint_active)))
  else `uvm_error("<%=obj.BlockId%> ERROR CCP IF", "maint_active must not be unknown.");

assert_maint_read_data_en_x_z:
  assert property( @(posedge clk) disable iff (~rst_n)
    (!$isunknown(maint_read_data_en)))
  else `uvm_error("<%=obj.BlockId%> ERROR CCP IF", "maint_read_data_en must not be unknown.");

<% if(obj.Block === "dmi") { %>
<% if(obj.useScratchpad) { %>
// No assertion on sp_op_data_bank as it is not driven from RTL
assert_sp_rdrsp_vld_x_z:
  assert property( @(posedge clk) disable iff (~rst_n)
    (!$isunknown(sp_rdrsp_vld)))
  else `uvm_error("<%=obj.BlockId%> ERROR CCP IF", "sp_rdrsp_vld must not be unknown.");

assert_sp_rdrsp_data_x_z:
  assert property( @(posedge clk) disable iff (~rst_n)
    (!$isunknown(sp_rdrsp_data)))
  else `uvm_error("<%=obj.BlockId%> ERROR CCP IF", "sp_rdrsp_data must not be unknown.");

assert_sp_rdrsp_byten_x_z:
  assert property( @(posedge clk) disable iff (~rst_n)
    (!$isunknown(sp_rdrsp_byten)))
  else `uvm_error("<%=obj.BlockId%> ERROR CCP IF", "sp_rdrsp_byten must not be unknown.");

assert_sp_rdrsp_last_x_z:
  assert property( @(posedge clk) disable iff (~rst_n)
    (!$isunknown(sp_rdrsp_last)))
  else `uvm_error("<%=obj.BlockId%> ERROR CCP IF", "sp_rdrsp_last must not be unknown.");

assert_sp_rdrsp_rdy_x_z:
  assert property( @(posedge clk) disable iff (~rst_n)
    (!$isunknown(sp_rdrsp_rdy)))
  else `uvm_error("<%=obj.BlockId%> ERROR CCP IF", "sp_rdrsp_rdy must not be unknown.");

assert_sp_rdrsp_cancel_x_z:
  assert property( @(posedge clk) disable iff (~rst_n)
    (!$isunknown(sp_rdrsp_cancel)))
  else `uvm_error("<%=obj.BlockId%> ERROR CCP IF", "sp_rdrsp_cancel must not be unknown.");

assert_sp_wr_vld_x_z:
  assert property( @(posedge clk) disable iff (~rst_n)
    (!$isunknown(sp_wr_vld)))
  else `uvm_error("<%=obj.BlockId%> ERROR CCP IF", "sp_wr_vld must not be unknown.");

assert_sp_wr_data_x_z:
  assert property( @(posedge clk) disable iff (~rst_n)
    sp_wr_vld |-> (!$isunknown(sp_wr_data)))
  else `uvm_error("<%=obj.BlockId%> ERROR CCP IF", "sp_wr_data must not be unknown.");

assert_sp_wr_byte_en_x_z:
  assert property( @(posedge clk) disable iff (~rst_n)
    sp_wr_vld |-> (!$isunknown(sp_wr_byte_en)))
  else `uvm_error("<%=obj.BlockId%> ERROR CCP IF", "sp_wr_byte_en must not be unknown.");

assert_sp_wr_beat_num_x_z:
  assert property( @(posedge clk) disable iff (~rst_n)
    sp_wr_vld |-> (!$isunknown(sp_wr_beat_num)))
  else `uvm_error("<%=obj.BlockId%> ERROR CCP IF", "sp_wr_beat_num must not be unknown.");

assert_sp_wr_last_x_z:
  assert property( @(posedge clk) disable iff (~rst_n)
    sp_wr_vld |-> (!$isunknown(sp_wr_last)))
  else `uvm_error("<%=obj.BlockId%> ERROR CCP IF", "sp_wr_last must not be unknown.");

assert_sp_wr_rdy_x_z:
  assert property( @(posedge clk) disable iff (~rst_n)
    (!$isunknown(sp_wr_rdy)))
  else `uvm_error("<%=obj.BlockId%> ERROR CCP IF", "sp_wr_rdy must not be unknown.");

assert_sp_op_rdy_x_z:
  assert property( @(posedge clk) disable iff (~rst_n)
    (!$isunknown(sp_op_rdy)))
  else `uvm_error("<%=obj.BlockId%> ERROR CCP IF", "sp_op_rdy must not be unknown.");

assert_sp_op_vld_x_z:
  assert property( @(posedge clk) disable iff (~rst_n)
    (!$isunknown(sp_op_vld)))
  else `uvm_error("<%=obj.BlockId%> ERROR CCP IF", "sp_op_vld must not be unknown.");

assert_sp_op_wr_data_x_z:
  assert property( @(posedge clk) disable iff (~rst_n)
    (!$isunknown(sp_op_wr_data)))
  else `uvm_error("<%=obj.BlockId%> ERROR CCP IF", "sp_op_wr_data must not be unknown.");

assert_sp_op_rd_data_x_z:
  assert property( @(posedge clk) disable iff (~rst_n)
    (!$isunknown(sp_op_rd_data)))
  else `uvm_error("<%=obj.BlockId%> ERROR CCP IF", "sp_op_rd_data must not be unknown.");

assert_sp_op_index_addr_x_z:
  assert property( @(posedge clk) disable iff (~rst_n)
    (!$isunknown(sp_op_index_addr)))
  else `uvm_error("<%=obj.BlockId%> ERROR CCP IF", "sp_op_index_addr must not be unknown.");

assert_sp_op_way_num_x_z:
  assert property( @(posedge clk) disable iff (~rst_n)
    (!$isunknown(sp_op_way_num)))
  else `uvm_error("<%=obj.BlockId%> ERROR CCP IF", "sp_op_way_num must not be unknown.");

assert_sp_op_beat_num_x_z:
  assert property( @(posedge clk) disable iff (~rst_n)
    (!$isunknown(sp_op_beat_num)))
  else `uvm_error("<%=obj.BlockId%> ERROR CCP IF", "sp_op_beat_num must not be unknown.");

assert_sp_op_burst_len_x_z:
  assert property( @(posedge clk) disable iff (~rst_n)
    (!$isunknown(sp_op_burst_len)))
  else `uvm_error("<%=obj.BlockId%> ERROR CCP IF", "sp_op_burst_len must not be unknown.");

assert_sp_op_burst_type_x_z:
  assert property( @(posedge clk) disable iff (~rst_n)
    (!$isunknown(sp_op_burst_type)))
  else `uvm_error("<%=obj.BlockId%> ERROR CCP IF", "sp_op_burst_type must not be unknown.");
<% } %>
<%} %>

   //----------------------------------------------------------------------- 
  // Reset ccp 
  //----------------------------------------------------------------------- 


  task automatic aysnc_reset_ccpctrlstatus();
    master_cb.ctrlop_vld                     <= 'b0;
    master_cb.ctrlop_addr                    <= 'b0;
    master_cb.ctrlop_security                <= 'b0;
    master_cb.ctrlop_allocate                <= 'b0;
    master_cb.ctrlop_rd_data                 <= 'b0;
    master_cb.ctrlop_wr_data                 <= 'b0;
    master_cb.ctrlop_port_sel                <= 'b0; 
    master_cb.ctrlop_bypass                  <= 'b0;
    master_cb.ctrlop_rp_update               <= 'b0;
    master_cb.ctrlop_tagstateup              <= 'b0;
    master_cb.ctrlop_state                   <= 'b0;
    master_cb.ctrlop_burstln                 <= 'b0;
    master_cb.ctrlop_burstwrap               <= 'b0;
    master_cb.ctrlop_setway_debug            <= 'b0;
    master_cb.ctrlop_waybusy_vec             <= 'b0;
    master_cb.ctrlop_waystale_vec            <= 'b0;
  endtask: aysnc_reset_ccpctrlstatus

  task automatic aysnc_reset_ccpctrlstatus_p2();
    master_cb.ctrlop_allocate                <= 'b0;
    master_cb.ctrlop_rd_data                 <= 'b0;
    master_cb.ctrlop_wr_data                 <= 'b0;
    master_cb.ctrlop_port_sel                <= 'b0; 
    master_cb.ctrlop_bypass                  <= 'b0;
    master_cb.ctrlop_rp_update               <= 'b0;
    master_cb.ctrlop_tagstateup              <= 'b0;
    master_cb.ctrlop_state                   <= 'b0;
    master_cb.ctrlop_burstln                 <= 'b0;
    master_cb.ctrlop_burstwrap               <= 'b0;
    master_cb.ctrlop_setway_debug            <= 'b0;
    master_cb.ctrlop_waybusy_vec             <= 'b0;
    master_cb.ctrlop_waystale_vec            <= 'b0;
  endtask: aysnc_reset_ccpctrlstatus_p2

  task automatic aysnc_reset_ccpfillctrl();
     master_cb.ctrl_fill_vld                 <= 'b0;
     master_cb.ctrl_fill_addr                <= 'b0;
     master_cb.ctrl_fill_wayn                <= 'b0;
     master_cb.ctrl_fill_security            <= 'b0;
     master_cb.ctrl_fill_state               <= 'b0;
  endtask: aysnc_reset_ccpfillctrl

  task automatic aysnc_reset_ccpfilldata();
     master_cb.ctrl_filldata_vld             <= 'b0;                 
     master_cb.ctrl_fill_data                <= 'b0;               
     master_cb.ctrl_filldata_id              <= 'b0;
     master_cb.ctrl_filldata_addr            <= 'b0;
     master_cb.ctrl_filldata_wayn            <= 'b0;
     master_cb.ctrl_filldata_beatn           <= 'b0;
<%/*if(obj.usePartialFill || obj.useCmc) { */%>
     master_cb.ctrl_filldata_byten           <= 'b0;
     master_cb.ctrl_filldata_last            <= 'b0;
<%/* } */%>
  endtask: aysnc_reset_ccpfilldata

  task automatic aysnc_reset_ccpwr();
    master_cb.ctrl_wr_vld                    <= 'b0;
    master_cb.ctrl_wr_data                   <= 'b0;
    master_cb.ctrl_wr_byte_en                <= 'b0; 
    master_cb.ctrl_wr_beat_num               <= 'b0;
    master_cb.ctrl_wr_last                   <= 'b0;
  endtask: aysnc_reset_ccpwr

  task automatic aysnc_reset_ccpctrlop_p0();
    master_cb.ctrlop_vld                     <= 'b0;
    master_cb.ctrlop_addr                    <= 'b0; 
    master_cb.ctrlop_security                <= 'b0;
  endtask: aysnc_reset_ccpctrlop_p0

  task automatic aysnc_reset_csr_maint_data();
    master_cb.maint_wrdata                   <= 'b0;
    master_cb.maint_req_opcode               <= 'b0; 
    master_cb.maint_req_way                  <= 'b0;
    master_cb.maint_req_entry                <= 'b0;
    master_cb.maint_req_word                 <= 'b0;
    master_cb.maint_req_data                 <= 'b0;
    master_cb.maint_req_array_sel            <= 'b0;
  endtask: aysnc_reset_csr_maint_data
  //----------------------------------------------------------------------- 
  // Drive  ccp csr maintenance data  port 
  //----------------------------------------------------------------------- 
  
  task automatic drive_csr_maint_data (ccp_csr_maint_seq_item pkt); 
      
      ccp_csr_maint_pkt_t m_pkt;
      if (rst_n == 0) begin
              return;
      end
      wait (rst_n == 1);
      @(master_cb)
       master_cb.maint_wrdata                   <= m_pkt.wrdata;
       master_cb.maint_req_opcode               <= m_pkt.opcode; 
       master_cb.maint_req_way                  <= m_pkt.wayn;
       master_cb.maint_req_entry                <= m_pkt.entry;
       master_cb.maint_req_word                 <= m_pkt.word;
       master_cb.maint_req_data                 <= m_pkt.reqdata;
       master_cb.maint_req_array_sel            <= m_pkt.arraysel;
  endtask
  //----------------------------------------------------------------------- 
  // collect fill ctrl for monitor
  //----------------------------------------------------------------------- 
   task automatic collect_csr_maint_pkt(ref ccp_csr_maint_pkt_t pkt);
     bit                     done =0;  

     do begin
        @(monitor_cb);
         if(!rst_n) begin
          return;
         end
        if (monitor_cb.maint_read_data_en & rst_n) begin
          pkt.wrdata               = monitor_cb.maint_wrdata;      
          pkt.opcode               = monitor_cb.maint_req_opcode;  
          pkt.wayn                 = monitor_cb.maint_req_way;     
          pkt.entry                = monitor_cb.maint_req_entry;   
          pkt.word                 = monitor_cb.maint_req_word;    
          pkt.reqdata              = monitor_cb.maint_req_data;    
          pkt.arraysel             = monitor_cb.maint_req_array_sel;    
          pkt.rddata               = monitor_cb.maint_read_data;   
          pkt.active               = monitor_cb.maint_active;      
          pkt.rddata_en            = monitor_cb.maint_read_data_en;
          pkt.t_pkt_seen_on_intf = $time;
          done = 1;
        end
     end while(!done);
   // uvm_report_info("ccp_if", $sformatf("%t:mon ccp_csr_maint_pkt: %s", $time, pkt.sprint_pkt()), UVM_HIGH);
   endtask : collect_csr_maint_pkt
  //----------------------------------------------------------------------- 
  // Drive  ccp_ctrlstatus port 
  //----------------------------------------------------------------------- 
  
  task automatic  drive_ctrlstatus_data (ccp_ctrlstatus_seq_item pkt); 
  
      if(rst_n == 0) begin
              return;
      end
      wait (rst_n == 1);
      $display("Putting the ctrl_status_pkt into the p0_ctrlstatus_pkt queue");
      p0_ctrlstatus_pkt.put(pkt);
 
    //  wait(e_ctrl_p0_complete[core_id].triggered); 
  endtask

   <% /*if((obj.testBench == "ccp_ncb") || (obj.testBench == "ccp_dmi")){*/%>
initial
     begin
     time t_ctrlwr_sent;
     time t_p0_ctrlstatus_sent;
     time t_p1_ctrlstatus_sent;
     time t_p2_ctrlstatus_sent;
     bit  was_cache_wr_rdy_set_already;
     bit  was_cacheop_rdy_set_already;
     bit  push_wr_bypass_data;
     ccp_ctrlstatus_seq_item pktp0,pktp1,temp_pktp2,pktp2;
     ccp_wr_data_pkt_t     wrpkt;
     ccp_wr_data_pkt_t   m_wrpkt;
     int  m_dly;
     bit wrdone,ctrldone;
         fork
           begin
             forever
             begin
               wrpkt = new();
               wrdone = 0;
               bcnt = 0;
             //  m_dly = ($urandom_range(1,100) <=CTRL_DATA_IF_BURST_PCT) ? 0 : ($urandom_range(CTRL_DATA_IF_DELAY_MIN,CTRL_DATA_IF_DELAY_MAX));
               if(ctrlwr_pkt.try_get(wrpkt)) begin
                 t_ctrlwr_sent = $time;
                 was_cache_wr_rdy_set_already =1;
                 `uvm_info("ccp_if", $sformatf("%t: ctrlwrpkt: %s", t_ctrlwr_sent, wrpkt.sprint_pkt()), UVM_HIGH);
    
                 do begin 
                     master_cb.ctrl_wr_vld       <= 1;
                     master_cb.ctrl_wr_data      <= {wrpkt.poison[0],wrpkt.data[0]};
                     master_cb.ctrl_wr_byte_en   <= wrpkt.byten[0]; 
                     master_cb.ctrl_wr_beat_num  <= wrpkt.beatn[0]; 
                     master_cb.ctrl_wr_last      <= wrpkt.last; 
                     if(master_cb.cache_wr_rdy == 1 && t_ctrlwr_sent !== $time)begin
                      wrdone = 1;
                     end
                     else begin
                      was_cache_wr_rdy_set_already =0;
                     end
                     if (!wrdone || was_cache_wr_rdy_set_already ) begin
                      @(master_cb);
                     end
                 end 
                 while(!wrdone);
               end
               else begin
                 aysnc_reset_ccpwr();
                 @(master_cb);
               end
             end
           end
           begin
             forever
             begin
               ctrldone = 0;
               pktp0 = new();
               aysnc_reset_ccpctrlop_p0();
               //@(master_cb);
               if(p0_ctrlstatus_pkt.try_get(pktp0))begin
                 t_p0_ctrlstatus_sent = $time;
                 was_cacheop_rdy_set_already = 1;
                 `uvm_info("ccp_if", $sformatf("%t: ctrlstatuspkt p0: %s", t_p0_ctrlstatus_sent, pktp0.m_ctrlstatus_pkt.sprint_pkt()), UVM_HIGH);
                 do begin 
                  // if (m_dly > 0) begin
                  //   aysnc_reset_ccpctrlop_p0();
                  //   @(master_cb);
                  //   if (rst_n == 0) begin
                  //       break;
                  //   end
                  //   m_dly--;
                  // end
                  // else begin
                     bnk                                                <= pktp0.m_ctrlstatus_pkt.bnk;
                     master_cb.ctrlop_vld[pktp0.m_ctrlstatus_pkt.bnk]   <= 1;
                     master_cb.ctrlop_addr                              <= pktp0.m_ctrlstatus_pkt.addr; 
                     master_cb.ctrlop_security                          <= pktp0.m_ctrlstatus_pkt.security;
                     tmp_idxp0 = {};
                     tmp_idxp0 = fill_addr_inflight_q.find_first_index with (item.addr[WCCPADDR-1:CACHELINE_OFFSET] == pktp0.m_ctrlstatus_pkt.addr[WCCPADDR-1:CACHELINE_OFFSET] &&
                                                                             item.secu == pktp0.m_ctrlstatus_pkt.security);
                     if(tmp_idxp0.size() >0) begin
                       `uvm_info("ccp_if", $sformatf("%t: addr is in fill_addr_inflight_q ctrlstatuspkt p0: %s", t_p0_ctrlstatus_sent, pktp0.m_ctrlstatus_pkt.sprint_pkt()), UVM_HIGH);
                       pktp0.m_ctrlstatus_pkt.alloc   = 0;
                       pktp0.m_ctrlstatus_pkt.rd_data = 0;
                       pktp0.m_ctrlstatus_pkt.wr_data = 0;
                       pktp0.m_ctrlstatus_pkt.bypass  = 0;
                     end

                     if(master_cb.cacheop_rdy[bnk] == 1 && t_p0_ctrlstatus_sent !== $time)begin
                       <%if(obj.testBench === "io_aiu"){%>
                        ->e_ctrl_p0_complete[core_id]; 
                      <%} else {%>
                        ->e_ctrl_p0_complete; 
                      <%}%>
                      p1_ctrlstatus_pkt.put(pktp0);   
                      ctrldone = 1;
                     end
                     else begin
                       was_cacheop_rdy_set_already = 0;
                     end
                     if (!ctrldone || was_cacheop_rdy_set_already ) begin
                      @(master_cb);
                     end
                  //   end
                 end while(!ctrldone);
               end
               else begin
                 aysnc_reset_ccpctrlop_p0();
                 @(master_cb);
               end
             end
           end
           begin
             forever
             begin
               pktp1 = new();
               @(master_cb);
               if(p1_ctrlstatus_pkt.try_get(pktp1)) begin
                 t_p1_ctrlstatus_sent = $time;
                 uvm_report_info("ccp_if", $sformatf("%t: ctrlstatuspkt p1: %s", t_p1_ctrlstatus_sent, pktp1.m_ctrlstatus_pkt.sprint_pkt()), UVM_HIGH);
                 p2_ctrlstatus_pkt.put(pktp1);
               end
             end
           end
           begin
             forever
              begin
                 temp_pktp2 = new();
                 if(p2_ctrlstatus_pkt.try_get(temp_pktp2))begin
                 @(master_cb)
                   pktp2 = new();
                   $cast(pktp2,temp_pktp2);
                   t_p2_ctrlstatus_sent = $time;
                   uvm_report_info("ccp_if", $sformatf("%t: ctrlstatuspkt p2: %s", t_p2_ctrlstatus_sent, pktp2.m_ctrlstatus_pkt.sprint_pkt()), UVM_HIGH);
                   uvm_report_info("ccp_if", $sformatf("%t: ctrlstatuspkt data p2: %s", t_p2_ctrlstatus_sent, pktp2.m_wr_pkt.sprint_pkt()), UVM_HIGH);
                   tmp_idx = {};
                   tmp_idx = fill_addr_inflight_q.find_first_index with (item.addr[WCCPADDR-1:CACHELINE_OFFSET] == pktp2.m_ctrlstatus_pkt.addr[WCCPADDR-1:CACHELINE_OFFSET] &&
                                                                         item.secu == pktp2.m_ctrlstatus_pkt.security);
                   
                  // `uvm_info("CCP_IF",$sformatf("fill data fill_addr_inflight_q :%p",fill_addr_inflight_q),UVM_HIGH);   
                   if(tmp_idx.size()>0) begin
                     `uvm_info("CCP_IF",$sformatf("fill addr :0%0x secu :%0b",fill_addr_inflight_q[tmp_idx[0]].addr,fill_addr_inflight_q[tmp_idx[0]].secu),UVM_HIGH);   
                   end
                   busyway = get_busy_way(pktp2.m_ctrlstatus_pkt.addr,busy_index_way_q);
                 // `uvm_info("body",$sformatf("busyway :%0b busy way sb: %p",busyway,busy_index_way_q), UVM_HIGH)
           
                  push_wr_bypass_data                 =  1'b0;
                  rd_data                             =  1'b0;
                  wr_data                             =  1'b0;
                  write_upgrade                       =  1'b0;
                  port_sel                            =  1'b0;
                  temp_filladdr                       = pktp2.m_ctrlstatus_pkt.addr; 
                  temp_secu                           = pktp2.m_ctrlstatus_pkt.security;
                  
      
                //  `uvm_info("SATYA CCP IF",$sformatf("cache_nack_noalloc :%0b cache_currentstate :%0b wayn :%0d ",cache_nack_noalloc,cache_currentstate,onehot_to_binary(cache_wayn)),UVM_HIGH);
                  if((cache_nack == 1 && !cache_nack_ce && !cache_nack_uce ) || cache_nack_uce || tmp_idx.size()>0 ||  (busyway[onehot_to_binary(cache_alloc_wayn)] == 1'b1) ) begin
                    master_cb.ctrlop_rd_data          <= 0;
                    master_cb.ctrlop_wr_data          <= 0;
                    master_cb.ctrlop_allocate         <= 0;
                    master_cb.ctrlop_bypass           <= 0;
                    master_cb.ctrlop_rp_update        <= 0;
                  end else if(cache_vld == 1'b1 && cache_currentstate == <%=obj.BlockId + '_ccp_agent_pkg'%>::IX && (pktp2.m_ctrlstatus_pkt.rd_data ==1'b1 || pktp2.m_ctrlstatus_pkt.wr_data == 1'b1 || 
                                                                                pktp2.m_ctrlstatus_pkt.bypass == 1'b1 || pktp2.m_ctrlstatus_pkt.alloc == 1'b1 )) begin
                    master_cb.ctrlop_wr_data          <= 0;
                    master_cb.ctrlop_rp_update        <= 0;
                    master_cb.ctrlop_burstln          <= pktp2.m_ctrlstatus_pkt.burstln;
                    master_cb.ctrlop_burstwrap        <= pktp2.m_ctrlstatus_pkt.burstwrap;
                    master_cb.ctrlop_allocate         <= pktp2.m_ctrlstatus_pkt.alloc;
                    if(pktp2.m_ctrlstatus_pkt.bypass == 1'b1) begin
                      push_wr_bypass_data             =  1'b1;
                      master_cb.ctrlop_bypass         <= pktp2.m_ctrlstatus_pkt.bypass;
                    end begin
                      push_wr_bypass_data             =  0;
                      master_cb.ctrlop_bypass         <= 0;
                    end
                  end 
                  <% if (obj.Block !== "dmi") { %>
                     else if(cache_vld == 1'b1 && (cache_currentstate == <%=obj.BlockId + '_ccp_agent_pkg'%>::SC || cache_currentstate == <%=obj.BlockId + '_ccp_agent_pkg'%>::UC)  && (pktp2.m_ctrlstatus_pkt.wr_data == 1'b1 && !pktp2.m_ctrlstatus_pkt.bypass)) begin
                  <% } else { %>
                     else if(cache_vld == 1'b1 && (cache_currentstate == <%=obj.BlockId + '_ccp_agent_pkg'%>::SC)  && (pktp2.m_ctrlstatus_pkt.wr_data == 1'b1 && !pktp2.m_ctrlstatus_pkt.bypass)) begin
                  <% } %>
                    master_cb.ctrlop_burstln          <= pktp2.m_ctrlstatus_pkt.burstln;
                    master_cb.ctrlop_burstwrap        <= pktp2.m_ctrlstatus_pkt.burstwrap;
                    master_cb.ctrlop_wr_data          <= 0;
                    master_cb.ctrlop_allocate         <= 0;
                    master_cb.ctrlop_bypass           <= 0;
                    master_cb.ctrlop_rp_update        <= 1'b1;
                    write_upgrade                     =  1'b1; // NAVEEN- what is writeupgrade? The above condition indicates write hit
                  end else if((cache_vld == 1'b1 && cache_currentstate != <%=obj.BlockId + '_ccp_agent_pkg'%>::IX && (pktp2.m_ctrlstatus_pkt.rd_data ==1'b1 && pktp2.m_ctrlstatus_pkt.wr_data == 1'b1))) begin
                    master_cb.ctrlop_burstln          <= pktp2.m_ctrlstatus_pkt.burstln;
                    master_cb.ctrlop_burstwrap        <= pktp2.m_ctrlstatus_pkt.burstwrap;
                    master_cb.ctrlop_wr_data          <= pktp2.m_ctrlstatus_pkt.wr_data;
                    master_cb.ctrlop_allocate         <= 0;
                    master_cb.ctrlop_bypass           <= 0;
                    master_cb.ctrlop_rp_update        <= 1'b1;
                    push_wr_bypass_data               =  1'b1;
                    wr_data                           = pktp2.m_ctrlstatus_pkt.wr_data;
                  end else if(cache_vld == 1'b1 && cache_currentstate != <%=obj.BlockId + '_ccp_agent_pkg'%>::IX && (pktp2.m_ctrlstatus_pkt.rd_data ==1'b1 || (pktp2.m_ctrlstatus_pkt.wr_data == 1'b1) ||
                                                   ( pktp2.m_ctrlstatus_pkt.wr_data == 1'b1 && pktp2.m_ctrlstatus_pkt.bypass == 1'b1))) begin // NAVEEN- Revist the condition
                    if(pktp2.m_ctrlstatus_pkt.wr_data == 1'b1 ) begin
                      push_wr_bypass_data             =  1'b1;
                      master_cb.ctrlop_bypass         <= pktp2.m_ctrlstatus_pkt.bypass;
                    end else begin
                      push_wr_bypass_data             =  0;
                      master_cb.ctrlop_bypass         <= 0;
                    end
                     rd_data                         = pktp2.m_ctrlstatus_pkt.rd_data;
                     master_cb.ctrlop_wr_data        <= pktp2.m_ctrlstatus_pkt.wr_data;
                     master_cb.ctrlop_burstln        <= pktp2.m_ctrlstatus_pkt.burstln;
                     master_cb.ctrlop_burstwrap      <= pktp2.m_ctrlstatus_pkt.burstwrap;
                     master_cb.ctrlop_rp_update      <= 1'b1;
                     master_cb.ctrlop_allocate       <= 0;
                  end else  begin
                    master_cb.ctrlop_rd_data          <= 0;
                    master_cb.ctrlop_wr_data          <= 0;
                    master_cb.ctrlop_allocate         <= 0;
                    master_cb.ctrlop_bypass           <= 0;
                    master_cb.ctrlop_rp_update        <= 0;
                  end
                   master_cb.ctrlop_tagstateup       <= pktp2.m_ctrlstatus_pkt.tagstateup;
                   master_cb.ctrlop_state            <= pktp2.m_ctrlstatus_pkt.state;
                   master_cb.ctrlop_setway_debug     <= pktp2.m_ctrlstatus_pkt.setway_debug;
                   master_cb.ctrlop_waybusy_vec      <= busyway;
                   port_sel                          = pktp2.m_ctrlstatus_pkt.rsp_evict_sel; 
                  if(cache_nack_ce == 1 && !cache_nack_uce) begin
                     p1_ctrlstatus_pkt.try_get(pktp1);
                     p2_ctrlstatus_pkt.try_get(pktp2);
                    `uvm_info("CCP_IF",$sformatf("Correctable Error asserted cache_nack_ce: %b",cache_nack_ce),UVM_HIGH); 
                  end 

                   if(push_wr_bypass_data == 1'b1 && !write_upgrade) begin
                    
                     for (int i = 0; i < BURSTLN; i++) begin
                      m_wrpkt          = new();
                      m_wrpkt.last     = ((i == BURSTLN-1) ? 1'b1 : 1'b0);
                      m_wrpkt.byten    = new[1];
                      m_wrpkt.byten[0] = pktp2.m_wr_pkt.byten[i];
                      m_wrpkt.beatn    = new[1];
                      m_wrpkt.beatn[0] = pktp2.m_ctrlstatus_pkt.addr[LINE_INDEX_HIGH:LINE_INDEX_LOW]+i;
                      m_wrpkt.poison     = new[1];
                      m_wrpkt.poison[0]  = pktp2.m_wr_pkt.poison[i];
                      m_wrpkt.data     = new[1];
                      m_wrpkt.data[0]  = pktp2.m_wr_pkt.data[i];
                      ctrlwr_pkt.put(m_wrpkt); 
                     end
                   end
                  
                 end
                 else begin
                  @(master_cb);
                  push_wr_bypass_data               =  1'b0;
                  rd_data                           =  1'b0;
                  wr_data                           =  1'b0;
                  write_upgrade                     =  1'b0;
                  port_sel                          =  1'b0;
                  aysnc_reset_ccpctrlstatus_p2();
                 end
              end
            end  
         join 
     end
      
 <%     /*if(obj.Block !=='dmi') { */%>
     //assign ctrlop_rd_data = ((cachectrl_evict_vld == 1'b1 && cache_evict_state == 2'b11) || (cachectrl_evict_vld == 1'b1 && cache_evict_state == 2'b11 && rd_data == 1'b1 && wr_data == 1'b1 )) ? 1'b1:rd_data;
 <%/* } else { */%>
     assign ctrlop_rd_data = ((cachectrl_evict_vld == 1'b1 && cache_evict_state == 2'b10) || (cachectrl_evict_vld == 1'b1 && cache_evict_state == 2'b10 && rd_data == 1'b1 && wr_data == 1'b1 )) ? 1'b1:rd_data;
 <%/* } */%>
     assign ctrlop_port_sel = ((cachectrl_evict_vld == 1'b1 && cache_evict_state == 2'b11) || (cachectrl_evict_vld == 1'b1 && cache_evict_state == 2'b10 && rd_data == 1'b1 && wr_data == 1'b1 )) ? 1'b1:port_sel;
     always  @(negedge clk)
       begin
       if(ctrlop_allocate && !cache_nack_noalloc)begin
         fill_addr_inflight_pkt.addr      = temp_filladdr;
         fill_addr_inflight_pkt.secu      = temp_secu;
         fill_addr_inflight_pkt.wayn      = onehot_to_binary(cache_alloc_wayn);
         fill_addr_inflight_q.push_back(fill_addr_inflight_pkt);
         update_index_way(fill_addr_inflight_pkt,1,busy_index_way_q);
       //  `uvm_info("CCP_IF",$sformatf("addr added  temp_filladdr :%0x tmp_secu :%0b wayn: %d",fill_addr_inflight_pkt.addr,fill_addr_inflight_pkt.secu,fill_addr_inflight_pkt.wayn ),UVM_HIGH);   
       //  `uvm_info("CCP_IF",$sformatf("fill data fill_addr_inflight_q :%p",fill_addr_inflight_q),UVM_HIGH);   
       end
      end


 
 
    <%/*}*/%>
    always @(posedge clk) begin
        posedge_count++;
    end
  //----------------------------------------------------------------------- 
  // collect ctrlstatus response for driver
  //----------------------------------------------------------------------- 
   task automatic collect_ctrlstatus_p2_pkt(ref ccp_ctrlstatus_seq_item pkt);
        <%if(obj.testBench === "io_aiu"){%>
          @(e_ccp_ctrl_pkt[core_id])
        <%} else {%>
          @(e_ccp_ctrl_pkt)
        <%}%>
          temp_ccp_ctrl_pkt =   collect_ccp_ctrl_pkt_q.pop_front();
          pkt.m_ctrlstatus_pkt.copy(temp_ccp_ctrl_pkt);
     uvm_report_info("ccp_if", $sformatf("%t:collect ctrlstatuspkt p2: %s",$time, pkt.m_ctrlstatus_pkt.sprint_pkt()), UVM_HIGH);
   endtask : collect_ctrlstatus_p2_pkt

  //----------------------------------------------------------------------- 
  // collect for filldone response for drive
  //----------------------------------------------------------------------- 
   task automatic collect_filldone_pkt(ref fill_addr_inflight_t  pkt);
        <%if(obj.testBench === "io_aiu"){%>
          @(e_fill_complete[core_id])  
        <%} else {%>
          @(e_fill_complete)  
        <%}%> 
          pkt = fill_rsp_pkt_q.pop_front();
          filldone_pkt.addr = pkt.addr;         
          filldone_pkt.wayn = pkt.wayn;         
         // update_index_way(filldone_pkt,1,busy_index_way_q);
        `uvm_info("ccp_if", $sformatf("%t:collect fill done add : 0x%0x wayn :0x%0x", $time,pkt.addr,pkt.wayn ), UVM_HIGH);
   endtask : collect_filldone_pkt
  //----------------------------------------------------------------------- 
  // collect fill miss for driver:
  //----------------------------------------------------------------------- 
   task automatic collect_cachefillmiss_pkt(ref ccp_cachefill_seq_item pkt);

         if(!rst_n) begin
            return;
         end
          <%if(obj.testBench === "io_aiu"){%>
            @(e_fill_cacheline[core_id])
          <%} else {%>
            @(e_fill_cacheline)
          <%}%>
         `uvm_info("CCP_IF",$sformatf("P2 miss fill_addr_q :%p",fill_addr_q),UVM_HIGH);   
          if(fill_addr_q.size() >0) begin
            temp_fill_addr_pkt = fill_addr_q.pop_front();
            uvm_report_info("ccp_if", $sformatf("%t:collect_cachefillmiss addr :0x%0x security :%0b", $time,temp_fill_addr_pkt.addr,temp_fill_addr_pkt.security), UVM_HIGH);
            pkt.miss                   = 1;
            pkt.fillctrl_pkt.addr      = temp_fill_addr_pkt.addr;
            pkt.fillctrl_pkt.wayn      = temp_fill_addr_pkt.wayn;
            pkt.fillctrl_pkt.security  = temp_fill_addr_pkt.security;
            pkt.fillctrl_pkt.state     = temp_fill_addr_pkt.state;
          end  else begin
            `uvm_error("ccp_if", $sformatf("%t:mon e_fill_cacheline triggered but fill_addr_q size :%d", $time, fill_addr_q.size()));
         end
         //`uvm_info("CCP_IF",$sformatf("P2 miss fill_addr_q :%p",fill_addr_q),UVM_HIGH);   
         `uvm_info("CCP_IF",$sformatf("P2 miss fill_addr_q :%p",pkt),UVM_HIGH);   
   endtask : collect_cachefillmiss_pkt
  //----------------------------------------------------------------------- 
  // Drive  ccp_fill data  port 
  //----------------------------------------------------------------------- 
  
  task automatic drive_cachefill_data (ccp_cachefill_seq_item pkt); 
      
      ccp_filldata_pkt_t m_fillpkt;
      if (rst_n == 0) begin
              return;
      end
      wait (rst_n == 1);
      for (int i = 0; i < BURSTLN; i++) begin
        m_fillpkt           = new();
        m_fillpkt.beatn     = new[1];
        m_fillpkt.beatn[0]  = pkt.filldata_pkt.addr[LINE_INDEX_HIGH:LINE_INDEX_LOW]+i;
        m_fillpkt.data      = new[1];
        m_fillpkt.data[0]   = pkt.filldata_pkt.data[i];
        m_fillpkt.poison    = new[1];
        m_fillpkt.poison[0] = pkt.filldata_pkt.poison[i];
        m_fillpkt.fillId    = pkt.filldata_pkt.fillId;
        m_fillpkt.addr      = pkt.filldata_pkt.addr;
        m_fillpkt.wayn      = pkt.filldata_pkt.wayn;
        m_fillpkt.byten     = new[1];
        m_fillpkt.byten[0]  = 16'hFFFF;
        if( i == (BURSTLN -1))
           m_fillpkt.last = 1;

        cachefilldata_pkt.put(m_fillpkt); 
      end

      tmp_idx_fill = {};
      tmp_idx_fill = fill_addr_inflight_q.find_first_index with (item.addr[WCCPADDR-1:CACHELINE_OFFSET] == pkt.filldata_pkt.addr[WCCPADDR-1:CACHELINE_OFFSET]);
      if(tmp_idx_fill.size()>0) begin
        fill_addr_inflight_q[tmp_idx_fill[0]].Id = pkt.filldata_pkt.fillId;
        `uvm_info("CCP_IF",$sformatf("fill data fill_addr_inflight_q :%p",fill_addr_inflight_q),UVM_HIGH);   
      end else begin
        `uvm_info("ccp_if", $sformatf("%t:drive filldata : %s", $time, pkt.filldata_pkt.sprint_pkt()), UVM_HIGH);
        `uvm_error("CCP_IF","unexpected cache_fill_addr generated")   
      end

      cachefillctrl_pkt.put(pkt.fillctrl_pkt); 
  endtask
   
   <% /*if((obj.testBench == "ccp_ncb") || (obj.testBench == "ccp_dmi")){*/%>
 initial
    begin
     time  t_filldata_sent;
     int m_dly;
     ccp_filldata_pkt_t fdpkt;
     bit  was_cache_filldata_rdy_set_already,done ;
     forever
     begin
       fdpkt = new();
       done = 0;
       fdbcnt = 0;
       m_dly = ($urandom_range(1,79) <=FILL_IF_BURST_PCT) ? 0 : ($urandom_range(FILL_IF_DELAY_MIN,FILL_IF_DELAY_MAX));
       if(cachefilldata_pkt.try_get(fdpkt))begin
         t_filldata_sent = $time;
         was_cache_filldata_rdy_set_already =1;
    
         do begin 
           if (m_dly > 0) begin
             aysnc_reset_ccpfilldata();
             @(master_cb);
             if (rst_n == 0) begin
                 break;
             end
             m_dly--;
           end
           else begin
            master_cb.ctrl_filldata_vld         <= 1;
            master_cb.ctrl_fill_data            <= {fdpkt.poison[0],fdpkt.data[0]};
            master_cb.ctrl_filldata_id          <= fdpkt.fillId; 
            master_cb.ctrl_filldata_addr        <= fdpkt.addr; 
            master_cb.ctrl_filldata_wayn        <= fdpkt.wayn; 
            master_cb.ctrl_filldata_beatn       <= fdpkt.beatn[0]; 
            master_cb.ctrl_filldata_byten       <= fdpkt.byten[0]; 
            master_cb.ctrl_filldata_last        <= fdpkt.last; 
            if(master_cb.cache_filldata_rdy == 1 && t_filldata_sent !== $time)begin
                done = 1;
             end
             else begin
              was_cache_filldata_rdy_set_already =0;
             end
             if (!done || was_cache_filldata_rdy_set_already ) begin
              @(master_cb);
             end
           end
         end 
         while(!done);
       end
       else begin
        aysnc_reset_ccpfilldata();
        @(master_cb);
       end
     end
   end
   
 initial
    begin
     int m_dly;
     time               t_ctrlfill_sent;
     ccp_fillctrl_pkt_t fpkt;
     bit                was_cache_fill_rdy_set_already,done ;
     int                fc_ccp_idx;
     int                fc_ccp_idx_q[$];

     forever
     begin
       fpkt = new();
       done = 0;
       //m_dly = ($urandom_range(1,100) <=FILL_IF_BURST_PCT) ? 0 : ($urandom_range(FILL_IF_DELAY_MIN,FILL_IF_DELAY_MAX));
       m_dly = 0;
       if(cachefillctrl_pkt.try_get(fpkt))begin
         t_ctrlfill_sent = $time;
         was_cache_fill_rdy_set_already =1;
         uvm_report_info("ccp_if", $sformatf("%t: cachefillctrl_pkt: %s", $time, fpkt.sprint_pkt()), UVM_HIGH);
    
         do begin 
           if (m_dly > 0) begin
             aysnc_reset_ccpfillctrl();
             @(master_cb);
             if (rst_n == 0) begin
                 break;
             end
             m_dly--;
           end
           else begin
           master_cb.ctrl_fill_vld         <= 1;
           master_cb.ctrl_fill_addr        <= fpkt.addr; 
           master_cb.ctrl_fill_security    <= fpkt.security;
           master_cb.ctrl_fill_wayn        <= fpkt.wayn; 
           master_cb.ctrl_fill_state       <= fpkt.state; 
            if(master_cb.cache_fill_rdy == 1 && t_ctrlfill_sent !== $time)begin
                done = 1;
            end
            else begin
             was_cache_fill_rdy_set_already =0;
            end
            if (!done || was_cache_fill_rdy_set_already ) begin
              @(master_cb);
            end
           end
         end 
         while(!done);
   <% /*if((obj.testBench == "ccp_ncb") || (obj.testBench == "ccp_dmi")){*/%>
          tmp_idx_fillc = {}; 
          tmp_idx_fillc = fill_addr_inflight_q.find_first_index with (item.addr == fpkt.addr &&
                                                                      item.secu == fpkt.security &&
                                                                      item.fillctrl == 0 );
          uvm_report_info("ccp_if", $sformatf("%t: fill_addr_inflight_pkt : %p", $time, fill_addr_inflight_q[tmp_idx_fillc[0]]), UVM_HIGH);
          if(!tmp_idx_fillc.size()) begin
            `uvm_error("CCP_IF","unexpected fill_addr and security  ")   
          end else begin
            if(fill_addr_inflight_q[tmp_idx_fillc[0]].filldata == 1) begin
              uvm_report_info("ccp_if", $sformatf("%t: fill_addr_inflight_pkt fill_data : %0d", $time, fill_addr_inflight_q[tmp_idx_fillc[0]].filldata), UVM_HIGH);
              temp_fill_rsp_pkt = fill_addr_inflight_q[tmp_idx_fillc[0]];
              fill_rsp_pkt_q.push_back(temp_fill_rsp_pkt); 
              fill_addr_inflight_q.delete(tmp_idx_fillc[0]);
              update_index_way(temp_fill_rsp_pkt,0,busy_index_way_q);
              <%if(obj.testBench === "io_aiu"){%>
                ->e_fill_complete[core_id];  
              <%} else {%>
                ->e_fill_complete;  
              <%}%> 
            end else begin
              fill_addr_inflight_q[tmp_idx_fillc[0]].fillctrl = 1;
            end
          end
    <%/* } */%>
       end
       else begin
        aysnc_reset_ccpfillctrl();
        @(master_cb);
       end
     end
   end
  //----------------------------------------------------------------------- 
  // drive rdy signal for evict and rdrsp if 
  //----------------------------------------------------------------------- 
  initial
    begin
      @(master_cb)
        if(rst_n) begin
          cache_rdrsp_rdy <= 'b0;  
          cache_evict_rdy <= 'b0;  
        end
        else begin  
          cache_rdrsp_rdy <= 'b1;  
          cache_evict_rdy <= 'b1;  
        end 
    end
<%/* } */%>
  //----------------------------------------------------------------------- 
  // collect wr data for monitor
  //----------------------------------------------------------------------- 
   task automatic collect_ctrlwr_pkt(ref ccp_wr_data_pkt_t pkt);
     ccp_ctrlwr_data_t       data[16];
     ccp_data_poision_t      poison[16];
     ccp_ctrlwr_byten_t      byten[16]; 
     ccp_ctrlwr_beatn_t      beatn[16];
     time                    timestamp[16];
     bit                     done =0;  
     int                     beat_cnt = 0;
     bit                     first_pass = 0;

     do begin
        @(master_cb);
         if(!rst_n) begin
          return;
         end
        if (monitor_cb.ctrl_wr_vld & rst_n & first_pass == 0) begin
          pkt.t_pkt_seen_on_intf = $time;
          first_pass             = 1;
        end
        if (monitor_cb.ctrl_wr_vld & monitor_cb.cache_wr_rdy & rst_n) begin
          data[beat_cnt]      = monitor_cb.ctrl_wr_data[WCCPDATA_IF-2:0];
          poison[beat_cnt]    = monitor_cb.ctrl_wr_data[WCCPDATA_IF-1];
          byten[beat_cnt]     = monitor_cb.ctrl_wr_byte_en;
          beatn[beat_cnt]     = monitor_cb.ctrl_wr_beat_num;
          timestamp[beat_cnt] = $time;
          if(monitor_cb.ctrl_wr_last)begin
            pkt.data      = new[beat_cnt+1](data);
            pkt.poison    = new[beat_cnt+1](poison);
            pkt.byten     = new[beat_cnt+1](byten);
            pkt.beatn     = new[beat_cnt+1](beatn);
            pkt.timestamp = new[beat_cnt+1](timestamp);
            beat_cnt      = 0;
            done = 1;
          end else begin
            beat_cnt++;
          end
        end
     end while(!done);
    uvm_report_info("ccp_if", $sformatf("%t: mon ctrlwrpkt: %s",$time, pkt.sprint_pkt()), UVM_HIGH);
   endtask : collect_ctrlwr_pkt


  //----------------------------------------------------------------------- 
  // collect scratchpad input data for monitor
  //----------------------------------------------------------------------- 
   task automatic collect_sp_wr_pkt(ref ccp_sp_wr_pkt_t pkt);
     ccp_ctrlwr_data_t       data[16];
     ccp_data_poision_t      poison[16];
     ccp_ctrlwr_byten_t      byten[16]; 
     ccp_ctrlwr_beatn_t      beatn[16];
     time                    timestamp[16];
     bit                     done =0;  
     int                     beat_cnt = 0;
     bit                     first_pass = 0;

     do begin
        @(master_cb);
         if(!rst_n) begin
          return;
         end
        if (monitor_cb.sp_wr_vld & rst_n & first_pass == 0) begin
          pkt.t_pkt_seen_on_intf = $time;
          first_pass             = 1;
        end
        if (monitor_cb.sp_wr_vld & monitor_cb.sp_wr_rdy & rst_n) begin
          data[beat_cnt]      = monitor_cb.sp_wr_data[WCCPDATA_IF-2:0];
          poison[beat_cnt]    = monitor_cb.sp_wr_data[WCCPDATA_IF-1];
          byten[beat_cnt]     = monitor_cb.sp_wr_byte_en;
          beatn[beat_cnt]     = monitor_cb.sp_wr_beat_num;
          timestamp[beat_cnt] = $time;
          if(monitor_cb.sp_wr_last)begin
            pkt.data      = new[beat_cnt+1](data);
            pkt.poison    = new[beat_cnt+1](poison);
            pkt.byten     = new[beat_cnt+1](byten);
            pkt.beatn     = new[beat_cnt+1](beatn);
            pkt.timestamp = new[beat_cnt+1](timestamp);
            beat_cnt      = 0;
            done = 1;
          end else begin
            beat_cnt++;
          end
        end
     end while(!done);
    //uvm_report_info("ccp_if", $sformatf("%t: mon ctrlwrpkt: %s",$time, pkt.sprint_pkt()), UVM_HIGH);
   endtask : collect_sp_wr_pkt


  //----------------------------------------------------------------------- 
  // collect Evict data for monitor
  //----------------------------------------------------------------------- 
   task automatic collect_cacheevict_pkt(ref ccp_evict_pkt_t pkt);
      ccp_cache_evict_data_t        data[16];
      ccp_data_poision_t            poison[16];
      ccp_ctrlwr_byten_t            byten[16]; 
      ccp_cache_evict_cancel_t      datacancel; 
      time                          timestamp[16];
      bit                           done =0;  
      int                           beat_cnt = 0;
      bit                           first_pass = 0;

     do begin
        @(monitor_cb);
         if(!rst_n) begin
            return;
         end
        if (monitor_cb.cache_evict_vld & rst_n & first_pass == 0) begin
            pkt.t_pkt_seen_on_intf = $time;
            first_pass             = 1;
        end
        if (monitor_cb.cache_evict_vld & monitor_cb.cache_evict_rdy & rst_n & ~monitor_cb.cache_evict_cancel) begin
           data[beat_cnt]           = monitor_cb.cache_evict_data[WCCPDATA_IF-2:0];            
           poison[beat_cnt]           = monitor_cb.cache_evict_data[WCCPDATA_IF-1];            
           byten[beat_cnt]          = monitor_cb.cache_evict_byten;
           timestamp[beat_cnt]      = $time; 
           if(monitor_cb.cache_evict_last)begin
             pkt.datacancel         = monitor_cb.cache_evict_cancel;
             pkt.data               = new[beat_cnt+1](data); 
             pkt.poison               = new[beat_cnt+1](poison); 
             pkt.byten              = new[beat_cnt+1](byten); 
             pkt.timestamp          = new[beat_cnt+1](timestamp); 
             done = 1;
             beat_cnt = 0;
           end else begin
             beat_cnt++;
           end
        end
     end while(!done);
     uvm_report_info("ccp_if", $sformatf("%t: mon ccp_evict_pkt: %s",$time, pkt.sprint_pkt()), UVM_HIGH);
   endtask : collect_cacheevict_pkt

  //----------------------------------------------------------------------- 
  // collect Evict data for monitor
  //----------------------------------------------------------------------- 
   task automatic collect_cacherdrsp_pkt(ref ccp_rd_rsp_pkt_t pkt);
     ccp_cache_rdrsp_data_t        data[16];
     ccp_data_poision_t            poison[16];
     ccp_cache_rdrsp_byten_t       byten[16]; 
     ccp_cache_rdrsp_cancel_t      datacancel; 
     time                          timestamp[16];
     bit                           done =0;  
     int                           beat_cnt = 0;
     bit                           first_pass = 0;

     do begin
        @(monitor_cb);
         if(!rst_n) begin
            return;
         end
        if (monitor_cb.cache_rdrsp_vld & rst_n & first_pass == 0) begin
            pkt.t_pkt_seen_on_intf = $time;
            first_pass             = 1;
        end
        if (monitor_cb.cache_rdrsp_vld & monitor_cb.cache_rdrsp_rdy & rst_n & ~monitor_cb.cache_rdrsp_cancel) begin
           data[beat_cnt]           = monitor_cb.cache_rdrsp_data[WCCPDATA_IF-2:0];            
           poison[beat_cnt]         = monitor_cb.cache_rdrsp_data[WCCPDATA_IF-1];            
           byten[beat_cnt]          = monitor_cb.cache_rdrsp_byten;
           timestamp[beat_cnt]      = $time; 
           if(monitor_cb.cache_rdrsp_last)begin
             pkt.datacancel         = monitor_cb.cache_rdrsp_cancel;
             pkt.data               = new[beat_cnt+1](data); 
             pkt.poison             = new[beat_cnt+1](poison); 
             pkt.byten              = new[beat_cnt+1](byten); 
             pkt.timestamp          = new[beat_cnt+1](timestamp); 
             beat_cnt = 0;
             done = 1;
           end else begin
             beat_cnt++;
           end
        end
     end while(!done);
     uvm_report_info("ccp_if", $sformatf("%t: mon ccp_rd_rsp_pkt: %s",$time, pkt.sprint_pkt()), UVM_HIGH);
   endtask : collect_cacherdrsp_pkt

  //----------------------------------------------------------------------- 
  // collect Read response data per beat for monitor
  //----------------------------------------------------------------------- 
   task automatic collect_cacherdrsp_per_beat_pkt(ref ccp_rd_rsp_pkt_t pkt);
     bit           done =0;  
     bit           first_pass = 0;
     pkt = new();
     pkt.data      = new[1];
     pkt.poison    = new[1];
     pkt.byten     = new[1];
     pkt.timestamp = new[1];

     do begin
        @(monitor_cb);
         if(!rst_n) begin
            return;
         end
        if (monitor_cb.cache_rdrsp_vld & rst_n & first_pass == 0) begin
            pkt.t_pkt_seen_on_intf = $time;
            first_pass             = 1;
        end
        if (monitor_cb.cache_rdrsp_vld & monitor_cb.cache_rdrsp_rdy & rst_n & ~monitor_cb.cache_rdrsp_cancel) begin
           pkt.datacancel      = monitor_cb.cache_rdrsp_cancel;
           pkt.data[0]         = monitor_cb.cache_rdrsp_data[WCCPDATA_IF-2:0];            
           pkt.poison[0]       = monitor_cb.cache_rdrsp_data[WCCPDATA_IF-1];            
           pkt.byten[0]        = monitor_cb.cache_rdrsp_byten;
           pkt.last            = monitor_cb.cache_rdrsp_last;
           pkt.timestamp[0]    = $time; 
           done = 1;
        end
     end while(!done);
     uvm_report_info("ccp_if", $sformatf("%t: mon ccp_rd_rsp_pkt: %s",$time, pkt.sprint_pkt()), UVM_HIGH);
   endtask : collect_cacherdrsp_per_beat_pkt

  //----------------------------------------------------------------------- 
  // collect Evict data for monitor
  //----------------------------------------------------------------------- 
   task automatic collect_sp_output_pkt(ref ccp_sp_output_pkt_t pkt);
     ccp_cache_rdrsp_data_t        data[16];
     ccp_data_poision_t            poison[16];
     ccp_cache_rdrsp_byten_t       byten[16]; 
     ccp_cache_rdrsp_cancel_t      datacancel; 
     time                          timestamp[16];
     bit                           done =0;  
     int                           beat_cnt = 0;
     bit                           first_pass = 0;

     do begin
        @(monitor_cb);
         if(!rst_n) begin
            return;
         end
        if (monitor_cb.sp_rdrsp_vld & rst_n & first_pass == 0) begin
            pkt.t_pkt_seen_on_intf = $time;
            first_pass             = 1;
        end
        if (monitor_cb.sp_rdrsp_vld & monitor_cb.sp_rdrsp_rdy & rst_n& ~monitor_cb.sp_rdrsp_cancel) begin
           data[beat_cnt]           = monitor_cb.sp_rdrsp_data[WCCPDATA_IF-2:0];            
           poison[beat_cnt]         = monitor_cb.sp_rdrsp_data[WCCPDATA_IF-1];            
           byten[beat_cnt]          = monitor_cb.sp_rdrsp_byten;
           timestamp[beat_cnt]      = $time; 
           if(monitor_cb.sp_rdrsp_last)begin
             pkt.datacancel         = monitor_cb.sp_rdrsp_cancel;
             pkt.data               = new[beat_cnt+1](data); 
             pkt.poison             = new[beat_cnt+1](poison); 
             pkt.byten              = new[beat_cnt+1](byten); 
             pkt.timestamp          = new[beat_cnt+1](timestamp); 
             beat_cnt = 0;
             done = 1;
           end else begin
             beat_cnt++;
           end
        end
     end while(!done);
     //uvm_report_info("ccp_if", $sformatf("%t: mon ccp_rd_rsp_pkt: %s",$time, pkt.sprint_pkt()), UVM_HIGH);
   endtask : collect_sp_output_pkt

  //----------------------------------------------------------------------- 
  // collect fill data for monitor
  //----------------------------------------------------------------------- 
   task automatic collect_cachefilldata_pkt(ref ccp_filldata_pkt_t pkt);
     bit done =0;  
     int fd_q[$];
     int fd_ccp_idx_q[$];
     int fd_ccp_idx  ;
     ccp_ctrlfilldata_Id_t filldone_id;
     do begin
        @(monitor_cb);
         if(!rst_n) begin
            return;
         end
        if (monitor_cb.cache_fill_done & rst_n) begin
          filldone_id = monitor_cb.cache_fill_done_id;
          fd_q = cachefilldata_pkt_q.find_first_index with (item.fillId == filldone_id);
          if(!fd_q.size())begin
	    `uvm_info("CCP_IF",$sformatf("filldone_id: 0x%h current cachefilldata_pkt_q %p",filldone_id,cachefilldata_pkt_q),UVM_HIGH)
            `uvm_error("CCP_IF","unexpected cache_fill_done asserted")   
          end else begin
            pkt = cachefilldata_pkt_q[fd_q[0]];
            cachefilldata_pkt_q.delete(fd_q[0]);
          end  
          pkt.doneId       = filldone_id;
          pkt.done         = monitor_cb.cache_fill_done;
   <%/* if((obj.testBench == "ccp_ncb") || (obj.testBench == "ccp_dmi")){*/%>
          tmp_idx_done = {}; 
          tmp_idx_done = fill_addr_inflight_q.find_first_index with (item.Id == pkt.doneId);
          if(!tmp_idx_done.size()>0) begin
            `uvm_error("CCP_IF","unexpected fill_addr and done_Id  ")   
          end else begin
            if(fill_addr_inflight_q[tmp_idx_done[0]].fillctrl == 1) begin
              temp_fill_rsp_pkt = fill_addr_inflight_q[tmp_idx_done[0]];
              fill_rsp_pkt_q.push_back(temp_fill_rsp_pkt); 
              fill_addr_inflight_q.delete(tmp_idx_done[0]);
              update_index_way(temp_fill_rsp_pkt,0,busy_index_way_q);
              <%if(obj.testBench === "io_aiu"){%>
                ->e_fill_complete[core_id];  
              <%} else {%>
                ->e_fill_complete;  
              <%}%> 
            end else begin
              fill_addr_inflight_q[tmp_idx_done[0]].filldata = 1;
            end
          end
    <% /*} */%>
          pkt.t_pkt_seen_on_intf = $time;
          done = 1;
         end
     end while(!done);
     uvm_report_info("ccp_if", $sformatf("%t:mon filldata_pkt: %s", $time, pkt.sprint_pkt()), UVM_HIGH);
   endtask : collect_cachefilldata_pkt

  //----------------------------------------------------------------------- 
  // collect fill data for monitor before fill_done signal
  //----------------------------------------------------------------------- 
   task automatic collect_cachefilldata_before_done_pkt(ref ccp_filldata_pkt_t pkt);
     bit done =0;  
     int fd_q[$];
     ccp_ctrlfilldata_Id_t filldone_id;
<%if(obj.usePartialFill) { %>
     //do begin
     //   //@(monitor_cb);
     //    if(!rst_n) begin
     //       return;
     //    end
     //   //if (cachefilldata_pkt_before_done_q.size() > 0) begin
          <%if(obj.testBench === "io_aiu"){%>
            @(e_fill_before_done_complete[core_id])
          <%} else {%>
            @(e_fill_before_done_complete)
          <%}%> 

          pkt = cachefilldata_pkt_before_done_q[0];
          cachefilldata_pkt_before_done_q.delete(0);
          pkt.t_pkt_seen_on_intf = $time;

     //     done = 1;
     //    //end
     //end while(!done);
     uvm_report_info("ccp_if", $sformatf("%t:mon filldata_before_done_pkt: %s", $time, pkt.sprint_pkt()), UVM_HIGH);
<% } %>
   endtask : collect_cachefilldata_before_done_pkt

 initial 
    begin
      forever
        begin
          ccp_ctrlfill_data_t       data[16];
          ccp_ctrlfilldata_byten_t  byten[16];
          ccp_data_poision_t        poison[16];
          ccp_ctrlfilldata_beatn_t  beatn[16];
          bit                       done;  
          time                      timestamp[16];
          int                       beat_cnt;
          bit                       first_pass;
          ccp_filldata_pkt_t        pktd ;

          do begin
             @(monitor_cb);
             if(monitor_cb.ctrl_filldata_vld & rst_n & first_pass == 0) begin
               pktd                    = new();
               pktd.t_pkt_seen_on_intf = $time;
               first_pass              = 1;
             end
             
             if(monitor_cb.ctrl_filldata_vld & monitor_cb.cache_filldata_rdy & rst_n & !done) begin
               pktd.fillId              = monitor_cb.ctrl_filldata_id;
               pktd.addr                = monitor_cb.ctrl_filldata_addr;
               pktd.wayn                = monitor_cb.ctrl_filldata_wayn;
               data[beat_cnt]           = monitor_cb.ctrl_fill_data[WCCPDATA_IF-2:0];            
               poison[beat_cnt]         = monitor_cb.ctrl_fill_data[WCCPDATA_IF-1];            
               beatn[beat_cnt]          = monitor_cb.ctrl_filldata_beatn;
<%/*if(obj.usePartialFill || obj.useCmc) { */%>
               byten[beat_cnt]          = monitor_cb.ctrl_filldata_byten;
<%/* } */%>
               timestamp[beat_cnt]      = $time; 
<%/*if(obj.usePartialFill || obj.useCmc) { */%>		
               if(monitor_cb.ctrl_filldata_last)begin
                 pktd.data              = new[beat_cnt+1](data); 
                 pktd.poison            = new[beat_cnt+1](poison); 
                 pktd.beatn             = new[beat_cnt+1](beatn); 
                 pktd.byten             = new[beat_cnt+1](byten); 
                 pktd.timestamp         = new[beat_cnt+1](timestamp); 
                 beat_cnt = 0;
                 done = 1;
               end else begin
                 beat_cnt++;
               end
<%/* } else {*/%>
/*               if(beat_cnt == BURSTLN-1 )begin
                 pktd.data              = new[beat_cnt+1](data); 
                 pktd.poison            = new[beat_cnt+1](poison); 
                 pktd.beatn             = new[beat_cnt+1](beatn); 
                 pktd.timestamp         = new[beat_cnt+1](timestamp); 
                 beat_cnt = 0;
                 done = 1;
               end else begin
                 beat_cnt++;
               end*/
<%/* } */%>
             end
          end while(!done);
          if(done & first_pass ) begin
           cachefilldata_pkt_q.push_back(pktd);
<%/*if(obj.usePartialFill || obj.useCmc) { */%>
           cachefilldata_pkt_before_done_q.push_back(pktd);
<%/* } */%>
          <%if(obj.testBench === "io_aiu"){%>
           ->e_fill_before_done_complete[core_id];
          <%} else {%>
           ->e_fill_before_done_complete;
          <%}%> 
           done = 0;
           first_pass = 0;
          end
       end
     end

  //----------------------------------------------------------------------- 
  // collect fill ctrl for monitor
  //----------------------------------------------------------------------- 
   task automatic collect_cachefillctrl_pkt(ref ccp_fillctrl_pkt_t pkt);
     bit                     done =0;  

     do begin
        @(master_cb);
         if(!rst_n) begin
          return;
         end
        if (monitor_cb.ctrl_fill_vld & monitor_cb.cache_fill_rdy & rst_n) begin
          pkt.addr               = monitor_cb.ctrl_fill_addr;
          pkt.wayn               = monitor_cb.ctrl_fill_wayn;
          pkt.security           = monitor_cb.ctrl_fill_security;
          pkt.state              = ccp_cachestate_enum_t'(monitor_cb.ctrl_fill_state);
          pkt.t_pkt_seen_on_intf = $time;
          done = 1;
        end
     end while(!done);
    uvm_report_info("ccp_if", $sformatf("%t:mon cachefillctrl_pkt: %s", $time, pkt.sprint_pkt()), UVM_HIGH);
   endtask : collect_cachefillctrl_pkt

  //----------------------------------------------------------------------- 
  // collect ctrlstatus_p0 data for monitor
  //----------------------------------------------------------------------- 
   task automatic collect_ctrlstatus_p0_pkt(ref ccp_ctrl_pkt_t pkt);
     bit done =0;  

     time t_mp0_ctrlstatus_sent;
    ccp_ctrl_pkt_t pkt0,pkt1;  
     do begin
         if(!rst_n) begin
            return;
         end
            @(master_cb);

            if(mp00_for_mp1_ctrlstatus_pkt.try_get(pkt)) begin
                done = 1;
            end
            //for (int i=0;i< N_TAG_BANK;i++) begin
            //  if (monitor_cb.ctrlop_vld[i] & monitor_cb.cacheop_rdy[i] & rst_n) begin
            //      pkt.addr               = monitor_cb.ctrlop_addr;            
            //      pkt.security           = monitor_cb.ctrlop_security;            
            //      pkt.bnk                = i;            
            //      pkt.timestamp          = $time;  
            //      done = 1;
            //   end
            //end
     end while(!done);
     t_mp0_ctrlstatus_sent = $time;
     uvm_report_info("ccp_if", $sformatf("%t:collect ctrlstatuspkt p0: %s", t_mp0_ctrlstatus_sent, pkt.sprint_pkt()), UVM_HIGH);
   endtask : collect_ctrlstatus_p0_pkt

  //----------------------------------------------------------------------- 
  // collect ctrlstatus_p1 data for monitor
  //----------------------------------------------------------------------- 
   task automatic collect_ctrlstatus_p1_pkt(ref ccp_ctrl_pkt_t pkt);
     bit done =0;  

     time t_mp1_ctrlstatus_sent;
    ccp_ctrl_pkt_t pkt1;  
     do begin
         if(!rst_n) begin
            return;
         end
            @(master_cb);

            if(mp11_ctrlstatus_pkt.try_get(pkt)) begin
                done = 1;
            end
     end while(!done);
     t_mp1_ctrlstatus_sent = $time;
     uvm_report_info("ccp_if", $sformatf("%t:collect ctrlstatuspkt p1: %s", t_mp1_ctrlstatus_sent, pkt.sprint_pkt()), UVM_HIGH);
   endtask : collect_ctrlstatus_p1_pkt
  //----------------------------------------------------------------------- 
  // collect scratchpad ctrlstatus for monitor
  //----------------------------------------------------------------------- 
   task automatic collect_sp_ctrlstatus_pkt(ref ccp_sp_ctrl_pkt_t pkt);
     bit done =0;  
     <% /*if(obj.Block == "dmi") { */%>
         logic [WSMIMSG-1:0] msgType_ff;
         bit msgtype_ff_valid = 0;
     <% /*} */%>
     time t_sp_ctrlstatus_sent;
     do begin
         if(!rst_n) begin
            return;
         end
            //@(master_cb);
            @monitor_cb;

            for (int i=0;i< <%=obj.nDataBanks%>;i++) begin
//Logic to account for the scratch_op fifo in the DMI CCP Scratchpad RTL when it isn't bypassed - CONC-11044
<% /*if(obj.Block == "dmi") { */%>
              if (monitor_cb.sp_op_vld[i] & !monitor_cb.sp_op_rdy[i] & rst_n & !monitor_cb.cache_nack_ce) begin
                   msgtype_ff_valid = 1;
                   msgType_ff = monitor_cb.msgType_p1;
              end
<%/* } */%>

<% /*if(obj.Block == "dmi") { */%>
              if (monitor_cb.sp_op_vld[i] & monitor_cb.sp_op_rdy[i] & rst_n & !monitor_cb.cache_nack_ce) begin
<% /*} else { */%>
              //if (monitor_cb.sp_op_vld[i] & monitor_cb.sp_op_rdy[i] & rst_n) begin
<% /*} */%>

                  pkt.sp_op_wr_data      = monitor_cb.sp_op_wr_data;
                  pkt.sp_op_rd_data      = monitor_cb.sp_op_rd_data;
                  pkt.sp_op_data_bank    = i;
                  pkt.sp_op_index_addr   = monitor_cb.sp_op_index_addr;
                  pkt.sp_op_way_num      = monitor_cb.sp_op_way_num;
                  pkt.sp_op_beat_num     = monitor_cb.sp_op_beat_num;
                  pkt.sp_op_burst_len    = monitor_cb.sp_op_burst_len;
                  pkt.sp_op_burst_type   = monitor_cb.sp_op_burst_type;
                  <% /*if(obj.Block == "dmi") { */%>
                      pkt.sp_op_msg_type     = msgtype_ff_valid ? msgType_ff : monitor_cb.msgType_p1;
                  <% /*} else { */%>
                      //pkt.sp_op_msg_type     = monitor_cb.msgType_p1;
                  <% /*} */%>
                  pkt.posedge_count      = monitor_cb.posedge_count;
                  pkt.t_pkt_seen_on_intf = $time;  
                  done = 1;
               end
            end
     end while(!done);
     t_sp_ctrlstatus_sent = $time;
//   uvm_report_info("ccp_if", $sformatf("%t:collect ctrlstatuspkt p0: %s", t_mp0_ctrlstatus_sent, pkt.sprint_pkt()), UVM_HIGH);
   endtask : collect_sp_ctrlstatus_pkt
  //----------------------------------------------------------------------- 
  // collect ctrlstatus data for monitor
  //----------------------------------------------------------------------- 
   task automatic collect_ctrlstatus_pkt(ref ccp_ctrl_pkt_t pkt);
     bit done =0;  
     ccp_ctrl_pkt_t scratch_pkt;
     ccp_ctrl_pkt_t scratch_pkt_p1;
     ccp_ctrl_pkt_t scratch_pkt_p0;
     time t_mp<%=TagPipe+2%>_ctrlstatus_sent;
     do begin
         if(!rst_n) begin
            return;
         end
           @(monitor_cb);
              if(rst_n)begin
               if(mp<%=TagPipe+1%>_ctrlstatus_pkt.try_get(pkt)) begin
                if(monitor_cb.cache_nack_ce) begin
                pkt.nackce             = monitor_cb.cache_nack_ce;
                    @(monitor_cb);
                    @(monitor_cb);
                    mp1_ctrlstatus_pkt.try_get(scratch_pkt);
                end

<% /*if(obj.Block !== "dmi") { */%>
                //if (!monitor_cb.out_req_valid_p2) begin
                //    return;
                //end
<% /*} */%>

                pkt.t_pt_err           = monitor_cb.t_pt_err ;
                pkt.cancel             = monitor_cb.ctrlop_cancel ;
                pkt.pt_id              = monitor_cb.ctrlop_pt_id_p2 ;
                pkt.lookup_p2          = monitor_cb.ctrlop_lookup_p2 ;
                pkt.retry              = monitor_cb.ctrlop_retry  ;
                uvm_report_info("temp; ccp_if",$sformatf("retry signal: %b, ctrlop_retry %b", pkt.retry, monitor_cb.ctrlop_retry),UVM_HIGH);

                pkt.alloc              = monitor_cb.ctrlop_allocate;
                pkt.rd_data            = monitor_cb.ctrlop_rd_data;
                pkt.wr_data            = monitor_cb.ctrlop_wr_data;
                pkt.rsp_evict_sel      = monitor_cb.ctrlop_port_sel;
                pkt.bypass             = monitor_cb.ctrlop_bypass;        
                pkt.rp_update          = monitor_cb.ctrlop_rp_update;
                pkt.tagstateup         = monitor_cb.ctrlop_tagstateup;
                pkt.state              = ccp_cachestate_enum_t'(monitor_cb.ctrlop_state);
                pkt.burstln            = monitor_cb.ctrlop_burstln;
                pkt.burstwrap          = monitor_cb.ctrlop_burstwrap;
                pkt.setway_debug       = monitor_cb.ctrlop_setway_debug;
                pkt.waypbusy_vec       = monitor_cb.ctrlop_waybusy_vec;
                pkt.waystale_vec       = monitor_cb.ctrlop_waystale_vec;
                pkt.currstate          = ccp_cachestate_enum_t'(monitor_cb.cache_currentstate);
 <% /*if(obj.Block =='dmi') { */%>
     <% if(obj.nWays>1) { %>
                pkt.wayn               = onehot_to_binary(monitor_cb.cache_alloc_wayn);
     <% } else { %>
                pkt.wayn               = 0;
     <% } %>
 <%/* } else { */%>
                //pkt.wayn               = onehot_to_binary(monitor_cb.cache_alloc_wayn);
 <%/* } */%>
                pkt.currnruvec         = monitor_cb.cache_current_nru_vec;
                pkt.hitwayn            = monitor_cb.cache_hit_wayn;
                pkt.evictvld           = monitor_cb.cachectrl_evict_vld ;
                pkt.evictaddr          = monitor_cb.cache_evict_addr ;
                pkt.evictsecurity      = monitor_cb.cache_evict_security;
                pkt.evictstate         = ccp_cachestate_enum_t'(monitor_cb.cache_evict_state);
                pkt.nackce             = monitor_cb.cache_nack_ce;
                pkt.nackuce            = monitor_cb.cache_nack_uce;
                pkt.nack               = monitor_cb.cache_nack;
                pkt.nacknoalloc        = monitor_cb.cache_nack_noalloc ;
                pkt.noways2alloc       = monitor_cb.cache_no_ways_2_alloc ;
                pkt.cancel             = monitor_cb.ctrlop_cancel ;
                pkt.lookup_p2          = monitor_cb.ctrlop_lookup_p2 ;
                pkt.wrdata             = monitor_cb.maint_wrdata;      
                pkt.opcode             = monitor_cb.maint_req_opcode;  
                pkt.mntwayn            = monitor_cb.maint_req_way;     
                pkt.entry              = monitor_cb.maint_req_entry;   
                pkt.word               = monitor_cb.maint_req_word;    
                pkt.reqdata            = monitor_cb.maint_req_data;    
                pkt.arraysel           = monitor_cb.maint_req_array_sel;    
                pkt.rddata             = monitor_cb.maint_read_data;   
                pkt.active             = monitor_cb.maint_active;      
                pkt.rddata_en          = monitor_cb.maint_read_data_en;

                pkt.isRead             = monitor_cb.isRead ;
                pkt.isWrite            = monitor_cb.isWrite ;
                pkt.isSnoop            = monitor_cb.isSnoop ;
                pkt.isMntOp            = monitor_cb.isMntOp ;
                pkt.nru_counter        = monitor_cb.nru_counter;

                pkt.isRead_Wakeup      = monitor_cb.isRead_Wakeup ;
                pkt.isWrite_Wakeup     = monitor_cb.isWrite_Wakeup ;
                pkt.isSnoop_Wakeup     = monitor_cb.isSnoop_Wakeup ;
                pkt.write_upgrade      = write_upgrade ;
                pkt.stale_vec_flag     = monitor_cb.stale_vec_flag ;

                pkt.read_hit            = monitor_cb.read_hit;
                pkt.read_miss_allocate  = monitor_cb.read_miss_allocate;
                pkt.write_hit           = monitor_cb.write_hit;
                pkt.write_miss_allocate = monitor_cb.write_miss_allocate;
                pkt.snoop_hit           = monitor_cb.snoop_hit;
                pkt.write_hit_upgrade   = monitor_cb.write_hit_upgrade;
                pkt.isRecycle           = monitor_cb.isRecycle;
                pkt.cancel_p2           = monitor_cb.cancel_p2;
                pkt.wr_addr_fifo_full   = monitor_cb.wr_addr_fifo_full;
                pkt.ccp_tt_full_p2      = monitor_cb.ccp_tt_full_p2;
                pkt.flush_fail_p2       = monitor_cb.flush_fail_p2;
                pkt.isRttfull           = monitor_cb.rttfull;
                pkt.isWttfull           = monitor_cb.wttfull;
                pkt.isWttanyfull        = monitor_cb.anywttfull;
                pkt.isHntdropped        = monitor_cb.ccp_hnt_drop_p2;
                pkt.msgType             = monitor_cb.msgType_p2;

                pkt.timestamp          = $time;  
                collect_ccp_ctrl_pkt_q.push_back(pkt);
                <%if(obj.testBench === "io_aiu"){%>
                  ->e_ccp_ctrl_pkt[core_id];
                <%} else {%>
                  ->e_ccp_ctrl_pkt;
                <%}%>
                if(monitor_cb.ctrlop_allocate && !monitor_cb.cache_nack_noalloc) begin
                  fill_addr_pkt                    = new();
                  fill_addr_pkt.addr               = pkt.addr;    
                  fill_addr_pkt.security           = pkt.security;
                  fill_addr_pkt.wayn               = pkt.wayn;
                 // fill_addr_inflight_pkt.addr      = pkt.addr;
                 // fill_addr_inflight_pkt.secu      = pkt.security;
                 // fill_addr_inflight_pkt.wayn      = pkt.wayn;
                 // fill_addr_inflight_q.push_back(fill_addr_inflight_pkt);
                 // update_index_way(fill_addr_inflight_pkt,1,busy_index_way_q);
                  fill_addr_q.push_back(fill_addr_pkt);
                  <%if(obj.testBench === "io_aiu"){%>
                    ->e_fill_cacheline[core_id];
                  <%} else {%>
                    ->e_fill_cacheline;
                  <%}%>
                end
                done = 1;
               end
              end
     end while(!done);

     //if (monitor_cb.ctrlop_retry || monitor_cb.cache_nack) begin
     //    @(monitor_cb);
     //    mp1_ctrlstatus_pkt.try_get(scratch_pkt_p1);
     //    mp0_ctrlstatus_pkt.try_get(scratch_pkt_p0);
     //end

     t_mp<%=TagPipe+2%>_ctrlstatus_sent = $time;
     uvm_report_info("ccp_if", $sformatf("%t:mon ctrlstatuspkt p<%=TagPipe+2%>: %s", t_mp<%=TagPipe+2%>_ctrlstatus_sent, pkt.sprint_pkt()), UVM_HIGH);
   endtask : collect_ctrlstatus_pkt


   initial
     begin
<% for(var i= 0;i<TagPipe+2;i++){ %>
     time t_mp<%=i%>_ctrlstatus_sent;
<% } %>
<% for(var i= 0;i<TagPipe+2;i++){ %>
     ccp_ctrl_pkt_t pkt<%=i%>;
<% } %>
          fork
            p0:begin
                 forever
                   begin
                     @(master_cb);
                     for (int i=0;i< N_TAG_BANK;i++) begin
                       if (monitor_cb.ctrlop_vld[i] & monitor_cb.cacheop_rdy[i] & ~monitor_cb.cache_nack_ce & rst_n) begin
                           pkt0 = new();
                           pkt0.t_pkt_seen_on_intf = $time;
                           pkt0.addr               = monitor_cb.ctrlop_addr;            
                           pkt0.security           = monitor_cb.ctrlop_security;            
                           pkt0.isCoh              = ~monitor_cb.isCoh_p0;
                           pkt0.isRplyVld          = monitor_cb.isRply_vld_p0;
                           pkt0.msgType_p0         = monitor_cb.msgType_p0;
//                           pkt0.pt_id              = monitor_cb.ctrlop_pt_id_p2;
                           pkt0.bnk                = i;
                           pkt0.posedge_count      = monitor_cb.posedge_count;
                           t_mp0_ctrlstatus_sent = $time;
                           #0 ;
                           uvm_report_info("ccp_if", $sformatf("%t:mon ctrlstatuspkt p0: %s", t_mp0_ctrlstatus_sent, pkt0.sprint_pkt()), UVM_HIGH);
                           mp0_ctrlstatus_pkt.put(pkt0);
                           mp00_for_mp1_ctrlstatus_pkt.put(pkt0);
                       end
                     end
                   end
               end
<% if(TagPipe >0) { %>
  <% for(var i= 0;i<TagPipe;i++){ %>
            p<%=i+1%>:begin
                 forever
                   begin
                     @(master_cb);
                     pkt<%=i+1%> = new();
                     if(mp<%=i%>_ctrlstatus_pkt.try_get(pkt<%=i+1%>) & rst_n)begin
                       t_mp<%=i+1%>_ctrlstatus_sent = $time;
                       #0 ;
                       uvm_report_info("ccp_if", $sformatf("%t:mon ctrlstatuspkt p<%=i+1%>: %s", t_mp<%=i+1%>_ctrlstatus_sent, pkt<%=i+1%>.sprint_pkt()), UVM_HIGH);
                       mp<%=i+1%>_ctrlstatus_pkt.put(pkt<%=i+1%>);
                     end
                   end
               end
  <% } %>
<% } %>

            p<%=TagPipe+1%>:begin
                 forever
                   begin
                     @(master_cb);
                     pkt<%=TagPipe+1%> = new();
                     if(mp<%=TagPipe%>_ctrlstatus_pkt.try_get(pkt<%=TagPipe+1%>) & rst_n)begin
                       t_mp<%=TagPipe+1%>_ctrlstatus_sent = $time;
                       pkt<%=TagPipe+1%>.isReplay            = monitor_cb.isReplay;
                       pkt<%=TagPipe+1%>.toReplay            = monitor_cb.toReplay;
                       pkt<%=TagPipe+1%>.isRecycle_p1        = monitor_cb.isRecycle;
                       #0 ;
                       uvm_report_info("ccp_if", $sformatf("%t:mon ctrlstatuspkt p<%=TagPipe+1%>: %s", t_mp<%=TagPipe+1%>_ctrlstatus_sent, pkt<%=TagPipe+1%>.sprint_pkt()), UVM_HIGH);
<% /*if(obj.Block == "dmi") { */%>
                      if(monitor_cb.toReplay && monitor_cb.cache_nack_ce)begin
                        mp11_ctrlstatus_pkt.put(pkt<%=TagPipe+1%>);
                      end
                      else begin
<% /*} */%>
                       mp<%=TagPipe+1%>_ctrlstatus_pkt.put(pkt<%=TagPipe+1%>);
<%/* if(obj.Block == "dmi") { */%>
                      end
<%/* } */%>
                     end
                   end
               end
          join
     end   

//----------------------------------------------------------------------------------------------------------
// Scoreboard to keep track of busy way
//----------------------------------------------------------------------------------------------------------
       task automatic  update_index_way(input fill_addr_inflight_t  filldone_pkt,input bit set_flg,ref busy_index_way_t busy_index_way_q[$]);
          int bwy_idx_q[$];
          int done_idx;
          ccp_ctrlop_waybusy_vec_t tmp_way;
          //addr_trans_mgr           m_addr_mgr;

//          m_addr_mgr = addr_trans_mgr::get_instance();
//<% if (obj.Block === "io_aiu") { %>
//          done_idx =  m_addr_mgr.get_set_index(addrMgrConst::get_aiu_funitid(<%=obj.Id%>), 1, filldone_pkt.addr);
//<% } else {  %>
//          done_idx =  m_addr_mgr.get_set_index(addrMgrConst::get_dmi_funitid(<%=obj.Id%>), 1, filldone_pkt.addr);
//<% } %>
          done_idx = CcpCalcIndex(filldone_pkt.addr);

          bwy_idx_q = {};
          bwy_idx_q =  busy_index_way_q.find_first_index with (item.indx == done_idx); 
      //    `uvm_info("CCP_IF update_index_way",$sformatf("done_idx :%0b addr :%0x",done_idx,filldone_pkt.addr),UVM_HIGH);

    <%   if(obj.nWays >1) {  %>
          if(!set_flg) begin
            if(!bwy_idx_q.size()) begin
              `uvm_error("body","update_index_way: unexpected cache_fill_addr generated")   
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
              `uvm_error("body","update_index_way: unexpected cache_fill_addr generated")   
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
       endtask:update_index_way
//----------------------------------------------------------------------------------------------------------
// function to get busy way
//----------------------------------------------------------------------------------------------------------
    function automatic  ccp_ctrlop_waybusy_vec_t get_busy_way(input ccp_ctrlop_addr_t addr, ref busy_index_way_t busy_index_way_q[$] );  
       int bwy_idx_q[$];
       int idx;
       //addr_trans_mgr m_addr_mgr;

       ccp_ctrlop_waybusy_vec_t tmp_way;
       //m_addr_mgr = addr_trans_mgr::get_instance();

       idx = CcpCalcIndex(addr);
//<% if (obj.Block === "io_aiu") { %>
//          idx =  m_addr_mgr.get_set_index(addrMgrConst::get_aiu_funitid(<%=obj.Id%>), 1, addr);
//<% } else {  %>
//          idx =  m_addr_mgr.get_set_index(addrMgrConst::get_dmi_funitid(<%=obj.Id%>), 1, addr);
//<% } %>
       bwy_idx_q = {};
       bwy_idx_q =  busy_index_way_q.find_first_index with (item.indx == idx ); 
       if(!bwy_idx_q.size()) begin
         tmp_way = 0;
       end else begin
         tmp_way = busy_index_way_q[bwy_idx_q[0]].wayn;
       end
      return(tmp_way);
    endfunction:get_busy_way

//-----------------------------------------------------------------------
// Function to convert one-hot vector to int 
//----------------------------------------------------------------------- 
function bit [N_WAY-1:0] onehot_to_binary(bit [N_WAY-1:0] in_word);
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

function automatic bit [N_WAY-1:0] binary_to_onehot(bit [N_WAY-1:0] in_word);
    
    bit [N_WAY-1:0] onehot = 0;
    
    onehot[in_word] = 1;

    return onehot;
endfunction : binary_to_onehot

endinterface
