
////////////////////////////////////////////////////////////////////////////////
//
// Author       : Neha F
// Purpose      : DVE predictor class
// Description  : This is one of the components of fsys_scoreboard. This component
//                contains predicting logic from DVE block. 
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


class fsys_scb_dve_predictor extends uvm_component;

   `uvm_component_utils(fsys_scb_dve_predictor)

   `ifdef FSYS_SCB_COVER_ON 
   fsys_txn_path_coverage fsys_txn_path_cov;
   `endif // `ifdef FSYS_SCB_COVER_ON              

   extern function new(string name = "fsys_scb_dve_predictor", uvm_component parent = null);
   extern function void build_phase(uvm_phase phase);

   <% for(var pidx = 0; pidx < obj.nDVEs; pidx++) { %>
      extern function void analyze_smi_pkt_<%=pidx%>(input dve<%=pidx%>_smi_agent_pkg::smi_seq_item m_pkt, ref fsys_scb_txn fsys_txn_q[$]);
      extern function void smi_cmd_prediction_<%=pidx%>(input dve<%=pidx%>_smi_agent_pkg::smi_seq_item m_pkt, ref fsys_scb_txn fsys_txn_q[$]); 
      extern function void smi_dtw_prediction_<%=pidx%>(input dve<%=pidx%>_smi_agent_pkg::smi_seq_item m_pkt, ref fsys_scb_txn fsys_txn_q[$]);
      extern function void smi_str_prediction_<%=pidx%>(input dve<%=pidx%>_smi_agent_pkg::smi_seq_item m_pkt, ref fsys_scb_txn fsys_txn_q[$]);
      extern function void smi_snpreq_prediction_<%=pidx%>(input dve<%=pidx%>_smi_agent_pkg::smi_seq_item m_pkt, ref fsys_scb_txn fsys_txn_q[$]);
      extern function void smi_snprsp_prediction_<%=pidx%>(input dve<%=pidx%>_smi_agent_pkg::smi_seq_item m_pkt, ref fsys_scb_txn fsys_txn_q[$]);
      extern function void smi_sysreq_prediction_<%=pidx%>(input dve<%=pidx%>_smi_agent_pkg::smi_seq_item m_pkt, ref fsys_scb_txn fsys_txn_q[$]);
      extern function void analyze_sys_event_<%=pidx%>(input dve<%=pidx%>_smi_agent_pkg::smi_seq_item m_pkt, ref fsys_scb_txn fsys_txn_q[$]);
      extern function void smi_sysrsp_prediction_<%=pidx%>(input dve<%=pidx%>_smi_agent_pkg::smi_seq_item m_pkt, ref fsys_scb_txn fsys_txn_q[$]);
      extern function void analyze_sys_event_rsp_<%=pidx%>(input dve<%=pidx%>_smi_agent_pkg::smi_seq_item m_pkt, ref fsys_scb_txn fsys_txn_q[$]);
      //SYSREQ related lists 
      dve<%=pidx%>_smi_agent_pkg::smi_seq_item pending_attach_sys_req_<%=pidx%>[$];
      //Queue of funit IDs attached AIUs
      int attached_funit_ids_<%=pidx%>[$];
      int cmdreq_order_uid_<%=pidx%>[$];
      int sysevent_order_uid_<%=pidx%>[$];
   <% } //foreach DVE %>
   extern function void check_phase(uvm_phase phase);
endclass : fsys_scb_dve_predictor

function fsys_scb_dve_predictor::new(string name = "fsys_scb_dve_predictor", uvm_component parent = null);
   super.new(name,parent);
endfunction : new

function void fsys_scb_dve_predictor::build_phase(uvm_phase phase);
   super.build_phase(phase);
endfunction : build_phase

<% for(var pidx = 0; pidx < obj.nDVEs; pidx++) { %>

//====================================================================================================
//
// Function : analyze_smi_pkt
//
//====================================================================================================
function void fsys_scb_dve_predictor::analyze_smi_pkt_<%=pidx%>(input dve<%=pidx%>_smi_agent_pkg::smi_seq_item m_pkt, ref fsys_scb_txn fsys_txn_q[$]);
   dve<%=pidx%>_smi_agent_pkg::smi_seq_item tmp_pkt = dve<%=pidx%>_smi_agent_pkg::smi_seq_item::type_id::create("tmp_pkt");
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
   else if (tmp_pkt.isSnpMsg()) begin
      smi_snpreq_prediction_<%=pidx%>(tmp_pkt, fsys_txn_q);
   end // is SNPReq
   else if (tmp_pkt.isSnpRspMsg()) begin
      smi_snprsp_prediction_<%=pidx%>(tmp_pkt, fsys_txn_q);
   end // is SNPRsp
   else if (tmp_pkt.isSysReqMsg()) begin
      smi_sysreq_prediction_<%=pidx%>(tmp_pkt, fsys_txn_q);
   end // is SysReq
   else if (tmp_pkt.isSysRspMsg()) begin
      smi_sysrsp_prediction_<%=pidx%>(tmp_pkt, fsys_txn_q);
   end // is SysRsp

endfunction : analyze_smi_pkt_<%=pidx%>

//====================================================================================================
//
// Function : analyze_smi_pkt
//
//====================================================================================================
function void fsys_scb_dve_predictor::smi_cmd_prediction_<%=pidx%>(input dve<%=pidx%>_smi_agent_pkg::smi_seq_item m_pkt, ref fsys_scb_txn fsys_txn_q[$]);
   `undef LABEL
   `define LABEL "smi_cmd_msg_dve<%=pidx%>"
   int find_q[$];
   bit match_found = 0;

   //non register accesses
   foreach (fsys_txn_q[txn_idx]) begin
      foreach(fsys_txn_q[txn_idx].cmd_req_val_q[cmd_idx]) begin
         if (fsys_txn_q[txn_idx].cmd_req_val_q[cmd_idx] == 1
            && fsys_txn_q[txn_idx].cmd_req_targ_q[cmd_idx] == <%=obj.DveInfo[pidx].FUnitId%>
            && fsys_txn_q[txn_idx].cmd_req_targ_q[cmd_idx] == m_pkt.smi_targ_ncore_unit_id
            && fsys_txn_q[txn_idx].cmd_req_id_q[cmd_idx] == m_pkt.smi_msg_id
            && fsys_txn_q[txn_idx].cmd_req_addr_q[cmd_idx] == m_pkt.smi_addr
            && fsys_txn_q[txn_idx].smi_src_ncore_unit_id == m_pkt.smi_src_ncore_unit_id
            && fsys_txn_q[txn_idx].is_dvm == 1
         ) begin
            `uvm_info(`LABEL, $sformatf(
               "FSYS_UID:%0d : SMI command req packet seen (DVE's FUnitId:'d<%=obj.DveInfo[pidx].FUnitId%>) %0s", 
               fsys_txn_q[txn_idx].fsys_unique_txn_id, m_pkt.convert2string()), UVM_NONE+50)
            fsys_txn_q[txn_idx].smi_msg_id = m_pkt.smi_msg_id;
            fsys_txn_q[txn_idx].smi_targ_ncore_unit_id = m_pkt.smi_targ_ncore_unit_id;
            fsys_txn_q[txn_idx].dest_funit_id = m_pkt.smi_targ_ncore_unit_id;
            fsys_txn_q[txn_idx].update_time_accessed();
            fsys_txn_q[txn_idx].cmd_msg_id_q.push_back(m_pkt.smi_msg_id);
            fsys_txn_q[txn_idx].cmd_addr_q.push_back(m_pkt.smi_addr);
            // These queues will have 1 entry per each CMDReq for this fsys_txn.
            fsys_txn_q[txn_idx].snpreq_cnt_q.push_back(-1);
            fsys_txn_q[txn_idx].snprsp_cnt_q.push_back(0);
            fsys_txn_q[txn_idx].snpreq_msg_id_q.push_back(-1);
            fsys_txn_q[txn_idx].snp_data_to_aiu_q.push_back(0);
            fsys_txn_q[txn_idx].internal_rbid_release_q.push_back(0);
            fsys_txn_q[txn_idx].snp_data_to_dmi_q.push_back(0);
            match_found = 1;
            fsys_txn_q[txn_idx].cmd_req_val_q.delete(cmd_idx);
            fsys_txn_q[txn_idx].cmd_req_id_q.delete(cmd_idx);
            fsys_txn_q[txn_idx].cmd_req_targ_q.delete(cmd_idx);
            fsys_txn_q[txn_idx].cmd_req_addr_q.delete(cmd_idx);
            cmdreq_order_uid_<%=pidx%>.push_back(fsys_txn_q[txn_idx].fsys_unique_txn_id);
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
function void fsys_scb_dve_predictor::smi_dtw_prediction_<%=pidx%>(input dve<%=pidx%>_smi_agent_pkg::smi_seq_item m_pkt, ref fsys_scb_txn fsys_txn_q[$]);
   `undef LABEL
   `define LABEL "smi_dtw_msg_dve<%=pidx%>"
   int find_q[$];
   bit match_found = 0;
   foreach(fsys_txn_q[idx]) begin
      if (fsys_txn_q[idx].rbid_val_q.size() !== 0) begin
         foreach(fsys_txn_q[idx].rbid_val_q[i]) begin
            //`uvm_info(`LABEL, $sformatf(
            //    "FSYS_UID:%0d : rbid_val='d%0d, rbid=0x%0h, rbid_unit_id=0x%0h", 
            //    fsys_txn_q[idx].fsys_unique_txn_id ,fsys_txn_q[idx].rbid_val_q[i] ,
            //    fsys_txn_q[idx].rbid_q[i] ,fsys_txn_q[idx].rbid_unit_id_q[i]), UVM_DEBUG)
            if (fsys_txn_q[idx].rbid_q[i] == m_pkt.smi_rbid
               && fsys_txn_q[idx].smi_src_ncore_unit_id == m_pkt.smi_src_ncore_unit_id
               && fsys_txn_q[idx].rbid_unit_id_q[i] == <%=obj.DveInfo[pidx].FUnitId%>
               && fsys_txn_q[idx].is_dvm == 1) begin
               `uvm_info(`LABEL, $sformatf(
                  "FSYS_UID:%0d : SMI DTW packet seen. Remaining DTWs='d%0d. (FUnitId:'d<%=obj.DveInfo[pidx].FUnitId%>) %0s", 
                  fsys_txn_q[idx].fsys_unique_txn_id, 
                  (fsys_txn_q[idx].exp_smi_data_pkts - 1), 
                  m_pkt.convert2string()), UVM_NONE+50)
               fsys_txn_q[idx].smi_msg_order_q.push_back(smi_msgs_t'(fsys_coverage_pkg::DTW_REQ));
               fsys_txn_q[idx].exp_smi_data_pkts = fsys_txn_q[idx].exp_smi_data_pkts - 1;
               fsys_txn_q[idx].update_time_accessed();
               fsys_txn_q[idx].rbid_val_q.delete(i);
               fsys_txn_q[idx].rbid_q.delete(i);
               fsys_txn_q[idx].rbid_unit_id_q.delete(i);
               fsys_txn_q[idx].dvm_part_2_addr_q[0] = m_pkt.smi_dp_data[0];
               match_found = 1;
               if (attached_funit_ids_<%=pidx%>.size() == 1) begin
                  `uvm_info(`LABEL, $sformatf("FSYS_UID:%0d : There is only 1 attached coherent unit. There won't be snoops sent.", 
                     fsys_txn_q[idx].fsys_unique_txn_id), UVM_NONE+50)
                  if (fsys_txn_q[idx].snpreq_cnt_q[0] == -1) fsys_txn_q[idx].snpreq_cnt_q[0] = 0;
                  if (fsys_txn_q[idx].snpreq_cnt_q[1] == -1) fsys_txn_q[idx].snpreq_cnt_q[1] = 0;
                  if (fsys_txn_q[idx].aiu_check_done == 1 && fsys_txn_q[idx].dvm_complete_exp == 0 && fsys_txn_q[idx].dvm_complete_resp_exp == 0
                     && fsys_txn_q[idx].ac_dvmcmpl_exp == 0 && fsys_txn_q[idx].ac_dvmcmpl_resp_exp == 0) begin
                     `uvm_info(`LABEL, $sformatf(
                        "FSYS_UID:%0d : Deleting transaction from fsys_txn_q. Remaining txns: 'd%0d",
                        fsys_txn_q[idx].fsys_unique_txn_id, (fsys_txn_q.size()-1)), UVM_NONE+50)
                     `ifdef FSYS_SCB_COVER_ON
                        fsys_txn_path_cov.sample_txn(fsys_txn_q[idx].smi_msg_order_q, (fsys_txn_q[idx].ioaiu_core_id >= 0));
                     `endif // `ifdef FSYS_SCB_COVER_ON
                     fsys_txn_q[idx].print_path();
                     fsys_txn_q.delete(idx);
                  end
               end
               break;
            end // if RBID matches current packet
         end // foreach rbid
      end // if multiple RBIDs per txn
      if (match_found == 1) break;
   end // foreach pending txn
   if (match_found == 0) begin
      `uvm_error(`LABEL, $sformatf(
         "FSYS_SCB: DTW match any pending transactions(DVE's FUnitId:'d<%=obj.DveInfo[pidx].FUnitId%>). %0s", 
         m_pkt.convert2string()))
   end // if didn't match any pending txn
endfunction : smi_dtw_prediction_<%=pidx%>

//====================================================================================================
//
// Function : smi_str_prediction
//
//====================================================================================================
function void fsys_scb_dve_predictor::smi_str_prediction_<%=pidx%>(input dve<%=pidx%>_smi_agent_pkg::smi_seq_item m_pkt, ref fsys_scb_txn fsys_txn_q[$]);
   `undef LABEL
   `define LABEL "smi_str_msg_dve<%=pidx%>"
   bit match_found = 0;
   foreach(fsys_txn_q[idx]) begin
      if (fsys_txn_q[idx].str_msg_id_q.size() > 0) begin
         foreach(fsys_txn_q[idx].str_msg_id_q[i]) begin
            if ((fsys_txn_q[idx].dest_funit_id == <%=obj.DveInfo[pidx].FUnitId%>)
               && fsys_txn_q[idx].str_msg_id_val_q[i] == 1
               && fsys_txn_q[idx].is_dvm == 1
               && fsys_txn_q[idx].str_msg_id_q[i] == m_pkt.smi_rmsg_id
               && fsys_txn_q[idx].str_unit_id_q[i] == m_pkt.smi_targ_ncore_unit_id) 
            begin
               `uvm_info(`LABEL, $sformatf(
                  "FSYS_UID:%0d : SMI STR seen. (DVE's FUnitId:'d<%=obj.DveInfo[pidx].FUnitId%>) %0s", 
                  fsys_txn_q[idx].fsys_unique_txn_id, m_pkt.convert2string()), UVM_NONE+50)
               //Store these information for DTW matching
               // Used as a check before removing Read txns from Q
               fsys_txn_q[idx].rbid_val_q.push_back(1);
               fsys_txn_q[idx].rbid_q.push_back(m_pkt.smi_rbid);
               fsys_txn_q[idx].rbid_unit_id_q.push_back(m_pkt.smi_src_ncore_unit_id);
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
// Function : smi_snpreq_prediction
//
//====================================================================================================
function void fsys_scb_dve_predictor::smi_snpreq_prediction_<%=pidx%>(input dve<%=pidx%>_smi_agent_pkg::smi_seq_item m_pkt, ref fsys_scb_txn fsys_txn_q[$]);
   `undef LABEL
   `define LABEL "smi_snpreq_dve<%=pidx%>"
   bit match_found = 0;
   // START - Unit attached state check
   int find_q[$];
   find_q = attached_funit_ids_<%=pidx%>.find_index with(item == m_pkt.smi_targ_ncore_unit_id);
   if (find_q.size() == 0) begin
      `uvm_error(`LABEL, $sformatf(
         "FSYS_SCB: Snoop sent to funit_id 0x%0h, which is not attached to this DVE. SMI pkt: %0s", 
         m_pkt.smi_targ_ncore_unit_id, m_pkt.convert2string()))
   end
   // END - Unit attached state check

   find_q.delete();
   //First delete all non-existing UIDs
   for(int idx = cmdreq_order_uid_<%=pidx%>.size()-1; idx >=0; idx--) begin
      find_q = fsys_txn_q.find_index with (item.fsys_unique_txn_id == cmdreq_order_uid_<%=pidx%>[idx]);
      if (find_q.size() == 0) begin
         cmdreq_order_uid_<%=pidx%>.delete(idx);
      end
   end

   find_q.delete();

   foreach(cmdreq_order_uid_<%=pidx%>[idx]) begin
      find_q = fsys_txn_q.find_index with (item.fsys_unique_txn_id == cmdreq_order_uid_<%=pidx%>[idx]);
      if (find_q.size() == 1) begin
         if (fsys_txn_q[find_q[0]].is_dvm == 1
            && fsys_txn_q[find_q[0]].source_funit_id !== m_pkt.smi_targ_ncore_unit_id
            && ((m_pkt.smi_addr[3:3] == 1'b0 && fsys_txn_q[find_q[0]].cmd_addr_q[0][31:4] == m_pkt.smi_addr[31:4])
               || (m_pkt.smi_addr[3:3] == 1'b1 && fsys_txn_q[find_q[0]].dvm_part_2_addr_q[0][31:4] == m_pkt.smi_addr[31:4]))
            && ((fsys_txn_q[find_q[0]].snpreq_cnt_q[0] == -1 && fsys_txn_q[find_q[0]].snprsp_cnt_q[0] == 0)
               || ((fsys_txn_q[find_q[0]].snpreq_cnt_q[0] > 0 || fsys_txn_q[find_q[0]].snprsp_cnt_q[0] > 0) && fsys_txn_q[find_q[0]].snpreq_msg_id_q[0] == m_pkt.smi_msg_id))
            && (m_pkt.smi_addr[3] == 0 || (m_pkt.smi_addr[3] == 1 && fsys_txn_q[find_q[0]].snpreq_msg_id_q[0] == m_pkt.smi_msg_id))   // Match msg_id for part-2 snoop
         ) begin
            `uvm_info(`LABEL, $sformatf(
               "FSYS_UID:%0d : DVM Part-%0d SNPReq seen. %0s", 
               fsys_txn_q[find_q[0]].fsys_unique_txn_id,
               (m_pkt.smi_addr[3] + 1),
               m_pkt.convert2string()), UVM_NONE+50)

            if (m_pkt.smi_addr[3:3] == 1'b0) begin 
               fsys_txn_q[find_q[0]].dvm_part_1_addr_q[0] = m_pkt.smi_addr;
               fsys_txn_q[find_q[0]].dvm_mpf3_range_q[0] = m_pkt.smi_mpf3_range[0];
               fsys_txn_q[find_q[0]].dvm_mpf1_q[0] = m_pkt.smi_mpf1_vmid_ext;
            end
            if (m_pkt.smi_addr[3:3] == 1'b1) begin
               fsys_txn_q[find_q[0]].dvm_part_2_addr_q[0] = m_pkt.smi_addr;
               fsys_txn_q[find_q[0]].dvm_mpf3_num_q[0] = m_pkt.smi_mpf3_num;
               fsys_txn_q[find_q[0]].dvm_part_2_mpf1_q[0] = m_pkt.smi_mpf1_vmid_ext;
            end
            fsys_txn_q[find_q[0]].snpreq_msg_id_q[0] = m_pkt.smi_msg_id;
            if (m_pkt.smi_addr[3:3] == 1'b1) begin 
               if (fsys_txn_q[find_q[0]].snpreq_cnt_q[0] == -1) fsys_txn_q[find_q[0]].snpreq_cnt_q[0] = 0;
	       if (fsys_txn_q[find_q[0]].snpreq_cnt_q[0] == 0) begin
                  fsys_txn_q[find_q[0]].smi_msg_order_q.push_back(smi_msgs_t'(fsys_coverage_pkg::SNP_REQ));
               end
               fsys_txn_q[find_q[0]].snpreq_cnt_q[0] = fsys_txn_q[find_q[0]].snpreq_cnt_q[0] + 1;
               fsys_txn_q[find_q[0]].snpreq_targ_id_q.push_back(m_pkt.smi_targ_ncore_unit_id);
               fsys_txn_q[find_q[0]].snpreq_src_id_q.push_back(m_pkt.smi_src_ncore_unit_id);
               fsys_txn_q[find_q[0]].chi_snp_txnid_q.push_back(-1);
               fsys_txn_q[find_q[0]].chi_snp_data_count_q.push_back(-1);
               fsys_txn_q[find_q[0]].snp_up_q.push_back(2'b00);
               fsys_txn_q[find_q[0]].read_acc_dtr_exp_q.push_back(0);
               fsys_txn_q[find_q[0]].read_acc_dtr_tgtid_q.push_back(0);
               fsys_txn_q[find_q[0]].read_acc_dtr_msgid_q.push_back(-1);
               fsys_txn_q[find_q[0]].snp_ioaiu_from_chi_q.push_back(0);
               fsys_txn_q[find_q[0]].ioaiu_snprsp_exp_q.push_back(0);
               fsys_txn_q[find_q[0]].ioaiu_snpdat_exp_q.push_back(0);
               fsys_txn_q[find_q[0]].ioaiu_snp_data_seen_q.push_back(0);
               fsys_txn_q[find_q[0]].ioaiu_dvm_snp_addr_seen_q.push_back(0);
               fsys_txn_q[find_q[0]].chi_dvm_snp_addr_seen_q.push_back(0);
               // Concatenate msg_id and targ_id to create unique identifier to match SNPRsp
               fsys_txn_q[find_q[0]].snpreq_unq_id_q.push_back({m_pkt.smi_targ_ncore_unit_id, m_pkt.smi_msg_id});
               fsys_txn_q[find_q[0]].update_time_accessed();
            end
            match_found = 1;
            break;
         end // if matched
      end // if txn found
      if (match_found == 1) break;
   end //foreach pending txn 
   if (match_found == 0)
         `uvm_error(`LABEL, $sformatf(
            "FSYS_SCB: SNPReq didn't match any pending transactions. %0s",
            m_pkt.convert2string()))
endfunction : smi_snpreq_prediction_<%=pidx%>

//====================================================================================================
//
// Function : smi_snprsp_prediction
//
//====================================================================================================
function void fsys_scb_dve_predictor::smi_snprsp_prediction_<%=pidx%>(input dve<%=pidx%>_smi_agent_pkg::smi_seq_item m_pkt, ref fsys_scb_txn fsys_txn_q[$]);
   `undef LABEL
   `define LABEL "smi_snprsp_dve<%=pidx%>"
   bit match_found = 0;
   bit all_dve_snp_resp_seen = 1;
   bit all_ioaiu_snp_resp_seen = 1;
   bit all_chi_snp_resp_seen = 1;
   foreach (fsys_txn_q[idx]) begin
      if (fsys_txn_q[idx].snpreq_msg_id_q.size() > 0) begin
         foreach (fsys_txn_q[idx].snpreq_msg_id_q[i]) begin
            if (fsys_txn_q[idx].is_dvm == 1
               && fsys_txn_q[idx].snpreq_msg_id_q[i] == m_pkt.smi_rmsg_id
               && (fsys_txn_q[idx].dest_funit_id == <%=obj.DveInfo[pidx].FUnitId%> || fsys_txn_q[idx].multi_cacheline_access == 1)
               && fsys_txn_q[idx].snpreq_cnt_q[i] > 0)
            begin
               foreach (fsys_txn_q[idx].snpreq_unq_id_q[j]) begin
                  if (fsys_txn_q[idx].snpreq_unq_id_q[j] == {m_pkt.smi_src_ncore_unit_id, m_pkt.smi_rmsg_id}
                     && fsys_txn_q[idx].snpreq_src_id_q[j] == <%=obj.DveInfo[pidx].FUnitId%>) begin
                     `uvm_info(`LABEL, $sformatf(
                        "FSYS_UID:%0d : SNPRsp seen (DVE's FUnitId:'d<%=obj.DveInfo[pidx].FUnitId%>) %0s",
                        fsys_txn_q[idx].fsys_unique_txn_id, m_pkt.convert2string()), UVM_NONE+50)
                     fsys_txn_q[idx].update_time_accessed();
                     if (fsys_txn_q[idx].ioaiu_core_id >=0) begin
                        fsys_txn_q[idx].exp_smi_data_pkts = fsys_txn_q[idx].exp_smi_data_pkts - 1;
                     end
                     fsys_txn_q[idx].snpreq_cnt_q[i] = fsys_txn_q[idx].snpreq_cnt_q[i] - 1;
                     fsys_txn_q[idx].snprsp_cnt_q[i] = fsys_txn_q[idx].snprsp_cnt_q[i] + 1;

                     foreach(fsys_txn_q[idx].snpreq_cnt_q[snpreq_idx]) begin
                        if (fsys_txn_q[idx].snpreq_cnt_q[snpreq_idx] == 0) begin
                           all_dve_snp_resp_seen = (all_dve_snp_resp_seen & 1'b1);
                        end else begin
                           all_dve_snp_resp_seen = 0;
                        end
                     end
                     foreach(fsys_txn_q[idx].ioaiu_snprsp_exp_q[snpreq_idx]) begin
                        if (fsys_txn_q[idx].ioaiu_snprsp_exp_q[snpreq_idx] == 0 && fsys_txn_q[idx].ioaiu_snpdat_exp_q[snpreq_idx] == 0) begin
                           all_ioaiu_snp_resp_seen = (all_ioaiu_snp_resp_seen & 1'b1);
                        end else begin
                           all_ioaiu_snp_resp_seen = 0;
                        end
                     end
                     foreach(fsys_txn_q[idx].chi_snp_txnid_q[snpreq_idx]) begin
                        if (fsys_txn_q[idx].chi_snp_txnid_q[snpreq_idx] < 0) begin
                           all_chi_snp_resp_seen = (all_chi_snp_resp_seen & 1'b1);
                        end else begin
                           all_chi_snp_resp_seen = 0;
                        end
                     end

                     // only add first SNP_REQ and last SNP_RSP
                     if (all_dve_snp_resp_seen == 1) begin
                        fsys_txn_q[idx].smi_msg_order_q.push_back(smi_msgs_t'(fsys_coverage_pkg::SNP_RESP));
                     end

                     if (fsys_txn_q[idx].ioaiu_snprsp_exp_q[j] == 0 
                        && fsys_txn_q[idx].ioaiu_snpdat_exp_q[j] == 0
                        && (fsys_txn_q[idx].ioaiu_dvm_snp_addr_seen_q[j] == 2 || fsys_txn_q[idx].ioaiu_dvm_snp_addr_seen_q[j] == 0)
                        && fsys_txn_q[idx].chi_snp_txnid_q[j] < 0 ) begin
                        //fsys_txn_q[idx].snpreq_unq_id_q.delete(j);
                        //fsys_txn_q[idx].snpreq_targ_id_q.delete(j); 
                        //fsys_txn_q[idx].snpreq_src_id_q.delete(j); 
                        //fsys_txn_q[idx].chi_snp_txnid_q.delete(j); 
                        //fsys_txn_q[idx].chi_snp_data_count_q.delete(j); 
                        //fsys_txn_q[idx].snp_up_q.delete(j); 
                        //fsys_txn_q[idx].read_acc_dtr_exp_q.delete(j); 
                        //fsys_txn_q[idx].read_acc_dtr_tgtid_q.delete(j); 
                        //fsys_txn_q[idx].read_acc_dtr_msgid_q.delete(j); 
                        //fsys_txn_q[idx].snp_ioaiu_from_chi_q.delete(j);
                        //fsys_txn_q[idx].ioaiu_snprsp_exp_q.delete(j); 
                        //fsys_txn_q[idx].ioaiu_snpdat_exp_q.delete(j); 
                        //fsys_txn_q[idx].ioaiu_snp_data_seen_q.delete(j); 
                        //fsys_txn_q[idx].ioaiu_dvm_snp_addr_seen_q.delete(j); 
                        //fsys_txn_q[idx].chi_dvm_snp_addr_seen_q.delete(j); 
                     end
                     // if all snpresp are seen, invalidate addr values to avoid multiple matches
                     if (fsys_txn_q[idx].snpreq_cnt_q[i] == 0) begin
                        fsys_txn_q[idx].dvm_part_1_addr_q[i] = -2;
                        fsys_txn_q[idx].dvm_part_2_addr_q[i] = -2;
                     end
                     if (all_dve_snp_resp_seen == 1 && fsys_txn_q[idx].aiu_check_done == 1 
                        && fsys_txn_q[idx].dvm_complete_exp == 0 && fsys_txn_q[idx].dvm_complete_resp_exp == 0
                        && fsys_txn_q[idx].ac_dvmcmpl_exp == 0 && fsys_txn_q[idx].ac_dvmcmpl_resp_exp == 0
                        && all_ioaiu_snp_resp_seen == 1 && all_chi_snp_resp_seen == 1) begin
                        `uvm_info(`LABEL, $sformatf(
                           "FSYS_UID:%0d : Deleting transaction from fsys_txn_q. Remaining txns: 'd%0d",
                           fsys_txn_q[idx].fsys_unique_txn_id, (fsys_txn_q.size()-1)), UVM_NONE+50)
                        `ifdef FSYS_SCB_COVER_ON
                           fsys_txn_path_cov.sample_txn(fsys_txn_q[idx].smi_msg_order_q, (fsys_txn_q[idx].ioaiu_core_id >= 0));
                        `endif // `ifdef FSYS_SCB_COVER_ON
                        fsys_txn_q[idx].print_path();
                        fsys_txn_q.delete(idx);
                     end
                     match_found = 1;
                     break;
                  end
               end // foreach snpreq_unq_id_q 
            end // if matched
            if (match_found == 1) break;
         end // foreach CMDReq
      end // if there are pending CMDReqs
      if (match_found == 1) break;
   end //foreach pending txn 
   if (match_found == 0) begin
      `uvm_error(`LABEL, $sformatf(
         "FSYS_SCB: SNPRsp didn't match any pending transactions. %0s",
         m_pkt.convert2string()))
   end
endfunction : smi_snprsp_prediction_<%=pidx%>

//====================================================================================================
//
// Function : smi_sysreq_prediction
//
//====================================================================================================
function void fsys_scb_dve_predictor::smi_sysreq_prediction_<%=pidx%>(input dve<%=pidx%>_smi_agent_pkg::smi_seq_item m_pkt, ref fsys_scb_txn fsys_txn_q[$]);
   `undef LABEL
   `define LABEL "smi_sysreq_dve<%=pidx%>"
   `uvm_info(`LABEL, $sformatf("FSYS_SCB: SYSREQ seen: %0s", m_pkt.convert2string()), UVM_NONE+50)
   case(m_pkt.smi_sysreq_op)
      dve<%=pidx%>_smi_agent_pkg::SMI_SYSREQ_ATTACH:
      begin
         pending_attach_sys_req_<%=pidx%>.push_back(m_pkt);
      end
      dve<%=pidx%>_smi_agent_pkg::SMI_SYSREQ_DETACH:
      begin
         pending_attach_sys_req_<%=pidx%>.push_back(m_pkt);
      end
      default:
      begin
         if ($test$plusargs("EN_SYS_EVENT_CHECK")) begin
            if (m_pkt.smi_sysreq_op == dve<%=pidx%>_smi_agent_pkg::SMI_SYSREQ_EVENT) begin
               analyze_sys_event_<%=pidx%>(m_pkt, fsys_txn_q);
            end
         end else begin
            `uvm_info(`LABEL, $sformatf("FSYS_SCB: SYSReq packet: Not Supported %0s", m_pkt.convert2string()), UVM_NONE+50)
            pending_attach_sys_req_<%=pidx%>.push_back(m_pkt);
         end
      end
   endcase
endfunction : smi_sysreq_prediction_<%=pidx%>

//====================================================================================================
//
// Function : analyze_sys_event
//
//====================================================================================================
function void fsys_scb_dve_predictor::analyze_sys_event_<%=pidx%>(input dve<%=pidx%>_smi_agent_pkg::smi_seq_item m_pkt, ref fsys_scb_txn fsys_txn_q[$]);
   `undef LABEL
   `define LABEL "analyze_sys_event_dve<%=pidx%>"
   int find_q[$];
   bit matched = 0;
   fsys_scb_txn m_txn = fsys_scb_txn::type_id::create("m_txn");
   if (m_pkt.smi_src_ncore_unit_id == <%=obj.DveInfo[pidx].FUnitId%>) begin
      //First delete all non-existing UIDs
      for(int idx = sysevent_order_uid_<%=pidx%>.size()-1; idx >=0; idx--) begin
         find_q = fsys_txn_q.find_index with (item.fsys_unique_txn_id == sysevent_order_uid_<%=pidx%>[idx]);
         if (find_q.size() == 0) begin
            sysevent_order_uid_<%=pidx%>.delete(idx);
         end
      end

      find_q.delete();
      foreach(sysevent_order_uid_<%=pidx%>[idx]) begin
         find_q = fsys_txn_q.find_index with (item.fsys_unique_txn_id == sysevent_order_uid_<%=pidx%>[idx]);
         if (find_q.size() == 1) begin
            foreach (fsys_txn_q[find_q[0]].sys_evnt_rcvrs_q[i]) begin
               if (fsys_txn_q[find_q[0]].sys_evnt_rcvrs_q[i].funit_id == m_pkt.smi_targ_ncore_unit_id
                  && fsys_txn_q[find_q[0]].sys_evnt_rcvrs_q[i].dve_sent == 0) begin
                  fsys_txn_q[find_q[0]].sys_evnt_rcvrs_q[i].smi_msg_id = m_pkt.smi_msg_id;
                  fsys_txn_q[find_q[0]].sys_evnt_rcvrs_q[i].dve_sent = 1;
                  `uvm_info(`LABEL, $sformatf(
                     "FSYS_UID:%0d : DVE sent SYSREQ for a SYS_EVENT transaction. %0s", 
                     fsys_txn_q[find_q[0]].fsys_unique_txn_id, m_pkt.convert2string()), UVM_NONE+50)
                  matched = 1;
                  break;
               end // if sys event match found
            end // foreach sys_evnt_rcvrs_q
         end // if UID found
         if (matched == 1) break;
      end // foreach sys_event txns
      if (matched == 0) begin
         `uvm_error(`LABEL, $sformatf("FSYS_SCB: Outgoing SYS_EVENT didn't match any pending transactions. PKT: %0s", m_pkt.convert2string()))
      end
   end // outgoing SYS_EVENT 
   else begin
      find_q = fsys_txn_q.find_index with (item.is_sys_evnt == 1 && item.smi_msg_id == m_pkt.smi_msg_id
                                          && item.source_funit_id == m_pkt.smi_src_ncore_unit_id);
      if (find_q.size() > 0) begin
         <% for(i = 0; i < obj.DveInfo[pidx].sysEvtReceivers.length; i++) { %>
            if (<%=obj.DveInfo[pidx].sysEvtReceivers[i]%> !== m_pkt.smi_src_ncore_unit_id) begin
               fsys_scb_txn::sys_evnt_rcvrs_s rcvr;
               rcvr.funit_id = <%=obj.DveInfo[pidx].sysEvtReceivers[i]%>;
               rcvr.smi_msg_id = -1;
               fsys_txn_q[find_q[0]].sys_evnt_rcvrs_q.push_back(rcvr);
               `uvm_info(`LABEL, $sformatf("FSYS_UID:%0d : DVE will broadcast to FUnitId: 'd%0d", fsys_txn_q[find_q[0]].fsys_unique_txn_id, rcvr.funit_id), UVM_NONE+50)
            end
         <% } %>
         `uvm_info(`LABEL, $sformatf(
            "FSYS_UID:%0d : DVE received SYSREQ for a SYS_EVENT transaction. Will forward it to %0d attached AIUs. PKT: %0s", 
            fsys_txn_q[find_q[0]].fsys_unique_txn_id, fsys_txn_q[find_q[0]].sys_evnt_rcvrs_q.size(), m_pkt.convert2string()), UVM_NONE+50)
         sysevent_order_uid_<%=pidx%>.push_back(fsys_txn_q[find_q[0]].fsys_unique_txn_id);
      end else begin
         `uvm_info(`LABEL, $sformatf("FSYS_SCB: Incoming SYS_EVENT didn't match any pending transactions, adding a new transaction. PKT: %0s", m_pkt.convert2string()), UVM_NONE+50)
          m_txn.fsys_unique_txn_id = fsys_scoreboard::get_next_unique_txn_id();
         `uvm_info(`LABEL, $sformatf(
            "FSYS_UID:%0d : Adding a SYS_EVENT to pending queue. PKT: %0s", 
            m_txn.fsys_unique_txn_id, m_pkt.convert2string()), UVM_NONE+50)
         m_txn.is_sys_evnt = 1;
         m_txn.source_funit_id = m_pkt.smi_src_ncore_unit_id;
         m_txn.smi_msg_id = m_pkt.smi_msg_id;
         <% for(i = 0; i < obj.DveInfo[pidx].sysEvtReceivers.length; i++) { %>
            if (<%=obj.DveInfo[pidx].sysEvtReceivers[i]%> !== m_pkt.smi_src_ncore_unit_id) begin
               fsys_scb_txn::sys_evnt_rcvrs_s rcvr;
               rcvr.funit_id = <%=obj.DveInfo[pidx].sysEvtReceivers[i]%>;
               rcvr.smi_msg_id = -1;
               m_txn.sys_evnt_rcvrs_q.push_back(rcvr);
               `uvm_info(`LABEL, $sformatf("FSYS_UID:%0d : DVE will broadcast to FUnitId: 'd%0d", m_txn.fsys_unique_txn_id, rcvr.funit_id), UVM_NONE+50)
            end
         <% } %>
         `uvm_info(`LABEL, $sformatf(
            "FSYS_UID:%0d : DVE received SYSREQ for a SYS_EVENT transaction. Will forward it to %0d attached AIUs. PKT: %0s", 
            m_txn.fsys_unique_txn_id, m_txn.sys_evnt_rcvrs_q.size(), m_pkt.convert2string()), UVM_NONE+50)
         sysevent_order_uid_<%=pidx%>.push_back(m_txn.fsys_unique_txn_id);
         fsys_txn_q.push_back(m_txn);
      end
   end // incoming SYS_EVENT

endfunction : analyze_sys_event_<%=pidx%>

//====================================================================================================
//
// Function : smi_sysrsp_prediction
//
//====================================================================================================
function void fsys_scb_dve_predictor::smi_sysrsp_prediction_<%=pidx%>(input dve<%=pidx%>_smi_agent_pkg::smi_seq_item m_pkt, ref fsys_scb_txn fsys_txn_q[$]);
   `undef LABEL
   `define LABEL "smi_sysrsp_dve<%=pidx%>"
   int find_q[$];
   bit matched=0;
   `uvm_info(`LABEL, $sformatf("FSYS_SCB: SYSRSP seen: %0s", m_pkt.convert2string()), UVM_NONE+50)
   find_q = pending_attach_sys_req_<%=pidx%>.find_index with (
                  item.smi_targ_ncore_unit_id == m_pkt.smi_src_ncore_unit_id
                  && item.smi_msg_id == m_pkt.smi_rmsg_id);
   if (find_q.size() > 0) begin
      if (pending_attach_sys_req_<%=pidx%>[find_q[0]].smi_sysreq_op == dve<%=pidx%>_smi_agent_pkg::SMI_SYSREQ_ATTACH) begin
         attached_funit_ids_<%=pidx%>.push_back(m_pkt.smi_targ_ncore_unit_id);
         pending_attach_sys_req_<%=pidx%>.delete(find_q[0]);
         `uvm_info(`LABEL, $sformatf("FSYS_SCB: SYSRSP matched a pending SYSREQ. Marking DVE as attached to funit id: 0x%0h", m_pkt.smi_targ_ncore_unit_id), UVM_NONE+50)
      end else if (pending_attach_sys_req_<%=pidx%>[find_q[0]].smi_sysreq_op == dve<%=pidx%>_smi_agent_pkg::SMI_SYSREQ_DETACH) begin
         foreach(attached_funit_ids_<%=pidx%>[idx]) begin
            if (attached_funit_ids_<%=pidx%>[idx] == m_pkt.smi_targ_ncore_unit_id) begin
               attached_funit_ids_<%=pidx%>.delete(idx);
               matched = 1;
               `uvm_info(`LABEL, $sformatf("FSYS_SCB: SYSRSP matched a pending SYSREQ. Marking DVE as detached from funit id: 0x%0h", m_pkt.smi_targ_ncore_unit_id), UVM_NONE+50)
               break;
            end
         end
         if (matched == 0) begin
            `uvm_error(`LABEL, $sformatf("FSYS_SCB: DETACH seen, but the unit wasn't in attached state. PKT: %0s", m_pkt.convert2string()))
         end
         pending_attach_sys_req_<%=pidx%>.delete(find_q[0]);
      end else begin
         `uvm_info(`LABEL, $sformatf("FSYS_SCB: SYSRSP matched to an unsupported SYSReq type %0s", pending_attach_sys_req_<%=pidx%>[find_q[0]].convert2string()), UVM_NONE+50)
         pending_attach_sys_req_<%=pidx%>.delete(find_q[0]);
      end
   end else begin
      if ($test$plusargs("EN_SYS_EVENT_CHECK")) begin
         analyze_sys_event_rsp_<%=pidx%>(m_pkt, fsys_txn_q);
      end else begin
         `uvm_error(`LABEL, $sformatf("FSYS_SCB: SYSRSP didn't match any pending SYSREQ. PKT: %0s", m_pkt.convert2string()))
      end
   end
endfunction : smi_sysrsp_prediction_<%=pidx%>

//====================================================================================================
//
// Function : analyze_sys_event_rsp
//
//====================================================================================================
function void fsys_scb_dve_predictor::analyze_sys_event_rsp_<%=pidx%>(input dve<%=pidx%>_smi_agent_pkg::smi_seq_item m_pkt, ref fsys_scb_txn fsys_txn_q[$]);
   `undef LABEL
   `define LABEL "analyze_sys_event_rsp_dve<%=pidx%>"
   int find_q[$];
   bit matched = 0;
   if (m_pkt.smi_src_ncore_unit_id == <%=obj.DveInfo[pidx].FUnitId%>) begin
      //First delete all non-existing UIDs
      for(int idx = sysevent_order_uid_<%=pidx%>.size()-1; idx >=0; idx--) begin
         find_q = fsys_txn_q.find_index with (item.fsys_unique_txn_id == sysevent_order_uid_<%=pidx%>[idx]);
         if (find_q.size() == 0) begin
            sysevent_order_uid_<%=pidx%>.delete(idx);
         end
      end

      find_q.delete();
      foreach(sysevent_order_uid_<%=pidx%>[idx]) begin
         find_q = fsys_txn_q.find_index with (item.fsys_unique_txn_id == sysevent_order_uid_<%=pidx%>[idx]);
         if (find_q.size() == 1) begin
            if (fsys_txn_q[find_q[0]].sys_evnt_rcvrs_q.size() !== 0) begin
               `uvm_error(`LABEL, $sformatf("FSYS_UID:%0d : DVE sent SYS_EVENT RSP to originating unit, while it's still waiting for %0d SYSRSPes from other attached units. PKT: %0s",
                  fsys_txn_q[find_q[0]].fsys_unique_txn_id, fsys_txn_q[find_q[0]].sys_evnt_rcvrs_q.size(), m_pkt.convert2string()))
            end else begin
               fsys_txn_q[find_q[0]].sys_rsp_sent = 1;
               `uvm_info(`LABEL, $sformatf("FSYS_UID:%0d : DVE sent SYS_EVENT RSP to originating unit. PKT: %0s",
                  fsys_txn_q[find_q[0]].fsys_unique_txn_id, m_pkt.convert2string()), UVM_NONE+50)
                  matched = 1;
            end
            break;
         end // if UID found
      end // foreach sys_event txns
      if (matched == 0) begin
         `uvm_error(`LABEL, $sformatf("FSYS_SCB: Outgoing SYSRSP didn't match any pending transactions. PKT: %0s", m_pkt.convert2string()))
      end
   end // outgoing SYS_EVENT RSP
   else begin
      //First delete all non-existing UIDs
      for(int idx = sysevent_order_uid_<%=pidx%>.size()-1; idx >=0; idx--) begin
         find_q = fsys_txn_q.find_index with (item.fsys_unique_txn_id == sysevent_order_uid_<%=pidx%>[idx]);
         if (find_q.size() == 0) begin
            sysevent_order_uid_<%=pidx%>.delete(idx);
         end
      end

      find_q.delete();
      foreach(sysevent_order_uid_<%=pidx%>[idx]) begin
         find_q = fsys_txn_q.find_index with (item.fsys_unique_txn_id == sysevent_order_uid_<%=pidx%>[idx]);
         if (find_q.size() == 1) begin
            foreach (fsys_txn_q[find_q[0]].sys_evnt_rcvrs_q[i]) begin
               if (fsys_txn_q[find_q[0]].sys_evnt_rcvrs_q[i].funit_id == m_pkt.smi_src_ncore_unit_id
                  && fsys_txn_q[find_q[0]].sys_evnt_rcvrs_q[i].dve_sent == 1
                  && fsys_txn_q[find_q[0]].sys_evnt_rcvrs_q[i].unit_rcvd == 1
                  && fsys_txn_q[find_q[0]].sys_evnt_rcvrs_q[i].rsp_sent == 1
                  && fsys_txn_q[find_q[0]].sys_evnt_rcvrs_q[i].smi_msg_id == m_pkt.smi_rmsg_id) begin
                  fsys_txn_q[find_q[0]].sys_evnt_rcvrs_q[i].rsp_rcvd = 1;
                  fsys_txn_q[find_q[0]].sys_evnt_rcvrs_q.delete(i);
                  `uvm_info(`LABEL, $sformatf(
                     "FSYS_UID:%0d : DVE received SYSRSP for a SYS_EVENT transaction. %0s", 
                     fsys_txn_q[find_q[0]].fsys_unique_txn_id, m_pkt.convert2string()), UVM_NONE+50)
                  matched = 1;
                  break;
               end // if match found
            end // foreach sys_evnt_rcvrs_q
         end // if UID found
         if (matched == 1) break;
      end // foreach sys_event txns
      if (matched == 0) begin
         `uvm_error(`LABEL, $sformatf("FSYS_SCB: Incoming SYSRSP didn't match any pending transactions. PKT: %0s", m_pkt.convert2string()))
      end
   end // incoming SYS_EVENT RSP
endfunction : analyze_sys_event_rsp_<%=pidx%>

<% } //foreach DVE %>

////////////////////////////////////////////////////////////////////////////////
// Function: check_phase
// Description: Runs end of test checks and prints debug information
////////////////////////////////////////////////////////////////////////////////
function void fsys_scb_dve_predictor::check_phase(uvm_phase phase);
   <% for(var pidx = 0; pidx < obj.nDVEs; pidx++) { %>
      if (pending_attach_sys_req_<%=pidx%>.size() !== 0) begin
      //TODO: make this an error when TB has support to drive event_if signals
         `uvm_warning("check_phase", $psprintf("FSYS_SCB: DVE<%=pidx%> has %0d pending SYSREQ that didn't see SYSRSP", pending_attach_sys_req_<%=pidx%>.size()))
      end
   <% } // foreach DVE %>
endfunction : check_phase

// End of file
