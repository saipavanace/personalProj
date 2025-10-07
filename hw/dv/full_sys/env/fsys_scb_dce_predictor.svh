////////////////////////////////////////////////////////////////////////////////
//
// Author       : Neha F
// Purpose      : DCE predictor class
// Description  : This is one of the components of fsys_scoreboard. This component
//                contains predicting logic from DCE blocks. 
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


class fsys_scb_dce_predictor extends uvm_component;

   `uvm_component_utils(fsys_scb_dce_predictor)
   `ifdef FSYS_SCB_COVER_ON 
   fsys_txn_path_coverage fsys_txn_path_cov;
   `endif // `ifdef FSYS_SCB_COVER_ON              


   extern function new(string name = "fsys_scb_dce_predictor", uvm_component parent = null);
   extern function void build_phase(uvm_phase phase);

<% for(var pidx = 0; pidx < obj.nDCEs; pidx++) { %>
   extern function void analyze_smi_pkt_<%=pidx%>(input dce<%=pidx%>_smi_agent_pkg::smi_seq_item m_pkt, ref fsys_scb_txn fsys_txn_q[$]);
   extern function void smi_cmd_prediction_<%=pidx%>(input dce<%=pidx%>_smi_agent_pkg::smi_seq_item m_pkt, ref fsys_scb_txn fsys_txn_q[$]); 
   extern function void smi_str_prediction_<%=pidx%>(input dce<%=pidx%>_smi_agent_pkg::smi_seq_item m_pkt, ref fsys_scb_txn fsys_txn_q[$]);
   extern function void smi_rbr_prediction_<%=pidx%>(input dce<%=pidx%>_smi_agent_pkg::smi_seq_item m_pkt, ref fsys_scb_txn fsys_txn_q[$]);
   extern function void smi_mrd_prediction_<%=pidx%>(input dce<%=pidx%>_smi_agent_pkg::smi_seq_item m_pkt, ref fsys_scb_txn fsys_txn_q[$]);
   extern function void smi_snpreq_prediction_<%=pidx%>(input dce<%=pidx%>_smi_agent_pkg::smi_seq_item m_pkt, ref fsys_scb_txn fsys_txn_q[$]);
   extern function void smi_snprsp_prediction_<%=pidx%>(input dce<%=pidx%>_smi_agent_pkg::smi_seq_item m_pkt, ref fsys_scb_txn fsys_txn_q[$]);
   extern function void smi_rbrsp_prediction_<%=pidx%>(input dce<%=pidx%>_smi_agent_pkg::smi_seq_item m_pkt, ref fsys_scb_txn fsys_txn_q[$]);
   extern function void smi_updreq_prediction_<%=pidx%>(input dce<%=pidx%>_smi_agent_pkg::smi_seq_item m_pkt, ref fsys_scb_txn fsys_txn_q[$]);
   extern function void smi_sysreq_prediction_<%=pidx%>(input dce<%=pidx%>_smi_agent_pkg::smi_seq_item m_pkt, ref fsys_scb_txn fsys_txn_q[$]);
   extern function void analyze_sys_event_<%=pidx%>(input dce<%=pidx%>_smi_agent_pkg::smi_seq_item m_pkt, ref fsys_scb_txn fsys_txn_q[$]);
   extern function void smi_sysrsp_prediction_<%=pidx%>(input dce<%=pidx%>_smi_agent_pkg::smi_seq_item m_pkt, ref fsys_scb_txn fsys_txn_q[$]);
   dce<%=pidx%>_smi_agent_pkg::smi_seq_item tmp_snpreq_pkt_<%=pidx%>[$];
   int cmdreq_order_uid_<%=pidx%>[$];
   int cmdreq_order_idx_<%=pidx%>[$];
   int rbid_internally_released_<%=pidx%>[$];
   int rbid_internally_released_dmiid_<%=pidx%>[$];
   //SYSREQ related lists 
   dce<%=pidx%>_smi_agent_pkg::smi_seq_item pending_attach_sys_req_<%=pidx%>[$];
   //Queue of funit IDs attached AIUs
   int attached_funit_ids_<%=pidx%>[$];

   extern function void check_for_reissue_<%=pidx%>(input int rbid, input int dmi_id);
<% } //foreach DCE %>
   // End of test checks
   extern function void check_phase(uvm_phase phase);

   //MEM_CONSISTENCY
   mem_consistency_checker mem_checker;
   bit   m_en_mem_check;
endclass : fsys_scb_dce_predictor

function fsys_scb_dce_predictor::new(string name = "fsys_scb_dce_predictor", uvm_component parent = null);
   super.new(name,parent);
endfunction : new

function void fsys_scb_dce_predictor::build_phase(uvm_phase phase);
   super.build_phase(phase);
   //MEM_CONSISTENCY
   if($test$plusargs("EN_MEM_CHECK")) begin
      m_en_mem_check = 1;
   end else begin
      m_en_mem_check = 0;
   end
   if(m_en_mem_check) begin
      if(!(uvm_config_db #(mem_consistency_checker)::get(uvm_root::get(), "", "mem_checker", mem_checker)))begin
         `uvm_fatal("fsys_scb_dce_predictor", "Could not find mem_consistency_checker object in UVM DB");
      end
   end

endfunction : build_phase

<% for(var pidx = 0; pidx < obj.nDCEs; pidx++) { %>

//====================================================================================================
//
// Function : analyze_smi_pkt
//
//====================================================================================================
function void fsys_scb_dce_predictor::analyze_smi_pkt_<%=pidx%>(input dce<%=pidx%>_smi_agent_pkg::smi_seq_item m_pkt, ref fsys_scb_txn fsys_txn_q[$]);
   dce<%=pidx%>_smi_agent_pkg::smi_seq_item tmp_pkt = dce<%=pidx%>_smi_agent_pkg::smi_seq_item::type_id::create("tmp_pkt");
   tmp_pkt.copy(m_pkt);
   if (tmp_pkt.isCmdMsg()) begin
      smi_cmd_prediction_<%=pidx%>(tmp_pkt, fsys_txn_q);
   end // if cmd_req smi pkt
   else if (tmp_pkt.isStrMsg()) begin
      smi_str_prediction_<%=pidx%>(tmp_pkt, fsys_txn_q);
   end
   else if (tmp_pkt.isRbMsg()) begin
      smi_rbr_prediction_<%=pidx%>(tmp_pkt, fsys_txn_q);
   end // if RbrMsg
   else if (tmp_pkt.isMrdMsg()) begin
      smi_mrd_prediction_<%=pidx%>(tmp_pkt, fsys_txn_q);
   end //if MRDReq
   else if (tmp_pkt.isSnpMsg()) begin
      smi_snpreq_prediction_<%=pidx%>(tmp_pkt, fsys_txn_q);
   end // is SNPReq
   else if (tmp_pkt.isSnpRspMsg()) begin
      smi_snprsp_prediction_<%=pidx%>(tmp_pkt, fsys_txn_q);
   end // is SNPRsp
   else if (tmp_pkt.isRbRspMsg()) begin
      smi_rbrsp_prediction_<%=pidx%>(tmp_pkt, fsys_txn_q);
   end // is RBRsp
   else if (tmp_pkt.isUpdMsg()) begin
      smi_updreq_prediction_<%=pidx%>(tmp_pkt, fsys_txn_q);
   end // is UpdReq
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
function void fsys_scb_dce_predictor::smi_cmd_prediction_<%=pidx%>(input dce<%=pidx%>_smi_agent_pkg::smi_seq_item m_pkt, ref fsys_scb_txn fsys_txn_q[$]);
   `undef LABEL
   `define LABEL "smi_cmd_msg_dce<%=pidx%>"
   bit match_found = 0;
   int find_combined_q[$];
   dce<%=pidx%>_smi_agent_pkg::smi_seq_item tmp_pkt = dce<%=pidx%>_smi_agent_pkg::smi_seq_item::type_id::create("tmp_pkt");
   dce<%=pidx%>_smi_agent_pkg::eMsgCMD cmd_type;
   $cast(cmd_type, m_pkt.smi_msg_type);
   tmp_pkt.copy(m_pkt);
   foreach (fsys_txn_q[txn_idx]) begin
      foreach(fsys_txn_q[txn_idx].cmd_req_val_q[cmd_idx]) begin
         if (fsys_txn_q[txn_idx].cmd_req_val_q[cmd_idx] == 1
            && fsys_txn_q[txn_idx].cmd_req_targ_q[cmd_idx] == <%=obj.DceInfo[pidx].FUnitId%>
            && fsys_txn_q[txn_idx].cmd_req_id_q[cmd_idx] == m_pkt.smi_msg_id
            && fsys_txn_q[txn_idx].cmd_req_addr_q[cmd_idx] == m_pkt.smi_addr
            <% if (obj.wSecurityAttribute > 0) { %>
            && fsys_txn_q[txn_idx].smi_ns == m_pkt.smi_ns
            <% } %>
            <% if (obj.Widths.Concerto.Ndp.Body.wPR > 0) { %>
            && fsys_txn_q[txn_idx].smi_pr == m_pkt.smi_pr
            <% } %>
            && fsys_txn_q[txn_idx].smi_src_ncore_unit_id == m_pkt.smi_src_ncore_unit_id
         ) begin
            if(fsys_txn_q[txn_idx].multi_cacheline_access) begin
               `uvm_info(`LABEL, $sformatf(
                  "FSYS_UID:%0d SUB_ID:%0d : CMDReq seen (DCE's FUnitId:'d<%=obj.DceInfo[pidx].FUnitId%>) %0s", 
                  fsys_txn_q[txn_idx].fsys_unique_txn_id, fsys_txn_q[txn_idx].cmd_req_subid_q[cmd_idx],
                  m_pkt.convert2string()), UVM_NONE+50)
            end
            else begin
               `uvm_info(`LABEL, $sformatf(
                  "FSYS_UID:%0d : CMDReq seen (DCE's FUnitId:'d<%=obj.DceInfo[pidx].FUnitId%>) %0s", 
                  fsys_txn_q[txn_idx].fsys_unique_txn_id, m_pkt.convert2string()), UVM_NONE+50)
            end
            //Only reset for IOAIU txns, CHIAIU predictor uses this msg_id for STR matching
            fsys_txn_q[txn_idx].update_time_accessed();
            if (fsys_txn_q[txn_idx].ioaiu_core_id >= 0) begin
               fsys_txn_q[txn_idx].smi_msg_id = -1;
            end
            fsys_txn_q[txn_idx].cmd_did_q.push_back(m_pkt.smi_dest_id);
            //fsys_txn_q[txn_idx].smi_vz_ca_ac_ns_pr_qos_q.push_back({m_pkt.smi_vz, m_pkt.smi_ca, m_pkt.smi_ac, m_pkt.smi_ns, m_pkt.smi_pr, m_pkt.smi_qos});
            fsys_txn_q[txn_idx].cmd_req_pkt_<%=pidx%>_q.push_back(tmp_pkt);
            fsys_txn_q[txn_idx].rbr_rbid_q.push_back(-1);
            fsys_txn_q[txn_idx].str_subid_q.push_back(fsys_txn_q[txn_idx].cmd_req_subid_q[cmd_idx]);
            fsys_txn_q[txn_idx].rbr_rbid_val_q.push_back(0);
            fsys_txn_q[txn_idx].snoops_exp_q.push_back(0);
            fsys_txn_q[txn_idx].mrdreq_seen_q.push_back(0);
            fsys_txn_q[txn_idx].rbrreq_seen_q.push_back(0);
            fsys_txn_q[txn_idx].cmd_msg_id_q.push_back(m_pkt.smi_msg_id);
            fsys_txn_q[txn_idx].cmd_addr_q.push_back(m_pkt.smi_addr);
            fsys_txn_q[txn_idx].dce_queue_idx[cmd_idx] = (fsys_txn_q[txn_idx].cmd_msg_id_q.size()-1);
            fsys_txn_q[txn_idx].aiu_queue_idx.push_back(cmd_idx);

            // Remove CHI combined command from the order queue. Because CHI re-uses same OTT entry to reissue part-2
            if (fsys_txn_q[txn_idx].combined_cmd == 1) begin
               find_combined_q = cmdreq_order_uid_<%=pidx%>.find_index with (item == fsys_txn_q[txn_idx].fsys_unique_txn_id);
               if (find_combined_q.size() > 0) begin
                  cmdreq_order_uid_<%=pidx%>.delete(find_combined_q[0]);
                  cmdreq_order_idx_<%=pidx%>.delete(find_combined_q[0]);
               end
            end
            cmdreq_order_uid_<%=pidx%>.push_back(fsys_txn_q[txn_idx].fsys_unique_txn_id);
            cmdreq_order_idx_<%=pidx%>.push_back((fsys_txn_q[txn_idx].cmd_msg_id_q.size()-1));
            if (dce<%=pidx%>_env_pkg::dce_goldenref_model::cmdreq2owner_snp.exists(cmd_type)) begin
               fsys_txn_q[txn_idx].snp_msg_type_q.push_back(dce<%=pidx%>_env_pkg::dce_goldenref_model::cmdreq2owner_snp[cmd_type]);
            end else if (dce<%=pidx%>_env_pkg::dce_goldenref_model::cmdreq2stsh_snp.exists(cmd_type)) begin
               fsys_txn_q[txn_idx].snp_msg_type_q.push_back(dce<%=pidx%>_env_pkg::dce_goldenref_model::cmdreq2stsh_snp[cmd_type]);
            end else begin
               if (cmd_type inside {dce<%=pidx%>_smi_agent_pkg::eCmdWrBkFull, dce<%=pidx%>_smi_agent_pkg::eCmdWrBkPtl, 
                                    dce<%=pidx%>_smi_agent_pkg::eCmdWrNCPtl, dce<%=pidx%>_smi_agent_pkg::eCmdWrNCFull, 
                                    dce<%=pidx%>_smi_agent_pkg::eCmdWrClnFull, dce<%=pidx%>_smi_agent_pkg::eCmdWrClnPtl, 
                                    dce<%=pidx%>_smi_agent_pkg::eCmdEvict,  dce<%=pidx%>_smi_agent_pkg::eCmdWrEvict}
               ) begin
                  fsys_txn_q[txn_idx].snp_msg_type_q.push_back(0);
               end else begin
                  `uvm_error(`LABEL, $sformatf(
                     "FSYS_UID:%0d : Failed to find snoop msg type for cmd_req_type %0s", 
                     fsys_txn_q[txn_idx].fsys_unique_txn_id, cmd_type.name()))
               end
            end
            `uvm_info(`LABEL, $sformatf(
               "FSYS_UID:%0d : Snoop message type is: 0x%0h", fsys_txn_q[txn_idx].fsys_unique_txn_id, 
               fsys_txn_q[txn_idx].snp_msg_type_q[fsys_txn_q[txn_idx].snp_msg_type_q.size()-1]), 
               UVM_NONE+50)
            // These queues will have 1 entry per each CMDReq for this fsys_txn.
            fsys_txn_q[txn_idx].snpreq_cnt_q.push_back(0);
            fsys_txn_q[txn_idx].snprsp_cnt_q.push_back(0);
            fsys_txn_q[txn_idx].snpreq_msg_id_q.push_back(-1);
            fsys_txn_q[txn_idx].snpreq_did_q.push_back(-1);
            fsys_txn_q[txn_idx].dce_funitid_q.push_back(<%=obj.DceInfo[pidx].FUnitId%>);
            fsys_txn_q[txn_idx].snp_data_to_aiu_q.push_back(0);
            fsys_txn_q[txn_idx].internal_rbid_release_q.push_back(0);
            fsys_txn_q[txn_idx].snp_data_to_dmi_q.push_back(0);
            if ((m_pkt.smi_dest_id !== fsys_txn_q[txn_idx].dest_funit_id) && (fsys_txn_q[txn_idx].multi_cacheline_access == 0)) begin
               `uvm_error(`LABEL, $sformatf(
                  "FSYS_UID:%0d : DId(0x%0h) of CMDReq doesn't match this addr's(0x%0h) destination unit(0x%0h)", 
                  fsys_txn_q[txn_idx].fsys_unique_txn_id, 
                  m_pkt.smi_dest_id, m_pkt.smi_addr, 
                  fsys_txn_q[txn_idx].dest_funit_id))
            end // if DId doesn't match addr's matching DMI/DII
            match_found = 1;
            fsys_txn_q[txn_idx].cmd_req_val_q[cmd_idx] = 0;
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
// Function : smi_str_prediction
//
//====================================================================================================
function void fsys_scb_dce_predictor::smi_str_prediction_<%=pidx%>(input dce<%=pidx%>_smi_agent_pkg::smi_seq_item m_pkt, ref fsys_scb_txn fsys_txn_q[$]);
   `undef LABEL
   `define LABEL "smi_str_msg_dce<%=pidx%>"
   bit match_found = 0;
   int mem_region;
   bit wrunqfullstash = 0;
   int dce_idx = 0;
   foreach(fsys_txn_q[idx]) begin
      if (fsys_txn_q[idx].str_msg_id_q.size() > 0) begin
         foreach(fsys_txn_q[idx].str_msg_id_q[i]) begin
            if ((fsys_txn_q[idx].dce_funit_id == <%=obj.DceInfo[pidx].FUnitId%> || fsys_txn_q[idx].multi_cacheline_access == 1)
               && fsys_txn_q[idx].str_msg_id_val_q[i] == 1
               && fsys_txn_q[idx].str_msg_id_q[i] == m_pkt.smi_rmsg_id
               && fsys_txn_q[idx].str_unit_id_q[i] == m_pkt.smi_targ_ncore_unit_id) 
            begin
               if(fsys_txn_q[idx].multi_cacheline_access) begin
                  `uvm_info(`LABEL, $sformatf(
                     "FSYS_UID:%0d SUB_ID:%0d : SMI STR packet seen (DCE's FUnitId:'d<%=obj.DceInfo[pidx].FUnitId%>) %0s",
                     fsys_txn_q[idx].fsys_unique_txn_id, fsys_txn_q[idx].subid_q[i], m_pkt.convert2string()), UVM_NONE+50)
               end else begin
                  `uvm_info(`LABEL, $sformatf(
                     "FSYS_UID:%0d : SMI STR packet seen (DCE's FUnitId:'d<%=obj.DceInfo[pidx].FUnitId%>) %0s",
                     fsys_txn_q[idx].fsys_unique_txn_id, m_pkt.convert2string()), UVM_NONE+50)
               end
               //Check all snoops have seen their response. Dataless txn is an exeption?? (Confirm in spec)
               fsys_txn_q[idx].update_time_accessed();
               dce_idx = fsys_txn_q[idx].dce_queue_idx[i];
               if (!fsys_txn_q[idx].multi_cacheline_access) begin
                  fsys_txn_q[idx].smi_msg_order_q.push_back(smi_msgs_t'(fsys_coverage_pkg::STR_REQ));
               end
               if (fsys_txn_q[idx].snpreq_cnt_q[dce_idx] !== 0) begin // && fsys_txn_q[idx].is_dataless_txn == 0) begin
                  `uvm_warning(`LABEL, $sformatf("FSYS_UID:%0d : DCE STR was observed before receiving all SNPRsp. Pending SNPRspes for this addr are 'd%0d.", fsys_txn_q[idx].fsys_unique_txn_id, fsys_txn_q[idx].snpreq_cnt_q[dce_idx]))
               end else begin 
                  // Moved to AIUs STR function
                  //fsys_txn_q[idx].snpreq_msg_id_q[i] = -1;
               end

               <% for(var wr_stsh_idx = 0; wr_stsh_idx < _child_blkid.length; wr_stsh_idx++) { %>
               <%  if(_child_blk[wr_stsh_idx].match('chiaiu')) { %>
               if (fsys_txn_q[idx].m_chi_req_pkt_<%=wr_stsh_idx%> !== null) begin
                  if (fsys_txn_q[idx].m_chi_req_pkt_<%=wr_stsh_idx%>.opcode == 'h20
                     && fsys_txn_q[idx].stash_accept == 1) wrunqfullstash = 1;
               end
               <% } // if chiaui%>
               <% } // foreach aiu %>
               if (fsys_txn_q[idx].ioaiu_core_id >= 0  
                  && fsys_txn_q[idx].ace_command_type == "WRUNQFULLSTASH"
                  && fsys_txn_q[idx].stash_accept == 1) wrunqfullstash = 1;
               //Store these information for DTW matching
               if (fsys_txn_q[idx].is_write == 1 
                     && fsys_txn_q[idx].owo_write == 0
                     && fsys_txn_q[idx].mrd_possible_q[i] == 0  // This index i is already an aiu_index
                     && fsys_txn_q[idx].snp_data_to_aiu_q[dce_idx] == 0 
                     && fsys_txn_q[idx].dataless_wrunq_q[i] == 0
                     && fsys_txn_q[idx].is_atomic_txn == 0
                     && wrunqfullstash == 0
                  ) begin
                  fsys_txn_q[idx].rbid_val_q.push_back(1);
                  fsys_txn_q[idx].rbid_q.push_back(m_pkt.smi_rbid);
                  fsys_txn_q[idx].str_subid_q.push_back(fsys_txn_q[idx].subid_q[i]);
                  fsys_txn_q[idx].rbid_unit_id_q.push_back(ncoreConfigInfo::map_addr2dmi_or_dii(fsys_txn_q[idx].cmd_req_addr_q[i], mem_region));
                  fsys_txn_q[idx].snpdat_unit_id_q.push_back(-1);
                  fsys_txn_q[idx].snpsrc_unit_id_q.push_back(-1);
               end
               if (fsys_txn_q[idx].rbrreq_seen_q[dce_idx] == 0 && fsys_txn_q[idx].mrdreq_seen_q[dce_idx] == 0)
                  fsys_txn_q[idx].dce_check_done = 1;

               //`uvm_info(`LABEL, $sformatf("FSYS_UID:%0d : snpreq_cnt_q='d%0d, rbrreq_seen_q='d%0d, snp_data_to_dmi_q='d%0d, IDX='d%0d",fsys_txn_q[idx].fsys_unique_txn_id, fsys_txn_q[idx].snpreq_cnt_q[dce_idx], fsys_txn_q[idx].rbrreq_seen_q[dce_idx], fsys_txn_q[idx].snp_data_to_dmi_q[dce_idx], dce_idx), UVM_NONE+50)
               //Internal rbid release scenario
               if ((fsys_txn_q[idx].snpreq_cnt_q[dce_idx] == 0 || fsys_txn_q[idx].is_stash_txn == 1)
                  && fsys_txn_q[idx].rbrreq_seen_q[dce_idx] < 4 && fsys_txn_q[idx].rbrreq_seen_q[dce_idx] > 0
                  && fsys_txn_q[idx].snp_data_to_dmi_q[dce_idx] == 0) begin
                  fsys_txn_q[idx].rbuse_count++;
                  fsys_txn_q[idx].internal_rbuse_count++;
                  fsys_txn_q[idx].internal_rbid_release_q[dce_idx] = 1;
                  rbid_internally_released_<%=pidx%>.push_back(fsys_txn_q[idx].rbr_rbid_q[dce_idx]);
                  rbid_internally_released_dmiid_<%=pidx%>.push_back(fsys_txn_q[idx].cmd_did_q[dce_idx]);
                  if (fsys_txn_q[idx].exp_smi_data_pkts == 0 && fsys_txn_q[idx].dmi_check_done == 0) begin
                     fsys_txn_q[idx].dmi_check_done = 1;
                  end
                  `uvm_info(`LABEL, $sformatf(
                     "FSYS_UID:%0d : RBID:0x%0h. Marking this RBID as internally released. RBID: 0x%0h, DMIID=0x%0h, dceidx='d%0d",
                     fsys_txn_q[idx].fsys_unique_txn_id, m_pkt.smi_rbid, fsys_txn_q[idx].rbr_rbid_q[dce_idx], fsys_txn_q[idx].cmd_did_q[dce_idx], dce_idx), UVM_NONE+50)
               end
               // TODO: In eCmdMkUnq, I have seen DCE send only snps & then STR(No RBR). Set this higher number so this cmdreq won't match any other RBR in future
               // TODO: For stash, sometimes there is SNP, SNPRSP & then STR&RBR. Is this behavior correct?
               if (fsys_txn_q[idx].rbrreq_seen_q[dce_idx] == 0 && fsys_txn_q[idx].snprsp_cnt_q[dce_idx] > 0 
                  && fsys_txn_q[idx].is_stash_txn == 0 && fsys_txn_q[idx].ioaiu_core_id >= 0)
                  fsys_txn_q[idx].rbrreq_seen_q[dce_idx] = 4; // Set this to highest number so another's RBRReq Won't match by mistake
               if (fsys_txn_q[idx].rbuse_count == fsys_txn_q[idx].rbrsvd_count && fsys_txn_q[idx].snpreq_cnt_q[dce_idx] == 0) begin
                  fsys_txn_q[idx].dce_check_done = 1;
               end else begin
                  fsys_txn_q[idx].dce_check_done = 0;
               end
               // instead of deleting, maintain valid bit. These queues will be used for coverage collection.
               //fsys_txn_q[idx].str_msg_id_q.delete(i);
               //fsys_txn_q[idx].str_unit_id_q.delete(i);
               fsys_txn_q[idx].str_msg_id_val_q[i] = 0;
               match_found = 1;
               break;
            end
         end // foreach str_msg_id_q
      end // if str_msg_id_q not empty
      if (match_found == 1) break;
   end //foreach fsys_txn
   if (match_found == 0) begin
      `uvm_error(`LABEL, $sformatf(
         "FSYS_SCB: STRReq didn't match any pending transactions. %0s",
         m_pkt.convert2string()))
   end
endfunction : smi_str_prediction_<%=pidx%>

//====================================================================================================
//
// Function : smi_rbr_prediction
//
//====================================================================================================
function void fsys_scb_dce_predictor::smi_rbr_prediction_<%=pidx%>(input dce<%=pidx%>_smi_agent_pkg::smi_seq_item m_pkt, ref fsys_scb_txn fsys_txn_q[$]);
   `undef LABEL
   `define LABEL "smi_rbr_msg_dce<%=pidx%>"
   bit match_found = 0;
   int recall_idx;
   int find_q[$];
   int cmd_idx;
   dce<%=pidx%>_smi_agent_pkg::smi_seq_item tmp_pkt = dce<%=pidx%>_smi_agent_pkg::smi_seq_item::type_id::create("tmp_pkt");
   tmp_pkt.copy(m_pkt);
   //First delete all non-existing UIDs
   for(int idx = cmdreq_order_uid_<%=pidx%>.size()-1; idx >=0; idx--) begin
      find_q = fsys_txn_q.find_index with (item.fsys_unique_txn_id == cmdreq_order_uid_<%=pidx%>[idx]);
      if (find_q.size() == 0) begin
         cmdreq_order_uid_<%=pidx%>.delete(idx);
         cmdreq_order_idx_<%=pidx%>.delete(idx);
      end
   end
   find_q.delete();
   foreach(cmdreq_order_uid_<%=pidx%>[idx]) begin
      find_q = fsys_txn_q.find_index with (item.fsys_unique_txn_id == cmdreq_order_uid_<%=pidx%>[idx]);
      if (find_q.size() == 1) begin
         cmd_idx = cmdreq_order_idx_<%=pidx%>[idx];
         //`uvm_info(`LABEL, $sformatf(
         //    "FSYS_UID:%0d : addr=0x%0h, did=0x%0h, ca=0x%0h, ns=0x%0h,pr=0x%0h,qos=0x%0h,rbr_seen='d%0d,mrdseen='d%0d,is_write=0x%0h", 
         //    fsys_txn_q[find_q[0]].fsys_unique_txn_id,
         //    fsys_txn_q[find_q[0]].cmd_addr_q[cmd_idx], 
         //    fsys_txn_q[find_q[0]].cmd_did_q[cmd_idx], 
         //    fsys_txn_q[find_q[0]].cmd_req_pkt_<%=pidx%>_q[0].smi_ca, 
         //    fsys_txn_q[find_q[0]].cmd_req_pkt_<%=pidx%>_q[0].smi_ns, 
         //    fsys_txn_q[find_q[0]].cmd_req_pkt_<%=pidx%>_q[0].smi_pr, 
         //    fsys_txn_q[find_q[0]].cmd_req_pkt_<%=pidx%>_q[0].smi_qos,
         //    fsys_txn_q[find_q[0]].rbrreq_seen_q[cmd_idx], 
         //    fsys_txn_q[find_q[0]].mrdreq_seen_q[cmd_idx], 
         //    fsys_txn_q[find_q[0]].is_write), 
         //    UVM_NONE+50)
         if (fsys_txn_q[find_q[0]].cmd_addr_q[cmd_idx] == m_pkt.smi_addr
            && fsys_txn_q[find_q[0]].cmd_did_q[cmd_idx] == m_pkt.smi_targ_ncore_unit_id
            // Always using idx 0, because these fields don't change for entire txn. But if DCE changes, the indexes maynot match because this is DCE instance specific list
            <% if (obj.Widths.Concerto.Ndp.Body.wCA > 0) { %>
            && fsys_txn_q[find_q[0]].cmd_req_pkt_<%=pidx%>_q[0].smi_ca == m_pkt.smi_ca 
            <% } %>
            //<% if (obj.Widths.Concerto.Ndp.Body.wAC > 0) { %>
            //&& fsys_txn_q[find_q[0]].cmd_req_pkt_<%=pidx%>_q[0].smi_ac == m_pkt.smi_ac
            //<% } %>
            <% if (obj.wSecurityAttribute > 0) { %>
            && fsys_txn_q[find_q[0]].cmd_req_pkt_<%=pidx%>_q[0].smi_ns == m_pkt.smi_ns
            <% } %>
            <% if (obj.Widths.Concerto.Ndp.Body.wPR > 0) { %>
            && fsys_txn_q[find_q[0]].cmd_req_pkt_<%=pidx%>_q[0].smi_pr == m_pkt.smi_pr
            <% } %>
            //To filter out RBRs for recall
            <% if (obj.Widths.Concerto.Ndp.Body.wTof > 0) { %>
            && m_pkt.smi_tof !== 0
            <% } %>
            //TODO: WHY wasn't QoS same as CMDReq for CHI txns?
            <% if (obj.Widths.Concerto.Ndp.Body.wQos > 0) { %>
            && ((fsys_txn_q[find_q[0]].cmd_req_pkt_<%=pidx%>_q[0].smi_qos == m_pkt.smi_qos && m_pkt.smi_rtype == 1) 
               || m_pkt.smi_rtype == 0 )
            <% } %>
            && ((fsys_txn_q[find_q[0]].rbrreq_seen_q[cmd_idx] inside {0} && m_pkt.smi_rtype == 1)
               || (fsys_txn_q[find_q[0]].rbrreq_seen_q[cmd_idx] inside {1,2} && m_pkt.smi_rtype == 0))
            && (fsys_txn_q[find_q[0]].dce_funit_id == <%=obj.DceInfo[pidx].FUnitId%> || fsys_txn_q[find_q[0]].multi_cacheline_access == 1)
            && ((fsys_txn_q[find_q[0]].mrdreq_seen_q[cmd_idx] == 0 && m_pkt.smi_rtype == 1) || m_pkt.smi_rtype == 0)
            && ((fsys_txn_q[find_q[0]].str_msg_id_q[fsys_txn_q[find_q[0]].aiu_queue_idx[cmd_idx]] !== -1 && m_pkt.smi_rtype == 1) || (m_pkt.smi_rtype == 0))
            && ((m_pkt.smi_mw == 1 && fsys_txn_q[find_q[0]].is_write == 1) || (m_pkt.smi_mw == 0))
         ) begin
            if(fsys_txn_q[find_q[0]].multi_cacheline_access) begin
               `uvm_info(`LABEL, $sformatf(
                  "FSYS_UID:%0d SUB_ID:%0d : RBRReq(%0s) seen (DCE's FUnitId:'d<%=obj.DceInfo[pidx].FUnitId%>) %0s", 
                  fsys_txn_q[find_q[0]].fsys_unique_txn_id, fsys_txn_q[find_q[0]].subid_q[cmd_idx],
                  m_pkt.smi_rtype == 1 ? "reserve" : "release", 
                  m_pkt.convert2string()), UVM_NONE+50)
            end
            else begin
               `uvm_info(`LABEL, $sformatf(
                  "FSYS_UID:%0d : RBRReq(%0s) seen (DCE's FUnitId:'d<%=obj.DceInfo[pidx].FUnitId%>) %0s", 
                  fsys_txn_q[find_q[0]].fsys_unique_txn_id, m_pkt.smi_rtype == 1 ? "reserve" : "release", 
                  m_pkt.convert2string()), UVM_NONE+50)
            end
            check_for_reissue_<%=pidx%>(m_pkt.smi_rbid, m_pkt.smi_targ_ncore_unit_id);
            if (!fsys_txn_q[find_q[0]].multi_cacheline_access) begin
               fsys_txn_q[find_q[0]].smi_msg_order_q.push_back(smi_msgs_t'(fsys_coverage_pkg::RBR_REQ));
            end
            //for stash(stashonceunique) txns, sometimes DCE sends STR & RBR together after stash accepted. 
            //Handle RBID internal release for stash here if STR was already seen
            if (fsys_txn_q[find_q[0]].str_msg_id_val_q[fsys_txn_q[find_q[0]].aiu_queue_idx[cmd_idx]] == 0) begin
               fsys_txn_q[find_q[0]].rbuse_count++;
               fsys_txn_q[find_q[0]].internal_rbuse_count++;
               fsys_txn_q[find_q[0]].internal_rbid_release_q[cmd_idx] = 1;
               rbid_internally_released_<%=pidx%>.push_back(m_pkt.smi_rbid);
               rbid_internally_released_dmiid_<%=pidx%>.push_back(m_pkt.smi_targ_ncore_unit_id);
               if (fsys_txn_q[find_q[0]].exp_smi_data_pkts == 0 && fsys_txn_q[find_q[0]].dmi_check_done == 0) begin
                  fsys_txn_q[find_q[0]].dmi_check_done = 1;
               end
               `uvm_info(`LABEL, $sformatf(
                  "FSYS_UID:%0d : RBID:0x%0h. Marking this RBID as internally released.",
                  fsys_txn_q[find_q[0]].fsys_unique_txn_id, m_pkt.smi_rbid), UVM_NONE+50)
            end
            fsys_txn_q[find_q[0]].update_time_accessed();
            if (m_pkt.smi_rtype == 1) begin
               fsys_txn_q[find_q[0]].rbr_rbid_q[cmd_idx] = m_pkt.smi_rbid;
               fsys_txn_q[find_q[0]].rbr_rbid_val_q[cmd_idx] = 1;
               fsys_txn_q[find_q[0]].rbuse_seen = 0;
               fsys_txn_q[find_q[0]].rbrsvd_count++;
               fsys_txn_q[find_q[0]].rbrreq_seen_q[cmd_idx] = 1;
               fsys_txn_q[find_q[0]].dce_check_done = 0;
               fsys_txn_q[find_q[0]].snoops_exp_q[cmd_idx] = 1;
               fsys_txn_q[find_q[0]].snpreq_msg_id_q[cmd_idx] = m_pkt.smi_msg_id;
               fsys_txn_q[find_q[0]].snpreq_did_q[cmd_idx] = m_pkt.smi_targ_ncore_unit_id;
            end //Reserve command
            else begin
               //TODO: Error in Ncore3.6 onwards
               //Only free up the RBID if RBR Rsvd was seen by DMI.
               //if (fsys_txn_q[find_q[0]].rbrreq_seen_q[cmd_idx] == 2) begin
               fsys_txn_q[find_q[0]].rbr_rbid_val_q[cmd_idx] = 0; 
               //end
               fsys_txn_q[find_q[0]].rbrreq_seen_q[cmd_idx] = 3;
               if (fsys_txn_q[find_q[0]].snpreq_cnt_q[cmd_idx] == 0)
                  fsys_txn_q[find_q[0]].snpreq_msg_id_q[cmd_idx] = -1;
                  fsys_txn_q[find_q[0]].snpreq_did_q[cmd_idx] = -1;
               fsys_txn_q[find_q[0]].rbuse_count++;
               fsys_txn_q[find_q[0]].snoops_exp_q[cmd_idx] = 0;
               if (fsys_txn_q[find_q[0]].rbuse_count == fsys_txn_q[find_q[0]].rbrsvd_count && fsys_txn_q[find_q[0]].snpreq_cnt_q[cmd_idx] == 0) begin
                  fsys_txn_q[find_q[0]].dce_check_done = 1;
               end
               if (fsys_txn_q[find_q[0]].snp_data_to_aiu_q[cmd_idx] == 1) begin
                  fsys_txn_q[find_q[0]].mrd_possible_q[fsys_txn_q[find_q[0]].aiu_queue_idx[cmd_idx]] = 0;
               end
               //TODO: Change this uvm_info to error after rbr_release_exp variable is implemented
               if (fsys_txn_q[find_q[0]].rbr_release_exp == 0) begin
                  //`uvm_info(`LABEL, $sformatf(
                  //    "FSYS_UID:%0d : RBRReq(Release) is not expected for this transaction", 
                  //    fsys_txn_q[find_q[0]].fsys_unique_txn_id), UVM_NONE+50)
               end
            end
            //Check if any saved snpreq matches this packet
            for (int snp_idx = (tmp_snpreq_pkt_<%=pidx%>.size()-1); snp_idx >= 0; snp_idx--) begin
               if (m_pkt.smi_rtype == 1
                  && tmp_snpreq_pkt_<%=pidx%>[snp_idx].smi_rbid == m_pkt.smi_rbid
                  && tmp_snpreq_pkt_<%=pidx%>[snp_idx].smi_msg_id == m_pkt.smi_msg_id
                  && tmp_snpreq_pkt_<%=pidx%>[snp_idx].smi_src_ncore_unit_id == <%=obj.DceInfo[pidx].FUnitId%>
                  && tmp_snpreq_pkt_<%=pidx%>[snp_idx].smi_addr == m_pkt.smi_addr
               ) begin
                  `uvm_info(`LABEL, $sformatf(
                     "FSYS_UID:%0d : Matched a previously saved SNPReq to this UID (DCE's FUnitId:'d<%=obj.DceInfo[pidx].FUnitId%>) %0s",
                     fsys_txn_q[find_q[0]].fsys_unique_txn_id, tmp_snpreq_pkt_<%=pidx%>[snp_idx].convert2string()), UVM_NONE+50)
                  fsys_txn_q[find_q[0]].snpreq_cnt_q[0] = fsys_txn_q[find_q[0]].snpreq_cnt_q[0] + 1;
                  fsys_txn_q[find_q[0]].snpreq_msg_id_q[0] = tmp_snpreq_pkt_<%=pidx%>[snp_idx].smi_msg_id;
                  fsys_txn_q[find_q[0]].snpreq_did_q[0] = tmp_snpreq_pkt_<%=pidx%>[snp_idx].smi_dest_id;
                  fsys_txn_q[find_q[0]].snpreq_targ_id_q.push_back(tmp_snpreq_pkt_<%=pidx%>[snp_idx].smi_targ_ncore_unit_id);
                  fsys_txn_q[find_q[0]].snpreq_rbid_q.push_back(tmp_snpreq_pkt_<%=pidx%>[snp_idx].smi_rbid);
                  fsys_txn_q[find_q[0]].snpreq_src_id_q.push_back(tmp_snpreq_pkt_<%=pidx%>[snp_idx].smi_src_ncore_unit_id);
                  fsys_txn_q[find_q[0]].snpreq_addr_q.push_back(m_pkt.smi_addr);
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
                  fsys_txn_q[find_q[0]].ioaiu_snp_addr_seen_q.push_back(-1);
                  fsys_txn_q[find_q[0]].snp_chi_from_ioaiu_q.push_back(0);
                  // Concatenate msg_id and targ_id to create unique identifier to match SNPRsp
                  fsys_txn_q[find_q[0]].snpreq_unq_id_q.push_back({tmp_snpreq_pkt_<%=pidx%>[snp_idx].smi_targ_ncore_unit_id, tmp_snpreq_pkt_<%=pidx%>[snp_idx].smi_msg_id});
                  tmp_snpreq_pkt_<%=pidx%>.delete(snp_idx);
               end
               //else begin
               //   `uvm_error(`LABEL, $sformatf(
               //      "FSYS_SCB: Saved SNPReq didn't match any pending transactions. %0s",
               //      m_pkt.convert2string()))
               //end // saved snpreq didnt match recall
            end
            match_found = 1;
            break;
         end // if matched
      end // if UID match found
      else begin
         `uvm_error(`LABEL, $sformatf(
            "FSYS_SCB: Failed to find pending txn with FSYS_UID:%0d ", 
            cmdreq_order_uid_<%=pidx%>[idx]))
      end
      if (match_found == 1) break;
   end //foreach cmdreq_order_uid 
   if (match_found == 0) begin
      // This could be a recall
      match_found = 0;
      foreach (fsys_txn_q[idx]) begin
         if (fsys_txn_q[idx].rbr_rbid_q.size() > 0 && fsys_txn_q[idx].cmd_msg_id_q.size() == 0) begin
            foreach (fsys_txn_q[idx].rbr_rbid_q[i]) begin
               if (fsys_txn_q[idx].rbr_rbid_q[i] == m_pkt.smi_rbid
                  && fsys_txn_q[idx].rbr_rbid_val_q[i] == 1
                  && fsys_txn_q[idx].dce_funit_id == <%=obj.DceInfo[pidx].FUnitId%>
                  && fsys_txn_q[idx].rbrreq_seen_q[i] == 0
                  && fsys_txn_q[idx].recall_addr == m_pkt.smi_addr
                  && fsys_txn_q[idx].snpreq_msg_id_q[i] == m_pkt.smi_msg_id
               ) begin
                  `uvm_info(`LABEL, $sformatf(
                     "FSYS_UID:%0d : RBRReq(%0s) seen for recall (DCE's FUnitId:'d<%=obj.DceInfo[pidx].FUnitId%>) %0s", 
                     fsys_txn_q[idx].fsys_unique_txn_id, m_pkt.smi_rtype == 1 ? "reserve" : "release",
                     m_pkt.convert2string()), UVM_NONE+50)
                  fsys_txn_q[idx].rbuse_seen = 0;
                  fsys_txn_q[idx].rbrsvd_count++;
                  fsys_txn_q[idx].rbrreq_seen_q[i] = 1;
                  fsys_txn_q[idx].dce_check_done = 0;
                  fsys_txn_q[idx].snoops_exp_q[i] = 1;
                  fsys_txn_q[idx].snpreq_msg_id_q[i] = m_pkt.smi_msg_id;
                  fsys_txn_q[idx].snpreq_did_q[i] = m_pkt.smi_targ_ncore_unit_id;
                  fsys_txn_q[idx].cmd_did_q[i] = m_pkt.smi_targ_ncore_unit_id;
                  fsys_txn_q[idx].update_time_accessed();
                  match_found = 1;
                  break;
               end // if matched
            end // foreach rbr_rbid_q 
         end // if there are pending recalls 
         if (match_found == 1) break;
      end //foreach pending txn 
      if (match_found == 0) begin
         fsys_scb_txn m_txn = fsys_scb_txn::type_id::create("m_txn");
         m_txn.fsys_unique_txn_id = fsys_scoreboard::get_next_unique_txn_id();
         `uvm_info(`LABEL, $sformatf(
            "FSYS_UID:%0d : Adding a Recall to pending queue. RBRReq(%0s) DCE's FUnitId:'d<%=obj.DceInfo[pidx].FUnitId%> %0s", 
            m_txn.fsys_unique_txn_id, m_pkt.smi_rtype == 1 ? "reserve" : "release", m_pkt.convert2string()), UVM_NONE+50)
         m_txn.recall_addr = m_pkt.smi_addr;
         check_for_reissue_<%=pidx%>(m_pkt.smi_rbid, m_pkt.smi_targ_ncore_unit_id);
         m_txn.rbrsvd_count++;
         m_txn.rbr_rbid_q.push_back(m_pkt.smi_rbid);
         m_txn.str_subid_q.push_back(0);
         m_txn.rbr_rbid_val_q.push_back(1);
         m_txn.cmd_did_q.push_back(m_pkt.smi_targ_ncore_unit_id);
         //m_txn.smi_vz_ca_ac_ns_pr_qos_q.push_back({m_pkt.smi_vz, m_pkt.smi_ca, m_pkt.smi_ac, m_pkt.smi_ns, m_pkt.smi_pr, m_pkt.smi_qos});
         m_txn.cmd_req_pkt_<%=pidx%>_q.push_back(tmp_pkt);
         m_txn.rbrreq_seen_q.push_back(1);
         m_txn.snoops_exp_q.push_back(1);
         m_txn.snpreq_cnt_q.push_back(0);
         m_txn.snpreq_msg_id_q.push_back(m_pkt.smi_msg_id);
         m_txn.snpreq_did_q.push_back(m_pkt.smi_targ_ncore_unit_id);
         m_txn.dce_funitid_q.push_back(<%=obj.DceInfo[pidx].FUnitId%>);
         m_txn.internal_rbid_release_q.push_back(0);
         m_txn.snp_data_to_dmi_q.push_back(0);
         m_txn.snp_data_to_aiu_q.push_back(0);
         m_txn.dce_funit_id = <%=obj.DceInfo[pidx].FUnitId%>;
         m_txn.update_time_accessed();
         fsys_txn_q.push_back(m_txn);
         recall_idx = fsys_txn_q.size() - 1;
         //Check if any saved snpreq matches this packet
         //if (tmp_snpreq_pkt_<%=pidx%> !== null) begin
         for (int snp_idx = (tmp_snpreq_pkt_<%=pidx%>.size()-1); snp_idx >= 0; snp_idx--) begin
            if (tmp_snpreq_pkt_<%=pidx%>[snp_idx].smi_rbid == m_pkt.smi_rbid
                  && tmp_snpreq_pkt_<%=pidx%>[snp_idx].smi_src_ncore_unit_id == <%=obj.DceInfo[pidx].FUnitId%>
                  && tmp_snpreq_pkt_<%=pidx%>[snp_idx].smi_addr == m_pkt.smi_addr
            ) begin
               `uvm_info(`LABEL, $sformatf(
                  "FSYS_UID:%0d : Matched a previously saved SNPReq to this recall (DCE's FUnitId:'d<%=obj.DceInfo[pidx].FUnitId%>) %0s",
                  fsys_txn_q[recall_idx].fsys_unique_txn_id, tmp_snpreq_pkt_<%=pidx%>[snp_idx].convert2string()), UVM_NONE+50)
               fsys_txn_q[recall_idx].update_time_accessed(); //Check if this is redundant 
               fsys_txn_q[recall_idx].snpreq_cnt_q[0] = fsys_txn_q[recall_idx].snpreq_cnt_q[0] + 1;
               fsys_txn_q[recall_idx].snpreq_msg_id_q[0] = tmp_snpreq_pkt_<%=pidx%>[snp_idx].smi_msg_id;
               fsys_txn_q[recall_idx].snpreq_did_q[0] = tmp_snpreq_pkt_<%=pidx%>[snp_idx].smi_dest_id;
               fsys_txn_q[recall_idx].snpreq_targ_id_q.push_back(tmp_snpreq_pkt_<%=pidx%>[snp_idx].smi_targ_ncore_unit_id);
               fsys_txn_q[recall_idx].snpreq_rbid_q.push_back(tmp_snpreq_pkt_<%=pidx%>[snp_idx].smi_rbid);
               fsys_txn_q[recall_idx].snpreq_src_id_q.push_back(tmp_snpreq_pkt_<%=pidx%>[snp_idx].smi_src_ncore_unit_id);
               fsys_txn_q[recall_idx].snpreq_addr_q.push_back(m_pkt.smi_addr);
               fsys_txn_q[recall_idx].chi_snp_txnid_q.push_back(-1);
               fsys_txn_q[recall_idx].chi_snp_data_count_q.push_back(-1);
               fsys_txn_q[recall_idx].snp_up_q.push_back(2'b00);
               fsys_txn_q[recall_idx].read_acc_dtr_exp_q.push_back(0);
               fsys_txn_q[recall_idx].read_acc_dtr_tgtid_q.push_back(0);
               fsys_txn_q[recall_idx].read_acc_dtr_msgid_q.push_back(-1);
               fsys_txn_q[recall_idx].snp_ioaiu_from_chi_q.push_back(0);
               fsys_txn_q[recall_idx].ioaiu_snprsp_exp_q.push_back(0);
               fsys_txn_q[recall_idx].ioaiu_snpdat_exp_q.push_back(0);
               fsys_txn_q[recall_idx].ioaiu_snp_data_seen_q.push_back(0);
               fsys_txn_q[recall_idx].ioaiu_snp_addr_seen_q.push_back(-1);
               fsys_txn_q[recall_idx].snp_chi_from_ioaiu_q.push_back(0);
               // Concatenate msg_id and targ_id to create unique identifier to match SNPRsp
               fsys_txn_q[recall_idx].snpreq_unq_id_q.push_back({tmp_snpreq_pkt_<%=pidx%>[snp_idx].smi_targ_ncore_unit_id, tmp_snpreq_pkt_<%=pidx%>[snp_idx].smi_msg_id});
               tmp_snpreq_pkt_<%=pidx%>.delete(snp_idx);
            end
         end 
      end // RBRReq Reserve seen, add a recall transaction to queue
   end

endfunction : smi_rbr_prediction_<%=pidx%>

//====================================================================================================
//
// Function : smi_mrd_prediction
//
//====================================================================================================
function void fsys_scb_dce_predictor::smi_mrd_prediction_<%=pidx%>(input dce<%=pidx%>_smi_agent_pkg::smi_seq_item m_pkt, ref fsys_scb_txn fsys_txn_q[$]);
   `undef LABEL
   `define LABEL "smi_mrd_msg_dce<%=pidx%>"
   bit match_found = 0;
   int find_q[$];
   int cmd_idx;
   //First delete all non-existing UIDs
   for(int idx = cmdreq_order_uid_<%=pidx%>.size()-1; idx >=0; idx--) begin
      find_q = fsys_txn_q.find_index with (item.fsys_unique_txn_id == cmdreq_order_uid_<%=pidx%>[idx]);
      if (find_q.size() == 0) begin
         cmdreq_order_uid_<%=pidx%>.delete(idx);
         cmdreq_order_idx_<%=pidx%>.delete(idx);
      end
   end
   find_q.delete();
   foreach(cmdreq_order_uid_<%=pidx%>[idx]) begin
      find_q = fsys_txn_q.find_index with (item.fsys_unique_txn_id == cmdreq_order_uid_<%=pidx%>[idx]);
      if (find_q.size() == 1) begin
            cmd_idx = cmdreq_order_idx_<%=pidx%>[idx];
            //`uvm_info(`LABEL, $psprintf(
            //    "FSYS_UID:%0d : cmd_addr_q[%0d]=0x%0h. did = %0h, dce_funit_id = 'd%0d, srcid= 0x%0h, cmd_msg_id=0x%0h, mrdreq_seen_q=0x%0h, m_pkt.smi_targ_ncore_unit_id=%0h, stash_nid=%0d, smi_stash_dtr_msg_id=0x%0h, stash_Accept=%0d, mrd_possible=0x%0h, aiu_queue_idx[cmd_idx]='d%0d", 
            //    fsys_txn_q[find_q[0]].fsys_unique_txn_id, cmd_idx, 
            //    fsys_txn_q[find_q[0]].cmd_addr_q[cmd_idx], 
            //    fsys_txn_q[find_q[0]].cmd_did_q[cmd_idx], 
            //    fsys_txn_q[find_q[0]].dce_funitid_q[cmd_idx], 
            //    fsys_txn_q[find_q[0]].smi_src_ncore_unit_id, 
            //    fsys_txn_q[find_q[0]].cmd_msg_id_q[cmd_idx], 
            //    fsys_txn_q[find_q[0]].mrdreq_seen_q[cmd_idx], 
            //    m_pkt.smi_targ_ncore_unit_id, 
            //    fsys_txn_q[find_q[0]].smi_stash_nid, 
            //    fsys_txn_q[find_q[0]].smi_stash_dtr_msg_id, 
            //    fsys_txn_q[find_q[0]].stash_accept, 
            //    fsys_txn_q[find_q[0]].mrd_possible_q[fsys_txn_q[find_q[0]].aiu_queue_idx[cmd_idx]],
            //    fsys_txn_q[find_q[0]].aiu_queue_idx[cmd_idx]), 
            //    UVM_NONE+50)
            if (fsys_txn_q[find_q[0]].cmd_addr_q[cmd_idx] == m_pkt.smi_addr
               && fsys_txn_q[find_q[0]].cmd_did_q[cmd_idx] == m_pkt.smi_targ_ncore_unit_id
               <% if (obj.wSecurityAttribute > 0) { %>
               && fsys_txn_q[find_q[0]].smi_ns == m_pkt.smi_ns 
               <% } %>
               <% if (obj.Widths.Concerto.Ndp.Body.wPR > 0) { %>
               && fsys_txn_q[find_q[0]].smi_pr == m_pkt.smi_pr 
               <% } %>
               && (fsys_txn_q[find_q[0]].dce_funitid_q[cmd_idx] == <%=obj.DceInfo[pidx].FUnitId%>)
               && (fsys_txn_q[find_q[0]].smi_src_ncore_unit_id == m_pkt.smi_mpf1_dtr_tgt_id 
                  || (fsys_txn_q[find_q[0]].is_stash_txn == 1 && m_pkt.smi_mpf1_dtr_tgt_id == fsys_txn_q[find_q[0]].smi_stash_nid))
               && ((fsys_txn_q[find_q[0]].is_stash_txn == 0 && fsys_txn_q[find_q[0]].cmd_msg_id_q[cmd_idx] == m_pkt.smi_mpf2_dtr_msg_id && m_pkt.smi_msg_type !== dce<%=pidx%>_smi_agent_pkg::MRD_PREF)
                  || (fsys_txn_q[find_q[0]].is_stash_txn == 1 && fsys_txn_q[find_q[0]].stash_accept == 0 && m_pkt.smi_msg_type == dce<%=pidx%>_smi_agent_pkg::MRD_PREF && m_pkt.smi_msg_pri == fsys_txn_q[find_q[0]].smi_pri)
                  || (fsys_txn_q[find_q[0]].stash_accept == 1 && fsys_txn_q[find_q[0]].smi_stash_dtr_msg_id == m_pkt.smi_mpf2_dtr_msg_id))
               && fsys_txn_q[find_q[0]].mrdreq_seen_q[cmd_idx] == 0
               && fsys_txn_q[find_q[0]].mrd_possible_q[fsys_txn_q[find_q[0]].aiu_queue_idx[cmd_idx]] == 1
            ) begin
               `uvm_info(`LABEL, $sformatf(
                  "FSYS_UID:%0d : MRDReq seen (DCE's FUnitId:'d<%=obj.DceInfo[pidx].FUnitId%>) %0s",
                  fsys_txn_q[find_q[0]].fsys_unique_txn_id, m_pkt.convert2string()), UVM_NONE+50)
               if (!fsys_txn_q[find_q[0]].multi_cacheline_access) begin
                  fsys_txn_q[find_q[0]].smi_msg_order_q.push_back(smi_msgs_t'(fsys_coverage_pkg::MRD_REQ));
               end
               //Check all snoops have seen their response
               //CCMP Spec (version NCore3.6 98) section 4.9.1
               //(MrdReq is generated) In response to a Read command after the DCE has concluded that the data will not provided to the 
               // requester by a snooper. This determination may be based on the SNPrspmessages received from 
               // the snoopers or may be based on the inspection of the states of the cacheline in various potential 
               // snoopers as reflected in thedirectory.

               // Based on above spec reference, this check is not relevant, DCE can send Mrd without waitinf for SnpRspes.
               //if (fsys_txn_q[find_q[0]].snpreq_cnt_q[cmd_idx] !== 0) begin
               //   `uvm_error(`LABEL, $sformatf(
               //      "FSYS_UID:%0d : DCE MRDReq was observed before receiving all SNPRsp. Pending SNPRspes for this addr are 'd%0d.", 
               //      fsys_txn_q[find_q[0]].fsys_unique_txn_id, 
               //      fsys_txn_q[find_q[0]].snpreq_cnt_q[cmd_idx]))
               //end
               if (fsys_txn_q[find_q[0]].rbrreq_seen_q[cmd_idx] == 0)
                  fsys_txn_q[find_q[0]].rbrreq_seen_q[cmd_idx] = 4; // Set this to highest number so another's RBRReq Won't match by mistake
               fsys_txn_q[find_q[0]].update_time_accessed();
               match_found = 1;
               fsys_txn_q[find_q[0]].mrdreq_seen_q[cmd_idx] = 1;
               //if (fsys_txn_q[find_q[0]].rbuse_count == fsys_txn_q[find_q[0]].rbrsvd_count && fsys_txn_q[find_q[0]].snpreq_cnt_q[cmd_idx] == 0) begin
               if (fsys_txn_q[find_q[0]].snpreq_cnt_q[cmd_idx] == 0) begin
                  fsys_txn_q[find_q[0]].dce_check_done = 1;
               end
               if (fsys_txn_q[find_q[0]].rbrreq_seen_q[cmd_idx] == 0 || fsys_txn_q[find_q[0]].rbrreq_seen_q[cmd_idx] > 2) begin
                  cmdreq_order_uid_<%=pidx%>.delete(idx);
                  cmdreq_order_idx_<%=pidx%>.delete(idx); 
               end
               break;
            end // if matched
      end // UID match found 
      if (match_found == 1) break;
   end //foreach cmdreq_order_uid_<%=pidx%>
   if (match_found == 0) begin
      `uvm_error(`LABEL, $sformatf(
         "FSYS_SCB: MRDReq didn't match any pending transactions. %0s", 
         m_pkt.convert2string()))
   end
endfunction : smi_mrd_prediction_<%=pidx%>

//====================================================================================================
//
// Function : smi_snpreq_prediction
//
//====================================================================================================
function void fsys_scb_dce_predictor::smi_snpreq_prediction_<%=pidx%>(input dce<%=pidx%>_smi_agent_pkg::smi_seq_item m_pkt, ref fsys_scb_txn fsys_txn_q[$]);
   `undef LABEL
   `define LABEL "smi_snpreq_dce<%=pidx%>"
   bit match_found = 0;
   int find_q[$];
   int cmd_idx;
   dce<%=pidx%>_smi_agent_pkg::smi_seq_item tmp_pkt = dce<%=pidx%>_smi_agent_pkg::smi_seq_item::type_id::create("tmp_pkt");
   tmp_pkt.copy(m_pkt);
   // START - Unit attached state check
   find_q = attached_funit_ids_<%=pidx%>.find_index with(item == m_pkt.smi_targ_ncore_unit_id);
   if (find_q.size() == 0) begin
      `uvm_error(`LABEL, $sformatf(
         "FSYS_SCB: Snoop sent to funit_id 0x%0h, which is not attached to this DCE. SMI pkt: %0s", 
         m_pkt.smi_targ_ncore_unit_id, m_pkt.convert2string()))
   end
   find_q.delete();
   // END - Unit attached state check
   foreach(cmdreq_order_uid_<%=pidx%>[idx]) begin
      find_q = fsys_txn_q.find_index with (item.fsys_unique_txn_id == cmdreq_order_uid_<%=pidx%>[idx]);
      if (find_q.size() == 1) begin
         if (fsys_txn_q[find_q[0]].cmd_did_q.size() > cmdreq_order_idx_<%=pidx%>[idx]) begin
            cmd_idx = cmdreq_order_idx_<%=pidx%>[idx];
            //`uvm_info(`LABEL, $psprintf(
            //    "FSYS_UID:%0d : cmd_addr_q[%0d]=0x%0h. snpreq_cnt = 'd%0d. fsys_txn_q[find_q[0]].snpreq_msg_id[cmd_idx] = 0x%0h, snoops exp = 'd%0d", 
            //    fsys_txn_q[find_q[0]].fsys_unique_txn_id, 
            //    cmd_idx, 
            //    fsys_txn_q[find_q[0]].cmd_addr_q[cmd_idx],
            //    fsys_txn_q[find_q[0]].snpreq_cnt_q[cmd_idx], 
            //    fsys_txn_q[find_q[0]].snpreq_msg_id_q[cmd_idx],
            //    fsys_txn_q[find_q[0]].snoops_exp_q[cmd_idx]), 
            //    UVM_NONE+50)
            if (fsys_txn_q[find_q[0]].cmd_addr_q[cmd_idx] == m_pkt.smi_addr
               //Due to NCOR-199, the VZ bit is changing in each cmdreq of multi cacheline txn.
               //Understand this VZ bit changes in multiline txns & implement accordingly
               //commenting out for now
               //<% if (obj.Widths.Concerto.Ndp.Body.wVZ > 0) { %>
               //&& fsys_txn_q[find_q[0]].cmd_req_pkt_<%=pidx%>_q[0].smi_vz == m_pkt.smi_vz
               //<% } %>
               <% if (obj.Widths.Concerto.Ndp.Body.wCA > 0) { %>
               && fsys_txn_q[find_q[0]].cmd_req_pkt_<%=pidx%>_q[0].smi_ca == m_pkt.smi_ca
               <% } %>
               //<% if (obj.Widths.Concerto.Ndp.Body.wAC > 0) { %>
               //&& fsys_txn_q[find_q[0]].cmd_req_pkt_<%=pidx%>_q[0].smi_ac == m_pkt.smi_ac
               //<% } %>
               <% if (obj.wSecurityAttribute > 0) { %>
               && fsys_txn_q[find_q[0]].cmd_req_pkt_<%=pidx%>_q[0].smi_ns == m_pkt.smi_ns
               <% } %>
               <% if (obj.Widths.Concerto.Ndp.Body.wPR > 0) { %>
               && fsys_txn_q[find_q[0]].cmd_req_pkt_<%=pidx%>_q[0].smi_pr == m_pkt.smi_pr
               <% } %>
               <% if (obj.Widths.Concerto.Ndp.Body.wQos > 0) { %>
               && (fsys_txn_q[find_q[0]].cmd_req_pkt_<%=pidx%>_q[0].smi_qos == m_pkt.smi_qos) 
               <% } %>
               //To filter out SNPs for recall
               <% if (obj.Widths.Concerto.Ndp.Body.wTof > 0) { %>
               && m_pkt.smi_tof !== 0
               <% } %>
               && (fsys_txn_q[find_q[0]].mrdreq_seen_q[cmd_idx] == 0 || fsys_txn_q[find_q[0]].is_stash_txn == 1)
               && fsys_txn_q[find_q[0]].only_waiting_for_mrd == 0
               //&& fsys_txn_q[find_q[0]].rbrreq_seen_q[cmd_idx] < 3 // Either RBRsvd seen or not seen. But not seen RBUse/Release
               && fsys_txn_q[find_q[0]].snp_msg_type_q[cmd_idx] == m_pkt.smi_msg_type
               && fsys_txn_q[find_q[0]].only_mrd_pref_possible == 0
               && ((m_pkt.smi_mpf2_stash_valid == 1 && fsys_txn_q[find_q[0]].smi_stash_lpid == m_pkt.smi_mpf2_stash_lpid) || m_pkt.smi_mpf2_stash_valid == 0)
               && ((m_pkt.smi_mpf1_stash_valid == 1 && fsys_txn_q[find_q[0]].smi_stash_nid == m_pkt.smi_mpf1_stash_nid) || m_pkt.smi_mpf1_stash_valid == 0)
               //&& fsys_txn_q[find_q[0]].snoops_exp_q[cmd_idx] == 1 -- not really true to see rbr and then snp
               && ((fsys_txn_q[find_q[0]].snpreq_cnt_q[cmd_idx] == 0 && fsys_txn_q[find_q[0]].snprsp_cnt_q[cmd_idx] == 0 && fsys_txn_q[find_q[0]].str_msg_id_q[fsys_txn_q[find_q[0]].aiu_queue_idx[cmd_idx]] !== -1)
                  || (((fsys_txn_q[find_q[0]].snpreq_cnt_q[cmd_idx] + fsys_txn_q[find_q[0]].snprsp_cnt_q[cmd_idx]) > 0) && fsys_txn_q[find_q[0]].snpreq_msg_id_q[cmd_idx] == m_pkt.smi_msg_id))
            ) begin
               if(fsys_txn_q[find_q[0]].multi_cacheline_access) begin
                  `uvm_info(`LABEL, $sformatf(
                     "FSYS_UID:%0d SUB_ID:%0d: SNPReq seen (DCE's FUnitId:'d<%=obj.DceInfo[pidx].FUnitId%>) %0s", 
                     fsys_txn_q[find_q[0]].fsys_unique_txn_id, fsys_txn_q[find_q[0]].cmd_req_subid_q[cmd_idx],
                     m_pkt.convert2string()), UVM_NONE+50)
               end else begin
                  `uvm_info(`LABEL, $sformatf(
                     "FSYS_UID:%0d : SNPReq seen (DCE's FUnitId:'d<%=obj.DceInfo[pidx].FUnitId%>) %0s", 
                     fsys_txn_q[find_q[0]].fsys_unique_txn_id, m_pkt.convert2string()), UVM_NONE+50)
               end
               if (!fsys_txn_q[find_q[0]].multi_cacheline_access && fsys_txn_q[find_q[0]].snpreq_cnt_q[cmd_idx] == 0) begin
                  fsys_txn_q[find_q[0]].smi_msg_order_q.push_back(smi_msgs_t'(fsys_coverage_pkg::SNP_REQ));
               end
               fsys_txn_q[find_q[0]].snpreq_cnt_q[cmd_idx] = fsys_txn_q[find_q[0]].snpreq_cnt_q[cmd_idx] + 1;
               // Assign RBID if snoop is seen before RBRReq. This RBID is only valid if RBuse isn't seen yet.
               if (fsys_txn_q[find_q[0]].rbr_rbid_q[cmd_idx] == -1 && fsys_txn_q[find_q[0]].rbrreq_seen_q[cmd_idx] < 4) begin
                  fsys_txn_q[find_q[0]].rbr_rbid_q[cmd_idx] = m_pkt.smi_rbid;
               end
               fsys_txn_q[find_q[0]].snpreq_msg_id_q[cmd_idx] = m_pkt.smi_msg_id;
               fsys_txn_q[find_q[0]].snpreq_did_q[cmd_idx] = m_pkt.smi_dest_id;
               fsys_txn_q[find_q[0]].snpreq_targ_id_q.push_back(m_pkt.smi_targ_ncore_unit_id);
               fsys_txn_q[find_q[0]].snpreq_rbid_q.push_back(m_pkt.smi_rbid);
               fsys_txn_q[find_q[0]].snpreq_src_id_q.push_back(m_pkt.smi_src_ncore_unit_id);
               fsys_txn_q[find_q[0]].snpreq_addr_q.push_back(m_pkt.smi_addr);
               fsys_txn_q[find_q[0]].snpreq_ns_q.push_back(m_pkt.smi_ns);
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
               fsys_txn_q[find_q[0]].ioaiu_snp_addr_seen_q.push_back(-1);
               fsys_txn_q[find_q[0]].snp_chi_from_ioaiu_q.push_back(0);
               // Concatenate msg_id and targ_id to create unique identifier to match SNPRsp
               fsys_txn_q[find_q[0]].snpreq_unq_id_q.push_back({m_pkt.smi_targ_ncore_unit_id, m_pkt.smi_msg_id});
               fsys_txn_q[find_q[0]].update_time_accessed();
               match_found = 1;
               // TODO: match mpf1, mpf2 & mpf3 in specific snp types.
               //fsys_txn_q[find_q[0]].cmd_msg_id_q[cmd_idx] == m_pkt.smi_mpf2 
               //&& m_pkt.smi_src_ncore_unit_id == m_pkt.smi_mpf1
               break;
            end // if matched
         end // foreach CMDReq
      end // if there are pending CMDReqs
      if (match_found == 1) break;
   end //foreach pending txn 
   if (match_found == 0) begin
      // This could be SNP for Recall
      match_found = 0;
      foreach (fsys_txn_q[idx]) begin
         if (fsys_txn_q[idx].rbr_rbid_q.size() > 0 && fsys_txn_q[idx].cmd_msg_id_q.size() == 0) begin
            foreach (fsys_txn_q[idx].rbr_rbid_q[i]) begin
               if (fsys_txn_q[idx].rbr_rbid_q[i] == m_pkt.smi_rbid
                  && fsys_txn_q[idx].rbr_rbid_val_q[i] == 1
                  && fsys_txn_q[idx].dce_funit_id == <%=obj.DceInfo[pidx].FUnitId%>
                  && fsys_txn_q[idx].recall_addr == m_pkt.smi_addr
                  && fsys_txn_q[idx].snpreq_msg_id_q[i] == m_pkt.smi_msg_id
               ) begin
                  `uvm_info(`LABEL, $sformatf(
                     "FSYS_UID:%0d : SNPReq seen for recall (DCE's FUnitId:'d<%=obj.DceInfo[pidx].FUnitId%>) %0s",
                     fsys_txn_q[idx].fsys_unique_txn_id, m_pkt.convert2string()), UVM_NONE+50)
                  fsys_txn_q[idx].snpreq_cnt_q[i] = fsys_txn_q[idx].snpreq_cnt_q[i] + 1;
                  fsys_txn_q[idx].snpreq_msg_id_q[i] = m_pkt.smi_msg_id;
                  fsys_txn_q[idx].snpreq_did_q[i] = m_pkt.smi_dest_id;
                  fsys_txn_q[idx].snpreq_targ_id_q.push_back(m_pkt.smi_targ_ncore_unit_id);
                  fsys_txn_q[idx].snpreq_rbid_q.push_back(m_pkt.smi_rbid);
                  fsys_txn_q[idx].snpreq_src_id_q.push_back(m_pkt.smi_src_ncore_unit_id);
                  fsys_txn_q[idx].snpreq_addr_q.push_back(m_pkt.smi_addr);
                  fsys_txn_q[idx].snpreq_ns_q.push_back(m_pkt.smi_ns);
                  fsys_txn_q[idx].chi_snp_txnid_q.push_back(-1);
                  fsys_txn_q[idx].chi_snp_data_count_q.push_back(-1);
                  fsys_txn_q[idx].snp_up_q.push_back(2'b00);
                  fsys_txn_q[idx].read_acc_dtr_exp_q.push_back(0);
                  fsys_txn_q[idx].read_acc_dtr_tgtid_q.push_back(0);
                  fsys_txn_q[idx].read_acc_dtr_msgid_q.push_back(-1);
                  fsys_txn_q[idx].snp_ioaiu_from_chi_q.push_back(0);
                  fsys_txn_q[idx].ioaiu_snprsp_exp_q.push_back(0);
                  fsys_txn_q[idx].ioaiu_snpdat_exp_q.push_back(0);
                  fsys_txn_q[idx].ioaiu_snp_data_seen_q.push_back(0);
                  fsys_txn_q[idx].ioaiu_snp_addr_seen_q.push_back(-1);
                  fsys_txn_q[idx].snp_chi_from_ioaiu_q.push_back(0);
                  // Concatenate msg_id and targ_id to create unique identifier to match SNPRsp
                  fsys_txn_q[idx].snpreq_unq_id_q.push_back({m_pkt.smi_targ_ncore_unit_id, m_pkt.smi_msg_id});
                  fsys_txn_q[idx].update_time_accessed();
                  match_found = 1;
                  break;
               end // if matched
            end // foreach CMDReq DID
         end // if there are pending recalls 
         if (match_found == 1) break;
      end //foreach pending txn 
      if (match_found == 0) begin
         fsys_scb_txn m_txn = fsys_scb_txn::type_id::create("m_txn");
         m_txn.fsys_unique_txn_id = fsys_scoreboard::get_next_unique_txn_id();
         `uvm_info(`LABEL, $sformatf(
            "FSYS_UID:%0d : Adding a Recall to pending queue. SnpReq. DCE's FUnitId:'d<%=obj.DceInfo[pidx].FUnitId%> %0s", 
            m_txn.fsys_unique_txn_id, m_pkt.convert2string()), UVM_NONE+50)
         m_txn.recall_addr = m_pkt.smi_addr;
         //tmp_snpreq_pkt_<%=pidx%>.push_back(m_pkt);
         //`uvm_info(`LABEL, $sformatf(
         //   "Possible SNPReq for recall. Saving this packet to be matched to a later RBR(Reserve) packet. %0s", 
         //   m_pkt.convert2string()), UVM_NONE+50)
         m_txn.recall_addr = m_pkt.smi_addr;
         m_txn.rbrsvd_count++;
         m_txn.rbr_rbid_q.push_back(m_pkt.smi_rbid);
         m_txn.str_subid_q.push_back(0);
         m_txn.rbr_rbid_val_q.push_back(1);
         m_txn.cmd_did_q.push_back(m_pkt.smi_dest_id);
         //m_txn.smi_vz_ca_ac_ns_pr_qos_q.push_back({m_pkt.smi_vz, m_pkt.smi_ca, m_pkt.smi_ac, m_pkt.smi_ns, m_pkt.smi_pr, m_pkt.smi_qos});
         m_txn.cmd_req_pkt_<%=pidx%>_q.push_back(tmp_pkt);
         m_txn.rbrreq_seen_q.push_back(0);
         m_txn.snoops_exp_q.push_back(1);
         m_txn.snpreq_cnt_q.push_back(1);
         m_txn.snpreq_msg_id_q.push_back(m_pkt.smi_msg_id);
         m_txn.snpreq_did_q.push_back(m_pkt.smi_targ_ncore_unit_id);
         m_txn.dce_funitid_q.push_back(<%=obj.DceInfo[pidx].FUnitId%>);
         m_txn.internal_rbid_release_q.push_back(0);
         m_txn.snp_data_to_dmi_q.push_back(0);
         m_txn.snp_data_to_aiu_q.push_back(0);
         m_txn.dce_funit_id = <%=obj.DceInfo[pidx].FUnitId%>;

         m_txn.snpreq_targ_id_q.push_back(m_pkt.smi_targ_ncore_unit_id);
         m_txn.snpreq_rbid_q.push_back(m_pkt.smi_rbid);
         m_txn.snpreq_src_id_q.push_back(m_pkt.smi_src_ncore_unit_id);
         m_txn.snpreq_addr_q.push_back(m_pkt.smi_addr);
         m_txn.snpreq_ns_q.push_back(m_pkt.smi_ns);
         m_txn.chi_snp_txnid_q.push_back(-1);
         m_txn.chi_snp_data_count_q.push_back(-1);
         m_txn.snp_up_q.push_back(2'b00);
         m_txn.read_acc_dtr_exp_q.push_back(0);
         m_txn.read_acc_dtr_tgtid_q.push_back(0);
         m_txn.read_acc_dtr_msgid_q.push_back(-1);
         m_txn.snp_ioaiu_from_chi_q.push_back(0);
         m_txn.ioaiu_snprsp_exp_q.push_back(0);
         m_txn.ioaiu_snpdat_exp_q.push_back(0);
         m_txn.ioaiu_snp_data_seen_q.push_back(0);
         m_txn.ioaiu_snp_addr_seen_q.push_back(-1);
         m_txn.snp_chi_from_ioaiu_q.push_back(0);
         m_txn.snpreq_unq_id_q.push_back({m_pkt.smi_targ_ncore_unit_id, m_pkt.smi_msg_id});

         m_txn.update_time_accessed();
         fsys_txn_q.push_back(m_txn);
         //end else begin
         //   `uvm_error(`LABEL, $sformatf(
         //      "FSYS_SCB: SNPReq didn't match any pending transactions. %0s",
         //      m_pkt.convert2string()))
         //end
      end
   end
endfunction : smi_snpreq_prediction_<%=pidx%>

//====================================================================================================
//
// Function : smi_snprsp_prediction
//
//====================================================================================================
function void fsys_scb_dce_predictor::smi_snprsp_prediction_<%=pidx%>(input dce<%=pidx%>_smi_agent_pkg::smi_seq_item m_pkt, ref fsys_scb_txn fsys_txn_q[$]);
   `undef LABEL
   `define LABEL "smi_snprsp_dce<%=pidx%>"
   bit match_found = 0;
   bit[63:0] snp_cacheline_addr;
   foreach (fsys_txn_q[idx]) begin
      if (fsys_txn_q[idx].snpreq_msg_id_q.size() > 0) begin
         foreach (fsys_txn_q[idx].snpreq_msg_id_q[i]) begin
            if (fsys_txn_q[idx].snpreq_msg_id_q[i] == m_pkt.smi_rmsg_id
               && (fsys_txn_q[idx].dce_funitid_q[i] == <%=obj.DceInfo[pidx].FUnitId%>)
               && fsys_txn_q[idx].snpreq_cnt_q[i] > 0)
            begin
               foreach (fsys_txn_q[idx].snpreq_unq_id_q[j]) begin
                  if (fsys_txn_q[idx].snpreq_unq_id_q[j] == {m_pkt.smi_src_ncore_unit_id, m_pkt.smi_rmsg_id}
                     && fsys_txn_q[idx].snpreq_src_id_q[j] == <%=obj.DceInfo[pidx].FUnitId%>) begin
                     if(fsys_txn_q[idx].multi_cacheline_access) begin
                        `uvm_info(`LABEL, $sformatf(
                           "FSYS_UID:%0d SUB_ID:%0d : SNPRsp seen (DCE's FUnitId:'d<%=obj.DceInfo[pidx].FUnitId%>) %0s",
                           fsys_txn_q[idx].fsys_unique_txn_id, fsys_txn_q[idx].cmd_req_subid_q[i], m_pkt.convert2string()), UVM_NONE+50)
                     end
                     else begin
                        `uvm_info(`LABEL, $sformatf(
                           "FSYS_UID:%0d : SNPRsp seen (DCE's FUnitId:'d<%=obj.DceInfo[pidx].FUnitId%>) %0s",
                           fsys_txn_q[idx].fsys_unique_txn_id, m_pkt.convert2string()), UVM_NONE+50)
                     end
                     fsys_txn_q[idx].update_time_accessed();
                     fsys_txn_q[idx].snpreq_cnt_q[i] = fsys_txn_q[idx].snpreq_cnt_q[i] - 1;
                     fsys_txn_q[idx].snprsp_cnt_q[i] = fsys_txn_q[idx].snprsp_cnt_q[i] + 1;
                     // only add first SNP_REQ and last SNP_RSP
                     if (!fsys_txn_q[idx].multi_cacheline_access && fsys_txn_q[idx].snpreq_cnt_q[i] == 0) begin
                        fsys_txn_q[idx].smi_msg_order_q.push_back(smi_msgs_t'(fsys_coverage_pkg::SNP_RESP));
                     end
                     fsys_txn_q[idx].snp_data_to_dmi_q[i] = (fsys_txn_q[idx].snp_data_to_dmi_q[i]) | (m_pkt.smi_cmstatus_dt_dmi);
                     fsys_txn_q[idx].snp_data_to_aiu_q[i] = (fsys_txn_q[idx].snp_data_to_aiu_q[i]) | (m_pkt.smi_cmstatus_dt_aiu);
                     //if (fsys_txn_q[idx].snpreq_cnt_q[i] == 0 && fsys_txn_q[idx].rbrreq_seen_q[i] >= 3) begin
                     //   fsys_txn_q[idx].snpreq_msg_id_q[i] = -1;
                     //end
                     if (fsys_txn_q[idx].ioaiu_core_id >=0 && (m_pkt.smi_cmstatus_dt_dmi == 0 || m_pkt.smi_cmstatus_err == 1)) begin
                        fsys_txn_q[idx].exp_smi_data_pkts = fsys_txn_q[idx].exp_smi_data_pkts - 1;
                     end
                     else if (fsys_txn_q[idx].snp_ioaiu_from_chi_q[j] == 1 && (m_pkt.smi_cmstatus_dt_dmi == 0 || m_pkt.smi_cmstatus_err == 1)) begin
                        fsys_txn_q[idx].exp_smi_data_pkts = fsys_txn_q[idx].exp_smi_data_pkts - 1;
                     end
                     if (fsys_txn_q[idx].snp_data_to_aiu_q[i] == 1 && fsys_txn_q[idx].mrdreq_seen_q[i] == 0) begin
                        fsys_txn_q[idx].mrd_possible_q[fsys_txn_q[idx].aiu_queue_idx[i]] = 0;
                     end
                     //MEM_CONSISTENCY
                     if(m_en_mem_check) begin
                        if (m_pkt.smi_cmstatus_dt_dmi) begin
                           snp_cacheline_addr = {(fsys_txn_q[idx].snpreq_addr_q[j] >> ncoreConfigInfo::WCACHE_OFFSET), <%=obj.wCacheLineOffset%>'b0};
                           mem_checker.snoop_on_native_if(.addr(snp_cacheline_addr), 
                                                          .data(fsys_txn_q[idx].snoop_data[m_pkt.smi_src_ncore_unit_id][snp_cacheline_addr]), 
                                                          .byte_en(fsys_txn_q[idx].snoop_be[m_pkt.smi_src_ncore_unit_id][snp_cacheline_addr]),
                                                          .snp_resp(0), // TODO
                                                          .funit_id(m_pkt.smi_src_ncore_unit_id), 
                                                          .core_id(0),
                                                          .to_dmi(1),
                                                          .fsys_index(idx), 
                                                          .fsys_txn_q(fsys_txn_q));
                        end
                     end
                     //TODO: Find in spec if there are any other cases where DTW can be sent to DMI.
                     if (m_pkt.smi_cmstatus_dt_dmi == 0) begin
                        //No data will be sent to DMI
                        for (int snp_idx = fsys_txn_q[idx].snpdat_unit_id_q.size()-1; snp_idx >=0; snp_idx--) begin
                           if (fsys_txn_q[idx].snpdat_unit_id_q[snp_idx] == m_pkt.smi_src_ncore_unit_id
                              && fsys_txn_q[idx].snpsrc_unit_id_q[snp_idx] == m_pkt.smi_targ_ncore_unit_id
                              && fsys_txn_q[idx].rbr_rbid_q[i] == fsys_txn_q[idx].rbid_q[snp_idx]
                              && fsys_txn_q[idx].snpreq_did_q[i] == fsys_txn_q[idx].rbid_unit_id_q[snp_idx]
                              && fsys_txn_q[idx].snp_msg_type_q[i] !== 'h46) begin
                              if(fsys_txn_q[idx].rbid_val_q.size()>0) fsys_txn_q[idx].rbid_val_q.delete(snp_idx);
                              if(fsys_txn_q[idx].rbid_q.size()>0) fsys_txn_q[idx].rbid_q.delete(snp_idx);
                              if(fsys_txn_q[idx].str_subid_q.size()>snp_idx) fsys_txn_q[idx].str_subid_q.delete(snp_idx); 
                              if(fsys_txn_q[idx].rbid_unit_id_q.size()>0) fsys_txn_q[idx].rbid_unit_id_q.delete(snp_idx);
                              if(fsys_txn_q[idx].snpdat_unit_id_q.size()>0) fsys_txn_q[idx].snpdat_unit_id_q.delete(snp_idx);
                              if(fsys_txn_q[idx].snpsrc_unit_id_q.size()>0) fsys_txn_q[idx].snpsrc_unit_id_q.delete(snp_idx);
                              break;
                           end
                        end
                     end // No data to DMI
                     // Invalidate it incase it doesn't get deleted in code below
                     fsys_txn_q[idx].snpreq_src_id_q[j] = -1;
                     if (fsys_txn_q[idx].is_stash_txn == 1 && m_pkt.smi_cmstatus_snarf == 1) begin
                        fsys_txn_q[idx].smi_stash_dtr_msg_id = m_pkt.smi_mpf1_dtr_msg_id;
                        fsys_txn_q[idx].stash_accept = 1;
                        if (fsys_txn_q[idx].ace_command_type != "WRUNQFULLSTASH") begin //Refer "Fig 16 Write stash full accept transaction flow" from Ncore System Spec
                           fsys_txn_q[idx].exp_smi_data_pkts = fsys_txn_q[idx].exp_smi_data_pkts + 1;
                        end
                        fsys_txn_q[idx].exp_chi_data_flits = fsys_txn_q[idx].chi_snp_data_count_q[j];
                     end // Stash accepted SNPResp
                     else if (fsys_txn_q[idx].is_stash_txn == 1 && m_pkt.smi_cmstatus_snarf == 0 && m_pkt.smi_src_ncore_unit_id == fsys_txn_q[idx].smi_stash_nid) begin
                        fsys_txn_q[idx].dce_check_done = 1;
                     end //Stash reject. DCE sometimes doesn't send RBR(TODO: Check spec)
                     //TODO: Code to analyze cmstatus of SNPRsp goes here
                     //Internal rbid release scenario for recalls
                     if (fsys_txn_q[idx].cmd_msg_id_q.size() == 0 && fsys_txn_q[idx].snpreq_cnt_q[i] == 0) begin
                        if (fsys_txn_q[idx].snp_data_to_dmi_q[i] == 0 && fsys_txn_q[idx].rbrreq_seen_q[i] !== 0) begin
                           rbid_internally_released_<%=pidx%>.push_back(fsys_txn_q[idx].rbr_rbid_q[i]);
                           rbid_internally_released_dmiid_<%=pidx%>.push_back(fsys_txn_q[idx].cmd_did_q[i]);
                           `uvm_info(`LABEL, $sformatf(
                              "FSYS_UID:%0d : RBID:0x%0h. Marking this RBID as internally released.",
                              fsys_txn_q[idx].fsys_unique_txn_id, fsys_txn_q[idx].rbr_rbid_q[i]), UVM_NONE+50)
                        end
                     end
                     //`uvm_info(`LABEL, $sformatf("FSYS_UID:%0d : snpreq_cnt_q='d%0d, rbrreq_seen_q='d%0d, snp_data_to_dmi_q='d%0d, idx='d%0d",fsys_txn_q[idx].fsys_unique_txn_id, fsys_txn_q[idx].snpreq_cnt_q[i], fsys_txn_q[idx].rbrreq_seen_q[i], fsys_txn_q[idx].snp_data_to_dmi_q[i], i), UVM_NONE+50)
                     //Internal rbid release scenario for normal txns
                     if (fsys_txn_q[idx].snpreq_cnt_q[i] == 0 && fsys_txn_q[idx].cmd_msg_id_q.size() > 0
                        && fsys_txn_q[idx].rbrreq_seen_q[i] > 0 && fsys_txn_q[idx].snp_data_to_dmi_q[i] == 0
                        && fsys_txn_q[idx].str_msg_id_val_q[fsys_txn_q[idx].aiu_queue_idx[i]] == 0
                        && fsys_txn_q[idx].internal_rbid_release_q[i] == 0) begin
                        fsys_txn_q[idx].rbuse_count++;
                        fsys_txn_q[idx].internal_rbuse_count++;
                        fsys_txn_q[idx].internal_rbid_release_q[i] = 1;
                        rbid_internally_released_<%=pidx%>.push_back(fsys_txn_q[idx].rbr_rbid_q[i]);
                        rbid_internally_released_dmiid_<%=pidx%>.push_back(fsys_txn_q[idx].cmd_did_q[i]);
                        `uvm_info(`LABEL, $sformatf(
                           "FSYS_UID:%0d : RBID:0x%0h. Marking this RBID as internally released. RBID: 0x%0h, DMIID=0x%0h, dceidx='d%0d",
                           fsys_txn_q[idx].fsys_unique_txn_id, m_pkt.smi_rbid, fsys_txn_q[idx].rbr_rbid_q[i], fsys_txn_q[idx].cmd_did_q[i], i), UVM_NONE+50)
                     end


                     if (fsys_txn_q[idx].cmd_msg_id_q.size() == 0 && fsys_txn_q[idx].snpreq_cnt_q[i] == 0 
                         && (fsys_txn_q[idx].rbrreq_seen_q[i] >= 2 || fsys_txn_q[idx].rbrreq_seen_q[i]==0)) begin
                        `uvm_info(`LABEL, $sformatf(
                           "FSYS_UID:%0d : Deleting a recall transaction from fsys_txn_q. Remaining txns: 'd%0d", 
                           fsys_txn_q[idx].fsys_unique_txn_id, (fsys_txn_q.size()-1)), UVM_NONE+50)
                        fsys_txn_q.delete(idx);
                     end // This is recall, delete the txn
                     else begin
                        //So far have seen this case(SNPResp before outgoing DTR) in CHIAIU. Adding this in CHI only to not affect IOAIU tests
                        if ((fsys_txn_q[idx].read_acc_dtr_exp_q[j] == 0 && fsys_txn_q[idx].ioaiu_core_id < 0) 
                           || (fsys_txn_q[idx].ioaiu_core_id >= 0 && fsys_txn_q[idx].read_acc_dtr_msgid_q[j] == -1 && fsys_txn_q[idx].snp_chi_from_ioaiu_q[j] == 0)
                           || (fsys_txn_q[idx].ioaiu_core_id >= 0 && fsys_txn_q[idx].read_acc_dtr_exp_q[j] == 0 && fsys_txn_q[idx].snp_chi_from_ioaiu_q[j] == 1)
                           || ((m_pkt.smi_cmstatus_dt_aiu == 1 && fsys_txn_q[idx].read_acc_dtr_msgid_q[j] == -1 && fsys_txn_q[idx].ioaiu_snprsp_exp_q[j] == 0) || (m_pkt.smi_cmstatus_dt_aiu == 0 && fsys_txn_q[idx].ioaiu_snprsp_exp_q[j] == 0))) begin
                           //fsys_txn_q[idx].snpreq_unq_id_q.delete(j);
                           //fsys_txn_q[idx].snpreq_targ_id_q.delete(j); 
                           //fsys_txn_q[idx].snpreq_rbid_q.delete(j); 
                           //fsys_txn_q[idx].snpreq_src_id_q.delete(j); 
                           //fsys_txn_q[idx].snpreq_addr_q.delete(j);
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
                           //fsys_txn_q[idx].ioaiu_snp_addr_seen_q.delete(j); 
                           //fsys_txn_q[idx].snp_chi_from_ioaiu_q.delete(j);
                           fsys_txn_q[idx].read_acc_dtr_msgid_q[j] = -1; 
                        end else begin
                           fsys_txn_q[idx].snpreq_unq_id_q[j] = -1;
                        end
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
// Function : smi_rbrsp_prediction
//
//====================================================================================================
function void fsys_scb_dce_predictor::smi_rbrsp_prediction_<%=pidx%>(input dce<%=pidx%>_smi_agent_pkg::smi_seq_item m_pkt, ref fsys_scb_txn fsys_txn_q[$]);
   `undef LABEL
   `define LABEL "smi_rbrsp_dce<%=pidx%>"
   bit match_found = 0;
   foreach (fsys_txn_q[idx]) begin
      if (fsys_txn_q[idx].rbr_rbid_q.size() > 0 ) begin
         foreach (fsys_txn_q[idx].rbr_rbid_q[i]) begin
            //`uvm_info(`LABEL, $sformatf(
            //    "FSYS_UID:%0d :rbr_rbid_q = 0x%0h, cmd_did_q=0x%0h, dce_funit_id='d%0d, dce_check_done='d%0d", 
            //    fsys_txn_q[idx].fsys_unique_txn_id,
            //    fsys_txn_q[idx].rbr_rbid_q[i], 
            //    fsys_txn_q[idx].cmd_did_q[i], 
            //    fsys_txn_q[idx].dce_funit_id, 
            //    fsys_txn_q[idx].dce_check_done), 
            //    UVM_NONE+50)
            if (fsys_txn_q[idx].rbr_rbid_q[i] == m_pkt.smi_rbid
               && fsys_txn_q[idx].rbr_rbid_val_q[i] == 1
               && fsys_txn_q[idx].cmd_did_q[i] == m_pkt.smi_src_ncore_unit_id
               && (fsys_txn_q[idx].dce_funit_id == <%=obj.DceInfo[pidx].FUnitId%> || fsys_txn_q[idx].multi_cacheline_access == 1)
               && (fsys_txn_q[idx].rbuse_count-fsys_txn_q[idx].internal_rbuse_count) < fsys_txn_q[idx].rbrsvd_count
               //&& (fsys_txn_q[idx].dce_check_done == 0 || (fsys_txn_q[idx].dce_check_done == 1 && fsys_txn_q[idx].internal_rbuse_count > 0))
            ) begin
               fsys_txn_q[idx].update_time_accessed();
               //If this is a recall added by snpreq, remove from internally released anyway
               if (fsys_txn_q[idx].cmd_msg_id_q.size() == 0 && fsys_txn_q[idx].rbrreq_seen_q[i] == 0) begin
                  foreach(rbid_internally_released_<%=pidx%>[rb_idx]) begin
                     if (m_pkt.smi_rbid == rbid_internally_released_<%=pidx%>[rb_idx]
                        && fsys_txn_q[idx].cmd_did_q[i] == rbid_internally_released_dmiid_<%=pidx%>[rb_idx]) begin
                        rbid_internally_released_<%=pidx%>.delete(rb_idx);
                        rbid_internally_released_dmiid_<%=pidx%>.delete(rb_idx);
                        `uvm_info(`LABEL, $sformatf(
                           "FSYS_UID:%0d : RBID:0x%0h. Removing this RBID from internally released queue.",
                           fsys_txn_q[idx].fsys_unique_txn_id, m_pkt.smi_rbid), UVM_NONE+50)
                        break;
                     end
                  end
               end
               if (fsys_txn_q[idx].internal_rbid_release_q[i] == 0) begin
                  fsys_txn_q[idx].rbuse_count++;
               end 
               else begin
                  fsys_txn_q[idx].internal_rbuse_count--;
               end
               foreach(rbid_internally_released_<%=pidx%>[rb_idx]) begin
                  `uvm_info(`LABEL, $sformatf(
                     "FSYS_SCB_DBG: idx='d%0d, RBID:0x%0h, DMI_ID=0x%0h. Smi PKT: rbid=0x%0h, cmd_id=0x%0h", 
                     rb_idx, rbid_internally_released_<%=pidx%>[rb_idx], rbid_internally_released_dmiid_<%=pidx%>[rb_idx], m_pkt.smi_rbid, fsys_txn_q[idx].cmd_did_q[i]), UVM_NONE+50)
                  if (m_pkt.smi_rbid == rbid_internally_released_<%=pidx%>[rb_idx]
                     && fsys_txn_q[idx].cmd_did_q[i] == rbid_internally_released_dmiid_<%=pidx%>[rb_idx]) begin
                     rbid_internally_released_<%=pidx%>.delete(rb_idx);
                     rbid_internally_released_dmiid_<%=pidx%>.delete(rb_idx);
                     `uvm_info(`LABEL, $sformatf(
                        "FSYS_UID:%0d : RBID:0x%0h. Removing this RBID from internally released queue.",
                        fsys_txn_q[idx].fsys_unique_txn_id, m_pkt.smi_rbid), UVM_NONE+50)
                     break;
                  end
               end
               fsys_txn_q[idx].rbr_rbid_q[i] = -1; 
               //if (fsys_txn_q[idx].snpreq_cnt_q[i] == 0)
               //   fsys_txn_q[idx].snpreq_msg_id_q[i] = -1;
               fsys_txn_q[idx].rbrreq_seen_q[i] = 4; // Set this to highest number so another's RBRReq(Release) Won't match by mistake
               if (fsys_txn_q[idx].snp_data_to_aiu_q[i] == 1 && fsys_txn_q[idx].mrdreq_seen_q[i] == 0) begin
                  fsys_txn_q[idx].mrd_possible_q[fsys_txn_q[idx].aiu_queue_idx[i]] = 0;
               end
               for (int rbr_idx = fsys_txn_q[idx].rbid_q.size()-1; rbr_idx >=0; rbr_idx--) begin
                  // This is needed in case of WRUNQ that were sent out as RDUNQ & their rbrreq entries will keep waiting for DTW without deleting them from q
                  if (fsys_txn_q[idx].rbid_q[rbr_idx] == m_pkt.smi_rbid && fsys_txn_q[idx].rbid_unit_id_q[rbr_idx] == m_pkt.smi_src_ncore_unit_id
                     && fsys_txn_q[idx].snpsrc_unit_id_q[rbr_idx] == m_pkt.smi_targ_ncore_unit_id) begin
                     fsys_txn_q[idx].rbid_val_q.delete(rbr_idx);
                     fsys_txn_q[idx].rbid_q.delete(rbr_idx);
                     fsys_txn_q[idx].rbid_unit_id_q.delete(rbr_idx);
                     // TODO: Confirm in spec: WRUNQ had a SNPRSP with dt_dmi=1, but WrUnqPtl didn't send DTW(Is that optional?).
                     //if (fsys_txn_q[idx].snpdat_unit_id_q[rbr_idx] != -1)
                     //   fsys_txn_q[idx].exp_smi_data_pkts = fsys_txn_q[idx].exp_smi_data_pkts - 1;
                     fsys_txn_q[idx].snpdat_unit_id_q.delete(rbr_idx);
                     fsys_txn_q[idx].snpsrc_unit_id_q.delete(rbr_idx);
                  end
               end

               if(fsys_txn_q[idx].multi_cacheline_access) begin
                  `uvm_info(`LABEL, $sformatf(
                     "FSYS_UID:%0d SUB_ID:%0d : RBRsp seen (DCE's FUnitId:'d<%=obj.DceInfo[pidx].FUnitId%>) rbuse_count = %0d, rbrsvd_count=%0d %0s", 
                     fsys_txn_q[idx].fsys_unique_txn_id, fsys_txn_q[idx].subid_q[i], fsys_txn_q[idx].rbuse_count,
                     fsys_txn_q[idx].rbrsvd_count, m_pkt.convert2string()), UVM_NONE+50)
               end else begin
                  `uvm_info(`LABEL, $sformatf(
                     "FSYS_UID:%0d : RBRsp seen (DCE's FUnitId:'d<%=obj.DceInfo[pidx].FUnitId%>) rbuse_count = %0d, rbrsvd_count=%0d %0s", 
                     fsys_txn_q[idx].fsys_unique_txn_id, fsys_txn_q[idx].rbuse_count,
                     fsys_txn_q[idx].rbrsvd_count, m_pkt.convert2string()), UVM_NONE+50)
               end
               if (!fsys_txn_q[idx].multi_cacheline_access) begin
                  fsys_txn_q[idx].smi_msg_order_q.push_back(smi_msgs_t'(fsys_coverage_pkg::RBR_RSP));
               end
               fsys_txn_q[idx].rbuse_seen = 1;
               if (fsys_txn_q[idx].cmd_msg_id_q.size() == 0 && fsys_txn_q[idx].snpreq_cnt_q[i] == 0) begin
                  `uvm_info(`LABEL, $sformatf(
                     "FSYS_UID:%0d : Deleting a recall transaction from fsys_txn_q. Remaining txns: 'd%0d", 
                     fsys_txn_q[idx].fsys_unique_txn_id, (fsys_txn_q.size()-1)), UVM_NONE+50)
                  fsys_txn_q.delete(idx);
               end // This is recall, delete the txn
               else begin
                  if (fsys_txn_q[idx].snpreq_cnt_q[i] == 0) begin
                     fsys_txn_q[idx].dce_check_done = 1;
                  end
                  if (fsys_txn_q[idx].rbuse_count !== fsys_txn_q[idx].rbrsvd_count) begin
                     fsys_txn_q[idx].dce_check_done = 0;
                  end 
                  if (fsys_txn_q[idx].aiu_str_cnt == fsys_txn_q[idx].str_msg_id_q.size()
                     && fsys_txn_q[idx].exp_smi_cmd_pkts == 0
                     && fsys_txn_q[idx].axi_data_seen == 1
                     && (fsys_txn_q[idx].is_write == 0 || (fsys_txn_q[idx].is_write == 1 && fsys_txn_q[idx].axi_write_resp_seen == 1))
                     && fsys_txn_q[idx].exp_smi_data_pkts == 0) begin
                     `uvm_info(`LABEL, $sformatf(
                        "FSYS_UID:%0d : Setting aiu_check_done", 
                        fsys_txn_q[idx].fsys_unique_txn_id), UVM_NONE+50)
                     fsys_txn_q[idx].aiu_check_done = 1;
                  end
                  //Since DMI predictor doesn't monitor rbuse, set it's done flag if all data is seen at this point
                  if (fsys_txn_q[idx].exp_smi_data_pkts == 0 && fsys_txn_q[idx].dmi_check_done == 0) begin
                     fsys_txn_q[idx].dmi_check_done = 1;
                  end
                  if (fsys_txn_q[idx].exp_smi_data_pkts == 0 && fsys_txn_q[idx].aiu_check_done == 0 && fsys_txn_q[idx].dmi_check_done == 1) begin
                     fsys_txn_q[idx].delete_at_aiu = 1;
                  end
                  if (fsys_txn_q[idx].snpreq_cnt_q[i] == 0 
                     && fsys_txn_q[idx].aiu_check_done == 1 
                     && fsys_txn_q[idx].dmi_check_done == 1 
                     && fsys_txn_q[idx].is_atomic_txn == 0
                     && fsys_txn_q[idx].dce_check_done == 1) begin
                     `uvm_info(`LABEL, $sformatf(
                        "FSYS_UID:%0d : Deleting transaction from fsys_txn_q. Remaining txns: 'd%0d", 
                        fsys_txn_q[idx].fsys_unique_txn_id, (fsys_txn_q.size()-1)), UVM_NONE+50)
                     `ifdef FSYS_SCB_COVER_ON
                        fsys_txn_path_cov.sample_txn(fsys_txn_q[idx].smi_msg_order_q, (fsys_txn_q[idx].ioaiu_core_id >= 0));
                     `endif // `ifdef FSYS_SCB_COVER_ON
                     fsys_txn_q[idx].print_path();
                     fsys_txn_q.delete(idx);
                  end // regular write txn
               end // else of recall
               match_found = 1;
               break;
            end // if matched
         end // foreach CMDReq DID
      end // if there are pending recalls 
      if (match_found == 1) break;
   end //foreach pending txn 
   if (match_found == 0) begin
      foreach(rbid_internally_released_<%=pidx%>[rb_idx]) begin
         //`uvm_info(`LABEL, $sformatf("FSYS_DEBUG: PKT RBID: 0x%0h, saved RBID: 0x%0h, NCORE unit=0x%0h, saved: 0x%0h",m_pkt.smi_rbid, rbid_internally_released_<%=pidx%>[rb_idx], m_pkt.smi_src_ncore_unit_id, rbid_internally_released_dmiid_<%=pidx%>[rb_idx]), UVM_NONE+50)
         if (m_pkt.smi_rbid == rbid_internally_released_<%=pidx%>[rb_idx]
             && m_pkt.smi_src_ncore_unit_id == rbid_internally_released_dmiid_<%=pidx%>[rb_idx]) begin
            rbid_internally_released_<%=pidx%>.delete(rb_idx);
            rbid_internally_released_dmiid_<%=pidx%>.delete(rb_idx);
            `uvm_info(`LABEL, $sformatf(
               "FSYS_SCB: RBRsp seen. This RBID was internally released earlier, it's matching txn may have been deleted from fsys_txn_q %0s", 
               m_pkt.convert2string()), UVM_NONE+50)
            match_found = 1;
            break;
         end
      end
      if (match_found == 0) begin
         `uvm_error(`LABEL, $sformatf(
            "FSYS_SCB: RBRsp didn't match any pending transactions. %0s", 
            m_pkt.convert2string()))
      end
   end
endfunction : smi_rbrsp_prediction_<%=pidx%>
//====================================================================================================
//
// Function : smi_updreq_prediction
//
//====================================================================================================
function void fsys_scb_dce_predictor::smi_updreq_prediction_<%=pidx%>(input dce<%=pidx%>_smi_agent_pkg::smi_seq_item m_pkt, ref fsys_scb_txn fsys_txn_q[$]);
   `undef LABEL
   `define LABEL "smi_updreq_dce<%=pidx%>"
   bit match_found = 0;
   foreach(fsys_txn_q[idx]) begin
      if ((fsys_txn_q[idx].dce_funit_id== <%=obj.DceInfo[pidx].FUnitId%>)
          //&& fsys_txn_q[idx].updreq_msg_id_val == 1
          //&& fsys_txn_q[idx].updreq_msg_id == m_pkt.smi_msg_id
          && fsys_txn_q[idx].updreq_req_addr == m_pkt.smi_addr
          && fsys_txn_q[idx].delete_at_dce == 1
          && fsys_txn_q[idx].dce_check_done == 0
          && fsys_txn_q[idx].source_funit_id == m_pkt.smi_src_ncore_unit_id) 
      begin
         `uvm_info(`LABEL, $sformatf("FSYS_UID:%0d : SMI UpdReq packet seen (DCE's FUnitId:'d<%=obj.DceInfo[pidx].FUnitId%>) %0s. Source AIU native if type %0s", fsys_txn_q[idx].fsys_unique_txn_id, m_pkt.convert2string(), ncoreConfigInfo::get_native_interface(m_pkt.smi_src_ncore_unit_id).name()), UVM_NONE)
         if ((fsys_txn_q[idx].is_write == 0 && fsys_txn_q[idx].ace_command_type !== "EVCT")
            || (fsys_txn_q[idx].is_write == 1 && fsys_txn_q[idx].axi_write_resp_seen == 1)
            || (fsys_txn_q[idx].ace_command_type == "EVCT" && fsys_txn_q[idx].axi_write_resp_seen == 1))begin
            `uvm_info(`LABEL, $sformatf("FSYS_UID:%0d : Deleting transaction from fsys_txn_q. remaining txns: 'd%0d", fsys_txn_q[idx].fsys_unique_txn_id, (fsys_txn_q.size()-1)), UVM_NONE+50)
            `ifdef FSYS_SCB_COVER_ON
               fsys_txn_path_cov.sample_txn(fsys_txn_q[idx].smi_msg_order_q, (fsys_txn_q[idx].ioaiu_core_id >= 0));
            `endif // `ifdef FSYS_SCB_COVER_ON
            fsys_txn_q[idx].print_path();
            fsys_txn_q.delete(idx);
         end else begin
            `uvm_info(`LABEL, $sformatf("FSYS_UID:%0d : Write Resp Not seen yet. Don't delete transaction from fsys_txn_q", fsys_txn_q[idx].fsys_unique_txn_id), UVM_NONE+50)
            fsys_txn_q[idx].dce_check_done = 1;
            if (fsys_txn_q[idx].is_dataless_txn == 1)begin
               fsys_txn_q[idx].dmi_check_done = 1;
               fsys_txn_q[idx].dii_check_done = 1;
            end
         end
         match_found = 1;
         break;
      end
      if (match_found == 1) break;
   end //foreach fsys_txn
   if (match_found == 0 && (ncoreConfigInfo::get_native_interface(m_pkt.smi_src_ncore_unit_id) inside {ncoreConfigInfo::ACE_AIU/*, ncoreConfigInfo::IO_CACHE_AIU*/})) begin
      `uvm_error(`LABEL, $sformatf("FSYS_SCB: UpdReq packet didn't match any pending transactions. %0s", m_pkt.convert2string()))
   end
   if (!(ncoreConfigInfo::get_native_interface(m_pkt.smi_src_ncore_unit_id) inside {ncoreConfigInfo::ACE_AIU, ncoreConfigInfo::IO_CACHE_AIU})) begin
      `uvm_error(`LABEL, $sformatf("SMI UpdReq is not expected from native interface %0s unit id 'd%0d. Remaining txns: 'd%0d",  ncoreConfigInfo::get_native_interface(m_pkt.smi_src_ncore_unit_id).name(),m_pkt.smi_src_ncore_unit_id, (fsys_txn_q.size()-1)))
   end
endfunction : smi_updreq_prediction_<%=pidx%>

//====================================================================================================
//
// Function : smi_sysreq_prediction
//
//====================================================================================================
function void fsys_scb_dce_predictor::smi_sysreq_prediction_<%=pidx%>(input dce<%=pidx%>_smi_agent_pkg::smi_seq_item m_pkt, ref fsys_scb_txn fsys_txn_q[$]);
   `undef LABEL
   `define LABEL "smi_sysreq_dce<%=pidx%>"
   `uvm_info(`LABEL, $sformatf("SYSREQ seen: %0s", m_pkt.convert2string()), UVM_NONE+50)
   case(m_pkt.smi_sysreq_op)
      dce<%=pidx%>_smi_agent_pkg::SMI_SYSREQ_ATTACH:
      begin
         pending_attach_sys_req_<%=pidx%>.push_back(m_pkt);
      end
      dce<%=pidx%>_smi_agent_pkg::SMI_SYSREQ_DETACH:
      begin
         pending_attach_sys_req_<%=pidx%>.push_back(m_pkt);
      end
      default:
      begin
         if ($test$plusargs("EN_SYS_EVENT_CHECK")) begin
            if (m_pkt.smi_sysreq_op == dce<%=pidx%>_smi_agent_pkg::SMI_SYSREQ_EVENT) begin
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
function void fsys_scb_dce_predictor::analyze_sys_event_<%=pidx%>(input dce<%=pidx%>_smi_agent_pkg::smi_seq_item m_pkt, ref fsys_scb_txn fsys_txn_q[$]);
   `undef LABEL
   `define LABEL "analyze_sys_event_dce<%=pidx%>"
   fsys_scb_txn m_txn = fsys_scb_txn::type_id::create("m_txn");
   if (m_pkt.smi_targ_ncore_unit_id == <%=obj.DceInfo[pidx].FUnitId%>) begin
      `uvm_error(`LABEL, $sformatf("FSYS_SCB: DCE cannot be receiver of SYS_EVENT msg. PKT: %0s", m_pkt.convert2string()))
   end
   if (m_pkt.smi_targ_ncore_unit_id !== <%=obj.DveInfo[0].FUnitId%>) begin
      `uvm_error(`LABEL, $sformatf("FSYS_SCB: Outgoing SYS_EVENT should always be going to DVE. PKT: %0s", m_pkt.convert2string()))
   end
   m_txn.fsys_unique_txn_id = fsys_scoreboard::get_next_unique_txn_id();
   `uvm_info(`LABEL, $sformatf(
      "FSYS_UID:%0d : Adding a SYS_EVENT to pending queue. DCE's FUnitId:'d<%=obj.DceInfo[pidx].FUnitId%> %0s", 
      m_txn.fsys_unique_txn_id, m_pkt.convert2string()), UVM_NONE+50)
   m_txn.is_sys_evnt = 1;
   m_txn.source_funit_id = m_pkt.smi_src_ncore_unit_id;
   m_txn.smi_msg_id = m_pkt.smi_msg_id;
   fsys_txn_q.push_back(m_txn);

endfunction : analyze_sys_event_<%=pidx%>

//====================================================================================================
//
// Function : smi_sysrsp_prediction
//
//====================================================================================================
function void fsys_scb_dce_predictor::smi_sysrsp_prediction_<%=pidx%>(input dce<%=pidx%>_smi_agent_pkg::smi_seq_item m_pkt, ref fsys_scb_txn fsys_txn_q[$]);
   `undef LABEL
   `define LABEL "smi_sysrsp_dce<%=pidx%>"
   int find_q[$];
   bit matched=0;
   `uvm_info(`LABEL, $sformatf("FSYS_SCB: SYSRSP seen: %0s", m_pkt.convert2string()), UVM_NONE+50)
   find_q = pending_attach_sys_req_<%=pidx%>.find_index with (
                  item.smi_targ_ncore_unit_id == m_pkt.smi_src_ncore_unit_id
                  && item.smi_msg_id == m_pkt.smi_rmsg_id);
   if (find_q.size() > 0) begin
      if (pending_attach_sys_req_<%=pidx%>[find_q[0]].smi_sysreq_op == dce<%=pidx%>_smi_agent_pkg::SMI_SYSREQ_ATTACH) begin
         attached_funit_ids_<%=pidx%>.push_back(m_pkt.smi_targ_ncore_unit_id);
         pending_attach_sys_req_<%=pidx%>.delete(find_q[0]);
         `uvm_info(`LABEL, $sformatf("FSYS_SCB: SYSRSP matched a pending SYSREQ. Marking DCE as attached to funit id: 0x%0h", m_pkt.smi_targ_ncore_unit_id), UVM_NONE+50)
      end else if (pending_attach_sys_req_<%=pidx%>[find_q[0]].smi_sysreq_op == dce<%=pidx%>_smi_agent_pkg::SMI_SYSREQ_DETACH) begin
         foreach(attached_funit_ids_<%=pidx%>[idx]) begin
            if (attached_funit_ids_<%=pidx%>[idx] == m_pkt.smi_targ_ncore_unit_id) begin
               attached_funit_ids_<%=pidx%>.delete(idx);
               matched = 1;
               `uvm_info(`LABEL, $sformatf("FSYS_SCB: SYSRSP matched a pending SYSREQ. Marking DCE as detached from funit id: 0x%0h", m_pkt.smi_targ_ncore_unit_id), UVM_NONE+50)
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
         find_q = fsys_txn_q.find_index with (
            item.is_sys_evnt == 1
            && item.smi_msg_id == m_pkt.smi_rmsg_id
            && item.source_funit_id == m_pkt.smi_targ_ncore_unit_id
            );
         if (find_q.size() > 0) begin
            `uvm_info(`LABEL, $sformatf(
               "FSYS_UID:%0d : Received SYSRSP for a SYS_EVENT transaction. DCE's FUnitId:'d<%=obj.DceInfo[pidx].FUnitId%> %0s", 
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
      end else begin
         `uvm_error(`LABEL, $sformatf("FSYS_SCB: SYSRSP didn't match any pending SYSREQ. PKT: %0s", m_pkt.convert2string()))
      end
   end
endfunction : smi_sysrsp_prediction_<%=pidx%>

//====================================================================================================
//
// Function : check_for_reissue 
//
//====================================================================================================
function void fsys_scb_dce_predictor::check_for_reissue_<%=pidx%>(input int rbid, input int dmi_id);
   `undef LABEL
   `define LABEL "check_for_reissue_dce<%=pidx%>"

   //foreach(rbid_internally_released_<%=pidx%>[rb_idx]) begin
   //   `uvm_info(`LABEL, $sformatf(
   //      "FSYS_SCB_DBG: idx='d%0d, RBID:0x%0h, DMI_ID=0x%0h", 
   //      rb_idx, rbid_internally_released_<%=pidx%>[rb_idx], rbid_internally_released_dmiid_<%=pidx%>[rb_idx]), UVM_NONE+50)
   //end
   foreach (rbid_internally_released_<%=pidx%>[idx]) begin
      if (rbid_internally_released_<%=pidx%>[idx] == rbid && rbid_internally_released_dmiid_<%=pidx%>[idx] == dmi_id) begin
         `uvm_error(`LABEL, $sformatf("FSYS_SCB: RBID reissue error. RBID:0x%0h to DMI FunitId:0x%0h was internally released, but RbrRsp isn't yet seen", rbid, dmi_id))
      end
   end
endfunction : check_for_reissue_<%=pidx%>

<% } //foreach DCE %>

////////////////////////////////////////////////////////////////////////////////
// Function: check_phase
// Description: Runs end of test checks and prints debug information
////////////////////////////////////////////////////////////////////////////////
function void fsys_scb_dce_predictor::check_phase(uvm_phase phase);
   <% for(var pidx = 0; pidx < obj.nDCEs; pidx++) { %>
      if (tmp_snpreq_pkt_<%=pidx%>.size() != 0) begin
         `uvm_error("check_phase", $psprintf("FSYS_SCB: DCE<%=pidx%> Has some unaccounted for snoops", tmp_snpreq_pkt_<%=pidx%>.size()))
      end
      if (pending_attach_sys_req_<%=pidx%>.size() !== 0) begin
      //TODO: make this an error when TB has support to drive event_if signals
         `uvm_warning("check_phase", $psprintf("FSYS_SCB: DCE<%=pidx%> has %0d pending SYSREQ that didn't see SYSRSP", pending_attach_sys_req_<%=pidx%>.size()))
      end
   <% } // foreach DCE %>
endfunction : check_phase

// End of file
