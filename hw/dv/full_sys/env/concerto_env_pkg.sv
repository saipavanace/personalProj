
////////////////////////////////////////////////////////////////////////////////
//
// concerto_env_pkg 
<% if (1 == 0) { %>
// Author: Satya Prakash
<% } %>
//
////////////////////////////////////////////////////////////////////////////////
<%
//Embedded javascript code to figure number of blocks
   var _child_blkid = [];
   var _child_blk   = [];
   var pidx = 0;
   var qidx = 0;
   var idx  = 0;
   var ridx = 0;
   var initiatorAgents = obj.AiuInfo.length ;
   var numChiAiu         = 0;
   var numIoAiu          = 0;

   for(pidx = 0; pidx < obj.nAIUs; pidx++) {
       if((obj.AiuInfo[pidx].fnNativeInterface == 'CHI-A')||(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-B')||(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-E')) {
       _child_blkid[pidx] = 'chiaiu' + idx;
       _child_blk[pidx]   = 'chiaiu';
       numChiAiu = numChiAiu + 1;
       idx++;
       } else {
       _child_blkid[pidx] = 'ioaiu' + qidx;
       _child_blk[pidx]   = 'ioaiu';
       numIoAiu = numIoAiu + 1;
       qidx++;
       }
   }
   for(pidx = 0; pidx < obj.nDCEs; pidx++) {
       ridx = pidx + obj.nAIUs;
       _child_blkid[ridx] = 'dce' + pidx;
       _child_blk[ridx]   = 'dce';
   }
   for(pidx =  0; pidx < obj.nDMIs; pidx++) {
       ridx = pidx + obj.nAIUs + obj.nDCEs;
       _child_blkid[ridx] = 'dmi' + pidx;
       _child_blk[ridx]   = 'dmi';
   }
   for(pidx = 0; pidx < obj.nDIIs; pidx++) {
       ridx = pidx + obj.nAIUs + obj.nDCEs + obj.nDMIs;
       _child_blkid[ridx] = 'dii' + pidx;
       _child_blk[ridx]   = 'dii';
   }
   for(pidx = 0; pidx < obj.nDVEs; pidx++) {
       ridx = pidx + obj.nAIUs + obj.nDCEs + obj.nDMIs + obj.nDIIs;
       _child_blkid[ridx] = 'dve' + pidx;
       _child_blk[ridx]   = 'dve';
   }
%>
`include "snps_compile.sv"
`include "svt_amba_env.sv"
package concerto_env_pkg;

 import uvm_pkg::*;
 `include "uvm_macros.svh"
<% if(obj.testBench=="emu") { %>
  import mgc_vtl_chi_pkg::*;
  import ioaiu_smi_pkg::*;
//import mgc_axi_pkg::*;         
`include "/engr/dev/tools/mentor/Veloce_Transactors_Library_v22.2/chi_v2/sysvlog/vtl_chi_types.svh" 
<% } %> 

  import concerto_register_map_pkg::*;
<%  if(!obj.CUSTOMER_ENV) { %>
  import ncore_config_pkg::*;
  import addr_trans_mgr_pkg::*;
<% } %>

<% for(var pidx = 0; pidx < _child_blkid.length; pidx++) { %>
  <%  if(_child_blk[pidx].match('chiaiu')) { %>
    import <%=_child_blkid[pidx]%>_env_pkg::*; 
  <% } %>
<% } %>
<% if(numChiAiu > 0) { %>
    import chi_aiu_unit_args_pkg::*;
<% } %>
<% for(var pidx = 0; pidx < _child_blkid.length; pidx++) { %>
  <%  if(_child_blk[pidx].match('ioaiu')) { %>
    import <%=_child_blkid[pidx]%>_env_pkg::*; 
    export <%=_child_blkid[pidx]%>_env_pkg::*; 
  <% } %>
<% } %>
<% for(var pidx = 0; pidx < obj.nDMIs; pidx++) {%>
    import dmi<%=pidx%>_env_pkg::*;
<% } %>
<% for(var pidx = 0; pidx < obj.nDIIs; pidx++) {%>
    import dii<%=pidx%>_env_pkg::*;
<% } %>
<% for(var pidx = 0; pidx < obj.nDCEs; pidx++) {%>
    import dce<%=pidx%>_env_pkg::*;
<% } %>
<% for(var pidx = 0; pidx < obj.nDVEs; pidx++) {%>
    import dve<%=pidx%>_env_pkg::*;
<% } %>
  import legato_scb_pkg::*;
  import q_chnl_agent_pkg::*;
  import fsys_coverage_pkg::*;

 `include "snps_import.sv"
//  `include "cust_svt_amba_system_configuration.sv"
//  `include "svt_amba_env.sv"
 import svt_amba_env_class_pkg::*;
  `include "svt_amba_seq_item_lib.sv"
  `include "conc_svt_chi_seq_lib.sv"
  `include "conc_svt_chi_seq_item_lib.sv"
  
  `include "mem_checker_cfg.svh"
  `include "concerto_env_cfg.svh"
  typedef class fsys_scoreboard;
  `include "addr_status_types.svh"
  `include "addr_status.svh"
  `include "fsys_scb_txn.svh"
  `include "fsys_coherency_checker.svh"
  `include "mem_consistency_checker.svh"
  `include "fsys_scb_chi_predictor.svh"
  `include "fsys_scb_ioaiu_predictor.svh"
  `include "fsys_scb_ioaiup_predictor.svh"
  `include "fsys_scb_dmi_predictor.svh"
  `include "fsys_scb_dii_predictor.svh"
  `include "fsys_scb_dce_predictor.svh"
  `include "fsys_scb_dve_predictor.svh"
  `include "fsys_scoreboard.svh"
  `include "chi_coh_bringup_virtual_seqr.sv"
  `include "concerto_env_snps.svh"
  `include "concerto_env_inhouse.svh"
  `include "concerto_env.svh"
endpackage:concerto_env_pkg
