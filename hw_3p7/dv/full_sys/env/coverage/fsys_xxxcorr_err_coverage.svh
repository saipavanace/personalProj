////////////////////////////////////////////////////////////////////////////////
//
// fsys_xxxcorr_err_coverage 
// Author: Cyrille LUDWIG
//
////////////////////////////////////////////////////////////////////////////////
<%
//Embedded javascript code to figure number of blocks
   var _child_blkid = [];
   var _child_blk   = [];
   var _child_nativetype   = [];
   var _child_blk_nCore = [];
   var _child   = [{}];
   var useAtomic =1;
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
   var numAxi4   = 0;

   for(pidx = 0; pidx < obj.nAIUs; pidx++) {
       if((obj.AiuInfo[pidx].fnNativeInterface == 'CHI-A')||(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-B')||(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-E')) {
       _child_blkid[pidx] = 'chiaiu' + idx;
       _child_blk[pidx]   = 'chiaiu';
       numChiAiu = numChiAiu + 1;
       idx++;
       } else {
       if(obj.AiuInfo[pidx].fnNativeInterface == 'ACE' || obj.AiuInfo[pidx].fnNativeInterface == 'ACE5') { numAce++;_child_nativetype[pidx]= 'fullace' }
       if(obj.AiuInfo[pidx].fnNativeInterface == 'ACE-LITE') { numAceLite++; _child_nativetype[pidx]= 'ace-lite' }
       if(obj.AiuInfo[pidx].fnNativeInterface == 'ACELITE-E') { numAceLiteE++;_child_nativetype[pidx]= 'ace-lite-e' }
       if(obj.AiuInfo[pidx].fnNativeInterface == 'AXI4' || obj.AiuInfo[pidx].fnNativeInterface == 'AXI5') { numAxi4++;_child_nativetype[pidx]= 'axi4'}
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
       if (!obj.DmiInfo[pidx].useAtomic) { useAtomic=0; } // currently, if one DMI don't use atomic we don't run atomic stimulus
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
class Fsys_xxxcorr_err_coverage extends Fsys_base_coverage;

/////////////////////////////////////////////////////////////////////////////////////
//     ##   ##### ##### #####  # #####  #    # #####  ####  
//    #  #    #     #   #    # # #    # #    #   #   #      
//   #    #   #     #   #    # # #####  #    #   #    ####  
//   ######   #     #   #####  # #    # #    #   #        # 
//   #    #   #     #   #   #  # #    # #    #   #   #    # 
//   #    #   #     #   #    # # #####   ####    #    ####  
/////////////////////////////////////////////////////////////////////////////////////
//at least one err type by native type
<% if (numChiAiu) {%>     
   int chi_uncorr_errtype; 
   int chi_uncorr_errinfo; 
<%} // if chi%>
<% if (numIoAiu)  { %>   
   int ioaiu_uncorr_errtype; 
   int ioaiu_uncorr_errinfo; 
   int ioaiu_corr_errtype;   
   int ioaiu_corr_errinfo;   
<%} // if ioaiu%>
    int dce_uncorr_errtype; 
    int dce_uncorr_errinfo;
    int dmi_uncorr_errtype; 
    int dmi_uncorr_errinfo;
///////////////////////////////////////////////////////////////////////////////////
// ####   ####  #    # ###### #####   ####  #####   ####  #    # #####   ####  
//#    # #    # #    # #      #    # #    # #    # #    # #    # #    # #      
//#      #    # #    # #####  #    # #      #    # #    # #    # #    #  ####  
//#      #    # #    # #      #####  #  ### #####  #    # #    # #####       # 
//#    # #    #  #  #  #      #   #  #    # #   #  #    # #    # #      #    # 
// ####   ####    ##   ###### #    #  ####  #    #  ####   ####  #       ####  
///////////////////////////////////////////////////////////////////////////////////
<% // Commun Bins
var corr_bins_str = `
            bins data = {0};
            bins cache ={1};`;
var uncorr_bins_str = `
            bins native_itf_wr_resp = {2};
            bins native_itf_rd_resp = {3};
            bins native_itf_snp_resp = {4};
            bins decode = {7};
            bins transport = {8};
            bins timeout = {9};
            bins sys_event = {10};
            bins sysco = {11};
            bins soft_prog = {12};
            type_option.goal=0;  // use only cross
            type_option.weight=0;  // use only cross
`;
var soft_prog_err_bins_str = `
            bins no_credit = {1};
            bins unconnect_dmi_access = {3};
            bins unconnect_dii_access = {2};
            bins unconnect_dce_access = {5};
            type_option.goal=0;  // use only cross
            type_option.weight=0;  // use only cross
`;

var dec_err_bins_str = `
            bins no_address_hit = {0};
            bins multiple_address_hit = {1};
            bins illegal_csr_access = {2};
            bins illegal_dii_access = {3};
            bins illegal_secure_access = {4};
            type_option.goal=0;  // use only cross
            type_option.weight=0;  // use only cross
`;
%>

// AIUs DEC ERR covergroup 
   covergroup cg_uncorr_err;
         CovDceSoftProgErrInfo: coverpoint dce_uncorr_errinfo[3:0] {
            <%if (obj.initiatorGroups.length > 1 ) {%>bins unconnect_dmi_access = {2};<%}%>
            bins no_credit = {1};
            type_option.goal=0;  // use only cross
            type_option.weight=0;  // use only cross
         }
         CovDceErrType: coverpoint dce_uncorr_errtype {
            bins data = {0};
            bins decode = {7};
            bins transport = {8};
            bins timeout = {9};
            bins sys_event = {10};
            bins soft_prog = {12};
            type_option.goal=0;  // use only cross
            type_option.weight=0;  // use only cross
         }
   <% if (!useAtomic) {%>
          CovDmiSoftProgErrInfo: coverpoint dmi_uncorr_errinfo[3:0] {
            bins no_atomic = {0};
            type_option.goal=0;  // use only cross
            type_option.weight=0;  // use only cross
         }
         CovDmiErrType: coverpoint dmi_uncorr_errtype {
            bins soft_prog = {12};
            type_option.goal=0;  // use only cross
            type_option.weight=0;  // use only cross
         }
   <%}%>

<% if (numChiAiu) {%>    
         CovChiDecErrInfo: coverpoint chi_uncorr_errinfo[3:0] {
            <%=dec_err_bins_str%>
         }
         CovChiSoftProgErrInfo: coverpoint chi_uncorr_errinfo[3:0] {
            <%=soft_prog_err_bins_str%>
         }
         CovChiErrType: coverpoint chi_uncorr_errtype {
            <%=corr_bins_str%>
            <%=uncorr_bins_str%>         
         }
<% } // if chi%> 
<% if (numIoAiu) {%>    
         CovIoaiuDecErrInfo: coverpoint ioaiu_uncorr_errinfo[3:0] {
            <%=dec_err_bins_str%>
         }
         CovIoaiuSoftProgErrInfo: coverpoint ioaiu_uncorr_errinfo[3:0] {
         <%=soft_prog_err_bins_str%>
         }
         CovIoaiuErrType: coverpoint ioaiu_uncorr_errtype {
          <%=corr_bins_str%>
          <%=uncorr_bins_str%>
         }
<%} // if ioaiu%>

/// CROSS ///
     CrossDceSoftProgErr: cross CovDceErrType, CovDceSoftProgErrInfo { 
         //#Cover.FSYS.decErr.NoCredit
         bins nocredit = binsof (CovDceErrType.soft_prog) && binsof(CovDceSoftProgErrInfo.no_credit); 
        option.cross_auto_bin_max = 0;   
        }  
<% if (!useAtomic) {%>
     CrossDmiSoftProgErr: cross CovDmiErrType, CovDmiSoftProgErrInfo {
         bins atomic_not_allow = binsof (CovDmiErrType.soft_prog) && binsof(CovDmiSoftProgErrInfo.no_atomic); 
        option.cross_auto_bin_max = 0;   
     } 
<%}%>
<% if (numChiAiu) {%>    
     CrossChiSoftProgErr: cross CovChiErrType, CovChiSoftProgErrInfo { 
         //#Cover.FSYS.decErr.NoCredit
         bins nocredit = binsof (CovChiErrType.soft_prog) && binsof(CovChiSoftProgErrInfo.no_credit); 
<%if (obj.initiatorGroups.length > 1 ) {%>
         //#Cover.FSYS.decErr.Unconnected_dmi 
         bins unconnect_dmi = binsof (CovChiErrType.soft_prog) && binsof(CovChiSoftProgErrInfo.unconnect_dmi_access); 
         //#Cover.FSYS.decErr.Unconnected_dii
         bins unconnect_dii = binsof (CovChiErrType.soft_prog) && binsof(CovChiSoftProgErrInfo.unconnect_dii_access); 
         //#Cover.FSYS.decErr.Unconnected_dce // Tested also at AIU block IP level
         // Unreachable due to error priority order and because config expect to have correct hexAiuDce/hexAiuDmi set
         //bins unconnect_dce = binsof (CovChiErrType.decode) && binsof(CovChiDecErrInfo.unconnect_dce_access); 
<%}%>
         option.cross_auto_bin_max = 0;
        }  
     CrossChiDecErr: cross CovChiErrType, CovChiDecErrInfo { 
         //#Cover.FSYS.decErr.reg.illegal_secure_txn
         bins illegal_secure_access = binsof (CovChiErrType.decode) && binsof(CovChiDecErrInfo.illegal_secure_access); 
         //#Cover.FSYS.decErr.reg.illegal_dii_txn
         bins illegal_dii_access = binsof (CovChiErrType.decode) && binsof(CovChiDecErrInfo.illegal_dii_access); 
        option.cross_auto_bin_max = 0;   
        }  
<% } // if chi%> 
<% if (numIoAiu) {%>   
   CrossIoaiuSoftProgErr: cross CovIoaiuErrType, CovIoaiuSoftProgErrInfo {                                                            
      //#Cover.FSYS.decErr.NoCredit
      bins nocredit = binsof (CovIoaiuErrType.soft_prog) && binsof(CovIoaiuSoftProgErrInfo.no_credit);                           
<%if (obj.initiatorGroups.length > 1 ) {%>
      //#Cover.FSYS.decErr.Unconnected_dmi                                                                           
      bins unconnect_dmi = binsof (CovIoaiuErrType.soft_prog) && binsof(CovIoaiuSoftProgErrInfo.unconnect_dmi_access);           
      //#Cover.FSYS.decErr.Unconnected_dii                                                                           
      bins unconnect_dii = binsof (CovIoaiuErrType.soft_prog) && binsof(CovIoaiuSoftProgErrInfo.unconnect_dii_access);           
      //#Cover.FSYS.decErr.Unconnected_dce // Tested also at AIU block IP level
      // Unreachable due to error priority order and because config expect to have correct hexAiuDce/hexAiuDmi set                                                                        
      //bins unconnect_dce = binsof (CovIoaiuErrType.decode) && binsof(CovIoaiuDecErrInfo.unconnect_dce_access);           
<%}%>
     option.cross_auto_bin_max = 0;                                                                                  
     }                            
   CrossIoaiuDecErr: cross CovIoaiuErrType, CovIoaiuDecErrInfo {                                                            
      //#Cover.FSYS.decErr.reg.illegal_secure_txn                                                                    
      bins illegal_secure_access = binsof (CovIoaiuErrType.decode) && binsof(CovIoaiuDecErrInfo.illegal_secure_access);    
      //#Cover.FSYS.decErr.reg.illegal_dii_txn                                                                       
      bins illegal_dii_access = binsof (CovIoaiuErrType.decode) && binsof(CovIoaiuDecErrInfo.illegal_dii_access);        
     option.cross_auto_bin_max = 0;                                                                                  
     }                            
<%} // if ioaiu%>
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
       cg_uncorr_err = new();
    endfunction:new

    // ALL FUNCTIONS
<%for(pidx = 0; pidx < nALLs; pidx++) { %>  
<%  if(_child_blk[pidx].match('ioaiu')) { %>
   <%for (var c=0; c <_child_blk_nCore[pidx];c++)  {%>
    extern function void collect_item_<%=_child_blkid[pidx]%>_core<%=c%>();
   <%} //foreach core%>
<%} else { // if not ioaiu%>
     <%  if(_child_blk[pidx].match('chiaiu') || _child_blk[pidx].match('dce')|| _child_blk[pidx].match('dmi')) { %>
    extern function void collect_item_<%=_child_blkid[pidx]%>();
    <%}%>
<%}%>
<%} // foreach nALLs%>
endclass:Fsys_xxxcorr_err_coverage

///////////////////////////////////////////////////////////////////////////////////
//  ###### #    # #    #  ####  ##### #  ####  #    #  ####  
//  #      #    # ##   # #    #   #   # #    # ##   # #      
//  #####  #    # # #  # #        #   # #    # # #  #  ####  
//  #      #    # #  # # #        #   # #    # #  # #      # 
//  #      #    # #   ## #    #   #   # #    # #   ## #    # 
//  #       ####  #    #  ####    #   #  ####  #    #  ####  
//////////////////////////////////////////////////////////////////////////////////
// Collect CSR value each native or smi txn                                                            
<%for(pidx = 0; pidx < nALLs; pidx++) { %>
     <%  if(_child_blk[pidx].match('chiaiu') || _child_blk[pidx].match('dce')|| _child_blk[pidx].match('dmi')) { %>
function void Fsys_xxxcorr_err_coverage::collect_item_<%=_child_blkid[pidx]%>();   // each smi & native_itf req check the status of credit
     if (!csr_init_done) begin 
        return; // do nothing if boot_seq isn't done
     end
       if(vif.<%=_child_blkid[pidx]%>_uncorr_errvld[0]) begin
        <%if (_child_blk[pidx].match('dce')) { %>
       dce_uncorr_errtype=vif.<%=_child_blkid[pidx]%>_uncorr_errtype[0];
       dce_uncorr_errinfo=vif.<%=_child_blkid[pidx]%>_uncorr_errinfo[0];
        <%} else if (_child_blk[pidx].match('dmi')) { %>
       dmi_uncorr_errtype=vif.<%=_child_blkid[pidx]%>_uncorr_errtype[0];
       dmi_uncorr_errinfo=vif.<%=_child_blkid[pidx]%>_uncorr_errinfo[0];
       <%} else { %>
       chi_uncorr_errtype=vif.<%=_child_blkid[pidx]%>_uncorr_errtype[0];
       chi_uncorr_errinfo=vif.<%=_child_blkid[pidx]%>_uncorr_errinfo[0];
       <%}%>
       cg_uncorr_err.sample();
       end
endfunction:collect_item_<%=_child_blkid[pidx]%>
    <% } // chi%>
<%  if(_child_blk[pidx].match('ioaiu')) { %>
   <%for (var c=0; c <_child_blk_nCore[pidx];c++)  {%>
function void Fsys_xxxcorr_err_coverage::collect_item_<%=_child_blkid[pidx]%>_core<%=c%>();   // each smi & native_itf req check the status of credit
     if (!csr_init_done) return; // do nothing if boot_seq isn't done
       <% if (_child_nativetype[pidx].match('fullace')) {%>
         if(vif.<%=_child_blkid[pidx]%>_uncorr_errvld[<%=c%>]) begin
            ioaiu_uncorr_errtype=vif.<%=_child_blkid[pidx]%>_uncorr_errtype[<%=c%>];
            ioaiu_uncorr_errinfo=vif.<%=_child_blkid[pidx]%>_uncorr_errinfo[<%=c%>];
            cg_uncorr_err.sample();
         end
       <% } //fullace%>
       <% if (_child_nativetype[pidx].match('ace-lite') || _child_nativetype[pidx].match('ace-lite-e')  ) {%>
         if(vif.<%=_child_blkid[pidx]%>_uncorr_errvld[<%=c%>]) begin
            ioaiu_uncorr_errtype=vif.<%=_child_blkid[pidx]%>_uncorr_errtype[<%=c%>];
            ioaiu_uncorr_errinfo=vif.<%=_child_blkid[pidx]%>_uncorr_errinfo[<%=c%>];
            cg_uncorr_err.sample();
         end
       <% } //acelite%>
       <% if (_child_nativetype[pidx].match('axi4')) {%>
          if(vif.<%=_child_blkid[pidx]%>_uncorr_errvld[<%=c%>]) begin
          ioaiu_uncorr_errtype=vif.<%=_child_blkid[pidx]%>_uncorr_errtype[<%=c%>];
          ioaiu_uncorr_errinfo=vif.<%=_child_blkid[pidx]%>_uncorr_errinfo[<%=c%>];
          cg_uncorr_err.sample();
       end                                                                  
       <% } //axi4%>
endfunction:collect_item_<%=_child_blkid[pidx]%>_core<%=c%>
    <% } // each core%>
    <% } // if ioaiu%>
<% } //nALLS%>
