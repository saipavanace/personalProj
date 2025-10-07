/****************************************************************************************************************************
*                                                                                                                           *
* Placeholder connectivity checker for Ncore 3.0 placeholder conectivity check                                              *
* This module force the placeholder inputs and checks the connectivity by                                                   *
* checking forced value at wrapper module.                                                                                  *
*                                                                                                                           *
* File    : placeholder_connectivity_checker.sv                                                                             *
* Version : 0.1                                                                                                             *
* Author  : Kruna Patel                                                                                                     *
* Confluence page links  :                                                                                                  *
*                                                                                                                           *
*                                                                                                                           *
/***************************************************************************************************************************/

`ifndef PLACEHOLDER_CONNECTIVITY_CHECKER_SV
`define PLACEHOLDER_CONNECTIVITY_CHECKER_SV

<% if ((obj.useResiliency && obj.testBench != "fsys") || (obj.testBench == "io_aiu")) { %>
module placeholder_connectivity_checker(input tb_clk, input tb_rstn);

 // Following event will end the test
<% if((obj.testBench == 'dii')||(obj.testBench == 'dmi')||(obj.testBench == 'chi_aiu')||(obj.testBench == 'io_aiu')) { %>
`ifndef VCS
 event kill_test;
`else // `ifndef VCS
 uvm_event kill_test;
`endif // `ifndef VCS ... `else ... 
<% } else {%>
 event kill_test;
<% } %>

 string report_id = "placeholder_connectivity_checker";

 <% var hier_path_dut      = ['tb_top.dut'];  %>

<%  if(obj.testBench == "io_aiu" && obj.DutInfo.nNativeInterfacePorts > 1) {
      var dut_sizePhArray = [];
      var dut_userPlaceInt = [[]];
      for(var j = 0; j < obj.DutInfo.nNativeInterfacePorts; j++){
        let isArray = Array.isArray(obj.interfaces.userPlaceInt[j]);
        if (isArray) {
            dut_sizePhArray[j]  = obj.interfaces.userPlaceInt[j].length;
            dut_userPlaceInt[j] = new Array(dut_sizePhArray[j]);
            for (var i=0; i<dut_sizePhArray[j]; i++) {
                dut_userPlaceInt[j][i] = obj.interfaces.userPlaceInt[j][i];
            }
        } else {
            dut_sizePhArray[j]  = 1;
            dut_userPlaceInt[j] = new Array(1);
            dut_userPlaceInt[j][0] = obj.interfaces.userPlaceInt[j];
        }
      }
    } else {
%>
<%  var dut_sizePhArray;
    var dut_userPlaceInt = [];
    let isArray = Array.isArray(obj.interfaces.userPlaceInt);
    if (isArray) {
        dut_sizePhArray  = obj.interfaces.userPlaceInt.length;
        dut_userPlaceInt = new Array(dut_sizePhArray);
        for (var i=0; i<dut_sizePhArray; i++) {
            dut_userPlaceInt[i] = obj.interfaces.userPlaceInt[i];
        }
    } else {
        dut_sizePhArray  = 1;
        dut_userPlaceInt = new Array(1);
        dut_userPlaceInt[0] = obj.interfaces.userPlaceInt;
    }
    }
%>
 <%
    var placeholder_a_input_signal_array =  ['rx_req_flit', 'rx_req_flitv', 'rx_req_flit_pend', 'rx_rsp_flit', 'rx_rsp_flitv', 'rx_rsp_flit_pend', 'rx_dat_flit', 'rx_dat_flitv', 'rx_dat_flit_pend', 'tx_snp_lcrdv', 'tx_rsp_lcrdv', 'tx_dat_lcrdv', 'rx_link_active_req', 'tx_link_active_ack'];
    var placeholder_a_output_signal_array  = ['rx_req_lcrdv', 'rx_rsp_lcrdv', 'rx_dat_lcrdv', 'tx_snp_flit', 'tx_snp_flitv', 'tx_snp_flit_pend', 'tx_rsp_flit', 'tx_rsp_flitv', 'tx_rsp_flit_pend', 'tx_dat_flit', 'tx_dat_flitv', 'tx_dat_flit_pend', 'rx_link_active_ack', 'tx_link_active_req'];

    var placeholder_b_input_signal_array      = ['ar_ready', 'r_valid', 'r_id', 'r_data', 'r_resp', 'r_last', 'aw_ready', 'w_ready', 'b_valid', 'b_id', 'b_resp'];
    var placeholder_b_output_signal_array     = ['ar_valid', 'ar_id', 'ar_addr', 'ar_len', 'ar_size', 'ar_burst', 'ar_lock', 'ar_prot', 'ar_cache', 'r_ready', 'aw_valid', 'aw_id', 'aw_addr', 'aw_len', 'aw_size', 'aw_burst', 'aw_lock', 'aw_prot', 'aw_cache', 'w_valid', 'w_data', 'w_strb', 'w_last', 'b_ready'];
    var placeholder_b_hierarchy = ['tb_top.dut.dii0.u_dii_unit'] ;

    var placeholder_c_input_signal_array  = ['ar_ready', 'r_valid', 'r_id', 'r_data', 'r_resp', 'r_last', 'aw_ready', 'w_ready', 'b_valid', 'b_id', 'b_resp'];
    var placeholder_c_output_signal_array = ['ar_valid', 'ar_id', 'ar_addr', 'ar_len', 'ar_size', 'ar_burst', 'ar_lock', 'ar_prot', 'ar_cache', 'r_ready', 'aw_valid', 'aw_id', 'aw_addr', 'aw_len', 'aw_size', 'aw_burst', 'aw_lock', 'aw_prot', 'aw_cache', 'w_valid', 'w_data', 'w_strb', 'w_last', 'b_ready'];
    var placeholder_c_hierarchy = ['tb_top.dut.dii1.u_dii_unit'] ;

    var placeholder_d_input_signal_array  = ['r_valid', 'r_id', 'r_data', 'r_resp', 'r_last', 'aw_ready', 'w_ready', 'b_valid', 'b_id', 'b_resp'];
    var placeholder_d_output_signal_array = ['ar_valid', 'ar_id', 'ar_addr', 'ar_len', 'ar_size', 'ar_burst', 'ar_lock', 'ar_prot', 'ar_cache', 'r_ready', 'aw_valid', 'aw_id', 'aw_addr', 'aw_len', 'aw_size', 'aw_burst', 'aw_lock', 'aw_prot', 'aw_cache', 'w_valid', 'w_data', 'w_strb', 'w_last', 'b_ready'];
    var placeholder_d_hierarchy = ['tb_top.dut.sys_dii.u_dii_unit'] ;

    var _delay;
    var nResiliencyDelay_json = obj.DutInfo.ResilienceInfo.nResiliencyDelay;
    if(obj.testBench == "io_aiu" && obj.DutInfo.nNativeInterfacePorts > 1) {
      var placeholder_fault_output_signal_array = [[[]]];
      for(var j = 0; j < obj.DutInfo.nNativeInterfacePorts; j++){
        if((dut_sizePhArray[j] > 0) && (dut_userPlaceInt[j][0]._SKIP_ != true)){
          placeholder_fault_output_signal_array[j] = [['cerr_fault', 'interface_fault']];
        }
      }
    } else {
      if((dut_sizePhArray > 0) && (dut_userPlaceInt[0]._SKIP_ != true)){
      var placeholder_fault_output_signal_array = [['cerr_fault', 'interface_fault']];
      } else {
      var placeholder_fault_output_signal_array = [[]];
      }
    }
    var placeholder_inst_prefix = ['u_axiPlaceholder'];
    var fault_hierarchy = ['tb_top'];
    var func_checker_inst_name = [];

    if(obj.testBench == "io_aiu" && obj.DutInfo.nNativeInterfacePorts > 1) {
      var userPlaceInt_output_signal_array = [[]];
      var userPlaceInt_input_signal_array = [[]];
      var tmp_userPlaceInt_output_signal_array = [[]];
      var tmp_userPlaceInt_input_signal_array = [[]];
      var userPlaceInt_wrapper_sig_output_name = [''];
      var userPlaceInt_wrapper_sig_input_name = [''];
      var wrapper_sig_width_out = [];
      var wrapper_sig_width_in = [];
      for(var j = 0; j < obj.DutInfo.nNativeInterfacePorts; j++){
        for (var idx=0; idx < dut_sizePhArray[j]; idx++) {
          if(dut_userPlaceInt[j][idx]._SKIP_ != true){
            var userPlaceInt_name = dut_userPlaceInt[j][idx].name;
            var sig_name = '';
            userPlaceInt_wrapper_sig_output_name[j] = userPlaceInt_name + 'out'
            userPlaceInt_wrapper_sig_input_name[j] = userPlaceInt_name + 'in'
            tmp_userPlaceInt_output_signal_array[0] = [];
            if(dut_userPlaceInt[j][idx].params.wOut != 0){
              wrapper_sig_width_out[j] = dut_userPlaceInt[j][idx].params.wOut;
              dut_userPlaceInt[j][idx].synonyms.out.forEach(function outways(item,index){
                sig_name = item.name;
                tmp_userPlaceInt_output_signal_array[0].push(sig_name);
              })
              userPlaceInt_output_signal_array[j] = tmp_userPlaceInt_output_signal_array[0];
            }
            tmp_userPlaceInt_input_signal_array[0] = [];
            if(dut_userPlaceInt[j][idx].params.wIn != 0){
              wrapper_sig_width_in[j] = dut_userPlaceInt[j][idx].params.wIn;
              dut_userPlaceInt[j][idx].synonyms.in.forEach(function inways(item,index){
                sig_name = item.name;
                tmp_userPlaceInt_input_signal_array[0].push(sig_name);
              })
              userPlaceInt_input_signal_array[j] = tmp_userPlaceInt_input_signal_array[0];
            }
          }
        }
      }
    } else {
    var userPlaceInt_output_signal_array = [[]];
    var userPlaceInt_input_signal_array = [[]];
    var userPlaceInt_wrapper_sig_output_name = '';
    var userPlaceInt_wrapper_sig_input_name = '';
    var wrapper_sig_width_out = 0;
    var wrapper_sig_width_in = 0;

    for (var idx=0; idx < dut_sizePhArray; idx++) {
    if(dut_userPlaceInt[idx]._SKIP_ != true){
      var userPlaceInt_name = dut_userPlaceInt[idx].name;
      var sig_name = '';
      userPlaceInt_wrapper_sig_output_name = userPlaceInt_name + 'out'
      userPlaceInt_wrapper_sig_input_name = userPlaceInt_name + 'in'

      if(dut_userPlaceInt[idx].params.wOut != 0){
        wrapper_sig_width_out = dut_userPlaceInt[idx].params.wOut;
        dut_userPlaceInt[idx].synonyms.out.forEach(function outways(item,index){
          sig_name = item.name;
          userPlaceInt_output_signal_array[0].push(sig_name);
        })
      }
      if(dut_userPlaceInt[idx].params.wIn != 0){
        wrapper_sig_width_in = dut_userPlaceInt[idx].params.wIn;
        dut_userPlaceInt[idx].synonyms.in.forEach(function inways(item,index){
          sig_name = item.name;
          userPlaceInt_input_signal_array[0].push(sig_name);
        })
      }
    }
   }
    }
   %>

   <% if(obj.testBench == "chi_aiu") {
       if (obj.fnNativeInterface === 'CHI-A') {
          var wrapper_prefix = ['chi_a_slv_'] ;
          var placeholder_prefix = ['chi_a_slv_placeholder_'] ;
       } else if (obj.fnNativeInterface === 'CHI-B') {
          var wrapper_prefix = ['chi_b_slv_'] ;
          var placeholder_prefix = ['chi_b_slv_placeholder_'] ;
       } else if (obj.fnNativeInterface === 'CHI-E') {
          var wrapper_prefix = ['chi_e_slv_'] ;
          var placeholder_prefix = ['chi_e_slv_placeholder_'] ;
       }
          var placeholder_input_signal_array =[placeholder_a_input_signal_array];
          var placeholder_output_signal_array =[placeholder_a_output_signal_array];
          var placeholder_a_hierarchy = ['tb_top.dut.unit'] ;
          var placeholder_hierarchy =[placeholder_a_hierarchy];
          var placeholder_hierarchy_duplicate =[['tb_top.dut.dup_unit']];
          placeholder_inst_prefix = ['u_chiPlaceholder'];
          func_checker_inst_name = ['u_chi_aiu_fault_checker'];
          _delay = 1; // jira-CONC-7129 as nativeInterfacePipe enabled
    }else if(obj.testBench == "dii") {
          var wrapper_prefix = ['axi4_mst_'] ;
          var placeholder_prefix = ['axi_mst_placeholder_'] ;
          var placeholder_input_signal_array =[[]];
          var placeholder_output_signal_array =[[]];
          var placeholder_b_hierarchy = ['tb_top.dut.u_dii_unit'] ;
          var placeholder_hierarchy =[placeholder_b_hierarchy];
          var placeholder_hierarchy_duplicate =[['tb_top.dut.dup_unit']];
          func_checker_inst_name = ['u_dii_fault_checker'];
          _delay = 1;
    }else if(obj.testBench == "dmi") {
          var wrapper_prefix = ['axi4_mst_'] ;
          var placeholder_prefix = ['axi_mst_placeholder_'] ;
          var placeholder_input_signal_array =[placeholder_b_input_signal_array];
          var placeholder_output_signal_array =[placeholder_b_output_signal_array];
          var placeholder_b_hierarchy = ['tb_top.dut.dmi_unit'] ;
          var placeholder_hierarchy =[placeholder_b_hierarchy];
          var placeholder_hierarchy_duplicate =[['tb_top.dut.dup_unit']];
          func_checker_inst_name = ['u_dmi_fault_checker'];
          _delay = 0;
    }else if(obj.testBench == "io_aiu") {
          var wrapper_prefix = [] ;
          var placeholder_prefix = [] ;
          var placeholder_input_signal_array =[[]];
          var placeholder_output_signal_array =[[]];
          var placeholder_hierarchy =[[]];
          var placeholder_hierarchy_duplicate =[[]];
for(var i = 0; i < obj.DutInfo.nNativeInterfacePorts; i++){
          placeholder_hierarchy[i] =['tb_top.dut.ioaiu_core_wrapper.ioaiu_core'+i];
          placeholder_hierarchy_duplicate[i] =['tb_top.dut.dup_unit.ioaiu_core'+i];
}
          placeholder_inst_prefix = ['pph'];
          func_checker_inst_name = ['dup_checker'];
          _delay = 0;
    } %>

  initial begin
    logic [1023:0] prev_val [127:0] [127:0];
     
    bit inject_fault_in_func_unit;
    bit inject_fault_in_checker_unit;   
    bit placeholder_tb_mission_fault_ud;
    bit placeholder_tb_latent_fault_ud;
    bit start_out_cov_sample =0;
    bit start_checker_ilf;
    int    delay_bw_two_faults; 
    int    rand_pos_in_signal;
    int    signal_width[127:0][127:0];
    int    signal_width_sum;
    bit    signal_width_val;
    bit[1023:0] signal_width_val_force,Delay_signal_val;
    bit[1023:0] signal_width_val_form;
    bit    signal_width_val_op_da[$], signal_width_val_ip_da[$];
<%  if(obj.testBench == "io_aiu" && obj.DutInfo.nNativeInterfacePorts > 1) {%>
    int    signal_width_in[];
    int    signal_width_out[];
<%  }else {%>
    int    signal_width_in;
    int    signal_width_out;
<%  }%>
    bit    check_placeholder_a;
    bit    check_placeholder_b;
    bit    check_placeholder_c;
    bit    check_placeholder_d;
    bit    check_native_intf_connectivity;


<% if((obj.testBench == 'dii')||(obj.testBench == 'dmi')||(obj.testBench == 'chi_aiu')||(obj.testBench == 'io_aiu')) { %>
`ifdef VCS
//#0.1
   
  kill_test = new("kill_test");

`endif // `ifndef VCS ... `else ... 
<% } %>

    signal_width_sum = 0;
    signal_width_val = 0;
    signal_width_val_force = 0;
    signal_width_val_form = 0;
<%  if(obj.testBench == "io_aiu" && obj.DutInfo.nNativeInterfacePorts > 1) {%>
    signal_width_in = new[<%=wrapper_sig_width_in.length%>];
    signal_width_in = '{<%=wrapper_sig_width_in%>};
    signal_width_out = new[<%=wrapper_sig_width_out.length%>];
    signal_width_out = '{<%=wrapper_sig_width_out%>};
<%  }else {%>
    signal_width_in = <%=wrapper_sig_width_in%>;
    signal_width_out = <%=wrapper_sig_width_out%>;
<%  }%>
    check_native_intf_connectivity = 1'b1;

   <% if ((obj.testBench == "dmi") || (obj.testBench == "dii") || (obj.testBench == "chi_aiu") || (obj.testBench == "io_aiu")) { %> // System level
    if ($test$plusargs("test_placeholder_connectivity")) begin
      void'($value$plusargs("ph_check_native_intf=%0d", check_native_intf_connectivity));
      @(posedge tb_rstn);
      repeat(100)@(posedge tb_clk);
      delay_bw_two_faults = 0;
      if(check_native_intf_connectivity) begin
      repeat(10000) begin
        @(posedge tb_clk);

       <% for (var idx = 0; idx < placeholder_input_signal_array[0].length; idx++) { %>
         prev_val[0] [<%=idx%>] =  <%=hier_path_dut%>.<%=wrapper_prefix%><%=placeholder_input_signal_array[0][idx]%>;
         repeat(<%=_delay%>)@(posedge tb_clk);
         if(<%=placeholder_hierarchy%>.<%=placeholder_prefix%><%=placeholder_input_signal_array[0][idx]%> !=  (prev_val[0][<%=idx%>])) begin
           `uvm_error(report_id,$sformatf({"input_signal_array:: Mismatch {Exp:%0s=0x%0h|Act:%0s=0x%0h}"}, "<%=hier_path_dut%>.<%=wrapper_prefix%><%=placeholder_input_signal_array[0][idx]%>", prev_val[0][<%=idx%>], "<%=placeholder_hierarchy%>.<%=placeholder_prefix%><%=placeholder_input_signal_array[0][idx]%>",  <%=placeholder_hierarchy%>.<%=placeholder_prefix%><%=placeholder_input_signal_array[0][idx]%>));
         end else begin
           `uvm_info(report_id,$sformatf({"input_signal_array:: Match {Exp:%0s=0x%0h|Act:%0s=0x%0h}"}, "<%=hier_path_dut%>.<%=wrapper_prefix%><%=placeholder_input_signal_array[0][idx]%>", prev_val[0][<%=idx%>], "<%=placeholder_hierarchy%>.<%=placeholder_prefix%><%=placeholder_input_signal_array[0][idx]%>",  <%=placeholder_hierarchy%>.<%=placeholder_prefix%><%=placeholder_input_signal_array[0][idx]%>), UVM_DEBUG);
         end
      <% } %>
      <% for (var idx = 0; idx < placeholder_output_signal_array[0].length; idx++) { %>
         prev_val[0] [<%=idx%>] =  <%=placeholder_hierarchy%>.<%=placeholder_prefix%><%=placeholder_output_signal_array[0][idx]%>;
         repeat(<%=_delay%>)@(posedge tb_clk);
         if(<%=hier_path_dut%>.<%=wrapper_prefix%><%=placeholder_output_signal_array[0][idx]%> !=  (prev_val[0][<%=idx%>])) begin
           `uvm_error(report_id,$sformatf({"output_signal_array:: Mismatch. {Exp:%0s=0x%0h|Act:%0s=0x%0h}"}, "<%=placeholder_hierarchy%>.<%=placeholder_prefix%><%=placeholder_output_signal_array[0][idx]%>", prev_val[0][<%=idx%>], "<%=hier_path_dut%>.<%=wrapper_prefix%><%=placeholder_output_signal_array[0][idx]%>", <%=hier_path_dut%>.<%=wrapper_prefix%><%=placeholder_output_signal_array[0][idx]%>));
         end else begin
           `uvm_info(report_id,$sformatf({"output_signal_array:: Match. {Exp:%0s=0x%0h|Act:%0s=0x%0h}"}, "<%=placeholder_hierarchy%>.<%=placeholder_prefix%><%=placeholder_output_signal_array[0][idx]%>", prev_val[0][<%=idx%>], "<%=hier_path_dut%>.<%=wrapper_prefix%><%=placeholder_output_signal_array[0][idx]%>", <%=hier_path_dut%>.<%=wrapper_prefix%><%=placeholder_output_signal_array[0][idx]%>), UVM_DEBUG);
         end
      <% } %>
      end
      end else begin
        `uvm_info(report_id, $sformatf("Skipping Native interface check for connectivity. Jiras, CONC-7129, CONC-7546"), UVM_NONE);
      end

      // force the user signal and check at the wrapper's top connectivity
<%if(obj.testBench == "io_aiu" && obj.DutInfo.nNativeInterfacePorts > 1) {%>
 {inject_fault_in_checker_unit,inject_fault_in_func_unit} = $urandom_range(0,3);
   delay_bw_two_faults =  $urandom_range(1,3);

      repeat(100) begin
      `uvm_info(report_id, $sformatf("\n%s %s %s\n",{4{"*"}},{40{"-"}},{4{"*"}}), UVM_NONE);
<%for(var j = 0; j < obj.DutInfo.nNativeInterfacePorts; j++){%>
        //output [<%=j%>]
        signal_width_sum = 0;
        signal_width_val_op_da.delete();

      <% for (var idx = 0; idx < userPlaceInt_output_signal_array[j].length; idx++) { %>
         signal_width[<%=j%>][<%=idx%>] = $bits(<%=placeholder_hierarchy[j]%>.<%=placeholder_inst_prefix%>.<%=userPlaceInt_output_signal_array[j][idx]%>);
         signal_width_sum = signal_width_sum + signal_width[<%=j%>][<%=idx%>];
         repeat(1)@(posedge tb_clk);
         signal_width_val_force = $urandom_range(0,(2**signal_width[<%=j%>][<%=idx%>])-1);

         for(int i=signal_width[<%=j%>][<%=idx%>]-1; i>=0; i--) begin
           signal_width_val_op_da.push_back(signal_width_val_force[i]);
            
         end

               do begin
              Delay_signal_val   =  $urandom_range(0,(2**signal_width[<%=j%>][<%=idx%>])-1); 
              end while(signal_width_val_force  == Delay_signal_val );
           //#Check.IOAIU.Placeholder.Output
           case({inject_fault_in_checker_unit,inject_fault_in_func_unit})
                 'b00 : begin
                   // do nothing
                   start_out_cov_sample = 1;
                   placeholder_tb_mission_fault_ud = 0;
                   placeholder_tb_latent_fault_ud  = 0;
                   
                    repeat(1)@(posedge tb_clk);
                    <% if(wrapper_sig_width_out[j] > 1) { %>
                    for(int i=(signal_width_out[<%=j%>]-signal_width_sum+signal_width[<%=j%>][<%=idx%>]-1);i>=(signal_width_out[<%=j%>]-signal_width_sum);i--) begin
    

                      if({inject_fault_in_checker_unit,inject_fault_in_func_unit}== 0) begin
                      signal_width_val = signal_width_val_op_da.pop_front();
                      signal_width_val = 0;
                      end else begin
                      signal_width_val = signal_width_val_op_da.pop_front();
                      end
             

                        if(<%=hier_path_dut%>.<%=userPlaceInt_wrapper_sig_output_name[j]%>[i] != signal_width_val) begin
                           `uvm_error(report_id, $sformatf("userPlaceInt_output mismatch: %0s[%0d] ->{exp:%0d|act:%0d}", "<%=hier_path_dut%>.<%=userPlaceInt_wrapper_sig_output_name[j]%>" ,(i), signal_width_val, <%=hier_path_dut%>.<%=userPlaceInt_wrapper_sig_output_name[j]%>[i]));
                       end else begin
                           `uvm_info(report_id, $sformatf("userPlaceInt_output match: %0s[%0d] ->{exp:%0d|act:%0d}", "<%=hier_path_dut%>.<%=userPlaceInt_wrapper_sig_output_name[j]%>" ,(i), signal_width_val, <%=hier_path_dut%>.<%=userPlaceInt_wrapper_sig_output_name[j]%>[i]), UVM_DEBUG);
                         end
                      end
                     <% } else { %>
                        if({inject_fault_in_checker_unit,inject_fault_in_func_unit}== 0 ) begin
                              signal_width_val = signal_width_val_op_da.pop_front();
                              signal_width_val = 0;
                              end else begin
                              signal_width_val = signal_width_val_op_da.pop_front();
                              end

                            if(<%=hier_path_dut%>.<%=userPlaceInt_wrapper_sig_output_name[j]%> != signal_width_val) begin
                              `uvm_error(report_id, $sformatf("userPlaceInt_output mismatch: %0s ->{exp:%0d|act:%0d}", "<%=hier_path_dut%>.<%=userPlaceInt_wrapper_sig_output_name[j]%>" , signal_width_val, <%=hier_path_dut%>.<%=userPlaceInt_wrapper_sig_output_name[j]%>));
                            end else begin
                              `uvm_info(report_id, $sformatf("userPlaceInt_output match: %0s ->{exp:%0d|act:%0d}", "<%=hier_path_dut%>.<%=userPlaceInt_wrapper_sig_output_name[j]%>" , signal_width_val, <%=hier_path_dut%>.<%=userPlaceInt_wrapper_sig_output_name[j]%>), UVM_DEBUG);
                            end
                          <% } %>

                    end
   
                  'b01 : begin
                   start_out_cov_sample = 1;
                  repeat(<%= nResiliencyDelay_json %>) @(posedge tb_clk);

                           force  <%=placeholder_hierarchy[j]%>.<%=placeholder_inst_prefix%>.<%=userPlaceInt_output_signal_array[j][idx]%> = signal_width_val_force;
                           <% if (obj.DutInfo.ResilienceInfo.enableUnitDuplication) { %>
                           force  <%=placeholder_hierarchy_duplicate[j]%>.<%=placeholder_inst_prefix%>.<%=userPlaceInt_output_signal_array[j][idx]%> =Delay_signal_val;         

                                  placeholder_tb_mission_fault_ud = 1;
                                  placeholder_tb_latent_fault_ud  = 0;
                                <% } %>
                                  repeat(<%= nResiliencyDelay_json %>) @(posedge tb_clk); //#3
                                  repeat(2) @(posedge tb_clk);
                                  start_checker_ilf = 1;

                                   repeat(1)@(posedge tb_clk);
                                       <%if(wrapper_sig_width_out[j] > 1) { %>
                                       for(int i=(signal_width_out[<%=j%>]-signal_width_sum+signal_width[<%=j%>][<%=idx%>]-1);i>=(signal_width_out[<%=j%>]-signal_width_sum);i--) begin
    

                                        if({inject_fault_in_checker_unit,inject_fault_in_func_unit}== 0) begin
                                         signal_width_val = signal_width_val_op_da.pop_front();
                                         signal_width_val = 0;
                                         end else begin
                                         signal_width_val = signal_width_val_op_da.pop_front();
                                         end
    

                                         if(<%=hier_path_dut%>.<%=userPlaceInt_wrapper_sig_output_name[j]%>[i] != signal_width_val) begin
                                          `uvm_error(report_id, $sformatf("userPlaceInt_output mismatch: %0s[%0d] ->{exp:%0d|act:%0d}", "<%=hier_path_dut%>.<%=userPlaceInt_wrapper_sig_output_name[j]%>" ,(i), signal_width_val, <%=hier_path_dut%>.<%=userPlaceInt_wrapper_sig_output_name[j]%>[i]));
                                        end else begin
                                          `uvm_info(report_id, $sformatf("userPlaceInt_output match: %0s[%0d] ->{exp:%0d|act:%0d}", "<%=hier_path_dut%>.<%=userPlaceInt_wrapper_sig_output_name[j]%>" ,(i), signal_width_val, <%=hier_path_dut%>.<%=userPlaceInt_wrapper_sig_output_name[j]%>[i]), UVM_DEBUG);
                                         end
                                          end
                                    <% } else { %>
                                         if({inject_fault_in_checker_unit,inject_fault_in_func_unit}== 0 ) begin
                                        signal_width_val = signal_width_val_op_da.pop_front();
                                        signal_width_val = 0;
                                        end else begin
                                        signal_width_val = signal_width_val_op_da.pop_front();
                                        end
                           
                                                 if(<%=hier_path_dut%>.<%=userPlaceInt_wrapper_sig_output_name[j]%> != signal_width_val) begin
                                                   `uvm_error(report_id, $sformatf("userPlaceInt_output mismatch: %0s ->{exp:%0d|act:%0d}", "<%=hier_path_dut%>.<%=userPlaceInt_wrapper_sig_output_name[j]%>" , signal_width_val, <%=hier_path_dut%>.<%=userPlaceInt_wrapper_sig_output_name[j]%>));
                                                 end else begin
                                                   `uvm_info(report_id, $sformatf("userPlaceInt_output match: %0s ->{exp:%0d|act:%0d}", "<%=hier_path_dut%>.<%=userPlaceInt_wrapper_sig_output_name[j]%>" , signal_width_val, <%=hier_path_dut%>.<%=userPlaceInt_wrapper_sig_output_name[j]%>), UVM_DEBUG);
                                                 end
                                               <% } %>
                           
                                                      
                                                release  <%=placeholder_hierarchy[j]%>.<%=placeholder_inst_prefix%>.<%=userPlaceInt_output_signal_array[j][idx]%> ;
                                                <% if (obj.DutInfo.ResilienceInfo.enableUnitDuplication) { %>
                                                release  <%=placeholder_hierarchy_duplicate[j]%>.<%=placeholder_inst_prefix%>.<%=userPlaceInt_output_signal_array[j][idx]%>;
                                                <% } %>
                                            end
                           
               'b10 : begin
                   start_out_cov_sample = 1;

                   force  <%=placeholder_hierarchy[j]%>.<%=placeholder_inst_prefix%>.<%=userPlaceInt_output_signal_array[j][idx]%> = signal_width_val_force;
                   <% if (obj.DutInfo.ResilienceInfo.enableUnitDuplication) { %>
                   force  <%=placeholder_hierarchy_duplicate[j]%>.<%=placeholder_inst_prefix%>.<%=userPlaceInt_output_signal_array[j][idx]%> =Delay_signal_val;           
                   placeholder_tb_mission_fault_ud = 1;
                   placeholder_tb_latent_fault_ud  = 0;                     
                   <% } %>

                   repeat(4) @(posedge tb_clk);
                   start_checker_ilf = 1;
                   repeat(1)@(posedge tb_clk);
                      <% if(wrapper_sig_width_out[j] > 1) { %>
                        for(int i=(signal_width_out[<%=j%>]-signal_width_sum+signal_width[<%=j%>][<%=idx%>]-1);i>=(signal_width_out[<%=j%>]-signal_width_sum);i--) begin
    

                         if({inject_fault_in_checker_unit,inject_fault_in_func_unit}== 0) begin
                          signal_width_val = signal_width_val_op_da.pop_front();
                          signal_width_val = 0;
                          end else begin
                          signal_width_val = signal_width_val_op_da.pop_front();
                          end
    

                          if(<%=hier_path_dut%>.<%=userPlaceInt_wrapper_sig_output_name[j]%>[i] != signal_width_val) begin
                           `uvm_error(report_id, $sformatf("userPlaceInt_output mismatch: %0s[%0d] ->{exp:%0d|act:%0d}", "<%=hier_path_dut%>.<%=userPlaceInt_wrapper_sig_output_name[j]%>" ,(i), signal_width_val, <%=hier_path_dut%>.<%=userPlaceInt_wrapper_sig_output_name[j]%>[i]));
                         end else begin
                           `uvm_info(report_id, $sformatf("userPlaceInt_output match: %0s[%0d] ->{exp:%0d|act:%0d}", "<%=hier_path_dut%>.<%=userPlaceInt_wrapper_sig_output_name[j]%>" ,(i), signal_width_val, <%=hier_path_dut%>.<%=userPlaceInt_wrapper_sig_output_name[j]%>[i]), UVM_DEBUG);
                         end
                        end
                    
                    <% } else { %>
                        if({inject_fault_in_checker_unit,inject_fault_in_func_unit}== 0 ) begin
                        signal_width_val = signal_width_val_op_da.pop_front();
                        signal_width_val = 0;
                        end else begin
                        signal_width_val = signal_width_val_op_da.pop_front();
                        end

                        if(<%=hier_path_dut%>.<%=userPlaceInt_wrapper_sig_output_name[j]%> != signal_width_val) begin
                        `uvm_error(report_id, $sformatf("userPlaceInt_output mismatch: %0s ->{exp:%0d|act:%0d}", "<%=hier_path_dut%>.<%=userPlaceInt_wrapper_sig_output_name[j]%>" , signal_width_val, <%=hier_path_dut%>.<%=userPlaceInt_wrapper_sig_output_name[j]%>));
                        end else begin
                        `uvm_info(report_id, $sformatf("userPlaceInt_output match: %0s ->{exp:%0d|act:%0d}", "<%=hier_path_dut%>.<%=userPlaceInt_wrapper_sig_output_name[j]%>" , signal_width_val, <%=hier_path_dut%>.<%=userPlaceInt_wrapper_sig_output_name[j]%>), UVM_DEBUG);
                        end
                       <% } %>

                  release  <%=placeholder_hierarchy[j]%>.<%=placeholder_inst_prefix%>.<%=userPlaceInt_output_signal_array[j][idx]%> ;
   		  <% if (obj.DutInfo.ResilienceInfo.enableUnitDuplication) { %>
                  release  <%=placeholder_hierarchy_duplicate[j]%>.<%=placeholder_inst_prefix%>.<%=userPlaceInt_output_signal_array[j][idx]%>;
                 <% } %>

                 end 
                'b11 : begin
                   start_out_cov_sample = 1;

		   force  <%=placeholder_hierarchy[j]%>.<%=placeholder_inst_prefix%>.<%=userPlaceInt_output_signal_array[j][idx]%> =signal_width_val_force;       repeat(<%= nResiliencyDelay_json %>)@(posedge tb_clk); //#1
  		   <% if (obj.DutInfo.ResilienceInfo.enableUnitDuplication) { %>
 		   force  <%=placeholder_hierarchy_duplicate[j]%>.<%=placeholder_inst_prefix%>.<%=userPlaceInt_output_signal_array[j][idx]%> = signal_width_val_force;
                   <% } %>

                   placeholder_tb_mission_fault_ud = 0;
                   placeholder_tb_latent_fault_ud  = 0;
                   repeat(2) @(posedge tb_clk);
                   start_checker_ilf = 1;
                   repeat(1)@(posedge tb_clk);
                   <% if(wrapper_sig_width_out[j] > 1) { %>
                   for(int i=(signal_width_out[<%=j%>]-signal_width_sum+signal_width[<%=j%>][<%=idx%>]-1);i>=(signal_width_out[<%=j%>]-signal_width_sum);i--) begin
    

                      if({inject_fault_in_checker_unit,inject_fault_in_func_unit}== 0) begin
                      signal_width_val = signal_width_val_op_da.pop_front();
                      signal_width_val = 0;
                      end else begin
                      signal_width_val = signal_width_val_op_da.pop_front();
                      end
    
                       //#Check.IOAIU.Placeholder.connectivity
                      if(<%=hier_path_dut%>.<%=userPlaceInt_wrapper_sig_output_name[j]%>[i] != signal_width_val) begin
                        `uvm_error(report_id, $sformatf("userPlaceInt_output mismatch: %0s[%0d] ->{exp:%0d|act:%0d}", "<%=hier_path_dut%>.<%=userPlaceInt_wrapper_sig_output_name[j]%>" ,(i), signal_width_val, <%=hier_path_dut%>.<%=userPlaceInt_wrapper_sig_output_name[j]%>[i]));
                      end else begin
                        `uvm_info(report_id, $sformatf("userPlaceInt_output match: %0s[%0d] ->{exp:%0d|act:%0d}", "<%=hier_path_dut%>.<%=userPlaceInt_wrapper_sig_output_name[j]%>" ,(i), signal_width_val, <%=hier_path_dut%>.<%=userPlaceInt_wrapper_sig_output_name[j]%>[i]), UVM_DEBUG);
                      end
                    end
                  <% } else { %>
        
                     if({inject_fault_in_checker_unit,inject_fault_in_func_unit}== 0 ) begin
                     signal_width_val = signal_width_val_op_da.pop_front();
                     signal_width_val = 0;
                     end else begin
                     signal_width_val = signal_width_val_op_da.pop_front();
                     end

                   if(<%=hier_path_dut%>.<%=userPlaceInt_wrapper_sig_output_name[j]%> != signal_width_val) begin
                     `uvm_error(report_id, $sformatf("userPlaceInt_output mismatch: %0s ->{exp:%0d|act:%0d}", "<%=hier_path_dut%>.<%=userPlaceInt_wrapper_sig_output_name[j]%>" , signal_width_val, <%=hier_path_dut%>.<%=userPlaceInt_wrapper_sig_output_name[j]%>));
                   end else begin
                     `uvm_info(report_id, $sformatf("userPlaceInt_output match: %0s ->{exp:%0d|act:%0d}", "<%=hier_path_dut%>.<%=userPlaceInt_wrapper_sig_output_name[j]%>" , signal_width_val, <%=hier_path_dut%>.<%=userPlaceInt_wrapper_sig_output_name[j]%>), UVM_DEBUG);
                   end
                   <% } %>
                      repeat(5) @(posedge tb_clk); //#2
                      release  <%=placeholder_hierarchy[j]%>.<%=placeholder_inst_prefix%>.<%=userPlaceInt_output_signal_array[j][idx]%> ;
                      repeat(<%= nResiliencyDelay_json %>) @(posedge tb_clk);
                      <% if (obj.DutInfo.ResilienceInfo.enableUnitDuplication) { %>
                      release  <%=placeholder_hierarchy_duplicate[j]%>.<%=placeholder_inst_prefix%>.<%=userPlaceInt_output_signal_array[j][idx]%>; 
		      <% } %>

               end
               
        endcase


         `uvm_info(report_id, $sformatf("Forcing placeholder output signal %s with {%0p}", "<%=placeholder_hierarchy[j]%>.<%=placeholder_inst_prefix%>.<%=userPlaceInt_output_signal_array[j][idx]%>", signal_width_val_op_da), UVM_NONE);   
          
         repeat(5)@(posedge tb_clk);

         <% if(userPlaceInt_output_signal_array[j][idx].length != 0 && obj.DutInfo.ResilienceInfo.enableUnitDuplication) { %>
    
         if((<%=fault_hierarchy%>.fault_mission_fault != placeholder_tb_mission_fault_ud ) || (<%=fault_hierarchy%>.fault_latent_fault != placeholder_tb_latent_fault_ud )) begin
           `uvm_error(report_id, $sformatf(" Fault mismatch for <%=userPlaceInt_output_signal_array[j][idx]%> : mission_fault{exp:%0d|act:%0d}, latent_fault{exp:%0d|act:%0d}",placeholder_tb_mission_fault_ud , <%=fault_hierarchy%>.fault_mission_fault,placeholder_tb_latent_fault_ud , <%=fault_hierarchy%>.fault_latent_fault));
         end else begin
           `uvm_info(report_id, $sformatf(" Fault match for <%=userPlaceInt_output_signal_array[j][idx]%>: mission_fault{exp:%0d|act:%0d}, latent_fault{exp:%0d|act:%0d}", placeholder_tb_mission_fault_ud, <%=fault_hierarchy%>.fault_mission_fault,placeholder_tb_latent_fault_ud, <%=fault_hierarchy%>.fault_latent_fault), UVM_LOW);
         end

        // clear any fault generated before if any...
        repeat(5)@(posedge tb_clk);
        bist_reset_seq();
        repeat(5)@(posedge tb_clk);
         <% } %>

      <% } %>




         
        //input [<%=j%>]
        signal_width_sum = 0;
        signal_width_val_ip_da.delete();
        repeat(1)@(posedge tb_clk);
        <% if(wrapper_sig_width_in[j] != 0) { %>
          signal_width_val_force = $urandom_range(1,(2**signal_width_in[<%=j%>])-1);
          for(int i=signal_width_in[<%=j%>]-1; i>=0; i--) begin
            signal_width_val_ip_da.push_back(signal_width_val_force[i]);
          end
          `uvm_info(report_id, $sformatf("\nForcing wrapper input signal %s with {%0p}", "<%=hier_path_dut%>.<%=userPlaceInt_wrapper_sig_input_name[j]%>", signal_width_val_ip_da), UVM_NONE);
          force  <%=hier_path_dut%>.<%=userPlaceInt_wrapper_sig_input_name[j]%> = signal_width_val_force;
        <% } %>
      <% for (var idx = 0; idx < userPlaceInt_input_signal_array[j].length; idx++) { %>
         signal_width[<%=j%>][<%=idx%>] = $bits(<%=placeholder_hierarchy[j]%>.<%=placeholder_inst_prefix%>.<%=userPlaceInt_input_signal_array[j][idx]%>);
         signal_width_sum = signal_width_sum + signal_width[<%=j%>][<%=idx%>];
         signal_width_val_form = 0;
         for(int i=(signal_width[<%=j%>][<%=idx%>]-1); i>=0; i--) begin
           signal_width_val = signal_width_val_ip_da.pop_front();
           signal_width_val_form = {signal_width_val_form, signal_width_val};
         end
         repeat(5)@(posedge tb_clk);
         //#Check.IOAIU.Placeholder.connectivity
         if(<%=placeholder_hierarchy[j]%>.<%=placeholder_inst_prefix%>.<%=userPlaceInt_input_signal_array[j][idx]%> != signal_width_val_form) begin
           `uvm_error(report_id, $sformatf("userPlaceInt_input mismatch: %0s ->{exp:%0d|act:%0d}", "<%=placeholder_hierarchy[j]%>.<%=placeholder_inst_prefix%>.<%=userPlaceInt_input_signal_array[j][idx]%>", signal_width_val_form, <%=placeholder_hierarchy[j]%>.<%=placeholder_inst_prefix%>.<%=userPlaceInt_input_signal_array[j][idx]%>));
         end else begin
           `uvm_info(report_id, $sformatf("userPlaceInt_input match: %0s ->{exp:%0d|act:%0d}", "<%=placeholder_hierarchy[j]%>.<%=placeholder_inst_prefix%>.<%=userPlaceInt_input_signal_array[j][idx]%>", signal_width_val_form, <%=placeholder_hierarchy[j]%>.<%=placeholder_inst_prefix%>.<%=userPlaceInt_input_signal_array[j][idx]%>), UVM_DEBUG);
         end
      <% } %>
         //release  <%=placeholder_hierarchy[j]%>.<%=placeholder_inst_prefix%>.<%=userPlaceInt_input_signal_array[j][idx]%> ;
         release  <%=hier_path_dut%>.<%=userPlaceInt_wrapper_sig_input_name[j]%> ;

         repeat(5)@(posedge tb_clk);

         <% if(userPlaceInt_wrapper_sig_input_name[j][idx].length != 0 && obj.DutInfo.ResilienceInfo.enableUnitDuplication) { %>
         if((<%=fault_hierarchy%>.fault_mission_fault != 'h0) || (<%=fault_hierarchy%>.fault_latent_fault != 'h0)) begin
           `uvm_error(report_id, $sformatf(" Fault mismatch for <%=userPlaceInt_input_signal_array[j][idx]%> : mission_fault{exp:%0d|act:%0d}, latent_fault{exp:%0d|act:%0d}", 1, <%=fault_hierarchy%>.fault_mission_fault, 0, <%=fault_hierarchy%>.fault_latent_fault));
         end else begin
           `uvm_info(report_id, $sformatf(" Fault match for <%=userPlaceInt_input_signal_array[j][idx]%>: mission_fault{exp:%0d|act:%0d}, latent_fault{exp:%0d|act:%0d}", 1, <%=fault_hierarchy%>.fault_mission_fault, 0, <%=fault_hierarchy%>.fault_latent_fault), UVM_LOW);
         end

         <% } %>


<% } %>
      end

<%} else {%>
      repeat(100) begin
      `uvm_info(report_id, $sformatf("\n%s %s %s\n",{4{"*"}},{40{"-"}},{4{"*"}}), UVM_NONE);
        //output
        signal_width_sum = 0;
        signal_width_val_op_da.delete();
        {inject_fault_in_checker_unit,inject_fault_in_func_unit} = $urandom_range(0,3);
        delay_bw_two_faults =  $urandom_range(1,3);

         <% for (var idx = 0; idx < userPlaceInt_output_signal_array[0].length; idx++) { %>

             signal_width[0][<%=idx%>] = $bits(<%=placeholder_hierarchy%>.<%=placeholder_inst_prefix%>.<%=userPlaceInt_output_signal_array[0][idx]%>);
             signal_width_sum = signal_width_sum + signal_width[0][<%=idx%>];
             repeat(1)@(posedge tb_clk);
             signal_width_val_force = $urandom_range(0,(2**signal_width[0][<%=idx%>])-1);
             for(int i=signal_width[0][<%=idx%>]-1; i>=0; i--) begin
               signal_width_val_op_da.push_back(signal_width_val_force[i]);
              
              end
       
              do begin
              Delay_signal_val   =  $urandom_range(0,(2**signal_width[0][<%=idx%>])-1);              
              end while(signal_width_val_force  == Delay_signal_val );
 
               case({inject_fault_in_checker_unit,inject_fault_in_func_unit})
                  'b00 : begin
                   // do nothing
                   start_out_cov_sample = 1;
                   placeholder_tb_mission_fault_ud = 0;
                   placeholder_tb_latent_fault_ud  = 0;
                         repeat(1)@(posedge tb_clk);
     
                          <% if(wrapper_sig_width_out > 1) { %>
                           for(int i=(signal_width_out-signal_width_sum+signal_width[0][<%=idx%>]-1);i>=(signal_width_out-signal_width_sum);i--) begin
                             if({inject_fault_in_checker_unit,inject_fault_in_func_unit}== 0) begin
                             signal_width_val = signal_width_val_op_da.pop_front();
                             signal_width_val = 0;
                             end else begin
                             signal_width_val = signal_width_val_op_da.pop_front();
                             end

                             if(<%=hier_path_dut%>.<%=userPlaceInt_wrapper_sig_output_name%>[i] != signal_width_val) begin
                               `uvm_error(report_id, $sformatf("userPlaceInt_output mismatch: %0s[%0d] ->{exp:%0d|act:%0d}", "<%=hier_path_dut%>.<%=userPlaceInt_wrapper_sig_output_name%>" ,(i), signal_width_val, <%=hier_path_dut%>.<%=userPlaceInt_wrapper_sig_output_name%>[i]));
                             end else begin
                               `uvm_info(report_id, $sformatf("userPlaceInt_output match: %0s[%0d] ->{exp:%0d|act:%0d}", "<%=hier_path_dut%>.<%=userPlaceInt_wrapper_sig_output_name%>" ,(i), signal_width_val, <%=hier_path_dut%>.<%=userPlaceInt_wrapper_sig_output_name%>[i]), UVM_DEBUG);
                             end
                           end
                           <% } else { %>
                                   if({inject_fault_in_checker_unit,inject_fault_in_func_unit}== 0 ) begin
                                   signal_width_val = signal_width_val_op_da.pop_front();
                                   signal_width_val = 0;
                                   end else begin
                                   signal_width_val = signal_width_val_op_da.pop_front();
                                   end

                                      if(<%=hier_path_dut%>.<%=userPlaceInt_wrapper_sig_output_name%> != signal_width_val) begin
                                        `uvm_error(report_id, $sformatf("userPlaceInt_output mismatch: %0s ->{exp:%0d|act:%0d}", "<%=hier_path_dut%>.<%=userPlaceInt_wrapper_sig_output_name%>" , signal_width_val, <%=hier_path_dut%>.<%=userPlaceInt_wrapper_sig_output_name%>));
                                      end else begin
                                        `uvm_info(report_id, $sformatf("userPlaceInt_output match: %0s ->{exp:%0d|act:%0d}", "<%=hier_path_dut%>.<%=userPlaceInt_wrapper_sig_output_name%>" , signal_width_val, <%=hier_path_dut%>.<%=userPlaceInt_wrapper_sig_output_name%>), UVM_DEBUG);
                                end
                             <% } %>

                           end
   
                  'b01 : begin
                   start_out_cov_sample = 1;
                     force  <%=placeholder_hierarchy[0]%>.<%=placeholder_inst_prefix%>.<%=userPlaceInt_output_signal_array[0][idx]%> = signal_width_val_force;
                     <% if (obj.DutInfo.ResilienceInfo.enableUnitDuplication) { %>
                     repeat(<%= nResiliencyDelay_json %>) @(posedge tb_clk);
                     force  <%=placeholder_hierarchy_duplicate[0]%>.<%=placeholder_inst_prefix%>.<%=userPlaceInt_output_signal_array[0][idx]%> =Delay_signal_val;

                      placeholder_tb_mission_fault_ud = 1;
                      placeholder_tb_latent_fault_ud  = 0;
                    <% } %>

                       repeat(<%= nResiliencyDelay_json %>) @(posedge tb_clk); //#3
                       repeat(2) @(posedge tb_clk);
                       start_checker_ilf = 1;
                       repeat(1)@(posedge tb_clk);

                        <% if(wrapper_sig_width_out > 1) { %>
                         for(int i=(signal_width_out-signal_width_sum+signal_width[0][<%=idx%>]-1);i>=(signal_width_out-signal_width_sum);i--) begin
                           if({inject_fault_in_checker_unit,inject_fault_in_func_unit}== 0) begin
                           signal_width_val = signal_width_val_op_da.pop_front();
                           signal_width_val = 0;
                           end else begin
                           signal_width_val = signal_width_val_op_da.pop_front();
                           end

                           if(<%=hier_path_dut%>.<%=userPlaceInt_wrapper_sig_output_name%>[i] != signal_width_val) begin
                             `uvm_error(report_id, $sformatf("userPlaceInt_output mismatch: %0s[%0d] ->{exp:%0d|act:%0d}", "<%=hier_path_dut%>.<%=userPlaceInt_wrapper_sig_output_name%>" ,(i), signal_width_val, <%=hier_path_dut%>.<%=userPlaceInt_wrapper_sig_output_name%>[i]));
                           end else begin
                             `uvm_info(report_id, $sformatf("userPlaceInt_output match: %0s[%0d] ->{exp:%0d|act:%0d}", "<%=hier_path_dut%>.<%=userPlaceInt_wrapper_sig_output_name%>" ,(i), signal_width_val, <%=hier_path_dut%>.<%=userPlaceInt_wrapper_sig_output_name%>[i]), UVM_DEBUG);
                           end
                         end
                       <% } else { %>
                          if({inject_fault_in_checker_unit,inject_fault_in_func_unit}== 0 ) begin
                           signal_width_val = signal_width_val_op_da.pop_front();
                           signal_width_val = 0;
                           end else begin
                           signal_width_val = signal_width_val_op_da.pop_front();
                          end

                         if(<%=hier_path_dut%>.<%=userPlaceInt_wrapper_sig_output_name%> != signal_width_val) begin
                           `uvm_error(report_id, $sformatf("userPlaceInt_output mismatch: %0s ->{exp:%0d|act:%0d}", "<%=hier_path_dut%>.<%=userPlaceInt_wrapper_sig_output_name%>" , signal_width_val, <%=hier_path_dut%>.<%=userPlaceInt_wrapper_sig_output_name%>));
                         end else begin
                           `uvm_info(report_id, $sformatf("userPlaceInt_output match: %0s ->{exp:%0d|act:%0d}", "<%=hier_path_dut%>.<%=userPlaceInt_wrapper_sig_output_name%>" , signal_width_val, <%=hier_path_dut%>.<%=userPlaceInt_wrapper_sig_output_name%>), UVM_DEBUG);
                         end
                       <% } %>
                              release  <%=placeholder_hierarchy[0]%>.<%=placeholder_inst_prefix%>.<%=userPlaceInt_output_signal_array[0][idx]%> ;
                        	<% if(obj.DutInfo.ResilienceInfo.enableUnitDuplication){ %>
                              release  <%=placeholder_hierarchy_duplicate[0]%>.<%=placeholder_inst_prefix%>.<%=userPlaceInt_output_signal_array[0][idx]%>;
                            <% } %>
                end
                 

               'b10 : begin
                   start_out_cov_sample = 1;
                   force  <%=placeholder_hierarchy[0]%>.<%=placeholder_inst_prefix%>.<%=userPlaceInt_output_signal_array[0][idx]%> = signal_width_val_force;
                   <% if(obj.DutInfo.ResilienceInfo.enableUnitDuplication){ %>
                   force  <%=placeholder_hierarchy_duplicate[0]%>.<%=placeholder_inst_prefix%>.<%=userPlaceInt_output_signal_array[0][idx]%> =Delay_signal_val;
                   placeholder_tb_mission_fault_ud = 1;
                   placeholder_tb_latent_fault_ud  = 0;
                   <% } %>
                   repeat(4) @(posedge tb_clk);
                   start_checker_ilf = 1;
                   repeat(1)@(posedge tb_clk);

                  <% if(wrapper_sig_width_out > 1) { %>
                     for(int i=(signal_width_out-signal_width_sum+signal_width[0][<%=idx%>]-1);i>=(signal_width_out-signal_width_sum);i--) begin
                       if({inject_fault_in_checker_unit,inject_fault_in_func_unit}== 0) begin
                       signal_width_val = signal_width_val_op_da.pop_front();
                       signal_width_val = 0;
                       end else begin
                       signal_width_val = signal_width_val_op_da.pop_front();
                       end

                       if(<%=hier_path_dut%>.<%=userPlaceInt_wrapper_sig_output_name%>[i] != signal_width_val) begin
                         `uvm_error(report_id, $sformatf("userPlaceInt_output mismatch: %0s[%0d] ->{exp:%0d|act:%0d}", "<%=hier_path_dut%>.<%=userPlaceInt_wrapper_sig_output_name%>" ,(i), signal_width_val, <%=hier_path_dut%>.<%=userPlaceInt_wrapper_sig_output_name%>[i]));
                       end else begin
                         `uvm_info(report_id, $sformatf("userPlaceInt_output match: %0s[%0d] ->{exp:%0d|act:%0d}", "<%=hier_path_dut%>.<%=userPlaceInt_wrapper_sig_output_name%>" ,(i), signal_width_val, <%=hier_path_dut%>.<%=userPlaceInt_wrapper_sig_output_name%>[i]), UVM_DEBUG);
                       end
                      end
                   
                  <% } else { %>
                       if({inject_fault_in_checker_unit,inject_fault_in_func_unit}== 0 ) begin
                       signal_width_val = signal_width_val_op_da.pop_front();
                       signal_width_val = 0;
                       end else begin
                       signal_width_val = signal_width_val_op_da.pop_front();
                       end

                       if(<%=hier_path_dut%>.<%=userPlaceInt_wrapper_sig_output_name%> != signal_width_val) begin
                       `uvm_error(report_id, $sformatf("userPlaceInt_output mismatch: %0s ->{exp:%0d|act:%0d}", "<%=hier_path_dut%>.<%=userPlaceInt_wrapper_sig_output_name%>" , signal_width_val, <%=hier_path_dut%>.<%=userPlaceInt_wrapper_sig_output_name%>));
                       end else begin
                       `uvm_info(report_id, $sformatf("userPlaceInt_output match: %0s ->{exp:%0d|act:%0d}", "<%=hier_path_dut%>.<%=userPlaceInt_wrapper_sig_output_name%>" , signal_width_val, <%=hier_path_dut%>.<%=userPlaceInt_wrapper_sig_output_name%>), UVM_DEBUG);
                       end
                    <% }%>
                   release  <%=placeholder_hierarchy[0]%>.<%=placeholder_inst_prefix%>.<%=userPlaceInt_output_signal_array[0][idx]%> ;
                    <% if(obj.DutInfo.ResilienceInfo.enableUnitDuplication){ %>
                   release  <%=placeholder_hierarchy_duplicate[0]%>.<%=placeholder_inst_prefix%>.<%=userPlaceInt_output_signal_array[0][idx]%>;
                   <% } %>
                 end
                      
                'b11 : begin
                   start_out_cov_sample = 1;
 		   force  <%=placeholder_hierarchy[0]%>.<%=placeholder_inst_prefix%>.<%=userPlaceInt_output_signal_array[0][idx]%> =signal_width_val_force;
		   repeat(<%= nResiliencyDelay_json %>)@(posedge tb_clk); //#1
 		   <% if(obj.DutInfo.ResilienceInfo.enableUnitDuplication){ %>
 		   force  <%=placeholder_hierarchy_duplicate[0]%>.<%=placeholder_inst_prefix%>.<%=userPlaceInt_output_signal_array[0][idx]%> = signal_width_val_force;
<% } %>

                   placeholder_tb_mission_fault_ud = 0;
                   placeholder_tb_latent_fault_ud  = 0;
                   repeat(2) @(posedge tb_clk);
                   start_checker_ilf = 1;

                    <% if(wrapper_sig_width_out > 1) { %>
                     for(int i=(signal_width_out-signal_width_sum+signal_width[0][<%=idx%>]-1);i>=(signal_width_out-signal_width_sum);i--) begin
                      if({inject_fault_in_checker_unit,inject_fault_in_func_unit}== 0) begin
                      signal_width_val = signal_width_val_op_da.pop_front();
                      signal_width_val = 0;
                      end else begin
                      signal_width_val = signal_width_val_op_da.pop_front();
                      end

                      if(<%=hier_path_dut%>.<%=userPlaceInt_wrapper_sig_output_name%>[i] != signal_width_val) begin
                        `uvm_error(report_id, $sformatf("userPlaceInt_output mismatch: %0s[%0d] ->{exp:%0d|act:%0d}", "<%=hier_path_dut%>.<%=userPlaceInt_wrapper_sig_output_name%>" ,(i), signal_width_val, <%=hier_path_dut%>.<%=userPlaceInt_wrapper_sig_output_name%>[i]));
                      end else begin
                        `uvm_info(report_id, $sformatf("userPlaceInt_output match: %0s[%0d] ->{exp:%0d|act:%0d}", "<%=hier_path_dut%>.<%=userPlaceInt_wrapper_sig_output_name%>" ,(i), signal_width_val, <%=hier_path_dut%>.<%=userPlaceInt_wrapper_sig_output_name%>[i]), UVM_DEBUG);
                      end
                    end
              <% } else { %>
                   if({inject_fault_in_checker_unit,inject_fault_in_func_unit}== 0 ) begin
                  signal_width_val = signal_width_val_op_da.pop_front();
                  signal_width_val = 0;
                  end else begin
                  signal_width_val = signal_width_val_op_da.pop_front();
                  end
                  if(<%=hier_path_dut%>.<%=userPlaceInt_wrapper_sig_output_name%> != signal_width_val) begin
                  `uvm_error(report_id, $sformatf("userPlaceInt_output mismatch: %0s ->{exp:%0d|act:%0d}", "<%=hier_path_dut%>.<%=userPlaceInt_wrapper_sig_output_name%>" , signal_width_val, <%=hier_path_dut%>.<%=userPlaceInt_wrapper_sig_output_name%>));
                  end else begin
                   `uvm_info(report_id, $sformatf("userPlaceInt_output match: %0s ->{exp:%0d|act:%0d}", "<%=hier_path_dut%>.<%=userPlaceInt_wrapper_sig_output_name%>" , signal_width_val, <%=hier_path_dut%>.<%=userPlaceInt_wrapper_sig_output_name%>), UVM_DEBUG);
                end
             <% } %>

                   
                  repeat(5) @(posedge tb_clk); //#2
                  release  <%=placeholder_hierarchy[0]%>.<%=placeholder_inst_prefix%>.<%=userPlaceInt_output_signal_array[0][idx]%> ;
                  repeat(<%= nResiliencyDelay_json %>) @(posedge tb_clk);
                  <% if(obj.DutInfo.ResilienceInfo.enableUnitDuplication){ %>
                  release  <%=placeholder_hierarchy_duplicate[0]%>.<%=placeholder_inst_prefix%>.<%=userPlaceInt_output_signal_array[0][idx]%>;
                  <% } %>
              end
               endcase

         `uvm_info(report_id, $sformatf("Forcing placeholder output signal %s with {%0p}", "<%=placeholder_hierarchy%>.<%=placeholder_inst_prefix%>.<%=userPlaceInt_output_signal_array[0][idx]%>", signal_width_val_op_da), UVM_NONE);
                   
          repeat(5)@(posedge tb_clk);

         <% if(userPlaceInt_output_signal_array[0][idx].length != 0 && obj.DutInfo.ResilienceInfo.enableUnitDuplication) { %>
         if((<%=fault_hierarchy%>.fault_mission_fault != placeholder_tb_mission_fault_ud) || (<%=fault_hierarchy%>.fault_latent_fault != placeholder_tb_latent_fault_ud)) begin
           `uvm_error(report_id, $sformatf(" Fault mismatch for <%=userPlaceInt_output_signal_array[0][idx]%> : mission_fault{exp:%0d|act:%0d}, latent_fault{exp:%0d|act:%0d}", placeholder_tb_mission_fault_ud, <%=fault_hierarchy%>.fault_mission_fault, placeholder_tb_latent_fault_ud, <%=fault_hierarchy%>.fault_latent_fault));
         end else begin
           `uvm_info(report_id, $sformatf(" Fault match for <%=userPlaceInt_output_signal_array[0][idx]%>: mission_fault{exp:%0d|act:%0d}, latent_fault{exp:%0d|act:%0d}", placeholder_tb_mission_fault_ud, <%=fault_hierarchy%>.fault_mission_fault, placeholder_tb_latent_fault_ud, <%=fault_hierarchy%>.fault_latent_fault), UVM_LOW);
         end
        // clear any fault generated before if any...
        repeat(5)@(posedge tb_clk);
        bist_reset_seq();
        repeat(5)@(posedge tb_clk);

           <% } %>

        <% } %>

        //input
        signal_width_sum = 0;
        signal_width_val_ip_da.delete();
        repeat(1)@(posedge tb_clk);
        <% if(wrapper_sig_width_in != 0) { %>
          signal_width_val_force = $urandom_range(1,(2**signal_width_in)-1);
          for(int i=signal_width_in-1; i>=0; i--) begin
            signal_width_val_ip_da.push_back(signal_width_val_force[i]);
          end
          `uvm_info(report_id, $sformatf("\nForcing wrapper input signal %s with {%0p}", "<%=hier_path_dut%>.<%=userPlaceInt_wrapper_sig_input_name%>", signal_width_val_ip_da), UVM_NONE);
          force  <%=hier_path_dut%>.<%=userPlaceInt_wrapper_sig_input_name%> = signal_width_val_force;
        <% } %>
      <% for (var idx = 0; idx < userPlaceInt_input_signal_array[0].length; idx++) { %>
         signal_width[0][<%=idx%>] = $bits(<%=placeholder_hierarchy%>.<%=placeholder_inst_prefix%>.<%=userPlaceInt_input_signal_array[0][idx]%>);
         signal_width_sum = signal_width_sum + signal_width[0][<%=idx%>];
         signal_width_val_form = 0;
         for(int i=(signal_width[0][<%=idx%>]-1); i>=0; i--) begin
           signal_width_val = signal_width_val_ip_da.pop_front();
           signal_width_val_form = {signal_width_val_form, signal_width_val};
         end
         repeat(1)@(posedge tb_clk);
         if(<%=placeholder_hierarchy%>.<%=placeholder_inst_prefix%>.<%=userPlaceInt_input_signal_array[0][idx]%> != signal_width_val_form) begin
           `uvm_error(report_id, $sformatf("userPlaceInt_input mismatch: %0s ->{exp:%0d|act:%0d}", "<%=placeholder_hierarchy%>.<%=placeholder_inst_prefix%>.<%=userPlaceInt_input_signal_array[0][idx]%>", signal_width_val_form, <%=placeholder_hierarchy%>.<%=placeholder_inst_prefix%>.<%=userPlaceInt_input_signal_array[0][idx]%>));
         end else begin
           `uvm_info(report_id, $sformatf("userPlaceInt_input match: %0s ->{exp:%0d|act:%0d}", "<%=placeholder_hierarchy%>.<%=placeholder_inst_prefix%>.<%=userPlaceInt_input_signal_array[0][idx]%>", signal_width_val_form, <%=placeholder_hierarchy%>.<%=placeholder_inst_prefix%>.<%=userPlaceInt_input_signal_array[0][idx]%>), UVM_DEBUG);
         end
         release  <%=hier_path_dut%>.<%=userPlaceInt_wrapper_sig_input_name%> ;

    
     <% } %>
end     
<%}%>

      // test the placeholder fault
for(int i_ilf=0;i_ilf<4;i_ilf++) begin

 {inject_fault_in_checker_unit,inject_fault_in_func_unit} = $urandom_range(0,3);

<%  if(obj.testBench == "io_aiu" && obj.DutInfo.nNativeInterfacePorts > 1) { %>
  delay_bw_two_faults =  $urandom_range(1,3);

    <%  for(var j = 0; j < obj.DutInfo.nNativeInterfacePorts; j++){%>
      <% for (var idx = 0; idx < placeholder_fault_output_signal_array[j][0].length; idx++) { %>
         @(posedge tb_clk);
         signal_width[<%=j%>][<%=idx%>] = $bits(<%=placeholder_hierarchy[j]%>.<%=placeholder_inst_prefix%>.<%=placeholder_fault_output_signal_array[j][0][idx]%>);
              signal_width_val_force = $urandom_range(1,(2**signal_width[<%=j%>][<%=idx%>])-1);
              do begin
              Delay_signal_val   =  $urandom_range(0,(2**signal_width[<%=j%>][<%=idx%>])-1); 
              end while(signal_width_val_force  == Delay_signal_val ); 
         //#Check.IOAIU.Placeholder.cerr_fault
         //#Check.IOAIU.Placeholder.interface_fault
        //#Stimulus.IOAIU.Resilience.Placeholder
         case({inject_fault_in_checker_unit,inject_fault_in_func_unit})
                 'b00 : begin
                   // do nothing
                   start_out_cov_sample = 1;
                   placeholder_tb_mission_fault_ud = 0;
                   placeholder_tb_latent_fault_ud  = 0;
                  end
   
                  'b01 : begin
                   start_out_cov_sample = 1;
                  repeat(<%= nResiliencyDelay_json %>) @(posedge tb_clk);

                   `uvm_info(report_id, $sformatf("\nForcing  placeholder_fault_output signal  %s", "<%=placeholder_hierarchy[j]%>.<%=placeholder_inst_prefix%>.<%=placeholder_fault_output_signal_array[j][0][idx]%>"), UVM_DEBUG);
   
         
                    force  <%=placeholder_hierarchy[j]%>.<%=placeholder_inst_prefix%>.<%=placeholder_fault_output_signal_array[j][0][idx]%> =signal_width_val_force;
                    <% if(obj.DutInfo.ResilienceInfo.enableUnitDuplication){ %>
                    force  <%=placeholder_hierarchy_duplicate[j]%>.<%=placeholder_inst_prefix%>.<%=placeholder_fault_output_signal_array[j][0][idx]%> = Delay_signal_val;
                    <% } %>
                   `uvm_info(report_id, $sformatf("\nForcing  placeholder_fault_output signal  %s", "<%=placeholder_hierarchy[j]%>.<%=placeholder_inst_prefix%>.<%=placeholder_fault_output_signal_array[j][0][idx]%>"), UVM_DEBUG);
                    
                   if("<%=placeholder_fault_output_signal_array[0][idx]%>" == "cerr_fault") begin
                   <% if(obj.DutInfo.ResilienceInfo.enableUnitDuplication){ %>

                       placeholder_tb_mission_fault_ud = 1;
                       placeholder_tb_latent_fault_ud  = 0; 
                       <% } else { %>
                       placeholder_tb_mission_fault_ud = 0;
                       placeholder_tb_latent_fault_ud  = 0;
                       <% } %>
                
                       end else begin 
                       placeholder_tb_mission_fault_ud = 1;
                       placeholder_tb_latent_fault_ud  = 1;
                       end

                       repeat(<%= nResiliencyDelay_json %>) @(posedge tb_clk); //#3
                       repeat(2) @(posedge tb_clk);
                       start_checker_ilf = 1;
                       release  <%=placeholder_hierarchy[j]%>.<%=placeholder_inst_prefix%>.<%=placeholder_fault_output_signal_array[j][0][idx]%> ;
        	       repeat(<%= nResiliencyDelay_json %>) @(posedge tb_clk);
          	       <% if(obj.DutInfo.ResilienceInfo.enableUnitDuplication){ %>
                       release  <%=placeholder_hierarchy_duplicate[j]%>.<%=placeholder_inst_prefix%>.<%=placeholder_fault_output_signal_array[j][0][idx]%>;
                     <% } %>
                    end
                 

               'b10 : begin
                    start_out_cov_sample = 1;
                       force  <%=placeholder_hierarchy[j]%>.<%=placeholder_inst_prefix%>.<%=placeholder_fault_output_signal_array[j][0][idx]%> =signal_width_val_force;
                       <% if(obj.DutInfo.ResilienceInfo.enableUnitDuplication){ %>
                       force  <%=placeholder_hierarchy_duplicate[j]%>.<%=placeholder_inst_prefix%>.<%=placeholder_fault_output_signal_array[j][0][idx]%> = Delay_signal_val;  
                       <% } %>

                     		if("<%=placeholder_fault_output_signal_array[0][idx]%>" == "cerr_fault") begin
                                <% if(obj.DutInfo.ResilienceInfo.enableUnitDuplication){ %>
                     		placeholder_tb_mission_fault_ud= 1;
                     		placeholder_tb_latent_fault_ud  = 0;
                     		<% } else { %>
                     		placeholder_tb_mission_fault_ud = 0;
                     		placeholder_tb_latent_fault_ud  = 0;
                     		 <% } %>
                     		end else begin 
                     		placeholder_tb_mission_fault_ud = 1;
                     		placeholder_tb_latent_fault_ud  = 1;
                     		end
                     		repeat(4) @(posedge tb_clk);
                     		start_checker_ilf = 1;
		                release  <%=placeholder_hierarchy[j]%>.<%=placeholder_inst_prefix%>.<%=placeholder_fault_output_signal_array[j][0][idx]%> ;
                                repeat(<%= nResiliencyDelay_json %>) @(posedge tb_clk);
                                 <% if(obj.DutInfo.ResilienceInfo.enableUnitDuplication){ %>
                                release  <%=placeholder_hierarchy_duplicate[j]%>.<%=placeholder_inst_prefix%>.<%=placeholder_fault_output_signal_array[j][0][idx]%>;
                                <% } %>
                               end
                      
                'b11 : begin
                          start_out_cov_sample = 1;
                          force  <%=placeholder_hierarchy[j]%>.<%=placeholder_inst_prefix%>.<%=placeholder_fault_output_signal_array[j][0][idx]%> =signal_width_val_force;
                          repeat(<%= nResiliencyDelay_json %>)@(posedge tb_clk); //#1
                          <% if(obj.DutInfo.ResilienceInfo.enableUnitDuplication){ %>
                          force  <%=placeholder_hierarchy_duplicate[j]%>.<%=placeholder_inst_prefix%>.<%=placeholder_fault_output_signal_array[j][0][idx]%> = signal_width_val_force;
                          <% } %>

                              if("<%=placeholder_fault_output_signal_array[0][idx]%>" == "cerr_fault") begin                   
                              placeholder_tb_mission_fault_ud = 0;
                              placeholder_tb_latent_fault_ud  = 0;
                              end else begin
                              placeholder_tb_mission_fault_ud = 1;
                              placeholder_tb_latent_fault_ud  = 0;
                              end
                              repeat(2) @(posedge tb_clk);
                              start_checker_ilf = 1;
                              repeat(5) @(posedge tb_clk); //#2
      	 	              release  <%=placeholder_hierarchy[j]%>.<%=placeholder_inst_prefix%>.<%=placeholder_fault_output_signal_array[j][0][idx]%> ;
                              repeat(<%= nResiliencyDelay_json %>) @(posedge tb_clk);
                              <% if(obj.DutInfo.ResilienceInfo.enableUnitDuplication){ %>
                              release  <%=placeholder_hierarchy_duplicate[j]%>.<%=placeholder_inst_prefix%>.<%=placeholder_fault_output_signal_array[j][0][idx]%>;                
                              <% } %>
               end
               endcase
               repeat(delay_bw_two_faults*10) @(posedge tb_clk);
               start_checker_ilf = 0;
               start_out_cov_sample = 0;
                 //#Cover.IOAIU.Placeholder.fault
                 repeat(5)@(posedge tb_clk);
                 <% if((placeholder_fault_output_signal_array[0].length != 0) && (obj.useResiliency)) { %>
                 if("<%=placeholder_fault_output_signal_array[0][idx]%>" == "cerr_fault") begin
                 if(!((<%=fault_hierarchy%>.fault_mission_fault == placeholder_tb_mission_fault_ud) || (<%=fault_hierarchy%>.fault_latent_fault == placeholder_tb_latent_fault_ud))) begin
                    `uvm_error(report_id, $sformatf(" Fault mismatch: mission_fault for cerr_fault {exp:%0d|act:%0d}, latent_fault{exp:%0d|act:%0d}", placeholder_tb_mission_fault_ud, <%=fault_hierarchy%>.fault_mission_fault, placeholder_tb_latent_fault_ud, <%=fault_hierarchy%>.fault_latent_fault));
                 end else begin
                 `uvm_info(report_id, $sformatf(" Fault match: mission_fault{exp:%0d|act:%0d}, latent_fault{exp:%0d|act:%0d}", placeholder_tb_mission_fault_ud, <%=fault_hierarchy%>.fault_mission_fault,placeholder_tb_latent_fault_ud, <%=fault_hierarchy%>.fault_latent_fault), UVM_LOW);
                 end
                  if((<%=hier_path_dut%>.<%=func_checker_inst_name%>.cerr_counter <= 'h0) && {inject_fault_in_checker_unit,inject_fault_in_func_unit} == 3) begin
                  `uvm_error(report_id, $sformatf(" CERR error not detected: cerr_counter=%0d", <%=hier_path_dut%>.<%=func_checker_inst_name%>.cerr_counter));
                  end else begin
                   `uvm_info(report_id, $sformatf(" CERR error detected: cerr_counter=%0d", <%=hier_path_dut%>.<%=func_checker_inst_name%>.cerr_counter), UVM_LOW);
                   end
                  end else if("<%=placeholder_fault_output_signal_array[0][idx]%>" == "interface_fault") begin
                  if(!((<%=fault_hierarchy%>.fault_mission_fault == placeholder_tb_mission_fault_ud) || (<%=fault_hierarchy%>.fault_latent_fault == placeholder_tb_latent_fault_ud))) begin
                  `uvm_error(report_id, $sformatf(" Fault mismatch: mission_fault for interface_fault{exp:%0d|act:%0d}, latent_fault{exp:%0d|act:%0d}",placeholder_tb_mission_fault_ud, <%=fault_hierarchy%>.fault_mission_fault, placeholder_tb_latent_fault_ud, <%=fault_hierarchy%>.fault_latent_fault));
                   end else begin
                   `uvm_info(report_id, $sformatf(" Fault match: mission_fault{exp:%0d|act:%0d}, latent_fault{exp:%0d|act:%0d}", placeholder_tb_mission_fault_ud, <%=fault_hierarchy%>.fault_mission_fault, placeholder_tb_latent_fault_ud, <%=fault_hierarchy%>.fault_latent_fault), UVM_LOW);
                    end
                end

         // clear any fault generated before if any...
         repeat(5)@(posedge tb_clk);
         bist_reset_seq();
         repeat(5)@(posedge tb_clk);
         <% } %>

      <% } %>
      <% } %>
<%  } else { %>
      <% for (var idx = 0; idx < placeholder_fault_output_signal_array[0].length; idx++) { %>
         @(posedge tb_clk);
          delay_bw_two_faults =  $urandom_range(1,3);

         {inject_fault_in_checker_unit,inject_fault_in_func_unit} = $urandom_range(0,3);

         signal_width[<%=0%>][<%=idx%>] = $bits(<%=placeholder_hierarchy[0]%>.<%=placeholder_inst_prefix%>.<%=placeholder_fault_output_signal_array[0][idx]%>);
                  signal_width_val_force = $urandom_range(1,(2**signal_width[0][<%=idx%>])-1);
              do begin
              Delay_signal_val   =  $urandom_range(0,(2**signal_width[0][<%=idx%>])-1); 
              end while(signal_width_val_force  == Delay_signal_val );
          `uvm_info("check case value", $sformatf("inject_fault_in_checker_unit   %0d   inject_fault_in_func_unit   %0d  ",inject_fault_in_checker_unit,inject_fault_in_func_unit), UVM_NONE);
               case({inject_fault_in_checker_unit,inject_fault_in_func_unit})
                 'b00 : begin
                   // do nothing
                   start_out_cov_sample = 1;
                   placeholder_tb_mission_fault_ud = 0;
                   placeholder_tb_latent_fault_ud  = 0;
                  end
   
                  'b01 : begin
                   start_out_cov_sample = 1;
                  repeat(<%= nResiliencyDelay_json %>) @(posedge tb_clk);

                   `uvm_info(report_id, $sformatf("\nForcing  placeholder_fault_output signal  %s", "<%=placeholder_hierarchy[0]%>.<%=placeholder_inst_prefix%>.<%=placeholder_fault_output_signal_array[0][idx]%>"), UVM_DEBUG);
         
                          force  <%=placeholder_hierarchy[0]%>.<%=placeholder_inst_prefix%>.<%=placeholder_fault_output_signal_array[0][idx]%> =signal_width_val_force;
                          <% if(obj.DutInfo.ResilienceInfo.enableUnitDuplication){ %>
                          force  <%=placeholder_hierarchy_duplicate[0]%>.<%=placeholder_inst_prefix%>.<%=placeholder_fault_output_signal_array[0][idx]%> = Delay_signal_val;
                          <% } %>
                          if("<%=placeholder_fault_output_signal_array[0][idx]%>" == "cerr_fault") begin
                          <% if(obj.DutInfo.ResilienceInfo.enableUnitDuplication){ %>

                         placeholder_tb_mission_fault_ud = 1;
                         placeholder_tb_latent_fault_ud  = 0;
                          <% } else { %>
                         placeholder_tb_mission_fault_ud = 0;
                         placeholder_tb_latent_fault_ud  = 0;
                          <% } %>
      
                            end else begin 
                            placeholder_tb_mission_fault_ud = 1;
                            <% if(obj.DutInfo.ResilienceInfo.enableUnitDuplication){ %>
                            placeholder_tb_latent_fault_ud  = 0;
                            <% } else { %>
                            placeholder_tb_latent_fault_ud  = 0;
                              <% } %>  
                            end
                            repeat(<%= nResiliencyDelay_json %>) @(posedge tb_clk); //#3
                            repeat(2) @(posedge tb_clk);
                            start_checker_ilf = 1;
        

                              release  <%=placeholder_hierarchy[0]%>.<%=placeholder_inst_prefix%>.<%=placeholder_fault_output_signal_array[0][idx]%> ;
                              repeat(<%= nResiliencyDelay_json %>) @(posedge tb_clk);
                              <% if(obj.DutInfo.ResilienceInfo.enableUnitDuplication){ %>
                              release  <%=placeholder_hierarchy_duplicate[0]%>.<%=placeholder_inst_prefix%>.<%=placeholder_fault_output_signal_array[0][idx]%>;
                              <% } %>
                 end
                 

               'b10 : begin
                   start_out_cov_sample = 1;
                      force  <%=placeholder_hierarchy[0]%>.<%=placeholder_inst_prefix%>.<%=placeholder_fault_output_signal_array[0][idx]%> =signal_width_val_force;
               	      <% if(obj.DutInfo.ResilienceInfo.enableUnitDuplication){ %>
                      force  <%=placeholder_hierarchy_duplicate[0]%>.<%=placeholder_inst_prefix%>.<%=placeholder_fault_output_signal_array[0][idx]%> = Delay_signal_val;
                      <% } %>

                             if("<%=placeholder_fault_output_signal_array[0][idx]%>" == "cerr_fault") begin 
                            <% if(obj.DutInfo.ResilienceInfo.enableUnitDuplication){ %>
                            placeholder_tb_mission_fault_ud = 1;
                            placeholder_tb_latent_fault_ud  = 0;
                            <%}else {%>
                            placeholder_tb_mission_fault_ud = 0;
                            placeholder_tb_latent_fault_ud  = 0;
                            <% }%>
                            end else begin 
                            placeholder_tb_mission_fault_ud = 1;
                            <% if(obj.DutInfo.ResilienceInfo.enableUnitDuplication){ %>
                            placeholder_tb_latent_fault_ud  = 0;
                            <% } else {%>
                            placeholder_tb_latent_fault_ud  = 0;
                             <% } %>
                            end
                            repeat(4) @(posedge tb_clk);
                            start_checker_ilf = 1;
                            release  <%=placeholder_hierarchy[0]%>.<%=placeholder_inst_prefix%>.<%=placeholder_fault_output_signal_array[0][idx]%> ;
                            repeat(<%= nResiliencyDelay_json %>) @(posedge tb_clk);
                            <% if(obj.DutInfo.ResilienceInfo.enableUnitDuplication){ %>
                            release  <%=placeholder_hierarchy_duplicate[0]%>.<%=placeholder_inst_prefix%>.<%=placeholder_fault_output_signal_array[0][idx]%>;
                           <% } %>
                end
                      
                'b11 : begin
                   start_out_cov_sample = 1;
                   force  <%=placeholder_hierarchy[0]%>.<%=placeholder_inst_prefix%>.<%=placeholder_fault_output_signal_array[0][idx]%> = signal_width_val_force;
                   repeat(<%= nResiliencyDelay_json %>)@(posedge tb_clk); //#1
                   <% if(obj.DutInfo.ResilienceInfo.enableUnitDuplication){ %>
                   force  <%=placeholder_hierarchy_duplicate[0]%>.<%=placeholder_inst_prefix%>.<%=placeholder_fault_output_signal_array[0][idx]%> = signal_width_val_force;
                   <% } %>

                         if("<%=placeholder_fault_output_signal_array[0][idx]%>" == "cerr_fault") begin 
                         placeholder_tb_mission_fault_ud = 0;
                         placeholder_tb_latent_fault_ud  = 0;
                         end else begin
                         placeholder_tb_mission_fault_ud = 1;
                         placeholder_tb_latent_fault_ud  = 0;
                          end
                         repeat(2) @(posedge tb_clk);
                         start_checker_ilf = 1;
                         repeat(5) @(posedge tb_clk); //#2
      	 	         release  <%=placeholder_hierarchy[0]%>.<%=placeholder_inst_prefix%>.<%=placeholder_fault_output_signal_array[0][idx]%> ;
                        repeat(<%= nResiliencyDelay_json %>) @(posedge tb_clk);
                       <% if(obj.DutInfo.ResilienceInfo.enableUnitDuplication){ %>
                        release  <%=placeholder_hierarchy_duplicate[0]%>.<%=placeholder_inst_prefix%>.<%=placeholder_fault_output_signal_array[0][idx]%>;
                       <% } %>

               end
           endcase
          repeat(5)@(posedge tb_clk);
          <% if((placeholder_fault_output_signal_array[0].length != 0) && (obj.useResiliency)) { %>
          if("<%=placeholder_fault_output_signal_array[0][idx]%>" == "cerr_fault") begin
          if(!((<%=fault_hierarchy%>.fault_mission_fault == placeholder_tb_mission_fault_ud ) && (<%=fault_hierarchy%>.fault_latent_fault == placeholder_tb_latent_fault_ud))) begin
           `uvm_error(report_id, $sformatf(" Fault mismatch: mission_fault for cerr_fault {exp:%0d|act:%0d}, latent_fault{exp:%0d|act:%0d}", placeholder_tb_mission_fault_ud, <%=fault_hierarchy%>.fault_mission_fault,placeholder_tb_latent_fault_ud , <%=fault_hierarchy%>.fault_latent_fault));
         end else begin
           `uvm_info(report_id, $sformatf(" Fault match: mission_fault{exp:%0d|act:%0d}, latent_fault{exp:%0d|act:%0d}", placeholder_tb_mission_fault_ud, <%=fault_hierarchy%>.fault_mission_fault,placeholder_tb_latent_fault_ud, <%=fault_hierarchy%>.fault_latent_fault), UVM_LOW);
         end
          if((<%=hier_path_dut%>.<%=func_checker_inst_name%>.cerr_counter <= 'h0) && {inject_fault_in_checker_unit,inject_fault_in_func_unit} == 3) begin
           `uvm_error(report_id, $sformatf(" CERR error not detected: cerr_counter=%0d", <%=hier_path_dut%>.<%=func_checker_inst_name%>.cerr_counter));
         end else begin
           `uvm_info(report_id, $sformatf(" CERR error detected: cerr_counter=%0d", <%=hier_path_dut%>.<%=func_checker_inst_name%>.cerr_counter), UVM_LOW);
         end
         end else if("<%=placeholder_fault_output_signal_array[0][idx]%>" == "interface_fault") begin
             if(!((<%=fault_hierarchy%>.fault_mission_fault == placeholder_tb_mission_fault_ud) && (<%=fault_hierarchy%>.fault_latent_fault == placeholder_tb_latent_fault_ud))) begin
           `uvm_error(report_id, $sformatf(" Fault mismatch: mission_fault for interface_fault{exp:%0d|act:%0d}, latent_fault{exp:%0d|act:%0d}", placeholder_tb_mission_fault_ud, <%=fault_hierarchy%>.fault_mission_fault, placeholder_tb_latent_fault_ud, <%=fault_hierarchy%>.fault_latent_fault));
         end else begin
           `uvm_info(report_id, $sformatf(" Fault match: mission_fault{exp:%0d|act:%0d}, latent_fault{exp:%0d|act:%0d}",placeholder_tb_mission_fault_ud , <%=fault_hierarchy%>.fault_mission_fault, placeholder_tb_latent_fault_ud, <%=fault_hierarchy%>.fault_latent_fault), UVM_LOW);
         end
         end

          // clear any fault generated before if any...
          repeat(5)@(posedge tb_clk);
          bist_reset_seq();
          repeat(5)@(posedge tb_clk);
          <% } %>
      <% } %>
<%  } %>
 end
end
<% if((obj.testBench == 'dii')||(obj.testBench == 'dmi')||(obj.testBench == 'chi_aiu')||(obj.testBench == 'io_aiu')) { %>
`ifndef VCS
    -> kill_test;
`else // `ifndef VCS
    kill_test.trigger();
`endif // `ifndef VCS ... `else ... 
<% } else {%>
    -> kill_test;
<% } %>

   <% } %>
  end

 <%if(obj.useResiliency){%>
  // Following task executes the Bist reset sequence
  task bist_reset_seq();
    wait(tb_rstn === 1'b1);
    for(int i=0; i<6; i++) begin
      @(posedge tb_clk);
      force <%=hier_path_dut[0]%>.bist_bist_next = 1'b1;
      wait(<%=hier_path_dut[0]%>.bist_bist_next_ack === 1'b1);
      force <%=hier_path_dut[0]%>.bist_bist_next = 1'b0;
      @(posedge tb_clk);
      wait(<%=hier_path_dut[0]%>.bist_bist_next_ack === 1'b0);
      release <%=hier_path_dut[0]%>.bist_bist_next;
      `uvm_info(report_id ,$sformatf("BIST RESET step %0d done", i), UVM_NONE)
    end
  endtask : bist_reset_seq
 <%}%>

endmodule: placeholder_connectivity_checker

<% } %>
`endif
