/****************************************************************************************************************************
*                                                                                                                           *
* this module checkes uncorr error injection at full sys, 
* all fsys module signal forced to inject errror and mission fault is observed.
* Once mission fault check completes, Bist automatic/manual seq runs to clear fault
*                                                                                                                           *
* File    : fsys_fault_injector_checker.sv                                                                                  *
* Version : 0.1                                                                                                             *                                       
* Author  : Kruna Patel                                                                                                     *                                    
* Confluence page links  :                                                                                                  *
*                                                                                                                           *
*                                                                                                                           *                         
/***************************************************************************************************************************/

<%
var numChiAiu = 0; // Number of CHI AIUs
var numIoAiu = 0; // Number of IO AIUs
for(var pidx = 0; pidx < obj.nAIUs; pidx++) {
    if((obj.AiuInfo[pidx].fnNativeInterface == "CHI-A")||(obj.AiuInfo[pidx].fnNativeInterface == "CHI-B")||(obj.AiuInfo[pidx].fnNativeInterface == "CHI-E")) 
       { 
       numChiAiu++ ; 
       }
    else
       { numIoAiu++ ; 
       }
}
%>
`ifndef FSYS_FAULT_INJECTOR_CHECKER_SV
`define FSYS_FAULT_INJECTOR_CHECKER_SV

<% if (obj.useResiliency) { %>
`include "fault_if.sv"
module fsys_fault_injector_checker(input tb_clk, input tb_rstn);


int FSYS_FAULT_INJECTOR_CHECKER_CLK_DELAY_BEFORE_ERR = 20480;
   <% var hier_path_dut = ['tb_top.dut']; %>
   <% var dce_unit_outputs_array = ['smi_tx0_ndp_targ_id', 'smi_tx0_ndp_src_id', 'smi_tx0_ndp_ndp_len', 'smi_tx0_ndp_ndp', 'smi_tx0_ndp_msg_type', 'smi_tx0_ndp_msg_id', 'smi_tx0_ndp_dp_present', 'smi_tx1_ndp_targ_id', 'smi_tx1_ndp_src_id', 'smi_tx1_ndp_ndp_len', 'smi_tx1_ndp_ndp', 'smi_tx1_ndp_msg_type', 'smi_tx1_ndp_msg_id', 'smi_tx1_ndp_dp_present'/*, 'smi_tx2_ndp_targ_id', 'smi_tx2_ndp_src_id', 'smi_tx2_ndp_ndp_len', 'smi_tx2_ndp_ndp', 'smi_tx2_ndp_msg_type', 'smi_tx2_ndp_msg_id', 'smi_tx2_ndp_dp_present'*/ , 'smi_rx0_ndp_msg_ready', 'smi_rx1_ndp_msg_ready'/*, 'smi_rx2_ndp_msg_ready'*/];

   var dce_dup_unit_outputs_array = ['dup_unit_smi_tx0_ndp_targ_id', 'dup_unit_smi_tx0_ndp_src_id', 'dup_unit_smi_tx0_ndp_ndp_len', 'dup_unit_smi_tx0_ndp_ndp', 'dup_unit_smi_tx0_ndp_msg_type', 'dup_unit_smi_tx0_ndp_msg_id', 'dup_unit_smi_tx0_ndp_dp_present', 'dup_unit_smi_tx1_ndp_targ_id', 'dup_unit_smi_tx1_ndp_src_id', 'dup_unit_smi_tx1_ndp_ndp_len', 'dup_unit_smi_tx1_ndp_ndp', 'dup_unit_smi_tx1_ndp_msg_type', 'dup_unit_smi_tx1_ndp_msg_id', 'dup_unit_smi_tx1_ndp_dp_present'/*, 'dup_unit_smi_tx2_ndp_targ_id', 'dup_unit_smi_tx2_ndp_src_id', 'dup_unit_smi_tx2_ndp_ndp_len', 'dup_unit_smi_tx2_ndp_ndp', 'dup_unit_smi_tx2_ndp_msg_type', 'dup_unit_smi_tx2_ndp_msg_id', 'dup_unit_smi_tx2_ndp_dp_present'*/, 'dup_unit_smi_rx0_ndp_msg_ready', 'dup_unit_smi_rx1_ndp_msg_ready'/*, 'dup_unit_smi_rx2_ndp_msg_ready'*/];

   var dce_uce_signals_array = ['dce_cmux_UCE','dce_dm_UCE','dce_target_id_UCE','dce_timeout_UCE'];
      
   var dce_dup_uce_signals_array = ['dup_unit_dce_cmux_UCE','dup_unit_dce_dm_UCE','dup_unit_dce_target_id_UCE','dup_unit_dce_timeout_UCE'];

     var dii_unit_outputs_array = ['smi_tx0_ndp_targ_id', 'smi_tx0_ndp_src_id', 'smi_tx0_ndp_ndp_len', 'smi_tx0_ndp_ndp',  'smi_tx0_ndp_msg_type', 'smi_tx0_ndp_msg_id', 'smi_tx0_ndp_dp_present', 'smi_tx1_ndp_targ_id', 'smi_tx1_ndp_src_id', 'smi_tx1_ndp_ndp_len', 'smi_tx1_ndp_ndp',  'smi_tx1_ndp_msg_type', 'smi_tx1_ndp_msg_id', 'smi_tx1_ndp_dp_present'/*, 'smi_tx2_ndp_targ_id', 'smi_tx2_ndp_src_id', 'smi_tx2_ndp_ndp_len', 'smi_tx2_ndp_ndp',  'smi_tx2_ndp_msg_type', 'smi_tx2_ndp_msg_id', 'smi_tx2_ndp_dp_present',  'smi_tx2_dp_user', 'smi_tx2_dp_last', 'smi_tx2_dp_data'*/, 'smi_rx0_ndp_msg_ready', 'smi_rx1_ndp_msg_ready'/*, 'smi_rx2_ndp_msg_ready', 'smi_rx2_dp_ready'*/];  
      
     var dii_dup_unit_outputs_array = ['late_smi_tx0_ndp_targ_id', 'late_smi_tx0_ndp_src_id', 'late_smi_tx0_ndp_ndp_len', 'late_smi_tx0_ndp_ndp',  'late_smi_tx0_ndp_msg_type', 'late_smi_tx0_ndp_msg_id', 'late_smi_tx0_ndp_dp_present', 'late_smi_tx1_ndp_targ_id', 'late_smi_tx1_ndp_src_id', 'late_smi_tx1_ndp_ndp_len', 'late_smi_tx1_ndp_ndp',  'late_smi_tx1_ndp_msg_type', 'late_smi_tx1_ndp_msg_id', 'late_smi_tx1_ndp_dp_present'/*, 'late_smi_tx2_ndp_targ_id', 'late_smi_tx2_ndp_src_id', 'late_smi_tx2_ndp_ndp_len', 'late_smi_tx2_ndp_ndp',  'late_smi_tx2_ndp_msg_type', 'late_smi_tx2_ndp_msg_id', 'late_smi_tx2_ndp_dp_present',  'late_smi_tx2_dp_user', 'late_smi_tx2_dp_last', 'late_smi_tx2_dp_data'*/, 'late_smi_rx0_ndp_msg_ready', 'late_smi_rx1_ndp_msg_ready'/*, 'late_smi_rx2_ndp_msg_ready', 'late_smi_rx2_dp_ready'*/];  

   var dii_uce_signals_array = ['dii_cmux_UCE','dii_placeholder_UCE','dii_read_buffer_UCE','dii_target_mismatch_UCE'];
      
   var dii_dup_uce_signals_array = ['late_dii_cmux_UCE','late_dii_placeholder_UCE','late_dii_read_buffer_UCE','late_dii_target_mismatch_UCE'];

     var dve_unit_outputs_array = ['smi_tx0_ndp_targ_id', 'smi_tx0_ndp_src_id', 'smi_tx0_ndp_ndp_len', 'smi_tx0_ndp_ndp',  'smi_tx0_ndp_msg_type', 'smi_tx0_ndp_msg_id', 'smi_tx0_ndp_dp_present', 'smi_tx1_ndp_targ_id', 'smi_tx1_ndp_src_id', 'smi_tx1_ndp_ndp_len', 'smi_tx1_ndp_ndp',  'smi_tx1_ndp_msg_type', 'smi_tx1_ndp_msg_id', 'smi_tx1_ndp_dp_present', 'smi_rx0_ndp_msg_ready', 'smi_rx1_ndp_msg_ready'/*, 'smi_rx2_ndp_msg_ready', 'smi_rx2_dp_ready'*/];
      
     var dve_dup_unit_outputs_array = ['dup_unit__smi_tx0_ndp_targ_id', 'dup_unit__smi_tx0_ndp_src_id', 'dup_unit__smi_tx0_ndp_ndp_len', 'dup_unit__smi_tx0_ndp_ndp',  'dup_unit__smi_tx0_ndp_msg_type', 'dup_unit__smi_tx0_ndp_msg_id', 'dup_unit__smi_tx0_ndp_dp_present', 'dup_unit__smi_tx1_ndp_targ_id', 'dup_unit__smi_tx1_ndp_src_id', 'dup_unit__smi_tx1_ndp_ndp_len', 'dup_unit__smi_tx1_ndp_ndp',  'dup_unit__smi_tx1_ndp_msg_type', 'dup_unit__smi_tx1_ndp_msg_id', 'dup_unit__smi_tx1_ndp_dp_present', 'dup_unit__smi_rx0_ndp_msg_ready', 'dup_unit__smi_rx1_ndp_msg_ready'/*, 'dup_unit__smi_rx2_ndp_msg_ready', 'dup_unit__smi_rx2_dp_ready'*/];

   var dve_uce_signals_array = ['dve_cmux_UCE','dve_target_id_UCE','dve_trace_mem_UCE'];
      
   var dve_dup_uce_signals_array = ['dup_unit__dve_cmux_UCE','dup_unit__dve_target_id_UCE','dup_unit__dve_trace_mem_UCE'];

     var dmi_unit_outputs_array = ['smi_tx0_ndp_targ_id', 'smi_tx0_ndp_src_id', 'smi_tx0_ndp_ndp_len', 'smi_tx0_ndp_ndp', 'smi_tx0_ndp_msg_type' , 'smi_tx0_ndp_msg_id', 'smi_tx0_ndp_dp_present', 'smi_tx1_ndp_targ_id', 'smi_tx1_ndp_src_id', 'smi_tx1_ndp_ndp_len', 'smi_tx1_ndp_ndp', 'smi_tx1_ndp_msg_type', 'smi_tx1_ndp_msg_id', 'smi_tx1_ndp_dp_present', 'smi_tx2_ndp_targ_id', 'smi_tx2_ndp_src_id', 'smi_tx2_ndp_ndp_len', 'smi_tx2_ndp_ndp', 'smi_tx2_ndp_msg_type', 'smi_tx2_ndp_msg_id', 'smi_tx2_ndp_dp_present'/*, 'smi_tx3_ndp_targ_id', 'smi_tx3_ndp_src_id', 'smi_tx3_ndp_ndp_len', 'smi_tx3_ndp_ndp', 'smi_tx3_ndp_msg_type', 'smi_tx3_ndp_msg_id', 'smi_tx3_ndp_dp_present', 'smi_tx3_dp_user', 'smi_tx3_dp_last', 'smi_tx3_dp_data'*/, 'smi_rx0_ndp_msg_ready', 'smi_rx1_ndp_msg_ready', 'smi_rx2_ndp_msg_ready'/*, 'smi_rx3_ndp_msg_ready', 'smi_rx3_dp_ready'*/];
      
     var dmi_dup_unit_outputs_array = ['dup_unit__smi_tx0_ndp_targ_id', 'dup_unit__smi_tx0_ndp_src_id', 'dup_unit__smi_tx0_ndp_ndp_len', 'dup_unit__smi_tx0_ndp_ndp', 'dup_unit__smi_tx0_ndp_msg_type' , 'dup_unit__smi_tx0_ndp_msg_id', 'dup_unit__smi_tx0_ndp_dp_present', 'dup_unit__smi_tx1_ndp_targ_id', 'dup_unit__smi_tx1_ndp_src_id', 'dup_unit__smi_tx1_ndp_ndp_len', 'dup_unit__smi_tx1_ndp_ndp', 'dup_unit__smi_tx1_ndp_msg_type', 'dup_unit__smi_tx1_ndp_msg_id', 'dup_unit__smi_tx1_ndp_dp_present', 'dup_unit__smi_tx2_ndp_targ_id', 'dup_unit__smi_tx2_ndp_src_id', 'dup_unit__smi_tx2_ndp_ndp_len', 'dup_unit__smi_tx2_ndp_ndp', 'dup_unit__smi_tx2_ndp_msg_type', 'dup_unit__smi_tx2_ndp_msg_id', 'dup_unit__smi_tx2_ndp_dp_present'/*, 'dup_unit__smi_tx3_ndp_targ_id', 'dup_unit__smi_tx3_ndp_src_id', 'dup_unit__smi_tx3_ndp_ndp_len', 'dup_unit__smi_tx3_ndp_ndp', 'dup_unit__smi_tx3_ndp_msg_type', 'dup_unit__smi_tx3_ndp_msg_id', 'dup_unit__smi_tx3_ndp_dp_present', 'dup_unit__smi_tx3_dp_user', 'dup_unit__smi_tx3_dp_last', 'dup_unit__smi_tx3_dp_data'*/, 'dup_unit__smi_rx0_ndp_msg_ready', 'dup_unit__smi_rx1_ndp_msg_ready', 'dup_unit__smi_rx2_ndp_msg_ready'/*, 'dup_unit__smi_rx3_ndp_msg_ready', 'dup_unit__smi_rx3_dp_ready'*/];

   var dmi_uce_signals_array = ['dmi_c_wr_buff_UCE','dmi_cmux_UCE','dmi_placeholder_UCE','dmi_rd_buffer_UCE','dmi_smc_data_UCE','dmi_smc_tag_UCE','dmi_target_id_UCE','dmi_timeout_error_UCE']; // Excluding dmi_native_rd_resp_UCE & dmi_native_wr_resp_UCE as per CONC-11671
      
   var dmi_dup_uce_signals_array = ['dup_unit__dmi_c_wr_buff_UCE','dup_unit__dmi_cmux_UCE','dup_unit__dmi_placeholder_UCE','dup_unit__dmi_rd_buffer_UCE','dup_unit__dmi_smc_data_UCE','dup_unit__dmi_smc_tag_UCE','dup_unit__dmi_target_id_UCE','dup_unit__dmi_timeout_error_UCE'];  // Excluding dup_unit__dmi_native_rd_resp_UCE & dup_unit__dmi_native_wr_resp_UCE as per CONC-11671

     var ioaiu_unit_outputs_array = ['smi_tx0_ndp_targ_id', 'smi_tx0_ndp_src_id', 'smi_tx0_ndp_ndp_len', 'smi_tx0_ndp_ndp', 'smi_tx0_ndp_msg_type', 'smi_tx0_ndp_msg_id', 'smi_tx0_ndp_dp_present', 'smi_tx1_ndp_targ_id', 'smi_tx1_ndp_src_id', 'smi_tx1_ndp_ndp_len', 'smi_tx1_ndp_ndp', 'smi_tx1_ndp_msg_type', 'smi_tx1_ndp_msg_id', 'smi_tx1_ndp_dp_present'/*, 'smi_tx2_ndp_targ_id', 'smi_tx2_ndp_src_id', 'smi_tx2_ndp_ndp_len', 'smi_tx2_ndp_ndp', 'smi_tx2_ndp_msg_type', 'smi_tx2_ndp_msg_id', 'smi_tx2_ndp_dp_present', 'smi_tx2_dp_user', 'smi_tx2_dp_last', 'smi_tx2_dp_data'*/, 'smi_rx0_ndp_msg_ready', 'smi_rx1_ndp_msg_ready'/*, 'smi_rx2_ndp_msg_ready', 'smi_rx2_dp_ready'*/]; 

     var ioaiu_dup_unit_outputs_array = ['w_delay_smi_tx0_ndp_targ_id', 'w_delay_smi_tx0_ndp_src_id', 'w_delay_smi_tx0_ndp_ndp_len', 'w_delay_smi_tx0_ndp_ndp', 'w_delay_smi_tx0_ndp_msg_type', 'w_delay_smi_tx0_ndp_msg_id', 'w_delay_smi_tx0_ndp_dp_present', 'w_delay_smi_tx1_ndp_targ_id', 'w_delay_smi_tx1_ndp_src_id', 'w_delay_smi_tx1_ndp_ndp_len', 'w_delay_smi_tx1_ndp_ndp', 'w_delay_smi_tx1_ndp_msg_type', 'w_delay_smi_tx1_ndp_msg_id', 'w_delay_smi_tx1_ndp_dp_present'/*, 'w_delay_smi_tx2_ndp_targ_id', 'w_delay_smi_tx2_ndp_src_id', 'w_delay_smi_tx2_ndp_ndp_len', 'w_delay_smi_tx2_ndp_ndp', 'w_delay_smi_tx2_ndp_msg_type', 'w_delay_smi_tx2_ndp_msg_id', 'w_delay_smi_tx2_ndp_dp_present', 'w_delay_smi_tx2_dp_user', 'w_delay_smi_tx2_dp_last', 'w_delay_smi_tx2_dp_data'*/, 'w_delay_smi_rx0_ndp_msg_ready', 'w_delay_smi_rx1_ndp_msg_ready'/*, 'w_delay_smi_rx2_ndp_msg_ready', 'w_delay_smi_rx2_dp_ready'*/]; 

   var ioaiu_ace_uce_signals_array = ['ioaiu_core_wrapper.cmd_rsp_header_UCE','ioaiu_core_wrapper.cmd_rsp_message_UCE','ioaiu_core_wrapper.dtr_req_rx_data_UCE','ioaiu_core_wrapper.dtr_req_rx_header_UCE','ioaiu_core_wrapper.dtr_req_rx_message_UCE','ioaiu_core_wrapper.dtr_rsp_rx_header_UCE','ioaiu_core_wrapper.dtr_rsp_rx_message_UCE','ioaiu_core_wrapper.dtw_dbg_rsp_header_UCE','ioaiu_core_wrapper.dtw_dbg_rsp_message_UCE','ioaiu_core_wrapper.dtw_rsp_header_UCE','ioaiu_core_wrapper.dtw_rsp_message_UCE','ioaiu_core_wrapper.snp_req_header_UCE','ioaiu_core_wrapper.snp_req_message_UCE','ioaiu_core_wrapper.str_req_header_UCE','ioaiu_core_wrapper.str_req_message_UCE','ioaiu_core_wrapper.sys_req_rx_header_UCE','ioaiu_core_wrapper.sys_req_rx_message_UCE','ioaiu_core_wrapper.sys_rsp_rx_header_UCE','ioaiu_core_wrapper.sys_rsp_rx_message_UCE','ioaiu_core_wrapper.upd_rsp_header_UCE','ioaiu_core_wrapper.upd_rsp_message_UCE','ioaiu_core_wrapper.cmp_rsp_header_UCE','ioaiu_core_wrapper.cmp_rsp_message_UCE'];      

   var ioaiu_ace_dup_uce_signals_array = ['dup_unit.cmd_rsp_header_UCE','dup_unit.cmd_rsp_message_UCE','dup_unit.dtr_req_rx_data_UCE','dup_unit.dtr_req_rx_header_UCE','dup_unit.dtr_req_rx_message_UCE','dup_unit.dtr_rsp_rx_header_UCE','dup_unit.dtr_rsp_rx_message_UCE','dup_unit.dtw_dbg_rsp_header_UCE','dup_unit.dtw_dbg_rsp_message_UCE','dup_unit.dtw_rsp_header_UCE','dup_unit.dtw_rsp_message_UCE','dup_unit.snp_req_header_UCE','dup_unit.snp_req_message_UCE','dup_unit.str_req_header_UCE','dup_unit.str_req_message_UCE','dup_unit.sys_req_rx_header_UCE','dup_unit.sys_req_rx_message_UCE','dup_unit.sys_rsp_rx_header_UCE','dup_unit.sys_rsp_rx_message_UCE','dup_unit.upd_rsp_header_UCE','dup_unit.upd_rsp_message_UCE','dup_unit.cmp_rsp_header_UCE','dup_unit.cmp_rsp_message_UCE'];

   var ioaiu_axi4_w_cache_uce_signals_array = ['ioaiu_core_wrapper.cmd_rsp_header_UCE','ioaiu_core_wrapper.cmd_rsp_message_UCE','ioaiu_core_wrapper.dtr_req_rx_data_UCE','ioaiu_core_wrapper.dtr_req_rx_header_UCE','ioaiu_core_wrapper.dtr_req_rx_message_UCE','ioaiu_core_wrapper.dtr_rsp_rx_header_UCE','ioaiu_core_wrapper.dtr_rsp_rx_message_UCE','ioaiu_core_wrapper.dtw_dbg_rsp_header_UCE','ioaiu_core_wrapper.dtw_dbg_rsp_message_UCE','ioaiu_core_wrapper.dtw_rsp_header_UCE','ioaiu_core_wrapper.dtw_rsp_message_UCE','ioaiu_core_wrapper.snp_req_header_UCE','ioaiu_core_wrapper.snp_req_message_UCE','ioaiu_core_wrapper.str_req_header_UCE','ioaiu_core_wrapper.str_req_message_UCE','ioaiu_core_wrapper.sys_req_rx_header_UCE','ioaiu_core_wrapper.sys_req_rx_message_UCE','ioaiu_core_wrapper.sys_rsp_rx_header_UCE','ioaiu_core_wrapper.sys_rsp_rx_message_UCE','ioaiu_core_wrapper.upd_rsp_header_UCE','ioaiu_core_wrapper.upd_rsp_message_UCE'];      

   var ioaiu_axi4_w_cache_dup_uce_signals_array = ['dup_unit.cmd_rsp_header_UCE','dup_unit.cmd_rsp_message_UCE','dup_unit.dtr_req_rx_data_UCE','dup_unit.dtr_req_rx_header_UCE','dup_unit.dtr_req_rx_message_UCE','dup_unit.dtr_rsp_rx_header_UCE','dup_unit.dtr_rsp_rx_message_UCE','dup_unit.dtw_dbg_rsp_header_UCE','dup_unit.dtw_dbg_rsp_message_UCE','dup_unit.dtw_rsp_header_UCE','dup_unit.dtw_rsp_message_UCE','dup_unit.snp_req_header_UCE','dup_unit.snp_req_message_UCE','dup_unit.str_req_header_UCE','dup_unit.str_req_message_UCE','dup_unit.sys_req_rx_header_UCE','dup_unit.sys_req_rx_message_UCE','dup_unit.sys_rsp_rx_header_UCE','dup_unit.sys_rsp_rx_message_UCE','dup_unit.upd_rsp_header_UCE','dup_unit.upd_rsp_message_UCE'];

   var ioaiu_axi4_wo_cache_uce_signals_array = ['ioaiu_core_wrapper.cmd_rsp_header_UCE','ioaiu_core_wrapper.cmd_rsp_message_UCE','ioaiu_core_wrapper.dtr_req_rx_data_UCE','ioaiu_core_wrapper.dtr_req_rx_header_UCE','ioaiu_core_wrapper.dtr_req_rx_message_UCE','ioaiu_core_wrapper.dtw_dbg_rsp_header_UCE','ioaiu_core_wrapper.dtw_dbg_rsp_message_UCE','ioaiu_core_wrapper.dtw_rsp_header_UCE','ioaiu_core_wrapper.dtw_rsp_message_UCE','ioaiu_core_wrapper.str_req_header_UCE','ioaiu_core_wrapper.str_req_message_UCE'];      

   var ioaiu_axi4_wo_cache_dup_uce_signals_array = ['dup_unit.cmd_rsp_header_UCE','dup_unit.cmd_rsp_message_UCE','dup_unit.dtr_req_rx_data_UCE','dup_unit.dtr_req_rx_header_UCE','dup_unit.dtr_req_rx_message_UCE','dup_unit.dtw_dbg_rsp_header_UCE','dup_unit.dtw_dbg_rsp_message_UCE','dup_unit.dtw_rsp_header_UCE','dup_unit.dtw_rsp_message_UCE','dup_unit.str_req_header_UCE','dup_unit.str_req_message_UCE'];

   var ioaiu_acelite_uce_signals_array = ['ioaiu_core_wrapper.cmd_rsp_header_UCE','ioaiu_core_wrapper.cmd_rsp_message_UCE','ioaiu_core_wrapper.dtr_req_rx_data_UCE','ioaiu_core_wrapper.dtr_req_rx_header_UCE','ioaiu_core_wrapper.dtr_req_rx_message_UCE','ioaiu_core_wrapper.dtw_dbg_rsp_header_UCE','ioaiu_core_wrapper.dtw_dbg_rsp_message_UCE','ioaiu_core_wrapper.dtw_rsp_header_UCE','ioaiu_core_wrapper.dtw_rsp_message_UCE','ioaiu_core_wrapper.str_req_header_UCE','ioaiu_core_wrapper.str_req_message_UCE'];      

   var ioaiu_acelite_dup_uce_signals_array = ['dup_unit.cmd_rsp_header_UCE','dup_unit.cmd_rsp_message_UCE','dup_unit.dtr_req_rx_data_UCE','dup_unit.dtr_req_rx_header_UCE','dup_unit.dtr_req_rx_message_UCE','dup_unit.dtw_dbg_rsp_header_UCE','dup_unit.dtw_dbg_rsp_message_UCE','dup_unit.dtw_rsp_header_UCE','dup_unit.dtw_rsp_message_UCE','dup_unit.str_req_header_UCE','dup_unit.str_req_message_UCE'];

   var ioaiu_aceliteE_type1_uce_signals_array = ['ioaiu_core_wrapper.cmd_rsp_header_UCE','ioaiu_core_wrapper.cmd_rsp_message_UCE','ioaiu_core_wrapper.dtr_req_rx_data_UCE','ioaiu_core_wrapper.dtr_req_rx_header_UCE','ioaiu_core_wrapper.dtr_req_rx_message_UCE','ioaiu_core_wrapper.dtr_rsp_rx_header_UCE','ioaiu_core_wrapper.dtr_rsp_rx_message_UCE','ioaiu_core_wrapper.dtw_dbg_rsp_header_UCE','ioaiu_core_wrapper.dtw_dbg_rsp_message_UCE','ioaiu_core_wrapper.dtw_rsp_header_UCE','ioaiu_core_wrapper.dtw_rsp_message_UCE','ioaiu_core_wrapper.snp_req_header_UCE','ioaiu_core_wrapper.snp_req_message_UCE','ioaiu_core_wrapper.str_req_header_UCE','ioaiu_core_wrapper.str_req_message_UCE','ioaiu_core_wrapper.sys_rsp_rx_header_UCE','ioaiu_core_wrapper.sys_rsp_rx_message_UCE'];      

   var ioaiu_aceliteE_type1_dup_uce_signals_array = ['dup_unit.cmd_rsp_header_UCE','dup_unit.cmd_rsp_message_UCE','dup_unit.dtr_req_rx_data_UCE','dup_unit.dtr_req_rx_header_UCE','dup_unit.dtr_req_rx_message_UCE','dup_unit.dtr_rsp_rx_header_UCE','dup_unit.dtr_rsp_rx_message_UCE','dup_unit.dtw_dbg_rsp_header_UCE','dup_unit.dtw_dbg_rsp_message_UCE','dup_unit.dtw_rsp_header_UCE','dup_unit.dtw_rsp_message_UCE','dup_unit.snp_req_header_UCE','dup_unit.snp_req_message_UCE','dup_unit.str_req_header_UCE','dup_unit.str_req_message_UCE','dup_unit.sys_rsp_rx_header_UCE','dup_unit.sys_rsp_rx_message_UCE'];

   var ioaiu_aceliteE_type2_uce_signals_array = ['ioaiu_core_wrapper.cmd_rsp_header_UCE','ioaiu_core_wrapper.cmd_rsp_message_UCE','ioaiu_core_wrapper.dtr_req_rx_data_UCE','ioaiu_core_wrapper.dtr_req_rx_header_UCE','ioaiu_core_wrapper.dtr_req_rx_message_UCE','ioaiu_core_wrapper.dtr_rsp_rx_header_UCE','ioaiu_core_wrapper.dtr_rsp_rx_message_UCE','ioaiu_core_wrapper.dtw_dbg_rsp_header_UCE','ioaiu_core_wrapper.dtw_dbg_rsp_message_UCE','ioaiu_core_wrapper.dtw_rsp_header_UCE','ioaiu_core_wrapper.dtw_rsp_message_UCE','ioaiu_core_wrapper.str_req_header_UCE','ioaiu_core_wrapper.str_req_message_UCE'];      

   var ioaiu_aceliteE_type2_dup_uce_signals_array = ['dup_unit.cmd_rsp_header_UCE','dup_unit.cmd_rsp_message_UCE','dup_unit.dtr_req_rx_data_UCE','dup_unit.dtr_req_rx_header_UCE','dup_unit.dtr_req_rx_message_UCE','dup_unit.dtr_rsp_rx_header_UCE','dup_unit.dtr_rsp_rx_message_UCE','dup_unit.dtw_dbg_rsp_header_UCE','dup_unit.dtw_dbg_rsp_message_UCE','dup_unit.dtw_rsp_header_UCE','dup_unit.dtw_rsp_message_UCE','dup_unit.str_req_header_UCE','dup_unit.str_req_message_UCE'];

     var chi_aiu_unit_outputs_array = ['smi_tx0_ndp_targ_id', 'smi_tx0_ndp_src_id', 'smi_tx0_ndp_ndp_len', 'smi_tx0_ndp_ndp', 'smi_tx0_ndp_msg_type', 'smi_tx0_ndp_msg_id', 'smi_tx0_ndp_dp_present', 'smi_tx1_ndp_targ_id', 'smi_tx1_ndp_src_id', 'smi_tx1_ndp_ndp_len', 'smi_tx1_ndp_ndp', 'smi_tx1_ndp_msg_type', 'smi_tx1_ndp_msg_id', 'smi_tx1_ndp_dp_present'/*, 'smi_tx2_ndp_targ_id', 'smi_tx2_ndp_src_id', 'smi_tx2_ndp_ndp_len', 'smi_tx2_ndp_ndp', 'smi_tx2_ndp_msg_type', 'smi_tx2_ndp_msg_id', 'smi_tx2_ndp_dp_present', 'smi_tx2_dp_user', 'smi_tx2_dp_last', 'smi_tx2_dp_data'*/, 'smi_rx0_ndp_msg_ready', 'smi_rx1_ndp_msg_ready'/*, 'smi_rx2_ndp_msg_ready', 'smi_rx2_dp_ready'*/];

     var chi_aiu_dup_unit_outputs_array = ['dup_unit__smi_tx0_ndp_targ_id', 'dup_unit__smi_tx0_ndp_src_id', 'dup_unit__smi_tx0_ndp_ndp_len', 'dup_unit__smi_tx0_ndp_ndp', 'dup_unit__smi_tx0_ndp_msg_type', 'dup_unit__smi_tx0_ndp_msg_id', 'dup_unit__smi_tx0_ndp_dp_present', 'dup_unit__smi_tx1_ndp_targ_id', 'dup_unit__smi_tx1_ndp_src_id', 'dup_unit__smi_tx1_ndp_ndp_len', 'dup_unit__smi_tx1_ndp_ndp', 'dup_unit__smi_tx1_ndp_msg_type', 'dup_unit__smi_tx1_ndp_msg_id', 'dup_unit__smi_tx1_ndp_dp_present'/*, 'dup_unit__smi_tx2_ndp_targ_id', 'dup_unit__smi_tx2_ndp_src_id', 'dup_unit__smi_tx2_ndp_ndp_len', 'dup_unit__smi_tx2_ndp_ndp', 'dup_unit__smi_tx2_ndp_msg_type', 'dup_unit__smi_tx2_ndp_msg_id', 'dup_unit__smi_tx2_ndp_dp_present', 'dup_unit__smi_tx2_dp_user', 'dup_unit__smi_tx2_dp_last', 'dup_unit__smi_tx2_dp_data'*/, 'dup_unit__smi_rx0_ndp_msg_ready', 'dup_unit__smi_rx1_ndp_msg_ready'/*, 'dup_unit__smi_rx2_ndp_msg_ready', 'dup_unit__smi_rx2_dp_ready'*/];


   var chi_aiu_uce_signals_array = ['chi_aiu_cmux_UCE','chi_aiu_native_decode_err_UCE','chi_aiu_native_snp_resp_UCE','chi_aiu_placeholder_UCE','chi_aiu_timeout_error_UCE','chi_aiu_transport_error_UCE'];
      
   var chi_aiu_dup_uce_signals_array = ['dup_unit__chi_aiu_cmux_UCE','dup_unit__chi_aiu_native_decode_err_UCE','dup_unit__chi_aiu_native_snp_resp_UCE','dup_unit__chi_aiu_placeholder_UCE','dup_unit__chi_aiu_timeout_error_UCE','dup_unit__chi_aiu_transport_error_UCE'];

   var dce_ce_signals_array = ['dce_cmux_cmd_req_CE','dce_cmux_mrd_rsp_CE','dce_cmux_rbr_rsp_CE','dce_cmux_snp_rsp_CE','dce_cmux_str_rsp_CE','dce_cmux_sys_req_rx_CE','dce_cmux_sys_rsp_rx_CE','dce_cmux_upd_req_CE','dce_dm_CE'];
      
   var dce_dup_ce_signals_array = ['dup_unit_dce_cmux_cmd_req_CE','dup_unit_dce_cmux_mrd_rsp_CE','dup_unit_dce_cmux_rbr_rsp_CE','dup_unit_dce_cmux_snp_rsp_CE','dup_unit_dce_cmux_str_rsp_CE','dup_unit_dce_cmux_sys_req_rx_CE','dup_unit_dce_cmux_sys_rsp_rx_CE','dup_unit_dce_cmux_upd_req_CE','dup_unit_dce_dm_CE'];

   var dii_ce_signals_array = ['dii_cmux_cmd_req_CE','dii_cmux_dtr_rsp_CE','dii_cmux_dtw_dbg_rsp_CE','dii_cmux_dtw_req_CE','dii_cmux_str_rsp_CE','dii_placeholder_CE','dii_read_buffer_CE'];
      
   var dii_dup_ce_signals_array = ['late_dii_cmux_cmd_req_CE','late_dii_cmux_dtr_rsp_CE','late_dii_cmux_dtw_dbg_rsp_CE','late_dii_cmux_dtw_req_CE','late_dii_cmux_str_rsp_CE','late_dii_placeholder_CE','late_dii_read_buffer_CE'];

   var dve_ce_signals_array = ['dve_cmux_cmd_req_CE','dve_cmux_dtw_dbg_req_CE','dve_cmux_dtw_req_CE','dve_cmux_snp_rsp_rx_CE','dve_cmux_str_rsp_CE','dve_cmux_sys_req_rx_CE','dve_trace_mem_CE'];
      
   var dve_dup_ce_signals_array = ['dup_unit__dve_cmux_cmd_req_CE','dup_unit__dve_cmux_dtw_dbg_req_CE','dup_unit__dve_cmux_dtw_req_CE','dup_unit__dve_cmux_snp_rsp_rx_CE','dup_unit__dve_cmux_str_rsp_CE','dup_unit__dve_cmux_sys_req_rx_CE','dup_unit__dve_trace_mem_CE'];

   var dmi_ce_signals_array = ['dmi_c_wr_buff_CE','dmi_cmux_cmd_req_CE','dmi_cmux_dtr_rsp_CE','dmi_cmux_dtw_dbg_rsp_CE','dmi_cmux_dtw_req_CE','dmi_cmux_mrd_req_CE','dmi_cmux_rbr_req_CE','dmi_cmux_str_rsp_CE','dmi_placeholder_CE','dmi_rd_buffer_CE','dmi_smc_data_CE','dmi_smc_tag_CE'];

   var dmi_dup_ce_signals_array = ['dup_unit__dmi_c_wr_buff_CE','dup_unit__dmi_cmux_cmd_req_CE','dup_unit__dmi_cmux_dtr_rsp_CE','dup_unit__dmi_cmux_dtw_dbg_rsp_CE','dup_unit__dmi_cmux_dtw_req_CE','dup_unit__dmi_cmux_mrd_req_CE','dup_unit__dmi_cmux_rbr_req_CE','dup_unit__dmi_cmux_str_rsp_CE','dup_unit__dmi_placeholder_CE','dup_unit__dmi_rd_buffer_CE','dup_unit__dmi_smc_data_CE','dup_unit__dmi_smc_tag_CE'];
      
   var ioaiu_ace_ce_signals_array = ['ioaiu_core_wrapper.cmd_rsp_CE','ioaiu_core_wrapper.dtr_req_rx_CE','ioaiu_core_wrapper.dtr_rsp_rx_CE','ioaiu_core_wrapper.dtw_dbg_rsp_CE','ioaiu_core_wrapper.dtw_rsp_CE','ioaiu_core_wrapper.snp_req_CE','ioaiu_core_wrapper.str_req_CE','ioaiu_core_wrapper.sys_req_rx_CE','ioaiu_core_wrapper.sys_rsp_rx_CE','ioaiu_core_wrapper.upd_rsp_CE','ioaiu_core_wrapper.cmp_rsp_CE'];

   var ioaiu_ace_dup_ce_signals_array = ['dup_unit.cmd_rsp_CE','dup_unit.dtr_req_rx_CE','dup_unit.dtr_rsp_rx_CE','dup_unit.dtw_dbg_rsp_CE','dup_unit.dtw_rsp_CE','dup_unit.snp_req_CE','dup_unit.str_req_CE','dup_unit.sys_req_rx_CE','dup_unit.sys_rsp_rx_CE','dup_unit.upd_rsp_CE','dup_unit.cmp_rsp_CE']; 

   var ioaiu_axi4_w_cache_ce_signals_array = ['ioaiu_core_wrapper.cmd_rsp_CE','ioaiu_core_wrapper.dtr_req_rx_CE','ioaiu_core_wrapper.dtr_rsp_rx_CE','ioaiu_core_wrapper.dtw_dbg_rsp_CE','ioaiu_core_wrapper.dtw_rsp_CE','ioaiu_core_wrapper.snp_req_CE','ioaiu_core_wrapper.str_req_CE','ioaiu_core_wrapper.sys_req_rx_CE','ioaiu_core_wrapper.sys_rsp_rx_CE','ioaiu_core_wrapper.upd_rsp_CE'];

   var ioaiu_axi4_w_cache_dup_ce_signals_array = ['dup_unit.cmd_rsp_CE','dup_unit.dtr_req_rx_CE','dup_unit.dtr_rsp_rx_CE','dup_unit.dtw_dbg_rsp_CE','dup_unit.dtw_rsp_CE','dup_unit.snp_req_CE','dup_unit.str_req_CE','dup_unit.sys_req_rx_CE','dup_unit.sys_rsp_rx_CE','dup_unit.upd_rsp_CE']; 

   var ioaiu_axi4_wo_cache_ce_signals_array = ['ioaiu_core_wrapper.cmd_rsp_CE','ioaiu_core_wrapper.dtr_req_rx_CE','ioaiu_core_wrapper.dtw_dbg_rsp_CE','ioaiu_core_wrapper.dtw_rsp_CE','ioaiu_core_wrapper.str_req_CE']; 

   var ioaiu_axi4_wo_cache_dup_ce_signals_array = ['dup_unit.cmd_rsp_CE','dup_unit.dtr_req_rx_CE','dup_unit.dtw_dbg_rsp_CE','dup_unit.dtw_rsp_CE','dup_unit.str_req_CE'];

   var ioaiu_acelite_ce_signals_array = ['ioaiu_core_wrapper.cmd_rsp_CE','ioaiu_core_wrapper.dtr_req_rx_CE','ioaiu_core_wrapper.dtw_dbg_rsp_CE','ioaiu_core_wrapper.dtw_rsp_CE','ioaiu_core_wrapper.str_req_CE']; 

   var ioaiu_acelite_dup_ce_signals_array = ['dup_unit.cmd_rsp_CE','dup_unit.dtr_req_rx_CE','dup_unit.dtw_dbg_rsp_CE','dup_unit.dtw_rsp_CE','dup_unit.str_req_CE']; 

   var ioaiu_aceliteE_type1_ce_signals_array = ['ioaiu_core_wrapper.cmd_rsp_CE','ioaiu_core_wrapper.dtr_req_rx_CE','ioaiu_core_wrapper.dtr_rsp_rx_CE','ioaiu_core_wrapper.dtw_dbg_rsp_CE','ioaiu_core_wrapper.dtw_rsp_CE','ioaiu_core_wrapper.snp_req_CE','ioaiu_core_wrapper.str_req_CE','ioaiu_core_wrapper.sys_rsp_rx_CE']; 

   var ioaiu_aceliteE_type1_dup_ce_signals_array = ['dup_unit.cmd_rsp_CE','dup_unit.dtr_req_rx_CE','dup_unit.dtr_rsp_rx_CE','dup_unit.dtw_dbg_rsp_CE','dup_unit.dtw_rsp_CE','dup_unit.snp_req_CE','dup_unit.str_req_CE','dup_unit.sys_rsp_rx_CE']; 

   var ioaiu_aceliteE_type2_ce_signals_array = ['ioaiu_core_wrapper.cmd_rsp_CE','ioaiu_core_wrapper.dtr_req_rx_CE','ioaiu_core_wrapper.dtr_rsp_rx_CE','ioaiu_core_wrapper.dtw_dbg_rsp_CE','ioaiu_core_wrapper.dtw_rsp_CE','ioaiu_core_wrapper.str_req_CE']; 

   var ioaiu_aceliteE_type2_dup_ce_signals_array = ['dup_unit.cmd_rsp_CE','dup_unit.dtr_req_rx_CE','dup_unit.dtr_rsp_rx_CE','dup_unit.dtw_dbg_rsp_CE','dup_unit.dtw_rsp_CE','dup_unit.str_req_CE']; 

   var chi_aiu_ce_signals_array = ['chi_aiu_placeholder_CE','chi_aiu_cmux_sys_rsp_rx_CE','chi_aiu_cmux_sys_req_rx_CE','chi_aiu_cmux_str_req_CE','chi_aiu_cmux_snp_req_CE','chi_aiu_cmux_dtw_rsp_CE','chi_aiu_cmux_dtr_rsp_rx_CE','chi_aiu_cmux_dtr_req_rx_CE','chi_aiu_cmux_cmp_rsp_CE','chi_aiu_cmux_cmd_rsp_CE'];

   var chi_aiu_dup_ce_signals_array = ['dup_unit__chi_aiu_placeholder_CE','dup_unit__chi_aiu_cmux_sys_rsp_rx_CE','dup_unit__chi_aiu_cmux_sys_req_rx_CE','dup_unit__chi_aiu_cmux_str_req_CE','dup_unit__chi_aiu_cmux_snp_req_CE','dup_unit__chi_aiu_cmux_dtw_rsp_CE','dup_unit__chi_aiu_cmux_dtr_rsp_rx_CE','dup_unit__chi_aiu_cmux_dtr_req_rx_CE','dup_unit__chi_aiu_cmux_cmp_rsp_CE','dup_unit__chi_aiu_cmux_cmd_rsp_CE'];

        %> 
   <% var dce_outputs_array     = [dce_unit_outputs_array]; %> 
   <% var dmi_outputs_array     = [dmi_unit_outputs_array]; %> 
   <% var dve_outputs_array     = [dve_unit_outputs_array]; %> 
   <% var dii_outputs_array     = [dii_unit_outputs_array]; %> 
   <% var ioaiu_outputs_array   = [ioaiu_unit_outputs_array]; %> 
   <% var chi_aiu_outputs_array = [chi_aiu_unit_outputs_array]; %> 
   <% var dce_dup_outputs_array     = [dce_dup_unit_outputs_array]; %> 
   <% var dmi_dup_outputs_array     = [dmi_dup_unit_outputs_array]; %> 
   <% var dve_dup_outputs_array     = [dve_dup_unit_outputs_array]; %> 
   <% var dii_dup_outputs_array     = [dii_dup_unit_outputs_array]; %> 
   <% var ioaiu_dup_outputs_array   = [ioaiu_dup_unit_outputs_array]; %> 
   <% var chi_aiu_dup_outputs_array = [chi_aiu_dup_unit_outputs_array]; %> 
   <% var dce_uce_array     = [dce_uce_signals_array]; %> 
   <% var dmi_uce_array     = [dmi_uce_signals_array]; %> 
   <% var dve_uce_array     = [dve_uce_signals_array]; %> 
   <% var dii_uce_array     = [dii_uce_signals_array]; %> 
   <% var ioaiu_uce_array   = [ioaiu_ace_uce_signals_array, ioaiu_aceliteE_type1_uce_signals_array,ioaiu_acelite_uce_signals_array,ioaiu_axi4_wo_cache_uce_signals_array,ioaiu_axi4_w_cache_uce_signals_array,ioaiu_aceliteE_type2_uce_signals_array]; %> 
   <% var chi_aiu_uce_array = [chi_aiu_uce_signals_array]; %> 
   <% var dce_dup_uce_array     = [dce_dup_uce_signals_array]; %> 
   <% var dmi_dup_uce_array     = [dmi_dup_uce_signals_array]; %> 
   <% var dve_dup_uce_array     = [dve_dup_uce_signals_array]; %> 
   <% var dii_dup_uce_array     = [dii_dup_uce_signals_array]; %> 
   <% var ioaiu_dup_uce_array   = [ioaiu_ace_dup_uce_signals_array, ioaiu_aceliteE_type1_dup_uce_signals_array,ioaiu_acelite_dup_uce_signals_array,ioaiu_axi4_wo_cache_dup_uce_signals_array,ioaiu_axi4_w_cache_dup_uce_signals_array,ioaiu_aceliteE_type2_dup_uce_signals_array]; %> 
   <% var chi_aiu_dup_uce_array = [chi_aiu_dup_uce_signals_array]; %> 
   <% var dce_ce_array     = [dce_ce_signals_array]; %> 
   <% var dmi_ce_array     = [dmi_ce_signals_array]; %> 
   <% var dve_ce_array     = [dve_ce_signals_array]; %> 
   <% var dii_ce_array     = [dii_ce_signals_array]; %> 
   <% var ioaiu_ce_array   = [ioaiu_ace_ce_signals_array, ioaiu_aceliteE_type1_ce_signals_array,ioaiu_acelite_ce_signals_array,ioaiu_axi4_wo_cache_ce_signals_array,ioaiu_axi4_w_cache_ce_signals_array,ioaiu_aceliteE_type2_ce_signals_array]; %> 
   <% var chi_aiu_ce_array = [chi_aiu_ce_signals_array]; %> 
   <% var dce_dup_ce_array     = [dce_dup_ce_signals_array]; %> 
   <% var dmi_dup_ce_array     = [dmi_dup_ce_signals_array]; %> 
   <% var dve_dup_ce_array     = [dve_dup_ce_signals_array]; %> 
   <% var dii_dup_ce_array     = [dii_dup_ce_signals_array]; %> 
   <% var ioaiu_dup_ce_array   = [ioaiu_ace_dup_ce_signals_array, ioaiu_aceliteE_type1_dup_ce_signals_array,ioaiu_acelite_dup_ce_signals_array,ioaiu_axi4_wo_cache_dup_ce_signals_array,ioaiu_axi4_w_cache_dup_ce_signals_array,ioaiu_aceliteE_type2_dup_ce_signals_array]; %> 
   <% var chi_aiu_dup_ce_array = [chi_aiu_dup_ce_signals_array]; %> 
   <% var total_ncore_units = obj.DceInfo.length +obj.DveInfo.length +obj.DiiInfo.length +obj.DmiInfo.length + obj.AiuInfo.length%>
   <% var offset_start = 0; %>
   <% for(pidx = 0; pidx < obj.nAIUs; pidx++) { %>
        fault_if        fault_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>();
        bist_if         bist_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>();
    <% } %>

    <% for(pidx = 0; pidx < obj.nDCEs; pidx++) { %>
        fault_if        fault_<%=obj.DceInfo[pidx].strRtlNamePrefix%>();
        bist_if         bist_<%=obj.DceInfo[pidx].strRtlNamePrefix%>();
    <% } %>

    <% for(pidx =  0; pidx < obj.nDMIs; pidx++) { %>
        fault_if        fault_<%=obj.DmiInfo[pidx].strRtlNamePrefix%>();
        bist_if         bist_<%=obj.DmiInfo[pidx].strRtlNamePrefix%>();
    <% } %>

    <% for(pidx = 0; pidx < obj.nDIIs; pidx++) { %>
        fault_if        fault_<%=obj.DiiInfo[pidx].strRtlNamePrefix%>();
        bist_if         bist_<%=obj.DiiInfo[pidx].strRtlNamePrefix%>();
    <% } %>

    <% for(var pidx = 0; pidx < obj.nDVEs; pidx++) { %>
        fault_if        fault_<%=obj.DveInfo[pidx].strRtlNamePrefix%>();
        bist_if         bist_<%=obj.DveInfo[pidx].strRtlNamePrefix%>();
    <% } %>
   logic [159:0] expected_mission_fault_reg, expected_latent_fault_reg, expected_cerr_over_thres_fault_reg;
   logic [31:0] FSCERRR;
   logic [31:0] SCLFX0_latent_fault;
   logic [31:0] SCLFX1_latent_fault;
   logic [31:0] SCLFX2_latent_fault;
   logic [31:0] SCLFX3_latent_fault;
   logic [31:0] SCLFX4_latent_fault;
   logic [31:0] SCMFX0_mission_fault;
   logic [31:0] SCMFX1_mission_fault;
   logic [31:0] SCMFX2_mission_fault;
   logic [31:0] SCMFX3_mission_fault;
   logic [31:0] SCMFX4_mission_fault;
   logic [31:0] SCCETHF0;
   logic [31:0] SCCETHF1;
   logic [31:0] SCCETHF2;
   logic [31:0] SCCETHF3;
   logic [31:0] SCCETHF4;
   localparam aiu_offset_start = <%=offset_start%>;
    <% for (var i = 0; i<(obj.AiuInfo.length); i++) { %>
    logic expected_<%=obj.AiuInfo[i].strRtlNamePrefix%>_mission_fault, expected_<%=obj.AiuInfo[i].strRtlNamePrefix%>_latent_fault;
    <%  offset_start = offset_start + 1; } %>
   localparam aiu_offset_end = <%=offset_start - 1%>;
   localparam dmi_offset_start = <%=offset_start%>;
    <% for (var i = 0; i<obj.DmiInfo.length; i++) { %>
    logic expected_<%=obj.DmiInfo[i].strRtlNamePrefix%>_mission_fault, expected_<%=obj.DmiInfo[i].strRtlNamePrefix%>_latent_fault;
    <%  offset_start = offset_start + 1; } %>
   localparam dmi_offset_end = <%=offset_start - 1%>;
   localparam dii_offset_start = <%=offset_start%>;
    <% for (var i = 0; i<(obj.DiiInfo.length); i++) { %> 
    logic expected_<%=obj.DiiInfo[i].strRtlNamePrefix%>_mission_fault, expected_<%=obj.DiiInfo[i].strRtlNamePrefix%>_latent_fault;
    <%  offset_start = offset_start + 1; } %>
   localparam dii_offset_end = <%=offset_start - 1%>;
   localparam dve_offset_start = <%=offset_start%>;
    <% for (var i = 0; i<obj.DveInfo.length; i++) { %>
    logic expected_<%=obj.DveInfo[i].strRtlNamePrefix%>_mission_fault, expected_<%=obj.DveInfo[i].strRtlNamePrefix%>_latent_fault;
    <%  offset_start = offset_start + 1; } %>
   localparam dve_offset_end = <%=offset_start - 1%>;
   localparam dce_offset_start = <%=offset_start%>;
    <% for (var i = 0; i<obj.DceInfo.length; i++) { %>
    logic expected_<%=obj.DceInfo[i].strRtlNamePrefix%>_mission_fault, expected_<%=obj.DceInfo[i].strRtlNamePrefix%>_latent_fault;
    <%  offset_start = offset_start + 1; } %>
   localparam dce_offset_end = <%=offset_start - 1%>;
   logic [<%=numChiAiu%> -1:0]          expected_caiu_mission_fault_reg, expected_caiu_latent_fault_reg,  expected_caiu_cerr_over_thres_fault_reg;
   logic [<%=numIoAiu%> -1:0]           expected_ioaiu_mission_fault_reg, expected_ioaiu_latent_fault_reg,  expected_ioaiu_cerr_over_thres_fault_reg;
   logic [<%=obj.DmiInfo.length%> -1:0] expected_dmi_mission_fault_reg, expected_dmi_latent_fault_reg,  expected_dmi_cerr_over_thres_fault_reg;
   logic [<%=obj.DiiInfo.length%> -1:0] expected_dii_mission_fault_reg, expected_dii_latent_fault_reg,  expected_dii_cerr_over_thres_fault_reg;
   logic [<%=obj.DveInfo.length%> -1:0] expected_dve_mission_fault_reg, expected_dve_latent_fault_reg,  expected_dve_cerr_over_thres_fault_reg;
   logic [<%=obj.DceInfo.length%> -1:0] expected_dce_mission_fault_reg, expected_dce_latent_fault_reg,  expected_dce_cerr_over_thres_fault_reg;

    bit func_unit_uncorr_err_inj, dup_unit_uncorr_err_inj, both_units_uncorr_err_inj;
    bit dce_uncorr_err_inj, dmi_uncorr_err_inj, dve_uncorr_err_inj, dii_uncorr_err_inj, chiaiu_uncorr_err_inj, ioaiu_uncorr_err_inj;
    int num_dce_signals_for_uncorr_err_inj     =    (<%=obj.DceInfo[0].ResilienceInfo.enableUnitDuplication%> == 1) ? <%=dce_unit_outputs_array.length%> : 0; 
    int num_dmi_signals_for_uncorr_err_inj     =    (<%=obj.DmiInfo[0].ResilienceInfo.enableUnitDuplication%> == 1) ? <%=dmi_dup_unit_outputs_array.length%> : 0; 
    int num_dve_signals_for_uncorr_err_inj     =    (<%=obj.DveInfo[0].ResilienceInfo.enableUnitDuplication%> == 1) ? <%=dve_dup_unit_outputs_array.length%> : 0; 
    int num_dii_signals_for_uncorr_err_inj     =    (<%=obj.DiiInfo[0].ResilienceInfo.enableUnitDuplication%> == 1) ? <%=dii_dup_unit_outputs_array.length%> : 0; 
    int num_ioaiu_signals_for_uncorr_err_inj   =    (<%=obj.AiuInfo[0].ResilienceInfo.enableUnitDuplication%> == 1) ? <%=ioaiu_dup_unit_outputs_array.length%> : 0; 
    int num_chi_aiu_signals_for_uncorr_err_inj =    (<%=obj.AiuInfo[0].ResilienceInfo.enableUnitDuplication%> == 1) ? <%=chi_aiu_dup_unit_outputs_array.length%> : 0;
    bit bypass_fsys_fault_inject_reg_check_error=0;
    bit bypass_fsys_fault_check_with_uce_signals=0;
    bit bypass_signal_invalid_value_check=0;
    uvm_event injectSingleErr;
    bit uncorr_err_inj_test_start_indication;
    bit corr_err_inj_test_start_indication;

    class check_bist_fault_fsm;
    typedef enum logic [2:0] {IDLE, CHECK1, CHECK2, CHECK3, CHECK4, CHECK5, CHECK6} statetype;
    statetype curr_state;
    virtual fault_if        fault_if_inst;
    virtual bist_if         bist_if_inst;
    string strRtlNamePrefix = "";
    static uvm_event_pool ev_pool  = uvm_event_pool::get_global_pool();
    static uvm_event ev_fsc_bist_start   = ev_pool.get("ev_fsc_bist_start");
    static uvm_event fsc_test_done = ev_pool.get("fsc_test_done");
    bit bist_next_ack_q;
    bit bist_next_q;
    bit [5:0]bist_next_assered;
    bit change_state;
    bit test_done;
    string unit_type="";

    virtual task run();
      `uvm_info("check_bist_fault_fsm", $psprintf("%0s.run Starting...",strRtlNamePrefix),UVM_LOW)
      if(!($test$plusargs("disable_bist"))) begin
        fork
        begin
            `uvm_info("check_bist_fault_fsm", "Waiting for fsc test to finish - fsc_test_done.wait_trigger", UVM_LOW)
            fsc_test_done.wait_trigger();
            test_done = 1;
        end

        begin
            forever begin
                ev_fsc_bist_start.wait_trigger();
                `uvm_info("check_bist_fault_fsm", $psprintf("%0s.bist_fault_fsm starting...",strRtlNamePrefix),UVM_LOW)
                bist_fault_fsm();
            end
        end
        join_none
        wait(test_done==1);
        disable fork;
      end
      `uvm_info("check_bist_fault_fsm", $psprintf("%0s.run Ending...",strRtlNamePrefix),UVM_LOW)
    endtask

    virtual task bist_fault_fsm();
    bit done=0;
        curr_state = IDLE;
        bist_next_ack_q = 0;
        bist_next_q = 0;
        do begin : _do_while_
            @(posedge fault_if_inst.clk);
            if(bist_if_inst.bist_next==1 && bist_next_q==0) 
                change_state = 1;
            if(change_state==1 && bist_if_inst.bist_next_ack==1 && bist_next_ack_q==0) begin : _change_state_
                if(curr_state==IDLE) begin : _CHECK1_
                    curr_state = CHECK1;
                    if(fault_if_inst.mission_fault==0 && fault_if_inst.latent_fault==0 && fault_if_inst.cerr_over_thres_fault==0)
                        `uvm_info("check_bist_fault_fsm", $psprintf("%0s.bist_fault_fsm %0s state confirmed expected values, mission_fault=0 latent_fault=0 cerr_over_thres_fault=0",strRtlNamePrefix,curr_state.name()),UVM_MEDIUM)
                    else
                        `uvm_error("check_bist_fault_fsm", $psprintf("%0s.bist_fault_fsm %0s state, Expected : mission_fault=0 latent_fault=0 cerr_over_thres_fault=0. Actual : mission_fault=%0d latent_fault=%0d cerr_over_thres_fault=%0d",strRtlNamePrefix,curr_state.name(),fault_if_inst.mission_fault,fault_if_inst.latent_fault,fault_if_inst.cerr_over_thres_fault))

                end : _CHECK1_
                else if(curr_state==CHECK1) begin : _CHECK2_
                    curr_state = CHECK2;
                    if(fault_if_inst.mission_fault==0 && fault_if_inst.latent_fault==0 && fault_if_inst.cerr_over_thres_fault==1)
                        `uvm_info("check_bist_fault_fsm", $psprintf("%0s.bist_fault_fsm %0s state confirmed expected values, mission_fault=0 latent_fault=0 cerr_over_thres_fault=1",strRtlNamePrefix,curr_state.name()),UVM_MEDIUM)
                    else
                        `uvm_error("check_bist_fault_fsm", $psprintf("%0s.bist_fault_fsm %0s state, Expected : mission_fault=0 latent_fault=0 cerr_over_thres_fault=1. Actual : mission_fault=%0d latent_fault=%0d cerr_over_thres_fault=%0d",strRtlNamePrefix,curr_state.name(),fault_if_inst.mission_fault,fault_if_inst.latent_fault,fault_if_inst.cerr_over_thres_fault))
                end : _CHECK2_
                else if(curr_state==CHECK2) begin : _CHECK3_
                    curr_state = CHECK3;
                    if(fault_if_inst.mission_fault==0 && fault_if_inst.latent_fault==1 && fault_if_inst.cerr_over_thres_fault==0)
                        `uvm_info("check_bist_fault_fsm", $psprintf("%0s.bist_fault_fsm %0s state confirmed expected values, mission_fault=0 latent_fault=1 cerr_over_thres_fault=0",strRtlNamePrefix,curr_state.name()),UVM_MEDIUM)
                    else
                        `uvm_error("check_bist_fault_fsm", $psprintf("%0s.bist_fault_fsm %0s state, Expected : mission_fault=0 latent_fault=1 cerr_over_thres_fault=0. Actual : mission_fault=%0d latent_fault=%0d cerr_over_thres_fault=%0d",strRtlNamePrefix,curr_state.name(),fault_if_inst.mission_fault,fault_if_inst.latent_fault,fault_if_inst.cerr_over_thres_fault))
                end : _CHECK3_
                else if(curr_state==CHECK3) begin : _CHECK4_
                    curr_state = CHECK4;
                    if(fault_if_inst.mission_fault==1 && fault_if_inst.latent_fault==0 && fault_if_inst.cerr_over_thres_fault==0)
                        `uvm_info("check_bist_fault_fsm", $psprintf("%0s.bist_fault_fsm %0s state confirmed expected values, mission_fault=1 latent_fault=0 cerr_over_thres_fault=0",strRtlNamePrefix,curr_state.name()),UVM_MEDIUM)
                    else
                        `uvm_error("check_bist_fault_fsm", $psprintf("%0s.bist_fault_fsm %0s state, Expected : mission_fault=1 latent_fault=0 cerr_over_thres_fault=0. Actual : mission_fault=%0d latent_fault=%0d cerr_over_thres_fault=%0d",strRtlNamePrefix,curr_state.name(),fault_if_inst.mission_fault,fault_if_inst.latent_fault,fault_if_inst.cerr_over_thres_fault))
                end : _CHECK4_
                else if(curr_state==CHECK4) begin : _CHECK5_
                    curr_state = CHECK5;
//1. For bist timeout error test (enabled by plusarg - "exp_bist_timeout_err"), Don't check for chiaiu, ioaiu & dce (bist_timeout_trigger does exist). 
// For each unit type, there is separate test and at a time, onlysingle unit out of all units have mission fault set to 0 as part of bist timeout error test. It is difficult to capture it here at the moment.
// Normally, In step-5 with bist_next_ack, mission fault is asserted by fault checker as part of bist timeout trigger. 
// But in bist timeout error test, fault checker will assert bist_next_ack with mission fault set to 0. 
// Anyway mission fault value in step-5 as part of bist timeout error is captured by FSCBISTAR reg (step-5 error) & checked in test (concerto_fsc_task).                    
//2. dve, dmi & dii don't have bist_timeout_trigger, so mission fault value in all the cases are same.
                    if(($test$plusargs("exp_bist_timeout_err")) && ((unit_type=="dve") || (unit_type=="dmi") || (unit_type=="dii"))) begin 
                        if(fault_if_inst.mission_fault==1 && fault_if_inst.latent_fault==0 && fault_if_inst.cerr_over_thres_fault==0)
                            `uvm_info("check_bist_fault_fsm", $psprintf("%0s.bist_fault_fsm %0s state confirmed expected values, mission_fault=1 latent_fault=0 cerr_over_thres_fault=0",strRtlNamePrefix,curr_state.name()),UVM_MEDIUM)
                        else
                            `uvm_error("check_bist_fault_fsm", $psprintf("%0s.bist_fault_fsm %0s state, Expected : mission_fault=1 latent_fault=0 cerr_over_thres_fault=0. Actual : mission_fault=%0d latent_fault=%0d cerr_over_thres_fault=%0d",strRtlNamePrefix,curr_state.name(),fault_if_inst.mission_fault,fault_if_inst.latent_fault,fault_if_inst.cerr_over_thres_fault))
                    end
                end : _CHECK5_
                else if(curr_state==CHECK5) begin : _CHECK6_
                    curr_state = CHECK6;
                    if(fault_if_inst.mission_fault==0 && fault_if_inst.latent_fault==0 && fault_if_inst.cerr_over_thres_fault==0)
                        `uvm_info("check_bist_fault_fsm", $psprintf("%0s.bist_fault_fsm %0s state confirmed expected values, mission_fault=0 latent_fault=0 cerr_over_thres_fault=0",strRtlNamePrefix,curr_state.name()),UVM_MEDIUM)
                    else
                        `uvm_error("check_bist_fault_fsm", $psprintf("%0s.bist_fault_fsm %0s state, Expected : mission_fault=0 latent_fault=0 cerr_over_thres_fault=0. Actual : mission_fault=%0d latent_fault=%0d cerr_over_thres_fault=%0d",strRtlNamePrefix,curr_state.name(),fault_if_inst.mission_fault,fault_if_inst.latent_fault,fault_if_inst.cerr_over_thres_fault))
                    done=1;
                end : _CHECK6_
                change_state = 0;
            end : _change_state_
            bist_next_ack_q = bist_if_inst.bist_next_ack;
            bist_next_q = bist_if_inst.bist_next;
        end : _do_while_
        while(done==0);
    endtask

    endclass 


    initial begin
    <% for(pidx = 0; pidx < obj.nAIUs; pidx++) { %>
        check_bist_fault_fsm check_bist_fault_fsm_<%=obj.AiuInfo[pidx].strRtlNamePrefix%> = new();
    <% } %>

    <% for(pidx = 0; pidx < obj.nDCEs; pidx++) { %>
        check_bist_fault_fsm check_bist_fault_fsm_<%=obj.DceInfo[pidx].strRtlNamePrefix%> = new();
    <% } %>

    <% for(pidx =  0; pidx < obj.nDMIs; pidx++) { %>
        check_bist_fault_fsm check_bist_fault_fsm_<%=obj.DmiInfo[pidx].strRtlNamePrefix%> = new();
    <% } %>

    <% for(pidx = 0; pidx < obj.nDIIs; pidx++) { %>
        check_bist_fault_fsm check_bist_fault_fsm_<%=obj.DiiInfo[pidx].strRtlNamePrefix%> = new();
    <% } %>

    <% for(var pidx = 0; pidx < obj.nDVEs; pidx++) { %>
        check_bist_fault_fsm check_bist_fault_fsm_<%=obj.DveInfo[pidx].strRtlNamePrefix%> = new();
    <% } %>

    <% for(pidx = 0; pidx < obj.nAIUs; pidx++) { %>
        check_bist_fault_fsm_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>.fault_if_inst        = fault_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>;
        check_bist_fault_fsm_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>.bist_if_inst         = bist_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>;
        check_bist_fault_fsm_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>.strRtlNamePrefix = "<%=obj.AiuInfo[pidx].strRtlNamePrefix%>";
        check_bist_fault_fsm_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>.unit_type = "aiu";
    <% } %>

    <% for(pidx = 0; pidx < obj.nDCEs; pidx++) { %>
        check_bist_fault_fsm_<%=obj.DceInfo[pidx].strRtlNamePrefix%>.fault_if_inst        = fault_<%=obj.DceInfo[pidx].strRtlNamePrefix%>;
        check_bist_fault_fsm_<%=obj.DceInfo[pidx].strRtlNamePrefix%>.bist_if_inst         = bist_<%=obj.DceInfo[pidx].strRtlNamePrefix%>;
        check_bist_fault_fsm_<%=obj.DceInfo[pidx].strRtlNamePrefix%>.strRtlNamePrefix = "<%=obj.DceInfo[pidx].strRtlNamePrefix%>";
        check_bist_fault_fsm_<%=obj.DceInfo[pidx].strRtlNamePrefix%>.unit_type = "dce";
    <% } %>

    <% for(pidx =  0; pidx < obj.nDMIs; pidx++) { %>
        check_bist_fault_fsm_<%=obj.DmiInfo[pidx].strRtlNamePrefix%>.fault_if_inst        = fault_<%=obj.DmiInfo[pidx].strRtlNamePrefix%>;
        check_bist_fault_fsm_<%=obj.DmiInfo[pidx].strRtlNamePrefix%>.bist_if_inst         = bist_<%=obj.DmiInfo[pidx].strRtlNamePrefix%>;
        check_bist_fault_fsm_<%=obj.DmiInfo[pidx].strRtlNamePrefix%>.strRtlNamePrefix = "<%=obj.DmiInfo[pidx].strRtlNamePrefix%>";
        check_bist_fault_fsm_<%=obj.DmiInfo[pidx].strRtlNamePrefix%>.unit_type = "dmi";
    <% } %>

    <% for(pidx = 0; pidx < obj.nDIIs; pidx++) { %>
        check_bist_fault_fsm_<%=obj.DiiInfo[pidx].strRtlNamePrefix%>.fault_if_inst        = fault_<%=obj.DiiInfo[pidx].strRtlNamePrefix%>;
        check_bist_fault_fsm_<%=obj.DiiInfo[pidx].strRtlNamePrefix%>.bist_if_inst         = bist_<%=obj.DiiInfo[pidx].strRtlNamePrefix%>;
        check_bist_fault_fsm_<%=obj.DiiInfo[pidx].strRtlNamePrefix%>.strRtlNamePrefix = "<%=obj.DiiInfo[pidx].strRtlNamePrefix%>";
        check_bist_fault_fsm_<%=obj.DiiInfo[pidx].strRtlNamePrefix%>.unit_type = "dii";
    <% } %>

    <% for(var pidx = 0; pidx < obj.nDVEs; pidx++) { %>
        check_bist_fault_fsm_<%=obj.DveInfo[pidx].strRtlNamePrefix%>.fault_if_inst        = fault_<%=obj.DveInfo[pidx].strRtlNamePrefix%>;
        check_bist_fault_fsm_<%=obj.DveInfo[pidx].strRtlNamePrefix%>.bist_if_inst         = bist_<%=obj.DveInfo[pidx].strRtlNamePrefix%>;
        check_bist_fault_fsm_<%=obj.DveInfo[pidx].strRtlNamePrefix%>.strRtlNamePrefix = "<%=obj.DveInfo[pidx].strRtlNamePrefix%>";
        check_bist_fault_fsm_<%=obj.DveInfo[pidx].strRtlNamePrefix%>.unit_type = "dve";
    <% } %>


      fork
    <% for(pidx = 0; pidx < obj.nAIUs; pidx++) { %>
        check_bist_fault_fsm_<%=obj.AiuInfo[pidx].strRtlNamePrefix%>.run();
    <% } %>

    <% for(pidx = 0; pidx < obj.nDCEs; pidx++) { %>
        check_bist_fault_fsm_<%=obj.DceInfo[pidx].strRtlNamePrefix%>.run();
    <% } %>

    <% for(pidx =  0; pidx < obj.nDMIs; pidx++) { %>
        check_bist_fault_fsm_<%=obj.DmiInfo[pidx].strRtlNamePrefix%>.run();
    <% } %>

    <% for(pidx = 0; pidx < obj.nDIIs; pidx++) { %>
        check_bist_fault_fsm_<%=obj.DiiInfo[pidx].strRtlNamePrefix%>.run();
    <% } %>

    <% for(var pidx = 0; pidx < obj.nDVEs; pidx++) { %>
        check_bist_fault_fsm_<%=obj.DveInfo[pidx].strRtlNamePrefix%>.run();
    <% } %>
      join
    end
    
   //Inject uncorr error at fullsys.
   initial begin
     logic [1023:0] prev_val [127:0] [127:0];
     logic [1023:0] dup_prev_val [127:0] [127:0];
     int rand_pos_in_signal;
     bit expected_mission_fault, expected_latent_fault;
     automatic int signal_width;
     int clk_wait_after_release=10;
     reset_fsc_reg();
     if($test$plusargs("disable_bist"))
         FSYS_FAULT_INJECTOR_CHECKER_CLK_DELAY_BEFORE_ERR = 100;
     else
         FSYS_FAULT_INJECTOR_CHECKER_CLK_DELAY_BEFORE_ERR = 20480;
     uvm_config_db#(int unsigned)::set(null, "", "FSCERRR", FSCERRR); 

     uvm_config_db#(int unsigned)::set(null, "", "SCLFX0_latent_fault", SCLFX0_latent_fault); 
     uvm_config_db#(int unsigned)::set(null, "", "SCLFX1_latent_fault", SCLFX1_latent_fault); 
     uvm_config_db#(int unsigned)::set(null, "", "SCLFX2_latent_fault", SCLFX2_latent_fault); 
     uvm_config_db#(int unsigned)::set(null, "", "SCLFX3_latent_fault", SCLFX3_latent_fault); 
     uvm_config_db#(int unsigned)::set(null, "", "SCLFX4_latent_fault", SCLFX4_latent_fault); 

     uvm_config_db#(int unsigned)::set(null, "", "SCMFX0_mission_fault",SCMFX0_mission_fault ); 
     uvm_config_db#(int unsigned)::set(null, "", "SCMFX1_mission_fault",SCMFX1_mission_fault ); 
     uvm_config_db#(int unsigned)::set(null, "", "SCMFX2_mission_fault",SCMFX2_mission_fault ); 
     uvm_config_db#(int unsigned)::set(null, "", "SCMFX3_mission_fault",SCMFX3_mission_fault ); 
     uvm_config_db#(int unsigned)::set(null, "", "SCMFX4_mission_fault",SCMFX4_mission_fault ); 

     uvm_config_db#(int unsigned)::set(null, "", "SCCETHF0", SCCETHF0); 
     uvm_config_db#(int unsigned)::set(null, "", "SCCETHF1", SCCETHF1); 
     uvm_config_db#(int unsigned)::set(null, "", "SCCETHF2", SCCETHF2); 
     uvm_config_db#(int unsigned)::set(null, "", "SCCETHF3", SCCETHF3); 
     uvm_config_db#(int unsigned)::set(null, "", "SCCETHF4", SCCETHF4); 
     $value$plusargs("bypass_fsys_fault_inject_reg_check_error=%d",bypass_fsys_fault_inject_reg_check_error);
     $value$plusargs("bypass_fsys_fault_check_with_uce_signals=%d",bypass_fsys_fault_check_with_uce_signals);
     $value$plusargs("bypass_signal_invalid_value_check=%d",bypass_signal_invalid_value_check);
     if(bypass_fsys_fault_check_with_uce_signals==0) begin
         num_dce_signals_for_uncorr_err_inj     =    num_dce_signals_for_uncorr_err_inj + <%=dce_uce_signals_array.length%>; 
         num_dmi_signals_for_uncorr_err_inj     =    num_dmi_signals_for_uncorr_err_inj + <%=dmi_uce_signals_array.length%>; 
         num_dve_signals_for_uncorr_err_inj     =    num_dve_signals_for_uncorr_err_inj + <%=dve_uce_signals_array.length%>; 
         num_dii_signals_for_uncorr_err_inj     =    num_dii_signals_for_uncorr_err_inj + <%=dii_uce_signals_array.length%>; 
         num_chi_aiu_signals_for_uncorr_err_inj =    num_chi_aiu_signals_for_uncorr_err_inj + <%=chi_aiu_uce_signals_array.length%>;
       <% var num_of_signals = 0; %>
       <% for (var i = 0; i<(obj.AiuInfo.length); i++) { %>
       <% if ((obj.AiuInfo[i].fnNativeInterface != "CHI-A") && (obj.AiuInfo[i].fnNativeInterface != "CHI-B") && (obj.AiuInfo[i].fnNativeInterface != "CHI-E")) { %>
       <%   
          if(obj.AiuInfo[i].fnNativeInterface == "ACE" || obj.AiuInfo[i].fnNativeInterface == "ACE5") { num_of_signals = num_of_signals + ioaiu_uce_array[0].length;}
          else if(obj.AiuInfo[i].fnNativeInterface == "ACELITE-E") { 
              if(obj.AiuInfo[i].interfaces.axiInt.eAc>0) {
                num_of_signals = num_of_signals + ioaiu_uce_array[1].length;
              } else {
                num_of_signals = num_of_signals + ioaiu_uce_array[5].length;
              }
          }
          else if(obj.AiuInfo[i].fnNativeInterface == "ACE-LITE") {  num_of_signals = num_of_signals + ioaiu_uce_array[2].length; }
          else if(((obj.AiuInfo[i].fnNativeInterface == "AXI4") || (obj.AiuInfo[i].fnNativeInterface == "AXI5")) && (obj.AiuInfo[i].useCache==0)) { num_of_signals = num_of_signals + ioaiu_uce_array[3].length;}
          else if(((obj.AiuInfo[i].fnNativeInterface == "AXI4") || (obj.AiuInfo[i].fnNativeInterface == "AXI5"))&& (obj.AiuInfo[i].useCache==1)) { num_of_signals = num_of_signals + ioaiu_uce_array[4].length;}
       %>  
       <% }} %>
         num_ioaiu_signals_for_uncorr_err_inj   =    (num_ioaiu_signals_for_uncorr_err_inj * <%=numIoAiu%>) + <%=num_of_signals%>; 
     end
     if ($test$plusargs("func_unit_uncorr_err_inj") || $test$plusargs("dup_unit_uncorr_err_inj")) begin
         $value$plusargs("func_unit_uncorr_err_inj=%d",func_unit_uncorr_err_inj);
         $value$plusargs("dup_unit_uncorr_err_inj=%d",dup_unit_uncorr_err_inj);
         if(func_unit_uncorr_err_inj && dup_unit_uncorr_err_inj)  both_units_uncorr_err_inj = 1;
     end else begin
         func_unit_uncorr_err_inj = 1;
         if($test$plusargs("exp_bist_timeout_err")) begin
           func_unit_uncorr_err_inj = 1;
           dup_unit_uncorr_err_inj = 1;
         end
     end
     $value$plusargs("dce_uncorr_err_inj=%d",dce_uncorr_err_inj);
     $value$plusargs("dmi_uncorr_err_inj=%d",dmi_uncorr_err_inj);
     $value$plusargs("dve_uncorr_err_inj=%d",dve_uncorr_err_inj);
     $value$plusargs("dii_uncorr_err_inj=%d",dii_uncorr_err_inj);
     $value$plusargs("chiaiu_uncorr_err_inj=%d",chiaiu_uncorr_err_inj);
     $value$plusargs("ioaiu_uncorr_err_inj=%d",ioaiu_uncorr_err_inj);
     if(!((dce_uncorr_err_inj==1) ||  (dmi_uncorr_err_inj==1)|| (dve_uncorr_err_inj==1) || (dii_uncorr_err_inj==1) || (chiaiu_uncorr_err_inj==1) || (ioaiu_uncorr_err_inj==1))) begin
        if(!$test$plusargs("exp_bist_timeout_err")) begin
            randcase
            1: dce_uncorr_err_inj  = 1;
            1: dmi_uncorr_err_inj  = 1;
            1: dve_uncorr_err_inj  = 1;
            1: dii_uncorr_err_inj  = 1;
            1: chiaiu_uncorr_err_inj  = 1;
            1: ioaiu_uncorr_err_inj   = 1;
            endcase
        end else if($test$plusargs("exp_bist_timeout_err")) begin
            randcase
            1: dce_uncorr_err_inj  = 1;
            1: chiaiu_uncorr_err_inj  = 1;
            1: ioaiu_uncorr_err_inj   = 1;
            endcase
        end
     end
      `uvm_info("fsys_fault_injector_checker", $psprintf("DCE units=%0d DMI units=%0d DVE units=%0d DII units=%0d IOAIU units=%0d CHIAIU units=%0d",<%=obj.DceInfo.length%>,<%=obj.DmiInfo.length%>,<%=obj.DveInfo.length%>,<%=obj.DiiInfo.length%>,<%=numIoAiu%>,<%=numChiAiu%>),UVM_LOW)
      `uvm_info("fsys_fault_injector_checker", $psprintf("num_dce_signals_for_uncorr_err_inj %0d,num_dmi_signals_for_uncorr_err_inj %0d,num_dve_signals_for_uncorr_err_inj %0d,num_dii_signals_for_uncorr_err_inj %0d,num_ioaiu_signals_for_uncorr_err_inj %0d,num_chi_aiu_signals_for_uncorr_err_inj %0d",num_dce_signals_for_uncorr_err_inj,num_dmi_signals_for_uncorr_err_inj,num_dve_signals_for_uncorr_err_inj,num_dii_signals_for_uncorr_err_inj,num_ioaiu_signals_for_uncorr_err_inj,num_chi_aiu_signals_for_uncorr_err_inj),UVM_LOW)
     uvm_config_db#(int unsigned)::set(null, "", "uncorr_err_inj_test_start_indication", uncorr_err_inj_test_start_indication); 
     uvm_config_db#(int unsigned)::set(null, "", "num_dce_signals_for_uncorr_err_inj", dce_uncorr_err_inj ? (num_dce_signals_for_uncorr_err_inj * <%=obj.DceInfo.length%>) : 0  ); 
     uvm_config_db#(int unsigned)::set(null, "", "num_dmi_signals_for_uncorr_err_inj", dmi_uncorr_err_inj ? (num_dmi_signals_for_uncorr_err_inj * <%=obj.DmiInfo.length%>) : 0  ); 
     uvm_config_db#(int unsigned)::set(null, "", "num_dve_signals_for_uncorr_err_inj", dve_uncorr_err_inj ? (num_dve_signals_for_uncorr_err_inj * <%=obj.DveInfo.length%>) : 0  ); 
     uvm_config_db#(int unsigned)::set(null, "", "num_dii_signals_for_uncorr_err_inj", dii_uncorr_err_inj ? (num_dii_signals_for_uncorr_err_inj * (<%=obj.DiiInfo.length%> - 1)) : 0  ); 
     uvm_config_db#(int unsigned)::set(null, "", "num_ioaiu_signals_for_uncorr_err_inj", ioaiu_uncorr_err_inj ? (num_ioaiu_signals_for_uncorr_err_inj) : 0 ); 
     uvm_config_db#(int unsigned)::set(null, "", "num_chi_aiu_signals_for_uncorr_err_inj", chiaiu_uncorr_err_inj ? (num_chi_aiu_signals_for_uncorr_err_inj * <%=numChiAiu%>) : 0); 
     `uvm_info("fsys_fault_injector_checker",$sformatf("Run-time switch settings : func_unit_uncorr_err_inj %0d dup_unit_uncorr_err_inj %0d",func_unit_uncorr_err_inj,dup_unit_uncorr_err_inj),UVM_LOW)
     `uvm_info("fsys_fault_injector_checker",$sformatf("Run-time switch settings : dce_uncorr_err_inj %0d,dmi_uncorr_err_inj %0d,dve_uncorr_err_inj %0d,dii_uncorr_err_inj %0d,chiaiu_uncorr_err_inj %0d,ioaiu_uncorr_err_inj %0d",dce_uncorr_err_inj,dmi_uncorr_err_inj,dve_uncorr_err_inj,dii_uncorr_err_inj,chiaiu_uncorr_err_inj,ioaiu_uncorr_err_inj),UVM_LOW)
     if ($test$plusargs("inject_uncorrectable_error")) begin
       @(posedge tb_rstn);
       #1000ns; // CONC-14034 - Adding hardcode delay to finish sysco attach messaging to DCEs

       //DCE  
       if(dce_uncorr_err_inj) begin
       <% var hier_path_dce = ''; %>
       <% for (var i = 0; i<obj.DceInfo.length; i++) { %>
         <% if(obj.DceInfo[i].hierPath && obj.DceInfo[i].hierPath !== '') { 
            hier_path_dce = `${hier_path_dut}.${obj.DceInfo[i].hierPath}`;
          } else {
            hier_path_dce = hier_path_dut; 
         }%>
         <% if(obj.DceInfo[0].ResilienceInfo.enableUnitDuplication==1) { %>
         <% for (var idx = 0; idx< dce_outputs_array[0].length; idx++) { %>
           repeat(FSYS_FAULT_INJECTOR_CHECKER_CLK_DELAY_BEFORE_ERR)@(posedge <%=hier_path_dce%>.<%=obj.DceInfo[i].strRtlNamePrefix%>.clk_clk);
           #1ps;
           <% if((i==0) && (idx==0)) { %>
           uncorr_err_inj_test_start_indication = 1;
           uvm_config_db#(int unsigned)::set(null, "", "uncorr_err_inj_test_start_indication", uncorr_err_inj_test_start_indication); 
           <% } %>
           prev_val[0][<%=idx%>] = <%=hier_path_dce%>.<%=obj.DceInfo[i].strRtlNamePrefix%>.<%=dce_outputs_array[0][idx]%>;
           signal_invalid_value_check("<%=hier_path_dce%>.<%=obj.DceInfo[i].strRtlNamePrefix%>.<%=dce_outputs_array[0][idx]%>",<%=hier_path_dce%>.<%=obj.DceInfo[i].strRtlNamePrefix%>.<%=dce_outputs_array[0][idx]%>);
           signal_width = $bits(<%=hier_path_dce%>.<%=obj.DceInfo[i].strRtlNamePrefix%>.<%=dce_outputs_array[0][idx]%>);
           rand_pos_in_signal = $urandom_range(0, signal_width-1);
           if(func_unit_uncorr_err_inj) begin 
               `uvm_info("fsys_fault_injector_checker",$sformatf("Error injection done (FORCE) on signal <%=hier_path_dce%>.<%=obj.DceInfo[i].strRtlNamePrefix%>.<%=dce_outputs_array[0][idx]%> of width=%0d. Random Bit-position=%0d, Orig value='h%0h, Forced value='h%0h",signal_width,rand_pos_in_signal,prev_val[0][<%=idx%>],prev_val[0][<%=idx%>] ^ (1'b1<<rand_pos_in_signal)),UVM_LOW)
               force   <%=hier_path_dce%>.<%=obj.DceInfo[i].strRtlNamePrefix%>.<%=dce_outputs_array[0][idx]%> = prev_val[0][<%=idx%>] ^ (1'b1<<rand_pos_in_signal);
           end
           <% if(obj.DceInfo[i].ResilienceInfo.enableUnitDuplication) {  %>
           if(dup_unit_uncorr_err_inj) begin 
               dup_prev_val[0][<%=idx%>] = <%=hier_path_dce%>.<%=obj.DceInfo[i].strRtlNamePrefix%>.<%=dce_dup_outputs_array[0][idx]%>;
               signal_invalid_value_check("<%=hier_path_dce%>.<%=obj.DceInfo[i].strRtlNamePrefix%>.<%=dce_dup_outputs_array[0][idx]%>",<%=hier_path_dce%>.<%=obj.DceInfo[i].strRtlNamePrefix%>.<%=dce_dup_outputs_array[0][idx]%>);
               `uvm_info("fsys_fault_injector_checker",$sformatf("Error injection done (FORCE) on signal <%=hier_path_dce%>.<%=obj.DceInfo[i].strRtlNamePrefix%>.<%=dce_dup_outputs_array[0][idx]%> of width=%0d. Random Bit-position=%0d, Orig value='h%0h, Forced value='h%0h",signal_width,rand_pos_in_signal,dup_prev_val[0][<%=idx%>],dup_prev_val[0][<%=idx%>] ^ (1'b1<<rand_pos_in_signal)),UVM_LOW)
               force   <%=hier_path_dce%>.<%=obj.DceInfo[i].strRtlNamePrefix%>.<%=dce_dup_outputs_array[0][idx]%> = dup_prev_val[0][<%=idx%>] ^ (1'b1<<rand_pos_in_signal); 
           end
           <% } %>
           @(posedge <%=hier_path_dce%>.<%=obj.DceInfo[i].strRtlNamePrefix%>.clk_clk);
           if(func_unit_uncorr_err_inj) begin 
               release <%=hier_path_dce%>.<%=obj.DceInfo[i].strRtlNamePrefix%>.<%=dce_outputs_array[0][idx]%>;
               `uvm_info("fsys_fault_injector_checker",$sformatf("RELEASING signal <%=hier_path_dce%>.<%=obj.DceInfo[i].strRtlNamePrefix%>.<%=dce_outputs_array[0][idx]%> of width=%0d from Forced value='h%0h (Infected-bit %0d). Back to Orig value='h%0h",signal_width,prev_val[0][<%=idx%>] ^ (1'b1<<rand_pos_in_signal),rand_pos_in_signal,<%=hier_path_dce%>.<%=obj.DceInfo[i].strRtlNamePrefix%>.<%=dce_outputs_array[0][idx]%>),UVM_LOW)
           end
           <% if(obj.DceInfo[i].ResilienceInfo.enableUnitDuplication) {  %>
           if(dup_unit_uncorr_err_inj) begin 
               release <%=hier_path_dce%>.<%=obj.DceInfo[i].strRtlNamePrefix%>.<%=dce_dup_outputs_array[0][idx]%>;
               `uvm_info("fsys_fault_injector_checker",$sformatf("RELEASING signal <%=hier_path_dce%>.<%=obj.DceInfo[i].strRtlNamePrefix%>.<%=dce_dup_outputs_array[0][idx]%> of width=%0d from Forced value='h%0h (Infected-bit %0d). Back to Orig value='h%0h",signal_width,dup_prev_val[0][<%=idx%>] ^ (1'b1<<rand_pos_in_signal),rand_pos_in_signal,<%=hier_path_dce%>.<%=obj.DceInfo[i].strRtlNamePrefix%>.<%=dce_dup_outputs_array[0][idx]%>),UVM_LOW)
           end
           <% } %>
           reset_fsc_reg();
           expFaults(1, <%=obj.DceInfo[i].ResilienceInfo.enableUnitDuplication%>,func_unit_uncorr_err_inj,dup_unit_uncorr_err_inj,expected_mission_fault,expected_latent_fault);
           expected_dce_mission_fault_reg[<%=i%>] = expected_mission_fault;
           expected_dce_latent_fault_reg[<%=i%>] = expected_latent_fault ;
           update_fsc_reg();
           repeat(clk_wait_after_release)@(posedge <%=hier_path_dce%>.<%=obj.DceInfo[i].strRtlNamePrefix%>.clk_clk);
           <% if(obj.DceInfo[i].hierPath && obj.DceInfo[i].hierPath !== '') { %>
               compareFaults($sformatf("Consider other %0s inputs enableUnitDuplication %0d, UCERR at Func unit %0d, UCERR at Checker unit %0d compareFaults function is called from file - fsys_fault_injector_checker line %0d","<%=obj.DceInfo[i].strRtlNamePrefix%>",<%=obj.DceInfo[i].ResilienceInfo.enableUnitDuplication%>,func_unit_uncorr_err_inj,(<%=obj.DceInfo[i].ResilienceInfo.enableUnitDuplication%>==1) ? dup_unit_uncorr_err_inj: 0,`__LINE__),"<%=hier_path_dut%>.<%=obj.FscInfo.strRtlNamePrefix%>.<%=obj.DceInfo[i].hierPath%>.<%=obj.DceInfo[i].strRtlNamePrefix%>",expected_mission_fault,expected_latent_fault,<%=hier_path_dut%>.<%=obj.FscInfo.strRtlNamePrefix%>.fault_<%=obj.DceInfo[i].strRtlNamePrefix%>_mission_fault,<%=hier_path_dut%>.<%=obj.FscInfo.strRtlNamePrefix%>.fault_<%=obj.DceInfo[i].strRtlNamePrefix%>_latent_fault);
           <%}else{%>
               compareFaults($sformatf("Consider other %0s inputs enableUnitDuplication %0d, UCERR at Func unit %0d, UCERR at Checker unit %0d compareFaults function is called from file - fsys_fault_injector_checker line %0d","<%=obj.DceInfo[i].strRtlNamePrefix%>",<%=obj.DceInfo[i].ResilienceInfo.enableUnitDuplication%>,func_unit_uncorr_err_inj,(<%=obj.DceInfo[i].ResilienceInfo.enableUnitDuplication%>==1) ? dup_unit_uncorr_err_inj: 0,`__LINE__),"<%=hier_path_dut%>.<%=obj.FscInfo.strRtlNamePrefix%>.<%=obj.DceInfo[i].strRtlNamePrefix%>",expected_mission_fault,expected_latent_fault,<%=hier_path_dut%>.<%=obj.FscInfo.strRtlNamePrefix%>.fault_<%=obj.DceInfo[i].strRtlNamePrefix%>_mission_fault,<%=hier_path_dut%>.<%=obj.FscInfo.strRtlNamePrefix%>.fault_<%=obj.DceInfo[i].strRtlNamePrefix%>_latent_fault);
           <%}%>
           repeat(clk_wait_after_release+15)@(posedge <%=hier_path_dce%>.<%=obj.DceInfo[i].strRtlNamePrefix%>.clk_clk);
         <% }} %>
     if(bypass_fsys_fault_check_with_uce_signals==0) begin
     // #Stimulus.FSYS.FSC_DCE_unit_error 
     // #Stimulus.FSYS.FSC_DCE_dupunit_error 
         <% for (var idx = 0; idx< dce_uce_array[0].length; idx++) { %>
           repeat(FSYS_FAULT_INJECTOR_CHECKER_CLK_DELAY_BEFORE_ERR)@(posedge <%=hier_path_dce%>.<%=obj.DceInfo[i].strRtlNamePrefix%>.clk_clk);
           <% if((i==0) && (idx==0)) { %>
           uncorr_err_inj_test_start_indication = 1;
           uvm_config_db#(int unsigned)::set(null, "", "uncorr_err_inj_test_start_indication", uncorr_err_inj_test_start_indication); 
           <% } %>
           signal_width = $bits(<%=hier_path_dce%>.<%=obj.DceInfo[i].strRtlNamePrefix%>.<%=dce_uce_array[0][idx]%>);
           rand_pos_in_signal = $urandom_range(0, signal_width-1);
           fork
           begin
           if(func_unit_uncorr_err_inj) begin 
               prev_val[0][<%=idx%>] = <%=hier_path_dce%>.<%=obj.DceInfo[i].strRtlNamePrefix%>.<%=dce_uce_array[0][idx]%>;
               signal_invalid_value_check("<%=hier_path_dce%>.<%=obj.DceInfo[i].strRtlNamePrefix%>.<%=dce_uce_array[0][idx]%>",<%=hier_path_dce%>.<%=obj.DceInfo[i].strRtlNamePrefix%>.<%=dce_uce_array[0][idx]%>);
               `uvm_info("fsys_fault_injector_checker",$sformatf("Error injection done (FORCE) on signal <%=hier_path_dce%>.<%=obj.DceInfo[i].strRtlNamePrefix%>.<%=dce_uce_array[0][idx]%> of width=%0d. Random Bit-position=%0d, Orig value='h%0h, Forced value='h%0h",signal_width,rand_pos_in_signal,prev_val[0][<%=idx%>],1'b1),UVM_LOW)
               force   <%=hier_path_dce%>.<%=obj.DceInfo[i].strRtlNamePrefix%>.<%=dce_uce_array[0][idx]%> = 1'b1; //prev_val[0][<%=idx%>] ^ (1'b1<<rand_pos_in_signal);
               @(posedge <%=hier_path_dce%>.<%=obj.DceInfo[i].strRtlNamePrefix%>.clk_clk);
               release <%=hier_path_dce%>.<%=obj.DceInfo[i].strRtlNamePrefix%>.<%=dce_uce_array[0][idx]%>;
               `uvm_info("fsys_fault_injector_checker",$sformatf("RELEASING signal <%=hier_path_dce%>.<%=obj.DceInfo[i].strRtlNamePrefix%>.<%=dce_uce_array[0][idx]%> of width=%0d from Forced value='h%0h (Infected-bit %0d). Back to Orig value='h%0h",signal_width,prev_val[0][<%=idx%>] ^ (1'b1<<rand_pos_in_signal),rand_pos_in_signal,<%=hier_path_dce%>.<%=obj.DceInfo[i].strRtlNamePrefix%>.<%=dce_uce_array[0][idx]%>),UVM_LOW)
           end
           end
           begin
           <% if(obj.DceInfo[i].ResilienceInfo.enableUnitDuplication) {  %>
           if(dup_unit_uncorr_err_inj) begin 
               dup_prev_val[0][<%=idx%>] = <%=hier_path_dce%>.<%=obj.DceInfo[i].strRtlNamePrefix%>.<%=dce_dup_uce_array[0][idx]%>;
               signal_invalid_value_check("<%=hier_path_dce%>.<%=obj.DceInfo[i].strRtlNamePrefix%>.<%=dce_dup_uce_array[0][idx]%>",<%=hier_path_dce%>.<%=obj.DceInfo[i].strRtlNamePrefix%>.<%=dce_dup_uce_array[0][idx]%>);
               repeat(<%=obj.DceInfo[i].ResilienceInfo.nResiliencyDelay%>) begin
                 @(posedge <%=hier_path_dce%>.<%=obj.DceInfo[i].strRtlNamePrefix%>.clk_clk);
               end
               `uvm_info("fsys_fault_injector_checker",$sformatf("Error injection done (FORCE) on signal <%=hier_path_dce%>.<%=obj.DceInfo[i].strRtlNamePrefix%>.<%=dce_dup_uce_array[0][idx]%> of width=%0d. Random Bit-position=%0d, Orig value='h%0h, Forced value='h%0h",signal_width,rand_pos_in_signal,dup_prev_val[0][<%=idx%>],1'b1),UVM_LOW)
               force   <%=hier_path_dce%>.<%=obj.DceInfo[i].strRtlNamePrefix%>.<%=dce_dup_uce_array[0][idx]%> = 1'b1; //dup_prev_val[0][<%=idx%>] ^ (1'b1<<rand_pos_in_signal); 
               @(posedge <%=hier_path_dce%>.<%=obj.DceInfo[i].strRtlNamePrefix%>.clk_clk);
               release <%=hier_path_dce%>.<%=obj.DceInfo[i].strRtlNamePrefix%>.<%=dce_dup_uce_array[0][idx]%>;
               `uvm_info("fsys_fault_injector_checker",$sformatf("RELEASING signal <%=hier_path_dce%>.<%=obj.DceInfo[i].strRtlNamePrefix%>.<%=dce_dup_uce_array[0][idx]%> of width=%0d from Forced value='h%0h (Infected-bit %0d). Back to Orig value='h%0h",signal_width,dup_prev_val[0][<%=idx%>] ^ (1'b1<<rand_pos_in_signal),rand_pos_in_signal,<%=hier_path_dce%>.<%=obj.DceInfo[i].strRtlNamePrefix%>.<%=dce_dup_uce_array[0][idx]%>),UVM_LOW)
           end
           <% } %>
           end
           join
           reset_fsc_reg();
           expFaults(0, <%=obj.DceInfo[i].ResilienceInfo.enableUnitDuplication%>,func_unit_uncorr_err_inj,dup_unit_uncorr_err_inj,expected_mission_fault,expected_latent_fault);
           expected_dce_mission_fault_reg[<%=i%>] = expected_mission_fault;
           expected_dce_latent_fault_reg[<%=i%>] = expected_latent_fault ;
           update_fsc_reg();
           repeat(clk_wait_after_release)@(posedge <%=hier_path_dce%>.<%=obj.DceInfo[i].strRtlNamePrefix%>.clk_clk);
           <% if(obj.DceInfo[i].hierPath && obj.DceInfo[i].hierPath !== '') { %>
                 compareFaults($sformatf("Consider other %0s inputs enableUnitDuplication %0d, UCERR at Func unit %0d, UCERR at Checker unit %0d compareFaults function is called from file - fsys_fault_injector_checker line %0d","<%=obj.DceInfo[i].strRtlNamePrefix%>",<%=obj.DceInfo[i].ResilienceInfo.enableUnitDuplication%>,func_unit_uncorr_err_inj,(<%=obj.DceInfo[i].ResilienceInfo.enableUnitDuplication%>==1) ? dup_unit_uncorr_err_inj: 0,`__LINE__),"<%=hier_path_dut%>.<%=obj.FscInfo.strRtlNamePrefix%>.<%=obj.DceInfo[i].hierPath%>.<%=obj.DceInfo[i].strRtlNamePrefix%>",expected_mission_fault,expected_latent_fault,<%=hier_path_dut%>.<%=obj.FscInfo.strRtlNamePrefix%>.fault_<%=obj.DceInfo[i].strRtlNamePrefix%>_mission_fault,<%=hier_path_dut%>.<%=obj.FscInfo.strRtlNamePrefix%>.fault_<%=obj.DceInfo[i].strRtlNamePrefix%>_latent_fault);
           <%}else{%>
                 compareFaults($sformatf("Consider other %0s inputs enableUnitDuplication %0d, UCERR at Func unit %0d, UCERR at Checker unit %0d compareFaults function is called from file - fsys_fault_injector_checker line %0d","<%=obj.DceInfo[i].strRtlNamePrefix%>",<%=obj.DceInfo[i].ResilienceInfo.enableUnitDuplication%>,func_unit_uncorr_err_inj,(<%=obj.DceInfo[i].ResilienceInfo.enableUnitDuplication%>==1) ? dup_unit_uncorr_err_inj: 0,`__LINE__),"<%=hier_path_dut%>.<%=obj.FscInfo.strRtlNamePrefix%>.<%=obj.DceInfo[i].strRtlNamePrefix%>",expected_mission_fault,expected_latent_fault,<%=hier_path_dut%>.<%=obj.FscInfo.strRtlNamePrefix%>.fault_<%=obj.DceInfo[i].strRtlNamePrefix%>_mission_fault,<%=hier_path_dut%>.<%=obj.FscInfo.strRtlNamePrefix%>.fault_<%=obj.DceInfo[i].strRtlNamePrefix%>_latent_fault);
           <% } %>
           repeat(clk_wait_after_release+15)@(posedge <%=hier_path_dce%>.<%=obj.DceInfo[i].strRtlNamePrefix%>.clk_clk);
         <% } %>
     end // if(bypass_fsys_fault_check_with_uce_signals==0) begin
       <% } %>
       end // if(dce_uncorr_err_inj) begin

       //DMI  
       if(dmi_uncorr_err_inj) begin
        <% var hier_path_dmi = ''; %>
       <% for (var i = 0; i<obj.DmiInfo.length; i++) { %>
         <% if(obj.DmiInfo[i].hierPath && obj.DmiInfo[i].hierPath !== '') { 
            hier_path_dmi = `${hier_path_dut}.${obj.DmiInfo[i].hierPath}`;
          } else {
            hier_path_dmi = hier_path_dut; 
         }%>
         <% if(obj.DmiInfo[0].ResilienceInfo.enableUnitDuplication==1) { %>
         <% for (var idx = 0; idx< dmi_outputs_array[0].length; idx++) { %>
           repeat(FSYS_FAULT_INJECTOR_CHECKER_CLK_DELAY_BEFORE_ERR)@(posedge <%=hier_path_dmi%>.<%=obj.DmiInfo[i].strRtlNamePrefix%>.clk_clk);
           #1ps;
           <% if((i==0) && (idx==0)) { %>
           uncorr_err_inj_test_start_indication = 1;
           uvm_config_db#(int unsigned)::set(null, "", "uncorr_err_inj_test_start_indication", uncorr_err_inj_test_start_indication); 
           <% } %>
           prev_val[0][<%=idx%>] = <%=hier_path_dmi%>.<%=obj.DmiInfo[i].strRtlNamePrefix%>.<%=dmi_outputs_array[0][idx]%>;
           signal_invalid_value_check("<%=hier_path_dmi%>.<%=obj.DmiInfo[i].strRtlNamePrefix%>.<%=dmi_outputs_array[0][idx]%>",<%=hier_path_dmi%>.<%=obj.DmiInfo[i].strRtlNamePrefix%>.<%=dmi_outputs_array[0][idx]%>);
           signal_width = $bits(<%=hier_path_dmi%>.<%=obj.DmiInfo[i].strRtlNamePrefix%>.<%=dmi_outputs_array[0][idx]%>);
           rand_pos_in_signal = $urandom_range(0, signal_width-1);
           if(func_unit_uncorr_err_inj) begin 
               `uvm_info("fsys_fault_injector_checker",$sformatf("Error injection done (FORCE) on signal <%=hier_path_dmi%>.<%=obj.DmiInfo[i].strRtlNamePrefix%>.<%=dmi_outputs_array[0][idx]%> of width=%0d. Random Bit-position=%0d, Orig value='h%0h, Forced value='h%0h",signal_width,rand_pos_in_signal,prev_val[0][<%=idx%>],prev_val[0][<%=idx%>] ^ (1'b1<<rand_pos_in_signal)),UVM_LOW)
               force   <%=hier_path_dmi%>.<%=obj.DmiInfo[i].strRtlNamePrefix%>.<%=dmi_outputs_array[0][idx]%> = prev_val[0][<%=idx%>] ^ (1'b1<<rand_pos_in_signal);
           end
           <% if(obj.DmiInfo[i].ResilienceInfo.enableUnitDuplication) {  %>
           if(dup_unit_uncorr_err_inj) begin 
               dup_prev_val[0][<%=idx%>] = <%=hier_path_dmi%>.<%=obj.DmiInfo[i].strRtlNamePrefix%>.<%=dmi_dup_outputs_array[0][idx]%>;
               signal_invalid_value_check("<%=hier_path_dmi%>.<%=obj.DmiInfo[i].strRtlNamePrefix%>.<%=dmi_dup_outputs_array[0][idx]%>",<%=hier_path_dmi%>.<%=obj.DmiInfo[i].strRtlNamePrefix%>.<%=dmi_dup_outputs_array[0][idx]%>);
               `uvm_info("fsys_fault_injector_checker",$sformatf("Error injection done (FORCE) on signal <%=hier_path_dmi%>.<%=obj.DmiInfo[i].strRtlNamePrefix%>.<%=dmi_dup_outputs_array[0][idx]%> of width=%0d. Random Bit-position=%0d, Orig value='h%0h, Forced value='h%0h",signal_width,rand_pos_in_signal,dup_prev_val[0][<%=idx%>],dup_prev_val[0][<%=idx%>] ^ (1'b1<<rand_pos_in_signal)),UVM_LOW)
               force   <%=hier_path_dmi%>.<%=obj.DmiInfo[i].strRtlNamePrefix%>.<%=dmi_dup_outputs_array[0][idx]%> = dup_prev_val[0][<%=idx%>] ^ (1'b1<<rand_pos_in_signal);
           end
           <% } %>
           @(posedge <%=hier_path_dmi%>.<%=obj.DmiInfo[i].strRtlNamePrefix%>.clk_clk);
           if(func_unit_uncorr_err_inj) begin 
               release <%=hier_path_dmi%>.<%=obj.DmiInfo[i].strRtlNamePrefix%>.<%=dmi_outputs_array[0][idx]%>;
               `uvm_info("fsys_fault_injector_checker",$sformatf("RELEASING signal <%=hier_path_dmi%>.<%=obj.DmiInfo[i].strRtlNamePrefix%>.<%=dmi_outputs_array[0][idx]%> of width=%0d from Forced value='h%0h (Infected-bit %0d). Back to Orig value='h%0h",signal_width,prev_val[0][<%=idx%>] ^ (1'b1<<rand_pos_in_signal),rand_pos_in_signal,<%=hier_path_dmi%>.<%=obj.DmiInfo[i].strRtlNamePrefix%>.<%=dmi_outputs_array[0][idx]%>),UVM_LOW)
           end
           <% if(obj.DmiInfo[i].ResilienceInfo.enableUnitDuplication) {  %>
           if(dup_unit_uncorr_err_inj) begin 
               release <%=hier_path_dmi%>.<%=obj.DmiInfo[i].strRtlNamePrefix%>.<%=dmi_dup_outputs_array[0][idx]%>;
               `uvm_info("fsys_fault_injector_checker",$sformatf("RELEASING signal <%=hier_path_dmi%>.<%=obj.DmiInfo[i].strRtlNamePrefix%>.<%=dmi_dup_outputs_array[0][idx]%> of width=%0d from Forced value='h%0h (Infected-bit %0d). Back to Orig value='h%0h",signal_width,dup_prev_val[0][<%=idx%>] ^ (1'b1<<rand_pos_in_signal),rand_pos_in_signal,<%=hier_path_dmi%>.<%=obj.DmiInfo[i].strRtlNamePrefix%>.<%=dmi_dup_outputs_array[0][idx]%>),UVM_LOW)
           end
           <% } %>
           reset_fsc_reg();
           expFaults(1, <%=obj.DmiInfo[i].ResilienceInfo.enableUnitDuplication%>,func_unit_uncorr_err_inj,dup_unit_uncorr_err_inj,expected_mission_fault,expected_latent_fault);
           expected_dmi_mission_fault_reg[<%=i%>] = expected_mission_fault;
           expected_dmi_latent_fault_reg[<%=i%>] = expected_latent_fault ;
           update_fsc_reg();
           repeat(clk_wait_after_release)@(posedge <%=hier_path_dmi%>.<%=obj.DmiInfo[i].strRtlNamePrefix%>.clk_clk);
           <% if(obj.DmiInfo[i].hierPath && obj.DmiInfo[i].hierPath !== '') { %>
                compareFaults($sformatf("Consider other %0s inputs enableUnitDuplication %0d, UCERR at Func unit %0d, UCERR at Checker unit %0d  compareFaults function is called from file - fsys_fault_injector_checker line %0d","<%=obj.DmiInfo[i].strRtlNamePrefix%>",<%=obj.DmiInfo[i].ResilienceInfo.enableUnitDuplication%>,func_unit_uncorr_err_inj,(<%=obj.DmiInfo[i].ResilienceInfo.enableUnitDuplication%>==1) ? dup_unit_uncorr_err_inj: 0,`__LINE__),"<%=hier_path_dut%>.<%=obj.FscInfo.strRtlNamePrefix%>.<%=obj.DmiInfo[i].hierPath%>.<%=obj.DmiInfo[i].strRtlNamePrefix%>",expected_mission_fault,expected_latent_fault,<%=hier_path_dut%>.<%=obj.FscInfo.strRtlNamePrefix%>.fault_<%=obj.DmiInfo[i].strRtlNamePrefix%>_mission_fault,<%=hier_path_dut%>.<%=obj.FscInfo.strRtlNamePrefix%>.fault_<%=obj.DmiInfo[i].strRtlNamePrefix%>_latent_fault);
           <%}else{%>
                compareFaults($sformatf("Consider other %0s inputs enableUnitDuplication %0d, UCERR at Func unit %0d, UCERR at Checker unit %0d  compareFaults function is called from file - fsys_fault_injector_checker line %0d","<%=obj.DmiInfo[i].strRtlNamePrefix%>",<%=obj.DmiInfo[i].ResilienceInfo.enableUnitDuplication%>,func_unit_uncorr_err_inj,(<%=obj.DmiInfo[i].ResilienceInfo.enableUnitDuplication%>==1) ? dup_unit_uncorr_err_inj: 0,`__LINE__),"<%=hier_path_dut%>.<%=obj.FscInfo.strRtlNamePrefix%>.<%=obj.DmiInfo[i].strRtlNamePrefix%>",expected_mission_fault,expected_latent_fault,<%=hier_path_dut%>.<%=obj.FscInfo.strRtlNamePrefix%>.fault_<%=obj.DmiInfo[i].strRtlNamePrefix%>_mission_fault,<%=hier_path_dut%>.<%=obj.FscInfo.strRtlNamePrefix%>.fault_<%=obj.DmiInfo[i].strRtlNamePrefix%>_latent_fault);
           <% } %>
           repeat(clk_wait_after_release+15)@(posedge <%=hier_path_dmi%>.<%=obj.DmiInfo[i].strRtlNamePrefix%>.clk_clk);
         <% }} %>
     if(bypass_fsys_fault_check_with_uce_signals==0) begin
     // #Stimulus.FSYS.FSC_DMI_unit_error 
     // #Stimulus.FSYS.FSC_DMI_dupunit_error 
         <% for (var idx = 0; idx< dmi_uce_array[0].length; idx++) { %>
           repeat(FSYS_FAULT_INJECTOR_CHECKER_CLK_DELAY_BEFORE_ERR)@(posedge <%=hier_path_dmi%>.<%=obj.DmiInfo[i].strRtlNamePrefix%>.clk_clk);
           <% if((i==0) && (idx==0)) { %>
           uncorr_err_inj_test_start_indication = 1;
           uvm_config_db#(int unsigned)::set(null, "", "uncorr_err_inj_test_start_indication", uncorr_err_inj_test_start_indication); 
           <% } %>
           signal_width = $bits(<%=hier_path_dmi%>.<%=obj.DmiInfo[i].strRtlNamePrefix%>.<%=dmi_uce_array[0][idx]%>);
           rand_pos_in_signal = $urandom_range(0, signal_width-1);
           fork
           begin
           if(func_unit_uncorr_err_inj) begin 
               prev_val[0][<%=idx%>] = <%=hier_path_dmi%>.<%=obj.DmiInfo[i].strRtlNamePrefix%>.<%=dmi_uce_array[0][idx]%>;
               signal_invalid_value_check("<%=hier_path_dmi%>.<%=obj.DmiInfo[i].strRtlNamePrefix%>.<%=dmi_uce_array[0][idx]%>",<%=hier_path_dmi%>.<%=obj.DmiInfo[i].strRtlNamePrefix%>.<%=dmi_uce_array[0][idx]%>);
               `uvm_info("fsys_fault_injector_checker",$sformatf("Error injection done (FORCE) on signal <%=hier_path_dmi%>.<%=obj.DmiInfo[i].strRtlNamePrefix%>.<%=dmi_uce_array[0][idx]%> of width=%0d. Random Bit-position=%0d, Orig value='h%0h, Forced value='h%0h",signal_width,rand_pos_in_signal,prev_val[0][<%=idx%>],1'b1),UVM_LOW)
               force   <%=hier_path_dmi%>.<%=obj.DmiInfo[i].strRtlNamePrefix%>.<%=dmi_uce_array[0][idx]%> =  1'b1; //prev_val[0][<%=idx%>] ^ (1'b1<<rand_pos_in_signal);
               @(posedge <%=hier_path_dmi%>.<%=obj.DmiInfo[i].strRtlNamePrefix%>.clk_clk);
               release <%=hier_path_dmi%>.<%=obj.DmiInfo[i].strRtlNamePrefix%>.<%=dmi_uce_array[0][idx]%>;
               `uvm_info("fsys_fault_injector_checker",$sformatf("RELEASING signal <%=hier_path_dmi%>.<%=obj.DmiInfo[i].strRtlNamePrefix%>.<%=dmi_uce_array[0][idx]%> of width=%0d from Forced value='h%0h (Infected-bit %0d). Back to Orig value='h%0h",signal_width,prev_val[0][<%=idx%>] ^ (1'b1<<rand_pos_in_signal),rand_pos_in_signal,<%=hier_path_dmi%>.<%=obj.DmiInfo[i].strRtlNamePrefix%>.<%=dmi_uce_array[0][idx]%>),UVM_LOW)
           end
           end
           begin
           <% if(obj.DmiInfo[i].ResilienceInfo.enableUnitDuplication) {  %>
           if(dup_unit_uncorr_err_inj) begin 
               dup_prev_val[0][<%=idx%>] = <%=hier_path_dmi%>.<%=obj.DmiInfo[i].strRtlNamePrefix%>.<%=dmi_dup_uce_array[0][idx]%>;
               signal_invalid_value_check("<%=hier_path_dmi%>.<%=obj.DmiInfo[i].strRtlNamePrefix%>.<%=dmi_dup_uce_array[0][idx]%>",<%=hier_path_dmi%>.<%=obj.DmiInfo[i].strRtlNamePrefix%>.<%=dmi_dup_uce_array[0][idx]%>);
               repeat(<%=obj.DmiInfo[i].ResilienceInfo.nResiliencyDelay%>) begin
                 @(posedge <%=hier_path_dmi%>.<%=obj.DmiInfo[i].strRtlNamePrefix%>.clk_clk);
               end
               `uvm_info("fsys_fault_injector_checker",$sformatf("Error injection done (FORCE) on signal <%=hier_path_dmi%>.<%=obj.DmiInfo[i].strRtlNamePrefix%>.<%=dmi_dup_uce_array[0][idx]%> of width=%0d. Random Bit-position=%0d, Orig value='h%0h, Forced value='h%0h",signal_width,rand_pos_in_signal,dup_prev_val[0][<%=idx%>],1'b1),UVM_LOW)
               force   <%=hier_path_dmi%>.<%=obj.DmiInfo[i].strRtlNamePrefix%>.<%=dmi_dup_uce_array[0][idx]%> = 1'b1; //dup_prev_val[0][<%=idx%>] ^ (1'b1<<rand_pos_in_signal);
               @(posedge <%=hier_path_dmi%>.<%=obj.DmiInfo[i].strRtlNamePrefix%>.clk_clk);
               release <%=hier_path_dmi%>.<%=obj.DmiInfo[i].strRtlNamePrefix%>.<%=dmi_dup_uce_array[0][idx]%>;
               `uvm_info("fsys_fault_injector_checker",$sformatf("RELEASING signal <%=hier_path_dmi%>.<%=obj.DmiInfo[i].strRtlNamePrefix%>.<%=dmi_dup_uce_array[0][idx]%> of width=%0d from Forced value='h%0h (Infected-bit %0d). Back to Orig value='h%0h",signal_width,dup_prev_val[0][<%=idx%>] ^ (1'b1<<rand_pos_in_signal),rand_pos_in_signal,<%=hier_path_dmi%>.<%=obj.DmiInfo[i].strRtlNamePrefix%>.<%=dmi_dup_uce_array[0][idx]%>),UVM_LOW)
           end
           <% } %>
           end
           join
           reset_fsc_reg();
           expFaults(0, <%=obj.DmiInfo[i].ResilienceInfo.enableUnitDuplication%>,func_unit_uncorr_err_inj,dup_unit_uncorr_err_inj,expected_mission_fault,expected_latent_fault);
           expected_dmi_mission_fault_reg[<%=i%>] = expected_mission_fault;
           expected_dmi_latent_fault_reg[<%=i%>] = expected_latent_fault ;
           update_fsc_reg();
           repeat(clk_wait_after_release)@(posedge <%=hier_path_dmi%>.<%=obj.DmiInfo[i].strRtlNamePrefix%>.clk_clk);
           <% if(obj.DmiInfo[i].hierPath && obj.DmiInfo[i].hierPath !== '') { %>
                compareFaults($sformatf("Consider other %0s inputs enableUnitDuplication %0d, UCERR at Func unit %0d, UCERR at Checker unit %0d  compareFaults function is called from file - fsys_fault_injector_checker line %0d","<%=obj.DmiInfo[i].strRtlNamePrefix%>",<%=obj.DmiInfo[i].ResilienceInfo.enableUnitDuplication%>,func_unit_uncorr_err_inj,(<%=obj.DmiInfo[i].ResilienceInfo.enableUnitDuplication%>==1) ? dup_unit_uncorr_err_inj: 0,`__LINE__),"<%=hier_path_dut%>.<%=obj.FscInfo.strRtlNamePrefix%>.<%=obj.DmiInfo[i].hierPath%>.<%=obj.DmiInfo[i].strRtlNamePrefix%>",expected_mission_fault,expected_latent_fault,<%=hier_path_dut%>.<%=obj.FscInfo.strRtlNamePrefix%>.fault_<%=obj.DmiInfo[i].strRtlNamePrefix%>_mission_fault,<%=hier_path_dut%>.<%=obj.FscInfo.strRtlNamePrefix%>.fault_<%=obj.DmiInfo[i].strRtlNamePrefix%>_latent_fault);
           <%} else {%>
                compareFaults($sformatf("Consider other %0s inputs enableUnitDuplication %0d, UCERR at Func unit %0d, UCERR at Checker unit %0d  compareFaults function is called from file - fsys_fault_injector_checker line %0d","<%=obj.DmiInfo[i].strRtlNamePrefix%>",<%=obj.DmiInfo[i].ResilienceInfo.enableUnitDuplication%>,func_unit_uncorr_err_inj,(<%=obj.DmiInfo[i].ResilienceInfo.enableUnitDuplication%>==1) ? dup_unit_uncorr_err_inj: 0,`__LINE__),"<%=hier_path_dut%>.<%=obj.FscInfo.strRtlNamePrefix%>.<%=obj.DmiInfo[i].strRtlNamePrefix%>",expected_mission_fault,expected_latent_fault,<%=hier_path_dut%>.<%=obj.FscInfo.strRtlNamePrefix%>.fault_<%=obj.DmiInfo[i].strRtlNamePrefix%>_mission_fault,<%=hier_path_dut%>.<%=obj.FscInfo.strRtlNamePrefix%>.fault_<%=obj.DmiInfo[i].strRtlNamePrefix%>_latent_fault);
           <% } %>
           repeat(clk_wait_after_release+15)@(posedge <%=hier_path_dmi%>.<%=obj.DmiInfo[i].strRtlNamePrefix%>.clk_clk);
         <% } %>
     end // if(bypass_fsys_fault_check_with_uce_signals==0) begin
       <% } %>
       end // if(dmi_uncorr_err_inj) begin

       //DVE  
       if(dve_uncorr_err_inj) begin
       <% for (var i = 0; i<obj.DveInfo.length; i++) { %>
         <% if(obj.DveInfo[0].ResilienceInfo.enableUnitDuplication==1) { %>
         <% for (var idx = 0; idx< dve_outputs_array[0].length; idx++) { %>
           repeat(FSYS_FAULT_INJECTOR_CHECKER_CLK_DELAY_BEFORE_ERR)@(posedge <%=hier_path_dut%>.<%=obj.DveInfo[i].strRtlNamePrefix%>.clk_clk);
           #1ps;
           <% if((i==0) && (idx==0)) { %>
           uncorr_err_inj_test_start_indication = 1;
           uvm_config_db#(int unsigned)::set(null, "", "uncorr_err_inj_test_start_indication", uncorr_err_inj_test_start_indication); 
           <% } %>
           prev_val[0][<%=idx%>] = <%=hier_path_dut%>.<%=obj.DveInfo[i].strRtlNamePrefix%>.<%=dve_outputs_array[0][idx]%>;
           signal_invalid_value_check("<%=hier_path_dut%>.<%=obj.DveInfo[i].strRtlNamePrefix%>.<%=dve_outputs_array[0][idx]%>",<%=hier_path_dut%>.<%=obj.DveInfo[i].strRtlNamePrefix%>.<%=dve_outputs_array[0][idx]%>);
           signal_width = $bits(<%=hier_path_dut%>.<%=obj.DveInfo[i].strRtlNamePrefix%>.<%=dve_outputs_array[0][idx]%>);
           rand_pos_in_signal = $urandom_range(0, signal_width-1);
           if(func_unit_uncorr_err_inj) begin 
               `uvm_info("fsys_fault_injector_checker",$sformatf("Error injection done (FORCE) on signal <%=hier_path_dut%>.<%=obj.DveInfo[i].strRtlNamePrefix%>.<%=dve_outputs_array[0][idx]%> of width=%0d. Random Bit-position=%0d, Orig value='h%0h, Forced value='h%0h",signal_width,rand_pos_in_signal,prev_val[0][<%=idx%>],prev_val[0][<%=idx%>] ^ (1'b1<<rand_pos_in_signal)),UVM_LOW)
               force   <%=hier_path_dut%>.<%=obj.DveInfo[i].strRtlNamePrefix%>.<%=dve_outputs_array[0][idx]%> = prev_val[0][<%=idx%>] ^ (1'b1<<rand_pos_in_signal);
           end
           <% if(obj.DveInfo[i].ResilienceInfo.enableUnitDuplication) {  %>
           if(dup_unit_uncorr_err_inj) begin 
               dup_prev_val[0][<%=idx%>] = <%=hier_path_dut%>.<%=obj.DveInfo[i].strRtlNamePrefix%>.<%=dve_dup_outputs_array[0][idx]%>;
               signal_invalid_value_check("<%=hier_path_dut%>.<%=obj.DveInfo[i].strRtlNamePrefix%>.<%=dve_dup_outputs_array[0][idx]%>",<%=hier_path_dut%>.<%=obj.DveInfo[i].strRtlNamePrefix%>.<%=dve_dup_outputs_array[0][idx]%>);
               `uvm_info("fsys_fault_injector_checker",$sformatf("Error injection done (FORCE) on signal <%=hier_path_dut%>.<%=obj.DveInfo[i].strRtlNamePrefix%>.<%=dve_dup_outputs_array[0][idx]%> of width=%0d. Random Bit-position=%0d, Orig value='h%0h, Forced value='h%0h",signal_width,rand_pos_in_signal,dup_prev_val[0][<%=idx%>],dup_prev_val[0][<%=idx%>] ^ (1'b1<<rand_pos_in_signal)),UVM_LOW)
               force   <%=hier_path_dut%>.<%=obj.DveInfo[i].strRtlNamePrefix%>.<%=dve_dup_outputs_array[0][idx]%> = dup_prev_val[0][<%=idx%>] ^ (1'b1<<rand_pos_in_signal);
           end
           <% } %>
           @(posedge <%=hier_path_dut%>.<%=obj.DveInfo[i].strRtlNamePrefix%>.clk_clk);
           if(func_unit_uncorr_err_inj) begin 
               release <%=hier_path_dut%>.<%=obj.DveInfo[i].strRtlNamePrefix%>.<%=dve_outputs_array[0][idx]%>;
               `uvm_info("fsys_fault_injector_checker",$sformatf("RELEASING signal <%=hier_path_dut%>.<%=obj.DveInfo[i].strRtlNamePrefix%>.<%=dve_outputs_array[0][idx]%> of width=%0d from Forced value='h%0h (Infected-bit %0d). Back to Orig value='h%0h",signal_width,prev_val[0][<%=idx%>] ^ (1'b1<<rand_pos_in_signal),rand_pos_in_signal,<%=hier_path_dut%>.<%=obj.DveInfo[i].strRtlNamePrefix%>.<%=dve_outputs_array[0][idx]%>),UVM_LOW)
           end
           <% if(obj.DveInfo[i].ResilienceInfo.enableUnitDuplication) {  %>
           if(dup_unit_uncorr_err_inj) begin 
               release <%=hier_path_dut%>.<%=obj.DveInfo[i].strRtlNamePrefix%>.<%=dve_dup_outputs_array[0][idx]%>;
               `uvm_info("fsys_fault_injector_checker",$sformatf("RELEASING signal <%=hier_path_dut%>.<%=obj.DveInfo[i].strRtlNamePrefix%>.<%=dve_dup_outputs_array[0][idx]%> of width=%0d from Forced value='h%0h (Infected-bit %0d). Back to Orig value='h%0h",signal_width,dup_prev_val[0][<%=idx%>] ^ (1'b1<<rand_pos_in_signal),rand_pos_in_signal,<%=hier_path_dut%>.<%=obj.DveInfo[i].strRtlNamePrefix%>.<%=dve_dup_outputs_array[0][idx]%>),UVM_LOW)
           end
           <% } %>
           reset_fsc_reg();
           expFaults(1, <%=obj.DveInfo[i].ResilienceInfo.enableUnitDuplication%>,func_unit_uncorr_err_inj,dup_unit_uncorr_err_inj,expected_mission_fault,expected_latent_fault);
           expected_dve_mission_fault_reg[<%=i%>] = expected_mission_fault;
           expected_dve_latent_fault_reg[<%=i%>] = expected_latent_fault ;
           update_fsc_reg();
           repeat(clk_wait_after_release)@(posedge <%=hier_path_dut%>.<%=obj.DveInfo[i].strRtlNamePrefix%>.clk_clk);
           compareFaults($sformatf("Consider other %0s inputs enableUnitDuplication %0d, UCERR at Func unit %0d, UCERR at Checker unit %0d  compareFaults function is called from file - fsys_fault_injector_checker line %0d","<%=obj.DveInfo[i].strRtlNamePrefix%>",<%=obj.DveInfo[i].ResilienceInfo.enableUnitDuplication%>,func_unit_uncorr_err_inj,(<%=obj.DveInfo[i].ResilienceInfo.enableUnitDuplication%>==1) ? dup_unit_uncorr_err_inj: 0,`__LINE__),"<%=hier_path_dut%>.<%=obj.FscInfo.strRtlNamePrefix%>.<%=obj.DveInfo[i].strRtlNamePrefix%>",expected_mission_fault,expected_latent_fault,<%=hier_path_dut%>.<%=obj.FscInfo.strRtlNamePrefix%>.fault_<%=obj.DveInfo[i].strRtlNamePrefix%>_mission_fault,<%=hier_path_dut%>.<%=obj.FscInfo.strRtlNamePrefix%>.fault_<%=obj.DveInfo[i].strRtlNamePrefix%>_latent_fault);
           repeat(clk_wait_after_release+15)@(posedge <%=hier_path_dut%>.<%=obj.DveInfo[i].strRtlNamePrefix%>.clk_clk);
         <% }} %>
     if(bypass_fsys_fault_check_with_uce_signals==0) begin
     // #Stimulus.FSYS.FSC_DVE_unit_error 
     // #Stimulus.FSYS.FSC_DVE_dupunit_error 
         <% for (var idx = 0; idx< dve_uce_array[0].length; idx++) { %>
           repeat(FSYS_FAULT_INJECTOR_CHECKER_CLK_DELAY_BEFORE_ERR)@(posedge <%=hier_path_dut%>.<%=obj.DveInfo[i].strRtlNamePrefix%>.clk_clk);
           <% if((i==0) && (idx==0)) { %>
           uncorr_err_inj_test_start_indication = 1;
           uvm_config_db#(int unsigned)::set(null, "", "uncorr_err_inj_test_start_indication", uncorr_err_inj_test_start_indication); 
           <% } %>
           signal_width = $bits(<%=hier_path_dut%>.<%=obj.DveInfo[i].strRtlNamePrefix%>.<%=dve_uce_array[0][idx]%>);
           rand_pos_in_signal = $urandom_range(0, signal_width-1);
           fork
           begin
           if(func_unit_uncorr_err_inj) begin 
                prev_val[0][<%=idx%>] = <%=hier_path_dut%>.<%=obj.DveInfo[i].strRtlNamePrefix%>.<%=dve_uce_array[0][idx]%>;
                signal_invalid_value_check("<%=hier_path_dut%>.<%=obj.DveInfo[i].strRtlNamePrefix%>.<%=dve_uce_array[0][idx]%>",<%=hier_path_dut%>.<%=obj.DveInfo[i].strRtlNamePrefix%>.<%=dve_uce_array[0][idx]%>);
               `uvm_info("fsys_fault_injector_checker",$sformatf("Error injection done (FORCE) on signal <%=hier_path_dut%>.<%=obj.DveInfo[i].strRtlNamePrefix%>.<%=dve_uce_array[0][idx]%> of width=%0d. Random Bit-position=%0d, Orig value='h%0h, Forced value='h%0h",signal_width,rand_pos_in_signal,prev_val[0][<%=idx%>],1'b1),UVM_LOW)
               force   <%=hier_path_dut%>.<%=obj.DveInfo[i].strRtlNamePrefix%>.<%=dve_uce_array[0][idx]%> =  1'b1; //prev_val[0][<%=idx%>] ^ (1'b1<<rand_pos_in_signal);
               @(posedge <%=hier_path_dut%>.<%=obj.DveInfo[i].strRtlNamePrefix%>.clk_clk);
               release <%=hier_path_dut%>.<%=obj.DveInfo[i].strRtlNamePrefix%>.<%=dve_uce_array[0][idx]%>;
               `uvm_info("fsys_fault_injector_checker",$sformatf("RELEASING signal <%=hier_path_dut%>.<%=obj.DveInfo[i].strRtlNamePrefix%>.<%=dve_uce_array[0][idx]%> of width=%0d from Forced value='h%0h (Infected-bit %0d). Back to Orig value='h%0h",signal_width,prev_val[0][<%=idx%>] ^ (1'b1<<rand_pos_in_signal),rand_pos_in_signal,<%=hier_path_dut%>.<%=obj.DveInfo[i].strRtlNamePrefix%>.<%=dve_uce_array[0][idx]%>),UVM_LOW)
           end
           end
           begin
           <% if(obj.DveInfo[i].ResilienceInfo.enableUnitDuplication) {  %>
           if(dup_unit_uncorr_err_inj) begin 
               dup_prev_val[0][<%=idx%>] = <%=hier_path_dut%>.<%=obj.DveInfo[i].strRtlNamePrefix%>.<%=dve_dup_uce_array[0][idx]%>;
               signal_invalid_value_check("<%=hier_path_dut%>.<%=obj.DveInfo[i].strRtlNamePrefix%>.<%=dve_dup_uce_array[0][idx]%>",<%=hier_path_dut%>.<%=obj.DveInfo[i].strRtlNamePrefix%>.<%=dve_dup_uce_array[0][idx]%>);
               repeat(<%=obj.DveInfo[i].ResilienceInfo.nResiliencyDelay%>) begin
                 @(posedge <%=hier_path_dut%>.<%=obj.DveInfo[i].strRtlNamePrefix%>.clk_clk);
               end
               `uvm_info("fsys_fault_injector_checker",$sformatf("Error injection done (FORCE) on signal <%=hier_path_dut%>.<%=obj.DveInfo[i].strRtlNamePrefix%>.<%=dve_dup_uce_array[0][idx]%> of width=%0d. Random Bit-position=%0d, Orig value='h%0h, Forced value='h%0h",signal_width,rand_pos_in_signal,dup_prev_val[0][<%=idx%>],1'b1),UVM_LOW)
               force   <%=hier_path_dut%>.<%=obj.DveInfo[i].strRtlNamePrefix%>.<%=dve_dup_uce_array[0][idx]%> = 1'b1; //dup_prev_val[0][<%=idx%>] ^ (1'b1<<rand_pos_in_signal);
               @(posedge <%=hier_path_dut%>.<%=obj.DveInfo[i].strRtlNamePrefix%>.clk_clk);
               release <%=hier_path_dut%>.<%=obj.DveInfo[i].strRtlNamePrefix%>.<%=dve_dup_uce_array[0][idx]%>;
               `uvm_info("fsys_fault_injector_checker",$sformatf("RELEASING signal <%=hier_path_dut%>.<%=obj.DveInfo[i].strRtlNamePrefix%>.<%=dve_dup_uce_array[0][idx]%> of width=%0d from Forced value='h%0h (Infected-bit %0d). Back to Orig value='h%0h",signal_width,dup_prev_val[0][<%=idx%>] ^ (1'b1<<rand_pos_in_signal),rand_pos_in_signal,<%=hier_path_dut%>.<%=obj.DveInfo[i].strRtlNamePrefix%>.<%=dve_dup_uce_array[0][idx]%>),UVM_LOW)
           end
           <% } %>
           end
           join
           reset_fsc_reg();
           expFaults(0, <%=obj.DveInfo[i].ResilienceInfo.enableUnitDuplication%>,func_unit_uncorr_err_inj,dup_unit_uncorr_err_inj,expected_mission_fault,expected_latent_fault);
           expected_dve_mission_fault_reg[<%=i%>] = expected_mission_fault;
           expected_dve_latent_fault_reg[<%=i%>] = expected_latent_fault ;
           update_fsc_reg();
           repeat(clk_wait_after_release)@(posedge <%=hier_path_dut%>.<%=obj.DveInfo[i].strRtlNamePrefix%>.clk_clk);
           compareFaults($sformatf("Consider other %0s inputs enableUnitDuplication %0d, UCERR at Func unit %0d, UCERR at Checker unit %0d  compareFaults function is called from file - fsys_fault_injector_checker line %0d","<%=obj.DveInfo[i].strRtlNamePrefix%>",<%=obj.DveInfo[i].ResilienceInfo.enableUnitDuplication%>,func_unit_uncorr_err_inj,(<%=obj.DveInfo[i].ResilienceInfo.enableUnitDuplication%>==1) ? dup_unit_uncorr_err_inj: 0,`__LINE__),"<%=hier_path_dut%>.<%=obj.FscInfo.strRtlNamePrefix%>.<%=obj.DveInfo[i].strRtlNamePrefix%>",expected_mission_fault,expected_latent_fault,<%=hier_path_dut%>.<%=obj.FscInfo.strRtlNamePrefix%>.fault_<%=obj.DveInfo[i].strRtlNamePrefix%>_mission_fault,<%=hier_path_dut%>.<%=obj.FscInfo.strRtlNamePrefix%>.fault_<%=obj.DveInfo[i].strRtlNamePrefix%>_latent_fault);
           repeat(clk_wait_after_release+15)@(posedge <%=hier_path_dut%>.<%=obj.DveInfo[i].strRtlNamePrefix%>.clk_clk);
         <% } %>
     end // if(bypass_fsys_fault_check_with_uce_signals==0) begin
       <% } %>
       end // if(dve_uncorr_err_inj) begin



       //DII  
       if(dii_uncorr_err_inj) begin
       <% for (var i = 0; i<(obj.DiiInfo.length - 1); i++) { %>   //taking 1 less dii, since last one is sys_dii
         <% if(obj.DiiInfo[0].ResilienceInfo.enableUnitDuplication==1) { %>
         <% for (var idx = 0; idx< dii_outputs_array[0].length; idx++) { %>
           repeat(FSYS_FAULT_INJECTOR_CHECKER_CLK_DELAY_BEFORE_ERR)@(posedge <%=hier_path_dut%>.<%=obj.DiiInfo[i].strRtlNamePrefix%>.clk_clk);
           #1ps;
           <% if((i==0) && (idx==0)) { %>
           uncorr_err_inj_test_start_indication = 1;
           uvm_config_db#(int unsigned)::set(null, "", "uncorr_err_inj_test_start_indication", uncorr_err_inj_test_start_indication); 
           <% } %>
           prev_val[0][<%=idx%>] = <%=hier_path_dut%>.<%=obj.DiiInfo[i].strRtlNamePrefix%>.<%=dii_outputs_array[0][idx]%>;
           signal_invalid_value_check("<%=hier_path_dut%>.<%=obj.DiiInfo[i].strRtlNamePrefix%>.<%=dii_outputs_array[0][idx]%>",<%=hier_path_dut%>.<%=obj.DiiInfo[i].strRtlNamePrefix%>.<%=dii_outputs_array[0][idx]%>);
           signal_width = $bits(<%=hier_path_dut%>.<%=obj.DiiInfo[i].strRtlNamePrefix%>.<%=dii_outputs_array[0][idx]%>);
           rand_pos_in_signal = $urandom_range(0, signal_width-1);
           if(func_unit_uncorr_err_inj) begin 
               `uvm_info("fsys_fault_injector_checker",$sformatf("Error injection done (FORCE) on signal <%=hier_path_dut%>.<%=obj.DiiInfo[i].strRtlNamePrefix%>.<%=dii_outputs_array[0][idx]%> of width=%0d. Random Bit-position=%0d, Orig value='h%0h, Forced value='h%0h",signal_width,rand_pos_in_signal,prev_val[0][<%=idx%>],prev_val[0][<%=idx%>] ^ (1'b1<<rand_pos_in_signal)),UVM_LOW)
               force   <%=hier_path_dut%>.<%=obj.DiiInfo[i].strRtlNamePrefix%>.<%=dii_outputs_array[0][idx]%> = prev_val[0][<%=idx%>] ^ (1'b1<<rand_pos_in_signal);
           end
           <% if(obj.DiiInfo[i].ResilienceInfo.enableUnitDuplication) {  %>
           if(dup_unit_uncorr_err_inj) begin 
               dup_prev_val[0][<%=idx%>] = <%=hier_path_dut%>.<%=obj.DiiInfo[i].strRtlNamePrefix%>.<%=dii_dup_outputs_array[0][idx]%>;
               signal_invalid_value_check("<%=hier_path_dut%>.<%=obj.DiiInfo[i].strRtlNamePrefix%>.<%=dii_dup_outputs_array[0][idx]%>",<%=hier_path_dut%>.<%=obj.DiiInfo[i].strRtlNamePrefix%>.<%=dii_dup_outputs_array[0][idx]%>);
               `uvm_info("fsys_fault_injector_checker",$sformatf("Error injection done (FORCE) on signal <%=hier_path_dut%>.<%=obj.DiiInfo[i].strRtlNamePrefix%>.<%=dii_dup_outputs_array[0][idx]%> of width=%0d. Random Bit-position=%0d, Orig value='h%0h, Forced value='h%0h",signal_width,rand_pos_in_signal,dup_prev_val[0][<%=idx%>],dup_prev_val[0][<%=idx%>] ^ (1'b1<<rand_pos_in_signal)),UVM_LOW)
               force   <%=hier_path_dut%>.<%=obj.DiiInfo[i].strRtlNamePrefix%>.<%=dii_dup_outputs_array[0][idx]%> = dup_prev_val[0][<%=idx%>] ^ (1'b1<<rand_pos_in_signal);
           end
           <% } %>
           @(posedge <%=hier_path_dut%>.<%=obj.DiiInfo[i].strRtlNamePrefix%>.clk_clk);
           if(func_unit_uncorr_err_inj) begin 
               release <%=hier_path_dut%>.<%=obj.DiiInfo[i].strRtlNamePrefix%>.<%=dii_outputs_array[0][idx]%>;
               `uvm_info("fsys_fault_injector_checker",$sformatf("RELEASING signal <%=hier_path_dut%>.<%=obj.DiiInfo[i].strRtlNamePrefix%>.<%=dii_outputs_array[0][idx]%> of width=%0d from Forced value='h%0h (Infected-bit %0d). Back to Orig value='h%0h",signal_width,prev_val[0][<%=idx%>] ^ (1'b1<<rand_pos_in_signal),rand_pos_in_signal,<%=hier_path_dut%>.<%=obj.DiiInfo[i].strRtlNamePrefix%>.<%=dii_outputs_array[0][idx]%>),UVM_LOW)
           end
           <% if(obj.DiiInfo[i].ResilienceInfo.enableUnitDuplication) {  %>
           if(dup_unit_uncorr_err_inj) begin 
               release <%=hier_path_dut%>.<%=obj.DiiInfo[i].strRtlNamePrefix%>.<%=dii_dup_outputs_array[0][idx]%>;
               `uvm_info("fsys_fault_injector_checker",$sformatf("RELEASING signal <%=hier_path_dut%>.<%=obj.DiiInfo[i].strRtlNamePrefix%>.<%=dii_dup_outputs_array[0][idx]%> of width=%0d from Forced value='h%0h (Infected-bit %0d). Back to Orig value='h%0h",signal_width,dup_prev_val[0][<%=idx%>] ^ (1'b1<<rand_pos_in_signal),rand_pos_in_signal,<%=hier_path_dut%>.<%=obj.DiiInfo[i].strRtlNamePrefix%>.<%=dii_dup_outputs_array[0][idx]%>),UVM_LOW)
           end
           <% } %>
           reset_fsc_reg();
           expFaults(1, <%=obj.DiiInfo[i].ResilienceInfo.enableUnitDuplication%>,func_unit_uncorr_err_inj,dup_unit_uncorr_err_inj,expected_mission_fault,expected_latent_fault);
           expected_dii_mission_fault_reg[<%=i%>] = expected_mission_fault;
           expected_dii_latent_fault_reg[<%=i%>] = expected_latent_fault ;
           update_fsc_reg();
           repeat(clk_wait_after_release)@(posedge <%=hier_path_dut%>.<%=obj.DiiInfo[i].strRtlNamePrefix%>.clk_clk);
           compareFaults($sformatf("Consider other %0s inputs enableUnitDuplication %0d, UCERR at Func unit %0d, UCERR at Checker unit %0d  compareFaults function is called from file - fsys_fault_injector_checker line %0d","<%=obj.DiiInfo[i].strRtlNamePrefix%>",<%=obj.DiiInfo[i].ResilienceInfo.enableUnitDuplication%>,func_unit_uncorr_err_inj,(<%=obj.DiiInfo[i].ResilienceInfo.enableUnitDuplication%>==1) ? dup_unit_uncorr_err_inj: 0,`__LINE__),"<%=hier_path_dut%>.<%=obj.FscInfo.strRtlNamePrefix%>.<%=obj.DiiInfo[i].strRtlNamePrefix%>",expected_mission_fault,expected_latent_fault,<%=hier_path_dut%>.<%=obj.FscInfo.strRtlNamePrefix%>.fault_<%=obj.DiiInfo[i].strRtlNamePrefix%>_mission_fault,<%=hier_path_dut%>.<%=obj.FscInfo.strRtlNamePrefix%>.fault_<%=obj.DiiInfo[i].strRtlNamePrefix%>_latent_fault);
           repeat(clk_wait_after_release+15)@(posedge <%=hier_path_dut%>.<%=obj.DiiInfo[i].strRtlNamePrefix%>.clk_clk);
         <% }} %>
     if(bypass_fsys_fault_check_with_uce_signals==0) begin
     // #Stimulus.FSYS.FSC_DII_unit_error 
     // #Stimulus.FSYS.FSC_DII_dupunit_error 
         <% for (var idx = 0; idx< dii_uce_array[0].length; idx++) { %>
           repeat(FSYS_FAULT_INJECTOR_CHECKER_CLK_DELAY_BEFORE_ERR)@(posedge <%=hier_path_dut%>.<%=obj.DiiInfo[i].strRtlNamePrefix%>.clk_clk);
           <% if((i==0) && (idx==0)) { %>
           uncorr_err_inj_test_start_indication = 1;
           uvm_config_db#(int unsigned)::set(null, "", "uncorr_err_inj_test_start_indication", uncorr_err_inj_test_start_indication); 
           <% } %>
           signal_width = $bits(<%=hier_path_dut%>.<%=obj.DiiInfo[i].strRtlNamePrefix%>.<%=dii_uce_array[0][idx]%>);
           rand_pos_in_signal = $urandom_range(0, signal_width-1);
           fork
           begin
           if(func_unit_uncorr_err_inj) begin 
               prev_val[0][<%=idx%>] = <%=hier_path_dut%>.<%=obj.DiiInfo[i].strRtlNamePrefix%>.<%=dii_uce_array[0][idx]%>;
               signal_invalid_value_check("<%=hier_path_dut%>.<%=obj.DiiInfo[i].strRtlNamePrefix%>.<%=dii_uce_array[0][idx]%>",<%=hier_path_dut%>.<%=obj.DiiInfo[i].strRtlNamePrefix%>.<%=dii_uce_array[0][idx]%>);
               `uvm_info("fsys_fault_injector_checker",$sformatf("Error injection done (FORCE) on signal <%=hier_path_dut%>.<%=obj.DiiInfo[i].strRtlNamePrefix%>.<%=dii_uce_array[0][idx]%> of width=%0d. Random Bit-position=%0d, Orig value='h%0h, Forced value='h%0h",signal_width,rand_pos_in_signal,prev_val[0][<%=idx%>],1'b1),UVM_LOW)
               force   <%=hier_path_dut%>.<%=obj.DiiInfo[i].strRtlNamePrefix%>.<%=dii_uce_array[0][idx]%> =  1'b1; //prev_val[0][<%=idx%>] ^ (1'b1<<rand_pos_in_signal);
               @(posedge <%=hier_path_dut%>.<%=obj.DiiInfo[i].strRtlNamePrefix%>.clk_clk);
               release <%=hier_path_dut%>.<%=obj.DiiInfo[i].strRtlNamePrefix%>.<%=dii_uce_array[0][idx]%>;
               `uvm_info("fsys_fault_injector_checker",$sformatf("RELEASING signal <%=hier_path_dut%>.<%=obj.DiiInfo[i].strRtlNamePrefix%>.<%=dii_uce_array[0][idx]%> of width=%0d from Forced value='h%0h (Infected-bit %0d). Back to Orig value='h%0h",signal_width,prev_val[0][<%=idx%>] ^ (1'b1<<rand_pos_in_signal),rand_pos_in_signal,<%=hier_path_dut%>.<%=obj.DiiInfo[i].strRtlNamePrefix%>.<%=dii_uce_array[0][idx]%>),UVM_LOW)
           end
           end
           begin
           <% if(obj.DiiInfo[i].ResilienceInfo.enableUnitDuplication) {  %>
           if(dup_unit_uncorr_err_inj) begin 
               dup_prev_val[0][<%=idx%>] = <%=hier_path_dut%>.<%=obj.DiiInfo[i].strRtlNamePrefix%>.<%=dii_dup_uce_array[0][idx]%>;
               signal_invalid_value_check("<%=hier_path_dut%>.<%=obj.DiiInfo[i].strRtlNamePrefix%>.<%=dii_dup_uce_array[0][idx]%>",<%=hier_path_dut%>.<%=obj.DiiInfo[i].strRtlNamePrefix%>.<%=dii_dup_uce_array[0][idx]%>);
               repeat(<%=obj.DiiInfo[i].ResilienceInfo.nResiliencyDelay%>) begin
                 @(posedge <%=hier_path_dut%>.<%=obj.DiiInfo[i].strRtlNamePrefix%>.clk_clk);
               end
               `uvm_info("fsys_fault_injector_checker",$sformatf("Error injection done (FORCE) on signal <%=hier_path_dut%>.<%=obj.DiiInfo[i].strRtlNamePrefix%>.<%=dii_dup_uce_array[0][idx]%> of width=%0d. Random Bit-position=%0d, Orig value='h%0h, Forced value='h%0h",signal_width,rand_pos_in_signal,dup_prev_val[0][<%=idx%>],1'b1),UVM_LOW)
               force   <%=hier_path_dut%>.<%=obj.DiiInfo[i].strRtlNamePrefix%>.<%=dii_dup_uce_array[0][idx]%> = 1'b1; //dup_prev_val[0][<%=idx%>] ^ (1'b1<<rand_pos_in_signal);
               @(posedge <%=hier_path_dut%>.<%=obj.DiiInfo[i].strRtlNamePrefix%>.clk_clk);
               release <%=hier_path_dut%>.<%=obj.DiiInfo[i].strRtlNamePrefix%>.<%=dii_dup_uce_array[0][idx]%>;
               `uvm_info("fsys_fault_injector_checker",$sformatf("RELEASING signal <%=hier_path_dut%>.<%=obj.DiiInfo[i].strRtlNamePrefix%>.<%=dii_dup_uce_array[0][idx]%> of width=%0d from Forced value='h%0h (Infected-bit %0d). Back to Orig value='h%0h",signal_width,dup_prev_val[0][<%=idx%>] ^ (1'b1<<rand_pos_in_signal),rand_pos_in_signal,<%=hier_path_dut%>.<%=obj.DiiInfo[i].strRtlNamePrefix%>.<%=dii_dup_uce_array[0][idx]%>),UVM_LOW)
           end
           <% } %>
           end
           join
           reset_fsc_reg();
           expFaults(0, <%=obj.DiiInfo[i].ResilienceInfo.enableUnitDuplication%>,func_unit_uncorr_err_inj,dup_unit_uncorr_err_inj,expected_mission_fault,expected_latent_fault);
           expected_dii_mission_fault_reg[<%=i%>] = expected_mission_fault;
           expected_dii_latent_fault_reg[<%=i%>] = expected_latent_fault ;
           update_fsc_reg();
           repeat(clk_wait_after_release)@(posedge <%=hier_path_dut%>.<%=obj.DiiInfo[i].strRtlNamePrefix%>.clk_clk);
           compareFaults($sformatf("Consider other %0s inputs enableUnitDuplication %0d, UCERR at Func unit %0d, UCERR at Checker unit %0d  compareFaults function is called from file - fsys_fault_injector_checker line %0d","<%=obj.DiiInfo[i].strRtlNamePrefix%>",<%=obj.DiiInfo[i].ResilienceInfo.enableUnitDuplication%>,func_unit_uncorr_err_inj,(<%=obj.DiiInfo[i].ResilienceInfo.enableUnitDuplication%>==1) ? dup_unit_uncorr_err_inj: 0,`__LINE__),"<%=hier_path_dut%>.<%=obj.FscInfo.strRtlNamePrefix%>.<%=obj.DiiInfo[i].strRtlNamePrefix%>",expected_mission_fault,expected_latent_fault,<%=hier_path_dut%>.<%=obj.FscInfo.strRtlNamePrefix%>.fault_<%=obj.DiiInfo[i].strRtlNamePrefix%>_mission_fault,<%=hier_path_dut%>.<%=obj.FscInfo.strRtlNamePrefix%>.fault_<%=obj.DiiInfo[i].strRtlNamePrefix%>_latent_fault);
           repeat(clk_wait_after_release+15)@(posedge <%=hier_path_dut%>.<%=obj.DiiInfo[i].strRtlNamePrefix%>.clk_clk);
         <% } %>
     end // if(bypass_fsys_fault_check_with_uce_signals==0) begin
       <% } %>
       end // if(dii_uncorr_err_inj) begin


       //CHi AIU  
       if(chiaiu_uncorr_err_inj) begin
       <% var chiaiu_index = 0; 
       for (var i = 0; i<(obj.AiuInfo.length); i++) { %>
       <% if ((obj.AiuInfo[i].fnNativeInterface == "CHI-A") || (obj.AiuInfo[i].fnNativeInterface == "CHI-B") || (obj.AiuInfo[i].fnNativeInterface == "CHI-E")) { %>
         <% if(obj.AiuInfo[0].ResilienceInfo.enableUnitDuplication==1) { %>
         <% for (var idx = 0; idx< chi_aiu_outputs_array[0].length; idx++) { %>
           repeat(FSYS_FAULT_INJECTOR_CHECKER_CLK_DELAY_BEFORE_ERR)@(posedge <%=hier_path_dut%>.<%=obj.AiuInfo[i].strRtlNamePrefix%>.clk_clk);
           #1ps;
           <% if((i==0) && (idx==0)) { %>
           uncorr_err_inj_test_start_indication = 1;
           uvm_config_db#(int unsigned)::set(null, "", "uncorr_err_inj_test_start_indication", uncorr_err_inj_test_start_indication); 
           <% } %>
           prev_val[0][<%=idx%>] = <%=hier_path_dut%>.<%=obj.AiuInfo[i].strRtlNamePrefix%>.<%=chi_aiu_outputs_array[0][idx]%>;
           signal_invalid_value_check("<%=hier_path_dut%>.<%=obj.AiuInfo[i].strRtlNamePrefix%>.<%=chi_aiu_outputs_array[0][idx]%>",<%=hier_path_dut%>.<%=obj.AiuInfo[i].strRtlNamePrefix%>.<%=chi_aiu_outputs_array[0][idx]%>);
           signal_width = $bits(<%=hier_path_dut%>.<%=obj.AiuInfo[i].strRtlNamePrefix%>.<%=chi_aiu_outputs_array[0][idx]%>);
           rand_pos_in_signal = $urandom_range(0, signal_width-1);
           if(func_unit_uncorr_err_inj) begin 
               `uvm_info("fsys_fault_injector_checker",$sformatf("Error injection done (FORCE) on signal <%=hier_path_dut%>.<%=obj.AiuInfo[i].strRtlNamePrefix%>.<%=chi_aiu_outputs_array[0][idx]%> of width=%0d. Random Bit-position=%0d, Orig value='h%0h, Forced value='h%0h",signal_width,rand_pos_in_signal,prev_val[0][<%=idx%>],prev_val[0][<%=idx%>] ^ (1'b1<<rand_pos_in_signal)),UVM_LOW)
               force   <%=hier_path_dut%>.<%=obj.AiuInfo[i].strRtlNamePrefix%>.<%=chi_aiu_outputs_array[0][idx]%> = prev_val[0][<%=idx%>] ^ (1'b1<<rand_pos_in_signal);
           end
           <% if(obj.AiuInfo[i].ResilienceInfo.enableUnitDuplication) {  %>
           if(dup_unit_uncorr_err_inj) begin 
               dup_prev_val[0][<%=idx%>] = <%=hier_path_dut%>.<%=obj.AiuInfo[i].strRtlNamePrefix%>.<%=chi_aiu_dup_outputs_array[0][idx]%>;
               signal_invalid_value_check("<%=hier_path_dut%>.<%=obj.AiuInfo[i].strRtlNamePrefix%>.<%=chi_aiu_dup_outputs_array[0][idx]%>",<%=hier_path_dut%>.<%=obj.AiuInfo[i].strRtlNamePrefix%>.<%=chi_aiu_dup_outputs_array[0][idx]%>);
               `uvm_info("fsys_fault_injector_checker",$sformatf("Error injection done (FORCE) on signal <%=hier_path_dut%>.<%=obj.AiuInfo[i].strRtlNamePrefix%>.<%=chi_aiu_dup_outputs_array[0][idx]%> of width=%0d. Random Bit-position=%0d, Orig value='h%0h, Forced value='h%0h",signal_width,rand_pos_in_signal,dup_prev_val[0][<%=idx%>],dup_prev_val[0][<%=idx%>] ^ (1'b1<<rand_pos_in_signal)),UVM_LOW)
               force   <%=hier_path_dut%>.<%=obj.AiuInfo[i].strRtlNamePrefix%>.<%=chi_aiu_dup_outputs_array[0][idx]%> = dup_prev_val[0][<%=idx%>] ^ (1'b1<<rand_pos_in_signal);
           end
           <% } %>
           @(posedge <%=hier_path_dut%>.<%=obj.AiuInfo[i].strRtlNamePrefix%>.clk_clk);
           if(func_unit_uncorr_err_inj) begin 
               release <%=hier_path_dut%>.<%=obj.AiuInfo[i].strRtlNamePrefix%>.<%=chi_aiu_outputs_array[0][idx]%>;
               `uvm_info("fsys_fault_injector_checker",$sformatf("RELEASING signal <%=hier_path_dut%>.<%=obj.AiuInfo[i].strRtlNamePrefix%>.<%=chi_aiu_outputs_array[0][idx]%> of width=%0d from Forced value='h%0h (Infected-bit %0d). Back to Orig value='h%0h",signal_width,prev_val[0][<%=idx%>] ^ (1'b1<<rand_pos_in_signal),rand_pos_in_signal,<%=hier_path_dut%>.<%=obj.AiuInfo[i].strRtlNamePrefix%>.<%=chi_aiu_outputs_array[0][idx]%>),UVM_LOW)
           end
           <% if(obj.AiuInfo[i].ResilienceInfo.enableUnitDuplication) {  %>
           if(dup_unit_uncorr_err_inj) begin 
               release <%=hier_path_dut%>.<%=obj.AiuInfo[i].strRtlNamePrefix%>.<%=chi_aiu_dup_outputs_array[0][idx]%>;
               `uvm_info("fsys_fault_injector_checker",$sformatf("RELEASING signal <%=hier_path_dut%>.<%=obj.AiuInfo[i].strRtlNamePrefix%>.<%=chi_aiu_dup_outputs_array[0][idx]%> of width=%0d from Forced value='h%0h (Infected-bit %0d). Back to Orig value='h%0h",signal_width,dup_prev_val[0][<%=idx%>] ^ (1'b1<<rand_pos_in_signal),rand_pos_in_signal,<%=hier_path_dut%>.<%=obj.AiuInfo[i].strRtlNamePrefix%>.<%=chi_aiu_dup_outputs_array[0][idx]%>),UVM_LOW)
           end
           <% } %>
           reset_fsc_reg();
           expFaults(1, <%=obj.AiuInfo[i].ResilienceInfo.enableUnitDuplication%>,func_unit_uncorr_err_inj,dup_unit_uncorr_err_inj,expected_mission_fault,expected_latent_fault);
           expected_caiu_mission_fault_reg[<%=chiaiu_index%>] = expected_mission_fault;
           expected_caiu_latent_fault_reg[<%=chiaiu_index%>] = expected_latent_fault ;
           update_fsc_reg();
           repeat(clk_wait_after_release)@(posedge <%=hier_path_dut%>.<%=obj.AiuInfo[i].strRtlNamePrefix%>.clk_clk);
           compareFaults($sformatf("Consider other %0s inputs enableUnitDuplication %0d, UCERR at Func unit %0d, UCERR at Checker unit %0d  compareFaults function is called from file - fsys_fault_injector_checker line %0d","<%=obj.AiuInfo[i].strRtlNamePrefix%>",<%=obj.AiuInfo[i].ResilienceInfo.enableUnitDuplication%>,func_unit_uncorr_err_inj,(<%=obj.AiuInfo[i].ResilienceInfo.enableUnitDuplication%>==1) ? dup_unit_uncorr_err_inj: 0,`__LINE__),"<%=hier_path_dut%>.<%=obj.FscInfo.strRtlNamePrefix%>.<%=obj.AiuInfo[i].strRtlNamePrefix%>",expected_mission_fault,expected_latent_fault,<%=hier_path_dut%>.<%=obj.FscInfo.strRtlNamePrefix%>.fault_<%=obj.AiuInfo[i].strRtlNamePrefix%>_mission_fault,<%=hier_path_dut%>.<%=obj.FscInfo.strRtlNamePrefix%>.fault_<%=obj.AiuInfo[i].strRtlNamePrefix%>_latent_fault);
           repeat(clk_wait_after_release+15)@(posedge <%=hier_path_dut%>.<%=obj.AiuInfo[i].strRtlNamePrefix%>.clk_clk);
         <% }} %>
     if(bypass_fsys_fault_check_with_uce_signals==0) begin
     // #Stimulus.FSYS.FSC_CHI_unit_error 
     // #Stimulus.FSYS.FSC_CHI_dupunit_error 
         <% for (var idx = 0; idx< chi_aiu_uce_array[0].length; idx++) { %>
           repeat(FSYS_FAULT_INJECTOR_CHECKER_CLK_DELAY_BEFORE_ERR)@(posedge <%=hier_path_dut%>.<%=obj.AiuInfo[i].strRtlNamePrefix%>.clk_clk);
           <% if((i==0) && (idx==0)) { %>
           uncorr_err_inj_test_start_indication = 1;
           uvm_config_db#(int unsigned)::set(null, "", "uncorr_err_inj_test_start_indication", uncorr_err_inj_test_start_indication); 
           <% } %>
           signal_width = $bits(<%=hier_path_dut%>.<%=obj.AiuInfo[i].strRtlNamePrefix%>.<%=chi_aiu_uce_array[0][idx]%>);
           rand_pos_in_signal = $urandom_range(0, signal_width-1);
           fork
           begin
           if(func_unit_uncorr_err_inj) begin 
               prev_val[0][<%=idx%>] = <%=hier_path_dut%>.<%=obj.AiuInfo[i].strRtlNamePrefix%>.<%=chi_aiu_uce_array[0][idx]%>;
               signal_invalid_value_check("<%=hier_path_dut%>.<%=obj.AiuInfo[i].strRtlNamePrefix%>.<%=chi_aiu_uce_array[0][idx]%>",<%=hier_path_dut%>.<%=obj.AiuInfo[i].strRtlNamePrefix%>.<%=chi_aiu_uce_array[0][idx]%>);
               `uvm_info("fsys_fault_injector_checker",$sformatf("Error injection done (FORCE) on signal <%=hier_path_dut%>.<%=obj.AiuInfo[i].strRtlNamePrefix%>.<%=chi_aiu_uce_array[0][idx]%> of width=%0d. Random Bit-position=%0d, Orig value='h%0h, Forced value='h%0h",signal_width,rand_pos_in_signal,prev_val[0][<%=idx%>],1'b1),UVM_LOW)
               force   <%=hier_path_dut%>.<%=obj.AiuInfo[i].strRtlNamePrefix%>.<%=chi_aiu_uce_array[0][idx]%> =  1'b1; //prev_val[0][<%=idx%>] ^ (1'b1<<rand_pos_in_signal);
               @(posedge <%=hier_path_dut%>.<%=obj.AiuInfo[i].strRtlNamePrefix%>.clk_clk);
               release <%=hier_path_dut%>.<%=obj.AiuInfo[i].strRtlNamePrefix%>.<%=chi_aiu_uce_array[0][idx]%>;
               `uvm_info("fsys_fault_injector_checker",$sformatf("RELEASING signal <%=hier_path_dut%>.<%=obj.AiuInfo[i].strRtlNamePrefix%>.<%=chi_aiu_uce_array[0][idx]%> of width=%0d from Forced value='h%0h (Infected-bit %0d). Back to Orig value='h%0h",signal_width,prev_val[0][<%=idx%>] ^ (1'b1<<rand_pos_in_signal),rand_pos_in_signal,<%=hier_path_dut%>.<%=obj.AiuInfo[i].strRtlNamePrefix%>.<%=chi_aiu_uce_array[0][idx]%>),UVM_LOW)
           end
           end
           begin
           <% if(obj.AiuInfo[i].ResilienceInfo.enableUnitDuplication) {  %>
           if(dup_unit_uncorr_err_inj) begin 
               dup_prev_val[0][<%=idx%>] = <%=hier_path_dut%>.<%=obj.AiuInfo[i].strRtlNamePrefix%>.<%=chi_aiu_dup_uce_array[0][idx]%>;
               signal_invalid_value_check("<%=hier_path_dut%>.<%=obj.AiuInfo[i].strRtlNamePrefix%>.<%=chi_aiu_dup_uce_array[0][idx]%>",<%=hier_path_dut%>.<%=obj.AiuInfo[i].strRtlNamePrefix%>.<%=chi_aiu_dup_uce_array[0][idx]%>);
               repeat(<%=obj.AiuInfo[i].ResilienceInfo.nResiliencyDelay%>) begin
                 @(posedge <%=hier_path_dut%>.<%=obj.AiuInfo[i].strRtlNamePrefix%>.clk_clk);
               end
               `uvm_info("fsys_fault_injector_checker",$sformatf("Error injection done (FORCE) on signal <%=hier_path_dut%>.<%=obj.AiuInfo[i].strRtlNamePrefix%>.<%=chi_aiu_dup_uce_array[0][idx]%> of width=%0d. Random Bit-position=%0d, Orig value='h%0h, Forced value='h%0h",signal_width,rand_pos_in_signal,dup_prev_val[0][<%=idx%>],1'b1),UVM_LOW)
               force   <%=hier_path_dut%>.<%=obj.AiuInfo[i].strRtlNamePrefix%>.<%=chi_aiu_dup_uce_array[0][idx]%> = 1'b1; //dup_prev_val[0][<%=idx%>] ^ (1'b1<<rand_pos_in_signal);
               @(posedge <%=hier_path_dut%>.<%=obj.AiuInfo[i].strRtlNamePrefix%>.clk_clk);
               release <%=hier_path_dut%>.<%=obj.AiuInfo[i].strRtlNamePrefix%>.<%=chi_aiu_dup_uce_array[0][idx]%>;
               `uvm_info("fsys_fault_injector_checker",$sformatf("RELEASING signal <%=hier_path_dut%>.<%=obj.AiuInfo[i].strRtlNamePrefix%>.<%=chi_aiu_dup_uce_array[0][idx]%> of width=%0d from Forced value='h%0h (Infected-bit %0d). Back to Orig value='h%0h",signal_width,dup_prev_val[0][<%=idx%>] ^ (1'b1<<rand_pos_in_signal),rand_pos_in_signal,<%=hier_path_dut%>.<%=obj.AiuInfo[i].strRtlNamePrefix%>.<%=chi_aiu_dup_uce_array[0][idx]%>),UVM_LOW)
           end
           <% } %>
           end
           join
           reset_fsc_reg();
           expFaults(0, <%=obj.AiuInfo[i].ResilienceInfo.enableUnitDuplication%>,func_unit_uncorr_err_inj,dup_unit_uncorr_err_inj,expected_mission_fault,expected_latent_fault);
           expected_caiu_mission_fault_reg[<%=chiaiu_index%>] = expected_mission_fault;
           expected_caiu_latent_fault_reg[<%=chiaiu_index%>] = expected_latent_fault ;
           update_fsc_reg();
           repeat(clk_wait_after_release)@(posedge <%=hier_path_dut%>.<%=obj.AiuInfo[i].strRtlNamePrefix%>.clk_clk);
           compareFaults($sformatf("Consider other %0s inputs enableUnitDuplication %0d, UCERR at Func unit %0d, UCERR at Checker unit %0d  compareFaults function is called from file - fsys_fault_injector_checker line %0d","<%=obj.AiuInfo[i].strRtlNamePrefix%>",<%=obj.AiuInfo[i].ResilienceInfo.enableUnitDuplication%>,func_unit_uncorr_err_inj,(<%=obj.AiuInfo[i].ResilienceInfo.enableUnitDuplication%>==1) ? dup_unit_uncorr_err_inj: 0,`__LINE__),"<%=hier_path_dut%>.<%=obj.FscInfo.strRtlNamePrefix%>.<%=obj.AiuInfo[i].strRtlNamePrefix%>",expected_mission_fault,expected_latent_fault,<%=hier_path_dut%>.<%=obj.FscInfo.strRtlNamePrefix%>.fault_<%=obj.AiuInfo[i].strRtlNamePrefix%>_mission_fault,<%=hier_path_dut%>.<%=obj.FscInfo.strRtlNamePrefix%>.fault_<%=obj.AiuInfo[i].strRtlNamePrefix%>_latent_fault);
           repeat(clk_wait_after_release+15)@(posedge <%=hier_path_dut%>.<%=obj.AiuInfo[i].strRtlNamePrefix%>.clk_clk);
         <% } %>
     end // if(bypass_fsys_fault_check_with_uce_signals==0) begin
       <% chiaiu_index = chiaiu_index+1; } %>
       <% } %>
       end // if(chiaiu_uncorr_err_inj) begin

       //IO AIU  
       if(ioaiu_uncorr_err_inj) begin
       <% var ioaiu_index = 0;
       for (var i = 0; i<(obj.AiuInfo.length); i++) { %>
       <% if ((obj.AiuInfo[i].fnNativeInterface != "CHI-A") && (obj.AiuInfo[i].fnNativeInterface != "CHI-B")  && (obj.AiuInfo[i].fnNativeInterface != "CHI-E")) { %>
         <% if(obj.AiuInfo[0].ResilienceInfo.enableUnitDuplication==1) { %>
         <% for (var idx = 0; idx< ioaiu_outputs_array[0].length; idx++) { %>
           repeat(FSYS_FAULT_INJECTOR_CHECKER_CLK_DELAY_BEFORE_ERR)@(posedge <%=hier_path_dut%>.<%=obj.AiuInfo[i].strRtlNamePrefix%>.clk_clk);
           #1ps;
           <% if(idx==0) { %>
           uncorr_err_inj_test_start_indication = 1;
           uvm_config_db#(int unsigned)::set(null, "", "uncorr_err_inj_test_start_indication", uncorr_err_inj_test_start_indication); 
           <% } %>
           prev_val[0][<%=idx%>] = <%=hier_path_dut%>.<%=obj.AiuInfo[i].strRtlNamePrefix%>.<%=ioaiu_outputs_array[0][idx]%>;
           signal_invalid_value_check("<%=hier_path_dut%>.<%=obj.AiuInfo[i].strRtlNamePrefix%>.<%=ioaiu_outputs_array[0][idx]%>",<%=hier_path_dut%>.<%=obj.AiuInfo[i].strRtlNamePrefix%>.<%=ioaiu_outputs_array[0][idx]%>);
           signal_width = $bits(<%=hier_path_dut%>.<%=obj.AiuInfo[i].strRtlNamePrefix%>.<%=ioaiu_outputs_array[0][idx]%>);
           rand_pos_in_signal = $urandom_range(0, signal_width-1);
           if(func_unit_uncorr_err_inj) begin 
               `uvm_info("fsys_fault_injector_checker",$sformatf("Error injection done (FORCE) on signal <%=hier_path_dut%>.<%=obj.AiuInfo[i].strRtlNamePrefix%>.<%=ioaiu_outputs_array[0][idx]%> of width=%0d. Random Bit-position=%0d, Orig value='h%0h, Forced value='h%0h",signal_width,rand_pos_in_signal,prev_val[0][<%=idx%>],prev_val[0][<%=idx%>] ^ (1'b1<<rand_pos_in_signal)),UVM_LOW)
               force   <%=hier_path_dut%>.<%=obj.AiuInfo[i].strRtlNamePrefix%>.<%=ioaiu_outputs_array[0][idx]%> = prev_val[0][<%=idx%>] ^ (1'b1<<rand_pos_in_signal);
           end
           <% if(obj.AiuInfo[i].ResilienceInfo.enableUnitDuplication) {  %>
           if(dup_unit_uncorr_err_inj) begin 
               dup_prev_val[0][<%=idx%>] = <%=hier_path_dut%>.<%=obj.AiuInfo[i].strRtlNamePrefix%>.<%=ioaiu_dup_outputs_array[0][idx]%>;
               signal_invalid_value_check("<%=hier_path_dut%>.<%=obj.AiuInfo[i].strRtlNamePrefix%>.<%=ioaiu_dup_outputs_array[0][idx]%>",<%=hier_path_dut%>.<%=obj.AiuInfo[i].strRtlNamePrefix%>.<%=ioaiu_dup_outputs_array[0][idx]%>);
               `uvm_info("fsys_fault_injector_checker",$sformatf("Error injection done (FORCE) on signal <%=hier_path_dut%>.<%=obj.AiuInfo[i].strRtlNamePrefix%>.<%=ioaiu_dup_outputs_array[0][idx]%> of width=%0d. Random Bit-position=%0d, Orig value='h%0h, Forced value='h%0h",signal_width,rand_pos_in_signal,dup_prev_val[0][<%=idx%>],dup_prev_val[0][<%=idx%>] ^ (1'b1<<rand_pos_in_signal)),UVM_LOW)
               force   <%=hier_path_dut%>.<%=obj.AiuInfo[i].strRtlNamePrefix%>.<%=ioaiu_dup_outputs_array[0][idx]%> = dup_prev_val[0][<%=idx%>] ^ (1'b1<<rand_pos_in_signal);
           end
           <% } %>
           @(posedge <%=hier_path_dut%>.<%=obj.AiuInfo[i].strRtlNamePrefix%>.clk_clk);
           if(func_unit_uncorr_err_inj) begin 
               release <%=hier_path_dut%>.<%=obj.AiuInfo[i].strRtlNamePrefix%>.<%=ioaiu_outputs_array[0][idx]%>;
               `uvm_info("fsys_fault_injector_checker",$sformatf("RELEASING signal <%=hier_path_dut%>.<%=obj.AiuInfo[i].strRtlNamePrefix%>.<%=ioaiu_outputs_array[0][idx]%> of width=%0d from Forced value='h%0h (Infected-bit %0d). Back to Orig value='h%0h",signal_width,prev_val[0][<%=idx%>] ^ (1'b1<<rand_pos_in_signal),rand_pos_in_signal,<%=hier_path_dut%>.<%=obj.AiuInfo[i].strRtlNamePrefix%>.<%=ioaiu_outputs_array[0][idx]%>),UVM_LOW)
           end
           <% if(obj.AiuInfo[i].ResilienceInfo.enableUnitDuplication) {  %>
           if(dup_unit_uncorr_err_inj) begin 
               release <%=hier_path_dut%>.<%=obj.AiuInfo[i].strRtlNamePrefix%>.<%=ioaiu_dup_outputs_array[0][idx]%>;
               `uvm_info("fsys_fault_injector_checker",$sformatf("RELEASING signal <%=hier_path_dut%>.<%=obj.AiuInfo[i].strRtlNamePrefix%>.<%=ioaiu_dup_outputs_array[0][idx]%> of width=%0d from Forced value='h%0h (Infected-bit %0d). Back to Orig value='h%0h",signal_width,dup_prev_val[0][<%=idx%>] ^ (1'b1<<rand_pos_in_signal),rand_pos_in_signal,<%=hier_path_dut%>.<%=obj.AiuInfo[i].strRtlNamePrefix%>.<%=ioaiu_dup_outputs_array[0][idx]%>),UVM_LOW)
           end
           <% } %>
           reset_fsc_reg();
           expFaults(1, <%=obj.AiuInfo[i].ResilienceInfo.enableUnitDuplication%>,func_unit_uncorr_err_inj,dup_unit_uncorr_err_inj,expected_mission_fault,expected_latent_fault);
           expected_ioaiu_mission_fault_reg[<%=ioaiu_index%>] = expected_mission_fault;
           expected_ioaiu_latent_fault_reg[<%=ioaiu_index%>] = expected_latent_fault ;
           update_fsc_reg();
           repeat(clk_wait_after_release)@(posedge <%=hier_path_dut%>.<%=obj.AiuInfo[i].strRtlNamePrefix%>.clk_clk);
           compareFaults($sformatf("Consider other %0s inputs enableUnitDuplication %0d, UCERR at Func unit %0d, UCERR at Checker unit %0d  compareFaults function is called from file - fsys_fault_injector_checker line %0d","<%=obj.AiuInfo[i].strRtlNamePrefix%>",<%=obj.AiuInfo[i].ResilienceInfo.enableUnitDuplication%>,func_unit_uncorr_err_inj,(<%=obj.AiuInfo[i].ResilienceInfo.enableUnitDuplication%>==1) ? dup_unit_uncorr_err_inj: 0,`__LINE__),"<%=hier_path_dut%>.<%=obj.FscInfo.strRtlNamePrefix%>.<%=obj.AiuInfo[i].strRtlNamePrefix%>",expected_mission_fault,expected_latent_fault,<%=hier_path_dut%>.<%=obj.FscInfo.strRtlNamePrefix%>.fault_<%=obj.AiuInfo[i].strRtlNamePrefix%>_mission_fault,<%=hier_path_dut%>.<%=obj.FscInfo.strRtlNamePrefix%>.fault_<%=obj.AiuInfo[i].strRtlNamePrefix%>_latent_fault);
           repeat(clk_wait_after_release+15)@(posedge <%=hier_path_dut%>.<%=obj.AiuInfo[i].strRtlNamePrefix%>.clk_clk);
         <% }} %>
     if(bypass_fsys_fault_check_with_uce_signals==0) begin
     // #Stimulus.FSYS.FSC_IO_unit_error 
     // #Stimulus.FSYS.FSC_IO_dupunit_error 
       <%   
       var ioaiu_uce_array_num = 0;
          if(obj.AiuInfo[i].fnNativeInterface == "ACE" || obj.AiuInfo[i].fnNativeInterface == "ACE5") { ioaiu_uce_array_num = 0;}
          else if(obj.AiuInfo[i].fnNativeInterface == "ACELITE-E") { 
              if(obj.AiuInfo[i].interfaces.axiInt.eAc>0) {
                ioaiu_uce_array_num = 1;
              } else {
                ioaiu_uce_array_num = 5;
              }
          }
          else if(obj.AiuInfo[i].fnNativeInterface == "ACE-LITE") { ioaiu_uce_array_num = 2;}
          else if(((obj.AiuInfo[i].fnNativeInterface == "AXI4") || (obj.AiuInfo[i].fnNativeInterface == "AXI5")) && (obj.AiuInfo[i].useCache==0)) { ioaiu_uce_array_num = 3;}
          else if(((obj.AiuInfo[i].fnNativeInterface == "AXI4") || (obj.AiuInfo[i].fnNativeInterface == "AXI5")) && (obj.AiuInfo[i].useCache==1)) { ioaiu_uce_array_num = 4;}
       %>  
         <% for (var idx = 0; idx< ioaiu_uce_array[ioaiu_uce_array_num].length; idx++) { %>
           repeat(FSYS_FAULT_INJECTOR_CHECKER_CLK_DELAY_BEFORE_ERR)@(posedge <%=hier_path_dut%>.<%=obj.AiuInfo[i].strRtlNamePrefix%>.clk_clk);
           <% if(idx==0) { %>
           uncorr_err_inj_test_start_indication = 1;
           uvm_config_db#(int unsigned)::set(null, "", "uncorr_err_inj_test_start_indication", uncorr_err_inj_test_start_indication); 
           <% } %>
           signal_width = $bits(<%=hier_path_dut%>.<%=obj.AiuInfo[i].strRtlNamePrefix%>.<%=ioaiu_uce_array[ioaiu_uce_array_num][idx]%>);
           rand_pos_in_signal = $urandom_range(0, signal_width-1);
           fork
           begin
           if(func_unit_uncorr_err_inj) begin 
               prev_val[0][<%=idx%>] = <%=hier_path_dut%>.<%=obj.AiuInfo[i].strRtlNamePrefix%>.<%=ioaiu_uce_array[ioaiu_uce_array_num][idx]%>;
               signal_invalid_value_check("<%=hier_path_dut%>.<%=obj.AiuInfo[i].strRtlNamePrefix%>.<%=ioaiu_uce_array[ioaiu_uce_array_num][idx]%>",<%=hier_path_dut%>.<%=obj.AiuInfo[i].strRtlNamePrefix%>.<%=ioaiu_uce_array[ioaiu_uce_array_num][idx]%>);
               `uvm_info("fsys_fault_injector_checker",$sformatf("Error injection done (FORCE) on signal <%=hier_path_dut%>.<%=obj.AiuInfo[i].strRtlNamePrefix%>.<%=ioaiu_uce_array[ioaiu_uce_array_num][idx]%> of width=%0d. Random Bit-position=%0d, Orig value='h%0h, Forced value='h%0h",signal_width,rand_pos_in_signal,prev_val[0][<%=idx%>],1'b1),UVM_LOW)
               force   <%=hier_path_dut%>.<%=obj.AiuInfo[i].strRtlNamePrefix%>.<%=ioaiu_uce_array[ioaiu_uce_array_num][idx]%> =  1'b1; //prev_val[0][<%=idx%>] ^ (1'b1<<rand_pos_in_signal);
               @(posedge <%=hier_path_dut%>.<%=obj.AiuInfo[i].strRtlNamePrefix%>.clk_clk);
               release <%=hier_path_dut%>.<%=obj.AiuInfo[i].strRtlNamePrefix%>.<%=ioaiu_uce_array[ioaiu_uce_array_num][idx]%>;
               `uvm_info("fsys_fault_injector_checker",$sformatf("RELEASING signal <%=hier_path_dut%>.<%=obj.AiuInfo[i].strRtlNamePrefix%>.<%=ioaiu_uce_array[ioaiu_uce_array_num][idx]%> of width=%0d from Forced value='h%0h (Infected-bit %0d). Back to Orig value='h%0h",signal_width,prev_val[0][<%=idx%>] ^ (1'b1<<rand_pos_in_signal),rand_pos_in_signal,<%=hier_path_dut%>.<%=obj.AiuInfo[i].strRtlNamePrefix%>.<%=ioaiu_uce_array[ioaiu_uce_array_num][idx]%>),UVM_LOW)
           end
           end
           begin
           <% if(obj.AiuInfo[i].ResilienceInfo.enableUnitDuplication) {  %>
           if(dup_unit_uncorr_err_inj) begin 
               dup_prev_val[0][<%=idx%>] = <%=hier_path_dut%>.<%=obj.AiuInfo[i].strRtlNamePrefix%>.<%=ioaiu_dup_uce_array[ioaiu_uce_array_num][idx]%>;
               signal_invalid_value_check("<%=hier_path_dut%>.<%=obj.AiuInfo[i].strRtlNamePrefix%>.<%=ioaiu_dup_uce_array[ioaiu_uce_array_num][idx]%>",<%=hier_path_dut%>.<%=obj.AiuInfo[i].strRtlNamePrefix%>.<%=ioaiu_dup_uce_array[ioaiu_uce_array_num][idx]%>);
               repeat(<%=obj.AiuInfo[i].ResilienceInfo.nResiliencyDelay%>) begin
                 @(posedge <%=hier_path_dut%>.<%=obj.AiuInfo[i].strRtlNamePrefix%>.clk_clk);
               end
               `uvm_info("fsys_fault_injector_checker",$sformatf("Error injection done (FORCE) on signal <%=hier_path_dut%>.<%=obj.AiuInfo[i].strRtlNamePrefix%>.<%=ioaiu_dup_uce_array[ioaiu_uce_array_num][idx]%> of width=%0d. Random Bit-position=%0d, Orig value='h%0h, Forced value='h%0h",signal_width,rand_pos_in_signal,dup_prev_val[0][<%=idx%>],1'b1),UVM_LOW)
               force   <%=hier_path_dut%>.<%=obj.AiuInfo[i].strRtlNamePrefix%>.<%=ioaiu_dup_uce_array[ioaiu_uce_array_num][idx]%> = 1'b1; //dup_prev_val[0][<%=idx%>] ^ (1'b1<<rand_pos_in_signal);
               @(posedge <%=hier_path_dut%>.<%=obj.AiuInfo[i].strRtlNamePrefix%>.clk_clk);
               release <%=hier_path_dut%>.<%=obj.AiuInfo[i].strRtlNamePrefix%>.<%=ioaiu_dup_uce_array[ioaiu_uce_array_num][idx]%>;
               `uvm_info("fsys_fault_injector_checker",$sformatf("RELEASING signal <%=hier_path_dut%>.<%=obj.AiuInfo[i].strRtlNamePrefix%>.<%=ioaiu_dup_uce_array[ioaiu_uce_array_num][idx]%> of width=%0d from Forced value='h%0h (Infected-bit %0d). Back to Orig value='h%0h",signal_width,dup_prev_val[0][<%=idx%>] ^ (1'b1<<rand_pos_in_signal),rand_pos_in_signal,<%=hier_path_dut%>.<%=obj.AiuInfo[i].strRtlNamePrefix%>.<%=ioaiu_dup_uce_array[ioaiu_uce_array_num][idx]%>),UVM_LOW)
           end
           <% } %>
           end
           join
           reset_fsc_reg();
           expFaults(0, <%=obj.AiuInfo[i].ResilienceInfo.enableUnitDuplication%>,func_unit_uncorr_err_inj,dup_unit_uncorr_err_inj,expected_mission_fault,expected_latent_fault);
           expected_ioaiu_mission_fault_reg[<%=ioaiu_index%>] = expected_mission_fault;
           expected_ioaiu_latent_fault_reg[<%=ioaiu_index%>] = expected_latent_fault ;
           update_fsc_reg();
           repeat(clk_wait_after_release)@(posedge <%=hier_path_dut%>.<%=obj.AiuInfo[i].strRtlNamePrefix%>.clk_clk);
           compareFaults($sformatf("Consider other %0s inputs enableUnitDuplication %0d, UCERR at Func unit %0d, UCERR at Checker unit %0d  compareFaults function is called from file - fsys_fault_injector_checker line %0d","<%=obj.AiuInfo[i].strRtlNamePrefix%>",<%=obj.AiuInfo[i].ResilienceInfo.enableUnitDuplication%>,func_unit_uncorr_err_inj,(<%=obj.AiuInfo[i].ResilienceInfo.enableUnitDuplication%>==1) ? dup_unit_uncorr_err_inj: 0,`__LINE__),"<%=hier_path_dut%>.<%=obj.FscInfo.strRtlNamePrefix%>.<%=obj.AiuInfo[i].strRtlNamePrefix%>",expected_mission_fault,expected_latent_fault,<%=hier_path_dut%>.<%=obj.FscInfo.strRtlNamePrefix%>.fault_<%=obj.AiuInfo[i].strRtlNamePrefix%>_mission_fault,<%=hier_path_dut%>.<%=obj.FscInfo.strRtlNamePrefix%>.fault_<%=obj.AiuInfo[i].strRtlNamePrefix%>_latent_fault);
           repeat(clk_wait_after_release+15)@(posedge <%=hier_path_dut%>.<%=obj.AiuInfo[i].strRtlNamePrefix%>.clk_clk);
         <% } %>
     end // if(bypass_fsys_fault_check_with_uce_signals==0) begin
       <% ioaiu_index = ioaiu_index + 1; } %>
       <% } %>
       end // if(ioaiu_uncorr_err_inj) begin



     end
     uncorr_err_inj_test_start_indication = 0;
     uvm_config_db#(int unsigned)::set(null, "", "uncorr_err_inj_test_start_indication", uncorr_err_inj_test_start_indication); 
   end

  bit dce_corr_err_inj, dmi_corr_err_inj, dve_corr_err_inj, dii_corr_err_inj, chiaiu_corr_err_inj, ioaiu_corr_err_inj;
  int num_dce_signals_for_corr_err_inj     =   <%=dce_ce_signals_array.length%>; 
  int num_dmi_signals_for_corr_err_inj     =   <%=dmi_ce_signals_array.length%>; 
  int num_dve_signals_for_corr_err_inj     =   <%=dve_ce_signals_array.length%>; 
  int num_dii_signals_for_corr_err_inj     =   <%=dii_ce_signals_array.length%>; 
  int num_ioaiu_signals_for_corr_err_inj   =   0; 
  int num_chi_aiu_signals_for_corr_err_inj =   <%=chi_aiu_ce_signals_array.length%>;
  bit func_unit_corr_err_inj, dup_unit_corr_err_inj, both_units_corr_err_inj;
  initial begin
     if($test$plusargs("disable_bist"))
         FSYS_FAULT_INJECTOR_CHECKER_CLK_DELAY_BEFORE_ERR = 100;
     else
         FSYS_FAULT_INJECTOR_CHECKER_CLK_DELAY_BEFORE_ERR = 20480;
      injectSingleErr = new("injectSingleErr");
      uvm_config_db#(uvm_event)::set( .cntxt(null),
                                    .inst_name(""),
                                    .field_name( "injectSingleErr" ),
                                    .value( injectSingleErr));
      reset_fsc_reg();
      //if ($test$plusargs("func_unit_corr_err_inj") || $test$plusargs("dup_unit_corr_err_inj")) begin
      //    $value$plusargs("func_unit_corr_err_inj=%d",func_unit_corr_err_inj);
      //    $value$plusargs("dup_unit_corr_err_inj=%d",dup_unit_corr_err_inj);
      //    if(func_unit_corr_err_inj && dup_unit_corr_err_inj)  both_units_corr_err_inj = 1;
      //end else begin
          func_unit_corr_err_inj = 1;
          dup_unit_corr_err_inj = 1;
      //end
      $value$plusargs("dce_corr_err_inj=%d",dce_corr_err_inj);
      $value$plusargs("dmi_corr_err_inj=%d",dmi_corr_err_inj);
      $value$plusargs("dve_corr_err_inj=%d",dve_corr_err_inj);
      $value$plusargs("dii_corr_err_inj=%d",dii_corr_err_inj);
      $value$plusargs("chiaiu_corr_err_inj=%d",chiaiu_corr_err_inj);
      $value$plusargs("ioaiu_corr_err_inj=%d",ioaiu_corr_err_inj);
      if(!((dce_corr_err_inj==1) ||  (dmi_corr_err_inj==1)|| (dve_corr_err_inj==1) || (dii_corr_err_inj==1) || (chiaiu_corr_err_inj==1) || (ioaiu_corr_err_inj==1))) begin
         randcase
         1: dce_corr_err_inj  = 1;
         1: dmi_corr_err_inj  = 1;
         1: dve_corr_err_inj  = 1;
         1: dii_corr_err_inj  = 1;
         1: chiaiu_corr_err_inj  = 1;
         1: ioaiu_corr_err_inj   = 1;
         endcase
      end
       <% var num_of_signals = 0; %>
       <% for (var i = 0; i<(obj.AiuInfo.length); i++) { %>
       <% if ((obj.AiuInfo[i].fnNativeInterface != "CHI-A") && (obj.AiuInfo[i].fnNativeInterface != "CHI-B")  && (obj.AiuInfo[i].fnNativeInterface != "CHI-E")) { %>
       <%   
          if(obj.AiuInfo[i].fnNativeInterface == "ACE" || obj.AiuInfo[i].fnNativeInterface == "ACE5") { num_of_signals = num_of_signals + ioaiu_ce_array[0].length;}
          else if(obj.AiuInfo[i].fnNativeInterface == "ACELITE-E") { 
              if(obj.AiuInfo[i].interfaces.axiInt.eAc>0) {
                num_of_signals = num_of_signals + ioaiu_ce_array[1].length;
              } else {
                num_of_signals = num_of_signals + ioaiu_ce_array[5].length;
              }
          }
          else if(obj.AiuInfo[i].fnNativeInterface == "ACE-LITE") {  num_of_signals = num_of_signals + ioaiu_ce_array[2].length; }
          else if(((obj.AiuInfo[i].fnNativeInterface == "AXI4") || (obj.AiuInfo[i].fnNativeInterface == "AXI5")) && (obj.AiuInfo[i].useCache==0)) { num_of_signals = num_of_signals + ioaiu_ce_array[3].length;}
          else if(((obj.AiuInfo[i].fnNativeInterface == "AXI4")  || (obj.AiuInfo[i].fnNativeInterface == "AXI5")) && (obj.AiuInfo[i].useCache==1)) { num_of_signals = num_of_signals + ioaiu_ce_array[4].length;}
       %>  
       <% }} %>
         num_ioaiu_signals_for_corr_err_inj   =    (num_ioaiu_signals_for_corr_err_inj * <%=numIoAiu%>) + <%=num_of_signals%>; 
      `uvm_info("fsys_fault_injector_checker", $psprintf("DCE units=%0d DMI units=%0d DVE units=%0d DII units=%0d IOAIU units=%0d CHIAIU units=%0d",<%=obj.DceInfo.length%>,<%=obj.DmiInfo.length%>,<%=obj.DveInfo.length%>,<%=obj.DiiInfo.length%>,<%=numIoAiu%>,<%=numChiAiu%>),UVM_LOW)
      `uvm_info("fsys_fault_injector_checker", $psprintf("num_dce_signals_for_corr_err_inj %0d,num_dmi_signals_for_corr_err_inj %0d,num_dve_signals_for_corr_err_inj %0d,num_dii_signals_for_corr_err_inj %0d,num_ioaiu_signals_for_corr_err_inj %0d,num_chi_aiu_signals_for_corr_err_inj %0d",num_dce_signals_for_corr_err_inj,num_dmi_signals_for_corr_err_inj,num_dve_signals_for_corr_err_inj,num_dii_signals_for_corr_err_inj,num_ioaiu_signals_for_corr_err_inj,num_chi_aiu_signals_for_corr_err_inj),UVM_LOW)
     uvm_config_db#(int unsigned)::set(null, "", "corr_err_inj_test_start_indication", corr_err_inj_test_start_indication); 
     uvm_config_db#(int unsigned)::set(null, "", "num_dce_signals_for_corr_err_inj", dce_corr_err_inj ? (num_dce_signals_for_corr_err_inj * <%=obj.DceInfo.length%>) : 0  ); 
     uvm_config_db#(int unsigned)::set(null, "", "num_dmi_signals_for_corr_err_inj", dmi_corr_err_inj ? (num_dmi_signals_for_corr_err_inj * <%=obj.DmiInfo.length%>) : 0  ); 
     uvm_config_db#(int unsigned)::set(null, "", "num_dve_signals_for_corr_err_inj", dve_corr_err_inj ? (num_dve_signals_for_corr_err_inj * <%=obj.DveInfo.length%>) : 0  ); 
     uvm_config_db#(int unsigned)::set(null, "", "num_dii_signals_for_corr_err_inj", dii_corr_err_inj ? (num_dii_signals_for_corr_err_inj * (<%=obj.DiiInfo.length%> - 1)) : 0  ); 
     uvm_config_db#(int unsigned)::set(null, "", "num_ioaiu_signals_for_corr_err_inj", ioaiu_corr_err_inj ? (num_ioaiu_signals_for_corr_err_inj ) : 0 ); 
     uvm_config_db#(int unsigned)::set(null, "", "num_chi_aiu_signals_for_corr_err_inj", chiaiu_corr_err_inj ? (num_chi_aiu_signals_for_corr_err_inj * <%=numChiAiu%>) : 0); 
     `uvm_info("fsys_fault_injector_checker",$sformatf("Run-time switch settings : dce_corr_err_inj %0d,dmi_corr_err_inj %0d,dve_corr_err_inj %0d,dii_corr_err_inj %0d,chiaiu_corr_err_inj %0d,ioaiu_corr_err_inj %0d",dce_corr_err_inj,dmi_corr_err_inj,dve_corr_err_inj,dii_corr_err_inj,chiaiu_corr_err_inj,ioaiu_corr_err_inj),UVM_LOW)
     `uvm_info("fsys_fault_injector_checker",$sformatf("Run-time switch settings : func_unit_corr_err_inj %0d dup_unit_corr_err_inj %0d",func_unit_corr_err_inj,dup_unit_corr_err_inj),UVM_LOW)
     if($test$plusargs("fsc_inject_correctable_err")) begin
       @(posedge tb_rstn);
       #1000ns; // CONC-14034 - Adding hardcode delay to finish sysco attach messaging to DCEs
       //DMI  
       if(dmi_corr_err_inj) begin
     // #Stimulus.FSYS.FSC_DMI_reach_corr_threshold 
       <% var hier_path_dmi_corr = ''; %>
       <% for (var i = 0; i<obj.DmiInfo.length; i++) { %>
         <% if(obj.DmiInfo[i].hierPath && obj.DmiInfo[i].hierPath !== '') { 
            hier_path_dmi_corr = `${hier_path_dut}.${obj.DmiInfo[i].hierPath}`;
          } else {
            hier_path_dmi_corr = hier_path_dut; 
         }%>
         <% for (var idx = 0; idx< dmi_ce_array[0].length; idx++) { %>
           <% if((i==0) && (idx==0)) { %>
           corr_err_inj_test_start_indication = 1;
           uvm_config_db#(int unsigned)::set(null, "", "corr_err_inj_test_start_indication", corr_err_inj_test_start_indication); 
           <% } %>
           injectSingleErr.wait_trigger();
           reset_fsc_reg();
           repeat(<%=hier_path_dmi_corr%>.<%=obj.DmiInfo[i].strRtlNamePrefix%>.dmi_unit.csr.res_cerr_thresh+1) begin
             @(posedge <%=hier_path_dmi_corr%>.<%=obj.DmiInfo[i].strRtlNamePrefix%>.clk_clk);
             fork
             begin
              if(func_unit_corr_err_inj) begin 
               `uvm_info("fsys_fault_injector_checker",$sformatf("Error injection done (FORCE) on signal <%=hier_path_dmi_corr%>.<%=obj.DmiInfo[i].strRtlNamePrefix%>.<%=dmi_ce_array[0][idx]%> Orig value='h%0h, Forced value='h%0h",<%=hier_path_dmi_corr%>.<%=obj.DmiInfo[i].strRtlNamePrefix%>.<%=dmi_ce_array[0][idx]%>,1'b1),UVM_LOW)
               force   <%=hier_path_dmi_corr%>.<%=obj.DmiInfo[i].strRtlNamePrefix%>.<%=dmi_ce_array[0][idx]%> = 1'b1; 
               @(posedge <%=hier_path_dmi_corr%>.<%=obj.DmiInfo[i].strRtlNamePrefix%>.clk_clk);
               release <%=hier_path_dmi_corr%>.<%=obj.DmiInfo[i].strRtlNamePrefix%>.<%=dmi_ce_array[0][idx]%>;
               `uvm_info("fsys_fault_injector_checker",$sformatf("RELEASING signal <%=hier_path_dmi_corr%>.<%=obj.DmiInfo[i].strRtlNamePrefix%>.<%=dmi_ce_array[0][idx]%> from Forced value='h%0h. Back to Orig value='h%0h",1'b1,<%=hier_path_dmi_corr%>.<%=obj.DmiInfo[i].strRtlNamePrefix%>.<%=dmi_ce_array[0][idx]%>),UVM_LOW)
              end
             end

           <% if(obj.DmiInfo[i].ResilienceInfo.enableUnitDuplication) {  %>
             begin
              if(dup_unit_corr_err_inj) begin 
               repeat(<%=obj.DmiInfo[i].ResilienceInfo.nResiliencyDelay%>) begin
                 @(posedge <%=hier_path_dmi_corr%>.<%=obj.DmiInfo[i].strRtlNamePrefix%>.clk_clk);
               end
               `uvm_info("fsys_fault_injector_checker",$sformatf("Error injection done (FORCE) on signal <%=hier_path_dmi_corr%>.<%=obj.DmiInfo[i].strRtlNamePrefix%>.<%=dmi_dup_ce_array[0][idx]%> Orig value='h%0h, Forced value='h%0h",<%=hier_path_dmi_corr%>.<%=obj.DmiInfo[i].strRtlNamePrefix%>.<%=dmi_dup_ce_array[0][idx]%>,1'b1),UVM_LOW)
               force   <%=hier_path_dmi_corr%>.<%=obj.DmiInfo[i].strRtlNamePrefix%>.<%=dmi_dup_ce_array[0][idx]%> = 1'b1; 
               @(posedge <%=hier_path_dmi_corr%>.<%=obj.DmiInfo[i].strRtlNamePrefix%>.clk_clk);
               release <%=hier_path_dmi_corr%>.<%=obj.DmiInfo[i].strRtlNamePrefix%>.<%=dmi_dup_ce_array[0][idx]%>;
               `uvm_info("fsys_fault_injector_checker",$sformatf("RELEASING signal <%=hier_path_dmi_corr%>.<%=obj.DmiInfo[i].strRtlNamePrefix%>.<%=dmi_dup_ce_array[0][idx]%> from Forced value='h%0h. Back to Orig value='h%0h",1'b1,<%=hier_path_dmi_corr%>.<%=obj.DmiInfo[i].strRtlNamePrefix%>.<%=dmi_dup_ce_array[0][idx]%>),UVM_LOW)
              end
             end
             
           <% } %>
             join
           end // repeat
           reset_fsc_reg();
           expected_dmi_cerr_over_thres_fault_reg[<%=i%>] = 1;
           update_fsc_reg();
         <% } %>
       <% } %>
      end // if(dmi_corr_err_inj) begin

       //DVE  
       if(dve_corr_err_inj) begin
     // #Stimulus.FSYS.FSC_DVE_reach_corr_threshold
       <% for (var i = 0; i<obj.DveInfo.length; i++) { %>
         <% for (var idx = 0; idx< dve_ce_array[0].length; idx++) { %>
           <% if((i==0) && (idx==0)) { %>
           corr_err_inj_test_start_indication = 1;
           uvm_config_db#(int unsigned)::set(null, "", "corr_err_inj_test_start_indication", corr_err_inj_test_start_indication); 
           <% } %>
           injectSingleErr.wait_trigger();
           reset_fsc_reg();
           repeat(<%=hier_path_dut%>.<%=obj.DveInfo[i].strRtlNamePrefix%>.unit.u_csr.dve_res_cerr_threshold+1) begin
             @(posedge <%=hier_path_dut%>.<%=obj.DveInfo[i].strRtlNamePrefix%>.clk_clk);
             fork
             begin
              if(func_unit_corr_err_inj) begin 
               `uvm_info("fsys_fault_injector_checker",$sformatf("Error injection done (FORCE) on signal <%=hier_path_dut%>.<%=obj.DveInfo[i].strRtlNamePrefix%>.<%=dve_ce_array[0][idx]%> Orig value='h%0h, Forced value='h%0h",<%=hier_path_dut%>.<%=obj.DveInfo[i].strRtlNamePrefix%>.<%=dve_ce_array[0][idx]%>,1'b1),UVM_LOW)
               force   <%=hier_path_dut%>.<%=obj.DveInfo[i].strRtlNamePrefix%>.<%=dve_ce_array[0][idx]%> = 1'b1; 
               @(posedge <%=hier_path_dut%>.<%=obj.DveInfo[i].strRtlNamePrefix%>.clk_clk);
               release <%=hier_path_dut%>.<%=obj.DveInfo[i].strRtlNamePrefix%>.<%=dve_ce_array[0][idx]%>;
               `uvm_info("fsys_fault_injector_checker",$sformatf("RELEASING signal <%=hier_path_dut%>.<%=obj.DveInfo[i].strRtlNamePrefix%>.<%=dve_ce_array[0][idx]%> from Forced value='h%0h. Back to Orig value='h%0h",1'b1,<%=hier_path_dut%>.<%=obj.DveInfo[i].strRtlNamePrefix%>.<%=dve_ce_array[0][idx]%>),UVM_LOW)
              end
             end

           <% if(obj.DveInfo[i].ResilienceInfo.enableUnitDuplication) {  %>
             begin
              if(dup_unit_corr_err_inj) begin 
               repeat(<%=obj.DveInfo[i].ResilienceInfo.nResiliencyDelay%>) begin
                 @(posedge <%=hier_path_dut%>.<%=obj.DveInfo[i].strRtlNamePrefix%>.clk_clk);
               end
               `uvm_info("fsys_fault_injector_checker",$sformatf("Error injection done (FORCE) on signal <%=hier_path_dut%>.<%=obj.DveInfo[i].strRtlNamePrefix%>.<%=dve_dup_ce_array[0][idx]%> Orig value='h%0h, Forced value='h%0h",<%=hier_path_dut%>.<%=obj.DveInfo[i].strRtlNamePrefix%>.<%=dve_dup_ce_array[0][idx]%>,1'b1),UVM_LOW)
               force   <%=hier_path_dut%>.<%=obj.DveInfo[i].strRtlNamePrefix%>.<%=dve_dup_ce_array[0][idx]%> = 1'b1; 
               @(posedge <%=hier_path_dut%>.<%=obj.DveInfo[i].strRtlNamePrefix%>.clk_clk);
               release <%=hier_path_dut%>.<%=obj.DveInfo[i].strRtlNamePrefix%>.<%=dve_dup_ce_array[0][idx]%>;
               `uvm_info("fsys_fault_injector_checker",$sformatf("RELEASING signal <%=hier_path_dut%>.<%=obj.DveInfo[i].strRtlNamePrefix%>.<%=dve_dup_ce_array[0][idx]%> from Forced value='h%0h. Back to Orig value='h%0h",1'b1,<%=hier_path_dut%>.<%=obj.DveInfo[i].strRtlNamePrefix%>.<%=dve_dup_ce_array[0][idx]%>),UVM_LOW)
              end
             end
             
           <% } %>
             join
           end // repeat
           reset_fsc_reg();
           expected_dve_cerr_over_thres_fault_reg[<%=i%>] = 1;
           update_fsc_reg();
         <% } %>
       <% } %>
      end // if(dve_corr_err_inj) begin

       //DCE  
       if(dce_corr_err_inj) begin
        <% var hier_path_dce_corr = ''; %>
     // #Stimulus.FSYS.FSC_DCE_reach_corr_threshold 
       <% for (var i = 0; i<obj.DceInfo.length; i++) { %>
         <% if(obj.DceInfo[i].hierPath && obj.DceInfo[i].hierPath !== '') { 
            hier_path_dce_corr = `${hier_path_dut}.${obj.DceInfo[i].hierPath}`;
          } else {
            hier_path_dce_corr = hier_path_dut; 
         }%>
         <% for (var idx = 0; idx< dce_ce_array[0].length; idx++) { %>
           <% if((i==0) && (idx==0)) { %>
           corr_err_inj_test_start_indication = 1;
           uvm_config_db#(int unsigned)::set(null, "", "corr_err_inj_test_start_indication", corr_err_inj_test_start_indication); 
           <% } %>
           injectSingleErr.wait_trigger();
           reset_fsc_reg();
           <%
           var ASILB  = 0; // (obj.useResiliency & obj.DceInfo[i].ResilienceInfo.enableUnitDuplication) ? 0 : 1;
           var hier_path_dce_csr  = '';
           if (!ASILB) {
             hier_path_dce_csr = 'dce_func_unit.u_csr';
           } else {
             hier_path_dce_csr = 'u_csr';
           }
           %>
           repeat(<%=hier_path_dce_corr%>.<%=obj.DceInfo[i].strRtlNamePrefix%>.<%=hier_path_dce_csr%>.dce_res_cerr_threshold+1) begin
             @(posedge <%=hier_path_dce_corr%>.<%=obj.DceInfo[i].strRtlNamePrefix%>.clk_clk);
             fork
             begin
              if(func_unit_corr_err_inj) begin 
               `uvm_info("fsys_fault_injector_checker",$sformatf("Error injection done (FORCE) on signal <%=hier_path_dce_corr%>.<%=obj.DceInfo[i].strRtlNamePrefix%>.<%=dce_ce_array[0][idx]%> Orig value='h%0h, Forced value='h%0h",<%=hier_path_dce_corr%>.<%=obj.DceInfo[i].strRtlNamePrefix%>.<%=dce_ce_array[0][idx]%>,1'b1),UVM_LOW)
               force   <%=hier_path_dce_corr%>.<%=obj.DceInfo[i].strRtlNamePrefix%>.<%=dce_ce_array[0][idx]%> = 1'b1; 
               @(posedge <%=hier_path_dce_corr%>.<%=obj.DceInfo[i].strRtlNamePrefix%>.clk_clk);
               release <%=hier_path_dce_corr%>.<%=obj.DceInfo[i].strRtlNamePrefix%>.<%=dce_ce_array[0][idx]%>;
               `uvm_info("fsys_fault_injector_checker",$sformatf("RELEASING signal <%=hier_path_dce_corr%>.<%=obj.DceInfo[i].strRtlNamePrefix%>.<%=dce_ce_array[0][idx]%> from Forced value='h%0h. Back to Orig value='h%0h",1'b1,<%=hier_path_dce_corr%>.<%=obj.DceInfo[i].strRtlNamePrefix%>.<%=dce_ce_array[0][idx]%>),UVM_LOW)
              end
             end

           <% if(obj.DceInfo[i].ResilienceInfo.enableUnitDuplication) {  %>
             begin
              if(dup_unit_corr_err_inj) begin 
               repeat(<%=obj.DceInfo[i].ResilienceInfo.nResiliencyDelay%>) begin
                 @(posedge <%=hier_path_dce_corr%>.<%=obj.DceInfo[i].strRtlNamePrefix%>.clk_clk);
               end
               `uvm_info("fsys_fault_injector_checker",$sformatf("Error injection done (FORCE) on signal <%=hier_path_dce_corr%>.<%=obj.DceInfo[i].strRtlNamePrefix%>.<%=dce_dup_ce_array[0][idx]%> Orig value='h%0h, Forced value='h%0h",<%=hier_path_dce_corr%>.<%=obj.DceInfo[i].strRtlNamePrefix%>.<%=dce_dup_ce_array[0][idx]%>,1'b1),UVM_LOW)
               force   <%=hier_path_dce_corr%>.<%=obj.DceInfo[i].strRtlNamePrefix%>.<%=dce_dup_ce_array[0][idx]%> = 1'b1; 
               @(posedge <%=hier_path_dce_corr%>.<%=obj.DceInfo[i].strRtlNamePrefix%>.clk_clk);
               release <%=hier_path_dce_corr%>.<%=obj.DceInfo[i].strRtlNamePrefix%>.<%=dce_dup_ce_array[0][idx]%>;
               `uvm_info("fsys_fault_injector_checker",$sformatf("RELEASING signal <%=hier_path_dce_corr%>.<%=obj.DceInfo[i].strRtlNamePrefix%>.<%=dce_dup_ce_array[0][idx]%> from Forced value='h%0h. Back to Orig value='h%0h",1'b1,<%=hier_path_dce_corr%>.<%=obj.DceInfo[i].strRtlNamePrefix%>.<%=dce_dup_ce_array[0][idx]%>),UVM_LOW)
              end
             end
             
           <% } %>
             join
           end // repeat
           reset_fsc_reg();
           expected_dce_cerr_over_thres_fault_reg[<%=i%>] = 1;
           update_fsc_reg();
         <% } %>
       <% } %>
      end // if(dce_corr_err_inj) begin

       //DII  
       if(dii_corr_err_inj) begin
     // #Stimulus.FSYS.FSC_DII_reach_corr_threshold 
       <% for (var i = 0; i<obj.DiiInfo.length; i++) { %>
         <% for (var idx = 0; idx< dii_ce_array[0].length; idx++) { %>
           <% if((i==0) && (idx==0)) { %>
           corr_err_inj_test_start_indication = 1;
           uvm_config_db#(int unsigned)::set(null, "", "corr_err_inj_test_start_indication", corr_err_inj_test_start_indication); 
           <% } %>
           injectSingleErr.wait_trigger();
           reset_fsc_reg();
           repeat(<%=hier_path_dut%>.<%=obj.DiiInfo[i].strRtlNamePrefix%>.u_dii_unit.dii_csr.DIIUCRTR_ResThreshold_out+1) begin
             @(posedge <%=hier_path_dut%>.<%=obj.DiiInfo[i].strRtlNamePrefix%>.clk_clk);
             fork
             begin
              if(func_unit_corr_err_inj) begin 
               `uvm_info("fsys_fault_injector_checker",$sformatf("Error injection done (FORCE) on signal <%=hier_path_dut%>.<%=obj.DiiInfo[i].strRtlNamePrefix%>.<%=dii_ce_array[0][idx]%> Orig value='h%0h, Forced value='h%0h",<%=hier_path_dut%>.<%=obj.DiiInfo[i].strRtlNamePrefix%>.<%=dii_ce_array[0][idx]%>,1'b1),UVM_LOW)
               force   <%=hier_path_dut%>.<%=obj.DiiInfo[i].strRtlNamePrefix%>.<%=dii_ce_array[0][idx]%> = 1'b1; 
               @(posedge <%=hier_path_dut%>.<%=obj.DiiInfo[i].strRtlNamePrefix%>.clk_clk);
               release <%=hier_path_dut%>.<%=obj.DiiInfo[i].strRtlNamePrefix%>.<%=dii_ce_array[0][idx]%>;
               `uvm_info("fsys_fault_injector_checker",$sformatf("RELEASING signal <%=hier_path_dut%>.<%=obj.DiiInfo[i].strRtlNamePrefix%>.<%=dii_ce_array[0][idx]%> from Forced value='h%0h. Back to Orig value='h%0h",1'b1,<%=hier_path_dut%>.<%=obj.DiiInfo[i].strRtlNamePrefix%>.<%=dii_ce_array[0][idx]%>),UVM_LOW)
              end
             end

           <% if(obj.DiiInfo[i].ResilienceInfo.enableUnitDuplication) {  %>
             begin
              if(dup_unit_corr_err_inj) begin 
               repeat(<%=obj.DiiInfo[i].ResilienceInfo.nResiliencyDelay%>) begin
                 @(posedge <%=hier_path_dut%>.<%=obj.DiiInfo[i].strRtlNamePrefix%>.clk_clk);
               end
               `uvm_info("fsys_fault_injector_checker",$sformatf("Error injection done (FORCE) on signal <%=hier_path_dut%>.<%=obj.DiiInfo[i].strRtlNamePrefix%>.<%=dii_dup_ce_array[0][idx]%> Orig value='h%0h, Forced value='h%0h",<%=hier_path_dut%>.<%=obj.DiiInfo[i].strRtlNamePrefix%>.<%=dii_dup_ce_array[0][idx]%>,1'b1),UVM_LOW)
               force   <%=hier_path_dut%>.<%=obj.DiiInfo[i].strRtlNamePrefix%>.<%=dii_dup_ce_array[0][idx]%> = 1'b1; 
               @(posedge <%=hier_path_dut%>.<%=obj.DiiInfo[i].strRtlNamePrefix%>.clk_clk);
               release <%=hier_path_dut%>.<%=obj.DiiInfo[i].strRtlNamePrefix%>.<%=dii_dup_ce_array[0][idx]%>;
               `uvm_info("fsys_fault_injector_checker",$sformatf("RELEASING signal <%=hier_path_dut%>.<%=obj.DiiInfo[i].strRtlNamePrefix%>.<%=dii_dup_ce_array[0][idx]%> from Forced value='h%0h. Back to Orig value='h%0h",1'b1,<%=hier_path_dut%>.<%=obj.DiiInfo[i].strRtlNamePrefix%>.<%=dii_dup_ce_array[0][idx]%>),UVM_LOW)
              end
             end
             
           <% } %>
             join
           end // repeat
           reset_fsc_reg();
           expected_dii_cerr_over_thres_fault_reg[<%=i%>] = 1;
           update_fsc_reg();
         <% } %>
       <% } %>
      end // if(dii_corr_err_inj) begin

       //CHIAIU
       if(chiaiu_corr_err_inj) begin
     // #Stimulus.FSYS.FSC_CHI_reach_corr_threshold 
       <% var chiaiu_index = 0;
       for (var i = 0; i<obj.AiuInfo.length; i++) { %>
       <% if ((obj.AiuInfo[i].fnNativeInterface == "CHI-A") || (obj.AiuInfo[i].fnNativeInterface == "CHI-B") || (obj.AiuInfo[i].fnNativeInterface == "CHI-E")) { %>
         <% for (var idx = 0; idx< chi_aiu_ce_array[0].length; idx++) { %>
           <% if((i==0) && (idx==0)) { %>
           corr_err_inj_test_start_indication = 1;
           uvm_config_db#(int unsigned)::set(null, "", "corr_err_inj_test_start_indication", corr_err_inj_test_start_indication); 
           <% } %>
           injectSingleErr.wait_trigger();
           reset_fsc_reg();
           repeat(<%=hier_path_dut%>.<%=obj.AiuInfo[i].strRtlNamePrefix%>.unit.chi_aiu_csr.CAIUCRTR_ResThreshold_out+1) begin
             @(posedge <%=hier_path_dut%>.<%=obj.AiuInfo[i].strRtlNamePrefix%>.clk_clk);
             fork
             begin
              if(func_unit_corr_err_inj) begin 
               `uvm_info("fsys_fault_injector_checker",$sformatf("Error injection done (FORCE) on signal <%=hier_path_dut%>.<%=obj.AiuInfo[i].strRtlNamePrefix%>.<%=chi_aiu_ce_array[0][idx]%> Orig value='h%0h, Forced value='h%0h",<%=hier_path_dut%>.<%=obj.AiuInfo[i].strRtlNamePrefix%>.<%=chi_aiu_ce_array[0][idx]%>,1'b1),UVM_LOW)
               force   <%=hier_path_dut%>.<%=obj.AiuInfo[i].strRtlNamePrefix%>.<%=chi_aiu_ce_array[0][idx]%> = 1'b1; 
               @(posedge <%=hier_path_dut%>.<%=obj.AiuInfo[i].strRtlNamePrefix%>.clk_clk);
               release <%=hier_path_dut%>.<%=obj.AiuInfo[i].strRtlNamePrefix%>.<%=chi_aiu_ce_array[0][idx]%>;
               `uvm_info("fsys_fault_injector_checker",$sformatf("RELEASING signal <%=hier_path_dut%>.<%=obj.AiuInfo[i].strRtlNamePrefix%>.<%=chi_aiu_ce_array[0][idx]%> from Forced value='h%0h. Back to Orig value='h%0h",1'b1,<%=hier_path_dut%>.<%=obj.AiuInfo[i].strRtlNamePrefix%>.<%=chi_aiu_ce_array[0][idx]%>),UVM_LOW)
              end
             end

           <% if(obj.AiuInfo[i].ResilienceInfo.enableUnitDuplication) {  %>
             begin
              if(dup_unit_corr_err_inj) begin 
               repeat(<%=obj.AiuInfo[i].ResilienceInfo.nResiliencyDelay%>) begin
                 @(posedge <%=hier_path_dut%>.<%=obj.AiuInfo[i].strRtlNamePrefix%>.clk_clk);
               end
               `uvm_info("fsys_fault_injector_checker",$sformatf("Error injection done (FORCE) on signal <%=hier_path_dut%>.<%=obj.AiuInfo[i].strRtlNamePrefix%>.<%=chi_aiu_dup_ce_array[0][idx]%> Orig value='h%0h, Forced value='h%0h",<%=hier_path_dut%>.<%=obj.AiuInfo[i].strRtlNamePrefix%>.<%=chi_aiu_dup_ce_array[0][idx]%>,1'b1),UVM_LOW)
               force   <%=hier_path_dut%>.<%=obj.AiuInfo[i].strRtlNamePrefix%>.<%=chi_aiu_dup_ce_array[0][idx]%> = 1'b1; 
               @(posedge <%=hier_path_dut%>.<%=obj.AiuInfo[i].strRtlNamePrefix%>.clk_clk);
               release <%=hier_path_dut%>.<%=obj.AiuInfo[i].strRtlNamePrefix%>.<%=chi_aiu_dup_ce_array[0][idx]%>;
               `uvm_info("fsys_fault_injector_checker",$sformatf("RELEASING signal <%=hier_path_dut%>.<%=obj.AiuInfo[i].strRtlNamePrefix%>.<%=chi_aiu_dup_ce_array[0][idx]%> from Forced value='h%0h. Back to Orig value='h%0h",1'b1,<%=hier_path_dut%>.<%=obj.AiuInfo[i].strRtlNamePrefix%>.<%=chi_aiu_dup_ce_array[0][idx]%>),UVM_LOW)
              end
             end
             
           <% } %>
             join
           end // repeat
           reset_fsc_reg();
           expected_caiu_cerr_over_thres_fault_reg[<%=chiaiu_index%>] = 1;
           update_fsc_reg();
         <% } %>
        <% chiaiu_index = chiaiu_index + 1;} %>
       <% } %>
      end // if(chiaiu_corr_err_inj) begin

       //IOAIU
       if(ioaiu_corr_err_inj) begin
     // #Stimulus.FSYS.FSC_IO_reach_corr_threshold 
       <% var ioaiu_index = 0;
       for (var i = 0; i<obj.AiuInfo.length; i++) { %>
       <% if ((obj.AiuInfo[i].fnNativeInterface != "CHI-A") && (obj.AiuInfo[i].fnNativeInterface != "CHI-B")  && (obj.AiuInfo[i].fnNativeInterface != "CHI-E")) { %>
       <%   
       var ioaiu_ce_array_num = 0;
          if(obj.AiuInfo[i].fnNativeInterface == "ACE" || obj.AiuInfo[i].fnNativeInterface == "ACE5") { ioaiu_ce_array_num = 0;}
          else if(obj.AiuInfo[i].fnNativeInterface == "ACELITE-E") { 
              if(obj.AiuInfo[i].interfaces.axiInt.eAc>0) {
                ioaiu_ce_array_num = 1;
              } else {
                ioaiu_ce_array_num = 5;
              }
          }
          else if(obj.AiuInfo[i].fnNativeInterface == "ACE-LITE") { ioaiu_ce_array_num = 2;}
          else if(((obj.AiuInfo[i].fnNativeInterface == "AXI4") || (obj.AiuInfo[i].fnNativeInterface == "AXI5")) && (obj.AiuInfo[i].useCache==0)) { ioaiu_ce_array_num = 3;}
          else if(((obj.AiuInfo[i].fnNativeInterface == "AXI4")  || (obj.AiuInfo[i].fnNativeInterface == "AXI5")) && (obj.AiuInfo[i].useCache==1)) { ioaiu_ce_array_num = 4;}
       %>  
         <% for (var idx = 0; idx< ioaiu_ce_array[ioaiu_ce_array_num].length; idx++) { %>
           <% if(idx==0) { %>
           corr_err_inj_test_start_indication = 1;
           uvm_config_db#(int unsigned)::set(null, "", "corr_err_inj_test_start_indication", corr_err_inj_test_start_indication); 
           <% } %>
           injectSingleErr.wait_trigger();
           reset_fsc_reg();
           repeat(<%=hier_path_dut%>.<%=obj.AiuInfo[i].strRtlNamePrefix%>.ioaiu_core_wrapper.ioaiu_core0.apb_csr.XAIUCRTR_ResThreshold_out+1) begin
             @(posedge <%=hier_path_dut%>.<%=obj.AiuInfo[i].strRtlNamePrefix%>.clk_clk);
             fork
             begin
              if(func_unit_corr_err_inj) begin 
               `uvm_info("fsys_fault_injector_checker",$sformatf("Error injection done (FORCE) on signal <%=hier_path_dut%>.<%=obj.AiuInfo[i].strRtlNamePrefix%>.<%=ioaiu_ce_array[ioaiu_ce_array_num][idx]%> Orig value='h%0h, Forced value='h%0h",<%=hier_path_dut%>.<%=obj.AiuInfo[i].strRtlNamePrefix%>.<%=ioaiu_ce_array[ioaiu_ce_array_num][idx]%>,1'b1),UVM_LOW)
               force   <%=hier_path_dut%>.<%=obj.AiuInfo[i].strRtlNamePrefix%>.<%=ioaiu_ce_array[ioaiu_ce_array_num][idx]%> = 1'b1; 
               @(posedge <%=hier_path_dut%>.<%=obj.AiuInfo[i].strRtlNamePrefix%>.clk_clk);
               release <%=hier_path_dut%>.<%=obj.AiuInfo[i].strRtlNamePrefix%>.<%=ioaiu_ce_array[ioaiu_ce_array_num][idx]%>;
               `uvm_info("fsys_fault_injector_checker",$sformatf("RELEASING signal <%=hier_path_dut%>.<%=obj.AiuInfo[i].strRtlNamePrefix%>.<%=ioaiu_ce_array[ioaiu_ce_array_num][idx]%> from Forced value='h%0h. Back to Orig value='h%0h",1'b1,<%=hier_path_dut%>.<%=obj.AiuInfo[i].strRtlNamePrefix%>.<%=ioaiu_ce_array[ioaiu_ce_array_num][idx]%>),UVM_LOW)
              end
             end

           <% if(obj.AiuInfo[i].ResilienceInfo.enableUnitDuplication) {  %>
             begin
              if(dup_unit_corr_err_inj) begin 
               repeat(<%=obj.AiuInfo[i].ResilienceInfo.nResiliencyDelay%>) begin
                 @(posedge <%=hier_path_dut%>.<%=obj.AiuInfo[i].strRtlNamePrefix%>.clk_clk);
               end
               `uvm_info("fsys_fault_injector_checker",$sformatf("Error injection done (FORCE) on signal <%=hier_path_dut%>.<%=obj.AiuInfo[i].strRtlNamePrefix%>.<%=ioaiu_dup_ce_array[ioaiu_ce_array_num][idx]%> Orig value='h%0h, Forced value='h%0h",<%=hier_path_dut%>.<%=obj.AiuInfo[i].strRtlNamePrefix%>.<%=ioaiu_dup_ce_array[ioaiu_ce_array_num][idx]%>,1'b1),UVM_LOW)
               force   <%=hier_path_dut%>.<%=obj.AiuInfo[i].strRtlNamePrefix%>.<%=ioaiu_dup_ce_array[ioaiu_ce_array_num][idx]%> = 1'b1; 
               @(posedge <%=hier_path_dut%>.<%=obj.AiuInfo[i].strRtlNamePrefix%>.clk_clk);
               release <%=hier_path_dut%>.<%=obj.AiuInfo[i].strRtlNamePrefix%>.<%=ioaiu_dup_ce_array[ioaiu_ce_array_num][idx]%>;
               `uvm_info("fsys_fault_injector_checker",$sformatf("RELEASING signal <%=hier_path_dut%>.<%=obj.AiuInfo[i].strRtlNamePrefix%>.<%=ioaiu_dup_ce_array[ioaiu_ce_array_num][idx]%> from Forced value='h%0h. Back to Orig value='h%0h",1'b1,<%=hier_path_dut%>.<%=obj.AiuInfo[i].strRtlNamePrefix%>.<%=ioaiu_dup_ce_array[ioaiu_ce_array_num][idx]%>),UVM_LOW)
              end
             end
             
           <% } %>
             join
           end // repeat
           reset_fsc_reg();
           expected_ioaiu_cerr_over_thres_fault_reg[<%=ioaiu_index%>] = 1;
           update_fsc_reg();
         <% } %>
        <% ioaiu_index = ioaiu_index+1; } %>
       <% } %>
      end // if(ioaiu_corr_err_inj) begin

    end // if($test$plusargs("fsc_inject_correctable_err")) begin
    //corr_err_inj_test_start_indication = 0;
    //uvm_config_db#(int unsigned)::set(null, "", "corr_err_inj_test_start_indication", corr_err_inj_test_start_indication); 
  end
   
    task start_automatic_bist();
      bit[31:0]  read_data;
      //writting SCBISTCR to enable bist seq.
      @(posedge tb_clk);
      force tb_top.m_apb_fsc.paddr  = 'h0; //SCBISTCR addr is 'h0
      force tb_top.m_apb_fsc.pwdata = 'h1; //Writing 0th location to start automatic seq                
      force tb_top.m_apb_fsc.pwrite = 'b1;                 
      force tb_top.m_apb_fsc.psel   = 'b1;                  
      @(posedge tb_clk);
      force tb_top.m_apb_fsc.penable  = 'b1;  
      wait(tb_top.m_apb_fsc.pready);        
      @(posedge tb_clk);
      if(tb_top.m_apb_fsc.pslverr) begin
        `uvm_error("Bist sequence",$sformatf("Something went wrong while writing SCBISTCR Reg"));
      end  
      force tb_top.m_apb_fsc.psel     = 'b0;                  
      force tb_top.m_apb_fsc.penable  = 'b0;  
      `uvm_info("fsys_fault_injector_checker",$sformatf("Automatic Bist seq register writing complete. "),UVM_LOW);

       //Reading SCBISTAR register to check status. 
      repeat(100)@(posedge tb_clk);      //Wait for Bist seq to complete
      force tb_top.m_apb_fsc.paddr  = 'h4; //SCBISTAR addr is 'h4
      force tb_top.m_apb_fsc.pwrite = 'b0;                 
      force tb_top.m_apb_fsc.psel   = 'b1;                  
      @(posedge tb_clk);
      force tb_top.m_apb_fsc.penable  = 'b1;  
      wait(tb_top.m_apb_fsc.pready); 
      read_data = tb_top.m_apb_fsc.prdata;       
      `uvm_info("fsys_fault_injector_checker",$sformatf("SCBISTAR read data %0h",read_data),UVM_LOW);
       if(read_data[9:5] != 0) begin
        `uvm_error("Bist sequence",$sformatf("Error detected in Bist seq, SCBISTAR Reg %0h",read_data[9:5]));
       end
      @(posedge tb_clk);
      force tb_top.m_apb_fsc.psel     = 'b0;                  
      force tb_top.m_apb_fsc.penable  = 'b0;  
      release  tb_top.m_apb_fsc.paddr;
      release  tb_top.m_apb_fsc.pwdata;                
      release  tb_top.m_apb_fsc.pwrite;                 
      release  tb_top.m_apb_fsc.psel; 
      release  tb_top.m_apb_fsc.penable;  
    endtask : start_automatic_bist 

    // #Check.FSYS.FSC.Exp_And_Compare_Faults
    function expFaults(input output_signal, input bit t_enable_unit_duplication, bit t_func_unit_uncorr_err_inj, bit t_dup_unit_uncorr_err_inj, output bit t_expected_mission_fault, output bit t_expected_latent_fault);
      if(output_signal==0) begin
        if(t_enable_unit_duplication) begin
           case({t_func_unit_uncorr_err_inj,t_dup_unit_uncorr_err_inj})
           0 : begin
               t_expected_mission_fault= 0; t_expected_latent_fault = 0;
           end
           1 : begin
               t_expected_mission_fault= 1; t_expected_latent_fault = 0;
           end
           2 : begin
               t_expected_mission_fault= 1; t_expected_latent_fault = 0;
           end
           3 : begin
               t_expected_mission_fault= 1; t_expected_latent_fault = 0;
           end
           endcase
         end else begin
           t_expected_mission_fault= t_func_unit_uncorr_err_inj? 1 : 0; t_expected_latent_fault = 0;
         end
       end else begin
           t_expected_mission_fault= 1; t_expected_latent_fault = 0;
       end
    endfunction : expFaults

    function compareFaults(string input_message,string hierach_path, input bit t_expected_mission_fault, input bit t_expected_latent_fault, input bit t_actual_mission_fault, input bit t_actual_latent_fault);
           if((t_expected_mission_fault !=  t_actual_mission_fault) || (t_expected_latent_fault != t_actual_latent_fault)) begin
               if(t_expected_mission_fault !=  t_actual_mission_fault)
                   `uvm_info("fsys_fault_injector_checker",$sformatf("%0s Mission fault mismatch. Exp=%0d Act=%0d",hierach_path,t_expected_mission_fault,t_actual_mission_fault),UVM_LOW)
               if(t_expected_latent_fault!=  t_actual_latent_fault)
                   `uvm_info("fsys_fault_injector_checker",$sformatf("%0s Latent fault mismatch. Exp=%0d Act=%0d",hierach_path,t_expected_latent_fault,t_actual_latent_fault),UVM_LOW)
               if(bypass_fsys_fault_inject_reg_check_error) `uvm_info("fsys_fault_injector_checker",$sformatf("Fault mismatch observed for %0s. %0s",hierach_path,input_message),UVM_LOW)
               else `uvm_error("fsys_fault_injector_checker",$sformatf("Fault mismatch observed for %0s. %0s",hierach_path,input_message))
           end else begin
               `uvm_info("fsys_fault_injector_checker",$sformatf("No issue with Fault observed for %0s. %0s",hierach_path,input_message),UVM_LOW)
           end
    endfunction : compareFaults

     string reg_print="";
    function update_fsc_reg();
        reg_print="";
        //expected_mission_fault_reg = {{128-<%=total_ncore_units%>{1'b0}},expected_dce_mission_fault_reg,expected_dve_mission_fault_reg,expected_dii_mission_fault_reg,expected_dmi_mission_fault_reg,expected_aiu_mission_fault_reg};
        //expected_latent_fault_reg  = {{128-<%=total_ncore_units%>{1'b0}},expected_dce_latent_fault_reg,expected_dve_latent_fault_reg,expected_dii_latent_fault_reg,expected_dmi_latent_fault_reg,expected_aiu_latent_fault_reg};
        //expected_cerr_over_thres_fault_reg = {{128-<%=total_ncore_units%>{1'b0}},expected_dce_cerr_over_thres_fault_reg,expected_dve_cerr_over_thres_fault_reg,expected_dii_cerr_over_thres_fault_reg,expected_dmi_cerr_over_thres_fault_reg,expected_aiu_cerr_over_thres_fault_reg};
        expected_mission_fault_reg[31:0]     = {{32-$bits(expected_caiu_mission_fault_reg){1'b0}},expected_caiu_mission_fault_reg};
        expected_mission_fault_reg[63:32]    = {{32-$bits(expected_ioaiu_mission_fault_reg){1'b0}},expected_ioaiu_mission_fault_reg};
        expected_mission_fault_reg[95:64]    = {{32-$bits(expected_dmi_mission_fault_reg){1'b0}},expected_dmi_mission_fault_reg};
        expected_mission_fault_reg[127:96]   = {{32-$bits(expected_dii_mission_fault_reg){1'b0}},expected_dii_mission_fault_reg};
        expected_mission_fault_reg[143:128]  = {{16-$bits(expected_dce_mission_fault_reg){1'b0}},expected_dce_mission_fault_reg};
        expected_mission_fault_reg[158:144]  = 15'b0;
        expected_mission_fault_reg[159]      = expected_dve_mission_fault_reg;
        expected_latent_fault_reg [31:0]    = {{32-$bits(expected_caiu_latent_fault_reg){1'b0}},expected_caiu_latent_fault_reg};
        expected_latent_fault_reg [63:32]   = {{32-$bits(expected_ioaiu_latent_fault_reg){1'b0}},expected_ioaiu_latent_fault_reg};
        expected_latent_fault_reg [95:64]   = {{32-$bits(expected_dmi_latent_fault_reg){1'b0}},expected_dmi_latent_fault_reg};
        expected_latent_fault_reg [127:96]  = {{32-$bits(expected_dii_latent_fault_reg){1'b0}},expected_dii_latent_fault_reg};
        expected_latent_fault_reg [143:128] = {{16-$bits(expected_dce_latent_fault_reg){1'b0}},expected_dce_latent_fault_reg};
        expected_latent_fault_reg [158:144] = 15'b0;
        expected_latent_fault_reg [159]     = expected_dve_latent_fault_reg;
        expected_cerr_over_thres_fault_reg [31:0]   = {{32-$bits(expected_caiu_cerr_over_thres_fault_reg){1'b0}},expected_caiu_cerr_over_thres_fault_reg};
        expected_cerr_over_thres_fault_reg [63:32]  = {{32-$bits(expected_ioaiu_cerr_over_thres_fault_reg){1'b0}},expected_ioaiu_cerr_over_thres_fault_reg};
        expected_cerr_over_thres_fault_reg [95:64]  = {{32-$bits(expected_dmi_cerr_over_thres_fault_reg){1'b0}},expected_dmi_cerr_over_thres_fault_reg};
        expected_cerr_over_thres_fault_reg [127:96] = {{32-$bits(expected_dii_cerr_over_thres_fault_reg){1'b0}},expected_dii_cerr_over_thres_fault_reg};
        expected_cerr_over_thres_fault_reg [143:128]= {{16-$bits(expected_dce_cerr_over_thres_fault_reg){1'b0}},expected_dce_cerr_over_thres_fault_reg};
        expected_cerr_over_thres_fault_reg [158:144]= 15'b0;
        expected_cerr_over_thres_fault_reg [159]    = expected_dve_cerr_over_thres_fault_reg;
        FSCERRR                     = 0;
        SCLFX0_latent_fault         = expected_latent_fault_reg[31:0];
        SCLFX1_latent_fault         = expected_latent_fault_reg[63:32];
        SCLFX2_latent_fault         = expected_latent_fault_reg[95:64];
        SCLFX3_latent_fault         = expected_latent_fault_reg[127:96];
        SCLFX4_latent_fault         = expected_latent_fault_reg[159:128];
        reg_print = $sformatf("%0s SCLFX0_latent_fault=0x%8h\n",reg_print,SCLFX0_latent_fault);
        reg_print = $sformatf("%0s SCLFX1_latent_fault=0x%8h\n",reg_print,SCLFX1_latent_fault);
        reg_print = $sformatf("%0s SCLFX2_latent_fault=0x%8h\n",reg_print,SCLFX2_latent_fault);
        reg_print = $sformatf("%0s SCLFX3_latent_fault=0x%8h\n",reg_print,SCLFX3_latent_fault);
        reg_print = $sformatf("%0s SCLFX4_latent_fault=0x%8h\n",reg_print,SCLFX4_latent_fault);
       
        SCMFX0_mission_fault        = expected_mission_fault_reg[31:0];
        SCMFX1_mission_fault        = expected_mission_fault_reg[63:32];
        SCMFX2_mission_fault        = expected_mission_fault_reg[95:64];
        SCMFX3_mission_fault        = expected_mission_fault_reg[127:96];
        SCMFX4_mission_fault        = expected_mission_fault_reg[159:128];
        reg_print = $sformatf("%0s SCMFX0_mission_fault=0x%8h\n",reg_print,SCMFX0_mission_fault);
        reg_print = $sformatf("%0s SCMFX1_mission_fault=0x%8h\n",reg_print,SCMFX1_mission_fault);
        reg_print = $sformatf("%0s SCMFX2_mission_fault=0x%8h\n",reg_print,SCMFX2_mission_fault);
        reg_print = $sformatf("%0s SCMFX3_mission_fault=0x%8h\n",reg_print,SCMFX3_mission_fault);
        reg_print = $sformatf("%0s SCMFX4_mission_fault=0x%8h\n",reg_print,SCMFX4_mission_fault);

        SCCETHF0      = expected_cerr_over_thres_fault_reg[31:0];
        SCCETHF1      = expected_cerr_over_thres_fault_reg[63:32];
        SCCETHF2      = expected_cerr_over_thres_fault_reg[95:64];
        SCCETHF3      = expected_cerr_over_thres_fault_reg[127:96];
        SCCETHF4      = expected_cerr_over_thres_fault_reg[159:128];
        reg_print = $sformatf("%0s SCCETHF0=0x%8h\n",reg_print,SCCETHF0);
        reg_print = $sformatf("%0s SCCETHF1=0x%8h\n",reg_print,SCCETHF1);
        reg_print = $sformatf("%0s SCCETHF2=0x%8h\n",reg_print,SCCETHF2);
        reg_print = $sformatf("%0s SCCETHF3=0x%8h\n",reg_print,SCCETHF3);
        reg_print = $sformatf("%0s SCCETHF4=0x%8h\n",reg_print,SCCETHF4);

        uvm_config_db#(int unsigned)::set(null, "", "FSCERRR", FSCERRR); 

        uvm_config_db#(int unsigned)::set(null, "", "SCLFX0_latent_fault", SCLFX0_latent_fault); 
        uvm_config_db#(int unsigned)::set(null, "", "SCLFX1_latent_fault", SCLFX1_latent_fault); 
        uvm_config_db#(int unsigned)::set(null, "", "SCLFX2_latent_fault", SCLFX2_latent_fault); 
        uvm_config_db#(int unsigned)::set(null, "", "SCLFX3_latent_fault", SCLFX3_latent_fault); 
        uvm_config_db#(int unsigned)::set(null, "", "SCLFX4_latent_fault", SCLFX4_latent_fault); 

        uvm_config_db#(int unsigned)::set(null, "", "SCMFX0_mission_fault",SCMFX0_mission_fault ); 
        uvm_config_db#(int unsigned)::set(null, "", "SCMFX1_mission_fault",SCMFX1_mission_fault ); 
        uvm_config_db#(int unsigned)::set(null, "", "SCMFX2_mission_fault",SCMFX2_mission_fault ); 
        uvm_config_db#(int unsigned)::set(null, "", "SCMFX3_mission_fault",SCMFX3_mission_fault ); 
        uvm_config_db#(int unsigned)::set(null, "", "SCMFX4_mission_fault",SCMFX4_mission_fault ); 

        uvm_config_db#(int unsigned)::set(null, "", "SCCETHF0", SCCETHF0); 
        uvm_config_db#(int unsigned)::set(null, "", "SCCETHF1", SCCETHF1); 
        uvm_config_db#(int unsigned)::set(null, "", "SCCETHF2", SCCETHF2); 
        uvm_config_db#(int unsigned)::set(null, "", "SCCETHF3", SCCETHF3); 
        uvm_config_db#(int unsigned)::set(null, "", "SCCETHF4", SCCETHF4); 

        `uvm_info("fsys_fault_injector_checker",$sformatf("%0s",reg_print),UVM_LOW)
    endfunction

    function reset_fsc_reg();
        FSCERRR                     = 0;
     
        SCLFX0_latent_fault         = 0;
        SCLFX1_latent_fault         = 0;
        SCLFX2_latent_fault         = 0;
        SCLFX3_latent_fault         = 0;
        SCLFX4_latent_fault         = 0;

        SCMFX0_mission_fault        = 0;
        SCMFX1_mission_fault        = 0;
        SCMFX2_mission_fault        = 0;
        SCMFX3_mission_fault        = 0;
        SCMFX4_mission_fault        = 0;

        SCCETHF0  = 0;
        SCCETHF1  = 0;
        SCCETHF2  = 0;
        SCCETHF3  = 0;
        SCCETHF4  = 0;
        
        expected_latent_fault_reg  = 0;
        expected_mission_fault_reg = 0;
        expected_cerr_over_thres_fault_reg = 0;

        expected_caiu_mission_fault_reg=0; expected_caiu_latent_fault_reg=0;  expected_caiu_cerr_over_thres_fault_reg=0;
        expected_ioaiu_mission_fault_reg=0; expected_ioaiu_latent_fault_reg=0;  expected_ioaiu_cerr_over_thres_fault_reg=0;
        expected_dmi_mission_fault_reg=0; expected_dmi_latent_fault_reg=0;  expected_dmi_cerr_over_thres_fault_reg=0;
        expected_dii_mission_fault_reg=0; expected_dii_latent_fault_reg=0;  expected_dii_cerr_over_thres_fault_reg=0;
        expected_dve_mission_fault_reg=0; expected_dve_latent_fault_reg=0;  expected_dve_cerr_over_thres_fault_reg=0;
        expected_dce_mission_fault_reg=0; expected_dce_latent_fault_reg=0;  expected_dce_cerr_over_thres_fault_reg=0;

    endfunction

    function signal_invalid_value_check(input signal_name, input logic [1023:0] signal);
        if((signal==='hX) || (signal==='hx) || (signal==='hZ) || (signal==='hz)) begin
            if(bypass_signal_invalid_value_check==1)
                `uvm_info("fsys_fault_injector_checker",$sformatf("Invalid value=%0h is found for signal %0s",signal_name,signal),UVM_LOW)
            else
                `uvm_error("fsys_fault_injector_checker",$sformatf("Invalid value=%0h is found for signal %0s",signal_name,signal))
        end
    endfunction
 endmodule: fsys_fault_injector_checker

<% } %>
`endif
