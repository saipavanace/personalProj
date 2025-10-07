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

   for(pidx = 0; pidx < obj.nAIUs; pidx++) {
       if((obj.AiuInfo[pidx].fnNativeInterface == 'CHI-A')||(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-B')||(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-E')) {
       _child_blkid[pidx] = 'chiaiu' + idx;
       _child_blk[pidx]   = 'chiaiu';
       numChiAiu = numChiAiu + 1;
       idx++;
       } else {
       if(obj.AiuInfo[pidx].fnNativeInterface == 'ACE5'||obj.AiuInfo[pidx].fnNativeInterface == 'ACE') { numAce++; }
       if(obj.AiuInfo[pidx].fnNativeInterface == 'ACE-LITE') { numAceLite++; }
       if(obj.AiuInfo[pidx].fnNativeInterface == 'ACELITE-E') { numAceLiteE++; }
       if(obj.AiuInfo[pidx].fnNativeInterface == 'AXI4' && obj.AiuInfo[pidx].useCache) { numAxi4_with_cache++; }
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
class Fsys_sftcrdt_coverage extends Fsys_base_coverage;

/////////////////////////////////////////////////////////////////////////////////////
//     ##   ##### ##### #####  # #####  #    # #####  ####  
//    #  #    #     #   #    # # #    # #    #   #   #      
//   #    #   #     #   #    # # #####  #    #   #    ####  
//   ######   #     #   #####  # #    # #    #   #        # 
//   #    #   #     #   #   #  # #    # #    #   #   #    # 
//   #    #   #     #   #    # # #####   ####    #    ####  
/////////////////////////////////////////////////////////////////////////////////////
<%for(pidx = 0; pidx < nALLs; pidx++) { %>  
    <%  if(_child_blk[pidx].match('chiaiu') || _child_blk[pidx].match('ioaiu')) { %>
    <%if (typeof _child_blk_nCore[pidx] === 'undefined')  {%>
    int <%=_child_blkid[pidx]%>_dce_credit_state[<%=obj.nDCEs%>];
    int <%=_child_blkid[pidx]%>_dmi_credit_state[<%=obj.nDMIs%>];
    int <%=_child_blkid[pidx]%>_dii_credit_state[<%=obj.nDIIs%>];
    <%} else {%>
    int <%=_child_blkid[pidx]%>_dce_credit_state[<%=_child_blk_nCore[pidx]%>][<%=obj.nDCEs%>]; 
    int <%=_child_blkid[pidx]%>_dmi_credit_state[<%=_child_blk_nCore[pidx]%>][<%=obj.nDMIs%>]; 
    int <%=_child_blkid[pidx]%>_dii_credit_state[<%=_child_blk_nCore[pidx]%>][<%=obj.nDIIs%>]; 
    <%}%>
    <%}%>
    <%  if(_child_blk[pidx].match('dce')) { %>
    int <%=_child_blkid[pidx]%>_dmi_credit_state[<%=obj.nDMIs%>];
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
<% // Commun Bins
var sftw_credit_bins_str = 
`
          bins normal = {0};
          bins all_crdt_used = {1};
          bins all_crdt_available = {4};
`;
%>                   
// AIUs Commun covergroup 
   covergroup cg_coh_crdt;
//#Cover.FSYS.CCRstate.ALL.atleastone.normal
//#Cover.FSYS.CCRstate.all_crdt_available
//#Cover.FSYS.CCRstate.all_crdt_used
<%for(pidx = 0; pidx < nALLs; pidx++) { %>
   <%  if(_child_blk[pidx].match('dce')) { %>
        <%for (var j=0; j< obj.nDMIs; j++){%> 
          <%var found =0;
          if (obj.ConnectivityMap ) {
               for(var i = 0 ; i < obj.ConnectivityMap.dceDmiMap[pidx].length; i++){  
                    if(obj.ConnectivityMap.dceDmiMap[pidx][i] == obj.DmiInfo[j].FUnitId) { found = 1; }  
               }  
               if(found == 0) continue;
          }
          %>
          CovCreditDMI<%=j%>_<%=_child_blkid[pidx]%>: coverpoint <%=_child_blkid[pidx]%>_dmi_credit_state[<%=j%>] {
               <%=sftw_credit_bins_str%>
          }
   <%} // foreach dmi %>
  <%} // if dce%>
   <%  if(_child_blk[pidx].match('ioaiu')) { %>
    <%for (var c=0; c <_child_blk_nCore[pidx];c++)  {%>
         <%for (var j=0; j< obj.nDCEs; j++){%> 
          <%var found =0;
          if (obj.ConnectivityMap ) {
               for(var i = 0 ; i<obj.ConnectivityMap.aiuDceMap[pidx].length; i++){  
                    if(obj.ConnectivityMap.aiuDceMap[pidx][i] == obj.DceInfo[j].FUnitId) { found = 1; }  
               }  
               if(found == 0) continue;
          } 
          %>
         CovCreditDCE<%=j%>_<%=_child_blkid[pidx]%>_c<%=c%>: coverpoint <%=_child_blkid[pidx]%>_dce_credit_state[<%=c%>][<%=j%>] {
               <%=sftw_credit_bins_str%>
         }
         <%} // each dce%>
    <%} //each core%>      
   <%} // if ioaiu%>
   <%  if(_child_blk[pidx].match('chiaiu')) { %>
         <%for (var j=0; j< obj.nDCEs; j++){%> 
          <%var found =0;
          if (obj.ConnectivityMap ) {
               for(var i = 0 ; i<obj.ConnectivityMap.aiuDceMap[pidx].length; i++){  
                    if(obj.ConnectivityMap.aiuDceMap[pidx][i] == obj.DceInfo[j].FUnitId) { found = 1; }  
               }  
               if(found == 0) continue;
          }
          %>
         CovCreditDCE<%=j%>_<%=_child_blkid[pidx]%>: coverpoint <%=_child_blkid[pidx]%>_dce_credit_state[<%=j%>] {
               <%=sftw_credit_bins_str%>
         }
         <%} // each dce%>
   <%} // if chiaiu%>
<%} // for nALLs%>
 
   endgroup  

covergroup cg_noncoh_crdt;
//#Cover.FSYS.CCRstate.ALL.atleastone.normal
//#Cover.FSYS.CCRstate.all_crdt_available
//#Cover.FSYS.CCRstate.all_crdt_used
<%for(pidx = 0; pidx < nALLs; pidx++) { %>
     <%if(_child_blk[pidx].match('ioaiu')) { %>
     <%for (var c=0; c <_child_blk_nCore[pidx];c++)  {%>

          <%for (var j=0; j< obj.nDMIs; j++){%>
               <%var found =0;
               if (obj.ConnectivityMap ) {
                    if (obj.ConnectivityMap.aiuDmiMap[pidx]){
                    for(var i = 0 ; i<obj.ConnectivityMap.aiuDmiMap[pidx].length; i++){  
                         if(obj.ConnectivityMap.aiuDmiMap[pidx][i] == obj.DmiInfo[j].FUnitId) { found = 1; }  
                    }  
                    }
                    if(found == 0) continue;
               }
               %>

          CovCreditDMI<%=j%>_<%=_child_blkid[pidx]%>_c<%=c%>: coverpoint <%=_child_blkid[pidx]%>_dmi_credit_state[<%=c%>][<%=j%>] {
               <%=sftw_credit_bins_str%>
               }
          <%}%>
         
          <%for (var j=0; j< obj.nDIIs; j++){%> 
               <% var found =0;
               if (obj.ConnectivityMap ) {
                    if (obj.ConnectivityMap.aiuDiiMap[pidx]){
                    for(var i = 0 ; i<obj.ConnectivityMap.aiuDiiMap[pidx].length; i++){  
                         if(obj.ConnectivityMap.aiuDiiMap[pidx][i] == obj.DiiInfo[j].FUnitId) { found = 1; }  
                    }  
                    }
                    if(found == 0) continue;
               }
               %>
          CovCreditDII<%=j%>_<%=_child_blkid[pidx]%>_c<%=c%>: coverpoint <%=_child_blkid[pidx]%>_dii_credit_state[<%=c%>][<%=j%>] {
               <%if(j < obj.nDIIs-1) {%>
               <%=sftw_credit_bins_str%><%} else {%>
               bins normal = {0};
               bins all_crdt_available = {4};
               <%}%>
               }   
          <%}%>   
    <%}%>      
   <%} // if ioaiu%>
  <%  if(_child_blk[pidx].match('chiaiu')) { %>
         <%for (var j=0; j< obj.nDMIs; j++){%> 
               <% var found =0;
               if (obj.ConnectivityMap ) {
                    if (obj.ConnectivityMap.aiuDmiMap[pidx]){
                    for(var i = 0 ; i<obj.ConnectivityMap.aiuDmiMap[pidx].length; i++){  
                         if(obj.ConnectivityMap.aiuDmiMap[pidx][i] == obj.DmiInfo[j].FUnitId) { found = 1; }  
                    }  
                    }
                    if(found == 0) continue;
               }
               %>
         CovCreditDMI<%=j%>_<%=_child_blkid[pidx]%>: coverpoint <%=_child_blkid[pidx]%>_dmi_credit_state[<%=j%>] {
               <%=sftw_credit_bins_str%>
         }
         <%}%>
         
         <%for (var j=0; j< obj.nDIIs; j++){%> 
               <%var found =0;
               if (obj.ConnectivityMap ) {
                    if (obj.ConnectivityMap.aiuDiiMap[pidx]){
                    for(var i = 0 ; i<obj.ConnectivityMap.aiuDiiMap[pidx].length; i++){  
                         if(obj.ConnectivityMap.aiuDiiMap[pidx][i] == obj.DiiInfo[j].FUnitId) { found = 1; }  
                    }  
                    }
                    if(found == 0) continue;
               }
               %>
         CovCreditDII<%=j%>_<%=_child_blkid[pidx]%>: coverpoint <%=_child_blkid[pidx]%>_dii_credit_state[<%=j%>] {
               <%if(j < obj.nDIIs-1) {%>
               <%=sftw_credit_bins_str%><%} else {%>
               bins normal = {0};
               bins all_crdt_available = {4};
               <%}%>
         }
        <%}%>  
   <%} // if chiaiu%>
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
       cg_coh_crdt = new();
       cg_noncoh_crdt= new();
    endfunction:new

    // ALL FUNCTIONS
<%for(pidx = 0; pidx < nALLs; pidx++) { %>  
    extern function void collect_item_<%=_child_blkid[pidx]%>();
<%}%>
endclass:Fsys_sftcrdt_coverage

///////////////////////////////////////////////////////////////////////////////////
//  ###### #    # #    #  ####  ##### #  ####  #    #  ####  
//  #      #    # ##   # #    #   #   # #    # ##   # #      
//  #####  #    # # #  # #        #   # #    # # #  #  ####  
//  #      #    # #  # # #        #   # #    # #  # #      # 
//  #      #    # #   ## #    #   #   # #    # #   ## #    # 
//  #       ####  #    #  ####    #   #  ####  #    #  ####  
//////////////////////////////////////////////////////////////////////////////////
                                                            
<%for(pidx = 0; pidx < nALLs; pidx++) { %>
function void Fsys_sftcrdt_coverage::collect_item_<%=_child_blkid[pidx]%>();   // each smi & native_itf req check the status of credit
     if (!csr_init_done) return; // do nothing if boot_seq isn't done
     <%  if(_child_blk[pidx].match('chiaiu')) { %>
         <%for (var j=0; j< obj.nDCEs; j++){%> 
         <%=_child_blkid[pidx]%>_dce_credit_state[<%=j%>] =  vif.<%=_child_blkid[pidx]%>_dce_credit_state[<%=j%>]; 
         <%}%>

         <%for (var j=0; j< obj.nDMIs; j++){%> 
         <%=_child_blkid[pidx]%>_dmi_credit_state[<%=j%>] = vif.<%=_child_blkid[pidx]%>_dmi_credit_state[<%=j%>]; 
         <%}%>
         
         <%for (var j=0; j< obj.nDIIs; j++){%> 
         <%=_child_blkid[pidx]%>_dii_credit_state[<%=j%>] = vif.<%=_child_blkid[pidx]%>_dii_credit_state[<%=j%>]; 
         <%}%>      
        cg_coh_crdt.sample();
        cg_noncoh_crdt.sample();
    <% }%>
    <%  if(_child_blk[pidx].match('ioaiu')) { %>
        <%for (var c=0; c <_child_blk_nCore[pidx];c++)  {%>
         <%for (var j=0; j< obj.nDCEs; j++){%> 
         <%=_child_blkid[pidx]%>_dce_credit_state[<%=c%>][<%=j%>] =  vif.<%=_child_blkid[pidx]%>_dce_credit_state[<%=c%>][<%=j%>]; 
         <%}%>

         <%for (var j=0; j< obj.nDMIs; j++){%> 
         <%=_child_blkid[pidx]%>_dmi_credit_state[<%=c%>][<%=j%>] =  vif.<%=_child_blkid[pidx]%>_dmi_credit_state[<%=c%>][<%=j%>];
         <%}%>
         
         <%for (var j=0; j< obj.nDIIs; j++){%> 
         <%=_child_blkid[pidx]%>_dii_credit_state[<%=c%>][<%=j%>] =  vif.<%=_child_blkid[pidx]%>_dii_credit_state[<%=c%>][<%=j%>];
         <%}%>      
       <%}%>      
        cg_coh_crdt.sample();
        cg_noncoh_crdt.sample();
    <% }%>
    <%  if(_child_blk[pidx].match('dce')) { %>
        <%for (var j=0; j< obj.nDMIs; j++){%> 
         <%=_child_blkid[pidx]%>_dmi_credit_state[<%=j%>] = vif.<%=_child_blkid[pidx]%>_dmi_credit_state[<%=j%>]; 
        <%}%>
        cg_coh_crdt.sample();
     <% }%>
endfunction:collect_item_<%=_child_blkid[pidx]%>
<% }%>
