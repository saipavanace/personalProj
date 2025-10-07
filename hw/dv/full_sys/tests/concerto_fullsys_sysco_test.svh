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
var numBootIoAiu = 0; // Number of IOAIUs with csr access
var chiaiu0;  // strRtlNamePrefix of chiaiu0
var aceaiu0;  // strRtlNamePrefix of aceaiu0
var ncaiu0;   // strRtlNamePrefix of ncaiu0
var csrAccess_ioaiu;  // IOAIU with csr access
var csrAccess_chiaiu;  // IOAIU with csr access
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
var initiatorAgents   = obj.AiuInfo.length ;
var aiu_NumCores = [];
const aiu_axiInt = [];
const ncAiuName = [];


for(var pidx = 0; pidx < initiatorAgents; pidx++) { 
  if(Array.isArray(obj.AiuInfo[pidx].interfaces.axiInt)) {
      aiu_NumCores[pidx]    = obj.AiuInfo[pidx].interfaces.axiInt.length;
  } else {
      aiu_NumCores[pidx]    = 1;
  }
}

var ncaiu_idx=0;
for(var pidx = 0; pidx < obj.nAIUs; pidx++) {
    if (obj.AiuInfo[pidx].fnNativeInterface.indexOf('CHI') < 0) {
        if(Array.isArray(obj.AiuInfo[pidx].interfaces.axiInt)) {
            aiu_axiInt[pidx] = new Array(obj.AiuInfo[pidx].interfaces.axiInt.length);
            for (var i=0; i<obj.AiuInfo[pidx].interfaces.axiInt.length; i++) {
              aiu_axiInt[pidx][i] = obj.AiuInfo[pidx].interfaces.axiInt[i];
            }
            ncAiuName[ncaiu_idx] = obj.AiuInfo[pidx].strRtlNamePrefix + "_0";
        } else {
            aiu_axiInt[pidx]    = new Array(1);
            aiu_axiInt[pidx][0] = obj.AiuInfo[pidx].interfaces.axiInt;
            ncAiuName[ncaiu_idx]  = obj.AiuInfo[pidx].strRtlNamePrefix;
        }
        ncaiu_idx++;
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
         if(obj.AiuInfo[pidx].fnNativeInterface == "ACE") { if (numACEAiu==0) { aceaiu0=obj.AiuInfo[pidx].strRtlNamePrefix; }
                                                            numCAiu++ ; numACEAiu++; }
         else {  if(Array.isArray(obj.AiuInfo[pidx].interfaces.axiInt)) {
                    if (numNCAiu == 0) { ncaiu0 = obj.AiuInfo[pidx].strRtlNamePrefix + "_0"; }
                 } else {
                    if (numNCAiu == 0) { ncaiu0 = obj.AiuInfo[pidx].strRtlNamePrefix; }
                 }
                 numNCAiu++ ; }
         if(obj.AiuInfo[pidx].useCache) idxIoAiuWithPC = numNCAiu;
         if(obj.AiuInfo[pidx].fnCsrAccess) numBootIoAiu++;
         
       }
}
var chi_idx=0;
var ace_idx=0;
var io_idx=0;
var found_csr_access_chiaiu = 0;
var found_csr_access_ioaiu = 0;
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
            csrAccess_ioaiu = io_idx;    // TODO check usage
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


//File: concerto_fullsys_sysco_test.svh

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



class concerto_fullsys_sysco_test extends concerto_fullsys_test;

    //////////////////
    //Properties
    //////////////////

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

    //////////////////
    //UVM Registery
    //////////////////    
    `uvm_component_utils(concerto_fullsys_sysco_test)
    //////////////////
    //Methods
    //////////////////
    extern function new(string name = "concerto_fullsys_sysco_test", uvm_component parent = null);
    extern virtual function void build_phase(uvm_phase  phase);
    extern virtual function void end_of_elaboration_phase(uvm_phase phase);
    extern virtual task main_seq_iter_post_hook(uvm_phase phase, int iter);// at the end of the iteration (inside the iteration)
    <% 
    var qidx = 0;
    var cidx = 0;
    for(var idx = 0; idx < obj.nAIUs; idx++) { 
       if((obj.AiuInfo[idx].fnNativeInterface == 'CHI-A')||(obj.AiuInfo[idx].fnNativeInterface == 'CHI-B' || obj.AiuInfo[idx].fnNativeInterface == 'CHI-E')) { %>
    extern virtual task chiaiu<%=cidx%>_sysco_attach();
    extern virtual task chiaiu<%=cidx%>_sysco_detach(uvm_phase phase);
    extern virtual task chiaiu<%=cidx%>_cache_flush();
    <% cidx++; %>
    <% } else { %>
       <%if((obj.AiuInfo[idx].fnNativeInterface == 'ACE')) { %>
       ioaiu<%=qidx%>_inhouse_axi_bfm_pkg::ace_master_cache_flush_seq        m_iocacheflush_seq<%=qidx%>[<%=aiu_NumCores[idx]%>];
       <% } %>
    <% if(obj.AiuInfo[idx].fnCsrAccess == 1) { %>
    extern virtual task ioaiu<%=qidx%>_flush_cache(string AiuName);
    extern virtual task ioaiu<%=qidx%>_sysco_attach(string AiuName);
    extern virtual task ioaiu<%=qidx%>_sysco_detach(string AiuName);
    <% } %>
    <% qidx++; } %>
    <% } %>

endclass: concerto_fullsys_sysco_test

//////////////////
//Calling Method: Child Class
//Description: Constructor
//Arguments:   UVM Default
//Return type: N/A
//////////////////
function concerto_fullsys_sysco_test::new(string name = "concerto_fullsys_sysco_test", uvm_component parent = null);
    super.new(name, parent);
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
//////////////////
//Calling Method: UVM Factory
//Description: Build phase
//Arguments:   UVM Default
//Return type: Void
//////////////////
function void concerto_fullsys_sysco_test::build_phase(uvm_phase phase);
    string msg_idx;
    int        transorder_mode;
   

    `uvm_info("Build", "Entered Build Phase", UVM_LOW);
    super.build_phase(phase);

    if($value$plusargs("clk_off_en=%s", clk_off_en_arg)) begin
       if(clk_off_en_arg.tolower() == "all") begin
          for(int clk=0; clk < <%=obj.Clocks.length%>; clk++) begin
         clk_off_en[clk] = 1;
          end
       end
       else begin
          parse_str(clk_off_en_str, "n", clk_off_en_arg);
          foreach (clk_off_en_str[i]) begin
         clk_off_en[clk_off_en_str[i].atoi()] = 1;
          end
       end
    end

    if($value$plusargs("clk_off_chiaiu=%s", clk_off_chiaiu_arg)) begin
       if(clk_off_chiaiu_arg.tolower() == "all") begin
          for(int aiu=0; aiu < <%=numChiAiu%>; aiu++) begin
         clk_off_chiaiu[aiu] = 1;
          end
       end
       else begin
          parse_str(clk_off_chiaiu_str, "n", clk_off_chiaiu_arg); 
          foreach (clk_off_chiaiu_str[i]) begin
         clk_off_chiaiu[clk_off_chiaiu_str[i].atoi()] = 1;
          end
       end
    end

    if($value$plusargs("clk_off_ioaiu=%s", clk_off_ioaiu_arg)) begin
       if(clk_off_ioaiu_arg.tolower() == "all") begin
          for(int aiu=0; aiu < <%=numIoAiu%>; aiu++) begin
         clk_off_ioaiu[aiu] = 1;
          end
       end
       else begin
          parse_str(clk_off_ioaiu_str, "n", clk_off_ioaiu_arg);
          foreach (clk_off_ioaiu_str[i]) begin
         clk_off_ioaiu[clk_off_ioaiu_str[i].atoi()] = 1;
          end
       end
    end

    if(!$value$plusargs("clk_off_time=%d", clk_off_time)) begin
       clk_off_time = 5000;  // time in ns to turn off clock
    end

    set_inactivity_period(m_args.k_timeout);
    
    if ($test$plusargs("clk_off_en")) 
      max_iteration = 1; // if clock_off don't iterate again
    else
      max_iteration = 2;
   <% var qidx=0; for(var pidx = 0; pidx < obj.nAIUs; pidx++) { %>
   <%if((!obj.AiuInfo[pidx].fnNativeInterface.match("CHI"))) { %>
   <%if ((obj.AiuInfo[pidx].fnNativeInterface == 'ACE')) { %>
    <% for(var coreidx=0; coreidx < aiu_NumCores[pidx]; coreidx++) { %>
        m_iocacheflush_seq<%=qidx%>[<%=coreidx%>]                        = ioaiu<%=qidx%>_inhouse_axi_bfm_pkg::ace_master_cache_flush_seq::type_id::create("m_iocacheflush<%=qidx%>_<%=coreidx%>_seq");
   <% } //each core%>
   <% } // if ace%>
    <% qidx++; } // if no CHI %>
  <% } // foreach AIU%>
  
    `uvm_info("Build", "Exited Build Phase", UVM_LOW);

endfunction: build_phase

function void concerto_fullsys_sysco_test::end_of_elaboration_phase(uvm_phase phase);
   super.end_of_elaboration_phase(phase);
<% var qidx=0; for(var pidx = 0; pidx < obj.nAIUs; pidx++) { %>
   <%if((!obj.AiuInfo[pidx].fnNativeInterface.match("CHI"))) { %>
   <%if ((obj.AiuInfo[pidx].fnNativeInterface == 'ACE')) { %>
    <% for(var coreidx=0; coreidx < aiu_NumCores[pidx]; coreidx++) { %>
        m_iocacheflush_seq<%=qidx%>[<%=coreidx%>].m_write_addr_chnl_seqr = m_concerto_env.inhouse.m_ioaiu<%=qidx%>_env.m_env[<%=coreidx%>].m_axi_master_agent.m_write_addr_chnl_seqr;
        m_iocacheflush_seq<%=qidx%>[<%=coreidx%>].m_write_data_chnl_seqr = m_concerto_env.inhouse.m_ioaiu<%=qidx%>_env.m_env[<%=coreidx%>].m_axi_master_agent.m_write_data_chnl_seqr;
        m_iocacheflush_seq<%=qidx%>[<%=coreidx%>].m_write_resp_chnl_seqr = m_concerto_env.inhouse.m_ioaiu<%=qidx%>_env.m_env[<%=coreidx%>].m_axi_master_agent.m_write_resp_chnl_seqr;
        m_iocacheflush_seq<%=qidx%>[<%=coreidx%>].m_ace_cache_model       = m_concerto_env.inhouse.m_ace_cache_model_ioaiu<%=qidx%>[<%=coreidx%>];
   <% } //each core%>
   <% } // if ace%>
    <% qidx++; } // if no CHI %>
  <% } // foreach AIU%>
endfunction: end_of_elaboration_phase
////////////////////////////////////////////////////////////////////////////////////////
// #     #  #######  #######  #    #         #######     #      #####   #    #   #####   
// #     #  #     #  #     #  #   #             #       # #    #     #  #   #   #     #  
// #     #  #     #  #     #  #  #              #      #   #   #        #  #    #        
// #######  #     #  #     #  ###               #     #     #   #####   ###      #####   
// #     #  #     #  #     #  #  #              #     #######        #  #  #          #  
// #     #  #     #  #     #  #   #             #     #     #  #     #  #   #   #     #  
// #     #  #######  #######  #    #  #####     #     #     #   #####   #    #   ##### 
// #Stimulus.FSYS.perfmon.mastercountenable 
////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////
//////////////////// POST HOOK ///////////
task concerto_fullsys_sysco_test::main_seq_iter_post_hook(uvm_phase phase, int iter);
  uvm_reg ral_reg;
  uvm_reg_field ral_field;
  bit [31:0] data;
  bit [31:0] mask;
  uvm_factory factory = uvm_factory::get();

  phase.raise_objection(this, "main_seq_post_hook_run_phase");
  `uvm_info(get_name(), $sformatf("START HOOK main_seq_iter_post_hook iter:%0d",iter), UVM_NONE)
  wait_seq_totaly_done(phase);
  #5us;
  `uvm_info(get_name(), $sformatf("POST_HOOK wait_seq_totaly_done iter:%0d",iter), UVM_NONE)
   <%chiaiu_idx = 0;
  ioaiu_idx = 0;
  for(var pidx = 0; pidx < obj.nAIUs; pidx++) {
  // START CHI_SECTION
  if((obj.AiuInfo[pidx].fnNativeInterface.match("CHI"))) { %>
          
            // 1st thread : CHIAIUs
                    if(chiaiu_en.exists(<%=chiaiu_idx%>)) begin:_chiaiu<%=chiaiu_idx%>
                        chiaiu<%=chiaiu_idx%>_sysco_detach(phase);
                        // do clock off if enabled
                        if(clk_off_chiaiu.exists(<%=chiaiu_idx%>)) begin:_clk_off_chi<%=chiaiu_idx%>
                            `uvm_info("TEST_MAIN", $sformatf("Start CHIAIU<%=chiaiu_idx%> link down"), UVM_NONE)
                            m_chi<%=chiaiu_idx%>_vseq.construct_lnk_down_seq();
                            <% for(var clk=0; clk<obj.Clocks.length; clk++) { %>
                                if(clk_off_en.exists(<%=clk%>)) begin
                                    <% for(var pma=0; pma<obj.PmaInfo.length; pma++) {
                                        if(obj.PmaInfo[pma].unitClk[0] == obj.Clocks[clk].name) { %>
                                            // start PMA
                                            wait(m_concerto_env.inhouse.<%=obj.PmaInfo[pma].strRtlNamePrefix%>_qc_if.QACCEPTn); 
                                            #100ns;
                                            `uvm_info("TEST_MAIN", $sformatf("Start asserting <%=obj.PmaInfo[pma].strRtlNamePrefix%>_qc_if.QREQn"), UVM_NONE)
                                            m_concerto_env.inhouse.m_q_chnl_seq<%=pma%>.start(m_concerto_env.inhouse.m_q_chnl_agent<%=pma%>.m_q_chnl_seqr);
                                            #100ns;
                                        <% } 
                                    } %>
                                    `uvm_info("TEST_MAIN", $sformatf("Turning off tb_top.m_clk_if_<%=clocks[clk]%>.clk for %0d ns after CHI<%=chiaiu_idx%> sequence done", clk_off_time), UVM_NONE)
                                    force tb_top.m_clk_if_<%=clocks[clk]%>.clk = 0;
                                    #(clk_off_time * 1ns);                      
                                    `uvm_info("TEST_MAIN", "Releasing tb_top.m_clk_if_<%=clocks[clk]%>.clk", UVM_NONE)
                                    release tb_top.m_clk_if_<%=clocks[clk]%>.clk;
                                end
                            <% } %>                          
                        end:_clk_off_chi<%=chiaiu_idx%>// if (clk_off_chiaiu.exists(<%=chiaiu_idx%>))
                        if($test$plusargs("enable_sysco_reattach")) begin
                            #10us;
                            chiaiu<%=chiaiu_idx%>_sysco_attach();
                        end
                    end:_chiaiu<%=chiaiu_idx%>
                <% chiaiu_idx++;%>
           
               // END CHI_SECTION
                <%} else { %>
            // START IOAIU_SECTION
            begin:_ioaiu<%=ioaiu_idx%>_section
                // do IOAIU detach
                // First flush all related caches, must be done first for all cores in any given MC AIU. 
                // This is to avoid send Coh traffic after the agent is detached by the first core's detach call
                <% var coreidx=0;for(var coreidx=0; coreidx < aiu_NumCores[pidx]; coreidx++) { %>
                    if(ioaiu_en.exists(<%=ioaiu_idx%>)) begin
                        <% if((obj.AiuInfo[pidx].fnNativeInterface == "ACE") || ((obj.AiuInfo[pidx].fnNativeInterface == "AXI4") && (obj.AiuInfo[pidx].useCache))) { %>
                                `uvm_info("TEST_MAIN", $sformatf("Flush IOAIU<%=ioaiu_idx%>_<%=coreidx%> related caches"), UVM_NONE)
                                phase.raise_objection(this, "IOAIU<%=ioaiu_idx%>_<%=coreidx%> flush_cache");
                                <% if(obj.AiuInfo[pidx].fnNativeInterface == "ACE") { %>
                                    if($test$plusargs("en_cache_flush")) begin
                                        `uvm_info("TEST_MAIN", $sformatf("Start IOAIU<%=ioaiu_idx%>[<%=coreidx%>] ACE Cache Flush Sequence"), UVM_NONE)
                                        m_iocacheflush_seq<%=ioaiu_idx%>[<%=coreidx%>].start(null);
                                        wait_seq_totaly_done(phase);
                                        `uvm_info("TEST_MAIN", $sformatf("IOAIU<%=ioaiu_idx%>[<%=coreidx%>] ACE Cache Flush Sequence done"), UVM_NONE)
                                    end
                                <% } else {// AXI4+$%>
                            <% if(numBootIoAiu > 0) { %>
                                 //always flush proxy cache //if($test$plusargs("en_cache_flush")) begin
                                // The AIU name must take the core index into account, hence the below formula
                                `uvm_info("TEST_MAIN", "Calling ioaiu<%=csrAccess_ioaiu%>_flush_cache(<%=obj.AiuInfo[pidx].strRtlNamePrefix+((aiu_NumCores[pidx]>1)?("_"+coreidx):"")%> for ioaiu<%=ioaiu_idx%>_<%=coreidx%>)", UVM_NONE)
                                ioaiu<%=csrAccess_ioaiu%>_flush_cache("<%=obj.AiuInfo[pidx].strRtlNamePrefix+((aiu_NumCores[pidx]>1)?("_"+coreidx):"")%>"); 
                                wait_seq_totaly_done(phase);
                                 //   end
                            <%} %>
                            <% } //AXI4 + $%>
                                phase.drop_objection(this, "IOAIU<%=ioaiu_idx%>_<%=coreidx%> flush_cache");
                           
                        <%} %>
                    end
                <% } %>
                // Detach phase
                    // For all cores as any given AIU scoreboard in the DV env have their own detach FSM
                    <% var coreidx=0;// for(var coreidx=0; coreidx < aiu_NumCores[pidx]; coreidx++) { %>
                    if(ioaiu_en.exists(<%=ioaiu_idx%>)) begin
                        <% if((((obj.AiuInfo[pidx].fnNativeInterface === "ACELITE-E") || (obj.AiuInfo[pidx].fnNativeInterface === "ACE-LITE")) && (obj.AiuInfo[pidx].cmpInfo.nDvmSnpInFlight > 0)) || (obj.AiuInfo[pidx].fnNativeInterface == "ACE") || ((obj.AiuInfo[pidx].fnNativeInterface == "AXI4") && (obj.AiuInfo[pidx].useCache))) { %>
                            `uvm_info("TEST_MAIN", $sformatf("All ioaiu<%=ioaiu_idx%>_* flush seqs have completed, start the ioaiu<%=ioaiu_idx%> detach seqs"), UVM_NONE)
                            <% if(numBootIoAiu > 0) { %>
                                `uvm_info("TEST_MAIN", "Setting IOAIU<%=ioaiu_idx%>_<%=coreidx%> to DETACH state", UVM_LOW)
                                phase.raise_objection(this, "IOAIU<%=ioaiu_idx%>_<%=coreidx%> detach");                             
                                if (m_concerto_env.inhouse.m_ioaiu<%=ioaiu_idx%>_env.m_env[<%=coreidx%>].m_scb.m_sysco_fsm_state != ioaiu<%=ioaiu_idx%>_env_pkg::DETACH) begin:_check_already_detach_ioaiu<%=ioaiu_idx%>   
                                   if(m_args.ioaiu_scb_en) begin
                                       m_concerto_env.inhouse.m_ioaiu<%=ioaiu_idx%>_env.m_env[<%=coreidx%>].m_scb.m_sysco_fsm_state = ioaiu<%=ioaiu_idx%>_env_pkg::DETACH;   
                                       ev_sysco_fsm_state_change_<%=obj.AiuInfo[pidx].FUnitId%>.trigger();  
                                   end
                                   // Only for core 0, as all cores in any given AIU share the same detach FSM
                                   <% if (coreidx == 0) { %>
                                       // The AIU name must take the core index into account, hence the below formula
                                       `uvm_info("TEST_MAIN", "Calling ioaiu<%=csrAccess_ioaiu%>_sysco_detach(<%=obj.AiuInfo[pidx].strRtlNamePrefix+((aiu_NumCores[pidx]>1)?("_"+coreidx):"")%> for ioaiu<%=ioaiu_idx%>_<%=coreidx%>)", UVM_LOW)
                                       ioaiu<%=csrAccess_ioaiu%>_sysco_detach("<%=obj.AiuInfo[pidx].strRtlNamePrefix+((aiu_NumCores[pidx]>1)?("_"+coreidx):"")%>");  
                                   <% } %> 
                                end:_check_already_detach_ioaiu<%=ioaiu_idx%>
                                phase.drop_objection(this, "IOAIU<%=ioaiu_idx%>_<%=coreidx%> detach");
                            <% }
                        } %>
                    end
                    <% //} %>
                // Do IOAIU clock off if enabled
                if(ioaiu_en.exists(<%=ioaiu_idx%>)) begin:_ioaiu<%=ioaiu_idx%>_exist
                    if(clk_off_ioaiu.exists(<%=ioaiu_idx%>)) begin:_clk_off_ioaiu<%=ioaiu_idx%>
                        phase.raise_objection(this, "IOAIU<%=ioaiu_idx%>_<%=coreidx%> clock off");
                        `uvm_info("TEST_MAIN", $sformatf("All ioaiu<%=ioaiu_idx%>_* detach seqs have completed, start the ioaiu<%=ioaiu_idx%> clock off seqs"), UVM_NONE)
                        <% for(var clk=0; clk<obj.Clocks.length; clk++) { %>
                            if(clk_off_en.exists(<%=clk%>)) begin
                                <% for(var pma=0; pma<obj.PmaInfo.length; pma++) {
                                    if(obj.PmaInfo[pma].unitClk[0] == obj.Clocks[clk].name) { %>
                                        // start PMA
                                        wait(m_concerto_env.inhouse.<%=obj.PmaInfo[pma].strRtlNamePrefix%>_qc_if.QACCEPTn); 
                                        #100ns;
                                        `uvm_info("TEST_MAIN", $sformatf("Start asserting m_concerto_env.inhouse.<%=obj.PmaInfo[pma].strRtlNamePrefix%>_qc_if.QREQn"), UVM_NONE)
                                        m_concerto_env.inhouse.m_q_chnl_seq<%=pma%>.start(m_concerto_env.inhouse.m_q_chnl_agent<%=pma%>.m_q_chnl_seqr);
                                        #100ns;
                                    <% } 
                                } %>
                                `uvm_info("TEST_MAIN", $sformatf("Turning off tb_top.m_clk_if_<%=clocks[clk]%>.clk for %0d ns after IOAIU<%=ioaiu_idx%> sequence done", clk_off_time), UVM_NONE)
                                #(200*1ns);
                                force tb_top.m_clk_if_<%=clocks[clk]%>.clk = 0;
                                #(clk_off_time * 1ns);                      
                                `uvm_info("TEST_MAIN", "Releasing tb_top.m_clk_if_<%=clocks[clk]%>.clk", UVM_NONE)
                                release tb_top.m_clk_if_<%=clocks[clk]%>.clk;
                            end
                        <% } %>                          
                        #5us; // still wait a bit after detach
                        phase.drop_objection(this, "IOAIU<%=ioaiu_idx%>_<%=coreidx%> clock off");
                    end:_clk_off_ioaiu<%=ioaiu_idx%>
                    // do IOAIU reattach if enabled
                        <% if((((obj.AiuInfo[pidx].fnNativeInterface === "ACELITE-E") || (obj.AiuInfo[pidx].fnNativeInterface === "ACE-LITE")) && (obj.AiuInfo[pidx].cmpInfo.nDvmSnpInFlight > 0)) || (obj.AiuInfo[pidx].fnNativeInterface == "ACE") || ((obj.AiuInfo[pidx].fnNativeInterface == "AXI4") && (obj.AiuInfo[pidx].useCache))) { %>
                        `uvm_info("TEST_MAIN", $sformatf("All ioaiu<%=ioaiu_idx%>_* detach seqs have completed, start the ioaiu<%=ioaiu_idx%> reattach seqs"), UVM_NONE)
                            <% if(numBootIoAiu > 0) { %>
                                <% var coreidx=0;//for(var coreidx=0; coreidx < aiu_NumCores[pidx]; coreidx++) { %>
                                    // For all cores as any given AIU scoreboard in the DV env have their own detach FSM
                                    if($test$plusargs("enable_sysco_reattach")) begin   // TODO move this cond 3 levels up
                                        `uvm_info("TEST_MAIN", "Setting IOAIU<%=ioaiu_idx%>_<%=coreidx%> to CONNECT state", UVM_LOW)
                                        phase.raise_objection(this, "IOAIU<%=ioaiu_idx%>_<%=coreidx%> reattach");
                                        if(m_args.ioaiu_scb_en) begin
                                            m_concerto_env.inhouse.m_ioaiu<%=ioaiu_idx%>_env.m_env[<%=coreidx%>].m_scb.m_sysco_fsm_state = ioaiu<%=ioaiu_idx%>_env_pkg::CONNECT;   
                                            ev_sysco_fsm_state_change_<%=obj.AiuInfo[pidx].FUnitId%>.trigger();
                                        end
                                        // Only for core 0, as all cores in any given AIU in the RTL share the same detach FSM
                                        <% if (coreidx == 0) { %>
                                            // The AIU name must take the core index into account, hence the below formula
                                            `uvm_info("TEST_MAIN", "Calling ioaiu<%=csrAccess_ioaiu%>_sysco_attach(<%=obj.AiuInfo[pidx].nUnitId%>) for <%=obj.AiuInfo[pidx].strRtlNamePrefix+((aiu_NumCores[pidx]>1)?("_"+coreidx):"")%>", UVM_LOW)
                                            ioaiu<%=csrAccess_ioaiu%>_sysco_attach("<%=obj.AiuInfo[pidx].strRtlNamePrefix+((aiu_NumCores[pidx]>1)?("_"+coreidx):"")%>");
                                        <% } %> 
                                        phase.drop_objection(this, "IOAIU<%=ioaiu_idx%>_<%=coreidx%> reattach");     
                                    end
                                <% //} 
                            }
                        } %>
                end:_ioaiu<%=ioaiu_idx%>_exist
            end:_ioaiu<%=ioaiu_idx%>_section
            <% ioaiu_idx++;
            }
            // END IOAIU_SECTION
            } %>
if( !$test$plusargs("enable_sysco_reattach")) begin:_noreattach_only_noncoh_txn
   `uvm_info(get_name(), "!!! NO REATTACH set all txn to NONCOHERENT only for the next iteration!!!!", UVM_NONE)
   if(m_concerto_env_cfg.has_chi_vip_snps) begin:_chi_vip
            `ifdef CHI_UNITS_CNT_NON_ZERO
            factory.set_type_override_by_name(test_cfg.chi_txn_seq_name,"chi_subsys_regular_noncoh_item_connect");
            `endif // CHI_UNITS_CNT_NON_ZERO
            factory.print(0); // print only override
    end:_chi_vip 
   <% var chiaiu_idx=0;var ioaiu_idx=0; for(var pidx = 0; pidx < obj.nAIUs; pidx++) { %>
   <% if (obj.AiuInfo[pidx].fnNativeInterface.match("CHI")) { %>
                    m_chi<%=chiaiu_idx%>_args.k_rd_noncoh_pct.set_value(100);
                    m_chi<%=chiaiu_idx%>_args.k_rd_ldrstr_pct.set_value(0);
                    m_chi<%=chiaiu_idx%>_args.k_rq_lcrdrt_pct.set_value(0); 
                    m_chi<%=chiaiu_idx%>_args.k_rd_rdonce_pct.set_value(0);
                    m_chi<%=chiaiu_idx%>_args.k_dt_ls_upd_pct.set_value(0);
                    m_chi<%=chiaiu_idx%>_args.k_dt_ls_cmo_pct.set_value(0);
                    m_chi<%=chiaiu_idx%>_args.k_dt_ls_sth_pct.set_value(0);
                    m_chi<%=chiaiu_idx%>_args.k_wr_noncoh_pct.set_value(100);
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
    <% chiaiu_idx++;%>
    <%} else { %> 
      <% for(var i=0; i<aiu_NumCores[pidx]; i++) { %>
                    io_subsys_mstr_seq_cfg_inhouse<%=ioaiu_idx%>.dont_use_cfg_obj_wt_in_mstr_pipelined_seq = 1;
                    uvm_config_db #(ioaiu<%=ioaiu_idx%>_inhouse_axi_bfm_pkg::mstr_seq_cfg)::set(uvm_root::get(),"*", $sformatf("<%=obj.AiuInfo[pidx].fnNativeInterface%>_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>_mstr_seq_cfg_p<%=ioaiu_idx%>_s%0d",seq_id), io_subsys_mstr_seq_cfg_inhouse<%=ioaiu_idx%>);
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
end:_noreattach_only_noncoh_txn  
    `ifndef USE_VIP_SNPS 
      `ifdef VCS
      super.main_seq_iter_post_hook(phase,iter); 
      `endif // `ifdef VCS
   `endif // `ifndef USE_VIP_SNPS 

`uvm_info(get_name(), $sformatf("END HOOK main_seq_iter_post_hook iter:%0d",iter), UVM_NONE)
phase.drop_objection(this, "main_seq_post_hook_run_phase");
endtask:main_seq_iter_post_hook

////////////////////////////////////////////////////////////////////
//#######  #     #  #     #   #####   #######  ###  #######  #     #  
//#        #     #  ##    #  #     #     #      #   #     #  ##    #  
//#        #     #  # #   #  #           #      #   #     #  # #   #  
//#####    #     #  #  #  #  #           #      #   #     #  #  #  #  
//#        #     #  #   # #  #           #      #   #     #  #   # #  
//#        #     #  #    ##  #     #     #      #   #     #  #    ##  
//#         #####   #     #   #####      #     ###  #######  #     #  
////////////////////////////////////////////////////////////////////
<%
var cidx = 0;
var qidx = 0;
for(var idx = 0; idx < obj.nAIUs; idx++) { 
    if((obj.AiuInfo[idx].fnNativeInterface == 'CHI-A')||(obj.AiuInfo[idx].fnNativeInterface == 'CHI-B' || obj.AiuInfo[idx].fnNativeInterface == 'CHI-E')) { %>

task concerto_fullsys_sysco_test::chiaiu<%=cidx%>_sysco_attach();
    chiaiu<%=cidx%>_chi_container_pkg::addr_width_t addr;
    bit [31:0] data;
    bit sysco_attach;
    int num_loop = 100;

    `uvm_info("TEST_MAIN", $sformatf("chiaiu<%=cidx%>_sysco_attach: Attaching CHIAIU<%=cidx%>"), UVM_NONE)

     if(m_concerto_env_cfg.has_chi_vip_snps) begin:_chi_vip<%=cidx%>
       `uvm_info(get_name(), "USE_VIP_SNPS coherency_entry_seq::ONGOING[<%=cidx%>]", UVM_NONE)
        coherency_entry_seq<%=cidx%>.randomize();
       // fork:entry_seq  // need fork because some issue with protocol service sequencer
        coherency_entry_seq<%=cidx%>.start(m_concerto_env.snps.svt.amba_system_env.chi_system[0].rn[<%=cidx%>].prot_svc_seqr);
       // join_any:entry_seq
        `uvm_info(get_name(), "USE_VIP_SNPS coherency_entry_seq::END[<%=cidx%>]", UVM_NONE)
        // poll for attach state
         wait(m_concerto_env.snps.svt.amba_system_env.chi_system[0].rn[<%=cidx%>].shared_status.sysco_interface_state == svt_chi_status::COHERENCY_ENABLED_STATE);
        // disable entry_seq;// issue in the service sequencer 
     end:_chi_vip<%=cidx%> else begin:_inhouse_chi<%=cidx%>
         ev_toggle_sysco_chiaiu<%=cidx%>.trigger(m_concerto_env.inhouse.m_chi<%=cidx%>_container);
     end:_inhouse_chi<%=cidx%>

    `uvm_info("TEST_MAIN", $sformatf("chiaiu<%=cidx%>_sysco_attach: CHIAIU<%=cidx%> is attached"), UVM_NONE)
    if(m_args.chiaiu_scb_en) begin
       wait (m_concerto_env.inhouse.m_chiaiu<%=cidx%>_env.m_scb.m_sysco_st ==  chiaiu<%=cidx%>_chi_aiu_vseq_pkg::ENABLED);
       `uvm_info("TEST_MAIN", $sformatf("chiaiu<%=cidx%>_sysco_attach: CHIAIU<%=cidx%> is attached (SCB)"), UVM_NONE)
    end else begin
      #1us;                                                       
    end
endtask

task concerto_fullsys_sysco_test::chiaiu<%=cidx%>_cache_flush();
   
    if(m_concerto_env_cfg.has_chi_vip_snps) begin:_chi_vip<%=cidx%>
    //!!!!!!!!!!!
   // REMOVE ALREADY DONE IN THE svt_chi_protocol_service_coherency_exit_sequence ///
   //!!!!!!!!!!!!
   //   svt_axi_cache::addr_t  q_cache_addr[$];
   // // Get all the addr in the CHI cache
   //   if (m_concerto_env.snps.svt.amba_system_env.chi_system[0].rn[<%=cidx%>].rn_cache.get_tagged_addresses_for_matched_cache_state ( -1, -1, q_cache_addr) ) begin:_flush_cache_chi<%=cidx%>
   //   `uvm_info("SNPS_FLUSH", "chiaiu<%=cidx%> flush ongoing...", UVM_NONE)
   //   foreach (q_cache_addr[i]) begin:_addr_flush<%=cidx%>
   //      svt_chi_system_cacheline_invalidation_virtual_sequence cacheline_invalidation;
   //      cacheline_invalidation = svt_chi_system_cacheline_invalidation_virtual_sequence::type_id::create("cacheline_invalidation");
   //      cacheline_invalidation.invalidate_node = <%=cidx%>;
   //      cacheline_invalidation.invalidate_addr = q_cache_addr[i];
   //      cacheline_invalidation.init_snp_attr_is_snoopable = 1;
   //      cacheline_invalidation.init_snp_attr_snp_domain_type = `SVT_CHI_SNP_DOMAIN_OUTER;
   //      cacheline_invalidation.init_mem_attr_allocate_hint = 0;
   //      cacheline_invalidation.init_is_non_secure_access = 1; // !!! SYSCO ONLY RUN with NON-SECURE txn !!!
   //      `uvm_info("SNPS_FLUSH", $sformatf("chiaiu<%=cidx%> flush addr:0x%0h",q_cache_addr[i]), UVM_NONE)
   //      cacheline_invalidation.start(m_concerto_env.snps.svt.amba_system_env.chi_system[0].virt_seqr);
   //   end:_addr_flush<%=cidx%>
   //   `uvm_info("SNPS_FLUSH", "chiaiu<%=cidx%> flush finished", UVM_NONE)
   //   end:_flush_cache_chi<%=cidx%> else begin:_empty_cache_chi<%=cidx%> 
   //   `uvm_info("SNPS_FLUSH", "cache chiaiu<%=cidx%> is empty no flush needed", UVM_NONE)
   //   end:_empty_cache_chi<%=cidx%> 
    end:_chi_vip<%=cidx%> else begin:_inhouse_chi<%=cidx%>
     chiaiu<%=cidx%>_chi_container_pkg::addr_width_t addr;
     chiaiu<%=cidx%>_chi_container_pkg::chi_bfm_cache_state_t cache_state;
     bit [511:0] data_out, data_out_1;
     int data_size;
     string chi_uc  = "CHI_UC";
     string chi_ud  = "CHI_UD";
     string chi_sd  = "CHI_SD";
     string chi_sc  = "CHI_SC";
     string chi_udp = "CHI_UDP";
         foreach (m_concerto_env.inhouse.m_chi<%=cidx%>_container.m_chi_cache[i]) begin
            addr = m_concerto_env.inhouse.m_chi<%=cidx%>_container.m_chi_cache[i].get_cacheline();

            if (m_concerto_env.inhouse.m_chi<%=cidx%>_container.m_chi_cache[addr].get_cacheline_state().name == chi_uc || m_concerto_env.inhouse.m_chi<%=cidx%>_container.m_chi_cache[addr].get_cacheline_state().name == chi_ud
             || m_concerto_env.inhouse.m_chi<%=cidx%>_container.m_chi_cache[addr].get_cacheline_state().name == chi_sd || m_concerto_env.inhouse.m_chi<%=cidx%>_container.m_chi_cache[addr].get_cacheline_state().name == chi_udp) begin
                cache_state = m_concerto_env.inhouse.m_chi<%=cidx%>_container.m_chi_cache[addr].get_cacheline_state(); 
                data_size = 'd6;
                assert(std::randomize(data_out));
                m_chi<%=cidx%>_vseq.write_flush_cache(addr, data_out, data_size, cache_state);
            end
         end
    end:_inhouse_chi<%=cidx%>     
endtask

task concerto_fullsys_sysco_test::chiaiu<%=cidx%>_sysco_detach(uvm_phase phase);
    chiaiu<%=cidx%>_chi_container_pkg::addr_width_t addr;
    bit [31:0] data;
    bit sysco_attach;
    int num_loop = 100;


    if($test$plusargs("en_cache_flush")) begin
        chiaiu<%=cidx%>_cache_flush();
        wait_seq_totaly_done(phase);
        #5us;
    end
     if(m_concerto_env_cfg.has_chi_vip_snps) begin:_chi_vip<%=cidx%>
       `uvm_info("TEST_MAIN", $sformatf("chiaiu<%=cidx%>_sysco_detach: Detaching CHIAIU<%=cidx%>. Current sysco state %0s",m_concerto_env.snps.svt.amba_system_env.chi_system[0].rn[<%=cidx%>].shared_status.sysco_interface_state.name()), UVM_NONE)
       if (m_concerto_env.snps.svt.amba_system_env.chi_system[0].rn[<%=cidx%>].shared_status.sysco_interface_state != svt_chi_status::COHERENCY_DISABLED_STATE) begin:_not_already_detach<%=cidx%>
        //wait(m_concerto_env.snps.svt.amba_system_env.chi_system[0].rn[<%=cidx%>].shared_status.sysco_interface_state == svt_chi_status::COHERENCY_ENABLED_STATE);
       `uvm_info(get_name(), "USE_VIP_SNPS coherency_exit_seq::ONGOING[<%=cidx%>]", UVM_NONE)
        coherency_exit_seq<%=cidx%>.randomize();
       `uvm_info(get_name(), "USE_VIP_SNPS coherency_exit_seq::RANDOMIZE[<%=cidx%>]", UVM_NONE)
        coherency_exit_seq<%=cidx%>.start(m_concerto_env.snps.svt.amba_system_env.chi_system[0].rn[<%=cidx%>].prot_svc_seqr);
       `uvm_info(get_name(), "USE_VIP_SNPS coherency_exit_seq::ENDING[<%=cidx%>]", UVM_NONE)
         // poll for detach state
         wait (m_concerto_env.snps.svt.amba_system_env.chi_system[0].rn[<%=cidx%>].shared_status.sysco_interface_state == svt_chi_status::COHERENCY_DISABLED_STATE);
       end:_not_already_detach<%=cidx%>
     end:_chi_vip<%=cidx%> else begin:_inhouse_chi<%=cidx%>
        ev_toggle_sysco_chiaiu<%=cidx%>.trigger(m_concerto_env.inhouse.m_chi<%=cidx%>_container);
     end:_inhouse_chi<%=cidx%>

    `uvm_info("TEST_MAIN", $sformatf("chiaiu<%=cidx%>_sysco_detach: CHIAIU<%=cidx%> is detached"), UVM_NONE)
    if(m_args.chiaiu_scb_en) begin
       wait (m_concerto_env.inhouse.m_chiaiu<%=cidx%>_env.m_scb.m_sysco_st ==  chiaiu<%=cidx%>_chi_aiu_vseq_pkg::DISABLED);
       `uvm_info("TEST_MAIN", $sformatf("chiaiu<%=cidx%>_sysco_detach: CHIAIU<%=cidx%> is detached (SCB)"), UVM_NONE)
    end else begin
      #5us;                                                       
    end
endtask

<% cidx++; }
else {
if(obj.AiuInfo[idx].fnCsrAccess == 1) { %>
task concerto_fullsys_sysco_test::ioaiu<%=qidx%>_flush_cache(string AiuName);
     ioaiu<%=qidx%>_axi_agent_pkg::axi_axaddr_t addr;
    bit [31:0] data;
    bit [31:0] mask;
    bit [31:0] field_val;
    uvm_reg    ral_reg;
    uvm_reg_field ral_field;

    // Test if a proxy $ is present
    ral_reg = m_concerto_env.m_regs.get_block_by_name(AiuName).get_reg_by_name("XAIUINFOR");
    ral_field = ral_reg.get_field_by_name("UT");
    
    // Warning, see concerto_base_test::rw_tsks.read_csr<%=qidx%>(), accesses are ignored for extra cores (check_addr_for_core)
    
    rw_tsks.read_csr<%=qidx%>(ral_reg.get_address(), data);
    field_val = ((1 << ral_field.get_n_bits())-1) & (data >> ral_field.get_lsb_pos());

    // flush only an NCAIU with proxy $
    `uvm_info("TEST_MAIN", $sformatf("ioaiu<%=qidx%>_flush_cache: CSR %s @0x%0h, data=0x%0h, %s=0x%0h", ral_reg.get_name(), ral_reg.get_address(), data, ral_field.get_name(), field_val), UVM_LOW)
    if (field_val== 2) begin   // TODO replace hard-code val
        `uvm_info("TEST_MAIN", $sformatf("UT=0x%0h, ioaiu<%=qidx%>_flush_cache(%s)", field_val, AiuName), UVM_NONE)
        // ioaiu<%=qidx%>_flush_cache(AiuName);
        end 
    else 
        return;

    `uvm_info("TEST_MAIN", $sformatf("ioaiu<%=qidx%>_flush_cache: Flushing all tag array entries for %s", AiuName), UVM_NONE)
    // poll until no more active ops
    ral_reg = m_concerto_env.m_regs.get_block_by_name(AiuName).get_reg_by_name("XAIUPCMAR");
    ral_field = ral_reg.get_field_by_name("MntOpActv");
    do begin
        rw_tsks.read_csr<%=qidx%>(ral_reg.get_address(), data);
        field_val = ((1 << ral_field.get_n_bits())-1) & (data >> ral_field.get_lsb_pos());
        `uvm_info("TEST_MAIN", $sformatf("ioaiu<%=qidx%>_flush_cache: CSR %s @0x%0h, data=0x%0h, %s=0x%0h", ral_reg.get_name(), ral_reg.get_address(), data, ral_field.get_name(), field_val), UVM_LOW)    
    end while(field_val == 1);

    // Flush all entries of proxy cache Tag array
    // RMWrite : Op = 4 (flush all entries), ArrayID=0 (Tag array)
    ral_reg = m_concerto_env.m_regs.get_block_by_name(AiuName).get_reg_by_name("XAIUPCMCR");
    rw_tsks.read_csr<%=qidx%>(ral_reg.get_address(), data);
    ral_field = ral_reg.get_field_by_name("ArrayID");
    mask = ~(((1 << ral_field.get_n_bits())-1) << ral_field.get_lsb_pos()); // set field to all zeroes
    data &= mask; // set field to 0
    ral_field = ral_reg.get_field_by_name("MntOp");
    // `uvm_info("TEST_MAIN", $sformatf("ioaiu<%=qidx%>_flush_cache: CSR %s @0x%0h, data=0x%0h, %s=0x%0h", ral_reg.get_name(), ral_reg.get_address(), data, ral_field.get_name(), field_val), UVM_NONE)
    mask = ~(((1 << ral_field.get_n_bits())-1) << ral_field.get_lsb_pos()); // set field to all zeroes
    data &= mask; // set field to 0
    data |= (4 << ral_field.get_lsb_pos()); // set field to value
    rw_tsks.write_csr<%=qidx%>(ral_reg.get_address(), data);                                                
    `uvm_info("TEST_MAIN", $sformatf("ioaiu<%=qidx%>_flush_cache: CSR %s @0x%0h, data=0x%0h, %s=0x%0h", ral_reg.get_name(), ral_reg.get_address(), data, ral_field.get_name(), field_val), UVM_LOW)
    #10ns;
    // poll until no more active ops
    ral_reg = m_concerto_env.m_regs.get_block_by_name(AiuName).get_reg_by_name("XAIUPCMAR");
    ral_field = ral_reg.get_field_by_name("MntOpActv");
    do begin
        #100ns;                                                                        
        rw_tsks.read_csr<%=qidx%>(ral_reg.get_address(), data);
        field_val = ((1 << ral_field.get_n_bits())-1) & (data >> ral_field.get_lsb_pos());
        `uvm_info("TEST_MAIN", $sformatf("ioaiu<%=qidx%>_flush_cache: CSR %s @0x%0h, data=0x%0h, %s=0x%0h", ral_reg.get_name(), ral_reg.get_address(), data, ral_field.get_name(), field_val), UVM_LOW)
    end while(field_val == 1);
endtask // _flush_cache                                                

task concerto_fullsys_sysco_test::ioaiu<%=qidx%>_sysco_attach(string AiuName);
    ioaiu<%=qidx%>_axi_agent_pkg::axi_axaddr_t addr;
    bit [31:0] data;
    bit [31:0] mask;
    bit [31:0] field_val;
    uvm_reg    ral_reg;
    uvm_reg_field ral_field;
    bit sysco_attach;
    bit sysco_error;
    int num_loop = 1000;

    `uvm_info("TEST_MAIN", $sformatf("ioaiu<%=qidx%>_sysco_attach: Attaching %s", AiuName), UVM_NONE)
    // RMWrite
    //#Check.FSYS.csr.Test.pre-v3.4.TCR
    ral_reg = m_concerto_env.m_regs.get_block_by_name(AiuName).get_reg_by_name("XAIUTCR");
    rw_tsks.read_csr<%=qidx%>(ral_reg.get_address(), data);
    ral_field = ral_reg.get_field_by_name("SysCoAttach");
    mask = ~(((1 << ral_field.get_n_bits())-1) << ral_field.get_lsb_pos()); // set field to all zeroes
    data &= mask; // set field to 0
    data |= (1 << ral_field.get_lsb_pos()); // set field to value
    rw_tsks.write_csr<%=qidx%>(ral_reg.get_address(), data);                                                
    `uvm_info("TEST_MAIN", $sformatf("ioaiu<%=qidx%>_sysco_attach: CSR %s @0x%0h, data=0x%0h, %s=0x%0h", ral_reg.get_name(), ral_reg.get_address(), data, ral_field.get_name(), field_val), UVM_LOW)
    
    // poll for attach state
    ral_reg = m_concerto_env.m_regs.get_block_by_name(AiuName).get_reg_by_name("XAIUTAR");
    //#Check.FSYS.csr.Test.pre-v3.4.TAR
    do begin
       #100ns;                                                                        
       rw_tsks.read_csr<%=qidx%>(ral_reg.get_address(), data);
       ral_field = ral_reg.get_field_by_name("SysCoAttached");
       field_val = ((1 << ral_field.get_n_bits())-1) & (data >> ral_field.get_lsb_pos());
       sysco_attach = field_val;
        `uvm_info("TEST_MAIN", $sformatf("ioaiu<%=qidx%>_sysco_attach: CSR %s @0x%0h, data=0x%0h, %s=0x%0h", ral_reg.get_name(), ral_reg.get_address(), data, ral_field.get_name(), field_val), UVM_LOW)
       ral_field = ral_reg.get_field_by_name("SysCoError");
       field_val = ((1 << ral_field.get_n_bits())-1) & (data >> ral_field.get_lsb_pos());
       sysco_error = field_val;
       num_loop--;
    end while((sysco_attach==0) && (sysco_error==0) && (num_loop > 0));

    if(num_loop == 0) begin
       `uvm_error("TEST_MAIN", $sformatf("ioaiu<%=qidx%>_sysco_attach: failed to see SYSCO ATTACH state for AIU%0d", AiuName))
    end
    else begin
       if(sysco_error == 1) begin
          `uvm_error("TEST_MAIN", $sformatf("ioaiu<%=qidx%>_sysco_attach: Received SYSCO Error for %s", AiuName))
       end
       else begin
          `uvm_info("TEST_MAIN", $sformatf("ioaiu<%=qidx%>_sysco_attach: %s is attached", AiuName), UVM_NONE)
       end
    end
endtask

task concerto_fullsys_sysco_test::ioaiu<%=qidx%>_sysco_detach(string AiuName);
    ioaiu<%=qidx%>_axi_agent_pkg::axi_axaddr_t addr;
    bit [31:0] data;
    bit [31:0] mask;
    bit [31:0] field_val;
    uvm_reg    ral_reg;
    uvm_reg_field ral_field;
    bit sysco_attach;
    bit sysco_error;
    int num_loop = 1000;

    `uvm_info("TEST_MAIN", $sformatf("ioaiu<%=qidx%>_sysco_detach: Detaching %s", AiuName), UVM_NONE)

    ral_reg = m_concerto_env.m_regs.get_block_by_name(AiuName).get_reg_by_name("XAIUTCR");
    ral_field = ral_reg.get_field_by_name("SysCoAttach");
    rw_tsks.read_csr<%=qidx%>(ral_reg.get_address(), data);
    
    field_val = 1;
    data &= ~(field_val << ral_field.get_lsb_pos());
    `uvm_info("TEST_MAIN", $sformatf("ioaiu<%=qidx%>_sysco_detach: CSR %s @0x%0h, data=0x%0h, %s=0x%0h", ral_reg.get_name(), ral_reg.get_address(), data, ral_field.get_name(), field_val), UVM_LOW)
    rw_tsks.write_csr<%=qidx%>(ral_reg.get_address(),data, 0);
    
    // Poll XAIUTAR for detach state
    ral_reg = m_concerto_env.m_regs.get_block_by_name(AiuName).get_reg_by_name("XAIUTAR");
    do begin
       #100ns;                                                                        
       rw_tsks.read_csr<%=qidx%>(ral_reg.get_address(), data);
       ral_field = ral_reg.get_field_by_name("SysCoAttached");
       field_val = ((1 << ral_field.get_n_bits())-1) & (data >> ral_field.get_lsb_pos());
       sysco_attach = field_val;
        `uvm_info("TEST_MAIN", $sformatf("ioaiu<%=qidx%>_sysco_detach: CSR %s @0x%0h, data=0x%0h, %s=0x%0h", ral_reg.get_name(), ral_reg.get_address(), data, ral_field.get_name(), field_val), UVM_LOW)
       ral_field = ral_reg.get_field_by_name("SysCoError");
       field_val = ((1 << ral_field.get_n_bits())-1) & (data >> ral_field.get_lsb_pos());
       sysco_error = field_val;
       num_loop--;
    end while((sysco_attach==1) && (sysco_error==0) && (num_loop > 0));

    if(num_loop == 0) begin
       `uvm_error("TEST_MAIN", $sformatf("ioaiu<%=qidx%>_sysco_detach failed to see SYSCO DETACH state for %s", AiuName))
    end
    else begin
       if(sysco_error == 1) begin
          `uvm_error("TEST_MAIN", $sformatf("ioaiu<%=qidx%>_sysco_detach: Received SYSCO Error for %s", AiuName))
       end
       else begin
          `uvm_info("TEST_MAIN", $sformatf("ioaiu<%=qidx%>_sysco_detach: %s is detached", AiuName), UVM_NONE)
       end
    end
    #5us;
endtask
<% } 
qidx++; } 
} %>
