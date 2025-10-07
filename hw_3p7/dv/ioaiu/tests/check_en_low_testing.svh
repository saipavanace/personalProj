//#Check.IOAIU.Parity.Err.Chk_En_Off
<% var ioaiu_unit_outputs_array=  []; %>
<%{var ioaiu_unit_outputs_array  = ['aw_valid_chk','w_valid_chk','b_ready_chk','ar_valid_chk','r_ready_chk','aw_id_chk','aw_addr_chk','aw_len_chk','aw_ctl_chk0','aw_ctl_chk1','aw_ctl_chk3','aw_user_chk','w_data_chk','w_strb_chk','w_last_chk','ar_id_chk','ar_addr_chk','ar_len_chk','ar_ctl_chk0','ar_ctl_chk1','ar_user_chk'];
if (obj.DutInfo.fnNativeInterface === "ACE5") {
  let nameToRemove = 'aw_ctl_chk3';
  let index = ioaiu_unit_outputs_array.indexOf(nameToRemove);

  if (index !== -1) {
  ioaiu_unit_outputs_array.splice(index, 1);
  }
  ioaiu_unit_outputs_array = ioaiu_unit_outputs_array.concat([
    'ac_ready_chk', 'cr_valid_chk', 'cd_valid_chk', 'w_ack_chk', 'r_ack_chk','cr_resp_chk','cd_data_chk','cd_last_chk','aw_ctl_chk2','ar_ctl_chk3','ar_ctl_chk2'
  ]);
}
if(obj.DutInfo.fnNativeInterface == "ACELITE-E" && obj.DutInfo.interfaces.axiInt.params.eAc == 1){
ioaiu_unit_outputs_array = ioaiu_unit_outputs_array.concat([
    'ac_ready_chk', 'cr_valid_chk','aw_stashnid_chk','aw_stashlpid_chk','aw_trace_chk','w_trace_chk','ar_trace_chk','cr_trace_chk','cr_resp_chk','ar_ctl_chk3','aw_ctl_chk2','ar_ctl_chk2'
  ]);
   }
   if(obj.DutInfo.fnNativeInterface == "ACELITE-E" ){
ioaiu_unit_outputs_array = ioaiu_unit_outputs_array.concat([
    'aw_stashnid_chk','aw_stashlpid_chk','aw_trace_chk','w_trace_chk','ar_trace_chk','aw_ctl_chk2','ar_ctl_chk2'
  ]);
   }
if(obj?.DutInfo?.interfaces?.axiInt?.params?.wWUser != null && obj.DutInfo.interfaces.axiInt.params.wWUser != 0){
ioaiu_unit_outputs_array = ioaiu_unit_outputs_array.concat([
   'w_user_chk' 
  ]);
}   
}%>
<%if(obj.DutInfo.nNativeInterfacePorts == 1){%>
module check_en_low_testing(input aclk,arst_n);

  uvm_event wait_for_chk_en_test;
  uvm_event ev_default_seq_en_test;

  initial begin
    ev_default_seq_en_test = uvm_event_pool::get_global("ev_default_seq_en_test");
    ev_default_seq_en_test.wait_trigger();
    if($test$plusargs("check_enable_low_parity_test"))begin
    wait_for_chk_en_test = uvm_event_pool::get_global("wait_for_chk_en_test"); 
     //@(posedge arst_n);
     <%for(var idx=0; idx< ioaiu_unit_outputs_array.length; idx++) {%>
       `uvm_info("CHECK_EN_LOW_TESTING_MODULE",$sformatf("Start the testing of <%=ioaiu_unit_outputs_array[idx]%>"),UVM_LOW)
       <%if(ioaiu_unit_outputs_array[idx].endsWith("valid_chk") || ioaiu_unit_outputs_array[idx].endsWith("ready_chk") || ioaiu_unit_outputs_array[idx].endsWith("ack_chk")){%>
         repeat(10)
         @(posedge aclk);
         force arst_n = 0;
         force tb_top.dut.<%=obj.DutInfo.interfaces.axiInt.name%><%=ioaiu_unit_outputs_array[idx]%> = 0;
         repeat(100)
         @(posedge aclk);
         release tb_top.dut.<%=obj.DutInfo.interfaces.axiInt.name%><%=ioaiu_unit_outputs_array[idx]%>;
         release arst_n;
       <%} else {%>
         repeat(10)
         @(posedge aclk);
         force tb_top.dut.<%=obj.DutInfo.interfaces.axiInt.name%><%=ioaiu_unit_outputs_array[idx]%> = 0;
         repeat(100)
         @(posedge aclk);
         release tb_top.dut.<%=obj.DutInfo.interfaces.axiInt.name%><%=ioaiu_unit_outputs_array[idx]%>;
       <%}%>
     <%}%>
    `uvm_info("CHECK_EN_LOW_TESTING_MODULE",$sformatf("event trigger successfully"),UVM_LOW)
    wait_for_chk_en_test.trigger();
    end
  end

 always@(posedge aclk)begin
   if($test$plusargs("check_enable_low_parity_test"))begin
     if(<%if(obj.useResiliency){%> tb_top.dut.fault_mission_fault<%}else{%> 0 <%}%>)begin
      `uvm_fatal("CHECK_EN_LOW_TESTING_MODULE",$sformatf("mission_fault mismatch Exp:0 Act:1")) 
     end
     else if(tb_top.dut.<%=obj.DutInfo.interfaces.irqInt.name%>uc)begin
      `uvm_fatal("CHECK_EN_LOW_TESTING_MODULE",$sformatf("IRQ_UC mismatch Exp:0 Act:1")) 
     end
     else if(tb_top.dut.ioaiu_core_wrapper.ioaiu_core0.XAIUUESR_ErrVld_out)begin
      `uvm_fatal("CHECK_EN_LOW_TESTING_MODULE",$sformatf("ErrVld mismatch Exp:0 Act:1")) 
     end
   end
 end

endmodule
<%}%>

