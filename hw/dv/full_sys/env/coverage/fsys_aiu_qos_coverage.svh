////////////////////////////////////////////////////////////////////////////////
//
// fsys_aiu_qos_coverage 
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
   var ioaiuqosenable = 1;
   var chiqosenable = 1;

   for(pidx = 0; pidx < obj.nAIUs; pidx++) {
       if((obj.AiuInfo[pidx].fnNativeInterface == 'CHI-A')||(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-B')||(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-E')) {
       _child_blkid[pidx] = 'chiaiu' + idx;
       _child_blk[pidx]   = 'chiaiu';
       _child_blk_nCore[pidx] = 1;
       numChiAiu = numChiAiu + 1;
       idx++;
       if ( ! obj.AiuInfo[pidx].fnEnableQos) { chiqosenable = 0;}
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
       if ( ! obj.AiuInfo[pidx].fnEnableQos) { ioaiuqosenable = 0;}
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
       if ( ! obj.DmiInfo[pidx].fnEnableQos) { dmiqosenable = 0;}
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

class Fsys_aiu_qos_coverage extends Fsys_base_coverage;
                                                        
/////////////////////////////////////////////////////////////////////////////////////
//     ##   ##### ##### #####  # #####  #    # #####  ####  
//    #  #    #     #   #    # # #    # #    #   #   #      
//   #    #   #     #   #    # # #####  #    #   #    ####  
//   ######   #     #   #####  # #    # #    #   #        # 
//   #    #   #     #   #   #  # #    # #    #   #   #    # 
//   #    #   #     #   #    # # #####   ####    #    ####  
/////////////////////////////////////////////////////////////////////////////////////
// at least one time the event below:  
    bit ioaiu_qos_eventstatus;
    bit ioaiu_qos_eventstatuscount;
    //unreachable from FSYS point of view needs more than 33 000 txns// bit ioaiu_qos_eventstatuscountoverflow;
    bit chiaiu_qos_eventstatus;
    bit chiaiu_qos_eventstatuscount;
    //unreachable from FSYS point of view needs more than 33 000 txns// bit chiaiu_qos_eventstatuscountoverflow;
    bit ioaiu_pc_allocactive;
    bit ioaiu_pc_evictactive;   
///////////////////////////////////////////////////////////////////////////////////
// ####   ####  #    # ###### #####   ####  #####   ####  #    # #####   ####  
//#    # #    # #    # #      #    # #    # #    # #    # #    # #    # #      
//#      #    # #    # #####  #    # #      #    # #    # #    # #    #  ####  
//#      #    # #    # #      #####  #  ### #####  #    # #    # #####       # 
//#    # #    #  #  #  #      #   #  #    # #   #  #    # #    # #      #    # 
// ####   ####    ##   ###### #    #  ####  #    #  ####   ####  #       ####  
///////////////////////////////////////////////////////////////////////////////////
// AIUs Commun covergroup 
   covergroup cg_aiu_qos;
    <% if (numIoAiu && ioaiuqosenable) {%>
    coverpoint ioaiu_qos_eventstatus;             
    coverpoint ioaiu_qos_eventstatuscount;    
    // coverpoint ioaiu_qos_eventstatuscountoverflow; // unreachable from FSYS point of view needs more than 33 000 txns
    <%}%>
    <% if (numChiAiu && chiqosenable) {%>
    coverpoint chiaiu_qos_eventstatus;             
    coverpoint chiaiu_qos_eventstatuscount;        
    <%}%>
    <% if (numAxi4_with_cache) {%>
    coverpoint ioaiu_pc_allocactive;
    coverpoint ioaiu_pc_evictactive;
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
    <% if (ioaiuqosenable ||chiqosenable ) {%>
       cg_aiu_qos = new();
    <%}%>
    endfunction:new

    // ALL FUNCTIONS

<%for(pidx = 0; pidx < nAIUs; pidx++) { %>  
    <% if (_child_blk[pidx].match('aiu')) { %>
        <%for (var c=0; c <_child_blk_nCore[pidx];c++)  {%>
    extern function void collect_item_<%=_child_blkid[pidx]%>_core<%=c%>();
     <%} //foreach core%>
<%}//foreach IOAIU%>
<%} //for ALLs%>
endclass:Fsys_aiu_qos_coverage

///////////////////////////////////////////////////////////////////////////////////
//  ###### #    # #    #  ####  ##### #  ####  #    #  ####  
//  #      #    # ##   # #    #   #   # #    # ##   # #      
//  #####  #    # # #  # #        #   # #    # # #  #  ####  
//  #      #    # #  # # #        #   # #    # #  # #      # 
//  #      #    # #   ## #    #   #   # #    # #   ## #    # 
//  #       ####  #    #  ####    #   #  ####  #    #  ####  
/////////////////////////////////////////////////////////////////////////////////
                                                            
<%for(pidx = 0; pidx < nAIUs; pidx++) { %>  
    <% if (_child_blk[pidx].match('aiu')) { %>
        <%for (var c=0; c < _child_blk_nCore[pidx];c++)  {%>
function void Fsys_aiu_qos_coverage::collect_item_<%=_child_blkid[pidx]%>_core<%=c%>();
     if (!csr_init_done) return; // do nothing if boot_seq isn't done
     //#Cover.FSYS.QOSSR.EventStatus.atleastOne
     //#Cover.FSYS.QOSSR.EventStatusCount.atleastone
     //#Cover.FSYS.QOSSR.EventStatusCountOverflow.atleastone
    <% if ( (ioaiuqosenable && _child_blk[pidx].match('ioaiu')) || 
            (chiqosenable   && _child_blk[pidx].match('chiaiu'))      ) {%>
    <%=_child_blk[pidx]%>_qos_eventstatus               = vif.<%=_child_blkid[pidx]%>_qos_eventstatus[<%=c%>];                    
    <%=_child_blk[pidx]%>_qos_eventstatuscount          = vif.<%=_child_blkid[pidx]%>_qos_eventstatuscount[<%=c%>];
//    <%_child_blk[pidx]%>_qos_eventstatuscountoverflow  = vif.<%=_child_blkid[pidx]%>_qos_eventstatuscountoverflow[<%=c%>];
     <%if(_child[pidx].fnNativeInterface == 'AXI4' && _child[pidx].useCache) {%>
       //#Cover.FSYS.PC.AllocActive
       //#Cover.FSYS.PC.EvictActive
        ioaiu_pc_allocactive       = vif.<%=_child_blkid[pidx]%>_pc_allocactive[<%=c%>];                    
        ioaiu_pc_evictactive       = vif.<%=_child_blkid[pidx]%>_pc_evictactive[<%=c%>];                    
     <%} //if use cache%>
     cg_aiu_qos.sample();
    <%}%>
endfunction:collect_item_<%=_child_blkid[pidx]%>_core<%=c%>
     <%} //foreach core%>
<%}//foreach IOAIU%>
<%} //for ALLs%>
