<% var ASILB = 0; // (obj.useResiliency & obj.enableUnitDuplication) ? 0 : 1; %>
<% var hier_path_dce_csr          = (!ASILB) ? 'dce_func_unit.u_csr' : 'u_csr'; %>
<% var hier_path_dce_cmux         = (!ASILB) ? 'dce_func_unit.dce_conc_mux' : 'dce_conc_mux'; %>
<% var hier_path_dce_sbcmdreqfifo = (!ASILB) ? 'dce_func_unit.skid_buf_cmd_req_fifo' : 'skid_buf_cmd_req_fifo'; %>
<% var hier_path_dce_sb           = (!ASILB) ? 'dce_func_unit.dce_skid_buffer' : 'dce_skid_buffer'; %>

//
// The entire notice above must be reproduced on all authorized copies.
//-----------------------------------------------------------------------
<%
//Embedded javascript code to figure number of blocks
   var _child_blkid = [];
   var _child_blk   = [];
   var _child_blk_nCore = [];
   var _child   = [{}];
   var pidx = 0;
   var qidx = 0;
   var idx  = 0;
   var ridx = 0;
   var initiatorAgents = obj.AiuInfo.length ;
   var numChiAiu         = 0;
   var numIoAiu          = 0;
   var numAce     = 0;
   var numAceLite     = 0;
   var numAceLiteE     = 0;
   var numAxi4_with_cache     = 0;
   var dmiqosenable = 0;
   var dmismc = 0;
   var numAce_with_if_parity_check = 0;
   var numAxi5_with_if_parity_check = 0;
   var numAce5Lite_with_if_parity_check = 0;
   let computedAxiInt;

   for(pidx = 0; pidx < obj.nAIUs; pidx++) {
       if((obj.AiuInfo[pidx].fnNativeInterface == 'CHI-A')||(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-B')||(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-E')) {
       _child_blkid[pidx] = 'chiaiu' + idx;
       _child_blk[pidx]   = 'chiaiu';
       _child_blk_nCore[pidx] = 1;
       numChiAiu = numChiAiu + 1;
       idx++;
       } else {
       if(obj.AiuInfo[pidx].fnNativeInterface == 'ACE5' || obj.AiuInfo[pidx].fnNativeInterface == 'ACE') { 
           numAce++; 
           if(Array.isArray(obj.AiuInfo[pidx].interfaces.axiInt)){
               computedAxiInt = obj.AiuInfo[pidx].interfaces.axiInt[0];
           }else{
               computedAxiInt = obj.AiuInfo[pidx].interfaces.axiInt;
           }
           if(computedAxiInt.params.checkType=="ODD_PARITY_BYTE_ALL") {
               numAce_with_if_parity_check= numAce_with_if_parity_check+ 1;
           }
       }
       if(obj.AiuInfo[pidx].fnNativeInterface == 'ACE-LITE') { numAceLite++; }
       if(obj.AiuInfo[pidx].fnNativeInterface == 'ACELITE-E') { 
           numAceLiteE++; 
           if(Array.isArray(obj.AiuInfo[pidx].interfaces.axiInt)){
               computedAxiInt = obj.AiuInfo[pidx].interfaces.axiInt[0];
           }else{
               computedAxiInt = obj.AiuInfo[pidx].interfaces.axiInt;
           }
           if(computedAxiInt.params.checkType=="ODD_PARITY_BYTE_ALL") {
               numAce5Lite_with_if_parity_check = numAce5Lite_with_if_parity_check+ 1;
           }
       }
       if(obj.AiuInfo[pidx].fnNativeInterface == 'AXI4' && obj.AiuInfo[pidx].useCache) { numAxi4_with_cache++; }
       if(obj.AiuInfo[pidx].fnNativeInterface == 'AXI5') { 
           if(Array.isArray(obj.AiuInfo[pidx].interfaces.axiInt)){
               computedAxiInt = obj.AiuInfo[pidx].interfaces.axiInt[0];
           }else{
               computedAxiInt = obj.AiuInfo[pidx].interfaces.axiInt;
           }
           if(computedAxiInt.params.checkType=="ODD_PARITY_BYTE_ALL") {
               numAxi5_with_if_parity_check = numAxi5_with_if_parity_check+ 1;
           }
       }
       _child_blkid[pidx] = 'ioaiu' + qidx;
       _child_blk[pidx]   = 'ioaiu';
       _child_blk_nCore[pidx] = obj.AiuInfo[pidx].nNativeInterfacePorts;
       numIoAiu = numIoAiu + 1;
       qidx++;
       }
       _child[pidx]  = obj.AiuInfo[pidx];
   }
   start_nDCEs=pidx;
   for(pidx = 0; pidx < obj.nDCEs; pidx++) {
       ridx = pidx + obj.nAIUs;
       _child_blkid[ridx] = 'dce' + pidx;
       _child_blk[ridx]   = 'dce';
       _child[ridx]   = obj.DceInfo[pidx];
   }
   start_nDMIS=ridx;
   for(pidx =  0; pidx < obj.nDMIs; pidx++) {
       ridx = pidx + obj.nAIUs + obj.nDCEs;
       _child_blkid[ridx] = 'dmi' + pidx;
       _child_blk[ridx]   = 'dmi';
       _child[ridx]   = obj.DmiInfo[pidx];
       if (!dmiqosenable) { dmiqosenable = obj.DmiInfo[pidx].fnEnableQos;}
       if (!dmismc) { dmismc = obj.DmiInfo[pidx].useCmc;}
   }

   start_nDIIS=ridx;
   for(pidx = 0; pidx < obj.nDIIs; pidx++) {
       ridx = pidx + obj.nAIUs + obj.nDCEs + obj.nDMIs;
       _child_blkid[ridx] = 'dii' + pidx;
       _child_blk[ridx]   = 'dii';
       _child[ridx]   = obj.DiiInfo[pidx];
   }
   start_nDVES=ridx;
   for(pidx = 0; pidx < obj.nDVEs; pidx++) {
       ridx = pidx + obj.nAIUs + obj.nDCEs + obj.nDMIs + obj.nDIIs;
       _child_blkid[ridx] = 'dve' + pidx;
       _child_blk[ridx]   = 'dve';
       _child[ridx]   = obj.DveInfo[pidx];
   }
   var nALLs = ridx+1;
%>
`ifndef FSYS_COV_CSR_PROBE_IF_SV
`define FSYS_COV_CSR_PROBE_IF_SV

interface fsys_coverage_csr_probe_if ();

// CREDIT CSR

<%for(pidx = 0; pidx < nALLs; pidx++) { %>  
    <%if(_child_blk[pidx].match('chiaiu')) { %>
       int <%=_child_blkid[pidx]%>_dce_credit_state[<%=obj.nDCEs%>];
       int <%=_child_blkid[pidx]%>_dmi_credit_state[<%=obj.nDMIs%>];
       int <%=_child_blkid[pidx]%>_dii_credit_state[<%=obj.nDIIs%>];
    <%} else { %>
          <% if (_child_blk[pidx].match('ioaiu')) { %>
                int <%=_child_blkid[pidx]%>_dce_credit_state[<%=_child_blk_nCore[pidx]%>][<%=obj.nDCEs%>]; 
                int <%=_child_blkid[pidx]%>_dmi_credit_state[<%=_child_blk_nCore[pidx]%>][<%=obj.nDMIs%>]; 
                int <%=_child_blkid[pidx]%>_dii_credit_state[<%=_child_blk_nCore[pidx]%>][<%=obj.nDIIs%>]; 
          <% } %>
    <% } %>
    <%  if(_child_blk[pidx].match('dce')) { %>
       int <%=_child_blkid[pidx]%>_dmi_credit_state[<%=obj.nDMIs%>];
    <%}%>
<%}%>

<%for(pidx = 0; pidx < nALLs; pidx++) { %>  
    <%  if(_child_blk[pidx].match('aiu')) { %>
// QOS CSR
    int <%=_child_blkid[pidx]%>_qos_eventstatus[<%=_child_blk_nCore[pidx]%>];
    int <%=_child_blkid[pidx]%>_qos_eventstatuscount[<%=_child_blk_nCore[pidx]%>];
    int <%=_child_blkid[pidx]%>_qos_eventstatuscountoverflow[<%=_child_blk_nCore[pidx]%>];
// PROXY $ CSR
    <%if(_child[pidx].fnNativeInterface == 'AXI4' && _child[pidx].useCache) {%>
    int <%=_child_blkid[pidx]%>_pc_allocactive[<%=_child_blk_nCore[pidx]%>];
    int <%=_child_blkid[pidx]%>_pc_evictactive[<%=_child_blk_nCore[pidx]%>];
    <%} // if ioaiu with cache %>
// ERROR CSR
    int <%=_child_blkid[pidx]%>_uncorr_errvld[<%=_child_blk_nCore[pidx]%>];
    int <%=_child_blkid[pidx]%>_uncorr_errtype[<%=_child_blk_nCore[pidx]%>];
    int <%=_child_blkid[pidx]%>_uncorr_errinfo[<%=_child_blk_nCore[pidx]%>];
    <% if (_child_blk[pidx].match('ioaiu')) { %>
    int <%=_child_blkid[pidx]%>_corr_errvld[<%=_child_blk_nCore[pidx]%>];
    int <%=_child_blkid[pidx]%>_corr_errtype[<%=_child_blk_nCore[pidx]%>];
    int <%=_child_blkid[pidx]%>_corr_errinfo[<%=_child_blk_nCore[pidx]%>];

    <%} // if ioaiu%>
    <%} // if aiu%>
   
    <% if (_child_blk[pidx].match('dce')) { %>
    int <%=_child_blkid[pidx]%>_uncorr_errvld[1];
    int <%=_child_blkid[pidx]%>_uncorr_errtype[1];
    int <%=_child_blkid[pidx]%>_uncorr_errinfo[1];
    <%} // if dce%>
// DMI WTT,RTT,Write Buffer
   <% if (_child_blk[pidx].match('dmi')) { %>
   bit <%=_child_blkid[pidx]%>_full_rtt;
   bit <%=_child_blkid[pidx]%>_full_wtt;
   bit <%=_child_blkid[pidx]%>_full_nc_wr_buf;
   bit <%=_child_blkid[pidx]%>_full_c_wr_buf ;
   bit <%=_child_blkid[pidx]%>_threshold_reached_rtt;
   bit <%=_child_blkid[pidx]%>_threshold_reached_wtt;
   bit <%=_child_blkid[pidx]%>_threshold_reached_nc_wr_buf;
   //NKR - Signal removed from Ncore3.6
   //bit <%=_child_blkid[pidx]%>_threshold_reached_c_wr_buf;
   bit <%=_child_blkid[pidx]%>_smc_allocactive;
   bit <%=_child_blkid[pidx]%>_smc_evictactive;
   int <%=_child_blkid[pidx]%>_uncorr_errvld[1];
   int <%=_child_blkid[pidx]%>_uncorr_errtype[1];
   int <%=_child_blkid[pidx]%>_uncorr_errinfo[1];
    <%} // if dmi%>

<%} //each nALLs%>
//////////////
/// PROBE  //
//////////////
// CREDIT CSR
<%for(pidx = 0; pidx < nALLs; pidx++) { %>
     <%  if(_child_blk[pidx].match('chiaiu')) { %>
         <%for (var j=0; j< obj.nDCEs; j++){%> 
         assign <%=_child_blkid[pidx]%>_dce_credit_state[<%=j%>] =  `AIU<%=pidx%>.unit.chi_aiu_csr.CAIUCCR<%=j%>_DCECounterState_out; 
         <%}%>

         <%for (var j=0; j< obj.nDMIs; j++){%> 
         assign <%=_child_blkid[pidx]%>_dmi_credit_state[<%=j%>] = `AIU<%=pidx%>.unit.chi_aiu_csr.CAIUCCR<%=j%>_DMICounterState_out; 
         <%}%>
         
         <%for (var j=0; j< obj.nDIIs; j++){%> 
         assign <%=_child_blkid[pidx]%>_dii_credit_state[<%=j%>] = `AIU<%=pidx%>.unit.chi_aiu_csr.CAIUCCR<%=j%>_DIICounterState_out; 
         <%}%>      
    <% }%>
    <%  if(_child_blk[pidx].match('ioaiu')) { %>
        <%for (var c=0; c <_child_blk_nCore[pidx];c++)  {%>
         <%for (var j=0; j< obj.nDCEs; j++){%> 
         assign <%=_child_blkid[pidx]%>_dce_credit_state[<%=c%>][<%=j%>] =  `AIU<%=pidx%>.ioaiu_core_wrapper.ioaiu_core<%=c%>.apb_csr.XAIUCCR<%=j%>_DCECounterState_out; 
         <%}%>

         <%for (var j=0; j< obj.nDMIs; j++){%> 
         assign <%=_child_blkid[pidx]%>_dmi_credit_state[<%=c%>][<%=j%>] =  `AIU<%=pidx%>.ioaiu_core_wrapper.ioaiu_core<%=c%>.apb_csr.XAIUCCR<%=j%>_DMICounterState_out; 
         <%}%>
         
         <%for (var j=0; j< obj.nDIIs; j++){%> 
         assign <%=_child_blkid[pidx]%>_dii_credit_state[<%=c%>][<%=j%>] =  `AIU<%=pidx%>.ioaiu_core_wrapper.ioaiu_core<%=c%>.apb_csr.XAIUCCR<%=j%>_DIICounterState_out; 
         <%}%>      
       <%} // foreach core%>      
    <% }%>
    <%  if(_child_blk[pidx].match('dce')) { %>
      <%
      var ASILB  = 0; // (obj.useResiliency & obj.enableUnitDuplication) ? 0 : 1;
      var hier_path_dce_csr  = '';
      var hier_path_dce_cmux  = '';
      var hier_path_dce_sbcmdreqfifo  = '';
      var hier_path_dce_sb = '';
      if (!ASILB) {
        hier_path_dce_csr = 'dce_func_unit.u_csr';
        hier_path_dce_cmux = 'dce_func_unit.dce_conc_mux';
        hier_path_dce_sbcmdreqfifo = 'dce_func_unit.skid_buf_cmd_req_fifo';
        hier_path_dce_sb = 'dce_func_unit.dce_skid_buffer';
      } else {
        hier_path_dce_csr = 'u_csr';
        hier_path_dce_cmux = 'dce_conc_mux';
        hier_path_dce_sbcmdreqfifo = 'skid_buf_cmd_req_fifo';
        hier_path_dce_sb = 'dce_skid_buffer';
      }
      %>
        <%for (var j=0; j< obj.nDMIs; j++){%> 
         <%if(_child[pidx].hierPath && _child[pidx].hierPath !== ''){%>
            assign <%=_child_blkid[pidx]%>_dmi_credit_state[<%=j%>] = dut.<%=_child[pidx].instancePath%>.<%=hier_path_dce_csr%>.DCEUCCR<%=j%>_DMICounterState_out;
         <%}else{%>
            assign <%=_child_blkid[pidx]%>_dmi_credit_state[<%=j%>] = dut.<%=_child_blkid[pidx]%>.<%=hier_path_dce_csr%>.DCEUCCR<%=j%>_DMICounterState_out;
         <%}%>
        <%}%>
     <% }%>
<%}// each nALLS%>

//ERROR CSR
<%for(pidx = 0; pidx < nALLs; pidx++) { %>  
    <%  if(_child_blk[pidx].match('chiaiu')) { %>
    assign <%=_child_blkid[pidx]%>_uncorr_errvld[0] = `AIU<%=pidx%>.unit.chi_aiu_csr.CAIUUESR_ErrVld_out;
    assign <%=_child_blkid[pidx]%>_uncorr_errtype[0] = `AIU<%=pidx%>.unit.chi_aiu_csr.CAIUUESR_ErrType_out;
    assign <%=_child_blkid[pidx]%>_uncorr_errinfo[0] = `AIU<%=pidx%>.unit.chi_aiu_csr.CAIUUESR_ErrInfo_out;
    <%} // if chi%>
    
    <% if (_child_blk[pidx].match('ioaiu')) { %>
        <%for (var c=0; c <_child_blk_nCore[pidx];c++)  {%>
        assign <%=_child_blkid[pidx]%>_uncorr_errvld[<%=c%>] = `AIU<%=pidx%>.ioaiu_core_wrapper.ioaiu_core<%=c%>.apb_csr.XAIUUESR_ErrVld_out;
        assign <%=_child_blkid[pidx]%>_uncorr_errtype[<%=c%>] = `AIU<%=pidx%>.ioaiu_core_wrapper.ioaiu_core<%=c%>.apb_csr.XAIUUESR_ErrType_out;
        assign <%=_child_blkid[pidx]%>_uncorr_errinfo[<%=c%>] = `AIU<%=pidx%>.ioaiu_core_wrapper.ioaiu_core<%=c%>.apb_csr.XAIUUESR_ErrInfo_out;
        assign <%=_child_blkid[pidx]%>_corr_errvld[<%=c%>]   = `AIU<%=pidx%>.ioaiu_core_wrapper.ioaiu_core<%=c%>.apb_csr.XAIUCESR_ErrVld_out;
        assign <%=_child_blkid[pidx]%>_corr_errtype[<%=c%>]   = `AIU<%=pidx%>.ioaiu_core_wrapper.ioaiu_core<%=c%>.apb_csr.XAIUCESR_ErrType_out;
        assign <%=_child_blkid[pidx]%>_corr_errinfo[<%=c%>]   = `AIU<%=pidx%>.ioaiu_core_wrapper.ioaiu_core<%=c%>.apb_csr.XAIUCESR_ErrInfo_out;
    
    // PROXY $ CSR
          <%if(_child[pidx].fnNativeInterface == 'AXI4' && _child[pidx].useCache) {%>
              assign <%=_child_blkid[pidx]%>_pc_allocactive[<%=c%>] = `AIU<%=pidx%>.ioaiu_core_wrapper.ioaiu_core<%=c%>.apb_csr.XAIUPCTAR_AllocActive_out;
              assign <%=_child_blkid[pidx]%>_pc_evictactive[<%=c%>] = `AIU<%=pidx%>.ioaiu_core_wrapper.ioaiu_core<%=c%>.apb_csr.XAIUPCTAR_EvictActive_out;
          <%} // if ioaiu with cache %>
       <%} // foreach core%>      
    <%} // if ioaiu%>
   <%  if(_child_blk[pidx].match('dce')) { %>
      <%
      var ASILB  = 0; // (obj.useResiliency & obj.enableUnitDuplication) ? 0 : 1;
      var hier_path_dce_csr  = '';
      var hier_path_dce_cmux  = '';
      var hier_path_dce_sbcmdreqfifo  = '';
      var hier_path_dce_sb = '';
      if (!ASILB) {
        hier_path_dce_csr = 'dce_func_unit.u_csr';
        hier_path_dce_cmux = 'dce_func_unit.dce_conc_mux';
        hier_path_dce_sbcmdreqfifo = 'dce_func_unit.skid_buf_cmd_req_fifo';
        hier_path_dce_sb = 'dce_func_unit.dce_skid_buffer';
      } else {
        hier_path_dce_csr = 'u_csr';
        hier_path_dce_cmux = 'dce_conc_mux';
        hier_path_dce_sbcmdreqfifo = 'skid_buf_cmd_req_fifo';
        hier_path_dce_sb = 'dce_skid_buffer';
      }
      %>
         <%if(_child[pidx].hierPath && _child[pidx].hierPath !== ''){%>
               assign <%=_child_blkid[pidx]%>_uncorr_errvld[0]  = dut.<%=_child[pidx].instancePath%>.<%=hier_path_dce_csr%>.DCEUUESR_ErrVld_out; 
               assign <%=_child_blkid[pidx]%>_uncorr_errtype[0] = dut.<%=_child[pidx].instancePath%>.<%=hier_path_dce_csr%>.DCEUUESR_ErrType_out; 
               assign <%=_child_blkid[pidx]%>_uncorr_errinfo[0] = dut.<%=_child[pidx].instancePath%>.<%=hier_path_dce_csr%>.DCEUUESR_ErrInfo_out; 
         <%}else{%>
               assign <%=_child_blkid[pidx]%>_uncorr_errvld[0] = dut.<%=_child_blkid[pidx]%>.<%=hier_path_dce_csr%>.DCEUUESR_ErrVld_out; 
               assign <%=_child_blkid[pidx]%>_uncorr_errtype[0] = dut.<%=_child_blkid[pidx]%>.<%=hier_path_dce_csr%>.DCEUUESR_ErrType_out; 
               assign <%=_child_blkid[pidx]%>_uncorr_errinfo[0] = dut.<%=_child_blkid[pidx]%>.<%=hier_path_dce_csr%>.DCEUUESR_ErrInfo_out; 
         <% }%>
     <% }%>

// DMI WTT/RTT threshold
   <%  if(_child_blk[pidx].match('dmi')) { %>
       <%if(_child[pidx].hierPath && _child[pidx].hierPath !== ''){%>
           <% if(_child[pidx].fnEnableQos) { %>
              assign <%=_child_blkid[pidx]%>_full_rtt = & (dut.<%=_child[pidx].instancePath%>.dmi_unit.dmi_transaction_control.rtt.tt_valid);
              assign <%=_child_blkid[pidx]%>_full_wtt = & (dut.<%=_child[pidx].instancePath%>.dmi_unit.dmi_transaction_control.wtt.wtt_valid);
              // NF: These signals don't exist in NCore3.6
              assign <%=_child_blkid[pidx]%>_full_nc_wr_buf = & (dut.<%=_child[pidx].instancePath%>.dmi_unit.dmi_protocol_control.nc_write_buffer.rb_id_valid);
              assign <%=_child_blkid[pidx]%>_full_c_wr_buf = & (dut.<%=_child[pidx].instancePath%>.dmi_unit.dmi_protocol_control.c_write_buffer.rb_id_valid);
              
              assign <%=_child_blkid[pidx]%>_threshold_reached_rtt = dut.<%=_child[pidx].instancePath%>.dmi_unit.dmi_protocol_control.RTT_threshold_reached;
              assign <%=_child_blkid[pidx]%>_threshold_reached_wtt = dut.<%=_child[pidx].instancePath%>.dmi_unit.dmi_protocol_control.WTT_threshold_reached;
              assign <%=_child_blkid[pidx]%>_threshold_reached_nc_wr_buf = dut.<%=_child[pidx].instancePath%>.dmi_unit.dmi_protocol_control.nc_wDataBuffer_threshold_reached;
           <% } // if qos enable%>
           <% if(_child[pidx].useCmc) { %>
              assign <%=_child_blkid[pidx]%>_smc_allocactive = dut.<%=_child[pidx].instancePath%>.dmi_unit.csr.DMIUSMCTAR_AllocActive_out;
              assign <%=_child_blkid[pidx]%>_smc_evictactive = dut.<%=_child[pidx].instancePath%>.dmi_unit.csr.DMIUSMCTAR_EvictActive_out;
           <% } // if qos smc%>
           assign <%=_child_blkid[pidx]%>_uncorr_errvld[0] = dut.<%=_child[pidx].instancePath%>.dmi_unit.csr.DMIUUESR_ErrVld_out; 
           assign <%=_child_blkid[pidx]%>_uncorr_errtype[0] = dut.<%=_child[pidx].instancePath%>.dmi_unit.csr.DMIUUESR_ErrType_out; 
           assign <%=_child_blkid[pidx]%>_uncorr_errinfo[0] = dut.<%=_child[pidx].instancePath%>.dmi_unit.csr.DMIUUESR_ErrInfo_out; 
       <%}else{%>
           <% if(_child[pidx].fnEnableQos) { %>
              assign <%=_child_blkid[pidx]%>_full_rtt = & (dut.<%=_child[pidx].strRtlNamePrefix%>.dmi_unit.dmi_transaction_control.rtt.tt_valid);
              assign <%=_child_blkid[pidx]%>_full_wtt = & (dut.<%=_child[pidx].strRtlNamePrefix%>.dmi_unit.dmi_transaction_control.wtt.wtt_valid);
              // NF: These signals don't exist in NCore3.6
              assign <%=_child_blkid[pidx]%>_full_nc_wr_buf = & (dut.<%=_child[pidx].strRtlNamePrefix%>.dmi_unit.dmi_protocol_control.nc_write_buffer.rb_id_valid);
              assign <%=_child_blkid[pidx]%>_full_c_wr_buf = & (dut.<%=_child[pidx].strRtlNamePrefix%>.dmi_unit.dmi_protocol_control.c_write_buffer.rb_id_valid);
              
              assign <%=_child_blkid[pidx]%>_threshold_reached_rtt = dut.<%=_child[pidx].strRtlNamePrefix%>.dmi_unit.dmi_protocol_control.RTT_threshold_reached;
              assign <%=_child_blkid[pidx]%>_threshold_reached_wtt = dut.<%=_child[pidx].strRtlNamePrefix%>.dmi_unit.dmi_protocol_control.WTT_threshold_reached;
              assign <%=_child_blkid[pidx]%>_threshold_reached_nc_wr_buf = dut.<%=_child[pidx].strRtlNamePrefix%>.dmi_unit.dmi_protocol_control.nc_wDataBuffer_threshold_reached;
           <% } // if qos enable%>
           <% if(_child[pidx].useCmc) { %>
              assign <%=_child_blkid[pidx]%>_smc_allocactive = dut.<%=_child[pidx].strRtlNamePrefix%>.dmi_unit.csr.DMIUSMCTAR_AllocActive_out;
              assign <%=_child_blkid[pidx]%>_smc_evictactive = dut.<%=_child[pidx].strRtlNamePrefix%>.dmi_unit.csr.DMIUSMCTAR_EvictActive_out;
           <% } // if qos smc%>
           assign <%=_child_blkid[pidx]%>_uncorr_errvld[0] = dut.<%=_child[pidx].strRtlNamePrefix%>.dmi_unit.csr.DMIUUESR_ErrVld_out; 
           assign <%=_child_blkid[pidx]%>_uncorr_errtype[0] = dut.<%=_child[pidx].strRtlNamePrefix%>.dmi_unit.csr.DMIUUESR_ErrType_out; 
           assign <%=_child_blkid[pidx]%>_uncorr_errinfo[0] = dut.<%=_child[pidx].strRtlNamePrefix%>.dmi_unit.csr.DMIUUESR_ErrInfo_out; 
       <% }%>
   <% }%>

<%}// each nALLS%>

//IOAIU QOS
<%for(pidx = 0; pidx < nALLs; pidx++) { %>  
    <%  if(_child_blk[pidx].match('chiaiu')) { %>
    assign <%=_child_blkid[pidx]%>_qos_eventstatus[0] = `AIU<%=pidx%>.unit.chi_aiu_csr.CAIUQOSSR_EventStatus_out;
    assign <%=_child_blkid[pidx]%>_qos_eventstatuscount[0] = (`AIU<%=pidx%>.unit.chi_aiu_csr.CAIUQOSSR_EventStatusCount_out > 0);
    assign <%=_child_blkid[pidx]%>_qos_eventstatuscountoverflow[0] = `AIU<%=pidx%>.unit.chi_aiu_csr.CAIUQOSSR_EventStatusCountOverflow_out;
    <%} // if chi%>
    <% if (_child_blk[pidx].match('ioaiu')) { %>
        <%for (var c=0; c <_child_blk_nCore[pidx];c++)  {%>
    assign <%=_child_blkid[pidx]%>_qos_eventstatus[<%=c%>]               = `AIU<%=pidx%>.ioaiu_core_wrapper.ioaiu_core<%=c%>.apb_csr.XAIUQOSSR_EventStatus_out;
    assign <%=_child_blkid[pidx]%>_qos_eventstatuscount[<%=c%>]          = (`AIU<%=pidx%>.ioaiu_core_wrapper.ioaiu_core<%=c%>.apb_csr.XAIUQOSSR_EventStatusCount_out > 0);
    assign <%=_child_blkid[pidx]%>_qos_eventstatuscountoverflow[<%=c%>]  = `AIU<%=pidx%>.ioaiu_core_wrapper.ioaiu_core<%=c%>.apb_csr.XAIUQOSSR_EventStatusCountOverflow_out;
       <%} // foreach core%>      
    <%} // if ioaiu%>
<%}// each nALLS%>
endinterface

`endif // FSYS_COV_CSR_PROBE_IF_SV
