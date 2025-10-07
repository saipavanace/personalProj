////////////////////////////////////////////////////////////////////////////////
//
// Fsys_smi_coverage_atomic 
// Author: Cyrille LUDWIG
//
////////////////////////////////////////////////////////////////////////////////
<%
//Embedded javascript code to figure number of blocks
   var _child_blkid = [];
   var _child_blk   = [];
   var _child   = [{}];
   var pidx = 0;
   var dmi_useAtomic =0;
   var qidx = 0;
   var idx  = 0;
   var ridx = 0;
   var initiatorAgents = obj.AiuInfo.length ;
   var numChiAiu         = 0;
   var numIoAiu          = 0;
   var numAce     = 0;
   var numAceLite     = 0;
   var numAceLiteE     = 0;
   var numAxi5_Axi4_with_cache     = 0;
   var num_AXI5_atomic = 0;
   var num_AXI5_AXI4= 0;
   let computedAxiInt;

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
       if((obj.AiuInfo[pidx].fnNativeInterface == 'AXI4' && obj.AiuInfo[pidx].useCache) || (obj.AiuInfo[pidx].fnNativeInterface == 'AXI5' && obj.AiuInfo[pidx].useCache)) { numAxi5_Axi4_with_cache++; }
       if((obj.AiuInfo[pidx].fnNativeInterface == 'AXI4') || (obj.AiuInfo[pidx].fnNativeInterface == 'AXI5')) { 
           num_AXI5_AXI4++; 
           if(Array.isArray(obj.AiuInfo[pidx].interfaces.axiInt)){
               computedAxiInt = obj.AiuInfo[pidx].interfaces.axiInt[0];
           }else{
               computedAxiInt = obj.AiuInfo[pidx].interfaces.axiInt;
           }
           if(obj.AiuInfo[pidx].fnNativeInterface.match("AXI5") && (computedAxiInt.params.atomicTransactions==true)) {
               num_AXI5_atomic = num_AXI5_atomic + 1;
           }
       }

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
       if (obj.DmiInfo[pidx].useAtomic) { dmi_useAtomic=1; }
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

class Fsys_smi_coverage_atomic;
                                                        
/////////////////////////////////////////////////////////////////////////////////////
//     ##   ##### ##### #####  # #####  #    # #####  ####  
//    #  #    #     #   #    # # #    # #    #   #   #      
//   #    #   #     #   #    # # #####  #    #   #    ####  
//   ######   #     #   #####  # #    # #    #   #        # 
//   #    #   #     #   #   #  # #    # #    #   #   #    # 
//   #    #   #     #   #    # # #####   ####    #    ####  
/////////////////////////////////////////////////////////////////////////////////////
                                                          
    // AIUs to DCE/DMI/DII field
    smi_mpf1_argv_t chi_cmd_req_atomic_argv;
    smi_mpf1_argv_t ace_xxx_cmd_req_atomic_argv;
    smi_ch_t chi_cmd_req_atomic_coh;
    smi_ch_t ace_xxx_cmd_req_atomic_coh;
    eMsgCMD chi_cmd_req_type;  
    eMsgCMD ioaiu_cmd_req_type;  
  <% if (num_AXI5_atomic) {%>
    smi_mpf1_argv_t axiWithAtomic_cmd_req_atomic_argv;
    smi_ch_t axiWithAtomic_cmd_req_atomic_coh;
    eMsgCMD ioaiu_axiWithAtomic_cmd_req_type;  
  <% } %>


///////////////////////////////////////////////////////////////////////////////////
// ####   ####  #    # ###### #####   ####  #####   ####  #    # #####   ####  
//#    # #    # #    # #      #    # #    # #    # #    # #    # #    # #      
//#      #    # #    # #####  #    # #      #    # #    # #    # #    #  ####  
//#      #    # #    # #      #####  #  ### #####  #    # #    # #####       # 
//#    # #    #  #  #  #      #   #  #    # #   #  #    # #    # #      #    # 
// ####   ####    ##   ###### #    #  ####  #    #  ####   ####  #       ####  
///////////////////////////////////////////////////////////////////////////////////
// AIUs Commun covergroup 
   <%if (dmi_useAtomic)  {%> 
    covergroup cg_smi_atomic;

        <% if (numChiAiu>0) {%>
        //#Cover.FSYS.Chi.cmdreq.atomic
        CovChiCmdReqAtomicCoh:     coverpoint chi_cmd_req_atomic_coh;  
        CovChiCmdReqAtomicArgv:     coverpoint chi_cmd_req_atomic_argv{
                                                    ignore_bins invalid_bins[] = {[8:63]}; 
                                                } 
        ChiCovCmdReqAtomic:   coverpoint chi_cmd_req_type {
                                          bins WR_ATOMIC = {eCmdWrAtm};
                                          bins RD_ATOMIC = {eCmdRdAtm};
                                          bins SWAP_ATOMIC = {eCmdSwAtm};
                                          bins COMP_ATOMIC = {eCmdCompAtm};
                                        }
        CrossChiAtomic: cross ChiCovCmdReqAtomic,CovChiCmdReqAtomicArgv,CovChiCmdReqAtomicCoh {
                                        ignore_bins InvCrossAtmSw   = !binsof(CovChiCmdReqAtomicArgv) intersect {0} && binsof(ChiCovCmdReqAtomic.SWAP_ATOMIC);
                                        ignore_bins InvCrossAtmComp = !binsof(CovChiCmdReqAtomicArgv) intersect {1} && binsof(ChiCovCmdReqAtomic.COMP_ATOMIC);
                                        }
        <% } %>
        <% if (numAce || numAceLiteE ||num_AXI5_atomic) {%>
        //#Cover.FSYS.IO.cmdreq.atomic
        CovIoCmdReqAtomicCoh:     coverpoint ace_xxx_cmd_req_atomic_coh;  
        CovIoCmdReqAtomicArgv:    coverpoint ace_xxx_cmd_req_atomic_argv{
                                                    ignore_bins NonAtm = {0}; // CCMP Spec Table E1-2 AWATOP encodings
                                                    bins AtmSt[] = {[6'b01_0000:6'b01_0111]}; // CCMP Spec Table E1-2 AWATOP encodings
                                                    bins AtmLd[] = {[6'b10_0000:6'b10_0111]}; // CCMP Spec Table E1-2 AWATOP encodings
                                                    bins AtmSwp = {6'b11_0000}; // CCMP Spec Table E1-2 AWATOP encodings
                                                    bins AtmComp = {6'b11_0001}; // CCMP Spec Table E1-2 AWATOP encodings
                                                } 

        IoCovCmdReqAtomic:   coverpoint ioaiu_cmd_req_type {
                                          bins RD_ATOMIC = {eCmdRdAtm};
                                          bins WR_ATOMIC = {eCmdWrAtm};
                                          bins SWAP_ATOMIC = {eCmdSwAtm};
                                          bins COMP_ATOMIC = {eCmdCompAtm};
                                        }
        CrossIoAtomic: cross IoCovCmdReqAtomic,CovIoCmdReqAtomicArgv,CovIoCmdReqAtomicCoh {
                                          ignore_bins InvCrossAtmWr   = !binsof(CovIoCmdReqAtomicArgv.AtmSt) && binsof(IoCovCmdReqAtomic.WR_ATOMIC);
                                          ignore_bins InvCrossAtmRd   = !binsof(CovIoCmdReqAtomicArgv.AtmLd) && binsof(IoCovCmdReqAtomic.RD_ATOMIC);
                                          ignore_bins InvCrossAtmSw   = !binsof(CovIoCmdReqAtomicArgv.AtmSwp)  && binsof(IoCovCmdReqAtomic.SWAP_ATOMIC) ;
                                          ignore_bins InvCrossAtmComp = !binsof(CovIoCmdReqAtomicArgv.AtmComp) && binsof(IoCovCmdReqAtomic.COMP_ATOMIC) ;
                                        }
        <% } %>
        <% if (num_AXI5_atomic) {%>
        // #Cover.FSYS.v371.amba5_axi5_owo_txns_smi
        CovIo_axiWithAtomic_CmdReqAtomicCoh:     coverpoint axiWithAtomic_cmd_req_atomic_coh;  
        CovIo_axiWithAtomic_CmdReqAtomicArgv:    coverpoint axiWithAtomic_cmd_req_atomic_argv{
                                                    ignore_bins NonAtm = {0}; // CCMP Spec Table E1-2 AWATOP encodings
                                                    bins AtmSt[] = {[6'b01_0000:6'b01_0111]}; // CCMP Spec Table E1-2 AWATOP encodings
                                                    bins AtmLd[] = {[6'b10_0000:6'b10_0111]}; // CCMP Spec Table E1-2 AWATOP encodings
                                                    bins AtmSwp = {6'b11_0000}; // CCMP Spec Table E1-2 AWATOP encodings
                                                    bins AtmComp = {6'b11_0001}; // CCMP Spec Table E1-2 AWATOP encodings
                                                } 

        Io_axiWithAtomic_CovCmdReqAtomic:   coverpoint ioaiu_axiWithAtomic_cmd_req_type{
                                          bins RD_ATOMIC = {eCmdRdAtm};
                                          bins WR_ATOMIC = {eCmdWrAtm};
                                          bins SWAP_ATOMIC = {eCmdSwAtm};
                                          bins COMP_ATOMIC = {eCmdCompAtm};
                                        }
        CrossIo_axiWithAtomic_Atomic: cross Io_axiWithAtomic_CovCmdReqAtomic,CovIo_axiWithAtomic_CmdReqAtomicArgv,CovIo_axiWithAtomic_CmdReqAtomicCoh{
                                          ignore_bins InvCrossAtmWr   = !binsof(CovIo_axiWithAtomic_CmdReqAtomicArgv.AtmSt) && binsof(Io_axiWithAtomic_CovCmdReqAtomic.WR_ATOMIC);
                                          ignore_bins InvCrossAtmRd   = !binsof(CovIo_axiWithAtomic_CmdReqAtomicArgv.AtmLd) && binsof(Io_axiWithAtomic_CovCmdReqAtomic.RD_ATOMIC);
                                          ignore_bins InvCrossAtmSw   = !binsof(CovIo_axiWithAtomic_CmdReqAtomicArgv.AtmSwp)  && binsof(Io_axiWithAtomic_CovCmdReqAtomic.SWAP_ATOMIC) ;
                                          ignore_bins InvCrossAtmComp = !binsof(CovIo_axiWithAtomic_CmdReqAtomicArgv.AtmComp) && binsof(Io_axiWithAtomic_CovCmdReqAtomic.COMP_ATOMIC) ;
                                        }

        <% } %>
    endgroup
<%} // dmi_useAtomic%>
    
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
   <%if (dmi_useAtomic)  {%> 
       cg_smi_atomic = new();
    <%}%>
    endfunction:new

    // ALL FUNCTIONS
<%for(pidx = 0; pidx < obj.nAIUs; pidx++) { %>  
    extern function void collect_item_<%=_child_blkid[pidx]%>(<%=_child_blkid[pidx]%>_smi_agent_pkg::smi_seq_item m_pkt);
<%}%>
endclass:Fsys_smi_coverage_atomic

///////////////////////////////////////////////////////////////////////////////////
//  ###### #    # #    #  ####  ##### #  ####  #    #  ####  
//  #      #    # ##   # #    #   #   # #    # ##   # #      
//  #####  #    # # #  # #        #   # #    # # #  #  ####  
//  #      #    # #  # # #        #   # #    # #  # #      # 
//  #      #    # #   ## #    #   #   # #    # #   ## #    # 
//  #       ####  #    #  ####    #   #  ####  #    #  ####  
//////////////////////////////////////////////////////////////////////////////////                                                           
<%for(pidx = 0; pidx < obj.nAIUs; pidx++) { %>
function void Fsys_smi_coverage_atomic::collect_item_<%=_child_blkid[pidx]%>(<%=_child_blkid[pidx]%>_smi_agent_pkg::smi_seq_item m_pkt);
    if (m_pkt) begin
        <%  if(_child_blk[pidx].match('chiaiu')) { %>
        case (ncoreConfigInfo::get_unit_type(m_pkt.smi_src_ncore_unit_id))
            ncoreConfigInfo::AIU: begin
                               if (m_pkt.smi_conc_msg_class == eConcMsgCmdReq) begin
                                                        chi_cmd_req_type =eMsgCMD'(m_pkt.smi_msg_type);
                                                       <%if (dmi_useAtomic)  {%> 
                                                        if (chi_cmd_req_type inside {eCmdWrAtm,eCmdRdAtm,eCmdSwAtm,eCmdCompAtm}) begin
                                                            chi_cmd_req_atomic_coh = m_pkt.smi_ch;
                                                            chi_cmd_req_atomic_argv = m_pkt.smi_mpf1_argv;
                                                            cg_smi_atomic.sample();
                                                        end
                                                        <%} //dmi_useAtomic%>
                               end
                               end
        endcase
        <%}%>
        <%  if(_child_blk[pidx].match('ioaiu')) { %>
        case (ncoreConfigInfo::get_unit_type(m_pkt.smi_src_ncore_unit_id))
            ncoreConfigInfo::AIU: begin
                               if (m_pkt.smi_conc_msg_class == eConcMsgCmdReq) begin
                                                      ioaiu_cmd_req_type =eMsgCMD'(m_pkt.smi_msg_type);
                                                       <%if (dmi_useAtomic)  {%> 
                                                      if (ioaiu_cmd_req_type inside {eCmdWrAtm,eCmdRdAtm,eCmdSwAtm,eCmdCompAtm}) begin
                                                            ace_xxx_cmd_req_atomic_coh = m_pkt.smi_ch;
                                                            ace_xxx_cmd_req_atomic_argv = m_pkt.smi_mpf1_argv;
                                                            cg_smi_atomic.sample();
                                                      end
                                                      <% if(Array.isArray(_child[pidx].interfaces.axiInt)){
                                                          computedAxiInt = _child[pidx].interfaces.axiInt[0];
                                                      }else{
                                                          computedAxiInt = _child[pidx].interfaces.axiInt;
                                                      } %>

                                                       <% if (_child[pidx].fnNativeInterface.match("AXI5") && (computedAxiInt.params.atomicTransactions==true)) {%>
                                                      ioaiu_axiWithAtomic_cmd_req_type=eMsgCMD'(m_pkt.smi_msg_type);
                                                      if (ioaiu_axiWithAtomic_cmd_req_type inside {eCmdWrAtm,eCmdRdAtm,eCmdSwAtm,eCmdCompAtm}) begin
                                                            axiWithAtomic_cmd_req_atomic_coh = m_pkt.smi_ch;
                                                            axiWithAtomic_cmd_req_atomic_argv = m_pkt.smi_mpf1_argv;
                                                            cg_smi_atomic.sample();
                                                      end
                                                       <% } %>
                                                      <% }%>
                               end
                               end
        endcase
        <%}%>
    end
endfunction:collect_item_<%=_child_blkid[pidx]%>
<% }%>
