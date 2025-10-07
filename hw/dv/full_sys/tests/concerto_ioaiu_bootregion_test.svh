

//File: concerto_ioaiu_bootregion_test.svh

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
var numChiAiu = 0;
var numIoAiu = 0;
var initiatorAgents   = obj.AiuInfo.length ;
var aiu_NumCores = [];
var max_NumCores;

for(var pidx = 0; pidx < initiatorAgents; pidx++) { 
  if(Array.isArray(obj.AiuInfo[pidx].interfaces.axiInt)) {
      aiu_NumCores[pidx]    = obj.AiuInfo[pidx].interfaces.axiInt.length;
  } else {
      aiu_NumCores[pidx]    = 1;
  }
}
max_NumCores =Math.max(...aiu_NumCores)

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
     if(bundle.fnNativeInterface === "CHI-A" || bundle.fnNativeInterface === "CHI-B" || bundle.fnNativeInterface === "CHI-E") {
       numChiAiu = numChiAiu + 1;
     } 
     else if((bundle.fnNativeInterface === "ACE" || bundle.fnNativeInterface === "ACE-LITE" || bundle.fnNativeInterface === "ACELITE-E") 
             || (bundle.fnNativeInterface === "AXI4" || bundle.fnNativeInterface === "AXI5")) {
       numIoAiu = numIoAiu + 1;
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


// main goal: with CSR reset value , access to the bootmem region with rdnosnp/wrnosnp  txn
class concerto_ioaiu_bootregion_test extends concerto_fullsys_test;

    //////////////////
    //UVM Registery
    //////////////////    
    `uvm_component_utils(concerto_ioaiu_bootregion_test)

    addr_trans_mgr    m_addr_mgr;

    `ifdef USE_VIP_SNPS_CHI //existing flow will not run when USE_VIP_SNPS set
        <% var chi_idx=0;%>
        <% for(var idx = 0;  idx < obj.nAIUs; idx++) {%> 
        <% if (obj.AiuInfo[idx].fnNativeInterface.match('CHI')) { %>
          chi_subsys_pkg::chi_subsys_vseq         m_snps_chi<%=chi_idx%>_vseq;
        <% chi_idx++;} }%>
       `ifdef CHI_UNITS_CNT_NON_ZERO
           chi_aiu_unit_args_pkg::chi_aiu_unit_args m_chi0_args;
           chiaiu0_chi_bfm_types_pkg::addr_width_t boot_addr;
       `endif
    `endif

    //////////////////
    //Methods
    //////////////////
    // UVM PHASE
    extern function new(string name = "concerto_ioaiu_bootregion_test", uvm_component parent = null);
    extern virtual task ncore_test_stimulus(uvm_phase phase);
    extern virtual function void start_of_simulation_phase(uvm_phase phase);
    
endclass: concerto_ioaiu_bootregion_test

function concerto_ioaiu_bootregion_test::new(string name = "concerto_ioaiu_bootregion_test", uvm_component parent = null);
    super.new(name, parent);
    m_addr_mgr = addr_trans_mgr::get_instance();
endfunction: new
///////////////////////////////////////////////////////////////////////////////// 
// #     #  #     #  #     #         ######   #     #     #      #####   #######  
// #     #  #     #  ##   ##         #     #  #     #    # #    #     #  #        
// #     #  #     #  # # # #         #     #  #     #   #   #   #        #        
// #     #  #     #  #  #  #         ######   #######  #     #   #####   #####    
// #     #   #   #   #     #         #        #     #  #######        #  #        
// #     #    # #    #     #         #        #     #  #     #  #     #  #        
//  #####      #     #     #  #####  #        #     #  #     #   #####   #######  
///////////////////////////////////////////////////////////////////////////////// 
task concerto_ioaiu_bootregion_test::ncore_test_stimulus(uvm_phase phase);
  bit[511:0] data;
  bit[511:0] read_data;
  bit prog_gprar_migr_mifsr=1; // Setting this to one because we always want to program these registers as per address manager randomization

  if (!test_cfg.k_access_boot_region) // don't setup boot csr register // must used reset value 
      `uvm_error("BOOTREGION", "you must use +k_access_boot_region")
  $value$plusargs("prog_gprar_migr_mifsr=%d", prog_gprar_migr_mifsr);

   `uvm_info("CONCERTO_IOAIU_BOOTREGION_TEST", "START ncore_test_stimulus", UVM_LOW)
   phase.raise_objection(this, "bootregion_test main_phase"); 
    #100ns; // wait clock on
    if(prog_gprar_migr_mifsr==1) begin
       conc_boot_tsk.pre_ncore_configure() ; 
       conc_boot_tsk.setup_gprar_mem() ; 
    end

       csr_init_done.trigger(null);// to start scb
       `uvm_info("BOOTREGION", "Starting concerto_ioaiu_bootregion_test::exec_inhouse_seq ...", UVM_LOW)
       exec_inhouse_seq(phase); // use full_sys exec_in_house_seq with new setup of seq in start_of_simulation_phase below
       wait_seq_totaly_done(phase);
       ev_sim_done.trigger();

   `uvm_info("CONCERTO_IOAIU_BOOTREGION_TEST", "END ncore_test_stimulus", UVM_LOW)
   phase.drop_objection(this, "bootregion_test main_phase"); 
endtask:ncore_test_stimulus


function void concerto_ioaiu_bootregion_test::start_of_simulation_phase(uvm_phase phase);
  super.start_of_simulation_phase(phase);
  `uvm_info(get_name(), "!!!set all txn to NONCOHERENT to acces to bootmemregion!!!!", UVM_NONE)
  //if (!(m_concerto_env_cfg.has_vip_snps)) begin // Inhouse CHI and IOAIU BFMs
  <% var chiaiu_idx=0;var ioaiu_idx=0; for(var pidx = 0; pidx < obj.nAIUs; pidx++) { %>
   <% if (obj.AiuInfo[pidx].fnNativeInterface.match("CHI")) { %>
       `ifndef USE_VIP_SNPS_CHI
                    m_chi<%=chiaiu_idx%>_vseq.k_access_boot_region    = 1; // use BOOT addr
                    m_chi<%=chiaiu_idx%>_args.k_rd_ldrstr_pct.set_value(0);
                    m_chi<%=chiaiu_idx%>_args.k_rq_lcrdrt_pct.set_value(0); 
                    m_chi<%=chiaiu_idx%>_args.k_rd_rdonce_pct.set_value(0);
                    m_chi<%=chiaiu_idx%>_args.k_dt_ls_upd_pct.set_value(0);
                    m_chi<%=chiaiu_idx%>_args.k_dt_ls_cmo_pct.set_value(0);
                    m_chi<%=chiaiu_idx%>_args.k_dt_ls_sth_pct.set_value(0);
                    m_chi<%=chiaiu_idx%>_args.k_wr_cohunq_pct.set_value(0);
                    m_chi<%=chiaiu_idx%>_args.k_pre_fetch_pct.set_value(0);
                    m_chi<%=chiaiu_idx%>_args.k_unsupported_txn_pct.set_value(0);
                    // nondata
                    m_chi<%=chiaiu_idx%>_args.k_dt_ls_upd_pct.set_value(0);
                    m_chi<%=chiaiu_idx%>_args.k_dt_ls_cmo_pct.set_value(0);
                    m_chi<%=chiaiu_idx%>_args.k_pre_fetch_pct.set_value(0);
                    //stash
                    m_chi<%=chiaiu_idx%>_args.k_dt_ls_sth_pct.set_value(0);
                    m_chi<%=chiaiu_idx%>_args.k_wr_sthunq_pct.set_value(0); 
                    //copy_back
                     m_chi<%=chiaiu_idx%>_args.k_wr_cpybck_pct.set_value(0);
                     if ($test$plusargs("sysco_disable")) begin // only noncoh txn
                       m_chi<%=chiaiu_idx%>_args.k_rd_noncoh_pct.set_value(100);
                       m_chi<%=chiaiu_idx%>_args.k_wr_noncoh_pct.set_value(100);
                     end else begin // coh boot
                       m_chi<%=chiaiu_idx%>_args.k_rd_noncoh_pct.set_value(0);
                       m_chi<%=chiaiu_idx%>_args.k_wr_noncoh_pct.set_value(0);
                       m_chi<%=chiaiu_idx%>_args.k_wr_cohunq_pct.set_value(100);
                       m_chi<%=chiaiu_idx%>_args.k_rd_ldrstr_pct.set_value(100);
                     end 

       <% if (obj.AiuInfo[pidx].BootInfo.regionHut) { // HUT: 0:DMI /1:DII%>
          m_chi<%=chiaiu_idx%>_args.k_device_type_mem_pct.set_value(100); // if BOOT space on DII
          <% if (!(obj.ConnectivityMap.aiuDiiMap[pidx]) ) {%>
          m_chi<%=chiaiu_idx%>_read_args.k_num_requests.set_value(0);
          <% }%>
       <%} else {%> 
          m_chi<%=chiaiu_idx%>_args.k_device_type_mem_pct.set_value(0); // if BOOT space on DMI
          <% if (!(obj.ConnectivityMap.aiuDmiMap[pidx]) ) {%>
          m_chi<%=chiaiu_idx%>_read_args.k_num_requests.set_value(0);
          <% }%>
       <%}%> 
      `endif
    <% chiaiu_idx++;%>
    <%} else { %> 
        <% if (obj.AiuInfo[pidx].BootInfo.regionHut) { // HUT: 0:DMI / 1:DII %>
          <% if (!(obj.ConnectivityMap.aiuDiiMap[pidx]) ) {%>
            <% for(var i=0; i<aiu_NumCores[pidx]; i++) { %>
                    fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_seq<%=ioaiu_idx%>[<%=i%>].k_num_read_req      = 0;
                    fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_seq<%=ioaiu_idx%>[<%=i%>].k_num_write_req     = 0;
            <% } %>
          <% }%>
        <% }  else { %>
          <% if (!(obj.ConnectivityMap.aiuDmiMap[pidx]) ) {%>
            <% for(var i=0; i<aiu_NumCores[pidx]; i++) { %>
                    fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_seq<%=ioaiu_idx%>[<%=i%>].k_num_read_req      = 0;
                    fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_seq<%=ioaiu_idx%>[<%=i%>].k_num_write_req     = 0;
            <% } %>
          <% }%>
        <% } %>

      <% for(var i=0; i<aiu_NumCores[pidx]; i++) { %>
                    fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_seq<%=ioaiu_idx%>[<%=i%>].k_access_boot_region   = 1;
                    fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_seq<%=ioaiu_idx%>[<%=i%>].wt_ace_rdnosnp      = 100;
                    fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_seq<%=ioaiu_idx%>[<%=i%>].wt_ace_rdonce       = 0;
                    fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_seq<%=ioaiu_idx%>[<%=i%>].wt_ace_wrnosnp      = 100;
                    fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_seq<%=ioaiu_idx%>[<%=i%>].wt_ace_wrunq        = 0;
                    fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_seq<%=ioaiu_idx%>[<%=i%>].wt_ace_wrlnunq      = 0;
                    fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_seq<%=ioaiu_idx%>[<%=i%>].wt_ace_wrcln        = 0;
                    fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_seq<%=ioaiu_idx%>[<%=i%>].wt_ace_rdunq        = 0;
                    fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_seq<%=ioaiu_idx%>[<%=i%>].wt_ace_clnunq       = 0;
                    fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_seq<%=ioaiu_idx%>[<%=i%>].wt_ace_rdcln        = 0;
                    fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_seq<%=ioaiu_idx%>[<%=i%>].wt_ace_rdshrd       = 0;
                    fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_seq<%=ioaiu_idx%>[<%=i%>].wt_ace_rdnotshrddty = 0;   
                    fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_seq<%=ioaiu_idx%>[<%=i%>].wt_ace_clnunq       = 0;
                    fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_seq<%=ioaiu_idx%>[<%=i%>].wt_ace_rd_cln_invld = 0; 
                    fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_seq<%=ioaiu_idx%>[<%=i%>].wt_ace_rd_make_invld= 0; 
                    //nondata
                    fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_seq<%=ioaiu_idx%>[<%=i%>].wt_ace_clnshrd      = 0;
                    fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_seq<%=ioaiu_idx%>[<%=i%>].wt_ace_clninvl      = 0;
                    fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_seq<%=ioaiu_idx%>[<%=i%>].wt_ace_mkunq        = 0;
                    fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_seq<%=ioaiu_idx%>[<%=i%>].wt_ace_mkinvl       = 0;
                    fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_seq<%=ioaiu_idx%>[<%=i%>].wt_ace_evct         = 0;
                    fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_seq<%=ioaiu_idx%>[<%=i%>].no_updates          = 0;    
                    fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_seq<%=ioaiu_idx%>[<%=i%>].wt_ace_clnshrd_pers = 0;
                    //stash
                    fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_seq<%=ioaiu_idx%>[<%=i%>].wt_ace_ptl_stash    = 0;
                    fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_seq<%=ioaiu_idx%>[<%=i%>].wt_ace_full_stash   = 0;
                    fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_seq<%=ioaiu_idx%>[<%=i%>].wt_ace_shared_stash = 0;
                    fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_seq<%=ioaiu_idx%>[<%=i%>].wt_ace_unq_stash    = 0;
                    fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_seq<%=ioaiu_idx%>[<%=i%>].wt_ace_stash_trans  = 0;     
                    //copy_bakc
                    fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_seq<%=ioaiu_idx%>[<%=i%>].wt_ace_wrcln        = 0;
                    fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_seq<%=ioaiu_idx%>[<%=i%>].wt_ace_wrbk         = 0;
                    fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_seq<%=ioaiu_idx%>[<%=i%>].wt_ace_wrevct       = 0; 
    <%  } %>
    <% ioaiu_idx++;%>
    <%  } %>
    <%} %>
  //end 
endfunction:start_of_simulation_phase
////////////////////////////////////////////////////////////////////
//#######  #     #  #     #   #####   #######  ###  #######  #     #  
//#        #     #  ##    #  #     #     #      #   #     #  ##    #  
//#        #     #  # #   #  #           #      #   #     #  # #   #  
//#####    #     #  #  #  #  #           #      #   #     #  #  #  #  
//#        #     #  #   # #  #           #      #   #     #  #   # #  
//#        #     #  #    ##  #     #     #      #   #     #  #    ##  
//#         #####   #     #   #####      #     ###  #######  #     #  
////////////////////////////////////////////////////////////////////


