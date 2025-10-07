////////////////////////////////////////////////////////////////////////////////
//
// fsys_sftcredit_coverage 
// Author: Cyrille LUDWIG
//
////////////////////////////////////////////////////////////////////////////////
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
   var numAce_with_if_parity_check = 0;
   var numAxi5_with_if_parity_check = 0;
   var numAce5Lite_with_if_parity_check = 0;
   let computedAxiInt;

   for(pidx = 0; pidx < obj.nAIUs; pidx++) {
       if((obj.AiuInfo[pidx].fnNativeInterface == 'CHI-A')||(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-B')||(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-E')) {
       _child_blkid[pidx] = 'chiaiu' + idx;
       _child_blk[pidx]   = 'chiaiu';
       numChiAiu = numChiAiu + 1;
       idx++;
       } else {
       if(obj.AiuInfo[pidx].fnNativeInterface == 'ACE5'||obj.AiuInfo[pidx].fnNativeInterface == 'ACE') { 
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
`include "concerto_phys.sv"
//#Cover.FSYS.v371.if_parity_chk_err.XAIUUESR.ErrVld_in_func_cov
//#Cover.FSYS.v371.if_parity_chk_err.XAIUUESR.ErrInfo_in_func_cov
//#Cover.FSYS.v371.if_parity_chk_err.XAIUUESR.ErrType_in_func_cov
class Fsys_if_parity_chk_coverage extends Fsys_base_coverage;

/////////////////////////////////////////////////////////////////////////////////////
//     ##   ##### ##### #####  # #####  #    # #####  ####  
//    #  #    #     #   #    # # #    # #    #   #   #      
//   #    #   #     #   #    # # #####  #    #   #    ####  
//   ######   #     #   #####  # #    # #    #   #        # 
//   #    #   #     #   #   #  # #    # #    #   #   #    # 
//   #    #   #     #   #    # # #####   ####    #    ####  
/////////////////////////////////////////////////////////////////////////////////////
<%for(pidx = 0; pidx < nALLs; pidx++) { %>  
    <%  if(_child_blk[pidx].match('ioaiu')) { %>

   <%if(Array.isArray(_child[pidx].interfaces.axiInt)){
               computedAxiInt = _child[pidx].interfaces.axiInt[0];
   }else{
               computedAxiInt = _child[pidx].interfaces.axiInt;
   }%>
       <%if((_child[pidx].fnNativeInterface == 'ACE5' || _child[pidx].fnNativeInterface == 'ACELITE-E' || _child[pidx].fnNativeInterface == 'AXI5') && (computedAxiInt.params.checkType=="ODD_PARITY_BYTE_ALL")) {%>
           <%for (var c=0; c <_child_blk_nCore[pidx];c++)  {%>
            int <%=_child_blkid[pidx]%>_uncorr_errvld[<%=_child_blk_nCore[pidx]%>] ;
            int <%=_child_blkid[pidx]%>_uncorr_errtype[<%=_child_blk_nCore[pidx]%>];
            int <%=_child_blkid[pidx]%>_uncorr_errinfo[<%=_child_blk_nCore[pidx]%>];
           <%} // foreach core%>
       <%}%>
     <%}%>
<%}%>
 
   
                                                   

///////////////////////////////////////////////////////////////////////////////////
// ####   ####  #    # ###### #####   ####  #####   ####  #    # #####   ####  
//#    # #    # #    # #      #    # #    # #    # #    # #    # #    # #      
//#      #    # #    # #####  #    # #      #    # #    # #    # #    #  ####  
//#      #    # #    # #      #####  #  ### #####  #    # #    # #####       # 
//#    # #    #  #  #  #      #   #  #    # #   #  #    # #    # #      #    # 
// ####   ####    ##   ###### #    #  ####  #    #  ####   ####  #       ####  
///////////////////////////////////////////////////////////////////////////////////
                  
// AIUs Commun covergroup 
   covergroup cg_if_parity_chk;
<%for(pidx = 0; pidx < nALLs; pidx++) { %>
   <%  if(_child_blk[pidx].match('ioaiu')) { %>
   <%if(Array.isArray(_child[pidx].interfaces.axiInt)){
               computedAxiInt = _child[pidx].interfaces.axiInt[0];
   }else{
               computedAxiInt = _child[pidx].interfaces.axiInt;
   }%>
       <%if((_child[pidx].fnNativeInterface == 'ACE5' || _child[pidx].fnNativeInterface == 'ACELITE-E' || _child[pidx].fnNativeInterface == 'AXI5') && (computedAxiInt.params.checkType=="ODD_PARITY_BYTE_ALL")) {%>
           <%for (var c=0; c <_child_blk_nCore[pidx];c++)  {%>
           CP_<%=_child_blkid[pidx]%>_uncorr_errvld_<%=c%> : coverpoint <%=_child_blkid[pidx]%>_uncorr_errvld[<%=c%>] {
               bins uncorr_errvld_value_1 = {1};
               ignore_bins uncorr_errvld_value_0 = {0};
           }

           CP_<%=_child_blkid[pidx]%>_uncorr_errtype_<%=c%> : coverpoint <%=_child_blkid[pidx]%>_uncorr_errtype[<%=c%>] {
               bins interface_checker_error = {'hD};
           }

           CP_<%=_child_blkid[pidx]%>_uncorr_errinfo_<%=c%> : coverpoint <%=_child_blkid[pidx]%>_uncorr_errinfo[<%=c%>] {
               bins interface_checker_error_channel_AR  = {'h0};
               bins interface_checker_error_channel_AW  = {'h1};
               bins interface_checker_error_channel_W   = {'h2};
               bins interface_checker_error_channel_R   = {'h3};
               bins interface_checker_error_channel_B   = {'h4};
       <%if(_child[pidx].fnNativeInterface == 'ACE5' || _child[pidx].fnNativeInterface == 'ACELITE-E') {%>
               bins interface_checker_error_channel_CR  = {'h5};
               bins interface_checker_error_channel_AC  = {'h7};
       <%}%>
       <%if(_child[pidx].fnNativeInterface == 'ACE5') {%>
               bins interface_checker_error_channel_CD  = {'h6};
               bins interface_checker_error_channel_RACK= {'h8};
               bins interface_checker_error_channel_WACK= {'h9};
       <%}%>
           }

           Cross_<%=_child_blkid[pidx]%>_uncorr_errvld_errtype_errinfo : cross CP_<%=_child_blkid[pidx]%>_uncorr_errvld_<%=c%>, CP_<%=_child_blkid[pidx]%>_uncorr_errtype_<%=c%>, CP_<%=_child_blkid[pidx]%>_uncorr_errinfo_<%=c%>;
           <%} // foreach core%>
       <%}%>
   <%} // if ioaiu%>
<%} // for nALLs%>
 
   endgroup  

/////////////////////////////////////////////////////////////////////////////////////
//    #    # ###### ##### #    #  ####  #####   ####  
//    ##  ## #        #   #    # #    # #    # #      
//    # ## # #####    #   ###### #    # #    #  ####  
//    #    # #        #   #    # #    # #    #      # 
//    #    # #        #   #    # #    # #    # #    # 
//    #    # ######   #   #    #  ####  #####   ####  
////////////////////////////////////////////////////////////////////////////////////
                                                    
    function new();
     super.new(); 
       //covergroup
       cg_if_parity_chk= new();
    endfunction:new

    // ALL FUNCTIONS
<%for(pidx = 0; pidx < nALLs; pidx++) { %>  
    extern function void collect_item_<%=_child_blkid[pidx]%>();
<%}%>
endclass:Fsys_if_parity_chk_coverage

///////////////////////////////////////////////////////////////////////////////////
//  ###### #    # #    #  ####  ##### #  ####  #    #  ####  
//  #      #    # ##   # #    #   #   # #    # ##   # #      
//  #####  #    # # #  # #        #   # #    # # #  #  ####  
//  #      #    # #  # # #        #   # #    # #  # #      # 
//  #      #    # #   ## #    #   #   # #    # #   ## #    # 
//  #       ####  #    #  ####    #   #  ####  #    #  ####  
//////////////////////////////////////////////////////////////////////////////////
                                                            
<%for(pidx = 0; pidx < nALLs; pidx++) { %>
function void Fsys_if_parity_chk_coverage::collect_item_<%=_child_blkid[pidx]%>();   // each smi & native_itf req check the status of credit
     if (!csr_init_done) return; // do nothing if boot_seq isn't done
   <%  if(_child_blk[pidx].match('ioaiu')) { %>
   <%if(Array.isArray(_child[pidx].interfaces.axiInt)){
               computedAxiInt = _child[pidx].interfaces.axiInt[0];
   }else{
               computedAxiInt = _child[pidx].interfaces.axiInt;
   }%>
       <%if((_child[pidx].fnNativeInterface == 'ACE5' || _child[pidx].fnNativeInterface == 'ACELITE-E' || _child[pidx].fnNativeInterface == 'AXI5') && (computedAxiInt.params.checkType=="ODD_PARITY_BYTE_ALL")) {%>
           <%for (var c=0; c <_child_blk_nCore[pidx];c++)  {%>
               <%=_child_blkid[pidx]%>_uncorr_errvld[<%=c%>]  = vif.<%=_child_blkid[pidx]%>_uncorr_errvld[<%=c%>] ;
               <%=_child_blkid[pidx]%>_uncorr_errtype[<%=c%>] = vif.<%=_child_blkid[pidx]%>_uncorr_errtype[<%=c%>];
               <%=_child_blkid[pidx]%>_uncorr_errinfo[<%=c%>] = vif.<%=_child_blkid[pidx]%>_uncorr_errinfo[<%=c%>];
           <%} // foreach core%>
       <%}%>

       cg_if_parity_chk.sample();
    <% }%>
endfunction:collect_item_<%=_child_blkid[pidx]%>
<% }%>
