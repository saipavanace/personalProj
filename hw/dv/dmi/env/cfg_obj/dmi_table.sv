////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Lookup Table to maintain current state of any in-flight DMI transaction flow from a DV perspective. 
// Instantiated as a queue in the resource manager and manipulated as needed.
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
class dmi_table extends uvm_object;
  `uvm_object_param_utils(dmi_table)
   int                UID;
   int                PKT_UID; //assosciated SMI txn packet ID
  //MRD
   dmi_table_type_t   table_type;
   smi_type_t         msg_type;
   string             msg_s;
   smi_ncore_unit_id_bit_t            aiu_id;
   AIUmsgID_t         aiu_msg_id;
   aiu_id_t           aiu_entry;
   smi_ncore_unit_id_bit_t dce_id;
   smi_msg_id_t       smi_msg_id;
   smi_addr_t         cache_addr;
   smi_security_t     security;
   bit                exclusive;
   bit                cmd_rsp_rcvd = 0;
   bit                mrd_rsp_rcvd = 0;
   bit                dtr_req_rcvd = 0;
   //NC Read
   bit                str_req_rcvd = 0;
   bit                str_rsp_sent = 0;
   axi_arid_t         axi_axid_q;
   bit                arlock;
   //Atomic Load
   bit                dtw_rsp_rcvd = 0;
   bit                exp_cmp_match = 0;
   //NC Write
   smi_rbid_t         smi_rbid; 
   bit                awlock;
   //DTW
   smi_ncore_unit_id_bit_t  dtr_aiu_id; 
   smi_ncore_unit_id_bit_t  secondary_aiu_id; 
   aiu_id_t           dtr_aiu_entry;
   smi_msg_id_t       secondary_smi_msg_id; 
   smi_msg_id_t       dtr_rmsg_id; 
   smi_msg_id_t       RBRs_rmsg_id; 
   smi_msg_id_t       RBRl_rmsg_id; 
   bit                rb_rsp_rcvd = 0;
   bit                rb_rl_rsp_expd = 0;
   bit                rb_rl_rsp_rcvd = 0;
   bit                secondary_dtw_rsp_rcvd = 0;
   bit                isMrgMrd;
   bit                isMW;
   int                dtws_expd;
   bit                rb_released;
   bit                release_in_flight;
   int                dtw_req_sent;
  extern function new(string name="dmi_table");
  extern function void initialize(ref smi_seq_item smi_item, input int id);
  extern function bit is_coh_read();
  extern function bit is_coh_write();
  extern function bit is_dtw_simple();
  extern function bit is_dtw_mrg_mrd();
  extern function bit is_non_coh_read(); 
  extern function bit is_cmd_cmo();
  extern function bit is_coh_read_cmo();
  extern function bit is_non_coh_write(); 
  extern function bit is_atomic_load();
  extern function bit is_in_flight_non_coh_wr();
  extern function bit is_in_flight_non_coh_rd();
  extern function bit is_in_flight_coh_wr();
  extern function bit is_in_flight_coh_wr_merge();
  extern function bit is_in_flight_coh_rd();
  extern function bit is_in_flight_atomic_ld();
  extern function bit is_active_cmo();
  extern function bit is_atomic_store();
  extern function smi_full_addr_t get_full_addr();
  extern function bit is_addr_match(smi_addr_t m_addr, bit m_ns);
  extern function string smi_type_string(smi_type_t msg_type);
  extern function string convert2string();
  extern function print_entry();
  extern function smi_addr_t cl_aligned(smi_addr_t addr);

  extern function bit is_coh_wr_TT();
  extern function bit is_coh_rd_TT();
  extern function bit is_non_coh_wr_TT();
  extern function bit is_non_coh_rd_TT();
  extern function bit is_atm_ld_TT();

  extern function bit is_aiu_match(aiu_id_t lhs, aiu_id_t rhs);

  extern function bit is_cmp_miss();
endclass

function dmi_table::new (string name="dmi_table");
  super.new(name);
endfunction

function dmi_table::print_entry();
  `uvm_info("dmi_table",$sformatf("%s", convert2string()),UVM_MEDIUM);
endfunction

function string dmi_table::convert2string();
  //Print function
  string s;
  if(isMW) begin
    $sformat(s,"%sDT_UID:%0d: :: PKT_UID:%0d: | [%0s] SmiType:%0s | PRIMARY [SmiMsgId:%0h AiuId:%0h] | Addr:%0h NS:%0b ES:%0b",
              s, UID, PKT_UID, table_type.name, msg_s, smi_msg_id, aiu_id, cache_addr, security, exclusive);
  end
  else begin
    $sformat(s,"%sDT_UID:%0d: :: PKT_UID:%0d: | [%0s] SmiType:%0s | SmiMsgId:%0h AiuId:%0h Addr:%0h NS:%0b ES:%0b",
              s, UID, PKT_UID, table_type.name, msg_s, smi_msg_id, aiu_id, cache_addr, security, exclusive);
  end
  if(is_coh_read()) begin
    // C Read | MrdReq->MrdRsp->DtrReq->DtrRsp
    $sformat(s,"%s DceId:%0h cmd_rsp_rcvd:%0b mrd_rsp_rcvd:%0b dtr_req_rcvd:%0b",
             s, dce_id, cmd_rsp_rcvd, mrd_rsp_rcvd, dtr_req_rcvd);
  end
  else if(is_dtw_simple() || is_dtw_mrg_mrd()) begin
    // C Write | RbrReq->DtwReq->DtwRsp->RbrRsp
    if(isMW) begin
      $sformat(s,"%s RBID:%0h DceId:%0h rbr_rsp_rcvd:%0b PRIMARY [dtw_req_sent:%0b dtw_rsp_rcvd:%0b]",
               s, smi_rbid, dce_id, rb_rsp_rcvd, dtw_req_sent, dtw_rsp_rcvd);
    end
    else begin
      $sformat(s,"%s RBID:%0h DceId:%0h rbr_rsp_rcvd:%0b dtw_req_sent:%0b dtw_rsp_rcvd:%0b",
               s, smi_rbid, dce_id, rb_rsp_rcvd, dtw_req_sent, dtw_rsp_rcvd);
    end

    if(is_non_coh_write() || is_atomic_load())begin
      $sformat(s,"%s [dtw_req_sent:%0b dtw_rsp_rcvd:%0b]", s, dtw_req_sent, dtw_rsp_rcvd);
    end
    else begin
      $sformat(s,"%s dtw_rsp_rcvd:%0b", s, dtw_rsp_rcvd);
    end

    if(isMrgMrd) begin
      $sformat(s,"%s dtr_req_rcvd:%0b", s, dtr_req_rcvd);
    end
    if(rb_rl_rsp_expd) begin
      $sformat(s,"%s rb_rl_rsp_expd:%0b rb_rl_rsp_rcvd:%0b release_in_flight:%0b",
               s, rb_rl_rsp_expd, rb_rl_rsp_rcvd, release_in_flight);
    end
  end
  else if(is_non_coh_read()) begin
    // NC Read | CmdReq->CmdRsp->StrReq->DtrReq->DtrRsp->StrRsp
    $sformat(s,"%s cmd_rsp_rcvd: %0b str_req_rcvd:%0b str_rsp_sent:%0b dtr_req_rcvd:%0b",
             s, cmd_rsp_rcvd, str_req_rcvd, str_rsp_sent, dtr_req_rcvd);
  end
  else if (is_cmd_cmo()) begin
    // CMO | CmdReq->CmdRsp->StrReq->DtrReq->DtrRsp->StrRsp
    $sformat(s,"%s cmd_rsp_rcvd: %0b str_req_rcvd:%0b str_rsp_sent:%0b dtr_req_rcvd:%0b",
             s, cmd_rsp_rcvd, str_req_rcvd, str_rsp_sent, dtr_req_rcvd); 
  end
  else if(is_non_coh_write()) begin
    // NC Write | CmdReq->CmdRsp->StrReq->DtwRreq->DtwRsp->StrRsp
    $sformat(s,"%s cmd_rsp_rcvd:%0b str_req_rcvd:%0b str_rsp_sent:%0b dtw_req_sent:%0b dtw_rsp_rcvd:%0b ",
             s, cmd_rsp_rcvd, str_req_rcvd, str_rsp_sent, dtw_req_sent, dtw_rsp_rcvd);
  end
  else if(is_atomic_load()) begin
    // NC Atomic | CmdReq->CmdRsp->StrReq->DtwReq->DtwRsp->DtrReq->DtrRsp->StrRsp
    $sformat(s,"%s cmd_rsp_rcvd: %0b str_req_rcvd:%0b str_rsp_sent:%0b dtw_req_sent:%0b dtw_rsp_rcvd:%0b dtr_req_rcvd:%0b",
             s, cmd_rsp_rcvd, str_req_rcvd, str_rsp_sent, dtw_req_sent, dtw_rsp_rcvd, dtr_req_rcvd);
    if(msg_type == CMD_CMP_ATM) begin
      $sformat(s,"%s exp_cmp_match:%0b", s, exp_cmp_match);
    end
  end 
  else if(is_atomic_store()) begin
    // NC Atomic | CmdReq->CmdRsp->StrReq->DtwReq->DtwRsp->->StrRsp
    $sformat(s,"%s cmd_rsp_rcvd:%0b str_req_rcvd:%0b str_rsp_sent:%0b dtw_req_sent:%0b dtw_rsp_rcvd:%0b ",
             s, cmd_rsp_rcvd, str_req_rcvd, str_rsp_sent, dtw_req_sent, dtw_rsp_rcvd);

  end
  if(isMW) begin
    if(dtws_expd==1) begin
      $sformat(s,"%s MW:%0b dtws_expd:%0d",
              s, isMW, dtws_expd);
    end
    else begin
      $sformat(s,"%s MW:%0b dtws_expd:%0d | SECONDARY [dtw_rsp_rcvd:%0b SmiMsgId:%0h AiuId:%0h]",
              s, isMW, dtws_expd, secondary_dtw_rsp_rcvd, secondary_smi_msg_id, secondary_aiu_id);
    end
  end
  return(s);
endfunction

function void dmi_table::initialize(ref smi_seq_item smi_item, input int id);
  //Constructor call for new elements
  UID = id;
  PKT_UID = smi_item.pkt_uid;
  msg_type = smi_item.smi_msg_type;
  if(is_coh_read()) begin
    table_type    = COH_RD_TT;
    dce_id        = smi_item.smi_src_ncore_unit_id;
    aiu_id        = smi_item.smi_mpf1_dtr_tgt_id;
    aiu_msg_id    = smi_item.smi_mpf2_dtr_msg_id;
    smi_msg_id    = smi_item.smi_msg_id;
    cache_addr    = smi_item.smi_addr;
    security      = smi_item.smi_ns;
    exclusive     = smi_item.smi_es;
    cmd_rsp_rcvd  = 0;
  end
  else if(is_dtw_simple() || is_dtw_mrg_mrd()) begin
    table_type   = COH_WR_TT;
    aiu_id       = smi_item.smi_src_ncore_unit_id;
    smi_msg_id   = smi_item.smi_msg_id;
    cache_addr   = smi_item.smi_addr;
    security     = smi_item.smi_ns;
    smi_rbid     = smi_item.smi_rbid;
    dtr_aiu_id   = smi_item.smi_mpf1[WSMINCOREUNITID-1:0];
    dtr_rmsg_id  = smi_item.smi_mpf2;
    exclusive     = smi_item.smi_es;
    isMrgMrd     = is_dtw_mrg_mrd();
    dtr_aiu_entry.aiu_id = dtr_aiu_id;
    dtr_aiu_entry.msg_id = dtr_rmsg_id;
  end
  else if(is_non_coh_read() || is_cmd_cmo()) begin
    table_type   = NON_COH_RD_TT;
    aiu_id       = smi_item.smi_src_ncore_unit_id;
    smi_msg_id   = smi_item.smi_msg_id;
    cache_addr   = smi_item.smi_addr;
    security     = smi_item.smi_ns;
    exclusive     = smi_item.smi_es;
    cmd_rsp_rcvd = 0;
    str_req_rcvd = 0;
    str_rsp_sent = 0;
    dtr_req_rcvd = 0;
  end
  else if(is_non_coh_write() || is_atomic_store()) begin
    table_type    = NON_COH_WR_TT;
    aiu_id        = smi_item.smi_src_ncore_unit_id;
    smi_msg_id    = smi_item.smi_msg_id;
    cache_addr    = smi_item.smi_addr;
    security      = smi_item.smi_ns;
    exclusive     = smi_item.smi_es;
    cmd_rsp_rcvd  = 0;
    str_req_rcvd  = 0;
    str_rsp_sent  = 0;
    dtw_req_sent  = 0;
    dtw_rsp_rcvd  = 0;
  end
  else if(is_atomic_load()) begin
    table_type    = ATM_LD_TT;
    aiu_id        = smi_item.smi_src_ncore_unit_id;
    smi_msg_id    = smi_item.smi_msg_id;
    cache_addr    = smi_item.smi_addr;
    security      = smi_item.smi_ns;
    exclusive     = smi_item.smi_es;
    cmd_rsp_rcvd  = 0;
    str_req_rcvd  = 0;
    str_rsp_sent  = 0;
    dtr_req_rcvd  = 0;
    dtw_req_sent  = 0;
    dtw_rsp_rcvd  = 0;
  end 
  else begin
    `uvm_error("dmi_table",$sformatf("who-am-i :%0h?",msg_type))
  end
  aiu_entry.aiu_id = smi_item.smi_src_ncore_unit_id;
  aiu_entry.msg_id = smi_item.smi_msg_id;
  msg_s = smi_type_string(msg_type);
endfunction

//Core common computations/////////////////////////////////////////////////////////////////////////////////

function bit dmi_table::is_in_flight_non_coh_wr();
  if(table_type == NON_COH_WR_TT && !dtw_rsp_rcvd) begin
    return(1);
  end
  else begin
    return(0);
  end
endfunction

function bit dmi_table::is_in_flight_non_coh_rd();
  if(table_type == NON_COH_RD_TT && !dtr_req_rcvd) begin
    return(1);
  end
  else begin
    return(0);
  end
endfunction

function bit dmi_table::is_in_flight_coh_wr();
  if(table_type == COH_WR_TT && !dtw_rsp_rcvd) begin
    return(1);
  end
  else begin
    return(0);
  end
endfunction

function bit dmi_table::is_in_flight_coh_wr_merge();
  if(table_type == COH_WR_TT && isMrgMrd && !(dtw_rsp_rcvd && dtr_req_rcvd)) begin
    return(1);
  end
  else begin
    return(0);
  end
endfunction

function bit dmi_table::is_in_flight_coh_rd();
  if(table_type == COH_RD_TT && !dtr_req_rcvd) begin
    return(1);
  end
  else begin
    return(0);
  end
endfunction

function bit dmi_table::is_in_flight_atomic_ld();
  if(table_type == ATM_LD_TT && (!dtr_req_rcvd || !dtw_rsp_rcvd)) begin
    return(1);
  end
  else begin
    return(0);
  end
endfunction

function bit dmi_table::is_active_cmo();
  if((is_coh_read_cmo() | is_cmd_cmo()) && !str_req_rcvd) begin
    return(1);
  end
  else begin
    return(0);
  end
endfunction

function bit dmi_table::is_aiu_match(aiu_id_t lhs, aiu_id_t rhs);
  if( (lhs.aiu_id == rhs.aiu_id) && (lhs.msg_id == rhs.msg_id) ) begin
    return(1);
  end
  else begin
    return(0);
  end
endfunction

function bit dmi_table::is_cmp_miss();
  return(exp_cmp_match && str_rsp_sent && dtw_rsp_rcvd && cmd_rsp_rcvd && !dtr_req_rcvd);
endfunction
//Whoami SMI Message Types//////////////////////////////////////////////////////////////////////////////////
function bit dmi_table::is_coh_read();
  eMsgMRD eMsg;
  return ((msg_type >= eMsg.first()) && (msg_type <= eMsg.last()));
endfunction

function bit dmi_table::is_coh_read_cmo();
  return(msg_type inside {MRD_PREF, MRD_INV, MRD_FLUSH});
endfunction

function bit dmi_table::is_dtw_simple();
  eMsgDTW eMsg;
  return ((msg_type >= eMsg.first()) && (msg_type <= eMsg.last())); 
endfunction

function bit dmi_table::is_dtw_mrg_mrd();
  eMsgDTWMrgMRD eMsg;
  return ( (msg_type >= eMsg.first()) && (msg_type <= eMsg.last()) );
endfunction

function bit dmi_table::is_coh_write();
  return (is_dtw_simple()|is_dtw_mrg_mrd());
endfunction

function bit dmi_table::is_non_coh_read(); 
  return (msg_type inside {CMD_RD_NC});
endfunction

function bit dmi_table::is_cmd_cmo();
  return (msg_type inside {CMD_CLN_INV, CMD_CLN_VLD, CMD_CLN_SH_PER, CMD_MK_INV, CMD_PREF});
endfunction

function bit dmi_table::is_non_coh_write(); 
  return (msg_type inside {CMD_WR_NC_PTL, CMD_WR_NC_FULL});
endfunction

function bit dmi_table::is_atomic_load();
  return (msg_type inside {CMD_RD_ATM, CMD_SW_ATM, CMD_CMP_ATM});
endfunction

function bit dmi_table::is_atomic_store();
  return (msg_type inside {CMD_WR_ATM});
endfunction

//Is Table Types///////////////////////////////////////////////////////////////////////////////////////
function bit dmi_table::is_coh_wr_TT();
  if(table_type==COH_WR_TT) begin
    return(1);
  end
  else begin
    return(0);
  end
endfunction

function bit dmi_table::is_coh_rd_TT();
if(table_type==COH_RD_TT) begin
    return(1);
  end
  else begin
    return(0);
  end
endfunction

function bit dmi_table::is_non_coh_wr_TT();
if(table_type==NON_COH_WR_TT) begin
    return(1);
  end
  else begin
    return(0);
  end
endfunction

function bit dmi_table::is_non_coh_rd_TT();
if(table_type==NON_COH_RD_TT) begin
    return(1);
  end
  else begin
    return(0);
  end
endfunction

function bit dmi_table::is_atm_ld_TT();
  if(table_type==ATM_LD_TT) begin
    return(1);
  end
  else begin
    return(0);
  end
endfunction

//Basic computations/////////////////////////////////////////////////////////////////////////////////
function string dmi_table::smi_type_string(smi_type_t msg_type);
  smi_msg_type_e _type;
  string _s, _sfx;
  _type = smi_msg_type_e'(msg_type);
  _sfx  = $sformatf("%0s",_type.name);
  _s    = _sfx.substr(0,_sfx.len()-3);
  return(_s);
endfunction

function bit dmi_table::is_addr_match(smi_addr_t m_addr, bit m_ns);
  if((cl_aligned(m_addr) === cl_aligned(cache_addr)) &&
     (m_ns === security))begin
    return(1);
  end
  else begin
    return(0);
  end
endfunction

function smi_addr_t dmi_table::cl_aligned(smi_addr_t addr);
  smi_addr_t cl_aligned_addr;
  cl_aligned_addr = (addr >> $clog2(N_SYS_CACHELINE));
  return cl_aligned_addr;
endfunction // cl_aligned

function smi_full_addr_t dmi_table::get_full_addr();
  smi_full_addr_t item;
  item.ns = security;
  item.addr = cache_addr;
  item.src_type = table_type;
  return(item);
endfunction
