//-----------------------------------------------------------------------
//-----------------------------------------------------------------------
//  Task    : chi_aiu_csr_id_reset_seq
//  Purpose : test unit ids against json, rather than cpr
//
//-----------------------------------------------------------------------
class chi_aiu_csr_id_reset_seq extends ral_csr_base_seq; 
   `uvm_object_utils(chi_aiu_csr_id_reset_seq)

    uvm_reg_data_t read_data;

    function new(string name="");
        super.new(name);
    endfunction

    task body();
       read_data = 'hDEADBEEF ;  //bogus sentinel

       read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUIDR.RPN, read_data);
       compareValues("CAIUFUIDR_RPN", "should be 0 (json)", read_data,<%=obj.AiuInfo[obj.Id].FUnitId%>);  
       read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUIDR.NRRI, read_data);
       compareValues("CAIUIDR_NRRI", "should be 0 (json)", read_data, 0);  //TODO FIXME meaningful values from json
       read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUIDR.NUnitId, read_data);
       //compareValues("CAIUIDR_NUnitId", "should be 0 (json)", read_data, <%/*=obj.DmiInfo[obj.Id].FUnitId*/%>);
       compareValues("CAIUIDR_NUnitId", "should be <%=obj.AiuInfo[obj.Id].nUnitId%> (json)", read_data, <%=obj.AiuInfo[obj.Id].nUnitId%>);
       read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUIDR.Valid, read_data);
       compareValues("CAIUIDR_Valid", "should always be 1", read_data, 1);  
       read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUFUIDR.FUnitId, read_data);
       compareValues("CAIUIDR_FUnitId", "should be <%=obj.AiuInfo[obj.Id].FUnitId%> (json)", read_data, <%=obj.AiuInfo[obj.Id].FUnitId%>);
    endtask
endclass : chi_aiu_csr_id_reset_seq

//-----------------------------------------------------------------------
//   base method for chi_aiu 
//-----------------------------------------------------------------------
class chi_aiu_ral_csr_base_seq extends ral_csr_base_seq;

    virtual chi_aiu_csr_probe_if u_csr_probe_vif;
    virtual chi_aiu_dut_probe_if u_dut_probe_vif;
    virtual <%=obj.BlockId%>_apb_if  apb_vif;
    int timeout_uc_err;
    uvm_event_pool ev_pool = uvm_event_pool::get_global_pool();
    uvm_event ev = ev_pool.get("ev");
    uvm_event ev_snp_rsp_err = ev_pool.get("ev_snp_rsp_err");
    uvm_event ev_csr_test_time_out_CMDrsp_STRreq = ev_pool.get("ev_csr_test_time_out_CMDrsp_STRreq");
    uvm_event ev_csr_test_time_out_SNPrsp = ev_pool.get("ev_csr_test_time_out_SNPrsp");
    uvm_event ev_csr_test_time_out_SYSrsp = ev_pool.get("ev_csr_test_time_out_SYSrsp");
    uvm_event ev_update_crd = ev_pool.get("ev_update_crd");
    uvm_event err_inj_ev = ev_pool.get("err_inj_ev");
    uvm_event all_txn_done_ev = ev_pool.get("all_txn_done_ev");
    <% if (obj.useResiliency) { %>
        uvm_event ev_bist_reset_done = ev_pool.get("bist_reset_done");
    <%}%>
    <% for (var i = 0; i <  obj.nSmiRx; i++) { %>
    virtual <%=obj.BlockId%>_smi_if   m_smi<%=i%>_tx_vif;
    <% } %>
    <% for (var i = 0; i <  obj.nSmiTx; i++) { %>
    virtual <%=obj.BlockId%>_smi_if   m_smi<%=i%>_rx_vif;
    <% } %>
    chi_aiu_scb chi_scb;

    function new(string name="");
        super.new(name);
    endfunction

    function getsb_handle();
      if (!uvm_config_db#(chi_aiu_scb)::get(.cntxt( null ),
                                              .inst_name( "*" ),
                                              .field_name( "chi_aiu_scb" ),
                                              .value( chi_scb ))) begin
         `uvm_error("chi_aiu_ral_csr_base_seq", "chi_scb handle not found")
      end
    endfunction

    function getCsrProbeIf();
        if(!uvm_config_db#(virtual chi_aiu_csr_probe_if )::get(null, get_full_name(), "u_csr_probe_if",u_csr_probe_vif))
            `uvm_error("NOVIF",{"virtual interface must be set  for :",get_full_name(),".vif"})
    endfunction // checkCsrProbeIf

    function getDutProbeIf();
        if(!uvm_config_db#(virtual chi_aiu_dut_probe_if )::get(null, get_full_name(), "u_dut_probe_if",u_dut_probe_vif)) begin
            `uvm_error("NOVIF",{"virtual interface must be set  for :",get_full_name(),".vif"})
    end
    endfunction // getDutProbeIf


    task poll_CAIUUESR_ErrVld(bit [31:0] poll_till, output uvm_reg_data_t fieldVal);
        poll_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUUESR.ErrVld,poll_till,fieldVal,50_000);
    endtask

    task poll_CAIUCESR_ErrVld(bit [31:0] poll_till, output uvm_reg_data_t fieldVal);
        poll_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUCESR.ErrVld,poll_till,fieldVal,20_000);
    endtask

    task poll_CAIUCCR_DCE_negative_state(bit [31:0] poll_till, output uvm_reg_data_t fieldVal);
        poll_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUCCR0.DCECounterState,poll_till,fieldVal);
    endtask

    task poll_CAIUCCR_DMI_negative_state(bit [31:0] poll_till, output uvm_reg_data_t fieldVal);
        poll_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUCCR0.DMICreditLimit,poll_till,fieldVal);
    endtask

    task poll_CAIUCCR_DII_negative_state(bit [31:0] poll_till, output uvm_reg_data_t fieldVal);
        poll_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUCCR0.DIICounterState,poll_till,fieldVal);
    endtask

    function void getSMIIf();
      <% var smi_portid_snprsp =0;
         obj.AiuInfo[obj.Id].smiPortParams.tx.forEach(function find_port_id(item,index){ 
           if(item.params.fnMsgClass.indexOf('snp_rsp_') != -1) {
             smi_portid_snprsp = index;
             console.log("smi_portid_snprsp is = "+ index ) ;
           }
         });  %>
      <% var smi_portid_cmdrsp =0;
         var smi_portid_dtwrsp =0;
         var smi_portid_dtrrsp =0;
         var smi_portid_dtrreq =0;
         var smi_portid_strreq =0;
         var smi_portid_snpreq =0;
         var smi_portid_sysrsp =0;
         var smi_portid_sysreq =0;
         var smi_portid_dtwdbgrsp =0;
         var smi_portid_cmprsp =0;
         obj.AiuInfo[obj.Id].smiPortParams.rx.forEach(function find_port_id(item,index){ 
           if(item.params.fnMsgClass.indexOf('cmd_rsp_') != -1) {
             smi_portid_cmdrsp = index;
             console.log("smi_portid_cmdrsp is = "+ index ) ;
           }
           if(item.params.fnMsgClass.indexOf('dtw_rsp_') != -1) {
             smi_portid_dtwrsp = index;
             console.log("smi_portid_dtwrsp is = "+ index ) ;
           }
           if(item.params.fnMsgClass.indexOf('dtr_rsp_rx_') != -1) {
             smi_portid_dtrrsp = index;
             console.log("smi_portid_dtrrsp is = "+ index ) ;
           }
           if(item.params.fnMsgClass.indexOf('dtr_req_rx_') != -1) {
             smi_portid_dtrreq = index;
             console.log("smi_portid_dtrreq is = "+ index ) ;
           }
           if(item.params.fnMsgClass.indexOf('str_req_') != -1) {
             smi_portid_strreq = index;
             console.log("smi_portid_strreq is = "+ index ) ;
           }
           if(item.params.fnMsgClass.indexOf('snp_req_') != -1) {
             smi_portid_snpreq = index;
             console.log("smi_portid_snpreq is = "+ index ) ;
           }
           if(item.params.fnMsgClass.indexOf('sys_rsp_rx_') != -1) {
             smi_portid_sysrsp = index;
             console.log("smi_portid_sysrsp is = "+ index ) ;
           }
           if(item.params.fnMsgClass.indexOf('sys_req_') != -1) {
             smi_portid_sysreq = index;
             console.log("smi_portid_sysreq is = "+ index ) ;
           }
           if(item.params.fnMsgClass.indexOf('dtw_dbg_rsp_') != -1) {
             smi_portid_dtwdbgrsp = index;
             console.log("smi_portid_dtwdbgrsp is = "+ index ) ;
           }
           if(item.params.fnMsgClass.indexOf('cmp_rsp_') != -1) {
                smi_portid_cmprsp = index;
                console.log("smi_portid_cmprsp is = "+ index ) ;
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
      <% for (var i = 0; i < obj.nSmiTx; i++) { %>
      if (!uvm_config_db #(virtual <%=obj.BlockId%>_smi_if)::get(
        .cntxt(null),
        .inst_name(get_full_name()),
        .field_name("m_smi<%=i%>_rx_vif"),
        .value(m_smi<%=i%>_rx_vif))) begin

        `uvm_fatal(get_name(), "unable to find m_smi<%=i%>_rx_vif")
      end
      <% } %>
    endfunction

    function bit [`UVM_REG_ADDR_WIDTH-1 : 0] get_unmapped_csr_addr();
      bit [`UVM_REG_ADDR_WIDTH-1 : 0] all_csr_addr[$];
      typedef struct packed {
                             bit [`UVM_REG_ADDR_WIDTH-1 : 0] lower_addr;
                             bit [`UVM_REG_ADDR_WIDTH-1 : 0] upper_addr;
                            } csr_addr;
      csr_addr csr_unmapped_addr_range[$];
      int randomly_selected_unmapped_csr_sddr;
      
      <% obj.DutInfo.csr.spaceBlock[0].registers.forEach(function GetAllregAddr(item,i){ %>
                                  //all_csr_addr.push_back({12'h<%=obj.DutInfo.nrri%>,8'h<%=obj.DutInfo.rpn%>,12'h<%=item.addressOffset%>});
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

endclass : chi_aiu_ral_csr_base_seq

class access_unmapped_csr_addr extends chi_aiu_ral_csr_base_seq; //#Stimulus.CHIAIU.decerr.v3.unmappaddr
  `uvm_object_utils(access_unmapped_csr_addr)
  bit [`UVM_REG_ADDR_WIDTH-1 : 0] unmapped_csr_addr;
  apb_pkt_t apb_pkt;
  int no_of_err;

  function new(string name="");
      super.new(name);
  endfunction

  task body();
    get_apb_if();
    no_of_err = $urandom_range(50,100);
    ev.trigger();
  for (int j=0;j<no_of_err;j++) begin
    unmapped_csr_addr = get_unmapped_csr_addr();
    apb_pkt = apb_pkt_t::type_id::create("apb_pkt");
    apb_pkt.paddr = unmapped_csr_addr;
    apb_pkt.pwrite = 1;
    apb_pkt.psel = 1;
    apb_pkt.pwdata = $urandom;
    apb_vif.drive_apb_channel(apb_pkt);
  end
  endtask
endclass : access_unmapped_csr_addr

class chi_aiu_illegal_csr_access extends chi_aiu_ral_csr_base_seq;   // #Check.CHIAIU.v3.Security.SecurityErrorLogging 
  `uvm_object_utils(chi_aiu_illegal_csr_access)

   uvm_reg_data_t poll_data, read_data, read_data2, write_data, read_nsx, read_addr_low, read_addr_high;
   uvm_status_e           status;
   bit [7:0]  errthd;
   int        errcount_vld, errthd_vld;
   int        i,j;
   bit        err_det_en, err_int_en;
   bit [WSMIADDR-1:0] exp_addr;
   bit [WSMIADDR-1:0] erraddr_q[$];
   bit [51:0]actual_addr;
   bit [31:0] err_addr0;
   bit [19:0] err_addr;
   bit [19:0] exp_errinfo;
   bit [19:0] errinfo_q[$];
   bit [19:0] exp_errinfo_tmp;

    function new(string name="");
        super.new(name);
    endfunction

    task body();
        ncoreConfigInfo::sys_addr_csr_t csrq[$];
        getsb_handle();
        getCsrProbeIf();

        csrq = ncoreConfigInfo::get_all_gpra();
        write_data = 1;
        err_det_en = $urandom_range(1,0);
        err_int_en = $urandom_range(1,0);
        write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUUEDR.DecErrDetEn, err_det_en); 
        write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUUEIR.DecErrIntEn, err_int_en);
	    if($test$plusargs("illegal_csr_format_uncrr")) begin
            write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUNRSAR.NRSAR, 1); 
        end 
        ev.trigger();
        if (err_det_en) begin
            poll_CAIUUESR_ErrVld(1, poll_data);

            foreach (chi_scb.csr_addr_decode_err_addr_q[i]) begin
                exp_addr = chi_scb.csr_addr_decode_err_addr_q[i];
                exp_errinfo[19:8] = chi_scb.csr_addr_decode_err_msg_id_q[i];
                exp_errinfo[4] = chi_scb.csr_addr_decode_err_cmd_type_q[i];
	            if($test$plusargs("illegal_csr_format_uncrr")) begin
                    exp_errinfo[3:0] = 4'b0010;
                end else begin
                    exp_errinfo[3:0] = 4'b0000;
                end
                errinfo_q.push_back(exp_errinfo);
                erraddr_q.push_back(exp_addr);
            end

            `uvm_info(get_full_name(),$sformatf("erraddr_q = %0p, errinfo_q = %0p",erraddr_q,errinfo_q),UVM_NONE)
            read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUUESR.ErrInfo, read_data);
            uvm_config_db#(int)::set(null,"*","chi_dec_err_type",read_data); //for coverage
            if (!(read_data inside {errinfo_q})) begin
              `uvm_error(get_full_name(),$sformatf("Expected ErrInfo inside %0p, Actual ErrInfo = %0h",errinfo_q,read_data))
            end
            read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUUESR.ErrType, read_data);
            uvm_config_db#(int)::set(null,"*","chi_errtype_code",read_data); //for coverage
            compareValues("CAIUUESR_ErrType", "", read_data, 7);
            //read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUUELR0.ErrEntry, read_data);
            //err_entry = read_data;
            //read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUUELR0.ErrWay, read_data);
            //err_way = read_data;
            //read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUUELR0.ErrWord, read_data);
            //err_word = read_data;
            read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUUELR0.ErrAddr, read_data);
            err_addr0 = read_data;
            read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUUELR1.ErrAddr, read_data);
            err_addr = read_data;
            actual_addr = {err_addr,err_addr0};
            if (!(actual_addr inside {erraddr_q})) begin
                    `uvm_error(get_full_name(),$sformatf("Expected ErrAdd inside %0p, Actual ErrAddr = %0h",erraddr_q, actual_addr))
            end
            if(err_int_en) begin
                fork
                    begin
                        wait (u_csr_probe_vif.IRQ_UC === 1);
                        uvm_config_db#(int)::set(null,"*","chi_irq_uc",u_csr_probe_vif.IRQ_UC); //for coverage
                    end
                    begin
                        #200000ns;
                        `uvm_error(get_name(),$sformatf("Timeout! Did not see IRQ_UC asserted"));
                    end
                join_any
                disable fork;
            end else begin
                fork
                    begin
                        wait (u_csr_probe_vif.IRQ_UC === 1);
                        `uvm_error(get_name(),$sformatf("IRQ_UC interrupt asserted when interrupt is disabled"));
                    end
                    begin
                        #2000ns;
                    end
                join_any
                disable fork;
            end
        end

	       all_txn_done_ev.wait_ptrigger();

        if (!err_det_en) begin
            read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUUESR.ErrVld, read_data);
            compareValues("CAIUUESR_ErrVld", "Error Valid should not assert when error detect is disabled", read_data, 0);
        end
    
        write_data = 0;
        write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUUEDR.DecErrDetEn, write_data); 
        write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUUEIR.DecErrIntEn, write_data);
        write_data = 1;
        write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUUESR.ErrVld, write_data);
        // Read the CAIUUESR_ErrVld should be cleared
        read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUUESR.ErrVld, read_data);
        compareValues("CAIUUESR_ErrVld", "now clear", read_data, 0);


    endtask
endclass : chi_aiu_illegal_csr_access




class chi_aiu_csr_secure_access extends chi_aiu_ral_csr_base_seq;   // #Check.CHIAIU.v3.Security.SecurityErrorLogging 
  `uvm_object_utils(chi_aiu_csr_secure_access)

   uvm_reg_data_t poll_data, read_data, read_data2, write_data, read_nsx, read_addr_low, read_addr_high;
   uvm_status_e           status;
   bit [7:0]  errthd;
   int        errcount_vld, errthd_vld;
   int        i,j;
   bit        err_det_en, err_int_en;
   bit [WSMIADDR-1:0] exp_addr;
   bit [WSMIADDR-1:0] erraddr_q[$];
   bit [51:0]actual_addr;
   bit [31:0] err_addr0;
   bit [19:0] err_addr;
   bit [19:0] exp_errinfo;
   bit [19:0] errinfo_q[$];
   bit [19:0] exp_errinfo_tmp;

    function new(string name="");
        super.new(name);
    endfunction

    task body();
        ncoreConfigInfo::sys_addr_csr_t csrq[$];
        getsb_handle();
        getCsrProbeIf();

        csrq = ncoreConfigInfo::get_all_gpra();
        write_data = 1;
        err_det_en = $urandom_range(1,0);
        err_int_en = $urandom_range(1,0);
        write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUUEDR.DecErrDetEn, err_det_en); 
        write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUUEIR.DecErrIntEn, err_int_en);

        <% for(var i = 0; i < obj.DutInfo.nGPRA; i++) { %>
                write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUGPRAR<%=i%>.NSX, csrq[<%=i%>].nsx);
        <% } %>


        ev.trigger();
        if (err_det_en) begin
            poll_CAIUUESR_ErrVld(1, poll_data);

            foreach (chi_scb.csr_addr_decode_err_addr_q[i]) begin
              exp_addr = chi_scb.csr_addr_decode_err_addr_q[i];
              exp_errinfo[19:8] = chi_scb.csr_addr_decode_err_msg_id_q[i];
              exp_errinfo[4] = chi_scb.csr_addr_decode_err_cmd_type_q[i];
              exp_errinfo[3:0] = 4'b0100;
              errinfo_q.push_back(exp_errinfo);
              erraddr_q.push_back(exp_addr);
            end

            `uvm_info(get_full_name(),$sformatf("erraddr_q = %0p, errinfo_q = %0p",erraddr_q,errinfo_q),UVM_NONE)
            read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUUESR.ErrInfo, read_data);
            uvm_config_db#(int)::set(null,"*","chi_dec_err_type",read_data); //for coverage
            if (!(read_data inside {errinfo_q})) begin
              `uvm_error(get_full_name(),$sformatf("Expected ErrInfo inside %0p, Actual ErrInfo = %0h",errinfo_q,read_data))
            end
            read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUUESR.ErrType, read_data);
            uvm_config_db#(int)::set(null,"*","chi_errtype_code",read_data); //for coverage
            compareValues("CAIUUESR_ErrType", "", read_data, 7);
            //read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUUELR0.ErrEntry, read_data);
            //err_entry = read_data;
            //read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUUELR0.ErrWay, read_data);
            //err_way = read_data;
            //read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUUELR0.ErrWord, read_data);
            //err_word = read_data;
            read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUUELR0.ErrAddr, read_data);
            err_addr0 = read_data;
            read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUUELR1.ErrAddr, read_data);
            err_addr = read_data;
            actual_addr = {err_addr,err_addr0};
            if (!(actual_addr inside {erraddr_q})) begin
                    `uvm_error(get_full_name(),$sformatf("Expected ErrAdd inside %0p, Actual ErrAddr = %0h",erraddr_q, actual_addr))
            end
            if (err_int_en) begin
                fork
                    begin
                        wait (u_csr_probe_vif.IRQ_UC === 1);
                        uvm_config_db#(int)::set(null,"*","chi_irq_uc",u_csr_probe_vif.IRQ_UC); //for coverage
                    end
                    begin
                      #200000ns;
                      `uvm_error(get_name(),$sformatf("Timeout! Did not see IRQ_UC asserted"));
                    end
                join_any
                disable fork;
            end else begin
                fork
                    begin
                        wait (u_csr_probe_vif.IRQ_UC === 1);
                        `uvm_error(get_name(),$sformatf("IRQ_UC interrupt asserted when interrupt is disabled"));
                    end
                    begin
                      #2000ns;
                    end
                join_any
                disable fork;
            end
        end

	    all_txn_done_ev.wait_ptrigger();

        if (!err_det_en) begin
            read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUUESR.ErrVld, read_data);
            compareValues("CAIUUESR_ErrVld", "Error Valid should not assert when error detect is disabled", read_data, 0);
        end
    
        write_data = 0;
        write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUUEDR.DecErrDetEn, write_data); 
        write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUUEIR.DecErrIntEn, write_data);
        write_data = 1;
        write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUUESR.ErrVld, write_data);
        // Read the CAIUUESR_ErrVld should be cleared
        read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUUESR.ErrVld, read_data);
        compareValues("CAIUUESR_ErrVld", "now clear", read_data, 0);

    endtask
endclass : chi_aiu_csr_secure_access

class chi_aiu_csr_uuecr_sw_write_seq extends chi_aiu_ral_csr_base_seq; 
  `uvm_object_utils(chi_aiu_csr_uuecr_sw_write_seq)

   uvm_reg_data_t poll_data, read_data, read_data2, write_data;
   uvm_status_e           status;
   bit [7:0]  errthd;
   int        errcount_vld, errthd_vld;
   int        i,j;

    function new(string name="");
        super.new(name);
    endfunction

    task body();
        getCsrProbeIf();

        ev.trigger();

        write_data = 1;
        write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUUEIR.TimeOutErrIntEn, write_data);

        write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUUESAR.ErrType, 9);
        write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUUESAR.ErrInfo, 16'hABCD);
        write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUUESAR.ErrVld, write_data);

        fork
            begin
                wait (u_csr_probe_vif.IRQ_UC === 1);
                uvm_config_db#(int)::set(null,"*","chi_irq_uc",u_csr_probe_vif.IRQ_UC); //for coverage
            end
            begin
              #200000ns;
              `uvm_error(get_name(),$sformatf("Timeout! Did not see IRQ_UC asserted"));
            end
        join_any
        disable fork;

        read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUUESR.ErrVld, read_data);
        compareValues("CAIUUESR_ErrVld", "now set", read_data, 1);
        
        write_data = 0;
        write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUUESAR.ErrVld, write_data);
        // Read the CAIUUESR_ErrVld should be cleared
        read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUUESR.ErrVld, read_data);
        compareValues("CAIUUESR_ErrVld", "now clear", read_data, 0);

        wait (u_csr_probe_vif.IRQ_UC === 0);

    endtask
endclass : chi_aiu_csr_uuecr_sw_write_seq

class chi_aiu_csr_time_out_error_seq extends chi_aiu_ral_csr_base_seq; //#Check.CHIAIU.v3.Error.timeouterr
  `uvm_object_utils(chi_aiu_csr_time_out_error_seq)

    uvm_reg_data_t poll_data, read_data, write_data,timeout_threshold;
    bit [47:0] actual_addr;
    bit [47:0] expt_addr;
    bit [19:0] errinfo;
    bit [31:0] erraddr0;
    bit [19:0] erraddr;
    bit [03:0] errtype = 'h9;
    bit skip_check;
    chi_req_seq_item cmd_req_pkt;
    smi_seq_item  snp_req_pkt;
    int timeout_err_cnt = 0;
    int num_timeout_err = 1;
    bit mission_fault_asserted; 

    function new(string name="");
        super.new(name);
    endfunction

    task body();
      getCsrProbeIf();
      getsb_handle();
      getSMIIf();

      if(!$value$plusargs("k_num_timeout_err=%0d", num_timeout_err)) begin
          num_timeout_err = 1;
      end

          if(!uvm_config_db#(bit)::get(null,"","mission_fault_asserted",mission_fault_asserted))
              begin 
              `uvm_info(get_full_name(),"mission fault is not asserted",UVM_LOW)
              end

      <% if (obj.useResiliency) { %>
           if(mission_fault_asserted)begin
           ev_bist_reset_done.wait_ptrigger();
           end 
      <%}%>

      write_data = 1;
      write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUUEDR.TimeoutErrDetEn, write_data);
      write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUUEIR.TimeOutErrIntEn, write_data);
      if ($test$plusargs("SYSrsp_time_out_test")) begin
        timeout_threshold = 6;
      end else begin
        timeout_threshold = 1;
      end
      if ($test$plusargs("SYSrsp_time_out_test")) begin
      write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUSCPTOCR.TimeOutThreshold, timeout_threshold);
      end else begin
      write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUTOCR.TimeOutThreshold, timeout_threshold);
      end
      ev.trigger();

      while (((timeout_err_cnt < num_timeout_err) && $test$plusargs("STRreq_time_out_test")) || ((timeout_err_cnt == 0) && !$test$plusargs("STRreq_time_out_test"))) begin
      if (($test$plusargs("CMDrsp_time_out_test") || $test$plusargs("STRreq_time_out_test")) && (timeout_err_cnt == 0)) begin
        //#Stimulus.CHIAIU.timeout.v3.cmdrsptimeout
        //#Stimulus.CHIAIU.timeout.v3.strreqtimeout
        ev_csr_test_time_out_CMDrsp_STRreq.wait_ptrigger();
        $cast(cmd_req_pkt,ev_csr_test_time_out_CMDrsp_STRreq.get_trigger_data());

	if      (cmd_req_pkt.opcode inside {DVMOP}) 		errinfo[1:0] = 2'b11; // DVM
	else if (cmd_req_pkt.opcode inside {write_ops}) 	errinfo[1:0] = 2'b01; // Write
	else if (cmd_req_pkt.opcode inside {dataless_ops}) 	errinfo[1:0] = 2'b10; // CMO/Dataless
	else if (cmd_req_pkt.opcode inside {read_ops})  	errinfo[1:0] = 2'b00; // Read
        errinfo[2] = cmd_req_pkt.ns;
        errinfo[7:3] = 5'b0; //reserved
        errinfo[19:8] = cmd_req_pkt.txnid; //txnid

        expt_addr = cmd_req_pkt.addr;
      end
      if ($test$plusargs("SNPrsp_time_out_test")) begin //#Stimulus.CHIAIU.timeout.v3.snprsptimeout
        ev_csr_test_time_out_SNPrsp.wait_ptrigger();
        $cast(snp_req_pkt,ev_csr_test_time_out_SNPrsp.get_trigger_data());

        errinfo[1:0] = 2'b0; //reserved
        errinfo[2] = snp_req_pkt.smi_ns;
        errinfo[7:3] = 5'b0; //reserved
        errinfo[19:8] = 13'b0; //reserved

        expt_addr = snp_req_pkt.smi_addr;
      end
      if (num_timeout_err > 1) begin
          skip_check = 1;
      end
      `uvm_info(get_full_name(),$sformatf("errinfo = %0h, expt_addr = %0h",errinfo,expt_addr),UVM_NONE)

      poll_CAIUUESR_ErrVld(1, poll_data);
      if ($test$plusargs("SYSrsp_time_out_test")) begin
        errtype = 'hb;
        skip_check = 1;
        //ev_csr_test_time_out_SYSrsp.trigger(null);
      end
      fork
      begin
          wait (u_csr_probe_vif.IRQ_UC === 1);
          uvm_config_db#(int)::set(null,"*","chi_irq_uc",u_csr_probe_vif.IRQ_UC); //for coverage
          timeout_uc_err = 1;
          uvm_config_db#(int)::set(null,"*","timeout_uc_err",timeout_uc_err);
      end
      begin
        #200000ns;
        `uvm_error("RUN_MAIN",$sformatf("Timeout! Did not see IRQ_UC asserted"));
      end
      join_any
      disable fork;
      read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUUESR.ErrType, read_data);
      uvm_config_db#(int)::set(null,"*","chi_errtype_code",read_data); //for coverage
      compareValues("CAIUUESR.ErrType","should be",read_data,errtype);
      if(!skip_check) begin
        read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUUESR.ErrInfo, read_data);
        uvm_config_db#(int)::set(null,"*","chi_sysevt_err_type",read_data); //for coverage
        uvm_config_db#(int)::set(null,"*","chi_sysco_err_type",read_data); //for coverage
        compareValues("CAIUUESR.ErrInfo","should be",read_data,errinfo);
        //read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUUELR0.ErrEntry, read_data);
        //errentry = read_data;
        //read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUUELR0.ErrWay, read_data);
        //errway = read_data;
        //read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUUELR0.ErrWord, read_data);
        //errword = read_data;
        read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUUELR0.ErrAddr, read_data);
        erraddr0 = read_data;
        read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUUELR1.ErrAddr, read_data);
        erraddr = read_data;
        actual_addr = {erraddr,erraddr0};
        if (actual_addr !== expt_addr) begin
          `uvm_error(get_full_name(),$sformatf("received addr = 0x%0x didn't match with expected addr = 0x%0x",actual_addr, expt_addr))
        end
      end else begin
        `uvm_info(get_full_name(),$sformatf("skipping timeout error logging checks"), UVM_NONE)
      end
      write_data = 0;
      write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUUEDR.TimeoutErrDetEn, write_data);
      write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUUEIR.TimeOutErrIntEn, write_data);
      timeout_threshold = 0;
      if ($test$plusargs("SYSrsp_time_out_test")) begin
      write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUSCPTOCR.TimeOutThreshold, timeout_threshold);
      end else begin
      write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUTOCR.TimeOutThreshold, timeout_threshold);
      end
      write_data = 1;
      write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUUESR.ErrVld, write_data);
      // Read the CAIUUESR_ErrVld should be cleared
      read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUUESR.ErrVld, read_data);
      compareValues("CAIUUESR_ErrVld", "now clear", read_data, 0);

      timeout_err_cnt++;
      if ((timeout_err_cnt < num_timeout_err) && $test$plusargs("STRreq_time_out_test")) begin
          write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUUEDR.TimeoutErrDetEn, write_data);
          write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUUEIR.TimeOutErrIntEn, write_data);
          write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUTOCR.TimeOutThreshold, write_data);
      end
      end
    endtask

endclass : chi_aiu_csr_time_out_error_seq

class chi_aiu_csr_caiuuedr_ProtErrDetEn_seq extends chi_aiu_ral_csr_base_seq; 
  `uvm_object_utils(chi_aiu_csr_caiuuedr_ProtErrDetEn_seq)

    chi_aiu_scb_txn snp_req_pkt;
    uvm_reg_data_t poll_data, read_data, write_data;
    bit        err_det_en, err_int_en;
    bit [51:0] erraddr;
    bit [19:0] errinfo;
    bit [4:0]  errtype;

    function new(string name="");
        super.new(name);
    endfunction
  
    task body();
        getsb_handle();
        getCsrProbeIf();
        errtype = 5'h4;

        write_data = 1;
        err_det_en = $urandom_range(1,0);
        err_int_en = $urandom_range(1,0);
        write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUUEDR.ProtErrDetEn, err_det_en);
        write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUUEIR.ProtErrIntEn, err_int_en);
        ev.trigger();
        ev_snp_rsp_err.wait_ptrigger();
        $cast(snp_req_pkt,ev_snp_rsp_err.get_trigger_data());
        `uvm_info(get_full_name(),$sformatf("Triggered csr_event: ev_snp_rsp_err with pkt info as:: %0s", snp_req_pkt.convert2string()), UVM_NONE)
        errinfo[2] = snp_req_pkt.m_snp_req_pkt.smi_ns;
        if ($test$plusargs("SNPrsp_with_data_error")) begin
          errinfo[1:0] = 2'b10;
        end else if ($test$plusargs("SNPrsp_with_non_data_error")) begin
          errinfo[1:0] = 2'b11;
        end
        errinfo[19:8] = snp_req_pkt.m_chi_snp_addr_pkt.txnid; //txnid
        erraddr = snp_req_pkt.m_snp_req_pkt.smi_addr;


        if (err_det_en) begin
            `uvm_info(get_full_name(),$sformatf("errinfo = 0x%0x, erraddr = 0x%0x", errinfo, erraddr),UVM_NONE)
            poll_CAIUUESR_ErrVld(1, poll_data);
      
            read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUUESR.ErrType, read_data);
            uvm_config_db#(int)::set(null,"*","chi_errtype_code",read_data); //for coverage
            compareValues("CAIUUESR_ErrType","Valid ErrType", read_data, errtype);

            read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUUESR.ErrInfo, read_data);
            uvm_config_db#(int)::set(null,"*","chi_transport_err_type",read_data); //for coverage
            compareValues("CAIUUESR_ErrInfo","Valid ErrInfo", read_data, errinfo);

            //read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUUELR0.ErrEntry, read_data);
            //compareValues("CAIUUELR0_ErrEntry","Valid ErrEntry", read_data, erraddr[19:0]);
            //read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUUELR0.ErrWay, read_data);
            //compareValues("CAIUUELR0_ErrWay","Valid ErrWay", read_data, erraddr[25:20]);
            //read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUUELR0.ErrWord, read_data);
            //compareValues("CAIUUELR0_ErrWord","Valid ErrWord", read_data, erraddr[31:26]);
            read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUUELR0.ErrAddr, read_data);
            compareValues("CAIUUELR0_ErrAddr","Valid ErrAddr", read_data, erraddr[31:0]);
            read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUUELR1.ErrAddr, read_data);
            compareValues("CAIUUELR1_ErrAddr","Valid ErrAddr", read_data, erraddr[51:32]);

            if (err_int_en) begin
                fork
                  begin
                      wait (u_csr_probe_vif.IRQ_UC === 1);
                      uvm_config_db#(int)::set(null,"*","chi_irq_uc",u_csr_probe_vif.IRQ_UC); //for coverage
                  end
                  begin
                    #200000ns;
                    `uvm_error(get_name(),$sformatf("Timeout! Did not see IRQ_UC asserted"));
                  end
                join_any
                disable fork;
            end else begin
                fork
                  begin
                      wait (u_csr_probe_vif.IRQ_UC === 1);
                      `uvm_error(get_name(),$sformatf("IRQ_UC interrupt asserted when interrupt is disabled"));
                  end
                  begin
                    #2000ns;
                  end
                join_any
                disable fork;
            end
        end
      
	    all_txn_done_ev.wait_ptrigger();

        if (!err_det_en) begin
            read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUUESR.ErrVld, read_data);
            compareValues("CAIUUESR_ErrVld", "Error Valid should not assert when error detect is disabled", read_data, 0);
        end
    
        write_data = 0;
        write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUUEDR.ProtErrDetEn, write_data);
        write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUUEIR.ProtErrIntEn, write_data);
        write_data = 1;
        write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUUESR.ErrVld, write_data);
        read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUUESR.ErrVld, read_data); 
        compareValues("CAIUUESR_ErrVld","should be", read_data, 0);
    endtask

endclass: chi_aiu_csr_caiuuedr_ProtErrDetEn_seq

class chi_aiu_csr_caiuuedr_TransErrDetEn_seq extends chi_aiu_ral_csr_base_seq; 
  `uvm_object_utils(chi_aiu_csr_caiuuedr_TransErrDetEn_seq)

    uvm_reg_data_t poll_data, read_data, read_data2, write_data;
    bit [7:0]  errthd;
    int        errcount_vld, errthd_vld;
    int        errcount_ovf;
    bit [3:0]  errtype;
    bit [19:0] errinfo;
    bit errinfo_check, erraddr_check;
    bit [51:0]  exp_addr;
    bit [51:0] actual_addr;
    bit [19:0] err_addr;

    TRIG_TCTRLR_t tctrlr[<%=obj.DutInfo.nTraceRegisters%>];
    TRIG_TBALR_t  tbalr[<%=obj.DutInfo.nTraceRegisters%>];
    TRIG_TBAHR_t  tbahr[<%=obj.DutInfo.nTraceRegisters%>];
    TRIG_TOPCR0_t topcr0[<%=obj.DutInfo.nTraceRegisters%>];
    TRIG_TOPCR1_t topcr1[<%=obj.DutInfo.nTraceRegisters%>];
    TRIG_TUBR_t   tubr[<%=obj.DutInfo.nTraceRegisters%>];
    TRIG_TUBMR_t  tubmr[<%=obj.DutInfo.nTraceRegisters%>];

    uvm_event csr_trace_debug_done = ev_pool.get("csr_trace_debug_done");

    TRIG_TCTRLR_t tctrlr_save[<%=obj.DutInfo.nTraceRegisters%>];
    int caiu_cctrlr_phase = 0;          // This variable is controlled by the test.
    bit [31:0] caiu_cctrlr_val;         // Parm to use for CCTRLR
    bit [31:0] trackPhase;              // Fix added for CONC-8950
    bit mission_fault_asserted; 

<% for (j=0; j < obj.DutInfo.nTraceRegisters; ++j) {%>
    bit [31:0] caiu_tctrlr<%=j%>_val;   // Parm to use for TCTRLR
    bit [31:0] caiu_tbalr<%=j%>_val;    // Parm to use for TBALR
    bit [31:0] caiu_tbahr<%=j%>_val;    // Parm to use for TBAHR
    bit [31:0] caiu_topcr0<%=j%>_val;   // Parm to use for TOPCR0
    bit [31:0] caiu_topcr1<%=j%>_val;   // Parm to use for TOPCR1
    bit [31:0] caiu_tubr<%=j%>_val;     // Parm to use for TUBR
    bit [31:0] caiu_tubmr<%=j%>_val;    // Parm to use for TUBMR
<% } %>
    function new(string name="");
        super.new(name);
    endfunction

    task body();
      bit dis_uedr_ted_4resiliency = $test$plusargs("dis_uedr_ted_4resiliency") ? 1 : 0;
      getSMIIf();
      getCsrProbeIf();
      errtype = 4'h8;

         if(!uvm_config_db#(bit)::get(null,"","mission_fault_asserted",mission_fault_asserted))
              begin 
              `uvm_info(get_full_name(),"mission fault is not asserted",UVM_LOW)
              end

      <% if (obj.useResiliency) { %>
           if(mission_fault_asserted)begin
           ev_bist_reset_done.wait_ptrigger();
           end 
      <%}%>

      if(dis_uedr_ted_4resiliency) begin
        `uvm_info(get_full_name(),$sformatf("Skipping enabling of error detection inside xUEDR"),UVM_NONE)
      end
      else begin
      // Set the CAIUUECR_ErrDetEn = 1
      write_data = 1;
      write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUUEDR.TransErrDetEn, write_data);
      write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUUEIR.TransErrIntEn, write_data);
      end

      if ($test$plusargs("wrong_DtwDbg_rsp_target_id")) begin

        <% for(var i=0; i<obj.DutInfo.nTraceRegisters; i++) {%>
        if ($test$plusargs("ttrig_reg_prog_en")) begin : ttrig_reg_prog_en_code_<%=i%>
            // decide register values
            // randomize registers if value not passed through plusargs.
            bit [5:0] trace<%=i%>_match_en_rand;
            bit trace<%=i%>_native_match_en;
            bit trace<%=i%>_addr_match_en;
            bit trace<%=i%>_opcode_match_en;
            bit trace<%=i%>_memattr_match_en;
            bit trace<%=i%>_user_match_en;
            bit trace<%=i%>_target_type_match_en;
            bit [4:0] trace<%=i%>_addr_match_size;
            bit [3:0] trace<%=i%>_memattr_match_value;
            bit [3:0] trace<%=i%>_opcode_valids_rand;
            bit [14:0] trace<%=i%>_opcode1;
            bit [14:0] trace<%=i%>_opcode2;
            bit [14:0] trace<%=i%>_opcode3;
            bit [14:0] trace<%=i%>_opcode4;
            bit trace<%=i%>_target_type_match_hut;
            bit [4:0] trace<%=i%>_target_type_match_hui;

            uvm_config_db#(int)::get(null, "", "caiu_cctrlr_phase", caiu_cctrlr_phase);

            if (($test$plusargs("caiu_cctrlr_mod")) && ($test$plusargs("caiu_tctrlr<%=i%>_val")) &&
                (caiu_cctrlr_phase==2)) begin
                tctrlr[<%=i%>] = caiu_tctrlr<%=i%>_val;
            end else if($test$plusargs("trigger<%=i%>_random")) begin
                tctrlr[<%=i%>] = $urandom();
            end else if($value$plusargs("tctrlr<%=i%>_value=%0x", tctrlr[<%=i%>])) begin
                // user-specified tctrlr
            end else begin : randomize_tctrlr_by_field
              begin: select_values_for_enables
                case ($urandom_range(100,1)) inside
                    ['d01:'d20]: trace<%=i%>_match_en_rand = 'h3f; // all enabled
                    ['d21:'d25]: trace<%=i%>_match_en_rand = 'h20; // enable one at a time
                    ['d26:'d30]: trace<%=i%>_match_en_rand = 'h10;
                    ['d31:'d35]: trace<%=i%>_match_en_rand = 'h08;
                    ['d36:'d40]: trace<%=i%>_match_en_rand = 'h04;
                    ['d41:'d45]: trace<%=i%>_match_en_rand = 'h02;
                    ['d46:'d50]: trace<%=i%>_match_en_rand = 'h01;
                    ['d51:'d60]: trace<%=i%>_match_en_rand = 'h00; // none enabled
                    default :    trace<%=i%>_match_en_rand = $urandom_range('h3f,'h00); // unconstrained
                endcase
                if($value$plusargs("trace_native_match_en=%0b", trace<%=i%>_native_match_en)) begin
                    // user-specified native_match_en
                end else begin
                    trace<%=i%>_native_match_en = trace<%=i%>_match_en_rand[0];
                end
                tctrlr[<%=i%>].native_trace_en = trace<%=i%>_native_match_en;
                if($value$plusargs("trace_addr_match_en=%0b", trace<%=i%>_addr_match_en)) begin
                    // user-specified addr_match_en
                end else begin
                    trace<%=i%>_addr_match_en = trace<%=i%>_match_en_rand[1];
                end
                tctrlr[<%=i%>].addr_match_en = trace<%=i%>_addr_match_en;
                if($value$plusargs("trace_opcode_match_en=%0b", trace<%=i%>_opcode_match_en)) begin
                    // user-specified opcode_match_en
                end else begin
                    trace<%=i%>_opcode_match_en = trace<%=i%>_match_en_rand[2];
                end
                tctrlr[<%=i%>].opcode_match_en = trace<%=i%>_opcode_match_en;
                if($value$plusargs("trace_memattr_match_en=%0b", trace<%=i%>_memattr_match_en)) begin
                    // user-specified memattr_match_en
                end else begin
                    trace<%=i%>_memattr_match_en = trace<%=i%>_match_en_rand[3];
                end
                tctrlr[<%=i%>].memattr_match_en = trace<%=i%>_memattr_match_en;
                if($value$plusargs("trace_user_match_en=%0b", trace<%=i%>_user_match_en)) begin
                    // user-specified user_match_en
                end else begin
                    trace<%=i%>_user_match_en = trace<%=i%>_match_en_rand[4];
                end
                tctrlr[<%=i%>].user_match_en = trace<%=i%>_user_match_en;
                if($value$plusargs("trace_target_type_match_en=%0b", trace<%=i%>_target_type_match_en)) begin
                    // user-specified target_type_match_en
                end else begin
                    trace<%=i%>_target_type_match_en = trace<%=i%>_match_en_rand[5];
                end
                tctrlr[<%=i%>].target_type_match_en = trace<%=i%>_target_type_match_en;
              end: select_values_for_enables

              begin: select_values_for_tctrlr_misc_fields
                if($value$plusargs("trace_addr_match_size=%0x", trace<%=i%>_addr_match_size)) begin
                    // user-specified addr_match_size
                end else begin
                    trace<%=i%>_addr_match_en = trace<%=i%>_match_en_rand[1];
                    case ($urandom_range(100,1)) inside
                        ['d01:'d10]: trace<%=i%>_addr_match_size = 'h1f; // max size
                        ['d11:'d20]: trace<%=i%>_addr_match_size = 'h00; // min size
                        default :    trace<%=i%>_addr_match_size = $urandom_range('h1f,'h00); // unconstrained
                    endcase
                end
                tctrlr[<%=i%>].range = trace<%=i%>_addr_match_size;

                if($value$plusargs("trace_memattr_match_value=%0x", trace<%=i%>_memattr_match_value)) begin
                    // user-specified memattr_match_value
                end else begin
                    trace<%=i%>_memattr_match_value = $urandom_range('hf,'h0); // unconstrained
                end
                tctrlr[<%=i%>].memattr = trace<%=i%>_memattr_match_value;

                // hut dii=1, dmi=0
                if($value$plusargs("trace_target_type_match_hut=%0b", trace<%=i%>_target_type_match_hut)) begin
                    // user-specified target_type_match_hut
                end else begin
                    trace<%=i%>_target_type_match_hut = $urandom_range('h1,'h0); // unconstrained
                end
                tctrlr[<%=i%>].hut = trace<%=i%>_target_type_match_hut;

                if($value$plusargs("trace_target_type_match_hui=%0b", trace<%=i%>_target_type_match_hui)) begin
                    // user-specified target_type_match_hui
                end else begin
                    case ($urandom_range(100,1)) inside
                        // 'h00 and 'h01 are most commonly seen in simulations, larger values are rare or do not occur
                        ['d01:'d10]: trace<%=i%>_target_type_match_hui = 'h00; 
                        ['d11:'d20]: trace<%=i%>_target_type_match_hui = 'h01; 
                        ['d21:'d30]: trace<%=i%>_target_type_match_hui = 'h02; 
                        default :    trace<%=i%>_target_type_match_hui = $urandom_range('h1f,'h00); // unconstrained
                    endcase
                end
                tctrlr[<%=i%>].hui = trace<%=i%>_target_type_match_hui;

              end: select_values_for_tctrlr_misc_fields
            end : randomize_tctrlr_by_field

            if (($test$plusargs("caiu_cctrlr_mod")) && ($test$plusargs("caiu_tbalr<%=i%>_val")) &&
                (caiu_cctrlr_phase==2)) begin
                tbalr[<%=i%>] = caiu_tbalr<%=i%>_val;
            end
            if (($test$plusargs("caiu_cctrlr_mod")) && ($test$plusargs("caiu_tbahr<%=i%>_val")) &&
                (caiu_cctrlr_phase==2)) begin
                tbahr[<%=i%>] = caiu_tbahr<%=i%>_val;
            end else if($test$plusargs("trigger<%=i%>_random")) begin
                tbalr[<%=i%>] = $urandom();
                tbahr[<%=i%>] = $urandom();
            end else if($value$plusargs("tbalr<%=i%>_value=%0x", tbalr[<%=i%>])) begin
                // user-specified tbalr
                $value$plusargs("tbahr<%=i%>_value=%0x", tbahr[<%=i%>]); 
                // user-specified tbahr
            end else begin
                case ($urandom_range(100,1)) inside
                    ['d01:'d10]: tbahr[<%=i%>] = 'h00; // min
                    ['d11:'d15]: tbahr[<%=i%>] = 'h01; // walk a one
                    ['d16:'d20]: tbahr[<%=i%>] = 'h02; 
                    ['d21:'d25]: tbahr[<%=i%>] = 'h04; 
                    ['d26:'d30]: tbahr[<%=i%>] = 'h08; 
                    ['d31:'d35]: tbahr[<%=i%>] = 'h10; 
                    ['d36:'d40]: tbahr[<%=i%>] = 'h20; 
                    ['d41:'d45]: tbahr[<%=i%>] = 'h40; 
                    ['d46:'d50]: tbahr[<%=i%>] = 'h80; 
                    ['d51:'d60]: tbahr[<%=i%>] = 'hff; // max
                    default :    tbahr[<%=i%>] = $urandom_range('hff,'h00); // unconstrained
                endcase
                case ($urandom_range(100,1)) inside
                    ['d01:'d10]: tbalr[<%=i%>] = 'h0000_0000; // min
                    ['d11:'d15]: tbalr[<%=i%>] = $urandom_range('h0000_00ff,'h0000_0000); // lower
                    ['d16:'d20]: tbalr[<%=i%>] = 'h0000_0100; 
                    ['d21:'d25]: tbalr[<%=i%>] = 'h0000_ff70; 
                    ['d26:'d30]: tbalr[<%=i%>] = 'h0001_0000; 
                    ['d31:'d35]: tbalr[<%=i%>] = 'h000f_f800; 
                    ['d36:'d40]: tbalr[<%=i%>] = 'h0010_0000; 
                    ['d41:'d45]: tbalr[<%=i%>] = 'h00ff_ff90; 
                    ['d46:'d50]: tbalr[<%=i%>] = 'h0100_0000; 
                    ['d51:'d55]: tbalr[<%=i%>] = 'h0fff_fff0; 
                    ['d56:'d60]: tbalr[<%=i%>] = 'h1000_0000; 
                    ['d61:'d65]: tbalr[<%=i%>] = 'ha5a5_a5a5; 
                    ['d66:'d70]: tbalr[<%=i%>] = 'h5a5a_5a5a; 
                    ['d71:'d75]: tbalr[<%=i%>] = $urandom_range('hffff_ffff,'hffff_ff00); // upper
                    ['d76:'d85]: tbalr[<%=i%>] = 'hffff_ffff; // max
                    default :    tbalr[<%=i%>] = $urandom_range('hffff_ffff,'h0000_0000); // unconstrained
                endcase
            end

            if (($test$plusargs("caiu_cctrlr_mod")) && ($test$plusargs("caiu_topcr0<%=i%>_val")) &&
                (caiu_cctrlr_phase==2)) begin
                topcr0[<%=i%>] = caiu_topcr0<%=i%>_val;
            end
            if (($test$plusargs("caiu_cctrlr_mod")) && ($test$plusargs("caiu_topcr1<%=i%>_val")) &&
                (caiu_cctrlr_phase==2)) begin
                topcr1[<%=i%>] = caiu_topcr1<%=i%>_val;
            end else if($test$plusargs("trigger<%=i%>_random")) begin
                topcr0[<%=i%>] = $urandom();
                topcr1[<%=i%>] = $urandom();
            // assume if user specifies topcr0 they also specify topcr1
            end else if($value$plusargs("topcr0<%=i%>_value=%0x", topcr0[<%=i%>])) begin
                // user-specified topcr0
                $value$plusargs("topcr1<%=i%>_value=%0x", topcr1[<%=i%>]);
                // user-specified topcr1
            end else begin : opcode_weighted_randomization
                case ($urandom_range(100,1)) inside
                    // prioritize more valids for a better chance of getting a match
                    ['d01:'d10]: trace<%=i%>_opcode_valids_rand = 'hf; // all
                    ['d11:'d15]: trace<%=i%>_opcode_valids_rand = 'h8; // one at a time
                    ['d16:'d20]: trace<%=i%>_opcode_valids_rand = 'h4; 
                    ['d21:'d25]: trace<%=i%>_opcode_valids_rand = 'h2; 
                    ['d26:'d30]: trace<%=i%>_opcode_valids_rand = 'h1; 
                    ['d31:'d35]: trace<%=i%>_opcode_valids_rand = 'h0; // none
                    default :    trace<%=i%>_opcode_valids_rand = $urandom_range('hf,'h0); // unconstrained
                endcase
                case ($urandom_range(100,1)) inside
                    // most of the time, choose values from 'h00 to 'h3f, not sure if values above 'h3f are possible for NCore 3.2
                    ['d01:'d90]: trace<%=i%>_opcode1 = $urandom_range('h3f,'h00);
                    ['d90:'d91]: trace<%=i%>_opcode1 = 'h7fff; // max value
                    default :    trace<%=i%>_opcode1 = $urandom_range('h7fff,'h0000); // unconstrained
                endcase
                case ($urandom_range(100,1)) inside
                    // most of the time, choose values from 'h00 to 'h3f, not sure if values above 'h3f are possible for NCore 3.2
                    ['d01:'d90]: trace<%=i%>_opcode2 = $urandom_range('h3f,'h00);
                    ['d90:'d91]: trace<%=i%>_opcode2 = 'h7fff; // max value
                    default :    trace<%=i%>_opcode2 = $urandom_range('h7fff,'h0000); // unconstrained
                endcase
                case ($urandom_range(100,1)) inside
                    // most of the time, choose values from 'h00 to 'h3f, not sure if values above 'h3f are possible for NCore 3.2
                    ['d01:'d90]: trace<%=i%>_opcode3 = $urandom_range('h3f,'h00);
                    ['d90:'d91]: trace<%=i%>_opcode3 = 'h7fff; // max value
                    default :    trace<%=i%>_opcode3 = $urandom_range('h7fff,'h0000); // unconstrained
                endcase
                case ($urandom_range(100,1)) inside
                    // most of the time, choose values from 'h00 to 'h3f, not sure if values above 'h3f are possible for NCore 3.2
                    ['d01:'d90]: trace<%=i%>_opcode4 = $urandom_range('h3f,'h00);
                    ['d90:'d91]: trace<%=i%>_opcode4 = 'h7fff; // max value
                    default :    trace<%=i%>_opcode4 = $urandom_range('h7fff,'h0000); // unconstrained
                endcase
                topcr0[<%=i%>].valid1  = trace<%=i%>_opcode_valids_rand[0];
                topcr0[<%=i%>].valid2  = trace<%=i%>_opcode_valids_rand[1];
                topcr1[<%=i%>].valid3  = trace<%=i%>_opcode_valids_rand[2];
                topcr1[<%=i%>].valid4  = trace<%=i%>_opcode_valids_rand[3];
                topcr0[<%=i%>].opcode1 = trace<%=i%>_opcode1;
                topcr0[<%=i%>].opcode2 = trace<%=i%>_opcode2;
                topcr1[<%=i%>].opcode3 = trace<%=i%>_opcode3;
                topcr1[<%=i%>].opcode4 = trace<%=i%>_opcode4;
            end : opcode_weighted_randomization

            if (($test$plusargs("caiu_cctrlr_mod")) && ($test$plusargs("caiu_tubr<%=i%>_val")) &&
                (caiu_cctrlr_phase==2)) begin
                tubr[<%=i%>] = caiu_tubr<%=i%>_val;
            end else if($test$plusargs("trigger<%=i%>_random")) begin
                tubr[<%=i%>] = $urandom();
            end else if($value$plusargs("tubr<%=i%>_value=%0x", tubr[<%=i%>])) begin
                // user-specified tubr
            end else begin : tubr_weighted_randomization
                case ($urandom_range(100,1)) inside
                    ['d01:'d20]: tubr[<%=i%>] = 'h0000_0000; 
                    ['d21:'d40]: tubr[<%=i%>] = $urandom_range('hf,'h0);
                    ['d41:'d41]: tubr[<%=i%>] = 'h0000_0010; 
                    ['d42:'d42]: tubr[<%=i%>] = 'h0000_0020; 
                    ['d43:'d43]: tubr[<%=i%>] = 'h0000_0040; 
                    ['d44:'d44]: tubr[<%=i%>] = 'h0000_0080; 
                    ['d45:'d45]: tubr[<%=i%>] = 'h0000_0100; 
                    ['d46:'d46]: tubr[<%=i%>] = 'h0000_0200; 
                    ['d47:'d47]: tubr[<%=i%>] = 'h0000_0400; 
                    ['d48:'d48]: tubr[<%=i%>] = 'h0000_0800; 
                    ['d49:'d49]: tubr[<%=i%>] = 'h0000_1000; 
                    ['d50:'d50]: tubr[<%=i%>] = 'h0000_2000; 
                    ['d51:'d51]: tubr[<%=i%>] = 'h0000_4000; 
                    ['d52:'d52]: tubr[<%=i%>] = 'h0000_8000; 
                    ['d53:'d53]: tubr[<%=i%>] = 'h0001_0000; 
                    ['d54:'d54]: tubr[<%=i%>] = 'h0002_0000; 
                    ['d55:'d55]: tubr[<%=i%>] = 'h0004_0000; 
                    ['d56:'d56]: tubr[<%=i%>] = 'h0008_0000; 
                    ['d57:'d57]: tubr[<%=i%>] = 'h0010_0000; 
                    ['d58:'d58]: tubr[<%=i%>] = 'h0020_0000; 
                    ['d59:'d59]: tubr[<%=i%>] = 'h0040_0000; 
                    ['d60:'d60]: tubr[<%=i%>] = 'h0080_0000; 
                    ['d61:'d61]: tubr[<%=i%>] = 'h0100_0000; 
                    ['d62:'d62]: tubr[<%=i%>] = 'h0200_0000; 
                    ['d63:'d63]: tubr[<%=i%>] = 'h0400_0000; 
                    ['d64:'d64]: tubr[<%=i%>] = 'h0800_0000; 
                    ['d65:'d65]: tubr[<%=i%>] = 'h1000_0000; 
                    ['d66:'d66]: tubr[<%=i%>] = 'h2000_0000; 
                    ['d67:'d67]: tubr[<%=i%>] = 'h4000_0000; 
                    ['d68:'d68]: tubr[<%=i%>] = 'h8000_0000; 
                    ['d69:'d74]: tubr[<%=i%>] = 'hffff_ffff; 
                    ['d75:'d79]: tubr[<%=i%>] = $urandom_range('hffff_ffff,'hffff_fff0);
                    default :    tubr[<%=i%>] = $urandom_range('hffff_ffff,'h0000_0000); // unconstrained
                endcase
            end : tubr_weighted_randomization

            if (($test$plusargs("caiu_cctrlr_mod")) && ($test$plusargs("caiu_tubmr<%=i%>_val")) &&
                (caiu_cctrlr_phase==2)) begin
                tubmr[<%=i%>] = caiu_tubmr<%=i%>_val;
            end else if($test$plusargs("trigger<%=i%>_random")) begin
                tubmr[<%=i%>] = $urandom();
            end else if($value$plusargs("tubmr<%=i%>_value=%0x", tubmr[<%=i%>])) begin
                // user-specified tubmr
            end else begin : tubmr_weighted_randomization
                case ($urandom_range(100,1)) inside
                    ['d01:'d20]: tubmr[<%=i%>] = 'h0000_0000; 
                    ['d21:'d40]: tubmr[<%=i%>] = $urandom_range('hf,'h0);
                    ['d41:'d41]: tubmr[<%=i%>] = 'h0000_0010; 
                    ['d42:'d42]: tubmr[<%=i%>] = 'h0000_0020; 
                    ['d43:'d43]: tubmr[<%=i%>] = 'h0000_0040; 
                    ['d44:'d44]: tubmr[<%=i%>] = 'h0000_0080; 
                    ['d45:'d45]: tubmr[<%=i%>] = 'h0000_0100; 
                    ['d46:'d46]: tubmr[<%=i%>] = 'h0000_0200; 
                    ['d47:'d47]: tubmr[<%=i%>] = 'h0000_0400; 
                    ['d48:'d48]: tubmr[<%=i%>] = 'h0000_0800; 
                    ['d49:'d49]: tubmr[<%=i%>] = 'h0000_1000; 
                    ['d50:'d50]: tubmr[<%=i%>] = 'h0000_2000; 
                    ['d51:'d51]: tubmr[<%=i%>] = 'h0000_4000; 
                    ['d52:'d52]: tubmr[<%=i%>] = 'h0000_8000; 
                    ['d53:'d53]: tubmr[<%=i%>] = 'h0001_0000; 
                    ['d54:'d54]: tubmr[<%=i%>] = 'h0002_0000; 
                    ['d55:'d55]: tubmr[<%=i%>] = 'h0004_0000; 
                    ['d56:'d56]: tubmr[<%=i%>] = 'h0008_0000; 
                    ['d57:'d57]: tubmr[<%=i%>] = 'h0010_0000; 
                    ['d58:'d58]: tubmr[<%=i%>] = 'h0020_0000; 
                    ['d59:'d59]: tubmr[<%=i%>] = 'h0040_0000; 
                    ['d60:'d60]: tubmr[<%=i%>] = 'h0080_0000; 
                    ['d61:'d61]: tubmr[<%=i%>] = 'h0100_0000; 
                    ['d62:'d62]: tubmr[<%=i%>] = 'h0200_0000; 
                    ['d63:'d63]: tubmr[<%=i%>] = 'h0400_0000; 
                    ['d64:'d64]: tubmr[<%=i%>] = 'h0800_0000; 
                    ['d65:'d65]: tubmr[<%=i%>] = 'h1000_0000; 
                    ['d66:'d66]: tubmr[<%=i%>] = 'h2000_0000; 
                    ['d67:'d67]: tubmr[<%=i%>] = 'h4000_0000; 
                    ['d68:'d68]: tubmr[<%=i%>] = 'h8000_0000; 
                    ['d69:'d74]: tubmr[<%=i%>] = 'hffff_ffff; 
                    ['d75:'d79]: tubmr[<%=i%>] = $urandom_range('hffff_ffff,'hffff_fff0);
                    default :    tubmr[<%=i%>] = $urandom_range('hffff_ffff,'h0000_0000); // unconstrained
                endcase
            end : tubmr_weighted_randomization

            // zero out bits that should not exist in the RTL for this particular config

            // CHI-A does not support native traceme
            <% if (obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-A') { %>
            tctrlr[<%=i%>].native_trace_en = 0;
            <%}%>

            tctrlr[<%=i%>].aw = 0; // CHI does not have aw
            tctrlr[<%=i%>].ar = 0; // CHI does not have ar

            // set user_match_en to always 0 when user bit width is 0, CONC-7967
            <% if(!obj.AiuInfo[obj.Id].interfaces.chiInt.params.REQ_RSVDC) {%>
            tctrlr[<%=i%>].user_match_en = 0;
            tubr[<%=i%>].user = 0;
            tubmr[<%=i%>].user_mask = 0;
            <%}%>

            // ------------------------------------------------------------------------
            // Fix for CONC-8950....Storing all the enablements bits of the TCTRLR 
            // register. Those might get restored at phase2 as indicated in CONC-7967. 
            if (($test$plusargs("caiu_cctrlr_mod")) && ("caiu_cctrlr_phase==0") && (trackPhase <= <%=i%>)) begin
               tctrlr_save[<%=i%>] = tctrlr[<%=i%>];
               ++trackPhase;
            end;

           // -----------------------------------------------------
           // Restored the enablement bits.
           if (caiu_cctrlr_phase==1) begin
               tctrlr[<%=i%>] = tctrlr_save[<%=i%>];     // CONC-8950

               tubmr[<%=i%>]  = 32'h0;
               tubr[<%=i%>]   = 32'h0;
               topcr0[<%=i%>] = 32'h0;
               topcr1[<%=i%>] = 32'h0;
               tbalr[<%=i%>]  = 32'h0;
               tbahr[<%=i%>]  = 32'h0;

              `uvm_info(get_name(), $sformatf("All Trace Regs have been reset as caiu_cctrlr_phase=1."), UVM_HIGH)
            end

           if (caiu_cctrlr_phase==2) begin
              if (<%=i%> == 0 || (tctrlr[0][0]==1))      // CONC-8950
                 tctrlr[<%=i%>] = tctrlr_save[<%=i%>];
           end
      
            // write register values to RTL
            // fixme: billc: 2021-09-30, decide whether or not to add code to not write certain registers if the corresponding match_en is 0
            <% if (obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>
            write_csr(m_regs.<%=obj.BlockId%>.CAIUTCTRLR<%=i%>.native_trace_en, tctrlr[<%=i%>].native_trace_en);
            <%}%>
            write_csr(m_regs.<%=obj.BlockId%>.CAIUTCTRLR<%=i%>.addr_match_en, tctrlr[<%=i%>].addr_match_en);
            write_csr(m_regs.<%=obj.BlockId%>.CAIUTCTRLR<%=i%>.opcode_match_en, tctrlr[<%=i%>].opcode_match_en);
            write_csr(m_regs.<%=obj.BlockId%>.CAIUTCTRLR<%=i%>.memattr_match_en, tctrlr[<%=i%>].memattr_match_en);
            <% if(obj.AiuInfo[obj.Id].interfaces.chiInt.params.REQ_RSVDC) {%>
            write_csr(m_regs.<%=obj.BlockId%>.CAIUTCTRLR<%=i%>.user_match_en, tctrlr[<%=i%>].user_match_en);
            <%}%>
            write_csr(m_regs.<%=obj.BlockId%>.CAIUTCTRLR<%=i%>.target_type_match_en, tctrlr[<%=i%>].target_type_match_en);
            write_csr(m_regs.<%=obj.BlockId%>.CAIUTCTRLR<%=i%>.hut, tctrlr[<%=i%>].hut);
            write_csr(m_regs.<%=obj.BlockId%>.CAIUTCTRLR<%=i%>.hui, tctrlr[<%=i%>].hui);
            write_csr(m_regs.<%=obj.BlockId%>.CAIUTCTRLR<%=i%>.range, tctrlr[<%=i%>].range);
            //write_csr(m_regs.<%=obj.BlockId%>.CAIUTCTRLR<%=i%>.aw, tctrlr[<%=i%>].aw); // aw does not exist for CHI
            //write_csr(m_regs.<%=obj.BlockId%>.CAIUTCTRLR<%=i%>.ar, tctrlr[<%=i%>].ar); // ar does not exist for CHI
            write_csr(m_regs.<%=obj.BlockId%>.CAIUTCTRLR<%=i%>.memattr, tctrlr[<%=i%>].memattr);

            write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUTBALR<%=i%>.base_addr_lo, tbalr[<%=i%>].base_addr_43_12);

            write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUTBAHR<%=i%>.base_addr_hi, tbahr[<%=i%>].base_addr_51_44);

            topcr0[<%=i%>].opcode1 = topcr0[<%=i%>].opcode1 & {WREQOPCODE{1'b1}};
            topcr0[<%=i%>].opcode2 = topcr0[<%=i%>].opcode2 & {WREQOPCODE{1'b1}};
            topcr1[<%=i%>].opcode3 = topcr1[<%=i%>].opcode3 & {WREQOPCODE{1'b1}};
            topcr1[<%=i%>].opcode4 = topcr1[<%=i%>].opcode4 & {WREQOPCODE{1'b1}};
            write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUTOPCR0<%=i%>.opcode1, topcr0[<%=i%>].opcode1);
            write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUTOPCR0<%=i%>.valid1,  topcr0[<%=i%>].valid1);
            write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUTOPCR0<%=i%>.opcode2, topcr0[<%=i%>].opcode2);
            write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUTOPCR0<%=i%>.valid2,  topcr0[<%=i%>].valid2);
            write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUTOPCR1<%=i%>.opcode3, topcr1[<%=i%>].opcode3);
            write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUTOPCR1<%=i%>.valid3,  topcr1[<%=i%>].valid3);
            write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUTOPCR1<%=i%>.opcode4, topcr1[<%=i%>].opcode4);
            write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUTOPCR1<%=i%>.valid4,  topcr1[<%=i%>].valid4);

            <% if(obj.AiuInfo[obj.Id].interfaces.chiInt.params.REQ_RSVDC) {%>
            tubr[<%=i%>].user = tubr[<%=i%>].user & {WREQRSVDC{1'b1}};
            tubmr[<%=i%>].user_mask = tubmr[<%=i%>].user_mask & {WREQRSVDC{1'b1}};
            write_csr(m_regs.<%=obj.BlockId%>.CAIUTUBR<%=i%>.user, tubr[<%=i%>].user);
            write_csr(m_regs.<%=obj.BlockId%>.CAIUTUBMR<%=i%>.user_mask, tubmr[<%=i%>].user_mask);
            <%}%>

            // pass register values to the scoreboard.
            chi_aiu_scb::tctrlr[<%=i%>] =  tctrlr[<%=i%>];
            chi_aiu_scb::tbalr[<%=i%>]  =  tbalr[<%=i%>];
            chi_aiu_scb::tbahr[<%=i%>]  =  tbahr[<%=i%>];
            chi_aiu_scb::topcr0[<%=i%>] =  topcr0[<%=i%>];
            chi_aiu_scb::topcr1[<%=i%>] =  topcr1[<%=i%>];
            chi_aiu_scb::tubr[<%=i%>]   =  tubr[<%=i%>];
            chi_aiu_scb::tubmr[<%=i%>]  =  tubmr[<%=i%>];

            `uvm_info(get_name(), $sformatf("TTRI: tctrlr[<%=i%>]               = %8h", tctrlr[<%=i%>]), UVM_HIGH)
            `uvm_info(get_name(), $sformatf("TTRI: tbalr[<%=i%>]                = %8h", tbalr[<%=i%>]), UVM_HIGH)
            `uvm_info(get_name(), $sformatf("TTRI: tbahr[<%=i%>]                = %8h", tbahr[<%=i%>]), UVM_HIGH)
            `uvm_info(get_name(), $sformatf("TTRI: topcr0[<%=i%>]               = %8h", topcr0[<%=i%>]), UVM_HIGH)
            `uvm_info(get_name(), $sformatf("TTRI: topcr1[<%=i%>]               = %8h", topcr1[<%=i%>]), UVM_HIGH)
            `uvm_info(get_name(), $sformatf("TTRI: tubr[<%=i%>]                 = %8h", tubr[<%=i%>]), UVM_HIGH)
            `uvm_info(get_name(), $sformatf("TTRI: tubmr[<%=i%>]                = %8h", tubmr[<%=i%>]), UVM_HIGH)
            `uvm_info(get_name(), $sformatf("TTRI: trace<%=i%>_match_en_rand         = %6b",  trace<%=i%>_match_en_rand), UVM_HIGH)
            `uvm_info(get_name(), $sformatf("TTRI: trace<%=i%>_native_match_en       = %b",  trace<%=i%>_native_match_en), UVM_HIGH)
            `uvm_info(get_name(), $sformatf("TTRI: trace<%=i%>_addr_match_en         = %b",  trace<%=i%>_addr_match_en), UVM_HIGH)
            `uvm_info(get_name(), $sformatf("TTRI: trace<%=i%>_opcode_match_en       = %b",  trace<%=i%>_opcode_match_en), UVM_HIGH)
            `uvm_info(get_name(), $sformatf("TTRI: trace<%=i%>_memattr_match_en      = %b",  trace<%=i%>_memattr_match_en), UVM_HIGH)
            `uvm_info(get_name(), $sformatf("TTRI: trace<%=i%>_user_match_en         = %b",  trace<%=i%>_user_match_en), UVM_HIGH)
            `uvm_info(get_name(), $sformatf("TTRI: trace<%=i%>_target_type_match_en  = %b",  trace<%=i%>_target_type_match_en), UVM_HIGH)
            `uvm_info(get_name(), $sformatf("TTRI: match_en native       = %b, addr = %b, opcode = %b, memattr = %b, user = %b, target_type = %b", trace<%=i%>_native_match_en, trace<%=i%>_addr_match_en, trace<%=i%>_opcode_match_en, trace<%=i%>_memattr_match_en, trace<%=i%>_user_match_en, trace<%=i%>_target_type_match_en), UVM_HIGH)
            `uvm_info(get_name(), $sformatf("TTRI: trace<%=i%>_addr_match_size       = %h", trace<%=i%>_addr_match_size), UVM_HIGH)
            `uvm_info(get_name(), $sformatf("TTRI: trace<%=i%>_memattr_match_value   = %h", trace<%=i%>_memattr_match_value), UVM_HIGH)
            `uvm_info(get_name(), $sformatf("TTRI: trace<%=i%>_opcode_valids_rand    = %4b", trace<%=i%>_opcode_valids_rand), UVM_HIGH)
            `uvm_info(get_name(), $sformatf("TTRI: trace<%=i%>_opcode1               = %4h", trace<%=i%>_opcode1), UVM_HIGH)
            `uvm_info(get_name(), $sformatf("TTRI: trace<%=i%>_opcode2               = %4h", trace<%=i%>_opcode2), UVM_HIGH)
            `uvm_info(get_name(), $sformatf("TTRI: trace<%=i%>_opcode3               = %4h", trace<%=i%>_opcode3), UVM_HIGH)
            `uvm_info(get_name(), $sformatf("TTRI: trace<%=i%>_opcode4               = %4h", trace<%=i%>_opcode4), UVM_HIGH)
            `uvm_info(get_name(), $sformatf("TTRI: trace<%=i%>_target_type_match_hut = %b", trace<%=i%>_target_type_match_hut), UVM_HIGH)
            `uvm_info(get_name(), $sformatf("TTRI: trace<%=i%>_target_type_match_hui = %5h", trace<%=i%>_target_type_match_hui), UVM_HIGH)

        end : ttrig_reg_prog_en_code_<%=i%>
        <%}%>

        if ($test$plusargs("tcap_reg_prog_en")) begin : tcap_reg_prog_en_code
            bit [31:0] set_value = 0;
            bit [7:0]  smi_cap   = 0;
            bit [3:0]  gain      = 0;
            bit [11:0] inc       = 0;

            if (($test$plusargs("caiu_cctrlr_mod")) && ($test$plusargs("caiu_cctrlr_val")) &&
                (caiu_cctrlr_phase==2)) begin
                smi_cap = caiu_cctrlr_val[7:0];
                gain    = caiu_cctrlr_val[19:16];
                inc     = caiu_cctrlr_val[31:20];
            end else if ($test$plusargs("cctrlr_random")) begin
                std::randomize(smi_cap);
                std::randomize(gain);
                std::randomize(inc);
                `uvm_info(get_name(), $sformatf("<%=obj.DutInfo.strRtlNamePrefix%> Set CCRTRLR to random values. SMI_CAPT=%0h, GAIN=%0d, VALUE=%0d", smi_cap, gain, inc), UVM_LOW)
            end else if ($value$plusargs("cctrlr_value=0x%0h", set_value)) begin
                smi_cap      = set_value[7:0];
                gain         = set_value[19:16];
                inc          = set_value[31:20];
                `uvm_info(get_name(), $sformatf("<%=obj.DutInfo.strRtlNamePrefix%> Set CCRTRLR through cmdln=%0h. SMI_CAPT=%0h, GAIN=%0d, INC=%0d", set_value, smi_cap, gain, inc), UVM_LOW)
            end else begin : weighted_random
                if ($value$plusargs("cctrlr_enables=0x%0h", smi_cap)) begin
                  // user-specified smi_cap
                end else begin : cctrlr_enables_weighted_random
                  case ($urandom_range(100,1)) inside
                    ['d01:'d10]: smi_cap = 'hff; // all on DMI
                    ['d11:'d20]: smi_cap = 'hcf; // all on CHI
                    ['d21:'d22]: smi_cap = 'h01; // try one at a time
                    ['d23:'d24]: smi_cap = 'h02;
                    ['d25:'d26]: smi_cap = 'h04;
                    ['d27:'d28]: smi_cap = 'h08;
                    ['d29:'d30]: smi_cap = 'h10;
                    ['d31:'d32]: smi_cap = 'h20;
                    ['d33:'d34]: smi_cap = 'h40;
                    ['d35:'d36]: smi_cap = 'h80;
                    ['d37:'d70]: smi_cap = 'h00; // all off
                    default :    smi_cap = $urandom_range('hff,'h00); // unconstrained
                  endcase
                end : cctrlr_enables_weighted_random
                if ($value$plusargs("cctrlr_gain=0x%0h", gain)) begin
                  // user-specified gain
                end else begin : cctrlr_gain_weighted_random 
                  case ($urandom_range(100,1)) inside
                    ['d01:'d50]: gain = 'h0; // disables TS corrections
                    default :    gain = $urandom_range('hf,'h0); // unconstrained
                  endcase
                end : cctrlr_gain_weighted_random
                if ($value$plusargs("cctrlr_inc_integer=0x%0h", inc[11:8])) begin
                  // user-specified inc integer
                end else begin : cctrlr_inc_integer_weighted_random 
                  case ($urandom_range(100,1)) inside
                    ['d01:'d25]: inc[11:8] = 'h0;
                    ['d26:'d50]: inc[11:8] = 'hf;
                    default :    inc[11:8] = $urandom_range('hf,'h0); // unconstrained
                  endcase
                end : cctrlr_inc_integer_weighted_random
                if ($value$plusargs("cctrlr_inc_fractional=0x%0h", inc[7:0])) begin
                  // user-specified inc fractional
                end else begin : cctrlr_inc_fractional_weighted_random 
                  case ($urandom_range(100,1)) inside
                    ['d01:'d25]: inc[7:0] = 'h00;
                    ['d26:'d50]: inc[7:0] = 'hff;
                    default :    inc[7:0] = $urandom_range('hff,'h00); // unconstrained
                  endcase
                end : cctrlr_inc_fractional_weighted_random
            end : weighted_random

            uvm_config_db#(int)::get(null, "*", "caiu_cctrlr_phase", caiu_cctrlr_phase);

            if ($test$plusargs("caiu_cctrlr_mod") && (caiu_cctrlr_phase != 0)) begin
                // CCTRLR[7:0] are updated
                smi_cap = (caiu_cctrlr_phase==2) ? smi_cap : 0;
		<% for (i=0; i < obj.DutInfo.nTraceRegisters; ++i) {%>
                tctrlr[<%=i%>] = (caiu_cctrlr_phase==2) ? tctrlr[<%=i%>] : 0;
        	<%}%>
            end

            write_data = (smi_cap >> 0) & 1;
            write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUCCTRLR.ndn0Tx, write_data);
            trace_debug_scb::port_capture_en[0] = write_data ? (smi_cap[0] | 'b1) : (smi_cap[0] & 'b0);

            write_data = (smi_cap >> 1) & 1;
            write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUCCTRLR.ndn0Rx, write_data);
            trace_debug_scb::port_capture_en[1] = write_data ? (smi_cap[1] | 'b1) : (smi_cap[1] & 'b0);

            write_data = (smi_cap >> 2) & 1;
            write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUCCTRLR.ndn1Tx, write_data);
            trace_debug_scb::port_capture_en[2] = write_data ? (smi_cap[2] | 'b1) : (smi_cap[2] & 'b0);

            write_data = (smi_cap >> 3) & 1;
            write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUCCTRLR.ndn1Rx, write_data);
            trace_debug_scb::port_capture_en[3] = write_data ? (smi_cap[3] | 'b1) : (smi_cap[3] & 'b0);

            write_data = (smi_cap >> 4) & 1;
            write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUCCTRLR.ndn2Tx, write_data);
            trace_debug_scb::port_capture_en[4] = write_data ? (smi_cap[4] | 'b1) : (smi_cap[4] & 'b0);

            write_data = (smi_cap >> 5) & 1;
            write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUCCTRLR.ndn2Rx, write_data);
            trace_debug_scb::port_capture_en[5] = write_data ? (smi_cap[5] | 'b1) : (smi_cap[5] & 'b0);

            write_data = (smi_cap >> 6) & 1;
            write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUCCTRLR.dn0Tx , write_data);
            trace_debug_scb::port_capture_en[6] = write_data ? (smi_cap[6] | 'b1) : (smi_cap[6] & 'b0);

            write_data = (smi_cap >> 7) & 1;
            write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUCCTRLR.dn0Rx , write_data);
            trace_debug_scb::port_capture_en[7] = write_data ? (smi_cap[7] | 'b1) : (smi_cap[7] & 'b0);

            write_data = gain;
            write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUCCTRLR.gain  , write_data);
            trace_debug_scb::gain = write_data;

            write_data = inc;
            write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUCCTRLR.inc   , write_data);
            trace_debug_scb::inc = write_data;

        end : tcap_reg_prog_en_code


      end //wrong_DtwDbg_rsp_target_id 

      ev.trigger();

      if ($test$plusargs("str_req_err_inj")) begin 

        @(posedge m_smi<%=smi_portid_strreq%>_tx_vif.clk);
        err_inj_ev.wait_ptrigger();

        errinfo[19:8] = m_smi<%=smi_portid_strreq%>_tx_vif.smi_src_id[WSMISRCID-1:WSMINCOREPORTID];
        errinfo[7:1] = 0;
        errinfo[0] = 1'b1; //1 for smi_protection 
        //errinfo_check = 0;
        //erraddr_check = 0;
      end

      if ($test$plusargs("DtwDbg_rsp_err_inj")) begin
 
        @(posedge m_smi<%=smi_portid_dtwdbgrsp%>_tx_vif.clk);
        err_inj_ev.wait_ptrigger();

        errinfo[19:8] = m_smi<%=smi_portid_dtwdbgrsp%>_tx_vif.smi_src_id[WSMISRCID-1:WSMINCOREPORTID];
        errinfo[0] = 1'b1; //1 for smi_protection 
        //errinfo_check = 0;
       // erraddr_check = 0;
      end //wrong_DtwDbg_rsp_target_id

      if ($test$plusargs("dtr_req_err_inj")) begin 

        @(posedge m_smi<%=smi_portid_dtrreq%>_tx_vif.clk);
        err_inj_ev.wait_ptrigger();

        errinfo[19:8] = m_smi<%=smi_portid_dtrreq%>_tx_vif.smi_src_id[WSMISRCID-1:WSMINCOREPORTID];
        errinfo[7:1] = 0;
        errinfo[0] = 1'b1; //1 for smi_protection
        //errinfo_check = 0;
        //erraddr_check = 0;
      end

      if ($test$plusargs("snp_req_err_inj")) begin 

        @(posedge m_smi<%=smi_portid_snpreq%>_tx_vif.clk);
        err_inj_ev.wait_ptrigger();

        errinfo[19:8] = m_smi<%=smi_portid_snpreq%>_tx_vif.smi_src_id[WSMISRCID-1:WSMINCOREPORTID];
        errinfo[7:1] = 0;
        errinfo[0] = 1'b1; //1 for smi_protection
        //errinfo_check = 1;
        //erraddr_check = 1;
      end

      if ($test$plusargs("nccmd_rsp_err_inj")) begin 

        @(posedge m_smi<%=smi_portid_cmdrsp%>_tx_vif.clk);
        err_inj_ev.wait_ptrigger();

        errinfo[19:8] = m_smi<%=smi_portid_cmdrsp%>_tx_vif.smi_src_id[WSMISRCID-1:WSMINCOREPORTID];
        errinfo[7:1] = 0;
        errinfo[0] = 1'b1; //1 for smi_protection
        //errinfo_check = 1;
        //erraddr_check = 0;
      end
      if ($test$plusargs("ccmd_rsp_err_inj")) begin 

        @(posedge m_smi<%=smi_portid_cmdrsp%>_tx_vif.clk);
        err_inj_ev.wait_ptrigger();

        errinfo[19:8] = m_smi<%=smi_portid_cmdrsp%>_tx_vif.smi_src_id[WSMISRCID-1:WSMINCOREPORTID];
        errinfo[7:1] = 0;
        errinfo[0] = 1'b1; //1 for smi_protection
        //errinfo_check = 1;
        //erraddr_check = 0;
      end

      if ($test$plusargs("dtw_rsp_err_inj")) begin 

        @(posedge m_smi<%=smi_portid_dtwrsp%>_tx_vif.clk);
        err_inj_ev.wait_ptrigger();

        errinfo[19:8] = m_smi<%=smi_portid_dtwrsp%>_tx_vif.smi_src_id[WSMISRCID-1:WSMINCOREPORTID];
        errinfo[7:1] = 0;
        errinfo[0] = 1'b1; //1 for smi_protection
        //errinfo_check = 1;
        //erraddr_check = 0;
      end

      if ($test$plusargs("cmp_rsp_err_inj")) begin 

        @(posedge m_smi<%=smi_portid_cmprsp%>_tx_vif.clk);
        err_inj_ev.wait_ptrigger();

        errinfo[19:8] = m_smi<%=smi_portid_cmprsp%>_tx_vif.smi_src_id[WSMISRCID-1:WSMINCOREPORTID];
        errinfo[7:1] = 0;
        errinfo[0] = 1'b1; //1 for smi_protection
        //errinfo_check = 1;
        //erraddr_check = 0;
      end

      if ($test$plusargs("wrong_DtwDbg_rsp_target_id")) begin
        if ($test$plusargs("ttrig_reg_prog_en")) begin
            csr_trace_debug_done.trigger(null);
        end
        do
          @(posedge m_smi<%=smi_portid_dtwdbgrsp%>_tx_vif.clk);
        while ((m_smi<%=smi_portid_dtwdbgrsp%>_tx_vif.smi_msg_valid === 1'b0 || m_smi<%=smi_portid_dtwdbgrsp%>_tx_vif.smi_msg_ready === 1'b0) || (smi_seq_item::type2class(m_smi<%=smi_portid_dtwdbgrsp%>_tx_vif.smi_msg_type) != eConcMsgDtwDbgRsp && smi_seq_item::type2class(m_smi<%=smi_portid_dtwdbgrsp%>_tx_vif.smi_msg_type) != eConcMsgDtwDbgRsp) || (m_smi<%=smi_portid_dtwdbgrsp%>_tx_vif.smi_targ_id[WSMITGTID-1:WSMINCOREPORTID] == <%=obj.AiuInfo[obj.Id].FUnitId%>));
        errinfo[19:8] = m_smi<%=smi_portid_dtwdbgrsp%>_tx_vif.smi_src_id[WSMISRCID-1:WSMINCOREPORTID];
        //errinfo[5:1] = Resereved;
        errinfo[0] = 1'b0; //0 for wrong targ_id
        errinfo_check = 1;
        erraddr_check = 0;
      end //wrong_DtwDbg_rsp_target_id

      if ($test$plusargs("wrong_cmdrsp_target_id")) begin //#Stimulus.CHIAIU.transporterr.v3.cmdrsp
        do
          @(posedge m_smi<%=smi_portid_cmdrsp%>_tx_vif.clk);
        while ((m_smi<%=smi_portid_cmdrsp%>_tx_vif.smi_msg_valid === 1'b0 || m_smi<%=smi_portid_cmdrsp%>_tx_vif.smi_msg_ready === 1'b0) || (smi_seq_item::type2class(m_smi<%=smi_portid_cmdrsp%>_tx_vif.smi_msg_type) != eConcMsgCCmdRsp && smi_seq_item::type2class(m_smi<%=smi_portid_cmdrsp%>_tx_vif.smi_msg_type) != eConcMsgNcCmdRsp) || (m_smi<%=smi_portid_cmdrsp%>_tx_vif.smi_targ_id[WSMITGTID-1:WSMINCOREPORTID] == <%=obj.AiuInfo[obj.Id].FUnitId%>));
        errinfo[19:8] = m_smi<%=smi_portid_cmdrsp%>_tx_vif.smi_src_id[WSMISRCID-1:WSMINCOREPORTID];
        //errinfo[5:1] = Resereved;
        errinfo[0] = 1'b0; //0 for wrong targ_id
        errinfo_check = 1;
        erraddr_check = 0;
      end
      if ($test$plusargs("wrong_dtwrsp_target_id")) begin //#Stimulus.CHIAIU.transporterr.v3.dtwrsp
        do
          @(posedge m_smi<%=smi_portid_dtwrsp%>_tx_vif.clk);
        while ((m_smi<%=smi_portid_dtwrsp%>_tx_vif.smi_msg_valid === 1'b0 || m_smi<%=smi_portid_dtwrsp%>_tx_vif.smi_msg_ready === 1'b0) || (smi_seq_item::type2class(m_smi<%=smi_portid_dtwrsp%>_tx_vif.smi_msg_type) != eConcMsgDtwRsp) || (m_smi<%=smi_portid_dtwrsp%>_tx_vif.smi_targ_id[WSMITGTID-1:WSMINCOREPORTID] == <%=obj.AiuInfo[obj.Id].FUnitId%>));
        errinfo[19:8] = m_smi<%=smi_portid_dtwrsp%>_tx_vif.smi_src_id[WSMISRCID-1:WSMINCOREPORTID];
        //errinfo[5:1] = Resereved;
        errinfo[0] = 1'b0; //0 for wrong targ_id
        errinfo_check = 1;
        erraddr_check = 0;
      end
      if ($test$plusargs("wrong_dtrrsp_target_id")) begin //#Stimulus.CHIAIU.transporterr.v3.dtrrsp
        do
          @(posedge m_smi<%=smi_portid_dtrrsp%>_tx_vif.clk);
        while ((m_smi<%=smi_portid_dtrrsp%>_tx_vif.smi_msg_valid === 1'b0 || m_smi<%=smi_portid_dtrrsp%>_tx_vif.smi_msg_ready === 1'b0) || (smi_seq_item::type2class(m_smi<%=smi_portid_dtrrsp%>_tx_vif.smi_msg_type) != eConcMsgDtrRsp) || (m_smi<%=smi_portid_dtrrsp%>_tx_vif.smi_targ_id[WSMITGTID-1:WSMINCOREPORTID] == <%=obj.AiuInfo[obj.Id].FUnitId%>));
        errinfo[19:8] = m_smi<%=smi_portid_dtrrsp%>_tx_vif.smi_src_id[WSMISRCID-1:WSMINCOREPORTID];
        //errinfo[5:1] = Resereved;
        errinfo[0] = 1'b0; //0 for wrong targ_id
        errinfo_check = 1;
        erraddr_check = 0;
      end
      if ($test$plusargs("wrong_dtrreq_target_id")) begin //#Stimulus.CHIAIU.transporterr.v3.dtrreq
        do
          @(posedge m_smi<%=smi_portid_dtrreq%>_tx_vif.clk);
        while ((m_smi<%=smi_portid_dtrreq%>_tx_vif.smi_msg_valid === 1'b0 || m_smi<%=smi_portid_dtrreq%>_tx_vif.smi_msg_ready === 1'b0) || (smi_seq_item::type2class(m_smi<%=smi_portid_dtrreq%>_tx_vif.smi_msg_type) != eConcMsgDtrReq) || (m_smi<%=smi_portid_dtrreq%>_tx_vif.smi_targ_id[WSMITGTID-1:WSMINCOREPORTID] == <%=obj.AiuInfo[obj.Id].FUnitId%>));
        errinfo[19:8] = m_smi<%=smi_portid_dtrreq%>_tx_vif.smi_src_id[WSMISRCID-1:WSMINCOREPORTID];
        //errinfo[5:1] = Resereved;
        errinfo[0] = 1'b0; //0 for wrong targ_id
        errinfo_check = 1;
        erraddr_check = 0;
      end
      if ($test$plusargs("wrong_sysreq_target_id")) begin
        do
          @(posedge m_smi<%=smi_portid_sysreq%>_tx_vif.clk);
        while ((m_smi<%=smi_portid_sysreq%>_tx_vif.smi_msg_valid === 1'b0 || m_smi<%=smi_portid_sysreq%>_tx_vif.smi_msg_ready === 1'b0) || (smi_seq_item::type2class(m_smi<%=smi_portid_sysreq%>_tx_vif.smi_msg_type) != eConcMsgSysReq) || (m_smi<%=smi_portid_sysreq%>_tx_vif.smi_targ_id[WSMITGTID-1:WSMINCOREPORTID] == <%=obj.AiuInfo[obj.Id].FUnitId%>));
        errinfo[19:8] = m_smi<%=smi_portid_sysreq%>_tx_vif.smi_src_id[WSMISRCID-1:WSMINCOREPORTID];
        //errinfo[5:1] = Resereved;
        errinfo[0] = 1'b0; //0 for wrong targ_id
        errinfo_check = 1;
        erraddr_check = 0;
      end
      if ($test$plusargs("wrong_strreq_target_id")) begin //#Stimulus.CHIAIU.transporterr.v3.strreq
        do
          @(posedge m_smi<%=smi_portid_strreq%>_tx_vif.clk);
        while ((m_smi<%=smi_portid_strreq%>_tx_vif.smi_msg_valid === 1'b0 || m_smi<%=smi_portid_strreq%>_tx_vif.smi_msg_ready === 1'b0) || (smi_seq_item::type2class(m_smi<%=smi_portid_strreq%>_tx_vif.smi_msg_type) != eConcMsgStrReq) || (m_smi<%=smi_portid_strreq%>_tx_vif.smi_targ_id[WSMITGTID-1:WSMINCOREPORTID] == <%=obj.AiuInfo[obj.Id].FUnitId%>));
        errinfo[19:8] = m_smi<%=smi_portid_strreq%>_tx_vif.smi_src_id[WSMISRCID-1:WSMINCOREPORTID];
        //errinfo[5:1] = Resereved;
        errinfo[0] = 1'b0; //0 for wrong targ_id
        errinfo_check = 1;
        erraddr_check = 0;
      end
      if ($test$plusargs("wrong_snpreq_target_id")) begin //#Stimulus.CHIAIU.transporterr.v3.snpreq
        do begin
          @(posedge m_smi<%=smi_portid_snpreq%>_tx_vif.clk);
        end while ((m_smi<%=smi_portid_snpreq%>_tx_vif.smi_msg_valid === 1'b0 || m_smi<%=smi_portid_snpreq%>_tx_vif.smi_msg_ready === 1'b0) || (smi_seq_item::type2class(m_smi<%=smi_portid_snpreq%>_tx_vif.smi_msg_type) != eConcMsgSnpReq) || (m_smi<%=smi_portid_snpreq%>_tx_vif.smi_targ_id[WSMITGTID-1:WSMINCOREPORTID] == <%=obj.AiuInfo[obj.Id].FUnitId%>));
        errinfo[19:8] = m_smi<%=smi_portid_snpreq%>_tx_vif.smi_src_id[WSMISRCID-1:WSMINCOREPORTID];
        //errinfo[5:1] = Resereved;
        errinfo[0] = 1'b0; //0 for wrong targ_id
        exp_addr = m_smi<%=smi_portid_snpreq%>_tx_vif.smi_ndp[SNP_REQ_ADDR_MSB:SNP_REQ_ADDR_LSB];
        errinfo_check = 1;
        erraddr_check = 1;
      end
      if ($test$plusargs("wrong_sysrsp_target_id")) begin
        do
          @(posedge m_smi<%=smi_portid_sysrsp%>_tx_vif.clk);
        while ((m_smi<%=smi_portid_sysrsp%>_tx_vif.smi_msg_valid === 1'b0 || m_smi<%=smi_portid_sysrsp%>_tx_vif.smi_msg_ready === 1'b0) || (smi_seq_item::type2class(m_smi<%=smi_portid_sysrsp%>_tx_vif.smi_msg_type) != eConcMsgSysRsp) || (m_smi<%=smi_portid_sysrsp%>_tx_vif.smi_targ_id[WSMITGTID-1:WSMINCOREPORTID] == <%=obj.AiuInfo[obj.Id].FUnitId%>));
        errinfo[19:8] = m_smi<%=smi_portid_sysrsp%>_tx_vif.smi_src_id[WSMISRCID-1:WSMINCOREPORTID];
        //errinfo[5:1] = Resereved;
        errinfo[0] = 1'b0; //0 for wrong targ_id
        errinfo_check = 1;
        erraddr_check = 0;
      end
      `uvm_info(get_full_name(),$sformatf("errinfo = %0h, exp_addr = %0h", errinfo, exp_addr),UVM_DEBUG)
      if(dis_uedr_ted_4resiliency) begin
        `uvm_info(get_full_name(),$sformatf("Skipping enabling of error detection inside xUEDR"),UVM_NONE)
      end
      else begin
      //keep on  Reading the CAIUUESR_ErrVld bit = 1
      poll_CAIUUESR_ErrVld(1, poll_data);
      //TODO: Need to enable below fork-join_any block when interrupt interface is available   
      fork
        begin
            wait (u_csr_probe_vif.IRQ_UC === 1);
            uvm_config_db#(int)::set(null,"*","chi_irq_uc",1); //for coverage
        end
        begin
          #200000ns;
          `uvm_error(get_name(),$sformatf("Timeout! Did not see IRQ_UC asserted"));
        end
      join_any
      disable fork;

      read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUUESR.ErrType, read_data);
      compareValues("CAIUUESR_ErrType","Valid Type", read_data, errtype);
      if (errinfo_check) begin
        read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUUESR.ErrInfo, read_data);
        compareValues("CAIUUESR_ErrInfo","Valid Type", read_data, errinfo);
      end
      if (erraddr_check) begin
        //Disabled address check as per CONC-6294
        //read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUUELR0.ErrEntry, read_data);
        //err_entry = read_data;
        //read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUUELR0.ErrWay, read_data);
        //err_way = read_data;
        //read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUUELR0.ErrWord, read_data);
        //err_word = read_data;
        //read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUUELR1.ErrAddr, read_data);
        //err_addr = read_data;
        //actual_addr = {err_addr,err_word,err_way,err_entry};
        //if (actual_addr !== exp_addr) begin
        //          `uvm_error(get_full_name(),$sformatf("received addr = 0x%0x didn't match with expected addr = 0x%0x",actual_addr, exp_addr))
        //end
      end

      write_data = 0;
      write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUUEDR.TransErrDetEn, write_data);
      write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUUEIR.TransErrIntEn, write_data);
      write_data = 1;
      write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUUESR.ErrVld, write_data);
      read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUUESR.ErrVld, read_data); 
      compareValues("CAIUUESR_ErrVld","should be", read_data, 0);
      end
    endtask
endclass : chi_aiu_csr_caiuuedr_TransErrDetEn_seq

class chi_aiu_csr_caiucecr_TransErrDetEn_seq extends chi_aiu_ral_csr_base_seq; 
  `uvm_object_utils(chi_aiu_csr_caiucecr_TransErrDetEn_seq)

    uvm_reg_data_t poll_data, read_data, read_data2, write_data;
    bit [7:0]  errthd;
    bit [3:0]  errtype;
    bit [15:0] errinfo;
    bit [51:0] exp_addr;
    bit [51:0] actual_addr;
    bit [19:0] err_addr;
    bit        errinfo_check, erraddr_check;
    int        errcount_vld, errthd_vld;
    int        errcount_ovf;

    function new(string name="");
        super.new(name);
    endfunction

    task body();
      bit dis_uedr_ted_4resiliency = $test$plusargs("dis_uedr_ted_4resiliency") ? 1 : 0;
      getSMIIf();
      getCsrProbeIf();

      if(dis_uedr_ted_4resiliency) begin
        `uvm_info(get_full_name(),$sformatf("Skipping-0 enabling of error detection inside xUEDR"),UVM_NONE)
      end
      else begin
      errtype = 4'h8;
      write_data = 1;
      write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUCECR.ErrDetEn, write_data);
      write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUCECR.ErrIntEn, write_data);
      ev.trigger();

	if ($test$plusargs("ccmd_rsp_err_inj")) begin

        @(posedge m_smi<%=smi_portid_cmdrsp%>_tx_vif.clk);
        err_inj_ev.wait_ptrigger();

        errinfo[15:6] = m_smi<%=smi_portid_cmdrsp%>_tx_vif.smi_src_id[WSMISRCID-1:WSMINCOREPORTID];
        errinfo[5:0] = 6'b0; 
        errinfo_check = 1;
        end


        if ($test$plusargs("nccmd_rsp_err_inj")) begin

        @(posedge m_smi<%=smi_portid_cmdrsp%>_tx_vif.clk);
        err_inj_ev.wait_ptrigger();

        errinfo[15:6] = m_smi<%=smi_portid_cmdrsp%>_tx_vif.smi_src_id[WSMISRCID-1:WSMINCOREPORTID];
        errinfo[5:0] = 6'b0; 
        errinfo_check = 1;
        end

       if ($test$plusargs("snp_req_err_inj")) begin

        @(posedge m_smi<%=smi_portid_snpreq%>_tx_vif.clk);
        err_inj_ev.wait_ptrigger();

        errinfo[15:6] = m_smi<%=smi_portid_snpreq%>_tx_vif.smi_src_id[WSMISRCID-1:WSMINCOREPORTID];
        errinfo[5:0] = 6'b0; 
        errinfo_check = 1;
       end

       if ($test$plusargs("str_req_err_inj")) begin

        @(posedge m_smi<%=smi_portid_strreq%>_tx_vif.clk);
        err_inj_ev.wait_ptrigger();

        errinfo[15:6] = m_smi<%=smi_portid_strreq%>_tx_vif.smi_src_id[WSMISRCID-1:WSMINCOREPORTID];
        errinfo[5:0] = 6'b0; 
        errinfo_check = 1;       
       end

       if ($test$plusargs("dtr_req_err_inj")) begin

        @(posedge m_smi<%=smi_portid_dtrreq%>_tx_vif.clk);
        err_inj_ev.wait_ptrigger();

        errinfo[15:6] = m_smi<%=smi_portid_dtrreq%>_tx_vif.smi_src_id[WSMISRCID-1:WSMINCOREPORTID];
        errinfo[5:0] = 6'b0; 
        errinfo_check = 1;
       end

      if ($test$plusargs("cmp_rsp_err_inj")) begin

        @(posedge m_smi<%=smi_portid_cmprsp%>_tx_vif.clk);
        err_inj_ev.wait_ptrigger();

        errinfo[15:6] = m_smi<%=smi_portid_cmprsp%>_tx_vif.smi_src_id[WSMISRCID-1:WSMINCOREPORTID];
        errinfo[5:0] = 6'b0; 
     end

     if ($test$plusargs("dtw_rsp_err_inj")) begin

        @(posedge m_smi<%=smi_portid_dtwrsp%>_tx_vif.clk);
        err_inj_ev.wait_ptrigger();

        errinfo[15:6] = m_smi<%=smi_portid_dtwrsp%>_tx_vif.smi_src_id[WSMISRCID-1:WSMINCOREPORTID];
        errinfo[5:0] = 6'b0; 
        errinfo_check = 1;
     end
 end

     `uvm_info(get_full_name(),$sformatf("errinfo = %0h, exp_addr = %0h", errinfo, exp_addr),UVM_DEBUG)
      if(dis_uedr_ted_4resiliency) begin
        `uvm_info(get_full_name(),$sformatf("Skipping-1 enabling of error detection inside xUEDR"),UVM_NONE)
      end
      else begin
      poll_CAIUCESR_ErrVld(1, poll_data);
         fork
           begin
               wait (u_csr_probe_vif.IRQ_C === 1);
           end
           begin
              #200000ns;
              `uvm_error(get_full_name(),$sformatf("Timeout! Did not see IRQ_C asserted"));
           end
         join_any
      disable fork;

      read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUCESR.ErrType, read_data);
      compareValues("CAIUCESR_ErrType","Valid Type", read_data, errtype);
      if (errinfo_check) begin
        read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUCESR.ErrInfo, read_data);
        compareValues("CAIUCESR_ErrInfo","Valid Info", read_data, errinfo);
      end
      if (erraddr_check) begin
        //Disabled address check as per CONC-6294
      end
      write_data = 0;
      write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUCECR.ErrDetEn, write_data);
      write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUCECR.ErrIntEn, write_data);
      write_data = 1;
      write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUCESR.ErrVld, write_data);
      read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUCESR.ErrCount, read_data); 
      compareValues("CAIUCESR_ErrVld","should be", read_data, 0);
     end
   endtask

endclass : chi_aiu_csr_caiucecr_TransErrDetEn_seq

class chi_aiu_csr_no_address_hit_seq extends chi_aiu_ral_csr_base_seq;  //#Check.CHIAIU.v3.Error.decodeerr 
  `uvm_object_utils(chi_aiu_csr_no_address_hit_seq)

    uvm_reg_data_t poll_data, read_data, write_data;
    bit [WSMIADDR-1:0] exp_addr;
    bit [WSMIADDR-1:0] erraddr_q[$];
    bit [51:0]actual_addr;
    bit [31:0] err_addr0;
    bit [19:0] err_addr;
    bit [19:0] exp_errinfo;
    bit [19:0] errinfo_q[$];

    function new(string name="");
        super.new(name);
    endfunction

    task body();
        getsb_handle();
        getCsrProbeIf();

        // Set the CAIUUEDR_ErrDetEn = 1
        write_data = 1;
        write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUUEDR.DecErrDetEn, write_data); 
        write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUUEIR.DecErrIntEn, write_data);

        ev.trigger();
        //keep on  Reading the CAIUUESR_ErrVld bit = 1
        poll_CAIUUESR_ErrVld(1, poll_data);
        foreach (chi_scb.csr_addr_decode_err_addr_q[i]) begin
          exp_addr = chi_scb.csr_addr_decode_err_addr_q[i];
          exp_errinfo[19:8] = chi_scb.csr_addr_decode_err_msg_id_q[i];
          exp_errinfo[4] = chi_scb.csr_addr_decode_err_cmd_type_q[i];
          exp_errinfo[3:0] = 4'b0000;
          errinfo_q.push_back(exp_errinfo);
          erraddr_q.push_back(exp_addr);
        end
        `uvm_info(get_full_name(),$sformatf("erraddr_q = %0p, errinfo_q = %0p",erraddr_q,errinfo_q),UVM_NONE)
        read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUUESR.ErrInfo, read_data);
        uvm_config_db#(int)::set(null,"*","chi_dec_err_type",read_data); //for coverage
        if (!(read_data inside {errinfo_q})) begin
          `uvm_error(get_full_name(),$sformatf("Expected error info should be inside %0p, Actual ErrInfo = %0h",errinfo_q,read_data))
        end
        read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUUESR.ErrType, read_data);
        uvm_config_db#(int)::set(null,"*","chi_errtype_code",read_data); //for coverage
        compareValues("CAIUUESR_ErrType", "", read_data, 7);
        //read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUUELR0.ErrEntry, read_data);
        //err_entry = read_data;
        //read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUUELR0.ErrWay, read_data);
        //err_way = read_data;
        //read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUUELR0.ErrWord, read_data);
        //err_word = read_data;
        read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUUELR0.ErrAddr, read_data);
        err_addr0 = read_data;
        read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUUELR1.ErrAddr, read_data);
        err_addr = read_data;
        actual_addr = {err_addr,err_addr0};
        if (!(actual_addr inside {erraddr_q})) begin
                `uvm_error(get_full_name(),$sformatf("Expected ErrAdd inside %0p, Actual ErrAddr = %0h",erraddr_q, actual_addr))
        end
        fork
            begin
                wait (u_csr_probe_vif.IRQ_UC === 1);
                uvm_config_db#(int)::set(null,"*","chi_irq_uc",u_csr_probe_vif.IRQ_UC); //for coverage
            end
            begin
              #200000ns;
              `uvm_error(get_name(),$sformatf("Timeout! Did not see IRQ_UC asserted"));
            end
        join_any
        disable fork;

        write_data = 0;
        write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUUEDR.DecErrDetEn, write_data); 
        write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUUEIR.DecErrIntEn, write_data);
        write_data = 1;
        write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUUESR.ErrVld, write_data);
        // Read the CAIUUESR_ErrVld should be cleared
        read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUUESR.ErrVld, read_data);
        compareValues("CAIUUESR_ErrVld", "now clear", read_data, 0);

    endtask
endclass : chi_aiu_csr_no_address_hit_seq

class chi_aiu_csr_address_region_overlap_seq extends chi_aiu_ral_csr_base_seq;//#Check.CHIAIU.v3.Error.decodeerr //#Check.CHIAIU.v3.Error.multipleaddr 
  `uvm_object_utils(chi_aiu_csr_address_region_overlap_seq)

    uvm_reg_data_t poll_data, read_data, write_data;
    bit [WSMIADDR-1:0] exp_addr;
    bit [WSMIADDR-1:0] erraddr_q[$];
    bit [51:0]actual_addr;
    bit [31:0] err_addr0;
    bit [19:0] err_addr;
    bit [19:0] exp_errinfo;
    bit [19:0] errinfo_q[$];
    bit [19:0] exp_errinfo_tmp;
    int ndmi = 1;

    bit [ncoreConfigInfo::W_SEC_ADDR -1:0] laddr;
    bit [ncoreConfigInfo::W_SEC_ADDR -1:0] uaddr;
    bit [ncoreConfigInfo::W_SEC_ADDR -1:0] random_cfg_addr_coh;
    bit [ncoreConfigInfo::W_SEC_ADDR -1:0] random_cfg_addr_noncoh;
    int selected_addr_map_index;

    function new(string name="");
        super.new(name);
    endfunction

    task body();
        ncoreConfigInfo::sys_addr_csr_t csrq[$];
        uvm_reg_data_t write_data;
        getsb_handle();
        getCsrProbeIf();

        csrq = ncoreConfigInfo::get_all_gpra();
        foreach (csrq[i]) begin
          `uvm_info(get_name(),
              $psprintf("unit: %s hui:%0d low-addr:0x0%h up-addr: 0x%0h sz:%0d",
                  csrq[i].unit.name(), csrq[i].mig_nunitid,
                  csrq[i].low_addr, csrq[i].upp_addr, csrq[i].size),
              UVM_NONE) 
          if (csrq[i].unit == ncoreConfigInfo::DMI && (ncoreConfigInfo::user_addrq[ncoreConfigInfo::COH].size() == 0 || ncoreConfigInfo::user_addrq[ncoreConfigInfo::NONCOH].size() == 0)) begin
            ndmi = ncoreConfigInfo::intrlvgrp_vector[ncoreConfigInfo::picked_dmi_igs][csrq[i].mig_nunitid];
            laddr = ({csrq[i].upp_addr,csrq[i].low_addr} << 12);
            uaddr = laddr + ndmi * (1 << (csrq[i].size + 12));
            std::randomize(random_cfg_addr_coh) with {random_cfg_addr_coh inside {[laddr:uaddr]};};
            do begin
              std::randomize(random_cfg_addr_noncoh) with {random_cfg_addr_noncoh inside {[laddr:uaddr]};};
            end while (random_cfg_addr_noncoh == random_cfg_addr_coh);
            ncoreConfigInfo::user_addrq[ncoreConfigInfo::COH].push_back(random_cfg_addr_coh);
            ncoreConfigInfo::user_addrq[ncoreConfigInfo::NONCOH].push_back(random_cfg_addr_noncoh);
            selected_addr_map_index = i;
            `uvm_info(get_full_name(),$sformatf("random_cfg_addr_coh = %0h, random_cfg_addr_noncoh = %0h",random_cfg_addr_coh,random_cfg_addr_noncoh),UVM_NONE);
          end
          ndmi = 1;
        end

        // Set the CAIUUEDR_ErrDetEn = 1
        write_data = 1;
        write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUUEDR.DecErrDetEn, write_data); 
        write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUUEIR.DecErrIntEn, write_data);

<% for(var i = 0; i < obj.DutInfo.nGPRA; i++) { %>
        write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUGPRBLR<%=i%>.AddrLow, csrq[selected_addr_map_index].low_addr);
        write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUGPRBHR<%=i%>.AddrHigh, csrq[selected_addr_map_index].upp_addr);
        write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUGPRAR<%=i%>.Size, csrq[selected_addr_map_index].size);
 //       write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUGPRAR<%=i%>.DIGId, 0);
        write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUGPRAR<%=i%>.Valid, 1);
        write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUGPRAR<%=i%>.HUI, csrq[<%=i%>].mig_nunitid);
        write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUGPRAR<%=i%>.HUT, csrq[<%=i%>].unit == ncoreConfigInfo::DII ? 2'b10 : 2'b00);
<% } %>
        ev.trigger();
        //keep on  Reading the CAIUUESR_ErrVld bit = 1
        poll_CAIUUESR_ErrVld(1, poll_data);
        foreach (chi_scb.csr_addr_decode_err_addr_q[i]) begin
          exp_addr = chi_scb.csr_addr_decode_err_addr_q[i];
          exp_errinfo[19:8] = chi_scb.csr_addr_decode_err_msg_id_q[i];
          exp_errinfo[4] = chi_scb.csr_addr_decode_err_cmd_type_q[i];
          exp_errinfo[3:0] = 4'b0001;
          errinfo_q.push_back(exp_errinfo);
          erraddr_q.push_back(exp_addr);
        end
        `uvm_info(get_full_name(),$sformatf("erraddr_q = %0p, errinfo_q = %0p",erraddr_q,errinfo_q),UVM_NONE)
        read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUUESR.ErrInfo, read_data);
        uvm_config_db#(int)::set(null,"*","chi_dec_err_type",read_data); //for coverage
        if (!(read_data inside {errinfo_q})) begin
          `uvm_error(get_full_name(),$sformatf("Expected ErrInfo inside %0p, Actual ErrInfo = %0h",errinfo_q,read_data))
        end
        read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUUESR.ErrType, read_data);
        uvm_config_db#(int)::set(null,"*","chi_errtype_code",read_data); //for coverage
        compareValues("CAIUUESR_ErrType", "", read_data, 7);
        //read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUUELR0.ErrEntry, read_data);
        //err_entry = read_data;
        //read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUUELR0.ErrWay, read_data);
        //err_way = read_data;
        //read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUUELR0.ErrWord, read_data);
        //err_word = read_data;
        read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUUELR0.ErrAddr, read_data);
        err_addr0 = read_data;
        read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUUELR1.ErrAddr, read_data);
        err_addr = read_data;
        actual_addr = {err_addr,err_addr0};
        if (!(actual_addr inside {erraddr_q})) begin
                `uvm_error(get_full_name(),$sformatf("Expected ErrAdd inside %0p, Actual ErrAddr = %0h",erraddr_q, actual_addr))
        end
        fork
            begin
                wait (u_csr_probe_vif.IRQ_UC === 1);
                uvm_config_db#(int)::set(null,"*","chi_irq_uc",u_csr_probe_vif.IRQ_UC); //for coverage
            end
            begin
              #200000ns;
              `uvm_error(get_name(),$sformatf("Timeout! Did not see IRQ_UC asserted"));
            end
        join_any
        disable fork;

        write_data = 0;
        write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUUEDR.DecErrDetEn, write_data); 
        write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUUEIR.DecErrIntEn, write_data);
        write_data = 1;
        write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUUESR.ErrVld, write_data);
        // Read the CAIUUESR_ErrVld should be cleared
        read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUUESR.ErrVld, read_data);
        compareValues("CAIUUESR_ErrVld", "now clear", read_data, 0);

    endtask
endclass : chi_aiu_csr_address_region_overlap_seq

class chi_aiu_csr_scm_seq extends chi_aiu_ral_csr_base_seq; 
  `uvm_object_utils(chi_aiu_csr_scm_seq)

    uvm_reg_data_t poll_data, read_data, write_data;
    uvm_status_e           status;
    bit [7:0]  errthd;
    int        errcount_vld, errthd_vld;
    int        i,j;
    bit [WSMIADDR-1:0] exp_addr;
    bit [WSMIADDR-1:0] erraddr_q[$];
    bit [3:0] expected_err_type = 'hC;
    bit [51:0]actual_addr;
    bit [31:0] err_addr0;
    bit [19:0] err_addr;
    bit [19:0] exp_errinfo;
    bit [19:0] errinfo_q[$];
    bit [19:0] exp_errinfo_tmp;
    bit pause_main_traffic;

    int dce_credit[];
    int dmi_credit[];
    int dii_credit[];

    int csr_dce_credit;
    int csr_dmi_credit;
    int csr_dii_credit;

    int dce_credit_zero;
    int dmi_credit_zero;
    int dii_credit_zero;

    function new(string name="");
        super.new(name);
    endfunction

    task body();
           getsb_handle();
           getCsrProbeIf();
           getSMIIf();

           dce_credit = new[<%=obj.nDCEs%>];
           dmi_credit = new[<%=obj.nDMIs%>];
           dii_credit = new[<%=obj.nDIIs%>];

          `uvm_info(get_full_name(),$sformatf("csr_credit_mgmt_seq_start"),UVM_HIGH)

           <%for (var j=0; j< obj.nDCEs; j++){%> 
           uvm_config_db#(int)::get(null,"*","check_dce_credit_limit_<%=j%>",csr_dce_credit);
           dce_credit[<%=j%>] = csr_dce_credit; 
           if  (dce_credit[<%=j%>] == 'h0) begin
               dce_credit_zero[<%=j%>] = 1; 
           end
           <%}%>

           <%for (var j=0; j< obj.nDMIs; j++){%> 
           uvm_config_db#(int)::get(null,"*","check_dmi_credit_limit_<%=j%>",csr_dmi_credit);
           dmi_credit[<%=j%>] = csr_dmi_credit; 
           if  (dmi_credit[<%=j%>] == 'h0) begin
               dmi_credit_zero[<%=j%>] = 1; 
           end
           <%}%>


           <%for (var j=0; j< obj.nDIIs; j++){%> 
           uvm_config_db#(int)::get(null,"*","check_dii_credit_limit_<%=j%>",csr_dii_credit);
           dii_credit[<%=j%>] = csr_dii_credit; 
           if  (dii_credit[<%=j%>] == 'h0) begin
               dii_credit_zero[<%=j%>] = 1; 
           end
           <%}%>

           if (($test$plusargs("zero_nonzero_crd_test"))) begin
               ncoreConfigInfo::dce_credit_zero = dce_credit_zero;
               ncoreConfigInfo::dmi_credit_zero = dmi_credit_zero;
               ncoreConfigInfo::dii_credit_zero = dii_credit_zero;

               write_data = 1;
               write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUUEDR.SoftwareProgConfigErrDetEn, write_data);//#Check.CHIAIU.v3.Error.decodeerr
               write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUUEIR.SoftwareProgConfigErrIntEn, write_data);

           end

           `uvm_info(get_full_name(),$sformatf("CSR_SCM : dce_crd_limit : %0p dmi_crd_limit : %0p dii_crd_limit : %0p",dce_credit,dmi_credit,dii_credit),UVM_HIGH)

              repeat(3000) @(posedge m_smi0_tx_vif.clk);


           <% for(var i = 0; i < obj.nDCEs; i++) { %>
           write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUCCR<%=i%>.DCECreditLimit, dce_credit[<%=i%>]);
           <% } %>

           <% for(var i = 0; i < obj.nDMIs; i++) { %>
           write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUCCR<%=i%>.DMICreditLimit, dmi_credit[<%=i%>]);
           <% } %>

           <% for(var i = 0; i < obj.nDIIs; i++) { %>
           write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUCCR<%=i%>.DIICreditLimit, dii_credit[<%=i%>]);
           <% } %>

           ev.trigger();
           //poll_CAIUCCR_DCE_negative_state(1,poll_data);

           if (($test$plusargs("zero_nonzero_crd_test"))) begin
               poll_CAIUUESR_ErrVld(1, poll_data);

               foreach (chi_scb.csr_addr_decode_err_addr_q[i]) begin
                 exp_addr = chi_scb.csr_addr_decode_err_addr_q[i];
                 //exp_errinfo[19:8] = chi_scb.csr_addr_decode_err_msg_id_q[i];
                 //exp_errinfo[4] = chi_scb.csr_addr_decode_err_cmd_type_q[i];
                 exp_errinfo[3:0] = 4'b0001;
                 errinfo_q.push_back(exp_errinfo);
                 erraddr_q.push_back(exp_addr);
               end

               `uvm_info(get_full_name(),$sformatf("erraddr_q = %0p, errinfo_q = %0p",erraddr_q,errinfo_q),UVM_NONE)
               read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUUESR.ErrInfo, read_data);
               uvm_config_db#(int)::set(null,"*","chi_soft_prog_err_type",read_data);//for coverage
               if (!(read_data inside {errinfo_q})) begin
                 `uvm_error(get_full_name(),$sformatf("Expected ErrInfo inside %0p, Actual ErrInfo = %0h",errinfo_q,read_data))
               end
               read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUUESR.ErrType, read_data);
               uvm_config_db#(int)::set(null,"*","chi_errtype_code",read_data); //for coverage
               compareValues("CAIUUESR_ErrType", "", read_data, expected_err_type);
               //read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUUELR0.ErrEntry, read_data);
               //err_entry = read_data;
               //read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUUELR0.ErrWay, read_data);
               //err_way = read_data;
               //read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUUELR0.ErrWord, read_data);
               //err_word = read_data;
               read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUUELR0.ErrAddr, read_data);
               err_addr0 = read_data;
               read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUUELR1.ErrAddr, read_data);
               err_addr = read_data;
               actual_addr = {err_addr,err_addr0};
               if (!(actual_addr inside {erraddr_q})) begin
                       `uvm_error(get_full_name(),$sformatf("Expected ErrAdd inside %0p, Actual ErrAddr = %0h",erraddr_q, actual_addr))
               end
           end



           if (($test$plusargs("zero_nonzero_crd_test"))) begin

               repeat(500) @(posedge m_smi0_tx_vif.clk);

               pause_main_traffic = 'h1;
               uvm_config_db#(int)::set(null,"*","pause_main_traffic",pause_main_traffic);
	           all_txn_done_ev.wait_ptrigger();

           <%for (var j=0; j< obj.nDCEs; j++){%> 
               if  (dce_credit_zero[<%=j%>] == 'h1) begin
                   dce_credit[<%=j%>] = $urandom_range(1,31);
                   if  (dce_credit[<%=j%>] != 'h0) begin
                       dce_credit_zero[<%=j%>] = 0; 
                   end
                   write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUCCR<%=j%>.DCECreditLimit, dce_credit[<%=j%>]);
                   ncoreConfigInfo::dce_credit_zero[<%=j%>] = dce_credit_zero[<%=j%>];
               end
           <%}%>

           <%for (var j=0; j< obj.nDMIs; j++){%> 
               if  (dmi_credit_zero[<%=j%>] == 'h1) begin
                   dmi_credit[<%=j%>] = $urandom_range(1,31);
                   if  (dmi_credit[<%=j%>] != 'h0) begin
                       dmi_credit_zero[<%=j%>] = 0; 
                   end
                   write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUCCR<%=j%>.DMICreditLimit, dmi_credit[<%=j%>]);
                   ncoreConfigInfo::dmi_credit_zero[<%=j%>] = dmi_credit_zero[<%=j%>];
               end
           <%}%>

           <% for(var j =0; j < obj.nDIIs; j++) { %>
               if  (dii_credit_zero[<%=j%>] == 'h1) begin
                   dii_credit[<%=j%>] = $urandom_range(1,31); 
                   if  (dii_credit[<%=j%>] != 'h0) begin
                       dii_credit_zero[<%=j%>] = 0; 
                   end
                   write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUCCR<%=j%>.DIICreditLimit,dii_credit[<%=j%>]);
                   ncoreConfigInfo::dii_credit_zero[<%=j%>] = dii_credit_zero[<%=j%>];
               end
           <% } %>

               repeat(20) @(posedge m_smi0_tx_vif.clk);
               pause_main_traffic = 'h0;
               uvm_config_db#(int)::set(null,"*","pause_main_traffic",pause_main_traffic);

             //  ncoreConfigInfo::dce_credit_zero = dce_credit_zero;
             //  ncoreConfigInfo::dmi_credit_zero = dmi_credit_zero;
             //  ncoreConfigInfo::dii_credit_zero = dii_credit_zero;


               fork
                   begin
                       wait (u_csr_probe_vif.IRQ_UC === 1);
                       uvm_config_db#(int)::set(null,"*","chi_irq_uc",u_csr_probe_vif.IRQ_UC); //for coverage
                   end
                   begin
                     #200000ns;
                     `uvm_error(get_name(),$sformatf("Timeout! Did not see IRQ_UC asserted"));
                   end
               join_any
               disable fork;

               write_data = 0;
               write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUUEDR.SoftwareProgConfigErrDetEn, write_data);
               write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUUEIR.SoftwareProgConfigErrIntEn, write_data);
               write_data = 1;
               write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUUESR.ErrVld, write_data);
               // Read the CAIUUESR_ErrVld should be cleared
               read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUUESR.ErrVld, read_data);
               compareValues("CAIUUESR_ErrVld", "now clear", read_data, 0);

           end else begin
               repeat(2000) @(posedge m_smi0_tx_vif.clk);
           end


           ev_update_crd.trigger();

    endtask

endclass : chi_aiu_csr_scm_seq

class chi_aiu_ral_addr_map_seq extends ral_csr_base_seq; 
  `uvm_object_utils(chi_aiu_ral_addr_map_seq)

    TRIG_TCTRLR_t tctrlr[<%=obj.DutInfo.nTraceRegisters%>];
    TRIG_TBALR_t  tbalr[<%=obj.DutInfo.nTraceRegisters%>];
    TRIG_TBAHR_t  tbahr[<%=obj.DutInfo.nTraceRegisters%>];
    TRIG_TOPCR0_t topcr0[<%=obj.DutInfo.nTraceRegisters%>];
    TRIG_TOPCR1_t topcr1[<%=obj.DutInfo.nTraceRegisters%>];
    TRIG_TUBR_t   tubr[<%=obj.DutInfo.nTraceRegisters%>];
    TRIG_TUBMR_t  tubmr[<%=obj.DutInfo.nTraceRegisters%>];


    TRIG_TCTRLR_t tctrlr_save[<%=obj.DutInfo.nTraceRegisters%>];
    int caiu_cctrlr_phase = 0;          // This variable is controlled by the test.
    bit [31:0] caiu_cctrlr_val;         // Parm to use for CCTRLR
    bit [31:0] trackPhase;              // Fix added for CONC-8950
    uvm_reg_data_t write_value =32'hFFFF_FFFF;
    uvm_reg_data_t read_value;
    uvm_reg my_register;
    uvm_reg_data_t mirrored_value;
    uvm_status_e   status;

<% for (j=0; j < obj.DutInfo.nTraceRegisters; ++j) {%>
    bit [31:0] caiu_tctrlr<%=j%>_val;   // Parm to use for TCTRLR
    bit [31:0] caiu_tbalr<%=j%>_val;    // Parm to use for TBALR
    bit [31:0] caiu_tbahr<%=j%>_val;    // Parm to use for TBAHR
    bit [31:0] caiu_topcr0<%=j%>_val;   // Parm to use for TOPCR0
    bit [31:0] caiu_topcr1<%=j%>_val;   // Parm to use for TOPCR1
    bit [31:0] caiu_tubr<%=j%>_val;     // Parm to use for TUBR
    bit [31:0] caiu_tubmr<%=j%>_val;    // Parm to use for TUBMR
<% } %>

    function new(string name="");
        super.new(name);
    endfunction

    task body();
        ncoreConfigInfo::sys_addr_csr_t csrq[$];
        uvm_reg_data_t write_data;
        int            qos_starv_event = 0;
        int            init_credit_val;

        csrq = ncoreConfigInfo::get_all_gpra();
        foreach (csrq[i]) begin
          `uvm_info(get_name(),
              $psprintf("unit: %s hui:%0d low-addr:0x0%h up-addr: 0x%0h sz:%0d",
                  csrq[i].unit.name(), csrq[i].mig_nunitid,
                  csrq[i].low_addr, csrq[i].upp_addr, csrq[i].size),
              UVM_NONE) 
        end

<% for(var i = 0; i < obj.DutInfo.nGPRA; i++) { %>
        write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUGPRBLR<%=i%>.AddrLow, csrq[<%=i%>].low_addr);
        write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUGPRBHR<%=i%>.AddrHigh, csrq[<%=i%>].upp_addr);
        write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUGPRAR<%=i%>.Size, csrq[<%=i%>].size);
 //       write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUGPRAR<%=i%>.DIGId, 0);
        write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUGPRAR<%=i%>.Valid, 1);
        write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUGPRAR<%=i%>.HUI, csrq[<%=i%>].mig_nunitid);
        write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUGPRAR<%=i%>.HUT, csrq[<%=i%>].unit == ncoreConfigInfo::DII ? 2'b10 : 2'b00);
        if($test$plusargs("dvm_addr_region_overlap")) begin
            write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUGPRAR<%=i%>.NSX, csrq[<%=i%>].nsx);
        end else begin
            write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUGPRAR<%=i%>.NSX, 'h1);
        end

        uvm_config_db#(int)::set(null,"*","gpra_size<%=i%>",csrq[<%=i%>].size);  // for coverage

<% } %>
        if($test$plusargs("k_num_event_msg")) begin
//HEY          write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUEVRXCR.Enable, 1);
//HEY          write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUETOR.EventTimeOutThreshold, 64);
        end
        if($test$plusargs("k_chi_sys_event_disable")) begin
            write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUTCR.EventDisable, 1);
        end

        //#Stimulus.CHIAIU.sysco.disable
        write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUTCR.SysCoDisable, 0);


        //FIXME: balajik - right now assigning max credit value to not hang any tests. Later will need randomize this. 
        if (!$value$plusargs("k_chi_init_credit_val=%d",init_credit_val)) begin  // #Stimulus.CHIAIU.v3.4.SCM.BringUp
            init_credit_val = 31;
        end

        <% for(var i = 0; i < obj.nDCEs; i++) { %>
        write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUCCR<%=i%>.DCECreditLimit, init_credit_val);
        <% } %>

        <% for(var i = 0; i < obj.nDMIs; i++) { %>
        write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUCCR<%=i%>.DMICreditLimit, init_credit_val);
        <% } %>

        <% for(var i = 0; i < obj.nDIIs; i++) { %>
        write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUCCR<%=i%>.DIICreditLimit, init_credit_val);
        <% } %>

        if ($value$plusargs("event_first=%d",qos_starv_event)) begin
            if (qos_starv_event == 31) begin
                write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUQOSCR.EventThreshold, $urandom_range(2,10));
            end
        end

        if ($test$plusargs("en_qos_starv")) begin
            write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUQOSCR.EventThreshold, $urandom_range(2,10));
        end

        if ($test$plusargs("dtw_dbg_rsp_err_inj")) begin

        <% for(var i=0; i<obj.DutInfo.nTraceRegisters; i++) {%>
        if ($test$plusargs("ttrig_reg_prog_en")) begin : ttrig_reg_prog_en_code_<%=i%>
            // decide register values
            // randomize registers if value not passed through plusargs.
            bit [5:0] trace<%=i%>_match_en_rand;
            bit trace<%=i%>_native_match_en;
            bit trace<%=i%>_addr_match_en;
            bit trace<%=i%>_opcode_match_en;
            bit trace<%=i%>_memattr_match_en;
            bit trace<%=i%>_user_match_en;
            bit trace<%=i%>_target_type_match_en;
            bit [4:0] trace<%=i%>_addr_match_size;
            bit [3:0] trace<%=i%>_memattr_match_value;
            bit [3:0] trace<%=i%>_opcode_valids_rand;
            bit [14:0] trace<%=i%>_opcode1;
            bit [14:0] trace<%=i%>_opcode2;
            bit [14:0] trace<%=i%>_opcode3;
            bit [14:0] trace<%=i%>_opcode4;
            bit trace<%=i%>_target_type_match_hut;
            bit [4:0] trace<%=i%>_target_type_match_hui;

            uvm_config_db#(int)::get(null, "", "caiu_cctrlr_phase", caiu_cctrlr_phase);

            if (($test$plusargs("caiu_cctrlr_mod")) && ($test$plusargs("caiu_tctrlr<%=i%>_val")) &&
                (caiu_cctrlr_phase==2)) begin
                tctrlr[<%=i%>] = caiu_tctrlr<%=i%>_val;
            end else if($test$plusargs("trigger<%=i%>_random")) begin
                tctrlr[<%=i%>] = $urandom();
            end else if($value$plusargs("tctrlr<%=i%>_value=%0x", tctrlr[<%=i%>])) begin
                // user-specified tctrlr
            end else begin : randomize_tctrlr_by_field
              begin: select_values_for_enables
                case ($urandom_range(100,1)) inside
                    ['d01:'d20]: trace<%=i%>_match_en_rand = 'h3f; // all enabled
                    ['d21:'d25]: trace<%=i%>_match_en_rand = 'h20; // enable one at a time
                    ['d26:'d30]: trace<%=i%>_match_en_rand = 'h10;
                    ['d31:'d35]: trace<%=i%>_match_en_rand = 'h08;
                    ['d36:'d40]: trace<%=i%>_match_en_rand = 'h04;
                    ['d41:'d45]: trace<%=i%>_match_en_rand = 'h02;
                    ['d46:'d50]: trace<%=i%>_match_en_rand = 'h01;
                    ['d51:'d60]: trace<%=i%>_match_en_rand = 'h00; // none enabled
                    default :    trace<%=i%>_match_en_rand = $urandom_range('h3f,'h00); // unconstrained
                endcase
                if($value$plusargs("trace_native_match_en=%0b", trace<%=i%>_native_match_en)) begin
                    // user-specified native_match_en
                end else begin
                    trace<%=i%>_native_match_en = trace<%=i%>_match_en_rand[0];
                end
                tctrlr[<%=i%>].native_trace_en = trace<%=i%>_native_match_en;
                if($value$plusargs("trace_addr_match_en=%0b", trace<%=i%>_addr_match_en)) begin
                    // user-specified addr_match_en
                end else begin
                    trace<%=i%>_addr_match_en = trace<%=i%>_match_en_rand[1];
                end
                tctrlr[<%=i%>].addr_match_en = trace<%=i%>_addr_match_en;
                if($value$plusargs("trace_opcode_match_en=%0b", trace<%=i%>_opcode_match_en)) begin
                    // user-specified opcode_match_en
                end else begin
                    trace<%=i%>_opcode_match_en = trace<%=i%>_match_en_rand[2];
                end
                tctrlr[<%=i%>].opcode_match_en = trace<%=i%>_opcode_match_en;
                if($value$plusargs("trace_memattr_match_en=%0b", trace<%=i%>_memattr_match_en)) begin
                    // user-specified memattr_match_en
                end else begin
                    trace<%=i%>_memattr_match_en = trace<%=i%>_match_en_rand[3];
                end
                tctrlr[<%=i%>].memattr_match_en = trace<%=i%>_memattr_match_en;
                if($value$plusargs("trace_user_match_en=%0b", trace<%=i%>_user_match_en)) begin
                    // user-specified user_match_en
                end else begin
                    trace<%=i%>_user_match_en = trace<%=i%>_match_en_rand[4];
                end
                tctrlr[<%=i%>].user_match_en = trace<%=i%>_user_match_en;
                if($value$plusargs("trace_target_type_match_en=%0b", trace<%=i%>_target_type_match_en)) begin
                    // user-specified target_type_match_en
                end else begin
                    trace<%=i%>_target_type_match_en = trace<%=i%>_match_en_rand[5];
                end
                tctrlr[<%=i%>].target_type_match_en = trace<%=i%>_target_type_match_en;
              end: select_values_for_enables

              begin: select_values_for_tctrlr_misc_fields
                if($value$plusargs("trace_addr_match_size=%0x", trace<%=i%>_addr_match_size)) begin
                    // user-specified addr_match_size
                end else begin
                    trace<%=i%>_addr_match_en = trace<%=i%>_match_en_rand[1];
                    case ($urandom_range(100,1)) inside
                        ['d01:'d10]: trace<%=i%>_addr_match_size = 'h1f; // max size
                        ['d11:'d20]: trace<%=i%>_addr_match_size = 'h00; // min size
                        default :    trace<%=i%>_addr_match_size = $urandom_range('h1f,'h00); // unconstrained
                    endcase
                end
                tctrlr[<%=i%>].range = trace<%=i%>_addr_match_size;

                if($value$plusargs("trace_memattr_match_value=%0x", trace<%=i%>_memattr_match_value)) begin
                    // user-specified memattr_match_value
                end else begin
                    trace<%=i%>_memattr_match_value = $urandom_range('hf,'h0); // unconstrained
                end
                tctrlr[<%=i%>].memattr = trace<%=i%>_memattr_match_value;

                // hut dii=1, dmi=0
                if($value$plusargs("trace_target_type_match_hut=%0b", trace<%=i%>_target_type_match_hut)) begin
                    // user-specified target_type_match_hut
                end else begin
                    trace<%=i%>_target_type_match_hut = $urandom_range('h1,'h0); // unconstrained
                end
                tctrlr[<%=i%>].hut = trace<%=i%>_target_type_match_hut;

                if($value$plusargs("trace_target_type_match_hui=%0b", trace<%=i%>_target_type_match_hui)) begin
                    // user-specified target_type_match_hui
                end else begin
                    case ($urandom_range(100,1)) inside
                        // 'h00 and 'h01 are most commonly seen in simulations, larger values are rare or do not occur
                        ['d01:'d10]: trace<%=i%>_target_type_match_hui = 'h00; 
                        ['d11:'d20]: trace<%=i%>_target_type_match_hui = 'h01; 
                        ['d21:'d30]: trace<%=i%>_target_type_match_hui = 'h02; 
                        default :    trace<%=i%>_target_type_match_hui = $urandom_range('h1f,'h00); // unconstrained
                    endcase
                end
                tctrlr[<%=i%>].hui = trace<%=i%>_target_type_match_hui;

              end: select_values_for_tctrlr_misc_fields
            end : randomize_tctrlr_by_field

            if (($test$plusargs("caiu_cctrlr_mod")) && ($test$plusargs("caiu_tbalr<%=i%>_val")) &&
                (caiu_cctrlr_phase==2)) begin
                tbalr[<%=i%>] = caiu_tbalr<%=i%>_val;
            end
            if (($test$plusargs("caiu_cctrlr_mod")) && ($test$plusargs("caiu_tbahr<%=i%>_val")) &&
                (caiu_cctrlr_phase==2)) begin
                tbahr[<%=i%>] = caiu_tbahr<%=i%>_val;
            end else if($test$plusargs("trigger<%=i%>_random")) begin
                tbalr[<%=i%>] = $urandom();
                tbahr[<%=i%>] = $urandom();
            end else if($value$plusargs("tbalr<%=i%>_value=%0x", tbalr[<%=i%>])) begin
                // user-specified tbalr
                $value$plusargs("tbahr<%=i%>_value=%0x", tbahr[<%=i%>]); 
                // user-specified tbahr
            end else begin
                case ($urandom_range(100,1)) inside
                    ['d01:'d10]: tbahr[<%=i%>] = 'h00; // min
                    ['d11:'d15]: tbahr[<%=i%>] = 'h01; // walk a one
                    ['d16:'d20]: tbahr[<%=i%>] = 'h02; 
                    ['d21:'d25]: tbahr[<%=i%>] = 'h04; 
                    ['d26:'d30]: tbahr[<%=i%>] = 'h08; 
                    ['d31:'d35]: tbahr[<%=i%>] = 'h10; 
                    ['d36:'d40]: tbahr[<%=i%>] = 'h20; 
                    ['d41:'d45]: tbahr[<%=i%>] = 'h40; 
                    ['d46:'d50]: tbahr[<%=i%>] = 'h80; 
                    ['d51:'d60]: tbahr[<%=i%>] = 'hff; // max
                    default :    tbahr[<%=i%>] = $urandom_range('hff,'h00); // unconstrained
                endcase
                case ($urandom_range(100,1)) inside
                    ['d01:'d10]: tbalr[<%=i%>] = 'h0000_0000; // min
                    ['d11:'d15]: tbalr[<%=i%>] = $urandom_range('h0000_00ff,'h0000_0000); // lower
                    ['d16:'d20]: tbalr[<%=i%>] = 'h0000_0100; 
                    ['d21:'d25]: tbalr[<%=i%>] = 'h0000_ff70; 
                    ['d26:'d30]: tbalr[<%=i%>] = 'h0001_0000; 
                    ['d31:'d35]: tbalr[<%=i%>] = 'h000f_f800; 
                    ['d36:'d40]: tbalr[<%=i%>] = 'h0010_0000; 
                    ['d41:'d45]: tbalr[<%=i%>] = 'h00ff_ff90; 
                    ['d46:'d50]: tbalr[<%=i%>] = 'h0100_0000; 
                    ['d51:'d55]: tbalr[<%=i%>] = 'h0fff_fff0; 
                    ['d56:'d60]: tbalr[<%=i%>] = 'h1000_0000; 
                    ['d61:'d65]: tbalr[<%=i%>] = 'ha5a5_a5a5; 
                    ['d66:'d70]: tbalr[<%=i%>] = 'h5a5a_5a5a; 
                    ['d71:'d75]: tbalr[<%=i%>] = $urandom_range('hffff_ffff,'hffff_ff00); // upper
                    ['d76:'d85]: tbalr[<%=i%>] = 'hffff_ffff; // max
                    default :    tbalr[<%=i%>] = $urandom_range('hffff_ffff,'h0000_0000); // unconstrained
                endcase
            end

            if (($test$plusargs("caiu_cctrlr_mod")) && ($test$plusargs("caiu_topcr0<%=i%>_val")) &&
                (caiu_cctrlr_phase==2)) begin
                topcr0[<%=i%>] = caiu_topcr0<%=i%>_val;
            end
            if (($test$plusargs("caiu_cctrlr_mod")) && ($test$plusargs("caiu_topcr1<%=i%>_val")) &&
                (caiu_cctrlr_phase==2)) begin
                topcr1[<%=i%>] = caiu_topcr1<%=i%>_val;
            end else if($test$plusargs("trigger<%=i%>_random")) begin
                topcr0[<%=i%>] = $urandom();
                topcr1[<%=i%>] = $urandom();
            // assume if user specifies topcr0 they also specify topcr1
            end else if($value$plusargs("topcr0<%=i%>_value=%0x", topcr0[<%=i%>])) begin
                // user-specified topcr0
                $value$plusargs("topcr1<%=i%>_value=%0x", topcr1[<%=i%>]);
                // user-specified topcr1
            end else begin : opcode_weighted_randomization
                case ($urandom_range(100,1)) inside
                    // prioritize more valids for a better chance of getting a match
                    ['d01:'d10]: trace<%=i%>_opcode_valids_rand = 'hf; // all
                    ['d11:'d15]: trace<%=i%>_opcode_valids_rand = 'h8; // one at a time
                    ['d16:'d20]: trace<%=i%>_opcode_valids_rand = 'h4; 
                    ['d21:'d25]: trace<%=i%>_opcode_valids_rand = 'h2; 
                    ['d26:'d30]: trace<%=i%>_opcode_valids_rand = 'h1; 
                    ['d31:'d35]: trace<%=i%>_opcode_valids_rand = 'h0; // none
                    default :    trace<%=i%>_opcode_valids_rand = $urandom_range('hf,'h0); // unconstrained
                endcase
                case ($urandom_range(100,1)) inside
                    // most of the time, choose values from 'h00 to 'h3f, not sure if values above 'h3f are possible for NCore 3.2
                    ['d01:'d90]: trace<%=i%>_opcode1 = $urandom_range('h3f,'h00);
                    ['d90:'d91]: trace<%=i%>_opcode1 = 'h7fff; // max value
                    default :    trace<%=i%>_opcode1 = $urandom_range('h7fff,'h0000); // unconstrained
                endcase
                case ($urandom_range(100,1)) inside
                    // most of the time, choose values from 'h00 to 'h3f, not sure if values above 'h3f are possible for NCore 3.2
                    ['d01:'d90]: trace<%=i%>_opcode2 = $urandom_range('h3f,'h00);
                    ['d90:'d91]: trace<%=i%>_opcode2 = 'h7fff; // max value
                    default :    trace<%=i%>_opcode2 = $urandom_range('h7fff,'h0000); // unconstrained
                endcase
                case ($urandom_range(100,1)) inside
                    // most of the time, choose values from 'h00 to 'h3f, not sure if values above 'h3f are possible for NCore 3.2
                    ['d01:'d90]: trace<%=i%>_opcode3 = $urandom_range('h3f,'h00);
                    ['d90:'d91]: trace<%=i%>_opcode3 = 'h7fff; // max value
                    default :    trace<%=i%>_opcode3 = $urandom_range('h7fff,'h0000); // unconstrained
                endcase
                case ($urandom_range(100,1)) inside
                    // most of the time, choose values from 'h00 to 'h3f, not sure if values above 'h3f are possible for NCore 3.2
                    ['d01:'d90]: trace<%=i%>_opcode4 = $urandom_range('h3f,'h00);
                    ['d90:'d91]: trace<%=i%>_opcode4 = 'h7fff; // max value
                    default :    trace<%=i%>_opcode4 = $urandom_range('h7fff,'h0000); // unconstrained
                endcase
                topcr0[<%=i%>].valid1  = trace<%=i%>_opcode_valids_rand[0];
                topcr0[<%=i%>].valid2  = trace<%=i%>_opcode_valids_rand[1];
                topcr1[<%=i%>].valid3  = trace<%=i%>_opcode_valids_rand[2];
                topcr1[<%=i%>].valid4  = trace<%=i%>_opcode_valids_rand[3];
                topcr0[<%=i%>].opcode1 = trace<%=i%>_opcode1;
                topcr0[<%=i%>].opcode2 = trace<%=i%>_opcode2;
                topcr1[<%=i%>].opcode3 = trace<%=i%>_opcode3;
                topcr1[<%=i%>].opcode4 = trace<%=i%>_opcode4;
            end : opcode_weighted_randomization

            if (($test$plusargs("caiu_cctrlr_mod")) && ($test$plusargs("caiu_tubr<%=i%>_val")) &&
                (caiu_cctrlr_phase==2)) begin
                tubr[<%=i%>] = caiu_tubr<%=i%>_val;
            end else if($test$plusargs("trigger<%=i%>_random")) begin
                tubr[<%=i%>] = $urandom();
            end else if($value$plusargs("tubr<%=i%>_value=%0x", tubr[<%=i%>])) begin
                // user-specified tubr
            end else begin : tubr_weighted_randomization
                case ($urandom_range(100,1)) inside
                    ['d01:'d20]: tubr[<%=i%>] = 'h0000_0000; 
                    ['d21:'d40]: tubr[<%=i%>] = $urandom_range('hf,'h0);
                    ['d41:'d41]: tubr[<%=i%>] = 'h0000_0010; 
                    ['d42:'d42]: tubr[<%=i%>] = 'h0000_0020; 
                    ['d43:'d43]: tubr[<%=i%>] = 'h0000_0040; 
                    ['d44:'d44]: tubr[<%=i%>] = 'h0000_0080; 
                    ['d45:'d45]: tubr[<%=i%>] = 'h0000_0100; 
                    ['d46:'d46]: tubr[<%=i%>] = 'h0000_0200; 
                    ['d47:'d47]: tubr[<%=i%>] = 'h0000_0400; 
                    ['d48:'d48]: tubr[<%=i%>] = 'h0000_0800; 
                    ['d49:'d49]: tubr[<%=i%>] = 'h0000_1000; 
                    ['d50:'d50]: tubr[<%=i%>] = 'h0000_2000; 
                    ['d51:'d51]: tubr[<%=i%>] = 'h0000_4000; 
                    ['d52:'d52]: tubr[<%=i%>] = 'h0000_8000; 
                    ['d53:'d53]: tubr[<%=i%>] = 'h0001_0000; 
                    ['d54:'d54]: tubr[<%=i%>] = 'h0002_0000; 
                    ['d55:'d55]: tubr[<%=i%>] = 'h0004_0000; 
                    ['d56:'d56]: tubr[<%=i%>] = 'h0008_0000; 
                    ['d57:'d57]: tubr[<%=i%>] = 'h0010_0000; 
                    ['d58:'d58]: tubr[<%=i%>] = 'h0020_0000; 
                    ['d59:'d59]: tubr[<%=i%>] = 'h0040_0000; 
                    ['d60:'d60]: tubr[<%=i%>] = 'h0080_0000; 
                    ['d61:'d61]: tubr[<%=i%>] = 'h0100_0000; 
                    ['d62:'d62]: tubr[<%=i%>] = 'h0200_0000; 
                    ['d63:'d63]: tubr[<%=i%>] = 'h0400_0000; 
                    ['d64:'d64]: tubr[<%=i%>] = 'h0800_0000; 
                    ['d65:'d65]: tubr[<%=i%>] = 'h1000_0000; 
                    ['d66:'d66]: tubr[<%=i%>] = 'h2000_0000; 
                    ['d67:'d67]: tubr[<%=i%>] = 'h4000_0000; 
                    ['d68:'d68]: tubr[<%=i%>] = 'h8000_0000; 
                    ['d69:'d74]: tubr[<%=i%>] = 'hffff_ffff; 
                    ['d75:'d79]: tubr[<%=i%>] = $urandom_range('hffff_ffff,'hffff_fff0);
                    default :    tubr[<%=i%>] = $urandom_range('hffff_ffff,'h0000_0000); // unconstrained
                endcase
            end : tubr_weighted_randomization

            if (($test$plusargs("caiu_cctrlr_mod")) && ($test$plusargs("caiu_tubmr<%=i%>_val")) &&
                (caiu_cctrlr_phase==2)) begin
                tubmr[<%=i%>] = caiu_tubmr<%=i%>_val;
            end else if($test$plusargs("trigger<%=i%>_random")) begin
                tubmr[<%=i%>] = $urandom();
            end else if($value$plusargs("tubmr<%=i%>_value=%0x", tubmr[<%=i%>])) begin
                // user-specified tubmr
            end else begin : tubmr_weighted_randomization
                case ($urandom_range(100,1)) inside
                    ['d01:'d20]: tubmr[<%=i%>] = 'h0000_0000; 
                    ['d21:'d40]: tubmr[<%=i%>] = $urandom_range('hf,'h0);
                    ['d41:'d41]: tubmr[<%=i%>] = 'h0000_0010; 
                    ['d42:'d42]: tubmr[<%=i%>] = 'h0000_0020; 
                    ['d43:'d43]: tubmr[<%=i%>] = 'h0000_0040; 
                    ['d44:'d44]: tubmr[<%=i%>] = 'h0000_0080; 
                    ['d45:'d45]: tubmr[<%=i%>] = 'h0000_0100; 
                    ['d46:'d46]: tubmr[<%=i%>] = 'h0000_0200; 
                    ['d47:'d47]: tubmr[<%=i%>] = 'h0000_0400; 
                    ['d48:'d48]: tubmr[<%=i%>] = 'h0000_0800; 
                    ['d49:'d49]: tubmr[<%=i%>] = 'h0000_1000; 
                    ['d50:'d50]: tubmr[<%=i%>] = 'h0000_2000; 
                    ['d51:'d51]: tubmr[<%=i%>] = 'h0000_4000; 
                    ['d52:'d52]: tubmr[<%=i%>] = 'h0000_8000; 
                    ['d53:'d53]: tubmr[<%=i%>] = 'h0001_0000; 
                    ['d54:'d54]: tubmr[<%=i%>] = 'h0002_0000; 
                    ['d55:'d55]: tubmr[<%=i%>] = 'h0004_0000; 
                    ['d56:'d56]: tubmr[<%=i%>] = 'h0008_0000; 
                    ['d57:'d57]: tubmr[<%=i%>] = 'h0010_0000; 
                    ['d58:'d58]: tubmr[<%=i%>] = 'h0020_0000; 
                    ['d59:'d59]: tubmr[<%=i%>] = 'h0040_0000; 
                    ['d60:'d60]: tubmr[<%=i%>] = 'h0080_0000; 
                    ['d61:'d61]: tubmr[<%=i%>] = 'h0100_0000; 
                    ['d62:'d62]: tubmr[<%=i%>] = 'h0200_0000; 
                    ['d63:'d63]: tubmr[<%=i%>] = 'h0400_0000; 
                    ['d64:'d64]: tubmr[<%=i%>] = 'h0800_0000; 
                    ['d65:'d65]: tubmr[<%=i%>] = 'h1000_0000; 
                    ['d66:'d66]: tubmr[<%=i%>] = 'h2000_0000; 
                    ['d67:'d67]: tubmr[<%=i%>] = 'h4000_0000; 
                    ['d68:'d68]: tubmr[<%=i%>] = 'h8000_0000; 
                    ['d69:'d74]: tubmr[<%=i%>] = 'hffff_ffff; 
                    ['d75:'d79]: tubmr[<%=i%>] = $urandom_range('hffff_ffff,'hffff_fff0);
                    default :    tubmr[<%=i%>] = $urandom_range('hffff_ffff,'h0000_0000); // unconstrained
                endcase
            end : tubmr_weighted_randomization

            // zero out bits that should not exist in the RTL for this particular config

            // CHI-A does not support native traceme
            <% if (obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-A') { %>
            tctrlr[<%=i%>].native_trace_en = 0;
            <%}%>

            tctrlr[<%=i%>].aw = 0; // CHI does not have aw
            tctrlr[<%=i%>].ar = 0; // CHI does not have ar

            // set user_match_en to always 0 when user bit width is 0, CONC-7967
            <% if(!obj.AiuInfo[obj.Id].interfaces.chiInt.params.REQ_RSVDC) {%>
            tctrlr[<%=i%>].user_match_en = 0;
            tubr[<%=i%>].user = 0;
            tubmr[<%=i%>].user_mask = 0;
            <%}%>

            // ------------------------------------------------------------------------
            // Fix for CONC-8950....Storing all the enablements bits of the TCTRLR 
            // register. Those might get restored at phase2 as indicated in CONC-7967. 
            if (($test$plusargs("caiu_cctrlr_mod")) && ("caiu_cctrlr_phase==0") && (trackPhase <= <%=i%>)) begin
               tctrlr_save[<%=i%>] = tctrlr[<%=i%>];
               ++trackPhase;
            end;

           // -----------------------------------------------------
           // Restored the enablement bits.
           if (caiu_cctrlr_phase==1) begin
               tctrlr[<%=i%>] = tctrlr_save[<%=i%>];     // CONC-8950

               tubmr[<%=i%>]  = 32'h0;
               tubr[<%=i%>]   = 32'h0;
               topcr0[<%=i%>] = 32'h0;
               topcr1[<%=i%>] = 32'h0;
               tbalr[<%=i%>]  = 32'h0;
               tbahr[<%=i%>]  = 32'h0;

              `uvm_info(get_name(), $sformatf("All Trace Regs have been reset as caiu_cctrlr_phase=1."), UVM_HIGH)
            end

           if (caiu_cctrlr_phase==2) begin
              if (<%=i%> == 0 || (tctrlr[0][0]==1))      // CONC-8950
                 tctrlr[<%=i%>] = tctrlr_save[<%=i%>];
           end
      
            // write register values to RTL
            // fixme: billc: 2021-09-30, decide whether or not to add code to not write certain registers if the corresponding match_en is 0
            <% if (obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>
            write_csr(m_regs.<%=obj.BlockId%>.CAIUTCTRLR<%=i%>.native_trace_en, tctrlr[<%=i%>].native_trace_en);
            <%}%>
            write_csr(m_regs.<%=obj.BlockId%>.CAIUTCTRLR<%=i%>.addr_match_en, tctrlr[<%=i%>].addr_match_en);
            write_csr(m_regs.<%=obj.BlockId%>.CAIUTCTRLR<%=i%>.opcode_match_en, tctrlr[<%=i%>].opcode_match_en);
            write_csr(m_regs.<%=obj.BlockId%>.CAIUTCTRLR<%=i%>.memattr_match_en, tctrlr[<%=i%>].memattr_match_en);
            <% if(obj.AiuInfo[obj.Id].interfaces.chiInt.params.REQ_RSVDC) {%>
            write_csr(m_regs.<%=obj.BlockId%>.CAIUTCTRLR<%=i%>.user_match_en, tctrlr[<%=i%>].user_match_en);
            <%}%>
            write_csr(m_regs.<%=obj.BlockId%>.CAIUTCTRLR<%=i%>.target_type_match_en, tctrlr[<%=i%>].target_type_match_en);
            write_csr(m_regs.<%=obj.BlockId%>.CAIUTCTRLR<%=i%>.hut, tctrlr[<%=i%>].hut);
            write_csr(m_regs.<%=obj.BlockId%>.CAIUTCTRLR<%=i%>.hui, tctrlr[<%=i%>].hui);
            write_csr(m_regs.<%=obj.BlockId%>.CAIUTCTRLR<%=i%>.range, tctrlr[<%=i%>].range);
            //write_csr(m_regs.<%=obj.BlockId%>.CAIUTCTRLR<%=i%>.aw, tctrlr[<%=i%>].aw); // aw does not exist for CHI
            //write_csr(m_regs.<%=obj.BlockId%>.CAIUTCTRLR<%=i%>.ar, tctrlr[<%=i%>].ar); // ar does not exist for CHI
            write_csr(m_regs.<%=obj.BlockId%>.CAIUTCTRLR<%=i%>.memattr, tctrlr[<%=i%>].memattr);

            write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUTBALR<%=i%>.base_addr_lo, tbalr[<%=i%>].base_addr_43_12);

            write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUTBAHR<%=i%>.base_addr_hi, tbahr[<%=i%>].base_addr_51_44);

            topcr0[<%=i%>].opcode1 = topcr0[<%=i%>].opcode1 & {WREQOPCODE{1'b1}};
            topcr0[<%=i%>].opcode2 = topcr0[<%=i%>].opcode2 & {WREQOPCODE{1'b1}};
            topcr1[<%=i%>].opcode3 = topcr1[<%=i%>].opcode3 & {WREQOPCODE{1'b1}};
            topcr1[<%=i%>].opcode4 = topcr1[<%=i%>].opcode4 & {WREQOPCODE{1'b1}};
            write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUTOPCR0<%=i%>.opcode1, topcr0[<%=i%>].opcode1);
            write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUTOPCR0<%=i%>.valid1,  topcr0[<%=i%>].valid1);
            write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUTOPCR0<%=i%>.opcode2, topcr0[<%=i%>].opcode2);
            write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUTOPCR0<%=i%>.valid2,  topcr0[<%=i%>].valid2);
            write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUTOPCR1<%=i%>.opcode3, topcr1[<%=i%>].opcode3);
            write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUTOPCR1<%=i%>.valid3,  topcr1[<%=i%>].valid3);
            write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUTOPCR1<%=i%>.opcode4, topcr1[<%=i%>].opcode4);
            write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUTOPCR1<%=i%>.valid4,  topcr1[<%=i%>].valid4);

            <% if(obj.AiuInfo[obj.Id].interfaces.chiInt.params.REQ_RSVDC) {%>
            tubr[<%=i%>].user = tubr[<%=i%>].user & {WREQRSVDC{1'b1}};
            tubmr[<%=i%>].user_mask = tubmr[<%=i%>].user_mask & {WREQRSVDC{1'b1}};
            write_csr(m_regs.<%=obj.BlockId%>.CAIUTUBR<%=i%>.user, tubr[<%=i%>].user);
            write_csr(m_regs.<%=obj.BlockId%>.CAIUTUBMR<%=i%>.user_mask, tubmr[<%=i%>].user_mask);
            <%}%>

            // pass register values to the scoreboard.
            chi_aiu_scb::tctrlr[<%=i%>] =  tctrlr[<%=i%>];
            chi_aiu_scb::tbalr[<%=i%>]  =  tbalr[<%=i%>];
            chi_aiu_scb::tbahr[<%=i%>]  =  tbahr[<%=i%>];
            chi_aiu_scb::topcr0[<%=i%>] =  topcr0[<%=i%>];
            chi_aiu_scb::topcr1[<%=i%>] =  topcr1[<%=i%>];
            chi_aiu_scb::tubr[<%=i%>]   =  tubr[<%=i%>];
            chi_aiu_scb::tubmr[<%=i%>]  =  tubmr[<%=i%>];

            `uvm_info(get_name(), $sformatf("TTRI: tctrlr[<%=i%>]               = %8h", tctrlr[<%=i%>]), UVM_HIGH)
            `uvm_info(get_name(), $sformatf("TTRI: tbalr[<%=i%>]                = %8h", tbalr[<%=i%>]), UVM_HIGH)
            `uvm_info(get_name(), $sformatf("TTRI: tbahr[<%=i%>]                = %8h", tbahr[<%=i%>]), UVM_HIGH)
            `uvm_info(get_name(), $sformatf("TTRI: topcr0[<%=i%>]               = %8h", topcr0[<%=i%>]), UVM_HIGH)
            `uvm_info(get_name(), $sformatf("TTRI: topcr1[<%=i%>]               = %8h", topcr1[<%=i%>]), UVM_HIGH)
            `uvm_info(get_name(), $sformatf("TTRI: tubr[<%=i%>]                 = %8h", tubr[<%=i%>]), UVM_HIGH)
            `uvm_info(get_name(), $sformatf("TTRI: tubmr[<%=i%>]                = %8h", tubmr[<%=i%>]), UVM_HIGH)
            `uvm_info(get_name(), $sformatf("TTRI: trace<%=i%>_match_en_rand         = %6b",  trace<%=i%>_match_en_rand), UVM_HIGH)
            `uvm_info(get_name(), $sformatf("TTRI: trace<%=i%>_native_match_en       = %b",  trace<%=i%>_native_match_en), UVM_HIGH)
            `uvm_info(get_name(), $sformatf("TTRI: trace<%=i%>_addr_match_en         = %b",  trace<%=i%>_addr_match_en), UVM_HIGH)
            `uvm_info(get_name(), $sformatf("TTRI: trace<%=i%>_opcode_match_en       = %b",  trace<%=i%>_opcode_match_en), UVM_HIGH)
            `uvm_info(get_name(), $sformatf("TTRI: trace<%=i%>_memattr_match_en      = %b",  trace<%=i%>_memattr_match_en), UVM_HIGH)
            `uvm_info(get_name(), $sformatf("TTRI: trace<%=i%>_user_match_en         = %b",  trace<%=i%>_user_match_en), UVM_HIGH)
            `uvm_info(get_name(), $sformatf("TTRI: trace<%=i%>_target_type_match_en  = %b",  trace<%=i%>_target_type_match_en), UVM_HIGH)
            `uvm_info(get_name(), $sformatf("TTRI: match_en native       = %b, addr = %b, opcode = %b, memattr = %b, user = %b, target_type = %b", trace<%=i%>_native_match_en, trace<%=i%>_addr_match_en, trace<%=i%>_opcode_match_en, trace<%=i%>_memattr_match_en, trace<%=i%>_user_match_en, trace<%=i%>_target_type_match_en), UVM_HIGH)
            `uvm_info(get_name(), $sformatf("TTRI: trace<%=i%>_addr_match_size       = %h", trace<%=i%>_addr_match_size), UVM_HIGH)
            `uvm_info(get_name(), $sformatf("TTRI: trace<%=i%>_memattr_match_value   = %h", trace<%=i%>_memattr_match_value), UVM_HIGH)
            `uvm_info(get_name(), $sformatf("TTRI: trace<%=i%>_opcode_valids_rand    = %4b", trace<%=i%>_opcode_valids_rand), UVM_HIGH)
            `uvm_info(get_name(), $sformatf("TTRI: trace<%=i%>_opcode1               = %4h", trace<%=i%>_opcode1), UVM_HIGH)
            `uvm_info(get_name(), $sformatf("TTRI: trace<%=i%>_opcode2               = %4h", trace<%=i%>_opcode2), UVM_HIGH)
            `uvm_info(get_name(), $sformatf("TTRI: trace<%=i%>_opcode3               = %4h", trace<%=i%>_opcode3), UVM_HIGH)
            `uvm_info(get_name(), $sformatf("TTRI: trace<%=i%>_opcode4               = %4h", trace<%=i%>_opcode4), UVM_HIGH)
            `uvm_info(get_name(), $sformatf("TTRI: trace<%=i%>_target_type_match_hut = %b", trace<%=i%>_target_type_match_hut), UVM_HIGH)
            `uvm_info(get_name(), $sformatf("TTRI: trace<%=i%>_target_type_match_hui = %5h", trace<%=i%>_target_type_match_hui), UVM_HIGH)

        end : ttrig_reg_prog_en_code_<%=i%>
        <%}%>

        if ($test$plusargs("tcap_reg_prog_en")) begin : tcap_reg_prog_en_code
            bit [31:0] set_value = 0;
            bit [7:0]  smi_cap   = 0;
            bit [3:0]  gain      = 0;
            bit [11:0] inc       = 0;

            if (($test$plusargs("caiu_cctrlr_mod")) && ($test$plusargs("caiu_cctrlr_val")) &&
                (caiu_cctrlr_phase==2)) begin
                smi_cap = caiu_cctrlr_val[7:0];
                gain    = caiu_cctrlr_val[19:16];
                inc     = caiu_cctrlr_val[31:20];
            end else if ($test$plusargs("cctrlr_random")) begin
                std::randomize(smi_cap);
                std::randomize(gain);
                std::randomize(inc);
                `uvm_info(get_name(), $sformatf("<%=obj.DutInfo.strRtlNamePrefix%> Set CCRTRLR to random values. SMI_CAPT=%0h, GAIN=%0d, VALUE=%0d", smi_cap, gain, inc), UVM_LOW)
            end else if ($value$plusargs("cctrlr_value=0x%0h", set_value)) begin
                smi_cap      = set_value[7:0];
                gain         = set_value[19:16];
                inc          = set_value[31:20];
                `uvm_info(get_name(), $sformatf("<%=obj.DutInfo.strRtlNamePrefix%> Set CCRTRLR through cmdln=%0h. SMI_CAPT=%0h, GAIN=%0d, INC=%0d", set_value, smi_cap, gain, inc), UVM_LOW)
            end else begin : weighted_random
                if ($value$plusargs("cctrlr_enables=0x%0h", smi_cap)) begin
                  // user-specified smi_cap
                end else begin : cctrlr_enables_weighted_random
                  case ($urandom_range(100,1)) inside
                    ['d01:'d10]: smi_cap = 'hff; // all on DMI
                    ['d11:'d20]: smi_cap = 'hcf; // all on CHI
                    ['d21:'d22]: smi_cap = 'h01; // try one at a time
                    ['d23:'d24]: smi_cap = 'h02;
                    ['d25:'d26]: smi_cap = 'h04;
                    ['d27:'d28]: smi_cap = 'h08;
                    ['d29:'d30]: smi_cap = 'h10;
                    ['d31:'d32]: smi_cap = 'h20;
                    ['d33:'d34]: smi_cap = 'h40;
                    ['d35:'d36]: smi_cap = 'h80;
                    ['d37:'d70]: smi_cap = 'h00; // all off
                    default :    smi_cap = $urandom_range('hff,'h00); // unconstrained
                  endcase
                end : cctrlr_enables_weighted_random
                if ($value$plusargs("cctrlr_gain=0x%0h", gain)) begin
                  // user-specified gain
                end else begin : cctrlr_gain_weighted_random 
                  case ($urandom_range(100,1)) inside
                    ['d01:'d50]: gain = 'h0; // disables TS corrections
                    default :    gain = $urandom_range('hf,'h0); // unconstrained
                  endcase
                end : cctrlr_gain_weighted_random
                if ($value$plusargs("cctrlr_inc_integer=0x%0h", inc[11:8])) begin
                  // user-specified inc integer
                end else begin : cctrlr_inc_integer_weighted_random 
                  case ($urandom_range(100,1)) inside
                    ['d01:'d25]: inc[11:8] = 'h0;
                    ['d26:'d50]: inc[11:8] = 'hf;
                    default :    inc[11:8] = $urandom_range('hf,'h0); // unconstrained
                  endcase
                end : cctrlr_inc_integer_weighted_random
                if ($value$plusargs("cctrlr_inc_fractional=0x%0h", inc[7:0])) begin
                  // user-specified inc fractional
                end else begin : cctrlr_inc_fractional_weighted_random 
                  case ($urandom_range(100,1)) inside
                    ['d01:'d25]: inc[7:0] = 'h00;
                    ['d26:'d50]: inc[7:0] = 'hff;
                    default :    inc[7:0] = $urandom_range('hff,'h00); // unconstrained
                  endcase
                end : cctrlr_inc_fractional_weighted_random
            end : weighted_random

            uvm_config_db#(int)::get(null, "*", "caiu_cctrlr_phase", caiu_cctrlr_phase);

            if ($test$plusargs("caiu_cctrlr_mod") && (caiu_cctrlr_phase != 0)) begin
                // CCTRLR[7:0] are updated
                smi_cap = (caiu_cctrlr_phase==2) ? smi_cap : 0;
		<% for (i=0; i < obj.DutInfo.nTraceRegisters; ++i) {%>
                tctrlr[<%=i%>] = (caiu_cctrlr_phase==2) ? tctrlr[<%=i%>] : 0;
        	<%}%>
            end

            write_data = (smi_cap >> 0) & 1;
            write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUCCTRLR.ndn0Tx, write_data);
            trace_debug_scb::port_capture_en[0] = write_data ? (smi_cap[0] | 'b1) : (smi_cap[0] & 'b0);

            write_data = (smi_cap >> 1) & 1;
            write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUCCTRLR.ndn0Rx, write_data);
            trace_debug_scb::port_capture_en[1] = write_data ? (smi_cap[1] | 'b1) : (smi_cap[1] & 'b0);

            write_data = (smi_cap >> 2) & 1;
            write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUCCTRLR.ndn1Tx, write_data);
            trace_debug_scb::port_capture_en[2] = write_data ? (smi_cap[2] | 'b1) : (smi_cap[2] & 'b0);

            write_data = (smi_cap >> 3) & 1;
            write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUCCTRLR.ndn1Rx, write_data);
            trace_debug_scb::port_capture_en[3] = write_data ? (smi_cap[3] | 'b1) : (smi_cap[3] & 'b0);

            write_data = (smi_cap >> 4) & 1;
            write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUCCTRLR.ndn2Tx, write_data);
            trace_debug_scb::port_capture_en[4] = write_data ? (smi_cap[4] | 'b1) : (smi_cap[4] & 'b0);

            write_data = (smi_cap >> 5) & 1;
            write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUCCTRLR.ndn2Rx, write_data);
            trace_debug_scb::port_capture_en[5] = write_data ? (smi_cap[5] | 'b1) : (smi_cap[5] & 'b0);

            write_data = (smi_cap >> 6) & 1;
            write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUCCTRLR.dn0Tx , write_data);
            trace_debug_scb::port_capture_en[6] = write_data ? (smi_cap[6] | 'b1) : (smi_cap[6] & 'b0);

            write_data = (smi_cap >> 7) & 1;
            write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUCCTRLR.dn0Rx , write_data);
            trace_debug_scb::port_capture_en[7] = write_data ? (smi_cap[7] | 'b1) : (smi_cap[7] & 'b0);

            write_data = gain;
            write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUCCTRLR.gain  , write_data);
            trace_debug_scb::gain = write_data;

            write_data = inc;
            write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUCCTRLR.inc   , write_data);
            trace_debug_scb::inc = write_data;

        end : tcap_reg_prog_en_code

        end //dtw_dbg_rsp_err_inj

        if(this.model == null) begin
        `uvm_error(get_type_name(),"this.model in seq is null");
        end

        my_register = this.model.get_reg_by_name("CAIUUELR0");
        if(my_register == null) begin
          `uvm_error(get_type_name(),"The value of my_register is null because it couldnt find CAIUUELR0");
        end

        my_register.write(status, write_value);
        `uvm_info(get_type_name(),$sformatf("The value written in CAIUUELR0 is %0h", write_value),UVM_LOW)

       if(status != UVM_IS_OK) begin
        `uvm_error(get_type_name(), $sformatf("Error writing to reg CAIUUELR0: %s", status.name()));
          return;
       end

       my_register.read(status,read_value);
       `uvm_info(get_type_name(), $sformatf("And CAIUUELR0 in seq after reading is %0h",read_value),UVM_LOW)

       if(status != UVM_IS_OK) begin
          `uvm_error(get_type_name(), $sformatf("Error reading from reg CAIUUELR0: %s", status.name()));
           return;
       end

       mirrored_value = my_register.get_mirrored_value();
       `uvm_info(get_type_name(),$sformatf("The mirrored value in sequence is %0h", mirrored_value), UVM_LOW)

    endtask
endclass : chi_aiu_ral_addr_map_seq

class chi_aiu_ral_sysco_seq extends chi_aiu_ral_csr_base_seq;
  `uvm_object_utils(chi_aiu_ral_sysco_seq)

    function new(string name="");
        super.new(name);
    endfunction

    task body();
        uvm_reg_data_t attached, connecting, attach;
        uvm_object uvm_obj;
        chi_base_seq_item chi_obj;
        uvm_event_pool ev_pool_sysco = uvm_event_pool::get_global_pool();
        uvm_event ev_toggle_sysco_<%=obj.BlockId%> = ev_pool_sysco.get("ev_toggle_sysco_<%=obj.BlockId%>");
        uvm_event ev_csr_sysco_<%=obj.BlockId%> = ev_pool_sysco.get("ev_csr_sysco_<%=obj.BlockId%>");
        uvm_event ev_csr_sysco_toggle = ev_pool.get("ev_csr_sysco_toggle");
        bit csr_boot_sysco_st = $value$plusargs("csr_boot_sysco_st=%0d", csr_boot_sysco_st) ? csr_boot_sysco_st : 1;
        bit is_1stTime = 1;
        int max_value;
        int toggle_count;
        getSMIIf();
        getCsrProbeIf();

        $value$plusargs("toggle_count=%d",toggle_count);

        forever begin
          `uvm_info(get_name(), $sformatf("Running in a loop again"), UVM_NONE)
          if(uvm_obj == null) begin // Null for CSR
            chi_obj = chi_base_seq_item::type_id::create("chi_obj");
            read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUTAR.SysCoAttached, attached);
            if(attached) begin // ENABLED then,
              attach = 'h0;
              `uvm_info(get_name(), $sformatf("dbg-0::attached=%0d, connecting=%0d, attach=%0d", attached, connecting, attach), UVM_DEBUG)
            end
            else begin
              read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUTAR.SysCoConnecting, connecting);
              if(connecting) begin // connecting then,
                uvm_reg_data_t tmp_data;
                do begin
                  repeat(1000) @(posedge m_smi<%=smi_portid_snpreq%>_tx_vif.clk);
                  read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUTAR.SysCoConnecting, tmp_data);
                  `uvm_info(get_name(), $sformatf("waiting <%=obj.DutInfo.strRtlNamePrefix%>CAIUTAR.SysCoConnecting=%0d for it to be 0", tmp_data), UVM_NONE)
                end while (tmp_data != 0);
                attach = 'h0;
                `uvm_info(get_name(), $sformatf("dbg-1::attached=%0d, connecting=%0d, attach=%0d", attached, connecting, attach), UVM_DEBUG)
              end else begin
                attach = 'h1;
                `uvm_info(get_name(), $sformatf("dbg-2::attached=%0d, connecting=%0d, attach=%0d", attached, connecting, attach), UVM_DEBUG)
              end
            end
            chi_obj.sysco_req = attach;
            chi_obj.sysco_ack = attached;
            if(is_1stTime && (csr_boot_sysco_st != attach)) begin
              /**
                *Assuming attach will be readout 'h0 from RTL as default. Below logic is added for disabling sysco at start
                *& making in sync with the native sysco logic
                */
              //#Stimulus.CHIAIU.sysco.csrdetach
              write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUTCR.SysCoAttach, csr_boot_sysco_st);
            end
            else begin
              //#Stimulus.CHIAIU.sysco.csrattach
              ev_csr_sysco_<%=obj.BlockId%>.trigger(chi_obj);
              write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUTCR.SysCoAttach, attach);
            end
            is_1stTime = 0;
          end
          else begin
            `uvm_info(get_name(), $sformatf("Event ev_toggle_sysco_<%=obj.BlockId%> triggered without Null object, so Native interface should operate from TB"), UVM_NONE)
            `uvm_info(get_name(), $sformatf("dbg-3::attached=%0d, connecting=%0d, attach=%0d", attached, connecting, attach), UVM_DEBUG)
          end
          `uvm_info(get_name(), $sformatf("dbg-4::attached=%0d, connecting=%0d, attach=%0d", attached, connecting, attach), UVM_DEBUG)
          ev.trigger();
          `uvm_info(get_name(), $sformatf("dbg-5::attached=%0d, connecting=%0d, attach=%0d", attached, connecting, attach), UVM_DEBUG)
          ev_toggle_sysco_<%=obj.BlockId%>.wait_ptrigger_data(uvm_obj);
          `uvm_info(get_name(), $sformatf("dbg-6::attached=%0d, connecting=%0d, attach=%0d", attached, connecting, attach), UVM_DEBUG)

           max_value ++;

        if($test$plusargs("k_toggle_sysco"))begin 
          if(max_value == toggle_count)begin
            ev_csr_sysco_toggle.trigger();
            break;
          end
        end

     end
  endtask
endclass : chi_aiu_ral_sysco_seq

class res_corr_err_threshold_seq extends ral_csr_base_seq; 
   `uvm_object_utils(res_corr_err_threshold_seq)

    uvm_reg_data_t threshold_width, threshold_value;
    uvm_status_e   status;
    string threshold_range = "rand", csr_fld_name;
    int range_min, range_max;
    uvm_reg_field  res_threshold_fld;

    function new(string name="");
        super.new(name);
    endfunction

    virtual task body();
      <% if(obj.useResiliency) { %>
      res_threshold_fld = m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUCRTR.ResThreshold;
      csr_fld_name = res_threshold_fld.get_full_name;
      threshold_width = get_threshold_width;
      case(threshold_range)
        "min" : begin
          threshold_value = 0;
        end
        "max" : begin
          threshold_value = (2**threshold_width) - 1;
        end
        "fix" : begin
          threshold_value = threshold_value;
        end
        "fix_range" : begin
          threshold_value = $urandom_range(range_min,range_max-1);
        end
        "rand" : begin
          threshold_value = $urandom_range(0,(2**threshold_width)-1);
        end
        default : begin
          threshold_value = $urandom_range(0,(2**threshold_width)-1);
        end
      endcase
      `uvm_info(get_name(), $sformatf("Writing %0s with value=%0d", csr_fld_name, threshold_value), UVM_NONE)
      write_csr(res_threshold_fld, threshold_value);
      <% } %>
    endtask

    virtual function int get_threshold_width();
      <% if(obj.useResiliency) { %>
      return res_threshold_fld.get_n_bits();
      <% } else { %>
      return 0;
      <% } %>
    endfunction
    virtual function int get_threshold_value();
      return threshold_value;
    endfunction
    virtual function void set_threshold_value(int val);
      threshold_value = val;
    endfunction
    virtual function void set_threshold_range(string range = "rand");
      threshold_range = range;
    endfunction
    virtual function void set_threshold_range_value(int min, int max);
      range_min = min;
      range_max = max;
    endfunction
endclass : res_corr_err_threshold_seq

class chi_aiu_csr_trace_debug_seq extends chi_aiu_ral_csr_base_seq;
    `uvm_object_utils(chi_aiu_csr_trace_debug_seq)

    uvm_reg_data_t write_data;

    TRIG_TCTRLR_t tctrlr[<%=obj.DutInfo.nTraceRegisters%>];
    TRIG_TBALR_t  tbalr[<%=obj.DutInfo.nTraceRegisters%>];
    TRIG_TBAHR_t  tbahr[<%=obj.DutInfo.nTraceRegisters%>];
    TRIG_TOPCR0_t topcr0[<%=obj.DutInfo.nTraceRegisters%>];
    TRIG_TOPCR1_t topcr1[<%=obj.DutInfo.nTraceRegisters%>];
    TRIG_TUBR_t   tubr[<%=obj.DutInfo.nTraceRegisters%>];
    TRIG_TUBMR_t  tubmr[<%=obj.DutInfo.nTraceRegisters%>];

    uvm_event csr_trace_debug_done = ev_pool.get("csr_trace_debug_done");

    TRIG_TCTRLR_t tctrlr_save[<%=obj.DutInfo.nTraceRegisters%>];
    int caiu_cctrlr_phase = 0;          // This variable is controlled by the test.
    bit [31:0] caiu_cctrlr_val;         // Parm to use for CCTRLR
    bit [31:0] trackPhase;              // Fix added for CONC-8950

<% for (j=0; j < obj.DutInfo.nTraceRegisters; ++j) {%>
    bit [31:0] caiu_tctrlr<%=j%>_val;   // Parm to use for TCTRLR
    bit [31:0] caiu_tbalr<%=j%>_val;    // Parm to use for TBALR
    bit [31:0] caiu_tbahr<%=j%>_val;    // Parm to use for TBAHR
    bit [31:0] caiu_topcr0<%=j%>_val;   // Parm to use for TOPCR0
    bit [31:0] caiu_topcr1<%=j%>_val;   // Parm to use for TOPCR1
    bit [31:0] caiu_tubr<%=j%>_val;     // Parm to use for TUBR
    bit [31:0] caiu_tubmr<%=j%>_val;    // Parm to use for TUBMR
<% } %>

    function new(string name="");
        super.new(name);

        $value$plusargs("caiu_cctrlr_val=%x",caiu_cctrlr_val);

<% for (j=0; j < obj.DutInfo.nTraceRegisters; ++j) {%>
        $value$plusargs("caiu_tctrlr<%=j%>_val=%x",caiu_tctrlr<%=j%>_val);
        $value$plusargs("caiu_tbalr<%=j%>_val=%x",caiu_tbalr<%=j%>_val);
        $value$plusargs("caiu_tbahr<%=j%>_val=%x",caiu_tbahr<%=j%>_val);
        $value$plusargs("caiu_topcr0<%=j%>_val=%x",caiu_topcr0<%=j%>_val);
        $value$plusargs("caiu_topcr1<%=j%>_val=%x",caiu_topcr1<%=j%>_val);
        $value$plusargs("caiu_tubr<%=j%>_val=%x",caiu_tubr<%=j%>_val);
        $value$plusargs("caiu_tubmr<%=j%>_val=%x",caiu_tubmr<%=j%>_val);
<% } %>

    endfunction

    task body();
        // to get full randomization of each trigger register, unconstrained, set the plusarg trigger<%=i%>_random
        // the recommended plusarg usage to control trigger register values is to use one of the following, from highest priority to lowest, 
        // 1. trigger<%=i%>_random plusarg, to get full randomization of every trigger register, unconstrained
        // 2. register value plusargs, such as tctrlr<%=i%>_value for full control of an entire trigger register
        // 3. use field plusargs, such as trace<%=i%>_native_match_en, for full control of a particular trigger register field
        // 4. default is to let the sequence randomize the field plusargs using a weighted random
        // do not mix plusarg types 2 and 3 for a single register, the result is undefined
        <% for(var i=0; i<obj.DutInfo.nTraceRegisters; i++) {%>
        if ($test$plusargs("ttrig_reg_prog_en")) begin : ttrig_reg_prog_en_code_<%=i%>
            // decide register values
            // randomize registers if value not passed through plusargs.
            bit [5:0] trace<%=i%>_match_en_rand;
            bit trace<%=i%>_native_match_en;
            bit trace<%=i%>_addr_match_en;
            bit trace<%=i%>_opcode_match_en;
            bit trace<%=i%>_memattr_match_en;
            bit trace<%=i%>_user_match_en;
            bit trace<%=i%>_target_type_match_en;
            bit [4:0] trace<%=i%>_addr_match_size;
            bit [3:0] trace<%=i%>_memattr_match_value;
            bit [3:0] trace<%=i%>_opcode_valids_rand;
            bit [14:0] trace<%=i%>_opcode1;
            bit [14:0] trace<%=i%>_opcode2;
            bit [14:0] trace<%=i%>_opcode3;
            bit [14:0] trace<%=i%>_opcode4;
            bit trace<%=i%>_target_type_match_hut;
            bit [4:0] trace<%=i%>_target_type_match_hui;

            uvm_config_db#(int)::get(null, "", "caiu_cctrlr_phase", caiu_cctrlr_phase);

            if (($test$plusargs("caiu_cctrlr_mod")) && ($test$plusargs("caiu_tctrlr<%=i%>_val")) &&
                (caiu_cctrlr_phase==2)) begin
                tctrlr[<%=i%>] = caiu_tctrlr<%=i%>_val;
            end else if($test$plusargs("trigger<%=i%>_random")) begin
                tctrlr[<%=i%>] = $urandom();
            end else if($value$plusargs("tctrlr<%=i%>_value=%0x", tctrlr[<%=i%>])) begin
                // user-specified tctrlr
            end else begin : randomize_tctrlr_by_field
              begin: select_values_for_enables
                case ($urandom_range(100,1)) inside
                    ['d01:'d20]: trace<%=i%>_match_en_rand = 'h3f; // all enabled
                    ['d21:'d25]: trace<%=i%>_match_en_rand = 'h20; // enable one at a time
                    ['d26:'d30]: trace<%=i%>_match_en_rand = 'h10;
                    ['d31:'d35]: trace<%=i%>_match_en_rand = 'h08;
                    ['d36:'d40]: trace<%=i%>_match_en_rand = 'h04;
                    ['d41:'d45]: trace<%=i%>_match_en_rand = 'h02;
                    ['d46:'d50]: trace<%=i%>_match_en_rand = 'h01;
                    ['d51:'d60]: trace<%=i%>_match_en_rand = 'h00; // none enabled
                    default :    trace<%=i%>_match_en_rand = $urandom_range('h3f,'h00); // unconstrained
                endcase
                if($value$plusargs("trace_native_match_en=%0b", trace<%=i%>_native_match_en)) begin
                    // user-specified native_match_en
                end else begin
                    trace<%=i%>_native_match_en = trace<%=i%>_match_en_rand[0];
                end
                tctrlr[<%=i%>].native_trace_en = trace<%=i%>_native_match_en;
                if($value$plusargs("trace_addr_match_en=%0b", trace<%=i%>_addr_match_en)) begin
                    // user-specified addr_match_en
                end else begin
                    trace<%=i%>_addr_match_en = trace<%=i%>_match_en_rand[1];
                end
                tctrlr[<%=i%>].addr_match_en = trace<%=i%>_addr_match_en;
                if($value$plusargs("trace_opcode_match_en=%0b", trace<%=i%>_opcode_match_en)) begin
                    // user-specified opcode_match_en
                end else begin
                    trace<%=i%>_opcode_match_en = trace<%=i%>_match_en_rand[2];
                end
                tctrlr[<%=i%>].opcode_match_en = trace<%=i%>_opcode_match_en;
                if($value$plusargs("trace_memattr_match_en=%0b", trace<%=i%>_memattr_match_en)) begin
                    // user-specified memattr_match_en
                end else begin
                    trace<%=i%>_memattr_match_en = trace<%=i%>_match_en_rand[3];
                end
                tctrlr[<%=i%>].memattr_match_en = trace<%=i%>_memattr_match_en;
                if($value$plusargs("trace_user_match_en=%0b", trace<%=i%>_user_match_en)) begin
                    // user-specified user_match_en
                end else begin
                    trace<%=i%>_user_match_en = trace<%=i%>_match_en_rand[4];
                end
                tctrlr[<%=i%>].user_match_en = trace<%=i%>_user_match_en;
                if($value$plusargs("trace_target_type_match_en=%0b", trace<%=i%>_target_type_match_en)) begin
                    // user-specified target_type_match_en
                end else begin
                    trace<%=i%>_target_type_match_en = trace<%=i%>_match_en_rand[5];
                end
                tctrlr[<%=i%>].target_type_match_en = trace<%=i%>_target_type_match_en;
              end: select_values_for_enables

              begin: select_values_for_tctrlr_misc_fields
                if($value$plusargs("trace_addr_match_size=%0x", trace<%=i%>_addr_match_size)) begin
                    // user-specified addr_match_size
                end else begin
                    trace<%=i%>_addr_match_en = trace<%=i%>_match_en_rand[1];
                    case ($urandom_range(100,1)) inside
                        ['d01:'d10]: trace<%=i%>_addr_match_size = 'h1f; // max size
                        ['d11:'d20]: trace<%=i%>_addr_match_size = 'h00; // min size
                        default :    trace<%=i%>_addr_match_size = $urandom_range('h1f,'h00); // unconstrained
                    endcase
                end
                tctrlr[<%=i%>].range = trace<%=i%>_addr_match_size;

                if($value$plusargs("trace_memattr_match_value=%0x", trace<%=i%>_memattr_match_value)) begin
                    // user-specified memattr_match_value
                end else begin
                    trace<%=i%>_memattr_match_value = $urandom_range('hf,'h0); // unconstrained
                end
                tctrlr[<%=i%>].memattr = trace<%=i%>_memattr_match_value;

                // hut dii=1, dmi=0
                if($value$plusargs("trace_target_type_match_hut=%0b", trace<%=i%>_target_type_match_hut)) begin
                    // user-specified target_type_match_hut
                end else begin
                    trace<%=i%>_target_type_match_hut = $urandom_range('h1,'h0); // unconstrained
                end
                tctrlr[<%=i%>].hut = trace<%=i%>_target_type_match_hut;

                if($value$plusargs("trace_target_type_match_hui=%0b", trace<%=i%>_target_type_match_hui)) begin
                    // user-specified target_type_match_hui
                end else begin
                    case ($urandom_range(100,1)) inside
                        // 'h00 and 'h01 are most commonly seen in simulations, larger values are rare or do not occur
                        ['d01:'d10]: trace<%=i%>_target_type_match_hui = 'h00; 
                        ['d11:'d20]: trace<%=i%>_target_type_match_hui = 'h01; 
                        ['d21:'d30]: trace<%=i%>_target_type_match_hui = 'h02; 
                        default :    trace<%=i%>_target_type_match_hui = $urandom_range('h1f,'h00); // unconstrained
                    endcase
                end
                tctrlr[<%=i%>].hui = trace<%=i%>_target_type_match_hui;

              end: select_values_for_tctrlr_misc_fields
            end : randomize_tctrlr_by_field

            if (($test$plusargs("caiu_cctrlr_mod")) && ($test$plusargs("caiu_tbalr<%=i%>_val")) &&
                (caiu_cctrlr_phase==2)) begin
                tbalr[<%=i%>] = caiu_tbalr<%=i%>_val;
            end
            if (($test$plusargs("caiu_cctrlr_mod")) && ($test$plusargs("caiu_tbahr<%=i%>_val")) &&
                (caiu_cctrlr_phase==2)) begin
                tbahr[<%=i%>] = caiu_tbahr<%=i%>_val;
            end else if($test$plusargs("trigger<%=i%>_random")) begin
                tbalr[<%=i%>] = $urandom();
                tbahr[<%=i%>] = $urandom();
            end else if($value$plusargs("tbalr<%=i%>_value=%0x", tbalr[<%=i%>])) begin
                // user-specified tbalr
                $value$plusargs("tbahr<%=i%>_value=%0x", tbahr[<%=i%>]); 
                // user-specified tbahr
            end else begin
                case ($urandom_range(100,1)) inside
                    ['d01:'d10]: tbahr[<%=i%>] = 'h00; // min
                    ['d11:'d15]: tbahr[<%=i%>] = 'h01; // walk a one
                    ['d16:'d20]: tbahr[<%=i%>] = 'h02; 
                    ['d21:'d25]: tbahr[<%=i%>] = 'h04; 
                    ['d26:'d30]: tbahr[<%=i%>] = 'h08; 
                    ['d31:'d35]: tbahr[<%=i%>] = 'h10; 
                    ['d36:'d40]: tbahr[<%=i%>] = 'h20; 
                    ['d41:'d45]: tbahr[<%=i%>] = 'h40; 
                    ['d46:'d50]: tbahr[<%=i%>] = 'h80; 
                    ['d51:'d60]: tbahr[<%=i%>] = 'hff; // max
                    default :    tbahr[<%=i%>] = $urandom_range('hff,'h00); // unconstrained
                endcase
                case ($urandom_range(100,1)) inside
                    ['d01:'d10]: tbalr[<%=i%>] = 'h0000_0000; // min
                    ['d11:'d15]: tbalr[<%=i%>] = $urandom_range('h0000_00ff,'h0000_0000); // lower
                    ['d16:'d20]: tbalr[<%=i%>] = 'h0000_0100; 
                    ['d21:'d25]: tbalr[<%=i%>] = 'h0000_ff70; 
                    ['d26:'d30]: tbalr[<%=i%>] = 'h0001_0000; 
                    ['d31:'d35]: tbalr[<%=i%>] = 'h000f_f800; 
                    ['d36:'d40]: tbalr[<%=i%>] = 'h0010_0000; 
                    ['d41:'d45]: tbalr[<%=i%>] = 'h00ff_ff90; 
                    ['d46:'d50]: tbalr[<%=i%>] = 'h0100_0000; 
                    ['d51:'d55]: tbalr[<%=i%>] = 'h0fff_fff0; 
                    ['d56:'d60]: tbalr[<%=i%>] = 'h1000_0000; 
                    ['d61:'d65]: tbalr[<%=i%>] = 'ha5a5_a5a5; 
                    ['d66:'d70]: tbalr[<%=i%>] = 'h5a5a_5a5a; 
                    ['d71:'d75]: tbalr[<%=i%>] = $urandom_range('hffff_ffff,'hffff_ff00); // upper
                    ['d76:'d85]: tbalr[<%=i%>] = 'hffff_ffff; // max
                    default :    tbalr[<%=i%>] = $urandom_range('hffff_ffff,'h0000_0000); // unconstrained
                endcase
            end

            if (($test$plusargs("caiu_cctrlr_mod")) && ($test$plusargs("caiu_topcr0<%=i%>_val")) &&
                (caiu_cctrlr_phase==2)) begin
                topcr0[<%=i%>] = caiu_topcr0<%=i%>_val;
            end
            if (($test$plusargs("caiu_cctrlr_mod")) && ($test$plusargs("caiu_topcr1<%=i%>_val")) &&
                (caiu_cctrlr_phase==2)) begin
                topcr1[<%=i%>] = caiu_topcr1<%=i%>_val;
            end else if($test$plusargs("trigger<%=i%>_random")) begin
                topcr0[<%=i%>] = $urandom();
                topcr1[<%=i%>] = $urandom();
            // assume if user specifies topcr0 they also specify topcr1
            end else if($value$plusargs("topcr0<%=i%>_value=%0x", topcr0[<%=i%>])) begin
                // user-specified topcr0
                $value$plusargs("topcr1<%=i%>_value=%0x", topcr1[<%=i%>]);
                // user-specified topcr1
            end else begin : opcode_weighted_randomization
                case ($urandom_range(100,1)) inside
                    // prioritize more valids for a better chance of getting a match
                    ['d01:'d10]: trace<%=i%>_opcode_valids_rand = 'hf; // all
                    ['d11:'d15]: trace<%=i%>_opcode_valids_rand = 'h8; // one at a time
                    ['d16:'d20]: trace<%=i%>_opcode_valids_rand = 'h4; 
                    ['d21:'d25]: trace<%=i%>_opcode_valids_rand = 'h2; 
                    ['d26:'d30]: trace<%=i%>_opcode_valids_rand = 'h1; 
                    ['d31:'d35]: trace<%=i%>_opcode_valids_rand = 'h0; // none
                    default :    trace<%=i%>_opcode_valids_rand = $urandom_range('hf,'h0); // unconstrained
                endcase
                case ($urandom_range(100,1)) inside
                    // most of the time, choose values from 'h00 to 'h3f, not sure if values above 'h3f are possible for NCore 3.2
                    ['d01:'d90]: trace<%=i%>_opcode1 = $urandom_range('h3f,'h00);
                    ['d90:'d91]: trace<%=i%>_opcode1 = 'h7fff; // max value
                    default :    trace<%=i%>_opcode1 = $urandom_range('h7fff,'h0000); // unconstrained
                endcase
                case ($urandom_range(100,1)) inside
                    // most of the time, choose values from 'h00 to 'h3f, not sure if values above 'h3f are possible for NCore 3.2
                    ['d01:'d90]: trace<%=i%>_opcode2 = $urandom_range('h3f,'h00);
                    ['d90:'d91]: trace<%=i%>_opcode2 = 'h7fff; // max value
                    default :    trace<%=i%>_opcode2 = $urandom_range('h7fff,'h0000); // unconstrained
                endcase
                case ($urandom_range(100,1)) inside
                    // most of the time, choose values from 'h00 to 'h3f, not sure if values above 'h3f are possible for NCore 3.2
                    ['d01:'d90]: trace<%=i%>_opcode3 = $urandom_range('h3f,'h00);
                    ['d90:'d91]: trace<%=i%>_opcode3 = 'h7fff; // max value
                    default :    trace<%=i%>_opcode3 = $urandom_range('h7fff,'h0000); // unconstrained
                endcase
                case ($urandom_range(100,1)) inside
                    // most of the time, choose values from 'h00 to 'h3f, not sure if values above 'h3f are possible for NCore 3.2
                    ['d01:'d90]: trace<%=i%>_opcode4 = $urandom_range('h3f,'h00);
                    ['d90:'d91]: trace<%=i%>_opcode4 = 'h7fff; // max value
                    default :    trace<%=i%>_opcode4 = $urandom_range('h7fff,'h0000); // unconstrained
                endcase
                topcr0[<%=i%>].valid1  = trace<%=i%>_opcode_valids_rand[0];
                topcr0[<%=i%>].valid2  = trace<%=i%>_opcode_valids_rand[1];
                topcr1[<%=i%>].valid3  = trace<%=i%>_opcode_valids_rand[2];
                topcr1[<%=i%>].valid4  = trace<%=i%>_opcode_valids_rand[3];
                topcr0[<%=i%>].opcode1 = trace<%=i%>_opcode1;
                topcr0[<%=i%>].opcode2 = trace<%=i%>_opcode2;
                topcr1[<%=i%>].opcode3 = trace<%=i%>_opcode3;
                topcr1[<%=i%>].opcode4 = trace<%=i%>_opcode4;
            end : opcode_weighted_randomization

            if (($test$plusargs("caiu_cctrlr_mod")) && ($test$plusargs("caiu_tubr<%=i%>_val")) &&
                (caiu_cctrlr_phase==2)) begin
                tubr[<%=i%>] = caiu_tubr<%=i%>_val;
            end else if($test$plusargs("trigger<%=i%>_random")) begin
                tubr[<%=i%>] = $urandom();
            end else if($value$plusargs("tubr<%=i%>_value=%0x", tubr[<%=i%>])) begin
                // user-specified tubr
            end else begin : tubr_weighted_randomization
                case ($urandom_range(100,1)) inside
                    ['d01:'d20]: tubr[<%=i%>] = 'h0000_0000; 
                    ['d21:'d40]: tubr[<%=i%>] = $urandom_range('hf,'h0);
                    ['d41:'d41]: tubr[<%=i%>] = 'h0000_0010; 
                    ['d42:'d42]: tubr[<%=i%>] = 'h0000_0020; 
                    ['d43:'d43]: tubr[<%=i%>] = 'h0000_0040; 
                    ['d44:'d44]: tubr[<%=i%>] = 'h0000_0080; 
                    ['d45:'d45]: tubr[<%=i%>] = 'h0000_0100; 
                    ['d46:'d46]: tubr[<%=i%>] = 'h0000_0200; 
                    ['d47:'d47]: tubr[<%=i%>] = 'h0000_0400; 
                    ['d48:'d48]: tubr[<%=i%>] = 'h0000_0800; 
                    ['d49:'d49]: tubr[<%=i%>] = 'h0000_1000; 
                    ['d50:'d50]: tubr[<%=i%>] = 'h0000_2000; 
                    ['d51:'d51]: tubr[<%=i%>] = 'h0000_4000; 
                    ['d52:'d52]: tubr[<%=i%>] = 'h0000_8000; 
                    ['d53:'d53]: tubr[<%=i%>] = 'h0001_0000; 
                    ['d54:'d54]: tubr[<%=i%>] = 'h0002_0000; 
                    ['d55:'d55]: tubr[<%=i%>] = 'h0004_0000; 
                    ['d56:'d56]: tubr[<%=i%>] = 'h0008_0000; 
                    ['d57:'d57]: tubr[<%=i%>] = 'h0010_0000; 
                    ['d58:'d58]: tubr[<%=i%>] = 'h0020_0000; 
                    ['d59:'d59]: tubr[<%=i%>] = 'h0040_0000; 
                    ['d60:'d60]: tubr[<%=i%>] = 'h0080_0000; 
                    ['d61:'d61]: tubr[<%=i%>] = 'h0100_0000; 
                    ['d62:'d62]: tubr[<%=i%>] = 'h0200_0000; 
                    ['d63:'d63]: tubr[<%=i%>] = 'h0400_0000; 
                    ['d64:'d64]: tubr[<%=i%>] = 'h0800_0000; 
                    ['d65:'d65]: tubr[<%=i%>] = 'h1000_0000; 
                    ['d66:'d66]: tubr[<%=i%>] = 'h2000_0000; 
                    ['d67:'d67]: tubr[<%=i%>] = 'h4000_0000; 
                    ['d68:'d68]: tubr[<%=i%>] = 'h8000_0000; 
                    ['d69:'d74]: tubr[<%=i%>] = 'hffff_ffff; 
                    ['d75:'d79]: tubr[<%=i%>] = $urandom_range('hffff_ffff,'hffff_fff0);
                    default :    tubr[<%=i%>] = $urandom_range('hffff_ffff,'h0000_0000); // unconstrained
                endcase
            end : tubr_weighted_randomization

            if (($test$plusargs("caiu_cctrlr_mod")) && ($test$plusargs("caiu_tubmr<%=i%>_val")) &&
                (caiu_cctrlr_phase==2)) begin
                tubmr[<%=i%>] = caiu_tubmr<%=i%>_val;
            end else if($test$plusargs("trigger<%=i%>_random")) begin
                tubmr[<%=i%>] = $urandom();
            end else if($value$plusargs("tubmr<%=i%>_value=%0x", tubmr[<%=i%>])) begin
                // user-specified tubmr
            end else begin : tubmr_weighted_randomization
                case ($urandom_range(100,1)) inside
                    ['d01:'d20]: tubmr[<%=i%>] = 'h0000_0000; 
                    ['d21:'d40]: tubmr[<%=i%>] = $urandom_range('hf,'h0);
                    ['d41:'d41]: tubmr[<%=i%>] = 'h0000_0010; 
                    ['d42:'d42]: tubmr[<%=i%>] = 'h0000_0020; 
                    ['d43:'d43]: tubmr[<%=i%>] = 'h0000_0040; 
                    ['d44:'d44]: tubmr[<%=i%>] = 'h0000_0080; 
                    ['d45:'d45]: tubmr[<%=i%>] = 'h0000_0100; 
                    ['d46:'d46]: tubmr[<%=i%>] = 'h0000_0200; 
                    ['d47:'d47]: tubmr[<%=i%>] = 'h0000_0400; 
                    ['d48:'d48]: tubmr[<%=i%>] = 'h0000_0800; 
                    ['d49:'d49]: tubmr[<%=i%>] = 'h0000_1000; 
                    ['d50:'d50]: tubmr[<%=i%>] = 'h0000_2000; 
                    ['d51:'d51]: tubmr[<%=i%>] = 'h0000_4000; 
                    ['d52:'d52]: tubmr[<%=i%>] = 'h0000_8000; 
                    ['d53:'d53]: tubmr[<%=i%>] = 'h0001_0000; 
                    ['d54:'d54]: tubmr[<%=i%>] = 'h0002_0000; 
                    ['d55:'d55]: tubmr[<%=i%>] = 'h0004_0000; 
                    ['d56:'d56]: tubmr[<%=i%>] = 'h0008_0000; 
                    ['d57:'d57]: tubmr[<%=i%>] = 'h0010_0000; 
                    ['d58:'d58]: tubmr[<%=i%>] = 'h0020_0000; 
                    ['d59:'d59]: tubmr[<%=i%>] = 'h0040_0000; 
                    ['d60:'d60]: tubmr[<%=i%>] = 'h0080_0000; 
                    ['d61:'d61]: tubmr[<%=i%>] = 'h0100_0000; 
                    ['d62:'d62]: tubmr[<%=i%>] = 'h0200_0000; 
                    ['d63:'d63]: tubmr[<%=i%>] = 'h0400_0000; 
                    ['d64:'d64]: tubmr[<%=i%>] = 'h0800_0000; 
                    ['d65:'d65]: tubmr[<%=i%>] = 'h1000_0000; 
                    ['d66:'d66]: tubmr[<%=i%>] = 'h2000_0000; 
                    ['d67:'d67]: tubmr[<%=i%>] = 'h4000_0000; 
                    ['d68:'d68]: tubmr[<%=i%>] = 'h8000_0000; 
                    ['d69:'d74]: tubmr[<%=i%>] = 'hffff_ffff; 
                    ['d75:'d79]: tubmr[<%=i%>] = $urandom_range('hffff_ffff,'hffff_fff0);
                    default :    tubmr[<%=i%>] = $urandom_range('hffff_ffff,'h0000_0000); // unconstrained
                endcase
            end : tubmr_weighted_randomization

            // zero out bits that should not exist in the RTL for this particular config

            // CHI-A does not support native traceme
            <% if (obj.AiuInfo[obj.Id].fnNativeInterface == 'CHI-A') { %>
            tctrlr[<%=i%>].native_trace_en = 0;
            <%}%>

            tctrlr[<%=i%>].aw = 0; // CHI does not have aw
            tctrlr[<%=i%>].ar = 0; // CHI does not have ar

            // set user_match_en to always 0 when user bit width is 0, CONC-7967
            <% if(!obj.AiuInfo[obj.Id].interfaces.chiInt.params.REQ_RSVDC) {%>
            tctrlr[<%=i%>].user_match_en = 0;
            tubr[<%=i%>].user = 0;
            tubmr[<%=i%>].user_mask = 0;
            <%}%>

            // ------------------------------------------------------------------------
            // Fix for CONC-8950....Storing all the enablements bits of the TCTRLR 
            // register. Those might get restored at phase2 as indicated in CONC-7967. 
            if (($test$plusargs("caiu_cctrlr_mod")) && ("caiu_cctrlr_phase==0") && (trackPhase <= <%=i%>)) begin
               tctrlr_save[<%=i%>] = tctrlr[<%=i%>];
               ++trackPhase;
            end;

           // -----------------------------------------------------
           // Restored the enablement bits.
           if (caiu_cctrlr_phase==1) begin
               tctrlr[<%=i%>] = tctrlr_save[<%=i%>];     // CONC-8950

               tubmr[<%=i%>]  = 32'h0;
               tubr[<%=i%>]   = 32'h0;
               topcr0[<%=i%>] = 32'h0;
               topcr1[<%=i%>] = 32'h0;
               tbalr[<%=i%>]  = 32'h0;
               tbahr[<%=i%>]  = 32'h0;

              `uvm_info(get_name(), $sformatf("All Trace Regs have been reset as caiu_cctrlr_phase=1."), UVM_HIGH)
            end

           if (caiu_cctrlr_phase==2) begin
              if (<%=i%> == 0 || (tctrlr[0][0]==1))      // CONC-8950
                 tctrlr[<%=i%>] = tctrlr_save[<%=i%>];
           end
      
            // write register values to RTL
            // fixme: billc: 2021-09-30, decide whether or not to add code to not write certain registers if the corresponding match_en is 0
            <% if (obj.AiuInfo[obj.Id].fnNativeInterface != 'CHI-A') { %>
            write_csr(m_regs.<%=obj.BlockId%>.CAIUTCTRLR<%=i%>.native_trace_en, tctrlr[<%=i%>].native_trace_en);
            <%}%>
            write_csr(m_regs.<%=obj.BlockId%>.CAIUTCTRLR<%=i%>.addr_match_en, tctrlr[<%=i%>].addr_match_en);
            write_csr(m_regs.<%=obj.BlockId%>.CAIUTCTRLR<%=i%>.opcode_match_en, tctrlr[<%=i%>].opcode_match_en);
            write_csr(m_regs.<%=obj.BlockId%>.CAIUTCTRLR<%=i%>.memattr_match_en, tctrlr[<%=i%>].memattr_match_en);
            <% if(obj.AiuInfo[obj.Id].interfaces.chiInt.params.REQ_RSVDC) {%>
            write_csr(m_regs.<%=obj.BlockId%>.CAIUTCTRLR<%=i%>.user_match_en, tctrlr[<%=i%>].user_match_en);
            <%}%>
            write_csr(m_regs.<%=obj.BlockId%>.CAIUTCTRLR<%=i%>.target_type_match_en, tctrlr[<%=i%>].target_type_match_en);
            write_csr(m_regs.<%=obj.BlockId%>.CAIUTCTRLR<%=i%>.hut, tctrlr[<%=i%>].hut);
            write_csr(m_regs.<%=obj.BlockId%>.CAIUTCTRLR<%=i%>.hui, tctrlr[<%=i%>].hui);
            write_csr(m_regs.<%=obj.BlockId%>.CAIUTCTRLR<%=i%>.range, tctrlr[<%=i%>].range);
            //write_csr(m_regs.<%=obj.BlockId%>.CAIUTCTRLR<%=i%>.aw, tctrlr[<%=i%>].aw); // aw does not exist for CHI
            //write_csr(m_regs.<%=obj.BlockId%>.CAIUTCTRLR<%=i%>.ar, tctrlr[<%=i%>].ar); // ar does not exist for CHI
            write_csr(m_regs.<%=obj.BlockId%>.CAIUTCTRLR<%=i%>.memattr, tctrlr[<%=i%>].memattr);

            write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUTBALR<%=i%>.base_addr_lo, tbalr[<%=i%>].base_addr_43_12);

            write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUTBAHR<%=i%>.base_addr_hi, tbahr[<%=i%>].base_addr_51_44);

            topcr0[<%=i%>].opcode1 = topcr0[<%=i%>].opcode1 & {WREQOPCODE{1'b1}};
            topcr0[<%=i%>].opcode2 = topcr0[<%=i%>].opcode2 & {WREQOPCODE{1'b1}};
            topcr1[<%=i%>].opcode3 = topcr1[<%=i%>].opcode3 & {WREQOPCODE{1'b1}};
            topcr1[<%=i%>].opcode4 = topcr1[<%=i%>].opcode4 & {WREQOPCODE{1'b1}};
            write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUTOPCR0<%=i%>.opcode1, topcr0[<%=i%>].opcode1);
            write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUTOPCR0<%=i%>.valid1,  topcr0[<%=i%>].valid1);
            write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUTOPCR0<%=i%>.opcode2, topcr0[<%=i%>].opcode2);
            write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUTOPCR0<%=i%>.valid2,  topcr0[<%=i%>].valid2);
            write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUTOPCR1<%=i%>.opcode3, topcr1[<%=i%>].opcode3);
            write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUTOPCR1<%=i%>.valid3,  topcr1[<%=i%>].valid3);
            write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUTOPCR1<%=i%>.opcode4, topcr1[<%=i%>].opcode4);
            write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUTOPCR1<%=i%>.valid4,  topcr1[<%=i%>].valid4);

            <% if(obj.AiuInfo[obj.Id].interfaces.chiInt.params.REQ_RSVDC) {%>
            tubr[<%=i%>].user = tubr[<%=i%>].user & {WREQRSVDC{1'b1}};
            tubmr[<%=i%>].user_mask = tubmr[<%=i%>].user_mask & {WREQRSVDC{1'b1}};
            write_csr(m_regs.<%=obj.BlockId%>.CAIUTUBR<%=i%>.user, tubr[<%=i%>].user);
            write_csr(m_regs.<%=obj.BlockId%>.CAIUTUBMR<%=i%>.user_mask, tubmr[<%=i%>].user_mask);
            <%}%>

            // pass register values to the scoreboard.
            chi_aiu_scb::tctrlr[<%=i%>] =  tctrlr[<%=i%>];
            chi_aiu_scb::tbalr[<%=i%>]  =  tbalr[<%=i%>];
            chi_aiu_scb::tbahr[<%=i%>]  =  tbahr[<%=i%>];
            chi_aiu_scb::topcr0[<%=i%>] =  topcr0[<%=i%>];
            chi_aiu_scb::topcr1[<%=i%>] =  topcr1[<%=i%>];
            chi_aiu_scb::tubr[<%=i%>]   =  tubr[<%=i%>];
            chi_aiu_scb::tubmr[<%=i%>]  =  tubmr[<%=i%>];

            `uvm_info(get_name(), $sformatf("TTRI: tctrlr[<%=i%>]               = %8h", tctrlr[<%=i%>]), UVM_HIGH)
            `uvm_info(get_name(), $sformatf("TTRI: tbalr[<%=i%>]                = %8h", tbalr[<%=i%>]), UVM_HIGH)
            `uvm_info(get_name(), $sformatf("TTRI: tbahr[<%=i%>]                = %8h", tbahr[<%=i%>]), UVM_HIGH)
            `uvm_info(get_name(), $sformatf("TTRI: topcr0[<%=i%>]               = %8h", topcr0[<%=i%>]), UVM_HIGH)
            `uvm_info(get_name(), $sformatf("TTRI: topcr1[<%=i%>]               = %8h", topcr1[<%=i%>]), UVM_HIGH)
            `uvm_info(get_name(), $sformatf("TTRI: tubr[<%=i%>]                 = %8h", tubr[<%=i%>]), UVM_HIGH)
            `uvm_info(get_name(), $sformatf("TTRI: tubmr[<%=i%>]                = %8h", tubmr[<%=i%>]), UVM_HIGH)
            `uvm_info(get_name(), $sformatf("TTRI: trace<%=i%>_match_en_rand         = %6b",  trace<%=i%>_match_en_rand), UVM_HIGH)
            `uvm_info(get_name(), $sformatf("TTRI: trace<%=i%>_native_match_en       = %b",  trace<%=i%>_native_match_en), UVM_HIGH)
            `uvm_info(get_name(), $sformatf("TTRI: trace<%=i%>_addr_match_en         = %b",  trace<%=i%>_addr_match_en), UVM_HIGH)
            `uvm_info(get_name(), $sformatf("TTRI: trace<%=i%>_opcode_match_en       = %b",  trace<%=i%>_opcode_match_en), UVM_HIGH)
            `uvm_info(get_name(), $sformatf("TTRI: trace<%=i%>_memattr_match_en      = %b",  trace<%=i%>_memattr_match_en), UVM_HIGH)
            `uvm_info(get_name(), $sformatf("TTRI: trace<%=i%>_user_match_en         = %b",  trace<%=i%>_user_match_en), UVM_HIGH)
            `uvm_info(get_name(), $sformatf("TTRI: trace<%=i%>_target_type_match_en  = %b",  trace<%=i%>_target_type_match_en), UVM_HIGH)
            `uvm_info(get_name(), $sformatf("TTRI: match_en native       = %b, addr = %b, opcode = %b, memattr = %b, user = %b, target_type = %b", trace<%=i%>_native_match_en, trace<%=i%>_addr_match_en, trace<%=i%>_opcode_match_en, trace<%=i%>_memattr_match_en, trace<%=i%>_user_match_en, trace<%=i%>_target_type_match_en), UVM_HIGH)
            `uvm_info(get_name(), $sformatf("TTRI: trace<%=i%>_addr_match_size       = %h", trace<%=i%>_addr_match_size), UVM_HIGH)
            `uvm_info(get_name(), $sformatf("TTRI: trace<%=i%>_memattr_match_value   = %h", trace<%=i%>_memattr_match_value), UVM_HIGH)
            `uvm_info(get_name(), $sformatf("TTRI: trace<%=i%>_opcode_valids_rand    = %4b", trace<%=i%>_opcode_valids_rand), UVM_HIGH)
            `uvm_info(get_name(), $sformatf("TTRI: trace<%=i%>_opcode1               = %4h", trace<%=i%>_opcode1), UVM_HIGH)
            `uvm_info(get_name(), $sformatf("TTRI: trace<%=i%>_opcode2               = %4h", trace<%=i%>_opcode2), UVM_HIGH)
            `uvm_info(get_name(), $sformatf("TTRI: trace<%=i%>_opcode3               = %4h", trace<%=i%>_opcode3), UVM_HIGH)
            `uvm_info(get_name(), $sformatf("TTRI: trace<%=i%>_opcode4               = %4h", trace<%=i%>_opcode4), UVM_HIGH)
            `uvm_info(get_name(), $sformatf("TTRI: trace<%=i%>_target_type_match_hut = %b", trace<%=i%>_target_type_match_hut), UVM_HIGH)
            `uvm_info(get_name(), $sformatf("TTRI: trace<%=i%>_target_type_match_hui = %5h", trace<%=i%>_target_type_match_hui), UVM_HIGH)

        end : ttrig_reg_prog_en_code_<%=i%>
        <%}%>

        if ($test$plusargs("tcap_reg_prog_en")) begin : tcap_reg_prog_en_code
            bit [31:0] set_value = 0;
            bit [7:0]  smi_cap   = 0;
            bit [3:0]  gain      = 0;
            bit [11:0] inc       = 0;

            if (($test$plusargs("caiu_cctrlr_mod")) && ($test$plusargs("caiu_cctrlr_val")) &&
                (caiu_cctrlr_phase==2)) begin
                smi_cap = caiu_cctrlr_val[7:0];
                gain    = caiu_cctrlr_val[19:16];
                inc     = caiu_cctrlr_val[31:20];
            end else if ($test$plusargs("cctrlr_random")) begin
                std::randomize(smi_cap);
                std::randomize(gain);
                std::randomize(inc);
                `uvm_info(get_name(), $sformatf("<%=obj.DutInfo.strRtlNamePrefix%> Set CCRTRLR to random values. SMI_CAPT=%0h, GAIN=%0d, VALUE=%0d", smi_cap, gain, inc), UVM_LOW)
            end else if ($value$plusargs("cctrlr_value=0x%0h", set_value)) begin
                smi_cap      = set_value[7:0];
                gain         = set_value[19:16];
                inc          = set_value[31:20];
                `uvm_info(get_name(), $sformatf("<%=obj.DutInfo.strRtlNamePrefix%> Set CCRTRLR through cmdln=%0h. SMI_CAPT=%0h, GAIN=%0d, INC=%0d", set_value, smi_cap, gain, inc), UVM_LOW)
            end else begin : weighted_random
                if ($value$plusargs("cctrlr_enables=0x%0h", smi_cap)) begin
                  // user-specified smi_cap
                end else begin : cctrlr_enables_weighted_random
                  case ($urandom_range(100,1)) inside
                    ['d01:'d10]: smi_cap = 'hff; // all on DMI
                    ['d11:'d20]: smi_cap = 'hcf; // all on CHI
                    ['d21:'d22]: smi_cap = 'h01; // try one at a time
                    ['d23:'d24]: smi_cap = 'h02;
                    ['d25:'d26]: smi_cap = 'h04;
                    ['d27:'d28]: smi_cap = 'h08;
                    ['d29:'d30]: smi_cap = 'h10;
                    ['d31:'d32]: smi_cap = 'h20;
                    ['d33:'d34]: smi_cap = 'h40;
                    ['d35:'d36]: smi_cap = 'h80;
                    ['d37:'d70]: smi_cap = 'h00; // all off
                    default :    smi_cap = $urandom_range('hff,'h00); // unconstrained
                  endcase
                end : cctrlr_enables_weighted_random
                if ($value$plusargs("cctrlr_gain=0x%0h", gain)) begin
                  // user-specified gain
                end else begin : cctrlr_gain_weighted_random 
                  case ($urandom_range(100,1)) inside
                    ['d01:'d50]: gain = 'h0; // disables TS corrections
                    default :    gain = $urandom_range('hf,'h0); // unconstrained
                  endcase
                end : cctrlr_gain_weighted_random
                if ($value$plusargs("cctrlr_inc_integer=0x%0h", inc[11:8])) begin
                  // user-specified inc integer
                end else begin : cctrlr_inc_integer_weighted_random 
                  case ($urandom_range(100,1)) inside
                    ['d01:'d25]: inc[11:8] = 'h0;
                    ['d26:'d50]: inc[11:8] = 'hf;
                    default :    inc[11:8] = $urandom_range('hf,'h0); // unconstrained
                  endcase
                end : cctrlr_inc_integer_weighted_random
                if ($value$plusargs("cctrlr_inc_fractional=0x%0h", inc[7:0])) begin
                  // user-specified inc fractional
                end else begin : cctrlr_inc_fractional_weighted_random 
                  case ($urandom_range(100,1)) inside
                    ['d01:'d25]: inc[7:0] = 'h00;
                    ['d26:'d50]: inc[7:0] = 'hff;
                    default :    inc[7:0] = $urandom_range('hff,'h00); // unconstrained
                  endcase
                end : cctrlr_inc_fractional_weighted_random
            end : weighted_random

            uvm_config_db#(int)::get(null, "*", "caiu_cctrlr_phase", caiu_cctrlr_phase);

            if ($test$plusargs("caiu_cctrlr_mod") && (caiu_cctrlr_phase != 0)) begin
                // CCTRLR[7:0] are updated
                smi_cap = (caiu_cctrlr_phase==2) ? smi_cap : 0;
		<% for (i=0; i < obj.DutInfo.nTraceRegisters; ++i) {%>
                tctrlr[<%=i%>] = (caiu_cctrlr_phase==2) ? tctrlr[<%=i%>] : 0;
        	<%}%>
            end

            write_data = (smi_cap >> 0) & 1;
            write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUCCTRLR.ndn0Tx, write_data);
            trace_debug_scb::port_capture_en[0] = write_data ? (smi_cap[0] | 'b1) : (smi_cap[0] & 'b0);

            write_data = (smi_cap >> 1) & 1;
            write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUCCTRLR.ndn0Rx, write_data);
            trace_debug_scb::port_capture_en[1] = write_data ? (smi_cap[1] | 'b1) : (smi_cap[1] & 'b0);

            write_data = (smi_cap >> 2) & 1;
            write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUCCTRLR.ndn1Tx, write_data);
            trace_debug_scb::port_capture_en[2] = write_data ? (smi_cap[2] | 'b1) : (smi_cap[2] & 'b0);

            write_data = (smi_cap >> 3) & 1;
            write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUCCTRLR.ndn1Rx, write_data);
            trace_debug_scb::port_capture_en[3] = write_data ? (smi_cap[3] | 'b1) : (smi_cap[3] & 'b0);

            write_data = (smi_cap >> 4) & 1;
            write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUCCTRLR.ndn2Tx, write_data);
            trace_debug_scb::port_capture_en[4] = write_data ? (smi_cap[4] | 'b1) : (smi_cap[4] & 'b0);

            write_data = (smi_cap >> 5) & 1;
            write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUCCTRLR.ndn2Rx, write_data);
            trace_debug_scb::port_capture_en[5] = write_data ? (smi_cap[5] | 'b1) : (smi_cap[5] & 'b0);

            write_data = (smi_cap >> 6) & 1;
            write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUCCTRLR.dn0Tx , write_data);
            trace_debug_scb::port_capture_en[6] = write_data ? (smi_cap[6] | 'b1) : (smi_cap[6] & 'b0);

            write_data = (smi_cap >> 7) & 1;
            write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUCCTRLR.dn0Rx , write_data);
            trace_debug_scb::port_capture_en[7] = write_data ? (smi_cap[7] | 'b1) : (smi_cap[7] & 'b0);

            write_data = gain;
            write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUCCTRLR.gain  , write_data);
            trace_debug_scb::gain = write_data;

            write_data = inc;
            write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUCCTRLR.inc   , write_data);
            trace_debug_scb::inc = write_data;

        end : tcap_reg_prog_en_code

        //trigger event to notify trace trigger csr programming is done.
        ev.trigger();
        if ($test$plusargs("ttrig_reg_prog_en")) begin
            csr_trace_debug_done.trigger(null);
        end
    endtask : body

endclass : chi_aiu_csr_trace_debug_seq


class csr_connectivity_seq extends chi_aiu_ral_csr_base_seq; 
  `uvm_object_utils(csr_connectivity_seq)

    uvm_reg_data_t poll_data, read_data, write_data;
    bit [WSMIADDR-1:0] exp_addr;
    bit [WSMIADDR-1:0] erraddr_q[$];
    bit [3:0] expected_err_type = 'hC;
    bit [19:0] err_addr;
    bit [19:0] exp_errinfo;
    bit [19:0] errinfo_q[$];
    bit cmdType;
    chi_txnid_t txn_id;
    int addr_idx;
    bit dec_err_det_en, dec_err_int_en;

    function new(string name="");
        super.new(name);
    endfunction

    task body();
        getsb_handle();
        getCsrProbeIf();
        erraddr_q.delete();
        errinfo_q.delete();

        // Set CAIUUEDR_ErrDetEn reg
        // #Stimulus.CHIAIU.v3.4.Connectivity.ErrDetEnErrDetInt
        if(!$value$plusargs("connectivity_dec_err_det=%0d", dec_err_det_en))
          dec_err_det_en = 1;
        write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUUEDR.SoftwareProgConfigErrDetEn, dec_err_det_en);//#Check.CHIAIU.v3.Error.decodeerr
        write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUUEDR.DecErrDetEn, dec_err_det_en);//#Check.CHIAIU.v3.Error.decodeerr

         // Set CAIUUEDR_ErrIntEn reg     
         // #Stimulus.CHIAIU.v3.4.Connectivity.ErrDetEnErrDetInt
        if(!$value$plusargs("connectivity_dec_err_int=%0d", dec_err_int_en))
        dec_err_int_en = 1;
        write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUUEIR.SoftwareProgConfigErrIntEn, dec_err_int_en);
        write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUUEIR.DecErrIntEn, dec_err_int_en);

        ev.trigger();

        if (dec_err_det_en) begin

          //keep on Reading the CAIUUESR_ErrVld bit = 1
          poll_CAIUUESR_ErrVld(1, poll_data);
  
          // foreach (chi_scb.csr_addr_decode_err_addr_q[i]) begin  // Not used anymore as problem of "foreach queue ordering"
          for( int i=0; i < chi_scb.csr_addr_decode_err_addr_q.size();i++) begin 
            exp_addr = chi_scb.csr_addr_decode_err_addr_q[i];
            if ($test$plusargs("addr_no_hit_check") || $test$plusargs("illegal_dii_access_check")) begin
              // For Software Programming or Configuration Error ==>  [19:4] – Reserved (set to zero)
              // For Decode Error ==>  [7:6] - Reserved (set to zero)
              // For Decode Error ==>  [5:4] – Command Type 2'b1x: Not used, reserved
              exp_errinfo[19:8] = chi_scb.csr_addr_decode_err_msg_id_q[i];
              exp_errinfo[4] = chi_scb.csr_addr_decode_err_cmd_type_q[i];
            end
            exp_errinfo[3:0] = {'b0,chi_scb.csr_addr_decode_err_type_q[i]};
            errinfo_q.push_back(exp_errinfo);
            erraddr_q.push_back(exp_addr);
          end

          `uvm_info(get_full_name(),$sformatf("erraddr_q = %0p, errinfo_q = %0p",erraddr_q,errinfo_q),UVM_NONE)

          read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUUESR.ErrInfo, read_data);
          if ($test$plusargs("addr_no_hit_check") || $test$plusargs("illegal_dii_access_check")) begin
          uvm_config_db#(int)::set(null,"*","chi_dec_err_type",read_data); //for coverage
          end else begin
          uvm_config_db#(int)::set(null,"*","chi_soft_prog_err_type",read_data);//for coverage
          end

          if (!(read_data inside {errinfo_q})) begin
            `uvm_error(get_full_name(),$sformatf("Expected error info should be inside %0p, Actual ErrInfo = %0h",errinfo_q,read_data))
          end

          txn_id = read_data[19:8]; // Transaction ID
          cmdType = read_data[4];   // Command Type (Write/Read)
          for( int i=0; i < errinfo_q.size();i++) begin 
              if(errinfo_q[i][19:8] == txn_id && errinfo_q[i][4] == cmdType) begin
              exp_errinfo = errinfo_q[i];
              exp_addr = erraddr_q[i];
              break;
            end
          end
          //#Check.CHIAIU.v3.4.Connectivity.ErrorLogging
          //#Check.CHIAIU.v3.4.Connectivity.ErrorPriority
          if     ($test$plusargs("dce_connectivity_check"))   exp_errinfo[3:0] = 'b0101; // unconnected DCE unit access
          else if($test$plusargs("dmi_connectivity_check"))   exp_errinfo[3:0] = 'b0010; // unconnected DMI unit access
          else if($test$plusargs("dii_connectivity_check"))   exp_errinfo[3:0] = 'b0011; // unconnected DII unit access
          else if($test$plusargs("addr_no_hit_check"))        exp_errinfo[3:0] = 'b0000; // No address hit
          else if($test$plusargs("illegal_dii_access_check")) exp_errinfo[3:0] = 'b0011; // Illegal DII access type

          if ($test$plusargs("addr_no_hit_check") || $test$plusargs("illegal_dii_access_check")) begin
            expected_err_type = 'h7;
          end
          
          compareValues("CAIUUESR_Errinfo", "", read_data, exp_errinfo); 

          read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUUESR.ErrType, read_data);
          uvm_config_db#(int)::set(null,"*","chi_errtype_code",read_data); //for coverage
          compareValues("CAIUUESR_ErrType", "", read_data, expected_err_type); //Address_decode error
          
          read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUUELR0.ErrAddr, read_data);
          compareValues("CAIUUELR0_ErrAddress", "exp_addr", read_data, exp_addr[31:0]); 

          read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUUELR1.ErrAddr, read_data);
          <% if(obj.AiuInfo[obj.Id].interfaces.chiInt.params.wAddr > 32+20) { %>
            compareValues("CAIUUELR1_ErrAddr", "", read_data, exp_addr[WSMIADDR-1:WSMIADDR-20]); // 20 MSBs of Address decode error
          <% } else if(obj.AiuInfo[obj.Id].interfaces.chiInt.params.wAddr > 32)  { %>
            compareValues("CAIUUELR1_ErrAddr", "", read_data, exp_addr[WSMIADDR-1:32]); // Up to 20 addr bits down to bit 32 of Address decode error
          <% } else { %>
            compareValues("CAIUUELR1_ErrAddr", "", read_data, 0); //  Address decode error
          <% } %>

          fork : irq_fork
            begin
              if (dec_err_int_en) begin
                //#Check.CHIAIU.v3.4.Connectivity.ErrorLogging
                wait (u_csr_probe_vif.IRQ_UC === 1);
                uvm_config_db#(int)::set(null,"*","chi_irq_uc",u_csr_probe_vif.IRQ_UC); //for coverage
                <% if(obj.AiuInfo[obj.Id].ResilienceInfo.fnResiliencyProtectionType == "parity" || obj.AiuInfo[obj.Id].ResilienceInfo.fnResiliencyProtectionType == "ecc") { %>
                //#Check.CHIAIU.v3.4.Connectivity.MissionFault
                //wait (u_csr_probe_vif.fault_mission_fault === 1); // CONC-7064 
                <% } %>                
              end
            end
            begin
              #200000ns;
              `uvm_error(get_name(),$sformatf("Timeout! Did not see IRQ_UC asserted"));
            end
          join_any
          disable irq_fork;
            
        end

        write_data = 0;
        write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUUEDR.SoftwareProgConfigErrDetEn, write_data);
        write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUUEIR.SoftwareProgConfigErrIntEn, write_data);
        write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUUEDR.DecErrDetEn, write_data);
        write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUUEIR.DecErrIntEn, write_data);
        write_data = 1;
        write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUUESR.ErrVld, write_data);
        // Read the CAIUUESR_ErrVld should be cleared
        read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUUESR.ErrVld, read_data);
        compareValues("CAIUUESR_ErrVld", "now clear", read_data, 0);

    endtask
endclass : csr_connectivity_seq

//-----------------------------------------------------------------------
//-----------------------------------------------------------------------
/**
* Abstract:
* 
* This sequence programs the required registers for Sys Req events 
* verification
*     - This will program the timeouts and enable-disable csrs 
*/
//-----------------------------------------------------------------------
//-----------------------------------------------------------------------
//
class chiaiu_csr_sysreq_event_seq extends chi_aiu_ral_csr_base_seq; 
   `uvm_object_utils(chiaiu_csr_sysreq_event_seq)
    uvm_reg_data_t write_data;
    uvm_reg_data_t read_data;

    rand int ev_disable_clock_cycles;  // introduce this delay while enabling and disabling events
    int ev_enable_toggle_count;
    bit ev_enable=1;
    bit err_det_en;
    bit intr_en;
    int tmp;
    bit mission_fault_asserted; 

    constraint c_ev_disable_clock_cycles{
      ev_disable_clock_cycles inside {[1:5000]};
    }

    function new(string name="");
        super.new(name);
    endfunction

    task body();
        getCsrProbeIf();
	tmp = $urandom_range(1,2);

          if(!uvm_config_db#(bit)::get(null,"","mission_fault_asserted",mission_fault_asserted))
              begin 
              `uvm_info(get_full_name(),"mission fault is not asserted",UVM_LOW)
              end

        <% if (obj.useResiliency) { %>
            if(mission_fault_asserted)begin
              ev_bist_reset_done.wait_ptrigger();
            end 
        <%}%>
        fork
            // program Error Related registers when timeout is enabled
            begin
                if($test$plusargs("ev_enable_toggle")) begin
                    write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUTCR.EventDisable, 1'b1);
                    `uvm_info("EV CSR SEQ",$sformatf("events enable = %0d at %0t", ev_enable, $realtime),UVM_DEBUG)
                end
                if($test$plusargs("enable_ev_timeout") || $test$plusargs("enable_ev_hdshak_timeout") ) begin
                    //enable timeout error register
                    write_data = tmp[0]; // randomly turn on error detection or dont
                    err_det_en = write_data;
                    write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUUEDR.TimeoutErrDetEn, write_data);
                    //enable interrupts
                    write_data =tmp[0]; // randomly enable interrupt or dont
                    intr_en = write_data;
                    write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUUEIR.TimeOutErrIntEn, write_data);
                    timeout_uc_err = 1;
                    uvm_config_db#(int)::set(null,"*","timeout_uc_err",timeout_uc_err);
 
                    write_data = 1;//tmp[0] ? 3 : $urandom_range(2,1); //Timeout Threshold - increments in the multiples of 4K so only randomizing few values to save time
                    if($test$plusargs("enable_ev_timeout")) begin
                      write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUEHTOCR.TimeOutThreshold, write_data);
                    end else begin
                    write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUSEPTOCR.TimeOutThreshold, write_data);
                    end

                end else begin
                    //program timeout threshold - need to program this always hence outside the above if condition
                    write_data = 10; //Timeout Threshold - increments in the multiples of 4K so only randomizing few values to save time
                    write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUSEPTOCR.TimeOutThreshold, write_data);

                end
                ev.trigger();
                if($test$plusargs("enable_ev_timeout") && (intr_en == 1) && (err_det_en == 1)) begin
                    fork
                        begin
                            wait (u_csr_probe_vif.IRQ_UC === 1);
                            uvm_config_db#(int)::set(null,"*","chi_irq_uc",u_csr_probe_vif.IRQ_UC); //for coverage
                        end
                        begin
                          #200000ns;
                          `uvm_error(get_name(),$sformatf("Timeout! Did not see IRQ_UC asserted"));
                        end
                    join_any
                end
                if($test$plusargs("enable_ev_timeout") && $urandom_range(1,0) && err_det_en) begin  //randomly enable or disable error clearing
                    do begin
                        read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUUESR.ErrVld, read_data);
                    end while (read_data == 0);

                    read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUUESR.ErrType, read_data);
                    uvm_config_db#(int)::set(null,"*","chi_errtype_code",read_data); //for coverage
                    read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUUESR.ErrInfo, read_data);
                    uvm_config_db#(int)::set(null,"*","chi_sysevt_err_type",read_data); //for coverage
                    #($urandom_range(50,1) * 1us); //wait for random amount of time before clearing error
                    write_data = 1;
                    write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUUESR.ErrVld, write_data);
                end
            end
        join
    endtask
endclass : chiaiu_csr_sysreq_event_seq

class chi_aiu_qossr_status extends chi_aiu_ral_csr_base_seq;
  `uvm_object_utils(chi_aiu_qossr_status)

    uvm_reg_data_t poll_data, read_data, write_data;
    uvm_reg_data_t field_rd_data_evtcount,field_rd_data_prev_evtcount,field_rd_data;
    uvm_reg_data_t eventThreshold;

    int starvation_wait_count,delay,k_timeout;
    int starvation_count =0;
    uvm_cmdline_processor clp = uvm_cmdline_processor::get_inst();
    string arg_value;
    uvm_status_e           status;

  function new(string name="");
      super.new(name);
      if (clp.get_arg_value("+k_timeout=", arg_value)) begin
           k_timeout = arg_value.atoi();
           k_timeout = (k_timeout /100);
      end
  endfunction

  task body();
    getCsrProbeIf();
    getDutProbeIf();
    ev.trigger();

    read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUQOSSR.EventStatus, read_data);
    compareValues("CAIUQOSSR_EventStatus", "should be 0", read_data, 0);
    if ($test$plusargs("force_overflow_count")) begin
        read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUQOSSR.EventStatusCount, read_data);
        compareValues("CAIUQOSSR_EventStatusCount", "should be 'hFFFF", read_data, 'hFFFF);
    end else begin
        read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUQOSSR.EventStatusCount, read_data);
        compareValues("CAIUQOSSR_EventStatusCount", "should be 0", read_data, 0);
    end
    read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUQOSSR.EventStatusCountOverflow, read_data);
    compareValues("CAIUQOSSR_EventStatusCountOverflow", "should be 0", read_data, 0);

    fork
     begin
       do begin
         field_rd_data = 0;
            read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUQOSSR.EventStatus, field_rd_data);

         if(field_rd_data==1)`uvm_info(get_full_name(),$sformatf("Entered in starvation mode Reg EvntStatus %0d ",field_rd_data), UVM_NONE)
            read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUQOSSR.EventStatusCount, field_rd_data_evtcount);

    if (!$test$plusargs("force_overflow_count")) begin
         if(field_rd_data_evtcount !=starvation_count && field_rd_data_evtcount != field_rd_data_prev_evtcount) begin
             `uvm_error("STARV_EN_CHK", $sformatf("Starvation Event count mismatch  expected eventstatuscount=0x%0d from QoS eventstatuscount reg =0x%0d",starvation_count,field_rd_data_evtcount));
         end
         end

         field_rd_data_prev_evtcount= field_rd_data_evtcount;
         k_timeout--;
       end while (starvation_count <10 && k_timeout !=0);

        if(starvation_count == 0 &&  k_timeout == 0)begin
            `uvm_error(get_name(),$sformatf("Timeout! Did not enter starvation mode"));
        end
     end

      begin
         forever begin
         @(posedge u_csr_probe_vif.clk)
         @(posedge u_csr_probe_vif.QOSSR_EventStatus)
         #1ns; starvation_count ++;
              `uvm_info(get_full_name(),$sformatf("Entered in starvation mode probe if EvntStatus %0d count %0d ",u_csr_probe_vif.QOSSR_EventStatus,starvation_count), UVM_NONE)
         end
      end
       
    join_any
    disable fork;

    do begin
        wait((u_dut_probe_vif.ott_entry_validvec === 0) && (u_dut_probe_vif.stt_entry_validvec === 0));
        #10000ns;
    end while ((u_dut_probe_vif.ott_entry_validvec != 0) || (u_dut_probe_vif.stt_entry_validvec != 0));

    if ($test$plusargs("force_overflow_count")) begin
        read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUQOSSR.EventStatusCountOverflow, read_data);
        compareValues("CAIUQOSSR_EventStatusCountOverflow", "should be 1", read_data, 1);
    end else begin
        read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUQOSSR.EventStatusCountOverflow, read_data);
        compareValues("CAIUQOSSR_EventStatusCountOverflow", "should be 0", read_data, 0);
    end

    write_data = 'hFFFF;
    write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUQOSSR.EventStatusCount, write_data); //Doing RMW so the EventStatusCountOverflow is also cleared.
    read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUQOSSR.EventStatusCount, read_data);
    compareValues("CAIUQOSSR_EventStatusCount", "Cleared", read_data, 0);
    read_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.CAIUQOSSR.EventStatusCountOverflow, read_data);
    compareValues("CAIUQOSSR_EventStatusCountflow", "Cleared", read_data, 0);

  endtask
endclass : chi_aiu_qossr_status
