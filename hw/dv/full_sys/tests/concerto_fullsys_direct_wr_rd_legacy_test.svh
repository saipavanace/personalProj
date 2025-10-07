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
let aceaiu0;  // strRtlNamePrefix of aceaiuu0;   // strRtlNamePrefix of aceaiu0
let csrAccess_ioaiu;
let csrAccess_chiaiu;
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
   let aiu_idx = 0;
   let idx = 0;
   let cidx=0;
   let ncidx=0;
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
    if(obj.AiuInfo[pidx].fnNativeInterface.match('CHI')) 
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
                            if(item.fnNativeInterface.match('CHI')) { 
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
                            if(item.fnNativeInterface.match('CHI')) { 
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
// LEGACY use with concerto_fullsys_direct_wr_rd_legacy_test +k_directed_test_wr_rd=1 
//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

class concerto_fullsys_direct_wr_rd_legacy_test extends concerto_fullsys_test; 

  `uvm_component_utils(concerto_fullsys_direct_wr_rd_legacy_test)

  //ATTRIBUTS
   bit [ncoreConfigInfo::W_SEC_ADDR-1:0] all_dmi_dii_start_addr[int][$]; 
   bit [ncoreConfigInfo::W_SEC_ADDR-1:0] all_dii_start_addr[int][$]; 
   bit [ncoreConfigInfo::W_SEC_ADDR-1:0] all_dmi_start_addr[int][$]; 
   
  //METHOD 
   // UVM PHASE
   extern virtual function void end_of_elaboration_phase(uvm_phase phase);
   extern virtual task exec_inhouse_seq (uvm_phase phase);
 
    extern virtual task directed_test_addr();
    extern virtual task directed_read_test(integer proc_num, uvm_phase phase);
    extern virtual task directed_atomic_test_all_chiaius_CONC_11504(uvm_phase phase);
    extern virtual task directed_write_read_test_all_ioaius_CONC_11133(uvm_phase phase);
    extern virtual task directed_write_read_test_all_aius_CONC_11133(uvm_phase phase);
    extern virtual task directed_atomic_test_all_aius_CONC_11504(uvm_phase phase);
    extern virtual task directed_write_read_test_all_aius_random(uvm_phase phase);
    extern virtual function bit [255:0] perform_atomic_op(string atomic_op, bit [63:0] atomic_initial_data, bit [63:0]atomic_txndata, int num_bytes=2,   input bit [ncoreConfigInfo::W_SEC_ADDR-1:0] addr=0);
    extern virtual task directed_write_read_test(integer proc_num, uvm_phase phase);
    extern virtual task directed_write_read_test_all_aius(uvm_phase phase);
    extern virtual task directed_write_read_test_all_chiaius_CONC_11133(uvm_phase phase);
    extern         task data_integrity_wr_rd();
    extern         task ioaiu_wun_wlunq();
 <% for(idx = 0, qidx=0; idx < obj.nAIUs; idx++) { 
    if(!(obj.AiuInfo[idx].fnNativeInterface.match('CHI'))) { %>
    extern virtual task write_ioaiu<%=qidx%>(input ioaiu<%=qidx%>_axi_agent_pkg::axi_axaddr_t addr, int len, int size, bit[1023:0] data, int coh);
    extern virtual task read_ioaiu<%=qidx%>(input ioaiu<%=qidx%>_axi_agent_pkg::axi_axaddr_t addr, int len, int size, output bit[1023:0] data);
    extern virtual task read_ioaiu_rdonce<%=qidx%>(input ioaiu<%=qidx%>_axi_agent_pkg::axi_axaddr_t addr, int len, int size, output bit[1023:0] data);
`ifdef USE_VIP_SNPS
    <%if(numACEAiu>1 && obj.AiuInfo[idx].fnNativeInterface == 'ACE'){%>
    extern virtual task read_ioaiu_rdunq<%=qidx%>(input ioaiu<%=qidx%>_axi_agent_pkg::axi_axaddr_t addr, int len, int size);
    extern virtual task read_ioaiu_rd_all<%=qidx%>(input ioaiu<%=qidx%>_axi_agent_pkg::axi_axaddr_t addr, int len, int size);
    extern virtual task write_ioaiu_wlunq<%=qidx%>(input ioaiu<%=qidx%>_axi_agent_pkg::axi_axaddr_t addr, int len, int size);
    extern virtual task write_ioaiu_wrevict<%=qidx%>(input ioaiu<%=qidx%>_axi_agent_pkg::axi_axaddr_t addr, int len, int size);
    <%} %>
`endif //`ifdef USE_VIP_SNPS
    ioaiu<%=qidx%>_axi_agent_pkg::axi_virtual_sequencer  m_ioaiu_vseqr<%=qidx%>[<%=aiu_NumCores[idx]%>];
     <% 
      qidx++; 
      }
    } %>

  function new(string name = "concerto_fullsys_direct_wr_rd_legacy_test", uvm_component parent=null);
    super.new(name,parent);
  endfunction: new

  

endclass: concerto_fullsys_direct_wr_rd_legacy_test


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
 function void concerto_fullsys_direct_wr_rd_legacy_test::end_of_elaboration_phase (uvm_phase phase);
  super.end_of_elaboration_phase(phase);
<% for(pidx = 0,qidx=0 ; pidx < obj.nAIUs; pidx++) { %>
      <% if (!(obj.AiuInfo[pidx].fnNativeInterface.match('CHI'))) { %>
      <% for(let coreidx=0; coreidx<aiu_NumCores[pidx]; coreidx++) { %> 
     if(!(uvm_config_db#(ioaiu<%=qidx%>_axi_agent_pkg::axi_virtual_sequencer)::get(.cntxt( null ),.inst_name( "" ),.field_name( "m_ioaiu_vseqr<%=qidx%>[<%=coreidx%>]" ),.value( m_ioaiu_vseqr<%=qidx%>[<%=coreidx%>] ) ))) begin
     `uvm_error(get_name(), "Cannot get m_ioaiu_vseqr<%=qidx%>[<%=coreidx%>]")
     end
      <% } %>
      <%  qidx++; } %>
    <% } %>
 endfunction:end_of_elaboration_phase

task concerto_fullsys_direct_wr_rd_legacy_test::exec_inhouse_seq (uvm_phase phase);
// OVERWRITE exec_inhouse_seq used in the main_phase

 int processor_a_num;
 int processor_b_num;
 bit [ncoreConfigInfo::W_SEC_ADDR-1:0] temp_addr;

 // preliminary create a queue of start addr by DII or DMI using in the task
 int ig;
 foreach (test_cfg.csrq[ig]) begin:_foreach_csrq_ig
            <% if (obj.wSysAddr > 44) {%> 
               temp_addr[43:12] = test_cfg.csrq[ig].low_addr;
               temp_addr[ncoreConfigInfo::W_SEC_ADDR-1:44] = test_cfg.csrq[ig].upp_addr; 
            <%} else {%>
              temp_addr[ncoreConfigInfo::W_SEC_ADDR-1:12] = test_cfg.csrq[ig].low_addr;
            <%}%>
           
             all_dmi_dii_start_addr[test_cfg.csrq[ig].mig_nunitid].push_back(temp_addr);
             if(test_cfg.csrq[ig].unit.name=="DII")
                all_dii_start_addr[test_cfg.csrq[ig].mig_nunitid].push_back(temp_addr);
             else 
                all_dmi_start_addr[test_cfg.csrq[ig].mig_nunitid].push_back(temp_addr);
  end:_foreach_csrq_ig
 
 `uvm_info("direct_wr_rd_legacy_TEST", "EXEC_INHOUSE_SEQ ", UVM_LOW)
 `uvm_info("WR_RD Traffic", ".... Generate Write - Read traffic", UVM_LOW)
  phase.raise_objection(this, "exec_inhouse_seq::directed_wr_rd");

  csr_init_done.trigger(null);

  #100ns; 
  
  if ($value$plusargs("use_user_addrq=%d", use_user_addrq)) begin:_use_user_addrq
      gen_addr_use_user_addrq();
  end:_use_user_addrq
  
  fork
 begin
   if (k_directed_data_integrity==0) begin
     directed_test_addr();

     if ($test$plusargs("k_directed_test_wr_rd_all_aius_random")) begin
        `uvm_info("VS", "Directed Write Read Test All AIUs random", UVM_LOW)
        directed_write_read_test_all_aius_random(phase);
     end
     else begin
         if ($test$plusargs("k_directed_test_wr_rd_all_aius") || $test$plusargs("k_directed_test_atomic_all_aius")) begin
            `uvm_info("VS", "Directed Write-Read/Atomic Test All AIUs", UVM_LOW)
            if (!$test$plusargs("k_directed_wr_rd_all_chiaius_to_all_targets_noncoh") && !$test$plusargs("k_directed_wr_rd_all_chiaius_to_all_targets_coh") && !$test$plusargs("k_directed_wr_rd_all_ioaius_to_all_targets_noncoh") &&  !$test$plusargs("k_directed_wr_rd_all_ioaius_to_all_targets_coh") && !$test$plusargs("k_directed_atomic_all_chiaius_to_all_targets")) begin
                directed_write_read_test_all_aius(phase);
            end else if($test$plusargs("k_directed_atomic_all_chiaius_to_all_targets")) begin
              directed_atomic_test_all_aius_CONC_11504(phase);
            end else begin
              directed_write_read_test_all_aius_CONC_11133(phase);
            end
         end
         else begin
            `uvm_info("VS", "Directed Write Read Test", UVM_LOW)
             if ($test$plusargs("k_directed_test_basic")) begin
                processor_a_num = 0;
             end
             else begin
                processor_a_num = $urandom_range(0,<%=obj.nAIUs-1%>);
             end
             directed_write_read_test(processor_a_num, phase);
         end
     end
    end
   else if(k_directed_wrunq_wrevict==1)begin 
     `uvm_info("VS", $sformatf("IOAIU<%=ncidx%> Write HERE before method call"), UVM_NONE)
       ioaiu_wun_wlunq();
   end
   else begin 
     `uvm_info("VS", $sformatf("IOAIU<%=ncidx%> Write HERE before method call"), UVM_LOW)
       data_integrity_wr_rd();
   end
     ev_sim_done.trigger(null);
 end  // fork
 begin
     #(sim_timeout_ms*1ms);
     timeout = 1;
 end
 join_any
 phase.drop_objection(this, "exec_inhouse_seq::directed_wr_rd");
`uvm_info("direct_wr_rd_legacy_TEST", "END EXEC_INHOUSE_SEQ", UVM_LOW)
endtask: exec_inhouse_seq

////////////////////////////////////////////////////////////////////
//#######  #     #  #     #   #####   #######  ###  #######  #     #  
//#        #     #  ##    #  #     #     #      #   #     #  ##    #  
//#        #     #  # #   #  #           #      #   #     #  # #   #  
//#####    #     #  #  #  #  #           #      #   #     #  #  #  #  
//#        #     #  #   # #  #           #      #   #     #  #   # #  
//#        #     #  #    ##  #     #     #      #   #     #  #    ##  
//#         #####   #     #   #####      #     ###  #######  #     #  
////////////////////////////////

//************************************************************************************
task concerto_fullsys_direct_wr_rd_legacy_test::directed_atomic_test_all_chiaius_CONC_11504(uvm_phase phase);
bit bypass_data_in_data_out_checks=0;
bit use_single_mem_region_in_test=0;
int test_k_device_type_mem_pct=0;
bit is_device_mem = 0;
bit en_atomic_op[string];
bit atomicStore, atomicLoad, atomicSwap, atomicCompare;


   if($value$plusargs("AtomicStore_ADD=%0b",en_atomic_op["AtomicStore_ADD"])) begin
       `uvm_info("VS", $psprintf("Plusarg is set to run AtomicStore_ADD"), UVM_LOW)
   end
   else if($value$plusargs("AtomicStore_CLR=%0b",en_atomic_op["AtomicStore_CLR"])) begin
       `uvm_info("VS", $psprintf("Plusarg is set to run AtomicStore_CLR"), UVM_LOW)
   end
   else if($value$plusargs("AtomicStore_OR=%0b",en_atomic_op["AtomicStore_OR"])) begin
       `uvm_info("VS", $psprintf("Plusarg is set to run AtomicStore_OR"), UVM_LOW)
   end
   else if($value$plusargs("AtomicStore_SET=%0b",en_atomic_op["AtomicStore_SET"])) begin
       `uvm_info("VS", $psprintf("Plusarg is set to run AtomicStore_SET"), UVM_LOW)
   end
   else if($value$plusargs("AtomicStore_MAX=%0b",en_atomic_op["AtomicStore_MAX"])) begin
       `uvm_info("VS", $psprintf("Plusarg is set to run AtomicStore_MAX"), UVM_LOW)
   end
   else if($value$plusargs("AtomicStore_MIN=%0b",en_atomic_op["AtomicStore_MIN"])) begin
       `uvm_info("VS", $psprintf("Plusarg is set to run AtomicStore_MIN"), UVM_LOW)
   end
   else if($value$plusargs("AtomicStore_UMAX=%0b",en_atomic_op["AtomicStore_UMAX"])) begin
       `uvm_info("VS", $psprintf("Plusarg is set to run AtomicStore_UMAX"), UVM_LOW)
   end
   else if($value$plusargs("AtomicStore_UMIN=%0b",en_atomic_op["AtomicStore_UMIN"])) begin
       `uvm_info("VS", $psprintf("Plusarg is set to run AtomicStore_UMIN"), UVM_LOW)
   end
   else if($value$plusargs("AtomicLoad_ADD=%0b",en_atomic_op["AtomicLoad_ADD"])) begin
       `uvm_info("VS", $psprintf("Plusarg is set to run AtomicLoad_ADD"), UVM_LOW)
   end
   else if($value$plusargs("AtomicLoad_CLR=%0b",en_atomic_op["AtomicLoad_CLR"])) begin
       `uvm_info("VS", $psprintf("Plusarg is set to run AtomicLoad_CLR"), UVM_LOW)
   end
   else if($value$plusargs("AtomicLoad_OR=%0b",en_atomic_op["AtomicLoad_OR"])) begin
       `uvm_info("VS", $psprintf("Plusarg is set to run AtomicLoad_OR"), UVM_LOW)
   end
   else if($value$plusargs("AtomicLoad_SET=%0b",en_atomic_op["AtomicLoad_SET"])) begin
       `uvm_info("VS", $psprintf("Plusarg is set to run AtomicLoad_SET"), UVM_LOW)
   end
   else if($value$plusargs("AtomicLoad_MAX=%0b",en_atomic_op["AtomicLoad_MAX"])) begin
       `uvm_info("VS", $psprintf("Plusarg is set to run AtomicLoad_MAX"), UVM_LOW)
   end
   else if($value$plusargs("AtomicLoad_MIN=%0b",en_atomic_op["AtomicLoad_MIN"])) begin
       `uvm_info("VS", $psprintf("Plusarg is set to run AtomicLoad_MIN"), UVM_LOW)
   end
   else if($value$plusargs("AtomicLoad_UMAX=%0b",en_atomic_op["AtomicLoad_UMAX"])) begin
       `uvm_info("VS", $psprintf("Plusarg is set to run AtomicLoad_UMAX"), UVM_LOW)
   end
   else if($value$plusargs("AtomicLoad_UMIN=%0b",en_atomic_op["AtomicLoad_UMIN"])) begin
       `uvm_info("VS", $psprintf("Plusarg is set to run AtomicLoad_UMIN"), UVM_LOW)
   end
   else if($value$plusargs("AtomicSwap=%0b",en_atomic_op["AtomicSwap"])) begin
       `uvm_info("VS", $psprintf("Plusarg is set to run AtomicSwap"), UVM_LOW)
   end
   else if($value$plusargs("AtomicCompare=%0b",en_atomic_op["AtomicCompare"])) begin
       `uvm_info("VS", $psprintf("Plusarg is set to run AtomicCompare"), UVM_LOW)
   end else begin // by default
    en_atomic_op["AtomicStore_ADD"]=1;
   end

   if(
      en_atomic_op["AtomicStore_ADD"] || en_atomic_op["AtomicStore_CLR"] || en_atomic_op["AtomicStore_OR"] || en_atomic_op["AtomicStore_SET"] ||
      en_atomic_op["AtomicStore_MAX"] || en_atomic_op["AtomicStore_MIN"] || en_atomic_op["AtomicStore_UMAX"] || en_atomic_op["AtomicStore_UMIN"]
   ) begin
       atomicStore = 1;
   end
   else if(
      en_atomic_op["AtomicLoad_ADD"] || en_atomic_op["AtomicLoad_CLR"] || en_atomic_op["AtomicLoad_OR"] || en_atomic_op["AtomicLoad_SET"] ||
      en_atomic_op["AtomicLoad_MAX"] || en_atomic_op["AtomicLoad_MIN"] || en_atomic_op["AtomicLoad_UMAX"] || en_atomic_op["AtomicLoad_UMIN"]
   ) begin
       atomicLoad = 1;
   end
   else if(en_atomic_op["AtomicSwap"]) begin
       atomicSwap = 1;
   end
   else if(en_atomic_op["AtomicCompare"]) begin
       atomicCompare = 1;
   end
`uvm_info("VS", $psprintf("Inside directed_atomic_test_all_chiaius_CONC_11504"), UVM_LOW)
//`ifdef TEMP
   if($value$plusargs("k_device_type_mem_pct=%d",test_k_device_type_mem_pct)) begin
       `uvm_info("VS", $psprintf("Setting k_device_type_mem_pct to %0d",test_k_device_type_mem_pct), UVM_LOW)
   end
   if(test_k_device_type_mem_pct==100) begin
       is_device_mem = 1;
   end else if(test_k_device_type_mem_pct==0) begin
       is_device_mem = 0;
   end else begin
       `uvm_info("VS", $psprintf("plusarg k_device_type_mem_pct is set to %0d. Please correct the value of plusarg k_device_type_mem_pct to 100 if Device memory test or 0 if Normal memory test",test_k_device_type_mem_pct), UVM_LOW)
   end
       
   `uvm_info("VS", "Directed Write/ Read Test All CHIAIUs", UVM_LOW)
    `ifndef USE_VIP_SNPS //existing flow will not run when USE_VIP_SNPS set
/// don't use CHI boot anymore //<% if ((found_csr_access_chiaiu > 0) && (found_csr_access_ioaiu > 0)) { %>
/// don't use CHI boot anymore //    if(boot_from_ioaiu == 1) begin
/// don't use CHI boot anymore //    end else begin
/// don't use CHI boot anymore //        foreach(m_chi0_vseq.all_dmi_dii_start_addr[x]) begin
/// don't use CHI boot anymore //          foreach(m_chi0_vseq.all_dmi_dii_start_addr[x][y]) begin
/// don't use CHI boot anymore //            all_dmi_dii_start_addr[x].push_back(m_chi0_vseq.all_dmi_dii_start_addr[x][y]);
/// don't use CHI boot anymore //          end
/// don't use CHI boot anymore //        end
/// don't use CHI boot anymore //        foreach(m_chi0_vseq.all_dii_start_addr[x]) begin
/// don't use CHI boot anymore //          foreach(m_chi0_vseq.all_dii_start_addr[x][y]) begin
/// don't use CHI boot anymore //            all_dii_start_addr[x].push_back(m_chi0_vseq.all_dii_start_addr[x][y]);
/// don't use CHI boot anymore //          end
/// don't use CHI boot anymore //        end
/// don't use CHI boot anymore //        foreach(m_chi0_vseq.all_dmi_start_addr[x]) begin
/// don't use CHI boot anymore //          foreach(m_chi0_vseq.all_dmi_start_addr[x][y]) begin
/// don't use CHI boot anymore //            all_dmi_start_addr[x].push_back(m_chi0_vseq.all_dmi_start_addr[x][y]);
/// don't use CHI boot anymore //          end
/// don't use CHI boot anymore //        end
/// don't use CHI boot anymore //    end // else: !if(boot_from_ioaiu == 1)
/// don't use CHI boot anymore //<% } else {%>
/// don't use CHI boot anymore //<%   if(found_csr_access_chiaiu > 0) { %>
/// don't use CHI boot anymore //        foreach(m_chi0_vseq.all_dmi_dii_start_addr[x]) begin
/// don't use CHI boot anymore //          foreach(m_chi0_vseq.all_dmi_dii_start_addr[x][y]) begin
/// don't use CHI boot anymore //            all_dmi_dii_start_addr[x].push_back(m_chi0_vseq.all_dmi_dii_start_addr[x][y]);
/// don't use CHI boot anymore //          end
/// don't use CHI boot anymore //        end
/// don't use CHI boot anymore //        foreach(m_chi0_vseq.all_dii_start_addr[x]) begin
/// don't use CHI boot anymore //          foreach(m_chi0_vseq.all_dii_start_addr[x][y]) begin
/// don't use CHI boot anymore //            all_dii_start_addr[x].push_back(m_chi0_vseq.all_dii_start_addr[x][y]);
/// don't use CHI boot anymore //          end
/// don't use CHI boot anymore //        end
/// don't use CHI boot anymore //        foreach(m_chi0_vseq.all_dmi_start_addr[x]) begin
/// don't use CHI boot anymore //          foreach(m_chi0_vseq.all_dmi_start_addr[x][y]) begin
/// don't use CHI boot anymore //            all_dmi_start_addr[x].push_back(m_chi0_vseq.all_dmi_start_addr[x][y]);
/// don't use CHI boot anymore //          end
/// don't use CHI boot anymore //        end
/// don't use CHI boot anymore //   <% } else { %>
/// don't use CHI boot anymore //   <% if (found_csr_access_ioaiu > 0) { %>
/// don't use CHI boot anymore //<% } } } %>
`endif
   
  if($test$plusargs("bypass_data_in_data_out_checks"))  bypass_data_in_data_out_checks=1;
  if($test$plusargs("use_single_mem_region_in_test"))   use_single_mem_region_in_test=1;
  <% for(idx = 0, cidx=0, ncidx=0; idx < obj.nAIUs; idx++) { 
    if(obj.AiuInfo[idx].fnNativeInterface == 'CHI-B') { %>
    `ifndef USE_VIP_SNPS //existing flow will not run when USE_VIP_SNPS set
                begin 
                    bit [511:0] data_in, data_in_1;
                    bit [511:0] data_out, data_out_1;
                    chiaiu<%=cidx%>_chi_aiu_vseq_pkg::chi_bfm_opcode_type_t atomic_op_type;
                    chiaiu<%=cidx%>_chi_aiu_vseq_pkg::chi_bfm_opcode_t atomic_op;
                    bit [63:0] atomic_compare_data, atomic_swap_data;
                    bit [127:0] atomic_txndata, atomic_initial_data;
                    bit [ncoreConfigInfo::W_SEC_ADDR-1:0] addr;
                    bit [ncoreConfigInfo::W_SEC_ADDR-1:0] coh_addr;
                    bit [ncoreConfigInfo::W_SEC_ADDR-1:0] non_coh_addr;
                    bit [ncoreConfigInfo::W_SEC_ADDR-1:0] aligned_addr_wrt_total_bytes_lower, aligned_addr_wrt_total_bytes_upper;
                    int drop_bytes_for_device_mem;
                    bit [5:0] idx_val = <%=idx%>;
                    int data_size;
                    int wData;
                   `uvm_info("FULLSYS_TEST", "Start write/read on processor<%=idx%> : CHIAIU<%=cidx%>", UVM_NONE)

                    <% if (obj.AiuInfo[idx].wData == 128) { %>
                        wData = 128;
                    <% } else if (obj.AiuInfo[idx].wData == 256) { %> 
                         wData = 256;
                    <% } else { %>
                         wData = 512;
                    <% } %>
                    `uvm_info("VS", $sformatf("wData<%=cidx%> = %d", wData), UVM_LOW)
                       
                    if ($test$plusargs("k_directed_test_all_coh")) begin
                       m_chi<%=cidx%>_args.k_coh_addr_pct.set_value(100);
                    end
                    else begin
                       m_chi<%=cidx%>_args.k_coh_addr_pct.set_value(k_directed_test_coh_addr_pct);
                    end

                    if ($test$plusargs("k_directed_test_all_non_coh")) begin
                       m_chi<%=cidx%>_args.k_noncoh_addr_pct.set_value(100);
                    end 
                    else begin
                       m_chi<%=cidx%>_args.k_noncoh_addr_pct.set_value(k_directed_test_noncoh_addr_pct);
                    end
                    // m_chi<%=cidx%>_args.k_new_addr_pct.set_value(100);
                    m_chi<%=cidx%>_args.k_rd_noncoh_pct.set_value(0);
                    m_chi<%=cidx%>_args.k_rd_ldrstr_pct.set_value(0);
                    m_chi<%=cidx%>_args.k_rd_rdonce_pct.set_value(0);
                    if ($test$plusargs("k_directed_test_all_non_coh")) begin
                        m_chi<%=cidx%>_args.k_wr_noncoh_pct.set_value(100);
                        m_chi<%=cidx%>_args.k_rd_noncoh_pct.set_value(0);
                    end
                    else begin
                        m_chi<%=cidx%>_args.k_wr_noncoh_pct.set_value(k_directed_test_noncoh_addr_pct);
                    end
                    if ($test$plusargs("k_directed_test_all_coh")) begin
                        m_chi<%=cidx%>_args.k_wr_cohunq_pct.set_value(100);
                    end
                    else begin
                        m_chi<%=cidx%>_args.k_wr_cohunq_pct.set_value(k_directed_test_coh_addr_pct);
                    end
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
                      for(int crit_dw=0;crit_dw<8;crit_dw=crit_dw+1) begin // for each critical DW
                         for (int j = ((atomicCompare==1)?2:1); j <((atomicCompare==1)?5:4); j++) begin
                           if($test$plusargs("k_directed_test_wr_rd_to_all_dmi")) begin
                             for(int all_dmi=0;all_dmi<(use_single_mem_region_in_test ? 1 :all_dmi_start_addr[<%=aiu_rpn[idx]%>].size());all_dmi=all_dmi+1) begin // for each DMI 
                               for (int i = 0; i < chi_num_trans; i++) begin
                                  m_chi<%=cidx%>_args.k_wr_noncoh_pct.set_value(100);
                                  m_chi<%=cidx%>_args.k_rd_noncoh_pct.set_value(0);
                                  m_chi<%=cidx%>_args.k_coh_addr_pct.set_value(0);
                                  m_chi<%=cidx%>_args.k_noncoh_addr_pct.set_value(100);
                                  m_chi<%=cidx%>_args.k_device_type_mem_pct.set_value(test_k_device_type_mem_pct);
                                  m_chi<%=cidx%>_vseq.set_unit_args(m_chi<%=cidx%>_args);
                                  assert(std::randomize(data_out));
                                  data_size = j;  // 2,4,8,16,32,64 bytes
                                  //non_coh_addr = ncoreConfigInfo::user_addrq[ncoreConfigInfo::NONCOH][i];
                                  //non_coh_addr[12:0] = {idx_val,7'b0000000};
                                  non_coh_addr = all_dmi_start_addr[<%=obj.AiuInfo[idx].rpn%>][all_dmi] + (i*64);
                                  non_coh_addr[5:3] = crit_dw;
                                  addr = non_coh_addr;
                                  if(is_device_mem) begin
                                      aligned_addr_wrt_total_bytes_lower =  (addr >> data_size) << data_size;
                                      aligned_addr_wrt_total_bytes_upper =  aligned_addr_wrt_total_bytes_lower + (2 ** data_size);
                                      drop_bytes_for_device_mem = addr - aligned_addr_wrt_total_bytes_lower;
                                  end

                                  `uvm_info("VS", $sformatf("CHI<%=cidx%> DMI Target GPR[%0d] Non-coherent Write Address = 0x%x,size = %d, Write Data = %x Critical DW=%0d",all_dmi, non_coh_addr, data_size, data_out,crit_dw), UVM_LOW) 
                                  m_chi<%=cidx%>_vseq.write_memory(non_coh_addr, data_out, data_size, 0);

                                  m_chi<%=cidx%>_args.k_wr_noncoh_pct.set_value(0);
                                  m_chi<%=cidx%>_args.k_coh_addr_pct.set_value(100);
                                  m_chi<%=cidx%>_args.k_noncoh_addr_pct.set_value(0);
                                  if(atomicStore) begin
                                      atomic_op_type=chiaiu<%=cidx%>_chi_bfm_types_pkg::ATOMIC_ST_CMD;

                                      if(en_atomic_op["AtomicStore_ADD"]) begin
                                          atomic_op = chiaiu<%=cidx%>_chi_bfm_types_pkg::BFM_ATOMICSTORE_STADD;
                                      end else if (en_atomic_op["AtomicStore_CLR"]) begin
                                          atomic_op = chiaiu<%=cidx%>_chi_bfm_types_pkg::BFM_ATOMICSTORE_STCLR;
                                      end else if (en_atomic_op["AtomicStore_OR"]) begin
                                          atomic_op = chiaiu<%=cidx%>_chi_bfm_types_pkg::BFM_ATOMICSTORE_STEOR;
                                      end else if (en_atomic_op["AtomicStore_SET"]) begin
                                          atomic_op = chiaiu<%=cidx%>_chi_bfm_types_pkg::BFM_ATOMICSTORE_STSET;
                                      end else if (en_atomic_op["AtomicStore_MAX"]) begin
                                          atomic_op = chiaiu<%=cidx%>_chi_bfm_types_pkg::BFM_ATOMICSTORE_STSMAX;
                                      end else if (en_atomic_op["AtomicStore_MIN"]) begin
                                          atomic_op = chiaiu<%=cidx%>_chi_bfm_types_pkg::BFM_ATOMICSTORE_STMIN;
                                      end else if (en_atomic_op["AtomicStore_UMAX"]) begin
                                          atomic_op = chiaiu<%=cidx%>_chi_bfm_types_pkg::BFM_ATOMICSTORE_STUSMAX;
                                      end else if (en_atomic_op["AtomicStore_UMIN"]) begin
                                          atomic_op = chiaiu<%=cidx%>_chi_bfm_types_pkg::BFM_ATOMICSTORE_STUMIN;
                                      end
                                      m_chi<%=cidx%>_args.k_atomic_st_pct.set_value(100);
                                      m_chi<%=cidx%>_args.k_atomic_ld_pct.set_value(0);
                                      m_chi<%=cidx%>_args.k_atomic_sw_pct.set_value(0);
                                      m_chi<%=cidx%>_args.k_atomic_cm_pct.set_value(0);
                                      assert(std::randomize(atomic_txndata));
                                      //atomic_txndata = 0;
                                      m_chi<%=cidx%>_vseq.set_unit_args(m_chi<%=cidx%>_args);
                                      m_chi<%=cidx%>_vseq.atomic(atomic_op_type,atomic_op,0,non_coh_addr, atomic_txndata, data_size, 0, wData, atomic_initial_data);
                                  end
                                  else if(atomicLoad) begin
                                      atomic_op_type=chiaiu<%=cidx%>_chi_bfm_types_pkg::ATOMIC_LD_CMD;
                                      m_chi<%=cidx%>_args.k_atomic_st_pct.set_value(0);
                                      m_chi<%=cidx%>_args.k_atomic_ld_pct.set_value(100);
                                      m_chi<%=cidx%>_args.k_atomic_sw_pct.set_value(0);
                                      m_chi<%=cidx%>_args.k_atomic_cm_pct.set_value(0);
                                      if(en_atomic_op["AtomicLoad_ADD"]) begin
                                          atomic_op = chiaiu<%=cidx%>_chi_bfm_types_pkg::BFM_ATOMICLOAD_LDADD;
                                      end else if (en_atomic_op["AtomicLoad_CLR"]) begin
                                          atomic_op = chiaiu<%=cidx%>_chi_bfm_types_pkg::BFM_ATOMICLOAD_LDCLR;
                                      end else if (en_atomic_op["AtomicLoad_OR"]) begin
                                          atomic_op = chiaiu<%=cidx%>_chi_bfm_types_pkg::BFM_ATOMICLOAD_LDEOR;
                                      end else if (en_atomic_op["AtomicLoad_SET"]) begin
                                          atomic_op = chiaiu<%=cidx%>_chi_bfm_types_pkg::BFM_ATOMICLOAD_LDSET;
                                      end else if (en_atomic_op["AtomicLoad_MAX"]) begin
                                          atomic_op = chiaiu<%=cidx%>_chi_bfm_types_pkg::BFM_ATOMICLOAD_LDSMAX;
                                      end else if (en_atomic_op["AtomicLoad_MIN"]) begin
                                          atomic_op = chiaiu<%=cidx%>_chi_bfm_types_pkg::BFM_ATOMICLOAD_LDMIN;
                                      end else if (en_atomic_op["AtomicLoad_UMAX"]) begin
                                          atomic_op = chiaiu<%=cidx%>_chi_bfm_types_pkg::BFM_ATOMICLOAD_LDUSMAX;
                                      end else if (en_atomic_op["AtomicLoad_UMIN"]) begin
                                          atomic_op = chiaiu<%=cidx%>_chi_bfm_types_pkg::BFM_ATOMICLOAD_LDUMIN;
                                      end
                                      assert(std::randomize(atomic_txndata));
                                      //atomic_txndata = 0;
                                      m_chi<%=cidx%>_vseq.set_unit_args(m_chi<%=cidx%>_args);
                                      m_chi<%=cidx%>_vseq.atomic(atomic_op_type,atomic_op,0,non_coh_addr, atomic_txndata, data_size, 0, wData, atomic_initial_data);
                                  end
                                  else if(atomicSwap) begin
                                      atomic_op_type=chiaiu<%=cidx%>_chi_bfm_types_pkg::ATOMIC_SW_CMD;
                                      atomic_op=chiaiu<%=cidx%>_chi_bfm_types_pkg::BFM_ATOMICSWAP;
                                      m_chi<%=cidx%>_args.k_atomic_st_pct.set_value(0);
                                      m_chi<%=cidx%>_args.k_atomic_ld_pct.set_value(0);
                                      m_chi<%=cidx%>_args.k_atomic_sw_pct.set_value(100);
                                      m_chi<%=cidx%>_args.k_atomic_cm_pct.set_value(0);
                                      assert(std::randomize(atomic_txndata));
                                      //atomic_txndata = 0;
                                      m_chi<%=cidx%>_vseq.set_unit_args(m_chi<%=cidx%>_args);
                                      m_chi<%=cidx%>_vseq.atomic(atomic_op_type,atomic_op,0,non_coh_addr, atomic_txndata, data_size, 0, wData,atomic_initial_data);
                                  end
                                  else if(atomicCompare) begin
                                      atomic_op_type=chiaiu<%=cidx%>_chi_bfm_types_pkg::ATOMIC_CM_CMD;
                                      atomic_op=chiaiu<%=cidx%>_chi_bfm_types_pkg::BFM_ATOMICCOMPARE;
                                      m_chi<%=cidx%>_args.k_atomic_st_pct.set_value(0);
                                      m_chi<%=cidx%>_args.k_atomic_ld_pct.set_value(0);
                                      m_chi<%=cidx%>_args.k_atomic_sw_pct.set_value(0);
                                      m_chi<%=cidx%>_args.k_atomic_cm_pct.set_value(100);
                                      assert(std::randomize(atomic_txndata));
                                      //atomic_txndata = 0;
                                      if($test$plusargs("AtomicCompare_case1")) begin
                                          case(data_size)
                                          2 : atomic_txndata[15:0] = data_out[15:0];
                                          3 : atomic_txndata[31:0] = data_out[31:0];
                                          4 : atomic_txndata[63:0] = data_out[63:0];
                                          endcase
                                      end
                                      m_chi<%=cidx%>_vseq.set_unit_args(m_chi<%=cidx%>_args);
                                      m_chi<%=cidx%>_vseq.atomic(atomic_op_type,atomic_op,0,non_coh_addr, atomic_txndata, data_size, 0, wData,atomic_initial_data);
                                  end
                                  

                                  m_chi<%=cidx%>_args.k_coh_addr_pct.set_value(0);
                                  m_chi<%=cidx%>_args.k_noncoh_addr_pct.set_value(100);
                                  m_chi<%=cidx%>_args.k_wr_noncoh_pct.set_value(0);
                                  m_chi<%=cidx%>_args.k_rd_noncoh_pct.set_value(100);
                                  m_chi<%=cidx%>_args.k_device_type_mem_pct.set_value(test_k_device_type_mem_pct);
                                  m_chi<%=cidx%>_vseq.set_unit_args(m_chi<%=cidx%>_args);

                                  m_chi<%=cidx%>_vseq.read_memory(non_coh_addr, data_in, data_size, wData);
                                  `uvm_info("VS", $sformatf("CHI<%=cidx%> DMI Target GPR[%0d] Non-coherent Read Address = 0x%x,size = %d,  Read Data = %x Critical DW=%0d", all_dmi,non_coh_addr, data_size,data_in,crit_dw), UVM_LOW)

                                  for(int set_zero_bits=(8 * (2 ** data_size)); set_zero_bits<512; set_zero_bits=set_zero_bits+1) begin
                                      data_out[set_zero_bits] = 1'b0; data_in[set_zero_bits] = 1'b0;
                                      if(atomicStore || atomicLoad || atomicSwap || atomicCompare) begin
                                          atomic_txndata[set_zero_bits] = 1'b0;
                                      end // if(atomicStore) begin
                                      if(atomicLoad || atomicSwap || atomicCompare) begin
                                          atomic_initial_data[set_zero_bits] = 1'b0;
                                      end // if(atomicLoad) begin
                                  end
                                  case (data_size)
                                     1: begin
                                     if(atomicLoad || atomicSwap) begin
                                         if (data_out[15:0] != atomic_initial_data[15:0]) begin
                                           if(!bypass_data_in_data_out_checks) 
                                               `uvm_error("VS", $sformatf("Data Mismatch CHI<%=cidx%>. Address = %x, xfer size 2B, Write Data = %x, Read Data = %x", non_coh_addr, data_out[15:0], atomic_initial_data[15:0]))
                                           else
                                           `uvm_info("VS",$sformatf("Data Mismatch CHI<%=cidx%>. Address = %x, xfer size 2B, Write Data = %x, Read Data = %x", non_coh_addr, data_out[15:0], atomic_initial_data[15:0]),UVM_NONE)
                                         end
                                         else begin
                                             `uvm_info("VS", $sformatf("CHIAIU<%=cidx%> Data Transfer Write-Read Test Match. DMI Target GPR[%0d] Address = %x, xfer size 2B, Write Data = %x, Read Data = %x Critical DW=%0d",all_dmi, non_coh_addr, data_out[15:0], atomic_initial_data[15:0],crit_dw), UVM_LOW)
                                         end
                                     end // if(atomicLoad) begin
                                     if(atomicStore || atomicLoad || atomicSwap) begin
                                         if(atomicStore || atomicLoad) begin
                                             data_out = perform_atomic_op(atomic_op.name,data_out,atomic_txndata,2,non_coh_addr);
                                         end
                                         else if(atomicSwap)
                                             data_out = atomic_txndata;
                                         if (data_out[15:0] != data_in[15:0]) begin
                                           if(!bypass_data_in_data_out_checks) 
                                               `uvm_error("VS", $sformatf("Data Mismatch CHI<%=cidx%>. Address = %x, xfer size 2B, Write Data = %x, Read Data = %x", non_coh_addr, data_out[15:0], data_in[15:0]))
                                           else
                                           `uvm_info("VS",$sformatf("Data Mismatch CHI<%=cidx%>. Address = %x, xfer size 2B, Write Data = %x, Read Data = %x", non_coh_addr, data_out[15:0], data_in[15:0]),UVM_NONE)
                                         end
                                         else begin
                                             `uvm_info("VS", $sformatf("CHIAIU<%=cidx%> Data Transfer Write-Read Test Match. DMI Target GPR[%0d] Address = %x, xfer size 2B, Write Data = %x, Read Data = %x Critical DW=%0d",all_dmi, non_coh_addr, data_out[15:0], data_in[15:0],crit_dw), UVM_LOW)
                                         end
                                     end // if(atomicStore) begin
                                        end
                                     2: begin
                                     if(atomicLoad || atomicSwap || atomicCompare) begin
                                         if(atomicCompare) begin
                                             data_out[31:16] = 0;
                                             atomic_initial_data[31:16] = 0;
                                             data_in[31:16] = 0;
                                         end
                                         if (data_out[31:0] != atomic_initial_data[31:0]) begin
                                           if(!bypass_data_in_data_out_checks) 
                                               `uvm_error("VS", $sformatf("Data Mismatch CHI<%=cidx%>. Address = %x, xfer size 4B, Write Data = %x, Read Data = %x", non_coh_addr, data_out[31:0], atomic_initial_data[31:0]))
                                           else
                                           `uvm_info("VS",$sformatf("Data Mismatch CHI<%=cidx%>. Address = %x, xfer size 4B, Write Data = %x, Read Data = %x", non_coh_addr, data_out[31:0], atomic_initial_data[31:0]),UVM_NONE)
                                         end
                                         else begin
                                             `uvm_info("VS", $sformatf("CHIAIU<%=cidx%> Data Transfer Write-Read Test Match. DMI Target GPR[%0d] Address = %x, xfer size 4B, Write Data = %x, Read Data = %x Critical DW=%0d",all_dmi, non_coh_addr, data_out[31:0], atomic_initial_data[31:0],crit_dw), UVM_LOW)
                                         end
                                     end // if(atomicLoad) begin
                                     if(atomicStore || atomicLoad || atomicSwap|| atomicCompare) begin
                                         if(atomicStore || atomicLoad) begin
                                             data_out = perform_atomic_op(atomic_op.name,data_out,atomic_txndata,4,non_coh_addr);
                                         end
                                         else if(atomicSwap)
                                             data_out = atomic_txndata;
                                         else if(atomicCompare)
                                             data_out = (atomic_txndata[15:0]==atomic_initial_data[15:0])?atomic_txndata[31:16]:atomic_initial_data[15:0];
                                         if (data_out[31:0] != data_in[31:0]) begin
                                           if(!bypass_data_in_data_out_checks) 
                                               `uvm_error("VS", $sformatf("Data Mismatch CHI<%=cidx%>. Address = %x, xfer size 4B, Write Data = %x, Read Data = %x", non_coh_addr, data_out[31:0], data_in[31:0]))
                                           else
                                           `uvm_info("VS",$sformatf("Data Mismatch CHI<%=cidx%>. Address = %x, xfer size 4B, Write Data = %x, Read Data = %x", non_coh_addr, data_out[31:0], data_in[31:0]),UVM_NONE)
                                         end
                                         else begin
                                             `uvm_info("VS", $sformatf("CHIAIU<%=cidx%> Data Transfer Write-Read Test Match. DMI Target GPR[%0d] Address = %x, xfer size 4B, Write Data = %x, Read Data = %x Critical DW=%0d",all_dmi, non_coh_addr, data_out[31:0], data_in[31:0],crit_dw), UVM_LOW)
                                         end
                                     end // if(atomicStore) begin
                                        end
                                     3: begin
                                     if(atomicLoad || atomicSwap || atomicCompare) begin
                                         if(atomicCompare) begin
                                             data_out[63:32] = 0;
                                             atomic_initial_data[63:32] = 0;
                                             data_in[63:32] = 0;
                                         end
                                         if (data_out[63:0] != atomic_initial_data[63:0]) begin
                                           if(!bypass_data_in_data_out_checks) 
                                               `uvm_error("VS", $sformatf("Data Mismatch CHI<%=cidx%>. Address = %x, xfer size 8B, Write Data = %x, Read Data = %x", non_coh_addr, data_out[63:0], atomic_initial_data[63:0]))
                                           else
                                           `uvm_info("VS",$sformatf("Data Mismatch CHI<%=cidx%>. Address = %x, xfer size 8B, Write Data = %x, Read Data = %x", non_coh_addr, data_out[63:0], atomic_initial_data[63:0]),UVM_NONE)
                                         end
                                         else begin
                                             `uvm_info("VS", $sformatf("CHIAIU<%=cidx%> Data Transfer Write-Read Test Match. DMI Target GPR[%0d] Address = %x, xfer size 8B, Write Data = %x, Read Data = %x Critical DW=%0d",all_dmi, non_coh_addr, data_out[63:0], atomic_initial_data[63:0],crit_dw), UVM_LOW)
                                         end
                                     end // if(atomicLoad) begin
                                     if(atomicStore || atomicLoad || atomicSwap || atomicCompare) begin
                                         if(atomicStore || atomicLoad) begin
                                             data_out = perform_atomic_op(atomic_op.name,data_out,atomic_txndata,8,non_coh_addr);
                                         end
                                         else if(atomicSwap)
                                             data_out = atomic_txndata;
                                         else if(atomicCompare)
                                             data_out = (atomic_txndata[31:0]==atomic_initial_data[31:0])?atomic_txndata[63:32]:atomic_initial_data[31:0];
                                         if (data_out[63:0] != data_in[63:0]) begin
                                           if(!bypass_data_in_data_out_checks) 
                                               `uvm_error("VS", $sformatf("Data Mismatch CHI<%=cidx%>. Address = %x, xfer size 8B, Write Data = %x, Read Data = %x", non_coh_addr, data_out[63:0], data_in[63:0]))
                                           else
                                           `uvm_info("VS",$sformatf("Data Mismatch CHI<%=cidx%>. Address = %x, xfer size 8B, Write Data = %x, Read Data = %x", non_coh_addr, data_out[63:0], data_in[63:0]),UVM_NONE)
                                         end
                                         else begin
                                             `uvm_info("VS", $sformatf("CHIAIU<%=cidx%> Data Transfer Write-Read Test Match. DMI Target GPR[%0d] Address = %x, xfer size 8B, Write Data = %x, Read Data = %x Critical DW=%0d",all_dmi, non_coh_addr, data_out[63:0], data_in[63:0],crit_dw), UVM_LOW)
                                         end
                                     end // if(atomicStore) begin
                                        end
                                     4: begin
                                     if(atomicLoad || atomicSwap || atomicCompare) begin
                                         if(wData>=128 && wData<=256) begin
                                         int zero_bits_lower_boundary, zero_bits_upper_boundary;
                                             zero_bits_lower_boundary = ((8 * (2 ** data_size)) - (8 * addr[3:0]));
                                             zero_bits_upper_boundary = (8 * (2 ** data_size));
                                             if(is_device_mem) begin
                                                 zero_bits_lower_boundary = zero_bits_lower_boundary - (drop_bytes_for_device_mem*8) + (8 * addr[3:0]);
                                             end
                                             if(zero_bits_lower_boundary!=zero_bits_upper_boundary)
                                             for(int set_zero_bits=zero_bits_lower_boundary;set_zero_bits<zero_bits_upper_boundary;  set_zero_bits=set_zero_bits+1) begin
                                                 data_out[set_zero_bits] = 1'b0; atomic_initial_data[set_zero_bits] = 1'b0;
                                             end
                                         end else 
                                             `uvm_error("VS", $sformatf("Check CHI Data width must not be other than 128, 256"))
                                         if(atomicCompare) begin
                                             data_out[127:64] = 0;
                                             atomic_initial_data[127:64] = 0;
                                             data_in[127:64] = 0;
                                         end
                                         if (data_out[127:0] != atomic_initial_data[127:0]) begin
                                           if(!bypass_data_in_data_out_checks) 
                                               `uvm_error("VS", $sformatf("Data Mismatch CHI<%=cidx%>. Address = %x, xfer size 16B, Write Data = %x, Read Data = %x", non_coh_addr, data_out[127:0], atomic_initial_data[127:0]))
                                           else
                                           `uvm_info("VS",$sformatf("Data Mismatch CHI<%=cidx%>. Address = %x, xfer size 16B, Write Data = %x, Read Data = %x", non_coh_addr, data_out[127:0], atomic_initial_data[127:0]),UVM_NONE)
                                         end
                                         else begin
                                             `uvm_info("VS", $sformatf("CHIAIU<%=cidx%> Data Transfer Write-Read Test Match. DMI Target GPR[%0d] Address = %x, xfer size 16B, Write Data = %x, Read Data = %x Critical DW=%0d",all_dmi, non_coh_addr, data_out[127:0], atomic_initial_data[127:0],crit_dw), UVM_LOW)
                                         end
                                     end // if(atomicLoad) begin
                                     if(atomicStore || atomicLoad || atomicSwap || atomicCompare) begin
                                         if(wData>=128 && wData<=256) begin
                                         int zero_bits_lower_boundary, zero_bits_upper_boundary;
                                             zero_bits_lower_boundary = ((8 * (2 ** data_size)) - (8 * addr[3:0]));
                                             zero_bits_upper_boundary = (8 * (2 ** data_size));
                                             if(is_device_mem) begin
                                                 zero_bits_lower_boundary = zero_bits_lower_boundary - (drop_bytes_for_device_mem*8) + (8 * addr[3:0]);
                                             end
                                             if(zero_bits_lower_boundary!=zero_bits_upper_boundary)
                                             for(int set_zero_bits=zero_bits_lower_boundary;set_zero_bits<zero_bits_upper_boundary;  set_zero_bits=set_zero_bits+1) begin
                                                 data_out[set_zero_bits] = 1'b0; data_in[set_zero_bits] = 1'b0; /*atomic_txndata[set_zero_bits] = 1'b0;*/
                                             end
                                         end else 
                                             `uvm_error("VS", $sformatf("Check CHI Data width must not be other than 128, 256"))
                                         if(atomicStore || atomicLoad)
                                             data_out = perform_atomic_op(atomic_op.name,data_out,atomic_txndata);
                                         else if(atomicSwap)
                                             data_out = atomic_txndata;
                                         else if(atomicCompare)
                                             data_out = (atomic_txndata[63:0]==atomic_initial_data[63:0])?atomic_txndata[127:64]:atomic_initial_data[63:0];
                                         if (data_out[127:0] != data_in[127:0]) begin
                                           if(!bypass_data_in_data_out_checks) 
                                               `uvm_error("VS", $sformatf("Data Mismatch CHI<%=cidx%>. Address = %x, xfer size 16B, Write Data = %x, Read Data = %x", non_coh_addr, data_out[127:0], data_in[127:0]))
                                           else
                                           `uvm_info("VS",$sformatf("Data Mismatch CHI<%=cidx%>. Address = %x, xfer size 16B, Write Data = %x, Read Data = %x", non_coh_addr, data_out[127:0], data_in[127:0]),UVM_NONE)
                                         end
                                         else begin
                                             `uvm_info("VS", $sformatf("CHIAIU<%=cidx%> Data Transfer Write-Read Test Match. DMI Target GPR[%0d] Address = %x, xfer size 16B, Write Data = %x, Read Data = %x Critical DW=%0d",all_dmi, non_coh_addr, data_out[127:0], data_in[127:0],crit_dw), UVM_LOW)
                                         end
                                     end // if(atomicStore) begin
                                        end
                                     default: begin
                                         `uvm_error("VS", $sformatf("Unsupported data size [CHI<%=cidx%>]%d", data_size))
                                        end
                                   endcase
                               end   //for i
                             end //for(all_dmi=0;all_dmi<all_dmi_start_addr[<%=obj.AiuInfo[idx].rpn%>].size();all_dmi=all_dmi+1) begin // for each DMI 
                           end //if($test$plusargs("k_directed_test_wr_rd_to_all_dmi")) begin
                          end // for j
                      end // for(int crit_dw=0;crit_dw<8;crit_dw=crit_dw+1) begin


                   `uvm_info("FULLSYS_TEST", "Done testing on processor<%=idx%> All AIUs: CHIAIU<%=cidx%>", UVM_NONE)
                   end // fork 
    `else //`ifndef USE_VIP_SNPS

    `endif //`ifndef USE_VIP_SNPS ... `else
     <% cidx++; %>
   <% } %>
  <% } %>
//`endif//`ifndef USE_VIP_SNPS
//`endif 
endtask :directed_atomic_test_all_chiaius_CONC_11504 

//************************************************************************************
// #Stimulus.FSYS.dwid_test.IOaiuNonCoh
// #Stimulus.FSYS.dwid_test.IOaiuCoh
task concerto_fullsys_direct_wr_rd_legacy_test::directed_write_read_test_all_ioaius_CONC_11133(uvm_phase phase);
bit bypass_data_in_data_out_checks=0;
bit use_single_mem_region_in_test=0;
`ifndef USE_VIP_SNPS //existing flow will not run when USE_VIP_SNPS set
   `uvm_info("VS", "Directed Write/ Read Test All IOAIUs", UVM_LOW)
   
// removed don't use CHI BOOT anymore//<% if ((found_csr_access_chiaiu > 0) && (found_csr_access_ioaiu > 0)) { %>
// removed don't use CHI BOOT anymore//    if(boot_from_ioaiu == 1) begin
// removed don't use CHI BOOT anymore//    end else begin
// removed don't use CHI BOOT anymore//        foreach(m_chi0_vseq.all_dmi_dii_start_addr[x]) begin
// removed don't use CHI BOOT anymore//          foreach(m_chi0_vseq.all_dmi_dii_start_addr[x][y]) begin
// removed don't use CHI BOOT anymore//            all_dmi_dii_start_addr[x].push_back(m_chi0_vseq.all_dmi_dii_start_addr[x][y]);
// removed don't use CHI BOOT anymore//          end
// removed don't use CHI BOOT anymore//        end
// removed don't use CHI BOOT anymore//        foreach(m_chi0_vseq.all_dii_start_addr[x]) begin
// removed don't use CHI BOOT anymore//          foreach(m_chi0_vseq.all_dii_start_addr[x][y]) begin
// removed don't use CHI BOOT anymore//            all_dii_start_addr[x].push_back(m_chi0_vseq.all_dii_start_addr[x][y]);
// removed don't use CHI BOOT anymore//          end
// removed don't use CHI BOOT anymore//        end
// removed don't use CHI BOOT anymore//        foreach(m_chi0_vseq.all_dmi_start_addr[x]) begin
// removed don't use CHI BOOT anymore//          foreach(m_chi0_vseq.all_dmi_start_addr[x][y]) begin
// removed don't use CHI BOOT anymore//            all_dmi_start_addr[x].push_back(m_chi0_vseq.all_dmi_start_addr[x][y]);
// removed don't use CHI BOOT anymore//          end
// removed don't use CHI BOOT anymore//        end
// removed don't use CHI BOOT anymore//    end // else: !if(boot_from_ioaiu == 1)
// removed don't use CHI BOOT anymore//<% } else { %>
// removed don't use CHI BOOT anymore//<%   if(found_csr_access_chiaiu > 0) { %>
// removed don't use CHI BOOT anymore//        foreach(m_chi0_vseq.all_dmi_dii_start_addr[x]) begin
// removed don't use CHI BOOT anymore//          foreach(m_chi0_vseq.all_dmi_dii_start_addr[x][y]) begin
// removed don't use CHI BOOT anymore//            all_dmi_dii_start_addr[x].push_back(m_chi0_vseq.all_dmi_dii_start_addr[x][y]);
// removed don't use CHI BOOT anymore//          end
// removed don't use CHI BOOT anymore//        end
// removed don't use CHI BOOT anymore//        foreach(m_chi0_vseq.all_dii_start_addr[x]) begin
// removed don't use CHI BOOT anymore//          foreach(m_chi0_vseq.all_dii_start_addr[x][y]) begin
// removed don't use CHI BOOT anymore//            all_dii_start_addr[x].push_back(m_chi0_vseq.all_dii_start_addr[x][y]);
// removed don't use CHI BOOT anymore//          end
// removed don't use CHI BOOT anymore//        end
// removed don't use CHI BOOT anymore//        foreach(m_chi0_vseq.all_dmi_start_addr[x]) begin
// removed don't use CHI BOOT anymore//          foreach(m_chi0_vseq.all_dmi_start_addr[x][y]) begin
// removed don't use CHI BOOT anymore//            all_dmi_start_addr[x].push_back(m_chi0_vseq.all_dmi_start_addr[x][y]);
// removed don't use CHI BOOT anymore//          end
// removed don't use CHI BOOT anymore//        end
// removed don't use CHI BOOT anymore//   <% } else { %>
// removed don't use CHI BOOT anymore//   <% if (found_csr_access_ioaiu > 0) { %>
// removed don't use CHI BOOT anymore//<% } } } %>
   
  if($test$plusargs("bypass_data_in_data_out_checks"))  bypass_data_in_data_out_checks=1;
  if($test$plusargs("use_single_mem_region_in_test"))   use_single_mem_region_in_test=1;
  <% for(idx = 0, cidx=0, ncidx=0; idx < obj.nAIUs; idx++) { 
    if((obj.AiuInfo[idx].fnNativeInterface.match('CHI'))) { %>
     <% cidx++;
    } else { %>
                begin 
                    bit [1023:0] data_in, data_in_1;
                    bit [1023:0] data_out, data_out_1;
                    int data_size;
                    bit [ncoreConfigInfo::W_SEC_ADDR-1:0] non_coh_addr;
                    bit [ncoreConfigInfo::W_SEC_ADDR-1:0] coh_addr;
                    bit [5:0] idx_val = <%=idx%>;
                   `uvm_info("FULLSYS_TEST", "Start write on processor<%=idx%> : IOAIU<%=ncidx%>", UVM_NONE)
     
                   `ifndef USE_VIP_SNPS
                   <% for(let i=0; i<aiu_NumCores[idx]; i++) { %> 
                   fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_seq<%=ncidx%>[<%=i%>].k_num_read_req        = 0;
                   fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_seq<%=ncidx%>[<%=i%>].k_num_write_req       = ioaiu_num_trans;
                   fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_seq<%=ncidx%>[<%=i%>].k_directed_test_alloc = 1;
        <% if((obj.AiuInfo[idx].fnNativeInterface == 'ACE') || (obj.AiuInfo[idx].fnNativeInterface == 'ACE-LITE') || (obj.AiuInfo[idx].fnNativeInterface == 'ACELITE-E')) { %>
                   fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_seq<%=ncidx%>[<%=i%>].wt_ace_rdnosnp      = 0;
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
      <% } %>
                  `else
      <% for(let i=0; i<aiu_NumCores[pidx]; i++) { %> 
                   cust_seq_h<%=ncidx%>[<%=i%>].k_num_read_req        = 0;
                   cust_seq_h<%=ncidx%>[<%=i%>].k_num_write_req       = ioaiu_num_trans;
                   cust_seq_h<%=ncidx%>[<%=i%>].k_directed_test_alloc = 1;
        <% if((obj.AiuInfo[idx].fnNativeInterface == 'ACE') || (obj.AiuInfo[idx].fnNativeInterface == 'ACE-LITE') || (obj.AiuInfo[idx].fnNativeInterface == 'ACELITE-E')) { %>
                   cust_seq_h<%=ncidx%>[<%=i%>].wt_ace_rdnosnp      = 0;
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
                   for (int i=0; i < ioaiu_num_trans; i++) begin
                      int size = $clog2(ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA/8);
                      int len;   
                      assert(std::randomize(data_out));
                      //non_coh_addr = ncoreConfigInfo::user_addrq[ncoreConfigInfo::NONCOH][i];
                      //non_coh_addr[12:0] = {idx_val, 7'b0000000};
                      //coh_addr = ncoreConfigInfo::user_addrq[ncoreConfigInfo::COH][i];
                      //coh_addr[12:0] = {idx_val, 7'b0000000};
                      if ($test$plusargs("k_directed_test_all_non_coh")) begin
                        for(int crit_dw=0;crit_dw<8;crit_dw=crit_dw+1) begin // for each critical DW
                          for(int len = 0; len < 4; len++) begin  
                            if($test$plusargs("k_directed_test_wr_rd_to_all_dmi")) begin
                              //for(int all_dmi=0;all_dmi<all_dmi_start_addr[<%=obj.AiuInfo[idx].rpn%>].size();all_dmi=all_dmi+1) begin // for each DMI 
                              for(int all_dmi=0;all_dmi<(use_single_mem_region_in_test ? 1 :all_dmi_start_addr[<%=aiu_rpn[idx]%>].size());all_dmi=all_dmi+1) begin // for each DMI 
                                int width = ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA;
                                assert(std::randomize(data_out));
                                non_coh_addr = all_dmi_start_addr[<%=aiu_rpn[idx]%>][all_dmi] + (i*64);
                                non_coh_addr[5:3] = crit_dw;
                               `uvm_info("VS", $sformatf("IOAIU<%=ncidx%> DMI Target GPR[%0d] AXI Write Non-coherent Addr=%x, data_out = %x, width=%0d len=%0d Critical DW=%0d", all_dmi,non_coh_addr, data_out[4*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA-1:0], width,len,crit_dw), UVM_LOW)
                                write_ioaiu<%=ncidx%>(non_coh_addr, len, size, data_out[1023:0], 0);
                                read_ioaiu<%=ncidx%>(non_coh_addr, len, size, data_in[1023:0]);
                               `uvm_info("VS", $sformatf("IOAIU<%=ncidx%> AXI Read Non-coherent Addr=%x, data_in = %x", non_coh_addr, data_in[4*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA-1:0]), UVM_LOW)
                                case (len)
                                   0: begin
                                         data_out = data_out[ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA-1:0];
                                         data_in  = data_in [ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA-1:0];
                                         if (non_coh_addr[ioaiu<%=ncidx%>_axi_agent_pkg::WLOGXDATA-1:0] !== 0) begin
                                             for(int st_offset = 0; st_offset < non_coh_addr[ioaiu<%=ncidx%>_axi_agent_pkg::WLOGXDATA-1:0] ; st_offset++) begin
                                                 data_out[8*st_offset +: 8] = 8'h0;
                                                 data_in [8*st_offset +: 8] = 8'h0;
                                             end
                                         end
                                         if (data_out[ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA-1:0] != data_in[ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA-1:0]) begin
                                            `uvm_error("VS", $sformatf("IOAIU<%=ncidx%> AXI Data Transfer ERROR0, Expected = %x, Actual = %x", 
                                                                        data_out[ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA-1:0], data_in[ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA-1:0]))
                                         end
                                         else begin
                                             `uvm_info("VS", $sformatf("IOAIU<%=ncidx%> Data Transfer Write-Read Test Match. DMI Target GPR[%0d] Address = %x, xfer len %0d, Write Data = %x, Read Data = %x Critical DW=%0d",all_dmi, non_coh_addr,len , data_out, data_in,crit_dw), UVM_LOW)
                                         end
                                      end
                                   1: begin
                                         data_out = data_out[2*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA-1:0];
                                         data_in  = data_in [2*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA-1:0];
                                         if (non_coh_addr[ioaiu<%=ncidx%>_axi_agent_pkg::WLOGXDATA-1:0] !== 0) begin
                                             for(int st_offset = 0; st_offset < non_coh_addr[ioaiu<%=ncidx%>_axi_agent_pkg::WLOGXDATA-1:0] ; st_offset++) begin
                                                 data_out[8*st_offset +: 8] = 8'h0;
                                                 data_in [8*st_offset +: 8] = 8'h0;
                                             end
                                         end
                                         if (data_out[2*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA-1:0] != data_in[2*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA-1:0]) begin
                                            `uvm_error("VS", $sformatf("IOAIU<%=ncidx%> AXI Data Transfer ERROR1, Expected = %x, Actual = %x", 
                                                                        data_out[2*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA-1:0], data_in[2*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA-1:0]))
                                         end
                                         else begin
                                             `uvm_info("VS", $sformatf("IOAIU<%=ncidx%> Data Transfer Write-Read Test Match. DMI Target GPR[%0d] Address = %x, xfer len %0d, Write Data = %x, Read Data = %x Critical DW=%0d",all_dmi, non_coh_addr,len , data_out, data_in,crit_dw), UVM_LOW)
                                         end
                                      end
                                   2: begin
                                         data_out = data_out[3*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA-1:0];
                                         data_in  = data_in [3*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA-1:0];
                                         if (non_coh_addr[ioaiu<%=ncidx%>_axi_agent_pkg::WLOGXDATA-1:0] !== 0) begin
                                             for(int st_offset = 0; st_offset < non_coh_addr[ioaiu<%=ncidx%>_axi_agent_pkg::WLOGXDATA-1:0] ; st_offset++) begin
                                                 data_out[8*st_offset +: 8] = 8'h0;
                                                 data_in [8*st_offset +: 8] = 8'h0;
                                             end
                                         end
                                         if (data_out[3*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA-1:0] != data_in[3*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA-1:0]) begin
                                            `uvm_error("VS", $sformatf("IOAIU<%=ncidx%> AXI Data Transfer ERROR2, Expected = %x, Actual = %x", 
                                                                        data_out[3*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA-1:0], data_in[3*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA-1:0]))
                                         end
                                         else begin
                                             `uvm_info("VS", $sformatf("IOAIU<%=ncidx%> Data Transfer Write-Read Test Match. DMI Target GPR[%0d] Address = %x, xfer len %0d, Write Data = %x, Read Data = %x Critical DW=%0d",all_dmi, non_coh_addr,len , data_out, data_in,crit_dw), UVM_LOW)
                                         end
                                      end
                                   3: begin
                                         data_out = data_out[4*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA-1:0];
                                         data_in  = data_in [4*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA-1:0];
                                         if (non_coh_addr[ioaiu<%=ncidx%>_axi_agent_pkg::WLOGXDATA-1:0] !== 0) begin
                                             for(int st_offset = 0; st_offset < non_coh_addr[ioaiu<%=ncidx%>_axi_agent_pkg::WLOGXDATA-1:0] ; st_offset++) begin
                                                 data_out[8*st_offset +: 8] = 8'h0;
                                                 data_in [8*st_offset +: 8] = 8'h0;
                                             end
                                         end
                                         if (data_out[4*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA-1:0] != data_in[4*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA-1:0]) begin
                                            `uvm_error("VS", $sformatf("IOAIU<%=ncidx%> AXI Data Transfer ERROR3, Expected = %x, Actual = %x", 
                                                                        data_out[4*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA-1:0], data_in[4*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA-1:0]))
                                         end
                                         else begin
                                             `uvm_info("VS", $sformatf("IOAIU<%=ncidx%> Data Transfer Write-Read Test Match. DMI Target GPR[%0d] Address = %x, xfer len %0d, Write Data = %x, Read Data = %x Critical DW=%0d",all_dmi, non_coh_addr,len , data_out, data_in,crit_dw), UVM_LOW)
                                         end
                                      end
                                 endcase
                              end // for(int all_dmi=0
                            end // if($test$plusargs("k_directed_test_wr_rd_to_all_dmi")) begin
                            if($test$plusargs("k_directed_test_wr_rd_to_all_dii")) begin
                             for(int all_dii=0;all_dii<(use_single_mem_region_in_test ? 1: all_dii_start_addr[<%=aiu_rpn[idx]%>].size());all_dii=all_dii+1) begin // for each DMI 
                                int width = ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA;
                                assert(std::randomize(data_out));
                                non_coh_addr = all_dii_start_addr[<%=aiu_rpn[idx]%>][all_dii]+ (i*64);
                                non_coh_addr[5:3] = crit_dw;
                               `uvm_info("VS", $sformatf("IOAIU<%=ncidx%>  DII Target GPR[%0d] AXI Write Non-coherent Addr=%x, data_out = %x, width=%0d Critical DW=%0d", all_dmi_start_addr[<%=aiu_rpn[idx]%>].size(), non_coh_addr, data_out[4*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA-1:0], width,crit_dw), UVM_LOW)
                                write_ioaiu<%=ncidx%>(non_coh_addr, len, size, data_out[1023:0], 0);
                                read_ioaiu<%=ncidx%>(non_coh_addr, len, size, data_in[1023:0]);
                               `uvm_info("VS", $sformatf("IOAIU<%=ncidx%> AXI Read Non-coherent Addr=%x, data_in = %x", non_coh_addr, data_in[4*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA-1:0]), UVM_LOW)
                                case (len)
                                   0: begin
                                         data_out = data_out[ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA-1:0];
                                         data_in  = data_in [ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA-1:0];
                                         if (non_coh_addr[ioaiu<%=ncidx%>_axi_agent_pkg::WLOGXDATA-1:0] !== 0) begin
                                             for(int st_offset = 0; st_offset < non_coh_addr[ioaiu<%=ncidx%>_axi_agent_pkg::WLOGXDATA-1:0] ; st_offset++) begin
                                                 data_out[8*st_offset +: 8] = 8'h0;
                                                 data_in [8*st_offset +: 8] = 8'h0;
                                             end
                                         end
                                         if (data_out[ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA-1:0] != data_in[ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA-1:0]) begin
                                            `uvm_error("VS", $sformatf("IOAIU<%=ncidx%> AXI Data Transfer ERROR0, Expected = %x, Actual = %x", 
                                                                        data_out[ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA-1:0], data_in[ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA-1:0]))
                                         end
                                         else begin
                                             `uvm_info("VS", $sformatf("IOAIU<%=ncidx%> Data Transfer Write-Read Test Match. DII Target GPR[%0d] Address = %x, xfer len %0d, Write Data = %x, Read Data = %x Critical DW=%0d",all_dmi_start_addr[<%=aiu_rpn[idx]%>].size()+all_dii, non_coh_addr,len , data_out, data_in,crit_dw), UVM_LOW)
                                         end
                                      end
                                   1: begin
                                         data_out = data_out[2*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA-1:0];
                                         data_in  = data_in [2*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA-1:0];
                                         if (non_coh_addr[ioaiu<%=ncidx%>_axi_agent_pkg::WLOGXDATA-1:0] !== 0) begin
                                             for(int st_offset = 0; st_offset < non_coh_addr[ioaiu<%=ncidx%>_axi_agent_pkg::WLOGXDATA-1:0] ; st_offset++) begin
                                                 data_out[8*st_offset +: 8] = 8'h0;
                                                 data_in [8*st_offset +: 8] = 8'h0;
                                             end
                                         end
                                         if (data_out[2*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA-1:0] != data_in[2*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA-1:0]) begin
                                            `uvm_error("VS", $sformatf("IOAIU<%=ncidx%> AXI Data Transfer ERROR1, Expected = %x, Actual = %x", 
                                                                        data_out[2*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA-1:0], data_in[2*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA-1:0]))
                                         end
                                         else begin
                                             `uvm_info("VS", $sformatf("IOAIU<%=ncidx%> Data Transfer Write-Read Test Match. DII Target GPR[%0d] Address = %x, xfer len %0d, Write Data = %x, Read Data = %x Critical DW=%0d",all_dmi_start_addr[<%=aiu_rpn[idx]%>].size()+all_dii, non_coh_addr,len , data_out, data_in,crit_dw), UVM_LOW)
                                         end
                                      end
                                   2: begin
                                         data_out = data_out[3*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA-1:0];
                                         data_in  = data_in [3*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA-1:0];
                                         if (non_coh_addr[ioaiu<%=ncidx%>_axi_agent_pkg::WLOGXDATA-1:0] !== 0) begin
                                             for(int st_offset = 0; st_offset < non_coh_addr[ioaiu<%=ncidx%>_axi_agent_pkg::WLOGXDATA-1:0] ; st_offset++) begin
                                                 data_out[8*st_offset +: 8] = 8'h0;
                                                 data_in [8*st_offset +: 8] = 8'h0;
                                             end
                                         end
                                         if (data_out[3*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA-1:0] != data_in[3*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA-1:0]) begin
                                            `uvm_error("VS", $sformatf("IOAIU<%=ncidx%> AXI Data Transfer ERROR2, Expected = %x, Actual = %x", 
                                                                        data_out[3*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA-1:0], data_in[3*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA-1:0]))
                                         end
                                         else begin
                                             `uvm_info("VS", $sformatf("IOAIU<%=ncidx%> Data Transfer Write-Read Test Match. DII Target GPR[%0d] Address = %x, xfer len %0d, Write Data = %x, Read Data = %x Critical DW=%0d",all_dmi_start_addr[<%=aiu_rpn[idx]%>].size()+all_dii, non_coh_addr,len , data_out, data_in,crit_dw), UVM_LOW)
                                         end
                                      end
                                   3: begin
                                         data_out = data_out[4*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA-1:0];
                                         data_in  = data_in [4*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA-1:0];
                                         if (non_coh_addr[ioaiu<%=ncidx%>_axi_agent_pkg::WLOGXDATA-1:0] !== 0) begin
                                             for(int st_offset = 0; st_offset < non_coh_addr[ioaiu<%=ncidx%>_axi_agent_pkg::WLOGXDATA-1:0] ; st_offset++) begin
                                                 data_out[8*st_offset +: 8] = 8'h0;
                                                 data_in [8*st_offset +: 8] = 8'h0;
                                             end
                                         end
                                         if (data_out[4*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA-1:0] != data_in[4*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA-1:0]) begin
                                            `uvm_error("VS", $sformatf("IOAIU<%=ncidx%> AXI Data Transfer ERROR3, Expected = %x, Actual = %x", 
                                                                        data_out[4*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA-1:0], data_in[4*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA-1:0]))
                                         end
                                         else begin
                                             `uvm_info("VS", $sformatf("IOAIU<%=ncidx%> Data Transfer Write-Read Test Match. DII Target GPR[%0d] Address = %x, xfer len %0d, Write Data = %x, Read Data = %x Critical DW=%0d",all_dmi_start_addr[<%=aiu_rpn[idx]%>].size()+all_dii, non_coh_addr,len , data_out, data_in,crit_dw), UVM_LOW)
                                         end
                                      end
                                 endcase
                              end // for(int all_dii=0
                            end // if($test$plusargs("k_directed_test_wr_rd_to_all_dii")) begin
                          end // for(int len = 0; len < 4; len++) begin
                        end // for(int crit_dw=0;crit_dw<8;crit_dw=crit_dw+1) begin
                      end // if ($test$plusargs("k_directed_test_all_non_coh")) begin

                      len = 3;
                      assert(std::randomize(data_out));
                      if ($test$plusargs("k_directed_test_all_coh")) begin
                        for(int crit_dw=0;crit_dw<8;crit_dw=crit_dw+1) begin // for each critical DW
                          for (int j = 6; j < 7; j++) begin  // need cacheline
                            for(int all_dmi=0;all_dmi<(use_single_mem_region_in_test? 1 : all_dmi_start_addr[<%=aiu_rpn[idx]%>].size());all_dmi=all_dmi+1) begin // for each DMI 
                      <% if(!(obj.AiuInfo[idx].fnNativeInterface == 'AXI4' && !obj.AiuInfo[idx].useCache)) { %>
                         `uvm_info("VS", $sformatf("IOAIU<%=ncidx%> AXI Write Coherent Addr=%x, data_out = %x", coh_addr, data_out[4*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA-1:0]), UVM_LOW)
                         non_coh_addr = all_dmi_start_addr[<%=aiu_rpn[idx]%>][all_dmi]  + (i*64);
                         non_coh_addr[5:3] = crit_dw;
                         coh_addr = non_coh_addr;
                         coh_addr[5:3] = crit_dw;
                         `uvm_info("VS", $sformatf("IOAIU<%=ncidx%> DMI Target GPR[%0d] AXI Write Coherent Addr=%x, data_in = %x Critical DW=%0d", all_dmi,coh_addr, data_out[4*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA-1:0],crit_dw), UVM_LOW)
                         write_ioaiu<%=ncidx%>(coh_addr, len, size, data_out[1023:0], 1);
                         read_ioaiu_rdonce<%=ncidx%>(coh_addr, len, size, data_in[1023:0]);
                        `uvm_info("VS", $sformatf("IOAIU<%=ncidx%> DMI Target GPR[%0d] AXI Read Coherent Addr=%x, data_in = %x Critical DW=%0d", all_dmi,coh_addr, data_in[4*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA-1:0],crit_dw), UVM_LOW)
                         data_out = data_out[4*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA-1:0];
                         data_in  = data_in [4*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA-1:0];
                         if (coh_addr[ioaiu<%=ncidx%>_axi_agent_pkg::WLOGXDATA-1:0] !== 0) begin
                             for(int st_offset = 0; st_offset < coh_addr[ioaiu<%=ncidx%>_axi_agent_pkg::WLOGXDATA-1:0] ; st_offset++) begin
                                 data_out[8*st_offset +: 8] = 8'h0;
                                 data_in [8*st_offset +: 8] = 8'h0;
                             end
                         end
                         if (data_out[4*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA-1:0] != data_in[4*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA-1:0]) begin
                            `uvm_error("VS", $sformatf("IOAIU<%=ncidx%> AXI Data Transfer ERROR, Expected = %x, Actual = %x", 
                                                        data_out[4*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA-1:0], data_in[4*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA-1:0]))
                         end
                         else begin
                            `uvm_info("VS", $sformatf("IOAIU<%=ncidx%> AXI Data Transfer Write-Read Test Match GOOD, Expected = %x, Actual = %x",data_out[4*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA-1:0], data_in[4*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA-1:0]), UVM_LOW)
                         end
                      <% } %>

                      assert(std::randomize(data_out));
                          if ((k_directed_test_noncoh_addr_pct != 0) && (k_directed_test_coh_addr_pct != 0)) begin  // both non-coherent and coherent
                             randcase
                                k_directed_test_noncoh_addr_pct: begin
                                                                     `uvm_info("VS", $sformatf("IOAIU<%=ncidx%> DMI Target GPR[%0d] AXI Write Non-coherent Addr=%x, data_out = %x Critical DW=%0d", all_dmi,non_coh_addr, 
                                                                                               data_out[4*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA-1:0],crit_dw), UVM_LOW)
                                                                     write_ioaiu<%=ncidx%>(non_coh_addr, len, size, data_out[1023:0], 0);
                                                                     read_ioaiu<%=ncidx%>(non_coh_addr, len, size, data_in[1023:0]);
                                                                    `uvm_info("VS", $sformatf("IOAIU<%=ncidx%> DMI Target GPR[%0d] AXI Read Non-coherent Addr=%x, data_in = %x Critical DW=%0d",all_dmi, non_coh_addr, data_in[4*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA-1:0],crit_dw), UVM_LOW)
                                                                     if (data_out[4*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA-1:0] != data_in[4*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA-1:0]) begin
                                                                        `uvm_error("VS", $sformatf("IOAIU<%=ncidx%> AXI Data Transfer ERROR, Expected = %x, Actual = %x", 
                                                                                                   data_out[4*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA-1:0], data_in[4*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA-1:0]))
                                                                     end
                                                                     else begin
                                                                        `uvm_info("VS", "IOAIU<%=ncidx%> AXI Data Transfer Write-Read Test Match GOOD", UVM_LOW)
                                                                     end
                                                                 end
                                k_directed_test_coh_addr_pct:    begin
                                                                   <% if(!(obj.AiuInfo[idx].fnNativeInterface == 'AXI4' && !obj.AiuInfo[idx].useCache)) { %>
                                                                    `uvm_info("VS", $sformatf("IOAIU<%=ncidx%> AXI Write Coherent Addr=%x, data_out = %x", coh_addr, data_out[4*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA-1:0]), UVM_LOW)
                                                                    write_ioaiu<%=ncidx%>(coh_addr, len, size, data_out[1023:0], 1);
                                                                    read_ioaiu_rdonce<%=ncidx%>(coh_addr, len, size, data_in[1023:0]);
                                                                   `uvm_info("VS", $sformatf("IOAIU<%=ncidx%> AXI Read Coherent Addr=%x, data_in = %x", coh_addr, data_in[4*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA-1:0]), UVM_LOW)
                                                                    if (data_out[4*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA-1:0] != data_in[4*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA-1:0]) begin
                                                                       `uvm_error("VS", $sformatf("IOAIU<%=ncidx%> AXI Data Transfer ERROR, Expected = %x, Actual = %x", 
                                                                                                   data_out[4*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA-1:0], data_in[4*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA-1:0]))
                                                                    end
                                                                    else begin
                                                                       `uvm_info("VS", "IOAIU<%=ncidx%> AXI Data Transfer Write-Read Test Match GOOD", UVM_LOW)
                                                                    end
                                                                   <% } %>
                                                                 end
                             endcase
                             end // if ((k_directed_test_noncoh_addr_pct != 0)
                             end // for(int all_dmi=0;all_d 
                           end // for (int j = 6; j < 7; j
                         end // for(int crit_dw=0;crit_dw<8;crit_dw=crit_dw+1) begin
                       end  // if ($test$plusargs(
                   end  // for (int i=0; i < ioaiu_num_trans; i++)
               end

     <% ncidx++;
    }
  } %>
`endif //`ifndef USE_VIP_SNPS 

endtask : directed_write_read_test_all_ioaius_CONC_11133 

//************************************************************************************
// #Stimulus.FSYS.dwid_test.ChiaiuNonCoh.IOaiuNonCoh
// #Stimulus.FSYS.dwid_test.ChiaiuCoh.IOaiuCoh
task concerto_fullsys_direct_wr_rd_legacy_test::directed_write_read_test_all_aius_CONC_11133(uvm_phase phase);
bit all_ioaiu_seq_first=0;
bit all_ioaiu_done, all_chiaiu_done;
   `uvm_info("VS", "Directed Write/ Read Test All AIUs", UVM_LOW)
   all_ioaiu_seq_first = $urandom();
   fork
     begin
       if(all_ioaiu_seq_first==1) begin
          wait(all_ioaiu_done==1);
       end
       if ($test$plusargs("k_directed_wr_rd_all_chiaius_to_all_targets_noncoh") || $test$plusargs("k_directed_wr_rd_all_chiaius_to_all_targets_coh")) begin
         directed_write_read_test_all_chiaius_CONC_11133(phase);
       end
       all_chiaiu_done = 1;
     end

     begin
       if(all_ioaiu_seq_first==0) begin
         wait(all_chiaiu_done==1);
       end
       if ($test$plusargs("k_directed_wr_rd_all_ioaius_to_all_targets_noncoh") ||  $test$plusargs("k_directed_wr_rd_all_ioaius_to_all_targets_coh")) begin
         directed_write_read_test_all_ioaius_CONC_11133(phase);
       end
       all_ioaiu_done = 1;
     end
   join
endtask : directed_write_read_test_all_aius_CONC_11133 

//************************************************************************************
task concerto_fullsys_direct_wr_rd_legacy_test::directed_atomic_test_all_aius_CONC_11504(uvm_phase phase);
bit all_ioaiu_seq_first=0;
bit all_ioaiu_done, all_chiaiu_done;
   `uvm_info("VS", "Directed Write/ Read Test All AIUs", UVM_LOW)
   all_ioaiu_seq_first = $urandom();
   fork
     begin
       if(all_ioaiu_seq_first==1) begin
          wait(all_ioaiu_done==1);
       end
       if ($test$plusargs("k_directed_atomic_all_chiaius_to_all_targets")) begin
         directed_atomic_test_all_chiaius_CONC_11504(phase);
       end
       all_chiaiu_done = 1;
     end

     begin
       if(all_ioaiu_seq_first==0) begin
         wait(all_chiaiu_done==1);
       end
       if ($test$plusargs("k_directed_atomic_all_ioaius_to_all_targets")) begin
         `uvm_error("VS", "Directed Atomic test. The ioaiu directed atomic test is not available with k_directed_atomic_all_ioaius_to_all_targets")
         //directed_write_read_test_all_ioaius_CONC_11133(phase);
       end
       all_ioaiu_done = 1;
     end
   join
endtask : directed_atomic_test_all_aius_CONC_11504 

//************************************************************************************
task concerto_fullsys_direct_wr_rd_legacy_test::directed_write_read_test_all_aius_random(uvm_phase phase);
   `uvm_info("VS", "Directed Write/ Read Test", UVM_LOW)
   
//`ifndef USE_VIP_SNPS //existing flow will not run when USE_VIP_SNPS set
   fork    // execute all AIUs in parallel
  <% for(idx = 0, cidx=0, ncidx=0; idx < obj.nAIUs; idx++) { 
    if((obj.AiuInfo[idx].fnNativeInterface.match('CHI'))) { %>
    `ifndef USE_VIP_SNPS //existing flow will not run when USE_VIP_SNPS set
                begin 
                    bit [511:0] data_in, data_in_1;
                    bit [511:0] data_out, data_out_1;
                    bit [ncoreConfigInfo::W_SEC_ADDR-1:0] coh_addr;
                    bit [ncoreConfigInfo::W_SEC_ADDR-1:0] non_coh_addr;
                    int data_size;
                    int wData;
                   `uvm_info("FULLSYS_TEST", "Start write/read on processor<%=idx%> : CHIAIU<%=cidx%>", UVM_NONE)

                    <% if (obj.AiuInfo[idx].wData == 128) { %>
                        wData = 128;
                    <% } else if (obj.AiuInfo[idx].wData == 256) { %> 
                         wData = 256;
                    <% } else { %>
                         wData = 512;
                    <% } %>
                    `uvm_info("VS", $sformatf("wData<%=cidx%> = %d", wData), UVM_LOW)
                       
                    if ($test$plusargs("k_directed_test_all_coh")) begin
                       m_chi<%=cidx%>_args.k_coh_addr_pct.set_value(100);
                    end
                    else begin
                       m_chi<%=cidx%>_args.k_coh_addr_pct.set_value(k_directed_test_coh_addr_pct);
                    end

                    if ($test$plusargs("k_directed_test_all_non_coh")) begin
                       m_chi<%=cidx%>_args.k_noncoh_addr_pct.set_value(100);
                    end 
                    else begin
                       m_chi<%=cidx%>_args.k_noncoh_addr_pct.set_value(k_directed_test_noncoh_addr_pct);
                    end
                    // m_chi<%=cidx%>_args.k_new_addr_pct.set_value(100);
                    m_chi<%=cidx%>_args.k_rd_noncoh_pct.set_value(0);
                    m_chi<%=cidx%>_args.k_rd_ldrstr_pct.set_value(0);
                    m_chi<%=cidx%>_args.k_rd_rdonce_pct.set_value(0);
                    if ($test$plusargs("k_directed_test_all_non_coh")) begin
                        m_chi<%=cidx%>_args.k_wr_noncoh_pct.set_value(100);
                        m_chi<%=cidx%>_args.k_rd_noncoh_pct.set_value(0);
                    end
                    else begin
                        m_chi<%=cidx%>_args.k_wr_noncoh_pct.set_value(k_directed_test_noncoh_addr_pct);
                    end
                    if ($test$plusargs("k_directed_test_all_coh")) begin
                        m_chi<%=cidx%>_args.k_wr_cohunq_pct.set_value(100);
                    end
                    else begin
                        m_chi<%=cidx%>_args.k_wr_cohunq_pct.set_value(k_directed_test_coh_addr_pct);
                    end
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
                    if ($test$plusargs("k_directed_test_all_non_coh")) begin
                     for (int j = 1; j < 7; j++) begin
                          for (int i = 0; i < chi_num_trans; i++) begin
                             assert(std::randomize(data_out));
                             data_size = j;  // 2,4,8,16,32,64 bytes
                             non_coh_addr = ncoreConfigInfo::user_addrq[ncoreConfigInfo::NONCOH][i];
                             if ($urandom_range(0,1) == 0) begin
                                m_chi<%=cidx%>_args.k_wr_noncoh_pct.set_value(100);
                                m_chi<%=cidx%>_args.k_rd_noncoh_pct.set_value(0);
                                m_chi<%=cidx%>_vseq.set_unit_args(m_chi<%=cidx%>_args);
                                `uvm_info("VS", $sformatf("CHI<%=cidx%> Write Address = %x,size = %d, Write Data = %x", non_coh_addr, data_size, data_out), UVM_LOW) 
                                m_chi<%=cidx%>_vseq.write_memory(non_coh_addr, data_out, data_size);
                             end
                             else begin
                               m_chi<%=cidx%>_args.k_wr_noncoh_pct.set_value(0);
                               m_chi<%=cidx%>_args.k_rd_noncoh_pct.set_value(100);
                               m_chi<%=cidx%>_vseq.set_unit_args(m_chi<%=cidx%>_args);
                               m_chi<%=cidx%>_vseq.read_memory(non_coh_addr, data_in, data_size, wData);
                               `uvm_info("VS", $sformatf("CHI<%=cidx%> Read Address = %x,size = %d,  Read Data = %x", non_coh_addr, data_size,data_in), UVM_LOW)
                             end
                          end   //for i
                      end // for j
                    end  // k_directed_test_all_non_coh 

                    if ($test$plusargs("k_directed_test_all_coh")) begin
                     for (int j = 6; j < 7; j++) begin  // need cacheline
                          for (int i = 0; i < 100; i++) begin
                             assert(std::randomize(data_out));
                             data_size = j;  // 2,4,8,16,32,64 bytes
                             coh_addr = ncoreConfigInfo::user_addrq[ncoreConfigInfo::COH][i];
                             if ($urandom_range(0,1) == 0) begin
                                 m_chi<%=cidx%>_args.k_wr_cohunq_pct.set_value(100);
                                 m_chi<%=cidx%>_args.k_rd_rdonce_pct.set_value(0);
                                 m_chi<%=cidx%>_vseq.set_unit_args(m_chi<%=cidx%>_args);
                                 `uvm_info("VS", $sformatf("CHI<%=cidx%> Write Address = %x,size = %d, Write Data = %x", coh_addr, data_size, data_out), UVM_LOW) 
                                 m_chi<%=cidx%>_vseq.write_memory_coh(coh_addr, data_out, data_size);
                             end
                             else begin
                                 m_chi<%=cidx%>_args.k_wr_cohunq_pct.set_value(0);
                                 m_chi<%=cidx%>_args.k_rd_rdonce_pct.set_value(100);
                                 m_chi<%=cidx%>_vseq.set_unit_args(m_chi<%=cidx%>_args);
                                 m_chi<%=cidx%>_vseq.read_memory_coh(coh_addr, data_in, data_size, wData);
                                 `uvm_info("VS", $sformatf("CHI<%=cidx%> Read Address = %x,size = %d,  Read Data = %x", coh_addr, data_size,data_in), UVM_LOW)
                             end
                          end   //for i
                      end // for j
                    end  // k_directed_test_all_coh 

                    if ((k_directed_test_noncoh_addr_pct != 0) && (k_directed_test_coh_addr_pct != 0)) begin  // both non-coherent and coherent
                       for (int i = 0; i < chi_num_trans; i++) begin
                          assert(std::randomize(data_out));
                          assert(std::randomize(data_out_1));
                          data_size = 6;  // 64 bytes
                          non_coh_addr = ncoreConfigInfo::user_addrq[ncoreConfigInfo::NONCOH][i];
                          coh_addr = ncoreConfigInfo::user_addrq[ncoreConfigInfo::COH][i];
                          if($urandom_range(0,1) == 0) begin
                              `uvm_info("VS", $sformatf("CHI<%=cidx%> Non-coherent Write Address = %x,size = %d, Write Data = %x", non_coh_addr, data_size, data_out), UVM_LOW) 
                             `uvm_info("VS", $sformatf("CHI<%=cidx%> Coherent Write Address = %x,size = %d, Write Data = %x", coh_addr, data_size, data_out_1), UVM_LOW) 
                              m_chi<%=cidx%>_args.k_wr_noncoh_pct.set_value(k_directed_test_noncoh_addr_pct);
                              m_chi<%=cidx%>_args.k_rd_noncoh_pct.set_value(0);
                              m_chi<%=cidx%>_args.k_wr_cohunq_pct.set_value(k_directed_test_coh_addr_pct);
                              m_chi<%=cidx%>_args.k_rd_rdonce_pct.set_value(0);
                              m_chi<%=cidx%>_vseq.set_unit_args(m_chi<%=cidx%>_args);
                              m_chi<%=cidx%>_vseq.write_memory(non_coh_addr, data_out, data_size);
                              m_chi<%=cidx%>_vseq.write_memory_coh(coh_addr, data_out_1, data_size);
                           end
                           else begin
                              m_chi<%=cidx%>_args.k_wr_noncoh_pct.set_value(0);
                              m_chi<%=cidx%>_args.k_rd_noncoh_pct.set_value(k_directed_test_noncoh_addr_pct);
                              m_chi<%=cidx%>_args.k_wr_cohunq_pct.set_value(0);
                              m_chi<%=cidx%>_args.k_rd_rdonce_pct.set_value(k_directed_test_coh_addr_pct);
                              m_chi<%=cidx%>_vseq.set_unit_args(m_chi<%=cidx%>_args);
                              m_chi<%=cidx%>_vseq.read_memory(ncoreConfigInfo::user_addrq[ncoreConfigInfo::NONCOH][i], data_in, data_size, wData);
                              m_chi<%=cidx%>_vseq.read_memory_coh(ncoreConfigInfo::user_addrq[ncoreConfigInfo::COH][i], data_in_1, data_size, wData);
                              `uvm_info("VS", $sformatf("CHI<%=cidx%> Non-coherent Read Address = %x,size = %d,  Read Data = %x", non_coh_addr, data_size,data_in), UVM_LOW)
                              `uvm_info("VS", $sformatf("CHI<%=cidx%> Coherent Read Address = %x,size = %d,  Read Data = %x", coh_addr, data_size,data_in_1), UVM_LOW)
                           end
                       end

                    end //k_directed_test_noncoh_addr_pct and k_directed_test_coh_addr_pct

                       `uvm_info("FULLSYS_TEST", "Done write/ read  on processor<%=idx%> : CHIAIU<%=cidx%>", UVM_NONE)
                   end // fork 
          `else //`ifndef USE_VIP_SNPS
                  begin 
                    bit [511:0] data_in, data_in_1;
                    bit [511:0] data_out, data_out_1;
                    bit [ncoreConfigInfo::W_SEC_ADDR-1:0] coh_addr;
                    bit [ncoreConfigInfo::W_SEC_ADDR-1:0] non_coh_addr;
                    int data_size;
                    int wData;
                   `uvm_info("FULLSYS_TEST", "Start write/read on processor<%=idx%> : CHIAIU<%=cidx%>", UVM_NONE)

                    <% if (obj.AiuInfo[idx].wData == 128) { %>
                        wData = 128;
                    <% } else if (obj.AiuInfo[idx].wData == 256) { %> 
                         wData = 256;
                    <% } else { %>
                         wData = 512;
                    <% } %>
                    `uvm_info("VS", $sformatf("wData<%=cidx%> = %d", wData), UVM_LOW)
                       
                    if ($test$plusargs("k_directed_test_all_coh")) begin
                       m_chi0_args.k_coh_addr_pct.set_value(100);
                    end
                    else begin
                       m_chi0_args.k_coh_addr_pct.set_value(k_directed_test_coh_addr_pct);
                    end

                    if ($test$plusargs("k_directed_test_all_non_coh")) begin
                       m_chi0_args.k_noncoh_addr_pct.set_value(100);
                    end 
                    else begin
                       m_chi0_args.k_noncoh_addr_pct.set_value(k_directed_test_noncoh_addr_pct);
                    end
                    // m_chi<%=cidx%>_args.k_new_addr_pct.set_value(100);
                    m_chi0_args.k_rd_noncoh_pct.set_value(0);
                    m_chi0_args.k_rd_ldrstr_pct.set_value(0);
                    m_chi0_args.k_rd_rdonce_pct.set_value(0);
                    if ($test$plusargs("k_directed_test_all_non_coh")) begin
                        m_chi0_args.k_wr_noncoh_pct.set_value(100);
                        m_chi0_args.k_rd_noncoh_pct.set_value(100);
                    end
                    else begin
                        m_chi0_args.k_wr_noncoh_pct.set_value(k_directed_test_noncoh_addr_pct);
                        m_chi0_args.k_rd_noncoh_pct.set_value(k_directed_test_noncoh_addr_pct);
                    end
                    if ($test$plusargs("k_directed_test_all_coh")) begin
                        m_chi0_args.k_wr_cohunq_pct.set_value(100);
                        m_chi0_args.k_rd_rdonce_pct.set_value(100);
                    end
                    else begin
                        m_chi0_args.k_wr_cohunq_pct.set_value(k_directed_test_coh_addr_pct);
                        m_chi0_args.k_rd_rdonce_pct.set_value(k_directed_test_coh_addr_pct);
                    end
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
                    //m_chi<%=cidx%>_vseq.set_unit_args(m_chi<%=cidx%>_args);
                    <% if(numChiAiu > 0) { %>
                       m_svt_chi_item.m_args = m_chi0_args;
                    <% } %>
                    m_snps_chi<%=cidx%>_vseq.set_unit_args(m_chi0_args);
                    m_snps_chi<%=cidx%>_vseq.k_directed_test_alloc = 1;
                    if ($test$plusargs("k_directed_test_all_non_coh")) begin
                     for (int j = 1; j < 7; j++) begin
                          for (int i = 0; i < chi_num_trans; i++) begin
                             assert(std::randomize(data_out));
                             data_size = j;  // 2,4,8,16,32,64 bytes
                             non_coh_addr = ncoreConfigInfo::user_addrq[ncoreConfigInfo::NONCOH][i];
                             if(non_coh_addr==0)begin
                                non_coh_addr=addr_mgr.get_noncoh_addr(<%=obj.AiuInfo[cidx].FUnitId%>, 1);
                             end
                             if ($urandom_range(0,1) == 0) begin
                                //m_chi0_args.k_wr_noncoh_pct.set_value(100);
                                //m_chi0_args.k_rd_noncoh_pct.set_value(0);
                                //m_chi0_vseq.set_unit_args(m_chi<%=cidx%>_args);
                             <% if(numChiAiu > 0) { %>
                                  m_svt_chi_item.m_args = m_chi0_args;
                             <% } %>
                                 m_snps_chi<%=cidx%>_vseq.set_unit_args(m_chi0_args);
                                `uvm_info("VS", $sformatf("CHI<%=cidx%> Write Address = %x,size = %d, Write Data = %x", non_coh_addr, data_size, data_out), UVM_LOW) 
                                m_snps_chi<%=cidx%>_vseq.write_memory(non_coh_addr, data_out, data_size);// need to add
                             end
                             else begin
                               //m_chi0_args.k_wr_noncoh_pct.set_value(0);
                               //m_chi0_args.k_rd_noncoh_pct.set_value(100);
                               //m_chi<%=cidx%>_vseq.set_unit_args(m_chi<%=cidx%>_args);
                               <% if(numChiAiu > 0) { %>
                                  m_svt_chi_item.m_args = m_chi0_args;
                               <% } %>
                               m_snps_chi<%=cidx%>_vseq.set_unit_args(m_chi0_args);
                               m_snps_chi<%=cidx%>_vseq.read_memory(non_coh_addr, data_in, data_size, wData);// need to add 
                               `uvm_info("VS", $sformatf("CHI<%=cidx%> Read Address = %x,size = %d,  Read Data = %x", non_coh_addr, data_size,data_in), UVM_LOW)
                             end
                          end   //for i
                      end // for j
                    end  // k_directed_test_all_non_coh 

                    if ($test$plusargs("k_directed_test_all_coh")) begin
                     for (int j = 6; j < 7; j++) begin  // need cacheline
                          for (int i = 0; i < 100; i++) begin
                             assert(std::randomize(data_out));
                             data_size = j;  // 2,4,8,16,32,64 bytes
                             coh_addr = ncoreConfigInfo::user_addrq[ncoreConfigInfo::COH][i];
                               if(coh_addr==0)begin
                                 coh_addr=addr_mgr.get_coh_addr(<%=obj.AiuInfo[cidx].FUnitId%>, 1);
                              end
                             if ($urandom_range(0,1) == 0) begin
                                 //m_chi0_args.k_wr_cohunq_pct.set_value(100);
                                 //m_chi0_args.k_rd_rdonce_pct.set_value(0);
                                 //m_chi<%=cidx%>_vseq.set_unit_args(m_chi<%=cidx%>_args);
                                 <% if(numChiAiu > 0) { %>
                                    m_svt_chi_item.m_args = m_chi0_args;
                                 <% } %>
                                 m_snps_chi<%=cidx%>_vseq.set_unit_args(m_chi0_args);
                                 `uvm_info("VS", $sformatf("CHI<%=cidx%> Write Address = %x,size = %d, Write Data = %x", coh_addr, data_size, data_out), UVM_LOW) 
                                 m_snps_chi<%=cidx%>_vseq.write_memory_coh(coh_addr, data_out, data_size);//need to add 
                             end
                             else begin
                                 //m_chi0_args.k_wr_cohunq_pct.set_value(0);
                                 //m_chi0_args.k_rd_rdonce_pct.set_value(100);
                                 //m_chi<%=cidx%>_vseq.set_unit_args(m_chi<%=cidx%>_args);
                                 <% if(numChiAiu > 0) { %>
                                   m_svt_chi_item.m_args = m_chi0_args;
                                 <% } %>
                                 m_snps_chi<%=cidx%>_vseq.set_unit_args(m_chi0_args);
                                 m_snps_chi<%=cidx%>_vseq.read_memory_coh(coh_addr, data_in, data_size, wData);//need to add
                                 `uvm_info("VS", $sformatf("CHI<%=cidx%> Read Address = %x,size = %d,  Read Data = %x", coh_addr, data_size,data_in), UVM_LOW)
                             end
                          end   //for i
                      end // for j
                    end  // k_directed_test_all_coh 

                    if ((k_directed_test_noncoh_addr_pct != 0) && (k_directed_test_coh_addr_pct != 0)) begin  // both non-coherent and coherent
                       for (int i = 0; i < chi_num_trans; i++) begin
                          assert(std::randomize(data_out));
                          assert(std::randomize(data_out_1));
                          data_size = 6;  // 64 bytes
                          non_coh_addr = ncoreConfigInfo::user_addrq[ncoreConfigInfo::NONCOH][i];
                          coh_addr = ncoreConfigInfo::user_addrq[ncoreConfigInfo::COH][i];
                         if(non_coh_addr==0)begin
                              non_coh_addr=addr_mgr.get_noncoh_addr(<%=obj.AiuInfo[cidx].FUnitId%>, 1);
                              end 
                         if(coh_addr==0)begin
                              coh_addr=addr_mgr.get_coh_addr(<%=obj.AiuInfo[cidx].FUnitId%>, 1);
                              end 
                          if($urandom_range(0,1) == 0) begin
                              `uvm_info("VS", $sformatf("CHI<%=cidx%> Non-coherent Write Address = %x,size = %d, Write Data = %x", non_coh_addr, data_size, data_out), UVM_LOW) 
                             `uvm_info("VS", $sformatf("CHI<%=cidx%> Coherent Write Address = %x,size = %d, Write Data = %x", coh_addr, data_size, data_out_1), UVM_LOW) 
                              //m_chi0_args.k_wr_noncoh_pct.set_value(k_directed_test_noncoh_addr_pct);
                              //m_chi0_args.k_rd_noncoh_pct.set_value(0);
                              //m_chi0_args.k_wr_cohunq_pct.set_value(k_directed_test_coh_addr_pct);
                              //m_chi0_args.k_rd_rdonce_pct.set_value(0);
                              //m_chi<%=cidx%>_vseq.set_unit_args(m_chi<%=cidx%>_args);
                                 <% if(numChiAiu > 0) { %>
                                    m_svt_chi_item.m_args = m_chi0_args;
                                 <% } %>
                                 m_snps_chi<%=cidx%>_vseq.set_unit_args(m_chi0_args);
                                 m_snps_chi<%=cidx%>_vseq.write_memory(non_coh_addr, data_out, data_size); // need to add
                                 m_snps_chi<%=cidx%>_vseq.write_memory_coh(coh_addr, data_out_1, data_size); // need to add
                           end
                           else begin
                              //m_chi0_args.k_wr_noncoh_pct.set_value(0);
                              //m_chi0_args.k_rd_noncoh_pct.set_value(k_directed_test_noncoh_addr_pct);
                              //m_chi0_args.k_wr_cohunq_pct.set_value(0);
                              //m_chi0_args.k_rd_rdonce_pct.set_value(k_directed_test_coh_addr_pct);
                              //m_chi<%=cidx%>_vseq.set_unit_args(m_chi<%=cidx%>_args);
                                 <% if(numChiAiu > 0) { %>
                                    m_svt_chi_item.m_args = m_chi0_args;
                                 <% } %>
                                 m_snps_chi<%=cidx%>_vseq.set_unit_args(m_chi0_args);
                                 m_snps_chi<%=cidx%>_vseq.read_memory(ncoreConfigInfo::user_addrq[ncoreConfigInfo::NONCOH][i], data_in, data_size, wData);// need to add
                                 m_snps_chi<%=cidx%>_vseq.read_memory_coh(ncoreConfigInfo::user_addrq[ncoreConfigInfo::COH][i], data_in_1, data_size, wData);// need to add
                              `uvm_info("VS", $sformatf("CHI<%=cidx%> Non-coherent Read Address = %x,size = %d,  Read Data = %x", non_coh_addr, data_size,data_in), UVM_LOW)
                              `uvm_info("VS", $sformatf("CHI<%=cidx%> Coherent Read Address = %x,size = %d,  Read Data = %x", coh_addr, data_size,data_in_1), UVM_LOW)
                           end
                       end

                    end //k_directed_test_noncoh_addr_pct and k_directed_test_coh_addr_pct

                       `uvm_info("FULLSYS_TEST", "Done write/ read  on processor<%=idx%> : CHIAIU<%=cidx%>", UVM_NONE)
                   end // fork 
    `endif // `ifnded USE_VIP_SNPS ... `else

    
     <% cidx++;
    } else { %>
                begin 
                    bit [1023:0] data_in, data_in_1;
                    bit [1023:0] data_out, data_out_1;
                    int data_size;
                    bit [5:0] idx_val = <%=idx%>;
                    bit [ncoreConfigInfo::W_SEC_ADDR-1:0] non_coh_addr;
                    bit [ncoreConfigInfo::W_SEC_ADDR-1:0] coh_addr;
                   `uvm_info("FULLSYS_TEST", "Start write on processor<%=idx%> : IOAIU<%=ncidx%>", UVM_NONE)
                   `ifndef USE_VIP_SNPS
                   <% for(let i=0; i<aiu_NumCores[ncidx]; i++) { %> 
                   fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_seq<%=ncidx%>[<%=i%>].k_num_read_req        = 0;
                   fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_seq<%=ncidx%>[<%=i%>].k_num_write_req       = ioaiu_num_trans;
                   fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_seq<%=ncidx%>[<%=i%>].k_directed_test_alloc = 1;
        <% if((obj.AiuInfo[idx].fnNativeInterface == 'ACE') || (obj.AiuInfo[idx].fnNativeInterface == 'ACE-LITE') || (obj.AiuInfo[idx].fnNativeInterface == 'ACELITE-E')) { %>
                   fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_seq<%=ncidx%>[<%=i%>].wt_ace_rdnosnp      = 0;
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
      <% for(let i=0; i<aiu_NumCores[pidx]; i++) { %> 
                 cust_seq_h<%=ncidx%>[<%=i%>].k_num_read_req        = 0;
                   cust_seq_h<%=ncidx%>[<%=i%>].k_num_write_req       = ioaiu_num_trans;
                   cust_seq_h<%=ncidx%>[<%=i%>].k_directed_test_alloc = 1;
        <% if((obj.AiuInfo[idx].fnNativeInterface == 'ACE') || (obj.AiuInfo[idx].fnNativeInterface == 'ACE-LITE') || (obj.AiuInfo[idx].fnNativeInterface == 'ACELITE-E')) { %>
                   cust_seq_h<%=ncidx%>[<%=i%>].wt_ace_rdnosnp      = 0;
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
  
                       for (int i=0; i < ioaiu_num_trans; i++) begin
                          bit [ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA-1:0] wdata;
                          int size = $clog2(ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA/8);
                          int len;   
                          assert(std::randomize(data_out));
                          non_coh_addr = ncoreConfigInfo::user_addrq[ncoreConfigInfo::NONCOH][i];
                          coh_addr = ncoreConfigInfo::user_addrq[ncoreConfigInfo::COH][i];
                          non_coh_addr[12:0] = {idx_val, 7'b0000000};
                          coh_addr[12:0] = {idx_val, 7'b0000000};
                          if ($test$plusargs("k_directed_test_all_non_coh")) begin
                            for(int len = 0; len < 4; len++) begin  // 0 implies 16B
                                assert(std::randomize(data_out));
                                if ($urandom_range(0,1) == 0) begin
                                   `uvm_info("VS", $sformatf("IOAIU<%=ncidx%> AXI Write Non-coherent Addr=%x, data_out = %x", non_coh_addr, data_out), UVM_LOW)
                                    write_ioaiu<%=ncidx%>(non_coh_addr, len, size, data_out[1023:0], 0);
                                end
                                else begin
                                   read_ioaiu<%=ncidx%>(non_coh_addr, len, size, data_in[1023:0]);
                                  `uvm_info("VS", $sformatf("IOAIU<%=ncidx%> AXI Read Non-coherent Addr=%x, data_in = %x", non_coh_addr, data_in), UVM_LOW)
                                end
                            end
                          end

                          len = 3;
                          assert(std::randomize(data_out));
                          if ($test$plusargs("k_directed_test_all_coh")) begin
                          <% if(!(obj.AiuInfo[idx].fnNativeInterface == 'AXI4' && !obj.AiuInfo[idx].useCache)) { %>
                              if ($urandom_range(0,1) == 0) begin
                                 `uvm_info("VS", $sformatf("IOAIU<%=ncidx%> AXI Write Coherent Addr=%x, data_out = %x", coh_addr, data_out), UVM_LOW)
                                  write_ioaiu<%=ncidx%>(coh_addr, len, size, data_out[1023:0], 1);
                              end
                              else begin
                                 read_ioaiu_rdonce<%=ncidx%>(coh_addr, len, size, data_in[1023:0]);
                                 `uvm_info("VS", $sformatf("IOAIU<%=ncidx%> AXI Read Coherent Addr=%x, data_in = %x", coh_addr, data_in), UVM_LOW)
                             end
                          <% } %>
                          end

                          assert(std::randomize(data_out));
                          if ((k_directed_test_noncoh_addr_pct != 0) && (k_directed_test_coh_addr_pct != 0)) begin  // both non-coherent and coherent
                             randcase
                                k_directed_test_noncoh_addr_pct: begin
                                                                      if ($urandom_range(0,1) == 0) begin
                                                                          `uvm_info("VS", $sformatf("IOAIU<%=ncidx%> AXI Write Non-coherent Addr=%x, data_out = %x", non_coh_addr, data_out), UVM_LOW)
                                                                           write_ioaiu<%=ncidx%>(non_coh_addr, len, size, data_out[1023:0], 0);
                                                                      end
                                                                      else begin
                                                                          read_ioaiu<%=ncidx%>(non_coh_addr, len, size, data_in[1023:0]);
                                                                         `uvm_info("VS", $sformatf("IOAIU<%=ncidx%> AXI Read Non-coherent Addr=%x, data_in = %x", non_coh_addr, data_in), UVM_LOW)
                                                                      end
                                                                 end
                                k_directed_test_coh_addr_pct:    begin
                                                                     if ($urandom_range(0,1) == 0) begin
                                                                         `uvm_info("VS", $sformatf("IOAIU<%=ncidx%> AXI Write Coherent Addr=%x, data_out = %x", coh_addr, data_out), UVM_LOW)
                                                                         write_ioaiu<%=ncidx%>(coh_addr, len, size, data_out[1023:0], 1);
                                                                     end
                                                                     else begin
                                                                         read_ioaiu_rdonce<%=ncidx%>(coh_addr, len, size, data_in[1023:0]);
                                                                        `uvm_info("VS", $sformatf("IOAIU<%=ncidx%> AXI Read Coherent Addr=%x, data_in = %x", coh_addr, data_in), UVM_LOW)
                                                                     end
                                                                 end
                             endcase

                          end
                       end  // for
/*
                   fork
                   begin
                       phase.raise_objection(this, "IOAIU<%=ncidx%> sequence");
                       // m_iocache_seq<%=ncidx%>.start(null);
                       `uvm_info("FULLSYS_TEST", "Done write on processor<%=idx%> : IOAIU<%=ncidx%>", UVM_NONE)
                       #10us;
                       phase.drop_objection(this, "IOAIU<%=ncidx%> sequence");
                   end
                   begin
                       ev_ioaiu<%=ncidx%>_seq_done.wait_trigger();
                       ev_sim_done.trigger(null);
                   end
                   join
*/
                   end  // fork

     <% ncidx++;
    }
  } %>
  join
//`endif //`ifndef USE_VIP_SNPS
endtask : directed_write_read_test_all_aius_random

//*************************************************************************************



//*************************************************************************************
  <% for(idx = 0, ncidx=0; idx < obj.nAIUs; idx++) { 
    if(!(obj.AiuInfo[idx].fnNativeInterface.match('CHI'))) { %>

`ifdef USE_VIP_SNPS


    <%if(numACEAiu>1 && obj.AiuInfo[idx].fnNativeInterface == 'ACE'){%>
task concerto_fullsys_direct_wr_rd_legacy_test::write_ioaiu_wrevict<%=ncidx%>(input ioaiu<%=ncidx%>_axi_agent_pkg::axi_axaddr_t addr,
                                                  int len,
                                                  int size);
    int core_id=0;
    bit check_unconnected;
    bit [2:0] unit_unconnected;

fsys_svt_seq_lib::seq_lib_svt_ace_wrevict_sequence m_iowrnosnp_wrunq<%=ncidx%>;
//seq_lib_svt_ace_write_sequence m_iowrnosnp_wrunq<%=ncidx%>[<%=aiu_NumCores[pidx]%>];
    									
    check_unconnected = 0;
    m_iowrnosnp_wrunq<%=ncidx%>   = fsys_svt_seq_lib::seq_lib_svt_ace_wrevict_sequence::type_id::create("m_iowrnosnp_wrunq<%=ncidx%>");
    m_iowrnosnp_wrunq<%=ncidx%>.directed_wr_rd =1;
    m_iowrnosnp_wrunq<%=ncidx%>.myAddr = addr;
    m_iowrnosnp_wrunq<%=ncidx%>.axlen = len + 1;
    m_iowrnosnp_wrunq<%=ncidx%>.awsize = size;
    ncoreConfigInfo::extract_intlv_bits_in_addr(ncoreConfigInfo::mp_aiu_intv_bits[<%=obj.AiuInfo[idx].FUnitId%>].pri_bits, addr, core_id);

check_unconnected=ncoreConfigInfo::check_unmapped_add(addr,<%=obj.AiuInfo[idx].FUnitId%>,unit_unconnected);
    if(check_unconnected==0)begin
    <% if(obj.AiuInfo[idx].nNativeInterfacePorts>1){%>
        //ace_axi_seq<%=ncidx%>.start(m_concerto_env.snps.svt.amba_system_env.axi_system[0].master[<%=obj.AiuInfo[idx].rpn[0]-chi_idx%>+core_id].sequencer);
        m_iowrnosnp_wrunq<%=ncidx%>.start(m_concerto_env.snps.svt.amba_system_env.axi_system[0].master[<%=obj.AiuInfo[idx].rpn[0]-chi_idx%>+core_id].sequencer);
    <% }else { %>
        m_iowrnosnp_wrunq<%=ncidx%>.start(m_concerto_env.snps.svt.amba_system_env.axi_system[0].master[<%=obj.AiuInfo[idx].rpn-chi_idx%>].sequencer);
        //ace_axi_seq<%=ncidx%>.start(m_concerto_env.snps.svt.amba_system_env.axi_system[0].master[<%=obj.AiuInfo[idx].rpn-chi_idx%>].sequencer);
    <% } %>
    end else begin
        `uvm_info("VS", $sformatf("Trying to access unconnected slave dropping addr %0h",addr), UVM_NONE)
    end


endtask : write_ioaiu_wrevict<%=ncidx%>


task concerto_fullsys_direct_wr_rd_legacy_test::write_ioaiu_wlunq<%=ncidx%>(input ioaiu<%=ncidx%>_axi_agent_pkg::axi_axaddr_t addr,
                                                  int len,
                                                  int size);
    int core_id=0;
    bit check_unconnected;
    bit [2:0] unit_unconnected;

fsys_svt_seq_lib::seq_lib_svt_ace_wlunq_sequence m_iowrnosnp_wrunq<%=ncidx%>;
//seq_lib_svt_ace_write_sequence m_iowrnosnp_wrunq<%=ncidx%>[<%=aiu_NumCores[pidx]%>];
    									
    check_unconnected = 0;
    m_iowrnosnp_wrunq<%=ncidx%>   = fsys_svt_seq_lib::seq_lib_svt_ace_wlunq_sequence::type_id::create("m_iowrnosnp_wrunq<%=ncidx%>");
    m_iowrnosnp_wrunq<%=ncidx%>.directed_wr_rd =1;
    m_iowrnosnp_wrunq<%=ncidx%>.myAddr = addr;
    m_iowrnosnp_wrunq<%=ncidx%>.axlen = len + 1;
    m_iowrnosnp_wrunq<%=ncidx%>.awsize = size;
    ncoreConfigInfo::extract_intlv_bits_in_addr(ncoreConfigInfo::mp_aiu_intv_bits[<%=obj.AiuInfo[idx].FUnitId%>].pri_bits, addr, core_id);

check_unconnected=ncoreConfigInfo::check_unmapped_add(addr,<%=obj.AiuInfo[idx].FUnitId%>,unit_unconnected);
    if(check_unconnected==0)begin
    <% if(obj.AiuInfo[idx].nNativeInterfacePorts>1){%>
        //ace_axi_seq<%=ncidx%>.start(m_concerto_env.snps.svt.amba_system_env.axi_system[0].master[<%=obj.AiuInfo[idx].rpn[0]-chi_idx%>+core_id].sequencer);
        m_iowrnosnp_wrunq<%=ncidx%>.start(m_concerto_env.snps.svt.amba_system_env.axi_system[0].master[<%=obj.AiuInfo[idx].rpn[0]-chi_idx%>+core_id].sequencer);
    <% }else { %>
        m_iowrnosnp_wrunq<%=ncidx%>.start(m_concerto_env.snps.svt.amba_system_env.axi_system[0].master[<%=obj.AiuInfo[idx].rpn-chi_idx%>].sequencer);
        //ace_axi_seq<%=ncidx%>.start(m_concerto_env.snps.svt.amba_system_env.axi_system[0].master[<%=obj.AiuInfo[idx].rpn-chi_idx%>].sequencer);
    <% } %>
    end else begin
        `uvm_info("VS", $sformatf("Trying to access unconnected slave dropping addr %0h",addr), UVM_NONE)
    end


endtask : write_ioaiu_wlunq<%=ncidx%>
    <% } %>

task concerto_fullsys_direct_wr_rd_legacy_test::write_ioaiu<%=ncidx%>(input ioaiu<%=ncidx%>_axi_agent_pkg::axi_axaddr_t addr,
                                                  int len,
                                                  int size,
                                                  bit [1023:0] data,
                                                  int coh);
    int core_id=0;
    bit check_unconnected;
    bit [2:0] unit_unconnected;

fsys_svt_seq_lib::seq_lib_svt_data_integrity_ace_write_sequence m_iowrnosnp_wrunq<%=ncidx%>;
//seq_lib_svt_ace_write_sequence m_iowrnosnp_wrunq<%=ncidx%>[<%=aiu_NumCores[pidx]%>];
    bit [ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA-1 : 0] wdata;
    int addr_mask;
    int addr_offset;
    									
    addr_mask = (ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA/8)-1;
    addr_offset = addr & addr_mask;
    check_unconnected = 0;
    m_iowrnosnp_wrunq<%=ncidx%>   = fsys_svt_seq_lib::seq_lib_svt_data_integrity_ace_write_sequence::type_id::create("m_iowrnosnp_wrunq<%=ncidx%>");
    m_iowrnosnp_wrunq<%=ncidx%>.directed_wr_rd =1;
    m_iowrnosnp_wrunq<%=ncidx%>.myAddr = addr;
    m_iowrnosnp_wrunq<%=ncidx%>.axlen = len + 1;
    m_iowrnosnp_wrunq<%=ncidx%>.awsize = size;
    ncoreConfigInfo::extract_intlv_bits_in_addr(ncoreConfigInfo::mp_aiu_intv_bits[<%=obj.AiuInfo[idx].FUnitId%>].pri_bits, addr, core_id);

       // m_iowrnosnp_wrunq<%=ncidx%>.m_data[(addr_offset*8)+:32] = data;
    case (len)
      0:   m_iowrnosnp_wrunq<%=ncidx%>.myData[ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA-1 : 0] = data[ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA-1 : 0];
      1: begin
           m_iowrnosnp_wrunq<%=ncidx%>.myData[ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA-1 : 0] = data[ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA-1 : 0];
           m_iowrnosnp_wrunq<%=ncidx%>.myData[(2*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA)-1 :ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA] = data[(2*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA)-1 :ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA];
         end
      2: begin
           m_iowrnosnp_wrunq<%=ncidx%>.myData[ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA-1:0] = data[ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA-1:0];
           m_iowrnosnp_wrunq<%=ncidx%>.myData[(2*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA)-1:ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA] = data[(2*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA)-1:ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA];
           m_iowrnosnp_wrunq<%=ncidx%>.myData[(3*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA)-1:(2*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA)] = data[(3*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA)-1:(2*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA)];
         end
      3: begin
           m_iowrnosnp_wrunq<%=ncidx%>.myData[ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA-1:0] = data[ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA-1:0];
           m_iowrnosnp_wrunq<%=ncidx%>.myData[(2*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA)-1:ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA] = data[(2*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA)-1:ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA];
           m_iowrnosnp_wrunq<%=ncidx%>.myData[(3*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA)-1:(2*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA)] = data[(3*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA)-1:(2*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA)];
           m_iowrnosnp_wrunq<%=ncidx%>.myData[(4*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA)-1:(3*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA)] = data[(4*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA)-1:(3*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA)];
         end
      7: begin
           m_iowrnosnp_wrunq<%=ncidx%>.myData[ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA-1:0] = data[ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA-1:0];
           m_iowrnosnp_wrunq<%=ncidx%>.myData[(2*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA)-1:ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA] = data[(2*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA)-1:ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA];
           m_iowrnosnp_wrunq<%=ncidx%>.myData[(3*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA)-1:(2*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA)] = data[(3*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA)-1:(2*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA)];
           m_iowrnosnp_wrunq<%=ncidx%>.myData[(4*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA)-1:(3*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA)] = data[(4*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA)-1:(3*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA)];
           m_iowrnosnp_wrunq<%=ncidx%>.myData[(5*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA)-1:(4*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA)] = data[(5*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA)-1:(4*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA)];
           m_iowrnosnp_wrunq<%=ncidx%>.myData[(6*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA)-1:(5*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA)] = data[(6*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA)-1:(5*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA)];
           m_iowrnosnp_wrunq<%=ncidx%>.myData[(7*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA)-1:(6*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA)] = data[(7*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA)-1:(6*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA)];
           m_iowrnosnp_wrunq<%=ncidx%>.myData[(8*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA)-1:(7*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA)] = data[(8*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA)-1:(7*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA)];
         end
      15: begin
           m_iowrnosnp_wrunq<%=ncidx%>.myData[ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA-1:0] = data[ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA-1:0];
           m_iowrnosnp_wrunq<%=ncidx%>.myData[(2*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA)-1:ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA] = data[(2*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA)-1:ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA];
           m_iowrnosnp_wrunq<%=ncidx%>.myData[(3*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA)-1:(2*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA)] = data[(3*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA)-1:(2*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA)];
           m_iowrnosnp_wrunq<%=ncidx%>.myData[(4*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA)-1:(3*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA)] = data[(4*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA)-1:(3*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA)];
           m_iowrnosnp_wrunq<%=ncidx%>.myData[(5*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA)-1:(4*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA)] = data[(5*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA)-1:(4*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA)];
           m_iowrnosnp_wrunq<%=ncidx%>.myData[(6*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA)-1:(5*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA)] = data[(6*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA)-1:(5*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA)];
           m_iowrnosnp_wrunq<%=ncidx%>.myData[(7*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA)-1:(6*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA)] = data[(7*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA)-1:(6*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA)];
           m_iowrnosnp_wrunq<%=ncidx%>.myData[(8*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA)-1:(7*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA)] = data[(8*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA)-1:(7*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA)];
           m_iowrnosnp_wrunq<%=ncidx%>.myData[(9*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA)-1:(8*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA)] = data[(9*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA)-1:(8*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA)];
           m_iowrnosnp_wrunq<%=ncidx%>.myData[(10*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA)-1:(9*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA)] = data[(10*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA)-1:(9*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA)];
           m_iowrnosnp_wrunq<%=ncidx%>.myData[(11*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA)-1:(10*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA)] = data[(11*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA)-1:(10*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA)];
           m_iowrnosnp_wrunq<%=ncidx%>.myData[(12*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA)-1:(11*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA)] = data[(12*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA)-1:(11*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA)];
           m_iowrnosnp_wrunq<%=ncidx%>.myData[(13*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA)-1:(12*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA)] = data[(13*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA)-1:(12*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA)];
           m_iowrnosnp_wrunq<%=ncidx%>.myData[(14*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA)-1:(13*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA)] = data[(14*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA)-1:(13*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA)];
           m_iowrnosnp_wrunq<%=ncidx%>.myData[(15*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA)-1:(14*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA)] = data[(15*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA)-1:(14*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA)];
           m_iowrnosnp_wrunq<%=ncidx%>.myData[(16*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA)-1:(15*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA)] = data[(16*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA)-1:(15*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA)];
         end

      default: `uvm_error("VS", $sformatf("Unsupported length %d for AXI transfer", len))
   endcase
      
    // m_iowrnosnp_wrunq<%=ncidx%>.m_wstrb = 32'hF<<addr_offset; // Assuming (ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA/8) < 32
    // m_iowrnosnp_wrunq<%=ncidx%>.m_wstrb = 32'hFFFF; // 16B write
    case (ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA)
       32: m_iowrnosnp_wrunq<%=ncidx%>.wstrb = 32'h0000_000f;
       64: m_iowrnosnp_wrunq<%=ncidx%>.wstrb = 32'h0000_00ff;
       128:m_iowrnosnp_wrunq<%=ncidx%>.wstrb = 32'h0000_ffff;
       256:m_iowrnosnp_wrunq<%=ncidx%>.wstrb = 32'hffff_ffff;
       default: `uvm_error("VS", $sformatf("Unsupported Size ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA"))
    endcase
    `uvm_info("VS", $sformatf("IOAIU<%=ncidx%> Write Addr=%x, Data=%x",addr, data), UVM_LOW)
    m_iowrnosnp_wrunq<%=ncidx%>.m_coh_transaction = coh;

    check_unconnected=ncoreConfigInfo::check_unmapped_add(addr,<%=obj.AiuInfo[idx].FUnitId%>,unit_unconnected);
    if(check_unconnected==0)begin
    <% if(obj.AiuInfo[idx].nNativeInterfacePorts>1){%>
        //ace_axi_seq<%=ncidx%>.start(m_concerto_env.snps.svt.amba_system_env.axi_system[0].master[<%=obj.AiuInfo[idx].rpn[0]-chi_idx%>+core_id].sequencer);
        m_iowrnosnp_wrunq<%=ncidx%>.start(m_concerto_env.snps.svt.amba_system_env.axi_system[0].master[<%=obj.AiuInfo[idx].rpn[0]-chi_idx%>+core_id].sequencer);
    <% }else { %>
        m_iowrnosnp_wrunq<%=ncidx%>.start(m_concerto_env.snps.svt.amba_system_env.axi_system[0].master[<%=obj.AiuInfo[idx].rpn-chi_idx%>].sequencer);
        //ace_axi_seq<%=ncidx%>.start(m_concerto_env.snps.svt.amba_system_env.axi_system[0].master[<%=obj.AiuInfo[idx].rpn-chi_idx%>].sequencer);
    <% } %>
    end else begin
        `uvm_info("VS", $sformatf("Trying to access unconnected slave dropping addr %0h",addr), UVM_NONE)
    end

   // m_iowrnosnp_wrunq<%=ncidx%>.start(m_concerto_env.snps.svt.amba_system_env.axi_system[0].master[<%=ncidx%>].sequencer);
    


endtask : write_ioaiu<%=ncidx%>
`else //`ifdef USE_VIP_SNPS
task concerto_fullsys_direct_wr_rd_legacy_test::write_ioaiu<%=ncidx%>(input ioaiu<%=ncidx%>_axi_agent_pkg::axi_axaddr_t addr,
                                                  int len,
                                                  int size,
                                                  bit [1023:0] data,
                                                  int coh);
    ioaiu<%=ncidx%>_inhouse_axi_bfm_pkg::axi_wrnosnp_wrunq_seq m_iowrnosnp_wrunq<%=ncidx%>[<%=aiu_NumCores[idx]%>];
    bit [ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA-1:0] wdata;
    int addr_mask;
    int addr_offset;
										
    addr_mask = (ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA/8)-1;
    addr_offset = addr & addr_mask;
<% for(let i=0; i<aiu_NumCores[idx]; i++) { %> 
    m_iowrnosnp_wrunq<%=ncidx%>[<%=i%>]   = ioaiu<%=ncidx%>_inhouse_axi_bfm_pkg::axi_wrnosnp_wrunq_seq::type_id::create("m_iowrnosnp_wrunq<%=ncidx%>");
    m_iowrnosnp_wrunq<%=ncidx%>[<%=i%>].m_ace_cache_model      = m_concerto_env.inhouse.m_ace_cache_model_ioaiu<%=ncidx%>[<%=i%>];

    m_iowrnosnp_wrunq<%=ncidx%>[<%=i%>].m_addr = addr;
    m_iowrnosnp_wrunq<%=ncidx%>[<%=i%>].m_axlen = len;
    m_iowrnosnp_wrunq<%=ncidx%>[<%=i%>].m_size = size;
    m_iowrnosnp_wrunq<%=ncidx%>[<%=i%>].generate_per_beat_strb = 1;
    // m_iowrnosnp_wrunq<%=ncidx%>[<%=i%>].m_data[(addr_offset*8)+:32] = data; 
    case (len)
      0:   m_iowrnosnp_wrunq<%=ncidx%>[<%=i%>].m_data[0] = data[ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA-1:0];
      1: begin
           m_iowrnosnp_wrunq<%=ncidx%>[<%=i%>].m_data[0] = data[ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA-1:0];
           m_iowrnosnp_wrunq<%=ncidx%>[<%=i%>].m_data[1] = data[2*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA-1:ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA];
         end
      2: begin
           m_iowrnosnp_wrunq<%=ncidx%>[<%=i%>].m_data[0] = data[ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA-1:0];
           m_iowrnosnp_wrunq<%=ncidx%>[<%=i%>].m_data[1] = data[2*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA-1:ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA];
           m_iowrnosnp_wrunq<%=ncidx%>[<%=i%>].m_data[2] = data[3*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA-1:2*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA];
         end
      3: begin
           m_iowrnosnp_wrunq<%=ncidx%>[<%=i%>].m_data[0] = data[ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA-1:0];
           m_iowrnosnp_wrunq<%=ncidx%>[<%=i%>].m_data[1] = data[2*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA-1:ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA];
           m_iowrnosnp_wrunq<%=ncidx%>[<%=i%>].m_data[2] = data[3*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA-1:2*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA];
           m_iowrnosnp_wrunq<%=ncidx%>[<%=i%>].m_data[3] = data[4*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA-1:3*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA];
         end
      default: `uvm_error("VS", $sformatf("Unsupported length %d for AXI transfer", len))
      
   endcase
      
    // m_iowrnosnp_wrunq<%=ncidx%>.m_wstrb = 32'hF<<addr_offset; // Assuming (ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA/8) < 32
    // m_iowrnosnp_wrunq<%=ncidx%>.m_wstrb = 32'hFFFF; // 16B write
    case (ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA)
       32: m_iowrnosnp_wrunq<%=ncidx%>[<%=i%>].m_wstrb = 32'h0000_000f;
       64: m_iowrnosnp_wrunq<%=ncidx%>[<%=i%>].m_wstrb = 32'h0000_00ff;
       128:m_iowrnosnp_wrunq<%=ncidx%>[<%=i%>].m_wstrb = 32'h0000_ffff;
       256:m_iowrnosnp_wrunq<%=ncidx%>[<%=i%>].m_wstrb = 32'hffff_ffff;
       default: `uvm_error("VS", $sformatf("Unsupported Size ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA"))
    endcase
       
    `uvm_info("VS", $sformatf("IOAIU<%=ncidx%> Write Addr=%x, Data=%x",addr, data), UVM_LOW)
    m_iowrnosnp_wrunq<%=ncidx%>[<%=i%>].m_coh_transaction = coh;
    m_iowrnosnp_wrunq<%=ncidx%>[<%=i%>].start(m_ioaiu_vseqr<%=ncidx%>[<%=i%>]);
    <% }%>
endtask : write_ioaiu<%=ncidx%>
`endif //`ifdef USE_VIP_SNPS ... `else

`ifdef USE_VIP_SNPS
task concerto_fullsys_direct_wr_rd_legacy_test::read_ioaiu<%=ncidx%>(input ioaiu<%=ncidx%>_axi_agent_pkg::axi_axaddr_t addr, 
                                                 int len,
                                                 int size,
                                                 output bit[1023:0] data);

int core_id=0;
    bit check_unconnected;
    bit [2:0] unit_unconnected;
     fsys_svt_seq_lib::seq_lib_svt_data_integrity_ace_read_sequence m_iordnosnp_seq<%=ncidx%>;
    svt_axi_master_transaction m_seq_item;
    bit [ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA-1:0] rdata[];  
    //ioaiu<%=ncidx%>_axi_agent_pkg::axi_rresp_t rresp;
    int addr_mask;
    int addr_offset;
    int num_bits, starting_bit;
										
    rdata=new[len+1];// Up to len+1 transfers
    addr_mask = (ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA/8)-1;
    addr_offset = addr & addr_mask; 
    check_unconnected = 0;
    m_iordnosnp_seq<%=ncidx%>   =  fsys_svt_seq_lib::seq_lib_svt_data_integrity_ace_read_sequence::type_id::create("m_iordnosnp_seq<%=ncidx%>");
    
     m_iordnosnp_seq<%=ncidx%>.tr = svt_axi_master_transaction::type_id::create("tr");
    m_iordnosnp_seq<%=ncidx%>.arsize = $clog2(ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA/8);
    m_iordnosnp_seq<%=ncidx%>.myAddr = addr;
    m_iordnosnp_seq<%=ncidx%>.axlen = len + 1;
    m_iordnosnp_seq<%=ncidx%>.directed_wr_rd =1;
    //m_iordnosnp_seq<%=ncidx%>.m_size = size;
    ncoreConfigInfo::extract_intlv_bits_in_addr(ncoreConfigInfo::mp_aiu_intv_bits[<%=obj.AiuInfo[idx].FUnitId%>].pri_bits, addr, core_id);

    check_unconnected=ncoreConfigInfo::check_unmapped_add(addr,<%=obj.AiuInfo[idx].FUnitId%>,unit_unconnected);
    if(check_unconnected==0)begin
    <% if(obj.AiuInfo[idx].nNativeInterfacePorts>1){%>
        //ace_axi_seq<%=ncidx%>.start(m_concerto_env.snps.svt.amba_system_env.axi_system[0].master[<%=obj.AiuInfo[idx].rpn[0]-chi_idx%>+core_id].sequencer);
        m_iordnosnp_seq<%=ncidx%>.start(m_concerto_env.snps.svt.amba_system_env.axi_system[0].master[<%=obj.AiuInfo[idx].rpn[0]-chi_idx%>+core_id].sequencer);
    <% }else { %>
        m_iordnosnp_seq<%=ncidx%>.start(m_concerto_env.snps.svt.amba_system_env.axi_system[0].master[<%=obj.AiuInfo[idx].rpn-chi_idx%>].sequencer);
        //ace_axi_seq<%=ncidx%>.start(m_concerto_env.snps.svt.amba_system_env.axi_system[0].master[<%=obj.AiuInfo[idx].rpn-chi_idx%>].sequencer);
    <% } %>
    end else begin
        `uvm_info("VS", $sformatf("Trying to access unconnected slave dropping addr %0h",addr), UVM_NONE)
    end

   // m_iordnosnp_seq<%=ncidx%>.start(m_concerto_env.snps.svt.amba_system_env.axi_system[0].master[<%=ncidx%>].sequencer);
   
    for (int i=0; i < len+1; i++) begin
      rdata[i] = m_iordnosnp_seq<%=ncidx%>.tr.data[i];
      // data[i] = rdata[(addr_offset*8)+:32];
      num_bits = 2 ** size;
      starting_bit = i * num_bits * 8;
      data[starting_bit+:ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA] = rdata[i];
      
      `uvm_info("VS", $sformatf("IOAIU<%=ncidx%> Read Addr = %x, rdata[%d] = %x, ", addr, i, rdata[i]), UVM_LOW)
    end
   /* rresp =  (m_iordnosnp_seq<%=ncidx%>.m_seq_item.m_has_data) ? m_iordnosnp_seq<%=ncidx%>.m_seq_item.m_read_data_pkt.rresp : 0;
    if(rresp) begin
        `uvm_error("READ_IOAIU",$sformatf("Resp_err :0x%0h on Read Data",rresp))
    end */

endtask : read_ioaiu<%=ncidx%>
`else //`ifdef USE_VIP_SNPS
task concerto_fullsys_direct_wr_rd_legacy_test::read_ioaiu<%=ncidx%>(input ioaiu<%=ncidx%>_axi_agent_pkg::axi_axaddr_t addr, 
                                                 int len,
                                                 int size,
                                                 output bit[1023:0] data);
    ioaiu<%=ncidx%>_inhouse_axi_bfm_pkg::axi_rdnosnp_seq m_iordnosnp_seq<%=ncidx%>[<%=aiu_NumCores[idx]%>];
    bit [ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA-1:0] rdata[4];  // Up to 4 transfers
    ioaiu<%=ncidx%>_axi_agent_pkg::axi_rresp_t rresp[<%=aiu_NumCores[idx]%>];
    int addr_mask;
    int addr_offset;
    int num_bits, starting_bit;
										
    addr_mask = (ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA/8)-1;
    addr_offset = addr & addr_mask;
   <% for(let i=0; i<aiu_NumCores[idx]; i++) { %> 
    m_iordnosnp_seq<%=ncidx%>[<%=i%>]   = ioaiu<%=ncidx%>_inhouse_axi_bfm_pkg::axi_rdnosnp_seq::type_id::create("m_iordnosnp_seq<%=ncidx%>[<%=i%>]");
    m_iordnosnp_seq<%=ncidx%>[<%=i%>].m_addr = addr;
    m_iordnosnp_seq<%=ncidx%>[<%=i%>].m_len = len;
    m_iordnosnp_seq<%=ncidx%>[<%=i%>].m_size = size;
    m_iordnosnp_seq<%=ncidx%>[<%=i%>].start(m_ioaiu_vseqr<%=ncidx%>[<%=i%>]);
   <% } %>
    for (int i=0; i < len+1; i++) begin
      <% for(let n=0; n<aiu_NumCores[idx]; n++) { %> 
      rdata[i] = (m_iordnosnp_seq<%=ncidx%>[<%=n%>].m_seq_item.m_has_data) ? m_iordnosnp_seq<%=ncidx%>[<%=n%>].m_seq_item.m_read_data_pkt.rdata[i] : 0;
      <% } %>
      // data[i] = rdata[(addr_offset*8)+:32];
      num_bits = 2 ** size;
      starting_bit = i * num_bits * 8;
      data[starting_bit+:ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA] = rdata[i];
      
      `uvm_info("VS", $sformatf("IOAIU<%=ncidx%> Read Addr = %x, rdata[%d] = %x, ", addr, i, rdata[i]), UVM_LOW)
    end
    <% for(let i=0; i<aiu_NumCores[idx]; i++) { %>
    rresp[<%=i%>] =  (m_iordnosnp_seq<%=ncidx%>[<%=i%>].m_seq_item.m_has_data) ? m_iordnosnp_seq<%=ncidx%>[<%=i%>].m_seq_item.m_read_data_pkt.rresp : 0;
    // for nrsar test receiving Resp_err is expected so when k_nrsar_test == 1 this check is disabled
    if(k_nrsar_test==0) begin
      if(rresp[<%=i%>]) begin
          `uvm_error("READ_IOAIU",$sformatf("Resp_err :0x%0h on Read Data",rresp[<%=i%>]))
      end
    end
    <% } %>
endtask : read_ioaiu<%=ncidx%>
`endif //`ifdef USE_VIP_SNPS ... `else

`ifdef USE_VIP_SNPS
    <%if(numACEAiu>1 && obj.AiuInfo[idx].fnNativeInterface == 'ACE'){%>
task concerto_fullsys_direct_wr_rd_legacy_test::read_ioaiu_rd_all<%=ncidx%>(input ioaiu<%=ncidx%>_axi_agent_pkg::axi_axaddr_t addr, 
                                                 int len,
                                                 int size);

fsys_svt_seq_lib::seq_lib_svt_ace_all_read_sequence m_iordonce_seq<%=ncidx%>[<%=aiu_NumCores[idx]%>];
    svt_axi_master_transaction m_seq_item;
										
   <% for(let i=0; i<aiu_NumCores[idx]; i++) { %>  
   m_iordonce_seq<%=ncidx%>[<%=i%>]   =  fsys_svt_seq_lib::seq_lib_svt_ace_all_read_sequence::type_id::create("m_iordonce_seq<%=ncidx%>[<%=i%>]");
   m_iordonce_seq<%=ncidx%>[<%=i%>].arsize = $clog2(ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA/8);
   m_iordonce_seq<%=ncidx%>[<%=i%>].directed_wr_rd =1;
   m_iordonce_seq<%=ncidx%>[<%=i%>].axlen = len + 1;
   m_iordonce_seq<%=ncidx%>[<%=i%>].myAddr = addr;
   // m_iordonce_seq<%=ncidx%>.m_size = size;
    m_iordonce_seq<%=ncidx%>[<%=i%>].start(m_concerto_env.snps.svt.amba_system_env.axi_system[0].master[<%=ncidx%>].sequencer);   
    <% } %>

endtask : read_ioaiu_rd_all<%=ncidx%>

task concerto_fullsys_direct_wr_rd_legacy_test::read_ioaiu_rdunq<%=ncidx%>(input ioaiu<%=ncidx%>_axi_agent_pkg::axi_axaddr_t addr, 
                                                 int len,
                                                 int size);

fsys_svt_seq_lib::seq_lib_svt_ace_rdunq_sequence m_iordonce_seq<%=ncidx%>[<%=aiu_NumCores[idx]%>];
    svt_axi_master_transaction m_seq_item;
										
   <% for(let i=0; i<aiu_NumCores[idx]; i++) { %>  
   m_iordonce_seq<%=ncidx%>[<%=i%>]   =  fsys_svt_seq_lib::seq_lib_svt_ace_rdunq_sequence::type_id::create("m_iordonce_seq<%=ncidx%>[<%=i%>]");
   m_iordonce_seq<%=ncidx%>[<%=i%>].arsize = $clog2(ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA/8);
   m_iordonce_seq<%=ncidx%>[<%=i%>].axlen = len + 1;
   m_iordonce_seq<%=ncidx%>[<%=i%>].myAddr = addr;
   // m_iordonce_seq<%=ncidx%>.m_size = size;
    m_iordonce_seq<%=ncidx%>[<%=i%>].start(m_concerto_env.snps.svt.amba_system_env.axi_system[0].master[<%=ncidx%>].sequencer);   
    <% } %>

endtask : read_ioaiu_rdunq<%=ncidx%>
   <% } %>

task concerto_fullsys_direct_wr_rd_legacy_test::read_ioaiu_rdonce<%=ncidx%>(input ioaiu<%=ncidx%>_axi_agent_pkg::axi_axaddr_t addr, 
                                                 int len,
                                                 int size,
                                                 output bit[1023:0] data);

fsys_svt_seq_lib::seq_lib_svt_ace_read_sequence m_iordonce_seq<%=ncidx%>[<%=aiu_NumCores[idx]%>];
    svt_axi_master_transaction m_seq_item;
    bit [ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA-1:0] rdata[4];  // Up to 4 transfers
    //ioaiu<%=ncidx%>_axi_agent_pkg::axi_rresp_t rresp;
    int addr_mask;
    int addr_offset;
    int num_bits, starting_bit;
										
    addr_mask = (ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA/8)-1;
    addr_offset = addr & addr_mask;
   <% for(let i=0; i<aiu_NumCores[idx]; i++) { %>  
   m_iordonce_seq<%=ncidx%>[<%=i%>]   =  fsys_svt_seq_lib::seq_lib_svt_ace_read_sequence::type_id::create("m_iordonce_seq<%=ncidx%>[<%=i%>]");
   m_iordonce_seq<%=ncidx%>[<%=i%>].arsize = $clog2(ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA/8);
   m_iordonce_seq<%=ncidx%>[<%=i%>].directed_wr_rd =1;
   m_iordonce_seq<%=ncidx%>[<%=i%>].addr_offset = addr_offset;
   m_iordonce_seq<%=ncidx%>[<%=i%>].tr = svt_axi_master_transaction::type_id::create("tr");
   m_iordonce_seq<%=ncidx%>[<%=i%>].axlen = len + 1;
   m_iordonce_seq<%=ncidx%>[<%=i%>].myAddr = addr;
   m_iordonce_seq<%=ncidx%>[<%=i%>].m_coh_transaction =1;
   // m_iordonce_seq<%=ncidx%>.m_size = size;
    m_iordonce_seq<%=ncidx%>[<%=i%>].arid = 0;
    m_iordonce_seq<%=ncidx%>[<%=i%>].start(m_concerto_env.snps.svt.amba_system_env.axi_system[0].master[<%=ncidx%>].sequencer);   
    <% } %>
    for (int i=0; i < len+1; i++) begin
       <% for(let n=0; n<aiu_NumCores[idx]; n++) { %> 
      rdata[i] = /* (m_iordonce_seq<%=ncidx%>.m_seq_item.m_has_data) ? */m_iordonce_seq<%=ncidx%>[<%=n%>].tr.data[i];
       <% } %>
      // data[i] = rdata[(addr_offset*8)+:32];
      num_bits = 2 ** size;
      starting_bit = i * num_bits * 8;
      data[starting_bit+:ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA] = rdata[i];
      
    //   `uvm_info("VS", $sformatf("IOAIU<%=ncidx%> Read Addr = %x, rdata[%d] = %x, addr_mask=%x", addr, i, rdata[i], addr_mask), UVM_LOW)
    end
   /* rresp =  (m_iordonce_seq<%=ncidx%>.m_seq_item.m_has_data) ? m_iordonce_seq<%=ncidx%>.m_seq_item.m_read_data_pkt.rresp : 0;
    if(rresp) begin
        `uvm_error("READ_IOAIU",$sformatf("Resp_err :0x%0h on Read Data",rresp))
    end */

//todo

endtask : read_ioaiu_rdonce<%=ncidx%>
`else //`ifdef USE_VIP_SNPS
task concerto_fullsys_direct_wr_rd_legacy_test::read_ioaiu_rdonce<%=ncidx%>(input ioaiu<%=ncidx%>_axi_agent_pkg::axi_axaddr_t addr, 
                                                 int len,
                                                 int size,
                                                 output bit[1023:0] data);
    ioaiu<%=ncidx%>_inhouse_axi_bfm_pkg::axi_rdonce_seq m_iordonce_seq<%=ncidx%>[<%=aiu_NumCores[idx]%>];
    bit [ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA-1:0] rdata[4];  // Up to 4 transfers
    ioaiu<%=ncidx%>_axi_agent_pkg::axi_rresp_t rresp[<%=aiu_NumCores[idx]%>];
    int addr_mask;
    int addr_offset;
    int num_bits, starting_bit;
										
    addr_mask = (ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA/8)-1;
    addr_offset = addr & addr_mask;
    <% for(let i=0; i<aiu_NumCores[idx]; i++) { %> 
    m_iordonce_seq<%=ncidx%>[<%=i%>]   = ioaiu<%=ncidx%>_inhouse_axi_bfm_pkg::axi_rdonce_seq::type_id::create("m_iordonce_seq<%=ncidx%>[<%=i%>]");

    m_iordonce_seq<%=ncidx%>[<%=i%>].m_addr = addr;
    m_iordonce_seq<%=ncidx%>[<%=i%>].m_len = len;
    m_iordonce_seq<%=ncidx%>[<%=i%>].m_size = size;
    m_iordonce_seq<%=ncidx%>[<%=i%>].use_arid = 0;
    m_iordonce_seq<%=ncidx%>[<%=i%>].start(m_ioaiu_vseqr<%=ncidx%>[<%=i%>]);
   <% } %>
    for (int i=0; i < len+1; i++) begin
       <% for(let i=0; i<aiu_NumCores[idx]; i++) { %> 
      rdata[i] = (m_iordonce_seq<%=ncidx%>[<%=i%>].m_seq_item.m_has_data) ? m_iordonce_seq<%=ncidx%>[<%=i%>].m_seq_item.m_read_data_pkt.rdata[i] : 0;
       <% } %>
      // data[i] = rdata[(addr_offset*8)+:32];
      num_bits = 2 ** size;
      starting_bit = i * num_bits * 8;
      data[starting_bit+:ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA] = rdata[i];
      
    //   `uvm_info("VS", $sformatf("IOAIU<%=ncidx%> Read Addr = %x, rdata[%d] = %x, addr_mask=%x", addr, i, rdata[i], addr_mask), UVM_LOW)
    end
    <% for(let i=0; i<aiu_NumCores[idx]; i++) { %> 
    rresp[<%=i%>] =  (m_iordonce_seq<%=ncidx%>[<%=i%>].m_seq_item.m_has_data) ? m_iordonce_seq<%=ncidx%>[<%=i%>].m_seq_item.m_read_data_pkt.rresp : 0;
    
    if(rresp[<%=i%>]) begin
        `uvm_error("READ_IOAIU",$sformatf("Resp_err :0x%0h on Read Data",rresp[<%=i%>]))
    end
    <% } %>
endtask : read_ioaiu_rdonce<%=ncidx%>
`endif //`ifdef USE_VIP_SNPS ... `else

     <% ncidx++;
    }
  } %>

task concerto_fullsys_direct_wr_rd_legacy_test::directed_read_test(integer proc_num, uvm_phase phase);
   `uvm_info("VS", "Directed Read Test", UVM_LOW)
 `ifndef USE_VIP_SNPS //existing flow will not run when USE_VIP_SNPS set
                case(proc_num)
  <% for(idx = 0, cidx=0, ncidx=0; idx < obj.nAIUs; idx++) { 
    if((obj.AiuInfo[idx].fnNativeInterface.match('CHI'))) { %>
                <%=idx%>: begin 
    `ifndef USE_VIP_SNPS //existing flow will not run when USE_VIP_SNPS set
                   `uvm_info("FULLSYS_TEST", "Start read on processor<%=idx%> : CHIAIU<%=cidx%>", UVM_NONE)
                    if ($test$plusargs("k_directed_test_all_coh")) begin
                       m_chi<%=cidx%>_read_args.k_coh_addr_pct.set_value(100);
                    end
                    else begin
                       m_chi<%=cidx%>_read_args.k_coh_addr_pct.set_value(k_directed_test_coh_addr_pct);
                    end

                    if ($test$plusargs("k_directed_test_all_non_coh")) begin
                       m_chi<%=cidx%>_read_args.k_noncoh_addr_pct.set_value(100);
                    end
                    else begin
                       m_chi<%=cidx%>_read_args.k_noncoh_addr_pct.set_value(k_directed_test_noncoh_addr_pct);
                    end
                    m_chi<%=cidx%>_read_args.k_new_addr_pct.set_value(100);
                    m_chi<%=cidx%>_read_args.k_device_type_mem_pct.set_value(0);

                    if ($test$plusargs("k_directed_test_all_non_coh")) begin
                       m_chi<%=cidx%>_read_args.k_rd_noncoh_pct.set_value(100);
                    end
                    else begin
                       m_chi<%=cidx%>_read_args.k_rd_noncoh_pct.set_value(k_directed_test_noncoh_addr_pct);
                    end

                    m_chi<%=cidx%>_read_args.k_rd_ldrstr_pct.set_value(0);

                    if ($test$plusargs("k_directed_test_all_coh")) begin
                       m_chi<%=cidx%>_read_args.k_rd_rdonce_pct.set_value(100);
                    end
                    else begin
                       m_chi<%=cidx%>_read_args.k_rd_rdonce_pct.set_value(k_directed_test_coh_addr_pct);
                    end

                    m_chi<%=cidx%>_read_args.k_wr_noncoh_pct.set_value(0);
                    m_chi<%=cidx%>_read_args.k_wr_cohunq_pct.set_value(0);
                    m_chi<%=cidx%>_read_args.k_wr_cpybck_pct.set_value(0);
                    m_chi<%=cidx%>_read_args.k_dt_ls_upd_pct.set_value(0);
                    m_chi<%=cidx%>_read_args.k_dt_ls_cmo_pct.set_value(0);
                    m_chi<%=cidx%>_read_args.k_pre_fetch_pct.set_value(0);
                    m_chi<%=cidx%>_read_args.k_dt_ls_sth_pct.set_value(0);
                    m_chi<%=cidx%>_read_args.k_wr_sthunq_pct.set_value(0);
                    m_chi<%=cidx%>_read_args.k_atomic_st_pct.set_value(0);
                    m_chi<%=cidx%>_read_args.k_atomic_ld_pct.set_value(0);
                    m_chi<%=cidx%>_read_args.k_atomic_sw_pct.set_value(0);
                    m_chi<%=cidx%>_read_args.k_atomic_cm_pct.set_value(0);
                    m_chi<%=cidx%>_read_args.k_dvm_opert_pct.set_value(0);
                    m_chi<%=cidx%>_read_vseq.set_unit_args(m_chi<%=cidx%>_read_args);
                    m_chi<%=cidx%>_read_vseq.k_directed_test_alloc = 1;
                    fork
                    begin
                        phase.raise_objection(this, "CHIAIU<%=cidx%> sequence");
                         m_chi<%=cidx%>_read_vseq.start(null);
                        `uvm_info("FULLSYS_TEST", "Done read on processor<%=idx%> : CHIAIU<%=cidx%>", UVM_NONE)
                        //#5us;
                        phase.drop_objection(this, "CHIAIU<%=cidx%> sequence");
                    end
                    begin
                         ev_chi<%=cidx%>_read_seq_done.wait_trigger();
                         ev_sim_done.trigger(null);
                    end
                    join
    `endif //`ifndef USE_VIP_SNPS
                   end
     <% cidx++;
    } else { %>
                <%=idx%>: begin 
                   `uvm_info("FULLSYS_TEST", "Start read on processor<%=idx%> : IOAIU<%=ncidx%>", UVM_NONE)
                   <% for(let i=0; i<aiu_NumCores[idx]; i++) { %>
                   fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_read_seq<%=ncidx%>[<%=i%>].m_ace_cache_model.user_addrq_idx[ncoreConfigInfo::COH] = 0;
                   fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_read_seq<%=ncidx%>[<%=i%>].k_num_read_req        = ioaiu_num_trans;
                   fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_read_seq<%=ncidx%>[<%=i%>].k_num_write_req       = 0;
                   fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_read_seq<%=ncidx%>[<%=i%>].k_directed_test_alloc = 1;
                   
        <% if((obj.AiuInfo[idx].fnNativeInterface == 'ACE') || (obj.AiuInfo[idx].fnNativeInterface == 'ACE-LITE') || (obj.AiuInfo[idx].fnNativeInterface == 'ACELITE-E')) { %>
                   fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_read_seq<%=ncidx%>[<%=i%>].wt_ace_rdnosnp      = 0;
                   if ($test$plusargs("k_directed_test_all_coh")) begin
                      fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_read_seq<%=ncidx%>[<%=i%>].wt_ace_rdonce       = 100;
                   end
                   else begin
                      fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_read_seq<%=ncidx%>[<%=i%>].wt_ace_rdonce = k_directed_test_coh_addr_pct;
                   end
                   fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_read_seq<%=ncidx%>[<%=i%>].wt_ace_wrnosnp      = 0;
                   fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_read_seq<%=ncidx%>[<%=i%>].wt_ace_wrunq        = 0;
                   fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_read_seq<%=ncidx%>[<%=i%>].wt_ace_wrlnunq      = 0;
          <% if(obj.AiuInfo[idx].fnNativeInterface == 'ACE') { %>
                   fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_read_seq<%=ncidx%>[<%=i%>].wt_ace_rdshrd       = 0;
                   fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_read_seq<%=ncidx%>[<%=i%>].wt_ace_rdcln        = 0;
                   fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_read_seq<%=ncidx%>[<%=i%>].wt_ace_rdnotshrddty = 0;
                   fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_read_seq<%=ncidx%>[<%=i%>].wt_ace_rdunq        = 0;
                   fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_read_seq<%=ncidx%>[<%=i%>].wt_ace_wrcln        = 0;
                   fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_read_seq<%=ncidx%>[<%=i%>].wt_ace_wrbk         = 0;
                   fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_read_seq<%=ncidx%>[<%=i%>].wt_ace_wrevct       = 0;
                   fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_read_seq<%=ncidx%>[<%=i%>].wt_ace_dvm_msg      = 0;
                   fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_read_seq<%=ncidx%>[<%=i%>].wt_ace_dvm_sync     = 0;
          <% } %>
                   fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_read_seq<%=ncidx%>[<%=i%>].wt_ace_clnunq       = 0;
                   fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_read_seq<%=ncidx%>[<%=i%>].wt_ace_clnshrd      = 0;
                   fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_read_seq<%=ncidx%>[<%=i%>].wt_ace_clninvl      = 0;
                   fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_read_seq<%=ncidx%>[<%=i%>].wt_ace_mkunq        = 0;
                   fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_read_seq<%=ncidx%>[<%=i%>].wt_ace_mkinvl       = 0;
                   fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_read_seq<%=ncidx%>[<%=i%>].wt_ace_evct         = 0;
                   fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_read_seq<%=ncidx%>[<%=i%>].no_updates          = 0;
                   fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_read_seq<%=ncidx%>[<%=i%>].wt_ace_rd_bar       = 0;
                   fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_read_seq<%=ncidx%>[<%=i%>].wt_ace_wr_bar       = 0;
          <% if(obj.AiuInfo[idx].fnNativeInterface != 'ACE-LITE') { %>
                   fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_read_seq<%=ncidx%>[<%=i%>].wt_ace_atm_str      = 0;
                   fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_read_seq<%=ncidx%>[<%=i%>].wt_ace_atm_ld       = 0;
                   fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_read_seq<%=ncidx%>[<%=i%>].wt_ace_atm_swap     = 0;
                   fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_read_seq<%=ncidx%>[<%=i%>].wt_ace_atm_comp     = 0;
                   fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_read_seq<%=ncidx%>[<%=i%>].wt_ace_ptl_stash    = 0;
                   fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_read_seq<%=ncidx%>[<%=i%>].wt_ace_full_stash   = 0;
                   fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_read_seq<%=ncidx%>[<%=i%>].wt_ace_shared_stash = 0;
                   fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_read_seq<%=ncidx%>[<%=i%>].wt_ace_unq_stash    = 0;
                   fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_read_seq<%=ncidx%>[<%=i%>].wt_ace_stash_trans  = 0;
          <% } %>
      <% }%>
      <% } %>
                   fork
                       <% for(let i=0; i<aiu_NumCores[idx]; i++) { %>
                   begin
                       phase.raise_objection(this, "IOAIU<%=ncidx%>[<%=i%>] sequence");
                       fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_read_seq<%=ncidx%>[<%=i%>].start(null);
                       `uvm_info("FULLSYS_TEST", "Done read on processor<%=idx%> : IOAIU<%=ncidx%>[<%=i%>]", UVM_NONE)
                       //#1us;
                       phase.drop_objection(this, "IOAIU<%=ncidx%>[<%=i%>] sequence");
                   end
                   begin
                       ev_ioaiu<%=ncidx%>_read_seq_done[<%=i%>].wait_trigger();
                       ev_sim_done.trigger(null);
                   end
                       <% } //foreach core%>
                   join
                   end
     <% ncidx++;
    }
  } %>
                endcase
`endif //`ifndef USE_VIP_SNPS
endtask : directed_read_test

task concerto_fullsys_direct_wr_rd_legacy_test::directed_test_addr();
                bit [ncoreConfigInfo::W_SEC_ADDR-1:0] addr;
                bit [<%=obj.DmiInfo[0].ccpParams.PriSubDiagAddrBits.length-1%> : 0] pri_bits_val;
                string task_message="";
                `uvm_info("VS", "Generate Direct Addresses", UVM_LOW)
                if(!$test$plusargs("k_directed_wr_rd_all_chiaius_to_all_targets_noncoh") && !$test$plusargs("k_directed_wr_rd_all_chiaius_to_all_targets_coh")) begin
                    // Get the address used in write to use in read ??
                    addr_mgr.gen_user_noncoh_addr(<%=obj.DmiInfo[0].FUnitId%>, <%=obj.DmiInfo[0].ccpParams.nSets%>, ncoreConfigInfo::user_addrq[ncoreConfigInfo::NONCOH]);
                    if (!$test$plusargs("all_gpra_ncmode"))addr_mgr.gen_user_coh_addr(<%=obj.DmiInfo[0].FUnitId%>, <%=obj.DmiInfo[0].ccpParams.nSets%>, ncoreConfigInfo::user_addrq[ncoreConfigInfo::COH]);
                    for(int i=0; i< <%=obj.DmiInfo[0].ccpParams.nSets%>; i++) begin
                        addr = ncoreConfigInfo::user_addrq[ncoreConfigInfo::NONCOH][i];
                        pri_bits_val = i;
  <% for(idx    =0; idx<obj.DmiInfo[0].ccpParams.PriSubDiagAddrBits.length;idx++){%> 
                            addr[<%=obj.DmiInfo[0].ccpParams.PriSubDiagAddrBits[idx]%>] = pri_bits_val[<%=idx%>];
  <% } %>
                            addr[5:0] = k_directed_64B_aligned ? 6'b0 : addr[5:0];
                        //`uvm_info("ADDR DEBUG",$sformatf("NC[19:10] %0d [18:8] %0d, Addr %0h i =%0d ",addr[19:10],addr[18:8],addr,i),UVM_NONE)
                        ncoreConfigInfo::user_addrq[ncoreConfigInfo::NONCOH][i] = addr;
                    end
                    for(int i=0; i< <%=obj.DmiInfo[0].ccpParams.nSets%>; i++) begin
                        addr = ncoreConfigInfo::user_addrq[ncoreConfigInfo::COH][i];
                        pri_bits_val = i;
  <% for(idx    =0; idx<obj.DmiInfo[0].ccpParams.PriSubDiagAddrBits.length;idx++){%> 
                            addr[<%=obj.DmiInfo[0].ccpParams.PriSubDiagAddrBits[idx]%>] = pri_bits_val[<%=idx%>];
  <% } %>
                            addr[5:0] = k_directed_64B_aligned ? 6'b0 : addr[5:0];
                        //`uvm_info("ADDR DEBUG",$sformatf("C [19:10] %0d [18:8] %0d, Addr %0h i =%0d ",addr[19:10],addr[18:8],addr,i),UVM_NONE)
                        ncoreConfigInfo::user_addrq[ncoreConfigInfo::COH][i] = addr;
                    end
                end // if(!$test$plusargs("k_directed_wr_rd_all_chiaius_to_all_targets_noncoh")) begin
                else begin
	       <% for(pidx=0, cidx=0; pidx<obj.nAIUs; pidx++) {
               if((obj.AiuInfo[pidx].fnNativeInterface.match('CHI'))) { %>
`ifndef USE_VIP_SNPS //existing flow will not run when USE_VIP_SNPS set
                    foreach(m_chi0_vseq.all_dmi_start_addr[<%=obj.AiuInfo[pidx].rpn%>][y]) begin
                        task_message = $psprintf("DMI[%0d][%0d] %0s",task_message,<%=obj.AiuInfo[pidx].rpn%>,y, m_chi0_vseq.all_dmi_start_addr[<%=obj.AiuInfo[pidx].rpn%>][y]);
                    end
                    `uvm_info("VS", $psprintf("Generated Direct Addresses AIU-RPN %0d to DMI %0s",<%=obj.AiuInfo[pidx].rpn%>,task_message),UVM_NONE)

                    task_message = "";
                    foreach(m_chi0_vseq.all_dii_start_addr[<%=obj.AiuInfo[pidx].rpn%>][y]) begin
                        task_message = $psprintf("DII[%0d][%0d] %0s",task_message,<%=obj.AiuInfo[pidx].rpn%>,y, m_chi0_vseq.all_dii_start_addr[<%=obj.AiuInfo[pidx].rpn%>][y]);
                    end
                    `uvm_info("VS", $psprintf("Generated Direct Addresses AIU-RPN %0d to DII %0s",<%=obj.AiuInfo[pidx].rpn%>,task_message),UVM_NONE)

                    task_message = "";
                    foreach(m_chi0_vseq.all_dmi_dii_start_addr[<%=obj.AiuInfo[pidx].rpn%>][y]) begin
                        task_message = $psprintf("DII[%0d][%0d] %0s",task_message,<%=obj.AiuInfo[pidx].rpn%>,y, m_chi0_vseq.all_dmi_dii_start_addr[<%=obj.AiuInfo[pidx].rpn%>][y]);
                    end
                    `uvm_info("VS", $psprintf("Generated Direct Addresses AIU-RPN %0d to ALL DMI & DII %0s",<%=obj.AiuInfo[pidx].rpn%>,task_message), UVM_NONE)
                <% cidx++; %>
`endif
               <% } } %>
                end
/*
	       <% chi_idx=0;
	       io_idx=0;
	       for(pidx=0; pidx<obj.nAIUs; pidx++) {
               if((obj.AiuInfo[pidx].fnNativeInterface.match('CHI'))) { %>
               m_chi<%=chi_idx%>_vseq.m_chi_container.user_addrq[ncoreConfigInfo::NONCOH] = ncoreConfigInfo::user_addrq[ncoreConfigInfo::NONCOH];
               m_chi<%=chi_idx%>_read_vseq.m_chi_container.user_addrq[ncoreConfigInfo::NONCOH] = ncoreConfigInfo::user_addrq[ncoreConfigInfo::NONCOH];
               m_chi<%=chi_idx%>_vseq.m_chi_container.user_addrq[ncoreConfigInfo::COH] = ncoreConfigInfo::user_addrq[ncoreConfigInfo::COH];
               m_chi<%=chi_idx%>_read_vseq.m_chi_container.user_addrq[ncoreConfigInfo::COH] = ncoreConfigInfo::user_addrq[ncoreConfigInfo::COH];
	       <% chi_idx++;
               } else { %>
               m_concerto_env.inhouse.m_ace_cache_model_ioaiu<%=io_idx%>.user_addrq[ncoreConfigInfo::NONCOH] = ncoreConfigInfo::user_addrq[ncoreConfigInfo::NONCOH];
               m_concerto_env.inhouse.m_ace_cache_model_ioaiu<%=io_idx%>.user_addrq[ncoreConfigInfo::COH] = ncoreConfigInfo::user_addrq[ncoreConfigInfo::COH];

               m_iocache_seq<%=io_idx%>.m_ace_cache_model.user_addrq[ncoreConfigInfo::NONCOH] = ncoreConfigInfo::user_addrq[ncoreConfigInfo::NONCOH];
               m_iocache_seq<%=io_idx%>.m_ace_cache_model.user_addrq[ncoreConfigInfo::COH] = ncoreConfigInfo::user_addrq[ncoreConfigInfo::COH];

               m_iocache_read_seq<%=io_idx%>.m_ace_cache_model.user_addrq[ncoreConfigInfo::NONCOH] = ncoreConfigInfo::user_addrq[ncoreConfigInfo::NONCOH];
               m_iocache_read_seq<%=io_idx%>.m_ace_cache_model.user_addrq[ncoreConfigInfo::COH] = ncoreConfigInfo::user_addrq[ncoreConfigInfo::COH];

	       <% io_idx++; } 
               } %>
*/

endtask : directed_test_addr
task concerto_fullsys_direct_wr_rd_legacy_test::directed_write_read_test(integer proc_num, uvm_phase phase);
   bit [511:0] data_in, data_in_1;
   bit [511:0] data_out, data_out_1;
   int data_size;
   `ifdef USE_VIP_SNPS
   bit [ncoreConfigInfo::W_SEC_ADDR-1:0] temp_addr , temp_addr_coh;
   `endif // `ifdef USE_VIP_SNPS
   int wData;
   `uvm_info("VS", "Directed Write/ Read Test", UVM_LOW)
   //`ifndef USE_VIP_SNPS //existing flow will not run when USE_VIP_SNPS set
                case(proc_num)
  <% for(idx = 0, cidx=0, ncidx=0; idx < obj.nAIUs; idx++) { 
               if((obj.AiuInfo[idx].fnNativeInterface.match('CHI'))) { %>
                <%=idx%>: begin 
     `ifndef USE_VIP_SNPS //existing flow will not run when USE_VIP_SNPS set
                   `uvm_info("FULLSYS_TEST", "Start write/read on processor<%=idx%> : CHIAIU<%=cidx%>", UVM_NONE)

                    <% if (obj.AiuInfo[idx].wData == 128) { %>
                        wData = 128;
                    <% } else if (obj.AiuInfo[idx].wData == 256) { %> 
                         wData = 256;
                    <% } else { %>
                         wData = 512;
                    <% } %>
                    `uvm_info("VS", $sformatf("wData<%=cidx%> = %d", wData), UVM_LOW)

                    if ($test$plusargs("k_directed_test_all_coh")) begin
                       m_chi<%=cidx%>_args.k_coh_addr_pct.set_value(100);
                    end
                    else begin
                       m_chi<%=cidx%>_args.k_coh_addr_pct.set_value(k_directed_test_coh_addr_pct);
                    end

                    if ($test$plusargs("k_directed_test_all_non_coh")) begin
                       m_chi<%=cidx%>_args.k_noncoh_addr_pct.set_value(100);
                    end 
                    else begin
                       m_chi<%=cidx%>_args.k_noncoh_addr_pct.set_value(k_directed_test_noncoh_addr_pct);
                    end
                    // m_chi<%=cidx%>_args.k_new_addr_pct.set_value(100);
                    m_chi<%=cidx%>_args.k_rd_noncoh_pct.set_value(0);
                    m_chi<%=cidx%>_args.k_rd_ldrstr_pct.set_value(0);
                    m_chi<%=cidx%>_args.k_rd_rdonce_pct.set_value(0);
                    if ($test$plusargs("k_directed_test_all_non_coh")) begin
                        m_chi<%=cidx%>_args.k_wr_noncoh_pct.set_value(100);
                        m_chi<%=cidx%>_args.k_rd_noncoh_pct.set_value(0);
                    end
                    else begin
                        m_chi<%=cidx%>_args.k_wr_noncoh_pct.set_value(k_directed_test_noncoh_addr_pct);
                    end
                    if ($test$plusargs("k_directed_test_all_coh")) begin
                        m_chi<%=cidx%>_args.k_wr_cohunq_pct.set_value(100);
                    end
                    else begin
                        m_chi<%=cidx%>_args.k_wr_cohunq_pct.set_value(k_directed_test_coh_addr_pct);
                    end
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
                    if ($test$plusargs("k_directed_test_all_non_coh")) begin
                     for (int j = 1; j < 7; j++) begin
                          for (int i = 0; i < chi_num_trans; i++) begin
                             m_chi<%=cidx%>_args.k_wr_noncoh_pct.set_value(100);
                             m_chi<%=cidx%>_args.k_rd_noncoh_pct.set_value(0);
                             m_chi<%=cidx%>_vseq.set_unit_args(m_chi<%=cidx%>_args);
                             assert(std::randomize(data_out));
                             data_size = j;  // 2,4,8,16,32,64 bytes
                             `uvm_info("VS", $sformatf("CHI<%=cidx%> Write Address = %x,size = %d, Write Data = %x", ncoreConfigInfo::user_addrq[ncoreConfigInfo::NONCOH][i], data_size, data_out), UVM_LOW) 
                             m_chi<%=cidx%>_vseq.write_memory(ncoreConfigInfo::user_addrq[ncoreConfigInfo::NONCOH][i], data_out, data_size);

                             m_chi<%=cidx%>_args.k_wr_noncoh_pct.set_value(0);
                             m_chi<%=cidx%>_args.k_rd_noncoh_pct.set_value(100);
                             m_chi<%=cidx%>_vseq.set_unit_args(m_chi<%=cidx%>_args);

                             m_chi<%=cidx%>_vseq.read_memory(ncoreConfigInfo::user_addrq[ncoreConfigInfo::NONCOH][i], data_in, data_size, wData);
                             `uvm_info("VS", $sformatf("CHI<%=cidx%> Read Address = %x,size = %d,  Read Data = %x", ncoreConfigInfo::user_addrq[ncoreConfigInfo::NONCOH][i], data_size,data_in), UVM_LOW)

                             case (data_size)
                                1: begin
                                    if (data_out[15:0] != data_in[15:0]) begin
                                      `uvm_error("VS", $sformatf("Data Mismatch CHI<%=cidx%>. Address = %x, xfer size 2B, Write Data = %x, Read Data = %x", ncoreConfigInfo::user_addrq[ncoreConfigInfo::NONCOH][i], data_out[15:0], data_in[15:0]))
                                    end
                                   end
                                2: begin
                                    if (data_out[31:0] != data_in[31:0]) begin
                                      `uvm_error("VS", $sformatf("Data Mismatch CHI<%=cidx%>. Address = %x, xfer size 4B, Write Data = %x, Read Data = %x", ncoreConfigInfo::user_addrq[ncoreConfigInfo::NONCOH][i], data_out[31:0], data_in[31:0]))
                                    end
                                   end
                                3: begin
                                    if (data_out[63:0] != data_in[63:0]) begin
                                      `uvm_error("VS", $sformatf("Data Mismatch CHI<%=cidx%>. Address = %x, xfer size 8B, Write Data = %x, Read Data = %x", ncoreConfigInfo::user_addrq[ncoreConfigInfo::NONCOH][i], data_out[63:0], data_in[63:0]))
                                    end
                                   end
                                4: begin
                                    if (data_out[127:0] != data_in[127:0]) begin
                                      `uvm_error("VS", $sformatf("Data Mismatch CHI<%=cidx%>. Address = %x, xfer size 16B, Write Data = %x, Read Data = %x", ncoreConfigInfo::user_addrq[ncoreConfigInfo::NONCOH][i], data_out[127:0], data_in[127:0]))
                                    end
                                   end
                                5: begin
                                    if (data_out[255:0] != data_in[255:0]) begin
                                      `uvm_error("VS", $sformatf("Data Mismatch CHI<%=cidx%>. Address = %x, xfer size 32B, Write Data = %x, Read Data = %x", ncoreConfigInfo::user_addrq[ncoreConfigInfo::NONCOH][i], data_out[255:0], data_in[255:0]))
                                    end
                                   end
                                6: begin
                                    if (data_out[511:0] != data_in[511:0]) begin
                                      `uvm_error("VS", $sformatf("Data Mismatch CHI<%=cidx%>. Address = %x, xfer size 64B, Write Data = %x, Read Data = %x", ncoreConfigInfo::user_addrq[ncoreConfigInfo::NONCOH][i], data_out[511:0], data_in[511:0]))
                                    end
                                   end
                                default: begin
                                    `uvm_error("VS", $sformatf("Unsupported data size [CHI<%=cidx%>]%d", data_size))
                                   end
                              endcase
                          end   //for i
                      end // for j
                    end  // k_directed_test_all_non_coh 

                    if ($test$plusargs("k_directed_test_all_coh")) begin
                     for (int j = 6; j < 7; j++) begin  // need cacheline
                          for (int i = 0; i < chi_num_trans; i++) begin
                             m_chi<%=cidx%>_args.k_wr_cohunq_pct.set_value(100);
                             m_chi<%=cidx%>_args.k_rd_rdonce_pct.set_value(0);
                             m_chi<%=cidx%>_vseq.set_unit_args(m_chi<%=cidx%>_args);
                             assert(std::randomize(data_out));
                             data_size = j;  // 2,4,8,16,32,64 bytes
                             `uvm_info("VS", $sformatf("CHI<%=cidx%> Write Address = %x,size = %d, Write Data = %x", ncoreConfigInfo::user_addrq[ncoreConfigInfo::COH][i], data_size, data_out), UVM_LOW) 
                             m_chi<%=cidx%>_vseq.write_memory_coh(ncoreConfigInfo::user_addrq[ncoreConfigInfo::COH][i], data_out, data_size);

                             m_chi<%=cidx%>_args.k_wr_cohunq_pct.set_value(0);
                             m_chi<%=cidx%>_args.k_rd_rdonce_pct.set_value(100);
                             m_chi<%=cidx%>_vseq.set_unit_args(m_chi<%=cidx%>_args);

                              m_chi<%=cidx%>_vseq.read_memory_coh(ncoreConfigInfo::user_addrq[ncoreConfigInfo::COH][i], data_in, data_size, wData);
                             `uvm_info("VS", $sformatf("CHI<%=cidx%> Read Address = %x,size = %d,  Read Data = %x", ncoreConfigInfo::user_addrq[ncoreConfigInfo::COH][i], data_size,data_in), UVM_LOW)

                             case (data_size)
                                1: begin
                                    if (data_out[15:0] != data_in[15:0]) begin
                                      `uvm_error("VS", $sformatf("Data Mismatch CHI<%=cidx%>. Address = %x, xfer size 2B, Write Data = %x, Read Data = %x", ncoreConfigInfo::user_addrq[ncoreConfigInfo::COH][i], data_out[15:0], data_in[15:0]))
                                    end
                                   end
                                2: begin
                                    if (data_out[31:0] != data_in[31:0]) begin
                                      `uvm_error("VS", $sformatf("Data Mismatch CHI<%=cidx%>. Address = %x, xfer size 4B, Write Data = %x, Read Data = %x", ncoreConfigInfo::user_addrq[ncoreConfigInfo::COH][i], data_out[31:0], data_in[31:0]))
                                    end
                                   end
                                3: begin
                                    if (data_out[63:0] != data_in[63:0]) begin
                                      `uvm_error("VS", $sformatf("Data Mismatch CHI<%=cidx%>. Address = %x, xfer size 8B, Write Data = %x, Read Data = %x", ncoreConfigInfo::user_addrq[ncoreConfigInfo::COH][i], data_out[63:0], data_in[63:0]))
                                    end
                                   end
                                4: begin
                                    if (data_out[127:0] != data_in[127:0]) begin
                                      `uvm_error("VS", $sformatf("Data Mismatch CHI<%=cidx%>. Address = %x, xfer size 16B, Write Data = %x, Read Data = %x", ncoreConfigInfo::user_addrq[ncoreConfigInfo::COH][i], data_out[127:0], data_in[127:0]))
                                    end
                                   end
                                5: begin
                                    if (data_out[255:0] != data_in[255:0]) begin
                                      `uvm_error("VS", $sformatf("Data Mismatch CHI<%=cidx%>. Address = %x, xfer size 32B, Write Data = %x, Read Data = %x", ncoreConfigInfo::user_addrq[ncoreConfigInfo::COH][i], data_out[255:0], data_in[255:0]))
                                    end
                                   end
                                6: begin
                                    if (data_out[511:0] != data_in[511:0]) begin
                                      `uvm_info("VS", $sformatf("Data Mismatch CHI<%=cidx%>. Address = %x, xfer size 64B, Write Data = %x, Read Data = %x", ncoreConfigInfo::user_addrq[ncoreConfigInfo::COH][i], data_out[511:0], data_in[511:0]), UVM_LOW)
                                    end
                                   end
                                default: begin
                                    `uvm_error("VS", $sformatf("Unsupported data size [CHI<%=cidx%>]%d", data_size))
                                   end
                              endcase
                          end   //for i
                      end // for j
                    end  // k_directed_test_all_coh 

                    if ((k_directed_test_noncoh_addr_pct != 0) && (k_directed_test_coh_addr_pct != 0)) begin  // both non-coherent and coherent
                       for (int i = 0; i < chi_num_trans; i++) begin
                          m_chi<%=cidx%>_args.k_wr_noncoh_pct.set_value(k_directed_test_noncoh_addr_pct);
                          m_chi<%=cidx%>_args.k_rd_noncoh_pct.set_value(0);

                          m_chi<%=cidx%>_args.k_wr_cohunq_pct.set_value(k_directed_test_coh_addr_pct);
                          m_chi<%=cidx%>_args.k_rd_rdonce_pct.set_value(0);
                          m_chi<%=cidx%>_vseq.set_unit_args(m_chi<%=cidx%>_args);
                          assert(std::randomize(data_out));
                          assert(std::randomize(data_out_1));
                          data_size = 6;  // 64 bytes
                           `uvm_info("VS", $sformatf("CHI<%=cidx%> Non-coherent Write Address = %x,size = %d, Write Data = %x", ncoreConfigInfo::user_addrq[ncoreConfigInfo::NONCOH][i], data_size, data_out), UVM_LOW) 
                          `uvm_info("VS", $sformatf("CHI<%=cidx%> Coherent Write Address = %x,size = %d, Write Data = %x", ncoreConfigInfo::user_addrq[ncoreConfigInfo::COH][i], data_size, data_out_1), UVM_LOW) 
                           m_chi<%=cidx%>_vseq.write_memory(ncoreConfigInfo::user_addrq[ncoreConfigInfo::NONCOH][i], data_out, data_size);
                           m_chi<%=cidx%>_vseq.write_memory_coh(ncoreConfigInfo::user_addrq[ncoreConfigInfo::COH][i], data_out_1, data_size);

                           m_chi<%=cidx%>_args.k_wr_noncoh_pct.set_value(0);
                           m_chi<%=cidx%>_args.k_rd_noncoh_pct.set_value(k_directed_test_noncoh_addr_pct);

                           m_chi<%=cidx%>_args.k_wr_cohunq_pct.set_value(0);
                           m_chi<%=cidx%>_args.k_rd_rdonce_pct.set_value(k_directed_test_coh_addr_pct);
                           m_chi<%=cidx%>_vseq.set_unit_args(m_chi<%=cidx%>_args);

                           m_chi<%=cidx%>_vseq.read_memory(ncoreConfigInfo::user_addrq[ncoreConfigInfo::NONCOH][i], data_in, data_size, wData);
                           m_chi<%=cidx%>_vseq.read_memory_coh(ncoreConfigInfo::user_addrq[ncoreConfigInfo::COH][i], data_in_1, data_size, wData);
                           `uvm_info("VS", $sformatf("CHI<%=cidx%> Non-coherent Read Address = %x,size = %d,  Read Data = %x", ncoreConfigInfo::user_addrq[ncoreConfigInfo::NONCOH][i], data_size,data_in), UVM_LOW)
                           `uvm_info("VS", $sformatf("CHI<%=cidx%> Coherent Read Address = %x,size = %d,  Read Data = %x", ncoreConfigInfo::user_addrq[ncoreConfigInfo::COH][i], data_size,data_in_1), UVM_LOW)
                            if (data_out[511:0] != data_in[511:0]) begin
                                      `uvm_info("VS", $sformatf("Non-coherent Data Mismatch CHI<%=cidx%>. Address = %x, xfer size 64B, Write Data = %x, Read Data = %x", ncoreConfigInfo::user_addrq[ncoreConfigInfo::NONCOH][i], data_out[511:0], data_in[511:0]), UVM_LOW)
                            end
                            if (data_out_1[511:0] != data_in_1[511:0]) begin
                                      `uvm_info("VS", $sformatf("Coherent Data Mismatch CHI<%=cidx%>. Address = %x, xfer size 64B, Write Data = %x, Read Data = %x", ncoreConfigInfo::user_addrq[ncoreConfigInfo::COH][i], data_out[511:0], data_in[511:0]), UVM_LOW)
                            end
                       end

                    end //k_directed_test_noncoh_addr_pct and k_directed_test_coh_addr_pct

                       `uvm_info("FULLSYS_TEST", "Done write/ read  on processor<%=idx%> : CHIAIU<%=cidx%>", UVM_NONE)
      `else  //existing flow will  run when USE_VIP_SNPS set
                   `uvm_info("FULLSYS_TEST", "Start write/read on processor<%=idx%> : CHIAIU<%=cidx%>", UVM_NONE)

                    <% if (obj.AiuInfo[idx].wData == 128) { %>
                        wData = 128;
                    <% } else if (obj.AiuInfo[idx].wData == 256) { %> 
                         wData = 256;
                    <% } else { %>
                         wData = 512;
                    <% } %>
                    `uvm_info("VS", $sformatf("wData<%=cidx%> = %d", wData), UVM_LOW)

                    if ($test$plusargs("k_directed_test_all_coh")) begin
                       m_chi0_args.k_coh_addr_pct.set_value(100);
                    end
                    else begin
                       m_chi0_args.k_coh_addr_pct.set_value(k_directed_test_coh_addr_pct);
                    end

                    if ($test$plusargs("k_directed_test_all_non_coh")) begin
                       m_chi0_args.k_noncoh_addr_pct.set_value(100);
                    end 
                    else begin
                       m_chi0_args.k_noncoh_addr_pct.set_value(k_directed_test_noncoh_addr_pct);
                    end
                    // m_chi<%=cidx%>_args.k_new_addr_pct.set_value(100);
                    m_chi0_args.k_rd_noncoh_pct.set_value(0);
                    m_chi0_args.k_rd_ldrstr_pct.set_value(0);
                    m_chi0_args.k_rd_rdonce_pct.set_value(0);
                    if ($test$plusargs("k_directed_test_all_non_coh")) begin
                        m_chi0_args.k_wr_noncoh_pct.set_value(100);
                        m_chi0_args.k_rd_noncoh_pct.set_value(100);
                    end
                    else begin
                        m_chi0_args.k_wr_noncoh_pct.set_value(k_directed_test_noncoh_addr_pct);
                        m_chi0_args.k_rd_noncoh_pct.set_value(k_directed_test_noncoh_addr_pct);
                    end
                    if ($test$plusargs("k_directed_test_all_coh")) begin
                        m_chi0_args.k_wr_cohunq_pct.set_value(100);
                        m_chi0_args.k_rd_rdonce_pct.set_value(100);
                    end
                    else begin
                        m_chi0_args.k_wr_cohunq_pct.set_value(k_directed_test_coh_addr_pct);
                        m_chi0_args.k_rd_rdonce_pct.set_value(k_directed_test_coh_addr_pct);
                    end
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
                   // m_chi<%=cidx%>_vseq.set_unit_args(m_chi<%=cidx%>_args);//need to add
                    <% if(numChiAiu > 0) { %>
                     m_svt_chi_item.m_args = m_chi0_args;
                    <% } %>
                    m_snps_chi<%=cidx%>_vseq.set_unit_args(m_chi0_args);
                    m_snps_chi<%=cidx%>_vseq.k_directed_test_alloc = 1; //need to add
                    if ($test$plusargs("k_directed_test_all_non_coh")) begin
                     for (int j = 1; j < 7; j++) begin
                          for (int i = 0; i < chi_num_trans; i++) begin
                             //m_chi0_args.k_wr_noncoh_pct.set_value(100);
                             //m_chi0_args.k_rd_noncoh_pct.set_value(0);
                             //m_chi0_vseq.set_unit_args(m_chi<%=cidx%>_args); need to add 
                             <% if(numChiAiu > 0) { %>
                              m_svt_chi_item.m_args = m_chi0_args;
                             <% } %>
                             m_snps_chi<%=cidx%>_vseq.set_unit_args(m_chi0_args);

                             assert(std::randomize(data_out));
                             data_size = j;  // 2,4,8,16,32,64 bytes
                             temp_addr=ncoreConfigInfo::user_addrq[ncoreConfigInfo::NONCOH][i];
                             if(temp_addr==0)begin
                              temp_addr=addr_mgr.get_noncoh_addr(<%=obj.AiuInfo[cidx].FUnitId%>, 1);
                              end
                             `uvm_info("VS", $sformatf("CHI<%=cidx%> Write Address = %x,size = %d, Write Data = %x value_i =%0d array=%0p",temp_addr, data_size, data_out,i,ncoreConfigInfo::user_addrq), UVM_LOW) 
                             //`uvm_info("VS", $sformatf("CHI<%=cidx%> Write Address = %x,size = %d, Write Data = %x value_i =%0d array=%0p", ncoreConfigInfo::user_addrq[ncoreConfigInfo::NONCOH][i], data_size, data_out,i,ncoreConfigInfo::user_addrq), UVM_LOW) 
                             m_snps_chi<%=cidx%>_vseq.write_memory(temp_addr, data_out, data_size); // need to add for snps 
                             //m_snps_chi<%=cidx%>_vseq.write_memory(ncoreConfigInfo::user_addrq[ncoreConfigInfo::NONCOH][i], data_out, data_size); // need to add for snps 

                             //m_chi0_args.k_wr_noncoh_pct.set_value(0);
                             //m_chi0_args.k_rd_noncoh_pct.set_value(100);
                             //m_chi0_vseq.set_unit_args(m_chi<%=cidx%>_args);
                             <% if(numChiAiu > 0) { %>
                                 m_svt_chi_item.m_args = m_chi0_args;
                             <% } %>
                             m_snps_chi<%=cidx%>_vseq.set_unit_args(m_chi0_args);


                             m_snps_chi<%=cidx%>_vseq.read_memory(temp_addr, data_in, data_size, wData); //need to add 
                             //m_snps_chi<%=cidx%>_vseq.read_memory(ncoreConfigInfo::user_addrq[ncoreConfigInfo::NONCOH][i], data_in, data_size, wData); //need to add 
                             `uvm_info("VS", $sformatf("CHI<%=cidx%> Read Address = %x,size = %d,  Read Data = %x", ncoreConfigInfo::user_addrq[ncoreConfigInfo::NONCOH][i], data_size,data_in), UVM_LOW)

                             case (data_size)
                                1: begin
                                    if (data_out[15:0] != data_in[15:0]) begin
                                      `uvm_error("VS", $sformatf("Data Mismatch CHI<%=cidx%>. Address = %x, xfer size 2B, Write Data = %x, Read Data = %x", ncoreConfigInfo::user_addrq[ncoreConfigInfo::NONCOH][i], data_out[15:0], data_in[15:0]))
                                    end
                                   end
                                2: begin
                                    if (data_out[31:0] != data_in[31:0]) begin
                                      `uvm_error("VS", $sformatf("Data Mismatch CHI<%=cidx%>. Address = %x, xfer size 4B, Write Data = %x, Read Data = %x", ncoreConfigInfo::user_addrq[ncoreConfigInfo::NONCOH][i], data_out[31:0], data_in[31:0]))
                                    end
                                   end
                                3: begin
                                    if (data_out[63:0] != data_in[63:0]) begin
                                      `uvm_error("VS", $sformatf("Data Mismatch CHI<%=cidx%>. Address = %x, xfer size 8B, Write Data = %x, Read Data = %x", ncoreConfigInfo::user_addrq[ncoreConfigInfo::NONCOH][i], data_out[63:0], data_in[63:0]))
                                    end
                                   end
                                4: begin
                                    if (data_out[127:0] != data_in[127:0]) begin
                                      `uvm_error("VS", $sformatf("Data Mismatch CHI<%=cidx%>. Address = %x, xfer size 16B, Write Data = %x, Read Data = %x", ncoreConfigInfo::user_addrq[ncoreConfigInfo::NONCOH][i], data_out[127:0], data_in[127:0]))
                                    end
                                   end
                                5: begin
                                    if (data_out[255:0] != data_in[255:0]) begin
                                      `uvm_error("VS", $sformatf("Data Mismatch CHI<%=cidx%>. Address = %x, xfer size 32B, Write Data = %x, Read Data = %x", ncoreConfigInfo::user_addrq[ncoreConfigInfo::NONCOH][i], data_out[255:0], data_in[255:0]))
                                    end
                                   end
                                6: begin
                                    if (data_out[511:0] != data_in[511:0]) begin
                                      `uvm_error("VS", $sformatf("Data Mismatch CHI<%=cidx%>. Address = %x, xfer size 64B, Write Data = %x, Read Data = %x", ncoreConfigInfo::user_addrq[ncoreConfigInfo::NONCOH][i], data_out[511:0], data_in[511:0]))
                                    end
                                   end
                                default: begin
                                    `uvm_error("VS", $sformatf("Unsupported data size [CHI<%=cidx%>]%d", data_size))
                                   end
                              endcase
                          end   //for i
                      end // for j
                    end  // k_directed_test_all_non_coh 

                    if ($test$plusargs("k_directed_test_all_coh")) begin
                     for (int j = 6; j < 7; j++) begin  // need cacheline
                          for (int i = 0; i < chi_num_trans; i++) begin
                             //m_chi0_args.k_wr_cohunq_pct.set_value(100);
                             //m_chi0_args.k_rd_rdonce_pct.set_value(0);
                             //m_chi<%=cidx%>_vseq.set_unit_args(m_chi<%=cidx%>_args); //need to add 
                             <% if(numChiAiu > 0) { %>
                                 m_svt_chi_item.m_args = m_chi0_args;
                             <% } %>
                             m_snps_chi<%=cidx%>_vseq.set_unit_args(m_chi0_args);

                             assert(std::randomize(data_out));
                             data_size = j;  // 2,4,8,16,32,64 bytes
                             temp_addr_coh=ncoreConfigInfo::user_addrq[ncoreConfigInfo::COH][i];
                             if(temp_addr_coh==0)begin
                              temp_addr_coh=addr_mgr.get_coh_addr(<%=obj.AiuInfo[cidx].FUnitId%>, 1);
                              end
                             `uvm_info("VS", $sformatf("CHI<%=cidx%> Write Address = %x,size = %d, Write Data = %x array=%0p", ncoreConfigInfo::user_addrq[ncoreConfigInfo::COH][i], data_size, data_out,ncoreConfigInfo::user_addrq), UVM_LOW) 
                             m_snps_chi<%=cidx%>_vseq.write_memory_coh(temp_addr_coh, data_out, data_size); // need to add
                              // m_snps_chi<%=cidx%>_vseq.write_memory_coh(ncoreConfigInfo::user_addrq[ncoreConfigInfo::COH][i], data_out, data_size); // need to add

                             //m_chi0_args.k_wr_cohunq_pct.set_value(0);
                             //m_chi0_args.k_rd_rdonce_pct.set_value(100);
                             //m_chi<%=cidx%>_vseq.set_unit_args(m_chi<%=cidx%>_args); // need to add 
                             <% if(numChiAiu > 0) { %>
                                 m_svt_chi_item.m_args = m_chi0_args;
                             <% } %>
                             m_snps_chi<%=cidx%>_vseq.set_unit_args(m_chi0_args);


                              m_snps_chi<%=cidx%>_vseq.read_memory_coh(temp_addr_coh, data_in, data_size, wData); // need to add 
                              //m_snps_chi<%=cidx%>_vseq.read_memory_coh(ncoreConfigInfo::user_addrq[ncoreConfigInfo::COH][i], data_in, data_size, wData); // need to add 
                             `uvm_info("VS", $sformatf("CHI<%=cidx%> Read Address = %x,size = %d,  Read Data = %x", ncoreConfigInfo::user_addrq[ncoreConfigInfo::COH][i], data_size,data_in), UVM_LOW)

                             case (data_size)
                                1: begin
                                    if (data_out[15:0] != data_in[15:0]) begin
                                      `uvm_error("VS", $sformatf("Data Mismatch CHI<%=cidx%>. Address = %x, xfer size 2B, Write Data = %x, Read Data = %x", ncoreConfigInfo::user_addrq[ncoreConfigInfo::COH][i], data_out[15:0], data_in[15:0]))
                                    end
                                   end
                                2: begin
                                    if (data_out[31:0] != data_in[31:0]) begin
                                      `uvm_error("VS", $sformatf("Data Mismatch CHI<%=cidx%>. Address = %x, xfer size 4B, Write Data = %x, Read Data = %x", ncoreConfigInfo::user_addrq[ncoreConfigInfo::COH][i], data_out[31:0], data_in[31:0]))
                                    end
                                   end
                                3: begin
                                    if (data_out[63:0] != data_in[63:0]) begin
                                      `uvm_error("VS", $sformatf("Data Mismatch CHI<%=cidx%>. Address = %x, xfer size 8B, Write Data = %x, Read Data = %x", ncoreConfigInfo::user_addrq[ncoreConfigInfo::COH][i], data_out[63:0], data_in[63:0]))
                                    end
                                   end
                                4: begin
                                    if (data_out[127:0] != data_in[127:0]) begin
                                      `uvm_error("VS", $sformatf("Data Mismatch CHI<%=cidx%>. Address = %x, xfer size 16B, Write Data = %x, Read Data = %x", ncoreConfigInfo::user_addrq[ncoreConfigInfo::COH][i], data_out[127:0], data_in[127:0]))
                                    end
                                   end
                                5: begin
                                    if (data_out[255:0] != data_in[255:0]) begin
                                      `uvm_error("VS", $sformatf("Data Mismatch CHI<%=cidx%>. Address = %x, xfer size 32B, Write Data = %x, Read Data = %x", ncoreConfigInfo::user_addrq[ncoreConfigInfo::COH][i], data_out[255:0], data_in[255:0]))
                                    end
                                   end
                                6: begin
                                    if (data_out[511:0] != data_in[511:0]) begin
                                      `uvm_info("VS", $sformatf("Data Mismatch CHI<%=cidx%>. Address = %x, xfer size 64B, Write Data = %x, Read Data = %x", ncoreConfigInfo::user_addrq[ncoreConfigInfo::COH][i], data_out[511:0], data_in[511:0]), UVM_LOW)
                                    end
                                   end
                                default: begin
                                    `uvm_error("VS", $sformatf("Unsupported data size [CHI<%=cidx%>]%d", data_size))
                                   end
                              endcase
                          end   //for i
                      end // for j
                    end  // k_directed_test_all_coh 

                    if ((k_directed_test_noncoh_addr_pct != 0) && (k_directed_test_coh_addr_pct != 0)) begin  // both non-coherent and coherent
                       for (int i = 0; i < chi_num_trans; i++) begin
                          //m_chi0_args.k_wr_noncoh_pct.set_value(k_directed_test_noncoh_addr_pct);
                          //m_chi0_args.k_rd_noncoh_pct.set_value(0);

                          //m_chi0_args.k_wr_cohunq_pct.set_value(k_directed_test_coh_addr_pct);
                          //m_chi0_args.k_rd_rdonce_pct.set_value(0);
                          //m_chi<%=cidx%>_vseq.set_unit_args(m_chi<%=cidx%>_args);
                          <% if(numChiAiu > 0) { %>
                              m_svt_chi_item.m_args = m_chi0_args;
                          <% } %>
                          m_snps_chi<%=cidx%>_vseq.set_unit_args(m_chi0_args);

                          assert(std::randomize(data_out));
                          assert(std::randomize(data_out_1));
                          data_size = 6;  // 64 bytes
                          temp_addr=ncoreConfigInfo::user_addrq[ncoreConfigInfo::NONCOH][i];
                             if(temp_addr==0)begin
                                temp_addr=addr_mgr.get_noncoh_addr(<%=obj.AiuInfo[cidx].FUnitId%>, 1);
                              end
                           temp_addr_coh=ncoreConfigInfo::user_addrq[ncoreConfigInfo::COH][i];
                             if(temp_addr_coh==0)begin
                                 temp_addr_coh=addr_mgr.get_coh_addr(<%=obj.AiuInfo[cidx].FUnitId%>, 1);
                              end
                           `uvm_info("VS", $sformatf("CHI<%=cidx%> Non-coherent Write Address = %x,size = %d, Write Data = %x", ncoreConfigInfo::user_addrq[ncoreConfigInfo::NONCOH][i], data_size, data_out), UVM_LOW) 
                          `uvm_info("VS", $sformatf("CHI<%=cidx%> Coherent Write Address = %x,size = %d, Write Data = %x", ncoreConfigInfo::user_addrq[ncoreConfigInfo::COH][i], data_size, data_out_1), UVM_LOW) 
                             m_snps_chi<%=cidx%>_vseq.write_memory(temp_addr, data_out, data_size); //need to add for snps
                             //m_snps_chi<%=cidx%>_vseq.write_memory(ncoreConfigInfo::user_addrq[ncoreConfigInfo::NONCOH][i], data_out, data_size); //need to add for snps
                             m_snps_chi<%=cidx%>_vseq.write_memory_coh(temp_addr_coh, data_out_1, data_size); //need to add for snps
                             //m_snps_chi<%=cidx%>_vseq.write_memory_coh(ncoreConfigInfo::user_addrq[ncoreConfigInfo::COH][i], data_out_1, data_size); //need to add for snps

                           //m_chi0_args.k_wr_noncoh_pct.set_value(0);
                           //m_chi0_args.k_rd_noncoh_pct.set_value(k_directed_test_noncoh_addr_pct);

                           //m_chi0_args.k_wr_cohunq_pct.set_value(0);
                           //m_chi0_args.k_rd_rdonce_pct.set_value(k_directed_test_coh_addr_pct);
                           //m_chi<%=cidx%>_vseq.set_unit_args(m_chi<%=cidx%>_args);// need to add
                           <% if(numChiAiu > 0) { %>
                              m_svt_chi_item.m_args = m_chi0_args;
                           <% } %>
                           m_snps_chi<%=cidx%>_vseq.set_unit_args(m_chi0_args);


                             //m_snps_chi<%=cidx%>_vseq.read_memory(ncoreConfigInfo::user_addrq[ncoreConfigInfo::NONCOH][i], data_in, data_size, wData);// need to add 
                            // m_snps_chi<%=cidx%>_vseq.read_memory_coh(ncoreConfigInfo::user_addrq[ncoreConfigInfo::COH][i], data_in_1, data_size, wData);//need to add 
                             m_snps_chi<%=cidx%>_vseq.read_memory(temp_addr, data_in, data_size, wData);// need to add 
                             m_snps_chi<%=cidx%>_vseq.read_memory_coh(temp_addr_coh, data_in_1, data_size, wData);//need to add 
                           `uvm_info("VS", $sformatf("CHI<%=cidx%> Non-coherent Read Address = %x,size = %d,  Read Data = %x", ncoreConfigInfo::user_addrq[ncoreConfigInfo::NONCOH][i], data_size,data_in), UVM_LOW)
                           `uvm_info("VS", $sformatf("CHI<%=cidx%> Coherent Read Address = %x,size = %d,  Read Data = %x", ncoreConfigInfo::user_addrq[ncoreConfigInfo::COH][i], data_size,data_in_1), UVM_LOW)
                            if (data_out[511:0] != data_in[511:0]) begin
                                      `uvm_info("VS", $sformatf("Non-coherent Data Mismatch CHI<%=cidx%>. Address = %x, xfer size 64B, Write Data = %x, Read Data = %x", ncoreConfigInfo::user_addrq[ncoreConfigInfo::NONCOH][i], data_out[511:0], data_in[511:0]), UVM_LOW)
                            end
                            if (data_out_1[511:0] != data_in_1[511:0]) begin
                                      `uvm_info("VS", $sformatf("Coherent Data Mismatch CHI<%=cidx%>. Address = %x, xfer size 64B, Write Data = %x, Read Data = %x", ncoreConfigInfo::user_addrq[ncoreConfigInfo::COH][i], data_out[511:0], data_in[511:0]), UVM_LOW)
                            end
                       end

                    end //k_directed_test_noncoh_addr_pct and k_directed_test_coh_addr_pct

                       `uvm_info("FULLSYS_TEST", "Done write/ read  on processor<%=idx%> : CHIAIU<%=cidx%>", UVM_NONE)
                           
     `endif //`ifndef USE_VIP_SNPS .. `else
                   end  //case
     <% cidx++;
    } else { %>
                <%=idx%>: begin 
                   `uvm_info("FULLSYS_TEST", "Start write on processor<%=idx%> : IOAIU<%=ncidx%>", UVM_NONE)
                   `ifndef USE_VIP_SNPS
                   <% for(let i=0; i<aiu_NumCores[idx]; i++) { %>
                   fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_seq<%=ncidx%>[<%=i%>].k_num_read_req        = 0;
                   fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_seq<%=ncidx%>[<%=i%>].k_num_write_req       = ioaiu_num_trans;
                   fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_seq<%=ncidx%>[<%=i%>].k_directed_test_alloc = 1;
        <% if((obj.AiuInfo[idx].fnNativeInterface == 'ACE') || (obj.AiuInfo[idx].fnNativeInterface == 'ACE-LITE') || (obj.AiuInfo[idx].fnNativeInterface == 'ACELITE-E')) { %>
                   fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_seq<%=ncidx%>[<%=i%>].wt_ace_rdnosnp      = 0;
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
      <% } %>
                `else
      <% for(let i=0; i<aiu_NumCores[pidx]; i++) { %> 
                   cust_seq_h<%=ncidx%>[<%=i%>].k_num_read_req        = 0;
                   cust_seq_h<%=ncidx%>[<%=i%>].k_num_write_req       = ioaiu_num_trans;
                   cust_seq_h<%=ncidx%>[<%=i%>].k_directed_test_alloc = 1;
        <% if((obj.AiuInfo[idx].fnNativeInterface == 'ACE') || (obj.AiuInfo[idx].fnNativeInterface == 'ACE-LITE') || (obj.AiuInfo[idx].fnNativeInterface == 'ACELITE-E')) { %>
                   cust_seq_h<%=ncidx%>[<%=i%>].wt_ace_rdnosnp      = 0;
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
                       for (int i=0; i < ioaiu_num_trans; i++) begin
                          int size = $clog2(ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA/8);
                          int len = 3;   // transfer length of 4
                          int coh = 0;  // non-coherent 
                          bit [ncoreConfigInfo::W_SEC_ADDR-1:0] non_coh_addr;
                          bit [5:0] idx_val = <%=idx%>;
                          bit [1023:0] ioaiu_data_out;
                          bit [1023:0] ioaiu_data_in;
                          non_coh_addr = ncoreConfigInfo::user_addrq[ncoreConfigInfo::NONCOH][i];
                          non_coh_addr[12:0] = {idx_val, 7'b0000000};
                          assert(std::randomize(ioaiu_data_out));
                              `uvm_info("VS", $sformatf("AXI Write addr=%x, ioaiu_data_out = %x", non_coh_addr, ioaiu_data_out), UVM_LOW)
                              write_ioaiu<%=ncidx%>(non_coh_addr, len, size, ioaiu_data_out,coh);
                              read_ioaiu<%=ncidx%>(non_coh_addr, len, size, ioaiu_data_in);
                              `uvm_info("VS", $sformatf("AXI Read addr=%x, ioaiu_data_in = %x", non_coh_addr, ioaiu_data_in), UVM_LOW)
                              if (ioaiu_data_out[4*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA-1:0] != ioaiu_data_in[4*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA-1:0]) begin
                                 `uvm_error("VS", $sformatf("IOAIU<%=ncidx%> AXI Data Transfer ERROR, Expected = %x, Actual = %x", 
                                                            ioaiu_data_out[4*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA-1:0], ioaiu_data_in[4*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA-1:0]))
                              end
                              else begin
                                 `uvm_info("VS", "IOAIU<%=ncidx%> AXI Data Transfer Write-Read Test Match GOOD", UVM_LOW)
                              end
                       end  // for

/*
                   fork
                   begin
                       phase.raise_objection(this, "IOAIU<%=ncidx%> sequence");
                       // m_iocache_seq<%=ncidx%>.start(null);
                       `uvm_info("FULLSYS_TEST", "Done write on processor<%=idx%> : IOAIU<%=ncidx%>", UVM_NONE)
                       #10us;
                       phase.drop_objection(this, "IOAIU<%=ncidx%> sequence");
                   end
                   begin
                       ev_ioaiu<%=ncidx%>_seq_done.wait_trigger();
                       ev_sim_done.trigger(null);
                   end
                   join
*/
                   end  // case

     <% ncidx++;
    }
  } %>
                endcase
// `endif //`ifndef USE_VIP_SNPS
endtask : directed_write_read_test

//************************************************************************************
task concerto_fullsys_direct_wr_rd_legacy_test::directed_write_read_test_all_aius(uvm_phase phase);
   `uvm_info("VS", "Directed Write/ Read Test All AIUs", UVM_LOW)
   
   
// `ifndef USE_VIP_SNPS //existing flow will not run when USE_VIP_SNPS set
   fork    // execute all AIUs in parallel
  <% for(idx = 0, cidx=0, ncidx=0; idx < obj.nAIUs; idx++) { 
               if((obj.AiuInfo[idx].fnNativeInterface.match('CHI'))) { %>
    `ifndef USE_VIP_SNPS //existing flow will not run when USE_VIP_SNPS set
                begin 
                    bit [511:0] data_in, data_in_1;
                    bit [511:0] data_out, data_out_1;
                    bit [ncoreConfigInfo::W_SEC_ADDR-1:0] coh_addr;
                    bit [ncoreConfigInfo::W_SEC_ADDR-1:0] non_coh_addr;
                    bit [5:0] idx_val = <%=idx%>;
                    int data_size;
                    int wData;
                   `uvm_info("FULLSYS_TEST", "Start write/read on processor<%=idx%> : CHIAIU<%=cidx%>", UVM_NONE)

                    <% if (obj.AiuInfo[idx].wData == 128) { %>
                        wData = 128;
                    <% } else if (obj.AiuInfo[idx].wData == 256) { %> 
                         wData = 256;
                    <% } else { %>
                         wData = 512;
                    <% } %>
                    `uvm_info("VS", $sformatf("wData<%=cidx%> = %d", wData), UVM_LOW)
                       
                    if ($test$plusargs("k_directed_test_all_coh")) begin
                       m_chi<%=cidx%>_args.k_coh_addr_pct.set_value(100);
                    end
                    else begin
                       m_chi<%=cidx%>_args.k_coh_addr_pct.set_value(k_directed_test_coh_addr_pct);
                    end

                    if ($test$plusargs("k_directed_test_all_non_coh")) begin
                       m_chi<%=cidx%>_args.k_noncoh_addr_pct.set_value(100);
                    end 
                    else begin
                       m_chi<%=cidx%>_args.k_noncoh_addr_pct.set_value(k_directed_test_noncoh_addr_pct);
                    end
                    // m_chi<%=cidx%>_args.k_new_addr_pct.set_value(100);
                    m_chi<%=cidx%>_args.k_rd_noncoh_pct.set_value(0);
                    m_chi<%=cidx%>_args.k_rd_ldrstr_pct.set_value(0);
                    m_chi<%=cidx%>_args.k_rd_rdonce_pct.set_value(0);
                    if ($test$plusargs("k_directed_test_all_non_coh")) begin
                        m_chi<%=cidx%>_args.k_wr_noncoh_pct.set_value(100);
                        m_chi<%=cidx%>_args.k_rd_noncoh_pct.set_value(0);
                    end
                    else begin
                        m_chi<%=cidx%>_args.k_wr_noncoh_pct.set_value(k_directed_test_noncoh_addr_pct);
                    end
                    if ($test$plusargs("k_directed_test_all_coh")) begin
                        m_chi<%=cidx%>_args.k_wr_cohunq_pct.set_value(100);
                    end
                    else begin
                        m_chi<%=cidx%>_args.k_wr_cohunq_pct.set_value(k_directed_test_coh_addr_pct);
                    end
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
                    if ($test$plusargs("k_directed_test_all_non_coh")) begin
                     for (int j = 1; j < 7; j++) begin
                          for (int i = 0; i < chi_num_trans; i++) begin
                             m_chi<%=cidx%>_args.k_wr_noncoh_pct.set_value(100);
                             m_chi<%=cidx%>_args.k_rd_noncoh_pct.set_value(0);
                             m_chi<%=cidx%>_vseq.set_unit_args(m_chi<%=cidx%>_args);
                             assert(std::randomize(data_out));
                             data_size = j;  // 2,4,8,16,32,64 bytes
                             non_coh_addr = ncoreConfigInfo::user_addrq[ncoreConfigInfo::NONCOH][i];
                             non_coh_addr[12:0] = {idx_val,7'b0000000};
                             `uvm_info("VS", $sformatf("CHI<%=cidx%> Write Address = %x,size = %d, Write Data = %x", non_coh_addr, data_size, data_out), UVM_LOW) 
                             m_chi<%=cidx%>_vseq.write_memory(non_coh_addr, data_out, data_size);

                             m_chi<%=cidx%>_args.k_wr_noncoh_pct.set_value(0);
                             m_chi<%=cidx%>_args.k_rd_noncoh_pct.set_value(100);
                             m_chi<%=cidx%>_vseq.set_unit_args(m_chi<%=cidx%>_args);

                             m_chi<%=cidx%>_vseq.read_memory(non_coh_addr, data_in, data_size, wData);
                             `uvm_info("VS", $sformatf("CHI<%=cidx%> Read Address = %x,size = %d,  Read Data = %x", non_coh_addr, data_size,data_in), UVM_LOW)

                             case (data_size)
                                1: begin
                                    if (data_out[15:0] != data_in[15:0]) begin
                                      `uvm_error("VS", $sformatf("Data Mismatch CHI<%=cidx%>. Address = %x, xfer size 2B, Write Data = %x, Read Data = %x", non_coh_addr, data_out[15:0], data_in[15:0]))
                                    end
                                   end
                                2: begin
                                    if (data_out[31:0] != data_in[31:0]) begin
                                      `uvm_error("VS", $sformatf("Data Mismatch CHI<%=cidx%>. Address = %x, xfer size 4B, Write Data = %x, Read Data = %x", non_coh_addr, data_out[31:0], data_in[31:0]))
                                    end
                                   end
                                3: begin
                                    if (data_out[63:0] != data_in[63:0]) begin
                                      `uvm_error("VS", $sformatf("Data Mismatch CHI<%=cidx%>. Address = %x, xfer size 8B, Write Data = %x, Read Data = %x", non_coh_addr, data_out[63:0], data_in[63:0]))
                                    end
                                   end
                                4: begin
                                    if (data_out[127:0] != data_in[127:0]) begin
                                      `uvm_error("VS", $sformatf("Data Mismatch CHI<%=cidx%>. Address = %x, xfer size 16B, Write Data = %x, Read Data = %x", non_coh_addr, data_out[127:0], data_in[127:0]))
                                    end
                                   end
                                5: begin
                                    if (data_out[255:0] != data_in[255:0]) begin
                                      `uvm_error("VS", $sformatf("Data Mismatch CHI<%=cidx%>. Address = %x, xfer size 32B, Write Data = %x, Read Data = %x", non_coh_addr, data_out[255:0], data_in[255:0]))
                                    end
                                   end
                                6: begin
                                    if (data_out[511:0] != data_in[511:0]) begin
                                      `uvm_error("VS", $sformatf("Data Mismatch CHI<%=cidx%>. Address = %x, xfer size 64B, Write Data = %x, Read Data = %x", non_coh_addr, data_out[511:0], data_in[511:0]))
                                    end
                                   end
                                default: begin
                                    `uvm_error("VS", $sformatf("Unsupported data size [CHI<%=cidx%>]%d", data_size))
                                   end
                              endcase
                          end   //for i
                      end // for j
                    end  // k_directed_test_all_non_coh 

                    if ($test$plusargs("k_directed_test_all_coh")) begin
                     for (int j = 6; j < 7; j++) begin  // need cacheline
                          for (int i = 0; i < chi_num_trans; i++) begin
                             m_chi<%=cidx%>_args.k_wr_cohunq_pct.set_value(100);
                             m_chi<%=cidx%>_args.k_rd_rdonce_pct.set_value(0);
                             m_chi<%=cidx%>_vseq.set_unit_args(m_chi<%=cidx%>_args);
                             assert(std::randomize(data_out));
                             data_size = j;  // 2,4,8,16,32,64 bytes
                             coh_addr = ncoreConfigInfo::user_addrq[ncoreConfigInfo::COH][i];
                             coh_addr[12:0] = {idx_val, 7'b0000000};
                             `uvm_info("VS", $sformatf("CHI<%=cidx%> Write Address = %x,size = %d, Write Data = %x", coh_addr, data_size, data_out), UVM_LOW) 
                             m_chi<%=cidx%>_vseq.write_memory_coh(coh_addr, data_out, data_size);

                             m_chi<%=cidx%>_args.k_wr_cohunq_pct.set_value(0);
                             m_chi<%=cidx%>_args.k_rd_rdonce_pct.set_value(100);
                             m_chi<%=cidx%>_vseq.set_unit_args(m_chi<%=cidx%>_args);

                              m_chi<%=cidx%>_vseq.read_memory_coh(coh_addr, data_in, data_size, wData);
                             `uvm_info("VS", $sformatf("CHI<%=cidx%> Read Address = %x,size = %d,  Read Data = %x", coh_addr, data_size,data_in), UVM_LOW)

                             case (data_size)
                                1: begin
                                    if (data_out[15:0] != data_in[15:0]) begin
                                      `uvm_error("VS", $sformatf("Data Mismatch CHI<%=cidx%>. Address = %x, xfer size 2B, Write Data = %x, Read Data = %x", coh_addr, data_out[15:0], data_in[15:0]))
                                    end
                                   end
                                2: begin
                                    if (data_out[31:0] != data_in[31:0]) begin
                                      `uvm_error("VS", $sformatf("Data Mismatch CHI<%=cidx%>. Address = %x, xfer size 4B, Write Data = %x, Read Data = %x", coh_addr, data_out[31:0], data_in[31:0]))
                                    end
                                   end
                                3: begin
                                    if (data_out[63:0] != data_in[63:0]) begin
                                      `uvm_error("VS", $sformatf("Data Mismatch CHI<%=cidx%>. Address = %x, xfer size 8B, Write Data = %x, Read Data = %x", coh_addr, data_out[63:0], data_in[63:0]))
                                    end
                                   end
                                4: begin
                                    if (data_out[127:0] != data_in[127:0]) begin
                                      `uvm_error("VS", $sformatf("Data Mismatch CHI<%=cidx%>. Address = %x, xfer size 16B, Write Data = %x, Read Data = %x", coh_addr, data_out[127:0], data_in[127:0]))
                                    end
                                   end
                                5: begin
                                    if (data_out[255:0] != data_in[255:0]) begin
                                      `uvm_error("VS", $sformatf("Data Mismatch CHI<%=cidx%>. Address = %x, xfer size 32B, Write Data = %x, Read Data = %x", coh_addr, data_out[255:0], data_in[255:0]))
                                    end
                                   end
                                6: begin
                                    if (data_out[511:0] != data_in[511:0]) begin
                                      `uvm_info("VS", $sformatf("Data Mismatch CHI<%=cidx%>. Address = %x, xfer size 64B, Write Data = %x, Read Data = %x", coh_addr, data_out[511:0], data_in[511:0]), UVM_LOW)
                                    end
                                   end
                                default: begin
                                    `uvm_error("VS", $sformatf("Unsupported data size [CHI<%=cidx%>]%d", data_size))
                                   end
                              endcase
                          end   //for i
                      end // for j
                    end  // k_directed_test_all_coh 

                    if ((k_directed_test_noncoh_addr_pct != 0) && (k_directed_test_coh_addr_pct != 0)) begin  // both non-coherent and coherent
                       for (int i = 0; i < chi_num_trans; i++) begin
                          m_chi<%=cidx%>_args.k_wr_noncoh_pct.set_value(k_directed_test_noncoh_addr_pct);
                          m_chi<%=cidx%>_args.k_rd_noncoh_pct.set_value(0);

                          m_chi<%=cidx%>_args.k_wr_cohunq_pct.set_value(k_directed_test_coh_addr_pct);
                          m_chi<%=cidx%>_args.k_rd_rdonce_pct.set_value(0);
                          m_chi<%=cidx%>_vseq.set_unit_args(m_chi<%=cidx%>_args);
                          assert(std::randomize(data_out));
                          assert(std::randomize(data_out_1));
                          data_size = 6;  // 64 bytes
                          non_coh_addr = ncoreConfigInfo::user_addrq[ncoreConfigInfo::NONCOH][i];
                          non_coh_addr[12:0] = {idx_val, 7'b0000000};
                          coh_addr = ncoreConfigInfo::user_addrq[ncoreConfigInfo::COH][i];
                          coh_addr[12:0] = {idx_val, 7'b0000000};
                           `uvm_info("VS", $sformatf("CHI<%=cidx%> Non-coherent Write Address = %x,size = %d, Write Data = %x", non_coh_addr, data_size, data_out), UVM_LOW) 
                          `uvm_info("VS", $sformatf("CHI<%=cidx%> Coherent Write Address = %x,size = %d, Write Data = %x", coh_addr, data_size, data_out_1), UVM_LOW) 
                           m_chi<%=cidx%>_vseq.write_memory(non_coh_addr, data_out, data_size);
                           m_chi<%=cidx%>_vseq.write_memory_coh(coh_addr, data_out_1, data_size);

                           m_chi<%=cidx%>_args.k_wr_noncoh_pct.set_value(0);
                           m_chi<%=cidx%>_args.k_rd_noncoh_pct.set_value(k_directed_test_noncoh_addr_pct);

                           m_chi<%=cidx%>_args.k_wr_cohunq_pct.set_value(0);
                           m_chi<%=cidx%>_args.k_rd_rdonce_pct.set_value(k_directed_test_coh_addr_pct);
                           m_chi<%=cidx%>_vseq.set_unit_args(m_chi<%=cidx%>_args);

                           m_chi<%=cidx%>_vseq.read_memory(ncoreConfigInfo::user_addrq[ncoreConfigInfo::NONCOH][i], data_in, data_size, wData);
                           m_chi<%=cidx%>_vseq.read_memory_coh(ncoreConfigInfo::user_addrq[ncoreConfigInfo::COH][i], data_in_1, data_size, wData);
                           `uvm_info("VS", $sformatf("CHI<%=cidx%> Non-coherent Read Address = %x,size = %d,  Read Data = %x", non_coh_addr, data_size,data_in), UVM_LOW)
                           `uvm_info("VS", $sformatf("CHI<%=cidx%> Coherent Read Address = %x,size = %d,  Read Data = %x", coh_addr, data_size,data_in_1), UVM_LOW)
                            if (data_out[511:0] != data_in[511:0]) begin
                                      `uvm_info("VS", $sformatf("Non-coherent Data Mismatch CHI<%=cidx%>. Address = %x, xfer size 64B, Write Data = %x, Read Data = %x", non_coh_addr, data_out[511:0], data_in[511:0]), UVM_LOW)
                            end
                            if (data_out_1[511:0] != data_in_1[511:0]) begin
                                      `uvm_info("VS", $sformatf("Coherent Data Mismatch CHI<%=cidx%>. Address = %x, xfer size 64B, Write Data = %x, Read Data = %x", coh_addr, data_out_1[511:0], data_in_1[511:0]), UVM_LOW)
                            end
                       end

                    end //k_directed_test_noncoh_addr_pct and k_directed_test_coh_addr_pct

                       `uvm_info("FULLSYS_TEST", "Done write/ read  on processor<%=idx%> All AIUs: CHIAIU<%=cidx%>", UVM_NONE)
                   end // fork 
    `else //`ifndef USE_VIP_SNPS
             begin 
                    bit [511:0] data_in, data_in_1;
                    bit [511:0] data_out, data_out_1;
                    bit [ncoreConfigInfo::W_SEC_ADDR-1:0] coh_addr;
                    bit [ncoreConfigInfo::W_SEC_ADDR-1:0] non_coh_addr;
                    bit [5:0] idx_val = <%=idx%>;
                    int data_size;
                    int wData;
                    int flag;
                   `uvm_info("FULLSYS_TEST", "Start write/read on processor<%=idx%> : CHIAIU<%=cidx%>", UVM_NONE)

                    <% if (obj.AiuInfo[idx].wData == 128) { %>
                        wData = 128;
                    <% } else if (obj.AiuInfo[idx].wData == 256) { %> 
                         wData = 256;
                    <% } else { %>
                         wData = 512;
                    <% } %>
                    `uvm_info("VS", $sformatf("wData<%=cidx%> = %d", wData), UVM_LOW)
                      //key.put(); 
                    if ($test$plusargs("k_directed_test_all_coh")) begin
                       m_chi0_args.k_coh_addr_pct.set_value(100);
                    end
                    else begin
                       m_chi0_args.k_coh_addr_pct.set_value(k_directed_test_coh_addr_pct);
                    end

                    if ($test$plusargs("k_directed_test_all_non_coh")) begin
                       m_chi0_args.k_noncoh_addr_pct.set_value(100);
                    end 
                    else begin
                       m_chi0_args.k_noncoh_addr_pct.set_value(k_directed_test_noncoh_addr_pct);
                    end
                    // m_chi0_args.k_new_addr_pct.set_value(100);
                    m_chi0_args.k_rd_noncoh_pct.set_value(0);
                    m_chi0_args.k_rd_ldrstr_pct.set_value(0);
                    m_chi0_args.k_rd_rdonce_pct.set_value(0);
                    if ($test$plusargs("k_directed_test_all_non_coh")) begin
                        m_chi0_args.k_wr_noncoh_pct.set_value(100);
                        m_chi0_args.k_rd_noncoh_pct.set_value(100);
                    end
                    else begin
                        m_chi0_args.k_wr_noncoh_pct.set_value(k_directed_test_noncoh_addr_pct);
                        m_chi0_args.k_rd_noncoh_pct.set_value(k_directed_test_noncoh_addr_pct);
                    end
                    if ($test$plusargs("k_directed_test_all_coh")) begin
                        m_chi0_args.k_wr_cohunq_pct.set_value(100);
                        m_chi0_args.k_rd_rdonce_pct.set_value(100);
                    end
                    else begin
                        m_chi0_args.k_wr_cohunq_pct.set_value(k_directed_test_coh_addr_pct);
                        m_chi0_args.k_rd_rdonce_pct.set_value(k_directed_test_coh_addr_pct);
                    end
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
                    if ($test$plusargs("k_directed_test_all_non_coh")) begin
                     for (int j = 1; j < 7; j++) begin
                          for (int i = 0; i < chi_num_trans; i++) begin
                             
                             assert(std::randomize(data_out));
                             data_size = j;  // 2,4,8,16,32,64 bytes
                             non_coh_addr = ncoreConfigInfo::user_addrq[ncoreConfigInfo::NONCOH][i];

                              if(non_coh_addr==0)begin
                                 non_coh_addr=addr_mgr.get_noncoh_addr(<%=obj.AiuInfo[cidx].FUnitId%>, 1);
                              end
                             non_coh_addr[12:0] = {idx_val,7'b0000000};
                             //key.get(1);
                               //m_chi0_args.k_wr_noncoh_pct.set_value(100);
                               //m_chi0_args.k_rd_noncoh_pct.set_value(0);
                             <% if(numChiAiu > 0) { %>
                                m_svt_chi_item.m_args = m_chi0_args;
                             <% } %>
                             m_snps_chi<%=cidx%>_vseq.set_unit_args(m_chi0_args);

                             `uvm_info("VS", $sformatf("CHI<%=cidx%> Write Address = %x,size = %d, Write Data = %x value_i=%0d flag=%0d", non_coh_addr, data_size, data_out,i,flag), UVM_LOW) 
                              m_snps_chi<%=cidx%>_vseq.write_memory(non_coh_addr, data_out, data_size); //need to add

                                 //m_chi0_args.k_wr_noncoh_pct.set_value(0);
                                 //m_chi0_args.k_rd_noncoh_pct.set_value(100);
                             <% if(numChiAiu > 0) { %>
                                m_svt_chi_item.m_args = m_chi0_args;
                             <% } %>
                              m_snps_chi<%=cidx%>_vseq.set_unit_args(m_chi0_args);

                              //#500ns;
                           
                             m_snps_chi<%=cidx%>_vseq.read_memory(non_coh_addr, data_in, data_size, wData); //need to add
                             flag=flag+1;
                             `uvm_info("VS", $sformatf("CHI<%=cidx%> Read Address = %x,size = %d,  Read Data = %x value_i=%0d flag =%0d", non_coh_addr, data_size,data_in,i,flag), UVM_LOW)
                             case (data_size)
                                1: begin
                                    if (data_out[15:0] != data_in[15:0]) begin
                                      `uvm_error("VS", $sformatf("Data Mismatch CHI<%=cidx%>. Address = %x, xfer size 2B, Write Data = %x, Read Data = %x", non_coh_addr, data_out[15:0], data_in[15:0]))
                                    end
                                   end
                                2: begin
                                    if (data_out[31:0] != data_in[31:0]) begin
                                      `uvm_error("VS", $sformatf("Data Mismatch CHI<%=cidx%>. Address = %x, xfer size 4B, Write Data = %x, Read Data = %x", non_coh_addr, data_out[31:0], data_in[31:0]))
                                    end
                                   end
                                3: begin
                                    if (data_out[63:0] != data_in[63:0]) begin
                                      `uvm_error("VS", $sformatf("Data Mismatch CHI<%=cidx%>. Address = %x, xfer size 8B, Write Data = %x, Read Data = %x", non_coh_addr, data_out[63:0], data_in[63:0]))
                                    end
                                   end
                                4: begin
                                    if (data_out[127:0] != data_in[127:0]) begin
                                      `uvm_error("VS", $sformatf("Data Mismatch CHI<%=cidx%>. Address = %x, xfer size 16B, Write Data = %x, Read Data = %x", non_coh_addr, data_out[127:0], data_in[127:0]))
                                    end
                                   end
                                5: begin
                                    if (data_out[255:0] != data_in[255:0]) begin
                                      `uvm_error("VS", $sformatf("Data Mismatch CHI<%=cidx%>. Address = %x, xfer size 32B, Write Data = %x, Read Data = %x", non_coh_addr, data_out[255:0], data_in[255:0]))
                                    end
                                   end
                                6: begin
                                    if (data_out[511:0] != data_in[511:0]) begin
                                      `uvm_error("VS", $sformatf("Data Mismatch CHI<%=cidx%>. Address = %x, xfer size 64B, Write Data = %x, Read Data = %x", non_coh_addr, data_out[511:0], data_in[511:0]))
                                    end
                                   end
                                default: begin
                                    `uvm_error("VS", $sformatf("Unsupported data size [CHI<%=cidx%>]%d", data_size))
                                   end
                              endcase
                              //key.put(1);
                          end   //for i
                      end // for j
                      //key.get();
                    end  // k_directed_test_all_non_coh 

                    if ($test$plusargs("k_directed_test_all_coh")) begin
                     for (int j = 6; j < 7; j++) begin  // need cacheline
                          for (int i = 0; i < chi_num_trans; i++) begin
                             //m_chi0_args.k_wr_cohunq_pct.set_value(100);
                             //m_chi0_args.k_rd_rdonce_pct.set_value(0);
                             <% if(numChiAiu > 0) { %>
                                m_svt_chi_item.m_args = m_chi0_args;
                             <% } %>
                             m_snps_chi<%=cidx%>_vseq.set_unit_args(m_chi0_args);
                   
                             assert(std::randomize(data_out));
                             data_size = j;  // 2,4,8,16,32,64 bytes
                             coh_addr = ncoreConfigInfo::user_addrq[ncoreConfigInfo::COH][i];
                              
                              if(coh_addr==0)begin
                              coh_addr=addr_mgr.get_coh_addr(<%=obj.AiuInfo[cidx].FUnitId%>, 1);
                              end
                             
                             coh_addr[12:0] = {idx_val, 7'b0000000};
                            //coh_key.get(1);
                             `uvm_info("VS", $sformatf("CHI<%=cidx%> Write Address = %x,size = %d, Write Data = %x", coh_addr, data_size, data_out), UVM_LOW) 
                              m_snps_chi<%=cidx%>_vseq.write_memory_coh(coh_addr, data_out, data_size); //need to add

                             //m_chi0_args.k_wr_cohunq_pct.set_value(0);
                             //m_chi0_args.k_rd_rdonce_pct.set_value(100);
                             <% if(numChiAiu > 0) { %>
                                m_svt_chi_item.m_args = m_chi0_args;
                             <% } %>
                             m_snps_chi<%=cidx%>_vseq.set_unit_args(m_chi0_args);

                              m_snps_chi<%=cidx%>_vseq.read_memory_coh(coh_addr, data_in, data_size, wData); // need to add
                             `uvm_info("VS", $sformatf("CHI<%=cidx%> Read Address = %x,size = %d,  Read Data = %x", coh_addr, data_size,data_in), UVM_LOW)

                             case (data_size)
                                1: begin
                                    if (data_out[15:0] != data_in[15:0]) begin
                                      `uvm_error("VS", $sformatf("Data Mismatch CHI<%=cidx%>. Address = %x, xfer size 2B, Write Data = %x, Read Data = %x", coh_addr, data_out[15:0], data_in[15:0]))
                                    end
                                   end
                                2: begin
                                    if (data_out[31:0] != data_in[31:0]) begin
                                      `uvm_error("VS", $sformatf("Data Mismatch CHI<%=cidx%>. Address = %x, xfer size 4B, Write Data = %x, Read Data = %x", coh_addr, data_out[31:0], data_in[31:0]))
                                    end
                                   end
                                3: begin
                                    if (data_out[63:0] != data_in[63:0]) begin
                                      `uvm_error("VS", $sformatf("Data Mismatch CHI<%=cidx%>. Address = %x, xfer size 8B, Write Data = %x, Read Data = %x", coh_addr, data_out[63:0], data_in[63:0]))
                                    end
                                   end
                                4: begin
                                    if (data_out[127:0] != data_in[127:0]) begin
                                      `uvm_error("VS", $sformatf("Data Mismatch CHI<%=cidx%>. Address = %x, xfer size 16B, Write Data = %x, Read Data = %x", coh_addr, data_out[127:0], data_in[127:0]))
                                    end
                                   end
                                5: begin
                                    if (data_out[255:0] != data_in[255:0]) begin
                                      `uvm_error("VS", $sformatf("Data Mismatch CHI<%=cidx%>. Address = %x, xfer size 32B, Write Data = %x, Read Data = %x", coh_addr, data_out[255:0], data_in[255:0]))
                                    end
                                   end
                                6: begin
                                    if (data_out[511:0] != data_in[511:0]) begin
                                      `uvm_info("VS", $sformatf("Data Mismatch CHI<%=cidx%>. Address = %x, xfer size 64B, Write Data = %x, Read Data = %x", coh_addr, data_out[511:0], data_in[511:0]), UVM_LOW)
                                    end
                                   end
                                default: begin
                                    `uvm_error("VS", $sformatf("Unsupported data size [CHI<%=cidx%>]%d", data_size))
                                   end
                              endcase
                              //coh_key.put(1);
                          end   //for i
                      end // for j
                    end  // k_directed_test_all_coh 

                    if ((k_directed_test_noncoh_addr_pct != 0) && (k_directed_test_coh_addr_pct != 0)) begin  // both non-coherent and coherent
                       for (int i = 0; i < chi_num_trans; i++) begin
                          //m_chi0_args.k_wr_noncoh_pct.set_value(k_directed_test_noncoh_addr_pct);
                          //m_chi0_args.k_rd_noncoh_pct.set_value(0);

                          //m_chi0_args.k_wr_cohunq_pct.set_value(k_directed_test_coh_addr_pct);
                          //m_chi0_args.k_rd_rdonce_pct.set_value(0);
                          //m_chi<%=cidx%>_vseq.set_unit_args(m_chi<%=cidx%>_args);
                             <% if(numChiAiu > 0) { %>
                                m_svt_chi_item.m_args = m_chi0_args;
                             <% } %>
                             m_snps_chi<%=cidx%>_vseq.set_unit_args(m_chi0_args);
                          assert(std::randomize(data_out));
                          assert(std::randomize(data_out_1));
                          data_size = 6;  // 64 bytes
                          non_coh_addr = ncoreConfigInfo::user_addrq[ncoreConfigInfo::NONCOH][i];
                          non_coh_addr[12:0] = {idx_val, 7'b0000000};
                          coh_addr = ncoreConfigInfo::user_addrq[ncoreConfigInfo::COH][i];
                          coh_addr[12:0] = {idx_val, 7'b0000000};
                           `uvm_info("VS", $sformatf("CHI<%=cidx%> Non-coherent Write Address = %x,size = %d, Write Data = %x", non_coh_addr, data_size, data_out), UVM_LOW) 
                          `uvm_info("VS", $sformatf("CHI<%=cidx%> Coherent Write Address = %x,size = %d, Write Data = %x", coh_addr, data_size, data_out_1), UVM_LOW) 
                           m_snps_chi<%=cidx%>_vseq.write_memory(non_coh_addr, data_out, data_size); //need to add 
                           m_snps_chi<%=cidx%>_vseq.write_memory_coh(coh_addr, data_out_1, data_size);//need to add

                           //m_chi0_args.k_wr_noncoh_pct.set_value(0);
                           //m_chi0_args.k_rd_noncoh_pct.set_value(k_directed_test_noncoh_addr_pct);

                           //m_chi0_args.k_wr_cohunq_pct.set_value(0);
                           //m_chi0_args.k_rd_rdonce_pct.set_value(k_directed_test_coh_addr_pct);
                           //m_chi<%=cidx%>_vseq.set_unit_args(m_chi<%=cidx%>_args);
                             <% if(numChiAiu > 0) { %>
                                m_svt_chi_item.m_args = m_chi0_args;
                             <% } %>
                             m_snps_chi<%=cidx%>_vseq.set_unit_args(m_chi0_args);

                             m_snps_chi<%=cidx%>_vseq.read_memory(non_coh_addr, data_in, data_size, wData); //need to add
                             m_snps_chi<%=cidx%>_vseq.read_memory_coh(coh_addr, data_in_1, data_size, wData); // need to add
                             //m_snps_chi<%=cidx%>_vseq.read_memory(ncoreConfigInfo::user_addrq[ncoreConfigInfo::NONCOH][i], data_in, data_size, wData); //need to add
                             //m_snps_chi<%=cidx%>_vseq.read_memory_coh(ncoreConfigInfo::user_addrq[ncoreConfigInfo::COH][i], data_in_1, data_size, wData); // need to add
                           `uvm_info("VS", $sformatf("CHI<%=cidx%> Non-coherent Read Address = %x,size = %d,  Read Data = %x", non_coh_addr, data_size,data_in), UVM_LOW)
                           `uvm_info("VS", $sformatf("CHI<%=cidx%> Coherent Read Address = %x,size = %d,  Read Data = %x", coh_addr, data_size,data_in_1), UVM_LOW)
                            if (data_out[511:0] != data_in[511:0]) begin
                                      `uvm_info("VS", $sformatf("Non-coherent Data Mismatch CHI<%=cidx%>. Address = %x, xfer size 64B, Write Data = %x, Read Data = %x", non_coh_addr, data_out[511:0], data_in[511:0]), UVM_LOW)
                            end
                            if (data_out_1[511:0] != data_in_1[511:0]) begin
                                      `uvm_info("VS", $sformatf("Coherent Data Mismatch CHI<%=cidx%>. Address = %x, xfer size 64B, Write Data = %x, Read Data = %x", coh_addr, data_out_1[511:0], data_in_1[511:0]), UVM_LOW)
                            end
                       end

                    end //k_directed_test_noncoh_addr_pct and k_directed_test_coh_addr_pct

                       `uvm_info("FULLSYS_TEST", "Done write/ read  on processor<%=idx%> All AIUs: CHIAIU<%=cidx%>", UVM_NONE)
                       //key.get();
                   end // fork 

    `endif //`ifndef USE_VIP_SNPS ... `else
     <% cidx++;
    } else { %>
                begin 
                    bit [1023:0] data_in, data_in_1;
                    bit [1023:0] data_out, data_out_1;
                    int data_size;
                    bit [ncoreConfigInfo::W_SEC_ADDR-1:0] non_coh_addr;
                    bit [ncoreConfigInfo::W_SEC_ADDR-1:0] coh_addr;
                    bit [5:0] idx_val = <%=idx%>;
                   `uvm_info("FULLSYS_TEST", "Start write on processor<%=idx%> : IOAIU<%=ncidx%>", UVM_NONE)
     
                   `ifndef USE_VIP_SNPS
                   <% for(let i=0; i<aiu_NumCores[idx]; i++) { %> 
                   fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_seq<%=ncidx%>[<%=i%>].k_num_read_req        = 0;
                   fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_seq<%=ncidx%>[<%=i%>].k_num_write_req       = ioaiu_num_trans;
                   fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_seq<%=ncidx%>[<%=i%>].k_directed_test_alloc = 1;
        <% if((obj.AiuInfo[idx].fnNativeInterface == 'ACE') || (obj.AiuInfo[idx].fnNativeInterface == 'ACE-LITE') || (obj.AiuInfo[idx].fnNativeInterface == 'ACELITE-E')) { %>
                   fsys_main_traffic_vseq.ioaiu_traffic_vseq.inhouse_vseq.m_iocache_seq<%=ncidx%>[<%=i%>].wt_ace_rdnosnp      = 0;
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
      <% } %>
                  `else
      <% for(let i=0; i<aiu_NumCores[pidx]; i++) { %> 
                   cust_seq_h<%=ncidx%>[<%=i%>].k_num_read_req        = 0;
                   cust_seq_h<%=ncidx%>[<%=i%>].k_num_write_req       = ioaiu_num_trans;
                   cust_seq_h<%=ncidx%>[<%=i%>].k_directed_test_alloc = 1;
        <% if((obj.AiuInfo[idx].fnNativeInterface == 'ACE') || (obj.AiuInfo[idx].fnNativeInterface == 'ACE-LITE') || (obj.AiuInfo[idx].fnNativeInterface == 'ACELITE-E')) { %>
                   cust_seq_h<%=ncidx%>[<%=i%>].wt_ace_rdnosnp      = 0;
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
                       for (int i=0; i < ioaiu_num_trans; i++) begin
                          int size = $clog2(ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA/8);
                          int len;   
                          assert(std::randomize(data_out));
                          non_coh_addr = ncoreConfigInfo::user_addrq[ncoreConfigInfo::NONCOH][i];
                          non_coh_addr[12:0] = {idx_val, 7'b0000000};
                          coh_addr = ncoreConfigInfo::user_addrq[ncoreConfigInfo::COH][i];
                          coh_addr[12:0] = {idx_val, 7'b0000000};
                          if ($test$plusargs("k_directed_test_all_non_coh")) begin
                            for(int len = 0; len < 4; len++) begin  
                                int width = ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA;
                                assert(std::randomize(data_out));
                               `uvm_info("VS", $sformatf("IOAIU<%=ncidx%> AXI Write Non-coherent Addr=%x, data_out = %x, width=%0d", non_coh_addr, data_out[4*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA-1:0], width), UVM_LOW)
                                write_ioaiu<%=ncidx%>(non_coh_addr, len, size, data_out[1023:0], 0);
                                read_ioaiu<%=ncidx%>(non_coh_addr, len, size, data_in[1023:0]);
                               `uvm_info("VS", $sformatf("IOAIU<%=ncidx%> AXI Read Non-coherent Addr=%x, data_in = %x", non_coh_addr, data_in[4*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA-1:0]), UVM_LOW)
                                case (len)
                                   0: begin
                                         if (data_out[ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA-1:0] != data_in[ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA-1:0]) begin
                                            `uvm_error("VS", $sformatf("IOAIU<%=ncidx%> AXI Data Transfer ERROR0, Expected = %x, Actual = %x", 
                                                                        data_out[ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA-1:0], data_in[ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA-1:0]))
                                         end
                                         else begin
                                             `uvm_info("VS", "IOAIU<%=ncidx%> AXI Data Transfer Write-Read Test Match GOOD", UVM_LOW)
                                         end
                                      end
                                   1: begin
                                         if (data_out[2*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA-1:0] != data_in[2*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA-1:0]) begin
                                            `uvm_error("VS", $sformatf("IOAIU<%=ncidx%> AXI Data Transfer ERROR1, Expected = %x, Actual = %x", 
                                                                        data_out[2*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA-1:0], data_in[2*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA-1:0]))
                                         end
                                         else begin
                                             `uvm_info("VS", "IOAIU<%=ncidx%> AXI Data Transfer Write-Read Test Match GOOD", UVM_LOW)
                                         end
                                      end
                                   2: begin
                                         if (data_out[3*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA-1:0] != data_in[3*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA-1:0]) begin
                                            `uvm_error("VS", $sformatf("IOAIU<%=ncidx%> AXI Data Transfer ERROR2, Expected = %x, Actual = %x", 
                                                                        data_out[3*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA-1:0], data_in[3*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA-1:0]))
                                         end
                                         else begin
                                             `uvm_info("VS", "IOAIU<%=ncidx%> AXI Data Transfer Write-Read Test Match GOOD", UVM_LOW)
                                         end
                                      end
                                   3: begin
                                         if (data_out[4*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA-1:0] != data_in[4*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA-1:0]) begin
                                            `uvm_error("VS", $sformatf("IOAIU<%=ncidx%> AXI Data Transfer ERROR3, Expected = %x, Actual = %x", 
                                                                        data_out[4*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA-1:0], data_in[4*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA-1:0]))
                                         end
                                         else begin
                                             `uvm_info("VS", "IOAIU<%=ncidx%> AXI Data Transfer Write-Read Test Match GOOD", UVM_LOW)
                                         end
                                      end
                                endcase
                            end
                          end

                          len = 3;
                          assert(std::randomize(data_out));
                          if ($test$plusargs("k_directed_test_all_coh")) begin
                          <% if(!(obj.AiuInfo[idx].fnNativeInterface == 'AXI4' && !obj.AiuInfo[idx].useCache)) { %>
                             `uvm_info("VS", $sformatf("IOAIU<%=ncidx%> AXI Write Coherent Addr=%x, data_out = %x", coh_addr, data_out[4*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA-1:0]), UVM_LOW)
                             write_ioaiu<%=ncidx%>(coh_addr, len, size, data_out[1023:0], 1);
                             read_ioaiu_rdonce<%=ncidx%>(coh_addr, len, size, data_in[1023:0]);
                            `uvm_info("VS", $sformatf("IOAIU<%=ncidx%> AXI Read Coherent Addr=%x, data_in = %x", coh_addr, data_in[4*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA-1:0]), UVM_LOW)
                             if (data_out[4*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA-1:0] != data_in[4*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA-1:0]) begin
                                `uvm_error("VS", $sformatf("IOAIU<%=ncidx%> AXI Data Transfer ERROR, Expected = %x, Actual = %x", 
                                                            data_out[4*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA-1:0], data_in[4*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA-1:0]))
                             end
                             else begin
                                `uvm_info("VS", "IOAIU<%=ncidx%> AXI Data Transfer Write-Read Test Match GOOD", UVM_LOW)
                             end
                          <% } %>
                          end

                          assert(std::randomize(data_out));
                          if ((k_directed_test_noncoh_addr_pct != 0) && (k_directed_test_coh_addr_pct != 0)) begin  // both non-coherent and coherent
                             randcase
                                k_directed_test_noncoh_addr_pct: begin
                                                                     `uvm_info("VS", $sformatf("IOAIU<%=ncidx%> AXI Write Non-coherent Addr=%x, data_out = %x", non_coh_addr, 
                                                                                               data_out[4*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA-1:0]), UVM_LOW)
                                                                     write_ioaiu<%=ncidx%>(non_coh_addr, len, size, data_out[1023:0], 0);
                                                                     read_ioaiu<%=ncidx%>(non_coh_addr, len, size, data_in[1023:0]);
                                                                    `uvm_info("VS", $sformatf("IOAIU<%=ncidx%> AXI Read Non-coherent Addr=%x, data_in = %x", non_coh_addr, data_in[4*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA-1:0]), UVM_LOW)
                                                                     if (data_out[4*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA-1:0] != data_in[4*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA-1:0]) begin
                                                                        `uvm_error("VS", $sformatf("IOAIU<%=ncidx%> AXI Data Transfer ERROR, Expected = %x, Actual = %x", 
                                                                                                   data_out[4*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA-1:0], data_in[4*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA-1:0]))
                                                                     end
                                                                     else begin
                                                                        `uvm_info("VS", "IOAIU<%=ncidx%> AXI Data Transfer Write-Read Test Match GOOD", UVM_LOW)
                                                                     end
                                                                 end
                                k_directed_test_coh_addr_pct:    begin
                                                                   <% if(!(obj.AiuInfo[idx].fnNativeInterface == 'AXI4' && !obj.AiuInfo[idx].useCache)) { %>
                                                                    `uvm_info("VS", $sformatf("IOAIU<%=ncidx%> AXI Write Coherent Addr=%x, data_out = %x", coh_addr, data_out[4*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA-1:0]), UVM_LOW)
                                                                    write_ioaiu<%=ncidx%>(coh_addr, len, size, data_out[1023:0], 1);
                                                                    read_ioaiu_rdonce<%=ncidx%>(coh_addr, len, size, data_in[1023:0]);
                                                                   `uvm_info("VS", $sformatf("IOAIU<%=ncidx%> AXI Read Coherent Addr=%x, data_in = %x", coh_addr, data_in[4*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA-1:0]), UVM_LOW)
                                                                    if (data_out[4*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA-1:0] != data_in[4*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA-1:0]) begin
                                                                       `uvm_error("VS", $sformatf("IOAIU<%=ncidx%> AXI Data Transfer ERROR, Expected = %x, Actual = %x", 
                                                                                                   data_out[4*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA-1:0], data_in[4*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA-1:0]))
                                                                    end
                                                                    else begin
                                                                       `uvm_info("VS", "IOAIU<%=ncidx%> AXI Data Transfer Write-Read Test Match GOOD", UVM_LOW)
                                                                    end
                                                                   <% } %>
                                                                 end
                             endcase

                          end
                       end  // for

                   end  // fork

     <% ncidx++;
    }
  } %>
  join
//`endif//`ifndef USE_VIP_SNPS
endtask : directed_write_read_test_all_aius

//************************************************************************************
// #Stimulus.FSYS.dwid_test.ChiaiuNonCoh
// #Stimulus.FSYS.dwid_test.ChiaiuCoh
task concerto_fullsys_direct_wr_rd_legacy_test::directed_write_read_test_all_chiaius_CONC_11133(uvm_phase phase);
bit bypass_data_in_data_out_checks=0;
bit use_single_mem_region_in_test=0;
int test_k_device_type_mem_pct=0;
bit is_device_mem = 0;

   if($value$plusargs("k_device_type_mem_pct=%d",test_k_device_type_mem_pct)) begin
       `uvm_info("VS", $psprintf("Setting k_device_type_mem_pct to %0d",test_k_device_type_mem_pct), UVM_LOW)
   end
   if(test_k_device_type_mem_pct==100) begin
       is_device_mem = 1;
   end else if(test_k_device_type_mem_pct==0) begin
       is_device_mem = 0;
   end else begin
       `uvm_info("VS", $psprintf("plusarg k_device_type_mem_pct is set to %0d. Please correct the value of plusarg k_device_type_mem_pct to 100 if Device memory test or 0 if Normal memory test",test_k_device_type_mem_pct), UVM_LOW)
   end
       
   `uvm_info("VS", "Directed Write/ Read Test All CHIAIUs", UVM_LOW)
    `ifndef USE_VIP_SNPS //existing flow will not run when USE_VIP_SNPS set
// removed don't use CHI BOOT anymore ///<% if ((found_csr_access_chiaiu > 0) && (found_csr_access_ioaiu > 0)) { %>
// removed don't use CHI BOOT anymore ///    if(boot_from_ioaiu == 1) begin
// removed don't use CHI BOOT anymore ///    end else begin
// removed don't use CHI BOOT anymore ///        foreach(m_chi0_vseq.all_dmi_dii_start_addr[x]) begin
// removed don't use CHI BOOT anymore ///          foreach(m_chi0_vseq.all_dmi_dii_start_addr[x][y]) begin
// removed don't use CHI BOOT anymore ///            all_dmi_dii_start_addr[x].push_back(m_chi0_vseq.all_dmi_dii_start_addr[x][y]);
// removed don't use CHI BOOT anymore ///          end
// removed don't use CHI BOOT anymore ///        end
// removed don't use CHI BOOT anymore ///        foreach(m_chi0_vseq.all_dii_start_addr[x]) begin
// removed don't use CHI BOOT anymore ///          foreach(m_chi0_vseq.all_dii_start_addr[x][y]) begin
// removed don't use CHI BOOT anymore ///            all_dii_start_addr[x].push_back(m_chi0_vseq.all_dii_start_addr[x][y]);
// removed don't use CHI BOOT anymore ///          end
// removed don't use CHI BOOT anymore ///        end
// removed don't use CHI BOOT anymore ///        foreach(m_chi0_vseq.all_dmi_start_addr[x]) begin
// removed don't use CHI BOOT anymore ///          foreach(m_chi0_vseq.all_dmi_start_addr[x][y]) begin
// removed don't use CHI BOOT anymore ///            all_dmi_start_addr[x].push_back(m_chi0_vseq.all_dmi_start_addr[x][y]);
// removed don't use CHI BOOT anymore ///          end
// removed don't use CHI BOOT anymore ///        end
// removed don't use CHI BOOT anymore ///    end // else: !if(boot_from_ioaiu == 1)
// removed don't use CHI BOOT anymore ///<% } else { %>
// removed don't use CHI BOOT anymore ///<%   if(found_csr_access_chiaiu > 0) { %>
// removed don't use CHI BOOT anymore ///        foreach(m_chi0_vseq.all_dmi_dii_start_addr[x]) begin
// removed don't use CHI BOOT anymore ///          foreach(m_chi0_vseq.all_dmi_dii_start_addr[x][y]) begin
// removed don't use CHI BOOT anymore ///            all_dmi_dii_start_addr[x].push_back(m_chi0_vseq.all_dmi_dii_start_addr[x][y]);
// removed don't use CHI BOOT anymore ///          end
// removed don't use CHI BOOT anymore ///        end
// removed don't use CHI BOOT anymore ///        foreach(m_chi0_vseq.all_dii_start_addr[x]) begin
// removed don't use CHI BOOT anymore ///          foreach(m_chi0_vseq.all_dii_start_addr[x][y]) begin
// removed don't use CHI BOOT anymore ///            all_dii_start_addr[x].push_back(m_chi0_vseq.all_dii_start_addr[x][y]);
// removed don't use CHI BOOT anymore ///          end
// removed don't use CHI BOOT anymore ///        end
// removed don't use CHI BOOT anymore ///        foreach(m_chi0_vseq.all_dmi_start_addr[x]) begin
// removed don't use CHI BOOT anymore ///          foreach(m_chi0_vseq.all_dmi_start_addr[x][y]) begin
// removed don't use CHI BOOT anymore ///            all_dmi_start_addr[x].push_back(m_chi0_vseq.all_dmi_start_addr[x][y]);
// removed don't use CHI BOOT anymore ///          end
// removed don't use CHI BOOT anymore ///        end
// removed don't use CHI BOOT anymore ///   <% } else { %>
// removed don't use CHI BOOT anymore ///   <% if (found_csr_access_ioaiu > 0) { %>
// removed don't use CHI BOOT anymore ///<% } } } %>
`endif
   
  if($test$plusargs("bypass_data_in_data_out_checks"))  bypass_data_in_data_out_checks=1;
  if($test$plusargs("use_single_mem_region_in_test"))   use_single_mem_region_in_test=1;
  <% for(idx = 0, cidx=0, ncidx=0; idx < obj.nAIUs; idx++) { 
    if((obj.AiuInfo[idx].fnNativeInterface.match('CHI'))) { %>
    `ifndef USE_VIP_SNPS //existing flow will not run when USE_VIP_SNPS set
                begin 
                    bit [511:0] data_in, data_in_1;
                    bit [511:0] data_out, data_out_1;
                    bit [ncoreConfigInfo::W_SEC_ADDR-1:0] addr;
                    bit [ncoreConfigInfo::W_SEC_ADDR-1:0] coh_addr;
                    bit [ncoreConfigInfo::W_SEC_ADDR-1:0] non_coh_addr;
                    bit [ncoreConfigInfo::W_SEC_ADDR-1:0] aligned_addr_wrt_total_bytes_lower, aligned_addr_wrt_total_bytes_upper;
                    int drop_bytes_for_device_mem;
                    bit [5:0] idx_val = <%=idx%>;
                    int data_size;
                    int wData;
                   `uvm_info("FULLSYS_TEST", "Start write/read on processor<%=idx%> : CHIAIU<%=cidx%>", UVM_NONE)

                    <% if (obj.AiuInfo[idx].wData == 128) { %>
                        wData = 128;
                    <% } else if (obj.AiuInfo[idx].wData == 256) { %> 
                         wData = 256;
                    <% } else { %>
                         wData = 512;
                    <% } %>
                    `uvm_info("VS", $sformatf("wData<%=cidx%> = %d", wData), UVM_LOW)
                       
                    if ($test$plusargs("k_directed_test_all_coh")) begin
                       m_chi<%=cidx%>_args.k_coh_addr_pct.set_value(100);
                    end
                    else begin
                       m_chi<%=cidx%>_args.k_coh_addr_pct.set_value(k_directed_test_coh_addr_pct);
                    end

                    if ($test$plusargs("k_directed_test_all_non_coh")) begin
                       m_chi<%=cidx%>_args.k_noncoh_addr_pct.set_value(100);
                    end 
                    else begin
                       m_chi<%=cidx%>_args.k_noncoh_addr_pct.set_value(k_directed_test_noncoh_addr_pct);
                    end
                    // m_chi<%=cidx%>_args.k_new_addr_pct.set_value(100);
                    m_chi<%=cidx%>_args.k_rd_noncoh_pct.set_value(0);
                    m_chi<%=cidx%>_args.k_rd_ldrstr_pct.set_value(0);
                    m_chi<%=cidx%>_args.k_rd_rdonce_pct.set_value(0);
                    if ($test$plusargs("k_directed_test_all_non_coh")) begin
                        m_chi<%=cidx%>_args.k_wr_noncoh_pct.set_value(100);
                        m_chi<%=cidx%>_args.k_rd_noncoh_pct.set_value(0);
                    end
                    else begin
                        m_chi<%=cidx%>_args.k_wr_noncoh_pct.set_value(k_directed_test_noncoh_addr_pct);
                    end
                    if ($test$plusargs("k_directed_test_all_coh")) begin
                        m_chi<%=cidx%>_args.k_wr_cohunq_pct.set_value(100);
                    end
                    else begin
                        m_chi<%=cidx%>_args.k_wr_cohunq_pct.set_value(k_directed_test_coh_addr_pct);
                    end
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
                    if ($test$plusargs("k_directed_test_all_non_coh")) begin
                      for(int crit_dw=0;crit_dw<8;crit_dw=crit_dw+1) begin // for each critical DW
                         for (int j = 1; j < 7; j++) begin
                           if($test$plusargs("k_directed_test_wr_rd_to_all_dmi")) begin
                             for(int all_dmi=0;all_dmi<(use_single_mem_region_in_test ? 1 :all_dmi_start_addr[<%=aiu_rpn[idx]%>].size());all_dmi=all_dmi+1) begin // for each DMI 
                               for (int i = 0; i < chi_num_trans; i++) begin
                                  m_chi<%=cidx%>_args.k_wr_noncoh_pct.set_value(100);
                                  m_chi<%=cidx%>_args.k_rd_noncoh_pct.set_value(0);
                                  m_chi<%=cidx%>_args.k_device_type_mem_pct.set_value(test_k_device_type_mem_pct);
                                  m_chi<%=cidx%>_vseq.set_unit_args(m_chi<%=cidx%>_args);
                                  assert(std::randomize(data_out));
                                  data_size = j;  // 2,4,8,16,32,64 bytes
                                  //non_coh_addr = ncoreConfigInfo::user_addrq[ncoreConfigInfo::NONCOH][i];
                                  //non_coh_addr[12:0] = {idx_val,7'b0000000};
                                  non_coh_addr = all_dmi_start_addr[<%=obj.AiuInfo[idx].rpn%>][all_dmi] + (i*64);
                                  non_coh_addr[5:3] = crit_dw;
                                  addr = non_coh_addr;
                                  if(is_device_mem) begin
                                      aligned_addr_wrt_total_bytes_lower =  (addr >> data_size) << data_size;
                                      aligned_addr_wrt_total_bytes_upper =  aligned_addr_wrt_total_bytes_lower + (2 ** data_size);
                                      drop_bytes_for_device_mem = addr - aligned_addr_wrt_total_bytes_lower;
                                  end

                                  `uvm_info("VS", $sformatf("CHI<%=cidx%> DMI Target GPR[%0d] Non-coherent Write Address = 0x%x,size = %d, Write Data = %x Critical DW=%0d",all_dmi, non_coh_addr, data_size, data_out,crit_dw), UVM_LOW) 
                                  m_chi<%=cidx%>_vseq.write_memory(non_coh_addr, data_out, data_size, 0);

                                  m_chi<%=cidx%>_args.k_wr_noncoh_pct.set_value(0);
                                  m_chi<%=cidx%>_args.k_rd_noncoh_pct.set_value(100);
                                  m_chi<%=cidx%>_args.k_device_type_mem_pct.set_value(test_k_device_type_mem_pct);
                                  m_chi<%=cidx%>_vseq.set_unit_args(m_chi<%=cidx%>_args);

                                  m_chi<%=cidx%>_vseq.read_memory(non_coh_addr, data_in, data_size, wData);
                                  `uvm_info("VS", $sformatf("CHI<%=cidx%> DMI Target GPR[%0d] Non-coherent Read Address = 0x%x,size = %d,  Read Data = %x Critical DW=%0d", all_dmi,non_coh_addr, data_size,data_in,crit_dw), UVM_LOW)

                                  for(int set_zero_bits=(8 * (2 ** data_size)); set_zero_bits<512; set_zero_bits=set_zero_bits+1) begin
                                      data_out[set_zero_bits] = 1'b0; data_in[set_zero_bits] = 1'b0;
                                  end
                                  case (data_size)
                                     1: begin
                                         if (data_out[15:0] != data_in[15:0]) begin
                                           if(!bypass_data_in_data_out_checks) 
                                               `uvm_error("VS", $sformatf("Data Mismatch CHI<%=cidx%>. Address = %x, xfer size 2B, Write Data = %x, Read Data = %x", non_coh_addr, data_out[15:0], data_in[15:0]))
                                           else
                                           `uvm_info("VS",$sformatf("Data Mismatch CHI<%=cidx%>. Address = %x, xfer size 2B, Write Data = %x, Read Data = %x", non_coh_addr, data_out[15:0], data_in[15:0]),UVM_NONE)
                                         end
                                         else begin
                                             `uvm_info("VS", $sformatf("CHIAIU<%=cidx%> Data Transfer Write-Read Test Match. DMI Target GPR[%0d] Address = %x, xfer size 2B, Write Data = %x, Read Data = %x Critical DW=%0d",all_dmi, non_coh_addr, data_out[15:0], data_in[15:0],crit_dw), UVM_LOW)
                                         end
                                        end
                                     2: begin
                                         if (data_out[31:0] != data_in[31:0]) begin
                                           if(!bypass_data_in_data_out_checks) 
                                               `uvm_error("VS", $sformatf("Data Mismatch CHI<%=cidx%>. Address = %x, xfer size 4B, Write Data = %x, Read Data = %x", non_coh_addr, data_out[31:0], data_in[31:0]))
                                           else
                                           `uvm_info("VS",$sformatf("Data Mismatch CHI<%=cidx%>. Address = %x, xfer size 4B, Write Data = %x, Read Data = %x", non_coh_addr, data_out[31:0], data_in[31:0]),UVM_NONE)
                                         end
                                         else begin
                                             `uvm_info("VS", $sformatf("CHIAIU<%=cidx%> Data Transfer Write-Read Test Match. DMI Target GPR[%0d] Address = %x, xfer size 4B, Write Data = %x, Read Data = %x Critical DW=%0d",all_dmi, non_coh_addr, data_out[31:0], data_in[31:0],crit_dw), UVM_LOW)
                                         end
                                        end
                                     3: begin
                                         if (data_out[63:0] != data_in[63:0]) begin
                                           if(!bypass_data_in_data_out_checks) 
                                               `uvm_error("VS", $sformatf("Data Mismatch CHI<%=cidx%>. Address = %x, xfer size 8B, Write Data = %x, Read Data = %x", non_coh_addr, data_out[63:0], data_in[63:0]))
                                           else
                                           `uvm_info("VS",$sformatf("Data Mismatch CHI<%=cidx%>. Address = %x, xfer size 8B, Write Data = %x, Read Data = %x", non_coh_addr, data_out[63:0], data_in[63:0]),UVM_NONE)
                                         end
                                         else begin
                                             `uvm_info("VS", $sformatf("CHIAIU<%=cidx%> Data Transfer Write-Read Test Match. DMI Target GPR[%0d] Address = %x, xfer size 8B, Write Data = %x, Read Data = %x Critical DW=%0d",all_dmi, non_coh_addr, data_out[63:0], data_in[63:0],crit_dw), UVM_LOW)
                                         end
                                        end
                                     4: begin
                                         if(wData>=128 && wData<=256) begin
                                         int zero_bits_lower_boundary, zero_bits_upper_boundary;
                                             zero_bits_lower_boundary = ((8 * (2 ** data_size)) - (8 * addr[3:0]));
                                             zero_bits_upper_boundary = (8 * (2 ** data_size));
                                             if(is_device_mem) begin
                                                 zero_bits_lower_boundary = zero_bits_lower_boundary - (drop_bytes_for_device_mem*8) + (8 * addr[3:0]);
                                             end
                                             if(zero_bits_lower_boundary!=zero_bits_upper_boundary)
                                             for(int set_zero_bits=zero_bits_lower_boundary;set_zero_bits<zero_bits_upper_boundary;  set_zero_bits=set_zero_bits+1) begin
                                                 data_out[set_zero_bits] = 1'b0; data_in[set_zero_bits] = 1'b0;
                                             end
                                         end else 
                                             `uvm_error("VS", $sformatf("Check CHI Data width must not be other than 128, 256"))
                                         if (data_out[127:0] != data_in[127:0]) begin
                                           if(!bypass_data_in_data_out_checks) 
                                               `uvm_error("VS", $sformatf("Data Mismatch CHI<%=cidx%>. Address = %x, xfer size 16B, Write Data = %x, Read Data = %x", non_coh_addr, data_out[127:0], data_in[127:0]))
                                           else
                                           `uvm_info("VS",$sformatf("Data Mismatch CHI<%=cidx%>. Address = %x, xfer size 16B, Write Data = %x, Read Data = %x", non_coh_addr, data_out[127:0], data_in[127:0]),UVM_NONE)
                                         end
                                         else begin
                                             `uvm_info("VS", $sformatf("CHIAIU<%=cidx%> Data Transfer Write-Read Test Match. DMI Target GPR[%0d] Address = %x, xfer size 16B, Write Data = %x, Read Data = %x Critical DW=%0d",all_dmi, non_coh_addr, data_out[127:0], data_in[127:0],crit_dw), UVM_LOW)
                                         end
                                        end
                                     5: begin
                                         if(wData>=128 && wData<=256) begin
                                         int zero_bits_lower_boundary, zero_bits_upper_boundary;
                                             zero_bits_lower_boundary = ((8 * (2 ** data_size)) - ((wData==256)?(8 * addr[4:0]):(8 * addr[3:0])));
                                             zero_bits_upper_boundary = (8 * (2 ** data_size));
                                             if(is_device_mem) begin
                                                 zero_bits_lower_boundary = zero_bits_lower_boundary - (drop_bytes_for_device_mem*8) + ((wData==256)?(8 * addr[4:0]):(8 * addr[3:0]));
                                             end
                                             if(zero_bits_lower_boundary!=zero_bits_upper_boundary)
                                             for(int set_zero_bits=zero_bits_lower_boundary;set_zero_bits<zero_bits_upper_boundary;  set_zero_bits=set_zero_bits+1) begin
                                                 data_out[set_zero_bits] = 1'b0; data_in[set_zero_bits] = 1'b0;
                                             end
                                         end else 
                                             `uvm_error("VS", $sformatf("Check CHI Data width must not be other than 128, 256"))
                                         if (data_out[255:0] != data_in[255:0]) begin
                                           if(!bypass_data_in_data_out_checks) 
                                               `uvm_error("VS", $sformatf("Data Mismatch CHI<%=cidx%>. Address = %x, xfer size 32B, Write Data = %x, Read Data = %x", non_coh_addr, data_out[255:0], data_in[255:0]))
                                           else
                                           `uvm_info("VS",$sformatf("Data Mismatch CHI<%=cidx%>. Address = %x, xfer size 32B, Write Data = %x, Read Data = %x", non_coh_addr, data_out[255:0], data_in[255:0]),UVM_NONE)
                                         end
                                         else begin
                                             `uvm_info("VS", $sformatf("CHIAIU<%=cidx%> Data Transfer Write-Read Test Match. DMI Target GPR[%0d] Address = %x, xfer size 32B, Write Data = %x, Read Data = %x Critical DW=%0d",all_dmi, non_coh_addr, data_out[255:0], data_in[255:0],crit_dw), UVM_LOW)
                                         end
                                        end
                                     6: begin
                                         if(wData>=128 && wData<=256) begin
                                         int zero_bits_lower_boundary, zero_bits_upper_boundary;
                                             zero_bits_lower_boundary = ((8 * (2 ** data_size)) - ((wData==256)?(8 * addr[4:0]):(8 * addr[3:0])));
                                             zero_bits_upper_boundary = (8 * (2 ** data_size));
                                             if(is_device_mem) begin
                                                 zero_bits_lower_boundary = zero_bits_lower_boundary - (drop_bytes_for_device_mem*8) + ((wData==256)?(8 * addr[4:0]):(8 * addr[3:0]));
                                             end
                                             if(zero_bits_lower_boundary!=zero_bits_upper_boundary)
                                             for(int set_zero_bits=zero_bits_lower_boundary;set_zero_bits<zero_bits_upper_boundary;  set_zero_bits=set_zero_bits+1) begin
                                                 data_out[set_zero_bits] = 1'b0; data_in[set_zero_bits] = 1'b0;
                                             end
                                         end else 
                                             `uvm_error("VS", $sformatf("Check CHI Data width must not be other than 128, 256"))
                                         if (data_out[511:0] != data_in[511:0]) begin
                                           if(!bypass_data_in_data_out_checks) 
                                               `uvm_error("VS", $sformatf("Data Mismatch CHI<%=cidx%>. Address = %x, xfer size 64B, Write Data = %x, Read Data = %x", non_coh_addr, data_out[511:0], data_in[511:0]))
                                           else
                                           `uvm_info("VS",$sformatf("Data Mismatch CHI<%=cidx%>. Address = %x, xfer size 64B, Write Data = %x, Read Data = %x", non_coh_addr, data_out[511:0], data_in[511:0]),UVM_NONE)
                                         end
                                         else begin
                                             `uvm_info("VS", $sformatf("CHIAIU<%=cidx%> Data Transfer Write-Read Test Match. DMI Target GPR[%0d] Address = %x, xfer size 64B, Write Data = %x, Read Data = %x Critical DW=%0d",all_dmi, non_coh_addr, data_out[511:0], data_in[511:0],crit_dw), UVM_LOW)
                                         end
                                        end
                                     default: begin
                                         `uvm_error("VS", $sformatf("Unsupported data size [CHI<%=cidx%>]%d", data_size))
                                        end
                                   endcase
                               end   //for i
                             end //for(all_dmi=0;all_dmi<all_dmi_start_addr[<%=obj.AiuInfo[idx].rpn%>].size();all_dmi=all_dmi+1) begin // for each DMI 
                           end //if($test$plusargs("k_directed_test_wr_rd_to_all_dmi")) begin
                           if($test$plusargs("k_directed_test_wr_rd_to_all_dii")) begin
                             for(int all_dii=0;all_dii<(use_single_mem_region_in_test ? 1: all_dii_start_addr[<%=aiu_rpn[idx]%>].size());all_dii=all_dii+1) begin // for each DMI 
                               for (int i = 0; i < chi_num_trans; i++) begin
                                  m_chi<%=cidx%>_args.k_wr_noncoh_pct.set_value(100);
                                  m_chi<%=cidx%>_args.k_rd_noncoh_pct.set_value(0);
                                  m_chi<%=cidx%>_args.k_device_type_mem_pct.set_value(test_k_device_type_mem_pct);
                                  m_chi<%=cidx%>_vseq.set_unit_args(m_chi<%=cidx%>_args);
                                  assert(std::randomize(data_out));
                                  data_size = j;  // 2,4,8,16,32,64 bytes
                                  //non_coh_addr = ncoreConfigInfo::user_addrq[ncoreConfigInfo::NONCOH][i];
                                  //non_coh_addr[12:0] = {idx_val,7'b0000000};
                                  non_coh_addr = all_dii_start_addr[<%=obj.AiuInfo[idx].rpn%>][all_dii]  + (i*64);
                                  non_coh_addr[5:3] = crit_dw;
                                  addr = non_coh_addr;
                                  if(is_device_mem) begin
                                      aligned_addr_wrt_total_bytes_lower =  (addr >> data_size) << data_size;
                                      aligned_addr_wrt_total_bytes_upper =  aligned_addr_wrt_total_bytes_lower + (2 ** data_size);
                                      drop_bytes_for_device_mem = addr - aligned_addr_wrt_total_bytes_lower;
                                  end

                                  `uvm_info("VS", $sformatf("CHI<%=cidx%> DII Target GPR[%0d] Non-coherent Write Address = 0x%x,size = %d,  Write Data = %x Critical DW=%0d", all_dmi_start_addr[<%=obj.AiuInfo[idx].rpn%>].size()+all_dii,non_coh_addr, data_size,data_out,crit_dw), UVM_LOW)
                                  m_chi<%=cidx%>_vseq.write_memory(non_coh_addr, data_out, data_size, 0);

                                  m_chi<%=cidx%>_args.k_wr_noncoh_pct.set_value(0);
                                  m_chi<%=cidx%>_args.k_rd_noncoh_pct.set_value(100);
                                  m_chi<%=cidx%>_args.k_device_type_mem_pct.set_value(test_k_device_type_mem_pct);
                                  m_chi<%=cidx%>_vseq.set_unit_args(m_chi<%=cidx%>_args);

                                  m_chi<%=cidx%>_vseq.read_memory(non_coh_addr, data_in, data_size, wData);
                                  `uvm_info("VS", $sformatf("CHI<%=cidx%> DII Target GPR[%0d] Non-coherent Read Address Address = 0x%x,size = %d,  Read Data = %x Critical DW=%0d", all_dmi_start_addr[<%=obj.AiuInfo[idx].rpn%>].size()+all_dii, non_coh_addr, data_size,data_in,crit_dw), UVM_LOW)

                                  for(int set_zero_bits=(8 * (2 ** data_size)); set_zero_bits<512; set_zero_bits=set_zero_bits+1) begin
                                      data_out[set_zero_bits] = 1'b0; data_in[set_zero_bits] = 1'b0;
                                  end
                                  case (data_size)
                                     1: begin
                                         if (data_out[15:0] != data_in[15:0]) begin
                                           if(!bypass_data_in_data_out_checks) 
                                               `uvm_error("VS", $sformatf("Data Mismatch CHI<%=cidx%>. Address = %x, xfer size 2B, Write Data = %x, Read Data = %x", non_coh_addr, data_out[15:0], data_in[15:0]))
                                           else
                                           `uvm_info("VS",$sformatf("Data Mismatch CHI<%=cidx%>. Address = %x, xfer size 2B, Write Data = %x, Read Data = %x", non_coh_addr, data_out[15:0], data_in[15:0]),UVM_NONE)
                                         end
                                         else begin
                                             `uvm_info("VS", $sformatf("CHIAIU<%=cidx%> Data Transfer Write-Read Test Match. DII Target GPR[%0d] Address = %x, xfer size 2B, Write Data = %x, Read Data = %x Critical DW=%0d",all_dmi_start_addr[<%=obj.AiuInfo[idx].rpn%>].size()+all_dii, non_coh_addr, data_out[15:0], data_in[15:0],crit_dw), UVM_LOW)
                                         end
                                        end
                                     2: begin
                                         if (data_out[31:0] != data_in[31:0]) begin
                                           if(!bypass_data_in_data_out_checks) 
                                               `uvm_error("VS", $sformatf("Data Mismatch CHI<%=cidx%>. Address = %x, xfer size 4B, Write Data = %x, Read Data = %x", non_coh_addr, data_out[31:0], data_in[31:0]))
                                           else
                                           `uvm_info("VS",$sformatf("Data Mismatch CHI<%=cidx%>. Address = %x, xfer size 4B, Write Data = %x, Read Data = %x", non_coh_addr, data_out[31:0], data_in[31:0]),UVM_NONE)
                                         end
                                         else begin
                                             `uvm_info("VS", $sformatf("CHIAIU<%=cidx%> Data Transfer Write-Read Test Match. DII Target GPR[%0d] Address = %x, xfer size 4B, Write Data = %x, Read Data = %x Critical DW=%0d",all_dmi_start_addr[<%=obj.AiuInfo[idx].rpn%>].size()+all_dii, non_coh_addr, data_out[31:0], data_in[31:0],crit_dw), UVM_LOW)
                                         end
                                        end
                                     3: begin
                                         if (data_out[63:0] != data_in[63:0]) begin
                                           if(!bypass_data_in_data_out_checks) 
                                               `uvm_error("VS", $sformatf("Data Mismatch CHI<%=cidx%>. Address = %x, xfer size 8B, Write Data = %x, Read Data = %x", non_coh_addr, data_out[63:0], data_in[63:0]))
                                           else
                                           `uvm_info("VS",$sformatf("Data Mismatch CHI<%=cidx%>. Address = %x, xfer size 8B, Write Data = %x, Read Data = %x", non_coh_addr, data_out[63:0], data_in[63:0]),UVM_NONE)
                                         end
                                         else begin
                                             `uvm_info("VS", $sformatf("CHIAIU<%=cidx%> Data Transfer Write-Read Test Match. DII Target GPR[%0d] Address = %x, xfer size 8B, Write Data = %x, Read Data = %x Critical DW=%0d",all_dmi_start_addr[<%=obj.AiuInfo[idx].rpn%>].size()+all_dii, non_coh_addr, data_out[63:0], data_in[63:0],crit_dw), UVM_LOW)
                                         end
                                        end
                                     4: begin
                                         if(wData>=128 && wData<=256) begin
                                         int zero_bits_lower_boundary, zero_bits_upper_boundary;
                                             zero_bits_lower_boundary = ((8 * (2 ** data_size)) - (8 * addr[3:0]));
                                             zero_bits_upper_boundary = (8 * (2 ** data_size));
                                             if(is_device_mem) begin
                                                 zero_bits_lower_boundary = zero_bits_lower_boundary - (drop_bytes_for_device_mem*8) + (8 * addr[3:0]);
                                             end
                                             if(zero_bits_lower_boundary!=zero_bits_upper_boundary)
                                             for(int set_zero_bits=zero_bits_lower_boundary;set_zero_bits<zero_bits_upper_boundary;  set_zero_bits=set_zero_bits+1) begin
                                                 data_out[set_zero_bits] = 1'b0; data_in[set_zero_bits] = 1'b0;
                                             end
                                         end else 
                                             `uvm_error("VS", $sformatf("Check CHI Data width must not be other than 128, 256"))
                                         if (data_out[127:0] != data_in[127:0]) begin
                                           if(!bypass_data_in_data_out_checks) 
                                               `uvm_error("VS", $sformatf("Data Mismatch CHI<%=cidx%>. Address = %x, xfer size 16B, Write Data = %x, Read Data = %x", non_coh_addr, data_out[127:0], data_in[127:0]))
                                           else
                                           `uvm_info("VS",$sformatf("Data Mismatch CHI<%=cidx%>. Address = %x, xfer size 16B, Write Data = %x, Read Data = %x", non_coh_addr, data_out[127:0], data_in[127:0]),UVM_NONE)
                                         end
                                         else begin
                                             `uvm_info("VS", $sformatf("CHIAIU<%=cidx%> Data Transfer Write-Read Test Match. DII Target GPR[%0d] Address = %x, xfer size 16B, Write Data = %x, Read Data = %x Critical DW=%0d",all_dmi_start_addr[<%=obj.AiuInfo[idx].rpn%>].size()+all_dii, non_coh_addr, data_out[127:0], data_in[127:0],crit_dw), UVM_LOW)
                                         end
                                        end
                                     5: begin
                                         if(wData>=128 && wData<=256) begin
                                         int zero_bits_lower_boundary, zero_bits_upper_boundary;
                                             zero_bits_lower_boundary = ((8 * (2 ** data_size)) - ((wData==256)?(8 * addr[4:0]):(8 * addr[3:0])));
                                             zero_bits_upper_boundary = (8 * (2 ** data_size));
                                             if(is_device_mem) begin
                                                 zero_bits_lower_boundary = zero_bits_lower_boundary - (drop_bytes_for_device_mem*8) + ((wData==256)?(8 * addr[4:0]):(8 * addr[3:0]));
                                             end
                                             if(zero_bits_lower_boundary!=zero_bits_upper_boundary)
                                             for(int set_zero_bits=zero_bits_lower_boundary;set_zero_bits<zero_bits_upper_boundary;  set_zero_bits=set_zero_bits+1) begin
                                                 data_out[set_zero_bits] = 1'b0; data_in[set_zero_bits] = 1'b0;
                                             end
                                         end else 
                                             `uvm_error("VS", $sformatf("Check CHI Data width must not be other than 128, 256"))
                                         if (data_out[255:0] != data_in[255:0]) begin
                                           if(!bypass_data_in_data_out_checks) 
                                               `uvm_error("VS", $sformatf("Data Mismatch CHI<%=cidx%>. Address = %x, xfer size 32B, Write Data = %x, Read Data = %x", non_coh_addr, data_out[255:0], data_in[255:0]))
                                           else
                                           `uvm_info("VS",$sformatf("Data Mismatch CHI<%=cidx%>. Address = %x, xfer size 32B, Write Data = %x, Read Data = %x", non_coh_addr, data_out[255:0], data_in[255:0]),UVM_NONE)
                                         end
                                         else begin
                                             `uvm_info("VS", $sformatf("CHIAIU<%=cidx%> Data Transfer Write-Read Test Match. DII Target GPR[%0d] Address = %x, xfer size 32B, Write Data = %x, Read Data = %x Critical DW=%0d",all_dmi_start_addr[<%=obj.AiuInfo[idx].rpn%>].size()+all_dii, non_coh_addr, data_out[255:0], data_in[255:0],crit_dw), UVM_LOW)
                                         end
                                        end
                                     6: begin
                                         if(wData>=128 && wData<=256) begin
                                         int zero_bits_lower_boundary, zero_bits_upper_boundary;
                                             zero_bits_lower_boundary = ((8 * (2 ** data_size)) - ((wData==256)?(8 * addr[4:0]):(8 * addr[3:0])));
                                             zero_bits_upper_boundary = (8 * (2 ** data_size));
                                             if(is_device_mem) begin
                                                 zero_bits_lower_boundary = zero_bits_lower_boundary - (drop_bytes_for_device_mem*8) + ((wData==256)?(8 * addr[4:0]):(8 * addr[3:0]));
                                             end
                                             if(zero_bits_lower_boundary!=zero_bits_upper_boundary)
                                             for(int set_zero_bits=zero_bits_lower_boundary;set_zero_bits<zero_bits_upper_boundary;  set_zero_bits=set_zero_bits+1) begin
                                                 data_out[set_zero_bits] = 1'b0; data_in[set_zero_bits] = 1'b0;
                                             end
                                         end else 
                                             `uvm_error("VS", $sformatf("Check CHI Data width must not be other than 128, 256"))
                                         if (data_out[511:0] != data_in[511:0]) begin
                                           if(!bypass_data_in_data_out_checks) 
                                               `uvm_error("VS", $sformatf("Data Mismatch CHI<%=cidx%>. Address = %x, xfer size 64B, Write Data = %x, Read Data = %x", non_coh_addr, data_out[511:0], data_in[511:0]))
                                           else
                                           `uvm_info("VS",$sformatf("Data Mismatch CHI<%=cidx%>. Address = %x, xfer size 64B, Write Data = %x, Read Data = %x", non_coh_addr, data_out[511:0], data_in[511:0]),UVM_NONE)
                                         end
                                         else begin
                                             `uvm_info("VS", $sformatf("CHIAIU<%=cidx%> Data Transfer Write-Read Test Match. DII Target GPR[%0d] Address = %x, xfer size 64B, Write Data = %x, Read Data = %x Critical DW=%0d",all_dmi_start_addr[<%=obj.AiuInfo[idx].rpn%>].size()+all_dii, non_coh_addr, data_out[511:0], data_in[511:0],crit_dw), UVM_LOW)
                                         end
                                        end
                                     default: begin
                                         `uvm_error("VS", $sformatf("Unsupported data size [CHI<%=cidx%>]%d", data_size))
                                        end
                                   endcase
                                end   //for i
                              end// for(int all_dii=0;all_dii<all_dii_start_addr[<%=obj.AiuInfo[idx].rpn%>].size();all_dii=all_dii+1) begin // for each DMI 
                            end //if($test$plusargs("k_directed_test_wr_rd_to_all_dii")) begin
                          end // for j
                      end // for(int crit_dw=0;crit_dw<8;crit_dw=crit_dw+1) begin
                    end  // k_directed_test_all_non_coh 

                    if ($test$plusargs("k_directed_test_all_coh")) begin
                      for(int crit_dw=0;crit_dw<8;crit_dw=crit_dw+1) begin // for each critical DW
                        for (int j = 6; j < 7; j++) begin  // need cacheline
                          for(int all_dmi=0;all_dmi<(use_single_mem_region_in_test ? 1 :all_dmi_start_addr[<%=obj.AiuInfo[idx].rpn%>].size());all_dmi=all_dmi+1) begin // for each DMI 
                           for (int i = 0; i < chi_num_trans; i++) begin
                             m_chi<%=cidx%>_args.k_wr_cohunq_pct.set_value(100);
                             m_chi<%=cidx%>_args.k_rd_rdonce_pct.set_value(0);
                             m_chi<%=cidx%>_vseq.set_unit_args(m_chi<%=cidx%>_args);
                             assert(std::randomize(data_out));
                             data_size = j;  // 2,4,8,16,32,64 bytes
                             //coh_addr = ncoreConfigInfo::user_addrq[ncoreConfigInfo::COH][i];
                             //coh_addr[12:0] = {idx_val, 7'b0000000};
                             coh_addr = all_dmi_start_addr[<%=obj.AiuInfo[idx].rpn%>][all_dmi]  + (i*64);
                             coh_addr[5:3] = crit_dw;
                             addr = coh_addr;
                             `uvm_info("VS", $sformatf("CHI<%=cidx%> DMI Target GPR[%0d] Write Address = 0x%x,size = %d, Write Data = %x Critical DW=%0d", all_dmi,coh_addr, data_size, data_out,crit_dw), UVM_LOW) 
                             m_chi<%=cidx%>_vseq.write_memory_coh(coh_addr, data_out, data_size, 0);

                             m_chi<%=cidx%>_args.k_wr_cohunq_pct.set_value(0);
                             m_chi<%=cidx%>_args.k_rd_rdonce_pct.set_value(100);
                             m_chi<%=cidx%>_vseq.set_unit_args(m_chi<%=cidx%>_args);

                             m_chi<%=cidx%>_vseq.read_memory_coh(coh_addr, data_in, data_size, wData,1);
                             `uvm_info("VS", $sformatf("CHI<%=cidx%> DMI Target GPR[%0d] Read Address = 0x%x,size = %d,  Read Data = %x Critical DW=%0d", all_dmi,coh_addr, data_size,data_in,crit_dw), UVM_LOW)

                             //for(int set_zero_bits=(8 * (2 ** data_size)); set_zero_bits<512; set_zero_bits=set_zero_bits+1) begin
                             //    data_out[set_zero_bits] = 1'b0; data_in[set_zero_bits] = 1'b0;
                             //end
                             case (data_size)
                                1: begin
                                    if (data_out[15:0] != data_in[15:0]) begin
                                      if(!bypass_data_in_data_out_checks) 
                                          `uvm_error("VS", $sformatf("Data Mismatch CHI<%=cidx%>. Address = %x, xfer size 2B, Write Data = %x, Read Data = %x", coh_addr, data_out[15:0], data_in[15:0]))
                                      else
                                      `uvm_info("VS",$sformatf("Data Mismatch CHI<%=cidx%>. Address = %x, xfer size 2B, Write Data = %x, Read Data = %x", coh_addr, data_out[15:0], data_in[15:0]),UVM_NONE)
                                    end
                                    else begin
                                        `uvm_info("VS", $sformatf("CHIAIU<%=cidx%> Data Transfer Write-Read Test Match. DMI Target GPR[%0d] Address = %x, xfer size 2B, Write Data = %x, Read Data = %x Critical DW=%0d",all_dmi, coh_addr, data_out[15:0], data_in[15:0],crit_dw), UVM_LOW)
                                    end
                                   end
                                2: begin
                                    if (data_out[31:0] != data_in[31:0]) begin
                                      if(!bypass_data_in_data_out_checks) 
                                          `uvm_error("VS", $sformatf("Data Mismatch CHI<%=cidx%>. Address = %x, xfer size 4B, Write Data = %x, Read Data = %x", coh_addr, data_out[31:0], data_in[31:0]))
                                      else
                                      `uvm_info("VS",$sformatf("Data Mismatch CHI<%=cidx%>. Address = %x, xfer size 4B, Write Data = %x, Read Data = %x", coh_addr, data_out[31:0], data_in[31:0]),UVM_NONE)
                                    end
                                    else begin
                                        `uvm_info("VS", $sformatf("CHIAIU<%=cidx%> Data Transfer Write-Read Test Match. DMI Target GPR[%0d] Address = %x, xfer size 4B, Write Data = %x, Read Data = %x Critical DW=%0d",all_dmi, coh_addr, data_out[31:0], data_in[31:0],crit_dw), UVM_LOW)
                                    end
                                   end
                                3: begin
                                    if (data_out[63:0] != data_in[63:0]) begin
                                      if(!bypass_data_in_data_out_checks) 
                                          `uvm_error("VS", $sformatf("Data Mismatch CHI<%=cidx%>. Address = %x, xfer size 8B, Write Data = %x, Read Data = %x", coh_addr, data_out[63:0], data_in[63:0]))
                                      else
                                      `uvm_info("VS",$sformatf("Data Mismatch CHI<%=cidx%>. Address = %x, xfer size 8B, Write Data = %x, Read Data = %x", coh_addr, data_out[63:0], data_in[63:0]),UVM_NONE)
                                    end
                                    else begin
                                        `uvm_info("VS", $sformatf("CHIAIU<%=cidx%> Data Transfer Write-Read Test Match. DMI Target GPR[%0d] Address = %x, xfer size 8B, Write Data = %x, Read Data = %x Critical DW=%0d",all_dmi, coh_addr, data_out[63:0], data_in[63:0],crit_dw), UVM_LOW)
                                    end
                                   end
                                4: begin
                                         //if(wData>=128 && wData<=256) begin
                                         //int zero_bits_lower_boundary, zero_bits_upper_boundary;
                                         //    zero_bits_lower_boundary = ((8 * (2 ** data_size)) - (8 * addr[3:0]));
                                         //    zero_bits_upper_boundary = (8 * (2 ** data_size));
                                         //    if(zero_bits_lower_boundary!=zero_bits_upper_boundary)
                                         //    for(int set_zero_bits=zero_bits_lower_boundary;set_zero_bits<zero_bits_upper_boundary;  set_zero_bits=set_zero_bits+1) begin
                                         //        data_out[set_zero_bits] = 1'b0; data_in[set_zero_bits] = 1'b0;
                                         //    end
                                         //end else 
                                         //    `uvm_error("VS", $sformatf("Check CHI Data width must not be other than 128, 256"))
                                    if (data_out[127:0] != data_in[127:0]) begin
                                      if(!bypass_data_in_data_out_checks) 
                                          `uvm_error("VS", $sformatf("Data Mismatch CHI<%=cidx%>. Address = %x, xfer size 16B, Write Data = %x, Read Data = %x", coh_addr, data_out[127:0], data_in[127:0]))
                                      else
                                      `uvm_info("VS",$sformatf("Data Mismatch CHI<%=cidx%>. Address = %x, xfer size 16B, Write Data = %x, Read Data = %x", coh_addr, data_out[127:0], data_in[127:0]),UVM_NONE)
                                    end
                                    else begin
                                        `uvm_info("VS", $sformatf("CHIAIU<%=cidx%> Data Transfer Write-Read Test Match. DMI Target GPR[%0d] Address = %x, xfer size 16B, Write Data = %x, Read Data = %x Critical DW=%0d",all_dmi, coh_addr, data_out[127:0], data_in[127:0],crit_dw), UVM_LOW)
                                    end
                                   end
                                5: begin
                                         //if(wData>=128 && wData<=256) begin
                                         //int zero_bits_lower_boundary, zero_bits_upper_boundary;
                                         //    zero_bits_lower_boundary = ((8 * (2 ** data_size)) - ((wData==256)?(8 * addr[4:0]):(8 * addr[3:0])));
                                         //    zero_bits_upper_boundary = (8 * (2 ** data_size));
                                         //    if(zero_bits_lower_boundary!=zero_bits_upper_boundary)
                                         //    for(int set_zero_bits=zero_bits_lower_boundary;set_zero_bits<zero_bits_upper_boundary;  set_zero_bits=set_zero_bits+1) begin
                                         //        data_out[set_zero_bits] = 1'b0; data_in[set_zero_bits] = 1'b0;
                                         //    end
                                         //end else 
                                         //    `uvm_error("VS", $sformatf("Check CHI Data width must not be other than 128, 256"))
                                    if (data_out[255:0] != data_in[255:0]) begin
                                      if(!bypass_data_in_data_out_checks) 
                                          `uvm_error("VS", $sformatf("Data Mismatch CHI<%=cidx%>. Address = %x, xfer size 32B, Write Data = %x, Read Data = %x", coh_addr, data_out[255:0], data_in[255:0]))
                                      else
                                      `uvm_info("VS",$sformatf("Data Mismatch CHI<%=cidx%>. Address = %x, xfer size 32B, Write Data = %x, Read Data = %x", coh_addr, data_out[255:0], data_in[255:0]),UVM_NONE)
                                    end
                                    else begin
                                        `uvm_info("VS", $sformatf("CHIAIU<%=cidx%> Data Transfer Write-Read Test Match. DMI Target GPR[%0d] Address = %x, xfer size 32B, Write Data = %x, Read Data = %x Critical DW=%0d",all_dmi, coh_addr, data_out[255:0], data_in[255:0],crit_dw), UVM_LOW)
                                    end
                                   end
                                6: begin
                                         //if(wData>=128 && wData<=256) begin
                                         //int zero_bits_lower_boundary, zero_bits_upper_boundary;
                                         //    zero_bits_lower_boundary = ((8 * (2 ** data_size)) - ((wData==256)?(8 * addr[4:0]):(8 * addr[3:0])));
                                         //    zero_bits_upper_boundary = (8 * (2 ** data_size));
                                         //    if(zero_bits_lower_boundary!=zero_bits_upper_boundary)
                                         //    for(int set_zero_bits=zero_bits_lower_boundary;set_zero_bits<zero_bits_upper_boundary;  set_zero_bits=set_zero_bits+1) begin
                                         //        data_out[set_zero_bits] = 1'b0; data_in[set_zero_bits] = 1'b0;
                                         //    end
                                         //end else 
                                         //    `uvm_error("VS", $sformatf("Check CHI Data width must not be other than 128, 256"))
                                    if (data_out[511:0] != data_in[511:0]) begin
                                      if(!bypass_data_in_data_out_checks) 
                                          `uvm_error("VS", $sformatf("Data Mismatch CHI<%=cidx%>. Address = %x, xfer size 64B, Write Data = %x, Read Data = %x", coh_addr, data_out[511:0], data_in[511:0]))
                                      else
                                          `uvm_info("VS",$sformatf("Data Mismatch CHI<%=cidx%>. Address = %x, xfer size 64B, Write Data = %x, Read Data = %x", coh_addr, data_out[511:0], data_in[511:0]),UVM_NONE)
                                    end
                                    else begin
                                        `uvm_info("VS", $sformatf("CHIAIU<%=cidx%> Data Transfer Write-Read Test Match. DMI Target GPR[%0d] Address = %x, xfer size 64B, Write Data = %x, Read Data = %x Critical DW=%0d",all_dmi, coh_addr, data_out[511:0], data_in[511:0],crit_dw), UVM_LOW)
                                    end
                                   end
                                default: begin
                                    `uvm_error("VS", $sformatf("Unsupported data size [CHI<%=cidx%>]%d", data_size))
                                   end
                              endcase
                           end   //for i
                          end //for(int all_dmi=0;all_dmi<all_dmi_start_addr[<%=obj.AiuInfo[idx].rpn%>].size();all_dmi=all_dmi+1) begin // for each DMI 
                        end // for j
                      end // for(int crit_dw=0;crit_dw<8;crit_dw=crit_dw+1) begin // for each critical DW
                    end  // k_directed_test_all_coh 


                   `uvm_info("FULLSYS_TEST", "Done write/ read  on processor<%=idx%> All AIUs: CHIAIU<%=cidx%>", UVM_NONE)
                   end // fork 
    `else //`ifndef USE_VIP_SNPS

    `endif //`ifndef USE_VIP_SNPS ... `else
     <% cidx++; %>
   <% } %>
  <% } %>
//`endif//`ifndef USE_VIP_SNPS
endtask : directed_write_read_test_all_chiaius_CONC_11133 


function bit [255:0] concerto_fullsys_direct_wr_rd_legacy_test::perform_atomic_op(string atomic_op, bit [63:0]atomic_initial_data, bit [63:0]atomic_txndata, int num_bytes=2,  bit [ncoreConfigInfo::W_SEC_ADDR-1:0] addr=0);
int mem_region;
int dmi_index ;
<% if(obj.nDMIs>0) { %>
int dmi_width[<%=obj.nDMIs%>];
<% for(pidx = 0; pidx < obj.nDMIs; pidx++) { %>
    bit [<%=obj.DmiInfo[pidx].wData%>-1:0] atomic_initial_data_tmp_<%=pidx%>, atomic_txndata_tmp_<%=pidx%>, atomic_initial_data_<%=pidx%>, atomic_txndata_<%=pidx%>;
    bit [ncoreConfigInfo::W_SEC_ADDR-1:0] byte_addr_<%=pidx%> = addr[<%=Math.log2(obj.DmiInfo[pidx].wData/8)%>-1:0];
<% } %>
<% for(pidx = 0; pidx < obj.nDMIs; pidx++) { %>
    dmi_width[<%=pidx%>]= <%=obj.DmiInfo[pidx].wData%>;
<% }} %>
  dmi_index = ncoreConfigInfo::map_addr2dmi_or_dii(addr, mem_region) - <%=obj.DmiInfo[0].FUnitId%>;
  //$display("concerto_fullsys_direct_wr_rd_legacy_test::perform_atomic_op::dmi_index %0d addr 0x%0h",dmi_index,addr);

  if(atomic_op == "BFM_ATOMICSTORE_STADD" || atomic_op == "BFM_ATOMICLOAD_LDADD") begin
      return(atomic_initial_data + atomic_txndata);
  end
  else if(atomic_op == "BFM_ATOMICSTORE_STCLR" || atomic_op == "BFM_ATOMICLOAD_LDCLR") begin
      return(atomic_initial_data & (~atomic_txndata));
  end
  else if(atomic_op == "BFM_ATOMICSTORE_STEOR" || atomic_op == "BFM_ATOMICLOAD_LDEOR") begin
      return(atomic_initial_data ^ atomic_txndata);
  end
  else if(atomic_op == "BFM_ATOMICSTORE_STSET" || atomic_op == "BFM_ATOMICLOAD_LDSET") begin
      return(atomic_initial_data | atomic_txndata);
  end
  else if(atomic_op == "BFM_ATOMICSTORE_STSMAX" || atomic_op == "BFM_ATOMICLOAD_LDSMAX") begin
<% if(obj.nDMIs>0) { %>
<% for(pidx = 0; pidx < obj.nDMIs; pidx++) { %>
    if(dmi_index==<%=pidx%>) begin
      atomic_txndata_<%=pidx%>      = atomic_txndata;
      atomic_initial_data_<%=pidx%> = atomic_initial_data;
      atomic_txndata_tmp_<%=pidx%>      = atomic_txndata_<%=pidx%> <<((dmi_width[dmi_index]/8)- num_bytes)*8;
      atomic_initial_data_tmp_<%=pidx%> = atomic_initial_data_<%=pidx%> <<((dmi_width[dmi_index]/8) - num_bytes)*8;
      return(($signed(atomic_txndata_tmp_<%=pidx%>) > $signed(atomic_initial_data_tmp_<%=pidx%>)) ? atomic_txndata: atomic_initial_data);
    end
<% }} %>
  end
  else if(atomic_op == "BFM_ATOMICSTORE_STMIN" || atomic_op == "BFM_ATOMICLOAD_LDMIN") begin
<% if(obj.nDMIs>0) { %>
<% for(pidx = 0; pidx < obj.nDMIs; pidx++) { %>
    if(dmi_index==<%=pidx%>) begin
      atomic_txndata_<%=pidx%>      = atomic_txndata;
      atomic_initial_data_<%=pidx%> = atomic_initial_data;
      atomic_txndata_tmp_<%=pidx%>      = atomic_txndata_<%=pidx%> <<((dmi_width[dmi_index]/8)- num_bytes)*8;
      atomic_initial_data_tmp_<%=pidx%> = atomic_initial_data_<%=pidx%> <<((dmi_width[dmi_index]/8) - num_bytes)*8;
      return(($signed(atomic_txndata_tmp_<%=pidx%>) < $signed(atomic_initial_data_tmp_<%=pidx%>)) ? atomic_txndata: atomic_initial_data);
    end
<% }} %>
      //return(($signed(atomic_txndata) < $signed(atomic_initial_data)) ? atomic_txndata: atomic_initial_data);
  end
  else if(atomic_op == "BFM_ATOMICSTORE_STUSMAX" || atomic_op == "BFM_ATOMICLOAD_LDUSMAX") begin
      return((atomic_txndata > atomic_initial_data) ? atomic_txndata: atomic_initial_data);
  end
  else if(atomic_op == "BFM_ATOMICSTORE_STUMIN" || atomic_op == "BFM_ATOMICLOAD_LDUMIN") begin
      return((atomic_txndata < atomic_initial_data) ? atomic_txndata: atomic_initial_data);
  end
endfunction : perform_atomic_op

task concerto_fullsys_direct_wr_rd_legacy_test::data_integrity_wr_rd();
 int width;
 int size;
 bit axi,has_cache ;
 bit [ncoreConfigInfo::W_SEC_ADDR -1:0] start_addr_noncoh_q[$];
 bit [ncoreConfigInfo::W_SEC_ADDR -1:0] end_addr_noncoh_q[$];
 int len;
 bit [4095:0] data_out;
 bit [4095:0] data_in;
 bit [ncoreConfigInfo::W_SEC_ADDR-1:0] coh_addr,temp_addr;
 bit [ncoreConfigInfo::W_SEC_ADDR -1:0] start_addr0,end_addr0,start_addr1,end_addr1,start_addr,end_addr;
    ncoreConfigInfo::intq noncoh_regionsq;
    ncore_memory_map m_mem;
 int que_size,_tmp;


addr_trans_mgr    addr_mgr;
addr_mgr = addr_trans_mgr::get_instance();
addr_mgr.gen_memory_map();

     m_mem = addr_mgr.get_memory_map_instance(); 
     noncoh_regionsq = m_mem.get_noncoh_mem_regions();


addr_mgr.get_dmi_unit_addr_range(start_addr0,end_addr0,start_addr1,end_addr1);
  
     foreach(noncoh_regionsq[indx]) begin
        addr_mgr.get_mem_region_bounds(noncoh_regionsq[indx], start_addr, end_addr);
        start_addr_noncoh_q.push_back(start_addr);
        end_addr_noncoh_q.push_back(end_addr);
        `uvm_info("func",$psprintf("noncoh_start_arry[%0d] is %0h  &  noncoh_end_arry[%0d] is %0h", indx, start_addr, indx, end_addr),UVM_LOW)
     end 
     que_size=start_addr_noncoh_q.size();
        `uvm_info("func",$psprintf("size %0d", que_size),UVM_LOW)



  <% for(idx = 0, ncidx=0; idx < obj.nAIUs; idx++) { 
        if(!(obj.AiuInfo[idx].fnNativeInterface.match("CHI") || (obj.AiuInfo[idx].fnNativeInterface == 'ACE') || (obj.AiuInfo[idx].fnNativeInterface == 'ACE-LITE') || (obj.AiuInfo[idx].fnNativeInterface == 'ACELITE-E'))) { %>
          axi=1;
         `uvm_info("VS", $sformatf("Inside AXI"), UVM_LOW)
     <% } else { %>  
	   axi=0;  
          `uvm_info("VS", $sformatf("Inside not AXI"), UVM_LOW)
     <% }
       
      
               if(!(obj.AiuInfo[idx].fnNativeInterface.match('CHI'))) { %>
for (int i=0; i < ioaiu_num_trans; i++) begin
    bit check_unconnected=0;
    bit [2:0] unit_unconnected;
                         
                          
                             `uvm_info("VS", $sformatf("IOAIU<%=ncidx%> Write HERE in method start_addr_noncoh_q:%0p end_addr_noncoh_q:%0p ",start_addr_noncoh_q,end_addr_noncoh_q), UVM_LOW)
                          
                                
                                 width = ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA;
                                size = $clog2(ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA/8); 
                                assert(std::randomize(data_out));
                                if ((axi==1)) begin
				    case(width)
                                         32: begin 
                                           std::randomize(len)with{len inside {1,3,7,15};};
                                         end       
                                         64: begin 
                                           std::randomize(len)with{len inside {1,3,7};};
                                         end
                                         128: begin 
                                           std::randomize(len)with{len inside {1,3};};
                                         end
                                         256: begin 
                                           len = 1; 
                                         end
                                      default: `uvm_error("VS", $sformatf("Unsupported Size WXDATA"))
   				endcase
                                end else begin
                                len = (((width/8)<64)?64/(width/8):1)-1; 
                                end
                                   
                                //coh_addr = ncoreConfigInfo::user_addrq[ncoreConfigInfo::COH][i];
                              // std::randomize(coh_addr)with{coh_addr inside {[start_addr1:end_addr1]};};
                        	std::randomize(_tmp)with{_tmp inside {[0:(que_size-1)]};};	
	                        std::randomize(coh_addr)with{coh_addr inside {[start_addr_noncoh_q[_tmp]:end_addr_noncoh_q[_tmp]]};};
                               
				case(width)
                                        32: begin 
                                           coh_addr[5:2] =  $urandom_range(0,15);
                                           coh_addr[1:0] = 2'b0;
                                         end       
                                      64: begin 
                                           coh_addr[5:3] =  $urandom_range(0,7);
                                           coh_addr[2:0] = 3'b0;
                                         end
                                      128: begin 
                                        coh_addr[5:4] = $urandom_range(0,3); 
                                           coh_addr[3:0] = 4'b0;
                                         end
                                      256: begin 
                                           coh_addr[5] =  $urandom_range(0,1);
                                           coh_addr[4:0] = 5'b0;
                                         end
                                      default: `uvm_error("VS", $sformatf("Unsupported Size WXDATA"))
       					
   				endcase

                               `uvm_info("VS", $sformatf("IOAIU<%=ncidx%> AXI Write coherent before  Addr=%x data_out = %x, width=%0d len:%0h size:%0h ", coh_addr, data_out[ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA-1:0], width,len,size), UVM_LOW)
                                write_ioaiu<%=ncidx%>(coh_addr, len, size, data_out[1023:0], 0);
                               `uvm_info("VS", $sformatf("IOAIU<%=ncidx%> AXI Write coherent after Addr=%x data_out = %x, width=%0d len:%0h size:%0h ", coh_addr, data_out[ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA-1:0], width,len,size), UVM_LOW) 
                                read_ioaiu<%=ncidx%>(coh_addr, len, size, data_in[1023:0]);
                               `uvm_info("VS", $sformatf("IOAIU<%=ncidx%> AXI Read coherent Addr=%x, data_in = %x",coh_addr, data_in[ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA-1:0]), UVM_LOW)
                                check_unconnected=ncoreConfigInfo::check_unmapped_add(coh_addr,<%=obj.AiuInfo[idx].FUnitId%>,unit_unconnected);
                                if(check_unconnected==0)begin
                                case (len)
                                   1: begin
                                         if (data_out[2*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA-1:0] != data_in[2*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA-1:0]) begin
                                            `uvm_error("VS", $sformatf("IOAIU<%=ncidx%> AXI Data Transfer ERROR0, Expected = %x, Actual = %x", 
                                                                        data_out[2*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA-1:0], data_in[2*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA-1:0]))
                                         end
                                         else begin
                                             `uvm_info("VS", "IOAIU<%=ncidx%> AXI Data Transfer Write-Read Test Match GOOD", UVM_LOW)
                                         end
                                      end
                                   3: begin
                                         if (data_out[4*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA-1:0] != data_in[4*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA-1:0]) begin
                                            `uvm_error("VS", $sformatf("IOAIU<%=ncidx%> AXI Data Transfer ERROR1, Expected = %x, Actual = %x", 
                                                                        data_out[4*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA-1:0], data_in[4*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA-1:0]))
                                         end
                                         else begin
                                             `uvm_info("VS", "IOAIU<%=ncidx%> AXI Data Transfer Write-Read Test Match GOOD", UVM_LOW)
                                         end
                                      end
                                   7: begin
                                         if (data_out[8*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA-1:0] != data_in[8*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA-1:0]) begin
                                            `uvm_error("VS", $sformatf("IOAIU<%=ncidx%> AXI Data Transfer ERROR2, Expected = %x, Actual = %x", 
                                                                        data_out[8*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA-1:0], data_in[8*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA-1:0]))
                                         end
                                         else begin
                                             `uvm_info("VS", "IOAIU<%=ncidx%> AXI Data Transfer Write-Read Test Match GOOD", UVM_LOW)
                                         end
                                      end
                                   15: begin
                                         if (data_out[16*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA-1:0] != data_in[16*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA-1:0]) begin
                                            `uvm_error("VS", $sformatf("IOAIU<%=ncidx%> AXI Data Transfer ERROR3, Expected = %x, Actual = %x", 
                                                                        data_out[16*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA-1:0], data_in[16*ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA-1:0]))
                                         end
                                         else begin
                                             `uvm_info("VS", "IOAIU<%=ncidx%> AXI Data Transfer Write-Read Test Match GOOD", UVM_LOW)
                                         end
                                      end
                                endcase
                                end else begin
                                    `uvm_info("VS", $sformatf("Trying to access unconnected slave dropping addr %0h",coh_addr), UVM_NONE)
                                end
                          end
   <% ncidx++; } %>
<% } %>
endtask:data_integrity_wr_rd

task concerto_fullsys_direct_wr_rd_legacy_test::ioaiu_wun_wlunq();
`ifdef USE_VIP_SNPS
 int width;
 int size;
 bit [ncoreConfigInfo::W_SEC_ADDR -1:0] start_addr_coh_q[$];
 bit [ncoreConfigInfo::W_SEC_ADDR -1:0] end_addr_coh_q[$];
 int len;
 bit [ncoreConfigInfo::W_SEC_ADDR-1:0] coh_addr,temp_addr;
 bit [ncoreConfigInfo::W_SEC_ADDR -1:0] start_addr0,end_addr0,start_addr1,end_addr1,start_addr,end_addr;
    ncoreConfigInfo::intq coh_regionsq;
    ncore_memory_map m_mem;
 int que_size,_tmp;

addr_trans_mgr    addr_mgr;
addr_mgr = addr_trans_mgr::get_instance();
addr_mgr.gen_memory_map();

     m_mem = addr_mgr.get_memory_map_instance(); 
     coh_regionsq = m_mem.get_coh_mem_regions();


addr_mgr.get_dmi_unit_addr_range(start_addr0,end_addr0,start_addr1,end_addr1);
  
     foreach(coh_regionsq[indx]) begin
        addr_mgr.get_mem_region_bounds(coh_regionsq[indx], start_addr, end_addr);
        start_addr_coh_q.push_back(start_addr);
        end_addr_coh_q.push_back(end_addr);
        `uvm_info("func",$psprintf("start_addr_coh_q[%0d] is %0h  &  coh_end_arry[%0d] is %0h", indx, start_addr, indx, end_addr),UVM_LOW)
     end 
     que_size=start_addr_coh_q.size();
        `uvm_info("func",$psprintf("size %0d", que_size),UVM_LOW)
<%if(numACEAiu>1){%>
fork
<%let abc = numACEAiu-1%>
  <% for(idx = 0, ncidx=0; idx < obj.nAIUs; idx++) { 
        if((obj.AiuInfo[idx].fnNativeInterface == 'ACE')) { %>
begin
for (int i=0; i < ioaiu_num_trans; i++) begin
    bit check_unconnected=0;
    bit [2:0] unit_unconnected;
                          
                             `uvm_info("VS", $sformatf("IOAIU<%=ncidx%> Write HERE in method start_addr_coh_q:%0p end_addr_coh_q:%0p ",start_addr_coh_q,end_addr_coh_q), UVM_LOW)
                          
                                
                                 width = ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA;
                                size = $clog2(ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA/8); 
                                len = (((width/8)<64)?64/(width/8):1)-1; 
                                   
	                        std::randomize(coh_addr)with{coh_addr inside {[start_addr_coh_q[0]:start_addr_coh_q[0]+'h3fff]};};
                               
				coh_addr[5:0] =  'd0;
                        fork 
                           begin

                               `uvm_info("VS", $sformatf("IOAIU<%=ncidx%> AXI READ coherent before  Addr=%x , width=%0d len:%0h size:%0h ", coh_addr, width,len,size), UVM_NONE)
                             read_ioaiu_rdunq<%=ncidx%>(coh_addr, len, size);
                           end
                           begin
                                 width = ioaiu<%=(ncidx+1>abc) ? (ncidx-1) : (ncidx+1)%>_axi_agent_pkg::WXDATA;
                                size = $clog2(width/8); 
                                len = (((width/8)<64)?64/(width/8):1)-1; 
                               `uvm_info("VS", $sformatf(" IOAIU<%=(ncidx+1>abc) ? (ncidx-1) : (ncidx+1)%> AXI READ coherent after Addr=%x  width=%0d len:%0h size:%0h ", coh_addr, width,len,size), UVM_NONE) 
                             read_ioaiu_rd_all<%=(ncidx+1>abc) ? (ncidx-1) : (ncidx+1)%>(coh_addr, len, size);
                           end
                         join
                               width = ioaiu<%=ncidx%>_axi_agent_pkg::WXDATA;
                                size = $clog2(width/8); 
                                len = (((width/8)<64)?64/(width/8):1)-1; 
                               `uvm_info("VS", $sformatf("IOAIU<%=ncidx%> AXI WRITE coherent after Addr=%x  width=%0d len:%0h size:%0h ", coh_addr, width,len,size), UVM_NONE) 

                                //write_ioaiu_wlunq<%=(ncidx+1>abc) ? (ncidx-1) : (ncidx+1)%>(coh_addr, len, size);
                              if ($test$plusargs("wrlunq_wrunq_test")) begin
                                write_ioaiu_wlunq<%=ncidx%>(coh_addr, len, size);
                              end
                              if ($test$plusargs("cache_maintainance_test")) begin
                                write_ioaiu_wrevict<%=ncidx%>(coh_addr, len, size);
                              end

                          end
end
   <% ncidx++; } %>
<% } %>
join
<% } %>
`endif //`ifdef USE_VIP_SNPS
endtask:ioaiu_wun_wlunq
