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

class concerto_base_trace_test extends concerto_base_test; 

  `uvm_component_utils(concerto_base_trace_test)
   
   static uvm_event csr_trace_debug_done = ev_pool.get("csr_trace_debug_done");

   bit [31:0] 	trace_capture_en_q[$];
   bit [31:0] 	trace_trigger_en_q[$];
    //ACE Model
    <% var qidx=0; var idx=0; for(var pidx = 0 ; pidx < obj.nAIUs; pidx++) { %>
      <% if(!(obj.AiuInfo[pidx].fnNativeInterface.match('CHI'))) { %>
           ioaiu<%=qidx%>_env_pkg::trace_trigger_utils m_trace_trigger_<%=pidx%>[<%=aiu_NumCores[pidx]%>];
<%  qidx++; } %>
    <% } %>

  function new(string name = "concerto_base_trace_test", uvm_component parent=null);
    super.new(name,parent);
  endfunction: new

  // UVM PHASE
  extern virtual function void start_of_simulation_phase(uvm_phase phase);

  // function & tasks 
  extern virtual task trace_capture_en();
  extern virtual task trace_trigger_en();
  <% for(var idx = 0, qidx=0; idx < obj.nAIUs; idx++) { 
  if(!(obj.AiuInfo[idx].fnNativeInterface.match('CHI'))) { %>
     <% if(obj.AiuInfo[idx].fnCsrAccess == 1) { %>
  extern virtual task ioaiu_trace_capture_program<%=qidx%>(input bit[31:0] trace_capture_queue[$]);
  extern virtual task ioaiu_trace_accum_check<%=qidx%>(input bit[31:0] trace_capture_queue[$]);
  extern virtual task ioaiu_trace_trigger_program<%=qidx%>(input bit[31:0] trace_trigger_queue[$]);
  <% }
  qidx++; }
  } %>
  // TASK & FUNCTION
endclass: concerto_base_trace_test


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
 function void concerto_base_trace_test::start_of_simulation_phase(uvm_phase phase);
     super.start_of_simulation_phase(phase);
    <% var qidx=0; var idx=0; for(var pidx = 0 ; pidx < obj.nAIUs; pidx++) { %>
      <% if(!(obj.AiuInfo[pidx].fnNativeInterface.match("CHI"))) { %>
      <% for(var i=0; i<aiu_NumCores[pidx]; i++) { %> 
        m_trace_trigger_<%=pidx%>[<%=i%>] = new();
        m_trace_trigger_<%=pidx%>[<%=i%>].set_mpCoreId_value(<%=i%>);
        uvm_config_db#(ioaiu<%=qidx%>_env_pkg::trace_trigger_utils)::set(this, "m_concerto_env.<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_env.m_env[<%=i%>]", "m_trace_trigger", m_trace_trigger_<%=pidx%>[<%=i%>]);
  <% } %>
    <% qidx++; } %>
  <% } %>
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
 task concerto_base_trace_test::trace_capture_en();
    bit [31:0] aiu_trace_capture;
    bit [31:0] dmi_trace_capture;
    bit [31:0] dii_trace_capture;

    bit [7:0]  tr_aiu_smi_capture;
    bit [7:0]  tr_dmi_smi_capture;
    bit [7:0]  tr_dii_smi_capture;

<% for(var unit = 0; unit < obj.nAIUs_mpu; unit++) { %>
    <% if (!_blkportsid[unit]) { //only one trace capture value for all MPU ports%>
    bit [31:0] <%=_blkid[unit]%>_trace_capture;
<% }} %>

<% for(var unit = 0; unit < obj.nDMIs; unit++) { %>
    bit [31:0] dmi<%=unit%>_trace_capture;
<% } %>
<% for(var unit = 0; unit < obj.nDIIs; unit++) { %>
    bit [31:0] dii<%=unit%>_trace_capture;
<% } %>

    if(!$value$plusargs("aiu_trace_capture=%h", aiu_trace_capture)) aiu_trace_capture = 32'h0;
   <% var cidx=0; var ioidx=0; 
    for(var unit = 0; unit < obj.nAIUs_mpu; unit++) { %>
    <% if (!_blkportsid[unit]) { //only one trace capture value for all MPU ports%>
    if(!$value$plusargs("<%=_blkid[unit]%>_trace_capture=%h", <%=_blkid[unit]%>_trace_capture)) begin
        if ($test$plusargs("rand_capture")) begin
           std::randomize(tr_aiu_smi_capture);
           <%=_blkid[unit]%>_trace_capture = tr_aiu_smi_capture;
        end else begin
           <%=_blkid[unit]%>_trace_capture = aiu_trace_capture;
        end
    end
    <%} // only ports 0 %>
    `uvm_info("trace_capture_en", $sformatf("generating <%=_blkid[unit].toUpperCase()%>_trace_capture_en=%0h ports_id:<%=_blkportsid[unit]%>", <%=_blkid[unit]%>_trace_capture), UVM_MEDIUM)
    trace_capture_en_q.push_back(<%=_blkid[unit]%>_trace_capture);
    <% if (!_blkportsid[unit]) { //only one trace capture value for all MPU ports%>
    <% if(_blk[unit].fnNativeInterface.match('CHI')) { %>
    m_concerto_env.inhouse.m_chiaiu<%=cidx%>_env.m_trace_debug_scb.port_capture_en     = <%=_blkid[unit]%>_trace_capture[7:0];
    //m_concerto_env.m_chiaiu<%=cidx%>_env.m_trace_debug_scb.circular_buffer_en  = aiu<%=unit%>_trace_capture[8:8];
    //m_concerto_env.m_chiaiu<%=cidx%>_env.m_trace_debug_scb.threshold_val       = aiu<%=unit%>_trace_capture[11:9];
    <% cidx++; }
    else { %>
    m_concerto_env.inhouse.m_ioaiu<%=ioidx%>_env.m_trace_debug_scb.port_capture_en     = <%=_blkid[unit]%>_trace_capture[7:0];
    //m_concerto_env.m_ioaiu<%=ioidx%>_env.m_trace_debug_scb.circular_buffer_en  = aiu<%=unit%>_trace_capture[8:8];
    //m_concerto_env.m_ioaiu<%=ioidx%>_env.m_trace_debug_scb.threshold_val       = aiu<%=unit%>_trace_capture[11:9];
    <% ioidx++; } %>
    <%} // only ports 0 %>
<% } %>

    if(!$value$plusargs("dmi_trace_capture=%h", dmi_trace_capture)) dmi_trace_capture = 32'h0;
<% for(var unit = 0; unit < obj.nDMIs; unit++) { %>
    if(!$value$plusargs("dmi<%=unit%>_trace_capture=%h", dmi<%=unit%>_trace_capture)) begin
        if ($test$plusargs("rand_capture")) begin
           std::randomize(tr_dmi_smi_capture);
           dmi<%=unit%>_trace_capture = tr_dmi_smi_capture;
        end else begin
           dmi<%=unit%>_trace_capture = dmi_trace_capture;
        end
    end
    `uvm_info("trace_capture_en", $sformatf("generating DMI<%=unit%> trace_capture_en=%0h", dmi<%=unit%>_trace_capture), UVM_MEDIUM)
    trace_capture_en_q.push_back(dmi<%=unit%>_trace_capture);
    <% if(DmiInfo[unit].smiPortParams.tx.length==5) { %>
    m_concerto_env.inhouse.m_dmi<%=unit%>_env.m_trace_debug_scb.port_capture_en     = dmi<%=unit%>_trace_capture[9:0];
    <% } else { %>
    m_concerto_env.inhouse.m_dmi<%=unit%>_env.m_trace_debug_scb.port_capture_en     = dmi<%=unit%>_trace_capture[7:0];
    <%}%>
    //m_concerto_env.m_dmi<%=unit%>_env.m_trace_debug_scb.circular_buffer_en  = dmi<%=unit%>_trace_capture[8:8];
    //m_concerto_env.m_dmi<%=unit%>_env.m_trace_debug_scb.threshold_val       = dmi<%=unit%>_trace_capture[11:9];
<% } %>

    if(!$value$plusargs("dii_trace_capture=%h", dii_trace_capture)) dii_trace_capture = 32'h0;
<% for(var unit = 0; unit < obj.nDIIs; unit++) { %>
    if(!$value$plusargs("dii<%=unit%>_trace_capture=%h", dii<%=unit%>_trace_capture)) begin
        if ($test$plusargs("rand_capture")) begin
           std::randomize(tr_dii_smi_capture);
           dii<%=unit%>_trace_capture = tr_dii_smi_capture;
        end else begin
           dii<%=unit%>_trace_capture = dii_trace_capture;
        end
    end
    `uvm_info("trace_capture_en", $sformatf("generating DII<%=unit%> trace_capture_en=%0h", dii<%=unit%>_trace_capture), UVM_MEDIUM)
    trace_capture_en_q.push_back(dii<%=unit%>_trace_capture);
    m_concerto_env.inhouse.m_dii<%=unit%>_env.m_trace_debug_scb.port_capture_en     = dii<%=unit%>_trace_capture[7:0];
    //m_concerto_env.m_dii<%=unit%>_env.m_trace_debug_scb.circular_buffer_en  = dii<%=unit%>_trace_capture[8:8];
    //m_concerto_env.m_dii<%=unit%>_env.m_trace_debug_scb.threshold_val       = dii<%=unit%>_trace_capture[11:9];
<% } %>

<% if ((numChiAiu > 0) && (numBootIoAiu > 0)) { %>
    if($test$plusargs("boot_from_ioaiu"))
       ioaiu_trace_capture_program<%=BootIoAiu[0]%>(trace_capture_en_q);	
       //else
       // CLU REMOVE TODO use APB PORT DEBUG write instead of CHI OR IOAIU write CSR// m_chi0_vseq.chi_trace_capture_program(trace_capture_en_q);	
<% } else {%>
    <% if(numBootIoAiu > 0) { %>
    ioaiu_trace_capture_program<%=BootIoAiu[0]%>(trace_capture_en_q);	
    <% } %>
<% } %>
endtask:trace_capture_en

task concerto_base_trace_test::trace_trigger_en();
<% var cidx=0; var ioidx=0;
for(var unit = 0; unit < obj.nAIUs; unit++) {
    if(obj.AiuInfo[unit].fnNativeInterface.match("CHI")) { %>
    chiaiu<%=cidx%>_env_pkg::TRIG_TCTRLR_t aiu<%=unit%>_tctrlr[<%=obj.AiuInfo[unit].nTraceRegisters%>];
    chiaiu<%=cidx%>_env_pkg::TRIG_TBALR_t  aiu<%=unit%>_tbalr[<%=obj.AiuInfo[unit].nTraceRegisters%>];
    chiaiu<%=cidx%>_env_pkg::TRIG_TBAHR_t  aiu<%=unit%>_tbahr[<%=obj.AiuInfo[unit].nTraceRegisters%>];
    chiaiu<%=cidx%>_env_pkg::TRIG_TOPCR0_t aiu<%=unit%>_topcr0[<%=obj.AiuInfo[unit].nTraceRegisters%>];
    chiaiu<%=cidx%>_env_pkg::TRIG_TOPCR1_t aiu<%=unit%>_topcr1[<%=obj.AiuInfo[unit].nTraceRegisters%>];
    chiaiu<%=cidx%>_env_pkg::TRIG_TUBR_t   aiu<%=unit%>_tubr[<%=obj.AiuInfo[unit].nTraceRegisters%>];
    chiaiu<%=cidx%>_env_pkg::TRIG_TUBMR_t  aiu<%=unit%>_tubmr[<%=obj.AiuInfo[unit].nTraceRegisters%>];
    <% cidx++; }
    else { %>
    ioaiu<%=ioidx%>_env_pkg::TRIG_TCTRLR_t aiu<%=unit%>_tctrlr[<%=obj.AiuInfo[unit].nTraceRegisters%>];
    ioaiu<%=ioidx%>_env_pkg::TRIG_TBALR_t  aiu<%=unit%>_tbalr[<%=obj.AiuInfo[unit].nTraceRegisters%>];
    ioaiu<%=ioidx%>_env_pkg::TRIG_TBAHR_t  aiu<%=unit%>_tbahr[<%=obj.AiuInfo[unit].nTraceRegisters%>];
    ioaiu<%=ioidx%>_env_pkg::TRIG_TOPCR0_t aiu<%=unit%>_topcr0[<%=obj.AiuInfo[unit].nTraceRegisters%>];
    ioaiu<%=ioidx%>_env_pkg::TRIG_TOPCR1_t aiu<%=unit%>_topcr1[<%=obj.AiuInfo[unit].nTraceRegisters%>];
    ioaiu<%=ioidx%>_env_pkg::TRIG_TUBR_t   aiu<%=unit%>_tubr[<%=obj.AiuInfo[unit].nTraceRegisters%>];
    ioaiu<%=ioidx%>_env_pkg::TRIG_TUBMR_t  aiu<%=unit%>_tubmr[<%=obj.AiuInfo[unit].nTraceRegisters%>];
    <% ioidx++; } %>
<% } %>

   int native_match_weight;
   int addr_match_weight;
   int opcode_match_weight;
   int target_match_weight;
   int user_match_weight;
   int memattr_match_weight;
   int memattr_aw_match_weight;
   int memattr_ar_match_weight;
   bit [3:0] memattr;

   bit [51:0] trace_trigger_base_addr;
   int 	      trace_trigger_range;
   bit 	      trace_trigger_hut;
   int 	      trace_trigger_hui;

   int 	      num_dmi_huis = addrMgrConst::intrlvgrp_vector[addrMgrConst::picked_dmi_igs].size();
   int        num_dii_huis = <%=obj.nDIIs%>-1;
   int 	      num_memregions = addrMgrConst::memregions_info.size();
   int 	      memregion;

   int 	      programming_aiu;
   int 	      rand_aiu;

   <% if (numBootIoAiu > 0) { %>
   int        BootIoAiu[<%=BootIoAiu.length%>] = '{ <%for(var b=0; b<BootIoAiu.length; b++) { %> <%=BootIoAiu[b]%> <%if(b<(BootIoAiu.length-1)){%>, <%} } %> };
   <% } %>
 
   if(!$value$plusargs("trace_triger_native_match_weight=%d", native_match_weight))
     native_match_weight = 75;
   
   if(!$value$plusargs("trace_triger_addr_match_weight=%d", addr_match_weight))
     addr_match_weight = 50;

   if(!$value$plusargs("trace_triger_opcode_match_weight=%d", opcode_match_weight))
     opcode_match_weight = 50;

   if(!$value$plusargs("trace_triger_target_match_weight=%d", target_match_weight))
     target_match_weight = 50;

   if(!$value$plusargs("trace_triger_user_match_weight=%d", user_match_weight))
     user_match_weight = 25;

   if(!$value$plusargs("trace_triger_memattr_match_weight=%d", memattr_match_weight))
     memattr_match_weight = 50;

   if(!$value$plusargs("trace_triger_memattr_aw_match_weight=%d", memattr_aw_match_weight))
     memattr_aw_match_weight = 50;

   if(!$value$plusargs("trace_triger_memattr_ar_match_weight=%d", memattr_ar_match_weight))
     memattr_ar_match_weight = 50;

   <% if((found_csr_access_chiaiu > 0) && (found_csr_access_ioaiu > 0)) { %>
   if($test$plusargs("boot_from_ioaiu")) begin
      programming_aiu = <%=csrAccess_ioaiu%>;
      `uvm_info("FULLSYS_TEST", $sformatf("trace_trigger program(1) using IOAIU%0d, AIU%0d", BootIoAiu[rand_aiu], programming_aiu), UVM_NONE)
   end
   else begin
      programming_aiu = <%=csrAccess_chiaiu%>;
      `uvm_info("FULLSYS_TEST", $sformatf("trace_trigger program(1) using CHIAIU%0d, AIU%0d", rand_aiu, programming_aiu), UVM_NONE)
   end
   <% } else if (found_csr_access_chiaiu > 1) { %>
      programming_aiu = <%=csrAccess_chiaiu%>;
      `uvm_info("FULLSYS_TEST", $sformatf("trace_trigger program(2) using CHIAIU%0d, AIU%0d", rand_aiu, programming_aiu), UVM_NONE)
   <% } else if (found_csr_access_ioaiu > 1) { %>
      programming_aiu = <%=csrAccess_ioaiu%>;
      `uvm_info("FULLSYS_TEST", $sformatf("trace_trigger program(2) using IOAIU%0d, AIU%0d", rand_aiu, programming_aiu), UVM_NONE)
   <% } %>
   
<% for(var unit = 0; unit < obj.nAIUs; unit++) { %>
    if(programming_aiu == <%=unit%>) begin
    <% for(var set = 0; set < obj.AiuInfo[unit].nTraceRegisters; set++) { %>
       aiu<%=unit%>_tctrlr[<%=set%>] = 'h1;

       trace_trigger_en_q.push_back(aiu<%=unit%>_tbalr[<%=set%>]);
       trace_trigger_en_q.push_back(aiu<%=unit%>_tbahr[<%=set%>]);
       trace_trigger_en_q.push_back(aiu<%=unit%>_topcr0[<%=set%>]);
       trace_trigger_en_q.push_back(aiu<%=unit%>_topcr1[<%=set%>]);
       trace_trigger_en_q.push_back(aiu<%=unit%>_tubr[<%=set%>]);
       trace_trigger_en_q.push_back(aiu<%=unit%>_tubmr[<%=set%>]);
       trace_trigger_en_q.push_back(aiu<%=unit%>_tctrlr[<%=set%>]);
    <% } %>
    end else begin
// randomize each set of trace trigger csrs							     
    <% for(var set = 0; set < obj.AiuInfo[unit].nTraceRegisters; set++) { %>

    if(!$value$plusargs("trace_trigger_hut=%d", trace_trigger_hut)) begin
       <% if ((obj.nDMIs > 0) && (obj.nDIIs > 1)) { %>
       trace_trigger_hut = $urandom()%2;
       <% } else if (obj.nDMIs > 0) { %>
       trace_trigger_hut = addrMgrConst::DMI;
       <% } else if (obj.nDIIs > 1) { %>
       trace_trigger_hut = addrMgrConst::DII;
       <% } %>
    end
    if(!$value$plusargs("trace_trigger_hui=%d", trace_trigger_hui)) begin
        if(trace_trigger_hut == addrMgrConst::DMI) begin trace_trigger_hui = $urandom() % num_dmi_huis; end
        else begin trace_trigger_hui = $urandom() % num_dii_huis; end
    end
    if(!$value$plusargs("trace_trigger_memattr=%h", memattr)) memattr = $urandom()&'hF;

    if(!$value$plusargs("trace_trigger_base_addr=%h", trace_trigger_base_addr)) begin
       memregion = $urandom() % num_memregions;
       trace_trigger_base_addr = addrMgrConst::memregions_info[memregion].start_addr;
       trace_trigger_range = addrMgrConst::memregions_info[memregion].size;
    end
    else if(!$value$plusargs("trace_trigger_range=%d", trace_trigger_range)) begin
       `uvm_error("FULLSYS_TEST", $sformatf("trace_trigger_en: trace_trigger_base_addr is set but trace_trigger_range is not set.  Please add +trace_trigger_range=<range>"))
    end
 
    if(!$value$plusargs("aiu<%=unit%>_tctrlr<%=set%>=%h", aiu<%=unit%>_tctrlr[<%=set%>])) begin
       aiu<%=unit%>_tctrlr[<%=set%>].addr_match_en        = (($urandom()%100) < addr_match_weight) ? 1 : 0;
       aiu<%=unit%>_tctrlr[<%=set%>].opcode_match_en      = (($urandom()%100) < opcode_match_weight) ? 1 : 0;
       aiu<%=unit%>_tctrlr[<%=set%>].memattr_match_en     = (($urandom()%100) < memattr_match_weight) ? 1 : 0;
       aiu<%=unit%>_tctrlr[<%=set%>].target_type_match_en = (($urandom()%100) < target_match_weight) ? 1 : 0;
       aiu<%=unit%>_tctrlr[<%=set%>].hut                  = trace_trigger_hut;
       aiu<%=unit%>_tctrlr[<%=set%>].hui                  = trace_trigger_hui;
       aiu<%=unit%>_tctrlr[<%=set%>].range                = trace_trigger_range;
       aiu<%=unit%>_tctrlr[<%=set%>].aw                   = (aiu<%=unit%>_tctrlr[<%=set%>].memattr_match_en==0) ? 0 : (($urandom()%100) < memattr_aw_match_weight) ? 1 : 0;
       aiu<%=unit%>_tctrlr[<%=set%>].ar                   = (aiu<%=unit%>_tctrlr[<%=set%>].memattr_match_en==0) ? 0 : ((aiu<%=unit%>_tctrlr[<%=set%>].aw==0) ? 1 : (($urandom()%100) < memattr_ar_match_weight) ? 1 : 0);
       aiu<%=unit%>_tctrlr[<%=set%>].memattr              = (aiu<%=unit%>_tctrlr[<%=set%>].memattr_match_en==0) ? 0 : memattr;

       <% if (obj.AiuInfo[unit].fnNativeInterface.match('CHI')) { %>
          <% if(obj.AiuInfo[unit].interfaces.chiInt.params.TraceTag > 0) { %>
       aiu<%=unit%>_tctrlr[<%=set%>].native_trace_en      = (($urandom()%100) < native_match_weight) ? 1 : 0;
          <% } else { %>
       aiu<%=unit%>_tctrlr[<%=set%>].native_trace_en      = 0;
          <% } %>

          <% if(obj.AiuInfo[unit].interfaces.chiInt.params.REQ_RSVDC > 0) { %>
       aiu<%=unit%>_tctrlr[<%=set%>].user_match_en        = (($urandom()%100) < user_match_weight) ? 1 : 0;
          <% } else { %>
       aiu<%=unit%>_tctrlr[<%=set%>].user_match_en        = 0;
          <% } %>
       <% } else { %>
          <% if(aiu_axiInt[unit].params.eTrace > 0) { %>
       aiu<%=unit%>_tctrlr[<%=set%>].native_trace_en      = (($urandom()%100) < native_match_weight) ? 1 : 0;
          <% } else { %>
       aiu<%=unit%>_tctrlr[<%=set%>].native_trace_en      = 0;
          <% } %>

          <% if((aiu_axiInt[unit].params.wAwUser == 0) || (aiu_axiInt[unit].params.wArUser == 0)) { %>
       aiu<%=unit%>_tctrlr[<%=set%>].user_match_en        = 0;
          <% } else { %>
       aiu<%=unit%>_tctrlr[<%=set%>].user_match_en        = (($urandom()%100) < user_match_weight) ? 1 : 0;
          <% } %>
       <% } %>
       `uvm_info("FULLSYS_TEST", $sformatf("trace_trigger_en: setting aiu<%=unit%>_tctrlr[<%=set%>] = %p", aiu<%=unit%>_tctrlr[<%=set%>]), UVM_MEDIUM)
    end

    <% if (obj.AiuInfo[unit].fnNativeInterface == 'AXI4') { %>
    // opcode_match_en should always be set to 0 if the native interface is AXI4 - Ref JIRA CONC-8084
      aiu<%=unit%>_tctrlr[<%=set%>].opcode_match_en = 1'b0;
    <% } %>

    aiu<%=unit%>_tbalr[<%=set%>] = trace_trigger_base_addr[43:12];
    `uvm_info("FULLSYS_TEST", $sformatf("trace_trigger_en: setting aiu<%=unit%>_tbalr[<%=set%>] = %p", aiu<%=unit%>_tbalr[<%=set%>]), UVM_MEDIUM)

    aiu<%=unit%>_tbahr[<%=set%>] = trace_trigger_base_addr[51:44];
    `uvm_info("FULLSYS_TEST", $sformatf("trace_trigger_en: setting aiu<%=unit%>_tbahr[<%=set%>] = %p", aiu<%=unit%>_tbahr[<%=set%>]), UVM_MEDIUM)

    if(!$value$plusargs("aiu<%=unit%>_topcr0<%=set%>=%h", aiu<%=unit%>_topcr0[<%=set%>])) begin
       <% if(obj.AiuInfo[unit].fnNativeInterface == 'CHI-A') { %>
          aiu<%=unit%>_topcr0[<%=set%>].valid1 = $urandom()%2;
          aiu<%=unit%>_topcr0[<%=set%>].valid2 = $urandom()%2;
          aiu<%=unit%>_topcr0[<%=set%>].opcode1 = $urandom()%'h1D;
          aiu<%=unit%>_topcr0[<%=set%>].opcode2 = $urandom()%'h1D;
       <% } else if(obj.AiuInfo[unit].fnNativeInterface == 'CHI-B' || obj.AiuInfo[unit].fnNativeInterface == 'CHI-E') { %>
          aiu<%=unit%>_topcr0[<%=set%>].valid1 = $urandom()%2;
          aiu<%=unit%>_topcr0[<%=set%>].valid2 = $urandom()%2;
          aiu<%=unit%>_topcr0[<%=set%>].opcode1 = $urandom()%'h3A;
          aiu<%=unit%>_topcr0[<%=set%>].opcode2 = $urandom()%'h3A;
       <% } else if (obj.AiuInfo[unit].fnNativeInterface == 'ACE' || obj.AiuInfo[unit].fnNativeInterface == 'ACE5' ||obj.AiuInfo[unit].fnNativeInterface == 'ACELITE' || obj.AiuInfo[unit].fnNativeInterface == 'ACELITE-E') { %>
          aiu<%=unit%>_topcr0[<%=set%>].valid1 = $urandom()%2;
          aiu<%=unit%>_topcr0[<%=set%>].valid2 = $urandom()%2;
          aiu<%=unit%>_topcr0[<%=set%>].opcode1 = $urandom()%'h2B;
          aiu<%=unit%>_topcr0[<%=set%>].opcode2 = $urandom()%'h2B;
       <% } else { %>
          aiu<%=unit%>_topcr0[<%=set%>].valid1 = 0;
          aiu<%=unit%>_topcr0[<%=set%>].valid2 = 0;
          aiu<%=unit%>_topcr0[<%=set%>].opcode1 = 0;
          aiu<%=unit%>_topcr0[<%=set%>].opcode2 = 0;
       <% } %>
       `uvm_info("FULLSYS_TEST", $sformatf("trace_trigger_en: setting aiu<%=unit%>_topcr0[<%=set%>] = %p", aiu<%=unit%>_topcr0[<%=set%>]), UVM_MEDIUM)
    end
    if(!$value$plusargs("aiu<%=unit%>_topcr1<%=set%>=%h", aiu<%=unit%>_topcr1[<%=set%>])) begin
       <% if(obj.AiuInfo[unit].fnNativeInterface == 'CHI-A') { %>
          aiu<%=unit%>_topcr1[<%=set%>].valid3 = $urandom()%2;
          aiu<%=unit%>_topcr1[<%=set%>].valid4 = $urandom()%2;
          aiu<%=unit%>_topcr1[<%=set%>].opcode3 = $urandom()%'h1D;
          aiu<%=unit%>_topcr1[<%=set%>].opcode4 = $urandom()%'h1D;
       <% } else if(obj.AiuInfo[unit].fnNativeInterface == 'CHI-B' || obj.AiuInfo[unit].fnNativeInterface == 'CHI-E') { %>
          aiu<%=unit%>_topcr1[<%=set%>].valid3 = $urandom()%2;
          aiu<%=unit%>_topcr1[<%=set%>].valid4 = $urandom()%2;
          aiu<%=unit%>_topcr1[<%=set%>].opcode3 = $urandom()%'h3A;
          aiu<%=unit%>_topcr1[<%=set%>].opcode4 = $urandom()%'h3A;
       <% } else if (obj.AiuInfo[unit].fnNativeInterface == 'ACE' || obj.AiuInfo[unit].fnNativeInterface == 'ACE5' ||obj.AiuInfo[unit].fnNativeInterface == 'ACELITE' || obj.AiuInfo[unit].fnNativeInterface == 'ACELITE-E') { %>
          aiu<%=unit%>_topcr1[<%=set%>].valid3 = $urandom()%2;
          aiu<%=unit%>_topcr1[<%=set%>].valid4 = $urandom()%2;
          aiu<%=unit%>_topcr1[<%=set%>].opcode3 = $urandom()%'h2B;
          aiu<%=unit%>_topcr1[<%=set%>].opcode4 = $urandom()%'h2B;
       <% } else { %>
          aiu<%=unit%>_topcr1[<%=set%>].valid3 = 0;
          aiu<%=unit%>_topcr1[<%=set%>].valid4 = 0;
          aiu<%=unit%>_topcr1[<%=set%>].opcode3 = 0;
          aiu<%=unit%>_topcr1[<%=set%>].opcode4 = 0;
       <% } %>
       `uvm_info("FULLSYS_TEST", $sformatf("trace_trigger_en: setting aiu<%=unit%>_topcr1[<%=set%>] = %p", aiu<%=unit%>_topcr1[<%=set%>]), UVM_MEDIUM)
    end
    if(!$value$plusargs("aiu<%=unit%>_tubr<%=set%>=%h", aiu<%=unit%>_tubr[<%=set%>])) begin
       <% if (obj.AiuInfo[unit].fnNativeInterface.match('CHI')) { %>
       <% if (obj.AiuInfo[unit].interfaces.chiInt.params.REQ_RSVDC > 0) { %>
       if(aiu<%=unit%>_tctrlr[<%=set%>].user_match_en) begin
          aiu<%=unit%>_tubr[<%=set%>] = $urandom() & {<%=obj.AiuInfo[unit].interfaces.chiInt.params.REQ_RSVDC%>{1'b1}};
       end else begin
          aiu<%=unit%>_tubr[<%=set%>] = 0;
       end
       <% } else { %>
          aiu<%=unit%>_tubr[<%=set%>] = 0;
       <% } %>
       <% } else { %>
       <% if ((aiu_axiInt[unit].params.wAwUser > 0) && (aiu_axiInt[unit].params.wArUser > 0)) { %>
       if(aiu<%=unit%>_tctrlr[<%=set%>].user_match_en) begin
          <% if(aiu_axiInt[unit].params.wAwUser < aiu_axiInt[unit].params.wArUser) { %>
          aiu<%=unit%>_tubr[<%=set%>] = $urandom() & {<%=aiu_axiInt[unit].params.wAwUser%>{1'b1}};
          <% } else { %>
          aiu<%=unit%>_tubr[<%=set%>] = $urandom() & {<%=aiu_axiInt[unit].params.wArUser%>{1'b1}};
          <% } %>
       end else begin
          aiu<%=unit%>_tubr[<%=set%>] = 0;
       end
       <% } else { %>
          aiu<%=unit%>_tubr[<%=set%>] = 0;
       <% } %>
       <% } %>
        `uvm_info("FULLSYS_TEST", $sformatf("trace_trigger_en: setting aiu<%=unit%>_tubr[<%=set%>] = %p", aiu<%=unit%>_tubr[<%=set%>]), UVM_MEDIUM)
    end
    if(!$value$plusargs("aiu<%=unit%>_tubmr<%=set%>=%h", aiu<%=unit%>_tubmr[<%=set%>])) begin
       <% if ((obj.AiuInfo[unit].fnNativeInterface.match('CHI'))) { %>
       <% if (obj.AiuInfo[unit].interfaces.chiInt.params.REQ_RSVDC > 0) { %>
       if(aiu<%=unit%>_tctrlr[<%=set%>].user_match_en) begin
          aiu<%=unit%>_tubmr[<%=set%>] = $urandom() & {<%=obj.AiuInfo[unit].interfaces.chiInt.params.REQ_RSVDC%>{1'b1}};
       end else begin
          aiu<%=unit%>_tubmr[<%=set%>] = 0;
       end
       <% } else { %>
          aiu<%=unit%>_tubmr[<%=set%>] = 0;
       <% } %>
       <% } else { %>
       <% if ((aiu_axiInt[unit].params.wAwUser > 0) && (aiu_axiInt[unit].params.wArUser > 0)) { %>
       if(aiu<%=unit%>_tctrlr[<%=set%>].user_match_en) begin
          <% if(aiu_axiInt[unit].params.wAwUser < aiu_axiInt[unit].params.wArUser) { %>
          aiu<%=unit%>_tubmr[<%=set%>] = $urandom() & {<%=aiu_axiInt[unit].params.wAwUser%>{1'b1}};
          <% } else { %>
          aiu<%=unit%>_tubmr[<%=set%>] = $urandom() & {<%=aiu_axiInt[unit].params.wArUser%>{1'b1}};
          <% } %>
       end else begin
          aiu<%=unit%>_tubmr[<%=set%>] = 0;
       end
       <% } else { %>
          aiu<%=unit%>_tubmr[<%=set%>] = 0;
       <% } %>
       <% } %>
       `uvm_info("FULLSYS_TEST", $sformatf("trace_trigger_en: setting aiu<%=unit%>_tubmr[<%=set%>] = %p", aiu<%=unit%>_tubmr[<%=set%>]), UVM_MEDIUM)
    end

    trace_trigger_en_q.push_back(aiu<%=unit%>_tbalr[<%=set%>]);
    trace_trigger_en_q.push_back(aiu<%=unit%>_tbahr[<%=set%>]);
    trace_trigger_en_q.push_back(aiu<%=unit%>_topcr0[<%=set%>]);
    trace_trigger_en_q.push_back(aiu<%=unit%>_topcr1[<%=set%>]);
    trace_trigger_en_q.push_back(aiu<%=unit%>_tubr[<%=set%>]);
    trace_trigger_en_q.push_back(aiu<%=unit%>_tubmr[<%=set%>]);
    trace_trigger_en_q.push_back(aiu<%=unit%>_tctrlr[<%=set%>]);
    <% } %>
    end // else: !if(programming_aiu == <%=unit%>)						 
<% } %>

<% if(found_csr_access_ioaiu > 0) { %>
      `uvm_info("FULLSYS_TEST", $sformatf("trace_trigger programming using IOAIU<%=csrAccess_ioaiu%>"), UVM_NONE)
       ioaiu_trace_trigger_program<%=csrAccess_ioaiu%>(trace_trigger_en_q);	
<% } else { %>
      `uvm_info("FULLSYS_TEST", $sformatf("trace_trigger programming using CHIAIU<%=csrAccess_chiaiu%>"), UVM_NONE)
      // CLU REMOVE TODO use APB PORT DEBUG write instead of CHI OR IOAIU write CSR// m_chi<%=csrAccess_chiaiu%>_vseq.chi_trace_trigger_program(trace_trigger_en_q);	
<% } %>

    // assign trace trigger values to AIU scoreboards
<% var cidx=0; var ioidx=0;
for(var unit = 0; unit < obj.nAIUs; unit++) { %>
    <% if((obj.AiuInfo[unit].fnNativeInterface.match('CHI'))) { %>
    <% for(var set = 0; set < obj.AiuInfo[unit].nTraceRegisters; set++) { %>
    if(m_args.chiaiu_scb_en) begin
    m_concerto_env.inhouse.m_chiaiu<%=cidx%>_env.m_scb.tctrlr[<%=set%>] = aiu<%=unit%>_tctrlr[<%=set%>];
    m_concerto_env.inhouse.m_chiaiu<%=cidx%>_env.m_scb.tbalr[<%=set%>] = aiu<%=unit%>_tbalr[<%=set%>];
    m_concerto_env.inhouse.m_chiaiu<%=cidx%>_env.m_scb.tbahr[<%=set%>] = aiu<%=unit%>_tbahr[<%=set%>];
    m_concerto_env.inhouse.m_chiaiu<%=cidx%>_env.m_scb.topcr0[<%=set%>] = aiu<%=unit%>_topcr0[<%=set%>];
    m_concerto_env.inhouse.m_chiaiu<%=cidx%>_env.m_scb.topcr1[<%=set%>] = aiu<%=unit%>_topcr1[<%=set%>];
    m_concerto_env.inhouse.m_chiaiu<%=cidx%>_env.m_scb.tubr[<%=set%>] = aiu<%=unit%>_tubr[<%=set%>];
    m_concerto_env.inhouse.m_chiaiu<%=cidx%>_env.m_scb.tubmr[<%=set%>] = aiu<%=unit%>_tubmr[<%=set%>];
    end
    <% } %>
    <% cidx++; }
    else { %>
    <% for(var set = 0; set < obj.AiuInfo[unit].nTraceRegisters; set++) { %>
    uvm_config_db#(int)::set(null, "<%=obj.AiuInfo[unit].strRtlNamePrefix%>_env", "tctrlr_<%=set%>", aiu<%=unit%>_tctrlr[<%=set%>]);
    uvm_config_db#(int)::set(null, "<%=obj.AiuInfo[unit].strRtlNamePrefix%>_env", "tbalr_<%=set%>",  aiu<%=unit%>_tbalr[<%=set%>]);
    uvm_config_db#(int)::set(null, "<%=obj.AiuInfo[unit].strRtlNamePrefix%>_env", "tbahr_<%=set%>",  aiu<%=unit%>_tbahr[<%=set%>]);
    uvm_config_db#(int)::set(null, "<%=obj.AiuInfo[unit].strRtlNamePrefix%>_env", "topcr0_<%=set%>", aiu<%=unit%>_topcr0[<%=set%>]);
    uvm_config_db#(int)::set(null, "<%=obj.AiuInfo[unit].strRtlNamePrefix%>_env", "topcr1_<%=set%>", aiu<%=unit%>_topcr1[<%=set%>]);
    uvm_config_db#(int)::set(null, "<%=obj.AiuInfo[unit].strRtlNamePrefix%>_env", "tubr_<%=set%>",   aiu<%=unit%>_tubr[<%=set%>]);
    uvm_config_db#(int)::set(null, "<%=obj.AiuInfo[unit].strRtlNamePrefix%>_env", "tubmr_<%=set%>",  aiu<%=unit%>_tubmr[<%=set%>]);
    // pass register values to the scoreboard.
    m_trace_trigger_<%=unit%>[0].TCTRLR_write_reg(<%=set%>,aiu<%=unit%>_tctrlr[<%=set%>]);
    m_trace_trigger_<%=unit%>[0].TBALR_write_reg (<%=set%>,aiu<%=unit%>_tbalr[<%=set%>]);
    m_trace_trigger_<%=unit%>[0].TBAHR_write_reg (<%=set%>,aiu<%=unit%>_tbahr[<%=set%>]);
    m_trace_trigger_<%=unit%>[0].TOPCR0_write_reg(<%=set%>,aiu<%=unit%>_topcr0[<%=set%>]);
    m_trace_trigger_<%=unit%>[0].TOPCR1_write_reg(<%=set%>,aiu<%=unit%>_topcr1[<%=set%>]);
    m_trace_trigger_<%=unit%>[0].TUBR_write_reg  (<%=set%>,aiu<%=unit%>_tubr[<%=set%>]);
    m_trace_trigger_<%=unit%>[0].TUBMR_write_reg (<%=set%>,aiu<%=unit%>_tubmr[<%=set%>]);
    m_trace_trigger_<%=unit%>[0].print_trigger_sets_reg_values();
    <% } %>
    <% ioidx++; }
} %>

endtask:trace_trigger_en     

<% for(var idx = 0, qidx=0; idx < obj.nAIUs; idx++) { 
if(!(obj.AiuInfo[idx].fnNativeInterface.match('CHI'))) { %>
<%if(obj.AiuInfo[idx].fnCsrAccess == 1) { %>
task concerto_base_trace_test::ioaiu_trace_capture_program<%=qidx%>(input bit[31:0] trace_capture_queue[$]);
    ioaiu<%=qidx%>_axi_agent_pkg::axi_axaddr_t addr;
    bit [31:0] write_data;
    bit [7:0] rpn;
    bit [7:0] aiu_rpn;
    bit [7:0] dce_rpn;
    bit [7:0] dmi_rpn;
    bit [7:0] dii_rpn;
    bit k_csr_access_only;
    bit nonblocking;								   
    int queue_idx = 0;

    // set csrBaseAddr
    addr = addr_trans_mgr_pkg::addrMgrConst::NRS_REGION_BASE;
    aiu_rpn = 0;
    dce_rpn = aiu_rpn + <%=obj.nAIUs_mpu%>;
    dmi_rpn = dce_rpn + <%=obj.nDCEs%>;
    dii_rpn = dmi_rpn + <%=obj.nDMIs%>;

    // program CCTRLR for AIUs					   
    addr[11:0] = <% if(numChiAiu) {%>m_concerto_env.m_regs.<%=chiaiu0%>.CAIUCCTRLR.get_offset()<%} else {%>m_concerto_env.m_regs.<%if(numNCAiu){%><%=ncaiu0%><%}else{%><%=aceaiu0%><%}%>.XAIUCCTRLR.get_offset()<%}%>;
    write_data = <% if(numChiAiu) {%>m_concerto_env.m_regs.<%=chiaiu0%>.CAIUCCTRLR.get_reset()<%} else {%>m_concerto_env.m_regs.<%if(numNCAiu){%><%=ncaiu0%><%}else{%><%=aceaiu0%><%}%>.XAIUCCTRLR.get_reset()<%}%>;

<% for(var unit = 0; unit < obj.nAIUs_mpu; unit++) { %>
    write_data[7:0] = trace_capture_queue[queue_idx];
    if(write_data[7:0] > 0) begin
       addr[19:12] = aiu_rpn + <%=unit%>;
       `uvm_info("ioaiu_trace_capture_program", $sformatf("Writing <%=_blkid[unit].toUpperCase()%>_<%=_blkportsid[unit]%>.xAIUCCTRLR = 0x%0h @=0x%0h", write_data,addr), UVM_MEDIUM)
       rw_tsks.write_csr<%=qidx%>(addr, write_data);
    end
    queue_idx++;
<% } %>   

<% if(obj.nDMIs > 0) { %>
    // program CCTRLR for DMIs					   
    addr[11:0] = m_concerto_env.m_regs.<%=obj.DmiInfo[0].strRtlNamePrefix%>.DMICCTRLR.get_offset();
    write_data = m_concerto_env.m_regs.<%=obj.DmiInfo[0].strRtlNamePrefix%>.DMICCTRLR.get_reset() & 32'hFFFF_FF00;

<% for(var unit = 0; unit < obj.nDMIs; unit++) { %>
    write_data[7:0] = trace_capture_queue[queue_idx];
    if(write_data[7:0] > 0) begin
       addr[19:12] = dmi_rpn + <%=unit%>;
       `uvm_info("ioaiu_trace_capture_program", $sformatf("Writing DMI<%=unit%>.DMICCTRLR = 0x%0h @=0x%0h", write_data,addr), UVM_MEDIUM)
       rw_tsks.write_csr<%=qidx%>(addr, write_data);
    end
    queue_idx++;
<% } } %>   

<% if(obj.nDIIs > 1) { %>
    // program CCTRLR for DIIs					   
    addr[11:0] = m_concerto_env.m_regs.<%=obj.DiiInfo[0].strRtlNamePrefix%>.DIICCTRLR.get_offset();
    write_data = m_concerto_env.m_regs.<%=obj.DiiInfo[0].strRtlNamePrefix%>.DIICCTRLR.get_reset() & 32'hFFFF_FF00;

<% for(var unit = 0; unit < obj.nDIIs; unit++) { %>
    write_data[7:0] = trace_capture_queue[queue_idx];
    if(write_data[7:0] > 0) begin
       addr[19:12] = dii_rpn + <%=unit%>;
       `uvm_info("ioaiu_trace_capture_program", $sformatf("Writing DII<%=unit%>.DIICCTRLR = 0x%0h @=0x%0h", write_data,addr), UVM_MEDIUM)
       rw_tsks.write_csr<%=qidx%>(addr, write_data);
    end
    queue_idx++;
<% } } %>   
endtask: ioaiu_trace_capture_program<%=qidx%>

task concerto_base_trace_test::ioaiu_trace_accum_check<%=qidx%>(input bit[31:0] trace_capture_queue[$]);
    ioaiu<%=qidx%>_axi_agent_pkg::axi_axaddr_t addr;
    bit [31:0] read_data;
    bit [7:0] dve_rpn;

    int trace_capture_enabled = 0; 

    foreach(trace_capture_queue[queue_idx]) begin
        trace_capture_enabled = trace_capture_enabled | (trace_capture_queue[queue_idx] & 8'hFF);
    end
								   
    // set csrBaseAddr				  								
    addr = addr_trans_mgr_pkg::addrMgrConst::NRS_REGION_BASE;
    dve_rpn = <%=obj.nAIUs%> + <%=obj.nDCEs%> + <%=obj.nDMIs%> + <%=obj.nDIIs%>;

    // read DVE TASCR					   
    addr[19:12] = dve_rpn;
    addr[11:0] = m_concerto_env.m_regs.<%=obj.DveInfo[0].strRtlNamePrefix%>.DVETASCR.get_offset();
    rw_tsks.read_csr<%=qidx%>(addr, read_data);

    if((trace_capture_enabled == 0) && (read_data[0]==0) && disable_bist)
       `uvm_error("ioaiu_trace_accum_check", "Trace Capture is not enabled and Trace Accum buffer is not empty")
  
    if((trace_capture_enabled != 0) && (read_data[0]==1) && !disable_bist)
       `uvm_error("ioaiu_trace_accum_check", "Trace Capture is enabled and Trace Accum buffer is empty")

endtask: ioaiu_trace_accum_check<%=qidx%>

task concerto_base_trace_test::ioaiu_trace_trigger_program<%=qidx%>(input bit[31:0] trace_trigger_queue[$]);
    ioaiu<%=qidx%>_axi_agent_pkg::axi_axaddr_t addr;
    bit [31:0] write_data;
    bit [7:0] aiu_rpn;
    string csr_name;
    int queue_idx = 0;

    // set csrBaseAddr
    addr = addr_trans_mgr_pkg::addrMgrConst::NRS_REGION_BASE;
    aiu_rpn = 0;

<% var cidx=0; var ioidx=0;%>
<% for(var unit = 0; unit < obj.nAIUs; unit++) { %>
   addr[19:12] = aiu_rpn + <%=unit%>;

<% for(var set=0; set<obj.AiuInfo[unit].nTraceRegisters; set++) { %>

<% if (obj.AiuInfo[unit].fnNativeInterface.match('CHI')) { %>
    csr_name = "CAIUTBALR";
    addr[11:0] = m_concerto_env.m_regs.<%=chiaiu0%>.CAIUTBALR<%=set%>.get_offset();
<% } else if(obj.AiuInfo[unit].fnNativeInterface == 'ACE'||obj.AiuInfo[unit].fnNativeInterface == 'ACE5') { %>
    csr_name = "XAIUTBALR";
    addr[11:0] = m_concerto_env.m_regs.<%=aceaiu0%>.XAIUTBALR<%=set%>.get_offset();
<% } else { %>
    csr_name = "XAIUTBALR";
    addr[11:0] = m_concerto_env.m_regs.<%=ncaiu0%>.XAIUTBALR<%=set%>.get_offset();
<% } %>
    write_data = trace_trigger_queue[queue_idx];
    `uvm_info("ioaiu_trace_trigger_program", $sformatf("Writing AIU<%=unit%>.%s[<%=set%>] = 0x%0h", csr_name, write_data), UVM_MEDIUM)
    rw_tsks.write_csr<%=qidx%>(addr, write_data);
    queue_idx++;

<% if (obj.AiuInfo[unit].fnNativeInterface.match('CHI')) { %>
    csr_name = "CAIUTBAHR";
    addr[11:0] = m_concerto_env.m_regs.<%=chiaiu0%>.CAIUTBAHR<%=set%>.get_offset();
<% } else if(obj.AiuInfo[unit].fnNativeInterface == 'ACE'||obj.AiuInfo[unit].fnNativeInterface == 'ACE5') { %>
    csr_name = "XAIUTBAHR";
    addr[11:0] = m_concerto_env.m_regs.<%=aceaiu0%>.XAIUTBAHR<%=set%>.get_offset();
<% } else { %>
    csr_name = "XAIUTBAHR";
    addr[11:0] = m_concerto_env.m_regs.<%=ncaiu0%>.XAIUTBAHR<%=set%>.get_offset();
<% } %>
    write_data = trace_trigger_queue[queue_idx];
    `uvm_info("ioaiu_trace_trigger_program", $sformatf("Writing AIU<%=unit%>.%s[<%=set%>] = 0x%0h", csr_name, write_data), UVM_MEDIUM)
    rw_tsks.write_csr<%=qidx%>(addr, write_data);
    queue_idx++;

<% if (obj.AiuInfo[unit].fnNativeInterface.match('CHI')) { %>
    csr_name = "CAIUTOPCR0";
    addr[11:0] = m_concerto_env.m_regs.<%=chiaiu0%>.CAIUTOPCR0<%=set%>.get_offset();
<% } else if(obj.AiuInfo[unit].fnNativeInterface == 'ACE'||obj.AiuInfo[unit].fnNativeInterface == 'ACE5') { %>
    csr_name = "XAIUTOPCR0";
    addr[11:0] = m_concerto_env.m_regs.<%=aceaiu0%>.XAIUTOPCR0<%=set%>.get_offset();
<% } else { %>
    csr_name = "XAIUTOPCR0";
    addr[11:0] = m_concerto_env.m_regs.<%=ncaiu0%>.XAIUTOPCR0<%=set%>.get_offset();
<% } %>
    write_data = trace_trigger_queue[queue_idx];
    `uvm_info("ioaiu_trace_trigger_program", $sformatf("Writing AIU<%=unit%>.%s[<%=set%>] = 0x%0h", csr_name, write_data), UVM_MEDIUM)
    rw_tsks.write_csr<%=qidx%>(addr, write_data);
    queue_idx++;

<% if (obj.AiuInfo[unit].fnNativeInterface.match('CHI')) { %>
    csr_name = "CAIUTOPCR1";
    addr[11:0] = m_concerto_env.m_regs.<%=chiaiu0%>.CAIUTOPCR1<%=set%>.get_offset();
<% } else if(obj.AiuInfo[unit].fnNativeInterface == 'ACE'||obj.AiuInfo[unit].fnNativeInterface == 'ACE5') { %>
    csr_name = "XAIUTOPCR1";
    addr[11:0] = m_concerto_env.m_regs.<%=aceaiu0%>.XAIUTOPCR1<%=set%>.get_offset();
<% } else { %>
    csr_name = "XAIUTOPCR1";
    addr[11:0] = m_concerto_env.m_regs.<%=ncaiu0%>.XAIUTOPCR1<%=set%>.get_offset();
<% } %>
    write_data = trace_trigger_queue[queue_idx];
    `uvm_info("ioaiu_trace_trigger_program", $sformatf("Writing AIU<%=unit%>.%s[<%=set%>] = 0x%0h", csr_name, write_data), UVM_MEDIUM)
    rw_tsks.write_csr<%=qidx%>(addr, write_data);
    queue_idx++;

<% if (obj.AiuInfo[unit].fnNativeInterface.match('CHI')) { %>
    csr_name = "CAIUTUBR";
    addr[11:0] = m_concerto_env.m_regs.<%=chiaiu0%>.CAIUTUBR<%=set%>.get_offset();
<% } else if(obj.AiuInfo[unit].fnNativeInterface == 'ACE'||obj.AiuInfo[unit].fnNativeInterface == 'ACE5') { %>
    csr_name = "XAIUTUBR";
    addr[11:0] = m_concerto_env.m_regs.<%=aceaiu0%>.XAIUTUBR<%=set%>.get_offset();
<% } else { %>
    csr_name = "XAIUTUBR";
    addr[11:0] = m_concerto_env.m_regs.<%=ncaiu0%>.XAIUTUBR<%=set%>.get_offset();
<% } %>
    write_data = trace_trigger_queue[queue_idx];
    `uvm_info("ioaiu_trace_trigger_program", $sformatf("Writing AIU<%=unit%>.%s[<%=set%>] = 0x%0h", csr_name, write_data), UVM_MEDIUM)
    rw_tsks.write_csr<%=qidx%>(addr, write_data);
    queue_idx++;

<% if (obj.AiuInfo[unit].fnNativeInterface.match('CHI')) { %>
    csr_name = "CAIUTUBMR";
    addr[11:0] = m_concerto_env.m_regs.<%=chiaiu0%>.CAIUTUBMR<%=set%>.get_offset();
<% } else if(obj.AiuInfo[unit].fnNativeInterface == 'ACE'||obj.AiuInfo[unit].fnNativeInterface == 'ACE5') { %>
    csr_name = "XAIUTUBMR";
    addr[11:0] = m_concerto_env.m_regs.<%=aceaiu0%>.XAIUTUBMR<%=set%>.get_offset();
<% } else { %>
    csr_name = "XAIUTUBMR";
    addr[11:0] = m_concerto_env.m_regs.<%=ncaiu0%>.XAIUTUBMR<%=set%>.get_offset();
<% } %>
    write_data = trace_trigger_queue[queue_idx];
    `uvm_info("ioaiu_trace_trigger_program", $sformatf("Writing AIU<%=unit%>.%s[<%=set%>] = 0x%0h", csr_name, write_data), UVM_MEDIUM)
    rw_tsks.write_csr<%=qidx%>(addr, write_data);
    queue_idx++;

<% if (obj.AiuInfo[unit].fnNativeInterface.match('CHI')) { %>
    csr_name = "CAIUTCTRLR";
    addr[11:0] = m_concerto_env.m_regs.<%=chiaiu0%>.CAIUTCTRLR<%=set%>.get_offset();
<% } else if(obj.AiuInfo[unit].fnNativeInterface == 'ACE'||obj.AiuInfo[unit].fnNativeInterface == 'ACE5') { %>
    csr_name = "XAIUTCTRLR";
    addr[11:0] = m_concerto_env.m_regs.<%=aceaiu0%>.XAIUTCTRLR<%=set%>.get_offset();
<% } else { %>
    csr_name = "XAIUTCTRLR";
    addr[11:0] = m_concerto_env.m_regs.<%=ncaiu0%>.XAIUTCTRLR<%=set%>.get_offset();
<% } %>
    write_data = trace_trigger_queue[queue_idx];
    `uvm_info("ioaiu_trace_trigger_program", $sformatf("Writing AIU<%=unit%>.%s[<%=set%>] = 0x%0h", csr_name, write_data), UVM_MEDIUM)
    rw_tsks.write_csr<%=qidx%>(addr, write_data);
<% if(!(obj.AiuInfo[unit].fnNativeInterface.match("CHI"))) { %>
    uvm_config_db#(int)::set(null, "<%=obj.AiuInfo[unit].strRtlNamePrefix%>_env", "tctrlr_<%=set%>", trace_trigger_queue[queue_idx]);
    m_trace_trigger_<%=unit%>[0].TCTRLR_write_reg(<%=set%>,trace_trigger_queue[queue_idx]);
<% } else { %>
    if(m_args.chiaiu_scb_en) begin
        m_concerto_env.inhouse.m_chiaiu<%=cidx%>_env.m_scb.tctrlr[<%=set%>] = trace_trigger_queue[queue_idx];
    end
<% } %>
    queue_idx++;

<% }
    if (obj.AiuInfo[unit].fnNativeInterface.match('CHI'))  {
      cidx++;
    } else { 
      ioidx++;
    } 
} %>   

endtask: ioaiu_trace_trigger_program<%=qidx%>
<% } %>
<%  qidx++; }
  } %>
