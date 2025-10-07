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
const initiatorAgents   = obj.AiuInfo.length ;
const aiu_NumCores = [];
const aiu_rpn = [];
const dce_rpn = [];
const dmi_rpn = [];
const aiuName = [];

   const _blkid = [];
   const _blkportsid =[];
   const _blk   = [{}];
   let _idx = 0;
   let idx = 0;
   let chiaiu_idx=0;
   let aiu_idx = 0;
   let nAIUs_mpu =0; 
   
   for(let pidx = 0; pidx < obj.nAIUs; pidx++) {
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

 for(let pidx = 0; pidx < initiatorAgents; pidx++) { 
   if(Array.isArray(obj.AiuInfo[pidx].interfaces.axiInt)) {
       aiu_NumCores[pidx]    = obj.AiuInfo[pidx].interfaces.axiInt.length;
       aiu_rpn[pidx]= obj.AiuInfo[pidx].rpn[0];
   } else {
       aiu_NumCores[pidx]    = 1;
       aiu_rpn[pidx]= obj.AiuInfo[pidx].rpn;
   }
 }

for(let pidx = 0; pidx < obj.nAIUs; pidx++) {
    if(Array.isArray(obj.AiuInfo[pidx].interfaces.axiInt)) {
        aiu_axiInt[pidx] = obj.AiuInfo[pidx].interfaces.axiInt[0];
        AiuCore = 'ioaiu_core0';
    } else {
        aiu_axiInt[pidx] = obj.AiuInfo[pidx].interfaces.axiInt;
        AiuCore = 'ioaiu_core0';
    }
}

for(let pidx = 0; pidx < obj.nDMIs; pidx++) {
    pma_en_dmi_blk &= obj.DmiInfo[pidx].usePma;
    pma_en_at_least_1_blk |= obj.DmiInfo[pidx].usePma;
    dmi_rpn[pidx] = obj.DmiInfo[pidx].rpn;
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
for(let pidx = 0; pidx < obj.nDIIs; pidx++) {
    pma_en_dii_blk &= obj.DiiInfo[pidx].usePma;
    pma_en_at_least_1_blk |= obj.DiiInfo[pidx].usePma;
}
for(let pidx = 0; pidx < obj.nDCEs; pidx++) {
    dce_rpn[pidx] = obj.DceInfo[pidx].rpn;
}
// Assuming CHI AIU will appear first in AiuInfo in top.level.dv.json before IO-AIUs
let chi_idx=0;
let io_idx=0;
for(let pidx = 0; pidx < obj.nAIUs; pidx++) {
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
       { numIoAiu++ ; 
         if(obj.AiuInfo[pidx].fnNativeInterface == "ACE"||obj.AiuInfo[pidx].fnNativeInterface == "ACE5") { 
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
for(let pidx = 0; pidx < obj.nDCEs; pidx++) {
    pma_en_dce_blk &= obj.DceInfo[pidx].usePma;
    pma_en_at_least_1_blk |= obj.DceInfo[pidx].usePma;
}
for(let pidx = 0; pidx < obj.nDVEs; pidx++) {
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
<%for(let pidx = 0; pidx < nAIUs_mpu; pidx++) {   %>
//  idx=<%=pidx%> : <%=_blkid[pidx]%>  port:<%=_blkportsid[pidx]%> 
<% } %>

//File: concerto_fullsys_test.svh

<%  if((obj.INHOUSE_OCP_VIP)) { %>
import ocp_agent_pkg::*;
<%  } %>

`ifdef CHI_UNITS_CNT_NON_ZERO
import chi_subsys_pkg::*;
<%for(idx = 0; idx < obj.nCHIs; idx++) { %>
import chiaiu<%=idx%>_smi_agent_pkg::*;
<% } %>
`endif

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

     if(bundle.fnNativeInterface === "ACE" || bundle.fnNativeInterface === "ACE5" ||bundle.fnNativeInterface === "CHI-A" || bundle.fnNativeInterface === "CHI-B" || bundle.fnNativeInterface === "CHI-E") { // interleaved Aius?
       obj.SnoopFilterInfo.forEach(function(snpinfo, snp_indx, array) {
          if (snpinfo.SnoopFilterAssignment.includes(bundle.FUnitId))
            idSnoopFilterSlice.push(snp_indx);
       });
     }

     if(bundle.fnNativeInterface === "ACE" || bundle.fnNativeInterface === "ACE5" ||bundle.fnNativeInterface === "ACE-LITE" || bundle.fnNativeInterface === "ACELITE-E") {
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
class concerto_fullsys_test extends concerto_base_trace_test;

    //////////////////
    //Properties
    //////////////////

    static string inst_name="";
    int iter;
    bit override_by_cust_svt_chi_rn_directed_snoop_response_sequence = 1;
    //bit has_chib;
    bit has_chie;

    static uvm_event ev_bist_reset_done = ev_pool.get("bist_reset_done");
    uvm_event kill_uncorr_test   = ev_pool.get("kill_uncorr_test");
    uvm_event kill_chiaiu_uncorr_test   = ev_pool.get("kill_chiaiu_uncorr_test");
    //event to sync with concerto_fullsys_test and end simulation when DECERR is received
    uvm_event kill_uncorr_grar_nsx_test = ev_pool.get("kill_uncorr_grar_nsx_test");


    <% for(pidx = 0; pidx < obj.nDMIs; pidx++) {if(obj.DmiInfo[pidx].useCmc) { %>
    static uvm_event ev_inject_error_dmi<%=pidx%>_smc = ev_pool.get("inject_error_dmi<%=pidx%>_smc"); <%}}%>


    //INHOUSE CHI SEQ
    <% let qidx=0; idx=0; for(let pidx = 0 ; pidx < obj.nAIUs; pidx++) { %>
      <% if((obj.AiuInfo[pidx].fnNativeInterface == 'CHI-A') || (obj.AiuInfo[pidx].fnNativeInterface == 'CHI-B')|| (obj.AiuInfo[pidx].fnNativeInterface == 'CHI-E')) { %>
           chiaiu<%=idx%>_chi_aiu_vseq_pkg::chi_aiu_vseq#(<%=obj.AiuInfo[pidx].FUnitId%>)       m_chi<%=idx%>_vseq;
           chiaiu<%=idx%>_chi_aiu_vseq_pkg::chi_aiu_vseq#(<%=obj.AiuInfo[pidx].FUnitId%>)       m_chi<%=idx%>_read_vseq; // read
           chi_aiu_unit_args_pkg::chi_aiu_unit_args                       m_chi<%=idx%>_args;
           chi_aiu_unit_args_pkg::chi_aiu_unit_args                       m_chi<%=idx%>_read_args;  // read
           //sys_event agent seq
    <% if(obj.AiuInfo[pidx].interfaces.eventRequestOutInt._SKIP_ == false || obj.AiuInfo[pidx].interfaces.eventRequestInInt._SKIP_ == false) { %>
        chiaiu<%=idx%>_event_agent_pkg::event_seq  m_chi<%=idx%>_event_seq;
    <% } %>         
	   static uvm_event ev_chi<%=idx%>_seq_done = ev_pool.get("m_chi<%=idx%>_seq");
	   static uvm_event ev_chi<%=idx%>_read_seq_done = ev_pool.get("m_chi<%=idx%>_read_seq");
	   <%  idx++;   %>
       <% } else { %>
      ioaiu<%=qidx%>_inhouse_axi_bfm_pkg::mstr_seq_cfg io_subsys_mstr_seq_cfg_inhouse<%=qidx%>;
      static uvm_event ev_ioaiu<%=qidx%>_seq_done[<%=aiu_NumCores[pidx]%>];
      static uvm_event ev_ioaiu<%=qidx%>_read_seq_done[<%=aiu_NumCores[pidx]%>];
<%  qidx++; } %>
    <% } %>
    // END INHOUSE CHI SEQ 
    
    // SNPS CHI SEQ
    bit vip_snps_non_coherent_txn = 0;
    bit vip_snps_coherent_txn = 0;
    int vip_snps_seq_length = 4;
    int seq_id;
    bit                          SYNPS_AXI_SLV_BACKPRESSURE_EN = 0;

  fsys_main_traffic_virtual_seq fsys_main_traffic_vseq;
  mstr_seq_cfg io_subsys_mstr_seq_cfg_inhouse[<%=obj.nAIUs%>];


  `ifdef IO_UNITS_CNT_NON_ZERO
    string io_subsys_mstr_agnt_seqr_str[`NUM_IOAIU_SVT_MASTERS] ;
    svt_axi_master_sequencer io_subsys_mstr_agnt_seqr_a[`NUM_IOAIU_SVT_MASTERS] ;
    mstr_seq_cfg io_subsys_mstr_seq_cfg_a[`NUM_IOAIU_SVT_MASTERS];
  `endif

//CHI Linkup Virtual sequence
<% if(numChiAiu > 0) { %>
     chi_coh_bringup_virtual_seq chi_coh_bringup_vseq;
<% } %>

  <% qidx=0;idx=0; for(let pidx = 0; pidx < obj.nAIUs; pidx++) { %>
    <% if((obj.AiuInfo[pidx].fnNativeInterface == 'CHI-A')||(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-B' || obj.AiuInfo[pidx].fnNativeInterface == 'CHI-E')) { %>
    //svt_chi_rn_transaction_random_sequence svt_chi_rn_seq_h<%=idx%>;
    //svt_chi_rn_coherent_transaction_base_sequence svt_chi_rn_seq_h<%=idx%>;
    //MOVED TO VSEQ svt_chi_link_service_activate_sequence svt_chi_link_up_seq_h<%=idx%>;
    svt_chi_link_service_deactivate_sequence svt_chi_link_dn_seq_h<%=idx%>;
    static uvm_event done_svt_chi_link_dn_seq_h<%=idx%> = ev_pool.get("done_svt_chi_link_dn_seq_h<%=idx%>");
    static uvm_event done_svt_chi_rn_seq_h<%=idx%> = ev_pool.get("done_svt_chi_rn_seq_h<%=idx%>");
    <% if(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-B' || obj.AiuInfo[pidx].fnNativeInterface == 'CHI-E') { %>
    svt_chi_protocol_service_coherency_exit_sequence coherency_exit_seq<%=idx%>;
    svt_chi_protocol_service_coherency_entry_sequence coherency_entry_seq<%=idx%>;
    <% } %>
   <% idx++; } else {%>
   <% qidx++; } } %>
<% if(numChiAiu > 0) { %>
     svt_chi_item m_svt_chi_item;
<% } %>
   // END SNPS CHI SEQ

  //TMP REMOVED// LEGACY SNPS CHI SEQ ???
     <% qidx=0; idx=0; for(let pidx = 0 ; pidx < obj.nAIUs; pidx++) { %>
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
  int chi_duty_cycle;
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
  <% for(let pidx = 0 ; pidx < obj.nAIUs; pidx++) { %>
      <% if(!((obj.AiuInfo[pidx].fnNativeInterface == 'CHI-A') || (obj.AiuInfo[pidx].fnNativeInterface == 'CHI-B') || (obj.AiuInfo[pidx].fnNativeInterface == 'CHI-E'))) { %>
       <% for(let i=0; i<aiu_NumCores[pidx]; i++) { %> 
    uvm_event ioaiu_clk_posedge_e_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_<%=i%>;
     <% } %>
    <% ioaiu_idx++;
    } %>
   <% } %>
`endif//USE_STL_TRACE

  //CONC-11906 To-Do: Move all below macros in concerto_common_macros_snps.svh
  //Picked up the below defines from concerto_iosubsys_test_snps for the
  //IOAIU_SUBSYS vsequence bringup

   `define CONC_COMMON_MERGE(val1,val2) \
   val1``val2

   `define CONC_COMMON_STRINGIFY(x) `"x`"
   
   `define CONC_SVT_AXI_SYSENV_0_PATH m_concerto_env.snps.svt.amba_system_env.axi_system[0]
   
   `define CONC_SVT_AXI_SYSSEQR_PATH                `CONC_COMMON_MERGE(`CONC_SVT_AXI_SYSENV_0_PATH,.sequencer)

   <% ioaiu_idx=0; let ioaiu_idx_with_multi_core=0;%> 
   <% for(let pidx=0; pidx<obj.nAIUs; pidx++) { %> 
   <%if(obj.AiuInfo[pidx].fnNativeInterface == 'ACE-LITE' || obj.AiuInfo[pidx].fnNativeInterface == 'ACELITE-E' || obj.AiuInfo[pidx].fnNativeInterface == 'ACE'  || obj.AiuInfo[pidx].fnNativeInterface == 'ACE5'|| obj.AiuInfo[pidx].fnNativeInterface == 'AXI4' || obj.AiuInfo[pidx].fnNativeInterface == 'AXI5') { 
      for(let i=0; i<aiu_NumCores[pidx]; i++) { %>
   `define CONC_SVT_IOAIU<%=ioaiu_idx%>_<%=i%>_MASTER_SEQR_PATH                `CONC_COMMON_MERGE(`CONC_SVT_AXI_SYSENV_0_PATH,.master[<%=ioaiu_idx_with_multi_core%>].sequencer)
   <% ioaiu_idx_with_multi_core = ioaiu_idx_with_multi_core + 1; } ioaiu_idx = ioaiu_idx+1;} } %>
   `define CONC_NUM_IOAIU_SVT_MASTERS <%=ioaiu_idx_with_multi_core%>

    `define CONC_COMMON_SVT_ACE_CONSTRAINTS(lhs_prefix,rhs_prefix)

    //CONC-11906 To-Do: Move all below in concerto_helper_pkg_snps.svh
    string conc_svt_axi_sysseqr_path_str="";
    <% if(numIoAiu > 0) { %> 
    string conc_ioaiu_fnnativeif_array[`CONC_NUM_IOAIU_SVT_MASTERS] ;
    string conc_ioaiu_name_array[`CONC_NUM_IOAIU_SVT_MASTERS] ;
    svt_axi_master_sequencer conc_svt_axi_master_agnt_seqr[`CONC_NUM_IOAIU_SVT_MASTERS] ;
    string conc_svt_axi_master_agnt_seqr_path_string_array[`CONC_NUM_IOAIU_SVT_MASTERS] ;
    <% } %>

   <% chi_idx=0;%>
  <% for(idx = 0;  idx < obj.nAIUs; idx++) {%> 
  <% if (obj.AiuInfo[idx].fnNativeInterface.match('CHI')) { %>
   chi_subsys_pkg::chi_subsys_vseq         m_snps_chi<%=chi_idx%>_vseq;
   <% chi_idx++;} }%>

    `ifdef CHI_SUBSYS
<%for(idx = 0; idx < obj.nCHIs; idx++) { %>
chiaiu<%=idx%>_smi_force_seq     m_smi_force_seq<%=idx%>;
<%}%>
    `endif

    //////////////////
    //UVM Registery
    //////////////////    
    `uvm_component_utils(concerto_fullsys_test)

    //////////////////
    //Methods
    //////////////////
    // UVM PHASE
    extern function new(string name = "concerto_fullsys_test", uvm_component parent = null);
    extern virtual function void build_phase(uvm_phase  phase);
    extern static function concerto_fullsys_test get_instance();
    extern virtual function void end_of_elaboration_phase(uvm_phase phase);
    extern virtual function void phase_ready_to_end(uvm_phase phase);
    <% if (numIoAiu > 0) { %>
    extern virtual task run_ioaiu_test_seq(input string initiator_port_name="", int ioaiu_port_id=0);
    //extern virtual task run_ioaiu_ace_test_seq(input string initiator_port_name="", int ioaiu_port_id=0);
    //extern virtual task run_ioaiu_axi4_test_seq(input string initiator_port_name="", int ioaiu_port_id=0);
    extern virtual task initialize_conc_helper_var_snps();
    <% } %>
    extern virtual function void start_of_simulation_phase(uvm_phase phase);
    extern virtual task run_phase(uvm_phase phase);
    extern virtual task ncore_test_stimulus(uvm_phase phase);
    extern virtual task kickoff_chi_coh_bringup_vseq();
    extern virtual task trigger_aiu_env_sysco_event();
    
    // TASK
    `ifdef IO_UNITS_CNT_NON_ZERO
      extern virtual function void io_subsys_init_snps_vseq(io_subsys_snps_vseq vseq);
      extern virtual function void io_subsys_init_inhouse_vseq(io_subsys_inhouse_vseq vseq);
      extern virtual function void configure_ioaiu_mstr_seqs();
    `endif
    extern virtual task gen_addr_use_user_addrq();
    extern virtual task exec_inhouse_seq(uvm_phase phase);
    extern virtual task wait_seq_totaly_done(uvm_phase phase);
 
    extern virtual task check_corr_errint_through_alias_reg();
   
    
    `ifdef USE_STL_TRACE 
    extern virtual task stl_csr_write();
    `endif //USE_STL_TRACE

    
    extern virtual task inject_error_all_dmi_smc();
    <% for(let pidx = 0; pidx < obj.nDMIs; pidx++) { if(obj.DmiInfo[pidx].useCmc) {%>
    extern virtual task inject_error_dmi<%=pidx%>_smc();
    <%}}%>
    uvm_event ev_steady_start_rd_bw = uvm_event_pool::get_global("ev_steady_start_rd_bw");
    uvm_event ev_steady_start_wr_bw = uvm_event_pool::get_global("ev_steady_start_wr_bw");
    uvm_event ev_steady_stop_rd_bw = uvm_event_pool::get_global("ev_steady_stop_rd_bw");
    uvm_event ev_steady_stop_wr_bw = uvm_event_pool::get_global("ev_steady_stop_wr_bw");
    virtual function void hook_aiu_en(); endfunction

    // Generic task used by Child class
    int max_iteration=1;
    virtual task main_seq_pre_hook(uvm_phase phase); endtask// before the iteration (outside the iteration loop)
    virtual task main_seq_post_hook(uvm_phase phase); endtask// after the iteration (outside the iteration loop)
    virtual task main_seq_iter_pre_hook(uvm_phase phase, int iter=0); endtask// at the beginning of the iteration(inside the iteration loop)
    extern virtual task main_seq_iter_post_hook(uvm_phase phase, int iter=0);// at the end of the iteration (inside the iteration)
    virtual task main_seq_hook_end_run_phase(uvm_phase phase); endtask
    //MOVED TO VSEQR <% if(numChiAiu > 0) { %>
    //MOVED TO VSEQR extern virtual function void init_coh_init_vseq();
    //MOVED TO VSEQR <% } %>
endclass: concerto_fullsys_test


////////////////////////////////
// VCS fix in case of iteration
/////////////////////////////////
 task concerto_fullsys_test::main_seq_iter_post_hook(uvm_phase phase, int iter=0); 
  `ifdef VCS
     `ifndef USE_VIP_SNPS_CHI
           if (max_iteration > 1) begin 
            #10us;  // in case of VCS always do  super.main_se_qiter_post_hook(phase)
               <% chi_idx=0;%>
              <% for(let pidx = 0; pidx < obj.nAIUs; pidx++) { %>
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
      `endif // USE_VIP_SNPS_CHI
    `endif // `ifdef VCS
endtask

//////////////////
//Calling Method: Child Class
//Description: Constructor
//Arguments:   UVM Default
//Return type: N/A
//////////////////
function concerto_fullsys_test::new(string name = "concerto_fullsys_test", uvm_component parent = null);
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
function void concerto_fullsys_test::build_phase(uvm_phase phase);

    string msg_idx;
    int    transorder_mode;
   uvm_factory factory = uvm_factory::get();

    `uvm_info("Build", "Entered Build Phase", UVM_LOW);
    super.build_phase(phase);

    if (!$value$plusargs("chi_num_trans=%d",chi_num_trans)) begin
        chi_num_trans = 0;
    end
    if (!$value$plusargs("ioaiu_num_trans=%d",ioaiu_num_trans)) begin
        ioaiu_num_trans = 0;
    end

    if (!$value$plusargs("chi_duty_cycle=%d",chi_duty_cycle)) begin
        chi_duty_cycle = 0;
    end

    if ($test$plusargs("func_unit_uncorr_err_inj") || $test$plusargs("dup_unit_uncorr_err_inj")) begin
        $value$plusargs("func_unit_uncorr_err_inj=%d",func_unit_uncorr_err_inj);
        $value$plusargs("dup_unit_uncorr_err_inj=%d",dup_unit_uncorr_err_inj);
        if(func_unit_uncorr_err_inj && dup_unit_uncorr_err_inj)  both_units_uncorr_err_inj = 1;
    end else begin
        func_unit_uncorr_err_inj = 1;
    end

    <% for(let pidx = 0 ; pidx < obj.nAIUs; pidx++) { %>
      <% if(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-E') { %> has_chie = 1; <% } %>
    <% } %>


   /// BEGIN INHOUSE IOAIU SEQ
    <% 
      ioaiu_idx = 0;
   %>
  <% for(let pidx = 0 ; pidx < obj.nAIUs; pidx++) { %>
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
  
<% if(numChiAiu > 0) { %>
   chi_coh_bringup_vseq = chi_coh_bringup_virtual_seq::type_id::create("chi_coh_bringup_vseq");
<% } %>
  <% idx=0; %>
  <% for(pidx = 0; pidx < obj.nAIUs; pidx++) { %>
    <%if((obj.AiuInfo[pidx].fnNativeInterface == 'CHI-A')||(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-B' || obj.AiuInfo[pidx].fnNativeInterface == 'CHI-E')) { %>
     `uvm_info(get_name(), "USE_VIP_SNPS svt_chi_link_service_sequence::CREATE[<%=idx%>]", UVM_NONE)
      //MOVED TO VSEQ svt_chi_link_up_seq_h<%=idx%> = svt_chi_link_service_activate_sequence::type_id::create("svt_chi_link_up_seq_h<%=idx%>");
      svt_chi_link_dn_seq_h<%=idx%> = svt_chi_link_service_deactivate_sequence::type_id::create("svt_chi_link_dn_seq_h<%=idx%>");
     `uvm_info(get_name(), "USE_VIP_SNPS svt_chi_rn_transaction_random_sequence::CREATE[<%=idx%>]", UVM_NONE)
      //svt_chi_rn_seq_h<%=idx%> = svt_chi_rn_transaction_random_sequence::type_id::create("svt_chi_rn_seq_h<%=idx%>");
      //svt_chi_rn_seq_h<%=idx%> = svt_chi_rn_coherent_transaction_base_sequence::type_id::create("svt_chi_rn_seq_h<%=idx%>");
      <% if(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-B' || obj.AiuInfo[pidx].fnNativeInterface == 'CHI-E') { %>
        coherency_entry_seq<%=idx%> = svt_chi_protocol_service_coherency_entry_sequence::type_id::create("coherency_entry_seq<%=idx%>");
        coherency_exit_seq<%=idx%> = svt_chi_protocol_service_coherency_exit_sequence::type_id::create("coherency_exit_seq<%=idx%>");
        coherency_entry_seq<%=idx%>.node_cfg = m_concerto_env_cfg.svt_cfg.chi_sys_cfg[0].rn_cfg[<%=idx%>];
        coherency_exit_seq<%=idx%>.node_cfg = m_concerto_env_cfg.svt_cfg.chi_sys_cfg[0].rn_cfg[<%=idx%>];
      <% } %>
    <% idx++; %>
    <%} %>
    <%} %>

   
   // UVM_DB SET
    uvm_config_db#(int unsigned)::set(this, "m_concerto_env.snps.svt.amba_system_env.chi_system[0].rn[<%=chiaiu_idx%>].rn_xact_seqr.svt_chi_rn_transaction_random_sequence", "sequence_length", chi_num_trans);
    uvm_config_db#(bit)::set(this, "m_concerto_env.snps.svt.amba_system_env.chi_system[0].rn[<%=chiaiu_idx%>].rn_xact_seqr.svt_chi_rn_transaction_random_sequence", "enable_non_blocking", 1);

   end:_build_chi_vip_snps

    `ifdef IO_UNITS_CNT_NON_ZERO
   if (m_concerto_env_cfg.has_axi_vip_snps) begin:_build_axi_vip_snps // TODO MOVE in VIRTUAL SEQ
        
      set_type_override_by_type(svt_axi_master_transaction::get_type(),io_subsys_pkg::io_subsys_axi_master_transaction::get_type());
      set_type_override_by_type(svt_axi_slave_transaction::get_type(),io_subsys_pkg::io_subsys_axi_slave_transaction::get_type());
     `uvm_info("CONCERTO_FULLSYS_TEST",$psprintf("fn:build_phase Override svt_axi_master_transaction by io_subys_axi_master_transaction"),UVM_LOW)
 
      set_type_override_by_type(svt_axi_master_snoop_transaction::get_type(),io_subsys_pkg::io_subsys_ace_master_snoop_transaction::get_type());
     `uvm_info("CONCERTO_FULLSYS_TEST",$psprintf("fn:build_phase Override svt_axi_master_snoop_transaction by io_subsys_ace_master_snoop_transaction"),UVM_LOW)
 
      if($test$plusargs("use_dvm")) begin
        set_type_override_by_type(svt_axi_master_transaction::get_type(),ioaiu0_env_pkg::ioaiu_axi_master_transaction::get_type());
        `uvm_info("CONCERTO_FULLSYS_TEST",$psprintf("fn:build_phase Override svt_axi_master_transaction by ioaiu_axi_master_transaction if use_dvm is set"),UVM_LOW)
      end    
      uvm_config_db#(uvm_object_wrapper)::set(this, "m_concerto_env.snps.svt.amba_system_env.axi_system[0].sequencer.main_phase", "default_sequence", null);
      uvm_config_db#(uvm_object_wrapper)::set(this, "m_concerto_env.snps.svt.amba_system_env.axi_system[0].master*.sequencer.main_phase", "default_sequence", null);
    end:_build_axi_vip_snps
    `endif

    /** Apply the null sequence to the AMBA ENV virtual sequencer to override the default sequence. */
    uvm_config_db#(uvm_object_wrapper)::set(this, "m_concerto_env.snps.svt.amba_system_env.sequencer.main_phase", "default_sequence", null );
    
   end:_build_vip_snps
    
    set_inactivity_period(m_args.k_timeout);
    
    if(!$value$plusargs("boot_from_ioaiu=%d",boot_from_ioaiu)) begin
       boot_from_ioaiu = 0;
    end

    `ifdef CHI_SUBSYS
<%for(idx = 0; idx < obj.nCHIs; idx++) { %>
 m_smi_force_seq<%=idx%> =  chiaiu<%=idx%>_smi_force_seq::type_id::create("m_smi_force_seq<%=idx%>",this);
<%}%>
    `endif
    `uvm_info("Build", "Exited Build Phase", UVM_LOW);
 endfunction: build_phase

<% if(numIoAiu > 0) { %> 
task concerto_fullsys_test::run_ioaiu_test_seq(input string initiator_port_name="", int ioaiu_port_id=0);
  if(m_concerto_env_cfg.has_axi_vip_snps) begin
    if(conc_ioaiu_fnnativeif_array[ioaiu_port_id]=="ACE" || conc_ioaiu_fnnativeif_array[ioaiu_port_id]=="ACE5" ||conc_ioaiu_fnnativeif_array[ioaiu_port_id]=="ACE-LITE" || conc_ioaiu_fnnativeif_array[ioaiu_port_id]=="ACELITE-E") begin
        `uvm_info("concerto_fullsys_test::run_ioaiu_test",$psprintf("Calling run_ioaiu_ace_test_seq for IOAIU[%0d/%0s]",ioaiu_port_id,initiator_port_name),UVM_LOW)
        //run_ioaiu_ace_test_seq(initiator_port_name,ioaiu_port_id);
    end else if(conc_ioaiu_fnnativeif_array[ioaiu_port_id]=="AXI4" || conc_ioaiu_fnnativeif_array[ioaiu_port_id]=="AXI5") begin
        `uvm_info("concerto_fullsys_test://:run_ioaiu_test",$psprintf("Calling run_ioaiu_axi4_test_seq for IOAIU[%0d/%0s]",ioaiu_port_id,initiator_port_name),UVM_LOW)
        //run_ioaiu_axi4_test_seq(initiat//or_port_name,ioaiu_port_id);
    end else begin
        `uvm_error("concerto_fullsys_test//::run_ioaiu_test",$psprintf("Please specify appropriate ioaiu fnnative interface IOAIU[%0d/%0s]",ioaiu_port_id,initiator_port_name))
    end
  end
endtask

//task concerto_fullsys_test::run_ioaiu_a//ce_test_seq(input string initiator_port_name="", int ioaiu_port_id=0);
//  if(m_concerto_env_cfg.has_axi_vip_snp//s) begin
//    string seq_name="ioaiu_random_all_o//ps_no_dvm_sequence";
//    string seq_inst="";
//    //ioaiu_random_all_ops_no_dvm_seque//nce svt_axi_ace_seq_h;
//    ioaiu_axi_ace_master_base_virtual_sequence_controls vseq_controls;
//    
//    vseq_controls = ioaiu_axi_ace_master_base_virtual_sequence_controls::type_id::create("vseq_controls");
//    
//    `uvm_info("concerto_fullsys_test::run_ioaiu_ace_test_seq",$psprintf("Starting sequence on IOAIU[%0d/%0s]",ioaiu_port_id,initiator_port_name),UVM_LOW)
//    vseq_controls.readonce_wt            = 0;                          // Generates svt_axi_transaction::READONCE           
//    vseq_controls.readclean_wt           = 0;                          // Generates svt_axi_transaction::READCLEAN          
//    vseq_controls.readnotshareddirty_wt  = 0;                          // Generates svt_axi_transaction::READNOTSHAREDDIRTY 
//    vseq_controls.readshared_wt          = 0;                          // Generates svt_axi_transaction::READSHARED         
//    vseq_controls.readunique_wt          = 0;                          // Generates svt_axi_transaction::READUNIQUE         
//    vseq_controls.cleanunique_wt         = 0;                          // Generates svt_axi_transaction::CLEANUNIQUE        
//    vseq_controls.cleanshared_wt         = 0;                          // Generates svt_axi_transaction::CLEANSHARED        
//    vseq_controls.cleansharedpersist_wt  = 0;                          // Generates svt_axi_transaction::CLEANSHAREDPERSIST 
//    vseq_controls.cleaninvalid_wt        = 0;                          // Generates svt_axi_transaction::CLEANINVALID       
//    vseq_controls.makeunique_wt          = 0;                          // Generates svt_axi_transaction::MAKEUNIQUE         
//    vseq_controls.makeinvalid_wt         = 0;                          // Generates svt_axi_transaction::MAKEINVALID        
//    //vseq_controls.writenosnoop_wt        = 1;                          // Generates svt_axi_transaction::WRITENOSNOOP       
//    vseq_controls.writeunique_wt         = 0;                          // Generates svt_axi_transaction::WRITEUNIQUE        
//    vseq_controls.writelineunique_wt     = 0;                          // Generates svt_axi_transaction::WRITELINEUNIQUE    
//    vseq_controls.writeback_wt           = 0;                          // Generates svt_axi_transaction::WRITEBACK          
//    vseq_controls.writeclean_wt          = 0;                          // Generates svt_axi_transaction::WRITECLEAN         
//    vseq_controls.evict_wt               = 0;                          // Generates svt_axi_transaction::EVICT              
//    vseq_controls.writeevict_wt          = 0;    
//    // Assign xact weights
//    if(conc_ioaiu_fnnativeif_array[ioaiu_port_id]=="ACE") begin
//        //vseq_controls.readnosnoop_wt         = 1;                          // Generates svt_axi_transaction::READNOSNOOP        
//        vseq_controls.readonce_wt            = 1;                          // Generates svt_axi_transaction::READONCE           
//        vseq_controls.readclean_wt           = 1;                          // Generates svt_axi_transaction::READCLEAN          
//        vseq_controls.readnotshareddirty_wt  = 1;                          // Generates svt_axi_transaction::READNOTSHAREDDIRTY 
//        vseq_controls.readshared_wt          = 1;                          // Generates svt_axi_transaction::READSHARED         
//        vseq_controls.readunique_wt          = 1;                          // Generates svt_axi_transaction::READUNIQUE         
//      if ($test$plusargs("use_nondata")) begin
//        vseq_controls.cleanunique_wt         = 1;                          // Generates svt_axi_transaction::CLEANUNIQUE        
//        vseq_controls.cleanshared_wt         = 1;                          // Generates svt_axi_transaction::CLEANSHARED        
//        vseq_controls.cleansharedpersist_wt  = 1;                          // Generates svt_axi_transaction::CLEANSHAREDPERSIST 
//        vseq_controls.cleaninvalid_wt        = 1;                          // Generates svt_axi_transaction::CLEANINVALID       
//        vseq_controls.makeunique_wt          = 1;                          // Generates svt_axi_transaction::MAKEUNIQUE         
//        vseq_controls.makeinvalid_wt         = 1;                          // Generates svt_axi_transaction::MAKEINVALID       
//      end 
//        //vseq_controls.writenosnoop_wt        = 1;                          // Generates svt_axi_transaction::WRITENOSNOOP       
//        vseq_controls.writeunique_wt         = 1;                          // Generates svt_axi_transaction::WRITEUNIQUE        
//        vseq_controls.writelineunique_wt     = 1;                          // Generates svt_axi_transaction::WRITELINEUNIQUE    
//     if ($test$plusargs("use_copyback")) begin
//        vseq_controls.writeback_wt           = 1;                          // Generates svt_axi_transaction::WRITEBACK          
//        vseq_controls.writeclean_wt          = 1;                          // Generates svt_axi_transaction::WRITECLEAN         
//        vseq_controls.evict_wt               = 1;                          // Generates svt_axi_transaction::EVICT              
//        vseq_controls.writeevict_wt          = 1;                          // Generates svt_axi_transaction::WRITEEVICT         
//      end 
//    end else if(conc_ioaiu_fnnativeif_array[ioaiu_port_id]=="ACE-LITE") begin
//        //vseq_controls.readnosnoop_wt              =  1;
//        vseq_controls.readonce_wt                 =  1;
//        vseq_controls.readclean_wt                =  0;
//        vseq_controls.readnotshareddirty_wt       =  0;
//        vseq_controls.readshared_wt               =  0;
//        vseq_controls.readunique_wt               =  0;
//      if ($test$plusargs("use_nondata")) begin
//        vseq_controls.cleanunique_wt              =  0;
//        vseq_controls.cleanshared_wt              =  1;
//        vseq_controls.cleansharedpersist_wt       =  1;
//        vseq_controls.cleaninvalid_wt             =  1;
//        vseq_controls.makeunique_wt               =  0;
//        vseq_controls.makeinvalid_wt              =  1;
//      end 
//        //vseq_controls.writenosnoop_wt             =  1;
//        vseq_controls.writeunique_wt              =  1;
//        vseq_controls.writelineunique_wt          =  1;
//     if ($test$plusargs("use_copyback")) begin
//        vseq_controls.writeback_wt                =  0;
//        vseq_controls.writeclean_wt               =  0;
//        vseq_controls.evict_wt                    =  0; 
//        vseq_controls.writeevict_wt               =  0;
//     end
//     if($test$plusargs("en_excl_txn")) begin
//        vseq_controls.cleanunique_wt              =  3;
//     end
//        vseq_controls.readoncecleaninvalid_wt     =  1;
//        vseq_controls.readoncemakeinvalid_wt      =  1;
//    end else if(conc_ioaiu_fnnativeif_array[ioaiu_port_id]=="ACELITE-E") begin
//        //vseq_controls.readnosnoop_wt              =  1;
//        vseq_controls.readonce_wt                 =  1;
//        vseq_controls.readclean_wt                =  0;
//        vseq_controls.readnotshareddirty_wt       =  0;
//        vseq_controls.readshared_wt               =  0;
//        vseq_controls.readunique_wt               =  0;
//      if ($test$plusargs("use_nondata")) begin
//        vseq_controls.cleanunique_wt              =  0;
//        vseq_controls.cleanshared_wt              =  1;
//        vseq_controls.cleansharedpersist_wt       =  1;
//        vseq_controls.cleaninvalid_wt             =  1;
//        vseq_controls.makeunique_wt               =  0;
//        vseq_controls.makeinvalid_wt              =  1;
//      end
//        //vseq_controls.writenosnoop_wt             =  1;
//        vseq_controls.writeunique_wt              =  1;
//        vseq_controls.writelineunique_wt          =  1;
//     if ($test$plusargs("use_copyback")) begin
//        vseq_controls.writeback_wt                =  0;
//        vseq_controls.writeclean_wt               =  0;
//        vseq_controls.evict_wt                    =  0; 
//        vseq_controls.writeevict_wt               =  0;
//     end
//        vseq_controls.readoncecleaninvalid_wt     =  1;
//        vseq_controls.readoncemakeinvalid_wt      =  1;
//    
//    `ifdef SVT_ACE5_ENABLE
//         // CONC-11906 : To-do Add logic for stash target to be chiaiu only
//     if($test$plusargs("use_stash")) begin
//        vseq_controls.writeuniqueptlstash_wt      = 0;  
//        vseq_controls.writeuniquefullstash_wt     = 0;  
//        vseq_controls.stashonceunique_wt          = 0;  
//        vseq_controls.stashonceshared_wt          = 0;  
//     end 
//         // CONC-11906 : To-do ACE5 feature - Check for cmo on write support
//        vseq_controls.cmo_wt                        = 0; // zero weight due to unsure of cmo on write support
//        vseq_controls.writeptlcmo_wt                = 0; // zero weight due to unsure of cmo on write support
//        vseq_controls.writefullcmo_wt               = 0; // zero weight due to unsure of cmo on write support
//    `endif
//    end else if(conc_ioaiu_fnnativeif_array[ioaiu_port_id]=="AXI4") begin
//        vseq_controls.write_wt                      = 1;
//        vseq_controls.read_wt                       = 1;
//    end
//
//    `uvm_info("concerto_fullsys_test::run_ioaiu_ace_test_seq",$psprintf("Starting sequence-%0s on IOAIU[ioaiu_port_id=%0d,initiator_port_name=%0s,native-if=%0s] sequencer-%0s",seq_name,ioaiu_port_id,initiator_port_name,conc_ioaiu_fnnativeif_array[ioaiu_port_id],`CONC_COMMON_STRINGIFY(`CONC_SVT_AXI_SYSSEQR_PATH)),UVM_LOW)
//    `uvm_info("concerto_fullsys_test::run_ioaiu_ace_test_seq",$psprintf("Setting variables through config db. sequence_length %0d port_id %0d ",ioaiu_num_trans,ioaiu_port_id),UVM_LOW)
//    seq_inst = $sformatf("svt_axi_ace_seq_h_%0d",ioaiu_port_id);
//    //svt_axi_ace_seq_h = ioaiu_random_all_ops_no_dvm_sequence::type_id::create(seq_inst);
//    uvm_config_db#(ioaiu_axi_ace_master_base_virtual_sequence_controls)::set(this, $psprintf("%0s.%0s",conc_svt_axi_sysseqr_path_str,seq_inst), "vseq_controls", vseq_controls);
//    uvm_config_db#(int unsigned)::set(this, $psprintf("%0s.%0s",conc_svt_axi_sysseqr_path_str,seq_inst), "sequence_length", ioaiu_num_trans);
//    uvm_config_db#(int unsigned)::set(this, $psprintf("%0s.%0s",conc_svt_axi_sysseqr_path_str,seq_inst), "port_id", ioaiu_port_id);
//    //svt_axi_ace_seq_h.start(`CONC_SVT_AXI_SYSSEQR_PATH);
//    `uvm_info("concerto_fullsys_test::run_ioaiu_ace_test_seq",$psprintf("Ending sequence-%0s on IOAIU[ioaiu_port_id=%0d,initiator_port_name=%0s,native-if=%0s]",seq_name,ioaiu_port_id,initiator_port_name,conc_ioaiu_fnnativeif_array[ioaiu_port_id]),UVM_LOW)
//  end
//endtask

//task concerto_fullsys_test::run_ioaiu_axi4_test_seq(input string initiator_port_name="", int ioaiu_port_id=0);
//    string seq_name="ioaiu_axi_random_sequence";
//    string seq_inst="";
//    ioaiu_axi_random_sequence svt_axi_seq_h;
//
//    `uvm_info("concerto_iosubsys_axi_random_snps::run_ioaiu_axi4_test_seq",$psprintf("Starting sequence-%0s on IOAIU[ioaiu_port_id=%0d,initiator_port_name=%0s,native-if=%0s] sequencer-%0s",seq_name,ioaiu_port_id,initiator_port_name,conc_ioaiu_fnnativeif_array[ioaiu_port_id],`CONC_COMMON_STRINGIFY(`CONC_SVT_AXI_SYSSEQR_PATH)),UVM_LOW)
//    `uvm_info("concerto_iosubsys_axi_random_snps::run_ioaiu_axi4_test_seq",$psprintf("Setting variables through config db. sequence_length %0d port_id %0d ",ioaiu_num_trans,ioaiu_port_id),UVM_LOW)
//    seq_inst = $sformatf("svt_axi_seq_h_%0d",ioaiu_port_id);
//    svt_axi_seq_h = ioaiu_axi_random_sequence::type_id::create(seq_inst);
//    svt_axi_seq_h.sequence_length = ioaiu_num_trans;
//    svt_axi_seq_h.start(m_concerto_env.snps.svt.amba_system_env.axi_system[0].sequencer.master_sequencer[ioaiu_port_id]);
//    `uvm_info("concerto_iosubsys_axi_random_snps::run_ioaiu_axi4_test_seq",$psprintf("Ending sequence-%0s on IOAIU[ioaiu_port_id=%0d,initiator_port_name=%0s,native-if=%0s]",seq_name,ioaiu_port_id,initiator_port_name,conc_ioaiu_fnnativeif_array[ioaiu_port_id]),UVM_LOW)
//endtask

//CONC-11906 To-Do: Move all below in concerto_helper_pkg_snps.svh
task concerto_fullsys_test::initialize_conc_helper_var_snps();

<% let ioaiu_cntr=0;   ioaiu_idx_with_multi_core=0;
for(let pidx=0; pidx<obj.nAIUs; pidx++) {  
if(!obj.AiuInfo[pidx].fnNativeInterface.match("CHI")) { 
for(let i=0; i<obj.AiuInfo[pidx].nNativeInterfacePorts; i++) { %>
    io_subsys_mstr_agnt_seqr_a[<%=ioaiu_idx_with_multi_core%>]   = `SVT_IOAIU<%=ioaiu_cntr%>_<%=i%>_MASTER_SEQR_PATH;
    io_subsys_mstr_agnt_seqr_str[<%=ioaiu_idx_with_multi_core%>] = $psprintf("%0s",`STRINGIFY(`SVT_IOAIU<%=ioaiu_cntr%>_<%=i%>_MASTER_SEQR_PATH));
<% ioaiu_idx_with_multi_core = ioaiu_idx_with_multi_core + 1;} ioaiu_cntr = ioaiu_cntr + 1;} } %>

    `uvm_info("CONCERTO_FULLSYS_TEST", $psprintf("fn:initialize_conc_helper_var_snps mstr_agnt_seqr_str - %0p", io_subsys_mstr_agnt_seqr_str), UVM_LOW);
 
endtask: initialize_conc_helper_var_snps
<% } %>

function concerto_fullsys_test concerto_fullsys_test::get_instance();
concerto_fullsys_test fullsys_test;
uvm_root top;
  top = uvm_root::get();
  if(top.get_child(inst_name)==null) begin
      $display("concerto_fullsys_test, could not find handle of fullsys_test %0s",inst_name);
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
function void concerto_fullsys_test::end_of_elaboration_phase(uvm_phase phase);
    int file_handle;
    `uvm_info("end_of_elaboration_phase", "Entered...", UVM_LOW)
    <% if (numIoAiu > 0) { %> 
    if(m_concerto_env_cfg.has_axi_vip_snps) begin: _vip_
        initialize_conc_helper_var_snps(); 
    end: _vip_
    else begin: _inhouse_
   <% ioaiu_idx = 0; %>
    <% for(let pidx = 0 ; pidx < obj.nAIUs; pidx++) { %>

    <% if(!obj.AiuInfo[pidx].fnNativeInterface.match("CHI")) { %>
        `uvm_info("end_of_elaboration_phase", "Fast delays on master channel for IOAIU<%=ioaiu_idx%>", UVM_LOW)
      <%if(obj.AiuInfo[pidx].cmpInfo.nDvmSnpInFlight > 0){%>
        
        `uvm_info("end_of_elaboration_phase", "Fast delays on snoop channel for IOAIU<%=ioaiu_idx%>", UVM_LOW)
        m_concerto_env_cfg.m_ioaiu<%=ioaiu_idx%>_env_cfg[0].m_axi_master_agent_cfg.k_ace_master_snoop_addr_chnl_delay_min.set_value(0);
        m_concerto_env_cfg.m_ioaiu<%=ioaiu_idx%>_env_cfg[0].m_axi_master_agent_cfg.k_ace_master_snoop_addr_chnl_delay_max.set_value(0);
        m_concerto_env_cfg.m_ioaiu<%=ioaiu_idx%>_env_cfg[0].m_axi_master_agent_cfg.k_ace_master_snoop_addr_chnl_burst_pct.set_value(100);
        m_concerto_env_cfg.m_ioaiu<%=ioaiu_idx%>_env_cfg[0].m_axi_master_agent_cfg.k_ace_master_snoop_data_chnl_delay_min.set_value(0);
        m_concerto_env_cfg.m_ioaiu<%=ioaiu_idx%>_env_cfg[0].m_axi_master_agent_cfg.k_ace_master_snoop_data_chnl_delay_max.set_value(0);
        m_concerto_env_cfg.m_ioaiu<%=ioaiu_idx%>_env_cfg[0].m_axi_master_agent_cfg.k_ace_master_snoop_data_chnl_burst_pct.set_value(100);
     if( $test$plusargs("ac_snoop_bkp")) begin
        m_concerto_env_cfg.m_ioaiu<%=ioaiu_idx%>_env_cfg[0].m_axi_master_agent_cfg.k_ace_master_snoop_resp_chnl_delay_min.set_value(200);
        m_concerto_env_cfg.m_ioaiu<%=ioaiu_idx%>_env_cfg[0].m_axi_master_agent_cfg.k_ace_master_snoop_resp_chnl_delay_max.set_value(250);
        m_concerto_env_cfg.m_ioaiu<%=ioaiu_idx%>_env_cfg[0].m_axi_master_agent_cfg.k_ace_master_snoop_resp_chnl_burst_pct.set_value(0);

     end else begin
        m_concerto_env_cfg.m_ioaiu<%=ioaiu_idx%>_env_cfg[0].m_axi_master_agent_cfg.k_ace_master_snoop_resp_chnl_delay_min.set_value(0);
        m_concerto_env_cfg.m_ioaiu<%=ioaiu_idx%>_env_cfg[0].m_axi_master_agent_cfg.k_ace_master_snoop_resp_chnl_delay_max.set_value(0);
        m_concerto_env_cfg.m_ioaiu<%=ioaiu_idx%>_env_cfg[0].m_axi_master_agent_cfg.k_ace_master_snoop_resp_chnl_burst_pct.set_value(100);
     end
    <%}%>

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
    <% } //foreach interfacesPort%> 
    <% ioaiu_idx++; } %>
    <% } %>
    end: _inhouse_
<% } %>
   `ifdef IO_UNITS_CNT_NON_ZERO
     configure_ioaiu_mstr_seqs();
   `endif

    if (this.get_report_verbosity_level() > UVM_LOW) begin
        uvm_top.print_topology();
    end
    `uvm_info("end_of_elaboration_phase", "Exiting...", UVM_LOW)
endfunction: end_of_elaboration_phase

function void concerto_fullsys_test::start_of_simulation_phase(uvm_phase phase);
  string     chiaiu_en_str[];
  string     ioaiu_en_str[];
  string     chiaiu_en_arg;
  string     ioaiu_en_arg;
  uvm_factory factory = uvm_factory::get();

  `uvm_info("FULLSYS_TEST", "START_OF_SIMULATION", UVM_LOW)
  super.start_of_simulation_phase(phase);

   //SVT OVERRIDE
    if(vip_snps_non_coherent_txn) begin
      set_type_override_by_type(svt_chi_rn_transaction::get_type(),rn_noncoherent_transaction::get_type());
    end
    else if(vip_snps_coherent_txn) begin
      set_type_override_by_type(svt_chi_rn_transaction::get_type(),rn_coherent_transaction::get_type());
    end    
    else begin
    `ifndef CHI_SUBSYS
            `ifdef CHI_UNITS_CNT_NON_ZERO
           <% let cidx = 0; %>
           <% for(idx = 0; idx < obj.nAIUs; idx++) {
            if(obj.AiuInfo[idx].fnNativeInterface.match('CHI')) { %>
            if (!uvm_re_match(uvm_glob_to_re("chi_subsys_random_coherency_vseq"),test_cfg.chi_subsys_vseq_name)) begin:_match_chi<%=cidx%>
                if(test_cfg.chi_txn_seq_name != "svt_chi_rn_transaction" && !test_cfg.disable_override_svt_chi_txn)
                    factory.set_inst_override_by_name("svt_chi_rn_transaction",test_cfg.chi_txn_seq_name,"uvm_test_top.m_concerto_env.snps.svt.amba_system_env.chi_system[0].rn[<%=cidx%>].*");  
            end:_match_chi<%=cidx%> else begin:_no_match_chi<%=cidx%>
                if(test_cfg.chi_txn_seq_name != "svt_chi_rn_transaction" && !test_cfg.disable_override_svt_chi_txn) begin
                  factory.set_inst_override_by_name("svt_chi_rn_transaction","chi_subsys_base_item","uvm_test_top.m_concerto_env.snps.svt.amba_system_env.chi_system[0].rn[<%=cidx%>].*"); // use chi_subsys_base_item to remove DATA_ERROR 
                  factory.set_inst_override_by_name("chi_subsys_base_item",test_cfg.chi_txn_seq_name,"uvm_test_top.m_concerto_env.snps.svt.amba_system_env.chi_system[0].rn[<%=cidx%>].rn_xact_seqr.m_random_seq*"); //xact only txn 
                end
            end:_no_match_chi<%=cidx%>
            <%cidx++;}}%> 
            if(test_cfg.chi_snp_seq_name != "svt_chi_rn_snoop_transaction")
                factory.set_type_override_by_name("svt_chi_rn_snoop_transaction", test_cfg.chi_snp_seq_name);
            `endif // CHI_UNITS_CNT_NON_ZERO
    `endif
    end
     `ifdef CHI_UNITS_CNT_NON_ZERO
    if (m_concerto_env_cfg.has_chi_vip_snps) begin:_chi_snps_vip
        if(test_cfg.chi_subsys_vseq_name != "chi_subsys_random_vseq")
            factory.set_type_override_by_name("chi_subsys_random_vseq", test_cfg.chi_subsys_vseq_name);
    end:_chi_snps_vip
    `endif

  `ifdef IO_UNITS_CNT_NON_ZERO
    if (m_concerto_env_cfg.has_axi_vip_snps) begin:_io_snps_vip
        if(test_cfg.io_subsys_vseq_name != "io_subsys_snps_vseq")
            factory.set_type_override_by_name("io_subsys_snps_vseq", test_cfg.io_subsys_vseq_name);
    end:_io_snps_vip
    else begin:io_inhouse_seq      
     <% qidx=0; for(let pidx = 0; pidx < obj.nAIUs; pidx++) { %>
    <% if(!(obj.AiuInfo[pidx].fnNativeInterface.match("CHI"))) { %>
         //sys_event agent seq      
    <% for(let i=0; i<aiu_NumCores[pidx]; i++) { %> 
        if(test_cfg.io_subsys_inhouse_seq_name != "axi_master_pipelined_seq") begin
          factory.set_type_override_by_name("ioaiu<%=qidx%>_inhouse_axi_bfm_pkg::axi_master_pipelined_seq","ioaiu<%=qidx%>_inhouse_axi_bfm_pkg::read_after_write_sequance");
        end
   <%}%>

    <%}%>
   <% qidx++;}%>

    end:io_inhouse_seq

  `endif

  if(test_cfg.fsys_vseq_name != "fsys_main_traffic_virtual_seq")
      factory.set_type_override_by_name("fsys_main_traffic_virtual_seq", test_cfg.fsys_vseq_name);

    fsys_main_traffic_vseq = fsys_main_traffic_virtual_seq::type_id::create("fsys_main_traffic_vseq");

    factory.print(0); // print only override
   // SVT OVERRIDE END
 
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
    <% chiaiu_idx=0; for(let pidx = 0 ; pidx < obj.nAIUs; pidx++) { %>
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
    <% ioaiu_idx=0; for(let pidx = 0 ; pidx < obj.nAIUs; pidx++) { %>
    <% if((obj.AiuInfo[pidx].fnNativeInterface != 'CHI-A')&&(obj.AiuInfo[pidx].fnNativeInterface != 'CHI-B')&&(obj.AiuInfo[pidx].fnNativeInterface != 'CHI-E')) { %>
       ioaiu_en[<%=ioaiu_idx%>] = 1;
       <% ioaiu_idx++; } %>
    <% } %>
    end else begin
       parse_str(ioaiu_en_str, "n", ioaiu_en_arg);
       foreach (ioaiu_en_str[i]) begin
	  ioaiu_en[ioaiu_en_str[i].atoi()] = 1;
          //`uvm_info("FULLSYS_TEST", $sformatf("ioaiu_en[%0d] = %0d", ioaiu_en_str[i].atoi(), ioaiu_en[ioaiu_en_str[i].atoi()]), UVM_NONE)
       end
    end

    hook_aiu_en();

    foreach(chiaiu_en[i]) begin
      t_chiaiu_en[i]= chiaiu_en[i];
       `uvm_info("FULLSYS_TEST", $sformatf("chiaiu_en[%0d] = %0d", i, chiaiu_en[i]), UVM_MEDIUM)
    end
    foreach(ioaiu_en[i]) begin
      t_ioaiu_en[i]= ioaiu_en[i];
       `uvm_info("FULLSYS_TEST", $sformatf("ioaiu_en[%0d] = %0d", i, ioaiu_en[i]), UVM_MEDIUM)
    end

    if(!$value$plusargs("chiaiu_qos=%s", chiaiu_qos_arg)) begin
       chiaiu_user_qos = 0;
    <% chiaiu_idx=0; for(let pidx = 0 ; pidx < obj.nAIUs; pidx++) { %>
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
    <% ioaiu_idx=0; for(let pidx = 0 ; pidx < obj.nAIUs; pidx++) { %>
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
    <% qidx=0;idx=0; for(let pidx = 0; pidx < obj.nAIUs; pidx++) { %>
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
    <% qidx=0; for(let pidx = 0; pidx < obj.nAIUs; pidx++) { %>
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
  <% idx=0; for(let pidx = 0; pidx < obj.nAIUs; pidx++) { %>
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
    if($test$plusargs("perf_test_tens")) begin
      m_chi<%=idx%>_vseq.duty_cycle = chi_duty_cycle;
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
       
         <% idx++;  %> 
       <%} %>          
       <%} %>          
    end:_setup_chi_inhouse_seq // TODO MOVE IN VIRTUAL SEQ

   // use in case CHI-B + SNPS VIP // TODO MOVE in VIRTUAL SEQ
    <% idx=0; for(let pidx = 0; pidx < obj.nAIUs; pidx++) { %>
    <% if(obj.AiuInfo[pidx].fnNativeInterface.match("CHI")) { %>
    m_chi<%=idx%>_args = chi_aiu_unit_args_pkg::chi_aiu_unit_args::type_id::create("chi_aiu_unit_args<%=idx%>");
    m_chi<%=idx%>_args.k_num_requests.set_value(chi_num_trans);
    m_chi<%=idx%>_args.k_coh_addr_pct.set_value(50);
    m_chi<%=idx%>_args.k_noncoh_addr_pct.set_value(50);
    m_chi<%=idx%>_args.k_device_type_mem_pct.set_value(50);
    m_chi<%=idx%>_args.k_new_addr_pct.set_value(50);
     //if (!m_concerto_env_cfg.has_chi_vip_snps) m_chi<%=idx%>_vseq.set_unit_args(m_chi<%=idx%>_args);

    // read
     m_chi<%=idx%>_read_args = chi_aiu_unit_args_pkg::chi_aiu_unit_args::type_id::create($psprintf("chi_aiu_unit_read_args[%0d]", 0));
     m_chi<%=idx%>_read_args.k_num_requests.set_value(chi_num_trans);
     m_chi<%=idx%>_read_args.k_coh_addr_pct.set_value(50);
     m_chi<%=idx%>_read_args.k_noncoh_addr_pct.set_value(50);
     m_chi<%=idx%>_read_args.k_device_type_mem_pct.set_value(50);
     m_chi<%=idx%>_read_args.k_new_addr_pct.set_value(50);
     if (!m_concerto_env_cfg.has_chi_vip_snps) m_chi<%=idx%>_read_vseq.set_unit_args(m_chi<%=idx%>_read_args);


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
                      //#Stimulus.FSYS.sysevent.dii_dmi
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
            if($test$plusargs("perf_test_tens")) begin 
              m_chi<%=idx%>_args.k_alloc_hint_pct.set_value(100);
              m_chi<%=idx%>_args.k_cacheable_pct.set_value(100);
              m_chi<%=idx%>_args.k_rq_lcrdrt_pct.set_value(100); 
              m_chi<%=idx%>_args.k_rd_rdonce_pct.set_value(100);
            end
            if (!m_concerto_env_cfg.has_chi_vip_snps) m_chi<%=idx%>_vseq.set_unit_args(m_chi<%=idx%>_args);
      <% idx++;  %>
    <%} %>
    <%} %>

if (m_concerto_env_cfg.has_chi_vip_snps) begin // TODO MOVE IN VIRTUAL SEQ
<% if(numChiAiu > 0) { %>
   // TMP VERY UGLY due to m_args static in chi_item TODO MOVE IN VIRUTAL SEQ
    m_svt_chi_item.m_args =  m_chi0_args; // !!! STATIC !!!! 
<%} %>
end
    
    if (!m_concerto_env_cfg.has_axi_vip_snps) begin:_setup_axi_inhouse_seq // TODO MOVE IN VIRTUAL SEQ
         <% qidx=0; cidx=0; for(let pidx = 0; pidx < obj.nAIUs; pidx++) { %>
         <% if(!(obj.AiuInfo[pidx].fnNativeInterface.match("CHI"))) { %>
         <%if(obj.AiuInfo[pidx].fnNativeInterface == 'ACE-LITE' || obj.AiuInfo[pidx].fnNativeInterface == 'ACELITE-E' || obj.AiuInfo[pidx].fnNativeInterface == 'ACE' || obj.AiuInfo[pidx].fnNativeInterface == 'ACE5' || obj.AiuInfo[pidx].fnNativeInterface == 'AXI4' || obj.AiuInfo[pidx].fnNativeInterface == 'AXI5') { %>
              fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.ioaiu_en   	= ioaiu_en;
              //io_subsys_mstr_seq_cfg_inhouse<%=qidx%> = ioaiu<%=qidx%>_inhouse_axi_bfm_pkg::io_mstr_seq_cfg::type_id::create("io_subsys_mstr_seq_cfg_inhouse<%=qidx%>");

              io_subsys_mstr_seq_cfg_inhouse<%=qidx%> = ioaiu<%=qidx%>_inhouse_axi_bfm_pkg::io_mstr_seq_cfg::type_id::create($psprintf("<%=obj.AiuInfo[pidx].fnNativeInterface%>_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_mstr_seq_cfg_p<%=qidx%>_s%0d",seq_id));

              io_subsys_mstr_seq_cfg_inhouse<%=qidx%>.init_master_info(ncoreConfigInfo::io_subsys_nativeif_a[<%=cidx%>].tolower(), "<%=obj.AiuInfo[pidx].strRtlNamePrefix%>", <%=obj.AiuInfo[pidx].FUnitId%>,<%=obj.AiuInfo[pidx].useCache%>,"<%=obj.AiuInfo[pidx].orderedWriteObservation%>");

             // uvm_config_db #(ioaiu<%=qidx%>_inhouse_axi_bfm_pkg::mstr_seq_cfg)::set(uvm_root::get(),"*", "io_subsys_mstr_seq_cfg_inhouse<%=qidx%>", io_subsys_mstr_seq_cfg_inhouse<%=qidx%>);

              uvm_config_db #(ioaiu<%=qidx%>_inhouse_axi_bfm_pkg::mstr_seq_cfg)::set(uvm_root::get(),"*", $sformatf("<%=obj.AiuInfo[pidx].fnNativeInterface%>_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_mstr_seq_cfg_p<%=qidx%>_s%0d",seq_id), io_subsys_mstr_seq_cfg_inhouse<%=qidx%>);

             // `uvm_info(get_full_name(), $sformatf("Setting <%=obj.AiuInfo[pidx].fnNativeInterface%>_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_mstr_seq_cfg_p<%=qidx%>_s%0d as io_subsys_mstr_seq_cfg_inhouse<%=qidx%>",seq_id), UVM_LOW)
           <%}%>
              //sys_event agent seq
         <% for(let i=0; i<aiu_NumCores[pidx]; i++) { %> 

         fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_seq<%=qidx%>[<%=i%>].core_id = <%=i%>;
         fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_seq<%=qidx%>[<%=i%>].set_seq_name("m_ioaiu<%=qidx%>_seq[<%=i%>]");
         fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_seq<%=qidx%>[<%=i%>].m_read_addr_chnl_seqr  = m_concerto_env.inhouse.m_ioaiu<%=qidx%>_env.m_env[<%=i%>].m_axi_master_agent.m_read_addr_chnl_seqr;
         fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_seq<%=qidx%>[<%=i%>].m_read_data_chnl_seqr  = m_concerto_env.inhouse.m_ioaiu<%=qidx%>_env.m_env[<%=i%>].m_axi_master_agent.m_read_data_chnl_seqr;
         fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_seq<%=qidx%>[<%=i%>].m_write_addr_chnl_seqr = m_concerto_env.inhouse.m_ioaiu<%=qidx%>_env.m_env[<%=i%>].m_axi_master_agent.m_write_addr_chnl_seqr;
         fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_seq<%=qidx%>[<%=i%>].m_write_data_chnl_seqr = m_concerto_env.inhouse.m_ioaiu<%=qidx%>_env.m_env[<%=i%>].m_axi_master_agent.m_write_data_chnl_seqr;
         fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_seq<%=qidx%>[<%=i%>].m_write_resp_chnl_seqr = m_concerto_env.inhouse.m_ioaiu<%=qidx%>_env.m_env[<%=i%>].m_axi_master_agent.m_write_resp_chnl_seqr;
         fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_seq<%=qidx%>[<%=i%>].m_ace_cache_model      = m_concerto_env.inhouse.m_ace_cache_model_ioaiu<%=qidx%>[<%=i%>];
         fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_seq<%=qidx%>[<%=i%>].k_directed_test        = k_directed_test;

         // read
         // if (k_directed_test_same_aiu) begin
             fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_read_seq<%=qidx%>[<%=i%>].core_id = <%=i%> ;
             fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_read_seq<%=qidx%>[<%=i%>].set_seq_name("m_ioaiu<%=qidx%>_read_seq[<%=i%>]");
             fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_read_seq<%=qidx%>[<%=i%>].m_read_addr_chnl_seqr  = m_concerto_env.inhouse.m_ioaiu<%=qidx%>_env.m_env[<%=i%>].m_axi_master_agent.m_read_addr_chnl_seqr;
             fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_read_seq<%=qidx%>[<%=i%>].m_read_data_chnl_seqr  = m_concerto_env.inhouse.m_ioaiu<%=qidx%>_env.m_env[<%=i%>].m_axi_master_agent.m_read_data_chnl_seqr;
             fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_read_seq<%=qidx%>[<%=i%>].m_write_addr_chnl_seqr = m_concerto_env.inhouse.m_ioaiu<%=qidx%>_env.m_env[<%=i%>].m_axi_master_agent.m_write_addr_chnl_seqr;
             fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_read_seq<%=qidx%>[<%=i%>].m_write_data_chnl_seqr = m_concerto_env.inhouse.m_ioaiu<%=qidx%>_env.m_env[<%=i%>].m_axi_master_agent.m_write_data_chnl_seqr;
             fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_read_seq<%=qidx%>[<%=i%>].m_write_resp_chnl_seqr = m_concerto_env.inhouse.m_ioaiu<%=qidx%>_env.m_env[<%=i%>].m_axi_master_agent.m_write_resp_chnl_seqr;
             fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_read_seq<%=qidx%>[<%=i%>].m_ace_cache_model      = m_concerto_env.inhouse.m_ace_cache_model_ioaiu<%=qidx%>[<%=i%>];
             fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_read_seq<%=qidx%>[<%=i%>].k_directed_test        = k_directed_test;
         // end

           <% if((obj.AiuInfo[pidx].fnNativeInterface == 'ACE') || (obj.AiuInfo[pidx].fnNativeInterface == 'ACE5') ||(aiu_axiInt[pidx].params.eAc==1) ){ %>
         fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iosnoop_seq<%=qidx%>[<%=i%>].m_read_addr_chnl_seqr   = m_concerto_env.inhouse.m_ioaiu<%=qidx%>_env.m_env[<%=i%>].m_axi_master_agent.m_read_addr_chnl_seqr;
         fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iosnoop_seq<%=qidx%>[<%=i%>].m_read_data_chnl_seqr   = m_concerto_env.inhouse.m_ioaiu<%=qidx%>_env.m_env[<%=i%>].m_axi_master_agent.m_read_data_chnl_seqr;
         fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iosnoop_seq<%=qidx%>[<%=i%>].m_snoop_addr_chnl_seqr  = m_concerto_env.inhouse.m_ioaiu<%=qidx%>_env.m_env[<%=i%>].m_axi_master_agent.m_snoop_addr_chnl_seqr;
         fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iosnoop_seq<%=qidx%>[<%=i%>].m_snoop_data_chnl_seqr  = m_concerto_env.inhouse.m_ioaiu<%=qidx%>_env.m_env[<%=i%>].m_axi_master_agent.m_snoop_data_chnl_seqr;
         fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iosnoop_seq<%=qidx%>[<%=i%>].m_snoop_resp_chnl_seqr  = m_concerto_env.inhouse.m_ioaiu<%=qidx%>_env.m_env[<%=i%>].m_axi_master_agent.m_snoop_resp_chnl_seqr;
         fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iosnoop_seq<%=qidx%>[<%=i%>].m_ace_cache_model       = m_concerto_env.inhouse.m_ace_cache_model_ioaiu<%=qidx%>[<%=i%>];

           <%}%>

		    if ($test$plusargs("fsys_force_sameaxid")) begin
               fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_seq<%=qidx%>[<%=i%>].en_force_axid=1;  
               fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_seq<%=qidx%>[<%=i%>].ioaiu_force_coh_axid=<%=qidx+1%>;  
               fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_seq<%=qidx%>[<%=i%>].ioaiu_force_noncoh_axid[0]=<%=qidx+1%>;  
               fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_seq<%=qidx%>[<%=i%>].ioaiu_force_noncoh_axid[1]=<%=qidx+1%>;  
            end
            if(ioaiu_user_qos == 1) begin
                fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_seq<%=qidx%>[<%=i%>].user_qos       = 1;
                fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_seq<%=qidx%>[<%=i%>].aiu_qos        = ioaiu_qos[<%=qidx%>];
            end
         <% cidx++;} // foreach core %>
         <% qidx++; } //foreach ioaiu%>
         <% } // foreahc AIU%>
    end:_setup_axi_inhouse_seq // TODO MOVE IN VIRTUAL SEQ

if (m_concerto_env_cfg.has_axi_vip_snps) begin:_setup_axi_vip_seq_init // TODO MOVE IN VIRTUAL SEQ
         <% qidx=0; for(let pidx = 0; pidx < obj.nAIUs; pidx++) { %>
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
      <%if(obj.AiuInfo[pidx].fnNativeInterface == 'ACE-LITE' || obj.AiuInfo[pidx].fnNativeInterface == 'ACELITE-E' || obj.AiuInfo[pidx].fnNativeInterface == 'ACE'  || obj.AiuInfo[pidx].fnNativeInterface == 'ACE5' || obj.AiuInfo[pidx].fnNativeInterface == 'AXI4'  || obj.AiuInfo[pidx].fnNativeInterface == 'AXI5') { %>
            if ($test$plusargs("read_test")) begin
		<% if(((obj.AiuInfo[pidx].fnNativeInterface == 'AXI4') || (obj.AiuInfo[pidx].fnNativeInterface == 'AXI5')) && !obj.AiuInfo[pidx].useCache) { %>
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
		<% if(((obj.AiuInfo[pidx].fnNativeInterface == 'AXI4') || (obj.AiuInfo[pidx].fnNativeInterface == 'AXI5')) && !obj.AiuInfo[pidx].useCache) { %>
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
                   cust_seq_h<%=qidx%>[<%=i%>].wt_ace_wrlnunq      = <%=(obj.AiuInfo[pidx].fnNativeInterface != "AXI4" && obj.AiuInfo[pidx].fnNativeInterface != "AXI5")?30:0%>;
                end
            <% } %>
            end // if ($test$plusargs("write_test"))
            else begin
		<% if(((obj.AiuInfo[pidx].fnNativeInterface == 'AXI4') || (obj.AiuInfo[pidx].fnNativeInterface == 'AXI5')) && !obj.AiuInfo[pidx].useCache) { %>
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
                  <% if (obj.AiuInfo[pidx].fnNativeInterface != 'AXI4' && obj.AiuInfo[pidx].fnNativeInterface != 'AXI5') { %>
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
                    cust_seq_h<%=qidx%>[<%=i%>].wt_ace_wrlnunq      = <%=(obj.AiuInfo[pidx].fnNativeInterface != "AXI4" && obj.AiuInfo[pidx].fnNativeInterface != "AXI5")?100:0%>;
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
                    <% if(obj.AiuInfo[pidx].fnNativeInterface == 'ACE'||obj.AiuInfo[pidx].fnNativeInterface == 'ACE5') { %>
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
                    cust_seq_h<%=qidx%>[<%=i%>].wt_ace_wrlnunq      = <%=(obj.AiuInfo[pidx].fnNativeInterface != "AXI4" && obj.AiuInfo[pidx].fnNativeInterface != "AXI5")?50:0%>;
                    <% if(obj.AiuInfo[pidx].fnNativeInterface == 'ACE'||obj.AiuInfo[pidx].fnNativeInterface == 'ACE5') { %>
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

     <%if(((obj.AiuInfo[pidx].fnNativeInterface == 'AXI4' || obj.AiuInfo[pidx].fnNativeInterface == 'AXI5') && obj.AiuInfo[pidx].useCache)) {%>
         if($test$plusargs("all_gpra_ncmode"))  begin
     // TMP avoid send noncoh txn in coh mem region //TODO when gpra random should add constraint with gpra.nc when select addr in noncoh & coh mem region 
                   cust_seq_h<%=qidx%>[<%=i%>].wt_ace_rdonce       = 0;
                   cust_seq_h<%=qidx%>[<%=i%>].wt_ace_wrunq        = 0;
                end
    <% }%>

		<% if(obj.AiuInfo[pidx].fnNativeInterface != 'AXI4' && obj.AiuInfo[pidx].fnNativeInterface != 'AXI5') { %>
        <% if(obj.AiuInfo[pidx].fnNativeInterface == 'ACE'||obj.AiuInfo[pidx].fnNativeInterface == 'ACE5') { %>
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
                      <% if(obj.AiuInfo[pidx].fnNativeInterface == 'ACELITE-E' || obj.AiuInfo[pidx].fnNativeInterface == 'ACE' || obj.AiuInfo[pidx].fnNativeInterface == 'ACE5') { %>
                      cust_seq_h<%=qidx%>[<%=i%>].wt_ace_clnshrd_pers = 100;
                      <% } %>
                    end else begin
                       cust_seq_h<%=qidx%>[<%=i%>].wt_ace_clnshrd      = 0;
                       cust_seq_h<%=qidx%>[<%=i%>].wt_ace_clninvl      = 0;
                       cust_seq_h<%=qidx%>[<%=i%>].wt_ace_mkinvl       = 0;
                    end
        <% if(obj.AiuInfo[pidx].fnNativeInterface == 'ACE'||obj.AiuInfo[pidx].fnNativeInterface == 'ACE5') { %>
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
         <% if(obj.AiuInfo[pidx].fnNativeInterface == 'ACE'||obj.AiuInfo[pidx].fnNativeInterface == 'ACE5') { %>
                        cust_seq_h<%=qidx%>[<%=i%>].wt_ace_clnunq       = 150;
         <% } %>
                    end
                end
        <% if(obj.AiuInfo[pidx].fnNativeInterface == 'ACELITE-E') { %>
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
               
        <% if(((!obj.noDVM) && (obj.AiuInfo[pidx].fnNativeInterface == 'ACE'))  || ((!obj.noDVM) && (obj.AiuInfo[pidx].fnNativeInterface == 'ACE5'))) { %>
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
                    <% if (obj.AiuInfo[pidx].fnNativeInterface != 'AXI4' && obj.AiuInfo[pidx].fnNativeInterface != 'AXI5') { %>
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
                      <% if(obj.AiuInfo[pidx].fnNativeInterface == 'ACE'||obj.AiuInfo[pidx].fnNativeInterface == 'ACE5') { %>
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

    `ifdef IO_UNITS_CNT_NON_ZERO
        if (m_concerto_env_cfg.has_axi_vip_snps) begin
            io_subsys_init_snps_vseq(fsys_main_traffic_vseq.ioaiu_traffic_vseq.snps_vseq);
        end else begin 
            io_subsys_init_inhouse_vseq(fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq);
        end
    `endif

  `uvm_info("FULLSYS_TEST", "END START_OF_SIMULATION", UVM_LOW)
//END setup MASTER_SEQ
endfunction:start_of_simulation_phase

// !!!! WE  USE RUN_PHASE & MAIN_PHASE !!!!!
//run_phase != main_phase 
// run_phase all the forked (sysco,pma etc...) sequence
// main_phase only the txn sequence
task concerto_fullsys_test::run_phase(uvm_phase phase); 
  `uvm_info("FULLSYS_TEST", "RUN_PHASE", UVM_LOW)
   fork
       begin
           trigger_aiu_env_sysco_event();
           hard_rstn_finished_ev.wait_trigger(); // sync with end of reset 
           kickoff_chi_coh_bringup_vseq();   
       end    
       <%for(idx = 0; idx < obj.nCHIs; idx++) { %>
       begin
         `ifdef CHI_SUBSYS
               `uvm_info(get_name(), "Starting force_seq<%=idx%>", UVM_NONE)
               m_smi_force_seq<%=idx%>.m_smi_force_virtual_seqr = m_concerto_env.inhouse.m_chiaiu<%=idx%>_env.m_smi_agent.m_smi_force_virtual_seqr;
               m_smi_force_seq<%=idx%>.start(m_concerto_env.inhouse.m_chiaiu<%=idx%>_env.m_smi_agent.m_smi_force_virtual_seqr);
               `uvm_info(get_name(), "Done force_seq<%=idx%>", UVM_NONE)
         `endif 
       end
       <%}%>
   join_none

   //All configuration is conducted from concerto_base_test.run_phase
   super.run_phase(phase);
   phase.raise_objection(this, "concerto_fullsys_test_run_phase");

   fork
       ncore_test_stimulus(phase);   
   join_none

   wait(iter == max_iteration-1) 
   ev_sim_done.wait_trigger();
   main_seq_hook_end_run_phase(phase);
  phase.drop_objection(this, "concerto_fullsys_test_run_phase");
  `uvm_info("FULLSYS_TEST", "END RUN_PHASE", UVM_LOW)
endtask:run_phase;

task concerto_fullsys_test::trigger_aiu_env_sysco_event();
    <% let chiidx=0;
    for(pidx=0; pidx<obj.nAIUs; pidx++) {
    if((obj.AiuInfo[pidx].fnNativeInterface == 'CHI-A') || (obj.AiuInfo[pidx].fnNativeInterface == 'CHI-B') || (obj.AiuInfo[pidx].fnNativeInterface == 'CHI-E') ) { %>
        chiaiu<%=chiidx%>_chi_agent_pkg::chi_base_seq_item chi_obj<%=chiidx%>;
    <% chiidx++; %>
    <% } } %>
 // Setup SysCo Attach for IOAIU scoreboards
  fork
    if(m_args.ioaiu_scb_en && !$test$plusargs("sysco_disable") && !test_cfg.disable_boot_tasks) begin : _setup_sysco_attch_for_ioaiu_scb_
    #1ns;   // add small delay to make sure trigger() is called after wait_trigger()   
    <% let ioidx=0;
    for(pidx=0; pidx<obj.nAIUs; pidx++) {
    if((obj.AiuInfo[pidx].fnNativeInterface != 'CHI-A') && (obj.AiuInfo[pidx].fnNativeInterface != 'CHI-B') && (obj.AiuInfo[pidx].fnNativeInterface != 'CHI-E') ) { 
    if((((obj.AiuInfo[pidx].fnNativeInterface === "ACELITE-E") || (obj.AiuInfo[pidx].fnNativeInterface === "ACE-LITE")) && (obj.AiuInfo[pidx].cmpInfo.nDvmSnpInFlight > 0)) || (obj.AiuInfo[pidx].fnNativeInterface == "ACE")  || (obj.AiuInfo[pidx].fnNativeInterface == "ACE5")|| ((obj.AiuInfo[pidx].fnNativeInterface == "AXI4") && (obj.AiuInfo[pidx].useCache)) || ((obj.AiuInfo[pidx].fnNativeInterface == "AXI5") && (obj.AiuInfo[pidx].useCache))  ||((obj.AiuInfo[pidx].fnNativeInterface == "AXI5") && (obj.AiuInfo[pidx].orderedWriteObservation == true)) ||((obj.AiuInfo[pidx].fnNativeInterface == "AXI4") && (obj.AiuInfo[pidx].orderedWriteObservation == true)) || ((obj.AiuInfo[pidx].fnNativeInterface == "ACELITE-E") && (obj.AiuInfo[pidx].orderedWriteObservation == true)) || ((obj.AiuInfo[pidx].fnNativeInterface == "ACE-LITE") && (obj.AiuInfo[pidx].orderedWriteObservation == true))) { %>
        `uvm_info("FULLSYS_TEST", "Triggering IOAIU<%=ioidx%> ev_sysco_fsm_state_change to CONNECT", UVM_NONE)
        m_concerto_env.inhouse.m_ioaiu<%=ioidx%>_env.m_env[0].m_scb.m_sysco_fsm_state = ioaiu<%=ioidx%>_env_pkg::CONNECT;  
        ev_sysco_fsm_state_change_<%=obj.AiuInfo[pidx].FUnitId%>.trigger();   
    <% } ioidx++;
    } } %>
    end : _setup_sysco_attch_for_ioaiu_scb_
  join_none

 // Setup SysCo Attach for CHIAIU scoreboards. Applies only for case when chiaiu coherency is enabled via SyscoAttach reg field
  fork
    if(m_args.chiaiu_scb_en && !$test$plusargs("sysco_disable") && !test_cfg.disable_boot_tasks && test_cfg.en_chiaiu_coherency_via_reg) begin : _setup_sysco_attch_for_chiaiu_scb_
    #2ns;   // add small delay to make sure trigger() is called after wait_trigger()   
    <% chiidx=0;
    for(pidx=0; pidx<obj.nAIUs; pidx++) {
    if((obj.AiuInfo[pidx].fnNativeInterface == 'CHI-A') || (obj.AiuInfo[pidx].fnNativeInterface == 'CHI-B') || (obj.AiuInfo[pidx].fnNativeInterface == 'CHI-E') ) { %>
         chi_obj<%=chiidx%> = chiaiu<%=chiidx%>_chi_agent_pkg::chi_base_seq_item::type_id::create("chi_obj<%=chiidx%>");
         chi_obj<%=chiidx%>.sysco_req = 1;
         chi_obj<%=chiidx%>.sysco_ack = 0;
        `uvm_info("FULLSYS_TEST", "Triggering m_concerto_env.inhouse.m_chiaiu<%=chiidx%>_env.m_scb.ev_csr_sysco_chiaiu<%=chiidx%> ", UVM_NONE)
         m_concerto_env.inhouse.m_chiaiu<%=chiidx%>_env.m_scb.ev_csr_sysco_chiaiu<%=chiidx%>.trigger(chi_obj<%=chiidx%>);
    <% chiidx++; %>
    <% } } %>
    end : _setup_sysco_attch_for_chiaiu_scb_
  join_none
endtask:trigger_aiu_env_sysco_event

//////////////////
//Calling Method: main_phase()
//////////////////
task concerto_fullsys_test::ncore_test_stimulus(uvm_phase phase);

   `uvm_info("CONCERTO_FULLSYS_TEST", "START ncore_test_stimulus", UVM_LOW)
    #1; //Wait ALL MAIN_PHASE start
   if($test$plusargs("use_emu_tsk")) begin
       emu_boot_tsk.exec_inhouse_boot_seq(phase);
   end

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
   `uvm_info("CONCERTO_FULLSYS_TEST", "END ncore_test_stimulus", UVM_LOW)
endtask: ncore_test_stimulus

task concerto_fullsys_test::kickoff_chi_coh_bringup_vseq();
   `uvm_info("FULLSYS_TEST", "Starting kickoff_chi_coh_bringup_vseq", UVM_LOW)
 if(m_concerto_env_cfg.has_chi_vip_snps) begin:_chi_vip_lnk 
//SANJEEV: Virtual Sequencer Called here
<% if(numChiAiu > 0) { %>
  chi_coh_bringup_vseq.coh_vseqr = m_concerto_env.snps.coh_vseqr;
  chi_coh_bringup_vseq.start(null);
<% } %>

<% cidx = 0; %>
<% if(numChiAiu>0) { %>
  fork
<% for(idx = 0; idx < obj.nAIUs; idx++) { 
    if((obj.AiuInfo[idx].fnNativeInterface == 'CHI-A')||(obj.AiuInfo[idx].fnNativeInterface == 'CHI-B' || obj.AiuInfo[idx].fnNativeInterface == 'CHI-E')) { %>

    begin
    automatic svt_chi_status::sysco_interface_state_enum pre_sysco_interface_state=m_concerto_env.snps.svt.amba_system_env.chi_system[0].rn[<%=cidx%>].shared_status.sysco_interface_state;
    `uvm_info("FULLSYS_SYSCO_TEST", $psprintf("RUN_PHASE sysco state %0s coherency_exit_active_queue_checking_done %0d is_link_active %0d",pre_sysco_interface_state,m_concerto_env.snps.svt.amba_system_env.chi_system[0].rn[<%=cidx%>].shared_status.coherency_exit_active_queue_checking_done,m_concerto_env.snps.svt.amba_system_env.chi_system[0].rn[0].shared_status.is_link_active), UVM_LOW)
      forever begin
          #10ns;
          if(m_concerto_env.snps.svt.amba_system_env.chi_system[0].rn[<%=cidx%>].shared_status.sysco_interface_state != pre_sysco_interface_state) begin
              `uvm_info("FULLSYS_TEST", $psprintf("RUN_PHASE sysco state change %0s -> %0s coherency_exit_active_queue_checking_done %0d is_link_active %0d",pre_sysco_interface_state,m_concerto_env.snps.svt.amba_system_env.chi_system[0].rn[0].shared_status.sysco_interface_state,m_concerto_env.snps.svt.amba_system_env.chi_system[0].rn[<%=cidx%>].shared_status.coherency_exit_active_queue_checking_done,m_concerto_env.snps.svt.amba_system_env.chi_system[0].rn[<%=cidx%>].shared_status.is_link_active), UVM_LOW)
          end
          pre_sysco_interface_state=m_concerto_env.snps.svt.amba_system_env.chi_system[0].rn[<%=cidx%>].shared_status.sysco_interface_state;
      end
    end

    begin
    automatic svt_chi_status::coherency_phase_enum pre_coherency_phase=m_concerto_env.snps.svt.amba_system_env.chi_system[0].rn[<%=cidx%>].shared_status.coherency_phase;
      forever begin
          #10ns;
          if(m_concerto_env.snps.svt.amba_system_env.chi_system[0].rn[<%=cidx%>].shared_status.coherency_phase != pre_coherency_phase) begin
              `uvm_info("FULLSYS_TEST", $psprintf("RUN_PHASE coherency phase change %0s -> %0s",pre_coherency_phase,m_concerto_env.snps.svt.amba_system_env.chi_system[0].rn[<%=cidx%>].shared_status.coherency_phase), UVM_LOW)
          end
          pre_coherency_phase=m_concerto_env.snps.svt.amba_system_env.chi_system[0].rn[<%=cidx%>].shared_status.coherency_phase;
      end
    end
    <% cidx++; }} %>
  join_none
<% } %>

 end:_chi_vip_lnk else begin:_chi_inhouse_lnk
 
 // Setup SysCO attach for CHI & launch pin attach
  fork
  <% idx = 0; %>
  <% for(pidx = 0; pidx < obj.nAIUs; pidx++) { %>
    <%if(obj.AiuInfo[pidx].fnNativeInterface.match("CHI")) { %>
    begin
        if(!$test$plusargs("sysco_disable") && !test_cfg.k_access_boot_region) begin
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
   `uvm_info("FULLSYS_TEST", "Finish kickoff_chi_coh_bringup_vseq", UVM_LOW)
endtask

function void concerto_fullsys_test::phase_ready_to_end(uvm_phase phase);
   super.phase_ready_to_end(phase);
    if($test$plusargs("hard_reset_en")) begin
       if(phase.get_imp() == uvm_shutdown_phase::get()) begin
          if(hard_reset_issued == 0) begin
             `uvm_info("FULLSYS_TEST", "Going to RESET", UVM_NONE)
             phase.jump(uvm_pre_reset_phase::get());
             hard_reset_issued++;
          end
       end
    end   
 
  endfunction

task concerto_fullsys_test::exec_inhouse_seq(uvm_phase phase); // BY default launch random txn
    
  bit [31:0] ioaiu_control_cfg;
  phase.raise_objection(this, "exec_inhouse_seq");
  `uvm_info("FULL_SYS_TEST", "Start exec_inhouse_seq", UVM_LOW)

   main_seq_pre_hook(phase);

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

  if ($test$plusargs("use_user_addrq") && !test_cfg.k_access_boot_region) begin:_use_user_addrq
  // k_access_boot_region create their own use_user_addrq
      gen_addr_use_user_addrq();
  end:_use_user_addrq

  for (iter = 0; iter < max_iteration ; iter++ ) begin: _iteration_loop
    if (iter>0) #10us;
    main_seq_iter_pre_hook (phase,iter);
    <%chiaiu_idx = 0;%>
    fork:_exec_fork
      fork:_start_all_seq

        begin
          phase.raise_objection(this, "USE_VIP_SNPS CHIAIU sequence");
          fsys_main_traffic_vseq.no_snoop_seq = iter;
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//ncore3.7 All random stimulus hashtags - ACE5, AXI5 w/ atomic, AXI5 w/ proxy cache and CHI-B interface parity check
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Config used for CHI-B interface parity check - hw_cfg_ncore37_no_owo, hw_cfg_45_axi5_ace5_chib_w_if_parity_chk
// Config used for - ACE5, AXI5 w/ atomic, AXI5 w/ proxy cache - hw_cfg_ncore37_no_owo, hw_cfg_45_axi5_ace5_chib_w_if_parity_chk
// #Stimulus.FSYS.v370.if_parity_chk.CHI_B 
// #Stimulus.FSYS.v370.if_parity_chk.CHI_F
// #Cover.FSYS.v370.if_parity_chk.CHI_B 
// #Cover.FSYS.v370.if_parity_chk.CHI_E
// #Stimulus.FSYS.v370.amba5.random_AXI5
// #Stimulus.FSYS.v370.amba5.random_ACE5
// #Stimulus.FSYS.v370.amba5.random_AXI5_w_proxy_cache
// #Stimulus.FSYS.v370.amba5.random_AXI5_w_atomics
//
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//ncore3.7.1 IOAIUp/OWO random stimulus hashtags - AXI5 256b/512b, ACE-Lite 256b/512b, ACE5Lite 256b/512b. Covered with fsys cfg - hw_cfg_ncore37, hw_cfg_ncore37_snps
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// #Stimulus.FSYS.v371.amba5_owo_axi.random_wr_rd_axi_256 
// #Stimulus.FSYS.v371.amba5_owo_axi.random_wr_rd_axi_512 
// #Stimulus.FSYS.v371.amba5_owo_axi.random_wr_rd_ACElite_256 
// #Stimulus.FSYS.v371.amba5_owo_axi.random_wr_rd_ACElite_512
// #Stimulus.FSYS.v371.amba5_owo_axi.random_wr_rd_ACE5lite_256 
// #Stimulus.FSYS.v371.amba5_owo_axi.random_wr_rd_ACE5lite_512
//
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//ncore3.7.1 IOAIUp/OWO atomic transactions stimulus (using weights in random tests - +atmstr=1, +atmld=1, +atmcmp=1, +atmswp=1) hashtags for AXI5 IOAIUp 256b/512b. 
//Covered with fsys cfg - hw_cfg_ncore37, hw_cfg_ncore37_snps
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// #Stimulus.FSYS.v371.amba5_owo_axi.random_atomic_AXI5_256
// #Stimulus.FSYS.v371.amba5_owo_axi.random_atomic_AXI5_512
          fsys_main_traffic_vseq.start(null);
          phase.drop_objection(this, "USE_VIP_SNPS CHIAIU sequence");
        end

        begin:_wait_seq_trigger
            if(!$test$plusargs("dont_wait_all_seq_trigger")) begin : _dont_wait_all_seq_trigger_
               fork:_all_master_agents
               <%chiaiu_idx = 0;
               ioaiu_idx = 0;
               for(let pidx = 0; pidx < obj.nAIUs; pidx++) {
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
                          end
                        end:_chiaiu<%=chiaiu_idx%>_wait
               <% chiaiu_idx++;
               } else { %>
               <% for(let i=0; i<aiu_NumCores[pidx]; i++) { %> 
		                 if(ioaiu_en.exists(<%=ioaiu_idx%>)) begin:_ioaiu<%=ioaiu_idx%>_<%=i%>_wait
                           if (m_concerto_env_cfg.has_axi_vip_snps)
                           begin
                           //done_snp_cust_seq_h<%=ioaiu_idx%>.wait_trigger();
                           end
                           else begin
                           ev_ioaiu<%=ioaiu_idx%>_seq_done[<%=i%>].wait_trigger();
                           end
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
            end : _dont_wait_all_seq_trigger_
                     `uvm_info("FULLSYS_TEST", "All sequences DONE", UVM_NONE)
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
  `uvm_info("FULL_SYS_TEST", "END exec_inhouse_seq", UVM_LOW)
endtask: exec_inhouse_seq

task concerto_fullsys_test::wait_seq_totaly_done(uvm_phase phase);
   phase.raise_objection(this, "wait_seq_totaly_done");
    // No need to WAIT IOIAIU because when seq is finished all the txn are finished

fork:_wait_ott_empty
    // Wait end of CHI txn (txn are forked)
    // now the test use main_phase but scb use run_phase
    // to synchronize the both phase wait nbr objection =0 in the chi scb
    // before finish the test main_phase
    <% chi_idx=0;%>
    <% io_idx=0;%>
    <% for(let pidx = 0; pidx < obj.nAIUs; pidx++) { %>
      <% if(obj.AiuInfo[pidx].fnNativeInterface.match("CHI")) { %>
       if (m_args.chiaiu_scb_en) begin 
         `uvm_info("FULL_SYS_TEST", $sformatf("wait_seq_totaly_done:: CHI<%=chi_idx%>  %0d TXNs are finishing",m_concerto_env.inhouse.m_chiaiu<%=chi_idx%>_env.m_scb.m_ott_q.size()), UVM_NONE)
         #1;
         if (m_concerto_env.inhouse.m_chiaiu<%=chi_idx%>_env.m_scb.objection) m_concerto_env.inhouse.m_chiaiu<%=chi_idx%>_env.m_scb.objection.wait_for_total_count( m_concerto_env.inhouse.m_chiaiu<%=chi_idx%>_env.m_scb, 0);
         wait(m_concerto_env.inhouse.m_chiaiu<%=chi_idx%>_env.m_scb.m_ott_q.size() == 0);
         `uvm_info("FULL_SYS_TEST", "wait_seq_totaly_done:: CHI<%=chi_idx%> TXN DONE", UVM_NONE)
       end
       <%chi_idx++;%>
    <%} // if chi%>
    <%}//foreach aiu%>
   
    // Wait end of IOAIU txn
    <% for(let pidx = 0; pidx < obj.nAIUs; pidx++) { %>
      <% if(!obj.AiuInfo[pidx].fnNativeInterface.match("CHI")) { %>
       if (m_args.ioaiu_scb_en) begin 
        fork
       	<% for(let n=0; n<aiu_NumCores[pidx]; n++) { %>
        begin
         `uvm_info("FULL_SYS_TEST", $sformatf("wait_seq_totaly_done:: IOAIU<%=io_idx%>_<%=n%> %0d TXNs are finishing",m_concerto_env.inhouse.m_ioaiu<%=io_idx%>_env.m_env[<%=n%>].m_scb.m_ott_q.size()), UVM_NONE)
         #1;
         if(m_concerto_env.inhouse.m_ioaiu<%=io_idx%>_env.m_env[<%=n%>].m_scb.objection) m_concerto_env.inhouse.m_ioaiu<%=io_idx%>_env.m_env[<%=n%>].m_scb.objection.wait_for_total_count( m_concerto_env.inhouse.m_ioaiu<%=io_idx%>_env.m_env[<%=n%>].m_scb, 0);
         `uvm_info("FULL_SYS_TEST", "wait_seq_totaly_done:: IOAIU<%=io_idx%>_<%=n%> TXN DONE", UVM_NONE)
        end<%}%>
        join
       end
       <%io_idx++;%>
    <%} // if chi%>
    <%}//foreach aiu%>
    // Wait end of DMI txn
    // now the test use main_phase but scb use run_phase
    // to synchronize the both phase wait nbr objection =0 in the dmi scb
    <% for(let pidx = 0; pidx < obj.nDMIs; pidx++) { %>
       if (m_args.dmi_scb_en) begin
        `uvm_info("FULL_SYS_TEST", $sformatf("wait_seq_totaly_done:: DMI<%=pidx%> %0d TXNs are finishing",m_concerto_env.inhouse.m_dmi<%=pidx%>_env.m_sb.rtt_q.size()+m_concerto_env.inhouse.m_dmi<%=pidx%>_env.m_sb.wtt_q.size()), UVM_NONE)
        #1;
        if(m_concerto_env.inhouse.m_dmi<%=pidx%>_env.m_sb.objection) m_concerto_env.inhouse.m_dmi<%=pidx%>_env.m_sb.objection.wait_for_total_count( m_concerto_env.inhouse.m_dmi<%=pidx%>_env.m_sb, 0);
        //wait (m_concerto_env.inhouse.m_dmi<%=pidx%>_env.m_sb.rtt_q.size() ==0
        //      && m_concerto_env.inhouse.m_dmi<%=pidx%>_env.m_sb.wtt_q.size() == 0
        //      );
        `uvm_info("FULL_SYS_TEST", "wait_seq_totaly_done:: DMI<%=pidx%> TXN DONE", UVM_NONE)
       end
    <%}//foreach dmi%>
    
    // Wait end of DII txn
    <% for(let pidx = 0; pidx < obj.nDIIs; pidx++) { %>
       if (m_args.dii_scb_en) begin
         `uvm_info("FULL_SYS_TEST", $sformatf("wait_seq_totaly_done:: DII<%=pidx%> %0d TXNs are finishing ...",m_concerto_env.inhouse.m_dii<%=pidx%>_env.m_scb.num_wtt_entries+m_concerto_env.inhouse.m_dii<%=pidx%>_env.m_scb.num_rtt_entries), UVM_NONE)
         #1;
        wait (m_concerto_env.inhouse.m_dii<%=pidx%>_env.m_scb.num_wtt_entries ==0
              && m_concerto_env.inhouse.m_dii<%=pidx%>_env.m_scb.num_rtt_entries == 0
              );
         `uvm_info("FULL_SYS_TEST", "wait_seq_totaly_done:: DII<%=pidx%> TXN DONE", UVM_NONE)
       end
    <%}//foreach dii%>
    // add time to be sure
join:_wait_ott_empty
    #10us;
    `uvm_info("FULL_SYS_TEST", "wait_seq_totaly_done!!!", UVM_NONE)
   phase.drop_objection(this, "wait_seq_totaly_done");
endtask:wait_seq_totaly_done

task concerto_fullsys_test::check_corr_errint_through_alias_reg();
    bit [31:0] data;

    // There are two conditions: 1. ErrCount >= ErrThreshold, or 2. ErrCount overflowed
<% for(idx = 0, qidx=0; idx < obj.nAIUs; idx++) { 
    if((obj.AiuInfo[idx].fnNativeInterface != 'CHI-A')&&(obj.AiuInfo[idx].fnNativeInterface != 'CHI-B')&&(obj.AiuInfo[idx].fnNativeInterface != 'CHI-E') && (numBootIoAiu > 0)) {%>
    ioaiu<%=BootIoAiu[0]%>_axi_agent_pkg::axi_axaddr_t addr;
    // set csrBaseAddr													
    addr = ncore_config_pkg::ncoreConfigInfo::NRS_REGION_BASE ; //  addr = {<%=obj.AiuInfo[idx].CsrInfo.csrBaseAddress.replace("0x","'h")%>, 8'hFF, 12'h000}; 
<% let pidx_aiu_cores=0%>
<% for(let pidx_aiu = 0; pidx_aiu < obj.nAIUs; pidx_aiu++) {
if((obj.AiuInfo[pidx_aiu].fnNativeInterface != 'CHI-A')&&(obj.AiuInfo[pidx_aiu].fnNativeInterface != 'CHI-B')&&(obj.AiuInfo[pidx_aiu].fnNativeInterface != 'CHI-E')){ %>
<% for(pidx_aiu_cores = 0; pidx_aiu_cores < aiu_NumCores[pidx_aiu]; pidx_aiu_cores++) {
        // check error counter overflow. IOAIUs idxToAiuWithPC: <%=idxIoAiuWithPC%>
        addr[19:12]= <%=aiu_rpn[pidx_aiu]%>;// Register Page Number
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
        addr[19:12]= <%=aiu_rpn[pidx_aiu]%>;// Register Page Number
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

<% } %>
<% } %>
<% } %>
<% for(let pidx_dce = 0; pidx_dce < obj.nDCEs; pidx_dce++) { %>
        addr[19:12]= <%=dce_rpn[pidx_dce]%>;// Register Page Number
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

<% } %>
<% for(let pidx_dmi = 0; pidx_dmi < obj.nDMIs; pidx_dmi++) { %>
        addr[19:12]= <%=dmi_rpn[pidx_dmi]%>;// Register Page Number
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

<% } %>
     <% break; %>
        <% } %>
     <% qidx++; %>
<% } %>
  
endtask: check_corr_errint_through_alias_reg

task concerto_fullsys_test::inject_error_all_dmi_smc();
<%for(let pidx = 0; pidx < obj.nDMIs; pidx++) { if(obj.DmiInfo[pidx].useCmc) {%>
   inject_error_dmi<%=pidx%>_smc();
<%}}%>
endtask : inject_error_all_dmi_smc

<%for(let pidx = 0; pidx < obj.nDMIs; pidx++) { if(obj.DmiInfo[pidx].useCmc) {%>
task concerto_fullsys_test::inject_error_dmi<%=pidx%>_smc();
    ev_inject_error_dmi<%=pidx%>_smc.trigger();
endtask : inject_error_dmi<%=pidx%>_smc
<%}}%>



`ifdef USE_STL_TRACE
task concerto_fullsys_test::stl_csr_write();
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
  <% for(let pidx = 0 ; pidx < obj.nAIUs; pidx++) { %>
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

task concerto_fullsys_test::gen_addr_use_user_addrq();
  int perf_txn_size;

  if(!($value$plusargs("perf_txn_size=%d", perf_txn_size))) begin
    perf_txn_size = 64;
  end

    $value$plusargs("use_user_addrq=%d", use_user_addrq);
    `uvm_info(get_name(), $psprintf("plusarg use_user_addrq is enabled, use_user_addrq value from plusarg %0d reduce_mem_size:%0d",use_user_addrq, test_cfg.reduce_mem_size), UVM_LOW)
if(!$test$plusargs("all_ways_for_sp")) begin
  
    if($test$plusargs("reduce_addr_area")) begin:_reduce_addr_area
        longint mid_addr;
        longint s; // start addr
        longint e; // end addr
        longint d; // size of addr chunk
        int nbr_addr = test_cfg.reduce_mem_size;
        longint addr;
        foreach (ncoreConfigInfo::memregions_info[region]) begin:_foreach_memregions
                if (ncoreConfigInfo::is_dii_addr(ncoreConfigInfo::memregions_info[region].start_addr) ||
                    (ncoreConfigInfo::is_dmi_addr(ncoreConfigInfo::memregions_info[region].start_addr) 
                     && ncoreConfigInfo::get_addr_gprar_nc(ncoreConfigInfo::memregions_info[region].start_addr))) begin:_noncoh_addrq
                    
                    addr = ncoreConfigInfo::memregions_info[region].start_addr;
                    
                    for(int i=0; i< nbr_addr; i++) begin
                        ncoreConfigInfo::user_addrq[ncoreConfigInfo::NONCOH].push_back(addr);
                        addr += (1<< <%=obj.wCacheLineOffset%>);
                    end
                end:_noncoh_addrq else begin:_coh_addrq
                    addr = ncoreConfigInfo::memregions_info[region].start_addr;
                    for(int i=0; i< nbr_addr; i++) begin
                        ncoreConfigInfo::user_addrq[ncoreConfigInfo::COH].push_back(addr);
                        addr += (1<< <%=obj.wCacheLineOffset%>);
                    end
                    addr = ncoreConfigInfo::memregions_info[region].end_addr;
                    for(int i=0; i< nbr_addr; i++) begin
                        ncoreConfigInfo::user_addrq[ncoreConfigInfo::COH].push_back(addr);
                        addr -= (1<< <%=obj.wCacheLineOffset%>);
                    end
                end:_coh_addrq
        end:_foreach_memregions
        `uvm_info(get_name(), $psprintf("coh_addrq.size: %0d noncoh_addrq.size:%0d", ncoreConfigInfo::user_addrq[ncoreConfigInfo::COH].size(), ncoreConfigInfo::user_addrq[ncoreConfigInfo::NONCOH].size()), UVM_LOW)

    end:_reduce_addr_area else begin:_no_reduce_addr_area
    if($test$plusargs("perf_test")) begin:_perf_test
      if( perf_txn_size < 2**<%=obj.wCacheLineOffset%>) begin
        perf_txn_size = 2**<%=obj.wCacheLineOffset%>;
      end
      if($test$plusargs("non_dmi_intlv")) begin
        addr_mgr.gen_seq_addr_in_user_addrq(use_user_addrq, perf_txn_size, 0, 0, ncoreConfigInfo::user_addrq[ncoreConfigInfo::COH]);
        ncoreConfigInfo::user_addrq[ncoreConfigInfo::NONCOH] = ncoreConfigInfo::user_addrq[ncoreConfigInfo::COH] ;
      end else begin
	      if($test$plusargs("coherent_test")) begin
		      `uvm_info(get_name(), $psprintf("executing gen_seq_addr_in_user_addrq in no write test coherent_test"), UVM_NONE)
          addr_mgr.gen_seq_addr_in_user_addrq(use_user_addrq, perf_txn_size, 0, -1, ncoreConfigInfo::user_addrq[ncoreConfigInfo::COH]);
		    end else begin
		      `uvm_info(get_name(), $psprintf("executing gen_seq_addr_in_user_addrq in no write test NONcoherent_test"), UVM_NONE)
		      addr_mgr.gen_seq_addr_in_user_addrq(use_user_addrq, perf_txn_size, 0, -1, ncoreConfigInfo::user_addrq[ncoreConfigInfo::NONCOH]);
		    end
      end
      `uvm_info(get_name(), $psprintf("perf_test plusarg is on, Final ncoreConfigInfo::user_addrq[ncoreConfigInfo::NONCOH] size %0d ncoreConfigInfo::user_addr[ncoreConfigInfo::COH] size %0d",ncoreConfigInfo::user_addrq[ncoreConfigInfo::NONCOH].size(),ncoreConfigInfo::user_addrq[ncoreConfigInfo::COH].size()), UVM_LOW)

    end:_perf_test else begin:_no_perf_test
    <% if ( obj.initiatorGroups.length >= 1) { %>
    <% for(pidx = 0; pidx < obj.nAIUs; pidx++) { %>
    addr_mgr.gen_user_noncoh_addr(<%=obj.AiuInfo[pidx].FUnitId%>, use_user_addrq/<%=obj.nAIUs%>, ncoreConfigInfo::user_addrq[ncoreConfigInfo::NONCOH]);  <% } %>
    <% } else { %>
    addr_mgr.gen_user_noncoh_addr(<%=obj.AiuInfo[0].FUnitId%>, use_user_addrq, ncoreConfigInfo::user_addrq[ncoreConfigInfo::NONCOH]);
    <% } %>
    `uvm_info(get_name(), $psprintf("Initial ncoreConfigInfo::user_addrq[ncoreConfigInfo::NONCOH] size %0d ncoreConfigInfo::user_addrq[ncoreConfigInfo::COH] size %0d",ncoreConfigInfo::user_addrq[ncoreConfigInfo::NONCOH].size(),ncoreConfigInfo::user_addrq[ncoreConfigInfo::COH].size()), UVM_HIGH)
         if($test$plusargs("dce_fix_index")) begin
            int dummy_csrq_idx;
            randcase
            <% for(pidx = 0; pidx < obj.nDCEs; pidx++) { let maxWay = 0; obj.DceInfo[pidx].SnoopFilterInfo.forEach(function FindMax(item){maxWay = (maxWay<item.nWays) ? item.nWays : maxWay;});%>
            <%=obj.DceInfo[pidx].nUnitId%> : addr_mgr.set_dce_sf_fix_index_in_user_addrq(<%=obj.DceInfo[pidx].nUnitId%>, ncoreConfigInfo::user_addrq[ncoreConfigInfo::COH],dummy_csrq_idx);
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
                <%=obj.DmiInfo[pidx].nUnitId%> : begin addr_mgr.set_dmi_smc_fix_index_in_user_addrq(<%=obj.DmiInfo[pidx].nUnitId%>, ncoreConfigInfo::user_addrq[ncoreConfigInfo::COH], 1); 
                // #Stimulus.FSYS.sysevent.coh_txn.pre-v3.4
                //#Stimulus.FSYS.sysevent.dce
                          if($test$plusargs("en_excl_txn"))
                             ncoreConfigInfo::user_addrq[ncoreConfigInfo::COH] = ncoreConfigInfo::user_addrq[ncoreConfigInfo::COH][0:0]; 
                          ncoreConfigInfo::user_addrq[ncoreConfigInfo::NONCOH] = {};
                          addr_mgr.set_dmi_smc_fix_index_in_user_addrq(<%=obj.DmiInfo[pidx].nUnitId%>, ncoreConfigInfo::user_addrq[ncoreConfigInfo::NONCOH], 0);
                // #Stimulus.FSYS.sysevent.noncoh_txn.pre-v3.4
                //#Stimulus.FSYS.sysevent.dii_dmi
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

                if($test$plusargs("en_excl_txn") && (ncoreConfigInfo::user_addrq[ncoreConfigInfo::COH].size()<min_use_user_addrq))  begin
                    <% if ( obj.initiatorGroups.length >= 1) { %>
                    <% for(pidx = 0; pidx < obj.nAIUs; pidx++) { %>
                    addr_mgr.gen_user_coh_addr(<%=obj.AiuInfo[pidx].FUnitId%>, ((use_user_addrq/<%=obj.nAIUs%>)>min_use_user_addrq) ? (use_user_addrq/<%=obj.nAIUs%>) :((min_use_user_addrq-ncoreConfigInfo::user_addrq[ncoreConfigInfo::COH].size())/<%=obj.nAIUs%>), ncoreConfigInfo::user_addrq[ncoreConfigInfo::COH]);  <% } %>
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
                    <% if ( obj.initiatorGroups.length >= 1) { %>
                    <% for(pidx = 0; pidx < obj.nAIUs; pidx++) { %>
                    addr_mgr.gen_user_noncoh_addr(<%=obj.AiuInfo[pidx].FUnitId%>, ((use_user_addrq/<%=obj.nAIUs%>)>min_use_user_addrq) ? (use_user_addrq/<%=obj.nAIUs%>) :((min_use_user_addrq -ncoreConfigInfo::user_addrq[ncoreConfigInfo::NONCOH].size())/<%=obj.nAIUs%>), ncoreConfigInfo::user_addrq[ncoreConfigInfo::NONCOH]);  

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
  end:_no_reduce_addr_area


 end else begin
      //#Stimulus.FSYS.DMI.ScratchPad
      bit [ncoreConfigInfo::W_SEC_ADDR-1:0] addr_sp_with_inter;


      ncoreConfigInfo::user_addrq[ncoreConfigInfo::NONCOH].delete();
      ncoreConfigInfo::user_addrq[ncoreConfigInfo::COH].delete();
     

      for(int dmi_idx = 0; dmi_idx < ncore_config_pkg::ncoreConfigInfo::NUM_DMIS; dmi_idx++) begin
        //generate address space for DMI scratshpad to be used by sequences
        foreach (ncoreConfigInfo::memregions_info[region]) begin:_foreach_memregions

          if(ncoreConfigInfo::is_dii_addr(ncoreConfigInfo::memregions_info[region].start_addr)) begin
            continue;
          end 
          
          addr_sp_with_inter = (test_cfg.k_sp_base_addr[dmi_idx]<< ncore_config_pkg::ncoreConfigInfo::WCACHE_OFFSET); 
           `uvm_info(get_name(), $psprintf("scratchpad address base k_sp_base_addr[dmi %0d] = %0h",dmi_idx,addr_sp_with_inter), UVM_MEDIUM)

          for(int i = 0 ; i < 400 ; i++) begin
            addr_sp_with_inter = addr_sp_with_inter + i*(2**<%=obj.wCacheLineOffset%>);
           `uvm_info(get_name(), $psprintf("scratchpad address send to seq  sp_base_seq[dmi %0d] = %0h",dmi_idx,addr_sp_with_inter), UVM_MEDIUM)
            ncoreConfigInfo::user_addrq[ncoreConfigInfo::NONCOH].push_back(addr_sp_with_inter) ;
          end

        end

      end    

      ncoreConfigInfo::user_addrq[ncoreConfigInfo::COH] = ncoreConfigInfo::user_addrq[ncoreConfigInfo::NONCOH] ;


  end

if (m_concerto_env_cfg.has_chi_vip_snps) begin:_setup_addr_chi_vip
<% if(numChiAiu > 0) { %>
               m_svt_chi_item.user_addrq[ncoreConfigInfo::NONCOH] = ncoreConfigInfo::user_addrq[ncoreConfigInfo::NONCOH];
               m_svt_chi_item.user_addrq[ncoreConfigInfo::COH] = ncoreConfigInfo::user_addrq[ncoreConfigInfo::COH];
               m_svt_chi_item.user_addr = 1;
<% } %> 
end:_setup_addr_chi_vip else begin:_setup_add_chi_inhouse
               <% chi_idx=0;
	       for(let pidx=0; pidx<obj.nAIUs; pidx++) {
               if(obj.AiuInfo[pidx].fnNativeInterface.match("CHI")) { %>
               m_chi<%=chi_idx%>_vseq.m_chi_container.user_addrq[ncoreConfigInfo::NONCOH] = ncoreConfigInfo::user_addrq[ncoreConfigInfo::NONCOH];
               m_chi<%=chi_idx%>_vseq.m_chi_container.user_addrq[ncoreConfigInfo::COH] = ncoreConfigInfo::user_addrq[ncoreConfigInfo::COH];
	       <% chi_idx++;%>
         <%}%>
         <%}%>
end:_setup_add_chi_inhouse

if (!m_concerto_env_cfg.has_axi_vip_snps) begin:_setup_addr_ace_inhouse
	       <%io_idx=0;
	       for(let pidx=0; pidx<obj.nAIUs; pidx++) {
               if(!(obj.AiuInfo[pidx].fnNativeInterface.match("CHI"))) { %>
              <% for(let coreidx=0; coreidx<aiu_NumCores[pidx]; coreidx++) { %>
               m_concerto_env.inhouse.m_ace_cache_model_ioaiu<%=io_idx%>[<%=coreidx%>].user_addrq[ncoreConfigInfo::NONCOH] = ncoreConfigInfo::user_addrq[ncoreConfigInfo::NONCOH];
               m_concerto_env.inhouse.m_ace_cache_model_ioaiu<%=io_idx%>[<%=coreidx%>].user_addrq[ncoreConfigInfo::COH] = ncoreConfigInfo::user_addrq[ncoreConfigInfo::COH];
              <% } %>//foreach core%>               
               <% io_idx++; } 
               } %>
end:_setup_addr_ace_inhouse

endtask:gen_addr_use_user_addrq

`ifdef IO_UNITS_CNT_NON_ZERO
function void concerto_fullsys_test::io_subsys_init_snps_vseq(io_subsys_snps_vseq vseq);
         //foreach(ioaiu_en[i]) begin
         //   vseq.t_ioaiu_en[i]=ioaiu_en[i]; 
         //   `uvm_info("FULLSYS_TEST", $sformatf("Subsys_snps ioaiu_en[port_id %0d] =  %0d", i, ioaiu_en[i]), UVM_NONE)
         //end
         int NumMstAiu;
         int NumAiu;
         int NumCore;
         <% 
         ioaiu_idx = 0;
         for(let pidx = 0; pidx < obj.nAIUs; pidx++) { %>
         <% if(!obj.AiuInfo[pidx].fnNativeInterface.match("CHI")) { %>
            //NumCore=0;
            if ( <%=aiu_NumCores[pidx]%> >1 ) begin
            <% for(let i=0; i<aiu_NumCores[pidx]; i++) { %>  
               if(ioaiu_en.exists(<%=ioaiu_idx%>)) begin
                vseq.t_ioaiu_en[NumMstAiu]=ioaiu_en[<%=ioaiu_idx%>]; 
               `uvm_info("FULLSYS_TEST", $sformatf("Subsys_snps ioaiu_en[%0d]  =  %0d",NumMstAiu, vseq.t_ioaiu_en[NumMstAiu]), UVM_NONE)
               end
               NumCore++;
               NumMstAiu=NumCore ;
               //NumMstAiu=NumMstAiu+NumCore;
            <% } // foreach core%> 
            end
            if(<%=aiu_NumCores[pidx]%> ==1 ) begin
                if(ioaiu_en.exists(<%=ioaiu_idx%>)) begin
                    vseq.t_ioaiu_en[NumMstAiu]=ioaiu_en[<%=ioaiu_idx%>]; 
                   `uvm_info("FULLSYS_TEST", $sformatf("Subsys_snps ioaiu_en[%0d]  =  %0d",NumMstAiu, vseq.t_ioaiu_en[NumMstAiu]), UVM_NONE)
                end
                NumCore++;
                NumMstAiu=NumCore ;
                //NumMstAiu=NumMstAiu+NumCore;
            end
         <% ioaiu_idx++; } %>
         <% } // foreach AIUs%>
             
         vseq.mstr_agnt_seqr_a   = io_subsys_mstr_agnt_seqr_a;
         vseq.mstr_agnt_seqr_str = io_subsys_mstr_agnt_seqr_str;
endfunction: io_subsys_init_snps_vseq

function void concerto_fullsys_test::io_subsys_init_inhouse_vseq(io_subsys_inhouse_vseq vseq);
         <% 
         ioaiu_idx = 0;
         for(let pidx = 0; pidx < obj.nAIUs; pidx++) { %>
         <% if(!obj.AiuInfo[pidx].fnNativeInterface.match("CHI")) { %>
         <% for(let i=0; i<aiu_NumCores[pidx]; i++) { %>  
         if (!m_concerto_env_cfg.has_axi_vip_snps && ioaiu_en.exists(<%=ioaiu_idx%>)) begin: _ioaiu<%=ioaiu_idx%>_<%=i%>_inhouse
           <% if(obj.AiuInfo[pidx].interfaces.eventRequestOutInt._SKIP_ == false || obj.AiuInfo[pidx].interfaces.eventRequestInInt._SKIP_ == false) { %>
           vseq.m_event_sqr_ioaiu<%=ioaiu_idx%>[<%=i%>] = m_concerto_env.inhouse.m_ioaiu<%=ioaiu_idx%>_env.m_env[<%=i%>].m_event_agent.m_sequencer;
           <% } %>                          
                        
         end:_ioaiu<%=ioaiu_idx%>_<%=i%>_inhouse
             <% } // foreach core%> 
          <% ioaiu_idx++; } %>
       <% } // foreach AIUs%>
endfunction: io_subsys_init_inhouse_vseq


function void concerto_fullsys_test::configure_ioaiu_mstr_seqs();
  int seq_id=0;
  foreach(io_subsys_mstr_seq_cfg_a[i]) begin 
      io_subsys_mstr_seq_cfg_a[i] = io_mstr_seq_cfg::type_id::create($psprintf("%0s_%0s_mstr_seq_cfg_p%0d_s%0d", ncoreConfigInfo::io_subsys_nativeif_a[i].tolower(), ncoreConfigInfo::io_subsys_instname_a[i], i,seq_id));
      io_subsys_mstr_seq_cfg_a[i].init_master_info(ncoreConfigInfo::io_subsys_nativeif_a[i].tolower(), ncoreConfigInfo::io_subsys_instname_a[i], ncoreConfigInfo::io_subsys_funitid_a[i]); 
      uvm_config_db #(mstr_seq_cfg)::set(this ,"m_concerto_env.snps.svt.amba_system_env.axi_system[0]*", $sformatf("%0s_%0s_mstr_seq_cfg_p%0d_s%0d", ncoreConfigInfo::io_subsys_nativeif_a[i].tolower(), ncoreConfigInfo::io_subsys_instname_a[i], i,seq_id), io_subsys_mstr_seq_cfg_a[i]);
  end 
        
endfunction:configure_ioaiu_mstr_seqs;


`endif
