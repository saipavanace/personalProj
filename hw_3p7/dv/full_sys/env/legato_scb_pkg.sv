////////////////////////////
//File: legato_scb_pkg.sv
////////////////////////////

<%
var _child_blkid = [];
var pidx = 0;
var qidx = 0;
var idx  = 0;
var ridx = 0;
var chiaiu_idx = 0;
var ioaiu_idx = 0;
for(pidx = 0; pidx < obj.nAIUs; pidx++) {
    if((obj.AiuInfo[pidx].fnNativeInterface == 'CHI-A')||(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-B')||(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-E')) {
//        _child_blkid[pidx] = obj.AiuInfo[pidx].strRtlNamePrefix;
        _child_blkid[pidx] = 'chiaiu' + idx;
        idx++;
    } else {
//        _child_blkid[pidx] = obj.AiuInfo[pidx].strRtlNamePrefix;
        _child_blkid[pidx] = 'ioaiu' + qidx;
        qidx++;
    }
}   
for(pidx = 0; pidx < obj.nDCEs; pidx++) {
    ridx = pidx + obj.nAIUs;
    _child_blkid[ridx] = 'dce' + pidx;
}   
for(pidx =  0; pidx < obj.nDMIs; pidx++) {
    ridx = pidx + obj.nAIUs + obj.nDCEs;
    _child_blkid[ridx] = 'dmi' + pidx;
}   
for(pidx = 0; pidx < obj.nDIIs; pidx++) {
    ridx = pidx + obj.nAIUs + obj.nDCEs + obj.nDMIs;
    _child_blkid[ridx] = 'dii' + pidx;
}
for(pidx = 0; pidx < obj.nDVEs; pidx++) {
    ridx = pidx + obj.nAIUs + obj.nDCEs + obj.nDMIs + obj.nDIIs;
    // FIXME: Uncomment below once DVE is alive in system level environment
    _child_blkid[ridx] = 'dve' + pidx;
}
%>
package legato_scb_pkg;
`ifdef QUESTA
    timeunit 1ps;
    timeprecision 1ps;
`endif

import uvm_pkg::*;
<%  if(!obj.CUSTOMER_ENV) { %>
    <% for(ridx = 0; ridx < _child_blkid.length; ridx++) { %>
        import <%=_child_blkid[ridx]%>_smi_agent_pkg::*;
    <% } %>
<% } %>
`include "legato_scb.svh"
endpackage: legato_scb_pkg

