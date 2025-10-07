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
var initiatorAgents   = obj.AiuInfo.length ;
var aiu_NumCores = [];
const aiu_axiInt = [];

for(var pidx = 0; pidx < initiatorAgents; pidx++) { 
  if(Array.isArray(obj.AiuInfo[pidx].interfaces.axiInt)) {
      aiu_NumCores[pidx]    = obj.AiuInfo[pidx].interfaces.axiInt.length;
  } else {
      aiu_NumCores[pidx]    = 1;
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
var ace_idx=0;
var io_idx=0;
for(var pidx = 0; pidx < obj.nAIUs; pidx++) {
    if((obj.AiuInfo[pidx].fnNativeInterface != "CHI-A")&&(obj.AiuInfo[pidx].fnNativeInterface != "CHI-B" && obj.AiuInfo[pidx].fnNativeInterface != "CHI-E")) 
    {
        if(obj.AiuInfo[pidx].fnNativeInterface == "ACE")
        {
            aceIdx[ace_idx] = io_idx;
            ace_idx++;
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


//File: concerto_fullsys_pcie_test.svh

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



class concerto_fullsys_pcie_test extends concerto_base_test;

    //////////////////
    //Properties
    //////////////////

    //ACE Model
    <% var qidx=0; var idx=0; for(var pidx = 0 ; pidx < obj.nAIUs; pidx++) { %>
      <% if((obj.AiuInfo[pidx].fnNativeInterface == 'CHI-A') || (obj.AiuInfo[pidx].fnNativeInterface == 'CHI-B' || obj.AiuInfo[pidx].fnNativeInterface == 'CHI-E')) { %>
           chiaiu<%=idx%>_chi_aiu_vseq_pkg::chi_aiu_vseq#(<%=obj.AiuInfo[pidx].FUnitId%>)       m_chi<%=idx%>_vseq;
           chi_aiu_unit_args_pkg::chi_aiu_unit_args                       m_chi<%=idx%>_args;
	   static uvm_event ev_chi<%=idx%>_seq_done = ev_pool.get("m_chi<%=idx%>_seq");
	   int chiaiu<%=idx%>_num_trans;
	   <%  idx++;   %>
       <% } else { %>
           ioaiu<%=qidx%>_inhouse_axi_bfm_pkg::axi_master_pipelined_seq          m_iocache_seq<%=qidx%>[<%=aiu_NumCores[pidx]%>];
      <% if((obj.AiuInfo[pidx].fnNativeInterface == 'ACE') || (aiu_axiInt[pidx].params.eAc==1) ){ %>
           ioaiu<%=qidx%>_inhouse_axi_bfm_pkg::axi_master_snoop_seq              m_iosnoop_seq<%=qidx%>[<%=aiu_NumCores[pidx]%>];
      <% } %>
      <% for(var coreidx=0; coreidx < aiu_NumCores[pidx]; coreidx++) { %>
	   static uvm_event ev_ioaiu<%=qidx%>_<%=coreidx%>_seq_done = ev_pool.get("m_ioaiu<%=qidx%>_<%=coreidx%>_seq");
      <% } %> // foreach core
	   int ioaiu<%=qidx%>_num_trans;
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


    int chi_num_trans;
    int ioaiu_num_trans;
    int boot_from_ioaiu;
    bit k_access_boot_region;
    bit k_csr_access_only;
    bit k_directed_test;
    bit k_directed_64B_aligned;
    int use_user_addrq;
    int 	      ioaiu_slow_master[int];
    //////////////////
    //UVM Registery
    //////////////////    
    `uvm_component_utils(concerto_fullsys_pcie_test)

    //////////////////
    //Methods
    //////////////////
    extern function new(string name = "concerto_fullsys_pcie_test", uvm_component parent = null);
    extern virtual function void build_phase(uvm_phase  phase);
    //extern virtual function void connect_pahse(uvm_phase phase);
    extern virtual function void end_of_elaboration_phase(uvm_phase phase);
    extern virtual task run_phase(uvm_phase phase);
    extern virtual task exec_inhouse_seq(uvm_phase phase);
    extern virtual task exec_inhouse_boot_seq(uvm_phase phase);
    extern virtual task exec_snoop_seq(uvm_phase phase);
    extern virtual task exec_cache_preload_seq(uvm_phase phase);
    extern virtual task set_ioaiu_control_cfg();
    extern virtual function void start_of_simulation_phase(uvm_phase phase);
    extern virtual function void report_phase(uvm_phase phase);

    <% for(var idx = 0, qidx=0; idx < obj.nAIUs; idx++) { 
    if((obj.AiuInfo[idx].fnNativeInterface != 'CHI-A')&&(obj.AiuInfo[idx].fnNativeInterface != 'CHI-B' && obj.AiuInfo[idx].fnNativeInterface != 'CHI-E')) { %>
    ioaiu<%=qidx%>_axi_agent_pkg::axi_virtual_sequencer  m_ioaiu_vseqr<%=qidx%>[<%=aiu_NumCores[idx]%>];
       <% if(obj.AiuInfo[idx].fnNativeInterface == 'ACE-LITE' || obj.AiuInfo[idx].fnNativeInterface == 'ACELITE-E' || obj.AiuInfo[idx].fnNativeInterface == 'ACE') { %>
    extern virtual task read_once<%=qidx%>(input ioaiu<%=qidx%>_axi_agent_pkg::axi_axaddr_t addr, input ioaiu<%=qidx%>_axi_agent_pkg::axi_axlen_t axlen, ioaiu<%=qidx%>_axi_agent_pkg::axi_arid_t arid, output bit[ioaiu<%=qidx%>_axi_agent_pkg::WXDATA-1:0] data);
    extern virtual task write_unq<%=qidx%>(input ioaiu<%=qidx%>_axi_agent_pkg::axi_axaddr_t addr, input bit[ioaiu<%=qidx%>_axi_agent_pkg::WXDATA-1:0] data, input ioaiu<%=qidx%>_axi_agent_pkg::axi_axlen_t axlen, ioaiu<%=qidx%>_axi_agent_pkg::axi_awid_t awid, input bit use_user_data=0);
    extern virtual task read_nosnp<%=qidx%>(input ioaiu<%=qidx%>_axi_agent_pkg::axi_axaddr_t addr, input ioaiu<%=qidx%>_axi_agent_pkg::axi_axlen_t axlen, ioaiu<%=qidx%>_axi_agent_pkg::axi_arid_t arid, output bit[ioaiu<%=qidx%>_axi_agent_pkg::WXDATA-1:0] data);
    extern virtual task write_nosnp<%=qidx%>(input ioaiu<%=qidx%>_axi_agent_pkg::axi_axaddr_t addr, input bit[ioaiu<%=qidx%>_axi_agent_pkg::WXDATA-1:0] data, input ioaiu<%=qidx%>_axi_agent_pkg::axi_axlen_t axlen, ioaiu<%=qidx%>_axi_agent_pkg::axi_awid_t awid, input bit use_user_data=0);
    extern virtual task write_4KB_block<%=qidx%>(input ioaiu<%=qidx%>_axi_agent_pkg::axi_axaddr_t dmi_addr, input ioaiu<%=qidx%>_axi_agent_pkg::axi_axaddr_t flag_addr, input int txn_size, input int counter);
    extern virtual task read_4KB_block<%=qidx%>(input ioaiu<%=qidx%>_axi_agent_pkg::axi_axaddr_t dmi_addr, input ioaiu<%=qidx%>_axi_agent_pkg::axi_axaddr_t flag_addr, input int txn_size, input int counter);
    extern virtual task pcie_write<%=qidx%>(input ioaiu<%=qidx%>_axi_agent_pkg::axi_axaddr_t dmi_addr, input ioaiu<%=qidx%>_axi_agent_pkg::axi_axaddr_t flag_addr, input int txn_size, input int num_iter);
    extern virtual task pcie_read<%=qidx%>(input ioaiu<%=qidx%>_axi_agent_pkg::axi_axaddr_t dmi_addr, input ioaiu<%=qidx%>_axi_agent_pkg::axi_axaddr_t flag_addr, input int txn_size, input int num_iter);

    bit[ioaiu<%=qidx%>_axi_agent_pkg::WXDATA-1:0] ioaiu<%=qidx%>_data;
    ioaiu<%=qidx%>_axi_agent_pkg::axi_awid_t m_awid<%=qidx%>;
    ioaiu<%=qidx%>_axi_agent_pkg::axi_arid_t m_arid<%=qidx%>;
    <% }
    qidx++; }
    } %>
   
endclass: concerto_fullsys_pcie_test

//////////////////
//Calling Method: Child Class
//Description: Constructor
//Arguments:   UVM Default
//Return type: N/A
//////////////////
function concerto_fullsys_pcie_test::new(string name = "concerto_fullsys_pcie_test", uvm_component parent = null);
    super.new(name, parent);
endfunction: new

//////////////////
//Calling Method: UVM Factory
//Description: Build phase
//Arguments:   UVM Default
//Return type: Void
//////////////////
function void concerto_fullsys_pcie_test::build_phase(uvm_phase phase);
   string     ioaiu_slow_master_str[];
   string     ioaiu_slow_master_arg;
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
function void concerto_fullsys_pcie_test::end_of_elaboration_phase(uvm_phase phase);
    int file_handle;
    `uvm_info("end_of_elaboration_phase", "Entered...", UVM_LOW)
  <% 
      var chiaiu_idx = 0;
      var ioaiu_idx = 0;
   %>
<% for(var pidx = 0 ; pidx < obj.nAIUs; pidx++) { %>
    <% if(!((obj.AiuInfo[pidx].fnNativeInterface.match('CHI')))) { %>
    <% for(var coreidx=0; coreidx < aiu_NumCores[pidx]; coreidx++) { %>
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
	<% } %> // foreach core												     
    <% ioaiu_idx++; } %>

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
task concerto_fullsys_pcie_test::run_phase(uvm_phase phase);
   super.run_phase(phase);
   `uvm_info("TEST_MAIN", "Starting concerto_fullsys_pcie_test::exec_inhouse_seq ...", UVM_LOW)
    exec_inhouse_seq(phase);
   `uvm_info("TEST_MAIN", "Finish concerto_fullsys_pcie_test ...", UVM_LOW)
endtask: run_phase


//////////////////
//Return type: Void
//////////////////
task concerto_fullsys_pcie_test::exec_inhouse_seq(uvm_phase phase);
    bit timeout;
   bit [31:0] ioaiu_control_cfg;
   int 	      chiaiu_en[int];
   int 	      ioaiu_en[int];
   string     chiaiu_en_str[];
   string     ioaiu_en_str[];
   string     chiaiu_en_arg;
   string     ioaiu_en_arg;
   int 	      cacheline_size;
   int 	      stagger_address[4] = {'h0, 'h140, 'h280, 'h3c0};
   int        intrlved_dmis;

   int 	      chiaiu_qos[int];
   int 	      ioaiu_qos[int];
   string     chiaiu_qos_str[];
   string     ioaiu_qos_str[];
   string     chiaiu_qos_arg;
   string     ioaiu_qos_arg;

   int 	      chiaiu_slow_master[int];
   string     chiaiu_slow_master_str[];
   string     chiaiu_slow_master_arg;

   int 	      dmi_slow_slave[int];
   string     dmi_slow_slave_str[];
   string     dmi_slow_slave_arg;

   int 	      chiaiu_intrlv_grp;
   int 	      ioaiu_intrlv_grp;
   int 	      i;

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

   int        perf_txn_size;
   int        num_iter;

   int        chi_read_ratio;
   int        chi_write_ratio;
   int        read_collision_pct;
   int        write_collision_pct;
   int        collision_idx;

   int 	      chi_txreq_dly;

   bit [addrMgrConst::W_SEC_ADDR-1:0] dmi_addr;
   bit [addrMgrConst::W_SEC_ADDR-1:0] flag_addr;
   
   int addr_offsets[<%=obj.nAIUs%>];
   addr_offsets[0] = 0;
   addr_offsets[1] = 'h80;
   addr_offsets[2] = 'hc0;
   addr_offsets[3] = 'h00;
   addr_offsets[4] = 'h40;
   addr_offsets[5] = 'h100;
   addr_offsets[6] = 'h140;
   addr_offsets[7] = 'h180;

    if (!$value$plusargs("chi_num_trans=%d",chi_num_trans)) begin
        chi_num_trans = 0;
    end
    if (!$value$plusargs("ioaiu_num_trans=%d",ioaiu_num_trans)) begin
        ioaiu_num_trans = 0;
    end

    if (!$value$plusargs("chiaiu_read_ratio=%d",chi_read_ratio)) begin
        chi_read_ratio = 50;
    end

    if (!$value$plusargs("chiaiu_write_ratio=%d",chi_write_ratio)) begin
        chi_write_ratio = 50;
    end

    if (!$value$plusargs("num_iter=%d",num_iter)) begin
        num_iter = 1;
    end

   <% var chiaiu_idx=0; ioaiu_idx=0;
    for(var pidx = 0 ; pidx < obj.nAIUs; pidx++) { %>
    <% if((obj.AiuInfo[pidx].fnNativeInterface == 'CHI-A')||(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-B' || obj.AiuInfo[pidx].fnNativeInterface == 'CHI-E')) { %>
       if(!$value$plusargs("chiaiu<%=chiaiu_idx%>_num_trans=%d", chiaiu<%=chiaiu_idx%>_num_trans)) begin
          chiaiu<%=chiaiu_idx%>_num_trans = chi_num_trans;
       end
    <% chiaiu_idx++; }
    else { %>
       if(!$value$plusargs("ioaiu<%=ioaiu_idx%>_num_trans=%d", ioaiu<%=ioaiu_idx%>_num_trans)) begin
          ioaiu<%=ioaiu_idx%>_num_trans = ioaiu_num_trans;
       end
    <% ioaiu_idx++; }
    } %>

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
    m_axi_slv_rd_seq_dii<%=pidx%>.m_memory_model         = m_concerto_env.inhouse.m_axi_slv_memory_model_dii<%=pidx%>;
    m_axi_slv_rd_seq_dii<%=pidx%>.prob_ace_rd_resp_error = m_args.dii<%=pidx%>_prob_ace_slave_rd_resp_error;
    m_axi_slv_wr_seq_dii<%=pidx%>.m_write_addr_chnl_seqr = m_concerto_env.inhouse.m_dii<%=pidx%>_env.m_axi_slave_agent.m_write_addr_chnl_seqr;
    m_axi_slv_wr_seq_dii<%=pidx%>.m_write_data_chnl_seqr = m_concerto_env.inhouse.m_dii<%=pidx%>_env.m_axi_slave_agent.m_write_data_chnl_seqr;
    m_axi_slv_wr_seq_dii<%=pidx%>.m_write_resp_chnl_seqr = m_concerto_env.inhouse.m_dii<%=pidx%>_env.m_axi_slave_agent.m_write_resp_chnl_seqr;
    m_axi_slv_wr_seq_dii<%=pidx%>.m_memory_model         = m_concerto_env.inhouse.m_axi_slv_memory_model_dii<%=pidx%>;
    m_axi_slv_wr_seq_dii<%=pidx%>.prob_ace_wr_resp_error = m_args.dii<%=pidx%>_prob_ace_slave_wr_resp_error;
    <% } %>
  <% } %>

  <% var qidx=0;var idx=0; for(var pidx = 0; pidx < obj.nAIUs; pidx++) { %>
    <% if((obj.AiuInfo[pidx].fnNativeInterface == 'CHI-A')||(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-B' || obj.AiuInfo[pidx].fnNativeInterface == 'CHI-E')) { %>
    m_chi<%=idx%>_vseq = chiaiu<%=idx%>_chi_aiu_vseq_pkg::chi_aiu_vseq#(<%=obj.AiuInfo[pidx].FUnitId%>)::type_id::create("m_chi<%=idx%>_seq");

    m_chi<%=idx%>_vseq.set_seq_name("m_chi<%=idx%>_seq");
    m_chi<%=idx%>_vseq.m_chi_container = m_concerto_env.inhouse.m_chi<%=idx%>_container;
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

      <% idx++;  %>
    <%} else { %>
    <% for(var coreidx=0; coreidx < aiu_NumCores[pidx]; coreidx++) { %>
    m_iocache_seq<%=qidx%>[<%=coreidx%>]                        = ioaiu<%=qidx%>_inhouse_axi_bfm_pkg::axi_master_pipelined_seq::type_id::create("m_ioaiu<%=qidx%>_<%=coreidx%>_seq");
    m_iocache_seq<%=qidx%>[<%=coreidx%>].core_id = <%=coreidx%>;
    m_iocache_seq<%=qidx%>[<%=coreidx%>].set_seq_name("m_ioaiu<%=qidx%>_<%=coreidx%>_seq");
    m_iocache_seq<%=qidx%>[<%=coreidx%>].m_read_addr_chnl_seqr  = m_concerto_env.inhouse.m_ioaiu<%=qidx%>_env.m_env[<%=coreidx%>].m_axi_master_agent.m_read_addr_chnl_seqr;
    m_iocache_seq<%=qidx%>[<%=coreidx%>].m_read_data_chnl_seqr  = m_concerto_env.inhouse.m_ioaiu<%=qidx%>_env.m_env[<%=coreidx%>].m_axi_master_agent.m_read_data_chnl_seqr;
    m_iocache_seq<%=qidx%>[<%=coreidx%>].m_write_addr_chnl_seqr = m_concerto_env.inhouse.m_ioaiu<%=qidx%>_env.m_env[<%=coreidx%>].m_axi_master_agent.m_write_addr_chnl_seqr;
    m_iocache_seq<%=qidx%>[<%=coreidx%>].m_write_data_chnl_seqr = m_concerto_env.inhouse.m_ioaiu<%=qidx%>_env.m_env[<%=coreidx%>].m_axi_master_agent.m_write_data_chnl_seqr;
    m_iocache_seq<%=qidx%>[<%=coreidx%>].m_write_resp_chnl_seqr = m_concerto_env.inhouse.m_ioaiu<%=qidx%>_env.m_env[<%=coreidx%>].m_axi_master_agent.m_write_resp_chnl_seqr;
    m_iocache_seq<%=qidx%>[<%=coreidx%>].m_ace_cache_model      = m_concerto_env.inhouse.m_ace_cache_model_ioaiu<%=qidx%>[<%=coreidx%>];
    m_iocache_seq<%=qidx%>[<%=coreidx%>].k_directed_test        = k_directed_test;

      <% if((obj.AiuInfo[pidx].fnNativeInterface == 'ACE') || (aiu_axiInt[pidx].params.eAc==1) ){ %>
    m_iosnoop_seq<%=qidx%>[<%=coreidx%>]                        = ioaiu<%=qidx%>_inhouse_axi_bfm_pkg::axi_master_snoop_seq::type_id::create("m_iosnoop<%=qidx%>_<%=coreidx%>_seq");
    m_iosnoop_seq<%=qidx%>[<%=coreidx%>].m_read_addr_chnl_seqr   = m_concerto_env.inhouse.m_ioaiu<%=qidx%>_env.m_env[<%=coreidx%>].m_axi_master_agent.m_read_addr_chnl_seqr;
    m_iosnoop_seq<%=qidx%>[<%=coreidx%>].m_read_data_chnl_seqr   = m_concerto_env.inhouse.m_ioaiu<%=qidx%>_env.m_env[<%=coreidx%>].m_axi_master_agent.m_read_data_chnl_seqr;
    m_iosnoop_seq<%=qidx%>[<%=coreidx%>].m_snoop_addr_chnl_seqr  = m_concerto_env.inhouse.m_ioaiu<%=qidx%>_env.m_env[<%=coreidx%>].m_axi_master_agent.m_snoop_addr_chnl_seqr;
    m_iosnoop_seq<%=qidx%>[<%=coreidx%>].m_snoop_data_chnl_seqr  = m_concerto_env.inhouse.m_ioaiu<%=qidx%>_env.m_env[<%=coreidx%>].m_axi_master_agent.m_snoop_data_chnl_seqr;
    m_iosnoop_seq<%=qidx%>[<%=coreidx%>].m_snoop_resp_chnl_seqr  = m_concerto_env.inhouse.m_ioaiu<%=qidx%>_env.m_env[<%=coreidx%>].m_axi_master_agent.m_snoop_resp_chnl_seqr;
    m_iosnoop_seq<%=qidx%>[<%=coreidx%>].m_ace_cache_model       = m_concerto_env.inhouse.m_ace_cache_model_ioaiu<%=qidx%>[<%=coreidx%>];
      <%}%>

    <% } %> // foreach core
    <% qidx++; } %>
  <% } %>

  <% var qidx=0;var idx=0; for(var pidx = 0; pidx < obj.nAIUs; pidx++) { %>
    <% if((obj.AiuInfo[pidx].fnNativeInterface == 'CHI-A')||(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-B' || obj.AiuInfo[pidx].fnNativeInterface == 'CHI-E')) { %>
    m_chi<%=idx%>_args = chi_aiu_unit_args_pkg::chi_aiu_unit_args::type_id::create($psprintf("chi_aiu_unit_args[%0d]", 0));
    m_chi<%=idx%>_args.k_num_requests.set_value(chiaiu<%=idx%>_num_trans);
    m_chi<%=idx%>_args.k_coh_addr_pct.set_value(50);
    m_chi<%=idx%>_args.k_noncoh_addr_pct.set_value(50);
    m_chi<%=idx%>_args.k_device_type_mem_pct.set_value(50);
    m_chi<%=idx%>_args.k_rq_lcrdrt_pct.set_value(0);
    m_chi<%=idx%>_args.k_rd_noncoh_pct.set_value(5);
    m_chi<%=idx%>_args.k_rd_ldrstr_pct.set_value(5);
    m_chi<%=idx%>_args.k_wr_noncoh_pct.set_value(5);
    m_chi<%=idx%>_args.k_new_addr_pct.set_value(50);
    m_chi<%=idx%>_vseq.set_unit_args(m_chi<%=idx%>_args);
      <% idx++; } %>
  <% } %>

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
        m_chi<%=idx%>_vseq.construct_lnk_seq();
        m_chi<%=idx%>_vseq.construct_txs_seq();
    end
    <% idx++; %>
    <%} %>
  <% } %>
    join
   
        `uvm_info("TEST_MAIN", "Start exec_inhouse_boot_seq", UVM_NONE)
        exec_inhouse_boot_seq(phase);

        // trigger csr_init_done to unit scoreboards
        csr_init_done.trigger(null);

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
       
        if($test$plusargs("ioaiu_control_cfg")) begin
           set_ioaiu_control_cfg();
        end

        if($test$plusargs("exec_snoop_seq")) begin
	   exec_snoop_seq(phase);
	end
	    
            if($value$plusargs("use_user_addrq=%d", use_user_addrq)) begin
                if($test$plusargs("perf_test")) begin
		   <% var chi_idx=0; var io_idx=0;
                   for(var pidx=0; pidx<obj.nAIUs; pidx++) {
                   if((obj.AiuInfo[pidx].fnNativeInterface == "CHI-A") || (obj.AiuInfo[pidx].fnNativeInterface == "CHI-B" || obj.AiuInfo[pidx].fnNativeInterface == "CHI-E")) { %>
                   intrlved_dmis = addrMgrConst::intrlvgrp_vector[addrMgrConst::picked_dmi_igs][chiaiu_intrlv_grp];
                   if($test$plusargs("dmi_non_intrlv")) begin
                      addr_mgr.gen_seq_dmi_addr_in_user_addrq(use_user_addrq, (<%=chi_idx%>%m_mem.nintrlv_grps[chiaiu_intrlv_grp])*perf_txn_size, chiaiu_intrlv_grp, m_chi<%=chi_idx%>_vseq.m_chi_container.user_addrq[addrMgrConst::COH]);
                      addr_mgr.gen_seq_dmi_addr_in_user_addrq(use_user_addrq, (<%=chi_idx%>%m_mem.nintrlv_grps[chiaiu_intrlv_grp])*perf_txn_size, chiaiu_intrlv_grp, m_chi<%=chi_idx%>_vseq.m_chi_container.user_write_addrq[addrMgrConst::COH]);
                      addr_mgr.gen_seq_dmi_addr_in_user_addrq(use_user_addrq, (<%=chi_idx%>%m_mem.nintrlv_grps[chiaiu_intrlv_grp])*perf_txn_size, chiaiu_intrlv_grp, m_chi<%=chi_idx%>_vseq.m_chi_container.user_read_addrq[addrMgrConst::COH]);
		   end else begin													      
                      addr_mgr.gen_seq_addr_in_user_addrq(use_user_addrq, perf_txn_size, chiaiu_intrlv_grp, -1, m_chi<%=chi_idx%>_vseq.m_chi_container.user_addrq[addrMgrConst::COH]);
                      addr_mgr.gen_seq_addr_in_user_addrq(use_user_addrq, perf_txn_size, chiaiu_intrlv_grp, -1, m_chi<%=chi_idx%>_vseq.m_chi_container.user_write_addrq[addrMgrConst::COH]);
                      addr_mgr.gen_seq_addr_in_user_addrq(use_user_addrq, perf_txn_size, chiaiu_intrlv_grp, -1, m_chi<%=chi_idx%>_vseq.m_chi_container.user_read_addrq[addrMgrConst::COH]);
                   end
		   if($test$plusargs("user_addrq_shift_index")) begin
		      m_chi<%=chi_idx%>_vseq.m_chi_container.user_addrq_idx[addrMgrConst::COH] = <%=chi_idx%>*2;
		      m_chi<%=chi_idx%>_vseq.m_chi_container.user_addrq_idx[addrMgrConst::NONCOH] = <%=chi_idx%>*2;
		      m_chi<%=chi_idx%>_vseq.m_chi_container.user_write_addrq_idx[addrMgrConst::COH] = <%=chi_idx%>*2;
		      m_chi<%=chi_idx%>_vseq.m_chi_container.user_write_addrq_idx[addrMgrConst::NONCOH] = <%=chi_idx%>*2;
		      m_chi<%=chi_idx%>_vseq.m_chi_container.user_read_addrq_idx[addrMgrConst::COH] = <%=chi_idx%>*2;
		      m_chi<%=chi_idx%>_vseq.m_chi_container.user_read_addrq_idx[addrMgrConst::NONCOH] = <%=chi_idx%>*2;
		   end
		   m_chi<%=chi_idx%>_vseq.m_chi_container.user_addrq[addrMgrConst::NONCOH] = m_chi<%=chi_idx%>_vseq.m_chi_container.user_addrq[addrMgrConst::COH];
		   m_chi<%=chi_idx%>_vseq.m_chi_container.user_write_addrq[addrMgrConst::NONCOH] = m_chi<%=chi_idx%>_vseq.m_chi_container.user_write_addrq[addrMgrConst::COH];
		   m_chi<%=chi_idx%>_vseq.m_chi_container.user_read_addrq[addrMgrConst::NONCOH] = m_chi<%=chi_idx%>_vseq.m_chi_container.user_read_addrq[addrMgrConst::COH];
                   <% chi_idx++; %>
                   <% } else { %>
                   intrlved_dmis = addrMgrConst::intrlvgrp_vector[addrMgrConst::picked_dmi_igs][ioaiu_intrlv_grp];
                   if($test$plusargs("use_caiu_addrq_for_ncaiu")) begin
            <% for(var coreidx=0; coreidx < aiu_NumCores[pidx]; coreidx++) { %>
		      <% if (numChiAiu == 1) { %>
		      m_concerto_env.inhouse.m_ace_cache_model_ioaiu<%=io_idx%>[<%=coreidx%>].user_addrq[addrMgrConst::COH] = m_chi0_vseq.m_chi_container.user_addrq[addrMgrConst::COH];
                      <% } else if (numChiAiu == 2) { %>
		      if(<%=io_idx%>%2) begin
		         m_concerto_env.inhouse.m_ace_cache_model_ioaiu<%=io_idx%>[<%=coreidx%>].user_addrq[addrMgrConst::COH] = m_chi1_vseq.m_chi_container.user_addrq[addrMgrConst::COH];
		      end else begin
		         m_concerto_env.inhouse.m_ace_cache_model_ioaiu<%=io_idx%>[<%=coreidx%>].user_addrq[addrMgrConst::COH] = m_chi0_vseq.m_chi_container.user_addrq[addrMgrConst::COH];
		      end
		      <% } else if (numChiAiu == 4) { %>
		      if((<%=io_idx%>%4)==3) begin
		         m_concerto_env.inhouse.m_ace_cache_model_ioaiu<%=io_idx%>[<%=coreidx%>].user_addrq[addrMgrConst::COH] = m_chi3_vseq.m_chi_container.user_addrq[addrMgrConst::COH];
		      end else if((<%=io_idx%>%4)==2) begin
		         m_concerto_env.inhouse.m_ace_cache_model_ioaiu<%=io_idx%>[<%=coreidx%>].user_addrq[addrMgrConst::COH] = m_chi2_vseq.m_chi_container.user_addrq[addrMgrConst::COH];
		      end else if((<%=io_idx%>%4)==1) begin
		         m_concerto_env.inhouse.m_ace_cache_model_ioaiu<%=io_idx%>[<%=coreidx%>].user_addrq[addrMgrConst::COH] = m_chi1_vseq.m_chi_container.user_addrq[addrMgrConst::COH];
		      end else begin
		         m_concerto_env.inhouse.m_ace_cache_model_ioaiu<%=io_idx%>[<%=coreidx%>].user_addrq[addrMgrConst::COH] = m_chi0_vseq.m_chi_container.user_addrq[addrMgrConst::COH];
		      end
            <% } %> // foreach core
                      <% } %>	
            			      
                   end else if($test$plusargs("dmi_non_intrlv")) begin
		      if($test$plusargs("use_user_write_read_addrq")) begin	 
                      <% for(var coreidx=0; coreidx < aiu_NumCores[pidx]; coreidx++) { %>      
                        addr_mgr.gen_seq_dmi_addr_in_user_write_read_addrq(use_user_addrq, (<%=io_idx%>%m_mem.nintrlv_grps[ioaiu_intrlv_grp])*perf_txn_size, ioaiu_intrlv_grp, m_concerto_env.inhouse.m_ace_cache_model_ioaiu<%=io_idx%>[<%=coreidx%>].user_write_addrq[addrMgrConst::COH],m_concerto_env.inhouse.m_ace_cache_model_ioaiu<%=io_idx%>[<%=coreidx%>].user_read_addrq[addrMgrConst::COH]);
                      <% } %> // foreach core       
                      end else begin
                         if($test$plusargs("use_special_addr_offset")) begin
                            <% for(var coreidx=0; coreidx < aiu_NumCores[pidx]; coreidx++) { %>
                         addr_mgr.gen_seq_dmi_addr_in_user_addrq(use_user_addrq, addr_offsets[<%=io_idx%>], ioaiu_intrlv_grp, m_concerto_env.inhouse.m_ace_cache_model_ioaiu<%=io_idx%>[<%=coreidx%>].user_addrq[addrMgrConst::COH]);
                         <% } %> // foreach core 
                         end else begin	
                          <% for(var coreidx=0; coreidx < aiu_NumCores[pidx]; coreidx++) { %>  		       
                         addr_mgr.gen_seq_dmi_addr_in_user_addrq(use_user_addrq, (<%=io_idx%>%m_mem.nintrlv_grps[ioaiu_intrlv_grp])*perf_txn_size, ioaiu_intrlv_grp, m_concerto_env.inhouse.m_ace_cache_model_ioaiu<%=io_idx%>[<%=coreidx%>].user_addrq[addrMgrConst::COH]);
                         <% } %> // foreach core
                         end
                      end
		   end else begin
                      if ($test$plusargs("use_stagger_address")) begin
                               //addr_mgr.gen_seq_addr_w_offset_in_user_addrq(use_user_addrq, cacheline_size, stagger_address[<%=io_idx%>%4], ioaiu_intrlv_grp, m_concerto_env.inhouse.m_ace_cache_model_ioaiu<%=io_idx%>.user_addrq[addrMgrConst::COH]);
                            <% for(var coreidx=0; coreidx < aiu_NumCores[pidx]; coreidx++) { %> 
                            addr_mgr.gen_seq_addr_in_user_addrq(use_user_addrq, perf_txn_size, ioaiu_intrlv_grp, <%=io_idx%>%intrlved_dmis, m_concerto_env.inhouse.m_ace_cache_model_ioaiu<%=io_idx%>[<%=coreidx%>].user_addrq[addrMgrConst::COH]);
                           <% } %> // foreach core
            
            end else begin
               <% for(var coreidx=0; coreidx < aiu_NumCores[pidx]; coreidx++) { %>
		         if($test$plusargs("use_user_write_read_addrq")) begin	
                         
                            addr_mgr.gen_seq_addr_in_user_write_read_addrq(use_user_addrq, perf_txn_size, ioaiu_intrlv_grp, m_concerto_env.inhouse.m_ace_cache_model_ioaiu<%=io_idx%>[<%=coreidx%>].user_write_addrq[addrMgrConst::COH], m_concerto_env.inhouse.m_ace_cache_model_ioaiu<%=io_idx%>[<%=coreidx%>].user_read_addrq[addrMgrConst::COH]);
                         end else begin
                            addr_mgr.gen_seq_addr_in_user_addrq(use_user_addrq, perf_txn_size, ioaiu_intrlv_grp, -1, m_concerto_env.inhouse.m_ace_cache_model_ioaiu<%=io_idx%>[<%=coreidx%>].user_addrq[addrMgrConst::COH]);
			               
          end
          <% } %> // foreach core
		      end
                   end
                   <% for(var coreidx=0; coreidx < aiu_NumCores[pidx]; coreidx++) { %>
	           m_concerto_env.inhouse.m_ace_cache_model_ioaiu<%=io_idx%>[<%=coreidx%>].user_addrq[addrMgrConst::NONCOH] = m_concerto_env.inhouse.m_ace_cache_model_ioaiu<%=io_idx%>[<%=coreidx%>].user_addrq[addrMgrConst::COH];
              <% } %> // foreach core 
		   if($test$plusargs("user_addrq_shift_index")) begin
            <% for(var coreidx=0; coreidx < aiu_NumCores[pidx]; coreidx++) { %>
		      m_concerto_env.inhouse.m_ace_cache_model_ioaiu<%=io_idx%>[<%=coreidx%>].user_addrq_idx[addrMgrConst::COH] = <%=io_idx%>;
		      m_concerto_env.inhouse.m_ace_cache_model_ioaiu<%=io_idx%>[<%=coreidx%>].user_addrq_idx[addrMgrConst::NONCOH] = <%=io_idx%>;
            <% } %> // foreach core 
		   end
                   <% io_idx++; } %>
                   <% } %>
		end // if ($test$plusargs("perf_test"))
                else begin
		   <% var chi_idx=0; var io_idx=0;
                   for(var pidx=0; pidx<obj.nAIUs; pidx++) {
                   if((obj.AiuInfo[pidx].fnNativeInterface == "CHI-A") || (obj.AiuInfo[pidx].fnNativeInterface == "CHI-B" || obj.AiuInfo[pidx].fnNativeInterface == "CHI-E")) { %>
                   addr_mgr.gen_user_noncoh_addr(<%=obj.AiuInfo[pidx].FUnitId%>, use_user_addrq, m_chi<%=chi_idx%>_vseq.m_chi_container.user_addrq[addrMgrConst::NONCOH]);
                   addr_mgr.gen_user_coh_addr(<%=obj.AiuInfo[pidx].FUnitId%>, use_user_addrq, m_chi<%=chi_idx%>_vseq.m_chi_container.user_addrq[addrMgrConst::COH]);
                   <% chi_idx++; %>
                   <% } else { %>
                   <% for(var coreidx=0; coreidx < aiu_NumCores[pidx]; coreidx++) { %>
                   addr_mgr.gen_user_noncoh_addr(<%=obj.AiuInfo[pidx].FUnitId%>, use_user_addrq, m_concerto_env.inhouse.m_ace_cache_model_ioaiu<%=io_idx%>[<%=coreidx%>].user_addrq[addrMgrConst::NONCOH]);
                   addr_mgr.gen_user_coh_addr(<%=obj.AiuInfo[pidx].FUnitId%>, use_user_addrq, m_concerto_env.inhouse.m_ace_cache_model_ioaiu<%=io_idx%>[<%=coreidx%>].user_addrq[addrMgrConst::COH]);
                   <% } %> // foreach core 
                   <% io_idx++; } %>
                   <% } %>
		end
	    end // if ($value$plusargs("use_user_addrq=%d", use_user_addrq))

            <% if(numChiAiu > 0) { %>
            if(!$value$plusargs("read_collision_pct=%d", read_collision_pct)) begin
	       read_collision_pct = 0;
	    end
            if(!$value$plusargs("write_collision_pct=%d", write_collision_pct)) begin
	       write_collision_pct = 0;
	    end
				   
            if(read_collision_pct > 0) begin
		collision_idx = m_chi0_vseq.m_chi_container.user_read_addrq[addrMgrConst::COH].size()/(100/read_collision_pct);
		collision_idx = m_chi0_vseq.m_chi_container.user_read_addrq[addrMgrConst::COH].size() - collision_idx;
		dmi_addr = m_chi0_vseq.m_chi_container.user_read_addrq[addrMgrConst::COH][collision_idx];
                `uvm_info("TEST_MAIN", $sformatf("read_collision_pct=%0d, collision_idx=%0d.  DMI addr=0x%0h", read_collision_pct, collision_idx, dmi_addr), UVM_NONE)                
	    end 
            else if(write_collision_pct > 0) begin
		collision_idx = m_chi0_vseq.m_chi_container.user_write_addrq[addrMgrConst::COH].size()/(100/write_collision_pct);
		collision_idx = m_chi0_vseq.m_chi_container.user_write_addrq[addrMgrConst::COH].size() - collision_idx;
		dmi_addr = m_chi0_vseq.m_chi_container.user_write_addrq[addrMgrConst::COH][collision_idx];
                `uvm_info("TEST_MAIN", $sformatf("write_collision_pct=%0d, collision_idx=%0d.  DMI addr=0x%0h", write_collision_pct, collision_idx, dmi_addr), UVM_NONE)                
            end 
            else begin
                dmi_addr = addr_mgr.gen_intrlvgrp_addr(0, 0);
                `uvm_info("TEST_MAIN", $sformatf("No collision.  DMI addr=0x%0h", dmi_addr), UVM_NONE)                
            end
            <% } else { %>
            dmi_addr = addr_mgr.gen_intrlvgrp_addr(0, 0);
            <% } %>
	    dmi_addr[11:0] = 12'h0;

            if($test$plusargs("use_dii_addr")) begin
                flag_addr = addr_mgr.gen_intrlvgrp_addr(addrMgrConst::intrlvgrp_vector[addrMgrConst::picked_dmi_igs].size());
            end else begin
                flag_addr = addr_mgr.gen_intrlvgrp_addr(0, 1);
	    end
	    flag_addr[11:0] = 12'h0;

            `uvm_info("TEST_MAIN", $sformatf("4KB block DMI base addr: 0x%0h, Flag base addr: 0x%0h", dmi_addr, flag_addr), UVM_NONE)

            // set randomize args after boot seq
  <% var qidx=0;var idx=0; for(var pidx = 0; pidx < obj.nAIUs; pidx++) { %>
    <% if((obj.AiuInfo[pidx].fnNativeInterface == 'CHI-A')||(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-B' || obj.AiuInfo[pidx].fnNativeInterface == 'CHI-E')) { %>
            m_chi<%=idx%>_args.k_num_requests.set_value(chiaiu<%=idx%>_num_trans);
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
            if($test$plusargs("noncoherent_test")) begin
               m_chi<%=idx%>_args.k_coh_addr_pct.set_value(0);
               m_chi<%=idx%>_args.k_noncoh_addr_pct.set_value(100);
               m_chi<%=idx%>_args.k_rd_noncoh_pct.set_value(chi_read_ratio);
               m_chi<%=idx%>_args.k_wr_noncoh_pct.set_value(chi_write_ratio);
               if ($test$plusargs("read_test")) begin
                  m_chi<%=idx%>_args.k_wr_noncoh_pct.set_value(0);
               end
               if ($test$plusargs("write_test")) begin
                  m_chi<%=idx%>_args.k_rd_noncoh_pct.set_value(0);
	       end // else: !if($test$plusargs("write_test"))
	    end	
	    else begin
               m_chi<%=idx%>_args.k_coh_addr_pct.set_value(100);
               m_chi<%=idx%>_args.k_noncoh_addr_pct.set_value(0);
               m_chi<%=idx%>_args.k_rd_ldrstr_pct.set_value(chi_read_ratio);
               m_chi<%=idx%>_args.k_wr_cohunq_pct.set_value(chi_write_ratio);
               if ($test$plusargs("read_test")) begin
                  m_chi<%=idx%>_args.k_wr_cohunq_pct.set_value(0);
               end
               if ($test$plusargs("write_test")) begin
                  m_chi<%=idx%>_args.k_rd_ldrstr_pct.set_value(0);
	       end // else: !if($test$plusargs("write_test"))
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
      <% idx++;  %>
    <%} else { %>
      <% for(var coreidx=0; coreidx < aiu_NumCores[pidx]; coreidx++) { %>
            m_iocache_seq<%=qidx%>[<%=coreidx%>].k_num_read_req      = ioaiu<%=qidx%>_num_trans/2;
            m_iocache_seq<%=qidx%>[<%=coreidx%>].k_num_write_req     = ioaiu<%=qidx%>_num_trans/2;
            if ($test$plusargs("read_test")) begin
                m_iocache_seq<%=qidx%>[<%=coreidx%>].k_num_read_req      = ioaiu<%=qidx%>_num_trans;
                m_iocache_seq<%=qidx%>[<%=coreidx%>].k_num_write_req      = 0;
            end
            if ($test$plusargs("write_test")) begin
                m_iocache_seq<%=qidx%>[<%=coreidx%>].k_num_write_req     = ioaiu<%=qidx%>_num_trans;
                m_iocache_seq<%=qidx%>[<%=coreidx%>].k_num_read_req      = 0;
            end
      <% if((obj.AiuInfo[pidx].fnNativeInterface == 'ACE') || (obj.AiuInfo[pidx].fnNativeInterface == 'ACE-LITE') || (obj.AiuInfo[pidx].fnNativeInterface == 'ACELITE-E')) { %>
            m_iocache_seq<%=qidx%>[<%=coreidx%>].wt_ace_rdnosnp      = 0;
            m_iocache_seq<%=qidx%>[<%=coreidx%>].wt_ace_rdonce       = 0;
            m_iocache_seq<%=qidx%>[<%=coreidx%>].wt_ace_rdunq        = 0;
            m_iocache_seq<%=qidx%>[<%=coreidx%>].wt_ace_rdshrd       = 0;
            m_iocache_seq<%=qidx%>[<%=coreidx%>].wt_ace_rdcln        = 0;
            m_iocache_seq<%=qidx%>[<%=coreidx%>].wt_ace_rdnotshrddty = 0;
            m_iocache_seq<%=qidx%>[<%=coreidx%>].wt_ace_wrnosnp      = 0;
            m_iocache_seq<%=qidx%>[<%=coreidx%>].wt_ace_wrunq        = 0;
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
	    if($test$plusargs("noncoherent_test")) begin
               // Enable both read+write by default
               m_iocache_seq<%=qidx%>[<%=coreidx%>].wt_ace_rdnosnp   = 50;
               m_iocache_seq<%=qidx%>[<%=coreidx%>].wt_ace_wrnosnp   = 50;
               if ($test$plusargs("read_test")) begin
                   m_iocache_seq<%=qidx%>[<%=coreidx%>].wt_ace_wrnosnp     = 0;
               end 
               if ($test$plusargs("write_test")) begin
                   m_iocache_seq<%=qidx%>[<%=coreidx%>].wt_ace_rdnosnp     = 0;
	       end
	    end // if ($test$lusargs("noncoherent_test"))
            <% if(obj.AiuInfo[pidx].NcMode != 1) { %>
	    else begin
               // Enable both read+write by default
               m_iocache_seq<%=qidx%>[<%=coreidx%>].wt_ace_rdonce       = 50;
               m_iocache_seq<%=qidx%>[<%=coreidx%>].wt_ace_wrunq        = 50;
               if ($test$plusargs("read_test")) begin
                   m_iocache_seq<%=qidx%>[<%=coreidx%>].wt_ace_wrunq       = 0;
               end 
               if ($test$plusargs("write_test")) begin
                   m_iocache_seq<%=qidx%>[<%=coreidx%>].wt_ace_rdonce      = 0;
	       end
            end																		       <% } %>	     
            m_iocache_seq<%=qidx%>[<%=coreidx%>].user_qos       = 1;
            m_iocache_seq<%=qidx%>[<%=coreidx%>].aiu_qos        = ioaiu_qos[<%=qidx%>];
   <% } %> // foreach core 
    <% } qidx++; %>
  <% } %>
<% } %>

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
  <% 
  var chiaiu_idx = 0;
  var ioaiu_idx = 0;
  for(var pidx = 0; pidx < obj.nAIUs; pidx++) { %>
    <% if((obj.AiuInfo[pidx].fnNativeInterface == 'CHI-A')||(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-B' || obj.AiuInfo[pidx].fnNativeInterface == 'CHI-E')) { %>
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
      <% chiaiu_idx++; %>
    <% } else {
       if(obj.AiuInfo[pidx].fnNativeInterface == 'ACE-LITE' || obj.AiuInfo[pidx].fnNativeInterface == 'ACELITE-E' || obj.AiuInfo[pidx].fnNativeInterface == 'ACE') { %>
                    begin
            <% for(var coreidx=0; coreidx < aiu_NumCores[pidx]; coreidx++) { %>
		        if(ioaiu_en.exists(<%=ioaiu_idx%>)) begin
                        phase.raise_objection(this, "IOAIU<%=ioaiu_idx%>[<%=coreidx%>] sequence");		
                        `uvm_info("TEST_MAIN", "Start IOAIU<%=ioaiu_idx%>[<%=coreidx%>] VSEQ", UVM_NONE)
                        //m_iocache_seq<%=ioaiu_idx%>.start(null);                        
                        if(<%=ioaiu_idx%> == 0) begin
                           pcie_write<%=ioaiu_idx%>(dmi_addr, flag_addr, perf_txn_size, num_iter);
                        end else if(<%=ioaiu_idx%> == 1) begin
                           pcie_read<%=ioaiu_idx%>(dmi_addr, flag_addr, perf_txn_size, num_iter);
                        end else if(<%=ioaiu_idx%> == 2) begin
                           m_iocache_seq<%=ioaiu_idx%>[<%=coreidx%>].start(null);
                        end
                        `uvm_info("TEST_MAIN", "Done IOAIU<%=ioaiu_idx%>[<%=coreidx%>] VSEQ", UVM_NONE)
                        #5us;
                        phase.drop_objection(this, "IOAIU<%=ioaiu_idx%>[<%=coreidx%>] sequence");
                        end
            <% } %> // foreach core
                    end
    <% } ioaiu_idx++; } %>
  <% } %>
                    begin
                        fork
  <%chiaiu_idx = 0;
  ioaiu_idx = 0;
  for(var pidx = 0; pidx < obj.nAIUs; pidx++) {
    if((obj.AiuInfo[pidx].fnNativeInterface == 'CHI-A')||(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-B' || obj.AiuInfo[pidx].fnNativeInterface == 'CHI-E')) { %>
		        if(chiaiu_en.exists(<%=chiaiu_idx%>)) begin												
                            ev_chi<%=chiaiu_idx%>_seq_done.wait_trigger();
			end
      <% chiaiu_idx++;
    } else {
      if(obj.AiuInfo[pidx].fnNativeInterface == 'ACE-LITE' || obj.AiuInfo[pidx].fnNativeInterface == 'ACELITE-E' || obj.AiuInfo[pidx].fnNativeInterface == 'ACE') { %>
		        <% for(var coreidx=0; coreidx < aiu_NumCores[pidx]; coreidx++) { %>
              if(ioaiu_en.exists(<%=ioaiu_idx%>)) begin
                            if(<%=ioaiu_idx%> == 2) begin
                                ev_ioaiu<%=ioaiu_idx%>_<%=coreidx%>_seq_done.wait_trigger();
                            end
                        end
             <% } %> // foreach core
    <% } ioaiu_idx++; }
  } %>
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

task concerto_fullsys_pcie_test::exec_inhouse_boot_seq(uvm_phase phase);
// Randomize and set configuration in DMI scoreboard
    bit [31:0] agent_id,way_vec,way_full_chk;
    bit [31:0] agent_ids_assigned_q[addr_trans_mgr_pkg::addrMgrConst::NUM_DMIS][$];
    bit [31:0] wayvec_assigned_q[addr_trans_mgr_pkg::addrMgrConst::NUM_DMIS][$];
    int shared_ways_per_user;
    int way_for_atomic=0;
    bit dmi_scb_en;

    int sp_ways[] = new[addr_trans_mgr_pkg::addrMgrConst::NUM_DMIS];
    int sp_size[] = new[addr_trans_mgr_pkg::addrMgrConst::NUM_DMIS];
    bit [<%=obj.wSysAddr-1%>:0] k_sp_base_addr[] = new[addr_trans_mgr_pkg::addrMgrConst::NUM_DMIS];
    int idxq[$];

    addr_trans_mgr_pkg::addrMgrConst::sys_addr_csr_t csrq[$];
    csrq = addr_trans_mgr_pkg::addrMgrConst::get_all_gpra();

    if (!$value$plusargs("dmi_scb_en=%d",dmi_scb_en)) begin
        dmi_scb_en = 0;
    end
    for(int i=0; i<addr_trans_mgr_pkg::addrMgrConst::NUM_DMIS; i++) begin
    int max_way_partitioning;
       if(addr_trans_mgr_pkg::addrMgrConst::dmis_with_ae[i]) begin  
          way_for_atomic = $urandom_range(0,addr_trans_mgr_pkg::addrMgrConst::dmi_CmcWays[i]-1);
       end
       if(addr_trans_mgr_pkg::addrMgrConst::dmis_with_cmcwp[i]) begin  
          way_full_chk = 0;
          for(int k=0; k<<%=obj.nAIUs%>;k++) begin
             agent_ids_assigned_q[i].push_back(k);  
          end
          agent_ids_assigned_q[i].shuffle();  
          max_way_partitioning = (addr_trans_mgr_pkg::addrMgrConst::dmi_CmcWPReg[i] > <%=obj.nAIUs%>) ? <%=obj.nAIUs%> : addr_trans_mgr_pkg::addrMgrConst::dmi_CmcWPReg[i];
          for( int j=0;j<max_way_partitioning /*addr_trans_mgr_pkg::addrMgrConst::dmi_CmcWPReg[i]*/;j++) begin

             if ($test$plusargs("all_way_partitioning")) begin
                if((j==0)&&(addr_trans_mgr_pkg::addrMgrConst::dmis_with_ae[j]==0)) begin 
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
          if(addr_trans_mgr_pkg::addrMgrConst::dmis_with_ae[i]==0) begin
             shared_ways_per_user = addr_trans_mgr_pkg::addrMgrConst::dmi_CmcWays[i]/addr_trans_mgr_pkg::addrMgrConst::dmi_CmcWPReg[i];
          end else begin
             shared_ways_per_user = (addr_trans_mgr_pkg::addrMgrConst::dmi_CmcWays[i]-1)/addr_trans_mgr_pkg::addrMgrConst::dmi_CmcWPReg[i];
          end
          for( int j=0;j<addr_trans_mgr_pkg::addrMgrConst::dmi_CmcWPReg[i];j++) begin
              if ($test$plusargs("all_way_partitioning")&&(addr_trans_mgr_pkg::addrMgrConst::dmis_with_ae[j]==0)) begin
                 way_vec = ((1<<addr_trans_mgr_pkg::addrMgrConst::dmi_CmcWays[i])-1);
              end else begin
                 way_vec = ((1<<$urandom_range(1,shared_ways_per_user)) - 1) << (shared_ways_per_user)*j;
              end
              if ($test$plusargs("no_way_partitioning")) way_vec=0;
		      `uvm_info("TEST_MAIN", $sformatf("For DMI%0d reg%0d with wayvec :%0b",i,j,way_vec), UVM_LOW)
              wayvec_assigned_q[i].push_back(way_vec);
              way_full_chk |=way_vec;
              `uvm_info("TEST_MAIN", $sformatf("For DMI%0d reg%0d with wayfull:%0b num ways in DMI:%0d",i,j,way_full_chk,addr_trans_mgr_pkg::addrMgrConst::dmi_CmcWays[i]), UVM_LOW)
          end

          for( int j=0;j<addr_trans_mgr_pkg::addrMgrConst::dmi_CmcWPReg[i];j++) begin
              `uvm_info("TEST_MAIN", $sformatf("For DMI%0d reg%0d with wayfull:%0b count ones:%0d",i,j,way_full_chk,$countones(way_full_chk)), UVM_LOW)
              way_vec = wayvec_assigned_q[i].pop_front;
              if(addr_trans_mgr_pkg::addrMgrConst::dmis_with_ae[i] && $countones(way_full_chk)>=addr_trans_mgr_pkg::addrMgrConst::dmi_CmcWays[i]) begin  
                 way_vec[way_for_atomic] = 1'b0;
                 `uvm_info("TEST_MAIN", $sformatf("For DMI%0d with AtomicEngine way:%0d/%0d is unallocated, so that atomic txn can allocate",i,way_for_atomic,addr_trans_mgr_pkg::addrMgrConst::dmi_CmcWays[i]), UVM_LOW)
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
       end // if (addr_trans_mgr_pkg::addrMgrConst::dmis_with_cmcwp[i])

       // Configure Scratchpad memories
       if(addr_trans_mgr_pkg::addrMgrConst::dmis_with_cmcsp[i]) begin  
          // Enabling and configuring Scratchpad using force
          if ($test$plusargs("all_ways_for_sp")) begin
              sp_ways[i] = addr_trans_mgr_pkg::addrMgrConst::dmi_CmcWays[i];
          end else if ($test$plusargs("all_ways_for_cache")) begin
              sp_ways[i] = 0;
          end else begin
              randcase
                  //15 : sp_ways[i] = 0;
                  30 : sp_ways[i] = addr_trans_mgr_pkg::addrMgrConst::dmi_CmcWays[i];
                  30 : sp_ways[i] = (addr_trans_mgr_pkg::addrMgrConst::dmi_CmcWays[i]/2);
                  40 : sp_ways[i] = $urandom_range(1,(addr_trans_mgr_pkg::addrMgrConst::dmi_CmcWays[i]-1));
              endcase
          end
 
          idxq = csrq.find_index(x) with (  (x.unit.name == "DMI") && (x.mig_nunitid == addr_trans_mgr_pkg::addrMgrConst::dmi_intrlvgrp[addr_trans_mgr_pkg::addrMgrConst::picked_dmi_igs][i]) );
          if(idxq.size() == 0) begin
              `uvm_error("EXEC_INHOUSE_BOOT_SEQ", $sformatf("DMI%0d Interleaving group %0d not found", i, addr_trans_mgr_pkg::addrMgrConst::dmi_intrlvgrp[addr_trans_mgr_pkg::addrMgrConst::picked_dmi_igs][i]))
              end
          k_sp_base_addr[i] = {csrq[idxq[0]].upp_addr,csrq[idxq[0]].low_addr,12'h0}; 

          sp_size[i] = addr_trans_mgr_pkg::addrMgrConst::dmi_CmcSet[i] * sp_ways[i];
          k_sp_base_addr[i] = $urandom_range(0, k_sp_base_addr[i] - (sp_size[i] << <%=obj.wCacheLineOffset%>) - 1);
          k_sp_base_addr[i] = k_sp_base_addr[i] >> ($clog2(addr_trans_mgr_pkg::addrMgrConst::dmi_CmcSet[i]*addr_trans_mgr_pkg::addrMgrConst::dmi_CmcWays[i])+<%=obj.wCacheLineOffset%>);
          k_sp_base_addr[i] = k_sp_base_addr[i] << ($clog2(addr_trans_mgr_pkg::addrMgrConst::dmi_CmcSet[i]*addr_trans_mgr_pkg::addrMgrConst::dmi_CmcWays[i])+<%=obj.wCacheLineOffset%>);

          <% if((obj.useCmc) && (numDmiWithSP > 0)) { %>
	  if(m_args.dmi_scb_en) begin 
              case(i) <%for(var sidx = 0; sidx < obj.nDMIs; sidx++) { if(obj.DmiInfo[sidx].ccpParams.useScratchpad==1) {%>
                 <%=sidx%> : 
                    if(sp_ways[<%=sidx%>] > 0) begin
                       m_concerto_env.inhouse.m_dmi<%=sidx%>_env.m_sb.sp_enabled     = (addr_trans_mgr_pkg::addrMgrConst::dmi_CmcWays[<%=sidx%>]) ? 32'h1 : 32'h0;
                       m_concerto_env.inhouse.m_dmi<%=sidx%>_env.m_sb.lower_sp_addr  = k_sp_base_addr[<%=sidx%>];
                       m_concerto_env.inhouse.m_dmi<%=sidx%>_env.m_sb.sp_ways        = sp_ways[<%=sidx%>];
                       m_concerto_env.inhouse.m_dmi<%=sidx%>_env.m_sb.create_SP_q();
		    end
                <% } } %>
              endcase
	  end
          <% } %>
       end // if (addr_trans_mgr_pkg::addrMgrConst::dmis_with_cmcsp[i])
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
    <% if(numChiAiu > 0) { %>
    m_chi0_vseq.m_regs = m_concerto_env.m_regs;
    m_chi0_vseq.enum_boot_seq(agent_ids_assigned_q,wayvec_assigned_q, k_sp_base_addr, sp_ways, sp_size, aiu_qos_threshold, dce_qos_threshold, dmi_qos_threshold);                        
    <% } else { %>
    randcase
<% for(var idx = 0, qidx=0; idx < obj.nAIUs; idx++) { 
    if((obj.AiuInfo[idx].fnNativeInterface != 'CHI-A')&&(obj.AiuInfo[idx].fnNativeInterface != 'CHI-B' && obj.AiuInfo[idx].fnNativeInterface != 'CHI-E')) { %>
            1: begin 
               `uvm_info("TEST_MAIN", "Start IOAIU<%=qidx%> boot_seq", UVM_NONE)
                // NEW FSYS TEST: NEEED update CONFIGURE_PAHSE //ioaiu_boot_seq<%=qidx%>(agent_ids_assigned_q,wayvec_assigned_q, k_sp_base_addr, sp_ways, sp_size, aiu_qos_threshold, dce_qos_threshold, dmi_qos_threshold, dmi_qos_rsved); 
               
               end
        <% qidx++;  }
    } %>
    endcase
    <% } %>
#5us; // Need to wait for pending transactions to complete e.g. DTRRsp
endtask: exec_inhouse_boot_seq

  
//////////////////
//Calling Method: UVM Factory
//Description: start_of_simulation_phase
//Arguments:   UVM Default
//Return type: Void
//////////////////
function void concerto_fullsys_pcie_test::start_of_simulation_phase(uvm_phase phase);
    super.start_of_simulation_phase(phase);
endfunction : start_of_simulation_phase 


//////////////////
//Calling Method: UVM Factory
//Description: report phase, calls report method to display EOT results
//Arguments:   UVM Default
//Return type: Void
//////////////////
function void concerto_fullsys_pcie_test::report_phase(uvm_phase phase);
    super.report_phase(phase);
endfunction : report_phase


task concerto_fullsys_pcie_test::set_ioaiu_control_cfg();
   int ioaiu_control_cfg;
   
   $value$plusargs("ioaiu_control_cfg=%d",ioaiu_control_cfg);
   if(ioaiu_control_cfg == 1) begin
  <% for(var pidx = 0; pidx < obj.nAIUs; pidx++) { %>
    <% if((obj.AiuInfo[pidx].fnNativeInterface == 'ACE-LITE')||(obj.AiuInfo[pidx].fnNativeInterface == 'ACELITE-E')||(obj.AiuInfo[pidx].fnNativeInterface == 'ACE')) { %>
	   <% if(obj.testBench != 'emu'){ %> 
	   force `U_CHIP.<%=obj.AiuInfo[pidx].strRtlNamePrefix%>.ioaiu_core_wrapper.ioaiu_core0.apb_csr.XAIUEDR1_cfg_out = 32'h00100000;
           <% } %>
	   <% if(obj.testBench == 'emu'){ %> 
	   //force ncore_hdl_top.dut.<%=obj.AiuInfo[pidx].strRtlNamePrefix%>.ioaiu_core.apb_csr.XAIUEDR1_cfg_out = 32'h00100000;
           <% } %>
    <% } %>
  <% } %>
   end
   else if(ioaiu_control_cfg == 2) begin
  <% for(var pidx = 0; pidx < obj.nAIUs; pidx++) { %>
    <% if((obj.AiuInfo[pidx].fnNativeInterface == 'ACE-LITE')||(obj.AiuInfo[pidx].fnNativeInterface == 'ACELITE-E')||(obj.AiuInfo[pidx].fnNativeInterface == 'ACE')) { %>
	   <% if(obj.testBench != 'emu'){ %> 
	   force `U_CHIP.<%=obj.AiuInfo[pidx].strRtlNamePrefix%>.ioaiu_core_wrapper.ioaiu_core0.apb_csr.XAIUEDR1_cfg_out = 32'h00200000;
           <% } %>
	   <% if(obj.testBench == 'emu'){ %> 
	   //force ncore_hdl_top.dut.<%=obj.AiuInfo[pidx].strRtlNamePrefix%>.ioaiu_core.apb_csr.XAIUEDR1_cfg_out = 32'h00200000;
           <% } %>
    <% } %>
  <% } %>
   end
   else begin
  <% for(var pidx = 0; pidx < obj.nAIUs; pidx++) { %>
    <% if((obj.AiuInfo[pidx].fnNativeInterface == 'ACE-LITE')||(obj.AiuInfo[pidx].fnNativeInterface == 'ACELITE-E')||(obj.AiuInfo[pidx].fnNativeInterface == 'ACE')) { %>
	   <% if(obj.testBench != 'emu'){ %> 
	   force `U_CHIP.<%=obj.AiuInfo[pidx].strRtlNamePrefix%>.ioaiu_core_wrapper.ioaiu_core0.apb_csr.XAIUEDR1_cfg_out = 32'h00000000;
           <% } %>
	   <% if(obj.testBench == 'emu'){ %> 
	   //force ncore_hdl_top.dut.<%=obj.AiuInfo[pidx].strRtlNamePrefix%>.ioaiu_core.apb_csr.XAIUEDR1_cfg_out = 32'h00000000;
           <% } %>
    <% } %>
  <% } %>
   end
endtask : set_ioaiu_control_cfg

<% for(var idx = 0, qidx=0; idx < obj.nAIUs; idx++) { 
    if((obj.AiuInfo[idx].fnNativeInterface != 'CHI-A')&&(obj.AiuInfo[idx].fnNativeInterface != 'CHI-B' && obj.AiuInfo[idx].fnNativeInterface != 'CHI-E')) {
       if(obj.AiuInfo[idx].fnNativeInterface == 'ACE-LITE' || obj.AiuInfo[idx].fnNativeInterface == 'ACELITE-E' || obj.AiuInfo[idx].fnNativeInterface == 'ACE') { %>

task concerto_fullsys_pcie_test::write_unq<%=qidx%>(input ioaiu<%=qidx%>_axi_agent_pkg::axi_axaddr_t addr, input bit[ioaiu<%=qidx%>_axi_agent_pkg::WXDATA-1:0] data, input ioaiu<%=qidx%>_axi_agent_pkg::axi_axlen_t axlen, input ioaiu<%=qidx%>_axi_agent_pkg::axi_awid_t awid, input bit use_user_data=0);
    ioaiu<%=qidx%>_inhouse_axi_bfm_pkg::axi_single_wrunq_data_seq m_iowrunq_seq<%=qidx%>[<%=aiu_NumCores[pidx]%>];
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
   <% for(var coreidx=0; coreidx < aiu_NumCores[pidx]; coreidx++) { %>
    m_iowrunq_seq<%=qidx%>[<%=coreidx%>]   = ioaiu<%=qidx%>_inhouse_axi_bfm_pkg::axi_single_wrunq_data_seq::type_id::create("m_iowrunq_seq<%=qidx%>_<%=coreidx%>");

    m_iowrunq_seq<%=qidx%>[<%=coreidx%>].m_addr = addr;
    m_iowrunq_seq<%=qidx%>[<%=coreidx%>].m_axlen = axlen;
    m_iowrunq_seq<%=qidx%>[<%=coreidx%>].use_awid = awid;

    m_iowrunq_seq<%=qidx%>[<%=coreidx%>].m_data = wdata[0];
    m_iowrunq_seq<%=qidx%>[<%=coreidx%>].m_wstrb = 'hFFFFFFFFFFFFFFFF;
    //`uvm_info("TEST_MAIN", $sformatf("write_unq address 0x%0h with data = %p", addr, m_iowrunq_seq<%=qidx%>.m_data), UVM_NONE);
    m_iowrunq_seq<%=qidx%>[<%=coreidx%>].start(m_ioaiu_vseqr<%=qidx%>[<%=coreidx%>]);
    <% } %> // foreach core 
endtask : write_unq<%=qidx%>

task concerto_fullsys_pcie_test::read_once<%=qidx%>(input ioaiu<%=qidx%>_axi_agent_pkg::axi_axaddr_t addr, input ioaiu<%=qidx%>_axi_agent_pkg::axi_axlen_t axlen, input ioaiu<%=qidx%>_axi_agent_pkg::axi_arid_t arid, output bit[ioaiu<%=qidx%>_axi_agent_pkg::WXDATA-1:0] data);
    ioaiu<%=qidx%>_inhouse_axi_bfm_pkg::axi_rdonce_seq m_iordonce_seq<%=qidx%>[<%=aiu_NumCores[pidx]%>];
    bit [ioaiu<%=qidx%>_axi_agent_pkg::WXDATA-1:0] rdata;
    ioaiu<%=qidx%>_axi_agent_pkg::axi_rresp_t rresp;
    int addr_mask;
    int addr_offset;
										
    addr_mask = (ioaiu<%=qidx%>_axi_agent_pkg::WXDATA/8)-1;
    addr_offset = addr & addr_mask;
<% for(var coreidx=0; coreidx < aiu_NumCores[pidx]; coreidx++) { %>
    m_iordonce_seq<%=qidx%>[<%=coreidx%>]   = ioaiu<%=qidx%>_inhouse_axi_bfm_pkg::axi_rdonce_seq::type_id::create("m_iordonce_seq<%=qidx%>_<%=coreidx%>");
    m_iordonce_seq<%=qidx%>[<%=coreidx%>].m_addr = addr;
    m_iordonce_seq<%=qidx%>[<%=coreidx%>].m_len  = axlen;
    m_iordonce_seq<%=qidx%>[<%=coreidx%>].use_arid = arid;
    m_iordonce_seq<%=qidx%>[<%=coreidx%>].start(m_ioaiu_vseqr<%=qidx%>[<%=coreidx%>]);

    if(m_iordonce_seq<%=qidx%>[<%=coreidx%>].m_seq_item.m_has_data) begin   
       //`uvm_info("TEST_MAIN", $sformatf("read_once address 0x%0h with data = %p", addr, m_iordonce_seq<%=qidx%>.m_seq_item.m_read_data_pkt.rdata), UVM_NONE);
       data = m_iordonce_seq<%=qidx%>[<%=coreidx%>].m_seq_item.m_read_data_pkt.rdata[0];
       rresp =  m_iordonce_seq<%=qidx%>[<%=coreidx%>].m_seq_item.m_read_data_pkt.rresp;
    end else begin
       data = 0;
       rresp = 0;
    end
  
    if(rresp) begin
        `uvm_error("READ_ONCE",$sformatf("Read address 0x%0h returns resp_err :0x%0h",addr, rresp))
    end
    <% } %> // foreach core
endtask : read_once<%=qidx%>

task concerto_fullsys_pcie_test::write_nosnp<%=qidx%>(input ioaiu<%=qidx%>_axi_agent_pkg::axi_axaddr_t addr, input bit[ioaiu<%=qidx%>_axi_agent_pkg::WXDATA-1:0] data, input ioaiu<%=qidx%>_axi_agent_pkg::axi_axlen_t axlen, input ioaiu<%=qidx%>_axi_agent_pkg::axi_awid_t awid, input bit use_user_data=0);
    ioaiu<%=qidx%>_inhouse_axi_bfm_pkg::axi_single_wrnosnp_seq m_iowrnosnp_seq<%=qidx%>[<%=aiu_NumCores[pidx]%>];
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
   <% for(var coreidx=0; coreidx < aiu_NumCores[pidx]; coreidx++) { %>
    m_iowrnosnp_seq<%=qidx%>[<%=coreidx%>]   = ioaiu<%=qidx%>_inhouse_axi_bfm_pkg::axi_single_wrnosnp_seq::type_id::create("m_iowrnosnp_seq<%=qidx%>_<%=coreidx%>");

    m_iowrnosnp_seq<%=qidx%>[<%=coreidx%>].m_addr = addr;
    m_iowrnosnp_seq<%=qidx%>[<%=coreidx%>].m_axlen = axlen;
    m_iowrnosnp_seq<%=qidx%>[<%=coreidx%>].use_awid = awid;

    m_iowrnosnp_seq<%=qidx%>[<%=coreidx%>].m_data = wdata[0];
    m_iowrnosnp_seq<%=qidx%>[<%=coreidx%>].m_wstrb = 'hFFFFFFFFFFFFFFFF;
    //`uvm_info("TEST_MAIN", $sformatf("write_nosnp address 0x%0h with data = %p", addr, m_iowrunq_seq<%=qidx%>.m_data), UVM_NONE);
    m_iowrnosnp_seq<%=qidx%>[<%=coreidx%>].start(m_ioaiu_vseqr<%=qidx%>[<%=coreidx%>]);
    <% } %> // foreach core
endtask : write_nosnp<%=qidx%>

task concerto_fullsys_pcie_test::read_nosnp<%=qidx%>(input ioaiu<%=qidx%>_axi_agent_pkg::axi_axaddr_t addr, input ioaiu<%=qidx%>_axi_agent_pkg::axi_axlen_t axlen, input ioaiu<%=qidx%>_axi_agent_pkg::axi_arid_t arid, output bit[ioaiu<%=qidx%>_axi_agent_pkg::WXDATA-1:0] data);
    ioaiu<%=qidx%>_inhouse_axi_bfm_pkg::axi_rdnosnp_seq m_iordnosnp_seq<%=qidx%>[<%=aiu_NumCores[pidx]%>];
    bit [ioaiu<%=qidx%>_axi_agent_pkg::WXDATA-1:0] rdata;
    ioaiu<%=qidx%>_axi_agent_pkg::axi_rresp_t rresp;
    int addr_mask;
    int addr_offset;
										
    addr_mask = (ioaiu<%=qidx%>_axi_agent_pkg::WXDATA/8)-1;
    addr_offset = addr & addr_mask;
   <% for(var coreidx=0; coreidx < aiu_NumCores[pidx]; coreidx++) { %>
    m_iordnosnp_seq<%=qidx%>[<%=coreidx%>]   = ioaiu<%=qidx%>_inhouse_axi_bfm_pkg::axi_rdnosnp_seq::type_id::create("m_iordnosnp_seq<%=qidx%>_<%=coreidx%>");
    m_iordnosnp_seq<%=qidx%>[<%=coreidx%>].m_addr = addr;
    m_iordnosnp_seq<%=qidx%>[<%=coreidx%>].m_len  = axlen;
    m_iordnosnp_seq<%=qidx%>[<%=coreidx%>].use_arid = arid;
    m_iordnosnp_seq<%=qidx%>[<%=coreidx%>].start(m_ioaiu_vseqr<%=qidx%>[<%=coreidx%>);

    if(m_iordnosnp_seq<%=qidx%>[<%=coreidx%>].m_seq_item.m_has_data) begin   
       //`uvm_info("TEST_MAIN", $sformatf("read_nosnp address 0x%0h with data = %p", addr, m_iordnosnp_seq<%=qidx%>.m_seq_item.m_read_data_pkt.rdata), UVM_NONE);
       data = m_iordnosnp_seq<%=qidx%>[<%=coreidx%>].m_seq_item.m_read_data_pkt.rdata[0];
       rresp =  m_iordnosnp_seq<%=qidx%>[<%=coreidx%>].m_seq_item.m_read_data_pkt.rresp;
    end else begin
       data = 0;
       rresp = 0;
    end
  
    if(rresp) begin
        `uvm_error("READ_NOSNP",$sformatf("Read address 0x%0h returns resp_err :0x%0h",addr, rresp))
    end
    <% } %> // foreach core
endtask : read_nosnp<%=qidx%>

task concerto_fullsys_pcie_test::write_4KB_block<%=qidx%>(input ioaiu<%=qidx%>_axi_agent_pkg::axi_axaddr_t dmi_addr, input ioaiu<%=qidx%>_axi_agent_pkg::axi_axaddr_t flag_addr, input int txn_size, input int counter);
    int num_txns = 4096/txn_size;
    ioaiu<%=qidx%>_axi_agent_pkg::axi_awid_t force_awid;
    int id_incr = 0;

    if(!$value$plusargs("force_axid=%d", force_awid)) begin
        force_awid = m_awid<%=qidx%>;
	id_incr = 1;
    end
				  
    `uvm_info("TEST_MAIN", $sformatf("write_4KB_block<%=qidx%> iter %0d starting DMI address = 0x%0h, txn_size=%0d, num_txns=%0d", counter, dmi_addr, txn_size, num_txns), UVM_NONE);
    fork
           //automatic bit [addrMgrConst::W_SEC_ADDR-1:0] m_addr = use_dii_addr ? dii_addr : (dmi_addr + (num_txns*txn_size));
	   automatic ioaiu<%=qidx%>_axi_agent_pkg::axi_awid_t use_awid = force_awid + (num_txns*id_incr);
           if($test$plusargs("noncoherent_test") || $test$plusargs("use_dii_addr")) begin
               write_nosnp<%=qidx%>(flag_addr, counter, (32/(ioaiu<%=qidx%>_axi_agent_pkg::WXDATA/8)-1), use_awid, 1);
           end else begin
               write_unq<%=qidx%>(flag_addr, counter, (32/(ioaiu<%=qidx%>_axi_agent_pkg::WXDATA/8)-1), use_awid, 1);
           end
    join_none
    for(int txn=num_txns-1; txn>=0; txn=txn-1) begin
        fork 
           automatic bit [addrMgrConst::W_SEC_ADDR-1:0] m_addr = dmi_addr + (txn*txn_size);
	   automatic ioaiu<%=qidx%>_axi_agent_pkg::axi_awid_t use_awid = force_awid + (txn*id_incr);
           if($test$plusargs("noncoherent_test")) begin
              write_nosnp<%=qidx%>(m_addr, m_addr, (txn_size/(ioaiu<%=qidx%>_axi_agent_pkg::WXDATA/8)-1), use_awid, 0);
           end else begin
              write_unq<%=qidx%>(m_addr, m_addr, (txn_size/(ioaiu<%=qidx%>_axi_agent_pkg::WXDATA/8)-1), use_awid, 0);
           end
        join_none  
    end

    m_awid<%=qidx%> = m_awid<%=qidx%> + num_txns;
    //wait fork;
endtask : write_4KB_block<%=qidx%>

task concerto_fullsys_pcie_test::read_4KB_block<%=qidx%>(input ioaiu<%=qidx%>_axi_agent_pkg::axi_axaddr_t dmi_addr, input ioaiu<%=qidx%>_axi_agent_pkg::axi_axaddr_t flag_addr, input int txn_size, input int counter);
    int num_txns = 4096/txn_size;
    bit[ioaiu<%=qidx%>_axi_agent_pkg::WXDATA-1:0] data;
    //bit [addrMgrConst::W_SEC_ADDR-1:0] poll_addr = use_dii_addr ? dii_addr : (dmi_addr + (num_txns*txn_size));
    ioaiu<%=qidx%>_axi_agent_pkg::axi_arid_t force_arid;
    int id_incr = 0;

    if(!$value$plusargs("force_axid=%d", force_arid)) begin
        force_arid = m_arid<%=qidx%>;
	id_incr = 1;
    end

    `uvm_info("TEST_MAIN", $sformatf("read_4KB_block<%=qidx%> iter %0d starting DMI address = 0x%0h, txn_size=%0d, num_txns=%0d", counter, dmi_addr, txn_size, num_txns), UVM_NONE);
    do begin
	automatic ioaiu<%=qidx%>_axi_agent_pkg::axi_arid_t use_arid = force_arid + (num_txns*id_incr);
        if($test$plusargs("noncoherent_test") || $test$plusargs("use_dii_addr")) begin
           read_nosnp<%=qidx%>(flag_addr, (32/(ioaiu<%=qidx%>_axi_agent_pkg::WXDATA/8)-1), use_arid, data);  
        end else begin
           read_once<%=qidx%>(flag_addr, (32/(ioaiu<%=qidx%>_axi_agent_pkg::WXDATA/8)-1), use_arid, data);  
        end
    end while (data != counter);
  
    for(int txn=(num_txns-1); txn>=0; txn=txn-1) begin
        fork
           automatic bit [addrMgrConst::W_SEC_ADDR-1:0] m_addr = dmi_addr + (txn*txn_size);
	   automatic ioaiu<%=qidx%>_axi_agent_pkg::axi_arid_t use_arid = force_arid + (txn*id_incr);
           if($test$plusargs("noncoherent_test")) begin
              read_nosnp<%=qidx%>(m_addr, (txn_size/(ioaiu<%=qidx%>_axi_agent_pkg::WXDATA/8)-1), use_arid, data);
           end else begin
              read_once<%=qidx%>(m_addr, (txn_size/(ioaiu<%=qidx%>_axi_agent_pkg::WXDATA/8)-1), use_arid, data);
           end
        join_none  
    end

    m_arid<%=qidx%> = m_arid<%=qidx%> + num_txns;
    //wait fork;
endtask : read_4KB_block<%=qidx%>

task concerto_fullsys_pcie_test::pcie_write<%=qidx%>(input ioaiu<%=qidx%>_axi_agent_pkg::axi_axaddr_t dmi_addr, input ioaiu<%=qidx%>_axi_agent_pkg::axi_axaddr_t flag_addr, input int txn_size, input int num_iter);
    bit [addrMgrConst::W_SEC_ADDR-1:0] m_dmi_addr;
    bit [addrMgrConst::W_SEC_ADDR-1:0] m_flag_addr;
  
    `uvm_info("TEST_MAIN", $sformatf("pcie_write<%=qidx%> starting DMI address = 0x%0h, num_iter=%0d", dmi_addr, num_iter), UVM_NONE);
    for(int iter=0; iter<num_iter; iter=iter+1) begin
        automatic bit [addrMgrConst::W_SEC_ADDR-1:0] m_dmi_addr = dmi_addr + (iter * (4096+txn_size));
        automatic bit [addrMgrConst::W_SEC_ADDR-1:0] m_flag_addr = flag_addr + (iter * 64);
        write_4KB_block<%=qidx%>(m_dmi_addr, m_flag_addr, txn_size, iter+1);
        #2ns;
    end
    wait fork;
endtask : pcie_write<%=qidx%>

task concerto_fullsys_pcie_test::pcie_read<%=qidx%>(input ioaiu<%=qidx%>_axi_agent_pkg::axi_axaddr_t dmi_addr, input ioaiu<%=qidx%>_axi_agent_pkg::axi_axaddr_t flag_addr, input int txn_size, input int num_iter);
  
    `uvm_info("TEST_MAIN", $sformatf("pcie_read<%=qidx%> starting DMI address = 0x%0h, num_iter=%0d", dmi_addr, num_iter), UVM_NONE);
    for(int iter=0; iter<num_iter; iter=iter+1) begin
        automatic bit [addrMgrConst::W_SEC_ADDR-1:0] m_dmi_addr = dmi_addr + (iter * (4096+txn_size));
        automatic bit [addrMgrConst::W_SEC_ADDR-1:0] m_flag_addr = flag_addr + (iter * 64);
        read_4KB_block<%=qidx%>(m_dmi_addr, m_flag_addr, txn_size, iter+1);
        #2ns;
    end
    wait fork;
endtask : pcie_read<%=qidx%>
<% } qidx++; }
 } %>

task concerto_fullsys_pcie_test::exec_cache_preload_seq(uvm_phase phase);
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
		        if(chiaiu_cache_preload_en.exists(<%=chiaiu_idx%>)) begin
                        `uvm_info("TEST_MAIN", "Start CHIAIU<%=chiaiu_idx%> VSEQ for Cache Preload", UVM_NONE)
                        phase.raise_objection(this, "CHIAIU<%=chiaiu_idx%> cache preload sequence");
                        m_chi<%=chiaiu_idx%>_vseq.start(null);  
                        `uvm_info("TEST_MAIN", "Done CHIAIU<%=chiaiu_idx%> VSEQ for Cache Preload", UVM_NONE)
                        #5us;
                        phase.drop_objection(this, "CHIAIU<%=chiaiu_idx%> cache preload sequence");
			end
                    end
      <% chiaiu_idx++; %>
    <% } else { %>
                    begin
                       <% for(var coreidx=0; coreidx < aiu_NumCores[pidx]; coreidx++) { %>
		        if(ioaiu_cache_preload_en.exists(<%=ioaiu_idx%>)) begin
                        phase.raise_objection(this, "IOAIU<%=ioaiu_idx%>[<%=aiu_NumCores[pidx]%>] cache preload sequence");
                        `uvm_info("TEST_MAIN", "Start IOAIU<%=ioaiu_idx%>[<%=aiu_NumCores[pidx]%>] VSEQ for Cache Preload", UVM_NONE)
                        m_iocache_seq<%=ioaiu_idx%>[<%=aiu_NumCores[pidx]%>].start(null);
                        `uvm_info("TEST_MAIN", "Done IOAIU<%=ioaiu_idx%>[<%=aiu_NumCores[pidx]%>] VSEQ for Cache Preload", UVM_NONE)
                        #5us;
                        phase.drop_objection(this, "IOAIU<%=ioaiu_idx%>[<%=aiu_NumCores[pidx]%>] cache preload sequence");
                        end
               <% } %> // foreach core 
                    end
    <% ioaiu_idx++; } %>
  <% } %>
                    begin
                        fork
  <%chiaiu_idx = 0;
  ioaiu_idx = 0;
  for(var pidx = 0; pidx < obj.nAIUs; pidx++) {
    if((obj.AiuInfo[pidx].fnNativeInterface == 'CHI-A')||(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-B' || obj.AiuInfo[pidx].fnNativeInterface == 'CHI-E')) { %>
		        if(chiaiu_cache_preload_en.exists(<%=chiaiu_idx%>)) begin												
                            ev_chi<%=chiaiu_idx%>_seq_done.wait_trigger();
			end
      <% chiaiu_idx++;
    } else { %>
            <% for(var coreidx=0; coreidx < aiu_NumCores[pidx]; coreidx++) { %>
		        if(ioaiu_cache_preload_en.exists(<%=ioaiu_idx%>)) begin												
                            ev_ioaiu<%=ioaiu_idx%>_<%=coreidx%>_seq_done.wait_trigger();
                        end
            <% } %> // foreach core
    <% ioaiu_idx++; }
  } %>
                        join
                        `uvm_info("TEST_MAIN", "All cache preload sequences DONE", UVM_NONE)
                        ev_sim_done.trigger(null);
                    end
    join

endtask // exec_preload_cache_seq

task concerto_fullsys_pcie_test::exec_snoop_seq(uvm_phase phase);
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
        addr_mgr.gen_seq_addr_in_user_addrq(use_user_addrq, 64, 0, -1, addrMgrConst::user_addrq[addrMgrConst::COH]);
	<% var chi_idx=0;
	var io_idx=0;
	for(var pidx=0; pidx<obj.nAIUs; pidx++) {
        if((obj.AiuInfo[pidx].fnNativeInterface == "CHI-A") || (obj.AiuInfo[pidx].fnNativeInterface == "CHI-B" || obj.AiuInfo[pidx].fnNativeInterface == "CHI-E")) { %>
	if((chiaiu_snoop_from.exists(<%=chi_idx%>))||(chiaiu_snoop_to.exists(<%=chi_idx%>))) begin
           m_chi<%=chi_idx%>_vseq.m_chi_container.user_addrq[addrMgrConst::COH] = addrMgrConst::user_addrq[addrMgrConst::COH];
        end
	<% chi_idx++;
        } else { %>
	if((ioaiu_snoop_from.exists(<%=io_idx%>))||(ioaiu_snoop_to.exists(<%=io_idx%>))) begin
      <% for(var coreidx=0; coreidx < aiu_NumCores[pidx]; coreidx++) { %>
           m_concerto_env.inhouse.m_ace_cache_model_ioaiu<%=io_idx%>[<%=coreidx%>].user_addrq[addrMgrConst::COH] = addrMgrConst::user_addrq[addrMgrConst::COH];
           <% } %> // foreach core
        end
	<% io_idx++; } 
        } %>
    end // if ($value$plusargs("use_user_addrq=%d", use_user_addrq))

  <% var qidx=0;var idx=0; for(var pidx = 0; pidx < obj.nAIUs; pidx++) { %>
    <% if((obj.AiuInfo[pidx].fnNativeInterface == 'CHI-A')||(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-B' || obj.AiuInfo[pidx].fnNativeInterface == 'CHI-E')) { %>
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
      <% idx++;  %>
    <%} else { %>
    <% for(var coreidx=0; coreidx < aiu_NumCores[pidx]; coreidx++) { %>
            m_iocache_seq<%=qidx%>[<%=coreidx%>].k_num_read_req      = snoop_num_trans;
            m_iocache_seq<%=qidx%>[<%=coreidx%>].k_num_write_req     = 0;
      <% if((obj.AiuInfo[pidx].fnNativeInterface == 'ACE') || (obj.AiuInfo[pidx].fnNativeInterface == 'ACE-LITE') || (obj.AiuInfo[pidx].fnNativeInterface == 'ACELITE-E')) { %>
            m_iocache_seq<%=qidx%>[<%=coreidx%>].wt_ace_rdnosnp      = 0;
            m_iocache_seq<%=qidx%>[<%=coreidx%>].wt_ace_rdonce       = 0;
            m_iocache_seq<%=qidx%>[<%=coreidx%>].wt_ace_rdshrd       = 0;
            m_iocache_seq<%=qidx%>[<%=coreidx%>].wt_ace_rdcln        = 0;
            m_iocache_seq<%=qidx%>[<%=coreidx%>].wt_ace_rdnotshrddty = 0;
            m_iocache_seq<%=qidx%>[<%=coreidx%>].wt_ace_wrnosnp      = 0;
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
            m_iocache_seq<%=qidx%>[<%=coreidx%>].wt_ace_wrunq        = 0;
            m_iocache_seq<%=qidx%>[<%=coreidx%>].wt_ace_rdunq        = 100;
   <% } %>
   <% } %> // foreach core
    <% qidx++; } %>
  
<% } %>

    fork
  <% 
  var chiaiu_idx = 0;
  var ioaiu_idx = 0;
  for(var pidx = 0; pidx < obj.nAIUs; pidx++) { %>
    <% if((obj.AiuInfo[pidx].fnNativeInterface == 'CHI-A')||(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-B' || obj.AiuInfo[pidx].fnNativeInterface == 'CHI-E')) { %>
		    begin
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
                    end
      <% chiaiu_idx++; %>
    <% } else { %>
                    begin
            <% for(var coreidx=0; coreidx < aiu_NumCores[pidx]; coreidx++) { %>
		        if(ioaiu_snoop_from.exists(<%=ioaiu_idx%>)) begin
                        phase.raise_objection(this, "IOAIU<%=ioaiu_idx%>[<%=coreidx%>] snoop from sequence");
                        `uvm_info("TEST_MAIN", "Start IOAIU<%=ioaiu_idx%>[<%=coreidx%>] Snoop From VSEQ", UVM_NONE)
                        m_iocache_seq<%=ioaiu_idx%>[<%=coreidx%>].start(null);
                        `uvm_info("TEST_MAIN", "Done IOAIU<%=ioaiu_idx%>[<%=coreidx%>] Snoop From VSEQ", UVM_NONE)
                        #5us;
                        phase.drop_objection(this, "IOAIU<%=ioaiu_idx%>[<%=coreidx%>] snoop from sequence");
                        end
		        else if(ioaiu_snoop_to.exists(<%=ioaiu_idx%>)) begin
                        phase.raise_objection(this, "IOAIU<%=ioaiu_idx%>[<%=coreidx%>] snoop to sequence");
                        `uvm_info("TEST_MAIN", "Start IOAIU<%=ioaiu_idx%>[<%=coreidx%>] Snoop To VSEQ", UVM_NONE)
                        #1000ns;
                        m_iocache_seq<%=ioaiu_idx%>[<%=coreidx%>].start(null);
                        `uvm_info("TEST_MAIN", "Done IOAIU<%=ioaiu_idx%>[<%=coreidx%>] Snoop To VSEQ", UVM_NONE)
                        #5us;
                        phase.drop_objection(this, "IOAIU<%=ioaiu_idx%>[<%=coreidx%>] snoop to sequence");
                        end
         <% } %> // foreach core
                    end
    <% ioaiu_idx++; } %>
  <% } %>
                    begin
                        fork
  <%chiaiu_idx = 0;
  ioaiu_idx = 0;
  for(var pidx = 0; pidx < obj.nAIUs; pidx++) {
    if((obj.AiuInfo[pidx].fnNativeInterface == 'CHI-A')||(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-B' || obj.AiuInfo[pidx].fnNativeInterface == 'CHI-E')) { %>
		        if((chiaiu_snoop_from.exists(<%=chiaiu_idx%>))||(chiaiu_snoop_to.exists(<%=chiaiu_idx%>))) begin
                            ev_chi<%=chiaiu_idx%>_seq_done.wait_trigger();
			end
      <% chiaiu_idx++;
    } else { %>
    <% for(var coreidx=0; coreidx < aiu_NumCores[pidx]; coreidx++) { %>
		        if((ioaiu_snoop_from.exists(<%=ioaiu_idx%>))||(ioaiu_snoop_to.exists(<%=ioaiu_idx%>))) begin
                            ev_ioaiu<%=ioaiu_idx%>_<%=coreidx%>_seq_done.wait_trigger();
                        end
   <% } %> // foreach core 
    <% ioaiu_idx++; }
  } %>
                        join
                        `uvm_info("TEST_MAIN", "All snoop sequences DONE", UVM_NONE)
                        ev_sim_done.trigger(null);
                    end
    join

endtask // exec_snoop_seq


