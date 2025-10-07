
`ifndef GUARD_DCE_CSR_SEQ_LIB
`define GUARD_DCE_CSR_SEQ_LIB
<% var has_secded = 0; %>
<% var filter_secded = 0; %>
<% var filter_parity = 0; %>
<% var total_sf_ways = 0; %>
<% obj.SnoopFilterInfo.forEach(function(bundle) {
    if(bundle.fnFilterType === "EXPLICITOWNER") {
        total_sf_ways += bundle.nWays;
    }
});
%>
<% obj.SnoopFilterInfo.forEach(function sfways(item,index){ %>
  <%if(item.TagFilterErrorInfo.fnErrDetectCorrect === "SECDED" || item.TagFilterErrorInfo.fnErrDetectCorrect === "PARITY") {%>
    <% has_secded = 1; %>
  <% } %>
<% }); %>
<% obj.SnoopFilterInfo.forEach(function sfways(item,index){ %>
  <%if(item.TagFilterErrorInfo.fnErrDetectCorrect === "SECDED") {%>
      <% filter_secded = 1; %>
  <% } %>
<% }); %>
<% obj.SnoopFilterInfo.forEach(function sfways(item,index){ %>
  <%if(item.TagFilterErrorInfo.fnErrDetectCorrect === "PARITY") {%>
      <% filter_parity = 1; %>
  <% } %>
<% }); %>
<% if (filter_secded == 1) { %>
bit filter_secded = 1;
<% } else { %>
bit filter_secded = 0;
<% } %>
<% if (filter_parity == 1) { %>
bit filter_parity = 1;
<% } else { %>
bit filter_parity = 0;
<% } %>
//-----------------------------------------------------------------------
//-----------------------------------------------------------------------
//  Task    : dce_csr_id_reset_seq
//  Purpose : test unit ids against json, rather than cpr
//
//-----------------------------------------------------------------------
class dce_csr_id_reset_seq extends ral_csr_base_seq; 
   `uvm_object_utils(dce_csr_id_reset_seq)

    uvm_reg_data_t read_data;

    function new(string name="");
        super.new(name);
    endfunction

    task body();
       read_data = 'hDEADBEEF ;  //bogus sentinel

       read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUIDR.RPN, read_data);
       compareValues("DCEUIDR_RPN", "should be <%=obj.DceInfo[obj.Id].rpn%> (json)", read_data, <%=obj.DceInfo[obj.Id].rpn%>);  //TODO FIXME meaningful values from json
       read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUIDR.NRRI, read_data);
       compareValues("DCEUIDR_NRRI", "should be <%=obj.DceInfo[obj.Id].nrri%> (json)", read_data, <%=obj.DceInfo[obj.Id].nrri%>);  //TODO FIXME meaningful values from json
       read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUIDR.NUnitId, read_data);
       compareValues("DCEUIDR_NUnitId", "should be <%=obj.DceInfo[obj.Id].nUnitId%>", read_data, <%=obj.DceInfo[obj.Id].nUnitId%>);
       read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUIDR.Valid, read_data);
       compareValues("DCEUIDR_Valid", "should always be 1", read_data, 1);  
       read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUFUIDR.FUnitId, read_data);
       compareValues("DCEUFUIDR_FUnitId", "should be <%=obj.DceInfo[obj.Id].FUnitId%> (json)", read_data, <%=obj.DceInfo[obj.Id].FUnitId%>);
    endtask
endclass : dce_csr_id_reset_seq

//-----------------------------------------------------------------------
//   base method for chi_aiu 
//-----------------------------------------------------------------------
class dce_ral_csr_base_seq extends ral_csr_base_seq;

    virtual <%=obj.BlockId%>_probe_if u_csr_probe_vif;
    <% for (var i = 0; i < obj.nSmiRx; i++) { %>
    virtual <%=obj.BlockId%>_smi_if   m_smi<%=i%>_tx_vif;
    <% } %>
    uvm_event_pool ev_pool = uvm_event_pool::get_global_pool();
    uvm_event ev = ev_pool.get("ev");
    uvm_event ev_always_inject_error = ev_pool.get("ev_always_inject_error");
    uvm_event csr_test_time_out_recall_ev = ev_pool.get("csr_test_time_out_recall_ev");
    uvm_event ev_fliter_memory_warmed_up = ev_pool.get("ev_fliter_memory_warmed_up");
    uvm_event ev_ready_for_mem_trigger = ev_pool.get("ev_ready_for_mem_trigger");
    uvm_event ev_last_cmdreq_issued = ev_pool.get("ev_last_cmdreq_issued");
    uvm_event ev_last_scb_txn = ev_pool.get("ev_last_scb_txn");
    uvm_event ev_first_scb_txn = ev_pool.get("ev_first_scb_txn");
    <% obj.SnoopFilterInfo.forEach(function sfways(item,index){ %>
      <% for(var i=0;i<item.nWays;i++){ %>
    uvm_event         injectSingleErrTag<%=index%>_<%=i%>;
    uvm_event         injectDoubleErrTag<%=index%>_<%=i%>;
    uvm_event         inject_multi_block_single_double_ErrTag<%=index%>_<%=i%>;
    uvm_event         inject_multi_block_double_ErrTag<%=index%>_<%=i%>;
    uvm_event         inject_multi_block_single_ErrTag<%=index%>_<%=i%>;
    uvm_event         injectAddrErrTag<%=index%>_<%=i%>;
      <% } %>
    <% }); %>
    bit [WSMIADDR:0] err_injected_addr;
    bit memory_warmed_up;
    dce_scb dce_sb;
    bit [ncoreConfigInfo::WSFSETIDX-1:0] err_injected_index;
    bit [<%=total_sf_ways%>-1:0] err_injected_way;
    virtual <%=obj.BlockId%>_apb_if  apb_vif;
    //dce_unit_args m_unit_args;
    function new(string name="");
        super.new(name);
    endfunction

    function bit [`UVM_REG_ADDR_WIDTH-1 : 0] get_unmapped_csr_addr();
      bit [`UVM_REG_ADDR_WIDTH-1 : 0] all_csr_addr[$];
      typedef struct packed {
                             bit [`UVM_REG_ADDR_WIDTH-1 : 0] lower_addr;
                             bit [`UVM_REG_ADDR_WIDTH-1 : 0] upper_addr;
                            } csr_addr;
      csr_addr csr_unmapped_addr_range[$];
      int randomly_selected_unmapped_csr_sddr;
      
      <% obj.DceInfo[obj.Id].csr.spaceBlock[0].registers.forEach(function GetAllregAddr(item,i){ %>
                                  //all_csr_addr.push_back({12'h<%=obj.DceInfo[obj.Id].nrri%>,8'h<%=obj.DceInfo[obj.Id].rpn%>,12'h<%=item.addressOffset%>});
                                  all_csr_addr.push_back(<%=item.addressOffset%>);
                               <% }); %>
      all_csr_addr.sort();
      `uvm_info(get_full_name(),$sformatf("all_csr_addr : %0p",all_csr_addr),UVM_NONE);
      for (int i = 0; i <= (all_csr_addr.size() - 2); i++) begin 
        if ((all_csr_addr[i+1] - all_csr_addr[i]) > 'h4) begin
          csr_unmapped_addr_range.push_back({(all_csr_addr[i]+'h4),(all_csr_addr[i+1]-4)});
        end
      end
      `uvm_info(get_full_name(),$sformatf("csr_unmapped_addr_range : %0p",csr_unmapped_addr_range),UVM_NONE);
      randomly_selected_unmapped_csr_sddr = $urandom_range((csr_unmapped_addr_range.size()-1),0);
      get_unmapped_csr_addr = $urandom_range(csr_unmapped_addr_range[randomly_selected_unmapped_csr_sddr].lower_addr,csr_unmapped_addr_range[randomly_selected_unmapped_csr_sddr].upper_addr);
      `uvm_info(get_full_name(),$sformatf("unmapped_csr_addr : 0x%0x",get_unmapped_csr_addr),UVM_NONE);
    endfunction : get_unmapped_csr_addr

    function void get_apb_if();
      if (!uvm_config_db#(virtual <%=obj.BlockId%>_apb_if)::get(.cntxt(null),
                                          .inst_name(this.get_full_name()),
                                          .field_name("apb_if"),
                                          .value(apb_vif)))
        `uvm_error(get_name,"Failed to get apb if")
    endfunction
    
    function getInjectErrEvent();
    <% obj.SnoopFilterInfo.forEach(function sfways(item,index){ %>
      <% for(var i=0;i<item.nWays;i++){ %>
      <% console.log("f"+index+"m"+i+"_memory"); %>
      if (!uvm_config_db#(uvm_event)::get(.cntxt(null),
                                          .inst_name(this.get_full_name()),
                                          .field_name("injectSingleErrTag<%=index%>_<%=i%>"),
                                          .value(injectSingleErrTag<%=index%>_<%=i%>)))
        `uvm_error(get_name,"Failed to get error event for single error tag")
      if (!uvm_config_db#(uvm_event)::get(.cntxt(null),
                                          .inst_name(this.get_full_name()),
                                          .field_name("injectDoubleErrTag<%=index%>_<%=i%>"),
                                          .value(injectDoubleErrTag<%=index%>_<%=i%>)))
        `uvm_error(get_name,"Failed to get error event for double error tag")
      if (!uvm_config_db#(uvm_event)::get(.cntxt(null),
                                          .inst_name(this.get_full_name()),
                                          .field_name("inject_multi_block_single_double_ErrTag<%=index%>_<%=i%>"),
                                          .value(inject_multi_block_single_double_ErrTag<%=index%>_<%=i%>)))
        `uvm_error(get_name,"Failed to get error event for multi block single double error tag")
      if (!uvm_config_db#(uvm_event)::get(.cntxt(null),
                                          .inst_name(this.get_full_name()),
                                          .field_name("inject_multi_block_double_ErrTag<%=index%>_<%=i%>"),
                                          .value(inject_multi_block_double_ErrTag<%=index%>_<%=i%>)))
        `uvm_error(get_name,"Failed to get error event for multi block double error tag")
      if (!uvm_config_db#(uvm_event)::get(.cntxt(null),
                                          .inst_name(this.get_full_name()),
                                          .field_name("inject_multi_block_single_ErrTag<%=index%>_<%=i%>"),
                                          .value(inject_multi_block_single_ErrTag<%=index%>_<%=i%>)))
        `uvm_error(get_name,"Failed to get error event for multi block single error tag")
      if (!uvm_config_db#(uvm_event)::get(.cntxt(null),
                                          .inst_name(this.get_full_name()),
                                          .field_name("injectAddrErrTag<%=index%>_<%=i%>"),
                                          .value(injectAddrErrTag<%=index%>_<%=i%>)))
        `uvm_error(get_name,"Failed to get error event for single addr error tag")
      <% } %>
    <% }); %>
    endfunction

    task inject_error(input int error_threshold = 1, input int delay_btwn_err_inj = 1, input bit serial_err_inj = 0, output int error_injected_sfid);
      semaphore sema=new(1);
      int i;
    <% obj.SnoopFilterInfo.forEach(function sfways(item,index){ %>
      <% for(var i=0;i<item.nWays;i++){ %>
      int number_of_time_error_injected_<%=index%>_<%=i%>;
      <% } %>
    <% }); %>
      `uvm_info("INJECT_ERROR",$sformatf("error_threshold = %0h",error_threshold),UVM_NONE)
        fork
        <% obj.SnoopFilterInfo.forEach(function sfways(item,index){ %>
          <%if(item.TagFilterErrorInfo.fnErrDetectCorrect === "SECDED" || item.TagFilterErrorInfo.fnErrDetectCorrect === "PARITY") {%>
            <% for(var i=0;i<item.nWays;i++){ %>
            begin
              do begin
                sema.get(1);
                if (i < error_threshold) begin 
                  if (!serial_err_inj) begin
                    i++;
                    sema.put(1);
                  end
                  if (memory_warmed_up == 0) begin
                    ev_ready_for_mem_trigger.trigger();
                    ev_fliter_memory_warmed_up.wait_ptrigger();
                    memory_warmed_up = 1;
                  end
                  @(posedge u_csr_probe_vif.clk);
                  if ($test$plusargs("dir_single_bit_tag_direct_error_test")) begin
                      injectSingleErrTag<%=index%>_<%=i%>.trigger();
                  <% if(obj.testBench == 'dce') { %>
                  `ifndef VCS
                     @(negedge u_csr_probe_vif.inject_tag_single_next<%=index%>_<%=i%>); 
                  `else // `ifndef VCS
                  <% if(obj.INHOUSE_APB_VIP && obj.assertOn) {%>
                     @(negedge u_csr_probe_vif.inject_tag_single_next<%=index%>_<%=i%>); 
                   <% } %>
                  `endif // `ifndef VCS ... `else ... 
                 <% } else {%>
                     @(negedge u_csr_probe_vif.inject_tag_single_next<%=index%>_<%=i%>); 
                 <% } %>
                      @(negedge u_csr_probe_vif.clk);
                      if (u_csr_probe_vif.find_cmd_req_addr_secded_err_<%=index%>_<%=i%>.size() > 0) begin
                   <% if(obj.testBench == 'dce') { %>
                  `ifndef VCS
                      err_injected_addr = u_csr_probe_vif.find_cmd_req_addr_secded_err_<%=index%>_<%=i%>.pop_back();
                  `else // `ifndef VCS
                  <% if(obj.INHOUSE_APB_VIP && obj.assertOn) {%>
                      err_injected_addr = u_csr_probe_vif.find_cmd_req_addr_secded_err_<%=index%>_<%=i%>.pop_back();
                   <% } %>
                  `endif // `ifndef VCS ... `else ... 
                 <% } else {%>
                      err_injected_addr = u_csr_probe_vif.find_cmd_req_addr_secded_err_<%=index%>_<%=i%>.pop_back();
                 <% } %>
                      end else begin
                        `uvm_error(get_name,"find_cmd_req_addr_secded_err_<%=index%>_<%=i%>.q empty. No error injected addr captured & pushed in cmd_req_addr queue")
                      end
                      err_injected_index = ncoreConfigInfo::get_sf_set_index(<%=index%>, err_injected_addr);
                      err_injected_way = <%=i%>;
                      `uvm_info(get_full_name(),$sformatf("err_injected_addr = %0h, err_injected_index = %0h, err_injected_way = %0h",err_injected_addr,err_injected_index,err_injected_way),UVM_NONE)
                  end
                  if ($test$plusargs("dir_double_bit_direct_tag_error_test")) begin
                      injectDoubleErrTag<%=index%>_<%=i%>.trigger();
                      <% if(obj.testBench == 'dce') { %>
                      `ifndef VCS                   
                      @(negedge u_csr_probe_vif.inject_tag_double_next<%=index%>_<%=i%>); 
                      `else // `ifndef VCS
                      <% if(obj.INHOUSE_APB_VIP && obj.assertOn) {%>
                      @(negedge u_csr_probe_vif.inject_tag_double_next<%=index%>_<%=i%>); 
                      <% } %>
                      `endif // `ifndef VCS ... `else ... 
                      <% } else {%>
                      @(negedge u_csr_probe_vif.inject_tag_double_next<%=index%>_<%=i%>); 
                      <% } %>
                      @(negedge u_csr_probe_vif.clk);
                      if (u_csr_probe_vif.find_cmd_req_addr_secded_err_<%=index%>_<%=i%>.size() > 0) begin
                      <% if(obj.testBench == 'dce') { %>
                     `ifndef VCS
                      err_injected_addr = u_csr_probe_vif.find_cmd_req_addr_secded_err_<%=index%>_<%=i%>.pop_back();
                     `else // `ifndef VCS
                     <% if(obj.INHOUSE_APB_VIP && obj.assertOn) {%>
                      err_injected_addr = u_csr_probe_vif.find_cmd_req_addr_secded_err_<%=index%>_<%=i%>.pop_back();
                     <% } %>
                    `endif // `ifndef VCS ... `else ... 
                     <% } else {%>
                      err_injected_addr = u_csr_probe_vif.find_cmd_req_addr_secded_err_<%=index%>_<%=i%>.pop_back();
                     <% } %>
                      end else begin
                        `uvm_error(get_name,"find_cmd_req_addr_secded_err_<%=index%>_<%=i%>.q empty. No error injected addr captured & pushed in cmd_req_addr queue")
                      end
                      err_injected_index = ncoreConfigInfo::get_sf_set_index(<%=index%>, err_injected_addr);
                      err_injected_way = <%=i%>;
                      `uvm_info(get_full_name(),$sformatf("err_injected_addr = %0h, err_injected_index = %0h, err_injected_way = %0h",err_injected_addr,err_injected_index,err_injected_way),UVM_NONE)
                  end
                  if ($test$plusargs("dir_multi_blk_single_double_tag_direct_error_test")) begin
                      inject_multi_block_single_double_ErrTag<%=index%>_<%=i%>.trigger();
                      <% if(obj.testBench == 'dce') { %>
                      `ifndef VCS                   
                      @(negedge u_csr_probe_vif.inject_tag_single_double_multi_blk_next<%=index%>_<%=i%>); 
                      `else // `ifndef VCS
                      <% if(obj.INHOUSE_APB_VIP && obj.assertOn) {%>
                      @(negedge u_csr_probe_vif.inject_tag_single_double_multi_blk_next<%=index%>_<%=i%>); 
                     <% } %>
                      `endif // `ifndef VCS ... `else ... 
                      <% } else {%>
                      @(negedge u_csr_probe_vif.inject_tag_single_double_multi_blk_next<%=index%>_<%=i%>); 
                      <% } %>
                  end
                  if ($test$plusargs("dir_multi_blk_double_tag_direct_error_test")) begin
                      inject_multi_block_double_ErrTag<%=index%>_<%=i%>.trigger();
                      <% if(obj.testBench == 'dce') { %>
                      `ifndef VCS                   
                      @(negedge u_csr_probe_vif.inject_tag_double_multi_blk_next<%=index%>_<%=i%>); 
                      `else // `ifndef VCS
                      <% if(obj.INHOUSE_APB_VIP && obj.assertOn) {%>
                      @(negedge u_csr_probe_vif.inject_tag_double_multi_blk_next<%=index%>_<%=i%>); 
                      <% } %>
                      `endif // `ifndef VCS ... `else ... 
                      <% } else {%>
                      @(negedge u_csr_probe_vif.inject_tag_double_multi_blk_next<%=index%>_<%=i%>); 
                      <% } %>
                  end
                  if ($test$plusargs("dir_multi_blk_single_tag_direct_error_test")) begin
                      inject_multi_block_single_ErrTag<%=index%>_<%=i%>.trigger();
                      <% if(obj.testBench == 'dce') { %>
                      `ifndef VCS                   
                      @(negedge u_csr_probe_vif.inject_tag_single_multi_blk_next<%=index%>_<%=i%>); 
                      `else // `ifndef VCS
                      <% if(obj.INHOUSE_APB_VIP && obj.assertOn) {%>
                      @(negedge u_csr_probe_vif.inject_tag_single_multi_blk_next<%=index%>_<%=i%>); 
                      <% } %>
                      `endif // `ifndef VCS ... `else ... 
                      <% } else {%>
                      @(negedge u_csr_probe_vif.inject_tag_single_multi_blk_next<%=index%>_<%=i%>); 
                      <% } %>
                  end
                  if ($test$plusargs("dir_inject_sram_address_protection_test")) begin
                      injectAddrErrTag<%=index%>_<%=i%>.trigger();
                      <% if(obj.testBench == 'dce') { %>
                      `ifndef VCS                   
                      @(negedge u_csr_probe_vif.inject_tag_addr_next<%=index%>_<%=i%>); 
                      `else // `ifndef VCS
                      <% if(obj.INHOUSE_APB_VIP && obj.assertOn) {%>
                      @(negedge u_csr_probe_vif.inject_tag_addr_next<%=index%>_<%=i%>); 
                      <% } %>
                      `endif // `ifndef VCS ... `else ... 
                      <% } else {%>
                      @(negedge u_csr_probe_vif.inject_tag_addr_next<%=index%>_<%=i%>); 
                      <% } %>
                      <% if(obj.testBench == 'dce') { %>
                      `ifndef VCS                   
                      err_injected_addr = u_csr_probe_vif.find_cmd_req_addr_secded_err_<%=index%>_<%=i%>.pop_back();
                      `else // `ifndef VCS
                      <% if(obj.INHOUSE_APB_VIP && obj.assertOn) {%>
                      err_injected_addr = u_csr_probe_vif.find_cmd_req_addr_secded_err_<%=index%>_<%=i%>.pop_back();
                      <% } %>
                      `endif // `ifndef VCS ... `else ... 
                      <% } else {%>
                      err_injected_addr = u_csr_probe_vif.find_cmd_req_addr_secded_err_<%=index%>_<%=i%>.pop_back();
                      <% } %>
                      err_injected_index = ncoreConfigInfo::get_sf_set_index(<%=index%>, err_injected_addr);
                      err_injected_way = <%=i%>;
                      `uvm_info(get_full_name(),$sformatf("err_injected_addr = %0h, err_injected_index = %0h, err_injected_way = %0h",err_injected_addr,err_injected_index,err_injected_way),UVM_NONE)
          end

                  repeat(delay_btwn_err_inj) begin
                    @(posedge u_csr_probe_vif.clk);
                  end
                  if (serial_err_inj) begin
                    i++;
                    sema.put(1);
                  end
                  number_of_time_error_injected_<%=index%>_<%=i%>++;
                  error_injected_sfid = <%=index%>;
                end else begin
                  sema.put(1);
                end
              end while (i < error_threshold);
              `uvm_info("INJECT_ERROR",$sformatf("number_of_time_error_injected_<%=index%>_<%=i%> = %0h",number_of_time_error_injected_<%=index%>_<%=i%>),UVM_NONE)
            end
            <% } %>
          <% } %>
        <% }); %>
        join
    endtask

    function void getSMIIf();
      <% var smi_portid_cmdreq =0;
         var smi_portid_sysreq =0;
         var smi_portid_sysrsp =0;
         var smi_portid_updreq =0;
         var smi_portid_snprsp =0;
         var smi_portid_strrsp =0;
         var smi_portid_rbureq =0;
         var smi_portid_rbrrsp =0;
         obj.smiPortParams.rx.forEach(function find_port_id(item,index){ 
           if(item.params.fnMsgClass.indexOf('cmd_req_') != -1) {
             smi_portid_cmdreq = index;
             console.log("smi_portid_cmdreq is = "+ index ) ;
           }
           if(item.params.fnMsgClass.indexOf('sys_req_rx_') != -1) {
             smi_portid_sysreq = index;
             console.log("smi_portid_sysreq is = "+ index ) ;
           }
           if(item.params.fnMsgClass.indexOf('sys_rsp_rx_') != -1) {
             smi_portid_sysrsp = index;
             console.log("smi_portid_sysrsp is = "+ index ) ;
           }
           if(item.params.fnMsgClass.indexOf('upd_req_') != -1) {
             smi_portid_updreq = index;
             console.log("smi_portid_updreq is = "+ index ) ;
           }
           if(item.params.fnMsgClass.indexOf('snp_rsp_') != -1) {
             smi_portid_snprsp = index;
             console.log("smi_portid_snprsp is = "+ index ) ;
           }
           if(item.params.fnMsgClass.indexOf('str_rsp_') != -1) {
             smi_portid_strrsp = index;
             console.log("smi_portid_strrsp is = "+ index ) ;
           }
           if(item.params.fnMsgClass.indexOf('rbu_req_') != -1) {
             smi_portid_rbureq = index;
             console.log("smi_portid_rbureq is = "+ index ) ;
           }
           if(item.params.fnMsgClass.indexOf('rbr_rsp_') != -1) {
             smi_portid_rbrrsp = index;
             console.log("smi_portid_rbrrsp is = "+ index ) ;
           }
         });  %>
      <% for (var i = 0; i < obj.nSmiRx; i++) { %>
      if (!uvm_config_db #(virtual <%=obj.BlockId%>_smi_if)::get(
        .cntxt(null),
        .inst_name(get_full_name()),
        .field_name("m_smi<%=i%>_tx_vif"),
        .value(m_smi<%=i%>_tx_vif))) begin

        `uvm_fatal(get_name(), "unable to find m_smi<%=i%>_tx_vif")
      end
      <% } %>

    endfunction

    function void get_scb_handle();
      if (!uvm_config_db#(dce_scb)::get(.cntxt( null ),
                                              .inst_name( "*" ),
                                              .field_name( "dce_sb" ),
                                              .value( dce_sb ))) begin
         `uvm_error("dce_ral_csr_base_seq", "dce_scb handle not found")
      end
    endfunction

    function getCsrProbeIf();
        if(!uvm_config_db#(virtual <%=obj.BlockId%>_probe_if )::get(null, get_full_name(), "probe_vif",u_csr_probe_vif))
            `uvm_error("NOVIF",{"virtual interface must be set  for :",get_full_name(),".vif"})
    endfunction // checkCsrProbeIf

    task poll_DCEUUESR_ErrVld(bit [31:0] poll_till, output uvm_reg_data_t fieldVal);
        poll_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUUESR.ErrVld,poll_till,fieldVal);
    endtask

    task poll_DCEUCESR_ErrVld(bit [31:0] poll_till, output uvm_reg_data_t fieldVal);
        poll_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUCESR.ErrVld,poll_till,fieldVal);
    endtask

    task poll_DCEUCESR_ErrCount(bit [31:0] poll_till, output uvm_reg_data_t fieldVal);
        poll_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUCESR.ErrCount,poll_till,fieldVal);
    endtask

    task poll_DCEUCESR_ErrCountOverflow(bit [31:0] poll_till, output uvm_reg_data_t fieldVal);
        poll_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUCESR.ErrCountOverflow,poll_till,fieldVal);
    endtask

endclass : dce_ral_csr_base_seq

class dce_csr_time_out_error_seq extends dce_ral_csr_base_seq; 
  `uvm_object_utils(dce_csr_time_out_error_seq)

    uvm_reg_data_t poll_data, read_data, write_data,timeout_threshold;
    bit [47:0] actual_addr;
    bit [47:0] expt_addr;
    bit [15:0]errinfo;
    bit [19:0] errentry;
    bit [5:0] errway;
    bit [5:0] errword;
    bit [19:0] erraddr;

    function new(string name="");
        super.new(name);
    endfunction

    task body();
      getCsrProbeIf();
      get_scb_handle();

      write_data = 1;
      write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUUEDR.TimeoutErrDetEn, write_data);
      write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUUEIR.TimeoutErrIntEn, write_data);
      timeout_threshold = 1;
      write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUTOCR.TimeOutThreshold, timeout_threshold);
      ev.trigger();

      csr_test_time_out_recall_ev.wait_ptrigger();

      errinfo[1:0] = 2'b0; //reserved
      errinfo[2] = dce_sb.m_dm_recrsp_pkt.m_ns;
      errinfo[15:3] = 13'b0; //reserved

      expt_addr = dce_sb.m_dm_recrsp_pkt.m_addr;
      `uvm_info(get_full_name(),$sformatf("errinfo = %0h, expt_addr = %0h",errinfo,expt_addr),UVM_MEDIUM)

      poll_DCEUUESR_ErrVld(1, poll_data);
      fork
      begin
          wait (u_csr_probe_vif.IRQ_UC === 1);
      end
      begin
        #200000ns;
        `uvm_error("RUN_MAIN",$sformatf("Timeout! Did not see IRQ_UC asserted"));
      end
      join_any
      disable fork;
      read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUUESR.ErrType, read_data);
      compareValues("DCEUUESR.ErrType","should be",read_data,9);
      read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUUESR.ErrInfo, read_data);
      compareValues("DCEUUESR.ErrInfo","should be",read_data,errinfo);
      read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUUELR0.ErrAddr, read_data);
      errentry = read_data[19:0];
      errway = read_data[25:20];
      errword = read_data[31:26];
      read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUUELR1.ErrAddr, read_data);
      erraddr = read_data;
      actual_addr = {erraddr,errword,errway,errentry};
      if (actual_addr !== expt_addr) begin
        `uvm_error(get_full_name(),$sformatf("received addr = 0x%0x didn't match with expected addr = 0x%0x",actual_addr, expt_addr))
      end
      write_data = 0;
      write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUUEDR.TimeoutErrDetEn, write_data);
      write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUUEIR.TimeoutErrIntEn, write_data);
      timeout_threshold = 0;
      write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUTOCR.TimeOutThreshold, timeout_threshold);
      write_data = 1;
      write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUUESR.ErrVld, write_data);
      read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUUESR.ErrVld, read_data);
      compareValues("DCEUUESR_ErrVld", "not set", read_data, 0);
    endtask

endclass : dce_csr_time_out_error_seq

class access_unmapped_csr_addr extends dce_ral_csr_base_seq;
  `uvm_object_utils(access_unmapped_csr_addr)
  bit [`UVM_REG_ADDR_WIDTH-1 : 0] unmapped_csr_addr;
  apb_pkt_t apb_pkt;

  function new(string name="");
      super.new(name);
  endfunction

  task body();
    get_apb_if();
    ev.trigger();
    unmapped_csr_addr = get_unmapped_csr_addr();
    apb_pkt = apb_pkt_t::type_id::create("apb_pkt");
    apb_pkt.psel       = 1;
    apb_pkt.paddr      = unmapped_csr_addr;
    apb_pkt.pwrite     = 1;
    apb_pkt.pwdata     = $urandom;
    apb_pkt.unmap_addr = unmapped_csr_addr;
    apb_vif.drive_apb_channel(apb_pkt);
  endtask
endclass : access_unmapped_csr_addr

class dce_csr_diruuedr_TransErrDetEn_seq extends dce_ral_csr_base_seq; 
  `uvm_object_utils(dce_csr_diruuedr_TransErrDetEn_seq)

    uvm_reg_data_t poll_data, read_data, write_data;
    bit [3:0]  errtype;
    bit [19:0] errinfo;
    bit [51:0] actual_addr;
    bit [51:0] exp_addr;
    bit [19:0] err_entry;
    bit [11:0] err_way;
    bit [19:0] err_addr;
    bit errinfo_check, erraddr_check;

    function new(string name="");
        super.new(name);
    endfunction

    task body();
      bit dis_uedr_ted_4resiliency = $test$plusargs("dis_uedr_ted_4resiliency") ? 1 : 0;
      getCsrProbeIf();
      getSMIIf();

      if(dis_uedr_ted_4resiliency) begin
        `uvm_info(get_full_name(),$sformatf("Skipping enabling of error detection inside xUEDR"),UVM_NONE)
        ev.trigger();
      end
      else begin
      errtype = 4'h8;

      // Set the DCEUUECR_ErrDetEn = 1
      write_data = 1;
      write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUUEDR.TransErrDetEn, write_data);
      write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUUEIR.TransErrIntEn, write_data);
      ev.trigger();
      if ($test$plusargs("wrong_cmdreq_target_id")) begin
        do
          @(posedge m_smi<%=smi_portid_cmdreq%>_tx_vif.clk);
        while (m_smi<%=smi_portid_cmdreq%>_tx_vif.smi_msg_valid === 1'b0 || m_smi<%=smi_portid_cmdreq%>_tx_vif.smi_msg_ready === 1'b0 || ((smi_seq_item::type2class(m_smi<%=smi_portid_cmdreq%>_tx_vif.smi_msg_type) != eConcMsgCmdReq) || ((smi_seq_item::type2class(m_smi<%=smi_portid_cmdreq%>_tx_vif.smi_msg_type) == eConcMsgCmdReq) && (m_smi<%=smi_portid_cmdreq%>_tx_vif.smi_targ_id[WSMITGTID-1:WSMINCOREPORTID] == <%=obj.DceInfo[obj.Id].FUnitId%>))));
        errinfo[19:8] = m_smi<%=smi_portid_cmdreq%>_tx_vif.smi_src_id[WSMISRCID-1:WSMINCOREPORTID];
        //errinfo[5:1] = Resereved;
        errinfo[0] = 1'b0; //0 for wrong targ_id
        exp_addr = m_smi<%=smi_portid_cmdreq%>_tx_vif.smi_ndp[CMD_REQ_ADDR_MSB:CMD_REQ_ADDR_LSB];
        errinfo_check = 1;
        erraddr_check = 1;
      end
      if ($test$plusargs("wrong_sysreq_target_id")) begin
        do
          @(posedge m_smi<%=smi_portid_sysreq%>_tx_vif.clk);
        while (m_smi<%=smi_portid_sysreq%>_tx_vif.smi_msg_valid === 1'b0 || m_smi<%=smi_portid_sysreq%>_tx_vif.smi_msg_ready === 1'b0 || ((smi_seq_item::type2class(m_smi<%=smi_portid_sysreq%>_tx_vif.smi_msg_type) != eConcMsgSysReq) || ((smi_seq_item::type2class(m_smi<%=smi_portid_sysreq%>_tx_vif.smi_msg_type) == eConcMsgSysReq) && (m_smi<%=smi_portid_sysreq%>_tx_vif.smi_targ_id[WSMITGTID-1:WSMINCOREPORTID] == <%=obj.DceInfo[obj.Id].FUnitId%>))));
        errinfo[19:8] = m_smi<%=smi_portid_sysreq%>_tx_vif.smi_src_id[WSMISRCID-1:WSMINCOREPORTID];
        //errinfo[5:1] = Resereved;
        errinfo[0] = 1'b0; //0 for wrong targ_id
        errinfo_check = 1;
        erraddr_check = 0;
      end
      if ($test$plusargs("wrong_sysrsp_target_id")) begin
        do
          @(posedge m_smi<%=smi_portid_sysrsp%>_tx_vif.clk);
        while (m_smi<%=smi_portid_sysrsp%>_tx_vif.smi_msg_valid === 1'b0 || m_smi<%=smi_portid_sysrsp%>_tx_vif.smi_msg_ready === 1'b0 || ((smi_seq_item::type2class(m_smi<%=smi_portid_sysrsp%>_tx_vif.smi_msg_type) != eConcMsgSysRsp) || ((smi_seq_item::type2class(m_smi<%=smi_portid_sysrsp%>_tx_vif.smi_msg_type) == eConcMsgSysRsp) && (m_smi<%=smi_portid_sysrsp%>_tx_vif.smi_targ_id[WSMITGTID-1:WSMINCOREPORTID] == <%=obj.DceInfo[obj.Id].FUnitId%>))));
        errinfo[19:8] = m_smi<%=smi_portid_sysrsp%>_tx_vif.smi_src_id[WSMISRCID-1:WSMINCOREPORTID];
        //errinfo[5:1] = Resereved;
        errinfo[0] = 1'b0; //0 for wrong targ_id
        errinfo_check = 1;
        erraddr_check = 0;
      end
      if ($test$plusargs("wrong_updreq_target_id")) begin
        do
          @(posedge m_smi<%=smi_portid_updreq%>_tx_vif.clk);
        while (m_smi<%=smi_portid_updreq%>_tx_vif.smi_msg_valid === 1'b0 || m_smi<%=smi_portid_updreq%>_tx_vif.smi_msg_ready === 1'b0 || ((smi_seq_item::type2class(m_smi<%=smi_portid_updreq%>_tx_vif.smi_msg_type) != eConcMsgUpdReq) || ((smi_seq_item::type2class(m_smi<%=smi_portid_updreq%>_tx_vif.smi_msg_type) == eConcMsgUpdReq) && (m_smi<%=smi_portid_updreq%>_tx_vif.smi_targ_id[WSMITGTID-1:WSMINCOREPORTID] == <%=obj.DceInfo[obj.Id].FUnitId%>))));
        errinfo[19:8] = m_smi<%=smi_portid_updreq%>_tx_vif.smi_src_id[WSMISRCID-1:WSMINCOREPORTID];
        //errinfo[5:1] = Resereved;
        errinfo[0] = 1'b0; //0 for wrong targ_id
        exp_addr = m_smi<%=smi_portid_updreq%>_tx_vif.smi_ndp[UPD_REQ_ADDR_MSB:UPD_REQ_ADDR_LSB];
        errinfo_check = 1;
        erraddr_check = 1;
      end
      if ($test$plusargs("wrong_snprsp_target_id")) begin
        do
          @(posedge m_smi<%=smi_portid_snprsp%>_tx_vif.clk);
        while (m_smi<%=smi_portid_snprsp%>_tx_vif.smi_msg_valid === 1'b0 || m_smi<%=smi_portid_snprsp%>_tx_vif.smi_msg_ready === 1'b0 || ((smi_seq_item::type2class(m_smi<%=smi_portid_snprsp%>_tx_vif.smi_msg_type) != eConcMsgSnpRsp) || ((smi_seq_item::type2class(m_smi<%=smi_portid_snprsp%>_tx_vif.smi_msg_type) == eConcMsgSnpRsp) && (m_smi<%=smi_portid_snprsp%>_tx_vif.smi_targ_id[WSMITGTID-1:WSMINCOREPORTID] == <%=obj.DceInfo[obj.Id].FUnitId%>))));
        errinfo[19:8] = m_smi<%=smi_portid_snprsp%>_tx_vif.smi_src_id[WSMISRCID-1:WSMINCOREPORTID];
        //errinfo[5:1] = Resereved;
        errinfo[0] = 1'b0; //0 for wrong targ_id
        errinfo_check = 1;
        erraddr_check = 0;
      end
      if ($test$plusargs("wrong_strrsp_target_id")) begin
        do
          @(posedge m_smi<%=smi_portid_strrsp%>_tx_vif.clk);
        while (m_smi<%=smi_portid_strrsp%>_tx_vif.smi_msg_valid === 1'b0 || m_smi<%=smi_portid_strrsp%>_tx_vif.smi_msg_ready === 1'b0 || ((smi_seq_item::type2class(m_smi<%=smi_portid_strrsp%>_tx_vif.smi_msg_type) != eConcMsgStrRsp) || ((smi_seq_item::type2class(m_smi<%=smi_portid_strrsp%>_tx_vif.smi_msg_type) == eConcMsgStrRsp) && (m_smi<%=smi_portid_strrsp%>_tx_vif.smi_targ_id[WSMITGTID-1:WSMINCOREPORTID] == <%=obj.DceInfo[obj.Id].FUnitId%>))));
        errinfo[19:8] = m_smi<%=smi_portid_strrsp%>_tx_vif.smi_src_id[WSMISRCID-1:WSMINCOREPORTID];
        //errinfo[5:1] = Resereved;
        errinfo[0] = 1'b0; //0 for wrong targ_id
        errinfo_check = 1;
        erraddr_check = 0;
      end
      if ($test$plusargs("wrong_rbureq_target_id")) begin
        do
          @(posedge m_smi<%=smi_portid_rbureq%>_tx_vif.clk);
        while (m_smi<%=smi_portid_rbureq%>_tx_vif.smi_msg_valid === 1'b0 || m_smi<%=smi_portid_rbureq%>_tx_vif.smi_msg_ready === 1'b0 || ((smi_seq_item::type2class(m_smi<%=smi_portid_rbureq%>_tx_vif.smi_msg_type) != eConcMsgRbUseReq) || ((smi_seq_item::type2class(m_smi<%=smi_portid_rbureq%>_tx_vif.smi_msg_type) == eConcMsgRbUseReq) && (m_smi<%=smi_portid_rbureq%>_tx_vif.smi_targ_id[WSMITGTID-1:WSMINCOREPORTID] == <%=obj.DceInfo[obj.Id].FUnitId%>))));
        errinfo[19:8] = m_smi<%=smi_portid_rbureq%>_tx_vif.smi_src_id[WSMISRCID-1:WSMINCOREPORTID];
        //errinfo[5:1] = Resereved;
        errinfo[0] = 1'b0; //0 for wrong targ_id
        errinfo_check = 1;
        erraddr_check = 0;
      end
      if ($test$plusargs("wrong_rbrsp_target_id")) begin
        do
          @(posedge m_smi<%=smi_portid_rbrrsp%>_tx_vif.clk);
        while (m_smi<%=smi_portid_rbrrsp%>_tx_vif.smi_msg_valid === 1'b0 || m_smi<%=smi_portid_rbrrsp%>_tx_vif.smi_msg_ready === 1'b0 || ((smi_seq_item::type2class(m_smi<%=smi_portid_rbrrsp%>_tx_vif.smi_msg_type) != eConcMsgRbRsp) || ((smi_seq_item::type2class(m_smi<%=smi_portid_rbrrsp%>_tx_vif.smi_msg_type) == eConcMsgRbRsp) && (m_smi<%=smi_portid_rbrrsp%>_tx_vif.smi_targ_id[WSMITGTID-1:WSMINCOREPORTID] == <%=obj.DceInfo[obj.Id].FUnitId%>))));
        errinfo[19:8] = m_smi<%=smi_portid_rbrrsp%>_tx_vif.smi_src_id[WSMISRCID-1:WSMINCOREPORTID];
        //errinfo[5:1] = Resereved;
        errinfo[0] = 1'b0; //0 for wrong targ_id
        errinfo_check = 1;
        erraddr_check = 0;
      end
      if ($test$plusargs("inject_smi_uncorr_error")) begin
        errinfo = 1;
        errinfo_check = 1;
      end
      `uvm_info(get_full_name(),$sformatf("[CSR SEQ TRANS ERR] errinfo = %0h (chk: %1d), exp_addr = %0h", errinfo, errinfo_check, exp_addr),UVM_HIGH)
      //keep on  Reading the CAIUUESR_ErrVld bit = 1
      poll_DCEUUESR_ErrVld(1, poll_data);
      fork
        begin
            wait (u_csr_probe_vif.IRQ_UC === 1);
        end
        begin
          #200000ns;
          `uvm_error(get_name(),$sformatf("Timeout! Did not see IRQ_UC asserted"));
        end
      join_any
      disable fork;

      `uvm_info(get_full_name(),$sformatf("[CSR SEQ TRANS ERR] Comparing the register status values"),UVM_HIGH)
      read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUUESR.ErrType, read_data);
      compareValues("DCEUUESR_ErrType","Valid Type", read_data, errtype);
      if (errinfo_check) begin
        read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUUESR.ErrInfo, read_data);
        compareValues("DCEUUESR_ErrInfo","Valid Type", read_data, errinfo);
      end
      if (erraddr_check) begin
        //Disabled address check as per CONC-6294
        //read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUUELR0.ErrAddr, read_data);
        //err_entry = read_data[19:0];
        //err_way = read_data[25:20];
        //read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUUELR1.ErrAddr, read_data);
        //err_addr = read_data;
        //actual_addr = {err_addr,err_way,err_entry};

        //if (actual_addr !== exp_addr) begin
        //          `uvm_error(get_full_name(),$sformatf("received addr = 0x%0x didn't match with expected addr = 0x%0x",actual_addr, exp_addr))
        //end
      end
      write_data = 0;
      write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUUEDR.TransErrDetEn, write_data);
      write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUUEIR.TransErrIntEn, write_data);
      write_data = 1;
      write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUUESR.ErrVld, write_data);
      read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUUESR.ErrVld, read_data);
      compareValues("DCEUUESR_ErrVld","reset", read_data, 0);
      end
    endtask
endclass : dce_csr_diruuedr_TransErrDetEn_seq

class dce_default_reset_seq extends dce_ral_csr_base_seq;
  `uvm_object_utils(dce_default_reset_seq)
    uvm_reg_data_t read_data, write_data;

    //grab handle to dce_env_cfg
    dce_env_config m_env_cfg;

    uvm_reg_data_t write_value =32'hFFFF_FFFF;
    uvm_reg_data_t read_value;
    uvm_status_e status;
    uvm_reg my_register;
    uvm_reg_data_t mirrored_value;

    function new(string name="");
        super.new(name);
    endfunction

    task body();
       ncoreConfigInfo::sys_addr_csr_t csrq[$];
       uvm_reg_data_t write_data;


        csrq = ncoreConfigInfo::get_all_gpra();
        foreach (csrq[i]) begin
          `uvm_info(get_name(),
              $psprintf("idx: %0d unit: %s hui:%0d low-addr:0x0%h up-addr: 0x%0h sz:%0d", i,
                  csrq[i].unit.name(), csrq[i].mig_nunitid,
                  csrq[i].low_addr, csrq[i].upp_addr, csrq[i].size),
              UVM_LOW) 
        end
        
        //program the address manager
<% for(var i = 0; i < obj.DutInfo.nGPRA; i++) { %>
        write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUGPRBLR<%=i%>.AddrLow, csrq[<%=i%>].low_addr);
        write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUGPRBHR<%=i%>.AddrHigh, csrq[<%=i%>].upp_addr);
        write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUGPRAR<%=i%>.Size, csrq[<%=i%>].size);
        write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUGPRAR<%=i%>.Valid, 1);
        write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUGPRAR<%=i%>.HUI, csrq[<%=i%>].mig_nunitid);
        write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUGPRAR<%=i%>.HUT, csrq[<%=i%>].unit == ncoreConfigInfo::DII ? 1 : 0);
<% } %>

      write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUAMIGR.Valid, 'b1);
      write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUAMIGR.AMIGS, ncoreConfigInfo::picked_dmi_igs);

      //Program MRDCredit Registers
<% for(var i = 0; i < obj.DceInfo[obj.Id].nDmis; i++) {
    if(obj.DmiInfo[0].nMrdSkidBufSize > 31) {%>
        write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUCCR<%=i%>.DMICreditLimit, 30);
    <%}
    else{ %>
        write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUCCR<%=i%>.DMICreditLimit, <%=obj.DmiInfo[0].nMrdSkidBufSize%>);
    <%}%>
    //$sformat(credits_msg, "dce%0d_dmi%0d_nMrdInFlight", ncoreConfigInfo::get_dce_funitid(<%=obj.Id%>), ncoreConfigInfo::get_dmi_funitid(<%=i%>));
    //dce_sb.m_credits.scm_credit(credits_msg,<%=obj.DmiInfo[0].nMrdSkidBufSize%>);
<% } %>

      // Check UnitType value
      // See Ncore SysArch Spec. 0b1000 – DCE Unit 
      read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUINFOR.UT, read_data);
      compareValues("DCEUINFOR_UT","reset", read_data, 8);
 
      <%if (obj.DceInfo[obj.Id].fnEnableQos == 1) { %>
          // Read the xQOSCR event threshold value.
          read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUQOSCR0.EventThreshold, read_data);
          `uvm_info(get_full_name(), $sformatf("Old DCEUQOSCR0.EventThreshold = %0d", read_data), UVM_NONE)
          if (m_env_cfg == null)
            `uvm_error(get_full_name(), "m_env_cfg is null")

          write_data = uvm_reg_data_t'(m_env_cfg.m_qoscr_event_threshold);
          write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUQOSCR0.EventThreshold, write_data);
          read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUQOSCR0.EventThreshold, read_data);
         `uvm_info(get_full_name(), $sformatf("New DCEUQOSCR0.EventThreshold = %0d", read_data), UVM_NONE)

          // CONC-13159
          write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUQOSCR0.useEvictionQoS, m_env_cfg.m_use_evict_qos);
          write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUQOSCR0.EvictionQoS,    m_env_cfg.m_evict_qos    );
         `uvm_info(get_full_name(), $sformatf("Eviction QoS registers updated (useEvictionQos: %1b) (evictionQos: %2d)", m_env_cfg.m_use_evict_qos, m_env_cfg.m_evict_qos), UVM_NONE)
      <% } %>

       if(this.model == null) begin
        `uvm_error(get_type_name(),"this.model in seq is null");
    end

    my_register = this.model.get_reg_by_name("DCEUCELR0");
    if(my_register == null) begin
        `uvm_error(get_type_name(),"The value of my_register is null because it couldnt find DCEUCELR0");
    end

    my_register.write(status, write_value);
    `uvm_info(get_type_name(),$sformatf("The value written in DCEUCELR0 is %0h", write_value),UVM_LOW)

    if(status != UVM_IS_OK) begin
       `uvm_error(get_type_name(), $sformatf("Error writing to reg DCEUCELR0: %s", status.name()));
        return;
    end

    my_register.read(status,read_value);
    `uvm_info(get_type_name(), $sformatf("And DCEUCELR0 in seq after reading is %0h",read_value),UVM_LOW)

    if(status != UVM_IS_OK) begin
       `uvm_error(get_type_name(), $sformatf("Error reading from reg DCEUCELR0: %s", status.name()));
        return;
    end

    mirrored_value = my_register.get_mirrored_value();
    `uvm_info(get_type_name(),$sformatf("The mirrored value in sequence is %0h", mirrored_value), UVM_LOW)
    endtask 

endclass : dce_default_reset_seq

//-----------------------------------------------------------------------
//-----------------------------------------------------------------------
/**
* Abstract:
* 
* In this test we will check error interrupt functionality through alias register write. 
* 1. Enable correctable error interrupt. 
* 2. Write 1 to DCEUCESAR.ErrVld (alias register) so that DCEUCESR.ErrVld asserts in actual register.
* 3. Check that uncorrectable error interrupt should be asserted by DUT.
* 4. Write 0 to DCEUCESAR.ErrVld (alias register) so that DCEUCESR.ErrVld de-asserts in actual register.
* 5. Check that uncorrectable error interrupt should be de-asserted by DUT.
* 2. Write 1 to DCEUCESAR.ErrVld (alias register) so that DCEUCESR.ErrVld asserts in actual register.
* 3. Check that uncorrectable error interrupt should be asserted by DUT.
* 4. Write 0 to DCEUCESAR.ErrVld (alias register) so that DCEUCESR.ErrVld de-asserts in actual register.
* 5. Check that uncorrectable error interrupt should be de-asserted by DUT.
*/
//-----------------------------------------------------------------------
//-----------------------------------------------------------------------
//

class dce_corr_errint_check_through_dceucesar_seq extends dce_ral_csr_base_seq; 
  `uvm_object_utils(dce_corr_errint_check_through_dceucesar_seq)

    uvm_reg_data_t poll_data, read_data, read_data2, write_data;
    bit [7:0]  errthd;
    int        errcount_vld, errthd_vld;
    int        errcount_ovf;

    function new(string name="");
        super.new(name);
    endfunction

    task body();
           getCsrProbeIf();
           ev.trigger();
           //set correctable error interrupt
           write_data = 1;
           write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUCECR.ErrIntEn, write_data);
       
           //Assert DCEUCESR.ErrVld through alias register write
           write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUCESAR.ErrVld, write_data);
         
           read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUCESR.ErrVld, read_data);
           compareValues("DCEUCESR_ErrVld","set", read_data, 1);

           // wait for IRQ_C interrupt 
           fork
           begin
             wait (u_csr_probe_vif.IRQ_C === 1);
           end
           begin
             #200000ns;
             `uvm_error("RUN_MAIN",$sformatf("Timeout! Did not see IRQ_C asserted"));
           end
           join_any
           disable fork;
  
           //De-assert XAIUCESR.ErrVld through alias register write

           write_data = 0;
           write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUCESAR.ErrVld, write_data);

           read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUCESR.ErrVld, read_data);
           compareValues("DCEUCESR_ErrVld", "now clear", read_data, 0);

           // wait for IRQ_C interrupt to de-assert
           fork
           begin
             wait (u_csr_probe_vif.IRQ_C === 0);
           end
           begin
             #200000ns;
             `uvm_error("RUN_MAIN",$sformatf("Timeout! Did not see IRQ_C de-asserted"));
           end
           join_any
           disable fork;

           //Repeat the entire procedure
           //set correctable error interrupt
           write_data = 1;
           write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUCECR.ErrIntEn, write_data);
       
           //Assert DCEUCESR.ErrVld through alias register write
           write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUCESAR.ErrVld, write_data);
         
           read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUCESR.ErrVld, read_data);
           compareValues("DCEUCESR_ErrVld","set", read_data, 1);

           // wait for IRQ_C interrupt 
           fork
           begin
             wait (u_csr_probe_vif.IRQ_C === 1);
           end
           begin
             #200000ns;
             `uvm_error("RUN_MAIN",$sformatf("Timeout! Did not see IRQ_C asserted"));
           end
           join_any
           disable fork;
  
           //De-assert XAIUCESR.ErrVld through alias register write

           write_data = 0;
           write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUCESAR.ErrVld, write_data);

           read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUCESR.ErrVld, read_data);
           compareValues("DCEUCESR_ErrVld", "now clear", read_data, 0);

           // wait for IRQ_C interrupt to de-assert
           fork
           begin
             wait (u_csr_probe_vif.IRQ_C === 0);
           end
           begin
             #200000ns;
             `uvm_error("RUN_MAIN",$sformatf("Timeout! Did not see IRQ_C de-asserted"));
           end
           join_any
           disable fork;
  
    endtask
endclass : dce_corr_errint_check_through_dceucesar_seq

class dce_ucorr_errint_check_through_dceuuesar_seq extends dce_ral_csr_base_seq; 
  `uvm_object_utils(dce_ucorr_errint_check_through_dceuuesar_seq)

    uvm_reg_data_t poll_data, read_data, read_data2, write_data;
    bit [7:0]  errthd;
    int        errcount_vld, errthd_vld;
    int        errcount_ovf;

    function new(string name="");
        super.new(name);
    endfunction

    task body();
           getCsrProbeIf();
           ev.trigger();
           //set correctable error interrupt
           write_data = 1;
           write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUUEDR.MemErrDetEn, write_data);
           write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUUEIR.MemErrIntEn, write_data);
       
           //Assert DCEUCESR.ErrVld through alias register write
           write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUUESAR.ErrVld, write_data);
           //write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUUESAR.ErrType, 1);
         
           read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUUESR.ErrVld, read_data);
           compareValues("DCEUUESR_ErrVld","set", read_data, 1);

           // wait for IRQ_C interrupt 
           fork
           begin
             wait (u_csr_probe_vif.IRQ_UC === 1);
           end
           begin
             #200000ns;
             `uvm_error("RUN_MAIN",$sformatf("Timeout! Did not see IRQ_C asserted"));
           end
           join_any
           disable fork;

           write_data = 0;
           write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUUESAR.ErrVld, write_data);

           read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUUESR.ErrVld, read_data);
           compareValues("DCEUUESR_ErrVld", "now clear", read_data, 0);
           write_data = 0;
           write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUUEDR.MemErrDetEn, write_data);
           write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUUEIR.MemErrIntEn, write_data);

           // wait for IRQ_C interrupt to de-assert
           fork
           begin
             wait (u_csr_probe_vif.IRQ_UC === 0);
           end
           begin
             #200000ns;
             `uvm_error("RUN_MAIN",$sformatf("Timeout! Did not see IRQ_C de-asserted"));
           end
           join_any
           disable fork;
    //------------------------------------------------------------------------------------//
           write_data = 1;
           write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUUEDR.TimeoutErrDetEn, write_data);
           write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUUEIR.TimeoutErrIntEn, write_data);

       //Assert DCEUCESR.ErrVld through alias register write
           write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUUESAR.ErrVld, write_data);
           write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUUESAR.ErrType, 'h9);
         
           read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUUESR.ErrVld, read_data);
           compareValues("DCEUUESR_ErrVld","set", read_data, 1);

           // wait for IRQ_C interrupt 
           fork
           begin
             wait (u_csr_probe_vif.IRQ_UC === 1);
           end
           begin
             #200000ns;
             `uvm_error("RUN_MAIN",$sformatf("Timeout! Did not see IRQ_C asserted"));
           end
           join_any
           disable fork;

           write_data = 0;
           write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUUESAR.ErrVld, write_data);

           read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUUESR.ErrVld, read_data);
           compareValues("DCEUUESR_ErrVld", "now clear", read_data, 0);
           write_data = 0;
           write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUUEDR.TimeoutErrDetEn, write_data);
           write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUUEIR.TimeoutErrIntEn, write_data);

           // wait for IRQ_C interrupt to de-assert
           fork
           begin
             wait (u_csr_probe_vif.IRQ_UC === 0);
           end
           begin
             #200000ns;
             `uvm_error("RUN_MAIN",$sformatf("Timeout! Did not see IRQ_C de-asserted"));
           end
           join_any
           disable fork;
  
    endtask
endclass : dce_ucorr_errint_check_through_dceuuesar_seq

//-----------------------------------------------------------------------
//-----------------------------------------------------------------------
/**
* Abstract:
* 
* In this test we will check alias register can be reflected in actual register in status. 
* Test will get arguments of this sequence name from command line and 
* call the body of this sequence.
* 1. write each filed of alias register and should reflect in actual status register. 
*/
//-----------------------------------------------------------------------
//-----------------------------------------------------------------------
//

class dce_csr_dceucesar_seq extends dce_ral_csr_base_seq; 
  `uvm_object_utils(dce_csr_dceucesar_seq)

    uvm_reg_data_t poll_data, read_data, read_data2, write_data;
    bit [7:0]  errthd;
    int        errcount_vld, errthd_vld;
    int        errcount_ovf;

    function new(string name="");
        super.new(name);
    endfunction

    task body();

           getCsrProbeIf();
           ev.trigger();
           write_data = 1;
           write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUCESAR.ErrVld, write_data);

           read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUCESR.ErrVld, read_data);
           compareValues("DCEUCESR_ErrVld","set", read_data, 1);

           write_data = 0;
           write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUCESAR.ErrVld, write_data);

           read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUCESR.ErrVld, read_data);
           compareValues("DCEUCESR_ErrVld","now clear", read_data, 0);

           // Write Alias CSR field ErrType to reflect into SR ErrType filed
           write_data = 4'b1111;
           write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUCESAR.ErrType, write_data);

           read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUCESR.ErrType, read_data);
           compareValues("DCEUCESR_ErrType", "", read_data, write_data);

           write_data = 4'b0000;
           write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUCESAR.ErrType, write_data);

           read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUCESR.ErrType, read_data);
           compareValues("DCEUCESR_ErrType", "", read_data, write_data);

           // Write Alias CSR field ErrInfo to reflect into SR ErrInfo filed
           write_data = 16'hffff;
           write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUCESAR.ErrInfo, write_data);

           read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUCESR.ErrInfo, read_data);
           compareValues("DCEUCESR_ErrInfo", "", read_data, write_data);

           write_data = 16'h0000;
           write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUCESAR.ErrInfo, write_data);

           read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUCESR.ErrInfo, read_data);
           compareValues("XAIUCESR_ErrInfo", "", read_data, write_data);
    endtask
endclass : dce_csr_dceucesar_seq

//-----------------------------------------------------------------------
//-----------------------------------------------------------------------
/**
* Abstract:
* 
* In this test we will check alias register can be reflected in actual register in status. 
* Test will get arguments of this sequence name from command line and 
* call the body of this sequence.
* 1. write each filed of alias register and should reflect in actual status register. 
*/
//-----------------------------------------------------------------------
//-----------------------------------------------------------------------
//

class dce_csr_dceuuesar_seq extends dce_ral_csr_base_seq; 
  `uvm_object_utils(dce_csr_dceuuesar_seq)

    uvm_reg_data_t poll_data, read_data, read_data2, write_data;
    bit [7:0]  errthd;
    int        errcount_vld, errthd_vld;
    int        errcount_ovf;

    function new(string name="");
        super.new(name);
    endfunction

    task body();

           getCsrProbeIf();
           ev.trigger();
           write_data = 1;
           write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUCESAR.ErrVld, write_data);

           read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUCESR.ErrVld, read_data);
           compareValues("DCEUUESR_ErrVld","set", read_data, 1);

           write_data = 0;
           write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUCESAR.ErrVld, write_data);

           read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUCESR.ErrVld, read_data);
           compareValues("DCEUUESR_ErrVld","now clear", read_data, 0);

           // Write Alias CSR field ErrType to reflect into SR ErrType filed
           write_data = 4'b1111;
           write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUCESAR.ErrType, write_data);

           read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUCESR.ErrType, read_data);
           compareValues("DCEUUESR_ErrType","", read_data, write_data);

           write_data = 4'b0000;
           write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUCESAR.ErrType, write_data);

           read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUCESR.ErrType, read_data);
           compareValues("DCEUUESR_ErrType","", read_data, write_data);
           
           // Write Alias CSR field ErrInfo to reflect into SR ErrInfo filed
           write_data = 16'hffff;
           write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUCESAR.ErrInfo, write_data);

           read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUCESR.ErrInfo, read_data);
           compareValues("DCEUUESR_ErrInfo","", read_data, write_data);

           write_data = 16'h0000;
           write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUCESAR.ErrInfo, write_data);

           read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUCESR.ErrInfo, read_data);
           compareValues("DCEUUESR_ErrInfo","", read_data, write_data);
    endtask
endclass : dce_csr_dceuuesar_seq


class dce_csr_no_address_hit_seq extends dce_ral_csr_base_seq; 
  `uvm_object_utils(dce_csr_no_address_hit_seq)

    uvm_reg_data_t poll_data,write_data,read_data;
    ncoreConfigInfo::sys_addr_csr_t csrq[$];
    bit [WSMIADDR-1:0] exp_addr;
    bit [51:0]actual_addr;
    bit [19:0] err_entry;
    bit [5:0] err_way;
    bit [5:0] err_word;
    bit [19:0] err_addr;
    rand bit [47:0] unmapped_lower_addr, range_select;
    bit [47:0] unmapped_upper_addr;
    bit [47:0] all_end_addr[$];
    bit [47:0] max_end_addr[$];
    typedef struct {
            bit [47:0] start_addr;
            bit [47:0] end_addr;
           } s;
    s all_addr_range[$];
    int addr_size[$];
    int max_addr_size[$];
    int min_addr_size[$];
    bit [31:0] addr_low;
    bit [3:0] addr_high;
    int selected_addr_map_index;
    addr_trans_mgr addr_mgr;

    function new(string name="");
        super.new(name);
    endfunction

    function void post_randomize();
      unmapped_upper_addr = (unmapped_lower_addr+((2**(range_select+12))-1));
  `uvm_info(get_full_name(),$sformatf("unmapped_lower_addr = 0x%0x, unmapped_upper_addr = 0x%0x",unmapped_lower_addr, unmapped_upper_addr),UVM_NONE)
    endfunction

    task body();
      getCsrProbeIf();
      get_scb_handle();
      addr_mgr = addr_trans_mgr::get_instance();    //singleton class constructed in base test

      //selected_addr_map_index = $urandom_range(16);
      addr_mgr.set_dce_sf_fix_index_in_user_addrq(ncoreConfigInfo::get_dce_funitid(0),ncoreConfigInfo::user_addrq[ncoreConfigInfo::COH],selected_addr_map_index);
      `uvm_info(get_full_name(),$sformatf("Address queue: %0p",ncoreConfigInfo::user_addrq[ncoreConfigInfo::COH]),UVM_NONE)
      `uvm_info(get_full_name(),$sformatf("selected_addr_map_index = %0d",selected_addr_map_index),UVM_NONE)

      csrq = ncoreConfigInfo::get_all_gpra();
      foreach (csrq[i]) begin
          `uvm_info(get_name(),
              $psprintf("idx: %0d unit: %s hui:%0d low-addr:0x0%h up-addr: 0x%0h sz:%0d", i,
                  csrq[i].unit.name(), csrq[i].mig_nunitid,
                  csrq[i].low_addr, csrq[i].upp_addr, csrq[i].size),
              UVM_LOW) 
          addr_size.push_back(csrq[i].size);
      end
      max_addr_size = addr_size.max();
      min_addr_size = addr_size.min();
      `uvm_info(get_full_name(), $sformatf("max_addr_size = %0d",max_addr_size[0]), UVM_NONE)

      all_addr_range.push_back('{ncoreConfigInfo::BOOT_REGION_BASE,((ncoreConfigInfo::BOOT_REGION_BASE + ncoreConfigInfo::BOOT_REGION_SIZE)-1)});
      all_addr_range.push_back('{ncoreConfigInfo::NRS_REGION_BASE,((ncoreConfigInfo::NRS_REGION_BASE + ncoreConfigInfo::NRS_REGION_SIZE)-1)});
      all_end_addr.push_back((ncoreConfigInfo::BOOT_REGION_BASE + ncoreConfigInfo::BOOT_REGION_SIZE)-1);
      all_end_addr.push_back((ncoreConfigInfo::NRS_REGION_BASE + ncoreConfigInfo::NRS_REGION_SIZE)-1);
      foreach(ncoreConfigInfo::memregion_boundaries[i]) begin
        all_addr_range.push_back('{ncoreConfigInfo::memregion_boundaries[i].start_addr,(ncoreConfigInfo::memregion_boundaries[i].end_addr-1)});
        all_end_addr.push_back(ncoreConfigInfo::memregion_boundaries[i].end_addr);
      end
      max_end_addr = all_end_addr.max();
      `uvm_info(get_full_name(), $sformatf("all_addr_range = %0p, max_end_addr = 0x%0x", all_addr_range, max_end_addr[0]), UVM_NONE)

      this.randomize() with { foreach(all_addr_range[i])
                              {
                                !(unmapped_lower_addr inside {[all_addr_range[i].start_addr:all_addr_range[i].end_addr]});
                                (unmapped_lower_addr < all_addr_range[i].start_addr) -> ((unmapped_lower_addr + (2**(range_select+12))) < all_addr_range[i].start_addr);
                              }
                              48'(unmapped_lower_addr+(2**(range_select+12))) == 49'(unmapped_lower_addr+(2**(range_select+12)));
                              unmapped_lower_addr == ((unmapped_lower_addr >> (range_select+12)) << (range_select+12));
                              range_select <= min_addr_size[0];
                              range_select > 0;
                              unmapped_lower_addr <= max_end_addr[0];
                            };

      addr_low = unmapped_lower_addr[43:0] >> 12;
      addr_high = unmapped_lower_addr[47:44];
      `uvm_info(get_full_name(), $sformatf("addr_low = 0x%0x, addr_high = 0x%0x", addr_low, addr_high), UVM_NONE)
      
      // Set the DCEUUECR_ErrDetEn = 1
      write_data = 1;
      write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUUEDR.DecErrDetEn, write_data); 
      write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUUEIR.DecErrIntEn, write_data);

<% for(var i = 0; i < obj.DutInfo.nGPRA; i++) { %>
      write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUGPRBLR<%=i%>.AddrLow, addr_low);
      write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUGPRBHR<%=i%>.AddrHigh, addr_high);
      write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUGPRAR<%=i%>.Size, range_select);
      write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUGPRAR<%=i%>.Valid, 1);
      write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUGPRAR<%=i%>.HUI, csrq[<%=i%>].mig_nunitid);
      write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUGPRAR<%=i%>.HUT, csrq[<%=i%>].unit == ncoreConfigInfo::DII ? 1 : 0);
<% } %>

      ev.trigger();
      //keep on  Reading the DCEUUESR_ErrVld bit = 1
      `uvm_info(get_full_name(),$sformatf("Polling started for DCEUUESR_ErrVld"), UVM_NONE)
      poll_DCEUUESR_ErrVld(1, poll_data);
      exp_addr = dce_sb.csr_addr_overlap_recall_addr_q[0];
      `uvm_info(get_full_name(),$sformatf("exp_addr = %0h",exp_addr),UVM_NONE)
      read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUUESR.ErrInfo, read_data);
      compareValues("DCEUUESR_ErrInfo", "", read_data, 0);
      read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUUESR.ErrType, read_data);
      compareValues("DCEUUESR_ErrType", "", read_data, 7);
      read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUUELR0.ErrAddr, read_data);
      err_entry = read_data[19:0];
      err_way   = read_data[25:20];
      err_word  = read_data[31:26];
      read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUUELR1.ErrAddr, read_data);
      err_addr  = read_data;
      actual_addr = {err_addr,err_word,err_way,err_entry};
      if (actual_addr !== exp_addr) begin
              `uvm_error(get_full_name(), $sformatf("[%-35s] (Expt: 0x%08h != 0x%08h :Obsv {errAddr: 0x%1h, errWord: 0x%1h, errWay: 0x%1h, errEntry: 0x%1h})", "DceCsr-RecallAddrMismatch", exp_addr, actual_addr, err_addr, err_word, err_way, err_entry));
            end
      fork
          begin
              wait (u_csr_probe_vif.IRQ_UC === 1);
          end
          begin
            #200000ns;
            `uvm_error(get_name(),$sformatf("Timeout! Did not see IRQ_UC asserted"));
          end
        join_any
      disable fork;

      write_data = 0;
      write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUUEDR.DecErrDetEn, write_data); 
      write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUUEIR.DecErrIntEn, write_data);
      write_data = 1;
      write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUUESR.ErrVld, write_data);
      // Read the DCEUUESR_ErrVld should be cleared
      read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUUESR.ErrVld, read_data);
      compareValues("DCEUUESR_ErrVld", "now clear", read_data, 0);
    endtask
endclass : dce_csr_no_address_hit_seq

class dce_csr_dceuedr0_cfgctrl_disable_vbrecovery_seq extends dce_ral_csr_base_seq; 
  `uvm_object_utils(dce_csr_dceuedr0_cfgctrl_disable_vbrecovery_seq)
    uvm_reg_data_t read_data;
    
    function new(string name="");
        super.new(name);
    endfunction
    
    task body();
 
      // Disable VB recovery on wr/up
      read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUEDR0.CfgCtrl, read_data);
      write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUEDR0.CfgCtrl, read_data | (1 << 18));
      
      ev.trigger(); //trigger indicating that the control register is set.
    endtask: body

endclass : dce_csr_dceuedr0_cfgctrl_disable_vbrecovery_seq

//****************************************************************
// seq check that trans_actv register is idle at start of test
//****************************************************************
class dce_csr_trans_actv_seq extends dce_ral_csr_base_seq; 
  `uvm_object_utils(dce_csr_trans_actv_seq)
    uvm_reg_data_t read_data, poll_data;
    
    function new(string name="");
        super.new(name);
    endfunction
    
    task body();
     `uvm_info(get_full_name(),"Waiting for ev_first_scb_txn",UVM_LOW);
      ev_first_scb_txn.wait_ptrigger();
     `uvm_info(get_full_name(),"Received ev_first_scb_txn",UVM_LOW);

      read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUTAR.TransActv, read_data);
      compareValues("DIRUTAR_TransActv", "TransActv expected to indicate busy", read_data, 1);
     // ev_last_cmdreq_issued.wait_ptrigger();
      ev_last_scb_txn.wait_ptrigger();
     // `uvm_info(get_full_name(),"Done waiting for ev_last_cmdreq_issued",UVM_LOW);
      `uvm_info(get_full_name(),"Done waiting for ev_last_scb_txn",UVM_LOW);
      poll_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUTAR.TransActv, 0, poll_data);

    endtask: body

endclass:dce_csr_trans_actv_seq

// csr writes for event messaging controls

class dce_csr_ev_msg_seq extends dce_ral_csr_base_seq;

  `uvm_object_utils(dce_csr_ev_msg_seq)

  dce_env_config csr_ev_msg_env_cfg;

    uvm_reg_data_t poll_data, read_data, write_data,timeout_threshold, timeout_errdeten, timeout_errinten;
    bit [15:0] errinfo;

    function new(string name="");
        super.new(name);
    endfunction

    task body();
      getCsrProbeIf();
      get_scb_handle();

      if($test$plusargs("en_dce_ev_protocol_timeout")) begin
        timeout_errdeten = 1; //$urandom_range(1,0);
        write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUUEDR.TimeoutErrDetEn, timeout_errdeten);

        timeout_errinten = 1; //$urandom_range(1,0);
        write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUUEIR.TimeoutErrIntEn, timeout_errinten);

        if (csr_ev_msg_env_cfg == null)
        `uvm_error(get_full_name(), "csr_ev_msg_env_cfg is null")

    timeout_threshold = uvm_reg_data_t'(csr_ev_msg_env_cfg.ev_prot_timeout_val);
        write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUTOCR.TimeOutThreshold, timeout_threshold);

        `uvm_info("DCE_CSR_EV_MSG_SEQ", $psprintf("Programmed DCE control registers with timeout_errdeten : %0d, timeout_errinten : %0d, timeout_threshold : %0d",timeout_errdeten, timeout_errinten, timeout_threshold), UVM_HIGH);
        // indicates to the dce_bringup_test that the CSR configuration is complete
        ev.trigger();

        // Wait for the error at ev_err_valid on the probe interface
        /*@dce_sb.e_sys_rsp_timeout_err;

        //if(dce_sb.event_in_err == 1) begin
          errinfo[0] = 1'b0; // effinfo[0] -> 0 indicates the protocol error
          errinfo[15:1] = 15'b0; // reserved
   
          `uvm_info(get_full_name(),$sformatf("errinfo = %0h",errinfo),UVM_MEDIUM)

          fork
          begin
             poll_DCEUUESR_ErrVld(1, poll_data);

             read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUUESR.ErrType, read_data);
             compareValues("DCEUUESR.ErrType","should be",read_data,4'hA);

             read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUUESR.ErrInfo, read_data);
             compareValues("DCEUUESR.ErrInfo","should be",read_data,errinfo);

          end
          begin
            #500ns;
            `uvm_error("RUN_MAIN",$sformatf("Timeout! Did not see ErrVld bit set in the DCEUUESR register"));
          end
          join_any
          disable fork;

          fork
          begin
              wait (u_csr_probe_vif.IRQ_UC === 1);
          end
          begin
            #200000ns;
            `uvm_error("RUN_MAIN",$sformatf("Timeout! Did not see IRQ_UC asserted"));
          end
          join_any
          disable fork;

          read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUUESR.ErrType, read_data);

          compareValues("DCEUUESR.ErrType","should be",read_data,4'hA);

          read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUUESR.ErrInfo, read_data);
          compareValues("DCEUUESR.ErrInfo","should be",read_data,errinfo);

          //write_data = 0;
          //write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUUEDR.TimeoutErrDetEn, write_data);
          //write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUUEIR.TimeoutErrIntEn, write_data);

          //timeout_threshold = 0;
          //write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUTOCR.TimeOutThreshold, timeout_threshold);

          write_data = 1;
          write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUUESR.ErrVld, write_data);
          read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUUESR.ErrVld, read_data);
          compareValues("DCEUUESR_ErrVld", "not set", read_data, 0);

          fork
          begin
              wait (u_csr_probe_vif.IRQ_UC === 0);
          end
          begin
            #200000ns;
            `uvm_error("RUN_MAIN",$sformatf("Timeout! Did not see IRQ_UC de-asserted after clearing the ErrVld bit"));
          end
          join_any
          disable fork;*/

        //end // dce_sb.event_in_err
      end
    endtask

endclass : dce_csr_ev_msg_seq

//single SF-setaddr sequence
class dce_sf_fix_index_seq extends dce_ral_csr_base_seq; 
  `uvm_object_utils(dce_sf_fix_index_seq)

    ncoreConfigInfo::sys_addr_csr_t csrq[$];
    int selected_addr_map_index;
    addr_trans_mgr addr_mgr;

    function new(string name="");
        super.new(name);
    endfunction

    task body();
      getCsrProbeIf();
      get_scb_handle();
      addr_mgr = addr_trans_mgr::get_instance();    //singleton class constructed in base test
      
      //Just pick a random set-addr in 0-16
      selected_addr_map_index = $urandom_range(16);
      addr_mgr.set_dce_sf_fix_index_in_user_addrq(ncoreConfigInfo::get_dce_funitid(0), ncoreConfigInfo::user_addrq[ncoreConfigInfo::COH], selected_addr_map_index);
      `uvm_info(get_full_name(),$sformatf("Address queue: %0p",ncoreConfigInfo::user_addrq[ncoreConfigInfo::COH]), UVM_NONE)
      `uvm_info(get_full_name(),$sformatf("selected_addr_map_index = %0d",selected_addr_map_index), UVM_NONE)

      csrq = ncoreConfigInfo::get_all_gpra();
      foreach (csrq[i]) begin
          `uvm_info(get_name(),
              $psprintf("idx: %0d unit: %s hui:%0d low-addr:0x0%h up-addr: 0x%0h sz:%0d", i,
                  csrq[i].unit.name(), csrq[i].mig_nunitid,
                  csrq[i].low_addr, csrq[i].upp_addr, csrq[i].size),
              UVM_LOW) 
      end
        
      
<% for(var i = 0; i < obj.DutInfo.nGPRA; i++) { %>
      write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUGPRBLR<%=i%>.AddrLow, csrq[selected_addr_map_index].low_addr);
      write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUGPRBHR<%=i%>.AddrHigh, csrq[selected_addr_map_index].upp_addr);
      write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUGPRAR<%=i%>.Size, csrq[<%=i%>].size);
      write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUGPRAR<%=i%>.Valid, 1);
      write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUGPRAR<%=i%>.HUI, csrq[<%=i%>].mig_nunitid);
      write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUGPRAR<%=i%>.HUT, csrq[<%=i%>].unit == ncoreConfigInfo::DII ? 1 : 0);
<% } %>

      ev.trigger();
      
      `uvm_info(get_name(),$sformatf("Exiting dce_sf_fix_index_seq"), UVM_LOW);

    endtask
endclass : dce_sf_fix_index_seq

class dce_csr_address_region_overlap_seq extends dce_ral_csr_base_seq; 
  `uvm_object_utils(dce_csr_address_region_overlap_seq)

    uvm_reg_data_t poll_data,write_data,read_data;
    ncoreConfigInfo::sys_addr_csr_t csrq[$];
    bit [WSMIADDR-1:0] exp_addr;
    bit [51:0]actual_addr;
    bit [19:0] err_entry;
    bit [5:0] err_way;
    bit [5:0] err_word;
    bit [19:0] err_addr;
    int selected_addr_map_index;
    addr_trans_mgr addr_mgr;

    function new(string name="");
        super.new(name);
    endfunction

    task body();
      getCsrProbeIf();
      get_scb_handle();
      addr_mgr = addr_trans_mgr::get_instance();    //singleton class constructed in base test

      addr_mgr.set_dce_sf_fix_index_in_user_addrq(ncoreConfigInfo::get_dce_funitid(0),ncoreConfigInfo::user_addrq[ncoreConfigInfo::COH],selected_addr_map_index);
      `uvm_info(get_full_name(),$sformatf("Address queue Size:%0d : %0p", ncoreConfigInfo::user_addrq[ncoreConfigInfo::COH].size(), ncoreConfigInfo::user_addrq[ncoreConfigInfo::COH]),UVM_NONE)
      `uvm_info(get_full_name(),$sformatf("selected_addr_map_index = %0d",selected_addr_map_index),UVM_NONE)

      csrq = ncoreConfigInfo::get_all_gpra();
      foreach (csrq[i]) begin
          `uvm_info(get_name(),
              $psprintf("idx: %0d unit: %s hui:%0d low-addr:0x0%h up-addr: 0x%0h sz:%0d", i,
                  csrq[i].unit.name(), csrq[i].mig_nunitid,
                  csrq[i].low_addr, csrq[i].upp_addr, csrq[i].size),
              UVM_LOW) 
      end
        
      
      // Set the DCEUUECR_ErrDetEn = 1
      write_data = 1;
      write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUUEDR.DecErrDetEn, write_data); 
      write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUUEIR.DecErrIntEn, write_data);

<% for(var i = 0; i < obj.DutInfo.nGPRA; i++) { %>
      write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUGPRBLR<%=i%>.AddrLow, csrq[selected_addr_map_index].low_addr);
      write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUGPRBHR<%=i%>.AddrHigh, csrq[selected_addr_map_index].upp_addr);
      write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUGPRAR<%=i%>.Size, csrq[<%=i%>].size);
      write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUGPRAR<%=i%>.Valid, 1);
      write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUGPRAR<%=i%>.HUI, csrq[<%=i%>].mig_nunitid);
      write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUGPRAR<%=i%>.HUT, csrq[<%=i%>].unit == ncoreConfigInfo::DII ? 1 : 0);
<% } %>

      ev.trigger();
      //keep on  Reading the DCEUUESR_ErrVld bit = 1
      poll_DCEUUESR_ErrVld(1, poll_data);
      //Choose latest recall address for which errvld asserts
      //exp_addr = dce_sb.csr_addr_overlap_recall_addr_q[0];
      exp_addr = dce_sb.csr_addr_overlap_recall_addr_q.pop_back();
      `uvm_info(get_full_name(),$sformatf("exp_addr = %0h",exp_addr),UVM_NONE)
      read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUUESR.ErrInfo, read_data);
      compareValues("DCEUUESR_ErrInfo", "", read_data, 1);
      read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUUESR.ErrType, read_data);
      compareValues("DCEUUESR_ErrType", "", read_data, 7);
      read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUUELR0.ErrAddr, read_data);
      err_entry = read_data[19:0];
      err_way = read_data[25:20];
      err_word = read_data[31:26];
      read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUUELR1.ErrAddr, read_data);
      err_addr = read_data;
      actual_addr = {err_addr,err_word,err_way,err_entry};
      if (actual_addr !== exp_addr) begin
              `uvm_error(get_full_name(),$sformatf("received addr = 0x%0x didn't match with expected addr = 0x%0x",actual_addr, exp_addr))
            end
      fork
          begin
              wait (u_csr_probe_vif.IRQ_UC === 1);
              `uvm_info(get_name(),$sformatf("IRQ_UC asserted"), UVM_LOW);
          end
          begin
            #200000ns;
            `uvm_error(get_name(),$sformatf("Timeout! Did not see IRQ_UC asserted"));
          end
        join_any
      disable fork;

      write_data = 0;
      write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUUEDR.DecErrDetEn, write_data); 
      write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUUEIR.DecErrIntEn, write_data);
      write_data = 1;
      write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUUESR.ErrVld, write_data);
      // Read the DCEUUESR_ErrVld should be cleared
      read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUUESR.ErrVld, read_data);
      compareValues("DCEUUESR_ErrVld", "now clear", read_data, 0);
      `uvm_info(get_name(),$sformatf("Exiting dce_csr_address_region_overlap_seq:body"), UVM_LOW);
    endtask
endclass : dce_csr_address_region_overlap_seq

class dce_csr_mrd_zero_credits_seq extends dce_ral_csr_base_seq;
  `uvm_object_utils(dce_csr_mrd_zero_credits_seq)

    uvm_reg_data_t poll_data, read_data, write_data;
    string credits_msg;

    function new(string name="");
        super.new(name);
    endfunction

    task body();
    getCsrProbeIf();
    get_scb_handle();

    write_data = 1;
    write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUUEDR.SoftwareProgConfigErrDetEn, write_data); 
    write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUUEIR.SoftwareProgConfigErrIntEn, write_data);

    write_data = 'b0;
    <% for(var i = 0; i < obj.DceInfo[obj.Id].nDmis; i++) { %>
    write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUCCR<%=i%>.DMICreditLimit, write_data);
    $sformat(credits_msg, "dce%0d_dmi%0d_nMrdInFlight", ncoreConfigInfo::get_dce_funitid(<%=obj.Id%>), ncoreConfigInfo::get_dmi_funitid(<%=i%>));
    dce_sb.m_credits.scm_credit(credits_msg, write_data);
    read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUCCR<%=i%>.DMICounterState, read_data);
    <% } %>
    
    ev.trigger();
      
    poll_DCEUUESR_ErrVld(1, poll_data);
    read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUUESR.ErrInfo, read_data);
    compareValues("DCEUUESR_ErrInfo", "", read_data, 'b0001);
    read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUUESR.ErrType, read_data);
    compareValues("DCEUUESR_ErrType", "", read_data, 'b1100);

    fork
          begin
              wait (u_csr_probe_vif.IRQ_UC === 1);
              `uvm_info(get_name(),$sformatf("IRQ_UC asserted"), UVM_LOW);
          end
          begin
            #200000ns;
            `uvm_error(get_name(),$sformatf("Timeout! Did not see IRQ_UC asserted"));
          end
    join_any
    disable fork;

        write_data = 0;
        write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUUEDR.DecErrDetEn, write_data); 
        write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUUEIR.DecErrIntEn, write_data);
        write_data = 1;
        write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUUESR.ErrVld, write_data);
        // Read the DCEUUESR_ErrVld should be cleared
        read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUUESR.ErrVld, read_data);
        compareValues("DCEUUESR_ErrVld", "now clear", read_data, 0);
        `uvm_info(get_name(),$sformatf("Exiting dce_csr_mrd_zero_credits_seq :body"), UVM_LOW);
    endtask
endclass : dce_csr_mrd_zero_credits_seq

class dce_csr_mrd_scm_seq extends dce_ral_csr_base_seq; 
  `uvm_object_utils(dce_csr_mrd_scm_seq)

    uvm_reg_data_t read_data, write_data, poll_data;
    int new_credits;
    int rand_state_changes;
    int pick_dmiid;
    string credits_msg;
    int delay;

    function new(string name="");
        super.new(name);
    endfunction

    task body();
    getCsrProbeIf();
    get_scb_handle();
    //#Stimulus.DCE.SCM.Randomize
        read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUSFMAR.MntOpActv, read_data);
    if(read_data == 1)
            poll_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUSFMAR.MntOpActv, 0, poll_data);
        write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUSFMCR.InitSnoopFilter, 1);
        write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUSFMCR.InitSnoopFilter, 0);
        poll_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUSFMAR.MntOpActv, 1, poll_data);
        poll_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUSFMAR.MntOpActv, 0, poll_data);
    ev.trigger();
    rand_state_changes = $urandom_range(10, 30);//Change to knob control

    for(int x=0; x < rand_state_changes; x++) begin
        delay = $urandom_range(1,1000);
        new_credits = $urandom_range(1, 31);
        #(<%=obj.Clocks[0].params.period%>ps * delay); //wait for random cycles
        pick_dmiid = $urandom_range(0,<%=obj.DceInfo[obj.Id].nDmis%>);
        `uvm_info("DCE_CSR_SEQ",$psprintf("Picked dmi id to changes credits is %d",pick_dmiid),UVM_LOW)
        <% for(var i = 0; i < obj.DceInfo[obj.Id].nDmis; i++) { %>
        write_data = new_credits;
        if(pick_dmiid == <%=i%>) begin
                write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUCCR<%=i%>.DMICreditLimit, write_data);
            $sformat(credits_msg, "dce%0d_dmi%0d_nMrdInFlight", ncoreConfigInfo::get_dce_funitid(<%=obj.Id%>), ncoreConfigInfo::get_dmi_funitid(<%=i%>));
            dce_sb.m_credits.scm_credit(credits_msg, new_credits);
                read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUCCR<%=i%>.DMICounterState, read_data);
            `uvm_info("DCE_CSR_SEQ",$psprintf("Credit counter State = %0d for DMI_<%=i%>",read_data),UVM_LOW)
            dce_sb.m_cov.collect_scm_state(ncoreConfigInfo::get_dmi_funitid(pick_dmiid), read_data);
        end
        <% } %>
    end
    #(<%=obj.Clocks[0].params.period%>ps * delay);
<% for(var i = 0; i < obj.DceInfo[obj.Id].nDmis; i++) {
    if(obj.DmiInfo[0].nMrdSkidBufSize > 31) {%>
        write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUCCR<%=i%>.DMICreditLimit, 30);
    $sformat(credits_msg, "dce%0d_dmi%0d_nMrdInFlight", ncoreConfigInfo::get_dce_funitid(<%=obj.Id%>), ncoreConfigInfo::get_dmi_funitid(<%=i%>));
    dce_sb.m_credits.scm_credit(credits_msg, 30);
    <% }
    else { %>
        write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUCCR<%=i%>.DMICreditLimit, <%=obj.DmiInfo[0].nMrdSkidBufSize%>);
    $sformat(credits_msg, "dce%0d_dmi%0d_nMrdInFlight", ncoreConfigInfo::get_dce_funitid(<%=obj.Id%>), ncoreConfigInfo::get_dmi_funitid(<%=i%>));
    dce_sb.m_credits.scm_credit(credits_msg, <%=obj.DmiInfo[0].nMrdSkidBufSize%>);
    <%}
 } %>
      `uvm_info(get_name(),$sformatf("Exiting dce_csr_mrd_scm_seq:body"), UVM_LOW);
    
    endtask

endclass : dce_csr_mrd_scm_seq

class dce_csr_diruuedr_MemErrDetEn_seq extends dce_ral_csr_base_seq; 
  `uvm_object_utils(dce_csr_diruuedr_MemErrDetEn_seq)

    uvm_reg_data_t poll_data, read_data, read_data2, write_data;
    bit [4:0]  errtype;
    bit [15:0] errinfo;
    int        err_sfid;    
    bit [51:0] actual_addr;
    bit [51:0] exp_addr;
    bit [19:0] err_entry;
    bit [11:0] err_way;
    bit [19:0] err_addr;

    function new(string name="");
        super.new(name);
    endfunction

    task body();
      bit dis_uedr_med_4resiliency = $test$plusargs("dis_uedr_med_4resiliency") ? 1 : 0;

<% if(has_secded) { %>
      if ((filter_secded && ($test$plusargs("dir_double_bit_direct_tag_error_test") || $test$plusargs("dir_multi_blk_single_double_tag_direct_error_test") || $test$plusargs("dir_multi_blk_double_tag_direct_error_test")))) begin
        getCsrProbeIf();
        getInjectErrEvent();

        errtype = 5'h0;
        errinfo[1:0] = 2'b11;
        //errinfo[7:2] = Reserved

        if(dis_uedr_med_4resiliency) begin
          ev.trigger();
          inject_error( , , , err_sfid);
          `uvm_info(get_full_name(),$sformatf("Skipping enabling of error detection inside xUEDR"),UVM_NONE)
        end
        else begin
        // Set the DCEUUECR_ErrDetEn = 1
        write_data = 1;
        write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUUEDR.MemErrDetEn, write_data); 
        write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUUEIR.MemErrIntEn, write_data);
        ev.trigger();
        inject_error( , , , err_sfid); 
        errinfo[15:8] = err_sfid;
        //keep on  Reading the DCEUUESR_ErrVld bit = 1
        poll_DCEUUESR_ErrVld(1, poll_data);

        fork
            begin
                wait (u_csr_probe_vif.IRQ_UC === 1);
            end
            begin
              #200000ns;
              `uvm_error(get_name(),$sformatf("Timeout! Did not see IRQ_UC asserted"));
            end
          join_any
        disable fork;
          
        read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUUESR.ErrType, read_data);
        compareValues("DCEUUESR_ErrType","Valid Type", read_data, errtype);
        read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUUESR.ErrInfo, read_data);
        compareValues("DCEUUESR_ErrInfo","Valid Type", read_data, errinfo);
 
        read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUUELR0.ErrAddr, read_data);
        compareValues("DCEUUELR0_ErrEntry","Valid Type", read_data[19:0], err_injected_index);
        //err_entry = read_data;
        compareValues("DCEUUELR0_ErrWay","Valid Type", read_data[25:20], err_injected_way);
        //err_way = read_data;
        read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUUELR1.ErrAddr, read_data); //ErrAddr must be 0
        compareValues("DCEUUELR1_ErrAddr","Valid Type", read_data, 0);
        //err_addr = read_data;
        //actual_addr = {err_addr,err_way,err_entry};
        //exp_addr = {erraddr_1,erraddr_0};
        //if (actual_addr !== exp_addr) begin
        //          `uvm_error(get_full_name(),$sformatf("received addr = 0x%0x didn't match with expected addr = 0x%0x",actual_addr, exp_addr))
        //end

        write_data = 0;
        write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUUEDR.MemErrDetEn, write_data); 
        write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUUEIR.MemErrIntEn, write_data);
        // write  DCEUUESR_ErrVld = 1 , W1C
        write_data = 1;
        write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUUESR.ErrVld, write_data);
        // Read the DCEUUESR_ErrVld should be cleared
        read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUUESR.ErrVld, read_data);
        compareValues("DCEUUESR_ErrVld", "now clear", read_data, 0);
        end
      end else begin
        ev.trigger();
      end
<% } else { %>
        ev.trigger();
<% } %>
    endtask
endclass : dce_csr_diruuedr_MemErrDetEn_seq

class always_inject_error extends dce_ral_csr_base_seq; 
  `uvm_object_utils(always_inject_error)

  uvm_reg_data_t write_data;

  function new(string name="");
      super.new(name);
  endfunction

  task body();
<% if(has_secded) { %>
    if (filter_secded) begin
      write_data = 1;
      write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUCECR.ErrDetEn, write_data);
      ev.trigger();
      ev_always_inject_error.trigger();
    end else begin
      ev.trigger();
    end
<% } else {%>
    ev.trigger();
<% } %>
  endtask
endclass : always_inject_error

class set_max_errthd extends dce_ral_csr_base_seq; 
  `uvm_object_utils(set_max_errthd)

    uvm_reg_data_t poll_data, write_data;
    int        err_sfid;    

    function new(string name="");
        super.new(name);
    endfunction

    task body();
      bit dis_cecr_med_4resiliency = $test$plusargs("dis_cecr_med_4resiliency") ? 1 : 0;
<% if(has_secded) { %>
      getCsrProbeIf();
      getInjectErrEvent();
      if (filter_secded) begin
        write_data = 255;
        <% if(obj.useResiliency) { %>
       `uvm_info(get_name(), $sformatf("Writing DCEUCRTR0 res_corr_err_threshold = %0d", write_data), UVM_NONE)
        write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUCRTR0.ResThreshold, write_data);
        <% } %>
        if(!dis_cecr_med_4resiliency) begin
            write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUCECR.ErrThreshold, write_data);
            write_data = 1;
            write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUCECR.ErrDetEn, write_data);
            write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUCECR.ErrIntEn, write_data);
            ev.trigger();
            inject_error(255,5,1,err_sfid); 
            poll_DCEUCESR_ErrVld(0, poll_data);
            poll_DCEUCESR_ErrCountOverflow(0,poll_data);
            poll_DCEUCESR_ErrCount(255,poll_data);
            if(poll_data != 255) begin
                `uvm_error("RUN_MAIN",$sformatf("ErrCount %0d should be 255",poll_data))
            end
            inject_error(1,,,err_sfid); 
            poll_DCEUCESR_ErrVld(1, poll_data);
            fork
              begin
                wait (u_csr_probe_vif.IRQ_C === 1);
              end
              begin
                #200000ns;
                `uvm_error("RUN_MAIN",$sformatf("Timeout! Did not see IRQ_C asserted"));
              end
            join_any
            disable fork;
            poll_DCEUCESR_ErrCountOverflow(0,poll_data);
            poll_DCEUCESR_ErrCount(255,poll_data);
            if(poll_data != 255) begin
                `uvm_error("RUN_MAIN",$sformatf("ErrCount %0d should be 255",poll_data))
            end
            inject_error(1,,,err_sfid); 
            poll_DCEUCESR_ErrVld(1, poll_data);
            poll_DCEUCESR_ErrCountOverflow(1,poll_data);
            poll_DCEUCESR_ErrCount(255,poll_data);
            if(poll_data != 255) begin
                `uvm_error("RUN_MAIN",$sformatf("ErrCount %0d should be 255",poll_data))
            end
            write_data = 0;
            write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUCECR.ErrDetEn, write_data);
            write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUCECR.ErrIntEn, write_data);
        end
        else begin
          write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUCECR.ErrDetEn, 0);
          ev.trigger();
          inject_error(256,5,1,err_sfid);
          #200us;
          `uvm_info("RUN_MAIN",$sformatf("Timeout!"), UVM_NONE);
        end
        <% if(obj.useResiliency) { %>
        begin
          if(!u_csr_probe_vif.cerr_over_thres_fault) begin
            `uvm_error("RUN_MAIN",$sformatf("cerr_over_thres_fault isn't asserted"));
          end
          else begin
            `uvm_info("RUN_MAIN",$sformatf("cerr_over_thres_fault is asserted"), UVM_NONE);
          end
        end
        <% } %>
      end else begin
        ev.trigger();
      end
<% } else { %>
        ev.trigger();
<% } %>
    endtask
endclass : set_max_errthd




//-----------------------------------------------------------------------
//-----------------------------------------------------------------------
/**
* Abstract:
* 
* In this test we will check if correctable errors are corrected (ErrThreshold filed CECR register) which should be count by Error counter. 
* Test will get arguments of this sequence name from command line and 
* call the body of this sequence.
* 1. If dce contains SECDED, Write Error threshold with random value b/w 1 to 255 (DUT must assert Interrupt once threshold value errors are corrected.
* 2. Eable Error detection from correctable CSR.
* 3. Enable Error Interrupt from CSR. If enabled then correctable iterrupt signal is asserted.
* 4. Inejct single error = ErrThd
* 5. Poll ErrVld=0,ErrOvf=0,Errcount= ErrThd
* 6. Inject single error
* 7. Poll ErrVld=1,ErrOvf=0,Errcount= ErrThd
* 8. Inject single error
* 9. Poll ErrVld=1,ErrOvf=1,Errcount= ErrThd
* 10. Disable Error Detection and Error Interrupt filed by writing 0.
* 11. Clear ErrVld by writting 1 (W1C access types of this field) in status register
* 12. Check if ErrCount should be cleared.
* 13. Repeat step 1 to 12.
*/
//-----------------------------------------------------------------------
//-----------------------------------------------------------------------
//

class dce_csr_dircecr_errInt_seq extends dce_ral_csr_base_seq; 
  `uvm_object_utils(dce_csr_dircecr_errInt_seq)

    uvm_reg_data_t poll_data, read_data, read_data2, write_data;
    bit [4:0]  errtype;
    bit [15:0] errinfo;
    bit [7:0]  errthd;
    int        err_sfid;    
    bit [51:0] actual_addr;
    bit [51:0] exp_addr;
    bit [19:0] err_entry;
    bit [11:0] err_way;
    bit [19:0] err_addr;

    function new(string name="");
        super.new(name);
    endfunction

    task body();
<% if(has_secded) { %>
      getCsrProbeIf();
      getInjectErrEvent();
      if ((filter_secded && ($test$plusargs("dir_single_bit_tag_direct_error_test") || $test$plusargs("dir_multi_blk_single_double_tag_direct_error_test") || $test$plusargs("dir_multi_blk_single_tag_direct_error_test")))) begin
        repeat(3) begin
        errtype = 5'h0;
        errinfo[1:0] = 2'b11;
        //errinfo[7:2] = Reserved

        errthd = $urandom_range(1,7);
        write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUCECR.ErrThreshold, errthd);
        // Set the DCEUCECR_ErrDetEn = 1
        write_data = 1;
        write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUCECR.ErrDetEn, write_data);
        // Set the DCEUCECR_ErrIntEn = 1
        write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUCECR.ErrIntEn, write_data);
        // wait for IRQ_C interrupt 
        ev.trigger();
        inject_error(errthd,5,1,err_sfid); 
        //at err count reached errthd, ErrVld and Overflow should be 0
        //poll_DCEUCESR_ErrVld(0, poll_data);
        //poll_DCEUCESR_ErrCountOverflow(0,poll_data);
        read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUCESR.ErrVld, read_data);
        compareValues("DCEUCESR_ErrVld","reset", read_data, 0);
        read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUCESR.ErrCountOverflow, read_data);
        compareValues("DCEUCESR_ErrCountOverflow","reset", read_data, 0);
        //keep on  Reading the DCEUCESR_ErrVld bit = 1 
        inject_error(1,,,err_sfid); 
        errinfo[15:8] = err_sfid;
        `uvm_info("DBG",$sformatf("Injected error in sfid:%0h", err_sfid), UVM_LOW)
        `uvm_info("DBG",$sformatf("errinfo:%0h", errinfo), UVM_LOW)
        `uvm_info(get_full_name(),$sformatf("cmd_req_addr = %0h",u_csr_probe_vif.cmd_req_addr),UVM_DEBUG)
        //errVld should be 1, if error = errthd+1
        //errOvf should be 0, if error = errthd+1
        poll_DCEUCESR_ErrVld(1, poll_data);
        //poll_DCEUCESR_ErrCountOverflow(0,poll_data);
        read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUCESR.ErrCountOverflow, read_data);
        compareValues("DCEUCESR_ErrCountOverflow","reset", read_data, 0);
        read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUCESR.ErrType, read_data);
        compareValues("DCEUCESR_ErrType","Valid Type", read_data, errtype);
        read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUCESR.ErrInfo, read_data);
        compareValues("DCEUCESR_ErrType","Valid Type", read_data, errinfo);

        read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUCELR0.ErrAddr, read_data);
        compareValues("DCEUCELR0_ErrEntry","Valid Type", read_data[19:0], err_injected_index);
        //err_entry = read_data;
        compareValues("DCEUCELR0_ErrWay","Valid Type", read_data[25:20], err_injected_way);
        //err_way = read_data;
        read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUCELR1.ErrAddr, read_data); //ErrAddr must be 0
        compareValues("DCEUCELR1_ErrAddr","Valid Type", read_data, 0);
        //err_addr = read_data;
        //actual_addr = {err_addr,err_way,err_entry};
        //exp_addr = {erraddr_1,erraddr_0};
        //if (actual_addr !== exp_addr) begin
        //          `uvm_error(get_full_name(),$sformatf("received addr = 0x%0x didn't match with expected addr = 0x%0x",actual_addr, exp_addr))
        //end
        // Read DCEUCESR_ErrCount , it should be at errthd
        poll_data = 0;
        poll_DCEUCESR_ErrCount(errthd,poll_data);
        if(poll_data < errthd) begin
            `uvm_error("RUN_MAIN",$sformatf("ErrCount %0d should be same as ErrThreshold %0d",poll_data,errthd))
        end
        fork
          begin
            wait (u_csr_probe_vif.IRQ_C === 1);
          end
          begin
            #200000ns;
            `uvm_error("RUN_MAIN",$sformatf("Timeout! Did not see IRQ_C asserted"));
          end
        join_any
        disable fork;
        //ovf should set if error = errthd+2
        inject_error(1,,,err_sfid); 
        poll_DCEUCESR_ErrVld(1, poll_data);
        poll_DCEUCESR_ErrCountOverflow(1,poll_data);
        // Read DMIDCEUCESR_ErrCount , it should be at errthd
        poll_data = 0;
        poll_DCEUCESR_ErrCount(errthd,poll_data);
        if(poll_data < errthd) begin
            `uvm_error("RUN_MAIN",$sformatf("ErrCount %0d should be same as ErrThreshold %0d",poll_data,errthd))
        end
        // Set the DCEUCECR_ErrDetEn = 0, to disable the error detection
        write_data = 0;
        write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUCECR.ErrDetEn, write_data);
        // Set the DCEUCECR_ErrIntEn = 0, to disable the error Interrupt
        write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUCECR.ErrIntEn, write_data);
        // write DCEUCESR_ErrVld = 1 to clear it
        write_data = 1;
        write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUCESR.ErrVld, write_data);
        // Read DCEUCESR_ErrVld , it should be 0
        read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUCESR.ErrVld, read_data);
        compareValues("DCEUCESR_ErrVld", "reset", read_data, 0);
        read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUCESR.ErrCount, read_data);
        compareValues("DCEUCESR_ErrCount", "now clear", read_data, 0);
        read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUCESR.ErrCountOverflow, read_data);
        compareValues("DCEUCESR_ErrOvf", "now clear", read_data, 0);
        // Monitor IRQ_C pin , it should be 0 now
        if(u_csr_probe_vif.IRQ_C === 0)begin
          `uvm_info("RUN_MAIN",$sformatf("IRQ_C interrupted de-asseretd"), UVM_LOW)
        end else begin
          `uvm_error("RUN_MAIN",$sformatf("IRQ_C interruped still aseerted"));
        end

        //repeat entire process again
        errthd = $urandom_range(1,7);
        write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUCECR.ErrThreshold, errthd);
        // Set the DCEUCECR_ErrDetEn = 1
        write_data = 1;
        write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUCECR.ErrDetEn, write_data);
        // Set the DCEUCECR_ErrIntEn = 1
        write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUCECR.ErrIntEn, write_data);
        // wait for IRQ_C interrupt 
        ev.trigger();
        inject_error(errthd,5,1,err_sfid); 
        //at err count reached errthd, ErrVld and Overflow should be 0
        //poll_DCEUCESR_ErrVld(0, poll_data);
        //poll_DCEUCESR_ErrCountOverflow(0,poll_data);
        read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUCESR.ErrVld, read_data);
        compareValues("DCEUCESR_ErrVld","reset", read_data, 0);
        read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUCESR.ErrCountOverflow, read_data);
        compareValues("DCEUCESR_ErrCountOverflow","reset", read_data, 0);
        //keep on  Reading the DCEUCESR_ErrVld bit = 1 
        inject_error(1,,,err_sfid); 
        errinfo[15:8] = err_sfid;
        `uvm_info("DBG",$sformatf("Injected error in sfid:%0h", err_sfid), UVM_LOW)
        `uvm_info("DBG",$sformatf("errinfo:%0h", errinfo), UVM_LOW)
        //errVld should be 1, if error = errthd+1
        //errOvf should be 0, if error = errthd+1
        poll_DCEUCESR_ErrVld(1, poll_data);
        //poll_DCEUCESR_ErrCountOverflow(0,poll_data);
        read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUCESR.ErrCountOverflow, read_data);
        compareValues("DCEUCESR_ErrCountOverflow","reset", read_data, 0);
        read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUCESR.ErrType, read_data);
        compareValues("DCEUCESR_ErrType","Valid Type", read_data, errtype);
        read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUCESR.ErrInfo, read_data);
        compareValues("DCEUCESR_ErrType","Valid Type", read_data, errinfo);
        // Read DCEUCESR_ErrCount , it should be at errthd
        poll_data = 0;
        poll_DCEUCESR_ErrCount(errthd,poll_data);
        if(poll_data < errthd) begin
            `uvm_error("RUN_MAIN",$sformatf("ErrCount %0d should be same as ErrThreshold %0d",poll_data,errthd))
        end
        fork
          begin
            wait (u_csr_probe_vif.IRQ_C === 1);
          end
          begin
            #200000ns;
            `uvm_error("RUN_MAIN",$sformatf("Timeout! Did not see IRQ_C asserted"));
          end
        join_any
        disable fork;
        //ovf should set if error = errthd+2
        inject_error(1,,,err_sfid); 
        poll_DCEUCESR_ErrVld(1, poll_data);
        poll_DCEUCESR_ErrCountOverflow(1,poll_data);
        // Read DMIDCEUCESR_ErrCount , it should be at errthd
        poll_data = 0;
        poll_DCEUCESR_ErrCount(errthd,poll_data);
        if(poll_data < errthd) begin
            `uvm_error("RUN_MAIN",$sformatf("ErrCount %0d should be same as ErrThreshold %0d",poll_data,errthd))
        end
        // Set the DCEUCECR_ErrDetEn = 0, to disable the error detection
        write_data = 0;
        write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUCECR.ErrDetEn, write_data);
        // Set the DCEUCECR_ErrIntEn = 0, to disable the error Interrupt
        write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUCECR.ErrIntEn, write_data);
        // write DCEUCESR_ErrVld = 0 to verify Not clear case 
    if($test$plusargs("W1C_w0_test_NC")) begin
        write_data = 0;
            write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUCESR.ErrVld, write_data);
            read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUCESR.ErrVld, read_data);
            compareValues("DCEUCESR_ErrVld", "should not clear", read_data, 1);
            read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUCESR.ErrCountOverflow, read_data);
            compareValues("DCEUCESR_ErrOvf", "should not clear", read_data, 1);

    end
        // write DCEUCESR_ErrVld = 1 to clear it
        write_data = 1;
        write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUCESR.ErrVld, write_data);
        // Read DCEUCESR_ErrVld , it should be 0
        read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUCESR.ErrVld, read_data);
        compareValues("DCEUCESR_ErrVld", "reset", read_data, 0);
        read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUCESR.ErrCount, read_data);
        compareValues("DCEUCESR_ErrCount", "now clear", read_data, 0);
        read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUCESR.ErrCountOverflow, read_data);
        compareValues("DCEUCESR_ErrOvf", "now clear", read_data, 0);
        // Monitor IRQ_C pin , it should be 0 now
        if(u_csr_probe_vif.IRQ_C === 0)begin
          `uvm_info("RUN_MAIN",$sformatf("IRQ_C interrupted de-asseretd"), UVM_LOW)
        end else begin
          `uvm_error("RUN_MAIN",$sformatf("IRQ_C interruped still aseerted"));
        end
       if(!$test$plusargs("back_to_back_error"))
       break;

      end
      end else if (($test$plusargs("dir_inject_sram_address_protection_test")) || (filter_parity && ($test$plusargs("dir_single_bit_tag_direct_error_test") || $test$plusargs("dir_multi_blk_single_double_tag_direct_error_test") || $test$plusargs("dir_multi_blk_single_tag_direct_error_test")))) begin
        errtype = 4'h0;
        errinfo[1:0] = 2'b11;
        write_data = 1;
        write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUUEDR.MemErrDetEn, write_data);
        write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUUEIR.MemErrIntEn, write_data);
        ev.trigger();
        inject_error( , , , err_sfid); 
        errinfo[15:8] = err_sfid;
        `uvm_info("DBG",$sformatf("Injected error in sfid:%0h", err_sfid), UVM_LOW)
        `uvm_info("DBG",$sformatf("errinfo:%0h", errinfo), UVM_LOW)
        fork
        begin
          if (u_csr_probe_vif.IRQ_UC === 0) begin
            @(u_csr_probe_vif.IRQ_UC);
          end
        end
        begin
          #200000ns;
          `uvm_error("RUN_MAIN",$sformatf("Timeout! Did not see IRQ_UC asserted"));
        end
        join_any
        disable fork;
        read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUUESR.ErrVld, read_data);
        compareValues("DCEUUESR_ErrVld", "set after inte", read_data, 1);
        read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUUESR.ErrType, read_data);
        compareValues("DCEUUESR_ErrType","Valid Type", read_data, errtype);
        read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUUESR.ErrInfo, read_data);
        compareValues("DCEUUESR_ErrInfo","Valid Type", read_data, errinfo);

        read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUUELR0.ErrAddr, read_data);
        compareValues("DCEUUELR0_ErrEntry","Valid Type", read_data[19:0], err_injected_index);
        //err_entry = read_data;
        compareValues("DCEUUELR0_ErrWay","Valid Type", read_data[25:20], err_injected_way);
        //err_way = read_data;
        read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUUELR1.ErrAddr, read_data); //ErrAddr must be 0
        compareValues("DCEUUELR1_ErrAddr","Valid Type", read_data, 0);
        //err_addr = read_data;
        //actual_addr = {err_addr,err_way,err_entry};
        //exp_addr = {erraddr_1,erraddr_0};
        //if (actual_addr !== exp_addr) begin
        //          `uvm_error(get_full_name(),$sformatf("received addr = 0x%0x didn't match with expected addr = 0x%0x",actual_addr, exp_addr))
        //end
        write_data = 0;
        write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUUEDR.MemErrDetEn, write_data); 
        write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUUEIR.MemErrIntEn, write_data);
        // write  DCEUUESR_ErrVld = 1 , W1C
        write_data = 1;
        write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUUESR.ErrVld, write_data);
        // Read the DCEUUESR_ErrVld should be cleared
        read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUUESR.ErrVld, read_data);
        compareValues("DCEUUESR_ErrVld", "now clear", read_data, 0);
      end else begin
        ev.trigger();
      end
<% } else { %>
        ev.trigger();
<% } %>
    endtask
endclass : dce_csr_dircecr_errInt_seq

//CSR sequences//
//-----------------------------------------------------------------------
//-----------------------------------------------------------------------
/**
* Abstract:
* 
* In this test we will check if ErrDetEn is set, correctable errors are logged by design. 
* Test will get arguments of this sequence name from command line and 
* call the body of this sequence.
* 1. If dir contains SECDED, enable Error detection from correctable CSR
* 2. Enable DIR single-bit error from command line
* 3. Poll Error valid bit from Correctable status register until it is 1. (Error captured)
* 4. Disable error detection in CSR.
* 5. Read ErrVld, which should be set until its cleared.
* 6. Clear ErrVld by writting 1 (W1C access types of this field) in status register
* 7. Compare read value with 0 for ErrVld field in status register (should be cleared)
*/
//-----------------------------------------------------------------------
//-----------------------------------------------------------------------
//
class dce_csr_dirucecr_errDetEn_seq extends dce_ral_csr_base_seq; 
  `uvm_object_utils(dce_csr_dirucecr_errDetEn_seq)

    uvm_reg_data_t poll_data, read_data, read_data2, write_data;
    bit [7:0]  errthd;
    int        errcount_vld, errthd_vld;
    int        errcount_ovf;
    int        err_sfid;    

    function new(string name="");
        super.new(name);
    endfunction

    task body();
<% if(has_secded) { %>
      getCsrProbeIf();
      getInjectErrEvent();
      if ((filter_secded && ($test$plusargs("dir_single_bit_tag_direct_error_test") || $test$plusargs("dir_multi_blk_single_double_tag_direct_error_test") || $test$plusargs("dir_multi_blk_single_tag_direct_error_test")))) begin
        // Set the DCEUCECR_ErrDetEn = 1
        write_data = 1;
        write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUCECR.ErrDetEn, write_data);
        ev.trigger();
        inject_error( , , , err_sfid); 
        //keep on  Reading the DCEUCESR_ErrVld bit = 1
        poll_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUCESR.ErrVld,1,poll_data);
        // Set the DCEUCECR_ErrDetEn = 0, to diable the error detection
        write_data = 0;
        write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUCECR.ErrDetEn, write_data);
        // Read DCEUCESR_ErrVld , it should be 1
        read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUCESR.ErrVld, read_data);
        compareValues("DCEUCESR_ErrVld", "set", read_data, 1);
        // write  DCEUCESR_ErrVld = 1 , W1C
        write_data = 0;
        write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUCESAR.ErrVld, write_data);
        // Read the DCEUCESR_ErrVld should be cleared
        read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUCESR.ErrVld, read_data);
        compareValues("DCEUCESR_ErrVld", "now clear", read_data, 0);
      end else if ((filter_parity && ($test$plusargs("dir_single_bit_tag_direct_error_test") || $test$plusargs("dir_multi_blk_single_double_tag_direct_error_test") || $test$plusargs("dir_multi_blk_single_tag_direct_error_test")))) begin
        write_data = 1;
        write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUUEDR.MemErrDetEn, write_data);
        ev.trigger();
        inject_error( , , , err_sfid); 
        poll_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUUESR.ErrVld,1,poll_data);
        write_data = 0;
        write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUUEDR.MemErrDetEn, write_data); 
        // write  DCEUUESR_ErrVld = 1 , W1C
        write_data = 1;
        write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUUESR.ErrVld, write_data);
        // Read the DCEUUESR_ErrVld should be cleared
        read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUUESR.ErrVld, read_data);
        compareValues("DCEUUESR_ErrVld", "now clear", read_data, 0);
      end else begin
        ev.trigger();
      end
<% } else { %>
        ev.trigger();
<% } %>
    endtask
endclass : dce_csr_dirucecr_errDetEn_seq

//-----------------------------------------------------------------------
//-----------------------------------------------------------------------
/**
* Abstract:
* 
* In this test we will check if correctable errors are corrected (ErrThreshold filed CECR register) which should be count by Error counter. 
* Test will get arguments of this sequence name from command line and 
* call the body of this sequence.
* 1. If dir contains SECDED, Write Error threshold with random value b/w 1 to 20 (DUT must assert Interrupt once threshold value errors are corrected.
* 2. Eable Error detection from correctable CSR.
* 3. Enable Error Interrupt from CSR. If enabled then correctable iterrupt signal is asserted.
* 4. Enable DIR single-bit error from command line
* 5. Poll ErrVld from Status register until it is set i.e. Correctable Errors are logged.
* 7. Compare ErrCount value and should be non-zero 
* 8. Disable Error Detection and Error Interrupt filed by writing 0.
* 9. Clear ErrVld by writting 1 (W1C access types of this field) in status register
* 10. Check if ErrCount should be cleared.
* 11. Repeat step 1 to 10.
*/
//-----------------------------------------------------------------------
//-----------------------------------------------------------------------
//

class dce_csr_dirucecr_errThd_seq extends dce_ral_csr_base_seq; 
  `uvm_object_utils(dce_csr_dirucecr_errThd_seq)

    uvm_reg_data_t poll_data, read_data, read_data2, write_data;
    bit [7:0]  errthd;
    int        errcount_vld, errthd_vld;
    int        errcount_ovf;
    int        err_sfid;    

    function new(string name="");
        super.new(name);
    endfunction

    task body();
<% if(has_secded) { %>
      getCsrProbeIf();
      getInjectErrEvent();
      if ((filter_secded && ($test$plusargs("dir_single_bit_tag_direct_error_test") || $test$plusargs("dir_multi_blk_single_double_tag_direct_error_test") || $test$plusargs("dir_multi_blk_single_tag_direct_error_test")))) begin
        // Set the DCEUCECR_ErrThreshold 
        errthd = $urandom_range(1,7);
        write_data = errthd;
        <% if(obj.useResiliency) { %>
        write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUCRTR0.ResThreshold, write_data);
        <% } %>
        write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUCECR.ErrThreshold, write_data);
        // Set the DCEUCECR_ErrDetEn = 1
        write_data = 1;
        write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUCECR.ErrDetEn, write_data);
        // Set the DCEUCECR_ErrIntEn = 1
        write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUCECR.ErrIntEn, write_data);
        // write  DCEUCESR_ErrVld = 1 , to reset it
        write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUCESR.ErrVld, write_data);
        ev.trigger();
        inject_error(errthd+1,5,1,err_sfid); 
        //keep on  Reading the DCEUCESR_ErrVld bit = 1 
        poll_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUCESR.ErrVld,1,poll_data);
        // Read DCEUCESR_ErrCount , it should be at errthd
        poll_data = 0;
        poll_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUCESR.ErrCount,errthd,poll_data);
        if(poll_data < errthd) begin
            `uvm_error("RUN_MAIN",$sformatf("ErrCount %0d should be same as ErrThreshold %0d",poll_data,errthd))
        end
        <% if(obj.useResiliency) { %>
        begin
          if(!u_csr_probe_vif.cerr_over_thres_fault) begin
            `uvm_error("RUN_MAIN",$sformatf("cerr_over_thres_fault isn't asserted."));
          end
          else begin
            `uvm_info("RUN_MAIN",$sformatf("cerr_over_thres_fault is asserted."), UVM_NONE);
          end
        end
        <% } %>
        // Set the DCEUCECR_ErrDetEn = 0
        write_data = 0;
        write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUCECR.ErrDetEn, write_data);
        // write : DCEUCESR_ErrVld = 1 , to reset it
        write_data = 1;
        write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUCESR.ErrVld, write_data);
        // Read DCEUCESR_ErrVld , it should be 0
        read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUCESR.ErrVld, read_data);
        compareValues("DCEUCESR_ErrVld", "now clear", read_data, 0);
        read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUCESR.ErrCount, read_data);
        compareValues("DCEUCESR_ErrCount", "now clear", read_data, 0);
        ///////////////////////////////////
        // Repeat entire process
        ///////////////////////////////////
        // Set the DCEUCECR_ErrThreshold 
        errthd = $urandom_range(1,7);
        poll_data = 0;
        write_data = errthd;
        write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUCECR.ErrThreshold, write_data);
        // Set the DCEUCECR_ErrDetEn = 1
        write_data = 1;
        write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUCECR.ErrDetEn, write_data);
        // Set the DCEUCECR_ErrIntEn = 1
        write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUCECR.ErrIntEn, write_data);
        // write  DCEUCESR_ErrVld = 1 , to reset it
        write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUCESR.ErrVld, write_data);
        ev.trigger();
        inject_error(errthd+1,5,1,err_sfid); 
        //keep on  Reading the DCEUCESR_ErrVld bit = 1 
        poll_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUCESR.ErrVld,1,poll_data);
        // Read DCEUCESR_ErrCount , it should be at errthd
        poll_data = 0;
        poll_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUCESR.ErrCount,errthd,poll_data);
        if(poll_data < errthd) begin
            `uvm_error("RUN_MAIN",$sformatf("ErrCount %0d should be same as ErrThreshold %0d",poll_data,errthd))
        end
        // Set the DCEUCECR_ErrDetEn = 0
        write_data = 0;
        write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUCECR.ErrDetEn, write_data);
        // write : DCEUCESR_ErrVld = 1 , to reset it
        write_data = 1;
        write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUCESR.ErrVld, write_data);
        // Read DCEUCESR_ErrVld , it should be 0
        read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUCESR.ErrVld, read_data);
        compareValues("DCEUCESR_ErrVld", "now clear", read_data, 0);
        read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUCESR.ErrCount, read_data);
        compareValues("DCEUCESR_ErrCount", "now clear", read_data, 0);     
      end else if ((filter_parity && ($test$plusargs("dir_single_bit_tag_direct_error_test") || $test$plusargs("dir_multi_blk_single_double_tag_direct_error_test") || $test$plusargs("dir_multi_blk_single_tag_direct_error_test")))) begin
        write_data = 1;
        write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUUEDR.MemErrDetEn, write_data);
        ev.trigger();
        inject_error( , , , err_sfid); 
        poll_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUUESR.ErrVld,1,poll_data);
        <% if(obj.useResiliency) { %>
        begin
          if(u_csr_probe_vif.cerr_over_thres_fault) begin
            `uvm_error("RUN_MAIN",$sformatf("cerr_over_thres_fault is asserted."));
          end
          else begin
            `uvm_info("RUN_MAIN",$sformatf("cerr_over_thres_fault isn't asserted."), UVM_NONE);
          end
        end
        <% } %>
        write_data = 0;
        write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUUEDR.MemErrDetEn, write_data); 
        // write  DCEUUESR_ErrVld = 1 , W1C
        write_data = 1;
        write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUUESR.ErrVld, write_data);
        // Read the DCEUUESR_ErrVld should be cleared
        read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUUESR.ErrVld, read_data);
        compareValues("DCEUUESR_ErrVld", "now clear", read_data, 0);
      end else begin
        ev.trigger();
      end
<% } else { %>
        ev.trigger();
<% } %>
    endtask
endclass : dce_csr_dirucecr_errThd_seq

//  ________________________________________________________________________________________________________
//
//  Concerto System Architecture Specification Revision B, Version 0.4 Section 8.7 Page 55
//  ________________________________________________________________________________________________________
//
//  Additionally, in the case that software is writing the error status register in the same cycle that one or
//  more errors occur, the result appears as if first the error occurred and then the write updated the state
//  of the register. In the case that software is writing the error status alias register in the same cycle that
//  one or more errors occur, the write simply updates the state of the register.
//
//-----------------------------------------------------------------------
class dce_csr_dirucecr_sw_write_seq extends dce_ral_csr_base_seq; 
  `uvm_object_utils(dce_csr_dirucecr_sw_write_seq)

   uvm_reg_data_t poll_data, read_data, read_data2, write_data;
   bit [7:0]  errthd;
   int        errcount_vld, errthd_vld;
   int        i;
   int        err_sfid; 

    function new(string name="");
        super.new(name);
    endfunction

    task body();
<% if(has_secded) { %>
      if ((filter_secded && ($test$plusargs("dir_single_bit_tag_direct_error_test") || $test$plusargs("dir_multi_blk_single_double_tag_direct_error_test") || $test$plusargs("dir_multi_blk_single_tag_direct_error_test")))) begin
        getCsrProbeIf();
        getInjectErrEvent();
        // Set the DCEUCECR_ErrDetEn = 1
        write_data = 1;
        write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUCECR.ErrDetEn, write_data);
        ev.trigger();
        inject_error( , , , err_sfid); 
        poll_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUCESR.ErrVld,1,poll_data);
        // write  DCEUCESR_ErrVld = 1 , to reset it
        write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUCESR.ErrVld, write_data);
        
        write_data = 0;
        fork
            begin
              for (i=0;i<100;i++) begin
                write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUCESAR.ErrVld, write_data);
              end
            end
            begin
              for (i=0;i<110;i++) begin
                inject_error( , , , err_sfid); 
              end
            end
        join
        
        // Set the DCEUCECR_ErrDetEn = 0
        write_data = 0;
        write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUCECR.ErrDetEn, write_data);
        // if vld is set, reset it
        read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUCESR.ErrVld, read_data);
        if(read_data) begin
           write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUCESAR.ErrVld, write_data);
        end
      end else begin
        ev.trigger();
      end
<% } else { %>
        ev.trigger();
<% } %>
    endtask
endclass : dce_csr_dirucecr_sw_write_seq

class dce_csr_diruuecr_sw_write_seq extends dce_ral_csr_base_seq; 
  `uvm_object_utils(dce_csr_diruuecr_sw_write_seq)

   uvm_reg_data_t poll_data, read_data, read_data2, write_data;
   bit [7:0]  errthd;
   int        errcount_vld, errthd_vld;
   int        i,j;
   int        err_sfid; 

    function new(string name="");
        super.new(name);
    endfunction

    task body();
<% if(has_secded) { %>
      if ((filter_secded && ($test$plusargs("dir_double_bit_direct_tag_error_test") || $test$plusargs("dir_multi_blk_single_double_tag_direct_error_test") || $test$plusargs("dir_multi_blk_double_tag_direct_error_test")))) begin
        getCsrProbeIf();
        getInjectErrEvent();
        // Set the DCEUUEDR_MemErrDetEn = 1
        write_data = 1;
        write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUUEDR.MemErrDetEn, write_data);
        ev.trigger();
        inject_error( , , , err_sfid); 
        poll_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUUESR.ErrVld,1,poll_data);
        // write  DCEUUESR_ErrVld = 1 , to reset it
        write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUUESR.ErrVld, write_data);
        
        write_data = 0;
        fork
            begin
              for (i=0;i<100;i++) begin
                write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUUESAR.ErrVld, write_data);
              end
            end
            begin
              for (j=0;j<10;j++) begin
                inject_error( , , , err_sfid); 
              end
            end
        join
        
        // Set the DCEUUECR_MemErrDetEn = 0
        write_data = 0;
        write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUUEDR.MemErrDetEn, write_data);
        // if vld is set, reset it
        read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUUESR.ErrVld, read_data);
        if(read_data) begin
           write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUUESAR.ErrVld, write_data);
        end
      end else begin
        ev.trigger();
      end
<% } else { %>
        ev.trigger();
<% } %>
    endtask
endclass : dce_csr_diruuecr_sw_write_seq

//-----------------------------------------------------------------------
//-----------------------------------------------------------------------
/**
* Abstract:
* 
* In this test we will check if correctable errors are injected and logging is disabled (ErrDetEn set to 0) ErrVld and ErrCount should be 0. 
* Test will get arguments of this sequence name from command line and 
* call the body of this sequence.
* 1. Enable DIR single-bit error from command line
* 2. Compare ErrVld value and should be zero 
* 3. Compare ErrCount value and should be zero 
*/
//-----------------------------------------------------------------------
//-----------------------------------------------------------------------
//

class dce_csr_dirucecr_noDetEn_seq extends dce_ral_csr_base_seq; 
  `uvm_object_utils(dce_csr_dirucecr_noDetEn_seq)

    uvm_reg_data_t poll_data, read_data, read_data2, write_data;
    bit [7:0]  errthd;
    int        errcount_vld, errthd_vld;
    int        errcount_ovf;
    int        err_sfid;    

    function new(string name="");
        super.new(name);
    endfunction

    task body();
<% if(has_secded) { %>
      getCsrProbeIf();
      getInjectErrEvent();
      if ((filter_secded && ($test$plusargs("dir_single_bit_tag_direct_error_test") || $test$plusargs("dir_multi_blk_single_double_tag_direct_error_test") || $test$plusargs("dir_multi_blk_single_tag_direct_error_test")))) begin
        ev.trigger();
        inject_error( , , , err_sfid); 
        // Don't Set the DCEUCECR_ErrDetEn = 1
        //Reading the DCEUCESR_ErrVld bit = 0
        read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUCESR.ErrVld, read_data);
        compareValues("DCEUCESR_ErrVld", "not set", read_data, 0);
        // Read DCEUCESR_ErrCount , it should be at 0
        read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUCESR.ErrCount, read_data);
        compareValues("DCEUCESR_ErrCount","not set", read_data, 0);
      end else if ((filter_parity && ($test$plusargs("dir_single_bit_tag_direct_error_test") || $test$plusargs("dir_multi_blk_single_double_tag_direct_error_test") || $test$plusargs("dir_multi_blk_single_tag_direct_error_test")))) begin
        write_data = 0;
        write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUUEDR.MemErrDetEn, write_data);
        ev.trigger();
        inject_error( , , , err_sfid); 
        read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUUESR.ErrVld, read_data);
        compareValues("DCEUUESR_ErrVld", "not set", read_data, 0);
      end else begin
        ev.trigger();
      end
<% } else { %>
        ev.trigger();
<% } %>
    endtask
endclass : dce_csr_dirucecr_noDetEn_seq

//-----------------------------------------------------------------------
/**
* Abstract:
* 
* In this test we will check if correctable errors are injected and interrupt assertion is disabled (ErrIntEn set to 0) ErrVld and ErrCount should be 0. 
* Test will get arguments of this sequence name from command line and 
* call the body of this sequence.
* 1. Enable DIR single-bit error from command line
* 2. Program ErrThreshold to 1 so we can check interupt is asserted or not.
* 3. Enable  error detection and logging.       
* 4. Wait to check if interrupt signal is asserted or not.
* 5. Poll for ErrVld be set and compare to 1.
* 6. Clear ErrVld value and should be zero 
* 7. Compare ErrCountOverflow value and should be zero 
*/
//-----------------------------------------------------------------------
//-----------------------------------------------------------------------
//

class dce_csr_dirucecr_noIntEn_seq extends dce_ral_csr_base_seq; 
  `uvm_object_utils(dce_csr_dirucecr_noIntEn_seq)

    uvm_reg_data_t poll_data, read_data, read_data2, write_data;
    bit [7:0]  errthd;
    int        errcount_vld, errthd_vld;
    int        errcount_ovf;
    int        err_sfid;    

    function new(string name="");
        super.new(name);
    endfunction

    task body();
<% if(has_secded) { %>
      getCsrProbeIf();
      getInjectErrEvent();
      if ((filter_secded && ($test$plusargs("dir_single_bit_tag_direct_error_test") || $test$plusargs("dir_multi_blk_single_double_tag_direct_error_test") || $test$plusargs("dir_multi_blk_single_tag_direct_error_test")))) begin
        // Set the DCEUCECR_ErrThreshold 
        write_data = 1;
        write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUCECR.ErrThreshold, write_data);
        // Set the DCEUCECR_ErrDetEn = 1
        write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUCECR.ErrDetEn, write_data);
        // Dont Set the DCEUCECR_ErrIntEn = 1
        ev.trigger();
        inject_error(2,5,1,err_sfid); 
        // wait for IRQ_C interrupt for a while. Shouldn't happen. Then join
        //#Cov.DMI.ErrIntDisEnCorrErrs
        fork
          begin
           `uvm_info("RUN_MAIN",$sformatf("Waiting for interrupt. It shouldn't happen"), UVM_NONE)
           @(posedge u_csr_probe_vif.IRQ_C);
           `uvm_error("RUN_MAIN", $sformatf("Unexpected interrupt! IntEn is not set"));
          end
          begin
           #50000ns;
           `uvm_info("RUN_MAIN",$sformatf("Done waiting. No interrupt received"), UVM_NONE)
          end
        join_any
        disable fork;
        //Reading the DCEUCESR_ErrVld bit = 1
        poll_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUCESR.ErrVld,1,poll_data);
        read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUCESR.ErrVld, read_data);
        compareValues("DCEUCESR_ErrVld", "set", read_data, 1);
        // write DCEUCESR_ErrVld = 1 to clear it
        write_data = 1;
        write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUCESR.ErrVld, write_data);
        read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUCESR.ErrCountOverflow, read_data);
        compareValues("DCEUCESR_ErrCountOverflow", "Should be clear", read_data, 0);
        // write DCEUCESR_ErrVld = 1 to clear it
      end else if ((filter_parity && ($test$plusargs("dir_single_bit_tag_direct_error_test") || $test$plusargs("dir_multi_blk_single_double_tag_direct_error_test") || $test$plusargs("dir_multi_blk_single_tag_direct_error_test")))) begin
        write_data = 1;
        write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUUEDR.MemErrDetEn, write_data);
        write_data = 0;
        write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUUEIR.MemErrIntEn, write_data);
        ev.trigger();
        inject_error( , , , err_sfid); 
        fork
          begin
           `uvm_info("RUN_MAIN",$sformatf("Waiting for interrupt. It shouldn't happen"), UVM_NONE)
           @(posedge u_csr_probe_vif.IRQ_UC);
           `uvm_error("RUN_MAIN", $sformatf("Unexpected interrupt! IntEn is not set"));
          end
          begin
           #50000ns;
           `uvm_info("RUN_MAIN",$sformatf("Done waiting. No interrupt received"), UVM_NONE)
          end
        join_any
        disable fork;
        //Reading the DCEUUESR_ErrVld bit = 1
        poll_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUUESR.ErrVld,1,poll_data);
        write_data = 0;
        write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUUEDR.MemErrDetEn, write_data);
        write_data = 1;
        write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUUESR.ErrVld, write_data);
        read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUUESR.ErrVld, read_data);
        compareValues("DCEUUESR_ErrVld", "not set", read_data, 0);
      end else begin
        ev.trigger();
      end
<% } else { %>
        ev.trigger();
<% } %>
    endtask
endclass : dce_csr_dirucecr_noIntEn_seq

//-----------------------------------------------------------------------
/**
* Abstract:
* 
* In this test we will check if insert double bit sram errors is detected by interrupt. 
* Test will get arguments of this sequence name from command line and 
* call the body of this sequence.
* Inject double bit DIR error for all transfer 
* 1. Program Error detection for uncorrectable double bit error in DIR
* 2. Program Error interrupt with 1. 
* 3. Poll until error information logged and interrupt is asserted.
* 4. Compare error type with appropriate type mentioned in table.
* 5. Program Error interrupt with 0 (disable). 
* 6. Clear ErrVld bit with writing 1.
* 7. Poll interrupt signal which should not asserted.
*/
//-----------------------------------------------------------------------
//-----------------------------------------------------------------------
class dce_csr_diruueir_MemErrInt_seq extends dce_ral_csr_base_seq; 
  `uvm_object_utils(dce_csr_diruueir_MemErrInt_seq)

    uvm_reg_data_t poll_data, read_data, read_data2, write_data;
    bit [7:0]  errthd;
    int        errcount_vld, errthd_vld;
    int        errcount_ovf;
    bit [3:0] errtype;
    bit [15:0] errinfo;
    int        err_sfid;    

    function new(string name="");
        super.new(name);
    endfunction

    task body();
<% if(has_secded) { %>
      if ((filter_secded && ($test$plusargs("dir_double_bit_direct_tag_error_test") || $test$plusargs("dir_multi_blk_single_double_tag_direct_error_test") || $test$plusargs("dir_multi_blk_double_tag_direct_error_test")))) begin
        repeat(5) begin
        getCsrProbeIf();
        getInjectErrEvent();
        errtype = 4'h0;
        errinfo[1:0] = 2'b11;
        //errinfo[7:2] = Reserved
        // Set the DCEUUEIR_ProtErrIntEn = 1
        write_data = 1;
        write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUUEDR.MemErrDetEn, write_data);
        // Set the DCEUUEIR_ProtErrIntEn = 1
        write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUUEIR.MemErrIntEn, write_data);
        ev.trigger();
        inject_error( , , , err_sfid); 
        errinfo[15:8] = err_sfid;
        `uvm_info("DBG",$sformatf("Injected error in sfid:%0h", err_sfid), UVM_LOW)
        `uvm_info("DBG",$sformatf("errinfo:%0h", errinfo), UVM_LOW)
        // wait for IRQ_UC interrupt 
        //if(u_csr_probe_vif.IRQ_UC == 0)begin // wait only if not already set
        fork
        begin
          if (u_csr_probe_vif.IRQ_UC === 0) begin
            @(u_csr_probe_vif.IRQ_UC);
          end
        end
        begin
          #200000ns;
          `uvm_error("RUN_MAIN",$sformatf("Timeout! Did not see IRQ_UC asserted"));
        end
        join_any
        disable fork;
        //end
        // Read the DCEUUESR_ErrVld
        read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUUESR.ErrVld, read_data);
        compareValues("DCEUUESR_ErrVld", "set after inte", read_data, 1);
        read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUUESR.ErrType, read_data);
        compareValues("DCEUUESR_ErrType","Valid Type", read_data, errtype);
        read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUUESR.ErrInfo, read_data);
        compareValues("DCEUUESR_ErrInfo","Valid Type", read_data, errinfo);
        // write DCEUUESR_ErrVld = 1 to clear it
        write_data = 1;
        write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUUESR.ErrVld, write_data);
        // Read DCEUUESR_ErrVld , it should be 0
        read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUUESR.ErrVld, read_data);
        compareValues("DCEUUESR_ErrVld", "reset", read_data, 0);
        // Monitor IRQ_C pin , it should be 0 now
        if(u_csr_probe_vif.IRQ_UC == 0)begin
          `uvm_info("RUN_MAIN",$sformatf("IRQ_UC interrupted de-asseretd"), UVM_MEDIUM)
        end else begin
          `uvm_error("RUN_MAIN",$sformatf("IRQ_UC interruped still aseerted"));
        end
         if(!$test$plusargs("back_to_back_error"))
         break;
      end
        // Set the DCEUUECR_ErrDetEn = 0, to disable the error detection
        write_data = 0;
        write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUUEDR.MemErrDetEn, write_data);
        write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUUEIR.MemErrIntEn, write_data);

      end else begin
        ev.trigger();
      end
<% } else { %>
        ev.trigger();
<% } %>
    endtask
endclass : dce_csr_diruueir_MemErrInt_seq

class res_corr_err_threshold_seq extends ral_csr_base_seq; 
   `uvm_object_utils(res_corr_err_threshold_seq)

    uvm_reg_data_t write_data, read_data;
    uvm_status_e   status;

    function new(string name="");
        super.new(name);
    endfunction

    task body();
      <% if(obj.useResiliency) { %>
      if(!$value$plusargs("res_corr_err_threshold=%0d", write_data)) begin
        write_data = $urandom_range(5,50);
      end
      `uvm_info(get_name(), $sformatf("Writing DCEUCRTR0 res_corr_err_threshold = %0d", write_data), UVM_NONE)
      write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DCEUCRTR0.ResThreshold, write_data);
      <% } %>
    endtask
endclass : res_corr_err_threshold_seq


//----------------------------------------------------------------------
/**
* Abstract:
* 
* This is a skidbuffer test.
* In this test we will check if insert double bit sram errors in skidbuf mem is detected by interrupt and errordet is enabled. 
* Test will get arguments of this sequence name from command line and 
* call the body of this sequence.
* Inject double bit SRAM error for all transfer 
* 1. Program Error detection for uncorrectable double bit error in SRAM
* 2. Program Error interrupt with 1. 
* 3. Poll until error information logged and interrupt is asserted.
* 4. Compare error type, error info with appropriate type mentioned in table.
* 5. Program Error interrupt with 0 (disable). 
* 6. Clear ErrVld bit with writing 1.
* 7. Poll interrupt signal which should not asserted.
*/
//-----------------------------------------------------------------------
//-----------------------------------------------------------------------

class dce_csr_dceueir_MemErrInt_skidbuf_seq extends dce_ral_csr_base_seq; 
  `uvm_object_utils(dce_csr_dceueir_MemErrInt_skidbuf_seq)

    uvm_reg_data_t poll_data, read_data, read_data2, write_data;
    bit [7:0]  errthd;
    int        errcount_vld, errthd_vld;
    int        errcount_ovf;
    bit [3:0]  errtype;
    bit [3:0]  errinfo;
    uvm_event kill_test_1;
    uvm_reg my_register;
    uvm_reg_data_t mirrored_value;
    bit irq_uc_asserted = 0;
    bit fault_mission_fault_asserted = 0;
    bit error_det;
    bit error_int;
    bit [3:0] sram_enabled;

    function new(string name="");
        super.new(name);
    endfunction

    task body();


    <% if(obj.DceInfo[obj.Id].CMDOverflowBufInSRAM == true) { %>

       
       getCsrProbeIf();
       get_scb_handle();
       kill_test_1 = new("kill_test_1");
       uvm_config_db#(uvm_event)::set(null, "", "kill_test_1", kill_test_1); 
       dce_sb.kill_test_1 = kill_test_1;   

       if ($test$plusargs("has_ucerr")) begin 

         errtype = 4'h0; //sram err type
         //Set the DCEUUEDR_MemErrDetEn = 1  
         write_data = 1;
         write_csr(m_regs.<%=obj.DceInfo[obj.Id].strRtlNamePrefix%>.DCEUUEDR.MemErrDetEn, write_data); 
         error_det = write_data;
         errinfo = 4'h5;
    
         if($test$plusargs("interrupt_en")) begin   

           `uvm_info("SKIDBUFERROR","In int 1",UVM_HIGH)
           // Set the DCEUUEIR_MemErrIntEn = 1
           write_data = 1;
           write_csr(m_regs.<%=obj.DceInfo[obj.Id].strRtlNamePrefix%>.DCEUUEIR.MemErrIntEn, write_data);
           error_int = write_data;
        
           fork
             begin
               if (u_csr_probe_vif.IRQ_UC == 0) begin

                 `uvm_info("SKIDBUFERROR","Waiting for interrupt to be asserted",UVM_HIGH)
                 if($test$plusargs("skid_mission_fault")) begin <% if (obj.DceInfo[obj.Id].useResiliency ) { %> @(u_csr_probe_vif.fault_mission_fault); <% } %> //#Check.DCE.Concerto.v3.7.MissionFault
                    `uvm_info("SKIDBUFERROR","Resiliency is ON",UVM_HIGH)
                 end else @(u_csr_probe_vif.IRQ_UC);
                
                 if($test$plusargs("skid_mission_fault")) fault_mission_fault_asserted =1;
                 else irq_uc_asserted =1;

                 `uvm_info("SKIDBUFERROR",$sformatf("Interrupt has been asserted and fault_mission_fault_asserted is %0b ",fault_mission_fault_asserted),UVM_HIGH)
               end
             end
             
             begin
               #200000ns;
               if ($test$plusargs("interrupt_en") && !$test$plusargs("skid_mission_fault") && !irq_uc_asserted) begin
                  `uvm_error("RUN_MAIN", "Timeout! Did not see IRQ_UC asserted");
               end
              <% if (obj.DceInfo[obj.Id].useResiliency ) { %>
               if ($test$plusargs("skid_mission_fault") && !fault_mission_fault_asserted) begin
                 `uvm_error("RUN_MAIN", "Timeout! Did not see mission fault asserted");
               end
             <% } %>
             end
           join_any
           disable fork;

         end

         if($test$plusargs("detection_en")) begin
           
          `uvm_info("SKIDBUFERROR","In det 1",UVM_HIGH)
    
          //keep on  Reading the DCEUUESR_ErrVld bit = 1
          poll_csr(m_regs.<%=obj.DceInfo[obj.Id].strRtlNamePrefix%>.DCEUUESR.ErrVld,1,poll_data); //#Check.DCE.Concerto.v3.7.UncorrectableError
          `uvm_info("SKIDBUFERROR","In check 1",UVM_HIGH)
              
          //Read and compare DCEUUESR.ErrInfo value
          read_csr(m_regs.<%=obj.DceInfo[obj.Id].strRtlNamePrefix%>.DCEUUESR.ErrInfo, read_data);
          sram_enabled = read_data;
          compareValues("DCEUUESR_ErrInfo","Valid Type", read_data, errinfo);
          `uvm_info("SKIDBUFERROR","In check 2",UVM_HIGH)
             
          //Read and compare DCEUUESR.ErrType value
          read_csr(m_regs.<%=obj.DceInfo[obj.Id].strRtlNamePrefix%>.DCEUUESR.ErrType, read_data);
          compareValues("DCEUUESR_ErrType","Valid Type", read_data, errtype);

          write_data = 0; 
          write_csr(m_regs.<%=obj.DceInfo[obj.Id].strRtlNamePrefix%>.DCEUUEDR.MemErrDetEn, write_data);
        
          // write DCEUUESR_ErrVld = 1 to clear it
          write_data = 1;
          write_csr(m_regs.<%=obj.DceInfo[obj.Id].strRtlNamePrefix%>.DCEUUESR.ErrVld, write_data);
            
          //Read DCEUUESR_ErrVld , it should be 0
          read_csr(m_regs.<%=obj.DceInfo[obj.Id].strRtlNamePrefix%>.DCEUUESR.ErrVld, read_data);
          compareValues("DCEUUESR_ErrVld", "reset", read_data, 0); 
            
          //Read DCEUUESAR_ErrVld , it should be 0
          read_csr(m_regs.<%=obj.DceInfo[obj.Id].strRtlNamePrefix%>.DCEUUESAR.ErrVld, read_data);
          compareValues("DCEUUESAR_ErrVld", "reset", read_data, 0);
            
         end
             
         if($test$plusargs("interrupt_en")) begin
              
           `uvm_info("SKIDBUFERROR","In int 2",UVM_HIGH);

           write_data = 0;
           write_csr(m_regs.<%=obj.DceInfo[obj.Id].strRtlNamePrefix%>.DCEUUEIR.MemErrIntEn, write_data);

           //Monitor IRQ_C pin , it should be 0 now
           assert (u_csr_probe_vif.IRQ_UC == 0) else begin
             `uvm_error("RUN_MAIN",$sformatf("IRQ_UC interruped still aseerted"));
            end 
         end
 
        
         <% if (obj.DceInfo[obj.Id].CMDOverflowBufInSRAM == true) { %> //collecting coverage
               dce_sb.m_cov.collect_skidbuff_err_csr(0, error_det, error_int, sram_enabled);                          
         <% } %>

         `uvm_info("SKIDBUFERROR","Going to trigger kill_test_1 from ral",UVM_HIGH);

         kill_test_1.trigger(); //trigger to kill test after uncorr err checks
          

       end else begin

          // Monitor IRQ_UC pin , it should be 0 now
          if(u_csr_probe_vif.IRQ_UC == 0)begin
            `uvm_info("RUN_MAIN",$sformatf("IRQ_UC interrupted de-asserted"), UVM_MEDIUM)
          end else begin
            `uvm_error("RUN_MAIN",$sformatf("IRQ_UC interruped asserted"));
          end
          // Read DCEUUESR_ErrVld , it should be 0
            read_csr(m_regs.<%=obj.DceInfo[obj.Id].strRtlNamePrefix%>.DCEUUESR.ErrVld, read_data);
            compareValues("DCEUUESR_ErrVld", "set", read_data, 0);
            read_csr(m_regs.<%=obj.DceInfo[obj.Id].strRtlNamePrefix%>.DCEUUESAR.ErrVld, read_data);
            compareValues("DCEUUESAR_ErrVld", "set", read_data, 0);
            read_csr(m_regs.<%=obj.DceInfo[obj.Id].strRtlNamePrefix%>.DCEUUESR.ErrType, read_data);
            compareValues("DCEUUESR_ErrType","Valid Type", read_data, 4'h0);
          // Read DCEUUESAR_ErrVld , it should be 0
            read_csr(m_regs.<%=obj.DceInfo[obj.Id].strRtlNamePrefix%>.DCEUUESAR.ErrVld, read_data);
            compareValues("DCEUUESAR_ErrVld", "set", read_data, 0);
            read_csr(m_regs.<%=obj.DceInfo[obj.Id].strRtlNamePrefix%>.DCEUUESAR.ErrType, read_data);
            compareValues("DCEUUESAR_ErrType","Valid Type", read_data, 4'h0);
          // Monitor IRQ_C pin , it should be 0 now
          if(u_csr_probe_vif.IRQ_UC == 0)begin
             `uvm_info("RUN_MAIN",$sformatf("IRQ_UC interrupted de-asseretd"), UVM_MEDIUM)
          end else begin
             `uvm_error("RUN_MAIN",$sformatf("IRQ_UC interruped still aseerted"));
          end

       end
    <% } %>

    endtask
endclass : dce_csr_dceueir_MemErrInt_skidbuf_seq


//-----------------------------------------------------------------------
//-----------------------------------------------------------------------
/**
* Abstract:
* 
* This is a skidbuffer test.
* In this test we will check if correctable errors are corrected (ErrThreshold filed CECR register) which should be count by Error counter. 
* Errthreshold value is programmed from dce_test.
* Test will get arguments of this sequence name from command line and 
* call the body of this sequence.
* 1. If dce contains SECDED, Write Error threshold with random value (DUT must assert Interrupt once threshold value errors are corrected).
* 2. Enable Error detection from correctable CSR.
* 3. Enable Error Interrupt from CSR. If enabled then correctable iterrupt signal is asserted.
* 4. Enable SRAM single-bit error from command line with 100% (all writes/read in SRAM)
* 5. Poll ErrVld from Status register until it is set i.e. Correctable Errors are logged.
* 7. Compare ErrCount value and should be non-zero, along with checking for ErrType, ErrInfo.
* 8. Disable Error Detection and Error Interrupt filed by writing 0.
* 9. Clear ErrVld by writting 1 (W1C access types of this field) in status register
* 10. Check if ErrCount should be cleared.
* 11. Repeat step 1 to 10.
*/
//-----------------------------------------------------------------------
//-----------------------------------------------------------------------
//

class dce_csr_dcececr_errThd_skidbuf_seq extends dce_ral_csr_base_seq; 
  `uvm_object_utils(dce_csr_dcececr_errThd_skidbuf_seq)

    uvm_reg_data_t poll_data, read_data, read_data2, write_data;
    bit [7:0]  errthd;
    int        errcount_vld, errthd_vld;
    int        errcount_ovf;
    bit [3:0]  errtype;
    bit [3:0]  errinfo;
    bit error_det;
    bit error_int;
    bit [3:0] sram_enabled;

    function new(string name="");
        super.new(name);
    endfunction

    task body();

       <% if (obj.DceInfo[obj.Id].CMDOverflowBufInSRAM == true) { %>
          
          getCsrProbeIf();
          get_scb_handle();
          errtype = 4'h0;
          error_det = 0; //defaulted to be 0 at the start
          error_int = 0; //defaulted to be 0 at the start

          // Set the DCEUCECR_ErrThreshold 
          if(!uvm_config_db#(bit [7:0])::get(get_sequencer(),"","errthd",errthd)) begin
            `uvm_error("SKIDBUFERROR","Failed to get errthd from config db");
          end
            `uvm_info("SKIDBUFERROR", $sformatf("errthd value in seq is: %0d", errthd), UVM_HIGH);

          //Write the DCEUCECR.ErrThreshold value
          
          write_data = errthd;
          write_csr(m_regs.<%=obj.DceInfo[obj.Id].strRtlNamePrefix%>.DCEUCECR.ErrThreshold, write_data);
          
          //Enable DCEUCECR.ErrDetEn bit
          write_csr(m_regs.<%=obj.DceInfo[obj.Id].strRtlNamePrefix%>.DCEUCECR.ErrDetEn, 1);
          error_det = 1;
          

          if($test$plusargs("interrupt_en"))begin

            `uvm_info("SKIDBUFERROR","Interrupt_en 1 of corr",UVM_HIGH);

            // Set the DCEUCECR_ErrIntEn = 1
            write_csr(m_regs.<%=obj.DceInfo[obj.Id].strRtlNamePrefix%>.DCEUCECR.ErrIntEn, 1);
            error_int = 1;

            fork
              begin
                if (u_csr_probe_vif.IRQ_C == 0) begin
                  `uvm_info("SKIDBUFERROR","Waiting for interrupt to be asserted for corr errors",UVM_HIGH);
                  @(u_csr_probe_vif.IRQ_C);
                  `uvm_info("SKIDBUFERROR","Interrupt is asserted for corr errors",UVM_HIGH);
                end
              end
              begin
                #200000ns;
                `uvm_error("RUN_MAIN",$sformatf("Timeout! Did not see IRQ_C asserted"));
              end
            join_any
            disable fork;

          end

          if($test$plusargs("detection_en")) begin

            `uvm_info("SKIDBUFERROR","In detection_en 1 of corr",UVM_HIGH);

            //Keep on reading the DCEUCESR_ErrVld bit = 1 
            poll_csr(m_regs.<%=obj.DceInfo[obj.Id].strRtlNamePrefix%>.DCEUCESR.ErrVld,1,poll_data); //#Check.DCE.Concerto.v3.7.CorrectableError

            //Keep on reading the DCEUCESR_ErrCountOverflow = 1 and then compare
            poll_data = 0;
            poll_csr(m_regs.<%=obj.DceInfo[obj.Id].strRtlNamePrefix%>.DCEUCESR.ErrCountOverflow,1,poll_data);
            read_csr(m_regs.<%=obj.DceInfo[obj.Id].strRtlNamePrefix%>.DCEUCESR.ErrCountOverflow, read_data);
            compareValues("DCEUCESR_ErrCountOverflow","Should be 1", read_data, 1);


            poll_data = 0;
            // Read DCEUCESR_ErrCount , it should be at errthd. If not then poll for it.
            read_csr(m_regs.<%=obj.DceInfo[obj.Id].strRtlNamePrefix%>.DCEUCESR.ErrCount, read_data);
            `uvm_info("SKIDBUFERROR",$sformatf("Read_data of Errcount after reading initially is %0d",read_data),UVM_HIGH);

            if(read_data != errthd) begin
              //Keep on reading the DCEUCESR_ErrCount value until it matches errthd.
              poll_csr(m_regs.<%=obj.DceInfo[obj.Id].strRtlNamePrefix%>.DCEUCESR.ErrCount,1,poll_data);
              if(poll_data < errthd) begin
                `uvm_error("RUN_MAIN",$sformatf("ErrCount %0d should be same as ErrThreshold %0d",poll_data,errthd))
              end
            end         
            
            `uvm_info("SKIDBUFERROR","In detection_en 1 of corr and now resetting values and checking",UVM_HIGH);
            write_data = 0;
            write_csr(m_regs.<%=obj.DceInfo[obj.Id].strRtlNamePrefix%>.DCEUCECR.ErrDetEn, write_data);
            //Write DCEUCESR_ErrVld = 1 , to reset it
            write_data = 1;
            write_csr(m_regs.<%=obj.DceInfo[obj.Id].strRtlNamePrefix%>.DCEUCESR.ErrVld, write_data);
            //Read DCEUCESR_ErrVld , it should be 0
            read_csr(m_regs.<%=obj.DceInfo[obj.Id].strRtlNamePrefix%>.DCEUCESR.ErrVld, read_data);
            compareValues("DCEUCESR_ErrVld", "now clear", read_data, 0);
            //Read DCEUCESAR_ErrVld , it should be 0
            read_csr(m_regs.<%=obj.DceInfo[obj.Id].strRtlNamePrefix%>.DCEUCESAR.ErrVld, read_data);
            compareValues("DCEUCESAR_ErrVld", "now clear", read_data, 0);
            //Read DCEUCESR_ErrCount , it should be 0
            read_csr(m_regs.<%=obj.DceInfo[obj.Id].strRtlNamePrefix%>.DCEUCESR.ErrCount, read_data);
            compareValues("DCEUCESR_ErrCount", "now clear", read_data, 0);
            //Read DCEUCESAR_ErrCount , it should be 0
            read_csr(m_regs.<%=obj.DceInfo[obj.Id].strRtlNamePrefix%>.DCEUCESAR.ErrCount, read_data);
            compareValues("DCEUCESAR_ErrCount", "now clear", read_data, 0);
            //Read DCEUCESR_ErrCountOverflow , it should be 0
            read_csr(m_regs.<%=obj.DceInfo[obj.Id].strRtlNamePrefix%>.DCEUCESR.ErrCountOverflow, read_data);
            compareValues("DCEUCESR_ErrCountOverflow","Should be 0", read_data, 0);
            //Read DCEUCESAR_ErrCountOverflow , it should be 0
            read_csr(m_regs.<%=obj.DceInfo[obj.Id].strRtlNamePrefix%>.DCEUCESAR.ErrCountOverflow, read_data);
            compareValues("DCEUCESAR_ErrCountOverflow","Should be 0", read_data, 0);
          end


           errinfo = 4'h5; //sram info
          `uvm_info("SKIDBUFERROR", $sformatf("In RAL_SEQ and errinfo value is: %0d", errinfo), UVM_HIGH);
         
          //Read and compare DCEUCESR.ErrType
          read_csr(m_regs.<%=obj.DceInfo[obj.Id].strRtlNamePrefix%>.DCEUCESR.ErrType, read_data);
          compareValues("DCEUCESR_ErrType","Valid Type", read_data, errtype);

          //Read and compare DCEUCESR.ErrInfo
          read_csr(m_regs.<%=obj.DceInfo[obj.Id].strRtlNamePrefix%>.DCEUCESR.ErrInfo, read_data); 
          sram_enabled = read_data;
          compareValues("DCEUCESR_ErrInfo","Valid Type", read_data, errinfo);
          
             


          if($test$plusargs("interrupt_en"))begin
            
            //Reset interrupt by writing 1 to DCEUCECR.ErrIntEn
            write_csr(m_regs.<%=obj.DceInfo[obj.Id].strRtlNamePrefix%>.DCEUCECR.ErrIntEn, 1); 

            `uvm_info("SKIDBUFERROR","In interrupt_en 2 of corr and restting interrupt values",UVM_HIGH);
            // Monitor IRQ_C pin , it should be 0 now
            if(u_csr_probe_vif.IRQ_C == 0)begin
              `uvm_info("SKIDBUFERROR",$sformatf("IRQ_C interrupted de-asseretd for corr errors"), UVM_HIGH)
            end else begin
              `uvm_error("RUN_MAIN",$sformatf("IRQ_C interruped still aseerted"));
            end
          end


        <% if (obj.DceInfo[obj.Id].CMDOverflowBufInSRAM == true) { %> //collecting coverage
          dce_sb.m_cov.collect_skidbuff_err_csr(1, error_det, error_int, sram_enabled);
         <% } %>
      <% } %>

    endtask
endclass : dce_csr_dcececr_errThd_skidbuf_seq


//-----------------------------------------------------------------------
//-----------------------------------------------------------------------
/**
* Abstract:
* 
* This is a skidbuffer test.
* In this test we will check if correctable errors are injected and logging is disabled (ErrDetEn set to 0) ErrVld and ErrCount should be 0. 
* Test will get arguments of this sequence name from command line and 
* call the body of this sequence.
* 1. Enable SRAM single-bit error from command line with 100% (all writes/read in SRAM)
* 2. Compare ErrVld value and should be zero 
* 3. Compare ErrCount value and should be zero 
*/
//-----------------------------------------------------------------------
//-----------------------------------------------------------------------
//

class dce_csr_dcececr_noDetEn_skidbuf_seq extends dce_ral_csr_base_seq; 
  `uvm_object_utils(dce_csr_dcececr_noDetEn_skidbuf_seq)

    uvm_reg_data_t poll_data, read_data, read_data2, write_data;
    bit [7:0]  errthd;
    int        errcount_vld, errthd_vld;
    int        errcount_ovf;
    bit error_det;
    bit error_int;
    bit [3:0] sram_enabled;

    function new(string name="");
        super.new(name);
    endfunction

    task body();
          
   <% if (obj.DceInfo[obj.Id].CMDOverflowBufInSRAM == true) { %>

      get_scb_handle();

      //Don't Set the DCEUCECR_ErrDetEn = 1
      //Reading and comparing the the DCEUCESR_ErrVld bit to be 0
      read_csr(m_regs.<%=obj.DceInfo[obj.Id].strRtlNamePrefix%>.DCEUCESR.ErrVld, read_data);
      compareValues("DCEUCESR_ErrVld", "not set", read_data, 0);

      //Read DCEUCESR_ErrCount , it should be at 0
      read_csr(m_regs.<%=obj.DceInfo[obj.Id].strRtlNamePrefix%>.DCEUCESR.ErrCount, read_data);
      compareValues("DCEUCESR_ErrCount","not set", read_data, 0);

      //Read DCEUCESAR_ErrVld , it should also clear, beacuse it is alias register
      read_csr(m_regs.<%=obj.DceInfo[obj.Id].strRtlNamePrefix%>.DCEUCESAR.ErrVld, read_data);
      compareValues("DCEUCESAR_ErrVld", "not set", read_data, 0);

      read_csr(m_regs.<%=obj.DceInfo[obj.Id].strRtlNamePrefix%>.DCEUCECR.ErrDetEn, read_data);
      error_det = read_data; //for coverage
      read_csr(m_regs.<%=obj.DceInfo[obj.Id].strRtlNamePrefix%>.DCEUCECR.ErrIntEn, read_data);
      error_int = read_data; //for coverage
        
      <% if (obj.DceInfo[obj.Id].CMDOverflowBufInSRAM == true) { %> //collecting coverage
      sram_enabled = 4'h5;
      dce_sb.m_cov.collect_skidbuff_err_csr(1, error_det, error_int, sram_enabled);
      <% } %>

   <% } %>

    endtask
endclass : dce_csr_dcececr_noDetEn_skidbuf_seq

//class cust_svt_ocp_master_transaction extends svt_ocp_master_transaction;
//
//  /** Following are the weights to constrain command types */
//    
//  /** 50% of the commands are of WR type */
//  int  m_en_mcmd_WR_wt = 50;
//  /** 50% of the commands are of RD type */
//  int  m_en_mcmd_RD_wt = 50;
// 
//  /**
//   * Creates distribution of generated transaction types, according to the
//   * weighting control values (which are also adjusted for the configuration).
//   */
//  constraint cust_command_type_constraint {
//    m_en_mcmd dist {
//                    svt_ocp_dataflow_transaction::WRNP    := m_en_mcmd_WR_wt,
//                    svt_ocp_dataflow_transaction::RD    := m_en_mcmd_RD_wt
//                    };
//  }
//
//  `uvm_object_utils(cust_svt_ocp_master_transaction)
//
//  function new (string name = "cust_svt_ocp_master_transaction");
//    super.new(name);
//  endfunction : new
//
//endclass : cust_svt_ocp_master_transaction
//
//class cust_svt_ocp_master_transaction_posted extends svt_ocp_master_transaction;
//
//  /** Following are the weights to constrain command types */
//    
//  /** 50% of the commands are of WR type */
//  int  m_en_mcmd_WR_wt = 50;
//  /** 50% of the commands are of RD type */
//  int  m_en_mcmd_RD_wt = 50;
// 
//  /**
//   * Creates distribution of generated transaction types, according to the
//   * weighting control values (which are also adjusted for the configuration).
//   */
//  constraint cust_command_type_constraint {
//    m_en_mcmd dist {
//                    svt_ocp_dataflow_transaction::WR    := m_en_mcmd_WR_wt,
//                    svt_ocp_dataflow_transaction::RD    := m_en_mcmd_RD_wt
//                    };
//  }
//
//  `uvm_object_utils(cust_svt_ocp_master_transaction_posted)
//
//  function new (string name = "cust_svt_ocp_master_transaction_posted");
//    super.new(name);
//  endfunction : new
//
//endclass : cust_svt_ocp_master_transaction_posted
//
//class csr_rmw_check_seq extends svt_ocp_master_transaction_base_sequence ;
// 
//  rand bit [31:0]  wr_data;
//  rand bit [31:0]  rd_data;
//  rand bit [31:0]  maskdata;
//  rand bit [31:0]  addr;
//  svt_ocp_master_transaction req;
//
//  `uvm_object_utils_begin(csr_rmw_check_seq)
//    `uvm_field_int    (wr_data,UVM_ALL_ON)
//    `uvm_field_int    (rd_data,UVM_ALL_ON)
//    `uvm_field_int    (maskdata,UVM_ALL_ON)
//    `uvm_field_int    (addr,UVM_ALL_ON)
//  `uvm_object_utils_end 
//
//
//  function new (string name = "csr_rmw_check_seq");
//    super.new(name);
//  endfunction : new
//
//  
//   task pre_body();
//     begin
//       if(starting_phase != null)
//         starting_phase.raise_objection(this);
//     end
//   endtask : pre_body
//   
//   // post_body - drop objection here
//   task post_body();
//     begin
//       if(starting_phase != null)
//         starting_phase.drop_objection(this);
//     end
//   endtask : post_body
//
//   task body();
//    `uvm_info("BODY",$sformatf("reg_addr = %x,wr_data = %x,maskdata = %x",addr,wr_data,maskdata), UVM_MEDIUM);
//    //---------------------------------------------------------------
//    // Reading register for read modified write 
//    //---------------------------------------------------------------
//      `uvm_do_with(req, 
//      { 
//        req.m_en_mcmd == svt_ocp_master_transaction::RD;
//        req.m_bvv_maddr[0] == addr;
//        req.m_n_mburstlength == 1;        
//      })
//      req.end_event.wait_trigger();
//      rd_data = req.m_bvv_data[0];
//    //---------------------------------------------------------------
//    // writing on register  
//    //---------------------------------------------------------------
//     rd_data = (rd_data & ~maskdata); 
//    `uvm_info("BODY",$sformatf("reg_addr = %x,wr_data = %x",addr,rd_data), UVM_MEDIUM);
//     wr_data = (wr_data | rd_data); 
//
//    `uvm_info("BODY",$sformatf("reg_addr = %x,wr_data = %x",addr,wr_data), UVM_MEDIUM);
//      `uvm_do_with(req, 
//      { 
//        req.m_en_mcmd == svt_ocp_master_transaction::WRNP;
//        req.m_bvv_maddr[0] == addr;
//        req.m_bvv_data[0] == wr_data;
//        req.m_n_mburstlength == 1;        
//      })
//      
//      req.end_event.wait_trigger();
//
//    //---------------------------------------------------------------
//    //  Do a READ to the address just written, Read data should be same
//    //  as wr_data
//    //---------------------------------------------------------------
//      `uvm_do_with(req, 
//      { 
//        req.m_en_mcmd == svt_ocp_master_transaction::RD;
//        req.m_bvv_maddr[0] == addr;
//        req.m_n_mburstlength == 1;        
//      })
//      req.end_event.wait_trigger();
//      rd_data = req.m_bvv_data[0];
//
//       if(wr_data == rd_data ) begin
//        uvm_report_info("BODY",$sformatf("Expected data: %x  Rd data : %x",wr_data,req.m_bvv_data[0]), UVM_MEDIUM);
//       end
//       else begin 
//        uvm_report_error("BODY",$sformatf("Expected data: %x  Rd data : %x",wr_data,req.m_bvv_data[0]), UVM_LOW);
//       end 
//
//
//   endtask:body 
//
//
//endclass : csr_rmw_check_seq
//
//class csr_wr_seq extends svt_ocp_master_transaction_base_sequence ;
// 
//  rand bit [31:0]  wr_data;
//  rand bit [31:0]  rd_data;
//  rand bit [31:0]  maskdata;
//  rand bit [31:0]  addr;
//  svt_ocp_master_transaction req;
//
//  `uvm_object_utils_begin(csr_wr_seq)
//    `uvm_field_int    (wr_data,UVM_ALL_ON)
//    `uvm_field_int    (rd_data,UVM_ALL_ON)
//    `uvm_field_int    (maskdata,UVM_ALL_ON)
//    `uvm_field_int    (addr,UVM_ALL_ON)
//  `uvm_object_utils_end 
//
//
//  function new (string name = "csr_wr_seq");
//    super.new(name);
//  endfunction : new
//
//  
//   task pre_body();
//     begin
//       if(starting_phase != null)
//         starting_phase.raise_objection(this);
//     end
//   endtask : pre_body
//   
//   // post_body - drop objection here
//   task post_body();
//     begin
//       if(starting_phase != null)
//         starting_phase.drop_objection(this);
//     end
//   endtask : post_body
//
//   task body();
//    //---------------------------------------------------------------
//    // writing on register  
//    //---------------------------------------------------------------
//    `uvm_info("BODY",$sformatf("reg_addr = %x,wr_data = %x",addr,wr_data), UVM_MEDIUM);
//      `uvm_do_with(req, 
//      { 
//        req.m_en_mcmd == svt_ocp_master_transaction::WRNP;
//        req.m_bvv_maddr[0] == addr;
//        req.m_bvv_data[0] == wr_data;
//        req.m_n_mburstlength == 1;        
//      })
//      
//      req.end_event.wait_trigger();
//    //---------------------------------------------------------------
//   endtask:body 
//
//endclass : csr_wr_seq
//
//class csr_rd_seq extends svt_ocp_master_transaction_base_sequence ;
// 
//  rand bit [31:0]  rd_data;
//  rand bit [31:0]  addr;
//  svt_ocp_master_transaction req;
//
//  `uvm_object_utils_begin(csr_rd_seq)
//    `uvm_field_int    (rd_data,UVM_ALL_ON)
//    `uvm_field_int    (addr,UVM_ALL_ON)
//  `uvm_object_utils_end 
//
//
//  function new (string name = "csr_rd_seq");
//    super.new(name);
//  endfunction : new
//
//  
//   task pre_body();
//     begin
//       if(starting_phase != null)
//         starting_phase.raise_objection(this);
//     end
//   endtask : pre_body
//   
//   // post_body - drop objection here
//   task post_body();
//     begin
//       if(starting_phase != null)
//         starting_phase.drop_objection(this);
//     end
//   endtask : post_body
//
//   task body();
//    //---------------------------------------------------------------
//    // Reading register for read modified write 
//    //---------------------------------------------------------------
//      `uvm_do_with(req, 
//      { 
//        req.m_en_mcmd == svt_ocp_master_transaction::RD;
//        req.m_bvv_maddr[0] == addr;
//        req.m_n_mburstlength == 1;        
//      })
//      req.end_event.wait_trigger();
//      rd_data = req.m_bvv_data[0];
//
//      uvm_report_info("BODY",$sformatf("reg_addr=  %x,Rd data : %x",addr,req.m_bvv_data[0]), UVM_MEDIUM);
//
//   endtask:body 
//
//
//endclass : csr_rd_seq
`endif //GUARD_DCE_CSR_SEQ_LIB_SV
  
