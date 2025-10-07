////////////////////////////////////////////////////////////////////////////////
//
// Author       : Neha F
// Purpose      : IOAIU predictor class
// Description  : This is a component of fsys_scoreboard. This component will
//                add new AXI packets as a new scb_txn and add prediction flags 
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
import concerto_env_pkg::*;


class fsys_scb_ioaiu_predictor extends uvm_component;

   int ioaiu_rdtxn_cnt, ioaiu_wrtxn_cnt;
   int min_latency = 1000000000; 
   int max_latency;
   `ifdef FSYS_SCB_COVER_ON 
   fsys_txn_path_coverage fsys_txn_path_cov;
   `endif // `ifdef FSYS_SCB_COVER_ON              

   `uvm_component_utils(fsys_scb_ioaiu_predictor)

   extern function new(string name = "fsys_scb_ioaiu_predictor", uvm_component parent = null);
   extern function void build_phase(uvm_phase phase);
   extern function bit  check_flags_and_delete_txn(string label, int index, ref fsys_scb_txn fsys_txn_q[$], input bit ignore_checks = 0, int line);
   extern function bit[63:0] smi_snp_addr_to_ace_snp_addr(int snp_no, bit[64:0] addr, bit[64:0] other_part_addr, bit mpf3_range, int mpf3_num, int mpf1, int other_part_mpf1);

   <% for(var pidx = 0; pidx < _child_blkid.length; pidx++) { %>
   <%  if(_child_blk[pidx].match('ioaiu')) { %>
   <%for(var i = 0; i < obj.AiuInfo[pidx].nNativeInterfacePorts; i++){%> 
   extern function void analyze_read_addr_pkt_<%=pidx%>_<%=i%>(input <%=_child_blkid[pidx]%>_env_pkg::axi4_read_addr_pkt_t m_pkt, ref fsys_scb_txn fsys_txn_q[$]);
   extern function void process_dvm_cmpl_<%=pidx%>_<%=i%>(input <%=_child_blkid[pidx]%>_env_pkg::ace_read_addr_pkt_t m_pkt, ref fsys_scb_txn fsys_txn_q[$], input bit ac_pkt=0);
   extern function bit match_for_dvm_part_2_<%=pidx%>_<%=i%>(input <%=_child_blkid[pidx]%>_env_pkg::ace_read_addr_pkt_t m_pkt, ref fsys_scb_txn fsys_txn_q[$]);
   extern function void analyze_write_addr_pkt_<%=pidx%>_<%=i%>(input <%=_child_blkid[pidx]%>_env_pkg::axi4_write_addr_pkt_t m_pkt, ref fsys_scb_txn fsys_txn_q[$]);
   extern function void analyze_write_data_pkt_<%=pidx%>_<%=i%>(input <%=_child_blkid[pidx]%>_env_pkg::axi4_write_data_pkt_t m_pkt, ref fsys_scb_txn fsys_txn_q[$]);
   extern function void analyze_read_data_pkt_<%=pidx%>_<%=i%>(input <%=_child_blkid[pidx]%>_env_pkg::axi4_read_data_pkt_t m_pkt, ref fsys_scb_txn fsys_txn_q[$]);
   extern function void analyze_write_resp_pkt_<%=pidx%>_<%=i%>(input <%=_child_blkid[pidx]%>_env_pkg::axi4_write_resp_pkt_t m_pkt, ref fsys_scb_txn fsys_txn_q[$]);
   extern function bit process_dvm_cmpl_resp_<%=pidx%>_<%=i%>(input <%=_child_blkid[pidx]%>_env_pkg::axi4_read_data_pkt_t m_pkt, ref fsys_scb_txn fsys_txn_q[$]);
   <% if(obj.AiuInfo[pidx].fnNativeInterface == "ACE5" || obj.AiuInfo[pidx].fnNativeInterface == "ACE" || obj.AiuInfo[pidx].fnNativeInterface == "ACELITE-E" || obj.AiuInfo[pidx].fnNativeInterface == "ACE-LITE"){ %>
   extern function void analyze_snoop_addr_pkt_<%=pidx%>_<%=i%>(<%=_child_blkid[pidx]%>_env_pkg::ace_snoop_addr_pkt_t m_pkt, ref fsys_scb_txn fsys_txn_q[$]);
   extern function void process_dvm_snp_<%=pidx%>_<%=i%>(<%=_child_blkid[pidx]%>_env_pkg::ace_snoop_addr_pkt_t m_pkt, ref fsys_scb_txn fsys_txn_q[$]);
   extern function void analyze_snoop_resp_pkt_<%=pidx%>_<%=i%>(<%=_child_blkid[pidx]%>_env_pkg::ace_snoop_resp_pkt_t m_pkt, ref fsys_scb_txn fsys_txn_q[$]);
   extern function void analyze_snoop_data_pkt_<%=pidx%>_<%=i%>(<%=_child_blkid[pidx]%>_env_pkg::ace_snoop_data_pkt_t m_pkt, ref fsys_scb_txn fsys_txn_q[$]);
   <%}%>
   <%=_child_blkid[pidx]%>_env_pkg::ace_write_data_pkt_t tmp_data_pkt_<%=pidx%>_<%=i%>[$];
   int snoop_order_uid_<%=pidx%>_<%=i%>[$];
   int snoop_order_snp_idx_<%=pidx%>_<%=i%>[$];
   int snoop_order_uid_counter_<%=pidx%>_<%=i%>;
   // CONC-14435
   int snoop_waiting_resp_counter_<%=pidx%>_<%=i%>;
   <%=_child_blkid[pidx]%>_env_pkg::ace_snoop_data_pkt_t snp_data_pkt_<%=pidx%>_<%=i%>[$];
   <% if(obj.AiuInfo[pidx].useCache == 1) {%>
   <%=_child_blkid[pidx]%>_ccp_env_pkg::ccp_cache_model  m_ccp_cache_model_<%=pidx%>_<%=i%>;
   <% } // useCache%>
   <% } // foreach InterfacePorts%>
   <% if(obj.AiuInfo[pidx].fnNativeInterface == "ACE5"||obj.AiuInfo[pidx].fnNativeInterface == "ACE"){ %>
   extern function void package_and_send_coh_checker_<%=pidx%>(fsys_scb_txn fsys_txn_q=null,<%=_child_blkid[pidx]%>_env_pkg::ace_snoop_addr_pkt_t snp_addr_pkt=null,bit [1:0] resperr,bit [4:0] resp,bit isRd,isWr,isSnp,int idx = 0);
   <%=_child_blkid[pidx]%>_env_pkg::ace_snoop_addr_pkt_t  ace_snp_req_q_<%=pidx%>[$];
   <%}%>
   <% if(obj.AiuInfo[pidx].useCache == 1) {%>
   extern function void package_and_send_coh_checker_<%=pidx%>(fsys_scb_txn fsys_txn_q=null,<%=_child_blkid[pidx]%>_smi_agent_pkg::smi_seq_item req_pkt = null, <%=_child_blkid[pidx]%>_smi_agent_pkg::smi_seq_item m_pkt=null,bit isRd,isWr,isSnp,int idx = 0);
   extern function void smi_snprsp_proxy_cache_<%=pidx%>(input <%=_child_blkid[pidx]%>_smi_agent_pkg::smi_seq_item m_pkt);
   <% if(obj.AiuInfo[pidx].useCache == 1) {%>
   <%=_child_blkid[pidx]%>_smi_agent_pkg::smi_seq_item  proxycache_snp_req_q_<%=pidx%>[$];
   <% } %>
   <% } // useCache%>
   extern function void analyze_smi_pkt_<%=pidx%>(input <%=_child_blkid[pidx]%>_smi_agent_pkg::smi_seq_item m_pkt, ref fsys_scb_txn fsys_txn_q[$]);
   extern function void smi_cmd_msg_prediction_<%=pidx%>(input <%=_child_blkid[pidx]%>_smi_agent_pkg::smi_seq_item m_pkt, ref fsys_scb_txn fsys_txn_q[$]);
   extern function bit process_read_cmd_types_<%=pidx%>(ref <%=_child_blkid[pidx]%>_smi_agent_pkg::smi_seq_item m_pkt, ref fsys_scb_txn fsys_txn_q[$]);
   extern function bit process_write_cmd_types_<%=pidx%>(ref <%=_child_blkid[pidx]%>_smi_agent_pkg::smi_seq_item m_pkt, ref fsys_scb_txn fsys_txn_q[$]);
   extern function void add_eviction_txn_<%=pidx%>(ref <%=_child_blkid[pidx]%>_smi_agent_pkg::smi_seq_item m_pkt, ref fsys_scb_txn fsys_txn_q[$]);
   extern function bit process_dvm_msg_<%=pidx%>(ref <%=_child_blkid[pidx]%>_smi_agent_pkg::smi_seq_item m_pkt, ref fsys_scb_txn fsys_txn_q[$]);
   extern function void smi_str_prediction_<%=pidx%>(input <%=_child_blkid[pidx]%>_smi_agent_pkg::smi_seq_item m_pkt, ref fsys_scb_txn fsys_txn_q[$]);
   extern function void smi_dtw_prediction_<%=pidx%>(input <%=_child_blkid[pidx]%>_smi_agent_pkg::smi_seq_item m_pkt, ref fsys_scb_txn fsys_txn_q[$]);
   extern function void smi_dtr_prediction_<%=pidx%>(input <%=_child_blkid[pidx]%>_smi_agent_pkg::smi_seq_item m_pkt, ref fsys_scb_txn fsys_txn_q[$]);
   extern function void smi_snpreq_prediction_<%=pidx%>(input <%=_child_blkid[pidx]%>_smi_agent_pkg::smi_seq_item m_pkt, ref fsys_scb_txn fsys_txn_q[$]);
   extern function void smi_updreq_prediction_<%=pidx%>(input <%=_child_blkid[pidx]%>_smi_agent_pkg::smi_seq_item m_pkt, ref fsys_scb_txn fsys_txn_q[$]);
   extern function void smi_sysreq_prediction_<%=pidx%>(input <%=_child_blkid[pidx]%>_smi_agent_pkg::smi_seq_item m_pkt, ref fsys_scb_txn fsys_txn_q[$]);
   extern function void analyze_sys_event_<%=pidx%>(input <%=_child_blkid[pidx]%>_smi_agent_pkg::smi_seq_item m_pkt, ref fsys_scb_txn fsys_txn_q[$]);
   extern function void smi_sysrsp_prediction_<%=pidx%>(input <%=_child_blkid[pidx]%>_smi_agent_pkg::smi_seq_item m_pkt, ref fsys_scb_txn fsys_txn_q[$]);
   extern function void smi_otherrsp_prediction_<%=pidx%>(input <%=_child_blkid[pidx]%>_smi_agent_pkg::smi_seq_item m_pkt, ref fsys_scb_txn fsys_txn_q[$]);
   extern function void analyze_sys_event_rsp_<%=pidx%>(input <%=_child_blkid[pidx]%>_smi_agent_pkg::smi_seq_item m_pkt, ref fsys_scb_txn fsys_txn_q[$]);
   extern function <%=_child_blkid[pidx]%>_smi_agent_pkg::eMsgCMD ace_cmd_to_smi_cmd_<%=pidx%>(string snoop_type);
   //SYSREQ related lists 
   <%=_child_blkid[pidx]%>_smi_agent_pkg::smi_seq_item pending_attach_sys_req_<%=pidx%>[$];
   //Queue of funit IDs of DCEs & DVEs that this AIU is attached to
   int attached_funit_ids_<%=pidx%>[$];
   int smi_snpreq_order_uid_<%=pidx%>[$];
   int smi_snpreq_order_idx_<%=pidx%>[$];
   int smi_snpreq_order_idx2_<%=pidx%>[$];

   <% } // if ioaui%>
   <% } // foreach aius%>

   // End of test checks
   extern function void check_phase(uvm_phase phase);

   //MEM_CONSISTENCY
   mem_consistency_checker mem_checker;
   bit   m_en_mem_check;
   //Coherency checker
   bit   m_en_coh_check;
   fsys_coherency_checker  coherency_checker;

endclass : fsys_scb_ioaiu_predictor

//===================================================================================================
//
//===================================================================================================
function fsys_scb_ioaiu_predictor::new(string name = "fsys_scb_ioaiu_predictor", uvm_component parent = null);
   super.new(name,parent);
endfunction : new

//===================================================================================================
//
//===================================================================================================
function void fsys_scb_ioaiu_predictor::build_phase(uvm_phase phase);
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
         `uvm_fatal("fsys_scb_ioaiu_predictor", "Could not find mem_consistency_checker object in UVM DB");
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
   <% for(var pidx = 0; pidx < _child_blkid.length; pidx++) { %>
   <%  if(_child_blk[pidx].match('ioaiu')) { %>
   <% if(obj.AiuInfo[pidx].useCache == 1) {%>
   <%for(var i = 0; i < obj.AiuInfo[pidx].nNativeInterfacePorts; i++){%> 
      if (!uvm_config_db#(<%=_child_blkid[pidx]%>_ccp_env_pkg::ccp_cache_model)::get(.cntxt( this ), 
                                                   .inst_name ( "" ), 
                                                   .field_name( "m_ccp_cache_model_<%=pidx%>_<%=i%>" ),
                                                   .value( m_ccp_cache_model_<%=pidx%>_<%=i%> ))) begin
         `uvm_error( get_name(),"m_ccp_cache_model_<%=pidx%>_<%=i%> not found" )
      end 
   <% } // foreach InterfacePorts%>
   <% } // useCache%>
   <% } // if ioaui%>
   <% } // foreach aius%>
endfunction : build_phase

<% for(var pidx = 0; pidx < _child_blkid.length; pidx++) { %>
<%  if(_child_blk[pidx].match('ioaiu')) { %>
<% if(obj.AiuInfo[pidx].fnNativeInterface == "ACE5" ||obj.AiuInfo[pidx].fnNativeInterface == "ACE" || obj.AiuInfo[pidx].useCache == 1 ){ %>
<% if(obj.AiuInfo[pidx].fnNativeInterface == "ACE5"||obj.AiuInfo[pidx].fnNativeInterface == "ACE"){ %>
function void fsys_scb_ioaiu_predictor::package_and_send_coh_checker_<%=pidx%>(fsys_scb_txn fsys_txn_q=null,<%=_child_blkid[pidx]%>_env_pkg::ace_snoop_addr_pkt_t snp_addr_pkt=null, bit [1:0] resperr,bit [4:0]  resp,bit isRd,isWr,isSnp,int idx =0);
<% } else { %>
function void fsys_scb_ioaiu_predictor::package_and_send_coh_checker_<%=pidx%>(fsys_scb_txn fsys_txn_q = null,<%=_child_blkid[pidx]%>_smi_agent_pkg::smi_seq_item req_pkt = null,<%=_child_blkid[pidx]%>_smi_agent_pkg::smi_seq_item m_pkt = null,bit isRd,isWr,isSnp,int idx = 0);
<% } %>
   `undef LABEL
   `define LABEL "package_and_send_coh_checker_<%=pidx%>"
     cache_state_t init_state,end_state ;
     bit flush = 0;
<% if(obj.AiuInfo[pidx].fnNativeInterface == "ACE5"||obj.AiuInfo[pidx].fnNativeInterface == "ACE"){ %>
     axi_acsnoop_enum_t acsnooptype;
     string arcmdtype, awcmdtype;
     if(isRd)begin
       arcmdtype = fsys_txn_q.ace_command_type; //fsys_txn_q.m_axi_rd_addr_pkt_<%=pidx%>.arsnoop;
       `uvm_info(`LABEL,$sformatf("isRd:%0b isWr:%0b isSnp:%0b is_coh :%0b opcode:%0s excl:%0b funit_id:<%=obj.AiuInfo[pidx].FUnitId%>",isRd,isWr,isSnp,fsys_txn_q.is_coh,arcmdtype,fsys_txn_q.m_axi_rd_addr_pkt_<%=pidx%>.arprot[1]),UVM_NONE+50);
     end
     if(isWr)begin
        awcmdtype = fsys_txn_q.ace_command_type; //fsys_txn_q.m_axi_wr_addr_pkt_<%=pidx%>.awsnoop;
       `uvm_info(`LABEL,$sformatf("isRd:%0b isWr:%0b isSnp:%0b is_coh :%0b opcode:%0s excl:%0b funit_id:<%=obj.AiuInfo[pidx].FUnitId%>",isRd,isWr,isSnp,fsys_txn_q.is_coh,awcmdtype,fsys_txn_q.m_axi_wr_addr_pkt_<%=pidx%>.awprot[1]),UVM_NONE+50);
     end
     if(isSnp)begin
        acsnooptype = snp_addr_pkt.acsnoop;
       `uvm_info(`LABEL,$sformatf("isRd:%0b isWr:%0b isSnp:%0b opcode:%0s funit_id:<%=obj.AiuInfo[pidx].FUnitId%>",isRd,isWr,isSnp,acsnooptype.name()),UVM_NONE+50);
     end
     if(isWr && fsys_txn_q.ace_command_type inside {"EVCT","WREVCT","WRBK"})begin
         end_state = IX;
         if(fsys_txn_q.ace_command_type == "EVCT")begin
           end_state = IX;
           coherency_checker.update_state(.addr(fsys_txn_q.m_axi_wr_addr_pkt_<%=pidx%>.awaddr),.ns(fsys_txn_q.m_axi_wr_addr_pkt_<%=pidx%>.awprot[1]),.funit_idx(<%=obj.AiuInfo[pidx].FUnitId%>),.state(end_state),.flush(flush));
         end
         if(fsys_txn_q.ace_command_type inside {"WREVCT","WRBK"})begin
           flush = 1;
           coherency_checker.update_state(.addr(fsys_txn_q.m_axi_wr_addr_pkt_<%=pidx%>.awaddr),.ns(fsys_txn_q.m_axi_wr_addr_pkt_<%=pidx%>.awprot[1]),.funit_idx(<%=obj.AiuInfo[pidx].FUnitId%>),.state(end_state),.flush(flush));
         end
      end
      else begin
        case({isSnp,isWr,isRd})
         3'b001:if(!(fsys_txn_q.ace_command_type inside {"RDONCE","CLNSHRD","CLNSHRDPERSIST","RDNOSNP"}))begin
                  if((resperr < 'b01 && !fsys_txn_q.m_axi_rd_addr_pkt_<%=pidx%>.arlock) || ((resperr == 'b01) && fsys_txn_q.m_axi_rd_addr_pkt_<%=pidx%>.arlock))begin
                    case(resp[3:2])
                      2'b00:end_state = UC;
                      2'b10:end_state = SC;
                      2'b01:end_state = UD;
                      2'b11:end_state = SD;
                    endcase
                    if(fsys_txn_q.ace_command_type inside {"RDONCEMAKEINVLD","RDONCECLNINVLD","CLNINVL","MKINVL"})begin
                      end_state = IX;
                    end
                    coherency_checker.update_state(.addr(fsys_txn_q.m_axi_rd_addr_pkt_<%=pidx%>.araddr),.ns(fsys_txn_q.m_axi_rd_addr_pkt_<%=pidx%>.arprot[1]),.funit_idx(<%=obj.AiuInfo[pidx].FUnitId%>),.state(end_state));
                  end
                end
         3'b010:begin
                  init_state = coherency_checker.get_state(.addr(fsys_txn_q.pcie_mode_smi_addr_q[idx]),.ns(fsys_txn_q.m_axi_wr_addr_pkt_<%=pidx%>.awprot[1]),.funit_idx(<%=obj.AiuInfo[pidx].FUnitId%>));
                  if(fsys_txn_q.ace_command_type == "WRCLN")begin
                     // If a snoop came before WRCLN finished, the cacheline maybe invalidated and stays invalidated
                     if (init_state == IX) end_state = IX; 
                     else end_state = SC; //could be UC, but SC is also an allowed end state.
                  end
                  //TODO: Need more info to complete this check 
                  //else if (fsys_txn_q.ace_command_type inside {"WRUNQ", "WRLNUNQ"}) begin
                  //   if(fsys_txn_q.m_axi_wr_addr_pkt_<%=pidx%>.awunique) end_state = IX;
                  //   else                                                end_state = SC;
                  //end
                  else begin
                     end_state = IX;
                  end
                  coherency_checker.update_state(.addr(fsys_txn_q.pcie_mode_smi_addr_q[idx]),.ns(fsys_txn_q.m_axi_wr_addr_pkt_<%=pidx%>.awprot[1]),.funit_idx(<%=obj.AiuInfo[pidx].FUnitId%>),.state(end_state),.flush(flush));
                end
         3'b100:begin
                 init_state = coherency_checker.get_state(.addr(snp_addr_pkt.acaddr),.ns(snp_addr_pkt.acprot[1]),.funit_idx(<%=obj.AiuInfo[pidx].FUnitId%>));
                
                  if(!resp[1])begin
                    if(resp[3:2] == 2'b10)begin
                       if(snp_addr_pkt.acsnoop inside {<%=_child_blkid[pidx]%>_env_pkg::RDCLN, <%=_child_blkid[pidx]%>_env_pkg::RDSHRD, <%=_child_blkid[pidx]%>_env_pkg::RDNOTSHRDDIR, <%=_child_blkid[pidx]%>_env_pkg::RDONCE})begin
                         case(init_state)
                           UC:
                           begin
                              if (resp[4] && resp[0]) begin 
                              //was unique and data transfer -- cacheline may be dirty(siltent transition in agent's cache)
                                 end_state = SD;
                                 `uvm_info(`LABEL,$sformatf("Cache state will transition to SD, becauase: snoop response has: WU=0x1 & DT=0x1, meaning cache may have been upgraded from UC to UD(silent) and this snoop is downgrading it to SD"),UVM_NONE+50);
                              end else
                                 end_state = SC;
                           end
                           UD:end_state = SD;
                           SC:end_state = SC;
                           SD:end_state = SD;
                         endcase
                       end
                       if(snp_addr_pkt.acsnoop == <%=_child_blkid[pidx]%>_env_pkg::CLNSHRD)begin
                         end_state = SC; 
                       end
                    end
                    else if(resp[3:0] == 2'b11)begin
                      end_state = SC;
                    end
                    else begin
                      end_state = IX;
                    end
                   end
                   coherency_checker.update_state(.addr(snp_addr_pkt.acaddr),.ns(snp_addr_pkt.acprot[1]),.funit_idx(<%=obj.AiuInfo[pidx].FUnitId%>),.state(end_state));
                end
        endcase
       end
<% } else { %>
     <%=_child_blkid[pidx]%>_smi_agent_pkg::eMsgDTR RxDtrType,TxDtrType;
     <%=_child_blkid[pidx]%>_smi_agent_pkg::eMsgDTW TxDtwType;
     <%=_child_blkid[pidx]%>_smi_agent_pkg::eMsgSNP SnpType;
     <%=_child_blkid[pidx]%>_smi_agent_pkg::smi_seq_item snp_rsp_pkt;
     snp_rsp_pkt = m_pkt;
       
     if(isRd)begin
        $cast(RxDtrType,m_pkt.smi_msg_type);
       `uvm_info(`LABEL,$sformatf("isRd:%0b isWr:%0b isSnp:%0b is_coh :%0b RxDtrType:opcode:%0s excl:%0b funit_id:<%=obj.AiuInfo[pidx].FUnitId%>",isRd,isWr,isSnp,fsys_txn_q.is_coh,RxDtrType.name(),fsys_txn_q.cmd_req_excl_q[idx]),UVM_NONE+50);
     end
     if(isWr)begin
        if(m_pkt !== null && m_pkt.isDtrMsg)begin
          $cast(TxDtrType,m_pkt.smi_msg_type);
          `uvm_info(`LABEL,$sformatf("isRd:%0b isWr:%0b isSnp:%0b is_coh :%0b TxDtrType:opcode:%0s excl:%0b funit_id:<%=obj.AiuInfo[pidx].FUnitId%>",isRd,isWr,isSnp,fsys_txn_q.is_coh,TxDtrType.name(),fsys_txn_q.cmd_req_excl_q[idx]),UVM_NONE+50);
        end
        if(m_pkt !== null && m_pkt.isDtwMsg)begin
          $cast(TxDtwType,m_pkt.smi_msg_type);
          `uvm_info(`LABEL,$sformatf("isRd:%0b isWr:%0b isSnp:%0b is_coh :%0b TxDtwType:opcode:%0s excl:%0b funit_id:<%=obj.AiuInfo[pidx].FUnitId%>",isRd,isWr,isSnp,fsys_txn_q.is_coh,TxDtwType.name(),fsys_txn_q.cmd_req_excl_q[idx]),UVM_NONE+50);
        end
     end
     if(isSnp)begin
         $cast(SnpType,req_pkt.smi_msg_type);
        `uvm_info(`LABEL,$sformatf("isRd:%0b isWr:%0b isSnp:%0b opcode:%0x cmstatus_rv:%0b cmstatus_rs:%0b funit_id:<%=obj.AiuInfo[pidx].FUnitId%>",isRd,isWr,isSnp,SnpType.name(),m_pkt.smi_cmstatus_rv,m_pkt.smi_cmstatus_rs),UVM_NONE+50);
     end
      case({isSnp,isWr,isRd})
       3'b001:  begin
                     case(RxDtrType)
                      DTR_DATA_INV    :end_state = IX;
                      DTR_DATA_UNQ_CLN:end_state = UC;
                      DTR_DATA_SHR_CLN:end_state = SC;
                      DTR_DATA_UNQ_DTY:end_state = UD;
                      DTR_DATA_SHR_DTY:end_state = SD;
                  endcase
                  if(fsys_txn_q.ace_command_type inside {"RDONCE","RDONCEMAKEINVLD","RDONCECLNINVLD","CLNINVL","MKINVL"})begin
                      end_state = IX;
                  end
                  coherency_checker.update_state(.addr(fsys_txn_q.dtr_addr_q[idx]),.ns(fsys_txn_q.cmd_req_ns_q[0]),.funit_idx(<%=obj.AiuInfo[pidx].FUnitId%>),.state(end_state));
                end
       3'b010:begin
                if(m_pkt !== null && m_pkt.isDtrMsg)begin
                     init_state = coherency_checker.get_state(.addr(fsys_txn_q.snpreq_addr_q[idx]),.ns(fsys_txn_q.snpreq_ns_q[idx]),.funit_idx(<%=obj.AiuInfo[pidx].FUnitId%>));
                  case(TxDtrType)   
                     DTR_DATA_INV    : if(fsys_txn_q.smi_snp_msg_type_q[idx] inside {<%=_child_blkid[pidx]%>_smi_agent_pkg::SNP_NITCCI,<%=_child_blkid[pidx]%>_smi_agent_pkg::SNP_NITCMI})  end_state = IX;
                     DTR_DATA_UNQ_CLN:   end_state = IX;
                     DTR_DATA_SHR_CLN:if(init_state inside {SD,UD})begin
                                         end_state = SD;
                                      end
                                      else begin
                                         end_state = SC;
                                      end
                     DTR_DATA_UNQ_DTY:end_state = IX;
                  endcase
                  //IF DTR is outgoing, invalidate the line in sender AIU
                  if (<%=obj.AiuInfo[pidx].FUnitId%> == m_pkt.smi_src_ncore_unit_id) begin
                     end_state = IX;
                  end
                   coherency_checker.update_state(.addr(fsys_txn_q.snpreq_addr_q[idx]),.ns(fsys_txn_q.snpreq_ns_q[idx]),.funit_idx(<%=obj.AiuInfo[pidx].FUnitId%>),.state(end_state),.flush(flush));
                end
                else begin
                   end_state = IX;
                   coherency_checker.update_state(.addr(fsys_txn_q.pcie_mode_smi_addr_q[idx]),.ns(fsys_txn_q.smi_ns),.funit_idx(<%=obj.AiuInfo[pidx].FUnitId%>),.state(end_state),.flush(flush));
                end
              end
       3'b100:begin
               init_state = coherency_checker.get_state(.addr(req_pkt.smi_addr),.ns(req_pkt.smi_ns),.funit_idx(<%=obj.AiuInfo[pidx].FUnitId%>));
               if(m_pkt.smi_cmstatus[7:6] == 2'b00)begin
                 //if(!m_pkt.smi_cmstatus_dt_aiu)begin
                   case({m_pkt.smi_cmstatus_rv,m_pkt.smi_cmstatus_rs})
                     2'b00: end_state = IX;
                     2'b10:
                     begin
                          //This agent is owner, but coh_check doesnt maintain that information
                          if(init_state inside {SD,UD})begin
                            end_state = SD;
                          end else end_state = SC; 
                     end
                     2'b11: begin
                              end_state = SC;
                              //if (m_pkt.smi_cmstatus_dc)
                              //   end_state = IX;
                           end
                   endcase
                 //end
               end 
               coherency_checker.update_state(.addr(req_pkt.smi_addr),.ns(req_pkt.smi_ns),.funit_idx(<%=obj.AiuInfo[pidx].FUnitId%>),.state(end_state));
              end
       endcase
<% } %>
 
endfunction : package_and_send_coh_checker_<%=pidx%>
<% } %>

<% if(obj.AiuInfo[pidx].useCache == 1) {%>
 function void fsys_scb_ioaiu_predictor::smi_snprsp_proxy_cache_<%=pidx%>(input <%=_child_blkid[pidx]%>_smi_agent_pkg::smi_seq_item m_pkt);
   `undef LABEL
   `define LABEL "smi_snprsp_proxy_cache_<%=_child_blkid[pidx]%>"
    int temp_q[$]; 

    temp_q = proxycache_snp_req_q_<%=pidx%>.find_index() with ((item.smi_src_ncore_unit_id == m_pkt.smi_targ_ncore_unit_id) &&
                                                     (item.smi_targ_ncore_unit_id == m_pkt.smi_src_ncore_unit_id) &&
                                                     (item.smi_msg_id == m_pkt.smi_rmsg_id));
    if (temp_q.size() == 1 )begin
      if(proxycache_snp_req_q_<%=pidx%>[temp_q[0]].smi_msg_type !== SNP_DVM_MSG)begin
       `uvm_info(`LABEL,$sformatf(" SnpResp pkt smi_src_ncore_unit_id:%0x smi_rmsg_id :%0x %0s ",m_pkt.smi_src_ncore_unit_id,m_pkt.smi_rmsg_id , m_pkt.convert2string()),UVM_NONE+50);
       if (m_pkt.smi_cmstatus_dt_aiu == 0) begin
         package_and_send_coh_checker_<%=pidx%>(null,proxycache_snp_req_q_<%=pidx%>[temp_q[0]],m_pkt,0,0,1);
       end
       proxycache_snp_req_q_<%=pidx%>.delete(temp_q[0]);
      end
      else begin
       `uvm_info(`LABEL,$sformatf(" DVM_Msg: SnpResp pkt smi_src_ncore_unit_id:%0x smi_rmsg_id :%0x not matching any inflight snp_req funit_id:<%=obj.AiuInfo[pidx].FUnitId%>",m_pkt.smi_src_ncore_unit_id,m_pkt.smi_rmsg_id ),UVM_NONE+50);
       proxycache_snp_req_q_<%=pidx%>.delete(temp_q[0]);
      end
    end
    else begin
       `uvm_error(`LABEL,$sformatf("SnpResp pkt smi_src_ncore_unit_id:%0x smi_rmsg_id :%0x not matching any inflight snp_req funit_id:<%=obj.AiuInfo[pidx].FUnitId%>",m_pkt.smi_src_ncore_unit_id,m_pkt.smi_rmsg_id ));
    end
   
 endfunction:smi_snprsp_proxy_cache_<%=pidx%>
<% } %>
<%for(var i = 0; i < obj.AiuInfo[pidx].nNativeInterfacePorts; i++){%> 
//===================================================================================================
//
//===================================================================================================

function void fsys_scb_ioaiu_predictor::analyze_read_addr_pkt_<%=pidx%>_<%=i%>(input <%=_child_blkid[pidx]%>_env_pkg::axi4_read_addr_pkt_t m_pkt, ref fsys_scb_txn fsys_txn_q[$]);
   int mem_region;
   int gpra_order;
	bit connected = 0;
   `undef LABEL
   `define  LABEL "read_addr_pkt_<%=_child_blkid[pidx]%>_core<%=i%>"
   fsys_scb_txn m_txn = fsys_scb_txn::type_id::create("m_txn");
   <%=_child_blkid[pidx]%>_env_pkg::ace_read_addr_pkt_t m_packet;
   <%=_child_blkid[pidx]%>_env_pkg::ace_read_addr_pkt_t m_packet_tmp;

   m_packet = new();
   m_packet_tmp = new();
   $cast(m_packet_tmp, m_pkt);
   m_packet.copy(m_packet_tmp);
   if (m_packet.print_snoop_type() == "DVMCMPL") begin
      process_dvm_cmpl_<%=pidx%>_<%=i%>(m_packet, fsys_txn_q);
      return;
   end else if (m_packet.print_snoop_type() == "DVMMSG") begin
      if (match_for_dvm_part_2_<%=pidx%>_<%=i%>(m_packet, fsys_txn_q)) begin
         return;
      end
   end
   `uvm_info(`LABEL, $sformatf(
      "New read txn observed. Addr=0x%0h %0s", 
      m_packet.araddr, m_packet.sprint_pkt()), UVM_NONE+50)
   m_txn.fsys_unique_txn_id = fsys_scoreboard::get_next_unique_txn_id();
   m_txn.smi_addr = m_packet.araddr;
   m_txn.smi_addr_val = 1;
   m_txn.source_funit_id = <%=obj.AiuInfo[pidx].FUnitId%>;
   m_txn.m_axi_rd_addr_pkt_<%=pidx%> = new();
   m_txn.m_axi_rd_addr_pkt_<%=pidx%>.copy(m_packet);
   m_txn.ace_command_type = m_packet.print_snoop_type();
   if (m_packet.araddr inside {[addrMgrConst::NRS_REGION_BASE : (addrMgrConst::NRS_REGION_BASE + addrMgrConst::NRS_REGION_SIZE)]}) begin
      `uvm_info(`LABEL, $sformatf(
         "FSYS_UID:%0d : Register access packet.", 
         m_txn.fsys_unique_txn_id), UVM_NONE+50)
      m_txn.register_txn = 1;
   end
   <% if(obj.AiuInfo[pidx].fnNativeInterface == "AXI4" || obj.AiuInfo[pidx].fnNativeInterface == "AXI5") {%>
   m_txn.is_coh = (addrMgrConst::get_addr_gprar_nc(m_packet.araddr) == 1) ? 0 : 1;
   if (m_txn.ace_command_type == "RDNOSNP"
      && m_txn.is_coh == 1) begin // && <%=obj.AiuInfo[pidx].useCache%> == 1) begin
      m_txn.ace_command_type = "RDONCE";
      m_txn.m_axi_rd_addr_pkt_<%=pidx%>.arcache[1] = 1'b1;
   end
   if (m_txn.ace_command_type !== "RDNOSNP"
      && m_txn.is_coh == 0) begin // && <%=obj.AiuInfo[pidx].useCache%> == 1) begin
      m_txn.ace_command_type = "RDNOSNP";
      //m_txn.m_axi_rd_addr_pkt_<%=pidx%>.arcache[1] = 1'b1;
   end
   <%} else {%>
   m_txn.is_coh = (m_packet.ardomain inside {2'b00, 2'b11}) ? 0 : 1;
   <%}%>

   if (m_txn.ace_command_type inside {"RDNOSNP"}) begin
      m_txn.mpf2_flowid_val = 1;
      m_txn.mpf2_flowid = m_packet.arid;
      m_txn.is_coh = 0;
   end else begin
      m_txn.mpf2_flowid_val = m_packet.arlock[0];
      <% if (obj.AiuInfo[pidx].nProcs == 1) { %>
         m_txn.mpf2_flowid = 0;
      <% } else if(obj.AiuInfo[pidx].AxIdProcSelectBits.length > 0) {%>
         m_txn.mpf2_flowid_val = 1;
         <% for(var j = 0; j < obj.AiuInfo[pidx].AxIdProcSelectBits.length; j++) { %>
         m_txn.mpf2_flowid[<%=j%>] = m_packet.arid[<%=obj.AiuInfo[pidx].AxIdProcSelectBits[j]%>];
         <% } %>
      <% } %>   
   end
   `uvm_info(`LABEL, $sformatf(
      "FSYS_UID:%0d : Expected mpf2_flowid_val=%0d, mpf2_flowid=0x%0h", 
      m_txn.fsys_unique_txn_id, m_txn.mpf2_flowid_val, m_txn.mpf2_flowid), UVM_NONE+50)
   if (m_packet.print_snoop_type() == "DVMMSG") begin
      `uvm_info(`LABEL, $sformatf("FSYS_UID:%0d : New DVMMSG transaction. %0s", 
         m_txn.fsys_unique_txn_id, m_packet.sprint_pkt()), UVM_NONE+50)
      if (m_packet.araddr[14:12] == 3'b100) begin
         `uvm_info(`LABEL, $sformatf("FSYS_UID:%0d : This is DVM Sync", 
            m_txn.fsys_unique_txn_id), UVM_NONE+50)
      end
      m_txn.dest_funit_id = <%=obj.DveInfo[0].FUnitId%>;
      m_txn.is_dvm = 1;
      <% if (obj.noDVM) { %>
         `uvm_error(`LABEL, $sformatf(
            "FSYS_UID:%0d : NCore doesn't support DVM txns in noDVM=true config: CONC-15169",  m_txn.fsys_unique_txn_id))
      <% } %>
      m_txn.register_txn = 0;
      foreach (m_txn.dvm_part_2_addr_q[addr_idx])
         m_txn.dvm_part_2_addr_q[addr_idx] = -1;
      if (m_packet.araddr[15] == 1) begin
         m_txn.ac_dvmcmpl_exp = 1;
      end 
      if (m_packet.araddr[0] == 1'b1) m_txn.dvm_part_2_exp = 1;
   end else begin
      m_txn.dest_funit_id = addrMgrConst::map_addr2dmi_or_dii(m_packet.araddr, mem_region);
      m_txn.dce_funit_id = addrMgrConst::map_addr2dce(m_packet.araddr);
   end
   gpra_order = addrMgrConst::get_addr_memorder(m_packet.araddr);
   m_txn.gprar_writeid = gpra_order[2];
   m_txn.gprar_readid = gpra_order[1];
   //CONC-11580
   m_txn.pcie_ordermode_rd_en = 1; //fsys_scoreboard::pcie_ordermode_rd_en_<%=_child_blkid[pidx]%>_core<%=i%>;
   m_txn.pcie_ordermode_wr_en = 1; //fsys_scoreboard::pcie_ordermode_wr_en_<%=_child_blkid[pidx]%>_core<%=i%>;
   m_txn.is_read = 1;
   m_txn.smi_ns = <%if(obj.wSecurityAttribute > 0){%>m_packet.arprot[1]<%}else{%>0<%}%>;
   m_txn.smi_pr = m_packet.arprot[0];
   m_txn.smi_qos = m_packet.arqos;
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
            m_txn.fsys_unique_txn_id, m_txn.dest_funit_id, m_packet.araddr, m_packet.sprint_pkt()))
      end else begin
         `uvm_info(`LABEL, $sformatf(
            "FSYS_UID:%0d : New TXN. Dest: DMI(FunitId:'d%0d). Addr=0x%0h pcie_ordermode_rd_en=%0d, pcie_ordermode_wr_en=%0d %0s",
            m_txn.fsys_unique_txn_id, m_txn.dest_funit_id, m_packet.araddr, 
            m_txn.pcie_ordermode_rd_en, m_txn.pcie_ordermode_wr_en, m_packet.sprint_pkt()), UVM_NONE+50)
      end
   end
   <% } //foreach DMI %>
   <% for(var idx = 0; idx < obj.nDIIs; idx++) { %> 
   if (m_txn.dest_funit_id == <%=obj.DiiInfo[idx].FUnitId%>) begin
      m_txn.dii_bound = 1;
      m_txn.is_coh = 0; // Since this is DII bound, it's non-coh, so CmdReq matches correct targ_id
	   <% if (obj.ConnectivityMap.aiuDiiMap[obj.AiuInfo[pidx].FUnitId]) { %>
	     <% for(var j = 0; j < obj.ConnectivityMap.aiuDiiMap[obj.AiuInfo[pidx].FUnitId].length; j++) { %>
        if (m_txn.dest_funit_id == <%=obj.ConnectivityMap.aiuDiiMap[obj.AiuInfo[pidx].FUnitId][j]%>) connected = 1;
	      <% } //foreach aiuDiiMap %>
	   <% } //if aiuDiiMap[obj.AiuInfo[pidx].FUnitId] %>
      if (connected == 0) begin
         `uvm_error(`LABEL, $sformatf(
            "FSYS_UID:%0d : New TXN to unconnected DII. Dest: DII(FunitId:'d%0d). Addr=0x%0h Packet: %0s",
            m_txn.fsys_unique_txn_id, m_txn.dest_funit_id, m_packet.araddr, m_packet.sprint_pkt()))
      end else begin
         `uvm_info(`LABEL, $sformatf(
            "FSYS_UID:%0d : New TXN. Dest: DII(FunitId:'d%0d). Addr=0x%0h pcie_ordermode_rd_en=%0d, pcie_ordermode_wr_en=%0d %0s", 
            m_txn.fsys_unique_txn_id, m_txn.dest_funit_id, m_packet.araddr, 
            m_txn.pcie_ordermode_rd_en, m_txn.pcie_ordermode_wr_en, m_packet.sprint_pkt()), UVM_NONE+50)
         end
   end
   <% } //foreach DII %>
   
   if (((m_txn.dmi_bound == 1 && m_txn.dii_bound == 1)
         || (m_txn.dmi_bound == 0 && m_txn.dii_bound == 0))
       && m_txn.is_dvm == 0) begin
      `uvm_error(`LABEL, $sformatf(
         "FSYS_UID:%0d : Scoreboard addr map logic error. Addr = 0x%0h was translated wrong. dmi_bound=%0d, dmi_bound=%0d.",
         m_txn.fsys_unique_txn_id, m_packet.araddr, m_txn.dmi_bound, m_txn.dii_bound))
   end // if both DMI and DII flags are set

   m_txn.ioaiu_core_id = <%=i%>;

   if (m_txn.is_dvm == 1) begin
      m_txn.exp_smi_cmd_pkts = 1;
      m_txn.exp_smi_data_pkts = 1;
   end else begin
      m_txn.predict_dtr_count_<%=pidx%>();
   end
   `uvm_info(`LABEL, $sformatf(
      "FSYS_UID:%0d : DCE for this transaction is: 'd%0d(FunitId). multi_cacheline_access=%0s(exp_smi_data_pkts=%0d), last_smi_addr=0x%0h, lower_addr_bound=0x%0h, upper_addr_bound=0x%0h", 
      m_txn.fsys_unique_txn_id, m_txn.dce_funit_id, (m_txn.multi_cacheline_access == 1) ? "yes" : "no", m_txn.exp_smi_data_pkts, 
      m_txn.last_smi_addr, m_txn.m_lower_wrapped_boundary, m_txn.m_upper_wrapped_boundary), UVM_NONE+50)
   //These txns will have AXI read data but no SMI data
   if (m_packet.print_snoop_type() inside {"CLNSHRD", "CLNSHRDPERSIST", "CLNINVL", "MKINVL", "CLNUNQ", "MKUNQ", "BARRIER"}) begin
      m_txn.is_cmo_txn = 1;
      m_txn.exp_smi_data_pkts = 0;
   end // CMO operations
   m_txn.update_time_accessed("ioaiu_rd_addr","<%=_child_blkid[pidx]%>");
   ioaiu_rdtxn_cnt++;
   fsys_txn_q.push_back(m_txn);

endfunction : analyze_read_addr_pkt_<%=pidx%>_<%=i%>

//===================================================================================================
//
//===================================================================================================
function void fsys_scb_ioaiu_predictor::process_dvm_cmpl_<%=pidx%>_<%=i%>(input <%=_child_blkid[pidx]%>_env_pkg::ace_read_addr_pkt_t m_pkt, ref fsys_scb_txn fsys_txn_q[$], input bit ac_pkt = 0);
   `undef LABEL
   `define LABEL "read_addr_pkt_<%=_child_blkid[pidx]%>_core<%=i%>"
   bit match_found = 0;
   foreach (fsys_txn_q[idx]) begin
      if (fsys_txn_q[idx].is_dvm == 1) begin
         foreach (fsys_txn_q[idx].dvm_complete_unit_id_q[j]) begin
            if (fsys_txn_q[idx].dvm_complete_unit_id_q[j] == <%=obj.AiuInfo[pidx].FUnitId%>
                  && fsys_txn_q[idx].dvm_complete_exp > 0 && ac_pkt == 0
            ) begin
               `uvm_info(`LABEL, $sformatf(
                  "FSYS_UID:%0d : DVM Complete seen. %0s", fsys_txn_q[idx].fsys_unique_txn_id, 
                  (ac_pkt == 1) ? "From Originating master" : m_pkt.sprint_pkt()), UVM_NONE+50)
               fsys_txn_q[idx].dvm_complete_exp--;
               fsys_txn_q[idx].dvm_complete_resp_exp++;
               fsys_txn_q[idx].dvm_complete_arid_q.push_back(m_pkt.arid);
               fsys_txn_q[idx].dvm_complete_resp_unit_q.push_back(fsys_txn_q[idx].dvm_complete_unit_id_q[j]);
               fsys_txn_q[idx].dvm_complete_unit_id_q.delete(j);
               fsys_txn_q[idx].update_time_accessed();
               match_found = 1;
               break;
            end // if matched
         end // foreach snpreq_targ_id_q
      end // if DVM
      if (match_found == 1) break;
   end // foreach
   if (match_found == 0) begin
      foreach (fsys_txn_q[idx]) begin
         if (fsys_txn_q[idx].source_funit_id == <%=obj.AiuInfo[pidx].FUnitId%>
            && fsys_txn_q[idx].ac_dvmcmpl_exp == 1 && ac_pkt == 1
         ) begin
            `uvm_info(`LABEL, $sformatf(
                  "FSYS_UID:%0d : DVM Complete seen. %0s", fsys_txn_q[idx].fsys_unique_txn_id, 
                  (ac_pkt == 1) ? "From Originating master" : m_pkt.sprint_pkt()), UVM_NONE+50)
            snoop_order_uid_<%=pidx%>_<%=i%>.push_back(fsys_txn_q[idx].fsys_unique_txn_id);
            snoop_order_snp_idx_<%=pidx%>_<%=i%>.push_back(0);
            fsys_txn_q[idx].ac_dvmcmpl_exp = 0;
            fsys_txn_q[idx].ac_dvmcmpl_resp_exp = 1;
            fsys_txn_q[idx].update_time_accessed();
            match_found = 1;
         end // match found
      end // foreach
      if (match_found == 0) begin
         `uvm_error(`LABEL, $sformatf(
            "FSYS_SCB: DVM Complete didn't match any pending transactions. %0s",
            m_pkt.sprint_pkt()))
      end
   end
endfunction : process_dvm_cmpl_<%=pidx%>_<%=i%>
//===================================================================================================
//
//===================================================================================================
function bit fsys_scb_ioaiu_predictor::match_for_dvm_part_2_<%=pidx%>_<%=i%>(input <%=_child_blkid[pidx]%>_env_pkg::ace_read_addr_pkt_t m_pkt, ref fsys_scb_txn fsys_txn_q[$]);
   `undef LABEL
   `define LABEL "read_addr_pkt_<%=_child_blkid[pidx]%>_core<%=i%>"
   int find_q[$];
   find_q = fsys_txn_q.find_index with (
                  item.source_funit_id == <%=obj.AiuInfo[pidx].FUnitId%>
                  && item.m_axi_rd_addr_pkt_<%=pidx%> !== null
                  && item.is_dvm == 1
                  && item.dvm_part_2_exp == 1 
                  && item.m_axi_rd_addr_pkt_<%=pidx%>.arid == m_pkt.arid
                  && item.ioaiu_core_id == <%=i%>);
   if (find_q.size() >= 1) begin
      `uvm_info(`LABEL, $sformatf(
         "FSYS_UID:%0d : Part-2 DVMMSG seen. %0s", 
         fsys_txn_q[find_q[0]].fsys_unique_txn_id, m_pkt.sprint_pkt()),
         UVM_NONE+50)
      fsys_txn_q[find_q[0]].update_time_accessed();
      //fsys_txn_q[find_q[0]].exp_smi_cmd_pkts++;
      //fsys_txn_q[find_q[0]].exp_smi_data_pkts++;
      fsys_txn_q[find_q[0]].dvm_part_2_exp = 0;
      fsys_txn_q[find_q[0]].dvm_part_2_seen = 1;
      return(1);
   end else begin
      return(0);
   end
endfunction : match_for_dvm_part_2_<%=pidx%>_<%=i%>
//===================================================================================================
//
//===================================================================================================
function void fsys_scb_ioaiu_predictor::analyze_read_data_pkt_<%=pidx%>_<%=i%>(input <%=_child_blkid[pidx]%>_env_pkg::axi4_read_data_pkt_t m_pkt, ref fsys_scb_txn fsys_txn_q[$]);
   `undef LABEL
   `define  LABEL "read_data_pkt_<%=_child_blkid[pidx]%>_core<%=i%>"
   int find_q[$];
   bit dvm_complete_resp = 0;
   bit all_rbr_seen = 1;
   bit all_mrd_seen = 1;
   <%=_child_blkid[pidx]%>_env_pkg::ace_read_data_pkt_t m_packet;
   <%=_child_blkid[pidx]%>_env_pkg::ace_read_data_pkt_t m_packet_tmp;
   m_packet = new();
   m_packet_tmp = new();
   $cast(m_packet_tmp, m_pkt);
   m_packet.copy(m_packet_tmp);
   //foreach(fsys_txn_q[idx]) begin
   //   `uvm_info(`LABEL, $sformatf(
   //   "FSYS_UID:%0d : arid: 0x%0h, rid: 0x%0h, exp_smi_data_pkts='d%0d, core_id=%0d, is_read=%0d", 
   //   fsys_txn_q[idx].fsys_unique_txn_id, fsys_txn_q[idx].m_axi_rd_addr_pkt_<%=pidx%> !== null 
   //   ? fsys_txn_q[idx].m_axi_rd_addr_pkt_<%=pidx%>.arid : 'hffff, m_pkt.rid, 
   //   fsys_txn_q[idx].exp_smi_data_pkts, fsys_txn_q[idx].ioaiu_core_id, fsys_txn_q[idx].is_read), UVM_NONE+50)
   //end
   dvm_complete_resp = process_dvm_cmpl_resp_<%=pidx%>_<%=i%>(m_pkt, fsys_txn_q);
   if (dvm_complete_resp == 1) return;
   find_q = fsys_txn_q.find_index with (
                  item.source_funit_id == <%=obj.AiuInfo[pidx].FUnitId%>
                  && (item.m_axi_rd_addr_pkt_<%=pidx%> !== null || item.is_atomic_txn == 1)
                  && (item.is_read == 1 || (item.is_atomic_txn == 1 && item.ace_command_type !== "ATMSTR"))
                  && (item.is_write == 0 || (item.is_atomic_txn == 1 && item.ace_command_type !== "ATMSTR"))
                  && (item.axi_data_seen == 0 || (item.is_atomic_txn == 1 && item.axi_data_seen == 1 && item.axi_rd_atm_data_seen == 0))
                  //&& (item.exp_smi_data_pkts == 0 || item.exp_smi_data_pkts == 1 || item.register_txn == 1)
                  && (item.exp_smi_data_pkts >= 0 || item.register_txn == 1) 
                  && ((item.m_axi_rd_addr_pkt_<%=pidx%> !== null && item.m_axi_rd_addr_pkt_<%=pidx%>.arid == m_pkt.rid)
                     || (item.is_atomic_txn == 1 && item.ace_command_type !== "ATMSTR"
                        && item.m_axi_wr_addr_pkt_<%=pidx%> !== null && item.m_axi_wr_addr_pkt_<%=pidx%>.awid == m_pkt.rid))
                  && item.ioaiu_core_id == <%=i%>);
   if (find_q.size() >= 1) begin
      `uvm_info(`LABEL, $sformatf(
         "FSYS_UID:%0d : Seen AXI read data. Remaining DTRs = 'd%0d.", 
         fsys_txn_q[find_q[0]].fsys_unique_txn_id, fsys_txn_q[find_q[0]].exp_smi_data_pkts), 
         UVM_NONE+50)

      fsys_txn_q[find_q[0]].update_time_accessed("ioaiu_rd_data","<%=_child_blkid[pidx]%>");
   if (fsys_txn_q[find_q[0]].is_dvm == 1 && (fsys_txn_q[find_q[0]].dvm_part_2_exp == 1 || fsys_txn_q[find_q[0]].dvm_part_2_seen == 1)) begin
         if (fsys_txn_q[find_q[0]].dvm_resp_seen == 0) begin
            fsys_txn_q[find_q[0]].dvm_resp_seen = 1;
         end else begin
            fsys_txn_q[find_q[0]].axi_data_seen = 1;
         end
      end else if (fsys_txn_q[find_q[0]].is_atomic_txn == 1) begin
         fsys_txn_q[find_q[0]].axi_rd_atm_data_seen = 1;
      end else begin
         fsys_txn_q[find_q[0]].axi_data_seen = 1;
      end
      if (fsys_txn_q[find_q[0]].is_dvm == 1 && fsys_txn_q[find_q[0]].axi_data_seen == 1
         && (fsys_txn_q[find_q[0]].is_write == 0 || (fsys_txn_q[find_q[0]].is_write == 1 && fsys_txn_q[find_q[0]].axi_write_resp_seen == 1))
         && fsys_txn_q[find_q[0]].aiu_str_cnt == fsys_txn_q[find_q[0]].str_msg_id_q.size()
         && (((fsys_txn_q[find_q[0]].dvm_part_2_exp == 1 || fsys_txn_q[find_q[0]].dvm_part_2_seen == 1) && fsys_txn_q[find_q[0]].aiu_str_cnt >= 1)
            || (fsys_txn_q[find_q[0]].dvm_part_2_exp == 0 && fsys_txn_q[find_q[0]].dvm_part_2_seen == 0))
         ) begin
         `uvm_info(`LABEL, $sformatf(
            "FSYS_UID:%0d : Setting aiu_check_done", 
            fsys_txn_q[find_q[0]].fsys_unique_txn_id), UVM_NONE+50)
         fsys_txn_q[find_q[0]].aiu_check_done = 1;
         if (fsys_txn_q[find_q[0]].snpreq_cnt_q[0] == 0 && fsys_txn_q[find_q[0]].snpreq_cnt_q[1] == 0
            && fsys_txn_q[find_q[0]].aiu_check_done == 1 
            && fsys_txn_q[find_q[0]].dvm_complete_exp == 0 && fsys_txn_q[find_q[0]].dvm_complete_resp_exp == 0
            && fsys_txn_q[find_q[0]].ac_dvmcmpl_exp == 0 && fsys_txn_q[find_q[0]].ac_dvmcmpl_resp_exp == 0) begin
            //Delete from queue if all pkts related to this DVM txn are done
            check_flags_and_delete_txn(`LABEL, find_q[0], fsys_txn_q, 1, `__LINE__);
            return;
         end
      end
      <% if(obj.AiuInfo[pidx].useCache == 1) {%>
         // If no command message was seen, str_msg_id_q will be empty. This will mean the read data came from proxy cache. 
         // Or if num of CMD Req and num of DTRs match, we have seen DTRs for each CMDReq and okay to delete
         // Transaction has ended, deleted from the queue.
         if ((fsys_txn_q[find_q[0]].str_msg_id_q.size() == 0 
               || (fsys_txn_q[find_q[0]].exp_smi_data_pkts == fsys_txn_q[find_q[0]].exp_smi_cmd_pkts && fsys_txn_q[find_q[0]].exp_smi_cmd_pkts !== 0))
               && fsys_txn_q[find_q[0]].register_txn == 0
               && fsys_txn_q[find_q[0]].aiu_str_cnt == fsys_txn_q[find_q[0]].str_msg_id_q.size()
               && fsys_txn_q[find_q[0]].rbuse_count == fsys_txn_q[find_q[0]].rbrsvd_count
               && ((fsys_txn_q[find_q[0]].dmi_check_done == 1 && fsys_txn_q[find_q[0]].rbrsvd_count > 0) || fsys_txn_q[find_q[0]].rbrsvd_count == 0)) begin
            `uvm_info(`LABEL, $sformatf(
               "FSYS_UID:%0d : All or some of read data was sent from proxy cache. Scoreboard reached this conclusion because not all the CMDReq were observed & useCache is set.", 
               fsys_txn_q[find_q[0]].fsys_unique_txn_id), UVM_NONE+50)
            //MEM_CONSISTENCY
            if(m_en_mem_check) begin
               if (fsys_txn_q[find_q[0]].is_cmo_txn == 0 && fsys_txn_q[find_q[0]].register_txn == 0 && fsys_txn_q[find_q[0]].is_atomic_txn == 0) begin
                  fsys_txn_q[find_q[0]].save_ioaiu_rdtxn_data_<%=pidx%>(m_packet);
                  //TODO: Skip datacheck for dataless txns
                  mem_checker.read_on_native_if(.addr(fsys_txn_q[find_q[0]].ioaiu_cacheline_addr), 
                                          .rdata(fsys_txn_q[find_q[0]].ioaiu_txn_data), 
                                          .byte_en(fsys_txn_q[find_q[0]].ioaiu_byte_en), 
                                          .txn_id(fsys_txn_q[find_q[0]].m_axi_rd_addr_pkt_<%=pidx%>.arid),
                                          .ns(fsys_txn_q[find_q[0]].m_axi_rd_addr_pkt_<%=pidx%>.arprot[1]),
                                          .is_coh(fsys_txn_q[find_q[0]].is_coh),
                                          .is_chi(0),
                                          .funit_id(<%=obj.AiuInfo[pidx].FUnitId%>), 
                                          .core_id(<%=i%>),
                                          .read_issue_time(fsys_txn_q[find_q[0]].m_axi_rd_addr_pkt_<%=pidx%>.t_pkt_seen_on_intf),
                                          .cache_unit((<%=obj.AiuInfo[pidx].useCache%> || fsys_txn_q[find_q[0]].snoop_data_fwded)),
                                          .fsys_txn_q(fsys_txn_q), 
                                          .fsys_index(find_q[0]));
               end
            end
            check_flags_and_delete_txn(`LABEL, find_q[0], fsys_txn_q, 1, `__LINE__);
            return;
         end else if (fsys_txn_q[find_q[0]].dtr_msg_id_q.size() !== 0 && fsys_txn_q[find_q[0]].register_txn == 0 && fsys_txn_q[find_q[0]].aiu_str_cnt == fsys_txn_q[find_q[0]].str_msg_id_q.size()) begin
            fsys_txn_q[find_q[0]].delete_at_dtr = 1;
            //MEM_CONSISTENCY
            if(m_en_mem_check) begin
               if (fsys_txn_q[find_q[0]].is_cmo_txn == 0) begin
                  fsys_txn_q[find_q[0]].save_ioaiu_rdtxn_data_<%=pidx%>(m_packet);
               end
            end
         end
      <% } %>
      if (fsys_txn_q[find_q[0]].exp_smi_data_pkts == 0) begin
         //MEM_CONSISTENCY
         if(m_en_mem_check && <%=obj.AiuInfo[pidx].useCache%> == 0) begin
            if (fsys_txn_q[find_q[0]].is_cmo_txn == 0 && fsys_txn_q[find_q[0]].register_txn == 0 && fsys_txn_q[find_q[0]].is_atomic_txn == 0) begin
               fsys_txn_q[find_q[0]].save_ioaiu_rdtxn_data_<%=pidx%>(m_packet);
               //TODO: Skip datacheck for dataless txns
               mem_checker.read_on_native_if(.addr(fsys_txn_q[find_q[0]].ioaiu_cacheline_addr), 
                                       .rdata(fsys_txn_q[find_q[0]].ioaiu_txn_data), 
                                       .byte_en(fsys_txn_q[find_q[0]].ioaiu_byte_en), 
                                       .txn_id(fsys_txn_q[find_q[0]].m_axi_rd_addr_pkt_<%=pidx%>.arid),
                                       .ns(fsys_txn_q[find_q[0]].m_axi_rd_addr_pkt_<%=pidx%>.arprot[1]),
                                       .is_coh(fsys_txn_q[find_q[0]].is_coh),
                                       .is_chi(0),
                                       .funit_id(<%=obj.AiuInfo[pidx].FUnitId%>), 
                                       .core_id(<%=i%>),
                                       .read_issue_time(fsys_txn_q[find_q[0]].m_axi_rd_addr_pkt_<%=pidx%>.t_pkt_seen_on_intf),
                                       .cache_unit((<%=obj.AiuInfo[pidx].useCache%> || fsys_txn_q[find_q[0]].snoop_data_fwded)),
                                       .fsys_txn_q(fsys_txn_q), 
                                       .fsys_index(find_q[0]));
            end
         end
   <% if((obj.AiuInfo[pidx].fnNativeInterface == 'ACE5')||(obj.AiuInfo[pidx].fnNativeInterface == 'ACE')){ %>
        if(m_en_coh_check) begin
           package_and_send_coh_checker_<%=pidx%>(fsys_txn_q[find_q[0]],null,m_pkt.rresp[1:0],m_pkt.rresp,1,0,0,0);
        end
  <% } %>
      end else begin
         //MEM_CONSISTENCY
         if(m_en_mem_check && <%=obj.AiuInfo[pidx].useCache%> == 0) begin
            if (fsys_txn_q[find_q[0]].is_cmo_txn == 0) begin
               fsys_txn_q[find_q[0]].save_ioaiu_rdtxn_data_<%=pidx%>(m_packet);
            end
         end
      end

      if (fsys_txn_q[find_q[0]].exp_smi_data_pkts == 0 
         && fsys_txn_q[find_q[0]].aiu_str_cnt == fsys_txn_q[find_q[0]].str_msg_id_q.size()
         && fsys_txn_q[find_q[0]].str_msg_id_q.size() > 0) begin
         if (fsys_txn_q[find_q[0]].is_atomic_txn == 0
            || (fsys_txn_q[find_q[0]].is_atomic_txn == 1 && fsys_txn_q[find_q[0]].axi_write_resp_seen == 1)) begin
            `uvm_info(`LABEL, $sformatf(
               "FSYS_UID:%0d : Setting aiu_check_done", 
               fsys_txn_q[find_q[0]].fsys_unique_txn_id), UVM_NONE+50)
            fsys_txn_q[find_q[0]].aiu_check_done = 1;
         end
         if (fsys_txn_q[find_q[0]].dmi_check_done == 0
            && fsys_txn_q[find_q[0]].rbuse_count == fsys_txn_q[find_q[0]].rbrsvd_count) begin
            foreach(fsys_txn_q[find_q[0]].rbrreq_seen_q[idx]) begin
               if(fsys_txn_q[find_q[0]].rbrreq_seen_q[idx] == 0 || fsys_txn_q[find_q[0]].rbrreq_seen_q[idx] > 1) begin
                  all_rbr_seen = all_rbr_seen & 1;
               end else begin
                  all_rbr_seen = 0;
               end
               if (fsys_txn_q[find_q[0]].mrdreq_seen_q[idx] == 0 || fsys_txn_q[find_q[0]].mrdreq_seen_q[idx] == 2) begin
                  all_mrd_seen = all_mrd_seen & 1;
               end else begin
                  all_mrd_seen = 0;
               end
            end // foreach
            if (all_rbr_seen == 1 && all_mrd_seen == 1)
               fsys_txn_q[find_q[0]].dmi_check_done = 1;
         end
      end else begin
         fsys_txn_q[find_q[0]].delete_at_dtr = 1;
      end

       if(!$test$plusargs("print_latency_delay")) if (!check_flags_and_delete_txn(`LABEL, find_q[0], fsys_txn_q, 0, `__LINE__)) begin
         // AIU identification register access. It will end within AIU.
         if (fsys_txn_q[find_q[0]].register_txn == 1 &&
            fsys_txn_q[find_q[0]].m_axi_rd_addr_pkt_<%=pidx%>.araddr[11:0] == 'h0) begin 
            check_flags_and_delete_txn(`LABEL, find_q[0], fsys_txn_q, 1, `__LINE__);
         end
      end
   end else begin
      `uvm_error(`LABEL, $sformatf(
         "FSYS_SCB: AXI read data didn't match any pending transaction. %0s", 
         m_packet.sprint_pkt()))
   end
endfunction : analyze_read_data_pkt_<%=pidx%>_<%=i%>
//===================================================================================================
//
//===================================================================================================
function bit fsys_scb_ioaiu_predictor::process_dvm_cmpl_resp_<%=pidx%>_<%=i%>(input <%=_child_blkid[pidx]%>_env_pkg::axi4_read_data_pkt_t m_pkt, ref fsys_scb_txn fsys_txn_q[$]);
   `undef LABEL
   `define  LABEL "read_data_pkt_<%=_child_blkid[pidx]%>_core<%=i%>"
   bit match_found = 0;
   bit all_snp_resp_seen = 1;
   bit all_ioaiu_snp_resp_seen = 1;
   bit all_chi_snp_resp_seen = 1;
   foreach(fsys_txn_q[idx]) begin
      foreach(fsys_txn_q[idx].dvm_complete_arid_q[i]) begin
         if (fsys_txn_q[idx].is_dvm == 1
            && fsys_txn_q[idx].dvm_complete_resp_exp > 0
            && fsys_txn_q[idx].dvm_complete_arid_q[i] == m_pkt.rid
            && fsys_txn_q[idx].dvm_complete_resp_unit_q[i] == <%=obj.AiuInfo[pidx].FUnitId%>) begin
            `uvm_info(`LABEL, $sformatf(
               "FSYS_UID:%0d : DVM Complete response seen. %0s", 
               fsys_txn_q[idx].fsys_unique_txn_id, m_pkt.sprint_pkt()), UVM_NONE+50)
            fsys_txn_q[idx].dvm_complete_resp_exp--;
            fsys_txn_q[idx].dvm_complete_arid_q.delete(i);
            fsys_txn_q[idx].dvm_complete_resp_unit_q.delete(i);
            foreach(fsys_txn_q[idx].snpreq_cnt_q[snpreq_idx]) begin
               if (fsys_txn_q[idx].snpreq_cnt_q[snpreq_idx] == 0) begin
                  all_snp_resp_seen = (all_snp_resp_seen & 1'b1);
               end else begin
                  all_snp_resp_seen = 0;
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
            if (all_snp_resp_seen == 1 && fsys_txn_q[idx].aiu_check_done == 1 
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
         end // matched
      end // foreach arid
      if (match_found) break;
   end // foreach txn
   return(match_found);
endfunction : process_dvm_cmpl_resp_<%=pidx%>_<%=i%>
//===================================================================================================
//
//===================================================================================================
function void fsys_scb_ioaiu_predictor::analyze_write_addr_pkt_<%=pidx%>_<%=i%>(input <%=_child_blkid[pidx]%>_env_pkg::axi4_write_addr_pkt_t m_pkt, ref fsys_scb_txn fsys_txn_q[$]);
   `undef LABEL
   `define LABEL "write_addr_pkt_<%=_child_blkid[pidx]%>_core<%=i%>"
   int mem_region;
   int gpra_order;
   bit connected = 0;
   bit use_cache = <%=obj.AiuInfo[pidx].useCache%>;
   fsys_scb_txn m_txn = fsys_scb_txn::type_id::create("m_txn");
   <%=_child_blkid[pidx]%>_env_pkg::ace_write_addr_pkt_t m_packet;
   <%=_child_blkid[pidx]%>_env_pkg::ace_write_addr_pkt_t m_packet_tmp;
   int   current_txn_count = fsys_txn_q.size();
   
   m_packet = new();
   m_packet_tmp = new();
   $cast(m_packet_tmp, m_pkt);
   m_packet.copy(m_packet_tmp);

   `uvm_info(`LABEL, $sformatf(
      "New write txn observed. Addr=0x%0h %0s", 
      m_pkt.awaddr, m_packet.sprint_pkt()), UVM_NONE+50)

   m_txn.fsys_unique_txn_id = fsys_scoreboard::get_next_unique_txn_id();
   m_txn.smi_addr = m_packet.awaddr;
   m_txn.smi_addr_val = 1;
   m_txn.source_funit_id = <%=obj.AiuInfo[pidx].FUnitId%>;
   m_txn.m_axi_wr_addr_pkt_<%=pidx%> = new();
   m_txn.m_axi_wr_addr_pkt_<%=pidx%>.copy(m_packet);
   if (m_packet.awatop !== 0 && m_packet.awsnoop == 0) begin
      case(m_packet.awatop[5:3])
	      'b010,'b011 : m_txn.ace_command_type = "ATMSTR";
	      'b100,'b111 : m_txn.ace_command_type = "ATMLD";
	      'b110       : begin
	         case(m_packet.awatop[2:0])
		         'b000       : m_txn.ace_command_type = "ATMSWAP";		 
		         'b001       : m_txn.ace_command_type = "ATMCOMPARE";
               default             : `uvm_info(`LABEL, $sformatf("Undefined AWATOP 0x%0b Addr:0x%0x", m_packet.awatop,m_packet.awaddr),UVM_NONE+50)
	         endcase // case (awatop[2:0])
	      end
         default             : `uvm_info(`LABEL, $sformatf("Undefined AWATOP 0x%0b Addr:0x%0x", m_packet.awatop,m_packet.awaddr),UVM_NONE+50)
	  endcase
   end else begin
      m_txn.ace_command_type = m_packet.print_snoop_type();
   end
   if (m_txn.ace_command_type inside {"ATMSTR", "ATMLD", "ATMSWAP", "ATMCOMPARE"}) begin
      m_txn.is_atomic_txn = 1;
   end
   if (m_packet.awaddr inside {[addrMgrConst::NRS_REGION_BASE : (addrMgrConst::NRS_REGION_BASE + addrMgrConst::NRS_REGION_SIZE)]}) begin
      `uvm_info(`LABEL, $sformatf(
         "FSYS_UID:%0d : Register access packet.", 
         m_txn.fsys_unique_txn_id), UVM_NONE+50)
      m_txn.register_txn = 1;
   end
   <% if(obj.AiuInfo[pidx].fnNativeInterface == "AXI4" || obj.AiuInfo[pidx].fnNativeInterface == "AXI5") {%>
   m_txn.is_coh = (addrMgrConst::get_addr_gprar_nc(m_packet.awaddr) == 1) ? 0 : 1;
   <%} else {%>
   m_txn.is_coh = (m_packet.awdomain inside {2'b00, 2'b11}) ? 0 : 1;
   <%}%>
   m_txn.dest_funit_id = addrMgrConst::map_addr2dmi_or_dii(m_packet.awaddr, mem_region);
   m_txn.dce_funit_id = addrMgrConst::map_addr2dce(m_packet.awaddr);
   gpra_order = addrMgrConst::get_addr_memorder(m_packet.awaddr);
   m_txn.gprar_writeid = gpra_order[2];
   m_txn.gprar_readid = gpra_order[1];
   //CONC-11580
   m_txn.pcie_ordermode_rd_en = 1; //fsys_scoreboard::pcie_ordermode_rd_en_<%=_child_blkid[pidx]%>_core<%=i%>;
   m_txn.pcie_ordermode_wr_en = 1; //fsys_scoreboard::pcie_ordermode_wr_en_<%=_child_blkid[pidx]%>_core<%=i%>;
   m_txn.is_write = 1;
   m_txn.smi_ns = <%if(obj.wSecurityAttribute > 0){%>m_packet.awprot[1]<%}else{%>0<%}%>;
   m_txn.smi_pr = m_packet.awprot[0];
   m_txn.smi_qos = m_packet.awqos;
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
            m_txn.fsys_unique_txn_id, m_txn.dest_funit_id, m_packet.awaddr, m_packet.sprint_pkt()))
      end else begin
         `uvm_info(`LABEL, $sformatf(
            "FSYS_UID:%0d : New TXN: %0s. Dest: DMI(FuniId:'d%0d). Addr=0x%0h pcie_ordermode_rd_en=%0d, pcie_ordermode_wr_en=%0d %0s",
            m_txn.fsys_unique_txn_id, m_txn.ace_command_type, m_txn.dest_funit_id, m_packet.awaddr,
            m_txn.pcie_ordermode_rd_en, m_txn.pcie_ordermode_wr_en, m_packet.sprint_pkt()), UVM_NONE+50)
      end
   end
   <% } //foreach DMI %>
   <% for(var idx = 0; idx < obj.nDIIs; idx++) { %> 
   if (m_txn.dest_funit_id == <%=obj.DiiInfo[idx].FUnitId%>) begin
      m_txn.dii_bound = 1;
      m_txn.is_coh = 0; // Since this is DII bound, it's non-coh, so CmdReq matches correct targ_id
	   <% if (obj.ConnectivityMap.aiuDiiMap[obj.AiuInfo[pidx].FUnitId]) { %>
	      <% for(var j = 0; j < obj.ConnectivityMap.aiuDiiMap[obj.AiuInfo[pidx].FUnitId].length; j++) { %>
         if (m_txn.dest_funit_id == <%=obj.ConnectivityMap.aiuDiiMap[obj.AiuInfo[pidx].FUnitId][j]%>) connected = 1;
	      <% } //foreach aiuDiiMap %>
	   <% } //if aiuDiiMap[obj.AiuInfo[pidx].FUnitId] %>
      if (connected == 0) begin
         `uvm_error(`LABEL, $sformatf(
            "FSYS_UID:%0d : New TXN to unconnected DII. Dest: DII(FunitId:'d%0d). Addr=0x%0h Packet: %0s",
            m_txn.fsys_unique_txn_id, m_txn.dest_funit_id, m_packet.awaddr, m_packet.sprint_pkt()))
      end else begin
         `uvm_info(`LABEL, $sformatf(
            "FSYS_UID:%0d : New TXN: %0s. Dest: DII(FuniId:'d%0d). Addr=0x%0h pcie_ordermode_rd_en=%0d, pcie_ordermode_wr_en=%0d %0s", 
            m_txn.fsys_unique_txn_id, m_txn.ace_command_type, m_txn.dest_funit_id, m_packet.awaddr, 
            m_txn.pcie_ordermode_rd_en, m_txn.pcie_ordermode_wr_en, m_packet.sprint_pkt()), UVM_NONE+50)
      end
   end
   <% } //foreach DII %>
   if ((m_txn.dmi_bound == 1 && m_txn.dii_bound == 1)
       || (m_txn.dmi_bound == 0 && m_txn.dii_bound == 0)) begin
      `uvm_error(`LABEL, $sformatf(
         "FSYS_UID:%0d : Scoreboard addr map logic error. Addr = 0x%0h was translated wrong. dmi_bound=%0d, dmi_bound=%0d.", 
         m_txn.fsys_unique_txn_id, m_packet.awaddr, m_txn.dmi_bound, m_txn.dii_bound))
   end // if both DMI and DII flags are set

   m_txn.ioaiu_core_id = <%=i%>;
   if (m_txn.ace_command_type inside {"WRUNQPTLSTASH", "WRUNQFULLSTASH", "STASHONCESHARED", "STASHONCEUNQ"}) begin
      m_txn.is_stash_txn = 1;
   end // Stash txns
   if (m_txn.ace_command_type == "WRNOSNP"
      && m_txn.is_coh == 1) begin // && <%=obj.AiuInfo[pidx].useCache%> == 1) begin
      m_txn.ace_command_type = "WRUNQ";
      m_txn.m_axi_wr_addr_pkt_<%=pidx%>.awcache[1] = 1'b1;
   end
   if (m_txn.ace_command_type !== "WRNOSNP"
      && m_txn.is_atomic_txn == 0
      && m_txn.is_coh == 0) begin // && <%=obj.AiuInfo[pidx].useCache%> == 1) begin
      m_txn.ace_command_type = "WRNOSNP";
      m_txn.m_axi_wr_addr_pkt_<%=pidx%>.awcache[1] = 1'b1;
   end
   if (m_txn.ace_command_type inside {"WRNOSNP"}) begin
      m_txn.mpf2_flowid_val = 1;
      m_txn.mpf2_flowid = m_packet.awid;
      m_txn.is_coh = 0;
   end else begin
     m_txn.mpf2_flowid_val = m_packet.awlock[0];
     if (m_txn.is_stash_txn) m_txn.mpf2_flowid_val = 1;
      <% if (obj.AiuInfo[pidx].nProcs == 1) { %>
         m_txn.mpf2_flowid = 0;
      <% } else if(obj.AiuInfo[pidx].AxIdProcSelectBits.length > 0) {%>
         m_txn.mpf2_flowid_val = 1;
         <% for(var j = 0; j < obj.AiuInfo[pidx].AxIdProcSelectBits.length; j++) { %>
         m_txn.mpf2_flowid[<%=j%>] = m_packet.awid[<%=obj.AiuInfo[pidx].AxIdProcSelectBits[j]%>];
         <% } %>
      <% } %>
   end
   `uvm_info(`LABEL, $sformatf(
      "FSYS_UID:%0d : Expected mpf2_flowid_val=%0d, mpf2_flowid=0x%0h", 
      m_txn.fsys_unique_txn_id, m_txn.mpf2_flowid_val, m_txn.mpf2_flowid), UVM_NONE+50)
   if (m_txn.ace_command_type inside {"WRUNQ", "WRLNUNQ"}) begin
      `uvm_info(`LABEL, $sformatf(
         "FSYS_UID:%0d : This is WRUNQ/WRLNUNQ/WRNOSNP transaction. It could be seen as eCmdRdUnq/eCmdWrUnqFull/eCmdMkUnq on the SMI interface, based on proxy cache status and allocation policy", 
         m_txn.fsys_unique_txn_id), UVM_NONE+50)
      m_txn.m_axi_rd_addr_pkt_<%=pidx%> = new();
      m_txn.m_axi_rd_addr_pkt_<%=pidx%>.araddr = m_packet.awaddr;
      m_txn.m_axi_rd_addr_pkt_<%=pidx%>.arprot = m_packet.awprot;
      m_txn.m_axi_rd_addr_pkt_<%=pidx%>.arburst = m_packet.awburst;
      //Whole filed copy doesnt work since they are enum types. However, we only need bit 1
      m_txn.m_axi_rd_addr_pkt_<%=pidx%>.arcache[1] = m_packet.awcache[1];
      m_txn.is_read = 1;
   end // Write Uniques
   //calculate expected DTWs
   m_txn.predict_dtw_count_<%=pidx%>();
   if (m_txn.ace_command_type inside {"STASHONCESHARED", "STASHONCEUNQ", "EVCT"}) begin
      m_txn.is_write = 0;
      m_txn.is_dataless_txn = 1;
      if (m_txn.ace_command_type == "EVCT") m_txn.exp_smi_data_pkts = 0;
   end // Stash txns
   if (tmp_data_pkt_<%=pidx%>_<%=i%>.size() > 0 && m_txn.is_write == 1) begin
      `uvm_info(`LABEL, $sformatf(
         "FSYS_UID:%0d : Seen AXI write data(To a previously saved data packet). Setting AIU check done flag. %0s",
         m_txn.fsys_unique_txn_id, tmp_data_pkt_<%=pidx%>_<%=i%>[0].sprint_pkt()), UVM_NONE+50)
      m_txn.axi_data_seen = 1;
      //MEM_CONSISTENCY
      if(m_en_mem_check) begin
         m_txn.save_ioaiu_wrtxn_data_<%=pidx%>(tmp_data_pkt_<%=pidx%>_<%=i%>[0]);
         if (m_txn.register_txn == 0) begin
            mem_checker.write_on_native_if(.addr(m_txn.ioaiu_cacheline_addr), 
                                     .wdata(m_txn.ioaiu_txn_data), 
                                     .byte_en(m_txn.ioaiu_byte_en), 
                                     .txn_id(m_packet.awid),
                                     .ns(m_packet.awprot[1]),
                                     .is_coh(m_txn.is_coh),
                                     .is_chi(0),
                                     .funit_id(<%=obj.AiuInfo[pidx].FUnitId%>), 
                                     .core_id(<%=i%>),
                                     .fsys_txn_q(fsys_txn_q), 
                                     .fsys_index(current_txn_count),
                                     .cached(use_cache));
         end
      end

      if (m_txn.is_read == 1) begin
         m_txn.delete_at_dtr = 1;
         `uvm_info(`LABEL, $sformatf(
            "FSYS_UID:%0d : Un-setting aiu_check_done", 
            m_txn.fsys_unique_txn_id), UVM_NONE+50)
         m_txn.aiu_check_done = 0;
      end
      tmp_data_pkt_<%=pidx%>_<%=i%>.delete(0);
   end // if data packet is already seen
   `uvm_info(`LABEL, $sformatf(
      "FSYS_UID:%0d : DCE for this transaction is: 'd%0d(FunitId). multi_cacheline_access=%0s(exp_smi_data_pkts=%0d), last_smi_addr=0x%0h, lower_addr_bound=0x%0h, upper_addr_bound=0x%0h", 
      m_txn.fsys_unique_txn_id, m_txn.dce_funit_id, (m_txn.multi_cacheline_access == 1) ? "yes" : "no", 
      m_txn.exp_smi_data_pkts, m_txn.last_smi_addr, m_txn.m_lower_wrapped_boundary, m_txn.m_upper_wrapped_boundary), UVM_NONE+50)
   //TODO: Why is there no UpdReq for WRCLN?
   if (m_txn.ace_command_type == "WRCLN") begin
      m_txn.is_coh = 0;
      m_txn.mpf2_flowid_val = 1;
      m_txn.mpf2_flowid = m_packet.awid;
   end
   //TODO: Add UpdReq monitoring in DCE for these txns
   if (m_txn.ace_command_type inside {"WRBK"/*, "WRCLN"*/, "WREVCT", "EVCT"}) begin
      m_txn.is_coh = 0;
      m_txn.mpf2_flowid_val = 1;
      m_txn.mpf2_flowid = m_packet.awid;
      m_txn.delete_at_dce = 1;
      m_txn.updreq_req_addr = m_packet.awaddr;
   <% if((obj.AiuInfo[pidx].fnNativeInterface == 'ACE')||(obj.AiuInfo[pidx].fnNativeInterface == 'ACE5')){ %>
      m_txn.ace_if = 1;
   <%}%>
   `uvm_info(`LABEL, $sformatf(
      "FSYS_UID:%0d : Expected mpf2_flowid_val=%0d, mpf2_flowid=0x%0h", 
      m_txn.fsys_unique_txn_id, m_txn.mpf2_flowid_val, m_txn.mpf2_flowid), UVM_NONE+50)
   end // WriteBack operations
   if (m_txn.ace_command_type inside {"BARRIER"}) begin
      m_txn.exp_smi_data_pkts = 0;
   end
   if (m_txn.ace_command_type inside {"ATMSTR", "ATMLD", "ATMSWAP", "ATMCOMPARE"}) begin
      m_txn.is_atomic_txn = 1;
      m_txn.exp_smi_data_pkts = (m_txn.ace_command_type == "ATMSTR") ? 1 : 2;
      m_txn.exp_smi_cmd_pkts = 2;
      //MEM_CONSISTENCY
      if(m_en_mem_check) begin
         mem_checker.atomic_on_native_if(.addr({(m_packet.awaddr >> addrMgrConst::WCACHE_OFFSET), <%=obj.wCacheLineOffset%>'b0})); 
      end // if m_en_mem_check
   end // Atomics
   m_txn.update_time_accessed("ioaiu_wr_addr","<%=_child_blkid[pidx]%>");
   ioaiu_wrtxn_cnt++;
   fsys_txn_q.push_back(m_txn);

endfunction : analyze_write_addr_pkt_<%=pidx%>_<%=i%>

//===================================================================================================
//
//===================================================================================================
function void fsys_scb_ioaiu_predictor::analyze_write_data_pkt_<%=pidx%>_<%=i%>(input <%=_child_blkid[pidx]%>_env_pkg::axi4_write_data_pkt_t m_pkt, ref fsys_scb_txn fsys_txn_q[$]);
   `undef LABEL
   `define LABEL "write_data_pkt_<%=_child_blkid[pidx]%>_core<%=i%>"
   int find_q[$];
   <%=_child_blkid[pidx]%>_env_pkg::ace_write_data_pkt_t m_packet;
   <%=_child_blkid[pidx]%>_env_pkg::ace_write_data_pkt_t m_packet_tmp;
   bit use_cache = <%=obj.AiuInfo[pidx].useCache%>;
   m_packet = new();
   m_packet_tmp = new();
   $cast(m_packet_tmp, m_pkt);
   m_packet.copy(m_packet_tmp);
   `uvm_info(`LABEL, $sformatf("FSYS_SCB: Seen AXI write data, trying to match with pending txns."), UVM_NONE+50)
   find_q = fsys_txn_q.find_index with (
                  (item.source_funit_id == <%=obj.AiuInfo[pidx].FUnitId%>)
                  && (item.m_axi_wr_addr_pkt_<%=pidx%> !== null
                  && (item.is_write == 1 || item.is_atomic_txn == 1)
                  && item.axi_data_seen == 0
                  && item.aiu_check_done == 0
                  && item.ioaiu_core_id == <%=i%>));
   if (find_q.size() >= 1) begin
      `uvm_info(`LABEL, $sformatf(
      "FSYS_UID:%0d : Seen AXI write data.", 
      fsys_txn_q[find_q[0]].fsys_unique_txn_id), UVM_NONE+50)
      fsys_txn_q[find_q[0]].update_time_accessed("ioaiu_wr_data","<%=_child_blkid[pidx]%>");
      //Set this flag when DTWs are seen(Currently DTWs are not being monitored at IOAIU predictor(Not YEt Implemented)
      if (fsys_txn_q[find_q[0]].is_write == 0 || (fsys_txn_q[find_q[0]].is_write == 1 && fsys_txn_q[find_q[0]].axi_write_resp_seen == 1)) begin
         `uvm_info(`LABEL, $sformatf(
            "FSYS_UID:%0d : Setting AIU check done flag.", 
            fsys_txn_q[find_q[0]].fsys_unique_txn_id), UVM_NONE+50)
         fsys_txn_q[find_q[0]].aiu_check_done = 1;
      end
      fsys_txn_q[find_q[0]].axi_data_seen = 1;

      //MEM_CONSISTENCY
      if(m_en_mem_check) begin
         fsys_txn_q[find_q[0]].save_ioaiu_wrtxn_data_<%=pidx%>(m_packet);
         if (fsys_txn_q[find_q[0]].register_txn == 0) begin
            mem_checker.write_on_native_if(.addr(fsys_txn_q[find_q[0]].ioaiu_cacheline_addr), 
                                     .wdata(fsys_txn_q[find_q[0]].ioaiu_txn_data), 
                                     .byte_en(fsys_txn_q[find_q[0]].ioaiu_byte_en), 
                                     .txn_id(fsys_txn_q[find_q[0]].m_axi_wr_addr_pkt_<%=pidx%>.awid),
                                     .ns(fsys_txn_q[find_q[0]].m_axi_wr_addr_pkt_<%=pidx%>.awprot[1]),
                                     .is_coh(fsys_txn_q[find_q[0]].is_coh),
                                     .is_chi(0),
                                     .funit_id(<%=obj.AiuInfo[pidx].FUnitId%>), 
                                     .core_id(<%=i%>),
                                     .fsys_txn_q(fsys_txn_q), 
                                     .fsys_index(find_q[0]),
                                     .cached(use_cache));
         end
      end

      if (fsys_txn_q[find_q[0]].is_read == 1 && fsys_txn_q[find_q[0]].exp_smi_data_pkts == 0 
         && (fsys_txn_q[find_q[0]].is_write == 0 || (fsys_txn_q[find_q[0]].is_write == 1 && fsys_txn_q[find_q[0]].axi_write_resp_seen == 1))
         && fsys_txn_q[find_q[0]].aiu_str_cnt == fsys_txn_q[find_q[0]].str_msg_id_q.size()) begin
         fsys_txn_q[find_q[0]].delete_at_aiu = 1; // To activate below delete() condition
      end else if (fsys_txn_q[find_q[0]].is_read == 1) begin
         fsys_txn_q[find_q[0]].delete_at_dtr = 1;
         `uvm_info(`LABEL, $sformatf("FSYS_UID:%0d : Un-setting aiu_check_done", 
            fsys_txn_q[find_q[0]].fsys_unique_txn_id), UVM_NONE+50)
         fsys_txn_q[find_q[0]].aiu_check_done = 0;
      end
      if (fsys_txn_q[find_q[0]].is_stash_txn == 1) begin
         `uvm_info(`LABEL, $sformatf("FSYS_UID:%0d : Un-setting aiu_check_done", 
            fsys_txn_q[find_q[0]].fsys_unique_txn_id), UVM_NONE+50)
         fsys_txn_q[find_q[0]].aiu_check_done = 0;
      end
      if (fsys_txn_q[find_q[0]].is_atomic_txn == 1) begin
         `uvm_info(`LABEL, $sformatf("FSYS_UID:%0d : Un-setting aiu_check_done", 
            fsys_txn_q[find_q[0]].fsys_unique_txn_id), UVM_NONE+50)
         fsys_txn_q[find_q[0]].aiu_check_done = 0;
      end

      if(!$test$plusargs("print_latency_delay")) if (fsys_txn_q[find_q[0]].delete_at_aiu == 1 && fsys_txn_q[find_q[0]].axi_write_resp_seen == 1) begin
          check_flags_and_delete_txn(`LABEL, find_q[0], fsys_txn_q, 1, `__LINE__);
       end
   end else begin
      tmp_data_pkt_<%=pidx%>_<%=i%>.push_back(m_packet);
      `uvm_info(`LABEL, $sformatf(
         "AXI WData before WAddr. Saving this wdata packet to be matched to a later addr packet. %0s", 
         m_packet.sprint_pkt()), UVM_NONE+50)
   end
endfunction : analyze_write_data_pkt_<%=pidx%>_<%=i%>

//===================================================================================================
//
//===================================================================================================
function void fsys_scb_ioaiu_predictor::analyze_write_resp_pkt_<%=pidx%>_<%=i%>(input <%=_child_blkid[pidx]%>_env_pkg::axi4_write_resp_pkt_t m_pkt, ref fsys_scb_txn fsys_txn_q[$]);
   `undef LABEL
   `define  LABEL "write_resp_pkt_<%=_child_blkid[pidx]%>_core<%=i%>"
   int find_q[$];
   bit use_cache = <%=obj.AiuInfo[pidx].useCache%>;

   //foreach (fsys_txn_q[idx]) begin
   //   if (this.get_report_verbosity_level() === UVM_DEBUG) begin
   //      fsys_txn_q[find_q[idx]].print_me();
   //   end
   //end

   find_q = fsys_txn_q.find_index with (
                  (item.source_funit_id == <%=obj.AiuInfo[pidx].FUnitId%>)
                  && (item.m_axi_wr_addr_pkt_<%=pidx%> !== null
                  && (item.is_read == 0 || item.ace_command_type inside {"WRUNQ", "WRLNUNQ"})
                  && (item.is_write == 1 || item.is_stash_txn == 1 || item.ace_command_type == "EVCT")
                  && item.axi_write_resp_seen == 0
                  && item.m_axi_wr_addr_pkt_<%=pidx%>.awid == m_pkt.bid
                  && item.ioaiu_core_id == <%=i%>));
   if (find_q.size() >= 1) begin
      `uvm_info(`LABEL, $sformatf(
        "FSYS_UID:%0d : Seen AXI write resp. Printing pkt. %0s.", 
         fsys_txn_q[find_q[0]].fsys_unique_txn_id, m_pkt.sprint_pkt()), 
         UVM_NONE+50)
      fsys_txn_q[find_q[0]].update_time_accessed("ioaiu_wr_resp","<%=_child_blkid[pidx]%>");
      //MEM_CONSISTENCY
      if(m_en_mem_check) begin
         if (fsys_txn_q[find_q[0]].register_txn == 0) begin
            mem_checker.bresp_on_native_if(.addr(fsys_txn_q[find_q[0]].ioaiu_cacheline_addr), 
                                        .txn_id(fsys_txn_q[find_q[0]].m_axi_wr_addr_pkt_<%=pidx%>.awid),
                                        .ns(fsys_txn_q[find_q[0]].m_axi_wr_addr_pkt_<%=pidx%>.awprot[1]),
                                        .is_coh(fsys_txn_q[find_q[0]].is_coh),
                                        .funit_id(<%=obj.AiuInfo[pidx].FUnitId%>), 
                                        .core_id(<%=i%>),
                                        .cached((fsys_txn_q[find_q[0]].exp_smi_data_pkts == 0 ? 0 : 1)),
                                        .fsys_txn_q(fsys_txn_q), 
                                        .fsys_index(find_q[0]));
         end
      end
      //fsys_txn_q[find_q[0]].update_time_accessed();
      //fsys_txn_q[find_q[0]].axi_data_seen = 1;
      fsys_txn_q[find_q[0]].axi_write_resp_seen = 1;
      if ((fsys_txn_q[find_q[0]].exp_smi_data_pkts == 0 || (fsys_txn_q[find_q[0]].str_msg_id_q.size() == 0 && use_cache == 1))
         && (fsys_txn_q[find_q[0]].axi_data_seen == 1 || fsys_txn_q[find_q[0]].is_dataless_txn == 1)
         && fsys_txn_q[find_q[0]].aiu_str_cnt == fsys_txn_q[find_q[0]].str_msg_id_q.size()
         && (fsys_txn_q[find_q[0]].dtr_msg_id_q.size() == 0 || (fsys_txn_q[find_q[0]].is_stash_txn == 1 && fsys_txn_q[find_q[0]].stash_accept == 1))
         && (fsys_txn_q[find_q[0]].is_stash_txn == 0 || (fsys_txn_q[find_q[0]].is_stash_txn == 1 && fsys_txn_q[find_q[0]].compack_dbid_val == 0 && fsys_txn_q[find_q[0]].exp_chi_data_flits == 0))) begin
         if (fsys_txn_q[find_q[0]].is_atomic_txn == 1 
            && fsys_txn_q[find_q[0]].ace_command_type !== "ATMSTR" 
            && fsys_txn_q[find_q[0]].axi_rd_atm_data_seen == 0) begin
               // do nothing
         end else begin
            `uvm_info(`LABEL, $sformatf(
               "FSYS_UID:%0d : Setting aiu_check_done", 
               fsys_txn_q[find_q[0]].fsys_unique_txn_id), UVM_NONE+50)
            fsys_txn_q[find_q[0]].aiu_check_done = 1;
         end
      end

      //`uvm_info(`LABEL, $sformatf("aiu_check_done:%0d dce_check_done:%0d dmi_check_done:%0d dii_check_done:%0d", fsys_txn_q[find_q[0]].aiu_check_done, fsys_txn_q[find_q[0]].dce_check_done, fsys_txn_q[find_q[0]].dmi_check_done, fsys_txn_q[find_q[0]].dii_check_done), UVM_NONE+50);
      if (fsys_txn_q[find_q[0]].dmi_check_done == 0
         && fsys_txn_q[find_q[0]].is_stash_txn == 1
         && fsys_txn_q[find_q[0]].stash_accept == 0
         && fsys_txn_q[find_q[0]].mrdreq_seen_q[0] == 0) begin
         fsys_txn_q[find_q[0]].only_mrd_pref_possible = 1;
      end
      if (((fsys_txn_q[find_q[0]].dmi_bound == 1 && fsys_txn_q[find_q[0]].dmi_check_done == 1)
            || (fsys_txn_q[find_q[0]].dii_bound == 1 && fsys_txn_q[find_q[0]].dii_check_done == 1))
          && (fsys_txn_q[find_q[0]].dce_check_done == 1 || fsys_txn_q[find_q[0]].is_coh == 0)
          && ((fsys_txn_q[find_q[0]].delete_at_dce == 1 && fsys_txn_q[find_q[0]].dce_check_done == 1) || (fsys_txn_q[find_q[0]].delete_at_dce == 0))
          && (fsys_txn_q[find_q[0]].aiu_check_done == 1)) begin
         `uvm_info(`LABEL, $sformatf(
            "FSYS_UID:%0d : Deleting transaction from fsys_txn_q. Remaining txns: 'd%0d", 
            fsys_txn_q[find_q[0]].fsys_unique_txn_id, (fsys_txn_q.size()-1)), UVM_NONE+50)
         `ifdef FSYS_SCB_COVER_ON
            fsys_txn_path_cov.sample_txn(fsys_txn_q[find_q[0]].smi_msg_order_q, (fsys_txn_q[find_q[0]].ioaiu_core_id >= 0));
         `endif // `ifdef FSYS_SCB_COVER_ON
         fsys_txn_q[find_q[0]].print_path();
         if(!$test$plusargs("print_latency_delay"))fsys_txn_q.delete(find_q[0]);
      end
   end else begin
      `uvm_error(`LABEL, $sformatf(
         "FSYS_SCB: AXI write resp didn't match any pending transaction. %0s", 
         m_pkt.sprint_pkt()))

   end
endfunction : analyze_write_resp_pkt_<%=pidx%>_<%=i%>

<% if(obj.AiuInfo[pidx].fnNativeInterface == "ACE5" ||obj.AiuInfo[pidx].fnNativeInterface == "ACE" || obj.AiuInfo[pidx].fnNativeInterface == "ACELITE-E" || obj.AiuInfo[pidx].fnNativeInterface == "ACE-LITE"){ %>
//===================================================================================================
//
//===================================================================================================
function void fsys_scb_ioaiu_predictor::analyze_snoop_addr_pkt_<%=pidx%>_<%=i%>(<%=_child_blkid[pidx]%>_env_pkg::ace_snoop_addr_pkt_t m_pkt, ref fsys_scb_txn fsys_txn_q[$]);
   `undef LABEL
   `define LABEL "snoop_addr_pkt_<%=_child_blkid[pidx]%>_core<%=i%>"
   bit match_found = 0;
   int find_q[$];
   int cmd_idx;
   int snp_idx;
   <%=_child_blkid[pidx]%>_env_pkg::ace_read_addr_pkt_t m_packet;
   <%=_child_blkid[pidx]%>_env_pkg::ace_snoop_addr_pkt_t tmp_pkt;

   tmp_pkt = new();
   tmp_pkt.copy(m_pkt);
   m_packet = new();
   m_packet.copy(m_pkt);
   <% if(obj.AiuInfo[pidx].fnNativeInterface == "ACE5"||obj.AiuInfo[pidx].fnNativeInterface == "ACE"){ %>
   ace_snp_req_q_<%=pidx%>.push_back(tmp_pkt);
   <% } %>
   if (m_pkt.print_snoop_type() == "DVMCMPL") begin
      process_dvm_cmpl_<%=pidx%>_<%=i%>(m_packet, fsys_txn_q, 1);
      return;
   end else if (m_pkt.print_snoop_type() inside {"DVMMSG"}) begin
      process_dvm_snp_<%=pidx%>_<%=i%>(m_pkt, fsys_txn_q);
      return;
   end
   //First delete all non-existing UIDs
   for(int idx = smi_snpreq_order_uid_<%=pidx%>.size()-1; idx >=0; idx--) begin
      find_q = fsys_txn_q.find_index with (item.fsys_unique_txn_id == smi_snpreq_order_uid_<%=pidx%>[idx]);
      if (find_q.size() == 0) begin
         smi_snpreq_order_uid_<%=pidx%>.delete(idx);
         smi_snpreq_order_idx_<%=pidx%>.delete(idx);
         smi_snpreq_order_idx2_<%=pidx%>.delete(idx);
      end
   end
   find_q.delete();

   foreach (smi_snpreq_order_uid_<%=pidx%>[idx]) begin
      find_q = fsys_txn_q.find_index with (item.fsys_unique_txn_id == smi_snpreq_order_uid_<%=pidx%>[idx]);
      if (find_q.size() == 1) begin
         `uvm_info(`LABEL, $sformatf("Checking for a match with FSYS_UID:%0d ", fsys_txn_q[find_q[0]].fsys_unique_txn_id), UVM_NONE+50)
         cmd_idx = smi_snpreq_order_idx_<%=pidx%>[idx];
         snp_idx = smi_snpreq_order_idx2_<%=pidx%>[idx];
         if ((fsys_txn_q[find_q[0]].cmd_addr_q[cmd_idx] >> addrMgrConst::WCACHE_OFFSET == m_pkt.acaddr >> addrMgrConst::WCACHE_OFFSET) // || fsys_txn_q[idx].recall_addr == m_pkt.acaddr)
            <% if (obj.wSecurityAttribute > 0) { %>
               && fsys_txn_q[find_q[0]].smi_ns == m_pkt.acprot[1]
            <% } %>
            && fsys_txn_q[find_q[0]].is_dvm == 0) begin
            if (fsys_txn_q[find_q[0]].snpreq_targ_id_q[snp_idx] == <%=obj.AiuInfo[pidx].FUnitId%>
               && fsys_txn_q[find_q[0]].ioaiu_snp_addr_seen_q[snp_idx] == 0
            ) begin
               `uvm_info(`LABEL, $sformatf(
                  "FSYS_UID:%0d : IOAIU Snoop Addr packet seen. %0s", 
                  fsys_txn_q[find_q[0]].fsys_unique_txn_id, m_pkt.sprint_pkt()), UVM_NONE+50)
<% if(obj.AiuInfo[pidx].fnNativeInterface == "ACE"||obj.AiuInfo[pidx].fnNativeInterface == "ACE5"){ %>
               fsys_txn_q[find_q[0]].m_axi_snp_addr_pkt_<%=pidx%> = new();
               fsys_txn_q[find_q[0]].m_axi_snp_addr_pkt_<%=pidx%>.copy(m_pkt);
<% } %>
               snoop_waiting_resp_counter_<%=pidx%>_<%=i%>++;
               fsys_txn_q[find_q[0]].ioaiu_snp_addr_seen_q[snp_idx] = 1;
               fsys_txn_q[find_q[0]].ioaiu_snprsp_exp_q[snp_idx] = 1;
               fsys_txn_q[find_q[0]].ioaiu_snpdat_exp_q[snp_idx] = 1;
               fsys_txn_q[find_q[0]].snpreq_addr_q[snp_idx] = m_pkt.acaddr;
               fsys_txn_q[find_q[0]].update_time_accessed("snp_addr","<%=_child_blkid[pidx]%>");
               snoop_order_uid_<%=pidx%>_<%=i%>.push_back(fsys_txn_q[find_q[0]].fsys_unique_txn_id);
               snoop_order_snp_idx_<%=pidx%>_<%=i%>.push_back(snp_idx);
               match_found = 1;
               smi_snpreq_order_uid_<%=pidx%>.delete(idx);
               smi_snpreq_order_idx_<%=pidx%>.delete(idx);
               smi_snpreq_order_idx2_<%=pidx%>.delete(idx);
            end // if matched
         end // if addr match 
      end //if UID found 
      else begin
         `uvm_error(`LABEL, $sformatf(
            "FSYS_SCB: Failed to find pending txn with FSYS_UID:%0d ", 
            smi_snpreq_order_uid_<%=pidx%>[idx]))
      end
      if (match_found == 1) begin

         break;
      end
      //match recall
      if (fsys_txn_q[find_q[0]].cmd_msg_id_q.size() == 0) begin
         if (fsys_txn_q[find_q[0]].recall_addr == m_pkt.acaddr
            && fsys_txn_q[find_q[0]].is_dvm == 0) begin
            foreach (fsys_txn_q[find_q[0]].snpreq_targ_id_q[j]) begin
               if (fsys_txn_q[find_q[0]].snpreq_targ_id_q[j] == <%=obj.AiuInfo[pidx].FUnitId%>
                  && fsys_txn_q[find_q[0]].ioaiu_snp_addr_seen_q[j] == 0
               ) begin
                  `uvm_info(`LABEL, $sformatf(
                     "FSYS_UID:%0d : IOAIU Snoop Addr packet seen. %0s", 
                     fsys_txn_q[find_q[0]].fsys_unique_txn_id, m_pkt.sprint_pkt()), UVM_NONE+50)
                  fsys_txn_q[find_q[0]].ioaiu_snp_addr_seen_q[j] = 1;
                  snoop_waiting_resp_counter_<%=pidx%>_<%=i%>++;
                  fsys_txn_q[find_q[0]].ioaiu_snprsp_exp_q[j] = 1;
                  fsys_txn_q[find_q[0]].ioaiu_snpdat_exp_q[j] = 1;
                  fsys_txn_q[find_q[0]].snpreq_addr_q[j] = m_pkt.acaddr;
                  fsys_txn_q[find_q[0]].update_time_accessed("snp_addr","<%=_child_blkid[pidx]%>");
                  snoop_order_uid_<%=pidx%>_<%=i%>.push_back(fsys_txn_q[find_q[0]].fsys_unique_txn_id);
                  snoop_order_snp_idx_<%=pidx%>_<%=i%>.push_back(j);
                  match_found = 1;
                  break;
               end // if matched
            end // foreach snpreq_targ_id_q 
         end // if addr match
      end
      if (match_found == 1) break;
   end // foreach pending txn
   if (match_found == 0) begin
      `uvm_error(`LABEL, $sformatf(
         "FSYS_SCB: IOAIU Snoop Addr packet didn't match any pending transactions. %0s",
         m_pkt.sprint_pkt()))
   end
endfunction : analyze_snoop_addr_pkt_<%=pidx%>_<%=i%>

//===================================================================================================
//
//===================================================================================================
function void fsys_scb_ioaiu_predictor::process_dvm_snp_<%=pidx%>_<%=i%>(<%=_child_blkid[pidx]%>_env_pkg::ace_snoop_addr_pkt_t m_pkt, ref fsys_scb_txn fsys_txn_q[$]);
   `undef LABEL
   `define LABEL "snoop_addr_pkt_<%=_child_blkid[pidx]%>_core<%=i%>"
   bit match_found = 0;
   bit[63:0] exp_addr_1_1;
   bit[63:0] exp_addr_2_1;
   foreach (fsys_txn_q[idx]) begin
      if (fsys_txn_q[idx].is_dvm == 1) begin
         exp_addr_1_1 = smi_snp_addr_to_ace_snp_addr(0, 
                                                     fsys_txn_q[idx].dvm_part_1_addr_q[0], 
                                                     fsys_txn_q[idx].dvm_part_2_addr_q[0], 
                                                     fsys_txn_q[idx].dvm_mpf3_range_q[0], 
                                                     fsys_txn_q[idx].dvm_mpf3_num_q[0], 
                                                     fsys_txn_q[idx].dvm_mpf1_q[0],
                                                     fsys_txn_q[idx].dvm_part_2_mpf1_q[0]);
         exp_addr_2_1 = smi_snp_addr_to_ace_snp_addr(1, 
                                                     fsys_txn_q[idx].dvm_part_2_addr_q[0],
                                                     fsys_txn_q[idx].dvm_part_1_addr_q[0], 
                                                     fsys_txn_q[idx].dvm_mpf3_range_q[0], 
                                                     fsys_txn_q[idx].dvm_mpf3_num_q[0], 
                                                     fsys_txn_q[idx].dvm_part_2_mpf1_q[0],
                                                     fsys_txn_q[idx].dvm_mpf1_q[0]);
         // if PICI type DVM, addr bit[40] is don't care and needs to be ignored in 1st snoop
         `uvm_info(`LABEL, $sformatf("FSYS_UID:%0d : DVM OP type = 3'b%0b, single part DVM=%0d, exp_addr_1_1=0x%0h",fsys_txn_q[idx].fsys_unique_txn_id, fsys_txn_q[idx].dvm_part_1_addr_q[0][13:11], (fsys_txn_q[idx].dvm_part_2_exp==0 && fsys_txn_q[idx].dvm_part_2_seen==0), exp_addr_1_1), UVM_NONE+50)
         if (fsys_txn_q[idx].dvm_part_1_addr_q[0][13:11] == 3'b010) begin
         `uvm_info(`LABEL, $sformatf("FSYS_UID:%0d : 1: bit 40 being flipped",fsys_txn_q[idx].fsys_unique_txn_id), UVM_NONE+50)
            exp_addr_1_1[40:40] = m_pkt.acaddr[40:40];
         end else begin
            exp_addr_2_1[3:3] = m_pkt.acaddr[3:3];
         end
         `uvm_info(`LABEL, $sformatf("FSYS_UID:%0d : Snoop 1: part-1 acaddr=0x%0h, 1_smi_addr=0x%0h. 2_smi_addr=0x%0h, 1_mpf1=0x%0h. , 2_mpf1=0x%0h",fsys_txn_q[idx].fsys_unique_txn_id,exp_addr_1_1, fsys_txn_q[idx].dvm_part_1_addr_q[0], fsys_txn_q[idx].dvm_part_2_addr_q[0], fsys_txn_q[idx].dvm_mpf1_q[0], fsys_txn_q[idx].dvm_part_2_mpf1_q[0]), UVM_NONE+50)
         `uvm_info(`LABEL, $sformatf("FSYS_UID:%0d : Snoop 2: part-1 acaddr=0x%0h, 1_smi_addr=0x%0h. 2_smi_addr=0x%0h, 1_mpf1=0x%0h. , 2_mpf1=0x%0h",fsys_txn_q[idx].fsys_unique_txn_id,exp_addr_2_1, fsys_txn_q[idx].dvm_part_2_addr_q[0], fsys_txn_q[idx].dvm_part_1_addr_q[0], fsys_txn_q[idx].dvm_part_2_mpf1_q[0], fsys_txn_q[idx].dvm_mpf1_q[0]), UVM_NONE+50)
         foreach (fsys_txn_q[idx].snpreq_targ_id_q[j]) begin
            if (fsys_txn_q[idx].snpreq_targ_id_q[j] == <%=obj.AiuInfo[pidx].FUnitId%>
               && fsys_txn_q[idx].ioaiu_dvm_snp_addr_seen_q[j] < 2
               && (m_pkt.acaddr[(<%=obj.AiuInfo[pidx].wAddr%>-1):0] == exp_addr_1_1[(<%=obj.AiuInfo[pidx].wAddr%>-1):0] 
                  || m_pkt.acaddr[(<%=obj.AiuInfo[pidx].wAddr%>-1):0] == exp_addr_2_1[(<%=obj.AiuInfo[pidx].wAddr%>-1):0])
            ) begin
               `uvm_info(`LABEL, $sformatf(
                  "FSYS_UID:%0d : IOAIU Snoop Addr packet seen. %0s", 
                  fsys_txn_q[idx].fsys_unique_txn_id, m_pkt.sprint_pkt()), UVM_NONE+50)
               fsys_txn_q[idx].ioaiu_dvm_snp_addr_seen_q[j]++;
               snoop_waiting_resp_counter_<%=pidx%>_<%=i%>++;
               if (fsys_txn_q[idx].ioaiu_snprsp_exp_q[j] == 1) begin
                  //repurposing snpdat flag to indicate 2 IOAIU SNPRSP are expected
                  fsys_txn_q[idx].ioaiu_snpdat_exp_q[j] = 1;
               end
               fsys_txn_q[idx].ioaiu_snprsp_exp_q[j] = 1;
               fsys_txn_q[idx].update_time_accessed();
               snoop_order_uid_<%=pidx%>_<%=i%>.push_back(fsys_txn_q[idx].fsys_unique_txn_id);
               snoop_order_snp_idx_<%=pidx%>_<%=i%>.push_back(j);
               match_found = 1;
               break;
            end // if matched
         end // foreach snpreq_targ_id_q
      end // if DVM
      if (match_found == 1) break;
   end // foreach
   if (match_found == 0) begin
      //TODO: Add a new DVM transaction
      `uvm_error(`LABEL, $sformatf(
         "FSYS_SCB: IOAIU DVM Snoop Addr packet didn't match any pending transactions. %0s",
         m_pkt.sprint_pkt()))
   end
endfunction : process_dvm_snp_<%=pidx%>_<%=i%>

//===================================================================================================
//
//===================================================================================================
function void fsys_scb_ioaiu_predictor::analyze_snoop_resp_pkt_<%=pidx%>_<%=i%>(<%=_child_blkid[pidx]%>_env_pkg::ace_snoop_resp_pkt_t m_pkt, ref fsys_scb_txn fsys_txn_q[$]);
   `undef LABEL
   `define LABEL "snoop_resp_pkt_<%=_child_blkid[pidx]%>_core<%=i%>"
   bit match_found = 0;
   int find_q[$];
   bit use_cache = <%=obj.AiuInfo[pidx].useCache%>;
   bit all_snp_resp_seen = 1;
   bit all_ioaiu_snp_resp_seen = 1;
   bit all_chi_snp_resp_seen = 1;
   int snp_idx;
   <%=_child_blkid[pidx]%>_env_pkg::ace_snoop_addr_pkt_t snp_addr_pkt;
   <%=_child_blkid[pidx]%>_env_pkg::ace_snoop_data_pkt_t snp_dat_pkt;

   <% if(obj.AiuInfo[pidx].fnNativeInterface == "ACE5"||obj.AiuInfo[pidx].fnNativeInterface == "ACE"){ %>
   snp_addr_pkt = ace_snp_req_q_<%=pidx%>.pop_front();
    if(!(snp_addr_pkt.acsnoop inside {4'b1110, 4'b1111})) begin //ACE_DVM_CMPL,ACE_DVM_MSG}))begin 
        if(m_en_coh_check) begin
            package_and_send_coh_checker_<%=pidx%>(null,snp_addr_pkt,m_pkt.crresp[<%=_child_blkid[pidx]%>_env_pkg::CCRRESPDATXFERBIT],m_pkt.crresp,0,0,1,0);
        end
    end
   <% } %>       
   //First delete all non-existing UIDs
   for(int idx = snoop_order_uid_<%=pidx%>_<%=i%>.size()-1; idx >=0; idx--) begin
      find_q = fsys_txn_q.find_index with (item.fsys_unique_txn_id == snoop_order_uid_<%=pidx%>_<%=i%>[idx]);
      if (find_q.size() == 0) begin
         `uvm_info(`LABEL, $sformatf("FSYS_UID:%0d : snoop_order_uid_counter_<%=pidx%>_<%=i%> increamented", snoop_order_uid_<%=pidx%>_<%=i%>[idx]), UVM_NONE+50)
         snoop_order_uid_<%=pidx%>_<%=i%>.delete(idx);
         snoop_order_snp_idx_<%=pidx%>_<%=i%>.delete(idx);
         snoop_order_uid_counter_<%=pidx%>_<%=i%>++;
      end
   end
   find_q.delete();
   foreach (snoop_order_uid_<%=pidx%>_<%=i%>[idx]) begin
      find_q = fsys_txn_q.find_index with (item.fsys_unique_txn_id == snoop_order_uid_<%=pidx%>_<%=i%>[idx]);
      snp_idx = snoop_order_snp_idx_<%=pidx%>_<%=i%>[idx];
      if (find_q.size() == 1) begin
         if (fsys_txn_q[find_q[0]].snpreq_targ_id_q.size() > snp_idx) begin
            if ((fsys_txn_q[find_q[0]].ioaiu_snprsp_exp_q[snp_idx] == 1
                  || (fsys_txn_q[find_q[0]].ioaiu_snprsp_exp_q[snp_idx] == 0 && fsys_txn_q[find_q[0]].is_dvm == 1 && fsys_txn_q[find_q[0]].ioaiu_snpdat_exp_q[snp_idx] == 1))
                  && fsys_txn_q[find_q[0]].snpreq_targ_id_q[snp_idx] == <%=obj.AiuInfo[pidx].FUnitId%>
            ) begin
               `uvm_info(`LABEL, $sformatf(
                  "FSYS_UID:%0d : IOAIU Snoop Response packet seen. Snoop data %0s. %0s", 
                  fsys_txn_q[find_q[0]].fsys_unique_txn_id, 
                  (m_pkt.crresp[<%=_child_blkid[pidx]%>_env_pkg::CCRRESPDATXFERBIT] == 1) 
                  ? "Expected" : "Not Expected", m_pkt.sprint_pkt()), UVM_NONE+50)
               if (fsys_txn_q[find_q[0]].ioaiu_snprsp_exp_q[snp_idx] == 0 && fsys_txn_q[find_q[0]].is_dvm == 1 && fsys_txn_q[find_q[0]].ioaiu_snpdat_exp_q[snp_idx] == 1) begin
                  fsys_txn_q[find_q[0]].ioaiu_snpdat_exp_q[snp_idx] = 0;
               end
               fsys_txn_q[find_q[0]].ioaiu_snprsp_exp_q[snp_idx] = 0;
               snoop_waiting_resp_counter_<%=pidx%>_<%=i%>--;
               if (m_pkt.crresp[<%=_child_blkid[pidx]%>_env_pkg::CCRRESPDATXFERBIT] == 1) begin
                  if (snp_data_pkt_<%=pidx%>_<%=i%>.size() > 0) begin
                     snp_dat_pkt = snp_data_pkt_<%=pidx%>_<%=i%>.pop_front();
                     `uvm_info(`LABEL, $sformatf(
                        "FSYS_UID:%0d : IOAIU Snoop data packet seen. %0s", 
                        fsys_txn_q[find_q[0]].fsys_unique_txn_id, snp_dat_pkt.sprint_pkt()), 
                        UVM_NONE+50)
                     fsys_txn_q[find_q[0]].ioaiu_snpdat_exp_q[snp_idx] = 0;
                     fsys_txn_q[find_q[0]].ioaiu_snp_data_seen_q[snp_idx] = 1;
                     //MEM_CONSISTENCY
                     if(m_en_mem_check) begin
                        fsys_txn_q[find_q[0]].save_ioaiu_snp_data_<%=pidx%>(snp_dat_pkt, <%=obj.AiuInfo[pidx].FUnitId%>, fsys_txn_q[find_q[0]].snpreq_addr_q[snp_idx]);
                     end
                     if (fsys_txn_q[find_q[0]].snp_up_q[snp_idx] !== 'b00) begin
                        fsys_txn_q[find_q[0]].read_acc_dtr_exp_q[snp_idx] = 1;
                     end // read acceleration by providing DTR to requesting AIU
                     snoop_order_uid_<%=pidx%>_<%=i%>.delete(idx);
                     snoop_order_snp_idx_<%=pidx%>_<%=i%>.delete(idx);
                  end else begin
                     fsys_txn_q[find_q[0]].ioaiu_snpdat_exp_q[snp_idx] = 1;
                     //TODO: error if data was seen but resp doesn't expect it.
                     if (fsys_txn_q[find_q[0]].ioaiu_snp_data_seen_q[snp_idx] == 1) begin
                        fsys_txn_q[find_q[0]].ioaiu_snpdat_exp_q[snp_idx] = 0;
                        snoop_order_uid_<%=pidx%>_<%=i%>.delete(idx);
                        snoop_order_snp_idx_<%=pidx%>_<%=i%>.delete(idx);
                     end
                  end
               end else begin
                  if (fsys_txn_q[find_q[0]].is_dvm == 0) begin
                     fsys_txn_q[find_q[0]].ioaiu_snpdat_exp_q[snp_idx] = 0;
                  end
                  snoop_order_uid_<%=pidx%>_<%=i%>.delete(idx);
                  snoop_order_snp_idx_<%=pidx%>_<%=i%>.delete(idx);
               end
               fsys_txn_q[find_q[0]].update_time_accessed("snp_resp","<%=_child_blkid[pidx]%>");
               //Delete logic for DVM
               if (fsys_txn_q[find_q[0]].is_dvm == 1) begin
                  foreach(fsys_txn_q[find_q[0]].snpreq_cnt_q[snpreq_idx]) begin
                     if (fsys_txn_q[find_q[0]].snpreq_cnt_q[snpreq_idx] == 0) begin
                        all_snp_resp_seen = (all_snp_resp_seen & 1'b1);
                     end else begin
                        all_snp_resp_seen = 0;
                     end
                  end
                  foreach(fsys_txn_q[find_q[0]].ioaiu_snprsp_exp_q[snpreq_idx]) begin
                     if (fsys_txn_q[find_q[0]].ioaiu_snprsp_exp_q[snpreq_idx] == 0 && fsys_txn_q[find_q[0]].ioaiu_snpdat_exp_q[snpreq_idx] == 0) begin
                        all_ioaiu_snp_resp_seen = (all_ioaiu_snp_resp_seen & 1'b1);
                     end else begin
                        all_ioaiu_snp_resp_seen = 0;
                     end
                  end
                  foreach(fsys_txn_q[find_q[0]].chi_snp_txnid_q[snpreq_idx]) begin
                     if (fsys_txn_q[find_q[0]].chi_snp_txnid_q[snpreq_idx] < 0) begin
                        all_chi_snp_resp_seen = (all_chi_snp_resp_seen & 1'b1);
                     end else begin
                        all_chi_snp_resp_seen = 0;
                     end
                  end
                  if (all_snp_resp_seen == 1 
                     && (fsys_txn_q[find_q[0]].axi_data_seen == 1 || (fsys_txn_q[find_q[0]].ioaiu_core_id < 0 && fsys_txn_q[find_q[0]].aiu_check_done == 1))
                     && fsys_txn_q[find_q[0]].dvm_complete_exp == 0 && fsys_txn_q[find_q[0]].dvm_complete_resp_exp == 0
                     && fsys_txn_q[find_q[0]].ac_dvmcmpl_exp == 0 && fsys_txn_q[find_q[0]].ac_dvmcmpl_resp_exp == 0
                     && all_ioaiu_snp_resp_seen == 1 && all_chi_snp_resp_seen == 1) begin
                     `uvm_info(`LABEL, $sformatf(
                        "FSYS_UID:%0d : Deleting transaction from fsys_txn_q. Remaining txns: 'd%0d",
                        fsys_txn_q[find_q[0]].fsys_unique_txn_id, (fsys_txn_q.size()-1)), UVM_NONE+50)
                     `ifdef FSYS_SCB_COVER_ON
                        fsys_txn_path_cov.sample_txn(fsys_txn_q[find_q[0]].smi_msg_order_q, (fsys_txn_q[find_q[0]].ioaiu_core_id >= 0));
                     `endif // `ifdef FSYS_SCB_COVER_ON
                     fsys_txn_q[find_q[0]].print_path();
                     if(!$test$plusargs("print_latency_delay"))fsys_txn_q.delete(find_q[0]);
                  end
               end
               //delete logic for DVM
               match_found = 1;
               break;
            end // if matched
         end // snpreq_targ_id_q queue is large enough
         if (match_found == 0) begin
            if (fsys_txn_q[find_q[0]].is_dvm == 1
                  && fsys_txn_q[find_q[0]].ac_dvmcmpl_resp_exp == 1
                  && fsys_txn_q[find_q[0]].source_funit_id == <%=obj.AiuInfo[pidx].FUnitId%>
            ) begin
               all_snp_resp_seen = 1;
               all_ioaiu_snp_resp_seen = 1;
               all_chi_snp_resp_seen = 1;
               fsys_txn_q[find_q[0]].ac_dvmcmpl_resp_exp = 0;
               `uvm_info(`LABEL, $sformatf(
                  "FSYS_UID:%0d : IOAIU DVM complete response seen.", 
                  fsys_txn_q[find_q[0]].fsys_unique_txn_id), UVM_NONE+50)
               match_found = 1;
               fsys_txn_q[find_q[0]].update_time_accessed("snp_resp","<%=_child_blkid[pidx]%>");
               //Delete logic
               foreach(fsys_txn_q[find_q[0]].snpreq_cnt_q[snpreq_idx]) begin
                  if (fsys_txn_q[find_q[0]].snpreq_cnt_q[snpreq_idx] == 0) begin
                     all_snp_resp_seen = (all_snp_resp_seen & 1'b1);
                  end else begin
                     all_snp_resp_seen = 0;
                  end
               end
               foreach(fsys_txn_q[find_q[0]].ioaiu_snprsp_exp_q[snpreq_idx]) begin
                  if (fsys_txn_q[find_q[0]].ioaiu_snprsp_exp_q[snpreq_idx] == 0 && fsys_txn_q[find_q[0]].ioaiu_snpdat_exp_q[snpreq_idx] == 0) begin
                     all_ioaiu_snp_resp_seen = (all_ioaiu_snp_resp_seen & 1'b1);
                  end else begin
                     all_ioaiu_snp_resp_seen = 0;
                  end
               end
               foreach(fsys_txn_q[find_q[0]].chi_snp_txnid_q[snpreq_idx]) begin
                  if (fsys_txn_q[find_q[0]].chi_snp_txnid_q[snpreq_idx] < 0) begin
                     all_chi_snp_resp_seen = (all_chi_snp_resp_seen & 1'b1);
                  end else begin
                     all_chi_snp_resp_seen = 0;
                  end
               end
               if (all_snp_resp_seen == 1 && fsys_txn_q[find_q[0]].axi_data_seen == 1 
                  && fsys_txn_q[find_q[0]].dvm_complete_exp == 0 && fsys_txn_q[find_q[0]].dvm_complete_resp_exp == 0
                  && fsys_txn_q[find_q[0]].ac_dvmcmpl_exp == 0 && fsys_txn_q[find_q[0]].ac_dvmcmpl_resp_exp == 0
                  && all_ioaiu_snp_resp_seen == 1 && all_chi_snp_resp_seen == 1) begin
                  `uvm_info(`LABEL, $sformatf(
                     "FSYS_UID:%0d : Deleting transaction from fsys_txn_q. Remaining txns: 'd%0d",
                     fsys_txn_q[find_q[0]].fsys_unique_txn_id, (fsys_txn_q.size()-1)), UVM_NONE+50)
                     `ifdef FSYS_SCB_COVER_ON
                        fsys_txn_path_cov.sample_txn(fsys_txn_q[find_q[0]].smi_msg_order_q, (fsys_txn_q[find_q[0]].ioaiu_core_id >= 0));
                     `endif // `ifdef FSYS_SCB_COVER_ON
                     fsys_txn_q[find_q[0]].print_path();
                     fsys_txn_q.delete(find_q[0]);
               end
               //delete logic
               break;
            end // match found
         end // no match_found, try DVM Cmpl response matching
      end // if UID found
      else begin
         `uvm_error(`LABEL, $sformatf(
            "FSYS_SCB: Failed to find pending txn with FSYS_UID:%0d ", 
            snoop_order_uid_<%=pidx%>_<%=i%>[idx]))
      end
      if (match_found == 1) break;
   end //foreach snoop_order_uid
   if (match_found == 0) begin
      if (snoop_order_uid_counter_<%=pidx%>_<%=i%> > 0) begin
         //CONC-10816 - IOAIU sends early SMI SnpRsp without seeing it in AC channel
         `uvm_info(`LABEL, $sformatf(
            "FSYS_SCB: IOAIU Snoop Response packet received, it's corresponding transaction is already deleted from fsys_txn_q", 
            m_pkt.sprint_pkt()), UVM_NONE+50)
         if (m_pkt.crresp[<%=_child_blkid[pidx]%>_env_pkg::CCRRESPDATXFERBIT] == 0) begin
            snoop_order_uid_counter_<%=pidx%>_<%=i%>--;
         end
      end else begin
         `uvm_error(`LABEL, $sformatf(
            "FSYS_SCB: IOAIU Snoop Response packet didn't match any pending transactions. %0s", 
            m_pkt.sprint_pkt()))
      end
   end
endfunction : analyze_snoop_resp_pkt_<%=pidx%>_<%=i%>
//===================================================================================================
//
//===================================================================================================
function void fsys_scb_ioaiu_predictor::analyze_snoop_data_pkt_<%=pidx%>_<%=i%>(<%=_child_blkid[pidx]%>_env_pkg::ace_snoop_data_pkt_t m_pkt, ref fsys_scb_txn fsys_txn_q[$]);
   `undef LABEL
   `define LABEL "snoop_data_pkt_<%=_child_blkid[pidx]%>_core<%=i%>"
   bit match_found = 0;
   bit use_cache = <%=obj.AiuInfo[pidx].useCache%>;
   int find_q[$];
   int snp_idx;
   //First delete all non-existing UIDs
   for(int idx = snoop_order_uid_<%=pidx%>_<%=i%>.size()-1; idx >=0; idx--) begin
      find_q = fsys_txn_q.find_index with (item.fsys_unique_txn_id == snoop_order_uid_<%=pidx%>_<%=i%>[idx]);
      if (find_q.size() == 0) begin
         `uvm_info(`LABEL, $sformatf("FSYS_SCB:snoop_order_uid_counter_<%=pidx%>_<%=i%> increamented for: %0d", snoop_order_uid_<%=pidx%>_<%=i%>[idx]), UVM_NONE+50)
         snoop_order_uid_<%=pidx%>_<%=i%>.delete(idx);
         snoop_order_snp_idx_<%=pidx%>_<%=i%>.delete(idx);
         snoop_order_uid_counter_<%=pidx%>_<%=i%>++;
      end
   end
   find_q.delete();
   foreach (snoop_order_uid_<%=pidx%>_<%=i%>[idx]) begin
      find_q = fsys_txn_q.find_index with (item.fsys_unique_txn_id == snoop_order_uid_<%=pidx%>_<%=i%>[idx]);
      snp_idx = snoop_order_snp_idx_<%=pidx%>_<%=i%>[idx];
      if (find_q.size() == 1) begin
         if (fsys_txn_q[find_q[0]].snpreq_targ_id_q.size() > snp_idx) begin
            if (fsys_txn_q[find_q[0]].ioaiu_snpdat_exp_q[snp_idx] == 1
               && fsys_txn_q[find_q[0]].ioaiu_snprsp_exp_q[snp_idx] == 0
               && fsys_txn_q[find_q[0]].ioaiu_snp_data_seen_q[snp_idx] == 0
               && fsys_txn_q[find_q[0]].snpreq_targ_id_q[snp_idx] == <%=obj.AiuInfo[pidx].FUnitId%>
               && fsys_txn_q[find_q[0]].is_dvm == 0
            ) begin
               `uvm_info(`LABEL, $sformatf(
                  "FSYS_UID:%0d : IOAIU Snoop data packet seen. %0s", 
                  fsys_txn_q[find_q[0]].fsys_unique_txn_id, m_pkt.sprint_pkt()), 
                  UVM_NONE+50)
               fsys_txn_q[find_q[0]].ioaiu_snpdat_exp_q[snp_idx] = 0;
               fsys_txn_q[find_q[0]].ioaiu_snp_data_seen_q[snp_idx] = 1;
               //MEM_CONSISTENCY
               if(m_en_mem_check) begin
                  fsys_txn_q[find_q[0]].save_ioaiu_snp_data_<%=pidx%>(m_pkt, <%=obj.AiuInfo[pidx].FUnitId%>, fsys_txn_q[find_q[0]].snpreq_addr_q[snp_idx]);
               end
               if (fsys_txn_q[find_q[0]].snp_up_q[snp_idx] !== 'b00) begin
                  fsys_txn_q[find_q[0]].read_acc_dtr_exp_q[snp_idx] = 1;
               end // read acceleration by providing DTR to requesting AIU
               //if (use_cache == 0) begin
                  // Add this SNP's RBID from RBRReq to rbid queue. This way DTW lookup equation remains same
                  // TODO: rbr_rbid_q's index does not map to snpreq_targ_id_q's index 1:1. Fix this
               //   fsys_txn_q[find_q[0]].rbid_val_q.push_back(1);
               //   fsys_txn_q[find_q[0]].rbid_q.push_back(fsys_txn_q[find_q[0]].rbr_rbid_q[snp_idx]);
               //   fsys_txn_q[find_q[0]].rbid_unit_id_q.push_back(fsys_txn_q[find_q[0]].cmd_did_q[snp_idx]);
               //   fsys_txn_q[find_q[0]].snpdat_unit_id_q.push_back(<%=obj.AiuInfo[pidx].FUnitId%>);
               //end
               if (fsys_txn_q[find_q[0]].ioaiu_snprsp_exp_q[snp_idx] == 0) 
                  snoop_order_uid_<%=pidx%>_<%=i%>.delete(idx);
                  snoop_order_snp_idx_<%=pidx%>_<%=i%>.delete(idx);
               match_found = 1;
               fsys_txn_q[find_q[0]].update_time_accessed("snp_data","<%=_child_blkid[pidx]%>");
               break;
            end // if matched
         end // snpreq_targ_id_q queue is large enough
      end // if UID found 
      else begin
         `uvm_error(`LABEL, $sformatf(
            "FSYS_SCB: Failed to find pending txn with FSYS_UID:%0d ", 
            snoop_order_uid_<%=pidx%>_<%=i%>[idx]))
      end
      if (match_found == 1) break;
   end //foreach snoop_order_uid
   if (match_found == 0) begin
      if (snoop_waiting_resp_counter_<%=pidx%>_<%=i%> > 0) begin
         snp_data_pkt_<%=pidx%>_<%=i%>.push_back(m_pkt);
      end else if (snoop_order_uid_counter_<%=pidx%>_<%=i%> > 0) begin
         //CONC-10816 - IOAIU sends early SMI SnpRsp without seeing it in AC channel
         `uvm_info(`LABEL, $sformatf(
            "FSYS_SCB: IOAIU Snoop Response Data received, it's corresponding transaction is already deleted from fsys_txn_q", 
            m_pkt.sprint_pkt()), UVM_NONE+50)
         snoop_order_uid_counter_<%=pidx%>_<%=i%>--;
      end else begin
         `uvm_error(`LABEL, $sformatf(
            "FSYS_SCB: IOAIU Snoop Data packet didn't match any pending transactions. %0s",
            m_pkt.sprint_pkt()))
      end
   end
endfunction : analyze_snoop_data_pkt_<%=pidx%>_<%=i%>
<%}%>
<% } // foreach InterfacePorts%>

//===================================================================================================
//
//===================================================================================================
function void fsys_scb_ioaiu_predictor::analyze_smi_pkt_<%=pidx%>(input <%=_child_blkid[pidx]%>_smi_agent_pkg::smi_seq_item m_pkt, ref fsys_scb_txn fsys_txn_q[$]);
   <%=_child_blkid[pidx]%>_smi_agent_pkg::smi_seq_item tmp_pkt = <%=_child_blkid[pidx]%>_smi_agent_pkg::smi_seq_item::type_id::create("tmp_pkt");
   //$cast(tmp_pkt, m_pkt);
   tmp_pkt.copy(m_pkt);
   if (tmp_pkt.isCmdMsg()) begin
      smi_cmd_msg_prediction_<%=pidx%>(tmp_pkt, fsys_txn_q);
   end // if cmd_req smi pkt
   if (tmp_pkt.isStrMsg()) begin
      smi_str_prediction_<%=pidx%>(tmp_pkt, fsys_txn_q);
   end
   else if (tmp_pkt.isDtrMsg()) begin
      smi_dtr_prediction_<%=pidx%>(tmp_pkt, fsys_txn_q);
   end // if DTRReq
   else if (tmp_pkt.isDtwMsg()) begin
      smi_dtw_prediction_<%=pidx%>(tmp_pkt, fsys_txn_q);
   end // if DTRReq
   else if (tmp_pkt.isSnpMsg()) begin
      smi_snpreq_prediction_<%=pidx%>(tmp_pkt, fsys_txn_q);
   end // is SNPReq
   else if (tmp_pkt.isSnpRspMsg()) begin
      <% if(obj.AiuInfo[pidx].useCache == 1) {%>
      if(m_en_coh_check) begin
         smi_snprsp_proxy_cache_<%=pidx%>(tmp_pkt);
      end
      <% } // useCache%>
   end // is SNPRsp
   else if (tmp_pkt.isUpdMsg()) begin
      smi_updreq_prediction_<%=pidx%>(tmp_pkt, fsys_txn_q);
   end // is UpdReq
   else if (tmp_pkt.isSysReqMsg()) begin
      smi_sysreq_prediction_<%=pidx%>(tmp_pkt, fsys_txn_q);
   end // is SysReq
   else if (tmp_pkt.isSysRspMsg()) begin
      smi_sysrsp_prediction_<%=pidx%>(tmp_pkt, fsys_txn_q);
   end // is SysRsp

   if($test$plusargs("print_latency_delay")) begin:_print_latency
      smi_otherrsp_prediction_<%=pidx%>(tmp_pkt, fsys_txn_q);
   end:_print_latency
endfunction : analyze_smi_pkt_<%=pidx%>

//===================================================================================================
//
//===================================================================================================
function void fsys_scb_ioaiu_predictor::smi_otherrsp_prediction_<%=pidx%>(input <%=_child_blkid[pidx]%>_smi_agent_pkg::smi_seq_item m_pkt, ref fsys_scb_txn fsys_txn_q[$]);
      int find_q[$];
      if($test$plusargs("latency_details")) begin
         $display("%s",m_pkt.convert2string());
      end
         if (m_pkt.isStrRspMsg()) begin
         find_q = fsys_txn_q.find_index with ( //Find Strreq to link STRrsp
                    item.source_funit_id == <%=obj.AiuInfo[pidx].FUnitId%>
                    && m_pkt.smi_rmsg_id inside {item.strrsp_rmsg_id_q}
                    );
   	  	if (find_q.size()) fsys_txn_q[find_q[0]].update_time_accessed("str_rsp_aiu", "<%=_child_blkid[pidx]%>");
       end
       if (m_pkt.isDtrRspMsg()) begin
          find_q = fsys_txn_q.find_index with ( //Find dtrreq to link dtrrsp
                    item.source_funit_id == <%=obj.AiuInfo[pidx].FUnitId%>
                    && item.dest_funit_id == m_pkt.smi_targ_ncore_unit_id
                    && m_pkt.smi_rmsg_id inside {item.dtrrsp_rmsg_id_q}
                    );
   	  	if (find_q.size()) fsys_txn_q[find_q[0]].update_time_accessed("dtr_rsp_aiu", "<%=_child_blkid[pidx]%>");
       end
       if (m_pkt.isDtwRspMsg()) begin
          find_q = fsys_txn_q.find_index with ( //Find dtrreq to link dtrrsp
                    item.source_funit_id == <%=obj.AiuInfo[pidx].FUnitId%>
                    && item.dest_funit_id == m_pkt.smi_src_ncore_unit_id
                    && m_pkt.smi_rmsg_id inside {item.dtwrsp_rmsg_id_q}
                    );
   	  	if (find_q.size()) fsys_txn_q[find_q[0]].update_time_accessed("dtw_rsp_aiu", "<%=_child_blkid[pidx]%>");
       end
	    if (m_pkt.isNcCmdRspMsg()) begin
		 find_q = fsys_txn_q.find_index with ( //Find XXXreq to link XXXrsp
                    item.source_funit_id == <%=obj.AiuInfo[pidx].FUnitId%>
                    && item.dest_funit_id == m_pkt.smi_src_ncore_unit_id
                     && m_pkt.smi_rmsg_id inside {item.cmd_req_id_q}  
                    );
   	  	if (find_q.size()) fsys_txn_q[find_q[0]].update_time_accessed("cmd_rsp_aiu", "<%=_child_blkid[pidx]%>");
	   end
       if (m_pkt.isCCmdRspMsg()) begin
	    find_q = fsys_txn_q.find_index with ( //Find XXXreq to link XXXrsp
                    item.source_funit_id == <%=obj.AiuInfo[pidx].FUnitId%>
                    && m_pkt.smi_src_ncore_unit_id inside {item.cmd_req_targ_q}
                    && m_pkt.smi_rmsg_id inside {item.cmd_req_id_q}  
                    );
   	 	if (find_q.size()) fsys_txn_q[find_q[0]].update_time_accessed("cmd_rsp_aiu", "<%=_child_blkid[pidx]%>");
	   end
endfunction: smi_otherrsp_prediction_<%=pidx%>
//===================================================================================================
//
//===================================================================================================
function void fsys_scb_ioaiu_predictor::smi_cmd_msg_prediction_<%=pidx%>(input <%=_child_blkid[pidx]%>_smi_agent_pkg::smi_seq_item m_pkt, ref fsys_scb_txn fsys_txn_q[$]);
   //TODO: Spec question. How to figure out which CMDReq belongs to which AXI txn? OTT Entry implementation isn't an option all the time. 
   // How to implement when we have multiple match for same addr and ns.
   `undef LABEL
   `define LABEL "smi_cmd_msg_<%=_child_blkid[pidx]%>"
   int find_q[$];
   bit use_cache = <%=obj.AiuInfo[pidx].useCache%>;
   bit[($clog2(<%=AiuInfo[pidx].nNativeInterfacePorts%>)-1):0] core_id; 
   bit success = 0;
   fsys_scb_txn m_txn;
   int mem_region;
   int temp;
   <%=_child_blkid[pidx]%>_smi_agent_pkg::eMsgCMD cmd_type;
   $cast(cmd_type, m_pkt.smi_msg_type);
   <% if (obj.AiuInfo[pidx].nNativeInterfacePorts > 1) { %>
      core_id = m_pkt.smi_msg_id[(<%=_child_blkid[pidx]%>_smi_agent_pkg::WSMIMSGID-1) : (<%=_child_blkid[pidx]%>_smi_agent_pkg::WSMIMSGID-$clog2(<%=AiuInfo[pidx].nNativeInterfacePorts%>))];
   <% } %>
   //TODO: create functions for each match logic.
   case(cmd_type)
      <%=_child_blkid[pidx]%>_smi_agent_pkg::eCmdRdUnq,
      <%=_child_blkid[pidx]%>_smi_agent_pkg::eCmdRdNC,
      <%=_child_blkid[pidx]%>_smi_agent_pkg::eCmdRdNITC,
      <%=_child_blkid[pidx]%>_smi_agent_pkg::eCmdRdVld,
      <%=_child_blkid[pidx]%>_smi_agent_pkg::eCmdRdCln,
      <%=_child_blkid[pidx]%>_smi_agent_pkg::eCmdRdNShD, 
      <%=_child_blkid[pidx]%>_smi_agent_pkg::eCmdMkInv,
      <%=_child_blkid[pidx]%>_smi_agent_pkg::eCmdMkUnq,
      <%=_child_blkid[pidx]%>_smi_agent_pkg::eCmdClnInv,
      <%=_child_blkid[pidx]%>_smi_agent_pkg::eCmdClnVld,
      <%=_child_blkid[pidx]%>_smi_agent_pkg::eCmdClnUnq,
      <%=_child_blkid[pidx]%>_smi_agent_pkg::eCmdClnShdPer,
      <%=_child_blkid[pidx]%>_smi_agent_pkg::eCmdRdNITCClnInv,
      <%=_child_blkid[pidx]%>_smi_agent_pkg::eCmdRdNITCMkInv: 
   begin
      success = process_read_cmd_types_<%=pidx%>(m_pkt, fsys_txn_q);
      if (!success) begin
         `uvm_error(`LABEL, $sformatf(
            "FSYS_SCB: CMDReq packet didn't match any pending transactions. total matches='d%0d. %0s", 
            find_q.size(), m_pkt.convert2string()))
      end
   end //read commands
   <%=_child_blkid[pidx]%>_smi_agent_pkg::eCmdWrUnqFull,
   <%=_child_blkid[pidx]%>_smi_agent_pkg::eCmdWrUnqPtl,
   <%=_child_blkid[pidx]%>_smi_agent_pkg::eCmdWrNCPtl,
   <%=_child_blkid[pidx]%>_smi_agent_pkg::eCmdWrNCFull,
   <%=_child_blkid[pidx]%>_smi_agent_pkg::eCmdWrStshFull,
   <%=_child_blkid[pidx]%>_smi_agent_pkg::eCmdWrStshPtl,
   <%=_child_blkid[pidx]%>_smi_agent_pkg::eCmdLdCchShd,
   <%=_child_blkid[pidx]%>_smi_agent_pkg::eCmdLdCchUnq,
   <%=_child_blkid[pidx]%>_smi_agent_pkg::eCmdRdAtm,
   <%=_child_blkid[pidx]%>_smi_agent_pkg::eCmdWrAtm,
   <%=_child_blkid[pidx]%>_smi_agent_pkg::eCmdCompAtm,
   <%=_child_blkid[pidx]%>_smi_agent_pkg::eCmdSwAtm : 
   begin
      success = process_write_cmd_types_<%=pidx%>(m_pkt, fsys_txn_q);
      if (!success) begin
         find_q.delete();
         // This could be eviction
         // Evictions are always WCNCFull, but I saw a case where last txn of multi line was WRNCPtl and an eviction on same address happened with WRNCFull.
         // Scoreboard doesn't have a way to differentiate them yet. TODO: revisit when proxy cache model is integrated 
         if (use_cache == 1 && cmd_type inside {<%=_child_blkid[pidx]%>_smi_agent_pkg::eCmdWrNCFull,<%=_child_blkid[pidx]%>_smi_agent_pkg::eCmdWrNCPtl}) begin
            add_eviction_txn_<%=pidx%>(m_pkt, fsys_txn_q);
            success = 1;
         end
         if (!success) begin
            `uvm_error(`LABEL, $sformatf(
               "FSYS_SCB: CMDReq packet didn't match any pending transactions. total matches='d%0d. %0s", 
               find_q.size(), m_pkt.convert2string()))
         end // Not a match for proxy cache instances
      end // !success
   end // Write commands
   <%=_child_blkid[pidx]%>_smi_agent_pkg::eCmdDvmMsg:
   begin
      success = process_dvm_msg_<%=pidx%>(m_pkt, fsys_txn_q);
      if (!success) begin
         `uvm_error(`LABEL, $sformatf(
            "FSYS_SCB: CMDReq packet didn't match any pending transactions. %0s", 
            m_pkt.convert2string()))
      end
   end
   default:
   begin
      `uvm_error(`LABEL, $sformatf(
         "FSYS_SCB: CMDReq packet: Not Supported %0s", 
         m_pkt.convert2string()))
   end
   endcase
endfunction : smi_cmd_msg_prediction_<%=pidx%>

//====================================================================================================
//
//====================================================================================================
function bit fsys_scb_ioaiu_predictor::process_read_cmd_types_<%=pidx%>(ref <%=_child_blkid[pidx]%>_smi_agent_pkg::smi_seq_item m_pkt, ref fsys_scb_txn fsys_txn_q[$]);
   int find_q[$], find_q_cp[$];
   int temp;
   bit[64:0] temp_addr;
   bit use_cache = <%=obj.AiuInfo[pidx].useCache%>;
   <%=_child_blkid[pidx]%>_smi_agent_pkg::eMsgCMD cmd_type;
   bit[($clog2(<%=AiuInfo[pidx].nNativeInterfacePorts%>)-1):0] core_id;
   $cast(cmd_type, m_pkt.smi_msg_type);
   <% if (obj.AiuInfo[pidx].nNativeInterfacePorts > 1) { %>
      core_id = m_pkt.smi_msg_id[(<%=_child_blkid[pidx]%>_smi_agent_pkg::WSMIMSGID-1) : (<%=_child_blkid[pidx]%>_smi_agent_pkg::WSMIMSGID-$clog2(<%=AiuInfo[pidx].nNativeInterfacePorts%>))];
   <% } %>
   find_q = fsys_txn_q.find_index with (
               (item.source_funit_id == <%=obj.AiuInfo[pidx].FUnitId%>)
               && (item.m_axi_rd_addr_pkt_<%=pidx%> !== null
               <% if (obj.wSecurityAttribute > 0) { %>
                  && (item.smi_ns == m_pkt.smi_ns || item.register_txn == 1)
               <% } %>
               <% if (obj.Widths.Concerto.Ndp.Body.wPR > 0) { %>
               && (item.m_axi_rd_addr_pkt_<%=pidx%>.arprot[0] == m_pkt.smi_pr || item.register_txn == 1)
               <% } %>
               <% if (obj.Widths.Concerto.Ndp.Body.wQos > 0) { %>
               && (item.smi_qos == m_pkt.smi_qos || item.register_txn == 1)
               <% } %>
               //&& (!item.m_axi_rd_addr_pkt_<%=pidx%>.arcache[1] == m_pkt.smi_st || item.register_txn == 1)
               && ((item.m_axi_rd_addr_pkt_<%=pidx%>.araddr == m_pkt.smi_addr || (item.multi_cacheline_access == 1 && (m_pkt.smi_addr inside {item.exp_addr_q})))) 
                  //|| (item.next_smi_addr == m_pkt.smi_addr && item.multi_cacheline_access == 1))
               && (!(m_pkt.smi_addr inside {item.pcie_mode_smi_addr_q}))
               && ((item.mpf2_flowid_val == 1 && m_pkt.smi_mpf2_flowid == item.mpf2_flowid) || (item.mpf2_flowid_val == 0))
               //&& item.mpf2_flowid_val == m_pkt.smi_mpf2_flowid_valid 
               && (((item.is_coh == 0 || item.is_cmo_txn == 1) && (item.dest_funit_id == m_pkt.smi_targ_ncore_unit_id || item.multi_cacheline_access == 1))
                  || ((item.is_coh == 1 || item.is_cmo_txn == 1) && (item.dce_funit_id == m_pkt.smi_targ_ncore_unit_id || item.multi_cacheline_access == 1)))
               && item.source_funit_id == m_pkt.smi_src_ncore_unit_id)
               && item.ioaiu_core_id == core_id
               && (item.aiu_check_done == 0 || (use_cache == 1 && item.is_write == 1))
               && ((item.is_write == 1 && cmd_type inside {<%=_child_blkid[pidx]%>_smi_agent_pkg::eCmdRdUnq, <%=_child_blkid[pidx]%>_smi_agent_pkg::eCmdMkUnq}) || item.is_write == 0)
               && ((cmd_type inside {<%=_child_blkid[pidx]%>_smi_agent_pkg::eCmdRdUnq, <%=_child_blkid[pidx]%>_smi_agent_pkg::eCmdMkUnq}  && item.ace_command_type inside {"WRUNQ", "WRLNUNQ", "RDUNQ", "MKUNQ"})
                  || (!(cmd_type inside {<%=_child_blkid[pidx]%>_smi_agent_pkg::eCmdRdUnq, <%=_child_blkid[pidx]%>_smi_agent_pkg::eCmdMkUnq})))
               && item.exp_smi_cmd_pkts > 0);
   if (find_q.size() > 1) begin
      //CONC-14406
      //first try to find exact command match
      for (int i = find_q.size()-1; i >= 0; i--) begin
         if (cmd_type == ace_cmd_to_smi_cmd_<%=pidx%>(fsys_txn_q[find_q[i]].ace_command_type)) begin
            find_q_cp.push_back(find_q[i]);
         end
      end // for loop
      // If we find exact command match, use that txn as the match.
      // else, do relaxed match
      if (find_q_cp.size() == 1) begin
         find_q.delete();
         find_q.push_back(find_q_cp[0]);
      end else begin
         for (int i = find_q.size()-1; i >= 0; i--) begin
            //`uvm_info(`LABEL, $sformatf("FSYS_UID:%0d : Matching cmd_type=0x%0h with ACE converted type: 0x%0h. Ace command type: %0s", fsys_txn_q[find_q[i]].fsys_unique_txn_id, cmd_type, ace_cmd_to_smi_cmd_<%=pidx%>(fsys_txn_q[find_q[i]].ace_command_type), fsys_txn_q[find_q[i]].ace_command_type), UVM_NONE+50)
            if (cmd_type !== ace_cmd_to_smi_cmd_<%=pidx%>(fsys_txn_q[find_q[i]].ace_command_type)) begin
               if (cmd_type inside {<%=_child_blkid[pidx]%>_smi_agent_pkg::eCmdRdUnq, <%=_child_blkid[pidx]%>_smi_agent_pkg::eCmdMkUnq}) begin
                  if (!(fsys_txn_q[find_q[i]].ace_command_type inside {"WRUNQ", "WRLNUNQ", "RDUNQ", "MKUNQ"})) begin
                     find_q.delete(i);
                  end else if (cmd_type == <%=_child_blkid[pidx]%>_smi_agent_pkg::eCmdRdUnq && fsys_txn_q[find_q[i]].ace_command_type == "MKUNQ") begin
                     find_q.delete(i);
                  end
               end else if (cmd_type inside {<%=_child_blkid[pidx]%>_smi_agent_pkg::eCmdRdVld}) begin
                  if (!(fsys_txn_q[find_q[i]].ace_command_type inside {"RDONCE"}))
                     find_q.delete(i);
               end else begin
                  find_q.delete(i);
               end
            end
         end // foreach matched txn
      end
   end // if multiple match
   //If multiple txns have same AxID, CMDReqs are sent in order of txns (TODO: Confirm if this is true in NCore specs)
   if (find_q.size() >= 1) begin
      if (find_q.size() > 1) begin
         foreach(find_q[idx]) begin 
            fsys_txn_q[find_q[idx]].print_me();
            // setting these to work around this known issue so txns can match in any order
            fsys_txn_q[find_q[idx]].pcie_ordermode_wr_en = 1;
            fsys_txn_q[find_q[idx]].pcie_ordermode_rd_en = 1;
         end
         `uvm_warning(`LABEL, $sformatf(
            "Known issue: SMI read command packet has multiple matches(%0d) Picking oldest txn to make progress. %0s",
            find_q.size(), m_pkt.convert2string()))
      end // multiple matches
      fsys_txn_q[find_q[0]].pcie_mode_smi_addr_q.push_back(m_pkt.smi_addr);
      if (fsys_txn_q[find_q[0]].multi_cacheline_access) begin
         for (int y = fsys_txn_q[find_q[0]].exp_addr_q.size()-1; y >=0; y--) begin
            if (fsys_txn_q[find_q[0]].exp_addr_q[y] == m_pkt.smi_addr) begin
               fsys_txn_q[find_q[0]].exp_addr_q.delete(y);
            end
         end
      end
      fsys_txn_q[find_q[0]].save_ioaiu_cmd_req_<%=pidx%>(m_pkt);
      if(fsys_txn_q[find_q[0]].multi_cacheline_access) begin
         `uvm_info(`LABEL, $sformatf(
            "FSYS_UID:%0d SUB_ID:%0d : SMI command packet seen. Remaining CMDReqs:'d%0d %0s", 
            fsys_txn_q[find_q[0]].fsys_unique_txn_id, fsys_txn_q[find_q[0]].subid_cnt,
            fsys_txn_q[find_q[0]].exp_smi_cmd_pkts, m_pkt.convert2string()), UVM_NONE+50)
      end
      else begin
         `uvm_info(`LABEL, $sformatf(
            "FSYS_UID:%0d : SMI command packet seen. Remaining CMDReqs:'d%0d %0s", 
            fsys_txn_q[find_q[0]].fsys_unique_txn_id, fsys_txn_q[find_q[0]].exp_smi_cmd_pkts, 
            m_pkt.convert2string()), UVM_NONE+50)
      end
      if (!(fsys_txn_q[find_q[0]].ace_command_type inside {"CLNSHRD", "CLNSHRDPERSIST", "CLNINVL", "MKINVL", "CLNUNQ", "MKUNQ", "BARRIER"})) begin
         fsys_txn_q[find_q[0]].dtr_msg_id_q.push_back(m_pkt.smi_msg_id);
         fsys_txn_q[find_q[0]].dtr_addr_q.push_back(m_pkt.smi_addr);
      end
      if (fsys_txn_q[find_q[0]].aiu_check_done == 1) fsys_txn_q[find_q[0]].aiu_check_done = 0;
      //In case of eCmdMkUnq, no data is transferred to the requester
      if (cmd_type == <%=_child_blkid[pidx]%>_smi_agent_pkg::eCmdMkUnq) begin
         if (fsys_txn_q[find_q[0]].exp_smi_data_pkts > 0)
            fsys_txn_q[find_q[0]].exp_smi_data_pkts = fsys_txn_q[find_q[0]].exp_smi_data_pkts-1;
         if (fsys_txn_q[find_q[0]].multi_cacheline_access == 0
            && fsys_txn_q[find_q[0]].ace_command_type !== "MKUNQ") begin
            fsys_txn_q[find_q[0]].is_dataless_txn = 1;
         end
         if (fsys_txn_q[find_q[0]].ace_command_type inside {"WRUNQ"}) begin
            fsys_txn_q[find_q[0]].dataless_wrunq_q.push_back(1);
         end
         if (!(fsys_txn_q[find_q[0]].ace_command_type inside {"CLNSHRD", "CLNSHRDPERSIST", "CLNINVL", "MKINVL", "CLNUNQ", "MKUNQ", "BARRIER"})) begin
            temp = fsys_txn_q[find_q[0]].dtr_msg_id_q.pop_back();
            temp_addr = fsys_txn_q[find_q[0]].dtr_addr_q.pop_back();
         end
         fsys_txn_q[find_q[0]].mrd_possible_q.push_back(0);
      end else begin
         fsys_txn_q[find_q[0]].mrd_possible_q.push_back(1);
         fsys_txn_q[find_q[0]].dataless_wrunq_q.push_back(0);
      end
      //if (fsys_txn_q[find_q[0]].exp_smi_cmd_pkts == 0 && use_cache == 1) begin
      //   fsys_txn_q[find_q[0]].exp_smi_data_pkts = fsys_txn_q[find_q[0]].str_msg_id_q.size();
      //end
      if (fsys_txn_q[find_q[0]].exp_smi_cmd_pkts >= 0) begin
         fsys_txn_q[find_q[0]].next_smi_addr = {m_pkt.smi_addr[<%=obj.AiuInfo[pidx].wAddr%>-1:6],6'b0} + 'h40;
         if (fsys_txn_q[find_q[0]].m_axi_rd_addr_pkt_<%=pidx%>.arburst === <%=_child_blkid[pidx]%>_env_pkg::AXIWRAP) begin
            if (fsys_txn_q[find_q[0]].next_smi_addr >= fsys_txn_q[find_q[0]].m_upper_wrapped_boundary) begin
               fsys_txn_q[find_q[0]].next_smi_addr = fsys_txn_q[find_q[0]].m_lower_wrapped_boundary;
            end
         end
         if (fsys_txn_q[find_q[0]].exp_smi_cmd_pkts != 0) begin
            `uvm_info(`LABEL, $sformatf(
               "FSYS_UID:%0d : Next CMDReq Addr = 0x%0h", 
               fsys_txn_q[find_q[0]].fsys_unique_txn_id, 
               fsys_txn_q[find_q[0]].next_smi_addr), 
               UVM_NONE+50)
         end // if next packet expected
      end // if exp_smi_cmd_pkts > 0
      //Special case scnario for WRUNQ
      if (fsys_txn_q[find_q[0]].m_axi_wr_addr_pkt_<%=pidx%> !== null 
         && fsys_txn_q[find_q[0]].ace_command_type inside {"WRUNQ", "WRLNUNQ"}
         && (cmd_type == <%=_child_blkid[pidx]%>_smi_agent_pkg::eCmdRdUnq || cmd_type == <%=_child_blkid[pidx]%>_smi_agent_pkg::eCmdMkUnq)
         && fsys_txn_q[find_q[0]].exp_smi_cmd_pkts == 0) begin
         fsys_txn_q[find_q[0]].m_axi_rd_addr_pkt_<%=pidx%> = null;
       end
      return (1); // success
   end else begin
      return (0); // Fail
   end
endfunction : process_read_cmd_types_<%=pidx%>

//====================================================================================================
//
//====================================================================================================
function bit fsys_scb_ioaiu_predictor::process_write_cmd_types_<%=pidx%>(ref <%=_child_blkid[pidx]%>_smi_agent_pkg::smi_seq_item m_pkt, ref fsys_scb_txn fsys_txn_q[$]);
   int find_q[$];
   bit use_cache = <%=obj.AiuInfo[pidx].useCache%>;
   <%=_child_blkid[pidx]%>_smi_agent_pkg::eMsgCMD cmd_type;
   bit[($clog2(<%=AiuInfo[pidx].nNativeInterfacePorts%>)-1):0] core_id;
   $cast(cmd_type, m_pkt.smi_msg_type);
   <% if (obj.AiuInfo[pidx].nNativeInterfacePorts > 1) { %>
      core_id = m_pkt.smi_msg_id[(<%=_child_blkid[pidx]%>_smi_agent_pkg::WSMIMSGID-1) : (<%=_child_blkid[pidx]%>_smi_agent_pkg::WSMIMSGID-$clog2(<%=AiuInfo[pidx].nNativeInterfacePorts%>))];
   <% } %>
   $cast(cmd_type, m_pkt.smi_msg_type);

   //foreach(fsys_txn_q[idx]) begin
   //   if (fsys_txn_q[idx].m_axi_wr_addr_pkt_<%=pidx%> !== null)
   //   `uvm_info(`LABEL, $psprintf("FSYS_UID:%0d smi_ns=%0d, smi_pr=%0d, smi_qos=%0d, awaddr=0x%0h, multi_cacheline_access=%0d, addr inside exp_addr_q=%0d, addr inside pcie_mode_smi_addr_q=%0d, mpf2_flowid_val=%0d, is_stash_txn=%0d, is_coh=%0d, is_write=%0d, is_atomic_txn=%0d, aiu_check_done=%0d, exp_smi_cmd_pkts=%0d core_id=%0d, expected core_id=%0d", 
   //   fsys_txn_q[idx].fsys_unique_txn_id, 
   //   fsys_txn_q[idx].smi_ns, 
   //   fsys_txn_q[idx].m_axi_wr_addr_pkt_<%=pidx%>.awprot[0], 
   //   fsys_txn_q[idx].smi_qos, 
   //   fsys_txn_q[idx].m_axi_wr_addr_pkt_<%=pidx%>.awaddr, 
   //   fsys_txn_q[idx].multi_cacheline_access, 
   //   (m_pkt.smi_addr inside {fsys_txn_q[idx].exp_addr_q}), 
   //   (m_pkt.smi_addr inside {fsys_txn_q[idx].pcie_mode_smi_addr_q}), 
   //   fsys_txn_q[idx].mpf2_flowid_val, 
   //   fsys_txn_q[idx].is_stash_txn, 
   //   fsys_txn_q[idx].is_coh, 
   //   fsys_txn_q[idx].is_write, 
   //   fsys_txn_q[idx].is_atomic_txn, 
   //   fsys_txn_q[idx].aiu_check_done, 
   //   fsys_txn_q[idx].exp_smi_cmd_pkts,
   //   core_id,
   //   fsys_txn_q[idx].ioaiu_core_id), UVM_NONE+50)
   //end


   find_q = fsys_txn_q.find_index with (
               (item.source_funit_id == <%=obj.AiuInfo[pidx].FUnitId%>)
               && (item.m_axi_wr_addr_pkt_<%=pidx%> !== null
               <% if (obj.wSecurityAttribute > 0) { %>
                  && (item.smi_ns == m_pkt.smi_ns || item.register_txn == 1)
               <% } %>
               <% if (obj.Widths.Concerto.Ndp.Body.wPR > 0) { %>
               && (item.m_axi_wr_addr_pkt_<%=pidx%>.awprot[0] == m_pkt.smi_pr || item.register_txn == 1)
               <% } %>
               <% if (obj.Widths.Concerto.Ndp.Body.wQos > 0) { %>
               && (item.smi_qos == m_pkt.smi_qos || item.register_txn == 1)
               <% } %>
               <% if (obj.Widths.Concerto.Ndp.Body.wST > 0) { %>
               //&& (!item.m_axi_wr_addr_pkt_<%=pidx%>.awcache[1] == m_pkt.smi_st || item.register_txn == 1)
               <% } %>
                && ((item.m_axi_wr_addr_pkt_<%=pidx%>.awaddr == m_pkt.smi_addr || (item.multi_cacheline_access == 1 && (m_pkt.smi_addr inside {item.exp_addr_q}))))
               //&& ((item.m_axi_wr_addr_pkt_<%=pidx%>.awaddr == m_pkt.smi_addr && item.multi_cacheline_access == 0)
               //   || (item.next_smi_addr == m_pkt.smi_addr && item.multi_cacheline_access == 1))
               && (!(m_pkt.smi_addr inside {item.pcie_mode_smi_addr_q}))
               && ((item.mpf2_flowid_val == 1 && m_pkt.smi_mpf2_flowid == item.mpf2_flowid) || (item.mpf2_flowid_val == 0 || item.is_stash_txn == 1))
               //&& (item.mpf2_flowid_val == m_pkt.smi_mpf2_flowid_valid || item.is_stash_txn == 1)
               && (((item.is_coh == 0 || (item.is_atomic_txn == 1 && item.exp_smi_cmd_pkts == 1)) 
                     && (item.dest_funit_id == m_pkt.smi_targ_ncore_unit_id || item.multi_cacheline_access == 1))
                  || ((item.is_coh == 1 && (item.dce_funit_id == m_pkt.smi_targ_ncore_unit_id || item.multi_cacheline_access == 1))
                     && (item.is_atomic_txn == 0 || (item.is_atomic_txn == 1 && item.exp_smi_cmd_pkts == 2))))
               && item.source_funit_id == m_pkt.smi_src_ncore_unit_id)
               //aiu_check_done not set or a bufferable write, which may see bresp before CmdReqs
               && (item.aiu_check_done == 0 || (use_cache == 1 && item.is_write == 1 && item.m_axi_wr_addr_pkt_<%=pidx%>.awcache[0] == 1))
               && item.ioaiu_core_id == core_id
               && item.exp_smi_cmd_pkts > 0);
   //if (find_q.size() > 1) begin
      for (int i = find_q.size()-1; i >= 0; i--) begin
         //`uvm_info(`LABEL, $sformatf(
         //    "FSYS_UID:%0d : Matching cmd_type=0x%0h with ACE converted type: 0x%0h. Ace command type: %0s",
         //    fsys_txn_q[find_q[i]].fsys_unique_txn_id, cmd_type, 
         //    ace_cmd_to_smi_cmd_<%=pidx%>(fsys_txn_q[find_q[i]].ace_command_type), 
         //    fsys_txn_q[find_q[i]].ace_command_type), UVM_NONE+50)
         if (cmd_type !== ace_cmd_to_smi_cmd_<%=pidx%>(fsys_txn_q[find_q[i]].ace_command_type)) begin
            if (fsys_txn_q[find_q[i]].ace_command_type inside{"WRUNQ", "WRLNUNQ"}) begin
               if (!(cmd_type inside {<%=_child_blkid[pidx]%>_smi_agent_pkg::eCmdWrUnqFull, <%=_child_blkid[pidx]%>_smi_agent_pkg::eCmdWrUnqPtl}))
                  find_q.delete(i);
            end else if (fsys_txn_q[find_q[i]].ace_command_type inside {"WRNOSNP", "WRCLN", "WRBK", "WREVCT"}) begin
               if (cmd_type !== <%=_child_blkid[pidx]%>_smi_agent_pkg::eCmdWrNCPtl && cmd_type !== <%=_child_blkid[pidx]%>_smi_agent_pkg::eCmdWrNCFull) 
                  find_q.delete(i);
            end else begin
               find_q.delete(i);
            end
         end
      end
   //end
   //If multiple txns have same Addr & NS, CMDReqs are sent in order of txns (Confirm if this is true in NCore specs)
   if (find_q.size() >= 1) begin
      if (find_q.size() > 1) begin
         foreach(find_q[idx]) begin 
            fsys_txn_q[find_q[idx]].print_me();
            // setting these to work around this known issue so txns can match in any order
            fsys_txn_q[find_q[idx]].pcie_ordermode_wr_en = 1;
            fsys_txn_q[find_q[idx]].pcie_ordermode_rd_en = 1;
         end
         `uvm_warning(`LABEL, $sformatf(
            "Known issue: SMI write command packet has multiple matches(%0d) Picking oldest txn to make progress. %0s",
            find_q.size(), m_pkt.convert2string()))
      end // Multiple matches
      if (fsys_txn_q[find_q[0]].is_atomic_txn == 0) begin
         fsys_txn_q[find_q[0]].pcie_mode_smi_addr_q.push_back(m_pkt.smi_addr);
      end
      if (fsys_txn_q[find_q[0]].multi_cacheline_access) begin
         for (int y = fsys_txn_q[find_q[0]].exp_addr_q.size()-1; y >=0; y--) begin
            if (fsys_txn_q[find_q[0]].exp_addr_q[y] == m_pkt.smi_addr) begin
               fsys_txn_q[find_q[0]].exp_addr_q.delete(y);
               break;
            end
         end
      end
      fsys_txn_q[find_q[0]].save_ioaiu_cmd_req_<%=pidx%>(m_pkt);
      if(fsys_txn_q[find_q[0]].multi_cacheline_access) begin
         `uvm_info(`LABEL, $sformatf(
            "FSYS_UID:%0d SUB_ID:%0d : SMI command packet seen. Remaining CMDReqs:'d%0d %0s",
            fsys_txn_q[find_q[0]].fsys_unique_txn_id, fsys_txn_q[find_q[0]].subid_cnt,
            fsys_txn_q[find_q[0]].exp_smi_cmd_pkts, 
            m_pkt.convert2string()), UVM_NONE+50)
      end
      else begin 
         `uvm_info(`LABEL, $sformatf(
            "FSYS_UID:%0d : SMI command packet seen. Remaining CMDReqs:'d%0d %0s",
            fsys_txn_q[find_q[0]].fsys_unique_txn_id, fsys_txn_q[find_q[0]].exp_smi_cmd_pkts,
            m_pkt.convert2string()), UVM_NONE+50)
      end
      if (fsys_txn_q[find_q[0]].aiu_check_done == 1) fsys_txn_q[find_q[0]].aiu_check_done = 0;
      if (cmd_type == <%=_child_blkid[pidx]%>_smi_agent_pkg::eCmdLdCchShd || cmd_type == <%=_child_blkid[pidx]%>_smi_agent_pkg::eCmdLdCchUnq) begin
         fsys_txn_q[find_q[0]].mrd_possible_q.push_back(1);
         fsys_txn_q[find_q[0]].exp_smi_data_pkts = 0;
         fsys_txn_q[find_q[0]].smi_stash_valid = m_pkt.smi_mpf1_stash_valid; 
      end else begin 
         fsys_txn_q[find_q[0]].mrd_possible_q.push_back(0);
      end
      if (fsys_txn_q[find_q[0]].is_stash_txn == 1) begin
         fsys_txn_q[find_q[0]].smi_stash_nid = m_pkt.smi_mpf1_stash_nid;
         fsys_txn_q[find_q[0]].smi_stash_lpid = m_pkt.smi_mpf2_stash_lpid;
      end
      if (fsys_txn_q[find_q[0]].is_atomic_txn == 1
         && fsys_txn_q[find_q[0]].ace_command_type !== "ATMSTR") begin
            if (fsys_txn_q[find_q[0]].dtr_msg_id_q.size() == 0) begin
               fsys_txn_q[find_q[0]].dtr_msg_id_q.push_back(m_pkt.smi_msg_id);
               fsys_txn_q[find_q[0]].dtr_addr_q.push_back(m_pkt.smi_addr);
            end
      end
      fsys_txn_q[find_q[0]].dataless_wrunq_q.push_back(0);
      //Special case scnario for WRUNQ
      if (fsys_txn_q[find_q[0]].m_axi_rd_addr_pkt_<%=pidx%> !== null 
         && fsys_txn_q[find_q[0]].ace_command_type inside {"WRUNQ", "WRLNUNQ"}
         && (cmd_type == <%=_child_blkid[pidx]%>_smi_agent_pkg::eCmdWrUnqFull || cmd_type == <%=_child_blkid[pidx]%>_smi_agent_pkg::eCmdWrUnqPtl)) begin
         if (fsys_txn_q[find_q[0]].multi_cacheline_access == 0) begin
            fsys_txn_q[find_q[0]].m_axi_rd_addr_pkt_<%=pidx%> = null;
            fsys_txn_q[find_q[0]].is_read = 0;
         end
      end
      //if (fsys_txn_q[find_q[0]].exp_smi_cmd_pkts == 0 && use_cache == 1) begin
      //   fsys_txn_q[find_q[0]].exp_smi_data_pkts = fsys_txn_q[find_q[0]].str_msg_id_q.size();
      //end
      if (fsys_txn_q[find_q[0]].exp_smi_cmd_pkts >= 0 && fsys_txn_q[find_q[0]].is_atomic_txn == 0) begin
         fsys_txn_q[find_q[0]].next_smi_addr = {m_pkt.smi_addr[<%=obj.AiuInfo[pidx].wAddr%>-1:6],6'b0} + 'h40;
         if (fsys_txn_q[find_q[0]].m_axi_wr_addr_pkt_<%=pidx%>.awburst === <%=_child_blkid[pidx]%>_env_pkg::AXIWRAP) begin
            if (fsys_txn_q[find_q[0]].next_smi_addr >= fsys_txn_q[find_q[0]].m_upper_wrapped_boundary) begin
               fsys_txn_q[find_q[0]].next_smi_addr = fsys_txn_q[find_q[0]].m_lower_wrapped_boundary;
            end
         end
         if (fsys_txn_q[find_q[0]].exp_smi_cmd_pkts != 0) begin
            `uvm_info(`LABEL, $sformatf(
               "FSYS_UID:%0d : Next CMDReq Addr = 0x%0h", 
               fsys_txn_q[find_q[0]].fsys_unique_txn_id, 
               fsys_txn_q[find_q[0]].next_smi_addr), UVM_NONE+50)
         end // if next packet expected
      end // if exp_smi_cmd_pkts > 0
      return(1);
   end else begin
      return(0);
   end
endfunction : process_write_cmd_types_<%=pidx%>

//====================================================================================================
//
//====================================================================================================
function void fsys_scb_ioaiu_predictor::add_eviction_txn_<%=pidx%>(ref <%=_child_blkid[pidx]%>_smi_agent_pkg::smi_seq_item m_pkt, ref fsys_scb_txn fsys_txn_q[$]);
   fsys_scb_txn m_txn;
   int mem_region;
   int idx;
   m_txn = fsys_scb_txn::type_id::create("m_txn");
   m_txn.fsys_unique_txn_id = fsys_scoreboard::get_next_unique_txn_id();
   m_txn.smi_addr = m_pkt.smi_addr;
   m_txn.smi_addr_val = 1;
   m_txn.is_write = 1;
   m_txn.dest_funit_id = addrMgrConst::map_addr2dmi_or_dii(m_pkt.smi_addr, mem_region);
   m_txn.dce_funit_id = addrMgrConst::map_addr2dce(m_pkt.smi_addr);
   m_txn.dmi_bound = 1;
   m_txn.is_coh = 0;
   m_txn.exp_smi_cmd_pkts = 0;
   m_txn.exp_smi_data_pkts = 1;
   m_txn.axi_data_seen = 1; //There will not be an AXI write data since this is cache eviction
   m_txn.save_ioaiu_cmd_req_<%=pidx%>(m_pkt);
   m_txn.mrd_possible_q.push_back(0);
   m_txn.dataless_wrunq_q.push_back(0);
   m_txn.snpreq_ns_q.push_back(m_pkt.smi_ns);
   m_txn.smi_ns = m_pkt.smi_ns;
   //m_txn.dtr_msg_id_q.push_back(m_pkt.smi_msg_id);
   m_txn.source_funit_id = <%=obj.AiuInfo[pidx].FUnitId%>;
   `uvm_info(`LABEL, $sformatf(
      "FSYS_UID:%0d : Setting aiu_check_done", 
      m_txn.fsys_unique_txn_id), UVM_NONE+50)
   m_txn.aiu_check_done = 1;
   if(m_txn.multi_cacheline_access) begin
      `uvm_info(`LABEL, $sformatf(
         "FSYS_UID:%0d SUB_ID:%0d : New Eviction transaction. %0s", 
         m_txn.fsys_unique_txn_id, m_txn.subid_cnt, m_pkt.convert2string()), 
         UVM_NONE+50)
   end
   else begin
      `uvm_info(`LABEL, $sformatf(
         "FSYS_UID:%0d : New Eviction transaction. %0s", 
         m_txn.fsys_unique_txn_id, m_pkt.convert2string()), 
         UVM_NONE+50)
   end
   fsys_txn_q.push_back(m_txn);
   idx = fsys_txn_q.size() - 1;
   <% if(obj.AiuInfo[pidx].useCache == 1) {%>
                  if(m_en_coh_check) begin
                      package_and_send_coh_checker_<%=pidx%>(fsys_txn_q[idx],null,m_pkt,0,1,0,0);
                  end
  <% } %>
endfunction : add_eviction_txn_<%=pidx%> 

//====================================================================================================
//
//====================================================================================================
function bit fsys_scb_ioaiu_predictor::process_dvm_msg_<%=pidx%>(ref <%=_child_blkid[pidx]%>_smi_agent_pkg::smi_seq_item m_pkt, ref fsys_scb_txn fsys_txn_q[$]);
   int find_q[$];
   int temp;
   <%=_child_blkid[pidx]%>_smi_agent_pkg::eMsgCMD cmd_type;
   bit[($clog2(<%=AiuInfo[pidx].nNativeInterfacePorts%>)-1):0] core_id;
   $cast(cmd_type, m_pkt.smi_msg_type);
   <% if (obj.AiuInfo[pidx].nNativeInterfacePorts > 1) { %>
      core_id = m_pkt.smi_msg_id[(<%=_child_blkid[pidx]%>_smi_agent_pkg::WSMIMSGID-1) : (<%=_child_blkid[pidx]%>_smi_agent_pkg::WSMIMSGID-$clog2(<%=AiuInfo[pidx].nNativeInterfacePorts%>))];
   <% } %>
   find_q = fsys_txn_q.find_index with (
               item.source_funit_id == <%=obj.AiuInfo[pidx].FUnitId%>
               && item.is_dvm == 1
               && item.m_axi_rd_addr_pkt_<%=pidx%> !== null
               && item.ace_command_type == "DVMMSG"
               //TODO: Why is addr diff & how to predict
               //&& item.m_axi_rd_addr_pkt_<%=pidx%>.araddr == m_pkt.smi_addr  
               && item.source_funit_id == m_pkt.smi_src_ncore_unit_id
               && item.dest_funit_id == m_pkt.smi_targ_ncore_unit_id
               && item.ioaiu_core_id == core_id
               && item.exp_smi_cmd_pkts > 0);
   if (find_q.size() >= 1) begin
      fsys_txn_q[find_q[0]].save_ioaiu_cmd_req_<%=pidx%>(m_pkt);
      if(fsys_txn_q[find_q[0]].multi_cacheline_access) begin
         `uvm_info(`LABEL, $sformatf(
            "FSYS_UID:%0d SUB_ID:%0d : SMI command packet seen. Remaining cmd_req=%0d. %0s", 
            fsys_txn_q[find_q[0]].fsys_unique_txn_id, fsys_txn_q[find_q[0]].subid_cnt,
            (fsys_txn_q[find_q[0]].exp_smi_cmd_pkts - 1),
            m_pkt.convert2string()), UVM_NONE+50)
      end
      else begin 
         `uvm_info(`LABEL, $sformatf(
            "FSYS_UID:%0d : SMI command packet seen. Remaining cmd_req=%0d. %0s", 
            fsys_txn_q[find_q[0]].fsys_unique_txn_id, (fsys_txn_q[find_q[0]].exp_smi_cmd_pkts - 1),
            m_pkt.convert2string()), UVM_NONE+50)
      end
      return (1); // success
   end else begin
      return (0); // Fail
   end
endfunction : process_dvm_msg_<%=pidx%>

//====================================================================================================
//
//====================================================================================================
function void fsys_scb_ioaiu_predictor::smi_str_prediction_<%=pidx%>(input <%=_child_blkid[pidx]%>_smi_agent_pkg::smi_seq_item m_pkt, ref fsys_scb_txn fsys_txn_q[$]);
   `undef LABEL
   `define LABEL "smi_str_msg_<%=_child_blkid[pidx]%>"
   bit match_found = 0;
   int dce_idx = 0;
   foreach(fsys_txn_q[idx]) begin
      if (fsys_txn_q[idx].str_msg_id_q.size() > 0) begin
         foreach(fsys_txn_q[idx].str_msg_id_q[i]) begin
            if ((fsys_txn_q[idx].source_funit_id == <%=obj.AiuInfo[pidx].FUnitId%>)
               && fsys_txn_q[idx].str_msg_id_q[i] == m_pkt.smi_rmsg_id
               && fsys_txn_q[idx].str_unit_id_q[i] == m_pkt.smi_targ_ncore_unit_id) 
            begin
               if(fsys_txn_q[idx].multi_cacheline_access) begin
                  `uvm_info(`LABEL, $sformatf(
                     "FSYS_UID:%0d SUB_ID:%0d : SMI STR packet seen. %0s", 
                     fsys_txn_q[idx].fsys_unique_txn_id, fsys_txn_q[idx].subid_q[i],
                     m_pkt.convert2string()), UVM_NONE+50)
               end
               else begin
                  `uvm_info(`LABEL, $sformatf(
                     "FSYS_UID:%0d : SMI STR packet seen. %0s", 
                     fsys_txn_q[idx].fsys_unique_txn_id, m_pkt.convert2string()), UVM_NONE+50)
               end
               dce_idx = (fsys_txn_q[idx].dce_queue_idx[i] == -1) ? i : fsys_txn_q[idx].dce_queue_idx[i];
               fsys_txn_q[idx].update_time_accessed("str_req_aiu","<%=_child_blkid[pidx]%>");
               fsys_txn_q[idx].str_msg_id_q[i] = -1;
               fsys_txn_q[idx].aiu_str_cnt = fsys_txn_q[idx].aiu_str_cnt + 1;
               if (fsys_txn_q[idx].snpreq_cnt_q[dce_idx] == 0 && fsys_txn_q[idx].is_stash_txn == 0) begin
                  fsys_txn_q[idx].snpreq_msg_id_q[dce_idx] = -1;
               end

               <% if( obj.AiuInfo[pidx].useCache == 1 ){ %>
                  if(m_en_coh_check) begin
                     if (fsys_txn_q[idx].is_write == 1 && fsys_txn_q[idx].mrd_possible_q[i] == 0) begin
                        package_and_send_coh_checker_<%=pidx%>(fsys_txn_q[idx],null,null,0,1,0,i);
                     end
                  end
               <% } %>
               <% if((obj.AiuInfo[pidx].fnNativeInterface == 'ACE5')||(obj.AiuInfo[pidx].fnNativeInterface == 'ACE')){ %>
                  if(m_en_coh_check) begin
                     if (fsys_txn_q[idx].is_write == 1 && fsys_txn_q[idx].mrd_possible_q[i] == 0) begin
                        package_and_send_coh_checker_<%=pidx%>(fsys_txn_q[idx],null,0,0,0,1,0,i);
                     end
                  end
               <% } %>
               if ((fsys_txn_q[idx].exp_smi_data_pkts == 0 
                     || (fsys_txn_q[idx].exp_smi_data_pkts == fsys_txn_q[idx].exp_smi_cmd_pkts 
                         && fsys_txn_q[idx].exp_smi_cmd_pkts !== 0 && fsys_txn_q[idx].cmdreq_skip == 1
                         && fsys_txn_q[idx].next_smi_addr > fsys_txn_q[idx].last_smi_addr))
                  && fsys_txn_q[idx].axi_data_seen == 1
                  && (fsys_txn_q[idx].is_write == 0 || (fsys_txn_q[idx].is_write == 1 && fsys_txn_q[idx].axi_write_resp_seen == 1))
                  && fsys_txn_q[idx].aiu_str_cnt == fsys_txn_q[idx].str_msg_id_q.size()) begin
                  `uvm_info(`LABEL, $sformatf(
                     "FSYS_UID:%0d : Setting aiu_check_done", 
                     fsys_txn_q[idx].fsys_unique_txn_id), UVM_NONE+50)
                  fsys_txn_q[idx].aiu_check_done = 1;
               end else if (fsys_txn_q[idx].is_write == 1 
                  && fsys_txn_q[idx].is_read == 0
                  && fsys_txn_q[idx].is_atomic_txn == 0
                  && fsys_txn_q[idx].exp_smi_data_pkts !== 0 
                  && fsys_txn_q[idx].axi_data_seen == 1 
                  && (fsys_txn_q[idx].is_write == 0 || (fsys_txn_q[idx].is_write == 1 && fsys_txn_q[idx].axi_write_resp_seen == 1))
                  && fsys_txn_q[idx].stash_accept == 0
                  && fsys_txn_q[idx].aiu_str_cnt == (fsys_txn_q[idx].str_msg_id_q.size() + fsys_txn_q[idx].exp_smi_cmd_pkts)) begin
                  `uvm_info(`LABEL, $sformatf(
                     "FSYS_UID:%0d : Setting aiu_check_done", 
                     fsys_txn_q[idx].fsys_unique_txn_id), UVM_NONE+50)
                  fsys_txn_q[idx].aiu_check_done = 1;
               end
               if (fsys_txn_q[idx].is_dvm == 1 && fsys_txn_q[idx].axi_data_seen == 1
                     && fsys_txn_q[idx].aiu_str_cnt == fsys_txn_q[idx].str_msg_id_q.size()) begin
                  `uvm_info(`LABEL, $sformatf(
                     "FSYS_UID:%0d : Setting aiu_check_done", 
                     fsys_txn_q[idx].fsys_unique_txn_id), UVM_NONE+50)
                  fsys_txn_q[idx].aiu_check_done = 1;
                  if (fsys_txn_q[idx].snpreq_cnt_q[0] == 0 && fsys_txn_q[idx].snpreq_cnt_q[1] == 0
                     && fsys_txn_q[idx].aiu_check_done == 1 
                     && (fsys_txn_q[idx].is_write == 0 || (fsys_txn_q[idx].is_write == 1 && fsys_txn_q[idx].axi_write_resp_seen == 1))
                     && fsys_txn_q[idx].dvm_complete_exp == 0 && fsys_txn_q[idx].dvm_complete_resp_exp == 0
                     && fsys_txn_q[idx].ac_dvmcmpl_exp == 0 && fsys_txn_q[idx].ac_dvmcmpl_resp_exp == 0) begin
                     //Delete from queue if all pkts related to this DVM txn are done
                     check_flags_and_delete_txn(`LABEL, idx, fsys_txn_q, 1, `__LINE__);
                     return;
                  end
               end
               else if (fsys_txn_q[idx].is_dataless_txn == 1) begin //this is always set for non multiline txn
                  if (fsys_txn_q[idx].is_stash_txn == 1
                      && (fsys_txn_q[idx].stash_accept == 0 
                        || (fsys_txn_q[idx].stash_accept == 1 && fsys_txn_q[idx].exp_chi_data_flits == 0))) begin
                     fsys_txn_q[idx].only_waiting_for_mrd = 1;
                  end
                  if ((fsys_txn_q[idx].rbrreq_seen_q[0] == 0 || fsys_txn_q[idx].rbrreq_seen_q[0] > 1) 
                       && (fsys_txn_q[idx].mrdreq_seen_q[0] == 0 || fsys_txn_q[idx].mrdreq_seen_q[0] == 2)
                       && ((fsys_txn_q[idx].is_stash_txn == 1 
                            && (fsys_txn_q[idx].rbrreq_seen_q[0] !== 0 
                                || fsys_txn_q[idx].mrdreq_seen_q[0] !== 0 
                                || fsys_txn_q[idx].snprsp_cnt_q[0] !== 0))
                            || (fsys_txn_q[idx].is_stash_txn == 0))
                       && fsys_txn_q[idx].exp_smi_data_pkts == 0
                       && fsys_txn_q[idx].axi_write_resp_seen == 1)
                  begin
                     check_flags_and_delete_txn(`LABEL, idx, fsys_txn_q, 1, `__LINE__);
                  end else if (fsys_txn_q[idx].exp_smi_data_pkts == 0 && fsys_txn_q[idx].axi_write_resp_seen == 1)begin //This is dataless, but there could be stash_accept
                     `uvm_info(`LABEL, $sformatf("FSYS_UID:%0d : Setting aiu_check_done", 
                        fsys_txn_q[idx].fsys_unique_txn_id), UVM_NONE+50)
                     fsys_txn_q[idx].aiu_check_done = 1;
                     if (fsys_txn_q[idx].rbrreq_seen_q[i] == 0) begin
                        fsys_txn_q[idx].rbrreq_seen_q[i] = 4;
                     end
                  end else begin
                     if (fsys_txn_q[idx].rbrreq_seen_q[i] == 0) begin
                        fsys_txn_q[idx].rbrreq_seen_q[i] = 4;
                     end
                  end
               end // is_dataless_txn
               //We sometimes see STR as last packet in cases of coh read where data gets forwarded as a result of SNP.
               else if (fsys_txn_q[idx].is_read == 1) begin
                  //if (fsys_txn_q[idx].rbuse_seen == 1) begin
                  //   fsys_txn_q[idx].dmi_check_done = 1;
                  //end
                  if (fsys_txn_q[idx].exp_smi_data_pkts == 0 && fsys_txn_q[idx].dmi_check_done == 0
                     && (fsys_txn_q[idx].rbrreq_seen_q[dce_idx] == 0 || fsys_txn_q[idx].rbrreq_seen_q[dce_idx] > 1)
                     && fsys_txn_q[idx].rbuse_count == fsys_txn_q[idx].rbrsvd_count) begin
                     fsys_txn_q[idx].dmi_check_done = 1;
                  end
                  if (fsys_txn_q[idx].rbuse_count == fsys_txn_q[idx].rbrsvd_count && fsys_txn_q[idx].snpreq_cnt_q[dce_idx] == 0) begin
                     fsys_txn_q[idx].dce_check_done = 1;
                  end
                  if (fsys_txn_q[idx].rbrreq_seen_q[dce_idx] == 0 && (fsys_txn_q[idx].dataless_wrunq_q[i] == 1 || fsys_txn_q[idx].is_write == 0)) begin
                     fsys_txn_q[idx].rbrreq_seen_q[dce_idx] = 4;
                  end
                  if(!$test$plusargs("print_latency_delay"))check_flags_and_delete_txn(`LABEL, idx, fsys_txn_q, 0, `__LINE__);
               end // is_read == 1
               else begin
                  if (fsys_txn_q[idx].rbrreq_seen_q[dce_idx] == 0 && fsys_txn_q[idx].dataless_wrunq_q[i] == 1) begin
                     fsys_txn_q[idx].rbrreq_seen_q[dce_idx] = 4;
                  end
               end
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

//===================================================================================================
//
//===================================================================================================
function void fsys_scb_ioaiu_predictor::smi_dtw_prediction_<%=pidx%>(input <%=_child_blkid[pidx]%>_smi_agent_pkg::smi_seq_item m_pkt, ref fsys_scb_txn fsys_txn_q[$]);
 // Only use with print_latency_delay
   int find_q[$];
   if($test$plusargs("print_latency_delay")) begin:_print_latency
   find_q = fsys_txn_q.find_index with (
                   m_pkt.smi_rbid inside {item.rbid_q} // link DTW to STR (noncoh) with RBID
                  && item.source_funit_id == <%=obj.AiuInfo[pidx].FUnitId%> 
                 );
   if (find_q.size()>0) begin
        fsys_txn_q[find_q[0]].dtwrsp_rmsg_id_q.push_back(m_pkt.smi_msg_id);
        fsys_txn_q[find_q[0]].update_time_accessed("dtw_req_aiu","<%=_child_blkid[pidx]%>");
      end
   end:_print_latency
endfunction : smi_dtw_prediction_<%=pidx%>

function void fsys_scb_ioaiu_predictor::smi_dtr_prediction_<%=pidx%>(input <%=_child_blkid[pidx]%>_smi_agent_pkg::smi_seq_item m_pkt, ref fsys_scb_txn fsys_txn_q[$]);
   `undef LABEL
   `define LABEL "smi_dtr_msg_<%=_child_blkid[pidx]%>"
   int match_found = 0;
   bit use_cache = <%=obj.AiuInfo[pidx].useCache%>;
   bit[63:0] snp_cacheline_addr;
   foreach(fsys_txn_q[idx]) begin
      if ((fsys_txn_q[idx].is_read == 1 && fsys_txn_q[idx].dtr_msg_id_q.size() > 0) 
          || (fsys_txn_q[idx].is_stash_txn == 1) 
          || (fsys_txn_q[idx].is_atomic_txn == 1 && fsys_txn_q[idx].dtr_msg_id_q.size() > 0)) begin
         if (fsys_txn_q[idx].is_stash_txn == 1 && fsys_txn_q[idx].stash_accept == 1 && fsys_txn_q[idx].dtr_msg_id_q.size() == 0) begin
            fsys_txn_q[idx].dtr_msg_id_q.push_back(-1);
            fsys_txn_q[idx].dtr_addr_q.push_back(-1);
         end
         foreach (fsys_txn_q[idx].dtr_msg_id_q[i]) begin
            `uvm_info(`LABEL, $sformatf(
               "FSYS_UID:%0d : dtr_msg_id_q[%0d]=0x%0h", 
               fsys_txn_q[idx].fsys_unique_txn_id, i, 
               fsys_txn_q[idx].dtr_msg_id_q[i]), UVM_DEBUG)
            if ((fsys_txn_q[idx].source_funit_id == <%=obj.AiuInfo[pidx].FUnitId%>
                  || (fsys_txn_q[idx].is_stash_txn == 1 && fsys_txn_q[idx].stash_accept == 1 && fsys_txn_q[idx].smi_stash_nid == <%=obj.AiuInfo[pidx].FUnitId%>))
               && (fsys_txn_q[idx].source_funit_id == m_pkt.smi_targ_ncore_unit_id 
                  || fsys_txn_q[idx].is_stash_txn == 1
                  || (fsys_txn_q[idx].is_stash_txn == 1 && fsys_txn_q[idx].source_funit_id == m_pkt.smi_src_ncore_unit_id))
                && ((fsys_txn_q[idx].dtr_msg_id_q[i] == m_pkt.smi_rmsg_id && fsys_txn_q[idx].is_stash_txn == 0)
                  || ((fsys_txn_q[idx].smi_stash_nid == <%=obj.AiuInfo[pidx].FUnitId%> 
                        || (fsys_txn_q[idx].source_funit_id == m_pkt.smi_src_ncore_unit_id && fsys_txn_q[idx].smi_stash_nid == m_pkt.smi_targ_ncore_unit_id))
                     && fsys_txn_q[idx].stash_accept == 1 && fsys_txn_q[idx].smi_stash_dtr_msg_id == m_pkt.smi_rmsg_id))) begin
                  `uvm_info(`LABEL, $sformatf(
                     "FSYS_UID:%0d : SMI DTR packet %0s seen. Remaining DTRs; 'd%0d. %0s",
                     fsys_txn_q[idx].fsys_unique_txn_id, 
                     (fsys_txn_q[idx].source_funit_id == m_pkt.smi_src_ncore_unit_id) ? "(Stash outgoing)" : "",
                     (fsys_txn_q[idx].exp_smi_data_pkts-1), m_pkt.convert2string()), UVM_NONE+50)
                  fsys_txn_q[idx].update_time_accessed("dtr_req_aiu","<%=_child_blkid[pidx]%>");
                  if (!fsys_txn_q[idx].multi_cacheline_access) begin
                     fsys_txn_q[idx].smi_msg_order_q.push_back(smi_msgs_t'(fsys_coverage_pkg::DTR_REQ));
                  end
                  //fsys_txn_q[idx].smi_targ_ncore_unit_id = m_pkt.smi_src_ncore_unit_id;
                  if (fsys_txn_q[idx].source_funit_id == m_pkt.smi_targ_ncore_unit_id) begin
                     fsys_txn_q[idx].exp_smi_data_pkts = fsys_txn_q[idx].exp_smi_data_pkts - 1;
                  end 
                  if (fsys_txn_q[idx].exp_smi_data_pkts < 0) begin
                     `uvm_error(`LABEL, $sformatf(
                        "FSYS_UID:%0d : Logged more SMI data than expected for this txn", 
                        fsys_txn_q[idx].fsys_unique_txn_id))
                  end
   <% if(obj.AiuInfo[pidx].useCache == 1) {%>
                  if(m_en_coh_check) begin
                      package_and_send_coh_checker_<%=pidx%>(fsys_txn_q[idx],null,m_pkt,1,0,0,i);
                  end
  <% } %>
                  fsys_txn_q[idx].dtr_msg_id_q.delete(i);
                  fsys_txn_q[idx].dtr_addr_q.delete(i);
                  match_found = 1;
                  
                  if (fsys_txn_q[idx].delete_at_dtr == 1) begin
                     if (fsys_txn_q[idx].exp_smi_data_pkts == 0 && fsys_txn_q[idx].aiu_str_cnt == fsys_txn_q[idx].str_msg_id_q.size()
                        && fsys_txn_q[idx].axi_data_seen == 1
                        && (fsys_txn_q[idx].is_write == 0 || (fsys_txn_q[idx].is_write == 1 && fsys_txn_q[idx].axi_write_resp_seen == 1))) begin 
                        `uvm_info(`LABEL, $sformatf(
                           "FSYS_UID:%0d : Setting aiu_check_done", 
                           fsys_txn_q[idx].fsys_unique_txn_id), UVM_NONE+50)
                        fsys_txn_q[idx].aiu_check_done = 1;
                        //MEM_CONSISTENCY
                        if(m_en_mem_check) begin
                           if (fsys_txn_q[idx].is_cmo_txn == 0 
                              && fsys_txn_q[idx].m_axi_rd_addr_pkt_<%=pidx%> !== null
                              && fsys_txn_q[idx].register_txn == 0) begin
                              //fsys_txn_q[idx].save_ioaiu_rdtxn_data_<%=pidx%>(m_packet);
                              //TODO: Skip datacheck for dataless txns
                              mem_checker.read_on_native_if(.addr(fsys_txn_q[idx].ioaiu_cacheline_addr), 
                                                      .rdata(fsys_txn_q[idx].ioaiu_txn_data), 
                                                      .byte_en(fsys_txn_q[idx].ioaiu_byte_en), 
                                                      .txn_id(fsys_txn_q[idx].m_axi_rd_addr_pkt_<%=pidx%>.arid),
                                                      .ns(fsys_txn_q[idx].m_axi_rd_addr_pkt_<%=pidx%>.arprot[1]),
                                                      .is_coh(fsys_txn_q[idx].is_coh),
                                                      .is_chi(0),
                                                      .funit_id(<%=obj.AiuInfo[pidx].FUnitId%>), 
                                                      .core_id(<%=i%>),
                                                      .read_issue_time(fsys_txn_q[idx].m_axi_rd_addr_pkt_<%=pidx%>.t_pkt_seen_on_intf),
                                                      .cache_unit((<%=obj.AiuInfo[pidx].useCache%> || fsys_txn_q[idx].snoop_data_fwded)),
                                                      .fsys_txn_q(fsys_txn_q), 
                                                      .fsys_index(idx));
                           end else if (fsys_txn_q[idx].is_write == 1 && fsys_txn_q[idx].register_txn == 0) begin
                              mem_checker.write_on_native_if(.addr(fsys_txn_q[idx].ioaiu_cacheline_addr), 
                                                      .wdata(fsys_txn_q[idx].ioaiu_txn_data), 
                                                      .byte_en(fsys_txn_q[idx].ioaiu_byte_en), 
                                                      .txn_id(fsys_txn_q[idx].m_axi_wr_addr_pkt_<%=pidx%>.awid),
                                                      .ns(fsys_txn_q[idx].m_axi_wr_addr_pkt_<%=pidx%>.awprot[1]),
                                                      .is_coh(fsys_txn_q[idx].is_coh),
                                                      .is_chi(0),
                                                      .funit_id(<%=obj.AiuInfo[pidx].FUnitId%>), 
                                                      .core_id(<%=i%>),
                                                      .fsys_txn_q(fsys_txn_q), 
                                                      .fsys_index(idx),
                                                      .cached(use_cache));
                           end
                        end // EN_MEM_CHECK
                     end
                     //Proxy cache case, when all cmd_req didn't go out.
                     if (fsys_txn_q[idx].is_write == 0
                        && fsys_txn_q[idx].exp_smi_data_pkts == fsys_txn_q[idx].exp_smi_cmd_pkts 
                        && fsys_txn_q[idx].aiu_str_cnt == fsys_txn_q[idx].str_msg_id_q.size()
                        && fsys_txn_q[idx].exp_smi_cmd_pkts !== 0
                        && fsys_txn_q[idx].cmdreq_skip == 1
                        && use_cache == 1) begin
                           `uvm_info(`LABEL, $sformatf(
                              "FSYS_UID:%0d : Setting aiu_check_done", 
                              fsys_txn_q[idx].fsys_unique_txn_id), UVM_NONE+50)
                           fsys_txn_q[idx].aiu_check_done = 1;
                     end
                     if (((fsys_txn_q[idx].is_write == 1 & fsys_txn_q[idx].is_read == 1) || fsys_txn_q[idx].is_atomic_txn == 1)
                        && (fsys_txn_q[idx].rbrreq_seen_q[i] == 0 || fsys_txn_q[idx].rbrreq_seen_q[i] > 1)
                        && fsys_txn_q[idx].rbuse_count == fsys_txn_q[idx].rbrsvd_count
                        && fsys_txn_q[idx].exp_smi_data_pkts == 0) begin
                        fsys_txn_q[idx].dmi_check_done = 1;
                     end
                     if (fsys_txn_q[idx].is_read == 1 
                        && fsys_txn_q[idx].exp_smi_data_pkts == 0
                        && (fsys_txn_q[idx].rbrreq_seen_q[i] == 0 || fsys_txn_q[idx].rbrreq_seen_q[i] > 1)
                        && fsys_txn_q[idx].rbuse_count == fsys_txn_q[idx].rbrsvd_count) begin
                        fsys_txn_q[idx].dmi_check_done = 1;
                     end
                     check_flags_and_delete_txn(`LABEL, idx, fsys_txn_q, 0, `__LINE__);
                    end
                  break;
            end // match found
         end // foreach pending DTR msg IDs
      end // Read message with expected DTRs
      if (match_found == 1) break;
   end // foreach fsys_txn_q
   if (match_found == 0) begin
      foreach (fsys_txn_q[idx]) begin
         if (fsys_txn_q[idx].snpreq_targ_id_q.size() > 0) begin
            foreach (fsys_txn_q[idx].snpreq_targ_id_q[i]) begin
               //`uvm_info(`LABEL, $sformatf("FSYS_UID:%0d : HERE: snpreq_targid=%0d(funitid=<%=obj.AiuInfo[pidx].FUnitId%>), index=%0d, dtr_tgtid=0x%0h,dtr_msgid='d%0d", fsys_txn_q[idx].fsys_unique_txn_id, fsys_txn_q[idx].snpreq_targ_id_q[i], i, fsys_txn_q[idx].read_acc_dtr_tgtid_q[i], fsys_txn_q[idx].read_acc_dtr_msgid_q[i]), UVM_NONE+50)
               if (fsys_txn_q[idx].snpreq_targ_id_q[i] == <%=obj.AiuInfo[pidx].FUnitId%>
                  // && fsys_txn_q[idx].read_acc_dtr_exp_q[i]  == 1 -->To cover cases with proxy cache
                  && fsys_txn_q[idx].read_acc_dtr_tgtid_q[i] == m_pkt.smi_targ_ncore_unit_id
                  && fsys_txn_q[idx].read_acc_dtr_msgid_q[i] == m_pkt.smi_rmsg_id
                  // CONC-16674 - DCE sends stashing snoops with DtrTgtId and DtrMsgId zeroed out. 
                  // This results in outgoing DTR matching wrong TXN and wrong cacheline being updated in coherency checker.
                  // Hence, ignoring stash_txn in outgoing DTR matches
                  && fsys_txn_q[idx].is_stash_txn == 0 
                  && (fsys_txn_q[idx].ioaiu_snp_addr_seen_q[i] == 1 
                     || (fsys_txn_q[idx].ioaiu_snp_addr_seen_q[i] == 0 && use_cache == 1))
               ) begin
                  `uvm_info(`LABEL, $sformatf(
                     "FSYS_UID:%0d : SMI DTR packet seen (Outgoing, snp read acceleration). %0s", 
                     fsys_txn_q[idx].fsys_unique_txn_id, m_pkt.convert2string()), UVM_NONE+50)
                  fsys_txn_q[idx].read_acc_dtr_exp_q[i] = 0;
                  fsys_txn_q[idx].read_acc_dtr_msgid_q[i] = -1;
                  fsys_txn_q[idx].update_time_accessed("dtr_req_aiu","<%=_child_blkid[pidx]%>");
                  fsys_txn_q[idx].snoop_data_fwded = 1;
   <% if(obj.AiuInfo[pidx].useCache == 1) {%>
                  if(m_en_coh_check) begin
                    package_and_send_coh_checker_<%=pidx%>(fsys_txn_q[idx],null,m_pkt,0,1,0,i);
                  end
  <% } %>
                  //MEM_CONSISTENCY
                  if(m_en_mem_check) begin
                     snp_cacheline_addr = {(fsys_txn_q[idx].snpreq_addr_q[i] >> addrMgrConst::WCACHE_OFFSET), <%=obj.wCacheLineOffset%>'b0};
                     mem_checker.snoop_on_native_if(.addr(snp_cacheline_addr), 
                                                    .data(fsys_txn_q[idx].snoop_data[<%=obj.AiuInfo[pidx].FUnitId%>][snp_cacheline_addr]), 
                                                    .byte_en(fsys_txn_q[idx].snoop_be[<%=obj.AiuInfo[pidx].FUnitId%>][snp_cacheline_addr]),
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
         `uvm_error(`LABEL, $sformatf(
            "FSYS_SCB: DTR didn't match any pending transactions. %0s",
            m_pkt.convert2string()))
      end
   end // if DTR didn't match any pending txn

endfunction : smi_dtr_prediction_<%=pidx%>

//====================================================================================================
//
// Function : smi_snpreq_prediction
//
//====================================================================================================
function void fsys_scb_ioaiu_predictor::smi_snpreq_prediction_<%=pidx%>(input <%=_child_blkid[pidx]%>_smi_agent_pkg::smi_seq_item m_pkt, ref fsys_scb_txn fsys_txn_q[$]);
   `undef LABEL
   `define LABEL "smi_snpreq_<%=_child_blkid[pidx]%>"
   bit match_found = 0;
   bit addr_match = 0;
   bit use_cache = <%=obj.AiuInfo[pidx].useCache%>;
 <% if(obj.AiuInfo[pidx].useCache == 1) {%>
   <%=_child_blkid[pidx]%>_smi_agent_pkg::smi_seq_item snp_req = new();
   snp_req.copy(m_pkt); 
   proxycache_snp_req_q_<%=pidx%>.push_back(snp_req);
 <% } %>
   foreach (fsys_txn_q[idx]) begin
      if (fsys_txn_q[idx].cmd_msg_id_q.size() > 0) begin
         foreach (fsys_txn_q[idx].cmd_msg_id_q[i]) begin
            addr_match = 0;
            //`uvm_info(`LABEL, $psprintf(
            //    "FSYS_UID:%0d : cmd_addr_q[%0d]=0x%0h. snpreq_cnt = 'd%0d. fsys_txn_q[idx].snpreq_msg_id[i] = 0x%0h, snoops targ id q size = 'd%0d, rbid=0x%0h",
            //    fsys_txn_q[idx].fsys_unique_txn_id, i, fsys_txn_q[idx].cmd_addr_q[i], fsys_txn_q[idx].snpreq_cnt_q[i], 
            //    fsys_txn_q[idx].snpreq_msg_id_q[i],fsys_txn_q[idx].snpreq_targ_id_q.size(), fsys_txn_q[idx].rbr_rbid_q[i]), UVM_NONE+50)
            if (fsys_txn_q[idx].cmd_addr_q[i] == m_pkt.smi_addr
               <% if (obj.wSecurityAttribute > 0) { %>
               && fsys_txn_q[idx].smi_ns == m_pkt.smi_ns
               <% } %>
               <% if (obj.Widths.Concerto.Ndp.Body.wPR > 0) { %>
               && fsys_txn_q[idx].smi_pr == m_pkt.smi_pr
               <% } %>
               <% if (obj.Widths.Concerto.Ndp.Body.wQos > 0) { %>
               && fsys_txn_q[idx].smi_qos == m_pkt.smi_qos
               <% } %>
            ) begin
               addr_match = 1;
            end //txn addr match 
            else if (fsys_txn_q[idx].is_dvm == 1
                     && fsys_txn_q[idx].source_funit_id !== <%=obj.AiuInfo[pidx].FUnitId%>
                     && ((m_pkt.smi_addr[3:3] == 1'b0 && fsys_txn_q[idx].cmd_addr_q[i][31:4] == m_pkt.smi_addr[31:4])
                        || (m_pkt.smi_addr[3:3] == 1'b1 && fsys_txn_q[idx].dvm_part_2_addr_q[i][31:4] == m_pkt.smi_addr[31:4]))
            ) begin
               addr_match = 1;
            end // dvm addr match
            if (addr_match == 1
               && fsys_txn_q[idx].snpreq_cnt_q[i] > 0 && fsys_txn_q[idx].snpreq_msg_id_q[i] == m_pkt.smi_msg_id
               && fsys_txn_q[idx].snpreq_unq_id_q.size() > 0
               //&& ((fsys_txn_q[idx].rbr_rbid_q[i] == m_pkt.smi_rbid && fsys_txn_q[idx].is_dvm == 0) || (fsys_txn_q[idx].is_dvm == 1))
               //&& fsys_txn_q[idx].snpreq_targ_id_q[i] == <%=obj.AiuInfo[pidx].FUnitId%>
            ) begin
               foreach (fsys_txn_q[idx].snpreq_targ_id_q[j]) begin
                  if (fsys_txn_q[idx].snpreq_targ_id_q[j] == <%=obj.AiuInfo[pidx].FUnitId%>
                     && fsys_txn_q[idx].snpreq_unq_id_q[j] == {m_pkt.smi_targ_ncore_unit_id, m_pkt.smi_msg_id}
                     && fsys_txn_q[idx].snpreq_src_id_q[j] == m_pkt.smi_src_ncore_unit_id
                     && (fsys_txn_q[idx].ioaiu_snp_addr_seen_q[j] == -1 || fsys_txn_q[idx].is_dvm == 1)
                     && ((fsys_txn_q[idx].read_acc_dtr_msgid_q[j] == -1
                     && fsys_txn_q[idx].read_acc_dtr_tgtid_q[j] == 0) || (fsys_txn_q[idx].is_dvm == 1))) begin
                     `uvm_info(`LABEL, $sformatf(
                        "FSYS_UID:%0d : SNPReq seen. %0s", 
                        fsys_txn_q[idx].fsys_unique_txn_id, m_pkt.convert2string()), 
                        UVM_NONE+50)
                     smi_snpreq_order_uid_<%=pidx%>.push_back(fsys_txn_q[idx].fsys_unique_txn_id);
                     smi_snpreq_order_idx_<%=pidx%>.push_back(i);
                     smi_snpreq_order_idx2_<%=pidx%>.push_back(j);
                     if (fsys_txn_q[idx].is_dvm == 1
                        && m_pkt.smi_addr[3:3] == 1'b0 && m_pkt.smi_addr[13:11] == 3'b100) begin
                        fsys_txn_q[idx].dvm_complete_exp++;
                        //fsys_txn_q[idx].dvm_complete_resp_exp++;
                        fsys_txn_q[idx].dvm_complete_unit_id_q.push_back(<%=obj.AiuInfo[pidx].FUnitId%>);
                        `uvm_info(`LABEL, $sformatf("FSYS_UID:%0d : DVM Complete expected.",
                           fsys_txn_q[idx].fsys_unique_txn_id), UVM_NONE+50)
                     end
                     if (fsys_txn_q[idx].ioaiu_snp_addr_seen_q[j] == -1)
                        fsys_txn_q[idx].ioaiu_snp_addr_seen_q[j] = 0;
                     fsys_txn_q[idx].snp_up_q[j] = m_pkt.smi_up;
                     // 45=MsgType:'h45(SNP_INV_DTW), won't generate AIU to AIU DTR
                     // TODO: Investigate and add other snoops that wont generate DTRs in below if condition.
                     if (!(m_pkt.smi_msg_type inside {'h45})) begin
                        fsys_txn_q[idx].read_acc_dtr_tgtid_q[j] = m_pkt.smi_mpf1_dtr_tgt_id;
                        fsys_txn_q[idx].read_acc_dtr_msgid_q[j] = m_pkt.smi_mpf2_dtr_msg_id;
                        fsys_txn_q[idx].read_acc_dtr_exp_q[j] = 1;
                     end
                     //`uvm_info(`LABEL, $sformatf("FSYS_UID:%0d : HERE: snpreq_targid=%0d(funitid=<%=obj.AiuInfo[pidx].FUnitId%>), index=%0d, dtr_tgtid=0x%0h,dtr_msgid='d%0d", fsys_txn_q[idx].fsys_unique_txn_id, fsys_txn_q[idx].snpreq_targ_id_q[j], j, fsys_txn_q[idx].read_acc_dtr_tgtid_q[j], fsys_txn_q[idx].read_acc_dtr_msgid_q[j]), UVM_NONE+50)
                     //SnpInv don't generate DTW, they don't send dirty data to memory
                     // && CONC-11661
                     if (!(m_pkt.smi_msg_type inside {'h46})
                        && fsys_txn_q[idx].rbr_rbid_q[i] !== -1) begin
                        // Add this SNP's RBID from RBRReq to rbid queue. This way DTW lookup equation remains same
                        fsys_txn_q[idx].rbid_val_q.push_back(1);
                        fsys_txn_q[idx].rbid_q.push_back(m_pkt.smi_rbid); //fsys_txn_q[idx].rbr_rbid_q[i]);
                        fsys_txn_q[idx].str_subid_q.push_back(0);
                        fsys_txn_q[idx].rbid_unit_id_q.push_back(m_pkt.smi_dest_id); //fsys_txn_q[idx].cmd_did_q[i]);
                        fsys_txn_q[idx].snpdat_unit_id_q.push_back(<%=obj.AiuInfo[pidx].FUnitId%>);
                        fsys_txn_q[idx].snpsrc_unit_id_q.push_back(m_pkt.smi_src_ncore_unit_id);
                     end
                     fsys_txn_q[idx].exp_smi_data_pkts = fsys_txn_q[idx].exp_smi_data_pkts + 1;
                     if (fsys_txn_q[idx].ioaiu_core_id < 0) begin
                        fsys_txn_q[idx].snp_ioaiu_from_chi_q[j] = 1;
                     end
                     fsys_txn_q[idx].update_time_accessed("snp_req","<%=_child_blkid[pidx]%>");
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
               if (fsys_txn_q[idx].snpreq_rbid_q[i] == m_pkt.smi_rbid    //there is 1 RBID value
                  && fsys_txn_q[idx].recall_addr == m_pkt.smi_addr
                  && fsys_txn_q[idx].dce_funit_id == m_pkt.smi_src_ncore_unit_id
                  && fsys_txn_q[idx].snpreq_unq_id_q[i] == {m_pkt.smi_targ_ncore_unit_id, m_pkt.smi_msg_id}
                  && fsys_txn_q[idx].snpreq_msg_id_q[0] == m_pkt.smi_msg_id
               ) begin
                  `uvm_info(`LABEL, $sformatf(
                     "FSYS_UID:%0d : SNPReq seen for recall %0s", 
                     fsys_txn_q[idx].fsys_unique_txn_id, m_pkt.convert2string()), 
                     UVM_NONE+50)
                  fsys_txn_q[idx].ioaiu_snp_addr_seen_q[i] = 0;
                  // de-actiavte this value, to avoid false re-matches
                  fsys_txn_q[idx].snpreq_rbid_q[i] = -1; 
                  smi_snpreq_order_uid_<%=pidx%>.push_back(fsys_txn_q[idx].fsys_unique_txn_id);
                  smi_snpreq_order_idx_<%=pidx%>.push_back(0);
                  smi_snpreq_order_idx2_<%=pidx%>.push_back(i);
                  // Add this SNP's RBID from RBRReq to rbid queue. This way DTW lookup equation remains same
                  fsys_txn_q[idx].rbid_val_q.push_back(1);
                  fsys_txn_q[idx].rbid_q.push_back(m_pkt.smi_rbid); //fsys_txn_q[idx].rbr_rbid_q[0]);
                  fsys_txn_q[idx].str_subid_q.push_back(0);
                  fsys_txn_q[idx].rbid_unit_id_q.push_back(m_pkt.smi_dest_id); //fsys_txn_q[idx].cmd_did_q[0]);
                  fsys_txn_q[idx].snpdat_unit_id_q.push_back(<%=obj.AiuInfo[pidx].FUnitId%>);
                  fsys_txn_q[idx].snpsrc_unit_id_q.push_back(m_pkt.smi_src_ncore_unit_id);
                  fsys_txn_q[idx].exp_smi_data_pkts = fsys_txn_q[idx].exp_smi_data_pkts + 1;
                  fsys_txn_q[idx].update_time_accessed("snp_req","<%=_child_blkid[pidx]%>");
                  match_found = 1;
                  break;
               end // if matched
            end // foreach CMDReq DID
         end // if there are pending recalls 
         if (match_found == 1) break;
      end //foreach pending txn 
      if (match_found == 0) begin
         `uvm_error(`LABEL, $sformatf(
            "FSYS_SCB: SNPReq didn't match any pending transactions. %0s", 
            m_pkt.convert2string()))
      end
   end
endfunction : smi_snpreq_prediction_<%=pidx%>

//====================================================================================================
//
// Function : smi_updreq_prediction
//
//====================================================================================================
function void fsys_scb_ioaiu_predictor::smi_updreq_prediction_<%=pidx%>(input <%=_child_blkid[pidx]%>_smi_agent_pkg::smi_seq_item m_pkt, ref fsys_scb_txn fsys_txn_q[$]);
   `undef LABEL
   `define LABEL "smi_updreq_<%=_child_blkid[pidx]%>"
   cache_state_t end_state ;
   <%=_child_blkid[pidx]%>_smi_agent_pkg::eMsgUPD upd_type;
   $cast(upd_type, m_pkt.smi_msg_type);
   
   if (!(addrMgrConst::get_native_interface(m_pkt.smi_src_ncore_unit_id) inside {addrMgrConst::ACE_AIU, addrMgrConst::IO_CACHE_AIU})) begin
      `uvm_error(`LABEL, $sformatf("SMI UpdReq is not expected from native interface %0s unit id 'd%0d. Remaining txns: 'd%0d",  addrMgrConst::get_native_interface(m_pkt.smi_src_ncore_unit_id).name(),m_pkt.smi_src_ncore_unit_id, (fsys_txn_q.size()-1)))
   end else begin
      if(m_en_coh_check) begin
         `uvm_info(`LABEL, $sformatf("FSYS_SCB: UPDREQ seen: %0s", m_pkt.convert2string()), UVM_NONE+50)
         if (upd_type == <%=_child_blkid[pidx]%>_smi_agent_pkg::eUpdInv) end_state = IX;
         else if (upd_type == <%=_child_blkid[pidx]%>_smi_agent_pkg::eUpdSCln) end_state = SC;
         coherency_checker.update_state(.addr(m_pkt.smi_addr),.ns(m_pkt.smi_ns),.funit_idx(<%=obj.AiuInfo[pidx].FUnitId%>),.state(end_state),.flush(0));
      end
   end
endfunction : smi_updreq_prediction_<%=pidx%>

//====================================================================================================
//
// Function : smi_sysreq_prediction
//
//====================================================================================================
function void fsys_scb_ioaiu_predictor::smi_sysreq_prediction_<%=pidx%>(input <%=_child_blkid[pidx]%>_smi_agent_pkg::smi_seq_item m_pkt, ref fsys_scb_txn fsys_txn_q[$]);
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
function void fsys_scb_ioaiu_predictor::analyze_sys_event_<%=pidx%>(input <%=_child_blkid[pidx]%>_smi_agent_pkg::smi_seq_item m_pkt, ref fsys_scb_txn fsys_txn_q[$]);
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
function void fsys_scb_ioaiu_predictor::smi_sysrsp_prediction_<%=pidx%>(input <%=_child_blkid[pidx]%>_smi_agent_pkg::smi_seq_item m_pkt, ref fsys_scb_txn fsys_txn_q[$]);
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
function void fsys_scb_ioaiu_predictor::analyze_sys_event_rsp_<%=pidx%>(input <%=_child_blkid[pidx]%>_smi_agent_pkg::smi_seq_item m_pkt, ref fsys_scb_txn fsys_txn_q[$]);
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
            `uvm_error(`LABEL, $sformatf("FSYS_SCB: <%=_child_blkid[pidx]%> received SYS_EVENT RSP as originating unit, while it's still waiting for %0d SYSRSP from other attached units. PKT: %0s",
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
//
// Function : ace_cmd_to_smi_cmd
//
//====================================================================================================
function <%=_child_blkid[pidx]%>_smi_agent_pkg::eMsgCMD fsys_scb_ioaiu_predictor::ace_cmd_to_smi_cmd_<%=pidx%>(string snoop_type);
   case (snoop_type)
    "RDONCE"          : return (<%=_child_blkid[pidx]%>_smi_agent_pkg::eCmdRdNITC);
    "RDNOSNP"         : return (<%=_child_blkid[pidx]%>_smi_agent_pkg::eCmdRdNC);
    "RDSHRD"          : return (<%=_child_blkid[pidx]%>_smi_agent_pkg::eCmdRdVld);
    "RDCLN"           : return (<%=_child_blkid[pidx]%>_smi_agent_pkg::eCmdRdCln);
    "RDNOTSHRDDIR"    : return (<%=_child_blkid[pidx]%>_smi_agent_pkg::eCmdRdNShD);
    "RDUNQ"           : return (<%=_child_blkid[pidx]%>_smi_agent_pkg::eCmdRdUnq);
    "CLNUNQ"          : return (<%=_child_blkid[pidx]%>_smi_agent_pkg::eCmdClnUnq);
    "MKUNQ"           : return (<%=_child_blkid[pidx]%>_smi_agent_pkg::eCmdMkUnq);
    "CLNSHRD"         : return (<%=_child_blkid[pidx]%>_smi_agent_pkg::eCmdClnVld);
    "CLNINVL"         : return (<%=_child_blkid[pidx]%>_smi_agent_pkg::eCmdClnInv);
    "MKINVL"          : return (<%=_child_blkid[pidx]%>_smi_agent_pkg::eCmdMkInv);
    "DVMMSG"          : return (<%=_child_blkid[pidx]%>_smi_agent_pkg::eCmdDvmMsg);
    "WRUNQ"           : return (<%=_child_blkid[pidx]%>_smi_agent_pkg::eCmdWrUnqPtl);
    "WRLNUNQ"         : return (<%=_child_blkid[pidx]%>_smi_agent_pkg::eCmdWrUnqFull);
    "WRNOSNP"         : return (<%=_child_blkid[pidx]%>_smi_agent_pkg::eCmdWrNCFull);
    "WRCLN"           : return (<%=_child_blkid[pidx]%>_smi_agent_pkg::eCmdWrNCPtl);
    "WRBK"            : return (<%=_child_blkid[pidx]%>_smi_agent_pkg::eCmdWrNCPtl);
    "EVCT"            : return (<%=_child_blkid[pidx]%>_smi_agent_pkg::eCmdWrNCFull);
    "WREVCT"          : return (<%=_child_blkid[pidx]%>_smi_agent_pkg::eCmdWrNCFull);
    "ATMLD"           : return (<%=_child_blkid[pidx]%>_smi_agent_pkg::eCmdRdAtm);
    "ATMSTR"          : return (<%=_child_blkid[pidx]%>_smi_agent_pkg::eCmdWrAtm);
    "ATMSWAP"         : return (<%=_child_blkid[pidx]%>_smi_agent_pkg::eCmdSwAtm);
    "ATMCOMPARE"      : return (<%=_child_blkid[pidx]%>_smi_agent_pkg::eCmdCompAtm);
    "WRUNQPTLSTASH"   : return (<%=_child_blkid[pidx]%>_smi_agent_pkg::eCmdWrStshPtl);
    "WRUNQFULLSTASH"  : return (<%=_child_blkid[pidx]%>_smi_agent_pkg::eCmdWrStshFull);
    "STASHONCEUNQ"    : return (<%=_child_blkid[pidx]%>_smi_agent_pkg::eCmdLdCchUnq);
    "STASHONCESHARED" : return (<%=_child_blkid[pidx]%>_smi_agent_pkg::eCmdLdCchShd);
    "CLNSHRDPERSIST"  : return (<%=_child_blkid[pidx]%>_smi_agent_pkg::eCmdClnShdPer);
    "RDONCEMAKEINVLD" : return (<%=_child_blkid[pidx]%>_smi_agent_pkg::eCmdRdNITCMkInv);
    "RDONCECLNINVLD"  : return (<%=_child_blkid[pidx]%>_smi_agent_pkg::eCmdRdNITCClnInv);
    default         : `uvm_error("ace_cmd_to_smi_cmd_<%=_child_blkid[pidx]%>", $psprintf(
                        "FSYS_SCB: SCB ERROR %0s command type not yet implemented!", snoop_type))
  endcase // case (snoop_type)
endfunction : ace_cmd_to_smi_cmd_<%=pidx%>

<% } // if ioaui%>
<% } // foreach aius%>

////////////////////////////////////////////////////////////////////////////////
// Function: check_phase
// Description: Runs end of test checks and prints debug information
////////////////////////////////////////////////////////////////////////////////
function void fsys_scb_ioaiu_predictor::check_phase(uvm_phase phase);
   <% for(var pidx = 0; pidx < _child_blkid.length; pidx++) { %>
   <%  if(_child_blk[pidx].match('ioaiu')) { %>
   <%for(var i = 0; i < obj.AiuInfo[pidx].nNativeInterfacePorts; i++){%>
      if (tmp_data_pkt_<%=pidx%>_<%=i%>.size() != 0) begin
         `uvm_error("check_phase", $psprintf("FSYS_SCB: <%=_child_blkid[pidx]%> saw WDATA before WADDR. Remaining WDATA without a write requests: %0d", tmp_data_pkt_<%=pidx%>_<%=i%>.size()))
      end
      //TODO: Some requests are receiving snoop data on CD channel before receiving snoop response on CR channel
      //SCB needs to save the data before response in a queue and based on response, match it to pending txns
      //if (snoop_order_uid_counter_<%=pidx%>_<%=i%> !== 0) begin
      //   `uvm_error("check_phase", $psprintf("FSYS_SCB: <%=_child_blkid[pidx]%> 'd%0d IOAIU snoop requests haven't seen snoop resp/data on AC channel", snoop_order_uid_counter_<%=pidx%>_<%=i%>))
      //end
   <% } // foreach InterfacePorts%>
   if (pending_attach_sys_req_<%=pidx%>.size() !== 0) begin
      //TODO: make this an error when TB has support to drive event_if signals
      `uvm_warning("check_phase", $psprintf("FSYS_SCB: <%=_child_blkid[pidx]%> has %0d pending SYSREQ that didn't see SYSRSP", pending_attach_sys_req_<%=pidx%>.size()))
   end
   <% } // if ioaui%>
   <% } // foreach aius%>
endfunction : check_phase

//====================================================================================================
//
// Function : check_flags_and_delete_txn
//
//====================================================================================================
function bit fsys_scb_ioaiu_predictor::check_flags_and_delete_txn(string label, int index, ref fsys_scb_txn fsys_txn_q[$], input bit ignore_checks = 0, int line);
   int delete = 0;
   string line_s, func_line;

   line_s.itoa(line);
   func_line = $sformatf("%0s,(%0s)",label,line_s);

   if (ignore_checks == 1) begin
      delete = 1;
   end 
   else if (((fsys_txn_q[index].dmi_check_done == 1 || fsys_txn_q[index].dii_check_done == 1)
       && (fsys_txn_q[index].dce_check_done == 1 || fsys_txn_q[index].is_coh == 0)) 
       && (fsys_txn_q[index].aiu_check_done == 1)
   ) begin
      delete = 1;
   end
   //If all conditions are satified, delete the txn
   if (delete == 1) begin
      `uvm_info(func_line, $sformatf(
         "FSYS_UID:%0d : Deleting transaction from fsys_txn_q. Remaining txns: 'd%0d",
         fsys_txn_q[index].fsys_unique_txn_id, (fsys_txn_q.size()-1)), UVM_NONE+50)
         min_latency = min_latency < ($time - fsys_txn_q[index].created) ? min_latency : ($time - fsys_txn_q[index].created);
         max_latency = max_latency > ($time - fsys_txn_q[index].created) ? max_latency : ($time - fsys_txn_q[index].created);
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

//====================================================================================================
//
// Function : smi_snp_addr_to_ace_snp_addr
//
//====================================================================================================
function bit[63:0] fsys_scb_ioaiu_predictor::smi_snp_addr_to_ace_snp_addr(int snp_no, bit[64:0] addr, bit[64:0] other_part_addr, bit mpf3_range, int mpf3_num, int mpf1, int other_part_mpf1);
   bit[63:0] ret_addr = 0; //this is ac snoop address
      	
   if(snp_no == 0) begin
	   ret_addr[0]     = addr[4];       //Single/Two parts
	 	ret_addr[3:2]   = addr[39:38];   //Staged Invalidation
	 	ret_addr[4]     = addr[40];      //Leaf Entry Invalidation
	 	ret_addr[5]     = addr[6];       //ASID bits Valid
	 	ret_addr[6]     = addr[5];       //VMID bits Valid
	 	ret_addr[7]     = mpf3_range;    // Range
	 	ret_addr[9:8]   = addr[8:7];     //Security
	 	ret_addr[11:10] = addr[10:9];    //Guest/Hypervisor
	 	ret_addr[14:12] = addr[13:11];   //DVMOp Type
	 	ret_addr[15]    = (addr[13:11] == 'b100) ? 1 : 0; //Completion Required
	 	ret_addr[23:16] = addr[29:22];   //ASID[7:0] or Vritual Index VA[19:12]
	 	ret_addr[31:24] = addr[21:14];   //VMID[7:0] or Vritual Index VA[27:20]
	 	ret_addr[39:32] = addr[37:30];   //ASID[15:8]
	 	ret_addr[43:40] = (addr[4] == 0) ? 
	 	                  mpf1[7:4] :
	 	                  {addr[43:41], other_part_addr[43]}; //if one part snoop: VMID[15:12]. if two part snoop: VA[48:45]
	 	ret_addr[47:44] = other_part_mpf1[3:0];     //VA[56:53]
   end 
   else begin
	 	ret_addr[0]     = mpf3_num[0];    //NUM[0]
	 	ret_addr[1]     = mpf3_num[1];    //NUM[1]
	 	ret_addr[2]     = mpf3_num[2];    //NUM[2]
	 	ret_addr[4]     = mpf3_num[3];    //NUM[3]/VA[4]--- This is true regardless of range value
	 	ret_addr[5]     = mpf3_num[4];    //NUM[4]/VA[5] -- This is true regardless of range value
	 	ret_addr[7:6]   = addr[5:4];      //Scale[1:0]/VA[7:6]/PA[7:6]
	 	ret_addr[9:8]   = addr[7:6];      //TTL[1:0]/VA[9:8]/PA[9:8]
      ret_addr[11:10] = addr[9:8];      //TG[1:0]/VA[11:10]/PA[11:10]
      ret_addr[39:12] = addr[37:10];    //VA[39:12]/PA[39:12]

      //DVM MSG Type PICI (Physical Instruction Cache Invalidate)
      if (other_part_addr[13:11] == 3'b010) begin            
         ret_addr[40]    = addr[38];       //PA[40]
         ret_addr[44:41] = addr[42:39];    //PA[44:41]
         ret_addr[45]    = addr[43];       //PA[45]
         ret_addr[46]    = addr[44];       //PA[46]
         ret_addr[47]    = addr[45];       //PA[47]
      end else begin
         ret_addr[3]     = addr[38];       //VA[40]
         ret_addr[43:40] = addr[42:39];    //VA[44:41]
         ret_addr[44]    = addr[44];       //VA[49]
         ret_addr[46]    = addr[45];       //VA[51]
         ret_addr[45]    = other_part_addr[44];       //VA[50]
         ret_addr[47]    = other_part_addr[45];       //VA[52]
      end
   end 

   return ret_addr;
endfunction : smi_snp_addr_to_ace_snp_addr

// End of file
