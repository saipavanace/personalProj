////////////////////////////////////////////////////////////////////////////////
//
// fsys_native_itf_coverage 
// Author: Cyrille LUDWIG
//
////////////////////////////////////////////////////////////////////////////////
<%
//Embedded javascript code to figure number of blocks
   var _child_blkid = [];
   var _child_blk   = [];
   var _child   = [{}];
   var _child_blk_nCore = [];
   var chi_idx = -1;
   var pidx = 0;
   var dmi_useAtomic =0;
   var qidx = 0;
   var idx  = 0;
   var ridx = 0;
   var initiatorAgents = obj.AiuInfo.length ;
   var numChiAiu         = 0;
   var numIoAiu          = 0;
   var numAce          = 0;
   var numAce5          = 0;
   var numAceLite     = 0;
   var numAceLiteE     = 0;
   var num_AXI5_AXI4 = 0;
   var num_AXI5_atomic = 0;
   var num_AXI5_with_owo = 0;
   var num_AXI5_with_owo_512b = 0;
   var num_AXI5_with_owo_256b = 0;
   var numAceLite_with_owo = 0;
   var numAceLite_with_owo_512b = 0;
   var numAceLite_with_owo_256b = 0;
   var numAce5Lite_with_owo = 0;
   var numAce5Lite_with_owo_512b = 0;
   var numAce5Lite_with_owo_256b = 0;
   var chi_a_present    = 0;
   var chi_b_present    = 0;
   var chi_e_present    = 0;
   var wdata64     = 0;
   var wdata128    = 0;
   var wdata256    = 0;
   var wdata512    = 0;
   var DVMV8_4=(obj.DveInfo[0].DVMVersionSupport==132)?1:0;
   var DVMV8_1=(obj.DveInfo[0].DVMVersionSupport==129)?1:0;
   var DVMV8_0=(obj.DveInfo[0].DVMVersionSupport==128)?1:0;
   let computedAxiInt;

   for(pidx = 0; pidx < obj.nAIUs; pidx++) {
       if((obj.AiuInfo[pidx].fnNativeInterface == 'CHI-A')||(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-B')||(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-E')) {
       _child_blkid[pidx] = 'chiaiu' + idx;
       _child_blk[pidx]   = 'chiaiu';
       numChiAiu = numChiAiu + 1;
       if (chi_idx == -1) chi_idx= pidx;  // capture the first CHI index
       if((obj.AiuInfo[pidx].fnNativeInterface == 'CHI-A')) chi_a_present = 1;
       if((obj.AiuInfo[pidx].fnNativeInterface == 'CHI-B')) chi_b_present = 1;
       if((obj.AiuInfo[pidx].fnNativeInterface == 'CHI-E')) chi_e_present = 1;

       idx++;
       } else {
       if(obj.AiuInfo[pidx].fnNativeInterface == 'ACE5'||obj.AiuInfo[pidx].fnNativeInterface == 'ACE') { 
           numAce++; 
           if(obj.AiuInfo[pidx].fnNativeInterface.match("ACE5")) {
               numAce5++; 
           }
       }
       if(obj.AiuInfo[pidx].fnNativeInterface == 'ACE-LITE') { 
           numAceLite++; 
           if(obj.AiuInfo[pidx].orderedWriteObservation==true) { 
               numAceLite_with_owo = numAceLite_with_owo + 1;
               if(obj.AiuInfo[pidx].wData==512) { 
                   numAceLite_with_owo_512b = numAceLite_with_owo_512b + 1;
               }
               if(obj.AiuInfo[pidx].wData==256) { 
                   numAceLite_with_owo_256b = numAceLite_with_owo_256b + 1;
               }
           }
       }
       if((obj.AiuInfo[pidx].fnNativeInterface == 'AXI4') || (obj.AiuInfo[pidx].fnNativeInterface == 'AXI5')) { 
           num_AXI5_AXI4++; 
           if(Array.isArray(obj.AiuInfo[pidx].interfaces.axiInt)){
               computedAxiInt = obj.AiuInfo[pidx].interfaces.axiInt[0];
           }else{
               computedAxiInt = obj.AiuInfo[pidx].interfaces.axiInt;
           }
           if(obj.AiuInfo[pidx].fnNativeInterface.match("AXI5") && (computedAxiInt.params.atomicTransactions==true) && (obj.AiuInfo[pidx].orderedWriteObservation==false)) {
               num_AXI5_atomic = num_AXI5_atomic + 1;
           }
           if(obj.AiuInfo[pidx].orderedWriteObservation==true) { 
               num_AXI5_with_owo = num_AXI5_with_owo + 1;
               if(obj.AiuInfo[pidx].wData==512) { 
                   num_AXI5_with_owo_512b = num_AXI5_with_owo_512b + 1;
               }
               if(obj.AiuInfo[pidx].wData==256) { 
                   num_AXI5_with_owo_256b = num_AXI5_with_owo_256b + 1;
               }
           }
       }

       if(obj.AiuInfo[pidx].fnNativeInterface == 'ACELITE-E') { 
           numAceLiteE++;
           if(obj.AiuInfo[pidx].orderedWriteObservation==true) { 
               numAce5Lite_with_owo = numAce5Lite_with_owo + 1;
               if(obj.AiuInfo[pidx].wData==512) { 
                   numAce5Lite_with_owo_512b = numAce5Lite_with_owo_512b + 1;
               }
               if(obj.AiuInfo[pidx].wData==256) { 
                   numAce5Lite_with_owo_256b = numAce5Lite_with_owo_256b + 1;
               }
           }
       }
       if((obj.AiuInfo[pidx].fnNativeInterface == 'ACELITE-E') || (num_AXI5_with_owo>0) || (numAceLite_with_owo>0) || (numAce5Lite_with_owo>0) || (num_AXI5_atomic>0)) {
            if(obj.AiuInfo[pidx].wData == 64)  {wdata64=1; }  
            if(obj.AiuInfo[pidx].wData == 128) {wdata128=1; } 
            if(obj.AiuInfo[pidx].wData == 256) {wdata256=1; } 
          if((num_AXI5_with_owo>0) || (numAceLite_with_owo>0) || (numAce5Lite_with_owo>0)) {
            if(obj.AiuInfo[pidx].wData == 512) {wdata512=1; } 
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
       _child[ridx]  = obj.DceInfo[pidx];
   }
   start_nDMIS=ridx;
   for(pidx =  0; pidx < obj.nDMIs; pidx++) {
       ridx = pidx + obj.nAIUs + obj.nDCEs;
       _child_blkid[ridx] = 'dmi' + pidx;
       _child_blk[ridx]   = 'dmi';
       if (obj.DmiInfo[pidx].useAtomic) { dmi_useAtomic=1; }
       _child[ridx]  = obj.DmiInfo[pidx];
   }
   start_nDIIS=ridx;
   for(pidx = 0; pidx < obj.nDIIs; pidx++) {
       ridx = pidx + obj.nAIUs + obj.nDCEs + obj.nDMIs;
       _child_blkid[ridx] = 'dii' + pidx;
       _child_blk[ridx]   = 'dii';
       _child[ridx]  = obj.DiiInfo[pidx];
   }
   start_nDVES=ridx;
   for(pidx = 0; pidx < obj.nDVEs; pidx++) {
       ridx = pidx + obj.nAIUs + obj.nDCEs + obj.nDMIs + obj.nDIIs;
       _child_blkid[ridx] = 'dve' + pidx;
       _child_blk[ridx]   = 'dve';
       _child[ridx]  = obj.DveInfo[pidx];
   }
   var nALLs = ridx+1;
%>

// numAce=<%=numAce%>
// numAceLiteE=<%=numAceLiteE%>
// numAceLite=<%=numAceLite%>

class Fsys_native_itf_coverage extends Fsys_base_coverage;
                                                        
/////////////////////////////////////////////////////////////////////////////////////
//     ##   ##### ##### #####  # #####  #    # #####  ####  
//    #  #    #     #   #    # # #    # #    #   #   #      
//   #    #   #     #   #    # # #####  #    #   #    ####  
//   ######   #     #   #####  # #    # #    #   #        # 
//   #    #   #     #   #   #  # #    # #    #   #   #    # 
//   #    #   #     #   #    # # #####   ####    #    ####  
/////////////////////////////////////////////////////////////////////////////////////
                                                          
    typedef enum {axi_ace_wdata_64, axi_ace_wdata_128, axi_ace_wdata_256, axi_ace_wdata_512} axi_ace_wdata_enum;                                                         
    typedef enum {Axi5_Axi4_Write, Axi5_Axi4_Read, Ace_WrNoSnoop, Ace_RdNoSnoop, Ace_WrUnique, Ace_RdOnce} CONC_11133_Cov_axi_ace_wr_rd_opcodes_enum; 
    typedef enum {chi_wdata_128, chi_wdata_256} chi_wdata_enum;                                                         
    typedef enum {WrNoSnoop,RdNoSnoop,WrUnique,RdOnce} CONC_11133_Cov_chi_wr_rd_opcodes_enum;
    typedef enum {CHI_ATOMICSTORE_STADD,CHI_ATOMICSTORE_STCLR,CHI_ATOMICSTORE_STEOR,CHI_ATOMICSTORE_STSET,CHI_ATOMICSTORE_STSMAX,CHI_ATOMICSTORE_STMIN,CHI_ATOMICSTORE_STUSMAX,CHI_ATOMICSTORE_STUMIN,
                  CHI_ATOMICLOAD_LDADD ,CHI_ATOMICLOAD_LDCLR,CHI_ATOMICLOAD_LDEOR,CHI_ATOMICLOAD_LDSET,CHI_ATOMICLOAD_LDSMAX,CHI_ATOMICLOAD_LDMIN ,CHI_ATOMICLOAD_LDUSMAX,CHI_ATOMICLOAD_LDUMIN,
                  CHI_ATOMICSWAP,
                  CHI_ATOMICCOMPARE} CONC_11504_Cov_chi_atomic_opcodes_enum;
    const bit DVMV8_4 = <%=DVMV8_4%>;
    const bit DVMV8_1 = <%=DVMV8_1%>;
    const bit DVMV8_0 = <%=DVMV8_0%>;
    bit sample_dvm_func_cov = 0;
    <% if (numIoAiu) {%>
    bit ioaiu_dvm_two_part_msg[<%=numIoAiu%>], ioaiu_snp_dvm_two_part_msg[<%=numIoAiu%>];
    bit [1:0]ioaiu_dvm_part_num[<%=numIoAiu%>];
    bit [1:0]ioaiu_snp_dvm_part_num[<%=numIoAiu%>];
    <% } %>
    // CHI TODO
      <% if (numChiAiu) {%>
    <% if(DVMV8_0) {%>
     bit chiaiu_captured_cmd_req_dvmV80;
     bit chiaiu_captured_snp_req_dvmV80;
    <% } %>
    <% if(DVMV8_1) {%>
     bit chiaiu_captured_cmd_req_dvmV81;
     bit chiaiu_captured_snp_req_dvmV81;
    <% } %>
    <% if(DVMV8_4) {%>
     bit chiaiu_captured_cmd_req_dvmV84;
     bit chiaiu_captured_snp_req_dvmV84;
     bit [4:0] chiaiu_cmd_req_dvm_field_num;
     bit       chiaiu_cmd_req_dvm_field_range;
     bit [1:0] chiaiu_cmd_req_dvm_field_scale;
     bit [4:0] chiaiu_snp_req_dvm_field_num;
     bit       chiaiu_snp_req_dvm_field_range;
     bit [1:0] chiaiu_snp_req_dvm_field_scale;
    <% } %>
    <% if(DVMV8_1 || DVMV8_4) {%>
     bit [7:0] chiaiu_cmd_req_dvm_field_vmidext;
     bit [7:0] chiaiu_snp_req_dvm_field_vmidext;
    <% } %>
     <%=_child_blkid[chi_idx]%>_env_pkg::chi_req_opcode_enum_t chi_cmd_req_type; 
     <%=_child_blkid[chi_idx]%>_chi_agent_pkg::chi_req_size_t chi_req_size; 
     bit [2:0] chi_addr_critical_dword;
     chi_wdata_enum chi_wdata;
     CONC_11133_Cov_chi_wr_rd_opcodes_enum CONC_11133_Cov_chi_wr_rd_opcodes;
     CONC_11504_Cov_chi_atomic_opcodes_enum CONC_11504_Cov_chi_atomic_opcodes;
     <%=_child_blkid[chi_idx]%>_chi_agent_pkg::chi_rsp_resperr_t chi_snp_sresp_resperr;
     <%=_child_blkid[chi_idx]%>_chi_agent_pkg::chi_rsp_resperr_t chi_snp_wdat_resperr;
     <%=_child_blkid[chi_idx]%>_chi_agent_pkg::chi_rsp_resperr_t chi_cresperr;
     <%=_child_blkid[chi_idx]%>_chi_agent_pkg::chi_dat_resperr_t chi_data_resperr;
     <%} // numcChiAiu %> 
    // ACE ACE_LITE_E ACE_LITE 
     <% if (numAce || numAceLiteE  || numAceLite || (num_AXI5_AXI4>0)) {%>
     ace_command_types_enum_t ace_xxx_cmd_type;
     <% if (numAce  || numAceLiteE) {%>
     axi_acsnoop_enum_t ace_snp_type;
     axi_crresp_t ace_sresp;
     <% } //numAce > 0 %>
     <% } // numAceXXX > 0%>
     axi_bresp_enum_t dii_bresp;
     axi_bresp_enum_t dii_rresp;
     axi_bresp_enum_t dmi_bresp;
     axi_bresp_enum_t dmi_rresp;
     <% if (numIoAiu) {%>
    //#Cover.FSYS.Axlen
     int aiu_data_width;
     axi_ace_wdata_enum axi_ace_wdata;
     CONC_11133_Cov_axi_ace_wr_rd_opcodes_enum CONC_11133_Cov_axi_ace_wr_rd_opcodes,owo_Axi_wr_rd_opcodes,owo_Acelite_wr_rd_opcodes,owo_Ace5lite_wr_rd_opcodes;
     bit [2:0] axi_ace_awaddr_critical_dword,axi_ace_araddr_critical_dword;
     axi_axlen_t aiu_arlen;
    <% if(DVMV8_0) {%>
     bit ioaiu_captured_cmd_dvmV80;
     bit ioaiu_captured_snp_dvmV80;
    <% } %>
    <% if(DVMV8_1) {%>
     bit ioaiu_captured_cmd_dvmV81;
     bit ioaiu_captured_snp_dvmV81;
    <% } %>
    <% if(DVMV8_4) {%>
     bit ioaiu_captured_cmd_dvmV84;
     bit ioaiu_captured_snp_dvmV84;
     bit [4:0] ioaiu_cmd_dvm_field_num;
     bit       ioaiu_cmd_dvm_field_range;
     bit [1:0] ioaiu_cmd_dvm_field_scale;
     bit [4:0] ioaiu_snp_dvm_field_num;
     bit       ioaiu_snp_dvm_field_range;
     bit [1:0] ioaiu_snp_dvm_field_scale;
    <% } %>
    <% if(DVMV8_1 || DVMV8_4) {%>
     bit [7:0] ioaiu_cmd_dvm_field_vmidext;
     bit [7:0] ioaiu_snp_dvm_field_vmidext;
    <% } %>
     axi_axlen_t aiu_awlen;
     axi_axsize_t aiu_awsize;
     axi_axburst_t aiu_awburst;
     axi_axaddr_t aiu_awaddr;
     axi_bresp_enum_t aiu_bresp, owo_axi_aiu_bresp, owo_axi_AceLite_bresp, owo_axi_Ace5Lite_bresp;
     axi_bresp_enum_t aiu_rresp, owo_axi_aiu_rresp, owo_axi_AceLite_rresp, owo_axi_Ace5Lite_rresp;
     axi_arcache_enum_t  rd_policies;
     axi_awcache_enum_t  wr_policies;
     axi_axlock_enum_t   arlock;
     axi_axlock_enum_t   awlock;
     <% } //numIoAiu  %>
    
//#Cover.FSYS.MPU.axi_txn_eachcore   // TODO create a coverpoint
<%   for(pidx = 0; pidx < obj.nAIUs; pidx++) {%>
 <%if (!obj.AiuInfo[pidx].fnNativeInterface.includes("CHI")) {  // IO case%>
   <% if (_child_blk_nCore[pidx] >1) { // number of core > 1 %> 
       <%for (var c=0; c <_child_blk_nCore[pidx];c++)  {%>
         bit <%=_child_blkid[pidx]%>_c<%=c%>_txn = 0;
        <%} // foreach core%>
   <%} // if ncore >1 %>
<% } //no CHI  %>
<% } //nAIUs  %>

///////////////////////////////////////////////////////////////////////////////////
// ####   ####  #    # ###### #####   ####  #####   ####  #    # #####   ####  
//#    # #    # #    # #      #    # #    # #    # #    # #    # #    # #      
//#      #    # #    # #####  #    # #      #    # #    # #    # #    #  ####  
//#      #    # #    # #      #####  #  ### #####  #    # #    # #####       # 
//#    # #    #  #  #  #      #   #  #    # #   #  #    # #    # #      #    # 
// ####   ####    ##   ###### #    #  ####  #    #  ####   ####  #       ####  
///////////////////////////////////////////////////////////////////////////////////
// AIUs Commun covergroup 
    covergroup cg_native_itf_cmd;
        <% if (numChiAiu) {%>
        CovChiCmdReq:     coverpoint chi_cmd_req_type { //#Cover.FSYS.chi.native_opcode
            bins REQLCRDRETURN        = {'h00};
            bins READSHARED           = {'h01};
            bins READCLEAN            = {'h02};
            bins READONCE             = {'h03};
            bins READNOSNP            = {'h04};
            <% if(chi_e_present) { %>
            // bins PCRDRETURN           = {'h05};
            // // New opcode CHI-E below
            // bins READPREFERUNIQUE            ={'h4C};
            // bins MAKEREADUNIQUE              ={'h41};
            // bins CLEANSHAREDPERSISTSEP       ={'h13};
            // bins WRITEUNIQUEZERO             ={'h43};
            // bins WRITENOSNPZERO              ={'h44};
            // bins WRITENOSNPFULLCLEANSH       ={'h50};
            // bins WRITENOSNPFULLCLEANINV      ={'h51};
            // bins WRITENOSNPFULLCLEANSHPERSEP ={'h52};
            // bins WRITEBACKFULLCLEANSH        ={'h58};
            // bins WRITEBACKFULLCLEANINV       ={'h59};
            // bins WRITEBACKFULLCLEANSHPERSEP  ={'h5A};
            // bins WRITECLEANFULLCLEANSH       ={'h5C};
            // bins WRITECLEANFULLCLEANSHPERSEP ={'h5E};
            <% } %>
            ignore_bins RSVD_6        = {'h06};
            bins READUNIQUE           = {'h07};
            bins CLEANSHARED          = {'h08};
            bins CLEANINVALID         = {'h09};
            bins MAKEINVALID          = {'h0A};
            bins CLEANUNIQUE          = {'h0B};
            bins MAKEUNIQUE           = {'h0C};
            bins EVICT                = {'h0D};
            <% if(chi_a_present) { %>
            ignore_bins EOBARRIER     = {'h0E};
            ignore_bins ECBARRIER     = {'h0F};
            <% } %>
            ignore_bins RSVD_10_13    = {['h10 : 'h13]};
            bins DVMOP                = {'h14};
            bins WRITEEVICTFULL       = {'h15};
            <% if(chi_a_present) { %>
            bins WRITECLEANPTL        = {'h16};
            <% } %>
            bins WRITECLEANFULL       = {'h17};
            bins WRITEUNIQUEPTL       = {'h18};
            bins WRITEUNIQUEFULL      = {'h19};
            bins WRITEBACKPTL         = {'h1A};
            bins WRITEBACKFULL        = {'h1B};
            bins WRITENOSNPPTL        = {'h1C};
            bins WRITENOSNPFULL       = {'h1D};
            ignore_bins RSVD_1E_1F    = {['h1E : 'h1F]}; 
            <% if(chi_b_present || chi_e_present) { %>
            ignore_bins WRITEUNIQUEFULLSTASH = {'h20};
            ignore_bins WRITEUNIQUEPTLSTASH  = {'h21};
            bins STASHONCESHARED      = {'h22};
            bins STASHONCEUNIQUE      = {'h23};
            bins READONCECLEANINVALID = {'h24};
            bins READONCEMAKEINVALID  = {'h25};
            bins READNOTSHAREDDIRTY   = {'h26};
            bins CLEANSHAREDPERSIST   = {'h27};
            bins PREFETCHTARGET       = {'h3A};
            ignore_bins RSVD_3B_3F    = {['h3B : 'h3F]};
                <% if (!dmi_useAtomic) {%>                                                        
            ignore_bins ATOMICS       = {['h28:'h39]};
                <% } else { //dmi_useAtomic %>                                                      
            bins ATOMICSTORE[]            = {'h28,'h29,'h2A,'h2B,'h2C,'h2D,'h2E,'h2F};
            bins ATOMICLOAD[]             = {'h30,'h31,'h32,'h33,'h34,'h35,'h36,'h37};
            bins ATOMICSWAP             = {'h38};
            bins ATOMICCOMPARE          = {'h39};
                <% } %>                                                      
            <% } %>
            }
         
         Cov_CONC_11133_Chi_req_size :     coverpoint chi_req_size {
            bins size_0 = {0}; 
            bins size_1 = {1}; 
            bins size_2 = {2}; 
            bins size_3 = {3}; 
            bins size_4 = {4}; 
            bins size_5 = {5}; 
            bins size_6 = {6}; 
            ignore_bins Reserved = {7};  // Reserved=7
         }
         Cov_CONC_11133_Chi_addr_critical_dword : coverpoint chi_addr_critical_dword {
            bins crit_dw_0 = {0}; 
            bins crit_dw_1 = {1}; 
            bins crit_dw_2 = {2}; 
            bins crit_dw_3 = {3}; 
            bins crit_dw_4 = {4}; 
            bins crit_dw_5 = {5}; 
            bins crit_dw_6 = {6}; 
            bins crit_dw_7 = {7}; 
         }
         Cov_CONC_11133_Chi_wdata : coverpoint chi_wdata;
         Cov_CONC_11133_chi_opcodes : coverpoint CONC_11133_Cov_chi_wr_rd_opcodes {
            bins noncoh_opcode_wr = {WrNoSnoop};
            bins noncoh_opcode_rd = {RdNoSnoop};
            bins coh_opcode_wr = {WrUnique};
            bins coh_opcode_rd = {RdOnce};
         }
         Cross_Cov_CONC_11133_chi_wr_rd : cross Cov_CONC_11133_chi_opcodes , Cov_CONC_11133_Chi_wdata, Cov_CONC_11133_Chi_addr_critical_dword, Cov_CONC_11133_Chi_req_size {
             ignore_bins RdOnce_size_0 = binsof(Cov_CONC_11133_chi_opcodes.coh_opcode_rd) && binsof(Cov_CONC_11133_Chi_req_size.size_0);
             ignore_bins RdOnce_size_1 = binsof(Cov_CONC_11133_chi_opcodes.coh_opcode_rd) && binsof(Cov_CONC_11133_Chi_req_size.size_1);
             ignore_bins RdOnce_size_2 = binsof(Cov_CONC_11133_chi_opcodes.coh_opcode_rd) && binsof(Cov_CONC_11133_Chi_req_size.size_2);
             ignore_bins RdOnce_size_3 = binsof(Cov_CONC_11133_chi_opcodes.coh_opcode_rd) && binsof(Cov_CONC_11133_Chi_req_size.size_3);
             ignore_bins RdOnce_size_4 = binsof(Cov_CONC_11133_chi_opcodes.coh_opcode_rd) && binsof(Cov_CONC_11133_Chi_req_size.size_4);
             ignore_bins RdOnce_size_5 = binsof(Cov_CONC_11133_chi_opcodes.coh_opcode_rd) && binsof(Cov_CONC_11133_Chi_req_size.size_5);
         }

         Cov_CONC_11504_Cov_chi_atomic_opcodes      : coverpoint CONC_11504_Cov_chi_atomic_opcodes {
             bins bin_CHI_ATOMICSTORE_STADD            =  { CHI_ATOMICSTORE_STADD           };
             bins bin_CHI_ATOMICSTORE_STCLR            =  { CHI_ATOMICSTORE_STCLR           };
             bins bin_CHI_ATOMICSTORE_STEOR            =  { CHI_ATOMICSTORE_STEOR           };
             bins bin_CHI_ATOMICSTORE_STSET            =  { CHI_ATOMICSTORE_STSET           };
             bins bin_CHI_ATOMICSTORE_STSMAX           =  { CHI_ATOMICSTORE_STSMAX          };
             bins bin_CHI_ATOMICSTORE_STMIN            =  { CHI_ATOMICSTORE_STMIN           };
             bins bin_CHI_ATOMICSTORE_STUSMAX          =  { CHI_ATOMICSTORE_STUSMAX         };
             bins bin_CHI_ATOMICSTORE_STUMIN           =  { CHI_ATOMICSTORE_STUMIN          };
             bins bin_CHI_ATOMICLOAD_LDADD             =  { CHI_ATOMICLOAD_LDADD            };
             bins bin_CHI_ATOMICLOAD_LDCLR             =  { CHI_ATOMICLOAD_LDCLR            };
             bins bin_CHI_ATOMICLOAD_LDEOR             =  { CHI_ATOMICLOAD_LDEOR            };
             bins bin_CHI_ATOMICLOAD_LDSET             =  { CHI_ATOMICLOAD_LDSET            };
             bins bin_CHI_ATOMICLOAD_LDSMAX            =  { CHI_ATOMICLOAD_LDSMAX           };
             bins bin_CHI_ATOMICLOAD_LDMIN             =  { CHI_ATOMICLOAD_LDMIN            };
             bins bin_CHI_ATOMICLOAD_LDUSMAX           =  { CHI_ATOMICLOAD_LDUSMAX          };
             bins bin_CHI_ATOMICLOAD_LDUMIN            =  { CHI_ATOMICLOAD_LDUMIN           };
             bins bin_CHI_ATOMICSWAP                   =  { CHI_ATOMICSWAP                  };
             bins bin_CHI_ATOMICCOMPARE                =  { CHI_ATOMICCOMPARE               };
         }
         Cov_CONC_11504_Cov_chi_req_size     : coverpoint chi_req_size{
            bins size_0 = {0}; 
            bins size_1 = {1}; 
            bins size_2 = {2}; 
            bins size_3 = {3}; 
            bins size_4 = {4}; 
            bins size_5 = {5}; 
         }
         Cross_Cov_CONC_11504_chi_atomic : cross Cov_CONC_11504_Cov_chi_atomic_opcodes, Cov_CONC_11133_Chi_wdata, Cov_CONC_11133_Chi_addr_critical_dword, Cov_CONC_11504_Cov_chi_req_size {
             ignore_bins CHI_ATOMICSTORE_STADD_size_4       = binsof(Cov_CONC_11504_Cov_chi_atomic_opcodes.bin_CHI_ATOMICSTORE_STADD) && binsof(Cov_CONC_11504_Cov_chi_req_size.size_4);
             ignore_bins CHI_ATOMICSTORE_STCLR_size_4       = binsof(Cov_CONC_11504_Cov_chi_atomic_opcodes.bin_CHI_ATOMICSTORE_STCLR) && binsof(Cov_CONC_11504_Cov_chi_req_size.size_4);
             ignore_bins CHI_ATOMICSTORE_STEOR_size_4       = binsof(Cov_CONC_11504_Cov_chi_atomic_opcodes.bin_CHI_ATOMICSTORE_STEOR) && binsof(Cov_CONC_11504_Cov_chi_req_size.size_4);
             ignore_bins CHI_ATOMICSTORE_STSET_size_4       = binsof(Cov_CONC_11504_Cov_chi_atomic_opcodes.bin_CHI_ATOMICSTORE_STSET) && binsof(Cov_CONC_11504_Cov_chi_req_size.size_4);
             ignore_bins CHI_ATOMICSTORE_STSMAX_size_4      = binsof(Cov_CONC_11504_Cov_chi_atomic_opcodes.bin_CHI_ATOMICSTORE_STSMAX  ) && binsof(Cov_CONC_11504_Cov_chi_req_size.size_4);
             ignore_bins CHI_ATOMICSTORE_STMIN_size_4       = binsof(Cov_CONC_11504_Cov_chi_atomic_opcodes.bin_CHI_ATOMICSTORE_STMIN   ) && binsof(Cov_CONC_11504_Cov_chi_req_size.size_4);
             ignore_bins CHI_ATOMICSTORE_STUSMAX_size_4     = binsof(Cov_CONC_11504_Cov_chi_atomic_opcodes.bin_CHI_ATOMICSTORE_STUSMAX ) && binsof(Cov_CONC_11504_Cov_chi_req_size.size_4);
             ignore_bins CHI_ATOMICSTORE_STUMIN_size_4      = binsof(Cov_CONC_11504_Cov_chi_atomic_opcodes.bin_CHI_ATOMICSTORE_STUMIN  ) && binsof(Cov_CONC_11504_Cov_chi_req_size.size_4);
             ignore_bins CHI_ATOMICLOAD_LDADD_size_4        = binsof(Cov_CONC_11504_Cov_chi_atomic_opcodes.bin_CHI_ATOMICLOAD_LDADD    ) && binsof(Cov_CONC_11504_Cov_chi_req_size.size_4);
             ignore_bins CHI_ATOMICLOAD_LDCLR_size_4        = binsof(Cov_CONC_11504_Cov_chi_atomic_opcodes.bin_CHI_ATOMICLOAD_LDCLR    ) && binsof(Cov_CONC_11504_Cov_chi_req_size.size_4);
             ignore_bins CHI_ATOMICLOAD_LDEOR_size_4        = binsof(Cov_CONC_11504_Cov_chi_atomic_opcodes.bin_CHI_ATOMICLOAD_LDEOR    ) && binsof(Cov_CONC_11504_Cov_chi_req_size.size_4);
             ignore_bins CHI_ATOMICLOAD_LDSET_size_4        = binsof(Cov_CONC_11504_Cov_chi_atomic_opcodes.bin_CHI_ATOMICLOAD_LDSET    ) && binsof(Cov_CONC_11504_Cov_chi_req_size.size_4);
             ignore_bins CHI_ATOMICLOAD_LDSMAX_size_4       = binsof(Cov_CONC_11504_Cov_chi_atomic_opcodes.bin_CHI_ATOMICLOAD_LDSMAX   ) && binsof(Cov_CONC_11504_Cov_chi_req_size.size_4);
             ignore_bins CHI_ATOMICLOAD_LDMIN_size_4        = binsof(Cov_CONC_11504_Cov_chi_atomic_opcodes.bin_CHI_ATOMICLOAD_LDMIN    ) && binsof(Cov_CONC_11504_Cov_chi_req_size.size_4);
             ignore_bins CHI_ATOMICLOAD_LDUSMAX_size_4      = binsof(Cov_CONC_11504_Cov_chi_atomic_opcodes.bin_CHI_ATOMICLOAD_LDUSMAX  ) && binsof(Cov_CONC_11504_Cov_chi_req_size.size_4);
             ignore_bins CHI_ATOMICLOAD_LDUMIN_size_4       = binsof(Cov_CONC_11504_Cov_chi_atomic_opcodes.bin_CHI_ATOMICLOAD_LDUMIN   ) && binsof(Cov_CONC_11504_Cov_chi_req_size.size_4);
             ignore_bins CHI_ATOMICSWAP_size_4              = binsof(Cov_CONC_11504_Cov_chi_atomic_opcodes.bin_CHI_ATOMICSWAP          ) && binsof(Cov_CONC_11504_Cov_chi_req_size.size_4);

             ignore_bins CHI_ATOMICSTORE_STADD_size_5       = binsof(Cov_CONC_11504_Cov_chi_atomic_opcodes.bin_CHI_ATOMICSTORE_STADD) && binsof(Cov_CONC_11504_Cov_chi_req_size.size_5);
             ignore_bins CHI_ATOMICSTORE_STCLR_size_5       = binsof(Cov_CONC_11504_Cov_chi_atomic_opcodes.bin_CHI_ATOMICSTORE_STCLR) && binsof(Cov_CONC_11504_Cov_chi_req_size.size_5);
             ignore_bins CHI_ATOMICSTORE_STEOR_size_5       = binsof(Cov_CONC_11504_Cov_chi_atomic_opcodes.bin_CHI_ATOMICSTORE_STEOR) && binsof(Cov_CONC_11504_Cov_chi_req_size.size_5);
             ignore_bins CHI_ATOMICSTORE_STSET_size_5       = binsof(Cov_CONC_11504_Cov_chi_atomic_opcodes.bin_CHI_ATOMICSTORE_STSET) && binsof(Cov_CONC_11504_Cov_chi_req_size.size_5);
             ignore_bins CHI_ATOMICSTORE_STSMAX_size_5      = binsof(Cov_CONC_11504_Cov_chi_atomic_opcodes.bin_CHI_ATOMICSTORE_STSMAX  ) && binsof(Cov_CONC_11504_Cov_chi_req_size.size_5);
             ignore_bins CHI_ATOMICSTORE_STMIN_size_5       = binsof(Cov_CONC_11504_Cov_chi_atomic_opcodes.bin_CHI_ATOMICSTORE_STMIN   ) && binsof(Cov_CONC_11504_Cov_chi_req_size.size_5);
             ignore_bins CHI_ATOMICSTORE_STUSMAX_size_5     = binsof(Cov_CONC_11504_Cov_chi_atomic_opcodes.bin_CHI_ATOMICSTORE_STUSMAX ) && binsof(Cov_CONC_11504_Cov_chi_req_size.size_5);
             ignore_bins CHI_ATOMICSTORE_STUMIN_size_5      = binsof(Cov_CONC_11504_Cov_chi_atomic_opcodes.bin_CHI_ATOMICSTORE_STUMIN  ) && binsof(Cov_CONC_11504_Cov_chi_req_size.size_5);
             ignore_bins CHI_ATOMICLOAD_LDADD_size_5        = binsof(Cov_CONC_11504_Cov_chi_atomic_opcodes.bin_CHI_ATOMICLOAD_LDADD    ) && binsof(Cov_CONC_11504_Cov_chi_req_size.size_5);
             ignore_bins CHI_ATOMICLOAD_LDCLR_size_5        = binsof(Cov_CONC_11504_Cov_chi_atomic_opcodes.bin_CHI_ATOMICLOAD_LDCLR    ) && binsof(Cov_CONC_11504_Cov_chi_req_size.size_5);
             ignore_bins CHI_ATOMICLOAD_LDEOR_size_5        = binsof(Cov_CONC_11504_Cov_chi_atomic_opcodes.bin_CHI_ATOMICLOAD_LDEOR    ) && binsof(Cov_CONC_11504_Cov_chi_req_size.size_5);
             ignore_bins CHI_ATOMICLOAD_LDSET_size_5        = binsof(Cov_CONC_11504_Cov_chi_atomic_opcodes.bin_CHI_ATOMICLOAD_LDSET    ) && binsof(Cov_CONC_11504_Cov_chi_req_size.size_5);
             ignore_bins CHI_ATOMICLOAD_LDSMAX_size_5       = binsof(Cov_CONC_11504_Cov_chi_atomic_opcodes.bin_CHI_ATOMICLOAD_LDSMAX   ) && binsof(Cov_CONC_11504_Cov_chi_req_size.size_5);
             ignore_bins CHI_ATOMICLOAD_LDMIN_size_5        = binsof(Cov_CONC_11504_Cov_chi_atomic_opcodes.bin_CHI_ATOMICLOAD_LDMIN    ) && binsof(Cov_CONC_11504_Cov_chi_req_size.size_5);
             ignore_bins CHI_ATOMICLOAD_LDUSMAX_size_5      = binsof(Cov_CONC_11504_Cov_chi_atomic_opcodes.bin_CHI_ATOMICLOAD_LDUSMAX  ) && binsof(Cov_CONC_11504_Cov_chi_req_size.size_5);
             ignore_bins CHI_ATOMICLOAD_LDUMIN_size_5       = binsof(Cov_CONC_11504_Cov_chi_atomic_opcodes.bin_CHI_ATOMICLOAD_LDUMIN   ) && binsof(Cov_CONC_11504_Cov_chi_req_size.size_5);
             ignore_bins CHI_ATOMICSWAP_size_5              = binsof(Cov_CONC_11504_Cov_chi_atomic_opcodes.bin_CHI_ATOMICSWAP          ) && binsof(Cov_CONC_11504_Cov_chi_req_size.size_5);

             ignore_bins CHI_ATOMICCOMPARE_size_0           = binsof(Cov_CONC_11504_Cov_chi_atomic_opcodes.bin_CHI_ATOMICCOMPARE       ) && binsof(Cov_CONC_11504_Cov_chi_req_size.size_0);
         }
            
        <% } %>
        <% if (numAce || numAceLiteE  || numAceLite) {%>
        //#Cover.FSYS.ace.native_opcode
        CovAceCmdReq:     coverpoint ace_xxx_cmd_type {
           <% if (!numAceLiteE) {%>
            ignore_bins ignore_ACELITEE = {
           <% if ((numAceLiteE==0) && (num_AXI5_atomic==0) && (num_AXI5_with_owo_512b==0) && (num_AXI5_with_owo_256b==0)) {%>
                                           ATMSTR,ATMLD,ATMSWAP,ATMCOMPARE,  //ATOMIC
           <% } %>
                                          WRUNQPTLSTASH,WRUNQFULLSTASH   // Write stash
                                          ,STASHONCESHARED,STASHONCEUNQ // stash
                                          ,RDONCECLNINVLD,RDONCEMAKEINVLD,CLNSHRDPERSIST
                                         };
            <% } //numAceLiteE == 0 %>
           <% if (!numAce) {%>
            ignore_bins ignore_ACE = {
                                            RDCLN,RDNOTSHRDDIR,RDUNQ,CLNUNQ,MKUNQ
                                            ,WRCLN,WRBK,EVCT,WREVCT
                                            ,RDSHRD // As here only ACE/ACELite/ACELite-E cmd are collected
                                        };
            <% } //numAce == 0 %> 
           <% if (!numAce && !numAceLiteE) {%>
            ignore_bins ignore_noACE_noACELiteE = {
                                            CLNSHRD,CLNINVL,MKINVL,
                                            RDONCE,DVMMSG,WRUNQ,WRLNUNQ
                                        };
            <% } //numAce == 0 && numAceLiteE == 0 %>             
            <% if (dmi_useAtomic==0 || ((numAceLiteE==0) && (num_AXI5_atomic==0) && (num_AXI5_with_owo_512b==0) && (num_AXI5_with_owo_256b==0))) {%>
            ignore_bins ignore_Atomic = {
                                           ATMSTR,ATMLD,ATMSWAP,ATMCOMPARE  //ATOMIC
                                         };
            <% } //dmi_useAtomic %>
             ignore_bins ignore_unsupported = {STASHTRANS,BARRIER};
         }                                             
        <% } //numAceXXX > 0 %>
     <% if (numAce) {%>
     // #Cover.FSYS.sysevent.CohExclusiveLoadCmds
         CovCohExclusiveLoadCmds : coverpoint ace_xxx_cmd_type {
             bins RDCLN = {ace_command_types_enum_t'(RDCLN)};
             bins RDSHRD = {ace_command_types_enum_t'(RDSHRD)};
         }
         // #Cover.FSYS.sysevent.CohExclusiveStoreCmds
         CovCohExclusiveStoreCmds: coverpoint ace_xxx_cmd_type {
             bins CLNUNQ = {ace_command_types_enum_t'(CLNUNQ)};
         }
     <% } //numAce > 0 %>
     <% if (numIoAiu) {%>
         Cov_CONC_11133_axi_ace_opcodes : coverpoint CONC_11133_Cov_axi_ace_wr_rd_opcodes{
     <% if ((numAce>0) || (numAceLite>0) ||(numAceLiteE>0)) {%>
            bins ace_noncoh_opcode_wr = {Ace_WrNoSnoop};
            bins ace_noncoh_opcode_rd = {Ace_RdNoSnoop};
            bins ace_coh_opcode_wr = {Ace_WrUnique};
            bins ace_coh_opcode_rd = {Ace_RdOnce};
     <% } %>
     <% if (num_AXI5_AXI4>0) {%>
            bins axi_opcode_wr = {Axi5_Axi4_Write};
            bins axi_opcode_rd = {Axi5_Axi4_Read};
     <% } %>
         }
     <% if (num_AXI5_with_owo>0) {%>
     // #Cover.FSYS.v371.amba5_axi5_owo_txns
     // #Cover.FSYS.v371.amba5_axi5_owo_CohTxns
     // #Cover.FSYS.v371.amba5_axi5_owo_NonCohTxns
         Cov_owo_axi_opcodes : coverpoint owo_Axi_wr_rd_opcodes{
            bins ace_noncoh_opcode_wr = {Ace_WrNoSnoop};
            bins ace_noncoh_opcode_rd = {Ace_RdNoSnoop};
            bins ace_coh_opcode_wr = {Ace_WrUnique};
            bins ace_coh_opcode_rd = {Ace_RdOnce};
            ignore_bins ignore_owo_axi_opcodes = {Axi5_Axi4_Write, Axi5_Axi4_Read};

         }
     <% } %>
     <% if (numAceLite_with_owo>0) {%>
     // #Cover.FSYS.v371.amba5_AceLite_owo_txns
     // #Cover.FSYS.v371.amba5_AceLite_owo_CohTxns
     // #Cover.FSYS.v371.amba5_AceLite_owo_NonCohTxns
         Cov_Acelite_axi_opcodes : coverpoint owo_Acelite_wr_rd_opcodes{
            bins ace_noncoh_opcode_wr = {Ace_WrNoSnoop};
            bins ace_noncoh_opcode_rd = {Ace_RdNoSnoop};
            bins ace_coh_opcode_wr = {Ace_WrUnique};
            bins ace_coh_opcode_rd = {Ace_RdOnce};
            ignore_bins ignore_owo_axi_opcodes = {Axi5_Axi4_Write, Axi5_Axi4_Read};

         }
     <% } %>
     <% if (numAce5Lite_with_owo>0) {%>
         Cov_Ace5lite_axi_opcodes : coverpoint owo_Ace5lite_wr_rd_opcodes{
            bins ace_noncoh_opcode_wr = {Ace_WrNoSnoop};
            bins ace_noncoh_opcode_rd = {Ace_RdNoSnoop};
     // #Cover.FSYS.v371.amba5_Ace5Lite_owo_txns
     // #Cover.FSYS.v371.amba5_Ace5Lite_owo_CohTxns
     // #Cover.FSYS.v371.amba5_Ace5Lite_owo_NonCohTxns
            bins ace_coh_opcode_wr = {Ace_WrUnique};
            bins ace_coh_opcode_rd = {Ace_RdOnce};
            ignore_bins ignore_owo_axi_opcodes = {Axi5_Axi4_Write, Axi5_Axi4_Read};

         }
     <% } %>
         Cov_CONC_11133_axi_ace_awlen : coverpoint aiu_awlen {
             bins awlen_0 = {0};
             bins awlen_1 = {1};
             bins awlen_2 = {2};
             bins awlen_3 = {3};
         }
         Cov_CONC_11133_axi_ace_arlen : coverpoint aiu_arlen {
             bins arlen_0 = {0};
             bins arlen_1 = {1};
             bins arlen_2 = {2};
             bins arlen_3 = {3};
         }
         Cov_CONC_11133_axi_ace_awaddr_critical_dword : coverpoint axi_ace_awaddr_critical_dword;
         Cov_CONC_11133_axi_ace_araddr_critical_dword : coverpoint axi_ace_araddr_critical_dword;
         Cov_CONC_11133_axi_ace_wdata : coverpoint axi_ace_wdata {
         <% if (wdata64==0) {%> 
             ignore_bins wdata64 = {axi_ace_wdata_64};
         <%} else {%>
             bins wdata64 = {axi_ace_wdata_64};
         <%} %>

         <% if (wdata128==0) {%> 
             ignore_bins wdata128 = {axi_ace_wdata_128};
         <%} else {%>
             bins wdata128 = {axi_ace_wdata_128};
         <%} %>

         <% if (wdata256==0) {%> 
             ignore_bins wdata256 = {axi_ace_wdata_256};
         <%} else {%>
             bins wdata256 = {axi_ace_wdata_256};
         <%} %>

         <% if (wdata512==0) {%> 
             ignore_bins wdata512 = {axi_ace_wdata_512};
         <%} else {%>
             bins wdata512 = {axi_ace_wdata_512};
         <%} %>
         }
         Cross_Cov_CONC_11133_axi_ace_wr : cross Cov_CONC_11133_axi_ace_opcodes, Cov_CONC_11133_axi_ace_wdata,Cov_CONC_11133_axi_ace_awaddr_critical_dword, Cov_CONC_11133_axi_ace_awlen {
     <% if ((numAce>0) || (numAceLite>0) ||(numAceLiteE>0)) {%>
             ignore_bins read_opcodes_0 = binsof(Cov_CONC_11133_axi_ace_opcodes.ace_noncoh_opcode_rd);
             ignore_bins read_opcodes_1 = binsof(Cov_CONC_11133_axi_ace_opcodes.ace_coh_opcode_rd);
     <% } %>
     <% if (num_AXI5_AXI4>0) {%>
             ignore_bins read_opcodes_2 = binsof(Cov_CONC_11133_axi_ace_opcodes.axi_opcode_rd);
     <% } %>
         }
         Cross_Cov_CONC_11133_axi_ace_rd : cross Cov_CONC_11133_axi_ace_opcodes, Cov_CONC_11133_axi_ace_wdata,Cov_CONC_11133_axi_ace_araddr_critical_dword, Cov_CONC_11133_axi_ace_arlen {
     <% if ((numAce>0) || (numAceLite>0) ||(numAceLiteE>0)) {%>
             ignore_bins write_opcodes_0 = binsof(Cov_CONC_11133_axi_ace_opcodes.ace_noncoh_opcode_wr);
             ignore_bins write_opcodes_1 = binsof(Cov_CONC_11133_axi_ace_opcodes.ace_coh_opcode_wr);
     <% } %>
     <% if (num_AXI5_AXI4>0) {%>
             ignore_bins write_opcodes_2 = binsof(Cov_CONC_11133_axi_ace_opcodes.axi_opcode_wr);
     <% } %>
         }
     <% if (num_AXI5_with_owo>0) {%>
     //#Cover.FSYS.v371.amba5_axi5_owo_critical_dword
         Cross_Cov_owo_axi_wr : cross Cov_owo_axi_opcodes, Cov_CONC_11133_axi_ace_wdata,Cov_CONC_11133_axi_ace_awaddr_critical_dword, Cov_CONC_11133_axi_ace_awlen {
         <% if (wdata64==0) {%> 
             ignore_bins wdata64 = binsof(Cov_CONC_11133_axi_ace_wdata.wdata64);
         <%} %>
         <% if (wdata128==0) {%> 
             ignore_bins wdata128 = binsof(Cov_CONC_11133_axi_ace_wdata.wdata128);
         <%} %>
         <% if (wdata256==0) {%> 
             ignore_bins wdata256 = binsof(Cov_CONC_11133_axi_ace_wdata.wdata256);
         <%} %>
         <% if (wdata512==0) {%> 
             ignore_bins wdata512 = binsof(Cov_CONC_11133_axi_ace_wdata.wdata512);
         <%} %>
         }
        Cross_Cov_owo_axi_rd : cross Cov_owo_axi_opcodes, Cov_CONC_11133_axi_ace_wdata,Cov_CONC_11133_axi_ace_araddr_critical_dword, Cov_CONC_11133_axi_ace_arlen {
         <% if (wdata64==0) {%> 
             ignore_bins wdata64 = binsof(Cov_CONC_11133_axi_ace_wdata.wdata64);
         <%} %>
         <% if (wdata128==0) {%> 
             ignore_bins wdata128 = binsof(Cov_CONC_11133_axi_ace_wdata.wdata128);
         <%} %>
         <% if (wdata256==0) {%> 
             ignore_bins wdata256 = binsof(Cov_CONC_11133_axi_ace_wdata.wdata256);
         <%} %>
         <% if (wdata512==0) {%> 
             ignore_bins wdata512 = binsof(Cov_CONC_11133_axi_ace_wdata.wdata512);
         <%} %>
         }

     <% } %>

     <% if (numAceLite_with_owo>0) {%>
     //#Cover.FSYS.v371.amba5_AceLite_owo_critical_dword
         Cross_Cov_owo_AceLite_wr : cross Cov_Acelite_axi_opcodes, Cov_CONC_11133_axi_ace_wdata,Cov_CONC_11133_axi_ace_awaddr_critical_dword, Cov_CONC_11133_axi_ace_awlen {
         <% if (wdata64==0) {%> 
             ignore_bins wdata64 = binsof(Cov_CONC_11133_axi_ace_wdata.wdata64);
         <%} %>
         <% if (wdata128==0) {%> 
             ignore_bins wdata128 = binsof(Cov_CONC_11133_axi_ace_wdata.wdata128);
         <%} %>
         <% if (wdata256==0) {%> 
             ignore_bins wdata256 = binsof(Cov_CONC_11133_axi_ace_wdata.wdata256);
         <%} %>
         <% if (wdata512==0) {%> 
             ignore_bins wdata512 = binsof(Cov_CONC_11133_axi_ace_wdata.wdata512);
         <%} %>
         }
         Cross_Cov_owo_AceLite_rd : cross Cov_Acelite_axi_opcodes, Cov_CONC_11133_axi_ace_wdata,Cov_CONC_11133_axi_ace_awaddr_critical_dword, Cov_CONC_11133_axi_ace_arlen {
         <% if (wdata64==0) {%> 
             ignore_bins wdata64 = binsof(Cov_CONC_11133_axi_ace_wdata.wdata64);
         <%} %>
         <% if (wdata128==0) {%> 
             ignore_bins wdata128 = binsof(Cov_CONC_11133_axi_ace_wdata.wdata128);
         <%} %>
         <% if (wdata256==0) {%> 
             ignore_bins wdata256 = binsof(Cov_CONC_11133_axi_ace_wdata.wdata256);
         <%} %>
         <% if (wdata512==0) {%> 
             ignore_bins wdata512 = binsof(Cov_CONC_11133_axi_ace_wdata.wdata512);
         <%} %>
         }
     <% } %>

     <% if (numAce5Lite_with_owo>0) {%>
     //#Cover.FSYS.v371.amba5_Ace5Lite_owo_critical_dword
         Cross_Cov_owo_Ace5Lite_wr : cross Cov_Ace5lite_axi_opcodes, Cov_CONC_11133_axi_ace_wdata,Cov_CONC_11133_axi_ace_awaddr_critical_dword, Cov_CONC_11133_axi_ace_awlen {
         <% if (wdata64==0) {%> 
             ignore_bins wdata64 = binsof(Cov_CONC_11133_axi_ace_wdata.wdata64);
         <%} %>
         <% if (wdata128==0) {%> 
             ignore_bins wdata128 = binsof(Cov_CONC_11133_axi_ace_wdata.wdata128);
         <%} %>
         <% if (wdata256==0) {%> 
             ignore_bins wdata256 = binsof(Cov_CONC_11133_axi_ace_wdata.wdata256);
         <%} %>
         <% if (wdata512==0) {%> 
             ignore_bins wdata512 = binsof(Cov_CONC_11133_axi_ace_wdata.wdata512);
         <%} %>
         }
         Cross_Cov_owo_Ace5Lite_rd : cross Cov_Ace5lite_axi_opcodes, Cov_CONC_11133_axi_ace_wdata,Cov_CONC_11133_axi_ace_awaddr_critical_dword, Cov_CONC_11133_axi_ace_arlen {
         <% if (wdata64==0) {%> 
             ignore_bins wdata64 = binsof(Cov_CONC_11133_axi_ace_wdata.wdata64);
         <%} %>
         <% if (wdata128==0) {%> 
             ignore_bins wdata128 = binsof(Cov_CONC_11133_axi_ace_wdata.wdata128);
         <%} %>
         <% if (wdata256==0) {%> 
             ignore_bins wdata256 = binsof(Cov_CONC_11133_axi_ace_wdata.wdata256);
         <%} %>
         <% if (wdata512==0) {%> 
             ignore_bins wdata512 = binsof(Cov_CONC_11133_axi_ace_wdata.wdata512);
         <%} %>
         }
     <% } %>
     <% } %>

     <% if (numIoAiu) {%>
         CovRdPoliciesVisibility: coverpoint rd_policies;
         CovWrPoliciesVisibility: coverpoint wr_policies;    
         CovExclusive_arlock : coverpoint arlock {
             bins EXCLUSIVE = {axi_axlock_enum_t'(EXCLUSIVE)};
         }
         CovExclusive_awlock : coverpoint awlock {
             bins EXCLUSIVE = {axi_axlock_enum_t'(EXCLUSIVE)};
         }
        <% if (numAce || numAceLiteE  || numAceLite) {%>
     // #Cover.FSYS.sysevent.NonCohExclusiveLoadCmds
         CovNonCohExclusiveLoadCmds : coverpoint ace_xxx_cmd_type { 
             bins RDNOSNOOP = {ace_command_types_enum_t'(RDNOSNP)};
         }
     // #Cover.FSYS.sysevent.NonCohExclusiveStoreCmds
         CovNonCohExclusiveStoreCmds : coverpoint ace_xxx_cmd_type { 
             bins WRNOSNOOP = {ace_command_types_enum_t'(WRNOSNP)};
         }
         Cross_CovNonCohExclusiveLoadCmds_And_CovExclusive : cross CovNonCohExclusiveLoadCmds, CovExclusive_arlock;
         Cross_CovNonCohExclusiveStoreCmds_And_CovExclusive : cross CovNonCohExclusiveStoreCmds, CovExclusive_awlock;
        <% } //numAceXXX > 0 %>
     <% } //numIoAiu 0 %>
     <% if (numAce) {%>
         Cross_CovCohExclusiveLoadCmds_And_CovExclusive : cross CovCohExclusiveLoadCmds, CovExclusive_arlock;
         Cross_CovCohExclusiveStoreCmds_And_CovExclusive : cross CovCohExclusiveStoreCmds, CovExclusive_arlock;
     <% } //numAce > 0 %>
    endgroup
<%
   var chi_resperr_bins_str = `
            bins okay = {0};
            bins ex_okay = {1};
            bins data_err = {2};
            bins non_data_err = {3};
            //option.auto_bin_max = 0;
`;
   var io_resp_bins_str = `
            bins okay = {0};
            bins ex_okay = {1};
            bins slv_err = {2};
            bins dec_err = {3};
            //option.auto_bin_max = 0;
`;

%> 
<% if (numIoAiu) {%>
<% var axlen_bins =`
            bins partial = {[ 0: ((SYS_nSysCacheline*8/(WXDATA)) - 2)]}; // Partial  
            bins fullcacheline = {((SYS_nSysCacheline*8/(WXDATA)) - 1)}; // Full cacheline
            bins multiline = {[(SYS_nSysCacheline*8/(WXDATA)): $]}; // Multiline
            //option.auto_bin_max = 0;
`
%>
    covergroup cg_axlen;
        CovArlen :coverpoint aiu_arlen {
            <%=axlen_bins%>
        }
        CovAwlen :coverpoint aiu_awlen {
            <%=axlen_bins%>
        }
    endgroup

`ifdef FSYS_COV_INCL_DVM_BINS
    covergroup cg_ioaiu_cross_dvm_version;
// #Cover.FSYS.DVM_dvmV8_DVMop_ioaiu_sender
// #Cover.FSYS.DVM_dvmV8_SnpDVMop_ioaiu_sender
    <% if(DVMV8_0) {%>
        CovCmddvmV80 : coverpoint ioaiu_captured_cmd_dvmV80 {
            bins bit_0 = {1}; 
        }
        CovSnpdvmV80 : coverpoint ioaiu_captured_snp_dvmV80 {
            bins bit_0 = {1}; 
        }
    <% } %>
// #Cover.FSYS.DVM_dvmV81_DVMop_ioaiu_sender
// #Cover.FSYS.DVM_dvmV81_SnpDVMop_ioaiu_sender
    <% if(DVMV8_1) {%>
        CovCmddvmV81 : coverpoint ioaiu_captured_cmd_dvmV81 {
            bins bit_0 = {1}; 
        }
        CovSnpdvmV81 : coverpoint ioaiu_captured_snp_dvmV81 {
            bins bit_0 = {1}; 
        }
    <% } %>
// #Cover.FSYS.DVM_dvmV84_DVMop_ioaiu_sender
// #Cover.FSYS.DVM_dvmV84_SnpDVMop_ioaiu_sender
    <% if(DVMV8_4) {%>
        CovCmddvmV84 : coverpoint ioaiu_captured_cmd_dvmV84 {
            bins bit_0 = {1}; 
        }
        CovSnpdvmV84 : coverpoint ioaiu_captured_snp_dvmV84 {
            bins bit_0 = {1}; 
        }
    <% } %>
    endgroup
`endif // `ifdef FSYS_COV_INCL_DVM_BINS
// #Cover.FSYS.DVM_dvmV81_toggle_cov
`ifdef FSYS_COV_INCL_DVM_BINS
    <% if(DVMV8_1 || DVMV8_4) {%>
    covergroup cg_ioaiu_dvm_field_dvmV81;
        CovCmddvmV81_vmidext :coverpoint ioaiu_cmd_dvm_field_vmidext{
            bins bit_0 = {1}; 
            bins bit_1 = {[2:3]}; 
            bins bit_2 = {[4:7]}; 
            bins bit_3 = {[8:15]}; 
            bins bit_4 = {[16:31]}; 
            bins bit_5 = {[32:63]}; 
            bins bit_6 = {[64:127]}; 
            bins bit_7 = {[128:255]}; 
        }
        CovSnpdvmV81_vmidext :coverpoint ioaiu_snp_dvm_field_vmidext{
            bins bit_0 = {1}; 
            bins bit_1 = {[2:3]}; 
            bins bit_2 = {[4:7]}; 
            bins bit_3 = {[8:15]}; 
            bins bit_4 = {[16:31]}; 
            bins bit_5 = {[32:63]}; 
            bins bit_6 = {[64:127]}; 
            bins bit_7 = {[128:255]}; 
        }
    endgroup
    <% } %>
`endif // `ifdef FSYS_COV_INCL_DVM_BINS
`ifdef FSYS_COV_INCL_DVM_BINS
    <% if(DVMV8_4) {%>
// #Cover.FSYS.DVM_dvmV84_toggle_cov
    covergroup cg_ioaiu_dvm_field_dvmV84;
        CovCmddvmV84_num :coverpoint ioaiu_cmd_dvm_field_num{
            bins bit_0 = {1}; 
            bins bit_1 = {[2:3]}; 
            bins bit_2 = {[4:7]}; 
            bins bit_3 = {[8:15]}; 
            bins bit_4 = {[16:31]}; 
        }
        CovSnpdvmV84_num :coverpoint ioaiu_snp_dvm_field_num{
            bins bit_0 = {1}; 
            bins bit_1 = {[2:3]}; 
            bins bit_2 = {[4:7]}; 
            bins bit_3 = {[8:15]}; 
            bins bit_4 = {[16:31]}; 
        }
        CovCmddvmV84_range :coverpoint ioaiu_cmd_dvm_field_range{
            bins bit_0 = {1}; 
        }
        CovSnpdvmV84_range :coverpoint ioaiu_snp_dvm_field_range{
            bins bit_0 = {1}; 
        }
        CovCmddvmV84_scale :coverpoint ioaiu_cmd_dvm_field_scale{
            bins bit_0 = {1}; 
            bins bit_1 = {[2:3]}; 
        }
        CovSnpdvmV84_scale :coverpoint ioaiu_snp_dvm_field_scale{
            bins bit_0 = {1}; 
            bins bit_1 = {[2:3]}; 
        }
    endgroup
    <% } %>
`endif // `ifdef FSYS_COV_INCL_DVM_BINS
<%} // if IoAiu%> 
    covergroup cg_native_itf_resp;
     <% if (numChiAiu) {%>
//#Cover.FSYS.CHI.snpErr
         CovChiSnpSRespErr:    coverpoint chi_snp_sresp_resperr  { 
            bins okay = {0};
            ignore_bins ex_okay = {1};  // According to Error response use by transaction type section of ARM CHI spec 9.4.7
            ignore_bins data_err = {2}; // Figure 2-17 Snoop transaction structure with response to Home  ARM CHI spec section 2.3.3
            bins non_data_err = {3};
            //option.auto_bin_max = 0;
         }
        CovChiSnpWdatRespErr:    coverpoint chi_snp_wdat_resperr  { 
            bins okay = {0};
            ignore_bins ex_okay = {1};  // According to Error response use by transaction type section of ARM CHI spec 9.4.7
            bins data_err = {2}; 
            ignore_bins non_data_err = {3}; // Figure 2-18 Snoop transaction structure with response to Home ARM CHI spec section 2.3.3
            //option.auto_bin_max = 0;
         }

//#Cover.FSYS.CHI.dataErr
//#Cover.FSYS.CHI.NondataErr
         CovChiDataRespErr:    coverpoint chi_data_resperr {
            <%=chi_resperr_bins_str%>
         }
         CovChiCRespErr:    coverpoint chi_cresperr {
            <%=chi_resperr_bins_str%>
         }
     <% } //numChiAiu %>

     <% if (numIoAiu) {%>
//#Cover.FSYS.AIU.readrespError
         CovAceRdResp:    coverpoint aiu_rresp {
            <%=io_resp_bins_str%>
         }
//#Cover.FSYS.AIU.writrespError
         CovAceWrResp:    coverpoint aiu_bresp{
            <%=io_resp_bins_str%>
         }
     <% } //numIoAiu %>

     <% if (num_AXI5_with_owo>0) {%>
// #Cover.FSYS.v371.amba5_axi5_owo_native_if_response
// #Cover.FSYS.v371.amba5_AceLite_owo_native_if_response 
// #Cover.FSYS.v371.amba5_Ace5Lite_owo_native_if_response
         Cov_owo_axi_RdResp:    coverpoint owo_axi_aiu_rresp{
            bins okay = {0};
            bins slv_err = {2};
            bins dec_err = {3};
            ignore_bins ex_okay = {1};
            //illegal_bins ex_okay = {1};
         }
         Cov_owo_axi_WrResp:    coverpoint owo_axi_aiu_bresp{
            bins okay = {0};
            bins slv_err = {2};
            bins dec_err = {3};
            ignore_bins ex_okay = {1};
            //illegal_bins ex_okay = {1};
         }
     <% } %>

     <% if (numAceLite_with_owo>0) {%>
         Cov_owo_AceLite_RdResp:    coverpoint owo_axi_AceLite_rresp{
            bins okay = {0};
            bins slv_err = {2};
            bins dec_err = {3};
            ignore_bins ex_okay = {1};
            //illegal_bins ex_okay = {1};
         }
         Cov_owo_AceLite_WrResp:    coverpoint owo_axi_AceLite_bresp{
            bins okay = {0};
            bins slv_err = {2};
            bins dec_err = {3};
            ignore_bins ex_okay = {1};
            //illegal_bins ex_okay = {1};
         }
     <% } %>

     <% if (numAce5Lite_with_owo>0) {%>
         Cov_owo_Ace5Lite_RdResp:    coverpoint owo_axi_Ace5Lite_rresp{
            bins okay = {0};
            bins slv_err = {2};
            bins dec_err = {3};
            ignore_bins ex_okay = {1};
            //illegal_bins ex_okay = {1};
         }
         Cov_owo_Ace5Lite_WrResp:    coverpoint owo_axi_Ace5Lite_bresp{
            bins okay = {0};
            bins slv_err = {2};
            bins dec_err = {3};
            ignore_bins ex_okay = {1};
            //illegal_bins ex_okay = {1};
         }
     <% } %>

        <% if (numAce ) {%>
//#Cover.FSYS.IO.snprespError
         CovAceSnpResp:   coverpoint ace_sresp {
            <%=io_resp_bins_str%>
         }
        CovAceSnpReq:     coverpoint ace_snp_type {
        }
        <% } //numAce > 0 %>

//#Cover.FSYS.DMI.readrespError
         CovDmiRdResp:    coverpoint dmi_rresp {
            <%=io_resp_bins_str%>
         }
//#Cover.FSYS.DMI.writrespError
         CovDmiWrResp:    coverpoint dmi_bresp {
            <%=io_resp_bins_str%>
         }

         <% if (obj.nDIIs> 1) { %>
//#Cover.FSYS.DII.readrespError
         CovDiiRdResp:    coverpoint dii_rresp {
            <%=io_resp_bins_str%>
         }
//#Cover.FSYS.DII.writrespError
//#Cover.FSYS.DII.writrespError.SLVERR
         CovDiiWrResp:    coverpoint dii_bresp {
            <%=io_resp_bins_str%>
         }
        <% } // nDii > 1%>
    endgroup

     <% if (numChiAiu) {%>
`ifdef FSYS_COV_INCL_DVM_BINS
        covergroup cg_chiaiu_cross_dvm_version;
// #Cover.FSYS.DVM_dvmV8_DVMop_chiaiu_sender
// #Cover.FSYS.DVM_dvmV8_SnpDVMop_chiaiu_sender
    <% if(DVMV8_0) {%>
            CovCmddvmV80 : coverpoint chiaiu_captured_cmd_req_dvmV80 {
                bins bit_0 = {1}; 
            }
            CovSnpdvmV80 : coverpoint chiaiu_captured_snp_req_dvmV80 {
                bins bit_0 = {1}; 
            }
    <% } %>
// #Cover.FSYS.DVM_dvmV81_DVMop_chiaiu_sender
// #Cover.FSYS.DVM_dvmV81_SnpDVMop_chiaiu_sender
    <% if(DVMV8_1) {%>
            CovCmddvmV81 : coverpoint chiaiu_captured_cmd_req_dvmV81 {
                bins bit_0 = {1}; 
            }
            CovSnpdvmV81 : coverpoint chiaiu_captured_snp_req_dvmV81 {
                bins bit_0 = {1}; 
            }
    <% } %>
// #Cover.FSYS.DVM_dvmV84_DVMop_chiaiu_sender
// #Cover.FSYS.DVM_dvmV84_SnpDVMop_chiaiu_sender
    <% if(DVMV8_4) {%>
            CovCmddvmV84 : coverpoint chiaiu_captured_cmd_req_dvmV84 {
                bins bit_0 = {1}; 
            }
            CovSnpdvmV84 : coverpoint chiaiu_captured_snp_req_dvmV84 {
                bins bit_0 = {1}; 
            }
    <% } %>
        endgroup
`endif // `ifdef FSYS_COV_INCL_DVM_BINS
`ifdef FSYS_COV_INCL_DVM_BINS
    <% if(DVMV8_1 || DVMV8_4) {%>
// #Cover.FSYS.DVM_dvmV81_toggle_cov
        covergroup cg_chiaiu_dvm_field_dvmV81;
            CovCmddvmV81_vmidext :coverpoint chiaiu_cmd_req_dvm_field_vmidext{
                bins bit_0 = {1}; 
                bins bit_1 = {[2:3]}; 
                bins bit_2 = {[4:7]}; 
                bins bit_3 = {[8:15]}; 
                bins bit_4 = {[16:31]}; 
                bins bit_5 = {[32:63]}; 
                bins bit_6 = {[64:127]}; 
                bins bit_7 = {[128:255]}; 
            }
            CovSnpdvmV81_vmidext :coverpoint chiaiu_snp_req_dvm_field_vmidext{
                bins bit_0 = {1}; 
                bins bit_1 = {[2:3]}; 
                bins bit_2 = {[4:7]}; 
                bins bit_3 = {[8:15]}; 
                bins bit_4 = {[16:31]}; 
                bins bit_5 = {[32:63]}; 
                bins bit_6 = {[64:127]}; 
                bins bit_7 = {[128:255]}; 
            }
        endgroup
    <% } %>
`endif // `ifdef FSYS_COV_INCL_DVM_BINS
`ifdef FSYS_COV_INCL_DVM_BINS
    <% if(DVMV8_4) {%>
// #Cover.FSYS.DVM_dvmV84_toggle_cov
        covergroup cg_chiaiu_dvm_field_dvmV84;
            CovCmddvmV84_num :coverpoint chiaiu_cmd_req_dvm_field_num{
                bins bit_0 = {1}; 
                bins bit_1 = {[2:3]}; 
                bins bit_2 = {[4:7]}; 
                bins bit_3 = {[8:15]}; 
                bins bit_4 = {[16:31]}; 
            }
            CovSnpdvmV84_num :coverpoint chiaiu_snp_req_dvm_field_num{
                bins bit_0 = {1}; 
                bins bit_1 = {[2:3]}; 
                bins bit_2 = {[4:7]}; 
                bins bit_3 = {[8:15]}; 
                bins bit_4 = {[16:31]}; 
            }
            CovCmddvmV84_range :coverpoint chiaiu_cmd_req_dvm_field_range{
                bins bit_0 = {1}; 
            }
            CovSnpdvmV84_range :coverpoint chiaiu_snp_req_dvm_field_range{
                bins bit_0 = {1}; 
            }
            CovCmddvmV84_scale :coverpoint chiaiu_cmd_req_dvm_field_scale{
                bins bit_0 = {1}; 
                bins bit_1 = {[2:3]}; 
            }
            CovSnpdvmV84_scale :coverpoint chiaiu_snp_req_dvm_field_scale{
                bins bit_0 = {1}; 
                bins bit_1 = {[2:3]}; 
            }
        endgroup
    <% } %>
`endif // `ifdef FSYS_COV_INCL_DVM_BINS
     <%}%>

<% if (dmi_useAtomic && ((numAceLiteE>0) || (num_AXI5_atomic>0) || (num_AXI5_with_owo_512b>0) || (num_AXI5_with_owo_256b>0))) {%>     
    typedef enum {AXI5, AXI5_owo_256, AXI5_owo_512, ACE5LITE} atomic_fnNativeInterface_e;                                                         
    atomic_fnNativeInterface_e atomic_fnNativeInterface;
    covergroup cg_native_itf_atomic_compare;
     <% if (numChiAiu) {%>
          
     <%}%>
     <% if ((numAceLiteE>0) || (num_AXI5_atomic>0) || (num_AXI5_with_owo_512b>0) || (num_AXI5_with_owo_256b>0)) {%>
    // sample only if ATMCOMPARE
    //   CovAceAtomicCompare: coverpoint ace_xxx_cmd_type{
    //              bins cmdAtomicCompare = {ATMCOMPARE};
    //   }
      CovAtomicNativeIf : coverpoint atomic_fnNativeInterface {
          <% if (num_AXI5_atomic>0) {%>
                    bins AXI5          = {AXI5};
          <% } %>
          <% if (num_AXI5_with_owo_256b>0) {%>
                    bins AXI5_owo_256  = {AXI5_owo_256};
          <% } %>
          <% if (num_AXI5_with_owo_512b>0) {%>
                    bins AXI5_owo_512  = {AXI5_owo_512};
          <% } %>
          <% if (numAceLiteE>0) {%>
                    bins ACE5LITE      = {ACE5LITE};
          <% } %>
      }
      // #Cover.FSYS.v371.amba5_axi5_owo_txns 
      // #Cover.FSYS.v371.amba5_Ace5Lite_owo_txns
      CovAtomicCmdtype : coverpoint ace_xxx_cmd_type {
                   bins ATMSTR = {ATMSTR}; 
                   bins ATMLD = {ATMLD}; 
                   bins ATMSWAP = {ATMSWAP}; 
                   bins ATMCOMPARE = {ATMCOMPARE}; 
      }
      CovAceAtomicAwlen: coverpoint aiu_awlen {
                   bins awlen0 = {0};
                   <% if (wdata128 || wdata64) {%> bins awlen1 = {1};<%}%>
                   <% if (wdata64) {%> bins awlen3 = {3};<%}%>
                   //option.auto_bin_max = 0;
                    option.weight = 0; // only cross
      }
     CovAceAtomicAwsize: coverpoint aiu_awsize{
               bins awsize1_3[] = {[1:3]};
               <% if (wdata128 || wdata256 ||wdata512) {%> bins awsize4 = {4};<%}%>
               <% if (wdata256 || wdata512) {%> bins awsize5 = {5};<%}%>
               //option.auto_bin_max = 0;
               option.weight = 0; // only cross
     }
     CovAceAtomicAwBurst: coverpoint  aiu_awburst{
               bins incr = {1};
               bins wrap = {2};
               //option.auto_bin_max = 0;
               option.weight = 0; // only cross
     }
     CovAceAtomicAwAddr: coverpoint aiu_awaddr[4:0] {
     <% if (wdata256) { %> bins aiu_addr[] = {[5'h0:5'h1F]};
     <% } else { %> bins aiu_addr[] = {[5'h0:5'h10]}; <%}%>
               //option.auto_bin_max = 0;
               option.weight = 0; // only cross
     }
     CovAceDataWidth: coverpoint aiu_data_width {
            <% if (wdata64)  {%>bins wdata64={64};   <%}%> 
            <% if (wdata128) {%>bins wdata128={128}; <%}%> 
            <% if (wdata256) {%>bins wdata256={256}; <%}%> 
            <% if (wdata512) {%>bins wdata512={512}; <%}%> 
            //option.auto_bin_max = 0;
            option.weight = 0; // only cross
     } 
     Cross_CovAtomicNativeIf_CovAtomicCmdtype : cross CovAtomicNativeIf,CovAtomicCmdtype;
    //cf table https://arterisip.atlassian.net/browse/CONC-11504                                                   
`ifdef VCS    
     // #Cover.FSYS.v371.amba5_axi5_atomicCompare_Wrap
      // #Cover.FSYS.v371.amba5_axi5_atomicTxn_data_size
      // #Cover.FSYS.v371.amba5_Ace5Lite_atomicTxn_data_size
      <% if (wdata64) { %>
       Cross_CovAceAtomicCompare_64wdata : cross CovAceDataWidth,CovAceAtomicAwAddr,CovAceAtomicAwsize,CovAceAtomicAwlen,CovAceAtomicAwBurst {
           ignore_bins not_legal_addr       = Cross_CovAceAtomicCompare_64wdata with (CovAceAtomicAwAddr > 16);
           ignore_bins not_legal_size     = Cross_CovAceAtomicCompare_64wdata with (CovAceAtomicAwsize > 3);
           ignore_bins not_legal_width     = Cross_CovAceAtomicCompare_64wdata with (CovAceDataWidth != 64);
           ignore_bins not_legal_len0      = Cross_CovAceAtomicCompare_64wdata with (CovAceAtomicAwsize < 2 && CovAceAtomicAwlen !=0);
           ignore_bins not_legal_incr      = Cross_CovAceAtomicCompare_64wdata with ((CovAceAtomicAwAddr % ((CovAceAtomicAwlen+1)*(2**CovAceAtomicAwsize))) != 0 && CovAceAtomicAwBurst == 1);
           ignore_bins not_legal_wrap      = Cross_CovAceAtomicCompare_64wdata with ((CovAceAtomicAwAddr % ((CovAceAtomicAwlen+1)*(2**CovAceAtomicAwsize))) == 0 && CovAceAtomicAwBurst == 2);
           ignore_bins not_legal_2B_addr = Cross_CovAceAtomicCompare_64wdata with (CovAceAtomicAwsize == 1  && CovAceAtomicAwAddr > 7);
           ignore_bins not_legal_4B_addr = Cross_CovAceAtomicCompare_64wdata with (CovAceAtomicAwsize == 2  && CovAceAtomicAwAddr > 6);
           ignore_bins not_legal_8B_addr = Cross_CovAceAtomicCompare_64wdata with (CovAceAtomicAwsize == 2  && CovAceAtomicAwAddr > 16);
           ignore_bins not_legal_4B      = Cross_CovAceAtomicCompare_64wdata with (CovAceAtomicAwsize == 2  && ((CovAceAtomicAwAddr % 2) != 0));
           ignore_bins not_legal_8B      = Cross_CovAceAtomicCompare_64wdata with (CovAceAtomicAwsize == 3  && ((CovAceAtomicAwAddr % 4) != 0));
           ignore_bins not_legal_len     = Cross_CovAceAtomicCompare_64wdata with (CovAceAtomicAwlen == 3  && (CovAceAtomicAwAddr != 0 && CovAceAtomicAwAddr != 16) );
           ignore_bins not_legal_len1    = Cross_CovAceAtomicCompare_64wdata with (CovAceAtomicAwlen == 1  && (((CovAceAtomicAwAddr % 8) != 0)  || CovAceAtomicAwsize !=3));
           ignore_bins not_legal_len2    = Cross_CovAceAtomicCompare_64wdata with (CovAceAtomicAwlen != 0  && CovAceAtomicAwsize == 2 );
           ignore_bins not_legal_special = Cross_CovAceAtomicCompare_64wdata with (CovAceAtomicAwAddr == 4  && CovAceAtomicAwsize == 2 && CovAceAtomicAwBurst ==2);
           ignore_bins not_legal_special2 = Cross_CovAceAtomicCompare_64wdata with (CovAceAtomicAwAddr == 16  && CovAceAtomicAwBurst ==1);
           ignore_bins not_legal_special3 = Cross_CovAceAtomicCompare_64wdata with (CovAceAtomicAwAddr == 16  && CovAceAtomicAwlen != 3);
       }
     <%}%>
     <% if (wdata128) { %>
       Cross_CovAceAtomicCompare_128wdata : cross CovAceDataWidth,CovAceAtomicAwAddr,CovAceAtomicAwsize,CovAceAtomicAwlen,CovAceAtomicAwBurst {
           ignore_bins not_legal_addr       = Cross_CovAceAtomicCompare_128wdata with (CovAceAtomicAwAddr > 16);
           ignore_bins not_legal_width     = Cross_CovAceAtomicCompare_128wdata with (CovAceDataWidth != 128);
           ignore_bins not_legal_size     = Cross_CovAceAtomicCompare_128wdata with (CovAceAtomicAwsize > 4);
           ignore_bins not_legal_len       = Cross_CovAceAtomicCompare_128wdata with (CovAceAtomicAwlen > 1);
           ignore_bins not_legal_awlen_1   = Cross_CovAceAtomicCompare_128wdata with (CovAceAtomicAwlen == 1 && CovAceAtomicAwsize < 4);
           ignore_bins not_legal_awlen_2   = Cross_CovAceAtomicCompare_128wdata with (CovAceAtomicAwlen == 1 && aiu_awaddr[3:0] != 0);
           ignore_bins not_legal_incr      = Cross_CovAceAtomicCompare_128wdata with ((CovAceAtomicAwAddr % ((CovAceAtomicAwlen+1)*(2**CovAceAtomicAwsize))) != 0 && CovAceAtomicAwBurst == 1);
           ignore_bins not_legal_wrap      = Cross_CovAceAtomicCompare_128wdata with ((CovAceAtomicAwAddr % ((CovAceAtomicAwlen+1)*(2**CovAceAtomicAwsize))) == 0 && CovAceAtomicAwBurst == 2);
           ignore_bins not_legal_4B      = Cross_CovAceAtomicCompare_128wdata with (CovAceAtomicAwsize == 2  && ((CovAceAtomicAwAddr % 2) != 0));
           ignore_bins not_legal_8B      = Cross_CovAceAtomicCompare_128wdata with (CovAceAtomicAwsize == 3  && ((CovAceAtomicAwAddr % 4) != 0));
           ignore_bins not_legal_16B     = Cross_CovAceAtomicCompare_128wdata with (CovAceAtomicAwsize == 4  && ((CovAceAtomicAwAddr % 8) != 0));
           ignore_bins not_legal_16B_ext     = Cross_CovAceAtomicCompare_128wdata with (CovAceAtomicAwAddr == 8 && CovAceAtomicAwlen ==1);
           ignore_bins not_legal_16B_size      = Cross_CovAceAtomicCompare_128wdata with (CovAceAtomicAwsize < 4  && CovAceAtomicAwAddr == 16);
           ignore_bins not_legal_16B_incr      = Cross_CovAceAtomicCompare_128wdata with (CovAceAtomicAwAddr == 16 && CovAceAtomicAwBurst ==1);
           ignore_bins not_legal_16B_len2      = Cross_CovAceAtomicCompare_128wdata with (CovAceAtomicAwAddr == 16 && CovAceAtomicAwlen ==0);
       }
     <%}%>
      <% if (wdata256) { %>
       Cross_CovAceAtomicCompare_256wdata : cross CovAceDataWidth,CovAceAtomicAwAddr,CovAceAtomicAwsize,CovAceAtomicAwlen,CovAceAtomicAwBurst {
           ignore_bins not_legal_width   = Cross_CovAceAtomicCompare_256wdata with (CovAceDataWidth != 256);
           ignore_bins not_legal_len     = Cross_CovAceAtomicCompare_256wdata with (CovAceAtomicAwlen != 0);
           ignore_bins not_legal_incr    = Cross_CovAceAtomicCompare_256wdata with ((CovAceAtomicAwAddr % ((CovAceAtomicAwlen+1)*(2**CovAceAtomicAwsize))) != 0 && CovAceAtomicAwBurst == 1);
           ignore_bins not_legal_wrap    = Cross_CovAceAtomicCompare_256wdata with ((CovAceAtomicAwAddr % ((CovAceAtomicAwlen+1)*(2**CovAceAtomicAwsize))) == 0 && CovAceAtomicAwBurst == 2);
           ignore_bins not_legal_4B      = Cross_CovAceAtomicCompare_256wdata with (CovAceAtomicAwsize == 2  && ((CovAceAtomicAwAddr % 2) != 0));
           ignore_bins not_legal_8B      = Cross_CovAceAtomicCompare_256wdata with (CovAceAtomicAwsize == 3  && ((CovAceAtomicAwAddr % 4) != 0));
           ignore_bins not_legal_16B     = Cross_CovAceAtomicCompare_256wdata with (CovAceAtomicAwsize == 4  && ((CovAceAtomicAwAddr % 8) != 0));
           ignore_bins not_legal_32B     = Cross_CovAceAtomicCompare_256wdata with (CovAceAtomicAwsize == 5  && ((CovAceAtomicAwAddr % 16) != 0));
       }
     <%}%>
     <% if (wdata512) { %>
       Cross_CovAceAtomicCompare_512wdata : cross CovAceDataWidth,CovAceAtomicAwAddr,CovAceAtomicAwsize,CovAceAtomicAwlen,CovAceAtomicAwBurst {
           ignore_bins not_legal_width   = Cross_CovAceAtomicCompare_512wdata with (CovAceDataWidth != 512);
           ignore_bins not_legal_len     = Cross_CovAceAtomicCompare_512wdata with (CovAceAtomicAwlen != 0);
           ignore_bins not_legal_incr    = Cross_CovAceAtomicCompare_512wdata with ((CovAceAtomicAwAddr % ((CovAceAtomicAwlen+1)*(2**CovAceAtomicAwsize))) != 0 && CovAceAtomicAwBurst == 1);
           ignore_bins not_legal_wrap    = Cross_CovAceAtomicCompare_512wdata with ((CovAceAtomicAwAddr % ((CovAceAtomicAwlen+1)*(2**CovAceAtomicAwsize))) == 0 && CovAceAtomicAwBurst == 2);
           ignore_bins not_legal_4B      = Cross_CovAceAtomicCompare_512wdata with (CovAceAtomicAwsize == 2  && ((CovAceAtomicAwAddr % 2) != 0));
           ignore_bins not_legal_8B      = Cross_CovAceAtomicCompare_512wdata with (CovAceAtomicAwsize == 3  && ((CovAceAtomicAwAddr % 4) != 0));
           ignore_bins not_legal_16B     = Cross_CovAceAtomicCompare_512wdata with (CovAceAtomicAwsize == 4  && ((CovAceAtomicAwAddr % 8) != 0));
           ignore_bins not_legal_32B     = Cross_CovAceAtomicCompare_512wdata with (CovAceAtomicAwsize == 5  && ((CovAceAtomicAwAddr % 16) != 0));
       }
     <%}%>

`else
      <% if (wdata64) { %>
       Cross_CovAceAtomicCompare_64wdata : cross CovAceDataWidth,CovAceAtomicAwAddr,CovAceAtomicAwsize,CovAceAtomicAwlen,CovAceAtomicAwBurst {
           ignore_bins not_legal_addr       = Cross_CovAceAtomicCompare_64wdata with (CovAceAtomicAwAddr > 16);
           ignore_bins not_legal_size     = Cross_CovAceAtomicCompare_64wdata with (CovAceAtomicAwsize > 3);
           ignore_bins not_legal_width     = Cross_CovAceAtomicCompare_64wdata with (CovAceDataWidth != 64);
           ignore_bins not_legal_len0      = Cross_CovAceAtomicCompare_64wdata with (CovAceAtomicAwsize < 2 && CovAceAtomicAwlen !=0);
           ignore_bins not_legal_incr      = Cross_CovAceAtomicCompare_64wdata with ((CovAceAtomicAwAddr % ((CovAceAtomicAwlen+1)*(2**CovAceAtomicAwsize))) != 0 && CovAceAtomicAwBurst == 1);
           ignore_bins not_legal_wrap      = Cross_CovAceAtomicCompare_64wdata with ((CovAceAtomicAwAddr % ((CovAceAtomicAwlen+1)*(2**CovAceAtomicAwsize))) == 0 && CovAceAtomicAwBurst == 2);
           ignore_bins not_legal_2B_addr = Cross_CovAceAtomicCompare_64wdata with (CovAceAtomicAwsize == 1  && CovAceAtomicAwAddr > 7);
           ignore_bins not_legal_4B_addr = Cross_CovAceAtomicCompare_64wdata with (CovAceAtomicAwsize == 2  && CovAceAtomicAwAddr > 6);
           ignore_bins not_legal_8B_addr = Cross_CovAceAtomicCompare_64wdata with (CovAceAtomicAwsize == 2  && CovAceAtomicAwAddr > 16);
           ignore_bins not_legal_4B      = Cross_CovAceAtomicCompare_64wdata with (CovAceAtomicAwsize == 2  && CovAceAtomicAwAddr[0] != 0);
           ignore_bins not_legal_8B      = Cross_CovAceAtomicCompare_64wdata with (CovAceAtomicAwsize == 3  && CovAceAtomicAwAddr[1:0] != 0);
           ignore_bins not_legal_len     = Cross_CovAceAtomicCompare_64wdata with (CovAceAtomicAwlen == 3  && (CovAceAtomicAwAddr != 0 && CovAceAtomicAwAddr != 16) );
           ignore_bins not_legal_len1    = Cross_CovAceAtomicCompare_64wdata with (CovAceAtomicAwlen == 1  && (CovAceAtomicAwAddr[2:0] != 0  || CovAceAtomicAwsize !=3));
           ignore_bins not_legal_len2    = Cross_CovAceAtomicCompare_64wdata with (CovAceAtomicAwlen != 0  && CovAceAtomicAwsize == 2 );
           ignore_bins not_legal_special = Cross_CovAceAtomicCompare_64wdata with (CovAceAtomicAwAddr == 4  && CovAceAtomicAwsize == 2 && CovAceAtomicAwBurst ==2);
           ignore_bins not_legal_special2 = Cross_CovAceAtomicCompare_64wdata with (CovAceAtomicAwAddr == 16  && CovAceAtomicAwBurst ==1);
           ignore_bins not_legal_special3 = Cross_CovAceAtomicCompare_64wdata with (CovAceAtomicAwAddr == 16  && CovAceAtomicAwlen != 3);
       }
     <%}%>
     <% if (wdata128) { %>
       Cross_CovAceAtomicCompare_128wdata : cross CovAceDataWidth,CovAceAtomicAwAddr,CovAceAtomicAwsize,CovAceAtomicAwlen,CovAceAtomicAwBurst {
           ignore_bins not_legal_addr       = Cross_CovAceAtomicCompare_128wdata with (CovAceAtomicAwAddr > 16);
           ignore_bins not_legal_width     = Cross_CovAceAtomicCompare_128wdata with (CovAceDataWidth != 128);
           ignore_bins not_legal_size     = Cross_CovAceAtomicCompare_128wdata with (CovAceAtomicAwsize > 4);
           ignore_bins not_legal_len       = Cross_CovAceAtomicCompare_128wdata with (CovAceAtomicAwlen > 1);
           ignore_bins not_legal_awlen_1   = Cross_CovAceAtomicCompare_128wdata with (CovAceAtomicAwlen == 1 && CovAceAtomicAwsize < 4);
           ignore_bins not_legal_awlen_2   = Cross_CovAceAtomicCompare_128wdata with (CovAceAtomicAwlen == 1 && CovAceAtomicAwAddr[3:0] != 0);
           ignore_bins not_legal_incr      = Cross_CovAceAtomicCompare_128wdata with ((CovAceAtomicAwAddr % ((CovAceAtomicAwlen+1)*(2**CovAceAtomicAwsize))) != 0 && CovAceAtomicAwBurst == 1);
           ignore_bins not_legal_wrap      = Cross_CovAceAtomicCompare_128wdata with ((CovAceAtomicAwAddr % ((CovAceAtomicAwlen+1)*(2**CovAceAtomicAwsize))) == 0 && CovAceAtomicAwBurst == 2);
           ignore_bins not_legal_4B      = Cross_CovAceAtomicCompare_128wdata with (CovAceAtomicAwsize == 2  && CovAceAtomicAwAddr[0] != 0);
           ignore_bins not_legal_8B      = Cross_CovAceAtomicCompare_128wdata with (CovAceAtomicAwsize == 3  && CovAceAtomicAwAddr[1:0] != 0);
           ignore_bins not_legal_16B      = Cross_CovAceAtomicCompare_128wdata with (CovAceAtomicAwsize == 4  && CovAceAtomicAwAddr[2:0] != 0);
           ignore_bins not_legal_16B_ext     = Cross_CovAceAtomicCompare_128wdata with (CovAceAtomicAwAddr == 8 && CovAceAtomicAwlen ==1);
           ignore_bins not_legal_16B_size      = Cross_CovAceAtomicCompare_128wdata with (CovAceAtomicAwsize < 4  && CovAceAtomicAwAddr == 16);
           ignore_bins not_legal_16B_incr      = Cross_CovAceAtomicCompare_128wdata with (CovAceAtomicAwAddr == 16 && CovAceAtomicAwBurst ==1);
           ignore_bins not_legal_16B_len2      = Cross_CovAceAtomicCompare_128wdata with (CovAceAtomicAwAddr == 16 && CovAceAtomicAwlen ==0);
       }
     <%}%>
      <% if (wdata256) { %>
       Cross_CovAceAtomicCompare_256wdata : cross CovAceDataWidth,CovAceAtomicAwAddr,CovAceAtomicAwsize,CovAceAtomicAwlen,CovAceAtomicAwBurst {
           ignore_bins not_legal_width     = Cross_CovAceAtomicCompare_256wdata with (CovAceDataWidth != 256);
           ignore_bins not_legal_len     = Cross_CovAceAtomicCompare_256wdata with (CovAceAtomicAwlen != 0);
           ignore_bins not_legal_incr      = Cross_CovAceAtomicCompare_256wdata with ((CovAceAtomicAwAddr % ((CovAceAtomicAwlen+1)*(2**CovAceAtomicAwsize))) != 0 && CovAceAtomicAwBurst == 1);
           ignore_bins not_legal_wrap      = Cross_CovAceAtomicCompare_256wdata with ((CovAceAtomicAwAddr % ((CovAceAtomicAwlen+1)*(2**CovAceAtomicAwsize))) == 0 && CovAceAtomicAwBurst == 2);
           ignore_bins not_legal_4B      = Cross_CovAceAtomicCompare_256wdata with (CovAceAtomicAwsize == 2  && CovAceAtomicAwAddr[0] != 0);
           ignore_bins not_legal_8B      = Cross_CovAceAtomicCompare_256wdata with (CovAceAtomicAwsize == 3  && CovAceAtomicAwAddr[1:0] != 0);
           ignore_bins not_legal_16B      = Cross_CovAceAtomicCompare_256wdata with (CovAceAtomicAwsize == 4  && CovAceAtomicAwAddr[2:0] != 0);
           ignore_bins not_legal_32B      = Cross_CovAceAtomicCompare_256wdata with (CovAceAtomicAwsize == 5  && CovAceAtomicAwAddr[3:0] != 0);
       }
     <%}%>
`endif     
     <%}%>
    endgroup
<%}%>    
/////////////////////////////////////////////////////////////////////////////////////
//    #    # ###### ##### #    #  ####  #####   ####  
//    ##  ## #        #   #    # #    # #    # #      
//    # ## # #####    #   ###### #    # #    #  ####  
//    #    # #        #   #    # #    # #    #      # 
//    #    # #        #   #    # #    # #    # #    # 
//    #    # ######   #   #    #  ####  #####   ####  
////////////////////////////////////////////////////////////////////////////////////
                                                    
    function new(); 
       void'($value$plusargs("sample_dvm_func_cov=%0d",sample_dvm_func_cov));
       //covergroup
       cg_native_itf_cmd = new();
       cg_native_itf_resp = new();
<% if (dmi_useAtomic && ((numAceLiteE>0) || (num_AXI5_atomic>0) || (num_AXI5_with_owo_512b>0) || (num_AXI5_with_owo_256b>0))) {%>     
      cg_native_itf_atomic_compare = new();
<% }%>
<% if (numIoAiu) {%>
       cg_axlen = new();
<% }%>
<% if (numIoAiu) {%>
       cg_axlen = new();
`ifdef FSYS_COV_INCL_DVM_BINS
       cg_ioaiu_cross_dvm_version = new();
    <% if(DVMV8_1 || DVMV8_4) {%>
       cg_ioaiu_dvm_field_dvmV81 = new();
    <% } %>
    <% if(DVMV8_4) {%>
       cg_ioaiu_dvm_field_dvmV84 = new();
    <% } %>
`endif // `ifdef FSYS_COV_INCL_DVM_BINS
<% }%>
<% if (numChiAiu) {%>
`ifdef FSYS_COV_INCL_DVM_BINS
       cg_chiaiu_cross_dvm_version = new();
    <% if(DVMV8_1 || DVMV8_4) {%>
       cg_chiaiu_dvm_field_dvmV81 = new();
    <% } %>
    <% if(DVMV8_4) {%>
       cg_chiaiu_dvm_field_dvmV84 = new();
    <% } %>
`endif // `ifdef FSYS_COV_INCL_DVM_BINS
<% }%>
    endfunction:new
<%for(var pidx = 0; pidx < nALLs; pidx++) { %> 
    // test<%=pidx%> : <%=_child[pidx].fnNativeInterface%>
<%}%>
    // ALL FUNCTIONS
    extern function void reset_fcov_dvm_var();
<% if (numIoAiu) {%>
    extern function void sample_ioaiu_cmd_dvm_fcov(bit ioaiu_num=0,bit [63:0]val=0, bit[3:0] vmidext);
    extern function void sample_ioaiu_snp_dvm_fcov(bit ioaiu_num=0,bit [63:0]val=0, bit[3:0] vmidext);
<% }%>
<% if (numChiAiu) {%>
    extern function void sample_chiaiu_cmd_dvm_fcov(bit extract_from_req=0, bit [63:0]val=0);
    extern function void sample_chiaiu_snp_dvm_fcov(bit [63:0]val=0, bit[11:0] fwdnid, bit[7:0] vmidext);
<% }%>
<%for(var pidx = 0; pidx < nALLs; pidx++) { %>
   <%if (typeof _child[pidx].fnNativeInterface !== 'undefined')  {%>
    <%if(_child[pidx].fnNativeInterface.includes("CHI")) { // CHI interface%>
    extern function void collect_item_req_<%=_child_blkid[pidx]%>(<%=_child_blkid[pidx]%>_env_pkg::chi_req_seq_item m_pkt);
    extern function void collect_item_snpaddr_<%=_child_blkid[pidx]%>(<%=_child_blkid[pidx]%>_env_pkg::chi_snp_seq_item m_pkt);
    extern function void collect_item_data_resp_<%=_child_blkid[pidx]%>(<%=_child_blkid[pidx]%>_env_pkg::chi_dat_seq_item m_pkt);
    extern function void collect_item_snp_wdat_resp_<%=_child_blkid[pidx]%>(<%=_child_blkid[pidx]%>_env_pkg::chi_dat_seq_item m_pkt);
    extern function void collect_item_snp_srsp_resp_<%=_child_blkid[pidx]%>(<%=_child_blkid[pidx]%>_env_pkg::chi_rsp_seq_item m_pkt);
    extern function void collect_item_cresp_<%=_child_blkid[pidx]%>(<%=_child_blkid[pidx]%>_env_pkg::chi_rsp_seq_item m_pkt);
    <%} else { // No CHI%>
    extern function void collect_item_wr_<%=_child_blkid[pidx]%>(<%=_child_blkid[pidx]%>_env_pkg::axi4_write_addr_pkt_t m_pkt);
    extern function void collect_item_bresp_<%=_child_blkid[pidx]%>(<%=_child_blkid[pidx]%>_env_pkg::axi4_write_resp_pkt_t m_pkt);
    extern function void collect_item_rd_<%=_child_blkid[pidx]%>(<%=_child_blkid[pidx]%>_env_pkg::axi4_read_addr_pkt_t m_pkt);
    extern function void collect_item_rd_data_<%=_child_blkid[pidx]%>(<%=_child_blkid[pidx]%>_env_pkg::axi4_read_data_pkt_t m_pkt);
    <%if(Array.isArray(_child[pidx].interfaces.axiInt)){
               computedAxiInt = _child[pidx].interfaces.axiInt[0];
    }else{
               computedAxiInt = _child[pidx].interfaces.axiInt;
    }%>
    <%if((_child[pidx].fnNativeInterface == 'AXI4') || (_child[pidx].fnNativeInterface == 'AXI5') || _child[pidx].fnNativeInterface.includes("ACE") || _child[pidx].fnNativeInterface == 'ACE5' || _child[pidx].fnNativeInterface == 'ACELITE-E' || _child[pidx].fnNativeInterface == 'ACE-LITE' || ((_child[pidx].fnNativeInterface == 'AXI5') && (computedAxiInt.params.atomicTransactions==true))) {%>
<% if(_child_blk[pidx].match('ioaiu') ) { %>
    extern function ace_command_types_enum_t ace_rd_cmd_type_<%=_child_blkid[pidx]%>(<%=_child_blkid[pidx]%>_env_pkg::axi4_read_addr_pkt_t m_pkt);
    extern function ace_command_types_enum_t ace_wr_cmd_type_<%=_child_blkid[pidx]%>(<%=_child_blkid[pidx]%>_env_pkg::axi4_write_addr_pkt_t m_pkt);
    <% }} // includes ACE %>
    <%if(_child[pidx].fnNativeInterface == 'ACE' || _child[pidx].fnNativeInterface == 'ACE5' ||_child[pidx].fnNativeInterface == "ACELITE-E") {%>
    <% if(_child[pidx].interfaces.axiInt.params.eAc==1 && (_child[pidx].fnNativeInterface == "ACE5" ||_child[pidx].fnNativeInterface == "ACE" || _child[pidx].fnNativeInterface == "ACELITE-E")){ %>
    extern function void collect_item_snp_<%=_child_blkid[pidx]%>(<%=_child_blkid[pidx]%>_env_pkg::ace_snoop_addr_pkt_t m_pkt);
    <%}%>
    extern function void collect_item_sresp_<%=_child_blkid[pidx]%>(<%=_child_blkid[pidx]%>_env_pkg::ace_snoop_resp_pkt_t m_pkt);
    <% } // only ACE%>
    <% } // CHI else %>
    <% } // only NATIVE%>
<%} // all agents%>
endclass:Fsys_native_itf_coverage

///////////////////////////////////////////////////////////////////////////////////
//  ###### #    # #    #  ####  ##### #  ####  #    #  ####  
//  #      #    # ##   # #    #   #   # #    # ##   # #      
//  #####  #    # # #  # #        #   # #    # # #  #  ####  
//  #      #    # #  # # #        #   # #    # #  # #      # 
//  #      #    # #   ## #    #   #   # #    # #   ## #    # 
//  #       ####  #    #  ####    #   #  ####  #    #  ####  
//////////////////////////////////////////////////////////////////////////////////
    function void Fsys_native_itf_coverage::reset_fcov_dvm_var();
    <% if (numIoAiu) {%>
    <% if(DVMV8_1 || DVMV8_4) {%>
        ioaiu_cmd_dvm_field_vmidext = 0;
        ioaiu_snp_dvm_field_vmidext = 0;
    <% } %>
    <% if(DVMV8_4) {%>
        ioaiu_cmd_dvm_field_num     = 0;
        ioaiu_cmd_dvm_field_range   = 0;
        ioaiu_cmd_dvm_field_scale   = 0;
        ioaiu_snp_dvm_field_num     = 0;
        ioaiu_snp_dvm_field_range   = 0;
        ioaiu_snp_dvm_field_scale   = 0;
    <% } %>
    <% if(DVMV8_0) {%>
        ioaiu_captured_cmd_dvmV80 = 0;
        ioaiu_captured_snp_dvmV80 = 0;
    <% } %>
    <% if(DVMV8_1) {%>
        ioaiu_captured_cmd_dvmV81 = 0;
        ioaiu_captured_snp_dvmV81 = 0;
    <% } %>
    <% if(DVMV8_4) {%>
        ioaiu_captured_snp_dvmV84 = 0;
        ioaiu_captured_cmd_dvmV84 = 0;
    <% } %>
    <% } %>
    <% if (numChiAiu) {%>
    <% if(DVMV8_1 || DVMV8_4) {%>
        chiaiu_cmd_req_dvm_field_vmidext = 0;
        chiaiu_snp_req_dvm_field_vmidext = 0;
    <% } %>
    <% if(DVMV8_4) {%>
        chiaiu_cmd_req_dvm_field_num     = 0;
        chiaiu_cmd_req_dvm_field_range   = 0;
        chiaiu_cmd_req_dvm_field_scale   = 0;
        chiaiu_snp_req_dvm_field_num     = 0;
        chiaiu_snp_req_dvm_field_range   = 0;
        chiaiu_snp_req_dvm_field_scale   = 0;
    <% } %>
    <% if(DVMV8_0) {%>
        chiaiu_captured_cmd_req_dvmV80 = 0;
        chiaiu_captured_snp_req_dvmV80 = 0;
    <% } %>
    <% if(DVMV8_1) {%>
        chiaiu_captured_cmd_req_dvmV81 = 0;
        chiaiu_captured_snp_req_dvmV81 = 0;
    <% } %>
    <% if(DVMV8_4) {%>
        chiaiu_captured_cmd_req_dvmV84 = 0;
        chiaiu_captured_snp_req_dvmV84 = 0;
    <% } %>
    <% } %>
    endfunction 

<% if (numIoAiu) {%>
    function void Fsys_native_itf_coverage::sample_ioaiu_cmd_dvm_fcov(bit ioaiu_num=0, bit [63:0]val=0, bit[3:0] vmidext);
`ifdef FSYS_COV_INCL_DVM_BINS
    <% if(DVMV8_0) {%>
        ioaiu_captured_cmd_dvmV80 = DVMV8_0;
    <% } %>
    <% if(DVMV8_1) {%>
        ioaiu_captured_cmd_dvmV81 = DVMV8_1;
        ioaiu_cmd_dvm_field_vmidext[3:0] = vmidext;
        ioaiu_cmd_dvm_field_vmidext[7:4] = val[43:40];
        cg_ioaiu_dvm_field_dvmV81.sample();
    <% } %>
    <% if(DVMV8_4) {%>
        ioaiu_captured_cmd_dvmV84 = DVMV8_4;
        ioaiu_cmd_dvm_field_range   = val[7];
        if(ioaiu_dvm_part_num[ioaiu_num][0]==0)  begin 
            ioaiu_dvm_two_part_msg[ioaiu_num] = val[0];
            if(ioaiu_dvm_two_part_msg[ioaiu_num]) ioaiu_dvm_part_num[ioaiu_num][0] = 1;
        end else if(ioaiu_dvm_part_num[ioaiu_num][0]==1) begin
            if(ioaiu_dvm_two_part_msg[ioaiu_num]) ioaiu_dvm_part_num[ioaiu_num][1] = 1;
        end
        if(ioaiu_dvm_two_part_msg[ioaiu_num] && ioaiu_dvm_part_num[ioaiu_num][0]==1 && ioaiu_dvm_part_num[ioaiu_num][1]==0)  begin  // part-1
            ioaiu_cmd_dvm_field_vmidext[3:0] = vmidext;
        end else if(ioaiu_dvm_two_part_msg[ioaiu_num] && ioaiu_dvm_part_num[ioaiu_num][1]==1) begin // part-2
            ioaiu_cmd_dvm_field_vmidext[7:4] = vmidext;
            ioaiu_cmd_dvm_field_num     = {val[5:4],val[2:0]};
            ioaiu_cmd_dvm_field_scale   = val[7:6];
            ioaiu_dvm_two_part_msg[ioaiu_num] = 0;
            ioaiu_dvm_part_num[ioaiu_num]  = 0;
        end
        cg_ioaiu_dvm_field_dvmV81.sample();
        cg_ioaiu_dvm_field_dvmV84.sample();
    <% } %>
        cg_ioaiu_cross_dvm_version.sample();
        reset_fcov_dvm_var();
`endif // `ifdef FSYS_COV_INCL_DVM_BINS
    endfunction:sample_ioaiu_cmd_dvm_fcov

    function void Fsys_native_itf_coverage::sample_ioaiu_snp_dvm_fcov(bit ioaiu_num=0,bit [63:0]val=0, bit[3:0] vmidext);
`ifdef FSYS_COV_INCL_DVM_BINS
    <% if(DVMV8_0) {%>
        ioaiu_captured_snp_dvmV80 = DVMV8_0;
    <% } %>
    <% if(DVMV8_1) {%>
        ioaiu_captured_snp_dvmV81 = DVMV8_1;
        ioaiu_snp_dvm_field_vmidext[3:0] = vmidext;
        ioaiu_snp_dvm_field_vmidext[7:4] = val[43:40];
        cg_ioaiu_dvm_field_dvmV81.sample();
    <% } %>
    <% if(DVMV8_4) {%>
        ioaiu_captured_snp_dvmV84 = DVMV8_4;
        ioaiu_snp_dvm_field_range   = val[7];
        if(ioaiu_snp_dvm_part_num[ioaiu_num][0]==0)  begin 
            ioaiu_snp_dvm_two_part_msg[ioaiu_num] = val[0];
            if(ioaiu_snp_dvm_two_part_msg[ioaiu_num]) ioaiu_snp_dvm_part_num[ioaiu_num][0] = 1;
        end else if(ioaiu_snp_dvm_part_num[ioaiu_num][0]==1) begin
            if(ioaiu_snp_dvm_two_part_msg[ioaiu_num]) ioaiu_snp_dvm_part_num[ioaiu_num][1] = 1;
        end
        if(ioaiu_snp_dvm_two_part_msg[ioaiu_num] && ioaiu_snp_dvm_part_num[ioaiu_num][0]==1 && ioaiu_snp_dvm_part_num[ioaiu_num][1]==0)  begin  // part-1
            ioaiu_snp_dvm_field_vmidext[3:0] = vmidext;
        end else if(ioaiu_snp_dvm_two_part_msg[ioaiu_num] && ioaiu_snp_dvm_part_num[ioaiu_num][1]==1) begin // part-2
            ioaiu_snp_dvm_field_vmidext[7:4] = vmidext;
            ioaiu_snp_dvm_field_num     = {val[5:4],val[2:0]};
            ioaiu_snp_dvm_field_scale   = val[7:6];
            ioaiu_snp_dvm_two_part_msg[ioaiu_num] = 0;
            ioaiu_snp_dvm_part_num[ioaiu_num]  = 0;
        end
        cg_ioaiu_dvm_field_dvmV81.sample();
        cg_ioaiu_dvm_field_dvmV84.sample();
    <% } %>
        cg_ioaiu_cross_dvm_version.sample();
        reset_fcov_dvm_var();
`endif // `ifdef FSYS_COV_INCL_DVM_BINS
    endfunction:sample_ioaiu_snp_dvm_fcov
<% }%>

<% if (numChiAiu) {%>
    function void Fsys_native_itf_coverage::sample_chiaiu_snp_dvm_fcov(bit [63:0]val=0, bit[11:0] fwdnid, bit[7:0] vmidext);
`ifdef FSYS_COV_INCL_DVM_BINS
    <% if(DVMV8_0) {%>
        chiaiu_captured_snp_req_dvmV80 = DVMV8_0;
    <% } %>
    <% if(DVMV8_1) {%>
        chiaiu_captured_snp_req_dvmV81 = DVMV8_1;
    <% } %>
    <% if(DVMV8_4) {%>
        chiaiu_captured_snp_req_dvmV84 = DVMV8_4;
    <% } %>
    <% if(DVMV8_1 || DVMV8_4) {%>
        //if(val[3]==0) begin // DVMSnp req part-1
        if(val[0]==0) begin // DVMSnp req part-1
            chiaiu_snp_req_dvm_field_vmidext = vmidext;
    <% if(DVMV8_4) {%>
            chiaiu_snp_req_dvm_field_range = fwdnid[0];
    <% } %>
        //end else if(val[3]==1) begin // DVMSnp req part-2
        end 
    <% if(DVMV8_4) {%>
        else if(val[0]==1) begin // DVMSnp req part-2
            chiaiu_snp_req_dvm_field_num = fwdnid[4:0];
            chiaiu_snp_req_dvm_field_scale = val[2:1];
        end
    <% } %>
        cg_chiaiu_dvm_field_dvmV81.sample();
    <% if(DVMV8_4) {%>
        cg_chiaiu_dvm_field_dvmV84.sample();
    <% } %>
    <% } %>
        cg_chiaiu_cross_dvm_version.sample();
        reset_fcov_dvm_var();
`endif // `ifdef FSYS_COV_INCL_DVM_BINS
    endfunction:sample_chiaiu_snp_dvm_fcov

    function void Fsys_native_itf_coverage::sample_chiaiu_cmd_dvm_fcov(bit extract_from_req=0, bit [63:0]val=0);
`ifdef FSYS_COV_INCL_DVM_BINS
    <% if(DVMV8_0) {%>
        chiaiu_captured_cmd_req_dvmV80 = DVMV8_0;
    <% } %>
    <% if(DVMV8_1) {%>
        chiaiu_captured_cmd_req_dvmV81 = DVMV8_1;
    <% } %>
    <% if(DVMV8_4) {%>
        chiaiu_captured_cmd_req_dvmV84 = DVMV8_4;
    <% } %>
    <% if(DVMV8_1 || DVMV8_4) {%>
        if(extract_from_req==1) begin
    <% if(DVMV8_4) {%>
            chiaiu_cmd_req_dvm_field_num[4] = val[42];
            chiaiu_cmd_req_dvm_field_range = val[41];
    <% } %>
        end else begin
    <% if(DVMV8_4) {%>
            chiaiu_cmd_req_dvm_field_num[3:0] = val[3:0];
            chiaiu_cmd_req_dvm_field_scale    = val[5:4];
    <% } %>
            chiaiu_cmd_req_dvm_field_vmidext  = val[63:56];
        end
        cg_chiaiu_dvm_field_dvmV81.sample();
    <% if(DVMV8_4) {%>
        cg_chiaiu_dvm_field_dvmV84.sample();
    <% } %>
    <% } %>
        cg_chiaiu_cross_dvm_version.sample();
        reset_fcov_dvm_var();
`endif // `ifdef FSYS_COV_INCL_DVM_BINS
    endfunction:sample_chiaiu_cmd_dvm_fcov
<% }%>

<% var ioaiu_idx=0; for(var pidx = 0; pidx < nALLs; pidx++) {%> 
   <%if (typeof _child[pidx].fnNativeInterface !== 'undefined')  {%>
    <%if(Array.isArray(_child[pidx].interfaces.axiInt)){
               computedAxiInt = _child[pidx].interfaces.axiInt[0];
    }else{
               computedAxiInt = _child[pidx].interfaces.axiInt;
    }%>
    <%if((_child[pidx].fnNativeInterface == 'AXI4') || (_child[pidx].fnNativeInterface == 'AXI5') || _child[pidx].fnNativeInterface.includes("ACE") || _child[pidx].fnNativeInterface == 'ACE5' || _child[pidx].fnNativeInterface == 'ACELITE-E' || _child[pidx].fnNativeInterface == 'ACE-LITE' || ((_child[pidx].fnNativeInterface == 'AXI5') && (computedAxiInt.params.atomicTransactions==true))) {%>
<% if(_child_blk[pidx].match('ioaiu') ) { %>
    function ace_command_types_enum_t Fsys_native_itf_coverage::ace_rd_cmd_type_<%=_child_blkid[pidx]%>(<%=_child_blkid[pidx]%>_env_pkg::axi4_read_addr_pkt_t m_pkt);
        if (m_pkt) begin
            <%=_child_blkid[pidx]%>_env_pkg::ace_read_addr_pkt_t m_ace_read_addr_pkt;
            m_ace_read_addr_pkt = new();
            $cast(m_ace_read_addr_pkt, m_pkt);
    
        case({m_ace_read_addr_pkt.arbar[0], m_ace_read_addr_pkt.ardomain, m_ace_read_addr_pkt.arsnoop})
           'b0_00_0000, 'b0_11_0000: ace_rd_cmd_type_<%=_child_blkid[pidx]%> = RDNOSNP;
           'b0_01_0000, 'b0_10_0000: ace_rd_cmd_type_<%=_child_blkid[pidx]%> = RDONCE;
           'b0_01_0001, 'b0_10_0001: ace_rd_cmd_type_<%=_child_blkid[pidx]%> = RDSHRD;
           'b0_01_0010, 'b0_10_0010: ace_rd_cmd_type_<%=_child_blkid[pidx]%> = RDCLN;
           'b0_01_0011, 'b0_10_0011: ace_rd_cmd_type_<%=_child_blkid[pidx]%>= RDNOTSHRDDIR;
           'b0_01_0111, 'b0_10_0111: ace_rd_cmd_type_<%=_child_blkid[pidx]%> = RDUNQ;
           'b0_01_1011, 'b0_10_1011: ace_rd_cmd_type_<%=_child_blkid[pidx]%> = CLNUNQ;
           'b0_01_1100, 'b0_10_1100: ace_rd_cmd_type_<%=_child_blkid[pidx]%> = MKUNQ;
           'b0_00_1000, 'b0_01_1000,
           'b0_10_1000             : ace_rd_cmd_type_<%=_child_blkid[pidx]%> = CLNSHRD;
           'b0_00_1001, 'b0_01_1001,
           'b0_10_1001             : ace_rd_cmd_type_<%=_child_blkid[pidx]%> = CLNINVL;
           'b0_00_1101, 'b0_01_1101,
           'b0_10_1101             : ace_rd_cmd_type_<%=_child_blkid[pidx]%> = MKINVL;
           'b1_00_0000, 'b1_01_0000,
           'b1_10_0000, 'b1_11_0000: ace_rd_cmd_type_<%=_child_blkid[pidx]%> = BARRIER;
           'b0_01_1110, 'b0_10_1110: ace_rd_cmd_type_<%=_child_blkid[pidx]%> = DVMCMPL;
           'b0_01_1111, 'b0_10_1111: ace_rd_cmd_type_<%=_child_blkid[pidx]%> = DVMMSG;
           'b0_00_1010, 'b0_01_1010,
           'b0_10_1010             : ace_rd_cmd_type_<%=_child_blkid[pidx]%> = CLNSHRDPERSIST;
           'b0_01_0101, 'b0_10_0101: ace_rd_cmd_type_<%=_child_blkid[pidx]%> = RDONCEMAKEINVLD;
           'b0_01_0100, 'b0_10_0100: ace_rd_cmd_type_<%=_child_blkid[pidx]%> = RDONCECLNINVLD;
           default             : uvm_report_error("ace_rd_cmd_type_<%=_child_blkid[pidx]%> Fsys coverage", $sformatf("Undefined read address channel snoop type: ID:\
                                                                              0x%0x Addr:0x%0x Bar:0x%0x Domain:0x%0x Snoop:0x%0x"
                                                                          , m_ace_read_addr_pkt.arid, m_ace_read_addr_pkt.araddr, m_ace_read_addr_pkt.arbar, m_ace_read_addr_pkt.ardomain, m_ace_read_addr_pkt.arsnoop),UVM_NONE);
        endcase
        end
    endfunction:ace_rd_cmd_type_<%=_child_blkid[pidx]%>
    
     function ace_command_types_enum_t Fsys_native_itf_coverage::ace_wr_cmd_type_<%=_child_blkid[pidx]%>(<%=_child_blkid[pidx]%>_env_pkg::axi4_write_addr_pkt_t m_pkt);
            if (m_pkt) begin
                <%=_child_blkid[pidx]%>_env_pkg::ace_write_addr_pkt_t m_ace_write_addr_pkt;
                m_ace_write_addr_pkt = new();
                $cast(m_ace_write_addr_pkt, m_pkt);
        if(m_ace_write_addr_pkt.awatop !== 0) begin
               case(m_ace_write_addr_pkt.awatop[5:3])
		           'b010,'b011 : ace_wr_cmd_type_<%=_child_blkid[pidx]%> = ATMSTR;
		           'b100,'b111 : ace_wr_cmd_type_<%=_child_blkid[pidx]%> = ATMLD;
		           'b110       : begin
		              case(m_ace_write_addr_pkt.awatop[2:0])
		                'b000       : ace_wr_cmd_type_<%=_child_blkid[pidx]%> = ATMSWAP;		 
		                'b001       : ace_wr_cmd_type_<%=_child_blkid[pidx]%> = ATMCOMPARE;
                                default             : uvm_report_error("ace_wr_cmd_type_<%=_child_blkid[pidx]%> Fsys coverage", $sformatf("Undefined AWATOP 0x%0b Addr:0x%0x", m_ace_write_addr_pkt.awatop,m_ace_write_addr_pkt.awaddr),UVM_NONE);
		              endcase // case (m_ace_write_addr_pkt.awatop[2:0])
		           end
                           default             : uvm_report_error("ace_wr_cmd_type_<%=_child_blkid[pidx]%> Fsys coverage", $sformatf("Undefined AWATOP 0x%0b Addr:0x%0x", m_ace_write_addr_pkt.awatop,m_ace_write_addr_pkt.awaddr),UVM_NONE);
	                 endcase
        end else begin
            case({m_ace_write_addr_pkt.awsnoop, m_ace_write_addr_pkt.awbar[0], m_ace_write_addr_pkt.awdomain}) 
                'b0_000_0_00,  'b0_000_0_11       : ace_wr_cmd_type_<%=_child_blkid[pidx]%> = WRNOSNP;
                'b0_000_0_01,  'b0_000_0_10       : ace_wr_cmd_type_<%=_child_blkid[pidx]%> = WRUNQ;
                'b0_001_0_01,  'b0_001_0_10       : ace_wr_cmd_type_<%=_child_blkid[pidx]%> = WRLNUNQ;
                'b0_010_0_00,  'b0_010_0_01,
                'b0_010_0_10                      : ace_wr_cmd_type_<%=_child_blkid[pidx]%> = WRCLN;
                'b0_011_0_00,  'b0_011_0_01,
                'b0_011_0_10                      : ace_wr_cmd_type_<%=_child_blkid[pidx]%> = WRBK;
                'b0_100_0_01,  'b0_100_0_10       : ace_wr_cmd_type_<%=_child_blkid[pidx]%> = EVCT;
                'b0_101_0_00,  'b0_101_0_01,
                'b0_101_0_10                      : ace_wr_cmd_type_<%=_child_blkid[pidx]%> = WREVCT;
                'b0_000_1_00,  'b0_000_1_01,
                'b0_000_1_10,  'b0_000_1_11       : ace_wr_cmd_type_<%=_child_blkid[pidx]%> = BARRIER;
                'b1_000_0_01,  'b1_000_0_10       : ace_wr_cmd_type_<%=_child_blkid[pidx]%> = WRUNQPTLSTASH;
                'b1_001_0_01,  'b1_001_0_10       : ace_wr_cmd_type_<%=_child_blkid[pidx]%> = WRUNQFULLSTASH;
                'b1_100_0_01,  'b1_100_0_10       : ace_wr_cmd_type_<%=_child_blkid[pidx]%> = STASHONCESHARED;
                'b1_101_0_01,  'b1_101_0_10       : ace_wr_cmd_type_<%=_child_blkid[pidx]%> = STASHONCEUNQ;
                'b1_110_0_00,  'b1_110_0_01,
                'b1_110_0_10,  'b1_110_0_11       : ace_wr_cmd_type_<%=_child_blkid[pidx]%> = STASHTRANS;
                default           : uvm_report_error("ace_wr_cmd_type_<%=_child_blkid[pidx]%> Fsys coverage", $sformatf("Undefined write address channel snoop type: Act:0x%b ID:0x%0x Addr:0x%0x snoop:%0b Bar:%0b Domain:%0b AtoP:%0b",
                                                      {m_ace_write_addr_pkt.awsnoop, m_ace_write_addr_pkt.awbar[0], m_ace_write_addr_pkt.awdomain},
                                                      m_ace_write_addr_pkt.awid, m_ace_write_addr_pkt.awaddr, m_ace_write_addr_pkt.awsnoop, m_ace_write_addr_pkt.awbar, m_ace_write_addr_pkt.awdomain, m_ace_write_addr_pkt.awatop),UVM_NONE);
              endcase // case ({m_ace_write_addr_pkt.awbar[0], m_ace_write_addr_pkt.awdomain, m_ace_write_addr_pkt.awsnoop})
        end
            end  
     endfunction:ace_wr_cmd_type_<%=_child_blkid[pidx]%>
 <% }} // only ACE%>

 <%if(_child[pidx].fnNativeInterface.includes("CHI")) {  // CHI case%>
function void Fsys_native_itf_coverage::collect_item_req_<%=_child_blkid[pidx]%>(<%=_child_blkid[pidx]%>_env_pkg::chi_req_seq_item m_pkt);
    if (m_pkt) begin
        chi_cmd_req_type = <%=_child_blkid[chi_idx]%>_chi_agent_pkg::chi_req_opcode_enum_t'(m_pkt.opcode); 
        chi_req_size = <%=_child_blkid[chi_idx]%>_chi_agent_pkg::chi_req_size_t'(m_pkt.size);
        chi_addr_critical_dword = m_pkt.addr[5:3];
        if(<%=_child[pidx].interfaces.chiInt.params.wData%> == 128) 
            chi_wdata = chi_wdata_128;
        if(<%=_child[pidx].interfaces.chiInt.params.wData%> == 256) 
            chi_wdata = chi_wdata_256;
        if(chi_cmd_req_type inside {<%=_child_blkid[chi_idx]%>_env_pkg::WRITENOSNPPTL,<%=_child_blkid[chi_idx]%>_env_pkg::WRITENOSNPFULL}) 
            CONC_11133_Cov_chi_wr_rd_opcodes = WrNoSnoop;
        else if(chi_cmd_req_type == <%=_child_blkid[chi_idx]%>_env_pkg::READNOSNP)
            CONC_11133_Cov_chi_wr_rd_opcodes = RdNoSnoop;
        else if(chi_cmd_req_type inside {<%=_child_blkid[chi_idx]%>_env_pkg::WRITEUNIQUEPTL,<%=_child_blkid[chi_idx]%>_env_pkg::WRITEUNIQUEFULL})
            CONC_11133_Cov_chi_wr_rd_opcodes = WrUnique;
        else if(chi_cmd_req_type == <%=_child_blkid[chi_idx]%>_env_pkg::READONCE)
            CONC_11133_Cov_chi_wr_rd_opcodes = RdOnce;

        if(chi_cmd_req_type == <%=_child_blkid[chi_idx]%>_env_pkg::ATOMICLOAD_LDADD)
            CONC_11504_Cov_chi_atomic_opcodes = CHI_ATOMICLOAD_LDADD;
        else if(chi_cmd_req_type == <%=_child_blkid[chi_idx]%>_env_pkg::ATOMICLOAD_LDCLR)
            CONC_11504_Cov_chi_atomic_opcodes = CHI_ATOMICLOAD_LDCLR;
        else if(chi_cmd_req_type == <%=_child_blkid[chi_idx]%>_env_pkg::ATOMICLOAD_LDEOR)
            CONC_11504_Cov_chi_atomic_opcodes = CHI_ATOMICLOAD_LDEOR;
        else if(chi_cmd_req_type == <%=_child_blkid[chi_idx]%>_env_pkg::ATOMICLOAD_LDSET)
            CONC_11504_Cov_chi_atomic_opcodes = CHI_ATOMICLOAD_LDSET;
        else if(chi_cmd_req_type == <%=_child_blkid[chi_idx]%>_env_pkg::ATOMICLOAD_LDSMAX)
            CONC_11504_Cov_chi_atomic_opcodes = CHI_ATOMICLOAD_LDSMAX;
        else if(chi_cmd_req_type == <%=_child_blkid[chi_idx]%>_env_pkg::ATOMICLOAD_LDMIN)
            CONC_11504_Cov_chi_atomic_opcodes = CHI_ATOMICLOAD_LDMIN;
        else if(chi_cmd_req_type == <%=_child_blkid[chi_idx]%>_env_pkg::ATOMICLOAD_LDUSMAX)
            CONC_11504_Cov_chi_atomic_opcodes = CHI_ATOMICLOAD_LDUSMAX;
        else if(chi_cmd_req_type == <%=_child_blkid[chi_idx]%>_env_pkg::ATOMICLOAD_LDUMIN)
            CONC_11504_Cov_chi_atomic_opcodes = CHI_ATOMICLOAD_LDUMIN;
        else if(chi_cmd_req_type == <%=_child_blkid[chi_idx]%>_env_pkg::ATOMICSTORE_STADD)
            CONC_11504_Cov_chi_atomic_opcodes = CHI_ATOMICSTORE_STADD;
        else if(chi_cmd_req_type == <%=_child_blkid[chi_idx]%>_env_pkg::ATOMICSTORE_STCLR)
            CONC_11504_Cov_chi_atomic_opcodes = CHI_ATOMICSTORE_STCLR;
        else if(chi_cmd_req_type == <%=_child_blkid[chi_idx]%>_env_pkg::ATOMICSTORE_STEOR)
            CONC_11504_Cov_chi_atomic_opcodes = CHI_ATOMICSTORE_STEOR;
        else if(chi_cmd_req_type == <%=_child_blkid[chi_idx]%>_env_pkg::ATOMICSTORE_STSET)
            CONC_11504_Cov_chi_atomic_opcodes = CHI_ATOMICSTORE_STSET;
        else if(chi_cmd_req_type == <%=_child_blkid[chi_idx]%>_env_pkg::ATOMICSTORE_STSMAX)
            CONC_11504_Cov_chi_atomic_opcodes = CHI_ATOMICSTORE_STSMAX;
        else if(chi_cmd_req_type == <%=_child_blkid[chi_idx]%>_env_pkg::ATOMICSTORE_STMIN)
            CONC_11504_Cov_chi_atomic_opcodes = CHI_ATOMICSTORE_STMIN;
        else if(chi_cmd_req_type == <%=_child_blkid[chi_idx]%>_env_pkg::ATOMICSTORE_STUSMAX)
            CONC_11504_Cov_chi_atomic_opcodes = CHI_ATOMICSTORE_STUSMAX;
        else if(chi_cmd_req_type == <%=_child_blkid[chi_idx]%>_env_pkg::ATOMICSTORE_STUMIN)
            CONC_11504_Cov_chi_atomic_opcodes = CHI_ATOMICSTORE_STUMIN;
        else if(chi_cmd_req_type == <%=_child_blkid[chi_idx]%>_env_pkg::ATOMICSWAP)
            CONC_11504_Cov_chi_atomic_opcodes = CHI_ATOMICSWAP;
        else if(chi_cmd_req_type == <%=_child_blkid[chi_idx]%>_env_pkg::ATOMICCOMPARE)
            CONC_11504_Cov_chi_atomic_opcodes = CHI_ATOMICCOMPARE;

        cg_native_itf_cmd.sample();
        if(m_pkt.opcode inside {<%=_child_blkid[pidx]%>_env_pkg::DVMOP} && sample_dvm_func_cov) begin
            sample_chiaiu_cmd_dvm_fcov(
            1,
            m_pkt.addr
            );
        end
    end
endfunction:collect_item_req_<%=_child_blkid[pidx]%>

function void Fsys_native_itf_coverage::collect_item_snpaddr_<%=_child_blkid[pidx]%>(<%=_child_blkid[pidx]%>_env_pkg::chi_snp_seq_item m_pkt);
    if (m_pkt.opcode == <%=_child_blkid[pidx]%>_env_pkg::SNPDVMOP) begin
            sample_chiaiu_snp_dvm_fcov(
            m_pkt.addr,
            m_pkt.fwdnid,
            m_pkt.vmidext
            );
    end
endfunction:collect_item_snpaddr_<%=_child_blkid[pidx]%>

function void collect_item_wdata_<%=_child_blkid[pidx]%>(<%=_child_blkid[pidx]%>_env_pkg::chi_dat_seq_item m_pkt);
    if (m_pkt) begin
    end
endfunction:collect_item_wdata_<%=_child_blkid[pidx]%>

function void Fsys_native_itf_coverage::collect_item_data_resp_<%=_child_blkid[pidx]%>(<%=_child_blkid[pidx]%>_env_pkg::chi_dat_seq_item m_pkt);
    if (m_pkt) begin
        chi_data_resperr = <%=_child_blkid[chi_idx]%>_chi_agent_pkg::chi_dat_resperr_t'(m_pkt.resperr); 
        cg_native_itf_resp.sample();
    end
endfunction:collect_item_data_resp_<%=_child_blkid[pidx]%>   

function void Fsys_native_itf_coverage::collect_item_snp_wdat_resp_<%=_child_blkid[pidx]%>(<%=_child_blkid[pidx]%>_env_pkg::chi_dat_seq_item m_pkt);
    if (m_pkt) begin
        chi_snp_wdat_resperr = <%=_child_blkid[chi_idx]%>_chi_agent_pkg::chi_rsp_resperr_t'(m_pkt.resperr);
        cg_native_itf_resp.sample();
        if (((m_pkt.opcode != <%=_child_blkid[pidx]%>_env_pkg::SNPRESPDATA)
            && (m_pkt.opcode != <%=_child_blkid[pidx]%>_env_pkg::SNPRESPDATAPTL)
            && (m_pkt.opcode != <%=_child_blkid[pidx]%>_env_pkg::SNPRESPDATAFWDED))  && sample_dvm_func_cov) begin
            sample_chiaiu_cmd_dvm_fcov(
            0,
            m_pkt.data  
            );
        end
    end
endfunction:collect_item_snp_wdat_resp_<%=_child_blkid[pidx]%>   

function void Fsys_native_itf_coverage::collect_item_snp_srsp_resp_<%=_child_blkid[pidx]%>(<%=_child_blkid[pidx]%>_env_pkg::chi_rsp_seq_item m_pkt);
    if (m_pkt) begin
        chi_snp_sresp_resperr = <%=_child_blkid[chi_idx]%>_chi_agent_pkg::chi_rsp_resperr_t'(m_pkt.resperr);
        cg_native_itf_resp.sample();
    end
endfunction:collect_item_snp_srsp_resp_<%=_child_blkid[pidx]%>   
function void Fsys_native_itf_coverage::collect_item_cresp_<%=_child_blkid[pidx]%>(<%=_child_blkid[pidx]%>_env_pkg::chi_rsp_seq_item m_pkt);
    if (m_pkt) begin
        chi_cresperr = <%=_child_blkid[chi_idx]%>_chi_agent_pkg::chi_rsp_resperr_t'(m_pkt.resperr); 
        cg_native_itf_resp.sample();
    end
endfunction:collect_item_cresp_<%=_child_blkid[pidx]%>   
<% } // includes CHI%>

 <%if(_child[pidx].fnNativeInterface == 'ACELITE-E' || _child[pidx].fnNativeInterface.includes("AXI") ||  _child[pidx].fnNativeInterface == 'ACE5' || _child[pidx].fnNativeInterface.includes("ACE")) {  // AXI4( including DMI & DII ) & ACE case%>

function void Fsys_native_itf_coverage::collect_item_wr_<%=_child_blkid[pidx]%>(<%=_child_blkid[pidx]%>_env_pkg::axi4_write_addr_pkt_t m_pkt);
<% if(_child_blk[pidx].match('ioaiu') ) { %>
bit owo_en;
// #Cover.FSYS.v371.amba5_owo_wData
    if(<%=_child[pidx].wData%>== 64)
        axi_ace_wdata = axi_ace_wdata_64;
    else if(<%=_child[pidx].wData%>==128)    
        axi_ace_wdata = axi_ace_wdata_128;
    else if(<%=_child[pidx].wData%>==256)    
        axi_ace_wdata = axi_ace_wdata_256;
<%}%>
    if (m_pkt) begin
<% if(_child_blk[pidx].match('ioaiu') ) { %>
        aiu_awlen      = m_pkt.awlen;
        axi_ace_awaddr_critical_dword = m_pkt.awaddr[5:3];
    <%if((_child[pidx].fnNativeInterface == 'AXI4') || (_child[pidx].fnNativeInterface == 'AXI5') || (_child[pidx].fnNativeInterface == 'ACE-LITE') || (_child[pidx].fnNativeInterface == 'ACELITE-E')) {%>
        CONC_11133_Cov_axi_ace_wr_rd_opcodes = Axi5_Axi4_Write;
        ace_xxx_cmd_type = ace_wr_cmd_type_<%=_child_blkid[pidx]%>(m_pkt);
       <%if(_child[pidx].orderedWriteObservation==true) {%>
        owo_en = 1;
        if(<%=_child[pidx].wData%>==512)    
            axi_ace_wdata = axi_ace_wdata_512;
        <%if(_child[pidx].fnNativeInterface == 'AXI4' || _child[pidx].fnNativeInterface == 'AXI5') {%>
        if((ace_xxx_cmd_type == WRNOSNP) && (addr_trans_mgr_pkg::ncoreConfigInfo::get_addr_gprar_nc(m_pkt.awaddr)==1)) begin
            CONC_11133_Cov_axi_ace_wr_rd_opcodes = Ace_WrNoSnoop;
            owo_Axi_wr_rd_opcodes = Ace_WrNoSnoop;
        end else if((ace_xxx_cmd_type == WRNOSNP) && (addr_trans_mgr_pkg::ncoreConfigInfo::get_addr_gprar_nc(m_pkt.awaddr)==0)) begin
            CONC_11133_Cov_axi_ace_wr_rd_opcodes = Ace_WrUnique;
            owo_Axi_wr_rd_opcodes = Ace_WrUnique;
        end
        <% } else if(_child[pidx].fnNativeInterface == 'ACELITE-E') {%>
        if(ace_xxx_cmd_type == WRNOSNP) begin
            CONC_11133_Cov_axi_ace_wr_rd_opcodes = Ace_WrNoSnoop;
            owo_Ace5lite_wr_rd_opcodes = Ace_WrNoSnoop;
        end else if(ace_xxx_cmd_type == WRUNQ) begin
            CONC_11133_Cov_axi_ace_wr_rd_opcodes = Ace_WrUnique;
            owo_Ace5lite_wr_rd_opcodes = Ace_WrUnique;
        end
        <%} else {%>
        if(ace_xxx_cmd_type == WRNOSNP) begin
            CONC_11133_Cov_axi_ace_wr_rd_opcodes = Ace_WrNoSnoop;
            owo_Acelite_wr_rd_opcodes= Ace_WrNoSnoop;
        end else if(ace_xxx_cmd_type == WRUNQ) begin
            CONC_11133_Cov_axi_ace_wr_rd_opcodes = Ace_WrUnique;
            owo_Acelite_wr_rd_opcodes= Ace_WrUnique;
        end
        <%}%>
       <%} else {%>
        owo_en = 0;
       <%}%>
    <%}%>
    <%if(_child[pidx].fnNativeInterface.includes("ACE") || _child[pidx].fnNativeInterface == 'ACE5' || _child[pidx].fnNativeInterface == 'ACELITE-E' || _child[pidx].fnNativeInterface == 'ACE-LITE') {%>
        ace_xxx_cmd_type = ace_wr_cmd_type_<%=_child_blkid[pidx]%>(m_pkt);
        if(ace_xxx_cmd_type == WRNOSNP) begin
            CONC_11133_Cov_axi_ace_wr_rd_opcodes = Ace_WrNoSnoop;
        end else if(ace_xxx_cmd_type == WRUNQ) begin
            CONC_11133_Cov_axi_ace_wr_rd_opcodes = Ace_WrUnique;
        end
    <%}%>
<%}%>
     <%if(Array.isArray(_child[pidx].interfaces.axiInt)){
               computedAxiInt = _child[pidx].interfaces.axiInt[0];
       }else{
               computedAxiInt = _child[pidx].interfaces.axiInt;
     }%>       
    <%if(((_child[pidx].fnNativeInterface == 'AXI5') && (computedAxiInt.params.atomicTransactions==true)) || _child[pidx].fnNativeInterface == 'ACELITE-E') {%>
        ace_xxx_cmd_type = ace_wr_cmd_type_<%=_child_blkid[pidx]%>(m_pkt);
<% if (dmi_useAtomic) {%>     
        if (ace_xxx_cmd_type == ATMCOMPARE) begin
          aiu_data_width =  <%=_child[pidx].wData%>;
          aiu_awlen      = m_pkt.awlen;
          aiu_awsize     = m_pkt.awsize;
          aiu_awburst    = m_pkt.awburst;
          aiu_awaddr     = m_pkt.awaddr;
          //$display("CLUDEBUG: awlen=%0d,awsize=%0d,awburst=%0d,awaddr=%0h",aiu_awlen,aiu_awsize,aiu_awburst,aiu_awaddr[4:0]);
          cg_native_itf_atomic_compare.sample();
        end
          <% if ((_child[pidx].fnNativeInterface == 'AXI5') && (_child[pidx].orderedWriteObservation==false)) { %>
          atomic_fnNativeInterface = AXI5;
          <% } else if ((_child[pidx].fnNativeInterface == 'AXI5') && (_child[pidx].orderedWriteObservation==true) && (_child[pidx].wData==256)) { %>
          atomic_fnNativeInterface = AXI5_owo_256;
          <% } else if ((_child[pidx].fnNativeInterface == 'AXI5') && (_child[pidx].orderedWriteObservation==true) && (_child[pidx].wData==512)) { %>
          atomic_fnNativeInterface = AXI5_owo_512;
          <% } else if (_child[pidx].fnNativeInterface == 'ACELITE-E') { %>
          atomic_fnNativeInterface = ACE5LITE;
          <% } %>
          cg_native_itf_atomic_compare.sample();
<% } // only atomic%>
     <% } // only ACE%>
     <% if(_child_blk[pidx].match('ioaiu') ) { %>
        aiu_awlen      = m_pkt.awlen;
        cg_axlen.sample();
        awlock      = axi_axlock_enum_t'(m_pkt.awlock);
        wr_policies = axi_awcache_enum_t'(m_pkt.awcache);
        cg_native_itf_cmd.sample();
    <%}%>
    end
endfunction:collect_item_wr_<%=_child_blkid[pidx]%>

function void Fsys_native_itf_coverage::collect_item_bresp_<%=_child_blkid[pidx]%>(<%=_child_blkid[pidx]%>_env_pkg::axi4_write_resp_pkt_t m_pkt);
    if (m_pkt) begin
        <%  if(_child_blk[pidx].match('ioaiu')) { %> 
        bit owo_en;
          <%if(_child[pidx].orderedWriteObservation==true) {%>
          owo_en = 1;
          <%if(_child[pidx].fnNativeInterface == 'AXI4' || _child[pidx].fnNativeInterface == 'AXI5') {%>
          owo_axi_aiu_bresp= axi_bresp_enum_t'(m_pkt.bresp); 
          <% } else if(_child[pidx].fnNativeInterface == 'ACELITE-E') {%>
          owo_axi_Ace5Lite_bresp= axi_bresp_enum_t'(m_pkt.bresp); 
          <%} else {%>
          owo_axi_AceLite_bresp= axi_bresp_enum_t'(m_pkt.bresp); 
          <%}%>
          <%} else {%>
          owo_en = 0;
          <%}%>
          aiu_bresp = axi_bresp_enum_t'(m_pkt.bresp); 
        <%} // ioaiu%>
        <%  if(_child_blk[pidx].match('dmi')) { %> dmi_bresp = axi_bresp_enum_t'(m_pkt.bresp); <%}%>
        <%  if(_child_blk[pidx].match('dii')) { %> dii_bresp = axi_bresp_enum_t'(m_pkt.bresp); <%}%>
        cg_native_itf_resp.sample();
    end
endfunction:collect_item_bresp_<%=_child_blkid[pidx]%>

function void Fsys_native_itf_coverage::collect_item_rd_<%=_child_blkid[pidx]%>(<%=_child_blkid[pidx]%>_env_pkg::axi4_read_addr_pkt_t m_pkt);
<% if(_child_blk[pidx].match('ioaiu') ) { %>
<%=_child_blkid[pidx]%>_env_pkg::ace_read_addr_pkt_t m_packet;
<%=_child_blkid[pidx]%>_env_pkg::ace_read_addr_pkt_t m_packet_tmp;
bit owo_en;
    m_packet_tmp = new();
    m_packet = new();
    $cast(m_packet_tmp, m_pkt);
    m_packet.copy(m_packet_tmp);
<%}%>
<% if(_child_blk[pidx].match('ioaiu') ) { %>
    if(<%=_child[pidx].wData%>== 64)
        axi_ace_wdata = axi_ace_wdata_64;
    else if(<%=_child[pidx].wData%>==128)    
        axi_ace_wdata = axi_ace_wdata_128;
    else if(<%=_child[pidx].wData%>==256)    
        axi_ace_wdata = axi_ace_wdata_256;
<%}%>

    if (m_pkt) begin
<% if(_child_blk[pidx].match('ioaiu') ) { %>
    aiu_arlen      = m_pkt.arlen;
    axi_ace_araddr_critical_dword = m_pkt.araddr[5:3];
    <%if(_child[pidx].fnNativeInterface == 'AXI4' || _child[pidx].fnNativeInterface == 'AXI5' || (_child[pidx].fnNativeInterface == 'ACE-LITE') || (_child[pidx].fnNativeInterface == 'ACELITE-E')) {%>
        CONC_11133_Cov_axi_ace_wr_rd_opcodes = Axi5_Axi4_Read;
        ace_xxx_cmd_type = ace_rd_cmd_type_<%=_child_blkid[pidx]%>(m_pkt);
        <%if(_child[pidx].orderedWriteObservation==true) {%>
        owo_en = 1;
        if(<%=_child[pidx].wData%>==512)    
            axi_ace_wdata = axi_ace_wdata_512;
        <%if(_child[pidx].fnNativeInterface == 'AXI4' || _child[pidx].fnNativeInterface == 'AXI5') {%>
        if((ace_xxx_cmd_type == RDNOSNP) && (addr_trans_mgr_pkg::ncoreConfigInfo::get_addr_gprar_nc(m_pkt.araddr)==1)) begin
            CONC_11133_Cov_axi_ace_wr_rd_opcodes = Ace_RdNoSnoop;
            owo_Axi_wr_rd_opcodes = Ace_RdNoSnoop;
        end else if((ace_xxx_cmd_type == RDNOSNP) && (addr_trans_mgr_pkg::ncoreConfigInfo::get_addr_gprar_nc(m_pkt.araddr)==0)) begin
            CONC_11133_Cov_axi_ace_wr_rd_opcodes = Ace_RdOnce;
            owo_Axi_wr_rd_opcodes = Ace_RdOnce;
        end
        <% } else if(_child[pidx].fnNativeInterface == 'ACELITE-E') {%>
        if(ace_xxx_cmd_type == RDNOSNP) begin
            CONC_11133_Cov_axi_ace_wr_rd_opcodes = Ace_RdNoSnoop;
            owo_Ace5lite_wr_rd_opcodes = Ace_RdNoSnoop;
        end else if(ace_xxx_cmd_type == RDONCE) begin
            CONC_11133_Cov_axi_ace_wr_rd_opcodes = Ace_RdOnce;
            owo_Ace5lite_wr_rd_opcodes = Ace_RdOnce;
        end
        <%} else {%>
        if(ace_xxx_cmd_type == RDNOSNP) begin
            CONC_11133_Cov_axi_ace_wr_rd_opcodes = Ace_RdNoSnoop;
            owo_Acelite_wr_rd_opcodes = Ace_RdNoSnoop;
        end else if(ace_xxx_cmd_type == RDONCE) begin
            CONC_11133_Cov_axi_ace_wr_rd_opcodes = Ace_RdOnce;
            owo_Acelite_wr_rd_opcodes = Ace_RdOnce;
        end
        <%}%>
       <%} else {%>
        owo_en = 0;
       <%}%>
    <%}%>
    <%if(_child[pidx].fnNativeInterface.includes("ACE") ||  _child[pidx].fnNativeInterface == 'ACE5' || (_child[pidx].fnNativeInterface == 'ACE-LITE')) {%>
        ace_xxx_cmd_type = ace_rd_cmd_type_<%=_child_blkid[pidx]%>(m_pkt);
        if(ace_xxx_cmd_type == RDNOSNP) begin
            CONC_11133_Cov_axi_ace_wr_rd_opcodes = Ace_RdNoSnoop;
        end else if(ace_xxx_cmd_type == RDONCE) begin
            CONC_11133_Cov_axi_ace_wr_rd_opcodes = Ace_RdOnce;
        end
    <%}%>
<%}%>
    <%if(_child[pidx].fnNativeInterface.includes("ACE") ||  _child[pidx].fnNativeInterface == 'ACE5' || _child[pidx].fnNativeInterface == 'ACELITE-E' || _child[pidx].fnNativeInterface == 'ACE-LITE') {%>
        ace_xxx_cmd_type = ace_rd_cmd_type_<%=_child_blkid[pidx]%>(m_pkt);
     <% } // only ACE%>
     <% if(_child_blk[pidx].match('ioaiu') ) { %>
        aiu_arlen      = m_pkt.arlen;
        cg_axlen.sample();
        rd_policies = axi_arcache_enum_t'(m_pkt.arcache);
        arlock      = axi_axlock_enum_t'(m_pkt.arlock);
        cg_native_itf_cmd.sample();
    <%if(_child[pidx].fnNativeInterface.includes("ACE") ||  _child[pidx].fnNativeInterface == 'ACE5') {%>
        if(ace_xxx_cmd_type inside{DVMMSG}  && sample_dvm_func_cov) begin
            sample_ioaiu_cmd_dvm_fcov(
            <%=ioaiu_idx%>,
            m_packet.araddr,
            m_packet.arvmid
            );
        end
     <% } // only ACE%>
    <%}%>
    end
endfunction:collect_item_rd_<%=_child_blkid[pidx]%>

function void Fsys_native_itf_coverage::collect_item_rd_data_<%=_child_blkid[pidx]%>(<%=_child_blkid[pidx]%>_env_pkg::axi4_read_data_pkt_t m_pkt);
    if (m_pkt) begin
        <%  if(_child_blk[pidx].match('ioaiu')) { %> 
        bit owo_en;
          <%if(_child[pidx].orderedWriteObservation==true) {%>
          owo_en = 1;
          <%if(_child[pidx].fnNativeInterface == 'AXI4' || _child[pidx].fnNativeInterface == 'AXI5') {%>
          owo_axi_aiu_rresp = axi_bresp_enum_t'(m_pkt.rresp); 
          <% } else if(_child[pidx].fnNativeInterface == 'ACELITE-E') {%>
          owo_axi_Ace5Lite_rresp= axi_bresp_enum_t'(m_pkt.rresp); 
          <%} else {%>
          owo_axi_AceLite_rresp= axi_bresp_enum_t'(m_pkt.rresp); 
          <%}%>
          <%} else {%>
          owo_en = 0;
          <%}%>
        aiu_rresp = axi_bresp_enum_t'(m_pkt.rresp); 
        <%} // ioaiu%>
        <%  if(_child_blk[pidx].match('dmi')) { %> dmi_rresp = axi_bresp_enum_t'(m_pkt.rresp); <%}%>
        <%  if(_child_blk[pidx].match('dii')) { %> dii_rresp = axi_bresp_enum_t'(m_pkt.rresp); <%}%>
        cg_native_itf_resp.sample();
    end
endfunction:collect_item_rd_data_<%=_child_blkid[pidx]%>   

<%if(_child[pidx].fnNativeInterface == 'ACE' || _child[pidx].fnNativeInterface == 'ACE5' ||_child[pidx].fnNativeInterface == "ACELITE-E") {%>
  <% if(_child[pidx].interfaces.axiInt.params.eAc==1 && (_child[pidx].fnNativeInterface == "ACE" || _child[pidx].fnNativeInterface == "ACE5" ||_child[pidx].fnNativeInterface == "ACELITE-E")){ %>
    function void Fsys_native_itf_coverage::collect_item_snp_<%=_child_blkid[pidx]%>(<%=_child_blkid[pidx]%>_env_pkg::ace_snoop_addr_pkt_t m_pkt);
        if (m_pkt) begin
            ace_snp_type = axi_acsnoop_enum_t'(m_pkt.acsnoop);
            cg_native_itf_cmd.sample();
            if(m_pkt.print_snoop_type() inside {"DVMMSG"} && sample_dvm_func_cov) begin
                sample_ioaiu_snp_dvm_fcov(
                <%=ioaiu_idx%>,
                m_pkt.acaddr,
                m_pkt.acvmid
                );
            end
        end
    endfunction:collect_item_snp_<%=_child_blkid[pidx]%>
   <%}%>

    function void Fsys_native_itf_coverage::collect_item_sresp_<%=_child_blkid[pidx]%>(<%=_child_blkid[pidx]%>_env_pkg::ace_snoop_resp_pkt_t m_pkt);
        if (m_pkt) begin
            ace_sresp = axi_crresp_t'(m_pkt.crresp);
            cg_native_itf_resp.sample();
        end
    endfunction:collect_item_sresp_<%=_child_blkid[pidx]%>
    <% } // includes ACE %>
  <% } // includes AXI || ACE %>
  <% if(_child_blk[pidx].match('ioaiu') )  {
      ioaiu_idx = ioaiu_idx + 1;
  } %>
  <% } // if NATIVE%>
<% } // for nALLS%>

