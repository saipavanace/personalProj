////////////////////////////////////////////////////////////////////////////////
//
// fsys_smi_coverage 
// Author: Cyrille LUDWIG
//
////////////////////////////////////////////////////////////////////////////////
<%
//Embedded javascript code to figure number of blocks
   var _child_blkid = [];
   var _child_blk   = [];
   var _child   = [{}];
   var pidx = 0;
   var useAtomic =0;
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
   var dmiqosenable = 1;
   var dmismc = 0;

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
       if (!obj.DmiInfo[pidx].fnEnableQos) { dmiqosenable = 0;}
       if (!dmismc) { dmismc = obj.DmiInfo[pidx].useCmc;}       
       if (obj.DmiInfo[pidx].useAtomic) { useAtomic=1; }
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

class Fsys_dmi_coverage extends Fsys_base_coverage;
                                                        
/////////////////////////////////////////////////////////////////////////////////////
//     ##   ##### ##### #####  # #####  #    # #####  ####  
//    #  #    #     #   #    # # #    # #    #   #   #      
//   #    #   #     #   #    # # #####  #    #   #    ####  
//   ######   #     #   #####  # #    # #    #   #        # 
//   #    #   #     #   #   #  # #    # #    #   #   #    # 
//   #    #   #     #   #    # # #####   ####    #    ####  
/////////////////////////////////////////////////////////////////////////////////////
// at least one time the event below:   
   bit dmi_full_rtt;
   bit dmi_full_wtt;
   bit dmi_full_nc_wr_buf;
   bit dmi_full_c_wr_buf ;
   bit dmi_threshold_reached_rtt;
   bit dmi_threshold_reached_wtt;
   bit dmi_threshold_reached_nc_wr_buf;
   //NKR - Signal removed from Ncore3.6
   //bit dmi_threshold_reached_c_wr_buf; 
   bit dmi_smc_allocactive;
   bit dmi_smc_evictactive;                                                

///////////////////////////////////////////////////////////////////////////////////
// ####   ####  #    # ###### #####   ####  #####   ####  #    # #####   ####  
//#    # #    # #    # #      #    # #    # #    # #    # #    # #    # #      
//#      #    # #    # #####  #    # #      #    # #    # #    # #    #  ####  
//#      #    # #    # #      #####  #  ### #####  #    # #    # #####       # 
//#    # #    #  #  #  #      #   #  #    # #   #  #    # #    # #      #    # 
// ####   ####    ##   ###### #    #  ####  #    #  ####   ####  #       ####  
///////////////////////////////////////////////////////////////////////////////////
// AIUs Commun covergroup 
   covergroup cg_dmi;
<% if(dmiqosenable) { %>
    coverpoint dmi_full_rtt;
    coverpoint dmi_full_wtt;
    coverpoint dmi_full_nc_wr_buf;
    coverpoint dmi_full_c_wr_buf ;
    coverpoint dmi_threshold_reached_rtt;
    coverpoint dmi_threshold_reached_wtt;
    coverpoint dmi_threshold_reached_nc_wr_buf;
    //NKR - Signal removed from Ncore3.6
    //coverpoint dmi_threshold_reached_c_wr_buf;   
<%}%>
<% if(dmismc) { %>
    coverpoint dmi_smc_allocactive;
    coverpoint dmi_smc_evictactive;                                                
<%}%>
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
       //covergroup
<% if(dmiqosenable || dmismc) { %>
       cg_dmi = new();
<%}%>
    endfunction:new

    // ALL FUNCTIONS
<%for(pidx = 0; pidx < obj.nDMIs; pidx++) { %>  
    extern function void collect_item_dmi<%=pidx%>();
<%}%>
endclass:Fsys_dmi_coverage

///////////////////////////////////////////////////////////////////////////////////
//  ###### #    # #    #  ####  ##### #  ####  #    #  ####  
//  #      #    # ##   # #    #   #   # #    # ##   # #      
//  #####  #    # # #  # #        #   # #    # # #  #  ####  
//  #      #    # #  # # #        #   # #    # #  # #      # 
//  #      #    # #   ## #    #   #   # #    # #   ## #    # 
//  #       ####  #    #  ####    #   #  ####  #    #  ####  
//////////////////////////////////////////////////////////////////////////////////
                                                            
<%for(pidx = 0; pidx < obj.nDMIs; pidx++) { %>
function void Fsys_dmi_coverage::collect_item_dmi<%=pidx%>();
     if (!csr_init_done) return; // do nothing if boot_seq isn't done
    <% if(dmiqosenable) { %>
    //#Cover.FSYS.RTT.full
    //#Cover.FSYS.WTT.full
    //#Cover.FSYS.databuffer.full
     dmi_full_rtt                   = vif.dmi<%=pidx%>_full_rtt;
     dmi_full_wtt                   = vif.dmi<%=pidx%>_full_wtt;
     dmi_full_nc_wr_buf             = vif.dmi<%=pidx%>_full_nc_wr_buf;
     dmi_full_c_wr_buf              = vif.dmi<%=pidx%>_full_c_wr_buf ;
     //#Cover.FSYS.RTT.threshold_reach
     //#Cover.FSYS.WTT.threshold_reach
    //#Cover.FSYS.databuffer.threshold_reach
     dmi_threshold_reached_rtt      = vif.dmi<%=pidx%>_threshold_reached_rtt;
     dmi_threshold_reached_wtt      = vif.dmi<%=pidx%>_threshold_reached_wtt;
     dmi_threshold_reached_nc_wr_buf= vif.dmi<%=pidx%>_threshold_reached_nc_wr_buf;
     //NKR - Signal removed from Ncore3.6
     //dmi_threshold_reached_c_wr_buf = vif.dmi<%=pidx%>_threshold_reached_c_wr_buf;
    <%}%>
    <% if(dmismc) { %>
    //#Cover.FSYS.SMC.AllocActive
    //#Cover.FSYS.SMC.EvictActive
      dmi_smc_allocactive = vif.dmi<%=pidx%>_smc_allocactive;
      dmi_smc_evictactive = vif.dmi<%=pidx%>_smc_evictactive;;   
    <%}%>
<% if(dmiqosenable || dmismc) { %>
     cg_dmi.sample();
    <%}%>
endfunction:collect_item_dmi<%=pidx%>
<%}%>
