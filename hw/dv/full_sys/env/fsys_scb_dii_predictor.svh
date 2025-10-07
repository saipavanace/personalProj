////////////////////////////////////////////////////////////////////////////////
//
// Author       : Neha F
// Purpose      : DII predictor class
// Description  : This is one of the components of fsys_scoreboard. This component
//                contains predicting logic from DII blocks. 
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
// Scoreboard code starts here
////////////////////////////////////////////////////////////////////////////////

import uvm_pkg::*;
`include "uvm_macros.svh"


class fsys_scb_dii_predictor extends uvm_component;

   `uvm_component_utils(fsys_scb_dii_predictor)
   `ifdef FSYS_SCB_COVER_ON 
   fsys_txn_path_coverage fsys_txn_path_cov;
   `endif // `ifdef FSYS_SCB_COVER_ON              


   extern function new(string name = "fsys_scb_dii_predictor", uvm_component parent = null);
   extern function void build_phase(uvm_phase phase);

   <% for(var pidx = 0; pidx < obj.nDIIs; pidx++) { %>
      extern function void analyze_smi_pkt_<%=pidx%>(input dii<%=pidx%>_smi_agent_pkg::smi_seq_item m_pkt, ref fsys_scb_txn fsys_txn_q[$]);
      extern function void smi_cmd_prediction_<%=pidx%>(input dii<%=pidx%>_smi_agent_pkg::smi_seq_item m_pkt, ref fsys_scb_txn fsys_txn_q[$]); 
      extern function void smi_dtw_prediction_<%=pidx%>(input dii<%=pidx%>_smi_agent_pkg::smi_seq_item m_pkt, ref fsys_scb_txn fsys_txn_q[$]);
      extern function void smi_str_prediction_<%=pidx%>(input dii<%=pidx%>_smi_agent_pkg::smi_seq_item m_pkt, ref fsys_scb_txn fsys_txn_q[$]);
      extern function void smi_sysreq_prediction_<%=pidx%>(input dii<%=pidx%>_smi_agent_pkg::smi_seq_item m_pkt, ref fsys_scb_txn fsys_txn_q[$]);
      extern function void smi_sysrsp_prediction_<%=pidx%>(input dii<%=pidx%>_smi_agent_pkg::smi_seq_item m_pkt, ref fsys_scb_txn fsys_txn_q[$]);
      // AXI Native interface
      extern function void analyze_read_addr_pkt_<%=pidx%>(input dii<%=pidx%>_env_pkg::axi4_read_addr_pkt_t m_pkt, ref fsys_scb_txn fsys_txn_q[$]);
      extern function void analyze_write_addr_pkt_<%=pidx%>(input dii<%=pidx%>_env_pkg::axi4_write_addr_pkt_t m_pkt, ref fsys_scb_txn fsys_txn_q[$]);
      extern function void analyze_write_data_pkt_<%=pidx%>(input dii<%=pidx%>_env_pkg::axi4_write_data_pkt_t m_pkt, ref fsys_scb_txn fsys_txn_q[$]);
      extern function void analyze_write_resp_pkt_<%=pidx%>(input dii<%=pidx%>_env_pkg::axi4_write_resp_pkt_t m_pkt, ref fsys_scb_txn fsys_txn_q[$]);
      extern function void analyze_read_data_pkt_<%=pidx%>(input dii<%=pidx%>_env_pkg::axi4_read_data_pkt_t m_pkt, ref fsys_scb_txn fsys_txn_q[$]);
      <% if (obj.DiiInfo[pidx].nExclusiveEntries > 0) { %>
         dii<%=pidx%>_env_pkg::exec_mon_predictor exec_mon_<%=pidx%>;
      <% } //if Excl monitors %>
      //MEM_CONSISTENCY  -- start
      extern function void write_addr_chnl_<%=pidx%>(dii<%=pidx%>_env_pkg::axi4_write_addr_pkt_t m_pkt);
      extern function void write_data_chnl_<%=pidx%>(dii<%=pidx%>_env_pkg::axi4_write_data_pkt_t m_pkt);
      extern function void read_addr_chnl_<%=pidx%>(dii<%=pidx%>_env_pkg::axi4_read_addr_pkt_t m_pkt);
      extern function void read_data_chnl_<%=pidx%>(dii<%=pidx%>_env_pkg::axi4_read_data_pkt_t m_pkt);
      bit[63:0] wr_addr_<%=pidx%>[$];
      bit[63:0] wr_txnid_<%=pidx%>[$];
      int       wr_awsize_<%=pidx%>[$];
      int       wr_awlen_<%=pidx%>[$];
      int       wr_awburst_<%=pidx%>[$];
      bit       wr_modifiable_<%=pidx%>[$];
      bit       wr_nsbit_<%=pidx%>[$];
      bit[((2 ** <%=obj.wCacheLineOffset%>)-1):0] byte_en_<%=pidx%>[$];
      dii<%=pidx%>_env_pkg::axi4_write_data_pkt_t  wr_data_before_addr_<%=pidx%>[$];
      bit[63:0] rd_addr_<%=pidx%>[$];
      bit[63:0] rd_txnid_<%=pidx%>[$];
      int       rd_arsize_<%=pidx%>[$];
      int       rd_arlen_<%=pidx%>[$];
      int       rd_arburst_<%=pidx%>[$];
      bit       rd_modifiable_<%=pidx%>[$];
      bit       rd_nsbit_<%=pidx%>[$];
      //MEM_CONSISTENCY  -- end 
  		<% if (obj.DiiInfo[pidx].strRtlNamePrefix == "sys_dii") { %>
      extern function save_register_value(dii<%=pidx%>_smi_agent_pkg::smi_seq_item m_pkt, int idx, ref fsys_scb_txn fsys_txn_q[$]);
      <% } //if SYS DII %>

   <% } //foreach DII %>

   //MEM_CONSISTENCY
   mem_consistency_checker mem_checker;
   bit   m_en_mem_check;

endclass : fsys_scb_dii_predictor

function fsys_scb_dii_predictor::new(string name = "fsys_scb_dii_predictor", uvm_component parent = null);
   super.new(name,parent);
endfunction : new

function void fsys_scb_dii_predictor::build_phase(uvm_phase phase);
   super.build_phase(phase);
   //MEM_CONSISTENCY
   if($test$plusargs("EN_MEM_CHECK")) begin
      m_en_mem_check = 1;
   end else begin
      m_en_mem_check = 0;
   end
   if(m_en_mem_check) begin
      if(!(uvm_config_db #(mem_consistency_checker)::get(uvm_root::get(), "", "mem_checker", mem_checker)))begin
         `uvm_fatal("fsys_scb_dii_predictor", "Could not find mem_consistency_checker object in UVM DB");
      end
   end
   <% for(var pidx = 0; pidx < obj.nDIIs; pidx++) { %>
   <% if (obj.DiiInfo[pidx].nExclusiveEntries > 0) { %>
   exec_mon_<%=pidx%> = new();
   <% } //if Excl monitors %>
   <% } //foreach DII %>

endfunction : build_phase

<% for(var pidx = 0; pidx < obj.nDIIs; pidx++) { %>

//====================================================================================================
//
// Function : analyze_smi_pkt
//
//====================================================================================================
function void fsys_scb_dii_predictor::analyze_smi_pkt_<%=pidx%>(input dii<%=pidx%>_smi_agent_pkg::smi_seq_item m_pkt, ref fsys_scb_txn fsys_txn_q[$]);
   dii<%=pidx%>_smi_agent_pkg::smi_seq_item tmp_pkt = dii<%=pidx%>_smi_agent_pkg::smi_seq_item::type_id::create("tmp_pkt");
   tmp_pkt.copy(m_pkt);
   if (tmp_pkt.isCmdMsg()) begin
      smi_cmd_prediction_<%=pidx%>(tmp_pkt, fsys_txn_q);
   end // if cmd_req smi pkt
   else if (tmp_pkt.isDtwMsg()) begin
      smi_dtw_prediction_<%=pidx%>(tmp_pkt, fsys_txn_q);
   end // if DTW smi pkt
   else if (tmp_pkt.isStrMsg()) begin
      smi_str_prediction_<%=pidx%>(tmp_pkt, fsys_txn_q);
   end
   else if (tmp_pkt.isSysReqMsg()) begin
      if ($test$plusargs("EN_SYS_EVENT_CHECK")) begin
         smi_sysreq_prediction_<%=pidx%>(tmp_pkt, fsys_txn_q);
      end
   end // is SysReq
   else if (tmp_pkt.isSysRspMsg()) begin
      if ($test$plusargs("EN_SYS_EVENT_CHECK")) begin
         smi_sysrsp_prediction_<%=pidx%>(tmp_pkt, fsys_txn_q);
      end
   end // is SysRsp

endfunction : analyze_smi_pkt_<%=pidx%>

//====================================================================================================
//
// Function : analyze_smi_pkt
//
//====================================================================================================
function void fsys_scb_dii_predictor::smi_cmd_prediction_<%=pidx%>(input dii<%=pidx%>_smi_agent_pkg::smi_seq_item m_pkt, ref fsys_scb_txn fsys_txn_q[$]);
   `undef LABEL
   `define LABEL "smi_cmd_msg_dii<%=pidx%>"
   int find_q[$];
   bit match_found = 0;
   dii<%=pidx%>_env_pkg::exmon_status_t exmon_st;
   dii<%=pidx%>_env_pkg:: exec_mon_result_t m_exmon_result;
   dii<%=pidx%>_smi_agent_pkg::eMsgCMD cmd_type;
   $cast(cmd_type, m_pkt.smi_msg_type);
   if (m_pkt.smi_addr inside {[ncoreConfigInfo::NRS_REGION_BASE : (ncoreConfigInfo::NRS_REGION_BASE + ncoreConfigInfo::NRS_REGION_SIZE)]}) begin
      `uvm_info(`LABEL, $sformatf(
         "Register access packet, skipping scoreboarding. Addr=0x%0h", 
         m_pkt.smi_addr), UVM_NONE+50)
      find_q = fsys_txn_q.find_index with (
                  item.smi_msg_id == m_pkt.smi_msg_id
                  && item.smi_src_ncore_unit_id == m_pkt.smi_src_ncore_unit_id
                  && (item.smi_addr_val == 1
                  && item.smi_addr == m_pkt.smi_addr
                  && item.register_txn == 1));
      if (find_q.size() == 1) begin
         `uvm_info(`LABEL, $sformatf(
            "FSYS_UID:%0d : Register command packet seen (DII's FUnitId:'d<%=obj.DiiInfo[pidx].FUnitId%>)", 
            fsys_txn_q[find_q[0]].fsys_unique_txn_id), UVM_NONE+50)
         fsys_txn_q[find_q[0]].update_time_accessed();
      end else begin
         // TODO: Improve this error message for debug purposes, also account for more than 1 match
         `uvm_error(`LABEL, $sformatf(
            "FSYS_SCB: Register command packet didn't match any pending transactions"))
      end
      return;
   end // register address

   //non register accesses
   foreach (fsys_txn_q[txn_idx]) begin
      foreach(fsys_txn_q[txn_idx].cmd_req_val_q[cmd_idx]) begin
         if (fsys_txn_q[txn_idx].cmd_req_val_q[cmd_idx] == 1
            && fsys_txn_q[txn_idx].cmd_req_targ_q[cmd_idx] == <%=obj.DiiInfo[pidx].FUnitId%>
            && fsys_txn_q[txn_idx].cmd_req_targ_q[cmd_idx] == m_pkt.smi_targ_ncore_unit_id
            && fsys_txn_q[txn_idx].cmd_req_id_q[cmd_idx] == m_pkt.smi_msg_id
            && fsys_txn_q[txn_idx].cmd_req_addr_q[cmd_idx] == m_pkt.smi_addr
            && fsys_txn_q[txn_idx].smi_src_ncore_unit_id == m_pkt.smi_src_ncore_unit_id
            && fsys_txn_q[txn_idx].register_txn == 0
            && ((fsys_txn_q[txn_idx].mpf2_flowid_val == 1 && fsys_txn_q[txn_idx].mpf2_flowid == m_pkt.smi_mpf2_flowid) || fsys_txn_q[txn_idx].mpf2_flowid_val == 0)
            && fsys_txn_q[txn_idx].mpf2_flowid_val == m_pkt.smi_mpf2_flowid_valid
            && fsys_txn_q[txn_idx].register_txn == 0
         ) begin
            if(fsys_txn_q[txn_idx].multi_cacheline_access) begin
               `uvm_info(`LABEL, $sformatf(
                  "FSYS_UID:%0d SUB_ID:%0d : SMI command req packet seen (DII's FUnitId:'d<%=obj.DiiInfo[pidx].FUnitId%>) %0s", 
                  fsys_txn_q[txn_idx].fsys_unique_txn_id, fsys_txn_q[txn_idx].cmd_req_subid_q[cmd_idx],
                  m_pkt.convert2string()), UVM_NONE+50)
            end
            else begin
               `uvm_info(`LABEL, $sformatf(
                  "FSYS_UID:%0d : SMI command req packet seen (DII's FUnitId:'d<%=obj.DiiInfo[pidx].FUnitId%>) %0s", 
                  fsys_txn_q[txn_idx].fsys_unique_txn_id, m_pkt.convert2string()), UVM_NONE+50)
            end
            //This needs to be updated because sometimes the same AXI transaction goes to different DIIs if it's crossing addr boundaries.
            fsys_txn_q[txn_idx].smi_msg_id = m_pkt.smi_msg_id;
            fsys_txn_q[txn_idx].smi_targ_ncore_unit_id = m_pkt.smi_targ_ncore_unit_id;
            fsys_txn_q[txn_idx].dest_funit_id = m_pkt.smi_targ_ncore_unit_id;
            fsys_txn_q[txn_idx].update_time_accessed();
            match_found = 1;
            fsys_txn_q[txn_idx].cmd_req_val_q[cmd_idx] = 0;
            <% if (obj.DiiInfo[pidx].nExclusiveEntries > 0) { %>
            if (cmd_type inside {dii<%=pidx%>_smi_agent_pkg::eCmdRdNC, dii<%=pidx%>_smi_agent_pkg::eCmdWrNCPtl, dii<%=pidx%>_smi_agent_pkg::eCmdWrNCFull}) begin
               m_exmon_result = exec_mon_<%=pidx%>.predict_exmon(m_pkt) ; 
               exmon_st = m_exmon_result.exmon_status;
               if (exmon_st == dii<%=pidx%>_env_pkg::EX_FAIL) begin
                  `uvm_info(`LABEL, $sformatf("FSYS_UID:%0d : Exclusive fail predicted", fsys_txn_q[txn_idx].fsys_unique_txn_id), UVM_NONE+50)
                  fsys_txn_q[txn_idx].cmd_req_addr_q.delete(cmd_idx);
                  fsys_txn_q[txn_idx].cmd_req_subid_q.delete(cmd_idx);
                  fsys_txn_q[txn_idx].cmd_req_val_q.delete(cmd_idx);
                  fsys_txn_q[txn_idx].cmd_req_id_q.delete(cmd_idx);
                  fsys_txn_q[txn_idx].cmd_req_targ_q.delete(cmd_idx);
                  fsys_txn_q[txn_idx].cmd_req_axi_id_q.delete(cmd_idx);
               end else if (m_pkt.smi_es == 1 && cmd_type !== dii<%=pidx%>_smi_agent_pkg::eCmdRdNC) begin
                  `uvm_info(`LABEL, $sformatf("FSYS_UID:%0d : Exclusive pass predicted", fsys_txn_q[txn_idx].fsys_unique_txn_id), UVM_NONE+50)
               end
            end
            <% } //if Excl monitors %>
            break;
         end // match found 
      end // foreach cmd_idx
      if (match_found == 1) break;
   end //foreach txn_idx
   if (match_found == 0) begin
      `uvm_error(`LABEL, $sformatf(
         "FSYS_SCB: Command req packet didn't match any pending transactions. %0s", 
         m_pkt.convert2string()))
   end
endfunction : smi_cmd_prediction_<%=pidx%>

//====================================================================================================
//
// Function : smi_dtw_prediction
//
//====================================================================================================
function void fsys_scb_dii_predictor::smi_dtw_prediction_<%=pidx%>(input dii<%=pidx%>_smi_agent_pkg::smi_seq_item m_pkt, ref fsys_scb_txn fsys_txn_q[$]);
   `undef LABEL
   `define LABEL "smi_dtw_msg_dii<%=pidx%>"
   int find_q[$];
   bit match_found = 0;
   bit all_cmd_axi_done = 1;
   foreach(fsys_txn_q[idx]) begin
      if (fsys_txn_q[idx].rbid_val_q.size() !== 0) begin
         foreach(fsys_txn_q[idx].rbid_val_q[i]) begin
            //`uvm_info(`LABEL, $sformatf(
            //    "FSYS_UID:%0d : rbid_val='d%0d, rbid=0x%0h, rbid_unit_id=0x%0h", 
            //    fsys_txn_q[idx].fsys_unique_txn_id ,fsys_txn_q[idx].rbid_val_q[i] ,
            //    fsys_txn_q[idx].rbid_q[i] ,fsys_txn_q[idx].rbid_unit_id_q[i]), UVM_DEBUG)
            if (fsys_txn_q[idx].rbid_q[i] == m_pkt.smi_rbid
               && fsys_txn_q[idx].smi_src_ncore_unit_id == m_pkt.smi_src_ncore_unit_id
               && fsys_txn_q[idx].rbid_unit_id_q[i] == <%=obj.DiiInfo[pidx].FUnitId%>) begin
               if(fsys_txn_q[idx].multi_cacheline_access) begin
                  `uvm_info(`LABEL, $sformatf(
                     "FSYS_UID:%0d SUB_ID:%0d %0d: SMI DTW packet seen. Remaining DTWs='d%0d. (FUnitId:'d<%=obj.DiiInfo[pidx].FUnitId%>) %0s", 
                     fsys_txn_q[idx].fsys_unique_txn_id, fsys_txn_q[idx].cmd_req_subid_q[i], fsys_txn_q[idx].str_subid_q[i],
                     (fsys_txn_q[idx].exp_smi_data_pkts - 1), m_pkt.convert2string()), UVM_NONE+50)
               end
               else begin
                  `uvm_info(`LABEL, $sformatf(
                     "FSYS_UID:%0d : SMI DTW packet seen. Remaining DTWs='d%0d. (FUnitId:'d<%=obj.DiiInfo[pidx].FUnitId%>) %0s", 
                     fsys_txn_q[idx].fsys_unique_txn_id, (fsys_txn_q[idx].exp_smi_data_pkts - 1), m_pkt.convert2string()), UVM_NONE+50)
               end
               if (!fsys_txn_q[idx].multi_cacheline_access) begin
                  fsys_txn_q[idx].smi_msg_order_q.push_back(smi_msgs_t'(fsys_coverage_pkg::DTW_REQ));
               end
               fsys_txn_q[idx].exp_smi_data_pkts = fsys_txn_q[idx].exp_smi_data_pkts - 1;
               fsys_txn_q[idx].update_time_accessed();
               fsys_txn_q[idx].rbid_val_q.delete(i);
               fsys_txn_q[idx].rbid_q.delete(i);
               fsys_txn_q[idx].str_subid_q.delete(i); 
               fsys_txn_q[idx].rbid_unit_id_q.delete(i);
               <% if (obj.DiiInfo[pidx].strRtlNamePrefix == "sys_dii") { %>
                  save_register_value(m_pkt, idx, fsys_txn_q);
               <% } //if SYS DII %>
               
               foreach (fsys_txn_q[idx].cmd_req_addr_q[done_idx]) begin
                  if (fsys_txn_q[idx].cmd_req_axi_id_q[done_idx].done == 0) begin
                     all_cmd_axi_done = 0;
                  end
               end

               if (fsys_txn_q[idx].exp_smi_data_pkts == 0 && all_cmd_axi_done == 1) begin  
                  if (fsys_txn_q[idx].aiu_check_done == 1) begin
                     `uvm_info(`LABEL, $sformatf(
                        "FSYS_UID:%0d : Deleting transaction from fsys_txn_q. remaining txns: 'd%0d",
                        fsys_txn_q[idx].fsys_unique_txn_id, (fsys_txn_q.size()-1)), UVM_NONE+50)
                     `ifdef FSYS_SCB_COVER_ON
                        fsys_txn_path_cov.sample_txn(fsys_txn_q[idx].smi_msg_order_q, (fsys_txn_q[idx].ioaiu_core_id >= 0));
                     `endif // `ifdef FSYS_SCB_COVER_ON
                     fsys_txn_q[idx].print_path();
                     fsys_txn_q.delete(idx);
                  end else begin
                     //FIX_ME Check with Neha following uvm_info is required or not
                     `uvm_info(`LABEL, $sformatf(
                        "FSYS_UID:%0d : SMI DTW seen. (DII's FUnitId:'d<%=obj.DiiInfo[pidx].FUnitId%>) %0s", 
                        fsys_txn_q[idx].fsys_unique_txn_id, m_pkt.convert2string()), UVM_NONE+50)   
                     //`uvm_error(`LABEL, $sformatf(
                     //   "FSYS_UID:%0d : Failed to delete packet from fsys_txn_q. AIU check_done flag: 'd%0d", 
                     //   fsys_txn_q[idx].fsys_unique_txn_id, fsys_txn_q[idx].aiu_check_done))
                     if (fsys_txn_q[idx].combined_cmd == 0) begin
                        fsys_txn_q[idx].dii_check_done = 1;
                     end
                  end
               end
               match_found = 1;
               break;
            end // if RBID matches current packet
         end // foreach rbid
      end // if multiple RBIDs per txn
      if (match_found == 1) break;
   end // foreach pending txn
   if (match_found == 0) begin
      `uvm_error(`LABEL, $sformatf(
         "FSYS_SCB: DTW match any pending transactions(DII's FUnitId:'d<%=obj.DiiInfo[pidx].FUnitId%>). %0s", 
         m_pkt.convert2string()))
   end // if didn't match any pending txn
endfunction : smi_dtw_prediction_<%=pidx%>

//====================================================================================================
//
// Function : smi_str_prediction
//
//====================================================================================================
function void fsys_scb_dii_predictor::smi_str_prediction_<%=pidx%>(input dii<%=pidx%>_smi_agent_pkg::smi_seq_item m_pkt, ref fsys_scb_txn fsys_txn_q[$]);
   `undef LABEL
   `define LABEL "smi_str_msg_dii<%=pidx%>"
   bit match_found = 0;
   foreach(fsys_txn_q[idx]) begin
      if (fsys_txn_q[idx].str_msg_id_q.size() > 0) begin
         foreach(fsys_txn_q[idx].str_msg_id_q[i]) begin
            if ((fsys_txn_q[idx].dest_funit_id == <%=obj.DiiInfo[pidx].FUnitId%> || fsys_txn_q[idx].multi_cacheline_access == 1 || fsys_txn_q[idx].register_txn == 1)
               && fsys_txn_q[idx].str_msg_id_val_q[i] == 1
               && fsys_txn_q[idx].str_msg_id_q[i] == m_pkt.smi_rmsg_id
               && fsys_txn_q[idx].str_unit_id_q[i] == m_pkt.smi_targ_ncore_unit_id) 
            begin
               if(fsys_txn_q[idx].multi_cacheline_access) begin
                  `uvm_info(`LABEL, $sformatf(
                     "FSYS_UID:%0d SUB_ID:%0d : SMI STR seen. (DII's FUnitId:'d<%=obj.DiiInfo[pidx].FUnitId%>) %0s", 
                     fsys_txn_q[idx].fsys_unique_txn_id, fsys_txn_q[idx].str_subid_q[i], m_pkt.convert2string()), UVM_NONE+50)
               end else begin
                  `uvm_info(`LABEL, $sformatf(
                     "FSYS_UID:%0d : SMI STR seen. (DII's FUnitId:'d<%=obj.DiiInfo[pidx].FUnitId%>) %0s", 
                     fsys_txn_q[idx].fsys_unique_txn_id, m_pkt.convert2string()), UVM_NONE+50)
               end
               if (!fsys_txn_q[idx].multi_cacheline_access) begin
                  fsys_txn_q[idx].smi_msg_order_q.push_back(smi_msgs_t'(fsys_coverage_pkg::STR_REQ));
               end
               //Store these information for DTW matching
               // Used as a check before removing Read txns from Q
               if(fsys_txn_q[idx].is_read || fsys_txn_q[idx].is_dataless_txn) begin 
                  if ((fsys_txn_q[idx].combined_cmd == 0) 
                      || (fsys_txn_q[idx].combined_cmd == 1 && fsys_txn_q[idx].chi_cmd_num == 1 && fsys_txn_q[idx].cmd_req_axi_id_q[0].done == 1)) begin
                     fsys_txn_q[idx].dii_check_done = 1;
                  end
               end
               if (fsys_txn_q[idx].is_write == 1) begin
                  fsys_txn_q[idx].rbid_val_q.push_back(1);
                  fsys_txn_q[idx].rbid_q.push_back(m_pkt.smi_rbid);
                  fsys_txn_q[idx].str_subid_q.push_back(fsys_txn_q[idx].str_subid_q[i]);
                  fsys_txn_q[idx].rbid_unit_id_q.push_back(m_pkt.smi_src_ncore_unit_id);
               end
               fsys_txn_q[idx].str_msg_id_val_q[i] = 0;
               fsys_txn_q[idx].update_time_accessed();
               match_found = 1;
               break;
            end
         end // foreach str_msg_id_q
      end // if str_msg_id_q not empty
      if (match_found == 1) break;
   end //foreach fsys_txn
   if (match_found == 0) begin
      `uvm_error(`LABEL, $sformatf(
         "FSYS_SCB: STR packet didn't match any pending transactions. %0s", 
         m_pkt.convert2string()))
   end
endfunction : smi_str_prediction_<%=pidx%>

//====================================================================================================
//
// Function : smi_sysreq_prediction
//
//====================================================================================================
function void fsys_scb_dii_predictor::smi_sysreq_prediction_<%=pidx%>(input dii<%=pidx%>_smi_agent_pkg::smi_seq_item m_pkt, ref fsys_scb_txn fsys_txn_q[$]);
   `undef LABEL
   `define LABEL "analyze_sys_event_dii<%=pidx%>"
   fsys_scb_txn m_txn = fsys_scb_txn::type_id::create("m_txn");
   if (m_pkt.smi_targ_ncore_unit_id == <%=obj.DiiInfo[pidx].FUnitId%>) begin
      `uvm_error(`LABEL, $sformatf("FSYS_SCB: DII cannot be receiver of SYS_EVENT msg. PKT: %0s", m_pkt.convert2string()))
   end
   if (m_pkt.smi_sysreq_op !== dii<%=pidx%>_smi_agent_pkg::SMI_SYSREQ_EVENT) begin
      `uvm_error(`LABEL, $sformatf("FSYS_SCB: DII should only receive SMI_SYSREQ_EVENT, while it saw %0s. PKT: %0s", m_pkt.smi_sysreq_op, m_pkt.convert2string()))
   end
   if (m_pkt.smi_targ_ncore_unit_id !== <%=obj.DveInfo[0].FUnitId%>) begin
      `uvm_error(`LABEL, $sformatf("FSYS_SCB: Outgoing SYS_EVENT should always be going to DVE. PKT: %0s", m_pkt.convert2string()))
   end
   m_txn.fsys_unique_txn_id = fsys_scoreboard::get_next_unique_txn_id();
   `uvm_info(`LABEL, $sformatf(
      "FSYS_UID:%0d : Adding a SYS_EVENT to pending queue. DII's FUnitId:'d<%=obj.DiiInfo[pidx].FUnitId%> %0s", 
      m_txn.fsys_unique_txn_id, m_pkt.convert2string()), UVM_NONE+50)
   m_txn.is_sys_evnt = 1;
   m_txn.source_funit_id = m_pkt.smi_src_ncore_unit_id;
   m_txn.smi_msg_id = m_pkt.smi_msg_id;
   fsys_txn_q.push_back(m_txn);

endfunction : smi_sysreq_prediction_<%=pidx%>

//====================================================================================================
//
// Function : smi_sysrsp_prediction
//
//====================================================================================================
function void fsys_scb_dii_predictor::smi_sysrsp_prediction_<%=pidx%>(input dii<%=pidx%>_smi_agent_pkg::smi_seq_item m_pkt, ref fsys_scb_txn fsys_txn_q[$]);
   `undef LABEL
   `define LABEL "smi_sysrsp_dii<%=pidx%>"
   int find_q[$];
   bit matched=0;
   
   find_q = fsys_txn_q.find_index with (
      item.is_sys_evnt == 1
      && item.smi_msg_id == m_pkt.smi_rmsg_id
      && item.source_funit_id == m_pkt.smi_targ_ncore_unit_id
      );
   if (find_q.size() > 0) begin
      `uvm_info(`LABEL, $sformatf(
         "FSYS_UID:%0d : Received SYSRSP for a SYS_EVENT transaction. DII's FUnitId:'d<%=obj.DiiInfo[pidx].FUnitId%> %0s", 
         fsys_txn_q[find_q[0]].fsys_unique_txn_id, m_pkt.convert2string()), UVM_NONE+50)
      if (fsys_txn_q[find_q[0]].sys_evnt_rcvrs_q.size() == 0 && fsys_txn_q[find_q[0]].sys_rsp_sent == 1) begin
         `uvm_info(`LABEL, $sformatf(
            "FSYS_UID:%0d : Deleting transaction from fsys_txn_q. Remaining txns: 'd%0d",
            fsys_txn_q[find_q[0]].fsys_unique_txn_id, (fsys_txn_q.size()-1)), UVM_NONE+50)
         fsys_txn_q.delete(find_q[0]);
      end
   end else begin
      `uvm_error(`LABEL, $sformatf("FSYS_SCB: SYSRSP didn't match any pending SYSREQ. PKT: %0s", m_pkt.convert2string()))
   end
endfunction : smi_sysrsp_prediction_<%=pidx%>



function void fsys_scb_dii_predictor::analyze_write_addr_pkt_<%=pidx%>(input dii<%=pidx%>_env_pkg::axi4_write_addr_pkt_t m_pkt, ref fsys_scb_txn fsys_txn_q[$]);
   `undef LABEL
   `define LABEL "axi_write_addr_pkt_dii<%=pidx%>"
   bit match_found = 0;
   foreach(fsys_txn_q[idx]) begin
      foreach(fsys_txn_q[idx].cmd_req_addr_q[cmd_idx]) begin
         if((fsys_txn_q[idx].is_write || fsys_txn_q[idx].chi_cmd_num == 1)
            &&
            ( (fsys_txn_q[idx].register_txn && 
               fsys_txn_q[idx].cmd_req_addr_q[cmd_idx][<%=obj.DiiInfo[pidx].interfaces.apbInt.params.wAddr%>-1:0] == m_pkt.awaddr[<%=obj.DiiInfo[pidx].interfaces.apbInt.params.wAddr%>-1:0]
              )
             ||( !fsys_txn_q[idx].register_txn                 
                && fsys_txn_q[idx].dest_funit_id == <%=obj.DiiInfo[pidx].FUnitId%> 
                && fsys_txn_q[idx].cmd_req_addr_q[cmd_idx] >> 6  == m_pkt.awaddr >> 6
                && ((fsys_txn_q[idx].cmd_req_val_q[cmd_idx] == 0 && fsys_txn_q[idx].str_msg_id_q[cmd_idx] == -1) || fsys_txn_q[idx].chi_cmd_num == 1)
               )
            ))
         begin
            if(fsys_txn_q[idx].cmd_req_axi_id_q[cmd_idx].id == -1 && fsys_txn_q[idx].cmd_req_axi_id_q[cmd_idx].done == 0 ) begin
               if(fsys_txn_q[idx].multi_cacheline_access) begin
                  `uvm_info(`LABEL, $sformatf(
                     "FSYS_UID:%0d SUB_ID:%0d : Write AXI address seen : %0s",
                     fsys_txn_q[idx].fsys_unique_txn_id, fsys_txn_q[idx].cmd_req_subid_q[cmd_idx],
                     m_pkt.sprint_pkt()), UVM_NONE+50)
               end
               else begin
                  `uvm_info(`LABEL, $sformatf(
                     "FSYS_UID:%0d : Write AXI address seen : %0s",
                     fsys_txn_q[idx].fsys_unique_txn_id, m_pkt.sprint_pkt()), UVM_NONE+50)
               end
               fsys_txn_q[idx].cmd_req_axi_id_q[cmd_idx].id = m_pkt.awid;
               fsys_txn_q[idx].cmd_req_axi_id_q[cmd_idx].funit_id = <%=obj.DiiInfo[pidx].FUnitId%>;
               match_found = 1;
               break;
            end
         end
      end
      if (match_found == 1) break;
   end
   if(!match_found) begin
      `uvm_info(`LABEL, $sformatf("FSYS_SCB: Write AXI Address did not match any pending transactions : %0s", m_pkt.sprint_pkt()),UVM_NONE)
      //`uvm_error(`LABEL, $sformatf("FSYS_SCB: Write AXI Address did not match any pending transactions : %0s", m_pkt.sprint_pkt()))
   end
endfunction : analyze_write_addr_pkt_<%=pidx%>

function void fsys_scb_dii_predictor::analyze_write_resp_pkt_<%=pidx%>(input dii<%=pidx%>_env_pkg::axi4_write_resp_pkt_t m_pkt, ref fsys_scb_txn fsys_txn_q[$]);
  `undef LABEL
  `define LABEL "axi_write_resp_pkt_dii<%=pidx%>"
   bit match_found = 0;
   bit all_cmd_axi_done = 1;
   foreach(fsys_txn_q[idx]) begin
      foreach(fsys_txn_q[idx].cmd_req_axi_id_q[cmd_idx]) begin
         if( fsys_txn_q[idx].cmd_req_axi_id_q[cmd_idx].done == 0
            && (fsys_txn_q[idx].cmd_req_val_q[cmd_idx] == 0 || fsys_txn_q[idx].register_txn || fsys_txn_q[idx].chi_cmd_num == 1)
            && fsys_txn_q[idx].cmd_req_axi_id_q[cmd_idx].id == m_pkt.bid
            && fsys_txn_q[idx].cmd_req_axi_id_q[cmd_idx].funit_id == <%=obj.DiiInfo[pidx].FUnitId%>
            && (fsys_txn_q[idx].is_write || fsys_txn_q[idx].chi_cmd_num == 1)) begin
            if(fsys_txn_q[idx].multi_cacheline_access) begin
               `uvm_info(`LABEL,$sformatf("FSYS_UID:%0d SUB_ID:%0d : Write AXI response ID match : %0s",
                  fsys_txn_q[idx].fsys_unique_txn_id, fsys_txn_q[idx].cmd_req_subid_q[cmd_idx],
                  m_pkt.sprint_pkt()),UVM_NONE+50)
            end
            else begin
               `uvm_info(`LABEL,$sformatf("FSYS_UID:%0d : Write AXI response ID match : %0s",
                  fsys_txn_q[idx].fsys_unique_txn_id, m_pkt.sprint_pkt()),UVM_NONE+50)
            end
            if (fsys_txn_q[idx].register_txn == 1) begin
               fsys_txn_q[idx].cmd_req_addr_q.delete(cmd_idx);
               fsys_txn_q[idx].cmd_req_subid_q.delete(cmd_idx);
               fsys_txn_q[idx].cmd_req_val_q.delete(cmd_idx);
               fsys_txn_q[idx].cmd_req_id_q.delete(cmd_idx);
               fsys_txn_q[idx].cmd_req_targ_q.delete(cmd_idx);
               fsys_txn_q[idx].cmd_req_axi_id_q.delete(cmd_idx);
            end
            fsys_txn_q[idx].cmd_req_axi_id_q[cmd_idx].done = 1;
            foreach (fsys_txn_q[idx].cmd_req_addr_q[done_idx]) begin
               if (fsys_txn_q[idx].cmd_req_axi_id_q[done_idx].done == 0) begin
                  all_cmd_axi_done = 0;
               end
            end
            if(fsys_txn_q[idx].exp_smi_data_pkts == 0 && all_cmd_axi_done == 1) begin // && (fsys_txn_q[idx].cmd_req_addr_q.size() == 0 || fsys_txn_q[idx].combined_cmd == 1)) begin  
               if (fsys_txn_q[idx].aiu_check_done == 1) begin
                  `uvm_info(`LABEL, $sformatf(
                    "FSYS_UID:%0d : Deleting transaction from fsys_txn_q. remaining txns: 'd%0d",
                    fsys_txn_q[idx].fsys_unique_txn_id, (fsys_txn_q.size()-1)), UVM_NONE+50)
                  `ifdef FSYS_SCB_COVER_ON
                     fsys_txn_path_cov.sample_txn(fsys_txn_q[idx].smi_msg_order_q, (fsys_txn_q[idx].ioaiu_core_id >= 0));
                  `endif // `ifdef FSYS_SCB_COVER_ON
                  fsys_txn_q[idx].print_path();
                  fsys_txn_q.delete(idx);
               end 
               else begin
                  fsys_txn_q[idx].cmd_req_axi_id_q[cmd_idx].done = 1;
                  fsys_txn_q[idx].dii_check_done = 1;
               end
            end
            match_found = 1;
            break;
         end
      end
      if(match_found) break;
   end
   if(!match_found) begin
      `uvm_error(`LABEL, $sformatf("Write AXI Response BID did not match any pending transactions : %0s", m_pkt.sprint_pkt()))
   end
endfunction : analyze_write_resp_pkt_<%=pidx%>  

function void fsys_scb_dii_predictor::analyze_write_data_pkt_<%=pidx%>(input dii<%=pidx%>_env_pkg::axi4_write_data_pkt_t m_pkt, ref fsys_scb_txn fsys_txn_q[$]);
	// Need to add logic to this function
endfunction : analyze_write_data_pkt_<%=pidx%>

// AXI Native Interface Transaction
function void fsys_scb_dii_predictor::analyze_read_addr_pkt_<%=pidx%>(input dii<%=pidx%>_env_pkg::axi4_read_addr_pkt_t m_pkt, ref fsys_scb_txn fsys_txn_q[$]);
   `undef LABEL
   `define LABEL "axi_read_addr_pkt_dii<%=pidx%>"
   bit match_found = 0;
   foreach(fsys_txn_q[idx]) begin
      foreach(fsys_txn_q[idx].cmd_req_addr_q[cmd_idx]) begin
         if(fsys_txn_q[idx].is_read
            &&
           (fsys_txn_q[idx].register_txn
            || (!fsys_txn_q[idx].register_txn 
               && fsys_txn_q[idx].dest_funit_id == <%=obj.DiiInfo[pidx].FUnitId%> 
               && fsys_txn_q[idx].cmd_req_addr_q[cmd_idx] >> 6 == m_pkt.araddr >> 6)
           ))
         begin
            if(fsys_txn_q[idx].cmd_req_axi_id_q[cmd_idx].id == -1 && fsys_txn_q[idx].cmd_req_axi_id_q[cmd_idx].done == 0) begin
               `uvm_info(`LABEL, $sformatf(
               "FSYS_UID:%0d : Read AXI address seen : %0s", 
               fsys_txn_q[idx].fsys_unique_txn_id, m_pkt.sprint_pkt()), UVM_NONE+50)
               fsys_txn_q[idx].cmd_req_axi_id_q[cmd_idx].created = $time; 
               fsys_txn_q[idx].cmd_req_axi_id_q[cmd_idx].id = m_pkt.arid; 
               fsys_txn_q[idx].cmd_req_axi_id_q[cmd_idx].funit_id = <%=obj.DiiInfo[pidx].FUnitId%>;
               match_found = 1;
               break;
            end
         end
      end
      if (match_found == 1) break;
   end
   if(!match_found) begin
      `uvm_error(`LABEL, $sformatf(
      "FSYS_SCB: Read transaction on native interface did not match any pending transactions. %0s",
      m_pkt.sprint_pkt()))
   end
endfunction : analyze_read_addr_pkt_<%=pidx%>

function void fsys_scb_dii_predictor::analyze_read_data_pkt_<%=pidx%>(input dii<%=pidx%>_env_pkg::axi4_read_data_pkt_t m_pkt, ref fsys_scb_txn fsys_txn_q[$]);
   `undef LABEL
   `define LABEL "axi_read_data_pkt_dii<%=pidx%>"
   bit match_found = 0;
   int min_idx, min_cmd_idx;
   int min_time = $time;
   for(int idx=0; idx < fsys_txn_q.size(); idx++) begin
      for(int cmd_idx = 0; cmd_idx < fsys_txn_q[idx].cmd_req_axi_id_q.size(); cmd_idx++) begin 
         //Find the oldest ID generated by this particular DII
         if( fsys_txn_q[idx].cmd_req_axi_id_q[cmd_idx].done == 0 
            && fsys_txn_q[idx].cmd_req_axi_id_q[cmd_idx].id == m_pkt.rid
            && fsys_txn_q[idx].cmd_req_axi_id_q[cmd_idx].funit_id == <%=obj.DiiInfo[pidx].FUnitId%>
            && fsys_txn_q[idx].is_read) begin
            if(fsys_txn_q[idx].cmd_req_axi_id_q[cmd_idx].created < min_time) begin
               min_time = fsys_txn_q[idx].cmd_req_axi_id_q[cmd_idx].created;
               min_idx = idx;
               min_cmd_idx = cmd_idx;
               match_found = 1;
            end
         end
      end
   end
   if(match_found) begin
      `uvm_info(`LABEL,$sformatf("FSYS_UID:%0d : Read AXI Data ID match : %0s", 
          fsys_txn_q[min_idx].fsys_unique_txn_id, m_pkt.sprint_pkt()),UVM_NONE+50)
      fsys_txn_q[min_idx].dii_check_done = 1;
      fsys_txn_q[min_idx].cmd_req_axi_id_q[min_cmd_idx].done = 1;
   end
   else `uvm_error(`LABEL, $sformatf("FSYS_SCB: Read AXI RID did not match any pending transactions : %0s", m_pkt.sprint_pkt()))
endfunction : analyze_read_data_pkt_<%=pidx%>

//MEM_CONSISTENCY
//====================================================================================================
//
// Function : write_addr_chnl 
//
//====================================================================================================
function void fsys_scb_dii_predictor::write_addr_chnl_<%=pidx%>(dii<%=pidx%>_env_pkg::axi4_write_addr_pkt_t m_pkt);
   `undef LABEL
   `define LABEL "dii<%=pidx%>_axi_awaddr"
   dii<%=pidx%>_env_pkg::axi4_write_data_pkt_t  tmp_pkt;
   cache_data_t                                 txn_data;
   cache_byte_en_t                              byte_en;
   bit[64:0]                                    cacheline_addr;
   bit[64:0]                                    beat_start_addr;
   bit[63:0]                                    lower_boundary; 
   bit[63:0]                                    upper_boundary;
   // This is also the total size of txn
   bit[<%=obj.wCacheLineOffset%>-1:0]           cache_byte_offset = m_pkt.awaddr[<%=obj.wCacheLineOffset%>-1:0];
   bit[<%=obj.wCacheLineOffset%>-1:0]           beat_start_offset;
   int                                          bytes_per_beat = (2 ** m_pkt.awsize);
   int                                          total_bytes;
   bit[7:0]                                     cacheline_bytes[];
   bit                                          cacheline_be[];
   int                                          data_bus_bytes;
   int                                          tmp_offset;
   int                                          beat_start_byte;
   data_bus_bytes = <%=obj.DiiInfo[pidx].wData%>/8;
   cacheline_bytes = new[(2**<%=obj.wCacheLineOffset%>)];
   cacheline_be = new[(2**<%=obj.wCacheLineOffset%>)];

   `uvm_info(`LABEL, $psprintf("DII AXI WADDR PKT: %0s", m_pkt.sprint_pkt()), UVM_NONE+50);
   if (wr_data_before_addr_<%=pidx%>.size() > 0) begin
      `uvm_info(`LABEL, $psprintf("DII AXI WDATA: Data before address was seen, retrieving."), UVM_MEDIUM);
      tmp_pkt = wr_data_before_addr_<%=pidx%>.pop_front();
      `uvm_info(`LABEL, $psprintf("DII AXI WDATA PKT: %0s", tmp_pkt.sprint_pkt()), UVM_NONE+50);
      cacheline_addr = {(m_pkt.awaddr >> ncoreConfigInfo::WCACHE_OFFSET), <%=obj.wCacheLineOffset%>'b0};
      beat_start_addr = (m_pkt.awaddr/data_bus_bytes) * data_bus_bytes;
      beat_start_offset = beat_start_addr[<%=obj.wCacheLineOffset%>-1:0];
      tmp_offset = cache_byte_offset-beat_start_offset;
      total_bytes = bytes_per_beat * (m_pkt.awlen+1);
      if (m_pkt.awburst == 'h2) begin //WRAP burst 
         lower_boundary = (m_pkt.awaddr/total_bytes) * total_bytes;
      end else begin
         lower_boundary = m_pkt.awaddr; //beat_start_addr;
      end
      upper_boundary = lower_boundary + total_bytes;
      foreach (tmp_pkt.wdata[idx]) begin
         int beat_end_byte;
         int bytes_saved=0;
         if (idx == 0) begin
            beat_start_byte = (cache_byte_offset - beat_start_offset);
            if (cache_byte_offset > beat_start_offset) beat_start_offset = cache_byte_offset;
         end
         beat_end_byte = beat_start_byte + bytes_per_beat - 1;
         if (beat_end_byte > data_bus_bytes) beat_end_byte = data_bus_bytes-1;
         for (int i = beat_start_byte; i <= beat_end_byte; i++) begin
            cacheline_bytes[beat_start_offset] = tmp_pkt.wdata[idx][8*i +: 8];
            cacheline_be[beat_start_offset] = tmp_pkt.wstrb[idx][i];
            bytes_saved++;
            beat_start_offset++;
            if (bytes_saved == bytes_per_beat || i == (data_bus_bytes-1)) begin
               if (total_bytes < data_bus_bytes && m_pkt.awburst == 'h2 
                  && (cache_byte_offset !== lower_boundary[<%=obj.wCacheLineOffset%>-1:0])) begin
                  beat_start_byte = (cache_byte_offset) - (beat_start_addr[<%=obj.wCacheLineOffset%>-1:0]) - (bytes_saved); 
               end else if (i < (data_bus_bytes-1)) begin
                  beat_start_byte = i+1;
               end else begin
                  beat_start_byte = 0;
               end
               break;
            end
         end
         if (tmp_pkt.wdata.size() > 1 
            && (beat_start_offset == upper_boundary[<%=obj.wCacheLineOffset%>-1:0]
               || beat_start_offset >= (2**<%=obj.wCacheLineOffset%>)) ) begin
            beat_start_offset = lower_boundary[<%=obj.wCacheLineOffset%>-1:0];
         end
      end // foreach data beat
      for (int idx = 0; idx < (2**<%=obj.wCacheLineOffset%>); idx++) begin
         txn_data[8*idx +: 8] = cacheline_bytes[idx];
         byte_en[idx] = cacheline_be[idx];
      end
      //TODO: Which parameter to use for APBAddr width? DiiInfo.apbInt.wAddr is 12, which isn't the width of whole NRS region.
      if ((!(cacheline_addr inside {[ncoreConfigInfo::BOOT_REGION_BASE : (ncoreConfigInfo::BOOT_REGION_BASE + ncoreConfigInfo::BOOT_REGION_SIZE)]}))
         <% if (obj.DiiInfo[pidx].strRtlNamePrefix == "sys_dii") { %>
          && (!(cacheline_addr[63:32] == 'b0 && cacheline_addr[23:0] > ncoreConfigInfo::NRS_REGION_BASE[23:0] && cacheline_addr[23:0] < ncoreConfigInfo::NRS_REGION_BASE[23:0] + ncoreConfigInfo::NRS_REGION_SIZE[23:0]))
          <% } %>
      ) begin
         `uvm_info(`LABEL, $psprintf("DII AXI WADDR: Addr: 0x%0h(cacheline aligned:0x%0h, cacheline data=0x%0h, byte_en=0x%0h", m_pkt.awaddr, cacheline_addr, txn_data, byte_en), UVM_NONE+50);
         if(m_en_mem_check)
         mem_checker.write_on_slave_if(.addr(cacheline_addr), 
                                    .wdata(txn_data), 
                                    .byte_en(byte_en), 
                                    .txn_id(m_pkt.awid),
                                    .ns(m_pkt.awprot[1]),
                                    .is_coh(0),
                                    .funit_id(<%=obj.DiiInfo[pidx].FUnitId%>),
                                    .eviction(0),
                                    .cache_unit(0));
      end
   end else begin
      wr_addr_<%=pidx%>.push_back(m_pkt.awaddr);
      wr_txnid_<%=pidx%>.push_back(m_pkt.awid);
      wr_awsize_<%=pidx%>.push_back(m_pkt.awsize);
      wr_modifiable_<%=pidx%>.push_back(m_pkt.awcache[1]);
      wr_awburst_<%=pidx%>.push_back(m_pkt.awburst);
      wr_awlen_<%=pidx%>.push_back(m_pkt.awlen);
      wr_nsbit_<%=pidx%>.push_back(m_pkt.awprot[1]);
   end
endfunction : write_addr_chnl_<%=pidx%> 

//====================================================================================================
//
// Function :write_data_chnl 
//
//====================================================================================================
function void fsys_scb_dii_predictor::write_data_chnl_<%=pidx%>(dii<%=pidx%>_env_pkg::axi4_write_data_pkt_t m_pkt);
   `undef LABEL
   `define LABEL "dii<%=pidx%>_axi_wdata"
   dii<%=pidx%>_env_pkg::axi4_write_data_pkt_t  tmp_pkt = new();
   bit[63:0]                           tmp_addr;
   bit[63:0]                           lower_boundary; 
   bit[63:0]                           upper_boundary; 
   bit[63:0]                           tmp_txnid;
   int                                 tmp_size;
   int                                 tmp_burst;
   int                                 tmp_len;
   bit                                 tmp_modifiable;
   cache_data_t                        txn_data;
   cache_byte_en_t                     byte_en;
   bit[64:0]                           cacheline_addr;
   bit[64:0]                           beat_start_addr;
   // This is also the total size of txn
   bit[<%=obj.wCacheLineOffset%>-1:0]  cache_byte_offset;
   bit[<%=obj.wCacheLineOffset%>-1:0]  beat_start_offset;
   int                                 bytes_per_beat;
   int                                 total_bytes;
   bit[7:0]                            cacheline_bytes[];
   bit                                 cacheline_be[];
   bit                                 tmp_ns;
   int                                 data_bus_bytes;
   int                                 tmp_offset;
   int                                 beat_start_byte;
   tmp_pkt.copy(m_pkt);
   data_bus_bytes = <%=obj.DiiInfo[pidx].wData%>/8;
   cacheline_bytes = new[(2**<%=obj.wCacheLineOffset%>)];
   cacheline_be = new[(2**<%=obj.wCacheLineOffset%>)];
   `uvm_info(`LABEL, $psprintf("DII AXI WDATA PKT: %0s", m_pkt.sprint_pkt()), UVM_NONE+50);
   if (wr_addr_<%=pidx%>.size() > 0) begin
      tmp_addr = wr_addr_<%=pidx%>.pop_front();
      cacheline_addr = {(tmp_addr >> ncoreConfigInfo::WCACHE_OFFSET), <%=obj.wCacheLineOffset%>'b0};
      beat_start_addr = (tmp_addr/data_bus_bytes) * data_bus_bytes;
      tmp_txnid = wr_txnid_<%=pidx%>.pop_front();
      tmp_size = wr_awsize_<%=pidx%>.pop_front();
      tmp_modifiable = wr_modifiable_<%=pidx%>.pop_front();
      tmp_burst = wr_awburst_<%=pidx%>.pop_front();
      tmp_len = wr_awlen_<%=pidx%>.pop_front();
      tmp_ns = wr_nsbit_<%=pidx%>.pop_front();
      cache_byte_offset = tmp_addr[<%=obj.wCacheLineOffset%>-1:0];
      beat_start_offset = beat_start_addr[<%=obj.wCacheLineOffset%>-1:0];
      bytes_per_beat = (2 ** tmp_size);
      total_bytes = bytes_per_beat * (tmp_len+1);
      if (tmp_burst == 'h2) begin //WRAP burst 
         lower_boundary = (tmp_addr/total_bytes) * total_bytes;
      end else begin
         lower_boundary = tmp_addr; //beat_start_addr;
      end
      upper_boundary = lower_boundary + total_bytes;
      tmp_offset = cache_byte_offset-beat_start_offset;
      `uvm_info(`LABEL, $psprintf("DII AXI WDATA: Addr: 0x%0h, byte_ofset=0x%0h, bytes_per_beat=0x%0h, total=0x%0h, lower_Addr=0x%0h, upper_addr=0x%0h, upper_byte_offset=0x%0h, lower_byte_offset=0x%0h", tmp_addr, cache_byte_offset, bytes_per_beat, total_bytes, lower_boundary, upper_boundary, upper_boundary[<%=obj.wCacheLineOffset%>-1:0], lower_boundary[<%=obj.wCacheLineOffset%>-1:0]), UVM_MEDIUM);
      foreach (m_pkt.wdata[idx]) begin
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
            if (beat_end_byte[tmp_size] !== beat_start_byte[tmp_size]) begin
               do begin
                  beat_end_byte = beat_end_byte - 1;
               end while (beat_end_byte[tmp_size] !== beat_start_byte[tmp_size]);
            end
         end else begin
            beat_end_byte = beat_start_byte + bytes_per_beat - 1;
         end
         if (beat_end_byte > data_bus_bytes) beat_end_byte = data_bus_bytes-1;
         //$display("MEM_DEBUG - 0: beat_start_byte=0x%0h, beat_end_byte=0x%0h, beat_start_offset=0x%0h", beat_start_byte, beat_end_byte, beat_start_offset);
         for (int i = beat_start_byte; i <= beat_end_byte; i++) begin
            cacheline_bytes[beat_start_offset] = m_pkt.wdata[idx][8*i +: 8];
            cacheline_be[beat_start_offset] = m_pkt.wstrb[idx][i];
            bytes_saved++;
            beat_start_offset++;
            if ((bytes_saved == bytes_per_beat) 
               || (i == (data_bus_bytes-1))
               || (bytes_saved == ((beat_end_byte-beat_start_byte) + 1) && idx == 0)
            ) begin
               if (total_bytes < data_bus_bytes && tmp_burst == 'h2 
                  && (cache_byte_offset !== lower_boundary[<%=obj.wCacheLineOffset%>-1:0])) begin
                  beat_start_byte = (cache_byte_offset) - (beat_start_addr[<%=obj.wCacheLineOffset%>-1:0]) - (bytes_saved); 
                  //$display("MEM_DEBUG - 1: beat_start_byte=0x%0h, beat_end_byte=0x%0h, beat_start_offset=0x%0h", beat_start_byte, beat_end_byte, beat_start_offset);
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
         if (m_pkt.wdata.size() > 1 
            && (beat_start_offset == upper_boundary[<%=obj.wCacheLineOffset%>-1:0]
               || beat_start_offset >= (2**<%=obj.wCacheLineOffset%>)) ) begin
            beat_start_offset = lower_boundary[<%=obj.wCacheLineOffset%>-1:0];
         end
      end // foreach data beat
      for (int idx = 0; idx < (2**<%=obj.wCacheLineOffset%>); idx++) begin
         txn_data[8*idx +: 8] = cacheline_bytes[idx];
         byte_en[idx] = cacheline_be[idx];
      end
      if ((!(cacheline_addr inside {[ncoreConfigInfo::BOOT_REGION_BASE : (ncoreConfigInfo::BOOT_REGION_BASE + ncoreConfigInfo::BOOT_REGION_SIZE)]}))
         <% if (obj.DiiInfo[pidx].strRtlNamePrefix == "sys_dii") { %>
          && (!(cacheline_addr[63:32] == 'b0 && cacheline_addr[23:0] > ncoreConfigInfo::NRS_REGION_BASE[23:0] && cacheline_addr[23:0] < ncoreConfigInfo::NRS_REGION_BASE[23:0] + ncoreConfigInfo::NRS_REGION_SIZE[23:0]))
          <% } %>
         ) begin
         `uvm_info(`LABEL, $psprintf("DII AXI WDATA: Addr: 0x%0h(cacheline aligned:0x%0h), cacheline data=0x%0h, byte_en=0x%0h", tmp_addr, cacheline_addr, txn_data, byte_en), UVM_NONE+50);
         if(m_en_mem_check)
         mem_checker.write_on_slave_if(.addr(cacheline_addr), 
                                    .wdata(txn_data), 
                                    .byte_en(byte_en), 
                                    .txn_id(tmp_txnid),
                                    .ns(tmp_ns),
                                    .is_coh(0),
                                    .funit_id(<%=obj.DiiInfo[pidx].FUnitId%>),
                                    .eviction(0),
                                    .cache_unit(0));
      end
   end else begin
      wr_data_before_addr_<%=pidx%>.push_back(tmp_pkt);
      `uvm_info(`LABEL, $psprintf("DII AXI WDATA: Data before address, saving for later comparison. Total data: %0d", wr_data_before_addr_<%=pidx%>.size()), UVM_MEDIUM);
   end
endfunction : write_data_chnl_<%=pidx%> 

//====================================================================================================
//
// Function : read_addr_chnl
//
//====================================================================================================
function void fsys_scb_dii_predictor::read_addr_chnl_<%=pidx%>(dii<%=pidx%>_env_pkg::axi4_read_addr_pkt_t m_pkt);
   `undef LABEL
   `define LABEL "dii<%=pidx%>_axi_araddr"
   `uvm_info(`LABEL, $psprintf("DII AXI RADDR PKT: %0s", m_pkt.sprint_pkt()), UVM_NONE+50);
   rd_addr_<%=pidx%>.push_back(m_pkt.araddr);
   rd_txnid_<%=pidx%>.push_back(m_pkt.arid);
   rd_arsize_<%=pidx%>.push_back(m_pkt.arsize);
   rd_modifiable_<%=pidx%>.push_back(m_pkt.arcache[1]);
   rd_arburst_<%=pidx%>.push_back(m_pkt.arburst);
   rd_arlen_<%=pidx%>.push_back(m_pkt.arlen);
   rd_nsbit_<%=pidx%>.push_back(m_pkt.arprot[1]);
endfunction : read_addr_chnl_<%=pidx%> 

//====================================================================================================
//
// Function : read_data_chnl
//
//====================================================================================================
function void fsys_scb_dii_predictor::read_data_chnl_<%=pidx%>(dii<%=pidx%>_env_pkg::axi4_read_data_pkt_t m_pkt);
   `undef LABEL
   `define LABEL "dii<%=pidx%>_axi_rdata"
   bit[63:0]                           tmp_addr;
   bit[63:0]                           tmp_txnid;
   bit[63:0]                           lower_boundary; 
   bit[63:0]                           upper_boundary; 
   int                                 tmp_size;
   bit                                 tmp_modifiable;
   int                                 tmp_burst;
   int                                 tmp_len;
   cache_data_t                        txn_data;
   cache_byte_en_t                     byte_en;
   bit[64:0]                           cacheline_addr;
   bit[64:0]                           beat_start_addr;
   // This is also the total size of txn
   bit[<%=obj.wCacheLineOffset%>-1:0]  cache_byte_offset;
   bit[<%=obj.wCacheLineOffset%>-1:0]  beat_start_offset;
   int                                 bytes_per_beat;
   int                                 total_bytes;
   bit[7:0]                            cacheline_bytes[];
   bit                                 cacheline_be[];
   int                                 find_q[$];
   bit                                 tmp_ns;
   int                                 data_bus_bytes;
   int                                 tmp_offset;
   int                                 beat_start_byte;
   data_bus_bytes = <%=obj.DiiInfo[pidx].wData%>/8;
   cacheline_bytes = new[(2**<%=obj.wCacheLineOffset%>)];
   cacheline_be = new[(2**<%=obj.wCacheLineOffset%>)];
   `uvm_info(`LABEL, $psprintf("DII AXI RDATA PKT: %0s", m_pkt.sprint_pkt()), UVM_NONE+50);
   find_q = rd_txnid_<%=pidx%>.find_index with (
                  item == m_pkt.rid);

   if (find_q.size() > 0) begin
      tmp_addr = rd_addr_<%=pidx%>[find_q[0]];
      tmp_txnid = rd_txnid_<%=pidx%>[find_q[0]];
      tmp_size = rd_arsize_<%=pidx%>[find_q[0]];
      tmp_modifiable = rd_modifiable_<%=pidx%>[find_q[0]];
      tmp_burst = rd_arburst_<%=pidx%>[find_q[0]];
      tmp_len = rd_arlen_<%=pidx%>[find_q[0]];
      tmp_ns = rd_nsbit_<%=pidx%>[find_q[0]];
      rd_addr_<%=pidx%>.delete(find_q[0]);
      rd_txnid_<%=pidx%>.delete(find_q[0]);
      rd_arsize_<%=pidx%>.delete(find_q[0]);
      rd_modifiable_<%=pidx%>.delete(find_q[0]);
      rd_arburst_<%=pidx%>.delete(find_q[0]);
      rd_arlen_<%=pidx%>.delete(find_q[0]);
      rd_nsbit_<%=pidx%>.delete(find_q[0]);
      cacheline_addr = {(tmp_addr >> ncoreConfigInfo::WCACHE_OFFSET), <%=obj.wCacheLineOffset%>'b0};
      beat_start_addr = (tmp_addr/data_bus_bytes) * data_bus_bytes;
      cache_byte_offset = tmp_addr[<%=obj.wCacheLineOffset%>-1:0];
      beat_start_offset = beat_start_addr[<%=obj.wCacheLineOffset%>-1:0];
      bytes_per_beat = (2 ** tmp_size);
      total_bytes = bytes_per_beat * (tmp_len+1);
      if (tmp_burst == 'h2) begin //WRAP burst 
         lower_boundary = (tmp_addr/total_bytes) * total_bytes;
      end else begin
         lower_boundary = tmp_addr; //beat_start_addr;
      end
      upper_boundary = lower_boundary + total_bytes;
      tmp_offset = cache_byte_offset-beat_start_offset;
      `uvm_info(`LABEL, $psprintf("DII AXI RDATA: Addr: 0x%0h, byte_ofset=0x%0h, bytes_per_beat=0x%0h, total=0x%0h, lower_Addr=0x%0h, upper_addr=0x%0h, upper_byte_offset=0x%0h, lower_byte_offset=0x%0h, beat_start_offset=0x%0h, cache_byte_offset=0x%0h, data_bus_bytes=0x%0h", tmp_addr, cache_byte_offset, bytes_per_beat, total_bytes, lower_boundary, upper_boundary, upper_boundary[<%=obj.wCacheLineOffset%>-1:0], lower_boundary[<%=obj.wCacheLineOffset%>-1:0], beat_start_offset, cache_byte_offset, data_bus_bytes), UVM_MEDIUM);
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
            if (beat_end_byte[tmp_size] !== beat_start_byte[tmp_size]) begin
               do begin
                  beat_end_byte = beat_end_byte - 1;
               end while (beat_end_byte[tmp_size] !== beat_start_byte[tmp_size]);
            end
         end else begin
            beat_end_byte = beat_start_byte + bytes_per_beat - 1;
         end
         if (beat_end_byte > data_bus_bytes) beat_end_byte = data_bus_bytes-1;
         //$display("MEM_DEBUG: beat_start_byte=0x%0h, beat_end_byte=0x%0h, beat_start_offset=0x%0h", beat_start_byte, beat_end_byte, beat_start_offset);
         for (int i = beat_start_byte; i <= beat_end_byte; i++) begin
            cacheline_bytes[beat_start_offset] = m_pkt.rdata[idx][8*i +: 8];
            cacheline_be[beat_start_offset] = 1'b1;
            bytes_saved++;
            beat_start_offset++;
            //$display("MEM_DEBUG: here-0 bytes_saved = 0x%0h idx = 0x%0h, (bytes_per_beat-cache_byte_offset)=0x%0h", bytes_saved, idx, (bytes_per_beat-cache_byte_offset));
            if ((bytes_saved == bytes_per_beat) 
               || (i == (data_bus_bytes-1))
               || (bytes_saved == ((beat_end_byte-beat_start_byte) + 1) && idx == 0)
            ) begin
               if (total_bytes < data_bus_bytes && tmp_burst == 'h2 
                  && (cache_byte_offset !== lower_boundary[<%=obj.wCacheLineOffset%>-1:0])) begin
                  beat_start_byte = (cache_byte_offset) - (beat_start_addr[<%=obj.wCacheLineOffset%>-1:0]) - (bytes_saved); 
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
               || beat_start_offset >= (2**<%=obj.wCacheLineOffset%>)) ) begin
            beat_start_offset = lower_boundary[<%=obj.wCacheLineOffset%>-1:0];
         end
      end // foreach data beat
      for (int idx = 0; idx < (2**<%=obj.wCacheLineOffset%>); idx++) begin
         txn_data[8*idx +: 8] = cacheline_bytes[idx];
         byte_en[idx] = cacheline_be[idx];
      end
      if ((!(cacheline_addr inside {[ncoreConfigInfo::BOOT_REGION_BASE : (ncoreConfigInfo::BOOT_REGION_BASE + ncoreConfigInfo::BOOT_REGION_SIZE)]}))
         <% if (obj.DiiInfo[pidx].strRtlNamePrefix == "sys_dii") { %>
          && (!(cacheline_addr[63:32] == 'b0 && cacheline_addr[23:0] > ncoreConfigInfo::NRS_REGION_BASE[23:0] && cacheline_addr[23:0] < ncoreConfigInfo::NRS_REGION_BASE[23:0] + ncoreConfigInfo::NRS_REGION_SIZE[23:0]))
          <% } %>
      ) begin
         `uvm_info(`LABEL, $psprintf("DII AXI RDATA: Addr: 0x%0h(cacheline aligned:0x%0h, cacheline data=0x%0h, byte_en=0x%0h", tmp_addr, cacheline_addr, txn_data, byte_en), UVM_NONE+50);
         if(m_en_mem_check)
         mem_checker.read_on_slave_if(.addr(cacheline_addr), 
                                   .rdata(txn_data), 
                                   .byte_en(byte_en), 
                                   .txn_id(tmp_txnid),
                                   .ns(tmp_ns),
                                   .is_coh(0),
                                   .funit_id(<%=obj.DiiInfo[pidx].FUnitId%>));
      end
   end else begin
      `uvm_error(`LABEL, $psprintf("Read data found no match: %0s", m_pkt.sprint_pkt()))
   end
endfunction : read_data_chnl_<%=pidx%>

<% } //foreach DII %>
<% for(var pidx = 0; pidx < obj.nDIIs; pidx++) { %>
<% if (obj.DiiInfo[pidx].strRtlNamePrefix == "sys_dii") { %>
////////////////////////////////////////////////////////////////////////////////
// Function: save_register_value
// Description: Stores value of TransOrderMode value from XAIUTCR regsiter 
////////////////////////////////////////////////////////////////////////////////
function fsys_scb_dii_predictor::save_register_value(dii<%=pidx%>_smi_agent_pkg::smi_seq_item m_pkt, int idx, ref fsys_scb_txn fsys_txn_q[$]);
   bit [31:0] addr_tcr;
   <% for(var pidx = 0; pidx < _child_blkid.length; pidx++) { %>
   <%  if(_child_blk[pidx].match('ioaiu')) { %>
   <%for(var i = 0; i < obj.AiuInfo[pidx].nNativeInterfacePorts; i++){%>
   addr_tcr = ncoreConfigInfo::NRS_REGION_BASE + (<%=pidx%> * 'h1000) + (<%=i%> * 'h1000) + 'h40;
   //`uvm_info("FSYS_SCB", $psprintf("addr_tcr=%0h, smi_Addr=%0h, ordermoderd=0x%0h, ordermodewr=0x%0h. DTW:%0s", addr_tcr, fsys_txn_q[idx].smi_addr, m_pkt.smi_dp_data[0][17:16], m_pkt.smi_dp_data[0][19:18], m_pkt.convert2string()), UVM_NONE+50);
   if (fsys_txn_q[idx].smi_addr[31:0] == addr_tcr) begin
      `uvm_info("FSYS_SCB", $psprintf("MATCHED: <%=_child_blkid[pidx]%>_core<%=i%> ordermoderd=0x%0h, ordermodewr=0x%0h.", m_pkt.smi_dp_data[0][17:16], m_pkt.smi_dp_data[0][19:18]), UVM_NONE+50);
      fsys_scoreboard::pcie_ordermode_rd_en_<%=_child_blkid[pidx]%>_core<%=i%> = (m_pkt.smi_dp_data[0][17:16] == 'b10) ? 1 : 0;
      fsys_scoreboard::pcie_ordermode_wr_en_<%=_child_blkid[pidx]%>_core<%=i%> = (m_pkt.smi_dp_data[0][19:18] == 'b10) ? 1 : 0;
   end
   <% } // for each core %>
   <% } // if ioaiu%>
   <% } // foreach aius%>
endfunction : save_register_value
<% } //if SYS DII %>
<% } //foreach DII %>
// End of file
