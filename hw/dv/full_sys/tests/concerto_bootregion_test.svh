

//File: concerto_bootregion_test.svh

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
             || (bundle.fnNativeInterface === "AXI4")) {
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
class concerto_bootregion_test extends concerto_fullsys_test;

    //////////////////
    //UVM Registery
    //////////////////    
    `uvm_component_utils(concerto_bootregion_test)
    int main_seq_iter=1;
    static uvm_event_pool ev_pool  = uvm_event_pool::get_global_pool();
    static uvm_event fsc_test_done = ev_pool.get("fsc_test_done");
    bit block_fsys_fsc_main_task=1;

    addr_trans_mgr    m_addr_mgr;

    `ifdef USE_VIP_SNPS_CHI //existing flow will not run when USE_VIP_SNPS set
        <% var chi_idx=0;%>
        <% for(var idx = 0;  idx < obj.nAIUs; idx++) {%> 
        <% if (obj.AiuInfo[idx].fnNativeInterface.match('CHI')) { %>
          chi_subsys_pkg::chi_subsys_vseq         m_snps_chi<%=chi_idx%>_vseq;
        <% chi_idx++;} }%>
       `ifdef CHI_UNITS_CNT_NON_ZERO
           chi_aiu_unit_args_pkg::chi_aiu_unit_args m_chi0_args;
       `endif
    `endif

    //////////////////
    //Methods
    //////////////////
    // UVM PHASE
    extern function new(string name = "concerto_bootregion_test", uvm_component parent = null);
    extern virtual task ncore_test_stimulus(uvm_phase phase);
    extern virtual function void start_of_simulation_phase(uvm_phase phase);
    
    // Needed for test - chiaiu_bootregion_noncoh_with_fsc_bist_auto_seq_triggerred_by_dce_corr_err
    task main_seq_pre_hook(uvm_phase phase);
        if($test$plusargs("inject_uncorrectable_error") || $test$plusargs("fsc_inject_correctable_err") || $test$plusargs("fsc_csr_parity_prot_check_test")) begin
            conc_fsc_tsk.fsys_fsc_main_task(phase);
            if($test$plusargs("wait_for_fsc_test_done")) // Wait only for fsc test
                fsc_test_done.wait_trigger();
        end
    endtask

endclass: concerto_bootregion_test

function concerto_bootregion_test::new(string name = "concerto_bootregion_test", uvm_component parent = null);
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
task concerto_bootregion_test::ncore_test_stimulus(uvm_phase phase);
int reduce_mem_size=64;
  `ifdef CHI_UNITS_CNT_NON_ZERO
      chiaiu0_chi_bfm_types_pkg::addr_width_t boot_addr;
  `endif
  bit[511:0] data;
  bit[511:0] read_data;
  if ($value$plusargs("reduce_addr_area=%d",reduce_mem_size)) begin
       if (reduce_mem_size==1) reduce_mem_size=64;
       `uvm_info(get_name(),$psprintf("BOOTREGION:: reduce_addr_area:%0d cacheline size:64B", reduce_mem_size),UVM_NONE)
  end


  if (!test_cfg.k_access_boot_region) // don't setup boot csr register // must used reset value 
      `uvm_error("BOOTREGION", "you must use +k_access_boot_region")

   `uvm_info("CONCERTO_BOOTREGION_TEST", "START ncore_test_stimulus", UVM_LOW)
   phase.raise_objection(this, "bootregion_test main_phase"); 
    #100ns; // wait clock on
   if (!(m_concerto_env_cfg.has_vip_snps)) begin
       csr_init_done.trigger(null);// to start scb
       `uvm_info("BOOTREGION", "Starting concerto_bootregion_test::exec_inhouse_seq ...", UVM_LOW)
       exec_inhouse_seq(phase); // use full_sys exec_in_house_seq with new setup of seq in start_of_simulation_phase below
       wait_seq_totaly_done(phase);
       ev_sim_done.trigger();
   end else begin // Synopsys BFM
   `ifdef USE_VIP_SNPS_CHI
     `ifdef CHI_UNITS_CNT_NON_ZERO
     csr_init_done.trigger(null);
     main_seq_pre_hook(phase);
     `uvm_info("BOOTREGION", "Starting concerto_bootregion_test Synopsys BFM sequence...", UVM_LOW)
  
     if(chi_num_trans>0 && ioaiu_num_trans>0) begin : en_chi_or_io_native_if_randomely // At present, we generate stimulus on either of native i/f for boot region test
     randcase
     1: begin
         chi_num_trans = 0;
     end
     1 :  begin
         ioaiu_num_trans = 0;
     end
     endcase
     end : en_chi_or_io_native_if_randomely
     if(chi_num_trans > 0) begin : enable_chi_to_bootregion
     <% var chiaiu_idx=0;for(var pidx = 0; pidx < obj.nAIUs; pidx++) { %>
        <% if (obj.AiuInfo[pidx].fnNativeInterface.match("CHI")) { %> // Synopsys CHI BFM
              m_snps_chi<%=chiaiu_idx%>_vseq = chi_subsys_pkg::chi_subsys_vseq::type_id::create("m_chi<%=chiaiu_idx%>_seq");
              m_snps_chi<%=chiaiu_idx%>_vseq.set_seq_name("m_chi<%=chiaiu_idx%>_seq");
              m_snps_chi<%=chiaiu_idx%>_vseq.set_done_event_name("done_svt_chi_rn_seq_h<%=chiaiu_idx%>");
              m_snps_chi<%=chiaiu_idx%>_vseq.rn_xact_seqr    =  m_concerto_env.snps.svt.amba_system_env.chi_system[0].rn[<%=chiaiu_idx%>].rn_xact_seqr;  
              m_snps_chi<%=chiaiu_idx%>_vseq.shared_status =  m_concerto_env.snps.svt.amba_system_env.chi_system[0].rn[<%=chiaiu_idx%>].shared_status;  
              m_snps_chi<%=chiaiu_idx%>_vseq.chi_num_trans =  chi_num_trans;  
              m_snps_chi<%=chiaiu_idx%>_vseq.m_regs = m_concerto_env.m_regs;
              // Due to STATIC m_chi0_args must create a dummy one.
              m_chi0_args = chi_aiu_unit_args_pkg::chi_aiu_unit_args::type_id::create("chi0_aiu_unit_args0");
              m_chi0_args.k_num_requests.set_value(chi_num_trans);
              m_chi0_args.k_noncoh_addr_pct.set_value(100);
              <% if (obj.AiuInfo[pidx].BootInfo.regionHut) { // HUT: 0:DMI /1:DII%>;
                m_chi0_args.k_device_type_mem_pct.set_value(100); // if BOOT space on DII
              <%} else {%> 
                m_chi0_args.k_device_type_mem_pct.set_value(0); // if BOOT space on DMI
              <%}%>
              m_chi0_args.k_new_addr_pct.set_value(100);
              m_snps_chi<%=chiaiu_idx%>_vseq.set_unit_args(m_chi0_args);
              for (int i =0; i < chi_num_trans; i++) begin // 10 transactions
                  if ($test$plusargs("reduce_addr_area")) begin // reduce number of addr to allow more snoop
                      boot_addr =  $urandom_range((ncore_config_pkg::ncoreConfigInfo::BOOT_REGION_BASE + (reduce_mem_size<< 6)-1), ncore_config_pkg::ncoreConfigInfo::BOOT_REGION_BASE);
                      boot_addr =  (boot_addr >> 6) << 6;
                  end else
                      boot_addr = m_addr_mgr.get_noncohboot_addr(0,0);

                  for(int j =0; j< 16; j++) begin
                      data[32*j +:32] = $urandom();
                  end
                  `uvm_info("BOOTREGION", $sformatf("Writing the Non Coherent Boot Memory address : %0x with data : %0x",boot_addr, data) , UVM_LOW)
                  m_snps_chi<%=chiaiu_idx%>_vseq.write_memory(boot_addr, data, 6); // 64 Bytes of Data
                  `uvm_info("BOOTREGION", $sformatf("Reading the Non Coherent Boot Memory address : %0x ",boot_addr) , UVM_LOW)
                  m_snps_chi<%=chiaiu_idx%>_vseq.read_memory(boot_addr, read_data, 6, 0);
                  //if(read_data != data) begin
                  //  `uvm_error("BOOTREGION", $sformatf("Read data didn't match the Write Data Expected :%0x Actual: %0x ",data, read_data))   
                  //end
              end
              <% chiaiu_idx++;%>
        <% } %> // fnNativeInterface.match("CHI"))
        <% break; %>// only CHI0 TODO fix cust_svt_amba_system_configuration or chi_vseq to access with other CHI to CS
     <% } %> // for loop pidx < obj.nAIUs
     ev_sim_done.trigger();
     end : enable_chi_to_bootregion

     if(ioaiu_num_trans > 0) begin : enable_io_to_bootregion
       fork
        `ifdef IO_UNITS_CNT_NON_ZERO
          begin
            fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.no_snoop_seq = 1;
            if (m_concerto_env_cfg.has_axi_vip_snps )
            begin: _ioaiu_vip
              `uvm_info(get_name(), "Starting IOAIU Traffic with SNPS VIP", UVM_LOW)
	      fsys_main_traffic_vseq.ioaiu_traffic_vseq.start(`SVT_VIRTUAL_SEQR_PATH);
              `uvm_info(get_name(), "Finished IOAIU Traffic with SNPS VIP", UVM_LOW)
            end: _ioaiu_vip
            else
            begin: _ioaiu_inhouse
              `uvm_info(get_name(), "Starting IOAIU Traffic with Inhouse Sequences", UVM_LOW)
              fsys_main_traffic_vseq.ioaiu_traffic_vseq.start(null);
              `uvm_info(get_name(), "Fineshed IOAIU Traffic with Inhouse Sequences", UVM_LOW)
            end: _ioaiu_inhouse
          end
        `endif
         
         begin : wait_for_all_ioaiu_seq_trigger_begin
         fork : wait_for_all_ioaiu_seq_trigger_fork_join
         <% var ioaiu_idx_with_multi_core = 0; %>
         <% var ioaiu_idx = 0; for(var pidx = 0; pidx < obj.nAIUs; pidx++) { %>
         <% if(!(obj.AiuInfo[pidx].fnNativeInterface.match("CHI"))) { %>
         <% for(var i=0; i<aiu_NumCores[pidx]; i++) { %>  
	       if(ioaiu_en.exists(<%=ioaiu_idx%>)) begin:_ioaiu<%=ioaiu_idx%>_<%=i%>
                 ev_ioaiu<%=ioaiu_idx%>_seq_done[<%=i%>].wait_trigger();
               end:_ioaiu<%=ioaiu_idx%>_<%=i%> 
             <% ioaiu_idx_with_multi_core = ioaiu_idx_with_multi_core + 1;} // foreach core%> 
         <% ioaiu_idx++; } //foreach ioaiu%>
         <% } // foreahc AIU%>
         join : wait_for_all_ioaiu_seq_trigger_fork_join
         ev_sim_done.trigger();
         end : wait_for_all_ioaiu_seq_trigger_begin
       join
     end : enable_io_to_bootregion

  `endif
  `endif
  end
   `uvm_info("CONCERTO_BOOTREGION_TEST", "END ncore_test_stimulus", UVM_LOW)
   phase.drop_objection(this, "bootregion_test main_phase"); 
endtask:ncore_test_stimulus


function void concerto_bootregion_test::start_of_simulation_phase(uvm_phase phase);
  super.start_of_simulation_phase(phase);
  `uvm_info(get_name(), "!!!set all txn to NONCOHERENT to acces to bootmemregion!!!!", UVM_NONE)
  if (!(m_concerto_env_cfg.has_vip_snps)) begin // Inhouse CHI and IOAIU BFMs
  <% var chiaiu_idx=0;var ioaiu_idx=0; for(var pidx = 0; pidx < obj.nAIUs; pidx++) { %>
   <% if (obj.AiuInfo[pidx].fnNativeInterface.match("CHI")) { %>
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

       <% if (obj.AiuInfo[pidx].BootInfo.regionHut) { // HUT: 0:DMI /1:DII%>;
         m_chi<%=chiaiu_idx%>_args.k_device_type_mem_pct.set_value(100); // if BOOT space on DII
       <%} else {%> 
         m_chi<%=chiaiu_idx%>_args.k_device_type_mem_pct.set_value(0); // if BOOT space on DMI
       <%}%> 
    <% chiaiu_idx++;%>
    <%} else { %> 
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
  end  else begin
  <% var chiaiu_idx=0;var ioaiu_idx=0; for(var pidx = 0; pidx < obj.nAIUs; pidx++) { %>
   <% if (!(obj.AiuInfo[pidx].fnNativeInterface.match("CHI"))) { %>
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
  end
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


