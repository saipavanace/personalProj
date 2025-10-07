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
let dmi_width= [];
let initiatorAgents   = obj.AiuInfo.length ;
let aiu_NumCores = [];
let aiu_rpn = [];
const aiuName = [];

   let _blkid = [];
   let _blkportsid =[];
   let _blk   = [{}];
   let _idx = 0;
   let aiu_idx = 0;
   let nAIUs_mpu =0; 
   
   for(var pidx = 0; pidx < obj.nAIUs; pidx++) {
      if(!Array.isArray(obj.AiuInfo[pidx].interfaces.axiInt)) {
       _blk[_idx]   = obj.AiuInfo[pidx];
       _blkid[_idx] = 'aiu' + aiu_idx;
       _blkportsid[_idx] = 0;
       nAIUs_mpu++;
       aiu_idx++;
       _idx++;
       } else {
       for (var port_idx = 0; port_idx < obj.AiuInfo[pidx].nNativeInterfacePorts; port_idx++) {
        _blk[_idx]   = obj.AiuInfo[pidx];
        _blkid[_idx] = 'aiu' + aiu_idx ;
        _blkportsid[_idx] = port_idx;
        _idx++;
        nAIUs_mpu++;
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
for(var pidx = 0; pidx < obj.nDCEs; pidx++) {
    pma_en_dce_blk &= obj.DceInfo[pidx].usePma;
    pma_en_at_least_1_blk |= obj.DceInfo[pidx].usePma;
}
for(var pidx = 0; pidx < obj.nDVEs; pidx++) {
    pma_en_dve_blk &= obj.DveInfo[pidx].usePma;
    pma_en_at_least_1_blk |= obj.DveInfo[pidx].usePma;
}
pma_en_all_blk = pma_en_dmi_blk & pma_en_dii_blk & pma_en_aiu_blk & pma_en_dce_blk & pma_en_dve_blk;

%>

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

     if(bundle.fnNativeInterface === "CHI-A" || bundle.fnNativeInterface === "CHI-B" || bundle.fnNativeInterface === "CHI-E") { // interleaved Aius?
       obj.SnoopFilterInfo.forEach(function(snpinfo, snp_indx, array) {
          if (snpinfo.SnoopFilterAssignment.includes(bundle.FUnitId))
            idSnoopFilterSlice.push(snp_indx);
       });
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

`ifdef USE_VIP_SNPS_CHI // Now using this test for synopsys vip sim 
import chi_subsys_pkg::*;
import  chi_ss_helper_pkg::*;

class chi_subsys_base_test extends concerto_fullsys_test;

    //////////////////
    //Properties
    //////////////////

    static string inst_name="";
    int vip_snps_seq_length = 4;
    chi_subsys_base_vseq base_vseq;
    cust_svt_report_catcher demote_dvmsnoop_check;
    <%for(let idx=0; idx < obj.nCHIs; idx++){%>
        svt_chi_rn_transaction_random_sequence svt_chi_rn_seq_h<%=idx%>;
        svt_chi_link_service_activate_sequence svt_chi_link_up_seq_h<%=idx%>;
        svt_chi_link_service_deactivate_sequence svt_chi_link_dn_seq_h<%=idx%>;
        static uvm_event done_svt_chi_rn_seq_h<%=idx%> = ev_pool.get("done_svt_chi_rn_seq_h<%=idx%>");
        chi_subsys_pkg::chi_subsys_coherency_entry_seq coherency_entry_seq<%=idx%>;
    <%}%>

    // int chi_num_trans;

    <% 
      var ioaiu_idx = 0;
   %>

    uvm_factory factory = uvm_factory::get();

    //////////////////
    //UVM Registery
    //////////////////    
    `uvm_component_utils(chi_subsys_base_test)

    //////////////////
    //Methods
    //////////////////

    function new(string name = "chi_subsys_base_test", uvm_component parent = null);
        super.new(name, parent);
        if(inst_name=="")
        inst_name=name;

    	if (!$value$plusargs("chi_seq_item=%0s",chi_seq_item)) begin
    	    chi_seq_item = "chi_subsys_base_item"; 
    	end

    endfunction: new

    function void build_phase(uvm_phase phase);
        `uvm_info("", "Entered Build Phase", UVM_LOW);
        super.build_phase(phase);
        demote_dvmsnoop_check = new();
        
        uvm_report_cb::add(null, demote_dvmsnoop_check);
        `ifdef CHI_UNITS_CNT_NON_ZERO
	    factory.set_type_override_by_name("svt_chi_rn_transaction", chi_seq_item);
            //set_type_override_by_type(svt_chi_rn_transaction::get_type(),chi_subsys_base_item::get_type());
            //set_type_override_by_type(svt_chi_rn_transaction::get_type(),chi_subsys_base_item::get_type());
            set_type_override_by_type (svt_chi_rn_snoop_transaction::get_type(), chi_subsys_snoop_base_item::get_type());
        `endif // CHI_UNITS_CNT_NON_ZERO
        base_vseq = chi_subsys_base_vseq::type_id::create("base_vseq");
        base_vseq.set_txn_count(chi_num_trans);
        `uvm_info("Build", "Exited Build Phase", UVM_LOW);
    endfunction: build_phase

    function chi_subsys_base_test get_instance();
        chi_subsys_base_test fullsys_test;
        uvm_root top;
        top = uvm_root::get();
        if(top.get_child(inst_name)==null) begin
            $error("chi_subsys_base_test, could not find handle of fullsys_test %0s",inst_name);
        end
        else
            $cast(fullsys_test,top.get_child(inst_name));
        return fullsys_test;

    endfunction:get_instance

    task exec_inhouse_seq(uvm_phase phase);
        
        phase.raise_objection(this, "chi_subsys_base_test");
        csr_init_done.trigger(null);
        #100ns
        k_disable_boot_addr = 1;
        start_sequence();
        phase.drop_objection(this, "chi_subsys_base_test");
    endtask: exec_inhouse_seq

    virtual task start_sequence();
        
    endtask: start_sequence

endclass: chi_subsys_base_test
`endif// Now using this test for synopsys vip sim 
