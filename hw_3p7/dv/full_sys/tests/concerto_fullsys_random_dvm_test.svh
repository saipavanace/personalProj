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
var aceaiu0;  // strRtlNamePrefix of aceaiuu0;   // strRtlNamePrefix of aceaiu0
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
         if(obj.AiuInfo[pidx].fnNativeInterface == "ACE" ||obj.AiuInfo[pidx].fnNativeInterface == "ACE5") { 
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
//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
class concerto_fullsys_random_dvm_test extends concerto_fullsys_test; 
  // #Stimulus.FSYS.DVM_v8
  // #Stimulus.FSYS.DVM_v81
  // #Stimulus.FSYS.DVM_v84
  // #Stimulus.FSYS.DVM_hang_scn1
  // #Stimulus.FSYS.DVM_hang_scn2
  // #Stimulus.FSYS.DVM_SnpRespErr

  `uvm_component_utils(concerto_fullsys_random_dvm_test)
  uvm_phase exec_inhouse_phase;

  //ATTRIBUTS
   
  //METHOD 
   // UVM PHASE
   extern virtual function void build_phase(uvm_phase phase);
   extern virtual function void end_of_elaboration_phase(uvm_phase phase);
   extern virtual function void start_of_simulation_phase(uvm_phase phase);
    <% if(numIoAiu > 0) { %> 
   extern virtual task run_ioaiu_test_seq(input string initiator_port_name="", int ioaiu_port_id=0);
    <% } %>
   extern virtual task run_chiaiu_test_seq(input string initiator_port_name="", int chiaiu_port_id=0);
   extern virtual task exec_inhouse_seq (uvm_phase phase);
   uvm_event block_sending_of_DvmComplete_trigger[];
   uvm_event unblock_sending_of_DvmComplete_trigger[];

  function new(string name = "concerto_fullsys_random_dvm_test", uvm_component parent=null);
    super.new(name,parent);
    block_sending_of_DvmComplete_trigger = new[<%=numIoAiu%>];
    unblock_sending_of_DvmComplete_trigger = new[<%=numIoAiu%>];
    foreach(block_sending_of_DvmComplete_trigger[i]) begin
        block_sending_of_DvmComplete_trigger[i] = new($psprintf("block_sending_of_DvmComplete_trigger[%0d]",i));
        unblock_sending_of_DvmComplete_trigger[i] = new($psprintf("unblock_sending_of_DvmComplete_trigger[%0d]",i));
    end
  endfunction: new

<% if(numIoAiu > 0) { %> 
  virtual task ioaiu_start_snoop_response_seq_for_dvm(int port_id, svt_axi_ace_master_snoop_response_sequence snoop_resp_seq);
  conc_svt_axi_ace_master_dvm_complete_sequence dvm_complete_seq;
    void'(snoop_resp_seq.randomize());
    `svt_xvm_debug("ioaiu_start_snoop_response_seq_for_dvm", $sformatf("Stopping existing snoop sequences on snoop sequencer 'd%0d to start dvm specific sequence of type svt_axi_ace_master_snoop_response_sequence('d%0d) as this virtual sequence requires a snoop sequence of this type",port_id, snoop_resp_seq));
    m_concerto_env.snps.svt.amba_system_env.axi_system[0].master[port_id].snoop_sequencer.stop_sequences();
    fork begin
      snoop_resp_seq.start(m_concerto_env.snps.svt.amba_system_env.axi_system[0].master[port_id].snoop_sequencer);
    end
    join_none

    if (m_concerto_env_cfg.svt_cfg.axi_sys_cfg[0].master_cfg[port_id].auto_gen_dvm_complete_enable == 0) begin
      dvm_complete_seq = conc_svt_axi_ace_master_dvm_complete_sequence::type_id::create($sformatf("dvm_complete_seq_%0d",port_id));
      dvm_complete_seq.snoop_resp_seq = snoop_resp_seq;
      fork
          begin
              forever begin
                block_sending_of_DvmComplete_trigger[port_id].wait_trigger();
                dvm_complete_seq.block_sending_of_DvmComplete = 1;
              end
          end

          begin
              forever begin
                unblock_sending_of_DvmComplete_trigger[port_id].wait_trigger();
                dvm_complete_seq.block_sending_of_DvmComplete = 0;
              end
          end
      join_none
      `ifdef SVT_UVM_TECHNOLOGY
      `ifdef SVT_UVM_12_OR_HIGHER 
      dvm_complete_seq.parent_starting_phase = exec_inhouse_phase;
      `else
      dvm_complete_seq.parent_starting_phase = exec_inhouse_phase;
      `endif
      `endif
      void'(dvm_complete_seq.randomize()); 
      dvm_complete_seq.start(m_concerto_env.snps.svt.amba_system_env.axi_system[0].master[port_id].sequencer);
    end
  endtask: ioaiu_start_snoop_response_seq_for_dvm

  virtual task ioaiu_send_dvm_sequence(int port_id, svt_axi_ace_master_snoop_response_sequence snoop_resp_seq, int num_of_dvm_message);
  int wt_multipart_dvm;
  conc_svt_axi_ace_master_dvm_base_sequence dvm_sync_seq;

  if(!$value$plusargs("wt_multipart_dvm=%0d",wt_multipart_dvm)) begin
      randcase
      40 : wt_multipart_dvm = 1;
      60 : wt_multipart_dvm = 0;
      endcase
  end  
    fork
    begin
        //for (int dvm_message_num = 0; dvm_message_num< 1; dvm_message_num++) begin
        for (int dvm_message_num = 0; dvm_message_num< num_of_dvm_message; dvm_message_num++) begin : dvm_non_sync_loop
          conc_svt_axi_ace_master_dvm_base_sequence dvm_operation_seq;
          svt_axi_ace_master_multipart_dvm_sequence two_part_dvm_operation_seq;
          bit [2:0] dvm_message_type=$urandom_range(3,0);
          if($urandom_range(99,1)<wt_multipart_dvm) begin : multipart_dvm
              two_part_dvm_operation_seq = svt_axi_ace_master_multipart_dvm_sequence::type_id::create($sformatf("two_part_dvm_operation_seq_%0d",port_id));
              `svt_xvm_debug("body",$sformatf("Starting %0d DVM Operation on master 'd%0d",dvm_message_num,port_id));
              two_part_dvm_operation_seq.randomize() with {two_part_dvm_operation_seq.seq_xact_type==svt_axi_transaction::DVMMESSAGE;
                                          two_part_dvm_operation_seq.dvm_message_type == local::dvm_message_type;};
              block_sending_of_DvmComplete_trigger[port_id].trigger();
              two_part_dvm_operation_seq.start(m_concerto_env.snps.svt.amba_system_env.axi_system[0].master[port_id].sequencer);
              unblock_sending_of_DvmComplete_trigger[port_id].trigger();
              `svt_xvm_debug("body",$sformatf("Ending %0d DVM Operation on master 'd%0d",dvm_message_num,port_id));
          end : multipart_dvm
          else begin : else_multipart_dvm
           fork
           begin
              dvm_operation_seq = conc_svt_axi_ace_master_dvm_base_sequence::type_id::create($sformatf("dvm_operation_seq_%0d",port_id));
              `svt_xvm_debug("body",$sformatf("Starting %0d DVM Operation on master 'd%0d",dvm_message_num,port_id));
              dvm_operation_seq.randomize() with {dvm_operation_seq.seq_xact_type==svt_axi_transaction::DVMMESSAGE;
                                          dvm_operation_seq.dvm_message_type == local::dvm_message_type;};
              dvm_operation_seq.start(m_concerto_env.snps.svt.amba_system_env.axi_system[0].master[port_id].sequencer);
              `svt_xvm_debug("body",$sformatf("Ending %0d DVM Operation on master 'd%0d",dvm_message_num,port_id));
              if($urandom_range(1,0)==1) #1ns;
            end
            join_none
          end : else_multipart_dvm
        end : dvm_non_sync_loop
      if(wt_multipart_dvm==0) begin
          // Send a DVM sync to know when the DVM operation is complete
          // in all peer masters.
          dvm_sync_seq = conc_svt_axi_ace_master_dvm_base_sequence::type_id::create($sformatf("dvm_sync_seq_%0d",port_id));
          dvm_sync_seq.randomize() with {dvm_sync_seq.seq_xact_type==svt_axi_transaction::DVMMESSAGE;
                                       dvm_sync_seq.dvm_message_type == 3'b100;};
          dvm_sync_seq.start(m_concerto_env.snps.svt.amba_system_env.axi_system[0].master[port_id].sequencer);
      end 
    end
    // Thread that waits for all the DVM complete transactions to be received
    begin
      // Wait for all the corresponding DVM Completes to be received
      if(wt_multipart_dvm==0) begin
          ioaiu_wait_for_dvm_complete(snoop_resp_seq, port_id);
      end
    end
    join
  endtask: ioaiu_send_dvm_sequence

  virtual task ioaiu_wait_for_dvm_complete(svt_axi_ace_master_snoop_response_sequence snoop_resp_seq, int port_id);
    `SVT_DATA_BASE_OBJECT_TYPE ev_xact;
    svt_axi_snoop_transaction snoop_xact;

    `svt_xvm_debug("ioaiu_wait_for_dvm_complete",$psprintf("Waiting for DVM COMPLETE on master 'd%0d",port_id));
    snoop_resp_seq.EVENT_DVM_COMPLETE_XACT.wait_trigger_data(ev_xact);
    if (!$cast(snoop_xact,ev_xact)) begin
      `svt_xvm_fatal("ioaiu_wait_for_dvm_complete","Transaction obtained through EVENT_DVM_COMPLETE_XACT is not of type svt_axi_snoop_transaction");
    end
    else begin
      `svt_xvm_debug("ioaiu_wait_for_dvm_complete",$psprintf("Received DVM COMPLETE %0s on master 'd%0d. Waiting for it to complete...",`SVT_AXI_ACE_PRINT_PREFIX(snoop_xact),port_id));
      wait (
             (snoop_xact.snoop_resp_status == svt_axi_snoop_transaction::ACCEPT) ||
             (snoop_xact.snoop_resp_status == svt_axi_snoop_transaction::ABORTED) 
           );
      `svt_xvm_debug("ioaiu_wait_for_dvm_complete",$psprintf("Received DVM COMPLETE %0s on master 'd%0d is now complete.",`SVT_AXI_ACE_PRINT_PREFIX(snoop_xact),port_id));
    end
  endtask: ioaiu_wait_for_dvm_complete
<% } %>


endclass: concerto_fullsys_random_dvm_test


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
 function void concerto_fullsys_random_dvm_test::build_phase(uvm_phase phase);
  super.build_phase(phase);
  set_type_override_by_type(svt_chi_rn_transaction_dvm_write_semantic_sequence::get_type(),conc_svt_chi_rn_transaction_dvm_write_semantic_sequence::get_type());
  set_type_override_by_type(svt_chi_rn_transaction::get_type(),conc_base_svt_chi_rn_transaction::get_type());

  <% if(numIoAiu > 0) { %> 
  set_type_override_by_type(svt_axi_master_transaction::get_type(),io_subsys_pkg::conc_svt_axi_master_dvm_transaction::get_type());
  <% } %>

 endfunction:build_phase

 function void concerto_fullsys_random_dvm_test::end_of_elaboration_phase (uvm_phase phase);
  super.end_of_elaboration_phase(phase);
 endfunction:end_of_elaboration_phase

function void concerto_fullsys_random_dvm_test::start_of_simulation_phase(uvm_phase phase);
  `uvm_info("FULLSYS_DVM_TEST", "START_OF_SIMULATION", UVM_LOW)
  super.start_of_simulation_phase(phase);
  `uvm_info("FULLSYS_DVM_TEST", "END START_OF_SIMULATION", UVM_LOW)
endfunction:start_of_simulation_phase

task concerto_fullsys_random_dvm_test::exec_inhouse_seq (uvm_phase phase);
// OVERWRITE exec_inhouse_seq used in the main_phase
bit [7:0]reg_map_Ver, json_Ver=<%=obj.DveInfo[0].DVMVersionSupport%>, frontdoor_read_Ver;
uvm_reg reg_;
uvm_status_e status;
// #Cover.FSYS.DVM_version_check

 `uvm_info("concerto_fullsys_random_dvm_test", "EXEC_INHOUSE_SEQ ", UVM_LOW)
  phase.raise_objection(this, "exec_inhouse_seq::concerto_fullsys_random_dvm_test");
  exec_inhouse_phase = phase;
  if(test_cfg.check_dvm_version) begin
      reg_ = m_concerto_env.m_regs.dve0.get_reg_by_name("DVEUDVMRR");
      reg_.read(status,frontdoor_read_Ver);
      if(frontdoor_read_Ver==json_Ver) begin
          `uvm_info("FULLSYS_DVM_TEST", $psprintf("Match in value, frontdoor_read_Ver=%0d json_Ver=%0d",frontdoor_read_Ver,json_Ver), UVM_LOW)
      end else begin
          `uvm_error("FULLSYS_DVM_TEST", $psprintf("Mismatch in value, frontdoor_read_Ver=%0d json_Ver=%0d",frontdoor_read_Ver,json_Ver))
      end

      reg_map_Ver = m_concerto_env.m_regs.dve0.get_reg_by_name("DVEUDVMRR").get_field_by_name("Ver").get_reset();
      if(reg_map_Ver==json_Ver) begin
          `uvm_info("FULLSYS_DVM_TEST", $psprintf("Match in value, reg_map_Ver=%0d json_Ver=%0d",reg_map_Ver,json_Ver), UVM_LOW)
      end else begin
          `uvm_error("FULLSYS_DVM_TEST", $psprintf("Mismatch in value, reg_map_Ver=%0d json_Ver=%0d",reg_map_Ver,json_Ver))
      end
  end
  csr_init_done.trigger(null);

  #100ns; 
  
  fork:fork_run_all_seq_in_parallel
    <%var chiaiu_idx = 0;
    var ioaiu_idx = 0;
    for(var pidx = 0; pidx < obj.nAIUs; pidx++) {
        if(obj.AiuInfo[pidx].fnNativeInterface.match("CHI")) {%>
    begin
           if(chiaiu_en.exists(<%=chiaiu_idx%>)) begin:_chiaiu<%=chiaiu_idx%>_trigger
               run_chiaiu_test_seq("<%=obj.AiuInfo[pidx].strRtlNamePrefix%>",<%=chiaiu_idx%>);
               #1ns;
               done_svt_chi_rn_seq_h<%=chiaiu_idx%>.trigger();
           end : _chiaiu<%=chiaiu_idx%>_trigger
    end
    <% chiaiu_idx++;
    } else { %>
    <% if(((obj.AiuInfo[pidx].fnNativeInterface == "ACELITE-E") && (aiu_axiInt[pidx].params.enableDVM))||(obj.AiuInfo[pidx].fnNativeInterface == "ACE")||(obj.AiuInfo[pidx].fnNativeInterface == "ACE5")||((obj.AiuInfo[pidx].fnNativeInterface == "ACE-LITE") && (aiu_axiInt[pidx].params.enableDVM))) { %>
    begin
          if(ioaiu_en.exists(<%=ioaiu_idx%>)) begin:_ioaiu<%=ioaiu_idx%>_trigger
               run_ioaiu_test_seq("<%=obj.AiuInfo[pidx].strRtlNamePrefix%>",<%=ioaiu_idx%>);
               #1ns;
               done_snp_cust_seq_h<%=ioaiu_idx%>.trigger();
          end:_ioaiu<%=ioaiu_idx%>_trigger
    end
    <% }  
    ioaiu_idx++; }
    } %>
  join_none:fork_run_all_seq_in_parallel
  
 fork
 begin

     begin : wait_for_all_seq_to_finish
         fork:_fork_wait_for_all_seq_to_finish

             <%chiaiu_idx = 0;
             ioaiu_idx = 0;
             for(var pidx = 0; pidx < obj.nAIUs; pidx++) {
                 if(obj.AiuInfo[pidx].fnNativeInterface.match("CHI")) {%>
                 begin
                    if(chiaiu_en.exists(<%=chiaiu_idx%>)) begin:_chiaiu<%=chiaiu_idx%>_wait	
                        `uvm_info("concerto_fullsys_random_dvm_test", $psprintf("Blocked by done_svt_chi_rn_seq_h<%=chiaiu_idx%>.wait_trigger"), UVM_LOW)
                        done_svt_chi_rn_seq_h<%=chiaiu_idx%>.wait_trigger();
                        `uvm_info("concerto_fullsys_random_dvm_test", $psprintf("Unbloking done_svt_chi_rn_seq_h<%=chiaiu_idx%>.wait_trigger"), UVM_LOW)
                        //#25us; //trial to wait for all <##>_RSP
                    end : _chiaiu<%=chiaiu_idx%>_wait
                 end  
             <% chiaiu_idx++;
             } else { %>
             <% if(((obj.AiuInfo[pidx].fnNativeInterface == "ACELITE-E") && (aiu_axiInt[pidx].params.enableDVM))||(obj.AiuInfo[pidx].fnNativeInterface == "ACE")||(obj.AiuInfo[pidx].fnNativeInterface == "ACE5")||((obj.AiuInfo[pidx].fnNativeInterface == "ACE-LITE") && (aiu_axiInt[pidx].params.enableDVM))) { %>
                 begin
                   if(ioaiu_en.exists(<%=ioaiu_idx%>)) begin:_ioaiu<%=ioaiu_idx%>_wait
                        `uvm_info("concerto_fullsys_random_dvm_test", $psprintf("Blocked by done_snp_cust_seq_h<%=ioaiu_idx%>.wait_trigger"), UVM_LOW)
                        done_snp_cust_seq_h<%=ioaiu_idx%>.wait_trigger();
                        `uvm_info("concerto_fullsys_random_dvm_test", $psprintf("Unbloking done_snp_cust_seq_h<%=ioaiu_idx%>.wait_trigger"), UVM_LOW)
                   end:_ioaiu<%=ioaiu_idx%>_wait
                 end  
             <% } 
             ioaiu_idx++; }
             } %>
         join:_fork_wait_for_all_seq_to_finish
         `uvm_info("concerto_fullsys_random_dvm_test", $psprintf("Executing ev_sim_done.trigger"), UVM_LOW)
         ev_sim_done.trigger(null);
     end : wait_for_all_seq_to_finish
 end  // fork
 begin
     #(sim_timeout_ms*1ms);
     timeout = 1;
 end
 join_any
 phase.drop_objection(this, "exec_inhouse_seq::concerto_fullsys_random_dvm_test");
`uvm_info("concerto_fullsys_random_dvm_test", "END EXEC_INHOUSE_SEQ", UVM_LOW)
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

<% if(numIoAiu > 0) { %> 
task concerto_fullsys_random_dvm_test::run_ioaiu_test_seq(input string initiator_port_name="", int ioaiu_port_id=0);
svt_axi_ace_master_snoop_response_sequence snoop_resp_seq;
  `uvm_info("concerto_iosubsys_test_snps::run_ioaiu_test",$psprintf("Calling run_ioaiu_test_seq for IOAIU[%0d/%0s]",ioaiu_port_id,initiator_port_name),UVM_LOW)
  if(ioaiu_num_trans>0) begin : ioaiu_random_dvm_test_thread
    `svt_xvm_debug("body", "Entered...");
     if (
           (m_concerto_env_cfg.svt_cfg.axi_sys_cfg[0].master_cfg[ioaiu_port_id].is_active == 1) &&
           (
             (m_concerto_env_cfg.svt_cfg.axi_sys_cfg[0].master_cfg[ioaiu_port_id].axi_interface_type == svt_axi_port_configuration::AXI_ACE) ||
             (
               (m_concerto_env_cfg.svt_cfg.axi_sys_cfg[0].master_cfg[ioaiu_port_id].axi_interface_type == svt_axi_port_configuration::ACE_LITE) &&
               m_concerto_env_cfg.svt_cfg.axi_sys_cfg[0].master_cfg[ioaiu_port_id].dvm_enable
             )
           )
         ) begin
          snoop_resp_seq = svt_axi_ace_master_snoop_response_sequence::type_id::create($sformatf("snoop_resp_seq_%0d",ioaiu_port_id));
          ioaiu_start_snoop_response_seq_for_dvm(ioaiu_port_id, snoop_resp_seq);
     end

    //ioaiu_send_dvm_sequence(ioaiu_port_id,snoop_resp_seq,$urandom_range(4,1));
    repeat(ioaiu_num_trans)
        ioaiu_send_dvm_sequence(ioaiu_port_id,snoop_resp_seq,1);
  end 

endtask: run_ioaiu_test_seq
<% } %>

task concerto_fullsys_random_dvm_test::run_chiaiu_test_seq(input string initiator_port_name="", int chiaiu_port_id=0);
bit dvm_sync_data_phase_complete = 0;
svt_chi_rn_transaction_dvm_sync_sequence dvm_sync_seq;
svt_chi_rn_transaction dvm_sync_xact;

  `uvm_info("concerto_iosubsys_test_snps::run_ioaiu_test",$psprintf("Calling run_chiaiu_test_seq for CHIAIU[%0d/%0s]",chiaiu_port_id,initiator_port_name),UVM_LOW)
  if(chi_num_trans>0) begin : chiaiu_random_dvm_test_thread
    for (int sync_num = 0; sync_num < chi_num_trans; sync_num++) begin
      `svt_xvm_debug("body",$sformatf("Starting DVM Operation on RN %0d",chiaiu_port_id));
      dvm_sync_data_phase_complete = 0;
      fork
      begin
          dvm_sync_seq = svt_chi_rn_transaction_dvm_sync_sequence::type_id::create("dvm_sync_seq");
          dvm_sync_seq.start(m_concerto_env.snps.svt.amba_system_env.chi_system[0].rn[chiaiu_port_id].rn_xact_seqr);
      end
      begin
        fork 
          begin : dvm_data_phase
            wait(dvm_sync_seq.dvm_sync_data_phase_complete == 1);
            dvm_sync_data_phase_complete = 1;
          end
          begin : dvm_retried
            wait(dvm_sync_seq.dvm_sync_retried_cancelled == 1);
          end
        join_any
        disable dvm_data_phase;
        disable dvm_retried;
      end
      join
  
      if (!$cast(dvm_sync_xact, m_concerto_env.snps.svt.amba_system_env.chi_system[0].rn[chiaiu_port_id].rn_xact_seqr.last_req())) begin
        `svt_xvm_fatal("body", $psprintf("Unable to cast last_req from seqr"));
      end
      else begin
        `svt_xvm_debug("body", $psprintf("Got the last_req %0s from seqr", `SVT_CHI_PRINT_PREFIX(dvm_sync_xact)));
      end
    end
  end : chiaiu_random_dvm_test_thread

endtask

