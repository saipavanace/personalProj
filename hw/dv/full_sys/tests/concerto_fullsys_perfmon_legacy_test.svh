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
let csrAccess_ioaiu;
let csrAccess_chiaiu;
let idxIoAiuWithPC = obj.nAIUs; // To get valid index of NCAIU with ProxyCache. Initialize to nAIUs
let numDmiWithSMC = 0; // Number of DMIs with SystemMemo/ryCache
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
// Assuming CHI AIU will appear first in AiuInfo in top.level.dv.json before IO-AIUs
let chi_idx=0;
let io_idx=0;
for(let pidx = 0; pidx < obj.nAIUs; pidx++) {
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
class concerto_fullsys_perfmon_legacy_test extends concerto_fullsys_test; 

  `uvm_component_utils(concerto_fullsys_perfmon_legacy_test)

   // UVM PHASE
   extern virtual task ncore_test_stimulus(uvm_phase phase);
 
  function new(string name = "concerto_fullsys_perfmon_legacy_test", uvm_component parent=null);
    super.new(name,parent);
  endfunction: new

  

endclass: concerto_fullsys_perfmon_legacy_test


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
task concerto_fullsys_perfmon_legacy_test::ncore_test_stimulus(uvm_phase phase);
   bit [<%=obj.AiuInfo[0].wAddr%>-1:0] cntvr_addr;
   bit [<%=obj.AiuInfo[0].wAddr%>-1:0] cntctrl_addr;
   int 	      data;
   bit [7:0] rpn = 0;
   bit [7:0] nAIUs; // Max 128
   bit [5:0] nDCEs; // Max 32
   bit [5:0] nDMIs; // Max 32
   bit [5:0] nDIIs; // Max 32 or nDIIs
   bit       nDVEs; // Max 1

 `uvm_info("PERFMON_LEGACY_TEST", "START ncore_test_stimulus", UVM_LOW)
  phase.raise_objection(this, "Start PERFMON LEGACY test");
  #100ns; 
        cntvr_addr          = ncore_config_pkg::ncoreConfigInfo::NRS_REGION_BASE ;
        cntctrl_addr        = ncore_config_pkg::ncoreConfigInfo::NRS_REGION_BASE ;
	      cntctrl_addr[19:12] = 8'hFF;
        cntctrl_addr[11:0]  = m_concerto_env.m_regs.sys_global_register_blk.GRBUNRRUCR.get_offset();
        data = 0;

<% 
   let read_function = 0;
   let write_function = 0;
   if(found_csr_access_chiaiu  > 0) {
     read_function = "rw_tsks.read_csr_chi"+csrAccess_chiaiu;
     write_function = "rw_tsks.write_csr_chi"+csrAccess_chiaiu;
   } else {
     read_function = "rw_tsks.read_csr"+csrAccess_ioaiu;
     write_function = "rw_tsks.write_csr"+csrAccess_ioaiu;
   } 
%>


        <%=read_function%>(cntctrl_addr,data);
        if(data == 0) begin
          `uvm_error("perf_cnt_test","NRRUCR register is 0")
        end
    	nAIUs = data[ 7: 0];
    	nDCEs = data[13: 8];
    	nDMIs = data[19:14];
    	nDIIs = data[25:20];
    	nDVEs = data[26:26];
	
	<% if (obj.AiuInfo[0].nPerfCounters) { %> 
 <% for(let idx = 0; idx < (nAIUs + nDCEs + nDMIs + nDIIs + nDVEs); idx++){
        let Irq_If_name ; let PerfCounter_exist;%> 
	    cntvr_addr[19:12]	  = rpn;
	    cntctrl_addr[19:12]   = rpn;
	<%if(idx < nAIUs) {
	  Irq_If_name = obj.AiuInfo[idx].strRtlNamePrefix; //nPerfCounters
	  if((obj.AiuInfo[idx].fnNativeInterface.match("CHI")) && (obj.AiuInfo[idx].nPerfCounters > 0)) {%>
	    cntvr_addr[11: 0]	  = m_concerto_env.m_regs.<%=obj.AiuInfo[idx].strRtlNamePrefix%>.CAIUCNTVR0.get_address();
	    cntctrl_addr[11: 0]   = m_concerto_env.m_regs.<%=obj.AiuInfo[idx].strRtlNamePrefix%>.CAIUCNTCR0.get_address();
       <% } else if((obj.AiuInfo[idx].nPerfCounters > 0)){%>
       <% if (obj.AiuInfo[idx].nNativeInterfacePorts>1 ) {%>
       cntvr_addr[11: 0]	  = m_concerto_env.m_regs.<%=obj.AiuInfo[idx].strRtlNamePrefix%>_0.XAIUCNTVR0.get_address();
       cntctrl_addr[11: 0]   = m_concerto_env.m_regs.<%=obj.AiuInfo[idx].strRtlNamePrefix%>_0.XAIUCNTCR0.get_address();
       <% } else {%>
       cntvr_addr[11: 0]	  = m_concerto_env.m_regs.<%=obj.AiuInfo[idx].strRtlNamePrefix%>.XAIUCNTVR0.get_address();
       cntctrl_addr[11: 0]   = m_concerto_env.m_regs.<%=obj.AiuInfo[idx].strRtlNamePrefix%>.XAIUCNTCR0.get_address();
       <% } %>
       <% }%>
       <% PerfCounter_exist = 1;%>
     <% } else if (nAIUs <= idx && idx < nAIUs+nDCEs && (obj.DceInfo[idx-nAIUs].nPerfCounters > 0)){
	    Irq_If_name = obj.DceInfo[idx-nAIUs].strRtlNamePrefix; %>
	    cntvr_addr[11: 0]	  = m_concerto_env.m_regs.<%=obj.DceInfo[idx-nAIUs].strRtlNamePrefix%>.DCECNTVR0.get_address();
	    cntctrl_addr[11: 0]   = m_concerto_env.m_regs.<%=obj.DceInfo[idx-nAIUs].strRtlNamePrefix%>.DCECNTCR0.get_address();
       <% PerfCounter_exist = 1;%>
     <% } else if (nAIUs+nDCEs <= idx && idx < nAIUs+nDCEs+nDMIs && (obj.DmiInfo[idx-nAIUs-nDCEs].nPerfCounters > 0)){
	    Irq_If_name = obj.DmiInfo[idx-nAIUs-nDCEs].strRtlNamePrefix; %>
	    cntvr_addr[11: 0]	  = m_concerto_env.m_regs.<%=obj.DmiInfo[idx-nAIUs-nDCEs].strRtlNamePrefix%>.DMICNTVR0.get_address();
	    cntctrl_addr[11: 0]   = m_concerto_env.m_regs.<%=obj.DmiInfo[idx-nAIUs-nDCEs].strRtlNamePrefix%>.DMICNTCR0.get_address();
       <% PerfCounter_exist = 1;%>
     <% } else if (nAIUs+nDCEs+nDMIs <= idx && idx < nAIUs+nDCEs+nDMIs+nDIIs && (obj.DiiInfo[idx-nAIUs-nDCEs-nDMIs].nPerfCounters > 0)) {
            Irq_If_name           = obj.DiiInfo[idx-nAIUs-nDCEs-nDMIs].strRtlNamePrefix;  %>
	    cntvr_addr[11: 0]	  = m_concerto_env.m_regs.<%=obj.DiiInfo[idx-nAIUs-nDCEs-nDMIs].strRtlNamePrefix%>.DIICNTVR0.get_address();
	    cntctrl_addr[11: 0]   = m_concerto_env.m_regs.<%=obj.DiiInfo[idx-nAIUs-nDCEs-nDMIs].strRtlNamePrefix%>.DIICNTCR0.get_address();
       <% PerfCounter_exist = 1;%>
     <% } else if (nAIUs+nDCEs+nDMIs+nDIIs <= idx && idx < nAIUs+nDCEs+nDMIs+nDIIs+nDVEs && (obj.DveInfo[idx-nAIUs-nDCEs-nDMIs-nDIIs].nPerfCounters > 0)){
	    Irq_If_name = obj.DveInfo[idx-nAIUs-nDCEs-nDMIs-nDIIs].strRtlNamePrefix; %>
	    cntvr_addr[11: 0]	  = m_concerto_env.m_regs.<%=obj.DveInfo[idx-nAIUs-nDCEs-nDMIs-nDIIs].strRtlNamePrefix%>.DVECNTVR0.get_address();
	    cntctrl_addr[11: 0]   = m_concerto_env.m_regs.<%=obj.DveInfo[idx-nAIUs-nDCEs-nDMIs-nDIIs].strRtlNamePrefix%>.DVECNTCR0.get_address();
       <% PerfCounter_exist = 1;%>
     <% } else {  %>
       <% PerfCounter_exist = 0;%>
     <%}%>

     <% if(PerfCounter_exist==1) //if(Irq_If_name != "sys_dii_check") { %>
	//set CNTVR  = 2**32 -2
	data = {32{1'b1}} - 2;
        <%=write_function%>(cntvr_addr,data);
	//set CNTCR configure  event2 = Div16 (30) and event1 = 0, control = 0, ssr = 0, interrupt enabled, counter enabled
	data = 32'h1E0005;
	<%=write_function%>(cntctrl_addr,data);
   #100ns
	//wait IRq_C of the block
      	`uvm_info("perf_cnt_test",$sformatf("waiting for overflow interrupt for <%=Irq_If_name%>"),UVM_NONE);
      	fork : fork_<%=Irq_If_name%>
      	  begin
      	    wait(tb_top.m_irq_if_<%=Irq_If_name%>.c === 1) begin
      	     `uvm_info("perf_cnt_test",$sformatf("overflow interrupt was received for <%=Irq_If_name%>"),UVM_NONE);
	     //clear interrupt
	     data = 32'h1E0007;
	     <%=write_function%>(cntctrl_addr,data);
	     wait(tb_top.m_irq_if_<%=Irq_If_name%>.c === 0) begin
	     `uvm_info("perf_cnt_test",$sformatf("overflow interrupt was cleared for <%=Irq_If_name%>"),UVM_NONE);
	     end
      	    end
	  end
	  begin
	    #1ms `uvm_error("perf_cnt_test",$sformatf("Timeout: Overflow inerrupt was not received for <%=Irq_If_name%>"));
	  end
      	join_any
        disable fork_<%=Irq_If_name%>;
	rpn++;
 <% } %>	 
 <% } // if nPerfCounters >0%>             

//super.main_phase(phase); // launch txn

//ev_sim_done.trigger(null);
exec_inhouse_seq(phase);
wait_seq_totaly_done(phase);
ev_sim_done.trigger();

phase.drop_objection(this, "END PERFMON LEGACY test");
`uvm_info("PERFMON_LEGACY_TEST", "END ncore_test_stimulus", UVM_LOW)
endtask:ncore_test_stimulus

////////////////////////////////////////////////////////////////////
//#######  #     #  #     #   #####   #######  ###  #######  #     #  
//#        #     #  ##    #  #     #     #      #   #     #  ##    #  
//#        #     #  # #   #  #           #      #   #     #  # #   #  
//#####    #     #  #  #  #  #           #      #   #     #  #  #  #  
//#        #     #  #   # #  #           #      #   #     #  #   # #  
//#        #     #  #    ##  #     #     #      #   #     #  #    ##  
//#         #####   #     #   #####      #     ###  #######  #     #  
/////////////////////////////////
