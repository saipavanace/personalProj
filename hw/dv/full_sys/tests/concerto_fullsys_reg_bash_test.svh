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
const initiatorAgents   = obj.AiuInfo.length ;
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
    if((obj.AiuInfo[pidx].fnNativeInterface.match('CHI'))) 
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
                           if((item.fnNativeInterface.match('CHI'))) {
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
                           if(!(item.fnNativeInterface.match('CHI'))) {
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
class concerto_fullsys_reg_bash_test extends concerto_fullsys_test; 

  `uvm_component_utils(concerto_fullsys_reg_bash_test)
  
  bit csr_test_from_ioaiu;
   <% for(let idx = 0, qidx=0; idx < obj.nAIUs; idx++) { 
if(!(obj.AiuInfo[idx].fnNativeInterface.match('CHI'))) {
if(obj.AiuInfo[idx].fnCsrAccess == 1) { %>
  ioaiu<%=qidx%>_axi_agent_pkg::axi_virtual_sequencer  m_ioaiu_vseqr<%=qidx%>;
   <% } 
 qidx++; }
 } %>
  function new(string name = "concerto_fullsys_reg_bash_test", uvm_component parent=null);
    super.new(name,parent);
  endfunction: new

  // UVM PHASE
   extern virtual function void end_of_elaboration_phase (uvm_phase phase);
   extern virtual task ncore_test_stimulus (uvm_phase phase);
  // SPECIFIC TASKS & FUNCTION
   extern virtual task run_fsys_reg_bit_bash_seq();
   extern virtual task run_fsys_reg_reset_value_seq();
 
   uvm_reg_bit_bash_seq reg_bit_bash_seq;
   uvm_reg_hw_reset_seq reg_hw_reset_seq;

endclass: concerto_fullsys_reg_bash_test
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
function void concerto_fullsys_reg_bash_test::end_of_elaboration_phase (uvm_phase phase); 
 super.end_of_elaboration_phase(phase);
  <% for(let idx = 0, qidx=0; idx < obj.nAIUs; idx++) { 
if(!(obj.AiuInfo[idx].fnNativeInterface.match('CHI'))) {
if(obj.AiuInfo[idx].fnCsrAccess == 1) { %>
 if(!(uvm_config_db#(ioaiu<%=qidx%>_axi_agent_pkg::axi_virtual_sequencer)::get(.cntxt( null ),.inst_name( "" ),.field_name( "m_ioaiu_vseqr<%=qidx%>[0]" ),.value( m_ioaiu_vseqr<%=qidx%> ) ))) begin
 `uvm_error(get_name(), "Cannot get m_ioaiu_vseqr<%=qidx%>")
 end
  <% } 
 qidx++; }
 } %>
endfunction:end_of_elaboration_phase

task concerto_fullsys_reg_bash_test::ncore_test_stimulus (uvm_phase phase); 
   
  `uvm_info("CONCERTO_FULLSYS_REG_BASH_TEST", "START ncore_test_stimulus", UVM_LOW)
  #100ns;
  phase.raise_objection(this, "Start REG_BASH_TEST");

 if (!test_cfg.disable_boot_tasks && !test_cfg.k_csr_access_only)
      `uvm_error("REG_BASH_TEST", "you must use +disable_boot_tasks=1 or +k_csr_access_only=1")
 
 if($test$plusargs("use_fsys_reg_bit_bash_seq")) begin
           run_fsys_reg_bit_bash_seq();
           #100ns;
 end else if($test$plusargs("use_fsys_reg_reset_value_seq")) begin
           run_fsys_reg_reset_value_seq();
           #100ns;
 end
ev_sim_done.trigger(null);

phase.drop_objection(this, "END REG_BASH_TEST");
`uvm_info("CONCERTO_FULLSYS_REG_BASH_TEST", "END ncore_test_stimulus", UVM_LOW)
endtask:ncore_test_stimulus

////////////////////////////////////////////////////////////////////
//#######  #     #  #     #   #####   #######  ###  #######  #     #  
//#        #     #  ##    #  #     #     #      #   #     #  ##    #  
//#        #     #  # #   #  #           #      #   #     #  # #   #  
//#####    #     #  #  #  #  #           #      #   #     #  #  #  #  
//#        #     #  #   # #  #           #      #   #     #  #   # #  
//#        #     #  #    ##  #     #     #      #   #     #  #    ##  
//#         #####   #     #   #####      #     ###  #######  #     #  
////////////////////////////////////////////////////////////////////

//#Check.FSYS.csr.bit_bash_from_ioaiu
//#Check.FSYS.csr.bit_bash_from_chiaiu
task concerto_fullsys_reg_bash_test::run_fsys_reg_bit_bash_seq();
`ifndef USE_VIP_SNPS
<%  if(numIoAiu>0) { %>
  ioaiu_reg_frontdoor ioaiu_frontdoor;
<%  } %>
<%  if(numChiAiu>0) { %>
  chiaiu_reg_frontdoor chiaiu_frontdoor;
<%  } %>
  uvm_reg regs[$];
`endif
  ext_uvm_reg_bit_bash_seq   csr_seq;
<%  if(numChiAiu>0 && numIoAiu>0) { %>
    if (!$value$plusargs("csr_test_from_ioaiu=%b",csr_test_from_ioaiu)) begin
        csr_test_from_ioaiu= 0;
    end
<%  } else if(numIoAiu>0 && numChiAiu==0) { %>
        csr_test_from_ioaiu= 1;
<%  } else if(numChiAiu>0 && numIoAiu==0) { %>
        csr_test_from_ioaiu= 0;
<%  } %>
    csr_seq = ext_uvm_reg_bit_bash_seq::type_id::create("csr_seq");
    csr_seq.model = m_concerto_env.m_regs;
`ifndef USE_VIP_SNPS
    if(csr_test_from_ioaiu) begin
<%  if(numIoAiu>0) { %>
      ioaiu_frontdoor = ioaiu_reg_frontdoor::type_id::create("ioaiu_frontdoor");
      m_concerto_env.m_regs.get_registers(regs,UVM_HIER);
      foreach (regs[rg]) begin
        regs[rg].reset(); 
        regs[rg].set_frontdoor(ioaiu_frontdoor); 
      end
<%  } %>
    end else begin
<%  if(numChiAiu>0) { %>
      chiaiu_frontdoor = chiaiu_reg_frontdoor::type_id::create("chiaiu_frontdoor");
       m_concerto_env.m_regs.get_registers(regs,UVM_HIER);
       foreach (regs[rg]) begin
        regs[rg].reset(); 
         regs[rg].set_frontdoor(chiaiu_frontdoor); 
       end
<%  } %>
    end
`endif

    <%let largest_index = (obj.nDCEs > obj.nDMIs) ? ( (obj.nDCEs > obj.nDIIs) ? obj.nDCEs : obj.nDIIs ) : ( (obj.nDMIs > obj.nDIIs) ? obj.nDMIs : obj.nDIIs );%>
<% for(let idx = 0; idx < obj.nAIUs; idx++) {
     if((obj.AiuInfo[idx].fnNativeInterface.match('CHI'))) {%>
    uvm_resource_db#(bit)::set({"REG::", m_concerto_env.m_regs.<%=obj.AiuInfo[idx].strRtlNamePrefix%>.CAIUCCTRLR.get_full_name()}, "NO_REG_BIT_BASH_TEST",1,this);
    uvm_resource_db#(bit)::set({"REG::", m_concerto_env.m_regs.<%=obj.AiuInfo[idx].strRtlNamePrefix%>.CAIUTCR.get_full_name()}, "NO_REG_BIT_BASH_TEST",1,this);
    uvm_resource_db#(bit)::set({"REG::", m_concerto_env.m_regs.<%=obj.AiuInfo[idx].strRtlNamePrefix%>.NRSBAR.get_full_name()}, "NO_REG_BIT_BASH_TEST",1,this);
    uvm_resource_db#(bit)::set({"REG::", m_concerto_env.m_regs.<%=obj.AiuInfo[idx].strRtlNamePrefix%>.NRSBLR.get_full_name()}, "NO_REG_BIT_BASH_TEST",1,this);
    uvm_resource_db#(bit)::set({"REG::", m_concerto_env.m_regs.<%=obj.AiuInfo[idx].strRtlNamePrefix%>.CAIUBRAR.get_full_name()}, "NO_REG_BIT_BASH_TEST",1,this);
    uvm_resource_db#(bit)::set({"REG::", m_concerto_env.m_regs.<%=obj.AiuInfo[idx].strRtlNamePrefix%>.CAIUBRBLR.get_full_name()}, "NO_REG_BIT_BASH_TEST",1,this);
    uvm_resource_db#(bit)::set({"REG::", m_concerto_env.m_regs.<%=obj.AiuInfo[idx].strRtlNamePrefix%>.CAIUTAR.get_full_name()}, "NO_REG_BIT_BASH_TEST",1,this);
    uvm_resource_db#(bit)::set({"REG::", m_concerto_env.m_regs.<%=obj.AiuInfo[idx].strRtlNamePrefix%>.CAIUNRSAR.get_full_name()}, "NO_REG_BIT_BASH_TEST",1,this);
    <%for(let j=0;j<largest_index;j++) {%>
    uvm_resource_db#(bit)::set({"REG::", m_concerto_env.m_regs.<%=obj.AiuInfo[idx].strRtlNamePrefix%>.CAIUCCR<%=j%>.get_full_name()}, "NO_REG_BIT_BASH_TEST",1,this);
    <%} %>

    <%} else {
  for (let mpu_io = 0; mpu_io < obj.AiuInfo[idx].nNativeInterfacePorts; mpu_io++){%>
    //AE to be rechecked
    <%for(let pidx = 0; pidx < 8; ++pidx){
     if(obj.AiuInfo[idx].nNativeInterfacePorts > 1){%>
    uvm_resource_db#(bit)::set({"REG::", m_concerto_env.m_regs.<%=obj.AiuInfo[idx].strRtlNamePrefix%>_<%=mpu_io%>.XAIUEDR<%=pidx%>.get_full_name()}, "NO_REG_BIT_BASH_TEST",1,this);
    <%} else { %>
    uvm_resource_db#(bit)::set({"REG::", m_concerto_env.m_regs.<%=obj.AiuInfo[idx].strRtlNamePrefix%>.XAIUEDR<%=pidx%>.get_full_name()}, "NO_REG_BIT_BASH_TEST",1,this);
    <%}}%>
    <% if (obj.AiuInfo[idx].fnNativeInterface == 'AXI4' && obj.AiuInfo[idx].useCache == 1){
     if(obj.AiuInfo[idx].nNativeInterfacePorts > 1){%>
    uvm_resource_db#(bit)::set({"REG::", m_concerto_env.m_regs.<%=obj.AiuInfo[idx].strRtlNamePrefix%>_<%=mpu_io%>.XAIUPCISR.get_full_name()}, "NO_REG_BIT_BASH_TEST",1,this);
    uvm_resource_db#(bit)::set({"REG::", m_concerto_env.m_regs.<%=obj.AiuInfo[idx].strRtlNamePrefix%>_<%=mpu_io%>.XAIUPCMAR.get_full_name()}, "NO_REG_BIT_BASH_TEST",1,this);
    uvm_resource_db#(bit)::set({"REG::", m_concerto_env.m_regs.<%=obj.AiuInfo[idx].strRtlNamePrefix%>_<%=mpu_io%>.XAIUPCMCR.get_full_name()}, "NO_REG_BIT_BASH_TEST",1,this);
    uvm_resource_db#(bit)::set({"REG::", m_concerto_env.m_regs.<%=obj.AiuInfo[idx].strRtlNamePrefix%>_<%=mpu_io%>.XAIUPCTCR.get_full_name()}, "NO_REG_BIT_BASH_TEST",1,this);
    <%} else { %>
    uvm_resource_db#(bit)::set({"REG::", m_concerto_env.m_regs.<%=obj.AiuInfo[idx].strRtlNamePrefix%>.XAIUPCISR.get_full_name()}, "NO_REG_BIT_BASH_TEST",1,this);
    uvm_resource_db#(bit)::set({"REG::", m_concerto_env.m_regs.<%=obj.AiuInfo[idx].strRtlNamePrefix%>.XAIUPCMAR.get_full_name()}, "NO_REG_BIT_BASH_TEST",1,this);
    uvm_resource_db#(bit)::set({"REG::", m_concerto_env.m_regs.<%=obj.AiuInfo[idx].strRtlNamePrefix%>.XAIUPCMCR.get_full_name()}, "NO_REG_BIT_BASH_TEST",1,this);
    uvm_resource_db#(bit)::set({"REG::", m_concerto_env.m_regs.<%=obj.AiuInfo[idx].strRtlNamePrefix%>.XAIUPCTCR.get_full_name()}, "NO_REG_BIT_BASH_TEST",1,this);
    <%}} %>
    <% if(obj.AiuInfo[idx].nNativeInterfacePorts > 1){%>
    uvm_resource_db#(bit)::set({"REG::", m_concerto_env.m_regs.<%=obj.AiuInfo[idx].strRtlNamePrefix%>_<%=mpu_io%>.XAIUCCTRLR.get_full_name()}, "NO_REG_BIT_BASH_TEST",1,this);
    uvm_resource_db#(bit)::set({"REG::", m_concerto_env.m_regs.<%=obj.AiuInfo[idx].strRtlNamePrefix%>_<%=mpu_io%>.XAIUTCR.get_full_name()}, "NO_REG_BIT_BASH_TEST",1,this);
    uvm_resource_db#(bit)::set({"REG::", m_concerto_env.m_regs.<%=obj.AiuInfo[idx].strRtlNamePrefix%>_<%=mpu_io%>.XAIUQOSSR.get_full_name()}, "NO_REG_BIT_BASH_TEST",1,this);
    uvm_resource_db#(bit)::set({"REG::", m_concerto_env.m_regs.<%=obj.AiuInfo[idx].strRtlNamePrefix%>_<%=mpu_io%>.XAIUNRSBLR.get_full_name()}, "NO_REG_BIT_BASH_TEST",1,this);
    uvm_resource_db#(bit)::set({"REG::", m_concerto_env.m_regs.<%=obj.AiuInfo[idx].strRtlNamePrefix%>_<%=mpu_io%>.XAIUTAR.get_full_name()}, "NO_REG_BIT_BASH_TEST",1,this);
    uvm_resource_db#(bit)::set({"REG::", m_concerto_env.m_regs.<%=obj.AiuInfo[idx].strRtlNamePrefix%>_<%=mpu_io%>.XAIUBRAR.get_full_name()}, "NO_REG_BIT_BASH_TEST",1,this);
    uvm_resource_db#(bit)::set({"REG::", m_concerto_env.m_regs.<%=obj.AiuInfo[idx].strRtlNamePrefix%>_<%=mpu_io%>.XAIUBRBLR.get_full_name()}, "NO_REG_BIT_BASH_TEST",1,this);
    uvm_resource_db#(bit)::set({"REG::", m_concerto_env.m_regs.<%=obj.AiuInfo[idx].strRtlNamePrefix%>_<%=mpu_io%>.XAIUNRSAR.get_full_name()}, "NO_REG_BIT_BASH_TEST",1,this);
    <%for(let j=0;j<largest_index;j++) {%>
    uvm_resource_db#(bit)::set({"REG::", m_concerto_env.m_regs.<%=obj.AiuInfo[idx].strRtlNamePrefix%>_<%=mpu_io%>.XAIUCCR<%=j%>.get_full_name()}, "NO_REG_BIT_BASH_TEST",1,this);
    <%} %>
    <%} else { %>
    uvm_resource_db#(bit)::set({"REG::", m_concerto_env.m_regs.<%=obj.AiuInfo[idx].strRtlNamePrefix%>.XAIUCCTRLR.get_full_name()}, "NO_REG_BIT_BASH_TEST",1,this);
    uvm_resource_db#(bit)::set({"REG::", m_concerto_env.m_regs.<%=obj.AiuInfo[idx].strRtlNamePrefix%>.XAIUTCR.get_full_name()}, "NO_REG_BIT_BASH_TEST",1,this);
    uvm_resource_db#(bit)::set({"REG::", m_concerto_env.m_regs.<%=obj.AiuInfo[idx].strRtlNamePrefix%>.XAIUQOSSR.get_full_name()}, "NO_REG_BIT_BASH_TEST",1,this);
    uvm_resource_db#(bit)::set({"REG::", m_concerto_env.m_regs.<%=obj.AiuInfo[idx].strRtlNamePrefix%>.XAIUNRSBLR.get_full_name()}, "NO_REG_BIT_BASH_TEST",1,this);
    uvm_resource_db#(bit)::set({"REG::", m_concerto_env.m_regs.<%=obj.AiuInfo[idx].strRtlNamePrefix%>.XAIUTAR.get_full_name()}, "NO_REG_BIT_BASH_TEST",1,this);
    uvm_resource_db#(bit)::set({"REG::", m_concerto_env.m_regs.<%=obj.AiuInfo[idx].strRtlNamePrefix%>.XAIUBRAR.get_full_name()}, "NO_REG_BIT_BASH_TEST",1,this);
    uvm_resource_db#(bit)::set({"REG::", m_concerto_env.m_regs.<%=obj.AiuInfo[idx].strRtlNamePrefix%>.XAIUBRBLR.get_full_name()}, "NO_REG_BIT_BASH_TEST",1,this);
    uvm_resource_db#(bit)::set({"REG::", m_concerto_env.m_regs.<%=obj.AiuInfo[idx].strRtlNamePrefix%>.XAIUNRSAR.get_full_name()}, "NO_REG_BIT_BASH_TEST",1,this);
    <%for(let j=0;j<largest_index;j++) {%>
    uvm_resource_db#(bit)::set({"REG::", m_concerto_env.m_regs.<%=obj.AiuInfo[idx].strRtlNamePrefix%>.XAIUCCR<%=j%>.get_full_name()}, "NO_REG_BIT_BASH_TEST",1,this);
    <%} %>
    <%}}}%>
<%}%>


    <% for(let pidx = 0; pidx < obj.nDMIs; pidx++) { %>
    uvm_resource_db#(bit)::set({"REG::", m_concerto_env.m_regs.<%=obj.DmiInfo[pidx].strRtlNamePrefix%>.DMICCTRLR.get_full_name()}, "NO_REG_BIT_BASH_TEST",1,this);
       <% if(obj.DmiInfo[pidx].useCmc) { %>
    uvm_resource_db#(bit)::set({"REG::", m_concerto_env.m_regs.<%=obj.DmiInfo[pidx].strRtlNamePrefix%>.DMIUSMCISR.get_full_name()}, "NO_REG_BIT_BASH_TEST",1,this);
    uvm_resource_db#(bit)::set({"REG::", m_concerto_env.m_regs.<%=obj.DmiInfo[pidx].strRtlNamePrefix%>.DMIUSMCMCR.get_full_name()}, "NO_REG_BIT_BASH_TEST",1,this);
      <% } %>
    <% } %>
    
    <% for(let pidx = 0; pidx < obj.nDCEs; pidx++) { %>
    uvm_resource_db#(bit)::set({"REG::", m_concerto_env.m_regs.<%=obj.DceInfo[pidx].strRtlNamePrefix%>.DCEUTCR.get_full_name()}, "NO_REG_BIT_BASH_TEST",1,this);
    uvm_resource_db#(bit)::set({"REG::", m_concerto_env.m_regs.<%=obj.DceInfo[pidx].strRtlNamePrefix%>.DCEUTAR.get_full_name()}, "NO_REG_BIT_BASH_TEST",1,this);
    uvm_resource_db#(bit)::set({"REG::", m_concerto_env.m_regs.<%=obj.DceInfo[pidx].strRtlNamePrefix%>.DCEUSFMAR.get_full_name()}, "NO_REG_BIT_BASH_TEST",1,this);
    uvm_resource_db#(bit)::set({"REG::", m_concerto_env.m_regs.<%=obj.DceInfo[pidx].strRtlNamePrefix%>.DCEUSER0.get_full_name()}, "NO_REG_BIT_BASH_TEST",1,this);
    <%for(let j=0;j<obj.nDMIs;j++) {%>
    uvm_resource_db#(bit)::set({"REG::", m_concerto_env.m_regs.<%=obj.DceInfo[pidx].strRtlNamePrefix%>.DCEUCCR<%=j%>.get_full_name()}, "NO_REG_BIT_BASH_TEST",1,this);
    <% } %>
    <% } %>

    <% for(let pidx = 0; pidx < obj.nDIIs; pidx++) { %>
    uvm_resource_db#(bit)::set({"REG::", m_concerto_env.m_regs.<%=obj.DiiInfo[pidx].strRtlNamePrefix%>.DIICCTRLR.get_full_name()}, "NO_REG_BIT_BASH_TEST",1,this);
    uvm_resource_db#(bit)::set({"REG::", m_concerto_env.m_regs.<%=obj.DiiInfo[pidx].strRtlNamePrefix%>.DIIUTAR.get_full_name()}, "NO_REG_BIT_BASH_TEST",1,this);
    <% } %>
    uvm_resource_db#(bit)::set({"REG::", m_concerto_env.m_regs.sys_dii.DIIUTAR.get_full_name()}, "NO_REG_BIT_BASH_TEST",1,this);

    uvm_resource_db#(bit)::set({"REG::", m_concerto_env.m_regs.<%=obj.DveInfo[0].strRtlNamePrefix%>.DVEUSER0.get_full_name()}, "NO_REG_BIT_BASH_TEST",1,this); //dve_ral_test.svh
    uvm_resource_db#(bit)::set({"REG::", m_concerto_env.m_regs.<%=obj.DveInfo[0].strRtlNamePrefix%>.DVETASCR.get_full_name()}, "NO_REG_BIT_BASH_TEST",1,this); //dve_ral_test.svh

    
    //csr_seq.start(null);
<% if ((found_csr_access_chiaiu > 0) && (found_csr_access_ioaiu > 0)) { %>
    if(csr_test_from_ioaiu == 1) begin
       `uvm_info("FULLSYS_TEST", "Start uvm_reg_bit_bash_seq from IOAIU<%=csrAccess_ioaiu%>", UVM_NONE)
       csrAccess_ioaiu = <%=csrAccess_ioaiu%>;
`ifndef USE_VIP_SNPS //existing flow will not run when USE_VIP_SNPS set
       m_concerto_env.m_regs.default_map.set_sequencer(m_ioaiu_vseqr<%=csrAccess_ioaiu%>);
       m_concerto_env.m_regs.default_map.set_auto_predict(1);
       csr_seq.start(null);
`else //  `ifndef USE_VIP_SNPS  
       m_concerto_env.snps.reg2axi.p_cfg = this.m_concerto_env.snps.m_cfg.svt_cfg.axi_sys_cfg[0].master_cfg[<%=csrAccess_ioaiu%>]; // Set the register config to be the same as the rn[0]
       m_concerto_env.m_regs.default_map.set_sequencer(m_concerto_env.snps.svt.amba_system_env.axi_system[0].master[<%=csrAccess_ioaiu%>].sequencer, m_concerto_env.snps.reg2axi);
       m_concerto_env.m_regs.default_map.set_auto_predict(1);
       csr_seq.start(null);
`endif //`ifndef USE_VIP_SNPS ... else
    end                       
    else begin
       `uvm_info("FULLSYS_TEST", "Start uvm_reg_bit_bash_seq from CHIAIU<%=csrAccess_chiaiu%>", UVM_NONE)
       csrAccess_chiaiu = <%=csrAccess_chiaiu%>;
`ifndef USE_VIP_SNPS //existing flow will not run when USE_VIP_SNPS set
       m_concerto_env.m_regs.default_map.set_sequencer(m_concerto_env.inhouse.m_chiaiu<%=csrAccess_chiaiu%>_env.m_chi_agent.m_rn_tx_req_chnl_seqr);
       m_concerto_env.m_regs.default_map.set_auto_predict(1);
       csr_seq.start(null);
`else //  `ifndef USE_VIP_SNPS  
       m_concerto_env.snps.reg2chi.p_cfg = this.m_concerto_env_cfg.svt_cfg.chi_sys_cfg[0].rn_cfg[<%=csrAccess_chiaiu%>]; // Set the register config to be the same as the rn[0]
       m_concerto_env.m_regs.default_map.set_sequencer(m_concerto_env.snps.svt.amba_system_env.chi_system[0].rn[<%=csrAccess_chiaiu%>].rn_xact_seqr,m_concerto_env.snps.reg2chi);
       m_concerto_env.m_regs.default_map.set_auto_predict(1);
       csr_seq.start(null);
`endif //`ifndef USE_VIP_SNPS ... else

    end // else: !if(csr_test_from_ioaiu == 1)
<% } else {
   if(found_csr_access_chiaiu > 0) { %>
       `uvm_info("FULLSYS_TEST", "Start uvm_reg_bit_bash_seq from CHIAIU<%=csrAccess_chiaiu%>", UVM_NONE)
       csrAccess_chiaiu = <%=csrAccess_chiaiu%>;
 `ifndef USE_VIP_SNPS //existing flow will not run when USE_VIP_SNPS set
       m_concerto_env.m_regs.default_map.set_sequencer(m_concerto_env.inhouse.m_chiaiu<%=csrAccess_chiaiu%>_env.m_chi_agent.m_rn_tx_req_chnl_seqr);
       m_concerto_env.m_regs.default_map.set_auto_predict(1);
       csr_seq.start(null);
 `else //  `ifndef USE_VIP_SNPS  
       m_concerto_env.snps.reg2chi.p_cfg = this.m_concerto_env_cfg.svt_cfg.chi_sys_cfg[0].rn_cfg[<%=csrAccess_chiaiu%>]; // Set the register config to be the same as the rn[0]
       m_concerto_env.m_regs.default_map.set_sequencer(m_concerto_env.snps.svt.amba_system_env.chi_system[0].rn[<%=csrAccess_chiaiu%>].rn_xact_seqr,m_concerto_env.snps.reg2chi);
       m_concerto_env.m_regs.default_map.set_auto_predict(1);
       csr_seq.start(null);
 `endif //`ifndef USE_VIP_SNPS
    <% } else { %>
<% if (found_csr_access_ioaiu > 0) { %>
`ifndef USE_VIP_SNPS //existing flow will not run when USE_VIP_SNPS set
       `uvm_info("FULLSYS_TEST", "Start uvm_reg_bit_bash_seq from IOAIU<%=csrAccess_ioaiu%>", UVM_NONE)
       m_concerto_env.m_regs.default_map.set_sequencer(m_ioaiu_vseqr<%=csrAccess_ioaiu%>);
       m_concerto_env.m_regs.default_map.set_auto_predict(1);
       csr_seq.start(null);
`else //  `ifndef USE_VIP_SNPS  
       `uvm_info("FULLSYS_TEST", "Start uvm_reg_bit_bash_seq from IOAIU<%=csrAccess_ioaiu%>", UVM_NONE)
       m_concerto_env.snps.reg2axi.p_cfg = this.m_concerto_env.snps.m_cfg.svt_cfg.axi_sys_cfg[0].master_cfg[<%=csrAccess_ioaiu%>]; // Set the register config to be the same as the rn[0]
       m_concerto_env.m_regs.default_map.set_sequencer(m_concerto_env.snps.svt.amba_system_env.axi_system[0].master[<%=csrAccess_ioaiu%>].sequencer, m_concerto_env.snps.reg2axi);
       m_concerto_env.m_regs.default_map.set_auto_predict(1);
       csr_seq.start(null);
`endif //`ifndef USE_VIP_SNPS ... else
<% } } } %>
    m_concerto_env.m_regs.print();
endtask:run_fsys_reg_bit_bash_seq

//#Check.FSYS.csr.reset_val_from_chiaiu
//#Check.FSYS.csr.reset_val_from_ioaiu
task concerto_fullsys_reg_bash_test::run_fsys_reg_reset_value_seq();
`ifndef USE_VIP_SNPS
<%  if(numIoAiu>0) { %>
  ioaiu_reg_frontdoor ioaiu_frontdoor;
<%  } %>
<%  if(numChiAiu>0) { %>
  chiaiu_reg_frontdoor chiaiu_frontdoor;
<%  } %>
  uvm_reg regs[$];
`endif
  uvm_reg_hw_reset_seq csr_seq;
<%  if(numChiAiu>0 && numIoAiu>0) { %>
    if (!$value$plusargs("csr_test_from_ioaiu=%b",csr_test_from_ioaiu)) begin
        csr_test_from_ioaiu= 0;
    end
<%  } else if(numIoAiu>0 && numChiAiu==0) { %>
        csr_test_from_ioaiu= 1;
<%  } else if(numChiAiu>0 && numIoAiu==0) { %>
        csr_test_from_ioaiu= 0;
<%  } %>
    csr_seq = uvm_reg_hw_reset_seq::type_id::create("csr_seq");
    csr_seq.model = m_concerto_env.m_regs;
`ifndef USE_VIP_SNPS
    if(csr_test_from_ioaiu) begin
<%  if(numIoAiu>0) { %>
      ioaiu_frontdoor = ioaiu_reg_frontdoor::type_id::create("ioaiu_frontdoor");
      m_concerto_env.m_regs.get_registers(regs,UVM_HIER);
      foreach (regs[rg]) begin
        regs[rg].reset(); 
        regs[rg].set_frontdoor(ioaiu_frontdoor); 
      end
<%  } %>
    end else begin
<%  if(numChiAiu>0) { %>
      chiaiu_frontdoor = chiaiu_reg_frontdoor::type_id::create("chiaiu_frontdoor");
       m_concerto_env.m_regs.get_registers(regs,UVM_HIER);
       foreach (regs[rg]) begin
         regs[rg].reset(); 
         regs[rg].set_frontdoor(chiaiu_frontdoor); 
       end
<%  } %>
    end
`endif

    // Run the reg model sequence
    `uvm_info("ncore_ral_reset_value_test", "Excluding CAIUTAR & DMIUSMCISR ", UVM_LOW)
<% for(let idx = 0; idx < obj.nAIUs; idx++) {
     if((obj.AiuInfo[idx].fnNativeInterface.match('CHI'))) {%>
    uvm_resource_db#(bit)::set({"REG::", m_concerto_env.m_regs.<%=obj.AiuInfo[idx].strRtlNamePrefix%>.CAIUTAR.get_full_name()}, "NO_REG_HW_RESET_TEST",1,this);
    //AE to be checked
    <%} else {
     for (let mpu_io = 0; mpu_io < obj.AiuInfo[idx].nNativeInterfacePorts; mpu_io++){%>
    <% if (obj.AiuInfo[idx].fnNativeInterface == 'AXI4' && obj.AiuInfo[idx].useCache == 1){%>
    <% if(obj.AiuInfo[idx].nNativeInterfacePorts > 1){%>
    uvm_resource_db#(bit)::set({"REG::", m_concerto_env.m_regs.<%=obj.AiuInfo[idx].strRtlNamePrefix%>_<%=mpu_io%>.XAIUPCISR.get_full_name()}, "NO_REG_HW_RESET_TEST",1,this);
    uvm_resource_db#(bit)::set({"REG::", m_concerto_env.m_regs.<%=obj.AiuInfo[idx].strRtlNamePrefix%>_<%=mpu_io%>.XAIUPCMAR.get_full_name()}, "NO_REG_HW_RESET_TEST",1,this);
    <%} else { %>
    uvm_resource_db#(bit)::set({"REG::", m_concerto_env.m_regs.<%=obj.AiuInfo[idx].strRtlNamePrefix%>.XAIUPCISR.get_full_name()}, "NO_REG_HW_RESET_TEST",1,this);
    uvm_resource_db#(bit)::set({"REG::", m_concerto_env.m_regs.<%=obj.AiuInfo[idx].strRtlNamePrefix%>.XAIUPCMAR.get_full_name()}, "NO_REG_HW_RESET_TEST",1,this);
    <%}}  %>
    <% if(obj.AiuInfo[idx].nNativeInterfacePorts > 1){%>
    uvm_resource_db#(bit)::set({"REG::", m_concerto_env.m_regs.<%=obj.AiuInfo[idx].strRtlNamePrefix%>_<%=mpu_io%>.XAIUNRSBLR.get_full_name()}, "NO_REG_HW_RESET_TEST",1,this);
    uvm_resource_db#(bit)::set({"REG::", m_concerto_env.m_regs.<%=obj.AiuInfo[idx].strRtlNamePrefix%>_<%=mpu_io%>.XAIUTAR.get_full_name()}, "NO_REG_HW_RESET_TEST",1,this);
    uvm_resource_db#(bit)::set({"REG::", m_concerto_env.m_regs.<%=obj.AiuInfo[idx].strRtlNamePrefix%>_<%=mpu_io%>.XAIUBRAR.get_full_name()}, "NO_REG_HW_RESET_TEST",1,this);
    uvm_resource_db#(bit)::set({"REG::", m_concerto_env.m_regs.<%=obj.AiuInfo[idx].strRtlNamePrefix%>_<%=mpu_io%>.XAIUBRBLR.get_full_name()}, "NO_REG_HW_RESET_TEST",1,this);
    <%} else { %>
    uvm_resource_db#(bit)::set({"REG::", m_concerto_env.m_regs.<%=obj.AiuInfo[idx].strRtlNamePrefix%>.XAIUNRSBLR.get_full_name()}, "NO_REG_HW_RESET_TEST",1,this);
    uvm_resource_db#(bit)::set({"REG::", m_concerto_env.m_regs.<%=obj.AiuInfo[idx].strRtlNamePrefix%>.XAIUTAR.get_full_name()}, "NO_REG_HW_RESET_TEST",1,this);
    uvm_resource_db#(bit)::set({"REG::", m_concerto_env.m_regs.<%=obj.AiuInfo[idx].strRtlNamePrefix%>.XAIUBRAR.get_full_name()}, "NO_REG_HW_RESET_TEST",1,this);
    uvm_resource_db#(bit)::set({"REG::", m_concerto_env.m_regs.<%=obj.AiuInfo[idx].strRtlNamePrefix%>.XAIUBRBLR.get_full_name()}, "NO_REG_HW_RESET_TEST",1,this);
    <%}}%>
<%}}%>


    <% for(let pidx = 0; pidx < obj.nDMIs; pidx++) { %>
       <% if(obj.DmiInfo[pidx].useCmc) { %>
    uvm_resource_db#(bit)::set({"REG::", m_concerto_env.m_regs.<%=obj.DmiInfo[pidx].strRtlNamePrefix%>.DMIUSMCISR.get_full_name()}, "NO_REG_HW_RESET_TEST",1,this);
    uvm_resource_db#(bit)::set({"REG::", m_concerto_env.m_regs.<%=obj.DmiInfo[pidx].strRtlNamePrefix%>.DMIUTAR.get_full_name()}, "NO_REG_HW_RESET_TEST",1,this);
       <% } %>
    <% } %>

    <% for(let pidx = 0; pidx < obj.nDCEs; pidx++) { %>
    uvm_resource_db#(bit)::set({"REG::", m_concerto_env.m_regs.<%=obj.DceInfo[pidx].strRtlNamePrefix%>.DCEUTAR.get_full_name()}, "NO_REG_HW_RESET_TEST",1,this);
    uvm_resource_db#(bit)::set({"REG::", m_concerto_env.m_regs.<%=obj.DceInfo[pidx].strRtlNamePrefix%>.DCEUSFMAR.get_full_name()}, "NO_REG_HW_RESET_TEST",1,this);
    <% } %>

    uvm_resource_db#(bit)::set({"REG::", m_concerto_env.m_regs.sys_dii.DIIUTAR.get_full_name()}, "NO_REG_HW_RESET_TEST",1,this);

        
    uvm_resource_db#(bit)::set({"REG::", m_concerto_env.m_regs.<%=obj.DveInfo[0].strRtlNamePrefix%>.DVEUSER0.get_full_name()}, "NO_REG_HW_RESET_TEST",1,this); //dve_ral_test.svh
    //csr_seq.start(null);
<% if ((found_csr_access_chiaiu > 0) && (found_csr_access_ioaiu > 0)) { %>
    if(csr_test_from_ioaiu == 1) begin
       `uvm_info("FULLSYS_TEST", "Start uvm_reg_hw_reset_seq from IOAIU<%=csrAccess_ioaiu%>", UVM_NONE)
       csrAccess_ioaiu = <%=csrAccess_ioaiu%>;
`ifndef USE_VIP_SNPS //existing flow will not run when USE_VIP_SNPS set
       m_concerto_env.m_regs.default_map.set_sequencer(m_ioaiu_vseqr<%=csrAccess_ioaiu%>);
       m_concerto_env.m_regs.default_map.set_auto_predict(1);
       csr_seq.start(null);
`else //  `ifndef USE_VIP_SNPS  
       m_concerto_env.snps.reg2axi.p_cfg = this.m_concerto_env.snps.m_cfg.svt_cfg.axi_sys_cfg[0].master_cfg[<%=csrAccess_ioaiu%>]; // Set the register config to be the same as the rn[0]
       m_concerto_env.m_regs.default_map.set_sequencer(m_concerto_env.snps.svt.amba_system_env.axi_system[0].master[<%=csrAccess_ioaiu%>].sequencer, m_concerto_env.snps.reg2axi);
       m_concerto_env.m_regs.default_map.set_auto_predict(1);
       csr_seq.start(null);
`endif //`ifndef USE_VIP_SNPS ... else
    end                       
    else begin
       `uvm_info("FULLSYS_TEST", "Start uvm_reg_hw_reset_seq from CHIAIU<%=csrAccess_chiaiu%>", UVM_NONE)
       csrAccess_chiaiu = <%=csrAccess_chiaiu%>;
`ifndef USE_VIP_SNPS //existing flow will not run when USE_VIP_SNPS set
       m_concerto_env.m_regs.default_map.set_sequencer(m_concerto_env.inhouse.m_chiaiu<%=csrAccess_chiaiu%>_env.m_chi_agent.m_rn_tx_req_chnl_seqr);
       m_concerto_env.m_regs.default_map.set_auto_predict(1);
       csr_seq.start(null);
`else //  `ifndef USE_VIP_SNPS  
       m_concerto_env.snps.reg2chi.p_cfg = this.m_concerto_env_cfg.svt_cfg.chi_sys_cfg[0].rn_cfg[<%=csrAccess_chiaiu%>]; // Set the register config to be the same as the rn[0]
       m_concerto_env.m_regs.default_map.set_sequencer(m_concerto_env.snps.svt.amba_system_env.chi_system[0].rn[<%=csrAccess_chiaiu%>].rn_xact_seqr,m_concerto_env.snps.reg2chi);
       m_concerto_env.m_regs.default_map.set_auto_predict(1);
       csr_seq.start(null);
`endif //`ifndef USE_VIP_SNPS ... else

    end // else: !if(csr_test_from_ioaiu == 1)
<% } else {
   if(found_csr_access_chiaiu > 0) { %>
       csrAccess_chiaiu = <%=csrAccess_chiaiu%>;
       `uvm_info("FULLSYS_TEST", "Start uvm_reg_hw_reset_seq from CHIAIU<%=csrAccess_chiaiu%>", UVM_NONE)
 `ifndef USE_VIP_SNPS //existing flow will not run when USE_VIP_SNPS set
       m_concerto_env.m_regs.default_map.set_sequencer(m_concerto_env.inhouse.m_chiaiu<%=csrAccess_chiaiu%>_env.m_chi_agent.m_rn_tx_req_chnl_seqr);
       m_concerto_env.m_regs.default_map.set_auto_predict(1);
       csr_seq.start(null);
 `else //  `ifndef USE_VIP_SNPS  
       m_concerto_env.snps.reg2chi.p_cfg = this.m_concerto_env_cfg.svt_cfg.chi_sys_cfg[0].rn_cfg[<%=csrAccess_chiaiu%>]; // Set the register config to be the same as the rn[0]
       m_concerto_env.m_regs.default_map.set_sequencer(m_concerto_env.snps.svt.amba_system_env.chi_system[0].rn[<%=csrAccess_chiaiu%>].rn_xact_seqr,m_concerto_env.snps.reg2chi);
       m_concerto_env.m_regs.default_map.set_auto_predict(1);
       csr_seq.start(null);
 `endif //`ifndef USE_VIP_SNPS
    <% } else { %>
<% if (found_csr_access_ioaiu > 0) { %>
`ifndef USE_VIP_SNPS //existing flow will not run when USE_VIP_SNPS set
       `uvm_info("FULLSYS_TEST", "Start uvm_reg_hw_reset_seq from IOAIU<%=csrAccess_ioaiu%>", UVM_NONE)
       m_concerto_env.m_regs.default_map.set_sequencer(m_ioaiu_vseqr<%=csrAccess_ioaiu%>);
       //m_concerto_env.m_regs.default_map.set_sequencer(m_concerto_env.snps.svt.amba_system_env.axi_system[0].master[<%=csrAccess_ioaiu%>].sequencer);
       m_concerto_env.m_regs.default_map.set_auto_predict(1);
       csr_seq.start(null);
`else //  `ifndef USE_VIP_SNPS  
       `uvm_info("FULLSYS_TEST", "Start uvm_reg_hw_reset_seq from IOAIU<%=csrAccess_ioaiu%>", UVM_NONE)
       m_concerto_env.snps.reg2axi.p_cfg = this.m_concerto_env.snps.m_cfg.svt_cfg.axi_sys_cfg[0].master_cfg[<%=csrAccess_ioaiu%>]; // Set the register config to be the same as the rn[0]
       m_concerto_env.m_regs.default_map.set_sequencer(m_concerto_env.snps.svt.amba_system_env.axi_system[0].master[<%=csrAccess_ioaiu%>].sequencer, m_concerto_env.snps.reg2axi);
       m_concerto_env.m_regs.default_map.set_auto_predict(1);
       csr_seq.start(null);
`endif //`ifndef USE_VIP_SNPS ... else
<% } } } %>

    m_concerto_env.m_regs.print();
endtask:run_fsys_reg_reset_value_seq
