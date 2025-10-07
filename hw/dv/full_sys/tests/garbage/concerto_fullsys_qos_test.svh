<%

var pma_en_dmi_blk = 1;
var pma_en_dii_blk = 1;
var pma_en_aiu_blk = 1;
var pma_en_dce_blk = 1;
var pma_en_dve_blk = 1;
var pma_en_at_least_1_blk = 0;
var pma_en_all_blk = 1;
var numChiAiu = 0; // Number of CHI AIUs
var numACEAiu = 0; // Number of ACE AIUs
var numIoAiu = 0; // Number of IO AIUs
var numCAiu = 0; // Number of Coherent AIUs
var numNCAiu = 0; // Number of Non-Coherent AIUs
var chiaiu0;  // strRtlNamePrefix of chiaiu0
var idxIoAiuWithPC = 0; // To get valid index of NCAIU with ProxyCache
var numDmiWithSMC = 0; // Number of DMIs with SystemMemoryCache
var idxDmiWithSMC = 0; // To get valid index of DMI with SystemMemoryCache
var numDmiWithSP = 0; // Number of DMIs with ScratchPad memory
var idxDmiWithSP = 0; // To get valid index of DMIs with ScratchPad memory
var numDmiWithWP = 0; // Number of DMIs with WayPartitioning
var idxDmiWithWP = 0; // To get valid index of DMIs with WayPartitioning
var aceIdx = [];
var clocks = [];
var clocks_freq = [];
var csrAccess_ioaiu;
var csrAccess_chiaiu;
var found_csr_access_chiaiu=0;
var found_csr_access_ioaiu=0;
const aiu_axiInt = [];
var aiu_NumCores = [];
var aiu_NumPorts = 0;
var initiatorAgents   = obj.AiuInfo.length ;

for(var pidx = 0; pidx < initiatorAgents; pidx++) { 
   if(obj.AiuInfo[pidx].nNativeInterfacePorts) {
       aiu_NumCores[pidx]    = obj.AiuInfo[pidx].nNativeInterfacePorts;
       aiu_NumPorts          += obj.AiuInfo[pidx].nNativeInterfacePorts;
   } else {
       aiu_NumCores[pidx]    = 1;
       aiu_NumPorts++;
   }
 }

for(var pidx = 0; pidx < obj.nAIUs; pidx++) {
    if(Array.isArray(obj.AiuInfo[pidx].interfaces.axiInt)) {
        aiu_axiInt[pidx] = obj.AiuInfo[pidx].interfaces.axiInt[0];
    } else {
        aiu_axiInt[pidx] = obj.AiuInfo[pidx].interfaces.axiInt;
    }
}


for(var pidx = 0; pidx < obj.nDMIs; pidx++) {
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
         if(obj.DmiInfo[pidx].ccpParams.useWayPartitioning)
            {
              numDmiWithWP++;
              idxDmiWithWP = pidx;
            }
       }
}
for(var pidx = 0; pidx < obj.nDIIs; pidx++) {
    pma_en_dii_blk &= obj.DiiInfo[pidx].usePma;
    pma_en_at_least_1_blk |= obj.DiiInfo[pidx].usePma;
}
for(var pidx = 0; pidx < obj.nAIUs; pidx++) {
    pma_en_aiu_blk &= obj.AiuInfo[pidx].usePma;
    pma_en_at_least_1_blk |= obj.AiuInfo[pidx].usePma;
    if((obj.AiuInfo[pidx].fnNativeInterface == "CHI-A")||(obj.AiuInfo[pidx].fnNativeInterface == "CHI-B" || obj.AiuInfo[pidx].fnNativeInterface == "CHI-E")) 
       { 
         if(numChiAiu == 0) { chiaiu0 = obj.AiuInfo[pidx].strRtlNamePrefix; }
         numChiAiu++ ; numCAiu++ ; 
       }
    else
       { numIoAiu++ ; 
         if(obj.AiuInfo[pidx].fnNativeInterface == "ACE") { numCAiu++; numACEAiu++; } else  numNCAiu++ ;
         if(obj.AiuInfo[pidx].useCache) idxIoAiuWithPC = numNCAiu;
       }
}
var chi_idx=0;
var ace_idx=0;
var io_idx=0;
for(var pidx = 0; pidx < obj.nAIUs; pidx++) {
    if((obj.AiuInfo[pidx].fnNativeInterface != "CHI-A")&&(obj.AiuInfo[pidx].fnNativeInterface != "CHI-B" && obj.AiuInfo[pidx].fnNativeInterface != "CHI-E")) 
    {
        if(obj.AiuInfo[pidx].fnNativeInterface == "ACE")
        {
            if(ace_idx == 0) { aceaiu0 = obj.AiuInfo[pidx].strRtlNamePrefix; }
            aceIdx[ace_idx] = io_idx;
            ace_idx++;
        }
        else
        {
            if(io_idx == 0) { ncaiu0 = obj.AiuInfo[pidx].strRtlNamePrefix; }
        }
        if((found_csr_access_ioaiu==0) && (obj.AiuInfo[pidx].fnCsrAccess == 1)) {
	   csrAccess_ioaiu = io_idx;
	   found_csr_access_ioaiu = 1;
        }
        io_idx++;
    } else {
        if((found_csr_access_chiaiu==0) && (obj.AiuInfo[pidx].fnCsrAccess == 1)) {
	   csrAccess_chiaiu = chi_idx;
	   found_csr_access_chiaiu = 1;
        }
        chi_idx++;
    }
} 
for(var pidx = 0; pidx < obj.nDCEs; pidx++) {
    pma_en_dce_blk &= obj.DceInfo[pidx].usePma;
    pma_en_at_least_1_blk |= obj.DceInfo[pidx].usePma;
}
for(var pidx = 0; pidx < obj.nDVEs; pidx++) {
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

for(var clock=0; clock < obj.Clocks.length; clock++) {
   var clk_name = obj.Clocks[clock].name;
   var name_len = clk_name.length;
   var mod_name;
   if(clk_name[name_len-1] == '_') {  // remove if last character is '_'
       mod_name = clk_name.substr(0, name_len-1);
   } else {
       mod_name = clk_name;
   }
   clocks[clock] = mod_name;
   clocks_freq[clock] = obj.Clocks[clock].params.frequency;
}
%>


//File: concerto_fullsys_qos_test.svh

<%  if((obj.INHOUSE_OCP_VIP)) { %>
import ocp_agent_pkg::*;
<%  } %>

<%  if((obj.INHOUSE_APB_VIP)|| (obj.useResiliency)) { %>
//import apb_agent_pkg::*;
<%  } %>


<%
var ioCacheEn = [];
var aiuNativeInf = [];
var dvmEn = [];
var dvmCmpEn = [];
var interlvAiu = [];
var cacheId;
var idSnoopFilterSlice = [];
var hntEn = [];
var hntEnVal;

//var agent_num = [];
//var current_agt_num = 0;
var count = -1 ;
var logical_id = -1;
var AgtIdToCacheId = [];
var aiuBundleIndex = [];
var nChiAgents = 0;
var nACEAgents = 0;


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
   var bundle_index = -1;
   
obj.AiuInfo.forEach(function(bundle, indx, array) {
  if (bundle.interleavedAgent == 0) {
    bundle_index += 1;
  }
  aiuBundleIndex.push(bundle_index);
});

%>



class concerto_fullsys_qos_test extends concerto_base_test;

    //////////////////
    //Properties
    //////////////////

    // newperf_test "duty_cycle" case & address setup
    int k_duty_cycle; 
    int k_duty_cycle_chi[int]; 
    int k_duty_cycle_ioaiu[int]; 
    int ioaiu_num_addr[int]; 
    int ioaiu_addr_idx_offset[int];
    int chi_addr_idx_offset[int];
    int axi_master_delay[int];
    int axi_master_delay2[int];
    int axi_master_burst_cycle[int];
    int axi_master_burst_txn[int];

    static uvm_event ev_report_bw = ev_pool.get("report_bw");

    //ACE Model
    <% var qidx=0; var idx=0; for(var pidx = 0 ; pidx < obj.nAIUs; pidx++) { %>
      <% if((obj.AiuInfo[pidx].fnNativeInterface == 'CHI-A') || (obj.AiuInfo[pidx].fnNativeInterface == 'CHI-B' || obj.AiuInfo[pidx].fnNativeInterface == 'CHI-E')) { %>
     `ifndef USE_VIP_SNPS //existing flow will not run when USE_VIP_SNPS set
           chiaiu<%=idx%>_chi_aiu_vseq_pkg::chi_aiu_vseq#(<%=obj.AiuInfo[pidx].FUnitId%>)       m_chi<%=idx%>_vseq;
           chi_aiu_unit_args_pkg::chi_aiu_unit_args                       m_chi<%=idx%>_args;
           chiaiu<%=idx%>_chi_aiu_vseq_pkg::chi_aiu_vseq#(<%=obj.AiuInfo[pidx].FUnitId%>)       m_chi<%=idx%>_vseq_2;
           chi_aiu_unit_args_pkg::chi_aiu_unit_args                       m_chi<%=idx%>_args2;
	   static uvm_event ev_chi<%=idx%>_seq_done = ev_pool.get("m_chi<%=idx%>_seq");
	   static uvm_event ev_chi<%=idx%>_seq2_done = ev_pool.get("m_chi<%=idx%>_seq2");
	   int chiaiu<%=idx%>_num_trans;
	   int chiaiu<%=idx%>_num_trans2;
      `else // `ifndef USE_VIP_SNPS
            chiaiu<%=idx%>_chi_aiu_vseq_pkg::snps_chi_aiu_vseq#(<%=obj.AiuInfo[pidx].FUnitId%>)   m_snps_chi<%=idx%>_vseq;
             //chiaiu<%=idx%>_chi_aiu_vseq_pkg::snps_chi_aiu_vseq#(<%=obj.AiuInfo[pidx].FUnitId%>)   m_snps_chi<%=idx%>_vseq_2;  //test_2
             chi_aiu_unit_args_pkg::chi_aiu_unit_args                       m_chi<%=idx%>_args;
             //chi_aiu_unit_args_pkg::chi_aiu_unit_args                       m_chi<%=idx%>_read_args;  // read
	     //static uvm_event ev_chi<%=idx%>_seq_done = ev_pool.get("m_chi<%=idx%>_seq");
	     //static uvm_event ev_chi<%=idx%>_read_seq_done = ev_pool.get("m_chi<%=idx%>_read_seq");
             int chiaiu<%=idx%>_num_trans;
	     int chiaiu<%=idx%>_num_trans2;
     `endif // `ifndef USE_VIP_SNPS ... `else
	   <%  idx++;   %>
       <% } else { %>
           ioaiu<%=qidx%>_inhouse_axi_bfm_pkg::axi_master_pipelined_seq          m_iocache_seq<%=qidx%>[<%=aiu_NumCores[pidx]%>];
           ioaiu<%=qidx%>_inhouse_axi_bfm_pkg::axi_master_pipelined_seq          m_iocache_seq<%=qidx%>_2[<%=aiu_NumCores[pidx]%>];
      <% if((obj.AiuInfo[pidx].fnNativeInterface == 'ACE') || (aiu_axiInt[pidx].params.eAc==1) ){ %>
           ioaiu<%=qidx%>_inhouse_axi_bfm_pkg::axi_master_snoop_seq              m_iosnoop_seq<%=qidx%>;
      <% } %>
     <%for(var coreidx=0; coreidx<aiu_NumCores[pidx]; coreidx++) { %>
	   static uvm_event ev_ioaiu<%=qidx%>_<%=coreidx%>_seq_done  = ev_pool.get( "m_ioaiu<%=qidx%>_<%=coreidx%>_seq");
	   static uvm_event ev_ioaiu<%=qidx%>_<%=coreidx%>_seq2_done = ev_pool.get( "m_ioaiu<%=qidx%>_<%=coreidx%>seq2");
	  <%}%>
	   int ioaiu<%=qidx%>_num_trans;
	   int ioaiu<%=qidx%>_num_trans2;
	<%  qidx++;   } %>
    <% } %>
   
    <% for(var pidx = 0 ; pidx < obj.nDMIs; pidx++) { %>
        dmi<%=pidx%>_inhouse_axi_bfm_pkg::axi_slave_read_seq   m_axi_slv_rd_seq_dmi<%=pidx%>;
        dmi<%=pidx%>_inhouse_axi_bfm_pkg::axi_slave_write_seq  m_axi_slv_wr_seq_dmi<%=pidx%>;
        dmi<%=pidx%>_inhouse_axi_bfm_pkg::axi_memory_model     m_axi_slv_memory_model_dmi<%=pidx%>;
        dmi<%=pidx%>_axi_agent_pkg::axi_agent_config  m_dmi<%=pidx%>_axi_slave_cfg;
    <% } %>

    <% for(var pidx = 0 ; pidx < obj.nDIIs; pidx++) { %>
	<% if(obj.DiiInfo[pidx].configuration == 0) { %>
        dii<%=pidx%>_inhouse_axi_bfm_pkg::axi_slave_read_seq   m_axi_slv_rd_seq_dii<%=pidx%>;
        dii<%=pidx%>_inhouse_axi_bfm_pkg::axi_slave_write_seq  m_axi_slv_wr_seq_dii<%=pidx%>;
        dii<%=pidx%>_inhouse_axi_bfm_pkg::axi_memory_model     m_axi_slv_memory_model_dii<%=pidx%>;
        <% } %>
    <% } %>
  
   `ifdef USE_VIP_SNPS
    bit vip_snps_non_coherent_txn = 0;
    bit vip_snps_coherent_txn = 0;
    int vip_snps_seq_length = 4;
    bit                          SYNPS_AXI_SLV_BACKPRESSURE_EN = 0;
    uvm_event                    svt_axi_common_aclk_posedge_e;

  <% var qidx=0;var idx=0; for(var pidx = 0; pidx < obj.nAIUs; pidx++) { %>
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
   `endif //`ifdef USE_VIP_SNPS 

    int chi_num_trans;
    int ioaiu_num_trans;
    int chi_num_trans2;
    int ioaiu_num_trans2;
    int boot_from_ioaiu;
    bit k_access_boot_region;
    bit k_csr_access_only;
    bit k_directed_test;
    bit k_directed_64B_aligned;
    int use_user_addrq;

   int 	      chiaiu_intrlv_grp;
   int 	      ioaiu_intrlv_grp;

   int 	      chiaiu_en[int];
   int 	      ioaiu_en[int];
   string     chiaiu_en_str[];
   string     ioaiu_en_str[];
   string     chiaiu_en_arg;
   string     ioaiu_en_arg;

   int 	      chiaiu_qos[int];
   int 	      ioaiu_qos[int];
   string     chiaiu_qos_str[];
   string     ioaiu_qos_str[];
   string     chiaiu_qos_arg;
   string     ioaiu_qos_arg;

   int 	      chiaiu_qos2[int];
   int 	      ioaiu_qos2[int];
   string     chiaiu_qos2_str[];
   string     ioaiu_qos2_str[];
   string     chiaiu_qos2_arg;
   string     ioaiu_qos2_arg;

   int 	      chiaiu_slow_master[int];
   string     chiaiu_slow_master_str[];
   string     chiaiu_slow_master_arg;
   int 	      ioaiu_slow_master[int];
   string     ioaiu_slow_master_str[];
   string     ioaiu_slow_master_arg;
   int 	      dmi_slow_slave[int];
   string     dmi_slow_slave_str[];
   string     dmi_slow_slave_arg;
   
   int 	      perf_txn_size;
   int 	      perf_coh_txn_size;
   int 	      perf_noncoh_txn_size[0:1];

   int 	      chi_txreq_dly;
   int 	      chi_txreq_dly2;

   <% var cidx=0; var ioidx=0;
   for(var idx = 0, qidx=0; idx < obj.nAIUs; idx++) { 
   if((obj.AiuInfo[idx].fnNativeInterface == 'CHI-A')||(obj.AiuInfo[idx].fnNativeInterface == 'CHI-B') || obj.AiuInfo[idx].fnNativeInterface == 'CHI-E') { %>
   int        chiaiu<%=cidx%>_read_ratio;
   int        chiaiu<%=cidx%>_write_ratio;
   int        chiaiu<%=cidx%>_read_ratio2;
   int        chiaiu<%=cidx%>_write_ratio2;
   <% cidx++; }
   else { %>
   int        ioaiu<%=ioidx%>_read_ratio;
   int        ioaiu<%=ioidx%>_write_ratio;
   int        ioaiu<%=ioidx%>_read_ratio2;
   int        ioaiu<%=ioidx%>_write_ratio2;

   int ioaiu<%=ioidx%>_collision_pct;
   int ioaiu<%=ioidx%>_num_collision;
   int ioaiu<%=ioidx%>_collision_pct2;
   int ioaiu<%=ioidx%>_num_collision2;
   <% ioidx++; }
   } %>

    //////////////////
    //UVM Registery
    //////////////////    
    `uvm_component_utils(concerto_fullsys_qos_test)

    //////////////////
    //Methods
    //////////////////
    extern function new(string name = "concerto_fullsys_qos_test", uvm_component parent = null);
    extern virtual function void build_phase(uvm_phase  phase);
    //extern virtual function void connect_pahse(uvm_phase phase);
    extern virtual function void end_of_elaboration_phase(uvm_phase phase);
    extern virtual task run_phase(uvm_phase phase);
    extern virtual task exec_inhouse_seq(uvm_phase phase);
    extern virtual task exec_inhouse_boot_seq(uvm_phase phase);
    extern virtual task exec_snoop_seq(uvm_phase phase);
    extern virtual task exec_cache_preload_seq(uvm_phase phase); 
    extern virtual task exec_qos_seq(uvm_phase phase);
    extern virtual task set_ioaiu_control_cfg();
    extern virtual task gen_user_addrq();
    extern virtual function void start_of_simulation_phase(uvm_phase phase);
    extern virtual function void report_phase(uvm_phase phase);

    <% for(var idx = 0, qidx=0; idx < obj.nAIUs; idx++) { 
    if(!(obj.AiuInfo[idx].fnNativeInterface.match('CHI'))) { %>
    extern virtual task read_once<%=qidx%>(input ioaiu<%=qidx%>_axi_agent_pkg::axi_axaddr_t addr, input ioaiu<%=qidx%>_axi_agent_pkg::axi_axlen_t axlen, ioaiu<%=qidx%>_axi_agent_pkg::axi_arid_t arid, output bit[ioaiu<%=qidx%>_axi_agent_pkg::WXDATA-1:0] data);
    extern virtual task write_unq<%=qidx%>(input ioaiu<%=qidx%>_axi_agent_pkg::axi_axaddr_t addr, input bit[ioaiu<%=qidx%>_axi_agent_pkg::WXDATA-1:0] data, input ioaiu<%=qidx%>_axi_agent_pkg::axi_axlen_t axlen, ioaiu<%=qidx%>_axi_agent_pkg::axi_awid_t awid, input bit use_user_data=0);
    extern virtual task read_nosnp<%=qidx%>(input ioaiu<%=qidx%>_axi_agent_pkg::axi_axaddr_t addr, input ioaiu<%=qidx%>_axi_agent_pkg::axi_axlen_t axlen, ioaiu<%=qidx%>_axi_agent_pkg::axi_arid_t arid, output bit[ioaiu<%=qidx%>_axi_agent_pkg::WXDATA-1:0] data);
    extern virtual task write_nosnp<%=qidx%>(input ioaiu<%=qidx%>_axi_agent_pkg::axi_axaddr_t addr, input bit[ioaiu<%=qidx%>_axi_agent_pkg::WXDATA-1:0] data, input ioaiu<%=qidx%>_axi_agent_pkg::axi_axlen_t axlen, ioaiu<%=qidx%>_axi_agent_pkg::axi_awid_t awid, input bit use_user_data=0);
    extern virtual task write_4KB_block<%=qidx%>(input ioaiu<%=qidx%>_axi_agent_pkg::axi_axaddr_t dmi_addr, input int txn_size);
    extern virtual task read_4KB_block<%=qidx%>(input ioaiu<%=qidx%>_axi_agent_pkg::axi_axaddr_t dmi_addr, input int txn_size);
    extern virtual task writeread_4KB_block<%=qidx%>(input ioaiu<%=qidx%>_axi_agent_pkg::axi_axaddr_t dmi_addr, input int txn_size, input int loop_cnt);
    ioaiu<%=qidx%>_axi_agent_pkg::axi_virtual_sequencer  m_ioaiu_vseqr<%=qidx%>[<%=aiu_NumCores[idx]%>];
    <% qidx++; }
    } %>
   
endclass: concerto_fullsys_qos_test

//////////////////
//Calling Method: Child Class
//Description: Constructor
//Arguments:   UVM Default
//Return type: N/A
//////////////////
function concerto_fullsys_qos_test::new(string name = "concerto_fullsys_qos_test", uvm_component parent = null);
    super.new(name, parent);
endfunction: new

//////////////////
//Calling Method: UVM Factory
//Description: Build phase
//Arguments:   UVM Default
//Return type: Void
//////////////////
function void concerto_fullsys_qos_test::build_phase(uvm_phase phase);
   int 	      i;
   int 	      transorder_mode;
   
    string msg_idx;
    `uvm_info("Build", "Entered Build Phase", UVM_LOW);
    super.build_phase(phase);

    if($value$plusargs("ioaiu_slow_master=%s", ioaiu_slow_master_arg)) begin
       if(ioaiu_slow_master_arg.tolower() == "all") begin
	  for(i=0; i < <%=numIoAiu%>; i=i+1) begin
	     ioaiu_slow_master[i] = 1;
	  end
       end
       else begin
          parse_str(ioaiu_slow_master_str, "n", ioaiu_slow_master_arg);
          foreach (ioaiu_slow_master_str[i]) begin
	     ioaiu_slow_master[ioaiu_slow_master_str[i].atoi()] = 1;
          end
       end
    end


<% for(var pidx = 0 ; pidx < obj.nDMIs; pidx++) { %>
    m_axi_slv_memory_model_dmi<%=pidx%> = dmi<%=pidx%>_inhouse_axi_bfm_pkg::axi_memory_model::type_id::create("m_axi_slv_memory_model");
    m_dmi<%=pidx%>_axi_slave_cfg      = dmi<%=pidx%>_axi_agent_pkg::axi_agent_config::type_id::create("m_dmi<%=pidx%>_axi_slave_cfg",  this);
    m_dmi<%=pidx%>_axi_slave_cfg.active = UVM_ACTIVE;

    m_concerto_env_cfg.m_dmi<%=pidx%>_env_cfg.m_axi_slave_agent_cfg.active = UVM_ACTIVE;
<% } %>

<% for(var pidx = 0 ; pidx < obj.nDIIs; pidx++) { %>
    <% if(obj.DiiInfo[pidx].configuration == 0) { %>
    m_axi_slv_memory_model_dii<%=pidx%> = dii<%=pidx%>_inhouse_axi_bfm_pkg::axi_memory_model::type_id::create("m_axi_slv_memory_model");
  

<%    if (obj.DiiInfo[pidx].configuration != 1) { %>
    m_concerto_env_cfg.m_dii<%=pidx%>_env_cfg.m_axi_slave_agent_cfg.active = UVM_ACTIVE;
    <% } %>
<% } %>
<% } %>

    // Send TransOrder Mode setting to ACE scoreboard
    if($value$plusargs("ace_transorder_mode=%d", transorder_mode)) begin
<% for(var pidx = 0 ; pidx < obj.nAIUs; pidx++) { %>
<% if((obj.AiuInfo[pidx].fnNativeInterface == 'ACE') || (obj.AiuInfo[pidx].fnNativeInterface == 'ACE-LITE') || (obj.AiuInfo[pidx].fnNativeInterface == 'ACELITE-E') || (obj.AiuInfo[pidx].fnNativeInterface == 'AXI4')) { %>
       uvm_config_db#(int)::set(null,"<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_env","transOrderMode_wr", transorder_mode);
       uvm_config_db#(int)::set(null,"<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_env","transOrderMode_rd", transorder_mode);
<% } } %>
    end

    set_inactivity_period(m_args.k_timeout);

    `uvm_info("Build", "Exited Build Phase", UVM_LOW);

endfunction: build_phase

//////////////////
//Calling Method: UVM Factory
//Description: end of elaboration phase
//Arguments:   UVM Default
//Return type: Void
//////////////////
function void concerto_fullsys_qos_test::end_of_elaboration_phase(uvm_phase phase);
    int file_handle;
    `uvm_info("end_of_elaboration_phase", "Entered...", UVM_LOW)

   <% 
      var chiaiu_idx = 0;
      var ioaiu_idx = 0;
   %>
<% for(var pidx = 0 ; pidx < obj.nAIUs; pidx++) { 
    if(!(obj.AiuInfo[pidx].fnNativeInterface.match('CHI'))) { 
     for(var coreidx=0; coreidx<aiu_NumCores[pidx]; coreidx++) { %> 
   if(!(uvm_config_db#(ioaiu<%=ioaiu_idx%>_axi_agent_pkg::axi_virtual_sequencer)::get(.cntxt( null ),.inst_name( "" ),.field_name( "m_ioaiu_vseqr<%=ioaiu_idx%>[<%=coreidx%>]" ),.value( m_ioaiu_vseqr<%=ioaiu_idx%>[<%=coreidx%>] ) ))) begin
     `uvm_error(get_name(), "Cannot get m_ioaiu_vseqr<%=ioaiu_idx%>[<%=coreidx%>]")
     end
    m_concerto_env.inhouse.m_ace_cache_model_ioaiu<%=ioaiu_idx%>[<%=coreidx%>].prob_unq_cln_to_unq_dirty                    =  m_args.aiu<%=pidx%>_prob_unq_cln_to_unq_dirty;
    m_concerto_env.inhouse.m_ace_cache_model_ioaiu<%=ioaiu_idx%>[<%=coreidx%>].prob_unq_cln_to_invalid                      =  m_args.aiu<%=pidx%>_prob_unq_cln_to_invalid;
    m_concerto_env.inhouse.m_ace_cache_model_ioaiu<%=ioaiu_idx%>[<%=coreidx%>].total_outstanding_coh_writes                 =  m_args.aiu<%=pidx%>_total_outstanding_coh_writes;
    m_concerto_env.inhouse.m_ace_cache_model_ioaiu<%=ioaiu_idx%>[<%=coreidx%>].total_min_ace_cache_size                     =  m_args.aiu<%=pidx%>_total_min_ace_cache_size;
    m_concerto_env.inhouse.m_ace_cache_model_ioaiu<%=ioaiu_idx%>[<%=coreidx%>].total_max_ace_cache_size                     =  m_args.aiu<%=pidx%>_total_max_ace_cache_size;
    m_concerto_env.inhouse.m_ace_cache_model_ioaiu<%=ioaiu_idx%>[<%=coreidx%>].size_of_wr_queue_before_flush                =  m_args.aiu<%=pidx%>_size_of_wr_queue_before_flush;
    m_concerto_env.inhouse.m_ace_cache_model_ioaiu<%=ioaiu_idx%>[<%=coreidx%>].wt_expected_end_state                        =  m_args.aiu<%=pidx%>_wt_expected_end_state;
    m_concerto_env.inhouse.m_ace_cache_model_ioaiu<%=ioaiu_idx%>[<%=coreidx%>].wt_legal_end_state_with_sf                   =  m_args.aiu<%=pidx%>_wt_legal_end_state_with_sf;
    m_concerto_env.inhouse.m_ace_cache_model_ioaiu<%=ioaiu_idx%>[<%=coreidx%>].wt_legal_end_state_without_sf                =  m_args.aiu<%=pidx%>_wt_legal_end_state_without_sf;
    m_concerto_env.inhouse.m_ace_cache_model_ioaiu<%=ioaiu_idx%>[<%=coreidx%>].wt_expected_start_state                      =  m_args.aiu<%=pidx%>_wt_expected_start_state;
    m_concerto_env.inhouse.m_ace_cache_model_ioaiu<%=ioaiu_idx%>[<%=coreidx%>].wt_legal_start_state                         =  m_args.aiu<%=pidx%>_wt_legal_start_state;
    m_concerto_env.inhouse.m_ace_cache_model_ioaiu<%=ioaiu_idx%>[<%=coreidx%>].wt_lose_cache_line_on_snps                   =  m_args.aiu<%=pidx%>_wt_lose_cache_line_on_snps;
    m_concerto_env.inhouse.m_ace_cache_model_ioaiu<%=ioaiu_idx%>[<%=coreidx%>].wt_keep_drty_cache_line_on_snps              =  m_args.aiu<%=pidx%>_wt_keep_drty_cache_line_on_snps;
    m_concerto_env.inhouse.m_ace_cache_model_ioaiu<%=ioaiu_idx%>[<%=coreidx%>].prob_respond_to_snoop_coll_with_wr           =  m_args.aiu<%=pidx%>_prob_respond_to_snoop_coll_with_wr;
    m_concerto_env.inhouse.m_ace_cache_model_ioaiu<%=ioaiu_idx%>[<%=coreidx%>].prob_was_unique_snp_resp                     =  m_args.aiu<%=pidx%>_prob_was_unique_snp_resp;
    m_concerto_env.inhouse.m_ace_cache_model_ioaiu<%=ioaiu_idx%>[<%=coreidx%>].prob_was_unique_always0_snp_resp             =  m_args.aiu<%=pidx%>_prob_was_unique_always0_snp_resp;
    m_concerto_env.inhouse.m_ace_cache_model_ioaiu<%=ioaiu_idx%>[<%=coreidx%>].prob_dataxfer_snp_resp_on_clean_hit          =  m_args.aiu<%=pidx%>_prob_dataxfer_snp_resp_on_clean_hit;
    m_concerto_env.inhouse.m_ace_cache_model_ioaiu<%=ioaiu_idx%>[<%=coreidx%>].prob_ace_wr_ix_start_state                   =  m_args.aiu<%=pidx%>_prob_ace_wr_ix_start_state;
    m_concerto_env.inhouse.m_ace_cache_model_ioaiu<%=ioaiu_idx%>[<%=coreidx%>].prob_ace_rd_ix_start_state                   =  m_args.aiu<%=pidx%>_prob_ace_rd_ix_start_state;
    m_concerto_env.inhouse.m_ace_cache_model_ioaiu<%=ioaiu_idx%>[<%=coreidx%>].prob_cache_flush_mode_per_1k                 =  m_args.aiu<%=pidx%>_prob_cache_flush_mode_per_1k;
    m_concerto_env.inhouse.m_ace_cache_model_ioaiu<%=ioaiu_idx%>[<%=coreidx%>].prob_ace_coh_win_error                       =  m_args.aiu<%=pidx%>_prob_ace_coh_win_error;
    m_concerto_env_cfg.m_ioaiu<%=ioaiu_idx%>_env_cfg[<%=coreidx%>].m_axi_master_agent_cfg.active =  UVM_ACTIVE;

    if(ioaiu_slow_master.exists(<%=ioaiu_idx%>)) begin
        `uvm_info("TEST_MAIN", "IOAIU<%=ioaiu_idx%> slow master", UVM_MEDIUM)
        m_concerto_env_cfg.m_ioaiu<%=ioaiu_idx%>_env_cfg[<%=coreidx%>].m_axi_master_agent_cfg.k_ace_master_read_addr_chnl_burst_pct.set_value(20);
        m_concerto_env_cfg.m_ioaiu<%=ioaiu_idx%>_env_cfg[<%=coreidx%>].m_axi_master_agent_cfg.k_ace_master_read_addr_chnl_delay_min.set_value(500);
        m_concerto_env_cfg.m_ioaiu<%=ioaiu_idx%>_env_cfg[<%=coreidx%>].m_axi_master_agent_cfg.k_ace_master_read_addr_chnl_delay_max.set_value(5000);
        m_concerto_env_cfg.m_ioaiu<%=ioaiu_idx%>_env_cfg[<%=coreidx%>].m_axi_master_agent_cfg.k_ace_master_read_data_chnl_burst_pct.set_value(100);
        m_concerto_env_cfg.m_ioaiu<%=ioaiu_idx%>_env_cfg[<%=coreidx%>].m_axi_master_agent_cfg.k_ace_master_write_addr_chnl_burst_pct.set_value(20);
        m_concerto_env_cfg.m_ioaiu<%=ioaiu_idx%>_env_cfg[<%=coreidx%>].m_axi_master_agent_cfg.k_ace_master_write_addr_chnl_delay_min.set_value(500);
        m_concerto_env_cfg.m_ioaiu<%=ioaiu_idx%>_env_cfg[<%=coreidx%>].m_axi_master_agent_cfg.k_ace_master_write_addr_chnl_delay_max.set_value(5000);
        m_concerto_env_cfg.m_ioaiu<%=ioaiu_idx%>_env_cfg[<%=coreidx%>].m_axi_master_agent_cfg.k_ace_master_write_data_chnl_burst_pct.set_value(100);
        m_concerto_env_cfg.m_ioaiu<%=ioaiu_idx%>_env_cfg[<%=coreidx%>].m_axi_master_agent_cfg.k_ace_master_write_resp_chnl_burst_pct.set_value(100);
    end // if (!ioaiu_slow_master[<%=ioaiu_idx%>].exists())
    else begin
        `uvm_info("TEST_MAIN", "IOAIU<%=ioaiu_idx%> fast master", UVM_MEDIUM)
        m_concerto_env_cfg.m_ioaiu<%=ioaiu_idx%>_env_cfg[<%=coreidx%>].m_axi_master_agent_cfg.k_ace_master_read_addr_chnl_delay_min.set_value(0);
        m_concerto_env_cfg.m_ioaiu<%=ioaiu_idx%>_env_cfg[<%=coreidx%>].m_axi_master_agent_cfg.k_ace_master_read_addr_chnl_delay_max.set_value(0);
        m_concerto_env_cfg.m_ioaiu<%=ioaiu_idx%>_env_cfg[<%=coreidx%>].m_axi_master_agent_cfg.k_ace_master_read_addr_chnl_burst_pct.set_value(100);
        m_concerto_env_cfg.m_ioaiu<%=ioaiu_idx%>_env_cfg[<%=coreidx%>].m_axi_master_agent_cfg.k_ace_master_read_data_chnl_delay_min.set_value(0);
        m_concerto_env_cfg.m_ioaiu<%=ioaiu_idx%>_env_cfg[<%=coreidx%>].m_axi_master_agent_cfg.k_ace_master_read_data_chnl_delay_max.set_value(0);
        m_concerto_env_cfg.m_ioaiu<%=ioaiu_idx%>_env_cfg[<%=coreidx%>].m_axi_master_agent_cfg.k_ace_master_read_data_chnl_burst_pct.set_value(100);
        m_concerto_env_cfg.m_ioaiu<%=ioaiu_idx%>_env_cfg[<%=coreidx%>].m_axi_master_agent_cfg.k_ace_master_write_addr_chnl_delay_min.set_value(0);
        m_concerto_env_cfg.m_ioaiu<%=ioaiu_idx%>_env_cfg[<%=coreidx%>].m_axi_master_agent_cfg.k_ace_master_write_addr_chnl_delay_max.set_value(0);
        m_concerto_env_cfg.m_ioaiu<%=ioaiu_idx%>_env_cfg[<%=coreidx%>].m_axi_master_agent_cfg.k_ace_master_write_addr_chnl_burst_pct.set_value(100);
        m_concerto_env_cfg.m_ioaiu<%=ioaiu_idx%>_env_cfg[<%=coreidx%>].m_axi_master_agent_cfg.k_ace_master_write_data_chnl_delay_min.set_value(0);
        m_concerto_env_cfg.m_ioaiu<%=ioaiu_idx%>_env_cfg[<%=coreidx%>].m_axi_master_agent_cfg.k_ace_master_write_data_chnl_delay_max.set_value(0);
        m_concerto_env_cfg.m_ioaiu<%=ioaiu_idx%>_env_cfg[<%=coreidx%>].m_axi_master_agent_cfg.k_ace_master_write_data_chnl_burst_pct.set_value(100);
        m_concerto_env_cfg.m_ioaiu<%=ioaiu_idx%>_env_cfg[<%=coreidx%>].m_axi_master_agent_cfg.k_ace_master_write_resp_chnl_delay_min.set_value(0);
        m_concerto_env_cfg.m_ioaiu<%=ioaiu_idx%>_env_cfg[<%=coreidx%>].m_axi_master_agent_cfg.k_ace_master_write_resp_chnl_delay_max.set_value(0);
        m_concerto_env_cfg.m_ioaiu<%=ioaiu_idx%>_env_cfg[<%=coreidx%>].m_axi_master_agent_cfg.k_ace_master_write_resp_chnl_burst_pct.set_value(100);
    end
	//newperf_test Force no delay on slave bus interface of the ioaiu 											     
    m_concerto_env_cfg.m_ioaiu<%=ioaiu_idx%>_env_cfg[<%=coreidx%>].m_axi_master_agent_cfg.k_ace_slave_read_addr_chnl_burst_pct.set_value(100);
    m_concerto_env_cfg.m_ioaiu<%=ioaiu_idx%>_env_cfg[<%=coreidx%>].m_axi_master_agent_cfg.k_ace_slave_read_data_chnl_burst_pct.set_value(100);
    m_concerto_env_cfg.m_ioaiu<%=ioaiu_idx%>_env_cfg[<%=coreidx%>].m_axi_master_agent_cfg.k_ace_slave_write_addr_chnl_burst_pct.set_value(100);
    m_concerto_env_cfg.m_ioaiu<%=ioaiu_idx%>_env_cfg[<%=coreidx%>].m_axi_master_agent_cfg.k_ace_slave_write_data_chnl_burst_pct.set_value(100);
    m_concerto_env_cfg.m_ioaiu<%=ioaiu_idx%>_env_cfg[<%=coreidx%>].m_axi_master_agent_cfg.k_ace_slave_write_resp_chnl_burst_pct.set_value(100);
    <% }	//foreach core%> 
    <% ioaiu_idx++;} %>
<% } %>

    if (this.get_report_verbosity_level() > UVM_LOW) begin
        uvm_top.print_topology();
    end
    `uvm_info("end_of_elaboration_phase", "Exiting...", UVM_LOW)
endfunction: end_of_elaboration_phase

//////////////////
//Calling Method: run_phase()
//Description: initialize memory
//Arguments:   void
//Return type: N/A
//////////////////
task concerto_fullsys_qos_test::run_phase(uvm_phase phase);
   super.run_phase(phase);
   addr_mgr.get_connectivity_if();
   `uvm_info("TEST_MAIN", "Starting concerto_fullsys_qos_test::exec_inhouse_seq ...", UVM_LOW)
    exec_inhouse_seq(phase);
   `uvm_info("TEST_MAIN", "Finish concerto_fullsys_qos_test ...", UVM_LOW)

endtask: run_phase


//////////////////
//Return type: Void
//////////////////
task concerto_fullsys_qos_test::exec_inhouse_seq(uvm_phase phase);
   `ifdef USE_VIP_SNPS
  <% if(numChiAiu > 0) { %>
    svt_chi_item m_svt_chi_item;
  <% } %>
   `endif
    bit timeout;
   bit [31:0] ioaiu_control_cfg;
   int        wt_axlen_256B;
   int 	      cacheline_size;
   int 	      stagger_address[4] = {'h0, 'h140, 'h280, 'h3c0};
   int        intrlved_dmis;

   string     alternate_str[];
   string     alternate_arg;
   string     force_axid_str[];
   string     force_axid_arg;
   int        ioaiu_force_axid;
   string     perf_noncoh_txn_size_str[];
   string     perf_noncoh_txn_size_arg;

   int 	      i, idx_offset;

   int        clk_off_time;
   int        clk_off_en[int];
   string     clk_off_en_str[];
   string     clk_off_en_arg;
   int        clk_off_chiaiu[int];
   string     clk_off_chiaiu_str[];
   string     clk_off_chiaiu_arg;
   int        clk_off_ioaiu[int];
   string     clk_off_ioaiu_str[];
   string     clk_off_ioaiu_arg;

    if (!$value$plusargs("chi_num_trans=%d",chi_num_trans)) begin
        chi_num_trans = 0;
    end
    if (!$value$plusargs("ioaiu_num_trans=%d",ioaiu_num_trans)) begin
        ioaiu_num_trans = 0;
    end
    if (!$value$plusargs("chi_num_trans2=%d",chi_num_trans2)) begin
        chi_num_trans2 = chi_num_trans;
    end
    if (!$value$plusargs("ioaiu_num_trans2=%d",ioaiu_num_trans2)) begin
        ioaiu_num_trans2 = ioaiu_num_trans;
    end
    if(!$value$plusargs("k_duty_cycle=%d", k_duty_cycle)) begin 
      k_duty_cycle = 0; 
   end 

   <% var chiaiu_idx=0; ioaiu_idx=0;
    for(var pidx = 0 ; pidx < obj.nAIUs; pidx++) { %>
    <% if((obj.AiuInfo[pidx].fnNativeInterface == 'CHI-A')||(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-B' || obj.AiuInfo[pidx].fnNativeInterface == 'CHI-E')) { %>
       if(!$value$plusargs("chiaiu<%=chiaiu_idx%>_num_trans=%d", chiaiu<%=chiaiu_idx%>_num_trans)) begin
          chiaiu<%=chiaiu_idx%>_num_trans = chi_num_trans;
       end
       if(!$value$plusargs("chiaiu<%=chiaiu_idx%>_read_ratio=%d", chiaiu<%=chiaiu_idx%>_read_ratio)) begin
          chiaiu<%=chiaiu_idx%>_read_ratio = 50;
       end
       if(!$value$plusargs("chiaiu<%=chiaiu_idx%>_write_ratio=%d", chiaiu<%=chiaiu_idx%>_write_ratio)) begin
          chiaiu<%=chiaiu_idx%>_write_ratio = 50;
       end

       if($test$plusargs("chiaiu<%=chiaiu_idx%>_read_ratio") && !($test$plusargs("chiaiu<%=chiaiu_idx%>_write_ratio"))) begin
           chiaiu<%=chiaiu_idx%>_write_ratio = 100 - chiaiu<%=chiaiu_idx%>_read_ratio;
       end													

       if($test$plusargs("chiaiu<%=chiaiu_idx%>_write_ratio") && !($test$plusargs("chiaiu<%=chiaiu_idx%>_read_ratio"))) begin
           chiaiu<%=chiaiu_idx%>_read_ratio = 100 - chiaiu<%=chiaiu_idx%>_write_ratio;
       end													

       if(!$value$plusargs("chiaiu<%=chiaiu_idx%>_num_trans2=%d", chiaiu<%=chiaiu_idx%>_num_trans2)) begin
          chiaiu<%=chiaiu_idx%>_num_trans2 = chi_num_trans2;
       end
       if(!$value$plusargs("chiaiu<%=chiaiu_idx%>_read_ratio2=%d", chiaiu<%=chiaiu_idx%>_read_ratio2)) begin
          chiaiu<%=chiaiu_idx%>_read_ratio2 = 50;
       end
       if(!$value$plusargs("chiaiu<%=chiaiu_idx%>_write_ratio2=%d", chiaiu<%=chiaiu_idx%>_write_ratio2)) begin
          chiaiu<%=chiaiu_idx%>_write_ratio2 = 50;
       end

       if($test$plusargs("chiaiu<%=chiaiu_idx%>_read_ratio2") && !($test$plusargs("chiaiu<%=chiaiu_idx%>_write_ratio2"))) begin
           chiaiu<%=chiaiu_idx%>_write_ratio2 = 100 - chiaiu<%=chiaiu_idx%>_read_ratio2;
       end													

       if($test$plusargs("chiaiu<%=chiaiu_idx%>_write_ratio2") && !($test$plusargs("chiaiu<%=chiaiu_idx%>_read_ratio2"))) begin
           chiaiu<%=chiaiu_idx%>_read_ratio2 = 100 - chiaiu<%=chiaiu_idx%>_write_ratio2;
       end													

      // newperf_test : new plusargs
      if(!$value$plusargs("chi<%=chiaiu_idx%>_addr_idx_offset=%d", chi_addr_idx_offset[<%=chiaiu_idx%>])) begin 
         chi_addr_idx_offset[<%=chiaiu_idx%>] = -1;
      end 
      if(!$value$plusargs("chi<%=chiaiu_idx%>_duty_cycle=%d", k_duty_cycle_ioaiu[<%=chiaiu_idx%>])) begin
         k_duty_cycle_chi[<%=chiaiu_idx%>]=k_duty_cycle;
        end
    <% chiaiu_idx++; }
    else { %>
       if(!$value$plusargs("ioaiu<%=ioaiu_idx%>_num_trans=%d", ioaiu<%=ioaiu_idx%>_num_trans)) begin
          ioaiu<%=ioaiu_idx%>_num_trans = ioaiu_num_trans;
       end

       if(!$value$plusargs("ioaiu<%=ioaiu_idx%>_read_ratio=%d", ioaiu<%=ioaiu_idx%>_read_ratio)) begin
          ioaiu<%=ioaiu_idx%>_read_ratio = 50;
       end
       if(!$value$plusargs("ioaiu<%=ioaiu_idx%>_write_ratio=%d", ioaiu<%=ioaiu_idx%>_write_ratio)) begin
          ioaiu<%=ioaiu_idx%>_write_ratio = 50;
       end

       if($test$plusargs("ioaiu<%=ioaiu_idx%>_read_ratio") && !($test$plusargs("ioaiu<%=ioaiu_idx%>_write_ratio"))) begin
           ioaiu<%=ioaiu_idx%>_write_ratio = 100 - ioaiu<%=ioaiu_idx%>_read_ratio;
       end													
       if($test$plusargs("ioaiu<%=ioaiu_idx%>_write_ratio") && !($test$plusargs("ioaiu<%=ioaiu_idx%>_read_ratio"))) begin
           ioaiu<%=ioaiu_idx%>_read_ratio = 100 - ioaiu<%=ioaiu_idx%>_write_ratio;
       end													

       if(!$value$plusargs("ioaiu<%=ioaiu_idx%>_num_trans2=%d", ioaiu<%=ioaiu_idx%>_num_trans2)) begin
          ioaiu<%=ioaiu_idx%>_num_trans2 = ioaiu_num_trans2;
       end

       if(!$value$plusargs("ioaiu<%=ioaiu_idx%>_read_ratio2=%d", ioaiu<%=ioaiu_idx%>_read_ratio2)) begin
          ioaiu<%=ioaiu_idx%>_read_ratio2 = 50;
       end
       if(!$value$plusargs("ioaiu<%=ioaiu_idx%>_write_ratio2=%d", ioaiu<%=ioaiu_idx%>_write_ratio2)) begin
          ioaiu<%=ioaiu_idx%>_write_ratio2 = 50;
       end

       if($test$plusargs("ioaiu<%=ioaiu_idx%>_read_ratio2") && !($test$plusargs("ioaiu<%=ioaiu_idx%>_write_ratio2"))) begin
           ioaiu<%=ioaiu_idx%>_write_ratio2 = 100 - ioaiu<%=ioaiu_idx%>_read_ratio2;
       end													
       if($test$plusargs("ioaiu<%=ioaiu_idx%>_write_ratio2") && !($test$plusargs("ioaiu<%=ioaiu_idx%>_read_ratio2"))) begin
           ioaiu<%=ioaiu_idx%>_read_ratio2 = 100 - ioaiu<%=ioaiu_idx%>_write_ratio2;
       end													

       if(!$value$plusargs("ioaiu<%=ioaiu_idx%>_collision_pct=%d", ioaiu<%=ioaiu_idx%>_collision_pct)) begin
          ioaiu<%=ioaiu_idx%>_collision_pct = 0;
       end

       if(!$value$plusargs("ioaiu<%=ioaiu_idx%>_collision_pct2=%d", ioaiu<%=ioaiu_idx%>_collision_pct2)) begin
          ioaiu<%=ioaiu_idx%>_collision_pct2 = 0;
       end
	   // newperf_test : new plusargs
       if(!$value$plusargs("k_duty_cycle_ioaiu<%=ioaiu_idx%>=%d", k_duty_cycle_ioaiu[<%=ioaiu_idx%>])) begin 
         k_duty_cycle_ioaiu[<%=ioaiu_idx%>] = k_duty_cycle; 
      end 

	   // newperf_test : new plusargs
      if(!$value$plusargs("ioaiu<%=ioaiu_idx%>_num_addr=%d", ioaiu_num_addr[<%=ioaiu_idx%>])) begin 
         ioaiu_num_addr[<%=ioaiu_idx%>] = ioaiu_num_trans;
      end 

	   // newperf_test : new plusargs
      if(!$value$plusargs("ioaiu<%=ioaiu_idx%>_addr_idx_offset=%d", ioaiu_addr_idx_offset[<%=ioaiu_idx%>])) begin 
         ioaiu_addr_idx_offset[<%=ioaiu_idx%>] = -1;
      end 
    <% ioaiu_idx++; }
    } %>
    
    `ifdef USE_VIP_SNPS
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
  <% var qidx=0;var idx=0; %>
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
    <%} else {%>
     /*<%if((obj.AiuInfo[pidx].fnNativeInterface == 'ACE-LITE' || obj.AiuInfo[pidx].fnNativeInterface == 'ACELITE-E' || obj.AiuInfo[pidx].fnNativeInterface == 'ACE') || (obj.AiuInfo[pidx].fnNativeInterface == 'AXI4' && obj.AiuInfo[pidx].useCache)) { %>
     snp_cust_seq_h<%=qidx%> = ioaiu<%=qidx%>_env_pkg::snp_cust_seq::type_id::create("snp_cust_seq_h<%=qidx%>"); 
     <% } %> */
      //cust_seq_h<%=qidx%> = ioaiu<%=qidx%>_env_pkg::snps_axi_master_pipelined_seq::type_id::create("cust_seq_h<%=qidx%>");
  <% qidx++; } } %>
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

  
    /** Apply the null sequence to the AMBA ENV virtual sequencer to override the default sequence. */
    uvm_config_db#(uvm_object_wrapper)::set(this, "m_concerto_env.snps.svt.amba_system_env.sequencer.main_phase", "default_sequence", null ); 
   <% var chiaiu_idx=0; ioaiu_idx=0;
    for(var pidx = 0 ; pidx < obj.nAIUs; pidx++) { %>
    <% if((obj.AiuInfo[pidx].fnNativeInterface == 'CHI-A')||(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-B' || obj.AiuInfo[pidx].fnNativeInterface == 'CHI-E')) { %>
    
    //uvm_config_db#(uvm_object_wrapper)::set(this, "m_concerto_env.snps.svt.amba_system_env.chi_system[0].rn[<%=chiaiu_idx%>].rn_xact_seqr.main_phase", "default_sequence", svt_chi_rn_transaction_random_sequence::type_id::get());
    //uvm_config_db#(int unsigned)::set(this, "m_concerto_env.snps.svt.amba_system_env.chi_system[0].rn[<%=chiaiu_idx%>].rn_xact_seqr.svt_chi_rn_transaction_random_sequence", "sequence_length", vip_snps_seq_length);
    uvm_config_db#(int unsigned)::set(this, "m_concerto_env.snps.svt.amba_system_env.chi_system[0].rn[<%=chiaiu_idx%>].rn_xact_seqr.svt_chi_rn_transaction_random_sequence", "sequence_length", chi_num_trans);
    //uvm_config_db#(int unsigned)::set(this, "m_concerto_env.snps.svt.amba_system_env.chi_system[0].rn[<%=chiaiu_idx%>].rn_xact_seqr.svt_chi_rn_transaction_random_sequence", "sequence_length", 0);
    uvm_config_db#(bit)::set(this, "m_concerto_env.snps.svt.amba_system_env.chi_system[0].rn[<%=chiaiu_idx%>].rn_xact_seqr.svt_chi_rn_transaction_random_sequence", "enable_non_blocking", 1);

    <% 
      chiaiu_idx++;
    } } %>
   `endif //`ifdef USE_VIP_SNPS
  
    if(!$value$plusargs("chiaiu_en=%s", chiaiu_en_arg)) begin
    <% var chiaiu_idx=0; for(var pidx = 0 ; pidx < obj.nAIUs; pidx++) { %>
    <% if((obj.AiuInfo[pidx].fnNativeInterface == 'CHI-A')||(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-B' || obj.AiuInfo[pidx].fnNativeInterface == 'CHI-E')) { %>
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
    <% var ioaiu_idx=0; for(var pidx = 0 ; pidx < obj.nAIUs; pidx++) { %>
    <% if((obj.AiuInfo[pidx].fnNativeInterface != 'CHI-A')&&(obj.AiuInfo[pidx].fnNativeInterface != 'CHI-B' && obj.AiuInfo[pidx].fnNativeInterface != 'CHI-E')) { %>
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
       `uvm_info("TEST_MAIN", $sformatf("chiaiu_en[%0d] = %0d", i, chiaiu_en[i]), UVM_MEDIUM)
    end
    foreach(ioaiu_en[i]) begin
       `uvm_info("TEST_MAIN", $sformatf("ioaiu_en[%0d] = %0d", i, ioaiu_en[i]), UVM_MEDIUM)
    end
   
    if(!$value$plusargs("chiaiu_qos=%s", chiaiu_qos_arg)) begin
    <% var chiaiu_idx=0; for(var pidx = 0 ; pidx < obj.nAIUs; pidx++) { %>
    <% if((obj.AiuInfo[pidx].fnNativeInterface == 'CHI-A')||(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-B' || obj.AiuInfo[pidx].fnNativeInterface == 'CHI-E')) { %>
       chiaiu_qos[<%=chiaiu_idx%>] = 0;
       <% chiaiu_idx++; } %>
    <% } %>
    end
    else begin
       parse_str(chiaiu_qos_str, "n", chiaiu_qos_arg);
       foreach (chiaiu_qos_str[i]) begin
	  chiaiu_qos[i] = chiaiu_qos_str[i].atoi();
       end
    end

    if(!$value$plusargs("ioaiu_qos=%s", ioaiu_qos_arg)) begin
    <% var ioaiu_idx=0; for(var pidx = 0 ; pidx < obj.nAIUs; pidx++) { %>
    <% if((obj.AiuInfo[pidx].fnNativeInterface != 'CHI-A')&&(obj.AiuInfo[pidx].fnNativeInterface != 'CHI-B' && obj.AiuInfo[pidx].fnNativeInterface != 'CHI-E')) { %>
       ioaiu_qos[<%=ioaiu_idx%>] = 0;
       <% ioaiu_idx++; } %>
    <% } %>
    end
    else begin
       parse_str(ioaiu_qos_str, "n", ioaiu_qos_arg);
       foreach (ioaiu_qos_str[i]) begin
	  ioaiu_qos[i] = ioaiu_qos_str[i].atoi();
       end
    end

    if(!$value$plusargs("chiaiu_qos2=%s", chiaiu_qos2_arg)) begin
    <% var chiaiu_idx=0; for(var pidx = 0 ; pidx < obj.nAIUs; pidx++) { %>
    <% if((obj.AiuInfo[pidx].fnNativeInterface == 'CHI-A')||(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-B' || obj.AiuInfo[pidx].fnNativeInterface == 'CHI-E')) { %>
       chiaiu_qos2[<%=chiaiu_idx%>] = 0;
       <% chiaiu_idx++; } %>
    <% } %>
    end
    else begin
       parse_str(chiaiu_qos2_str, "n", chiaiu_qos2_arg);
       foreach (chiaiu_qos2_str[i]) begin
	  chiaiu_qos2[i] = chiaiu_qos2_str[i].atoi();
       end
    end

    if(!$value$plusargs("ioaiu_qos2=%s", ioaiu_qos2_arg)) begin
    <% var ioaiu_idx=0; for(var pidx = 0 ; pidx < obj.nAIUs; pidx++) { %>
    <% if((obj.AiuInfo[pidx].fnNativeInterface != 'CHI-A')&&(obj.AiuInfo[pidx].fnNativeInterface != 'CHI-B' && obj.AiuInfo[pidx].fnNativeInterface != 'CHI-E')) { %>
       ioaiu_qos2[<%=ioaiu_idx%>] = 0;
       <% ioaiu_idx++; } %>
    <% } %>
    end
    else begin
       parse_str(ioaiu_qos2_str, "n", ioaiu_qos2_arg);
       foreach (ioaiu_qos2_str[i]) begin
	  ioaiu_qos2[i] = ioaiu_qos2_str[i].atoi();
       end
    end

    if($value$plusargs("chiaiu_slow_master=%s", chiaiu_slow_master_arg)) begin
       if(chiaiu_slow_master_arg.tolower() == "all") begin
	  for(i=0; i < <%=numChiAiu%>; i=i+1) begin
	     chiaiu_slow_master[i] = 1;
	  end
       end
       else begin
          parse_str(chiaiu_slow_master_str, "n", chiaiu_slow_master_arg);
          foreach (chiaiu_slow_master_str[i]) begin
	     chiaiu_slow_master[chiaiu_slow_master_str[i].atoi()] = 1;
          end
       end
    end

    if($value$plusargs("dmi_slow_slave=%s", dmi_slow_slave_arg)) begin
       parse_str(dmi_slow_slave_str, "n", dmi_slow_slave_arg);
       foreach (dmi_slow_slave_str[i]) begin
	  dmi_slow_slave[dmi_slow_slave_str[i].atoi()] = 1;
       end
    end

    if(!$value$plusargs("chiaiu_intrlv_grp=%d", chiaiu_intrlv_grp)) begin
       if($test$plusargs("use_dii_intrlv_grp")) begin
	  chiaiu_intrlv_grp = m_mem.dmi_grps.size();
       end
       else begin
          chiaiu_intrlv_grp = 0;
       end
    end
   
    if(!$value$plusargs("ioaiu_intrlv_grp=%d", ioaiu_intrlv_grp)) begin
       if($test$plusargs("use_dii_intrlv_grp")) begin
	  ioaiu_intrlv_grp = m_mem.dmi_grps.size();
       end
       else begin
          ioaiu_intrlv_grp = 0;
       end
    end
   
    if($value$plusargs("clk_off_en=%s", clk_off_en_arg)) begin
       parse_str(clk_off_en_str, "n", clk_off_en_arg);
       foreach (clk_off_en_str[i]) begin
	  clk_off_en[clk_off_en_str[i].atoi()] = 1;
       end
    end

    if($value$plusargs("clk_off_chiaiu=%s", clk_off_chiaiu_arg)) begin
       parse_str(clk_off_chiaiu_str, "n", clk_off_chiaiu_arg); 
       foreach (clk_off_chiaiu_str[i]) begin
	  clk_off_chiaiu[clk_off_chiaiu_str[i].atoi()] = 1;
       end
    end

    if($value$plusargs("clk_off_ioaiu=%s", clk_off_ioaiu_arg)) begin
       parse_str(clk_off_ioaiu_str, "n", clk_off_ioaiu_arg);
       foreach (clk_off_ioaiu_str[i]) begin
	  clk_off_ioaiu[clk_off_ioaiu_str[i].atoi()] = 1;
       end
    end

    if(!$value$plusargs("clk_off_time=%d", clk_off_time)) begin
       clk_off_time = 5000;  // time in ns to turn off clock
    end

    if (!$value$plusargs("cacheline_size=%d", cacheline_size)) begin
       cacheline_size = (1 << <%=obj.wCacheLineOffset%>);
    end
   
   if (!$value$plusargs("perf_txn_size=%d", perf_txn_size)) begin
       perf_txn_size = cacheline_size;
   	   perf_noncoh_txn_size = '{cacheline_size,cacheline_size};
	   perf_coh_txn_size= cacheline_size;
	end else begin
       perf_noncoh_txn_size = '{perf_txn_size,perf_txn_size};
       perf_coh_txn_size = perf_txn_size;
	end 

   	if (!$value$plusargs("perf_coh_txn_size=%d", perf_coh_txn_size)) begin
       perf_coh_txn_size = perf_txn_size;
    end
  	if ($value$plusargs("perf_noncoh_txn_size=%s",perf_noncoh_txn_size_arg)) begin
	        parse_str(perf_noncoh_txn_size_str, "n", perf_noncoh_txn_size_arg);
			foreach (perf_noncoh_txn_size_str[i])
                perf_noncoh_txn_size[i] = perf_noncoh_txn_size_str[i].atoi();
			if (perf_noncoh_txn_size_str.size()==1) perf_noncoh_txn_size[1] = perf_noncoh_txn_size[0];	   
     end
      
	if ($value$plusargs("wt_axlen_256B=%d",wt_axlen_256B)) begin // Override Cacheline size use as step in gen_seq_*_addr_*_in_user_addrq
       perf_txn_size = 256; //To have 256 Bytes adresses alignement
       perf_noncoh_txn_size = '{256,256};
       perf_coh_txn_size = 256;
    end

  <% for(var pidx = 0 ; pidx < obj.nDMIs; pidx++) { %>
    m_axi_slv_rd_seq_dmi<%=pidx%> = dmi<%=pidx%>_inhouse_axi_bfm_pkg::axi_slave_read_seq::type_id::create("m_axi_slv_rd_seq_dmi");
    m_axi_slv_wr_seq_dmi<%=pidx%> = dmi<%=pidx%>_inhouse_axi_bfm_pkg::axi_slave_write_seq::type_id::create("m_axi_slv_wr_seq_dmi");

    m_axi_slv_rd_seq_dmi<%=pidx%>.m_read_addr_chnl_seqr  = m_concerto_env.inhouse.m_dmi<%=pidx%>_env.m_axi_slave_agent.m_read_addr_chnl_seqr;
    m_axi_slv_rd_seq_dmi<%=pidx%>.m_read_data_chnl_seqr  = m_concerto_env.inhouse.m_dmi<%=pidx%>_env.m_axi_slave_agent.m_read_data_chnl_seqr;
    m_axi_slv_rd_seq_dmi<%=pidx%>.m_memory_model         = m_axi_slv_memory_model_dmi<%=pidx%>;
    m_axi_slv_rd_seq_dmi<%=pidx%>.prob_ace_rd_resp_error = m_args.dmi<%=pidx%>_prob_ace_slave_rd_resp_error;
    m_axi_slv_wr_seq_dmi<%=pidx%>.m_write_addr_chnl_seqr = m_concerto_env.inhouse.m_dmi<%=pidx%>_env.m_axi_slave_agent.m_write_addr_chnl_seqr;
    m_axi_slv_wr_seq_dmi<%=pidx%>.m_write_data_chnl_seqr = m_concerto_env.inhouse.m_dmi<%=pidx%>_env.m_axi_slave_agent.m_write_data_chnl_seqr;
    m_axi_slv_wr_seq_dmi<%=pidx%>.m_write_resp_chnl_seqr = m_concerto_env.inhouse.m_dmi<%=pidx%>_env.m_axi_slave_agent.m_write_resp_chnl_seqr;
    m_axi_slv_wr_seq_dmi<%=pidx%>.m_memory_model         = m_axi_slv_memory_model_dmi<%=pidx%>;
    m_axi_slv_wr_seq_dmi<%=pidx%>.prob_ace_wr_resp_error = m_args.dmi<%=pidx%>_prob_ace_slave_wr_resp_error;

    if(dmi_slow_slave.exists(<%=pidx%>)) begin
       `uvm_info("TEST_MAIN", "DMI<%=pidx%> slow slave", UVM_MEDIUM)
       m_dmi<%=pidx%>_axi_slave_cfg.k_slow_agent = 1;
    end
    else begin
       `uvm_info("TEST_MAIN", "DMI<%=pidx%> fast slave", UVM_MEDIUM)
       m_dmi<%=pidx%>_axi_slave_cfg.k_slow_agent = 0;
       m_dmi<%=pidx%>_axi_slave_cfg.k_ace_slave_read_addr_chnl_burst_pct.set_value(100);
       m_dmi<%=pidx%>_axi_slave_cfg.k_ace_slave_read_data_chnl_burst_pct.set_value(100);
       m_dmi<%=pidx%>_axi_slave_cfg.k_ace_slave_write_addr_chnl_burst_pct.set_value(100);
       m_dmi<%=pidx%>_axi_slave_cfg.k_ace_slave_write_data_chnl_burst_pct.set_value(100);
       m_dmi<%=pidx%>_axi_slave_cfg.k_ace_slave_write_resp_chnl_burst_pct.set_value(100);
    end
    m_concerto_env.inhouse.m_dmi<%=pidx%>_env.m_cfg.m_axi_slave_agent_cfg = m_dmi<%=pidx%>_axi_slave_cfg;
    m_concerto_env_cfg.m_dmi<%=pidx%>_env_cfg.m_axi_slave_agent_cfg.k_ace_slave_read_data_interbeatdly_dis.set_value(1);
    m_concerto_env_cfg.m_dmi<%=pidx%>_env_cfg.m_axi_slave_agent_cfg.k_ace_slave_random_dly_dis.set_value(1);
					    
    <% if(obj.DmiInfo[pidx].useCmc) { %>
    if(m_args.dmi_scb_en) begin  
       m_concerto_env.inhouse.m_dmi<%=pidx%>_env.m_sb.lookup_en = 1;						  
       if($test$plusargs("dmi_alloc_dis")) begin
          m_concerto_env.inhouse.m_dmi<%=pidx%>_env.m_sb.alloc_en = 0;
       end else begin
          m_concerto_env.inhouse.m_dmi<%=pidx%>_env.m_sb.alloc_en = 1;
       end						  
    end
    <% } %>						  
  <% } %>
  <% for(var pidx = 0 ; pidx < obj.nDIIs; pidx++) { %>
    <% if(obj.DiiInfo[pidx].configuration == 0) { %>
    m_axi_slv_rd_seq_dii<%=pidx%> = dii<%=pidx%>_inhouse_axi_bfm_pkg::axi_slave_read_seq::type_id::create("m_axi_slv_rd_seq_dii");
    m_axi_slv_wr_seq_dii<%=pidx%> = dii<%=pidx%>_inhouse_axi_bfm_pkg::axi_slave_write_seq::type_id::create("m_axi_slv_wr_seq_dii");

    m_axi_slv_rd_seq_dii<%=pidx%>.m_read_addr_chnl_seqr  = m_concerto_env.inhouse.m_dii<%=pidx%>_env.m_axi_slave_agent.m_read_addr_chnl_seqr;
    m_axi_slv_rd_seq_dii<%=pidx%>.m_read_data_chnl_seqr  = m_concerto_env.inhouse.m_dii<%=pidx%>_env.m_axi_slave_agent.m_read_data_chnl_seqr;
    m_axi_slv_rd_seq_dii<%=pidx%>.m_memory_model         = m_axi_slv_memory_model_dii<%=pidx%>;
    m_axi_slv_rd_seq_dii<%=pidx%>.prob_ace_rd_resp_error = m_args.dii<%=pidx%>_prob_ace_slave_rd_resp_error;
    m_axi_slv_wr_seq_dii<%=pidx%>.m_write_addr_chnl_seqr = m_concerto_env.inhouse.m_dii<%=pidx%>_env.m_axi_slave_agent.m_write_addr_chnl_seqr;
    m_axi_slv_wr_seq_dii<%=pidx%>.m_write_data_chnl_seqr = m_concerto_env.inhouse.m_dii<%=pidx%>_env.m_axi_slave_agent.m_write_data_chnl_seqr;
    m_axi_slv_wr_seq_dii<%=pidx%>.m_write_resp_chnl_seqr = m_concerto_env.inhouse.m_dii<%=pidx%>_env.m_axi_slave_agent.m_write_resp_chnl_seqr;
    m_axi_slv_wr_seq_dii<%=pidx%>.m_memory_model         = m_axi_slv_memory_model_dii<%=pidx%>;
    m_axi_slv_wr_seq_dii<%=pidx%>.prob_ace_wr_resp_error = m_args.dii<%=pidx%>_prob_ace_slave_wr_resp_error;
    <% } %>
  <% } %>
  `ifndef USE_VIP_SNPS //existing flow will not run when USE_VIP_SNPS set
  <% var qidx=0;var idx=0; for(var pidx = 0; pidx < obj.nAIUs; pidx++) { %>
    <% if((obj.AiuInfo[pidx].fnNativeInterface == 'CHI-A')||(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-B' || obj.AiuInfo[pidx].fnNativeInterface == 'CHI-E')) { %>
    m_chi<%=idx%>_vseq = chiaiu<%=idx%>_chi_aiu_vseq_pkg::chi_aiu_vseq#(<%=obj.AiuInfo[pidx].FUnitId%>)::type_id::create("m_chi<%=idx%>_seq");
    m_chi<%=idx%>_vseq.set_seq_name("m_chi<%=idx%>_seq");
    m_chi<%=idx%>_vseq.m_chi_container = m_concerto_env.inhouse.m_chi<%=idx%>_container;
    m_chi<%=idx%>_vseq.duty_cycle = k_duty_cycle_chi[<%=idx%>];

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

    m_chi<%=idx%>_vseq_2 = chiaiu<%=idx%>_chi_aiu_vseq_pkg::chi_aiu_vseq#(<%=obj.AiuInfo[pidx].FUnitId%>)::type_id::create("m_chi<%=idx%>_seq2");
    m_chi<%=idx%>_vseq_2.set_seq_name("m_chi<%=idx%>_seq2");
    m_chi<%=idx%>_vseq_2.m_chi_container = m_concerto_env.inhouse.m_chi<%=idx%>_container;

    m_chi<%=idx%>_vseq_2.m_rn_tx_req_chnl_seqr      = m_concerto_env.inhouse.m_chiaiu<%=idx%>_env.m_chi_agent.m_rn_tx_req_chnl_seqr;
    m_chi<%=idx%>_vseq_2.m_rn_tx_dat_chnl_seqr      = m_concerto_env.inhouse.m_chiaiu<%=idx%>_env.m_chi_agent.m_rn_tx_dat_chnl_seqr;
    m_chi<%=idx%>_vseq_2.m_rn_tx_rsp_chnl_seqr      = m_concerto_env.inhouse.m_chiaiu<%=idx%>_env.m_chi_agent.m_rn_tx_rsp_chnl_seqr;
    m_chi<%=idx%>_vseq_2.m_rn_rx_rsp_chnl_seqr      = m_concerto_env.inhouse.m_chiaiu<%=idx%>_env.m_chi_agent.m_rn_rx_rsp_chnl_seqr;
    m_chi<%=idx%>_vseq_2.m_rn_rx_dat_chnl_seqr      = m_concerto_env.inhouse.m_chiaiu<%=idx%>_env.m_chi_agent.m_rn_rx_dat_chnl_seqr;
    m_chi<%=idx%>_vseq_2.m_rn_rx_snp_chnl_seqr      = m_concerto_env.inhouse.m_chiaiu<%=idx%>_env.m_chi_agent.m_rn_rx_snp_chnl_seqr;
    m_chi<%=idx%>_vseq_2.m_lnk_hske_seqr            = m_concerto_env.inhouse.m_chiaiu<%=idx%>_env.m_chi_agent.m_lnk_hske_seqr;
    m_chi<%=idx%>_vseq_2.m_txs_actv_seqr            = m_concerto_env.inhouse.m_chiaiu<%=idx%>_env.m_chi_agent.m_txs_actv_seqr;
    m_chi<%=idx%>_vseq_2.m_sysco_seqr               = m_concerto_env.inhouse.m_chiaiu<%=idx%>_env.m_chi_agent.m_sysco_seqr;
    m_chi<%=idx%>_vseq_2.k_directed_test            = k_directed_test;

      <% idx++;  %>
    <%} else { %>
    <% for(var i=0; i<aiu_NumCores[pidx]; i++) { %>
    m_iocache_seq<%=qidx%>[<%=i%>]                        = ioaiu<%=qidx%>_inhouse_axi_bfm_pkg::axi_master_pipelined_seq::type_id::create("m_ioaiu<%=qidx%>_<%=i%>_seq");
    m_iocache_seq<%=qidx%>[<%=i%>].core_id = <%=i%>;
    m_iocache_seq<%=qidx%>[<%=i%>].set_seq_name("m_ioaiu<%=qidx%>_<%=i%>_seq");
    m_iocache_seq<%=qidx%>[<%=i%>].m_read_addr_chnl_seqr  = m_concerto_env.inhouse.m_ioaiu<%=qidx%>_env.m_env[<%=i%>].m_axi_master_agent.m_read_addr_chnl_seqr;
    m_iocache_seq<%=qidx%>[<%=i%>].m_read_data_chnl_seqr  = m_concerto_env.inhouse.m_ioaiu<%=qidx%>_env.m_env[<%=i%>].m_axi_master_agent.m_read_data_chnl_seqr;
    m_iocache_seq<%=qidx%>[<%=i%>].m_write_addr_chnl_seqr = m_concerto_env.inhouse.m_ioaiu<%=qidx%>_env.m_env[<%=i%>].m_axi_master_agent.m_write_addr_chnl_seqr;
    m_iocache_seq<%=qidx%>[<%=i%>].m_write_data_chnl_seqr = m_concerto_env.inhouse.m_ioaiu<%=qidx%>_env.m_env[<%=i%>].m_axi_master_agent.m_write_data_chnl_seqr;
    m_iocache_seq<%=qidx%>[<%=i%>].m_write_resp_chnl_seqr = m_concerto_env.inhouse.m_ioaiu<%=qidx%>_env.m_env[<%=i%>].m_axi_master_agent.m_write_resp_chnl_seqr;
    m_iocache_seq<%=qidx%>[<%=i%>].m_ace_cache_model      = m_concerto_env.inhouse.m_ace_cache_model_ioaiu<%=qidx%>[<%=i%>];
    m_iocache_seq<%=qidx%>[<%=i%>].k_directed_test        = k_directed_test;

    m_iocache_seq<%=qidx%>_2[<%=i%>]                        = ioaiu<%=qidx%>_inhouse_axi_bfm_pkg::axi_master_pipelined_seq::type_id::create("m_ioaiu<%=qidx%>_<%=i%>_seq2");
    m_iocache_seq<%=qidx%>_2[<%=i%>].core_id= <%=i%>;
    m_iocache_seq<%=qidx%>_2[<%=i%>].set_seq_name("m_ioaiu<%=qidx%>_<%=i%>_seq2");
    m_iocache_seq<%=qidx%>_2[<%=i%>].m_read_addr_chnl_seqr  = m_concerto_env.inhouse.m_ioaiu<%=qidx%>_env.m_env[<%=i%>].m_axi_master_agent.m_read_addr_chnl_seqr;
    m_iocache_seq<%=qidx%>_2[<%=i%>].m_read_data_chnl_seqr  = m_concerto_env.inhouse.m_ioaiu<%=qidx%>_env.m_env[<%=i%>].m_axi_master_agent.m_read_data_chnl_seqr;
    m_iocache_seq<%=qidx%>_2[<%=i%>].m_write_addr_chnl_seqr = m_concerto_env.inhouse.m_ioaiu<%=qidx%>_env.m_env[<%=i%>].m_axi_master_agent.m_write_addr_chnl_seqr;
    m_iocache_seq<%=qidx%>_2[<%=i%>].m_write_data_chnl_seqr = m_concerto_env.inhouse.m_ioaiu<%=qidx%>_env.m_env[<%=i%>].m_axi_master_agent.m_write_data_chnl_seqr;
    m_iocache_seq<%=qidx%>_2[<%=i%>].m_write_resp_chnl_seqr = m_concerto_env.inhouse.m_ioaiu<%=qidx%>_env.m_env[<%=i%>].m_axi_master_agent.m_write_resp_chnl_seqr;
    m_iocache_seq<%=qidx%>_2[<%=i%>].m_ace_cache_model      = m_concerto_env.inhouse.m_ace_cache_model_ioaiu<%=qidx%>[<%=i%>];
    m_iocache_seq<%=qidx%>_2[<%=i%>].k_directed_test        = k_directed_test;

    <% } //foreach Core%>
     <% if((obj.AiuInfo[pidx].fnNativeInterface == 'ACE') || (aiu_axiInt[pidx].params.eAc==1) ){ %>
    m_iosnoop_seq<%=qidx%>                        = ioaiu<%=qidx%>_inhouse_axi_bfm_pkg::axi_master_snoop_seq::type_id::create("m_iosnoop<%=qidx%>_seq");
    m_iosnoop_seq<%=qidx%>.m_read_addr_chnl_seqr   = m_concerto_env.inhouse.m_ioaiu<%=qidx%>_env.m_env[0].m_axi_master_agent.m_read_addr_chnl_seqr;
    m_iosnoop_seq<%=qidx%>.m_read_data_chnl_seqr   = m_concerto_env.inhouse.m_ioaiu<%=qidx%>_env.m_env[0].m_axi_master_agent.m_read_data_chnl_seqr;
    m_iosnoop_seq<%=qidx%>.m_snoop_addr_chnl_seqr  = m_concerto_env.inhouse.m_ioaiu<%=qidx%>_env.m_env[0].m_axi_master_agent.m_snoop_addr_chnl_seqr;
    m_iosnoop_seq<%=qidx%>.m_snoop_data_chnl_seqr  = m_concerto_env.inhouse.m_ioaiu<%=qidx%>_env.m_env[0].m_axi_master_agent.m_snoop_data_chnl_seqr;
    m_iosnoop_seq<%=qidx%>.m_snoop_resp_chnl_seqr  = m_concerto_env.inhouse.m_ioaiu<%=qidx%>_env.m_env[0].m_axi_master_agent.m_snoop_resp_chnl_seqr;
    m_iosnoop_seq<%=qidx%>.m_ace_cache_model       = m_concerto_env.inhouse.m_ace_cache_model_ioaiu<%=qidx%>[0];
      <%}%>
   <% qidx++; } %>
  <% } %>
   `endif //`ifndef USE_VIP_SNPS

  `ifdef USE_VIP_SNPS  // `ifdef USE_VIP_SNPS
   // //snps knob setting 
   // m_chi0_args = chi_aiu_unit_args_pkg::chi_aiu_unit_args::type_id::create("chi_aiu_unit_args0");
   // m_chi0_args.k_num_requests.set_value(chi_num_trans);
   // m_chi0_args.k_coh_addr_pct.set_value(50);
   // m_chi0_args.k_noncoh_addr_pct.set_value(50);
   // m_chi0_args.k_device_type_mem_pct.set_value(50);
   // m_chi0_args.k_rq_lcrdrt_pct.set_value(0);
   // m_chi0_args.k_rd_noncoh_pct.set_value(5);
   // m_chi0_args.k_rd_ldrstr_pct.set_value(5);
   // m_chi0_args.k_wr_noncoh_pct.set_value(5);
   // m_chi0_args.k_new_addr_pct.set_value(50);
   <% if(numChiAiu > 0) { %>
    m_svt_chi_item = svt_chi_item::type_id::create("m_svt_chi_item");
   <% } %>
    <% var qidx=0;var idx=0; for(var pidx = 0; pidx < obj.nAIUs; pidx++) { %>
    <% if((obj.AiuInfo[pidx].fnNativeInterface == 'CHI-A')||(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-B' || obj.AiuInfo[pidx].fnNativeInterface == 'CHI-E')) { %>
        //m_snps_chi<%=idx%>_vseq = chiaiu<%=idx%>_chi_aiu_vseq_pkg::snps_chi_aiu_vseq::type_id::create("m_chi<%=idx%>_seq");
        m_snps_chi<%=idx%>_vseq = chiaiu<%=idx%>_chi_aiu_vseq_pkg::snps_chi_aiu_vseq#(<%=obj.AiuInfo[pidx].FUnitId%>)::type_id::create("m_chi<%=idx%>_seq");
        //m_snps_chi<%=idx%>_vseq_2 = chiaiu<%=idx%>_chi_aiu_vseq_pkg::snps_chi_aiu_vseq#(<%=obj.AiuInfo[pidx].FUnitId%>)::type_id::create("m_chi<%=idx%>_read_seq"); // read

        m_snps_chi<%=idx%>_vseq.set_seq_name("m_chi<%=idx%>_seq");
        m_snps_chi<%=idx%>_vseq.set_done_event_name("done_svt_chi_rn_seq_h<%=idx%>");
        //m_snps_chi<%=idx%>_vseq_2.set_seq_name("m_chi<%=idx%>_read_seq"); // read

        m_snps_chi<%=idx%>_vseq.rn_xact_seqr    =  m_concerto_env.snps.svt.amba_system_env.chi_system[0].rn[<%=idx%>].rn_xact_seqr;  
        m_snps_chi<%=idx%>_vseq.shared_status =  m_concerto_env.snps.svt.amba_system_env.chi_system[0].rn[<%=idx%>].shared_status;  
        m_snps_chi<%=idx%>_vseq.chi_num_trans =  chi_num_trans;  
        m_snps_chi<%=idx%>_vseq.m_regs = m_concerto_env.m_regs;
        //m_snps_chi<%=idx%>_vseq.set_unit_args(m_chi0_args);

        //read
        //m_snps_chi<%=idx%>_vseq_2.rn_xact_seqr    =  m_concerto_env.snps.svt.amba_system_env.chi_system[0].rn[<%=idx%>].rn_xact_seqr; 

        <% idx++;  %>
   <%} else { %>

         <% qidx++; } %>

     
    <%} %>
 `endif // `ifdef USE_VIP_SNPS ... 

`ifndef USE_VIP_SNPS //this flow will not run while using SNPS
  <% var idx=0; for(var pidx = 0; pidx < obj.nAIUs; pidx++) { %>
    <% if((obj.AiuInfo[pidx].fnNativeInterface == 'CHI-A')||(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-B' || obj.AiuInfo[pidx].fnNativeInterface == 'CHI-E')) { %>
    m_chi<%=idx%>_args = chi_aiu_unit_args_pkg::chi_aiu_unit_args::type_id::create($psprintf("chi_aiu_unit_args[%0d]", 0));
    m_chi<%=idx%>_args.k_num_requests.set_value(chiaiu<%=idx%>_num_trans);
    m_chi<%=idx%>_args.k_coh_addr_pct.set_value(50);
    m_chi<%=idx%>_args.k_noncoh_addr_pct.set_value(50);
    m_chi<%=idx%>_args.k_device_type_mem_pct.set_value(50);
    m_chi<%=idx%>_args.k_rq_lcrdrt_pct.set_value(0);
    m_chi<%=idx%>_args.k_rd_noncoh_pct.set_value(5);
    if (!$test$plusargs("k_rd_ldrstr_pct") && !$test$plusargs("k_rd_rdonce_pct")) m_chi<%=idx%>_args.k_rd_ldrstr_pct.set_value(5);
	if (!$test$plusargs("k_rd_ldrstr_pct")) m_chi<%=idx%>_args.k_rd_ldrstr_pct.set_value(0);
	if (!$test$plusargs("k_rd_rdonce_pct"))  m_chi<%=idx%>_args.k_rd_rdonce_pct.set_value(0);
    if (!$test$plusargs("noncoherent_test") && !$test$plusargs("k_wr_noncoh_pct")) m_chi<%=idx%>_args.k_wr_noncoh_pct.set_value(5);
    m_chi<%=idx%>_args.k_new_addr_pct.set_value(50);
    m_chi<%=idx%>_vseq.set_unit_args(m_chi<%=idx%>_args);

    m_chi<%=idx%>_args2 = chi_aiu_unit_args_pkg::chi_aiu_unit_args::type_id::create($psprintf("chi_aiu_unit_args2[%0d]", 0));
    m_chi<%=idx%>_args2.k_num_requests.set_value(chiaiu<%=idx%>_num_trans2);
    m_chi<%=idx%>_args2.k_coh_addr_pct.set_value(50);
    m_chi<%=idx%>_args2.k_noncoh_addr_pct.set_value(50);
    m_chi<%=idx%>_args2.k_device_type_mem_pct.set_value(50);
    m_chi<%=idx%>_args2.k_rq_lcrdrt_pct.set_value(0);
    m_chi<%=idx%>_args2.k_rd_noncoh_pct.set_value(5);
    if (!$test$plusargs("k_rd_ldrstr_pct") && !$test$plusargs("k_rd_rdonce_pct")) m_chi<%=idx%>_args2.k_rd_ldrstr_pct.set_value(5);
	if (!$test$plusargs("k_rd_ldrstr_pct")) m_chi<%=idx%>_args2.k_rd_ldrstr_pct.set_value(0);
	if (!$test$plusargs("k_rd_rdonce_pct"))  m_chi<%=idx%>_args2.k_rd_rdonce_pct.set_value(0);
    if (!$test$plusargs("noncoherent_test") && !$test$plusargs("k_wr_noncoh_pct")) m_chi<%=idx%>_args2.k_wr_noncoh_pct.set_value(5);
    m_chi<%=idx%>_args2.k_new_addr_pct.set_value(50);
    m_chi<%=idx%>_vseq_2.set_unit_args(m_chi<%=idx%>_args2);
      <% idx++;  } %>
    <% } %>
`else //this flow will run while using SNPS
    <% var idx=0; for(var pidx = 0; pidx < obj.nAIUs; pidx++) { %>
    <% if((obj.AiuInfo[pidx].fnNativeInterface == 'CHI-A')||(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-B' || obj.AiuInfo[pidx].fnNativeInterface == 'CHI-E')) { %>
    m_chi0_args = chi_aiu_unit_args_pkg::chi_aiu_unit_args::type_id::create($psprintf("chi_aiu_unit_args[%0d]", 0));
    m_chi0_args.k_num_requests.set_value(chiaiu<%=idx%>_num_trans);
    m_chi0_args.k_coh_addr_pct.set_value(50);
    m_chi0_args.k_noncoh_addr_pct.set_value(50);
    m_chi0_args.k_device_type_mem_pct.set_value(50);
    m_chi0_args.k_rq_lcrdrt_pct.set_value(0);
    m_chi0_args.k_rd_noncoh_pct.set_value(5);
    if (!$test$plusargs("k_rd_ldrstr_pct") && !$test$plusargs("k_rd_rdonce_pct")) m_chi0_args.k_rd_ldrstr_pct.set_value(5);
	if (!$test$plusargs("k_rd_ldrstr_pct")) m_chi0_args.k_rd_ldrstr_pct.set_value(0);
	if (!$test$plusargs("k_rd_rdonce_pct"))  m_chi0_args.k_rd_rdonce_pct.set_value(0);
    if (!$test$plusargs("noncoherent_test") && !$test$plusargs("k_wr_noncoh_pct")) m_chi0_args.k_wr_noncoh_pct.set_value(5);
    m_chi0_args.k_new_addr_pct.set_value(50);
    m_svt_chi_item.m_args = m_chi0_args;
    m_snps_chi<%=idx%>_vseq.set_unit_args(m_chi0_args);
    
    <% idx++;  } %>
    <% } %>
`endif // `else part of SNPS




    phase.raise_objection(this, "bringup_test");

    #100ns;
   
    fork
  <% for(var pidx = 0; pidx < obj.nDMIs; pidx++) { %>
        m_axi_slv_rd_seq_dmi<%=pidx%>.start(null);
        m_axi_slv_wr_seq_dmi<%=pidx%>.start(null);
  <% } %>
  <% for(var pidx = 0; pidx < obj.nDIIs; pidx++) { %>
    <% if(obj.DiiInfo[pidx].configuration == 0) { %>
        m_axi_slv_rd_seq_dii<%=pidx%>.start(null);
        m_axi_slv_wr_seq_dii<%=pidx%>.start(null);
    <% } %>
  <% } %>
    join_none

    fork
  <% var idx = 0; %>
  <% for(pidx = 0; pidx < obj.nAIUs; pidx++) { %>
    <%if((obj.AiuInfo[pidx].fnNativeInterface == 'CHI-A')||(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-B' || obj.AiuInfo[pidx].fnNativeInterface == 'CHI-E')) { %>
    begin
      `ifdef USE_VIP_SNPS //SVT LINK
        `uvm_info(get_name(), "USE_VIP_SNPS svt_chi_link_UP_service_sequence::START[<%=idx%>]", UVM_LOW)
         svt_chi_link_up_seq_h<%=idx%>.start(m_concerto_env.snps.svt.amba_system_env.chi_system[0].rn[<%=idx%>].link_svc_seqr) ;
        `uvm_info(get_name(), "USE_VIP_SNPS svt_chi_link_UP_service_sequence::END[<%=idx%>]", UVM_LOW)
      `else //`ifdef USE_VIP_SNPS
        m_chi<%=idx%>_vseq.construct_lnk_seq();
        m_chi<%=idx%>_vseq.construct_txs_seq();
      `endif //`ifdef USE_VIP_SNPS ... `else
    end
    <% idx++; %>
    <%} %>
  <% } %>
    join
   
        `uvm_info("TEST_MAIN", "Start exec_inhouse_boot_seq", UVM_NONE)
        exec_inhouse_boot_seq(phase);

        // trigger csr_init_done to unit scoreboards
        csr_init_done.trigger(null);
      #100ns;
    fork
  <% var idx = 0; %>
  <% for(pidx = 0; pidx < obj.nAIUs; pidx++) { %>
    <%if((obj.AiuInfo[pidx].fnNativeInterface == 'CHI-A')||(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-B' || obj.AiuInfo[pidx].fnNativeInterface == 'CHI-E')) { %>
    begin
      `ifndef USE_VIP_SNPS //SVT LINK
        if(!$test$plusargs("sysco_disable")) begin
	  m_chi<%=idx%>_vseq.construct_sysco_seq(chiaiu<%=idx%>_chi_agent_pkg::CONNECT);
        end
      `endif
    end
    <% idx++; %>
    <%} %>
  <% } %>
    join

        #100ns;

             
  <% var idx = 0; %>
  <% for(pidx = 0; pidx < obj.nAIUs; pidx++) { %>
    <%if((obj.AiuInfo[pidx].fnNativeInterface != 'CHI-A')&&(obj.AiuInfo[pidx].fnNativeInterface != 'CHI-B' && obj.AiuInfo[pidx].fnNativeInterface != 'CHI-E')) { %>
      if($value$plusargs("ioaiu<%=idx%>_axi_master_delay=%d", axi_master_delay[<%=idx%>])) begin
    <% for(var i=0; i<aiu_NumCores[pidx]; i++) { %>
      m_concerto_env.inhouse.m_ioaiu<%=idx%>_env.m_env[<%=i%>].m_axi_master_agent.m_cfg.m_vif.ACE_MASTER_READ_ADDR_CHANNEL_BURST_PCT = 0;
      m_concerto_env.inhouse.m_ioaiu<%=idx%>_env.m_env[<%=i%>].m_axi_master_agent.m_cfg.m_vif.ACE_MASTER_READ_ADDR_CHANNEL_DELAY_MIN = axi_master_delay[<%=idx%>];
      m_concerto_env.inhouse.m_ioaiu<%=idx%>_env.m_env[<%=i%>].m_axi_master_agent.m_cfg.m_vif.ACE_MASTER_READ_ADDR_CHANNEL_DELAY_MAX = axi_master_delay[<%=idx%>];
      m_concerto_env.inhouse.m_ioaiu<%=idx%>_env.m_env[<%=i%>].m_axi_master_agent.m_cfg.m_vif.ACE_MASTER_WRITE_ADDR_CHANNEL_BURST_PCT = 0;
      m_concerto_env.inhouse.m_ioaiu<%=idx%>_env.m_env[<%=i%>].m_axi_master_agent.m_cfg.m_vif.ACE_MASTER_WRITE_ADDR_CHANNEL_DELAY_MIN = axi_master_delay[<%=idx%>];
      m_concerto_env.inhouse.m_ioaiu<%=idx%>_env.m_env[<%=i%>].m_axi_master_agent.m_cfg.m_vif.ACE_MASTER_WRITE_ADDR_CHANNEL_DELAY_MAX = axi_master_delay[<%=idx%>];
	  <%} // foreach core%>
      end
    <% idx++; } %>
  <% } %>

        if($test$plusargs("ioaiu_control_cfg")) begin
           set_ioaiu_control_cfg();
        end

        if($test$plusargs("exec_snoop_seq")) begin
	   exec_snoop_seq(phase);
	end
	    
        if($value$plusargs("use_user_addrq=%d", use_user_addrq)) begin
         `ifndef USE_VIP_SNPS
           gen_user_addrq();
         `endif
	end // if ($value$plusargs("use_user_addrq=%d", use_user_addrq))
			 
            // set randomize args after boot seq
`ifndef USE_VIP_SNPS //existing flow will not run when USE_VIP_SNPS set            
  <% var qidx=0;var idx=0; for(var pidx = 0; pidx < obj.nAIUs; pidx++) { %>
    <% if((obj.AiuInfo[pidx].fnNativeInterface == 'CHI-A')||(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-B' || obj.AiuInfo[pidx].fnNativeInterface == 'CHI-E')) { %>
            m_chi<%=idx%>_args.k_num_requests.set_value(chiaiu<%=idx%>_num_trans);
            m_chi<%=idx%>_args.k_device_type_mem_pct.set_value(0);
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
               if (!$test$plusargs("k_rd_noncoh_pct")) m_chi<%=idx%>_args.k_rd_noncoh_pct.set_value(chiaiu<%=idx%>_read_ratio);
               if (!$test$plusargs("k_wr_noncoh_pct")) m_chi<%=idx%>_args.k_wr_noncoh_pct.set_value(chiaiu<%=idx%>_write_ratio);
               if ($test$plusargs("read_test")|| $test$plusargs("chi<%=idx%>_read_test")) begin
                  m_chi<%=idx%>_args.k_wr_noncoh_pct.set_value(0);
               end
               if ($test$plusargs("write_test")||$test$plusargs("chi<%=idx%>_write_test")) begin
                  m_chi<%=idx%>_args.k_wr_noncoh_pct.set_value(100);
                  m_chi<%=idx%>_args.k_rd_noncoh_pct.set_value(0);
	       end // else: !if($test$plusargs("write_test"))
	    end	
	    else begin
               m_chi<%=idx%>_args.k_coh_addr_pct.set_value(100);
               m_chi<%=idx%>_args.k_noncoh_addr_pct.set_value(0);
               if (!$test$plusargs("k_rd_ldrstr_pct") && !$test$plusargs("k_rd_rdonce_pct")) m_chi<%=idx%>_args.k_rd_ldrstr_pct.set_value(chiaiu<%=idx%>_read_ratio);
               if (!$test$plusargs("k_wr_cohunq_pct")) m_chi<%=idx%>_args.k_wr_cohunq_pct.set_value(chiaiu<%=idx%>_write_ratio);
               if ($test$plusargs("read_test")|| $test$plusargs("chi<%=idx%>_read_test")) begin
                  m_chi<%=idx%>_args.k_wr_cohunq_pct.set_value(0);
               end
               if ($test$plusargs("write_test")||$test$plusargs("chi<%=idx%>_write_test")) begin
                  m_chi<%=idx%>_args.k_wr_cohunq_pct.set_value(100);
                  m_chi<%=idx%>_args.k_rd_ldrstr_pct.set_value(0);
         	  m_chi<%=idx%>_args.k_rd_rdonce_pct.set_value(0);
	          end // else: !if($test$plusargs("write_test"))
		   // case to force rd_once on specific CHI to be allow 1 CHI read
		   // unique & another read once to measure the snoop BW 
		if ($test$plusargs("force_chi<%=idx%>_rdonce")) begin 
                   m_chi<%=idx%>_args.k_rd_ldrstr_pct.set_value(0);
         	   m_chi<%=idx%>_args.k_rd_rdonce_pct.set_value(100);
		end
		if ($test$plusargs("chi_stashnid")) begin
                   m_chi<%=idx%>_args.k_dt_ls_sth_pct.set_value(100);
		   m_chi<%=idx%>_args.k_rd_ldrstr_pct.set_value(0);
         	   m_chi<%=idx%>_args.k_rd_rdonce_pct.set_value(0);
		end
	    end

           if(!$value$plusargs("chi_txreq_delay=%d", chi_txreq_dly)) begin
		chi_txreq_dly = 0;
           end
	   if(!chiaiu_slow_master.exists(<%=idx%>)) begin
               `uvm_info("TEST_MAIN", "CHAIU<%=idx%> fast master", UVM_MEDIUM)
               m_chi<%=idx%>_args.k_txreq_hld_dly.set_value(1);
               m_chi<%=idx%>_args.k_txreq_dly_min.set_value(chi_txreq_dly);
               m_chi<%=idx%>_args.k_txreq_dly_max.set_value(chi_txreq_dly);
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
            else begin
               `uvm_info("TEST_MAIN", "CHAIU<%=idx%> slow master", UVM_MEDIUM)
               m_chi<%=idx%>_args.k_txreq_dly_min.set_value(500);
               m_chi<%=idx%>_args.k_txreq_dly_max.set_value(5000);
            end
            m_chi<%=idx%>_vseq.set_unit_args(m_chi<%=idx%>_args);

	    m_chi<%=idx%>_vseq.user_qos = 1;
	    m_chi<%=idx%>_vseq.aiu_qos  = chiaiu_qos[<%=idx%>];

            m_chi<%=idx%>_args2.k_num_requests.set_value(chiaiu<%=idx%>_num_trans2);
            m_chi<%=idx%>_args2.k_device_type_mem_pct.set_value(0);
            m_chi<%=idx%>_args2.k_wr_cpybck_pct.set_value(0);
            m_chi<%=idx%>_args2.k_dt_ls_upd_pct.set_value(0);
            m_chi<%=idx%>_args2.k_dt_ls_cmo_pct.set_value(0);
            m_chi<%=idx%>_args2.k_pre_fetch_pct.set_value(0);
            m_chi<%=idx%>_args2.k_dt_ls_sth_pct.set_value(0);
            m_chi<%=idx%>_args2.k_wr_sthunq_pct.set_value(0);
            m_chi<%=idx%>_args2.k_atomic_st_pct.set_value(0);
            m_chi<%=idx%>_args2.k_atomic_ld_pct.set_value(0);
            m_chi<%=idx%>_args2.k_atomic_sw_pct.set_value(0);
            m_chi<%=idx%>_args2.k_atomic_cm_pct.set_value(0);
            m_chi<%=idx%>_args2.k_dvm_opert_pct.set_value(0);
            if($test$plusargs("noncoherent_test")) begin
               m_chi<%=idx%>_args2.k_coh_addr_pct.set_value(0);
               m_chi<%=idx%>_args2.k_noncoh_addr_pct.set_value(100);
               if (!$test$plusargs("k_rd_noncoh_pct")) m_chi<%=idx%>_args2.k_rd_noncoh_pct.set_value(chiaiu<%=idx%>_read_ratio2);
               if (!$test$plusargs("k_wr_noncoh_pct")) m_chi<%=idx%>_args2.k_wr_noncoh_pct.set_value(chiaiu<%=idx%>_write_ratio2);
               if ($test$plusargs("read_test")|| $test$plusargs("chi<%=idx%>_read_test")) begin
                  m_chi<%=idx%>_args2.k_wr_noncoh_pct.set_value(0);
               end
               if ($test$plusargs("write_test")||$test$plusargs("chi<%=idx%>_write_test")) begin
                  m_chi<%=idx%>_args2.k_wr_noncoh_pct.set_value(100);
                  m_chi<%=idx%>_args2.k_rd_noncoh_pct.set_value(0);
	       end // else: !if($test$plusargs("write_test"))
	    end	
	    else begin
               m_chi<%=idx%>_args2.k_coh_addr_pct.set_value(100);
               m_chi<%=idx%>_args2.k_noncoh_addr_pct.set_value(0);
               if (!$test$plusargs("k_rd_ldrstr_pct") && !$test$plusargs("k_rd_rdonce_pct")) m_chi<%=idx%>_args2.k_rd_ldrstr_pct.set_value(chiaiu<%=idx%>_read_ratio2);
               if (!$test$plusargs("k_wr_cohunq_pct")) m_chi<%=idx%>_args2.k_wr_cohunq_pct.set_value(chiaiu<%=idx%>_write_ratio2);
               if ($test$plusargs("read_test")|| $test$plusargs("chi<%=idx%>_read_test")) begin
                  m_chi<%=idx%>_args2.k_wr_cohunq_pct.set_value(0);
               end
               if ($test$plusargs("write_test")||$test$plusargs("chi<%=idx%>_write_test")) begin
                  m_chi<%=idx%>_args2.k_wr_cohunq_pct.set_value(100);
                  m_chi<%=idx%>_args2.k_rd_ldrstr_pct.set_value(0);
         	  m_chi<%=idx%>_args2.k_rd_rdonce_pct.set_value(0);
	          end // else: !if($test$plusargs("write_test"))
		   // case to force rd_once on specific CHI to be allow 1 CHI read
		   // unique & another read once to measure the snoop BW 
		if ($test$plusargs("force_chi<%=idx%>_rdonce")) begin 
                   m_chi<%=idx%>_args2.k_rd_ldrstr_pct.set_value(0);
         	   m_chi<%=idx%>_args2.k_rd_rdonce_pct.set_value(100);
		end
		if ($test$plusargs("chi_stashnid")) begin
                   m_chi<%=idx%>_args2.k_dt_ls_sth_pct.set_value(100);
		   m_chi<%=idx%>_args2.k_rd_ldrstr_pct.set_value(0);
         	   m_chi<%=idx%>_args2.k_rd_rdonce_pct.set_value(0);
		end
	    end

           if(!$value$plusargs("chi_txreq_delay2=%d", chi_txreq_dly2)) begin
		chi_txreq_dly2 = 0;
           end
	   if(!chiaiu_slow_master.exists(<%=idx%>)) begin
               `uvm_info("TEST_MAIN", "CHAIU<%=idx%> fast master", UVM_MEDIUM)
               m_chi<%=idx%>_args2.k_txreq_hld_dly.set_value(1);
               m_chi<%=idx%>_args2.k_txreq_dly_min.set_value(chi_txreq_dly2);
               m_chi<%=idx%>_args2.k_txreq_dly_max.set_value(chi_txreq_dly2);
               m_chi<%=idx%>_args2.k_txrsp_hld_dly.set_value(1);
               m_chi<%=idx%>_args2.k_txrsp_dly_min.set_value(0);
               m_chi<%=idx%>_args2.k_txrsp_dly_max.set_value(0);
               m_chi<%=idx%>_args2.k_txdat_hld_dly.set_value(1);
               m_chi<%=idx%>_args2.k_txdat_dly_min.set_value(0);
               m_chi<%=idx%>_args2.k_txdat_dly_max.set_value(0);
               m_chi<%=idx%>_args2.k_alloc_hint_pct.set_value(90);
               m_chi<%=idx%>_args2.k_cacheable_pct.set_value(90);
	       m_chi<%=idx%>_args2.k_on_fly_req.set_value(32);
	    end
            else begin
               `uvm_info("TEST_MAIN", "CHAIU<%=idx%> slow master", UVM_MEDIUM)
               m_chi<%=idx%>_args2.k_txreq_dly_min.set_value(500);
               m_chi<%=idx%>_args2.k_txreq_dly_max.set_value(5000);
            end
            m_chi<%=idx%>_vseq_2.set_unit_args(m_chi<%=idx%>_args2);

	    m_chi<%=idx%>_vseq_2.user_qos = 1;
	    m_chi<%=idx%>_vseq_2.aiu_qos  = chiaiu_qos2[<%=idx%>];
      <% idx++;  %>
    <%} else { %>
    <% for(var coreidx=0; coreidx<aiu_NumCores[pidx]; coreidx++) { %>
	if ($value$plusargs("ioaiu<%=qidx%>_force_axid=%d",  ioaiu_force_axid)) begin
	    m_iocache_seq<%=qidx%>[<%=coreidx%>].en_force_axid=1;
	    m_iocache_seq<%=qidx%>[<%=coreidx%>].ioaiu_force_noncoh_axid[0]=ioaiu_force_axid;
	    m_iocache_seq<%=qidx%>[<%=coreidx%>].ioaiu_force_noncoh_axid[1]=ioaiu_force_axid;
	    m_iocache_seq<%=qidx%>[<%=coreidx%>].ioaiu_force_coh_axid=ioaiu_force_axid;
	end
	if ($value$plusargs("ioaiu<%=qidx%>_force_coh_axid=%d",  ioaiu_force_axid)) begin
	    m_iocache_seq<%=qidx%>[<%=coreidx%>].en_force_axid=1;
	    m_iocache_seq<%=qidx%>[<%=coreidx%>].ioaiu_force_coh_axid=ioaiu_force_axid;
	end
        if ($value$plusargs("ioaiu<%=qidx%>_force_noncoh_axid=%s",force_axid_arg)) begin:ioaiu<%=qidx%>_force_noncoh_axid_<%=coreidx%>// 2 values: "<nbr tx noncoh mem region N>n<nbr tx noncoh mem region N+1>"
	    m_iocache_seq<%=qidx%>[<%=coreidx%>].en_force_axid=1;
	    parse_str(force_axid_str, "n", force_axid_arg);
	    foreach (force_axid_str[i]) 
                m_iocache_seq<%=qidx%>[<%=coreidx%>].ioaiu_force_noncoh_axid[i] = force_axid_str[i].atoi();
	    if (force_axid_str.size()==1) m_iocache_seq<%=qidx%>[<%=coreidx%>].ioaiu_force_noncoh_axid[1] = m_iocache_seq<%=qidx%>[<%=coreidx%>].ioaiu_force_noncoh_axid[0];	   
        end:ioaiu<%=qidx%>_force_noncoh_axid_<%=coreidx%>

      m_iocache_seq<%=qidx%>[<%=coreidx%>].k_num_read_req      = int'(real'(ioaiu<%=qidx%>_num_trans) * real'(real'(ioaiu<%=qidx%>_read_ratio)/100.00));
      m_iocache_seq<%=qidx%>[<%=coreidx%>].k_num_write_req     = int'(real'(ioaiu<%=qidx%>_num_trans) * real'(real'(ioaiu<%=qidx%>_write_ratio)/100.00));
      m_iocache_seq<%=qidx%>[<%=coreidx%>].duty_cycle          = k_duty_cycle_ioaiu[<%=qidx%>]; 
		 
      m_iocache_seq<%=qidx%>_2[<%=coreidx%>].k_num_read_req      = int'(real'(ioaiu<%=qidx%>_num_trans2) * real'(real'(ioaiu<%=qidx%>_read_ratio2)/100.00));
      m_iocache_seq<%=qidx%>_2[<%=coreidx%>].k_num_write_req     = int'(real'(ioaiu<%=qidx%>_num_trans2) * real'(real'(ioaiu<%=qidx%>_write_ratio2)/100.00));
      m_iocache_seq<%=qidx%>_2[<%=coreidx%>].duty_cycle          = k_duty_cycle_ioaiu[<%=qidx%>]; 

      if ($test$plusargs("read_test") || $test$plusargs("ioaiu<%=qidx%>_read_test")) begin
          m_iocache_seq<%=qidx%>[<%=coreidx%>].k_num_read_req      = ioaiu<%=qidx%>_num_trans;
          m_iocache_seq<%=qidx%>[<%=coreidx%>].k_num_write_req      = 0;
          m_iocache_seq<%=qidx%>_2[<%=coreidx%>].k_num_read_req      = ioaiu<%=qidx%>_num_trans2;
          m_iocache_seq<%=qidx%>_2[<%=coreidx%>].k_num_write_req      = 0;
      end
      if ($test$plusargs("write_test") ||$test$plusargs("ioaiu<%=qidx%>_write_test")) begin
          m_iocache_seq<%=qidx%>[<%=coreidx%>].k_num_write_req     = ioaiu<%=qidx%>_num_trans;
          m_iocache_seq<%=qidx%>[<%=coreidx%>].k_num_read_req      = 0;
          m_iocache_seq<%=qidx%>_2[<%=coreidx%>].k_num_write_req     = ioaiu<%=qidx%>_num_trans2;
          m_iocache_seq<%=qidx%>_2[<%=coreidx%>].k_num_read_req      = 0;
      end

      `uvm_info("TEST_MAIN", $sformatf("IOAIU<%=qidx%>_SEQ k_num_read_req=%0d, k_num_write_req=%0d", m_iocache_seq<%=qidx%>[<%=coreidx%>].k_num_read_req, m_iocache_seq<%=qidx%>[<%=coreidx%>].k_num_write_req), UVM_NONE)
      if($test$plusargs("run_seq2"))
         `uvm_info("TEST_MAIN", $sformatf("IOAIU<%=qidx%>_SEQ2 k_num_read_req=%0d, k_num_write_req=%0d", m_iocache_seq<%=qidx%>_2[<%=coreidx%>].k_num_read_req, m_iocache_seq<%=qidx%>_2[<%=coreidx%>].k_num_write_req), UVM_NONE)
	       
      m_iocache_seq<%=qidx%>[<%=coreidx%>].perf_coh_txn_size = perf_coh_txn_size;
      m_iocache_seq<%=qidx%>[<%=coreidx%>].perf_noncoh_txn_size = perf_noncoh_txn_size;
      m_iocache_seq<%=qidx%>_2[<%=coreidx%>].perf_coh_txn_size = perf_coh_txn_size;
      m_iocache_seq<%=qidx%>_2[<%=coreidx%>].perf_noncoh_txn_size = perf_noncoh_txn_size;
      if (!$test$plusargs("wt_ace_rdnosnp")) m_iocache_seq<%=qidx%>[<%=coreidx%>].wt_ace_rdnosnp      = 0;
      if (!$test$plusargs("wt_ace_rdonce") ) m_iocache_seq<%=qidx%>[<%=coreidx%>].wt_ace_rdonce       = 0;
      if (!$test$plusargs("wt_ace_wrnosnp")) m_iocache_seq<%=qidx%>[<%=coreidx%>].wt_ace_wrnosnp      = 0;
      if (!$test$plusargs("wt_ace_wrunq")  ) m_iocache_seq<%=qidx%>[<%=coreidx%>].wt_ace_wrunq        = 0;
      if (!$test$plusargs("wt_ace_rdnosnp")) m_iocache_seq<%=qidx%>_2[<%=coreidx%>].wt_ace_rdnosnp     = 0;
      if (!$test$plusargs("wt_ace_rdonce") ) m_iocache_seq<%=qidx%>_2[<%=coreidx%>].wt_ace_rdonce      = 0;
      if (!$test$plusargs("wt_ace_wrnosnp")) m_iocache_seq<%=qidx%>_2[<%=coreidx%>].wt_ace_wrnosnp     = 0;
      if (!$test$plusargs("wt_ace_wrunq")  ) m_iocache_seq<%=qidx%>_2[<%=coreidx%>].wt_ace_wrunq       = 0;
      <% if((obj.AiuInfo[pidx].fnNativeInterface == 'ACE') || (obj.AiuInfo[pidx].fnNativeInterface == 'ACE-LITE') || (obj.AiuInfo[pidx].fnNativeInterface == 'ACELITE-E')) { %>
            m_iocache_seq<%=qidx%>[<%=coreidx%>].wt_ace_rdunq        = 0;
            m_iocache_seq<%=qidx%>[<%=coreidx%>].wt_ace_rdshrd       = 0;
            m_iocache_seq<%=qidx%>[<%=coreidx%>].wt_ace_rdcln        = 0;
            m_iocache_seq<%=qidx%>[<%=coreidx%>].wt_ace_rdnotshrddty = 0;
            m_iocache_seq<%=qidx%>[<%=coreidx%>].wt_ace_wrlnunq      = 0;
            m_iocache_seq<%=qidx%>[<%=coreidx%>].wt_ace_wrbk         = 0;
            m_iocache_seq<%=qidx%>[<%=coreidx%>].wt_ace_wrevct       = 0;
            m_iocache_seq<%=qidx%>[<%=coreidx%>].wt_ace_clnunq       = 0;
            m_iocache_seq<%=qidx%>[<%=coreidx%>].wt_ace_clnshrd      = 0;
            m_iocache_seq<%=qidx%>[<%=coreidx%>].wt_ace_clninvl      = 0;
            m_iocache_seq<%=qidx%>[<%=coreidx%>].wt_ace_mkunq        = 0;
            m_iocache_seq<%=qidx%>[<%=coreidx%>].wt_ace_mkinvl       = 0;
            m_iocache_seq<%=qidx%>[<%=coreidx%>].wt_ace_evct         = 0;
            m_iocache_seq<%=qidx%>[<%=coreidx%>].no_updates          = 0;
            m_iocache_seq<%=qidx%>[<%=coreidx%>].wt_ace_ptl_stash    = 0;
            m_iocache_seq<%=qidx%>[<%=coreidx%>].wt_ace_full_stash   = 0;
            m_iocache_seq<%=qidx%>[<%=coreidx%>].wt_ace_shared_stash = 0;
            m_iocache_seq<%=qidx%>[<%=coreidx%>].wt_ace_unq_stash    = 0;
            m_iocache_seq<%=qidx%>[<%=coreidx%>].wt_ace_stash_trans  = 0;
            m_iocache_seq<%=qidx%>[<%=coreidx%>].wt_ace_atm_str      = 0;
            m_iocache_seq<%=qidx%>[<%=coreidx%>].wt_ace_atm_ld       = 0;
            m_iocache_seq<%=qidx%>[<%=coreidx%>].wt_ace_atm_swap     = 0;
            m_iocache_seq<%=qidx%>[<%=coreidx%>].wt_ace_atm_comp     = 0;
            m_iocache_seq<%=qidx%>[<%=coreidx%>].wt_ace_dvm_sync     = 0;
            m_iocache_seq<%=qidx%>[<%=coreidx%>].wt_ace_dvm_msg      = 0;
            m_iocache_seq<%=qidx%>[<%=coreidx%>].wt_ace_rd_bar       = 0;
            m_iocache_seq<%=qidx%>[<%=coreidx%>].wt_ace_wr_bar       = 0;

            m_iocache_seq<%=qidx%>_2[<%=coreidx%>].wt_ace_rdunq        = 0;
            m_iocache_seq<%=qidx%>_2[<%=coreidx%>].wt_ace_rdshrd       = 0;
            m_iocache_seq<%=qidx%>_2[<%=coreidx%>].wt_ace_rdcln        = 0;
            m_iocache_seq<%=qidx%>_2[<%=coreidx%>].wt_ace_rdnotshrddty = 0;
            m_iocache_seq<%=qidx%>_2[<%=coreidx%>].wt_ace_wrlnunq      = 0;
            m_iocache_seq<%=qidx%>_2[<%=coreidx%>].wt_ace_wrbk         = 0;
            m_iocache_seq<%=qidx%>_2[<%=coreidx%>].wt_ace_wrevct       = 0;
            m_iocache_seq<%=qidx%>_2[<%=coreidx%>].wt_ace_clnunq       = 0;
            m_iocache_seq<%=qidx%>_2[<%=coreidx%>].wt_ace_clnshrd      = 0;
            m_iocache_seq<%=qidx%>_2[<%=coreidx%>].wt_ace_clninvl      = 0;
            m_iocache_seq<%=qidx%>_2[<%=coreidx%>].wt_ace_mkunq        = 0;
            m_iocache_seq<%=qidx%>_2[<%=coreidx%>].wt_ace_mkinvl       = 0;
            m_iocache_seq<%=qidx%>_2[<%=coreidx%>].wt_ace_evct         = 0;
            m_iocache_seq<%=qidx%>_2[<%=coreidx%>].no_updates          = 0;
            m_iocache_seq<%=qidx%>_2[<%=coreidx%>].wt_ace_ptl_stash    = 0;
            m_iocache_seq<%=qidx%>_2[<%=coreidx%>].wt_ace_full_stash   = 0;
            m_iocache_seq<%=qidx%>_2[<%=coreidx%>].wt_ace_shared_stash = 0;
            m_iocache_seq<%=qidx%>_2[<%=coreidx%>].wt_ace_unq_stash    = 0;
            m_iocache_seq<%=qidx%>_2[<%=coreidx%>].wt_ace_stash_trans  = 0;
            m_iocache_seq<%=qidx%>_2[<%=coreidx%>].wt_ace_atm_str      = 0;
            m_iocache_seq<%=qidx%>_2[<%=coreidx%>].wt_ace_atm_ld       = 0;
            m_iocache_seq<%=qidx%>_2[<%=coreidx%>].wt_ace_atm_swap     = 0;
            m_iocache_seq<%=qidx%>_2[<%=coreidx%>].wt_ace_atm_comp     = 0;
            m_iocache_seq<%=qidx%>_2[<%=coreidx%>].wt_ace_dvm_sync     = 0;
            m_iocache_seq<%=qidx%>_2[<%=coreidx%>].wt_ace_dvm_msg      = 0;
            m_iocache_seq<%=qidx%>_2[<%=coreidx%>].wt_ace_rd_bar       = 0;
            m_iocache_seq<%=qidx%>_2[<%=coreidx%>].wt_ace_wr_bar       = 0;
		<%}%>
      if ($value$plusargs("ioaiu<%=qidx%>_alternate_test=%s",alternate_arg)) begin:ioaiu<%=qidx%>_alternate_coh_noncoh_<%=coreidx%> // 2 values: "<nbr tx coh>n<nbr tx noncoh>"
         parse_str(alternate_str, "n", alternate_arg);
         foreach ( alternate_str[i]) 
	    m_iocache_seq<%=qidx%>[<%=coreidx%>].nbr_alt_coh_noncoh_tx[i] = alternate_str[i].atoi();
	 //Weight coh or noncoh opcode 
	 if (!$value$plusargs("wt_ace_rdnosnp=%d", m_iocache_seq<%=qidx%>[<%=coreidx%>].wt_ace_rdnosnp)) m_iocache_seq<%=qidx%>[<%=coreidx%>].wt_ace_rdnosnp   = 25;
         if (!$value$plusargs("wt_ace_wrnosnp=%d", m_iocache_seq<%=qidx%>[<%=coreidx%>].wt_ace_wrnosnp)) m_iocache_seq<%=qidx%>[<%=coreidx%>].wt_ace_wrnosnp   = 25;
         if (!$value$plusargs("wt_ace_rdonce=%d", m_iocache_seq<%=qidx%>[<%=coreidx%>].wt_ace_rdonce)) m_iocache_seq<%=qidx%>[<%=coreidx%>].wt_ace_rdonce      = 25;
         if (!$value$plusargs("wt_ace_wrunq=%d", m_iocache_seq<%=qidx%>[<%=coreidx%>].wt_ace_wrunq))  m_iocache_seq<%=qidx%>[<%=coreidx%>].wt_ace_wrunq        = 25;
         if ($test$plusargs("read_test") || $test$plusargs("ioaiu<%=qidx%>_read_test")) begin
             m_iocache_seq<%=qidx%>[<%=coreidx%>].wt_ace_rdonce      = 50;
             m_iocache_seq<%=qidx%>[<%=coreidx%>].wt_ace_wrunq       = 0;
             m_iocache_seq<%=qidx%>[<%=coreidx%>].wt_ace_rdnosnp     = 50;
             m_iocache_seq<%=qidx%>[<%=coreidx%>].wt_ace_wrnosnp     = 0;
         end 
         if ($test$plusargs("write_test") || $test$plusargs("ioaiu<%=qidx%>_write_test")) begin
            m_iocache_seq<%=qidx%>[<%=coreidx%>].wt_ace_rdnosnp     = 0;
            m_iocache_seq<%=qidx%>[<%=coreidx%>].wt_ace_wrnosnp     = 50;
            m_iocache_seq<%=qidx%>[<%=coreidx%>].wt_ace_rdonce      = 0;
            m_iocache_seq<%=qidx%>[<%=coreidx%>].wt_ace_wrunq       = 50;
	 end	   
	 if (!$value$plusargs("wt_ace_rdnosnp=%d", m_iocache_seq<%=qidx%>_2[<%=coreidx%>].wt_ace_rdnosnp)) m_iocache_seq<%=qidx%>_2[<%=coreidx%>].wt_ace_rdnosnp   = 25;
         if (!$value$plusargs("wt_ace_wrnosnp=%d", m_iocache_seq<%=qidx%>_2[<%=coreidx%>].wt_ace_wrnosnp)) m_iocache_seq<%=qidx%>_2[<%=coreidx%>].wt_ace_wrnosnp   = 25;
         if (!$value$plusargs("wt_ace_rdonce=%d", m_iocache_seq<%=qidx%>_2[<%=coreidx%>].wt_ace_rdonce)) m_iocache_seq<%=qidx%>_2[<%=coreidx%>].wt_ace_rdonce      = 25;
         if (!$value$plusargs("wt_ace_wrunq=%d", m_iocache_seq<%=qidx%>_2[<%=coreidx%>].wt_ace_wrunq))  m_iocache_seq<%=qidx%>_2[<%=coreidx%>].wt_ace_wrunq        = 25;
         if ($test$plusargs("read_test") || $test$plusargs("ioaiu<%=qidx%>_read_test")) begin
             m_iocache_seq<%=qidx%>_2[<%=coreidx%>].wt_ace_rdonce      = 50;
             m_iocache_seq<%=qidx%>_2[<%=coreidx%>].wt_ace_wrunq       = 0;
             m_iocache_seq<%=qidx%>_2[<%=coreidx%>].wt_ace_rdnosnp     = 50;
             m_iocache_seq<%=qidx%>_2[<%=coreidx%>].wt_ace_wrnosnp     = 0;
         end 
         if ($test$plusargs("write_test") || $test$plusargs("ioaiu<%=qidx%>_write_test")) begin
            m_iocache_seq<%=qidx%>_2[<%=coreidx%>].wt_ace_rdnosnp     = 0;
            m_iocache_seq<%=qidx%>_2[<%=coreidx%>].wt_ace_wrnosnp     = 50;
            m_iocache_seq<%=qidx%>_2[<%=coreidx%>].wt_ace_rdonce      = 0;
            m_iocache_seq<%=qidx%>_2[<%=coreidx%>].wt_ace_wrunq       = 50;
	 end	   
         if($test$plusargs("k_duty_cycle_ioaiu<%=qidx%>")) begin // Override num of read/write request in case of duty cycle tests
            m_iocache_seq<%=qidx%>[<%=coreidx%>].k_num_read_req      = ioaiu<%=qidx%>_num_trans*(m_iocache_seq<%=qidx%>[<%=coreidx%>].wt_ace_rdnosnp+m_iocache_seq<%=qidx%>[<%=coreidx%>].wt_ace_rdonce)/100;
            m_iocache_seq<%=qidx%>[<%=coreidx%>].k_num_write_req     = ioaiu<%=qidx%>_num_trans*(m_iocache_seq<%=qidx%>[<%=coreidx%>].wt_ace_wrnosnp+m_iocache_seq<%=qidx%>[<%=coreidx%>].wt_ace_wrunq)/100;
            m_iocache_seq<%=qidx%>_2[<%=coreidx%>].k_num_read_req      = ioaiu<%=qidx%>_num_trans2*(m_iocache_seq<%=qidx%>_2[<%=coreidx%>].wt_ace_rdnosnp+m_iocache_seq<%=qidx%>_2[<%=coreidx%>].wt_ace_rdonce)/100;
            m_iocache_seq<%=qidx%>_2[<%=coreidx%>].k_num_write_req     = ioaiu<%=qidx%>_num_trans2*(m_iocache_seq<%=qidx%>_2[<%=coreidx%>].wt_ace_wrnosnp+m_iocache_seq<%=qidx%>_2[<%=coreidx%>].wt_ace_wrunq)/100;
         end
     end:ioaiu<%=qidx%>_alternate_coh_noncoh_<%=coreidx%> else begin:ioaiu<%=qidx%>_no_alternate_coh_noncoh_<%=coreidx%>

     if($test$plusargs("noncoherent_test") || $test$plusargs("ioaiu<%=qidx%>_noncoherent_test") || $test$plusargs("ioaiu<%=qidx%>_alternate_noncoh_test")) begin
         // Enable both read+write by default
         if (!$value$plusargs("wt_ace_rdnosnp=%d", m_iocache_seq<%=qidx%>[<%=coreidx%>].wt_ace_rdnosnp)) m_iocache_seq<%=qidx%>[<%=coreidx%>].wt_ace_rdnosnp   = 50;
         if (!$value$plusargs("wt_ace_wrnosnp=%d", m_iocache_seq<%=qidx%>[<%=coreidx%>].wt_ace_wrnosnp)) m_iocache_seq<%=qidx%>[<%=coreidx%>].wt_ace_wrnosnp   = 50;
         if (!$value$plusargs("wt_ace_rdnosnp=%d", m_iocache_seq<%=qidx%>_2[<%=coreidx%>].wt_ace_rdnosnp)) m_iocache_seq<%=qidx%>_2[<%=coreidx%>].wt_ace_rdnosnp   = 50;
         if (!$value$plusargs("wt_ace_wrnosnp=%d", m_iocache_seq<%=qidx%>_2[<%=coreidx%>].wt_ace_wrnosnp)) m_iocache_seq<%=qidx%>_2[<%=coreidx%>].wt_ace_wrnosnp   = 50;
         if ($test$plusargs("read_test") || $test$plusargs("ioaiu<%=qidx%>_read_test")) begin
             m_iocache_seq<%=qidx%>[<%=coreidx%>].wt_ace_rdnosnp     = 100;
             m_iocache_seq<%=qidx%>[<%=coreidx%>].wt_ace_wrnosnp     = 0;
             m_iocache_seq<%=qidx%>_2[<%=coreidx%>].wt_ace_rdnosnp     = 100;
             m_iocache_seq<%=qidx%>_2[<%=coreidx%>].wt_ace_wrnosnp     = 0;
         end 
         if ($test$plusargs("write_test") || $test$plusargs("ioaiu<%=qidx%>_write_test")) begin
             m_iocache_seq<%=qidx%>[<%=coreidx%>].wt_ace_rdnosnp     = 0;
             m_iocache_seq<%=qidx%>[<%=coreidx%>].wt_ace_wrnosnp     = 100;
             m_iocache_seq<%=qidx%>_2[<%=coreidx%>].wt_ace_rdnosnp     = 0;
             m_iocache_seq<%=qidx%>_2[<%=coreidx%>].wt_ace_wrnosnp     = 100;
	 end
	 if($test$plusargs("k_duty_cycle_ioaiu<%=qidx%>")) begin // RF Override num of read/write request in case of duty cycle tests
             m_iocache_seq<%=qidx%>[<%=coreidx%>].k_num_read_req      = ioaiu<%=qidx%>_num_trans*m_iocache_seq<%=qidx%>[<%=coreidx%>].wt_ace_rdnosnp/100;
             m_iocache_seq<%=qidx%>[<%=coreidx%>].k_num_write_req     = ioaiu<%=qidx%>_num_trans*m_iocache_seq<%=qidx%>[<%=coreidx%>].wt_ace_wrnosnp/100;
             m_iocache_seq<%=qidx%>_2[<%=coreidx%>].k_num_read_req      = ioaiu<%=qidx%>_num_trans2*m_iocache_seq<%=qidx%>_2[<%=coreidx%>].wt_ace_rdnosnp/100;
             m_iocache_seq<%=qidx%>_2[<%=coreidx%>].k_num_write_req     = ioaiu<%=qidx%>_num_trans2*m_iocache_seq<%=qidx%>_2[<%=coreidx%>].wt_ace_wrnosnp/100;
         end
     end // if ($test$lusargs("noncoherent_test"))
     <% if((obj.AiuInfo[pidx].fnNativeInterface != "AXI4") || obj.AiuInfo[pidx].useCache ) { %>
     else begin
         // Enable both read+write by default
         if (!$value$plusargs("wt_ace_rdonce=%d", m_iocache_seq<%=qidx%>[<%=coreidx%>].wt_ace_rdonce)) m_iocache_seq<%=qidx%>[<%=coreidx%>].wt_ace_rdonce       = 50;
         if (!$value$plusargs("wt_ace_wrunq=%d", m_iocache_seq<%=qidx%>[<%=coreidx%>].wt_ace_wrunq))  m_iocache_seq<%=qidx%>[<%=coreidx%>].wt_ace_wrunq        = 50;
         if (!$value$plusargs("wt_ace_rdonce=%d", m_iocache_seq<%=qidx%>_2[<%=coreidx%>].wt_ace_rdonce)) m_iocache_seq<%=qidx%>_2[<%=coreidx%>].wt_ace_rdonce       = 50;
         if (!$value$plusargs("wt_ace_wrunq=%d", m_iocache_seq<%=qidx%>_2[<%=coreidx%>].wt_ace_wrunq))  m_iocache_seq<%=qidx%>_2[<%=coreidx%>].wt_ace_wrunq        = 50;
         if ($test$plusargs("read_test") || $test$plusargs("ioaiu<%=qidx%>_read_test")) begin
             m_iocache_seq<%=qidx%>[<%=coreidx%>].wt_ace_rdonce      = 100;
             m_iocache_seq<%=qidx%>[<%=coreidx%>].wt_ace_wrunq       = 0;
             m_iocache_seq<%=qidx%>_2[<%=coreidx%>].wt_ace_rdonce      = 100;
             m_iocache_seq<%=qidx%>_2[<%=coreidx%>].wt_ace_wrunq       = 0;
         end 
         if ($test$plusargs("write_test") || $test$plusargs("ioaiu<%=qidx%>_write_test")) begin
             m_iocache_seq<%=qidx%>[<%=coreidx%>].wt_ace_rdonce      = 0;
             m_iocache_seq<%=qidx%>[<%=coreidx%>].wt_ace_wrunq       = 100;
             m_iocache_seq<%=qidx%>_2[<%=coreidx%>].wt_ace_rdonce      = 0;
             m_iocache_seq<%=qidx%>_2[<%=coreidx%>].wt_ace_wrunq       = 100;
	 end
         if($test$plusargs("k_duty_cycle_ioaiu<%=qidx%>")) begin // RF Override num of read/write request in case of duty cycle tests
             m_iocache_seq<%=qidx%>[<%=coreidx%>].k_num_read_req      = ioaiu<%=qidx%>_num_trans*m_iocache_seq<%=qidx%>[<%=coreidx%>].wt_ace_rdonce/100;
             m_iocache_seq<%=qidx%>[<%=coreidx%>].k_num_write_req     = ioaiu<%=qidx%>_num_trans*m_iocache_seq<%=qidx%>[<%=coreidx%>].wt_ace_wrunq/100;
             m_iocache_seq<%=qidx%>_2[<%=coreidx%>].k_num_read_req      = ioaiu<%=qidx%>_num_trans2*m_iocache_seq<%=qidx%>_2[<%=coreidx%>].wt_ace_rdonce/100;
             m_iocache_seq<%=qidx%>_2[<%=coreidx%>].k_num_write_req     = ioaiu<%=qidx%>_num_trans2*m_iocache_seq<%=qidx%>_2[<%=coreidx%>].wt_ace_wrunq/100;
         end
     end
     <% } %>
     end:ioaiu<%=qidx%>_no_alternate_coh_noncoh_<%=coreidx%>	

     <%if((obj.AiuInfo[pidx].fnNativeInterface == 'AXI4' && obj.AiuInfo[pidx].useCache)) {%>
     if($test$plusargs("all_gpra_ncmode"))  begin
     // TMP avoid send noncoh txn in coh mem region //TODO when gpra random should add constraint with gpra.nc when select addr in noncoh & coh mem region 
                       m_iocache_seq<%=qidx%>[<%=coreidx%>].wt_ace_wrunq        = 100;
                end
    <% }%>

     if($test$plusargs("ioaiu<%=qidx%>_stashnid")) begin
         m_iocache_seq<%=qidx%>[<%=coreidx%>].wt_ace_wrunq        = 0;
         m_iocache_seq<%=qidx%>[<%=coreidx%>].wt_ace_rdonce      = 0;
         m_iocache_seq<%=qidx%>[<%=coreidx%>].wt_ace_rdnosnp     = 0;
         m_iocache_seq<%=qidx%>[<%=coreidx%>].wt_ace_wrnosnp     = 0;
         m_iocache_seq<%=qidx%>[<%=coreidx%>].wt_ace_unq_stash   = 100;
     end			
     m_iocache_seq<%=qidx%>[<%=coreidx%>].k_num_read_req      = ((m_iocache_seq<%=qidx%>[<%=coreidx%>].k_num_read_req*wt_axlen_256B/100)/4) + (m_iocache_seq<%=qidx%>[<%=coreidx%>].k_num_read_req*(100-wt_axlen_256B)/100) ; // 1000 read txn 64B => 80%of 256B+20% of 64B = 400 read txn 
     m_iocache_seq<%=qidx%>[<%=coreidx%>].k_num_write_req     = ((m_iocache_seq<%=qidx%>[<%=coreidx%>].k_num_write_req*wt_axlen_256B/100)/4) + (m_iocache_seq<%=qidx%>[<%=coreidx%>].k_num_write_req*(100-wt_axlen_256B)/100) ; // 1000 write txn 64B => 80%of 256B+20% of 64B = 400 write txn 
     m_iocache_seq<%=qidx%>[<%=coreidx%>].user_qos       = 1;
     m_iocache_seq<%=qidx%>[<%=coreidx%>].aiu_qos        = ioaiu_qos[<%=qidx%>];

     m_iocache_seq<%=qidx%>_2[<%=coreidx%>].k_num_read_req      = ((m_iocache_seq<%=qidx%>_2[<%=coreidx%>].k_num_read_req*wt_axlen_256B/100)/4) + (m_iocache_seq<%=qidx%>_2[<%=coreidx%>].k_num_read_req*(100-wt_axlen_256B)/100) ; // 1000 read txn 64B => 80%of 256B+20% of 64B = 400 read txn 
     m_iocache_seq<%=qidx%>_2[<%=coreidx%>].k_num_write_req     = ((m_iocache_seq<%=qidx%>_2[<%=coreidx%>].k_num_write_req*wt_axlen_256B/100)/4) + (m_iocache_seq<%=qidx%>_2[<%=coreidx%>].k_num_write_req*(100-wt_axlen_256B)/100) ; // 1000 write txn 64B => 80%of 256B+20% of 64B = 400 write txn 
     m_iocache_seq<%=qidx%>_2[<%=coreidx%>].user_qos       = 1;
     m_iocache_seq<%=qidx%>_2[<%=coreidx%>].aiu_qos        = ioaiu_qos2[<%=qidx%>];
    <% } //foreach Core %>          
    <% qidx++; %>
  <% } %>
<% } %>

`else //will activate the flow of USE_VIP_SNPS

 <% var qidx=0;var idx=0; for(var pidx = 0; pidx < obj.nAIUs; pidx++) { %>
    <% if((obj.AiuInfo[pidx].fnNativeInterface == 'CHI-A')||(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-B' || obj.AiuInfo[pidx].fnNativeInterface == 'CHI-E')) { %>
            m_chi0_args.k_num_requests.set_value(chiaiu<%=idx%>_num_trans);
            m_chi0_args.k_device_type_mem_pct.set_value(0);
            m_chi0_args.k_wr_cpybck_pct.set_value(0);
            m_chi0_args.k_dt_ls_upd_pct.set_value(0);
            m_chi0_args.k_dt_ls_cmo_pct.set_value(0);
            m_chi0_args.k_pre_fetch_pct.set_value(0);
            m_chi0_args.k_dt_ls_sth_pct.set_value(0);
            m_chi0_args.k_wr_sthunq_pct.set_value(0);
            m_chi0_args.k_atomic_st_pct.set_value(0);
            m_chi0_args.k_atomic_ld_pct.set_value(0);
            m_chi0_args.k_atomic_sw_pct.set_value(0);
            m_chi0_args.k_atomic_cm_pct.set_value(0);
            m_chi0_args.k_dvm_opert_pct.set_value(0);
            if($test$plusargs("noncoherent_test")) begin
               m_chi0_args.k_coh_addr_pct.set_value(0);
               m_chi0_args.k_noncoh_addr_pct.set_value(100);
               if (!$test$plusargs("k_rd_noncoh_pct")) m_chi0_args.k_rd_noncoh_pct.set_value(chiaiu<%=idx%>_read_ratio);
               if (!$test$plusargs("k_wr_noncoh_pct")) m_chi0_args.k_wr_noncoh_pct.set_value(chiaiu<%=idx%>_write_ratio);
               if ($test$plusargs("read_test")|| $test$plusargs("chi<%=idx%>_read_test")) begin
                  m_chi0_args.k_wr_noncoh_pct.set_value(0);
               end
               if ($test$plusargs("write_test")||$test$plusargs("chi<%=idx%>_write_test")) begin
                  m_chi0_args.k_wr_noncoh_pct.set_value(100);
                  m_chi0_args.k_rd_noncoh_pct.set_value(0);
	       end // else: !if($test$plusargs("write_test"))
	    end	
	    else begin
               m_chi0_args.k_coh_addr_pct.set_value(100);
               m_chi0_args.k_noncoh_addr_pct.set_value(0);
               if (!$test$plusargs("k_rd_ldrstr_pct") && !$test$plusargs("k_rd_rdonce_pct")) m_chi0_args.k_rd_ldrstr_pct.set_value(chiaiu<%=idx%>_read_ratio);
               if (!$test$plusargs("k_wr_cohunq_pct")) m_chi0_args.k_wr_cohunq_pct.set_value(chiaiu<%=idx%>_write_ratio);
               if ($test$plusargs("read_test")|| $test$plusargs("chi<%=idx%>_read_test")) begin
                  m_chi0_args.k_wr_cohunq_pct.set_value(0);
               end
               if ($test$plusargs("write_test")||$test$plusargs("chi<%=idx%>_write_test")) begin
                  m_chi0_args.k_wr_cohunq_pct.set_value(100);
                  m_chi0_args.k_rd_ldrstr_pct.set_value(0);
         	  m_chi0_args.k_rd_rdonce_pct.set_value(0);
	          end // else: !if($test$plusargs("write_test"))
		   // case to force rd_once on specific CHI to be allow 1 CHI read
		   // unique & another read once to measure the snoop BW 
		if ($test$plusargs("force_chi<%=idx%>_rdonce")) begin 
                   m_chi0_args.k_rd_ldrstr_pct.set_value(0);
         	   m_chi0_args.k_rd_rdonce_pct.set_value(100);
		end
		if ($test$plusargs("chi_stashnid")) begin
                   m_chi0_args.k_dt_ls_sth_pct.set_value(100);
		   m_chi0_args.k_rd_ldrstr_pct.set_value(0);
         	   m_chi0_args.k_rd_rdonce_pct.set_value(0);
		end
	    end

           if(!$value$plusargs("chi_txreq_delay=%d", chi_txreq_dly)) begin
		chi_txreq_dly = 0;
           end
	   if(!chiaiu_slow_master.exists(<%=idx%>)) begin
               `uvm_info("TEST_MAIN", "CHAIU<%=idx%> fast master", UVM_MEDIUM)
               m_chi0_args.k_txreq_hld_dly.set_value(1);
               m_chi0_args.k_txreq_dly_min.set_value(chi_txreq_dly);
               m_chi0_args.k_txreq_dly_max.set_value(chi_txreq_dly);
               m_chi0_args.k_txrsp_hld_dly.set_value(1);
               m_chi0_args.k_txrsp_dly_min.set_value(0);
               m_chi0_args.k_txrsp_dly_max.set_value(0);
               m_chi0_args.k_txdat_hld_dly.set_value(1);
               m_chi0_args.k_txdat_dly_min.set_value(0);
               m_chi0_args.k_txdat_dly_max.set_value(0);
               m_chi0_args.k_alloc_hint_pct.set_value(90);
               m_chi0_args.k_cacheable_pct.set_value(90);
	       m_chi0_args.k_on_fly_req.set_value(32);
	    end
            else begin
               `uvm_info("TEST_MAIN", "CHAIU<%=idx%> slow master", UVM_MEDIUM)
               m_chi0_args.k_txreq_dly_min.set_value(500);
               m_chi0_args.k_txreq_dly_max.set_value(5000);
            end
            //set the args
            m_snps_chi<%=idx%>_vseq.set_unit_args(m_chi0_args);

            m_snps_chi<%=idx%>_vseq.user_qos = 1;
	    m_snps_chi<%=idx%>_vseq.aiu_qos  = chiaiu_qos[<%=idx%>];

      <% idx++;  %>
    <%} else { %>
	//need to add for ioaiu

    <% qidx++; %>
  <% } %>
<% } %>
`endif //`else part will run flow with SNPS

exec_cache_preload_seq(phase);

<% if(obj.PmaInfo.length > 0) { %>
    if($test$plusargs("qchannel_req_between_cmd_test")) begin
       fork
       <% for(var i=0; i<obj.PmaInfo.length; i++) { %>
       forever begin
          //phase.raise_objection(this, "q_cnl_seq<%=i%>");
          wait(m_concerto_env.inhouse.<%=obj.PmaInfo[i].strRtlNamePrefix%>_qc_if.QACCEPTn); 
          m_concerto_env.inhouse.m_q_chnl_seq<%=i%>.start(m_concerto_env.inhouse.m_q_chnl_agent<%=i%>.m_q_chnl_seqr);
          //phase.drop_objection(this, "q_cnl_seq<%=i%>");
	  #(5000*1ns);
       end
       <% } %>
       join_none
    end
<% } %>

            fork
                fork
                      if($test$plusargs("run_qos_test")) begin
                         #106ns;
			 exec_qos_seq(phase);
		      end
  <% var chiaiu_idx = 0;
  var ioaiu_idx = 0;
  for(var pidx = 0; pidx < obj.nAIUs; pidx++) { %>
    <% if((obj.AiuInfo[pidx].fnNativeInterface == 'CHI-A')||(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-B' || obj.AiuInfo[pidx].fnNativeInterface == 'CHI-E')) { %>
	     `ifndef USE_VIP_SNPS
		 begin
                  if(chiaiu_en.exists(<%=chiaiu_idx%>)) begin
                     `uvm_info("TEST_MAIN", "Start CHIAIU<%=chiaiu_idx%> VSEQ", UVM_NONE)
                      phase.raise_objection(this, "CHIAIU<%=chiaiu_idx%> sequence");
                      m_chi<%=chiaiu_idx%>_vseq.start(null);  
                     `uvm_info("TEST_MAIN", "Done CHIAIU<%=chiaiu_idx%> VSEQ", UVM_NONE)
                      #5us;
                      phase.drop_objection(this, "CHIAIU<%=chiaiu_idx%> sequence");
		   end
		 end

             `else //`ifdef USE_VIP_SNPS
		 begin
  
                 if(vip_snps_coherent_txn || vip_snps_non_coherent_txn) begin
                  //SVT TRAFFIC
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
                 end
                 else begin
                    m_svt_chi_item.print();
                   `uvm_info(get_name(), "Start m_snps_chi<%=chiaiu_idx%>_vseq", UVM_NONE)
                    //snps_vseq.start(null);
                    m_snps_chi<%=chiaiu_idx%>_vseq.start(null);
                    //done_svt_chi_rn_seq_h<%=chiaiu_idx%>.trigger(null);
                   `uvm_info(get_name(), "Done m_snps_chi<%=chiaiu_idx%>_vseq", UVM_NONE)
                 end
              end
             `endif //`ifdef USE_VIP_SNPS ... `else
      <% chiaiu_idx++; %> 
    <% } else { %>
                    `ifndef USE_VIP_SNPS
    <% for(var i=0; i<aiu_NumCores[pidx]; i++) { %>
                    begin
		        if(ioaiu_en.exists(<%=ioaiu_idx%>)) begin
                        phase.raise_objection(this, "IOAIU<%=ioaiu_idx%>[<%=i%>] sequence");
                        `uvm_info("TEST_MAIN", "Start IOAIU<%=ioaiu_idx%>[<%=i%>] VSEQ", UVM_NONE)
                        #10ns;
                        m_iocache_seq<%=ioaiu_idx%>[<%=i%>].start(null);
                        `uvm_info("TEST_MAIN", "Done IOAIU<%=ioaiu_idx%>[<%=i%>] VSEQ", UVM_NONE)
                        #5us;
                        phase.drop_objection(this, "IOAIU<%=ioaiu_idx%>[<%=i%>] sequence");
                        end
                    end
	<% } //foreach core %>
                      `endif //will not run SNPS flow 
    <% ioaiu_idx++; } %>
  <% } %>

                    begin
                        fork

`ifndef USE_VIP_SNPS   //existing flow will not run when USE_VIP_SNPS set                     
  <%chiaiu_idx = 0;
  ioaiu_idx = 0;
  for(var pidx = 0; pidx < obj.nAIUs; pidx++) {
    if((obj.AiuInfo[pidx].fnNativeInterface == 'CHI-A')||(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-B' || obj.AiuInfo[pidx].fnNativeInterface == 'CHI-E')) { %>
		        if(chiaiu_en.exists(<%=chiaiu_idx%>)) begin
                            ev_chi<%=chiaiu_idx%>_seq_done.wait_trigger();
                            if($test$plusargs("run_seq2")) begin
				addr_mgr.gen_seq_addr_in_user_addrq(use_user_addrq, perf_txn_size, chiaiu_intrlv_grp, -1, m_chi<%=chiaiu_idx%>_vseq.m_chi_container.user_addrq[ncoreConfigInfo::COH]);
                               fork
                               begin
                               `uvm_info("TEST_MAIN", "Start CHIAIU<%=chiaiu_idx%> VSEQ2", UVM_NONE)
                               phase.raise_objection(this, "CHIAIU<%=chiaiu_idx%> sequence2");
                               m_chi<%=chiaiu_idx%>_vseq_2.start(null);  
                               `uvm_info("TEST_MAIN", "Done CHIAIU<%=chiaiu_idx%> VSEQ2", UVM_NONE)
                               phase.drop_objection(this, "CHIAIU<%=chiaiu_idx%> sequence2");
                               end
                               begin
                                  ev_chi<%=chiaiu_idx%>_seq2_done.wait_trigger();
                               end
                               join_any
                            end
                            if($test$plusargs("inter_bw_report")) begin
	                        `uvm_info("TEST_MAIN", $sformatf("CHIAIU<%=chiaiu_idx%> sequence done.  Reporting intermediate BW"), UVM_NONE)
			        ev_report_bw.trigger(null);
			    end								     
                            // do clock off if enabled
                            if(clk_off_chiaiu.exists(<%=chiaiu_idx%>)) begin
			    wait(m_chi<%=chiaiu_idx%>_vseq.m_chi_container.m_txnid_pool.size() == 256);
			    #(100*1ns);
                            m_chi<%=chiaiu_idx%>_vseq.construct_lnk_down_seq();
                            <% for(var clk=0; clk<obj.Clocks.length; clk++) { %>
			       if(clk_off_en.exists(<%=clk%>)) begin
                                  // start PMA
                                  <%if (clk < obj.PmaInfo.length) { %>
                                  wait(m_concerto_env.inhouse.<%=obj.PmaInfo[clk].strRtlNamePrefix%>_qc_if.QACCEPTn); 
				  #100ns;
                                  `uvm_info("TEST_MAIN", $sformatf("Start asserting m_concerto_env.inhouse.<%=obj.PmaInfo[clk].strRtlNamePrefix%>_qc_if.QREQn"), UVM_NONE)
                                  m_concerto_env.inhouse.m_q_chnl_seq<%=clk%>.start(m_concerto_env.inhouse.m_q_chnl_agent<%=clk%>.m_q_chnl_seqr);
				  #100ns;
                                  <% } %>
                                  `uvm_info("TEST_MAIN", $sformatf("Turning off tb_top.m_clk_if_<%=clocks[clk]%>.clk for %0d ns after CHI<%=chiaiu_idx%> sequence done", clk_off_time), UVM_NONE)
			          force tb_top.m_clk_if_<%=clocks[clk]%>.clk = 0;
				  #(clk_off_time * 1ns);					  
                                  `uvm_info("TEST_MAIN", "Releasing tb_top.m_clk_if_<%=clocks[clk]%>.clk", UVM_NONE)
			          release tb_top.m_clk_if_<%=clocks[clk]%>.clk;
			       end
			    <% } %>						  
                            end
			end
      <% chiaiu_idx++;
    } else { %>
    <% for(var i=0; i<aiu_NumCores[pidx]; i++) { %>
		        if(ioaiu_en.exists(<%=ioaiu_idx%>)) begin												
                            ev_ioaiu<%=ioaiu_idx%>_<%=i%>_seq_done.wait_trigger();
                            if($test$plusargs("run_seq2")) begin
                               if($value$plusargs("ioaiu<%=ioaiu_idx%>_axi_master_delay2=%d", axi_master_delay2[<%=ioaiu_idx%>])) begin
                               m_concerto_env.inhouse.m_ioaiu<%=ioaiu_idx%>_env.m_env[<%=i%>].m_axi_master_agent.m_cfg.m_vif.ACE_MASTER_READ_ADDR_CHANNEL_BURST_PCT = 0;
                               m_concerto_env.inhouse.m_ioaiu<%=ioaiu_idx%>_env.m_env[<%=i%>].m_axi_master_agent.m_cfg.m_vif.ACE_MASTER_READ_ADDR_CHANNEL_DELAY_MIN = axi_master_delay2[<%=ioaiu_idx%>];
                               m_concerto_env.inhouse.m_ioaiu<%=ioaiu_idx%>_env.m_env[<%=i%>].m_axi_master_agent.m_cfg.m_vif.ACE_MASTER_READ_ADDR_CHANNEL_DELAY_MAX = axi_master_delay2[<%=ioaiu_idx%>];
                               m_concerto_env.inhouse.m_ioaiu<%=ioaiu_idx%>_env.m_env[<%=i%>].m_axi_master_agent.m_cfg.m_vif.ACE_MASTER_WRITE_ADDR_CHANNEL_BURST_PCT = 0;
                               m_concerto_env.inhouse.m_ioaiu<%=ioaiu_idx%>_env.m_env[<%=i%>].m_axi_master_agent.m_cfg.m_vif.ACE_MASTER_WRITE_ADDR_CHANNEL_DELAY_MIN = axi_master_delay2[<%=ioaiu_idx%>];
                               m_concerto_env.inhouse.m_ioaiu<%=ioaiu_idx%>_env.m_env[<%=i%>].m_axi_master_agent.m_cfg.m_vif.ACE_MASTER_WRITE_ADDR_CHANNEL_DELAY_MAX = axi_master_delay2[<%=ioaiu_idx%>];
                               end
	                       addr_mgr.gen_seq_addr_in_user_addrq(use_user_addrq, perf_coh_txn_size, ioaiu_intrlv_grp,-1, m_concerto_env.inhouse.m_ace_cache_model_ioaiu<%=ioaiu_idx%>[<%=i%>].user_addrq[ncoreConfigInfo::COH]);
                               fork
                               begin
                               phase.raise_objection(this, "IOAIU<%=ioaiu_idx%>[<%=i%>] sequence2");
                               `uvm_info("TEST_MAIN", "Start IOAIU<%=ioaiu_idx%>[<%=i%>] VSEQ2", UVM_NONE)
                               m_iocache_seq<%=ioaiu_idx%>_2[<%=i%>].start(null);
                               `uvm_info("TEST_MAIN", "Done IOAIU<%=ioaiu_idx%>[<%=i%>] VSEQ2", UVM_NONE)
                               phase.drop_objection(this, "IOAIU<%=ioaiu_idx%>[<%=i%>] sequence2");
                               end
                               begin
                                  ev_ioaiu<%=ioaiu_idx%>_<%=i%>_seq2_done.wait_trigger();
                               end
                               join_any
                            end
                       end
  <% } //foreach core %>
                            if($test$plusargs("inter_bw_report")) begin
	                        `uvm_info("TEST_MAIN", $sformatf("IOAIU<%=ioaiu_idx%> sequence done.  Reporting intermediate BW"), UVM_NONE)
			        ev_report_bw.trigger(null);
			    end								     
                            // do clock off if enabled
                            if(clk_off_ioaiu.exists(<%=ioaiu_idx%>)) begin
                            <% for(var clk=0; clk<obj.Clocks.length; clk++) { %>
			       if(clk_off_en.exists(<%=clk%>)) begin
                                  <%if (clk < obj.PmaInfo.length) { %>
                                  // start PMA
                                  wait(m_concerto_env.inhouse.<%=obj.PmaInfo[clk].strRtlNamePrefix%>_qc_if.QACCEPTn); 
				  #100ns;
                                  `uvm_info("TEST_MAIN", $sformatf("Start asserting m_concerto_env.inhouse.<%=obj.PmaInfo[clk].strRtlNamePrefix%>_qc_if.QREQn"), UVM_NONE)
                                  m_concerto_env.inhouse.m_q_chnl_seq<%=clk%>.start(m_concerto_env.inhouse.m_q_chnl_agent<%=clk%>.m_q_chnl_seqr);
				  #100ns;
                                  <% } %>

                                  `uvm_info("TEST_MAIN", $sformatf("Turning off tb_top.m_clk_if_<%=clocks[clk]%>.clk for %0d ns after IOAIU<%=ioaiu_idx%> sequence done", clk_off_time), UVM_NONE)
				  #(200*1ns);
			          force tb_top.m_clk_if_<%=clocks[clk]%>.clk = 0;
				  #(clk_off_time * 1ns);					  
                                  `uvm_info("TEST_MAIN", "Releasing tb_top.m_clk_if_<%=clocks[clk]%>.clk", UVM_NONE)
			          release tb_top.m_clk_if_<%=clocks[clk]%>.clk;
			       end
			    <% } %>						  
                        end
    <% ioaiu_idx++; }
  } %>
  `endif //ifndef SNPS

                        join
                        `uvm_info("TEST_MAIN", "All sequences DONE", UVM_NONE)
                        ev_sim_done.trigger(null);
                    end
                join

                begin
                    #(sim_timeout_ms*1ms);
                    timeout = 1;
                end
            join_any

        if (timeout)begin
            `uvm_fatal(get_name(), "Test Timeout")
            #50us;
        end   
    phase.drop_objection(this, "bringup_test");
endtask: exec_inhouse_seq

task concerto_fullsys_qos_test::exec_inhouse_boot_seq(uvm_phase phase);
// Randomize and set configuration in DMI scoreboard
    bit [31:0] agent_id,way_vec,way_full_chk;
    bit [31:0] agent_ids_assigned_q[ncore_config_pkg::ncoreConfigInfo::NUM_DMIS][$];
    bit [31:0] wayvec_assigned_q[ncore_config_pkg::ncoreConfigInfo::NUM_DMIS][$];
    int shared_ways_per_user;
    int way_for_atomic=0;

    int sp_ways[] = new[ncore_config_pkg::ncoreConfigInfo::NUM_DMIS];
    int sp_size[] = new[ncore_config_pkg::ncoreConfigInfo::NUM_DMIS];
    bit [<%=obj.wSysAddr-1%>:0] k_sp_base_addr[] = new[ncore_config_pkg::ncoreConfigInfo::NUM_DMIS];
    int idxq[$];
    string dce_credit_msg="";
    int new_dce_credits;

    ncore_config_pkg::ncoreConfigInfo::sys_addr_csr_t csrq[$];
    csrq = ncore_config_pkg::ncoreConfigInfo::get_all_gpra();

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

             case(i) <%for(var sidx = 0; sidx < obj.nDMIs; sidx++) {%>
                <%=sidx%> : begin <% if(obj.DmiInfo[sidx].useWayPartitioning && obj.DmiInfo[sidx].useCmc) {%>
                                 if(m_args.dmi_scb_en) begin
                                    m_concerto_env.inhouse.m_dmi<%=sidx%>_env.m_sb.way_partition_vld[j] = agent_id[31]; m_concerto_env.inhouse.m_dmi<%=sidx%>_env.m_sb.way_partition_reg_id[j] = agent_id[30:0];
                                    if ($test$plusargs("no_way_partitioning")) m_concerto_env.inhouse.m_dmi<%=sidx%>_env.m_sb.way_partition_vld[j]=0;
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
		      `uvm_info("TEST_MAIN", $sformatf("For DMI%0d reg%0d with wayvec :%0b",i,j,way_vec), UVM_LOW)
              wayvec_assigned_q[i].push_back(way_vec);
              way_full_chk |=way_vec;
              `uvm_info("TEST_MAIN", $sformatf("For DMI%0d reg%0d with wayfull:%0b num ways in DMI:%0d",i,j,way_full_chk,ncore_config_pkg::ncoreConfigInfo::dmi_CmcWays[i]), UVM_LOW)
          end

          for( int j=0;j<ncore_config_pkg::ncoreConfigInfo::dmi_CmcWPReg[i];j++) begin
              `uvm_info("TEST_MAIN", $sformatf("For DMI%0d reg%0d with wayfull:%0b count ones:%0d",i,j,way_full_chk,$countones(way_full_chk)), UVM_LOW)
              way_vec = wayvec_assigned_q[i].pop_front;
              if(ncore_config_pkg::ncoreConfigInfo::dmis_with_ae[i] && $countones(way_full_chk)>=ncore_config_pkg::ncoreConfigInfo::dmi_CmcWays[i]) begin  
                 way_vec[way_for_atomic] = 1'b0;
                 `uvm_info("TEST_MAIN", $sformatf("For DMI%0d with AtomicEngine way:%0d/%0d is unallocated, so that atomic txn can allocate",i,way_for_atomic,ncore_config_pkg::ncoreConfigInfo::dmi_CmcWays[i]), UVM_LOW)
                 `uvm_info("TEST_MAIN", $sformatf("For DMI%0d reg%0d with wayvec :%0b",i,j,way_vec), UVM_LOW)
              end
              wayvec_assigned_q[i].push_back(way_vec);

              case(i) <%for(var sidx = 0; sidx < obj.nDMIs; sidx++) {%>
                 <%=sidx%> : begin <% if(obj.DmiInfo[sidx].useWayPartitioning && obj.DmiInfo[sidx].useCmc) {%>
                                  if(m_args.dmi_scb_en) begin
                                     m_concerto_env.inhouse.m_dmi<%=sidx%>_env.m_sb.way_partition_reg_way[j] = way_vec;
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
	  if(m_args.dmi_scb_en) begin 
              case(i) <%for(var sidx = 0; sidx < obj.nDMIs; sidx++) { if(obj.DmiInfo[sidx].ccpParams.useScratchpad==1) {%>
                 <%=sidx%> : 
                    if(sp_ways[<%=sidx%>] > 0) begin
                       m_concerto_env.inhouse.m_dmi<%=sidx%>_env.m_sb.sp_enabled     = (ncore_config_pkg::ncoreConfigInfo::dmi_CmcWays[<%=sidx%>]) ? 32'h1 : 32'h0;
                       m_concerto_env.inhouse.m_dmi<%=sidx%>_env.m_sb.lower_sp_addr  = k_sp_base_addr[<%=sidx%>];
                       m_concerto_env.inhouse.m_dmi<%=sidx%>_env.m_sb.sp_ways        = sp_ways[<%=sidx%>];
                       m_concerto_env.inhouse.m_dmi<%=sidx%>_env.m_sb.create_SP_q();
		    end
                <% } } %>
              endcase
	  end
          <% } %>
       end // if (ncore_config_pkg::ncoreConfigInfo::dmis_with_cmcsp[i])
    end // for nDMIs

// Setup SysCo Attach for IOAIU scoreboards
if(m_args.ioaiu_scb_en) begin
#10ns;
<% var ioidx=0;
for(pidx=0; pidx<obj.nAIUs; pidx++) {
if((obj.AiuInfo[pidx].fnNativeInterface != 'CHI-A') && (obj.AiuInfo[pidx].fnNativeInterface != 'CHI-B' && obj.AiuInfo[pidx].fnNativeInterface != 'CHI-E')) { 
if((((obj.AiuInfo[pidx].fnNativeInterface === "ACELITE-E") || (obj.AiuInfo[pidx].fnNativeInterface === "ACE-LITE")) && (obj.AiuInfo[pidx].cmpInfo.nDvmSnpInFlight > 0)) || (obj.AiuInfo[pidx].fnNativeInterface == "ACE") || ((obj.AiuInfo[pidx].fnNativeInterface == "AXI4") && (obj.AiuInfo[pidx].useCache))) { %>
    m_concerto_env.inhouse.m_ioaiu<%=ioidx%>_env.m_env[0].m_scb.m_sysco_fsm_state = ioaiu<%=ioidx%>_env_pkg::CONNECT;   
    ev_sysco_fsm_state_change_<%=obj.AiuInfo[pidx].FUnitId%>.trigger();   
<% } ioidx++;
} } %>

end // if (m_args.ioaiu_scb_en)
   
//==================================================
    <% if(found_csr_access_ioaiu > 0) { %>
    `uvm_info("TEST_MAIN", "Start IOAIU<%=csrAccess_ioaiu%> boot_seq", UVM_NONE)
     // NEW FSYS TEST: NEEED update CONFIGURE_PAHSE //ioaiu_boot_seq<%=csrAccess_ioaiu%>(agent_ids_assigned_q,wayvec_assigned_q, k_sp_base_addr, sp_ways, sp_size, aiu_qos_threshold, dce_qos_threshold, dmi_qos_threshold,dmi_qos_rsved); 
    <% } else { %>
    `ifndef USE_VIP_SNPS // this will not run SNPS flow
    m_chi<%=csrAccess_chiaiu%>_vseq.m_regs = m_concerto_env.m_regs;
    m_chi<%=csrAccess_chiaiu%>_vseq.enum_boot_seq(agent_ids_assigned_q,wayvec_assigned_q, k_sp_base_addr, sp_ways, sp_size, aiu_qos_threshold, dce_qos_threshold, dmi_qos_threshold);
<% for(var temp_idx = 0; temp_idx < obj.nDCEs; temp_idx++) { %>
       for(int x=0;x<m_chi<%=csrAccess_chiaiu%>_vseq.numMrdCCR;x++) begin
         $sformat(dce_credit_msg, "dce%0d_dmi%0d_nMrdInFlight", m_chi<%=csrAccess_chiaiu%>_vseq.DceIds[<%=temp_idx%>], m_chi<%=csrAccess_chiaiu%>_vseq.DmiIds[x]);
         new_dce_credits=m_chi<%=csrAccess_chiaiu%>_vseq.aCredit_Mrd[m_chi<%=csrAccess_chiaiu%>_vseq.DceIds[<%=temp_idx%>]][m_chi<%=csrAccess_chiaiu%>_vseq.DmiIds[x]];
         if(m_concerto_env_cfg.m_dce<%=temp_idx%>_env_cfg.has_scoreboard)
           m_concerto_env.inhouse.m_dce<%=temp_idx%>_env.m_dce_scb.m_credits.scm_credit(dce_credit_msg, new_dce_credits);
       end
<% } %>
    `endif
    <% } %>

#5us; // Need to wait for pending transactions to complete e.g. DTRRsp
endtask: exec_inhouse_boot_seq

  
//////////////////
//Calling Method: UVM Factory
//Description: start_of_simulation_phase
//Arguments:   UVM Default
//Return type: Void
//////////////////
function void concerto_fullsys_qos_test::start_of_simulation_phase(uvm_phase phase);
    super.start_of_simulation_phase(phase);
endfunction : start_of_simulation_phase 


//////////////////
//Calling Method: UVM Factory
//Description: report phase, calls report method to display EOT results
//Arguments:   UVM Default
//Return type: Void
//////////////////
function void concerto_fullsys_qos_test::report_phase(uvm_phase phase);
    super.report_phase(phase);
endfunction : report_phase


task concerto_fullsys_qos_test::set_ioaiu_control_cfg();
   int ioaiu_control_cfg;
   
   $value$plusargs("ioaiu_control_cfg=%d",ioaiu_control_cfg);
   if(ioaiu_control_cfg == 1) begin
  <% for(var pidx = 0; pidx < obj.nAIUs; pidx++) { %>
    <% if((obj.AiuInfo[pidx].fnNativeInterface == 'ACE-LITE')||(obj.AiuInfo[pidx].fnNativeInterface == 'ACELITE-E')||(obj.AiuInfo[pidx].fnNativeInterface == 'ACE')) { %>
     <% if (obj.testBench != "emu" ) { %>
	   force `U_CHIP.<%=obj.AiuInfo[pidx].strRtlNamePrefix%>.ioaiu_core_wrapper.ioaiu_core0.apb_csr.XAIUEDR1_cfg_out = 32'h00100000;
     <% } %>
     <% if (obj.testBench == "emu" ) { %>
	 //  force ncore_hdl_top.dut.<%=obj.AiuInfo[pidx].strRtlNamePrefix%>.ioaiu_core.apb_csr.XAIUEDR1_cfg_out = 32'h00100000;
     <% } %>
    <% } %>
  <% } %>
   end
   else if(ioaiu_control_cfg == 2) begin
  <% for(var pidx = 0; pidx < obj.nAIUs; pidx++) { %>
    <% if((obj.AiuInfo[pidx].fnNativeInterface == 'ACE-LITE')||(obj.AiuInfo[pidx].fnNativeInterface == 'ACELITE-E')||(obj.AiuInfo[pidx].fnNativeInterface == 'ACE')) { %>
     <% if (obj.testBench != "emu" ) { %>
	   force `U_CHIP.<%=obj.AiuInfo[pidx].strRtlNamePrefix%>.ioaiu_core_wrapper.ioaiu_core0.apb_csr.XAIUEDR1_cfg_out = 32'h00200000;
     <% } %>
     <% if (obj.testBench == "emu" ) { %>
	    //  force ncore_hdl_top.dut.<%=obj.AiuInfo[pidx].strRtlNamePrefix%>.ioaiu_core.apb_csr.XAIUEDR1_cfg_out = 32'h00200000;
     <% } %>
    <% } %>
  <% } %>
   end
   else begin
  <% for(var pidx = 0; pidx < obj.nAIUs; pidx++) { %>
    <% if((obj.AiuInfo[pidx].fnNativeInterface == 'ACE-LITE')||(obj.AiuInfo[pidx].fnNativeInterface == 'ACELITE-E')||(obj.AiuInfo[pidx].fnNativeInterface == 'ACE')) { %>
     <% if (obj.testBench != "emu" ) { %>
	   force `U_CHIP.<%=obj.AiuInfo[pidx].strRtlNamePrefix%>.ioaiu_core_wrapper.ioaiu_core0.apb_csr.XAIUEDR1_cfg_out = 32'h00000000;
     <% } %>
     <% if (obj.testBench == "emu" ) { %>
	   //  force ncore_hdl_top.dut.<%=obj.AiuInfo[pidx].strRtlNamePrefix%>.ioaiu_core.apb_csr.XAIUEDR1_cfg_out = 32'h00000000;
     <% } %>
    <% } %>
  <% } %>
   end
endtask : set_ioaiu_control_cfg

<% for(var idx = 0, qidx=0; idx < obj.nAIUs; idx++) { 
    if((obj.AiuInfo[idx].fnNativeInterface != 'CHI-A')&&(obj.AiuInfo[idx].fnNativeInterface != 'CHI-B' && obj.AiuInfo[idx].fnNativeInterface != 'CHI-E')) { %>

task concerto_fullsys_qos_test::write_unq<%=qidx%>(input ioaiu<%=qidx%>_axi_agent_pkg::axi_axaddr_t addr, input bit[ioaiu<%=qidx%>_axi_agent_pkg::WXDATA-1:0] data, input ioaiu<%=qidx%>_axi_agent_pkg::axi_axlen_t axlen, input ioaiu<%=qidx%>_axi_agent_pkg::axi_awid_t awid, input bit use_user_data=0);
    ioaiu<%=qidx%>_inhouse_axi_bfm_pkg::axi_single_wrunq_data_seq m_iowrunq_seq<%=qidx%>;
    bit [ioaiu<%=qidx%>_axi_agent_pkg::WXDATA-1:0] wdata[];
    int addr_mask;
    int addr_offset;
    bit use_incr_data;

    use_incr_data = $test$plusargs("axi_incr_wdata")? 1 : 0;
    wdata = new[axlen+1];

    if(use_user_data == 1) begin
        wdata[0] = data;
        for(int i=1; i<=axlen; i=i+1) begin
            wdata[i] = '0;
        end
    end
    else if(use_incr_data == 1) begin
        foreach(wdata[idx]) begin
            wdata[idx] = addr + (idx*(ioaiu<%=qidx%>_axi_agent_pkg::WXDATA/8));
        end       
    end
    else begin
        foreach(wdata[idx]) begin
            wdata[idx] = $urandom();
        end
    end			  
    addr_mask = (ioaiu<%=qidx%>_axi_agent_pkg::WXDATA/8)-1;
    addr_offset = addr & addr_mask;

    m_iowrunq_seq<%=qidx%>   = ioaiu<%=qidx%>_inhouse_axi_bfm_pkg::axi_single_wrunq_data_seq::type_id::create("m_iowrunq_seq<%=qidx%>");

    m_iowrunq_seq<%=qidx%>.m_addr = addr;
    m_iowrunq_seq<%=qidx%>.m_axlen = axlen;
    m_iowrunq_seq<%=qidx%>.use_awid = awid;
    m_iowrunq_seq<%=qidx%>.user_qos = 1;
    m_iowrunq_seq<%=qidx%>.aiu_qos = ioaiu_qos[<%=qidx%>];

    m_iowrunq_seq<%=qidx%>.m_data = wdata[0];
    m_iowrunq_seq<%=qidx%>.m_wstrb = 'hFFFFFFFFFFFFFFFF;
    //`uvm_info("TEST_MAIN", $sformatf("write_unq address 0x%0h with data = %p", addr, m_iowrunq_seq<%=qidx%>.m_data), UVM_NONE);
    m_iowrunq_seq<%=qidx%>.start(m_ioaiu_vseqr<%=qidx%>[0]);
endtask : write_unq<%=qidx%>

task concerto_fullsys_qos_test::read_once<%=qidx%>(input ioaiu<%=qidx%>_axi_agent_pkg::axi_axaddr_t addr, input ioaiu<%=qidx%>_axi_agent_pkg::axi_axlen_t axlen, input ioaiu<%=qidx%>_axi_agent_pkg::axi_arid_t arid, output bit[ioaiu<%=qidx%>_axi_agent_pkg::WXDATA-1:0] data);
    ioaiu<%=qidx%>_inhouse_axi_bfm_pkg::axi_rdonce_seq m_iordonce_seq<%=qidx%>;
    bit [ioaiu<%=qidx%>_axi_agent_pkg::WXDATA-1:0] rdata;
    ioaiu<%=qidx%>_axi_agent_pkg::axi_rresp_t rresp;
    int addr_mask;
    int addr_offset;
										
    addr_mask = (ioaiu<%=qidx%>_axi_agent_pkg::WXDATA/8)-1;
    addr_offset = addr & addr_mask;

    m_iordonce_seq<%=qidx%>   = ioaiu<%=qidx%>_inhouse_axi_bfm_pkg::axi_rdonce_seq::type_id::create("m_iordonce_seq<%=qidx%>");
    m_iordonce_seq<%=qidx%>.m_addr = addr;
    m_iordonce_seq<%=qidx%>.m_len  = axlen;
    m_iordonce_seq<%=qidx%>.use_arid = arid;
    m_iordonce_seq<%=qidx%>.user_qos = 1;
    m_iordonce_seq<%=qidx%>.aiu_qos = ioaiu_qos[<%=qidx%>];
    m_iordonce_seq<%=qidx%>.start(m_ioaiu_vseqr<%=qidx%>[0]);

    if(m_iordonce_seq<%=qidx%>.m_seq_item.m_has_data) begin   
       //`uvm_info("TEST_MAIN", $sformatf("read_once address 0x%0h with data = %p", addr, m_iordonce_seq<%=qidx%>.m_seq_item.m_read_data_pkt.rdata), UVM_NONE);
       data = m_iordonce_seq<%=qidx%>.m_seq_item.m_read_data_pkt.rdata[0];
       rresp =  m_iordonce_seq<%=qidx%>.m_seq_item.m_read_data_pkt.rresp;
    end else begin
       data = 0;
       rresp = 0;
    end
  
    if(rresp) begin
        `uvm_error("READ_ONCE",$sformatf("Read address 0x%0h returns resp_err :0x%0h",addr, rresp))
    end
endtask : read_once<%=qidx%>

task concerto_fullsys_qos_test::write_nosnp<%=qidx%>(input ioaiu<%=qidx%>_axi_agent_pkg::axi_axaddr_t addr, input bit[ioaiu<%=qidx%>_axi_agent_pkg::WXDATA-1:0] data, input ioaiu<%=qidx%>_axi_agent_pkg::axi_axlen_t axlen, input ioaiu<%=qidx%>_axi_agent_pkg::axi_awid_t awid, input bit use_user_data=0);
    ioaiu<%=qidx%>_inhouse_axi_bfm_pkg::axi_single_wrnosnp_seq m_iowrnosnp_seq<%=qidx%>;
    bit [ioaiu<%=qidx%>_axi_agent_pkg::WXDATA-1:0] wdata[];
    int addr_mask;
    int addr_offset;
    bit use_incr_data;

    use_incr_data = $test$plusargs("axi_incr_wdata")? 1 : 0;
    wdata = new[axlen+1];

    if(use_user_data == 1) begin
        wdata[0] = data;
        for(int i=1; i<=axlen; i=i+1) begin
            wdata[i] = '0;
        end
    end
    else if(use_incr_data == 1) begin
        foreach(wdata[idx]) begin
            wdata[idx] = addr + (idx*(ioaiu<%=qidx%>_axi_agent_pkg::WXDATA/8));
        end       
    end
    else begin
        foreach(wdata[idx]) begin
            wdata[idx] = $urandom();
        end
    end			  
    addr_mask = (ioaiu<%=qidx%>_axi_agent_pkg::WXDATA/8)-1;
    addr_offset = addr & addr_mask;

    m_iowrnosnp_seq<%=qidx%>   = ioaiu<%=qidx%>_inhouse_axi_bfm_pkg::axi_single_wrnosnp_seq::type_id::create("m_iowrnosnp_seq<%=qidx%>");

    m_iowrnosnp_seq<%=qidx%>.m_addr = addr;
    m_iowrnosnp_seq<%=qidx%>.m_axlen = axlen;
    m_iowrnosnp_seq<%=qidx%>.use_awid = awid;
    m_iowrnosnp_seq<%=qidx%>.user_qos = 1;
    m_iowrnosnp_seq<%=qidx%>.aiu_qos = ioaiu_qos[<%=qidx%>];

    m_iowrnosnp_seq<%=qidx%>.m_data = wdata[0];
    m_iowrnosnp_seq<%=qidx%>.m_wstrb = 'hFFFFFFFFFFFFFFFF;
    //`uvm_info("TEST_MAIN", $sformatf("write_nosnp address 0x%0h with data = %p", addr, m_iowrunq_seq<%=qidx%>.m_data), UVM_NONE);
    m_iowrnosnp_seq<%=qidx%>.start(m_ioaiu_vseqr<%=qidx%>[0]);
endtask : write_nosnp<%=qidx%>

task concerto_fullsys_qos_test::read_nosnp<%=qidx%>(input ioaiu<%=qidx%>_axi_agent_pkg::axi_axaddr_t addr, input ioaiu<%=qidx%>_axi_agent_pkg::axi_axlen_t axlen, input ioaiu<%=qidx%>_axi_agent_pkg::axi_arid_t arid, output bit[ioaiu<%=qidx%>_axi_agent_pkg::WXDATA-1:0] data);
    ioaiu<%=qidx%>_inhouse_axi_bfm_pkg::axi_rdnosnp_seq m_iordnosnp_seq<%=qidx%>;
    bit [ioaiu<%=qidx%>_axi_agent_pkg::WXDATA-1:0] rdata;
    ioaiu<%=qidx%>_axi_agent_pkg::axi_rresp_t rresp;
    int addr_mask;
    int addr_offset;
							
    addr_mask = (ioaiu<%=qidx%>_axi_agent_pkg::WXDATA/8)-1;
    addr_offset = addr & addr_mask;

    m_iordnosnp_seq<%=qidx%>   = ioaiu<%=qidx%>_inhouse_axi_bfm_pkg::axi_rdnosnp_seq::type_id::create("m_iordnosnp_seq<%=qidx%>");
    m_iordnosnp_seq<%=qidx%>.m_addr = addr;
    m_iordnosnp_seq<%=qidx%>.m_len  = axlen;
    m_iordnosnp_seq<%=qidx%>.use_arid = arid;
    m_iordnosnp_seq<%=qidx%>.user_qos = 1;
    m_iordnosnp_seq<%=qidx%>.aiu_qos = ioaiu_qos[<%=qidx%>];
    m_iordnosnp_seq<%=qidx%>.start(m_ioaiu_vseqr<%=qidx%>[0]);

    if(m_iordnosnp_seq<%=qidx%>.m_seq_item.m_has_data) begin   
       //`uvm_info("TEST_MAIN", $sformatf("read_nosnp address 0x%0h with data = %p", addr, m_iordnosnp_seq<%=qidx%>.m_seq_item.m_read_data_pkt.rdata), UVM_NONE);
       data = m_iordnosnp_seq<%=qidx%>.m_seq_item.m_read_data_pkt.rdata[0];
       rresp =  m_iordnosnp_seq<%=qidx%>.m_seq_item.m_read_data_pkt.rresp;
    end else begin
       data = 0;
       rresp = 0;
    end
  
    if(rresp) begin
        `uvm_error("READ_NOSNP",$sformatf("Read address 0x%0h returns resp_err :0x%0h",addr, rresp))
    end
endtask : read_nosnp<%=qidx%>

task concerto_fullsys_qos_test::write_4KB_block<%=qidx%>(input ioaiu<%=qidx%>_axi_agent_pkg::axi_axaddr_t dmi_addr, input int txn_size);
    int num_txns = 4096/txn_size;
    ioaiu<%=qidx%>_axi_agent_pkg::axi_awid_t force_awid;
    int id_incr = 0;
    int m_awid;

    if(!$value$plusargs("force_axid=%d", force_awid)) begin
        force_awid = m_awid;
	id_incr = 1;
    end
				  
    `uvm_info("TEST_MAIN", $sformatf("write_4KB_block<%=qidx%> starting DMI address = 0x%0h, txn_size=%0d, num_txns=%0d", dmi_addr, txn_size, num_txns), UVM_NONE);
    for(int txn=num_txns-1; txn>=0; txn=txn-1) begin
        fork 
           automatic bit [ncoreConfigInfo::W_SEC_ADDR-1:0] m_addr = dmi_addr + (txn*txn_size);
	   automatic ioaiu<%=qidx%>_axi_agent_pkg::axi_awid_t use_awid = force_awid + (txn*id_incr);
           if($test$plusargs("ioaiu<%=qidx%>_noncoherent_test")) begin
              write_nosnp<%=qidx%>(m_addr, m_addr, (txn_size/(ioaiu<%=qidx%>_axi_agent_pkg::WXDATA/8)-1), use_awid, 0);
           end else begin
              write_unq<%=qidx%>(m_addr, m_addr, (txn_size/(ioaiu<%=qidx%>_axi_agent_pkg::WXDATA/8)-1), use_awid, 0);
           end
        join_none  
    end

    m_awid = m_awid + num_txns;
    //wait fork;
endtask : write_4KB_block<%=qidx%>

task concerto_fullsys_qos_test::read_4KB_block<%=qidx%>(input ioaiu<%=qidx%>_axi_agent_pkg::axi_axaddr_t dmi_addr, input int txn_size);
    int num_txns = 4096/txn_size;
    bit[ioaiu<%=qidx%>_axi_agent_pkg::WXDATA-1:0] data;
    //bit [ncoreConfigInfo::W_SEC_ADDR-1:0] poll_addr = use_dii_addr ? dii_addr : (dmi_addr + (num_txns*txn_size));
    ioaiu<%=qidx%>_axi_agent_pkg::axi_arid_t force_arid;
    int id_incr = 0;
    int m_arid = 0;

    if(!$value$plusargs("force_axid=%d", force_arid)) begin
        force_arid = m_arid;
	id_incr = 1;
    end

    `uvm_info("TEST_MAIN", $sformatf("read_4KB_block<%=qidx%> starting DMI address = 0x%0h, txn_size=%0d, num_txns=%0d", dmi_addr, txn_size, num_txns), UVM_NONE);
    for(int txn=(num_txns-1); txn>=0; txn=txn-1) begin
        fork
           automatic bit [ncoreConfigInfo::W_SEC_ADDR-1:0] m_addr = dmi_addr + (txn*txn_size);
	   automatic ioaiu<%=qidx%>_axi_agent_pkg::axi_arid_t use_arid = force_arid + (txn*id_incr);
           if($test$plusargs("ioaiu<%=qidx%>_noncoherent_test")) begin
              read_nosnp<%=qidx%>(m_addr, (txn_size/(ioaiu<%=qidx%>_axi_agent_pkg::WXDATA/8)-1), use_arid, data);
           end else begin
              read_once<%=qidx%>(m_addr, (txn_size/(ioaiu<%=qidx%>_axi_agent_pkg::WXDATA/8)-1), use_arid, data);
           end
        join_none  
    end

    m_arid = m_arid + num_txns;
    //wait fork;
endtask : read_4KB_block<%=qidx%>

task concerto_fullsys_qos_test::writeread_4KB_block<%=qidx%>(input ioaiu<%=qidx%>_axi_agent_pkg::axi_axaddr_t dmi_addr, input int txn_size, int loop_cnt);
    for(int loop=0; loop<loop_cnt; loop=loop+1) begin
       write_4KB_block<%=qidx%>(dmi_addr, txn_size);
       wait fork;
       read_4KB_block<%=qidx%>(dmi_addr, txn_size);
       wait fork;
    end
endtask : writeread_4KB_block<%=qidx%>

<% qidx++; }
 } %>

task concerto_fullsys_qos_test::exec_cache_preload_seq(uvm_phase phase);
   int 	      chiaiu_cache_preload_en[int];
   int 	      ioaiu_cache_preload_en[int];
   string     chiaiu_cache_preload_en_str[];
   string     ioaiu_cache_preload_en_str[];
   string     chiaiu_cache_preload_en_arg;
   string     ioaiu_cache_preload_en_arg;

    if($value$plusargs("chiaiu_cache_preload_en=%s", chiaiu_cache_preload_en_arg)) begin
       parse_str(chiaiu_cache_preload_en_str, "n", chiaiu_cache_preload_en_arg);
       foreach (chiaiu_cache_preload_en_str[i]) begin
	  chiaiu_cache_preload_en[chiaiu_cache_preload_en_str[i].atoi()] = 1;
       end
    end

    if($value$plusargs("ioaiu_cache_preload_en=%s", ioaiu_cache_preload_en_arg)) begin
       parse_str(ioaiu_cache_preload_en_str, "n", ioaiu_cache_preload_en_arg);
       foreach (ioaiu_cache_preload_en_str[i]) begin
	  ioaiu_cache_preload_en[ioaiu_cache_preload_en_str[i].atoi()] = 1;
       end
    end

    fork
  <% 
  var chiaiu_idx = 0;
  var ioaiu_idx = 0;
  for(var pidx = 0; pidx < obj.nAIUs; pidx++) { %>
    <% if((obj.AiuInfo[pidx].fnNativeInterface == 'CHI-A')||(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-B' || obj.AiuInfo[pidx].fnNativeInterface == 'CHI-E')) { %>
		    begin
                `ifdef USE_VIP_SNPS
                   if(vip_snps_coherent_txn || vip_snps_non_coherent_txn) begin
                    //SVT TRAFFIC
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
                    end
                    else begin
                    //m_svt_chi_item.print();
                   `uvm_info(get_name(), "Start m_snps_chi<%=chiaiu_idx%>_vseq", UVM_NONE)
                    //snps_vseq.start(null);
                    m_snps_chi<%=chiaiu_idx%>_vseq.start(null);
                    //done_svt_chi_rn_seq_h<%=chiaiu_idx%>.trigger(null);
                   `uvm_info(get_name(), "Done m_snps_chi<%=chiaiu_idx%>_vseq", UVM_NONE)
                    end
             `else //`ifdef USE_VIP_SNPS
		        if(chiaiu_cache_preload_en.exists(<%=chiaiu_idx%>)) begin
                        `uvm_info("TEST_MAIN", "Start CHIAIU<%=chiaiu_idx%> VSEQ for Cache Preload", UVM_NONE)
                        phase.raise_objection(this, "CHIAIU<%=chiaiu_idx%> cache preload sequence");
                        m_chi<%=chiaiu_idx%>_vseq.start(null);  
                        `uvm_info("TEST_MAIN", "Done CHIAIU<%=chiaiu_idx%> VSEQ for Cache Preload", UVM_NONE)
                        #5us;
                        phase.drop_objection(this, "CHIAIU<%=chiaiu_idx%> cache preload sequence");
			end
                 `endif
                    end
      <% chiaiu_idx++; %>
    <% } else { %>
    <% for(var i=0; i<aiu_NumCores[pidx]; i++) { %>
                    begin
		        if(ioaiu_cache_preload_en.exists(<%=ioaiu_idx%>)) begin
                        phase.raise_objection(this, "IOAIU<%=ioaiu_idx%>[<%=i%>] cache preload sequence");
                        `uvm_info("TEST_MAIN", "Start IOAIU<%=ioaiu_idx%>[<%=i%>] VSEQ for Cache Preload", UVM_NONE)
                        m_iocache_seq<%=ioaiu_idx%>[<%=i%>].start(null);
                        `uvm_info("TEST_MAIN", "Done IOAIU<%=ioaiu_idx%>[<%=i%>] VSEQ for Cache Preload", UVM_NONE)
                        #5us;
                        phase.drop_objection(this, "IOAIU<%=ioaiu_idx%>[<%=i%>] cache preload sequence");
                        end
                    end
	  <% } // foreach core %>
    <% ioaiu_idx++; } %>
  <% } %>
                    begin
                        fork
  <%chiaiu_idx = 0;
  ioaiu_idx = 0;
  for(var pidx = 0; pidx < obj.nAIUs; pidx++) {
    if((obj.AiuInfo[pidx].fnNativeInterface == 'CHI-A')||(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-B' || obj.AiuInfo[pidx].fnNativeInterface == 'CHI-E')) { %>
		        if(chiaiu_cache_preload_en.exists(<%=chiaiu_idx%>)) begin												
                            `ifndef USE_VIP_SNPS
                            ev_chi<%=chiaiu_idx%>_seq_done.wait_trigger();
                            `endif
			end
      <% chiaiu_idx++;
    } else { %>
    <% for(var i=0; i<aiu_NumCores[pidx]; i++) { %>
		        if(ioaiu_cache_preload_en.exists(<%=ioaiu_idx%>)) begin												
                            ev_ioaiu<%=ioaiu_idx%>_<%=i%>_seq_done.wait_trigger();
                            
                        end
	<% } // foreach core %>
    <% ioaiu_idx++; }
  } %>
                        join
                        `uvm_info("TEST_MAIN", "All cache preload sequences DONE", UVM_NONE)
                        ev_sim_done.trigger(null);
                    end
    join

endtask // exec_preload_cache_seq

task concerto_fullsys_qos_test::exec_snoop_seq(uvm_phase phase);
   int 	      chiaiu_snoop_from[int];
   int 	      chiaiu_snoop_to[int];
   int 	      ioaiu_snoop_from[int];
   int 	      ioaiu_snoop_to[int];
   string     chiaiu_snoop_from_str[];
   string     chiaiu_snoop_to_str[];
   string     ioaiu_snoop_from_str[];
   string     ioaiu_snoop_to_str[];
   string     chiaiu_snoop_from_arg;
   string     chiaiu_snoop_to_arg;
   string     ioaiu_snoop_from_arg;
   string     ioaiu_snoop_to_arg;
   int 	      use_user_addrq;
   int        snoop_num_trans;

    if($value$plusargs("chiaiu_snoop_from=%s", chiaiu_snoop_from_arg)) begin
       parse_str(chiaiu_snoop_from_str, "n", chiaiu_snoop_from_arg);
       foreach (chiaiu_snoop_from_str[i]) begin
	  chiaiu_snoop_from[chiaiu_snoop_from_str[i].atoi()] = 1;
       end
    end
    if($value$plusargs("chiaiu_snoop_to=%s", chiaiu_snoop_to_arg)) begin
       parse_str(chiaiu_snoop_to_str, "n", chiaiu_snoop_to_arg);
       foreach (chiaiu_snoop_to_str[i]) begin
	  chiaiu_snoop_to[chiaiu_snoop_to_str[i].atoi()] = 1;
       end
    end

    if($value$plusargs("ioaiu_snoop_from=%s", ioaiu_snoop_from_arg)) begin
       parse_str(ioaiu_snoop_from_str, "n", ioaiu_snoop_from_arg);
       foreach (ioaiu_snoop_from_str[i]) begin
	  ioaiu_snoop_from[ioaiu_snoop_from_str[i].atoi()] = 1;
       end
    end
    if($value$plusargs("ioaiu_snoop_to=%s", ioaiu_snoop_to_arg)) begin
       parse_str(ioaiu_snoop_to_str, "n", ioaiu_snoop_to_arg);
       foreach (ioaiu_snoop_to_str[i]) begin
	  ioaiu_snoop_to[ioaiu_snoop_to_str[i].atoi()] = 1;
       end
    end

    if(!$value$plusargs("snoop_num_trans=%d", snoop_num_trans)) begin
       snoop_num_trans = 64;
    end

    if($value$plusargs("use_user_addrq=%d", use_user_addrq)) begin
        addr_mgr.gen_seq_addr_in_user_addrq(use_user_addrq, 64, 0, -1, ncoreConfigInfo::user_addrq[ncoreConfigInfo::COH]);
	<% var chi_idx=0;
	var io_idx=0;
	for(var pidx=0; pidx<obj.nAIUs; pidx++) {
        if((obj.AiuInfo[pidx].fnNativeInterface == "CHI-A") || (obj.AiuInfo[pidx].fnNativeInterface == "CHI-B" || obj.AiuInfo[pidx].fnNativeInterface == "CHI-E")) { %>
	if((chiaiu_snoop_from.exists(<%=chi_idx%>))||(chiaiu_snoop_to.exists(<%=chi_idx%>))) begin
          `ifndef USE_VIP_SNPS // this will not run with SNPS
           m_chi<%=chi_idx%>_vseq.m_chi_container.user_addrq[ncoreConfigInfo::COH] = ncoreConfigInfo::user_addrq[ncoreConfigInfo::COH];
          `endif 
        end
	<% chi_idx++;
        } else { %>
	if((ioaiu_snoop_from.exists(<%=io_idx%>))||(ioaiu_snoop_to.exists(<%=io_idx%>))) begin
    <% for(var i=0; i<aiu_NumCores[pidx]; i++) { %>
           m_concerto_env.inhouse.m_ace_cache_model_ioaiu<%=io_idx%>[<%=i%>].user_addrq[ncoreConfigInfo::COH] = ncoreConfigInfo::user_addrq[ncoreConfigInfo::COH];
    <% } //foreach core %>    
	end
	<% io_idx++; } 
        } %>
    end // if ($value$plusargs("use_user_addrq=%d", use_user_addrq))

  <% var qidx=0;var idx=0; for(var pidx = 0; pidx < obj.nAIUs; pidx++) { %>
    <% if((obj.AiuInfo[pidx].fnNativeInterface == 'CHI-A')||(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-B' || obj.AiuInfo[pidx].fnNativeInterface == 'CHI-E')) { %>
           `ifndef USE_VIP_SNPS // this flow will not run with SNPS
            m_chi<%=idx%>_args.k_num_requests.set_value(snoop_num_trans);
            m_chi<%=idx%>_args.k_device_type_mem_pct.set_value(0);
            m_chi<%=idx%>_args.k_rd_noncoh_pct.set_value(0);
            m_chi<%=idx%>_args.k_rd_rdonce_pct.set_value(0);
            m_chi<%=idx%>_args.k_wr_noncoh_pct.set_value(0);
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
            m_chi<%=idx%>_args.k_coh_addr_pct.set_value(100);
            m_chi<%=idx%>_args.k_noncoh_addr_pct.set_value(0);
            m_chi<%=idx%>_args.k_wr_cohunq_pct.set_value(0);
            m_chi<%=idx%>_args.k_rd_ldrstr_pct.set_value(100);
            m_chi<%=idx%>_vseq.set_unit_args(m_chi<%=idx%>_args);
            `endif 
      <% idx++;  %>
    <%} else { %>
    <% for(var i=0; i<aiu_NumCores[pidx]; i++) { %>
            m_iocache_seq<%=qidx%>[<%=i%>].k_num_read_req      = snoop_num_trans;
            m_iocache_seq<%=qidx%>[<%=i%>].k_num_write_req     = 0;
      <% if((obj.AiuInfo[pidx].fnNativeInterface == 'ACE') || (obj.AiuInfo[pidx].fnNativeInterface == 'ACE-LITE') || (obj.AiuInfo[pidx].fnNativeInterface == 'ACELITE-E')) { %>
            m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_rdnosnp      = 0;
            m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_rdonce       = 0;
            m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_rdshrd       = 0;
            m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_rdcln        = 0;
            m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_rdnotshrddty = 0;
            m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_wrnosnp      = 0;
            m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_wrlnunq      = 0;
            m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_wrbk         = 0;
            m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_wrevct       = 0;
            m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_clnunq       = 0;
            m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_clnshrd      = 0;
            m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_clninvl      = 0;
            m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_mkunq        = 0;
            m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_mkinvl       = 0;
            m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_evct         = 0;
            m_iocache_seq<%=qidx%>[<%=i%>].no_updates          = 0;
            m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_ptl_stash    = 0;
            m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_full_stash   = 0;
            m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_shared_stash = 0;
            m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_unq_stash    = 0;
            m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_stash_trans  = 0;
            m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_atm_str      = 0;
            m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_atm_ld       = 0;
            m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_atm_swap     = 0;
            m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_atm_comp     = 0;
            m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_dvm_sync     = 0;
            m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_dvm_msg      = 0;
            m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_rd_bar       = 0;
            m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_wr_bar       = 0;
            m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_wrunq        = 0;
            m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_rdunq        = 100;
       <% } // if ACE %>
       <% }// foreach core %>
    <% qidx++; } %>
  <% } %>

    fork
  <% var chiaiu_idx = 0;
  var ioaiu_idx = 0;
  for(var pidx = 0; pidx < obj.nAIUs; pidx++) { %>
    <% if((obj.AiuInfo[pidx].fnNativeInterface == 'CHI-A')||(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-B' || obj.AiuInfo[pidx].fnNativeInterface == 'CHI-E')) { %>
		    begin
                        `ifndef USE_VIP_SNPS // this will work with SNPS
		        if(chiaiu_snoop_from.exists(<%=chiaiu_idx%>)) begin
                        `uvm_info("TEST_MAIN", "Start CHIAIU<%=chiaiu_idx%> Snoop From VSEQ", UVM_NONE)
                        phase.raise_objection(this, "CHIAIU<%=chiaiu_idx%> snoop from sequence");
                        m_chi<%=chiaiu_idx%>_vseq.start(null);  
                        `uvm_info("TEST_MAIN", "Done CHIAIU<%=chiaiu_idx%> Snoop From VSEQ", UVM_NONE)
                        #5us;
                        phase.drop_objection(this, "CHIAIU<%=chiaiu_idx%> snoop from sequence");
		        end
			else if(chiaiu_snoop_to.exists(<%=chiaiu_idx%>)) begin
                        `uvm_info("TEST_MAIN", "Start CHIAIU<%=chiaiu_idx%> Snoop To VSEQ", UVM_NONE)
                        phase.raise_objection(this, "CHIAIU<%=chiaiu_idx%> snoop to sequence");
			#2000ns;
                        m_chi<%=chiaiu_idx%>_vseq.start(null);  
                        `uvm_info("TEST_MAIN", "Done CHIAIU<%=chiaiu_idx%> Snoop To VSEQ", UVM_NONE)
                        #5us;
                        phase.drop_objection(this, "CHIAIU<%=chiaiu_idx%> snoop to sequence");
			end						
                        `endif // USE_VIP_SNPS
                    end
      <% chiaiu_idx++; %>
    <% } else { %>
    <% for(var i=0; i<aiu_NumCores[pidx]; i++) { %>
                    begin
		        if(ioaiu_snoop_from.exists(<%=ioaiu_idx%>)) begin
                        phase.raise_objection(this, "IOAIU<%=ioaiu_idx%>[<%=i%>] snoop from sequence");
                        `uvm_info("TEST_MAIN", "Start IOAIU<%=ioaiu_idx%>[<%=i%>] Snoop From VSEQ", UVM_NONE)
                        m_iocache_seq<%=ioaiu_idx%>[<%=i%>].start(null);
                        `uvm_info("TEST_MAIN", "Done IOAIU<%=ioaiu_idx%>[<%=i%>] Snoop From VSEQ", UVM_NONE)
                        #5us;
                        phase.drop_objection(this, "IOAIU<%=ioaiu_idx%>[<%=i%>] snoop from sequence");
                        end
		        else if(ioaiu_snoop_to.exists(<%=ioaiu_idx%>)) begin
                        phase.raise_objection(this, "IOAIU<%=ioaiu_idx%>[<%=i%>] snoop to sequence");
                        `uvm_info("TEST_MAIN", "Start IOAIU<%=ioaiu_idx%>[<%=i%>] Snoop To VSEQ", UVM_NONE)
                        #1000ns;
                        m_iocache_seq<%=ioaiu_idx%>[<%=i%>].start(null);
                        `uvm_info("TEST_MAIN", "Done IOAIU<%=ioaiu_idx%>[<%=i%>] Snoop To VSEQ", UVM_NONE)
                        #5us;
                        phase.drop_objection(this, "IOAIU<%=ioaiu_idx%>[<%=i%>] snoop to sequence");
                        end
                    end
	<% } // foreach core %>
    <% ioaiu_idx++; } %>
  <% } %>
                    begin
                        fork
  <% chiaiu_idx = 0;
  ioaiu_idx = 0;
  for(var pidx = 0; pidx < obj.nAIUs; pidx++) {
    if((obj.AiuInfo[pidx].fnNativeInterface == 'CHI-A')||(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-B' || obj.AiuInfo[pidx].fnNativeInterface == 'CHI-E')) { %>
                       `ifndef USE_VIP_SNPS
		        if((chiaiu_snoop_from.exists(<%=chiaiu_idx%>))||(chiaiu_snoop_to.exists(<%=chiaiu_idx%>))) begin
                            ev_chi<%=chiaiu_idx%>_seq_done.wait_trigger();
			end
                       `endif // USE_VIP_SNPS 
      <% chiaiu_idx++;
    } else { %>
    <% for(var i=0; i<aiu_NumCores[pidx]; i++) { %>
		        if((ioaiu_snoop_from.exists(<%=ioaiu_idx%>))||(ioaiu_snoop_to.exists(<%=ioaiu_idx%>))) begin
                            ev_ioaiu<%=ioaiu_idx%>_<%=i%>_seq_done.wait_trigger();
                        end
	<% } // foreach core %>
    <% ioaiu_idx++; }
  } %>
                        join
                        `uvm_info("TEST_MAIN", "All snoop sequences DONE", UVM_NONE)
                        ev_sim_done.trigger(null);
                    end
    join

endtask // exec_snoop_seq


task concerto_fullsys_qos_test::exec_qos_seq(uvm_phase phase);

   int num_loop = 1;
   int loop_cnt = 8;
   int axi_chnl_delay[3][4] = '{'{7, 7, 7, 7}, '{10, 6, 4, 3}, '{10, 6, 4, 3}};
   
   <%if (numNCAiu > 2) { %>
   for(int bw_loop=0; bw_loop<num_loop; bw_loop++) begin
      `uvm_info("TEST_MAIN", $sformatf("exec_qos_seq: Starting bw loop %0d", bw_loop), UVM_NONE)
      // set/change delays
      // NCAIU0 is fixed at 25% system BW
//      m_concerto_env_cfg.m_ioaiu0_env_cfg.m_axi_master_agent_cfg.k_ace_master_read_addr_chnl_burst_pct.set_value(0);
//      m_concerto_env_cfg.m_ioaiu0_env_cfg.m_axi_master_agent_cfg.k_ace_master_read_addr_chnl_delay_min.set_value(axi_chnl_delay[0][bw_loop]);
//      m_concerto_env_cfg.m_ioaiu0_env_cfg.m_axi_master_agent_cfg.k_ace_master_read_addr_chnl_delay_max.set_value(axi_chnl_delay[0][bw_loop]);
//      m_concerto_env_cfg.m_ioaiu0_env_cfg.m_axi_master_agent_cfg.k_ace_master_write_addr_chnl_burst_pct.set_value(0);
//      m_concerto_env_cfg.m_ioaiu0_env_cfg.m_axi_master_agent_cfg.k_ace_master_write_addr_chnl_delay_min.set_value(axi_chnl_delay[0][bw_loop]);
//      m_concerto_env_cfg.m_ioaiu0_env_cfg.m_axi_master_agent_cfg.k_ace_master_write_addr_chnl_delay_max.set_value(axi_chnl_delay[0][bw_loop]);
//      m_concerto_env.inhouse.m_ioaiu0_env.m_axi_master_agent.m_cfg.m_vif.ACE_MASTER_READ_ADDR_CHANNEL_BURST_PCT = 0;
//      m_concerto_env.inhouse.m_ioaiu0_env.m_axi_master_agent.m_cfg.m_vif.ACE_MASTER_READ_ADDR_CHANNEL_DELAY_MIN = axi_chnl_delay[0][bw_loop];
//      m_concerto_env.inhouse.m_ioaiu0_env.m_axi_master_agent.m_cfg.m_vif.ACE_MASTER_READ_ADDR_CHANNEL_DELAY_MAX = axi_chnl_delay[0][bw_loop];
//      m_concerto_env.inhouse.m_ioaiu0_env.m_axi_master_agent.m_cfg.m_vif.ACE_MASTER_WRITE_ADDR_CHANNEL_BURST_PCT = 0;
//      m_concerto_env.inhouse.m_ioaiu0_env.m_axi_master_agent.m_cfg.m_vif.ACE_MASTER_WRITE_ADDR_CHANNEL_DELAY_MIN = axi_chnl_delay[0][bw_loop];
//      m_concerto_env.inhouse.m_ioaiu0_env.m_axi_master_agent.m_cfg.m_vif.ACE_MASTER_WRITE_ADDR_CHANNEL_DELAY_MAX = axi_chnl_delay[0][bw_loop];

      // NCAIU1 is changing from 20 -> 30 -> 40 -> 50
//      m_concerto_env_cfg.m_ioaiu1_env_cfg.m_axi_master_agent_cfg.k_ace_master_read_addr_chnl_burst_pct.set_value(0);
//      m_concerto_env_cfg.m_ioaiu1_env_cfg.m_axi_master_agent_cfg.k_ace_master_read_addr_chnl_delay_min.set_value(axi_chnl_delay[1][bw_loop]);
//      m_concerto_env_cfg.m_ioaiu1_env_cfg.m_axi_master_agent_cfg.k_ace_master_read_addr_chnl_delay_max.set_value(axi_chnl_delay[1][bw_loop]);
//      m_concerto_env_cfg.m_ioaiu1_env_cfg.m_axi_master_agent_cfg.k_ace_master_write_addr_chnl_burst_pct.set_value(0);
//      m_concerto_env_cfg.m_ioaiu1_env_cfg.m_axi_master_agent_cfg.k_ace_master_write_addr_chnl_delay_min.set_value(axi_chnl_delay[1][bw_loop]);
//      m_concerto_env_cfg.m_ioaiu1_env_cfg.m_axi_master_agent_cfg.k_ace_master_write_addr_chnl_delay_max.set_value(axi_chnl_delay[1][bw_loop]);
//      m_concerto_env.inhouse.m_ioaiu1_env.m_axi_master_agent.m_cfg.m_vif.ACE_MASTER_READ_ADDR_CHANNEL_BURST_PCT = 0;
//      m_concerto_env.inhouse.m_ioaiu1_env.m_axi_master_agent.m_cfg.m_vif.ACE_MASTER_READ_ADDR_CHANNEL_DELAY_MIN = axi_chnl_delay[1][bw_loop];
//      m_concerto_env.inhouse.m_ioaiu1_env.m_axi_master_agent.m_cfg.m_vif.ACE_MASTER_READ_ADDR_CHANNEL_DELAY_MAX = axi_chnl_delay[1][bw_loop];
//      m_concerto_env.inhouse.m_ioaiu1_env.m_axi_master_agent.m_cfg.m_vif.ACE_MASTER_WRITE_ADDR_CHANNEL_BURST_PCT = 0;
//      m_concerto_env.inhouse.m_ioaiu1_env.m_axi_master_agent.m_cfg.m_vif.ACE_MASTER_WRITE_ADDR_CHANNEL_DELAY_MIN = axi_chnl_delay[1][bw_loop];
//      m_concerto_env.inhouse.m_ioaiu1_env.m_axi_master_agent.m_cfg.m_vif.ACE_MASTER_WRITE_ADDR_CHANNEL_DELAY_MAX = axi_chnl_delay[1][bw_loop];

      // NCAIU2 is changing from 20 -> 30 -> 40 -> 50
//      m_concerto_env_cfg.m_ioaiu2_env_cfg.m_axi_master_agent_cfg.k_ace_master_read_addr_chnl_burst_pct.set_value(0);
//      m_concerto_env_cfg.m_ioaiu2_env_cfg.m_axi_master_agent_cfg.k_ace_master_read_addr_chnl_delay_min.set_value(axi_chnl_delay[2][bw_loop]);
//      m_concerto_env_cfg.m_ioaiu2_env_cfg.m_axi_master_agent_cfg.k_ace_master_read_addr_chnl_delay_max.set_value(axi_chnl_delay[2][bw_loop]);
//      m_concerto_env_cfg.m_ioaiu2_env_cfg.m_axi_master_agent_cfg.k_ace_master_write_addr_chnl_burst_pct.set_value(0);
//      m_concerto_env_cfg.m_ioaiu2_env_cfg.m_axi_master_agent_cfg.k_ace_master_write_addr_chnl_delay_min.set_value(axi_chnl_delay[2][bw_loop]);
//      m_concerto_env_cfg.m_ioaiu2_env_cfg.m_axi_master_agent_cfg.k_ace_master_write_addr_chnl_delay_max.set_value(axi_chnl_delay[2][bw_loop]);
//      m_concerto_env.inhouse.m_ioaiu2_env.m_axi_master_agent.m_cfg.m_vif.ACE_MASTER_READ_ADDR_CHANNEL_BURST_PCT = 0;
//      m_concerto_env.inhouse.m_ioaiu2_env.m_axi_master_agent.m_cfg.m_vif.ACE_MASTER_READ_ADDR_CHANNEL_DELAY_MIN = axi_chnl_delay[2][bw_loop];
//      m_concerto_env.inhouse.m_ioaiu2_env.m_axi_master_agent.m_cfg.m_vif.ACE_MASTER_READ_ADDR_CHANNEL_DELAY_MAX = axi_chnl_delay[2][bw_loop];
//      m_concerto_env.inhouse.m_ioaiu2_env.m_axi_master_agent.m_cfg.m_vif.ACE_MASTER_WRITE_ADDR_CHANNEL_BURST_PCT = 0;
//      m_concerto_env.inhouse.m_ioaiu2_env.m_axi_master_agent.m_cfg.m_vif.ACE_MASTER_WRITE_ADDR_CHANNEL_DELAY_MIN = axi_chnl_delay[2][bw_loop];
//      m_concerto_env.inhouse.m_ioaiu2_env.m_axi_master_agent.m_cfg.m_vif.ACE_MASTER_WRITE_ADDR_CHANNEL_DELAY_MAX = axi_chnl_delay[2][bw_loop];

      fork
      begin
	 automatic int addr_idx0 = bw_loop*loop_cnt*64;
         phase.raise_objection(this, "IOAIU0 sequence");		
         //TMP writeread_4KB_block0(m_concerto_env.inhouse.m_ace_cache_model_ioaiu0.user_addrq[ncoreConfigInfo::COH][addr_idx0], 64, loop_cnt);
         phase.drop_objection(this, "IOAIU0 sequence");		
      end	 
      begin
	 automatic int addr_idx1 = bw_loop*loop_cnt*64;
         phase.raise_objection(this, "IOAIU1 sequence");		
         //TMP writeread_4KB_block1(m_concerto_env.inhouse.m_ace_cache_model_ioaiu1.user_addrq[ncoreConfigInfo::COH][addr_idx1], 64, loop_cnt);
         phase.drop_objection(this, "IOAIU1 sequence");		
      end	 
      begin
	 automatic int addr_idx2 = bw_loop*loop_cnt*64;
         phase.raise_objection(this, "IOAIU2 sequence");		
         //TMP writeread_4KB_block2(m_concerto_env.inhouse.m_ace_cache_model_ioaiu2.user_addrq[ncoreConfigInfo::COH][addr_idx2], 64, loop_cnt);
         phase.drop_objection(this, "IOAIU2 sequence");		
      end	 
      join

      `uvm_info("TEST_MAIN", $sformatf("exec_qos_seq: Finished bw loop %0d", bw_loop), UVM_NONE)
   end // for (bw_loop=0; bw_loop<4; bw_loop++)
			 
<% } %>
	 
endtask // exec_qos_seq


task concerto_fullsys_qos_test::gen_user_addrq();

   `ifndef USE_VIP_SNPS 
   int intrlved_dmis;
   string     alternate_str[];
   string     alternate_arg;
   int 	      idx_offset;
   
   int addr_offsets[<%=obj.nAIUs%>];
   addr_offsets[0] = 0;
   addr_offsets[1] = 'h80;
   addr_offsets[2] = 'hc0;
   addr_offsets[3] = 'h00;
   addr_offsets[4] = 'h40;
   addr_offsets[5] = 'h100;
   addr_offsets[6] = 'h140;
   addr_offsets[7] = 'h180;

   if($test$plusargs("perf_test")) begin
   <% var chi_idx=0; var io_idx=0;
   for(var pidx=0; pidx<obj.nAIUs; pidx++) {
   if((obj.AiuInfo[pidx].fnNativeInterface == "CHI-A") || (obj.AiuInfo[pidx].fnNativeInterface == "CHI-B" || obj.AiuInfo[pidx].fnNativeInterface == "CHI-E")) { %>
      intrlved_dmis = ncoreConfigInfo::intrlvgrp_vector[ncoreConfigInfo::picked_dmi_igs][chiaiu_intrlv_grp];
      if($test$plusargs("run_qos_test")) begin
         addr_mgr.gen_user_coh_addr(<%=obj.AiuInfo[pidx].FUnitId%>, use_user_addrq, m_chi<%=chi_idx%>_vseq.m_chi_container.user_addrq[ncoreConfigInfo::COH]);
      end else if($test$plusargs("dmi_non_intrlv")) begin
				 addr_mgr.gen_seq_dmi_addr_in_user_addrq(use_user_addrq, (<%=chi_idx%>%m_mem.nintrlv_grps[chiaiu_intrlv_grp])*perf_txn_size, chiaiu_intrlv_grp, m_chi<%=chi_idx%>_vseq.m_chi_container.user_addrq[ncoreConfigInfo::COH]);
      end else begin													      
         addr_mgr.gen_seq_addr_in_user_addrq(use_user_addrq, perf_txn_size, chiaiu_intrlv_grp, -1, m_chi<%=chi_idx%>_vseq.m_chi_container.user_addrq[ncoreConfigInfo::COH]);
      end // end dmi_non_intrlv

      if($test$plusargs("user_addrq_shift_index")) begin
         m_chi<%=chi_idx%>_vseq.m_chi_container.user_addrq_idx[ncoreConfigInfo::COH] = <%=chi_idx%>*2;
	 m_chi<%=chi_idx%>_vseq.m_chi_container.user_addrq_idx[ncoreConfigInfo::NONCOH] = <%=chi_idx%>*2;
      end else if (chi_addr_idx_offset[<%=chi_idx%>] != -1) begin // newperf_test:add offset on the address 
         m_chi<%=chi_idx%>_vseq.m_chi_container.user_addrq_idx[ncoreConfigInfo::COH] = chi_addr_idx_offset[<%=chi_idx%>];
         m_chi<%=chi_idx%>_vseq.m_chi_container.user_addrq_idx[ncoreConfigInfo::NONCOH] = chi_addr_idx_offset[<%=chi_idx%>];
      end
      m_chi<%=chi_idx%>_vseq.m_chi_container.user_addrq[ncoreConfigInfo::NONCOH] = m_chi<%=chi_idx%>_vseq.m_chi_container.user_addrq[ncoreConfigInfo::COH];
   <% chi_idx++;
   } else { %>
      intrlved_dmis = ncoreConfigInfo::intrlvgrp_vector[ncoreConfigInfo::picked_dmi_igs][ioaiu_intrlv_grp];
    <% for(var coreidx=0; coreidx<aiu_NumCores[pidx]; coreidx++) { %>
      if($test$plusargs("use_caiu_addrq_for_ncaiu")) begin
      <% if (numChiAiu == 1) { %>
         m_concerto_env.inhouse.m_ace_cache_model_ioaiu<%=io_idx%>[<%=coreidx%>].user_addrq[ncoreConfigInfo::COH] = m_chi0_vseq.m_chi_container.user_addrq[ncoreConfigInfo::COH];
      <% } else if (numChiAiu == 2) { %>
         if(<%=io_idx%>%2) begin
	    m_concerto_env.inhouse.m_ace_cache_model_ioaiu<%=io_idx%>[<%=coreidx%>].user_addrq[ncoreConfigInfo::COH] = m_chi1_vseq.m_chi_container.user_addrq[ncoreConfigInfo::COH];
	 end else begin
	    m_concerto_env.inhouse.m_ace_cache_model_ioaiu<%=io_idx%>[<%=coreidx%>].user_addrq[ncoreConfigInfo::COH] = m_chi0_vseq.m_chi_container.user_addrq[ncoreConfigInfo::COH];
	 end
      <% } else if (numChiAiu == 4) { %>
         if((<%=io_idx%>%4)==3) begin
	    m_concerto_env.inhouse.m_ace_cache_model_ioaiu<%=io_idx%>[<%=coreidx%>].user_addrq[ncoreConfigInfo::COH] = m_chi3_vseq.m_chi_container.user_addrq[ncoreConfigInfo::COH];
	 end else if((<%=io_idx%>%4)==2) begin
	    m_concerto_env.inhouse.m_ace_cache_model_ioaiu<%=io_idx%>[<%=coreidx%>].user_addrq[ncoreConfigInfo::COH] = m_chi2_vseq.m_chi_container.user_addrq[ncoreConfigInfo::COH];
	 end else if((<%=io_idx%>%4)==1) begin
	    m_concerto_env.inhouse.m_ace_cache_model_ioaiu<%=io_idx%>[<%=coreidx%>].user_addrq[ncoreConfigInfo::COH] = m_chi1_vseq.m_chi_container.user_addrq[ncoreConfigInfo::COH];
	 end else begin
	    m_concerto_env.inhouse.m_ace_cache_model_ioaiu<%=io_idx%>[<%=coreidx%>].user_addrq[ncoreConfigInfo::COH] = m_chi0_vseq.m_chi_container.user_addrq[ncoreConfigInfo::COH];
	 end
      <% } %>				      
      end else if($test$plusargs("dmi_non_intrlv")) begin
         if($test$plusargs("use_user_write_read_addrq")) begin	       
            addr_mgr.gen_seq_dmi_addr_in_user_write_read_addrq(use_user_addrq, (<%=io_idx%>%m_mem.nintrlv_grps[ioaiu_intrlv_grp])*perf_txn_size, ioaiu_intrlv_grp, m_concerto_env.inhouse.m_ace_cache_model_ioaiu<%=io_idx%>[<%=coreidx%>].user_write_addrq[ncoreConfigInfo::COH], m_concerto_env.inhouse.m_ace_cache_model_ioaiu<%=io_idx%>[<%=coreidx%>].user_read_addrq[ncoreConfigInfo::COH]);
         end else begin
            if($test$plusargs("use_special_addr_offset")) begin
               addr_mgr.gen_seq_dmi_addr_in_user_addrq(use_user_addrq, addr_offsets[<%=io_idx%>], ioaiu_intrlv_grp, m_concerto_env.inhouse.m_ace_cache_model_ioaiu<%=io_idx%>[<%=coreidx%>].user_addrq[ncoreConfigInfo::COH]);
	        m_concerto_env.inhouse.m_ace_cache_model_ioaiu<%=io_idx%>[<%=coreidx%>].user_addrq[ncoreConfigInfo::NONCOH] = m_concerto_env.inhouse.m_ace_cache_model_ioaiu<%=io_idx%>[<%=coreidx%>].user_addrq[ncoreConfigInfo::COH];
            end else begin			       
               addr_mgr.gen_seq_dmi_addr_in_user_addrq(use_user_addrq, (<%=io_idx%>%m_mem.nintrlv_grps[ioaiu_intrlv_grp])*perf_txn_size, ioaiu_intrlv_grp, m_concerto_env.inhouse.m_ace_cache_model_ioaiu<%=io_idx%>[<%=coreidx%>].user_addrq[ncoreConfigInfo::COH]);
	       m_concerto_env.inhouse.m_ace_cache_model_ioaiu<%=io_idx%>[<%=coreidx%>].user_addrq[ncoreConfigInfo::NONCOH] = m_concerto_env.inhouse.m_ace_cache_model_ioaiu<%=io_idx%>[<%=coreidx%>].user_addrq[ncoreConfigInfo::COH];
            end
        end
     end else begin
        if ($test$plusargs("use_stagger_address")) begin
           //addr_mgr.gen_seq_addr_w_offset_in_user_addrq(use_user_addrq, cacheline_size, stagger_address[<%=io_idx%>%4], ioaiu_intrlv_grp, m_concerto_env.inhouse.m_ace_cache_model_ioaiu<%=io_idx%>.user_addrq[ncoreConfigInfo::COH]);
           addr_mgr.gen_seq_addr_in_user_addrq(use_user_addrq, perf_txn_size, ioaiu_intrlv_grp, <%=io_idx%>%intrlved_dmis, m_concerto_env.inhouse.m_ace_cache_model_ioaiu<%=io_idx%>[<%=coreidx%>].user_addrq[ncoreConfigInfo::COH]);
	   m_concerto_env.inhouse.m_ace_cache_model_ioaiu<%=io_idx%>[<%=coreidx%>].user_addrq[ncoreConfigInfo::NONCOH] = m_concerto_env.inhouse.m_ace_cache_model_ioaiu<%=io_idx%>[<%=coreidx%>].user_addrq[ncoreConfigInfo::COH];
	end else begin
	   if($test$plusargs("use_user_write_read_addrq")) begin	       
              addr_mgr.gen_seq_addr_in_user_write_read_addrq(use_user_addrq, perf_txn_size, ioaiu_intrlv_grp, m_concerto_env.inhouse.m_ace_cache_model_ioaiu<%=io_idx%>[<%=coreidx%>].user_write_addrq[ncoreConfigInfo::COH], m_concerto_env.inhouse.m_ace_cache_model_ioaiu<%=io_idx%>[<%=coreidx%>].user_read_addrq[ncoreConfigInfo::COH]);
           end else begin
	      if ($value$plusargs("ioaiu<%=io_idx%>_alternate_noncoh_test=%s",alternate_arg)) begin:ioaiu<%=io_idx%>_<%=coreidx%>_alternate_noncoh_only_<%=coreidx%>// 2 values: "<nbr tx noncoh mem region N>n<nbr tx noncoh mem region N+1>"
	         parse_str(alternate_str, "n", alternate_arg);
		 foreach (alternate_str[i]) 
                    m_iocache_seq<%=io_idx%>[<%=coreidx%>].nbr_alt_noncoh_only_tx[i] = alternate_str[i].atoi();
                 end:ioaiu<%=io_idx%>_<%=coreidx%>_alternate_noncoh_only_<%=coreidx%>

                 if(!$test$plusargs("ioaiu<%=io_idx%>_seq_case")) begin // newperf_test
                    addr_mgr.gen_seq_addr_in_user_addrq(use_user_addrq, perf_coh_txn_size, ioaiu_intrlv_grp,-1, m_concerto_env.inhouse.m_ace_cache_model_ioaiu<%=io_idx%>[<%=coreidx%>].user_addrq[ncoreConfigInfo::COH],0,1, m_iocache_seq<%=io_idx%>[<%=coreidx%>].nbr_alt_noncoh_only_tx); 
                    addr_mgr.gen_seq_addr_in_user_addrq(use_user_addrq, perf_noncoh_txn_size[0],  ioaiu_intrlv_grp+100+<%=io_idx%>,-1, m_concerto_env.inhouse.m_ace_cache_model_ioaiu<%=io_idx%>[<%=coreidx%>].user_addrq[ncoreConfigInfo::NONCOH],0,0, m_iocache_seq<%=io_idx%>[<%=coreidx%>].nbr_alt_noncoh_only_tx, perf_noncoh_txn_size); 
                 end else if($test$plusargs("ioaiu<%=io_idx%>_random_mem_reg")) begin 
	     	    addr_mgr.gen_seq_addr_in_user_addrq(ioaiu_num_addr[<%=io_idx%>], perf_coh_txn_size, ioaiu_intrlv_grp+100+<%=io_idx%>,-1, m_concerto_env.inhouse.m_ace_cache_model_ioaiu<%=io_idx%>[<%=coreidx%>].user_addrq[ncoreConfigInfo::COH],  1, 1, m_iocache_seq<%=io_idx%>[<%=coreidx%>].nbr_alt_noncoh_only_tx, perf_noncoh_txn_size); 
	     	    addr_mgr.gen_seq_addr_in_user_addrq(ioaiu_num_addr[<%=io_idx%>], perf_noncoh_txn_size[0], ioaiu_intrlv_grp+100+<%=io_idx%>,-1, m_concerto_env.inhouse.m_ace_cache_model_ioaiu<%=io_idx%>[<%=coreidx%>].user_addrq[ncoreConfigInfo::NONCOH], 1, 0, m_iocache_seq<%=io_idx%>[<%=coreidx%>].nbr_alt_noncoh_only_tx, perf_noncoh_txn_size); 
                 end else begin
                    addr_mgr.gen_seq_addr_in_user_addrq(ioaiu_num_addr[<%=io_idx%>], perf_coh_txn_size, ioaiu_intrlv_grp,-1, m_concerto_env.inhouse.m_ace_cache_model_ioaiu<%=io_idx%>[<%=coreidx%>].user_addrq[ncoreConfigInfo::COH],0,1, m_iocache_seq<%=io_idx%>[<%=coreidx%>].nbr_alt_noncoh_only_tx); 
                    addr_mgr.gen_seq_addr_in_user_addrq(ioaiu_num_addr[<%=io_idx%>], perf_noncoh_txn_size[0], ioaiu_intrlv_grp+100+<%=io_idx%>,-1, m_concerto_env.inhouse.m_ace_cache_model_ioaiu<%=io_idx%>[<%=coreidx%>].user_addrq[ncoreConfigInfo::NONCOH],0, 0, m_iocache_seq<%=io_idx%>[<%=coreidx%>].nbr_alt_noncoh_only_tx, perf_noncoh_txn_size); 
                 end // end case ioaiu<%=io_idx%>_seq_case
	      end
	   end
        end
	if($test$plusargs("user_addrq_shift_index")) begin
	   m_concerto_env.inhouse.m_ace_cache_model_ioaiu<%=io_idx%>[<%=coreidx%>].user_addrq_idx[ncoreConfigInfo::COH] = <%=io_idx%>;
	   m_concerto_env.inhouse.m_ace_cache_model_ioaiu<%=io_idx%>[<%=coreidx%>].user_addrq_idx[ncoreConfigInfo::NONCOH] = <%=io_idx%>;
	end else if (ioaiu_addr_idx_offset[<%=io_idx%>] != -1) begin // newperf_test  // add offset // by default = -1
           m_concerto_env.inhouse.m_ace_cache_model_ioaiu<%=io_idx%>[<%=coreidx%>].user_addrq_idx[ncoreConfigInfo::COH]    = ioaiu_addr_idx_offset[<%=io_idx%>];
	   m_concerto_env.inhouse.m_ace_cache_model_ioaiu<%=io_idx%>[<%=coreidx%>].user_addrq_idx[ncoreConfigInfo::NONCOH] = ioaiu_addr_idx_offset[<%=io_idx%>];           
        end    
		<% } //foreach core%>
	<% io_idx++; } %>
        <% } %>
     end // if ($test$plusargs("perf_test"))
     else begin
     <% var chi_idx=0; var io_idx=0;
     for(var pidx=0; pidx<obj.nAIUs; pidx++) {
     if((obj.AiuInfo[pidx].fnNativeInterface == "CHI-A") || (obj.AiuInfo[pidx].fnNativeInterface == "CHI-B" || obj.AiuInfo[pidx].fnNativeInterface == "CHI-E")) { %>
        `ifndef USE_VIP_SNPS
        addr_mgr.gen_user_noncoh_addr(<%=obj.AiuInfo[pidx].FUnitId%>, use_user_addrq, m_chi<%=chi_idx%>_vseq.m_chi_container.user_addrq[ncoreConfigInfo::NONCOH]);
        addr_mgr.gen_user_coh_addr(<%=obj.AiuInfo[pidx].FUnitId%>, use_user_addrq, m_chi<%=chi_idx%>_vseq.m_chi_container.user_addrq[ncoreConfigInfo::COH]);
        `endif 
      <% chi_idx++;
      } else { 
     for(var coreidx=0; coreidx<aiu_NumCores[pidx]; coreidx++) { %>
        addr_mgr.gen_user_noncoh_addr(<%=obj.AiuInfo[pidx].FUnitId%>, use_user_addrq, m_concerto_env.inhouse.m_ace_cache_model_ioaiu<%=io_idx%>[<%=coreidx%>].user_addrq[ncoreConfigInfo::NONCOH]);
        addr_mgr.gen_user_coh_addr(<%=obj.AiuInfo[pidx].FUnitId%>, use_user_addrq, m_concerto_env.inhouse.m_ace_cache_model_ioaiu<%=io_idx%>[<%=coreidx%>].user_addrq[ncoreConfigInfo::COH]);
	 <% } //foreach core%>
      <% io_idx++; } %>
      <% } %>
     end
     
     <% if (numChiAiu > 0) {
     var io_idx=0;
     for(var pidx=0; pidx<obj.nAIUs; pidx++) {
     if((obj.AiuInfo[pidx].fnNativeInterface != "CHI-A") && (obj.AiuInfo[pidx].fnNativeInterface != "CHI-B" && obj.AiuInfo[pidx].fnNativeInterface != "CHI-E")) { %>
     if(ioaiu<%=io_idx%>_collision_pct > 0) begin
        ioaiu<%=io_idx%>_num_collision = int'(real'(use_user_addrq * (real'(ioaiu<%=io_idx%>_collision_pct)/100.00)));
        `uvm_info("TEST_MAIN", $sformatf("ioaiu<%=io_idx%>_collision_pct=%0d, ioaiu<%=io_idx%>_num_collision=%0d, use_user_addrq=%0d", ioaiu<%=io_idx%>_collision_pct, ioaiu<%=io_idx%>_num_collision, use_user_addrq), UVM_NONE)
         for(int idx=0; idx<ioaiu<%=io_idx%>_num_collision; idx++) begin
            idx_offset = (<%=io_idx%>+1)*100;
             <% for(var coreidx=0; coreidx<aiu_NumCores[pidx]; coreidx++) { %>
            m_concerto_env.inhouse.m_ace_cache_model_ioaiu<%=io_idx%>[<%=coreidx%>].user_addrq[ncoreConfigInfo::COH][idx+idx_offset+20] = m_chi0_vseq.m_chi_container.user_addrq[ncoreConfigInfo::COH][idx+idx_offset];
          <% } //foreach core %>
	      end
     end
     <% io_idx++; }
     } } %>


 `endif
endtask //gen_user_addrq

