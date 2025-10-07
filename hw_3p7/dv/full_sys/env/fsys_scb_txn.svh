////////////////////////////////////////////////////////////////////////////////
//
// Author       : Neha F
// Purpose      : Scoreboard transaction class for fsys_scoreboard
// Description  : This will serve as fsys scoreboard's transaction. 
//                This object will map transaction's path going through NCore.
//
////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////
//Below code is copied from concerto_env.svh file to be able to use
//_child_blkid for loops
////////////////////////////////////////////////////////////////////////////////
//
// concerto_env 
<% if (1 == 0) { %>
// Author: Satya Prakash
<% } %>
//
////////////////////////////////////////////////////////////////////////////////


<%
//Embedded javascript code to figure number of blocks
   var _child_blkid      = [];
   var _child_blk        = [];
   var pidx              = 0;
   var ridx              = 0;
   var qidx              = 0;
   var idx               = 0;
   var j                 = 0;
   var num_chi_aiu_tx_if = 0;
   var num_io_aiu_tx_if  = 0;
   var num_dmi_tx_if     = 0;
   var num_dii_tx_if     = 0;
   var num_dce_tx_if     = 0;
   var num_dve_tx_if     = 0;
   var num_chi_aiu_rx_if = 0;
   var num_io_aiu_rx_if  = 0;
   var num_dmi_rx_if     = 0;
   var num_dii_rx_if     = 0;
   var num_dce_rx_if     = 0;
   var num_dve_rx_if     = 0;
   var initiatorAgents   = obj.AiuInfo.length ;
   var numChiAiu         = 0;
   var numIoAiu          = 0;
   var aiu_NumCores = [];
   var orderedWriteObservation = 1;

   for(var pidx = 0; pidx < initiatorAgents; pidx++) { 
     if(Array.isArray(obj.AiuInfo[pidx].interfaces.axiInt)) {
         aiu_NumCores[pidx]    = obj.AiuInfo[pidx].interfaces.axiInt.length;
     } else {
         aiu_NumCores[pidx]    = 1;
     }
   }
   for(pidx = 0; pidx < obj.nAIUs; pidx++) {
       if((obj.AiuInfo[pidx].fnNativeInterface == 'CHI-A')||(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-B')||(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-E')) {
       _child_blkid[pidx] = 'chiaiu' + idx;
       _child_blk[pidx]   = 'chiaiu';
       num_chi_aiu_tx_if = obj.AiuInfo[pidx].smiPortParams.tx.length;
       num_chi_aiu_rx_if = obj.AiuInfo[pidx].smiPortParams.rx.length;
       numChiAiu = numChiAiu + 1;
       idx++;
       } else {
       _child_blkid[pidx] = 'ioaiu' + qidx;
       _child_blk[pidx]   = 'ioaiu';
       num_io_aiu_tx_if = obj.AiuInfo[pidx].smiPortParams.tx.length;
       num_io_aiu_rx_if = obj.AiuInfo[pidx].smiPortParams.rx.length;
       numIoAiu = numIoAiu + 1;
       qidx++;
       }
   }
   for(pidx = 0; pidx < obj.nDCEs; pidx++) {
       ridx = pidx + obj.nAIUs;
       _child_blkid[ridx] = 'dce' + pidx;
       _child_blk[ridx]   = 'dce';
       num_dce_tx_if = obj.DceInfo[pidx].smiPortParams.tx.length;
       num_dce_rx_if = obj.DceInfo[pidx].smiPortParams.rx.length;
   }
   for(pidx =  0; pidx < obj.nDMIs; pidx++) {
       ridx = pidx + obj.nAIUs + obj.nDCEs;
       _child_blkid[ridx] = 'dmi' + pidx;
       _child_blk[ridx]   = 'dmi';
       num_dmi_tx_if = obj.DmiInfo[pidx].smiPortParams.tx.length;
       num_dmi_rx_if = obj.DmiInfo[pidx].smiPortParams.rx.length;
   }
   for(pidx = 0; pidx < obj.nDIIs; pidx++) {
       ridx = pidx + obj.nAIUs + obj.nDCEs + obj.nDMIs;
       _child_blkid[ridx] = 'dii' + pidx;
       _child_blk[ridx]   = 'dii';
       num_dii_tx_if = obj.DiiInfo[pidx].smiPortParams.tx.length;
       num_dii_rx_if = obj.DiiInfo[pidx].smiPortParams.rx.length;
   }
   for(pidx = 0; pidx < obj.nDVEs; pidx++) {
       ridx = pidx + obj.nAIUs + obj.nDCEs + obj.nDMIs + obj.nDIIs;
       _child_blkid[ridx] = 'dve' + pidx;
       _child_blk[ridx]   = 'dve';
       num_dve_tx_if = obj.DveInfo[pidx].smiPortParams.tx.length;
       num_dve_rx_if = obj.DveInfo[pidx].smiPortParams.rx.length;
   }
%>


////////////////////////////////////////////////////////////////////////////////
// Scoreboard transaction code starts here
////////////////////////////////////////////////////////////////////////////////
import uvm_pkg::*;
`include "uvm_macros.svh"

class fsys_scb_txn extends uvm_object;

   `uvm_object_param_utils(fsys_scb_txn)

   int fsys_unique_txn_id;
   time last_active_point;
   time created;
   // Save initial transaction. A CHI or an AXI packet
   <% for(var pidx = 0; pidx < _child_blkid.length; pidx++) { %>
   <%  if(_child_blk[pidx].match('chiaiu')) { %>
   <%=_child_blkid[pidx]%>_env_pkg::chi_req_seq_item m_chi_req_pkt_<%=pidx%>;
   <%=_child_blkid[pidx]%>_env_pkg::chi_snp_seq_item m_chi_snp_pkt_<%=pidx%>;
   <% } // if chiaiu%>
   <%  if(_child_blk[pidx].match('ioaiu')) { %>
   <%=_child_blkid[pidx]%>_env_pkg::ace_read_addr_pkt_t m_axi_rd_addr_pkt_<%=pidx%>;
   <%=_child_blkid[pidx]%>_env_pkg::ace_write_addr_pkt_t m_axi_wr_addr_pkt_<%=pidx%>;
   <% if(obj.AiuInfo[pidx].fnNativeInterface == "ACE5"||obj.AiuInfo[pidx].fnNativeInterface == "ACE"){ %>
   <%=_child_blkid[pidx]%>_env_pkg::ace_snoop_addr_pkt_t m_axi_snp_addr_pkt_<%=pidx%>;
   <% } // if ACE%>
   <% } // if ioaiu%>
   <% } // foreach aius%>
   
   smi_msgs_t  smi_msg_order_q[$];
   string ace_command_type;
   bit ace_if = 0;
   bit[64:0] smi_addr;
   bit[64:0] next_smi_addr;
   bit[64:0] last_smi_addr;
   bit   smi_addr_val = 0;
   longint m_lower_wrapped_boundary;
   longint m_upper_wrapped_boundary;
   longint exp_addr_q[$];
   int dest_funit_id = -1;
   int source_funit_id = -1;
   int dce_funit_id = -1;
   bit dmi_bound = 0;
   bit dii_bound = 0;
   bit register_txn = 0;
   int smi_msg_id;
   int str_rmsg_id;
   bit dce_str_ready;
   int cmdreq_did;
   int smi_targ_ncore_unit_id;
   int smi_src_ncore_unit_id;
   int smi_stash_nid;
   int smi_stash_lpid;
   int smi_stash_valid;
   int smi_stash_dtr_msg_id;
   bit dbid_val = 0;
   int dbid;
   bit compack_dbid_val = 0;
   int compack_dbid;
   // List indexed by AIU ID to store the message ID of snoops sent by DCE
   int snooper_msg_id[int]; 
   bit rbid_val_q[$];
   int rbid_q[$];
   int rbid_unit_id_q[$];
   int exp_chi_data_flits;
   bit axi_data_seen = 0;
   bit axi_rd_atm_data_seen = 0;
   bit axi_write_resp_seen = 0;
   int chi_data_flits_atomic;
   bit readreceipt_exp = 0;
   bit readreceipt_seen = 0;
   bit dmi_check_done = 0;
   bit dii_check_done = 0;
   bit aiu_check_done = 0;
   bit dce_check_done = 0;
   bit chi_check_done = 0;
   bit only_mrd_pref_possible = 0;
   bit compack_seen;
   bit comp_seen;
   bit only_waiting_for_compack;
   bit aiu_str_seen;
   bit delete_at_str;
   int aiu_str_cnt = 0;
   bit is_read;
   bit is_write;
   bit is_coh;
   bit is_dvm;
   bit is_sys_evnt;
   bit sys_rsp_sent;
   typedef struct{
      int funit_id;
      int smi_msg_id;
      bit dve_sent;
      bit unit_rcvd;
      bit rsp_sent;
      bit rsp_rcvd;
   }sys_evnt_rcvrs_s;
   sys_evnt_rcvrs_s sys_evnt_rcvrs_q[$];
   bit is_snp;
   bit[64:0] dvm_part_2_addr_q[2];
   bit[64:0] dvm_part_1_addr_q[2];
   bit dvm_snp_1_seen_at_aiu = 0;
   bit dvm_snp_2_seen_at_aiu = 0;
   bit dvm_mpf3_range_q[2];
   int dvm_mpf3_num_q[2];
   int dvm_mpf1_q[2];
   int dvm_part_2_mpf1_q[2];
   bit chi_dvm_snp_addr_seen_q[$];
   int dvm_complete_unit_id_q[$];
   int dvm_complete_exp;
   int dvm_complete_resp_exp;
   bit ac_dvmcmpl_exp;
   bit ac_dvmcmpl_resp_exp;
   int dvm_complete_arid_q[$];
   int dvm_complete_resp_unit_q[$];
   bit dvm_part_2_exp;
   bit dvm_part_2_seen;
   bit dvm_resp_seen;
   int ioaiu_core_id = -1;
   int exp_smi_data_pkts = 1;
   int exp_smi_cmd_pkts = 1;
   bit multi_cacheline_access = 0;
   bit mpf2_flowid_val = 0;
   bit is_dataless_txn = 0;
   bit is_cmo_txn = 0;
   bit only_waiting_for_mrd = 0;
   bit dataless_wrunq_q[$];
   bit is_atomic_txn = 0;
   bit is_stash_txn = 0;
   bit stash_accept = 0;
   int mpf2_flowid;
   int dtr_msg_id_q[$];
   bit[64:0] dtr_addr_q[$];
   int str_msg_id_q[$];
   int dce_queue_idx[$];
   int aiu_queue_idx[$];
   int updreq_msg_id;
   bit cmd_req_val_q[$];
   // created by AIUs to match CMDReqs at DCE/DMI/DII
   int cmd_req_id_q[$];
   int cmd_req_targ_q[$];
   bit[64:0] cmd_req_addr_q[$];
   bit[64:0] owo_cmd_req_addr_q[$];
   bit[64:0] owo_cmo_seen_addr_q[$];
   bit[64:0] owo_cmo_str_seen_addr_q[$];
   bit       cmd_req_ns_q[$];
   bit cmd_req_excl_q[$];
   int cmd_req_subid_q[$], str_subid_q[$], subid_q[$];
   int subid_cnt;

   typedef struct{
      //ID DII unit id value pair
      time created;
      bit done;
      int id; // AXI AWID or ARID
      int funit_id;
   }fsys_axi_id_s;
   fsys_axi_id_s cmd_req_axi_id_q[$];
   bit[64:0] updreq_req_addr;
   bit mrd_possible_q[$];
   int str_msg_id_val_q[$];
   int updreq_msg_id_val;
   int str_unit_id_q[$];
   bit delete_at_dtr = 0;
   bit delete_at_aiu = 0;
   bit delete_at_dce = 0;
   bit chi_smi_cmd_seen = 0;
   int rbr_rbid_q[$];
   bit rbr_rbid_val_q[$];
   int snpdat_unit_id_q[$];
   int snpsrc_unit_id_q[$];
   bit [64:0] recall_addr;
   // DCE prediction variables
   bit snoops_exp_q[$];
   bit[1:0] mrdreq_seen_q[$]; // 0 = none seen, 1 = seen at DCE 2 = seen at DMI
   bit[2:0] rbrreq_seen_q[$]; // 0 = none seen, 1 = seen at DCE, 2 = seen at DMI, 3 = release seen at dce, 4 = release seen at dmi
   bit rbuse_seen = 0;
   int rbuse_count = 0;
   int internal_rbuse_count = 0;
   int rbrsvd_count = 0;
   bit rbr_release_exp = 0;
   bit updreq_seen = 0;
   //queues to store information of each CMDReq for same txn
   int cmd_msg_id_q[$]; //created by DCE to use for snp, MRD tracking
   bit[64:0] cmd_addr_q[$];
   bit[7:0]  snp_msg_type_q[$];
   int cmd_did_q[$];
   int dce_funitid_q[$];
   int snpreq_cnt_q[$];
   smi_msg_type_e  smi_snp_msg_type_q[$];
   int snprsp_cnt_q[$];
   int snpreq_msg_id_q[$];
   int snpreq_did_q[$];
   int snpreq_unq_id_q[$];
   int snpreq_targ_id_q[$];
   int snpreq_rbid_q[$];
   int snpreq_src_id_q[$];
   bit internal_rbid_release_q[$];
   bit[63:0] snpreq_addr_q[$];
   bit       snpreq_ns_q[$];
   bit[63:0] chi_snpreq_addr;
   int chi_snp_txnid_q[$];
   int chi_snp_data_count_q[$];
   bit[1:0] snp_up_q[$];
   bit      snp_rsp_sent_q[$];
   bit read_acc_dtr_exp_q[$];
   int read_acc_dtr_tgtid_q[$];
   int read_acc_dtr_msgid_q[$];
   bit ioaiu_snprsp_exp_q[$];
   bit ioaiu_snpdat_exp_q[$];
   bit ioaiu_snp_data_seen_q[$];
   int ioaiu_snp_addr_seen_q[$];
   bit [1:0] ioaiu_dvm_snp_addr_seen_q[$];
   bit ioaiu_snp_data_seen = 0;
   bit snp_data_to_dmi_q[$];
   bit snp_data_to_aiu = 0;
   bit snp_data_to_aiu_q[$];
   bit smi_ns = 0;
   bit smi_pr = 0;
   bit [3:0] smi_pri = 0;
   bit[3:0] smi_qos = 0;
   bit cmdreq_skip = 0;
   bit snp_ioaiu_from_chi_q[$];
   bit snp_chi_from_chi=0;
   bit gprar_readid;
   bit gprar_writeid;
   bit pcie_ordermode_rd_en = 0;
   bit pcie_ordermode_wr_en = 0;
   bit[64:0] pcie_mode_smi_addr_q[$];
   bit snp_chi_from_ioaiu_q[$];
   bit combined_cmd = 0;
   bit chi_unsupp_txn = 0;
   int chi_cmd_num = 0;
   //bit[8:0] smi_vz_ca_ac_ns_pr_qos_q[$];
   <% for(var pidx = 0; pidx < obj.nDCEs; pidx++) { %>
      dce<%=pidx%>_smi_agent_pkg::smi_seq_item cmd_req_pkt_<%=pidx%>_q[$];
   <% } //foreach DCE %>

   // MEM_CONSISTENCY : Data variables
   bit               snoop_data_fwded=0;
   cache_data_t      chi_txn_data;
   cache_byte_en_t   chi_byte_en;
   bit[63:0]         chi_cacheline_addr[];
   bit               dtr_data_inv_seen = 0;

   // MEM_CONSISTENCY : Data variables
   cache_data_t      ioaiu_txn_data[];
   cache_byte_en_t   ioaiu_byte_en[];
   bit[63:0]         ioaiu_cacheline_addr[];
   int               total_cachelines;

   // MEM_CONSISTENCY : Snoop data
   // First index: funit_id, second index: addr 
   cache_data_t      snoop_data[int][bit[63:0]];
   cache_byte_en_t   snoop_be[int][bit[63:0]];

   bit owo_write = 0;

   // add print_latency_delay
   int dtrrsp_rmsg_id_q[$];
   int dtwrsp_rmsg_id_q[$];
   int strrsp_rmsg_id_q[$];
   int mrdrsp_rmsg_id_q[$];
   int snprsp_rmsg_id_q[$];
   int rbrsp_rmsg_id_q[$];
   int slv_wr_axi_id_q[$];
   int slv_rd_axi_id_q[$];

   time t_table[string][$];

   // str_transport_link[$]               "endpoint" ,   "startpoint" , "comment" =>   t_table[END POINT]-t_table[START POINT]
   struct {
                                    string endpoint; string startpoint; string comment;
   } str_transport_link[$]  = '{
                                        '{"cmd_req_aiu"    ,"chi_req"       ,"CHI req->smi"}    
                                       ,'{"chi_rdata"      ,"chi_req"       ,"CHI req->rdata"}    
                                       ,'{"chi_wdata"      ,"chi_req"       ,"CHI req->wdata"}    
                                       ,'{"chi_crsp"       ,"chi_req"       ,"CHI req->crsp"}    
                                       ,'{"chi_srsp"       ,"chi_req"       ,"CHI req->srsp"}    
                                       ,'{"str_rsp_aiu"    ,"chi_wdata"     ,"CHI wdata->dtwrsp->strrsp"}    
                                       ,'{"dtw_req_aiu"    ,"chi_wdata"     ,"CHI wdata->dtwreq"}    
                                       ,'{"ioaiu_rd_data"  ,"ioaiu_rd_addr" ,"IOAIU rd ull latency"}
                                       ,'{"ioaiu_rd_data"  ,"dtr_req_aiu"   ,"IOAIU smi-> AXI4"}
                                       ,'{"ioaiu_wr_resp"  ,"ioaiu_wr_addr" ,"IOAIU wr full latency"}
                                       ,'{"cmd_req_aiu"    ,"ioaiu_rd_addr" ,"IOAIU rd req->smi"}
                                       ,'{"cmd_req_aiu"    ,"ioaiu_wr_addr" ,"IOAIU wr req -> smi"}
                                       ,'{"dtw_req_aiu"    ,"ioaiu_wr_data" ,"IOAIU wdata-> dtwreq"}
                                       ,'{"ioaiu_wr_data"  ,"ioaiu_wr_addr" ,"IOAIU AXI4 interface"}
                                       ,'{"ioaiu_wr_resp"  ,"dtw_req_aiu"   ,"IOAIU dtw req -> AXI resp"}
                                       ,'{"str_req_aiu"    ,"cmd_req_aiu"   ,"cmdreq -> strreq"}
                                       ,'{"mrd_req_dce"    ,"cmd_req_aiu"   ,"DCE cmd req-> mrd req"}
                                       ,'{"dtr_req_aiu"    ,"cmd_req_aiu"   ,"cmd req->data received"}
                                       ,'{"dtr_req_aiu"    ,"mrd_req_dce"   ,"mrd req-> dtr req"}
                                       ,'{"dtw_req_aiu"    ,"str_req_aiu"   ,"strreq -> dtw req"}
                                       ,'{"cmd_req_slv"    ,"cmd_req_aiu"   ,"transport_ndp"}
                                       ,'{"cmd_rsp_aiu"    ,"cmd_rsp_slv"   ,"transport_ndp"}
                                       ,'{"mrd_req_slv"    ,"mrd_req_dce"   ,"transport_ndp"}
                                       ,'{"mrd_rsp_slv"    ,"mrd_rsp_dce"   ,"transport_ndp"}
                                       ,'{"rbr_req_slv"    ,"rbr_req_dce"   ,"transport_ndp"}
                                       ,'{"rbr_rsp_dce"    ,"rbr_rsp_slv"   ,"transport_ndp"}
                                       ,'{"dtw_req_slv"    ,"dtw_req_aiu"   ,"transport_dp"}
                                       ,'{"dtw_rsp_aiu"    ,"dtw_rsp_slv"   ,"transport_dp"}
                                       ,'{"dtr_req_aiu"    ,"dtr_req_slv"   ,"transport_dp"}
                                       ,'{"dtr_rsp_slv"    ,"dtr_rsp_aiu"   ,"transport_dp"}
                                       ,'{"str_req_aiu"    ,"str_req_slv"   ,"transport_ndp"}
                                       ,'{"str_rsp_slv"    ,"str_rsp_aiu"   ,"transport_ndp"}
                                       ,'{"dmi_rd_addr"     ,"cmd_req_slv"   ,"DMI smi->AXI4"}
                                       ,'{"dmi_wr_data"    ,"dmi_wr_addr"    ,"DMI addr->data latency"}
                                       ,'{"dtr_req_slv"    ,"dmi_rd_data"    ,"DMI data AXI4->smi"}
                                       ,'{"dmi_wr_data"    ,"dtw_req_slv"    ,"DMI data smi -> AXI4"}
                                       ,'{"dmi_rd_data"    ,"dmi_rd_addr"    ,"Memory read latency"}
                                       ,'{"dmi_wr_resp"    ,"dmi_wr_addr"    ,"Memory write latency"}
                                       ,'{"dii_rd_addr"     ,"cmd_req_slv"   ,"DII smi->AXI4"}
                                       ,'{"dii_wr_data"    ,"dtw_req_slv"    ,"DII data smi -> AXI4"}
                                       ,'{"dii_wr_data"    ,"dii_wr_addr"    ,"DII addr->data latency"}
                                       ,'{"dii_rd_data"    ,"dii_rd_addr"    ,"Device read latency"}
                                       ,'{"dii_wr_resp"    ,"dii_wr_addr"    ,"Device write latency"}
                                       };

   extern function new(string name = "fsys_scb_txn");
   extern function print_me();
   extern function print_path();
   extern function update_time_accessed(string msg_name="", string agent_name="");
   extern function print_time_accessed();
   extern function cleanup_chi_op_queues();
   <% for(var pidx = 0; pidx < _child_blkid.length; pidx++) { %>
   extern function <%=_child_blkid[pidx]%>_print_time_accessed();
   <%  if(_child_blk[pidx].match('ioaiu')) { %>
   extern function predict_dtw_count_<%=pidx%>();
   extern function predict_dtr_count_<%=pidx%>();
   extern function save_ioaiu_cmd_req_<%=pidx%>(ref <%=_child_blkid[pidx]%>_smi_agent_pkg::smi_seq_item m_pkt);
   extern function save_ioaiu_wrtxn_data_<%=pidx%>(ref <%=_child_blkid[pidx]%>_env_pkg::ace_write_data_pkt_t m_pkt);
   extern function save_ioaiu_rdtxn_data_<%=pidx%>(ref <%=_child_blkid[pidx]%>_env_pkg::ace_read_data_pkt_t m_pkt);
   extern function save_ioaiu_snp_data_<%=pidx%>(input <%=_child_blkid[pidx]%>_env_pkg::ace_snoop_data_pkt_t m_pkt, int funit_id, bit[63:0] addr);
   <% } // if ioaiu%>
   <%  if(_child_blk[pidx].match('chiaiu')) { %>
   //MEM_CONSISTENCY
   extern function save_chi_txn_data_<%=pidx%>(input <%=_child_blkid[pidx]%>_env_pkg::chi_dat_seq_item m_pkt);
   extern function save_chi_snp_data_<%=pidx%>(input <%=_child_blkid[pidx]%>_env_pkg::chi_dat_seq_item m_pkt, int funit_id, bit[63:0] addr);
   <% } // if chiaiu%>
   <% } // foreach aius%>

endclass : fsys_scb_txn

function fsys_scb_txn::new(string name = "fsys_scb_txn");
  created = $time;
endfunction : new

function fsys_scb_txn::print_me();
   string msg = "";
      $sformat(msg, "FSYS_UID:%0d verbose prints below\n", fsys_unique_txn_id);
      $sformat(msg, "%0s FSYS_UID          : %0d\n",  msg, fsys_unique_txn_id);
<% for(var pidx = 0; pidx < _child_blkid.length; pidx++) { %>
<%  if(_child_blk[pidx].match('chiaiu')) { %>
   if (m_chi_req_pkt_<%=pidx%> !== null) begin
      $sformat(msg, "%0s CHI Access Type   : %0s\n", msg, (is_coh == 1 ? "Coherent" : "Non-Coherent"));
      $sformat(msg, "%0s Instance          : %0s\n", msg, "<%=_child_blkid[pidx]%>");
      $sformat(msg, "%0s Memory            : %0s\n", msg, (dmi_bound ? "DMI" : (dii_bound ? "DII" : "ERROR")));
      $sformat(msg, "%0s Address FunitID   : 0x%0h\n", msg, dest_funit_id);
      $sformat(msg, "%0s CHI data flits remaining   : 'd%0d", msg, exp_chi_data_flits);
      $sformat(msg, "\n%0s DBID_val = %0d, DBID = 0x%0h ", msg, dbid_val, dbid);
      $sformat(msg, "%0s \n%0s", msg, m_chi_req_pkt_<%=pidx%>.convert2string());
   end
<% } // if chiaiu%>
<%  if(_child_blk[pidx].match('ioaiu')) { %>
   if (m_axi_rd_addr_pkt_<%=pidx%> !== null && m_axi_wr_addr_pkt_<%=pidx%> == null) begin
      $sformat(msg, "%0s AXI Type          : %0s %0s\n", msg, "Read", is_coh == 1 ? "Coherent" : "Non-Coherent");
      $sformat(msg, "%0s Instance          : %0s\n", msg,"<%=_child_blkid[pidx]%>");
      $sformat(msg, "%0s Core              : %0d\n", msg,ioaiu_core_id);
      $sformat(msg, "%0s Memory            : %0s\n", msg,(dmi_bound ? "DMI" : (dii_bound ? "DII" : "ERROR")));
      $sformat(msg, "%0s Address FunitID   : 0x%0h\n", msg, dest_funit_id);
      $sformat(msg, "%0s AXI data seen     : %0s\n", msg, (axi_data_seen ? "Yes" : "No"));
      $sformat(msg, "%0s DTR's remaining   : 'd%0d\n", msg, exp_smi_data_pkts);
      $sformat(msg, "%0s CMDReq's remaining: 'd%0d\n", msg, exp_smi_cmd_pkts);
      $sformat(msg, "%0s Multi CL access   : %0s\n", msg, (multi_cacheline_access ? "Yes" : "No"));
      $sformat(msg, "%0s %0s", msg, m_axi_rd_addr_pkt_<%=pidx%>.sprint_pkt());
   end
   if (m_axi_wr_addr_pkt_<%=pidx%> !== null) begin
      $sformat(msg, "%0s AXI Type          : %0s %0s\n", msg, "Write", is_coh == 1 ? "Coherent" : "Non-Coherent");
      $sformat(msg, "%0s Core%0d           : %0s\n", msg, ioaiu_core_id, "<%=_child_blkid[pidx]%>");
      $sformat(msg, "%0s Memory            : %0s\n", msg, (dmi_bound ? "DMI" : (dii_bound ? "DII" : "ERROR")));
      $sformat(msg, "%0s Address FunitID   : 0x%0h\n", msg, dest_funit_id);
      $sformat(msg, "%0s AXI data seen     : %0s\n", msg, (axi_data_seen ? "Yes" : "No"));
      $sformat(msg, "%0s DTW's remaining   : 'd%0d\n", msg, exp_smi_data_pkts);
      $sformat(msg, "%0s CMDReq's remaining: 'd%0d\n", msg, exp_smi_cmd_pkts);
      $sformat(msg, "%0s Multi CL access   : %0s\n", msg, (multi_cacheline_access ? "Yes" : "No"));
      $sformat(msg, "%0s %0s",  msg, m_axi_wr_addr_pkt_<%=pidx%>.sprint_pkt());
   end
<% } // if ioaiu%>
<% } // foreach aius%>
   $sformat(msg, "%s\naiu_check_done:%0d dce_check_done:%0d dmi_check_done:%0d dii_check_done:%0d",  msg, aiu_check_done, dce_check_done, dmi_check_done, dii_check_done);
   // This is at UVM_NONE verbosity because it's only printed in error cases.
   `uvm_info("FSYS_TXN_Q", $psprintf("%0s",msg), UVM_NONE);
endfunction : print_me

////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Function : print_path
//
////////////////////////////////////////////////////////////////////////////////////////////////////////////
function fsys_scb_txn::print_path();
   string msg = "";
   if (multi_cacheline_access == 1) return;
   $sformat(msg, "FSYS_UID:%0d NCore Transaction Path:", fsys_unique_txn_id);
   foreach (smi_msg_order_q[idx]) begin
      if (idx == smi_msg_order_q.size()-1)
         $sformat(msg, "%0s %0s.",  msg, smi_msg_order_q[idx].name());
      else
         $sformat(msg, "%0s %0s -> ",  msg, smi_msg_order_q[idx].name());
   end
   `uvm_info("FSYS_TXN_PATH", $psprintf("%0s",msg), UVM_NONE+50);
endfunction : print_path

//===================================================================================================
//Call this function to update the time a txn in the fsys_txn_q is accessed. 
//===================================================================================================
function fsys_scb_txn::update_time_accessed(string msg_name="", string agent_name="");
  last_active_point = $time;
  if($test$plusargs("print_latency_delay") && msg_name.len() ) begin:_print_latency
     t_table[msg_name].push_back($time);
     $display("FSYS_UID:%0d %0s PKT RECEIVED => %s AT %0t",fsys_unique_txn_id,agent_name,msg_name,last_active_point);
     if (msg_name =="str_rsp_slv") begin:_str_rsp_slv
         print_time_accessed();
     end:_str_rsp_slv
  end:_print_latency
endfunction : update_time_accessed

//===================================================================================================
//Call this function to print all the existing value in t_table & the diff between endpoint and startpoint time  
//===================================================================================================
function fsys_scb_txn::print_time_accessed();
         string msg = "";

         // Sort
        string sorted_t_table[] = new [t_table.size()];
        int index = 0;
        foreach (t_table[str]) begin
              sorted_t_table[index++] = str;
        end
        sorted_t_table.sort() with (t_table[item][0]);

         $sformat(msg, "------------------------------------------------------ \n");
         $sformat(msg, "%0sFSYS_UID:%0d UPDATED TIMING FOR LATENCY CALCULATION \n", msg,fsys_unique_txn_id);
         $sformat(msg, "%0s------------------------------------------------------ \n",msg);
         foreach (sorted_t_table[j]) begin
            foreach (t_table[sorted_t_table[j]][i]) begin
            $sformat(msg, "%0s| %21s[%0d]  | %0t |\n", msg,sorted_t_table[j],i,t_table[sorted_t_table[j]][i]);
            end
         end
         foreach (str_transport_link[j]) begin
           if (t_table.exists(str_transport_link[j].endpoint) && t_table.exists(str_transport_link[j].startpoint))
              foreach(t_table[str_transport_link[j].endpoint][i])
                    $sformat(msg, "%0s| %25s | %20s[%0d]  -  %-20s[%0d] = %0t |\n", msg, str_transport_link[j].comment,str_transport_link[j].endpoint,i, str_transport_link[j].startpoint,i, t_table[str_transport_link[j].endpoint][i] - t_table[str_transport_link[j].startpoint][i]);

         end
         $sformat(msg, "%0s------------------------------------------------------ \n",msg);
         $display(msg);
endfunction : print_time_accessed
//===================================================================================================
//cleanup_chi_op_queues : Used for combined write OPs. cleans up txn queues to handle second 
//                         CmdReq of the transction.
//===================================================================================================
function fsys_scb_txn::cleanup_chi_op_queues();
   str_msg_id_q.delete();  
   cmd_req_val_q.delete();
   cmd_req_id_q.delete(); 
   cmd_req_targ_q.delete();
   cmd_req_addr_q.delete(); 
   cmd_req_ns_q.delete(); 
   cmd_req_excl_q.delete(); 
   cmd_req_subid_q.delete(); 
   //cmd_req_axi_id_q.delete(); 
   mrd_possible_q.delete();  
   str_msg_id_val_q.delete();
   str_unit_id_q.delete(); 
endfunction : cleanup_chi_op_queues

<% for(var pidx = 0; pidx < _child_blkid.length; pidx++) { %>
<%  if(_child_blk[pidx].match('ioaiu')) { %>
function fsys_scb_txn::predict_dtw_count_<%=pidx%>();
// This code is leveraged from ioaiu_scb_txn.svh (setup_ace_write_req() function)
   int m_burst_length = m_axi_wr_addr_pkt_<%=pidx%>.awlen + 1;
   int total_cacheline_count = 1;
   longint m_start_addr = (m_axi_wr_addr_pkt_<%=pidx%>.awaddr/(<%=_child_blkid[pidx]%>_env_pkg::WXDATA/8)) * (<%=_child_blkid[pidx]%>_env_pkg::WXDATA/8);
   int m_num_bytes = 2 ** m_axi_wr_addr_pkt_<%=pidx%>.awsize;
   longint m_aligned_addr = (m_start_addr/(m_num_bytes)) * m_num_bytes;
   bit m_aligned = (m_aligned_addr === m_start_addr);
   int m_dtsize = m_num_bytes * m_burst_length;
   int m_awlen_tmp = 0;
   m_lower_wrapped_boundary = (m_start_addr/m_dtsize) * m_dtsize; 
   m_upper_wrapped_boundary = m_lower_wrapped_boundary + m_dtsize;

   for (int i = 0; i < m_burst_length - 1; i++) begin
      if (m_aligned) begin
         m_start_addr = m_start_addr + m_num_bytes;
         if (m_axi_wr_addr_pkt_<%=pidx%>.awburst === <%=_child_blkid[pidx]%>_env_pkg::AXIWRAP) begin
            if (m_start_addr >= m_upper_wrapped_boundary) begin
               m_start_addr = m_lower_wrapped_boundary;
            end
         end
      end
      else begin
         m_start_addr = m_aligned_addr + m_num_bytes; 
         m_aligned    = 1;
      end
      if (m_start_addr[<%=_child_blkid[pidx]%>_env_pkg::SYS_wSysCacheline-1:0] === '0 &&
          (m_start_addr[<%=_child_blkid[pidx]%>_env_pkg::WAXADDR-1:<%=_child_blkid[pidx]%>_env_pkg::SYS_wSysCacheline] !== m_axi_wr_addr_pkt_<%=pidx%>.awaddr[<%=_child_blkid[pidx]%>_env_pkg::WAXADDR-1:<%=_child_blkid[pidx]%>_env_pkg::SYS_wSysCacheline] 
            || (m_axi_wr_addr_pkt_<%=pidx%>.awburst === <%=_child_blkid[pidx]%>_env_pkg::AXIWRAP && total_cacheline_count > 1)) 
          ) begin
         total_cacheline_count++;
         exp_addr_q.push_back(m_start_addr);
      end
      if (total_cacheline_count === 1) begin
         m_awlen_tmp++;
      end
      last_smi_addr = m_start_addr;
   end //for_m_burst_length
   exp_smi_data_pkts = total_cacheline_count;
   exp_smi_cmd_pkts = total_cacheline_count;
   total_cachelines = total_cacheline_count;
   if (m_axi_wr_addr_pkt_<%=pidx%>.awburst !== <%=_child_blkid[pidx]%>_env_pkg::AXIWRAP) begin
      m_lower_wrapped_boundary = m_axi_wr_addr_pkt_<%=pidx%>.awaddr; 
      m_upper_wrapped_boundary = last_smi_addr + 'h04; 
   end
   if (exp_smi_data_pkts > 1) begin
      multi_cacheline_access = 1;
      next_smi_addr = m_axi_wr_addr_pkt_<%=pidx%>.awaddr;
      if (last_smi_addr[12:12] !== smi_addr[12:12]) begin
         print_me();
         `uvm_error("FSYS_SCB", $sformatf(
            "FSYS_UID:%0d : This AXI transaction crosses 4k boundary.",
            fsys_unique_txn_id))
      end
   end 
   <%  if(obj.AiuInfo[pidx].orderedWriteObservation == 1) { %>
      exp_addr_q.push_front(m_axi_wr_addr_pkt_<%=pidx%>.awaddr);
      //exp_smi_cmd_pkts = exp_smi_cmd_pkts * 2;
      if(is_atomic_txn == 0) owo_write = 1;
   <% } // if ioaiu-p%>

endfunction : predict_dtw_count_<%=pidx%>

function fsys_scb_txn::predict_dtr_count_<%=pidx%>();
// This code is leveraged from ioaiu_scb_txn.svh (setup_ace_read_req() function)
   longint m_start_addr             = (m_axi_rd_addr_pkt_<%=pidx%>.araddr/(<%=_child_blkid[pidx]%>_env_pkg::WXDATA/8)) * (<%=_child_blkid[pidx]%>_env_pkg::WXDATA/8);
   int     m_arlen_tmp              = 0;
   int     m_num_bytes              = 2 ** m_axi_rd_addr_pkt_<%=pidx%>.arsize;
   int     m_burst_length           = m_axi_rd_addr_pkt_<%=pidx%>.arlen + 1;
   longint m_aligned_addr           = (m_axi_rd_addr_pkt_<%=pidx%>.araddr/(m_num_bytes)) * m_num_bytes; 
   bit     m_aligned                = (m_aligned_addr === m_start_addr);
   int     m_dtsize                 = m_num_bytes * m_burst_length;
   int total_cacheline_count            = 1;
   m_lower_wrapped_boundary = (m_start_addr/m_dtsize) * m_dtsize; 
   m_upper_wrapped_boundary = m_lower_wrapped_boundary + m_dtsize; 

   for (int i = 0; i < m_burst_length - 1; i++) begin : for_m_burst_length
       if (m_aligned) begin
           m_start_addr = m_start_addr + m_num_bytes;
           if (m_axi_rd_addr_pkt_<%=pidx%>.arburst === <%=_child_blkid[pidx]%>_env_pkg::AXIWRAP) begin
               if (m_start_addr >= m_upper_wrapped_boundary) begin
                   m_start_addr = m_lower_wrapped_boundary;
               end
           end
       end
       else begin
           m_start_addr = m_aligned_addr + m_num_bytes; 
           m_aligned    = 1;
       end
       if (m_start_addr[<%=_child_blkid[pidx]%>_env_pkg::SYS_wSysCacheline-1:0] === '0 &&
           (m_start_addr[<%=_child_blkid[pidx]%>_env_pkg::WAXADDR-1:<%=_child_blkid[pidx]%>_env_pkg::SYS_wSysCacheline] !== m_axi_rd_addr_pkt_<%=pidx%>.araddr[<%=_child_blkid[pidx]%>_env_pkg::WAXADDR-1:<%=_child_blkid[pidx]%>_env_pkg::SYS_wSysCacheline] || (m_axi_rd_addr_pkt_<%=pidx%>.arburst === <%=_child_blkid[pidx]%>_env_pkg::AXIWRAP && total_cacheline_count > 1))
       ) begin
           total_cacheline_count++;
           exp_addr_q.push_back(m_start_addr);
           `uvm_info("FSYS_SCB", $sformatf(
            "FSYS_UID:%0d : Exp addr:0x%0h", fsys_unique_txn_id, m_start_addr), UVM_NONE+50)
       end
       if (total_cacheline_count === 1) begin
           m_arlen_tmp++;
       end
      last_smi_addr = m_start_addr;
   end : for_m_burst_length
   exp_smi_data_pkts = total_cacheline_count;
   exp_smi_cmd_pkts = total_cacheline_count;
   total_cachelines = total_cacheline_count;
   if (m_axi_rd_addr_pkt_<%=pidx%>.arburst !== <%=_child_blkid[pidx]%>_env_pkg::AXIWRAP) begin
      m_lower_wrapped_boundary = m_axi_rd_addr_pkt_<%=pidx%>.araddr; 
      m_upper_wrapped_boundary = last_smi_addr + 'h04;
   end
   if (exp_smi_data_pkts > 1) begin
      multi_cacheline_access = 1;
      next_smi_addr = m_axi_rd_addr_pkt_<%=pidx%>.araddr;
      if (last_smi_addr[12:12] !== smi_addr[12:12]) begin
         print_me();
         `uvm_error("FSYS_SCB", $sformatf(
            "FSYS_UID:%0d : This AXI transaction crosses 4k boundary.",
            fsys_unique_txn_id))
      end
   end
endfunction : predict_dtr_count_<%=pidx%>

//====================================================================================================
//
//====================================================================================================
function fsys_scb_txn::save_ioaiu_cmd_req_<%=pidx%>(ref <%=_child_blkid[pidx]%>_smi_agent_pkg::smi_seq_item m_pkt);
   update_time_accessed("cmd_req_aiu","<%=_child_blkid[pidx]%>");
   smi_msg_id = m_pkt.smi_msg_id;
   str_msg_id_q.push_back(m_pkt.smi_msg_id);
   dce_queue_idx.push_back(-1);
   cmd_req_val_q.push_back(1);
   cmd_req_id_q.push_back(m_pkt.smi_msg_id);
   cmd_req_targ_q.push_back(m_pkt.smi_targ_ncore_unit_id);
   cmd_req_addr_q.push_back(m_pkt.smi_addr);
   cmd_req_ns_q.push_back(m_pkt.smi_ns);
   cmd_req_excl_q.push_back(m_pkt.smi_es);
   subid_cnt++;
   subid_q.push_back(subid_cnt);
   str_subid_q.push_back(subid_cnt);
   cmd_req_subid_q.push_back(subid_cnt);
   cmd_req_axi_id_q.push_back('{ 0, 0, -1, -1});
   str_msg_id_val_q.push_back(1);
   str_unit_id_q.push_back(m_pkt.smi_src_ncore_unit_id);
   mpf2_flowid_val = m_pkt.smi_mpf2_flowid_valid;
   mpf2_flowid = m_pkt.smi_mpf2_flowid;
   smi_targ_ncore_unit_id = m_pkt.smi_targ_ncore_unit_id;
   smi_src_ncore_unit_id = m_pkt.smi_src_ncore_unit_id;
   exp_smi_cmd_pkts = exp_smi_cmd_pkts - 1; 
   // if NON-COH atomic, there will not be anymore CmdReqs
   if (dest_funit_id == m_pkt.smi_targ_ncore_unit_id && is_atomic_txn == 1 && exp_smi_cmd_pkts > 0) begin
      exp_smi_cmd_pkts = 0; 
   end
   smi_pr = m_pkt.smi_pr;
   smi_pri = m_pkt.smi_msg_pri;
   smi_qos = m_pkt.smi_qos;

   <%  if(obj.AiuInfo[pidx].orderedWriteObservation == 1) { %>
      if (is_write == 1 && is_coh == 1 && is_atomic_txn == 0) begin
         mpf2_flowid_val = 0;
         //TXN_PATH coverage is only implemeted for single cacheline txns
         //If a second CmdReq is being sent to DCE, it means the line was snooped out, hence add the SNPs to 
            //TXN_PATH variable
         if ( m_pkt.smi_targ_ncore_unit_id inside {addrMgrConst::dce_ids} && multi_cacheline_access == 0 ) begin
            foreach (smi_msg_order_q[idx]) begin
               if (smi_msg_order_q[idx] == smi_msgs_t'(fsys_coverage_pkg::CMD_REQ)) begin
                  smi_msg_order_q.push_back(smi_msgs_t'(fsys_coverage_pkg::SNP_REQ));
                  smi_msg_order_q.push_back(smi_msgs_t'(fsys_coverage_pkg::SNP_RESP));
                  break;
               end
            end
         end
      end
   <% } // if ioaiu-p%>

   if(!multi_cacheline_access) begin
      smi_msg_order_q.push_back(smi_msgs_t'(fsys_coverage_pkg::CMD_REQ));
   end
   if(delete_at_dce) begin
       updreq_msg_id = m_pkt.smi_msg_id;
       dce_funit_id = addrMgrConst::map_addr2dce(m_pkt.smi_addr);
       updreq_msg_id_val = 1;
       updreq_req_addr = m_pkt.smi_addr;
       `uvm_info("FSYS_SCB", $sformatf("FSYS_UID:%0d : Expecting UpdReq packet", fsys_unique_txn_id), UVM_NONE+50)
   end
endfunction : save_ioaiu_cmd_req_<%=pidx%>

//====================================================================================================
//
//====================================================================================================
function fsys_scb_txn::save_ioaiu_wrtxn_data_<%=pidx%>(ref <%=_child_blkid[pidx]%>_env_pkg::ace_write_data_pkt_t m_pkt);
   bit[63:0] m_start_addr             = (m_axi_wr_addr_pkt_<%=pidx%>.awaddr/(<%=_child_blkid[pidx]%>_env_pkg::WXDATA/8)) * (<%=_child_blkid[pidx]%>_env_pkg::WXDATA/8);
   int     m_num_bytes              = 2 ** m_axi_wr_addr_pkt_<%=pidx%>.awsize;
   int     m_burst_length           = m_axi_wr_addr_pkt_<%=pidx%>.awlen + 1;
   bit[63:0] m_aligned_addr           = (m_axi_wr_addr_pkt_<%=pidx%>.awaddr/(m_num_bytes)) * m_num_bytes; 
   bit     m_aligned                = (m_aligned_addr === m_start_addr);
   int     m_dtsize                 = m_num_bytes * m_burst_length;
   bit[63:0] lower_boundary = (m_start_addr/m_dtsize) * m_dtsize; 
   bit[63:0] upper_boundary = m_lower_wrapped_boundary + m_dtsize;
   bit[64:0]                           cacheline_addr;
   bit[7:0]                            cacheline_bytes[];
   bit                                 cacheline_be[];
   bit[<%=obj.wCacheLineOffset%>-1:0]  cache_byte_offset;
   bit[<%=obj.wCacheLineOffset%>-1:0]  beat_start_offset;
   cache_data_t                        txn_data;
   cache_byte_en_t                     byte_en;
   int                                 cacheline_idx = 0;
   int                                 data_bus_bytes;
   cacheline_addr = {(m_axi_wr_addr_pkt_<%=pidx%>.awaddr >> addrMgrConst::WCACHE_OFFSET), <%=obj.wCacheLineOffset%>'b0};
   cache_byte_offset = m_axi_wr_addr_pkt_<%=pidx%>.awaddr[<%=obj.wCacheLineOffset%>-1:0];
   beat_start_offset = m_start_addr[<%=obj.wCacheLineOffset%>-1:0];
   cacheline_bytes = new[(2**<%=obj.wCacheLineOffset%>)];
   cacheline_be = new[(2**<%=obj.wCacheLineOffset%>)];
   data_bus_bytes = <%=obj.AiuInfo[pidx].wData%>/8;

   ioaiu_txn_data = new[total_cachelines];
   ioaiu_byte_en = new[total_cachelines];
   ioaiu_cacheline_addr = new[total_cachelines];
   `uvm_info(`LABEL, $psprintf("FSYS_UID:%0d : IOAIU AXI WRDATA PKT: %0s", fsys_unique_txn_id, m_pkt.sprint_pkt()), UVM_MEDIUM);

   `uvm_info(`LABEL, $psprintf(
      "IOAIU AXI WRDATA: Addr: 0x%0h(cachelie:0x%0h), beat_start_offset=0x%0h, data_bus_bytes=0x%0h, bytes_per_beat=0x%0h, total=0x%0h, lower_Addr=0x%0h, upper_addr=0x%0h, upper_byte_offset=0x%0h, lower_byte_offset=0x%0h", 
      m_axi_wr_addr_pkt_<%=pidx%>.awaddr, cacheline_addr, beat_start_offset, data_bus_bytes, m_num_bytes, m_dtsize, lower_boundary, upper_boundary,
      upper_boundary[<%=obj.wCacheLineOffset%>-1:0], lower_boundary[<%=obj.wCacheLineOffset%>-1:0]), UVM_MEDIUM);
   foreach (m_pkt.wdata[idx]) begin
      for (int i = 0; i < data_bus_bytes; i++) begin
         if ((beat_start_offset >= cache_byte_offset && idx == 0)
             || (idx > 0)) begin
            cacheline_bytes[beat_start_offset] = m_pkt.wdata[idx][8*i +: 8];
            cacheline_be[beat_start_offset] = m_pkt.wstrb[idx][i];
         end
         beat_start_offset++;
         if ((cacheline_addr + beat_start_offset) == upper_boundary) begin
            beat_start_offset = lower_boundary[<%=obj.wCacheLineOffset%>-1:0];
            if (total_cachelines > 1) begin
               ioaiu_cacheline_addr[cacheline_idx] = cacheline_addr;
               for (int idx = 0; idx < (2**<%=obj.wCacheLineOffset%>); idx++) begin
                  txn_data[8*idx +: 8] = cacheline_bytes[idx];
                  byte_en[idx] = cacheline_be[idx];
               end
               cacheline_bytes = new[(2**<%=obj.wCacheLineOffset%>)];
               cacheline_be = new[(2**<%=obj.wCacheLineOffset%>)];
               ioaiu_txn_data[cacheline_idx] = txn_data;
               ioaiu_byte_en[cacheline_idx] = byte_en;
               cacheline_idx++;
               cacheline_addr = lower_boundary;
            end else break;
         end else if (beat_start_offset == 0) begin
            beat_start_offset = 'h0;
            if (total_cachelines > 1) begin
               ioaiu_cacheline_addr[cacheline_idx] = cacheline_addr;
               for (int idx = 0; idx < (2**<%=obj.wCacheLineOffset%>); idx++) begin
                  txn_data[8*idx +: 8] = cacheline_bytes[idx];
                  byte_en[idx] = cacheline_be[idx];
               end
               cacheline_bytes = new[(2**<%=obj.wCacheLineOffset%>)];
               cacheline_be = new[(2**<%=obj.wCacheLineOffset%>)];
               ioaiu_txn_data[cacheline_idx] = txn_data;
               ioaiu_byte_en[cacheline_idx] = byte_en;
               cacheline_idx++;
               cacheline_addr = cacheline_addr + (2**<%=obj.wCacheLineOffset%>);
               if (cacheline_addr == upper_boundary) cacheline_addr = lower_boundary;
            end else begin
               beat_start_offset = lower_boundary[<%=obj.wCacheLineOffset%>-1:0];
            end
         end
      end // for each byte in a beat
   end // foreach data beat
   for (int idx = 0; idx < (2**<%=obj.wCacheLineOffset%>); idx++) begin
      txn_data[8*idx +: 8] = cacheline_bytes[idx];
      byte_en[idx] = cacheline_be[idx];
   end
   ioaiu_cacheline_addr[cacheline_idx] = cacheline_addr;
   ioaiu_txn_data[cacheline_idx] = txn_data;
   ioaiu_byte_en[cacheline_idx] = byte_en;

   foreach(ioaiu_cacheline_addr[idx]) begin
      `uvm_info(`LABEL, $psprintf(
         "FSYS_UID:%0d : IOAIU AXI WRDATA: Addr: 0x%0h, cacheline data=0x%0h, byte_en=0x%0h", 
         fsys_unique_txn_id, ioaiu_cacheline_addr[idx], ioaiu_txn_data[idx], ioaiu_byte_en[idx]), UVM_MEDIUM);
   end


endfunction : save_ioaiu_wrtxn_data_<%=pidx%>
//====================================================================================================
//
//====================================================================================================
function fsys_scb_txn::save_ioaiu_rdtxn_data_<%=pidx%>(ref <%=_child_blkid[pidx]%>_env_pkg::ace_read_data_pkt_t m_pkt);
   bit[63:0] m_start_addr             = (m_axi_rd_addr_pkt_<%=pidx%>.araddr/(<%=_child_blkid[pidx]%>_env_pkg::WXDATA/8)) * (<%=_child_blkid[pidx]%>_env_pkg::WXDATA/8);
   int     bytes_per_beat              = 2 ** m_axi_rd_addr_pkt_<%=pidx%>.arsize;
   int     m_burst_length           = m_axi_rd_addr_pkt_<%=pidx%>.arlen + 1;
   bit[63:0] m_aligned_addr           = (m_axi_rd_addr_pkt_<%=pidx%>.araddr/(bytes_per_beat)) * bytes_per_beat; 
   bit     m_aligned                = (m_aligned_addr === m_start_addr);
   int     total_bytes                 = bytes_per_beat * m_burst_length;
   bit[63:0] lower_boundary = (m_start_addr/total_bytes) * total_bytes; 
   bit[63:0] upper_boundary = m_lower_wrapped_boundary + total_bytes;
   bit[64:0]                           cacheline_addr;
   bit[7:0]                            cacheline_bytes[];
   bit                                 cacheline_be[];
   bit[<%=obj.wCacheLineOffset%>-1:0]  cache_byte_offset;
   bit[<%=obj.wCacheLineOffset%>-1:0]  beat_start_offset;
   cache_data_t                        txn_data;
   cache_byte_en_t                     byte_en;
   int                                 cacheline_idx = 0;
   int                                 data_bus_bytes;
   int                                 beat_start_byte;
   cacheline_addr = {(m_axi_rd_addr_pkt_<%=pidx%>.araddr >> addrMgrConst::WCACHE_OFFSET), <%=obj.wCacheLineOffset%>'b0};
   beat_start_offset = m_start_addr[<%=obj.wCacheLineOffset%>-1:0];
   cache_byte_offset = m_axi_rd_addr_pkt_<%=pidx%>.araddr[<%=obj.wCacheLineOffset%>-1:0];
   cacheline_bytes = new[(2**<%=obj.wCacheLineOffset%>)];
   cacheline_be = new[(2**<%=obj.wCacheLineOffset%>)];
   data_bus_bytes = <%=obj.AiuInfo[pidx].wData%>/8;

   ioaiu_txn_data = new[total_cachelines];
   ioaiu_byte_en = new[total_cachelines];
   ioaiu_cacheline_addr = new[total_cachelines];
   if (m_axi_rd_addr_pkt_<%=pidx%>.arburst == 'h2) begin //WRAP burst 
      lower_boundary = (m_axi_rd_addr_pkt_<%=pidx%>.araddr/total_bytes) * total_bytes;
   end else begin
      lower_boundary = m_axi_rd_addr_pkt_<%=pidx%>.araddr; //beat_start_addr;
   end
   upper_boundary = lower_boundary + total_bytes;
   `uvm_info(`LABEL, $psprintf("FSYS_UID:%0d : IOAIU AXI RDATA PKT: %0s", fsys_unique_txn_id, m_pkt.sprint_pkt()), UVM_MEDIUM);

   `uvm_info(`LABEL, $psprintf(
      "IOAIU AXI RDDATA: Addr: 0x%0h(cacheline(0x%0h), beat_start_offset=0x%0h, data_bus_bytes=0x%0h, bytes_per_beat=0x%0h, total=0x%0h, lower_Addr=0x%0h, upper_addr=0x%0h, upper_byte_offset=0x%0h, lower_byte_offset=0x%0h", 
+      m_axi_rd_addr_pkt_<%=pidx%>.araddr, cacheline_addr, beat_start_offset, data_bus_bytes, bytes_per_beat, total_bytes, lower_boundary, upper_boundary,
      upper_boundary[<%=obj.wCacheLineOffset%>-1:0], lower_boundary[<%=obj.wCacheLineOffset%>-1:0]), UVM_MEDIUM);
      foreach (m_pkt.rdata[idx]) begin
         int beat_end_byte;
         int bytes_saved=0;
         if (idx == 0) begin
            beat_start_byte = (cache_byte_offset - beat_start_offset);
            if (cache_byte_offset > beat_start_offset) beat_start_offset = cache_byte_offset;
         end
         if(idx == 0 && beat_start_byte !== 0 && bytes_per_beat !== data_bus_bytes) begin
            beat_end_byte = bytes_per_beat - 1;//beat_start_byte; // + bytes_per_beat - 1 - cache_byte_offset;
            if (beat_end_byte <= 0) beat_end_byte = beat_start_byte + bytes_per_beat - 1;
            else if (beat_end_byte <= beat_start_byte) beat_end_byte = beat_start_byte + beat_end_byte;
            if (beat_end_byte[m_axi_rd_addr_pkt_<%=pidx%>.arsize] !== beat_start_byte[m_axi_rd_addr_pkt_<%=pidx%>.arsize]) begin
               do begin
                  beat_end_byte = beat_end_byte - 1;
               end while (beat_end_byte[m_axi_rd_addr_pkt_<%=pidx%>.arsize] !== beat_start_byte[m_axi_rd_addr_pkt_<%=pidx%>.arsize]);
            end
         end else begin
            beat_end_byte = beat_start_byte + bytes_per_beat - 1;
         end
         if (beat_end_byte > data_bus_bytes) beat_end_byte = data_bus_bytes-1;
         $display("MEM_DEBUG: beat_start_byte=0x%0h, beat_end_byte=0x%0h, beat_start_offset=0x%0h", beat_start_byte, beat_end_byte, beat_start_offset);
         for (int i = beat_start_byte; i <= beat_end_byte; i++) begin
            cacheline_bytes[beat_start_offset] = m_pkt.rdata[idx][8*i +: 8];
            cacheline_be[beat_start_offset] = 1'b1;
            bytes_saved++;
            beat_start_offset++;
            $display("MEM_DEBUG: here-0 bytes_saved = 0x%0h idx = 0x%0h, (bytes_per_beat-cache_byte_offset)=0x%0h", bytes_saved, idx, (bytes_per_beat-cache_byte_offset));
            if ((bytes_saved == bytes_per_beat) 
               || (i == (data_bus_bytes-1))
               || (bytes_saved == ((beat_end_byte-beat_start_byte) + 1) && idx == 0)
            ) begin
               if (total_bytes < data_bus_bytes && m_axi_rd_addr_pkt_<%=pidx%>.arburst == 'h2 
                  && (cache_byte_offset !== lower_boundary[<%=obj.wCacheLineOffset%>-1:0])) begin
                  beat_start_byte = (cache_byte_offset) - (m_start_addr[<%=obj.wCacheLineOffset%>-1:0]) - (bytes_saved); 
               end else if (bytes_saved == ((beat_end_byte-beat_start_byte) + 1) && idx == 0 && bytes_per_beat !== data_bus_bytes) begin 
                  beat_start_byte = beat_start_byte + bytes_saved; 
                  if (beat_start_byte == data_bus_bytes) beat_start_byte = 0;
               end else if (i < (data_bus_bytes-1)) begin
                  beat_start_byte = i+1;
               end else begin
                  beat_start_byte = 0;
               end
               break;
            end
         end
         if (m_pkt.rdata.size() > 1
            && (beat_start_offset == upper_boundary[<%=obj.wCacheLineOffset%>-1:0]
               || (beat_start_offset >= (2**<%=obj.wCacheLineOffset%>) || beat_start_offset == 0))) begin
            //beat_start_offset = lower_boundary[<%=obj.wCacheLineOffset%>-1:0];
            if ((cacheline_addr + beat_start_offset) == upper_boundary) begin
               beat_start_offset = lower_boundary[<%=obj.wCacheLineOffset%>-1:0];
               if (total_cachelines > 1) begin
                  ioaiu_cacheline_addr[cacheline_idx] = cacheline_addr;
                  for (int idx = 0; idx < (2**<%=obj.wCacheLineOffset%>); idx++) begin
                     txn_data[8*idx +: 8] = cacheline_bytes[idx];
                     byte_en[idx] = cacheline_be[idx];
                  end
                  cacheline_bytes = new[(2**<%=obj.wCacheLineOffset%>)];
                  cacheline_be = new[(2**<%=obj.wCacheLineOffset%>)];
                  ioaiu_txn_data[cacheline_idx] = txn_data;
                  ioaiu_byte_en[cacheline_idx] = byte_en;
                  cacheline_idx++;
                  $display("MEM_DEBUG: here-0 cacheline_addr=0x%0h", cacheline_addr);
                  cacheline_addr = lower_boundary;
                  $display("MEM_DEBUG: here-1 cacheline_addr=0x%0h", cacheline_addr);
               end else break;
            end else if (beat_start_offset == 'h0) begin
               beat_start_offset = 'h0;
               if (total_cachelines > 1) begin
                  ioaiu_cacheline_addr[cacheline_idx] = cacheline_addr;
                  for (int idx = 0; idx < (2**<%=obj.wCacheLineOffset%>); idx++) begin
                     txn_data[8*idx +: 8] = cacheline_bytes[idx];
                     byte_en[idx] = cacheline_be[idx];
                  end
                  cacheline_bytes = new[(2**<%=obj.wCacheLineOffset%>)];
                  cacheline_be = new[(2**<%=obj.wCacheLineOffset%>)];
                  ioaiu_txn_data[cacheline_idx] = txn_data;
                  ioaiu_byte_en[cacheline_idx] = byte_en;
                  cacheline_idx++;
                  $display("MEM_DEBUG: here-2 cacheline_addr=0x%0h", cacheline_addr);
                  cacheline_addr = cacheline_addr + (2**<%=obj.wCacheLineOffset%>);
                  $display("MEM_DEBUG: here-3 cacheline_addr=0x%0h", cacheline_addr);
                  if (cacheline_addr == upper_boundary) begin
                     cacheline_addr = lower_boundary;
                  end
                  $display("MEM_DEBUG: here-5 cacheline_addr=0x%0h", cacheline_addr);
               end else begin
                  beat_start_offset = lower_boundary[<%=obj.wCacheLineOffset%>-1:0];
               end
            end
         end
      end // foreach data beat
   for (int idx = 0; idx < (2**<%=obj.wCacheLineOffset%>); idx++) begin
      txn_data[8*idx +: 8] = cacheline_bytes[idx];
      byte_en[idx] = cacheline_be[idx];
   end
   ioaiu_cacheline_addr[cacheline_idx] = cacheline_addr;
   ioaiu_txn_data[cacheline_idx] = txn_data;
   ioaiu_byte_en[cacheline_idx] = byte_en;

   foreach(ioaiu_cacheline_addr[idx]) begin
      `uvm_info(`LABEL, $psprintf(
         "FSYS_UID:%0d : IOAIU AXI RDATA: Addr: 0x%0h, cacheline data=0x%0h, byte_en=0x%0h", 
         fsys_unique_txn_id, ioaiu_cacheline_addr[idx], ioaiu_txn_data[idx], ioaiu_byte_en[idx]), UVM_MEDIUM);
   end

endfunction : save_ioaiu_rdtxn_data_<%=pidx%>

//====================================================================================================
//
//====================================================================================================
function fsys_scb_txn::save_ioaiu_snp_data_<%=pidx%>(input <%=_child_blkid[pidx]%>_env_pkg::ace_snoop_data_pkt_t m_pkt, int funit_id, bit[63:0] addr);
   bit[63:0] cacheline_addr;
   bit[7:0]  cacheline_bytes[];
   int       data_bus_bytes;
   bit[<%=obj.wCacheLineOffset%>-1:0]  beat_start_offset;
   data_bus_bytes = <%=obj.AiuInfo[pidx].wData%>/8;
   cacheline_bytes = new[(2**<%=obj.wCacheLineOffset%>)];
   cacheline_addr = {(addr >> addrMgrConst::WCACHE_OFFSET), <%=obj.wCacheLineOffset%>'b0};
   `uvm_info("save_ioaiu_snp_data_<%=pidx%>", $psprintf("Snoop addr = 0x%0h", addr), UVM_NONE+50)
   beat_start_offset = addr[<%=obj.wCacheLineOffset%>-1:0];
   foreach (m_pkt.cddata[idx]) begin
      for (int i = 0; i < data_bus_bytes; i++) begin
         cacheline_bytes[beat_start_offset] = m_pkt.cddata[idx][8*i +: 8];
         beat_start_offset++;
      end
   end // foreach data beat
   for (int idx = 0; idx < (2**<%=obj.wCacheLineOffset%>); idx++) begin
      snoop_data[funit_id][cacheline_addr][8*idx +: 8] = cacheline_bytes[idx];
      snoop_be[funit_id][cacheline_addr][idx] = 1'b1;
   end
   `uvm_info("save_ioaiu_snp_data_<%=pidx%>", $psprintf("FSYS_UID:%0d : funit_id = 0x%0h, cacheline addr = 0x%0h, data=0x%0h, BE=0x%0h", fsys_unique_txn_id, funit_id, cacheline_addr, snoop_data[funit_id][cacheline_addr], snoop_be[funit_id][cacheline_addr]), UVM_NONE+50)
endfunction : save_ioaiu_snp_data_<%=pidx%>
<% } // if ioaiu%>

//MEM_CONSISTENCY
<%  if(_child_blk[pidx].match('chiaiu')) { %>
//====================================================================================================
//
//====================================================================================================
function fsys_scb_txn::save_chi_txn_data_<%=pidx%>(input <%=_child_blkid[pidx]%>_env_pkg::chi_dat_seq_item m_pkt);
   chi_cacheline_addr = new[1];
   this.chi_cacheline_addr[0] = {(m_chi_req_pkt_<%=pidx%>.addr >> addrMgrConst::WCACHE_OFFSET), <%=obj.wCacheLineOffset%>'b0};
   `uvm_info("save_chi_txn_data_<%=pidx%>", $psprintf("cacheline addr = 0x%0h", chi_cacheline_addr[0]), UVM_NONE+50)
   case (<%=_child_blkid[pidx]%>_env_pkg::WDATA) 
      128:
      begin
         case(m_pkt.dataid)
            2'b00:
            begin
               chi_txn_data[127:0] = m_pkt.data;
               chi_byte_en[15:0] = m_pkt.be;
            end
            2'b01:
            begin
               chi_txn_data[255:128] = m_pkt.data;
               chi_byte_en[31:16] = m_pkt.be;
            end
            2'b10:
            begin
               chi_txn_data[383:256] = m_pkt.data;
               chi_byte_en[47:32] = m_pkt.be;
            end
            2'b11:
            begin
               chi_txn_data[511:384] = m_pkt.data;
               chi_byte_en[63:48] = m_pkt.be;
            end
         endcase
      end
      256:
      begin
         case(m_pkt.dataid)
            2'b00:
            begin
               chi_txn_data[255:0] = m_pkt.data;
               chi_byte_en[31:0] = m_pkt.be;
            end
            2'b01:
            begin
               //RSVD
            end
            2'b10:
            begin
               chi_txn_data[511:256] = m_pkt.data;
               chi_byte_en[63:32] = m_pkt.be;
            end
            2'b11:
            begin
               //RSVD
            end
         endcase
      end
      512:
      begin
         case(m_pkt.dataid)
            2'b00:
            begin
               chi_txn_data[511:0] = m_pkt.data;
               chi_byte_en[63:0] = m_pkt.be;
            end
            2'b01:
            begin
               //RSVD
            end
            2'b10:
            begin
               //RSVD
            end
            2'b11:
            begin
               //RSVD
            end
         endcase
      end
   endcase // CHI data width
endfunction : save_chi_txn_data_<%=pidx%>

//====================================================================================================
//
//====================================================================================================
function fsys_scb_txn::save_chi_snp_data_<%=pidx%>(input <%=_child_blkid[pidx]%>_env_pkg::chi_dat_seq_item m_pkt, int funit_id, bit[63:0] addr);
   bit[63:0] cacheline_addr;
   cacheline_addr = {(addr >> addrMgrConst::WCACHE_OFFSET), <%=obj.wCacheLineOffset%>'b0};
   `uvm_info("save_chi_snp_data_<%=pidx%>", $psprintf("cacheline addr = 0x%0h", cacheline_addr), UVM_NONE+50)
   case (<%=_child_blkid[pidx]%>_env_pkg::WDATA) 
      128:
      begin
         case(m_pkt.dataid)
            2'b00:
            begin
               snoop_data[funit_id][cacheline_addr][127:0] = m_pkt.data;
               snoop_be[funit_id][cacheline_addr][15:0] = m_pkt.be;
            end
            2'b01:
            begin
               snoop_data[funit_id][cacheline_addr][255:128] = m_pkt.data;
               snoop_be[funit_id][cacheline_addr][31:16] = m_pkt.be;
            end
            2'b10:
            begin
               snoop_data[funit_id][cacheline_addr][383:256] = m_pkt.data;
               snoop_be[funit_id][cacheline_addr][47:32] = m_pkt.be;
            end
            2'b11:
            begin
               snoop_data[funit_id][cacheline_addr][511:384] = m_pkt.data;
               snoop_be[funit_id][cacheline_addr][63:48] = m_pkt.be;
            end
         endcase
      end
      256:
      begin
         case(m_pkt.dataid)
            2'b00:
            begin
               snoop_data[funit_id][cacheline_addr][255:0] = m_pkt.data;
               snoop_be[funit_id][cacheline_addr][31:0] = m_pkt.be;
            end
            2'b01:
            begin
               //RSVD
            end
            2'b10:
            begin
               snoop_data[funit_id][cacheline_addr][511:256] = m_pkt.data;
               snoop_be[funit_id][cacheline_addr][63:32] = m_pkt.be;
            end
            2'b11:
            begin
               //RSVD
            end
         endcase
      end
      512:
      begin
         case(m_pkt.dataid)
            2'b00:
            begin
               snoop_data[funit_id][cacheline_addr][511:0] = m_pkt.data;
               snoop_be[funit_id][cacheline_addr][63:0] = m_pkt.be;
            end
            2'b01:
            begin
               //RSVD
            end
            2'b10:
            begin
               //RSVD
            end
            2'b11:
            begin
               //RSVD
            end
         endcase
      end
   endcase // CHI data width
endfunction : save_chi_snp_data_<%=pidx%>

<% } // if chiaiu%>
<% } // foreach aius%>
// End of file
