///////////////////////////////////////////////////////////////////////////////
//                                                                           //
// File         :   dii_ral_csr_seq.sv                                       //
// Author       :   Eric Weisman 2018                                        //
// Description  :   exercise CSR via APB                                     //
//                                                                           //
// Revision     :                                                            //
//                                                                           //
///////////////////////////////////////////////////////////////////////////////


//en/disable correctable, uncorrectable errors

<% var has_ucerr = 0; 
 if(obj.DiiInfo[obj.Id].fnErrDetectCorrect.substring(0,6) === "SECDED" || obj.DiiInfo[obj.Id].fnErrDetectCorrect.substring(0,6) === "PARITY") { 
    has_ucerr = 1;
 }
%>

<% var has_cerr = 0;
 if ((obj.DiiInfo[obj.Id].useExternalMemory == 1 && obj.DiiInfo[obj.Id].fnErrDetectCorrect.substring(0,6) == "SECDED")) {
    has_cerr = 1;
 }
%>


//-----------------------------------------------------------------------
//   base method for dii 
//-----------------------------------------------------------------------
class dii_ral_csr_base_seq extends ral_csr_base_seq;

    virtual <%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>_dii_csr_probe_if u_csr_probe_vif;
    uvm_event_pool ev_pool = uvm_event_pool::get_global_pool();
    uvm_event ev_bresp = ev_pool.get("ev_<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>_bresp");
    uvm_event ev_rresp = ev_pool.get("ev_<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>_rresp");
    uvm_event ev_irq_uc = ev_pool.get("ev_<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>_irq_uc");
    uvm_event ev_irq_uc_en = ev_pool.get("ev_<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>_irq_uc_en");
    uvm_event ev_targ_id_err = ev_pool.get("ev_<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>_targ_id_err");
    uvm_event ev_sys_event_err     = ev_pool.get("ev_<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>_sys_event_err");
    uvm_event ev_sys_event_req     = ev_pool.get("ev_<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>_sys_event_req");
   
    virtual <%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>_apb_if  apb_vif;
    dii_scoreboard dii_sb;
    bit has_ucerr_enabled = $test$plusargs("has_ucerr");
    bit smi_dtw_err_en_enabled = $test$plusargs("smi_dtw_err_en");
   
    function new(string name="");
        super.new(name);
    endfunction

    function getCsrProbeIf();
        if(!uvm_config_db#(virtual <%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>_dii_csr_probe_if )::get(null, get_full_name(), "u_csr_probe_if",u_csr_probe_vif))
            `uvm_error("NOVIF",{"virtual interface must be set  for :",get_full_name(),".vif"})
    endfunction // checkCsrProbeIf

      function void get_scb_handle();
      if (!uvm_config_db#(dii_scoreboard)::get(.cntxt( null ),
                                              .inst_name( "*" ),
                                              .field_name( "dii_scb" ),
                                              .value( dii_sb ))) begin
         `uvm_error("dii_ral_csr_base_seq", "dii_scb handle not found")
      end
    endfunction
    
    
    
    function bit [`UVM_REG_ADDR_WIDTH-1 : 0] get_unmapped_csr_addr();
      bit [`UVM_REG_ADDR_WIDTH-1 : 0] all_csr_addr[$];
      typedef struct packed {
                             bit [`UVM_REG_ADDR_WIDTH-1 : 0] lower_addr;
                             bit [`UVM_REG_ADDR_WIDTH-1 : 0] upper_addr;
                            } csr_addr;
      csr_addr csr_unmapped_addr_range[$];
      int randomly_selected_unmapped_csr_sddr;
      
      <% obj.DiiInfo[obj.Id].csr.spaceBlock[0].registers.forEach(function GetAllregAddr(item,i){ %>
                                  //all_csr_addr.push_back({12'h<%=obj.DiiInfo[obj.Id].nrri%>,8'h<%=obj.DiiInfo[obj.Id].rpn%>,12'h<%=item.addressOffset%>});
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
      if (!uvm_config_db#(virtual <%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>_apb_if)::get(.cntxt(null),
                                          .inst_name(this.get_full_name()),
                                          .field_name("m_apb_if"),
                                          .value(apb_vif)))
        `uvm_error(get_name,"Failed to get apb if")
    endfunction

endclass : dii_ral_csr_base_seq



//-----------------------------------------------------------------------
//-----------------------------------------------------------------------
/**
 * Abstract:
 * 
 * In this test we will check unit ids values against json
 * Test will get arguments of this sequence name from command line and 
 * call the body of this sequence.
 */
//-----------------------------------------------------------------------
//-----------------------------------------------------------------------
//
class dii_csr_id_reset_seq extends dii_ral_csr_base_seq; 
   `uvm_object_utils(dii_csr_id_reset_seq)

    uvm_reg_data_t read_data;

    function new(string name="");
        super.new(name);
    endfunction

    task body();

        uvm_status_e status; 
        uvm_reg my_register;
        uvm_reg_field my_field;
        uvm_reg_data_t write_data = 32'hFFFF_FFFF;
        uvm_reg_data_t read_data;
        uvm_reg_data_t mirrored_value;

        if(this.model == null) begin
            `uvm_error(get_type_name(), "this.model is null. Cannot perform write operation.");
            return;
        end

      
        my_register = this.model.get_reg_by_name("DIIUUELR0");
        if(my_register == null) begin
            `uvm_error(get_type_name(), "Register DIIUUELR0 not found in this.model");
            return;
        end

       my_register.write(status, write_data);
       `uvm_info(get_type_name(), $sformatf("Wrote %0h to register DIIUUELR0 in sequence", write_data), UVM_LOW)

       if(status != UVM_IS_OK) begin
       `uvm_error(get_type_name(), $sformatf("Error writing to reg DIIUUELR0: %s", status.name()));
        return;
      end

        my_register.read(status,read_data);
       `uvm_info(get_type_name(), $sformatf("And DIIUUELR0 in seq after reading is %0h",read_data),UVM_LOW)

      if(status != UVM_IS_OK) begin
       `uvm_error(get_type_name(), $sformatf("Error reading from reg DIIUUELR0: %s", status.name()));
        return;
      end
          read_data = 'hDEADBEEF ;  //bogus sentinel


          read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUIDR.RPN, read_data);
          compareValues("DIIUFUIDR_RPN", "should be <%=obj.DiiInfo[obj.Id].rpn%>", read_data, <%=obj.DiiInfo[obj.Id].rpn%>);  //TODO FIXME meaningful values from json
          read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUIDR.NRRI, read_data);
          compareValues("DIIUIDR_NRRI", "should be <%=obj.DiiInfo[obj.Id].nrri%>", read_data, <%=obj.DiiInfo[obj.Id].nrri%>);  //TODO FIXME meaningful values from json
          read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUIDR.NUnitId, read_data);
          compareValues("DIIUIDR_NUnitId", "should be <%=obj.DiiInfo[obj.Id].nUnitId%>", read_data, <%=obj.DiiInfo[obj.Id].nUnitId%>);  //TODO FIXME meaningful values from json
          read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUIDR.Valid, read_data);
          compareValues("DIIUIDR_Valid", "should be 1", read_data, 1);  

          read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUFUIDR.FUnitId, read_data);
          compareValues("DIIUIDR_FUnitId", "should be <%=obj.DiiInfo[obj.Id].FUnitId%> (json)", read_data, <%=obj.DiiInfo[obj.Id].FUnitId%>);

    endtask

endclass : dii_csr_id_reset_seq

class access_unmapped_csr_addr extends dii_ral_csr_base_seq;
  `uvm_object_utils(access_unmapped_csr_addr)
  bit [`UVM_REG_ADDR_WIDTH-1 : 0] unmapped_csr_addr;
  apb_pkt_t apb_pkt;

  function new(string name="");
      super.new(name);
  endfunction

  task body();
    get_apb_if();
    unmapped_csr_addr = get_unmapped_csr_addr();
    apb_pkt = apb_pkt_t::type_id::create("apb_pkt");
    apb_pkt.paddr = unmapped_csr_addr;
    apb_pkt.pwrite = 1;
    apb_pkt.psel = 1;
    apb_pkt.pwdata = $urandom;
    apb_vif.drive_apb_channel(apb_pkt);
  endtask
endclass : access_unmapped_csr_addr

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

class dii_csr_diicesar_seq extends dii_ral_csr_base_seq; 
  `uvm_object_utils(dii_csr_diicesar_seq)

    uvm_reg_data_t poll_data, read_data, read_data2, write_data;
    bit [7:0]  errthd;
    int        errcount_vld, errthd_vld;
    int        errcount_ovf;

    function new(string name="");
        super.new(name);
    endfunction

    task body();
     getCsrProbeIf();

<%    if (has_cerr || (obj.DiiInfo[obj.Id].ResilienceInfo.fnResiliencyProtectionType === "ecc")) { %>
            write_data = 1;
           write_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUCECR.ErrIntEn, write_data);
           write_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUCESAR.ErrVld, write_data);
           read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUCESR.ErrVld, read_data);
           compareValues("DIIUCESR_ErrVld", "set", read_data, 1);

           write_data = 0;
           write_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUCESR.ErrVld, write_data);
           read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUCESR.ErrVld, read_data);
           compareValues("DIIUCESR_ErrVld", "set", read_data, 1);

           // write  DIIUCESR_ErrVld = 1 , W1C
           write_data = 1;
           write_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUCESR.ErrVld, write_data);
           // Read the DIIUCESR_ErrVld should be cleared
           read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUCESR.ErrVld, read_data);
           compareValues("DIIUCESR_ErrVld", "now clear", read_data, 0);

           // Write Alias CSR field ErrType to reflect into SR ErrType filed
           // write info with ErrVld == 0: expect to take new info
           write_data = 4'b1111;
           write_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUCESAR.ErrType, write_data);
           read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUCESR.ErrType, read_data);
           compareValues("DIIUCESR_ErrType", "set", read_data, write_data);

           // Write Alias CSR field ErrInfo to reflect into SR ErrInfo filed
           write_data = 16'hffff;
           write_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUCESAR.ErrInfo, write_data);
           read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUCESR.ErrInfo, read_data);
           compareValues("DIIUCESR_ErrInfo", "set", read_data, write_data);

            fork
           begin
             wait (u_csr_probe_vif.IRQ_C === 1);
           end
           begin
             #200;
             `uvm_error("RUN_MAIN",$sformatf("Timeout! Did not see IRQ_C asserted"));
           end
           join_any
           disable fork;


           // write info with ErrVld == 1: expect to hold old data
           write_data = 1;
           write_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUCESAR.ErrVld, write_data);
           read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUCESR.ErrVld, read_data);

           write_data = 4'b0000;
           write_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUCESAR.ErrType, write_data);
           read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUCESR.ErrType, read_data);
           // expect data to be 4'b0000
           compareValues("DIIUCESR_ErrType", "set", read_data, 4'b0000);
           // Write Alias CSR field ErrInfo to reflect into SR ErrInfo filed
           write_data = 16'h0000;
           write_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUCESAR.ErrInfo, write_data);
           read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUCESR.ErrInfo, read_data);
           // expect data to be 16'h0000
           compareValues("DIIUCESR_ErrInfo", "set", read_data, 16'h0000);
<% } %>
    endtask
endclass : dii_csr_diicesar_seq

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

class dii_csr_diiuesar_seq extends dii_ral_csr_base_seq; 
  `uvm_object_utils(dii_csr_diiuesar_seq)

    uvm_reg_data_t poll_data, read_data, read_data2, write_data;
    bit [7:0]  errthd;
    int        errcount_vld, errthd_vld;
    int        errcount_ovf;

    function new(string name="");
        super.new(name);
    endfunction

    task body();

<%    if (has_ucerr || (obj.DiiInfo[obj.Id].ResilienceInfo.fnResiliencyProtectionType === "ecc") ||
          (obj.DiiInfo[obj.Id].ResilienceInfo.fnResiliencyProtectionType === "parity")) { %>

       write_data = 1;
       write_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUESAR.ErrVld, write_data);
       read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUESR.ErrVld, read_data);
       compareValues("DIIUUESR_ErrVld", "set", read_data, 1);

       write_data = 0;
       write_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUESAR.ErrVld, write_data);
       read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUESR.ErrVld, read_data);
       compareValues("DIIUUESR_ErrVld", "set", read_data, 0);

       write_data = 1;
       write_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUESAR.ErrVld, write_data);
       read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUESR.ErrVld, read_data);
       compareValues("DIIUUESR_ErrVld", "set", read_data, 1);

       // write  DIIUUESR_ErrVld = 1 , W1C
       write_data = 1;
       write_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUESR.ErrVld, write_data);
       // Read the DIIUUESR_ErrVld should be cleared
       read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUESR.ErrVld, read_data);
       compareValues("DIIUUESR_ErrVld", "now clear", read_data, 0);
  
//       if ($test$plusargs("has_ucerr")) begin
           // write info with ErrVld == 0: expect to take new info
           // Write Alias CSR field ErrType to reflect into SR ErrType filed
           write_data = 5'b11111;
           write_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUESAR.ErrType, write_data);
           read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUESR.ErrType, read_data);
           compareValues("DIIUUESR_ErrType", "set", read_data, write_data);
           // Write Alias CSR field ErrInfo to reflect into SR ErrInfo filed
           write_data = 20'hfffff;
           write_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUESAR.ErrInfo, write_data);
           read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUESR.ErrInfo, read_data);
           compareValues("DIIUUESR_ErrInfo", "set", read_data, write_data);

           // write info with ErrVld == 1: expect to hold old data
           read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUESAR.ErrVld, read_data);
           compareValues("DIIUUESR_ErrVld", "set", read_data, 1);
           write_data = 5'b00000;
           write_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUESAR.ErrType, write_data);
           read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUESR.ErrType, read_data);
           // expect data to be 5'b00000
           compareValues("DIIUUESR_ErrType", "set", read_data, 5'b00000);
           // Write Alias CSR field ErrInfo to reflect into SR ErrInfo filed
           write_data = 20'h00000;
           write_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUESAR.ErrInfo, write_data);
           read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUESR.ErrInfo, read_data);
           // expect data to be 16'h0000
           compareValues("DIIUUESR_ErrInfo", "set", read_data, 20'h00000);

//    end
<% } %>
    endtask
endclass : dii_csr_diiuesar_seq

//-----------------------------------------------------------------------
//-----------------------------------------------------------------------
/**
* Abstract:
* 
* In this test we will check if ErrDetEn is set, correctable errors are logged by design. 
* Test will get arguments of this sequence name from command line and 
* call the body of this sequence.
* 1. If dii contains SECDED, enable Error detection from correctable CSR
* 2. Enable SRAM single-bit error from command line with 100% (all writes/read in SRAM)
* 3. Poll Error valid bit from Correctable status register until it is 1. (Error captured)
* 4. Disable error detection in CSR.
* 5. Read ErrVld, which should be set until its cleared.
* 6. Clear ErrVld by writting 1 (W1C access types of this field) in status register
* 7. Compare read value with 0 for ErrVld field in status register (should be cleared)
*/
//-----------------------------------------------------------------------
//-----------------------------------------------------------------------
//

class dii_csr_diicecr_errDetEn_seq extends dii_ral_csr_base_seq; 
  `uvm_object_utils(dii_csr_diicecr_errDetEn_seq)

    uvm_reg_data_t poll_data, read_data, read_data2, write_data;
    bit [7:0]  errthd;
    int        errcount_vld, errthd_vld;
    int        errcount_ovf;

    function new(string name="");
        super.new(name);
    endfunction

    task body();

<%    if (has_cerr || (obj.DiiInfo[obj.Id].ResilienceInfo.fnResiliencyProtectionType === "ecc")) { %>
       write_data = 1;
       write_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUCESAR.ErrVld,write_data);
       read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUCESR.ErrVld,read_data);
       compareValues("DIIUCESR_ErrVld", "set", read_data, 1);

       // Write 1'b1 to SR should have no effects
       write_data = 0;
       read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUCESR.ErrVld,read_data);
       compareValues("DIIUCESR_ErrVld", "set", read_data, 1);

       // W1C to SR
       write_data = 1;
       write_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUCESR.ErrVld,write_data);
       read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUCESR.ErrVld,read_data);
       compareValues("DIIUCESR_ErrVld", "set", read_data, 0);
<% } %>
<% if(has_cerr) { %>
           // Set the DIIUCECR_ErrDetEn = 1
           write_data = 1;
           write_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUCECR.ErrDetEn, write_data);
           //keep on  Reading the DIIUCESR_ErrVld bit = 1
           poll_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUCESR.ErrVld,1,poll_data);
           // Set the DIIUCECR_ErrDetEn = 0, to diable the error detection
           write_data = 0;
           write_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUCECR.ErrDetEn, write_data);
           // Read DIIUCESR_ErrVld , it should be 1
           read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUCESR.ErrVld, read_data);
           compareValues("DIIUCESR_ErrVld", "set", read_data, 1);
           // write  DIIUCESR_ErrVld = 1 , W1C
           write_data = 1;
           write_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUCESR.ErrVld, write_data);
           // Read the DIIUCESR_ErrVld should be cleared
           read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUCESR.ErrVld, read_data);
           compareValues("DIIUCESR_ErrVld", "now clear", read_data, 0);
<% } else if((obj.useExternalMemoryFifo) && (obj.fnErrDetectCorrect == "SECDED")) { %>
           // Read the DIIUCESR_ErrVld should be clear
           read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUCESR.ErrVld, read_data);
           compareValues("DIIUESR_ErrVld", "RAZ/WI", read_data, 0);
           // Read DIIUCESAR_ErrVld , it should also clear, beacuse it is alias register
           // of register DIIUCESR_*
           read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUCESAR.ErrVld, read_data);
           compareValues("DIIUESAR_ErrVld", "RAZ/WI", read_data, 0);
<% } %>
    endtask
endclass : dii_csr_diicecr_errDetEn_seq

//-----------------------------------------------------------------------
//-----------------------------------------------------------------------
/**
* Abstract:
* 
* In this test we will check if correctable errors are logged and interupt signal is asserted from DUT.
* Test will get arguments of this sequence name from command line and 
* call the body of this sequence.
* 1. If dii contains SECDED, Write Error threshold with 1 (DUT must assert Interrupt once threshold value errors are corrected.
* 2. Eable Error detection from correctable CSR.
* 3. Enable Error Interrupt from CSR. If enabled then correctable iterrupt signal is asserted.
* 4. Enable SRAM single-bit error from command line with 100% (all writes/read in SRAM)
* 5. Poll interrupt signal from interface if not asserted issue Timeout error.
* 6. Read ErrVld field should be 1 (Error information logged) and Check ErrType 0x1 (Read Buffer in this case)
* 7. Disable Error Detection and Error Interrupt filed by writing 0.
* 8. Clear ErrVld by writting 1 (W1C access types of this field) in status register
* 9. Compare read value with 0 for ErrVld field in status register (should be cleared)
* 10. Poll for interrupt signal after disabling error detection and interrupt, should not assert this signal.
*/
//-----------------------------------------------------------------------
//-----------------------------------------------------------------------
//
class dii_csr_diicecr_errInt_seq extends dii_ral_csr_base_seq; 
  `uvm_object_utils(dii_csr_diicecr_errInt_seq)

    uvm_reg_data_t poll_data, read_data, read_data2, write_data;
    bit [7:0]  errthd;
    int        errcount_vld, errthd_vld;
    int        errcount_ovf;
    bit [3:0]  errtype;

    function new(string name="");
        super.new(name);
    endfunction

    task body();

       getCsrProbeIf();
<% if(has_cerr) { %>
           // Set the DIIUCECR_ErrThreshold 
        errthd = 1;

           write_data = errthd;
           write_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUCECR.ErrThreshold, write_data);
           // Set the DIIUCECR_ErrDetEn = 1
           write_data = 1;
           write_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUCECR.ErrDetEn, write_data);
           // Set the DIIUCECR_ErrIntEn = 1
           write_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUCECR.ErrIntEn, write_data);
           // wait for IRQ_C interrupt 
           fork
           begin
             if (u_csr_probe_vif.IRQ_C == 0) begin
               @(u_csr_probe_vif.IRQ_C);
             end
           end
           begin
             #200000ns;
             `uvm_error("RUN_MAIN",$sformatf("Timeout! Did not see IRQ_C asserted"));
           end
           join_any
           disable fork;
           // Read the DIIUCESR_ErrVld
           read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUCESR.ErrVld, read_data);
           compareValues("DIIUCESR_ErrVld", "set after inte", read_data, 1);
           read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUCESR.ErrType, read_data);
           compareValues("DIIUCESR_ErrType","Valid Type", read_data, errtype);
           read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUCESR.ErrCount, read_data);
           // Set the DIIUCECR_ErrDetEn = 0, to disable the error detection
           write_data = 0;
           write_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUCECR.ErrDetEn, write_data);
           // Set the DIIUCECR_ErrIntEn = 0, to disable the error Interrupt
           write_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUCECR.ErrIntEn, write_data);
           // write DIIUCESR_ErrVld = 1 to clear it
           write_data = 1;
           write_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUCESR.ErrVld, write_data);
           // Read DIIUCESR_ErrVld , it should be 0
           read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUCESR.ErrVld, read_data);
           compareValues("DIIUCESR_ErrVld", "reset", read_data, 0);
           // Monitor IRQ_C pin , it should be 0 now
           if(u_csr_probe_vif.IRQ_C == 0)begin
             `uvm_info("RUN_MAIN",$sformatf("IRQ_C interrupted de-asseretd"), UVM_LOW)
           end else begin
             `uvm_error("RUN_MAIN",$sformatf("IRQ_C interruped still aseerted"));
           end
<% } else if((obj.useExternalMemoryFifo) && (obj.fnErrDetectCorrect == "SECDED")){ %>
          // Read DIIUCESR_ErrVld , it should be 0
           read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUCESR.ErrVld, read_data);
           compareValues("DIIUCESR_ErrVld", "set", read_data, 0);
          // Read DIIUCESAR_ErrVld , it should be 0
           read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUCESAR.ErrVld, read_data);
           compareValues("DIIUCESAR_ErrVld", "set", read_data, 0);
          // Monitor IRQ_C pin , it should be 0 now
          if(u_csr_probe_vif.IRQ_C == 0)begin
             `uvm_info("RUN_MAIN",$sformatf("IRQ_C interrupted de-asseretd"), UVM_LOW)
          end else begin
             `uvm_error("RUN_MAIN",$sformatf("IRQ_C interruped still asserted"));
          end
<% } %>
    endtask
endclass : dii_csr_diicecr_errInt_seq

//-----------------------------------------------------------------------
//-----------------------------------------------------------------------
/**
* Abstract:
* 
* In this test we will check if correctable errors are corrected (ErrThreshold filed CECR register) which should be count by Error counter. 
* Test will get arguments of this sequence name from command line and 
* call the body of this sequence.
* 1. If dii contains SECDED, Write Error threshold with random value b/w 1 to 20 (DUT must assert Interrupt once threshold value errors are corrected.
* 2. Eable Error detection from correctable CSR.
* 3. Enable Error Interrupt from CSR. If enabled then correctable iterrupt signal is asserted.
* 4. Enable SRAM single-bit error from command line with 100% (all writes/read in SRAM)
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

class dii_csr_diicecr_errThd_seq extends dii_ral_csr_base_seq; 
  `uvm_object_utils(dii_csr_diicecr_errThd_seq)

    uvm_reg_data_t poll_data, read_data, read_data2, write_data;
    bit [7:0]  errthd;
    int        errcount_vld, errthd_vld;
    int        errcount_ovf;

    function new(string name="");
        super.new(name);
    endfunction

    task body();
      
<%    if (has_cerr || (obj.DiiInfo[obj.Id].ResilienceInfo.fnResiliencyProtectionType === "ecc")) { %>
          // Set the DIIUCECR_ErrThreshold 
          errthd = $urandom_range(1,20);
          write_data = errthd;
          write_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUCECR.ErrThreshold, write_data);
          // Set the DIIUCECR_ErrDetEn = 1
          write_data = 1;
          write_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUCECR.ErrDetEn, write_data);
          // Set the DIIUCECR_ErrIntEn = 1
          write_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUCECR.ErrIntEn, write_data);
          // write  DIIUCESR_ErrVld = 1 , to reset it
          write_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUCESR.ErrVld, write_data);
          read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUCESR.ErrVld, read_data);
<% } %>
<%  if(has_cerr) { %>
          //keep on  Reading the DIIUCESR_ErrVld bit = 1 
          poll_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUCESR.ErrVld,1,poll_data);
          // Read DIIUCESR_ErrCount , it should be at errthd
          poll_data = 0;
          poll_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUCESR.ErrCount,1,poll_data);
          if(poll_data < errthd) begin
              `uvm_error("RUN_MAIN",$sformatf("ErrCount %0d should be same as ErrThreshold %0d",poll_data,errthd))
          end
          // Set the DIIUCECR_ErrDetEn = 0
          write_data = 0;
          write_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUCECR.ErrDetEn, write_data);
          // write : DIIUCESR_ErrVld = 1 , to reset it
          write_data = 1;
          write_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUCESR.ErrVld, write_data);
          // Read DIIUCESR_ErrVld , it should be 0
          read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUCESR.ErrVld, read_data);
          compareValues("DIIUCESR_ErrVld", "now clear", read_data, 0);
          read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUCESR.ErrCount, read_data);
          compareValues("DIIUCESR_ErrCount", "now clear", read_data, 0);
          ///////////////////////////////////
          // Repeat entire process
          ///////////////////////////////////
          // Set the DIIUCECR_ErrThreshold 
          errthd = $urandom_range(1,20);
          poll_data = 0;
          write_data = errthd;
          write_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUCECR.ErrThreshold, write_data);
          // Set the DIIUCECR_ErrDetEn = 1
          write_data = 1;
          write_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUCECR.ErrDetEn, write_data);
          // Set the DIIUCECR_ErrIntEn = 1
          write_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUCECR.ErrIntEn, write_data);
          // write  DIIUCESR_ErrVld = 1 , to reset it
          write_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUCESR.ErrVld, write_data);
          //keep on  Reading the DIIUCESR_ErrVld bit = 1 
          poll_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUCESR.ErrVld,1,poll_data);
          // Read DIIUCESR_ErrCount , it should be at errthd
          poll_data = 0;
          poll_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUCESR.ErrCount,1,poll_data);
          if(poll_data < errthd) begin
              `uvm_error("RUN_MAIN",$sformatf("ErrCount %0d should be same as ErrThreshold %0d",poll_data,errthd))
          end
          // Set the DIIUCECR_ErrDetEn = 0
          write_data = 0;
          write_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUCECR.ErrDetEn, write_data);
          // write : DIIUCESR_ErrVld = 1 , to reset it
          write_data = 1;
          write_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUCESR.ErrVld, write_data);
          // Read DIIUCESR_ErrVld , it should be 0
          read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUCESR.ErrVld, read_data);
          compareValues("DIIUCESR_ErrVld", "now clear", read_data, 0);
          read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUCESR.ErrCount, read_data);
          compareValues("DIIUCESR_ErrCount", "now clear", read_data, 0);     
<% } %>
    endtask
endclass : dii_csr_diicecr_errThd_seq


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
//#Test.DMI.ErrInjWhileSoftwareWriteHappens
class dii_csr_diicecr_sw_write_seq extends dii_ral_csr_base_seq; 
  `uvm_object_utils(dii_csr_diicecr_sw_write_seq)

   uvm_reg_data_t poll_data, read_data, read_data2, write_data;
   bit [7:0]  errthd;
   int        errcount_vld, errthd_vld;
   int        i;

    function new(string name="");
        super.new(name);
    endfunction

   task body();

       getCsrProbeIf();

<%    if (has_cerr || (obj.DiiInfo[obj.Id].ResilienceInfo.fnResiliencyProtectionType === "ecc")) { %>
      // Set the DIIUCECR_ErrThreshold 
      errthd = 1;
      write_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUCECR.ErrThreshold, write_data);
      // Set the DIIUCECR_ErrDetEn = 1
      write_data = 1;
      write_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUCECR.ErrDetEn, write_data);
      // write DIIUCESR_ErrVal = 0, should have no effect.
      write_data = 0;
      write_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUCESR.ErrVld, write_data);
      // write  DIIUCESR_ErrVld = 1 , to reset it
      write_data = 1;
      write_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUCESR.ErrVld, write_data);
      read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUCESR.ErrVld, read_data);
<% } %>      
      <% if(has_cerr) { %>
          poll_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUCESR.ErrVld,1,poll_data);
          write_data = 0;
          fork
              begin
                 for (i=0;i<100;i++) begin
                    write_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUCESAR.ErrVld, write_data);
                 end
              end
              begin
                if (u_csr_probe_vif.DIIUCESR_ErrVld == 0) begin
                  @(u_csr_probe_vif.DIIUCESR_ErrVld);
                end
              end
              //begin
                  //read_data = 0;
                  //while(read_data == 0) begin
                  //  uvm_hdl_read(tb_top.dut.u_dii_unit.dii_csr.dii_csr_gen.DIIUCESR_ErrVld_out,read_data);
                  //end
              //end
          join;
          //wait fork;
<% } %>
         
<%    if (has_cerr || (obj.DiiInfo[obj.Id].ResilienceInfo.fnResiliencyProtectionType === "ecc")) { %>
          // Set the DIIUCECR_ErrDetEn = 0
          write_data = 0;
          write_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUCECR.ErrDetEn, write_data);
          // if vld is set, reset it
          read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUCESR.ErrVld, read_data);
          if(read_data) begin
             write_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUCESR.ErrVld, 1);
          end
<% } %>
    endtask
endclass : dii_csr_diicecr_sw_write_seq


//-----------------------------------------------------------------------
//-----------------------------------------------------------------------
/**
* Abstract:
* 
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

//#Test.DMI.DetectEnNotSetErrorsInjected
class dii_csr_diicecr_noDetEn_seq extends dii_ral_csr_base_seq; 
  `uvm_object_utils(dii_csr_diicecr_noDetEn_seq)

    uvm_reg_data_t poll_data, read_data, read_data2, write_data;
    bit [7:0]  errthd;
    int        errcount_vld, errthd_vld;
    int        errcount_ovf;

    function new(string name="");
        super.new(name);
    endfunction

    task body();

       //getCsrProbeIf();
<% if(has_cerr) { %>
          // Don't Set the DIIUCECR_ErrDetEn = 1
          //Reading the DIIUCESR_ErrVld bit = 0
          read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUCESR.ErrVld, read_data);
          compareValues("DIIUCESR_ErrVld", "not set", read_data, 0);
          // Read DIIUCESR_ErrCount , it should be at 0
          read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUCESR.ErrCount, read_data);
          compareValues("DIIUCESR_ErrCount","not set", read_data, 0);
<% } else  if((obj.useExternalMemoryFifo) && (obj.fnErrDetectCorrect == "SECDED")){ %>
        // Read the DIIUCESR_ErrVld should be cleared
          read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUCESR.ErrVld, read_data);
          compareValues("DIIUCESR_ErrVld", "not set", read_data, 0);
        // Read DIIUCESAR_ErrVld , it should also clear, beacuse it is alias register
        // of register DIIUCESR_*
          read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUCESAR.ErrVld, read_data);
          compareValues("DIIUCESAR_ErrVld", "not set", read_data, 0);
<% } %>
    endtask
endclass : dii_csr_diicecr_noDetEn_seq

//-----------------------------------------------------------------------
/**
* Abstract:
* 
* In this test we will check if correctable errors are injected and interrupt assertion is disabled (ErrIntEn set to 0) ErrVld and ErrCount should be 0. 
* Test will get arguments of this sequence name from command line and 
* call the body of this sequence.
* 1. Enable SRAM single-bit error from command line with 100% (all writes/read in SRAM)
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

class dii_csr_diicecr_noIntEn_seq extends dii_ral_csr_base_seq; 
  `uvm_object_utils(dii_csr_diicecr_noIntEn_seq)

    uvm_reg_data_t poll_data, read_data, read_data2, write_data;
    bit [7:0]  errthd;
    int        errcount_vld, errthd_vld;
    int        errcount_ovf;

    function new(string name="");
        super.new(name);
    endfunction

    task body();

       getCsrProbeIf();
<% if(has_cerr) { %>
          // Set the DIIUCECR_ErrThreshold 
          write_data = 1;
          write_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUCECR.ErrThreshold, write_data);
          // Set the DIIUCECR_ErrDetEn = 1
          write_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUCECR.ErrDetEn, write_data);
          // Dont Set the DIIUCECR_ErrIntEn = 1
          // wait for IRQ_C interrupt for a while. Shouldn't happen. Then join
          //#Cov.DMI.ErrIntDisEnCorrErrs
          fork
            begin
             `uvm_info("RUN_MAIN",$sformatf("Waiting for interrupt. It shouldn't happen"), UVM_NONE)
             @(u_csr_probe_vif.IRQ_C);
             `uvm_error("RUN_MAIN", $sformatf("Unexpected interrupt! IntEn is not set"));
            end
            begin
             #50000ns;
             `uvm_info("RUN_MAIN",$sformatf("Done waiting. No interrupt received"), UVM_NONE)
            end
          join_any
          disable fork;
          //Reading the DIIUCESR_ErrVld bit = 1
          poll_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUCESR.ErrVld,1,poll_data);
          read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUCESR.ErrVld, read_data);
          compareValues("DIIUCESR_ErrVld", "set", read_data, 1);
          // write DIIUCESR_ErrVld = 1 to clear it
          write_data = 1;
          write_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUCESR.ErrVld, write_data);
          read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUCESR.ErrCountOverflow, read_data);
          compareValues("DIIUCESR_ErrCountOverflow", "Should be clear", read_data, 0);
          // write DIIUCESR_ErrVld = 1 to clear it
<% } else { %>
          fork
            begin
             `uvm_info("RUN_MAIN",$sformatf("Waiting for interrupt. It shouldn't happen"), UVM_LOW)
            @(u_csr_probe_vif.IRQ_C);
             `uvm_error("RUN_MAIN", $sformatf("Unexpected interrupt! IntEn is not set"));
            end
            begin
             #100000ns;
             `uvm_info("RUN_MAIN",$sformatf("Done waiting. No interrupt received"), UVM_LOW)
            end
          join_any
          disable fork;
<% } %>
    endtask
endclass : dii_csr_diicecr_noIntEn_seq

//-----------------------------------------------------------------------
//  Note    : If the error count field is equal to the error threshold field, the
//            error valid bit is set when a new error is corrected, and once the error valid bit becomes set, the error
//            count field is frozen at its current value. If the error valid bit is set and a new error is corrected, the
//            error overflow bit is set. 
//-----------------------------------------------------------------------
//-----------------------------------------------------------------------
/**
* Abstract:
* 
* In this test we will check if valid is set (should not be cause W1C) then also counting of error should increment. 
* Test will get arguments of this sequence name from command line and 
* call the body of this sequence.
* Enable SRAM single-bit error from command line with 100% (all writes/read in SRAM)
* 1. Set ErrVld at start which would result in clearing bit as its W1C also do for Overflow bit as well.
* 2. Write threshold value in register.
* 3. Enable error logging by writing ErrDetEn bit filed.
* 4. Poll till ErrCount reach to threshold value and compare read value to errthd that we set.      
*/
//-----------------------------------------------------------------------
//-----------------------------------------------------------------------
//

class dii_csr_diicesr_rstNoVld_seq1 extends dii_ral_csr_base_seq; 
  `uvm_object_utils(dii_csr_diicesr_rstNoVld_seq1)

    uvm_reg_data_t poll_data, read_data, read_data2, write_data;
    bit [7:0]  errthd;
    int        errcount_vld, errthd_vld;
    int        errentry, errway, errword, erraddr;

    function new(string name="");
        super.new(name);
    endfunction

    task body();

<%    if (has_cerr || (obj.DiiInfo[obj.Id].ResilienceInfo.fnResiliencyProtectionType === "ecc")) { %>
          //#Test.DMI.ErrVldErrCountOverflowNotResetW1CIfClr
          // Try Set the DIIUCESR_ErrVld = 1. Need to use Alias register (DIIUCESAR) to write
          write_data = 1;
          write_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUCESAR.ErrVld, write_data);
          read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUCESR.ErrVld, read_data);
          compareValues("DIIUCESR_ErrVld","Should be 0", read_data, 1);

          // Write to DIIUCESR_ErrVld == 1; for W1C
          write_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUCESR.ErrVld, write_data);
          read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUCESR.ErrVld, read_data);
          compareValues("DIIUCESR_ErrVld","Should be 0", read_data, 0);
<% } %>
          
<% if(has_cerr) { %>
         `uvm_info("RUN_MAIN",$sformatf("Entered Test loop"), UVM_LOW)
          write_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUCESR.ErrCountOverflow, write_data);
          read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUCESR.ErrCountOverflow, read_data);
          compareValues("DIIUCESR_ErrCountOverflow","Should be 0", read_data, 0);

          //assert(randomize(errthd));
          errthd = 10;
          write_data = errthd;
          // Set the DIIUCECR_ErrThreshold 
          write_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUCECR.ErrThreshold, write_data);
          //Check ErrCount should be 0 after writing ErrThreshold
          write_data = 1;
          write_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUCECR.ErrDetEn, write_data);
          #200000ns;
          poll_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUCESR.ErrCount,errthd,poll_data);
          compareValues("DIIUCESR_ErrCount","Should be 0", poll_data, errthd);

    
<% } %>
    endtask
endclass : dii_csr_diicesr_rstNoVld_seq1

//-----------------------------------------------------------------------
/**
* Abstract:
* 
* In this test we will check if ErrCount is increament if we enable error logging and ErrVld should be high by then.
* Test will get arguments of this sequence name from command line and 
* call the body of this sequence.
* Enable SRAM single-bit error from command line with 100% (all writes/read in SRAM)
* 1. Enable error logging by writing ErrDetEn bit filed.
* 2. Poll till ErrCount reach to 1 value and compare read value of ErrVld to be set.
* 3. Check if ErrOverflow is asserted or not. 
* 4. Clear ErrVld and ErrOverflow.
*/
//-----------------------------------------------------------------------
//-----------------------------------------------------------------------
//


class dii_csr_diicesr_rstNoVld_seq2 extends dii_ral_csr_base_seq; 
  `uvm_object_utils(dii_csr_diicesr_rstNoVld_seq2)

    uvm_reg_data_t poll_data, read_data, read_data2, write_data;
    bit [7:0]  errthd;
    int        errcount, errthd_vld;
    int        errentry, errway, errword, erraddr;

    function new(string name="");
        super.new(name);
    endfunction

    task body();

          //keep on  Reading the DIIUCESR_ErrCount bit = 1
<% if(has_cerr) { %>
          write_data = 1;
          write_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUCECR.ErrDetEn, write_data);
          poll_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUCESR.ErrCount,1,poll_data);
          read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUCESR.ErrVld, read_data);
          compareValues("DIIUCESR_ErrVld", "set", read_data, 1);
          read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUCESR.ErrCountOverflow, read_data);
          compareValues("DIIUCESR.ErrCountOverflow", "not set yet", read_data, 0);

          //write_data = 0;
          //write_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUCECR.ErrDetEn, write_data);

          //readCompareCELR(0);

          //#Test.DMI.ErrVldErrCountOverflowNotResetW1CIfClr
          write_data = 1;
          write_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUCESR.ErrVld, write_data);
          read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUCESR.ErrVld, read_data);
          compareValues("DIIUCESR_ErrVld","Should be 0", read_data, 0);
          write_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUCESR.ErrCountOverflow, write_data);
          read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUCESR.ErrCountOverflow, read_data);
          compareValues("DIIUCESR_ErrCountOverflow","Should be 0", read_data, 0);
<% } %>
    endtask
endclass : dii_csr_diicesr_rstNoVld_seq2

class dii_csr_diicelr_address_seq extends dii_ral_csr_base_seq; 
  `uvm_object_utils(dii_csr_diicelr_address_seq)

    uvm_reg_data_t poll_data, read_data, read_data2, write_data;
    bit [7:0]  errthd;
    bit [47:0] actual_addr;
    bit [47:0] expt_addr;


    int        errcount_vld, errthd_vld;
    int       erraddr0 , erraddr1;
    smi_seq_item req_item;

    static uvm_event_pool ev_pool = uvm_event_pool::get_global_pool();
    static uvm_event ev = ev_pool.get("ev_<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>_ev");

    function new(string name="");
        super.new(name);
    endfunction

    task body();

<% if(has_cerr) { %>
        `uvm_info("RUN_MAIN",$sformatf("Entered Test loop"), UVM_LOW)
          //ev.wait_trigger();
          //if($cast(req_item, ev.get_trigger_data())) begin
          //    expt_addr  = req_item.smi_addr;
          //end 
          write_data = 1;
          write_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUCECR.ErrDetEn, write_data);
          poll_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUCESR.ErrVld,1,poll_data);
          read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUCESR.ErrCountOverflow, read_data);
           //compareValues("DIIUCESR.ErrCountOverflow", "not set yet", read_data, 0);
          `uvm_info("RUN_MAIN",$sformatf("ErrCountOverflow field=%0x", read_data), UVM_LOW)

          read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUCELR0.ErrAddr, read_data);
          erraddr0 = read_data;
          read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUCELR1.ErrAddr, read_data);
          erraddr1 = read_data;
          actual_addr = {erraddr1,erraddr0}; 
          compareValues("DIIUCELR", "error address matched", actual_addr, expt_addr);
<% } %>
    endtask
endclass : dii_csr_diicelr_address_seq


//-----------------------------------------------------------------------
/**
* Abstract:
* 
* In this test we will check if read response error is inserted it should capture with correct ErrType 
* Test will get arguments of this sequence name from command line and 
* call the body of this sequence.
* Inject ace read response error for all responses 
* 1. Program Error detection for protocol check
* 2. Poll until error information logged.
* 3. Compare error type with appropriate type mentioned in table.
* 4. Clear ErrVld bit with writing 1.
*/
//-----------------------------------------------------------------------
//-----------------------------------------------------------------------
//

class dii_csr_diiuedr_rdProtErrDetEn_seq extends dii_ral_csr_base_seq; 
  `uvm_object_utils(dii_csr_diiuedr_rdProtErrDetEn_seq)

    uvm_reg_data_t poll_data, read_data, read_data2, write_data;
    bit [7:0]  errthd;
    int        errcount_vld, errthd_vld;
    int        errcount_ovf;
    bit [3:0]  errtype;
    dii_txn    scb_txn;
    axi_axaddr_t exp_err_addr;
    bit [3:0]  errinfo_rresp_err;
    bit [19:0] errentry;
    bit [5:0]  errway;
    bit [5:0]  errword;
    bit [31:0] erraddr0;
    bit [19:0] erraddr1;
    bit [51:0] actual_err_addr;
    bit        rresp_err_detected;
   
    function new(string name="");
        super.new(name);
    endfunction

    task body();

<%    if (has_ucerr || (obj.DiiInfo[obj.Id].ResilienceInfo.fnResiliencyProtectionType === "ecc") ||
          (obj.DiiInfo[obj.Id].ResilienceInfo.fnResiliencyProtectionType === "parity")) { %>
    write_data = 1;
    write_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUESAR.ErrVld,write_data);
    write_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUESR.ErrVld,write_data);
<% } %>

                        
    if (has_ucerr_enabled) begin
           if (smi_dtw_err_en_enabled)
             errtype = 4'h0;
           else
             errtype = 4'h3;

           // Set the DIIUUECR_ErrDetEn = 1
           write_data = 1;
           write_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUEDR.ProtErrDetEn, write_data);
 
           fork
             begin
               // update error info only when see ErrVld 0->1 transition
               poll_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUESR.ErrVld,0,poll_data);
               ev_rresp.wait_ptrigger();
               $cast(scb_txn,ev_rresp.get_trigger_data());
//               exp_err_addr = scb_txn.axi_read_addr_pkt.araddr;
               exp_err_addr = scb_txn.smi_recd[eConcMsgCmdReq].smi_addr;
               for (int i=0; i < scb_txn.axi_read_data_pkt.rresp_per_beat.size(); i++) begin
                 `uvm_info($sformatf("%m"), $sformatf("RRESP[%0d] = %d addr=%p", i, scb_txn.axi_read_data_pkt.rresp_per_beat[i], scb_txn.axi_read_addr_pkt.araddr), UVM_HIGH)
                 if (scb_txn.axi_read_data_pkt.rresp_per_beat[i] > 1) begin
                    errinfo_rresp_err = {1'b0,scb_txn.axi_read_addr_pkt.arprot[1],scb_txn.axi_read_data_pkt.rresp_per_beat[i]};
                    break;  // captures the first error
                  end
               end
             end
             begin
               #10000ns;
               `uvm_error("RRESP","RRESP event was not triggered")
             end
           join_any
           disable fork;
          `uvm_info(get_full_name(),$sformatf("exp_err_addr = 0x%0x, errinfo_rresp_err = 0x%0x",exp_err_addr,errinfo_rresp_err),UVM_HIGH)

           //keep on  Reading the DIIUUESR_ErrVld bit = 1
           poll_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUESR.ErrVld,1,poll_data);
             
           read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUESR.ErrType, read_data);
           compareValues("DIIUUESR_ErrType","Valid Type", read_data, errtype);
           read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUESR.ErrInfo, read_data);
           compareValues("DIIUUESR_ErrInfo","Valid Type", read_data, errinfo_rresp_err);
           read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUELR0.ErrAddr, read_data);
           erraddr0 = read_data;
           read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUELR1.ErrAddr, read_data);
           erraddr1 = read_data;
           actual_err_addr = {erraddr1,erraddr0} & ((1 << <%=obj.DiiInfo[obj.Id].interfaces.axiInt.params.wAddr%>)-1);
           if (actual_err_addr !== exp_err_addr) begin
             `uvm_error(get_full_name(),$sformatf("received addr = 0x%0x didn't match with expected addr = 0x%0x",actual_err_addr, exp_err_addr))
           end
           // Read DIIUUESAR_ErrVld , it should be 1
           read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUESAR.ErrVld, read_data);
           write_data = 0;
           write_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUEDR.ProtErrDetEn, write_data);
           // write  DIIUUESR_ErrVld = 1 , W1C
           write_data = 1;
           write_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUESR.ErrVld, write_data);
           // Read the DIIUUESR_ErrVld should be cleared
           read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUESR.ErrVld, read_data);
           compareValues("DIIUUESR_ErrVld", "now clear", read_data, 0);
           // of register DIIUUESR_*
           // write  DIIUUESR_ErrVld = 1 , to make sure it only reset by 1, not set by 1
           write_data = 1;
           write_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUESR.ErrVld, write_data);
           // Read the DIIUUESR_ErrVld should be still be 0
           read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUESR.ErrVld, read_data);
           compareValues("DIIUUESR_ErrVld", "still clear", read_data, 0);    
       end else begin
           // Read the DIIUUESR_ErrVld should be clear
           read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUESR.ErrVld, read_data);
           compareValues("DIIUESR_ErrVld", "RAZ/WI", read_data, 0);
           // Read DIIUUESAR_ErrVld , it should also clear, beacuse it is alias register
           // of register DIIUUESR_*
           read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUESAR.ErrVld, read_data);
           compareValues("DIIUESAR_ErrVld", "RAZ/WI", read_data, 0);
           // Read the DIIUUESR_ErrVld should be still be 0
           read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUESR.ErrVld, read_data);
           compareValues("DIIUUESR_ErrVld", "still clear", read_data, 0);
           // write  DIIUUESR_ErrVld = 1 , to reset it
           write_data = 1;
           write_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUESR.ErrVld, write_data);
           // Read the DIIUUESR_ErrVld should be cleared
           write_data = 1;
           write_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUESR.ErrVld, write_data);
           read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUESR.ErrVld, read_data);
           compareValues("DIIUUESR_ErrVld", "clear", read_data, 0);
           // Read DIIUUESAR_ErrVld , it should also clear, beacuse it is alias register
           // of register DIIUUESR_*
           read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUESAR.ErrVld, read_data);
           compareValues("DIIUUESAR_ErrVld", "clear", read_data, 0);
       end
    endtask
endclass : dii_csr_diiuedr_rdProtErrDetEn_seq

//-----------------------------------------------------------------------
/**
* Abstract:
* 
* In this test we will check if write response error is inserted it should capture with correct ErrType 
* Test will get arguments of this sequence name from command line and 
* call the body of this sequence.
* Inject ace write response error for all responses 
* 1. Program Error detection for protocol check
* 2. Poll until error information logged.
* 3. Compare error type with appropriate type mentioned in table.
* 4. Clear ErrVld bit with writing 1.
*/
//-----------------------------------------------------------------------
//-----------------------------------------------------------------------
//
class dii_csr_diiuedr_wrProtErrDetEn_seq extends dii_ral_csr_base_seq; 
  `uvm_object_utils(dii_csr_diiuedr_wrProtErrDetEn_seq)

    uvm_reg_data_t poll_data, read_data, read_data2, write_data;
    bit [7:0]  errthd;
    int        errcount_vld, errthd_vld;
    int        errcount_ovf;
    bit [3:0]  errtype;
    dii_txn scb_txn;
    axi_axaddr_t exp_err_addr;
    bit [3:0] errinfo_bresp_err;
    bit [31:0] erraddr0;
    bit [19:0] erraddr1;
    bit [51:0]actual_err_addr;
   
    function new(string name="");
        super.new(name);
    endfunction

    task body();

    if (has_ucerr_enabled) begin
           if (smi_dtw_err_en_enabled)
             errtype = 4'h0;
           else
             errtype = 4'h2;

           // Set the DIIUUECR_ErrDetEn = 1
           write_data = 1;
           write_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUEDR.ProtErrDetEn, write_data);
           fork
             begin
               ev_bresp.wait_ptrigger();
               $cast(scb_txn,ev_bresp.get_trigger_data());
//               exp_err_addr = scb_txn.axi_write_addr_pkt.awaddr;
               exp_err_addr = scb_txn.smi_recd[eConcMsgCmdReq].smi_addr;
               errinfo_bresp_err = {1'b0,scb_txn.axi_write_addr_pkt.awprot[1],scb_txn.axi_write_resp_pkt.bresp};
             end
             begin
               #10000ns;
               `uvm_error("BRESP","BRESP event was not triggered")
             end
           join_any
           disable fork;
          `uvm_info(get_full_name(),$sformatf("exp_err_addr = 0x%0x, errinfo_bresp_err = 0x%0x",exp_err_addr,errinfo_bresp_err),UVM_DEBUG)
           //keep on  Reading the DIIUUESR_ErrVld bit = 1
           poll_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUESR.ErrVld,1,poll_data);
             
           read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUESR.ErrType, read_data);
           compareValues("DIIUUESR_ErrType","Valid Type", read_data, errtype);
           //#Check.DII.v3.protocol
           read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUESR.ErrInfo, read_data);
           compareValues("DIIUUESR_ErrInfo","Valid Type", read_data, errinfo_bresp_err);
           read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUELR0.ErrAddr, read_data);
           erraddr0 = read_data;
           read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUELR1.ErrAddr, read_data);
           erraddr1 = read_data;
           // need to mask address to the actual AXI address bus width
           actual_err_addr = {erraddr1,erraddr0} & ((1 << <%=obj.DiiInfo[obj.Id].interfaces.axiInt.params.wAddr%>)-1);
           if (actual_err_addr !== exp_err_addr) begin
             `uvm_error(get_full_name(),$sformatf("received addr = 0x%0x didn't match with expected addr = 0x%0x",actual_err_addr, exp_err_addr))
           end
           // Read DIIUUESAR_ErrVld , it should be 1
           read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUESAR.ErrVld, read_data);
           write_data = 0;
           write_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUEDR.ProtErrDetEn, write_data);
           // write  DIIUUESR_ErrVld = 1 , W1C
           write_data = 1;
           write_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUESR.ErrVld, write_data);
           // Read the DIIUUESR_ErrVld should be cleared
           read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUESR.ErrVld, read_data);
           compareValues("DIIUUESR_ErrVld", "now clear", read_data, 0);
           // of register DIIUUESR_*
           // write  DIIUUESR_ErrVld = 1 , to make sure it only reset by 1, not set by 1
           write_data = 1;
           write_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUESR.ErrVld, write_data);
           // Read the DIIUUESR_ErrVld should be still be 0
           read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUESR.ErrVld, read_data);
           compareValues("DIIUUESR_ErrVld", "still clear", read_data, 0);
    end else begin
           // Read the DIIUUESR_ErrVld should be clear
           read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUESR.ErrVld, read_data);
           compareValues("DIIUESR_ErrVld", "RAZ/WI", read_data, 0);
           // Read DIIUUESAR_ErrVld , it should also clear, beacuse it is alias register
           // of register DIIUUESR_*
           read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUESAR.ErrVld, read_data);
           compareValues("DIIUESAR_ErrVld", "RAZ/WI", read_data, 0);
           // Read the DIIUUESR_ErrVld should be still be 0
           read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUESR.ErrVld, read_data);
           compareValues("DIIUUESR_ErrVld", "still clear", read_data, 0);
           // write  DIIUUESR_ErrVld = 1 , to reset it
           write_data = 1;
           write_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUESR.ErrVld, write_data);
           // Read the DIIUUESR_ErrVld should be cleared
           write_data = 1;
           write_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUESR.ErrVld, write_data);
           read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUESR.ErrVld, read_data);
           compareValues("DIIUUESR_ErrVld", "clear", read_data, 0);
           // Read DIIUUESAR_ErrVld , it should also clear, beacuse it is alias register
           // of register DIIUUESR_*
           read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUESAR.ErrVld, read_data);
           compareValues("DIIUUESAR_ErrVld", "clear", read_data, 0);
    end
    endtask
endclass : dii_csr_diiuedr_wrProtErrDetEn_seq

//-----------------------------------------------------------------------
/**
* Abstract:
* 
* In this test we will check if insert wrong target id then it should be captured. 
* Test will get arguments of this sequence name from command line and 
* call the body of this sequence.
* Inject incorrect target id from command request. 
* 1. Program Error detection for concerto messages 
* 2. Poll until error information logged.
* 3. Compare error type with appropriate type mentioned in table.
* 4. Clear ErrVld bit with writing 1.
*/
//-----------------------------------------------------------------------
//-----------------------------------------------------------------------
//
class dii_csr_diiuedr_TransErrDetEn_seq extends dii_ral_csr_base_seq; 
  `uvm_object_utils(dii_csr_diiuedr_TransErrDetEn_seq)

    uvm_reg_data_t poll_data, read_data, read_data2, write_data;
    bit [7:0]  errthd;
    int        errcount_vld, errthd_vld;
    int        errcount_ovf;
    bit [3:0]  errtype;
    bit [19:0] errinfo;
    smi_seq_item smi_pkt;

    function new(string name="");
        super.new(name);
    endfunction

    task body();

    bit dis_uedr_ted_4resiliency = $test$plusargs("dis_uedr_ted_4resiliency") ? 1 : 0;
    getCsrProbeIf();
    if (has_ucerr_enabled && !dis_uedr_ted_4resiliency) begin
           errtype = 4'h8;
           errinfo[0] = 1'b0;
           //errinfo[5:1] = reserved;

           // Set DIIUUECR_ErrDetEn = 1
           write_data = 1;
           write_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUEDR.TransErrDetEn, write_data);

           // Set DIIUUEIR intEn = 1
           write_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUEIR.TransErrIntEn, write_data);
           ev_irq_uc_en.trigger();
           ev_targ_id_err.wait_ptrigger();
           $cast(smi_pkt,ev_targ_id_err.get_trigger_data());
           errinfo[19:8] = smi_pkt.smi_src_ncore_unit_id;
           `uvm_info(get_full_name(),$sformatf("errinfo = %0h",errinfo),UVM_MEDIUM);
	   //#Check.DII.WrongTargetId.ErrVld
           //keep on  Reading the DIIUUESR_ErrVld bit = 1
           poll_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUESR.ErrVld,1,poll_data);
           //#Check.DII.WrongTargetId.ErrType  
           read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUESR.ErrType, read_data);
           compareValues("DIIUUESR_ErrType","Valid Type", read_data, errtype);
           `uvm_info($sformatf("%m"), $sformatf("Target ID Error test: Observed error=%0d", read_data), UVM_NONE)
	   //#Check.DII.WrongTargetId.ErrInfo 
           read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUESR.ErrInfo, read_data);
           compareValues("DIIUUESR_ErrInfo","Valid Type", read_data, errinfo);

           // Read DIIUUESAR_ErrVld , it should be 1
           read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUESR.ErrVld, read_data);
           assert(read_data == 1) else begin
              `uvm_error($sformatf("%m"), $sformatf("Error Valid not asserted"))
           end
	   //#Check.DII.WrongTargetId.IRQ_UC
           // UC interrupt should be asserted
           assert(u_csr_probe_vif.IRQ_UC == 1) else begin
              `uvm_error($sformatf("%m"), $sformatf("UC interrupt not asserted or not level"))
           end

           write_data = 0;
           write_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUEDR.TransErrDetEn, write_data);
           write_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUEIR.TransErrIntEn, write_data);

           // write  DIIUUESR_ErrVld = 1 , W1C
           write_data = 1;
           write_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUESR.ErrVld, write_data);
           // Read the DIIUUESR_ErrVld should be cleared
           read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUESR.ErrVld, read_data);
           compareValues("DIIUUESR_ErrVld", "now clear", read_data, 0);
           // write  DIIUUESR_ErrVld = 1 , to make sure it only reset by 1, not set by 1
           write_data = 1;
           write_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUESR.ErrVld, write_data);
           // Read the DIIUUESR_ErrVld should be still be 0
           read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUESR.ErrVld, read_data);
           compareValues("DIIUUESR_ErrVld", "still clear", read_data, 0);

           // UC interrupt should be cleared
           assert(u_csr_probe_vif.IRQ_UC == 0) else begin
              `uvm_error($sformatf("%m"), $sformatf("UC interrupt not cleared"))
           end
       end else begin
           if(dis_uedr_ted_4resiliency) begin
             `uvm_info(get_full_name(),$sformatf("Skipping enabling of error detection inside xUEDR"),UVM_NONE)
             ev_irq_uc_en.trigger();
             ev_targ_id_err.wait_ptrigger();
             #10us;
             `uvm_info(get_full_name(),$sformatf("Timeout!"),UVM_NONE)
           end
           // Read the DIIUUESR_ErrVld should be clear
           read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUESR.ErrVld, read_data);
           compareValues("DIIUESR_ErrVld", "RAZ/WI", read_data, 0);
           // Read DIIUUESAR_ErrVld , it should also clear, beacuse it is alias register
           // of register DIIUUESR_*
           read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUESAR.ErrVld, read_data);
           compareValues("DIIUESAR_ErrVld", "RAZ/WI", read_data, 0);
           // Read the DIIUUESR_ErrVld should be still be 0
           read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUESR.ErrVld, read_data);
           compareValues("DIIUUESR_ErrVld", "still clear", read_data, 0);
           // write  DIIUUESR_ErrVld = 1 , to reset it
           write_data = 1;
           write_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUESR.ErrVld, write_data);
           // Read the DIIUUESR_ErrVld should be cleared
           write_data = 1;
           write_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUESR.ErrVld, write_data);
           read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUESR.ErrVld, read_data);
           compareValues("DIIUUESR_ErrVld", "clear", read_data, 0);
           // Read DIIUUESAR_ErrVld , it should also clear, beacuse it is alias register
           // of register DIIUUESR_*
           read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUESAR.ErrVld, read_data);
           compareValues("DIIUUESAR_ErrVld", "clear", read_data, 0);
       end
      `uvm_info($sformatf("%m"), $sformatf("Target ID Error test finished"), UVM_NONE)
    endtask
endclass : dii_csr_diiuedr_TransErrDetEn_seq

//-----------------------------------------------------------------------
/**
* Abstract:
* 
* In this test we will check if insert double bit sram errors. 
* Test will get arguments of this sequence name from command line and 
* call the body of this sequence.
* Inject double bit SRAM error for all transfer 
* 1. Program Error detection for uncorrectable double bit error in SRAM 
* 2. Poll until error information logged.
* 3. Compare error type with appropriate type mentioned in table.
* 4. Clear ErrVld bit with writing 1.
*/
//-----------------------------------------------------------------------
//-----------------------------------------------------------------------
//
class dii_csr_diiuedr_MemErrDetEn_seq extends dii_ral_csr_base_seq; 
  `uvm_object_utils(dii_csr_diiuedr_MemErrDetEn_seq)

    uvm_reg_data_t poll_data, read_data, read_data2, write_data;
    bit [7:0]  errthd;
    int        errcount_vld, errthd_vld;
    int        errcount_ovf;
    bit [3:0]  errtype;

    function new(string name="");
        super.new(name);
    endfunction

    task body();
<% if (obj.DiiInfo[obj.Id].useExternalMemory) { %>
    if (has_ucerr_enabled) begin
           if (smi_dtw_err_en_enabled)
             errtype = 4'h0;
           else
             errtype = 4'h1;

           // Set the DIIUUECR_ErrDetEn = 1
           write_data = 1;
           write_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUEDR.MemErrDetEn, write_data);
           //keep on  Reading the DIIUUESR_ErrVld bit = 1
           poll_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUESR.ErrVld,1,poll_data);
             
           read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUESR.ErrType, read_data);
           compareValues("DIIUUESR_ErrType","Valid Type", read_data, errtype);
           // Read DIIUUESAR_ErrVld , it should be 1
           read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUESAR.ErrVld, read_data);
           write_data = 0;
           write_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUEDR.MemErrDetEn, write_data);
           // write  DIIUUESR_ErrVld = 1 , W1C
           write_data = 1;
           write_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUESR.ErrVld, write_data);
           // Read the DIIUUESR_ErrVld should be cleared
           read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUESR.ErrVld, read_data);
           compareValues("DIIUUESR_ErrVld", "now clear", read_data, 0);
           // write  DIIUUESR_ErrVld = 1 , to make sure it only reset by 1, not set by 1
           write_data = 1;
           write_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUESR.ErrVld, write_data);
           // Read the DIIUUESR_ErrVld should be still be 0
           read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUESR.ErrVld, read_data);
           compareValues("DIIUUESR_ErrVld", "still clear", read_data, 0);
    end else begin
           // Read the DIIUUESR_ErrVld should be clear
           read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUESR.ErrVld, read_data);
           compareValues("DIIUESR_ErrVld", "RAZ/WI", read_data, 0);
           // Read DIIUUESAR_ErrVld , it should also clear, beacuse it is alias register
           // of register DIIUUESR_*
           read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUESAR.ErrVld, read_data);
           compareValues("DIIUESAR_ErrVld", "RAZ/WI", read_data, 0);
           // Read the DIIUUESR_ErrVld should be still be 0
           read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUESR.ErrVld, read_data);
           compareValues("DIIUUESR_ErrVld", "still clear", read_data, 0);
           // write  DIIUUESR_ErrVld = 1 , to reset it
           write_data = 1;
           write_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUESR.ErrVld, write_data);
           // Read the DIIUUESR_ErrVld should be cleared
           write_data = 1;
           write_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUESR.ErrVld, write_data);
           read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUESR.ErrVld, read_data);
           compareValues("DIIUUESR_ErrVld", "clear", read_data, 0);
           // Read DIIUUESAR_ErrVld , it should also clear, beacuse it is alias register
           // of register DIIUUESR_*
           read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUESAR.ErrVld, read_data);
           compareValues("DIIUUESAR_ErrVld", "clear", read_data, 0);
    end
<% } else { %>
           `uvm_info($sformatf("%m"), $sformatf("MemErrDetEn: DII does not have internal memory. SKIPPED"), UVM_NONE)
<% } %>
    endtask
endclass : dii_csr_diiuedr_MemErrDetEn_seq

//-----------------------------------------------------------------------
/**
* Abstract:
* 
* In this test we will check if insert double bit sram errors is detected by interrupt. 
* Test will get arguments of this sequence name from command line and 
* call the body of this sequence.
* Inject double bit SRAM error for all transfer 
* 1. Program Error detection for uncorrectable double bit error in SRAM
* 2. Program Error interrupt with 1. 
* 3. Poll until error information logged and interrupt is asserted.
* 4. Compare error type with appropriate type mentioned in table.
* 5. Program Error interrupt with 0 (disable). 
* 6. Clear ErrVld bit with writing 1.
* 7. Poll interrupt signal which should not asserted.
*/
//-----------------------------------------------------------------------
//-----------------------------------------------------------------------
class dii_csr_diiueir_MemErrInt_seq extends dii_ral_csr_base_seq; 
  `uvm_object_utils(dii_csr_diiueir_MemErrInt_seq)

    uvm_reg_data_t poll_data, read_data, read_data2, write_data;
    bit [7:0]  errthd;
    int        errcount_vld, errthd_vld;
    int        errcount_ovf;
    bit [3:0]  errtype;

    function new(string name="");
        super.new(name);
    endfunction

    task body();

<% if (obj.DiiInfo[obj.Id].useExternalMemory) { %>
       getCsrProbeIf();
       if (has_ucerr_enabled) begin
           errtype = 4'h1;
           // Set the DIIUUEIR_ProtErrIntEn = 1
           write_data = 1;
           write_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUEDR.MemErrDetEn, write_data);
           // Set the DIIUUEIR_ProtErrIntEn = 1
           write_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUEIR.MemErrIntEn, write_data);
           // wait for IRQ_UC interrupt 
           //if(u_csr_probe_vif.IRQ_UC == 0)begin // wait only if not already set
           fork
           begin
             if (u_csr_probe_vif.IRQ_UC == 0) begin
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
           // Read the DIIUUESR_ErrVld
           read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUESR.ErrVld, read_data);
           compareValues("DIIUUESR_ErrVld", "set after inte", read_data, 1);
           read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUESR.ErrType, read_data);
           compareValues("DIIUUESR_ErrType","Valid Type", read_data, errtype);
           // Set the DIIUUECR_ErrDetEn = 0, to disable the error detection
           write_data = 0;
           write_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUEIR.MemErrIntEn, write_data);
           // write DIIUUESR_ErrVld = 1 to clear it
           write_data = 1;
           write_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUESR.ErrVld, write_data);
           // Read DIIUUESR_ErrVld , it should be 0
           read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUESR.ErrVld, read_data);
           compareValues("DIIUUESR_ErrVld", "reset", read_data, 0);
           // Monitor IRQ_C pin , it should be 0 now
           assert (u_csr_probe_vif.IRQ_UC == 0) else begin
             `uvm_error("RUN_MAIN",$sformatf("IRQ_UC interruped still aseerted"));
           end
       end else begin
           // Monitor IRQ_UC pin , it should be 0 now
           if(u_csr_probe_vif.IRQ_UC == 0)begin
             `uvm_info("RUN_MAIN",$sformatf("IRQ_UC interrupted de-asserted"), UVM_MEDIUM)
           end else begin
             `uvm_error("RUN_MAIN",$sformatf("IRQ_UC interruped asserted"));
           end
          // Read DIIUUESR_ErrVld , it should be 0
           read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUESR.ErrVld, read_data);
           compareValues("DIIUUESR_ErrVld", "set", read_data, 0);
           read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUESR.ErrType, read_data);
           compareValues("DIIUUESR_ErrType","Valid Type", read_data, 4'h0);
          // Read DIIUUESAR_ErrVld , it should be 0
           read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUESAR.ErrVld, read_data);
           compareValues("DIIUUESAR_ErrVld", "set", read_data, 0);
           read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUESAR.ErrType, read_data);
           compareValues("DIIUUESAR_ErrType","Valid Type", read_data, 4'h0);
          // Monitor IRQ_C pin , it should be 0 now
          if(u_csr_probe_vif.IRQ_UC == 0)begin
             `uvm_info("RUN_MAIN",$sformatf("IRQ_UC interrupted de-asseretd"), UVM_MEDIUM)
          end else begin
             `uvm_error("RUN_MAIN",$sformatf("IRQ_UC interruped still aseerted"));
          end
       end
<% } else { %>
           `uvm_info($sformatf("%m"), $sformatf("MemErrDetEn: DII does not have internal memory. SKIPPED"), UVM_NONE)
<% } %>
    endtask
endclass : dii_csr_diiueir_MemErrInt_seq

//-----------------------------------------------------------------------
/**
* Abstract:
* 
* In this test we will check if insert protocol error interrupt should be asserted 
* Test will get arguments of this sequence name from command line and 
* call the body of this sequence.
* Inject ace read/write errors 
* 1. Program Error detection for uncorrectable prot error 
* 2. Program Error interrupt with 1. 
* 3. Poll until error information logged and interrupt is asserted.
* 4. Compare error type with appropriate type mentioned in table.
* 5. Program Error interrupt with 0 (disable). 
* 6. Clear ErrVld bit with writing 1.
* 7. Poll interrupt signal which should not asserted.
*/
//-----------------------------------------------------------------------
//-----------------------------------------------------------------------

class dii_csr_diiueir_ProtErrInt_seq extends dii_ral_csr_base_seq; 
  `uvm_object_utils(dii_csr_diiueir_ProtErrInt_seq)

    uvm_reg_data_t poll_data, read_data, read_data2, write_data;
    bit [7:0]  errthd;
    int        errcount_vld, errthd_vld;
    int        errcount_ovf;
    bit [3:0] errtype;

    function new(string name="");
        super.new(name);
    endfunction

    task body();

       getCsrProbeIf();
       if (has_ucerr_enabled) begin
         if ($test$plusargs("native_read_error")) begin
           errtype = 4'h3;
         end else if ($test$plusargs("native_write_error")) begin
          errtype = 4'h2;
         end
           // Set the DIIUUEIR_ProtErrIntEn = 1
           write_data = 1;
           write_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUEDR.ProtErrDetEn, write_data);
           // Set the DIIUUEIR_ProtErrIntEn = 1
           write_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUEIR.ProtErrIntEn, write_data);
           // wait for IRQ_UC interrupt 
           //if(u_csr_probe_vif.IRQ_UC == 0)begin // wait only if not already set
           fork
           begin
             if (u_csr_probe_vif.IRQ_UC == 0) begin
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
           // Read the DIIUUESR_ErrVld
           read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUESR.ErrVld, read_data);
           compareValues("DIIUUESR_ErrVld", "set after inte", read_data, 1);
           read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUESR.ErrType, read_data);
           compareValues("DIIUUESR_ErrType","Valid Type", read_data, errtype);
           // Set the DIIUUECR_ErrDetEn = 0, to disable the error detection
           write_data = 0;
           write_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUEDR.ProtErrDetEn, write_data);
           write_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUEIR.ProtErrIntEn, write_data);
           // write DIIUUESR_ErrVld = 1 to clear it
           write_data = 1;
           write_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUESR.ErrVld, write_data);
           // Read DIIUUESR_ErrVld , it should be 0
           read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUESR.ErrVld, read_data);
           compareValues("DIIUUESR_ErrVld", "reset", read_data, 0);
           // Monitor IRQ_C pin , it should be 0 now
           if(u_csr_probe_vif.IRQ_UC == 0)begin
             `uvm_info("RUN_MAIN",$sformatf("IRQ_UC interrupted de-asseretd"), UVM_MEDIUM)
           end else begin
             `uvm_error("RUN_MAIN",$sformatf("IRQ_UC interruped still aseerted"));
           end
       end else begin
           // Monitor IRQ_UC pin , it should be 0 now
           if(u_csr_probe_vif.IRQ_UC == 0)begin
             `uvm_info("RUN_MAIN",$sformatf("IRQ_UC interrupted de-asserted"), UVM_MEDIUM)
           end else begin
             `uvm_error("RUN_MAIN",$sformatf("IRQ_UC interruped asserted"));
           end
          // Read DIIUUESR_ErrVld , it should be 0
           read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUESR.ErrVld, read_data);
           compareValues("DIIUUESR_ErrVld", "set", read_data, 0);
           read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUESR.ErrType, read_data);
           compareValues("DIIUUESR_ErrType","Valid Type", read_data, 4'h0);
          // Read DIIUUESAR_ErrVld , it should be 0
           read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUESAR.ErrVld, read_data);
           compareValues("DIIUUESAR_ErrVld", "set", read_data, 0);
           read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUESAR.ErrType, read_data);
           compareValues("DIIUUESAR_ErrType","Valid Type", read_data, 4'h0);
          // Monitor IRQ_C pin , it should be 0 now
          if(u_csr_probe_vif.IRQ_UC == 0)begin
             `uvm_info("RUN_MAIN",$sformatf("IRQ_UC interrupted de-asseretd"), UVM_MEDIUM)
          end else begin
             `uvm_error("RUN_MAIN",$sformatf("IRQ_UC interruped still aseerted"));
          end
       end
    endtask
endclass : dii_csr_diiueir_ProtErrInt_seq

//-----------------------------------------------------------------------
//-----------------------------------------------------------------------
/**
* Abstract:
* 
* In this test we will check if uncorrectable errors are count by Error counter. 
* Test will get arguments of this sequence name from command line and 
* call the body of this sequence.
* Inject ace read/write response error
* 1. Eable Error detection from uncorrectable CSR.
* 2. Poll ErrVld from Status register until it is set i.e. Uncorrectable Errors are logged.
* 3. Compare ErrCount value and should be non-zero 
* 4. Disable Error Detection filed by writing 0.
* 5. Clear ErrVld by writting 1 (W1C access types of this field) in status register
* 6. Check if ErrCount should be cleared.
* 7. Repeat step 1 to 10.
*/
//-----------------------------------------------------------------------
//-----------------------------------------------------------------------
class dii_csr_diiuedr_ProtErrThd_seq extends dii_ral_csr_base_seq; 
  `uvm_object_utils(dii_csr_diiuedr_ProtErrThd_seq)

    uvm_reg_data_t poll_data, read_data, read_data2, write_data;
    bit [7:0]  errthd;
    int        errcount_vld, errthd_vld;
    int        errcount_ovf;

    function new(string name="");
        super.new(name);
    endfunction

    task body();

       //getCsrProbeIf();
       if (has_ucerr_enabled) begin
          // Set the DIIUUECR_ErrDetEn = 1
          write_data = 1;
          write_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUEDR.ProtErrDetEn, write_data);
          // write  DIIUUESR_ErrVld = 1 , to reset it
          write_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUESR.ErrVld, write_data);
          //keep on  Reading the DIIUUESR_ErrVld bit = 1 
          poll_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUESR.ErrVld,1,poll_data);
          // Read DIIUUESR_ErrCount , it should be at errthd
          //read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUESR.ErrCount, read_data);
          //if(read_data == 0)begin
          //    `uvm_error("RUN_MAIN",$sformatf("ErrCount should not be 0"))
          //end
          // write : DIIUUESR_ErrVld = 1 , to reset it
          write_data = 1;
          write_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUESR.ErrVld, write_data);
          // Read DIIUUESAR_ErrVld , it should be 0
          read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUESAR.ErrVld, read_data);
          compareValues("DIIUUESAR_ErrVld", "now clear", read_data, 0);
          // Read DIIUUESR_ErrVld , it should be 0
          read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUESR.ErrVld, read_data);
          compareValues("DIIUUESR_ErrVld", "now clear", read_data, 0);
          //read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUESR.ErrCount, read_data);
          //compareValues("DIIUUESR_ErrCount", "now clear", read_data, 0);
          //////////////////////////////////////////////////////////
          // Repeat entire process
          //////////////////////////////////////////////////////////
          // Set the DIIUUECR_ErrDetEn = 1
          write_data = 1;
          write_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUEDR.ProtErrDetEn, write_data);
          // write  DIIUUESR_ErrVld = 1 , to reset it
          write_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUESR.ErrVld, write_data);
          //keep on  Reading the DIIUUESR_ErrVld bit = 1 
          poll_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUESR.ErrVld,1,poll_data);
          // Read DIIUUESR_ErrCount , it should be at errthd
          //read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUESR.ErrCount, read_data);
          //if(read_data == 0)begin
          //    `uvm_error("RUN_MAIN",$sformatf("ErrCount should not be 0"))
          //end
          // write : DIIUUESR_ErrVld = 1 , to reset it
          write_data = 1;
          write_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUESR.ErrVld, write_data);
          // Read DIIUUESAR_ErrVld , it should be 0
          read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUESAR.ErrVld, read_data);
          compareValues("DIIUUESAR_ErrVld", "now clear", read_data, 0);
          // Read DIIUUESR_ErrVld , it should be 0
          read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUESR.ErrVld, read_data);
          compareValues("DIIUUESR_ErrVld", "now clear", read_data, 0);
          //read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUESR.ErrCount, read_data);
          //compareValues("DIIUUESR_ErrCount", "now clear", read_data, 0);
       end else begin
          // Read DIIUUESR_ErrCount , it should be 0
          // write alias : DIIUUESAR_ErrVld = 1 , to reset it
          write_data = 1;
          write_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUESR.ErrVld, write_data);
          //#Test.DMI.ESARWriteUpdatesESR
          read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUESR.ErrVld, read_data);
          compareValues("DIIUUESR_ErrVld", "clear", read_data, 0);
       end
    endtask
endclass : dii_csr_diiuedr_ProtErrThd_seq

//-----------------------------------------------------------------------
//  Task    : 
//  Purpose : 
//
//-----------------------------------------------------------------------
//#Test.DMI.ErrInjWhileSoftwareWriteHappens
class dii_csr_diiuecr_sw_write_seq extends dii_ral_csr_base_seq; 
  `uvm_object_utils(dii_csr_diiuecr_sw_write_seq)

    uvm_reg_data_t poll_data, read_data, read_data2, write_data;
    bit [7:0]  errthd;
    int        errcount_vld, errthd_vld;
    int        i;

    function new(string name="");
        super.new(name);
    endfunction

    task body();

<%    if (has_ucerr || (obj.DiiInfo[obj.Id].ResilienceInfo.fnResiliencyProtectionType === "ecc") ||
          (obj.DiiInfo[obj.Id].ResilienceInfo.fnResiliencyProtectionType === "parity")) { %>
         write_data = 1;
         write_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUESAR.ErrVld, write_data);
         read_csr( m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUESR.ErrVld, read_data);
         compareValues("DIIUUESR_ErrVld", "set", read_data, 1);

         write_data = 0;
         write_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUESR.ErrVld, write_data);
         read_csr( m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUESR.ErrVld, read_data);
         compareValues("DIIUUESR_ErrVld", "set", read_data, 1);

         write_data = 1;
         write_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUESR.ErrVld, write_data);
         read_csr( m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUESR.ErrVld, read_data);
         compareValues("DIIUUESR_ErrVld", "set", read_data, 0);

         write_data = 4'b1111;
         write_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUESAR.ErrType, write_data);
         read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUESR.ErrType, read_data);
         compareValues("DIIUUESR_ErrType0", "set", read_data, write_data);
         write_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUESR.ErrType, 4'b0000);
         read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUESR.ErrType, read_data);
         compareValues("DIIUUESR_ErrType1", "set", read_data, write_data);
         write_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUESR.ErrType, 4'b1111);
         read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUESR.ErrType, read_data);
         compareValues("DIIUUESR_ErrType2", "set", read_data, write_data);
         write_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUESAR.ErrType, 4'b0000);
         read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUESR.ErrType, read_data);
         compareValues("DIIUUESR_ErrType3", "set", read_data, 4'b0000);

         write_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUESAR.ErrInfo, 20'hfffff);
         read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUESR.ErrInfo, read_data);
         compareValues("DIIUUESR_ErrInfo4", "set", read_data, 20'hfffff);
         write_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUESR.ErrInfo, 20'h00000);
         read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUESR.ErrInfo, read_data);
         compareValues("DIIUUESR_ErrInfo5", "set", read_data, 20'hfffff);
         write_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUESR.ErrInfo, 20'hfffff);
         read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUESR.ErrInfo, read_data);
         compareValues("DIIUUESR_ErrInfo6", "set", read_data, 20'hfffff);
         write_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUESAR.ErrInfo, 20'h00000);
         read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUESR.ErrInfo, read_data);
         compareValues("DIIUUESR_ErrInfo7", "clear", read_data, 20'h00000);

         write_data = 1;
         write_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUESR.ErrVld, write_data);
         read_csr( m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUESR.ErrVld, read_data);
         compareValues("DIIUUESR_ErrVld", "set", read_data, 0);
<% } %>
       //getCsrProbeIf();
      if (has_ucerr_enabled) begin
          // Set the DIIUUECR_ErrDetEn = 1
          write_data = 1;
          write_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUEDR.ProtErrDetEn, write_data);
          // write  DIIUCESR_ErrVld = 1 , to reset it
          write_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUESR.ErrVld, write_data);
          write_data = 0;
          for (i=0;i<100;i++) begin
             write_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUESAR.ErrVld, write_data);
          end
          // Set the DIIUUECR_ErrDetEn = 0
          write_data = 0;
          write_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUEDR.ProtErrDetEn, write_data);
          // if vld is set, reset it
          read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUESR.ErrVld, read_data);
          if(read_data) begin
             write_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUESAR.ErrVld, write_data);
          end
      end
    endtask
endclass : dii_csr_diiuecr_sw_write_seq

//-----------------------------------------------------------------------
/**
* Abstract:
* 
* In this test we will check if uncorrectable errors are injected and logging is disabled ErrVld should be 0. 
* Test will get arguments of this sequence name from command line and 
* call the body of this sequence.
* 1. Poll for ErrVld be set and compare to 0.
*/
//-----------------------------------------------------------------------
//-----------------------------------------------------------------------
//

//#Test.DMI.DetectEnNotSetErrorsInjected
class dii_csr_diiuecr_noDetEn_seq extends dii_ral_csr_base_seq; 
  `uvm_object_utils(dii_csr_diiuecr_noDetEn_seq)

    uvm_reg_data_t poll_data, read_data, read_data2, write_data;
    bit [7:0]  errthd;
    int        errcount_vld, errthd_vld;
    int        errcount_ovf;

    function new(string name="");
        super.new(name);
    endfunction

    task body();

       if (has_ucerr_enabled) begin
          // Don't Set the DIIUUECR_ErrDetEn = 1
          //Reading the DIIUUESR_ErrVld bit = 0
          read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUESR.ErrVld, read_data);
          compareValues("DIIUUESR_ErrVld", "not set", read_data, 0);
          // Read DIIUUESR_ErrCount , it should be at 0
       end else begin
          // Read the DIIUUESR_ErrVld should be cleared
          read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUESR.ErrVld, read_data);
          compareValues("DIIUUESR_ErrVld", "not set", read_data, 0);
          // Read DIIUUESAR_ErrVld , it should also clear, beacuse it is alias register
          // of register DIIUUESR_*
          read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUESAR.ErrVld, read_data);
          compareValues("DIIUUESAR_ErrVld", "not set", read_data, 0);
       end
    endtask
endclass : dii_csr_diiuecr_noDetEn_seq

//-----------------------------------------------------------------------
/**
* Abstract:
* 
* In this test we will check if uncorrectable errors are injected and interrupt assertion is disabled (ErrIntEn set to 0) ErrVld and ErrCount should be 0. 
* Test will get arguments of this sequence name from command line and 
* call the body of this sequence.
* 1. Enable  error detection and logging.       
* 2. Wait to check if interrupt signal is asserted or not.
* 3. Poll for ErrVld be set and compare to 1.
* 4. Clear ErrVld value and should be zero 
* 5. Clear ErrCountOverflow value and should be zero 
*/
//-----------------------------------------------------------------------
//-----------------------------------------------------------------------
//

class dii_csr_diiuecr_noIntEn_seq extends dii_ral_csr_base_seq; 
  `uvm_object_utils(dii_csr_diiuecr_noIntEn_seq)

    uvm_reg_data_t poll_data, read_data, read_data2, write_data;
    bit [7:0]  errthd;
    int        errcount_vld, errthd_vld;
    int        errcount_ovf;

    function new(string name="");
        super.new(name);
    endfunction

    task body();

       getCsrProbeIf();
       if (has_ucerr_enabled) begin
          // Set the DIIUUECR_ErrDetEn = 1
          write_data = 1;
          write_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUEIR.ProtErrIntEn, write_data);
          // Dont Set the DIIUUECR_ErrIntEn = 1
          // wait for IRQ_UC interrupt for a while. Shouldn't happen. Then join
          //#Cov.DMI.ErrIntDisEnUnCorrErrs
          fork
            begin
             `uvm_info("RUN_MAIN",$sformatf("Waiting for interrupt. It shouldn't happen"), UVM_LOW)
             @(u_csr_probe_vif.IRQ_UC);
             `uvm_error("RUN_MAIN", $sformatf("Unexpected interrupt! IntEn is not set"));
            end
            begin
             #100000ns;
             `uvm_info("RUN_MAIN",$sformatf("Done waiting. No interrupt received"), UVM_LOW)
            end
          join_any
          disable fork;
          //Reading the DIIUUESR_ErrVld bit = 1
          read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUESR.ErrVld, read_data);
          compareValues("DIIUUESR_ErrVld", "set", read_data, 1);
          // write DIIUUESR_ErrVld = 1 to clear it
          write_data = 1;
          write_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUESR.ErrVld, write_data);
          //write_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUESR.ErrCountOverflow, write_data);
       end else begin
          fork
            begin
             `uvm_info("RUN_MAIN",$sformatf("Waiting for interrupt. It shouldn't happen"), UVM_LOW)
             @(u_csr_probe_vif.IRQ_UC);
             `uvm_error("RUN_MAIN", $sformatf("Unexpected interrupt! IntEn is not set"));
            end
            begin
             #100000ns;
             `uvm_info("RUN_MAIN",$sformatf("Done waiting. No interrupt received"), UVM_LOW)
            end
          join_any
          disable fork;
       end
    endtask
endclass : dii_csr_diiuecr_noIntEn_seq

//-----------------------------------------------------------------------
//  Task    : 
//  Purpose : 
//
//-----------------------------------------------------------------------
class dii_csr_diiuelr_seq1 extends dii_ral_csr_base_seq; 
  `uvm_object_utils(dii_csr_diiuelr_seq1)

    uvm_reg_data_t poll_data, read_data, read_data2, write_data;
    bit [7:0]  errthd;
    int        errcount_vld, errthd_vld;
    int        errentry, errway, errword, erraddr1;

    function new(string name="");
        super.new(name);
    endfunction

    task body();

       if (has_ucerr_enabled) begin
        `uvm_info("RUN_MAIN",$sformatf("Entered Test loop"), UVM_LOW)
          //#Test.DMI.ErrVldErrCountOverflowNotResetW1CIfClr
          // Try Set the DIIUUESR_ErrVld = 1. Shouldn't work as this field is W1C
          write_data = 1;
          write_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUESR.ErrVld, write_data);
          read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUESR.ErrVld, read_data);
          compareValues("DIIUUESR_ErrVld","Should be 0", read_data, 0);

          //write_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUESR.ErrCountOverflow, write_data);
          //read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUESR.ErrCountOverflow, read_data);
          //compareValues("DIIUUESR_ErrVld","Should be 0", read_data, 0);

          // Set the DIIUUECR_ErrDetEn = 1
          write_data = 1;
          write_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUEDR.ProtErrDetEn, write_data);
       end
    endtask
endclass : dii_csr_diiuelr_seq1

class dii_csr_diiuelr_seq2 extends dii_ral_csr_base_seq; 
  `uvm_object_utils(dii_csr_diiuelr_seq2)

    uvm_reg_data_t poll_data, read_data, read_data2, write_data;
    bit [7:0]  errthd;
    bit [43:0] actual_addr;
    bit [43:0] expt_addr;
    int        errcount_vld, errthd_vld;
    bit [31:0] erraddr0;
    bit [11:0] erraddr1;
    dii_txn    req_item;  

    static uvm_event_pool ev_pool = uvm_event_pool::get_global_pool();
    static uvm_event ev_rresp = ev_pool.get("ev_<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>_rresp");

    function new(string name="");
        super.new(name);
    endfunction

    task body();

       if (has_ucerr_enabled) begin
        `uvm_info("RUN_MAIN",$sformatf("Entered Test loop"), UVM_LOW)

          //keep on  Reading the DIIUUESR_ErrCount bit = 1
          write_data = 1;
          write_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUEDR.ProtErrDetEn, write_data);
          //read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUESR.ErrCountOverflow, read_data);
          //compareValues("DIIUUESR_ErrCountOverflow", "not set yet", read_data, 0);

          ev_rresp.wait_trigger();
          if($cast(req_item, ev_rresp.get_trigger_data())) begin
              expt_addr  = req_item.smi_recd[eConcMsgCmdReq].smi_addr;
          end 
    
          poll_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUESR.ErrVld,1,poll_data);

          //#Test.DMI.UnCorrErrErrLoggingSetAfterErrorCntCrossesErrThreshold
          //#Test.DMI.UnCorrErrErrLoggingRegisters
          //#Check.DMI.DetectEnSet
          //readCompareUELR(1);
          read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUELR0.ErrAddr, read_data);
          erraddr0 = read_data;
          read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUELR1.ErrAddr, read_data);
          erraddr1 = read_data;
          actual_addr = {erraddr1,erraddr0}; 
          compareValues("DIIUCELR", "error address matched", actual_addr, expt_addr);

       end
    endtask
endclass : dii_csr_diiuelr_seq2

class dii_csr_diicelr_seq extends dii_ral_csr_base_seq; 
  `uvm_object_utils(dii_csr_diicelr_seq)

    uvm_reg_data_t poll_data, read_data, read_data2, write_data;
    bit [7:0]  errthd;
    bit [43:0] actual_addr;
    bit [43:0] expt_addr;
    int        errcount_vld, errthd_vld;
    bit [31:0]  erraddr0;
    bit [11:0] erraddr1;
    smi_seq_item req_item;

    static uvm_event_pool ev_pool = uvm_event_pool::get_global_pool();
    static uvm_event ev = ev_pool.get("ev_<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>_ev");

    function new(string name="");
        super.new(name);
    endfunction

    task body();

<% if(has_cerr) { %>
        `uvm_info("RUN_MAIN",$sformatf("Entered Test loop"), UVM_LOW)


          ev.wait_trigger();
          if($cast(req_item, ev.get_trigger_data())) begin
              expt_addr  = req_item.smi_addr;
              `uvm_info(get_name(),$sformatf("exp_addr = %h",expt_addr),UVM_NONE)
          end 
    
           getCsrProbeIf();
           write_data = 1;
           write_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUCECR.ErrThreshold, write_data);

          //keep on  Reading the DIIUUESR_ErrCount bit = 1
           write_data = 1;
           write_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUCECR.ErrDetEn, write_data);
           // Set the DIIUCECR_ErrIntEn = 1
           write_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUCECR.ErrIntEn, write_data);
           // wait for IRQ_C interrupt 
           fork
           begin
             if (u_csr_probe_vif.IRQ_C == 0) begin
               @(u_csr_probe_vif.IRQ_C);
             end
           end
           begin
             #200000ns;
             `uvm_error("RUN_MAIN",$sformatf("Timeout! Did not see IRQ_C asserted"));
           end
           join_any
           disable fork;

          read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUCELR0.ErrAddr, read_data);
          erraddr0 = read_data;
          read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUCELR1.ErrAddr, read_data);
          erraddr1 = read_data;
          actual_addr = {erraddr1,erraddr0}; 
          compareValues("DIIUCELR", "error address matched", actual_addr, expt_addr);

<% } %>
    endtask
endclass : dii_csr_diicelr_seq

//-----------------------------------------------------------------------
/**
* Abstract:
* 
* In this test we assert corr/uncorr error for resiliency.
* Test will get arguments of this sequence name from command line and 
* call the body of this sequence.
* Inject error through test plus args
* 1. Program Error detection for uncorrectable/Corr error
* 2. Program Error interrupt with 1. 
* 3. Poll until error information logged and interrupt is asserted.
* 4. Once interrpt generated, scoreboard will check the error count
* 5. If uncorr error is detected dii test will terminate the test once detected.
*/
//-----------------------------------------------------------------------
//-----------------------------------------------------------------------

class dii_csr_enable_err_detection_interrupts_resiliency_seq extends dii_ral_csr_base_seq; 
  `uvm_object_utils(dii_csr_enable_err_detection_interrupts_resiliency_seq)

    uvm_reg_data_t poll_data, read_data, read_data2, write_data;
    bit [7:0]  errthd;
    int        errcount_vld, errthd_vld;
    int        errcount_ovf;
    bit [3:0] errtype;

    function new(string name="");
        super.new(name);
    endfunction

    task body();

       getCsrProbeIf();

           write_data = 1;
           write_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUESAR.ErrVld, write_data);
           write_data = 0;
           write_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUESR.ErrVld, write_data);
           write_data = 1;
           write_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUESR.ErrVld, write_data);

//           errtype = 4'h1;
           errtype = 4'h9;
           // Set the DIIUUEDR ProtErrDetEn = 1,TransErrDetEn =1
           write_data = 1;
           write_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUEDR.ProtErrDetEn, write_data);
           write_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUEDR.TransErrDetEn, write_data);
           // Set the DIIUUEDR ProtErrIntEn = 1,TransErrIntEn =1
           write_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUEIR.ProtErrIntEn, write_data);
           write_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUEIR.TransErrIntEn, write_data);
           // wait for IRQ_UC interrupt 
           //if(u_csr_probe_vif.IRQ_UC == 0)begin // wait only if not already set
<% if (obj.DiiInfo[obj.Id].ResilienceInfo.fnResiliencyProtectionType != "none") { %>
           fork
           begin
             if (u_csr_probe_vif.IRQ_UC == 0) begin
               @(u_csr_probe_vif.IRQ_UC);
               ev_irq_uc.trigger();
             end
           end
           begin
             #200000ns;
             `uvm_error("RUN_MAIN",$sformatf("Timeout! Did not see IRQ_UC asserted"));
           end
           join_any
           disable fork;
<% } %>
    endtask
endclass : dii_csr_enable_err_detection_interrupts_resiliency_seq

//-----------------------------------------------------------------------
//-----------------------------------------------------------------------
/**
 * Abstract:
 * 
 * set up address translation based on number of DII memory regions and
 * number of address translation registers
 * 
 */
//-----------------------------------------------------------------------
//-----------------------------------------------------------------------
//
<% if ((obj.DiiInfo[obj.Id].nAddrTransRegisters > 0) && (obj.testBench != "fsys")) { %>
<% if(obj.testBench == 'dii') { %>
`ifndef VCS
typedef class addr_trans_mgr;
typedef class ncore_memory_map;
`endif
<% } else { %>
typedef class addr_trans_mgr;
typedef class ncore_memory_map;
<% } %>
<% } %>

class dii_csr_addr_trans_seq extends dii_ral_csr_base_seq; 
   `uvm_object_utils(dii_csr_addr_trans_seq)

    uvm_reg_data_t read_data;
    uvm_reg_data_t write_data;

    <% if ((obj.DiiInfo[obj.Id].nAddrTransRegisters > 0) && (obj.testBench != "fsys")) { %>
    addr_trans_mgr      m_addr_mgr;
    addrMgrConst::intq  iocoh_regq;
    <% } %>

    function new(string name="");
        super.new(name);
    endfunction

    task pre_body();
    <% if (obj.testBench == "fsys"|| obj.testBench == "emu" ) { %>
        $cast(m_regs,model);
    <% } %> 
    endtask

    task body();
    <% if ((obj.DiiInfo[obj.Id].nAddrTransRegisters > 0) && (obj.testBench != "fsys")) { %>
       int        nAddrTrans;
       bit [3:0]  transV;
       bit [3:0]  t_mask;
       bit [3:0]  mask[3:0];
       bit [31:0] addrTransV, addrTransFrom, addrTransTo;
       ncore_memory_map m_map;
       bit [addrMgrConst::W_SEC_ADDR -1:0] lower_bound, upper_bound;

       nAddrTrans = <%=obj.DiiInfo[obj.Id].nAddrTransRegisters%>;

       m_addr_mgr = addr_trans_mgr::get_instance();
       m_map      = m_addr_mgr.get_memory_map_instance();

       iocoh_regq = m_map.get_iocoh_mem_regions();

       `uvm_info("AddrTrans", $sformatf("No IOCOH regions=%0d", iocoh_regq.size()), UVM_HIGH)
       for (int i=0; i<iocoh_regq.size(); i++) begin                                                                                 
          m_addr_mgr.get_mem_region_bounds(iocoh_regq[i], lower_bound, upper_bound);
          `uvm_info("AddrTrans", $sformatf("region:%d, lb addr:%p, ub addr:%p", i, lower_bound, upper_bound), UVM_HIGH)
       end

       // has one translation at least
       if (!m_regs) begin
          `uvm_error($sformatf("%m"), $sformatf("m_regs is null"))
       end                                                                                         
       assert(std::randomize(t_mask));
       write_data = ($urandom_range(0,100) < 98);
       transV[0]  = (write_data > 0);
       write_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUATER0.Valid, write_data);
       write_data = t_mask;
       mask[0]    = t_mask;
       write_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUATER0.Mask, write_data);

       // For from address, in may cover only partially the memory region, controlled by mask
       m_addr_mgr.get_mem_region_bounds(iocoh_regq[0], lower_bound, upper_bound);
       write_data = (lower_bound >> 20) & 32'hffff_ffff;
       write_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIURFAR0.FromAddr, write_data);
       write_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIURTAR0.ToAddr, ~write_data);

       <% if (obj.DiiInfo[obj.Id].nAddrTransRegisters > 1) { %>
       if ( iocoh_regq.size() > 1 )begin
          assert(std::randomize(t_mask));
          write_data = ($urandom_range(0,100) < 98);
          write_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUATER1.Valid, write_data);
          transV[1]  = (write_data > 0);
          write_data = t_mask;
          mask[1]    = t_mask;
          write_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUATER1.Mask, write_data);

          // For from address, in may cover only partially the memory region, controlled by mask
          m_addr_mgr.get_mem_region_bounds(iocoh_regq[1], lower_bound, upper_bound);
          write_data = (lower_bound >> 20) & 32'hffff_ffff;
          write_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIURFAR1.FromAddr, write_data);
          write_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIURTAR1.ToAddr, ~write_data);
       end                                                       
       <% } %>

       <% if (obj.DiiInfo[obj.Id].nAddrTransRegisters > 2) { %>
       if ( iocoh_regq.size() > 2 )begin
          assert(std::randomize(t_mask));
          write_data = ($urandom_range(0,100) < 98);
          transV[2]  = (write_data > 0);
          write_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUATER2.Valid, write_data);
          write_data = t_mask;
          mask[2]    = t_mask;
          write_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUATER2.Mask, write_data);

          // For from address, in may cover only partially the memory region, controlled by mask
          m_addr_mgr.get_mem_region_bounds(iocoh_regq[2], lower_bound, upper_bound);
          write_data = (lower_bound >> 20) & 32'hffff_ffff;
          write_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIURFAR2.FromAddr, write_data);
          write_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIURTAR2.ToAddr, ~write_data);
       end                                                       
       <% } %>

       <% if (obj.DiiInfo[obj.Id].nAddrTransRegisters > 3) { %>
       if ( iocoh_regq.size() > 3 )begin
          assert(std::randomize(t_mask));
          write_data = ($urandom_range(0,100) < 98);
          transV[3]  = (write_data > 0);
          write_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUATER3.Valid, write_data);
          write_data = t_mask;
          mask[3]    = t_mask;
          write_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUATER3.Mask, write_data);

          // For from address, in may cover only partially the memory region, controlled by mask
          m_addr_mgr.get_mem_region_bounds(iocoh_regq[3], lower_bound, upper_bound);
          write_data = (lower_bound >> 20) & 32'hffff_ffff;
          write_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIURFAR3.FromAddr, write_data);
          write_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIURTAR3.ToAddr, ~write_data);
       end                                                    
       <% } %>

       // check the settings
       for ( int i=0; i<nAddrTrans; i++ ) begin
           if (i == 0) begin
              read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUATER0.Valid, read_data);
              addrTransV = read_data << 31;
              read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUATER0.Mask, read_data);
              addrTransV |= read_data;
              read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIURFAR0.FromAddr, addrTransFrom);
              read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIURTAR0.ToAddr, addrTransTo);

              dii_scoreboard::addrTransV[0]    = addrTransV;
              dii_scoreboard::addrTransFrom[0] = addrTransFrom;
              dii_scoreboard::addrTransTo[0]   = addrTransTo;
           end
           <% if (obj.DiiInfo[obj.Id].nAddrTransRegisters > 1) { %>
           if (i == 1) begin
              read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUATER1.Valid, read_data);
              addrTransV = read_data << 31;
              read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUATER1.Mask, read_data);
              addrTransV |= read_data;
              read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIURFAR1.FromAddr, addrTransFrom);
              read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIURTAR1.ToAddr, addrTransTo);

              dii_scoreboard::addrTransV[1]    = addrTransV;
              dii_scoreboard::addrTransFrom[1] = addrTransFrom;
              dii_scoreboard::addrTransTo[1]   = addrTransTo;
           end
           <% } %>
           <% if (obj.DiiInfo[obj.Id].nAddrTransRegisters > 2) { %>                                                                                                   
           if (i == 2) begin
              read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUATER2.Valid, read_data);
              addrTransV  = read_data << 31;
              read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUATER2.Mask, read_data);
              addrTransV |= read_data;
              read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIURFAR2.FromAddr, addrTransFrom);
              read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIURTAR2.ToAddr, addrTransTo);

              dii_scoreboard::addrTransV[2]    = addrTransV;
              dii_scoreboard::addrTransFrom[2] = addrTransFrom;
              dii_scoreboard::addrTransTo[2]   = addrTransTo;
           end
           <% } %>
           <% if (obj.DiiInfo[obj.Id].nAddrTransRegisters > 2) { %>                                                                                                   
           if (i == 3) begin
              read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUATER3.Valid, read_data);
              addrTransV = read_data << 31;
              read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUATER3.Mask, read_data);
              addrTransV |= read_data;
              read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIURFAR3.FromAddr, addrTransFrom);
              read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIURTAR3.ToAddr, addrTransTo);

              dii_scoreboard::addrTransV[3]    = addrTransV;
              dii_scoreboard::addrTransFrom[3] = addrTransFrom;
              dii_scoreboard::addrTransTo[3]   = addrTransTo;
           end
           <% } %>
           if ( i < iocoh_regq.size() )  begin
              m_addr_mgr.get_mem_region_bounds(iocoh_regq[i], lower_bound, upper_bound);
              if (addrTransV != ((transV[i]<<31) | mask[i])) begin
                 `uvm_error($sformatf("%m"), $sformatf("DIIUATER%0d not match wrote=%0h read=%0h", i, (transV[i]<<31)|mask[i], addrTransV))
              end
              if (addrTransFrom != ((lower_bound >> 20) & 32'hffff_ffff)) begin
                 `uvm_error($sformatf("%m"), $sformatf("DIIURFARAx not match wrote=%0h read=%0h", (lower_bound >> 20) & 32'hffff_ffff, addrTransFrom))
              end
              if (addrTransTo != ((~(lower_bound >> 20)) & 32'hffff_ffff)) begin
                 `uvm_error($sformatf("%m"), $sformatf("DIIURTARAx not match wrote=%0h read=%0h", (~(lower_bound >> 20)) & 32'hffff_ffff, addrTransTo))
              end
           end else begin
              if ((addrTransV > 31) == 1) begin
                 `uvm_error($sformatf("%m"), $sformatf("DIUATERx Valid is set for i=%0d", i))
              end
           end
       end
    <% } %>
    endtask
endclass : dii_csr_addr_trans_seq

class res_corr_err_threshold_seq extends dii_ral_csr_base_seq; 
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
      `uvm_info(get_name(), $sformatf("Writing DIIUCRTR res_corr_err_threshold = %0d", write_data), UVM_NONE)
      write_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUCRTR.ResThreshold, write_data);
      <% } %>
    endtask
endclass : res_corr_err_threshold_seq

class dii_csr_cctrlr_seq extends dii_ral_csr_base_seq;
   `uvm_object_utils(dii_csr_cctrlr_seq)

    uvm_reg_data_t write_data, read_data;
    uvm_status_e   status;

    function new(string name="");
        super.new(name);
    endfunction

    task pre_body();
    <% if (obj.testBench == "fsys" ) { %>
        $cast(m_regs,model);
    <% } %> 
    endtask

    task body();

       bit [31:0] set_value  = 0;
       bit [7:0]  smi_cap    = 0;
       bit [3:0]  gain       = 0;
       bit [11:0] inc        = 0;
       
       if ($test$plusargs("cctrlr_random")) begin
           std::randomize(smi_cap);
           std::randomize(gain);
           std::randomize(inc);
           `uvm_info($sformatf("%m"), $sformatf("<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%> Set CCRTRLR to random values. SMI_CAPT=%0h, GAIN=%0d, INCR=%0d", smi_cap, gain, inc), UVM_NONE)
       end else if ($value$plusargs("cctrlr_value=0x%0h", set_value)) begin
           smi_cap      = set_value[7:0];
           gain         = set_value[19:16];
           inc          = set_value[31:20];
           `uvm_info($sformatf("%m"), $sformatf("<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%> Set CCRTRLR through cmdln=%0h. SMI_CAPT=%0h, GAIN=%0d, INCR=%0d", set_value, smi_cap, gain, inc), UVM_NONE)
       end else if ($test$plusargs("cctrlr_weighted_random")) begin : weighted_random
           if ($value$plusargs("cctrlr_enables=0x%0h", smi_cap)) begin
               // user-specified smi_cap
           end else begin : cctrlr_enables_weighted_random
               case ($urandom_range(100,1)) inside
                   ['d01:'d10]: smi_cap = 'hff; // all on DMI
                   ['d11:'d20]: smi_cap = 'hcf; // all on DII
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
           
           if ($test$plusargs("cctrlr_inc_weighted_random_low")) begin : cctrlr_inc_weighted_random_low
            
            std::randomize(inc) with  { inc inside { 1,2,4,8} ;}  ;

           end : cctrlr_inc_weighted_random_low

           `uvm_info($sformatf("%m"), $sformatf("<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%> Set CCRTRLR to weighted random values. SMI_CAPT=%0h, GAIN=%0d, INCR=%0d", smi_cap, gain, inc), UVM_NONE)
       end : weighted_random

      

       write_data = (smi_cap >> 0) & 1;
       write_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIICCTRLR.ndn0Tx, write_data);
       write_data = (smi_cap >> 1) & 1;
       write_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIICCTRLR.ndn0Rx, write_data);
       write_data = (smi_cap >> 2) & 1;
       write_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIICCTRLR.ndn1Tx, write_data);
       write_data = (smi_cap >> 3) & 1;
       write_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIICCTRLR.ndn1Rx, write_data);
       write_data = (smi_cap >> 4) & 1;
       write_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIICCTRLR.ndn2Tx, write_data);
       write_data = (smi_cap >> 5) & 1;
       write_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIICCTRLR.ndn2Rx, write_data);
       write_data = (smi_cap >> 6) & 1;
       write_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIICCTRLR.dn0Tx , write_data);
       write_data = (smi_cap >> 7) & 1;
       write_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIICCTRLR.dn0Rx , write_data);
       write_data = gain;
       write_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIICCTRLR.gain  , write_data);
       write_data = inc;
       write_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIICCTRLR.inc   , write_data);

       dii_scoreboard::smi_capture_en = smi_cap;
       dii_scoreboard::gain_value     = gain;
       dii_scoreboard::inc_value      = inc;

       trace_debug_scb::port_capture_en  = smi_cap;
       trace_debug_scb::gain             = gain;
       trace_debug_scb::inc              = inc;
       
    endtask : body
endclass : dii_csr_cctrlr_seq

class dii_csr_sys_event_seq extends dii_ral_csr_base_seq; 
   `uvm_object_utils(dii_csr_sys_event_seq)
    uvm_reg_data_t write_data;
    uvm_reg_data_t poll_data;
    uvm_reg_data_t read_data;
    uvm_reg_data_t timeout_threshold, timeout_errdeten, timeout_errinten;
    rand int ev_disable_clock_cycles;  // introduce this delay while enabling and disabling events

    bit sys_event_disable = 0;
    bit [3:0]  errtype;
    bit [19:0]  errinfo = 0;
    bit errvalid = 0;
    int sys_ev_prot_timeout_val;
    int has_sys_event;
    bit sys_event_irq_uc;
    
    
    constraint c_ev_disable_clock_cycles{
      ev_disable_clock_cycles inside {[1:5000]};
    }

    function new(string name="");
        super.new(name);
    endfunction

    task body();

        getCsrProbeIf();
        get_scb_handle();
        if($test$plusargs("sys_event_disable")) begin
            sys_event_disable = 1;
        end
        
        `uvm_info("DII_CSR_EV_MSG_SEQ", $psprintf("Start Sys event configuration sequence"), UVM_LOW)
        //#Stimulus.DII.EventMsg.DisableEvent
        write_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUTCR.EventDisable, sys_event_disable); // Disable events
                    `uvm_info($sformatf("%m"),$sformatf("sys_event_disable = %0d at %0t", sys_event_disable, $realtime),UVM_LOW)
      //#Stimulus.DII.EventMsgTimeoutErr
       if($test$plusargs("dii_sys_event_ev_timeout")) begin
        timeout_errdeten = 1;
          write_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUEDR.TimeoutErrDetEn, timeout_errdeten); 
        if (! $value$plusargs("k_ev_prot_timeout_val=%d",  sys_ev_prot_timeout_val) ) begin
          sys_ev_prot_timeout_val = 1;
         end
	        timeout_threshold = uvm_reg_data_t'(sys_ev_prot_timeout_val);
       end else begin

        timeout_threshold = $urandom_range(5,8); //Timeout Threshold - increments in the multiples of 4K so only randomizing few values to save time

      end 
        
    
        write_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUSEPTOCR.TimeOutThreshold, timeout_threshold);

        `uvm_info("DII_CSR_EV_MSG_SEQ", $psprintf("Programmed DII control registers with timeout_threshold : %0d", timeout_threshold), UVM_DEBUG)

      
          
          if($test$plusargs("dii_sys_event_ev_timeout") && (timeout_errdeten == 1)) begin
            
            fork
             begin
                 ev_sys_event_req.wait_ptrigger();
                 has_sys_event = 1;
             end
             begin
               #100000ns;
               has_sys_event = 0;
              `uvm_info("DII_CSR_EV_MSG_SEQ", $psprintf("No sys_event trigged"), UVM_LOW)
             end
            join_any
            disable fork;
            
            // Make sure that a sys_event is trigged before start the check of timeout feature
            if (has_sys_event) begin
                  fork
                   begin
                    wait (u_csr_probe_vif.IRQ_UC === 1);
                     `uvm_info("DII_CSR_EV_MSG_SEQ", $psprintf("IRQ_IC is correctly trigged"), UVM_LOW)
                     sys_event_irq_uc = u_csr_probe_vif.IRQ_UC;
                   end
                   begin
                     #200000ns;
                      `uvm_error("RUN_MAIN",$sformatf("Timeout! Did not see IRQ_UC asserted"));
                   end
                  join_any
                  disable fork;
                    //#Check.DII.EventMsg.SysRespTimeOut
                    ev_sys_event_err.wait_ptrigger();
                    #1us;
                    `uvm_info("DII_CSR_EV_MSG_SEQ", $psprintf("Start Checking Sys event Csr Registers"), UVM_LOW)

                    read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUESR.ErrType, read_data);
                    compareValues("DIIUUESR.ErrType","should be",read_data,4'hA);
                    errtype = read_data;

                    read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUESR.ErrInfo, read_data);
                    compareValues("DIIUUESR.ErrInfo","should be",read_data,errinfo);

                    read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUESR.ErrVld, read_data);
                    compareValues("DIIUUESR_ErrVld","should be",read_data,1);
                    errvalid = read_data;

                    read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUEDR.TimeoutErrDetEn, read_data); 
                    timeout_errdeten = read_data;
      
                    `uvm_info("DII_CSR_EV_MSG_SEQ", $psprintf("End Checking Sys event Csr Registers"), UVM_LOW)
              end
          end
          <% if (obj.DiiInfo[obj.Id].nExclusiveEntries  > 0) { %>
          dii_sb.cov.collect_sys_event_csr(timeout_errdeten,sys_event_disable,errtype,sys_event_irq_uc);
          <% } %>
     `uvm_info("DII_CSR_EV_MSG_SEQ", $psprintf("End Sys event configuration sequence"), UVM_LOW)
    endtask
endclass : dii_csr_sys_event_seq

//----------------------------------------------------------------------
/**
* Abstract:
* 
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

class dii_csr_diiueir_MemErrInt_skidbuf_seq extends dii_ral_csr_base_seq; 
  `uvm_object_utils(dii_csr_diiueir_MemErrInt_skidbuf_seq)

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
        get_scb_handle();
        kill_test_1 = new("kill_test_1");
        uvm_config_db#(uvm_event)::set(get_sequencer(), "", "kill_test_1", kill_test_1); 
        dii_sb.set_kill_test_event(kill_test_1); 
    endfunction

    task body();

    <% if(obj.DiiInfo[obj.Id].CMDOverflowBufInSRAM == true) { %>

       getCsrProbeIf();

       if (has_ucerr_enabled) begin // uncorr (int enabled and error det enabled)

           errtype = 4'h0; //sram err type

           //Set the DIIUUEDR_MemErrDetEn = 1  
           write_data = 1;
           write_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUEDR.MemErrDetEn, write_data); 
           error_det = write_data;

           if(u_csr_probe_vif.buffer_sel_probe == 0) errinfo = 4'h5; //sram info type
           else errinfo = 4'h6;
    
           if($test$plusargs("interrupt_en")) begin   

             `uvm_info("SKIDBUFERROR","Vyshak in int 1",UVM_HIGH)
             // Set the DIIUUEIR_MemErrIntEn = 1
             write_data = 1;
             write_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUEIR.MemErrIntEn, write_data);
             error_int = write_data;
        
             fork
             begin
               if (u_csr_probe_vif.IRQ_UC == 0) begin

                 `uvm_info("SKIDBUFERROR","Waiting for interrupt to be asserted",UVM_HIGH)
                 if($test$plusargs("skid_mission_fault")) @(u_csr_probe_vif.fault_mission_fault); //#Check.DII.Concerto.v3.7.MissionFault
                 else @(u_csr_probe_vif.IRQ_UC);
            
                 if($test$plusargs("skid_mission_fault")) fault_mission_fault_asserted =1;
                 else irq_uc_asserted =1;

                 `uvm_info("Vyshak",$sformatf("Interrupt has been asserted and fault_mission_fault_asserted is %0b ",fault_mission_fault_asserted),UVM_HIGH)
               end
             end
             
             begin
               //$display("Vyshak in 2975 and irq_uc_asserted is %0b",irq_uc_asserted);
               #200000ns;
               `uvm_info("Vyshak","Vyshak in 2977",UVM_MEDIUM);
               if (!irq_uc_asserted) begin
                  `uvm_error("RUN_MAIN", "Timeout! Did not see IRQ_UC asserted");
               end
              <% if (obj.DiiInfo[obj.Id].useResiliency ) { %>
               if ($test$plusargs("skid_mission_fault") && !fault_mission_fault_asserted) begin
                 `uvm_error("RUN_MAIN", "Timeout! Did not see mission fault asserted");
               end
             <% } %>
              `uvm_info("Vyshak","Vyshak finishing thread 3",UVM_MEDIUM);
             end
             join_any

             disable fork;
           end

           if($test$plusargs("detection_en")) begin
           
             `uvm_info("SKIDBUFERROR","Vyshak in det 1",UVM_HIGH)
    
              //keep on  Reading the DIIUUESR_ErrVld bit = 1
              poll_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUESR.ErrVld,1,poll_data);
              
              //Read and compare DIIUUESR.ErrInfo value
              read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUESR.ErrInfo, read_data);
              sram_enabled = read_data;
              compareValues("DIIUUESR_ErrInfo","Valid Type", read_data, errinfo);
             
              //Read and compare DIIUUESR.ErrType value
              read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUESR.ErrType, read_data);
              compareValues("DIIUUESR_ErrType","Valid Type", read_data, errtype);

            if(!$test$plusargs("interrupt_en")) begin
                assert (u_csr_probe_vif.IRQ_UC == 0) else begin // interrupt should not be asserted if DIIUUEIR is not set
                `uvm_error("RUN_MAIN",$sformatf("IRQ_UC should not be asserted if DIIUUEIR is not enabled"));
              end 
            end

              write_data = 0; 
              write_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUEDR.MemErrDetEn, write_data);
        
              // write DIIUUESR_ErrVld = 1 to clear it
              write_data = 1;
              write_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUESR.ErrVld, write_data);
            
              //Read DIIUUESR_ErrVld , it should be 0
              read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUESR.ErrVld, read_data);
              compareValues("DIIUUESR_ErrVld", "reset", read_data, 0); 
            
               //Read DIIUUESAR_ErrVld , it should be 0
              read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUESAR.ErrVld, read_data);
              compareValues("DIIUUESAR_ErrVld", "reset", read_data, 0);
            
            end
             
           if($test$plusargs("interrupt_en")) begin
              
              `uvm_info("SKIDBUFERROR","Vyshak in int 2",UVM_HIGH);

              write_data = 0;
              write_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUEIR.MemErrIntEn, write_data);

              //Monitor IRQ_C pin , it should be 0 now
              assert (u_csr_probe_vif.IRQ_UC == 0) else begin
                `uvm_error("RUN_MAIN",$sformatf("IRQ_UC interruped still aseerted"));
              end 
           end
 
        
          <% if (obj.DiiInfo[obj.Id].CMDOverflowBufInSRAM == true) { %> //collecting coverage
               dii_sb.cov.collect_skidbuff_err_csr(0, error_det, error_int, sram_enabled);                          
          <% } %>

          `uvm_info("SKIDBUFERROR","Going to trigger kill_test_1 from ral",UVM_HIGH);

           kill_test_1.trigger(); //trigger to kill test (checked in dii_test) after uncorr err checks
          

       end else begin

           // Monitor IRQ_UC pin , it should be 0 now
           if(u_csr_probe_vif.IRQ_UC == 0)begin
             `uvm_info("RUN_MAIN",$sformatf("IRQ_UC interrupted de-asserted"), UVM_MEDIUM)
           end else begin
             `uvm_error("RUN_MAIN",$sformatf("IRQ_UC interruped asserted"));
           end
          // Read DIIUUESR_ErrVld , it should be 0
           read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUESR.ErrVld, read_data);
           compareValues("DIIUUESR_ErrVld", "set", read_data, 0);
           read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUESAR.ErrVld, read_data);
           compareValues("DIIUUESAR_ErrVld", "set", read_data, 0);
           read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUESR.ErrType, read_data);
           compareValues("DIIUUESR_ErrType","Valid Type", read_data, 4'h0);
          // Read DIIUUESAR_ErrVld , it should be 0
           read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUESAR.ErrVld, read_data);
           compareValues("DIIUUESAR_ErrVld", "set", read_data, 0);
           read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUUESAR.ErrType, read_data);
           compareValues("DIIUUESAR_ErrType","Valid Type", read_data, 4'h0);
          // Monitor IRQ_C pin , it should be 0 now
          if(u_csr_probe_vif.IRQ_UC == 0)begin
             `uvm_info("RUN_MAIN",$sformatf("IRQ_UC interrupted de-asseretd"), UVM_MEDIUM)
          end else begin
             `uvm_error("RUN_MAIN",$sformatf("IRQ_UC interruped still aseerted"));
          end

       end
    <% } %>

    endtask
endclass : dii_csr_diiueir_MemErrInt_skidbuf_seq


//-----------------------------------------------------------------------
//-----------------------------------------------------------------------
/**
* Abstract:
* 
* In this test we will check if correctable errors are corrected (ErrThreshold filed CECR register) which should be count by Error counter. 
* Errthreshold value is programmed from dii_test.
* Test will get arguments of this sequence name from command line and 
* call the body of this sequence.
* 1. If dii contains SECDED, Write Error threshold with random value (DUT must assert Interrupt once threshold value errors are corrected).
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

class dii_csr_diicecr_errThd_skidbuf_seq extends dii_ral_csr_base_seq; 
  `uvm_object_utils(dii_csr_diicecr_errThd_skidbuf_seq)

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

       <% if (obj.DiiInfo[obj.Id].CMDOverflowBufInSRAM == true) { %>
          
          getCsrProbeIf();
          get_scb_handle();
          errtype = 4'h0;
          error_det = 0; //defaulted to be 0 at the start
          error_int = 0; //defaulted to be 0 at the start

          // Set the DIIUCECR_ErrThreshold 
          if(!uvm_config_db#(bit [7:0])::get(get_sequencer(),"","errthd",errthd)) begin
            `uvm_error("Vyshak","Failed to get errthd from config db");
          end
            `uvm_info("SKIDBUFERROR", $sformatf("Vyshak and errthd value is: %0d", errthd), UVM_HIGH);

          //Write the DIIUCECR.ErrThreshold value
          write_data = errthd;
          write_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUCECR.ErrThreshold, write_data);
          
          //Enable DIIUCECR.ErrDetEn bit
          write_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUCECR.ErrDetEn, 1);
          error_det = 1;
          

          if($test$plusargs("interrupt_en"))begin

            `uvm_info("SKIDBUFERROR","Vyshak in interrupt_en 1 of corr",UVM_HIGH);

            // Set the DIIUCECR_ErrIntEn = 1
            write_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUCECR.ErrIntEn, 1);
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

            `uvm_info("SKIDBUFERROR","Vyshak in detection_en 1 of corr",UVM_HIGH);

            //Keep on reading the DIIUCESR_ErrVld bit = 1 
            poll_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUCESR.ErrVld,1,poll_data);

            //Keep on reading the DIIUCESR_ErrCountOverflow = 1 and then compare
            poll_data = 0;
            poll_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUCESR.ErrCountOverflow,1,poll_data);
            read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUCESR.ErrCountOverflow, read_data);
            compareValues("DIIUCESR_ErrCountOverflow","Should be 1", read_data, 1);


            poll_data = 0;
            `uvm_info("Vyshak","Vyshak and polling for errcnt in 3089",UVM_MEDIUM);
            // Read DIIUCESR_ErrCount , it should be at errthd. If not then poll for it.
            read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUCESR.ErrCount, read_data);
            `uvm_info("SKIDBUFERROR",$sformatf("Read_data of Errcount after reading initially is %0d",read_data),UVM_HIGH);

            if(read_data != errthd) begin
              //Keep on reading the DIIUCESR_ErrCount value until it matches errthd.
              poll_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUCESR.ErrCount,1,poll_data);
              if(poll_data < errthd) begin
                `uvm_error("RUN_MAIN",$sformatf("ErrCount %0d should be same as ErrThreshold %0d",poll_data,errthd))
              end
            end         
            
            `uvm_info("SKIDBUFERROR","Vyshak in detection_en 1 of corr and now resetting values and checking",UVM_HIGH);
            write_data = 0;
            write_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUCECR.ErrDetEn, write_data);
            //Write DIIUCESR_ErrVld = 1 , to reset it
            write_data = 1;
            write_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUCESR.ErrVld, write_data);
            //Read DIIUCESR_ErrVld , it should be 0
            read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUCESR.ErrVld, read_data);
            compareValues("DIIUCESR_ErrVld", "now clear", read_data, 0);
            //Read DIIUCESAR_ErrVld , it should be 0
            read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUCESAR.ErrVld, read_data);
            compareValues("DIIUCESAR_ErrVld", "now clear", read_data, 0);
            //Read DIIUCESR_ErrCount , it should be 0
            read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUCESR.ErrCount, read_data);
            compareValues("DIIUCESR_ErrCount", "now clear", read_data, 0);
            //Read DIIUCESAR_ErrCount , it should be 0
            read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUCESAR.ErrCount, read_data);
            compareValues("DIIUCESAR_ErrCount", "now clear", read_data, 0);
            //Read DIIUCESR_ErrCountOverflow , it should be 0
            read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUCESR.ErrCountOverflow, read_data);
            compareValues("DIIUCESR_ErrCountOverflow","Should be 0", read_data, 0);
            //Read DIIUCESAR_ErrCountOverflow , it should be 0
            read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUCESAR.ErrCountOverflow, read_data);
            compareValues("DIIUCESAR_ErrCountOverflow","Should be 0", read_data, 0);
          end


          if(u_csr_probe_vif.buffer_sel_probe == 0) errinfo = 4'h5; //sram info
          else errinfo = 4'h6;

          `uvm_info("SKIDBUFERROR", $sformatf("In RAL_SEQ and u_csr_probe_vif.buffer_sel_probe value is: %0d", u_csr_probe_vif.buffer_sel_probe), UVM_HIGH);
          `uvm_info("SKIDBUFERROR", $sformatf("In RAL_SEQ and errinfo value is: %0d", errinfo), UVM_HIGH);
         
          //Read and compare DIIUCESR.ErrType
          read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUCESR.ErrType, read_data);
          compareValues("DIIUCESR_ErrType","Valid Type", read_data, errtype);

          //Read and compare DIIUCESR.ErrInfo
          read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUCESR.ErrInfo, read_data); 
          sram_enabled = read_data;
          compareValues("DIIUCESR_ErrInfo","Valid Type", read_data, errinfo);
          
             


          if($test$plusargs("interrupt_en"))begin
            
            //Reset interrupt by writing 1 to DIIUCECR.ErrIntEn
            write_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUCECR.ErrIntEn, 1); 

            `uvm_info("SKIDBUFERROR","Vyshak in interrupt_en 2 of corr and restting interrupt values",UVM_HIGH);
            // Monitor IRQ_C pin , it should be 0 now
            if(u_csr_probe_vif.IRQ_C == 0)begin
              `uvm_info("SKIDBUFERROR",$sformatf("IRQ_C interrupted de-asseretd for corr errors"), UVM_HIGH)
            end else begin
              `uvm_error("RUN_MAIN",$sformatf("IRQ_C interruped still aseerted"));
            end
          end


         <% if (obj.DiiInfo[obj.Id].CMDOverflowBufInSRAM == true) { %> //collecting coverage
          dii_sb.cov.collect_skidbuff_err_csr(1, error_det, error_int, sram_enabled);
         <% } %>
      <% } %>

    endtask
endclass : dii_csr_diicecr_errThd_skidbuf_seq


//-----------------------------------------------------------------------
//-----------------------------------------------------------------------
/**
* Abstract:
* 
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

class dii_csr_diicecr_noDetEn_skidbuf_seq extends dii_ral_csr_base_seq; 
  `uvm_object_utils(dii_csr_diicecr_noDetEn_skidbuf_seq)

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
          
   <% if (obj.DiiInfo[obj.Id].CMDOverflowBufInSRAM == true) { %>

      get_scb_handle();

      //Don't Set the DIIUCECR_ErrDetEn = 1
      //Reading and comparing the the DIIUCESR_ErrVld bit to be 0
      read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUCESR.ErrVld, read_data);
      compareValues("DIIUCESR_ErrVld", "not set", read_data, 0);

      //Read DIIUCESR_ErrCount , it should be at 0
      read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUCESR.ErrCount, read_data);
      compareValues("DIIUCESR_ErrCount","not set", read_data, 0);

      //Read DIIUCESAR_ErrVld , it should also clear, beacuse it is alias register
      read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUCESAR.ErrVld, read_data);
      compareValues("DIIUCESAR_ErrVld", "not set", read_data, 0);

      read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUCECR.ErrDetEn, read_data);
      error_det = read_data; //for coverage
      read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUCECR.ErrIntEn, read_data);
      error_int = read_data; //for coverage
        
      <% if (obj.DiiInfo[obj.Id].CMDOverflowBufInSRAM == true) { %> //collecting coverage
      sram_enabled = 4'h5;
      dii_sb.cov.collect_skidbuff_err_csr(1, error_det, error_int, sram_enabled);
      <% } %>

   <% } %>

    endtask
endclass : dii_csr_diicecr_noDetEn_skidbuf_seq

//-----------------------------------------------------------------------
//-----------------------------------------------------------------------
/**
* Abstract:
* 
* This seq is called for all the engineering debug registers tests that check all the bits from bit 0 to bit 5. 
* Test will get arguments of this sequence name from command line and 
* call the body of this sequence.
* 1. Enable required bits of the DIIUENGDBR register.
* 2. Read the value of that bit and it should be 1.
* 3. Check the functionality of enabling the bit in the scoreboard.
*/
//-----------------------------------------------------------------------
//-----------------------------------------------------------------------
//


class dii_csr_diiengdbr_seq extends dii_ral_csr_base_seq; 
  `uvm_object_utils(dii_csr_diiengdbr_seq)

    uvm_reg_data_t read_data, write_data;

    function new(string name="");
        super.new(name);
    endfunction

    task body();
     getCsrProbeIf();
     get_scb_handle();

            write_data = 1;

            if($test$plusargs("engdbgreg_test_forcearids")) begin
                 write_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUENGDBR.ForceArIdZeros, write_data);
                 read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUENGDBR.ForceArIdZeros, read_data);
                 compareValues("DIIUENGDBR_ForceArIdZeros", "set", read_data, 1);
                 dii_sb.force_arid_scb = 1;
            end
            else if ($test$plusargs("engdbgreg_test_forceawids"))begin
              write_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUENGDBR.ForceAwIdZeros, write_data);
              read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUENGDBR.ForceAwIdZeros, read_data);
              compareValues("DIIUENGDBR_ForceAwIdZeros", "set", read_data, 1);
              dii_sb.force_awid_scb = 1;
            end 
            else if ($test$plusargs("engdbgreg_test_force_ro_late_rsp"))begin
              write_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUENGDBR.ForceROLateWriteResponse, write_data);
              read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUENGDBR.ForceROLateWriteResponse, read_data);
              compareValues("DIIUENGDBR_ForceROLateWriteResponse", "set", read_data, 1);
              dii_sb.force_ro_late_rsp = 1;
            end 
            else if ($test$plusargs("engdbgreg_test_force_eo_late_rsp"))begin
              write_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUENGDBR.ForceEOLateWriteResponse, write_data);
              read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUENGDBR.ForceEOLateWriteResponse, read_data);
              compareValues("DIIUENGDBR_ForceEOLateWriteResponse", "set", read_data, 1);
              dii_sb.force_eo_late_rsp = 1;
            end 
            else if ($test$plusargs("engdbgreg_test_excl_src_from_ord"))begin
              write_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUENGDBR.ExcludeInitiatorFromOrdering, write_data);
              read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUENGDBR.ExcludeInitiatorFromOrdering, read_data);
              compareValues("DIIUENGDBR_ExcludeInitiatorFromOrdering", "set", read_data, 1);
              dii_sb.enforce_same_agent_scb = 0;
            end 
             else if ($test$plusargs("engdbgreg_test_excl_ro_wr_from_wo_wr"))begin
              write_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUENGDBR.ExcludeROWriteFromWO, write_data);
              read_csr(m_regs.<%=obj.DiiInfo[obj.Id].strRtlNamePrefix%>.DIIUENGDBR.ExcludeROWriteFromWO, read_data);
              compareValues("DIIUENGDBR_ExcludeROWriteFromWO", "set", read_data, 1);
            end 

    endtask
endclass : dii_csr_diiengdbr_seq



