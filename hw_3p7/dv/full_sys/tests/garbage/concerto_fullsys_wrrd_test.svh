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
    if((obj.AiuInfo[pidx].fnNativeInterface == "CHI-A")||(obj.AiuInfo[pidx].fnNativeInterface == "CHI-B")||(obj.AiuInfo[pidx].fnNativeInterface == "CHI-E")) 
       { 
         if(numChiAiu == 0) { chiaiu0 = obj.AiuInfo[pidx].strRtlNamePrefix; }
          numChiAiu++ ; numCAiu++ ; 
       }
    else
       { numIoAiu++ ; 
         if(obj.AiuInfo[pidx].fnNativeInterface == "ACE") { numCAiu++ ; numACEAiu++; } else { numNCAiu++ ;}
         if(obj.AiuInfo[pidx].useCache) idxIoAiuWithPC = numNCAiu;
       }
}
var ace_idx=0;
var io_idx=0;
for(var pidx = 0; pidx < obj.nAIUs; pidx++) {
    if((obj.AiuInfo[pidx].fnNativeInterface != "CHI-A")&&(obj.AiuInfo[pidx].fnNativeInterface != "CHI-B")&&(obj.AiuInfo[pidx].fnNativeInterface != "CHI-E")) 
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
%>


//File: concerto_fullsys_wrrd_test.svh

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



class concerto_fullsys_wrrd_test extends concerto_base_test;

    //////////////////
    //Properties
    //////////////////

    static uvm_event csr_trace_debug_done = ev_pool.get("csr_trace_debug_done");
    static uvm_event ev_bist_reset_done = ev_pool.get("bist_reset_done");

    <% for(pidx = 0; pidx < obj.nDMIs; pidx++) {if(obj.DmiInfo[pidx].useCmc) { %>
    static uvm_event ev_inject_error_dmi<%=pidx%>_smc = ev_pool.get("inject_error_dmi<%=pidx%>_smc"); <%}}%>
    `ifdef USE_VIP_SNPS
    bit vip_snps_non_coherent_txn = 0;
    bit vip_snps_coherent_txn = 0;
    int vip_snps_seq_length = 4;

  <% var qidx=0;var idx=0; for(var pidx = 0; pidx < obj.nAIUs; pidx++) { %>
    <% if((obj.AiuInfo[pidx].fnNativeInterface == 'CHI-A')||(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-B' || obj.AiuInfo[pidx].fnNativeInterface == 'CHI-E')) { %>
    svt_chi_rn_transaction_random_sequence svt_chi_rn_seq_h<%=idx%>;
    svt_chi_link_service_activate_sequence svt_chi_link_up_seq_h<%=idx%>;
    svt_chi_link_service_deactivate_sequence svt_chi_link_dn_seq_h<%=idx%>;
    static uvm_event done_svt_chi_link_dn_seq_h<%=idx%> = ev_pool.get("done_svt_chi_link_dn_seq_h<%=idx%>");
    static uvm_event done_svt_chi_rn_seq_h<%=idx%> = ev_pool.get("done_svt_chi_rn_seq_h<%=idx%>");
    <% if(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-B' || obj.AiuInfo[pidx].fnNativeInterface == 'CHI-E') { %>
    chiaiu0_chi_aiu_vseq_pkg::cust_svt_chi_protocol_service_coherency_entry_sequence coherency_entry_seq<%=idx%>;
    <% } %>
   <% idx++; } else {%>
    <%if((obj.AiuInfo[pidx].fnNativeInterface == 'ACE-LITE' || obj.AiuInfo[pidx].fnNativeInterface == 'ACELITE-E' || obj.AiuInfo[pidx].fnNativeInterface == 'ACE') || (obj.AiuInfo[pidx].fnNativeInterface == 'AXI4' && obj.AiuInfo[pidx].useCache)) { %>
    snp_cust_seq snp_cust_seq_h<%=qidx%>;
    static uvm_event done_snp_cust_seq_h<%=qidx%> = ev_pool.get("done_snp_cust_seq_h<%=qidx%>");
    <% } %>
   <% qidx++; } } %>
    `endif //`ifdef USE_VIP_SNPS
   
<% if(obj.useResiliency == 1) { %>
   uvm_reg_bit_bash_seq reg_bit_bash_seq;
   uvm_reg_hw_reset_seq reg_hw_reset_seq;
   uvm_event mission_fault_detected;
<% } %>

`ifndef USE_VIP_SNPS //existing flow will not run when USE_VIP_SNPS set
    //ACE Model
    <% var qidx=0; var idx=0; for(var pidx = 0 ; pidx < obj.nAIUs; pidx++) { %>
      <% if((obj.AiuInfo[pidx].fnNativeInterface == 'CHI-A') || (obj.AiuInfo[pidx].fnNativeInterface == 'CHI-B' || obj.AiuInfo[pidx].fnNativeInterface == 'CHI-E')) { %>
           `ifndef USE_VIP_SNPS //existing flow will not run when USE_VIP_SNPS set
           chiaiu<%=idx%>_chi_aiu_vseq_pkg::chi_aiu_vseq#(<%=obj.AiuInfo[pidx].FUnitId%>)       m_chi<%=idx%>_vseq;
           `endif //`ifndef USE_VIP_SNPS
           chi_aiu_unit_args_pkg::chi_aiu_unit_args                       m_chi<%=idx%>_args;
	   static uvm_event ev_chi<%=idx%>_seq_done = ev_pool.get("m_chi<%=idx%>_seq");
	   <%  idx++;   %>
       <% } else { %>
           ioaiu<%=qidx%>_inhouse_axi_bfm_pkg::axi_master_pipelined_seq          m_iocache_seq<%=qidx%>[<%=aiu_NumCores[pidx]%>];
           ioaiu<%=qidx%>_inhouse_axi_bfm_pkg::axi_master_snoop_seq              m_iosnoop_seq<%=qidx%>[<%=aiu_NumCores[pidx]%>];
           <% for(var coreidx=0; coreidx < aiu_NumCores[pidx]; coreidx++) { %>
	   static uvm_event ev_ioaiu<%=qidx%>_<%=coreidx%>_seq_done = ev_pool.get("m_ioaiu<%=qidx%>_<%=coreidx%>_seq");
      <% } %> // foreach core
	<%  qidx++;   } %>
    <% } %>
`else // `ifndef USE_VIP_SNPS
     <%  var idx=0; for(var pidx = 0 ; pidx < obj.nAIUs; pidx++) { %>
      <% if((obj.AiuInfo[pidx].fnNativeInterface == 'CHI-A') || (obj.AiuInfo[pidx].fnNativeInterface == 'CHI-B' || obj.AiuInfo[pidx].fnNativeInterface == 'CHI-E')) { %>
             //chiaiu<%=idx%>_chi_aiu_vseq_pkg::snps_chi_aiu_vseq                                      m_snps_chi<%=idx%>_vseq;
             chiaiu<%=idx%>_chi_aiu_vseq_pkg::snps_chi_aiu_vseq#(<%=obj.AiuInfo[pidx].FUnitId%>)   m_snps_chi<%=idx%>_vseq;
             //chiaiu<%=idx%>_chi_aiu_vseq_pkg::snps_chi_aiu_vseq#(<%=obj.AiuInfo[pidx].FUnitId%>)   m_snps_chi<%=idx%>_read_vseq;  //read
             chi_aiu_unit_args_pkg::chi_aiu_unit_args                       m_chi<%=idx%>_args;
             //chi_aiu_unit_args_pkg::chi_aiu_unit_args                       m_chi<%=idx%>_read_args;  // read
	     //static uvm_event ev_chi<%=idx%>_seq_done = ev_pool.get("m_chi<%=idx%>_seq");
	     //static uvm_event ev_chi<%=idx%>_read_seq_done = ev_pool.get("m_chi<%=idx%>_read_seq");
             <% idx++; %>
       <%  } %>
       <% } %>


 `endif // `ifndef USE_VIP_SNPS ... `else

    <% for(var pidx = 0 ; pidx < obj.nDMIs; pidx++) { %>
        dmi<%=pidx%>_inhouse_axi_bfm_pkg::axi_slave_read_seq   m_axi_slv_rd_seq_dmi<%=pidx%>;
        dmi<%=pidx%>_inhouse_axi_bfm_pkg::axi_slave_write_seq  m_axi_slv_wr_seq_dmi<%=pidx%>;
        dmi<%=pidx%>_inhouse_axi_bfm_pkg::axi_memory_model     m_axi_slv_memory_model_dmi<%=pidx%>;
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
    int use_user_addrq;
   
   int 	      chiaiu_en[int];
   int 	      ioaiu_en[int];
   string     chiaiu_en_str[];
   string     ioaiu_en_str[];
   string     chiaiu_en_arg;
   string     ioaiu_en_arg;

    //////////////////
    //UVM Registery
    //////////////////    
    `uvm_component_utils(concerto_fullsys_wrrd_test)

    //////////////////
    //Methods
    //////////////////
    extern function new(string name = "concerto_fullsys_wrrd_test", uvm_component parent = null);
    extern virtual function void build_phase(uvm_phase  phase);
    //extern virtual function void connect_pahse(uvm_phase phase);
    extern virtual function void end_of_elaboration_phase(uvm_phase phase);
    extern virtual task run_phase(uvm_phase phase);
    extern virtual task exec_inhouse_seq(uvm_phase phase);
    extern virtual task exec_inhouse_boot_seq(uvm_phase phase);
    <% 
    var qidx = 0;
    var cidx = 0;
    for(var idx = 0; idx < obj.nAIUs; idx++) { 
       if((obj.AiuInfo[idx].fnNativeInterface == 'CHI-A')||(obj.AiuInfo[idx].fnNativeInterface == 'CHI-B' || obj.AiuInfo[idx].fnNativeInterface == 'CHI-E')) { %>
    extern virtual task chiaiu_write_seq<%=cidx%>(int num_trans);
    extern virtual task chiaiu_read_seq<%=cidx%>(int num_trans);
    extern virtual task chiaiu_clean_seq<%=cidx%>(int num_trans);
    <% cidx++; %>
    <% } else { %>
    extern virtual task ioaiu_write_seq<%=qidx%>(int num_trans);
    extern virtual task ioaiu_read_seq<%=qidx%>(int num_trans);
    <% qidx++; } %>
    <% } %>

    extern virtual function void start_of_simulation_phase(uvm_phase phase);
    extern virtual function void report_phase(uvm_phase phase);


endclass: concerto_fullsys_wrrd_test

//////////////////
//Calling Method: Child Class
//Description: Constructor
//Arguments:   UVM Default
//Return type: N/A
//////////////////
function concerto_fullsys_wrrd_test::new(string name = "concerto_fullsys_wrrd_test", uvm_component parent = null);
    super.new(name, parent);
endfunction: new

//////////////////
//Calling Method: UVM Factory
//Description: Build phase
//Arguments:   UVM Default
//Return type: Void
//////////////////
function void concerto_fullsys_wrrd_test::build_phase(uvm_phase phase);
    string msg_idx;
    int 	   transorder_mode;
   

    `uvm_info("Build", "Entered Build Phase", UVM_LOW);
    super.build_phase(phase);

    if (!$value$plusargs("chi_num_trans=%d",chi_num_trans)) begin
        chi_num_trans = 0;
    end
    if (!$value$plusargs("ioaiu_num_trans=%d",ioaiu_num_trans)) begin
        ioaiu_num_trans = 0;
    end

   `ifdef USE_VIP_SNPS
    if($test$plusargs("vip_snps_non_coherent_txn")) begin
      vip_snps_non_coherent_txn = 1;
    end
    else if($test$plusargs("vip_snps_coherent_txn")) begin
      vip_snps_coherent_txn = 1;
    end

    void'($value$plusargs("vip_snps_seq_length=%0d",vip_snps_seq_length));

    //SVT CREATE
  <% var qidx=0;var idx=0; %>
  <% for(pidx = 0; pidx < obj.nAIUs; pidx++) { %>
    <%if((obj.AiuInfo[pidx].fnNativeInterface == 'CHI-A')||(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-B' || obj.AiuInfo[pidx].fnNativeInterface == 'CHI-E')) { %>
     `uvm_info(get_name(), "USE_VIP_SNPS svt_chi_link_service_sequence::CREATE[<%=idx%>]", UVM_NONE)
      svt_chi_link_up_seq_h<%=idx%> = svt_chi_link_service_activate_sequence::type_id::create("svt_chi_link_up_seq_h<%=idx%>");
      svt_chi_link_dn_seq_h<%=idx%> = svt_chi_link_service_deactivate_sequence::type_id::create("svt_chi_link_dn_seq_h<%=idx%>");
     `uvm_info(get_name(), "USE_VIP_SNPS svt_chi_rn_transaction_random_sequence::CREATE[<%=idx%>]", UVM_NONE)
      svt_chi_rn_seq_h<%=idx%> = svt_chi_rn_transaction_random_sequence::type_id::create("svt_chi_rn_seq_h<%=idx%>");
      <% if(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-B' || obj.AiuInfo[pidx].fnNativeInterface == 'CHI-E') { %>
        coherency_entry_seq<%=idx%> = chiaiu0_chi_aiu_vseq_pkg::cust_svt_chi_protocol_service_coherency_entry_sequence::type_id::create("coherency_entry_seq<%=idx%>");
      <% } %>
    <% idx++; %>
    <%} else {%>
     <%if((obj.AiuInfo[pidx].fnNativeInterface == 'ACE-LITE' || obj.AiuInfo[pidx].fnNativeInterface == 'ACELITE-E' || obj.AiuInfo[pidx].fnNativeInterface == 'ACE') || (obj.AiuInfo[pidx].fnNativeInterface == 'AXI4' && obj.AiuInfo[pidx].useCache)) { %>
     snp_cust_seq_h<%=qidx%> = snp_cust_seq::type_id::create("snp_cust_seq_h<%=qidx%>"); 
     <% } %>
  <% qidx++; } } %>
    //SVT OVERRIDE
    if(vip_snps_non_coherent_txn) begin
      set_type_override_by_type(svt_chi_rn_transaction::get_type(),rn_noncoherent_transaction::get_type());
    end
    else if(vip_snps_coherent_txn) begin
      set_type_override_by_type(svt_chi_rn_transaction::get_type(),rn_coherent_transaction::get_type());
    end    
    else begin
      set_type_override_by_type(svt_chi_rn_transaction::get_type(),svt_chi_item::get_type());
`ifdef CHI_UNITS_CNT_NON_ZERO
      set_type_override_by_type(svt_chi_rn_snoop_response_sequence::get_type(),chiaiu0_chi_aiu_vseq_pkg::cust_svt_chi_rn_directed_snoop_response_sequence::get_type());
`endif // CHI_UNITS_CNT_NON_ZERO
      `uvm_info(get_name(),$psprintf("Overrode svt_chi_rn_transaction by svt_chi_item"),UVM_DEBUG)
    end

  
    /** Apply the null sequence to the AMBA ENV virtual sequencer to override the default sequence. */
    uvm_config_db#(uvm_object_wrapper)::set(this, "m_concerto_env.snps.svt.amba_system_env.sequencer.main_phase", "default_sequence", null ); 
   <% var chiaiu_idx=0; ioaiu_idx=0;
    for(var pidx = 0 ; pidx < obj.nAIUs; pidx++) { %>
    <% if((obj.AiuInfo[pidx].fnNativeInterface == 'CHI-A')||(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-B' || obj.AiuInfo[pidx].fnNativeInterface == 'CHI-E')) { %>
    
    //uvm_config_db#(uvm_object_wrapper)::set(this, "m_concerto_env.snps.svt.amba_system_env.chi_system[0].rn[<%=chiaiu_idx%>].rn_xact_seqr.main_phase", "default_sequence", svt_chi_rn_transaction_random_sequence::type_id::get());
    //uvm_config_db#(int unsigned)::set(this, "m_concerto_env.snps.svt.amba_system_env.chi_system[0].rn[<%=chiaiu_idx%>].rn_xact_seqr.svt_chi_rn_transaction_random_sequence", "sequence_length", vip_snps_seq_length);
    uvm_config_db#(int unsigned)::set(this, "m_concerto_env.snps.svt.amba_system_env.chi_system[0].rn[<%=chiaiu_idx%>].rn_xact_seqr.svt_chi_rn_transaction_random_sequence", "sequence_length", chi_num_trans);
    //uvm_config_db#(int unsigned)::set(this, "m_concerto_env.snps.svt.amba_system_env.chi_system[0].rn[<%=chiaiu_idx%>].rn_xact_seqr.svt_chi_rn_transaction_random_sequence", "sequence_length", 0);
    uvm_config_db#(bit)::set(this, "m_concerto_env.snps.svt.amba_system_env.chi_system[0].rn[<%=chiaiu_idx%>].rn_xact_seqr.svt_chi_rn_transaction_random_sequence", "enable_non_blocking", 1);

    <% 
      chiaiu_idx++;
    } } %>
   `endif //`ifdef USE_VIP_SNPS

    //InHouse ACE model construction
    //Inhouse ACE master agent must be ACTIVE
    //Create plusargs objects for aiu
   <% 
      var chiaiu_idx = 0;
      var ioaiu_idx = 0;
   %>
<% for(var pidx = 0 ; pidx < obj.nAIUs; pidx++) { %>
    <% if(!((obj.AiuInfo[pidx].fnNativeInterface == 'CHI-A') || (obj.AiuInfo[pidx].fnNativeInterface == 'CHI-B' || obj.AiuInfo[pidx].fnNativeInterface == 'CHI-E'))) { %>
    <% for(var coreidx=0; coreidx < aiu_NumCores[pidx]; coreidx++) { %>
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
    if($test$plusargs("perf_test")) begin
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

<% for(var pidx = 0 ; pidx < obj.nDMIs; pidx++) { %>
    m_axi_slv_memory_model_dmi<%=pidx%> = dmi<%=pidx%>_inhouse_axi_bfm_pkg::axi_memory_model::type_id::create("m_axi_slv_memory_model");
  

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
function void concerto_fullsys_wrrd_test::end_of_elaboration_phase(uvm_phase phase);
    int file_handle;
    `uvm_info("end_of_elaboration_phase", "Entered...", UVM_LOW)
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
task concerto_fullsys_wrrd_test::run_phase(uvm_phase phase);
   super.run_phase(phase);
   `uvm_info("TEST_MAIN", "Starting concerto_fullsys_wrrd_test::exec_inhouse_seq ...", UVM_LOW)
    exec_inhouse_seq(phase);
   `uvm_info("TEST_MAIN", "Finish concerto_fullsys_wrrd_test ...", UVM_LOW)
endtask: run_phase




//////////////////
//Return type: Void
//////////////////



task concerto_fullsys_wrrd_test::exec_inhouse_seq(uvm_phase phase);
   `ifdef USE_VIP_SNPS
  <% if(numChiAiu > 0) { %>
    svt_chi_item m_svt_chi_item;
  <% } %>
   `endif  
    bit timeout;
    if (!$value$plusargs("chi_num_trans=%d",chi_num_trans)) begin
        chi_num_trans = 0;
    end
    if (!$value$plusargs("ioaiu_num_trans=%d",ioaiu_num_trans)) begin
        ioaiu_num_trans = 0;
    end

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
    <% if((obj.AiuInfo[pidx].fnNativeInterface != 'CHI-A')&&(obj.AiuInfo[pidx].fnNativeInterface != 'CHI-B')&&(obj.AiuInfo[pidx].fnNativeInterface != 'CHI-E')) { %>
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
    m_axi_slv_rd_seq_dii<%=pidx%>.m_memory_model         = m_axi_slv_memory_model_dii<%=pidx%>;
    m_axi_slv_rd_seq_dii<%=pidx%>.prob_ace_rd_resp_error = m_args.dii<%=pidx%>_prob_ace_slave_rd_resp_error;
    m_axi_slv_wr_seq_dii<%=pidx%>.m_write_addr_chnl_seqr = m_concerto_env.inhouse.m_dii<%=pidx%>_env.m_axi_slave_agent.m_write_addr_chnl_seqr;
    m_axi_slv_wr_seq_dii<%=pidx%>.m_write_data_chnl_seqr = m_concerto_env.inhouse.m_dii<%=pidx%>_env.m_axi_slave_agent.m_write_data_chnl_seqr;
    m_axi_slv_wr_seq_dii<%=pidx%>.m_write_resp_chnl_seqr = m_concerto_env.inhouse.m_dii<%=pidx%>_env.m_axi_slave_agent.m_write_resp_chnl_seqr;
    m_axi_slv_wr_seq_dii<%=pidx%>.m_memory_model         = m_axi_slv_memory_model_dii<%=pidx%>;
    m_axi_slv_wr_seq_dii<%=pidx%>.prob_ace_wr_resp_error = m_args.dii<%=pidx%>_prob_ace_slave_wr_resp_error;
    <% } %>
  <% } %>

 `ifndef USE_VIP_SNPS //existing flow will not run when USE_VIP_SNPS set
  <% var qidx=0;var idx=0; for(var pidx = 0; pidx < obj.nAIUs; pidx++) { %>
    <% if((obj.AiuInfo[pidx].fnNativeInterface == 'CHI-A')||(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-B' || obj.AiuInfo[pidx].fnNativeInterface == 'CHI-E')) { %>
 `ifndef USE_VIP_SNPS //existing flow will not run when USE_VIP_SNPS set
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

    `endif //`ifndef USE_VIP_SNPS
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
    <% } %> //foreach core
    <% qidx++; } %>
  <% } %>
  `else  // `ifndef USE_VIP_SNPS
   // //snps knob setting 
   // m_chi0_args = chi_aiu_unit_args_pkg::chi_aiu_unit_args::type_id::create("chi_aiu_unit_args0");
   // m_chi0_args.k_num_requests.set_value(chi_num_trans);
   // m_chi0_args.k_coh_addr_pct.set_value(50);
   // m_chi0_args.k_noncoh_addr_pct.set_value(50);
   // m_chi0_args.k_device_type_mem_pct.set_value(50);
   // m_chi0_args.k_rq_lcrdrt_pct.set_value(0);
   // m_chi0_args.k_rd_noncoh_pct.set_value(5);
   // m_chi0_args.k_rd_ldrstr_pct.set_value(5);
   // m_chi0_args.k_wr_noncoh_pct.set_value(5);
   // m_chi0_args.k_new_addr_pct.set_value(50);
   <% if(numChiAiu > 0) { %>
    m_svt_chi_item = svt_chi_item::type_id::create("m_svt_chi_item");
   <% } %>

    <% var idx=0; for(var pidx = 0; pidx < obj.nAIUs; pidx++) { %>
    <% if((obj.AiuInfo[pidx].fnNativeInterface == 'CHI-A')||(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-B' || obj.AiuInfo[pidx].fnNativeInterface == 'CHI-E')) { %>
        //m_snps_chi<%=idx%>_vseq = chiaiu<%=idx%>_chi_aiu_vseq_pkg::snps_chi_aiu_vseq::type_id::create("m_chi<%=idx%>_seq");
        m_snps_chi<%=idx%>_vseq = chiaiu<%=idx%>_chi_aiu_vseq_pkg::snps_chi_aiu_vseq#(<%=obj.AiuInfo[pidx].FUnitId%>)::type_id::create("m_chi<%=idx%>_seq");
        //m_snps_chi<%=idx%>_read_vseq = chiaiu<%=idx%>_chi_aiu_vseq_pkg::snps_chi_aiu_vseq#(<%=obj.AiuInfo[pidx].FUnitId%>)::type_id::create("m_chi<%=idx%>_read_seq"); // read

        m_snps_chi<%=idx%>_vseq.set_seq_name("m_chi<%=idx%>_seq");
        m_snps_chi<%=idx%>_vseq.set_done_event_name("done_svt_chi_rn_seq_h<%=idx%>");
        //m_snps_chi<%=idx%>_read_vseq.set_seq_name("m_chi<%=idx%>_read_seq"); // read

        m_snps_chi<%=idx%>_vseq.rn_xact_seqr    =  m_concerto_env.snps.svt.amba_system_env.chi_system[0].rn[<%=idx%>].rn_xact_seqr;  
        m_snps_chi<%=idx%>_vseq.shared_status =  m_concerto_env.snps.svt.amba_system_env.chi_system[0].rn[<%=idx%>].shared_status;
        m_snps_chi<%=idx%>_vseq.chi_num_trans =  chi_num_trans;  
        m_snps_chi<%=idx%>_vseq.m_regs = m_concerto_env.m_regs;
        //m_snps_chi<%=idx%>_vseq.set_unit_args(m_chi0_args);

        //read
        //m_snps_chi<%=idx%>_read_vseq.rn_xact_seqr    =  m_concerto_env.snps.svt.amba_system_env.chi_system[0].rn[<%=idx%>].rn_xact_seqr; 

        <% idx++;  %>
    <%} %>
    <%} %>
 `endif // `ifndef USE_VIP_SNPS ... `else

`ifndef USE_VIP_SNPS //existing flow will not run when USE_VIP_SNPS set
  <% var qidx=0;var idx=0; for(var pidx = 0; pidx < obj.nAIUs; pidx++) { %>
    <% if((obj.AiuInfo[pidx].fnNativeInterface == 'CHI-A')||(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-B' || obj.AiuInfo[pidx].fnNativeInterface == 'CHI-E')) { %>
 `ifndef USE_VIP_SNPS //existing flow will not run when USE_VIP_SNPS set
    m_chi<%=idx%>_args = chi_aiu_unit_args_pkg::chi_aiu_unit_args::type_id::create($psprintf("chi_aiu_unit_args[%0d]", 0));
    m_chi<%=idx%>_args.k_num_requests.set_value(chi_num_trans);
    m_chi<%=idx%>_args.k_coh_addr_pct.set_value(50);
    m_chi<%=idx%>_args.k_noncoh_addr_pct.set_value(50);
    m_chi<%=idx%>_args.k_device_type_mem_pct.set_value(50);
    m_chi<%=idx%>_args.k_rq_lcrdrt_pct.set_value(0);
    m_chi<%=idx%>_args.k_rd_noncoh_pct.set_value(5);
    m_chi<%=idx%>_args.k_rd_ldrstr_pct.set_value(5);
    m_chi<%=idx%>_args.k_wr_noncoh_pct.set_value(5);
    m_chi<%=idx%>_args.k_new_addr_pct.set_value(50);
    m_chi<%=idx%>_vseq.set_unit_args(m_chi<%=idx%>_args);
    `endif //`ifndef USE_VIP_SNPS
    <% idx++;  } %>
    <% } %>

`else //Will activate the flow of USE_VIP_SNPS
<%  var idx=0; for(var pidx = 0; pidx < obj.nAIUs; pidx++) { %>
    <% if((obj.AiuInfo[pidx].fnNativeInterface == 'CHI-A')||(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-B' || obj.AiuInfo[pidx].fnNativeInterface == 'CHI-E')) { %>
     m_chi0_args = chi_aiu_unit_args_pkg::chi_aiu_unit_args::type_id::create("chi_aiu_unit_args<%=idx%>");
     m_chi0_args.k_num_requests.set_value(chi_num_trans);
     m_chi0_args.k_coh_addr_pct.set_value(50);
     m_chi0_args.k_noncoh_addr_pct.set_value(50);
     //if(addrMgrConst::NUM_DIIS>1) begin
       m_chi0_args.k_device_type_mem_pct.set_value(50);
    //end else begin
    //   m_chi0_args.k_device_type_mem_pct.set_value(0);
    //end
     m_chi0_args.k_rq_lcrdrt_pct.set_value(0);
     m_chi0_args.k_rd_noncoh_pct.set_value(5);
     m_chi0_args.k_rd_ldrstr_pct.set_value(5);
     m_chi0_args.k_wr_noncoh_pct.set_value(5);
     m_chi0_args.k_new_addr_pct.set_value(50);
     m_svt_chi_item.m_args = m_chi0_args;
     m_snps_chi<%=idx%>_vseq.set_unit_args(m_chi0_args);

    //// read
    // m_chi0_read_args = chi_aiu_unit_args_pkg::chi_aiu_unit_args::type_id::create($psprintf("chi_aiu_unit_read_args[%0d]", 0));
    // m_chi0_read_args.k_num_requests.set_value(chi_num_trans);
    // m_chi0_read_args.k_coh_addr_pct.set_value(50);
    // m_chi0_read_args.k_noncoh_addr_pct.set_value(50);
    ////if(addrMgrConst::NUM_DIIS>1) begin
    //    m_chi0_read_args.k_device_type_mem_pct.set_value(50);
    ////end else begin
    ////   m_chi0_read_args.k_device_type_mem_pct.set_value(0);
    ////end
    // m_chi0_read_args.k_rq_lcrdrt_pct.set_value(0);
    // m_chi0_read_args.k_rd_noncoh_pct.set_value(5);
    // m_chi0_read_args.k_rd_ldrstr_pct.set_value(5);
    // m_chi0_read_args.k_wr_noncoh_pct.set_value(5);
    // m_chi0_read_args.k_new_addr_pct.set_value(50);
    // m_snps_chi<%=idx%>_read_vseq.set_unit_args(m_chi0_read_args);
   
     <% idx++; } %>
     <% } %>

`endif //`ifndef USE_VIP_SNPS

    phase.raise_objection(this, "wrrd_test");
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
      `ifdef USE_VIP_SNPS //SVT LINK
        `uvm_info(get_name(), "USE_VIP_SNPS svt_chi_link_UP_service_sequence::START[<%=idx%>]", UVM_LOW)
         svt_chi_link_up_seq_h<%=idx%>.start(m_concerto_env.snps.svt.amba_system_env.chi_system[0].rn[<%=idx%>].link_svc_seqr) ;
        `uvm_info(get_name(), "USE_VIP_SNPS svt_chi_link_UP_service_sequence::END[<%=idx%>]", UVM_LOW)
      `else //`ifdef USE_VIP_SNPS
        m_chi<%=idx%>_vseq.construct_lnk_seq();
        m_chi<%=idx%>_vseq.construct_txs_seq();
      `endif //`ifdef USE_VIP_SNPS ... `else
    end
    <% idx++; %>
    <%} %>
  <% } %>
    join


    `ifdef USE_VIP_SNPS
    fork
  <% var idx = 0; %>
  <% for(pidx = 0; pidx < obj.nAIUs; pidx++) { %>
    <%if(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-B' || obj.AiuInfo[pidx].fnNativeInterface == 'CHI-E') { %>
    begin
        `uvm_info(get_name(), "USE_VIP_SNPS coherency_entry_seq::START[<%=idx%>]", UVM_NONE)
        coherency_entry_seq<%=idx%>.delay_in_ns=50000;
        coherency_entry_seq<%=idx%>.randomize();
        fork
        begin
        coherency_entry_seq<%=idx%>.start(m_concerto_env.snps.svt.amba_system_env.chi_system[0].rn[<%=idx%>].prot_svc_seqr);
        `uvm_info(get_name(), "USE_VIP_SNPS coherency_entry_seq::END[<%=idx%>]", UVM_NONE)
        end
        join_none
        //#(coherency_entry_seq<%=idx%>.delay_in_ns*1ns);
        csr_init_done.wait_trigger();
        `uvm_info("TEST MAIN", "Done - waiting for csr_init_done trigger", UVM_NONE)
        tb_top.release_sysco_req = 1;
    end
    <% idx++; %>
    <%} %>
  <% } %>
    join_none
    `endif //`ifdef USE_VIP_SNPS
   
   // Boot Sequence
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
   `ifndef USE_VIP_SNPS //existing flow will not run when USE_VIP_SNPS set
   if($value$plusargs("use_user_addrq=%d", use_user_addrq)) begin
       <% var chi_idx=0;
       var io_idx=0;
       for(var pidx=0; pidx<obj.nAIUs; pidx++) {
       if((obj.AiuInfo[pidx].fnNativeInterface == "CHI-A") || (obj.AiuInfo[pidx].fnNativeInterface == "CHI-B") || obj.AiuInfo[pidx].fnNativeInterface == "CHI-E") { %>
       `ifndef USE_VIP_SNPS //existing flow will not run when USE_VIP_SNPS set
       addr_mgr.gen_user_noncoh_addr(<%=obj.AiuInfo[0].FUnitId%>, use_user_addrq, m_chi<%=chi_idx%>_vseq.m_chi_container.user_addrq[addrMgrConst::NONCOH]);
       if($test$plusargs("use_seq_user_addrq") || $test$plusargs("perf_test")) begin
          addr_mgr.gen_seq_addr_in_user_addrq(use_user_addrq, 64, 0, -1, m_chi<%=chi_idx%>_vseq.m_chi_container.user_addrq[addrMgrConst::COH]);
       end else begin
          addr_mgr.gen_user_coh_addr(<%=obj.AiuInfo[0].FUnitId%>, use_user_addrq, m_chi<%=chi_idx%>_vseq.m_chi_container.user_addrq[addrMgrConst::COH]);
       end	  
       `endif //`ifndef USE_VIP_SNPS
       <% chi_idx++;
       } 
       else {
          if((obj.AiuInfo[pidx].fnNativeInterface == "ACE")) { %>
          <% for(var coreidx=0; coreidx < aiu_NumCores[pidx]; coreidx++) { %>
       addr_mgr.gen_user_noncoh_addr(<%=obj.AiuInfo[0].FUnitId%>, use_user_addrq, m_concerto_env.inhouse.m_ace_cache_model_ioaiu<%=io_idx%>[<%=coreidx%>].user_addrq[addrMgrConst::NONCOH]);
       if($test$plusargs("use_seq_user_addrq") || $test$plusargs("perf_test")) begin
          addr_mgr.gen_seq_addr_in_user_addrq(use_user_addrq, 64, 0, -1, m_concerto_env.inhouse.m_ace_cache_model_ioaiu<%=io_idx%>[<%=coreidx%>].user_addrq[addrMgrConst::COH]);
       end else begin
          addr_mgr.gen_user_coh_addr(<%=obj.AiuInfo[0].FUnitId%>, use_user_addrq, m_concerto_env.inhouse.m_ace_cache_model_ioaiu<%=io_idx%>[<%=coreidx%>].user_addrq[addrMgrConst::COH]);
       end
       <% } %>// foreach core
	  <% }
          io_idx++;
         } 
       } %>

       <% var chi_idx=0;
       var io_idx=0;
       for(var pidx=0; pidx<obj.nAIUs; pidx++) {
       if((obj.AiuInfo[pidx].fnNativeInterface !== "CHI-A") && (obj.AiuInfo[pidx].fnNativeInterface !== "CHI-B")&& (obj.AiuInfo[pidx].fnNativeInterface !== "CHI-E")) { %>
          <% if(numChiAiu > 0) { %>
       `ifndef USE_VIP_SNPS //existing flow will not run when USE_VIP_SNPS set
       <% for(var coreidx=0; coreidx < aiu_NumCores[pidx]; coreidx++) { %>
       m_concerto_env.inhouse.m_ace_cache_model_ioaiu<%=io_idx%>[<%=coreidx%>].user_addrq[addrMgrConst::NONCOH] = m_chi0_vseq.m_chi_container.user_addrq[addrMgrConst::NONCOH];
       m_concerto_env.inhouse.m_ace_cache_model_ioaiu<%=io_idx%>[<%=coreidx%>].user_addrq[addrMgrConst::COH] = m_chi0_vseq.m_chi_container.user_addrq[addrMgrConst::COH];
       <% } %> // foreach core 

       `endif //`ifndef USE_VIP_SNPS
          <% } 
          else {
          if(obj.AiuInfo[pidx].fnNativeInterface !== "ACE") { %>
          <% for(var coreidx=0; coreidx < aiu_NumCores[pidx]; coreidx++) { %>
       m_concerto_env.inhouse.m_ace_cache_model_ioaiu<%=io_idx%>[<%=coreidx%>].user_addrq[addrMgrConst::NONCOH] = m_concerto_env.inhouse.m_ace_cache_model_ioaiu<%=aceIdx[0]%>[<%=coreidx%>].user_addrq[addrMgrConst::NONCOH];
       m_concerto_env.inhouse.m_ace_cache_model_ioaiu<%=io_idx%>[<%=coreidx%>].user_addrq[addrMgrConst::COH] = m_concerto_env.inhouse.m_ace_cache_model_ioaiu<%=aceIdx[0]%>[<%=coreidx%>].user_addrq[addrMgrConst::COH];
          <% } %> // foreach core
          <% } 
       }  io_idx++; }
       } %>
   end
   `endif //`ifndef USE_VIP_SNPS

`ifndef USE_VIP_SNPS //existing flow will not run when USE_VIP_SNPS set
            // set randomize args after boot seq
  <% var qidx=0;var idx=0; for(var pidx = 0; pidx < obj.nAIUs; pidx++) { %>
    <% if((obj.AiuInfo[pidx].fnNativeInterface == 'CHI-A')||(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-B' || obj.AiuInfo[pidx].fnNativeInterface == 'CHI-E')) { %>
            m_chi<%=idx%>_args.k_device_type_mem_pct.set_value(0);
            m_chi<%=idx%>_args.k_rd_noncoh_pct.set_value(0);
            m_chi<%=idx%>_args.k_rd_rdonce_pct.set_value(0);
            m_chi<%=idx%>_args.k_rd_ldrstr_pct.set_value(0);
            m_chi<%=idx%>_args.k_wr_cohunq_pct.set_value(0);
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
               m_chi<%=idx%>_args.k_rd_noncoh_pct.set_value(50);
               m_chi<%=idx%>_args.k_wr_noncoh_pct.set_value(50);
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
               m_chi<%=idx%>_args.k_rd_ldrstr_pct.set_value(50);
               m_chi<%=idx%>_args.k_wr_cohunq_pct.set_value(50);
               if ($test$plusargs("read_test")) begin
                  m_chi<%=idx%>_args.k_wr_cohunq_pct.set_value(0);
               end
               if ($test$plusargs("write_test")) begin
                  m_chi<%=idx%>_args.k_rd_ldrstr_pct.set_value(0);
	       end // else: !if($test$plusargs("write_test"))
	    end
													
            m_chi<%=idx%>_args.k_snprspdata_in_uc_pct.set_value(100);
            m_chi<%=idx%>_args.k_snprspdata_in_sc_pct.set_value(100);
            m_chi<%=idx%>_args.m_uc_to_ix_st_ch_pct.set_value(0);
            m_chi<%=idx%>_args.m_uc_to_sc_st_ch_pct.set_value(0);
            m_chi<%=idx%>_vseq.set_unit_args(m_chi<%=idx%>_args);
      <% idx++;  %>
    <%} else { %>
      <% for(var coreidx=0; coreidx < aiu_NumCores[pidx]; coreidx++) { %>
            m_iocache_seq<%=qidx%>[<%=coreidx%>].k_num_read_req      = 0;
            m_iocache_seq<%=qidx%>[<%=coreidx%>].k_num_write_req     = 0;
            m_iocache_seq<%=qidx%>[<%=coreidx%>].k_num_read_req      = ioaiu_num_trans/2;
            m_iocache_seq<%=qidx%>[<%=coreidx%>].k_num_write_req     = ioaiu_num_trans/2;
            if ($test$plusargs("read_test")) begin
                m_iocache_seq<%=qidx%>[<%=coreidx%>].k_num_read_req      = ioaiu_num_trans;
                m_iocache_seq<%=qidx%>[<%=coreidx%>].k_num_write_req      = 0;
            end
            if ($test$plusargs("write_test")) begin
                m_iocache_seq<%=qidx%>[<%=coreidx%>].k_num_write_req     = ioaiu_num_trans;
                m_iocache_seq<%=qidx%>[<%=coreidx%>].k_num_read_req      = 0;
            end
      <% if((obj.AiuInfo[pidx].fnNativeInterface == 'ACE') || (obj.AiuInfo[pidx].fnNativeInterface == 'ACE-LITE') || (obj.AiuInfo[pidx].fnNativeInterface == 'ACELITE-E')) { %>
            m_iocache_seq<%=qidx%>[<%=coreidx%>].wt_ace_rdnosnp      = 0;
            m_iocache_seq<%=qidx%>[<%=coreidx%>].wt_ace_rdonce       = 0;
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
            end
  
    <% qidx++; } %>
  <% } %>
   <% } %> // foreach core 
<% } %>

`else //will activate the flow of USE_VIP_SNPS
       <%  var idx=0; for(var pidx = 0; pidx < obj.nAIUs; pidx++) { %>
        <% if((obj.AiuInfo[pidx].fnNativeInterface == 'CHI-A')||(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-B' || obj.AiuInfo[pidx].fnNativeInterface == 'CHI-E')) { %>
            m_chi0_args.k_coh_addr_pct.set_value(50);
            m_chi0_args.k_noncoh_addr_pct.set_value(50);
            if(addrMgrConst::NUM_DIIS>1) begin
               m_chi0_args.k_device_type_mem_pct.set_value(50);
            end else begin
               m_chi0_args.k_device_type_mem_pct.set_value(0);
	    end

            if ($test$plusargs("read_test")) begin
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
                if($test$plusargs("noncoherent_test")) begin
                   m_chi0_args.k_coh_addr_pct.set_value(0);
                   m_chi0_args.k_noncoh_addr_pct.set_value(100);
                   m_chi0_args.k_rd_noncoh_pct.set_value(100);
                   m_chi0_args.k_rd_ldrstr_pct.set_value(0);
                   m_chi0_args.k_rd_rdonce_pct.set_value(0);
                end
                else if($test$plusargs("coherent_test")) begin
                   m_chi0_args.k_coh_addr_pct.set_value(100);
                   m_chi0_args.k_noncoh_addr_pct.set_value(0);
                   m_chi0_args.k_rd_noncoh_pct.set_value(0);
                   m_chi0_args.k_rd_ldrstr_pct.set_value(5);
                   m_chi0_args.k_rd_rdonce_pct.set_value(0);
                end
                else begin
                   m_chi0_args.k_rd_noncoh_pct.set_value(35);
                   m_chi0_args.k_rd_ldrstr_pct.set_value(35);
                   m_chi0_args.k_rd_rdonce_pct.set_value(30);
                end
            end
            else if ($test$plusargs("write_test")) begin
                m_chi0_args.k_rd_noncoh_pct.set_value(0);
                m_chi0_args.k_rd_ldrstr_pct.set_value(0);
                m_chi0_args.k_rd_rdonce_pct.set_value(0);
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
                if($test$plusargs("noncoherent_test")) begin
                   m_chi0_args.k_coh_addr_pct.set_value(0);
                   m_chi0_args.k_noncoh_addr_pct.set_value(100);
                   m_chi0_args.k_wr_noncoh_pct.set_value(5);
                   m_chi0_args.k_wr_cohunq_pct.set_value(0);
                end
                else if($test$plusargs("coherent_test")) begin
                   m_chi0_args.k_coh_addr_pct.set_value(100);
                   m_chi0_args.k_noncoh_addr_pct.set_value(0);
                   m_chi0_args.k_wr_noncoh_pct.set_value(0);
                   m_chi0_args.k_wr_cohunq_pct.set_value(100);
                end
                else begin
                   m_chi0_args.k_wr_noncoh_pct.set_value(100);
                   m_chi0_args.k_wr_cohunq_pct.set_value(100);
                end
            end
            else begin
                if($test$plusargs("noncoherent_test")) begin
                    m_chi0_args.k_rd_noncoh_pct.set_value(100);
                    m_chi0_args.k_rd_ldrstr_pct.set_value(0);
                    m_chi0_args.k_rd_rdonce_pct.set_value(0);
                    m_chi0_args.k_wr_noncoh_pct.set_value(100);
                    m_chi0_args.k_wr_cohunq_pct.set_value(0);
                end
                else if($test$plusargs("coherent_test")) begin
                    m_chi0_args.k_rd_noncoh_pct.set_value(0);
                    m_chi0_args.k_rd_ldrstr_pct.set_value(100);
                    m_chi0_args.k_rd_rdonce_pct.set_value(100);
                    m_chi0_args.k_wr_noncoh_pct.set_value(0);
                    m_chi0_args.k_wr_cohunq_pct.set_value(100);
                end
                else begin
                    if(($test$plusargs("dce_fix_index"))||($test$plusargs("dmi_fix_index"))||($test$plusargs("en_excl_txn")))begin
                       m_chi0_args.k_rd_ldrstr_pct.set_value(100);
                       m_chi0_args.k_rd_rdonce_pct.set_value(0);
                    end else begin
                       m_chi0_args.k_rd_ldrstr_pct.set_value(100);
                       m_chi0_args.k_rd_rdonce_pct.set_value(100);
                    end
                    if($test$plusargs("en_excl_txn"))begin
                      m_chi0_args.k_rd_noncoh_pct.set_value(0);
                      m_chi0_args.k_wr_noncoh_pct.set_value(0);
                      m_chi0_args.k_wr_cohunq_pct.set_value(0);
                    end else begin
                      m_chi0_args.k_rd_noncoh_pct.set_value(100);
                      m_chi0_args.k_wr_noncoh_pct.set_value(100);
                      m_chi0_args.k_wr_cohunq_pct.set_value(100);
                    end

                        if ($test$plusargs("en_excl_noncoh_txn")) begin
                              m_chi0_args.k_excl_txn_pct.set_value(100);
                              m_chi0_args.k_coh_addr_pct.set_value(0);
                              m_chi0_args.k_noncoh_addr_pct.set_value(100);
                              m_chi0_args.k_device_type_mem_pct.set_value(0);
                              m_chi0_args.k_rd_noncoh_pct.set_value(50);
                              m_chi0_args.k_wr_noncoh_pct.set_value(50);
                              m_chi0_args.k_rd_ldrstr_pct.set_value(0);
                              m_chi0_args.k_rd_rdonce_pct.set_value(0);
                              m_chi0_args.k_wr_cohunq_pct.set_value(0);
                              m_chi0_args.k_dt_ls_upd_pct.set_value(0);
                        end else begin
                            m_chi0_args.k_rd_noncoh_pct.set_value(100);
                            m_chi0_args.k_wr_noncoh_pct.set_value(100);
                            m_chi0_args.k_wr_cohunq_pct.set_value(100);
                        end

                end
	    end // else: !if($test$plusargs("write_test"))

                if ($test$plusargs("use_copyback")) begin
                    m_chi0_args.k_wr_cpybck_pct.set_value(20);
                end else begin
                    m_chi0_args.k_wr_cpybck_pct.set_value(0);
                end

                if ($test$plusargs("use_nondata")) begin
                    m_chi0_args.k_dt_ls_upd_pct.set_value(50);
                    m_chi0_args.k_dt_ls_cmo_pct.set_value(50);
                    m_chi0_args.k_pre_fetch_pct.set_value(20);
                end else begin
                    if($test$plusargs("en_excl_txn"))begin
                      m_chi0_args.k_dt_ls_upd_pct.set_value(50);
                    end else begin
                      m_chi0_args.k_dt_ls_upd_pct.set_value(0);
                    end
                    m_chi0_args.k_dt_ls_cmo_pct.set_value(0);
                    m_chi0_args.k_pre_fetch_pct.set_value(0);
                end
                if ($test$plusargs("use_stash")) begin
                    m_chi0_args.k_dt_ls_sth_pct.set_value(50);
                    m_chi0_args.k_wr_sthunq_pct.set_value(0);  // CHI-AIU does not support WriteStash
                end else begin
                    m_chi0_args.k_dt_ls_sth_pct.set_value(0);
                    m_chi0_args.k_wr_sthunq_pct.set_value(0);
                end
                if ($test$plusargs("use_atomic")) begin
                    m_chi0_args.k_atomic_st_pct.set_value(25);
                    m_chi0_args.k_atomic_ld_pct.set_value(25);
                    m_chi0_args.k_atomic_sw_pct.set_value(25);
                    m_chi0_args.k_atomic_cm_pct.set_value(25);
                end else begin
                    m_chi0_args.k_atomic_st_pct.set_value(0);
                    m_chi0_args.k_atomic_ld_pct.set_value(0);
                    m_chi0_args.k_atomic_sw_pct.set_value(0);
                    m_chi0_args.k_atomic_cm_pct.set_value(0);
                end // else: !if($test$plusargs("use_atomic"))
                if ($test$plusargs("use_dvm") && !($test$plusargs("use_ace_dvmsync"))) begin
                    m_chi0_args.k_dvm_opert_pct.set_value(25);
                end else begin
                    m_chi0_args.k_dvm_opert_pct.set_value(0);
                end
                if (!$test$plusargs("en_excl_txn")) begin
                   m_chi0_args.k_excl_txn_pct.set_value(100);
                end

	    if($test$plusargs("perf_test")||$test$plusargs("no_delay")) begin
               m_chi0_args.k_txreq_hld_dly.set_value(1);
               m_chi0_args.k_txreq_dly_min.set_value(0);
               m_chi0_args.k_txreq_dly_max.set_value(0);
               m_chi0_args.k_txrsp_hld_dly.set_value(1);
               m_chi0_args.k_txrsp_dly_min.set_value(0);
               m_chi0_args.k_txrsp_dly_max.set_value(0);
               m_chi0_args.k_txdat_hld_dly.set_value(1);
               m_chi0_args.k_txdat_dly_min.set_value(0);
               m_chi0_args.k_txdat_dly_max.set_value(0);
               m_chi0_args.k_alloc_hint_pct.set_value(90);
               m_chi0_args.k_cacheable_pct.set_value(90);
	       m_chi0_args.k_on_fly_req.set_value(32);
	    end
            m_snps_chi<%=idx%>_vseq.set_unit_args(m_chi0_args);
    <% idx++;  } %>
    <% } %>
  `endif //`ifndef USE_VIP_SNPS

   if($test$plusargs("readshare_scenario")) begin
   fork 
      begin
         fork
<% if(nChiAgents > 0) { %>
            begin
            `uvm_info("TEST_MAIN", "Start CHIAIU0 Seq", UVM_NONE)
            phase.raise_objection(this, "CHIAIU0 sequence");
	    if($test$plusargs("read_test")) begin
                chiaiu_read_seq0(chi_num_trans);
	    end else begin
                chiaiu_write_seq0(chi_num_trans);
	    end
            `uvm_info("TEST_MAIN", "Done CHIAIU0 Seq", UVM_NONE)
            #5us;
            phase.drop_objection(this, "CHIAIU0 sequence");
            end
<% } %>

<% if(nChiAgents > 1) { %>
            begin
            `uvm_info("TEST_MAIN", "Start CHIAIU1 Seq", UVM_NONE)
            phase.raise_objection(this, "CHIAIU1 sequence");
	    if($test$plusargs("read_test")) begin
                chiaiu_read_seq1(chi_num_trans);
	    end else begin
                chiaiu_write_seq1(chi_num_trans);
	    end
            `uvm_info("TEST_MAIN", "Done CHIAIU1 Seq", UVM_NONE)
            #5us;
            phase.drop_objection(this, "CHIAIU1 sequence");
            end
<% } %>
            `ifndef USE_VIP_SNPS //existing flow will not run when USE_VIP_SNPS set
            begin
	        fork
<% if(nChiAgents > 0) { %>
                   ev_chi0_seq_done.wait_trigger();
<% } %>
<% if(nChiAgents > 1) { %>
                   ev_chi1_seq_done.wait_trigger();
<% } %>
                join
                ev_sim_done.trigger(null);
	    end
        `endif //`ifndef USE_VIP_SNPS
	 join
      end
      begin
         #(sim_timeout_ms*1ms);
         timeout = 1;
      end
   join_any	  
   
   if (timeout)begin
       `uvm_fatal(get_name(), "Test Part 1 Timeout")
       #50us;
   end   

   <% if(numIoAiu > 0) { %>
   // read from different aiu
   `ifndef USE_VIP_SNPS //existing flow will not run when USE_VIP_SNPS set
   fork 
      begin
         fork
            begin
            <% for(var coreidx=0; coreidx < aiu_NumCores[pidx]; coreidx++) { %>
            `uvm_info("TEST_MAIN", "Start IOAIU0[<%=coreidx%>] Seq", UVM_NONE)
            phase.raise_objection(this, "IOAIU0[<%=coreidx%>] RD sequence");
            m_iocache_seq0[<%=coreidx%>].start(null);
            `uvm_info("TEST_MAIN", "Done IOAIU0[<%=coreidx%>] Read Seq", UVM_NONE)
            #5us;
            phase.drop_objection(this, "IOAIU0[<%=coreidx%>] RD sequence");
            
            <% } %> // foreach core
            end
            begin
               <% for(var coreidx=0; coreidx < aiu_NumCores[pidx]; coreidx++) { %>
                ev_ioaiu0_[<%=coreidx%>]_seq_done.wait_trigger();
               <% } %> // foreach core 
                ev_sim_done.trigger(null);
	    end
	 join
      end
      begin
         #(sim_timeout_ms*1ms);
         timeout = 1;
      end
   join_any	  
   `endif //`ifndef USE_VIP_SNPS
   <% } %>
   end else begin
   // read from 1 aiu
   fork 
      begin
         fork
<% if(nChiAgents > 0) { %>
            begin
            `uvm_info("TEST_MAIN", "Start CHIAIU0 Seq", UVM_NONE)
            phase.raise_objection(this, "CHIAIU0 sequence");
	    if($test$plusargs("read_test")) begin
                chiaiu_read_seq0(chi_num_trans);
	    end else begin
                chiaiu_write_seq0(chi_num_trans);
	    end
            `uvm_info("TEST_MAIN", "Done CHIAIU0 Seq", UVM_NONE)
            #5us;
            phase.drop_objection(this, "CHIAIU0 sequence");
            end
`ifndef USE_VIP_SNPS //existing flow will not run when USE_VIP_SNPS set
            begin
                ev_chi0_seq_done.wait_trigger();
                ev_sim_done.trigger(null);
	    end
`endif //`ifndef USE_VIP_SNPS
<% } %>
	 join
      end
      begin
         #(sim_timeout_ms*1ms);
         timeout = 1;
      end
   join_any	  
   
   if (timeout)begin
       `uvm_fatal(get_name(), "Test Part 1 Timeout")
       #50us;
   end   

   fork
      fork
  <% 
  var chiaiu_idx = 0;
  var ioaiu_idx = 0;
  for(var pidx = 0; pidx < obj.nAIUs; pidx++) { %>
    <% if((obj.AiuInfo[pidx].fnNativeInterface == 'CHI-A')||(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-B' || obj.AiuInfo[pidx].fnNativeInterface == 'CHI-E')) { %>
       <% if(chiaiu_idx > 0) { %>
		    begin
		     `ifdef USE_VIP_SNPS
                        if(vip_snps_coherent_txn || vip_snps_non_coherent_txn) begin
                         //SVT TRAFFIC
		        if(chiaiu_en.exists(<%=chiaiu_idx%>)) begin												
                            phase.raise_objection(this, "USE_VIP_SNPS CHIAIU<%=chiaiu_idx%> sequence");
                           `uvm_info(get_name(), "USE_VIP_SNPS svt_chi_rn_transaction_random_sequence::START[<%=chiaiu_idx%>]", UVM_LOW)
                            svt_chi_rn_seq_h<%=chiaiu_idx%>.start(m_concerto_env.snps.svt.amba_system_env.chi_system[0].rn[<%=chiaiu_idx%>].rn_xact_seqr) ;
                            //#1us;
                            done_svt_chi_rn_seq_h<%=chiaiu_idx%>.trigger(null);
                           `uvm_info("TEST_MAIN", "USE_VIP_SNPS svt_chi_rn_transaction_random_sequence::DONE[<%=chiaiu_idx%>]", UVM_NONE)
                            phase.drop_objection(this, "USE_VIP_SNPS CHIAIU<%=chiaiu_idx%> sequence");
                           end
                        end
                        else begin
                           m_svt_chi_item.print();
                          `uvm_info(get_name(), "Start m_snps_chi<%=chiaiu_idx%>_vseq", UVM_NONE)
                           //snps_vseq.start(null);
                           m_snps_chi<%=chiaiu_idx%>_vseq.start(null);
                           //done_svt_chi_rn_seq_h<%=chiaiu_idx%>.trigger(null);
                          `uvm_info(get_name(), "Done m_snps_chi<%=chiaiu_idx%>_vseq", UVM_NONE)
                        end
                      `else //`ifdef USE_VIP_SNPS
                         if(chiaiu_en.exists(<%=chiaiu_idx%>)) begin
                       `uvm_info("TEST_MAIN", "Start CHIAIU<%=chiaiu_idx%> VSEQ", UVM_NONE)
                        phase.raise_objection(this, "CHIAIU<%=chiaiu_idx%> sequence");
                        if((<%=chiaiu_idx%> == 0) && $test$plusargs("dvm_hang_test")) begin
			    #5ns;
                        end
                        m_chi<%=chiaiu_idx%>_vseq.start(null);
                        `uvm_info("TEST_MAIN", "Done CHIAIU<%=chiaiu_idx%> VSEQ", UVM_NONE)
                        #5us;
                        phase.drop_objection(this, "CHIAIU<%=chiaiu_idx%> sequence");
			end
            `endif //`ifdef USE_VIP_SNPS ... `else
		    end // if (chiaiu_idx > 0)
	<% } %>		       
      <% chiaiu_idx++; %>
    <% } else { %>
                    begin
		     `ifdef USE_VIP_SNPS
                       //SVT TRAFFIC
		        if(ioaiu_en.exists(<%=ioaiu_idx%>)) begin
                        phase.raise_objection(this, "USE_VIP_SNPS IOAIU<%=ioaiu_idx%> sequence");
                       `uvm_info("TEST_MAIN", "USE_VIP_SNPS START snp_cust_seq_h<%=ioaiu_idx%>", UVM_NONE)
                        <%if((obj.AiuInfo[pidx].fnNativeInterface == 'ACE-LITE' || obj.AiuInfo[pidx].fnNativeInterface == 'ACELITE-E' || obj.AiuInfo[pidx].fnNativeInterface == 'ACE') || (obj.AiuInfo[pidx].fnNativeInterface == 'AXI4' && obj.AiuInfo[pidx].useCache)) { %> 
                        //snp_cust_seq_h<%=ioaiu_idx%>.start(m_concerto_env.snps.svt.amba_system_env.axi_system[0].master[<%=ioaiu_idx%>].sequencer);
                        #1us;
                        done_snp_cust_seq_h<%=ioaiu_idx%>.trigger(null);
                        <% } %>
                       `uvm_info("TEST_MAIN", "USE_VIP_SNPS DONE snp_cust_seq_h<%=ioaiu_idx%>", UVM_NONE)
                        phase.drop_objection(this, "USE_VIP_SNPS IOAIU<%=ioaiu_idx%> sequence");
                        end
                     `else //`ifdef USE_VIP_SNPS
               <% for(var coreidx=0; coreidx < aiu_NumCores[pidx]; coreidx++) { %>
		        if(ioaiu_en.exists(<%=ioaiu_idx%>)) begin
                        phase.raise_objection(this, "IOAIU<%=ioaiu_idx%>[<%=coreidx%>] sequence");
                        `uvm_info("TEST_MAIN", "Start IOAIU<%=ioaiu_idx%>[<%=coreidx%>] VSEQ", UVM_NONE)
                    <% if((obj.AiuInfo[pidx].fnNativeInterface == 'ACE') || (aiu_axiInt[pidx].params.eAc==1) ){ %>
                        fork
		                  m_iocache_seq<%=ioaiu_idx%>[<%=coreidx%>].start(null);
		                  m_iosnoop_seq<%=ioaiu_idx%>[<%=coreidx%>].start(null);
			               join_any
                    <% } else { %>
                        m_iocache_seq<%=ioaiu_idx%>[<%=coreidx%>].start(null);
                    <% } %>
                        `uvm_info("TEST_MAIN", "Done IOAIU<%=ioaiu_idx%>[<%=coreidx%>] VSEQ", UVM_NONE)
                        #5us;
                        phase.drop_objection(this, "IOAIU<%=ioaiu_idx%>[<%=coreidx%>] sequence");
                        end
                     <% } %> // foreach core
                     `endif //`ifdef USE_VIP_SNPS ... `else
                    end
    <% ioaiu_idx++; } %>
  <% } %>
                    begin
                        fork
  <%chiaiu_idx = 0;
  ioaiu_idx = 0;
  for(var pidx = 0; pidx < obj.nAIUs; pidx++) {
    if((obj.AiuInfo[pidx].fnNativeInterface == 'CHI-A')||(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-B' || obj.AiuInfo[pidx].fnNativeInterface == 'CHI-E')) { %>
       <% if(chiaiu_idx > 0) { %>
		        if(chiaiu_en.exists(<%=chiaiu_idx%>)) begin			
                        `ifdef USE_VIP_SNPS
                          `uvm_info(get_name(), "USE_VIP_SNPS Waiting on TRAFFIC done_svt_chi_rn_seq_h<%=chiaiu_idx%> to Finish", UVM_LOW) 
                          done_svt_chi_rn_seq_h<%=chiaiu_idx%>.wait_trigger();
                      
                          #25us; //trial to wait for all <##>_RSP
                         `uvm_info(get_name(), "USE_VIP_SNPS svt_chi_link_service_DN_sequence::START[<%=chiaiu_idx%>]", UVM_LOW)
                          svt_chi_link_dn_seq_h<%=chiaiu_idx%>.start(m_concerto_env.snps.svt.amba_system_env.chi_system[0].rn[<%=chiaiu_idx%>].link_svc_seqr) ;
                          //done_svt_chi_link_dn_seq_h<%=chiaiu_idx%>.trigger(null);
                         `uvm_info(get_name(), "USE_VIP_SNPS svt_chi_link_service_DN_sequence::END[<%=chiaiu_idx%>]", UVM_LOW)


                          //`uvm_info(get_name(), "USE_VIP_SNPS Waiting on LINK done_svt_chi_link_dn_seq_h<%=chiaiu_idx%> to Finish", UVM_LOW) 
                          //done_svt_chi_link_dn_seq_h<%=chiaiu_idx%>.wait_trigger();
                         `else //`ifdef USE_VIP_SNPS
                          ev_chi<%=chiaiu_idx%>_seq_done.wait_trigger();
                        `endif //`ifdef USE_VIP_SNPS ... `else 
			end
       <% } %>
      <% chiaiu_idx++;
    } else { %>
                        `ifdef USE_VIP_SNPS
                        if(ioaiu_en.exists(<%=ioaiu_idx%>)) begin
    <%if((obj.AiuInfo[pidx].fnNativeInterface == 'ACE-LITE' || obj.AiuInfo[pidx].fnNativeInterface == 'ACELITE-E' || obj.AiuInfo[pidx].fnNativeInterface == 'ACE') || (obj.AiuInfo[pidx].fnNativeInterface == 'AXI4' && obj.AiuInfo[pidx].useCache)) { %>
                            done_snp_cust_seq_h<%=ioaiu_idx%>.wait_trigger();
    <% } %>
                        end
                        `else //`ifdef USE_VIP_SNPS
                        <% for(var coreidx=0; coreidx < aiu_NumCores[pidx]; coreidx++) { %>
                        if(ioaiu_en.exists(<%=ioaiu_idx%>)) begin
                            ev_ioaiu<%=ioaiu_idx%>_<%=coreidx%>_seq_done.wait_trigger();
                        end
                        <% } %> // foreach core
                        `endif //`ifdef USE_VIP_SNPS ... `else
                        
    <% ioaiu_idx++; }
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
   end // else: !if($test$plusargs("readshare_scenario"))
			
   if (timeout)begin
       `uvm_fatal(get_name(), "Test Part 2 Timeout")
       #50us;
   end   

   phase.drop_objection(this, "wrrd_test");
endtask: exec_inhouse_seq

task concerto_fullsys_wrrd_test::exec_inhouse_boot_seq(uvm_phase phase);
// Randomize and set configuration in DMI scoreboard
    bit [31:0] agent_id,way_vec,way_full_chk;
    bit [31:0] agent_ids_assigned_q[addr_trans_mgr_pkg::addrMgrConst::NUM_DMIS][$];
    bit [31:0] wayvec_assigned_q[addr_trans_mgr_pkg::addrMgrConst::NUM_DMIS][$];
    int shared_ways_per_user;
    int way_for_atomic=0;

    int sp_ways[] = new[addr_trans_mgr_pkg::addrMgrConst::NUM_DMIS];
    int sp_size[] = new[addr_trans_mgr_pkg::addrMgrConst::NUM_DMIS];
    bit [<%=obj.wSysAddr-1%>:0] k_sp_base_addr[] = new[addr_trans_mgr_pkg::addrMgrConst::NUM_DMIS];
    int idxq[$];

    addr_trans_mgr_pkg::addrMgrConst::sys_addr_csr_t csrq[$];
    csrq = addr_trans_mgr_pkg::addrMgrConst::get_all_gpra();

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
if((obj.AiuInfo[pidx].fnNativeInterface != 'CHI-A') && (obj.AiuInfo[pidx].fnNativeInterface != 'CHI-B')&& (obj.AiuInfo[pidx].fnNativeInterface != 'CHI-E')) { 
if((((obj.AiuInfo[pidx].fnNativeInterface === "ACELITE-E") || (obj.AiuInfo[pidx].fnNativeInterface === "ACE-LITE")) && (obj.AiuInfo[pidx].cmpInfo.nDvmSnpInFlight > 0)) || (obj.AiuInfo[pidx].fnNativeInterface == "ACE") || ((obj.AiuInfo[pidx].fnNativeInterface == "AXI4") && (obj.AiuInfo[pidx].useCache))) { %>
    m_concerto_env.inhouse.m_ioaiu<%=ioidx%>_env.m_env[0].m_scb.m_sysco_fsm_state = ioaiu<%=ioidx%>_env_pkg::CONNECT;  
    ev_sysco_fsm_state_change_<%=obj.AiuInfo[pidx].FUnitId%>.trigger();   
<% } ioidx++;
} } %>
end // if (m_args.ioaiu_scb_en)
   
//==================================================
    <% if(numChiAiu > 0) { %>
`ifndef USE_VIP_SNPS //existing flow will not run when USE_VIP_SNPS set
    m_chi0_vseq.m_regs = m_concerto_env.m_regs;
    m_chi0_vseq.enum_boot_seq(agent_ids_assigned_q,wayvec_assigned_q, k_sp_base_addr, sp_ways, sp_size, aiu_qos_threshold, dce_qos_threshold, dmi_qos_threshold);                        
`else //  `ifndef USE_VIP_SNPS  
    m_snps_chi0_vseq.m_regs = m_concerto_env.m_regs;
    m_snps_chi0_vseq.enum_boot_seq(agent_ids_assigned_q,wayvec_assigned_q, k_sp_base_addr, sp_ways, sp_size, aiu_qos_threshold, dce_qos_threshold, dmi_qos_threshold);                        
`endif //`ifndef USE_VIP_SNPS ... else
    <% } else { %>
    randcase
<% for(var idx = 0, qidx=0; idx < obj.nAIUs; idx++) { 
    if((obj.AiuInfo[idx].fnNativeInterface != 'CHI-A')&&(obj.AiuInfo[idx].fnNativeInterface != 'CHI-B')&&(obj.AiuInfo[idx].fnNativeInterface != 'CHI-E')) { %>
            1: begin 
               `uvm_info("TEST_MAIN", "Start IOAIU<%=qidx%> boot_seq", UVM_NONE)
               // NEW FSYS TEST: NEEED update CONFIGURE_PAHSE //ioaiu_boot_seq<%=qidx%>(agent_ids_assigned_q,wayvec_assigned_q, k_sp_base_addr, sp_ways, sp_size, aiu_qos_threshold, dce_qos_threshold, dmi_qos_threshold,dmi_qos_rsved); 
               
               end
     <% qidx++;
       } %>
<% } %>
    endcase
    <% } %>
    #5us; // Need to wait for pending transactions to complete e.g. DTRRsp
`ifdef USE_VIP_SNPS
    tb_top.release_sysco_req = 1;
`endif //`ifndef USE_VIP_SNPS
endtask: exec_inhouse_boot_seq

<% 
var qidx = 0;
var cidx = 0;
for(var idx = 0; idx < obj.nAIUs; idx++) { 
if(obj.AiuInfo[idx].fnNativeInterface == 'CHI-A' || obj.AiuInfo[idx].fnNativeInterface == 'CHI-B' || obj.AiuInfo[idx].fnNativeInterface == 'CHI-E') { %>

task concerto_fullsys_wrrd_test::chiaiu_write_seq<%=cidx%>(int num_trans);
   m_chi<%=cidx%>_args.k_num_requests.set_value(num_trans);
   m_chi<%=cidx%>_args.k_coh_addr_pct.set_value(100);
   m_chi<%=cidx%>_args.k_noncoh_addr_pct.set_value(0);
   m_chi<%=cidx%>_args.k_rd_noncoh_pct.set_value(0);
   m_chi<%=cidx%>_args.k_rd_ldrstr_pct.set_value(0);
   m_chi<%=cidx%>_args.k_rd_rdonce_pct.set_value(0);
   m_chi<%=cidx%>_args.k_wr_noncoh_pct.set_value(0);
   m_chi<%=cidx%>_args.k_wr_cohunq_pct.set_value(5);
   m_chi<%=cidx%>_args.k_wr_cpybck_pct.set_value(0);
   m_chi<%=cidx%>_args.k_dt_ls_upd_pct.set_value(5);
   m_chi<%=cidx%>_args.k_dt_ls_cmo_pct.set_value(0);
   m_chi<%=cidx%>_args.k_pre_fetch_pct.set_value(0);
   m_chi<%=cidx%>_args.k_dt_ls_sth_pct.set_value(0);
   m_chi<%=cidx%>_args.k_wr_sthunq_pct.set_value(0);
   m_chi<%=cidx%>_args.k_atomic_st_pct.set_value(0);
   m_chi<%=cidx%>_args.k_atomic_ld_pct.set_value(0);
   m_chi<%=cidx%>_args.k_atomic_sw_pct.set_value(0);
   m_chi<%=cidx%>_args.k_atomic_cm_pct.set_value(0);
   m_chi<%=cidx%>_args.k_dvm_opert_pct.set_value(0);
   if($test$plusargs("perf_test")) begin
      m_chi<%=cidx%>_args.k_txreq_hld_dly.set_value(1);
      m_chi<%=cidx%>_args.k_txreq_dly_min.set_value(0);
      m_chi<%=cidx%>_args.k_txreq_dly_max.set_value(0);
      m_chi<%=cidx%>_args.k_txrsp_hld_dly.set_value(1);
      m_chi<%=cidx%>_args.k_txrsp_dly_min.set_value(0);
      m_chi<%=cidx%>_args.k_txrsp_dly_max.set_value(0);
      m_chi<%=cidx%>_args.k_txdat_hld_dly.set_value(1);
      m_chi<%=cidx%>_args.k_txdat_dly_min.set_value(0);
      m_chi<%=cidx%>_args.k_txdat_dly_max.set_value(0);
      m_chi<%=cidx%>_args.k_alloc_hint_pct.set_value(90);
      m_chi<%=cidx%>_args.k_cacheable_pct.set_value(90);
      m_chi<%=cidx%>_args.k_on_fly_req.set_value(32);
   end
   m_chi<%=cidx%>_args.k_snprspdata_in_uc_pct.set_value(100);
   m_chi<%=cidx%>_args.k_snprspdata_in_sc_pct.set_value(100);
   m_chi<%=cidx%>_args.m_uc_to_ix_st_ch_pct.set_value(0);
   m_chi<%=cidx%>_args.m_uc_to_sc_st_ch_pct.set_value(0);
 `ifndef USE_VIP_SNPS //existing flow will not run when USE_VIP_SNPS set
   m_chi<%=cidx%>_vseq.set_unit_args(m_chi<%=cidx%>_args);
   m_chi<%=cidx%>_vseq.start(null);
 `else
   m_snps_chi<%=cidx%>_vseq.set_unit_args(m_chi<%=cidx%>_args);
   m_snps_chi<%=cidx%>_vseq.start(null);
 `endif //`ifndef USE_VIP_SNPS
endtask
													 
task concerto_fullsys_wrrd_test::chiaiu_read_seq<%=cidx%>(int num_trans);
   m_chi<%=cidx%>_args.k_num_requests.set_value(num_trans);
   m_chi<%=cidx%>_args.k_coh_addr_pct.set_value(100);
   m_chi<%=cidx%>_args.k_noncoh_addr_pct.set_value(0);
   m_chi<%=cidx%>_args.k_rd_noncoh_pct.set_value(0);
   if($test$plusargs("use_rdunq") || $test$plusargs("perf_test")) begin
      m_chi<%=cidx%>_args.k_rd_ldrstr_pct.set_value(5);
      m_chi<%=cidx%>_args.k_rd_rdonce_pct.set_value(0);
   end else begin
      m_chi<%=cidx%>_args.k_rd_ldrstr_pct.set_value(0);
      m_chi<%=cidx%>_args.k_rd_rdonce_pct.set_value(5);
   end   
   m_chi<%=cidx%>_args.k_wr_noncoh_pct.set_value(0);
   m_chi<%=cidx%>_args.k_wr_cohunq_pct.set_value(0);
   m_chi<%=cidx%>_args.k_wr_cpybck_pct.set_value(0);
   m_chi<%=cidx%>_args.k_dt_ls_upd_pct.set_value(5);
   m_chi<%=cidx%>_args.k_dt_ls_cmo_pct.set_value(0);
   m_chi<%=cidx%>_args.k_pre_fetch_pct.set_value(0);
   m_chi<%=cidx%>_args.k_dt_ls_sth_pct.set_value(0);
   m_chi<%=cidx%>_args.k_wr_sthunq_pct.set_value(0);
   m_chi<%=cidx%>_args.k_atomic_st_pct.set_value(0);
   m_chi<%=cidx%>_args.k_atomic_ld_pct.set_value(0);
   m_chi<%=cidx%>_args.k_atomic_sw_pct.set_value(0);
   m_chi<%=cidx%>_args.k_atomic_cm_pct.set_value(0);
   m_chi<%=cidx%>_args.k_dvm_opert_pct.set_value(0);
   if($test$plusargs("perf_test")) begin
      m_chi<%=cidx%>_args.k_txreq_hld_dly.set_value(1);
      m_chi<%=cidx%>_args.k_txreq_dly_min.set_value(0);
      m_chi<%=cidx%>_args.k_txreq_dly_max.set_value(0);
      m_chi<%=cidx%>_args.k_txrsp_hld_dly.set_value(1);
      m_chi<%=cidx%>_args.k_txrsp_dly_min.set_value(0);
      m_chi<%=cidx%>_args.k_txrsp_dly_max.set_value(0);
      m_chi<%=cidx%>_args.k_txdat_hld_dly.set_value(1);
      m_chi<%=cidx%>_args.k_txdat_dly_min.set_value(0);
      m_chi<%=cidx%>_args.k_txdat_dly_max.set_value(0);
      m_chi<%=cidx%>_args.k_alloc_hint_pct.set_value(90);
      m_chi<%=cidx%>_args.k_cacheable_pct.set_value(90);
      m_chi<%=cidx%>_args.k_on_fly_req.set_value(32);
   end
   m_chi<%=cidx%>_args.k_snprspdata_in_uc_pct.set_value(100);
   m_chi<%=cidx%>_args.k_snprspdata_in_sc_pct.set_value(100);
   m_chi<%=cidx%>_args.m_uc_to_ix_st_ch_pct.set_value(0);
   m_chi<%=cidx%>_args.m_uc_to_sc_st_ch_pct.set_value(0);
 `ifndef USE_VIP_SNPS //existing flow will not run when USE_VIP_SNPS set
   m_chi<%=cidx%>_vseq.set_unit_args(m_chi<%=cidx%>_args);
   m_chi<%=cidx%>_vseq.start(null);
 `else
   m_snps_chi<%=cidx%>_vseq.set_unit_args(m_chi<%=cidx%>_args);
   m_snps_chi<%=cidx%>_vseq.start(null);
 `endif //`ifndef USE_VIP_SNPS
endtask

task concerto_fullsys_wrrd_test::chiaiu_clean_seq<%=cidx%>(int num_trans);
   m_chi<%=cidx%>_args.k_num_requests.set_value(num_trans);
   m_chi<%=cidx%>_args.k_coh_addr_pct.set_value(100);
   m_chi<%=cidx%>_args.k_noncoh_addr_pct.set_value(0);
   m_chi<%=cidx%>_args.k_rd_noncoh_pct.set_value(0);
   m_chi<%=cidx%>_args.k_rd_ldrstr_pct.set_value(0);
   m_chi<%=cidx%>_args.k_rd_rdonce_pct.set_value(0);
   m_chi<%=cidx%>_args.k_wr_noncoh_pct.set_value(0);
   m_chi<%=cidx%>_args.k_wr_cohunq_pct.set_value(0);
   m_chi<%=cidx%>_args.k_wr_cpybck_pct.set_value(0);
   m_chi<%=cidx%>_args.k_dt_ls_upd_pct.set_value(5);
   m_chi<%=cidx%>_args.k_dt_ls_cmo_pct.set_value(0);
   m_chi<%=cidx%>_args.k_pre_fetch_pct.set_value(0);
   m_chi<%=cidx%>_args.k_dt_ls_sth_pct.set_value(0);
   m_chi<%=cidx%>_args.k_wr_sthunq_pct.set_value(0);
   m_chi<%=cidx%>_args.k_atomic_st_pct.set_value(0);
   m_chi<%=cidx%>_args.k_atomic_ld_pct.set_value(0);
   m_chi<%=cidx%>_args.k_atomic_sw_pct.set_value(0);
   m_chi<%=cidx%>_args.k_atomic_cm_pct.set_value(0);
   m_chi<%=cidx%>_args.k_dvm_opert_pct.set_value(0);
   if($test$plusargs("perf_test")) begin
      m_chi<%=cidx%>_args.k_txreq_hld_dly.set_value(1);
      m_chi<%=cidx%>_args.k_txreq_dly_min.set_value(0);
      m_chi<%=cidx%>_args.k_txreq_dly_max.set_value(0);
      m_chi<%=cidx%>_args.k_txrsp_hld_dly.set_value(1);
      m_chi<%=cidx%>_args.k_txrsp_dly_min.set_value(0);
      m_chi<%=cidx%>_args.k_txrsp_dly_max.set_value(0);
      m_chi<%=cidx%>_args.k_txdat_hld_dly.set_value(1);
      m_chi<%=cidx%>_args.k_txdat_dly_min.set_value(0);
      m_chi<%=cidx%>_args.k_txdat_dly_max.set_value(0);
      m_chi<%=cidx%>_args.k_alloc_hint_pct.set_value(90);
      m_chi<%=cidx%>_args.k_cacheable_pct.set_value(90);
      m_chi<%=cidx%>_args.k_on_fly_req.set_value(32);
   end
 `ifndef USE_VIP_SNPS //existing flow will not run when USE_VIP_SNPS set
   m_chi<%=cidx%>_vseq.set_unit_args(m_chi<%=cidx%>_args);
   m_chi<%=cidx%>_vseq.start(null);
 `else
   m_snps_chi<%=cidx%>_vseq.set_unit_args(m_chi<%=cidx%>_args);
   m_snps_chi<%=cidx%>_vseq.start(null);
 `endif //`ifndef USE_VIP_SNPS
endtask
<% cidx++; %>
<% } else { %>

task concerto_fullsys_wrrd_test::ioaiu_write_seq<%=qidx%>(int num_trans);
`ifndef USE_VIP_SNPS //existing flow will not run when USE_VIP_SNPS set
<% for(var coreidx=0; coreidx < aiu_NumCores[idx]; coreidx++) { %>
   m_iocache_seq<%=qidx%>[<%=coreidx%>].k_num_read_req      = 0;
   m_iocache_seq<%=qidx%>[<%=coreidx%>].k_num_write_req     = num_trans;
   m_iocache_seq<%=qidx%>[<%=coreidx%>].wt_ace_rdnosnp      = 0;
   m_iocache_seq<%=qidx%>[<%=coreidx%>].wt_ace_rdonce       = 0;
   m_iocache_seq<%=qidx%>[<%=coreidx%>].wt_ace_wrnosnp      = 0;
   m_iocache_seq<%=qidx%>[<%=coreidx%>].wt_ace_wrunq        = 5;
   m_iocache_seq<%=qidx%>[<%=coreidx%>].wt_ace_wrlnunq      = 0;
   m_iocache_seq<%=qidx%>[<%=coreidx%>].wt_ace_rdshrd       = 0;
   m_iocache_seq<%=qidx%>[<%=coreidx%>].wt_ace_rdcln        = 0;
   m_iocache_seq<%=qidx%>[<%=coreidx%>].wt_ace_rdnotshrddty = 0;
   m_iocache_seq<%=qidx%>[<%=coreidx%>].wt_ace_rdunq        = 0;
   m_iocache_seq<%=qidx%>[<%=coreidx%>].wt_ace_wrcln        = 0;
   m_iocache_seq<%=qidx%>[<%=coreidx%>].start(null);
    <% } %>// foreach core
`endif //`ifdef USE_VIP_SNPS ... `else
endtask
													 
task concerto_fullsys_wrrd_test::ioaiu_read_seq<%=qidx%>(int num_trans);
`ifndef USE_VIP_SNPS //existing flow will not run when USE_VIP_SNPS set
<% for(var coreidx=0; coreidx < aiu_NumCores[idx]; coreidx++) { %>
   m_iocache_seq<%=qidx%>[<%=coreidx%>].k_num_read_req      = num_trans;
   m_iocache_seq<%=qidx%>[<%=coreidx%>].k_num_write_req     = 0;
   m_iocache_seq<%=qidx%>[<%=coreidx%>].wt_ace_rdnosnp      = 0;
   m_iocache_seq<%=qidx%>[<%=coreidx%>].wt_ace_rdonce       = 5;
   <% if(obj.AiuInfo[idx].fnNativeInterface == 'ACE') { %>
   m_iocache_seq<%=qidx%>[<%=coreidx%>].wt_ace_rdunq        = 5;
   <% } else { %>
   m_iocache_seq<%=qidx%>[<%=coreidx%>].wt_ace_rdunq        = 0;
   <% } %>
   m_iocache_seq<%=qidx%>[<%=coreidx%>].wt_ace_wrnosnp      = 0;
   m_iocache_seq<%=qidx%>[<%=coreidx%>].wt_ace_wrunq        = 0;
   m_iocache_seq<%=qidx%>[<%=coreidx%>].wt_ace_wrlnunq      = 0;
   m_iocache_seq<%=qidx%>[<%=coreidx%>].wt_ace_rdshrd       = 0;
   m_iocache_seq<%=qidx%>[<%=coreidx%>].wt_ace_rdcln        = 0;
   m_iocache_seq<%=qidx%>[<%=coreidx%>].wt_ace_rdnotshrddty = 0;
   m_iocache_seq<%=qidx%>[<%=coreidx%>].wt_ace_wrcln        = 0;
   m_iocache_seq<%=qidx%>[<%=coreidx%>].start(null);
    <% } %>// foreach core
`endif //`ifdef USE_VIP_SNPS ... `else
endtask

<% qidx++; }
} %>
   
//////////////////
//Calling Method: UVM Factory
//Description: start_of_simulation_phase
//Arguments:   UVM Default
//Return type: Void
//////////////////
function void concerto_fullsys_wrrd_test::start_of_simulation_phase(uvm_phase phase);
    super.start_of_simulation_phase(phase);
endfunction : start_of_simulation_phase 


//////////////////
//Calling Method: UVM Factory
//Description: report phase, calls report method to display EOT results
//Arguments:   UVM Default
//Return type: Void
//////////////////
function void concerto_fullsys_wrrd_test::report_phase(uvm_phase phase);
    super.report_phase(phase);
endfunction : report_phase




