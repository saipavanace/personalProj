////////////////////////////////////////////////////////////////////////////////
//
// Author       : Neha F
// Purpose      : Full Sys scoreboard
// Description  : This is top level class that defines a system level
//                scoreboard. This will encapsulate analysis port declaration
//                for each NCore unit. All AP write() functions will leverage
//                predictor functionalities.   
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
   let computedAxiInt;

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

////////////////////////////////////////////////////////////////////////////////
//AIU analysis port declaration
////////////////////////////////////////////////////////////////////////////////
<% for(var pidx = 0; pidx < _child_blkid.length; pidx++) { %>
  <%  if(_child_blk[pidx].match('chiaiu')) { %>
`uvm_analysis_imp_decl ( _<%=_child_blkid[pidx]%>_smi_port      )
`uvm_analysis_imp_decl ( _<%=_child_blkid[pidx]%>_req_port     )
`uvm_analysis_imp_decl ( _<%=_child_blkid[pidx]%>_wdata_port   )
`uvm_analysis_imp_decl ( _<%=_child_blkid[pidx]%>_srsp_port    )
`uvm_analysis_imp_decl ( _<%=_child_blkid[pidx]%>_crsp_port    )
`uvm_analysis_imp_decl ( _<%=_child_blkid[pidx]%>_rdata_port   )
`uvm_analysis_imp_decl ( _<%=_child_blkid[pidx]%>_snpaddr_port )
  <% } // if chiaui%>
////////////////////////////////////////////////////////////////////////////////
  <%  if(_child_blk[pidx].match('ioaiu')) { %>
`uvm_analysis_imp_decl(_<%=_child_blkid[pidx]%>_smi_port)
    <%for(var i = 0; i < obj.AiuInfo[pidx].nNativeInterfacePorts; i++){%>
`uvm_analysis_imp_decl(_<%=_child_blkid[pidx]%>_core<%=i%>_read_addr_chnl)
`uvm_analysis_imp_decl(_<%=_child_blkid[pidx]%>_core<%=i%>_write_addr_chnl)
`uvm_analysis_imp_decl(_<%=_child_blkid[pidx]%>_core<%=i%>_read_data_chnl)
`uvm_analysis_imp_decl(_<%=_child_blkid[pidx]%>_core<%=i%>_read_data_advance_copy_chnl)
`uvm_analysis_imp_decl(_<%=_child_blkid[pidx]%>_core<%=i%>_write_data_chnl)
`uvm_analysis_imp_decl(_<%=_child_blkid[pidx]%>_core<%=i%>_write_resp_chnl)
`uvm_analysis_imp_decl(_<%=_child_blkid[pidx]%>_core<%=i%>_write_resp_advance_copy_chnl)
<% if(obj.AiuInfo[pidx].fnNativeInterface == "ACE5" ||obj.AiuInfo[pidx].fnNativeInterface == "ACE" || obj.AiuInfo[pidx].fnNativeInterface == "ACELITE-E" || obj.AiuInfo[pidx].fnNativeInterface == "ACE-LITE"){ %>
    `uvm_analysis_imp_decl(_<%=_child_blkid[pidx]%>_core<%=i%>_ace_snoop_addr_chnl)
    `uvm_analysis_imp_decl(_<%=_child_blkid[pidx]%>_core<%=i%>_ace_snoop_resp_chnl)
    `uvm_analysis_imp_decl(_<%=_child_blkid[pidx]%>_core<%=i%>_ace_snoop_data_chnl)
<% } %>
    <% } // froeach InterfacePorts%>
  <% } // if ioaiu%>
<% } // foreach aius%>
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
// DMI analysis port declaration
////////////////////////////////////////////////////////////////////////////////
<% for(var pidx = 0; pidx < obj.nDMIs; pidx++) { %>
`uvm_analysis_imp_decl(_dmi<%=pidx%>_smi)

`uvm_analysis_imp_decl(_dmi<%=pidx%>_read_addr_chnl)
`uvm_analysis_imp_decl(_dmi<%=pidx%>_read_data_chnl)
`uvm_analysis_imp_decl(_dmi<%=pidx%>_write_addr_chnl)
`uvm_analysis_imp_decl(_dmi<%=pidx%>_write_data_chnl)
`uvm_analysis_imp_decl(_dmi<%=pidx%>_write_resp_chnl)
<% } //foreach DMI %>
////////////////////////////////////////////////////////////////////////////////
// DII analysis port declaration
////////////////////////////////////////////////////////////////////////////////
<% for(var pidx = 0; pidx < obj.nDIIs; pidx++) { %>
`uvm_analysis_imp_decl(_dii<%=pidx%>_smi)

`uvm_analysis_imp_decl(_dii<%=pidx%>_read_addr_chnl)
`uvm_analysis_imp_decl(_dii<%=pidx%>_read_data_chnl)
`uvm_analysis_imp_decl(_dii<%=pidx%>_write_addr_chnl)
`uvm_analysis_imp_decl(_dii<%=pidx%>_write_data_chnl)
`uvm_analysis_imp_decl(_dii<%=pidx%>_write_resp_chnl)
<% } //foreach DII %>
////////////////////////////////////////////////////////////////////////////////
// DCE analysis port declaration
////////////////////////////////////////////////////////////////////////////////
<% for(var pidx = 0; pidx < obj.nDCEs; pidx++) { %>
`uvm_analysis_imp_decl(_dce<%=pidx%>_smi)
<% } //foreach DCE %>
////////////////////////////////////////////////////////////////////////////////
// DVE analysis port declaration
////////////////////////////////////////////////////////////////////////////////
<% for(var pidx = 0; pidx < obj.nDVEs; pidx++) { %>
`uvm_analysis_imp_decl(_dve<%=pidx%>_smi)
<% } //foreach DVE %>
////////////////////////////////////////////////////////////////////////////////
// Class: fsys_scoreboard
//
//
//
////////////////////////////////////////////////////////////////////////////////
`ifdef FSYS_SCB_COVER_ON
 `define FSYS_BOTH_COVER_ON
 `endif
`ifdef FSYS_COVER_ON  
 `define FSYS_BOTH_COVER_ON
 `endif

class fsys_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(fsys_scoreboard)

   fsys_scb_txn   fsys_txn_q[$];
   int            waive_txn_q[$];
   static int     fsys_unique_txn_id = 0;
   bit            fsys_pred_off = 0;
`ifdef FSYS_BOTH_COVER_ON 
   static uvm_event_pool ev_pool  = uvm_event_pool::get_global_pool();
   static uvm_event csr_init_done = ev_pool.get("csr_init_done");
 `endif
`ifdef FSYS_SCB_COVER_ON
   fsys_txn_path_coverage fsys_txn_path_cov;
`endif                  

   //MEM_CONSISTENCY
   mem_consistency_checker mem_checker;
   bit   m_en_mem_check;

   //COH_CHECKER
   fsys_coherency_checker coherency_checker;

    // FSYS COVERAGE
   `ifdef FSYS_COVER_ON 
   Fsys_coverage fsys_cov;
    //Concerto env config handle
   concerto_env_cfg m_concerto_env_cfg;
   <%for(var pidx = 0; pidx < obj.AiuInfo.length; pidx++) { 
        if(obj.AiuInfo[pidx].fnNativeInterface == "ACE5" ||obj.AiuInfo[pidx].fnNativeInterface == "ACE" || 
           obj.AiuInfo[pidx].fnNativeInterface == "CHI-A" || obj.AiuInfo[pidx].fnNativeInterface == "CHI-B"|| obj.AiuInfo[pidx].fnNativeInterface == "CHI-E"){ %>
   virtual event_out_if     m_event_out_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>;
   <%}}%>
   `endif

   // Predictor instantiation
   fsys_scb_chi_predictor     chi_predictor;
   fsys_scb_ioaiu_predictor   ioaiu_predictor;
   fsys_scb_ioaiup_predictor  ioaiup_predictor;
   fsys_scb_dmi_predictor     dmi_predictor;
   fsys_scb_dii_predictor     dii_predictor;
   fsys_scb_dce_predictor     dce_predictor;
   fsys_scb_dve_predictor     dve_predictor;

////////////////////////////////////////////////////////////////////////////////
//AIU analysis ports 
////////////////////////////////////////////////////////////////////////////////
<% for(var pidx = 0; pidx < _child_blkid.length; pidx++) { %>
  <%  if(_child_blk[pidx].match('chiaiu')) { %>
    uvm_analysis_imp_<%=_child_blkid[pidx]%>_req_port      #(<%=_child_blkid[pidx]%>_env_pkg::chi_req_seq_item, fsys_scoreboard) <%=_child_blkid[pidx]%>_req_port;
    uvm_analysis_imp_<%=_child_blkid[pidx]%>_wdata_port    #(<%=_child_blkid[pidx]%>_env_pkg::chi_dat_seq_item, fsys_scoreboard) <%=_child_blkid[pidx]%>_wdata_port;
    uvm_analysis_imp_<%=_child_blkid[pidx]%>_srsp_port     #(<%=_child_blkid[pidx]%>_env_pkg::chi_rsp_seq_item, fsys_scoreboard) <%=_child_blkid[pidx]%>_srsp_port;
    uvm_analysis_imp_<%=_child_blkid[pidx]%>_crsp_port     #(<%=_child_blkid[pidx]%>_env_pkg::chi_rsp_seq_item, fsys_scoreboard) <%=_child_blkid[pidx]%>_crsp_port;
    uvm_analysis_imp_<%=_child_blkid[pidx]%>_rdata_port    #(<%=_child_blkid[pidx]%>_env_pkg::chi_dat_seq_item, fsys_scoreboard) <%=_child_blkid[pidx]%>_rdata_port;
    uvm_analysis_imp_<%=_child_blkid[pidx]%>_snpaddr_port  #(<%=_child_blkid[pidx]%>_env_pkg::chi_snp_seq_item, fsys_scoreboard) <%=_child_blkid[pidx]%>_snpaddr_port;

    //SMI Port
    uvm_analysis_imp_<%=_child_blkid[pidx]%>_smi_port #(<%=_child_blkid[pidx]%>_smi_agent_pkg::smi_seq_item, fsys_scoreboard) <%=_child_blkid[pidx]%>_smi_port;
  <% } // if chiaui%>
////////////////////////////////////////////////////////////////////////////////
  <%  if(_child_blk[pidx].match('ioaiu')) { %>
    uvm_analysis_imp_<%=_child_blkid[pidx]%>_smi_port        
                  #(<%=_child_blkid[pidx]%>_smi_agent_pkg::smi_seq_item, fsys_scoreboard)          <%=_child_blkid[pidx]%>_smi_port;
    <%for(var i = 0; i < obj.AiuInfo[pidx].nNativeInterfacePorts; i++){%>
    <% if(obj.AiuInfo[pidx].fnNativeInterface == "ACE5"||obj.AiuInfo[pidx].fnNativeInterface == "ACE"){ %>
      static bit pcie_ordermode_rd_en_<%=_child_blkid[pidx]%>_core<%=i%> = 0;
      static bit pcie_ordermode_wr_en_<%=_child_blkid[pidx]%>_core<%=i%> = 0;
    <% } else { %>
      static bit pcie_ordermode_rd_en_<%=_child_blkid[pidx]%>_core<%=i%> = 1;
      static bit pcie_ordermode_wr_en_<%=_child_blkid[pidx]%>_core<%=i%> = 1;
   <% } %>
      uvm_analysis_imp_<%=_child_blkid[pidx]%>_core<%=i%>_read_addr_chnl               
                  #(<%=_child_blkid[pidx]%>_env_pkg::axi4_read_addr_pkt_t, fsys_scoreboard) <%=_child_blkid[pidx]%>_core<%=i%>_read_addr_port;
      uvm_analysis_imp_<%=_child_blkid[pidx]%>_core<%=i%>_write_addr_chnl              
                  #(<%=_child_blkid[pidx]%>_env_pkg::axi4_write_addr_pkt_t, fsys_scoreboard) <%=_child_blkid[pidx]%>_core<%=i%>_write_addr_port;
      uvm_analysis_imp_<%=_child_blkid[pidx]%>_core<%=i%>_read_data_chnl               
                  #(<%=_child_blkid[pidx]%>_env_pkg::axi4_read_data_pkt_t, fsys_scoreboard) <%=_child_blkid[pidx]%>_core<%=i%>_read_data_port;
      uvm_analysis_imp_<%=_child_blkid[pidx]%>_core<%=i%>_read_data_advance_copy_chnl  
                  #(<%=_child_blkid[pidx]%>_env_pkg::axi4_read_data_pkt_t, fsys_scoreboard) <%=_child_blkid[pidx]%>_core<%=i%>_read_data_advance_copy_port;
      uvm_analysis_imp_<%=_child_blkid[pidx]%>_core<%=i%>_write_data_chnl              
                  #(<%=_child_blkid[pidx]%>_env_pkg::axi4_write_data_pkt_t, fsys_scoreboard) <%=_child_blkid[pidx]%>_core<%=i%>_write_data_port;
      uvm_analysis_imp_<%=_child_blkid[pidx]%>_core<%=i%>_write_resp_chnl              
                  #(<%=_child_blkid[pidx]%>_env_pkg::axi4_write_resp_pkt_t, fsys_scoreboard) <%=_child_blkid[pidx]%>_core<%=i%>_write_resp_port;
      uvm_analysis_imp_<%=_child_blkid[pidx]%>_core<%=i%>_write_resp_advance_copy_chnl 
                  #(<%=_child_blkid[pidx]%>_env_pkg::axi4_write_resp_pkt_t, fsys_scoreboard) <%=_child_blkid[pidx]%>_core<%=i%>_write_resp_advance_copy_port;
      <% if(obj.AiuInfo[pidx].fnNativeInterface == "ACE5" || obj.AiuInfo[pidx].fnNativeInterface == "ACE" || obj.AiuInfo[pidx].fnNativeInterface == "ACELITE-E" || obj.AiuInfo[pidx].fnNativeInterface == "ACE-LITE"){ %>
        uvm_analysis_imp_<%=_child_blkid[pidx]%>_core<%=i%>_ace_snoop_addr_chnl          
                  #(<%=_child_blkid[pidx]%>_env_pkg::ace_snoop_addr_pkt_t, fsys_scoreboard) <%=_child_blkid[pidx]%>_core<%=i%>_snoop_addr_port;
        uvm_analysis_imp_<%=_child_blkid[pidx]%>_core<%=i%>_ace_snoop_resp_chnl          
                  #(<%=_child_blkid[pidx]%>_env_pkg::ace_snoop_resp_pkt_t, fsys_scoreboard) <%=_child_blkid[pidx]%>_core<%=i%>_snoop_resp_port;
        uvm_analysis_imp_<%=_child_blkid[pidx]%>_core<%=i%>_ace_snoop_data_chnl          
                  #(<%=_child_blkid[pidx]%>_env_pkg::ace_snoop_data_pkt_t, fsys_scoreboard) <%=_child_blkid[pidx]%>_core<%=i%>_snoop_data_port;
      <%}%>
    <% } // froeach InterfacePorts%>
  <% } // if ioaiu%>
<% } // foreach aius%>
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
//DMI analysis ports 
////////////////////////////////////////////////////////////////////////////////
<% for(var pidx = 0; pidx < obj.nDMIs; pidx++) { %>
uvm_analysis_imp_dmi<%=pidx%>_smi #(dmi<%=pidx%>_smi_agent_pkg::smi_seq_item, fsys_scoreboard) dmi<%=pidx%>_smi;
uvm_analysis_imp_dmi<%=pidx%>_read_addr_chnl  #(dmi<%=pidx%>_env_pkg::axi4_read_addr_pkt_t, fsys_scoreboard)  dmi<%=pidx%>_read_addr_port;
uvm_analysis_imp_dmi<%=pidx%>_read_data_chnl  #(dmi<%=pidx%>_env_pkg::axi4_read_data_pkt_t, fsys_scoreboard)  dmi<%=pidx%>_read_data_port;
uvm_analysis_imp_dmi<%=pidx%>_write_addr_chnl #(dmi<%=pidx%>_env_pkg::axi4_write_addr_pkt_t, fsys_scoreboard) dmi<%=pidx%>_write_addr_port;
uvm_analysis_imp_dmi<%=pidx%>_write_data_chnl #(dmi<%=pidx%>_env_pkg::axi4_write_data_pkt_t, fsys_scoreboard) dmi<%=pidx%>_write_data_port;
uvm_analysis_imp_dmi<%=pidx%>_write_resp_chnl #(dmi<%=pidx%>_env_pkg::axi4_write_resp_pkt_t, fsys_scoreboard) dmi<%=pidx%>_write_resp_port;
<% } //foreach DMI %>
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
//DII analysis ports 
////////////////////////////////////////////////////////////////////////////////
<% for(var pidx = 0; pidx < obj.nDIIs; pidx++) { %>
uvm_analysis_imp_dii<%=pidx%>_smi #(dii<%=pidx%>_smi_agent_pkg::smi_seq_item, fsys_scoreboard) dii<%=pidx%>_smi;
uvm_analysis_imp_dii<%=pidx%>_read_addr_chnl  #(dii<%=pidx%>_env_pkg::axi4_read_addr_pkt_t, fsys_scoreboard)  dii<%=pidx%>_read_addr_port;
uvm_analysis_imp_dii<%=pidx%>_read_data_chnl  #(dii<%=pidx%>_env_pkg::axi4_read_data_pkt_t, fsys_scoreboard)  dii<%=pidx%>_read_data_port;
uvm_analysis_imp_dii<%=pidx%>_write_addr_chnl #(dii<%=pidx%>_env_pkg::axi4_write_addr_pkt_t, fsys_scoreboard) dii<%=pidx%>_write_addr_port;
uvm_analysis_imp_dii<%=pidx%>_write_data_chnl #(dii<%=pidx%>_env_pkg::axi4_write_data_pkt_t, fsys_scoreboard) dii<%=pidx%>_write_data_port;
uvm_analysis_imp_dii<%=pidx%>_write_resp_chnl #(dii<%=pidx%>_env_pkg::axi4_write_resp_pkt_t, fsys_scoreboard) dii<%=pidx%>_write_resp_port;
<% } //foreach DII %>
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
//DCE analysis ports 
////////////////////////////////////////////////////////////////////////////////
<% for(var pidx = 0; pidx < obj.nDCEs; pidx++) { %>
uvm_analysis_imp_dce<%=pidx%>_smi #(dce<%=pidx%>_smi_agent_pkg::smi_seq_item, fsys_scoreboard) dce<%=pidx%>_smi;
<% } //foreach DCE %>
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
//DVE analysis ports 
////////////////////////////////////////////////////////////////////////////////
<% for(var pidx = 0; pidx < obj.nDVEs; pidx++) { %>
uvm_analysis_imp_dve<%=pidx%>_smi #(dve<%=pidx%>_smi_agent_pkg::smi_seq_item, fsys_scoreboard) dve<%=pidx%>_smi;
<% } //foreach DVE %>

   extern function new(string name = "fsys_scoreboard", uvm_component parent = null);
   extern function void build_phase(uvm_phase phase);

   extern static function int get_next_unique_txn_id();
   extern function void print_fsys_txn_q(int print_txn_count = 0);

////////////////////////////////////////////////////////////////////////////////
//AIU write functions 
////////////////////////////////////////////////////////////////////////////////
<% for(var pidx = 0; pidx < _child_blkid.length; pidx++) { %>
  <%  if(_child_blk[pidx].match('chiaiu')) { %>
    extern function void write_<%=_child_blkid[pidx]%>_req_port     ( const ref <%=_child_blkid[pidx]%>_env_pkg::chi_req_seq_item m_pkt  ) ;
    extern function void write_<%=_child_blkid[pidx]%>_wdata_port   ( const ref <%=_child_blkid[pidx]%>_env_pkg::chi_dat_seq_item m_pkt ) ;
    extern function void write_<%=_child_blkid[pidx]%>_srsp_port    ( const ref <%=_child_blkid[pidx]%>_env_pkg::chi_rsp_seq_item m_pkt  ) ;
    extern function void write_<%=_child_blkid[pidx]%>_crsp_port    ( const ref <%=_child_blkid[pidx]%>_env_pkg::chi_rsp_seq_item m_pkt  ) ;
    extern function void write_<%=_child_blkid[pidx]%>_rdata_port   ( const ref <%=_child_blkid[pidx]%>_env_pkg::chi_dat_seq_item m_pkt ) ;
    extern function void write_<%=_child_blkid[pidx]%>_snpaddr_port ( const ref <%=_child_blkid[pidx]%>_env_pkg::chi_snp_seq_item m_pkt  ) ;

    extern function void write_<%=_child_blkid[pidx]%>_smi_port ( const ref <%=_child_blkid[pidx]%>_smi_agent_pkg::smi_seq_item m_pkt);
  <% } // if chiaui%>
////////////////////////////////////////////////////////////////////////////////
  <%  if(_child_blk[pidx].match('ioaiu')) { %>
    extern function void write_<%=_child_blkid[pidx]%>_smi_port(<%=_child_blkid[pidx]%>_smi_agent_pkg::smi_seq_item m_pkt);
    <%for(var i = 0; i < obj.AiuInfo[pidx].nNativeInterfacePorts; i++){%>
      extern function void write_<%=_child_blkid[pidx]%>_core<%=i%>_read_addr_chnl(<%=_child_blkid[pidx]%>_env_pkg::axi4_read_addr_pkt_t m_pkt);
      extern function void write_<%=_child_blkid[pidx]%>_core<%=i%>_write_addr_chnl(<%=_child_blkid[pidx]%>_env_pkg::axi4_write_addr_pkt_t m_pkt);
      extern function void write_<%=_child_blkid[pidx]%>_core<%=i%>_read_data_chnl(<%=_child_blkid[pidx]%>_env_pkg::axi4_read_data_pkt_t m_pkt);
      extern function void write_<%=_child_blkid[pidx]%>_core<%=i%>_read_data_advance_copy_chnl(<%=_child_blkid[pidx]%>_env_pkg::axi4_read_data_pkt_t m_pkt);
      extern function void write_<%=_child_blkid[pidx]%>_core<%=i%>_write_data_chnl(<%=_child_blkid[pidx]%>_env_pkg::axi4_write_data_pkt_t m_pkt);
      extern function void write_<%=_child_blkid[pidx]%>_core<%=i%>_write_resp_chnl(<%=_child_blkid[pidx]%>_env_pkg::axi4_write_resp_pkt_t m_pkt);
      extern function void write_<%=_child_blkid[pidx]%>_core<%=i%>_write_resp_advance_copy_chnl(<%=_child_blkid[pidx]%>_env_pkg::axi4_write_resp_pkt_t m_pkt);

      <% if(obj.AiuInfo[pidx].fnNativeInterface == "ACE5" ||obj.AiuInfo[pidx].fnNativeInterface == "ACE" || obj.AiuInfo[pidx].fnNativeInterface == "ACELITE-E" || obj.AiuInfo[pidx].fnNativeInterface == "ACE-LITE"){ %>
        extern function void write_<%=_child_blkid[pidx]%>_core<%=i%>_ace_snoop_addr_chnl(<%=_child_blkid[pidx]%>_env_pkg::ace_snoop_addr_pkt_t m_pkt);
        extern function void write_<%=_child_blkid[pidx]%>_core<%=i%>_ace_snoop_resp_chnl(<%=_child_blkid[pidx]%>_env_pkg::ace_snoop_resp_pkt_t m_pkt);
        extern function void write_<%=_child_blkid[pidx]%>_core<%=i%>_ace_snoop_data_chnl(<%=_child_blkid[pidx]%>_env_pkg::ace_snoop_data_pkt_t m_pkt);
      <%}%>
    <% } // froeach InterfacePorts%>
  <% } // if ioaiu%>
<% } // foreach aius%>
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
//DMI write functions 
////////////////////////////////////////////////////////////////////////////////
<% for(var pidx = 0; pidx < obj.nDMIs; pidx++) { %>
extern function void write_dmi<%=pidx%>_smi(dmi<%=pidx%>_smi_agent_pkg::smi_seq_item m_pkt);
extern function void write_dmi<%=pidx%>_read_addr_chnl(dmi<%=pidx%>_env_pkg::axi4_read_addr_pkt_t m_pkt);
extern function void write_dmi<%=pidx%>_read_data_chnl(dmi<%=pidx%>_env_pkg::axi4_read_data_pkt_t m_pkt);
extern function void write_dmi<%=pidx%>_write_addr_chnl(dmi<%=pidx%>_env_pkg::axi4_write_addr_pkt_t m_pkt);
extern function void write_dmi<%=pidx%>_write_data_chnl(dmi<%=pidx%>_env_pkg::axi4_write_data_pkt_t m_pkt);
extern function void write_dmi<%=pidx%>_write_resp_chnl(dmi<%=pidx%>_env_pkg::axi4_write_resp_pkt_t m_pkt);
<% } //foreach DMI %>
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
//DII write functions 
////////////////////////////////////////////////////////////////////////////////
<% for(var pidx = 0; pidx < obj.nDIIs; pidx++) { %>
extern function void write_dii<%=pidx%>_smi(dii<%=pidx%>_smi_agent_pkg::smi_seq_item m_pkt);
extern function void write_dii<%=pidx%>_read_addr_chnl(dii<%=pidx%>_env_pkg::axi4_read_addr_pkt_t m_pkt);
extern function void write_dii<%=pidx%>_read_data_chnl(dii<%=pidx%>_env_pkg::axi4_read_data_pkt_t m_pkt);
extern function void write_dii<%=pidx%>_write_addr_chnl(dii<%=pidx%>_env_pkg::axi4_write_addr_pkt_t m_pkt);
extern function void write_dii<%=pidx%>_write_data_chnl(dii<%=pidx%>_env_pkg::axi4_write_data_pkt_t m_pkt);
extern function void write_dii<%=pidx%>_write_resp_chnl(dii<%=pidx%>_env_pkg::axi4_write_resp_pkt_t m_pkt);
<% } //foreach DII %>
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
//DCE write functions 
////////////////////////////////////////////////////////////////////////////////
<% for(var pidx = 0; pidx < obj.nDCEs; pidx++) { %>
extern function void write_dce<%=pidx%>_smi(dce<%=pidx%>_smi_agent_pkg::smi_seq_item m_pkt);
<% } //foreach DCE %>
////////////////////////////////////////////////////////////////////////////////
//DVE write functions 
////////////////////////////////////////////////////////////////////////////////
<% for(var pidx = 0; pidx < obj.nDVEs; pidx++) { %>
extern function void write_dve<%=pidx%>_smi(dve<%=pidx%>_smi_agent_pkg::smi_seq_item m_pkt);
<% } //foreach DCE %>////////////////////////////////////////////////////////////////////////////////

//// End of test checks
extern function void check_phase(uvm_phase phase);

//// Primary simulation time task
extern task run_phase(uvm_phase phase);

extern task time_decay_check();

`ifdef FSYS_BOTH_COVER_ON 
 extern task wait_csr_init_done();
`endif                  

`ifdef FSYS_COVER_ON 
extern task fsys_sys_event_coverage_helper_method();
`endif

extern function void waive_unsupported_txns(bit _del = 0);
//extern function void report_phase(uvm_phase phase);

virtual function void pre_abort();
   waive_unsupported_txns(1);
   `uvm_info("fsys_scoreboard", $psprintf("FSYS_TXN_Q info: Total FSYS_TXN in this run: %0d. Pending: %0d", fsys_unique_txn_id, fsys_txn_q.size()), UVM_NONE)
   print_fsys_txn_q();
   extract_phase(null);
endfunction : pre_abort


endclass : fsys_scoreboard

////////////////////////////////////////////////////////////////////////////////
// Function : new
////////////////////////////////////////////////////////////////////////////////
function fsys_scoreboard::new(string name = "fsys_scoreboard", uvm_component parent = null);
        super.new(name, parent);
         // FSYS COVERAGE
        `ifdef FSYS_COVER_ON 
        fsys_cov = new();
        `endif

        `ifdef FSYS_SCB_COVER_ON 
        fsys_txn_path_cov = new();
        `endif // `ifdef FSYS_SCB_COVER_ON              
endfunction : new

////////////////////////////////////////////////////////////////////////////////
// Function : build_phase
////////////////////////////////////////////////////////////////////////////////
function void fsys_scoreboard::build_phase(uvm_phase phase);

  bit coh_check;
  super.build_phase(phase);

  if($test$plusargs("FSYS_PRED_OFF")) begin
     fsys_pred_off = 1;
  end

  //AIU ports 
  <% for(var pidx = 0; pidx < _child_blkid.length; pidx++) { %>
    <%  if(_child_blk[pidx].match('chiaiu')) { %>
      <%=_child_blkid[pidx]%>_req_port            = new("<%=_child_blkid[pidx]%>_req_port"     , this);
      <%=_child_blkid[pidx]%>_wdata_port          = new("<%=_child_blkid[pidx]%>_wdata_port"   , this);
      <%=_child_blkid[pidx]%>_srsp_port           = new("<%=_child_blkid[pidx]%>_srsp_port"    , this);
      <%=_child_blkid[pidx]%>_crsp_port           = new("<%=_child_blkid[pidx]%>_crsp_port"    , this);
      <%=_child_blkid[pidx]%>_rdata_port          = new("<%=_child_blkid[pidx]%>_rdata_port"   , this);
      <%=_child_blkid[pidx]%>_snpaddr_port        = new("<%=_child_blkid[pidx]%>_snpaddr_port" , this);
      <%=_child_blkid[pidx]%>_smi_port                = new("<%=_child_blkid[pidx]%>_smi_port", this);
    <% } // if chiaui%>

    <%  if(_child_blk[pidx].match('ioaiu')) { %>
      <%=_child_blkid[pidx]%>_smi_port = new("<%=_child_blkid[pidx]%>_smi_port", this);
    <%for(var i = 0; i < obj.AiuInfo[pidx].nNativeInterfacePorts; i++){%>

      <%=_child_blkid[pidx]%>_core<%=i%>_read_addr_port               = new("<%=_child_blkid[pidx]%>_core<%=i%>_read_addr_port", this);
      <%=_child_blkid[pidx]%>_core<%=i%>_read_data_port               = new("<%=_child_blkid[pidx]%>_core<%=i%>_read_data_port", this);
      <%=_child_blkid[pidx]%>_core<%=i%>_read_data_advance_copy_port  = new("<%=_child_blkid[pidx]%>_core<%=i%>_read_data_advance_copy_port", this);
      <%=_child_blkid[pidx]%>_core<%=i%>_write_addr_port              = new("<%=_child_blkid[pidx]%>_core<%=i%>_write_addr_port", this);
      <%=_child_blkid[pidx]%>_core<%=i%>_write_resp_port              = new("<%=_child_blkid[pidx]%>_core<%=i%>_write_resp_port", this);
      <%=_child_blkid[pidx]%>_core<%=i%>_write_resp_advance_copy_port = new("<%=_child_blkid[pidx]%>_core<%=i%>_write_resp_advance_copy_port", this);
      <%=_child_blkid[pidx]%>_core<%=i%>_write_data_port              = new("<%=_child_blkid[pidx]%>_core<%=i%>_write_data_port", this);
      <% if(obj.AiuInfo[pidx].fnNativeInterface == "ACE5" ||obj.AiuInfo[pidx].fnNativeInterface == "ACE" || obj.AiuInfo[pidx].fnNativeInterface == "ACELITE-E" || obj.AiuInfo[pidx].fnNativeInterface == "ACE-LITE"){ %>
       <%=_child_blkid[pidx]%>_core<%=i%>_snoop_addr_port              = new("<%=_child_blkid[pidx]%>_core<%=i%>_snoop_addr_port", this);
       <%=_child_blkid[pidx]%>_core<%=i%>_snoop_resp_port              = new("<%=_child_blkid[pidx]%>_core<%=i%>_snoop_resp_port", this);
       <%=_child_blkid[pidx]%>_core<%=i%>_snoop_data_port              = new("<%=_child_blkid[pidx]%>_core<%=i%>_snoop_data_port", this);
      <%}%>
    <% } // froeach InterfacePorts%>
  <% } // if ioaiu%>
<% } // foreach aius%>

// DMI ports
<% for(var pidx = 0; pidx < obj.nDMIs; pidx++) { %>
dmi<%=pidx%>_smi = new ("dmi<%=pidx%>_smi", this);
dmi<%=pidx%>_read_addr_port  = new ("dmi<%=pidx%>_read_addr_port", this);
dmi<%=pidx%>_read_data_port  = new ("dmi<%=pidx%>_read_data_port", this);
dmi<%=pidx%>_write_addr_port = new ("dmi<%=pidx%>_write_addr_port", this);
dmi<%=pidx%>_write_data_port = new ("dmi<%=pidx%>_write_data_port", this);
dmi<%=pidx%>_write_resp_port = new ("dmi<%=pidx%>_write_resp_port", this);
<% } //foreach DMI %>
// DII ports
<% for(var pidx = 0; pidx < obj.nDIIs; pidx++) { %>
dii<%=pidx%>_smi = new ("dii<%=pidx%>_smi", this);
dii<%=pidx%>_read_addr_port  = new ("dii<%=pidx%>_read_addr_port", this);
dii<%=pidx%>_read_data_port  = new ("dii<%=pidx%>_read_data_port", this);
dii<%=pidx%>_write_addr_port = new ("dii<%=pidx%>_write_addr_port", this);
dii<%=pidx%>_write_data_port = new ("dii<%=pidx%>_write_data_port", this);
dii<%=pidx%>_write_resp_port = new ("dii<%=pidx%>_write_resp_port", this);
<% } //foreach DII %>
// DCE ports
<% for(var pidx = 0; pidx < obj.nDCEs; pidx++) { %>
dce<%=pidx%>_smi = new ("dce<%=pidx%>_smi", this);
<% } //foreach DCE %>
// DVE ports
<% for(var pidx = 0; pidx < obj.nDVEs; pidx++) { %>
dve<%=pidx%>_smi = new ("dve<%=pidx%>_smi", this);
<% } //foreach DVE %>
   //Predictors
   if (fsys_pred_off == 0) begin
      chi_predictor     = fsys_scb_chi_predictor::type_id::create("fsys_scb_chi_predictor", this);
      ioaiu_predictor   = fsys_scb_ioaiu_predictor::type_id::create("fsys_scb_ioaiu_predictor", this);
      ioaiup_predictor  = fsys_scb_ioaiup_predictor::type_id::create("fsys_scb_ioaiup_predictor", this);
      dmi_predictor     = fsys_scb_dmi_predictor::type_id::create("fsys_scb_dmi_predictor", this);
      dii_predictor     = fsys_scb_dii_predictor::type_id::create("fsys_scb_dii_predictor", this);
      dce_predictor     = fsys_scb_dce_predictor::type_id::create("fsys_scb_dce_predictor", this);
      dve_predictor     = fsys_scb_dve_predictor::type_id::create("fsys_scb_dve_predictor", this);
      `ifdef FSYS_SCB_COVER_ON 
      ioaiu_predictor.fsys_txn_path_cov   = fsys_txn_path_cov;
      ioaiup_predictor.fsys_txn_path_cov  = fsys_txn_path_cov;
      chi_predictor.fsys_txn_path_cov     = fsys_txn_path_cov;
      dce_predictor.fsys_txn_path_cov     = fsys_txn_path_cov;
      dii_predictor.fsys_txn_path_cov     = fsys_txn_path_cov;
      dmi_predictor.fsys_txn_path_cov     = fsys_txn_path_cov;
      dve_predictor.fsys_txn_path_cov     = fsys_txn_path_cov;
      `endif // `ifdef FSYS_SCB_COVER_ON              
   end

   `ifdef FSYS_COVER_ON 
    if(!(uvm_config_db #(concerto_env_cfg)::get(uvm_root::get(), "", "m_cfg", m_concerto_env_cfg)))begin
        `uvm_fatal("fsys_scoreboard", "Could not find concerto_env_cfg object in UVM DB");
    end

    <%for(var pidx = 0; pidx < obj.AiuInfo.length; pidx++) { 
        if(obj.AiuInfo[pidx].fnNativeInterface == "ACE5" ||obj.AiuInfo[pidx].fnNativeInterface == "ACE" || 
           obj.AiuInfo[pidx].fnNativeInterface == "CHI-A" || obj.AiuInfo[pidx].fnNativeInterface == "CHI-B"|| obj.AiuInfo[pidx].fnNativeInterface == "CHI-E"){ %>
    if(!uvm_config_db#(virtual event_out_if)::get(.cntxt( uvm_root::get() ),
                                                .inst_name( "" ),
                                                .field_name( "u_event_out_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>" ),
                                                .value( m_event_out_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%> ))) begin
        `uvm_fatal("fsys_scoreboard", "Could not find m_event_out_if_<%=obj.AiuInfo[pidx].strRtlNamePrefix%> object in UVM DB")
    end
   <%}}%>

   `endif

   if (fsys_pred_off == 0) begin
      //MEM_CONSISTENCY
      if($test$plusargs("EN_MEM_CHECK")) begin
         m_en_mem_check = 1;
      end else begin
         m_en_mem_check = 0;
      end
      if(m_en_mem_check) begin
         `uvm_info("mem_consistency_checker", "Memory consistency checker is enabled", UVM_NONE);
         mem_checker = mem_consistency_checker::type_id::create("MEM_CONST", this);
         uvm_config_db#(mem_consistency_checker)::set(uvm_root::get(), "", "mem_checker", mem_checker);
      end
   end
   if ($value$plusargs("EN_COH_CHECK=%0d", coh_check)) begin
      `uvm_info("fsys_coherency_checker", $psprintf("Coherency checker is %0s", coh_check ? "enabled" : "disabled"), UVM_NONE);
   end else begin
      coh_check = 1; //enabled by default
      `uvm_info("fsys_coherency_checker", "Coherency checker is enabled", UVM_NONE);
   end
   if (coh_check) begin
      coherency_checker = fsys_coherency_checker::type_id::create("COH_CHECK", this);
      uvm_config_db#(fsys_coherency_checker)::set(uvm_root::get(), "", "coherency_checker", coherency_checker);
   end

endfunction : build_phase

task fsys_scoreboard::run_phase(uvm_phase phase);
`ifdef FSYS_BOTH_COVER_ON 
  wait_csr_init_done();
`endif                  
 
`ifdef FSYS_COVER_ON 
`ifndef FSYS_COVER_ONLY_ATOMIC
fsys_sys_event_coverage_helper_method();
`endif
`endif
  time_decay_check();
endtask

`ifdef FSYS_BOTH_COVER_ON 
 task fsys_scoreboard::wait_csr_init_done();
fork
begin
     csr_init_done.wait_trigger();
     fsys_cov.sftcrdt.csr_init_done=1;
end     
join_none
 endtask : wait_csr_init_done
`endif                  

`ifdef FSYS_COVER_ON 
`ifndef FSYS_COVER_ONLY_ATOMIC
task fsys_scoreboard::fsys_sys_event_coverage_helper_method();
<% for(var pidx = 0; pidx < obj.nDCEs; pidx++) { %>
bit m_dce<%=pidx%>_event_in_req_ack_handshake_done = 1;
<% } //foreach DCE %>
<% for(var pidx = 0; pidx < obj.nDMIs; pidx++) { %>
bit m_dmi<%=pidx%>_event_in_req_ack_handshake_done = 1;
<% } //foreach DMI %>
<% for(var pidx = 0; pidx < obj.nDIIs; pidx++) { %>
bit m_dii<%=pidx%>_event_in_req_ack_handshake_done = 1;
<% } //foreach DII %>

<%for(var pidx = 0; pidx < obj.AiuInfo.length; pidx++) { 
        if(obj.AiuInfo[pidx].fnNativeInterface == "ACE5" || obj.AiuInfo[pidx].fnNativeInterface == "ACE" || obj.AiuInfo[pidx].fnNativeInterface == "ACELITE-E" ||
           obj.AiuInfo[pidx].fnNativeInterface == "CHI-A" || obj.AiuInfo[pidx].fnNativeInterface == "CHI-B" || obj.AiuInfo[pidx].fnNativeInterface == "CHI-E"){ %>
<% if(obj.AiuInfo[pidx].interfaces.eventRequestInInt._SKIP_ == false) { %>
bit aiu<%=pidx%>_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_event_out_req_ack_handshake_done  = 1;
<%}}}%>

<%for(var pidx = 0; pidx < obj.AiuInfo.length; pidx++) { %>
<% if(obj.AiuInfo[pidx].interfaces.eventRequestOutInt._SKIP_ == false) { %>
bit aiu<%=pidx%>_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_event_in_req_ack_handshake_done  = 1;
 <%}%> 
<%}%>  

fork
<% for(var pidx = 0; pidx < obj.nDCEs ; pidx++) { %>
begin  : dce<%=pidx%>_Thread_1
    //m_concerto_env_cfg.m_dce<%=pidx%>_env_cfg.m_probe_vif
    repeat(1) begin
        @(m_concerto_env_cfg.m_dce<%=pidx%>_env_cfg.m_probe_vif.monitor_cb)
        `uvm_info("fsys_scoreboard::fsys_sys_event_coverage_helper_method", $psprintf("Toggling check done for m_concerto_env_cfg.m_dce<%=pidx%>_env_cfg.m_probe_vif.monitor_cb"), UVM_HIGH)
    end
    forever begin
        @(m_concerto_env_cfg.m_dce<%=pidx%>_env_cfg.m_probe_vif.monitor_cb)
        
        // DCE_exclusive_monitor_store_pass dce<%=pidx%>
        if(m_concerto_env_cfg.m_dce<%=pidx%>_env_cfg.m_probe_vif.store_pass==1) begin
            fsys_cov.sys_event.restore_defaults();
            fsys_cov.sys_event.dce0_exmon_store_pass         = 1;
            fsys_cov.sys_event.DCE_sys_event_sample();
            `uvm_info("fsys_scoreboard::fsys_sys_event_coverage_helper_method", $psprintf("fsys_cov.sys_event.dce_exmon_store_pass goes high for sys_event coverage hit"), UVM_HIGH)
        end

        // DCE_event_in_req_assertion dce<%=pidx%>
        if(m_concerto_env_cfg.m_dce<%=pidx%>_env_cfg.m_probe_vif.event_in_req==1 && m_dce<%=pidx%>_event_in_req_ack_handshake_done) begin
            fsys_cov.sys_event.restore_defaults();
            fsys_cov.sys_event.dce0_event_in_req_assertion   = 1;
            fsys_cov.sys_event.DCE_sys_event_sample();
            m_dce<%=pidx%>_event_in_req_ack_handshake_done = 0;
            `uvm_info("fsys_scoreboard::fsys_sys_event_coverage_helper_method", $psprintf("fsys_cov.sys_event.dce_event_in_req_assertion goes high for sys_event coverage hit"), UVM_HIGH)
        end
        
        // DCE_event_in_ack_assertion dce<%=pidx%>
        if(m_concerto_env_cfg.m_dce<%=pidx%>_env_cfg.m_probe_vif.event_in_ack==1) begin
            fsys_cov.sys_event.restore_defaults();
            fsys_cov.sys_event.dce0_event_in_ack_assertion   = 1;
            fsys_cov.sys_event.DCE_sys_event_sample();
            m_dce<%=pidx%>_event_in_req_ack_handshake_done = 1;
            `uvm_info("fsys_scoreboard::fsys_sys_event_coverage_helper_method", $psprintf("fsys_cov.sys_event.dce_event_in_ack_assertion goes high for sys_event coverage hit"), UVM_HIGH)
            @(m_concerto_env_cfg.m_dce<%=pidx%>_env_cfg.m_probe_vif.monitor_cb);
        end
            
    end
end : dce<%=pidx%>_Thread_1

<% } //foreach DCE %>
<% for(var pidx = 0; pidx < 1; pidx++) { %>
<% if (obj.DiiInfo[pidx].nExclusiveEntries  > 0) { %>
begin  : dii<%=pidx%>_Thread_1
    //m_concerto_env_cfg.m_dce<%=pidx%>_env_cfg.m_probe_vif
    repeat(1) begin
        @(m_concerto_env_cfg.m_dii<%=pidx%>_env_cfg.m_dii_rtl_agent_cfg.m_vif.monitor_cb)
        `uvm_info("fsys_scoreboard::fsys_sys_event_coverage_helper_method", $psprintf("Toggling check done for m_concerto_env_cfg.m_dii<%=pidx%>_env_cfg.m_dii_rtl_agent_cfg.m_vif.monitor_cb"), UVM_LOW)
    end
    forever begin
        @(m_concerto_env_cfg.m_dii<%=pidx%>_env_cfg.m_dii_rtl_agent_cfg.m_vif.monitor_cb)
        // DII_event_in_req_assertion dii<%=pidx%>
        if(m_concerto_env_cfg.m_dii<%=pidx%>_env_cfg.m_dii_rtl_agent_cfg.m_vif.event_in_req==1) begin
            fsys_cov.sys_event.restore_defaults();
            fsys_cov.sys_event.dii<%=pidx%>_event_in_req_assertion   = 1;
            fsys_cov.sys_event.DII_sys_event_sample();
            m_dii<%=pidx%>_event_in_req_ack_handshake_done = 0;
            `uvm_info("fsys_scoreboard::fsys_sys_event_coverage_helper_method", $psprintf("fsys_cov.sys_event.dii_event_in_req_assertion goes high for sys_event coverage hit"), UVM_LOW)
        end
        
        // DII_event_in_ack_assertion dii<%=pidx%>
        if(m_concerto_env_cfg.m_dii<%=pidx%>_env_cfg.m_dii_rtl_agent_cfg.m_vif.event_in_ack==1) begin
            fsys_cov.sys_event.restore_defaults();
            fsys_cov.sys_event.dii<%=pidx%>_event_in_ack_assertion   = 1;
            fsys_cov.sys_event.DII_sys_event_sample();
            m_dii<%=pidx%>_event_in_req_ack_handshake_done = 1;
            `uvm_info("fsys_scoreboard::fsys_sys_event_coverage_helper_method", $psprintf("fsys_cov.sys_event.dii_event_in_ack_assertion goes high for sys_event coverage hit"), UVM_LOW)
            @(m_concerto_env_cfg.m_dii<%=pidx%>_env_cfg.m_dii_rtl_agent_cfg.m_vif.monitor_cb);
        end
            
    end
end : dii<%=pidx%>_Thread_1
<% } %> //if nExclusiveEntries  > 0
<% } //foreach DII %>
//TODO DMI
<%for(var pidx = 0; pidx < obj.AiuInfo.length; pidx++) { %>
<% if(obj.AiuInfo[pidx].interfaces.eventRequestOutInt._SKIP_ == false) { %>
<%  if(_child_blk[pidx].match('ioaiu')) { %>
begin  : aiu<%=pidx%>_0Thread_1

    forever begin
        wait(m_concerto_env_cfg.m_<%=_child_blkid[pidx]%>_env_cfg[0].m_event_agent_cfg.m_vif_slave.req == 1);

        // AIU<%=pidx%>_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_event_in_req_assertion
        if(m_concerto_env_cfg.m_<%=_child_blkid[pidx]%>_env_cfg[0].m_event_agent_cfg.m_vif_slave.req==1 && aiu<%=pidx%>_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_event_in_req_ack_handshake_done) begin
            fsys_cov.sys_event.restore_defaults();
            fsys_cov.sys_event.aiu<%=pidx%>_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_event_in_req_assertion  = 1;
            fsys_cov.sys_event.AIU_sys_event_sample();
            aiu<%=pidx%>_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_event_in_req_ack_handshake_done = 0;
            `uvm_info("fsys_scoreboard::fsys_sys_event_coverage_helper_method", $psprintf("fsys_cov.sys_event.aiu<%=pidx%>_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_event_in_req_assertion goes high for sys_event coverage hit"), UVM_HIGH)
        end
        
        wait(m_concerto_env_cfg.m_<%=_child_blkid[pidx]%>_env_cfg[0].m_event_agent_cfg.m_vif_slave.ack == 1);
        // AIU<%=pidx%>_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_event_in_ack_assertion
        if(m_concerto_env_cfg.m_<%=_child_blkid[pidx]%>_env_cfg[0].m_event_agent_cfg.m_vif_slave.ack==1) begin
            fsys_cov.sys_event.restore_defaults();
            fsys_cov.sys_event.aiu<%=pidx%>_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_event_in_ack_assertion = 1;
            fsys_cov.sys_event.AIU_sys_event_sample();
            aiu<%=pidx%>_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_event_in_req_ack_handshake_done = 1;
            `uvm_info("fsys_scoreboard::fsys_sys_event_coverage_helper_method", $psprintf("fsys_cov.sys_event.aiu<%=pidx%>_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_event_in_ack_assertion goes high for sys_event coverage hit"), UVM_HIGH)
        end
        wait(m_concerto_env_cfg.m_<%=_child_blkid[pidx]%>_env_cfg[0].m_event_agent_cfg.m_vif_slave.req==0 && m_concerto_env_cfg.m_<%=_child_blkid[pidx]%>_env_cfg[0].m_event_agent_cfg.m_vif_slave.ack==0);
            
    end
end : aiu<%=pidx%>_0Thread_1
<% } else { %>
begin  : aiu<%=pidx%>_Thread_1

    forever begin
        wait(m_concerto_env_cfg.m_<%=_child_blkid[pidx]%>_env_cfg.m_event_agent_cfg.m_vif_slave.req == 1);

        // AIU<%=pidx%>_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_event_in_req_assertion
        if(m_concerto_env_cfg.m_<%=_child_blkid[pidx]%>_env_cfg.m_event_agent_cfg.m_vif_slave.req==1 && aiu<%=pidx%>_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_event_in_req_ack_handshake_done) begin
            fsys_cov.sys_event.restore_defaults();
            fsys_cov.sys_event.aiu<%=pidx%>_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_event_in_req_assertion  = 1;
            fsys_cov.sys_event.AIU_sys_event_sample();
            aiu<%=pidx%>_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_event_in_req_ack_handshake_done = 0;
            `uvm_info("fsys_scoreboard::fsys_sys_event_coverage_helper_method", $psprintf("fsys_cov.sys_event.aiu<%=pidx%>_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_event_in_req_assertion goes high for sys_event coverage hit"), UVM_HIGH)
        end
        
        wait(m_concerto_env_cfg.m_<%=_child_blkid[pidx]%>_env_cfg.m_event_agent_cfg.m_vif_slave.ack == 1);
        // AIU<%=pidx%>_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_event_in_ack_assertion
        if(m_concerto_env_cfg.m_<%=_child_blkid[pidx]%>_env_cfg.m_event_agent_cfg.m_vif_slave.ack==1) begin
            fsys_cov.sys_event.restore_defaults();
            fsys_cov.sys_event.aiu<%=pidx%>_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_event_in_ack_assertion = 1;
            fsys_cov.sys_event.AIU_sys_event_sample();
            aiu<%=pidx%>_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_event_in_req_ack_handshake_done = 1;
            `uvm_info("fsys_scoreboard::fsys_sys_event_coverage_helper_method", $psprintf("fsys_cov.sys_event.aiu<%=pidx%>_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_event_in_ack_assertion goes high for sys_event coverage hit"), UVM_HIGH)
        end
        wait(m_concerto_env_cfg.m_<%=_child_blkid[pidx]%>_env_cfg.m_event_agent_cfg.m_vif_slave.req==0 && m_concerto_env_cfg.m_<%=_child_blkid[pidx]%>_env_cfg.m_event_agent_cfg.m_vif_slave.ack==0);
            
    end
end : aiu<%=pidx%>_Thread_1
<%}%> 
 <%}%> 
<%}%>
<%for(var pidx = 0; pidx < obj.AiuInfo.length; pidx++) { %>
<% if(obj.AiuInfo[pidx].interfaces.eventRequestInInt._SKIP_ == false) { %>
<%  if(_child_blk[pidx].match('ioaiu')) { %>
<%  if(obj.AiuInfo[pidx].fnNativeInterface == "ACE5" ||obj.AiuInfo[pidx].fnNativeInterface == "ACE" || obj.AiuInfo[pidx].fnNativeInterface == "ACELITE-E"){ %>
begin  : aiu<%=pidx%>_0Thread_2

    forever begin
        wait(m_concerto_env_cfg.m_<%=_child_blkid[pidx]%>_env_cfg[0].m_event_agent_cfg.m_vif_master.req == 1);

        // AIU<%=pidx%>_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_event_out_req_assertion
        if(m_concerto_env_cfg.m_<%=_child_blkid[pidx]%>_env_cfg[0].m_event_agent_cfg.m_vif_master.req==1 && aiu<%=pidx%>_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_event_out_req_ack_handshake_done) begin
            fsys_cov.sys_event.restore_defaults();
            fsys_cov.sys_event.aiu<%=pidx%>_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_event_out_req_assertion  = 1;
            fsys_cov.sys_event.AIU_sys_event_sample();
            aiu<%=pidx%>_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_event_out_req_ack_handshake_done = 0;
            `uvm_info("fsys_scoreboard::fsys_sys_event_coverage_helper_method", $psprintf("fsys_cov.sys_event.aiu<%=pidx%>_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_event_out_req_assertion goes high for sys_event coverage hit"), UVM_HIGH)
        end
        
        wait(m_concerto_env_cfg.m_<%=_child_blkid[pidx]%>_env_cfg[0].m_event_agent_cfg.m_vif_master.ack == 1);
        // AIU<%=pidx%>_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_event_out_ack_assertion
        if(m_concerto_env_cfg.m_<%=_child_blkid[pidx]%>_env_cfg[0].m_event_agent_cfg.m_vif_master.ack==1) begin
            fsys_cov.sys_event.restore_defaults();
            fsys_cov.sys_event.aiu<%=pidx%>_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_event_out_ack_assertion = 1;
            fsys_cov.sys_event.AIU_sys_event_sample();
            aiu<%=pidx%>_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_event_out_req_ack_handshake_done = 1;
            `uvm_info("fsys_scoreboard::fsys_sys_event_coverage_helper_method", $psprintf("fsys_cov.sys_event.aiu<%=pidx%>_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_event_out_ack_assertion goes high for sys_event coverage hit"), UVM_HIGH)
        end
        wait(m_concerto_env_cfg.m_<%=_child_blkid[pidx]%>_env_cfg[0].m_event_agent_cfg.m_vif_master.req==0 && m_concerto_env_cfg.m_<%=_child_blkid[pidx]%>_env_cfg[0].m_event_agent_cfg.m_vif_master.ack==0);
            
    end
end : aiu<%=pidx%>_0Thread_2
<%}%>
<% } else { %>
begin  : aiu<%=pidx%>_Thread_2

    forever begin
        wait(m_concerto_env_cfg.m_<%=_child_blkid[pidx]%>_env_cfg.m_event_agent_cfg.m_vif_master.req == 1);

        // AIU<%=pidx%>_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_event_out_req_assertion
        if(m_concerto_env_cfg.m_<%=_child_blkid[pidx]%>_env_cfg.m_event_agent_cfg.m_vif_master.req==1 && aiu<%=pidx%>_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_event_out_req_ack_handshake_done) begin
            fsys_cov.sys_event.restore_defaults();
            fsys_cov.sys_event.aiu<%=pidx%>_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_event_out_req_assertion  = 1;
            fsys_cov.sys_event.AIU_sys_event_sample();
            aiu<%=pidx%>_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_event_out_req_ack_handshake_done = 0;
            `uvm_info("fsys_scoreboard::fsys_sys_event_coverage_helper_method", $psprintf("fsys_cov.sys_event.aiu<%=pidx%>_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_event_out_req_assertion goes high for sys_event coverage hit"), UVM_HIGH)
        end
        
        wait(m_concerto_env_cfg.m_<%=_child_blkid[pidx]%>_env_cfg.m_event_agent_cfg.m_vif_master.ack == 1);
        // AIU<%=pidx%>_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_event_out_ack_assertion
        if(m_concerto_env_cfg.m_<%=_child_blkid[pidx]%>_env_cfg.m_event_agent_cfg.m_vif_master.ack==1) begin
            fsys_cov.sys_event.restore_defaults();
            fsys_cov.sys_event.aiu<%=pidx%>_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_event_out_ack_assertion = 1;
            fsys_cov.sys_event.AIU_sys_event_sample();
            aiu<%=pidx%>_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_event_out_req_ack_handshake_done = 1;
            `uvm_info("fsys_scoreboard::fsys_sys_event_coverage_helper_method", $psprintf("fsys_cov.sys_event.aiu<%=pidx%>_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_event_out_ack_assertion goes high for sys_event coverage hit"), UVM_HIGH)
        end
        wait(m_concerto_env_cfg.m_<%=_child_blkid[pidx]%>_env_cfg.m_event_agent_cfg.m_vif_master.req==0 && m_concerto_env_cfg.m_<%=_child_blkid[pidx]%>_env_cfg.m_event_agent_cfg.m_vif_master.ack==0);
            
    end
end : aiu<%=pidx%>_Thread_2
<%}%> 
 <%}%> 
<%}%>

join_none
endtask
`endif
`endif

////////////////////////////////////////////////////////////////////////////////////////////////////////
//Primary run time task to check for txn inactivity in the fsys_txn_q every #fsys_time_decay ps delay
////////////////////////////////////////////////////////////////////////////////////////////////////////
task fsys_scoreboard::time_decay_check();
  time fsys_time_decay_def = 140000000; 
  time fsys_time_decay_min =  10000000;
  time fsys_time_decay, last_checkpoint, curr_checkpoint;
  bit  tdc_disable = 0; 

  if((!$test$plusargs("EN_FSYS_SCB")) || $test$plusargs("DIS_FSYS_SCB")) tdc_disable = 1;
  else begin
    if($value$plusargs("FSYS_TIME_DECAY=%d",fsys_time_decay)) begin //Timescale in ps, use 0 to turn off all checks
      if(fsys_time_decay == 0) begin
        tdc_disable = 1;
        `uvm_info("fsys_time_decay","Time value set to 0, disabling checks",UVM_NONE)
      end else if(fsys_time_decay < fsys_time_decay_min) begin
        fsys_time_decay = fsys_time_decay_min;
        `uvm_info("fsys_time_decay", $sformatf("Time value chosen is lower than minimum value. Using default value %0dus", fsys_time_decay/1000000),UVM_NONE)
      end else begin
        `uvm_info("fsys_time_decay", $sformatf("FSYS_TIME_DECAY value set to %0dus", fsys_time_decay/1000000), UVM_NONE)
      end
    end
    else begin
      fsys_time_decay = fsys_time_decay_def;
      `uvm_info("fsys_time_decay", $sformatf("No +FSYS_TIME_DECAY option passed, using default value of %0dus", fsys_time_decay/1000000), UVM_NONE)
    end
  end

  if(!tdc_disable) begin
  fork
    forever begin
      #(fsys_time_decay);
      curr_checkpoint = $time;
      if(fsys_txn_q.size()!=0) begin
        `uvm_info("fsys_time_decay", $sformatf("Checking for inactivity in txn queue %0dns", curr_checkpoint/1000), UVM_FULL)
        waive_unsupported_txns();
        foreach(fsys_txn_q[idx]) begin
          if(!(fsys_txn_q[idx].fsys_unique_txn_id inside {waive_txn_q}) && (fsys_txn_q[idx].last_active_point < last_checkpoint)) begin 
            `uvm_error("fsys_time_decay",$sformatf("FSYS_UID:%0d : No activity logged in txn for %0dns, last active at %0dns", fsys_txn_q[idx].fsys_unique_txn_id, (curr_checkpoint - fsys_txn_q[idx].last_active_point)/1000, fsys_txn_q[idx].last_active_point/1000))
          end
        end
      end
      last_checkpoint = curr_checkpoint;
    end
  join_none
  end
endtask

////////////////////////////////////////////////////////////////////////////////
// Check an index value for waived checks and evict them from the queue 
////////////////////////////////////////////////////////////////////////////////
function void fsys_scoreboard::waive_unsupported_txns(bit _del=0);
  for(int i = (fsys_txn_q.size()-1); i >= 0; i--) begin
  <% for(var pidx = 0; pidx < _child_blkid.length; pidx++) { %>
  <%  if(_child_blk[pidx].match('ioaiu')) { %>
      if (fsys_txn_q[i].m_axi_wr_addr_pkt_<%=pidx%> !== null 
         && <%=obj.AiuInfo[pidx].useCache%> == 1
         //&& fsys_txn_q[i].str_msg_id_q.size() == 0
         && fsys_txn_q[i].axi_data_seen == 1) begin
        if(_del) begin
          `uvm_info("waive_unsupported_txns", $sformatf("FSYS_UID:%0d : Not Yet Implemented (Proxy Cache Support) Deleting unfinished write transaction on proxy cache IOAIU from fsys_txn_q. Remaining txns: 'd%0d", fsys_txn_q[i].fsys_unique_txn_id, (fsys_txn_q.size()-1)), UVM_NONE)
          fsys_txn_q.delete(i);
          continue;
        end
        else begin
          if(!(fsys_txn_q[i].fsys_unique_txn_id inside {waive_txn_q}) ) begin
            waive_txn_q.push_back(fsys_txn_q[i].fsys_unique_txn_id);
            continue;
          end
        end
      end
      else if (fsys_txn_q[i].m_axi_rd_addr_pkt_<%=pidx%> !== null 
         && <%=obj.AiuInfo[pidx].useCache%> == 1
         && fsys_txn_q[i].str_msg_id_q.size() == fsys_txn_q[i].aiu_str_cnt
         && fsys_txn_q[i].axi_data_seen == 1) begin
        if(_del) begin
          `uvm_info("waive_unsupported_txns", $sformatf("FSYS_UID:%0d : Not Yet Implemented (Proxy Cache Support) Deleting unfinished read transaction on proxy cache IOAIU from fsys_txn_q. Remaining txns: 'd%0d", fsys_txn_q[i].fsys_unique_txn_id, (fsys_txn_q.size()-1)), UVM_NONE)
          fsys_txn_q.delete(i);
          continue;
        end
        else begin 
          if(!(fsys_txn_q[i].fsys_unique_txn_id inside {waive_txn_q})) begin
            waive_txn_q.push_back(fsys_txn_q[i].fsys_unique_txn_id);
            continue;
          end
        end
      end
      else if (fsys_txn_q[i].m_axi_wr_addr_pkt_<%=pidx%> !== null
         && fsys_txn_q[i].is_stash_txn == 1 
         && fsys_txn_q[i].is_dataless_txn == 1
         && fsys_txn_q[i].mrdreq_seen_q[0] == 0
         && fsys_txn_q[i].str_msg_id_q.size() == fsys_txn_q[i].aiu_str_cnt) begin
        if(_del) begin
          `uvm_info("waive_unsupported_txns", $sformatf("FSYS_UID:%0d : Known Issue: No MRD generated for StashOnce. Deleting finished stash txn from fsys_txn_q. Remaining txns: 'd%0d", fsys_txn_q[i].fsys_unique_txn_id, (fsys_txn_q.size()-1)), UVM_NONE)
           fsys_txn_q.delete(i);
           continue;
        end
        else begin 
          if(!(fsys_txn_q[i].fsys_unique_txn_id inside {waive_txn_q})) begin
            waive_txn_q.push_back(fsys_txn_q[i].fsys_unique_txn_id);
            continue;
          end
        end
      end
  <% } // if ioaiu%>
  <%  if(_child_blk[pidx].match('chiaiu')) { %>
     if (fsys_txn_q[i].m_chi_req_pkt_<%=pidx%> !== null
        && fsys_txn_q[i].is_stash_txn == 1 
        && fsys_txn_q[i].mrdreq_seen_q[0] == 0
        && fsys_txn_q[i].aiu_str_seen == 1) begin
        if(_del) begin
          `uvm_info("waive_unsupported_txns", $sformatf("FSYS_UID:%0d : Known Issue: No MRD generated for StashOnce. Deleting finished stash txn from fsys_txn_q. Remaining txns: 'd%0d", fsys_txn_q[i].fsys_unique_txn_id, (fsys_txn_q.size()-1)), UVM_NONE)
          fsys_txn_q.delete(i);
          continue;
        end
        else begin 
          if(!(fsys_txn_q[i].fsys_unique_txn_id inside {waive_txn_q})) begin
            waive_txn_q.push_back(fsys_txn_q[i].fsys_unique_txn_id);
            continue;
          end
        end
     end
  <% } // if chiaiu%>
  <% } // foreach aius%>
  end
endfunction

////////////////////////////////////////////////////////////////////////////////
// Function: check_phase
// Description: Runs end of test checks and prints debug information
////////////////////////////////////////////////////////////////////////////////
function void fsys_scoreboard::check_phase(uvm_phase phase);
   if (fsys_pred_off == 0) begin
      `uvm_info("check_phase", $sformatf("Total IOAIU Transactions seen | Read : %0d, Write: %0d ", ioaiu_predictor.ioaiu_rdtxn_cnt, ioaiu_predictor.ioaiu_wrtxn_cnt), UVM_NONE)
      `uvm_info("check_phase", $sformatf("IOAIU Latency | Min : %0dns, Max %0dns ", ioaiu_predictor.min_latency/1000, ioaiu_predictor.max_latency/1000), UVM_NONE)
      `uvm_info("check_phase", $sformatf("Total IOAIUp Transactions seen | Read : %0d, Write: %0d ", ioaiup_predictor.ioaiu_rdtxn_cnt, ioaiup_predictor.ioaiu_wrtxn_cnt), UVM_NONE)
      `uvm_info("check_phase", $sformatf("IOAIUp Latency | Min : %0dns, Max %0dns ", ioaiup_predictor.min_latency/1000, ioaiup_predictor.max_latency/1000), UVM_NONE)
      `uvm_info("check_phase", $sformatf("Total CHIAIU Transactions seen : %0d ", chi_predictor.chi_txn_cnt ), UVM_NONE)
   end
   waive_unsupported_txns(1);
   if (fsys_txn_q.size() !== 0) begin
      print_fsys_txn_q();
      `uvm_error("check_phase", $psprintf("FSYS_SCB: FSYS_TXN_Q is not empty. %0d transaction are still pending", fsys_txn_q.size()))
   end
endfunction : check_phase

////////////////////////////////////////////////////////////////////////////////
// Function: print_fsys_txn_q 
// Description: Prints pending txn queue
////////////////////////////////////////////////////////////////////////////////
function void fsys_scoreboard::print_fsys_txn_q(int print_txn_count = 0);
   int cnt_limit = print_txn_count;
   int count;
   foreach(fsys_txn_q[idx]) begin
      fsys_txn_q[idx].print_me();
      count++;
      if (cnt_limit > 0 && count == cnt_limit) break;
   end //foreach pending txn
endfunction : print_fsys_txn_q

////////////////////////////////////////////////////////////////////////////////
// Function: get_next_unique_txn_id
// Description: Returns value of fsys_unique_txn_id and increments it
////////////////////////////////////////////////////////////////////////////////
static function int fsys_scoreboard::get_next_unique_txn_id();
   return(fsys_unique_txn_id++);
endfunction : get_next_unique_txn_id

////////////////////////////////////////////////////////////////////////////////
// Function: CHI AIU write() functions
////////////////////////////////////////////////////////////////////////////////
<% for(var pidx = 0; pidx < _child_blkid.length; pidx++) { %>
<%  if(_child_blk[pidx].match('chiaiu')) { %>
function void fsys_scoreboard::write_<%=_child_blkid[pidx]%>_req_port     ( const ref <%=_child_blkid[pidx]%>_env_pkg::chi_req_seq_item m_pkt  ) ;
   string func_name = "write_<%=_child_blkid[pidx]%>_req_port";
   `uvm_info(func_name, $sformatf("Packet received on %0s", func_name), UVM_HIGH)
    `ifdef FSYS_COVER_ON
   `ifndef FSYS_COVER_ONLY_ATOMIC
   fsys_cov.aiu_qos.collect_item_<%=_child_blkid[pidx]%>_core0();
   fsys_cov.xxxcorr_err.collect_item_<%=_child_blkid[pidx]%>();
   fsys_cov.sftcrdt.collect_item_<%=_child_blkid[pidx]%>();
   `endif
   fsys_cov.native_itf.collect_item_req_<%=_child_blkid[pidx]%>(m_pkt);
   `endif
   if (fsys_pred_off == 0) begin
      chi_predictor.analyze_chi_req_<%=pidx%>(m_pkt, fsys_txn_q);
   end 
endfunction : write_<%=_child_blkid[pidx]%>_req_port

function void fsys_scoreboard::write_<%=_child_blkid[pidx]%>_wdata_port   ( const ref <%=_child_blkid[pidx]%>_env_pkg::chi_dat_seq_item m_pkt ) ;
   string func_name = "write_<%=_child_blkid[pidx]%>_wdata_port"; 
   `uvm_info(func_name, $sformatf("Packet received on %0s", func_name), UVM_HIGH)
    `ifdef FSYS_COVER_ON
   `ifndef FSYS_COVER_ONLY_ATOMIC
   fsys_cov.xxxcorr_err.collect_item_<%=_child_blkid[pidx]%>();
   fsys_cov.sftcrdt.collect_item_<%=_child_blkid[pidx]%>();
   fsys_cov.native_itf.collect_item_snp_wdat_resp_<%=_child_blkid[pidx]%>(m_pkt);
   `endif
   `endif
   if (fsys_pred_off == 0) begin
      chi_predictor.analyze_chi_wdata_pkt_<%=pidx%>(m_pkt, fsys_txn_q);
   end 
endfunction : write_<%=_child_blkid[pidx]%>_wdata_port

function void fsys_scoreboard::write_<%=_child_blkid[pidx]%>_srsp_port    ( const ref <%=_child_blkid[pidx]%>_env_pkg::chi_rsp_seq_item m_pkt  ) ;
   string func_name = "write_<%=_child_blkid[pidx]%>_srsp_port"; 
   `uvm_info(func_name, $sformatf("Packet received on %0s", func_name), UVM_HIGH)
   `ifdef FSYS_COVER_ON                                    
   `ifndef FSYS_COVER_ONLY_ATOMIC
   fsys_cov.aiu_qos.collect_item_<%=_child_blkid[pidx]%>_core0();
   fsys_cov.xxxcorr_err.collect_item_<%=_child_blkid[pidx]%>();
   fsys_cov.sftcrdt.collect_item_<%=_child_blkid[pidx]%>(); 
   fsys_cov.native_itf.collect_item_snp_srsp_resp_<%=_child_blkid[pidx]%>(m_pkt);
   `endif                                                   
   `endif                                                   
   if (fsys_pred_off == 0) begin
      chi_predictor.analyze_chi_srsp_pkt_<%=pidx%>(m_pkt, fsys_txn_q);
   end
endfunction : write_<%=_child_blkid[pidx]%>_srsp_port

function void fsys_scoreboard::write_<%=_child_blkid[pidx]%>_crsp_port    ( const ref <%=_child_blkid[pidx]%>_env_pkg::chi_rsp_seq_item m_pkt  ) ;
   string func_name = "write_<%=_child_blkid[pidx]%>_crsp_port"; 
   `uvm_info(func_name, $sformatf("Packet received on %0s", func_name), UVM_HIGH)
   `ifdef FSYS_COVER_ON                                    
   `ifndef FSYS_COVER_ONLY_ATOMIC
   fsys_cov.aiu_qos.collect_item_<%=_child_blkid[pidx]%>_core0();
   fsys_cov.xxxcorr_err.collect_item_<%=_child_blkid[pidx]%>();
   fsys_cov.sftcrdt.collect_item_<%=_child_blkid[pidx]%>(); 
   fsys_cov.native_itf.collect_item_cresp_<%=_child_blkid[pidx]%>(m_pkt);
   `endif                                                   
   `endif                                                   
   if (fsys_pred_off == 0) begin
      chi_predictor.analyze_chi_crsp_pkt_<%=pidx%>(m_pkt, fsys_txn_q);
   end
endfunction : write_<%=_child_blkid[pidx]%>_crsp_port

function void fsys_scoreboard::write_<%=_child_blkid[pidx]%>_rdata_port   ( const ref <%=_child_blkid[pidx]%>_env_pkg::chi_dat_seq_item m_pkt ) ;
   string func_name = "write_<%=_child_blkid[pidx]%>_rdata_port"; 
   `uvm_info(func_name, $sformatf("Packet received on %0s", func_name), UVM_HIGH)
   `ifdef FSYS_COVER_ON                                    
   `ifndef FSYS_COVER_ONLY_ATOMIC
   fsys_cov.aiu_qos.collect_item_<%=_child_blkid[pidx]%>_core0();
   fsys_cov.xxxcorr_err.collect_item_<%=_child_blkid[pidx]%>();
   fsys_cov.sftcrdt.collect_item_<%=_child_blkid[pidx]%>(); 
   fsys_cov.native_itf.collect_item_data_resp_<%=_child_blkid[pidx]%>(m_pkt);
   `endif                                                   
   `endif                                                   
   if (fsys_pred_off == 0) begin
      chi_predictor.analyze_chi_rdata_pkt_<%=pidx%>(m_pkt, fsys_txn_q);
   end
endfunction : write_<%=_child_blkid[pidx]%>_rdata_port

function void fsys_scoreboard::write_<%=_child_blkid[pidx]%>_snpaddr_port ( const ref <%=_child_blkid[pidx]%>_env_pkg::chi_snp_seq_item m_pkt  ) ;
   string func_name = "write_<%=_child_blkid[pidx]%>_snpaddr_port"; 
   `uvm_info(func_name, $sformatf("Packet received on %0s", func_name), UVM_HIGH)
   `ifdef FSYS_COVER_ON                                    
   `ifndef FSYS_COVER_ONLY_ATOMIC
   fsys_cov.aiu_qos.collect_item_<%=_child_blkid[pidx]%>_core0();
   fsys_cov.xxxcorr_err.collect_item_<%=_child_blkid[pidx]%>();
   fsys_cov.sftcrdt.collect_item_<%=_child_blkid[pidx]%>(); 
   fsys_cov.native_itf.collect_item_snpaddr_<%=_child_blkid[pidx]%>(m_pkt);
   `endif                                                   
   `endif                                                   
   if (fsys_pred_off == 0) begin
      chi_predictor.analyze_chi_snpaddr_pkt_<%=pidx%>(m_pkt, fsys_txn_q);
   end
endfunction : write_<%=_child_blkid[pidx]%>_snpaddr_port

function void fsys_scoreboard::write_<%=_child_blkid[pidx]%>_smi_port ( const ref <%=_child_blkid[pidx]%>_smi_agent_pkg::smi_seq_item m_pkt);
   string func_name = "write_<%=_child_blkid[pidx]%>_smi_port"; 
   `uvm_info(func_name, $sformatf("Packet received on %0s", func_name), UVM_HIGH)
   `ifdef FSYS_COVER_ON
   `ifndef FSYS_COVER_ONLY_ATOMIC
   fsys_cov.aiu_qos.collect_item_<%=_child_blkid[pidx]%>_core0();
   fsys_cov.xxxcorr_err.collect_item_<%=_child_blkid[pidx]%>();
   fsys_cov.sftcrdt.collect_item_<%=_child_blkid[pidx]%>();
   fsys_cov.smi.collect_item_<%=_child_blkid[pidx]%>(m_pkt);
   `endif
   fsys_cov.atomic.collect_item_<%=_child_blkid[pidx]%>(m_pkt);
   `endif
   if (fsys_pred_off == 0) begin
      chi_predictor.analyze_smi_pkt_<%=pidx%>(m_pkt, fsys_txn_q);
   end
endfunction : write_<%=_child_blkid[pidx]%>_smi_port
<% } // if chiaui%>
<% } // foreach aius%>
////////////////////////////////////////////////////////////////////////////////
// Function: IOAIU write() functions
////////////////////////////////////////////////////////////////////////////////
<% for(var pidx = 0; pidx < _child_blkid.length; pidx++) { %>
<%  if(_child_blk[pidx].match('ioaiu')) { %>
function void fsys_scoreboard::write_<%=_child_blkid[pidx]%>_smi_port(<%=_child_blkid[pidx]%>_smi_agent_pkg::smi_seq_item m_pkt);
   string func_name = "write_<%=_child_blkid[pidx]%>_smi_port"; 
   `uvm_info(func_name, $sformatf("Packet received on %0s,msgtype 0x%0h", func_name, m_pkt.smi_msg_type), UVM_HIGH)
   `ifdef FSYS_COVER_ON
   `ifndef FSYS_COVER_ONLY_ATOMIC
   <%for(var i = 0; i < obj.AiuInfo[pidx].nNativeInterfacePorts; i++){%>
   fsys_cov.xxxcorr_err.collect_item_<%=_child_blkid[pidx]%>_core<%=i%>();
   fsys_cov.aiu_qos.collect_item_<%=_child_blkid[pidx]%>_core<%=i%>();
   <%} // each core%>
   <%if(Array.isArray(obj.AiuInfo[pidx].interfaces.axiInt)){
               computedAxiInt = obj.AiuInfo[pidx].interfaces.axiInt[0];
   }else{
               computedAxiInt = obj.AiuInfo[pidx].interfaces.axiInt;
   }%>
   <%if((obj.AiuInfo[pidx].fnNativeInterface == 'ACE5' || obj.AiuInfo[pidx].fnNativeInterface == 'ACELITE-E' || obj.AiuInfo[pidx].fnNativeInterface == 'AXI5') && (computedAxiInt.params.checkType=="ODD_PARITY_BYTE_ALL")) {%>
   fsys_cov.if_parity_chk.collect_item_<%=_child_blkid[pidx]%>();
   <%}%>
   fsys_cov.sftcrdt.collect_item_<%=_child_blkid[pidx]%>();
   fsys_cov.smi.collect_item_<%=_child_blkid[pidx]%>(m_pkt);
   `endif
   fsys_cov.atomic.collect_item_<%=_child_blkid[pidx]%>(m_pkt);
   `endif
   if (fsys_pred_off == 0) begin
      <% if(obj.AiuInfo[pidx].orderedWriteObservation == 1) { %>
         ioaiup_predictor.analyze_smi_pkt_<%=pidx%>(m_pkt, fsys_txn_q);
      <% //IOAIUp %> 
      <%} else { %>
         ioaiu_predictor.analyze_smi_pkt_<%=pidx%>(m_pkt, fsys_txn_q);
      <% } %>
   end
endfunction : write_<%=_child_blkid[pidx]%>_smi_port

<%for(var i = 0; i < obj.AiuInfo[pidx].nNativeInterfacePorts; i++){%>
function void fsys_scoreboard::write_<%=_child_blkid[pidx]%>_core<%=i%>_read_addr_chnl(<%=_child_blkid[pidx]%>_env_pkg::axi4_read_addr_pkt_t m_pkt);
   string func_name = "write_<%=_child_blkid[pidx]%>_core<%=i%>_read_addr_chnl"; 
   `uvm_info(func_name, $sformatf("Packet received on %0s", func_name), UVM_HIGH)
   `ifdef FSYS_COVER_ON
   `ifndef FSYS_COVER_ONLY_ATOMIC
   fsys_cov.aiu_qos.collect_item_<%=_child_blkid[pidx]%>_core<%=i%>();
   fsys_cov.xxxcorr_err.collect_item_<%=_child_blkid[pidx]%>_core<%=i%>();
   <%if(Array.isArray(obj.AiuInfo[pidx].interfaces.axiInt)){
               computedAxiInt = obj.AiuInfo[pidx].interfaces.axiInt[0];
   }else{
               computedAxiInt = obj.AiuInfo[pidx].interfaces.axiInt;
   }%>
   <%if((obj.AiuInfo[pidx].fnNativeInterface == 'ACE5' || obj.AiuInfo[pidx].fnNativeInterface == 'ACELITE-E' || obj.AiuInfo[pidx].fnNativeInterface == 'AXI5') && (computedAxiInt.params.checkType=="ODD_PARITY_BYTE_ALL")) {%>
   fsys_cov.if_parity_chk.collect_item_<%=_child_blkid[pidx]%>();
   <%}%>
   fsys_cov.sftcrdt.collect_item_<%=_child_blkid[pidx]%>();
   fsys_cov.native_itf.collect_item_rd_<%=_child_blkid[pidx]%>(m_pkt);
   <% if (obj.AiuInfo[pidx].nNativeInterfacePorts > 1) { %>fsys_cov.native_itf.<%=_child_blkid[pidx]%>_c<%=i%>_txn = 1; // txn pass through core <%=i%> <%}%>
   `endif
   `endif
   if (fsys_pred_off == 0) begin
      <% if(obj.AiuInfo[pidx].orderedWriteObservation == 1) { %>
         ioaiup_predictor.analyze_read_addr_pkt_<%=pidx%>_<%=i%>(m_pkt, fsys_txn_q);
      <% //IOAIUp %> 
      <%} else { %>
         ioaiu_predictor.analyze_read_addr_pkt_<%=pidx%>_<%=i%>(m_pkt, fsys_txn_q);
      <% } %>
   end
endfunction : write_<%=_child_blkid[pidx]%>_core<%=i%>_read_addr_chnl
function void fsys_scoreboard::write_<%=_child_blkid[pidx]%>_core<%=i%>_write_addr_chnl(<%=_child_blkid[pidx]%>_env_pkg::axi4_write_addr_pkt_t m_pkt);
   string func_name = "write_<%=_child_blkid[pidx]%>_core<%=i%>_write_addr_chnl"; 
   `uvm_info(func_name, $sformatf("Packet received on %0s", func_name), UVM_HIGH)
   `ifdef FSYS_COVER_ON
   `ifndef FSYS_COVER_ONLY_ATOMIC
   fsys_cov.aiu_qos.collect_item_<%=_child_blkid[pidx]%>_core<%=i%>();
   fsys_cov.xxxcorr_err.collect_item_<%=_child_blkid[pidx]%>_core<%=i%>();
   <%if(Array.isArray(obj.AiuInfo[pidx].interfaces.axiInt)){
               computedAxiInt = obj.AiuInfo[pidx].interfaces.axiInt[0];
   }else{
               computedAxiInt = obj.AiuInfo[pidx].interfaces.axiInt;
   }%>
   <%if((obj.AiuInfo[pidx].fnNativeInterface == 'ACE5' || obj.AiuInfo[pidx].fnNativeInterface == 'ACELITE-E' || obj.AiuInfo[pidx].fnNativeInterface == 'AXI5') && (computedAxiInt.params.checkType=="ODD_PARITY_BYTE_ALL")) {%>
   fsys_cov.if_parity_chk.collect_item_<%=_child_blkid[pidx]%>();
   <%}%>
   fsys_cov.sftcrdt.collect_item_<%=_child_blkid[pidx]%>();
   `endif
   fsys_cov.native_itf.collect_item_wr_<%=_child_blkid[pidx]%>(m_pkt);
   <% if (obj.AiuInfo[pidx].nNativeInterfacePorts > 1) { %>fsys_cov.native_itf.<%=_child_blkid[pidx]%>_c<%=i%>_txn = 1; // txn pass through core <%=i%> <%}%>
   `endif
   if (fsys_pred_off == 0) begin
      <% if(obj.AiuInfo[pidx].orderedWriteObservation == 1) { %>
         ioaiup_predictor.analyze_write_addr_pkt_<%=pidx%>_<%=i%>(m_pkt, fsys_txn_q);
      <% //IOAIUp %> 
      <%} else { %>
         ioaiu_predictor.analyze_write_addr_pkt_<%=pidx%>_<%=i%>(m_pkt, fsys_txn_q);
      <% } %>
   end
endfunction : write_<%=_child_blkid[pidx]%>_core<%=i%>_write_addr_chnl
function void fsys_scoreboard::write_<%=_child_blkid[pidx]%>_core<%=i%>_read_data_chnl(<%=_child_blkid[pidx]%>_env_pkg::axi4_read_data_pkt_t m_pkt);
   string func_name = "write_<%=_child_blkid[pidx]%>_core<%=i%>_read_data_chnl"; 
   `uvm_info(func_name, $sformatf("Packet received on %0s", func_name), UVM_HIGH)
   `ifdef FSYS_COVER_ON
   `ifndef FSYS_COVER_ONLY_ATOMIC
   fsys_cov.aiu_qos.collect_item_<%=_child_blkid[pidx]%>_core<%=i%>();
   fsys_cov.xxxcorr_err.collect_item_<%=_child_blkid[pidx]%>_core<%=i%>();
   <%if(Array.isArray(obj.AiuInfo[pidx].interfaces.axiInt)){
               computedAxiInt = obj.AiuInfo[pidx].interfaces.axiInt[0];
   }else{
               computedAxiInt = obj.AiuInfo[pidx].interfaces.axiInt;
   }%>
   <%if((obj.AiuInfo[pidx].fnNativeInterface == 'ACE5' || obj.AiuInfo[pidx].fnNativeInterface == 'ACELITE-E' || obj.AiuInfo[pidx].fnNativeInterface == 'AXI5') && (computedAxiInt.params.checkType=="ODD_PARITY_BYTE_ALL")) {%>
   fsys_cov.if_parity_chk.collect_item_<%=_child_blkid[pidx]%>();
   <%}%>
   fsys_cov.sftcrdt.collect_item_<%=_child_blkid[pidx]%>();
   fsys_cov.native_itf.collect_item_rd_data_<%=_child_blkid[pidx]%>(m_pkt);
   `endif
   `endif
   if (fsys_pred_off == 0) begin
      <% if(obj.AiuInfo[pidx].orderedWriteObservation == 1) { %>
         ioaiup_predictor.analyze_read_data_pkt_<%=pidx%>_<%=i%>(m_pkt, fsys_txn_q);
      <% //IOAIUp %> 
      <%} else { %>
         ioaiu_predictor.analyze_read_data_pkt_<%=pidx%>_<%=i%>(m_pkt, fsys_txn_q);
      <% } %>
   end
endfunction : write_<%=_child_blkid[pidx]%>_core<%=i%>_read_data_chnl
function void fsys_scoreboard::write_<%=_child_blkid[pidx]%>_core<%=i%>_read_data_advance_copy_chnl(<%=_child_blkid[pidx]%>_env_pkg::axi4_read_data_pkt_t m_pkt);
   string func_name = "write_<%=_child_blkid[pidx]%>_core<%=i%>_read_data_advance_copy_chnl"; 
   `uvm_info(func_name, $sformatf("Packet received on %0s", func_name), UVM_HIGH)
    `ifdef FSYS_COVER_ON
   `ifndef FSYS_COVER_ONLY_ATOMIC
   fsys_cov.aiu_qos.collect_item_<%=_child_blkid[pidx]%>_core<%=i%>();
   fsys_cov.xxxcorr_err.collect_item_<%=_child_blkid[pidx]%>_core<%=i%>();
   <%if(Array.isArray(obj.AiuInfo[pidx].interfaces.axiInt)){
               computedAxiInt = obj.AiuInfo[pidx].interfaces.axiInt[0];
   }else{
               computedAxiInt = obj.AiuInfo[pidx].interfaces.axiInt;
   }%>
   <%if((obj.AiuInfo[pidx].fnNativeInterface == 'ACE5' || obj.AiuInfo[pidx].fnNativeInterface == 'ACELITE-E' || obj.AiuInfo[pidx].fnNativeInterface == 'AXI5') && (computedAxiInt.params.checkType=="ODD_PARITY_BYTE_ALL")) {%>
   fsys_cov.if_parity_chk.collect_item_<%=_child_blkid[pidx]%>();
   <%}%>
   fsys_cov.sftcrdt.collect_item_<%=_child_blkid[pidx]%>();
   `endif
   `endif
endfunction : write_<%=_child_blkid[pidx]%>_core<%=i%>_read_data_advance_copy_chnl
function void fsys_scoreboard::write_<%=_child_blkid[pidx]%>_core<%=i%>_write_data_chnl(<%=_child_blkid[pidx]%>_env_pkg::axi4_write_data_pkt_t m_pkt);
   string func_name = "write_<%=_child_blkid[pidx]%>_core<%=i%>_write_data_chnl"; 
   `uvm_info(func_name, $sformatf("Packet received on %0s", func_name), UVM_HIGH)
   `ifdef FSYS_COVER_ON
   `ifndef FSYS_COVER_ONLY_ATOMIC
   fsys_cov.aiu_qos.collect_item_<%=_child_blkid[pidx]%>_core<%=i%>();
   fsys_cov.xxxcorr_err.collect_item_<%=_child_blkid[pidx]%>_core<%=i%>();
   <%if(Array.isArray(obj.AiuInfo[pidx].interfaces.axiInt)){
               computedAxiInt = obj.AiuInfo[pidx].interfaces.axiInt[0];
   }else{
               computedAxiInt = obj.AiuInfo[pidx].interfaces.axiInt;
   }%>
   <%if((obj.AiuInfo[pidx].fnNativeInterface == 'ACE5' || obj.AiuInfo[pidx].fnNativeInterface == 'ACELITE-E' || obj.AiuInfo[pidx].fnNativeInterface == 'AXI5') && (computedAxiInt.params.checkType=="ODD_PARITY_BYTE_ALL")) {%>
   fsys_cov.if_parity_chk.collect_item_<%=_child_blkid[pidx]%>();
   <%}%>
   fsys_cov.sftcrdt.collect_item_<%=_child_blkid[pidx]%>();
   `endif
   `endif
   if (fsys_pred_off == 0) begin
      <% if(obj.AiuInfo[pidx].orderedWriteObservation == 1) { %>
         ioaiup_predictor.analyze_write_data_pkt_<%=pidx%>_<%=i%>(m_pkt, fsys_txn_q);
      <% //IOAIUp %> 
      <%} else { %>
         ioaiu_predictor.analyze_write_data_pkt_<%=pidx%>_<%=i%>(m_pkt, fsys_txn_q);
      <% } %>
   end
endfunction : write_<%=_child_blkid[pidx]%>_core<%=i%>_write_data_chnl
function void fsys_scoreboard::write_<%=_child_blkid[pidx]%>_core<%=i%>_write_resp_chnl(<%=_child_blkid[pidx]%>_env_pkg::axi4_write_resp_pkt_t m_pkt);
   string func_name = "write_<%=_child_blkid[pidx]%>_core<%=i%>_write_resp_chnl"; 
   `uvm_info(func_name, $sformatf("Packet received on %0s", func_name), UVM_HIGH)
   if (fsys_pred_off == 0) begin
      <% if(obj.AiuInfo[pidx].orderedWriteObservation == 1) { %>
         ioaiup_predictor.analyze_write_resp_pkt_<%=pidx%>_<%=i%>(m_pkt, fsys_txn_q);
      <% //IOAIUp %> 
      <%} else { %>
         ioaiu_predictor.analyze_write_resp_pkt_<%=pidx%>_<%=i%>(m_pkt, fsys_txn_q);
      <% } %>
   end
   `ifdef FSYS_COVER_ON
   `ifndef FSYS_COVER_ONLY_ATOMIC
   fsys_cov.aiu_qos.collect_item_<%=_child_blkid[pidx]%>_core<%=i%>();
   fsys_cov.xxxcorr_err.collect_item_<%=_child_blkid[pidx]%>_core<%=i%>();
   <%if(Array.isArray(obj.AiuInfo[pidx].interfaces.axiInt)){
               computedAxiInt = obj.AiuInfo[pidx].interfaces.axiInt[0];
   }else{
               computedAxiInt = obj.AiuInfo[pidx].interfaces.axiInt;
   }%>
   <%if((obj.AiuInfo[pidx].fnNativeInterface == 'ACE5' || obj.AiuInfo[pidx].fnNativeInterface == 'ACELITE-E' || obj.AiuInfo[pidx].fnNativeInterface == 'AXI5') && (computedAxiInt.params.checkType=="ODD_PARITY_BYTE_ALL")) {%>
   fsys_cov.if_parity_chk.collect_item_<%=_child_blkid[pidx]%>();
   <%}%>
   fsys_cov.sftcrdt.collect_item_<%=_child_blkid[pidx]%>();
   fsys_cov.native_itf.collect_item_bresp_<%=_child_blkid[pidx]%>(m_pkt);
   `endif
   `endif
endfunction : write_<%=_child_blkid[pidx]%>_core<%=i%>_write_resp_chnl
function void fsys_scoreboard::write_<%=_child_blkid[pidx]%>_core<%=i%>_write_resp_advance_copy_chnl(<%=_child_blkid[pidx]%>_env_pkg::axi4_write_resp_pkt_t m_pkt);
   string func_name = "write_<%=_child_blkid[pidx]%>_core<%=i%>_write_resp_advance_copy_chnl"; 
   `uvm_info(func_name, $sformatf("Packet received on %0s", func_name), UVM_HIGH)
    `ifdef FSYS_COVER_ON
   `ifndef FSYS_COVER_ONLY_ATOMIC
   fsys_cov.aiu_qos.collect_item_<%=_child_blkid[pidx]%>_core<%=i%>();
   fsys_cov.xxxcorr_err.collect_item_<%=_child_blkid[pidx]%>_core<%=i%>();
   <%if(Array.isArray(obj.AiuInfo[pidx].interfaces.axiInt)){
               computedAxiInt = obj.AiuInfo[pidx].interfaces.axiInt[0];
   }else{
               computedAxiInt = obj.AiuInfo[pidx].interfaces.axiInt;
   }%>
   <%if((obj.AiuInfo[pidx].fnNativeInterface == 'ACE5' || obj.AiuInfo[pidx].fnNativeInterface == 'ACELITE-E' || obj.AiuInfo[pidx].fnNativeInterface == 'AXI5') && (computedAxiInt.params.checkType=="ODD_PARITY_BYTE_ALL")) {%>
   fsys_cov.if_parity_chk.collect_item_<%=_child_blkid[pidx]%>();
   <%}%>
   fsys_cov.sftcrdt.collect_item_<%=_child_blkid[pidx]%>();
   fsys_cov.native_itf.collect_item_bresp_<%=_child_blkid[pidx]%>(m_pkt);
   `endif
   `endif
endfunction : write_<%=_child_blkid[pidx]%>_core<%=i%>_write_resp_advance_copy_chnl

<% if(obj.AiuInfo[pidx].fnNativeInterface == "ACE5" ||obj.AiuInfo[pidx].fnNativeInterface == "ACE" || obj.AiuInfo[pidx].fnNativeInterface == "ACELITE-E" || obj.AiuInfo[pidx].fnNativeInterface == "ACE-LITE"){ %>
function void fsys_scoreboard::write_<%=_child_blkid[pidx]%>_core<%=i%>_ace_snoop_addr_chnl(<%=_child_blkid[pidx]%>_env_pkg::ace_snoop_addr_pkt_t m_pkt);
   string func_name = "write_<%=_child_blkid[pidx]%>_core<%=i%>_ace_snoop_addr_chnl"; 
   `uvm_info(func_name, $sformatf("Packet received on %0s", func_name), UVM_HIGH)
   `ifdef FSYS_COVER_ON
   `ifndef FSYS_COVER_ONLY_ATOMIC
  <% if(obj.AiuInfo[pidx].fnNativeInterface == "ACE5"||obj.AiuInfo[pidx].fnNativeInterface == "ACE"){ %>
   fsys_cov.xxxcorr_err.collect_item_<%=_child_blkid[pidx]%>_core<%=i%>();
   <%if(Array.isArray(obj.AiuInfo[pidx].interfaces.axiInt)){
               computedAxiInt = obj.AiuInfo[pidx].interfaces.axiInt[0];
   }else{
               computedAxiInt = obj.AiuInfo[pidx].interfaces.axiInt;
   }%>
   <%if((obj.AiuInfo[pidx].fnNativeInterface == 'ACE5' || obj.AiuInfo[pidx].fnNativeInterface == 'ACELITE-E') && (computedAxiInt.params.checkType=="ODD_PARITY_BYTE_ALL")) {%>
   fsys_cov.if_parity_chk.collect_item_<%=_child_blkid[pidx]%>();
   <%}%>
   fsys_cov.sftcrdt.collect_item_<%=_child_blkid[pidx]%>();
  <%}%>
  <% if(obj.AiuInfo[pidx].interfaces.axiInt.params.eAc==1 && (obj.AiuInfo[pidx].fnNativeInterface == "ACE5" ||obj.AiuInfo[pidx].fnNativeInterface == "ACE" || obj.AiuInfo[pidx].fnNativeInterface == "ACELITE-E")){ %>
   fsys_cov.native_itf.collect_item_snp_<%=_child_blkid[pidx]%>(m_pkt);
  <%}%>
   `endif
   `endif
   if (fsys_pred_off == 0) begin
      <% if(obj.AiuInfo[pidx].orderedWriteObservation == 1) { %>
         ioaiup_predictor.analyze_snoop_addr_pkt_<%=pidx%>_<%=i%>(m_pkt, fsys_txn_q);
      <% //IOAIUp %> 
      <%} else { %>
         ioaiu_predictor.analyze_snoop_addr_pkt_<%=pidx%>_<%=i%>(m_pkt, fsys_txn_q);
      <% } %>
   end
endfunction : write_<%=_child_blkid[pidx]%>_core<%=i%>_ace_snoop_addr_chnl
function void fsys_scoreboard::write_<%=_child_blkid[pidx]%>_core<%=i%>_ace_snoop_resp_chnl(<%=_child_blkid[pidx]%>_env_pkg::ace_snoop_resp_pkt_t m_pkt);
   string func_name = "write_<%=_child_blkid[pidx]%>_core<%=i%>_ace_snoop_resp_chnl"; 
   `uvm_info(func_name, $sformatf("Packet received on %0s", func_name), UVM_HIGH)
   `ifdef FSYS_COVER_ON
   `ifndef FSYS_COVER_ONLY_ATOMIC
   <% if(obj.AiuInfo[pidx].fnNativeInterface == "ACE5"||obj.AiuInfo[pidx].fnNativeInterface == "ACE"){ %>
   fsys_cov.xxxcorr_err.collect_item_<%=_child_blkid[pidx]%>_core<%=i%>();
   <%if(Array.isArray(obj.AiuInfo[pidx].interfaces.axiInt)){
               computedAxiInt = obj.AiuInfo[pidx].interfaces.axiInt[0];
   }else{
               computedAxiInt = obj.AiuInfo[pidx].interfaces.axiInt;
   }%>
   <%if((obj.AiuInfo[pidx].fnNativeInterface == 'ACE5' || obj.AiuInfo[pidx].fnNativeInterface == 'ACELITE-E') && (computedAxiInt.params.checkType=="ODD_PARITY_BYTE_ALL")) {%>
   fsys_cov.if_parity_chk.collect_item_<%=_child_blkid[pidx]%>();
   <%}%>
   fsys_cov.sftcrdt.collect_item_<%=_child_blkid[pidx]%>();
   fsys_cov.native_itf.collect_item_sresp_<%=_child_blkid[pidx]%>(m_pkt);
   <%}%>
   `endif
   `endif
   if (fsys_pred_off == 0) begin
      <% if(obj.AiuInfo[pidx].orderedWriteObservation == 1) { %>
         ioaiup_predictor.analyze_snoop_resp_pkt_<%=pidx%>_<%=i%>(m_pkt, fsys_txn_q);
      <% //IOAIUp %> 
      <%} else { %>
         ioaiu_predictor.analyze_snoop_resp_pkt_<%=pidx%>_<%=i%>(m_pkt, fsys_txn_q);
      <% } %>
   end
endfunction : write_<%=_child_blkid[pidx]%>_core<%=i%>_ace_snoop_resp_chnl
function void fsys_scoreboard::write_<%=_child_blkid[pidx]%>_core<%=i%>_ace_snoop_data_chnl(<%=_child_blkid[pidx]%>_env_pkg::ace_snoop_data_pkt_t m_pkt);
   string func_name = "write_<%=_child_blkid[pidx]%>_core<%=i%>_ace_snoop_data_chnl"; 
   `uvm_info(func_name, $sformatf("Packet received on %0s", func_name), UVM_HIGH)
   `ifdef FSYS_COVER_ON                                    
   `ifndef FSYS_COVER_ONLY_ATOMIC
   fsys_cov.xxxcorr_err.collect_item_<%=_child_blkid[pidx]%>_core<%=i%>();
   <%if(Array.isArray(obj.AiuInfo[pidx].interfaces.axiInt)){
               computedAxiInt = obj.AiuInfo[pidx].interfaces.axiInt[0];
   }else{
               computedAxiInt = obj.AiuInfo[pidx].interfaces.axiInt;
   }%>
   <%if((obj.AiuInfo[pidx].fnNativeInterface == 'ACE5') && (computedAxiInt.params.checkType=="ODD_PARITY_BYTE_ALL")) {%>
   fsys_cov.if_parity_chk.collect_item_<%=_child_blkid[pidx]%>();
   <%}%>
   fsys_cov.sftcrdt.collect_item_<%=_child_blkid[pidx]%>(); 
   `endif                                                   
   `endif                                                   
   if (fsys_pred_off == 0) begin
      <% if(obj.AiuInfo[pidx].orderedWriteObservation == 1) { %>
         ioaiup_predictor.analyze_snoop_data_pkt_<%=pidx%>_<%=i%>(m_pkt, fsys_txn_q);
      <% //IOAIUp %> 
      <%} else { %>
         ioaiu_predictor.analyze_snoop_data_pkt_<%=pidx%>_<%=i%>(m_pkt, fsys_txn_q);
      <% } %>
   end
endfunction : write_<%=_child_blkid[pidx]%>_core<%=i%>_ace_snoop_data_chnl
<%}%>
<% } // froeach InterfacePorts%>
<% } // if ioaiu%>
<% } // foreach aius%>

////////////////////////////////////////////////////////////////////////////////
//DMI write functions 
////////////////////////////////////////////////////////////////////////////////
<% for(var pidx = 0; pidx < obj.nDMIs; pidx++) { %>
function void fsys_scoreboard::write_dmi<%=pidx%>_smi(dmi<%=pidx%>_smi_agent_pkg::smi_seq_item m_pkt);
   string func_name = "write_dmi<%=pidx%>_smi"; 
   `uvm_info(func_name, $sformatf("Packet received on %0s", func_name), UVM_HIGH)
   `ifdef FSYS_COVER_ON
   `ifndef FSYS_COVER_ONLY_ATOMIC
   fsys_cov.smi.collect_item_dmi<%=pidx%>(m_pkt);
   <% if (obj.DmiInfo[pidx].useCmc && obj.DmiInfo[pidx].ccpParams.useScratchpad){ %>
   fsys_cov.smi.k_sp_base_addr[<%=pidx%>]=m_concerto_env_cfg.k_sp_base_addr[<%=pidx%>];
   <%}%>
   fsys_cov.dmi.collect_item_dmi<%=pidx%>();
   fsys_cov.xxxcorr_err.collect_item_dmi<%=pidx%>();
   `endif
   `endif
   if (fsys_pred_off == 0) begin
      dmi_predictor.analyze_smi_pkt_<%=pidx%>(dmi<%=pidx%>_smi_agent_pkg::smi_seq_item'(m_pkt), fsys_txn_q);
   end
endfunction : write_dmi<%=pidx%>_smi
function void fsys_scoreboard::write_dmi<%=pidx%>_read_addr_chnl(dmi<%=pidx%>_env_pkg::axi4_read_addr_pkt_t m_pkt);
   string func_name = "write_dmi<%=pidx%>_read_addr_chnl"; 
   `uvm_info(func_name, $sformatf("Packet received on %0s", func_name), UVM_HIGH)
   if (fsys_pred_off == 0) begin
      if(m_en_mem_check) begin
         dmi_predictor.read_addr_chnl_<%=pidx%>(m_pkt);
      end
   end
endfunction : write_dmi<%=pidx%>_read_addr_chnl
function void fsys_scoreboard::write_dmi<%=pidx%>_read_data_chnl(dmi<%=pidx%>_env_pkg::axi4_read_data_pkt_t m_pkt);
   string func_name = "write_dmi<%=pidx%>_read_data_chnl"; 
   `uvm_info(func_name, $sformatf("Packet received on %0s", func_name), UVM_HIGH)
   if (fsys_pred_off == 0) begin
      if(m_en_mem_check) begin
         dmi_predictor.read_data_chnl_<%=pidx%>(m_pkt);
      end
   end
   `ifdef FSYS_COVER_ON
   `ifndef FSYS_COVER_ONLY_ATOMIC
   fsys_cov.native_itf.collect_item_rd_data_dmi<%=pidx%>(m_pkt);
   fsys_cov.dmi.collect_item_dmi<%=pidx%>();
   `endif
   `endif
endfunction : write_dmi<%=pidx%>_read_data_chnl
function void fsys_scoreboard::write_dmi<%=pidx%>_write_addr_chnl(dmi<%=pidx%>_env_pkg::axi4_write_addr_pkt_t m_pkt);
   string func_name = "write_dmi<%=pidx%>_write_addr_chnl"; 
   `uvm_info(func_name, $sformatf("Packet received on %0s", func_name), UVM_HIGH)
   if (fsys_pred_off == 0) begin
      if(m_en_mem_check) begin
         dmi_predictor.write_addr_chnl_<%=pidx%>(m_pkt);
      end
   end
   `ifdef FSYS_COVER_ON
   `ifndef FSYS_COVER_ONLY_ATOMIC
    fsys_cov.dmi.collect_item_dmi<%=pidx%>();
   `endif
   `endif
endfunction : write_dmi<%=pidx%>_write_addr_chnl
function void fsys_scoreboard::write_dmi<%=pidx%>_write_data_chnl(dmi<%=pidx%>_env_pkg::axi4_write_data_pkt_t m_pkt);
   string func_name = "write_dmi<%=pidx%>_write_data_chnl"; 
   `uvm_info(func_name, $sformatf("Packet received on %0s", func_name), UVM_HIGH)
   if (fsys_pred_off == 0) begin
      if(m_en_mem_check) begin
         dmi_predictor.write_data_chnl_<%=pidx%>(m_pkt);
      end
   end
   `ifdef FSYS_COVER_ON
   `ifndef FSYS_COVER_ONLY_ATOMIC
   fsys_cov.dmi.collect_item_dmi<%=pidx%>();
  `endif
  `endif
endfunction : write_dmi<%=pidx%>_write_data_chnl
function void fsys_scoreboard::write_dmi<%=pidx%>_write_resp_chnl(dmi<%=pidx%>_env_pkg::axi4_write_resp_pkt_t m_pkt);
   string func_name = "write_dmi<%=pidx%>_write_resp_chnl"; 
   `uvm_info(func_name, $sformatf("Packet received on %0s", func_name), UVM_HIGH)
   `ifdef FSYS_COVER_ON
   `ifndef FSYS_COVER_ONLY_ATOMIC
   fsys_cov.dmi.collect_item_dmi<%=pidx%>();
   fsys_cov.native_itf.collect_item_bresp_dmi<%=pidx%>(m_pkt);
  `endif
  `endif
endfunction : write_dmi<%=pidx%>_write_resp_chnl
<% } //foreach DMI %>
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
//DII write functions 
////////////////////////////////////////////////////////////////////////////////
<% for(var pidx = 0; pidx < obj.nDIIs; pidx++) { %>
function void fsys_scoreboard::write_dii<%=pidx%>_smi(dii<%=pidx%>_smi_agent_pkg::smi_seq_item m_pkt);
   string func_name = "write_dii<%=pidx%>_smi"; 
   `uvm_info(func_name, $sformatf("Packet received on %0s", func_name), UVM_HIGH)
   `ifdef FSYS_COVER_ON
   `ifndef FSYS_COVER_ONLY_ATOMIC
   fsys_cov.smi.collect_item_dii<%=pidx%>(m_pkt);
   `endif
   `endif
   if (fsys_pred_off == 0) begin
      dii_predictor.analyze_smi_pkt_<%=pidx%>(dii<%=pidx%>_smi_agent_pkg::smi_seq_item'(m_pkt), fsys_txn_q);
   end
endfunction : write_dii<%=pidx%>_smi
function void fsys_scoreboard::write_dii<%=pidx%>_read_addr_chnl(dii<%=pidx%>_env_pkg::axi4_read_addr_pkt_t m_pkt);
   string func_name = "write_dii<%=pidx%>_read_addr_chnl";
   //`uvm_info(func_name, $sformatf("Packet received on %0s", func_name), UVM_HIGH)
   if (fsys_pred_off == 0) begin
      //dii_predictor.analyze_read_addr_pkt_<%=pidx%>(m_pkt, fsys_txn_q);
      if(m_en_mem_check) begin
         dii_predictor.read_addr_chnl_<%=pidx%>(m_pkt);
      end
   end
endfunction : write_dii<%=pidx%>_read_addr_chnl
function void fsys_scoreboard::write_dii<%=pidx%>_read_data_chnl(dii<%=pidx%>_env_pkg::axi4_read_data_pkt_t m_pkt);
   string func_name = "write_dii<%=pidx%>_read_data_chnl";
   `ifdef FSYS_COVER_ON
   `ifndef FSYS_COVER_ONLY_ATOMIC
   fsys_cov.native_itf.collect_item_rd_data_dii<%=pidx%>(m_pkt);
   `endif
   `endif
   if (fsys_pred_off == 0) begin
      //dii_predictor.analyze_read_data_pkt_<%=pidx%>(m_pkt, fsys_txn_q);
      if(m_en_mem_check) begin
         dii_predictor.read_data_chnl_<%=pidx%>(m_pkt);
      end
   end
   //`uvm_info(func_name, $sformatf("Packet received on %0s", func_name), UVM_HIGH)
endfunction : write_dii<%=pidx%>_read_data_chnl
function void fsys_scoreboard::write_dii<%=pidx%>_write_addr_chnl(dii<%=pidx%>_env_pkg::axi4_write_addr_pkt_t m_pkt);
   string func_name = "write_dii<%=pidx%>_write_addr_chnl"; 
   if (fsys_pred_off == 0) begin
      dii_predictor.analyze_write_addr_pkt_<%=pidx%>(m_pkt, fsys_txn_q);
      `uvm_info(func_name, $sformatf("Packet received on %0s", func_name), UVM_HIGH)
      if(m_en_mem_check) begin
         dii_predictor.write_addr_chnl_<%=pidx%>(m_pkt);
      end
   end
endfunction : write_dii<%=pidx%>_write_addr_chnl
function void fsys_scoreboard::write_dii<%=pidx%>_write_data_chnl(dii<%=pidx%>_env_pkg::axi4_write_data_pkt_t m_pkt);
   string func_name = "write_dii<%=pidx%>_write_data_chnl"; 
   if (fsys_pred_off == 0) begin
      dii_predictor.analyze_write_data_pkt_<%=pidx%>(m_pkt, fsys_txn_q);
      `uvm_info(func_name, $sformatf("Packet received on %0s", func_name), UVM_HIGH)
      if(m_en_mem_check) begin
         dii_predictor.write_data_chnl_<%=pidx%>(m_pkt);
      end
   end
endfunction : write_dii<%=pidx%>_write_data_chnl
function void fsys_scoreboard::write_dii<%=pidx%>_write_resp_chnl(dii<%=pidx%>_env_pkg::axi4_write_resp_pkt_t m_pkt);
   string func_name = "write_dii<%=pidx%>_write_resp_chnl";
   if (fsys_pred_off == 0) begin
      dii_predictor.analyze_write_resp_pkt_<%=pidx%>(m_pkt, fsys_txn_q);
   end
   `ifdef FSYS_COVER_ON
   `ifndef FSYS_COVER_ONLY_ATOMIC
   fsys_cov.native_itf.collect_item_bresp_dii<%=pidx%>(m_pkt);
   `endif
   `endif
   `uvm_info(func_name, $sformatf("Packet received on %0s", func_name), UVM_HIGH)
endfunction : write_dii<%=pidx%>_write_resp_chnl
<% } //foreach DII %>
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
//DCE write functions 
////////////////////////////////////////////////////////////////////////////////
<% for(var pidx = 0; pidx < obj.nDCEs; pidx++) { %>
function void fsys_scoreboard::write_dce<%=pidx%>_smi(dce<%=pidx%>_smi_agent_pkg::smi_seq_item m_pkt);
   string func_name = "write_dce<%=pidx%>_smi"; 
   `uvm_info(func_name, $sformatf("Packet received on %0s", func_name), UVM_HIGH)
   `ifdef FSYS_COVER_ON
   `ifndef FSYS_COVER_ONLY_ATOMIC
   fsys_cov.xxxcorr_err.collect_item_dce<%=pidx%>();
   fsys_cov.sftcrdt.collect_item_dce<%=pidx%>();
   fsys_cov.smi.collect_item_dce<%=pidx%>(m_pkt);
   `endif
   `endif
   if (fsys_pred_off == 0) begin
      dce_predictor.analyze_smi_pkt_<%=pidx%>(dce<%=pidx%>_smi_agent_pkg::smi_seq_item'(m_pkt), fsys_txn_q);
   end
endfunction : write_dce<%=pidx%>_smi
<% } //foreach DCE %>
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
//DVE write functions 
////////////////////////////////////////////////////////////////////////////////
<% for(var pidx = 0; pidx < obj.nDVEs; pidx++) { %>
function void fsys_scoreboard::write_dve<%=pidx%>_smi(dve<%=pidx%>_smi_agent_pkg::smi_seq_item m_pkt);
   string func_name = "write_dve<%=pidx%>_smi"; 
   `uvm_info(func_name, $sformatf("Packet received on %0s", func_name), UVM_HIGH)
   if (fsys_pred_off == 0) begin
      dve_predictor.analyze_smi_pkt_<%=pidx%>(dve<%=pidx%>_smi_agent_pkg::smi_seq_item'(m_pkt), fsys_txn_q);
   end
   `ifdef FSYS_COVER_ON
   `ifndef FSYS_COVER_ONLY_ATOMIC
   fsys_cov.smi.collect_item_dve<%=pidx%>(m_pkt);
   `endif
   `endif
endfunction : write_dve<%=pidx%>_smi
<% } //foreach DCE %>
////////////////////////////////////////////////////////////////////////////////
// End of file
