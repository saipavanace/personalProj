////////////////////////////////////////////////////////////////////////////////
//
// fsys_coverage_pkg 
// Author: Cyrille LUDWIG
//
////////////////////////////////////////////////////////////////////////////////
 <%
 //Embedded javascript code to figure number of blocks
    var _child_blkid = [];
    var _child_blk   = [];
    var _child   = [{}];
    var pidx = 0;
    var qidx = 0;
    var idx  = 0;
    var ridx = 0;
    var initiatorAgents = obj.AiuInfo.length ;
    var numChiAiu         = 0;
    var numIoAiu          = 0;
    var nALLs             = 0;
 
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
        _child[pidx]   = obj.AiuInfo[pidx];
    }
    for(pidx = 0; pidx < obj.nDCEs; pidx++) {
        ridx = pidx + obj.nAIUs;
        _child_blkid[ridx] = 'dce' + pidx;
        _child_blk[ridx]   = 'dce';
        _child[ridx]   = obj.DceInfo[pidx];
    }
    for(pidx =  0; pidx < obj.nDMIs; pidx++) {
        ridx = pidx + obj.nAIUs + obj.nDCEs;
        _child_blkid[ridx] = 'dmi' + pidx;
        _child_blk[ridx]   = 'dmi';
        _child[ridx]   = obj.DmiInfo[pidx];
    }
    for(pidx = 0; pidx < obj.nDIIs; pidx++) {
        ridx = pidx + obj.nAIUs + obj.nDCEs + obj.nDMIs;
        _child_blkid[ridx] = 'dii' + pidx;
        _child_blk[ridx]   = 'dii';
        _child[ridx]   = obj.DiiInfo[pidx];
    }
    for(pidx = 0; pidx < obj.nDVEs; pidx++) {
        ridx = pidx + obj.nAIUs + obj.nDCEs + obj.nDMIs + obj.nDIIs;
        _child_blkid[ridx] = 'dve' + pidx;
        _child_blk[ridx]   = 'dve';
        _child[ridx]   = obj.DveInfo[pidx];
    }
    nALLs = ridx+1;
 %>
 
 
 `ifdef USE_VIP_SNPS
  `include "snps_compile.sv"
`endif

package fsys_coverage_pkg;
 
   import uvm_pkg::*;
   `include "uvm_macros.svh"
  <% if(obj.testBench=="emu") { %>
    import mgc_vtl_chi_pkg::*;
  //import mgc_axi_pkg::*;         
  `include "/engr/dev/tools/mentor/Veloce_Transactors_Library_v22.2/chi_v2/sysvlog/vtl_chi_types.svh" <% } %> 
  
    import concerto_register_map_pkg::*;
  <%  if(!obj.CUSTOMER_ENV) { %>
  import ncore_config_pkg::*;
    import addr_trans_mgr_pkg::*;
  <% } %>
  
  <% for(var pidx = 0; pidx < nALLs; pidx++) { %>
    <%  if(_child_blk[pidx].match('chiaiu')) { %>
      import <%=_child_blkid[pidx]%>_env_pkg::*; 
`ifdef VCS
`endif // `ifndef VCS
`ifdef VCS
      export <%=_child_blkid[pidx]%>_env_pkg::*; 
`endif // `ifndef VCS
    <% } %>
  <% } %>
  <% if(numChiAiu > 0) { %>
      import chi_aiu_unit_args_pkg::*;
`ifdef VCS
      export chi_aiu_unit_args_pkg::*;
`endif // `ifndef VCS
  <% } %>
  <% for(var pidx = 0; pidx < nALLs; pidx++) { %>
    <%  if(_child_blk[pidx].match('ioaiu')) { %>
      import <%=_child_blkid[pidx]%>_env_pkg::*; 
`ifdef VCS
      export <%=_child_blkid[pidx]%>_env_pkg::*; 
`endif // `ifndef VCS
    <% } %>
  <% } %>
  <% for(var pidx = 0; pidx < obj.nDMIs; pidx++) {%>
      import dmi<%=pidx%>_env_pkg::*;
`ifdef VCS
      export dmi<%=pidx%>_env_pkg::*;
`endif // `ifndef VCS
  <% } %>
  <% for(var pidx = 0; pidx < obj.nDIIs; pidx++) {%>
      import dii<%=pidx%>_env_pkg::*;
`ifdef VCS
      export dii<%=pidx%>_env_pkg::*;
`endif // `ifndef VCS
  <% } %>
  <% for(var pidx = 0; pidx < obj.nDCEs; pidx++) {%>
      import dce<%=pidx%>_env_pkg::*;
`ifdef VCS
      export dce<%=pidx%>_env_pkg::*;
`endif // `ifndef VCS
  <% } %>
  <% for(var pidx = 0; pidx < obj.nDVEs; pidx++) {%>
      import dve<%=pidx%>_env_pkg::*;
`ifdef VCS
      export dve<%=pidx%>_env_pkg::*;
`endif // `ifndef VCS
  <% } %>  

  
  <%for( var pidx = 0; pidx < nALLs; pidx++) { %>
    <% if(!(_child_blk[pidx].match('chiaiu') ||_child_blk[pidx].match('dce') )) { %>
    `include "<%=_child_blkid[pidx]%>_axi_widths.svh" // generate & used by axi_types
    `include "<%=_child_blkid[pidx]%>_axi_types.svh" // we use only the commun part used by all agents
    <% break;%>
    <%}%>
    <%}%>

  `include "<%=_child_blkid[0]%>_smi_widths.svh" // generate & used by smi_types
  `include "<%=_child_blkid[0]%>_smi_types.svh" // we use only the commun part used by all agents
  `include "fsys_txn_path_coverage.svh"
  `ifndef IOAIU_SUBSYS_COVER_ON
  `include "fsys_base_coverage.svh"
  `include "fsys_aiu_qos_coverage.svh"
  `include "fsys_dmi_coverage.svh"
  `include "fsys_xxxcorr_err_coverage.svh"
  `include "fsys_sftcrdt_coverage.svh"
  `include "fsys_if_parity_chk_coverage.svh"
  `include "fsys_native_itf_coverage.svh"
  `include "fsys_smi_coverage.svh"
  `include "fsys_smi_coverage_atomic.svh"
  `include "fsys_sys_event_coverage.svh"
  `include "fsys_coverage.svh"
  `endif

endpackage:fsys_coverage_pkg
