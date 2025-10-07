/****************************************************************************************************************************
*                                                                                                                           *
* Fault Injector checker for Ncore 3.0 resiliency testing                                                                   *
* This module injects different types of faults at unit level as well as                                                    *
* system level and then checks the unit/system different fault outputs                                                      *
*                                                                                                                           *
* File    : fault_injector_checker.sv                                                                                       *
* Version : 0.1 (currently, works only at unit level)                                                                       *
* Author  : Aman Khandelwal                                                                                                 *
* Confluence page links  :                                                                                                  *
* 1. https://confluence.arteris.com/pages/viewpage.action?spaceKey=OP&title=Ncore+3.0+FSC+Micro-Architecture+Specification  *
* 2. https://confluence.arteris.com/display/OP/Ncore+v3.0+Resilience+Testplan                                               *
* 3. https://confluence.arteris.com/display/OP/fault_checker                                                                *
*                                                                                                                           *
*  TODO: 1. Inject both corr and uncorr errors at same time?                                                                *
/***************************************************************************************************************************/

`ifndef FAULT_INJECTOR_CHECKER_SV
`define FAULT_INJECTOR_CHECKER_SV

<% if (obj.CUSTOMER_ENV) { %>
`include "global_tb_phys.sv"
<% } %>

<% var aiu_axiInt;
   var aiu_axiIsArray;
   var aiu_axiLen;
if (obj.DutInfo.interfaces.axiInt) {
   aiu_axiIsArray = Array.isArray(obj.DutInfo.interfaces.axiInt);
   if(aiu_axiIsArray) {
      aiu_axiInt     = obj.DutInfo.interfaces.axiInt[0];
      aiu_axiLen     = obj.DutInfo.interfaces.axiInt.length;
   } else {
      aiu_axiInt     = obj.DutInfo.interfaces.axiInt;
      aiu_axiLen     = 1;
   }
}
%>
<%  
  var dmi_uses_sram = 0; //Not detecting CMD/MRD Skid Buffers
   if(obj.testBench == 'dmi'){
     if(Array.isArray(obj.DmiInfo[obj.Id].MemoryGeneration.tagMem) && obj.DmiInfo[obj.Id].MemoryGeneration.tagMem.length) {
       if(obj.DmiInfo[obj.Id].MemoryGeneration.tagMem[0].interfaceObjType == "sram") {
        dmi_uses_sram = 1;
       }
     }
     if(Array.isArray(obj.DmiInfo[obj.Id].MemoryGeneration.rpMem) && obj.DmiInfo[obj.Id].MemoryGeneration.rpMem.length) {
       if(obj.DmiInfo[obj.Id].MemoryGeneration.rpMem[0].interfaceObjType == "sram") {
        dmi_uses_sram = 1;
       }
     }
     if(Array.isArray(obj.DmiInfo[obj.Id].MemoryGeneration.dataMem) && obj.DmiInfo[obj.Id].MemoryGeneration.dataMem.length) {
       if(obj.DmiInfo[obj.Id].MemoryGeneration.dataMem[0].interfaceObjType == "sram") {
        dmi_uses_sram = 1;
       }
     }
     if(Array.isArray(obj.DmiInfo[obj.Id].MemoryGeneration.wrDataMem) && obj.DmiInfo[obj.Id].MemoryGeneration.wrDataMem.length) {
       if(obj.DmiInfo[obj.Id].MemoryGeneration.wrDataMem[0].interfaceObjType == "sram") {
        dmi_uses_sram = 1;
       }
     }
     if(Array.isArray(obj.DmiInfo[obj.Id].MemoryGeneration.rdDataMem) && obj.DmiInfo[obj.Id].MemoryGeneration.rdDataMem.length) {
       if(obj.DmiInfo[obj.Id].MemoryGeneration.rdDataMem[0].interfaceObjType == "sram") {
        dmi_uses_sram = 1;
       }
     }
     console.log("fault_injector_checker-- DMI uses SRAM, inserting reset code",dmi_uses_sram);
   }
%>
<% if (obj.useResiliency) { %>
module fault_injector_checker(input tb_clk, input tb_rstn);
    string output_signal;
    string report_id = "fault_injector_checker";
    // TODO: to be implemented in test
    // raise and drop objections and control the run_phase
<% if((obj.testBench == 'dii')||(obj.testBench == 'dmi')||(obj.testBench == 'dce')||(obj.testBench == 'dve')||(obj.testBench == 'chi_aiu')||(obj.testBench == 'io_aiu')) { %>
`ifndef VCS
    event raise_obj_for_resiliency_test;
    event drop_obj_for_resiliency_test;
    // Following event will end the test
    event kill_test;
`else // `ifndef VCS
    uvm_event raise_obj_for_resiliency_test;
    uvm_event drop_obj_for_resiliency_test;
    // Following event will end the test
    uvm_event kill_test;
`endif // `ifndef VCS ... `else ... 
<% } else {%>
    event raise_obj_for_resiliency_test;
    event drop_obj_for_resiliency_test;
    // Following event will end the test
    event kill_test;
<% } %>


    bit [2:0] inj_cntl;
    bit is_msg_field_inj_on = ($test$plusargs("smi_hdr_err_inj") || $test$plusargs("smi_ndp_err_inj") || $test$plusargs("smi_dp_ecc_inj")) ? 1 : 0;
    bit start_checker = 0;
    bit start_checker_ilf = 0;
    bit reset_done = 1;

    uvm_event_pool ev_pool = uvm_event_pool::get_global_pool();
    uvm_event ev_bist_reset_done = ev_pool.get("bist_reset_done");
    uvm_event ev_system_reset_done = ev_pool.get("ev_system_reset_done");
    uvm_event ev_drop_obj_for_resiliency_test = ev_pool.get("ev_drop_obj_for_resiliency_test");

 `ifdef RESILIENCY_TESTING
  <% var num_of_ncore_block_insts = 0; %>
  <% var nResiliencyDelay_json;
   if(obj.useResiliency) {
        nResiliencyDelay_json = obj.DutInfo.ResilienceInfo.nResiliencyDelay;
   }
  %>

  // Unit outputs
  // Removed signals 'dii_read_buffer_UCE', 'dii_placeholder_UCE', 'dii_cmux_UCE' in the below array
  // unit output arrays should contain only unit outputs except uncorrectable errors
  <% var hier_path_top = ['tb_top']; %>
  <% var hier_path_dut = ['tb_top.dut']; %>
  <% var obj_keys, obj_len, sig_name_; %>
  <% var unit_inst_name=[[]]; %>
  <% var checker_inst_name=[[]]; %>
  <% var func_checker_inst_name=[[]]; %>
  <% var unit_outputs_array=[[]]; %>
  <% var func_checker_inputs_array=[[]]; %>
  <% var func_checker_sram_inputs_array=[[]]; %>
  <% var smi_valid_signal_array=[[]]; %>
  <% var userPlaceInt_signal_array=[[]]; %>
  <% var unit_uecc_outputs_array, check_uecc_outputs_array; %>
  <% var unit_cecc_outputs_array, check_cecc_outputs_array; %>
  <% var force_rtl_sig_array= []; %>
  <% var ioaiu_unit_outputs_array=  [[]]; %>
  <% var check_outputs_array= [[]]; %>
  <% var ioaiu_unit_output_array_input_sig =  [[]]; %>
  <% var ioaiu_unit_output_array_out_sig =  [[]]; %>
  <% var check_outputs_array_out_sig = [[]]; %>
  <% var check_outputs_array_input_sig = [[]]; %>


/* updating generalized signals :: START */
    <%
    if(!(obj.testBench == "fsys"|| obj.testBench == "emu")){
      obj_keys = Object.keys(obj.DutInfo.interfaces);
      obj_len = obj_keys.length;

      for(var i=0; i<obj_len; i++){
        ////////////
        // CHI    //
        ////////////
        if(obj_keys[i] == "chiInt"){
          if(obj.DutInfo.interfaces.chiInt.direction == "slave"){
            if(obj.DutInfo.interfaces.chiInt._SKIP_ != true){
              sig_name_ = obj.DutInfo.interfaces.chiInt.name;
              for(var j=0; j<1;j++){
                func_checker_inputs_array[0].push(sig_name_+'rx_dat_lcrdv');
                func_checker_inputs_array[0].push(sig_name_+'rx_link_active_ack');
                func_checker_inputs_array[0].push(sig_name_+'rx_req_lcrdv');
                func_checker_inputs_array[0].push(sig_name_+'rx_rsp_lcrdv');
                func_checker_inputs_array[0].push(sig_name_+'tx_dat_flit');
                func_checker_inputs_array[0].push(sig_name_+'tx_dat_flit_pend');
                func_checker_inputs_array[0].push(sig_name_+'tx_dat_flitv');
                func_checker_inputs_array[0].push(sig_name_+'tx_link_active_req');
                func_checker_inputs_array[0].push(sig_name_+'tx_rsp_flit');
                func_checker_inputs_array[0].push(sig_name_+'tx_rsp_flit_pend');
                func_checker_inputs_array[0].push(sig_name_+'tx_rsp_flitv');
                func_checker_inputs_array[0].push(sig_name_+'tx_snp_flit');
                func_checker_inputs_array[0].push(sig_name_+'tx_snp_flit_pend');
                func_checker_inputs_array[0].push(sig_name_+'tx_snp_flitv');
              }
            }
          }
        }
        ////////////
        // AXI    //
        ////////////
        if(obj_keys[i] == "axiInt"){
          if(aiu_axiInt._SKIP_ != true){
            if(aiu_axiInt.direction == "master"){
              var sig_name_post_ = "";
              var wQos, wLock, wRegion, wProt, wAwUser, wArUser, wArVmidext;

              sig_name_ = obj.DutInfo.interfaces.axiInt.name;
              wQos      = aiu_axiInt.params.wQos    ;
              wLock     = aiu_axiInt.params.wLock   ;
              wRegion   = aiu_axiInt.params.wRegion ;
              wProt     = aiu_axiInt.params.wProt   ;
              wAwUser   = aiu_axiInt.params.wAwUser ;
              wArUser   = aiu_axiInt.params.wArUser ;
              wArVmidext = aiu_axiInt.params.wArVmidext ;

              for (var i=0; i<aiu_axiLen; i++) {
                 if(obj.testBench == "io_aiu"){
                    sig_name_ = aiu_axiInt.name;
                    sig_name_post_ = "";
                 }
                 func_checker_inputs_array[0].push(sig_name_+'ar_addr' +sig_name_post_);
                 func_checker_inputs_array[0].push(sig_name_+'ar_burst'+sig_name_post_);
                 func_checker_inputs_array[0].push(sig_name_+'ar_cache'+sig_name_post_);
                 func_checker_inputs_array[0].push(sig_name_+'ar_id'   +sig_name_post_);
                 func_checker_inputs_array[0].push(sig_name_+'ar_len'  +sig_name_post_);
                 func_checker_inputs_array[0].push(sig_name_+'ar_size' +sig_name_post_);
                 func_checker_inputs_array[0].push(sig_name_+'ar_valid'+sig_name_post_);
                 func_checker_inputs_array[0].push(sig_name_+'aw_addr' +sig_name_post_);
                 func_checker_inputs_array[0].push(sig_name_+'aw_burst'+sig_name_post_);
                 func_checker_inputs_array[0].push(sig_name_+'aw_cache'+sig_name_post_);
                 func_checker_inputs_array[0].push(sig_name_+'aw_id'   +sig_name_post_);
                 func_checker_inputs_array[0].push(sig_name_+'aw_len'  +sig_name_post_);
                 func_checker_inputs_array[0].push(sig_name_+'aw_lock' +sig_name_post_);
                 func_checker_inputs_array[0].push(sig_name_+'aw_size' +sig_name_post_);
                 func_checker_inputs_array[0].push(sig_name_+'aw_valid'+sig_name_post_);
                 func_checker_inputs_array[0].push(sig_name_+'b_ready' +sig_name_post_);
                 func_checker_inputs_array[0].push(sig_name_+'r_ready' +sig_name_post_);
                 func_checker_inputs_array[0].push(sig_name_+'w_data'  +sig_name_post_);
                 func_checker_inputs_array[0].push(sig_name_+'w_last'  +sig_name_post_);
                 func_checker_inputs_array[0].push(sig_name_+'w_strb'  +sig_name_post_);
                 func_checker_inputs_array[0].push(sig_name_+'w_valid' +sig_name_post_);
                 if(wQos){
                    func_checker_inputs_array[0].push(sig_name_+'aw_qos' +sig_name_post_ );
                    func_checker_inputs_array[0].push(sig_name_+'ar_qos' +sig_name_post_ );
                 }
                 if(wLock){
                    func_checker_inputs_array[0].push(sig_name_+'aw_lock'+sig_name_post_ );
                    func_checker_inputs_array[0].push(sig_name_+'ar_lock'+sig_name_post_ );
                 }
                 if(wProt){
                    func_checker_inputs_array[0].push(sig_name_+'aw_prot'+sig_name_post_ );
                    func_checker_inputs_array[0].push(sig_name_+'ar_prot'+sig_name_post_ );
                 }
                 if(wAwUser){
                    func_checker_inputs_array[0].push(sig_name_+'aw_user'+sig_name_post_ );
                 }
                 if(wArUser){
                    func_checker_inputs_array[0].push(sig_name_+'ar_user'+sig_name_post_ );
                 }

                 if(obj.DutInfo.hasOwnProperty("fnNativeInterface")){
                    if(obj.DutInfo.fnNativeInterface == "ACE-LITE" || obj.DutInfo.fnNativeInterface == "ACELITE-E" || obj.DutInfo.fnNativeInterface == "ACE"){
                    }
                 }
              }
            } else if(aiu_axiInt.direction == "slave"){
              var sig_name_post_ = "";

              sig_name_ = aiu_axiInt.name;
              for (var i=0; i<aiu_axiLen; i++) {
                 if(obj.testBench == "io_aiu"){
                   sig_name_ = aiu_axiInt.name;
                   sig_name_post_ = "";
                 }
                 func_checker_inputs_array[0].push(sig_name_+'ar_ready' +sig_name_post_);
                 func_checker_inputs_array[0].push(sig_name_+'aw_ready' +sig_name_post_);
                 func_checker_inputs_array[0].push(sig_name_+'b_id'     +sig_name_post_);
                 func_checker_inputs_array[0].push(sig_name_+'b_resp'   +sig_name_post_);
                 func_checker_inputs_array[0].push(sig_name_+'b_valid'  +sig_name_post_);
                 func_checker_inputs_array[0].push(sig_name_+'r_data'   +sig_name_post_);
                 func_checker_inputs_array[0].push(sig_name_+'r_id'     +sig_name_post_);
                 func_checker_inputs_array[0].push(sig_name_+'r_last'   +sig_name_post_);
                 func_checker_inputs_array[0].push(sig_name_+'r_resp'   +sig_name_post_);
                 func_checker_inputs_array[0].push(sig_name_+'r_valid'  +sig_name_post_);
                 func_checker_inputs_array[0].push(sig_name_+'w_ready'  +sig_name_post_);

                if(obj.DutInfo.hasOwnProperty("fnNativeInterface")){
//                 if(obj.DutInfo.fnNativeInterface == "ACE-LITE" || obj.DutInfo.fnNativeInterface == "ACELITE-E" || obj.DutInfo.fnNativeInterface == "ACE"){
                   if(aiu_axiInt.params.eAc){
                      func_checker_inputs_array[0].push(sig_name_+'ac_valid' +sig_name_post_);
                      func_checker_inputs_array[0].push(sig_name_+'ac_addr'  +sig_name_post_);
                      func_checker_inputs_array[0].push(sig_name_+'ac_snoop' +sig_name_post_);
                      func_checker_inputs_array[0].push(sig_name_+'ac_prot'  +sig_name_post_);
                      func_checker_inputs_array[0].push(sig_name_+'cr_ready' +sig_name_post_);
                   }
                   if(obj.DutInfo.fnNativeInterface == "ACE"){
                      func_checker_inputs_array[0].push(sig_name_+'cd_ready' +sig_name_post_);
                   }
                }
              }
            } // else if slave
          } // _SKIP_
        }
        ////////////
        // apb    //
        ////////////
        if(obj_keys[i] == "apbInt"){
          if(obj.DutInfo.interfaces.apbInt._SKIP_ != true){
            sig_name_ = obj.DutInfo.interfaces.apbInt.name;
            for(var j1=0; j1<1;j1++){
              func_checker_inputs_array[0].push(sig_name_+'pready') ;
              func_checker_inputs_array[0].push(sig_name_+'prdata') ;
              func_checker_inputs_array[0].push(sig_name_+'pslverr');
            }
          }
        }
        ////////////
        // q_     //
        ////////////
        if(obj_keys[i] == "qInt"){
          if(obj.DutInfo.interfaces.qInt._SKIP_ != true){
            sig_name_ = obj.DutInfo.interfaces.qInt.name;
            for(var j1=0; j1<1;j1++){
              func_checker_inputs_array[0].push(sig_name_+'ACTIVE') ;
              func_checker_inputs_array[0].push(sig_name_+'DENY')   ;
              func_checker_inputs_array[0].push(sig_name_+'ACCEPTn');
            }
          }
        }
        ////////////
        // SMI_TX //
        ////////////
        if(obj_keys[i] == "smiTxInt"){
          var wSmiUser, wSmiPri, nSmiDPvc;
          for(var j1=0; j1<obj.DutInfo.nSmiTx;j1++){
            if(obj.DutInfo.interfaces.smiTxInt[j1]._SKIP_ != true){
              wSmiUser    = obj.DutInfo.interfaces.smiTxInt[j1].params.wSmiUser ;
              wSmiPri     = obj.DutInfo.interfaces.smiTxInt[j1].params.wSmiPri  ;
              nSmiDPvc    = obj.DutInfo.interfaces.smiTxInt[j1].params.nSmiDPvc ;

              sig_name_ = obj.DutInfo.interfaces.smiTxInt[j1].name;
              for(var j2=0; j2<1;j2++){
                unit_outputs_array[0].push(sig_name_+'ndp_dp_present');
                unit_outputs_array[0].push(sig_name_+'ndp_msg_id')    ;
                if(wSmiPri){
                  unit_outputs_array[0].push(sig_name_+'ndp_msg_pri') ;
                }
                unit_outputs_array[0].push(sig_name_+'ndp_msg_type')  ;
                if(wSmiUser){
                  unit_outputs_array[0].push(sig_name_+'ndp_msg_user');
                }
                smi_valid_signal_array[0].push(sig_name_+'ndp_msg_valid') ;
                unit_outputs_array[0].push(sig_name_+'ndp_ndp')       ;
                unit_outputs_array[0].push(sig_name_+'ndp_ndp_len')   ;
                unit_outputs_array[0].push(sig_name_+'ndp_src_id')    ;
                unit_outputs_array[0].push(sig_name_+'ndp_targ_id')   ;
                if(nSmiDPvc){
                  unit_outputs_array[0].push(sig_name_+'dp_user')     ;
                  smi_valid_signal_array[0].push(sig_name_+'dp_valid')    ;
                  unit_outputs_array[0].push(sig_name_+'dp_last')     ;
                  unit_outputs_array[0].push(sig_name_+'dp_data')     ;
                }
              }
            }
          }
        }
        ////////////
        // SMI_RX //
        ////////////
        if(obj_keys[i] == "smiRxInt"){
          var nSmiDPvc;
          for(var j1=0; j1<obj.DutInfo.nSmiRx;j1++){
            if(obj.DutInfo.interfaces.smiRxInt[j1]._SKIP_ != true){
              nSmiDPvc = obj.DutInfo.interfaces.smiRxInt[j1].params.nSmiDPvc;
              sig_name_ = obj.DutInfo.interfaces.smiRxInt[j1].name;
              for(var j2=0; j2<1;j2++){
                unit_outputs_array[0].push(sig_name_+'ndp_msg_ready') ;
                if(nSmiDPvc){
                  unit_outputs_array[0].push(sig_name_+'dp_ready')    ;
                }
              }
            }
          }
        }

      } // obj_len
    }
    else if (obj.testBench == "dmi") {
      var dmi_unit_IOs = obj.dmi_unit_attributes.portSet;
      for (var ports in dmi_unit_IOs){
        if ((dmi_unit_IOs[ports].direction == "output") & ((dmi_unit_IOs[ports].size != 0))& !(dmi_unit_IOs[ports].name.includes("CE")) ){
          unit_outputs_array[0].push(dmi_unit_IOs[ports].name);
        }
      }
    }
    // fsys
    %>

  <% if(obj.testBench == "dii") {
       var dii_unit_outputs_array = [];
       unit_inst_name             = ['u_dii_unit'];
       checker_inst_name          = ['dup_unit'];
       func_checker_inst_name     = ['u_dii_fault_checker'];

       func_checker_inputs_array[0].push('cerr_thresh')   ;

       var dii_unit_uecc_outputs_array  = ['func_0_fault_in', 'func_1_fault_in', 'func_2_fault_in', 'func_3_fault_in', 'func_4_fault_in', 'func_5_fault_in'];
       var dii_check_uecc_outputs_array = ['check_0_fault_in', 'check_1_fault_in', 'check_2_fault_in', 'check_3_fault_in', 'check_4_fault_in', 'check_5_fault_in'];
       check_uecc_outputs_array         = [dii_check_uecc_outputs_array];
       unit_uecc_outputs_array          = [dii_unit_uecc_outputs_array];

       var dii_unit_cecc_outputs_array  = ['0_cerr_fault_in', '1_cerr_fault_in', '2_cerr_fault_in', '3_cerr_fault_in', '4_cerr_fault_in', '5_cerr_fault_in'];
       var dii_check_cecc_outputs_array = ['0_cerr_fault_in', '1_cerr_fault_in', '2_cerr_fault_in', '3_cerr_fault_in', '4_cerr_fault_in', '5_cerr_fault_in'];
       unit_cecc_outputs_array          = [dii_unit_cecc_outputs_array];
       check_cecc_outputs_array         = [dii_check_cecc_outputs_array];

     } else if(obj.testBench == "dve") {
       var dve_unit_outputs_array = [];
       unit_inst_name             = ['unit'];
       checker_inst_name          = ['dup_unit'];
       func_checker_inst_name     = ['u_fault_checker'];

       func_checker_inputs_array[0].push('cerr_thresh');

       var dve_unit_uecc_outputs_array  = ['func_0_fault_in', 'func_1_fault_in', 'func_2_fault_in', 'func_3_fault_in', 'func_4_fault_in'];
       var dve_check_uecc_outputs_array = ['check_0_fault_in', 'check_1_fault_in', 'check_2_fault_in', 'check_3_fault_in', 'check_4_fault_in'];
       unit_uecc_outputs_array          = [dve_unit_uecc_outputs_array];
       check_uecc_outputs_array         = [dve_check_uecc_outputs_array];

       var dve_unit_cecc_outputs_array  = ['0_cerr_fault_in', '1_cerr_fault_in', '2_cerr_fault_in', '3_cerr_fault_in', '4_cerr_fault_in'];
       var dve_check_cecc_outputs_array = ['0_cerr_fault_in', '1_cerr_fault_in', '2_cerr_fault_in', '3_cerr_fault_in', '4_cerr_fault_in'];
       unit_cecc_outputs_array          = [dve_unit_cecc_outputs_array];
       check_cecc_outputs_array         = [dve_check_cecc_outputs_array];
       force_rtl_sig_array              = ['pma_busy'];

     } else if(obj.testBench == "dmi") {
       var dmi_unit_outputs_array = [];
       smi_valid_signal_array     = [[]];
       unit_inst_name             = ['dmi_unit'];
       checker_inst_name          = ['dup_unit'];
       func_checker_inst_name     = ['u_dmi_fault_checker'];

       var dmi_unit_uecc_outputs_array  = [];
       var dmi_check_uecc_outputs_array = [];
       var dmi_unit_cecc_outputs_array  = [];
       var dmi_check_cecc_outputs_array = [];

       for (els in obj.dmi_fault_checker_attributes.portSet) {
         if(obj.dmi_fault_checker_attributes.portSet[els].direction == "input" && 
            !(obj.dmi_fault_checker_attributes.portSet[els].name.includes("clk") || obj.dmi_fault_checker_attributes.portSet[els].name.includes("reset_n"))  &&
             (obj.dmi_fault_checker_attributes.portSet[els].name.includes("func_") || obj.dmi_fault_checker_attributes.portSet[els].name.includes("check_")) &&
            !(obj.dmi_fault_checker_attributes.portSet[els].name.includes("fault_in")) &&
            !(obj.dmi_fault_checker_attributes.portSet[els].name.includes("sb_mem"))&&
            !(obj.dmi_fault_checker_attributes.portSet[els].name.includes("TagMem"))&&
            !(obj.dmi_fault_checker_attributes.portSet[els].name.includes("DataMem")) 
           ){
           //Replace func_ and check_ and make sure it doesn't exist in the array already
           var sig_name0 = obj.dmi_fault_checker_attributes.portSet[els].name.replace("func_","");
           var sig_name1 = sig_name0.replace("check_","");
           var match_flg = 0;
           for(els2 in func_checker_inputs_array[0]){
             if(sig_name1 == func_checker_inputs_array[0][els2]) {
               match_flg =1;
             }
           }
           if(!match_flg) {
             func_checker_inputs_array[0].push(sig_name1)
           }
         }
         if(obj.dmi_fault_checker_attributes.portSet[els].direction == "input" &&
            (obj.dmi_fault_checker_attributes.portSet[els].name.includes("sb_mem") ||
            obj.dmi_fault_checker_attributes.portSet[els].name.includes("TagMem") ||
            obj.dmi_fault_checker_attributes.portSet[els].name.includes("DataMem") 
            )
           ) {
           var sig_name0 = obj.dmi_fault_checker_attributes.portSet[els].name.replace("func_","");
           var sig_name1 = sig_name0.replace("check_","");
           var match_flg = 0;
           for(els2 in func_checker_sram_inputs_array[0]){
             if(sig_name1 == func_checker_sram_inputs_array[els2]) {
               match_flg =1;
             }
           }
           if(!match_flg) {
             func_checker_sram_inputs_array[0].push(sig_name1)
           }
 
         }
         if(!(obj.dmi_fault_checker_attributes.portSet[els].name.includes("clk") 
              || obj.dmi_fault_checker_attributes.portSet[els].name.includes("reset_n")
             )){
           if(obj.dmi_fault_checker_attributes.portSet[els].name.includes("func") 
              & obj.dmi_fault_checker_attributes.portSet[els].name.includes("fault_in")
              & !obj.dmi_fault_checker_attributes.portSet[els].name.includes("cerr")
             ) 
           {
              dmi_unit_uecc_outputs_array.push(obj.dmi_fault_checker_attributes.portSet[els].name)
           } 
           else if (obj.dmi_fault_checker_attributes.portSet[els].name.includes("check") 
                    & obj.dmi_fault_checker_attributes.portSet[els].name.includes("fault_in")
                    & !obj.dmi_fault_checker_attributes.portSet[els].name.includes("cerr")
                   ) 
           {
              dmi_check_uecc_outputs_array.push(obj.dmi_fault_checker_attributes.portSet[els].name);
           }
           else if (obj.dmi_fault_checker_attributes.portSet[els].name.includes("check") 
                    & obj.dmi_fault_checker_attributes.portSet[els].name.includes("fault_in")
                    & obj.dmi_fault_checker_attributes.portSet[els].name.includes("cerr")
                   )
           {
              dmi_unit_cecc_outputs_array.push(obj.dmi_fault_checker_attributes.portSet[els].name.slice(6));
              dmi_check_cecc_outputs_array.push(obj.dmi_fault_checker_attributes.portSet[els].name.slice(6));
           }
         }
       }
       unit_uecc_outputs_array          = [dmi_unit_uecc_outputs_array];
       check_uecc_outputs_array         = [dmi_check_uecc_outputs_array];
       unit_cecc_outputs_array          = [dmi_unit_cecc_outputs_array];
       check_cecc_outputs_array         = [dmi_check_cecc_outputs_array];
     } else if(obj.testBench == "io_aiu") {
        var dut_sizePhArray;
        var dut_userPlaceInt = [];
        let isArray = Array.isArray(obj.DutInfo.interfaces.userPlaceInt);
        if (isArray) {
            dut_sizePhArray  = obj.DutInfo.interfaces.userPlaceInt.length;
            dut_userPlaceInt = new Array(dut_sizePhArray);
            for (var i=0; i<dut_sizePhArray; i++) {
                dut_userPlaceInt[i] = obj.DutInfo.interfaces.userPlaceInt[i];
            }
        } else {
            dut_sizePhArray  = 1;
            dut_userPlaceInt = new Array(1);
            dut_userPlaceInt[0] = obj.DutInfo.interfaces.userPlaceInt;
        }    

       var ioaiu_unit_outputs_array = [];
       //func_checker_inputs_array    = [[]];
       smi_valid_signal_array       = [[]];
       unit_inst_name               = ['ioaiu_core_wrapper'];
       checker_inst_name            = ['dup_unit'];
       func_checker_inst_name       = ['dup_checker'];

       var axiIntLen = (Array.isArray(aiu_axiInt) ? aiu_axiInt.length: 1);
       for (var i=0; i<axiIntLen; i++) {
          func_checker_inputs_array[0].push('c' + i + '_w_od_we');
          func_checker_inputs_array[0].push('c' + i + '_w_od_waddr');
          func_checker_inputs_array[0].push('c' + i + '_w_od_wdata');
          func_checker_inputs_array[0].push('c' + i + '_w_od_wecc');
          func_checker_inputs_array[0].push('c' + i + '_w_od_re');
          func_checker_inputs_array[0].push('c' + i + '_w_od_raddr');
       }
//     func_checker_inputs_array[0].push('w_cr_fc');
       func_checker_inputs_array[0].push('w_threshold');

       for (var idx=0; idx<dut_sizePhArray; idx++) {
       if(dut_userPlaceInt[idx]._SKIP_ != true){
         if(dut_userPlaceInt[idx].params.wOut != 0){
           var userPlaceInt_name = dut_userPlaceInt[idx].name;
           var out_name = '';
           dut_userPlaceInt[idx].synonyms.out.forEach(function outways(item,index){
           out_name = item.name;
           userPlaceInt_signal_array[0].push(userPlaceInt_name + out_name);
           })
         }
       }
       }
                                           
       var ioaiu_unit_uecc_outputs_array  = ['w_ufault'];
       var ioaiu_check_uecc_outputs_array = ['w_delay_ufault'];
       unit_uecc_outputs_array            = [ioaiu_unit_uecc_outputs_array];
       check_uecc_outputs_array           = [ioaiu_check_uecc_outputs_array];
       var NSMIIFRX = obj.DutInfo.nSmiTx;

  
//var ioaiu_unit_output_val_array = ['c0_w_bvalid_my','c0_w_rvalid_my','c0_w_acvalid_my','c0_w_awready_my','c0_w_arready_my','c0_w_crready_my','c0_w_cdready_my','dtw_dbg_req_ready','dtw_dbg_rsp_valid','c0_w_wready_my'];
//var ioaiu_unit_output_rdy_array = ['c0_t_bready_my','c0_t_rready_my','c0_t_acready_my','c0_t_awvalid_my','c0_t_arvalid_my','c0_t_crvalid_my','c0_t_cdvalid_my','dtw_dbg_req_valid','dtw_dbg_rsp_ready','c0_t_wvalid_my'];

var ioaiu_unit_output_val_array = [aiu_axiInt.name+'b_valid',aiu_axiInt.name+'r_valid',aiu_axiInt.name+'aw_ready',aiu_axiInt.name+'ar_ready','dtw_dbg_req_ready','dtw_dbg_rsp_valid',aiu_axiInt.name+'w_ready'];
var ioaiu_unit_output_rdy_array = [aiu_axiInt.name+'b_ready',aiu_axiInt.name+'r_ready',aiu_axiInt.name+'aw_valid',aiu_axiInt.name+'ar_valid','dtw_dbg_req_valid','dtw_dbg_rsp_ready',aiu_axiInt.name+'w_valid'];

if (aiu_axiInt.name == "ace5_slv" || aiu_axiInt.name == "ace_slv" || aiu_axiInt.name == "ace_lite_slv" || aiu_axiInt.name == "ace5_lite_slv") {
ioaiu_unit_output_val_array.push(aiu_axiInt.name+'ac_valid');
ioaiu_unit_output_val_array.push(aiu_axiInt.name+'cr_ready');

ioaiu_unit_output_rdy_array.push(aiu_axiInt.name+'ac_ready');
ioaiu_unit_output_rdy_array.push(aiu_axiInt.name+'cr_valid');

  if (aiu_axiInt.name == "ace5_slv" || aiu_axiInt.name == "ace_slv") {
ioaiu_unit_output_val_array.push(aiu_axiInt.name+'cd_ready');
ioaiu_unit_output_rdy_array.push(aiu_axiInt.name+'cd_valid');
  }
}

//var val_check_outputs_array = ['w_delay_c0_w_bvalid_my','w_delay_c0_w_rvalid_my','w_delay_c0_w_acvalid_my','w_delay_c0_w_awready_my','w_delay_c0_w_arready_my','w_delay_c0_w_crready_my','w_delay_c0_w_cdready_my','w_delay_dtw_dbg_req_ready','w_delay_dtw_dbg_rsp_valid','w_delay_c0_w_wready_my'];

//var rdy_check_outputs_array = ['w_delay_c0_t_bready_my','w_delay_c0_t_rready_my','w_delay_c0_t_acready_my','w_delay_c0_t_awvalid_my','w_delay_c0_t_arvalid_my','w_delay_c0_t_crvalid_my','w_delay_c0_t_cdvalid_my','w_delay_dtw_dbg_req_valid','w_delay_dtw_dbg_rsp_ready','w_delay_c0_t_wvalid_my'];

var val_check_outputs_array = ['w_delay_'+aiu_axiInt.name+'b_valid','w_delay_'+aiu_axiInt.name+'r_valid','w_delay_'+aiu_axiInt.name+'aw_ready','w_delay_'+aiu_axiInt.name+'ar_ready','w_delay_dtw_dbg_req_ready','w_delay_dtw_dbg_rsp_valid','w_delay_'+aiu_axiInt.name+'w_ready'];

var rdy_check_outputs_array = ['w_delay_'+aiu_axiInt.name+'b_ready','w_delay_'+aiu_axiInt.name+'r_ready','w_delay_'+aiu_axiInt.name+'aw_valid','w_delay_'+aiu_axiInt.name+'ar_valid','w_delay_dtw_dbg_req_valid','w_delay_dtw_dbg_rsp_ready','w_delay_'+aiu_axiInt.name+'w_valid'];

if (aiu_axiInt.name == "ace5_slv" || aiu_axiInt.name == "ace_slv" || aiu_axiInt.name == "ace_lite_slv" || aiu_axiInt.name == "ace5_lite_slv") {
val_check_outputs_array.push('w_delay_'+aiu_axiInt.name+'ac_valid');
val_check_outputs_array.push('w_delay_'+aiu_axiInt.name+'cr_ready');

rdy_check_outputs_array.push('w_delay_'+aiu_axiInt.name+'ac_ready');
rdy_check_outputs_array.push('w_delay_'+aiu_axiInt.name+'cr_valid');

  if (aiu_axiInt.name == "ace5_slv" || aiu_axiInt.name == "ace_slv") {
val_check_outputs_array.push('w_delay_'+aiu_axiInt.name+'cd_ready');
rdy_check_outputs_array.push('w_delay_'+aiu_axiInt.name+'cd_valid');
  }
}

ioaiu_unit_output_array_out_sig = [ioaiu_unit_output_val_array];
check_outputs_array_out_sig     = [val_check_outputs_array];
ioaiu_unit_output_array_input_sig = [ioaiu_unit_output_rdy_array];
check_outputs_array_input_sig     = [rdy_check_outputs_array];

                  for(var i=0; i<NSMIIFRX; i++){
                      if(obj.DutInfo.interfaces.smiTxInt[i].params.nSmiDPvc){
                      ioaiu_unit_output_array_out_sig[0].push('smi_tx'+i+'_ndp_msg_valid');
                      ioaiu_unit_output_array_input_sig[0].push('smi_tx'+i+'_ndp_msg_ready');
                      ioaiu_unit_output_array_out_sig[0].push('smi_tx'+i+'_dp_valid');
                      ioaiu_unit_output_array_input_sig[0].push('smi_tx'+i+'_dp_ready');
                      ioaiu_unit_output_array_out_sig[0].push('smi_rx'+i+'_ndp_msg_ready');
                      ioaiu_unit_output_array_input_sig[0].push('smi_rx'+i+'_ndp_msg_valid');
                      ioaiu_unit_output_array_out_sig[0].push('smi_rx'+i+'_dp_ready');
                      ioaiu_unit_output_array_input_sig[0].push('smi_rx'+i+'_dp_valid');

                      check_outputs_array_out_sig[0].push('w_delay_smi_tx'+i+'_ndp_msg_valid');
                      check_outputs_array_input_sig[0].push('w_delay_smi_tx'+i+'_ndp_msg_ready');
                      check_outputs_array_out_sig[0].push('w_delay_smi_tx'+i+'_dp_valid');
                      check_outputs_array_input_sig[0].push('w_delay_smi_tx'+i+'_dp_ready');
                      check_outputs_array_out_sig[0].push('w_delay_smi_rx'+i+'_ndp_msg_ready');
                      check_outputs_array_input_sig[0].push('w_delay_smi_rx'+i+'_ndp_msg_valid');
                      check_outputs_array_out_sig[0].push('w_delay_smi_rx'+i+'_dp_ready');
                      check_outputs_array_input_sig[0].push('w_delay_smi_rx'+i+'_dp_valid');

                      }else {
                      ioaiu_unit_output_array_out_sig[0].push('smi_tx'+i+'_ndp_msg_valid');
                      ioaiu_unit_output_array_input_sig[0].push('smi_tx'+i+'_ndp_msg_ready');
                      ioaiu_unit_output_array_out_sig[0].push('smi_rx'+i+'_ndp_msg_ready');
                      ioaiu_unit_output_array_input_sig[0].push('smi_rx'+i+'_ndp_msg_valid');

                      check_outputs_array_out_sig[0].push('w_delay_smi_tx'+i+'_ndp_msg_valid');
                      check_outputs_array_input_sig[0].push('w_delay_smi_tx'+i+'_ndp_msg_ready');
                      check_outputs_array_out_sig[0].push('w_delay_smi_rx'+i+'_ndp_msg_ready');
                      check_outputs_array_input_sig[0].push('w_delay_smi_rx'+i+'_ndp_msg_valid');

                     }	 

                  }



//       var ioaiu_unit_outputs_array  = ['w_cfault','irq_c','w_cr_fc','c0_w_bid_my','c0_w_bresp_my','c0_w_buser_my','c0_t_btrack_my','c0_w_rid_my','c0_w_rdata_my','c0_w_rresp_my','c0_w_rlast_my','c0_w_ruser_my','c0_t_rtrack_my','c0_w_acaddr_my','c0_w_acsnoop_my','c0_w_acprot_my','c0_w_actrack_my','c0_w_acvmidext_my','c0_w_od_we','c0_w_od_waddr','c0_w_od_wecc','c0_w_od_re','c0_w_od_raddr','apb_prdata','apb_pslverr','csr_trace_CCTRLR_ndn0Tx_out','csr_trace_CCTRLR_ndn0Rx_out','csr_trace_CCTRLR_ndn1Tx_out','csr_trace_CCTRLR_ndn1Rx_out','csr_trace_CCTRLR_ndn2Tx_out','csr_trace_CCTRLR_ndn2Rx_out','csr_trace_CCTRLR_dn0Tx_out','csr_trace_CCTRLR_dn0Rx_out','csr_trace_CCTRLR_gain_out','csr_trace_CCTRLR_inc_out','dtw_dbg_rsp_m_prot','dtw_dbg_rsp_rl','dtw_dbg_rsp_cm_status','dtw_dbg_rsp_r_message_id','dtw_dbg_rsp_tm','dtw_dbg_rsp_target_id','dtw_dbg_rsp_initiator_id','dtw_dbg_rsp_cm_type','dtw_dbg_rsp_message_id','dtw_dbg_rsp_h_prot','irq_uc'];

//       var ioaiu_unit_outputs_array  = ['w_cfault','irq_c','w_cr_fc',aiu_axiInt.name+'b_id',aiu_axiInt.name+'b_resp',aiu_axiInt.name+'r_id',aiu_axiInt.name+'r_data',aiu_axiInt.name+'r_resp',aiu_axiInt.name+'r_last','c0_w_od_we','c0_w_od_waddr','c0_w_od_wecc','c0_w_od_re','c0_w_od_raddr','apb_prdata','apb_pslverr','csr_trace_CCTRLR_ndn0Tx_out','csr_trace_CCTRLR_ndn0Rx_out','csr_trace_CCTRLR_ndn1Tx_out','csr_trace_CCTRLR_ndn1Rx_out','csr_trace_CCTRLR_ndn2Tx_out','csr_trace_CCTRLR_ndn2Rx_out','csr_trace_CCTRLR_dn0Tx_out','csr_trace_CCTRLR_dn0Rx_out','csr_trace_CCTRLR_gain_out','csr_trace_CCTRLR_inc_out','dtw_dbg_rsp_m_prot','dtw_dbg_rsp_rl','dtw_dbg_rsp_cm_status','dtw_dbg_rsp_r_message_id','dtw_dbg_rsp_tm','dtw_dbg_rsp_target_id','dtw_dbg_rsp_initiator_id','dtw_dbg_rsp_cm_type','dtw_dbg_rsp_message_id','dtw_dbg_rsp_h_prot','irq_uc'];

       var ioaiu_unit_outputs_array  = ['w_cfault','irq_c',aiu_axiInt.name+'b_id',aiu_axiInt.name+'b_resp',aiu_axiInt.name+'r_id',aiu_axiInt.name+'r_data',aiu_axiInt.name+'r_resp',aiu_axiInt.name+'r_last','c0_w_od_we','c0_w_od_waddr','c0_w_od_wecc','c0_w_od_re','c0_w_od_raddr','apb_prdata','apb_pslverr','csr_trace_CCTRLR_ndn0Tx_out','csr_trace_CCTRLR_ndn0Rx_out','csr_trace_CCTRLR_ndn1Tx_out','csr_trace_CCTRLR_ndn1Rx_out','csr_trace_CCTRLR_ndn2Tx_out','csr_trace_CCTRLR_ndn2Rx_out','csr_trace_CCTRLR_dn0Tx_out','csr_trace_CCTRLR_dn0Rx_out','csr_trace_CCTRLR_gain_out','csr_trace_CCTRLR_inc_out','dtw_dbg_rsp_m_prot','dtw_dbg_rsp_rl','dtw_dbg_rsp_cm_status','dtw_dbg_rsp_r_message_id','dtw_dbg_rsp_tm','dtw_dbg_rsp_target_id','dtw_dbg_rsp_initiator_id','dtw_dbg_rsp_cm_type','dtw_dbg_rsp_message_id','dtw_dbg_rsp_h_prot','irq_uc'];

                if(obj.DutInfo.hasOwnProperty("fnNativeInterface")){
//                 if(obj.DutInfo.fnNativeInterface == "ACE-LITE" || obj.DutInfo.fnNativeInterface == "ACELITE-E" || obj.DutInfo.fnNativeInterface == "ACE"){
                   if(aiu_axiInt.params.eAc){
ioaiu_unit_outputs_array.push(aiu_axiInt.name+'ac_addr');
ioaiu_unit_outputs_array.push(aiu_axiInt.name+'ac_snoop');
ioaiu_unit_outputs_array.push(aiu_axiInt.name+'ac_prot');
if (wArVmidext==4) {
ioaiu_unit_outputs_array.push(aiu_axiInt.name+'ac_vmidext');
}
                   }
                }

                if (wArUser) {
ioaiu_unit_outputs_array.push(aiu_axiInt.name+'r_user');
                }

                if (wAwUser) {
ioaiu_unit_outputs_array.push(aiu_axiInt.name+'b_user');
                }

 
            ioaiu_unit_outputs_array            = [ioaiu_unit_outputs_array];

            for(var i=0; i<NSMIIFRX; i++){
                      if(obj.DutInfo.interfaces.smiTxInt[i].params.nSmiDPvc){
                      ioaiu_unit_outputs_array[0].push('smi_tx'+i+'_ndp_targ_id');
                      ioaiu_unit_outputs_array[0].push('smi_tx'+i+'_ndp_src_id');
                      ioaiu_unit_outputs_array[0].push('smi_tx'+i+'_ndp_ndp_len');
                      ioaiu_unit_outputs_array[0].push('smi_tx'+i+'_ndp_msg_user'); 
                      ioaiu_unit_outputs_array[0].push('smi_tx'+i+'_ndp_msg_type');
                      ioaiu_unit_outputs_array[0].push('smi_tx'+i+'_ndp_dp_present'); 
                      ioaiu_unit_outputs_array[0].push('smi_tx'+i+'_ndp_msg_id');
                      ioaiu_unit_outputs_array[0].push('smi_tx'+i+'_dp_user');
                      ioaiu_unit_outputs_array[0].push('smi_tx'+i+'_dp_last');
                      ioaiu_unit_outputs_array[0].push('smi_tx'+i+'_dp_data');  
                      }else {
                     ioaiu_unit_outputs_array[0].push('smi_tx'+i+'_ndp_targ_id');
                     ioaiu_unit_outputs_array[0].push('smi_tx'+i+'_ndp_src_id');
                     ioaiu_unit_outputs_array[0].push('smi_tx'+i+'_ndp_ndp_len');
                     ioaiu_unit_outputs_array[0].push('smi_tx'+i+'_ndp_msg_user'); 
                     ioaiu_unit_outputs_array[0].push('smi_tx'+i+'_ndp_msg_type');
                     ioaiu_unit_outputs_array[0].push('smi_tx'+i+'_ndp_dp_present');
                     ioaiu_unit_outputs_array[0].push('smi_tx'+i+'_ndp_msg_id');
                     }	 

                  }


//       var ioaiu_check_outputs_array = ['w_delay_cfault','w_delay_irq_c','w_delay_w_cr_fc','w_delay_c0_w_bid_my','w_delay_c0_w_bresp_my','w_delay_c0_w_buser_my','w_delay_c0_t_btrack_my','w_delay_c0_w_rid_my','w_delay_c0_w_rdata_my','w_delay_c0_w_rresp_my','w_delay_c0_w_rlast_my','w_delay_c0_w_ruser_my','w_delay_c0_t_rtrack_my','w_delay_c0_w_acaddr_my','w_delay_c0_w_acsnoop_my','w_delay_c0_w_acprot_my','w_delay_c0_w_actrack_my','w_delay_c0_w_acvmidext_my','w_delay_c0_w_od_we','w_delay_c0_w_od_waddr','w_delay_c0_w_od_wecc','w_delay_c0_w_od_re','w_delay_c0_w_od_raddr','w_delay_apb_prdata','w_delay_apb_pslverr','w_delay_csr_trace_CCTRLR_ndn0Tx_out','w_delay_csr_trace_CCTRLR_ndn0Rx_out','w_delay_csr_trace_CCTRLR_ndn1Tx_out','w_delay_csr_trace_CCTRLR_ndn1Rx_out','w_delay_csr_trace_CCTRLR_ndn2Tx_out','w_delay_csr_trace_CCTRLR_ndn2Rx_out','w_delay_csr_trace_CCTRLR_dn0Tx_out','w_delay_csr_trace_CCTRLR_dn0Rx_out','w_delay_csr_trace_CCTRLR_gain_out','w_delay_csr_trace_CCTRLR_inc_out','w_delay_dtw_dbg_rsp_m_prot','w_delay_dtw_dbg_rsp_rl','w_delay_dtw_dbg_rsp_cm_status','w_delay_dtw_dbg_rsp_r_message_id','w_delay_dtw_dbg_rsp_tm','w_delay_dtw_dbg_rsp_target_id','w_delay_dtw_dbg_rsp_initiator_id','w_delay_dtw_dbg_rsp_cm_type','w_delay_dtw_dbg_rsp_message_id','w_delay_dtw_dbg_rsp_h_prot','w_delay_irq_uc'];

//       var ioaiu_check_outputs_array = ['w_delay_cfault','w_delay_irq_c','w_delay_w_cr_fc','w_delay_'+aiu_axiInt.name+'b_id','w_delay_'+aiu_axiInt.name+'b_resp','w_delay_'+aiu_axiInt.name+'r_id','w_delay_'+aiu_axiInt.name+'r_data','w_delay_'+aiu_axiInt.name+'r_resp','w_delay_'+aiu_axiInt.name+'r_last','w_delay_c0_w_od_we','w_delay_c0_w_od_waddr','w_delay_c0_w_od_wecc','w_delay_c0_w_od_re','w_delay_c0_w_od_raddr','w_delay_apb_prdata','w_delay_apb_pslverr','w_delay_csr_trace_CCTRLR_ndn0Tx_out','w_delay_csr_trace_CCTRLR_ndn0Rx_out','w_delay_csr_trace_CCTRLR_ndn1Tx_out','w_delay_csr_trace_CCTRLR_ndn1Rx_out','w_delay_csr_trace_CCTRLR_ndn2Tx_out','w_delay_csr_trace_CCTRLR_ndn2Rx_out','w_delay_csr_trace_CCTRLR_dn0Tx_out','w_delay_csr_trace_CCTRLR_dn0Rx_out','w_delay_csr_trace_CCTRLR_gain_out','w_delay_csr_trace_CCTRLR_inc_out','w_delay_dtw_dbg_rsp_m_prot','w_delay_dtw_dbg_rsp_rl','w_delay_dtw_dbg_rsp_cm_status','w_delay_dtw_dbg_rsp_r_message_id','w_delay_dtw_dbg_rsp_tm','w_delay_dtw_dbg_rsp_target_id','w_delay_dtw_dbg_rsp_initiator_id','w_delay_dtw_dbg_rsp_cm_type','w_delay_dtw_dbg_rsp_message_id','w_delay_dtw_dbg_rsp_h_prot','w_delay_irq_uc'];

       var ioaiu_check_outputs_array = ['w_delay_cfault','w_delay_irq_c','w_delay_'+aiu_axiInt.name+'b_id','w_delay_'+aiu_axiInt.name+'b_resp','w_delay_'+aiu_axiInt.name+'r_id','w_delay_'+aiu_axiInt.name+'r_data','w_delay_'+aiu_axiInt.name+'r_resp','w_delay_'+aiu_axiInt.name+'r_last','w_delay_c0_w_od_we','w_delay_c0_w_od_waddr','w_delay_c0_w_od_wecc','w_delay_c0_w_od_re','w_delay_c0_w_od_raddr','w_delay_apb_prdata','w_delay_apb_pslverr','w_delay_csr_trace_CCTRLR_ndn0Tx_out','w_delay_csr_trace_CCTRLR_ndn0Rx_out','w_delay_csr_trace_CCTRLR_ndn1Tx_out','w_delay_csr_trace_CCTRLR_ndn1Rx_out','w_delay_csr_trace_CCTRLR_ndn2Tx_out','w_delay_csr_trace_CCTRLR_ndn2Rx_out','w_delay_csr_trace_CCTRLR_dn0Tx_out','w_delay_csr_trace_CCTRLR_dn0Rx_out','w_delay_csr_trace_CCTRLR_gain_out','w_delay_csr_trace_CCTRLR_inc_out','w_delay_dtw_dbg_rsp_m_prot','w_delay_dtw_dbg_rsp_rl','w_delay_dtw_dbg_rsp_cm_status','w_delay_dtw_dbg_rsp_r_message_id','w_delay_dtw_dbg_rsp_tm','w_delay_dtw_dbg_rsp_target_id','w_delay_dtw_dbg_rsp_initiator_id','w_delay_dtw_dbg_rsp_cm_type','w_delay_dtw_dbg_rsp_message_id','w_delay_dtw_dbg_rsp_h_prot','w_delay_irq_uc'];

                if(obj.DutInfo.hasOwnProperty("fnNativeInterface")){
//                 if(obj.DutInfo.fnNativeInterface == "ACE-LITE" || obj.DutInfo.fnNativeInterface == "ACELITE-E" || obj.DutInfo.fnNativeInterface == "ACE"){
                   if(aiu_axiInt.params.eAc){
ioaiu_check_outputs_array.push('w_delay_'+aiu_axiInt.name+'ac_addr');
ioaiu_check_outputs_array.push('w_delay_'+aiu_axiInt.name+'ac_snoop');
ioaiu_check_outputs_array.push('w_delay_'+aiu_axiInt.name+'ac_prot');
if (wArVmidext==4) {
ioaiu_check_outputs_array.push('w_delay_'+aiu_axiInt.name+'ac_vmidext');
}
                   }
                }
      
                if (wArUser) {
ioaiu_unit_outputs_array.push('w_delay_'+aiu_axiInt.name+'r_user');
                }

                if (wAwUser) {
ioaiu_unit_outputs_array.push('w_delay_'+aiu_axiInt.name+'b_user');
                }

 check_outputs_array           = [ioaiu_check_outputs_array];

 for(var i=0; i<NSMIIFRX; i++){
                      if(obj.DutInfo.interfaces.smiTxInt[i].params.nSmiDPvc){
                       check_outputs_array[0].push('w_delay_smi_tx'+i+'_ndp_targ_id');
                       check_outputs_array[0].push('w_delay_smi_tx'+i+'_ndp_src_id');
                       check_outputs_array[0].push('w_delay_smi_tx'+i+'_ndp_ndp_len');
                       check_outputs_array[0].push('w_delay_smi_tx'+i+'_ndp_msg_user'); 
                       check_outputs_array[0].push('w_delay_smi_tx'+i+'_ndp_msg_type');
                       check_outputs_array[0].push('w_delay_smi_tx'+i+'_ndp_dp_present'); 
                       check_outputs_array[0].push('w_delay_smi_tx'+i+'_ndp_msg_id');
                       check_outputs_array[0].push('w_delay_smi_tx'+i+'_dp_user');
                       check_outputs_array[0].push('w_delay_smi_tx'+i+'_dp_last');
                       check_outputs_array[0].push('w_delay_smi_tx'+i+'_dp_data');  
                      }else {
                      check_outputs_array[0].push('w_delay_smi_tx'+i+'_ndp_targ_id');
                      check_outputs_array[0].push('w_delay_smi_tx'+i+'_ndp_src_id');
                      check_outputs_array[0].push('w_delay_smi_tx'+i+'_ndp_ndp_len');
                      check_outputs_array[0].push('w_delay_smi_tx'+i+'_ndp_msg_user'); 
                      check_outputs_array[0].push('w_delay_smi_tx'+i+'_ndp_msg_type');
                      check_outputs_array[0].push('w_delay_smi_tx'+i+'_ndp_dp_present'); 
                      check_outputs_array[0].push('w_delay_smi_tx'+i+'_ndp_msg_id');
                      }	 
                }



       var ioaiu_unit_cecc_outputs_array  = ['0_cerr_fault_in', '1_cerr_fault_in', '2_cerr_fault_in', '3_cerr_fault_in', '4_cerr_fault_in', '5_cerr_fault_in', '6_cerr_fault_in', '7_cerr_fault_in', '8_cerr_fault_in'];
       var ioaiu_check_cecc_outputs_array = ['0_cerr_fault_in', '1_cerr_fault_in', '2_cerr_fault_in', '3_cerr_fault_in', '4_cerr_fault_in', '5_cerr_fault_in', '6_cerr_fault_in', '7_cerr_fault_in', '8_cerr_fault_in'];
       unit_cecc_outputs_array            = [ioaiu_unit_cecc_outputs_array];
       check_cecc_outputs_array           = [ioaiu_check_cecc_outputs_array];

     } else if(obj.testBench == "dce") {
       var dce_unit_outputs_array = [];
       smi_valid_signal_array     = [[]];
       unit_inst_name             = ['dce_func_unit'];
       checker_inst_name          = ['dup_unit'];
       func_checker_inst_name     = ['u_dce_fault_checker'];

       obj.DutInfo.SnoopFilterInfo.forEach(function sfways(item,index){
         for(var i=0; i<item.nWays; i++){
           func_checker_inputs_array[0].push('w_' +'f'+index +'m'+i +'_ce');
           func_checker_inputs_array[0].push('w_' +'f'+index +'m'+i +'_we');
           func_checker_inputs_array[0].push('w_' +'f'+index +'m'+i +'_addr');
           func_checker_inputs_array[0].push('w_' +'f'+index +'m'+i +'_biten');
           func_checker_inputs_array[0].push('w_' +'f'+index +'m'+i +'_wdata');
         }
       })

       func_checker_inputs_array[0].push('cerr_threshold');
       var dce_unit_uecc_outputs_array  = ['func_0_fault_in', 'func_1_fault_in', 'func_2_fault_in', 'func_3_fault_in', 'func_4_fault_in', 'func_5_fault_in', 'func_6_fault_in'];
       var dce_check_uecc_outputs_array = ['check_0_fault_in', 'check_1_fault_in', 'check_2_fault_in', 'check_3_fault_in', 'check_4_fault_in', 'check_5_fault_in', 'check_6_fault_in'];
       unit_uecc_outputs_array          = [dce_unit_uecc_outputs_array];
       check_uecc_outputs_array         = [dce_check_uecc_outputs_array];

       var dce_unit_cecc_outputs_array  = ['0_cerr_fault_in', '1_cerr_fault_in', '2_cerr_fault_in', '3_cerr_fault_in', '4_cerr_fault_in', '5_cerr_fault_in', '6_cerr_fault_in'];
       var dce_check_cecc_outputs_array = ['0_cerr_fault_in', '1_cerr_fault_in', '2_cerr_fault_in', '3_cerr_fault_in', '4_cerr_fault_in', '5_cerr_fault_in', '6_cerr_fault_in'];
       unit_cecc_outputs_array          = [dce_unit_cecc_outputs_array];
       check_cecc_outputs_array         = [dce_check_cecc_outputs_array];

     } else if(obj.testBench == "chi_aiu") {
       var chi_aiu_unit_outputs_array = [];
       unit_inst_name                 = ['unit'];
       checker_inst_name              = ['dup_unit'];
       func_checker_inst_name         = ['u_chi_aiu_fault_checker'];

       obj_keys = Object.keys(obj.DutInfo.interfaces);
       obj_len = obj_keys.length;
       for(var i=0; i<obj_len; i++){
       }

       func_checker_inputs_array[0].push('cerr_threshold');
       var chi_aiu_unit_uecc_outputs_array  = ['func_0_fault_in', 'func_1_fault_in', 'func_2_fault_in', 'func_3_fault_in', 'func_4_fault_in', 'func_5_fault_in', 'func_6_fault_in', 'func_7_fault_in'];
       var chi_aiu_check_uecc_outputs_array = ['check_0_fault_in', 'check_1_fault_in', 'check_2_fault_in', 'check_3_fault_in', 'check_4_fault_in', 'check_5_fault_in', 'check_6_fault_in', 'check_7_fault_in'];
       unit_uecc_outputs_array              = [chi_aiu_unit_uecc_outputs_array];
       check_uecc_outputs_array             = [chi_aiu_check_uecc_outputs_array];

       var chi_aiu_unit_cecc_outputs_array  = ['0_cerr_fault_in', '1_cerr_fault_in', '2_cerr_fault_in', '3_cerr_fault_in', '4_cerr_fault_in', '5_cerr_fault_in', '6_cerr_fault_in', '7_cerr_fault_in'];
       var chi_aiu_check_cecc_outputs_array = ['0_cerr_fault_in', '1_cerr_fault_in', '2_cerr_fault_in', '3_cerr_fault_in', '4_cerr_fault_in', '5_cerr_fault_in', '6_cerr_fault_in', '7_cerr_fault_in'];
       unit_cecc_outputs_array              = [chi_aiu_unit_cecc_outputs_array];
       check_cecc_outputs_array             = [chi_aiu_check_cecc_outputs_array];

     } else {
       var dve_unit_outputs_array = [];
       unit_inst_name             = ['u_dve_unit'];
       checker_inst_name          = ['u_dve_dup_unit'];
       func_checker_inst_name     = ['u_fault_checker'];

       var dve_unit_uecc_outputs_array  = ['func_0_fault_in', 'func_1_fault_in', 'func_2_fault_in', 'func_3_fault_in', 'func_4_fault_in'];
       var dve_check_uecc_outputs_array = ['check_0_fault_in', 'check_1_fault_in', 'check_2_fault_in', 'check_3_fault_in', 'check_4_fault_in'];
       unit_uecc_outputs_array          = [dve_unit_uecc_outputs_array];
       check_uecc_outputs_array         = [dve_check_uecc_outputs_array];

       var dve_unit_cecc_outputs_array  = ['0_cerr_fault_in', '1_cerr_fault_in', '2_cerr_fault_in', '3_cerr_fault_in', '4_cerr_fault_in'];
       var dve_check_cecc_outputs_array = ['0_cerr_fault_in', '1_cerr_fault_in', '2_cerr_fault_in', '3_cerr_fault_in', '4_cerr_fault_in'];
       unit_cecc_outputs_array          = [dve_unit_cecc_outputs_array];
       check_cecc_outputs_array         = [dve_check_cecc_outputs_array];
     } %>

/* updating generalized signals :: END */
   <%if (obj.testBench != "dmi"){
     for(var i in unit_outputs_array[0]){
       func_checker_inputs_array[0].push(unit_outputs_array[0][i]);
     }
     for(var i in smi_valid_signal_array[0]){
       func_checker_inputs_array[0].push(smi_valid_signal_array[0][i]);
     }
     for(var i in userPlaceInt_signal_array[0]){
       func_checker_inputs_array[0].push(userPlaceInt_signal_array[0][i]);
     }
   }
   else{
     func_checker_inputs_array
   }
   %>
   <% var unit_idx_min = 0; %>

   <% if ((obj.testBench == "psys") || (obj.testBench == "fsys") || (obj.testBench == "emu") || (obj.CUSTOMER_ENV)) { // System level
    var unit_idx_max = num_of_ncore_block_insts;
   } else { // Unit level
    var unit_idx_max = 1;
   } %>

   int bist_seq_active = 1;
   bit start_uecc_cov_sample = 0;
   bit start_out_cov_sample =0;

   /**
    *coverage for the resiliency at the block level will be captured
    *by the covergroup created below. Please update as required
    */
   // coverage variables
   logic clk_cvar;
   logic uecc_func_unit_or;
   logic uecc_check_unit_or;
   logic corr_out_func_unit_or;
   logic corr_out_check_unit_or;
   typedef struct
   {
     // considering uecc as a single bit to capture the intention properly
     logic uecc_func_unit;
     logic uecc_check_unit;
     logic mission_fault;
     logic latent_fault;
   } block_level_resiliency_check_struct_t;
   
// for correctable 
 typedef struct
  {
     // considering uecc as a single bit to capture the intention properly
     logic corr_out_func_unit;
     logic corr_out_check_unit;
     logic mission_fault;
     logic latent_fault;
   } block_level_corr_out_resiliency_check_struct_t;

   block_level_corr_out_resiliency_check_struct_t out_corr_blrc_cvar; 
   block_level_resiliency_check_struct_t blrc_cvar;

   assign clk_cvar = tb_clk;
   always @(*) begin
 corr_out_func_unit_or = (<% for(var idx=0; idx< ioaiu_unit_outputs_array[0].length; idx++) { %>
                                ("<%=ioaiu_unit_outputs_array[0][idx]%>" == output_signal) ? <%=hier_path_dut[0]%>.<%=ioaiu_unit_outputs_array[0][idx]%> :0  |
                              <% } %>
                           0) ? 1:0;
 
     uecc_func_unit_or =  (<% for(var idx=unit_idx_min; idx<unit_uecc_outputs_array[0].length; idx++) { %>
                                <%=hier_path_dut[0]%>.<%=unit_uecc_outputs_array[0][idx]%> |
                              <% } %>
                           0) ? 1:0;
   end
   assign out_corr_blrc_cvar.corr_out_func_unit = corr_out_func_unit_or ? 1:0 ;
   assign blrc_cvar.uecc_func_unit = uecc_func_unit_or ? 1:0 ;

   <% if(obj.DutInfo.ResilienceInfo.enableUnitDuplication) { %>
        always @(*) begin


          corr_out_check_unit_or = (<% for(var idx=0; idx<check_outputs_array[0].length; idx++) { %>
                                     ("<%=ioaiu_unit_outputs_array[0][idx]%>" == output_signal) ? <%=hier_path_dut[0]%>.<%=check_outputs_array[0][idx]%> :0 |
                                   <% } %>
                                 0) ? 1:0;  
          uecc_check_unit_or =  (<% for(var idx=unit_idx_min; idx<check_uecc_outputs_array[0].length; idx++) { %>
                                     <%=hier_path_dut[0]%>.<%=check_uecc_outputs_array[0][idx]%> |
                                   <% } %>
                                 0) ? 1:0;
         
        end
        assign out_corr_blrc_cvar.corr_out_check_unit = corr_out_check_unit_or ? 1:0 ;
      assign blrc_cvar.uecc_check_unit = uecc_check_unit_or ? 1:0 ;
   <% } %>
   assign blrc_cvar.mission_fault = <%=hier_path_dut[0]%>.fault_mission_fault;
   assign blrc_cvar.latent_fault = <%=hier_path_dut[0]%>.fault_latent_fault;
   assign out_corr_blrc_cvar.mission_fault = <%=hier_path_dut[0]%>.fault_mission_fault;
   assign out_corr_blrc_cvar.latent_fault = <%=hier_path_dut[0]%>.fault_latent_fault;
     //#Cover.IOAIU..Output.Fault 
     covergroup block_level_resiliency_check_output_signal_cg;
     option.per_instance = 1; // per instance coverage will be calculated
     option.name         = "block_level_resiliency_check_output_signal";
     option.comment      = "Block level coverage";
     option.goal         = 100;
     option.weight       = 100;

    output_func_cp : coverpoint out_corr_blrc_cvar.corr_out_func_unit iff(!bist_seq_active){
         bins output_0 = {0};
         bins output_1 = {[1:$]};
       }

     output_check_cp : coverpoint out_corr_blrc_cvar.corr_out_check_unit iff(!bist_seq_active){
         bins output_0 = {0};
         bins output_1 = {[1:$]};
       }

     mission_fault_cp : coverpoint out_corr_blrc_cvar.mission_fault iff(!bist_seq_active){
         bins fault_0 = {0};
         bins fault_1 = {1};
       }

     latent_fault_cp : coverpoint out_corr_blrc_cvar.latent_fault iff(!bist_seq_active){
         bins fault_0 = {0};
         ignore_bins fault_1 = {1};
       }

     output_func_cp_X_output_check_cp : cross output_func_cp, output_check_cp{
       ignore_bins output_00 = (binsof (output_func_cp.output_0) && binsof(output_check_cp.output_0));
     }
     mission_fault_cp_X_latent_fault_cp : cross mission_fault_cp, latent_fault_cp{
       
     }

     output_func_cp_X_output_check_cp__X__mission_fault_cp_X_latent_fault_cp : cross output_func_cp, output_check_cp, mission_fault_cp, latent_fault_cp{
       option.goal = (3/4)*100;
       bins output_fc11__ml10 = (binsof (output_func_cp.output_1) && binsof(output_check_cp.output_1) && binsof (mission_fault_cp.fault_0) && binsof(latent_fault_cp.fault_0));
       bins output_fc10__ml11 = (binsof (output_func_cp.output_1) && binsof(output_check_cp.output_0) && binsof (mission_fault_cp.fault_1) && binsof(latent_fault_cp.fault_0));
       bins output_fc01__ml01 = (binsof (output_func_cp.output_0) && binsof(output_check_cp.output_1) && binsof (mission_fault_cp.fault_1) && binsof(latent_fault_cp.fault_0));
       bins output_fc00__ml00 = (binsof (output_func_cp.output_0) && binsof(output_check_cp.output_0) && binsof (mission_fault_cp.fault_0) && binsof(latent_fault_cp.fault_0));
       ignore_bins ignore_comb = (
       (!binsof (output_func_cp.output_1) || !binsof(output_check_cp.output_1) || !binsof (mission_fault_cp.fault_0) || !binsof(latent_fault_cp.fault_0))    && (!binsof (output_func_cp.output_1) || !binsof(output_check_cp.output_0) || !binsof (mission_fault_cp.fault_1) || !binsof(latent_fault_cp.fault_0)) && (!binsof (output_func_cp.output_0) || !binsof(output_check_cp.output_1) || !binsof (mission_fault_cp.fault_1) || !binsof(latent_fault_cp.fault_0)) && (!binsof (output_func_cp.output_0) || !binsof(output_check_cp.output_0) || !binsof (mission_fault_cp.fault_0) || !binsof(latent_fault_cp.fault_0))
       );
     }
   endgroup

covergroup block_level_resiliency_check_uecc_cg;
     option.per_instance = 1; // per instance coverage will be calculated
     option.name         = "block_level_resiliency_check_uecc";
     option.comment      = "Block level coverage";
     option.goal         = 100;
     option.weight       = 100;

     uecc_func_cp : coverpoint blrc_cvar.uecc_func_unit iff(!bist_seq_active){
         bins uecc_0 = {0};
         bins uecc_1 = {[1:$]};
       }

     uecc_check_cp : coverpoint blrc_cvar.uecc_check_unit iff(!bist_seq_active){
         bins uecc_0 = {0};
         bins uecc_1 = {[1:$]};
       }

     mission_fault_cp : coverpoint blrc_cvar.mission_fault iff(!bist_seq_active){
         bins fault_0 = {0};
         bins fault_1 = {1};
       }

     latent_fault_cp : coverpoint blrc_cvar.latent_fault iff(!bist_seq_active){
         bins fault_0 = {0};
         bins fault_1 = {1};
       }

     uecc_func_cp_X_uecc_check_cp : cross uecc_func_cp, uecc_check_cp{
       ignore_bins uecc_00 = (binsof (uecc_func_cp.uecc_0) && binsof(uecc_check_cp.uecc_0));
     }
     mission_fault_cp_X_latent_fault_cp : cross mission_fault_cp, latent_fault_cp{
       ignore_bins fault_00 = (binsof (mission_fault_cp.fault_0) && binsof(latent_fault_cp.fault_0));
       ignore_bins fault_01 = (binsof (mission_fault_cp.fault_0) && binsof(latent_fault_cp.fault_1));
     }
//#Cover.IOAIU.Unitduplication.fault     
     uecc_func_cp_X_uecc_check_cp__X__mission_fault_cp_X_latent_fault_cp : cross uecc_func_cp, uecc_check_cp, mission_fault_cp, latent_fault_cp{
       option.goal = (3/4)*100;
       bins uecc_fc11__ml10 = (binsof (uecc_func_cp.uecc_1) && binsof(uecc_check_cp.uecc_1) && binsof (mission_fault_cp.fault_1) && binsof(latent_fault_cp.fault_0));
       bins uecc_fc10__ml11 = (binsof (uecc_func_cp.uecc_1) && binsof(uecc_check_cp.uecc_0) && binsof (mission_fault_cp.fault_1) && binsof(latent_fault_cp.fault_1));
       bins uecc_fc01__ml11 = (binsof (uecc_func_cp.uecc_0) && binsof(uecc_check_cp.uecc_1) && binsof (mission_fault_cp.fault_1) && binsof(latent_fault_cp.fault_1));
       bins uecc_fc00__ml00 = (binsof (uecc_func_cp.uecc_0) && binsof(uecc_check_cp.uecc_0) && binsof (mission_fault_cp.fault_0) && binsof(latent_fault_cp.fault_0));
       ignore_bins ignore_comb = (
            (!binsof (uecc_func_cp.uecc_1) || !binsof(uecc_check_cp.uecc_1) || !binsof (mission_fault_cp.fault_1) || !binsof(latent_fault_cp.fault_0))
         && (!binsof (uecc_func_cp.uecc_1) || !binsof(uecc_check_cp.uecc_0) || !binsof (mission_fault_cp.fault_1) || !binsof(latent_fault_cp.fault_1))
         && (!binsof (uecc_func_cp.uecc_0) || !binsof(uecc_check_cp.uecc_1) || !binsof (mission_fault_cp.fault_1) || !binsof(latent_fault_cp.fault_1))
         && (!binsof (uecc_func_cp.uecc_0) || !binsof(uecc_check_cp.uecc_0) || !binsof (mission_fault_cp.fault_0) || !binsof(latent_fault_cp.fault_0))
       );
     }
   endgroup

   block_level_resiliency_check_uecc_cg blrc_uecc_cgi;
   block_level_resiliency_check_output_signal_cg blrc_output_cgi;








   initial begin
     if($test$plusargs("test_unit_duplication_cov")) begin
       blrc_uecc_cgi = new();
       blrc_output_cgi = new();
     end
   end

   //always @(posedge blrc_cvar.uecc_func_unit or posedge blrc_cvar.uecc_check_unit) begin
   always @( blrc_cvar.mission_fault or  blrc_cvar.latent_fault or bist_seq_active) begin
      if(!bist_seq_active & start_uecc_cov_sample) begin
        // wait for uecc to be assrted
       `uvm_info(report_id ,$sformatf("blrc_uecc_cgi::blrc_cvar=%p", blrc_cvar), UVM_LOW)
        //repeat(5) @(posedge tb_clk);
        if(blrc_uecc_cgi != null)
        blrc_uecc_cgi.sample();
      end
     if(!bist_seq_active & start_out_cov_sample) begin
       // wait for uecc to be assrted
       `uvm_info(report_id ,$sformatf("blrc_output_cgi::out_corr_blrc_cvar=%p", out_corr_blrc_cvar), UVM_LOW)
       if(blrc_output_cgi != null)
         blrc_output_cgi.sample();
     end
   end
   bit [<%=unit_idx_max%>-1:0] sustained_mission_fault;// SRAM error injection will result in toggling functional units beyond control of force/releases and the mission falt will sustain regardless of BIST reset
   // abbreviation: tp for transport protection and ud for unit duplication
   bit [<%=unit_idx_max%>-1:0] tb_mission_fault_ud;
   bit [<%=unit_idx_max%>-1:0] tb_latent_fault_ud;
   bit [<%=unit_idx_max%>-1:0] tb_cerr_fault_ud;
   bit [<%=unit_idx_max%>-1:0] mission_fault_units;
   bit [<%=unit_idx_max%>-1:0] latent_fault_units;
   bit [<%=unit_idx_max%>-1:0] cerr_fault_units;
   int unsigned cerr_threshold_units[<%=unit_idx_max%>-1:0];
   int unsigned cerr_counter_units[<%=unit_idx_max%>-1:0];

   // Counts the number of times the cerr_thres interrupt triggered in full system, and also per unit instance
   int num_of_cerr_thres_unit_assertion [<%=unit_idx_max%>-1:0];

   initial begin
     <%  for  (var unit_idx = unit_idx_min; unit_idx < unit_idx_max; unit_idx++) { %>
      num_of_cerr_thres_unit_assertion[<%=unit_idx%>] = 0;
     <% } %>
   end
   <% if (!((obj.testBench == "psys") || (obj.testBench == "fsys") || (obj.CUSTOMER_ENV))) { %>
     <% if (obj.DutInfo.ResilienceInfo.fnResiliencyProtectionType == "ecc") { %>
       assign cerr_threshold_units[0] = <%=hier_path_dut[0]%>.<%=func_checker_inst_name[0]%>.cerr_threshold;
       assign cerr_counter_units[0]   = <%=hier_path_dut[0]%>.<%=func_checker_inst_name[0]%>.cerr_counter;
       assign cerr_fault_units[0]     = (cerr_counter_units[0]>cerr_threshold_units[0])? 1'b1 : 1'b0;
     <% } %>
   <% } %>

   initial begin
       void'($value$plusargs("inj_cntl=%d", inj_cntl));
   end

   initial begin
      force tb_top.dut.bist_bist_next = 1'b0;
      @(posedge tb_rstn);
      #100ns;
      //bist_seq(`__LINE__);
   end

  <%  for  (var unit_idx = unit_idx_min; unit_idx < unit_idx_max; unit_idx++) { %>
   initial begin
      int vld_txn_killed;
<% if((obj.testBench == 'dii')||(obj.testBench == 'dmi')||(obj.testBench == 'dce')||(obj.testBench == 'dve')||(obj.testBench == 'chi_aiu')||(obj.testBench == 'io_aiu')) { %>
`ifdef VCS
  kill_test = new("kill_test");
`endif // `ifndef VCS ... `else ... 
<% } %>

      @(posedge tb_rstn);
      forever begin
         @(negedge tb_clk);
         // TODO: driver of vld_txn_killed
         vld_txn_killed = 0;

         if (vld_txn_killed) begin
            repeat (200000) @(posedge tb_clk);
<% if((obj.testBench == 'dii')||(obj.testBench == 'dmi')||(obj.testBench == 'dce')||(obj.testBench == 'dve')||(obj.testBench == 'chi_aiu')||(obj.testBench == 'io_aiu')) { %>
`ifndef VCS
            -> kill_test;
`else // `ifndef VCS
            kill_test.trigger();
`endif // `ifndef VCS ... `else ... 
<% } else {%>
            -> kill_test;
<% } %>

         end
      end
   end
  <% } %>

	//////////////////////////////////////////////Begin BIST Sequences  //////////////////////////////////////////////////////////////////////////////
   // Following task executes the Bist reset sequence
   task bist_reset_seq();
      wait(tb_rstn === 1'b1);
      //Bist seq moves through 6 steps. Reference Spec:Ncore 3.6 Functional Safety Specification Table 5-1: BIST FSM 
      for (int i=1; i<=6; i++) begin
          @(posedge tb_clk);
          force <%=hier_path_dut[0]%>.bist_bist_next = 1'b1;
          wait(<%=hier_path_dut[0]%>.bist_bist_next_ack === 1'b1);
          force <%=hier_path_dut[0]%>.bist_bist_next = 1'b0;
          @(posedge tb_clk);
          wait(<%=hier_path_dut[0]%>.bist_bist_next_ack === 1'b0);
          release <%=hier_path_dut[0]%>.bist_bist_next;
          `uvm_info(report_id ,$sformatf("BIST RESET step %0d done", i), UVM_NONE)
      end
      ev_bist_reset_done.trigger();
   endtask : bist_reset_seq

   // Following task executes the Bist sequence, at each Bist seq step, Mission fault and Latent faults
   // should have the expected values, of which details are available at confluence page (link at the top)
   //#Check.IOAIU.BistSeq
   //#Stimulus.IOAIU.BistSeq
   task bist_seq(int _line, input bit initiate_system_reset=0);
      automatic int bist_seq_hanged = 0;
      int bist_step;
      automatic string line = string'(_line);
     <% for  (var unit_idx = unit_idx_min; unit_idx < unit_idx_max; unit_idx++) { %>
      int bist_step_<%=unit_idx%>;
     <% } %>

      <% if(dmi_uses_sram) { %>
      automatic uvm_event dmi_reset_event = ev_pool.get("dmi_reset_event");
      automatic uvm_event dmi_reset_event_complete = ev_pool.get("dmi_reset_event_complete");
      <% } %>

      bist_seq_active = 1;
      bist_step = 0;

      //SV impl issue with disable - so wrap inner fork..join_any, with a fork..join

      `uvm_info(report_id, $sformatf("bist_seq called from line:%0s",line),UVM_LOW)
      <% if(obj.testBench == 'chi_aiu') { %>
          if(<%=hier_path_dut[0]%>.fault_mission_fault === 1'b1 || <%=hier_path_dut[0]%>.fault_latent_fault === 1'b1 || <%=hier_path_dut[0]%>.fault_cerr_over_thres_fault === 1'b1) begin
	       	`uvm_info(report_id ,$sformatf(" bist seq force reset fault_mission_fault: %0b fault_latent_fault: %0b fault_cerr_over_thres_fault: %0b", <%=hier_path_dut[0]%>.fault_mission_fault, <%=hier_path_dut[0]%>.fault_latent_fault, <%=hier_path_dut[0]%>.fault_cerr_over_thres_fault), UVM_LOW);
               	force tb_top.dut.clk_reset_n = 0;
                @(posedge tb_clk);
                force tb_top.dut.clk_reset_n = 1;
                tb_mission_fault_ud[0] = 0;
                tb_latent_fault_ud[0]  = 0;
               	repeat(10) @(posedge tb_clk);
               	force tb_top.dut.clk_reset_n = 1;
      		ev_system_reset_done.trigger();
          end
      <% } %>
      fork begin
         fork
         begin
            repeat(6) begin
               repeat(2)@(posedge tb_clk);
               if($test$plusargs("bist_timeout_error") && bist_step == 4) begin
                <%if(obj.testBench == 'io_aiu') {%>
               force <%=hier_path_dut[0]%>.bist_bist_next = 1'b1;
               force tb_top.dut.ioaiu_core_wrapper.ioaiu_core0.ioaiu_control.q_sv_timer[31:0] = 32'hff;
                <% if(obj.DutInfo.ResilienceInfo.enableUnitDuplication) { %>
               repeat(<%= nResiliencyDelay_json %>) @(posedge tb_clk);
               force tb_top.dut.dup_unit.ioaiu_core0.ioaiu_control.q_sv_timer[31:0]  = 32'hff;
               <%}%>
               fork
               begin
                   wait(<%=hier_path_dut[0]%>.bist_bist_next_ack === 1'b1);
                   force <%=hier_path_dut[0]%>.bist_bist_next = 1'b0;
                   @(posedge tb_clk);
                   wait(<%=hier_path_dut[0]%>.bist_bist_next_ack === 1'b0);
                   release tb_top.dut.ioaiu_core_wrapper.ioaiu_core0.ioaiu_control.q_sv_timer[31:0];
                   repeat(<%= nResiliencyDelay_json %>) @(posedge tb_clk);
                   <% if(obj.DutInfo.ResilienceInfo.enableUnitDuplication) { %>
                   release tb_top.dut.dup_unit.ioaiu_core0.ioaiu_control.q_sv_timer[31:0];
                   <% } %>
                   release <%=hier_path_dut[0]%>.bist_bist_next;
              end
              begin
                   repeat(2**14)@(posedge tb_clk);
                   if( <%=hier_path_dut[0]%>.bist_bist_next_ack != 1'b1)
                  `uvm_error(report_id ,$sformatf("Bist sequence:: _bist_next_ack is not 1 after bist sequence %0dth step",bist_step));
              end
              join_any
              disable fork;
              <%}%>
              bist_step++;
              end else begin
               force <%=hier_path_dut[0]%>.bist_bist_next = 1'b1;
               wait(<%=hier_path_dut[0]%>.bist_bist_next_ack === 1'b1);
               repeat(2)@(posedge tb_clk);
               force <%=hier_path_dut[0]%>.bist_bist_next = 1'b0;
               wait(<%=hier_path_dut[0]%>.bist_bist_next_ack === 1'b0);
               bist_step++;
               end
                  if (bist_step == 1) begin
                  assert (<%=hier_path_dut[0]%>.fault_mission_fault === 1'b0)
                  else `uvm_error(report_id ,$sformatf("Bist sequence:: Mission fault is not 0 after bist sequence 1st step"));

                  assert (<%=hier_path_dut[0]%>.fault_latent_fault === 1'b0)
                  else `uvm_error(report_id ,$sformatf("Bist sequence:: Latent fault is not 0 after bist sequence 1st step"));

                  assert (<%=hier_path_dut[0]%>.fault_cerr_over_thres_fault === 1'b0)
                  else `uvm_error(report_id ,$sformatf("Bist sequence:: cerr fault is not 0 after bist sequence 1st step"));
               end else if (bist_step == 2) begin
                  assert (<%=hier_path_dut[0]%>.fault_mission_fault === 1'b0)
                  else `uvm_error(report_id ,$sformatf("Bist sequence:: Mission fault is not 1 after bist sequence 2nd step"));

                  assert (<%=hier_path_dut[0]%>.fault_latent_fault === 1'b0)
                  else `uvm_error(report_id ,$sformatf("Bist sequence:: Latent fault is not 1 after bist sequence 2nd step"));

                  assert (<%=hier_path_dut[0]%>.fault_cerr_over_thres_fault === 1'b1)
                  else `uvm_error(report_id ,$sformatf("Bist sequence:: cerr fault is not 0 after bist sequence 2nd step"));
               end else if (bist_step == 3) begin
                  assert (<%=hier_path_dut[0]%>.fault_mission_fault === 1'b0)
                  else `uvm_error(report_id ,$sformatf("Bist sequence:: Mission fault is not 0 after bist sequence 3rd step"));

                  assert (<%=hier_path_dut[0]%>.fault_latent_fault === 1'b1)
                  else `uvm_error(report_id ,$sformatf("Bist sequence:: Latent fault is not 1 after bist sequence 3rd step"));

                  assert (<%=hier_path_dut[0]%>.fault_cerr_over_thres_fault === 1'b0)
                  else `uvm_error(report_id ,$sformatf("Bist sequence:: cerr fault is not 0 after bist sequence 3rd step"));
               end else if (bist_step == 4) begin
                  assert (<%=hier_path_dut[0]%>.fault_mission_fault === 1'b1)
                  else `uvm_error(report_id ,$sformatf("Bist sequence:: Mission fault is not 1 after bist sequence 4th step"));

                  assert (<%=hier_path_dut[0]%>.fault_latent_fault === 1'b0)
                  else `uvm_error(report_id ,$sformatf("Bist sequence:: Latent fault is not 0 after bist sequence 4th step"));

                  assert (<%=hier_path_dut[0]%>.fault_cerr_over_thres_fault === 1'b0)
                  else `uvm_error(report_id ,$sformatf("Bist sequence:: cerr fault is not 0 after bist sequence 4th step"));
               end else if (bist_step == 5) begin
                   if($test$plusargs("bist_timeout_error")) begin
                    <%if(obj.testBench == 'io_aiu') {%>
                     assert (<%=hier_path_dut[0]%>.fault_mission_fault === 1'b0)
                     else `uvm_error(report_id ,$sformatf("Bist sequence:: Mission fault is not 0 after bist sequence 5th step"));

                     assert (<%=hier_path_dut[0]%>.fault_latent_fault === 1'b0)
                     else `uvm_error(report_id ,$sformatf("Bist sequence:: Latent fault is not 0 after bist sequence 5th step"));

                   	 assert (<%=hier_path_dut[0]%>.fault_cerr_over_thres_fault === 1'b0)
                     else `uvm_error(report_id ,$sformatf("Bist sequence:: Cerr fault is not 0 after bist sequence 5th step"));
                    <%}%>
                   end else begin
                      assert (<%=hier_path_dut[0]%>.fault_mission_fault === 1'b1)
                      else `uvm_error(report_id ,$sformatf("Bist sequence:: Mission fault is not 1 after bist sequence 5th step"));
                      
                      assert (<%=hier_path_dut[0]%>.fault_latent_fault === 1'b0)
                      else `uvm_error(report_id ,$sformatf("Bist sequence:: Latent fault is not 0 after bist sequence 5th step"));
                      
                      assert (<%=hier_path_dut[0]%>.fault_cerr_over_thres_fault === 1'b0)
                  	  else `uvm_error(report_id ,$sformatf("Bist sequence:: Cerr fault is not 0 after bist sequence 5th step"));
                   end                  
               end else if (bist_step == 6) begin
                  <% if(dmi_uses_sram) { %>
                  if(initiate_system_reset) begin
                    dmi_reset_event.trigger();
                    dmi_reset_event_complete.wait_trigger();
                  end
                  <% } %>
                  assert (<%=hier_path_dut[0]%>.fault_mission_fault === 1'b0)
                  else `uvm_error(report_id ,$sformatf("Bist sequence:: Mission fault is not 0 after bist sequence 6th step"));

                  assert (<%=hier_path_dut[0]%>.fault_latent_fault === 1'b0)
                  else `uvm_error(report_id ,$sformatf("Bist sequence:: Latent fault is not 0 after bist sequence 6th step"));

                  assert (<%=hier_path_dut[0]%>.fault_cerr_over_thres_fault === 1'b0)
                  else `uvm_error(report_id ,$sformatf("Bist sequence:: Cerr fault is not 0 after bist sequence 6th step"));
                  bist_step = 0;
               end

            end
         end
         join_any
         disable fork;
      end join


      repeat(10)@(posedge tb_clk);

      <%  for  (var unit_idx = unit_idx_min; unit_idx < unit_idx_max; unit_idx++) { %>
      assert (<%=hier_path_dut[unit_idx]%>.fault_mission_fault === 1'b0)
      else `uvm_error(report_id ,$sformatf("Bist sequence:: Mission fault is not 0 after bist sequence final step"));

      assert (<%=hier_path_dut[unit_idx]%>.fault_latent_fault === 1'b0)
      else `uvm_error(report_id ,$sformatf("Bist sequence:: Latent fault is not 0 after bist sequence final step"));

      assert (<%=hier_path_dut[unit_idx]%>.fault_cerr_over_thres_fault === 1'b0)
      else `uvm_error(report_id ,$sformatf("Bist sequence:: Cerr fault is not 0 after bist sequence final step"));
      <% } %>

     <%  for  (var unit_idx = unit_idx_min; unit_idx < unit_idx_max; unit_idx++) { %>
      tb_mission_fault_ud[<%=unit_idx%>] = 0;
      tb_latent_fault_ud[<%=unit_idx%>]  = 0;
     <% } %>
      bist_seq_active = 0;
   endtask:bist_seq

	////////////////////////////////////////////// End BIST Sequences  ///////////////////////////////////////////////////////////////////////////////
   initial begin
       // 1024 for the signal value, 128 for the no of outputs and last 128 for number of units
       logic [1023:0] prev_val [127:0] [300:0]; //Need to change "300" here just a temp fix
       bit force_func_check_unit_outputs;
       bit force_cerr_threshold;
       bit conc_7033_patch;
       <% var rand_pos_in_signal_json ;%>
       <% var rand_pos_in_signal_prev_json ;%>
       int delay_bw_two_faults;
       int signal_width[int];
       int cnt;

<% if((obj.testBench == 'dii')||(obj.testBench == 'dmi')||(obj.testBench == 'dce')||(obj.testBench == 'dve')||(obj.testBench == 'chi_aiu')||(obj.testBench == 'io_aiu')) { %>
`ifndef VCS
       int rand_pos_in_signal[int];
       int Fun_signal_val[int];
       int Delay_signal_val[int];
`else // `ifndef VCS
       <% var temp = 0; %>
       <% var tmp = 0; %>
       <% if (unit_outputs_array[0].length < func_checker_inputs_array[0].length) { %>
       <% temp = func_checker_inputs_array[0].length; %>
       <% } else { %>
       <% temp = unit_outputs_array[0].length; %>
       <% } %>
       <%  tmp = ioaiu_unit_outputs_array[0].length;   %>

       int rand_pos_in_signal[<%= temp %>];
        <% if((obj.testBench == 'io_aiu')) { %>
       int Fun_signal_val[<%=tmp%>];
       int Delay_signal_val[<%= tmp %>];
       <% } else {%>
       int Fun_signal_val[<%=temp%>];
       int Delay_signal_val[<%= temp %>];
       <%}%>
`endif // `ifndef VCS ... `else ...
<% } else {%>
       int rand_pos_in_signal[int];
       int Fun_signal_val[int];
       int Delay_signal_val[int];
<% } %>

       bit inject_fault_in_func_unit;
       bit inject_fault_in_checker_unit;
       bit mod2_cnt;
       bit avoid_dual_port_contention;
       bit [15:0] cerr_counter_max_value, cerr_threshold_max_value, cerr_cnt;
       bit [09:0] cerr_threshold_value;
       bit [03:0] cerr_counter_max_value_no_bits, cerr_threshold_max_value_no_bits;
       uvm_event_pool ev_pool = uvm_event_pool::get_global_pool();
<% if((obj.testBench == 'dii')||(obj.testBench == 'dmi')||(obj.testBench == 'dce')||(obj.testBench == 'dve')) { %>
`ifdef VCS
  //raise_obj_for_resiliency_test = new("raise_obj_for_resiliency_test");
  //drop_obj_for_resiliency_test = new("drop_obj_for_resiliency_test");
`endif // `ifndef VCS ... `else ... 
<% } %>

       @(posedge tb_rstn);
      <% if ((obj.useResiliency) && (obj.testBench != "fsys") && (obj.testBench != 'io_aiu') && (obj.testBench != 'chi_aiu')) { %>
       bist_reset_seq();
      <% } else if((obj.useResiliency) && (obj.testBench == 'chi_aiu')) {%>
        repeat(10)@(posedge tb_clk);
	if(<%=hier_path_dut[0]%>.fault_mission_fault) begin
         uvm_config_db#(bit)::set(null,"*","mission_fault_asserted",1); //for coverage
         bist_reset_seq();
         end 
      <% } %>

        
       delay_bw_two_faults = 0;
      <% if (((obj.testBench == "psys") || (obj.testBench == "fsys") || (obj.testBench == "emu") || (obj.CUSTOMER_ENV)) && (obj.useResiliency)){ %>
       force `U_CHIP.<%=obj.FscInfo.strRtlNamePrefix%>_psel = 1'b0;
       force `U_CHIP.<%=obj.FscInfo.strRtlNamePrefix%>_penable = 1'b0;
       force `U_CHIP.<%=obj.FscInfo.strRtlNamePrefix%>_pwrite = 1'b0;
      <% } %>

       force_func_check_unit_outputs = $test$plusargs("test_unit_duplication");
       force_cerr_threshold = 1; // $test$plusargs("test_cerr_threshold");

       <% if (obj.useResiliency) { %>
       <% if((obj.testBench == 'dii')||(obj.testBench == 'dmi')||(obj.testBench == 'dce')||(obj.testBench == 'dve')||(obj.testBench == 'chi_aiu')||(obj.testBench == 'io_aiu')) { %>
        `ifndef VCS
        -> raise_obj_for_resiliency_test;
        `else // `ifndef VCS
        raise_obj_for_resiliency_test.trigger();
        `endif // `ifndef VCS ... `else ... 
        <% } else {%>
       -> raise_obj_for_resiliency_test;
      <% } %>
      <% }%>

      <% if(obj.DutInfo.ResilienceInfo.enableUnitDuplication) { %>
       `uvm_info(report_id, "Triggering event raise_obj_for_resiliency_test",UVM_NONE)

    ////////////////////////////////////////////// Inject Faults In Unit Outputs //////////////////////////Uses JS unit_outputs_array ///////////
       begin
         if(force_func_check_unit_outputs) begin
           bist_seq(`__LINE__);
           //Waiting for first bist_seq completion
           #100ns;
           repeat(100)@(posedge tb_clk);
           wait (bist_seq_active == 0)

           delay_bw_two_faults =  $urandom_range(1,3);

           /*
            *If any background traffic is going on then we should force the
            *uecc to stay  low to make sure expectation stays correct
            */
           /*
             `uvm_info(report_id, "Forcing UECC as 0", UVM_LOW);
             <% for(var i in unit_uecc_outputs_array[0]) { %>
                  force <%=hier_path_dut[0]%>.<%=unit_uecc_outputs_array[0][i]%> = 'b0;
                  force <%=hier_path_dut[0]%>.<%=check_uecc_outputs_array[0][i]%> = 'b0;
             <% } %>
           */

           for(int rpt_cnt=0;rpt_cnt<40;rpt_cnt++) begin
             inject_fault_in_func_unit    = $urandom_range(0,1); //1: fault  inject in func    module
             inject_fault_in_checker_unit = $urandom_range(0,1); //1: fault  inject in checker module
             if(!inject_fault_in_func_unit) inject_fault_in_checker_unit = 1; //If not injecting error in func unit then complusory injecting in checker unit.
             `uvm_info(report_id ,$sformatf("repeat_cnt:%0d | Fault injection in Function unit %0b Checker unit %0b", rpt_cnt, inject_fault_in_func_unit, inject_fault_in_checker_unit),UVM_NONE);

            <% for  (var unit_idx = unit_idx_min; unit_idx < unit_idx_max; unit_idx++) { %>

              force <%=hier_path_dut[unit_idx]%>.bist_bist_next = 1'b0;
              repeat(5)@(posedge tb_clk);

             <% if ((obj.testBench == "psys") || (obj.testBench == "fsys") || (obj.testBench == "emu") || (obj.CUSTOMER_ENV)) { %>
              @(negedge tb_clk);
             <%} else {%>
              @(negedge tb_clk);
             <%}%>

               fork
               <% for  (var unit_idx_1 = unit_idx_min; unit_idx_1 < unit_outputs_array[0].length; unit_idx_1++) { %>
               <% rand_pos_in_signal_json = unit_idx_1; %>
               begin
                 prev_val[<%=unit_idx%>][<%=rand_pos_in_signal_json%>] = <%=hier_path_dut[unit_idx]%>.<%=unit_inst_name[unit_idx]%>.<%=unit_outputs_array[unit_idx][rand_pos_in_signal_json]%>;
                 // Either only one output will be driven to different values in func or check units or all the outputs or will be selected randomly
                 signal_width[<%= rand_pos_in_signal_json %>] = $bits(<%=hier_path_dut[unit_idx]%>.<%=unit_inst_name[unit_idx]%>.<%=unit_outputs_array[unit_idx][rand_pos_in_signal_json]%>);
                 rand_pos_in_signal[<%= rand_pos_in_signal_json %>] = $urandom_range(0, signal_width[<%= rand_pos_in_signal_json %>]-1);
                 // Sample at negedge of tb_clk, when signal values are stable
                 `uvm_info(report_id
                           ,$sformatf("reading the value ='h%0x from <%=hier_path_dut[unit_idx]%>.<%=unit_inst_name[unit_idx]%>.<%=unit_outputs_array[unit_idx][rand_pos_in_signal_json]%>, rand_pos_in_signal[<%= rand_pos_in_signal_json %>]=%0d\n"
                             ,prev_val[<%=unit_idx%>][<%=rand_pos_in_signal_json%>], rand_pos_in_signal[<%= rand_pos_in_signal_json %>])
                           ,UVM_DEBUG);

                 #0;
                 if(inject_fault_in_func_unit) begin
                   `uvm_info(report_id
                             ,$sformatf("forcing the <%=hier_path_dut[unit_idx]%>.<%=unit_inst_name[unit_idx]%>.<%=unit_outputs_array[unit_idx][rand_pos_in_signal_json]%> to value='h%0x at bit position=%0d\n"
                               ,(prev_val[<%=unit_idx%>][<%=rand_pos_in_signal_json%>] ^ (1'b1<<rand_pos_in_signal[<%= rand_pos_in_signal_json %>])), rand_pos_in_signal[<%= rand_pos_in_signal_json %>])
                             ,UVM_DEBUG);
                   force <%=hier_path_dut[unit_idx]%>.<%=unit_inst_name[unit_idx]%>.<%=unit_outputs_array[unit_idx][rand_pos_in_signal_json]%> = prev_val[<%=unit_idx%>][<%=rand_pos_in_signal_json%>] ^ (1'b1<<rand_pos_in_signal[<%= rand_pos_in_signal_json %>]);
                 end

                 repeat(<%= nResiliencyDelay_json %>) @(posedge tb_clk); // waiting for delay cycle set for latent unit
                 if (inject_fault_in_checker_unit) begin
                   `uvm_info(report_id
                             ,$sformatf("forcing the <%=hier_path_dut[unit_idx]%>.<%=checker_inst_name[unit_idx]%>.<%=unit_outputs_array[unit_idx][rand_pos_in_signal_json]%> to value='h%0x at bit position=%0d\n"
                               ,(prev_val[<%=unit_idx%>][<%=rand_pos_in_signal_json%>] ^ (1'b1<<rand_pos_in_signal[<%= rand_pos_in_signal_json %>])), rand_pos_in_signal[<%= rand_pos_in_signal_json %>])
                             ,UVM_DEBUG);

                   force <%=hier_path_dut[unit_idx]%>.<%=checker_inst_name[unit_idx]%>.<%=unit_outputs_array[unit_idx][rand_pos_in_signal_json]%> = prev_val[<%=unit_idx%>][<%=rand_pos_in_signal_json%>] ^ (1'b1<<rand_pos_in_signal[<%= rand_pos_in_signal_json %>]);
                   repeat(2)@(posedge tb_clk);
                 end
                 // release
                 repeat(2)@(posedge tb_clk);
                 if(inject_fault_in_func_unit) begin
                   force <%=hier_path_dut[unit_idx]%>.<%=unit_inst_name[unit_idx]%>.<%=unit_outputs_array[unit_idx][rand_pos_in_signal_json]%> = prev_val[<%=unit_idx%>][<%=rand_pos_in_signal_json%>];
                   release <%=hier_path_dut[unit_idx]%>.<%=unit_inst_name[unit_idx]%>.<%=unit_outputs_array[unit_idx][rand_pos_in_signal_json]%>;
                   repeat(<%= nResiliencyDelay_json %>) @(posedge tb_clk);
                 end
                 if (inject_fault_in_checker_unit) begin
                   force <%=hier_path_dut[unit_idx]%>.<%=checker_inst_name[unit_idx]%>.<%=unit_outputs_array[unit_idx][rand_pos_in_signal_json]%> = prev_val[<%=unit_idx%>][<%=rand_pos_in_signal_json%>];
                   release <%=hier_path_dut[unit_idx]%>.<%=checker_inst_name[unit_idx]%>.<%=unit_outputs_array[unit_idx][rand_pos_in_signal_json]%>;
                 end
               end
               <% } %>
               join
                //Any mismatch in output signals of the functional unit and late unit excluding uncorrectable faults causes a mission fault.
               case ({inject_fault_in_checker_unit,inject_fault_in_func_unit})
                      'b00 //No fault injection
                     ,'b11 //Fault injection in functional and checker block
                      : begin
                          tb_mission_fault_ud[<%=unit_idx%>] = 0;
                          tb_latent_fault_ud[<%=unit_idx%>]  = 0;
                        end
                      'b01 //Fault injection in functional block
                     ,'b10 //Fault injection in checker block
                      : begin
                          tb_mission_fault_ud[<%=unit_idx%>] = 1;
                          tb_latent_fault_ud[<%=unit_idx%>]  = 0;
                        end
                  default : begin
                            end
               endcase
               repeat(2) @(posedge tb_clk);
               start_checker = 1;
               repeat(delay_bw_two_faults) @(posedge tb_clk);
               #5ps;

               start_checker = 0;
               repeat(10)@(posedge tb_clk);
               //Calling bist_sequence to reset the faults
               bist_seq(`__LINE__);
            <% } %> // Java for loop for all units (unit_idx < unit_idx_max)
           end //end rpt_cnt

				//////////////////////////////////////////  Toggle for Coverage Collection  /////////////////////////////Uses JS func_checker_inputs_array //
           `uvm_info(report_id, "Testing now for coverage collection", UVM_LOW)
           <% if(!(obj.testBench == "fsys")){ %>
           <% if(obj.testBench == "dve"){ %>
             // forcing below signals to make sure other *valid signal force later on not impact?
             <% for  (var unit_idx = unit_idx_min; unit_idx < force_rtl_sig_array.length; unit_idx++) { %>
             force <%=hier_path_dut[unit_idx]%>.<%=unit_inst_name[unit_idx]%>.<%=force_rtl_sig_array[unit_idx]%> = 'h0;
             force <%=hier_path_dut[unit_idx]%>.<%=checker_inst_name[unit_idx]%>.<%=force_rtl_sig_array[unit_idx]%> = 'h0;
             <% } %>
           <% } %>
           <% } %>
           for(int rpt_cnt=0;rpt_cnt<100;rpt_cnt++) begin
             /*
              *if background traffic is going on then avoid forcing value in functional
              *unit as other checkers will shout an error
              */
             inject_fault_in_func_unit    = $urandom_range(0,1);
             inject_fault_in_checker_unit = $urandom_range(0,1);
             `uvm_info(report_id ,$sformatf("repeat_cnt:%0d | Fault injection in Function unit %0b Checker unit %0b", rpt_cnt, inject_fault_in_func_unit, inject_fault_in_checker_unit),UVM_NONE);

            <% for  (var unit_idx = unit_idx_min; unit_idx < unit_idx_max; unit_idx++) { %>

              force <%=hier_path_dut[unit_idx]%>.bist_bist_next = 1'b0;
              repeat(5)@(posedge tb_clk);

             <% if ((obj.testBench == "psys") || (obj.testBench == "fsys") || (obj.testBench == "emu") || (obj.CUSTOMER_ENV)) { %>
              @(negedge tb_clk);
             <%} else {%>
              @(negedge tb_clk);
             <%}%>

               fork
             <% for  (var unit_idx_1 = unit_idx_min; unit_idx_1 < func_checker_inputs_array[0].length; unit_idx_1++) { %>
             <% rand_pos_in_signal_json = unit_idx_1; %>
               begin
                 prev_val[<%=unit_idx%>][<%=rand_pos_in_signal_json%>] = <%=hier_path_dut[unit_idx]%>.<%=func_checker_inst_name[unit_idx]%>.func_<%=func_checker_inputs_array[unit_idx][rand_pos_in_signal_json]%>;
                 // Either only one output will be driven to different values in func or check units or all the outputs or will be selected randomly
                 signal_width[<%= rand_pos_in_signal_json %>] = $bits(<%=hier_path_dut[unit_idx]%>.<%=func_checker_inst_name[unit_idx]%>.func_<%=func_checker_inputs_array[unit_idx][rand_pos_in_signal_json]%>);
                 rand_pos_in_signal[<%= rand_pos_in_signal_json %>] = $urandom_range(0, signal_width[<%= rand_pos_in_signal_json %>]-1);
                 // Sample at negedge of tb_clk, when signal values are stable
                 `uvm_info(report_id
                           ,$sformatf("reading the value ='h%0x from <%=hier_path_dut[unit_idx]%>.<%=func_checker_inst_name[unit_idx]%>.func_<%=func_checker_inputs_array[unit_idx][rand_pos_in_signal_json]%>, rand_pos_in_signal[<%= rand_pos_in_signal_json %>]=%0d\n"
                             ,prev_val[<%=unit_idx%>][<%=rand_pos_in_signal_json%>], rand_pos_in_signal[<%= rand_pos_in_signal_json %>])
                           ,UVM_DEBUG);

                 #0;

                 if(inject_fault_in_func_unit) begin
                   `uvm_info(report_id
                             ,$sformatf("forcing the <%=hier_path_dut[unit_idx]%>.<%=func_checker_inst_name[unit_idx]%>.func_<%=func_checker_inputs_array[unit_idx][rand_pos_in_signal_json]%> to value='h%0x at bit position=%0d\n"
                               ,(prev_val[<%=unit_idx%>][<%=rand_pos_in_signal_json%>] ^ (1'b1<<rand_pos_in_signal[<%= rand_pos_in_signal_json %>])), rand_pos_in_signal[<%= rand_pos_in_signal_json %>])
                             ,UVM_DEBUG);
                   force <%=hier_path_dut[unit_idx]%>.<%=func_checker_inst_name[unit_idx]%>.func_<%=func_checker_inputs_array[unit_idx][rand_pos_in_signal_json]%> = prev_val[<%=unit_idx%>][<%=rand_pos_in_signal_json%>] ^ (1'b1<<rand_pos_in_signal[<%= rand_pos_in_signal_json %>]);
                 end

                 repeat(<%= nResiliencyDelay_json %>) @(posedge tb_clk); // waiting for delay cycle set for latent unit
                 if (inject_fault_in_checker_unit) begin
                   `uvm_info(report_id
                             ,$sformatf("forcing the <%=hier_path_dut[unit_idx]%>.<%=func_checker_inst_name[unit_idx]%>.check_<%=func_checker_inputs_array[unit_idx][rand_pos_in_signal_json]%> to value='h%0x at bit position=%0d\n"
                               ,(prev_val[<%=unit_idx%>][<%=rand_pos_in_signal_json%>] ^ (1'b1<<rand_pos_in_signal[<%= rand_pos_in_signal_json %>])), rand_pos_in_signal[<%= rand_pos_in_signal_json %>])
                             ,UVM_DEBUG);

                   force <%=hier_path_dut[unit_idx]%>.<%=func_checker_inst_name[unit_idx]%>.check_<%=func_checker_inputs_array[unit_idx][rand_pos_in_signal_json]%> = prev_val[<%=unit_idx%>][<%=rand_pos_in_signal_json%>] ^ (1'b1<<rand_pos_in_signal[<%= rand_pos_in_signal_json %>]);
                   repeat(2)@(posedge tb_clk);
                 end
                 // release
                 repeat(2)@(posedge tb_clk);
                 if(inject_fault_in_func_unit) begin
                   `uvm_info(report_id
                             ,$sformatf("releasing the value 'h%0x -> 'h%0x on <%=hier_path_dut[unit_idx]%>.<%=func_checker_inst_name[unit_idx]%>.func_<%=func_checker_inputs_array[unit_idx][rand_pos_in_signal_json]%> at bit position=%0d\n"
                             ,<%=hier_path_dut[unit_idx]%>.<%=func_checker_inst_name[unit_idx]%>.func_<%=func_checker_inputs_array[unit_idx][rand_pos_in_signal_json]%>, prev_val[<%=unit_idx%>][<%=rand_pos_in_signal_json%>], rand_pos_in_signal[<%= rand_pos_in_signal_json %>])
                             ,UVM_DEBUG);
                   force <%=hier_path_dut[unit_idx]%>.<%=func_checker_inst_name[unit_idx]%>.func_<%=func_checker_inputs_array[unit_idx][rand_pos_in_signal_json]%> = prev_val[<%=unit_idx%>][<%=rand_pos_in_signal_json%>];
                   release <%=hier_path_dut[unit_idx]%>.<%=func_checker_inst_name[unit_idx]%>.func_<%=func_checker_inputs_array[unit_idx][rand_pos_in_signal_json]%>;
                   repeat(<%= nResiliencyDelay_json %>) @(posedge tb_clk);
                 end
                 if (inject_fault_in_checker_unit) begin
                    `uvm_info(report_id
                             ,$sformatf("releasing the value 'h%0x -> 'h%0x on <%=hier_path_dut[unit_idx]%>.<%=func_checker_inst_name[unit_idx]%>.check_<%=func_checker_inputs_array[unit_idx][rand_pos_in_signal_json]%> at bit position=%0d\n"
                             ,<%=hier_path_dut[unit_idx]%>.<%=func_checker_inst_name[unit_idx]%>.check_<%=func_checker_inputs_array[unit_idx][rand_pos_in_signal_json]%>, prev_val[<%=unit_idx%>][<%=rand_pos_in_signal_json%>], rand_pos_in_signal[<%= rand_pos_in_signal_json %>])
                             ,UVM_DEBUG);
                   force <%=hier_path_dut[unit_idx]%>.<%=func_checker_inst_name[unit_idx]%>.check_<%=func_checker_inputs_array[unit_idx][rand_pos_in_signal_json]%> = prev_val[<%=unit_idx%>][<%=rand_pos_in_signal_json%>];
                   release <%=hier_path_dut[unit_idx]%>.<%=func_checker_inst_name[unit_idx]%>.check_<%=func_checker_inputs_array[unit_idx][rand_pos_in_signal_json]%>;
                 end
               end
             <% } %>
               join
                //Any mismatch in output signals of the functional unit and late unit excluding uncorrectable faults causes a mission fault.
                case ({inject_fault_in_checker_unit,inject_fault_in_func_unit})
                       'b00 //No fault injection
                      ,'b11 //Fault injection in functional and checker block
                       : begin
                           tb_mission_fault_ud[<%=unit_idx%>] = 0;
                           tb_latent_fault_ud[<%=unit_idx%>]  = 0;
                         end
                       'b01 //Fault injection in functional block
                      ,'b10 //Fault injection in checker block
                       : begin
                           tb_mission_fault_ud[<%=unit_idx%>] = 1;
                           tb_latent_fault_ud[<%=unit_idx%>]  = 0;
                         end
                   default : begin
                             end
                endcase
                repeat(2) @(posedge tb_clk);
                start_checker = 1;
                repeat(delay_bw_two_faults) @(posedge tb_clk);
                #5ps;

                start_checker = 0;
                repeat(10)@(posedge tb_clk);
                //Calling bist_sequence to reset the faults
                bist_seq(`__LINE__,1);

            <% } %> // Java for loop for all units (unit_idx < unit_idx_max)
           end //end rpt_cnt
           ///////////////////////////////////////////////////////////////////////////////////////////////////////////////
           //         SRAM unit duplication fault injection                            ///////////////////////////////////
           ///////////////////////////////////////////////////////////////////////////////////////////////////////////////
           `uvm_info(report_id, "Testing now for SRAM", UVM_LOW)
           for(int rpt_cnt=0;rpt_cnt<2;rpt_cnt++) begin
             <% if(obj.testBench == 'dmi') { %>
             automatic uvm_event dmi_reset_event = ev_pool.get("dmi_reset_event");
             automatic uvm_event dmi_reset_event_complete = ev_pool.get("dmi_reset_event_complete");
             avoid_dual_port_contention = $urandom_range(0,1);
             <% } %>
             inject_fault_in_func_unit    = $urandom_range(0,1);
             inject_fault_in_checker_unit = inject_fault_in_func_unit ? 0 : 1; //Can only inject in one or the other can't match internal states once logic starts toggling
             `uvm_info(report_id ,$sformatf("repeat_cnt:%0d | Fault injection in Function unit %0b Checker unit %0b for SRAM", rpt_cnt, inject_fault_in_func_unit, inject_fault_in_checker_unit),UVM_NONE);

            <% for  (var unit_idx = unit_idx_min; unit_idx < unit_idx_max; unit_idx++) {
                if( (obj.testBench == "dmi") &&  (func_checker_sram_inputs_array[0].length != 0) ) { %>
              force <%=hier_path_dut[unit_idx]%>.bist_bist_next = 1'b0;
              repeat(5)@(posedge tb_clk);

              @(negedge tb_clk);

               fork
             <% for  (var unit_idx_1 = unit_idx_min; unit_idx_1 < func_checker_sram_inputs_array[0].length; unit_idx_1++) { %>
             <% rand_pos_in_signal_json = unit_idx_1; %>
             <% if( !(func_checker_sram_inputs_array[unit_idx][rand_pos_in_signal_json].includes("sb_mem_read_addr") && func_checker_sram_inputs_array[unit_idx][rand_pos_in_signal_json].includes("sb_mem_write_addr")) ) { %>
               begin
                 prev_val[<%=unit_idx%>][<%=rand_pos_in_signal_json%>] = <%=hier_path_dut[unit_idx]%>.<%=func_checker_inst_name[unit_idx]%>.func_<%=func_checker_sram_inputs_array[unit_idx][rand_pos_in_signal_json]%>;
                 // Either only one output will be driven to different values in func or check units or all the outputs or will be selected randomly
                 signal_width[<%= rand_pos_in_signal_json %>] = $bits(<%=hier_path_dut[unit_idx]%>.<%=func_checker_inst_name[unit_idx]%>.func_<%=func_checker_sram_inputs_array[unit_idx][rand_pos_in_signal_json]%>);
                 rand_pos_in_signal[<%= rand_pos_in_signal_json %>] = $urandom_range(0, signal_width[<%= rand_pos_in_signal_json %>]-1);
                 // Sample at negedge of tb_clk, when signal values are stable
                 `uvm_info(report_id
                           ,$sformatf("reading the value ='h%0x from <%=hier_path_dut[unit_idx]%>.<%=func_checker_inst_name[unit_idx]%>.func_<%=func_checker_sram_inputs_array[unit_idx][rand_pos_in_signal_json]%>, rand_pos_in_signal[<%= rand_pos_in_signal_json %>]=%0d\n"
                             ,prev_val[<%=unit_idx%>][<%=rand_pos_in_signal_json%>], rand_pos_in_signal[<%= rand_pos_in_signal_json %>])
                           ,UVM_DEBUG);

                 #0;

                 if(inject_fault_in_func_unit) begin
                 <% if(func_checker_sram_inputs_array[unit_idx][rand_pos_in_signal_json].includes("sb_mem_read_en")) {%>
                     `uvm_info(report_id
                             ,$sformatf("forcing the <%=hier_path_dut[unit_idx]%>.<%=func_checker_inst_name[unit_idx]%>.func_<%=func_checker_sram_inputs_array[unit_idx][rand_pos_in_signal_json]%> to value='h%0x\n"
                               ,avoid_dual_port_contention)
                             ,UVM_DEBUG);
                   force <%=hier_path_dut[unit_idx]%>.<%=func_checker_inst_name[unit_idx]%>.func_<%=func_checker_sram_inputs_array[unit_idx][rand_pos_in_signal_json]%> = avoid_dual_port_contention;
                 <%} else if (func_checker_sram_inputs_array[unit_idx][rand_pos_in_signal_json].includes("sb_mem_write_en"))  {%>
                     `uvm_info(report_id
                             ,$sformatf("forcing the <%=hier_path_dut[unit_idx]%>.<%=func_checker_inst_name[unit_idx]%>.func_<%=func_checker_sram_inputs_array[unit_idx][rand_pos_in_signal_json]%> to value='h%0x\n"
                               ,~avoid_dual_port_contention)
                             ,UVM_DEBUG);
                   force <%=hier_path_dut[unit_idx]%>.<%=func_checker_inst_name[unit_idx]%>.func_<%=func_checker_sram_inputs_array[unit_idx][rand_pos_in_signal_json]%> = ~avoid_dual_port_contention;

                 <%} else {%>
                   `uvm_info(report_id
                             ,$sformatf("forcing the <%=hier_path_dut[unit_idx]%>.<%=func_checker_inst_name[unit_idx]%>.func_<%=func_checker_sram_inputs_array[unit_idx][rand_pos_in_signal_json]%> to value='h%0x at bit position=%0d\n"
                               ,(prev_val[<%=unit_idx%>][<%=rand_pos_in_signal_json%>] ^ (1'b1<<rand_pos_in_signal[<%= rand_pos_in_signal_json %>])), rand_pos_in_signal[<%= rand_pos_in_signal_json %>])
                             ,UVM_DEBUG);
                   force <%=hier_path_dut[unit_idx]%>.<%=func_checker_inst_name[unit_idx]%>.func_<%=func_checker_sram_inputs_array[unit_idx][rand_pos_in_signal_json]%> = prev_val[<%=unit_idx%>][<%=rand_pos_in_signal_json%>] ^ (1'b1<<rand_pos_in_signal[<%= rand_pos_in_signal_json %>]);
                 <%}%>
                 end

                 repeat(<%= nResiliencyDelay_json %>) @(posedge tb_clk); // waiting for delay cycle set for latent unit
                 if (inject_fault_in_checker_unit) begin
                 <% if(func_checker_sram_inputs_array[unit_idx][rand_pos_in_signal_json].includes("sb_mem_read_en")) {%>
                   `uvm_info(report_id
                             ,$sformatf("forcing the <%=hier_path_dut[unit_idx]%>.<%=func_checker_inst_name[unit_idx]%>.check_<%=func_checker_sram_inputs_array[unit_idx][rand_pos_in_signal_json]%> to value='h%0x\n"
                               ,avoid_dual_port_contention)
                             ,UVM_DEBUG);

                   force <%=hier_path_dut[unit_idx]%>.<%=func_checker_inst_name[unit_idx]%>.check_<%=func_checker_sram_inputs_array[unit_idx][rand_pos_in_signal_json]%> = avoid_dual_port_contention;
                 <%} else if (func_checker_sram_inputs_array[unit_idx][rand_pos_in_signal_json].includes("sb_mem_write_en"))  {%>
                   `uvm_info(report_id
                             ,$sformatf("forcing the <%=hier_path_dut[unit_idx]%>.<%=func_checker_inst_name[unit_idx]%>.check_<%=func_checker_sram_inputs_array[unit_idx][rand_pos_in_signal_json]%> to value='h%0x\n"
                               ,~avoid_dual_port_contention)
                             ,UVM_DEBUG);

                   force <%=hier_path_dut[unit_idx]%>.<%=func_checker_inst_name[unit_idx]%>.check_<%=func_checker_sram_inputs_array[unit_idx][rand_pos_in_signal_json]%> = ~avoid_dual_port_contention;
                 <%} else {%>
                   `uvm_info(report_id
                             ,$sformatf("forcing the <%=hier_path_dut[unit_idx]%>.<%=func_checker_inst_name[unit_idx]%>.check_<%=func_checker_sram_inputs_array[unit_idx][rand_pos_in_signal_json]%> to value='h%0x at bit position=%0d\n"
                               ,(prev_val[<%=unit_idx%>][<%=rand_pos_in_signal_json%>] ^ (1'b1<<rand_pos_in_signal[<%= rand_pos_in_signal_json %>])), rand_pos_in_signal[<%= rand_pos_in_signal_json %>])
                             ,UVM_DEBUG);

                   force <%=hier_path_dut[unit_idx]%>.<%=func_checker_inst_name[unit_idx]%>.check_<%=func_checker_sram_inputs_array[unit_idx][rand_pos_in_signal_json]%> = prev_val[<%=unit_idx%>][<%=rand_pos_in_signal_json%>] ^ (1'b1<<rand_pos_in_signal[<%= rand_pos_in_signal_json %>]);
                 <% } %>
                   repeat(2)@(posedge tb_clk);
                 end
                 // release
                 repeat(2)@(posedge tb_clk);
                 if(inject_fault_in_func_unit) begin
                   `uvm_info(report_id
                             ,$sformatf("releasing the value 'h%0x -> 'h%0x on <%=hier_path_dut[unit_idx]%>.<%=func_checker_inst_name[unit_idx]%>.func_<%=func_checker_sram_inputs_array[unit_idx][rand_pos_in_signal_json]%> at bit position=%0d\n"
                             ,<%=hier_path_dut[unit_idx]%>.<%=func_checker_inst_name[unit_idx]%>.func_<%=func_checker_sram_inputs_array[unit_idx][rand_pos_in_signal_json]%>, prev_val[<%=unit_idx%>][<%=rand_pos_in_signal_json%>], rand_pos_in_signal[<%= rand_pos_in_signal_json %>])
                             ,UVM_DEBUG);
                   force <%=hier_path_dut[unit_idx]%>.<%=func_checker_inst_name[unit_idx]%>.func_<%=func_checker_sram_inputs_array[unit_idx][rand_pos_in_signal_json]%> = prev_val[<%=unit_idx%>][<%=rand_pos_in_signal_json%>];
                   release <%=hier_path_dut[unit_idx]%>.<%=func_checker_inst_name[unit_idx]%>.func_<%=func_checker_sram_inputs_array[unit_idx][rand_pos_in_signal_json]%>;
                   repeat(<%= nResiliencyDelay_json %>) @(posedge tb_clk);
                 end
                 if (inject_fault_in_checker_unit) begin
                    `uvm_info(report_id
                             ,$sformatf("releasing the value 'h%0x -> 'h%0x on <%=hier_path_dut[unit_idx]%>.<%=func_checker_inst_name[unit_idx]%>.check_<%=func_checker_sram_inputs_array[unit_idx][rand_pos_in_signal_json]%> at bit position=%0d\n"
                             ,<%=hier_path_dut[unit_idx]%>.<%=func_checker_inst_name[unit_idx]%>.check_<%=func_checker_sram_inputs_array[unit_idx][rand_pos_in_signal_json]%>, prev_val[<%=unit_idx%>][<%=rand_pos_in_signal_json%>], rand_pos_in_signal[<%= rand_pos_in_signal_json %>])
                             ,UVM_DEBUG);
                   force <%=hier_path_dut[unit_idx]%>.<%=func_checker_inst_name[unit_idx]%>.check_<%=func_checker_sram_inputs_array[unit_idx][rand_pos_in_signal_json]%> = prev_val[<%=unit_idx%>][<%=rand_pos_in_signal_json%>];
                   release <%=hier_path_dut[unit_idx]%>.<%=func_checker_inst_name[unit_idx]%>.check_<%=func_checker_sram_inputs_array[unit_idx][rand_pos_in_signal_json]%>;
                 end
               end
             <% } %>
             <% } %>
               join
               tb_mission_fault_ud[<%=unit_idx%>] = inject_fault_in_func_unit ^ inject_fault_in_checker_unit;
               tb_latent_fault_ud[<%=unit_idx%>]  = 0;
               repeat(2) @(posedge tb_clk);
               start_checker = 1;
               repeat(delay_bw_two_faults) @(posedge tb_clk);
               #5ps;
               start_checker = 0;
               repeat(10)@(posedge tb_clk);
               //Force system reset to ensure all SRAM logic that toggle are cleared
               <% if(obj.testBench == 'dmi') { %>
               dmi_reset_event.trigger();
               dmi_reset_event_complete.wait_trigger();
               <% } %>
               bist_seq(`__LINE__);
            <% } } %> // Java for loop for all units (unit_idx < unit_idx_max)
           end //end rpt_cnt
           /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
           ///////////////////////////////////////End SRAM error testing ///////////////////////////////////////////////////////////////////////////
           /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
           //////////////////////////////////////////  Cover XOR Tree | Toggle all bits of every signal of func_checker_inputs_array////////////////
           /////Uses JS func_checker_inputs_array ///
           for(int rpt_cnt=0;rpt_cnt<2;rpt_cnt++) begin
             `uvm_info(report_id ,$sformatf("Forcing all bits at once to cover the remaining code coverage of *fault_xor_tree") ,UVM_NONE);
             inject_fault_in_checker_unit = 1;
             inject_fault_in_func_unit    = 1;
             mod2_cnt = ((rpt_cnt%2)==0) ? 'b1: 'b0;

            <% for  (var unit_idx = unit_idx_min; unit_idx < unit_idx_max; unit_idx++) { %>

               fork
             <% for  (var unit_idx_1 = unit_idx_min; unit_idx_1 < func_checker_inputs_array[0].length; unit_idx_1++) { %>
             <% rand_pos_in_signal_json = unit_idx_1; %>
               begin
                 prev_val[<%=unit_idx%>][<%=rand_pos_in_signal_json%>] = <%=hier_path_dut[unit_idx]%>.<%=func_checker_inst_name[unit_idx]%>.func_<%=func_checker_inputs_array[unit_idx][rand_pos_in_signal_json]%>;

                 #0;
                 if(inject_fault_in_func_unit) begin
                   `uvm_info(report_id ,$sformatf("forcing the <%=hier_path_dut[unit_idx]%>.<%=func_checker_inst_name[unit_idx]%>.func_<%=func_checker_inputs_array[unit_idx][rand_pos_in_signal_json]%> to all bits as %0d \n", (~mod2_cnt ? 'b1: 'b0)) ,UVM_DEBUG);
                   force <%=hier_path_dut[unit_idx]%>.<%=func_checker_inst_name[unit_idx]%>.func_<%=func_checker_inputs_array[unit_idx][rand_pos_in_signal_json]%> = ~mod2_cnt ? '1: '0;
                 end

                 repeat(<%= nResiliencyDelay_json %>) @(posedge tb_clk); // waiting for delay cycle set for latent unit
                 if(inject_fault_in_checker_unit) begin
                   `uvm_info(report_id ,$sformatf("forcing the <%=hier_path_dut[unit_idx]%>.<%=func_checker_inst_name[unit_idx]%>.check_<%=func_checker_inputs_array[unit_idx][rand_pos_in_signal_json]%> to all bits as %0d \n", (mod2_cnt ? 'b1: 'b0)) ,UVM_DEBUG);

                   force <%=hier_path_dut[unit_idx]%>.<%=func_checker_inst_name[unit_idx]%>.check_<%=func_checker_inputs_array[unit_idx][rand_pos_in_signal_json]%> = mod2_cnt ? '1: '0;
                   repeat(2)@(posedge tb_clk);
                 end
                 // release
                 repeat(5)@(posedge tb_clk);
                 if(inject_fault_in_func_unit) begin
                   force <%=hier_path_dut[unit_idx]%>.<%=func_checker_inst_name[unit_idx]%>.func_<%=func_checker_inputs_array[unit_idx][rand_pos_in_signal_json]%> = prev_val[<%=unit_idx%>][<%=rand_pos_in_signal_json%>];
                   release <%=hier_path_dut[unit_idx]%>.<%=func_checker_inst_name[unit_idx]%>.func_<%=func_checker_inputs_array[unit_idx][rand_pos_in_signal_json]%>;
                   repeat(<%= nResiliencyDelay_json %>) @(posedge tb_clk);
                 end
                 if (inject_fault_in_checker_unit) begin
                   force <%=hier_path_dut[unit_idx]%>.<%=func_checker_inst_name[unit_idx]%>.check_<%=func_checker_inputs_array[unit_idx][rand_pos_in_signal_json]%> = prev_val[<%=unit_idx%>][<%=rand_pos_in_signal_json%>];
                   release <%=hier_path_dut[unit_idx]%>.<%=func_checker_inst_name[unit_idx]%>.check_<%=func_checker_inputs_array[unit_idx][rand_pos_in_signal_json]%>;
                 end
               end
             <% } %>
               join

               tb_mission_fault_ud[<%=unit_idx%>] = 1;
               tb_latent_fault_ud[<%=unit_idx%>]  = 0;
               repeat(2) @(posedge tb_clk);
               start_checker = 1;
               repeat(delay_bw_two_faults) @(posedge tb_clk);
               #5ps;

               start_checker = 0;
               repeat(10)@(posedge tb_clk);
               //Calling bist_sequence to reset the faults
               bist_seq(`__LINE__,1);
            <% } %>
           end //end rpt_cnt : 2


        ////////////////////////////////////////////// End Coverage ////////////////////////////////////////////////////////////////////////////////

           /*
             `uvm_info(report_id, "Releasing UECC as 0", UVM_LOW);
             <% for(var i in unit_uecc_outputs_array[0]) { %>
                  release <%=hier_path_dut[0]%>.<%=unit_uecc_outputs_array[0][i]%>;
                  release <%=hier_path_dut[0]%>.<%=check_uecc_outputs_array[0][i]%>;
             <% } %>
           */

        ////////////////////////////////////////////// Begin Testing UECC ///////////////////////////////////
        ////Uses JS unit_uecc_outputs_array ////extra code for ioaiu ////////////////
           `uvm_info(report_id, "Testing now for UECC", UVM_LOW)
           // inject uecc for unit duplication through force
           //#Test.IOAIU.Resilince.Unitduplication
           //#Stimulus.IOAIU.Resilince.Unitduplication
           begin //if($test$plusargs("inject_latent_fault")) begin
             start_uecc_cov_sample = 1;
             for(int i_ilf=0;i_ilf<4;i_ilf++) begin
                /*
                 *|--------------------------+--------------------+---------------+--------------|
                 *| Uncorrectable Functional | Uncorrectable Late | Mission Fault | Latent Fault |
                 *|--------------------------+--------------------+---------------+--------------|
                 *| 1                        | 1                  | 1             | 0            |
                 *|--------------------------+--------------------+---------------+--------------|
                 *| 1                        | 0                  | 1             | 1            |
                 *|--------------------------+--------------------+---------------+--------------|
                 *| 0                        | 1                  | 1             | 1            |
                 *|--------------------------+--------------------+---------------+--------------|
                 *| 0                        | 0                  | 0             | 0            |
                 *|--------------------------+--------------------+---------------+--------------|
                 */

                 /*
                  *1. uecc change should be late by 1 clock cycle due to late_unit mimic
                  *   before feeding into checker unit.
                  *2. hold the uecc error value untill coverage gets sampled on fault assertion
                  *3. mission fault requires 2 clock to alter if going to change
                  */
               {inject_fault_in_checker_unit,inject_fault_in_func_unit} = $urandom_range(0,3); //i_ilf; //2-bit possibilites
               //{inject_fault_in_checker_unit,inject_fault_in_func_unit} = 'b10;/*no functional fault through force to avoid false coverage*///i_ilf;
               `uvm_info(report_id ,$sformatf("func_checker_inputs_uecc: Fault injection in Checker_unit=%0b Function_unit=%0b", inject_fault_in_checker_unit, inject_fault_in_func_unit), UVM_NONE);

               <% rand_pos_in_signal_json = Math.floor(Math.random() * unit_uecc_outputs_array[0].length); %>
               signal_width[<%= rand_pos_in_signal_json %>] = $bits(<%=hier_path_dut[0]%>.<%=unit_uecc_outputs_array[0][rand_pos_in_signal_json]%>);
               rand_pos_in_signal[<%= rand_pos_in_signal_json %>] = $urandom_range(0, signal_width[<%= rand_pos_in_signal_json %>]-1);
               //uvm_config_db#(bit)::set(uvm_root::get(), "", "test_unit_duplication_uecc", 1);
               case({inject_fault_in_checker_unit,inject_fault_in_func_unit})
                 'b00 : begin
                   // do nothing
                   start_uecc_cov_sample = 1;
                   tb_mission_fault_ud[0] = 0;
                   tb_latent_fault_ud[0]  = 0;
                   start_checker_ilf = 1;
                 end
                 'b01 : begin
                   start_uecc_cov_sample = 1;
                   force <%=hier_path_dut[0]%>.<%=unit_uecc_outputs_array[0][rand_pos_in_signal_json]%>= 1<<rand_pos_in_signal[<%= rand_pos_in_signal_json %>];
                   `uvm_info(report_id ,$sformatf("Force uncorrectable value inside functional unit %0s as %0b",`"<%=hier_path_dut[0]%>.<%=unit_uecc_outputs_array[0][rand_pos_in_signal_json]%>`",<%=hier_path_dut[0]%>.<%=unit_uecc_outputs_array[0][rand_pos_in_signal_json]%>), UVM_DEBUG);
                   tb_mission_fault_ud[0] = 1;
                   tb_latent_fault_ud[0]  = 0;
                   repeat(<%= nResiliencyDelay_json %>) @(posedge tb_clk); //#3
                   repeat(2) @(posedge tb_clk);
                   start_checker_ilf = 1;
                   repeat(5) @(posedge tb_clk); //#2
                   release <%=hier_path_dut[0]%>.<%=unit_uecc_outputs_array[0][rand_pos_in_signal_json]%>;
                 end
                 'b10 : begin
                   start_uecc_cov_sample = 1;
                   force <%=hier_path_dut[0]%>.<%=check_uecc_outputs_array[0][rand_pos_in_signal_json]%> = 1<<rand_pos_in_signal[<%= rand_pos_in_signal_json %>];
                   `uvm_info(report_id ,$sformatf("Force uncorrectable value inside checker unit %0s as %0b",`"<%=hier_path_dut[0]%>.<%=check_uecc_outputs_array[0][rand_pos_in_signal_json]%>`",<%=hier_path_dut[0]%>.<%=check_uecc_outputs_array[0][rand_pos_in_signal_json]%>), UVM_DEBUG);
                   tb_mission_fault_ud[0] = 1;
                   tb_latent_fault_ud[0]  = 0;
                   repeat(4) @(posedge tb_clk);
                   start_checker_ilf = 1;
                   repeat(5) @(posedge tb_clk); //#2
                   release <%=hier_path_dut[0]%>.<%=check_uecc_outputs_array[0][rand_pos_in_signal_json]%>;
                 end
                 'b11 : begin
                   start_uecc_cov_sample = 1;
                   force <%=hier_path_dut[0]%>.<%=unit_uecc_outputs_array[0][rand_pos_in_signal_json]%> = 1<<rand_pos_in_signal[<%= rand_pos_in_signal_json %>];
                   `uvm_info(report_id ,$sformatf("Force uncorrectable value inside functional unit %0s as %0b",`"<%=hier_path_dut[0]%>.<%=unit_uecc_outputs_array[0][rand_pos_in_signal_json]%>`",<%=hier_path_dut[0]%>.<%=unit_uecc_outputs_array[0][rand_pos_in_signal_json]%>), UVM_DEBUG);

                   //determine new signal for duplicate unit with random position
                   <% rand_pos_in_signal_prev_json = rand_pos_in_signal_json ;%>
                   <% rand_pos_in_signal_json = Math.floor(Math.random() * check_uecc_outputs_array[0].length); %>
                   signal_width[<%= rand_pos_in_signal_json %>] = $bits(<%=hier_path_dut[0]%>.<%=check_uecc_outputs_array[0][rand_pos_in_signal_json]%>);
                   rand_pos_in_signal[<%= rand_pos_in_signal_json %>] = $urandom_range(0, signal_width[<%= rand_pos_in_signal_json %>]-1);

                   repeat(<%= nResiliencyDelay_json %>)@(posedge tb_clk); //#1
                   force <%=hier_path_dut[0]%>.<%=check_uecc_outputs_array[0][rand_pos_in_signal_json]%> = 1<<rand_pos_in_signal[<%= rand_pos_in_signal_json %>];
                   `uvm_info(report_id ,$sformatf("Force uncorrectable value inside checker unit %0s as %0b",`"<%=hier_path_dut[0]%>.<%=check_uecc_outputs_array[0][rand_pos_in_signal_json]%>`",<%=hier_path_dut[0]%>.<%=check_uecc_outputs_array[0][rand_pos_in_signal_json]%>), UVM_DEBUG);
                   tb_mission_fault_ud[0] = 1;
                   tb_latent_fault_ud[0]  = 0;
                   repeat(2) @(posedge tb_clk);
                   start_checker_ilf = 1;
                   repeat(5) @(posedge tb_clk); //#2
                   release <%=hier_path_dut[0]%>.<%=unit_uecc_outputs_array[0][rand_pos_in_signal_prev_json]%>;
                   repeat(<%= nResiliencyDelay_json %>)@(posedge tb_clk); //#1
                   release <%=hier_path_dut[0]%>.<%=check_uecc_outputs_array[0][rand_pos_in_signal_json]%>;
                 end
               endcase
               repeat(delay_bw_two_faults*10) @(posedge tb_clk);
               start_checker_ilf = 0;
               start_uecc_cov_sample = 0;
               @(posedge tb_clk) bist_seq(`__LINE__);

          <%if(obj.testBench == 'io_aiu') {%>
              // Test output signals for unitduplication 
              <% for(i=0; i < ioaiu_unit_outputs_array[0].length; i++) {%>
              signal_width[<%= i %>] = $bits(<%=hier_path_dut[0]%>.<%=ioaiu_unit_outputs_array[0][i]%>);
              Fun_signal_val[<%= i %>] =  $urandom_range(0, ((2**signal_width[<%= i %>])-1));
              do begin
              Delay_signal_val[<%= i %>]   =  $urandom_range(0, ((2**signal_width[<%= i %>])-1));    
              end while(Fun_signal_val[<%= i %>]  ==  Delay_signal_val[<%= i %>] ); 
              output_signal =   "<%=ioaiu_unit_outputs_array[0][i]%>";
              case({inject_fault_in_checker_unit,inject_fault_in_func_unit})
                 'b00 : begin
                   // do nothing
                   start_out_cov_sample = 1;
                   tb_mission_fault_ud[0] = 0;
                   tb_latent_fault_ud[0]  = 0;
                   start_checker_ilf = 1;
                  end
                 'b01 : begin
                   start_out_cov_sample = 1;
                   force <%=hier_path_dut[0]%>.<%=ioaiu_unit_outputs_array[0][i]%>  = Fun_signal_val[<%= i %>];
		   force <%=hier_path_dut[0]%>.<%=check_outputs_array[0][i]%> = Delay_signal_val[<%= i %>];

                   `uvm_info(report_id ,$sformatf("Force uncorrectable value inside functional unit %0s as %0b Delay_Dup signals %0s val is %0b",`"<%=hier_path_dut[0]%>.<%=ioaiu_unit_outputs_array[0][i]%>`",<%=hier_path_dut[0]%>.<%=ioaiu_unit_outputs_array[0][i]%>,`"<%=hier_path_dut[0]%>.<%=check_outputs_array[0][i]%>`",<%=hier_path_dut[0]%>.<%=check_outputs_array[0][i]%>), UVM_DEBUG);
                   tb_mission_fault_ud[0] = 1;
                   tb_latent_fault_ud[0]  = 0;
                   repeat(<%= nResiliencyDelay_json %>) @(posedge tb_clk); //#3
                   repeat(10) @(posedge tb_clk);
                   start_checker_ilf = 1;
                   release <%=hier_path_dut[0]%>.<%=ioaiu_unit_outputs_array[0][i]%>;
		   release <%=hier_path_dut[0]%>.<%=check_outputs_array[0][i]%>;
                 end
                 'b10 : begin
                   start_out_cov_sample = 1;
		   force <%=hier_path_dut[0]%>.<%=ioaiu_unit_outputs_array[0][i]%>  = Fun_signal_val[<%= i %>];
		   force <%=hier_path_dut[0]%>.<%=check_outputs_array[0][i]%> = Delay_signal_val[<%= i %>];
                   `uvm_info(report_id ,$sformatf("Force uncorrectable value inside checker unit %0s as %0b",`"<%=hier_path_dut[0]%>.<%=check_outputs_array[0][i]%>`",<%=hier_path_dut[0]%>.<%=check_outputs_array[0][i]%>), UVM_DEBUG);
                   `uvm_info(report_id ,$sformatf("Force uncorrectable value inside functional unit %0s as %0b Delay_Dup signals %0s val is %0b",`"<%=hier_path_dut[0]%>.<%=ioaiu_unit_outputs_array[0][i]%>`",<%=hier_path_dut[0]%>.<%=ioaiu_unit_outputs_array[0][i]%>,`"<%=hier_path_dut[0]%>.<%=check_outputs_array[0][i]%>`",<%=hier_path_dut[0]%>.<%=check_outputs_array[0][i]%>), UVM_DEBUG);
                   tb_mission_fault_ud[0] = 1;
                   tb_latent_fault_ud[0]  = 0;
                   repeat(10) @(posedge tb_clk);
                   start_checker_ilf = 1;
                   release <%=hier_path_dut[0]%>.<%=check_outputs_array[0][i]%>;
		   release <%=hier_path_dut[0]%>.<%=ioaiu_unit_outputs_array[0][i]%>;
                 end
                 'b11 : begin
                   start_out_cov_sample = 1;
                   force <%=hier_path_dut[0]%>.<%=ioaiu_unit_outputs_array[0][i]%> = Fun_signal_val[<%= i %>];
                   repeat(<%= nResiliencyDelay_json %>)@(posedge tb_clk); //#1
                   force <%=hier_path_dut[0]%>.<%=check_outputs_array[0][i]%> = Fun_signal_val[<%= i %>];
                   `uvm_info(report_id ,$sformatf("Force uncorrectable value inside functional unit %0s as %0b",`"<%=hier_path_dut[0]%>.<%=ioaiu_unit_outputs_array[0][i]%>`",<%=hier_path_dut[0]%>.<%=ioaiu_unit_outputs_array[0][i]%>), UVM_DEBUG);
                   
                   tb_mission_fault_ud[0] = 0;
                   tb_latent_fault_ud[0]  = 0;
                   repeat(2) @(posedge tb_clk);
                   start_checker_ilf = 1;
                   repeat(5) @(posedge tb_clk); //#2
                   release <%=hier_path_dut[0]%>.<%=ioaiu_unit_outputs_array[0][i]%>;
                   repeat(<%= nResiliencyDelay_json %>)@(posedge tb_clk); //#1
                   release <%=hier_path_dut[0]%>.<%=check_outputs_array[0][i]%>;
                 end
               endcase
               repeat(delay_bw_two_faults*10) @(posedge tb_clk);
               start_checker_ilf = 0;
               start_out_cov_sample = 0;
               repeat(10) @(posedge tb_clk);
               if(tb_top.dut.dup_unit.ioaiu_core0.t_busy == 1 || tb_top.dut.ioaiu_core_wrapper.ioaiu_core0.t_busy == 1) begin
               force tb_top.dut.clk_reset_n = 0;
                @(posedge tb_clk);
                force tb_top.dut.clk_reset_n = 1;
                tb_mission_fault_ud[0] = 0;
                tb_latent_fault_ud[0]  = 0;
               wait(tb_top.dut.dup_unit.ioaiu_core0.t_busy == 0 && tb_top.dut.ioaiu_core_wrapper.ioaiu_core0.t_busy == 0)
               repeat(10) @(posedge tb_clk);
               force tb_top.dut.clk_reset_n = 1;
               end
               @(posedge tb_clk) bist_seq(`__LINE__);
                <% } %>

               <% for(i=0; i < ioaiu_unit_output_array_out_sig[0].length; i++) {%>
              signal_width[<%= i %>] = $bits(<%=hier_path_dut[0]%>.<%=ioaiu_unit_output_array_out_sig[0][i]%>);
              Fun_signal_val[<%= i %>] =  $urandom_range(0, ((2**signal_width[<%= i %>])-1));
              do begin
              Delay_signal_val[<%= i %>]   =  $urandom_range(0, ((2**signal_width[<%= i %>])-1));    
              end while(Fun_signal_val[<%= i %>]  ==  Delay_signal_val[<%= i %>] );


                   force <%=hier_path_dut[0]%>.<%=ioaiu_unit_output_array_input_sig[0][i]%>  = 0;
                   repeat(<%= nResiliencyDelay_json %>)@(posedge tb_clk);
                   force <%=hier_path_dut[0]%>.<%=check_outputs_array_input_sig[0][i]%>      = 0;

                   repeat(5)@(posedge tb_clk);
                    
              case({inject_fault_in_checker_unit,inject_fault_in_func_unit})
                 'b00 : begin
                   // do nothing
                   start_out_cov_sample = 1;
                   tb_mission_fault_ud[0] = 0;
                   tb_latent_fault_ud[0]  = 0;
                 repeat(10) @(posedge tb_clk);
                   start_checker_ilf = 1;
                  end
                 'b01 : begin
                   start_out_cov_sample = 1;
                   force <%=hier_path_dut[0]%>.<%=ioaiu_unit_output_array_out_sig[0][i]%> = Fun_signal_val[<%= i %>];
                   repeat(<%= nResiliencyDelay_json %>)@(posedge tb_clk);
		   force <%=hier_path_dut[0]%>.<%=check_outputs_array_out_sig[0][i]%> = Delay_signal_val[<%= i %>];

                   `uvm_info(report_id ,$sformatf("Force uncorrectable value inside functional unit %0s as %0b Delay_Dup signals %0s val is %0b",`"<%=hier_path_dut[0]%>.<%=ioaiu_unit_output_array_out_sig[0][i]%>`",<%=hier_path_dut[0]%>.<%=ioaiu_unit_output_array_out_sig[0][i]%>,`"<%=hier_path_dut[0]%>.<%=check_outputs_array_out_sig[0][i]%>`",<%=hier_path_dut[0]%>.<%=check_outputs_array_out_sig[0][i]%>), UVM_LOW);
                   tb_mission_fault_ud[0] = 1;
                   tb_latent_fault_ud[0]  = 0;
                   repeat(<%= nResiliencyDelay_json %>) @(posedge tb_clk); //#3
                   repeat(10) @(posedge tb_clk);
                   start_checker_ilf = 1;
                   repeat(5) @(posedge tb_clk); //#2
                   release <%=hier_path_dut[0]%>.<%=ioaiu_unit_output_array_out_sig[0][i]%>;
                    repeat(<%= nResiliencyDelay_json %>)@(posedge tb_clk);
		   release <%=hier_path_dut[0]%>.<%=check_outputs_array_out_sig[0][i]%>;
                 end
                 'b10 : begin
                   start_out_cov_sample = 1;
		   force <%=hier_path_dut[0]%>.<%=ioaiu_unit_output_array_out_sig[0][i]%>  = Fun_signal_val[<%= i %>];
                   repeat(<%= nResiliencyDelay_json %>)@(posedge tb_clk);
		   force <%=hier_path_dut[0]%>.<%=check_outputs_array_out_sig[0][i]%> = Delay_signal_val[<%= i %>];
                   `uvm_info(report_id ,$sformatf("Force uncorrectable value inside checker unit %0s as %0b",`"<%=hier_path_dut[0]%>.<%=check_outputs_array_out_sig[0][i]%>`",<%=hier_path_dut[0]%>.<%=check_outputs_array_out_sig[0][i]%>), UVM_DEBUG);
                   `uvm_info(report_id ,$sformatf("Force uncorrectable value inside functional unit %0s as %0b Delay_Dup signals %0s val is %0b",`"<%=hier_path_dut[0]%>.<%=ioaiu_unit_output_array_out_sig[0][i]%>`",<%=hier_path_dut[0]%>.<%=ioaiu_unit_output_array_out_sig[0][i]%>,`"<%=hier_path_dut[0]%>.<%=check_outputs_array_out_sig[0][i]%>`",<%=hier_path_dut[0]%>.<%=check_outputs_array_out_sig[0][i]%>), UVM_LOW);
                   tb_mission_fault_ud[0] = 1;
                   tb_latent_fault_ud[0]  = 0;
                   repeat(10) @(posedge tb_clk);
                   start_checker_ilf = 1;
                   repeat(5) @(posedge tb_clk); //#2
		   
                   release <%=hier_path_dut[0]%>.<%=ioaiu_unit_output_array_out_sig[0][i]%>;
                   release <%=hier_path_dut[0]%>.<%=check_outputs_array_out_sig[0][i]%>;

                 end
                 'b11 : begin
                   start_out_cov_sample = 1;
                   force <%=hier_path_dut[0]%>.<%=ioaiu_unit_output_array_out_sig[0][i]%> = Fun_signal_val[<%= i %>];
                   repeat(<%= nResiliencyDelay_json %>)@(posedge tb_clk); //#1
                   force <%=hier_path_dut[0]%>.<%=check_outputs_array_out_sig[0][i]%> = Fun_signal_val[<%= i %>];
                   `uvm_info(report_id ,$sformatf("Force uncorrectable value inside functional unit %0s as %0b",`"<%=hier_path_dut[0]%>.<%=ioaiu_unit_output_array_out_sig[0][i]%>`",<%=hier_path_dut[0]%>.<%=ioaiu_unit_output_array_out_sig[0][i]%>), UVM_LOW);
                   
                   tb_mission_fault_ud[0] = 0;
                   tb_latent_fault_ud[0]  = 0;
                   repeat(10) @(posedge tb_clk);
                   start_checker_ilf = 1;
                   repeat(5) @(posedge tb_clk); //#2
                   release <%=hier_path_dut[0]%>.<%=ioaiu_unit_output_array_out_sig[0][i]%>;
                   repeat(<%= nResiliencyDelay_json %>)@(posedge tb_clk); //#1
                   release <%=hier_path_dut[0]%>.<%=check_outputs_array_out_sig[0][i]%>;
                 end
               endcase

                 repeat(5) @(posedge tb_clk);               
                 release <%=hier_path_dut[0]%>.<%=ioaiu_unit_output_array_input_sig[0][i]%>;
                 repeat(<%= nResiliencyDelay_json %>)@(posedge tb_clk); 
                 release <%=hier_path_dut[0]%>.<%=check_outputs_array_input_sig[0][i]%>;
              
               repeat(delay_bw_two_faults*10) @(posedge tb_clk);
               start_checker_ilf = 0;
               start_out_cov_sample = 0;
               repeat(10) @(posedge tb_clk);
               if(tb_top.dut.dup_unit.ioaiu_core0.t_busy == 1 || tb_top.dut.ioaiu_core_wrapper.ioaiu_core0.t_busy == 1) begin
               force tb_top.dut.clk_reset_n = 0;
                @(posedge tb_clk);
                force tb_top.dut.clk_reset_n = 1;
                tb_mission_fault_ud[0] = 0;
                tb_latent_fault_ud[0]  = 0;
               wait(tb_top.dut.dup_unit.ioaiu_core0.t_busy == 0 && tb_top.dut.ioaiu_core_wrapper.ioaiu_core0.t_busy == 0)
               repeat(10) @(posedge tb_clk);
               force tb_top.dut.clk_reset_n = 1;
               end
               @(posedge tb_clk) bist_seq(`__LINE__);
                <% } %>
                <% } %>
               end
               end



           // CONC-7562
           `uvm_info(report_id, "Testing now for cerr_threshold_max", UVM_LOW)
           delay_bw_two_faults =  $urandom_range(1,3);
           <% rand_pos_in_signal_json = Math.floor(Math.random() * unit_cecc_outputs_array[0].length); %>
           signal_width[<%= rand_pos_in_signal_json %>] = $bits(<%=hier_path_dut[0]%>.<%=func_checker_inst_name[0]%>.func_<%=unit_cecc_outputs_array[0][rand_pos_in_signal_json]%>);
           rand_pos_in_signal[<%= rand_pos_in_signal_json %>] = $urandom_range(0, signal_width[<%= rand_pos_in_signal_json %>]-1);
           cerr_threshold_max_value_no_bits = $bits(<%=hier_path_dut[0]%>.<%=func_checker_inst_name[0]%>.cerr_threshold);
           cerr_threshold_max_value = 2**cerr_threshold_max_value_no_bits;
           cerr_threshold_value = cerr_threshold_max_value -1;
           force <%=hier_path_dut[0]%>.<%=func_checker_inst_name[0]%>.cerr_threshold = cerr_threshold_value;
           force <%=hier_path_dut[0]%>.<%=func_checker_inst_name[0]%>.func_<%=unit_cecc_outputs_array[0][rand_pos_in_signal_json]%>= 1<<rand_pos_in_signal[<%= rand_pos_in_signal_json %>];
           `uvm_info(report_id ,$sformatf("Force correctable value inside functional unit %0s as %0b", "<%=hier_path_dut[0]%>.<%=func_checker_inst_name[0]%>.func_<%=unit_cecc_outputs_array[0][rand_pos_in_signal_json]%>" ,<%=hier_path_dut[0]%>.<%=func_checker_inst_name[0]%>.func_<%=unit_cecc_outputs_array[0][rand_pos_in_signal_json]%>), UVM_DEBUG);
           repeat(<%= nResiliencyDelay_json %>) @(posedge tb_clk);
           force <%=hier_path_dut[0]%>.<%=func_checker_inst_name[0]%>.check_<%=check_cecc_outputs_array[0][rand_pos_in_signal_json]%>= 1<<rand_pos_in_signal[<%= rand_pos_in_signal_json %>];
           `uvm_info(report_id ,$sformatf("Force correctable value inside checker unit %0s as %0b", "<%=hier_path_dut[0]%>.<%=func_checker_inst_name[0]%>.check_<%=check_cecc_outputs_array[0][rand_pos_in_signal_json]%>" ,<%=hier_path_dut[0]%>.<%=func_checker_inst_name[0]%>.check_<%=check_cecc_outputs_array[0][rand_pos_in_signal_json]%>), UVM_DEBUG);
           repeat(cerr_threshold_max_value + 3) @(posedge tb_clk);
           assert(<%=hier_path_dut[0]%>.fault_cerr_over_thres_fault === 1) begin
             `uvm_info(report_id ,$sformatf("cerr_counter value {RTL:%0d} must be higher than threshold value %0d, So cerr_over_thres_fault is asserted{%0d}" ,<%=hier_path_dut[0]%>.<%=func_checker_inst_name[0]%>.cerr_counter ,cerr_threshold_value ,<%=hier_path_dut[0]%>.<%=func_checker_inst_name[0]%>.cerr_over_thres_fault) ,UVM_DEBUG);
           end
           else begin
             `uvm_error(report_id ,$sformatf("cerr_counter value {RTL:%0d} must be higher than threshold value %0d, but cerr_over_thres_fault is not asserted{%0d}" ,<%=hier_path_dut[0]%>.<%=func_checker_inst_name[0]%>.cerr_counter ,cerr_threshold_value ,<%=hier_path_dut[0]%>.<%=func_checker_inst_name[0]%>.cerr_over_thres_fault));
           end
           repeat(delay_bw_two_faults) @(posedge tb_clk);
           release <%=hier_path_dut[0]%>.<%=func_checker_inst_name[0]%>.func_<%=unit_cecc_outputs_array[0][rand_pos_in_signal_json]%>;
           repeat(<%= nResiliencyDelay_json %>)@(posedge tb_clk);
           release <%=hier_path_dut[0]%>.<%=func_checker_inst_name[0]%>.check_<%=check_cecc_outputs_array[0][rand_pos_in_signal_json]%>;
           repeat(5) @(posedge tb_clk);
           release <%=hier_path_dut[0]%>.<%=func_checker_inst_name[0]%>.cerr_threshold;
           repeat(delay_bw_two_faults) @(posedge tb_clk);
           @(posedge tb_clk) bist_seq(`__LINE__);
           repeat(delay_bw_two_faults) @(posedge tb_clk);

           // check for threshold maximum value overflow. CONC-7033
           `uvm_info(report_id, "Testing now for cerr_threshold", UVM_LOW)
         <% for  (var unit_idx = unit_idx_min; unit_idx < unit_idx_max; unit_idx++) { %>
         <% for  (var unit_idx_1 = unit_idx_min; unit_idx_1 < unit_cecc_outputs_array[unit_idx].length; unit_idx_1++) { %>
           begin
           delay_bw_two_faults =  $urandom_range(1,3);
           <% rand_pos_in_signal_json = unit_idx_1; %>
           signal_width[<%= rand_pos_in_signal_json %>] = $bits(<%=hier_path_dut[unit_idx]%>.<%=func_checker_inst_name[unit_idx]%>.func_<%=unit_cecc_outputs_array[unit_idx][rand_pos_in_signal_json]%>);
           rand_pos_in_signal[<%= rand_pos_in_signal_json %>] = $urandom_range(0, signal_width[<%= rand_pos_in_signal_json %>]-1);
           cerr_counter_max_value_no_bits = $bits(<%=hier_path_dut[unit_idx]%>.<%=func_checker_inst_name[unit_idx]%>.cerr_counter);
           cerr_counter_max_value = 2**cerr_counter_max_value_no_bits;
           cerr_cnt = 0;
           begin
             cerr_threshold_value = $urandom_range(cerr_threshold_max_value-1,1);
             force <%=hier_path_dut[unit_idx]%>.<%=func_checker_inst_name[unit_idx]%>.cerr_threshold = cerr_threshold_value;
             force <%=hier_path_dut[unit_idx]%>.<%=func_checker_inst_name[unit_idx]%>.func_<%=unit_cecc_outputs_array[unit_idx][rand_pos_in_signal_json]%>= 1<<rand_pos_in_signal[<%= rand_pos_in_signal_json %>];
             `uvm_info(report_id ,$sformatf("Force correctable value inside functional unit %0s as %0b", "<%=hier_path_dut[unit_idx]%>.<%=func_checker_inst_name[unit_idx]%>.func_<%=unit_cecc_outputs_array[unit_idx][rand_pos_in_signal_json]%>" ,<%=hier_path_dut[unit_idx]%>.<%=func_checker_inst_name[unit_idx]%>.func_<%=unit_cecc_outputs_array[unit_idx][rand_pos_in_signal_json]%>), UVM_DEBUG);
             repeat(<%= nResiliencyDelay_json %>) @(posedge tb_clk);
             force <%=hier_path_dut[unit_idx]%>.<%=func_checker_inst_name[unit_idx]%>.check_<%=check_cecc_outputs_array[unit_idx][rand_pos_in_signal_json]%>= 1<<rand_pos_in_signal[<%= rand_pos_in_signal_json %>];
             `uvm_info(report_id ,$sformatf("Force correctable value inside checker unit %0s as %0b", "<%=hier_path_dut[unit_idx]%>.<%=func_checker_inst_name[unit_idx]%>.check_<%=check_cecc_outputs_array[unit_idx][rand_pos_in_signal_json]%>" ,<%=hier_path_dut[unit_idx]%>.<%=func_checker_inst_name[unit_idx]%>.check_<%=check_cecc_outputs_array[unit_idx][rand_pos_in_signal_json]%>), UVM_DEBUG);

             // check for threshold maximum value overflow. CONC-7033
             repeat(cerr_counter_max_value) begin
               repeat(2) @(posedge tb_clk);
               if(cerr_cnt > cerr_threshold_value+1) begin // once counter overflows, on the next clock it will assign to o/p
                 assert(<%=hier_path_dut[unit_idx]%>.<%=func_checker_inst_name[unit_idx]%>.cerr_over_thres_fault === 1) begin
                   `uvm_info(report_id ,$sformatf("cerr_counter value {TB:%0d, RTL:%0d} is above the threshold value %0d, So cerr_over_thres_fault is asserted{%0d}" ,cerr_cnt ,<%=hier_path_dut[unit_idx]%>.<%=func_checker_inst_name[unit_idx]%>.cerr_counter ,cerr_threshold_value ,<%=hier_path_dut[unit_idx]%>.<%=func_checker_inst_name[unit_idx]%>.cerr_over_thres_fault) ,UVM_DEBUG);
                 end
                 else begin
                   `uvm_error(report_id ,$sformatf("cerr_counter value {TB:%0d, RTL:%0d} is above the threshold value %0d, But cerr_over_thres_fault isn't asserted{%0d}" ,cerr_cnt ,<%=hier_path_dut[unit_idx]%>.<%=func_checker_inst_name[unit_idx]%>.cerr_counter ,cerr_threshold_value ,<%=hier_path_dut[unit_idx]%>.<%=func_checker_inst_name[unit_idx]%>.cerr_over_thres_fault));
                 end
               end
               cerr_cnt++;
             end
             @(posedge tb_clk);
             if(force_cerr_threshold) begin
               conc_7033_patch = 1; // TODO: make patch 0 if conc-7033 decides to keep counter halt at threshold+1 value
               assert(<%=hier_path_dut[unit_idx]%>.<%=func_checker_inst_name[unit_idx]%>.cerr_counter === (cerr_threshold_value+conc_7033_patch)) begin
                 `uvm_info(report_id ,$sformatf("cerr_counter is reached to maximum(threshold+1+conc_7033_patch(%0d)) and stayed stable as counter value Act:%0d, Exp:%0d" ,conc_7033_patch, <%=hier_path_dut[unit_idx]%>.<%=func_checker_inst_name[unit_idx]%>.cerr_counter, (cerr_threshold_value+1+conc_7033_patch)) , UVM_DEBUG);
               end
               else begin
                 `uvm_error(report_id ,$sformatf("cerr_counter is reached to maximum(threshold+1+conc_7033_patch(%0d)) but not stayed stable as counter value Act:%0d, Exp:%0d" ,conc_7033_patch, <%=hier_path_dut[unit_idx]%>.<%=func_checker_inst_name[unit_idx]%>.cerr_counter, (cerr_threshold_value+conc_7033_patch)));
               end
             end

             release <%=hier_path_dut[unit_idx]%>.<%=func_checker_inst_name[unit_idx]%>.func_<%=unit_cecc_outputs_array[unit_idx][rand_pos_in_signal_json]%>;
             repeat(<%= nResiliencyDelay_json %>)@(posedge tb_clk);
             release <%=hier_path_dut[unit_idx]%>.<%=func_checker_inst_name[unit_idx]%>.check_<%=check_cecc_outputs_array[unit_idx][rand_pos_in_signal_json]%>;
             repeat(5) @(posedge tb_clk);
             release <%=hier_path_dut[unit_idx]%>.<%=func_checker_inst_name[unit_idx]%>.cerr_threshold;
           end
           repeat(delay_bw_two_faults*10) @(posedge tb_clk);
           @(posedge tb_clk) bist_seq(`__LINE__);
           repeat(delay_bw_two_faults*10) @(posedge tb_clk);
           end
           <% } %>
           <% } %>

           begin
           //exiting with the mission fault asserted
           <% rand_pos_in_signal_json = Math.floor(Math.random() * check_uecc_outputs_array[0].length); %>
           signal_width[<%= rand_pos_in_signal_json %>] = $bits(<%=hier_path_dut[0]%>.<%=check_uecc_outputs_array[0][rand_pos_in_signal_json]%>);
           rand_pos_in_signal[<%= rand_pos_in_signal_json %>] = $urandom_range(0, signal_width[<%= rand_pos_in_signal_json %>]-1);

           force <%=hier_path_dut[0]%>.<%=check_uecc_outputs_array[0][rand_pos_in_signal_json]%> = 1<<rand_pos_in_signal[<%= rand_pos_in_signal_json %>];
           `uvm_info(report_id ,$sformatf("Force uncorrectable value inside checker unit %0s as %0b",`"<%=hier_path_dut[0]%>.<%=check_uecc_outputs_array[0][rand_pos_in_signal_json]%>`",<%=hier_path_dut[0]%>.<%=check_uecc_outputs_array[0][rand_pos_in_signal_json]%>), UVM_DEBUG);
           tb_mission_fault_ud[0] = 1;
           tb_latent_fault_ud[0]  = 0; 
           repeat(2) @(posedge tb_clk);
           start_checker_ilf = 1;
           repeat(5) @(posedge tb_clk);
           release <%=hier_path_dut[0]%>.<%=check_uecc_outputs_array[0][rand_pos_in_signal_json]%>;
           end
       end
     end
       repeat(5) @(posedge tb_clk);
       <% } %>

         <% if ((obj.useResiliency) && (obj.testBench == 'io_aiu')) { %>
          if($test$plusargs("bist_timeout_error")) begin
           bist_seq(`__LINE__);
          end
         <%}%>

         start_checker_ilf = 0;
         <% if (obj.useResiliency) { %>
         `uvm_info(report_id, "Triggering event drop_obj_for_resiliency_test",UVM_NONE)
         <% if((obj.testBench == 'dii')||(obj.testBench == 'dmi')||(obj.testBench == 'dce')||(obj.testBench == 'dve')||(obj.testBench == 'chi_aiu')||(obj.testBench == 'io_aiu')) { %>
	  ev_drop_obj_for_resiliency_test.trigger();
         `ifndef VCS
        -> drop_obj_for_resiliency_test;
         `else // `ifndef VCS
          drop_obj_for_resiliency_test.trigger();
         `endif // `ifndef VCS ... `else ... 
        <% } else {%>
       -> drop_obj_for_resiliency_test;
        <% } %>
        <%}%>
   end// end initial

	//////////////////////////////////////////////End Testing UECC////////////////////////////////////////////////////////////////////////////////////


	/////////////////////////////////////////////Checks and Assertions////////////////////////////////////////////////////////////////////////////////
   initial begin
     if($test$plusargs("test_unit_duplication")) begin
       @(posedge tb_rstn);
       fork
         begin: unti_duplication_signal_error
           forever begin
             wait (start_checker);
            <% if((obj.testBench == 'dii')||(obj.testBench == 'dmi')||(obj.testBench == 'dce')||(obj.testBench == 'dve')||(obj.testBench == 'chi_aiu')||(obj.testBench == 'io_aiu')) { %>
            `ifndef VCS
             begin
            `else // `ifndef VCS
             do begin
            `endif // `ifndef VCS ... `else ... 
            <% } else {%>
             begin
            <% } %>
               if(bist_seq_active == 0) begin
                 @(posedge tb_clk);
                 <% for (var unit_idx = unit_idx_min; unit_idx < unit_idx_max; unit_idx++) { %>
                  assert (<%=hier_path_dut[unit_idx]%>.fault_mission_fault === tb_mission_fault_ud[<%=unit_idx%>]) begin
                     `uvm_info(report_id
                               ,$sformatf("RTL and TB Mission fault match rtl_mission_fault=%0b tb_mission_fault=%0b"
                                 ,<%=hier_path_dut[unit_idx]%>.fault_mission_fault, tb_mission_fault_ud[<%=unit_idx%>])
                               , UVM_DEBUG);
                  end
                  else begin `uvm_error(report_id ,$sformatf("RTL and TB Mission fault mismatch rtl_mission_fault %0b tb_mission_fault %0b",
                                      <%=hier_path_dut[unit_idx]%>.fault_mission_fault, tb_mission_fault_ud[<%=unit_idx%>]));
                  end

                  assert (<%=hier_path_dut[unit_idx]%>.fault_latent_fault === tb_latent_fault_ud[<%=unit_idx%>]) begin
                        `uvm_info(report_id
                                  , $sformatf("RTL and TB Latent fault match rtl_latent_fault %0b tb_latent_fault %0b"
                                    , <%=hier_path_dut[unit_idx]%>.fault_latent_fault, tb_latent_fault_ud[<%=unit_idx%>])
                                  , UVM_DEBUG);
                  end
                  else begin `uvm_error(report_id ,$sformatf("RTL and TB Latent fault mismatch rtl_latent_fault %0b tb_latent_fault %0b",
                                                              <%=hier_path_dut[unit_idx]%>.fault_latent_fault, tb_latent_fault_ud[<%=unit_idx%>]));
                  end
                 <% } %>
               end else begin
                 @(posedge tb_clk);
               end
             end while(start_checker);
           end
         end
         begin: inject_latent_fault
           forever begin
             wait(start_checker_ilf);
            <% if((obj.testBench == 'dii')||(obj.testBench == 'dmi')||(obj.testBench == 'dce')||(obj.testBench == 'dve')||(obj.testBench == 'chi_aiu')||(obj.testBench == 'io_aiu')) { %>
            `ifndef VCS
             begin
            `else // `ifndef VCS
             do begin
            `endif // `ifndef VCS ... `else ... 
            <% } else {%>
             begin
            <% } %>
              // #Check.IOAIU.Unitduplication.Fault
               if(bist_seq_active == 0) begin
                 @(posedge tb_clk);
                 <% for (var unit_idx = unit_idx_min; unit_idx < unit_idx_max; unit_idx++) { %>
                  assert (<%=hier_path_dut[unit_idx]%>.fault_mission_fault === tb_mission_fault_ud[<%=unit_idx%>]) begin
                     `uvm_info(report_id
                               ,$sformatf("start_checker_ilf - RTL and TB Mission fault match rtl_mission_fault=%0b tb_mission_fault=%0b"
                                 ,<%=hier_path_dut[unit_idx]%>.fault_mission_fault, tb_mission_fault_ud[<%=unit_idx%>])
                               , UVM_DEBUG);
                  end
                  else begin `uvm_error(report_id ,$sformatf("start_checker_ilf - RTL and TB Mission fault mismatch rtl_mission_fault %0b tb_mission_fault %0b",
                                      <%=hier_path_dut[unit_idx]%>.fault_mission_fault, tb_mission_fault_ud[<%=unit_idx%>]));
                  end

                  assert (<%=hier_path_dut[unit_idx]%>.fault_latent_fault === tb_latent_fault_ud[<%=unit_idx%>]) begin
                        `uvm_info(report_id
                                  , $sformatf("start_checker_ilf - RTL and TB Latent fault match rtl_latent_fault %0b tb_latent_fault %0b"
                                    , <%=hier_path_dut[unit_idx]%>.fault_latent_fault, tb_latent_fault_ud[<%=unit_idx%>])
                                  , UVM_DEBUG);
                  end
                  else begin `uvm_error(report_id ,$sformatf("start_checker_ilf - RTL and TB Latent fault mismatch rtl_latent_fault %0b tb_latent_fault %0b",
                                                              <%=hier_path_dut[unit_idx]%>.fault_latent_fault, tb_latent_fault_ud[<%=unit_idx%>]));
                  end
                 <% } %>
               end else begin
                 @(posedge tb_clk);
               end
             end while(start_checker_ilf);
           end
         end
       join_none
     end
   end

   initial begin
     if($test$plusargs("test_unit_duplication")) begin
     forever begin
       wait(tb_rstn);
       ev_bist_reset_done.wait_ptrigger();
       begin
         @(posedge tb_clk);
         <% for (var unit_idx = unit_idx_min; unit_idx < unit_idx_max; unit_idx++) { %>
         assert (!$isunknown(<%=hier_path_dut[unit_idx]%>.fault_mission_fault)) begin
         end else begin
           `uvm_error(report_id, 
                      $sformatf("Fault values is unknown! fault_mission_fault=%0d", <%=hier_path_dut[unit_idx]%>.fault_mission_fault)
                    );
         end
         assert (!$isunknown(<%=hier_path_dut[unit_idx]%>.fault_latent_fault)) begin
         end else begin
           `uvm_error(report_id, 
                      $sformatf("Fault values is unknown! fault_latent_fault=%0d", <%=hier_path_dut[unit_idx]%>.fault_latent_fault)
                    );
         end
         <% } %>
       end
     end
     end
   end

   // Assertions on RTL signals
  <%  for  (var unit_idx = unit_idx_min; unit_idx < unit_idx_max; unit_idx++) { %>
   initial begin
       //If no faults are injected, expect mission_fault, latent_fault to never trigger
       if (!(($test$plusargs("test_unit_duplication")) || (inj_cntl <= 1))) begin
          @(posedge tb_rstn);
          ev_bist_reset_done.wait_ptrigger();
          forever begin
             @(posedge tb_clk);
             if (mission_fault_units[<%=unit_idx%>] === 1'b1) begin
                if (<%=hier_path_dut[unit_idx]%>.fault_mission_fault === 1'b1)
                   `uvm_info(report_id ,$sformatf("Uncorrectable errors injected on SMI, mission fault signal %s is 1",
                                                                "<%=hier_path_dut[unit_idx]%>.fault_mission_fault"), UVM_DEBUG);
             end else begin
                assert ((bist_seq_active==0)?(<%=hier_path_dut[unit_idx]%>.fault_mission_fault === 1'b0):'b1)
                else `uvm_error(report_id ,$sformatf("Mission fault is not 0 %s with no faults injected","<%=hier_path_dut[unit_idx]%>.fault_mission_fault"));
             end

             if (latent_fault_units[<%=unit_idx%>] === 1'b1) begin
                if (<%=hier_path_dut[unit_idx]%>.fault_latent_fault === 1'b1)
                    `uvm_info(report_id ,$sformatf("Latent fault signal %s is 1 as expected",
                                                                 "<%=hier_path_dut[unit_idx]%>.fault_latent_fault"), UVM_DEBUG);
             end else begin
                assert ((bist_seq_active==0)?(<%=hier_path_dut[unit_idx]%>.fault_latent_fault === 1'b0):'b1)
                else `uvm_error(report_id ,$sformatf("Latent fault is not 0 %s with no faults injected","<%=hier_path_dut[unit_idx]%>.fault_latent_fault"));
             end

          end
       end
    end
   <% } %>

   <% if (obj.AiuInfo[obj.Id].ResilienceInfo.fnResiliencyProtectionType == "ecc" || obj.DveInfo[0].ResilienceInfo.fnResiliencyProtectionType == "ecc") { %>
    initial begin
       @(posedge tb_rstn);
       ev_bist_reset_done.wait_ptrigger();
       //Check initial conditions of cerr_over_thres_fault interrupt signal
     <% if ((obj.testBench == "psys") || (obj.testBench == "fsys") || (obj.testBench == "emu") || (obj.CUSTOMER_ENV)) { %>
      <%  for  (var unit_idx = unit_idx_min; unit_idx < unit_idx_max; unit_idx++) { %>
       if (<%=hier_path_dut[unit_idx]%>.fault_cerr_over_thres_fault || <%=hier_path_dut[unit_idx]%>.fault_mission_fault || <%=hier_path_dut[unit_idx]%>.fault_latent_fault)
          `uvm_error(report_id ,$sformatf("cerr_over_thres/mission/latent fault is not 0 for %s coming out of reset","<%=hier_path_dut[unit_idx]%>"))
      <% } %>
     <%} else {%>
       if (!($test$plusargs("test_unit_duplication") ||  (inj_cntl != 0) || $test$plusargs("inject_smi_uncorr_error") || $test$plusargs("inject_smi_corr_error"))) begin
       if (<%=hier_path_dut[0]%>.fault_cerr_over_thres_fault || <%=hier_path_dut[0]%>.fault_mission_fault || <%=hier_path_dut[0]%>.fault_latent_fault)
          `uvm_error(report_id ,"cerr_over_thres/mission/latent fault is not 0 coming out of reset")
       end
     <%}%>

     <% if ((obj.testBench == "psys") || (obj.testBench == "fsys") || (obj.testBench == "emu") || (obj.CUSTOMER_ENV)) { %>
      assert (`U_CHIP.cerr_over_thres_int || `U_CHIP.latent_fault_int || `U_CHIP.mission_fault_int)
      else `uvm_error(report_id ,$sformatf("cerr_over_thres_int/latent_fault_int/mission_fault_int is not 0 coming out of reset"))
     <% } %>
   end

   <%  for  (var unit_idx = unit_idx_min; unit_idx < unit_idx_max; unit_idx++) { %>
    initial begin
       if (!(($test$plusargs("inject_smi_uncorr_error")) || (inj_cntl[0] == 0))) begin
      <% if (obj.testBench != 'io_aiu') { %>
       ev_bist_reset_done.wait_ptrigger();
       <% } %>
       forever begin
          @(posedge <%=hier_path_dut[unit_idx]%>.fault_cerr_over_thres_fault);
          if (cerr_fault_units[<%=unit_idx%>]) begin
             num_of_cerr_thres_unit_assertion[<%=unit_idx%>]++;
             `uvm_info(report_id ,$sformatf("cerr_over_thres_fault asserted for %0d th time at time=%f for unit %s",
                                                          num_of_cerr_thres_unit_assertion[<%=unit_idx%>], $realtime, "<%=hier_path_dut[unit_idx]%>"), UVM_DEBUG)
          end else if (inj_cntl[0] == 0) begin
             `uvm_error(report_id ,$sformatf("cerr_over_thres_fault wrongly asserted during the simulation for signal %s", "<%=hier_path_dut[unit_idx]%>.fault_cerr_over_thres_fault"))
          end
       end // forever begin
       end
    end


    final begin
       if(is_msg_field_inj_on) begin
       if ($test$plusargs("inject_smi_corr_error") || (inj_cntl[0] != 0)) begin
          if (((num_of_cerr_thres_unit_assertion[<%=unit_idx%>] !== 0) && (cerr_fault_units[<%=unit_idx%>] == 0))) begin
             `uvm_error(report_id ,$sformatf("cerr_over_thres_fault wrongly asserted during the simulation for signal %s", "<%=hier_path_dut[unit_idx]%>.fault_cerr_over_thres_fault"))
          end else if (((num_of_cerr_thres_unit_assertion[<%=unit_idx%>] === 0) && (cerr_fault_units[<%=unit_idx%>] == 1))) begin
             `uvm_error(report_id ,$sformatf("cerr_over_thres_fault never asserted during the simulation for signal %s", "<%=hier_path_dut[unit_idx]%>.fault_cerr_over_thres_fault"))
          end else begin
             `uvm_info(report_id ,$sformatf("cerr_over_thres_fault asserted %0d times during the simulation for unit %s", num_of_cerr_thres_unit_assertion[<%=unit_idx%>], "<%=hier_path_dut[unit_idx]%>"), UVM_DEBUG)
          end
      //#Check.IOAIU.Smi.UncorrectableErr.Fault
       end else if ($test$plusargs("inject_smi_uncorr_error") || (inj_cntl inside {'h2, 'h4})) begin
          if (((num_of_cerr_thres_unit_assertion[<%=unit_idx%>] !== 0) && (cerr_fault_units[<%=unit_idx%>] == 0))) begin
             `uvm_error(report_id ,$sformatf("cerr_over_thres_fault wrongly asserted during the simulation for signal %s", "<%=hier_path_dut[unit_idx]%>.fault_cerr_over_thres_fault"))
          end
       end
       end
    end
   <% } %>
  <% } %>

   <%  for  (var unit_idx = unit_idx_min; unit_idx < unit_idx_max; unit_idx++) { %>
    initial begin
       @(posedge tb_rstn);
       forever begin
           @(posedge tb_clk);
//           wait (bist_seq_active==0);
           ev_bist_reset_done.wait_ptrigger();
           if (!($test$plusargs("test_unit_duplication") ||  (inj_cntl != 0) || $test$plusargs("inject_smi_uncorr_error") || $test$plusargs("inject_smi_corr_error"))) begin
             <% if ((obj.testBench == "psys") || (obj.testBench == "fsys") || (obj.CUSTOMER_ENV)) { %>
              if (<%=hier_path_dut[unit_idx]%>.fault_cerr_over_thres_fault || <%=hier_path_dut[unit_idx]%>.fault_mission_fault || <%=hier_path_dut[unit_idx]%>.fault_latent_fault) begin
                `uvm_error(report_id ,$sformatf("cerr_over_thres/mission/latent fault is not 0 for %s with no SMI fault injection plusargs enabled",
                                                              "<%=hier_path_dut[unit_idx]%>"))
              end
             <%} else {%>
              if (<%=hier_path_dut[0]%>.fault_cerr_over_thres_fault || <%=hier_path_dut[0]%>.fault_mission_fault || <%=hier_path_dut[0]%>.fault_latent_fault) begin
                `uvm_error(report_id ,"cerr_over_thres/mission/latent fault output is not 0 with no SMI fault injection plusargs enabled")
              end
             <%}%>

             <% if ((obj.testBench == "psys") || (obj.testBench == "fsys") || (obj.testBench == "emu") || (obj.CUSTOMER_ENV)) { %>
//              assert ((bist_seq_active==0)?(`U_CHIP.mission_fault_int === 1'b0):'b1)
//              else `uvm_error(report_id ,$sformatf("mission_fault_int is not 0 with no faults being injected"))

//              assert ((bist_seq_active==0)?(`U_CHIP.latent_fault_int === 1'b0):'b1)
//              else `uvm_error(report_id ,$sformatf("latent_fault_int is not 0 with no faults being injected"))

//              assert ((bist_seq_active==0)?(`U_CHIP.cerr_over_thres_int === 1'b0):'b1)
//              else `uvm_error(report_id ,$sformatf("cerr_over_thres_int is not 0 with no faults being injected"))
             <% } %>
          end
       end
    end
   <% } %>

  `else
   initial
   begin
    <% if (!obj.CUSTOMER_ENV) { %>
     `uvm_info("FAULT_INJECTOR_CHECKER(%m)", "FAULT_INJECTOR_CHECKER is disabled; to enable, please add these options during compilation/simulation --> (1) Compile with with +define+RESILIENCY_TESTING; (2) Simulate with +init_mem_with_rand_data plusarg option; (3) To inject mission faults during simulation, use the plusarg option +inject_mission_fault;  \n", UVM_NONE);
    <% } %>
   end
   `endif //end ifdef RESILIENCY_TESTING
endmodule: fault_injector_checker

<% } %>
`endif
