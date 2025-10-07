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
var numBootIoAiu = 0; // Number of NCAIUs can participate in Boot
var chiaiu0;  // strRtlNamePrefix of chiaiu0
var aceaiu0;  // strRtlNamePrefix of aceaiu0
var ncaiu0;   // strRtlNamePrefix of aceaiu0
var idxIoAiuWithPC = obj.nAIUs; // To get valid index of NCAIU with ProxyCache. Initialize to nAIUs
var numDmiWithSMC = 0; // Number of DMIs with SystemMemoryCache
var idxDmiWithSMC = 0; // To get valid index of DMI with SystemMemoryCache
var numDmiWithSP = 0; // Number of DMIs with ScratchPad memory
var idxDmiWithSP = 0; // To get valid index of DMIs with ScratchPad memory
var numDmiWithWP = 0; // Number of DMIs with WayPartitioning
var idxDmiWithWP = 0; // To get valid index of DMIs with WayPartitioning
var noBootIoAiu = 1;
const BootIoAiu = [];
var found_csr_access_chiaiu=0;
var found_csr_access_ioaiu=0;
var csrAccess_ioaiu;
var csrAccess_chiaiu;
const aiu_axiInt = [];
var dmi_width= [];
var AiuCore;
var initiatorAgents   = obj.AiuInfo.length ;
var aiu_NumCores = [];
var aiu_rpn = [];
var dce_rpn = [];
var dmi_rpn = [];
const aiuName = [];

   var _blkid = [];
   var _blkportsid =[];
   var _blk   = [{}];
   var _idx = 0;
   var aiu_idx = 0;
   obj.nAIUs_mpu =0; 
   
   for(var pidx = 0; pidx < obj.nAIUs; pidx++) {
      if(!Array.isArray(obj.AiuInfo[pidx].interfaces.axiInt)) {
       _blk[_idx]   = obj.AiuInfo[pidx];
       _blkid[_idx] = 'aiu' + aiu_idx;
       _blkportsid[_idx] = 0;
       obj.nAIUs_mpu++;
       aiu_idx++;
       _idx++;
       } else {
       for (var port_idx = 0; port_idx < obj.AiuInfo[pidx].nNativeInterfacePorts; port_idx++) {
        _blk[_idx]   = obj.AiuInfo[pidx];
        _blkid[_idx] = 'aiu' + aiu_idx ;
        _blkportsid[_idx] = port_idx;
        _idx++;
        obj.nAIUs_mpu++;
        }
        aiu_idx++;
       }
   }

 for(var pidx = 0; pidx < initiatorAgents; pidx++) { 
   if(Array.isArray(obj.AiuInfo[pidx].interfaces.axiInt)) {
       aiu_NumCores[pidx]    = obj.AiuInfo[pidx].interfaces.axiInt.length;
       aiu_rpn[pidx]= obj.AiuInfo[pidx].rpn[0];
   } else {
       aiu_NumCores[pidx]    = 1;
       aiu_rpn[pidx]= obj.AiuInfo[pidx].rpn;
   }
 }

for(var pidx = 0; pidx < obj.nAIUs; pidx++) {
    if(Array.isArray(obj.AiuInfo[pidx].interfaces.axiInt)) {
        aiu_axiInt[pidx] = obj.AiuInfo[pidx].interfaces.axiInt[0];
        AiuCore = 'ioaiu_core0';
    } else {
        aiu_axiInt[pidx] = obj.AiuInfo[pidx].interfaces.axiInt;
        AiuCore = 'ioaiu_core0';
    }
}

for(var pidx = 0; pidx < obj.nDMIs; pidx++) {
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
for(var pidx = 0; pidx < obj.nDIIs; pidx++) {
    pma_en_dii_blk &= obj.DiiInfo[pidx].usePma;
    pma_en_at_least_1_blk |= obj.DiiInfo[pidx].usePma;
}
for(var pidx = 0; pidx < obj.nDCEs; pidx++) {
    dce_rpn[pidx] = obj.DceInfo[pidx].rpn;
}
// Assuming CHI AIU will appear first in AiuInfo in top.level.dv.json before IO-AIUs
var chi_idx=0;
var io_idx=0;
for(var pidx = 0; pidx < obj.nAIUs; pidx++) {
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
for(var pidx = 0; pidx < obj.nDCEs; pidx++) {
    pma_en_dce_blk &= obj.DceInfo[pidx].usePma;
    pma_en_at_least_1_blk |= obj.DceInfo[pidx].usePma;
}
for(var pidx = 0; pidx < obj.nDVEs; pidx++) {
    pma_en_dve_blk &= obj.DveInfo[pidx].usePma;
    pma_en_at_least_1_blk |= obj.DveInfo[pidx].usePma;
}
pma_en_all_blk = pma_en_dmi_blk & pma_en_dii_blk & pma_en_aiu_blk & pma_en_dce_blk & pma_en_dve_blk;

%>

//File: concerto_fullsys_test.svh

<%  if((obj.INHOUSE_OCP_VIP)) { %>
import ocp_agent_pkg::*;
<%  } %>

`ifdef CHI_UNITS_CNT_NON_ZERO
import chi_subsys_pkg::*;
`endif

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


class concerto_fullsys_performance_test extends concerto_fullsys_test; 

  `uvm_component_utils(concerto_fullsys_performance_test)
 
  function new(string name = "concerto_fullsys_performance_test", uvm_component parent=null);
    super.new(name,parent);
    user_write_addrq = new[addrMgrConst::user_addrq.size()];
    user_read_addrq = new[addrMgrConst::user_addrq.size()];

  endfunction: new

  // UVM PHASE
  extern function void build_phase(uvm_phase phase);
  extern task run_phase (uvm_phase phase);
  extern function void start_of_simulation_phase (uvm_phase phase); 
  extern task exec_inhouse_seq (uvm_phase phase);
  extern function void hook_aiu_en();
  extern function void set_all_addrq();


  <% for(var qidx = 0 ; qidx < obj.nDMIs; qidx++) { %> <% if (obj.DmiInfo[qidx].useCmc){ %>
  extern task dmi<%=qidx%>_flush_cache();
  <% } %><% } %>
  extern task flush_all_dmi_cache();

  <%for(var pidx = 0; pidx < obj.nAIUs; pidx++) { %>
  uvm_event ev_wait_completion_of_seq_aiu<%=pidx%> = ev_pool.get("ev_wait_completion_of_seq_aiu<%=pidx%>");
  <% } %>

  int max_iteration=1;

  addrMgrConst::addrq user_write_addrq[];
  addrMgrConst::addrq user_read_addrq[];
<%
  qidx = 0;
  for(pidx=0; pidx<obj.nAIUs; pidx++) {
    if(!(obj.AiuInfo[pidx].fnNativeInterface.includes('CHI'))) {
      if(1) { // obj.AiuInfo[pidx].useCache) { 
%>
        ioaiu<%=qidx%>_inhouse_axi_bfm_pkg::axi_master_pipelined_seq        m_ioaiu_init_proxycache_seq<%=qidx%>[<%=aiu_NumCores[pidx]%>];
<%
      } 
      qidx++;
    } 
  } 
%>
endclass: concerto_fullsys_performance_test


//METHOD Definitions
///////////////////////////////////////////////////////////////////////////////// 
// #     #  #     #  #     #         ######   #     #     #      #####   #######  
// #     #  #     #  ##   ##         #     #  #     #    # #    #     #  #        
// #     #  #     #  # # # #         #     #  #     #   #   #   #        #        
// #     #  #     #  #  #  #         ######   #######  #     #   #####   #####    
// #     #   #   #   #     #         #        #     #  #######        #  #        
// #     #    # #    #     #         #        #     #  #     #  #     #  #        
//  #####      #     #     #  #####  #        #     #  #     #   #####   #######  
///////////////////////////////////////////////////////////////////////////////// 

function void concerto_fullsys_performance_test::build_phase(uvm_phase phase);
    super.build_phase(phase);
endfunction : build_phase


task concerto_fullsys_performance_test::run_phase (uvm_phase phase); 
  super.run_phase(phase);
endtask:run_phase

function void concerto_fullsys_performance_test::start_of_simulation_phase (uvm_phase phase); 
  string label;
  $value$plusargs("label=%s", label);

  super.start_of_simulation_phase(phase);
      <%
        qidx = 0;
        for(pidx=0; pidx<obj.nAIUs; pidx++) {
          if(!(obj.AiuInfo[pidx].fnNativeInterface.includes('CHI'))) {
            if(1) { //obj.AiuInfo[pidx].fnNativeInterface == 'ACE') { 
              for(var i=0; i<aiu_NumCores[pidx]; i++) {
      %>
          fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_seq<%=qidx%>[<%=i%>].no_updates = 1;
      <%
              }
            } 
            qidx++;
          } 
        } 
      %>

      <%
        qidx = 0;
        for(pidx=0; pidx<obj.nAIUs; pidx++) {
          if(!(obj.AiuInfo[pidx].fnNativeInterface.includes('CHI'))) {
            if(1) { //obj.AiuInfo[pidx].useCache) { 
              for(var i=0; i<aiu_NumCores[pidx]; i++) {
      %>  
      m_ioaiu_init_proxycache_seq<%=qidx%>[<%=i%>] = ioaiu<%=qidx%>_inhouse_axi_bfm_pkg::axi_master_pipelined_seq::type_id::create("m_ioaiu<%=qidx%>_init_pc_seq");

      m_ioaiu_init_proxycache_seq<%=qidx%>[<%=i%>].core_id = <%=i%>;
      m_ioaiu_init_proxycache_seq<%=qidx%>[<%=i%>].set_seq_name("m_ioaiu<%=qidx%>_seq[<%=i%>]");

      m_ioaiu_init_proxycache_seq<%=qidx%>[<%=i%>].m_read_addr_chnl_seqr  = m_concerto_env.inhouse.m_ioaiu<%=qidx%>_env.m_env[<%=i%>].m_axi_master_agent.m_read_addr_chnl_seqr;
      m_ioaiu_init_proxycache_seq<%=qidx%>[<%=i%>].m_read_data_chnl_seqr  = m_concerto_env.inhouse.m_ioaiu<%=qidx%>_env.m_env[<%=i%>].m_axi_master_agent.m_read_data_chnl_seqr;
      m_ioaiu_init_proxycache_seq<%=qidx%>[<%=i%>].m_write_addr_chnl_seqr = m_concerto_env.inhouse.m_ioaiu<%=qidx%>_env.m_env[<%=i%>].m_axi_master_agent.m_write_addr_chnl_seqr;
      m_ioaiu_init_proxycache_seq<%=qidx%>[<%=i%>].m_write_data_chnl_seqr = m_concerto_env.inhouse.m_ioaiu<%=qidx%>_env.m_env[<%=i%>].m_axi_master_agent.m_write_data_chnl_seqr;
      m_ioaiu_init_proxycache_seq<%=qidx%>[<%=i%>].m_write_resp_chnl_seqr = m_concerto_env.inhouse.m_ioaiu<%=qidx%>_env.m_env[<%=i%>].m_axi_master_agent.m_write_resp_chnl_seqr;
      m_ioaiu_init_proxycache_seq<%=qidx%>[<%=i%>].m_ace_cache_model      = m_concerto_env.inhouse.m_ace_cache_model_ioaiu<%=qidx%>[<%=i%>];

      m_ioaiu_init_proxycache_seq<%=qidx%>[<%=i%>].k_num_read_req         = 0;
      m_ioaiu_init_proxycache_seq<%=qidx%>[<%=i%>].k_num_write_req        = ioaiu_num_trans;

      m_ioaiu_init_proxycache_seq<%=qidx%>[<%=i%>].wt_ace_wrnosnp      = 0;
      m_ioaiu_init_proxycache_seq<%=qidx%>[<%=i%>].wt_ace_rdnosnp      = 0;
      m_ioaiu_init_proxycache_seq<%=qidx%>[<%=i%>].wt_ace_wrlnunq      = 0;
      m_ioaiu_init_proxycache_seq<%=qidx%>[<%=i%>].wt_ace_wrunq        = 0;
      m_ioaiu_init_proxycache_seq<%=qidx%>[<%=i%>].wt_ace_clnunq       = 0;
      m_ioaiu_init_proxycache_seq<%=qidx%>[<%=i%>].wt_ace_rdshrd       = 0;
      m_ioaiu_init_proxycache_seq<%=qidx%>[<%=i%>].wt_ace_rdcln        = 0;
      m_ioaiu_init_proxycache_seq<%=qidx%>[<%=i%>].wt_ace_rdnotshrddty = 0;
      m_ioaiu_init_proxycache_seq<%=qidx%>[<%=i%>].wt_ace_rdunq        = 0;
      m_ioaiu_init_proxycache_seq<%=qidx%>[<%=i%>].wt_ace_rdonce       = 0;
      m_ioaiu_init_proxycache_seq<%=qidx%>[<%=i%>].wt_ace_rd_cln_invld = 0;
      m_ioaiu_init_proxycache_seq<%=qidx%>[<%=i%>].wt_ace_ptl_stash    = 0;
      m_ioaiu_init_proxycache_seq<%=qidx%>[<%=i%>].wt_ace_clnshrd_pers = 0;                 
      m_ioaiu_init_proxycache_seq<%=qidx%>[<%=i%>].wt_ace_clnshrd      = 0;
      m_ioaiu_init_proxycache_seq<%=qidx%>[<%=i%>].wt_ace_clninvl      = 0;
      m_ioaiu_init_proxycache_seq<%=qidx%>[<%=i%>].wt_ace_mkinvl       = 0;
      m_ioaiu_init_proxycache_seq<%=qidx%>[<%=i%>].wt_ace_mkunq        = 0;
      m_ioaiu_init_proxycache_seq<%=qidx%>[<%=i%>].wt_ace_dvm_msg      = 0;
      m_ioaiu_init_proxycache_seq<%=qidx%>[<%=i%>].wt_ace_dvm_sync     = 0;
      m_ioaiu_init_proxycache_seq<%=qidx%>[<%=i%>].wt_ace_rd_bar        = 0;
      m_ioaiu_init_proxycache_seq<%=qidx%>[<%=i%>].wt_ace_rd_make_invld = 0;


      if($test$plusargs("coherent_test") && <%=obj.AiuInfo[pidx].fnNativeInterface.includes('AXI4') ? `1'b0`: `1'b1`%> ) begin
        m_ioaiu_init_proxycache_seq<%=qidx%>[<%=i%>].wt_ace_wrunq        = 100;
      end else begin
        m_ioaiu_init_proxycache_seq<%=qidx%>[<%=i%>].wt_ace_wrnosnp      = 100;
      end

      m_ioaiu_init_proxycache_seq<%=qidx%>[<%=i%>].k_directed_test = 1;
      m_ioaiu_init_proxycache_seq<%=qidx%>[<%=i%>].k_directed_test_alloc = 1;
      m_ioaiu_init_proxycache_seq<%=qidx%>[<%=i%>].use_axcache_from_test = 1;
      <%
              }
            } %>
      //setting specific waits for snoop tests
      if($test$plusargs("coherent_test") && $test$plusargs("read_test")) begin
          <%if(!((obj.AiuInfo[pidx].fnNativeInterface == 'AXI4' && obj.AiuInfo[pidx].useCache == 1 && aiu_NumCores[pidx] == 1) || 
                  (obj.AiuInfo[pidx].fnNativeInterface == 'ACELITE-E' && obj.AiuInfo[pidx].interfaces.axiInt.params.enableDVM == true))) {%>
        if(label =="perf_test_flav_r_c_seq_snp_ace_lite_dvm2axiP_0ns_0") begin
            <%for(var i=0; i<aiu_NumCores[pidx]; i++) {%>    
          fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_seq<%=qidx%>[<%=i%>].k_num_read_req      = 0;
            <%} %>
        end
          <%} %>
        <%if(obj.AiuInfo[pidx].fnNativeInterface == 'ACE') { 
            for(var i=0; i<aiu_NumCores[pidx]; i++) { %>
        if(label =="perf_test_flav_r_c_seq_snp_ace_lite2ace_0ns_0") begin
          fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_rdunq        = 100;
          fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_rdonce       = 0;
          m_concerto_env.inhouse.m_ace_cache_model_ioaiu<%=qidx%>[<%=i%>].prob_dataxfer_snp_resp_on_clean_hit       = 100;
        end else begin
          fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_rdunq        = 0;
          fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_rdonce       = 100;
        end
           <%}%>
        <%} else if(obj.AiuInfo[pidx].fnNativeInterface == 'AXI4' && obj.AiuInfo[pidx].useCache) {
              for(var i=0; i<aiu_NumCores[pidx]; i++) { %>
          if(label =="perf_test_flav_r_c_seq_snp_ace_lite_dvm2axiP_0ns_0") begin
            fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_rdnosnp      = 0;
            fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_rdunq        = 0;
            fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_rdonce       = 100;
          end
          <%}%>
        <%} else { 
              for(var i=0; i<aiu_NumCores[pidx]; i++) { %>
          fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_rdunq        = 0;
          fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_seq<%=qidx%>[<%=i%>].wt_ace_rdonce       = 100;
          <%}%>
        <%}%>
      end

       <%     qidx++;
          } 
        } 
      %>


endfunction:start_of_simulation_phase




function void concerto_fullsys_performance_test::hook_aiu_en();

    if($test$plusargs("en_all_coherent_ioaiu") || $test$plusargs("en_all_coherent_aiu")) begin
      foreach(chiaiu_en[i]) chiaiu_en[i]  = 0;
      foreach(ioaiu_en[i])  ioaiu_en[i]   = 0;
    end

    if($test$plusargs("en_all_coherent_aiu")) begin
      <% var chiaiu_idx=0; for(var pidx = 0 ; pidx < obj.nAIUs; pidx++) { if((obj.AiuInfo[pidx].fnNativeInterface.includes('CHI'))) { %>
      chiaiu_en[<%=chiaiu_idx%>] = 1;<% chiaiu_idx++; }} %>
    end

    if($test$plusargs("en_all_coherent_ioaiu") || $test$plusargs("en_all_coherent_aiu")) begin
      <% var ioaiu_idx=0; for(var pidx = 0 ; pidx < obj.nAIUs; pidx++) { if(!(obj.AiuInfo[pidx].fnNativeInterface.includes('CHI'))) { %>
          <% if((obj.AiuInfo[pidx].fnNativeInterface === "ACELITE-E") || (obj.AiuInfo[pidx].fnNativeInterface === "ACE-LITE") || (obj.AiuInfo[pidx].fnNativeInterface == "ACE") || ((obj.AiuInfo[pidx].fnNativeInterface == "AXI4") && (obj.AiuInfo[pidx].useCache))) { %>
      ioaiu_en[<%=ioaiu_idx%>] = 1; <% } ioaiu_idx++; } } %>
    end
endfunction : hook_aiu_en

task concerto_fullsys_performance_test::exec_inhouse_seq(uvm_phase phase); // BY default launch random txn
  

  phase.raise_objection(this, "exec_inhouse_seq");
  `uvm_info("FULL_SYS_TEST", "Start exec_inhouse_seq", UVM_LOW)

   main_seq_pre_hook(phase);

  #100ns; 

  if ($test$plusargs("use_seq_user_addrq")) begin:_use_user_addrq
      gen_addr_use_user_addrq();

      if ($test$plusargs("use_user_rw_addrq") && $test$plusargs("individual_initiator_addrq")) begin
        int j,k;
        foreach(addrMgrConst::user_addrq[coh_noncoh]) begin
          j=0;k=0;

          if(addrMgrConst::user_addrq[coh_noncoh].size() == 0) continue;

          for(int i = <%=obj.nCHIs%> * test_cfg.chi_num_trans ; i < use_user_addrq ; i++) begin
            if ((i % 2) == 1) begin
              user_write_addrq[coh_noncoh].push_back(addrMgrConst::user_addrq[coh_noncoh][i]);
              j++;
            end else begin
              user_read_addrq[coh_noncoh].push_back(addrMgrConst::user_addrq[coh_noncoh][i]);
              k++;
            end
            
          end
        end

        set_all_addrq();

      end
  end:_use_user_addrq

  for (iter = 0; iter < max_iteration ; iter++ ) begin: _iteration_loop

    if (iter>0) begin
      #10us;
    end

    main_seq_iter_pre_hook (phase,iter);

    <%var chiaiu_idx = 0;%>

    if($test$plusargs("init_all_cache")) begin

      `uvm_info("FULLSYS_TEST", "Starting initializing caches DMI SMCs and AIU Proxy Caches", UVM_NONE)
      fork

        begin
          `uvm_info("FULLSYS_TEST", "Start CHIAIU VSEQ for init DMI SMC purpose", UVM_NONE)
          `ifdef CHI_UNITS_CNT_NON_ZERO
            // start the CHI subsys virtual sequence
            fsys_main_traffic_vseq.chi_traffic_snps_vseq.init_all_cache = use_user_addrq;
            fsys_main_traffic_vseq.chi_traffic_snps_vseq.chi_num_trans = test_cfg.chi_num_trans;
            //fsys_main_traffic_vseq.chi_traffic_snps_vseq.init_from_chiaiu_idx = 0;
            fsys_main_traffic_vseq.chi_traffic_snps_vseq.start(null);
            fsys_main_traffic_vseq.chi_traffic_snps_vseq.init_all_cache  = 0;
          `endif
          `uvm_info("FULLSYS_TEST", "End of CHIAIU VSEQ for init DMI SMC purpose", UVM_NONE)
        end
        
        begin
          fork
            <% qidx = 0;
              for(pidx=0; pidx<obj.nAIUs; pidx++) {
                if(!(obj.AiuInfo[pidx].fnNativeInterface.includes('CHI'))) {
                  if(1) { //obj.AiuInfo[pidx].useCache) { 
                    for(var i=0; i<aiu_NumCores[pidx]; i++) { %>
              begin
                `uvm_info("FULLSYS_TEST", "Start VSEQ for init IOAIU<%=qidx%>[<%=i%>] ProxyCache purpose", UVM_NONE)
                m_ioaiu_init_proxycache_seq<%=qidx%>[<%=i%>].wait_ev_sim_done = 1'b0;
                m_ioaiu_init_proxycache_seq<%=qidx%>[<%=i%>].start(null);
              end

              begin
                ev_ioaiu<%=qidx%>_seq_done[<%=i%>].wait_trigger();
                `uvm_info("FULLSYS_TEST", "End of VSEQ for init IOAIU<%=qidx%>[<%=i%>] ProxyCache purpose", UVM_NONE)
                foreach(m_concerto_env.inhouse.m_ace_cache_model_ioaiu<%=qidx%>[<%=i%>].user_addrq_idx[i]) begin
                  m_concerto_env.inhouse.m_ace_cache_model_ioaiu<%=qidx%>[<%=i%>].user_addrq_idx[i]       = 0;
                  m_concerto_env.inhouse.m_ace_cache_model_ioaiu<%=qidx%>[<%=i%>].user_write_addrq_idx[i] = 0;
                  m_concerto_env.inhouse.m_ace_cache_model_ioaiu<%=qidx%>[<%=i%>].user_read_addrq_idx[i]  = 0;
                end

                ev_ioaiu<%=qidx%>_seq_done[<%=i%>].reset();
              end
            <%      }
                  }  qidx++;
                } 
              } %>
          join
        end

      join

      #1us;
      //ev_sim_done.trigger(null);
      //#1ns;
      //ev_sim_done.reset();
      
      `uvm_info("FULLSYS_TEST", "Finished initializing caches DMI SMCs and AIU Proxy Caches", UVM_NONE)

    end


  // trigger csr_init_done to unit scoreboards
  csr_init_done.trigger(null);

    fork:_exec_fork

      fork:_start_all_seq

        if (m_concerto_env_cfg.has_chi_vip_snps) begin:_chiaiu_vip
          phase.raise_objection(this, "USE_VIP_SNPS CHIAIU sequence");

          `ifdef CHI_UNITS_CNT_NON_ZERO
            // start the CHI subsys virtual sequence
            chi_ss_helper_pkg::k_disable_boot_addr = 1;

            `uvm_info("FULLSYS_TEST", "Start CHIAIU VSEQ", UVM_NONE)
            fsys_main_traffic_vseq.chi_traffic_snps_vseq.chi_num_trans = test_cfg.chi_num_trans;
            fsys_main_traffic_vseq.chi_traffic_snps_vseq.chiaiu_en = chiaiu_en;
            fsys_main_traffic_vseq.chi_traffic_snps_vseq.start(null);
            `uvm_info("FULLSYS_TEST", "End of CHIAIU VSEQ", UVM_NONE)
          `endif

            if($test$plusargs("dmi_flush")) begin // FLUSH DMI CACHEs
              flush_all_dmi_cache();
            end

          <%for(let idx = 0; idx < obj.nCHIs; idx++) { %>
              done_svt_chi_rn_seq_h<%=idx%>.trigger(null);
          <%}%>

          phase.drop_objection(this, "USE_VIP_SNPS CHIAIU sequence");
        end:_chiaiu_vip

         <% 
         var chiaiu_idx = 0; var ioaiu_idx = 0; var ioaiu_idx_with_multi_core = 0;

         for(var pidx = 0; pidx < obj.nAIUs; pidx++) { %>
            <% if (obj.AiuInfo[pidx].fnNativeInterface.includes('CHI')) { %>
              <% chiaiu_idx++; %>
            <% } else { %>
              <% for(var i=0; i<aiu_NumCores[pidx]; i++) { %>
              if (m_concerto_env_cfg.has_axi_vip_snps && ioaiu_en.exists(<%=ioaiu_idx%>) && ioaiu_en[<%=ioaiu_idx%>]) begin: _ioaiu<%=ioaiu_idx%>_<%=i%>_vip // TODO remove to use only one virtual seq
                  //SVT TRAFFIC
                  phase.raise_objection(this, "USE_VIP_SNPS IOAIU<%=ioaiu_idx%> sequence");
                  uvm_config_db#(svt_axi_port_configuration)::set(null, "*", "port_cfg_ioaiu<%=ioaiu_idx%>_<%=i%>", m_concerto_env_cfg.svt_cfg.axi_sys_cfg[0].master_cfg[<%=(aiu_rpn[pidx]+i)-chi_idx%>]);

                  <%if( pidx > 0 ) { %>
                  if($test$plusargs("sequential")) begin
                    ev_wait_completion_of_seq_aiu<%=pidx-1%>.wait_ptrigger();
                  end
                  <%}%>

                  if(ioaiu_num_trans > 0) begin
                    if($test$plusargs("use_legacy_ioaiu_seq")) begin
                        `uvm_info("TEST_MAIN", "USE_VIP_SNPS START cust_seq_h<%=ioaiu_idx%>[<%=i%>]", UVM_NONE)
                        cust_seq_h<%=ioaiu_idx%>[<%=i%>].start(m_concerto_env.snps.svt.amba_system_env.axi_system[0].sequencer);
                    end
                    else begin
                    <% if (numIoAiu > 0) { %> 
                      `uvm_info(get_name(),"IOAIU subsys random sequence enabled by plusarg-use_legacy_ioaiu_seq",UVM_NONE)
                      run_ioaiu_test_seq(conc_ioaiu_name_array[<%=ioaiu_idx_with_multi_core%>],<%=ioaiu_idx_with_multi_core%>);
                    <% } %>
                    end
                  end
                  #1us;
                  done_snp_cust_seq_h<%=ioaiu_idx%>.trigger(null);
                  `uvm_info("TEST_MAIN", "USE_VIP_SNPS DONE cust_seq_h<%=ioaiu_idx%>[<%=i%>]", UVM_NONE)
                  phase.drop_objection(this, "USE_VIP_SNPS IOAIU<%=ioaiu_idx%> sequence");

                  if($test$plusargs("sequential")) begin
                    if($test$plusargs("dmi_flush")) begin
                      flush_all_dmi_cache();
                    end
                  end
                  ev_wait_completion_of_seq_aiu<%=pidx%>.trigger();

              end: _ioaiu<%=ioaiu_idx%>_<%=i%>_vip
              else begin:_ioaiu<%=ioaiu_idx%>_<%=i%>_inhouse

                //ev_wait_completion_of_seq_aiu<%=pidx%>.trigger();

              end:_ioaiu<%=ioaiu_idx%>_<%=i%>_inhouse
             <% ioaiu_idx_with_multi_core = ioaiu_idx_with_multi_core + 1;} // foreach core %> 

          <%  ioaiu_idx++; } %>
       <% } // foreach AIUs %>


        `ifdef IO_UNITS_CNT_NON_ZERO
          begin
            if (!m_concerto_env_cfg.has_axi_vip_snps )
            begin: _ioaiu_inhouse
              //fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.no_snoop_seq = 1;
              `uvm_info(get_name(), "Starting IOAIU Traffic with Inhouse Sequences", UVM_LOW)
              fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.start(null);
              `uvm_info(get_name(), "Fineshed IOAIU Traffic with Inhouse Sequences", UVM_LOW)
              if($test$plusargs("sequential"))
              begin
                if($test$plusargs("dmi_flush"))
                begin
                  flush_all_dmi_cache();
                end
              end

            end: _ioaiu_inhouse
          end
        `endif



        begin:_wait_seq_trigger
          fork:_all_master_agents
            <%chiaiu_idx = 0;
            ioaiu_idx = 0;%>
            <%for(var pidx = 0; pidx < obj.nAIUs; pidx++) {
                if((obj.AiuInfo[pidx].fnNativeInterface.match("CHI"))) {%>
                  if(chiaiu_en.exists(<%=chiaiu_idx%>)) begin:_chiaiu<%=chiaiu_idx%>_wait	
                    if (m_concerto_env_cfg.has_chi_vip_snps) begin
                      `uvm_info(get_name(), "USE_VIP_SNPS Waiting on TRAFFIC done_svt_chi_rn_seq_h<%=chiaiu_idx%> to Finish", UVM_LOW) 
                      done_svt_chi_rn_seq_h<%=chiaiu_idx%>.wait_trigger();
                      #2us;
                    end else begin 
                      ev_chi<%=chiaiu_idx%>_seq_done.wait_trigger();
                    end
                  end:_chiaiu<%=chiaiu_idx%>_wait
                  <% chiaiu_idx++;%>
              <%} else { %>
                <% for(var i=0; i<aiu_NumCores[pidx]; i++) { %> 
                  if(ioaiu_en.exists(<%=ioaiu_idx%>) && ioaiu_en[<%=ioaiu_idx%>]) begin:_ioaiu<%=ioaiu_idx%>_<%=i%>_wait
                    if (m_concerto_env_cfg.has_axi_vip_snps)
                      done_snp_cust_seq_h<%=ioaiu_idx%>.wait_trigger();
                    else 
                      ev_ioaiu<%=ioaiu_idx%>_seq_done[<%=i%>].wait_trigger();
                  end:_ioaiu<%=ioaiu_idx%>_<%=i%>_wait
                <% } %> //foreach core %>
                <% ioaiu_idx++;%>
              <%}%>
            <%} // foreach AIUs %>
               
          join:_all_master_agents
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


////////////////////////////////////////////////////////////////////
//#######  #     #  #     #   #####   #######  ###  #######  #     #  
//#        #     #  ##    #  #     #     #      #   #     #  ##    #  
//#        #     #  # #   #  #           #      #   #     #  # #   #  
//#####    #     #  #  #  #  #           #      #   #     #  #  #  #  
//#        #     #  #   # #  #           #      #   #     #  #   # #  
//#        #     #  #    ##  #     #     #      #   #     #  #    ##  
//#         #####   #     #   #####      #     ###  #######  #     #  
////////////////////////////////////////////////////////////////////


  <% for(var pidx=0, qidx = 0 ; qidx < obj.nDMIs; qidx++) { %>
  <% if (obj.DmiInfo[qidx].useCmc){ %>
task concerto_fullsys_performance_test::dmi<%=qidx%>_flush_cache();

    uvm_status_e  status;
    bit[31:0]     data;
    
    data[3:0]   = 'h4;  // 0x4: Flush All Entries
    data[21:16] = 'h0;  // 0x00: Tag Array  /  0x01: Data Array  /   0x02-0x3F: Reserved
    `uvm_info("PERFORMANCE DMI CACHE FLUSH", $sformatf("Initializing DMI Flush all Tag entries of Cache Memory, <%=obj.DmiInfo[qidx].strRtlNamePrefix%>.DMIUSMCMCR = 0x%0h", data), UVM_NONE)
    m_concerto_env.m_regs.<%=obj.DmiInfo[qidx].strRtlNamePrefix%>.DMIUSMCMCR.write(status, data[31:0]);
    data[21:16] = 'h1;  // 0x00: Tag Array  /  0x01: Data Array  /   0x02-0x3F: Reserved
    `uvm_info("PERFORMANCE DMI CACHE FLUSH", $sformatf("Initializing DMI Flush all Data entries of Cache Memory, <%=obj.DmiInfo[qidx].strRtlNamePrefix%>.DMIUSMCMCR = 0x%0h", data), UVM_NONE)
    m_concerto_env.m_regs.<%=obj.DmiInfo[qidx].strRtlNamePrefix%>.DMIUSMCMCR.write(status, data[31:0]);

    // poll until no more active ops
    do begin
      #100ns;
      m_concerto_env.m_regs.<%=obj.DmiInfo[qidx].strRtlNamePrefix%>.DMIUSMCMAR.read(status, data[31:0]);
    end while(data[0] == 1);

endtask : dmi<%=qidx%>_flush_cache
<% } %>	
<% } %>	

task concerto_fullsys_performance_test::flush_all_dmi_cache();

  fork
    <%for(let idx=0; idx<obj.nDMIs; idx++){%><%if(obj.DmiInfo[idx].useCmc == 1){%>
        dmi<%=idx%>_flush_cache();<%}%><%}%>
  join

endtask : flush_all_dmi_cache


function void concerto_fullsys_performance_test::set_all_addrq();

   <% var ioaiu_idx = 0; %>
    <% for(var pidx = 0 ; pidx < obj.nAIUs; pidx++) { %>
      <% if(!obj.AiuInfo[pidx].fnNativeInterface.match("CHI")) { %>
        <% for(var i=0; i<aiu_NumCores[pidx]; i++) { %> 
          m_concerto_env.inhouse.m_ace_cache_model_ioaiu<%=ioaiu_idx%>[<%=i%>].user_write_addrq= user_write_addrq;
          m_concerto_env.inhouse.m_ace_cache_model_ioaiu<%=ioaiu_idx%>[<%=i%>].user_read_addrq = user_read_addrq;
        <% } %>
      <% ioaiu_idx++;} %>
    <% } %>

endfunction : set_all_addrq


