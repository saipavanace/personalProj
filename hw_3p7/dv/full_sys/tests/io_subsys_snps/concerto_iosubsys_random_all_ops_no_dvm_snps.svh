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

//File: concerto_iosubsys_random_all_ops_no_dvm_snps.svh

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
class concerto_iosubsys_random_all_ops_no_dvm_snps extends concerto_iosubsys_test_snps;

    //////////////////
    //UVM Registery
    //////////////////    
    `uvm_component_utils(concerto_iosubsys_random_all_ops_no_dvm_snps)

    //////////////////
    //Methods
    //////////////////
    extern function new(string name = "concerto_iosubsys_random_all_ops_no_dvm_snps", uvm_component parent = null);
    extern virtual function void build_phase(uvm_phase  phase);
    extern virtual task run_ioaiu_ace_test_seq(input string initiator_port_name="", int ioaiu_port_id=0);
    // Generic task used by Child class
    int max_iteration=1;
    virtual task main_seq_pre_hook(uvm_phase phase); endtask// before the iteration (outside the iteration loop)
    virtual task main_seq_post_hook(uvm_phase phase); endtask// after the iteration (outside the iteration loop)
    virtual task main_seq_iter_pre_hook(uvm_phase phase, int iter=0); endtask// at the beginning of the iteration(inside the iteration loop)
    virtual task main_seq_iter_post_hook(uvm_phase phase, int iter=0); endtask// at the end of the iteration (inside the iteration)
    virtual task main_seq_hook_end_run_phase(uvm_phase phase); endtask
endclass: concerto_iosubsys_random_all_ops_no_dvm_snps

//////////////////
//Calling Method: Child Class
//Description: Constructor
//Arguments:   UVM Default
//Return type: N/A
//////////////////
function concerto_iosubsys_random_all_ops_no_dvm_snps::new(string name = "concerto_iosubsys_random_all_ops_no_dvm_snps", uvm_component parent = null);
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
function void concerto_iosubsys_random_all_ops_no_dvm_snps::build_phase(uvm_phase phase);

    `uvm_info("Build", "Entered Build Phase", UVM_LOW);
    super.build_phase(phase);
 endfunction: build_phase

task concerto_iosubsys_random_all_ops_no_dvm_snps::run_ioaiu_ace_test_seq(input string initiator_port_name="", int ioaiu_port_id=0);
string seq_name="ioaiu_random_all_ops_no_dvm_sequence";
string seq_inst="";
ioaiu_random_all_ops_no_dvm_sequence svt_axi_ace_seq_h;
ioaiu_axi_ace_master_base_virtual_sequence_controls vseq_controls;

vseq_controls = ioaiu_axi_ace_master_base_virtual_sequence_controls::type_id::create("vseq_controls");

// Assign xact weights
if(conc_ioaiu_fnnativeif_array[ioaiu_port_id]=="ACE") begin
    //vseq_controls.readnosnoop_wt         = 1;                          // Generates svt_axi_transaction::READNOSNOOP        
    vseq_controls.readonce_wt            = 1;                          // Generates svt_axi_transaction::READONCE           
    vseq_controls.readclean_wt           = 1;                          // Generates svt_axi_transaction::READCLEAN          
    vseq_controls.readnotshareddirty_wt  = 1;                          // Generates svt_axi_transaction::READNOTSHAREDDIRTY 
    vseq_controls.readshared_wt          = 1;                          // Generates svt_axi_transaction::READSHARED         
    vseq_controls.readunique_wt          = 1;                          // Generates svt_axi_transaction::READUNIQUE         
    vseq_controls.cleanunique_wt         = 1;                          // Generates svt_axi_transaction::CLEANUNIQUE        
    vseq_controls.cleanshared_wt         = 1;                          // Generates svt_axi_transaction::CLEANSHARED        
    vseq_controls.cleansharedpersist_wt  = 1;                          // Generates svt_axi_transaction::CLEANSHAREDPERSIST 
    vseq_controls.cleaninvalid_wt        = 1;                          // Generates svt_axi_transaction::CLEANINVALID       
    vseq_controls.makeunique_wt          = 1;                          // Generates svt_axi_transaction::MAKEUNIQUE         
    vseq_controls.makeinvalid_wt         = 1;                          // Generates svt_axi_transaction::MAKEINVALID        
    //vseq_controls.writenosnoop_wt        = 1;                          // Generates svt_axi_transaction::WRITENOSNOOP       
    vseq_controls.writeunique_wt         = 1;                          // Generates svt_axi_transaction::WRITEUNIQUE        
    vseq_controls.writelineunique_wt     = 1;                          // Generates svt_axi_transaction::WRITELINEUNIQUE    
    vseq_controls.writeback_wt           = 1;                          // Generates svt_axi_transaction::WRITEBACK          
    vseq_controls.writeclean_wt          = 1;                          // Generates svt_axi_transaction::WRITECLEAN         
    vseq_controls.evict_wt               = 1;                          // Generates svt_axi_transaction::EVICT              
    vseq_controls.writeevict_wt          = 1;                          // Generates svt_axi_transaction::WRITEEVICT         
end else if(conc_ioaiu_fnnativeif_array[ioaiu_port_id]=="ACE-LITE") begin
    //vseq_controls.readnosnoop_wt              =  1;
    vseq_controls.readonce_wt                 =  1;
    vseq_controls.readclean_wt                =  0;
    vseq_controls.readnotshareddirty_wt       =  0;
    vseq_controls.readshared_wt               =  0;
    vseq_controls.readunique_wt               =  0;
    vseq_controls.cleanunique_wt              =  0;
    vseq_controls.cleanshared_wt              =  1;
    vseq_controls.cleansharedpersist_wt       =  1;
    vseq_controls.cleaninvalid_wt             =  1;
    vseq_controls.makeunique_wt               =  0;
    vseq_controls.makeinvalid_wt              =  1;
    //vseq_controls.writenosnoop_wt             =  1;
    vseq_controls.writeunique_wt              =  1;
    vseq_controls.writelineunique_wt          =  1;
    vseq_controls.writeback_wt                =  0;
    vseq_controls.writeclean_wt               =  0;
    vseq_controls.evict_wt                    =  0; 
    vseq_controls.writeevict_wt               =  0;
    vseq_controls.readoncecleaninvalid_wt     =  1;
    vseq_controls.readoncemakeinvalid_wt      =  1;
end else if(conc_ioaiu_fnnativeif_array[ioaiu_port_id]=="ACELITE-E") begin
    //vseq_controls.readnosnoop_wt              =  1;
    vseq_controls.readonce_wt                 =  1;
    vseq_controls.readclean_wt                =  0;
    vseq_controls.readnotshareddirty_wt       =  0;
    vseq_controls.readshared_wt               =  0;
    vseq_controls.readunique_wt               =  0;
    vseq_controls.cleanunique_wt              =  0;
    vseq_controls.cleanshared_wt              =  1;
    vseq_controls.cleansharedpersist_wt       =  1;
    vseq_controls.cleaninvalid_wt             =  1;
    vseq_controls.makeunique_wt               =  0;
    vseq_controls.makeinvalid_wt              =  1;
    //vseq_controls.writenosnoop_wt             =  1;
    vseq_controls.writeunique_wt              =  1;
    vseq_controls.writelineunique_wt          =  1;
    vseq_controls.writeback_wt                =  0;
    vseq_controls.writeclean_wt               =  0;
    vseq_controls.evict_wt                    =  0; 
    vseq_controls.writeevict_wt               =  0;
    vseq_controls.readoncecleaninvalid_wt     =  1;
    vseq_controls.readoncemakeinvalid_wt      =  1;

`ifdef SVT_ACE5_ENABLE
     // CONC-11906 : To-do Add logic for stash target to be chiaiu only
    vseq_controls.writeuniqueptlstash_wt      = 0;  
    vseq_controls.writeuniquefullstash_wt     = 0;  
    vseq_controls.stashonceunique_wt          = 0;  
    vseq_controls.stashonceshared_wt          = 0;  

     // CONC-11906 : To-do ACE5 feature - Check for cmo on write support
    vseq_controls.cmo_wt                        = 0; // zero weight due to unsure of cmo on write support
    vseq_controls.writeptlcmo_wt                = 0; // zero weight due to unsure of cmo on write support
    vseq_controls.writefullcmo_wt               = 0; // zero weight due to unsure of cmo on write support
`endif
end else if(conc_ioaiu_fnnativeif_array[ioaiu_port_id]=="AXI4") begin
    vseq_controls.write_wt                      = 1;
    vseq_controls.read_wt                       = 1;
end

    `uvm_info("concerto_iosubsys_random_all_ops_no_dvm_snps::run_ioaiu_ace_test_seq",$psprintf("Starting sequence-%0s on IOAIU[ioaiu_port_id=%0d,initiator_port_name=%0s,native-if=%0s] sequencer-%0s",seq_name,ioaiu_port_id,initiator_port_name,conc_ioaiu_fnnativeif_array[ioaiu_port_id],`CONC_COMMON_STRINGIFY(`CONC_SVT_AXI_SYSSEQR_PATH)),UVM_LOW)
    `uvm_info("concerto_iosubsys_random_all_ops_no_dvm_snps::run_ioaiu_ace_test_seq",$psprintf("Setting variables through config db. sequence_length %0d port_id %0d ",ioaiu_num_trans,ioaiu_port_id),UVM_LOW)
    seq_inst = $sformatf("svt_axi_ace_seq_h_%0d",ioaiu_port_id);
    svt_axi_ace_seq_h = ioaiu_random_all_ops_no_dvm_sequence::type_id::create(seq_inst);
    uvm_config_db#(ioaiu_axi_ace_master_base_virtual_sequence_controls)::set(this, $psprintf("%0s.%0s",conc_svt_axi_sysseqr_path_str,seq_inst), "vseq_controls", vseq_controls);
    uvm_config_db#(int unsigned)::set(this, $psprintf("%0s.%0s",conc_svt_axi_sysseqr_path_str,seq_inst), "sequence_length", ioaiu_num_trans);
    uvm_config_db#(int unsigned)::set(this, $psprintf("%0s.%0s",conc_svt_axi_sysseqr_path_str,seq_inst), "port_id", ioaiu_port_id);
    svt_axi_ace_seq_h.start(`CONC_SVT_AXI_SYSSEQR_PATH);
    `uvm_info("concerto_iosubsys_random_all_ops_no_dvm_snps::run_ioaiu_ace_test_seq",$psprintf("Ending sequence-%0s on IOAIU[ioaiu_port_id=%0d,initiator_port_name=%0s,native-if=%0s]",seq_name,ioaiu_port_id,initiator_port_name,conc_ioaiu_fnnativeif_array[ioaiu_port_id]),UVM_LOW)

endtask



`endif // `ifdef USE_VIP_SNPS
