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
   var dmi_useAtomic =1;
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
   var num_AXI5_with_owo = 0;
   var numAceLite_with_owo = 0;
   var numAce5Lite_with_owo = 0;
   var num_AXI5_AXI4 = 0;
   var num_AXI5_atomic = 0;
   let computedAxiInt;

   for(pidx = 0; pidx < obj.nAIUs; pidx++) {
       if((obj.AiuInfo[pidx].fnNativeInterface == 'CHI-A')||(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-B' || obj.AiuInfo[pidx].fnNativeInterface == 'CHI-E')) {
       _child_blkid[pidx] = 'chiaiu' + idx;
       _child_blk[pidx]   = 'chiaiu';
       numChiAiu = numChiAiu + 1;
       idx++;
       } else {
       if(obj.AiuInfo[pidx].fnNativeInterface == 'ACE5' ||obj.AiuInfo[pidx].fnNativeInterface == 'ACE') { numAce++; }
       if(obj.AiuInfo[pidx].fnNativeInterface == 'ACE-LITE') { 
           numAceLite++; 
           if(obj.AiuInfo[pidx].orderedWriteObservation==true) { 
               numAceLite_with_owo = numAceLite_with_owo + 1;
           }
       }
       if(obj.AiuInfo[pidx].fnNativeInterface == 'ACELITE-E') { 
           numAceLiteE++; 
           if(obj.AiuInfo[pidx].orderedWriteObservation==true) { 
               numAce5Lite_with_owo = numAce5Lite_with_owo + 1;
           }
       }
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
           if(obj.AiuInfo[pidx].orderedWriteObservation==true) { 
               num_AXI5_with_owo = num_AXI5_with_owo + 1;
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
       if (obj.DmiInfo[pidx].useAtomic) { dmi_useAtomic=1; } // currently, if one DMI don't use atomic we don't run atomic stimulus 
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

class Fsys_smi_coverage;
                                                        
/////////////////////////////////////////////////////////////////////////////////////
//     ##   ##### ##### #####  # #####  #    # #####  ####  
//    #  #    #     #   #    # # #    # #    #   #   #      
//   #    #   #     #   #    # # #####  #    #   #    ####  
//   ######   #     #   #####  # #    # #    #   #        # 
//   #    #   #     #   #   #  # #    # #    #   #   #    # 
//   #    #   #     #   #    # # #####   ####    #    ####  
/////////////////////////////////////////////////////////////////////////////////////
                                                          
    // AIUs to DCE/DMI/DII field
    eMsgCMD chi_cmd_req_type;  
    eMsgCMD ioaiu_cmd_req_type;  
    eMsgCMD ioaiu_owo_axi_cmd_req_type;  
    eMsgCMD ioaiu_owo_AceLite_cmd_req_type;  
    eMsgCMD ioaiu_owo_Ace5Lite_cmd_req_type;  
    eMsgCMD ioaiu_dii_cmd_req_type;
    eMsgCMD chi_dii_cmd_req_type;
    smi_ncore_unit_id_bit_t aiu_smi_req_src_id;
    smi_ncore_unit_id_bit_t aiu_smi_req_trgt_id;
    smi_ncore_unit_id_bit_t dce_smi_req_src_id;
    smi_ncore_unit_id_bit_t dce_smi_req_trgt_id;
    smi_ncore_unit_id_bit_t dmi_smi_req_src_id;
    smi_ncore_unit_id_bit_t dmi_smi_req_trgt_id;
    smi_ncore_unit_id_bit_t dii_smi_req_src_id;
    smi_ncore_unit_id_bit_t dii_smi_req_trgt_id;
    smi_ncore_unit_id_bit_t dve_smi_req_src_id;
    smi_ncore_unit_id_bit_t dve_smi_req_trgt_id;
    // DMI/DII to AIUs field
    eMsgDTR dmi_dtr_req_chi_type;
    eMsgDTR dmi_dtr_req_ioaiu_type;
    eMsgDTR dii_dtr_req_chi_type;
    eMsgDTR dii_dtr_req_ioaiu_type;
    // AIUs to DMI/DII field
    eMsgDTW chi_dtw_req_dmi_type;
    eMsgDTW chi_dtw_req_dii_type;
    eMsgDTW ioaiu_dtw_req_dmi_type;
    eMsgDTW ioaiu_dtw_req_dii_type;
    eMsgDTWMrgMRD chi_dtwmrg_req_dmi_type;
    eMsgDTWMrgMRD ioaiu_dtwmrg_req_dmi_type;
    // AIUs to AIUs field
    eMsgDTR aiu_dtr_req_chi_type;
    eMsgDTR aiu_dtr_req_ioaiu_type;
    // AIUs to DCE field
    eMsgUPD ioaiu_upd_req_type;
    eMsgUPD ioaiu_upd_axi5_axi4pc_req_type;
    //DCE to DMI field
    eMsgMRD dce_mrd_req_type;
    //DCE to AIU field
    eMsgSNP dce_snp_req_chi_type; 
    eMsgSNP dce_snp_req_ioaiu_type; 
    <% if (num_AXI5_with_owo>0) {%>
    eMsgSNP dce_snp_req_ioaiu_owo_axi_type; 
    <% } %>
    <% if (numAceLite_with_owo>0) {%>
    eMsgSNP dce_snp_req_ioaiu_owo_AceLite_type; 
    <% } %>

    eMsgSNP dce_snp_req_ace_type; 
    eMsgSNP dce_snp_req_axi5_axi4PC_type; 
    //DCE to DMI field
    eMsgRBReq dce_rbr_req_type;
    // sharer promotion
    smi_up_enum_t dce_smi_snp_up;
    smi_up_enum_t chi_smi_snp_up;
    smi_up_enum_t ace_smi_snp_up;
    smi_up_enum_t ncaiu_with_cache_smi_snp_up;
    // DCE sending SysReq
    //eMsgSysReq DCE_sends_sysreq_event;
    bit        DCE_sends_sysreq_event_bit; // To avoid false hits
    // DMI sending SysReq
    //eMsgSysReq DMI_sends_sysreq_event;
    bit        DMI_sends_sysreq_event_bit; // To avoid false hits
    // DII sending SysReq
    //eMsgSysReq DII_sends_sysreq_event;
    bit        DII_sends_sysreq_event_bit; // To avoid false hits
    //eMsgSysReq DVE_sends_sysreq_event;
    bit        DVE_sends_sysreq_event_bit; // To avoid false hits
    //eMsgSysRsp chiaiu_sends_sysreq_event;
    bit        DVE_sends_sysrsp_event_bit; // To avoid false hits
    //eMsgSysReq chiaiu_sends_sysreq_event;
    bit        chiaiu_sends_sysreq_event_bit; // To avoid false hits
    //eMsgSysReq ioaiu_sends_sysreq_event;
    bit        ioaiu_sends_sysreq_event_bit; // To avoid false hits
     <% if (num_AXI5_with_owo>0) {%>
    bit        ioaiu_owo_axi_sends_sysreq_event_bit; // To avoid false hits
     <% } %>

     <% if (numAceLite_with_owo>0) {%>
    bit        ioaiu_owo_AceLite_sends_sysreq_event_bit; // To avoid false hits
     <% } %>
    // AIU sending SysReq
    //eMsgSysRsp chiaiu_sends_sysrsp;
    //eMsgSysRsp ioaiu_sends_sysrsp;
    bit chiaiu_sends_sysrsp_bit; //  To avoid false hits
    bit ioaiu_sends_sysrsp_bit; //  To avoid false hits

<% if ((numAceLiteE && numChiAiu) || (numChiAiu>=2)) { // mini: 1 ACELITE-E+1CHI or 2 CHI%>
    // Begin_Stash
    <%for(pidx = 0; pidx < obj.nAIUs; pidx++) { %>  
        <%if(obj.AiuInfo[pidx].fnNativeInterface == 'ACELITE-E' || _child_blkid[pidx].match("chiaiu")) {%>
        <%if (_child_blkid[pidx].match("chiaiu")) {%> 
           eMsgSNP <%=_child_blkid[pidx]%>_stash_snp_req_type; 
           eMsgSNP <%=_child_blkid[pidx]%>_stash_snp_req_type_q[$]; 
           smi_cmstatus_snarf_t   <%=_child_blkid[pidx]%>_snp_rsp_snarf ;
           smi_msg_id_bit_t <%=_child_blkid[pidx]%>_stash_snp_req_msg_id_q[$];
        <%}%>
        eMsgCMD <%=_child_blkid[pidx]%>_stash_cmd_req_type;
        int <%=_child_blkid[pidx]%>_stash_target =-1;
       <%} // if ACELITE-E or CHI%>   
     <%} //foreach AIUS%>   
    // End_Stash
<%}%>

    enum {  ignore7,
        sp_base_addr_lower,
        sp_base_addr,
        sp_base_addr_high,
        sp_max_addr_lower,
        sp_max_addr,
        sp_max_addr_high} CovDmiSpAddr;

    bit [<%=obj.wSysAddr-1%>:0] k_sp_base_addr[] = new[ncore_config_pkg::ncoreConfigInfo::NUM_DMIS];
    smi_addr_t      k_sp_base_addr_p;
    smi_addr_t      k_sp_max_addr;
    int             spaddr_index, sp_ways;

    function smi_addr_t cl_aligned(smi_addr_t addr);
        smi_addr_t cl_aligned_addr;
        cl_aligned_addr = (addr >> $clog2(SYS_nSysCacheline));
        return cl_aligned_addr;
    endfunction // cl_aligned

    <% var ign = `ignore_`;%>

///////////////////////////////////////////////////////////////////////////////////
// ####   ####  #    # ###### #####   ####  #####   ####  #    # #####   ####  
//#    # #    # #    # #      #    # #    # #    # #    # #    # #    # #      
//#      #    # #    # #####  #    # #      #    # #    # #    # #    #  ####  
//#      #    # #    # #      #####  #  ### #####  #    # #    # #####       # 
//#    # #    #  #  #  #      #   #  #    # #   #  #    # #    # #      #    # 
// ####   ####    ##   ###### #    #  ####  #    #  ####   ####  #       ####  
///////////////////////////////////////////////////////////////////////////////////
// AIUs Commun covergroup 
   covergroup cg_smi;
        <% if (numChiAiu>0) {%>
        CovChiCmdReq:    coverpoint chi_cmd_req_type { //#Cover.FSYS.Chi.cmdreq.*
            ignore_bins ignore_value = { eCmdWrStshFull,eCmdWrStshPtl // not supported in CHI 
                        <%if (!dmi_useAtomic)  {%>,eCmdWrAtm,eCmdRdAtm,eCmdSwAtm,eCmdCompAtm // NO atomic supported in this cfg <%}%>
            };
        }
        CovDmiDtrReqChi: coverpoint dmi_dtr_req_chi_type;//#Cover.FSYS.dtrreq.DMItoChi.*
        CovDiiDtrReqChi: coverpoint dii_dtr_req_chi_type {bins  DtrDataInv = {eDtrDataInv};} //#Cover.FSYS.dtrreq.DIItoChi.DtrDataInv
        CovAiuDtrReqChi: coverpoint aiu_dtr_req_chi_type; //#Cover.FSYS.dtrreq.AIUtoChi.* 
        CovChiDtwReqDmi: coverpoint chi_dtw_req_dmi_type; //#Cover.FSYS.dtwreq.ChitoDMI.* 
        CovChiDtwReqDii: coverpoint chi_dtw_req_dii_type{ //#Cover.FSYS.dtwreq.ChitoDII.*
                ignore_bins ignored_values ={eDtwDataCln};  // No WriteEvict to DII
                }
        <%if (obj.initiatorGroups.length == 1) {%>
        //Only tested on config with no Connectivity interleaving feature enable because AIUs / DCEs may not be connected between them and so nostash txn will produce this type of item 
        CovChiDtwmrgReqDmi:  coverpoint chi_dtwmrg_req_dmi_type{ //#Cover.FSYS.dtwMrgreq.ChitoDMI
                        ignore_bins ignored_values = {eDtwMrgMRDSCln,eDtwMrgMRDSDty}; // Reserved in CCMP TABLE 4-43
                        }
        <% } %>
        CovDceSnpReqChi: coverpoint dce_snp_req_chi_type{ // #Cover.FSYS.snpreq.Chi.*
                ignore_bins ignore_value ={eSnpRecall,eSnpDvmMsg};
                }
        <% } %>
        <% if (numIoAiu>0) {%>
        //#Cover.FSYS.IO.cmdreq.*
        CovIoCmdReq:     coverpoint ioaiu_cmd_req_type {
               bins b_CmdRdNC         = {eCmdRdNC};      
               <%if (!numAxi5_Axi4_with_cache && !numAceLite && !numAce){ %><%=ign%><%}%>bins b_CmdRdNITC       = {eCmdRdNITC};
               <%if (!numAxi5_Axi4_with_cache && !numAce){ %><%=ign%><%}%>bins b_CmdRdVld        = {eCmdRdVld};
               <%if (!numAce){ %><%=ign%><%}%>bins b_CmdRdCln        = {eCmdRdCln};
               <%if (!numAce){ %><%=ign%><%}%>bins b_CmdRdNShD       = {eCmdRdNShD};
               <%if (!numAce && !numAxi5_Axi4_with_cache){ %><%=ign%><%}%>bins b_CmdRdUnq        = {eCmdRdUnq};

               <%if (!numAceLite && !numAceLiteE && !numAce){ %><%=ign%><%}%>bins b_CmdClnVld       = {eCmdClnVld};
               <%if (!numAceLiteE){ %><%=ign%><%}%>bins b_CmdClnShdPer    = {eCmdClnShdPer};
               <%if (!numAce){ %><%=ign%><%}%>bins b_CmdClnUnq       = {eCmdClnUnq};
               <%if (!numAce && !numAxi5_Axi4_with_cache){ %><%=ign%><%}%>bins b_CmdMkUnq        = {eCmdMkUnq};

               <%if (!numAceLite && !numAceLiteE && !numAce){ %><%=ign%><%}%>bins b_CmdClnInv       = {eCmdClnInv};
               <%if (!numAceLite && !numAceLiteE && !numAce){ %><%=ign%><%}%>bins b_CmdMkInv        = {eCmdMkInv};
               <%if (!numAceLiteE){ %><%=ign%><%}%>bins b_CmdRdNITCClnInv = {eCmdRdNITCClnInv}; 
               <%if (!numAceLiteE){ %><%=ign%><%}%>bins b_CmdRdNITCMkInv  = {eCmdRdNITCMkInv};   

               <%if (!numAceLite && !numAce){ %><%=ign%><%}%>bins b_CmdDvmMsg       = {eCmdDvmMsg};

               <%if (!numAceLiteE){ %><%=ign%><%}%>bins b_CmdWrStshPtl    = {eCmdWrStshPtl};
               <%if (!numAceLiteE){ %><%=ign%><%}%>bins b_CmdWrStshFull   = {eCmdWrStshFull};
               <%if (!numAceLiteE){ %><%=ign%><%}%>bins b_CmdLdCchShd     = {eCmdLdCchShd};
               <%if (!numAceLiteE){ %><%=ign%><%}%>bins b_CmdLdCchUnq     = {eCmdLdCchUnq};

               <%if (!dmi_useAtomic || !numAceLiteE || !num_AXI5_atomic){ %><%=ign%><%}%>bins b_CmdWrAtm        = {eCmdWrAtm};
               <%if (!dmi_useAtomic || !numAceLiteE || !num_AXI5_atomic){ %><%=ign%><%}%>bins b_CmdRdAtm        = {eCmdRdAtm};
               <%if (!dmi_useAtomic || !numAceLiteE || !num_AXI5_atomic){ %><%=ign%><%}%>bins b_CmdSwAtm        = {eCmdSwAtm};
               <%if (!dmi_useAtomic || !numAceLiteE || !num_AXI5_atomic){ %><%=ign%><%}%>bins b_CmdCompAtm      = {eCmdCompAtm};

               bins b_CmdWrNCPtl      = {eCmdWrNCPtl};   
               bins b_CmdWrNCFull     = {eCmdWrNCFull};  

               <%if (!numAxi5_Axi4_with_cache && !numAceLite && !numAce && !numAceLiteE){ %><%=ign%><%}%>bins b_CmdWrUnqPtl     = {eCmdWrUnqPtl};
               <%if (!numAxi5_Axi4_with_cache && !numAceLite && !numAce && !numAceLiteE){ %><%=ign%><%}%>bins b_CmdWrUnqFull    = {eCmdWrUnqFull};

               <%if (!numAce){ %><%=ign%><%}%>bins b_CmdWrBkFull     = {eCmdWrBkFull};
               <%if (!numAce){ %><%=ign%><%}%>bins b_CmdWrBkPtl      = {eCmdWrBkPtl}; 
               <%if (!numAce){ %><%=ign%><%}%>bins b_CmdWrClnFull    = {eCmdWrClnFull};
               <%if (!numAce){ %><%=ign%><%}%>bins b_CmdWrClnPtl     = {eCmdWrClnPtl}; 
               <%if (!numAce){ %><%=ign%><%}%>bins b_CmdWrEvict      = {eCmdWrEvict};
               <%if (!numAce){ %><%=ign%><%}%>bins b_CmdEvict        = {eCmdEvict};
               <%=ign%>bins b_CmdPref                                = {eCmdPref};     // Not Applicable according to CCMP spec
        
        } 
        CovDmiDtrReqIo:  coverpoint dmi_dtr_req_ioaiu_type{ //#Cover.FSYS.dtrreq.DMItoIO.*
                        <%if (!numAce){%>ignore_bins ignored_values = {eDtrDataShrDty,eDtrDataUnqDty}; // Only performed on ReadVld/ReadUnique .... CCMP spec TABLE 4-38. CMDreqs and the possible DTRreqs they may receive.
                        <%}%>
        }
        <% if(numAce>0 || numAceLiteE>0) { %>
        CovDiiCMOCmdReqIo:  coverpoint ioaiu_dii_cmd_req_type {//#Cover.FSYS.dii_cmo_io
            bins CMOcmdClnSh  = {eCmdClnVld};
            <%if (!numAceLiteE){ %><%=ign%><%}%>bins CMOcmdClnShPer  = {eCmdClnShdPer};
            bins CMOcmdClnInv = {eCmdClnInv};
            bins CMOcmdMkInv  = {eCmdMkInv};
        }
        <%}%>
        /* According to CHI-B spec Appendix A.1 Request message field mapping
        CMO are always with snpattr = 1 so not possible to goes to DII
        CovDiiCMOCmdReqChi:  coverpoint chi_dii_cmd_req_type { //#Cover.FSYS.dii_cmo_chi
            bins CMOcmdClnSh  = {eCmdClnVld};
            bins CMOcmdClnInv = {eCmdClnInv};
            bins CMOcmdMkInv  = {eCmdMkInv};
            bins CMOcmdClnShPer  = {eCmdClnShdPer};
        }
        */
        CovDiiDtrReqIo:  coverpoint dii_dtr_req_ioaiu_type {bins DtrDataInv = {eDtrDataInv};} //#Cover.FSYS.dtrreq.DIItoIO.DtrDataInv
        CovAIuDTrReqIo:  coverpoint aiu_dtr_req_ioaiu_type; //#Cover.FSYS.dtrreq.AIUtoIO.*
        CovIoDtwReqDmi:  coverpoint ioaiu_dtw_req_dmi_type{ //#Cover.FSYS.dtwreq.IOtoDMI.*
                        <%if (!numAce){%>ignore_bins ignored_values = {eDtwDataCln,eDtwNoData}; // Only performed on WriteEvict / WriteBack operations  <%}%>
            }
        CovIoDtwReqDii:  coverpoint ioaiu_dtw_req_dii_type { //#Cover.FSYS.dtwreq.IOtoDII.*
                ignore_bins ignored_values ={eDtwDataCln,eDtwNoData}; // No WriteEvict / WriteBack to DII
                }

        <%if (obj.initiatorGroups.length == 1) {%>
            <%if (numAceLiteE){ %> // The SMI messages appears with Stash Ptl transactions
        //Only tested on config with no Connectivity interleaving feature enable because AIUs / DCEs may not be connected between them and so nostash txn will produce this type of item 
        CovIoDtwmrgReqDmi: coverpoint ioaiu_dtwmrg_req_dmi_type{ //#Cover.FSYS.dtwMrgreq.IOtoDMI 
                        ignore_bins ignored_rsvd_values = {eDtwMrgMRDSCln,eDtwMrgMRDSDty}; // Reserved in CCMP TABLE 4-43
                        ignore_bins ignored_values = {eDtwMrgMRDInv,eDtwMrgMRDUCln}; // Not applicable according to Concerto C mappings v0.92
                        }
            <%}%>
        <%}%>
        
        <%if (numAce){%> CovIoUpdReq: coverpoint ioaiu_upd_req_type{ //#Cover.FSYS.updreqIO.*
                ignore_bins ignored_values ={eUpdSCln}; // CCMP v0.90 UpdSCln will not be implemented in Ncore 3.0, but will be implemented on Ncore 3’s future revisions
                }
        <%}%>
         <%if (numAxi5_Axi4_with_cache){%> CovIoUpdReqAxi5_Axi4pc: coverpoint ioaiu_upd_axi5_axi4pc_req_type{ 
                ignore_bins ignored_values ={eUpdSCln}; // CCMP v0.90 UpdSCln will not be implemented in Ncore 3.0, but will be implemented on Ncore 3’s future revisions
                }
        <%}%>
        CovDceSnpReqIo:  coverpoint dce_snp_req_ioaiu_type { //#Cover.FSYS.snpreq.IO.*
                ignore_bins ignored_values ={eSnpRecall,eSnpDvmMsg
                                            <%if (!numAceLiteE){%>,eSnpStshShd,eSnpStshUnq,eSnpUnqStsh,eSnpInvStsh<%}%>// Only performed when CmdLdCchUnq / CmdLdCchShd
                                            <%if (!numAce){%>,eSnpInvDtr<%}%>// Only performed when ReadUnique
                                            <%if (!numAceLiteE){ %>,eSnpNITCCI,eSnpNITCMI <%}%>
                                            <%if (!numAce){%>,eSnpClnDtr<%}%>// Only performed when Readclean
                                            }; 
                }
        <% if (num_AXI5_with_owo>0) {%>
        CovDceSnpReqIo_owo_axi:  coverpoint dce_snp_req_ioaiu_owo_axi_type;
        <% } %>
        <% if (numAceLite_with_owo>0) {%>
         CovDceSnpReqIo_owo_AceLite:  coverpoint dce_snp_req_ioaiu_owo_AceLite_type;
        <% } %>

        <% if (numAceLite_with_owo>0) {%>
        // #Cover.FSYS.v371.amba5_AceLite_owo_txns_smi 
        CovIo_owo_AceLite_CmdReq:     coverpoint ioaiu_owo_AceLite_cmd_req_type{
               bins b_CmdRdNITC       = {eCmdRdNITC};
               bins b_CmdRdNC         = {eCmdRdNC};      
               bins b_CmdWrNCPtl      = {eCmdWrNCPtl};   
               bins b_CmdWrNCFull     = {eCmdWrNCFull};  
               bins b_CmdClnUnq       = {eCmdClnUnq};
        }
        <% } %>
        <% if (num_AXI5_with_owo>0) {%>
        // #Cover.FSYS.v371.amba5_axi5_owo_txns_smi 
        CovIo_owo_axi_CmdReq:     coverpoint ioaiu_owo_axi_cmd_req_type{
               bins b_CmdRdNITC       = {eCmdRdNITC};
               bins b_CmdRdNC         = {eCmdRdNC};      
               bins b_CmdWrNCPtl      = {eCmdWrNCPtl};   
               bins b_CmdWrNCFull     = {eCmdWrNCFull};  
               bins b_CmdClnUnq       = {eCmdClnUnq};
        }
        <% } %>
        <% if (numAce5Lite_with_owo>0) {%>
        // #Cover.FSYS.v371.amba5_Ace5Lite_owo_txns_smi
        CovIo_owo_Ace5Lite_CmdReq:     coverpoint ioaiu_owo_Ace5Lite_cmd_req_type{
               bins b_CmdRdNITC       = {eCmdRdNITC};
               bins b_CmdRdNC         = {eCmdRdNC};      
               bins b_CmdWrNCPtl      = {eCmdWrNCPtl};   
               bins b_CmdWrNCFull     = {eCmdWrNCFull};  
               bins b_CmdClnUnq       = {eCmdClnUnq};
        }
        <% } %>
        <% } %>
        CovDceMrdReq:    coverpoint dce_mrd_req_type { //#Cover.FSYS.mrdreq.*
                ignore_bins ignored_MrdCln ={eMrdRdCln}; //(This MRD type is deprecated in CCMP.)
                <%if (!numAceLiteE){%>ignore_bins ignored_MrdPref = {eMrdPref}; // Only performed on CmdLdCchUnq / CmdLdCchShd
                <%}%>
                }

        CovDceRbrReq:    coverpoint dce_rbr_req_type; //#Cover.FSYS.rbr.*
    <% if(obj.nDCEs>0) { %>
    // #Cover.FSYS.sysevent.DCE_sends_smi_sysreq
        CovDceSysReq:    coverpoint DCE_sends_sysreq_event_bit {
        ignore_bins ignore_DCE_sends_sysreq_event_bit =  {0};
        }
    <% } %>
    <% if(obj.nDMIs>0 && (obj.DmiInfo[0].nExclusiveEntries > 0 )) { %>
    // #Cover.FSYS.sysevent.DMI_sends_smi_sysreq
        CovDmiSysReq:    coverpoint DMI_sends_sysreq_event_bit {
        ignore_bins ignore_DMI_sends_sysreq_event_bit =  {0};
        }
    <% } %>
    <% if(obj.nDIIs>0 && (obj.DiiInfo[0].nExclusiveEntries > 0 )) { %>
    // #Cover.FSYS.sysevent.DII_sends_smi_sysreq
        CovDiiSysReq:    coverpoint DII_sends_sysreq_event_bit {
        ignore_bins ignore_DII_sends_sysreq_event_bit =  {0};
        }
    <% } %>
    <% if(obj.nDVEs>0) { %>
    // #Cover.FSYS.sysevent.DVE_sends_smi_sysreq
        CovDveSysReq:    coverpoint DVE_sends_sysreq_event_bit {
        ignore_bins ignore_DVE_sends_sysreq_event_bit =  {0};
        }
    <% } %>
    <% if(obj.nDVEs>0) { %>
    // #Cover.FSYS.sysevent.DVE_sends_smi_sysrsp
        CovDveSysRsp:    coverpoint DVE_sends_sysrsp_event_bit {
        ignore_bins ignore_DVE_sends_sysreq_event_bit =  {0};
        }
    <% } %>
    <% if(numAce>0 || numAceLiteE>0 ) { %>
    // #Cover.FSYS.sysevent.ioaiu_sends_smi_sysreq
        CovioaiuSysReq:    coverpoint ioaiu_sends_sysreq_event_bit {
        ignore_bins ignore_ioaiu_sends_sysreq_event_bit =  {0};
        }
    <% } %>
    <% if (num_AXI5_with_owo>0) {%>
        Covioaiu_owo_axi_SysReq:    coverpoint ioaiu_owo_axi_sends_sysreq_event_bit{
        ignore_bins ignore_ioaiu_sends_sysreq_event_bit =  {0};
        }
     <% } %>

     <% if (numAceLite_with_owo>0) {%>
        Covioaiu_owo_AceLite_SysReq:    coverpoint ioaiu_owo_AceLite_sends_sysreq_event_bit{
        ignore_bins ignore_ioaiu_sends_sysreq_event_bit =  {0};
        }
     <% } %>
    <% if(numChiAiu>0) { %>
    // #Cover.FSYS.sysevent.chiaiu_sends_smi_sysreq
        CovchiaiuSysReq:    coverpoint chiaiu_sends_sysreq_event_bit {
        ignore_bins ignore_chiaiu_sends_sysreq_event_bit =  {0};
        }
    <% } %>
    <% if((numAce || numAxi5_Axi4_with_cache>0 || numAceLiteE>0) && obj.nDCEs>0) { %>
    // #Cover.FSYS.sysevent.ioaiu_sends_smi_sysrsp
        CovIoaiuSysRsp : coverpoint ioaiu_sends_sysrsp_bit {
        ignore_bins ignore_ioaiu_sends_sysrsp_bit =  {0};
        }
    <% } %>
    <% if(numChiAiu>0 && obj.nDCEs>0) { %>
    // #Cover.FSYS.sysevent.chiaiu_sends_smi_sysrsp
        CovChiaiuSysRsp : coverpoint chiaiu_sends_sysrsp_bit {
        ignore_bins ignore_chiaiu_sends_sysrsp_bit =  {0};
        }
    <% } %>
    <% if (obj.nDMIs>0 && obj.DmiInfo[0].useCmc && obj.DmiInfo[0].ccpParams.useScratchpad){ %>
        // #cover.FSYS.DMI.ScratchPad.ApAddr
        CovDmiSpAddr:    coverpoint CovDmiSpAddr {
        bins sp_base_addr_lower = {sp_base_addr_lower};
        bins sp_base_addr       = {sp_base_addr};
        bins sp_base_addr_high  = {sp_base_addr_high};
        bins sp_max_addr_lower  = {sp_max_addr_lower};
        bins sp_max_addr        = {sp_max_addr};
        bins sp_max_addr_high   = {sp_max_addr_high};
        }
    <% } %>
    endgroup

    covergroup cg_connectivity;
        <%if (obj.ConnectivityMap) {%>
        AiuSmiSrcId: coverpoint aiu_smi_req_src_id {
           <%=obj.AiuInfo.map(item =>`bins aiu_ids${item.FUnitId}={${item.FUnitId}};`).join('\n')%>
        }
        AiuSmiTrgtId: coverpoint aiu_smi_req_trgt_id {
            <%=obj.AiuInfo.filter(item => !((item.fnNativeInterface == "AXI4" && item.useCache == 0) || (item.fnNativeInterface == "AXI5" && item.useCache == 0))).map(item =>`bins aiu_ids${item.FUnitId}={${item.FUnitId}};`).join('\n')%>
            <%=obj.DiiInfo.map(item =>`bins dii_ids${item.FUnitId}={${item.FUnitId}};`).join('\n')%>
            <%=obj.DmiInfo.map(item =>`bins dmi_ids${item.FUnitId}={${item.FUnitId}};`).join('\n')%>
            <%=obj.DceInfo.map(item =>`bins dce_ids${item.FUnitId}={${item.FUnitId}};`).join('\n')%>
            <%=obj.DveInfo.map(item =>`bins dve_ids${item.FUnitId}={${item.FUnitId}};`).join('\n')%>
        }
        DceSmiSrcId: coverpoint dce_smi_req_src_id {
            <%=obj.DceInfo.map(item =>`bins dce_ids${item.FUnitId}={${item.FUnitId}};`).join('\n')%>
        }
        DceSmiTrgtId: coverpoint dce_smi_req_trgt_id {
            <%=obj.AiuInfo.filter(item => !((item.fnNativeInterface == "AXI4" && item.useCache == 0) || (item.fnNativeInterface == "AXI5" && item.useCache == 0))).map(item =>`bins aiu_ids${item.FUnitId}={${item.FUnitId}};`).join('\n')%>
            <%=obj.DmiInfo.map(item =>`bins dmi_ids${item.FUnitId}={${item.FUnitId}};`).join('\n')%>
         }
        DmiSmiSrcId: coverpoint dmi_smi_req_src_id {
            <%=obj.DmiInfo.map(item =>`bins dmi_ids${item.FUnitId}={${item.FUnitId}};`).join('\n')%>
        }
        DmiSmiTrgtId: coverpoint dmi_smi_req_trgt_id {
            <%=Object.keys(obj.ConnectivityMap.aiuDmiMap).map(src =>`bins aiu_ids${src}={${src}};`).join('\n')%>
            <%=obj.DceInfo.map(item =>`bins dce_ids${item.FUnitId}={${item.FUnitId}};`).join('\n')%>
         }
        DiiSmiSrcId: coverpoint dii_smi_req_src_id {
            <%=obj.DiiInfo.map(item =>`bins dii_ids${item.FUnitId}={${item.FUnitId}};`).join('\n')%>
        }
        DiiSmiTrgtId: coverpoint dii_smi_req_trgt_id {
            <%=Object.keys(obj.ConnectivityMap.aiuDiiMap).map(src =>`bins aiu_ids${src}={${src}};`).join('\n')%>
         }
        DveSmiSrcId: coverpoint dve_smi_req_src_id {
            <%=obj.DveInfo.map(item =>`bins dve_ids${item.FUnitId}={${item.FUnitId}};`).join('\n')%>
        }
        DveSmiTrgtId: coverpoint dve_smi_req_trgt_id {
        //      <%=obj.AiuInfo.map(item => (item.cmpInfo.nDvmSnpInFlight > 0)?`//bins aiu_ids${item.FUnitId}={${item.FUnitId}};`:``).join('\n')%>
              <%=obj.DveInfo.map(item => (item.sysEvtReceivers && item.sysEvtReceivers.length > 0)?
                    item.sysEvtReceivers.map( trgtId =>
`                   bins aiu_ids${trgtId}={${trgtId}};`).join('\n')
                    :``).join('\n')%>
         }
         //Copied these bins here for AIU X dest_id X txn_type bin
        <% if (numChiAiu>0) {%>
        CovChiCmdReq:    coverpoint chi_cmd_req_type { //#Cover.FSYS.Chi.cmdreq.*
            ignore_bins ignore_value = { eCmdWrStshFull,eCmdWrStshPtl // not supported in CHI 
                        <%if (!dmi_useAtomic)  {%>,eCmdWrAtm,eCmdRdAtm,eCmdSwAtm,eCmdCompAtm // NO atomic supported in this cfg <%}%>
            };
        }
        <%}%>
        <% if (numIoAiu>0) {%>
        //#Cover.FSYS.IO.cmdreq.*
        CovIoCmdReq:     coverpoint ioaiu_cmd_req_type {
               bins b_CmdRdNC         = {eCmdRdNC};      
               <%if (!numAxi5_Axi4_with_cache && !numAceLite && !numAce){ %><%=ign%><%}%>bins b_CmdRdNITC       = {eCmdRdNITC};
               <%if (!numAxi5_Axi4_with_cache && !numAce){ %><%=ign%><%}%>bins b_CmdRdVld        = {eCmdRdVld};
               <%if (!numAce){ %><%=ign%><%}%>bins b_CmdRdCln        = {eCmdRdCln};
               <%if (!numAce){ %><%=ign%><%}%>bins b_CmdRdNShD       = {eCmdRdNShD};
               <%if (!numAce && !numAxi5_Axi4_with_cache){ %><%=ign%><%}%>bins b_CmdRdUnq        = {eCmdRdUnq};

               <%if (!numAceLite && !numAceLiteE && !numAce){ %><%=ign%><%}%>bins b_CmdClnVld       = {eCmdClnVld};
               <%if (!numAceLiteE){ %><%=ign%><%}%>bins b_CmdClnShdPer    = {eCmdClnShdPer};
               <%if (!numAce){ %><%=ign%><%}%>bins b_CmdClnUnq       = {eCmdClnUnq};
               <%if (!numAce && !numAxi5_Axi4_with_cache){ %><%=ign%><%}%>bins b_CmdMkUnq        = {eCmdMkUnq};

               <%if (!numAceLite && !numAceLiteE && !numAce){ %><%=ign%><%}%>bins b_CmdClnInv       = {eCmdClnInv};
               <%if (!numAceLite && !numAceLiteE && !numAce){ %><%=ign%><%}%>bins b_CmdMkInv        = {eCmdMkInv};
               <%if (!numAceLiteE){ %><%=ign%><%}%>bins b_CmdRdNITCClnInv = {eCmdRdNITCClnInv}; 
               <%if (!numAceLiteE){ %><%=ign%><%}%>bins b_CmdRdNITCMkInv  = {eCmdRdNITCMkInv};   

               <%if (!numAceLite && !numAce){ %><%=ign%><%}%>bins b_CmdDvmMsg       = {eCmdDvmMsg};

               <%if (!numAceLiteE){ %><%=ign%><%}%>bins b_CmdWrStshPtl    = {eCmdWrStshPtl};
               <%if (!numAceLiteE){ %><%=ign%><%}%>bins b_CmdWrStshFull   = {eCmdWrStshFull};
               <%if (!numAceLiteE){ %><%=ign%><%}%>bins b_CmdLdCchShd     = {eCmdLdCchShd};
               <%if (!numAceLiteE){ %><%=ign%><%}%>bins b_CmdLdCchUnq     = {eCmdLdCchUnq};

               <%if (!dmi_useAtomic || !numAceLiteE|| !num_AXI5_atomic){ %><%=ign%><%}%>bins b_CmdWrAtm        = {eCmdWrAtm};
               <%if (!dmi_useAtomic || !numAceLiteE|| !num_AXI5_atomic){ %><%=ign%><%}%>bins b_CmdRdAtm        = {eCmdRdAtm};
               <%if (!dmi_useAtomic || !numAceLiteE|| !num_AXI5_atomic){ %><%=ign%><%}%>bins b_CmdSwAtm        = {eCmdSwAtm};
               <%if (!dmi_useAtomic || !numAceLiteE|| !num_AXI5_atomic){ %><%=ign%><%}%>bins b_CmdCompAtm      = {eCmdCompAtm};

               bins b_CmdWrNCPtl      = {eCmdWrNCPtl};   
               bins b_CmdWrNCFull     = {eCmdWrNCFull};  

               <%if (!numAxi5_Axi4_with_cache && !numAceLite && !numAce && !numAceLiteE){ %><%=ign%><%}%>bins b_CmdWrUnqPtl     = {eCmdWrUnqPtl};
               <%if (!numAxi5_Axi4_with_cache && !numAceLite && !numAce && !numAceLiteE){ %><%=ign%><%}%>bins b_CmdWrUnqFull    = {eCmdWrUnqFull};

               <%if (!numAce){ %><%=ign%><%}%>bins b_CmdWrBkFull     = {eCmdWrBkFull};
               <%if (!numAce){ %><%=ign%><%}%>bins b_CmdWrBkPtl      = {eCmdWrBkPtl}; 
               <%if (!numAce){ %><%=ign%><%}%>bins b_CmdWrClnFull    = {eCmdWrClnFull};
               <%if (!numAce){ %><%=ign%><%}%>bins b_CmdWrClnPtl     = {eCmdWrClnPtl}; 
               <%if (!numAce){ %><%=ign%><%}%>bins b_CmdWrEvict      = {eCmdWrEvict};
               <%if (!numAce){ %><%=ign%><%}%>bins b_CmdEvict        = {eCmdEvict};
               <%=ign%>bins b_CmdPref                                = {eCmdPref};     // Not Applicable according to CCMP spec
        
        } 
        <% } %>
        //#Cover.FSYS.Connectivity.<Src><Fid>_x_<Trgt><Fid>
        CovConnectAiu: cross AiuSmiSrcId,AiuSmiTrgtId {
<%=Object.keys(obj.ConnectivityMap.aiuDmiMap).map(src =>     //foreach src id
                   obj.ConnectivityMap.aiuDmiMap[src].map(trgt => // foreach Dmi target id
`                             bins AiuSrcId${src}_DmitrgtId${trgt} = CovConnectAiu with (AiuSmiSrcId == ${src} && AiuSmiTrgtId == ${trgt});`  // create a bins
                         ).join(`\n`)).join(`\n`)%> 
<%=Object.keys(obj.ConnectivityMap.aiuDiiMap).map(src =>     //foreach src id
                   obj.ConnectivityMap.aiuDiiMap[src].map(trgt => // foreach dii target id
`                             bins AiuSrcId${src}_DiitrgtId${trgt} = CovConnectAiu with (AiuSmiSrcId == ${src} && AiuSmiTrgtId == ${trgt});`  // create a bins
                         ).join(`\n`)).join(`\n`)%>
<%=Object.keys(obj.ConnectivityMap.aiuDceMap).filter(src => !((obj.AiuInfo[src].fnNativeInterface == "AXI4" && obj.AiuInfo[src].useCache == 0) || (obj.AiuInfo[src].fnNativeInterface == "AXI5" && obj.AiuInfo[src].useCache == 0))).map(src =>     //foreach src id
                         obj.ConnectivityMap.aiuDceMap[src].map(trgt => // foreach dce target id
`                             bins AiuSrcId${src}_DcetrgtId${trgt} = CovConnectAiu with (AiuSmiSrcId == ${src} && AiuSmiTrgtId == ${trgt});`  // create a bins
                               ).join(`\n`)).join(`\n`)%>
<%=Object.keys(obj.ConnectivityMap.aiuAiuMap).filter(src => !((obj.AiuInfo[src].fnNativeInterface == "AXI4" && obj.AiuInfo[src].useCache == 0) || (obj.AiuInfo[src].fnNativeInterface == "AXI5" && obj.AiuInfo[src].useCache == 0))).map(src =>     //foreach src id 
                               obj.ConnectivityMap.aiuAiuMap[src].filter(trgt => !((obj.AiuInfo[trgt].fnNativeInterface == "AXI4" && obj.AiuInfo[trgt].useCache == 0) || (obj.AiuInfo[trgt].fnNativeInterface == "AXI5" && obj.AiuInfo[trgt].useCache == 0))).map(trgt => // foreach Aiu target id
`                             bins AiuSrcId${src}_AiutrgtId${trgt} = CovConnectAiu with (AiuSmiSrcId == ${src} && AiuSmiTrgtId == ${trgt});`  // create a bins
                                     ).join(`\n`)).join(`\n`)%>                                                        
<%=obj.AiuInfo.map(src =>  (src.cmpInfo.nDvmSnpInFlight==0)?``:   //foreach src id supporting DVM
                obj.DveInfo.map(trgt => // foreach dve target
`                             bins AiuSrcId${src.FUnitId}_DvetrgtId${trgt.FUnitId} = CovConnectAiu with (AiuSmiSrcId == ${src.FUnitId} && AiuSmiTrgtId == ${trgt.FUnitId});`  // create a bins
                  ).join(`\n`)).join(`\n`)%>  
                  option.cross_auto_bin_max = 0;                                                       
                                     }
        <% if (numChiAiu>0) {%>
        CovConnectChiAiuCmdType: cross CovConnectAiu, CovChiCmdReq {

            <%=Object.keys(obj.ConnectivityMap.aiuDiiMap).map(src =>
            obj.ConnectivityMap.aiuDiiMap[src].map(trgt =>            
     `      ignore_bins ignore_not_possible_AiuSrcId${src}_DiitrgtId${trgt}_cmdtype_bins = binsof (CovConnectAiu.AiuSrcId${src}_DiitrgtId${trgt}) && binsof(CovChiCmdReq) intersect {eCmdEvict,eCmdWrEvict,eCmdWrClnPtl,eCmdWrClnFull,eCmdWrBkPtl,
                                                                                        eCmdWrBkFull,eCmdWrUnqFull,eCmdWrUnqPtl,eCmdCompAtm,eCmdSwAtm,eCmdRdAtm,
                                                                                        eCmdWrAtm,eCmdRdVld,eCmdRdNITC,eCmdRdNShD,eCmdClnVld,eCmdClnUnq,eCmdMkUnq,eCmdRdNITCClnInv,
                                                                                        eCmdRdNITCMkInv,eCmdDvmMsg,eCmdWrStshPtl,eCmdWrStshFull,eCmdLdCchShd,eCmdLdCchUnq,eCmdRdCln,eCmdPref,eCmdRdUnq}
                                                                                    ;`
             ).join(`\n`)).join(`\n`)%>               
            <%=Object.keys(obj.ConnectivityMap.aiuDmiMap).map(src =>
            obj.ConnectivityMap.aiuDmiMap[src].map(trgt =>            
     `      ignore_bins ignore_not_possible_AiuSrcId${src}_DmitrgtId${trgt}_cmdtype_bins = binsof (CovConnectAiu.AiuSrcId${src}_DmitrgtId${trgt}) && binsof(CovChiCmdReq) intersect {eCmdEvict,eCmdWrEvict,eCmdWrClnPtl,eCmdWrClnFull,eCmdWrBkPtl,
                                                                                        eCmdWrBkFull,eCmdWrUnqFull,eCmdWrUnqPtl,eCmdCompAtm,eCmdSwAtm,eCmdRdAtm,
                                                                                        eCmdWrAtm,eCmdRdVld,eCmdRdNITC,eCmdRdNShD,eCmdClnVld,eCmdClnUnq,eCmdMkUnq,eCmdRdNITCClnInv,
                                                                                        eCmdRdNITCMkInv,eCmdDvmMsg,eCmdWrStshPtl,eCmdWrStshFull,eCmdLdCchShd,eCmdLdCchUnq,eCmdPref}
                                                                                    ;`
             ).join(`\n`)).join(`\n`)%>
            <%=obj.AiuInfo.map(src =>  (src.cmpInfo.nDvmSnpInFlight==0)?``:
            obj.DveInfo.map(trgt =>       
     `      ignore_bins ignore_not_possible_AiuSrcId${src.FUnitId}_DvetrgtId${trgt.FUnitId}_cmdtype_bins = binsof (CovConnectAiu.AiuSrcId${src.FUnitId}_DvetrgtId${trgt.FUnitId} ) && binsof(CovChiCmdReq) intersect {eCmdEvict,eCmdWrEvict,eCmdWrClnPtl,eCmdWrClnFull,eCmdWrBkPtl,
                                                                                        eCmdWrBkFull,eCmdWrUnqFull,eCmdWrUnqPtl,eCmdCompAtm,eCmdSwAtm,eCmdRdAtm,
                                                                                        eCmdWrAtm,eCmdRdVld,eCmdRdNITC,eCmdRdNShD,eCmdClnVld,eCmdClnUnq,eCmdMkUnq,eCmdRdNITCClnInv,
                                                                                        eCmdRdNITCMkInv,eCmdWrStshPtl,eCmdWrStshFull,eCmdLdCchShd,eCmdLdCchUnq,eCmdRdCln,eCmdPref,eCmdClnShdPer,eCmdWrNCFull,eCmdWrNCPtl,eCmdMkInv,eCmdClnInv,eCmdRdUnq}
                                                                                    ;`
             ).join(`\n`)).join(`\n`)%>            
            
             option.cross_auto_bin_max = 0; }
        <%}%>
        <% if (numIoAiu>0) {%>
        CovConnectIoAiuCmdType: cross CovConnectAiu, CovIoCmdReq {

            <%=Object.keys(obj.ConnectivityMap.aiuDiiMap).map(src =>
            obj.ConnectivityMap.aiuDiiMap[src].map(trgt =>            
     `      ignore_bins ignore_not_possible_AiuSrcId${src}_DiitrgtId${trgt}_cmdtype_bins = binsof (CovConnectAiu.AiuSrcId${src}_DiitrgtId${trgt}) && binsof(CovIoCmdReq) intersect {eCmdEvict,eCmdWrEvict,eCmdWrClnPtl,eCmdWrClnFull,eCmdWrBkPtl,
                                                                                        eCmdWrBkFull,eCmdWrUnqFull,eCmdWrUnqPtl,eCmdCompAtm,eCmdSwAtm,eCmdRdAtm,
                                                                                        eCmdWrAtm,eCmdRdVld,eCmdRdNITC,eCmdRdNShD,eCmdClnVld,eCmdClnUnq,eCmdMkUnq,eCmdRdNITCClnInv,
                                                                                        eCmdRdNITCMkInv,eCmdDvmMsg,eCmdWrStshPtl,eCmdWrStshFull,eCmdLdCchShd,eCmdLdCchUnq,eCmdRdCln,eCmdPref,eCmdRdUnq}
                                                                                    ;`
             ).join(`\n`)).join(`\n`)%>
            <%=Object.keys(obj.ConnectivityMap.aiuDmiMap).map(src =>
            obj.ConnectivityMap.aiuDmiMap[src].map(trgt =>            
     `      ignore_bins ignore_not_possible_AiuSrcId${src}_DmitrgtId${trgt}_cmdtype_bins = binsof (CovConnectAiu.AiuSrcId${src}_DmitrgtId${trgt}) && binsof(CovIoCmdReq) intersect {eCmdEvict,eCmdWrEvict,eCmdWrClnPtl,eCmdWrClnFull,eCmdWrBkPtl,
                                                                                        eCmdWrBkFull,eCmdWrUnqFull,eCmdWrUnqPtl,eCmdCompAtm,eCmdSwAtm,eCmdRdAtm,
                                                                                        eCmdWrAtm,eCmdRdVld,eCmdRdNITC,eCmdRdNShD,eCmdClnVld,eCmdClnUnq,eCmdMkUnq,eCmdRdNITCClnInv,
                                                                                        eCmdRdNITCMkInv,eCmdDvmMsg,eCmdWrStshPtl,eCmdWrStshFull,eCmdLdCchShd,eCmdLdCchUnq,eCmdPref}
                                                                                    ;`
             ).join(`\n`)).join(`\n`)%>
            <%=obj.AiuInfo.map(src =>  (src.cmpInfo.nDvmSnpInFlight==0)?``:
            obj.DveInfo.map(trgt =>       
     `      ignore_bins ignore_not_possible_AiuSrcId${src.FUnitId}_DvetrgtId${trgt.FUnitId}_cmdtype_bins = binsof (CovConnectAiu.AiuSrcId${src.FUnitId}_DvetrgtId${trgt.FUnitId} ) && binsof(CovIoCmdReq) intersect {eCmdEvict,eCmdWrEvict,eCmdWrClnPtl,eCmdWrClnFull,eCmdWrBkPtl,
                                                                                        eCmdWrBkFull,eCmdWrUnqFull,eCmdWrUnqPtl,eCmdCompAtm,eCmdSwAtm,eCmdRdAtm,
                                                                                        eCmdWrAtm,eCmdRdVld,eCmdRdNITC,eCmdRdNShD,eCmdClnVld,eCmdClnUnq,eCmdMkUnq,eCmdRdNITCClnInv,
                                                                                        eCmdRdNITCMkInv,eCmdDvmMsg,eCmdWrStshPtl,eCmdWrStshFull,eCmdLdCchShd,eCmdLdCchUnq,eCmdRdCln,eCmdPref,eCmdClnShdPer,eCmdWrNCFull,eCmdWrNCPtl,eCmdMkInv,eCmdClnInv,eCmdRdUnq}
                                                                                    ;`
             ).join(`\n`)).join(`\n`)%>
            option.cross_auto_bin_max = 0; }
        <%}%>

        CovConnectDce: cross DceSmiSrcId,DceSmiTrgtId {
<%=Object.keys(obj.ConnectivityMap.dceAiuMap).map(src =>     //foreach src id
                   obj.ConnectivityMap.dceAiuMap[src].filter(trgt => !((obj.AiuInfo[trgt].fnNativeInterface == "AXI4" && obj.AiuInfo[trgt].useCache == 0) || (obj.AiuInfo[trgt].fnNativeInterface == "AXI5" && obj.AiuInfo[trgt].useCache == 0))).map(trgt => // foreach traget id
`                             bins DceSrcId${src}_AiutrgtId${trgt} = CovConnectDce with (DceSmiSrcId == ${src} && DceSmiTrgtId == ${trgt});`  // create a bins
                         ).join(`\n`)).join(`\n`)%>
<%=Object.keys(obj.ConnectivityMap.dceDmiMap).map(src =>     //foreach src id
                   obj.ConnectivityMap.dceDmiMap[src].map(trgt => // foreach traget id
`                             bins DceSrcId${src}_DmitrgtId${trgt} = CovConnectDce with (DceSmiSrcId == ${src} && DceSmiTrgtId == ${trgt});`  // create a bins
                         ).join(`\n`)).join(`\n`)%>
                  option.cross_auto_bin_max = 0;                                                       
                         }

     CovConnectDmi: cross DmiSmiSrcId,DmiSmiTrgtId {
<%=Object.keys(obj.ConnectivityMap.dceDmiMap).map(trgt =>     //foreach target id
                   obj.ConnectivityMap.dceDmiMap[trgt].map(src => // foreach source id
`                             bins DmiSrcId${src}_DcetrgtId${trgt} = CovConnectDmi with (DmiSmiSrcId == ${src} && DmiSmiTrgtId == ${trgt});`  // create a bins
                         ).join(`\n`)).join(`\n`)%>
<%=Object.keys(obj.ConnectivityMap.aiuDmiMap).map(trgt =>     //foreach src id
                   obj.ConnectivityMap.aiuDmiMap[trgt].map(src => // foreach traget id
`                             bins DmiSrcId${src}_AiutrgtId${trgt} = CovConnectDmi with (DmiSmiSrcId == ${src} && DmiSmiTrgtId == ${trgt});`  // create a bins
                         ).join(`\n`)).join(`\n`)%>
                  option.cross_auto_bin_max = 0;                                                       
                         } 

      CovConnectDii: cross DiiSmiSrcId,DiiSmiTrgtId {
<%=Object.keys(obj.ConnectivityMap.aiuDiiMap).map(trgt =>     //foreach target id
                   obj.ConnectivityMap.aiuDiiMap[trgt].map(src => // foreach source id
`                             bins DiiSrcId${src}_AiutrgtId${trgt} = CovConnectDii with (DiiSmiSrcId == ${src} && DiiSmiTrgtId == ${trgt});`  // create a bins
                         ).join(`\n`)).join(`\n`)%>
                  option.cross_auto_bin_max = 0;                                                       
                         }   
                         
       CovConnectDve: cross DveSmiSrcId,DveSmiTrgtId {
<%=obj.DveInfo.map(src =>   (src.sysEvtReceivers && src.sysEvtReceivers.length > 0)?  //foreach src id
             src.sysEvtReceivers.map( trgt => 
`                            bins DveSrcId${src.FUnitId}_AiutrgtId${trgt} = CovConnectDve with (DveSmiSrcId == ${src.FUnitId} && DveSmiTrgtId == ${trgt});`  // create a bins
             //obj.AiuInfo.map(trgt => // foreach dve target
//`                             bins DveSrcId${src.FUnitId}_AiutrgtId${trgt.FUnitId} = CovConnectDve with (DveSmiSrcId == ${src.FUnitId} && DveSmiTrgtId == ${trgt.FUnitId});`  // create a bins
          ).join(`\n`):``).join(`\n`)%>   
                  option.cross_auto_bin_max = 0;                                                       
                                  }                                                                    
       <% } //if connectivityMap }%>
    endgroup

    <% if (numChiAiu || numAce || numAxi5_Axi4_with_cache) {%>
    //#Cover.FSYS.owner_transfer
    //#Cover.FSYS.sharer_promotion
    covergroup cg_sharerpromotion;
    // Also covered at DCE IP level with hashtags Check.DCE.SnpReq.UP & Cover.DCE.SnpReq.UP

    CovDceUniqPresence: coverpoint dce_smi_snp_up  {
                 bins dce_smi_snp_up_presence = {SMI_UP_PRESENCE};
                 bins dce_smi_snp_up_permission = {SMI_UP_PERMISSION};
                ignore_bins ignore_value = { SMI_UP_NONE,SMI_UP_PROVIDER};
                }
    <% if (numChiAiu) {%>
    CovChiUniqPresence: coverpoint chi_smi_snp_up  {
                 bins chi_smi_snp_up_presence = {SMI_UP_PRESENCE};
                 bins chi_smi_snp_up_permission = {SMI_UP_PERMISSION};
                ignore_bins ignore_value = { SMI_UP_NONE,SMI_UP_PROVIDER};
                }
    CovDceSnpReqChi: coverpoint dce_snp_req_chi_type { 
                bins DceSnpReqChi = {[eSnpClnDtr:eSnpNITCMI]}; 
                ignore_bins ignore_value ={eSnpDvmMsg,eSnpRecall};
                } 
    CovSharedPromotiontChi: cross CovChiUniqPresence,CovDceSnpReqChi ;
    <%}%>
    <% if (numAce) {%>
    CovAceUniqPresence: coverpoint ace_smi_snp_up  {
                 bins ace_smi_snp_up_presence = {SMI_UP_PRESENCE};
                 bins ace_smi_snp_up_permission = {SMI_UP_PERMISSION};
                ignore_bins ignore_value = { SMI_UP_NONE,SMI_UP_PROVIDER};
                }
    CovDceSnpReqAce:  coverpoint dce_snp_req_ace_type { 
                bins DceSnpReqAce = {[eSnpClnDtr:eSnpNITCMI]}; 
                ignore_bins ignore_value ={eSnpDvmMsg,eSnpRecall};
                } 
    CovSharedPromotiontAce: cross CovAceUniqPresence,CovDceSnpReqAce;
    <%}%>
    <% if (numAxi5_Axi4_with_cache) {%>
    CovAxi5_Axi4PCUniqPresence: coverpoint ncaiu_with_cache_smi_snp_up  {
                 bins ncaiu_with_cache_smi_snp_up_presence = {SMI_UP_PRESENCE};
                 bins ncaiu_with_cache_smi_snp_up_permission = {SMI_UP_PERMISSION};
                ignore_bins ignore_value = { SMI_UP_NONE,SMI_UP_PROVIDER};
                }
    CovDceSnpReqAxi5_Axi4PC:  coverpoint dce_snp_req_axi5_axi4PC_type { 
                bins DceSnpReqAxi5_Axi4PC = {[eSnpClnDtr:eSnpNITCMI]}; 
                ignore_bins ignore_value ={eSnpDvmMsg,eSnpRecall};
                } 
    CovSharedPromotiontAxi5_Axi4PC: cross CovAxi5_Axi4PCUniqPresence,CovDceSnpReqAxi5_Axi4PC;
    <%}%>
    endgroup
    <%}%>
<% if ((numAceLiteE && numChiAiu) || (numChiAiu>=2)) { // mini: 1 ACELITE+1CHI or 2 CHI%>
covergroup cg_stash;
<%for(pidx = 0; pidx < obj.nAIUs; pidx++) { %>  
 <%if(_child[pidx].fnNativeInterface == 'ACELITE-E' || (_child_blkid[pidx].match("chiaiu") && (numChiAiu>=2))) {%>
 Cov<%=_child_blkid[pidx]%>StashReq:    coverpoint <%=_child_blkid[pidx]%>_stash_cmd_req_type { 
        <%if(_child[pidx].fnNativeInterface == 'ACELITE-E') {%>
            bins <%=_child_blkid[pidx]%>WrStshFull = {eCmdWrStshFull};
            bins <%=_child_blkid[pidx]%>WrStshPtl  = {eCmdWrStshPtl};
        <%}// if acelite-E%>
            bins <%=_child_blkid[pidx]%>StshOnceShared = {eCmdLdCchShd};
            bins <%=_child_blkid[pidx]%>StshOnceUniq   = {eCmdLdCchUnq};
            }
 Cov<%=_child_blkid[pidx]%>StashTarget:    coverpoint <%=_child_blkid[pidx]%>_stash_target {
             <%for(sidx = 0; sidx < nALLs; sidx++) { %>  
               <% if (pidx !=sidx && _child_blkid[sidx].match("chiaiu")) { // pidx != sidx Chi can't target itself%>
                bins <%=_child_blkid[sidx]%> = {<%=_child[sidx].FUnitId%>}; 
              <%} // target only CHIs%> 
                //bins forbidden_<%=_child_blkid[sidx]%> = {<%=_child[sidx].FUnitId%>}; /* Removing as per JIRA - CONC-14698, CONC-16590 */
               <% if ( _child_blkid[sidx].match("dve")) { // dve last id%>
                //bins forbidden_doesnt_exist = {[<%=_child[sidx].FUnitId+1%>:$]}; /* Removing as per JIRA - CONC-14698, CONC-16590 */
               <%}%>
            <%}// second foreach agents%> 
            }
  Cov<%=_child_blkid[pidx]%>CrossStashCmdTarget: cross Cov<%=_child_blkid[pidx]%>StashReq,Cov<%=_child_blkid[pidx]%>StashTarget;
<%} //if agent embedded ACELITE-E || CHI%>
<%} //foreach AIUS%>
endgroup

covergroup cg_snp_stash;
<%for(pidx = 0; pidx < obj.nAIUs; pidx++) { %>  
 <%if (_child_blkid[pidx].match("chiaiu")) {%>
    Cov<%=_child_blkid[pidx]%>StashSnpReq:    coverpoint <%=_child_blkid[pidx]%>_stash_snp_req_type {
        bins <%=_child_blkid[pidx]%>SnpInvStsh   = {eSnpInvStsh};
        bins <%=_child_blkid[pidx]%>SnpUnqStsh   = {eSnpUnqStsh};
        bins <%=_child_blkid[pidx]%>SnpStshShd   = {eSnpStshShd};
        bins <%=_child_blkid[pidx]%>SnpStshUnq   = {eSnpStshUnq};
    }
    Cov<%=_child_blkid[pidx]%>StashSnpRsp:  coverpoint <%=_child_blkid[pidx]%>_snp_rsp_snarf {
        bins <%=_child_blkid[pidx]%>_accept  = {1};
        bins <%=_child_blkid[pidx]%>_decline = {0};
    } 
  Cov<%=_child_blkid[pidx]%>CrossStashSnpSnarf: cross Cov<%=_child_blkid[pidx]%>StashSnpReq,Cov<%=_child_blkid[pidx]%>StashSnpRsp;
<%} //if  CHI%>
<%} //foreach AIUS%>
endgroup
<%} // allow stash%> 
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
       cg_smi = new();
       cg_connectivity= new();
     <% if (numChiAiu || numAce || numAxi5_Axi4_with_cache) {%>
       cg_sharerpromotion= new();
    <%}%>
    <% if ((numAceLiteE && numChiAiu) || (numChiAiu>=2)) { // mini: 1 ACELITE+1CHI or 2 CHI%>
    cg_stash = new();
    cg_snp_stash = new();
    <%}%>
    endfunction:new

    // ALL FUNCTIONS
<%for(pidx = 0; pidx < nALLs; pidx++) { %>  
    extern function void collect_item_<%=_child_blkid[pidx]%>(<%=_child_blkid[pidx]%>_smi_agent_pkg::smi_seq_item m_pkt);
<%}%>
endclass:Fsys_smi_coverage

///////////////////////////////////////////////////////////////////////////////////
//  ###### #    # #    #  ####  ##### #  ####  #    #  ####  
//  #      #    # ##   # #    #   #   # #    # ##   # #      
//  #####  #    # # #  # #        #   # #    # # #  #  ####  
//  #      #    # #  # # #        #   # #    # #  # #      # 
//  #      #    # #   ## #    #   #   # #    # #   ## #    # 
//  #       ####  #    #  ####    #   #  ####  #    #  ####  
//////////////////////////////////////////////////////////////////////////////////
                                                           
<%for(pidx = 0; pidx < nALLs; pidx++) { %>
function void Fsys_smi_coverage::collect_item_<%=_child_blkid[pidx]%>(<%=_child_blkid[pidx]%>_smi_agent_pkg::smi_seq_item m_pkt);
    if (m_pkt) begin
        <%  if(_child_blk[pidx].match('chiaiu')) { %>
        case (ncoreConfigInfo::get_unit_type(m_pkt.smi_src_ncore_unit_id))
            ncoreConfigInfo::DMI: begin
                               if (m_pkt.smi_conc_msg_class == eConcMsgDtrReq) dmi_dtr_req_chi_type = eMsgDTR'(m_pkt.smi_msg_type);
                               dmi_smi_req_src_id = smi_ncore_unit_id_bit_t'(m_pkt.smi_src_ncore_unit_id);
                               dmi_smi_req_trgt_id = smi_ncore_unit_id_bit_t'(m_pkt.smi_targ_ncore_unit_id);
                              end
            ncoreConfigInfo::DII: begin 
                               if (m_pkt.smi_conc_msg_class == eConcMsgDtrReq) dii_dtr_req_chi_type = eMsgDTR'(m_pkt.smi_msg_type);
                               dii_smi_req_src_id = smi_ncore_unit_id_bit_t'(m_pkt.smi_src_ncore_unit_id);
                               dii_smi_req_trgt_id = smi_ncore_unit_id_bit_t'(m_pkt.smi_targ_ncore_unit_id);
                              end
            ncoreConfigInfo::AIU: begin
                               if (m_pkt.smi_conc_msg_class == eConcMsgCmdReq) begin
                                    chi_cmd_req_type =eMsgCMD'(m_pkt.smi_msg_type);
                                    <% if ((numAceLiteE && numChiAiu) || (numChiAiu>=2)) { // stash mini: 1 ACELITE+1CHI or 2 CHI%>
                                      <%=_child_blkid[pidx]%>_stash_cmd_req_type =eMsgCMD'(m_pkt.smi_msg_type);
                                      if (m_pkt.smi_mpf1_stash_valid) <%=_child_blkid[pidx]%>_stash_target = int'(m_pkt.smi_mpf1_stash_nid);
                                      cg_stash.sample();
                                    <%}%>
                               end
                               if (m_pkt.smi_conc_msg_class == eConcMsgDtrReq) aiu_dtr_req_chi_type = eMsgDTR'(m_pkt.smi_msg_type);
                               aiu_smi_req_src_id = smi_ncore_unit_id_bit_t'(m_pkt.smi_src_ncore_unit_id);
                               aiu_smi_req_trgt_id = smi_ncore_unit_id_bit_t'(m_pkt.smi_targ_ncore_unit_id);
                               if (m_pkt.smi_conc_msg_class == eConcMsgSysReq) begin
                                   //chiaiu_sends_sysreq_event = eMsgSysReq'(SYS_REQ);
                                   chiaiu_sends_sysreq_event_bit = 1;
                                   `uvm_info("Fsys_smi_coverage::cg_smi",$psprintf("Getting chiaiu_sends_sysreq_event_bit coverpoint hit"),UVM_HIGH)
                                   cg_smi.sample();
                                   chiaiu_sends_sysreq_event_bit = 0; // Setting 0 to avoid false hit
                               end                                
                               if (m_pkt.smi_conc_msg_class == eConcMsgSysRsp) begin
                                   //chiaiu_sends_sysrsp =  eMsgSysRsp'(SYS_RSP);
                                   chiaiu_sends_sysrsp_bit =  1;
                                   `uvm_info("Fsys_smi_coverage::cg_smi",$psprintf("Getting chiaiu_sends_sysrsp_bit coverpoint hit"),UVM_HIGH)
                                   cg_smi.sample();
                                   chiaiu_sends_sysrsp_bit =  0; // Setting 0 to avoid false hit
                               end
                                if (m_pkt.smi_conc_msg_class == eConcMsgSnpRsp) begin
                               <% if ((numAceLiteE && numChiAiu) || (numChiAiu>=2)) { // stash mini: 1 ACELITE+1CHI or 2 CHI%>
                                   int find_q[$]; 
                                   find_q = <%=_child_blkid[pidx]%>_stash_snp_req_msg_id_q.find_first_index() with (item == m_pkt.smi_rmsg_id); 
                                   if (find_q.size()) begin
                                   <%=_child_blkid[pidx]%>_stash_snp_req_type = <%=_child_blkid[pidx]%>_stash_snp_req_type_q[find_q[0]];
                                   <%=_child_blkid[pidx]%>_snp_rsp_snarf = m_pkt.smi_cmstatus_snarf;
                                   <%=_child_blkid[pidx]%>_stash_snp_req_type_q.delete(find_q[0]);
                                   <%=_child_blkid[pidx]%>_stash_snp_req_msg_id_q.delete(find_q[0]);
                                   cg_snp_stash.sample();
                                   end
                                <%}%>
                               end
                               end
            ncoreConfigInfo::DCE: begin
                               dce_smi_req_src_id = smi_ncore_unit_id_bit_t'(m_pkt.smi_src_ncore_unit_id);
                               dce_smi_req_trgt_id = smi_ncore_unit_id_bit_t'(m_pkt.smi_targ_ncore_unit_id);
                               if (m_pkt.smi_conc_msg_class == eConcMsgSnpReq) begin
                                  <% if ((numAceLiteE && numChiAiu) || (numChiAiu>=2)) { // stash mini: 1 ACELITE+1CHI or 2 CHI%>
                                   if (m_pkt.smi_msg_type inside {eSnpInvStsh,eSnpUnqStsh,eSnpStshShd,eSnpStshUnq}) begin
                                     <%=_child_blkid[pidx]%>_stash_snp_req_type_q.push_back(eMsgSNP'(m_pkt.smi_msg_type));
                                     <%=_child_blkid[pidx]%>_stash_snp_req_msg_id_q.push_back(m_pkt.smi_msg_id);
                                   end
                                  <%}%>
                                  dce_snp_req_chi_type = eMsgSNP'(m_pkt.smi_msg_type);
                                  chi_smi_snp_up = smi_up_enum_t'(m_pkt.smi_up);
                                  dce_smi_snp_up = smi_up_enum_t'(m_pkt.smi_up);
                                  cg_sharerpromotion.sample();
                               end
                               end
            ncoreConfigInfo::DVE: begin
                               dve_smi_req_src_id = smi_ncore_unit_id_bit_t'(m_pkt.smi_src_ncore_unit_id);
                               dve_smi_req_trgt_id = smi_ncore_unit_id_bit_t'(m_pkt.smi_targ_ncore_unit_id);
                               end    
        endcase
        case (ncoreConfigInfo::get_unit_type(m_pkt.smi_targ_ncore_unit_id))
            ncoreConfigInfo::DMI: begin
                               if (m_pkt.smi_conc_msg_class == eConcMsgDtwReq) begin
                                  chi_dtw_req_dmi_type = eMsgDTW'(m_pkt.smi_msg_type);
                                  chi_dtwmrg_req_dmi_type = eMsgDTWMrgMRD'(m_pkt.smi_msg_type);
                               end
                              end
            ncoreConfigInfo::DII: begin
                               if (m_pkt.smi_conc_msg_class == eConcMsgDtwReq)  chi_dtw_req_dii_type = eMsgDTW'(m_pkt.smi_msg_type);
                               if (m_pkt.smi_conc_msg_class == eConcMsgCmdReq)  chi_dii_cmd_req_type = eMsgCMD'(m_pkt.smi_msg_type);
                               end
        endcase
        <%}%>
        <%  if(_child_blk[pidx].match('ioaiu')) { %>
        case (ncoreConfigInfo::get_unit_type(m_pkt.smi_src_ncore_unit_id))
            ncoreConfigInfo::DMI: begin
                               if (m_pkt.smi_conc_msg_class == eConcMsgDtrReq) dmi_dtr_req_ioaiu_type = eMsgDTR'(m_pkt.smi_msg_type);
                               dmi_smi_req_src_id = smi_ncore_unit_id_bit_t'(m_pkt.smi_src_ncore_unit_id);
                               dmi_smi_req_trgt_id = smi_ncore_unit_id_bit_t'(m_pkt.smi_targ_ncore_unit_id);
                               end
            ncoreConfigInfo::DII: begin
                               if (m_pkt.smi_conc_msg_class == eConcMsgDtrReq) dii_dtr_req_ioaiu_type = eMsgDTR'(m_pkt.smi_msg_type);
                               dii_smi_req_src_id = smi_ncore_unit_id_bit_t'(m_pkt.smi_src_ncore_unit_id);
                               dii_smi_req_trgt_id = smi_ncore_unit_id_bit_t'(m_pkt.smi_targ_ncore_unit_id);
                              end
            ncoreConfigInfo::DCE: begin
                               dce_smi_req_src_id = smi_ncore_unit_id_bit_t'(m_pkt.smi_src_ncore_unit_id);
                               dce_smi_req_trgt_id = smi_ncore_unit_id_bit_t'(m_pkt.smi_targ_ncore_unit_id);
                               if (m_pkt.smi_conc_msg_class == eConcMsgSnpReq) begin
                                   dce_snp_req_ioaiu_type = eMsgSNP'(m_pkt.smi_msg_type);
                          <%if((_child[pidx].fnNativeInterface == 'AXI4') || (_child[pidx].fnNativeInterface == 'AXI5') || (_child[pidx].fnNativeInterface == 'ACE-LITE')) {%>
                             <%if(_child[pidx].orderedWriteObservation==true) {%>
                              <%if(_child[pidx].fnNativeInterface == 'AXI4' || _child[pidx].fnNativeInterface == 'AXI5') {%>
                                   dce_snp_req_ioaiu_owo_axi_type = eMsgSNP'(m_pkt.smi_msg_type);
                              <%} else {%>
                                   dce_snp_req_ioaiu_owo_AceLite_type = eMsgSNP'(m_pkt.smi_msg_type);
                              <%}%>
                             <%}%>
                          <%}%>

                                   // test:<%=pidx%> <%=_child[pidx].fnNativeInterface%>
                                   <%if(_child[pidx].fnNativeInterface == 'ACE5' ||_child[pidx].fnNativeInterface == 'ACE') { %>
                                   dce_snp_req_ace_type = eMsgSNP'(m_pkt.smi_msg_type);
                                   ace_smi_snp_up = smi_up_enum_t'(m_pkt.smi_up);
                                   <%}%>
                                   <%if((_child[pidx].fnNativeInterface == 'AXI4' && _child[pidx].useCache) || (_child[pidx].fnNativeInterface == 'AXI5' && _child[pidx].useCache)) { %>
                                   dce_snp_req_axi5_axi4PC_type = eMsgSNP'(m_pkt.smi_msg_type);
                                   ncaiu_with_cache_smi_snp_up = smi_up_enum_t'(m_pkt.smi_up);
                                   <%}%>
                                   dce_smi_snp_up = smi_up_enum_t'(m_pkt.smi_up);
                                   cg_sharerpromotion.sample();
                               end
                               end
            ncoreConfigInfo::AIU: begin
                               if (m_pkt.smi_conc_msg_class == eConcMsgCmdReq) begin
                                    ioaiu_cmd_req_type =eMsgCMD'(m_pkt.smi_msg_type);
                                    <% if (((numAceLiteE && numChiAiu) || (numChiAiu>=2)) && (_child[pidx].fnNativeInterface == "ACELITE-E")) { // stash mini: 1 ACELITE+1CHI or 2 CHI%>
                                      <%=_child_blkid[pidx]%>_stash_cmd_req_type =eMsgCMD'(m_pkt.smi_msg_type);
                                      if (m_pkt.smi_mpf1_stash_valid) <%=_child_blkid[pidx]%>_stash_target= int'(m_pkt.smi_mpf1_stash_nid);
                                      cg_stash.sample();
                                    <%}%>
                                    <%if((_child[pidx].fnNativeInterface == 'AXI4') || (_child[pidx].fnNativeInterface == 'AXI5') || (_child[pidx].fnNativeInterface == 'ACE-LITE') || (_child[pidx].fnNativeInterface == 'ACELITE-E')) {%>
                                       <%if(_child[pidx].orderedWriteObservation==true) {%>
                                        <%if(_child[pidx].fnNativeInterface == 'AXI4' || _child[pidx].fnNativeInterface == 'AXI5') {%>
                                    ioaiu_owo_axi_cmd_req_type=eMsgCMD'(m_pkt.smi_msg_type);
                                        <% } else if(_child[pidx].fnNativeInterface == 'ACELITE-E') {%>
                                    ioaiu_owo_Ace5Lite_cmd_req_type=eMsgCMD'(m_pkt.smi_msg_type);
                                        <%} else {%>
                                    ioaiu_owo_AceLite_cmd_req_type=eMsgCMD'(m_pkt.smi_msg_type);
                                        <%}%>
                                       <%}%>
                                    <%}%>
                               end
                               if (m_pkt.smi_conc_msg_class == eConcMsgDtrReq) aiu_dtr_req_ioaiu_type = eMsgDTR'(m_pkt.smi_msg_type);
                               aiu_smi_req_src_id = smi_ncore_unit_id_bit_t'(m_pkt.smi_src_ncore_unit_id);
                               aiu_smi_req_trgt_id = smi_ncore_unit_id_bit_t'(m_pkt.smi_targ_ncore_unit_id);
                               if (m_pkt.smi_conc_msg_class == eConcMsgSysReq) begin
                                   //ioaiu_sends_sysreq_event = eMsgSysReq'(SYS_REQ);
                                   ioaiu_sends_sysreq_event_bit = 1;
                                   `uvm_info("Fsys_smi_coverage::cg_smi",$psprintf("Getting ioaiu_sends_sysreq_event_bit coverpoint hit"),UVM_HIGH)
                                   cg_smi.sample();
                                   ioaiu_sends_sysreq_event_bit = 0; // Setting 0 to avoid false hit
                                <%if((_child[pidx].fnNativeInterface == 'AXI4') || (_child[pidx].fnNativeInterface == 'AXI5') || (_child[pidx].fnNativeInterface == 'ACE-LITE')) {%>
                                   <%if(_child[pidx].orderedWriteObservation==true) {%>
                                    <%if(_child[pidx].fnNativeInterface == 'AXI4' || _child[pidx].fnNativeInterface == 'AXI5') {%>
                                   ioaiu_owo_axi_sends_sysreq_event_bit= 1;
                                   `uvm_info("Fsys_smi_coverage::cg_smi",$psprintf("Getting ioaiu_owo_axi_sends_sysreq_event_bit coverpoint hit"),UVM_HIGH)
                                   cg_smi.sample();
                                   ioaiu_owo_axi_sends_sysreq_event_bit= 0; // Setting 0 to avoid false hit
                                    <%} else {%>
                                   ioaiu_owo_AceLite_sends_sysreq_event_bit= 1;
                                   `uvm_info("Fsys_smi_coverage::cg_smi",$psprintf("Getting ioaiu_owo_AceLite_sends_sysreq_event_bit coverpoint hit"),UVM_HIGH)
                                   cg_smi.sample();
                                   ioaiu_owo_AceLite_sends_sysreq_event_bit= 0; // Setting 0 to avoid false hit
                                    <%}%>
                                   <%}%>
                                <%}%>
                               end                               
                               if (m_pkt.smi_conc_msg_class == eConcMsgSysRsp) begin
                                   //ioaiu_sends_sysrsp =  eMsgSysRsp'(SYS_RSP);
                                   ioaiu_sends_sysrsp_bit =  1;
                                   `uvm_info("Fsys_smi_coverage::cg_smi",$psprintf("Getting ioaiu_sends_sysrsp_bit coverpoint hit"),UVM_HIGH)
                                   cg_smi.sample();
                                   ioaiu_sends_sysrsp_bit =  0; // Setting 0 to avoid false hit
                               end
                               <%if((_child[pidx].fnNativeInterface == 'AXI4' && _child[pidx].useCache) || (_child[pidx].fnNativeInterface == 'AXI5' && _child[pidx].useCache)) { %>
                               if (m_pkt.smi_conc_msg_class == eConcMsgUpdReq) ioaiu_upd_axi5_axi4pc_req_type = eMsgUPD'(m_pkt.smi_msg_type);
                               <%}%>
                               end
        endcase
        case (ncoreConfigInfo::get_unit_type(m_pkt.smi_targ_ncore_unit_id))
            ncoreConfigInfo::DMI: begin
                               if (m_pkt.smi_conc_msg_class == eConcMsgDtwReq) begin
                                  ioaiu_dtw_req_dmi_type = eMsgDTW'(m_pkt.smi_msg_type);
                                  ioaiu_dtwmrg_req_dmi_type = eMsgDTWMrgMRD'(m_pkt.smi_msg_type);
                                end
                              end
            ncoreConfigInfo::DII: begin
                               if (m_pkt.smi_conc_msg_class == eConcMsgDtwReq) ioaiu_dtw_req_dii_type = eMsgDTW'(m_pkt.smi_msg_type);
                               if (m_pkt.smi_conc_msg_class == eConcMsgCmdReq) ioaiu_dii_cmd_req_type = eMsgCMD'(m_pkt.smi_msg_type);
                               end       
            ncoreConfigInfo::DCE: begin
                               if (m_pkt.smi_conc_msg_class == eConcMsgUpdReq) ioaiu_upd_req_type = eMsgUPD'(m_pkt.smi_msg_type);
                               end
        endcase
        <%}%>
        <%  if(_child_blk[pidx].match('dce')) { %>
        case (ncoreConfigInfo::get_unit_type(m_pkt.smi_src_ncore_unit_id))
            ncoreConfigInfo::DCE: begin
                               dce_smi_req_src_id = smi_ncore_unit_id_bit_t'(m_pkt.smi_src_ncore_unit_id);
                               dce_smi_req_trgt_id = smi_ncore_unit_id_bit_t'(m_pkt.smi_targ_ncore_unit_id);
                               if (m_pkt.smi_conc_msg_class == eConcMsgSysReq) begin
                                   //DCE_sends_sysreq_event = eMsgSysReq'(SYS_REQ);
                                   DCE_sends_sysreq_event_bit = 1;
                                   `uvm_info("Fsys_smi_coverage::cg_smi",$psprintf("Getting DCE_sends_sysreq_event_bit coverpoint hit"),UVM_HIGH)
                                   cg_smi.sample();
                                   DCE_sends_sysreq_event_bit = 0; // Setting 0 to avoid false hit
                               end
            end
            ncoreConfigInfo::DMI: begin
                               dmi_smi_req_src_id = smi_ncore_unit_id_bit_t'(m_pkt.smi_src_ncore_unit_id);
                               dmi_smi_req_trgt_id = smi_ncore_unit_id_bit_t'(m_pkt.smi_targ_ncore_unit_id);
            end
        endcase
        if (ncoreConfigInfo::get_unit_type(m_pkt.smi_targ_ncore_unit_id) == ncoreConfigInfo::DMI)begin
                               if (m_pkt.smi_conc_msg_class == eConcMsgRbReq || m_pkt.smi_conc_msg_class == eConcMsgRbUseReq)
                                   dce_rbr_req_type = eMsgRBReq'(m_pkt.smi_msg_type);
                               if (m_pkt.smi_conc_msg_class == eConcMsgMrdReq) dce_mrd_req_type = eMsgMRD'(m_pkt.smi_msg_type);
           end
        if (ncoreConfigInfo::get_unit_type(m_pkt.smi_targ_ncore_unit_id) == ncoreConfigInfo::AIU && m_pkt.smi_conc_msg_class == eConcMsgSnpReq )begin
                               dce_smi_snp_up = smi_up_enum_t'(m_pkt.smi_up);
                               cg_sharerpromotion.sample();
           end
        <%}%>
        <%  if(_child_blk[pidx].match('dmi')) { %>
        if (ncoreConfigInfo::get_unit_type(m_pkt.smi_src_ncore_unit_id) == ncoreConfigInfo::DMI)begin
                               dmi_smi_req_src_id = smi_ncore_unit_id_bit_t'(m_pkt.smi_src_ncore_unit_id);
                               dmi_smi_req_trgt_id = smi_ncore_unit_id_bit_t'(m_pkt.smi_targ_ncore_unit_id);
                               <% if (obj.DmiInfo[0].nExclusiveEntries  > 0) { %>
                                if (m_pkt.smi_conc_msg_class == eConcMsgSysReq) begin
                                   //DMI_sends_sysreq_event = eMsgSysReq'(SYS_REQ);
                                   DMI_sends_sysreq_event_bit = 1;
                                   `uvm_info("Fsys_smi_coverage::cg_smi",$psprintf("Getting DMI_sends_sysreq_event_bit coverpoint hit"),UVM_HIGH)
                                   cg_smi.sample();
                                   DMI_sends_sysreq_event_bit = 0; // Setting 0 to avoid false hit
                               end  
                                <%}%>                            
                               <% if (obj.nDMIs>0 && obj.DmiInfo[0].useCmc && obj.DmiInfo[0].ccpParams.useScratchpad){ %>
                                // #cover.FSYS.DMI.ScratchPad.ApAddr
                                 if(cl_aligned(m_pkt.smi_addr)      == (cl_aligned(k_sp_base_addr_p))) CovDmiSpAddr = sp_base_addr_lower;
                                 if(cl_aligned(m_pkt.smi_addr) == (cl_aligned(k_sp_base_addr_p)))   CovDmiSpAddr = sp_base_addr;
                                 if(cl_aligned(m_pkt.smi_addr) == (cl_aligned(k_sp_base_addr_p)))   CovDmiSpAddr = sp_base_addr_high;
                                 if(cl_aligned(m_pkt.smi_addr) == (cl_aligned(k_sp_max_addr)))      CovDmiSpAddr = sp_max_addr_lower;
                                 if(cl_aligned(m_pkt.smi_addr) == (cl_aligned(k_sp_max_addr)))      CovDmiSpAddr = sp_max_addr;
                                 if(cl_aligned(m_pkt.smi_addr) == (cl_aligned(k_sp_max_addr)))      CovDmiSpAddr = sp_max_addr_high;
                                 else CovDmiSpAddr = ignore7;
                                 cg_smi.sample();
                                <%}%>                            
           end
        <%}%>
        <%  if(_child_blk[pidx].match('dii')) { %>
        if (ncoreConfigInfo::get_unit_type(m_pkt.smi_src_ncore_unit_id) == ncoreConfigInfo::DII)begin
                               dii_smi_req_src_id = smi_ncore_unit_id_bit_t'(m_pkt.smi_src_ncore_unit_id);
                               dii_smi_req_trgt_id = smi_ncore_unit_id_bit_t'(m_pkt.smi_targ_ncore_unit_id);
                               <% if (obj.DiiInfo[0].nExclusiveEntries  > 0) { %>
                                if (m_pkt.smi_conc_msg_class == eConcMsgSysReq) begin
                                   //DII_sends_sysreq_event = eMsgSysReq'(SYS_REQ);
                                   DII_sends_sysreq_event_bit = 1;
                                   `uvm_info("Fsys_smi_coverage::cg_smi",$psprintf("Getting DII_sends_sysreq_event_bit coverpoint hit"),UVM_HIGH)
                                   cg_smi.sample();
                                   DII_sends_sysreq_event_bit = 0; // Setting 0 to avoid false hit
                               end        
                               <%}%>                        
           end
        <%}%>
        <%  if(_child_blk[pidx].match('dve')) { %>
        if (ncoreConfigInfo::get_unit_type(m_pkt.smi_src_ncore_unit_id) == ncoreConfigInfo::DVE)begin
                               dve_smi_req_trgt_id = smi_ncore_unit_id_bit_t'(m_pkt.smi_targ_ncore_unit_id);
                               dve_smi_req_src_id = smi_ncore_unit_id_bit_t'(m_pkt.smi_src_ncore_unit_id);
                                if (m_pkt.smi_conc_msg_class == eConcMsgSysReq) begin
                                   //DVE_sends_sysreq_event = eMsgSysReq'(SYS_REQ);
                                   DVE_sends_sysreq_event_bit = 1;
                                   `uvm_info("Fsys_smi_coverage::cg_smi",$psprintf("Getting DVE_sends_sysreq_event_bit coverpoint hit"),UVM_HIGH)
                                   cg_smi.sample();
                                   DVE_sends_sysreq_event_bit = 0; // Setting 0 to avoid false hit
                               end                                                               
                                if (m_pkt.smi_conc_msg_class == eConcMsgSysRsp) begin
                                   //DVE_sends_sysrsp_event = eMsgSysReq'(SYS_RSP);
                                   DVE_sends_sysrsp_event_bit = 1;
                                   `uvm_info("Fsys_smi_coverage::cg_smi",$psprintf("Getting DVE_sends_sysrsp_event_bit coverpoint hit"),UVM_HIGH)
                                   cg_smi.sample();
                                   DVE_sends_sysrsp_event_bit = 0; // Setting 0 to avoid false hit
                               end                                                               
           end
        <%}%>
        cg_connectivity.sample();
        cg_smi.sample();
    end
endfunction:collect_item_<%=_child_blkid[pidx]%>
<% }%>
