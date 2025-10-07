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
var csrAccess_ioaiu;
var csrAccess_chiaiu;
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
const aiu_axiInt = [];
var dmi_width= [];
var AiuCore;
var initiatorAgents   = obj.AiuInfo.length ;
var aiu_NumCores = [];
var aiu_rpn = [];
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
// Assuming CHI AIU will appear first in AiuInfo in top.level.dv.json before IO-AIUs
var chi_idx=0;
var io_idx=0;
for(var pidx = 0; pidx < obj.nAIUs; pidx++) {
    pma_en_aiu_blk &= obj.AiuInfo[pidx].usePma;
    pma_en_at_least_1_blk |= obj.AiuInfo[pidx].usePma;
    if((obj.AiuInfo[pidx].fnNativeInterface.match("CHI"))) 
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
                            if(item.fnNativeInterface.match("CHI")) {
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
                            if(!item.fnNativeInterface.match("CHI")) {
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

//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
//               /\             /\            /\       
//              /  \           /  \          /  \
//             /    \         /    \        /    \
//            /  |   \       /  |   \      /  |   \
//           /   |    \     /   |    \    /   |    \
//          /    °     \   /    °     \  /    °     \
//         /____________\ /____________\/____________\
// LEGACY use with CONCERTO_FULLSYS_TEST +k_directed_test=1
//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

class concerto_fullsys_direct_legacy_test extends concerto_fullsys_test; 

  `uvm_component_utils(concerto_fullsys_direct_legacy_test)

   // UVM PHASE
   extern virtual task exec_inhouse_seq (uvm_phase phase);
 
  function new(string name = "concerto_fullsys_direct_legacy_test", uvm_component parent=null);
    super.new(name,parent);
  endfunction: new

  

endclass: concerto_fullsys_direct_legacy_test


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


task concerto_fullsys_direct_legacy_test::exec_inhouse_seq (uvm_phase phase);
// OVERWRITE exec_inhouse_seq used in the main_phase

            int processor_a_num;
            int processor_b_num;
            //dmi_port_sel is null //addrMgrConst::sel_bits_t m_sel;
            bit [addrMgrConst::W_SEC_ADDR-1:0] addr;
            bit [<%=obj.DmiInfo[0].ccpParams.PriSubDiagAddrBits.length-1%> : 0] pri_bits_val;
   
   `uvm_info("direct_legacy_TEST", "START EXEC_INHOUSE_SEQ", UVM_LOW)
    csr_init_done.trigger(null);

     #100ns; 
  
     if ($value$plusargs("use_user_addrq=%d", use_user_addrq)) begin:_use_user_addrq
         gen_addr_use_user_addrq();
     end:_use_user_addrq

            fork
            begin
                // Get the address used in write to use in read ??
                addr_mgr.gen_user_noncoh_addr(<%=obj.DmiInfo[0].FUnitId%>, <%=obj.DmiInfo[0].ccpParams.nSets%>, addrMgrConst::user_addrq[addrMgrConst::NONCOH]);
                if (!$test$plusargs("all_gpra_ncmode")) addr_mgr.gen_user_coh_addr(<%=obj.DmiInfo[0].FUnitId%>, <%=obj.DmiInfo[0].ccpParams.nSets%>, addrMgrConst::user_addrq[addrMgrConst::COH]);
                for(int i=0; i< <%=obj.DmiInfo[0].ccpParams.nSets%>; i++) begin
                    addr = addrMgrConst::user_addrq[addrMgrConst::NONCOH][i];
                    pri_bits_val = i;
  <% for(var idx=0; idx<obj.DmiInfo[0].ccpParams.PriSubDiagAddrBits.length;idx++){%> 
                        addr[<%=obj.DmiInfo[0].ccpParams.PriSubDiagAddrBits[idx]%>] = pri_bits_val[<%=idx%>];
  <% } %>
                        addr[5:0] = k_directed_64B_aligned ? 6'b0 : addr[5:0];
                    //`uvm_info("ADDR DEBUG",$sformatf("NC[19:10] %0d [18:8] %0d, Addr %0h i =%0d ",addr[19:10],addr[18:8],addr,i),UVM_NONE)
                    addrMgrConst::user_addrq[addrMgrConst::NONCOH][i] = addr;
                end
                for(int i=0; i< <%=obj.DmiInfo[0].ccpParams.nSets%>; i++) begin
                    addr = addrMgrConst::user_addrq[addrMgrConst::COH][i];
                    pri_bits_val = i;
  <% for(var idx=0; idx<obj.DmiInfo[0].ccpParams.PriSubDiagAddrBits.length;idx++){%> 
                        addr[<%=obj.DmiInfo[0].ccpParams.PriSubDiagAddrBits[idx]%>] = pri_bits_val[<%=idx%>];
  <% } %>
                        addr[5:0] = k_directed_64B_aligned ? 6'b0 : addr[5:0];
                    //`uvm_info("ADDR DEBUG",$sformatf("C [19:10] %0d [18:8] %0d, Addr %0h i =%0d ",addr[19:10],addr[18:8],addr,i),UVM_NONE)
                    addrMgrConst::user_addrq[addrMgrConst::COH][i] = addr;
                end

//`ifndef USE_VIP_SNPS //existing flow will not run when USE_VIP_SNPS set
	       <% var chi_idx=0;
	       var io_idx=0;
	       for(var pidx=0; pidx<obj.nAIUs; pidx++) {
               if((obj.AiuInfo[pidx].fnNativeInterface.match("CHI"))) { %>
               `ifndef USE_VIP_SNPS //existing flow will not run when USE_VIP_SNPS set
               m_chi<%=chi_idx%>_vseq.m_chi_container.user_addrq[addrMgrConst::NONCOH] = addrMgrConst::user_addrq[addrMgrConst::NONCOH];
               m_chi<%=chi_idx%>_vseq.m_chi_container.user_addrq[addrMgrConst::COH] = addrMgrConst::user_addrq[addrMgrConst::COH];
               `endif //`ifndef USE_VIP_SNPS
	       <% chi_idx++;
               } else { %>
              <% for(var coreidx=0; coreidx<aiu_NumCores[pidx]; coreidx++) { %>
               m_concerto_env.inhouse.m_ace_cache_model_ioaiu<%=io_idx%>[<%=coreidx%>].user_addrq[addrMgrConst::NONCOH] = addrMgrConst::user_addrq[addrMgrConst::NONCOH];
               m_concerto_env.inhouse.m_ace_cache_model_ioaiu<%=io_idx%>[<%=coreidx%>].user_addrq[addrMgrConst::COH] = addrMgrConst::user_addrq[addrMgrConst::COH];
              <% } %>//foreach core%>               
               <% io_idx++; } 
               } %>

                processor_a_num = $urandom_range(0,<%=obj.nAIUs-1%>);
                case(processor_a_num)
  <% for(var idx = 0, cidx=0, ncidx=0; idx < obj.nAIUs; idx++) { 
               if((obj.AiuInfo[idx].fnNativeInterface.match("CHI"))) { %>
                <%=idx%>: begin 
                `ifndef USE_VIP_SNPS //existing flow will not run when USE_VIP_SNPS set
                   `uvm_info("FULLSYS_TEST", "Start write on processor<%=idx%> : CHIAIU<%=cidx%>", UVM_NONE)
                    m_chi<%=cidx%>_args.k_coh_addr_pct.set_value(0);
                    m_chi<%=cidx%>_args.k_noncoh_addr_pct.set_value(100);
                    m_chi<%=cidx%>_args.k_new_addr_pct.set_value(100);
                    m_chi<%=cidx%>_args.k_device_type_mem_pct.set_value(0);
                    m_chi<%=cidx%>_args.k_rd_noncoh_pct.set_value(0);
                    m_chi<%=cidx%>_args.k_rd_ldrstr_pct.set_value(0);
                    m_chi<%=cidx%>_args.k_rd_rdonce_pct.set_value(0);
                    m_chi<%=cidx%>_args.k_wr_noncoh_pct.set_value(50);
                    m_chi<%=cidx%>_args.k_wr_cohunq_pct.set_value(0);
                    m_chi<%=cidx%>_args.k_wr_cpybck_pct.set_value(0);
                    m_chi<%=cidx%>_args.k_dt_ls_upd_pct.set_value(0);
                    m_chi<%=cidx%>_args.k_dt_ls_cmo_pct.set_value(0);
                    m_chi<%=cidx%>_args.k_pre_fetch_pct.set_value(0);
                    m_chi<%=cidx%>_args.k_dt_ls_sth_pct.set_value(0);
                    m_chi<%=cidx%>_args.k_wr_sthunq_pct.set_value(0);
                    m_chi<%=cidx%>_args.k_atomic_st_pct.set_value(0);
                    m_chi<%=cidx%>_args.k_atomic_ld_pct.set_value(0);
                    m_chi<%=cidx%>_args.k_atomic_sw_pct.set_value(0);
                    m_chi<%=cidx%>_args.k_atomic_cm_pct.set_value(0);
                    m_chi<%=cidx%>_args.k_dvm_opert_pct.set_value(0);
                    m_chi<%=cidx%>_vseq.set_unit_args(m_chi<%=cidx%>_args);
                    m_chi<%=cidx%>_vseq.k_directed_test_alloc = 1;
                   fork
                   begin
                       phase.raise_objection(this, "CHIAIU<%=cidx%> sequence");
                       m_chi<%=cidx%>_vseq.start(null);
                       `uvm_info("FULLSYS_TEST", "Done  write on processor<%=idx%> : CHIAIU<%=cidx%>", UVM_NONE)
                       //#5us;
                       phase.drop_objection(this, "CHIAIU<%=cidx%> sequence");
                   end
                   begin
                       ev_chi<%=cidx%>_seq_done.wait_trigger();
                       ev_sim_done.trigger(null);
                   end
                   join
                `else //`ifndef USE_VIP_SNPS
                   `uvm_info("FULLSYS_TEST", "Start write on processor<%=idx%> : CHIAIU<%=cidx%>", UVM_NONE)
                    m_chi0_args.k_coh_addr_pct.set_value(0);
                    m_chi0_args.k_noncoh_addr_pct.set_value(100);
                    m_chi0_args.k_new_addr_pct.set_value(100);
                    m_chi0_args.k_device_type_mem_pct.set_value(0);
                    m_chi0_args.k_rd_noncoh_pct.set_value(0);
                    m_chi0_args.k_rd_ldrstr_pct.set_value(0);
                    m_chi0_args.k_rd_rdonce_pct.set_value(0);
                    m_chi0_args.k_wr_noncoh_pct.set_value(50);
                    m_chi0_args.k_wr_cohunq_pct.set_value(0);
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
                    //m_chi0_vseq.set_unit_args(m_chi<%=cidx%>_args);
                    <% if(numChiAiu > 0) { %>
                       m_svt_chi_item.m_args = m_chi0_args;
                    <% } %>
                    m_snps_chi<%=cidx%>_vseq.set_unit_args(m_chi0_args);
                    m_snps_chi<%=cidx%>_vseq.k_directed_test_alloc = 1;
                    fork
                    begin
                       phase.raise_objection(this, "CHIAIU<%=cidx%> sequence");
                        m_snps_chi<%=cidx%>_vseq.start(null);
                       `uvm_info("FULLSYS_TEST", "Done  write on processor<%=idx%> : CHIAIU<%=cidx%>", UVM_NONE)
                       //#5us;
                       phase.drop_objection(this, "CHIAIU<%=cidx%> sequence");
                   end
                   join_any  // TBD - logic implemented for SNPS, check inhouse code
                   `endif //`ifndef USE_VIP_SNPS ... else
                   end
 
     <% cidx++;
    } else { %>
                <%=idx%>: begin 
                   `uvm_info("FULLSYS_TEST", "Start write on processor<%=idx%> : IOAIU<%=ncidx%>", UVM_NONE)
                   `ifndef USE_VIP_SNPS
                   <% for(var i=0; i<aiu_NumCores[idx]; i++) { %>
                   fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_seq<%=ncidx%>[<%=i%>].k_num_read_req        = 0;
                   fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_seq<%=ncidx%>[<%=i%>].k_num_write_req       = ioaiu_num_trans;
                   fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_seq<%=ncidx%>[<%=i%>].k_directed_test_alloc = 1;
        <% if((obj.AiuInfo[idx].fnNativeInterface == 'ACE') || (obj.AiuInfo[idx].fnNativeInterface == 'ACE-LITE') || (obj.AiuInfo[idx].fnNativeInterface == 'ACELITE-E')) { %>
                   fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_seq<%=ncidx%>[<%=i%>].wt_ace_rdnosnp      = 0;
                   fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_seq<%=ncidx%>[<%=i%>].wt_ace_rdonce       = 0;
                   fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_seq<%=ncidx%>[<%=i%>].wt_ace_wrnosnp      = 50;
                   fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_seq<%=ncidx%>[<%=i%>].wt_ace_wrunq        = 0;
                   fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_seq<%=ncidx%>[<%=i%>].wt_ace_wrlnunq      = 0;
          <% if(obj.AiuInfo[idx].fnNativeInterface == 'ACE') { %>
                   fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_seq<%=ncidx%>[<%=i%>].wt_ace_rdshrd       = 0;
                   fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_seq<%=ncidx%>[<%=i%>].wt_ace_rdcln        = 0;
                   fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_seq<%=ncidx%>[<%=i%>].wt_ace_rdnotshrddty = 0;
                   fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_seq<%=ncidx%>[<%=i%>].wt_ace_rdunq        = 0;
                   fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_seq<%=ncidx%>[<%=i%>].wt_ace_wrcln        = 0;
                   fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_seq<%=ncidx%>[<%=i%>].wt_ace_wrbk         = 0;
                   fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_seq<%=ncidx%>[<%=i%>].wt_ace_wrevct       = 0;
                   fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_seq<%=ncidx%>[<%=i%>].wt_ace_dvm_msg      = 0;
                   fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_seq<%=ncidx%>[<%=i%>].wt_ace_dvm_sync     = 0;
          <% } %>
                   fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_seq<%=ncidx%>[<%=i%>].wt_ace_clnunq       = 0;
                   fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_seq<%=ncidx%>[<%=i%>].wt_ace_clnshrd      = 0;
                   fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_seq<%=ncidx%>[<%=i%>].wt_ace_clninvl      = 0;
                   fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_seq<%=ncidx%>[<%=i%>].wt_ace_mkunq        = 0;
                   fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_seq<%=ncidx%>[<%=i%>].wt_ace_mkinvl       = 0;
                   fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_seq<%=ncidx%>[<%=i%>].wt_ace_evct         = 0;
                   fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_seq<%=ncidx%>[<%=i%>].no_updates          = 0;
                   fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_seq<%=ncidx%>[<%=i%>].wt_ace_rd_bar       = 0;
                   fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_seq<%=ncidx%>[<%=i%>].wt_ace_wr_bar       = 0;
          <% if(obj.AiuInfo[idx].fnNativeInterface != 'ACE-LITE') { %>
                   fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_seq<%=ncidx%>[<%=i%>].wt_ace_atm_str      = 0;
                   fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_seq<%=ncidx%>[<%=i%>].wt_ace_atm_ld       = 0;
                   fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_seq<%=ncidx%>[<%=i%>].wt_ace_atm_swap     = 0;
                   fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_seq<%=ncidx%>[<%=i%>].wt_ace_atm_comp     = 0;
                   fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_seq<%=ncidx%>[<%=i%>].wt_ace_ptl_stash    = 0;
                   fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_seq<%=ncidx%>[<%=i%>].wt_ace_full_stash   = 0;
                   fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_seq<%=ncidx%>[<%=i%>].wt_ace_shared_stash = 0;
                   fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_seq<%=ncidx%>[<%=i%>].wt_ace_unq_stash    = 0;
                   fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_seq<%=ncidx%>[<%=i%>].wt_ace_stash_trans  = 0;
          <% } %>
      <% }%>
      <% } %>
                 `else
      <% for(var i=0; i<aiu_NumCores[pidx]; i++) { %> 
                   cust_seq_h<%=ncidx%>[<%=i%>].k_num_read_req        = 0;
                   cust_seq_h<%=ncidx%>[<%=i%>].k_num_write_req       = ioaiu_num_trans;
                   cust_seq_h<%=ncidx%>[<%=i%>].k_directed_test_alloc = 1;
        <% if((obj.AiuInfo[idx].fnNativeInterface == 'ACE') || (obj.AiuInfo[idx].fnNativeInterface == 'ACE-LITE') || (obj.AiuInfo[idx].fnNativeInterface == 'ACELITE-E')) { %>
                   cust_seq_h<%=ncidx%>[<%=i%>].wt_ace_rdnosnp      = 0;
                   cust_seq_h<%=ncidx%>[<%=i%>].wt_ace_rdonce       = 0;
                   cust_seq_h<%=ncidx%>[<%=i%>].wt_ace_wrnosnp      = 50;
                   cust_seq_h<%=ncidx%>[<%=i%>].wt_ace_wrunq        = 0;
                   cust_seq_h<%=ncidx%>[<%=i%>].wt_ace_wrlnunq      = 0;
          <% if(obj.AiuInfo[idx].fnNativeInterface == 'ACE') { %>
                   cust_seq_h<%=ncidx%>[<%=i%>].wt_ace_rdshrd       = 0;
                   cust_seq_h<%=ncidx%>[<%=i%>].wt_ace_rdcln        = 0;
                   cust_seq_h<%=ncidx%>[<%=i%>].wt_ace_rdnotshrddty = 0;
                   cust_seq_h<%=ncidx%>[<%=i%>].wt_ace_rdunq        = 0;
                   cust_seq_h<%=ncidx%>[<%=i%>].wt_ace_wrcln        = 0;
                   cust_seq_h<%=ncidx%>[<%=i%>].wt_ace_wrbk         = 0;
                   cust_seq_h<%=ncidx%>[<%=i%>].wt_ace_wrevct       = 0;
                   cust_seq_h<%=ncidx%>[<%=i%>].wt_ace_dvm_msg      = 0;
                   cust_seq_h<%=ncidx%>[<%=i%>].wt_ace_dvm_sync     = 0;
          <% } %>
                   cust_seq_h<%=ncidx%>[<%=i%>].wt_ace_clnunq       = 0;
                   cust_seq_h<%=ncidx%>[<%=i%>].wt_ace_clnshrd      = 0;
                   cust_seq_h<%=ncidx%>[<%=i%>].wt_ace_clninvl      = 0;
                   cust_seq_h<%=ncidx%>[<%=i%>].wt_ace_mkunq        = 0;
                   cust_seq_h<%=ncidx%>[<%=i%>].wt_ace_mkinvl       = 0;
                   cust_seq_h<%=ncidx%>[<%=i%>].wt_ace_evct         = 0;
                   cust_seq_h<%=ncidx%>[<%=i%>].no_updates          = 0;
                   cust_seq_h<%=ncidx%>[<%=i%>].wt_ace_rd_bar       = 0;
                   cust_seq_h<%=ncidx%>[<%=i%>].wt_ace_wr_bar       = 0;
          <% if(obj.AiuInfo[idx].fnNativeInterface != 'ACE-LITE') { %>
                   cust_seq_h<%=ncidx%>[<%=i%>].wt_ace_atm_str      = 0;
                   cust_seq_h<%=ncidx%>[<%=i%>].wt_ace_atm_ld       = 0;
                   cust_seq_h<%=ncidx%>[<%=i%>].wt_ace_atm_swap     = 0;
                   cust_seq_h<%=ncidx%>[<%=i%>].wt_ace_atm_comp     = 0;
                   cust_seq_h<%=ncidx%>[<%=i%>].wt_ace_ptl_stash    = 0;
                   cust_seq_h<%=ncidx%>[<%=i%>].wt_ace_full_stash   = 0;
                   cust_seq_h<%=ncidx%>[<%=i%>].wt_ace_shared_stash = 0;
                   cust_seq_h<%=ncidx%>[<%=i%>].wt_ace_unq_stash    = 0;
                   cust_seq_h<%=ncidx%>[<%=i%>].wt_ace_stash_trans  = 0;
          <% } %>
      <% }%>
    <% } %>

                  
                 `endif
                   fork
                   `ifndef USE_VIP_SNPS
                       <% for(var i=0; i<aiu_NumCores[idx]; i++) { %>
                   begin
                       phase.raise_objection(this, "IOAIU<%=ncidx%>[<%=i%>] sequence");
                       fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_seq<%=ncidx%>[<%=i%>].start(null);
                       `uvm_info("FULLSYS_TEST", "Done  write on processor<%=idx%>[<%=i%>] : IOAIU<%=ncidx%>[<%=i%>]", UVM_NONE)
                       //#1us;
                       phase.drop_objection(this, "IOAIU<%=ncidx%>[<%=i%>] sequence");
                   end
                   begin
                       ev_ioaiu<%=ncidx%>_seq_done[<%=i%>].wait_trigger();
                       ev_sim_done.trigger(null);
                   end
                       <% } //foreach core%>
                   `else
                       <% for(var i=0; i<aiu_NumCores[idx]; i++) { %>
                    begin
                    phase.raise_objection(this, "USE_VIP_SNPS IOAIU<%=ncidx%> sequence");
                    `uvm_info("FULLSYS_TEST", "USE_VIP_SNPS START cust_seq_h<%=ncidx%>[<%=i%>]", UVM_NONE)
                    uvm_config_db#(svt_axi_port_configuration)::set(null, "*", "port_cfg_ioaiu<%=ncidx%>_<%=i%>", m_concerto_env.snps.m_cfg.svt_cfg.axi_sys_cfg[0].master_cfg[<%=(aiu_rpn[idx]+i)-chi_idx%>]);
                      if(ioaiu_num_trans > 0)
                    cust_seq_h<%=ncidx%>[<%=i%>].start(m_concerto_env.snps.svt.amba_system_env.axi_system[0].sequencer);
                    #1us;
                    done_snp_cust_seq_h<%=ncidx%>.trigger(null);
                    `uvm_info("FULLSYS_TEST", "USE_VIP_SNPS DONE cust_seq_h<%=ncidx%>[<%=i%>]", UVM_NONE)
                    phase.drop_objection(this, "USE_VIP_SNPS IOAIU<%=ncidx%> sequence");
                    end
                       <% } //foreach core%>
                    `endif
                   join
                   end           
     <% ncidx++;
    }
  } %>
                endcase
                while(processor_a_num == processor_b_num) begin
                    processor_b_num = $urandom_range(0,<%=obj.nAIUs-1%>);
                end
                case(processor_b_num)
  <% for(var idx = 0, cidx=0, ncidx=0; idx < obj.nAIUs; idx++) { 
               if((obj.AiuInfo[idx].fnNativeInterface.match("CHI"))) { %>
                <%=idx%>: begin 
    `ifndef USE_VIP_SNPS //existing flow will not run when USE_VIP_SNPS set
                   `uvm_info("FULLSYS_TEST", "Start read on processor<%=idx%> : CHIAIU<%=cidx%>", UVM_NONE)
                    m_chi<%=cidx%>_args.k_coh_addr_pct.set_value(0);
                    m_chi<%=cidx%>_args.k_noncoh_addr_pct.set_value(100);
                    m_chi<%=cidx%>_args.k_new_addr_pct.set_value(100);
                    m_chi<%=cidx%>_args.k_device_type_mem_pct.set_value(0);
                    m_chi<%=cidx%>_args.k_rd_noncoh_pct.set_value(50);
                    m_chi<%=cidx%>_args.k_rd_ldrstr_pct.set_value(0);
                    m_chi<%=cidx%>_args.k_rd_rdonce_pct.set_value(0);
                    m_chi<%=cidx%>_args.k_wr_noncoh_pct.set_value(0);
                    m_chi<%=cidx%>_args.k_wr_cohunq_pct.set_value(0);
                    m_chi<%=cidx%>_args.k_wr_cpybck_pct.set_value(0);
                    m_chi<%=cidx%>_args.k_dt_ls_upd_pct.set_value(0);
                    m_chi<%=cidx%>_args.k_dt_ls_cmo_pct.set_value(0);
                    m_chi<%=cidx%>_args.k_pre_fetch_pct.set_value(0);
                    m_chi<%=cidx%>_args.k_dt_ls_sth_pct.set_value(0);
                    m_chi<%=cidx%>_args.k_wr_sthunq_pct.set_value(0);
                    m_chi<%=cidx%>_args.k_atomic_st_pct.set_value(0);
                    m_chi<%=cidx%>_args.k_atomic_ld_pct.set_value(0);
                    m_chi<%=cidx%>_args.k_atomic_sw_pct.set_value(0);
                    m_chi<%=cidx%>_args.k_atomic_cm_pct.set_value(0);
                    m_chi<%=cidx%>_args.k_dvm_opert_pct.set_value(0);
                    m_chi<%=cidx%>_vseq.set_unit_args(m_chi<%=cidx%>_args);
                    m_chi<%=cidx%>_vseq.k_directed_test_alloc = 1;
                    fork
                    begin
                        phase.raise_objection(this, "CHIAIU<%=cidx%> sequence");
                        m_chi<%=cidx%>_vseq.start(null);
                        `uvm_info("FULLSYS_TEST", "Done  read on processor<%=idx%> : CHIAIU<%=cidx%>", UVM_NONE)
                        //#5us;
                        phase.drop_objection(this, "CHIAIU<%=cidx%> sequence");
                    end
                    begin
                        ev_chi<%=cidx%>_seq_done.wait_trigger();
                        ev_sim_done.trigger(null);
                    end
                    join
      `else//`ifndef USE_VIP_SNPS
                    `uvm_info("FULLSYS_TEST", "Start read on processor<%=idx%> : CHIAIU<%=cidx%>", UVM_NONE)
                    m_chi0_args.k_coh_addr_pct.set_value(0);
                    m_chi0_args.k_noncoh_addr_pct.set_value(100);
                    m_chi0_args.k_new_addr_pct.set_value(100);
                    m_chi0_args.k_device_type_mem_pct.set_value(0);
                    m_chi0_args.k_rd_noncoh_pct.set_value(50);
                    m_chi0_args.k_rd_ldrstr_pct.set_value(0);
                    m_chi0_args.k_rd_rdonce_pct.set_value(0);
                    m_chi0_args.k_wr_noncoh_pct.set_value(0);
                    m_chi0_args.k_wr_cohunq_pct.set_value(0);
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
                    //m_chi0_vseq.set_unit_args(m_chi<%=cidx%>_args);
                    m_snps_chi<%=cidx%>_vseq.k_directed_test_alloc = 1;
                    <% if(numChiAiu > 0) { %>
                    m_svt_chi_item.m_args = m_chi0_args;
                     <% } %>
                    m_snps_chi<%=cidx%>_vseq.set_unit_args(m_chi0_args);
                    fork
                    begin
                        phase.raise_objection(this, "CHIAIU<%=cidx%> sequence");
                        m_snps_chi<%=cidx%>_vseq.start(null);
                        `uvm_info("FULLSYS_TEST", "Done  read on processor<%=idx%> : CHIAIU<%=cidx%>", UVM_NONE)
                        //#5us;
                        phase.drop_objection(this, "CHIAIU<%=cidx%> sequence");
                    end
                    //begin
                      //  ev_chi<%=cidx%>_seq_done.wait_trigger();
                        //ev_sim_done.trigger(null);
                    //end
                    join  // TBD - logic implemented for SNPS, check inhouse code
                   `endif    //`ifndef USE_VIP_SNPS ... else
                   end
     <% cidx++;
    } else { %>
                <%=idx%>: begin  
                   `uvm_info("FULLSYS_TEST", "Start read on processor<%=idx%> : IOAIU<%=ncidx%>", UVM_NONE)
                   `ifndef USE_VIP_SNPS
                   <% for(var i=0; i<aiu_NumCores[idx]; i++) { %> 
                   fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_seq<%=ncidx%>[<%=i%>].k_num_read_req        = ioaiu_num_trans;
                   fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_seq<%=ncidx%>[<%=i%>].k_num_write_req       = 0;
                   fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_seq<%=ncidx%>[<%=i%>].k_directed_test_alloc = 1;
        <% if((obj.AiuInfo[idx].fnNativeInterface == 'ACE') || (obj.AiuInfo[idx].fnNativeInterface == 'ACE-LITE') || (obj.AiuInfo[idx].fnNativeInterface == 'ACELITE-E')) { %>
                   fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_seq<%=ncidx%>[<%=i%>].wt_ace_rdnosnp      = 50;
                   fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_seq<%=ncidx%>[<%=i%>].wt_ace_rdonce       = 0;
                   fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_seq<%=ncidx%>[<%=i%>].wt_ace_wrnosnp      = 0;
                   fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_seq<%=ncidx%>[<%=i%>].wt_ace_wrunq        = 0;
                   fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_seq<%=ncidx%>[<%=i%>].wt_ace_wrlnunq      = 0;
          <% if(obj.AiuInfo[idx].fnNativeInterface == 'ACE') { %>
                   fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_seq<%=ncidx%>[<%=i%>].wt_ace_rdshrd       = 0;
                   fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_seq<%=ncidx%>[<%=i%>].wt_ace_rdcln        = 0;
                   fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_seq<%=ncidx%>[<%=i%>].wt_ace_rdnotshrddty = 0;
                   fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_seq<%=ncidx%>[<%=i%>].wt_ace_rdunq        = 0;
                   fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_seq<%=ncidx%>[<%=i%>].wt_ace_wrcln        = 0;
                   fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_seq<%=ncidx%>[<%=i%>].wt_ace_wrbk         = 0;
                   fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_seq<%=ncidx%>[<%=i%>].wt_ace_wrevct       = 0;
                   fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_seq<%=ncidx%>[<%=i%>].wt_ace_dvm_msg      = 0;
                   fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_seq<%=ncidx%>[<%=i%>].wt_ace_dvm_sync     = 0;
          <% } %>
                   fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_seq<%=ncidx%>[<%=i%>].wt_ace_clnunq       = 0;
                   fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_seq<%=ncidx%>[<%=i%>].wt_ace_clnshrd      = 0;
                   fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_seq<%=ncidx%>[<%=i%>].wt_ace_clninvl      = 0;
                   fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_seq<%=ncidx%>[<%=i%>].wt_ace_mkunq        = 0;
                   fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_seq<%=ncidx%>[<%=i%>].wt_ace_mkinvl       = 0;
                   fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_seq<%=ncidx%>[<%=i%>].wt_ace_evct         = 0;
                   fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_seq<%=ncidx%>[<%=i%>].no_updates          = 0;
                   fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_seq<%=ncidx%>[<%=i%>].wt_ace_rd_bar       = 0;
                   fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_seq<%=ncidx%>[<%=i%>].wt_ace_wr_bar       = 0;
          <% if(obj.AiuInfo[idx].fnNativeInterface != 'ACE-LITE') { %>
                   fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_seq<%=ncidx%>[<%=i%>].wt_ace_atm_str      = 0;
                   fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_seq<%=ncidx%>[<%=i%>].wt_ace_atm_ld       = 0;
                   fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_seq<%=ncidx%>[<%=i%>].wt_ace_atm_swap     = 0;
                   fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_seq<%=ncidx%>[<%=i%>].wt_ace_atm_comp     = 0;
                   fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_seq<%=ncidx%>[<%=i%>].wt_ace_ptl_stash    = 0;
                   fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_seq<%=ncidx%>[<%=i%>].wt_ace_full_stash   = 0;
                   fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_seq<%=ncidx%>[<%=i%>].wt_ace_shared_stash = 0;
                   fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_seq<%=ncidx%>[<%=i%>].wt_ace_unq_stash    = 0;
                   fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_seq<%=ncidx%>[<%=i%>].wt_ace_stash_trans  = 0;
          <% } %>
      <% }%>
      <% }%>
                   `else
      <% for(var i=0; i<aiu_NumCores[pidx]; i++) { %> 
                    cust_seq_h<%=ncidx%>[<%=i%>].k_num_read_req        = ioaiu_num_trans;
                   cust_seq_h<%=ncidx%>[<%=i%>].k_num_write_req       = 0;
                   cust_seq_h<%=ncidx%>[<%=i%>].k_directed_test_alloc = 1;
        <% if((obj.AiuInfo[idx].fnNativeInterface == 'ACE') || (obj.AiuInfo[idx].fnNativeInterface == 'ACE-LITE') || (obj.AiuInfo[idx].fnNativeInterface == 'ACELITE-E')) { %>
                   cust_seq_h<%=ncidx%>[<%=i%>].wt_ace_rdnosnp      = 50;
                   cust_seq_h<%=ncidx%>[<%=i%>].wt_ace_rdonce       = 0;
                   cust_seq_h<%=ncidx%>[<%=i%>].wt_ace_wrnosnp      = 0;
                   cust_seq_h<%=ncidx%>[<%=i%>].wt_ace_wrunq        = 0;
                   cust_seq_h<%=ncidx%>[<%=i%>].wt_ace_wrlnunq      = 0;
          <% if(obj.AiuInfo[idx].fnNativeInterface == 'ACE') { %>
                   cust_seq_h<%=ncidx%>[<%=i%>].wt_ace_rdshrd       = 0;
                   cust_seq_h<%=ncidx%>[<%=i%>].wt_ace_rdcln        = 0;
                   cust_seq_h<%=ncidx%>[<%=i%>].wt_ace_rdnotshrddty = 0;
                   cust_seq_h<%=ncidx%>[<%=i%>].wt_ace_rdunq        = 0;
                   cust_seq_h<%=ncidx%>[<%=i%>].wt_ace_wrcln        = 0;
                   cust_seq_h<%=ncidx%>[<%=i%>].wt_ace_wrbk         = 0;
                   cust_seq_h<%=ncidx%>[<%=i%>].wt_ace_wrevct       = 0;
                   cust_seq_h<%=ncidx%>[<%=i%>].wt_ace_dvm_msg      = 0;
                   cust_seq_h<%=ncidx%>[<%=i%>].wt_ace_dvm_sync     = 0;
          <% } %>
                   cust_seq_h<%=ncidx%>[<%=i%>].wt_ace_clnunq       = 0;
                   cust_seq_h<%=ncidx%>[<%=i%>].wt_ace_clnshrd      = 0;
                   cust_seq_h<%=ncidx%>[<%=i%>].wt_ace_clninvl      = 0;
                   cust_seq_h<%=ncidx%>[<%=i%>].wt_ace_mkunq        = 0;
                   cust_seq_h<%=ncidx%>[<%=i%>].wt_ace_mkinvl       = 0;
                   cust_seq_h<%=ncidx%>[<%=i%>].wt_ace_evct         = 0;
                   cust_seq_h<%=ncidx%>[<%=i%>].no_updates          = 0;
                   cust_seq_h<%=ncidx%>[<%=i%>].wt_ace_rd_bar       = 0;
                   cust_seq_h<%=ncidx%>[<%=i%>].wt_ace_wr_bar       = 0;
          <% if(obj.AiuInfo[idx].fnNativeInterface != 'ACE-LITE') { %>
                   cust_seq_h<%=ncidx%>[<%=i%>].wt_ace_atm_str      = 0;
                   cust_seq_h<%=ncidx%>[<%=i%>].wt_ace_atm_ld       = 0;
                   cust_seq_h<%=ncidx%>[<%=i%>].wt_ace_atm_swap     = 0;
                   cust_seq_h<%=ncidx%>[<%=i%>].wt_ace_atm_comp     = 0;
                   cust_seq_h<%=ncidx%>[<%=i%>].wt_ace_ptl_stash    = 0;
                   cust_seq_h<%=ncidx%>[<%=i%>].wt_ace_full_stash   = 0;
                   cust_seq_h<%=ncidx%>[<%=i%>].wt_ace_shared_stash = 0;
                   cust_seq_h<%=ncidx%>[<%=i%>].wt_ace_unq_stash    = 0;
                   cust_seq_h<%=ncidx%>[<%=i%>].wt_ace_stash_trans  = 0;
          <% } %>
      <% }%>
    <% } %>
                `endif

                   fork
                   `ifndef USE_VIP_SNPS
                   <% for(var i=0; i<aiu_NumCores[idx]; i++) { %> 
                   begin
                   phase.raise_objection(this, "IOAIU<%=ncidx%>[<%=i%>] sequence");
                   fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_seq<%=ncidx%>[<%=i%>].start(null);
                   `uvm_info("FULLSYS_TEST", "Done  read on processor<%=idx%> : IOAIU<%=ncidx%>", UVM_NONE)
                   //#1us;
                   phase.drop_objection(this, "IOAIU<%=ncidx%> [<%=i%>]sequence");
                   end
                   begin
                       ev_ioaiu<%=ncidx%>_seq_done[<%=i%>].wait_trigger();
                       ev_sim_done.trigger(null);
                   end
                  <% } //foreach core%>
                   `else
                   <% for(var i=0; i<aiu_NumCores[idx]; i++) { %> 
                    begin
                     phase.raise_objection(this, "USE_VIP_SNPS IOAIU<%=ncidx%> sequence");
                     `uvm_info("FULLSYS_TEST", "USE_VIP_SNPS START cust_seq_h<%=ncidx%>[<%=i%>]", UVM_NONE)
                     uvm_config_db#(svt_axi_port_configuration)::set(null, "*", "port_cfg_ioaiu<%=ncidx%>_<%=i%>", m_concerto_env.snps.m_cfg.svt_cfg.axi_sys_cfg[0].master_cfg[<%=(aiu_rpn[idx]+i)-chi_idx%>]);
                      if(ioaiu_num_trans > 0)
                     cust_seq_h<%=ncidx%>[<%=i%>].start(m_concerto_env.snps.svt.amba_system_env.axi_system[0].sequencer);
                     #1us;
                     done_snp_cust_seq_h<%=ncidx%>.trigger(null);
                     `uvm_info("FULLSYS_TEST", "USE_VIP_SNPS DONE cust_seq_h<%=ncidx%>[<%=i%>]", UVM_NONE)
                     phase.drop_objection(this, "USE_VIP_SNPS IOAIU<%=ncidx%> sequence");
                     end
                  <% } //foreach core%>
                   `endif
                   join
                   end         
     <% ncidx++;
    }
  } %>
                endcase

//`endif //`ifndef USE_VIP_SNPS

                ev_sim_done.trigger(null);
            end
            begin
                #(sim_timeout_ms*1ms);
                timeout = 1;
            end
            join_any
`uvm_info("direct_legacy_TEST", "END EXEC_INHOUSE_SEQ", UVM_LOW)
endtask: exec_inhouse_seq

////////////////////////////////////////////////////////////////////
//#######  #     #  #     #   #####   #######  ###  #######  #     #  
//#        #     #  ##    #  #     #     #      #   #     #  ##    #  
//#        #     #  # #   #  #           #      #   #     #  # #   #  
//#####    #     #  #  #  #  #           #      #   #     #  #  #  #  
//#        #     #  #   # #  #           #      #   #     #  #   # #  
//#        #     #  #    ##  #     #     #      #   #     #  #    ##  
//#         #####   #     #   #####      #     ###  #######  #     #  
/////////////////////////////////
