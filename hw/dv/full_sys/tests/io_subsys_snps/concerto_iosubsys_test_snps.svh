<%
let pma_en_dmi_blk = 1;
let pma_en_dii_blk = 1;
let pma_en_aiu_blk = 1;
let pma_en_dce_blk = 1;
let pma_en_dve_blk = 1;
let pma_en_at_least_1_blk = 0;
let pma_en_all_blk = 1;
let numChiAiu = 0; // Number of CHI AIUs
let numACEAiu = 0; // Number of ACE AIUs
let numIoAiu = 0; // Number of IO AIUs
let numCAiu = 0; // Number of Coherent AIUs
let numNCAiu = 0; // Number of Non-Coherent AIUs
let numBootIoAiu = 0; // Number of NCAIUs can participate in Boot
let chiaiu0;  // strRtlNamePrefix of chiaiu0
let aceaiu0;  // strRtlNamePrefix of aceaiu0
let ncaiu0;   // strRtlNamePrefix of aceaiu0
let idxIoAiuWithPC = obj.nAIUs; // To get valid index of NCAIU with ProxyCache. Initialize to nAIUs
let numDmiWithSMC = 0; // Number of DMIs with SystemMemoryCache
let idxDmiWithSMC = 0; // To get valid index of DMI with SystemMemoryCache
let numDmiWithSP = 0; // Number of DMIs with ScratchPad memory
let idxDmiWithSP = 0; // To get valid index of DMIs with ScratchPad memory
let numDmiWithWP = 0; // Number of DMIs with WayPartitioning
let idxDmiWithWP = 0; // To get valid index of DMIs with WayPartitioning
let noBootIoAiu = 1;
const BootIoAiu = [];
let found_csr_access_chiaiu=0;
let found_csr_access_ioaiu=0;
let csrAccess_ioaiu;
let csrAccess_chiaiu;
const aiu_axiInt = [];
const dmi_width= [];
let AiuCore;
let initiatorAgents   = obj.AiuInfo.length ;
const aiu_NumCores = [];
const aiu_rpn = [];
const aiuName = [];

   const _blkid = [];
   const _blkportsid =[];
   const _blk   = [{}];
   let _idx = 0;
   let pidx = 0;
   let qidx = 0;
   let idx = 0;
   let aiu_idx = 0;
   let chiaiu_idx = 0;
   let nAIUs_mpu =0; 
   
   for(pidx = 0; pidx < obj.nAIUs; pidx++) {
      if(!Array.isArray(obj.AiuInfo[pidx].interfaces.axiInt)) {
       _blk[_idx]   = obj.AiuInfo[pidx];
       _blkid[_idx] = 'aiu' + aiu_idx;
       _blkportsid[_idx] = 0;
       nAIUs_mpu++;
       aiu_idx++;
       _idx++;
       } else {
       for (let port_idx = 0; port_idx < obj.AiuInfo[pidx].nNativeInterfacePorts; port_idx++) {
        _blk[_idx]   = obj.AiuInfo[pidx];
        _blkid[_idx] = 'aiu' + aiu_idx ;
        _blkportsid[_idx] = port_idx;
        _idx++;
        nAIUs_mpu++;
        }
        aiu_idx++;
       }
   }

 for(pidx = 0; pidx < initiatorAgents; pidx++) { 
   if(Array.isArray(obj.AiuInfo[pidx].interfaces.axiInt)) {
       aiu_NumCores[pidx]    = obj.AiuInfo[pidx].interfaces.axiInt.length;
       aiu_rpn[pidx]= obj.AiuInfo[pidx].rpn[0];
   } else {
       aiu_NumCores[pidx]    = 1;
       aiu_rpn[pidx]= obj.AiuInfo[pidx].rpn;
   }
 }

for(pidx = 0; pidx < obj.nAIUs; pidx++) {
    if(Array.isArray(obj.AiuInfo[pidx].interfaces.axiInt)) {
        aiu_axiInt[pidx] = obj.AiuInfo[pidx].interfaces.axiInt[0];
        AiuCore = 'ioaiu_core0';
    } else {
        aiu_axiInt[pidx] = obj.AiuInfo[pidx].interfaces.axiInt;
        AiuCore = 'ioaiu_core0';
    }
}

for(pidx = 0; pidx < obj.nDMIs; pidx++) {
    pma_en_dmi_blk &= obj.DmiInfo[pidx].usePma;
    pma_en_at_least_1_blk |= obj.DmiInfo[pidx].usePma;
    if(obj.DmiInfo[pidx].useCmc)
       {
         numDmiWithSMC++;
         idxDmiWithSMC = pidx;
         if(obj.DmiInfo[pidx].ccpParams.useScratchpad)
            {
              numDmiWithSP++;
              idxDmiWithSP = pidx;
            }
         if(obj.DmiInfo[pidx].useWayPartitioning)
            {
              numDmiWithWP++;
              idxDmiWithWP = pidx;
            }
       }
}
for(pidx = 0; pidx < obj.nDIIs; pidx++) {
    pma_en_dii_blk &= obj.DiiInfo[pidx].usePma;
    pma_en_at_least_1_blk |= obj.DiiInfo[pidx].usePma;
}
// Assuming CHI AIU will appear first in AiuInfo in top.level.dv.json before IO-AIUs
let chi_idx=0;
let io_idx=0;
for(pidx = 0; pidx < obj.nAIUs; pidx++) {
    pma_en_aiu_blk &= obj.AiuInfo[pidx].usePma;
    pma_en_at_least_1_blk |= obj.AiuInfo[pidx].usePma;
    if((obj.AiuInfo[pidx].fnNativeInterface == "CHI-A")||(obj.AiuInfo[pidx].fnNativeInterface == "CHI-B")||(obj.AiuInfo[pidx].fnNativeInterface == "CHI-E")) 
       { 
       if(numChiAiu == 0) { chiaiu0 = obj.AiuInfo[pidx].strRtlNamePrefix; }
       if(obj.AiuInfo[pidx].fnCsrAccess == 1) {
         if (found_csr_access_chiaiu == 0) {
          csrAccess_chiaiu = chi_idx;
          found_csr_access_chiaiu = 1;
         }
       }
       numChiAiu++ ; numCAiu++ ; 
       chi_idx++;
       }
    else
       { 
         for(let i=0; i<aiu_NumCores[pidx]; i++) {
           numIoAiu++ ; 
         }
         if(obj.AiuInfo[pidx].fnNativeInterface == "ACE") { 
             if(numACEAiu == 0) { aceaiu0 = obj.AiuInfo[pidx].strRtlNamePrefix; }
	     numCAiu++; numACEAiu++; 
         } else {
             if(Array.isArray(obj.AiuInfo[pidx].interfaces.axiInt)) {
                 if (numNCAiu == 0) { ncaiu0 = obj.AiuInfo[pidx].strRtlNamePrefix + "_0"; }
             } else {
                 if (numNCAiu == 0) { ncaiu0 = obj.AiuInfo[pidx].strRtlNamePrefix; }
             }
             numNCAiu++ ;
         }
//         if(obj.AiuInfo[pidx].useCache) idxIoAiuWithPC = numNCAiu;
         if(obj.AiuInfo[pidx].useCache) {
             idxIoAiuWithPC = pidx;
             if(Array.isArray(obj.AiuInfo[pidx].interfaces.axiInt)) {
                 aiuName[pidx]  = obj.AiuInfo[pidx].strRtlNamePrefix + "_0";
             } else {
                 aiuName[pidx]  = obj.AiuInfo[pidx].strRtlNamePrefix;
            }
         }
         if(obj.AiuInfo[pidx].fnCsrAccess == 1) {
            if (found_csr_access_ioaiu == 0) {
	       csrAccess_ioaiu = io_idx;
	       found_csr_access_ioaiu = 1;
            }
	    BootIoAiu[numBootIoAiu] = io_idx;
            numBootIoAiu++;
	    noBootIoAiu = 0;
         }
         io_idx++;
       }
}
for(pidx = 0; pidx < obj.nDCEs; pidx++) {
    pma_en_dce_blk &= obj.DceInfo[pidx].usePma;
    pma_en_at_least_1_blk |= obj.DceInfo[pidx].usePma;
}
for(pidx = 0; pidx < obj.nDVEs; pidx++) {
    pma_en_dve_blk &= obj.DveInfo[pidx].usePma;
    pma_en_at_least_1_blk |= obj.DveInfo[pidx].usePma;
}
pma_en_all_blk = pma_en_dmi_blk & pma_en_dii_blk & pma_en_aiu_blk & pma_en_dce_blk & pma_en_dve_blk;

console.log("pma_en_at_least_1_blk = "+pma_en_at_least_1_blk);
console.log("pma_en_all_blk = "+pma_en_all_blk);

// For DMI registers's offset value
function getDmiOffset(register) {
    var found=0;
    var offset=0; 
    obj.DmiInfo.forEach(function regOffsetFindSB(item,i){
                            if(!found){
                               const reg = item.csr.spaceBlock[0].registers.find(reg => reg.name == register);
                               if(reg != undefined) {
                                  found = 1;
                                  offset = reg.addressOffset;
                               }
                            }
                         }
                        );
    return (offset.toString(16));
}

// For CHI registers's offset value
function getChiOffset(register) {
    var found=0;
    var offset=0; 
    obj.AiuInfo.forEach(function regOffsetFindSB(item,i){
                            if(item.fnNativeInterface === "CHI-A" || item.fnNativeInterface === "CHI-B" || item.fnNativeInterface === "CHI-E") {
                               if(!found){
                                  const reg = item.csr.spaceBlock[0].registers.find(reg => reg.name == register);
                                  if(reg != undefined) {
                                     found = 1;
                                     offset = reg.addressOffset;
                                  }
                               }
                            }
                         }
                        );
    return (offset.toString(16));
}

// For IOAIU registers's offset value
function getIoOffset(register) {
    var found=0;
    var offset=0; 
    obj.AiuInfo.forEach(function regOffsetFindSB(item,i){
                            if(!(item.fnNativeInterface === "CHI-A" || item.fnNativeInterface === "CHI-B" || item.fnNativeInterface === "CHI-E")) {
                               if(!found){
                                  const reg = item.csr.spaceBlock[0].registers.find(reg => reg.name == register);
                                  if(reg != undefined) {
                                     found = 1;
                                     offset = reg.addressOffset;
                                  }
                               }
                            }
                         }
                        );
    return (offset.toString(16));
}

// For DCE registers's offset value
function getDceOffset(register) {
    var found=0;
    var offset=0; 
    obj.DceInfo.forEach(function regOffsetFindSB(item,i){
                            if(!found){
                               const reg = item.csr.spaceBlock[0].registers.find(reg => reg.name == register);
                               if(reg != undefined) {
                                  found = 1;
                                  offset = reg.addressOffset;
                               }
                            }
                         }
                        );
    return (offset.toString(16));
}

// For DVE registers's offset value
function getDveOffset(register) {
    var found=0;
    var offset=0; 
    obj.DveInfo.forEach(function regOffsetFindSB(item,i){
                            if(!found){
                               const reg = item.csr.spaceBlock[0].registers.find(reg => reg.name == register);
                               if(reg != undefined) {
                                  found = 1;
                                  offset = reg.addressOffset;
                               }
                            }
                         }
                        );
    return (offset.toString(16));
}
%>
// agent DEBUG
<%for(pidx = 0; pidx < nAIUs_mpu; pidx++) {   %>
//  idx=<%=pidx%> : <%=_blkid[pidx]%>  port:<%=_blkportsid[pidx]%> 
<% } %>

//File: concerto_iosubsys_test_snps.svh

<%  if((obj.INHOUSE_OCP_VIP)) { %>
import ocp_agent_pkg::*;
<%  } %>

<%
const ioCacheEn = [];
const aiuNativeInf = [];
const dvmEn = [];
const dvmCmpEn = [];
const interlvAiu = [];
let cacheId;
const idSnoopFilterSlice = [];
const hntEn = [];
let hntEnVal;

//const agent_num = [];
//let current_agt_num = 0;
let count = -1 ;
let logical_id = -1;
const AgtIdToCacheId = [];
const aiuBundleIndex = [];
let nChiAgents = 0;
let nACEAgents = 0;


if (obj.nAIUs > 0) {
obj.AiuInfo.forEach(function(bundle, indx, array) {
    if(bundle.useCache) {
        ioCacheEn.push(1);
    } else {
        ioCacheEn.push(0);
    }
     aiuNativeInf.push(bundle.fnNativeInterface);

     if(bundle.nAius > 1) { // interleaved Aius?
       interlvAiu.push(1);
       //current_agt_num += 2;
     } else {
       interlvAiu.push(0);
       //current_agt_num += 1;
     }

     if((bundle.cmpInfo.nDvmSnpInFlight > 0)|(bundle.cmpInfo.nDvmMsgInFlight > 0)) {
       dvmEn.push(1);
     } else {
       dvmEn.push(0);
     }

     if((bundle.cmpInfo.nDvmCmpInFlight > 0)) {
       dvmCmpEn.push(1);
     } else {
       dvmCmpEn.push(0);
     }

     if(bundle.fnNativeInterface === "ACE" || bundle.fnNativeInterface === "CHI-A" || bundle.fnNativeInterface === "CHI-B" || bundle.fnNativeInterface === "CHI-E") { // interleaved Aius?
       obj.SnoopFilterInfo.forEach(function(snpinfo, snp_indx, array) {
          if (snpinfo.SnoopFilterAssignment.includes(bundle.FUnitId))
            idSnoopFilterSlice.push(snp_indx);
       });
     }

     if(bundle.fnNativeInterface === "ACE" || bundle.fnNativeInterface === "ACE-LITE" || bundle.fnNativeInterface === "ACELITE-E") {
       nACEAgents = nACEAgents + 1;
     }

     if(bundle.fnNativeInterface === "CHI-A" || bundle.fnNativeInterface === "CHI-B" || bundle.fnNativeInterface === "CHI-E") {
        nChiAgents = nChiAgents + 1;
     }
});
}
   let bundle_index = -1;
   
obj.AiuInfo.forEach(function(bundle, indx, array) {
  if (bundle.interleavedAgent == 0) {
    bundle_index += 1;
  }
  aiuBundleIndex.push(bundle_index);
});

%>
`ifdef USE_VIP_SNPS // Now using this test for synopsys vip sim 
class concerto_iosubsys_test_snps extends concerto_base_trace_test;

    //////////////////
    //Properties
    //////////////////

    static string inst_name="";
    int iter;

    static uvm_event ev_bist_reset_done = ev_pool.get("bist_reset_done");
    uvm_event kill_uncorr_test   = ev_pool.get("kill_uncorr_test");
    uvm_event kill_chiaiu_uncorr_test   = ev_pool.get("kill_chiaiu_uncorr_test");
    //event to sync with concerto_iosubsys_test_snps and end simulation when DECERR is received
    uvm_event kill_uncorr_grar_nsx_test = ev_pool.get("kill_uncorr_grar_nsx_test");


    <% for(pidx = 0; pidx < obj.nDMIs; pidx++) {if(obj.DmiInfo[pidx].useCmc) { %>
    static uvm_event ev_inject_error_dmi<%=pidx%>_smc = ev_pool.get("inject_error_dmi<%=pidx%>_smc"); <%}}%>


    //INHOUSE CHI SEQ
    <% qidx=0; idx=0; for(pidx = 0 ; pidx < obj.nAIUs; pidx++) { %>
      <% if((obj.AiuInfo[pidx].fnNativeInterface == 'CHI-A') || (obj.AiuInfo[pidx].fnNativeInterface == 'CHI-B')|| (obj.AiuInfo[pidx].fnNativeInterface == 'CHI-E')) { %>
           chiaiu<%=idx%>_chi_aiu_vseq_pkg::chi_aiu_vseq#(<%=obj.AiuInfo[pidx].FUnitId%>)       m_chi<%=idx%>_vseq;
           chiaiu<%=idx%>_chi_aiu_vseq_pkg::chi_aiu_vseq#(<%=obj.AiuInfo[pidx].FUnitId%>)       m_chi<%=idx%>_read_vseq; // read
           chi_aiu_unit_args_pkg::chi_aiu_unit_args                       m_chi<%=idx%>_args;
           chi_aiu_unit_args_pkg::chi_aiu_unit_args                       m_chi<%=idx%>_read_args;  // read
	   static uvm_event ev_chi<%=idx%>_seq_done = ev_pool.get("m_chi<%=idx%>_seq");
	   static uvm_event ev_chi<%=idx%>_read_seq_done = ev_pool.get("m_chi<%=idx%>_read_seq");
	   <%  idx++;   %>
       <% } else { %>
           ioaiu<%=qidx%>_inhouse_axi_bfm_pkg::axi_master_pipelined_seq          m_iocache_seq<%=qidx%>[<%=aiu_NumCores[pidx]%>];
           ioaiu<%=qidx%>_inhouse_axi_bfm_pkg::axi_master_pipelined_seq          m_iocache_read_seq<%=qidx%>[<%=aiu_NumCores[pidx]%>];  // read
      <% if((obj.AiuInfo[pidx].fnNativeInterface == 'ACE') || (aiu_axiInt[pidx].params.eAc==1) ){ %>
           ioaiu<%=qidx%>_inhouse_axi_bfm_pkg::axi_master_snoop_seq              m_iosnoop_seq<%=qidx%>[<%=aiu_NumCores[pidx]%>];
      <% } %>
      static uvm_event ev_ioaiu<%=qidx%>_seq_done[<%=aiu_NumCores[pidx]%>];
      static uvm_event ev_ioaiu<%=qidx%>_read_seq_done[<%=aiu_NumCores[pidx]%>];
<%  qidx++; } %>
    <% } %>
    // END INHOUSE CHI SEQ 
    
    // SNPS CHI SEQ
    bit vip_snps_non_coherent_txn = 0;
    bit vip_snps_coherent_txn = 0;
    int vip_snps_seq_length = 4;
    bit                          SYNPS_AXI_SLV_BACKPRESSURE_EN = 0;


  <% qidx=0;idx=0; for(pidx = 0; pidx < obj.nAIUs; pidx++) { %>
    <% if((obj.AiuInfo[pidx].fnNativeInterface == 'CHI-A')||(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-B' || obj.AiuInfo[pidx].fnNativeInterface == 'CHI-E')) { %>
    svt_chi_rn_transaction_random_sequence svt_chi_rn_seq_h<%=idx%>;
    svt_chi_link_service_activate_sequence svt_chi_link_up_seq_h<%=idx%>;
    svt_chi_link_service_deactivate_sequence svt_chi_link_dn_seq_h<%=idx%>;
    static uvm_event done_svt_chi_link_dn_seq_h<%=idx%> = ev_pool.get("done_svt_chi_link_dn_seq_h<%=idx%>");
    static uvm_event done_svt_chi_rn_seq_h<%=idx%> = ev_pool.get("done_svt_chi_rn_seq_h<%=idx%>");
    <% if(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-B' || obj.AiuInfo[pidx].fnNativeInterface == 'CHI-E') { %>
    chiaiu0_chi_aiu_vseq_pkg::cust_svt_chi_protocol_service_coherency_entry_sequence coherency_entry_seq<%=idx%>;
    <% } %>
   <% idx++; } else {%>
   <% qidx++; } } %>
<% if(numChiAiu > 0) { %>
     svt_chi_item m_svt_chi_item;
<% } %>
   // END SNPS CHI SEQ

  //TMP REMOVED// LEGACY SNPS CHI SEQ ???
     <% qidx=0; idx=0; for(pidx = 0 ; pidx < obj.nAIUs; pidx++) { %>
      <% if((obj.AiuInfo[pidx].fnNativeInterface == 'CHI-A') || (obj.AiuInfo[pidx].fnNativeInterface == 'CHI-B' || obj.AiuInfo[pidx].fnNativeInterface == 'CHI-E')) { %>
             //chiaiu<%=idx%>_chi_aiu_vseq_pkg::snps_chi_aiu_vseq#(<%=obj.AiuInfo[pidx].FUnitId%>)   m_snps_chi<%=idx%>_vseq;
             //chi_aiu_unit_args_pkg::chi_aiu_unit_args                       m_chi<%=idx%>_args;
             <% idx++; %>
       <%  } else {%>
           ioaiu<%=qidx%>_env_pkg::snps_axi_master_pipelined_seq cust_seq_h<%=qidx%>[<%=aiu_NumCores[pidx]%>];
           static uvm_event done_snp_cust_seq_h<%=qidx%> = ev_pool.get("done_snp_cust_seq_h<%=qidx%>");
           // CONC-11906 : Running snoop seq - cust_svt_axi_snoop_transaction or snps_axi_master_snoop_seq from vseq - snps_axi_master_pipelined_seq
	<%  qidx++; } %>
       <% } %>
  // END LEGACY SNPS CHI SEQ ???


    semaphore key=new(1);
    semaphore coh_key=new(1);

  bit timeout;
  bit enable_ace_dvmsync;
  int 	      chiaiu_en[int];
  int 	      ioaiu_en[int];
  int chi_num_trans;
  int ioaiu_num_trans;
  int boot_from_ioaiu;
  bit k_csr_access_only;
  bit k_nrsar_test;
  bit k_directed_test;
  bit k_directed_data_integrity;
  bit k_directed_wrunq_wrevict;
  bit k_directed_test_same_aiu;
  bit k_directed_test_wr_rd;   
  integer    k_directed_test_noncoh_addr_pct;
  integer    k_directed_test_coh_addr_pct;
  bit k_directed_64B_aligned;
  int use_user_addrq;
  int min_use_user_addrq=5;
  bit func_unit_uncorr_err_inj;
  bit dup_unit_uncorr_err_inj;
  bit both_units_uncorr_err_inj;
  int plusarg_int;

   int 	      chiaiu_qos[int];
   int 	      ioaiu_qos[int];
   string     chiaiu_qos_str[];
   string     ioaiu_qos_str[];
   string     chiaiu_qos_arg;
   string     ioaiu_qos_arg;
   bit 	      chiaiu_user_qos;
   bit 	      ioaiu_user_qos;
   
    bit 	hard_reset_issued;

    
    <% 
      let ioaiu_idx = 0;
   %>
`ifdef USE_STL_TRACE
  <% for(pidx = 0 ; pidx < obj.nAIUs; pidx++) { %>
      <% if(!((obj.AiuInfo[pidx].fnNativeInterface == 'CHI-A') || (obj.AiuInfo[pidx].fnNativeInterface == 'CHI-B') || (obj.AiuInfo[pidx].fnNativeInterface == 'CHI-E'))) { %>
       <% for(let i=0; i<aiu_NumCores[pidx]; i++) { %> 
    uvm_event ioaiu_clk_posedge_e_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_<%=i%>;
     <% } %>
    <% ioaiu_idx++;
    } %>
   <% } %>
`endif//USE_STL_TRACE

   //CONC-11906 To-Do: Move all below macros in concerto_common_macros_snps.svh
   `define CONC_COMMON_MERGE(val1,val2) \
   val1``val2

   `define CONC_COMMON_STRINGIFY(x) `"x`"
   
   `define CONC_SVT_AXI_SYSENV_0_PATH m_concerto_env.snps.svt.amba_system_env.axi_system[0]
   
   `define CONC_SVT_AXI_SYSSEQR_PATH                `CONC_COMMON_MERGE(`CONC_SVT_AXI_SYSENV_0_PATH,.sequencer)

   <% ioaiu_idx=0; let ioaiu_idx_with_multi_core=0;%> 
   <% for(pidx=0; pidx<obj.nAIUs; pidx++) { %> 
   <%if(obj.AiuInfo[pidx].fnNativeInterface == 'ACE-LITE' || obj.AiuInfo[pidx].fnNativeInterface == 'ACELITE-E' || obj.AiuInfo[pidx].fnNativeInterface == 'ACE' || obj.AiuInfo[pidx].fnNativeInterface == 'AXI4' || obj.AiuInfo[pidx].fnNativeInterface == 'AXI5') { 
      for(let i=0; i<aiu_NumCores[pidx]; i++) { %>
   `define CONC_SVT_IOAIU<%=ioaiu_idx%>_<%=i%>_MASTER_SEQR_PATH                `CONC_COMMON_MERGE(`CONC_SVT_AXI_SYSENV_0_PATH,.master[<%=ioaiu_idx_with_multi_core%>].sequencer)
   <% ioaiu_idx_with_multi_core = ioaiu_idx_with_multi_core + 1; } ioaiu_idx = ioaiu_idx+1;} } %>
   `define CONC_NUM_IOAIU_SVT_MASTERS <%=ioaiu_idx_with_multi_core%>
   
`ifdef USE_VIP_SNPS_AXI_SLAVES
   <% let axi_slv_idx=0; %>
   <% for(pidx=0; pidx<obj.nDMIs; pidx++) { %> 
   `define CONC_SVT_AXI_SLAVE<%=axi_slv_idx%>_SEQR_PATH                `CONC_COMMON_MERGE(`CONC_SVT_AXI_SYSENV_0_PATH,.slave[<%=axi_slv_idx%>].sequencer)
   `define CONC_SVT_DMI<%=pidx%>_SLAVE_SEQR_PATH                   `CONC_SVT_AXI_SLAVE<%=axi_slv_idx%>_SEQR_PATH                
   <% axi_slv_idx  = axi_slv_idx + 1; %>
   <% } %>
   `define CONC_NUM_DMI_SVT_SLAVES <%=axi_slv_idx%>
   <% let axi_dii_slv_idx=0; %>
   <% for(pidx=0; pidx<obj.nDIIs; pidx++) { %> 
   <% if(obj.DiiInfo[pidx].configuration == 0) { %>
   `define CONC_SVT_AXI_SLAVE<%=axi_slv_idx%>_SEQR_PATH                `CONC_COMMON_MERGE(`CONC_SVT_AXI_SYSENV_0_PATH,.slave[<%=axi_slv_idx%>].sequencer)
   `define CONC_SVT_DII<%=pidx%>_SLAVE_SEQR_PATH                   `CONC_SVT_AXI_SLAVE<%=axi_slv_idx%>_SEQR_PATH
   <% axi_slv_idx  = axi_slv_idx + 1; axi_dii_slv_idx=axi_dii_slv_idx+1;} } %>
   `define CONC_NUM_DII_SVT_SLAVES <%=axi_dii_slv_idx%>
   `define CONC_NUM_SVT_AXI_SLAVES <%=axi_slv_idx%>
`endif //`ifdef USE_VIP_SNPS_AXI_SLAVES
   
   `define CONC_COMMON_SVT_ACE_CONSTRAINTS(lhs_prefix,rhs_prefix)

    //CONC-11906 To-Do: Move all below in concerto_helper_pkg_snps.svh
    string conc_ioaiu_fnnativeif_array[`CONC_NUM_IOAIU_SVT_MASTERS] ;
    string conc_ioaiu_name_array[`CONC_NUM_IOAIU_SVT_MASTERS] ;
    string conc_svt_axi_sysseqr_path_str="";
    svt_axi_master_sequencer conc_svt_axi_master_agnt_seqr[`CONC_NUM_IOAIU_SVT_MASTERS] ;
    svt_axi_slave_sequencer conc_svt_axi_slave_agnt_seqr[`CONC_NUM_DMI_SVT_SLAVES + `CONC_NUM_DII_SVT_SLAVES]; 
    svt_axi_slave_sequencer conc_svt_dmi_slave_agnt_seqr[`CONC_NUM_DMI_SVT_SLAVES]; 
    svt_axi_slave_sequencer conc_svt_dii_slave_agnt_seqr[`CONC_NUM_DII_SVT_SLAVES]; 
    string conc_svt_axi_master_agnt_seqr_path_string_array[`CONC_NUM_IOAIU_SVT_MASTERS] ;
    string conc_svt_axi_slave_agnt_seqr_path_string_array[`CONC_NUM_DMI_SVT_SLAVES + `CONC_NUM_DII_SVT_SLAVES]; 

    bit [31:0] agent_ids_assigned_q[ncore_config_pkg::ncoreConfigInfo::NUM_DMIS][$];
    bit [31:0] wayvec_assigned_q[ncore_config_pkg::ncoreConfigInfo::NUM_DMIS][$];
    int sp_ways[] = new[ncore_config_pkg::ncoreConfigInfo::NUM_DMIS];
    int sp_size[] = new[ncore_config_pkg::ncoreConfigInfo::NUM_DMIS];
    bit [<%=obj.wSysAddr-1%>:0] k_sp_base_addr[] = new[ncore_config_pkg::ncoreConfigInfo::NUM_DMIS];

    //////////////////
    //UVM Registery
    //////////////////    
    `uvm_component_utils(concerto_iosubsys_test_snps)

    //////////////////
    //Methods
    //////////////////
    // UVM PHASE
    extern function new(string name = "concerto_iosubsys_test_snps", uvm_component parent = null);
    extern virtual function void build_phase(uvm_phase  phase);
    extern static function concerto_iosubsys_test_snps get_instance();
    extern virtual function void end_of_elaboration_phase(uvm_phase phase);
    extern virtual function void phase_ready_to_end(uvm_phase phase);
    extern virtual task run_ioaiu_test_seq(input string initiator_port_name="", int ioaiu_port_id=0);
    extern virtual task run_ioaiu_ace_test_seq(input string initiator_port_name="", int ioaiu_port_id=0);
    extern virtual task run_ioaiu_axi4_test_seq(input string initiator_port_name="", int ioaiu_port_id=0);
    extern virtual task initialize_conc_helper_var_snps();
    extern virtual function void start_of_simulation_phase(uvm_phase phase);
    extern virtual task reset_phase(uvm_phase phase);
    extern virtual task pre_configure_phase(uvm_phase phase);
    extern virtual task  configure_phase(uvm_phase phase);
    extern virtual task run_phase(uvm_phase phase);
    extern virtual task main_phase(uvm_phase phase);
    
    // TASK
    extern virtual task gen_addr_use_user_addrq();
    extern virtual task exec_inhouse_seq(uvm_phase phase);
    extern virtual task wait_seq_totaly_done(uvm_phase phase);
 
    extern virtual task check_corr_errint_through_alias_reg();
   
    
    `ifdef USE_STL_TRACE 
    extern virtual task stl_csr_write();
    `endif //USE_STL_TRACE

    
    extern virtual task inject_error_all_dmi_smc();
    <% for(pidx = 0; pidx < obj.nDMIs; pidx++) { if(obj.DmiInfo[pidx].useCmc) {%>
    extern virtual task inject_error_dmi<%=pidx%>_smc();
    <%}}%>

    // Generic task used by Child class
    int max_iteration=1;
    virtual task main_seq_pre_hook(uvm_phase phase); endtask// before the iteration (outside the iteration loop)
    virtual task main_seq_post_hook(uvm_phase phase); endtask// after the iteration (outside the iteration loop)
    virtual task main_seq_iter_pre_hook(uvm_phase phase, int iter=0); endtask// at the beginning of the iteration(inside the iteration loop)
    extern virtual task main_seq_iter_post_hook(uvm_phase phase, int iter=0);// at the end of the iteration (inside the iteration)
    virtual task main_seq_hook_end_run_phase(uvm_phase phase); endtask
endclass: concerto_iosubsys_test_snps


////////////////////////////////
// VCS fix in case of iteration
/////////////////////////////////
 task concerto_iosubsys_test_snps::main_seq_iter_post_hook(uvm_phase phase, int iter=0); 
  `ifdef VCS
           if (max_iteration > 1) begin 
            #10us;  // in case of VCS always do  super.main_se_qiter_post_hook(phase)
               <%chi_idx=0;%>
              <% for(pidx = 0; pidx < obj.nAIUs; pidx++) { %>
              <% if(obj.AiuInfo[pidx].fnNativeInterface.match("CHI")) { %>
               disable m_chi<%=chi_idx%>_vseq.body.t2_th;
               disable m_chi<%=chi_idx%>_vseq.body.t3_th;
               disable m_chi<%=chi_idx%>_vseq.body.t4_th;
               disable m_chi<%=chi_idx%>_vseq.body.t5_th;
               disable m_chi<%=chi_idx%>_vseq.body.t6_th;
               disable m_chi<%=chi_idx%>_vseq.body.t7_th;
               disable m_chi<%=chi_idx%>_vseq.body.t8_th;
               // disable m_chi<%=chi_idx%>_vseq.t9_th;
               //disable m_chi<%=chi_idx%>_vseq.body; // kill body to avoid double body & so double fork thread // body will be restart in next iterations
               m_chi<%=chi_idx%>_vseq.m_rn_tx_req_chnl_seqr.stop_sequences();
               m_chi<%=chi_idx%>_vseq.m_rn_tx_dat_chnl_seqr.stop_sequences();
               m_chi<%=chi_idx%>_vseq.m_rn_tx_rsp_chnl_seqr.stop_sequences();
               m_chi<%=chi_idx%>_vseq.m_rn_rx_rsp_chnl_seqr.stop_sequences();
               m_chi<%=chi_idx%>_vseq.m_rn_rx_dat_chnl_seqr.stop_sequences();
               m_chi<%=chi_idx%>_vseq.m_rn_rx_snp_chnl_seqr.stop_sequences();
               m_chi<%=chi_idx%>_vseq.m_lnk_hske_seqr.stop_sequences();      
               m_chi<%=chi_idx%>_vseq.m_txs_actv_seqr.stop_sequences();      
               m_chi<%=chi_idx%>_vseq.m_sysco_seqr.stop_sequences();         
              `uvm_info("FULL_SYS", "Disable CHI<%=chi_idx%> vseq.body", UVM_NONE);
               <%chi_idx++;%>
              <%} // if chi%>
              <%}//foreach aiu%>
           end
    `endif // `ifdef VCS
endtask

//////////////////
//Calling Method: Child Class
//Description: Constructor
//Arguments:   UVM Default
//Return type: N/A
//////////////////
function concerto_iosubsys_test_snps::new(string name = "concerto_iosubsys_test_snps", uvm_component parent = null);
    super.new(name, parent);
    hard_reset_issued = 0;
    if(inst_name=="")
      inst_name=name;
endfunction: new

//////////////////
//Calling Method: UVM Factory
//Description: Build phase
//Arguments:   UVM Default
//Return type: Void
//////////////////
function void concerto_iosubsys_test_snps::build_phase(uvm_phase phase);

    string msg_idx;
    int    transorder_mode;

    `uvm_info("Build", "Entered Build Phase", UVM_LOW);
    super.build_phase(phase);

    if (!$value$plusargs("chi_num_trans=%d",chi_num_trans)) begin
        chi_num_trans = 0;
    end
    if (!$value$plusargs("ioaiu_num_trans=%d",ioaiu_num_trans)) begin
        ioaiu_num_trans = 0;
    end

    if ($test$plusargs("func_unit_uncorr_err_inj") || $test$plusargs("dup_unit_uncorr_err_inj")) begin
        $value$plusargs("func_unit_uncorr_err_inj=%d",func_unit_uncorr_err_inj);
        $value$plusargs("dup_unit_uncorr_err_inj=%d",dup_unit_uncorr_err_inj);
        if(func_unit_uncorr_err_inj && dup_unit_uncorr_err_inj)  both_units_uncorr_err_inj = 1;
    end else begin
        func_unit_uncorr_err_inj = 1;
    end


   /// BEGIN INHOUSE IOAIU SEQ
    <% 
      ioaiu_idx = 0;
   %>
  <% for(pidx = 0 ; pidx < obj.nAIUs; pidx++) { %>
      <% if(!((obj.AiuInfo[pidx].fnNativeInterface == 'CHI-A') || (obj.AiuInfo[pidx].fnNativeInterface == 'CHI-B')|| (obj.AiuInfo[pidx].fnNativeInterface == 'CHI-E'))) { %>
       <% for(let i=0; i<aiu_NumCores[pidx]; i++) { %> 
      ev_ioaiu<%=ioaiu_idx%>_seq_done[<%=i%>] = ev_pool.get("m_ioaiu<%=ioaiu_idx%>_seq[<%=i%>]");
	   ev_ioaiu<%=ioaiu_idx%>_read_seq_done[<%=i%>] = ev_pool.get("m_ioaiu<%=ioaiu_idx%>_read_seq[<%=i%>]");  // read
`ifdef USE_STL_TRACE
     ioaiu_clk_posedge_e_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_<%=i%> = new("ioaiu_clk_posedge_e_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_<%=i%>");
     if(!uvm_config_db#(uvm_event)::get( .cntxt(null),
                      .inst_name( "" ),
                      .field_name( "ioaiu_clk_posedge_e_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_<%=i%>" ),
                      .value(ioaiu_clk_posedge_e_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_<%=i%>))) begin
        `uvm_error(get_name(), "Event ioaiu_clk_posedge_e_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_<%=i%> is not found")
     end
`endif // USE_STL_TRACE
     <% } %>
    <% ioaiu_idx++;
    } %>
   <% } %>
   /// END INHOUSE IOAIU SEQ

   // BEGIN SNPS VIP SEQ
   if (m_concerto_env_cfg.has_vip_snps) begin:_build_vip_snps
  if($value$plusargs("SYNPS_AXI_SLV_BACKPRESSURE_EN=%0d",SYNPS_AXI_SLV_BACKPRESSURE_EN)) begin
       `uvm_info(get_name(),$psprintf("axi_slave_mem_response_sequence - Setting SYNPS_AXI_SLV_BACKPRESSURE_EN %0d",SYNPS_AXI_SLV_BACKPRESSURE_EN),UVM_NONE)
    end
    if($test$plusargs("vip_snps_non_coherent_txn")) begin
      vip_snps_non_coherent_txn = 1;
    end
    else if($test$plusargs("vip_snps_coherent_txn")) begin
      vip_snps_coherent_txn = 1;
    end

    void'($value$plusargs("vip_snps_seq_length=%0d",vip_snps_seq_length));

    //SVT CREATE
   if (m_concerto_env_cfg.has_chi_vip_snps) begin:_build_chi_vip_snps //TODO MOVE in VIRTUAL SEQ
  <% idx=0; %>
  <% for(pidx = 0; pidx < obj.nAIUs; pidx++) { %>
    <%if((obj.AiuInfo[pidx].fnNativeInterface == 'CHI-A')||(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-B' || obj.AiuInfo[pidx].fnNativeInterface == 'CHI-E')) { %>
     `uvm_info(get_name(), "USE_VIP_SNPS svt_chi_link_service_sequence::CREATE[<%=idx%>]", UVM_NONE)
      svt_chi_link_up_seq_h<%=idx%> = svt_chi_link_service_activate_sequence::type_id::create("svt_chi_link_up_seq_h<%=idx%>");
      svt_chi_link_dn_seq_h<%=idx%> = svt_chi_link_service_deactivate_sequence::type_id::create("svt_chi_link_dn_seq_h<%=idx%>");
     `uvm_info(get_name(), "USE_VIP_SNPS svt_chi_rn_transaction_random_sequence::CREATE[<%=idx%>]", UVM_NONE)
      svt_chi_rn_seq_h<%=idx%> = svt_chi_rn_transaction_random_sequence::type_id::create("svt_chi_rn_seq_h<%=idx%>");
      <% if(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-B' || obj.AiuInfo[pidx].fnNativeInterface == 'CHI-E') { %>
        coherency_entry_seq<%=idx%> = chiaiu0_chi_aiu_vseq_pkg::cust_svt_chi_protocol_service_coherency_entry_sequence::type_id::create("coherency_entry_seq<%=idx%>");
      <% } %>
    <% idx++; %>
    <%} %>
    <%} %>

    //SVT OVERRIDE
    if(vip_snps_non_coherent_txn) begin
      set_type_override_by_type(svt_chi_rn_transaction::get_type(),rn_noncoherent_transaction::get_type());
    end
    else if(vip_snps_coherent_txn) begin
      set_type_override_by_type(svt_chi_rn_transaction::get_type(),rn_coherent_transaction::get_type());
    end    
    else begin
      set_type_override_by_type(svt_chi_rn_transaction::get_type(),svt_chi_item::get_type());
    `ifdef CHI_UNITS_CNT_NON_ZERO
      set_type_override_by_type(svt_chi_rn_snoop_response_sequence::get_type(),chiaiu0_chi_aiu_vseq_pkg::cust_svt_chi_rn_directed_snoop_response_sequence::get_type());
    `endif // CHI_UNITS_CNT_NON_ZERO
      `uvm_info(get_name(),$psprintf("Overrode svt_chi_rn_transaction by svt_chi_item"),UVM_DEBUG)
    end

   // UVM_DB SET
    uvm_config_db#(int unsigned)::set(this, "m_concerto_env.snps.svt.amba_system_env.chi_system[0].rn[<%=chiaiu_idx%>].rn_xact_seqr.svt_chi_rn_transaction_random_sequence", "sequence_length", chi_num_trans);
    uvm_config_db#(bit)::set(this, "m_concerto_env.snps.svt.amba_system_env.chi_system[0].rn[<%=chiaiu_idx%>].rn_xact_seqr.svt_chi_rn_transaction_random_sequence", "enable_non_blocking", 1);

   end:_build_chi_vip_snps
    
   if (m_concerto_env_cfg.has_axi_vip_snps) begin:_build_axi_vip_snps // TODO MOVE in VIRTUAL SEQ
  <% qidx=0; %>
  <% for(pidx = 0; pidx < obj.nAIUs; pidx++) { %>
    <%if(!(obj.AiuInfo[pidx].fnNativeInterface.match("CHI"))) { %>
     /*<%if((obj.AiuInfo[pidx].fnNativeInterface == 'ACE-LITE' || obj.AiuInfo[pidx].fnNativeInterface == 'ACELITE-E' || obj.AiuInfo[pidx].fnNativeInterface == 'ACE') || (obj.AiuInfo[pidx].fnNativeInterface == 'AXI4' && obj.AiuInfo[pidx].useCache)) { %>
     snp_cust_seq_h<%=qidx%> = ioaiu<%=qidx%>_env_pkg::snp_cust_seq::type_id::create("snp_cust_seq_h<%=qidx%>"); 
     <% } %> */
    <% for(let i=0; i<aiu_NumCores[pidx]; i++) { %> 
      cust_seq_h<%=qidx%>[<%=i%>] = ioaiu<%=qidx%>_env_pkg::snps_axi_master_pipelined_seq::type_id::create("cust_seq_h<%=qidx%>[<%=i%>]");
    <% } %>
  <% qidx++; } } %>
    set_type_override_by_type(svt_axi_master_transaction::get_type(),io_subsys_pkg::io_subsys_axi_master_transaction::get_type());
    set_type_override_by_type(svt_axi_slave_transaction::get_type(),io_subsys_pkg::io_subsys_axi_slave_transaction::get_type());
    set_type_override_by_type(svt_axi_master_snoop_transaction::get_type(),io_subsys_pkg::io_subsys_ace_master_snoop_transaction::get_type());
  <% if (found_csr_access_ioaiu > 0) { let i=0;%>
      set_type_override_by_type(svt_axi_master_snoop_transaction::get_type(),ioaiu0_env_pkg::cust_svt_axi_snoop_transaction::get_type());
      `uvm_info(get_name(),$psprintf("Overrode svt_axi_master_snoop_transaction by cust_svt_axi_snoop_transaction"),UVM_DEBUG)
      ///cust_seq_h<%=qidx%>[<%=i%>] = ioaiu<%=qidx%>_env_pkg::snps_axi_master_pipelined_seq::type_id::create("cust_seq_h<%=qidx%>_seq");

      if($test$plusargs("use_dvm")) begin
        set_type_override_by_type(svt_axi_master_transaction::get_type(),ioaiu0_env_pkg::ioaiu_axi_master_transaction::get_type());
        `uvm_info(get_name(),$psprintf("Override svt_axi_master_transaction by ioaiu_axi_master_transaction"),UVM_DEBUG)
      end else begin
        <% for(let ncidx = 0,idx = 0; idx < obj.nAIUs; idx++) { 
              if((obj.AiuInfo[idx].fnNativeInterface == 'ACE')) { %>
            set_inst_override_by_type("m_concerto_env.snps.svt.amba_system_env.axi_system[0].master[<%=ncidx%>].*",svt_axi_master_transaction::get_type(),ioaiu0_env_pkg::ioaiu<%=ncidx%>_axi_master_transaction::get_type());
            `uvm_info(get_name(),$psprintf("Overrode  <%=ncidx%> svt_axi_master_transaction by ioaiu_axi_master_transaction"),UVM_NONE)
         <% ncidx++; } %>
      <% } %>
      end
    <% } %>
   end:_build_axi_vip_snps

    /** Apply the null sequence to the AMBA ENV virtual sequencer to override the default sequence. */
    uvm_config_db#(uvm_object_wrapper)::set(this, "m_concerto_env.snps.svt.amba_system_env.sequencer.main_phase", "default_sequence", null ); 
   end:_build_vip_snps
    
    set_inactivity_period(m_args.k_timeout);
    
    if(!$value$plusargs("boot_from_ioaiu=%d",boot_from_ioaiu)) begin
       boot_from_ioaiu = 0;
    end

  

       `uvm_info("Build", "Exited Build Phase", UVM_LOW);
 endfunction: build_phase

task concerto_iosubsys_test_snps::run_ioaiu_test_seq(input string initiator_port_name="", int ioaiu_port_id=0);
    if(conc_ioaiu_fnnativeif_array[ioaiu_port_id]=="ACE" || conc_ioaiu_fnnativeif_array[ioaiu_port_id]=="ACE-LITE" || conc_ioaiu_fnnativeif_array[ioaiu_port_id]=="ACELITE-E") begin
        `uvm_info("concerto_iosubsys_test_snps::run_ioaiu_test",$psprintf("Calling run_ioaiu_ace_test_seq for IOAIU[%0d/%0s]",ioaiu_port_id,initiator_port_name),UVM_LOW)
        run_ioaiu_ace_test_seq(initiator_port_name,ioaiu_port_id);
    end else if(conc_ioaiu_fnnativeif_array[ioaiu_port_id]=="AXI4") begin
        `uvm_info("concerto_iosubsys_test_snps::run_ioaiu_test",$psprintf("Calling run_ioaiu_axi4_test_seq for IOAIU[%0d/%0s]",ioaiu_port_id,initiator_port_name),UVM_LOW)
        run_ioaiu_axi4_test_seq(initiator_port_name,ioaiu_port_id);
    end else begin
        `uvm_error("concerto_iosubsys_test_snps::run_ioaiu_test",$psprintf("Please specify appropriate ioaiu fnnative interface IOAIU[%0d/%0s]",ioaiu_port_id,initiator_port_name))
    end
endtask

task concerto_iosubsys_test_snps::run_ioaiu_ace_test_seq(input string initiator_port_name="", int ioaiu_port_id=0);
    `uvm_info("concerto_iosubsys_test_snps::run_ioaiu_ace_test_seq",$psprintf("Starting sequence on IOAIU[%0d/%0s]",ioaiu_port_id,initiator_port_name),UVM_LOW)
endtask

task concerto_iosubsys_test_snps::run_ioaiu_axi4_test_seq(input string initiator_port_name="", int ioaiu_port_id=0);
    `uvm_info("concerto_iosubsys_test_snps::run_ioaiu_ace_test_seq",$psprintf("Starting sequence on IOAIU[%0d/%0s]",ioaiu_port_id,initiator_port_name),UVM_LOW)
endtask

//CONC-11906 To-Do: Move all below in concerto_helper_pkg_snps.svh
task concerto_iosubsys_test_snps::initialize_conc_helper_var_snps();

conc_ioaiu_fnnativeif_array
   = {
<% let ioaiu_cntr=0; ioaiu_idx_with_multi_core=0;
for(pidx=0; pidx<obj.nAIUs; pidx++) {
if(obj.AiuInfo[pidx].fnNativeInterface == 'ACE-LITE' || obj.AiuInfo[pidx].fnNativeInterface == 'ACELITE-E' || obj.AiuInfo[pidx].fnNativeInterface == 'ACE' || obj.AiuInfo[pidx].fnNativeInterface == 'AXI4') {
for(let i=0; i<aiu_NumCores[pidx]; i++) {
if(ioaiu_cntr<(numIoAiu-1)) { %>    
     "<%=obj.AiuInfo[pidx].fnNativeInterface%>",
<% } else { %>    
     "<%=obj.AiuInfo[pidx].fnNativeInterface%>"
<% }     
ioaiu_cntr = ioaiu_cntr + 1; }}} %>
};

//`uvm_info("concerto_iosubsys_test_snps", $psprintf("fn:initialize_conc_helper_var_snps conc_ioaiu_fnnativeif_array - %0p", conc_ioaiu_fnnativeif_array), UVM_LOW);

 conc_ioaiu_name_array
   = {
<% ioaiu_cntr=0; 
for(pidx=0; pidx<obj.nAIUs; pidx++) {  
if(obj.AiuInfo[pidx].fnNativeInterface == 'ACE-LITE' || obj.AiuInfo[pidx].fnNativeInterface == 'ACELITE-E' || obj.AiuInfo[pidx].fnNativeInterface == 'ACE' || obj.AiuInfo[pidx].fnNativeInterface == 'AXI4') { 
for(let i=0; i<aiu_NumCores[pidx]; i++) {
if(ioaiu_cntr<(numIoAiu-1)) { %>    
     "<%=obj.AiuInfo[pidx].strRtlNamePrefix%>",
<% } else { %>    
     "<%=obj.AiuInfo[pidx].strRtlNamePrefix%>"
<% }     
 ioaiu_cntr = ioaiu_cntr + 1; }}} %>
};

//`uvm_info("concerto_iosubsys_test_snps", $psprintf("fn:initialize_conc_helper_var_snps conc_ioaiu_name_array - %0p", conc_ioaiu_name_array), UVM_LOW);

conc_svt_axi_sysseqr_path_str = $psprintf("%0s.%0s",`CONC_COMMON_STRINGIFY(`CONC_SVT_AXI_SYSENV_0_PATH),"sequencer");

<% ioaiu_cntr=0;   ioaiu_idx_with_multi_core=0;
for(pidx=0; pidx<obj.nAIUs; pidx++) {  
if(obj.AiuInfo[pidx].fnNativeInterface == 'ACE-LITE' || obj.AiuInfo[pidx].fnNativeInterface == 'ACELITE-E' || obj.AiuInfo[pidx].fnNativeInterface == 'ACE' || obj.AiuInfo[pidx].fnNativeInterface == 'AXI4') { 
for(let i=0; i<aiu_NumCores[pidx]; i++) { %>
conc_svt_axi_master_agnt_seqr[<%=ioaiu_cntr%>] = `CONC_SVT_IOAIU<%=ioaiu_cntr%>_<%=i%>_MASTER_SEQR_PATH;
<% ioaiu_idx_with_multi_core = ioaiu_idx_with_multi_core + 1;} ioaiu_cntr = ioaiu_cntr + 1;} } %>

foreach(conc_svt_axi_master_agnt_seqr_path_string_array[i]) begin
    conc_svt_axi_master_agnt_seqr_path_string_array[i] = $psprintf("%0s.%0s",`CONC_COMMON_STRINGIFY(`CONC_SVT_AXI_SYSENV_0_PATH),"master[i].sequencer");
end

foreach(conc_svt_axi_slave_agnt_seqr_path_string_array[i]) begin
    conc_svt_axi_slave_agnt_seqr_path_string_array[i] = $psprintf("%0s.%0s",`CONC_COMMON_STRINGIFY(`CONC_SVT_AXI_SYSENV_0_PATH),"slave[i].sequencer");
end


`ifdef USE_VIP_SNPS_AXI_SLAVES
<% for(pidx=0; pidx<axi_slv_idx; pidx++) { %> 
conc_svt_axi_slave_agnt_seqr[<%=pidx%>]  = `CONC_SVT_AXI_SLAVE<%=pidx%>_SEQR_PATH;
<% } %>

<% for(pidx=0; pidx<obj.nDMIs; pidx++) { %> 
conc_svt_dmi_slave_agnt_seqr[<%=pidx%>]  = `CONC_SVT_DMI<%=pidx%>_SLAVE_SEQR_PATH;
<% } %>

<% for(pidx=0; pidx<obj.nDIIs; pidx++) {  
if(obj.DiiInfo[pidx].configuration == 0) { %>
conc_svt_dii_slave_agnt_seqr[<%=pidx%>]  = `CONC_SVT_DII<%=pidx%>_SLAVE_SEQR_PATH;
<% }}  %>
`endif //`ifdef USE_VIP_SNPS_AXI_SLAVES
endtask

function concerto_iosubsys_test_snps concerto_iosubsys_test_snps::get_instance();
concerto_iosubsys_test_snps fullsys_test;
uvm_root top;
  top = uvm_root::get();
  if(top.get_child(inst_name)==null) begin
      $display("concerto_iosubsys_test_snps, could not find handle of fullsys_test %0s",inst_name);
  end
  else
    $cast(fullsys_test,top.get_child(inst_name));
  return fullsys_test;

endfunction:get_instance

//////////////////
//Calling Method: UVM Factory
//Description: end of elaboration phase
//Arguments:   UVM Default
//Return type: Void
//////////////////
function void concerto_iosubsys_test_snps::end_of_elaboration_phase(uvm_phase phase);
    int file_handle;
    `uvm_info("end_of_elaboration_phase", "Entered...", UVM_LOW)
    initialize_conc_helper_var_snps();
    //`uvm_error("end_of_elaboration_phase", "End to debug")
  
  //Create plusargs objects for aiu
   <% 
      chiaiu_idx = 0;
      ioaiu_idx = 0;
   %>
<% for(pidx = 0 ; pidx < obj.nAIUs; pidx++) { %>

    <% if(!((obj.AiuInfo[pidx].fnNativeInterface == 'CHI-A') || (obj.AiuInfo[pidx].fnNativeInterface == 'CHI-B')|| (obj.AiuInfo[pidx].fnNativeInterface == 'CHI-E'))) { %>
      <% for(let i=0; i<aiu_NumCores[pidx]; i++) { %> 
    m_concerto_env.inhouse.m_ace_cache_model_ioaiu<%=ioaiu_idx%>[<%=i%>].prob_unq_cln_to_unq_dirty                    =  m_args.aiu<%=pidx%>_prob_unq_cln_to_unq_dirty;
    m_concerto_env.inhouse.m_ace_cache_model_ioaiu<%=ioaiu_idx%>[<%=i%>].prob_unq_cln_to_invalid                      =  m_args.aiu<%=pidx%>_prob_unq_cln_to_invalid;
    m_concerto_env.inhouse.m_ace_cache_model_ioaiu<%=ioaiu_idx%>[<%=i%>].total_outstanding_coh_writes                 =  m_args.aiu<%=pidx%>_total_outstanding_coh_writes;
    m_concerto_env.inhouse.m_ace_cache_model_ioaiu<%=ioaiu_idx%>[<%=i%>].total_min_ace_cache_size                     =  m_args.aiu<%=pidx%>_total_min_ace_cache_size;
    m_concerto_env.inhouse.m_ace_cache_model_ioaiu<%=ioaiu_idx%>[<%=i%>].total_max_ace_cache_size                     =  m_args.aiu<%=pidx%>_total_max_ace_cache_size;
    m_concerto_env.inhouse.m_ace_cache_model_ioaiu<%=ioaiu_idx%>[<%=i%>].size_of_wr_queue_before_flush                =  m_args.aiu<%=pidx%>_size_of_wr_queue_before_flush;
    m_concerto_env.inhouse.m_ace_cache_model_ioaiu<%=ioaiu_idx%>[<%=i%>].wt_expected_end_state                        =  m_args.aiu<%=pidx%>_wt_expected_end_state;
    m_concerto_env.inhouse.m_ace_cache_model_ioaiu<%=ioaiu_idx%>[<%=i%>].wt_legal_end_state_with_sf                   =  m_args.aiu<%=pidx%>_wt_legal_end_state_with_sf;
    m_concerto_env.inhouse.m_ace_cache_model_ioaiu<%=ioaiu_idx%>[<%=i%>].wt_legal_end_state_without_sf                =  m_args.aiu<%=pidx%>_wt_legal_end_state_without_sf;
    m_concerto_env.inhouse.m_ace_cache_model_ioaiu<%=ioaiu_idx%>[<%=i%>].wt_expected_start_state                      =  m_args.aiu<%=pidx%>_wt_expected_start_state;
    m_concerto_env.inhouse.m_ace_cache_model_ioaiu<%=ioaiu_idx%>[<%=i%>].wt_legal_start_state                         =  m_args.aiu<%=pidx%>_wt_legal_start_state;
    m_concerto_env.inhouse.m_ace_cache_model_ioaiu<%=ioaiu_idx%>[<%=i%>].wt_lose_cache_line_on_snps                   =  m_args.aiu<%=pidx%>_wt_lose_cache_line_on_snps;
    m_concerto_env.inhouse.m_ace_cache_model_ioaiu<%=ioaiu_idx%>[<%=i%>].wt_keep_drty_cache_line_on_snps              =  m_args.aiu<%=pidx%>_wt_keep_drty_cache_line_on_snps;
    m_concerto_env.inhouse.m_ace_cache_model_ioaiu<%=ioaiu_idx%>[<%=i%>].prob_respond_to_snoop_coll_with_wr           =  m_args.aiu<%=pidx%>_prob_respond_to_snoop_coll_with_wr;
    m_concerto_env.inhouse.m_ace_cache_model_ioaiu<%=ioaiu_idx%>[<%=i%>].prob_was_unique_snp_resp                     =  m_args.aiu<%=pidx%>_prob_was_unique_snp_resp;
    m_concerto_env.inhouse.m_ace_cache_model_ioaiu<%=ioaiu_idx%>[<%=i%>].prob_was_unique_always0_snp_resp             =  m_args.aiu<%=pidx%>_prob_was_unique_always0_snp_resp;
    m_concerto_env.inhouse.m_ace_cache_model_ioaiu<%=ioaiu_idx%>[<%=i%>].prob_dataxfer_snp_resp_on_clean_hit          =  m_args.aiu<%=pidx%>_prob_dataxfer_snp_resp_on_clean_hit;
    m_concerto_env.inhouse.m_ace_cache_model_ioaiu<%=ioaiu_idx%>[<%=i%>].prob_ace_wr_ix_start_state                   =  m_args.aiu<%=pidx%>_prob_ace_wr_ix_start_state;
    m_concerto_env.inhouse.m_ace_cache_model_ioaiu<%=ioaiu_idx%>[<%=i%>].prob_ace_rd_ix_start_state                   =  m_args.aiu<%=pidx%>_prob_ace_rd_ix_start_state;
    m_concerto_env.inhouse.m_ace_cache_model_ioaiu<%=ioaiu_idx%>[<%=i%>].prob_cache_flush_mode_per_1k                 =  m_args.aiu<%=pidx%>_prob_cache_flush_mode_per_1k;
    m_concerto_env.inhouse.m_ace_cache_model_ioaiu<%=ioaiu_idx%>[<%=i%>].prob_ace_snp_resp_error                      =  m_args.aiu<%=pidx%>_prob_ace_snp_resp_error;
    if(m_mem.noncoh_reg_maps_to_dii == 1) begin
       m_concerto_env.inhouse.m_ace_cache_model_ioaiu<%=ioaiu_idx%>[<%=i%>].prob_ace_coh_win_error                       =  100;
    end else begin
       m_concerto_env.inhouse.m_ace_cache_model_ioaiu<%=ioaiu_idx%>[<%=i%>].prob_ace_coh_win_error                       =  m_args.aiu<%=ioaiu_idx%>_prob_ace_coh_win_error;
    end
    //if($test$plusargs("perf_test") || $test$plusargs("no_delay")) begin
        m_concerto_env_cfg.m_ioaiu<%=ioaiu_idx%>_env_cfg[<%=i%>].m_axi_master_agent_cfg.k_ace_master_read_addr_chnl_delay_min.set_value(0);
        m_concerto_env_cfg.m_ioaiu<%=ioaiu_idx%>_env_cfg[<%=i%>].m_axi_master_agent_cfg.k_ace_master_read_addr_chnl_delay_max.set_value(0);
        m_concerto_env_cfg.m_ioaiu<%=ioaiu_idx%>_env_cfg[<%=i%>].m_axi_master_agent_cfg.k_ace_master_read_addr_chnl_burst_pct.set_value(100);
        m_concerto_env_cfg.m_ioaiu<%=ioaiu_idx%>_env_cfg[<%=i%>].m_axi_master_agent_cfg.k_ace_master_read_data_chnl_delay_min.set_value(0);
        m_concerto_env_cfg.m_ioaiu<%=ioaiu_idx%>_env_cfg[<%=i%>].m_axi_master_agent_cfg.k_ace_master_read_data_chnl_delay_max.set_value(0);
        m_concerto_env_cfg.m_ioaiu<%=ioaiu_idx%>_env_cfg[<%=i%>].m_axi_master_agent_cfg.k_ace_master_read_data_chnl_burst_pct.set_value(100);
        m_concerto_env_cfg.m_ioaiu<%=ioaiu_idx%>_env_cfg[<%=i%>].m_axi_master_agent_cfg.k_ace_master_write_addr_chnl_delay_min.set_value(0);
        m_concerto_env_cfg.m_ioaiu<%=ioaiu_idx%>_env_cfg[<%=i%>].m_axi_master_agent_cfg.k_ace_master_write_addr_chnl_delay_max.set_value(0);
        m_concerto_env_cfg.m_ioaiu<%=ioaiu_idx%>_env_cfg[<%=i%>].m_axi_master_agent_cfg.k_ace_master_write_addr_chnl_burst_pct.set_value(100);
        m_concerto_env_cfg.m_ioaiu<%=ioaiu_idx%>_env_cfg[<%=i%>].m_axi_master_agent_cfg.k_ace_master_write_data_chnl_delay_min.set_value(0);
        m_concerto_env_cfg.m_ioaiu<%=ioaiu_idx%>_env_cfg[<%=i%>].m_axi_master_agent_cfg.k_ace_master_write_data_chnl_delay_max.set_value(0);
        m_concerto_env_cfg.m_ioaiu<%=ioaiu_idx%>_env_cfg[<%=i%>].m_axi_master_agent_cfg.k_ace_master_write_data_chnl_burst_pct.set_value(100);
        m_concerto_env_cfg.m_ioaiu<%=ioaiu_idx%>_env_cfg[<%=i%>].m_axi_master_agent_cfg.k_ace_master_write_resp_chnl_delay_min.set_value(0);
        m_concerto_env_cfg.m_ioaiu<%=ioaiu_idx%>_env_cfg[<%=i%>].m_axi_master_agent_cfg.k_ace_master_write_resp_chnl_delay_max.set_value(0);
        m_concerto_env_cfg.m_ioaiu<%=ioaiu_idx%>_env_cfg[<%=i%>].m_axi_master_agent_cfg.k_ace_master_write_resp_chnl_burst_pct.set_value(100);
    //end
    <% } //foreach interfacesPort%> 
    <% ioaiu_idx++; } %>

<% } %>

    if (this.get_report_verbosity_level() > UVM_LOW) begin
        uvm_top.print_topology();
    end
    `uvm_info("end_of_elaboration_phase", "Exiting...", UVM_LOW)
endfunction: end_of_elaboration_phase

task concerto_iosubsys_test_snps::reset_phase(uvm_phase phase);
   `uvm_info("IOSUBSYS_TEST_SNPS", "Entering RESET", UVM_LOW)
   super.reset_phase(phase);
   `uvm_info("IOSUBSYS_TEST_SNPS", "Exiting RESET", UVM_LOW)
endtask: reset_phase

task concerto_iosubsys_test_snps::pre_configure_phase(uvm_phase phase); 
    bit [31:0] agent_id,way_vec,way_full_chk;
    int shared_ways_per_user;
    int way_for_atomic=0;

    int idxq[$];

    ncore_config_pkg::ncoreConfigInfo::sys_addr_csr_t csrq[$];
    csrq = ncore_config_pkg::ncoreConfigInfo::get_all_gpra();
  `uvm_info("IOSUBSYS_TEST_SNPS", "START PRE_CONFIGURE_PHASE", UVM_LOW)
 // Setup SysCo Attach for IOAIU scoreboards
    if(m_args.ioaiu_scb_en && !$test$plusargs("sysco_disable") && !test_cfg.disable_boot_tasks) begin
    //#1ns;   // add small delay to make sure trigger() is called after wait_trigger()   
    <% let ioidx=0;
    for(pidx=0; pidx<obj.nAIUs; pidx++) {
    if((obj.AiuInfo[pidx].fnNativeInterface != 'CHI-A') && (obj.AiuInfo[pidx].fnNativeInterface != 'CHI-B') && (obj.AiuInfo[pidx].fnNativeInterface != 'CHI-E') ) { 
    if((((obj.AiuInfo[pidx].fnNativeInterface === "ACELITE-E") || (obj.AiuInfo[pidx].fnNativeInterface === "ACE-LITE")) && (obj.AiuInfo[pidx].cmpInfo.nDvmSnpInFlight > 0)) || (obj.AiuInfo[pidx].fnNativeInterface == "ACE") || ((obj.AiuInfo[pidx].fnNativeInterface == "AXI4") && (obj.AiuInfo[pidx].useCache))) { %>
        `uvm_info("TEST PRE_CONFIGURE_PHASE", "Triggering IOAIU<%=ioidx%> ev_sysco_fsm_state_change to CONNECT", UVM_NONE)
        m_concerto_env.inhouse.m_ioaiu<%=ioidx%>_env.m_env[0].m_scb.m_sysco_fsm_state = ioaiu<%=ioidx%>_env_pkg::CONNECT;  
        ev_sysco_fsm_state_change_<%=obj.AiuInfo[pidx].FUnitId%>.trigger();   
    <% } ioidx++;
    } } %>
    end // if (m_args.ioaiu_scb_en && !$test$plusargs("sysco_disable"))
    if(test_cfg.use_new_csr==0) begin // Configure ncore register using legacy boot task 
        for(int i=0; i<ncore_config_pkg::ncoreConfigInfo::NUM_DMIS; i++) begin
        int max_way_partitioning;
           if(ncore_config_pkg::ncoreConfigInfo::dmis_with_ae[i]) begin  
              way_for_atomic = $urandom_range(0,ncore_config_pkg::ncoreConfigInfo::dmi_CmcWays[i]-1);
           end
           if(ncore_config_pkg::ncoreConfigInfo::dmis_with_cmcwp[i]) begin  
              way_full_chk = 0;
              for(int k=0; k<<%=obj.nAIUs%>;k++) begin
                 agent_ids_assigned_q[i].push_back(k);  
              end
              agent_ids_assigned_q[i].shuffle();  
             max_way_partitioning = (ncore_config_pkg::ncoreConfigInfo::dmi_CmcWPReg[i] > <%=obj.nAIUs%>) ? <%=obj.nAIUs%> : ncore_config_pkg::ncoreConfigInfo::dmi_CmcWPReg[i];
             for( int j=0;j<max_way_partitioning /*ncore_config_pkg::ncoreConfigInfo::dmi_CmcWPReg[i]*/;j++) begin
                 if ($test$plusargs("all_way_partitioning")) begin
                    if((j==0)&&(ncore_config_pkg::ncoreConfigInfo::dmis_with_ae[j]==0)) begin 
                       agent_id = 32'h8000_0000 |  agent_ids_assigned_q[i][j]; agent_ids_assigned_q[i][j] = agent_id; end
                    else     begin agent_id = 32'h0000_0000 |  agent_ids_assigned_q[i][j]; agent_ids_assigned_q[i][j] = agent_id; end
                 end else begin
                    randcase
                      10 : begin agent_id = 32'h0000_0000 | agent_ids_assigned_q[i][j]; agent_ids_assigned_q[i][j] = agent_id; end
                      90 : begin agent_id = 32'h8000_0000 | agent_ids_assigned_q[i][j]; agent_ids_assigned_q[i][j] = agent_id; end
                    endcase
                 end

                 case(i) <%for(let sidx = 0; sidx < obj.nDMIs; sidx++) {%>
                    <%=sidx%> : begin <% if(obj.DmiInfo[sidx].useWayPartitioning && obj.DmiInfo[sidx].useCmc) {%>
                                     if(dmi_scb_en) begin
                                        m_concerto_env.m_dmi<%=sidx%>_env.m_sb.way_partition_vld[j] = agent_id[31]; m_concerto_env.m_dmi<%=sidx%>_env.m_sb.way_partition_reg_id[j] = agent_id[30:0];
                                        if ($test$plusargs("no_way_partitioning")) m_concerto_env.m_dmi<%=sidx%>_env.m_sb.way_partition_vld[j]=0;
                                        end
                                    <%}%>end
            <%}%>endcase

              end // for Waypart Registers
              if(ncore_config_pkg::ncoreConfigInfo::dmis_with_ae[i]==0) begin
                 shared_ways_per_user = ncore_config_pkg::ncoreConfigInfo::dmi_CmcWays[i]/ncore_config_pkg::ncoreConfigInfo::dmi_CmcWPReg[i];
              end else begin
                 shared_ways_per_user = (ncore_config_pkg::ncoreConfigInfo::dmi_CmcWays[i]-1)/ncore_config_pkg::ncoreConfigInfo::dmi_CmcWPReg[i];
              end
              for( int j=0;j<ncore_config_pkg::ncoreConfigInfo::dmi_CmcWPReg[i];j++) begin
                  if ($test$plusargs("all_way_partitioning")&&(ncore_config_pkg::ncoreConfigInfo::dmis_with_ae[j]==0)) begin
                     way_vec = ((1<<ncore_config_pkg::ncoreConfigInfo::dmi_CmcWays[i])-1);
                  end else begin
                     way_vec = ((1<<$urandom_range(1,shared_ways_per_user)) - 1) << (shared_ways_per_user)*j;
                  end
                  if ($test$plusargs("no_way_partitioning")) way_vec=0;
            	      `uvm_info("TEST PRE_CONFIGURE_PHASE", $sformatf("For DMI%0d reg%0d with wayvec :%0b",i,j,way_vec), UVM_LOW)
                  wayvec_assigned_q[i].push_back(way_vec);
                  way_full_chk |=way_vec;
                  `uvm_info("TEST PRE_CONFIGURE_PHASE", $sformatf("For DMI%0d reg%0d with wayfull:%0b num ways in DMI:%0d",i,j,way_full_chk,ncore_config_pkg::ncoreConfigInfo::dmi_CmcWays[i]), UVM_LOW)
              end

              for( int j=0;j<ncore_config_pkg::ncoreConfigInfo::dmi_CmcWPReg[i];j++) begin
                  `uvm_info("TEST PRE_CONFIGURE_PHASE", $sformatf("For DMI%0d reg%0d with wayfull:%0b count ones:%0d",i,j,way_full_chk,$countones(way_full_chk)), UVM_LOW)
                  way_vec = wayvec_assigned_q[i].pop_front;
                  if(ncore_config_pkg::ncoreConfigInfo::dmis_with_ae[i] && $countones(way_full_chk)>=ncore_config_pkg::ncoreConfigInfo::dmi_CmcWays[i]) begin  
                     way_vec[way_for_atomic] = 1'b0;
                     `uvm_info("TEST PRE_CONFIGURE_PHASE", $sformatf("For DMI%0d with AtomicEngine way:%0d/%0d is unallocated, so that atomic txn can allocate",i,way_for_atomic,ncore_config_pkg::ncoreConfigInfo::dmi_CmcWays[i]), UVM_LOW)
                     `uvm_info("TEST PRE_CONFIGURE_PHASE", $sformatf("For DMI%0d reg%0d with wayvec :%0b",i,j,way_vec), UVM_LOW)
                  end
                  wayvec_assigned_q[i].push_back(way_vec);

                  case(i) <%for(let sidx = 0; sidx < obj.nDMIs; sidx++) {%>
                     <%=sidx%> : begin <% if(obj.DmiInfo[sidx].useWayPartitioning && obj.DmiInfo[sidx].useCmc) {%>
                                      if(dmi_scb_en) begin
                                         m_concerto_env.m_dmi<%=sidx%>_env.m_sb.way_partition_reg_way[j] = way_vec;
                                      end
                                      <%}%>end
             <%}%>endcase
              end
           end // if (ncore_config_pkg::ncoreConfigInfo::dmis_with_cmcwp[i])

           // Configure Scratchpad memories
           if(ncore_config_pkg::ncoreConfigInfo::dmis_with_cmcsp[i]) begin  
              // Enabling and configuring Scratchpad using force
              if ($test$plusargs("all_ways_for_sp")) begin
                  sp_ways[i] = ncore_config_pkg::ncoreConfigInfo::dmi_CmcWays[i];
              end else if ($test$plusargs("all_ways_for_cache")) begin
                  sp_ways[i] = 0;
              end else begin
                  randcase
                      //15 : sp_ways[i] = 0;
                      30 : sp_ways[i] = ncore_config_pkg::ncoreConfigInfo::dmi_CmcWays[i];
                      30 : sp_ways[i] = (ncore_config_pkg::ncoreConfigInfo::dmi_CmcWays[i]/2);
                      40 : sp_ways[i] = $urandom_range(1,(ncore_config_pkg::ncoreConfigInfo::dmi_CmcWays[i]-1));
                  endcase
              end
 
              idxq = csrq.find_index(x) with (  (x.unit.name == "DMI") && (x.mig_nunitid == ncore_config_pkg::ncoreConfigInfo::dmi_intrlvgrp[ncore_config_pkg::ncoreConfigInfo::picked_dmi_igs][i]) );
              if(idxq.size() == 0) begin
                  `uvm_error("EXEC_INHOUSE_BOOT_SEQ", $sformatf("DMI%0d Interleaving group %0d not found", i, ncore_config_pkg::ncoreConfigInfo::dmi_intrlvgrp[ncore_config_pkg::ncoreConfigInfo::picked_dmi_igs][i]))
                  end
              k_sp_base_addr[i] = {csrq[idxq[0]].upp_addr,csrq[idxq[0]].low_addr,12'h0}; 

              sp_size[i] = ncore_config_pkg::ncoreConfigInfo::dmi_CmcSet[i] * sp_ways[i];
              k_sp_base_addr[i] = $urandom_range(0, k_sp_base_addr[i] - (sp_size[i] << <%=obj.wCacheLineOffset%>) - 1);
              k_sp_base_addr[i] = k_sp_base_addr[i] >> ($clog2(ncore_config_pkg::ncoreConfigInfo::dmi_CmcSet[i]*ncore_config_pkg::ncoreConfigInfo::dmi_CmcWays[i])+<%=obj.wCacheLineOffset%>);
              k_sp_base_addr[i] = k_sp_base_addr[i] << ($clog2(ncore_config_pkg::ncoreConfigInfo::dmi_CmcSet[i]*ncore_config_pkg::ncoreConfigInfo::dmi_CmcWays[i])+<%=obj.wCacheLineOffset%>);

              <% if((obj.useCmc) && (numDmiWithSP > 0)) { %>
              if(dmi_scb_en) begin 
                  case(i) <%for(let sidx = 0; sidx < obj.nDMIs; sidx++) { if(obj.DmiInfo[sidx].ccpParams.useScratchpad==1) {%>
                     <%=sidx%> : 
                        if(sp_ways[<%=sidx%>] > 0) begin
                           m_concerto_env.m_dmi<%=sidx%>_env.m_sb.sp_enabled     = (ncore_config_pkg::ncoreConfigInfo::dmi_CmcWays[<%=sidx%>]) ? 32'h1 : 32'h0;
                           m_concerto_env.m_dmi<%=sidx%>_env.m_sb.lower_sp_addr  = k_sp_base_addr[<%=sidx%>];
                           m_concerto_env.m_dmi<%=sidx%>_env.m_sb.sp_ways        = sp_ways[<%=sidx%>];
                           m_concerto_env.m_dmi<%=sidx%>_env.m_sb.create_SP_q();
            	    end
                    <% } } %>
                  endcase
              end
              <% } %>
           end // if (ncore_config_pkg::ncoreConfigInfo::dmis_with_cmcsp[i])
        end // for(int i=0; i<ncore_config_pkg::ncoreConfigInfo::NUM_DMIS; i++) begin  
    end // if(test_cfg.use_new_csr==0) begin
  `uvm_info("IOSUBSYS_TEST_SNPS", "END PRE_CONFIGURE_PHASE", UVM_LOW)
endtask:pre_configure_phase

task  concerto_iosubsys_test_snps::configure_phase(uvm_phase phase);

`uvm_info("IOSUBSYS_TEST_SNPS", "START CONFIGURE_PHASE", UVM_LOW)
   super.configure_phase(phase);
phase.raise_objection(this, "Start boot configuration");
if(test_cfg.use_new_csr==0) begin // Configure ncore register using legacy boot task 
     legacy_boot_tsk_snps.ioaiu_boot_seq<%=csrAccess_ioaiu%>(agent_ids_assigned_q,wayvec_assigned_q, k_sp_base_addr, sp_ways, sp_size); 
     if (!test_cfg.disable_sw_crdt_mgr_cls) begin   
       m_concerto_sw_credit_mgr.m_regs = m_concerto_env.m_regs;    
       `uvm_info(this.get_full_name(),$sformatf("Launch Software_Credit Sequence"),UVM_LOW)
       // sw credit manager set credit 
       `uvm_info("IOAIU<%=qidx%>BOOT_SEQ-sw_credit_mgmt", $sformatf("using sw credit manager class"), UVM_LOW)
       if($test$plusargs("use_custom_credit")) begin
          m_concerto_sw_credit_mgr.en_credit_alloc = 0; 
          m_concerto_sw_credit_mgr.set_custom_credit();
       end // $test$plusargs("use_custom_credit")
       m_concerto_sw_credit_mgr.boot_sw_crdt();
      `uvm_info(this.get_full_name(),$sformatf("Leaving Software_Credit Sequence"),UVM_LOW)
   end
end 
phase.drop_objection(this, "End boot configuration");
  `uvm_info("IOSUBSYS_TEST_SNPS", "END CONFIGURE_PHASE", UVM_LOW)
endtask:configure_phase

function void concerto_iosubsys_test_snps::start_of_simulation_phase(uvm_phase phase);
  string     chiaiu_en_str[];
  string     ioaiu_en_str[];
  string     chiaiu_en_arg;
  string     ioaiu_en_arg;
 
  `uvm_info("IOSUBSYS_TEST_SNPS", "START_OF_SIMULATION", UVM_LOW)
  super.start_of_simulation_phase(phase);

  
    if(!$value$plusargs("k_nrsar_test=%d",k_nrsar_test))begin
       k_nrsar_test = 0;
    end
    if(!$value$plusargs("k_directed_test=%d",k_directed_test))begin
       k_directed_test = 0;
    end
    if(!$value$plusargs("k_directed_data_integrity=%d",k_directed_data_integrity))begin
       k_directed_data_integrity = 0;
    end
    if(!$value$plusargs("k_directed_wrunq_wrevict=%d",k_directed_wrunq_wrevict))begin
       k_directed_wrunq_wrevict = 0;
    end
    if(!$value$plusargs("k_directed_test_same_aiu=%d",k_directed_test_same_aiu))begin
       k_directed_test_same_aiu = 0;
    end
    if(!$value$plusargs("k_directed_test_wr_rd=%d",k_directed_test_wr_rd))begin
       k_directed_test_wr_rd = 0;
    end
    if(!$value$plusargs("k_directed_test_noncoh_addr_pct=%d",k_directed_test_noncoh_addr_pct))begin
       k_directed_test_noncoh_addr_pct = 0;
    end
    if(!$value$plusargs("k_directed_test_coh_addr_pct=%d",k_directed_test_coh_addr_pct))begin
       k_directed_test_coh_addr_pct = 0;
    end
    if($test$plusargs("k_directed_64B_aligned"))begin
       k_directed_64B_aligned = 1;
    end
    if(!$value$plusargs("chiaiu_en=%s", chiaiu_en_arg)) begin
    <% chiaiu_idx=0; for(pidx = 0 ; pidx < obj.nAIUs; pidx++) { %>
    <% if((obj.AiuInfo[pidx].fnNativeInterface == 'CHI-A')||(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-B')||(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-E')) { %>
       chiaiu_en[<%=chiaiu_idx%>] = 1;
       <% chiaiu_idx++; } %>
    <% } %>
    end
    else begin
       parse_str(chiaiu_en_str, "n", chiaiu_en_arg);
       foreach (chiaiu_en_str[i]) begin
	  chiaiu_en[chiaiu_en_str[i].atoi()] = 1;
       end
    end
   
    if(!$value$plusargs("ioaiu_en=%s", ioaiu_en_arg)) begin
    <% ioaiu_idx=0; for(pidx = 0 ; pidx < obj.nAIUs; pidx++) { %>
    <% if((obj.AiuInfo[pidx].fnNativeInterface != 'CHI-A')&&(obj.AiuInfo[pidx].fnNativeInterface != 'CHI-B')&&(obj.AiuInfo[pidx].fnNativeInterface != 'CHI-E')) { %>
       ioaiu_en[<%=ioaiu_idx%>] = 1;
       <% ioaiu_idx++; } %>
    <% } %>
    end
    else begin
       parse_str(ioaiu_en_str, "n", ioaiu_en_arg);
       foreach (ioaiu_en_str[i]) begin
	  ioaiu_en[ioaiu_en_str[i].atoi()] = 1;
       end
    end

    foreach(chiaiu_en[i]) begin
      t_chiaiu_en[i]= chiaiu_en[i];
       `uvm_info("IOSUBSYS_TEST_SNPS", $sformatf("chiaiu_en[%0d] = %0d", i, chiaiu_en[i]), UVM_MEDIUM)
    end
    foreach(ioaiu_en[i]) begin
      t_ioaiu_en[i]= ioaiu_en[i];
       `uvm_info("IOSUBSYS_TEST_SNPS", $sformatf("ioaiu_en[%0d] = %0d", i, ioaiu_en[i]), UVM_MEDIUM)
    end

    if(!$value$plusargs("chiaiu_qos=%s", chiaiu_qos_arg)) begin
       chiaiu_user_qos = 0;
    <% chiaiu_idx=0; for(pidx = 0 ; pidx < obj.nAIUs; pidx++) { %>
    <% if((obj.AiuInfo[pidx].fnNativeInterface == 'CHI-A')||(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-B')||(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-E')) { %>
       chiaiu_qos[<%=chiaiu_idx%>] = 0;
       <% chiaiu_idx++; } %>
    <% } %>
    end
    else begin
       chiaiu_user_qos = 1;
       parse_str(chiaiu_qos_str, "n", chiaiu_qos_arg);
       foreach (chiaiu_qos_str[i]) begin
	  chiaiu_qos[i] = chiaiu_qos_str[i].atoi();
       end
    end

    if(!$value$plusargs("ioaiu_qos=%s", ioaiu_qos_arg)) begin
       ioaiu_user_qos = 0;
    <% ioaiu_idx=0; for(pidx = 0 ; pidx < obj.nAIUs; pidx++) { %>
    <% if((obj.AiuInfo[pidx].fnNativeInterface != 'CHI-A')&&(obj.AiuInfo[pidx].fnNativeInterface != 'CHI-B')&&(obj.AiuInfo[pidx].fnNativeInterface != 'CHI-E')) { %>
       ioaiu_qos[<%=ioaiu_idx%>] = 0;
       <% ioaiu_idx++; } %>
    <% } %>
    end
    else begin
       ioaiu_user_qos = 1;
       parse_str(ioaiu_qos_str, "n", ioaiu_qos_arg);
       foreach (ioaiu_qos_str[i]) begin
	  ioaiu_qos[i] = ioaiu_qos_str[i].atoi();
       end
    end
    //if($test$plusargs("dmiusmc_policy_chiaiu_test")) begin
    //  std::randomize(dmiusmc_policy_rand) with {dmiusmc_policy_rand dist { 1:=0, 2:=50, 4:=50, 8:=0, 16:=0};};// RdAllocDisable, WrAllocDisable have a direct tests
    //end
    if (m_concerto_env_cfg.has_chi_vip_snps) begin:_setup_chi_vip_seq // TODO MOVE IN VIRTUAL SEQ
<%let midx=0%>
<% if(numChiAiu > 0) { %>
    m_svt_chi_item = svt_chi_item::type_id::create("m_svt_chi_item");
<% } %>
    <% qidx=0;idx=0; for(pidx = 0; pidx < obj.nAIUs; pidx++) { %>
    <% if((obj.AiuInfo[pidx].fnNativeInterface == 'CHI-A')||(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-B' || obj.AiuInfo[pidx].fnNativeInterface == 'CHI-E')) { %>
       // m_snps_chi<%=idx%>_vseq = chiaiu<%=idx%>_chi_aiu_vseq_pkg::snps_chi_aiu_vseq#(<%=obj.AiuInfo[pidx].FUnitId%>)::type_id::create("m_chi<%=idx%>_seq");
       // m_snps_chi<%=idx%>_vseq.set_seq_name("m_chi<%=idx%>_seq");
       // m_snps_chi<%=idx%>_vseq.set_done_event_name("done_svt_chi_rn_seq_h<%=idx%>");
       // m_snps_chi<%=idx%>_vseq.rn_xact_seqr    =  m_concerto_env.snps.svt.amba_system_env.chi_system[0].rn[<%=idx%>].rn_xact_seqr;  
       // m_snps_chi<%=idx%>_vseq.shared_status =  m_concerto_env.snps.svt.amba_system_env.chi_system[0].rn[<%=idx%>].shared_status;  
       // m_snps_chi<%=idx%>_vseq.chi_num_trans =  chi_num_trans;  
       // m_snps_chi<%=idx%>_vseq.m_regs = m_concerto_env.m_regs;
        <% idx++;  %>
   <%} %>
   <%} %>
    end:_setup_chi_vip_seq 
   
    if (m_concerto_env_cfg.has_axi_vip_snps) begin:_setup_axi_vip_seq // TODO MOVE IN VIRTUAL SEQ
    <% qidx=0; for(pidx = 0; pidx < obj.nAIUs; pidx++) { %>
    <% if(!(obj.AiuInfo[pidx].fnNativeInterface.match("CHI"))) { %>
    <% for(let i=0; i<aiu_NumCores[pidx]; i++) { %> 
      cust_seq_h<%=qidx%>[<%=i%>] = ioaiu<%=qidx%>_env_pkg::snps_axi_master_pipelined_seq::type_id::create("cust_seq_h<%=qidx%>_seq");
      cust_seq_h<%=qidx%>[<%=i%>].set_seq_name("cust_seq_h<%=qidx%>_seq");
      cust_seq_h<%=qidx%>[<%=i%>].m_ace_cache_model      = m_concerto_env.inhouse.m_ace_cache_model_ioaiu<%=qidx%>[<%=i%>];
      cust_seq_h<%=qidx%>[<%=i%>].k_directed_test        = k_directed_test;
      cust_seq_h<%=qidx%>[<%=i%>].master_idx        = <%=midx%>;
      cust_seq_h<%=qidx%>[<%=i%>].m_axi_seqr        = m_concerto_env.snps.svt.amba_system_env.axi_system[0].master[<%=midx%>].sequencer;
    <% midx++; } %>
   <% qidx++; } %>
    <%} %>
    end:_setup_axi_vip_seq 

    if (!m_concerto_env_cfg.has_chi_vip_snps) begin:_setup_chi_inhouse_seq // TODO MOVE IN VIRTUAL SEQ
// BEGIN setup MASTER_SEQ
  <% idx=0; for(pidx = 0; pidx < obj.nAIUs; pidx++) { %>
    <% if(obj.AiuInfo[pidx].fnNativeInterface.match("CHI")) { %>
    m_chi<%=idx%>_vseq = chiaiu<%=idx%>_chi_aiu_vseq_pkg::chi_aiu_vseq#(<%=obj.AiuInfo[pidx].FUnitId%>)::type_id::create("m_chi<%=idx%>_seq");
    m_chi<%=idx%>_read_vseq = chiaiu<%=idx%>_chi_aiu_vseq_pkg::chi_aiu_vseq#(<%=obj.AiuInfo[pidx].FUnitId%>)::type_id::create("m_chi<%=idx%>_read_seq"); // read

    m_chi<%=idx%>_vseq.set_seq_name("m_chi<%=idx%>_seq");
    m_chi<%=idx%>_read_vseq.set_seq_name("m_chi<%=idx%>_read_seq"); // read
    m_chi<%=idx%>_vseq.m_chi_container = m_concerto_env.inhouse.m_chi<%=idx%>_container;
    m_chi<%=idx%>_read_vseq.m_chi_container = m_concerto_env.inhouse.m_chi<%=idx%>_container;
    m_chi<%=idx%>_vseq.m_regs = m_concerto_env.m_regs;
    m_chi<%=idx%>_read_vseq.m_regs = m_concerto_env.m_regs;
    
    m_chi<%=idx%>_vseq.wt_chi_data_flit_data_err                           =  m_args.aiu<%=pidx%>_wt_chi_data_flit_data_err;
    m_chi<%=idx%>_vseq.wt_chi_data_flit_non_data_err                       =  m_args.aiu<%=pidx%>_wt_chi_data_flit_non_data_err;
    m_chi<%=idx%>_vseq.m_chi_container.k_snp_rsp_data_err_wgt              =  m_args.aiu<%=pidx%>_k_snp_rsp_data_err_wgt;
    m_chi<%=idx%>_vseq.m_chi_container.k_snp_rsp_non_data_err_wgt          =  m_args.aiu<%=pidx%>_k_snp_rsp_non_data_err_wgt;
    m_concerto_env_cfg.m_chiaiu<%=idx%>_env_cfg.k_snp_rsp_non_data_err_wgt =  m_args.aiu<%=pidx%>_k_snp_rsp_non_data_err_wgt; 

    foreach(chiaiu_en[i]) begin
      m_chi<%=idx%>_vseq.t_chiaiu_en[i]= chiaiu_en[i];
    end
    foreach(ioaiu_en[i]) begin
      m_chi<%=idx%>_vseq.t_ioaiu_en[i]= ioaiu_en[i];
    end

    m_chi<%=idx%>_vseq.m_rn_tx_req_chnl_seqr      = m_concerto_env.inhouse.m_chiaiu<%=idx%>_env.m_chi_agent.m_rn_tx_req_chnl_seqr;
    m_chi<%=idx%>_vseq.m_rn_tx_dat_chnl_seqr      = m_concerto_env.inhouse.m_chiaiu<%=idx%>_env.m_chi_agent.m_rn_tx_dat_chnl_seqr;
    m_chi<%=idx%>_vseq.m_rn_tx_rsp_chnl_seqr      = m_concerto_env.inhouse.m_chiaiu<%=idx%>_env.m_chi_agent.m_rn_tx_rsp_chnl_seqr;
    m_chi<%=idx%>_vseq.m_rn_rx_rsp_chnl_seqr      = m_concerto_env.inhouse.m_chiaiu<%=idx%>_env.m_chi_agent.m_rn_rx_rsp_chnl_seqr;
    m_chi<%=idx%>_vseq.m_rn_rx_dat_chnl_seqr      = m_concerto_env.inhouse.m_chiaiu<%=idx%>_env.m_chi_agent.m_rn_rx_dat_chnl_seqr;
    m_chi<%=idx%>_vseq.m_rn_rx_snp_chnl_seqr      = m_concerto_env.inhouse.m_chiaiu<%=idx%>_env.m_chi_agent.m_rn_rx_snp_chnl_seqr;
    m_chi<%=idx%>_vseq.m_lnk_hske_seqr            = m_concerto_env.inhouse.m_chiaiu<%=idx%>_env.m_chi_agent.m_lnk_hske_seqr;
    m_chi<%=idx%>_vseq.m_txs_actv_seqr            = m_concerto_env.inhouse.m_chiaiu<%=idx%>_env.m_chi_agent.m_txs_actv_seqr;
    m_chi<%=idx%>_vseq.m_sysco_seqr               = m_concerto_env.inhouse.m_chiaiu<%=idx%>_env.m_chi_agent.m_sysco_seqr;
    m_chi<%=idx%>_vseq.k_directed_test            = k_directed_test;

    // read
    m_chi<%=idx%>_read_vseq.m_rn_tx_req_chnl_seqr      = m_concerto_env.inhouse.m_chiaiu<%=idx%>_env.m_chi_agent.m_rn_tx_req_chnl_seqr;
    m_chi<%=idx%>_read_vseq.m_rn_tx_dat_chnl_seqr      = m_concerto_env.inhouse.m_chiaiu<%=idx%>_env.m_chi_agent.m_rn_tx_dat_chnl_seqr;
    m_chi<%=idx%>_read_vseq.m_rn_tx_rsp_chnl_seqr      = m_concerto_env.inhouse.m_chiaiu<%=idx%>_env.m_chi_agent.m_rn_tx_rsp_chnl_seqr;
    m_chi<%=idx%>_read_vseq.m_rn_rx_rsp_chnl_seqr      = m_concerto_env.inhouse.m_chiaiu<%=idx%>_env.m_chi_agent.m_rn_rx_rsp_chnl_seqr;
    m_chi<%=idx%>_read_vseq.m_rn_rx_dat_chnl_seqr      = m_concerto_env.inhouse.m_chiaiu<%=idx%>_env.m_chi_agent.m_rn_rx_dat_chnl_seqr;
    m_chi<%=idx%>_read_vseq.m_rn_rx_snp_chnl_seqr      = m_concerto_env.inhouse.m_chiaiu<%=idx%>_env.m_chi_agent.m_rn_rx_snp_chnl_seqr;
    m_chi<%=idx%>_read_vseq.m_lnk_hske_seqr            = m_concerto_env.inhouse.m_chiaiu<%=idx%>_env.m_chi_agent.m_lnk_hske_seqr;
    m_chi<%=idx%>_read_vseq.m_txs_actv_seqr            = m_concerto_env.inhouse.m_chiaiu<%=idx%>_env.m_chi_agent.m_txs_actv_seqr;
    m_chi<%=idx%>_read_vseq.m_sysco_seqr               = m_concerto_env.inhouse.m_chiaiu<%=idx%>_env.m_chi_agent.m_sysco_seqr;
    m_chi<%=idx%>_read_vseq.k_directed_test            = k_directed_test;

    m_chi<%=idx%>_args = chi_aiu_unit_args_pkg::chi_aiu_unit_args::type_id::create("chi_aiu_unit_args<%=idx%>");
    m_chi<%=idx%>_args.k_num_requests.set_value(chi_num_trans);
    m_chi<%=idx%>_args.k_coh_addr_pct.set_value(50);
    m_chi<%=idx%>_args.k_noncoh_addr_pct.set_value(50);
    m_chi<%=idx%>_args.k_device_type_mem_pct.set_value(50);
    m_chi<%=idx%>_args.k_new_addr_pct.set_value(50);
    m_chi<%=idx%>_vseq.set_unit_args(m_chi<%=idx%>_args);

    // read
     m_chi<%=idx%>_read_args = chi_aiu_unit_args_pkg::chi_aiu_unit_args::type_id::create($psprintf("chi_aiu_unit_read_args[%0d]", 0));
     m_chi<%=idx%>_read_args.k_num_requests.set_value(chi_num_trans);
     m_chi<%=idx%>_read_args.k_coh_addr_pct.set_value(50);
     m_chi<%=idx%>_read_args.k_noncoh_addr_pct.set_value(50);
     m_chi<%=idx%>_read_args.k_device_type_mem_pct.set_value(50);
     m_chi<%=idx%>_read_args.k_new_addr_pct.set_value(50);
     m_chi<%=idx%>_read_vseq.set_unit_args(m_chi<%=idx%>_read_args);


    // set randomize args after boot seq
    if(($test$plusargs("k_coh_addr_pct"))) begin
      $value$plusargs("k_coh_addr_pct=%0d",plusarg_int);
      m_chi<%=idx%>_args.k_coh_addr_pct.set_value(plusarg_int);
    end else begin
        m_chi<%=idx%>_args.k_coh_addr_pct.set_value(50);
    end

    if(($test$plusargs("k_noncoh_addr_pct"))) begin
      $value$plusargs("k_noncoh_addr_pct=%0d",plusarg_int);
      m_chi<%=idx%>_args.k_noncoh_addr_pct.set_value(plusarg_int);
    end else begin
        m_chi<%=idx%>_args.k_noncoh_addr_pct.set_value(50);
    end
    
    if(ncoreConfigInfo::NUM_DIIS>1) begin
      if(($test$plusargs("k_device_type_mem_pct"))) begin
        $value$plusargs("k_device_type_mem_pct=%0d",plusarg_int);
        m_chi<%=idx%>_args.k_device_type_mem_pct.set_value(plusarg_int);
      end else begin
          m_chi<%=idx%>_args.k_device_type_mem_pct.set_value(50);
      end
    end else begin
       m_chi<%=idx%>_args.k_device_type_mem_pct.set_value(0);
    end
    
    if ($test$plusargs("read_test")) begin
        m_chi<%=idx%>_args.k_wr_noncoh_pct.set_value(0);
        m_chi<%=idx%>_args.k_wr_cohunq_pct.set_value(0);
        m_chi<%=idx%>_args.k_wr_cpybck_pct.set_value(0);
        m_chi<%=idx%>_args.k_dt_ls_upd_pct.set_value(0);
        m_chi<%=idx%>_args.k_dt_ls_cmo_pct.set_value(0);
        m_chi<%=idx%>_args.k_pre_fetch_pct.set_value(0);
        m_chi<%=idx%>_args.k_dt_ls_sth_pct.set_value(0);
        m_chi<%=idx%>_args.k_wr_sthunq_pct.set_value(0);
        m_chi<%=idx%>_args.k_atomic_st_pct.set_value(0);
        m_chi<%=idx%>_args.k_atomic_ld_pct.set_value(0);
        m_chi<%=idx%>_args.k_atomic_sw_pct.set_value(0);
        m_chi<%=idx%>_args.k_atomic_cm_pct.set_value(0);
        m_chi<%=idx%>_args.k_dvm_opert_pct.set_value(0);
        if($test$plusargs("noncoherent_test")) begin
           m_chi<%=idx%>_args.k_coh_addr_pct.set_value(0);
           m_chi<%=idx%>_args.k_noncoh_addr_pct.set_value(100);
           m_chi<%=idx%>_args.k_rd_noncoh_pct.set_value(100);
           m_chi<%=idx%>_args.k_rd_ldrstr_pct.set_value(0);
           m_chi<%=idx%>_args.k_rd_rdonce_pct.set_value(0);
        end
        else if($test$plusargs("coherent_test")) begin
           m_chi<%=idx%>_args.k_coh_addr_pct.set_value(100);
           m_chi<%=idx%>_args.k_noncoh_addr_pct.set_value(0);
           m_chi<%=idx%>_args.k_rd_noncoh_pct.set_value(0);
           m_chi<%=idx%>_args.k_rd_ldrstr_pct.set_value(100);
           m_chi<%=idx%>_args.k_rd_rdonce_pct.set_value(0);
        end
        else begin
           m_chi<%=idx%>_args.k_rd_noncoh_pct.set_value(35);
           m_chi<%=idx%>_args.k_rd_ldrstr_pct.set_value(35);
           m_chi<%=idx%>_args.k_rd_rdonce_pct.set_value(30);
        end
    end
    else if ($test$plusargs("write_test")) begin
        m_chi<%=idx%>_args.k_rd_noncoh_pct.set_value(0);
        m_chi<%=idx%>_args.k_rd_ldrstr_pct.set_value(0);
        m_chi<%=idx%>_args.k_rd_rdonce_pct.set_value(0);
        m_chi<%=idx%>_args.k_wr_cpybck_pct.set_value(0);
        m_chi<%=idx%>_args.k_dt_ls_upd_pct.set_value(0);
        m_chi<%=idx%>_args.k_dt_ls_cmo_pct.set_value(0);
        m_chi<%=idx%>_args.k_pre_fetch_pct.set_value(0);
        m_chi<%=idx%>_args.k_dt_ls_sth_pct.set_value(0);
        m_chi<%=idx%>_args.k_wr_sthunq_pct.set_value(0);
        m_chi<%=idx%>_args.k_atomic_st_pct.set_value(0);
        m_chi<%=idx%>_args.k_atomic_ld_pct.set_value(0);
        m_chi<%=idx%>_args.k_atomic_sw_pct.set_value(0);
        m_chi<%=idx%>_args.k_atomic_cm_pct.set_value(0);
        m_chi<%=idx%>_args.k_dvm_opert_pct.set_value(0);
        if($test$plusargs("noncoherent_test")) begin
           m_chi<%=idx%>_args.k_coh_addr_pct.set_value(0);
           m_chi<%=idx%>_args.k_noncoh_addr_pct.set_value(100);
           m_chi<%=idx%>_args.k_wr_noncoh_pct.set_value(100);
           m_chi<%=idx%>_args.k_wr_cohunq_pct.set_value(0);
        end
        else if($test$plusargs("coherent_test")) begin
           m_chi<%=idx%>_args.k_coh_addr_pct.set_value(100);
           m_chi<%=idx%>_args.k_noncoh_addr_pct.set_value(0);
           m_chi<%=idx%>_args.k_wr_noncoh_pct.set_value(0);
           m_chi<%=idx%>_args.k_wr_cohunq_pct.set_value(100);
        end
        else begin
           m_chi<%=idx%>_args.k_wr_noncoh_pct.set_value(100);
           m_chi<%=idx%>_args.k_wr_cohunq_pct.set_value(100);
        end
    end
    else begin
        if($test$plusargs("noncoherent_test")) begin
            m_chi<%=idx%>_args.k_rd_noncoh_pct.set_value(100);
            m_chi<%=idx%>_args.k_rd_ldrstr_pct.set_value(0);
            m_chi<%=idx%>_args.k_rd_rdonce_pct.set_value(0);
            m_chi<%=idx%>_args.k_dt_ls_upd_pct.set_value(0);
            m_chi<%=idx%>_args.k_dt_ls_cmo_pct.set_value(0);
            m_chi<%=idx%>_args.k_dt_ls_sth_pct.set_value(0);
            m_chi<%=idx%>_args.k_wr_noncoh_pct.set_value(100);
            m_chi<%=idx%>_args.k_wr_cohunq_pct.set_value(0);
            m_chi<%=idx%>_args.k_wr_cpybck_pct.set_value(0);
            m_chi<%=idx%>_args.k_dvm_opert_pct.set_value(0);
            m_chi<%=idx%>_args.k_pre_fetch_pct.set_value(0);
            m_chi<%=idx%>_args.k_unsupported_txn_pct.set_value(0);
        end
        else if($test$plusargs("coherent_test")) begin
            m_chi<%=idx%>_args.k_coh_addr_pct.set_value(100);
            m_chi<%=idx%>_args.k_noncoh_addr_pct.set_value(0);
            m_chi<%=idx%>_args.k_rd_noncoh_pct.set_value(0);
            m_chi<%=idx%>_args.k_rd_ldrstr_pct.set_value(100);
            m_chi<%=idx%>_args.k_rd_rdonce_pct.set_value(100);
            m_chi<%=idx%>_args.k_wr_noncoh_pct.set_value(0);
            m_chi<%=idx%>_args.k_wr_cohunq_pct.set_value(100);
            if($test$plusargs("en_excl_txn"))begin
                m_chi<%=idx%>_args.k_rd_ldrstr_pct.set_value(100);
                m_chi<%=idx%>_args.k_rd_rdonce_pct.set_value(0);
                m_chi<%=idx%>_args.k_wr_cohunq_pct.set_value(0);
                m_chi<%=idx%>_args.k_dt_ls_upd_pct.set_value(100);
            end
        end
        else begin
             if($test$plusargs("chi_coh_dii")) begin
              m_chi<%=idx%>_args.k_rq_lcrdrt_pct.set_value(100); 
              m_chi<%=idx%>_args.k_rd_rdonce_pct.set_value(100);
            end               
            if(($test$plusargs("dce_fix_index"))||($test$plusargs("dmi_fix_index"))||($test$plusargs("en_excl_txn")))begin
               m_chi<%=idx%>_args.k_rd_ldrstr_pct.set_value(100);
               m_chi<%=idx%>_args.k_rd_rdonce_pct.set_value(0);
            end else begin
               m_chi<%=idx%>_args.k_rd_ldrstr_pct.set_value(100);
               m_chi<%=idx%>_args.k_rd_rdonce_pct.set_value(100);
            end
            if($test$plusargs("en_excl_txn"))begin
              m_chi<%=idx%>_args.k_rd_noncoh_pct.set_value(0);
              m_chi<%=idx%>_args.k_wr_noncoh_pct.set_value(0);
              m_chi<%=idx%>_args.k_wr_cohunq_pct.set_value(0);
            end else begin
              m_chi<%=idx%>_args.k_rd_noncoh_pct.set_value(100);
              m_chi<%=idx%>_args.k_wr_noncoh_pct.set_value(100);
              m_chi<%=idx%>_args.k_wr_cohunq_pct.set_value(100);
            end

                if ($test$plusargs("en_excl_noncoh_txn")) begin
                      m_chi<%=idx%>_args.k_excl_txn_pct.set_value(100);
                      m_chi<%=idx%>_args.k_coh_addr_pct.set_value(0);
                      m_chi<%=idx%>_args.k_noncoh_addr_pct.set_value(100);
                      m_chi<%=idx%>_args.k_device_type_mem_pct.set_value(0);
                      m_chi<%=idx%>_args.k_rd_noncoh_pct.set_value(100);
                      m_chi<%=idx%>_args.k_wr_noncoh_pct.set_value(100);
                      m_chi<%=idx%>_args.k_rd_ldrstr_pct.set_value(0);
                      m_chi<%=idx%>_args.k_rd_rdonce_pct.set_value(0);
                      m_chi<%=idx%>_args.k_wr_cohunq_pct.set_value(0);
                      m_chi<%=idx%>_args.k_dt_ls_upd_pct.set_value(0);
                end else begin
                    m_chi<%=idx%>_args.k_rd_noncoh_pct.set_value(100);
                    m_chi<%=idx%>_args.k_wr_noncoh_pct.set_value(100);
                    m_chi<%=idx%>_args.k_wr_cohunq_pct.set_value(100);
                end

        end
	    end // else: !if($test$plusargs("write_test"))

                if ($test$plusargs("use_copyback")) begin
                    m_chi<%=idx%>_args.k_wr_cpybck_pct.set_value(100);
                end else begin
                    m_chi<%=idx%>_args.k_wr_cpybck_pct.set_value(0);
                end

                if ($test$plusargs("use_nondata")) begin
                    m_chi<%=idx%>_args.k_dt_ls_upd_pct.set_value(100);
                    m_chi<%=idx%>_args.k_dt_ls_cmo_pct.set_value(100);
                    m_chi<%=idx%>_args.k_pre_fetch_pct.set_value(20);
                end else begin
                    if($test$plusargs("en_excl_txn"))begin
                      m_chi<%=idx%>_args.k_dt_ls_upd_pct.set_value(100);
                    end else begin
                      m_chi<%=idx%>_args.k_dt_ls_upd_pct.set_value(0);
                    end
                    m_chi<%=idx%>_args.k_dt_ls_cmo_pct.set_value(0);
                    m_chi<%=idx%>_args.k_pre_fetch_pct.set_value(0);
                end
                if ($test$plusargs("use_stash")) begin
                    m_chi<%=idx%>_args.k_dt_ls_sth_pct.set_value(101);
                    m_chi<%=idx%>_args.k_wr_sthunq_pct.set_value(0);  // CHI-AIU does not support WriteStash
                end else begin
                    m_chi<%=idx%>_args.k_dt_ls_sth_pct.set_value(0);
                    m_chi<%=idx%>_args.k_wr_sthunq_pct.set_value(0);
                end
                if ($test$plusargs("use_atomic")) begin
                    m_chi<%=idx%>_args.k_atomic_st_pct.set_value(100);
                    m_chi<%=idx%>_args.k_atomic_ld_pct.set_value(100);
                    m_chi<%=idx%>_args.k_atomic_sw_pct.set_value(20);
                    m_chi<%=idx%>_args.k_atomic_cm_pct.set_value(20);
                end else begin
                    m_chi<%=idx%>_args.k_atomic_st_pct.set_value(0);
                    m_chi<%=idx%>_args.k_atomic_ld_pct.set_value(0);
                    m_chi<%=idx%>_args.k_atomic_sw_pct.set_value(0);
                    m_chi<%=idx%>_args.k_atomic_cm_pct.set_value(0);
                end // else: !if($test$plusargs("use_atomic"))
                if ($test$plusargs("chi_wr_dat_cancel_pct")) begin
                  if ($value$plusargs("chi_wr_dat_cancel_pct=%d",plusarg_int)) begin
                    m_chi<%=idx%>_args.k_writedatacancel_pct.set_value(plusarg_int);
                  end else begin
                    m_chi<%=idx%>_args.k_writedatacancel_pct.set_value(50);
                  end
                end 
                if ($test$plusargs("use_dvm") && !($test$plusargs("use_ace_dvmsync"))) begin
                    m_chi<%=idx%>_args.k_dvm_opert_pct.set_value(25);
                end else begin
                    m_chi<%=idx%>_args.k_dvm_opert_pct.set_value(0);
                end
                if ($test$plusargs("en_excl_txn")/* || $test$plusargs("en_excl_noncoh_txn")*/) begin
                   m_chi<%=idx%>_args.k_excl_txn_pct.set_value(100);
                end

	    if($test$plusargs("perf_test")||$test$plusargs("no_delay")) begin
               m_chi<%=idx%>_args.k_txreq_hld_dly.set_value(1);
               m_chi<%=idx%>_args.k_txreq_dly_min.set_value(0);
               m_chi<%=idx%>_args.k_txreq_dly_max.set_value(0);
               m_chi<%=idx%>_args.k_txrsp_hld_dly.set_value(1);
               m_chi<%=idx%>_args.k_txrsp_dly_min.set_value(0);
               m_chi<%=idx%>_args.k_txrsp_dly_max.set_value(0);
               m_chi<%=idx%>_args.k_txdat_hld_dly.set_value(1);
               m_chi<%=idx%>_args.k_txdat_dly_min.set_value(0);
               m_chi<%=idx%>_args.k_txdat_dly_max.set_value(0);
               m_chi<%=idx%>_args.k_alloc_hint_pct.set_value(90);
               m_chi<%=idx%>_args.k_cacheable_pct.set_value(90);
	       m_chi<%=idx%>_args.k_on_fly_req.set_value(32);
	    end
            m_chi<%=idx%>_vseq.set_unit_args(m_chi<%=idx%>_args);
            if(chiaiu_user_qos == 1) begin
	        m_chi<%=idx%>_vseq.user_qos = 1;
	        m_chi<%=idx%>_vseq.aiu_qos  = chiaiu_qos[<%=idx%>];
            end
            if($test$plusargs("directed_dtwmrg_test")) begin
              if($test$plusargs("chi<%=idx%>_clnunique")) begin
              m_chi<%=idx%>_args.k_dt_ls_upd_pct.set_value(100);
              m_chi<%=idx%>_args.k_rd_rdonce_pct.set_value(0);
              m_chi<%=idx%>_args.k_rd_ldrstr_pct.set_value(0);
              end else begin
              m_chi<%=idx%>_args.k_rd_rdonce_pct.set_value(100);
              m_chi<%=idx%>_args.k_rd_ldrstr_pct.set_value(100);
              m_chi<%=idx%>_args.k_dt_ls_upd_pct.set_value(0);
              end
              m_chi<%=idx%>_args.k_dt_ls_cmo_pct.set_value(0);
              m_chi<%=idx%>_args.k_wr_cohunq_pct.set_value(0);
              m_chi<%=idx%>_args.k_wr_cpybck_pct.set_value(0);
              m_chi<%=idx%>_args.k_dt_ls_sth_pct.set_value(0);
              m_chi<%=idx%>_args.k_atomic_st_pct.set_value(0);
              m_chi<%=idx%>_args.k_atomic_ld_pct.set_value(0);
              m_chi<%=idx%>_args.k_atomic_sw_pct.set_value(0);
              m_chi<%=idx%>_args.k_atomic_cm_pct.set_value(0);
              m_chi<%=idx%>_args.k_pre_fetch_pct.set_value(0);
              m_chi<%=idx%>_args.k_dvm_opert_pct.set_value(0);
              m_chi<%=idx%>_args.k_rq_lcrdrt_pct.set_value(0);
              m_chi<%=idx%>_args.k_unsupported_txn_pct.set_value(0);
              m_chi<%=idx%>_args.k_coh_addr_pct.set_value(100);
              m_chi<%=idx%>_args.k_noncoh_addr_pct.set_value(0);
            end
      <% idx++;  %>
    <%} %>
    <%} %>
    end:_setup_chi_inhouse_seq // TODO MOVE IN VIRTUAL SEQ

if (m_concerto_env_cfg.has_chi_vip_snps) begin // TODO MOVE IN VIRTUAL SEQ
<% if(numChiAiu > 0) { %>
    //m_snps_chi<%=idx%>_vseq.set_unit_args(m_chi0_args); //???
<%} %>
end
    
    if (!m_concerto_env_cfg.has_axi_vip_snps) begin:_setup_axi_inhouse_seq // TODO MOVE IN VIRTUAL SEQ
         <% qidx=0; for(pidx = 0; pidx < obj.nAIUs; pidx++) { %>
         <% if(!(obj.AiuInfo[pidx].fnNativeInterface.match("CHI"))) { %>
         <% for(let i=0; i<aiu_NumCores[pidx]; i++) { %> 
         m_iocache_seq<%=qidx%>[<%=i%>]                        = ioaiu<%=qidx%>_inhouse_axi_bfm_pkg::axi_master_pipelined_seq::type_id::create("m_ioaiu<%=qidx%>_seq");
         m_iocache_seq<%=qidx%>[<%=i%>].core_id = <%=i%>;
         m_iocache_seq<%=qidx%>[<%=i%>].set_seq_name("m_ioaiu<%=qidx%>_seq[<%=i%>]");
         m_iocache_seq<%=qidx%>[<%=i%>].m_read_addr_chnl_seqr  = m_concerto_env.inhouse.m_ioaiu<%=qidx%>_env.m_env[<%=i%>].m_axi_master_agent.m_read_addr_chnl_seqr;
         m_iocache_seq<%=qidx%>[<%=i%>].m_read_data_chnl_seqr  = m_concerto_env.inhouse.m_ioaiu<%=qidx%>_env.m_env[<%=i%>].m_axi_master_agent.m_read_data_chnl_seqr;
         m_iocache_seq<%=qidx%>[<%=i%>].m_write_addr_chnl_seqr = m_concerto_env.inhouse.m_ioaiu<%=qidx%>_env.m_env[<%=i%>].m_axi_master_agent.m_write_addr_chnl_seqr;
         m_iocache_seq<%=qidx%>[<%=i%>].m_write_data_chnl_seqr = m_concerto_env.inhouse.m_ioaiu<%=qidx%>_env.m_env[<%=i%>].m_axi_master_agent.m_write_data_chnl_seqr;
         m_iocache_seq<%=qidx%>[<%=i%>].m_write_resp_chnl_seqr = m_concerto_env.inhouse.m_ioaiu<%=qidx%>_env.m_env[<%=i%>].m_axi_master_agent.m_write_resp_chnl_seqr;
         m_iocache_seq<%=qidx%>[<%=i%>].m_ace_cache_model      = m_concerto_env.inhouse.m_ace_cache_model_ioaiu<%=qidx%>[<%=i%>];
         m_iocache_seq<%=qidx%>[<%=i%>].k_directed_test        = k_directed_test;

         // read
         // if (k_directed_test_same_aiu) begin
             m_iocache_read_seq<%=qidx%>[<%=i%>]                        = ioaiu<%=qidx%>_inhouse_axi_bfm_pkg::axi_master_pipelined_seq::type_id::create("m_ioaiu<%=qidx%>_read_seq");
             m_iocache_read_seq<%=qidx%>[<%=i%>].core_id = <%=i%> ;
             m_iocache_read_seq<%=qidx%>[<%=i%>].set_seq_name("m_ioaiu<%=qidx%>_read_seq[<%=i%>]");
             m_iocache_read_seq<%=qidx%>[<%=i%>].m_read_addr_chnl_seqr  = m_concerto_env.inhouse.m_ioaiu<%=qidx%>_env.m_env[<%=i%>].m_axi_master_agent.m_read_addr_chnl_seqr;
             m_iocache_read_seq<%=qidx%>[<%=i%>].m_read_data_chnl_seqr  = m_concerto_env.inhouse.m_ioaiu<%=qidx%>_env.m_env[<%=i%>].m_axi_master_agent.m_read_data_chnl_seqr;
             m_iocache_read_seq<%=qidx%>[<%=i%>].m_write_addr_chnl_seqr = m_concerto_env.inhouse.m_ioaiu<%=qidx%>_env.m_env[<%=i%>].m_axi_master_agent.m_write_addr_chnl_seqr;
             m_iocache_read_seq<%=qidx%>[<%=i%>].m_write_data_chnl_seqr = m_concerto_env.inhouse.m_ioaiu<%=qidx%>_env.m_env[<%=i%>].m_axi_master_agent.m_write_data_chnl_seqr;
             m_iocache_read_seq<%=qidx%>[<%=i%>].m_write_resp_chnl_seqr = m_concerto_env.inhouse.m_ioaiu<%=qidx%>_env.m_env[<%=i%>].m_axi_master_agent.m_write_resp_chnl_seqr;
             m_iocache_read_seq<%=qidx%>[<%=i%>].m_ace_cache_model      = m_concerto_env.inhouse.m_ace_cache_model_ioaiu<%=qidx%>[<%=i%>];
             m_iocache_read_seq<%=qidx%>[<%=i%>].k_directed_test        = k_directed_test;
         // end

           <% if((obj.AiuInfo[pidx].fnNativeInterface == 'ACE') || (aiu_axiInt[pidx].params.eAc==1) ){ %>
         m_iosnoop_seq<%=qidx%>[<%=i%>]                        = ioaiu<%=qidx%>_inhouse_axi_bfm_pkg::axi_master_snoop_seq::type_id::create("m_iosnoop<%=qidx%>_seq");
         m_iosnoop_seq<%=qidx%>[<%=i%>].m_read_addr_chnl_seqr   = m_concerto_env.inhouse.m_ioaiu<%=qidx%>_env.m_env[<%=i%>].m_axi_master_agent.m_read_addr_chnl_seqr;
         m_iosnoop_seq<%=qidx%>[<%=i%>].m_read_data_chnl_seqr   = m_concerto_env.inhouse.m_ioaiu<%=qidx%>_env.m_env[<%=i%>].m_axi_master_agent.m_read_data_chnl_seqr;
         m_iosnoop_seq<%=qidx%>[<%=i%>].m_snoop_addr_chnl_seqr  = m_concerto_env.inhouse.m_ioaiu<%=qidx%>_env.m_env[<%=i%>].m_axi_master_agent.m_snoop_addr_chnl_seqr;
         m_iosnoop_seq<%=qidx%>[<%=i%>].m_snoop_data_chnl_seqr  = m_concerto_env.inhouse.m_ioaiu<%=qidx%>_env.m_env[<%=i%>].m_axi_master_agent.m_snoop_data_chnl_seqr;
         m_iosnoop_seq<%=qidx%>[<%=i%>].m_snoop_resp_chnl_seqr  = m_concerto_env.inhouse.m_ioaiu<%=qidx%>_env.m_env[<%=i%>].m_axi_master_agent.m_snoop_resp_chnl_seqr;
         m_iosnoop_seq<%=qidx%>[<%=i%>].m_ace_cache_model       = m_concerto_env.inhouse.m_ace_cache_model_ioaiu<%=qidx%>[<%=i%>];

           <%}%>

         if ($test$plusargs("read_test") || (($test$plusargs("coherent_test"))  && ($test$plusargs("en_excl_txn")))) begin
                m_iocache_seq<%=qidx%>[<%=i%>].k_num_read_req      = ioaiu_num_trans;
                m_iocache_seq<%=qidx%>[<%=i%>].k_num_write_req     = 0;
            end else if ($test$plusargs("write_test")) begin
                m_iocache_seq<%=qidx%>[<%=i%>].k_num_read_req      = 0;
                m_iocache_seq<%=qidx%>[<%=i%>].k_num_write_req     = ioaiu_num_trans;
            end else begin
                m_iocache_seq<%=qidx%>[<%=i%>].k_num_read_req      = ioaiu_num_trans/2;
                m_iocache_seq<%=qidx%>[<%=i%>].k_num_write_req     = ioaiu_num_trans/2;
            end
		    if ($test$plusargs("fsys_force_sameaxid")) begin
               m_iocache_seq<%=qidx%>[<%=i%>].en_force_axid=1;  
               m_iocache_seq<%=qidx%>[<%=i%>].ioaiu_force_coh_axid=<%=qidx+1%>;  
               m_iocache_seq<%=qidx%>[<%=i%>].ioaiu_force_noncoh_axid[0]=<%=qidx+1%>;  
               m_iocache_seq<%=qidx%>[<%=i%>].ioaiu_force_noncoh_axid[1]=<%=qidx+1%>;  
            end
            if(ioaiu_user_qos == 1) begin
                m_iocache_seq<%=qidx%>[<%=i%>].user_qos       = 1;
                m_iocache_seq<%=qidx%>[<%=i%>].aiu_qos        = ioaiu_qos[<%=qidx%>];
            end
      <%if(obj.AiuInfo[pidx].fnNativeInterface == 'ACE-LITE' || obj.AiuInfo[pidx].fnNativeInterface == 'ACELITE-E' || obj.AiuInfo[pidx].fnNativeInterface == 'ACE' || obj.AiuInfo[pidx].fnNativeInterface == 'AXI4') { %>
            if ($test$plusargs("read_test")) begin
		<% if(obj.AiuInfo[pidx].fnNativeInterface == 'AXI4' && !obj.AiuInfo[pidx].useCache) { %>
                   m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_rdnosnp      = 100;
                   m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_rdonce       = 0;
                   m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_wrnosnp      = 0;
                   m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_wrunq        = 0;
                   m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_rdunq        = 0;
                   m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_clnunq       = 0;
                   m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_rdcln        = 0;
                   m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_rdshrd       = 0;
                <% } else { %>
                if($test$plusargs("noncoherent_test")) begin
                   m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_rdnosnp      = 100;
                   m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_rdonce       = 0;
                   m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_wrnosnp      = 0;
                   m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_wrunq        = 0;
                   m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_rdunq        = 0;
                   m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_clnunq       = 0;
                   m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_rdcln        = 0;
                   m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_rdshrd       = 0;
                   m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_rdnotshrddty = 0;
                end
                else if($test$plusargs("coherent_test")) begin
                   m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_rdnosnp      = 0;
                   m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_rdonce       = 100;
                   m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_wrnosnp      = 0;
                   m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_wrunq        = 0;
                end
                else begin
                   m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_rdnosnp      = 50;
                   m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_rdonce       = 50;
                   m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_wrnosnp      = 0;
                   m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_wrunq        = 0;
                end
            <% } %>
            end else if ($test$plusargs("write_test")) begin
		<% if(obj.AiuInfo[pidx].fnNativeInterface == 'AXI4' && !obj.AiuInfo[pidx].useCache) { %>
                   m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_rdnosnp      = 0;
                   m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_rdonce       = 0;
                   m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_wrnosnp      = 100;
                   m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_wrunq        = 0;
                   m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_wrlnunq      = 0;
                <% } else { %>
                if($test$plusargs("noncoherent_test")) begin
                   m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_rdnosnp      = 0;
                   m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_rdonce       = 0;
                   m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_wrnosnp      = 100;
                   m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_wrunq        = 0;
                   m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_wrlnunq      = 0;
                end
                else if($test$plusargs("coherent_test")) begin
                   m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_rdnosnp      = 0;
                   m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_rdonce       = 0;
                   m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_wrnosnp      = 0;
                   m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_wrunq        = 5;
                   m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_wrlnunq      = 0;
                end
                else begin
                   m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_rdnosnp      = 0;
                   m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_rdonce       = 0;
                   m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_wrnosnp      = 35;
                   m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_wrunq        = 35;
                   m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_wrlnunq      = <%=(obj.AiuInfo[pidx].fnNativeInterface != "AXI4")?30:0%>;
                end
            <% } %>
            end // if ($test$plusargs("write_test"))
            else begin
		<% if(obj.AiuInfo[pidx].fnNativeInterface == 'AXI4' && !obj.AiuInfo[pidx].useCache) { %>
                    m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_rdnosnp      = 100;
                    m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_rdonce       = 0;
                    m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_wrnosnp      = 100;
                    m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_wrunq        = 0;
                    m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_wrlnunq      = 0;
                    m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_wrcln        = 0;
                    m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_rdunq        = 0;
                    m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_clnunq       = 0;
                    m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_rdcln        = 0;
                    m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_rdshrd       = 0;
                <% } else { %>
                if($test$plusargs("noncoherent_test")) begin
                  <% if (obj.AiuInfo[pidx].fnNativeInterface != 'AXI4') { %>

                    m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_rdnosnp      = 100;
                    m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_rdonce       = 0;
                    m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_wrnosnp      = 100;
                    m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_wrunq        = 0;
                    m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_wrlnunq      = 0;
                    m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_wrcln        = 0;
                    m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_rdunq        = 0;
                    m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_clnunq       = 0;
                    m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_rdcln        = 0;
                    m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_rdshrd       = 0;
                    m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_rdnotshrddty = 0;                
                <% } else { %>
                    m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_rdnosnp      = 100;
                    m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_rdonce       = 0;
                    m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_wrnosnp      = 100;
                    m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_wrunq        = 0;
                    m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_wrlnunq      = 0;
                    m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_wrcln        = 0;
                    m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_rdunq        = 0;
                    m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_clnunq       = 0;
                    m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_rdcln        = 0;
                    m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_rdshrd       = 0;
                    m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_rdnotshrddty = 0;
                <% } %>
                end
                else if($test$plusargs("coherent_test")) begin
                    m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_rdnosnp      = 0;
                    m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_rdonce       = 100;
                    m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_wrnosnp      = 0;
                    m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_wrunq        = 100;
                    m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_wrlnunq      = <%=(obj.AiuInfo[pidx].fnNativeInterface != "AXI4")?100:0%>;
				   <% if(obj.AiuInfo[pidx].fnNativeInterface == 'ACE') { %>
                        m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_rdunq        = 100;
                        m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_rdcln        = 100;
                        m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_rdshrd       = 100;
                        m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_rdnotshrddty = 100;
                    <% } %>

                    <% if(obj.AiuInfo[pidx].fnNativeInterface == 'ACELITE-E') { %>
                    m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_rd_cln_invld = 100; 
                    m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_rd_make_invld= 100; 
                    <% } %>

                    if($test$plusargs("en_excl_txn")) begin
                        m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_rdnosnp      = 0/*5*/;
                        m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_rdonce       = 0/*5*/;
                        m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_wrnosnp      = 0/*5*/;
                        m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_wrunq        = 0/*5*/;
                        m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_wrlnunq      = 0;
                    <% if(obj.AiuInfo[pidx].fnNativeInterface == 'ACE') { %>
                        m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_wrcln        = 0;
                        m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_clnunq       = 100;
                        m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_rdunq        = 0;
                        m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_rdcln        = 100;
                        m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_rdshrd       = 100;
                        m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_rdnotshrddty = 100;
                        m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_mkunq        = 0;     
                        m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_clnshrd      = 0;  
                        m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_clninvl      = 0; 
                        m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_mkinvl       = 0; 
                        m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_rd_cln_invld = 0; 
                        m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_rd_make_invld= 0; 
                        m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_clnshrd_pers = 0;
                    <% } %>
                    end
                end
                else begin
                    if(m_mem.noncoh_reg_maps_to_dii == 0) begin
                       m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_rdnosnp      = 100;
                       m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_wrnosnp      = 100;
                    end else begin
                       m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_rdnosnp      = 0;
                       m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_wrnosnp      = 0;
                    end
                    if(($test$plusargs("dce_fix_index"))||($test$plusargs("dmi_fix_index")))begin
                       m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_rdonce       = 0;
                       m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_wrunq        = 100;
                    end else begin
                       m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_rdonce       = 100;
                       m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_wrunq        = 100;
                    end
                    m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_wrlnunq      = <%=(obj.AiuInfo[pidx].fnNativeInterface != "AXI4")?50:0%>;
                    <% if(obj.AiuInfo[pidx].fnNativeInterface == 'ACE') { %>
                       m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_rdshrd       = 100;
                       m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_rdcln        = 100;
                       m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_rdnotshrddty = 100;
                       m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_rdunq        = 100;
                    <% } %>
                    <% if(obj.AiuInfo[pidx].fnNativeInterface == 'ACELITE-E') { %>
                        m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_rd_cln_invld = 100; 
                        m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_rd_make_invld= 100; 
                        m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_clnshrd_pers = 100;
                    <% } %>

	        end // else: !if($test$plusargs("coherent_test"))
          <% } %>	    
     end // else: !if($test$plusargs("write_test")
     
     <%if((obj.AiuInfo[pidx].fnNativeInterface == 'AXI4' && obj.AiuInfo[pidx].useCache)) {%>
         if($test$plusargs("all_gpra_ncmode"))  begin
     // TMP avoid send noncoh txn in coh mem region //TODO when gpra random should add constraint with gpra.nc when select addr in noncoh & coh mem region 
                   m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_rdonce       = 0;
                   m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_wrunq        = 0;
                end
    <% }%>

		<% if(!(obj.AiuInfo[pidx].fnNativeInterface == 'AXI4')) { %>
        <% if(obj.AiuInfo[pidx].fnNativeInterface == 'ACE') { %>
                if ($test$plusargs("use_copyback")) begin
                    m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_wrcln        = 100;
                    m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_wrbk         = 100;
                    m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_wrevct       = 100;
                end else begin
                    m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_wrcln        = 0;
                    m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_wrbk         = 0;
                    m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_wrevct       = 0;
                end
        <% } %>
                if ($test$plusargs("use_nondata")) begin
                    if(m_mem.noncoh_reg_maps_to_dii == 0) begin
                      m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_clnshrd      = 100;
                      m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_clninvl      = 100;
                      m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_mkinvl       = 100;
                      <% if(obj.AiuInfo[pidx].fnNativeInterface == 'ACELITE-E' || obj.AiuInfo[pidx].fnNativeInterface == 'ACE') { %>
                      m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_clnshrd_pers = 100;
                      <% } %>
                    end else begin
                       m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_clnshrd      = 0;
                       m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_clninvl      = 0;
                       m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_mkinvl       = 0;
                    end

                    <% if(obj.AiuInfo[pidx].fnNativeInterface == 'ACE') { %>
                    m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_clnunq       = 50;
                    m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_mkunq        = 50;
                    m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_evct         = 50;
                    m_iocache_seq<%=qidx%>[<%=i%>].no_updates          = 50;
                    <% } %>

                end else begin
                    m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_clnunq       = 0;
                    m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_clnshrd      = 0;
                    m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_clninvl      = 0;
                    m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_mkunq        = 0;
                    m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_mkinvl       = 0;
                    m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_evct         = 0;
                    m_iocache_seq<%=qidx%>[<%=i%>].no_updates          = 0;
                    if($test$plusargs("en_excl_txn")) begin
         <% if(obj.AiuInfo[pidx].fnNativeInterface == 'ACE') { %>
                        m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_clnunq       = 150;
         <% } %>
                    end
                end
        <% if(obj.AiuInfo[pidx].fnNativeInterface != 'ACE-LITE') { %>
                if ($test$plusargs("use_atomic")) begin
                    m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_atm_str      = 50;
                    m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_atm_ld       = 50;
                    m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_atm_swap     = 10;
                    m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_atm_comp     = 10;
                end else begin
                    m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_atm_str      = 0;
                    m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_atm_ld       = 0;
                    m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_atm_swap     = 0;
                    m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_atm_comp     = 0;
                end // else: !if($test$plusargs("use_atomic"))
              if ($test$plusargs("use_atomic_compare")) begin
                    m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_rd_cln_invld = 0; 
                    m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_rd_make_invld= 0; 
                    m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_clnshrd_pers = 0;
                    m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_atm_str      = 0;
                    m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_atm_ld       = 0;
                    m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_atm_swap     = 0;
                    m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_atm_comp     = 400;
              end
            <% if(obj.AiuInfo[pidx].fnNativeInterface == 'ACELITE-E') { %>
                if ($test$plusargs("use_stash")) begin
                    m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_ptl_stash    = 100;
                    m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_full_stash   = 100;
                    m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_shared_stash = 100;
                    m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_unq_stash    = 100;
                    m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_stash_trans  = 0;
                end else begin
                    m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_ptl_stash    = 0;
                    m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_full_stash   = 0;
                    m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_shared_stash = 0;
                    m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_unq_stash    = 0;
                    m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_stash_trans  = 0;
                end
     <% } %>
        <% } %>
               
        <% if((!obj.noDVM) && (obj.AiuInfo[pidx].fnNativeInterface == 'ACE')) { %>
                if ($test$plusargs("use_dvm")) begin
                    m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_dvm_msg      = 25;
                    if($test$plusargs("use_ace_dvmsync") && (enable_ace_dvmsync==0)) begin
                    m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_dvm_sync     = 20;
		                enable_ace_dvmsync = 1;
                    end
		                else begin
                    m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_dvm_sync     = 0;
                    end
                     end else begin
                    m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_dvm_msg      = 0;
                    m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_dvm_sync     = 0;
                   end
        <% } else { %>
                    m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_dvm_msg      = 0;
                    m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_dvm_sync     = 0;
       <% } %>
                /*
                if ($test$plusargs("use_barrier")) begin
                    m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_rd_bar       = 25;
                    m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_wr_bar       = 25;
                end else begin
                    m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_rd_bar       = 0;
                    m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_wr_bar       = 0;
                end
                */
                    if($test$plusargs("dii_cmo_test")) begin
                    <% if (obj.AiuInfo[pidx].fnNativeInterface != 'AXI4') { %>
                    m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_clnshrd_pers = <%=(obj.AiuInfo[pidx].fnNativeInterface == 'ACELITE-E')?100:0%>;                 
                    m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_clnshrd      = 100;
                    m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_clninvl      = 100;
                    m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_mkinvl       = 100;
                    <% } else { %>
                    m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_clnshrd_pers = 0;                 
                    m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_clnshrd      = 0;
                    m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_clninvl      = 0;
                    m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_mkinvl       = 0;
                    <% } %>
                    m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_wrnosnp      = 10;
                    m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_rdnosnp      = 10;
                    m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_rdonce       = 0;
                    m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_rdshrd       = 0;
                    m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_rdcln        = 0;
                    m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_rdnotshrddty = 0;
                    m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_rdunq        = 0;
                    m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_clnunq       = 0;
                    m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_mkunq        = 0;
                    m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_dvm_msg      = 0;
                    m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_dvm_sync     = 0;
                    m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_rd_bar        = 0;
                    m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_rd_cln_invld  = 0;
                    m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_rd_make_invld = 0;
                    m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_clnshrd_pers  = 0;
                  end
      <% if(obj.AiuInfo[pidx].fnNativeInterface == 'ACE') { %>
			      if ($test$plusargs("nouse_unq_invld")) begin
                    m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_rdonce       = 0;
                    m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_rdunq        = 0;
                    m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_wrnosnp      = 0;
                    m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_wrunq        = 0;
                    m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_wrlnunq      = 0;
		        end
	  <%}%>
      <%if(obj.AiuInfo[pidx].fnNativeInterface == 'ACE-LITE' || obj.AiuInfo[pidx].fnNativeInterface == 'ACELITE-E' || obj.AiuInfo[pidx].fnNativeInterface == 'AXI4') { %>
                if ($test$plusargs("nouse_unq_invld")) begin
                    m_iocache_seq<%=qidx%>[<%=i%>].k_num_read_req      = ioaiu_num_trans;
                    m_iocache_seq<%=qidx%>[<%=i%>].k_num_write_req     = 0;
                    m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_wrunq        = 0;
                    m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_wrlnunq      = 0;
		                m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_rd_cln_invld = 0; 
                    m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_rd_make_invld= 0; 
                    m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_clnshrd_pers = 0;
                end
	  <%}%>

                    if($test$plusargs("directed_dtwmrg_test")) begin
                      <% if(obj.AiuInfo[pidx].fnNativeInterface == 'ACE') { %>
                      if($test$plusargs("ace<%=idx%>_clnunique")) begin
                      m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_clnunq       = 100;
                      m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_rdshrd       = 0;
                      m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_rdcln        = 0;
                      m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_rdnotshrddty = 0;
                      m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_rdunq        = 0;
                      end else begin
                      m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_clnunq       = 0;
                      m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_rdshrd       = 100;
                      m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_rdcln        = 100;
                      m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_rdnotshrddty = 100;
                      m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_rdunq        = 100;
                      end
                      m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_rdonce       = 0;
                      m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_rd_cln_invld = 0;
                      m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_ptl_stash    = 0;
                      <% } else if(obj.AiuInfo[pidx].fnNativeInterface == 'ACELITE-E') {%>
                      m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_rdonce       = 100;
                      m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_rd_cln_invld = 100;
                      m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_ptl_stash    = 100;
                      m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_clnunq       = 0;
                      m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_rdshrd       = 0;
                      m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_rdcln        = 0;
                      m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_rdnotshrddty = 0;
                      m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_rdunq        = 0;
                      <% } %>
                      m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_clnshrd_pers = 0;                 
                      m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_clnshrd      = 0;
                      m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_clninvl      = 0;
                      m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_mkinvl       = 0;
                      m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_wrnosnp      = 1;
                      m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_rdnosnp      = 1;
                      m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_mkunq        = 0;
                      m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_dvm_msg      = 0;
                      m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_dvm_sync     = 0;
                      m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_rd_bar        = 0;
                      m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_rd_make_invld = 0;

                  end

          <% } %>
          <% } %>
         <% } // foreach core %>
         <% qidx++; } //foreach ioaiu%>
         <% } // foreahc AIU%>
    end:_setup_axi_inhouse_seq // TODO MOVE IN VIRTUAL SEQ

if (m_concerto_env_cfg.has_axi_vip_snps) begin:_setup_axi_vip_seq_init // TODO MOVE IN VIRTUAL SEQ
         <% qidx=0; for(pidx = 0; pidx < obj.nAIUs; pidx++) { %>
         <% if(!(obj.AiuInfo[pidx].fnNativeInterface.match("CHI"))) { %>
         <% for(let i=0; i<aiu_NumCores[pidx]; i++) { %>
 if ($test$plusargs("read_test")) begin
                cust_seq_h<%=qidx%>[<%=i%>].k_num_read_req      = ioaiu_num_trans;
                cust_seq_h<%=qidx%>[<%=i%>].k_num_write_req     = 0;
            end else if ($test$plusargs("write_test")) begin
                cust_seq_h<%=qidx%>[<%=i%>].k_num_read_req      = 0;
                cust_seq_h<%=qidx%>[<%=i%>].k_num_write_req     = ioaiu_num_trans;
		cust_seq_h<%=qidx%>[<%=i%>].k_num_txn_req       = 0;
            end else if ($test$plusargs("ace_snoop_enable")) begin
                cust_seq_h<%=qidx%>[<%=i%>].k_num_read_req      = 0;
                cust_seq_h<%=qidx%>[<%=i%>].k_num_write_req     = 0;
                cust_seq_h<%=qidx%>[<%=i%>].k_num_txn_req       = ioaiu_num_trans;
            end else if ($test$plusargs("copyback_txn_enable")) begin
                cust_seq_h<%=qidx%>[<%=i%>].k_num_read_req      = 0;
                cust_seq_h<%=qidx%>[<%=i%>].k_num_write_req     = 0;
                cust_seq_h<%=qidx%>[<%=i%>].k_num_txn_req       = ioaiu_num_trans;
            end else if ($test$plusargs("en_outstanding_txn")) begin
                cust_seq_h<%=qidx%>[<%=i%>].k_num_read_req      = ioaiu_num_trans/2;
                cust_seq_h<%=qidx%>[<%=i%>].k_num_write_req     = ioaiu_num_trans/2;
                cust_seq_h<%=qidx%>[<%=i%>].k_num_txn_req       = 0;
          end else if ($test$plusargs("en_exclusive_txn")) begin
                cust_seq_h<%=qidx%>[<%=i%>].k_num_read_req      = 0;
                cust_seq_h<%=qidx%>[<%=i%>].k_num_write_req     = 0;
                cust_seq_h<%=qidx%>[<%=i%>].k_num_txn_req       = ioaiu_num_trans;
	    end else if ($test$plusargs("en_ace_rd_wr_txn")) begin
                cust_seq_h<%=qidx%>[<%=i%>].k_num_read_req      = ioaiu_num_trans/2;
                cust_seq_h<%=qidx%>[<%=i%>].k_num_write_req     = ioaiu_num_trans/2;
                cust_seq_h<%=qidx%>[<%=i%>].k_num_txn_req       = 0;
            end else if ($test$plusargs("k_axi4_seq_f_cov")) begin
                cust_seq_h<%=qidx%>[<%=i%>].k_num_read_req      = 0;
                cust_seq_h<%=qidx%>[<%=i%>].k_num_write_req     = 0;
                cust_seq_h<%=qidx%>[<%=i%>].k_num_txn_req       = ioaiu_num_trans;
            end else if ($test$plusargs("long_delay_en")) begin
                cust_seq_h<%=qidx%>[<%=i%>].k_num_read_req      = ioaiu_num_trans/2;
                cust_seq_h<%=qidx%>[<%=i%>].k_num_write_req     = ioaiu_num_trans/2;
                cust_seq_h<%=qidx%>[<%=i%>].k_num_txn_req       = ioaiu_num_trans;
            end else begin
                cust_seq_h<%=qidx%>[<%=i%>].k_num_read_req      = ioaiu_num_trans/2;
                cust_seq_h<%=qidx%>[<%=i%>].k_num_write_req     = ioaiu_num_trans/2;
		cust_seq_h<%=qidx%>[<%=i%>].k_num_txn_req       = 0;
            end
            if(ioaiu_user_qos == 1) begin
                cust_seq_h<%=qidx%>[<%=i%>].user_qos       = 1;
                cust_seq_h<%=qidx%>[<%=i%>].aiu_qos        = ioaiu_qos[<%=qidx%>];
            end
      <%if(obj.AiuInfo[pidx].fnNativeInterface == 'ACE-LITE' || obj.AiuInfo[pidx].fnNativeInterface == 'ACELITE-E' || obj.AiuInfo[pidx].fnNativeInterface == 'ACE' || obj.AiuInfo[pidx].fnNativeInterface == 'AXI4') { %>
            if ($test$plusargs("read_test")) begin
		<% if(obj.AiuInfo[pidx].fnNativeInterface == 'AXI4' && !obj.AiuInfo[pidx].useCache) { %>
                   cust_seq_h<%=qidx%>[<%=i%>].wt_ace_rdnosnp      = 100;
                   cust_seq_h<%=qidx%>[<%=i%>].wt_ace_rdonce       = 0;
                   cust_seq_h<%=qidx%>[<%=i%>].wt_ace_wrnosnp      = 0;
                   cust_seq_h<%=qidx%>[<%=i%>].wt_ace_wrunq        = 0;
                   cust_seq_h<%=qidx%>[<%=i%>].wt_ace_rdunq        = 0;
                   cust_seq_h<%=qidx%>[<%=i%>].wt_ace_clnunq       = 0;
                   cust_seq_h<%=qidx%>[<%=i%>].wt_ace_rdcln        = 0;
                   cust_seq_h<%=qidx%>[<%=i%>].wt_ace_rdshrd       = 0;
                <% } else { %>
                if($test$plusargs("noncoherent_test")) begin
                   cust_seq_h<%=qidx%>[<%=i%>].wt_ace_rdnosnp      = 100;
                   cust_seq_h<%=qidx%>[<%=i%>].wt_ace_rdonce       = 0;
                   cust_seq_h<%=qidx%>[<%=i%>].wt_ace_wrnosnp      = 0;
                   cust_seq_h<%=qidx%>[<%=i%>].wt_ace_wrunq        = 0;
                   cust_seq_h<%=qidx%>[<%=i%>].wt_ace_rdunq        = 0;
                   cust_seq_h<%=qidx%>[<%=i%>].wt_ace_clnunq       = 0;
                   cust_seq_h<%=qidx%>[<%=i%>].wt_ace_rdcln        = 0;
                   cust_seq_h<%=qidx%>[<%=i%>].wt_ace_rdshrd       = 0;
                   cust_seq_h<%=qidx%>[<%=i%>].wt_ace_rdnotshrddty = 0;
                end
                else if($test$plusargs("coherent_test")) begin
                   cust_seq_h<%=qidx%>[<%=i%>].wt_ace_rdnosnp      = 0;
                   cust_seq_h<%=qidx%>[<%=i%>].wt_ace_rdonce       = 100;
                   cust_seq_h<%=qidx%>[<%=i%>].wt_ace_wrnosnp      = 0;
                   cust_seq_h<%=qidx%>[<%=i%>].wt_ace_wrunq        = 0;
                end
                else begin
                   cust_seq_h<%=qidx%>[<%=i%>].wt_ace_rdnosnp      = 50;
                   cust_seq_h<%=qidx%>[<%=i%>].wt_ace_rdonce       = 50;
                   cust_seq_h<%=qidx%>[<%=i%>].wt_ace_wrnosnp      = 0;
                   cust_seq_h<%=qidx%>[<%=i%>].wt_ace_wrunq        = 0;
                end
            <% } %>
            end else if ($test$plusargs("write_test")) begin
		<% if(obj.AiuInfo[pidx].fnNativeInterface == 'AXI4' && !obj.AiuInfo[pidx].useCache) { %>
                   cust_seq_h<%=qidx%>[<%=i%>].wt_ace_rdnosnp      = 0;
                   cust_seq_h<%=qidx%>[<%=i%>].wt_ace_rdonce       = 0;
                   cust_seq_h<%=qidx%>[<%=i%>].wt_ace_wrnosnp      = 100;
                   cust_seq_h<%=qidx%>[<%=i%>].wt_ace_wrunq        = 0;
                   cust_seq_h<%=qidx%>[<%=i%>].wt_ace_wrlnunq      = 0;
                <% } else { %>
                if($test$plusargs("noncoherent_test")) begin
                   cust_seq_h<%=qidx%>[<%=i%>].wt_ace_rdnosnp      = 0;
                   cust_seq_h<%=qidx%>[<%=i%>].wt_ace_rdonce       = 0;
                   cust_seq_h<%=qidx%>[<%=i%>].wt_ace_wrnosnp      = 100;
                   cust_seq_h<%=qidx%>[<%=i%>].wt_ace_wrunq        = 0;
                   cust_seq_h<%=qidx%>[<%=i%>].wt_ace_wrlnunq      = 0;
                end
                else if($test$plusargs("coherent_test")) begin
                   cust_seq_h<%=qidx%>[<%=i%>].wt_ace_rdnosnp      = 0;
                   cust_seq_h<%=qidx%>[<%=i%>].wt_ace_rdonce       = 0;
                   cust_seq_h<%=qidx%>[<%=i%>].wt_ace_wrnosnp      = 0;
                   cust_seq_h<%=qidx%>[<%=i%>].wt_ace_wrunq        = 5;
                   cust_seq_h<%=qidx%>[<%=i%>].wt_ace_wrlnunq      = 0;
                end
                else begin
                   cust_seq_h<%=qidx%>[<%=i%>].wt_ace_rdnosnp      = 0;
                   cust_seq_h<%=qidx%>[<%=i%>].wt_ace_rdonce       = 0;
                   cust_seq_h<%=qidx%>[<%=i%>].wt_ace_wrnosnp      = 35;
                   cust_seq_h<%=qidx%>[<%=i%>].wt_ace_wrunq        = 35;
                   cust_seq_h<%=qidx%>[<%=i%>].wt_ace_wrlnunq      = <%=(obj.AiuInfo[pidx].fnNativeInterface != "AXI4")?30:0%>;
                end
            <% } %>
            end // if ($test$plusargs("write_test"))
            else begin
		<% if(obj.AiuInfo[pidx].fnNativeInterface == 'AXI4' && !obj.AiuInfo[pidx].useCache) { %>
                    cust_seq_h<%=qidx%>[<%=i%>].wt_ace_rdnosnp      = 100;
                    cust_seq_h<%=qidx%>[<%=i%>].wt_ace_rdonce       = 0;
                    cust_seq_h<%=qidx%>[<%=i%>].wt_ace_wrnosnp      = 100;
                    cust_seq_h<%=qidx%>[<%=i%>].wt_ace_wrunq        = 0;
                    cust_seq_h<%=qidx%>[<%=i%>].wt_ace_wrlnunq      = 0;
                    cust_seq_h<%=qidx%>[<%=i%>].wt_ace_wrcln        = 0;
                    cust_seq_h<%=qidx%>[<%=i%>].wt_ace_rdunq        = 0;
                    cust_seq_h<%=qidx%>[<%=i%>].wt_ace_clnunq       = 0;
                    cust_seq_h<%=qidx%>[<%=i%>].wt_ace_rdcln        = 0;
                    cust_seq_h<%=qidx%>[<%=i%>].wt_ace_rdshrd       = 0;
                <% } else { %>
                if($test$plusargs("noncoherent_test")) begin
                  <% if (obj.AiuInfo[pidx].fnNativeInterface != 'AXI4') { %>
                    cust_seq_h<%=qidx%>[<%=i%>].wt_ace_rdnosnp      = 100;
                    cust_seq_h<%=qidx%>[<%=i%>].wt_ace_rdonce       = 0;
                    cust_seq_h<%=qidx%>[<%=i%>].wt_ace_wrnosnp      = 100;
                    cust_seq_h<%=qidx%>[<%=i%>].wt_ace_wrunq        = 0;
                    cust_seq_h<%=qidx%>[<%=i%>].wt_ace_wrlnunq      = 0;
                    cust_seq_h<%=qidx%>[<%=i%>].wt_ace_wrcln        = 0;
                    cust_seq_h<%=qidx%>[<%=i%>].wt_ace_rdunq        = 0;
                    cust_seq_h<%=qidx%>[<%=i%>].wt_ace_clnunq       = 0;
                    cust_seq_h<%=qidx%>[<%=i%>].wt_ace_rdcln        = 0;
                    cust_seq_h<%=qidx%>[<%=i%>].wt_ace_rdshrd       = 0;
                    cust_seq_h<%=qidx%>[<%=i%>].wt_ace_rdnotshrddty = 0;                
                <% } else { %>
                    cust_seq_h<%=qidx%>[<%=i%>].wt_ace_rdnosnp      = 100;
                    cust_seq_h<%=qidx%>[<%=i%>].wt_ace_rdonce       = 0;
                    cust_seq_h<%=qidx%>[<%=i%>].wt_ace_wrnosnp      = 100;
                    cust_seq_h<%=qidx%>[<%=i%>].wt_ace_wrunq        = 0;
                    cust_seq_h<%=qidx%>[<%=i%>].wt_ace_wrlnunq      = 0;
                    cust_seq_h<%=qidx%>[<%=i%>].wt_ace_wrcln        = 0;
                    cust_seq_h<%=qidx%>[<%=i%>].wt_ace_rdunq        = 0;
                    cust_seq_h<%=qidx%>[<%=i%>].wt_ace_clnunq       = 0;
                    cust_seq_h<%=qidx%>[<%=i%>].wt_ace_rdcln        = 0;
                    cust_seq_h<%=qidx%>[<%=i%>].wt_ace_rdshrd       = 0;
                    cust_seq_h<%=qidx%>[<%=i%>].wt_ace_rdnotshrddty = 0;
                <% } %>
                end
                else if($test$plusargs("coherent_test")) begin
                    cust_seq_h<%=qidx%>[<%=i%>].wt_ace_rdnosnp      = 0;
                    cust_seq_h<%=qidx%>[<%=i%>].wt_ace_rdonce       = 100;
                    cust_seq_h<%=qidx%>[<%=i%>].wt_ace_wrnosnp      = 0;
                    cust_seq_h<%=qidx%>[<%=i%>].wt_ace_wrunq        = 100;
                    cust_seq_h<%=qidx%>[<%=i%>].wt_ace_wrlnunq      = <%=(obj.AiuInfo[pidx].fnNativeInterface != "AXI4")?100:0%>;
                    <% if(obj.AiuInfo[pidx].fnNativeInterface == 'ACELITE-E') { %>
                    cust_seq_h<%=qidx%>[<%=i%>].wt_ace_rd_cln_invld = 100; 
                    cust_seq_h<%=qidx%>[<%=i%>].wt_ace_rd_make_invld= 100; 
                    <% } %>

                    if($test$plusargs("en_excl_txn")) begin
                        cust_seq_h<%=qidx%>[<%=i%>].wt_ace_rdnosnp      = 0/*5*/;
                        cust_seq_h<%=qidx%>[<%=i%>].wt_ace_rdonce       = 0/*5*/;
                        cust_seq_h<%=qidx%>[<%=i%>].wt_ace_wrnosnp      = 0/*5*/;
                        cust_seq_h<%=qidx%>[<%=i%>].wt_ace_wrunq        = 0/*5*/;
                        cust_seq_h<%=qidx%>[<%=i%>].wt_ace_wrlnunq      = 0;
                    <% if(obj.AiuInfo[pidx].fnNativeInterface == 'ACE') { %>
                        cust_seq_h<%=qidx%>[<%=i%>].wt_ace_wrcln        = 0;
                        cust_seq_h<%=qidx%>[<%=i%>].wt_ace_clnunq       = 100;
                        cust_seq_h<%=qidx%>[<%=i%>].wt_ace_rdunq        = 0;
                        cust_seq_h<%=qidx%>[<%=i%>].wt_ace_rdcln        = 100;
                        cust_seq_h<%=qidx%>[<%=i%>].wt_ace_rdshrd       = 100;
                        cust_seq_h<%=qidx%>[<%=i%>].wt_ace_rdnotshrddty = 100;
                        cust_seq_h<%=qidx%>[<%=i%>].wt_ace_mkunq        = 0;     
                        cust_seq_h<%=qidx%>[<%=i%>].wt_ace_clnshrd      = 0;  
                        cust_seq_h<%=qidx%>[<%=i%>].wt_ace_clninvl      = 0; 
                        cust_seq_h<%=qidx%>[<%=i%>].wt_ace_mkinvl       = 0; 
                        cust_seq_h<%=qidx%>[<%=i%>].wt_ace_rd_cln_invld = 0; 
                        cust_seq_h<%=qidx%>[<%=i%>].wt_ace_rd_make_invld= 0; 
                        cust_seq_h<%=qidx%>[<%=i%>].wt_ace_clnshrd_pers = 0;
                    <% } %>
                    end
                end
                else begin
                    if(m_mem.noncoh_reg_maps_to_dii == 0) begin
                       cust_seq_h<%=qidx%>[<%=i%>].wt_ace_rdnosnp      = 100;
                       cust_seq_h<%=qidx%>[<%=i%>].wt_ace_wrnosnp      = 100;
 if($test$plusargs("excl_txn_en")) begin	
                       cust_seq_h<%=qidx%>[<%=i%>].wt_ace_exclusive_wr      = 90;
                       cust_seq_h<%=qidx%>[<%=i%>].wt_ace_exclusive_rd      = 90;
end
                    end else begin
                       cust_seq_h<%=qidx%>[<%=i%>].wt_ace_rdnosnp      = 0;
                       cust_seq_h<%=qidx%>[<%=i%>].wt_ace_wrnosnp      = 0;
 if($test$plusargs("excl_txn_en")) begin	
                       cust_seq_h<%=qidx%>[<%=i%>].wt_ace_exclusive_wr      = 90;
                       cust_seq_h<%=qidx%>[<%=i%>].wt_ace_exclusive_rd      = 90;
end
                    end
                    if(($test$plusargs("dce_fix_index"))||($test$plusargs("dmi_fix_index")))begin
                       cust_seq_h<%=qidx%>[<%=i%>].wt_ace_rdonce       = 0;
                       cust_seq_h<%=qidx%>[<%=i%>].wt_ace_wrunq        = 100;
                    end else begin
                       cust_seq_h<%=qidx%>[<%=i%>].wt_ace_rdonce       = 100;
                       cust_seq_h<%=qidx%>[<%=i%>].wt_ace_wrunq        = 100;
                    end
                    cust_seq_h<%=qidx%>[<%=i%>].wt_ace_wrlnunq      = <%=(obj.AiuInfo[pidx].fnNativeInterface != "AXI4")?50:0%>;
                    <% if(obj.AiuInfo[pidx].fnNativeInterface == 'ACE') { %>
                       cust_seq_h<%=qidx%>[<%=i%>].wt_ace_rdshrd       = 50;
                       cust_seq_h<%=qidx%>[<%=i%>].wt_ace_rdcln        = 50;
                       cust_seq_h<%=qidx%>[<%=i%>].wt_ace_rdnotshrddty = 50;
                       cust_seq_h<%=qidx%>[<%=i%>].wt_ace_rdunq        = 50;
                    <% } %>
                    <% if(obj.AiuInfo[pidx].fnNativeInterface == 'ACELITE-E') { %>
                        cust_seq_h<%=qidx%>[<%=i%>].wt_ace_rd_cln_invld = 100; 
                        cust_seq_h<%=qidx%>[<%=i%>].wt_ace_rd_make_invld= 100; 
                        cust_seq_h<%=qidx%>[<%=i%>].wt_ace_clnshrd_pers = 100;
                    <% } %>
	        end // else: !if($test$plusargs("coherent_test"))
	        <% } %>	    
	   end // else: !if($test$plusargs("write_test"))

     <%if((obj.AiuInfo[pidx].fnNativeInterface == 'AXI4' && obj.AiuInfo[pidx].useCache)) {%>
         if($test$plusargs("all_gpra_ncmode"))  begin
     // TMP avoid send noncoh txn in coh mem region //TODO when gpra random should add constraint with gpra.nc when select addr in noncoh & coh mem region 
                   cust_seq_h<%=qidx%>[<%=i%>].wt_ace_rdonce       = 0;
                   cust_seq_h<%=qidx%>[<%=i%>].wt_ace_wrunq        = 0;
                end
    <% }%>

		<% if(obj.AiuInfo[pidx].fnNativeInterface != 'AXI4') { %>
        <% if(obj.AiuInfo[pidx].fnNativeInterface == 'ACE') { %>
                if ($test$plusargs("use_copyback")) begin
                    cust_seq_h<%=qidx%>[<%=i%>].wt_ace_wrcln        = 100;
                    cust_seq_h<%=qidx%>[<%=i%>].wt_ace_wrbk         = 100;
                    cust_seq_h<%=qidx%>[<%=i%>].wt_ace_wrevct       = 100;
                end else begin
                    cust_seq_h<%=qidx%>[<%=i%>].wt_ace_wrcln        = 0;
                    cust_seq_h<%=qidx%>[<%=i%>].wt_ace_wrbk         = 0;
                    cust_seq_h<%=qidx%>[<%=i%>].wt_ace_wrevct       = 0;
                end
        <% } %>
                if ($test$plusargs("use_nondata")) begin
                    if(m_mem.noncoh_reg_maps_to_dii == 0) begin
                       cust_seq_h<%=qidx%>[<%=i%>].wt_ace_clnshrd      = 100;
                       cust_seq_h<%=qidx%>[<%=i%>].wt_ace_clninvl      = 100;
                       cust_seq_h<%=qidx%>[<%=i%>].wt_ace_mkinvl       = 100;
                      <% if(obj.AiuInfo[pidx].fnNativeInterface == 'ACELITE-E' || obj.AiuInfo[pidx].fnNativeInterface == 'ACE') { %>
                      cust_seq_h<%=qidx%>[<%=i%>].wt_ace_clnshrd_pers = 100;
                      <% } %>
                    end else begin
                       cust_seq_h<%=qidx%>[<%=i%>].wt_ace_clnshrd      = 0;
                       cust_seq_h<%=qidx%>[<%=i%>].wt_ace_clninvl      = 0;
                       cust_seq_h<%=qidx%>[<%=i%>].wt_ace_mkinvl       = 0;
                    end
        <% if(obj.AiuInfo[pidx].fnNativeInterface == 'ACE') { %>
                    cust_seq_h<%=qidx%>[<%=i%>].wt_ace_clnunq       = 50;
                    cust_seq_h<%=qidx%>[<%=i%>].wt_ace_mkunq        = 50;
                    cust_seq_h<%=qidx%>[<%=i%>].wt_ace_evct         = 50;
                    cust_seq_h<%=qidx%>[<%=i%>].no_updates          = 50;
        <% } %>
                end else begin
                    cust_seq_h<%=qidx%>[<%=i%>].wt_ace_clnunq       = 0;
                    cust_seq_h<%=qidx%>[<%=i%>].wt_ace_clnshrd      = 0;
                    cust_seq_h<%=qidx%>[<%=i%>].wt_ace_clninvl      = 0;
                    cust_seq_h<%=qidx%>[<%=i%>].wt_ace_mkunq        = 0;
                    cust_seq_h<%=qidx%>[<%=i%>].wt_ace_mkinvl       = 0;
                    cust_seq_h<%=qidx%>[<%=i%>].wt_ace_evct         = 0;
                    cust_seq_h<%=qidx%>[<%=i%>].no_updates          = 0;
                    if($test$plusargs("en_excl_txn")) begin
         <% if(obj.AiuInfo[pidx].fnNativeInterface == 'ACE') { %>
                        cust_seq_h<%=qidx%>[<%=i%>].wt_ace_clnunq       = 150;
         <% } %>
                    end
                end
        <% if(obj.AiuInfo[pidx].fnNativeInterface != 'ACE-LITE') { %>
                if ($test$plusargs("use_atomic")) begin
                    cust_seq_h<%=qidx%>[<%=i%>].wt_ace_atm_str      = 50;
                    cust_seq_h<%=qidx%>[<%=i%>].wt_ace_atm_ld       = 50;
                    cust_seq_h<%=qidx%>[<%=i%>].wt_ace_atm_swap     = 10;
                    cust_seq_h<%=qidx%>[<%=i%>].wt_ace_atm_comp     = 10;
                end else begin
                    cust_seq_h<%=qidx%>[<%=i%>].wt_ace_atm_str      = 0;
                    cust_seq_h<%=qidx%>[<%=i%>].wt_ace_atm_ld       = 0;
                    cust_seq_h<%=qidx%>[<%=i%>].wt_ace_atm_swap     = 0;
                    cust_seq_h<%=qidx%>[<%=i%>].wt_ace_atm_comp     = 0;
                end // else: !if($test$plusargs("use_atomic"))
              if ($test$plusargs("use_atomic_compare")) begin
                    cust_seq_h<%=qidx%>[<%=i%>].wt_ace_rd_cln_invld = 0; 
                    cust_seq_h<%=qidx%>[<%=i%>].wt_ace_rd_make_invld= 0; 
                    cust_seq_h<%=qidx%>[<%=i%>].wt_ace_clnshrd_pers = 0;
                    cust_seq_h<%=qidx%>[<%=i%>].wt_ace_atm_str      = 0;
                    cust_seq_h<%=qidx%>[<%=i%>].wt_ace_atm_ld       = 0;
                    cust_seq_h<%=qidx%>[<%=i%>].wt_ace_atm_swap     = 0;
                    cust_seq_h<%=qidx%>[<%=i%>].wt_ace_atm_comp     = 400;
              end

            <% if(obj.AiuInfo[pidx].fnNativeInterface == 'ACELITE-E') { %>
                if ($test$plusargs("use_stash")) begin
                    cust_seq_h<%=qidx%>[<%=i%>].wt_ace_ptl_stash    = 100;
                    cust_seq_h<%=qidx%>[<%=i%>].wt_ace_full_stash   = 100;
                    cust_seq_h<%=qidx%>[<%=i%>].wt_ace_shared_stash = 100;
                    cust_seq_h<%=qidx%>[<%=i%>].wt_ace_unq_stash    = 100;
                    cust_seq_h<%=qidx%>[<%=i%>].wt_ace_stash_trans  = 0;
                end else begin
                    cust_seq_h<%=qidx%>[<%=i%>].wt_ace_ptl_stash    = 0;
                    cust_seq_h<%=qidx%>[<%=i%>].wt_ace_full_stash   = 0;
                    cust_seq_h<%=qidx%>[<%=i%>].wt_ace_shared_stash = 0;
                    cust_seq_h<%=qidx%>[<%=i%>].wt_ace_unq_stash    = 0;
                    cust_seq_h<%=qidx%>[<%=i%>].wt_ace_stash_trans  = 0;
                end
            <% } %>
        <% } %>
               
        <% if((!obj.noDVM) && (obj.AiuInfo[pidx].fnNativeInterface == 'ACE')) { %>
                if ($test$plusargs("use_dvm")) begin
                    cust_seq_h<%=qidx%>[<%=i%>].wt_ace_dvm_msg      = 25;
                    if($test$plusargs("use_ace_dvmsync") && (enable_ace_dvmsync==0)) begin
                    cust_seq_h<%=qidx%>[<%=i%>].wt_ace_dvm_sync     = 20;
		    enable_ace_dvmsync = 1;
                    end
		    else begin
                    cust_seq_h<%=qidx%>[<%=i%>].wt_ace_dvm_sync     = 0;
                    end
                end else begin
                    cust_seq_h<%=qidx%>[<%=i%>].wt_ace_dvm_msg      = 0;
                    cust_seq_h<%=qidx%>[<%=i%>].wt_ace_dvm_sync     = 0;
                end
        <% } else { %>
                    cust_seq_h<%=qidx%>[<%=i%>].wt_ace_dvm_msg      = 0;
                    cust_seq_h<%=qidx%>[<%=i%>].wt_ace_dvm_sync     = 0;
       <% } %>
                if ($test$plusargs("use_barrier")) begin
                   // cust_seq_h<%=qidx%>[<%=i%>].wt_ace_rd_bar       = 25;
                   // cust_seq_h<%=qidx%>[<%=i%>].wt_ace_wr_bar       = 25;
                end else begin
                   // cust_seq_h<%=qidx%>[<%=i%>].wt_ace_rd_bar       = 0;
                   // cust_seq_h<%=qidx%>.wt_ace_wr_bar       = 0;
                end

                    if($test$plusargs("dii_cmo_test")) begin
                    <% if (obj.AiuInfo[pidx].fnNativeInterface != 'AXI4') { %>
                    cust_seq_h<%=qidx%>[<%=i%>].wt_ace_clnshrd_pers = <%=(obj.AiuInfo[pidx].fnNativeInterface == 'ACELITE-E')?100:0%>;                 
                    cust_seq_h<%=qidx%>[<%=i%>].wt_ace_clnshrd      = 100;
                    cust_seq_h<%=qidx%>[<%=i%>].wt_ace_clninvl      = 100;
                    cust_seq_h<%=qidx%>[<%=i%>].wt_ace_mkinvl       = 100;
                    <% } else { %>
                    cust_seq_h<%=qidx%>[<%=i%>].wt_ace_clnshrd_pers = 0;                 
                    cust_seq_h<%=qidx%>[<%=i%>].wt_ace_clnshrd      = 0;
                    cust_seq_h<%=qidx%>[<%=i%>].wt_ace_clninvl      = 0;
                    cust_seq_h<%=qidx%>[<%=i%>].wt_ace_mkinvl       = 0;
                    <% } %>
                    cust_seq_h<%=qidx%>[<%=i%>].wt_ace_wrnosnp      = 10;
                    cust_seq_h<%=qidx%>[<%=i%>].wt_ace_rdnosnp      = 10;
                    cust_seq_h<%=qidx%>[<%=i%>].wt_ace_rdonce       = 0;
                    cust_seq_h<%=qidx%>[<%=i%>].wt_ace_rdshrd       = 0;
                    cust_seq_h<%=qidx%>[<%=i%>].wt_ace_rdcln        = 0;
                    cust_seq_h<%=qidx%>[<%=i%>].wt_ace_rdnotshrddty = 0;
                    cust_seq_h<%=qidx%>[<%=i%>].wt_ace_rdunq        = 0;
                    cust_seq_h<%=qidx%>[<%=i%>].wt_ace_clnunq       = 0;
                    cust_seq_h<%=qidx%>[<%=i%>].wt_ace_mkunq        = 0;
                    cust_seq_h<%=qidx%>[<%=i%>].wt_ace_dvm_msg      = 0;
                    cust_seq_h<%=qidx%>[<%=i%>].wt_ace_dvm_sync     = 0;
                    cust_seq_h<%=qidx%>[<%=i%>].wt_ace_rd_bar        = 0;
                    cust_seq_h<%=qidx%>[<%=i%>].wt_ace_rd_cln_invld  = 0;
                    cust_seq_h<%=qidx%>[<%=i%>].wt_ace_rd_make_invld = 0;
                    cust_seq_h<%=qidx%>[<%=i%>].wt_ace_clnshrd_pers  = 0;
                  end

                    if($test$plusargs("directed_dtwmrg_test")) begin
                      <% if(obj.AiuInfo[pidx].fnNativeInterface == 'ACE') { %>
                      if($test$plusargs("ace<%=idx%>_clnunique")) begin
                      cust_seq_h<%=qidx%>[<%=i%>].wt_ace_clnunq       = 100;
                      cust_seq_h<%=qidx%>[<%=i%>].wt_ace_rdshrd       = 0;
                      cust_seq_h<%=qidx%>[<%=i%>].wt_ace_rdcln        = 0;
                      cust_seq_h<%=qidx%>[<%=i%>].wt_ace_rdnotshrddty = 0;
                      cust_seq_h<%=qidx%>[<%=i%>].wt_ace_rdunq        = 0;
                      end else begin
                      cust_seq_h<%=qidx%>[<%=i%>].wt_ace_clnunq       = 0;
                      cust_seq_h<%=qidx%>[<%=i%>].wt_ace_rdshrd       = 100;
                      cust_seq_h<%=qidx%>[<%=i%>].wt_ace_rdcln        = 100;
                      cust_seq_h<%=qidx%>[<%=i%>].wt_ace_rdnotshrddty = 100;
                      cust_seq_h<%=qidx%>[<%=i%>].wt_ace_rdunq        = 100;
                      end
                      cust_seq_h<%=qidx%>[<%=i%>].wt_ace_rdonce       = 0;
                      cust_seq_h<%=qidx%>[<%=i%>].wt_ace_rd_cln_invld = 0;
                      cust_seq_h<%=qidx%>[<%=i%>].wt_ace_ptl_stash    = 0;
                      <% } else if(obj.AiuInfo[pidx].fnNativeInterface == 'ACELITE-E') {%>
                      cust_seq_h<%=qidx%>[<%=i%>].wt_ace_rdonce       = 100;
                      cust_seq_h<%=qidx%>[<%=i%>].wt_ace_rd_cln_invld = 100;
                      cust_seq_h<%=qidx%>[<%=i%>].wt_ace_ptl_stash    = 100;
                      cust_seq_h<%=qidx%>[<%=i%>].wt_ace_clnunq       = 0;
                      cust_seq_h<%=qidx%>[<%=i%>].wt_ace_rdshrd       = 0;
                      cust_seq_h<%=qidx%>[<%=i%>].wt_ace_rdcln        = 0;
                      cust_seq_h<%=qidx%>[<%=i%>].wt_ace_rdnotshrddty = 0;
                      cust_seq_h<%=qidx%>[<%=i%>].wt_ace_rdunq        = 0;
                      <% } %>
                      cust_seq_h<%=qidx%>[<%=i%>].wt_ace_clnshrd_pers = 0;                 
                      cust_seq_h<%=qidx%>[<%=i%>].wt_ace_clnshrd      = 0;
                      cust_seq_h<%=qidx%>[<%=i%>].wt_ace_clninvl      = 0;
                      cust_seq_h<%=qidx%>[<%=i%>].wt_ace_mkinvl       = 0;
                      cust_seq_h<%=qidx%>[<%=i%>].wt_ace_wrnosnp      = 1;
                      cust_seq_h<%=qidx%>[<%=i%>].wt_ace_rdnosnp      = 1;
                      cust_seq_h<%=qidx%>[<%=i%>].wt_ace_mkunq        = 0;
                      cust_seq_h<%=qidx%>[<%=i%>].wt_ace_dvm_msg      = 0;
                      cust_seq_h<%=qidx%>[<%=i%>].wt_ace_dvm_sync     = 0;
                      cust_seq_h<%=qidx%>[<%=i%>].wt_ace_rd_bar        = 0;
                      cust_seq_h<%=qidx%>[<%=i%>].wt_ace_rd_make_invld = 0;

                  end
      <% } %>
      <% } %>
      <% } //for each core%>
    <% qidx++; } //foreach IO%>
  <% } //Foreach AIU%>

end:_setup_axi_vip_seq_init // TODO MOVE IN VIRTUAL SEQ


  `uvm_info("IOSUBSYS_TEST_SNPS", "END START_OF_SIMULATION", UVM_LOW)
//END setup MASTER_SEQ
endfunction:start_of_simulation_phase

// !!!! WE  USE RUN_PHASE & MAIN_PHASE !!!!!
//run_phase != main_phase 
// run_phase all the forked (sysco,pma etc...) sequence
// main_phase only the txn sequence
task concerto_iosubsys_test_snps::run_phase(uvm_phase phase); 
  `uvm_info("IOSUBSYS_TEST_SNPS", "RUN_PHASE", UVM_LOW)
   super.run_phase(phase);

 

 if(m_concerto_env_cfg.has_chi_vip_snps) begin:_chi_vip_lnk 
 fork
  <% idx = 0; %>
  <% for(pidx = 0; pidx < obj.nAIUs; pidx++) { %>
    <%if((obj.AiuInfo[pidx].fnNativeInterface == 'CHI-A')||(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-B' || obj.AiuInfo[pidx].fnNativeInterface == 'CHI-E')) { %>
    begin
        `uvm_info(get_name(), "USE_VIP_SNPS svt_chi_link_UP_service_sequence::START[<%=idx%>]", UVM_LOW)
         svt_chi_link_up_seq_h<%=idx%>.start(m_concerto_env.snps.svt.amba_system_env.chi_system[0].rn[<%=idx%>].link_svc_seqr) ;
        `uvm_info(get_name(), "USE_VIP_SNPS svt_chi_link_UP_service_sequence::END[<%=idx%>]", UVM_LOW)
    end
    <% idx++; %>
    <%} %>
  <% } %>
    join


    fork
  <% idx = 0; %>
  <% for(pidx = 0; pidx < obj.nAIUs; pidx++) { %>
    <%if(obj.AiuInfo[pidx].fnNativeInterface.match("CHI")) { %>
    begin
        `uvm_info(get_name(), "USE_VIP_SNPS coherency_entry_seq::START[<%=idx%>]", UVM_NONE)
        coherency_entry_seq<%=idx%>.wait_mode_using_trigger=0;
        coherency_entry_seq<%=idx%>.wait_mode_using_delay=1; // using delay instead of trigger because we check in the boot if CHI is connected
        coherency_entry_seq<%=idx%>.delay_in_ns=500;
        coherency_entry_seq<%=idx%>.randomize();
        fork
        begin
        coherency_entry_seq<%=idx%>.start(m_concerto_env.snps.svt.amba_system_env.chi_system[0].rn[<%=idx%>].prot_svc_seqr);
        `uvm_info(get_name(), "USE_VIP_SNPS coherency_entry_seq::END[<%=idx%>]", UVM_NONE)
        end
        join_none
        //#(coherency_entry_seq<%=idx%>.delay_in_ns*1ns);
        //csr_init_done.wait_trigger();
        //`uvm_info("TEST MAIN", "Done - waiting for csr_init_done trigger", UVM_NONE)
        //tb_top.release_sysco_req = 1;
    end
    <% idx++; %>
    <%} %>
  <% } %>
    join_none
 end:_chi_vip_lnk else begin:_chi_inhouse_lnk
 
 // Setup SysCO attach for CHI & launch pin attach
  fork
  <% idx = 0; %>
  <% for(pidx = 0; pidx < obj.nAIUs; pidx++) { %>
    <%if(obj.AiuInfo[pidx].fnNativeInterface.match("CHI")) { %>
    begin
        if(!$test$plusargs("sysco_disable") && !test_cfg.k_access_boot_region) begin
           #50ns;// add time to avoid conflict with construct_lnk_seq & reset
            m_chi<%=idx%>_vseq.construct_sysco_seq(chiaiu<%=idx%>_chi_agent_pkg::CONNECT);  
        end
    end
    <% idx++; %>
    <%} %>
  <% } %>
  join
// BEGIN CHI LINK_CONSTRUCTOR
    fork
  <% idx = 0; %>
  <% for(pidx = 0; pidx < obj.nAIUs; pidx++) { %>
    <%if((obj.AiuInfo[pidx].fnNativeInterface.match("CHI"))) {%>
    begin
        m_chi<%=idx%>_vseq.construct_lnk_seq();
        m_chi<%=idx%>_vseq.construct_txs_seq();
    end
    <% idx++; %>
    <%} %>
  <% } %>
    join
 end:_chi_inhouse_lnk
 // END CHI LINK_CONSTRUCTOR

   wait(iter == max_iteration-1) 
   ev_sim_done.wait_trigger();
   main_seq_hook_end_run_phase(phase);
  `uvm_info("IOSUBSYS_TEST_SNPS", "END RUN_PHASE", UVM_LOW)
endtask:run_phase;

//////////////////
//Calling Method: main_phase()
//////////////////
task concerto_iosubsys_test_snps::main_phase(uvm_phase phase);
   super.main_phase(phase);
   `uvm_info("IOSUBSYS_TEST_SNPS", "Starting MAIN_PHASE", UVM_LOW)
    phase.raise_objection(this, "fsys_test main_phase");
    #1; //Wait ALL MAIN_PHASE start
   <% if (obj.testBench == "emu" ) { %>
    emu_boot_tsk.exec_inhouse_boot_seq(phase);
   <%}%>
    exec_inhouse_seq(phase);
    wait_seq_totaly_done(phase);
   ev_sim_done.trigger();
    if (timeout)begin
            `uvm_fatal(get_name(), "Test Timeout")
            //#50us;
        end

   if($test$plusargs("trace_accum_check")) begin
      <% if (numBootIoAiu > 0) { %>
	   #1us;
	   ioaiu_trace_accum_check<%=BootIoAiu[0]%>(trace_capture_en_q);	
     <% } %>
    	end
    main_seq_post_hook(phase);
   phase.drop_objection(this, "fsys_test main_phase");
   `uvm_info("IOSUBSYS_TEST_SNPS", "Finish MAIN_PHASE", UVM_LOW)
endtask: main_phase


function void concerto_iosubsys_test_snps::phase_ready_to_end(uvm_phase phase);
   super.phase_ready_to_end(phase);
    if($test$plusargs("hard_reset_en")) begin
       if(phase.get_imp() == uvm_shutdown_phase::get()) begin
          if(hard_reset_issued == 0) begin
             `uvm_info("IOSUBSYS_TEST_SNPS", "Going to RESET", UVM_NONE)
             phase.jump(uvm_pre_reset_phase::get());
             hard_reset_issued++;
          end
       end
    end   
 
  endfunction

task concerto_iosubsys_test_snps::exec_inhouse_seq(uvm_phase phase); // BY default launch random txn
    
  bit [31:0] ioaiu_control_cfg;
  phase.raise_objection(this, "exec_inhouse_seq");
  `uvm_info("IOSUBSYS_TEST_SNPS", "Start exec_inhouse_seq", UVM_LOW)

   main_seq_pre_hook(phase);
  // trigger csr_init_done to unit scoreboards
  csr_init_done.trigger(null);

  #100ns; 
  
  <% if(numBootIoAiu > 0) { %>
  if($test$plusargs("check_corr_interrupt")) begin
     check_corr_errint_through_alias_reg();
  end
  <% } %>

  if($test$plusargs("inject_error_all_dmi_smc")) begin
     inject_error_all_dmi_smc();
  end
  
  if(k_csr_access_only==0) begin
    if($test$plusargs("trace_capture_en")) begin
	      trace_capture_en();
	  end
    if($test$plusargs("trace_trigger_en")) begin
	      trace_trigger_en();
        csr_trace_debug_done.trigger(null);
	  end
  end

  if ($value$plusargs("use_user_addrq=%d", use_user_addrq) && !test_cfg.k_access_boot_region) begin:_use_user_addrq
  // k_access_boot_region create their own use_user_addrq
      gen_addr_use_user_addrq();
  end:_use_user_addrq

  for (iter = 0; iter < max_iteration ; iter++ ) begin: _iteration_loop
    if (iter>0) #10us;
    main_seq_iter_pre_hook (phase,iter);
    fork:_exec_fork
      fork:_start_all_seq
         <% 
         chiaiu_idx = 0;
         ioaiu_idx = 0;
         ioaiu_idx_with_multi_core = 0;
         for(pidx = 0; pidx < obj.nAIUs; pidx++) { %>
            <% if ((obj.AiuInfo[pidx].fnNativeInterface == 'CHI-A')||(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-B')||(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-E')) { %>
            if (m_concerto_env_cfg.has_chi_vip_snps) begin:_chiaiu<%=chiaiu_idx%>_vip //TODO remove to use only virtual seq
                    if(chiaiu_en.exists(<%=chiaiu_idx%>)) begin
                     phase.raise_objection(this, "USE_VIP_SNPS CHIAIU<%=chiaiu_idx%> sequence");
                    `uvm_info(get_name(), "USE_VIP_SNPS svt_chi_rn_transaction_random_sequence::START[<%=chiaiu_idx%>]", UVM_LOW)
                     if((<%=chiaiu_idx%> == 0) && $test$plusargs("dvm_hang_test")) begin
			                  #5ns;
                     end
                     svt_chi_rn_seq_h<%=chiaiu_idx%>.start(m_concerto_env.snps.svt.amba_system_env.chi_system[0].rn[<%=chiaiu_idx%>].rn_xact_seqr) ;
                     //#1us;
                     done_svt_chi_rn_seq_h<%=chiaiu_idx%>.trigger(null);
                    `uvm_info("TEST_MAIN", "USE_VIP_SNPS svt_chi_rn_transaction_random_sequence::DONE[<%=chiaiu_idx%>]", UVM_NONE)
                     phase.drop_objection(this, "USE_VIP_SNPS CHIAIU<%=chiaiu_idx%> sequence");
                    end
                //  else begin  // Why seq.start if no chi ??? //start in slave mode to acept snoop ?//TOREMOVE ?? 
                //    m_svt_chi_item.print();
                //   `uvm_info(get_name(), "Start m_snps_chi<%=chiaiu_idx%>_vseq", UVM_NONE)
                //    //snps_vseq.start(null);
                //    m_snps_chi<%=chiaiu_idx%>_vseq.start(null);
                //    //done_svt_chi_rn_seq_h<%=chiaiu_idx%>.trigger(null);
                //   `uvm_info(get_name(), "Done m_snps_chi<%=chiaiu_idx%>_vseq", UVM_NONE)
                // end
            
            end:_chiaiu<%=chiaiu_idx%>_vip else  begin:_chiaiu<%=chiaiu_idx%>_inhouse
                    if(chiaiu_en.exists(<%=chiaiu_idx%>)) begin
                  `uvm_info("IOSUBSYS_TEST_SNPS", "Start CHIAIU<%=chiaiu_idx%> VSEQ", UVM_NONE)
                   phase.raise_objection(this, "CHIAIU<%=chiaiu_idx%> sequence");
                   if((<%=chiaiu_idx%> == 0) && $test$plusargs("dvm_hang_test")) begin
			         #5ns;
                   end
                   m_chi<%=chiaiu_idx%>_vseq.start(null);
                   `uvm_info("IOSUBSYS_TEST_SNPS", "Done CHIAIU<%=chiaiu_idx%> VSEQ", UVM_NONE)
                   //#5us;
                   phase.drop_objection(this, "CHIAIU<%=chiaiu_idx%> sequence");
                   end
            end:_chiaiu<%=chiaiu_idx%>_inhouse
      <% chiaiu_idx++; %>
      <% } else { %>
         <% for(let i=0; i<aiu_NumCores[pidx]; i++) { %>  
         if (m_concerto_env_cfg.has_axi_vip_snps && ioaiu_en.exists(<%=ioaiu_idx%>)) begin: _ioaiu<%=ioaiu_idx%>_<%=i%>_vip // TODO remove to use only one virtual seq
                       //SVT TRAFFIC
                        phase.raise_objection(this, "USE_VIP_SNPS IOAIU<%=ioaiu_idx%> sequence");
                       `uvm_info("TEST_MAIN", "USE_VIP_SNPS START cust_seq_h<%=ioaiu_idx%>[<%=i%>]", UVM_NONE)
                        uvm_config_db#(svt_axi_port_configuration)::set(null, "*", "port_cfg_ioaiu<%=ioaiu_idx%>_<%=i%>", m_concerto_env_cfg.svt_cfg.axi_sys_cfg[0].master_cfg[<%=(aiu_rpn[pidx]+i)-chi_idx%>]);
                        if(ioaiu_num_trans > 0) begin
                          if($test$plusargs("use_legacy_ioaiu_seq"))
                            cust_seq_h<%=ioaiu_idx%>[<%=i%>].start(m_concerto_env.snps.svt.amba_system_env.axi_system[0].sequencer);
                          else
                            run_ioaiu_test_seq(conc_ioaiu_name_array[<%=ioaiu_idx_with_multi_core%>],<%=ioaiu_idx_with_multi_core%>);
                        end
                        #1us;
                        done_snp_cust_seq_h<%=ioaiu_idx%>.trigger(null);
                       `uvm_info("TEST_MAIN", "USE_VIP_SNPS DONE cust_seq_h<%=ioaiu_idx%>[<%=i%>]", UVM_NONE)
                        phase.drop_objection(this, "USE_VIP_SNPS IOAIU<%=ioaiu_idx%> sequence");
         end: _ioaiu<%=ioaiu_idx%>_<%=i%>_vip else begin:_ioaiu<%=ioaiu_idx%>_<%=i%>_inhouse
		        if(ioaiu_en.exists(<%=ioaiu_idx%>)) begin:_ioaiu<%=ioaiu_idx%>_<%=i%>
                          phase.raise_objection(this, "IOAIU<%=ioaiu_idx%>[<%=i%>] sequence");
                        `uvm_info("IOSUBSYS_TEST_SNPS", "Start IOAIU<%=ioaiu_idx%>[<%=i%>] VSEQ", UVM_NONE)
                        fork
                    <% if((obj.AiuInfo[pidx].fnNativeInterface == 'ACE') || (aiu_axiInt[pidx].params.eAc==1) ){ %>
		                    if (iter == 0) m_iosnoop_seq<%=ioaiu_idx%>[<%=i%>].start(null);
                    <% } %>
                        m_iocache_seq<%=ioaiu_idx%>[<%=i%>].start(null);
			            join_any
                        `uvm_info("IOSUBSYS_TEST_SNPS", "Done IOAIU<%=ioaiu_idx%>[<%=i%>] VSEQ", UVM_NONE)
                        //#5us;
                        phase.drop_objection(this, "IOAIU<%=ioaiu_idx%>[<%=i%>] sequence");
                        
          end:_ioaiu<%=ioaiu_idx%>_<%=i%> 
         end:_ioaiu<%=ioaiu_idx%>_<%=i%>_inhouse
                     <% ioaiu_idx_with_multi_core = ioaiu_idx_with_multi_core + 1;} // foreach core%>
          <% ioaiu_idx++; } %>
       <% } // foreach AIUs%>
        begin:_wait_seq_trigger
               fork:_all_master_agents
               <%chiaiu_idx = 0;
               ioaiu_idx = 0;
               for(pidx = 0; pidx < obj.nAIUs; pidx++) {
                   if((obj.AiuInfo[pidx].fnNativeInterface.match("CHI"))) {%>
              	        if(chiaiu_en.exists(<%=chiaiu_idx%>)) begin:_chiaiu<%=chiaiu_idx%>_wait	
                          if (m_concerto_env_cfg.has_chi_vip_snps) begin
                             `uvm_info(get_name(), "USE_VIP_SNPS Waiting on TRAFFIC done_svt_chi_rn_seq_h<%=chiaiu_idx%> to Finish", UVM_LOW) 
                             done_svt_chi_rn_seq_h<%=chiaiu_idx%>.wait_trigger();
                             #25us; //trial to wait for all <##>_RSP
                             //`uvm_info(get_name(), "USE_VIP_SNPS svt_chi_link_service_DN_sequence::START[<%=chiaiu_idx%>]", UVM_LOW)
                             //svt_chi_link_dn_seq_h<%=chiaiu_idx%>.start(m_concerto_env.snps.svt.amba_system_env.chi_system[0].rn[<%=chiaiu_idx%>].link_svc_seqr) ;
                             //done_svt_chi_link_dn_seq_h<%=chiaiu_idx%>.trigger(null);
                             //`uvm_info(get_name(), "USE_VIP_SNPS svt_chi_link_service_DN_sequence::END[<%=chiaiu_idx%>]", UVM_LOW)
                             //`uvm_info(get_name(), "USE_VIP_SNPS Waiting on LINK done_svt_chi_link_dn_seq_h<%=chiaiu_idx%> to Finish", UVM_LOW) 
                             //done_svt_chi_link_dn_seq_h<%=chiaiu_idx%>.wait_trigger();
                          end else begin 
                            ev_chi<%=chiaiu_idx%>_seq_done.wait_trigger();
                          end
                        end:_chiaiu<%=chiaiu_idx%>_wait
               <% chiaiu_idx++;
               } else { %>
               <% for(let i=0; i<aiu_NumCores[pidx]; i++) { %> 
		                 if(ioaiu_en.exists(<%=ioaiu_idx%>)) begin:_ioaiu<%=ioaiu_idx%>_<%=i%>_wait
                           if (m_concerto_env_cfg.has_axi_vip_snps)
                           done_snp_cust_seq_h<%=ioaiu_idx%>.wait_trigger();
                           else ev_ioaiu<%=ioaiu_idx%>_seq_done[<%=i%>].wait_trigger();
                     end:_ioaiu<%=ioaiu_idx%>_<%=i%>_wait
               <% } %> //foreach core %>
               <% ioaiu_idx++; }
               } // foreach AIUs%>
                              //test uncorr error related to zero credit
                          if($test$plusargs("ioaiu_zero_credit") || $test$plusargs("gpra_secure_uncorr_err") || $test$plusargs("chiaiu_zero_credit"))begin
                                uvm_status_e   status;
                                uvm_object objectors_list[$];
                                uvm_objection objection;
                                bit error_dected;
                                fork
                               begin
                                  if($test$plusargs("ioaiu_zero_credit")) begin 
                                    kill_uncorr_test.wait_ptrigger();
                                    #10ns;
                                 end
                                 if($test$plusargs("chiaiu_zero_credit")) begin 
                                    kill_chiaiu_uncorr_test.wait_ptrigger();
                                 end
                                 if ($test$plusargs("gpra_secure_uncorr_err")) begin
                                  kill_uncorr_grar_nsx_test.wait_ptrigger();
                                  //#100ns; 
                                 end
                                  `uvm_info("Concerto_Uncorr_Error_test", $sformatf("decerr event triggered"), UVM_LOW);
                                  // Fetching the objection from current phase
                                  objection = phase.get_objection();
                                  // Collecting all the objectors which currently have objections raised
                                  objection.get_objectors(objectors_list);
                                  // Dropping the objections forcefully
                                  
                                  foreach(objectors_list[i]) begin
                                    uvm_report_info("run_main", $sformatf("objection count %d", objection.get_objection_count(objectors_list[i])),UVM_MEDIUM);
                                    while(objection.get_objection_count(objectors_list[i]) != 0) begin
                                      phase.drop_objection(objectors_list[i], "dropping objections to kill the test");
                                    end
                                  end
                                  `uvm_info("Concerto_Uncorr_Error_test", $sformatf("Jumping to report_phase"), UVM_LOW);
                                  phase.jump(uvm_report_phase::get());

                               //end
                               end
                              join
                          end 
                            //end test zero credit
                     join:_all_master_agents
                     `uvm_info("IOSUBSYS_TEST_SNPS", "All sequences DONE", UVM_NONE)
                     ev_sim_done.trigger(null);
                   end:_wait_seq_trigger
                join:_start_all_seq
                begin
                    #(sim_timeout_ms*1ms);
                    timeout = 1;
                end
      join_any:_exec_fork
      main_seq_iter_post_hook(phase,iter);
      end:_iteration_loop
   phase.drop_objection(this, "exec_inhouse_seq");
  `uvm_info("IOSUBSYS_TEST_SNPS", "END exec_inhouse_seq", UVM_LOW)
endtask: exec_inhouse_seq

task concerto_iosubsys_test_snps::wait_seq_totaly_done(uvm_phase phase);
   phase.raise_objection(this, "wait_seq_totaly_done");
    // No need to WAIT IOIAIU because when seq is finished all the txn are finished

    // Wait end of CHI txn (txn are forked)
    // now the test use main_phase but scb use run_phase
    // to synchronize the both phase wait nbr objection =0 in the chi scb
    // before finish the test main_phase
    <% chi_idx=0;%>
    <% for(pidx = 0; pidx < obj.nAIUs; pidx++) { %>
      <% if(obj.AiuInfo[pidx].fnNativeInterface.match("CHI")) { %>
       if (m_args.chiaiu_scb_en) m_concerto_env.inhouse.m_chiaiu<%=chi_idx%>_env.m_scb.objection.wait_for_total_count( m_concerto_env.inhouse.m_chiaiu<%=chi_idx%>_env.m_scb, 0);
       <%chi_idx++;%>
    <%} // if chi%>
    <%}//foreach aiu%>

    // Wait end of DMI txn
    // now the test use main_phase but scb use run_phase
    // to synchronize the both phase wait nbr objection =0 in the dmi scb
    <% for(pidx = 0; pidx < obj.nDMIs; pidx++) { %>
       if (m_args.dmi_scb_en) m_concerto_env.inhouse.m_dmi<%=pidx%>_env.m_sb.objection.wait_for_total_count( m_concerto_env.inhouse.m_dmi<%=pidx%>_env.m_sb, 0);
    <%}//foreach dmi%>
    
    // Wait end of DII txn
    #10us;
   phase.drop_objection(this, "wait_seq_totaly_done");
endtask:wait_seq_totaly_done

task concerto_iosubsys_test_snps::check_corr_errint_through_alias_reg();
    bit [31:0] data;
    bit [7:0] rpn = 0;

    // There are two conditions: 1. ErrCount >= ErrThreshold, or 2. ErrCount overflowed
<% for(idx = 0, qidx=0; idx < obj.nAIUs; idx++) { 
    if((obj.AiuInfo[idx].fnNativeInterface != 'CHI-A')&&(obj.AiuInfo[idx].fnNativeInterface != 'CHI-B')&&(obj.AiuInfo[idx].fnNativeInterface != 'CHI-E') && (numBootIoAiu > 0)) {%>
    ioaiu<%=BootIoAiu[0]%>_axi_agent_pkg::axi_axaddr_t addr;
    // set csrBaseAddr													
    addr = ncore_config_pkg::ncoreConfigInfo::NRS_REGION_BASE ; //  addr = {<%=obj.AiuInfo[idx].CsrInfo.csrBaseAddress.replace("0x","'h")%>, 8'hFF, 12'h000}; 
<% let pidx_aiu_cores=0%>
<% for(let pidx_aiu = 0; pidx_aiu < obj.nAIUs; pidx_aiu++) {
if((obj.AiuInfo[pidx_aiu].fnNativeInterface != 'CHI-A')&&(obj.AiuInfo[pidx_aiu].fnNativeInterface != 'CHI-B')&&(obj.AiuInfo[idx].fnNativeInterface != 'CHI-E')){ %>
<% for(pidx_aiu_cores = 0; pidx_aiu_cores < aiu_NumCores[pidx_aiu]; pidx_aiu_cores++) {
        // check error counter overflow. IOAIUs idxToAiuWithPC: <%=idxIoAiuWithPC%>
        addr[19:12]=rpn;// Register Page Number
//        addr[11:0] = <%if(idxIoAiuWithPC < obj.nAIUs) {%>m_concerto_env.m_regs.<%=obj.AiuInfo[idxIoAiuWithPC-1].strRtlNamePrefix%>.XAIUCECR.get_offset()<%} else {%> 12'h140 <%}%>; // 12'h<%=getIoOffset("XAIUCECR")%>;
        addr[11:0] = <%if(obj.AiuInfo[pidx_aiu].useCache) {%>m_concerto_env.m_regs.<%=aiuName[pidx_aiu]%>.XAIUCECR.get_offset()<%} else {%> 12'h140 <%}%>; // 12'h<%=getIoOffset("XAIUCECR")%>;
        data = 32'h0000_0002;
        rw_tsks.write_csr<%=BootIoAiu[0]%>(addr,data);
//        addr[11:0] = <%if(idxIoAiuWithPC < obj.nAIUs) {%>m_concerto_env.m_regs.<%=obj.AiuInfo[idxIoAiuWithPC-1].strRtlNamePrefix%>.XAIUCESAR.get_offset()<%} else {%> 12'h150 <%}%>; // 12'h<%=getIoOffset("XAIUCESAR")%>;
        addr[11:0] = <%if(obj.AiuInfo[pidx_aiu].useCache) {%>m_concerto_env.m_regs.<%=aiuName[pidx_aiu]%>.XAIUCESAR.get_offset()<%} else {%> 12'h150 <%}%>; // 12'h<%=getIoOffset("XAIUCESAR")%>;
        data = 32'h0000_03ff; // errCount=8'hff, Overflow=1, ErrVld=1
        rw_tsks.write_csr<%=BootIoAiu[0]%>(addr,data);
       `uvm_info($sformatf("%m"),$sformatf("IRQ_C alias write for <%=obj.AiuInfo[pidx_aiu].strRtlNamePrefix%> addr=%0h data=%0h",addr, data), UVM_NONE)
        
        // wait for IRQ_C interrupt 
        fork
        begin
          wait(tb_top.m_irq_if_<%=obj.AiuInfo[pidx_aiu].strRtlNamePrefix%>.c === 1);
          //wait (aiu_csr_probe_vif_<%=obj.AiuInfo[pidx_aiu].strRtlNamePrefix%>.IRQ_C === 1);
          `uvm_info(get_full_name(),"Seen IRQ_C for <%=obj.AiuInfo[pidx_aiu].strRtlNamePrefix%>",UVM_NONE)
        end
        begin
          #200ns;
          `uvm_error(get_full_name(),$sformatf("Timeout! Did not see IRQ_C asserted for AIU_<%=obj.AiuInfo[pidx_aiu].strRtlNamePrefix%>"));
        end
        join_any
        disable fork;

//        addr[11:0] = <%if(idxIoAiuWithPC < obj.nAIUs) {%>m_concerto_env.m_regs.<%=obj.AiuInfo[idxIoAiuWithPC-1].strRtlNamePrefix%>.XAIUCECR.get_offset()<%} else {%> 12'h140 <%}%>; // 12'h<%=getIoOffset("XAIUCECR")%>;
        addr[11:0] = <%if(obj.AiuInfo[pidx_aiu].useCache) {%>m_concerto_env.m_regs.<%=aiuName[pidx_aiu]%>.XAIUCECR.get_offset()<%} else {%> 12'h140 <%}%>; // 12'h<%=getIoOffset("XAIUCECR")%>;
        data = 32'h0000_0000;
        rw_tsks.write_csr<%=BootIoAiu[0]%>(addr,data);
//        addr[11:0] = <%if(idxIoAiuWithPC < obj.nAIUs) {%>m_concerto_env.m_regs.<%=obj.AiuInfo[idxIoAiuWithPC-1].strRtlNamePrefix%>.XAIUCESAR.get_offset()<%} else {%> 12'h150 <%}%>; // 12'h<%=getIoOffset("XAIUCESAR")%>;
        addr[11:0] = <%if(obj.AiuInfo[pidx_aiu].useCache) {%>m_concerto_env.m_regs.<%=aiuName[pidx_aiu]%>.XAIUCESAR.get_offset()<%} else {%> 12'h150 <%}%>; // 12'h<%=getIoOffset("XAIUCESAR")%>;
        data = 32'h0000_0000;
        rw_tsks.write_csr<%=BootIoAiu[0]%>(addr,data);
       `uvm_info($sformatf("%m"),$sformatf("IRQ_C alias write for <%=obj.AiuInfo[pidx_aiu].strRtlNamePrefix%> addr=%0h data=%0h",addr, data), UVM_NONE)

        // wait for IRQ_C interrupt 
        fork
        begin
          wait(tb_top.m_irq_if_<%=obj.AiuInfo[pidx_aiu].strRtlNamePrefix%>.c === 0);
          //wait (aiu_csr_probe_vif_<%=obj.AiuInfo[pidx_aiu].strRtlNamePrefix%>.IRQ_C === 1);
          `uvm_info(get_full_name(),"Seen IRQ_C de-asserted for <%=obj.AiuInfo[pidx_aiu].strRtlNamePrefix%>",UVM_NONE)
        end
        begin
          #200ns;
          `uvm_error(get_full_name(),$sformatf("Timeout! Did not see IRQ_C de-asserted for AIU_<%=obj.AiuInfo[pidx_aiu].strRtlNamePrefix%>"));
        end
        join_any
        disable fork;

        // check error count >= threshold
        addr[19:12]=rpn;// Register Page Number
//        addr[11:0] = <%if(idxIoAiuWithPC < obj.nAIUs) {%>m_concerto_env.m_regs.<%=obj.AiuInfo[idxIoAiuWithPC-1].strRtlNamePrefix%>.XAIUCECR.get_offset()<%} else {%> 12'h140 <%}%>; // 12'h<%=getIoOffset("XAIUCECR")%>;
        addr[11:0] = <%if(obj.AiuInfo[pidx_aiu].useCache) {%>m_concerto_env.m_regs.<%=aiuName[pidx_aiu]%>.XAIUCECR.get_offset()<%} else {%> 12'h140 <%}%>; // 12'h<%=getIoOffset("XAIUCECR")%>;
        data = 32'h0000_0002;
        rw_tsks.write_csr<%=BootIoAiu[0]%>(addr,data);
//        addr[11:0] = <%if(idxIoAiuWithPC < obj.nAIUs) {%>m_concerto_env.m_regs.<%=obj.AiuInfo[idxIoAiuWithPC-1].strRtlNamePrefix%>.XAIUCESAR.get_offset()<%} else {%> 12'h150 <%}%>; // 12'h<%=getIoOffset("XAIUCESAR")%>;
        addr[11:0] = <%if(obj.AiuInfo[pidx_aiu].useCache) {%>m_concerto_env.m_regs.<%=aiuName[pidx_aiu]%>.XAIUCESAR.get_offset()<%} else {%> 12'h150 <%}%>; // 12'h<%=getIoOffset("XAIUCESAR")%>;
        data = 32'h0000_0007; // errCount=8'h01, Overflow=1, ErrVld=1
        rw_tsks.write_csr<%=BootIoAiu[0]%>(addr,data);
       `uvm_info($sformatf("%m"),$sformatf("IRQ_C alias write (1) for <%=obj.AiuInfo[pidx_aiu].strRtlNamePrefix%> addr=%0h data=%0h",addr, data), UVM_NONE)
        // need to write alias register twice
        rw_tsks.write_csr<%=BootIoAiu[0]%>(addr,data);
       `uvm_info($sformatf("%m"),$sformatf("IRQ_C alias write (2) for <%=obj.AiuInfo[pidx_aiu].strRtlNamePrefix%> addr=%0h data=%0h",addr, data), UVM_NONE)
        
        // wait for IRQ_C interrupt 
        fork
        begin
          wait(tb_top.m_irq_if_<%=obj.AiuInfo[pidx_aiu].strRtlNamePrefix%>.c === 1);
          //wait (aiu_csr_probe_vif_<%=obj.AiuInfo[pidx_aiu].strRtlNamePrefix%>.IRQ_C === 1);
          `uvm_info(get_full_name(),"Seen IRQ_C for <%=obj.AiuInfo[pidx_aiu].strRtlNamePrefix%>",UVM_NONE)
        end
        begin
          #200ns;
          `uvm_error(get_full_name(),$sformatf("Timeout! Did not see IRQ_C asserted for AIU_<%=obj.AiuInfo[pidx_aiu].strRtlNamePrefix%>"));
        end
        join_any
        disable fork;

//        addr[11:0] = <%if(idxIoAiuWithPC < obj.nAIUs) {%>m_concerto_env.m_regs.<%=obj.AiuInfo[idxIoAiuWithPC-1].strRtlNamePrefix%>.XAIUCECR.get_offset()<%} else {%> 12'h140 <%}%>; // 12'h<%=getIoOffset("XAIUCECR")%>;
        addr[11:0] = <%if(obj.AiuInfo[pidx_aiu].useCache) {%>m_concerto_env.m_regs.<%=aiuName[pidx_aiu]%>.XAIUCECR.get_offset()<%} else {%> 12'h140 <%}%>; // 12'h<%=getIoOffset("XAIUCECR")%>;
        data = 32'h0000_0000;
        rw_tsks.write_csr<%=BootIoAiu[0]%>(addr,data);
//        addr[11:0] = <%if(idxIoAiuWithPC < obj.nAIUs) {%>m_concerto_env.m_regs.<%=obj.AiuInfo[idxIoAiuWithPC-1].strRtlNamePrefix%>.XAIUCESAR.get_offset()<%} else {%> 12'h150 <%}%>; // 12'h<%=getIoOffset("XAIUCESAR")%>;
        addr[11:0] = <%if(obj.AiuInfo[pidx_aiu].useCache) {%>m_concerto_env.m_regs.<%=aiuName[pidx_aiu]%>.XAIUCESAR.get_offset()<%} else {%> 12'h150 <%}%>; // 12'h<%=getIoOffset("XAIUCESAR")%>;
        data = 32'h0000_0000;
        rw_tsks.write_csr<%=BootIoAiu[0]%>(addr,data);
       `uvm_info($sformatf("%m"),$sformatf("IRQ_C alias write for <%=obj.AiuInfo[pidx_aiu].strRtlNamePrefix%> addr=%0h data=%0h",addr, data), UVM_NONE)

        // wait for IRQ_C interrupt 
        fork
        begin
          wait(tb_top.m_irq_if_<%=obj.AiuInfo[pidx_aiu].strRtlNamePrefix%>.c === 0);
          //wait (aiu_csr_probe_vif_<%=obj.AiuInfo[pidx_aiu].strRtlNamePrefix%>.IRQ_C === 1);
          `uvm_info(get_full_name(),"Seen IRQ_C de-asserted for <%=obj.AiuInfo[pidx_aiu].strRtlNamePrefix%>",UVM_NONE)
        end
        begin
          #200ns;
          `uvm_error(get_full_name(),$sformatf("Timeout! Did not see IRQ_C de-asserted for AIU_<%=obj.AiuInfo[pidx_aiu].strRtlNamePrefix%>"));
        end
        join_any
        disable fork;

                                                                                                                
        //repeat entire process
//        addr[11:0] = <%if(idxIoAiuWithPC < obj.nAIUs) {%>m_concerto_env.m_regs.<%=obj.AiuInfo[idxIoAiuWithPC-1].strRtlNamePrefix%>.XAIUCECR.get_offset()<%} else {%> 12'h140 <%}%>; // 12'h<%=getIoOffset("XAIUCECR")%>;
        addr[11:0] = <%if(obj.AiuInfo[pidx_aiu].useCache) {%>m_concerto_env.m_regs.<%=aiuName[pidx_aiu]%>.XAIUCECR.get_offset()<%} else {%> 12'h140 <%}%>; // 12'h<%=getIoOffset("XAIUCECR")%>;
        data = 32'h0000_0002;
        rw_tsks.write_csr<%=BootIoAiu[0]%>(addr,data);
//        addr[11:0] = <%if(idxIoAiuWithPC < obj.nAIUs) {%>m_concerto_env.m_regs.<%=obj.AiuInfo[idxIoAiuWithPC-1].strRtlNamePrefix%>.XAIUCESAR.get_offset()<%} else {%> 12'h150 <%}%>; // 12'h<%=getIoOffset("XAIUCESAR")%>;
        addr[11:0] = <%if(obj.AiuInfo[pidx_aiu].useCache) {%>m_concerto_env.m_regs.<%=aiuName[pidx_aiu]%>.XAIUCESAR.get_offset()<%} else {%> 12'h150 <%}%>; // 12'h<%=getIoOffset("XAIUCESAR")%>;
        data = 32'h0000_03ff;
        rw_tsks.write_csr<%=BootIoAiu[0]%>(addr,data);
        
        // wait for IRQ_C interrupt 
        fork
        begin
          wait(tb_top.m_irq_if_<%=obj.AiuInfo[pidx_aiu].strRtlNamePrefix%>.c === 1);
          //wait (aiu_csr_probe_vif_<%=obj.AiuInfo[pidx_aiu].strRtlNamePrefix%>.IRQ_C === 1);
          `uvm_info(get_full_name(),"Seen IRQ_C for <%=obj.AiuInfo[pidx_aiu].strRtlNamePrefix%>",UVM_NONE)
        end
        begin
          #200ns;
          `uvm_error(get_full_name(),$sformatf("Timeout! Did not see IRQ_C asserted for AIU_<%=obj.AiuInfo[pidx_aiu].strRtlNamePrefix%>"));
        end
        join_any
        disable fork;

//        addr[11:0] = <%if(idxIoAiuWithPC < obj.nAIUs) {%>m_concerto_env.m_regs.<%=obj.AiuInfo[idxIoAiuWithPC-1].strRtlNamePrefix%>.XAIUCECR.get_offset()<%} else {%> 12'h140 <%}%>; // 12'h<%=getIoOffset("XAIUCECR")%>;
        addr[11:0] = <%if(obj.AiuInfo[pidx_aiu].useCache) {%>m_concerto_env.m_regs.<%=aiuName[pidx_aiu]%>.XAIUCECR.get_offset()<%} else {%> 12'h140 <%}%>; // 12'h<%=getIoOffset("XAIUCECR")%>;        data = 32'h0000_0000;
        rw_tsks.write_csr<%=BootIoAiu[0]%>(addr,data);
//        addr[11:0] = <%if(idxIoAiuWithPC < obj.nAIUs) {%>m_concerto_env.m_regs.<%=obj.AiuInfo[idxIoAiuWithPC-1].strRtlNamePrefix%>.XAIUCESAR.get_offset()<%} else {%> 12'h150 <%}%>; // 12'h<%=getIoOffset("XAIUCESAR")%>;
        addr[11:0] = <%if(obj.AiuInfo[pidx_aiu].useCache) {%>m_concerto_env.m_regs.<%=aiuName[pidx_aiu]%>.XAIUCESAR.get_offset()<%} else {%> 12'h150 <%}%>; // 12'h<%=getIoOffset("XAIUCESAR")%>;
        data = 32'h0000_0000;
        rw_tsks.write_csr<%=BootIoAiu[0]%>(addr,data);

        // wait for IRQ_C interrupt 
        fork
        begin
          wait(tb_top.m_irq_if_<%=obj.AiuInfo[pidx_aiu].strRtlNamePrefix%>.c === 0);
          //wait (aiu_csr_probe_vif_<%=obj.AiuInfo[pidx_aiu].strRtlNamePrefix%>.IRQ_C === 1);
          `uvm_info(get_full_name(),"Seen IRQ_C de-asserted for <%=obj.AiuInfo[pidx_aiu].strRtlNamePrefix%>",UVM_NONE)
        end
        begin
          #200ns;
          `uvm_error(get_full_name(),$sformatf("Timeout! Did not see IRQ_C de-asserted for AIU_<%=obj.AiuInfo[pidx_aiu].strRtlNamePrefix%>"));
        end
        join_any
        disable fork;

        rpn++;
<% } %>
<% } else { %>
        rpn++;
<% } %>
<% } %>
<% for(let pidx_dce = 0; pidx_dce < obj.nDCEs; pidx_dce++) { %>
        addr[19:12]=rpn;// Register Page Number
        addr[11:0] = m_concerto_env.m_regs.<%=obj.DceInfo[0].strRtlNamePrefix%>.DCEUCECR.get_offset(); // 12'h<%=getIoOffset("DCEUCECR")%>;
        data = 32'h0000_0002;
        rw_tsks.write_csr<%=BootIoAiu[0]%>(addr,data);
        addr[11:0] = m_concerto_env.m_regs.<%=obj.DceInfo[0].strRtlNamePrefix%>.DCEUCESAR.get_offset(); // 12'h<%=getIoOffset("DCEUCESAR")%>;
        data = 32'h0000_0001;
        rw_tsks.write_csr<%=BootIoAiu[0]%>(addr,data);
        
        // wait for IRQ_C interrupt 
        fork
        begin
          wait(tb_top.m_irq_if_<%=obj.DceInfo[pidx_dce].strRtlNamePrefix%>.c === 1);
          //wait (aiu_csr_probe_vif_<%=obj.DceInfo[pidx_dce].strRtlNamePrefix%>.IRQ_C === 1);
          `uvm_info(get_full_name(),"Seen IRQ_C for <%=obj.DceInfo[pidx_dce].strRtlNamePrefix%>",UVM_NONE)
        end
        begin
          #200ns;
          `uvm_error(get_full_name(),$sformatf("Timeout! Did not see IRQ_C asserted for <%=obj.DceInfo[pidx_dce].strRtlNamePrefix%>"));
        end
        join_any
        disable fork;

        addr[11:0] = m_concerto_env.m_regs.<%=obj.DceInfo[0].strRtlNamePrefix%>.DCEUCECR.get_offset(); // 12'h<%=getIoOffset("DCEUCECR")%>;
        data = 32'h0000_0000;
        rw_tsks.write_csr<%=BootIoAiu[0]%>(addr,data);
        addr[11:0] = m_concerto_env.m_regs.<%=obj.DceInfo[0].strRtlNamePrefix%>.DCEUCESAR.get_offset(); // 12'h<%=getIoOffset("DCEUCESAR")%>;
        data = 32'h0000_0000;
        rw_tsks.write_csr<%=BootIoAiu[0]%>(addr,data);

        // wait for IRQ_C interrupt 
        fork
        begin
          wait(tb_top.m_irq_if_<%=obj.DceInfo[pidx_dce].strRtlNamePrefix%>.c === 0);
          //wait (aiu_csr_probe_vif_<%=obj.DceInfo[pidx_dce].strRtlNamePrefix%>.IRQ_C === 1);
          `uvm_info(get_full_name(),"Seen IRQ_C de-asserted for <%=obj.DceInfo[pidx_dce].strRtlNamePrefix%>",UVM_NONE)
        end
        begin
          #200ns;
          `uvm_error(get_full_name(),$sformatf("Timeout! Did not see IRQ_C de-asserted for <%=DceInfo[pidx_dce].strRtlNamePrefix%>"));
        end
        join_any
        disable fork;

        //repeat again
        addr[11:0] = m_concerto_env.m_regs.<%=obj.DceInfo[0].strRtlNamePrefix%>.DCEUCECR.get_offset(); // 12'h<%=getIoOffset("DCEUCECR")%>;
        data = 32'h0000_0002;
        rw_tsks.write_csr<%=BootIoAiu[0]%>(addr,data);
        addr[11:0] = m_concerto_env.m_regs.<%=obj.DceInfo[0].strRtlNamePrefix%>.DCEUCESAR.get_offset(); // 12'h<%=getIoOffset("DCEUCESAR")%>;
        data = 32'h0000_0001;
        rw_tsks.write_csr<%=BootIoAiu[0]%>(addr,data);
        
        // wait for IRQ_C interrupt 
        fork
        begin
          wait(tb_top.m_irq_if_<%=obj.DceInfo[pidx_dce].strRtlNamePrefix%>.c === 1);
          //wait (aiu_csr_probe_vif_<%=obj.DceInfo[pidx_dce].strRtlNamePrefix%>.IRQ_C === 1);
          `uvm_info(get_full_name(),"Seen IRQ_C for <%=obj.DceInfo[pidx_dce].strRtlNamePrefix%>",UVM_NONE)
        end
        begin
          #200ns;
          `uvm_error(get_full_name(),$sformatf("Timeout! Did not see IRQ_C asserted for <%=obj.DceInfo[pidx_dce].strRtlNamePrefix%>"));
        end
        join_any
        disable fork;

        addr[11:0] = m_concerto_env.m_regs.<%=obj.DceInfo[0].strRtlNamePrefix%>.DCEUCECR.get_offset(); // 12'h<%=getIoOffset("DCEUCECR")%>;
        data = 32'h0000_0000;
        rw_tsks.write_csr<%=BootIoAiu[0]%>(addr,data);
        addr[11:0] = m_concerto_env.m_regs.<%=obj.DceInfo[0].strRtlNamePrefix%>.DCEUCESAR.get_offset(); // 12'h<%=getIoOffset("DCEUCESAR")%>;
        data = 32'h0000_0000;
        rw_tsks.write_csr<%=BootIoAiu[0]%>(addr,data);

        // wait for IRQ_C interrupt 
        fork
        begin
          wait(tb_top.m_irq_if_<%=obj.DceInfo[pidx_dce].strRtlNamePrefix%>.c === 0);
          //wait (aiu_csr_probe_vif_<%=obj.DceInfo[pidx_dce].strRtlNamePrefix%>.IRQ_C === 1);
          `uvm_info(get_full_name(),"Seen IRQ_C de-asserted for <%=obj.DceInfo[pidx_dce].strRtlNamePrefix%>",UVM_NONE)
        end
        begin
          #200ns;
          `uvm_error(get_full_name(),$sformatf("Timeout! Did not see IRQ_C de-asserted for <%=DceInfo[pidx_dce].strRtlNamePrefix%>"));
        end
        join_any
        disable fork;

        rpn++;
<% } %>
<% for(let pidx_dmi = 0; pidx_dmi < obj.nDMIs; pidx_dmi++) { %>
        addr[19:12]=rpn;// Register Page Number
        addr[11:0] = m_concerto_env.m_regs.<%=obj.DmiInfo[idxDmiWithSMC].strRtlNamePrefix%>.DMIUCECR.get_offset(); // 12'h<%=getIoOffset("DMIUCECR")%>;
        data = 32'h0000_0002;
        rw_tsks.write_csr<%=BootIoAiu[0]%>(addr,data);
        addr[11:0] = m_concerto_env.m_regs.<%=obj.DmiInfo[idxDmiWithSMC].strRtlNamePrefix%>.DMIUCESAR.get_offset(); // 12'h<%=getIoOffset("DMIUCESAR")%>;
        data = 32'h0000_0001;
        rw_tsks.write_csr<%=BootIoAiu[0]%>(addr,data);
        
        // wait for IRQ_C interrupt 
        fork
        begin
          wait(tb_top.m_irq_if_<%=obj.DmiInfo[pidx_dmi].strRtlNamePrefix%>.c === 1);
          //wait (aiu_csr_probe_vif_<%=obj.DmiInfo[pidx_dmi].strRtlNamePrefix%>.IRQ_C === 1);
          `uvm_info(get_full_name(),"Seen IRQ_C for <%=obj.DmiInfo[pidx_dmi].strRtlNamePrefix%>",UVM_NONE)
        end
        begin
          #200ns;
          `uvm_error(get_full_name(),$sformatf("Timeout! Did not see IRQ_C asserted for <%=obj.DmiInfo[pidx_dmi].strRtlNamePrefix%>"));
        end
        join_any
        disable fork;

        addr[11:0] = m_concerto_env.m_regs.<%=obj.DmiInfo[idxDmiWithSMC].strRtlNamePrefix%>.DMIUCECR.get_offset(); // 12'h<%=getIoOffset("DMIUCECR")%>;
        data = 32'h0000_0000;
        rw_tsks.write_csr<%=BootIoAiu[0]%>(addr,data);
        addr[11:0] = m_concerto_env.m_regs.<%=obj.DmiInfo[idxDmiWithSMC].strRtlNamePrefix%>.DMIUCESAR.get_offset(); // 12'h<%=getIoOffset("DMIUCESAR")%>;
        data = 32'h0000_0000;
        rw_tsks.write_csr<%=BootIoAiu[0]%>(addr,data);

        // wait for IRQ_C interrupt 
        fork
        begin
          wait(tb_top.m_irq_if_<%=obj.DmiInfo[pidx_dmi].strRtlNamePrefix%>.c === 0);
          //wait (aiu_csr_probe_vif_<%=obj.DmiInfo[pidx_dmi].strRtlNamePrefix%>.IRQ_C === 1);
          `uvm_info(get_full_name(),"Seen IRQ_C de-asserted for <%=obj.DmiInfo[pidx_dmi].strRtlNamePrefix%>",UVM_NONE)
        end
        begin
          #200ns;
          `uvm_error(get_full_name(),$sformatf("Timeout! Did not see IRQ_C de-asserted for <%=DmiInfo[pidx_dmi].strRtlNamePrefix%>"));
        end
        join_any
        disable fork;

        //repeat again
        addr[11:0] = m_concerto_env.m_regs.<%=obj.DmiInfo[idxDmiWithSMC].strRtlNamePrefix%>.DMIUCECR.get_offset(); // 12'h<%=getIoOffset("DMIUCECR")%>;
        data = 32'h0000_0002;
        rw_tsks.write_csr<%=BootIoAiu[0]%>(addr,data);
        addr[11:0] = m_concerto_env.m_regs.<%=obj.DmiInfo[idxDmiWithSMC].strRtlNamePrefix%>.DMIUCESAR.get_offset(); // 12'h<%=getIoOffset("DMIUCESAR")%>;
        data = 32'h0000_0001;
        rw_tsks.write_csr<%=BootIoAiu[0]%>(addr,data);
        
        // wait for IRQ_C interrupt 
        fork
        begin
          wait(tb_top.m_irq_if_<%=obj.DmiInfo[pidx_dmi].strRtlNamePrefix%>.c === 1);
          //wait (aiu_csr_probe_vif_<%=obj.DmiInfo[pidx_dmi].strRtlNamePrefix%>.IRQ_C === 1);
          `uvm_info(get_full_name(),"Seen IRQ_C for <%=obj.DmiInfo[pidx_dmi].strRtlNamePrefix%>",UVM_NONE)
        end
        begin
          #200ns;
          `uvm_error(get_full_name(),$sformatf("Timeout! Did not see IRQ_C asserted for <%=obj.DmiInfo[pidx_dmi].strRtlNamePrefix%>"));
        end
        join_any
        disable fork;

        addr[11:0] = m_concerto_env.m_regs.<%=obj.DmiInfo[idxDmiWithSMC].strRtlNamePrefix%>.DMIUCECR.get_offset(); // 12'h<%=getIoOffset("DMIUCECR")%>;
        data = 32'h0000_0000;
        rw_tsks.write_csr<%=BootIoAiu[0]%>(addr,data);
        addr[11:0] = m_concerto_env.m_regs.<%=obj.DmiInfo[idxDmiWithSMC].strRtlNamePrefix%>.DMIUCESAR.get_offset(); // 12'h<%=getIoOffset("DMIUCESAR")%>;
        data = 32'h0000_0000;
        rw_tsks.write_csr<%=BootIoAiu[0]%>(addr,data);

        // wait for IRQ_C interrupt 
        fork
        begin
          wait(tb_top.m_irq_if_<%=obj.DmiInfo[pidx_dmi].strRtlNamePrefix%>.c === 0);
          //wait (aiu_csr_probe_vif_<%=obj.DmiInfo[pidx_dmi].strRtlNamePrefix%>.IRQ_C === 1);
          `uvm_info(get_full_name(),"Seen IRQ_C de-asserted for <%=obj.DmiInfo[pidx_dmi].strRtlNamePrefix%>",UVM_NONE)
        end
        begin
          #200ns;
          `uvm_error(get_full_name(),$sformatf("Timeout! Did not see IRQ_C de-asserted for <%=DmiInfo[pidx_dmi].strRtlNamePrefix%>"));
        end
        join_any
        disable fork;

        rpn++;
<% } %>
     <% break; %>
        <% } %>
     <% qidx++; %>
<% } %>
  
endtask: check_corr_errint_through_alias_reg

task concerto_iosubsys_test_snps::inject_error_all_dmi_smc();
<%for(pidx= 0; pidx < obj.nDMIs; pidx++) { if(obj.DmiInfo[pidx].useCmc) {%>
   inject_error_dmi<%=pidx%>_smc();
<%}}%>
endtask : inject_error_all_dmi_smc

<%for(pidx= 0; pidx < obj.nDMIs; pidx++) { if(obj.DmiInfo[pidx].useCmc) {%>
task concerto_iosubsys_test_snps::inject_error_dmi<%=pidx%>_smc();
    ev_inject_error_dmi<%=pidx%>_smc.trigger();
endtask : inject_error_dmi<%=pidx%>_smc
<%}}%>



`ifdef USE_STL_TRACE
task concerto_iosubsys_test_snps::stl_csr_write();
    int cycle, data;
    bit[127:0] address;
    integer outfile0;
    string line,trans_type,wait_st,rsp_st,burst_type,data_type;
    string CACHE, BUF,CACHE_WR_ALOC, CACHE_RD_ALOC, DOMAIN, LOCK, QOS,SNOOP;
    int CACHE_t, BUF_t,CACHE_WR_ALOC_t, CACHE_RD_ALOC_t, DOMAIN_t, LOCK_t, QOS_t,SNOOP_t;
    string regex,idle;
    int idle_cnt;
    string stl_file_name;

    `ifdef STL_FILE_FULL_PATH  
    `define STRING_STL_FILE_FULL_PATH `"`STL_FILE_FULL_PATH`"
    `uvm_info("STL::AXI",$psprintf("STL::starting stl AXI transactions %s ",`STRING_STL_FILE_FULL_PATH),UVM_NONE)
    `endif
    stl_file_name ="reg.stl";
    outfile0=$fopen({`STRING_STL_FILE_FULL_PATH,stl_file_name},"r");

    if(outfile0) `uvm_info(get_name(),$psprintf("STL::REG file opened successfully"),UVM_NONE)
    else `uvm_error(get_full_name(),$sformatf("STL::REG unable to open STL file for register configurations"));

    while(!$feof(outfile0)) begin 
       $fgets (line, outfile0); //Get entire comment line
       `uvm_info(get_name(),$psprintf("STL::REG comment line %s",line),UVM_NONE)
       regex="Waiting for SysCoAttached";
       if(!(uvm_re_match(regex,line))) begin
          $fscanf(outfile0,"%s %0d",idle,idle_cnt) ;
          `uvm_info(get_name(),$psprintf("STL::REG inserting idle cycles %0d",idle_cnt),UVM_NONE)
          repeat(idle_cnt) begin//SysCoAttach_delay
    <% 
      ioaiu_idx = 0;
   %>
  <% for(pidx= 0 ; pidx < obj.nAIUs; pidx++) { %>
      <% if((!((obj.AiuInfo[pidx].fnNativeInterface == 'CHI-A') || (obj.AiuInfo[pidx].fnNativeInterface == 'CHI-B')|| (obj.AiuInfo[pidx].fnNativeInterface == 'CHI-E')) && (ioaiu_idx==0))) { %>
          ioaiu_clk_posedge_e_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_0.wait_trigger();// 
    <% ioaiu_idx++;
    } %>
   <% } %>
          end
          $fgets (line, outfile0); //Get info 
          `uvm_info(get_name(),$psprintf("STL::Added idle cycles %s",line),UVM_NONE)
       end else begin
          $fscanf(outfile0," %d  %s %h  %s %h %s %s %s %s %s %s %s %s", cycle, trans_type,address,data_type,data,CACHE,BUF,CACHE_WR_ALOC,CACHE_RD_ALOC,DOMAIN,LOCK,SNOOP,QOS);

          if (($sscanf(CACHE, "CACHE:%d", CACHE_t) == 1) && ($sscanf(BUF, "BUF:%d", BUF_t) == 1) && ($sscanf(CACHE_WR_ALOC, "CACHE_WR_ALOC:%d", CACHE_WR_ALOC_t) == 1) && ($sscanf(CACHE_RD_ALOC, "CACHE_RD_ALOC:%d", CACHE_RD_ALOC_t) == 1) && ($sscanf(DOMAIN, "DOMAIN:%d", DOMAIN_t) == 1) && ($sscanf(LOCK, "LOCK:%d", LOCK_t) == 1) && ($sscanf(QOS, "QOS:%d", QOS_t) == 1))

        `uvm_info(get_name(),$psprintf("STL::REG timestamp= %0h axi transaction= %s awaddr= %0h wdata= %0h CACHE=%0h BUF=%0h CACHE_WR_ALOC=%0h CACHE_RD_ALOC=%0h DOMAIN=%0h LOCK=%0h SNOOP=%0h QOS=%0h", cycle, trans_type,address,data,CACHE_t,BUF_t,CACHE_WR_ALOC_t,CACHE_RD_ALOC_t,DOMAIN_t,LOCK_t,SNOOP_t,QOS_t),UVM_NONE)
       $fgets (line, outfile0); //Get info 
       `uvm_info(get_name(),$psprintf("STL::REG INFO line %s",line),UVM_NONE)
       rw_tsks.write_csr0(address,data,0);
       end
    end
endtask
`endif //USE_STL_TRACE

task concerto_iosubsys_test_snps::gen_addr_use_user_addrq();

    `uvm_info(get_name(), $psprintf("plusarg use_user_addrq is enabled, use_user_addrq value from plusarg %0d",use_user_addrq), UVM_LOW)
    <% if ( obj.initiatorGroups.length >= 1) { %>
    <% for(pidx = 0; pidx < obj.nAIUs; pidx++) { %>
    addr_mgr.gen_user_noncoh_addr(<%=obj.AiuInfo[pidx].FUnitId%>, use_user_addrq/<%=obj.nAIUs%>, ncoreConfigInfo::user_addrq[ncoreConfigInfo::NONCOH]);  <% } %>
    <% } else { %>
    addr_mgr.gen_user_noncoh_addr(<%=obj.AiuInfo[0].FUnitId%>, use_user_addrq, ncoreConfigInfo::user_addrq[ncoreConfigInfo::NONCOH]);
    <% } %>
    `uvm_info(get_name(), $psprintf("Initial ncoreConfigInfo::user_addrq[ncoreConfigInfo::NONCOH] size %0d ncoreConfigInfo::user_addrq[ncoreConfigInfo::COH] size %0d",ncoreConfigInfo::user_addrq[ncoreConfigInfo::NONCOH].size(),ncoreConfigInfo::user_addrq[ncoreConfigInfo::COH].size()), UVM_HIGH)
    if($test$plusargs("perf_test")) begin:_perf_test
        if($test$plusargs("write_test")) begin:_write_test
            if($test$plusargs("non_dmi_intlv")) begin
                          addr_mgr.gen_seq_write_addr_in_user_addrq(use_user_addrq, 256, 1, 0, ncoreConfigInfo::user_addrq[ncoreConfigInfo::COH]);
            end else begin
                          addr_mgr.gen_seq_write_addr_in_user_addrq(use_user_addrq, 256, 0, 1, ncoreConfigInfo::user_addrq[ncoreConfigInfo::COH]);
            end
        end:_write_test else begin: _no_write_test
            if($test$plusargs("non_dmi_intlv")) begin
              addr_mgr.gen_seq_addr_in_user_addrq(use_user_addrq, 64, 1, -1, ncoreConfigInfo::user_addrq[ncoreConfigInfo::COH]);
            end else begin
              addr_mgr.gen_seq_addr_in_user_addrq(use_user_addrq, 64, 0, -1, ncoreConfigInfo::user_addrq[ncoreConfigInfo::COH]);
            end
        end:_no_write_test
        `uvm_info(get_name(), $psprintf("perf_test plusarg is on, Final ncoreConfigInfo::user_addrq[ncoreConfigInfo::NONCOH] size %0d ncoreConfigInfo::user_addrq[ncoreConfigInfo::COH] size %0d",ncoreConfigInfo::user_addrq[ncoreConfigInfo::NONCOH].size(),ncoreConfigInfo::user_addrq[ncoreConfigInfo::COH].size()), UVM_LOW)
    end:_perf_test else begin:_no_perf_test

         if($test$plusargs("dce_fix_index")) begin
            int dummy_csrq_idx;
            randcase
            <% for(pidx = 0; pidx < obj.nDCEs; pidx++) { let maxWay = 0; obj.DceInfo[pidx].SnoopFilterInfo.forEach(function FindMax(item){maxWay = (maxWay<item.nWays) ? item.nWays : maxWay;});%>
            1 : addr_mgr.set_dce_sf_fix_index_in_user_addrq(<%=obj.DceInfo[pidx].nUnitId%>, ncoreConfigInfo::user_addrq[ncoreConfigInfo::COH],dummy_csrq_idx);
            <% } %>
            endcase
            `uvm_info(get_name(), $psprintf("dce_fix_index plusarg is on, Final ncoreConfigInfo::user_addrq[ncoreConfigInfo::NONCOH] size %0d ncoreConfigInfo::user_addrq[ncoreConfigInfo::COH] size %0d",ncoreConfigInfo::user_addrq[ncoreConfigInfo::NONCOH].size(),ncoreConfigInfo::user_addrq[ncoreConfigInfo::COH].size()), UVM_LOW)

         end else if($test$plusargs("dmi_fix_index") || $test$plusargs("en_excl_txn") || $test$plusargs("en_excl_noncoh_txn")) begin

            if($test$plusargs("dmi_fix_index")) begin
                <%
                for (pidx = 0; pidx < obj.nDMIs; pidx++)
                if (obj.DmiInfo[pidx].useCmc) { %>
                randcase
                <% for(pidx = 0; pidx < obj.nDMIs; pidx++) { let maxWay = 0; if(obj.DmiInfo[pidx].useCmc){obj.DmiInfo[pidx].ccpParams.PriSubDiagAddrBits.forEach(function FindMax(item){maxWay = (maxWay<item.nWays) ? item.nWays : maxWay;});%>
                1 : begin addr_mgr.set_dmi_smc_fix_index_in_user_addrq(<%=obj.DmiInfo[pidx].nUnitId%>, ncoreConfigInfo::user_addrq[ncoreConfigInfo::COH], 1); 
                // #Stimulus.FSYS.sysevent.coh_txn.pre-v3.4
                          if($test$plusargs("en_excl_txn"))
                             ncoreConfigInfo::user_addrq[ncoreConfigInfo::COH] = ncoreConfigInfo::user_addrq[ncoreConfigInfo::COH][0:0]; 
                          ncoreConfigInfo::user_addrq[ncoreConfigInfo::NONCOH] = {};
                          addr_mgr.set_dmi_smc_fix_index_in_user_addrq(<%=obj.DmiInfo[pidx].nUnitId%>, ncoreConfigInfo::user_addrq[ncoreConfigInfo::NONCOH], 0);
                // #Stimulus.FSYS.sysevent.noncoh_txn.pre-v3.4
                          if($test$plusargs("en_excl_noncoh_txn")) begin
                             ncoreConfigInfo::user_addrq[ncoreConfigInfo::NONCOH] = ncoreConfigInfo::user_addrq[ncoreConfigInfo::NONCOH][0:0]; 
                          end
                     end
                <% }} %>
                endcase
                <% } %>
                `uvm_info(get_name(), $psprintf("dmi_fix_index plusarg is on, Final ncoreConfigInfo::user_addrq[ncoreConfigInfo::NONCOH] size %0d ncoreConfigInfo::user_addrq[ncoreConfigInfo::COH] size %0d",ncoreConfigInfo::user_addrq[ncoreConfigInfo::NONCOH].size(),ncoreConfigInfo::user_addrq[ncoreConfigInfo::COH].size()), UVM_LOW)
           end else if($test$plusargs("en_excl_txn") || $test$plusargs("en_excl_noncoh_txn")) begin
                if(!$value$plusargs("min_use_user_addrq=%d", min_use_user_addrq)) begin
                    min_use_user_addrq = 10;
                end

                <%
                for (pidx = 0; pidx < obj.nDMIs; pidx++)
                if (obj.DmiInfo[pidx].useCmc) { %>
                <% for(pidx = 0; pidx < obj.nDMIs; pidx++) { let maxWay = 0; if(obj.DmiInfo[pidx].useCmc){obj.DmiInfo[pidx].ccpParams.PriSubDiagAddrBits.forEach(function FindMax(item){maxWay = (maxWay<item.nWays) ? item.nWays : maxWay;});%>
                if($test$plusargs("en_excl_txn")) begin
                    addr_mgr.set_dmi_smc_fix_index_in_user_addrq(<%=obj.DmiInfo[pidx].nUnitId%>, ncoreConfigInfo::tmp_user_addrq[ncoreConfigInfo::COH], 1); 
                    ncoreConfigInfo::user_addrq[ncoreConfigInfo::COH].push_back(ncoreConfigInfo::tmp_user_addrq[ncoreConfigInfo::COH][0]); 
                    ncoreConfigInfo::tmp_user_addrq[ncoreConfigInfo::COH] = {};
                end
                // #Stimulus.FSYS.sysevent.coh_txn.pre-v3.4
                if($test$plusargs("en_excl_noncoh_txn")) begin
                    addr_mgr.set_dmi_smc_fix_index_in_user_addrq(<%=obj.DmiInfo[pidx].nUnitId%>, ncoreConfigInfo::tmp_user_addrq[ncoreConfigInfo::NONCOH], 0);
                    ncoreConfigInfo::user_addrq[ncoreConfigInfo::NONCOH].push_back(ncoreConfigInfo::tmp_user_addrq[ncoreConfigInfo::NONCOH][0]); 
                    ncoreConfigInfo::tmp_user_addrq[ncoreConfigInfo::NONCOH] = {};
                end
                <% }} %>
                <% } %>

                if($test$plusargs("en_excl_txn") && (ncoreConfigInfo::user_addrq[ncoreConfigInfo::COH].size()<min_use_user_addrq))  begin
                    <% if ( obj.initiatorGroups.length >= 1) { %>
                    <% for(pidx = 0; pidx < obj.nAIUs; pidx++) { %>
                    addr_mgr.gen_user_coh_addr(<%=obj.AiuInfo[pidx].FUnitId%>, ((use_user_addrq/<%=obj.nAIUs%>)>min_use_user_addrq) ? (use_user_addrq/<%=obj.nAIUs%>) :(min_use_user_addrq-ncoreConfigInfo::user_addrq[ncoreConfigInfo::COH].size()), ncoreConfigInfo::user_addrq[ncoreConfigInfo::COH]);  <% } %>
                    <% } else { %>
                    addr_mgr.gen_user_coh_addr(<%=obj.AiuInfo[0].FUnitId%>, (use_user_addrq>min_use_user_addrq) ? use_user_addrq :(min_use_user_addrq-ncoreConfigInfo::user_addrq[ncoreConfigInfo::COH].size()), ncoreConfigInfo::user_addrq[ncoreConfigInfo::COH]);
                    <% } %>
                end

                if($test$plusargs("en_excl_txn"))  begin
                    `uvm_info(get_name(), $psprintf("en_excl_txn plusarg is on, Final ncoreConfigInfo::user_addrq[ncoreConfigInfo::NONCOH] size %0d ncoreConfigInfo::user_addrq[ncoreConfigInfo::COH] size %0d",ncoreConfigInfo::user_addrq[ncoreConfigInfo::NONCOH].size(),ncoreConfigInfo::user_addrq[ncoreConfigInfo::COH].size()), UVM_LOW)
                    foreach (ncoreConfigInfo::user_addrq[ncoreConfigInfo::COH][x]) begin
                        `uvm_info(get_name(), $psprintf("ncoreConfigInfo::user_addrq[ncoreConfigInfo::COH][%0d]  0x%0h",x,ncoreConfigInfo::user_addrq[ncoreConfigInfo::COH][x]), UVM_LOW)
                    end
                end

                // #Stimulus.FSYS.no_sysevent.excl.noncoh_txn.pre-v3.4
                if($test$plusargs("en_excl_noncoh_txn") && (ncoreConfigInfo::user_addrq[ncoreConfigInfo::NONCOH].size()<min_use_user_addrq)) begin
                    ncoreConfigInfo::user_addrq[ncoreConfigInfo::NONCOH] = {};
                    <% if ( obj.initiatorGroups.length >= 1) { %>
                    <% for(pidx = 0; pidx < obj.nAIUs; pidx++) { %>
                    addr_mgr.gen_user_noncoh_addr(<%=obj.AiuInfo[pidx].FUnitId%>, ((use_user_addrq/<%=obj.nAIUs%>)>min_use_user_addrq) ? (use_user_addrq/<%=obj.nAIUs%>) :(min_use_user_addrq -ncoreConfigInfo::user_addrq[ncoreConfigInfo::NONCOH].size()), ncoreConfigInfo::user_addrq[ncoreConfigInfo::NONCOH]);  

                    <% } %>
                    //ncoreConfigInfo::user_addrq[ncoreConfigInfo::NONCOH] = ncoreConfigInfo::user_addrq[ncoreConfigInfo::NONCOH][0:0]; 
                    <% } else { %>
                    addr_mgr.gen_user_noncoh_addr(<%=obj.AiuInfo[0].FUnitId%>, (use_user_addrq>min_use_user_addrq) ? use_user_addrq :(min_use_user_addrq-ncoreConfigInfo::user_addrq[ncoreConfigInfo::NONCOH].size()), ncoreConfigInfo::user_addrq[ncoreConfigInfo::NONCOH]);
                    //ncoreConfigInfo::user_addrq[ncoreConfigInfo::NONCOH] = ncoreConfigInfo::user_addrq[ncoreConfigInfo::NONCOH][0:0]; 
                    <% } %>
                end
                if($test$plusargs("en_excl_noncoh_txn"))  begin
                    `uvm_info(get_name(), $psprintf("en_excl_noncoh_txn plusarg is on, Final ncoreConfigInfo::user_addrq[ncoreConfigInfo::NONCOH] size %0d ncoreConfigInfo::user_addrq[ncoreConfigInfo::COH] size %0d",ncoreConfigInfo::user_addrq[ncoreConfigInfo::NONCOH].size(),ncoreConfigInfo::user_addrq[ncoreConfigInfo::COH].size()), UVM_LOW)
                    foreach (ncoreConfigInfo::user_addrq[ncoreConfigInfo::NONCOH][x]) begin
                        `uvm_info(get_name(), $psprintf("ncoreConfigInfo::user_addrq[ncoreConfigInfo::NONCOH][%0d]  0x%0h",x,ncoreConfigInfo::user_addrq[ncoreConfigInfo::NONCOH][x]), UVM_LOW)
                    end
                end
            end
         end else begin
          <% if ( obj.initiatorGroups.length >= 1) { %>
          <% for(pidx = 0; pidx < obj.nAIUs; pidx++) { %>
            if (!$test$plusargs("all_gpra_ncmode"))addr_mgr.gen_user_coh_addr(<%=obj.AiuInfo[pidx].FUnitId%>, use_user_addrq/<%=obj.nAIUs%>, ncoreConfigInfo::user_addrq[ncoreConfigInfo::COH]);  <% } %>
          <% } else { %>
            if (!$test$plusargs("all_gpra_ncmode"))addr_mgr.gen_user_coh_addr(<%=obj.AiuInfo[0].FUnitId%>, use_user_addrq, ncoreConfigInfo::user_addrq[ncoreConfigInfo::COH]);
          <% } %>

          end
    end:_no_perf_test

if (m_concerto_env_cfg.has_chi_vip_snps) begin:_setup_addr_chi_vip
<% if(numChiAiu > 0) { %>
               m_svt_chi_item.user_addrq[ncoreConfigInfo::NONCOH] = ncoreConfigInfo::user_addrq[ncoreConfigInfo::NONCOH];
               m_svt_chi_item.user_addrq[ncoreConfigInfo::COH] = ncoreConfigInfo::user_addrq[ncoreConfigInfo::COH];
               m_svt_chi_item.user_addr = 1;
<% } %> 
end:_setup_addr_chi_vip else begin:_setup_add_chi_inhouse
               <% chi_idx=0;
	       for(pidx=0; pidx<obj.nAIUs; pidx++) {
               if(obj.AiuInfo[pidx].fnNativeInterface.match("CHI")) { %>
               m_chi<%=chi_idx%>_vseq.m_chi_container.user_addrq[ncoreConfigInfo::NONCOH] = ncoreConfigInfo::user_addrq[ncoreConfigInfo::NONCOH];
               m_chi<%=chi_idx%>_vseq.m_chi_container.user_addrq[ncoreConfigInfo::COH] = ncoreConfigInfo::user_addrq[ncoreConfigInfo::COH];
	       <% chi_idx++;%>
         <%}%>
         <%}%>
end:_setup_add_chi_inhouse

if (!m_concerto_env_cfg.has_axi_vip_snps) begin:_setup_addr_ace_inhouse
	       <%io_idx=0;
	       for(pidx=0; pidx<obj.nAIUs; pidx++) {
               if(!(obj.AiuInfo[pidx].fnNativeInterface.match("CHI"))) { %>
              <% for(let coreidx=0; coreidx<aiu_NumCores[pidx]; coreidx++) { %>
               m_concerto_env.inhouse.m_ace_cache_model_ioaiu<%=io_idx%>[<%=coreidx%>].user_addrq[ncoreConfigInfo::NONCOH] = ncoreConfigInfo::user_addrq[ncoreConfigInfo::NONCOH];
               m_concerto_env.inhouse.m_ace_cache_model_ioaiu<%=io_idx%>[<%=coreidx%>].user_addrq[ncoreConfigInfo::COH] = ncoreConfigInfo::user_addrq[ncoreConfigInfo::COH];
              <% } %>//foreach core%>               
               <% io_idx++; } 
               } %>
end:_setup_addr_ace_inhouse

endtask:gen_addr_use_user_addrq

`endif // `ifdef USE_VIP_SNPS
