////////////////////////////////////////////////////////////////////////////////
//
// Author       : Neha F
// Purpose      : CHI AIU predictor class
// Description  : This is a component of fsys_scoreboard. This component will
//                add new CHI packets as a new scb_txn and add prediction flags 
//                for it's path through different NCore units. This transaction
//                will be added to fsys_pending_q.
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


class fsys_scb_chi_predictor extends uvm_component;

   int chi_txn_cnt;

   `uvm_component_utils(fsys_scb_chi_predictor)
   `ifdef FSYS_SCB_COVER_ON 
   fsys_txn_path_coverage fsys_txn_path_cov;
   `endif // `ifdef FSYS_SCB_COVER_ON              

   extern function new(string name = "fsys_scb_chi_predictor", uvm_component parent = null);
   extern function void build_phase(uvm_phase phase);
   extern function bit  check_flags_and_delete_txn(string label, int index, ref fsys_scb_txn fsys_txn_q[$], input int line, bit ignore_checks = 0);

   <% for(var pidx = 0; pidx < _child_blkid.length; pidx++) { %>
   <%  if(_child_blk[pidx].match('chiaiu')) { %>
   extern function void analyze_chi_req_<%=pidx%>(input <%=_child_blkid[pidx]%>_env_pkg::chi_req_seq_item m_pkt, ref fsys_scb_txn fsys_txn_q[$]);
   extern function void analyze_chi_rdata_pkt_<%=pidx%>(input <%=_child_blkid[pidx]%>_env_pkg::chi_dat_seq_item m_pkt, ref fsys_scb_txn fsys_txn_q[$]);
   extern function void analyze_chi_wdata_pkt_<%=pidx%>(input <%=_child_blkid[pidx]%>_env_pkg::chi_dat_seq_item m_pkt, ref fsys_scb_txn fsys_txn_q[$]);
   extern function void analyze_chi_crsp_pkt_<%=pidx%>(input <%=_child_blkid[pidx]%>_env_pkg::chi_rsp_seq_item m_pkt, ref fsys_scb_txn fsys_txn_q[$]);
   extern function void analyze_chi_srsp_pkt_<%=pidx%>(input <%=_child_blkid[pidx]%>_env_pkg::chi_rsp_seq_item m_pkt, ref fsys_scb_txn fsys_txn_q[$]);
   extern function void analyze_chi_snpaddr_pkt_<%=pidx%>(input <%=_child_blkid[pidx]%>_env_pkg::chi_snp_seq_item m_pkt, ref fsys_scb_txn fsys_txn_q[$]); 
   extern function void analyze_smi_pkt_<%=pidx%>(input <%=_child_blkid[pidx]%>_smi_agent_pkg::smi_seq_item m_pkt, ref fsys_scb_txn fsys_txn_q[$]);
   extern function void smi_cmd_msg_prediction_<%=pidx%>(input <%=_child_blkid[pidx]%>_smi_agent_pkg::smi_seq_item m_pkt, ref fsys_scb_txn fsys_txn_q[$]);
   extern function void smi_str_prediction_<%=pidx%>(input <%=_child_blkid[pidx]%>_smi_agent_pkg::smi_seq_item m_pkt, ref fsys_scb_txn fsys_txn_q[$]);
   extern function void smi_dtr_prediction_<%=pidx%>(input <%=_child_blkid[pidx]%>_smi_agent_pkg::smi_seq_item m_pkt, ref fsys_scb_txn fsys_txn_q[$]);
   extern function void smi_snpreq_prediction_<%=pidx%>(input <%=_child_blkid[pidx]%>_smi_agent_pkg::smi_seq_item m_pkt, ref fsys_scb_txn fsys_txn_q[$]);
   extern function void smi_sysreq_prediction_<%=pidx%>(input <%=_child_blkid[pidx]%>_smi_agent_pkg::smi_seq_item m_pkt, ref fsys_scb_txn fsys_txn_q[$]);
   extern function void analyze_sys_event_<%=pidx%>(input <%=_child_blkid[pidx]%>_smi_agent_pkg::smi_seq_item m_pkt, ref fsys_scb_txn fsys_txn_q[$]);
   extern function void smi_sysrsp_prediction_<%=pidx%>(input <%=_child_blkid[pidx]%>_smi_agent_pkg::smi_seq_item m_pkt, ref fsys_scb_txn fsys_txn_q[$]);
   extern function void analyze_sys_event_rsp_<%=pidx%>(input <%=_child_blkid[pidx]%>_smi_agent_pkg::smi_seq_item m_pkt, ref fsys_scb_txn fsys_txn_q[$]);
   //SYSREQ related lists 
   <%=_child_blkid[pidx]%>_smi_agent_pkg::smi_seq_item pending_attach_sys_req_<%=pidx%>[$];
   //Queue of funit IDs of DCEs & DVEs that this AIU is attached to
   int attached_funit_ids_<%=pidx%>[$];
   int smi_snpreq_order_uid_<%=pidx%>[$];

   //MEM_CONSISTENCY
   extern function void package_and_send_mem_checker_<%=pidx%>(ref fsys_scb_txn fsys_txn_q[$], int index, input string txn_type="RD");
   extern function void package_and_send_coh_checker_<%=pidx%>(fsys_scb_txn fsys_txn_q,bit [1:0] resperr,bit [2:0] resp,bit isRd,isWr,isSnp,int idx = 0);
   <% } // if chiaui%>
   <% } // foreach aius%>

   // End of test checks
   extern function void check_phase(uvm_phase phase);

   //MEM_CONSISTENCY
   mem_consistency_checker mem_checker;
   bit   m_en_mem_check;
   //Coherency checker
   bit   m_en_coh_check;
   fsys_coherency_checker  coherency_checker;

endclass : fsys_scb_chi_predictor

//====================================================================================================
//
//====================================================================================================
function fsys_scb_chi_predictor::new(string name = "fsys_scb_chi_predictor", uvm_component parent = null);
   super.new(name,parent);
endfunction : new

//====================================================================================================
//
//====================================================================================================
function void fsys_scb_chi_predictor::build_phase(uvm_phase phase);
   bit coh_check;
   super.build_phase(phase);
   //MEM_CONSISTENCY
   if($test$plusargs("EN_MEM_CHECK")) begin
      m_en_mem_check = 1;
   end else begin
      m_en_mem_check = 0;
   end
   if(m_en_mem_check) begin
      if(!(uvm_config_db #(mem_consistency_checker)::get(uvm_root::get(), "", "mem_checker", mem_checker)))begin
         `uvm_fatal("fsys_scb_chi_predictor", "Could not find mem_consistency_checker object in UVM DB");
      end
   end
   if ($value$plusargs("EN_COH_CHECK=%0d", coh_check)) begin
      m_en_coh_check = coh_check;
   end else begin
      //Enabled by default
      m_en_coh_check = 1;
   end

   if(m_en_coh_check) begin
      if(!(uvm_config_db #(fsys_coherency_checker)::get(uvm_root::get(), "", "coherency_checker", coherency_checker)))begin
         `uvm_fatal("fsys_scb_chi_predictor", "Could not find fsys_coherency_checker object in UVM DB");
      end
   end

endfunction : build_phase

<% for(var pidx = 0; pidx < _child_blkid.length; pidx++) { %>
<%  if(_child_blk[pidx].match('chiaiu')) { %>
//====================================================================================================
//
//====================================================================================================
function void fsys_scb_chi_predictor::analyze_chi_req_<%=pidx%>(input <%=_child_blkid[pidx]%>_env_pkg::chi_req_seq_item m_pkt, ref fsys_scb_txn fsys_txn_q[$]);
   `undef LABEL
   `define LABEL "chi_req_<%=_child_blkid[pidx]%>"
   int mem_region;
   bit connected = 0;
   int index;
   fsys_scb_txn m_txn = fsys_scb_txn::type_id::create("m_txn");
   m_txn.fsys_unique_txn_id = fsys_scoreboard::get_next_unique_txn_id();
   m_txn.m_chi_req_pkt_<%=pidx%> = new();
   m_txn.m_chi_req_pkt_<%=pidx%>.copy(m_pkt);
   m_txn.smi_addr = m_pkt.addr;
   m_txn.smi_addr_val = 1;
   m_txn.source_funit_id = <%=obj.AiuInfo[pidx].FUnitId%>;
   if (m_pkt.addr inside {[ncoreConfigInfo::NRS_REGION_BASE : (ncoreConfigInfo::NRS_REGION_BASE + ncoreConfigInfo::NRS_REGION_SIZE)]}
      && m_pkt.opcode !== <%=_child_blkid[pidx]%>_env_pkg::DVMOP) begin
      `uvm_info(`LABEL, $sformatf(
         "FSYS_UID:%0d : Register access packet. %0s",
         m_txn.fsys_unique_txn_id, 
         m_pkt.convert2string()), UVM_NONE+50)
      m_txn.register_txn = 1;
   end else if (m_pkt.opcode == <%=_child_blkid[pidx]%>_env_pkg::REQLCRDRETURN) begin
      `uvm_info(`LABEL, $sformatf(
         "FSYS_UID:%0d : New transaction with opcode %0s. Skipping scoreboarding. %0s", 
         m_txn.fsys_unique_txn_id, m_pkt.opcode.name(),
         m_pkt.convert2string()), UVM_NONE+50)
      return;
   end else begin
      if (m_pkt.opcode == <%=_child_blkid[pidx]%>_env_pkg::DVMOP) begin
         `uvm_info(`LABEL, $sformatf(
            "FSYS_UID:%0d : New transaction with opcode %0s. Packet: %0s", 
            m_txn.fsys_unique_txn_id, m_pkt.opcode.name(),
            m_pkt.convert2string()), UVM_NONE+50)
         m_txn.dest_funit_id = <%=obj.DveInfo[0].FUnitId%>;
         foreach (m_txn.dvm_part_2_addr_q[addr_idx])
            m_txn.dvm_part_2_addr_q[addr_idx] = -1;
         m_txn.is_dvm = 1;
         m_txn.register_txn = 0;
         <% if (obj.noDVM) { %>
            `uvm_error(`LABEL, $sformatf(
               "FSYS_UID:%0d : NCore doesn't support DVM txns in noDVM=true config: CONC-15169",  m_txn.fsys_unique_txn_id))
         <% } %>
      end else begin
         m_txn.dest_funit_id = ncoreConfigInfo::map_addr2dmi_or_dii(m_pkt.addr, mem_region);
         m_txn.dce_funit_id = ncoreConfigInfo::map_addr2dce(m_pkt.addr);
      end
      <% for(var idx = 0; idx < obj.nDMIs; idx++) { %> 
      if (m_txn.dest_funit_id == <%=obj.DmiInfo[idx].FUnitId%>) begin
         m_txn.dmi_bound = 1;
	      <% if (obj.ConnectivityMap.aiuDmiMap[obj.AiuInfo[pidx].FUnitId]) { %>
	         <% for(var j = 0; j < obj.ConnectivityMap.aiuDmiMap[obj.AiuInfo[pidx].FUnitId].length; j++) { %>
            if (m_txn.dest_funit_id == <%=obj.ConnectivityMap.aiuDmiMap[obj.AiuInfo[pidx].FUnitId][j]%>) connected = 1;
	         <% } //foreach aiuDmiMap %>
	      <% } //if aiuDmiMap[obj.AiuInfo[pidx].FUnitId] %>
         if (connected == 0) begin
            `uvm_error(`LABEL, $sformatf(
               "FSYS_UID:%0d : New TXN to unconnected DMI. Dest: DMI(FunitId:'d%0d). Addr=0x%0h Packet: %0s",
               m_txn.fsys_unique_txn_id, m_txn.dest_funit_id, m_pkt.addr, m_pkt.convert2string()))
         end else begin
            `uvm_info(`LABEL, $sformatf(
               "FSYS_UID:%0d : New transaction with opcode %0s. This should be routed to DMI with FuniId 'd%0d. Addr=0x%0h %0s", 
               m_txn.fsys_unique_txn_id, 
               m_pkt.opcode.name(),
               m_txn.dest_funit_id,
               m_pkt.addr,
               m_pkt.convert2string()),
               UVM_NONE+50)
         end
      end
      <% } //foreach DMI %>
      <% for(var idx = 0; idx < obj.nDIIs; idx++) { %> 
      if (m_txn.dest_funit_id == <%=obj.DiiInfo[idx].FUnitId%>) begin
         m_txn.dii_bound = 1;
	      <% if (obj.ConnectivityMap.aiuDiiMap[obj.AiuInfo[pidx].FUnitId]) { %>
	         <% for(var j = 0; j < obj.ConnectivityMap.aiuDiiMap[obj.AiuInfo[pidx].FUnitId].length; j++) { %>
            if (m_txn.dest_funit_id == <%=obj.ConnectivityMap.aiuDiiMap[obj.AiuInfo[pidx].FUnitId][j]%>) connected = 1;
	         <% } //foreach aiuDiiMap %>
	      <% } //if aiuDiiMap[obj.AiuInfo[pidx].FUnitId] %>
         if (connected == 0) begin
            `uvm_error(`LABEL, $sformatf(
               "FSYS_UID:%0d : New TXN to unconnected DII. Dest: DII(FunitId:'d%0d). Addr=0x%0h Packet: %0s",
               m_txn.fsys_unique_txn_id, m_txn.dest_funit_id, m_pkt.addr, m_pkt.convert2string()))
         end else begin
            `uvm_info(`LABEL, $sformatf(
               "FSYS_UID:%0d : New transaction with opcode %0s. This should be routed to DII with FunitId 'd%0d. Addr=0x%0h %0s", 
               m_txn.fsys_unique_txn_id, m_pkt.opcode.name(), m_txn.dest_funit_id, m_pkt.addr, m_pkt.convert2string()), UVM_NONE+50)
         end
      end
      <% } //foreach DII %>
      if (((m_txn.dmi_bound == 1 && m_txn.dii_bound == 1)
            || (m_txn.dmi_bound == 0 && m_txn.dii_bound == 0))
          && m_txn.is_dvm == 0) begin
         `uvm_error(`LABEL, $sformatf(
            "FSYS_UID:%0d : Scoreboard addr map logic error. Addr = 0x%0h was translated wrong. dmi_bound=%0d, dmi_bound=%0d.", 
            m_txn.fsys_unique_txn_id, m_pkt.addr, m_txn.dmi_bound, m_txn.dii_bound))
      end // if both DMI and DII flags are set
   end // if not register space
   if (m_pkt.opcode inside { 
      <% if (obj.AiuInfo[pidx].fnNativeInterface == 'CHI-E') { %>
                            <%=_child_blkid[pidx]%>_chi_agent_pkg::STASHONCESEPUNIQUE, 
                            <%=_child_blkid[pidx]%>_chi_agent_pkg::STASHONCESEPSHARED,
      <% } %>
                            <%=_child_blkid[pidx]%>_env_pkg::stash_ops}) begin
      if(m_en_coh_check) begin
            `uvm_info(`LABEL, $sformatf(
               "FSYS_UID:%0d :Opcode:%0s . Addr=0x%0h ns: %0b :init state should be IX, invalidating for agent <%=obj.AiuInfo[pidx].FUnitId%> ",m_txn.fsys_unique_txn_id,m_pkt.opcode.name(),m_pkt.addr, m_pkt.ns),UVM_NONE+50)
          coherency_checker.update_state(.addr(m_pkt.addr),.ns(m_pkt.ns),.funit_idx(<%=obj.AiuInfo[pidx].FUnitId%>),.state(IX));
      end
   end 
   if (m_pkt.opcode inside {<%=_child_blkid[pidx]%>_env_pkg::dataless_ops,  
      <% if (obj.AiuInfo[pidx].fnNativeInterface == 'CHI-E') { %>
                            <%=_child_blkid[pidx]%>_chi_agent_pkg::STASHONCESEPUNIQUE, 
                            <%=_child_blkid[pidx]%>_chi_agent_pkg::STASHONCESEPSHARED,
      <% } %>
                            <%=_child_blkid[pidx]%>_env_pkg::stash_ops}) begin
      m_txn.exp_smi_data_pkts = 0; //default is 1, so need to assign 0
      m_txn.is_dataless_txn = 1; 
   end else begin
      m_txn.exp_chi_data_flits = (((2**m_pkt.size)/(<%=_child_blkid[pidx]%>_env_pkg::WBE) == 0) ? 1 : ((2**m_pkt.size)/(<%=_child_blkid[pidx]%>_env_pkg::WBE))); 
      m_txn.exp_smi_data_pkts = 1;
      if (m_pkt.opcode inside {<%=_child_blkid[pidx]%>_env_pkg::atomic_dat_ops}) begin
         // CHI Spec section 2.10.5: The size of the data value returned in response to an AtomicCompare transaction is
         //half the number of bytes specified in the Size field in the associated Request packet
         if (m_pkt.opcode == 'h39) begin
            m_txn.exp_chi_data_flits = (m_txn.exp_chi_data_flits == 1) ? (2 * m_txn.exp_chi_data_flits) : (m_txn.exp_chi_data_flits + (m_txn.exp_chi_data_flits/2));
         end else begin
            m_txn.exp_chi_data_flits = 2 * m_txn.exp_chi_data_flits;
         end
         m_txn.chi_data_flits_atomic = m_txn.exp_chi_data_flits;
         m_txn.exp_smi_data_pkts = 2;
      end
      if (m_pkt.opcode inside {<%=_child_blkid[pidx]%>_chi_agent_pkg::wr_zero_ops}) begin
         m_txn.exp_chi_data_flits = 0;
      end
   end
   if (m_pkt.opcode inside {<%=_child_blkid[pidx]%>_env_pkg::WRITENOSNPPTL,<%=_child_blkid[pidx]%>_env_pkg::WRITENOSNPFULL, 
            <%=_child_blkid[pidx]%>_chi_agent_pkg::combined_wr_nc_ops, <%=_child_blkid[pidx]%>_chi_agent_pkg::combined_wr_unsupp_ops, 
            <%=_child_blkid[pidx]%>_chi_agent_pkg::WRITEEVICTFULL, <%=_child_blkid[pidx]%>_chi_agent_pkg::EVICT, 
            <% if (obj.AiuInfo[pidx].fnNativeInterface == 'CHI-E') { %>
            <%=_child_blkid[pidx]%>_env_pkg::WRITEEVICTOREVICT,
         <% } %>
            <%=_child_blkid[pidx]%>_chi_agent_pkg::WRITEUNIQUEFULLSTASH, <%=_child_blkid[pidx]%>_chi_agent_pkg::WRITEUNIQUEPTLSTASH}) begin
      m_txn.is_write = 1;
      m_txn.is_coh = 0;
   end else if (m_pkt.opcode inside {<%=_child_blkid[pidx]%>_env_pkg::READNOSNP}) begin
      m_txn.is_read = 1;
      m_txn.is_coh = 0;
   end else begin
      m_txn.is_coh = 1;
      if (m_pkt.opcode inside {<%=_child_blkid[pidx]%>_env_pkg::atomic_dat_ops, <%=_child_blkid[pidx]%>_env_pkg::atomic_dtls_ops}) begin
         m_txn.is_atomic_txn = 1;
      end
      `uvm_info(`LABEL, $sformatf(
         "FSYS_UID:%0d : DCE for this transaction is: 'd%0d(FunitId).", 
         m_txn.fsys_unique_txn_id, m_txn.dce_funit_id), UVM_NONE+50)
      if (m_pkt.opcode inside {<%=_child_blkid[pidx]%>_env_pkg::write_ops, 
                              <%=_child_blkid[pidx]%>_env_pkg::atomic_dat_ops, 
                              <%=_child_blkid[pidx]%>_env_pkg::atomic_dtls_ops}) m_txn.is_write = 1;
      if (m_pkt.opcode inside {<%=_child_blkid[pidx]%>_env_pkg::read_ops, 
                              <%=_child_blkid[pidx]%>_env_pkg::atomic_dat_ops}) m_txn.is_read = 1;
      if (m_txn.dii_bound == 1) begin
         //TODO: Saw CleanSharedPersist go to DII, investigate further
         //`uvm_error(`LABEL, $sformatf(
         //    "FSYS_UID:%0d : A coherent transaction on Addr = 0x%0h is not possible. This addr falls in DII's addr range.",
         //    m_txn.fsys_unique_txn_id, m_pkt.addr))
      end
   end
   if (m_pkt.opcode inside {<%=_child_blkid[pidx]%>_chi_agent_pkg::wr_zero_ops}) begin
      m_txn.is_coh = m_pkt.snpattr;
   end
   if ((m_pkt.order == 2'b10 || m_pkt.order == 2'b11)
      <% if (obj.AiuInfo[pidx].fnNativeInterface != 'CHI-A') { %>
            && m_pkt.opcode inside {<%=_child_blkid[pidx]%>_env_pkg::READNOSNP, 
                                            <%=_child_blkid[pidx]%>_env_pkg::READONCE, 
                                            <%=_child_blkid[pidx]%>_env_pkg::READONCECLEANINVALID, 
                                            <%=_child_blkid[pidx]%>_env_pkg::READONCEMAKEINVALID}) begin
        <%}else{%>
              && m_pkt.opcode inside {<%=_child_blkid[pidx]%>_env_pkg::READNOSNP, <%=_child_blkid[pidx]%>_env_pkg::READONCE}) begin
	<%}%>
      m_txn.readreceipt_exp = 1;
      `uvm_info(`LABEL, $sformatf(
         "FSYS_UID:%0d : READRECEIPT is expected", 
         m_txn.fsys_unique_txn_id), UVM_NONE+50)
   end
   if (m_pkt.opcode inside {<%=_child_blkid[pidx]%>_env_pkg::WRITEUNIQUEFULLSTASH,
                            <% if (obj.AiuInfo[pidx].fnNativeInterface == 'CHI-E') { %>
                            <%=_child_blkid[pidx]%>_chi_agent_pkg::STASHONCESEPSHARED,
                            <%=_child_blkid[pidx]%>_chi_agent_pkg::STASHONCESEPUNIQUE,
                            <%=_child_blkid[pidx]%>_chi_agent_pkg::combined_wr_unsupp_ops,
                            //<%=_child_blkid[pidx]%>_chi_agent_pkg::UNSUP_OPCODE_5,
                            <% } %>
                            <%=_child_blkid[pidx]%>_env_pkg::WRITEUNIQUEPTLSTASH}) begin
      m_txn.chi_unsupp_txn = 1;
      m_txn.exp_smi_data_pkts = 0;
   end
   m_txn.smi_ns = m_pkt.ns;
   m_txn.smi_pr = 0;
   m_txn.smi_qos = m_pkt.qos;
   m_txn.update_time_accessed();
   chi_txn_cnt++;
   fsys_txn_q.push_back(m_txn);

   if (m_pkt.opcode inside {<%=_child_blkid[pidx]%>_chi_agent_pkg::wr_zero_ops}) begin
      //MEM_CONSISTENCY
      if(m_en_mem_check) begin
         index = fsys_txn_q.size()-1; 
         fsys_txn_q[index].chi_cacheline_addr = new[1];
         fsys_txn_q[index].chi_cacheline_addr[0] = {(fsys_txn_q[index].m_chi_req_pkt_<%=pidx%>.addr >> ncoreConfigInfo::WCACHE_OFFSET), <%=obj.wCacheLineOffset%>'b0};
         package_and_send_mem_checker_<%=pidx%>(fsys_txn_q, index, "WR");
      end
   end
endfunction : analyze_chi_req_<%=pidx%>

//====================================================================================================
//
//====================================================================================================
function void fsys_scb_chi_predictor::analyze_chi_crsp_pkt_<%=pidx%>(input <%=_child_blkid[pidx]%>_env_pkg::chi_rsp_seq_item m_pkt, ref fsys_scb_txn fsys_txn_q[$]);
   `undef LABEL
   `define LABEL "chi_crsp_<%=_child_blkid[pidx]%>"
   int find_q[$];
   int cmd_idx;
   find_q = fsys_txn_q.find_index with (
                  item.source_funit_id == <%=obj.AiuInfo[pidx].FUnitId%>
                  && item.m_chi_req_pkt_<%=pidx%> !== null
                  && item.m_chi_req_pkt_<%=pidx%>.txnid == m_pkt.txnid
                  && item.only_waiting_for_compack == 0
                  && (item.comp_seen == 0 || (item.comp_seen == 1 && (!(m_pkt.opcode inside {<%=_child_blkid[pidx]%>_env_pkg::COMPDBIDRESP, <%=_child_blkid[pidx]%>_env_pkg::DBIDRESP}))))
                  && ((item.comp_seen == 0 && m_pkt.opcode == <%=_child_blkid[pidx]%>_env_pkg::COMP) || (m_pkt.opcode !== <%=_child_blkid[pidx]%>_env_pkg::COMP))
                  && item.chi_check_done == 0
                  && (item.aiu_check_done == 0 || (item.readreceipt_exp == 1 && item.readreceipt_seen == 0 && m_pkt.opcode == <%=_child_blkid[pidx]%>_env_pkg::READRECEIPT))
                  //opcode 'h41 is MAKEREADUNIQUE
                  && ((m_pkt.opcode == <%=_child_blkid[pidx]%>_env_pkg::READRECEIPT && item.is_read == 1) || (m_pkt.opcode !== <%=_child_blkid[pidx]%>_env_pkg::READRECEIPT && (item.is_read == 0 || item.m_chi_req_pkt_<%=pidx%>.opcode == 'h41)) || item.is_atomic_txn == 1)
                  && (!(item.m_chi_req_pkt_<%=pidx%>.opcode inside {<%=_child_blkid[pidx]%>_chi_agent_pkg::prefetch_op}))
                  && (item.dbid_val == 0 || (item.readreceipt_exp == 1 && item.readreceipt_seen == 0 && m_pkt.opcode == <%=_child_blkid[pidx]%>_env_pkg::READRECEIPT))
                  && ((item.readreceipt_exp == 1 && item.readreceipt_seen == 0 && m_pkt.opcode == <%=_child_blkid[pidx]%>_env_pkg::READRECEIPT)
                     || (m_pkt.opcode !== <%=_child_blkid[pidx]%>_env_pkg::READRECEIPT)));
   if (find_q.size() == 1) begin
      `uvm_info(`LABEL, $sformatf(
         "FSYS_UID:%0d : Seen CRSP packet. %0s", 
         fsys_txn_q[find_q[0]].fsys_unique_txn_id, 
         m_pkt.convert2string()), UVM_NONE+50)
      fsys_txn_q[find_q[0]].update_time_accessed();
      cmd_idx = fsys_txn_q[find_q[0]].chi_cmd_num;
      if (m_pkt.opcode inside {<%=_child_blkid[pidx]%>_env_pkg::COMPDBIDRESP, <%=_child_blkid[pidx]%>_env_pkg::DBIDRESP}) begin
         fsys_txn_q[find_q[0]].dbid_val = 1;
         fsys_txn_q[find_q[0]].dbid = m_pkt.dbid;
         fsys_txn_q[find_q[0]].compack_dbid_val = 1;
         fsys_txn_q[find_q[0]].compack_dbid = m_pkt.dbid;
         fsys_txn_q[find_q[0]].comp_seen = 1;
         if (fsys_txn_q[find_q[0]].m_chi_req_pkt_<%=pidx%>.opcode inside {<%=_child_blkid[pidx]%>_chi_agent_pkg::wr_zero_ops}) begin
            `uvm_info(`LABEL, $sformatf("FSYS_UID:%0d : Setting aiu_check_done flag", 
               fsys_txn_q[find_q[0]].fsys_unique_txn_id), UVM_NONE+50)
            fsys_txn_q[find_q[0]].aiu_check_done = 1;
            if(m_en_coh_check) begin
                package_and_send_coh_checker_<%=pidx%>(fsys_txn_q[find_q[0]],m_pkt.resperr,m_pkt.resp,0,1,0);
            end
            if (check_flags_and_delete_txn(`LABEL, find_q[0], fsys_txn_q, `__LINE__)) begin
               return;
            end
         end
      end // COMPDBIDRESP or DBIDRESP
      else begin
        if(m_en_coh_check) begin
          if(fsys_txn_q[find_q[0]].m_chi_req_pkt_<%=pidx%>.opcode inside {<%=_child_blkid[pidx]%>_env_pkg::dataless_ops})begin
            package_and_send_coh_checker_<%=pidx%>(fsys_txn_q[find_q[0]],m_pkt.resperr,m_pkt.resp,1,0,0);
          end
        end
      end
      //Since DMI predictor doesn't monitor rbuse, set it's done flag if all data is seen at this point
      if (fsys_txn_q[find_q[0]].exp_chi_data_flits == 0 && fsys_txn_q[find_q[0]].dmi_check_done == 0 && fsys_txn_q[find_q[0]].dce_check_done == 1) begin
         if ((fsys_txn_q[find_q[0]].rbrreq_seen_q[cmd_idx] == 0 || fsys_txn_q[find_q[0]].rbrreq_seen_q[cmd_idx] > 1))
            fsys_txn_q[find_q[0]].dmi_check_done = 1;
      end
      if ((fsys_txn_q[find_q[0]].m_chi_req_pkt_<%=pidx%>.opcode inside {<%=_child_blkid[pidx]%>_env_pkg::dataless_ops, <%=_child_blkid[pidx]%>_env_pkg::stash_ops}
            && m_pkt.opcode inside {<%=_child_blkid[pidx]%>_env_pkg::COMP, <%=_child_blkid[pidx]%>_env_pkg::COMPPERSIST})
         <% if (obj.AiuInfo[pidx].fnNativeInterface == 'CHI-E') { %>
         || (fsys_txn_q[find_q[0]].m_chi_req_pkt_<%=pidx%>.opcode inside {<%=_child_blkid[pidx]%>_chi_agent_pkg::combined_wr_nc_ops, <%=_child_blkid[pidx]%>_chi_agent_pkg::combined_wr_c_ops, <%=_child_blkid[pidx]%>_chi_agent_pkg::combined_wr_unsupp_ops}
            && (m_pkt.opcode == <%=_child_blkid[pidx]%>_chi_agent_pkg::COMPCMO || m_pkt.opcode == <%=_child_blkid[pidx]%>_chi_agent_pkg::COMPPERSIST)
            && fsys_txn_q[find_q[0]].chi_cmd_num == 1)
         || (fsys_txn_q[find_q[0]].m_chi_req_pkt_<%=pidx%>.opcode == <%=_child_blkid[pidx]%>_chi_agent_pkg::MAKEREADUNIQUE
            && fsys_txn_q[find_q[0]].m_chi_req_pkt_<%=pidx%>.excl == 1
            && fsys_txn_q[find_q[0]].is_dataless_txn == 1
            && m_pkt.opcode == <%=_child_blkid[pidx]%>_env_pkg::COMP)
         <% } %>
         ) begin
            fsys_txn_q[find_q[0]].comp_seen = 1;
            if (fsys_txn_q[find_q[0]].m_chi_req_pkt_<%=pidx%>.expcompack == 1 && fsys_txn_q[find_q[0]].compack_seen == 0) begin
               if (fsys_txn_q[find_q[0]].compack_dbid_val == 0) begin
                  fsys_txn_q[find_q[0]].compack_dbid_val = 1;
                  fsys_txn_q[find_q[0]].compack_dbid = m_pkt.dbid;
               end
               fsys_txn_q[find_q[0]].only_waiting_for_compack = 1;
            end else if (fsys_txn_q[find_q[0]].aiu_str_seen == 1) begin
               //TODO: Add checks to make sure NCore related steps were done before deleting
               `uvm_info(`LABEL, $sformatf("FSYS_UID:%0d : Setting aiu_check_done flag", 
                  fsys_txn_q[find_q[0]].fsys_unique_txn_id), UVM_NONE+50)
               fsys_txn_q[find_q[0]].aiu_check_done = 1;
               if (check_flags_and_delete_txn(`LABEL, find_q[0], fsys_txn_q, `__LINE__)) begin
                  return;
               end
            end else begin
               fsys_txn_q[find_q[0]].delete_at_str = 1;
            end
            if (m_pkt.resperr > 2'b01) begin
               `uvm_info(`LABEL, $sformatf("FSYS_UID:%0d : COMP with resperr=0x%0h. Deleting the txn from queue", 
                  fsys_txn_q[find_q[0]].fsys_unique_txn_id, m_pkt.resperr), UVM_NONE+50)
                  if (check_flags_and_delete_txn(`LABEL, find_q[0], fsys_txn_q, `__LINE__, 1)) begin
                     return;
                  end
            end
      end // DATALESS COMP response
      <% if (obj.AiuInfo[pidx].fnNativeInterface == 'CHI-E') { %>
      if (fsys_txn_q[find_q[0]].m_chi_req_pkt_<%=pidx%>.opcode inside {
                            <%=_child_blkid[pidx]%>_chi_agent_pkg::STASHONCESEPSHARED,
                            <%=_child_blkid[pidx]%>_chi_agent_pkg::STASHONCESEPUNIQUE
                            }
          && m_pkt.opcode == <%=_child_blkid[pidx]%>_env_pkg::COMP) begin

         if (check_flags_and_delete_txn(`LABEL, find_q[0], fsys_txn_q, `__LINE__, 1)) begin
            return;
         end
      end // unsupported stashes
      <% } %>

      if (fsys_txn_q[find_q[0]].readreceipt_exp == 1 && fsys_txn_q[find_q[0]].readreceipt_seen == 0 && m_pkt.opcode == <%=_child_blkid[pidx]%>_env_pkg::READRECEIPT) begin
         fsys_txn_q[find_q[0]].readreceipt_seen = 1;
         if ((fsys_txn_q[find_q[0]].m_chi_req_pkt_<%=pidx%>.expcompack == 0)
                  || (fsys_txn_q[find_q[0]].m_chi_req_pkt_<%=pidx%>.expcompack == 1 && fsys_txn_q[find_q[0]].compack_seen == 1)) begin
            if (fsys_txn_q[find_q[0]].exp_chi_data_flits == 0) begin
               `uvm_info(`LABEL, $sformatf("FSYS_UID:%0d : Setting aiu_check_done flag", 
                  fsys_txn_q[find_q[0]].fsys_unique_txn_id), UVM_NONE+50)
               fsys_txn_q[find_q[0]].aiu_check_done = 1;
            end
         end
         check_flags_and_delete_txn(`LABEL, find_q[0], fsys_txn_q, `__LINE__);
      end //READRECEIPT
   end else begin
      //TODO: COMP separately for write trasanctions isn't supported yet. Skipping error for now.
      if (m_pkt.opcode !== <%=_child_blkid[pidx]%>_env_pkg::chi_rsp_opcode_enum_t'('h4)) begin
         foreach(find_q[err_idx])begin
            fsys_txn_q[find_q[err_idx]].print_me();
         end
         `uvm_error(`LABEL, $sformatf(
            "FSYS_SCB: The CRESP packet didn't match any pending transactions. Total matches: %0d. %0s",
            find_q.size(), m_pkt.convert2string()))
      end else 
         foreach(find_q[err_idx])begin
            fsys_txn_q[find_q[err_idx]].print_me();
         end
         `uvm_info(`LABEL, $sformatf(
            "FSYS_SCB: The CRESP COMP packet - Not Yet Implemented. Total matches: %0d. %0s", 
            find_q.size(), m_pkt.convert2string()), UVM_NONE+50)
   end
endfunction : analyze_chi_crsp_pkt_<%=pidx%>

//====================================================================================================
//
//====================================================================================================
function void fsys_scb_chi_predictor::analyze_chi_srsp_pkt_<%=pidx%>(input <%=_child_blkid[pidx]%>_env_pkg::chi_rsp_seq_item m_pkt, ref fsys_scb_txn fsys_txn_q[$]);
   `undef LABEL
   `define LABEL "chi_srsp_<%=_child_blkid[pidx]%>"
   int find_q[$];
   bit match_found = 0;
   int cmd_idx;
   if (m_pkt.opcode == <%=_child_blkid[pidx]%>_env_pkg::SNPRESP) begin
      foreach (fsys_txn_q[idx]) begin
         if (fsys_txn_q[idx].chi_snp_txnid_q.size() > 0) begin
            foreach (fsys_txn_q[idx].chi_snp_txnid_q[i]) begin
               if (fsys_txn_q[idx].snpreq_targ_id_q[i] == <%=obj.AiuInfo[pidx].FUnitId%>
                  && fsys_txn_q[idx].chi_snp_txnid_q[i] == m_pkt.txnid
               ) begin
                  `uvm_info(`LABEL, $sformatf(
                     "FSYS_UID:%0d : CHI SNPResp seen. %0s", 
                     fsys_txn_q[idx].fsys_unique_txn_id, 
                     m_pkt.convert2string()), UVM_NONE+50)
                  fsys_txn_q[idx].chi_snp_txnid_q[i] = -2;
                  fsys_txn_q[idx].update_time_accessed();
                  match_found = 1;
                  if (m_pkt.datapull == 1 && fsys_txn_q[idx].is_stash_txn == 1) begin
                     fsys_txn_q[idx].dbid_val = 1;
                     fsys_txn_q[idx].dbid = m_pkt.dbid;
                  end
                  if(m_en_coh_check) begin
                     package_and_send_coh_checker_<%=pidx%>(fsys_txn_q[idx],m_pkt.resperr,m_pkt.resp,0,0,1,i);

                  end
                  break;
               end // if matched
            end // foreach CMDReq
         end // if there are pending CMDReqs
         if (match_found == 1) break;
      end //foreach pending txn 
      if (match_found == 0) begin
         `uvm_error(`LABEL, $sformatf(
            "FSYS_SCB: CHI SNPResp didn't match any pending transactions. %0s",
            m_pkt.convert2string()))
      end
      return;
   end // SNP responses

   find_q = fsys_txn_q.find_index with (
                  (item.source_funit_id == <%=obj.AiuInfo[pidx].FUnitId%> || item.stash_accept == 1 && item.smi_stash_nid == <%=obj.AiuInfo[pidx].FUnitId%>)
                  && ((item.m_chi_req_pkt_<%=pidx%> !== null && item.m_chi_req_pkt_<%=pidx%>.expcompack == 1)
                     || (item.stash_accept == 1 && item.smi_stash_nid == <%=obj.AiuInfo[pidx].FUnitId%>))
                  && item.compack_seen == 0
                  && item.compack_dbid_val == 1
                  && item.compack_dbid == m_pkt.txnid);
   if (find_q.size() == 1) begin
      `uvm_info(`LABEL, $sformatf(
         "FSYS_UID:%0d : Seen SRSP packet. %0s", 
         fsys_txn_q[find_q[0]].fsys_unique_txn_id, 
         m_pkt.convert2string()), UVM_NONE+50)
      fsys_txn_q[find_q[0]].update_time_accessed();
      cmd_idx = fsys_txn_q[find_q[0]].chi_cmd_num;
      if (m_pkt.opcode == <%=_child_blkid[pidx]%>_env_pkg::COMPACK) begin
         fsys_txn_q[find_q[0]].compack_seen = 1;
         if (fsys_txn_q[find_q[0]].is_stash_txn == 1 
            && fsys_txn_q[find_q[0]].exp_chi_data_flits == 0
            && (fsys_txn_q[find_q[0]].axi_write_resp_seen == 1 || fsys_txn_q[find_q[0]].ioaiu_core_id < 0)) begin
            check_flags_and_delete_txn(`LABEL, find_q[0], fsys_txn_q, `__LINE__, 1);
         end else if (fsys_txn_q[find_q[0]].readreceipt_exp == 1 && fsys_txn_q[find_q[0]].readreceipt_seen == 0) begin
            fsys_txn_q[find_q[0]].compack_dbid_val = 0;
         end else begin
            if (fsys_txn_q[find_q[0]].dmi_check_done == 0) begin
               if ((fsys_txn_q[find_q[0]].rbrreq_seen_q[cmd_idx] == 0 
                     || fsys_txn_q[find_q[0]].rbrreq_seen_q[cmd_idx] > 1)
                  && fsys_txn_q[find_q[0]].exp_chi_data_flits == 0
                  && (fsys_txn_q[find_q[0]].is_write == 0 || fsys_txn_q[find_q[0]].exp_smi_data_pkts == 0)
               )
                  fsys_txn_q[find_q[0]].dmi_check_done = 1;
            end
            if (fsys_txn_q[find_q[0]].aiu_str_seen == 1 
               && fsys_txn_q[find_q[0]].exp_chi_data_flits == 0
               && ((fsys_txn_q[find_q[0]].combined_cmd == 0) || (fsys_txn_q[find_q[0]].combined_cmd == 1 && fsys_txn_q[find_q[0]].chi_cmd_num == 1))) begin
               `uvm_info(`LABEL, $sformatf("FSYS_UID:%0d : Setting aiu_check_done flag", 
                  fsys_txn_q[find_q[0]].fsys_unique_txn_id), UVM_NONE+50)
               fsys_txn_q[find_q[0]].aiu_check_done = 1;
            end
            if (!check_flags_and_delete_txn(`LABEL, find_q[0], fsys_txn_q, `__LINE__)) begin
               //If txn wasn't deleted with just aiu_str_seen & hence ->aiu_check_done, reset aiu_check_done.
               `uvm_info(`LABEL, $sformatf("FSYS_UID:%0d : Resetting aiu_check_done flag", 
                  fsys_txn_q[find_q[0]].fsys_unique_txn_id), UVM_NONE+50)
               fsys_txn_q[find_q[0]].aiu_check_done = 0;
               //After COMPACK the CHI txnid will be reused, mark it as -1 here because this UID is not getting deleted
               // This way we don't have multiple matches.
               if (fsys_txn_q[find_q[0]].exp_chi_data_flits == 0 && fsys_txn_q[find_q[0]].m_chi_req_pkt_<%=pidx%> !== null
                   && ((fsys_txn_q[find_q[0]].combined_cmd == 0) || (fsys_txn_q[find_q[0]].combined_cmd == 1 && fsys_txn_q[find_q[0]].chi_cmd_num == 1))) begin
                  fsys_txn_q[find_q[0]].m_chi_req_pkt_<%=pidx%>.txnid = -1;
               end 
               if (fsys_txn_q[find_q[0]].exp_chi_data_flits == 0
                   && fsys_txn_q[find_q[0]].aiu_str_seen == 1
                   && ((fsys_txn_q[find_q[0]].combined_cmd == 0) || (fsys_txn_q[find_q[0]].combined_cmd == 1 && fsys_txn_q[find_q[0]].chi_cmd_num == 1))) begin
                  `uvm_info(`LABEL, $sformatf("FSYS_UID:%0d : Setting aiu_check_done flag", 
                     fsys_txn_q[find_q[0]].fsys_unique_txn_id),
                     UVM_NONE+50)
                  fsys_txn_q[find_q[0]].aiu_check_done = 1;
                  if(check_flags_and_delete_txn(`LABEL, find_q[0], fsys_txn_q, `__LINE__)) return;
               end
               if (fsys_txn_q[find_q[0]].is_read || (fsys_txn_q[find_q[0]].is_write && fsys_txn_q[find_q[0]].exp_chi_data_flits ==0)
                  || (fsys_txn_q[find_q[0]].is_stash_txn == 1)) begin
                  fsys_txn_q[find_q[0]].compack_dbid_val = 0;
               end
               if (fsys_txn_q[find_q[0]].is_write && fsys_txn_q[find_q[0]].exp_chi_data_flits ==0) begin
                  fsys_txn_q[find_q[0]].dbid_val = 0;
               end
            end
         end // else
      end // COMPACK response
   end else begin
      // TODO: Improve this error message for debug purposes, also account for more than 1 match
      // TODO: Only support for COMPACK is added for now, no other responses are supported, remove below if when other opcodes are supported
      if (m_pkt.opcode == <%=_child_blkid[pidx]%>_env_pkg::COMPACK)
         foreach(find_q[idx])
            fsys_txn_q[find_q[idx]].print_me();
         `uvm_error(`LABEL, $sformatf(
            "FSYS_SCB: The SRESP packet didn't match any pending transactions. Total matches 'd%0d.  %0s",
            find_q.size(), m_pkt.convert2string()))
   end
endfunction : analyze_chi_srsp_pkt_<%=pidx%>

//====================================================================================================
//
//====================================================================================================
function void fsys_scb_chi_predictor::analyze_chi_snpaddr_pkt_<%=pidx%>(input <%=_child_blkid[pidx]%>_env_pkg::chi_snp_seq_item m_pkt, ref fsys_scb_txn fsys_txn_q[$]); 
   `undef LABEL
   `define LABEL "chi_snpaddr_<%=_child_blkid[pidx]%>"
   bit match_found = 0;
   bit addr_match = 0;
   int find_q[$];
   //First delete all non-existing UIDs
   for(int idx = smi_snpreq_order_uid_<%=pidx%>.size()-1; idx >=0; idx--) begin
      find_q = fsys_txn_q.find_index with (item.fsys_unique_txn_id == smi_snpreq_order_uid_<%=pidx%>[idx]);
      if (find_q.size() == 0) begin
         smi_snpreq_order_uid_<%=pidx%>.delete(idx);
      end
   end
   find_q.delete();
   foreach (smi_snpreq_order_uid_<%=pidx%>[idx]) begin
      find_q = fsys_txn_q.find_index with (item.fsys_unique_txn_id == smi_snpreq_order_uid_<%=pidx%>[idx]);
      if (find_q.size() == 1) begin
         foreach (fsys_txn_q[find_q[0]].snpreq_msg_id_q[i]) begin
            addr_match = 0;
            //`uvm_info(`LABEL, $psprintf(
            //    "cmd_addr_q[%0d]=0x%0h. snpreq_cnt = 'd%0d. fsys_txn_q[find_q[0]].snpreq_msg_id[i] = 0x%0h, snoops exp = 'd%0d", 
            //    i, fsys_txn_q[find_q[0]].cmd_addr_q[i], fsys_txn_q[find_q[0]].snpreq_cnt_q[i], fsys_txn_q[find_q[0]].snpreq_msg_id_q[i],
            //    fsys_txn_q[find_q[0]].snoops_exp_q[i]), UVM_NONE+50)
            if ((fsys_txn_q[find_q[0]].cmd_addr_q[i] >> 3) == m_pkt.addr && m_pkt.opcode !== <%=_child_blkid[pidx]%>_chi_agent_pkg::SNPDVMOP) begin
               addr_match = 1;
               fsys_txn_q[find_q[0]].is_snp = 1;
               fsys_txn_q[find_q[0]].chi_snpreq_addr = m_pkt.addr << 3; 

            end
            else if ((fsys_txn_q[find_q[0]].recall_addr >> 3) == m_pkt.addr && m_pkt.opcode !== <%=_child_blkid[pidx]%>_chi_agent_pkg::SNPDVMOP) begin
               addr_match = 1;
               fsys_txn_q[find_q[0]].is_snp = 1;
               fsys_txn_q[find_q[0]].chi_snpreq_addr = m_pkt.addr << 3; 
            end
            else if (fsys_txn_q[find_q[0]].is_dvm == 1 && m_pkt.opcode == <%=_child_blkid[pidx]%>_chi_agent_pkg::SNPDVMOP
                     && (((fsys_txn_q[find_q[0]].dvm_part_1_addr_q[i] >> 3) == m_pkt.addr && fsys_txn_q[find_q[0]].dvm_snp_1_seen_at_aiu == 1)
                     || ((fsys_txn_q[find_q[0]].dvm_part_2_addr_q[i] >> 3) == m_pkt.addr && fsys_txn_q[find_q[0]].dvm_snp_2_seen_at_aiu == 1))) begin
               addr_match = 1;
            end
            if(addr_match)begin
               fsys_txn_q[find_q[0]].m_chi_snp_pkt_<%=pidx%> = new();
               fsys_txn_q[find_q[0]].m_chi_snp_pkt_<%=pidx%>.copy(m_pkt);
            end
            if (addr_match == 1
               && fsys_txn_q[find_q[0]].only_waiting_for_mrd == 0
               && ((fsys_txn_q[find_q[0]].is_dvm == 0 && m_pkt.stashlpidvalid == 1 
                    && fsys_txn_q[find_q[0]].smi_stash_lpid == m_pkt.stashlpid) || (m_pkt.stashlpidvalid == 0 || fsys_txn_q[find_q[0]].is_dvm == 1))
               && fsys_txn_q[find_q[0]].snpreq_unq_id_q.size() > 0 
             ) begin
               foreach(fsys_txn_q[find_q[0]].snpreq_targ_id_q[j]) begin
                  if (fsys_txn_q[find_q[0]].snpreq_targ_id_q[j] == <%=obj.AiuInfo[pidx].FUnitId%>
                     && ((fsys_txn_q[find_q[0]].chi_dvm_snp_addr_seen_q[j] == 0 && fsys_txn_q[find_q[0]].is_dvm == 1)
                        || (fsys_txn_q[find_q[0]].is_dvm == 0 && fsys_txn_q[find_q[0]].chi_snp_txnid_q[j] == -1 && m_pkt.addr == (fsys_txn_q[find_q[0]].snpreq_addr_q[j] >> 3)))) begin
                     `uvm_info(`LABEL, $sformatf(
                        "FSYS_UID:%0d : CHI SNP packet seen. %0s", 
                        fsys_txn_q[find_q[0]].fsys_unique_txn_id,
                        m_pkt.convert2string()), UVM_NONE+50)
                     if (fsys_txn_q[find_q[0]].is_dvm && ((fsys_txn_q[find_q[0]].dvm_part_1_addr_q[i] >> 3) == m_pkt.addr)) begin
                        `uvm_info(`LABEL, $sformatf(
                           "FSYS_UID:%0d : DVM part-1 SNP REQ", 
                           fsys_txn_q[find_q[0]].fsys_unique_txn_id), UVM_NONE+50)
                     end else begin
                        if (fsys_txn_q[find_q[0]].is_dvm) fsys_txn_q[find_q[0]].chi_dvm_snp_addr_seen_q[j] = 1;
                        fsys_txn_q[find_q[0]].chi_snp_txnid_q[j] = m_pkt.txnid;
                        // Calculating SNPRESPDATA flits using pkt size == 6(64bytes). There should be cacheline size variable instead.
                        fsys_txn_q[find_q[0]].chi_snp_data_count_q[j] = (((2**6)/(<%=_child_blkid[pidx]%>_env_pkg::WBE) == 0) ? 1 : ((2**6)/(<%=_child_blkid[pidx]%>_env_pkg::WBE)));
                     end
                     fsys_txn_q[find_q[0]].update_time_accessed();
                     match_found = 1;
                     smi_snpreq_order_uid_<%=pidx%>.delete(idx);
                     break;
                  end // if unique ID matches
               end //foreach unique ID
            end // if matched
            if (match_found == 1) break;
         end // foreach CMDReq
      end // if there are pending CMDReqs
      if (match_found == 1) break;
   end //foreach pending txn 
   if (match_found == 0) begin
      `uvm_error(`LABEL, $sformatf(
         "FSYS_SCB: CHI SNPReq didn't match any pending transactions. %0s", 
         m_pkt.convert2string()))
   end
endfunction : analyze_chi_snpaddr_pkt_<%=pidx%>

//====================================================================================================
//
//====================================================================================================
function void fsys_scb_chi_predictor::analyze_chi_rdata_pkt_<%=pidx%>(input <%=_child_blkid[pidx]%>_env_pkg::chi_dat_seq_item m_pkt, ref fsys_scb_txn fsys_txn_q[$]);
   `undef LABEL
   `define LABEL "chi_rdata_<%=_child_blkid[pidx]%>"
   int find_q[$];
   //first check for register packets
   find_q = fsys_txn_q.find_index with (
                  (item.m_chi_req_pkt_<%=pidx%> !== null
                  && item.m_chi_req_pkt_<%=pidx%>.txnid == m_pkt.txnid
                  && (!(item.m_chi_req_pkt_<%=pidx%>.opcode inside {<%=_child_blkid[pidx]%>_chi_agent_pkg::prefetch_op}))
                  && item.register_txn == 1));
   if (find_q.size() == 1) begin
      fsys_txn_q[find_q[0]].exp_chi_data_flits = fsys_txn_q[find_q[0]].exp_chi_data_flits - 1;
      fsys_txn_q[find_q[0]].update_time_accessed();
      `uvm_info(`LABEL, $sformatf(
         "FSYS_UID:%0d : Seen read data. Remaining data flits to receive 'd%0d. %0s", 
         fsys_txn_q[find_q[0]].fsys_unique_txn_id, 
         fsys_txn_q[find_q[0]].exp_chi_data_flits, 
         m_pkt.convert2string()), UVM_NONE+50)
      if(fsys_txn_q[find_q[0]].exp_chi_data_flits == 0) begin
         check_flags_and_delete_txn(`LABEL, find_q[0], fsys_txn_q, `__LINE__, 1);
      end
      return;
   end
   `uvm_info(`LABEL, $sformatf("Seen read data for non-register packet"), UVM_NONE+50)
   find_q = fsys_txn_q.find_index with (
                  ((item.source_funit_id == <%=obj.AiuInfo[pidx].FUnitId%> && item.stash_accept == 0)
                     || (item.stash_accept == 1 && item.smi_stash_nid == <%=obj.AiuInfo[pidx].FUnitId%>))
                  && ((item.m_chi_req_pkt_<%=pidx%> !== null && item.m_chi_req_pkt_<%=pidx%>.txnid == m_pkt.txnid)
                     || (item.is_stash_txn == 1 && item.stash_accept == 1 && item.dbid_val == 1 && item.dbid == m_pkt.txnid))
                  && (item.is_read == 1 || item.is_stash_txn == 1)
                  && item.exp_chi_data_flits > 0
                  && (item.aiu_check_done == 0 || (item.is_stash_txn == 1 && item.ioaiu_core_id >=0))    // some packets are only waiting for RBUse or COMPACK
                  && item.register_txn == 0);
   if (find_q.size() == 1) begin
      fsys_txn_q[find_q[0]].update_time_accessed();
      fsys_txn_q[find_q[0]].exp_chi_data_flits = fsys_txn_q[find_q[0]].exp_chi_data_flits - 1;
      //MEM_CONSISTENCY
      if(m_en_mem_check) begin
         if (fsys_txn_q[find_q[0]].is_stash_txn == 0)
            fsys_txn_q[find_q[0]].save_chi_txn_data_<%=pidx%>(m_pkt);
      end

      `uvm_info(`LABEL, $sformatf(
         "FSYS_UID:%0d : Seen read data. Remaining data flits to receive 'd%0d. %0s", 
         fsys_txn_q[find_q[0]].fsys_unique_txn_id, 
         fsys_txn_q[find_q[0]].exp_chi_data_flits, 
         m_pkt.convert2string()), UVM_NONE+50)

      if (fsys_txn_q[find_q[0]].exp_chi_data_flits == 0) begin
         //MEM_CONSISTENCY
         if(m_en_mem_check) begin
            if (fsys_txn_q[find_q[0]].is_stash_txn == 0)
               package_and_send_mem_checker_<%=pidx%>(fsys_txn_q, find_q[0], "RD");
         end
         //COH_CONSISTENCY
         if(m_en_coh_check) begin
            if (fsys_txn_q[find_q[0]].is_stash_txn == 0)
               package_and_send_coh_checker_<%=pidx%>(fsys_txn_q[find_q[0]],m_pkt.resperr,m_pkt.resp,1,0,0);
         end
      end

      if (fsys_txn_q[find_q[0]].is_stash_txn == 0) begin
         if(fsys_txn_q[find_q[0]].exp_chi_data_flits == 0 
            && (fsys_txn_q[find_q[0]].m_chi_req_pkt_<%=pidx%>.expcompack == 0 || (fsys_txn_q[find_q[0]].m_chi_req_pkt_<%=pidx%>.expcompack == 1 && fsys_txn_q[find_q[0]].compack_seen == 1))
            && (fsys_txn_q[find_q[0]].readreceipt_exp == 0 || (fsys_txn_q[find_q[0]].readreceipt_exp == 1 && fsys_txn_q[find_q[0]].readreceipt_seen == 1))) begin
            if(fsys_txn_q[find_q[0]].exp_chi_data_flits == 0 && fsys_txn_q[find_q[0]].aiu_str_seen == 1) begin
               `uvm_info(`LABEL, $sformatf("FSYS_UID:%0d : Setting aiu_check_done flag", 
                  fsys_txn_q[find_q[0]].fsys_unique_txn_id), 
                  UVM_NONE+50)
               fsys_txn_q[find_q[0]].aiu_check_done = 1;
            end
            if((fsys_txn_q[find_q[0]].rbrreq_seen_q[0] == 0 || fsys_txn_q[find_q[0]].rbrreq_seen_q[0] > 1)
               && (fsys_txn_q[find_q[0]].mrdreq_seen_q[0] == 0 || fsys_txn_q[find_q[0]].mrdreq_seen_q[0] == 2)) begin
             fsys_txn_q[find_q[0]].dmi_check_done = 1;
           end
            if (!check_flags_and_delete_txn(`LABEL, find_q[0], fsys_txn_q, `__LINE__)) begin
               if(fsys_txn_q[find_q[0]].exp_chi_data_flits == 0 && fsys_txn_q[find_q[0]].aiu_str_seen == 1) begin
                  `uvm_info(`LABEL, $sformatf("FSYS_UID:%0d : Setting aiu_check_done flag", 
                     fsys_txn_q[find_q[0]].fsys_unique_txn_id), 
                     UVM_NONE+50)
                  fsys_txn_q[find_q[0]].aiu_check_done = 1;
               end
               if (fsys_txn_q[find_q[0]].exp_chi_data_flits == 0 && fsys_txn_q[find_q[0]].m_chi_req_pkt_<%=pidx%>.expcompack == 0) begin
                  //CHI i/f packets are all seen, only SMI i/f packets left to be seen
                  //Assign chi_check_done flag to 1 indicating CHI i/f checks are done.
                  //For now this variable is only used here. TODO: Extend the usage to all txns
                  fsys_txn_q[find_q[0]].chi_check_done = 1;
               end
            end // DMI, DII check done flags not set
         end
         else if(fsys_txn_q[find_q[0]].m_chi_req_pkt_<%=pidx%>.expcompack == 1 && fsys_txn_q[find_q[0]].compack_seen == 0) begin
            fsys_txn_q[find_q[0]].compack_dbid_val = 1;
            fsys_txn_q[find_q[0]].compack_dbid = m_pkt.dbid;
         end
      end else begin
         if (fsys_txn_q[find_q[0]].dmi_check_done == 0) begin
            if ((fsys_txn_q[find_q[0]].rbrreq_seen_q[0] == 0 
                  || fsys_txn_q[find_q[0]].rbrreq_seen_q[0] > 1)
               && fsys_txn_q[find_q[0]].exp_chi_data_flits == 0
               && (fsys_txn_q[find_q[0]].is_write == 0 || fsys_txn_q[find_q[0]].exp_smi_data_pkts == 0)
            )
               fsys_txn_q[find_q[0]].dmi_check_done = 1;
         end
         if (fsys_txn_q[find_q[0]].compack_seen == 0) begin
            fsys_txn_q[find_q[0]].compack_dbid_val = 1;
            fsys_txn_q[find_q[0]].compack_dbid = m_pkt.dbid;
         end else begin
            if (fsys_txn_q[find_q[0]].exp_chi_data_flits == 0
               && (fsys_txn_q[find_q[0]].axi_write_resp_seen == 1 || fsys_txn_q[find_q[0]].ioaiu_core_id < 0)) begin
               `uvm_info(`LABEL, $sformatf("FSYS_UID:%0d : Setting aiu_check_done flag", 
                  fsys_txn_q[find_q[0]].fsys_unique_txn_id), 
                  UVM_NONE+50)
               fsys_txn_q[find_q[0]].aiu_check_done = 1;
               if (check_flags_and_delete_txn(`LABEL, find_q[0], fsys_txn_q, `__LINE__)) begin
                  return;
               end
            end
         end
      end // stash txn
   end else begin
      // TODO: Improve this error message for debug purposes, also account for more than 1 match
      `uvm_error(`LABEL, $sformatf(
         "FSYS_SCB: Read data packet didn't match any pending transactions. Total matches %0d. %0s",
         find_q.size(), m_pkt.convert2string()))
   end
endfunction : analyze_chi_rdata_pkt_<%=pidx%>

//====================================================================================================
//
//====================================================================================================
function void fsys_scb_chi_predictor::analyze_chi_wdata_pkt_<%=pidx%>(input <%=_child_blkid[pidx]%>_env_pkg::chi_dat_seq_item m_pkt, ref fsys_scb_txn fsys_txn_q[$]);
   `undef LABEL
   `define LABEL "chi_wdata_<%=_child_blkid[pidx]%>"
   int find_q[$];
   bit match_found = 0;
   if (m_pkt.opcode inside {<%=_child_blkid[pidx]%>_env_pkg::SNPRESPDATA, <%=_child_blkid[pidx]%>_env_pkg::SNPRESPDATAPTL, <%=_child_blkid[pidx]%>_env_pkg::SNPRESPDATAFWDED}) begin
      foreach (fsys_txn_q[idx]) begin
         if (fsys_txn_q[idx].chi_snp_txnid_q.size() > 0) begin
            foreach (fsys_txn_q[idx].chi_snp_txnid_q[i]) begin
               if (fsys_txn_q[idx].snpreq_targ_id_q[i] == <%=obj.AiuInfo[pidx].FUnitId%>
                  && fsys_txn_q[idx].chi_snp_txnid_q[i] == m_pkt.txnid
               ) begin
                  fsys_txn_q[idx].chi_snp_data_count_q[i] = fsys_txn_q[idx].chi_snp_data_count_q[i] - 1;
                  `uvm_info(`LABEL, $sformatf(
                     "FSYS_UID:%0d : CHI SNPRespData seen(%0s). Remaining data flits: 'd%0d. %0s",
                     fsys_txn_q[idx].fsys_unique_txn_id, m_pkt.opcode.name,
                     fsys_txn_q[idx].chi_snp_data_count_q[i], m_pkt.convert2string()), 
                     UVM_NONE+50)
                  //MEM_CONSISTENCY
                  if(m_en_mem_check) begin
                     fsys_txn_q[idx].save_chi_snp_data_<%=pidx%>(m_pkt, <%=obj.AiuInfo[pidx].FUnitId%>, fsys_txn_q[idx].snpreq_addr_q[i]);
                  end
                  if(m_en_coh_check) begin
                     package_and_send_coh_checker_<%=pidx%>(fsys_txn_q[idx],m_pkt.resperr,m_pkt.resp,0,0,1,i);
                  end
                  if (fsys_txn_q[idx].chi_snp_data_count_q[i] == 0) begin
                     fsys_txn_q[idx].chi_snp_txnid_q[i] = -2;
                     if (fsys_txn_q[idx].snp_up_q[i] !== 'b00) begin
                        fsys_txn_q[idx].read_acc_dtr_exp_q[i] = 1;
                     end // read acceleration by providing DTR to requesting AIU
                     // Add this SNP's RBID from RBRReq to rbid queue. This way DTW lookup equation remains same
                     //fsys_txn_q[idx].rbid_val_q.push_back(1);
                     //fsys_txn_q[idx].rbid_q.push_back(fsys_txn_q[idx].rbr_rbid_q[i]);
                     //fsys_txn_q[idx].rbid_unit_id_q.push_back(fsys_txn_q[idx].cmd_did_q[i]);
                     //fsys_txn_q[idx].snpdat_unit_id_q.push_back(<%=obj.AiuInfo[pidx].FUnitId%>);
                     if (fsys_txn_q[idx].ioaiu_core_id < 0)
                        fsys_txn_q[idx].exp_smi_data_pkts = fsys_txn_q[idx].exp_smi_data_pkts + 1;
                     if (m_pkt.datapull == 1 && fsys_txn_q[idx].is_stash_txn == 1) begin
                        fsys_txn_q[idx].dbid_val = 1;
                        fsys_txn_q[idx].dbid = m_pkt.dbid;
                        fsys_txn_q[idx].chi_snp_data_count_q[i] = (((2**6)/(<%=_child_blkid[pidx]%>_env_pkg::WBE) == 0) ? 1 : ((2**6)/(<%=_child_blkid[pidx]%>_env_pkg::WBE)));
                     end
                  end // if all data seen
                  fsys_txn_q[idx].update_time_accessed();
                  match_found = 1;
                  break;
               end // if matched
            end // foreach CMDReq
         end // if there are pending CMDReqs
         if (match_found == 1) break;
      end //foreach pending txn 
      if (match_found == 0) begin
         `uvm_error(`LABEL, $sformatf(
            "FSYS_SCB: CHI SNPRespData didn't match any pending transactions. %0s", 
            m_pkt.convert2string()))
      end
      return;
   end // SNP responses
   //first check for register packets
   find_q = fsys_txn_q.find_index with (
                  (item.m_chi_req_pkt_<%=pidx%> !== null
                  && item.dbid_val == 1
                  && item.dbid == m_pkt.txnid
                  && item.register_txn == 1));
   if (find_q.size() == 1) begin
      fsys_txn_q[find_q[0]].update_time_accessed();
      fsys_txn_q[find_q[0]].exp_chi_data_flits = fsys_txn_q[find_q[0]].exp_chi_data_flits - 1;
      `uvm_info(`LABEL, $sformatf(
         "FSYS_UID:%0d : Seen write data. Remaining data flits to receive 'd%0d. %0s",
         fsys_txn_q[find_q[0]].fsys_unique_txn_id, fsys_txn_q[find_q[0]].exp_chi_data_flits,
         m_pkt.convert2string()), UVM_NONE+50)
      if(fsys_txn_q[find_q[0]].exp_chi_data_flits == 0) begin
         `uvm_info(`LABEL, $sformatf("FSYS_UID:%0d : Setting aiu_check_done flag", 
            fsys_txn_q[find_q[0]].fsys_unique_txn_id), 
            UVM_NONE+50)
         if(m_en_coh_check) begin
            package_and_send_coh_checker_<%=pidx%>(fsys_txn_q[find_q[0]],m_pkt.resperr,m_pkt.resp,0,1,0);
         end
         fsys_txn_q[find_q[0]].aiu_check_done = 1;
      end
      return;
   end 
   `uvm_info(`LABEL, $sformatf("Seen write data for non-register packet"), UVM_NONE+50)
   find_q = fsys_txn_q.find_index with (
                  (item.source_funit_id == <%=obj.AiuInfo[pidx].FUnitId%>)
                  && (item.m_chi_req_pkt_<%=pidx%> !== null
                  && item.dbid_val == 1
                  && (item.is_write == 1 || item.is_dvm == 1)
                  && item.aiu_check_done == 0                                       // some packets are only waiting for RBUse or COMPACK
                  && item.dbid == m_pkt.txnid
                  && item.register_txn == 0));
   if (find_q.size() == 1) begin
      fsys_txn_q[find_q[0]].update_time_accessed();
      fsys_txn_q[find_q[0]].exp_chi_data_flits = fsys_txn_q[find_q[0]].exp_chi_data_flits - 1;
      //MEM_CONSISTENCY
      if(m_en_mem_check) begin
         fsys_txn_q[find_q[0]].save_chi_txn_data_<%=pidx%>(m_pkt);
      end

      `uvm_info(`LABEL, $sformatf(
         "FSYS_UID:%0d : Seen write data. Remaining data flits to receive 'd%0d. %0s", 
         fsys_txn_q[find_q[0]].fsys_unique_txn_id, 
         fsys_txn_q[find_q[0]].exp_chi_data_flits,
         m_pkt.convert2string()), UVM_NONE+50)
      //if half of atomic data is seen, it means we have seen all wdata for this txn.
      if (fsys_txn_q[find_q[0]].is_atomic_txn == 1 && (fsys_txn_q[find_q[0]].chi_data_flits_atomic >= (fsys_txn_q[find_q[0]].exp_chi_data_flits * 2))) begin
         `uvm_info(`LABEL, $sformatf(
            "FSYS_UID:%0d : Seen all write data for Atomic txn", 
            fsys_txn_q[find_q[0]].fsys_unique_txn_id), UVM_NONE+50)
         fsys_txn_q[find_q[0]].dbid_val = 0;
      end
      if(fsys_txn_q[find_q[0]].exp_chi_data_flits == 0) begin
         fsys_txn_q[find_q[0]].dbid_val = 0;
         <% if (obj.AiuInfo[pidx].fnNativeInterface == 'CHI-E') { %>
            if (m_pkt.opcode == <%=_child_blkid[pidx]%>_env_pkg::NCBWRDATACOMPACK) begin
               fsys_txn_q[find_q[0]].compack_seen = 1;
            end
         <% } %>
         if ((fsys_txn_q[find_q[0]].m_chi_req_pkt_<%=pidx%>.expcompack == 0)
             || (fsys_txn_q[find_q[0]].m_chi_req_pkt_<%=pidx%>.expcompack == 1 && fsys_txn_q[find_q[0]].compack_seen == 1 && fsys_txn_q[find_q[0]].exp_chi_data_flits == 0)) begin
            `uvm_info(`LABEL, $sformatf("FSYS_UID:%0d : Setting aiu_check_done flag", 
               fsys_txn_q[find_q[0]].fsys_unique_txn_id), 
               UVM_NONE+50)
            fsys_txn_q[find_q[0]].aiu_check_done = 1;
         end
         //MEM_CONSISTENCY
         if(m_en_mem_check) begin
            package_and_send_mem_checker_<%=pidx%>(fsys_txn_q, find_q[0], "WR");
         end
         if(m_en_coh_check) begin
            package_and_send_coh_checker_<%=pidx%>(fsys_txn_q[find_q[0]],m_pkt.resperr,m_pkt.resp,0,1,0);
         end
         //fsys_txn_q.delete(find_q[0]); // For writes, delete will happen in DII/DMI
         if (fsys_txn_q[find_q[0]].combined_cmd == 1 && fsys_txn_q[find_q[0]].chi_cmd_num == 0) begin
            // Reset this so second SMI command will match
            fsys_txn_q[find_q[0]].chi_smi_cmd_seen = 0;
            fsys_txn_q[find_q[0]].aiu_check_done = 0;
         end
      end
   end else begin
      // TODO: Improve this error message for debug purposes, also account for more than 1 match
      if(m_pkt.txnid == 0 && m_pkt.opcode == <%=_child_blkid[pidx]%>_chi_agent_pkg::DATALCRDRETURN) begin
         `uvm_info(`LABEL, $sformatf("Interface activate/deactivate interaction for link control test, expected. Refer to CHI-B Spec 13.5"),UVM_NONE+50)
      end
      else begin
         `uvm_error(`LABEL, $sformatf(
            "FSYS_SCB: Write data packet didn't match any pending transactions. Total matches 'd%0d. opcode = %0s. %0s", 
            find_q.size(), m_pkt.opcode.name(), m_pkt.convert2string()))
      end
   end

endfunction : analyze_chi_wdata_pkt_<%=pidx%>

//====================================================================================================
//
//====================================================================================================
function void fsys_scb_chi_predictor::analyze_smi_pkt_<%=pidx%>(input <%=_child_blkid[pidx]%>_smi_agent_pkg::smi_seq_item m_pkt, ref fsys_scb_txn fsys_txn_q[$]);
   <%=_child_blkid[pidx]%>_smi_agent_pkg::smi_seq_item tmp_pkt = <%=_child_blkid[pidx]%>_smi_agent_pkg::smi_seq_item::type_id::create("tmp_pkt");
   $cast(tmp_pkt, m_pkt);
   tmp_pkt.copy(m_pkt);
   if (tmp_pkt.isCmdMsg()) begin
      smi_cmd_msg_prediction_<%=pidx%>(tmp_pkt, fsys_txn_q);
   end // if cmd_req smi pkt
   if (tmp_pkt.isStrMsg()) begin
      smi_str_prediction_<%=pidx%>(tmp_pkt, fsys_txn_q);
   end
   else if (tmp_pkt.isDtrMsg()) begin
      smi_dtr_prediction_<%=pidx%>(tmp_pkt, fsys_txn_q);
   end // is DTRReq
   else if (tmp_pkt.isSnpMsg()) begin
      smi_snpreq_prediction_<%=pidx%>(tmp_pkt, fsys_txn_q);
   end // is SNPReq
   else if (tmp_pkt.isSysReqMsg()) begin
      smi_sysreq_prediction_<%=pidx%>(tmp_pkt, fsys_txn_q);
   end // is SysReq
   else if (tmp_pkt.isSysRspMsg()) begin
      smi_sysrsp_prediction_<%=pidx%>(tmp_pkt, fsys_txn_q);
   end // is SysRsp
endfunction : analyze_smi_pkt_<%=pidx%>

//====================================================================================================
//
//====================================================================================================
function void fsys_scb_chi_predictor::smi_cmd_msg_prediction_<%=pidx%>(input <%=_child_blkid[pidx]%>_smi_agent_pkg::smi_seq_item m_pkt, ref fsys_scb_txn fsys_txn_q[$]);
   `undef LABEL
   `define LABEL "smi_cmd_msg_<%=_child_blkid[pidx]%>"
   int find_q[$];
   <%=_child_blkid[pidx]%>_smi_agent_pkg::eMsgCMD cmd_type;
   bit smi_cmd_atomic = 0;
   $cast(cmd_type, m_pkt.smi_msg_type);
   if (cmd_type inside {<%=_child_blkid[pidx]%>_smi_agent_pkg::eCmdRdAtm,
                        <%=_child_blkid[pidx]%>_smi_agent_pkg::eCmdWrAtm,
                        <%=_child_blkid[pidx]%>_smi_agent_pkg::eCmdCompAtm,
                        <%=_child_blkid[pidx]%>_smi_agent_pkg::eCmdSwAtm}) begin
      smi_cmd_atomic = 1;
   end
   if (m_pkt.smi_addr inside {[ncoreConfigInfo::NRS_REGION_BASE : (ncoreConfigInfo::NRS_REGION_BASE + ncoreConfigInfo::NRS_REGION_SIZE)]}
       && ( ! (cmd_type inside {<%=_child_blkid[pidx]%>_smi_agent_pkg::eCmdDvmMsg}) )) begin
      `uvm_info(`LABEL, $sformatf(
         "Register access packet, skipping scoreboarding. Addr=0x%0h", 
         m_pkt.smi_addr), UVM_NONE+50)
      find_q = fsys_txn_q.find_index with (
                  (item.source_funit_id == <%=obj.AiuInfo[pidx].FUnitId%>)
                  && (item.m_chi_req_pkt_<%=pidx%> !== null
                  && item.m_chi_req_pkt_<%=pidx%>.addr == m_pkt.smi_addr
                  && item.register_txn == 1));
      if (find_q.size() >= 1) begin
         `uvm_info(`LABEL, $sformatf(
            "FSYS_UID:%0d : CmdReq for Register txn seen. %0s", 
            fsys_txn_q[find_q[0]].fsys_unique_txn_id, 
            m_pkt.convert2string()), UVM_NONE+50)
         fsys_txn_q[find_q[0]].smi_msg_id = m_pkt.smi_msg_id;
         fsys_txn_q[find_q[0]].smi_pri = m_pkt.smi_msg_pri;
         fsys_txn_q[find_q[0]].str_msg_id_q.push_back(m_pkt.smi_msg_id);
         fsys_txn_q[find_q[0]].dce_queue_idx.push_back(-1);
         fsys_txn_q[find_q[0]].cmd_req_val_q.push_back(1);
         fsys_txn_q[find_q[0]].cmd_req_id_q.push_back(m_pkt.smi_msg_id);
         fsys_txn_q[find_q[0]].cmd_req_targ_q.push_back(m_pkt.smi_targ_ncore_unit_id);
         fsys_txn_q[find_q[0]].cmd_req_addr_q.push_back(m_pkt.smi_addr);
         fsys_txn_q[find_q[0]].cmd_req_excl_q.push_back(m_pkt.smi_es);
         fsys_txn_q[find_q[0]].cmd_req_subid_q.push_back(0);
         fsys_txn_q[find_q[0]].cmd_req_axi_id_q.push_back('{ 0, 0, -1, -1});
         fsys_txn_q[find_q[0]].str_msg_id_val_q.push_back(1);
         fsys_txn_q[find_q[0]].str_unit_id_q.push_back(m_pkt.smi_src_ncore_unit_id);
         fsys_txn_q[find_q[0]].smi_targ_ncore_unit_id = m_pkt.smi_targ_ncore_unit_id;
         fsys_txn_q[find_q[0]].smi_src_ncore_unit_id = m_pkt.smi_src_ncore_unit_id;
         fsys_txn_q[find_q[0]].chi_smi_cmd_seen = 1; 
         fsys_txn_q[find_q[0]].update_time_accessed();
      end else begin
         // TODO: Improve this error message for debug purposes, also account for more than 1 match
         `uvm_error(`LABEL, $sformatf(
            "FSYS_SCB: CMDReq for register access, didn't match any pending transactions"))
      end
      return;
   end // register address

   //non register accesses
   find_q = fsys_txn_q.find_index with (
                  (item.source_funit_id == <%=obj.AiuInfo[pidx].FUnitId%>)
                  && (item.m_chi_req_pkt_<%=pidx%> !== null
                  && item.m_chi_req_pkt_<%=pidx%>.addr == m_pkt.smi_addr
                  && ((item.dest_funit_id == m_pkt.smi_targ_ncore_unit_id)
                     || (item.dce_funit_id == m_pkt.smi_targ_ncore_unit_id))
                  && item.source_funit_id == m_pkt.smi_src_ncore_unit_id
                  && (item.chi_smi_cmd_seen == 0 || (item.chi_smi_cmd_seen == 1 && item.is_atomic_txn == 1 && item.is_coh == 1 && item.str_msg_id_q.size() == 1))
                  && ((item.m_chi_req_pkt_<%=pidx%>.opcode inside {<%=_child_blkid[pidx]%>_env_pkg::stash_ops})
                     || ((!(item.m_chi_req_pkt_<%=pidx%>.opcode inside {<%=_child_blkid[pidx]%>_env_pkg::stash_ops})) 
                        && (1'b1  == m_pkt.smi_mpf2_flowid_valid)
                        `ifndef VCS
                        && (item.m_chi_req_pkt_<%=pidx%>.lpid[<%=obj.AiuInfo[pidx].concParams.cmdReqParams.wMpf2%>-2:0]  == m_pkt.smi_mpf2_flowid)))
                        `else
                        && (item.m_chi_req_pkt_<%=pidx%>.lpid[<%=obj.AiuInfo[pidx].interfaces.chiInt.params.LPID%>-1:0]  == m_pkt.smi_mpf2_flowid)))
                        `endif
                  && item.register_txn == 0)
                  //CONC-12552 & CONC-12386
                  && ((smi_cmd_atomic == 1 && item.is_atomic_txn == 1) || (smi_cmd_atomic == 0 && item.is_atomic_txn == 0)));
   if (find_q.size() >= 1) begin
      `uvm_info(`LABEL, $sformatf(
         "FSYS_UID:%0d : SMI command packet seen. %0s", 
         fsys_txn_q[find_q[0]].fsys_unique_txn_id, 
         m_pkt.convert2string()), UVM_NONE+50)
      fsys_txn_q[find_q[0]].update_time_accessed();
      fsys_txn_q[find_q[0]].aiu_check_done = 0;
      fsys_txn_q[find_q[0]].smi_pri = m_pkt.smi_msg_pri;
      fsys_txn_q[find_q[0]].smi_msg_order_q.push_back(smi_msgs_t'(fsys_coverage_pkg::CMD_REQ));
      // if this is first CMDReq for Atomic and going to DMI, then this is a non-coherent atomic txn.
      // Some dataless txns are also treated as non-coh. TODO: Find ref to spec
      if (((fsys_txn_q[find_q[0]].is_atomic_txn == 1 && fsys_txn_q[find_q[0]].str_msg_id_q.size() == 0)
            || fsys_txn_q[find_q[0]].is_dataless_txn == 1)
         && m_pkt.smi_targ_ncore_unit_id == fsys_txn_q[find_q[0]].dest_funit_id) begin 
         fsys_txn_q[find_q[0]].is_coh = 0;
      end
      if (fsys_txn_q[find_q[0]].m_chi_req_pkt_<%=pidx%>.opcode inside {<%=_child_blkid[pidx]%>_env_pkg::stash_ops}) begin
         fsys_txn_q[find_q[0]].is_stash_txn = 1;
         fsys_txn_q[find_q[0]].smi_stash_nid = m_pkt.smi_mpf1_stash_nid;
         fsys_txn_q[find_q[0]].smi_stash_lpid = m_pkt.smi_mpf2_stash_lpid;
      end // if stash op
      if(fsys_txn_q[find_q[0]].m_chi_req_pkt_<%=pidx%>.opcode inside {<%=_child_blkid[pidx]%>_chi_agent_pkg::combined_wr_nc_ops, 
                                                                      <%=_child_blkid[pidx]%>_chi_agent_pkg::combined_wr_c_ops}
      ) begin
         fsys_txn_q[find_q[0]].combined_cmd = 1;
         if (!(cmd_type inside {<%=_child_blkid[pidx]%>_smi_agent_pkg::eCmdWrNCFull, 
                             <%=_child_blkid[pidx]%>_smi_agent_pkg::eCmdWrBkFull,
                             <%=_child_blkid[pidx]%>_smi_agent_pkg::eCmdWrClnFull})
         ) begin
            fsys_txn_q[find_q[0]].aiu_str_seen = 0; 
            fsys_txn_q[find_q[0]].cleanup_chi_op_queues();
            fsys_txn_q[find_q[0]].chi_cmd_num++;
            fsys_txn_q[find_q[0]].is_dataless_txn = 1;
            fsys_txn_q[find_q[0]].is_write = 0;
            //TODO: Delete index 0 from all above and DCE's queues
         end // Second CmdReq of combined write OP
      end // Combined write ops 
      <% if (obj.AiuInfo[pidx].fnNativeInterface == 'CHI-E') { %>
      if (fsys_txn_q[find_q[0]].m_chi_req_pkt_<%=pidx%>.opcode == <%=_child_blkid[pidx]%>_chi_agent_pkg::MAKEREADUNIQUE
         && fsys_txn_q[find_q[0]].m_chi_req_pkt_<%=pidx%>.excl == 0 && fsys_txn_q[find_q[0]].combined_cmd == 1) begin
            fsys_txn_q[find_q[0]].chi_cmd_num++;
      end
      <% } %>
      //Refer to CCMP spec (0.90_NoCB) section 4.5.3.3.1.2
      if (m_pkt.smi_ch == 0) begin
         if(fsys_txn_q[find_q[0]].m_chi_req_pkt_<%=pidx%>.opcode inside 
            {<%=_child_blkid[pidx]%>_env_pkg::EVICT, <%=_child_blkid[pidx]%>_env_pkg::WRITECLEANPTL,
            <%=_child_blkid[pidx]%>_env_pkg::WRITECLEANFULL, <%=_child_blkid[pidx]%>_env_pkg::WRITEEVICTFULL,
            <%=_child_blkid[pidx]%>_env_pkg::WRITEBACKPTL, <%=_child_blkid[pidx]%>_env_pkg::WRITEBACKFULL
         <% if (obj.AiuInfo[pidx].fnNativeInterface == 'CHI-E') { %>
            ,<%=_child_blkid[pidx]%>_env_pkg::WRITEBACKFULL_CLEANSHARED, <%=_child_blkid[pidx]%>_env_pkg::WRITEBACKFULL_CLEANSHAREDPERSISTSEP,
            <%=_child_blkid[pidx]%>_env_pkg::WRITEBACKFULL_CLEANINVALID, <%=_child_blkid[pidx]%>_env_pkg::WRITECLEANFULL_CLEANSHARED,
            <%=_child_blkid[pidx]%>_env_pkg::WRITECLEANFULL_CLEANSHAREDPERSISTSEP, <%=_child_blkid[pidx]%>_env_pkg::WRITEEVICTOREVICT
         <% } %>
            }
            && fsys_txn_q[find_q[0]].chi_cmd_num == 0
         ) begin
            if (m_pkt.smi_targ_ncore_unit_id !=  fsys_txn_q[find_q[0]].dce_funit_id) begin
               `uvm_error(`LABEL, $sformatf(
                  "FSYS_UID:%0d : CmdReq from CHI with CH=0 & of WrBkPtl,WrBkFull,WrClnPtl,WrClnFull,WrEvict,WrEvictOrEvict Or Evict should be sent to DCE(funit_id:'d%0d), but is sent to ncore unit:'d%0d.", 
                  fsys_txn_q[find_q[0]].fsys_unique_txn_id, 
                  fsys_txn_q[find_q[0]].dce_funit_id, 
                  m_pkt.smi_targ_ncore_unit_id))
            end
         end //CHI Coh ops that don't need snoops are sent to DCE with CH=0
         else begin
            if (m_pkt.smi_targ_ncore_unit_id !== fsys_txn_q[find_q[0]].dest_funit_id) begin
               `uvm_error(`LABEL, $sformatf(
                  "FSYS_UID:%0d : CmdReq from CHI with CH=0 should be sent to funitid:'d%0d, while targ_id='d%0d.", 
                  fsys_txn_q[find_q[0]].fsys_unique_txn_id, 
                  fsys_txn_q[find_q[0]].dest_funit_id, 
                  m_pkt.smi_targ_ncore_unit_id))
            end
         end // other txns goes to DMI/DII
      end else if (m_pkt.smi_ch == 1) begin
         if (!fsys_txn_q[find_q[0]].m_chi_req_pkt_<%=pidx%>.is_coh_opcode() && fsys_txn_q[find_q[0]].chi_cmd_num == 0) begin
            `uvm_error(`LABEL, $sformatf(
               "FSYS_UID:%0d : CmdReq from CHI with CH=1, but CHI Req is non-coherent req.", 
               fsys_txn_q[find_q[0]].fsys_unique_txn_id))
         end
         if (m_pkt.smi_targ_ncore_unit_id !== fsys_txn_q[find_q[0]].dce_funit_id) begin
            `uvm_error(`LABEL, $sformatf(
               "FSYS_UID:%0d : CmdReq from CHI with CH=1 should be sent to funitid:'d%0d, while targ_id='d%0d.", 
               fsys_txn_q[find_q[0]].fsys_unique_txn_id, 
               fsys_txn_q[find_q[0]].dce_funit_id, 
               m_pkt.smi_targ_ncore_unit_id))
         end
      end// smi_ch checks
      fsys_txn_q[find_q[0]].smi_msg_id = m_pkt.smi_msg_id;
      fsys_txn_q[find_q[0]].str_msg_id_q.push_back(m_pkt.smi_msg_id);
      fsys_txn_q[find_q[0]].cmd_req_val_q.push_back(1);
      fsys_txn_q[find_q[0]].cmd_req_id_q.push_back(m_pkt.smi_msg_id);
      fsys_txn_q[find_q[0]].cmd_req_targ_q.push_back(m_pkt.smi_targ_ncore_unit_id);
      fsys_txn_q[find_q[0]].cmd_req_addr_q.push_back(m_pkt.smi_addr);
      fsys_txn_q[find_q[0]].cmd_req_excl_q.push_back(m_pkt.smi_es);
      fsys_txn_q[find_q[0]].cmd_req_subid_q.push_back(0);
      if (fsys_txn_q[find_q[0]].chi_cmd_num == 0) begin
         fsys_txn_q[find_q[0]].cmd_req_axi_id_q.push_back('{ 0, 0, -1, -1});
      end 
      if (fsys_txn_q[find_q[0]].is_read == 1 || fsys_txn_q[find_q[0]].is_dataless_txn == 1 || fsys_txn_q[find_q[0]].is_stash_txn == 1)
         fsys_txn_q[find_q[0]].mrd_possible_q.push_back(1);
      else 
         fsys_txn_q[find_q[0]].mrd_possible_q.push_back(0);
      fsys_txn_q[find_q[0]].str_msg_id_val_q.push_back(1);
      fsys_txn_q[find_q[0]].str_unit_id_q.push_back(m_pkt.smi_src_ncore_unit_id);
      fsys_txn_q[find_q[0]].smi_targ_ncore_unit_id = m_pkt.smi_targ_ncore_unit_id;
      fsys_txn_q[find_q[0]].smi_src_ncore_unit_id = m_pkt.smi_src_ncore_unit_id;
      fsys_txn_q[find_q[0]].chi_smi_cmd_seen = 1; 
      if(!(fsys_txn_q[find_q[0]].m_chi_req_pkt_<%=pidx%>.opcode inside {<%=_child_blkid[pidx]%>_env_pkg::stash_ops})) begin
         fsys_txn_q[find_q[0]].mpf2_flowid_val = 1;
         fsys_txn_q[find_q[0]].mpf2_flowid = m_pkt.smi_mpf2_flowid;
      end
   end else begin
      // TODO: Improve this error message for debug purposes, also account for more than 1 match
      `uvm_error(`LABEL, $sformatf(
         "FSYS_SCB: CMDReq packet didn't match any pending transactions. total matches='d%0d. %0s", 
         find_q.size(), m_pkt.convert2string()))
   end
endfunction : smi_cmd_msg_prediction_<%=pidx%>

//====================================================================================================
//
//====================================================================================================
function void fsys_scb_chi_predictor::smi_str_prediction_<%=pidx%>(input <%=_child_blkid[pidx]%>_smi_agent_pkg::smi_seq_item m_pkt, ref fsys_scb_txn fsys_txn_q[$]);
   `undef LABEL
   `define LABEL "smi_str_msg_<%=_child_blkid[pidx]%>"
   int find_q[$];
   int cmd_idx;
   find_q = fsys_txn_q.find_index with (
                  item.source_funit_id == <%=obj.AiuInfo[pidx].FUnitId%>
                  && item.chi_smi_cmd_seen == 1
                  && item.smi_msg_id == m_pkt.smi_rmsg_id
                  && (item.aiu_str_seen == 0 || (item.aiu_str_seen == 1 && item.is_atomic_txn == 1 && item.is_coh == 1))  // some packets are only waiting for RBUse or COMPACK
                  && item.smi_src_ncore_unit_id == m_pkt.smi_targ_ncore_unit_id
                  && item.smi_targ_ncore_unit_id == m_pkt.smi_src_ncore_unit_id);
   if (find_q.size() == 1) begin
      `uvm_info(`LABEL, $sformatf(
         "FSYS_UID:%0d : SMI STR packet seen. %0s",
         fsys_txn_q[find_q[0]].fsys_unique_txn_id,
         m_pkt.convert2string()), UVM_NONE+50)
      fsys_txn_q[find_q[0]].update_time_accessed();
      fsys_txn_q[find_q[0]].aiu_str_seen = 1;
      fsys_txn_q[find_q[0]].str_msg_id_q[0] = -1;
      fsys_txn_q[find_q[0]].aiu_str_cnt = fsys_txn_q[find_q[0]].aiu_str_cnt + 1;
      cmd_idx = fsys_txn_q[find_q[0]].chi_cmd_num;
      // CHI-E MakeReadUnique (Excl) 
      <% if (obj.AiuInfo[pidx].fnNativeInterface == 'CHI-E') { %>
      if (fsys_txn_q[find_q[0]].m_chi_req_pkt_<%=pidx%>.opcode == <%=_child_blkid[pidx]%>_chi_agent_pkg::MAKEREADUNIQUE
         && fsys_txn_q[find_q[0]].m_chi_req_pkt_<%=pidx%>.excl == 1) begin
         // PASS
         if (m_pkt.smi_cmstatus_exok == 1) begin
            `uvm_info(`LABEL, $sformatf(
               "FSYS_UID:%0d : Exclusive pass",
               fsys_txn_q[find_q[0]].fsys_unique_txn_id), UVM_NONE+50)
            fsys_txn_q[find_q[0]].exp_smi_data_pkts = 0;
            fsys_txn_q[find_q[0]].exp_chi_data_flits = 0;
            fsys_txn_q[find_q[0]].is_dataless_txn = 1;
            fsys_txn_q[find_q[0]].combined_cmd = 0;
         end
         //FAIL
         else begin
            //TODO: Make this a separate function
            `uvm_info(`LABEL, $sformatf(
               "FSYS_UID:%0d : Exclusive fail",
               fsys_txn_q[find_q[0]].fsys_unique_txn_id), UVM_NONE+50)
            fsys_txn_q[find_q[0]].combined_cmd = 1;
            fsys_txn_q[find_q[0]].chi_smi_cmd_seen = 0;
            fsys_txn_q[find_q[0]].aiu_str_seen = 0;
            // Reset this for the second pass of the command
            fsys_txn_q[find_q[0]].m_chi_req_pkt_<%=pidx%>.excl = 0;
         end
      end
      <% } %>
      if (fsys_txn_q[find_q[0]].snpreq_cnt_q[0] == 0 && fsys_txn_q[find_q[0]].is_stash_txn == 0) begin
         fsys_txn_q[find_q[0]].snpreq_msg_id_q[0] = -1;
      end
      if (fsys_txn_q[find_q[0]].delete_at_str == 1) begin
         `uvm_info(`LABEL, $sformatf("FSYS_UID:%0d : Setting aiu_check_done flag", 
               fsys_txn_q[find_q[0]].fsys_unique_txn_id), UVM_NONE+50)
            fsys_txn_q[find_q[0]].aiu_check_done = 1;
         if (check_flags_and_delete_txn(`LABEL, find_q[0], fsys_txn_q, `__LINE__)) begin
            return;
         end
      end
      if (fsys_txn_q[find_q[0]].m_chi_req_pkt_<%=pidx%>.opcode inside {<%=_child_blkid[pidx]%>_chi_agent_pkg::prefetch_op}) begin
         if (!check_flags_and_delete_txn(`LABEL, find_q[0], fsys_txn_q, `__LINE__, 1)) begin
            `uvm_error(`LABEL, $sformatf(
               "FSYS_UID:%0d : Failed to delete packet from fsys_txn_q. Packet was %0s bound, check_done flag from that unit is: 'd%0d", 
               fsys_txn_q[find_q[0]].fsys_unique_txn_id, 
               (fsys_txn_q[find_q[0]].dmi_bound == 1) ? "DMI" : ((fsys_txn_q[find_q[0]].dii_bound == 1) ? "DII" : "ERROR"), 
               (fsys_txn_q[find_q[0]].dmi_bound == 1) ? fsys_txn_q[find_q[0]].dmi_check_done : fsys_txn_q[find_q[0]].dii_check_done))
         end // DMI, DII check done flags not set
      end // PREFETCHTARGET
      else if (fsys_txn_q[find_q[0]].is_stash_txn == 1) begin
         if (fsys_txn_q[find_q[0]].exp_chi_data_flits == 0 && fsys_txn_q[find_q[0]].exp_smi_data_pkts == 0) begin
            `uvm_info(`LABEL, $sformatf("FSYS_UID:%0d : Setting aiu_check_done flag", 
               fsys_txn_q[find_q[0]].fsys_unique_txn_id), UVM_NONE+50)
            fsys_txn_q[find_q[0]].aiu_check_done = 1;
         end
         if (!check_flags_and_delete_txn(`LABEL, find_q[0], fsys_txn_q, `__LINE__)) begin 
            `uvm_info(`LABEL, $sformatf("FSYS_UID:%0d : Resetting aiu_check_done flag", 
               fsys_txn_q[find_q[0]].fsys_unique_txn_id), UVM_NONE+50)
            fsys_txn_q[find_q[0]].aiu_check_done = 0;
            if (fsys_txn_q[find_q[0]].stash_accept == 0 
                || (fsys_txn_q[find_q[0]].stash_accept == 1 && fsys_txn_q[find_q[0]].exp_chi_data_flits == 0)) begin
               `uvm_info(`LABEL, $sformatf("FSYS_UID:%0d : Setting aiu_check_done flag",
               fsys_txn_q[find_q[0]].fsys_unique_txn_id), UVM_NONE+50)
               fsys_txn_q[find_q[0]].aiu_check_done = 1;
               if (fsys_txn_q[find_q[0]].is_dataless_txn) begin
                  fsys_txn_q[find_q[0]].only_waiting_for_mrd = 1;
               end
            end
         end
      end // stash
      //For writes, when an RBR isn't sent, save the RBID for DTW matching
      else if (fsys_txn_q[find_q[0]].is_write == 1 && fsys_txn_q[find_q[0]].rbrreq_seen_q[cmd_idx] == 0
               && fsys_txn_q[find_q[0]].is_atomic_txn == 0 && fsys_txn_q[find_q[0]].is_coh == 1) begin
         fsys_txn_q[find_q[0]].rbid_val_q.push_back(1);
         fsys_txn_q[find_q[0]].rbid_q.push_back(m_pkt.smi_rbid);
         fsys_txn_q[find_q[0]].rbid_unit_id_q.push_back(fsys_txn_q[find_q[0]].dest_funit_id); 
         fsys_txn_q[find_q[0]].snpdat_unit_id_q.push_back(-1);
         fsys_txn_q[find_q[0]].snpsrc_unit_id_q.push_back(-1);
      end
      //We sometimes see STR as last packet in cases of coh read where data gets forwarded as a result of SNP.
      else if (((fsys_txn_q[find_q[0]].readreceipt_exp == 1 && fsys_txn_q[find_q[0]].readreceipt_seen == 1)
                  || (fsys_txn_q[find_q[0]].readreceipt_exp == 0))
               && ((fsys_txn_q[find_q[0]].m_chi_req_pkt_<%=pidx%>.expcompack == 0)
                  || (fsys_txn_q[find_q[0]].m_chi_req_pkt_<%=pidx%>.expcompack == 1 && fsys_txn_q[find_q[0]].compack_seen == 1))) begin

         if (fsys_txn_q[find_q[0]].exp_chi_data_flits == 0
            && !(fsys_txn_q[find_q[0]].m_chi_req_pkt_<%=pidx%>.opcode inside {<%=_child_blkid[pidx]%>_env_pkg::dataless_ops, <%=_child_blkid[pidx]%>_chi_agent_pkg::wr_zero_ops, <%=_child_blkid[pidx]%>_chi_agent_pkg::combined_wr_nc_ops, <%=_child_blkid[pidx]%>_chi_agent_pkg::combined_wr_c_ops})) begin
            `uvm_info(`LABEL, $sformatf("FSYS_UID:%0d : Setting aiu_check_done flag", 
               fsys_txn_q[find_q[0]].fsys_unique_txn_id), 
               UVM_NONE+50)
            fsys_txn_q[find_q[0]].aiu_check_done = 1;
            if((fsys_txn_q[find_q[0]].rbrreq_seen_q[cmd_idx] == 0 || fsys_txn_q[find_q[0]].rbrreq_seen_q[cmd_idx] > 1)
               && (fsys_txn_q[find_q[0]].mrdreq_seen_q[0] == 0 || fsys_txn_q[find_q[0]].mrdreq_seen_q[0] == 2)
            ) begin
             fsys_txn_q[find_q[0]].dmi_check_done = 1;
           end
         end
         check_flags_and_delete_txn(`LABEL, find_q[0], fsys_txn_q, `__LINE__);
      end //readreceipt check
   end else begin
      foreach(find_q[idx])
         fsys_txn_q[find_q[idx]].print_me();
      `uvm_error(`LABEL, $sformatf(
         "FSYS_SCB: STR packet didn't match any pending transactions. total matches='d%0d, %0s", 
         find_q.size(), m_pkt.convert2string()))
   end
endfunction : smi_str_prediction_<%=pidx%>

//===================================================================================================
//
//===================================================================================================
function void fsys_scb_chi_predictor::smi_dtr_prediction_<%=pidx%>(input <%=_child_blkid[pidx]%>_smi_agent_pkg::smi_seq_item m_pkt, ref fsys_scb_txn fsys_txn_q[$]);
   `undef LABEL
   `define LABEL "smi_dtr_msg_<%=_child_blkid[pidx]%>"
   int find_q[$];
   bit match_found = 0;
   bit[63:0] snp_cacheline_addr;
   int cmd_idx;
   find_q = fsys_txn_q.find_index with (
                  ((item.source_funit_id == <%=obj.AiuInfo[pidx].FUnitId%> && item.is_stash_txn == 0)
                     || (item.is_stash_txn == 1 && item.stash_accept == 1 && item.smi_stash_nid == <%=obj.AiuInfo[pidx].FUnitId%>))
                  && (item.chi_smi_cmd_seen == 1 || (item.is_stash_txn == 1 && item.ioaiu_core_id >= 0))
                  && (item.aiu_check_done == 0 || (item.is_stash_txn == 1 && item.ioaiu_core_id >=0))            // some packets are only waiting for RBUse or COMPACK
                  && ((item.smi_msg_id == m_pkt.smi_rmsg_id && item.is_stash_txn == 0 && item.combined_cmd == 0)
                     || (item.is_stash_txn == 1 && item.stash_accept == 1 && item.smi_stash_dtr_msg_id == m_pkt.smi_rmsg_id && item.smi_stash_nid == <%=obj.AiuInfo[pidx].FUnitId%>)
                     <% if (obj.AiuInfo[pidx].fnNativeInterface == 'CHI-E') { %>
                     || (item.m_chi_req_pkt_<%=pidx%> !== null && item.m_chi_req_pkt_<%=pidx%>.opcode == <%=_child_blkid[pidx]%>_chi_agent_pkg::MAKEREADUNIQUE && item.m_chi_req_pkt_<%=pidx%>.excl == 0 && item.smi_msg_id == m_pkt.smi_rmsg_id && item.is_stash_txn == 0 && item.combined_cmd == 1)
                     <% } %>
                     )
                  && ((item.smi_src_ncore_unit_id == m_pkt.smi_targ_ncore_unit_id && item.source_funit_id == <%=obj.AiuInfo[pidx].FUnitId%>)
                     || (item.is_stash_txn == 1 && item.smi_stash_nid == <%=obj.AiuInfo[pidx].FUnitId%> && <%=obj.AiuInfo[pidx].FUnitId%> !== m_pkt.smi_src_ncore_unit_id)));
   if (find_q.size() == 1) begin
      `uvm_info(`LABEL, $sformatf(
         "FSYS_UID:%0d : SMI DTR packet seen. Remaining DTRS:%0d. %0s", 
         fsys_txn_q[find_q[0]].fsys_unique_txn_id, 
         (fsys_txn_q[find_q[0]].exp_smi_data_pkts - 1), m_pkt.convert2string()), UVM_NONE+50)
      fsys_txn_q[find_q[0]].update_time_accessed();
      fsys_txn_q[find_q[0]].exp_smi_data_pkts = fsys_txn_q[find_q[0]].exp_smi_data_pkts - 1;
      fsys_txn_q[find_q[0]].smi_stash_dtr_msg_id = -1;
      cmd_idx = fsys_txn_q[find_q[0]].chi_cmd_num;
      fsys_txn_q[find_q[0]].smi_msg_order_q.push_back(smi_msgs_t'(fsys_coverage_pkg::DTR_REQ));
      // MEM_CONSISTENCY
      if (m_pkt.smi_msg_type == 'h80) begin
         fsys_txn_q[find_q[0]].dtr_data_inv_seen = 1;
      end
      if (fsys_txn_q[find_q[0]].exp_smi_data_pkts < 0) begin
         `uvm_error(`LABEL, $sformatf(
            "FSYS_UID:%0d : CHI transaction saw more DTRs than expected, something went wrong.", 
            fsys_txn_q[find_q[0]].fsys_unique_txn_id))
      end
      if (fsys_txn_q[find_q[0]].exp_smi_data_pkts == 0) begin
         if(fsys_txn_q[find_q[0]].dmi_bound == 1 && fsys_txn_q[find_q[0]].dmi_check_done == 0
            && ((fsys_txn_q[find_q[0]].rbrreq_seen_q.size() > 0 
                  && (fsys_txn_q[find_q[0]].rbrreq_seen_q[cmd_idx] == 0 || fsys_txn_q[find_q[0]].rbrreq_seen_q[cmd_idx] == 4))
               || (fsys_txn_q[find_q[0]].rbrreq_seen_q.size() == 0)))
            fsys_txn_q[find_q[0]].dmi_check_done = 1;
         else if (fsys_txn_q[find_q[0]].dii_bound == 1 && fsys_txn_q[find_q[0]].dii_check_done == 0)
            fsys_txn_q[find_q[0]].dii_check_done = 1;
      end
   end else begin
      foreach (fsys_txn_q[idx]) begin
         if (fsys_txn_q[idx].chi_snp_txnid_q.size() > 0) begin
            foreach (fsys_txn_q[idx].chi_snp_txnid_q[i]) begin
               if (fsys_txn_q[idx].snpreq_targ_id_q[i] == <%=obj.AiuInfo[pidx].FUnitId%>
                  && fsys_txn_q[idx].read_acc_dtr_exp_q[i]  == 1
                  && fsys_txn_q[idx].read_acc_dtr_tgtid_q[i] == m_pkt.smi_targ_ncore_unit_id
                  && fsys_txn_q[idx].read_acc_dtr_msgid_q[i] == m_pkt.smi_rmsg_id
               ) begin
                  `uvm_info(`LABEL, $sformatf(
                     "FSYS_UID:%0d : SMI DTR packet seen (Outgoing, snp read acceleration). %0s", 
                     fsys_txn_q[idx].fsys_unique_txn_id, m_pkt.convert2string()), UVM_NONE+50)
                  fsys_txn_q[idx].read_acc_dtr_exp_q[i] = 0;
                  fsys_txn_q[idx].read_acc_dtr_msgid_q[i] = -1;
                  fsys_txn_q[idx].snoop_data_fwded = 1;
                  fsys_txn_q[idx].update_time_accessed();
                  //MEM_CONSISTENCY
                  if(m_en_mem_check) begin
                     snp_cacheline_addr = {(fsys_txn_q[idx].snpreq_addr_q[i] >> ncoreConfigInfo::WCACHE_OFFSET), <%=obj.wCacheLineOffset%>'b0};
                     mem_checker.snoop_on_native_if(.addr(snp_cacheline_addr), 
                                                    .data(fsys_txn_q[idx].snoop_data[m_pkt.smi_src_ncore_unit_id][snp_cacheline_addr]), 
                                                    .byte_en(fsys_txn_q[idx].snoop_be[m_pkt.smi_src_ncore_unit_id][snp_cacheline_addr]),
                                                    .snp_resp(0), // TODO
                                                    .funit_id(m_pkt.smi_src_ncore_unit_id), 
                                                    .core_id(0),
                                                    .fsys_index(idx), 
                                                    .fsys_txn_q(fsys_txn_q));
                  end
                  match_found = 1;
                  break;
               end // if matched
            end // foreach CMDReq
         end // if there are pending CMDReqs
         if (match_found == 1) break;
      end //foreach pending txn 
      if (match_found == 0) begin
         foreach(find_q[err_idx])begin
            fsys_txn_q[find_q[err_idx]].print_me();
         end
         `uvm_error(`LABEL, $sformatf(
            "FSYS_SCB: DTR didn't match any pending transactions. Total matches: 'd%0d %0s", 
            find_q.size(), m_pkt.convert2string()))
      end
   end // if DTR didn't match any pending txn

endfunction : smi_dtr_prediction_<%=pidx%>

//====================================================================================================
//
// Function : smi_snpreq_prediction
//
//====================================================================================================
function void fsys_scb_chi_predictor::smi_snpreq_prediction_<%=pidx%>(input <%=_child_blkid[pidx]%>_smi_agent_pkg::smi_seq_item m_pkt, ref fsys_scb_txn fsys_txn_q[$]);
   `undef LABEL
   `define LABEL "smi_snpreq_<%=_child_blkid[pidx]%>"
   bit match_found = 0;
   bit dvm_addr_match = 0;
   foreach (fsys_txn_q[idx]) begin
      if (fsys_txn_q[idx].cmd_msg_id_q.size() > 0) begin
         foreach (fsys_txn_q[idx].cmd_msg_id_q[i]) begin
            //`uvm_info(`LABEL, $psprintf(
            //    "cmd_addr_q[%0d]=0x%0h. snpreq_cnt = 'd%0d. fsys_txn_q[idx].snpreq_msg_id[i] = 0x%0h, snoops exp = 'd%0d",
            //    i, fsys_txn_q[idx].cmd_addr_q[i], fsys_txn_q[idx].snpreq_cnt_q[i], fsys_txn_q[idx].snpreq_msg_id_q[i],
            //    fsys_txn_q[idx].snoops_exp_q[i]), UVM_NONE+50)
            if (fsys_txn_q[idx].is_dvm == 1
               && ((m_pkt.smi_addr[3:3] == 1'b0 && fsys_txn_q[idx].cmd_addr_q[i][31:4] == m_pkt.smi_addr[31:4])
                  || (m_pkt.smi_addr[3:3] == 1'b1 && fsys_txn_q[idx].dvm_part_2_addr_q[i][31:4] == m_pkt.smi_addr[31:4]))
            ) begin
               dvm_addr_match = 1;
            end
            if (((fsys_txn_q[idx].cmd_addr_q[i] == m_pkt.smi_addr && fsys_txn_q[idx].is_dvm == 0)
               || (m_pkt.smi_msg_type inside {'h4f} && dvm_addr_match == 1))
               && ((fsys_txn_q[idx].snpreq_cnt_q[i] > 0 && fsys_txn_q[idx].snpreq_msg_id_q[i] == m_pkt.smi_msg_id))
               && fsys_txn_q[idx].snpreq_unq_id_q.size() > 0
               //&& fsys_txn_q[idx].snpreq_targ_id_q[i] == <%=obj.AiuInfo[pidx].FUnitId%>
            ) begin
               foreach (fsys_txn_q[idx].snpreq_targ_id_q[j]) begin
                  if (fsys_txn_q[idx].snpreq_targ_id_q[j] == <%=obj.AiuInfo[pidx].FUnitId%>
                     && fsys_txn_q[idx].snp_up_q[j] == 2'b00) begin
                     `uvm_info(`LABEL, $sformatf(
                        "FSYS_UID:%0d : SNPReq seen. %0s", 
                        fsys_txn_q[idx].fsys_unique_txn_id, 
                        m_pkt.convert2string()), UVM_NONE+50)
                     smi_snpreq_order_uid_<%=pidx%>.push_back(fsys_txn_q[idx].fsys_unique_txn_id);
                     fsys_txn_q[idx].snp_up_q[j] = m_pkt.smi_up;
                     if (fsys_txn_q[idx].is_dvm == 1) begin
                        if (fsys_txn_q[idx].dvm_snp_1_seen_at_aiu == 0)
                           fsys_txn_q[idx].dvm_snp_1_seen_at_aiu = 1;
                        else
                           fsys_txn_q[idx].dvm_snp_2_seen_at_aiu = 1;
                     end
                     if (fsys_txn_q[idx].ioaiu_core_id >= 0)
                        fsys_txn_q[idx].snp_chi_from_ioaiu_q[j] = 1;
                     //SnpInv don't generate DTW, they don't send dirty data to memory
                     // && CONC-11661
                     if (!(m_pkt.smi_msg_type inside {'h46})
                        && fsys_txn_q[idx].rbr_rbid_q[i] !== -1) begin
                        // Add this SNP's RBID from RBRReq to rbid queue. This way DTW lookup equation remains same
                        fsys_txn_q[idx].rbid_val_q.push_back(1);
                        fsys_txn_q[idx].rbid_q.push_back(m_pkt.smi_rbid); //fsys_txn_q[idx].rbr_rbid_q[i]);
                        fsys_txn_q[idx].rbid_unit_id_q.push_back(m_pkt.smi_dest_id); //fsys_txn_q[idx].cmd_did_q[i]);
                        fsys_txn_q[idx].snpdat_unit_id_q.push_back(<%=obj.AiuInfo[pidx].FUnitId%>);
                        fsys_txn_q[idx].snpsrc_unit_id_q.push_back(m_pkt.smi_src_ncore_unit_id);
                     end
                     fsys_txn_q[idx].read_acc_dtr_tgtid_q[j] = m_pkt.smi_mpf1_dtr_tgt_id;
                     fsys_txn_q[idx].read_acc_dtr_msgid_q[j] = m_pkt.smi_mpf2_dtr_msg_id;
                     if (fsys_txn_q[idx].ioaiu_core_id >= 0)
                        fsys_txn_q[idx].exp_smi_data_pkts = fsys_txn_q[idx].exp_smi_data_pkts + 1;

                     if (fsys_txn_q[idx].ioaiu_core_id < 0)
                        fsys_txn_q[idx].snp_chi_from_chi = 1;

                     fsys_txn_q[idx].update_time_accessed();
                     match_found = 1;
                     break;
                  end // if target_id matches
               end //foreach unique id
            end // if matched
            if (match_found == 1) break;
         end // foreach CMDReq
      end // if there are pending CMDReqs
      if (match_found == 1) break;
   end //foreach pending txn 
   if (match_found == 0) begin
      // This could be SNP for Recall
      match_found = 0;
      foreach (fsys_txn_q[idx]) begin
         if (fsys_txn_q[idx].rbr_rbid_q.size() > 0 && fsys_txn_q[idx].cmd_msg_id_q.size() == 0) begin
            foreach (fsys_txn_q[idx].snpreq_unq_id_q[i]) begin
               if (fsys_txn_q[idx].rbr_rbid_q[0] == m_pkt.smi_rbid    //there is 1 RBID value
                  && fsys_txn_q[idx].recall_addr == m_pkt.smi_addr
                  && fsys_txn_q[idx].dce_funit_id == m_pkt.smi_src_ncore_unit_id
                  && fsys_txn_q[idx].snpreq_unq_id_q[i] == {m_pkt.smi_targ_ncore_unit_id, m_pkt.smi_msg_id}
                  && fsys_txn_q[idx].snpreq_msg_id_q[0] == m_pkt.smi_msg_id
               ) begin
                  `uvm_info(`LABEL, $sformatf(
                     "FSYS_UID:%0d : SNPReq seen for recall %0s", 
                     fsys_txn_q[idx].fsys_unique_txn_id, 
                     m_pkt.convert2string()), UVM_NONE+50)
                  fsys_txn_q[idx].update_time_accessed();
                  fsys_txn_q[idx].is_coh = 1; // for EN_COH_CHECK
                  smi_snpreq_order_uid_<%=pidx%>.push_back(fsys_txn_q[idx].fsys_unique_txn_id);
                  // Add this SNP's RBID from RBRReq to rbid queue. This way DTW lookup equation remains same
                  fsys_txn_q[idx].rbid_val_q.push_back(1);
                  fsys_txn_q[idx].rbid_q.push_back(m_pkt.smi_rbid); //fsys_txn_q[idx].rbr_rbid_q[i]);
                  fsys_txn_q[idx].rbid_unit_id_q.push_back(m_pkt.smi_dest_id); //fsys_txn_q[idx].cmd_did_q[i]);
                  fsys_txn_q[idx].snpdat_unit_id_q.push_back(<%=obj.AiuInfo[pidx].FUnitId%>);
                  fsys_txn_q[idx].snpsrc_unit_id_q.push_back(m_pkt.smi_src_ncore_unit_id);
                  match_found = 1;
                  break;
               end // if matched
            end // foreach CMDReq DID
         end // if there are pending recalls 
         if (match_found == 1) break;
      end //foreach pending txn 
      if (match_found == 0)
         `uvm_error(`LABEL, $sformatf(
            "FSYS_SCB: SNPReq didn't match any pending transactions. %0s",
            m_pkt.convert2string()))
   end
endfunction : smi_snpreq_prediction_<%=pidx%>

//====================================================================================================
//
// Function : smi_sysreq_prediction
//
//====================================================================================================
function void fsys_scb_chi_predictor::smi_sysreq_prediction_<%=pidx%>(input <%=_child_blkid[pidx]%>_smi_agent_pkg::smi_seq_item m_pkt, ref fsys_scb_txn fsys_txn_q[$]);
   `undef LABEL
   `define LABEL "smi_sysreq_<%=_child_blkid[pidx]%>"
   `uvm_info(`LABEL, $sformatf("FSYS_SCB: SYSREQ seen: %0s", m_pkt.convert2string()), UVM_NONE+50)
   case(m_pkt.smi_sysreq_op)
      <%=_child_blkid[pidx]%>_smi_agent_pkg::SMI_SYSREQ_ATTACH:
      begin
         pending_attach_sys_req_<%=pidx%>.push_back(m_pkt);
      end
      <%=_child_blkid[pidx]%>_smi_agent_pkg::SMI_SYSREQ_DETACH:
      begin
         pending_attach_sys_req_<%=pidx%>.push_back(m_pkt);
      end
      default:
      begin
         if ($test$plusargs("EN_SYS_EVENT_CHECK")) begin
            if (m_pkt.smi_sysreq_op == <%=_child_blkid[pidx]%>_smi_agent_pkg::SMI_SYSREQ_EVENT) begin
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
function void fsys_scb_chi_predictor::analyze_sys_event_<%=pidx%>(input <%=_child_blkid[pidx]%>_smi_agent_pkg::smi_seq_item m_pkt, ref fsys_scb_txn fsys_txn_q[$]);
   `undef LABEL
   `define LABEL "analyze_sys_event_<%=_child_blkid[pidx]%>"
   fsys_scb_txn m_txn = fsys_scb_txn::type_id::create("m_txn");
   int find_q[$];
   bit matched = 0;
   if (m_pkt.smi_targ_ncore_unit_id == <%=obj.AiuInfo[pidx].FUnitId%>) begin
      find_q = fsys_txn_q.find_index with (item.is_sys_evnt == 1); 
      foreach(find_q[idx]) begin
         foreach (fsys_txn_q[find_q[idx]].sys_evnt_rcvrs_q[i]) begin
            if (fsys_txn_q[find_q[idx]].sys_evnt_rcvrs_q[i].funit_id == m_pkt.smi_targ_ncore_unit_id
               && fsys_txn_q[find_q[idx]].sys_evnt_rcvrs_q[i].dve_sent == 1
               && fsys_txn_q[find_q[idx]].sys_evnt_rcvrs_q[i].unit_rcvd == 0
               && fsys_txn_q[find_q[idx]].sys_evnt_rcvrs_q[i].smi_msg_id == m_pkt.smi_msg_id) begin
               fsys_txn_q[find_q[idx]].sys_evnt_rcvrs_q[i].unit_rcvd = 1;
               `uvm_info(`LABEL, $sformatf(
                  "FSYS_UID:%0d : <%=_child_blkid[pidx]%> received SYSREQ for a SYS_EVENT transaction. %0s", 
                  fsys_txn_q[find_q[idx]].fsys_unique_txn_id, m_pkt.convert2string()), UVM_NONE+50)
               matched = 1;
               break;
            end // if matche found
         end // foreach sys_evnt_rcvrs_q
      end // foreach sys_event txns
      if (matched == 0) begin
         `uvm_error(`LABEL, $sformatf("FSYS_SCB: Incoming SYS_EVENT didn't match any pending transactions. PKT: %0s", m_pkt.convert2string()))
      end
   end // incoming SYS_EVENT
   else begin
      if (m_pkt.smi_targ_ncore_unit_id !== <%=obj.DveInfo[0].FUnitId%>) begin
         `uvm_error(`LABEL, $sformatf("FSYS_SCB: Outgoing SYS_EVENT should always be going to DVE. PKT: %0s", m_pkt.convert2string()))
      end
      m_txn.fsys_unique_txn_id = fsys_scoreboard::get_next_unique_txn_id();
      `uvm_info(`LABEL, $sformatf(
         "FSYS_UID:%0d : Adding a SYS_EVENT to pending queue. PKT: %0s", 
         m_txn.fsys_unique_txn_id, m_pkt.convert2string()), UVM_NONE+50)
      m_txn.is_sys_evnt = 1;
      m_txn.source_funit_id = m_pkt.smi_src_ncore_unit_id;
      m_txn.smi_msg_id = m_pkt.smi_msg_id;
      fsys_txn_q.push_back(m_txn);
   end // outgoing SYS_EVENT

endfunction : analyze_sys_event_<%=pidx%>


//====================================================================================================
//
// Function : smi_sysrsp_prediction
//
//====================================================================================================
function void fsys_scb_chi_predictor::smi_sysrsp_prediction_<%=pidx%>(input <%=_child_blkid[pidx]%>_smi_agent_pkg::smi_seq_item m_pkt, ref fsys_scb_txn fsys_txn_q[$]);
   `undef LABEL
   `define LABEL "smi_sysrsp_<%=_child_blkid[pidx]%>"
   int find_q[$];
   bit matched=0;
   `uvm_info(`LABEL, $sformatf("FSYS_SCB: SYSRSP seen: %0s", m_pkt.convert2string()), UVM_NONE+50)
   find_q = pending_attach_sys_req_<%=pidx%>.find_index with (
                  item.smi_targ_ncore_unit_id == m_pkt.smi_src_ncore_unit_id
                  && item.smi_msg_id == m_pkt.smi_rmsg_id);
   if (find_q.size() > 0) begin
      if (pending_attach_sys_req_<%=pidx%>[find_q[0]].smi_sysreq_op == <%=_child_blkid[pidx]%>_smi_agent_pkg::SMI_SYSREQ_ATTACH) begin
         attached_funit_ids_<%=pidx%>.push_back(m_pkt.smi_src_ncore_unit_id);
         pending_attach_sys_req_<%=pidx%>.delete(find_q[0]);
         `uvm_info(`LABEL, $sformatf("FSYS_SCB: SYSRSP matched a pending SYSREQ. Marking AIU as attached to funit id: 0x%0h", m_pkt.smi_src_ncore_unit_id), UVM_NONE+50)
      end else if (pending_attach_sys_req_<%=pidx%>[find_q[0]].smi_sysreq_op == <%=_child_blkid[pidx]%>_smi_agent_pkg::SMI_SYSREQ_DETACH) begin
         foreach(attached_funit_ids_<%=pidx%>[idx]) begin
            if (attached_funit_ids_<%=pidx%>[idx] == m_pkt.smi_src_ncore_unit_id) begin
               attached_funit_ids_<%=pidx%>.delete(idx);
               matched = 1;
               `uvm_info(`LABEL, $sformatf("FSYS_SCB: SYSRSP matched a pending SYSREQ. Marking AIU as detached from funit id: 0x%0h", m_pkt.smi_src_ncore_unit_id), UVM_NONE+50)
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
function void fsys_scb_chi_predictor::analyze_sys_event_rsp_<%=pidx%>(input <%=_child_blkid[pidx]%>_smi_agent_pkg::smi_seq_item m_pkt, ref fsys_scb_txn fsys_txn_q[$]);
   `undef LABEL
   `define LABEL "analyze_sys_event_rsp_<%=_child_blkid[pidx]%>"
   int find_q[$];
   bit matched = 0;
   if (m_pkt.smi_src_ncore_unit_id !== <%=obj.AiuInfo[pidx].FUnitId%>) begin
      find_q = fsys_txn_q.find_index with (item.is_sys_evnt == 1 
                        && item.smi_msg_id == m_pkt.smi_rmsg_id 
                        && item.source_funit_id == m_pkt.smi_targ_ncore_unit_id
                        && item.sys_rsp_sent == 1);
      if (find_q.size() > 0) begin
         if (fsys_txn_q[find_q[0]].sys_evnt_rcvrs_q.size() !== 0) begin
            `uvm_error(`LABEL, $sformatf("FSYS_SCB: <%=_child_blkid[pidx]%> received SYS_EVENT RSP as originating unit, while it's still waiting for %0d SYSRSPes from other attached units. PKT: %0s",
               fsys_txn_q[find_q[0]].sys_evnt_rcvrs_q.size(), m_pkt.convert2string()))
         end
         if (fsys_txn_q[find_q[0]].sys_evnt_rcvrs_q.size() == 0 && fsys_txn_q[find_q[0]].sys_rsp_sent == 1) begin
               `uvm_info(`LABEL, $sformatf(
                  "FSYS_UID:%0d : Deleting transaction from fsys_txn_q. Remaining txns: 'd%0d",
                  fsys_txn_q[find_q[0]].fsys_unique_txn_id, (fsys_txn_q.size()-1)), UVM_NONE+50)
               fsys_txn_q.delete(find_q[0]);
         end
      end // if match found
      else begin
         `uvm_error(`LABEL, $sformatf("FSYS_SCB: Incoming SYSRSP didn't match any pending transactions. PKT: %0s", m_pkt.convert2string()))
      end
   end // incoming SYS_EVENT RSP
   else begin
      find_q = fsys_txn_q.find_index with (item.is_sys_evnt == 1);
      foreach (find_q[idx]) begin
         foreach (fsys_txn_q[find_q[idx]].sys_evnt_rcvrs_q[i]) begin
            if (fsys_txn_q[find_q[idx]].sys_evnt_rcvrs_q[i].funit_id == m_pkt.smi_src_ncore_unit_id
               && fsys_txn_q[find_q[idx]].sys_evnt_rcvrs_q[i].dve_sent == 1
               && fsys_txn_q[find_q[idx]].sys_evnt_rcvrs_q[i].unit_rcvd == 1
               && fsys_txn_q[find_q[idx]].sys_evnt_rcvrs_q[i].rsp_sent == 0
               && fsys_txn_q[find_q[idx]].sys_evnt_rcvrs_q[i].smi_msg_id == m_pkt.smi_rmsg_id) begin
               fsys_txn_q[find_q[idx]].sys_evnt_rcvrs_q[i].rsp_sent = 1;
               `uvm_info(`LABEL, $sformatf(
                  "FSYS_UID:%0d : <%=_child_blkid[pidx]%> sent SYSRSP for a SYS_EVENT transaction. %0s", 
                  fsys_txn_q[find_q[idx]].fsys_unique_txn_id, m_pkt.convert2string()), UVM_NONE+50)
               matched = 1;
               break;
            end // if match found
         end // foreach sys_evnt_rcvrs_q
      end // foreach sys_event txns
      if (matched == 0) begin
         `uvm_error(`LABEL, $sformatf("FSYS_SCB: Outgoing SYSRSP didn't match any pending transactions. PKT: %0s", m_pkt.convert2string()))
      end
   end // outpoing SYS_EVENT RSP
endfunction : analyze_sys_event_rsp_<%=pidx%>

//====================================================================================================
//MEM_CONSISTENCY
//====================================================================================================
function void fsys_scb_chi_predictor::package_and_send_mem_checker_<%=pidx%>(ref fsys_scb_txn fsys_txn_q[$], int index, input string txn_type="RD");
   cache_data_t wdata[1]; 
   cache_byte_en_t byte_en[1];
   int cacheline_bytes = (2**<%=obj.wCacheLineOffset%>);
   int start_byte = fsys_txn_q[index].m_chi_req_pkt_<%=pidx%>.addr[<%=obj.wCacheLineOffset%>-1:0];
   int end_byte = start_byte + (2 ** fsys_txn_q[index].m_chi_req_pkt_<%=pidx%>.size);
   wdata[0] = fsys_txn_q[index].chi_txn_data;
   byte_en[0] = fsys_txn_q[index].chi_byte_en;
   if (txn_type == "WR") begin
      mem_checker.write_on_native_if(.addr(fsys_txn_q[index].chi_cacheline_addr), 
                                  .wdata(wdata), 
                                  .byte_en(byte_en), 
                                  .txn_id(fsys_txn_q[index].m_chi_req_pkt_<%=pidx%>.txnid),
                                  .ns(fsys_txn_q[index].m_chi_req_pkt_<%=pidx%>.ns),
                                  .is_coh(fsys_txn_q[index].is_coh),
                                  .is_chi(1),
                                  .funit_id(<%=obj.AiuInfo[pidx].FUnitId%>), 
                                  .core_id(0),
                                  .fsys_txn_q(fsys_txn_q), 
                                  .fsys_index(index),
                                  .cached(1'b0));
   end // Write txn
   else begin
      // Normal memory
      if (fsys_txn_q[index].m_chi_req_pkt_<%=pidx%>.memattr[1] == 0) begin
         start_byte = (start_byte/(2 ** fsys_txn_q[index].m_chi_req_pkt_<%=pidx%>.size)) * (2 ** fsys_txn_q[index].m_chi_req_pkt_<%=pidx%>.size);
         end_byte = start_byte + (2 ** fsys_txn_q[index].m_chi_req_pkt_<%=pidx%>.size) - 1;
         `uvm_info("MEM_CONST", $sformatf("FSYS_UID:%0d : normal mem: start byte = 0x%0h, end byte = 0x%0h",fsys_txn_q[index].fsys_unique_txn_id, start_byte, end_byte ), UVM_MEDIUM)
      end 
      //device memory
      else begin 
         start_byte = (start_byte/(2 ** fsys_txn_q[index].m_chi_req_pkt_<%=pidx%>.size)) * (2 ** fsys_txn_q[index].m_chi_req_pkt_<%=pidx%>.size);
         end_byte = start_byte + (2 ** fsys_txn_q[index].m_chi_req_pkt_<%=pidx%>.size) - 1;
         start_byte = fsys_txn_q[index].m_chi_req_pkt_<%=pidx%>.addr[<%=obj.wCacheLineOffset%>-1:0];
         `uvm_info("DEBUG", $sformatf("FSYS_UID:%0d : device mem: start byte = 0x%0h, end byte = 0x%0h",fsys_txn_q[index].fsys_unique_txn_id, start_byte, end_byte ), UVM_MEDIUM)
      end
      //TODO: Skip data check for dataless txns
      for(int i = 0; i < cacheline_bytes; i++) begin
         if (i < start_byte || i >= end_byte) begin
            byte_en[0][i] = 1'b0;
         end
      end
      mem_checker.read_on_native_if(.addr(fsys_txn_q[index].chi_cacheline_addr), 
                                  .rdata(wdata), 
                                  .byte_en(byte_en), 
                                  .txn_id(fsys_txn_q[index].m_chi_req_pkt_<%=pidx%>.txnid),
                                  .ns(fsys_txn_q[index].m_chi_req_pkt_<%=pidx%>.ns),
                                  .is_coh(fsys_txn_q[index].is_coh),
                                  .is_chi(1),
                                  .funit_id(<%=obj.AiuInfo[pidx].FUnitId%>), 
                                  .core_id(0),
                                  .read_issue_time(fsys_txn_q[index].m_chi_req_pkt_<%=pidx%>.pkt_time),
                                  .cache_unit(fsys_txn_q[index].snoop_data_fwded), // Snooped data could be cached in the source AIU
                                  .fsys_txn_q(fsys_txn_q), 
                                  .fsys_index(index));
   end // Read txn
endfunction : package_and_send_mem_checker_<%=pidx%>
//COH_CHECKER
function void fsys_scb_chi_predictor::package_and_send_coh_checker_<%=pidx%>(fsys_scb_txn fsys_txn_q,bit [1:0] resperr,bit [2:0]  resp,bit isRd,isWr,isSnp,int idx =0);
   `undef LABEL
   `define LABEL "package_and_send_coh_checker_<%=pidx%>"
     cache_state_t state ;
     chi_cmpdata_resp_t cmpdata_resp;
     chi_snp_resp_t snp_resp;
     bit flush = 0;
     if(isRd  || isWr)
       `uvm_info(`LABEL,$sformatf("isRd:%0b isWr:%0b isSnp:%0b is_coh :%0b opcode:%0s excl:%0b funit_id:<%=obj.AiuInfo[pidx].FUnitId%>",isRd,isWr,isSnp,fsys_txn_q.is_coh,fsys_txn_q.m_chi_req_pkt_<%=pidx%>.opcode.name(),fsys_txn_q.m_chi_req_pkt_<%=pidx%>.excl),UVM_NONE+50);
     if(isSnp)
       `uvm_info(`LABEL,$sformatf("isRd:%0b isWr:%0b isSnp:%0b is_coh :%0b opcode:%0s funit_id:<%=obj.AiuInfo[pidx].FUnitId%>",isRd,isWr,isSnp,fsys_txn_q.is_coh,fsys_txn_q.m_chi_snp_pkt_<%=pidx%>.opcode.name()),UVM_NONE+50);
     if(fsys_txn_q.is_coh)begin
      case({isSnp,isWr,isRd})
       3'b001:if(fsys_txn_q.m_chi_req_pkt_<%=pidx%>.opcode inside {<%=_child_blkid[pidx]%>_env_pkg::read_ops,<%=_child_blkid[pidx]%>_env_pkg::dataless_ops,<%=_child_blkid[pidx]%>_env_pkg::stash_ops,<%=_child_blkid[pidx]%>_env_pkg::atomic_dtls_ops,<%=_child_blkid[pidx]%>_env_pkg::atomic_dat_ops})begin
    <% if(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-E') { %>
                 if(!(fsys_txn_q.m_chi_req_pkt_<%=pidx%>.opcode inside {<%=_child_blkid[pidx]%>_env_pkg::CLEANSHARED,<%=_child_blkid[pidx]%>_env_pkg::CLEANSHAREDPERSIST,<%=_child_blkid[pidx]%>_env_pkg::CLEANSHAREDPERSISTSEP}))begin
                  if((resperr < 'b01 && !fsys_txn_q.m_chi_req_pkt_<%=pidx%>.excl) || 
                     ((((fsys_txn_q.m_chi_req_pkt_<%=pidx%>.opcode inside { <%=_child_blkid[pidx]%>_env_pkg::READPREFERUNIQUE,<%=_child_blkid[pidx]%>_env_pkg::MAKEREADUNIQUE}) && (resp inside {'b010,'b110}) && (!fsys_txn_q.chi_cmd_num)) ||(resperr == 'b01)) && fsys_txn_q.m_chi_req_pkt_<%=pidx%>.excl))begin
    <% } else { %>
                 if(!(fsys_txn_q.m_chi_req_pkt_<%=pidx%>.opcode inside {<%=_child_blkid[pidx]%>_env_pkg::CLEANSHARED,<%=_child_blkid[pidx]%>_env_pkg::CLEANSHAREDPERSIST}))begin
                  if((resperr < 'b01 && !fsys_txn_q.m_chi_req_pkt_<%=pidx%>.excl) || ((resperr == 'b01) && fsys_txn_q.m_chi_req_pkt_<%=pidx%>.excl))begin
    <% } %>
                    cmpdata_resp = resp;
                    case(cmpdata_resp)
                      CMPDATARESP_IX  :state = IX;
                      CMPDATARESP_UC  :state = UC;
                      CMPDATARESP_SC  :state = SC;
                      CMPDATARESP_UDPD:state = UD;
                      CMPDATARESP_SDPD:state = SD;
                    endcase
                    if((fsys_txn_q.m_chi_req_pkt_<%=pidx%>.opcode inside {<%=_child_blkid[pidx]%>_env_pkg::READONCE,<%=_child_blkid[pidx]%>_env_pkg::READONCEMAKEINVALID,<%=_child_blkid[pidx]%>_env_pkg::READONCECLEANINVALID})||
                       (fsys_txn_q.m_chi_req_pkt_<%=pidx%>.opcode inside {<%=_child_blkid[pidx]%>_env_pkg::stash_ops}))begin
                      state = IX;
                    end
                    coherency_checker.update_state(.addr(fsys_txn_q.m_chi_req_pkt_<%=pidx%>.addr),.ns(fsys_txn_q.m_chi_req_pkt_<%=pidx%>.ns),.funit_idx(<%=obj.AiuInfo[pidx].FUnitId%>),.state(state));
                  end
                end
              end
       3'b010:begin
                if(fsys_txn_q.m_chi_req_pkt_<%=pidx%>.opcode == <%=_child_blkid[pidx]%>_env_pkg::WRITECLEANFULL)begin
                  cmpdata_resp = resp;
                  case(cmpdata_resp)
                    CMPDATARESP_IX  :state = IX;
                    CMPDATARESP_UC  :state = UC;
                    CMPDATARESP_SC  :state = SC;
                    CMPDATARESP_UDPD:state = UC;
                    CMPDATARESP_SDPD:state = SC;
                  endcase
                end
                else begin
                   state = IX;
                end
                coherency_checker.update_state(.addr(fsys_txn_q.m_chi_req_pkt_<%=pidx%>.addr),.ns(fsys_txn_q.m_chi_req_pkt_<%=pidx%>.ns),.funit_idx(<%=obj.AiuInfo[pidx].FUnitId%>),.state(state),.flush(flush));
              end
       3'b100:begin 
                if(resperr < 'b10)begin
                   snp_resp = resp;
                   case(snp_resp)
                    SNPRESP_IX  :state = IX;
                    SNPRESP_SC  :state = SC;
                    SNPRESP_UC  :state = UC;
                    SNPRESP_SD  :state = SD;
                    SNPRESP_IXPD:state = IX;
                    SNPRESP_SCPD:state = SC;
                    SNPRESP_UCPD:state = UC;
                   endcase
                 end
                if((!(fsys_txn_q.m_chi_snp_pkt_<%=pidx%>.opcode inside {<%=_child_blkid[pidx]%>_env_pkg::SNPSTASHUNQ,<%=_child_blkid[pidx]%>_env_pkg::SNPSTASHSHRD}))
                   || (fsys_txn_q.cmd_msg_id_q.size() == 0))begin
                   coherency_checker.update_state(.addr(fsys_txn_q.snpreq_addr_q[idx]),.ns(fsys_txn_q.snpreq_ns_q[idx]),.funit_idx(<%=obj.AiuInfo[pidx].FUnitId%>),.state(state));
                end
              end
       endcase
     end
     else begin
       if(isWr)begin
         if(fsys_txn_q.m_chi_req_pkt_<%=pidx%>.opcode inside {<%=_child_blkid[pidx]%>_env_pkg::WRITEEVICTFULL,<%=_child_blkid[pidx]%>_env_pkg::WRITECLEANPTL,<%=_child_blkid[pidx]%>_env_pkg::WRITECLEANFULL,<%=_child_blkid[pidx]%>_env_pkg::WRITEBACKPTL,<%=_child_blkid[pidx]%>_env_pkg::WRITEBACKFULL})begin
           state = IX;
           flush = 1;
           coherency_checker.update_state(.addr(fsys_txn_q.m_chi_req_pkt_<%=pidx%>.addr),.ns(fsys_txn_q.m_chi_req_pkt_<%=pidx%>.ns),.funit_idx(<%=obj.AiuInfo[pidx].FUnitId%>),.state(state),.flush(flush));
         end
       end
       if(isRd)begin
         if(fsys_txn_q.m_chi_req_pkt_<%=pidx%>.opcode == <%=_child_blkid[pidx]%>_env_pkg::EVICT 
            <% if (obj.AiuInfo[pidx].fnNativeInterface == 'CHI-E') { %>
            || fsys_txn_q.m_chi_req_pkt_<%=pidx%>.opcode == <%=_child_blkid[pidx]%>_env_pkg::WRITEEVICTOREVICT
         <% } %>
         )begin
           state = IX;
           coherency_checker.update_state(.addr(fsys_txn_q.m_chi_req_pkt_<%=pidx%>.addr),.ns(fsys_txn_q.m_chi_req_pkt_<%=pidx%>.ns),.funit_idx(<%=obj.AiuInfo[pidx].FUnitId%>),.state(state));
         end
       end
     end
 
endfunction : package_and_send_coh_checker_<%=pidx%>

<% } // if chiaui%>
<% } // foreach aius%>

////////////////////////////////////////////////////////////////////////////////
// Function: check_phase
// Description: Runs end of test checks and prints debug information
////////////////////////////////////////////////////////////////////////////////
function void fsys_scb_chi_predictor::check_phase(uvm_phase phase);
   <% for(var pidx = 0; pidx < _child_blkid.length; pidx++) { %>
   <%  if(_child_blk[pidx].match('chiaiu')) { %>
   if (pending_attach_sys_req_<%=pidx%>.size() !== 0) begin
      //TODO: make this an error when TB has support to drive event_if signals
      `uvm_warning("check_phase", $psprintf("FSYS_SCB: <%=_child_blkid[pidx]%> has %0d pending SYSREQ that didn't see SYSRSP", pending_attach_sys_req_<%=pidx%>.size()))
   end
   <% } // if chiaiu%>
   <% } // foreach aius%>
endfunction : check_phase

//====================================================================================================
//
// Function : check_flags_and_delete_txn
//
//====================================================================================================
function bit fsys_scb_chi_predictor::check_flags_and_delete_txn(string label, int index, ref fsys_scb_txn fsys_txn_q[$], input int line, bit ignore_checks = 0);
   int delete = 0;
   string line_s, func_line;

   line_s.itoa(line);
   func_line = $sformatf("%0s,(%0s)",label,line_s);

   if (ignore_checks == 1) begin
      `uvm_info(func_line, $sformatf("Ignoring checking flags"), UVM_HIGH)
      delete = 1;
   end 
   else if ((((fsys_txn_q[index].dmi_check_done == 1 && fsys_txn_q[index].dmi_bound == 1) 
         || (fsys_txn_q[index].dii_check_done == 1 && fsys_txn_q[index].dii_bound == 1))
       && (fsys_txn_q[index].dce_check_done == 1 || fsys_txn_q[index].is_coh == 0)) 
       && (fsys_txn_q[index].aiu_check_done == 1)
   ) begin
      delete = 1;
   end
   else if (fsys_txn_q[index].aiu_check_done == 1 && fsys_txn_q[index].chi_unsupp_txn == 1) begin
      delete = 1;
   end
   `uvm_info(func_line, $sformatf("Check Done Flags | DMI :%0d, DII :%0d, DCE :%0d, AIU :%0d, UNSUPP_TXN: %0d, IS_COH :%0d", fsys_txn_q[index].dmi_check_done, fsys_txn_q[index].dii_check_done, fsys_txn_q[index].dce_check_done, fsys_txn_q[index].aiu_check_done, fsys_txn_q[index].chi_unsupp_txn, fsys_txn_q[index].is_coh), UVM_NONE+50)
   //If all conditions are satified, delete the txn
   if (delete == 1) begin
      `uvm_info(func_line, $sformatf(
         "FSYS_UID:%0d : Deleting transaction from fsys_txn_q. Remaining txns: 'd%0d",
         fsys_txn_q[index].fsys_unique_txn_id, (fsys_txn_q.size()-1)), UVM_NONE+50)
      `ifdef FSYS_SCB_COVER_ON
         fsys_txn_path_cov.sample_txn(fsys_txn_q[index].smi_msg_order_q, (fsys_txn_q[index].ioaiu_core_id >= 0));
      `endif // `ifdef FSYS_SCB_COVER_ON
      fsys_txn_q[index].print_path();
      fsys_txn_q.delete(index);
      return(1);
   end else begin
      return(0);
   end
endfunction : check_flags_and_delete_txn
// End of file
