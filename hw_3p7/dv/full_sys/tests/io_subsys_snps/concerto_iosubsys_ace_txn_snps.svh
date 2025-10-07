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
    if((obj.AiuInfo[pidx].fnNativeInterface == "CHI-A")||(obj.AiuInfo[pidx].fnNativeInterface == "CHI-B" || obj.AiuInfo[pidx].fnNativeInterface == "CHI-E")) 
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
// agent DEBUG
<%for(var pidx = 0; pidx < obj.nAIUs_mpu; pidx++) {   %>
//  idx=<%=pidx%> : <%=_blkid[pidx]%>  port:<%=_blkportsid[pidx]%> 
<% } %>

//File: concerto_iosubsys_ace_txn_snps.svh

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


`ifdef USE_VIP_SNPS // Now using this test for synopsys vip sim 
class concerto_iosubsys_ace_txn_snps extends concerto_iosubsys_test_snps;

    //////////////////
    //UVM Registery
    //////////////////    
    `uvm_component_utils(concerto_iosubsys_ace_txn_snps)

    //////////////////
    //Methods
    //////////////////
    extern function new(string name = "concerto_iosubsys_ace_txn_snps", uvm_component parent = null);
    extern virtual function void build_phase(uvm_phase  phase);
    extern virtual task run_ioaiu_ace_test_seq(input string initiator_port_name="", int ioaiu_port_id=0);
    // Generic task used by Child class
    int max_iteration=1;
    virtual task main_seq_pre_hook(uvm_phase phase); endtask// before the iteration (outside the iteration loop)
    virtual task main_seq_post_hook(uvm_phase phase); endtask// after the iteration (outside the iteration loop)
    virtual task main_seq_iter_pre_hook(uvm_phase phase, int iter=0); endtask// at the beginning of the iteration(inside the iteration loop)
    virtual task main_seq_iter_post_hook(uvm_phase phase, int iter=0); endtask// at the end of the iteration (inside the iteration)
    virtual task main_seq_hook_end_run_phase(uvm_phase phase); endtask
endclass: concerto_iosubsys_ace_txn_snps

//////////////////
//Calling Method: Child Class
//Description: Constructor
//Arguments:   UVM Default
//Return type: N/A
//////////////////
function concerto_iosubsys_ace_txn_snps::new(string name = "concerto_iosubsys_ace_txn_snps", uvm_component parent = null);
    super.new(name, parent);
    if(inst_name=="")
      inst_name=name;
endfunction: new

//////////////////
//Calling Method: UVM Factory
//Description: Build phase
//Arguments:   UVM Default
//Return type: Void
//////////////////
function void concerto_iosubsys_ace_txn_snps::build_phase(uvm_phase phase);

    `uvm_info("Build", "Entered Build Phase", UVM_LOW);
    super.build_phase(phase);
 endfunction: build_phase

task concerto_iosubsys_ace_txn_snps::run_ioaiu_ace_test_seq(input string initiator_port_name="", int ioaiu_port_id=0);
string seq_name="";
string ioaiu_ace_txn_type="";
svt_axi_ace_master_makeunique_sequence                       h_makeunique_sequence                    ;
svt_axi_ace_master_readshared_sequence                       h_readshared_sequence                    ;
svt_axi_ace_master_readclean_sequence                        h_readclean_sequence                     ;
svt_axi_ace_master_readnosnoop_sequence                      h_readnosnoop_sequence                   ; 
svt_axi_ace_master_readonce_sequence                         h_readonce_sequence                      ; 
svt_axi_ace_master_readnotshareddirty_sequence               h_readnotshareddirty_sequence            ;              
svt_axi_ace_master_readunique_sequence                       h_readunique_sequence                    ;
svt_axi_ace_master_cleanunique_sequence                      h_cleanunique_sequence                   ; 
svt_axi_ace_master_cleanshared_sequence                      h_cleanshared_sequence                   ; 
svt_axi_ace_master_cleaninvalid_sequence                     h_cleaninvalid_sequence                  ;  
svt_axi_ace_master_makeinvalid_sequence                      h_makeinvalid_sequence                   ; 
svt_axi_ace_master_writenosnoop_sequence                     h_writenosnoop_sequence                  ;  
svt_axi_ace_master_writeunique_sequence                      h_writeunique_sequence                   ; 
svt_axi_ace_master_writelineunique_sequence                  h_writelineunique_sequence               ;           
svt_axi_ace_master_writeback_sequence                        h_writeback_sequence                     ;
svt_axi_ace_master_writeclean_sequence                       h_writeclean_sequence                    ;
svt_axi_ace_master_evict_sequence                            h_evict_sequence                         ;                    
svt_axi_ace_master_writeevict_sequence                       h_writeevict_sequence                    ;
uvm_sequence svt_axi_ace_seq_h;
bit addr_mode_select=1;
int dmi_memory_coh_domain_start_addr_index=$urandom_range(addrMgrConst::dmi_memory_coh_domain_start_addr.size()-1,0);

if(!((conc_ioaiu_fnnativeif_array[ioaiu_port_id]=="ACE") || 
(conc_ioaiu_fnnativeif_array[ioaiu_port_id]=="ACE-LITE") ||
(conc_ioaiu_fnnativeif_array[ioaiu_port_id]=="ACELITE-E"))) begin : _test_valid_for_ace_extensions
    return;
end : _test_valid_for_ace_extensions

if($value$plusargs("ioaiu_ace_txn_type=%0s",ioaiu_ace_txn_type)) begin
    `uvm_info("concerto_iosubsys_ace_txn_snps::run_ioaiu_ace_test_seq",$psprintf("Test will generate %0s txns...",ioaiu_ace_txn_type),UVM_NONE)
end
if($value$plusargs("addr_mode=%0d",addr_mode_select)) begin
    `uvm_info("concerto_iosubsys_ace_txn_snps::run_ioaiu_ace_test_seq",$psprintf("Test will generate %0s txns in %0s...",ioaiu_ace_txn_type,(addr_mode_select==1)?"sequential addr mode":"random addr mode"),UVM_NONE)
end

if(ioaiu_ace_txn_type=="makeunique") begin
    seq_name = $sformatf("h_makeunique_sequence_%0d",ioaiu_port_id);
    h_makeunique_sequence = svt_axi_ace_master_makeunique_sequence::type_id::create("h_makeunique_sequence");
    $cast(svt_axi_ace_seq_h,h_makeunique_sequence);
    `uvm_info("concerto_iosubsys_ace_txn_snps::run_ioaiu_ace_test_seq",$psprintf("Inside makeunique..."),UVM_DEBUG)
end
else if(ioaiu_ace_txn_type=="readshared") begin
    seq_name = $sformatf("h_readshared_sequence_%0d",ioaiu_port_id);
    h_readshared_sequence = svt_axi_ace_master_readshared_sequence::type_id::create("h_readshared_sequence");
    $cast(svt_axi_ace_seq_h,h_readshared_sequence);
end
else if(ioaiu_ace_txn_type=="readclean") begin
    seq_name = $sformatf("h_readclean_sequence_%0d",ioaiu_port_id);
    h_readclean_sequence = svt_axi_ace_master_readclean_sequence::type_id::create("h_readclean_sequence");
    $cast(svt_axi_ace_seq_h,h_readclean_sequence);
end
else if(ioaiu_ace_txn_type=="readnosnoop") begin
    seq_name = $sformatf("h_readnosnoop_sequence_%0d",ioaiu_port_id);
    h_readnosnoop_sequence = svt_axi_ace_master_readnosnoop_sequence::type_id::create("h_readnosnoop_sequence");
    $cast(svt_axi_ace_seq_h,h_readnosnoop_sequence);
end
else if(ioaiu_ace_txn_type=="readnotshareddirty") begin
    seq_name = $sformatf("h_readnotshareddirty_sequence_%0d",ioaiu_port_id);
    h_readnotshareddirty_sequence = svt_axi_ace_master_readnotshareddirty_sequence::type_id::create("h_readnotshareddirty_sequence");
    $cast(svt_axi_ace_seq_h,h_readnotshareddirty_sequence);
end
else if(ioaiu_ace_txn_type=="readonce") begin
    seq_name = $sformatf("h_readonce_sequence_%0d",ioaiu_port_id);
    h_readonce_sequence = svt_axi_ace_master_readonce_sequence::type_id::create("h_readonce_sequence");
    $cast(svt_axi_ace_seq_h,h_readonce_sequence);
end
else if(ioaiu_ace_txn_type=="readunique") begin
    seq_name = $sformatf("h_readunique_sequence_%0d",ioaiu_port_id);
    h_readunique_sequence = svt_axi_ace_master_readunique_sequence::type_id::create("h_readunique_sequence");
    $cast(svt_axi_ace_seq_h,h_readunique_sequence);
end
else if(ioaiu_ace_txn_type=="cleanunique") begin
    seq_name = $sformatf("h_cleanunique_sequence_%0d",ioaiu_port_id);
    h_cleanunique_sequence = svt_axi_ace_master_cleanunique_sequence::type_id::create("h_cleanunique_sequence");
    $cast(svt_axi_ace_seq_h,h_cleanunique_sequence);
end
else if(ioaiu_ace_txn_type=="cleanshared") begin
    seq_name = $sformatf("h_cleanshared_sequence_%0d",ioaiu_port_id);
    h_cleanshared_sequence = svt_axi_ace_master_cleanshared_sequence::type_id::create("h_cleanshared_sequence");
    $cast(svt_axi_ace_seq_h,h_cleanshared_sequence);
end
else if(ioaiu_ace_txn_type=="cleaninvalid") begin
    seq_name = $sformatf("h_cleaninvalid_sequence_%0d",ioaiu_port_id);
    h_cleaninvalid_sequence = svt_axi_ace_master_cleaninvalid_sequence::type_id::create("h_cleaninvalid_sequence");
    $cast(svt_axi_ace_seq_h,h_cleaninvalid_sequence);
end
else if(ioaiu_ace_txn_type=="makeinvalid") begin
    seq_name = $sformatf("h_makeinvalid_sequence_%0d",ioaiu_port_id);
    h_makeinvalid_sequence = svt_axi_ace_master_makeinvalid_sequence::type_id::create("h_makeinvalid_sequence");
    $cast(svt_axi_ace_seq_h,h_makeinvalid_sequence);
end
else if(ioaiu_ace_txn_type=="writenosnoop") begin
    seq_name = $sformatf("h_writenosnoop_sequence_%0d",ioaiu_port_id);
    h_writenosnoop_sequence = svt_axi_ace_master_writenosnoop_sequence::type_id::create("h_writenosnoop_sequence");
    $cast(svt_axi_ace_seq_h,h_writenosnoop_sequence);
end
else if(ioaiu_ace_txn_type=="writeunique") begin
    seq_name = $sformatf("h_writeunique_sequence_%0d",ioaiu_port_id);
    h_writeunique_sequence = svt_axi_ace_master_writeunique_sequence::type_id::create("h_writeunique_sequence");
    $cast(svt_axi_ace_seq_h,h_writeunique_sequence);
end
else if(ioaiu_ace_txn_type=="writelineunique") begin
    seq_name = $sformatf("h_writelineunique_sequence_%0d",ioaiu_port_id);
    h_writelineunique_sequence = svt_axi_ace_master_writelineunique_sequence::type_id::create("h_writelineunique_sequence");
    $cast(svt_axi_ace_seq_h,h_writelineunique_sequence);
end
else if(ioaiu_ace_txn_type=="writeback") begin
    seq_name = $sformatf("h_writeback_sequence_%0d",ioaiu_port_id);
    h_writeback_sequence = svt_axi_ace_master_writeback_sequence::type_id::create("h_writeback_sequence");
    $cast(svt_axi_ace_seq_h,h_writeback_sequence);
end
else if(ioaiu_ace_txn_type=="writeclean") begin
    seq_name = $sformatf("h_writeclean_sequence_%0d",ioaiu_port_id);
    h_writeclean_sequence = svt_axi_ace_master_writeclean_sequence::type_id::create("h_writeclean_sequence");
    $cast(svt_axi_ace_seq_h,h_writeclean_sequence);
end
else if(ioaiu_ace_txn_type=="evict") begin
    seq_name = $sformatf("h_evict_sequence_%0d",ioaiu_port_id);
    h_evict_sequence = svt_axi_ace_master_evict_sequence::type_id::create("h_evict_sequence");
    $cast(svt_axi_ace_seq_h,h_evict_sequence);
end
else if(ioaiu_ace_txn_type=="writeevict") begin
    seq_name = $sformatf("h_writeevict_sequence_%0d",ioaiu_port_id);
    h_writeevict_sequence = svt_axi_ace_master_writeevict_sequence::type_id::create("h_writeevict_sequence");
    $cast(svt_axi_ace_seq_h,h_writeevict_sequence);
end
else begin
    seq_name = $sformatf("h_makeunique_sequence_%0d",ioaiu_port_id);
    h_makeunique_sequence = svt_axi_ace_master_makeunique_sequence::type_id::create("h_makeunique_sequence");
    $cast(svt_axi_ace_seq_h,h_makeunique_sequence);
    `uvm_info("concerto_iosubsys_ace_txn_snps::run_ioaiu_ace_test_seq",$psprintf("Inside makeunique..."),UVM_DEBUG)
end

`uvm_info("concerto_iosubsys_ace_txn_snps::run_ioaiu_ace_test_seq",$psprintf("Starting test on IOAIU[ioaiu_port_id=%0d,initiator_port_name=%0s,native-if=%0s] sequencer-%0s",ioaiu_port_id,initiator_port_name,conc_ioaiu_fnnativeif_array[ioaiu_port_id],conc_svt_axi_sysseqr_path_str),UVM_LOW)

if(addr_mode_select==1) begin
  // Hitting dmi non domain for all cases
  foreach(addrMgrConst::dmi_memory_coh_domain_start_addr[i]) begin
    if(i==dmi_memory_coh_domain_start_addr_index) begin
      `uvm_info("concerto_iosubsys_ace_txn_snps::run_ioaiu_ace_test_seq",$psprintf("Setting variables through config db. sequence_length %0d port_id %0d addr_mode_select %0d start_addr 'h%0h",ioaiu_num_trans,ioaiu_port_id,1,addrMgrConst::dmi_memory_coh_domain_start_addr[i]+(ioaiu_port_id*64000)),UVM_LOW)
  
      uvm_config_db#(int unsigned)::set(this, $psprintf("%0s.%0s",conc_svt_axi_sysseqr_path_str,seq_name), "sequence_length", ioaiu_num_trans);
      uvm_config_db#(int unsigned)::set(this, $psprintf("%0s.%0s",conc_svt_axi_sysseqr_path_str,seq_name), "port_id", ioaiu_port_id);
      uvm_config_db#(int unsigned)::set(this, $psprintf("%0s.%0s",conc_svt_axi_sysseqr_path_str,seq_name), "addr_mode_select",1);
      uvm_config_db#(bit[`SVT_AXI_ADDR_WIDTH-1:0])::set(this, $psprintf("%0s.%0s",conc_svt_axi_sysseqr_path_str,seq_name), "start_addr",addrMgrConst::dmi_memory_coh_domain_start_addr[i]+(ioaiu_port_id*64000));
      svt_axi_ace_seq_h.start(`CONC_SVT_AXI_SYSSEQR_PATH);
      `uvm_info("concerto_iosubsys_ace_txn_snps::run_ioaiu_ace_test_seq",$psprintf("Ending sequence-%0s on IOAIU[ioaiu_port_id=%0d,initiator_port_name=%0s,native-if=%0s]",seq_name,ioaiu_port_id,initiator_port_name,conc_ioaiu_fnnativeif_array[ioaiu_port_id]),UVM_LOW)
    end
  end    
  
  if((ioaiu_ace_txn_type=="readnosnoop") || (ioaiu_ace_txn_type=="writenosnoop")) begin
  // Hitting dmi noncoh domain for writenosnoop & readnosnoop 
      foreach(addrMgrConst::dmi_memory_noncoh_domain_start_addr[i]) begin
          `uvm_info("concerto_iosubsys_ace_txn_snps::run_ioaiu_ace_test_seq",$psprintf("Setting variables through config db. sequence_length %0d port_id %0d addr_mode_select %0d start_addr 'h%0h",ioaiu_num_trans,ioaiu_port_id,1,addrMgrConst::dmi_memory_noncoh_domain_start_addr[i]+(ioaiu_port_id*64000)),UVM_LOW)
      
          uvm_config_db#(int unsigned)::set(this, $psprintf("%0s.%0s",conc_svt_axi_sysseqr_path_str,seq_name), "sequence_length", ioaiu_num_trans);
          uvm_config_db#(int unsigned)::set(this, $psprintf("%0s.%0s",conc_svt_axi_sysseqr_path_str,seq_name), "port_id", ioaiu_port_id);
          uvm_config_db#(int unsigned)::set(this, $psprintf("%0s.%0s",conc_svt_axi_sysseqr_path_str,seq_name), "addr_mode_select",1);
          uvm_config_db#(bit[`SVT_AXI_ADDR_WIDTH-1:0])::set(this, $psprintf("%0s.%0s",conc_svt_axi_sysseqr_path_str,seq_name), "start_addr",addrMgrConst::dmi_memory_noncoh_domain_start_addr[i]+(ioaiu_port_id*64000));
          svt_axi_ace_seq_h.start(`CONC_SVT_AXI_SYSSEQR_PATH);
          `uvm_info("concerto_iosubsys_ace_txn_snps::run_ioaiu_ace_test_seq",$psprintf("Ending sequence-%0s on IOAIU[ioaiu_port_id=%0d,initiator_port_name=%0s,native-if=%0s]",seq_name,ioaiu_port_id,initiator_port_name,conc_ioaiu_fnnativeif_array[ioaiu_port_id]),UVM_LOW)
      end    
  
  // Hitting dii domain for writenosnoop & readnosnoop 
      foreach(addrMgrConst::dii_memory_domain_start_addr[i]) begin
          `uvm_info("concerto_iosubsys_ace_txn_snps::run_ioaiu_ace_test_seq",$psprintf("Setting variables through config db. sequence_length %0d port_id %0d addr_mode_select %0d start_addr 'h%0h",ioaiu_num_trans,ioaiu_port_id,1,addrMgrConst::dii_memory_domain_start_addr[i]+(ioaiu_port_id*64000)),UVM_LOW)
      
          uvm_config_db#(int unsigned)::set(this, $psprintf("%0s.%0s",conc_svt_axi_sysseqr_path_str,seq_name), "sequence_length", ioaiu_num_trans);
          uvm_config_db#(int unsigned)::set(this, $psprintf("%0s.%0s",conc_svt_axi_sysseqr_path_str,seq_name), "port_id", ioaiu_port_id);
          uvm_config_db#(int unsigned)::set(this, $psprintf("%0s.%0s",conc_svt_axi_sysseqr_path_str,seq_name), "addr_mode_select",1);
          uvm_config_db#(bit[`SVT_AXI_ADDR_WIDTH-1:0])::set(this, $psprintf("%0s.%0s",conc_svt_axi_sysseqr_path_str,seq_name), "start_addr",addrMgrConst::dii_memory_domain_start_addr[i]+(ioaiu_port_id*64000));
          svt_axi_ace_seq_h.start(`CONC_SVT_AXI_SYSSEQR_PATH);
          `uvm_info("concerto_iosubsys_ace_txn_snps::run_ioaiu_ace_test_seq",$psprintf("Ending sequence-%0s on IOAIU[ioaiu_port_id=%0d,initiator_port_name=%0s,native-if=%0s]",seq_name,ioaiu_port_id,initiator_port_name,conc_ioaiu_fnnativeif_array[ioaiu_port_id]),UVM_LOW)
      end    
  end
end else begin // if(addr_mode_select==1) begin
    `uvm_info("concerto_iosubsys_ace_txn_snps::run_ioaiu_ace_test_seq",$psprintf("Setting variables through config db. sequence_length %0d port_id %0d addr_mode_select %0d",ioaiu_num_trans*addrMgrConst::dmi_memory_coh_domain_start_addr.size(),ioaiu_port_id,0),UVM_LOW)

    uvm_config_db#(int unsigned)::set(this, $psprintf("%0s.%0s",conc_svt_axi_sysseqr_path_str,seq_name), "sequence_length", ioaiu_num_trans*addrMgrConst::dmi_memory_coh_domain_start_addr.size());
    uvm_config_db#(int unsigned)::set(this, $psprintf("%0s.%0s",conc_svt_axi_sysseqr_path_str,seq_name), "port_id", ioaiu_port_id);
    uvm_config_db#(int unsigned)::set(this, $psprintf("%0s.%0s",conc_svt_axi_sysseqr_path_str,seq_name), "addr_mode_select",0);
    svt_axi_ace_seq_h.start(`CONC_SVT_AXI_SYSSEQR_PATH);
    `uvm_info("concerto_iosubsys_ace_txn_snps::run_ioaiu_ace_test_seq",$psprintf("Ending sequence-%0s on IOAIU[ioaiu_port_id=%0d,initiator_port_name=%0s,native-if=%0s]",seq_name,ioaiu_port_id,initiator_port_name,conc_ioaiu_fnnativeif_array[ioaiu_port_id]),UVM_LOW)
end

endtask



`endif // `ifdef USE_VIP_SNPS
