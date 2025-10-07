///////////////////////////////////////////////////////////////////////////////
//                                                                           //
// File         :   dve_ral_csr_seq.sv                                       //
// Author       :   Eric Weisman 2018                                        //
// Description  :   exercise CSR via APB                                     //
//                                                                           //
// Revision     :                                                            //
//                                                                           //
///////////////////////////////////////////////////////////////////////////////


//en/disable correctable, uncorrectable errors
//TODO FIXME conditioned vars DNE in dve json, esp. cmc

<% let has_secded = true;
%>


<% 
const Dvm_NUnitIds = [] ;

for (const elem of obj.AiuInfo) {
    if(elem.cmpInfo.nDvmSnpInFlight >0) {
        Dvm_NUnitIds.push(elem.nUnitId);   //dve requires corresponding vector of NUnitIds of which aius are dvm capable, ordered by NUnitId
    }
}

let SnpsEnb = 0;
let SnpsEnb1 = 0;
let SnpsEnb2 = 0;
let SnpsEnb3 = 0;
for(let i in Dvm_NUnitIds) {
   if(Dvm_NUnitIds[i] > 95) { SnpsEnb3 |= 1 << (Dvm_NUnitIds[i]-96); }
   else if(Dvm_NUnitIds[i] > 63) { SnpsEnb2 |= 1 << (Dvm_NUnitIds[i]-64); }
   else if(Dvm_NUnitIds[i] > 31) { SnpsEnb1 |= 1 << (Dvm_NUnitIds[i]-32); }
   else {  SnpsEnb |= 1 << Dvm_NUnitIds[i]; }
}

const dvm_agent = Dvm_NUnitIds.length  
%>

//-----------------------------------------------------------------------
//   base method for dve 
//-----------------------------------------------------------------------
class dve_ral_csr_base_seq extends ral_csr_base_seq;

    virtual dve_csr_probe_if u_csr_probe_vif;
    virtual <%=obj.BlockId%>_apb_if  apb_vif;

    function new(string name="");
        super.new(name);
    endfunction

    function void getCsrProbeIf();
        if(!uvm_config_db#(virtual dve_csr_probe_if )::get(null, get_full_name(), "u_csr_probe_if",u_csr_probe_vif))
            `uvm_error("NOVIF",{"virtual interface must be set  for :",get_full_name(),".vif"})
    endfunction // checkCsrProbeIf

    task poll_DVEUUESR_ErrVld(bit [31:0] poll_till, output uvm_reg_data_t fieldVal);
        poll_csr(m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVEUUESR.ErrVld,poll_till,fieldVal);
    endtask

    function bit [`UVM_REG_ADDR_WIDTH-1 : 0] get_unmapped_csr_addr();
      bit [`UVM_REG_ADDR_WIDTH-1 : 0] all_csr_addr[$];
      typedef struct packed {
                             bit [`UVM_REG_ADDR_WIDTH-1 : 0] lower_addr;
                             bit [`UVM_REG_ADDR_WIDTH-1 : 0] upper_addr;
                            } csr_addr;
      csr_addr csr_unmapped_addr_range[$];
      int randomly_selected_unmapped_csr_sddr;
      
      <% obj.DveInfo[obj.Id].csr.spaceBlock[0].registers.forEach(function GetAllregAddr(item,i){ %>
                                  //all_csr_addr.push_back({12'h<%=obj.DveInfo[obj.Id].nrri%>,8'h<%=obj.DveInfo[obj.Id].rpn%>,12'h<%=item.addressOffset%>});
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
                                          .field_name("m_apb_if"),
                                          .value(apb_vif)))
        `uvm_error(get_name,"Failed to get apb if")
    endfunction

endclass : dve_ral_csr_base_seq

class access_unmapped_csr_addr extends dve_ral_csr_base_seq;
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
    start_item(apb_pkt);
    apb_pkt.paddr = unmapped_csr_addr;
    apb_pkt.unmap_addr = unmapped_csr_addr;
    apb_pkt.pwrite = 1;
    apb_pkt.psel = 1;
    apb_pkt.pwdata = $urandom;
    finish_item(apb_pkt);
  endtask
endclass : access_unmapped_csr_addr

//-----------------------------------------------------------------------
//-----------------------------------------------------------------------
//  Task    : dve_csr_init_seq
//  Purpose : DVE CSR init at startup
//
//-----------------------------------------------------------------------
class dve_csr_init_seq extends dve_ral_csr_base_seq; 
   `uvm_object_utils(dve_csr_init_seq)

    uvm_reg_data_t write_data, read_data;
    dve_coverage_reg cov;
    int SnpsEn[4];
    function new(string name="");
        super.new(name);
        cov = new();
    endfunction

    task body();
       // program SnpsEnb if SysCo connect is disabled
       if(!$test$plusargs("sysco_enable")) begin
       <% for(let i in Dvm_NUnitIds) { %>
       $display("Dvm_NUnitIds[<%=i%>] = <%=Dvm_NUnitIds[i]%>");
       <% } %>
        // read these ID csrs for code-coverage
        read_csr(m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVEUIDR.Valid, read_data);
        read_csr(m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVEUFUIDR.FUnitId, read_data);
        read_csr(m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVEUINFOR.Valid, read_data);
	  
        write_data[31:0] = <%=SnpsEnb%>;
        write_csr(m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVEUSER0.SnpsEnb, write_data);
        read_csr(m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVEUSER0.SnpsEnb, read_data);
       $display("SnoopEnb = 0x%0h", read_data);
       SnpsEn[0] = read_data;
       <% if (dvm_agent > 32) { %>
        write_data[31:0] = <%=SnpsEnb1%>;
        write_csr(m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVEUSER1.SnpsEnb, write_data);
        read_csr(m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVEUSER1.SnpsEnb, read_data);
        SnpsEn[1] = read_data;
       <% } %>
       <% if (dvm_agent > 64) { %>
        write_data[31:0] = <%=SnpsEnb2%>;
        write_csr(m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVEUSER2.SnpsEnb, write_data);
        read_csr(m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVEUSER2.SnpsEnb, read_data);
        SnpsEn[2] = read_data;
       <% } %>
       <% if (dvm_agent > 96) { %>
        write_data[31:0] = <%=SnpsEnb3%>;
        write_csr(m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVEUSER3.SnpsEnb, write_data);
        read_csr(m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVEUSER3.SnpsEnb, read_data);
        SnpsEn[3] = read_data;
       <% } %>
	cov.collect_dve_static_config(SnpsEn);
       end	
       if($test$plusargs("en_maxonesyncdvmop")) begin
          write_data = 0;
          write_csr(m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVEUENGDBR.MaxOneSyncDVMOp, write_data);
       end          

       // Enable ECC error detection in errors block (DV count does not depend on this)
       if($test$plusargs("mem_err_det_en")) begin
          write_data = 1;
          write_csr(m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVEUUEDR.MemErrDetEn, write_data);
          write_csr(m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVECECR.ErrDetEn, write_data);
          write_csr(m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVEUUEIR.MemErrIntEn, write_data);
       end
    endtask


endclass : dve_csr_init_seq


//-----------------------------------------------------------------------
//-----------------------------------------------------------------------
//  Task    : dve_csr_id_reset_seq
//  Purpose : test unit ids against json, rather than cpr
//
//-----------------------------------------------------------------------
class dve_csr_id_reset_seq extends dve_ral_csr_base_seq; 
   `uvm_object_utils(dve_csr_id_reset_seq)

    uvm_reg_data_t read_data;

    function new(string name="");
        super.new(name);
    endfunction

    task body();
          read_data = 'hDEADBEEF ;  //bogus sentinel


          read_csr(m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVEUIDR.RPN, read_data);
          compareValues("DVEUFUIDR_RPN", "should be 0 (json)", read_data, 0);  //TODO FIXME meaningful values from json
          read_csr(m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVEUIDR.NRRI, read_data);
          compareValues("DVEUIDR_NRRI", "should be 0 (json)", read_data, 0);  //TODO FIXME meaningful values from json
          read_csr(m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVEUIDR.NUnitId, read_data);
          compareValues("DVEUIDR_NUnitId", "should be 0 (json)", read_data, 0);  //TODO FIXME meaningful values from json
          read_csr(m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVEUIDR.Valid, read_data);
          compareValues("DVEUIDR_Valid", "should always be 1", read_data, 1);  

          read_csr(m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVEUFUIDR.FUnitId, read_data);
          //TODO : compare with proper value in json

    endtask


endclass : dve_csr_id_reset_seq

//-----------------------------------------------------------------------
//  Task    : 
//  Purpose : Test Uncorrectable Error registers
//
//-----------------------------------------------------------------------
//#Check.DMI.ErrIntEnUnCorrErrs
class dve_csr_dveuecr_errCntOvf_seq extends dve_ral_csr_base_seq; 
  `uvm_object_utils(dve_csr_dveuecr_errCntOvf_seq)

    uvm_reg_data_t poll_data, read_data, read_data2, write_data;
    bit [7:0]  errthd;
    int        errcount_vld, errthd_vld;
    int        errcount_ovf;
    bit [3:0] errtype;

    function new(string name="");
        super.new(name);
    endfunction

    task body();

<% if(has_secded) { %>

//          if ($test$plusargs("ccp_double_bit_data_error_test") || $test$plusargs("ccp_double_bit_tag_error_test"))
//            errtype = 4'h7;
//          else
//            errtype = 4'h6;
             

          assert(randomize(errthd));
          write_data = errthd;
          // Try Set the DVEUCECR_ErrThreshold. Shouldn't work as this is RAZ/WI
          //SG write_csr(m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVEUUEDR.ErrThreshold, write_data);
          //SG read_csr(m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVEUUEDR.ErrThreshold, read_data);
          //SG compareValues("DVEUUEDR_ErrThreshold","Should be 0", read_data, 0);

          //#Test.DMI.ErrVldErrOvfNotResetW1CIfClr
          // Try Set the DVEUUESR_ErrVld = 1. Shouldn't work as this field is W1C
          write_data = 1;
          write_csr(m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVEUUESR.ErrVld, write_data);
          read_csr(m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVEUUESR.ErrVld, read_data);
          compareValues("DVEUUESR_ErrVld","Should be 0", read_data, 0);

          //SG write_csr(m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVEUUESR.ErrOvf, write_data);
          //SG read_csr(m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVEUUESR.ErrOvf, read_data);
          //SG compareValues("DVEUUESR_ErrVld","Should be 0", read_data, 0);

         // Set the DVEUUEDR_ErrDetEn = 1
          //#Check.DMI.DetectEnSet
          write_data = 1;
          write_csr(m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVEUUEDR.TransErrDetEn, write_data);
         //SG // Set the DVEUUEDR_ErrIntEn = 1
         //SG  write_csr(m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVEUUEDR.ErrIntEn, write_data);
         // write  DVEUUESR_ErrVld = 1 , to reset it
          write_csr(m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVEUUESR.ErrVld, write_data);

        ///////////////////////////////////////////////////////////

          //keep on  Reading the DVEUUESR_ErrVld bit = 1
          poll_DVEUUESR_ErrVld(1, poll_data);
          compareValues("DVEUUESR_ErrVld", "set", poll_data, 1);

          read_csr(m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVEUUESR.ErrType, read_data);
          compareValues("DVEUUESR_ErrType","Valid Type", read_data, errtype);
          //SG read_csr(m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVEUUESR.ErrCount, read_data);
          //SG compareValues("DVEUUESR_ErrCount","For uncorrectable", read_data, 0);

          //keep on  Reading the DVEUUESR_ErrcountOvf bit = 1 
          //SG poll_DVEUUESR_ErrOvf(1, poll_data);
          //SG compareValues("DVEUUESR_ErrOvf", "set", poll_data, 1);

          read_csr(m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVEUUESR.ErrVld, read_data);
          compareValues("DVEUUESR_ErrVld", "set", read_data, 1);

          read_csr(m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVEUUESR.ErrType, read_data);
          compareValues("DVEUUESR_ErrType","Valid Type", read_data, errtype);
          //SG read_csr(m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVEUUESR.ErrCount, read_data);
          //SG compareValues("DVEUUESR_ErrCount","For uncorrectable", read_data, 0);

          // Read DVEUUESAR_ErrVld , it should be 1
          read_csr(m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVEUUESAR.ErrVld, read_data);
          compareValues("DVEUESAR_ErrVld", "set", read_data, 1);

          read_csr(m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVEUUESR.ErrType, read_data);
          compareValues("DVEUUESR_ErrType","Valid Type", read_data, errtype);

          // Reset the DVEUUEDR_ErrDetEn = 0
          write_data = 0;
          write_csr(m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVEUUEDR.TransErrDetEn, write_data);

          // Clear the DVEUUEDR_ErrIntEn = 0
          //SG write_csr(m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVEUUEDR.ErrIntEn, write_data);
          //#Test.DMI.ErrVldErrOvfResetW1CAfterSet
          // write  DVEUUESAR_ErrVld = 0 , to reset it
          write_csr(m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVEUUESAR.ErrVld, write_data);
          //SG read_csr(m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVEUUESR.ErrOvf, read_data);
          //SG compareValues("DVEUUESR_ErrOvf", "still set", read_data, 1);
          read_csr(m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVEUUESR.ErrType, read_data);
          compareValues("DVEUUESR_ErrType","Valid Type", read_data, errtype);

         // Read DVEUUESAR_ErrVld , it should also be 0, because it is alias of register
         // DVEUUESR_ErrVld
          //#Test.DMI.ErrVldErrOvfResetW1CAfterSet
          read_csr(m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVEUUESAR.ErrVld, read_data);
          compareValues("DVEUESAR_ErrVld", "cleared previously", read_data, 0);
          //SG read_csr(m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVEUUESAR.ErrOvf, read_data);
          //SG compareValues("DVEUUESAR_ErrOvf", "still set", read_data, 1);
          read_csr(m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVEUUESAR.ErrType, read_data);
          compareValues("DVEUUESAR_ErrType","Valid Type", read_data, errtype);

          //#Test.DMI.ErrVldErrOvfResetW1CAfterSet
          // Read DVEUUESR_ErrOvf , it should be 1
          //SG read_csr(m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVEUUESR.ErrOvf, read_data);
          //SG compareValues("DVEUUESR_ErrOvf", "still set", read_data, 1);

          // write  DVEUUESR_ErrOvf = 1 , to reset it
          //SG write_data = 1;
          //SG write_csr(m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVEUUESR.ErrOvf, write_data);

          //SG //#Test.DMI.ErrVldErrOvfResetW1CAfterSet
          //SG // Read DVEUUESR_ErrOvf , it should be 0
          //SG read_csr(m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVEUUESR.ErrOvf, read_data);
          //SG compareValues("DVEUUESR_ErrOvf", "now clear", read_data, 0);
          //SG read_csr(m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVEUUESR.ErrCount, read_data);
          //SG compareValues("DVEUUESR_ErrCount","cleared", read_data, 0);
          //SG // Read DVEUUESAR_ErrOvf , it should be 0
          //SG read_csr(m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVEUUESAR.ErrOvf, read_data);
          //SG compareValues("DVEUUESAR_ErrOvf", "now clear", read_data, 0);
          //SG read_csr(m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVEUUESAR.ErrCount, read_data);
          //SG compareValues("DVEUUESAR_ErrCount","cleared", read_data, 0);

          // write  DVEUUESAR_ErrVld = 1 , to set it
          write_data = 1;
          write_csr(m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVEUUESAR.ErrVld, write_data);

          //#Test.DMI.ESARWriteUpdatesESR
          // write  DVEUUESR_ErrVld = 1 , to reset it
          write_data = 1;
          write_csr(m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVEUUESR.ErrVld, write_data);

          // Read DVEUUESAR_ErrOvf , it should be 0
          //SG read_csr(m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVEUUESAR.ErrOvf, read_data);
          //SG compareValues("DVEUUESAR_ErrOvf", "clear", read_data, 0);
          //SG read_csr(m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVEUUESAR.ErrCount, read_data);
          //SG compareValues("DVEUUESAR_ErrCount","cleared", read_data, 0);

<% } else { %>
          // Read the DVEUUESR_ErrVld bit = 0
          read_csr(m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVEUUESR.ErrVld, read_data);
          compareValues("DVEUESR_ErrVld", "RAZ/WI", read_data, 0);
          // Read the DVEUUESR_ErrcountOvf bit = 0 
          //SG read_csr(m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVEUUESR.ErrOvf, read_data);
          //SG compareValues("DVEUUESR_ErrOvf", "RAZ/WI", read_data, 0);
          // Read DVEUUESAR_ErrVld , it should be 0
          read_csr(m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVEUUESAR.ErrVld, read_data);
          compareValues("DVEUESAR_ErrVld", "RAZ/WI", read_data, 0);
          read_csr(m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVEUUESAR.ErrType, read_data);
          compareValues("DVEUUESAR_ErrType","RAZ/WI", read_data, 0);
          // Read DVEUUESR_ErrVld , it should be 0
          //SG read_csr(m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVEUUESR.ErrOvf, read_data);
          //SG compareValues("DVEUUESR_ErrOvf", "RAZ/WI", read_data, 0);
          // Read DVEUUESAR_ErrVld , it should also be 0, because it is alias of register
          //SG read_csr(m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVEUUESAR.ErrOvf, read_data);
          //SG compareValues("DVEUUESAR_ErrOvf", "RAZ/WI", read_data, 0);
          // write  DVEUUESAR_ErrVld = 1
          write_data = 1;
          write_csr(m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVEUUESR.ErrVld, write_data);
          // Read DVEUUESR_ErrVld , it should be 0
          read_csr(m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVEUUESR.ErrVld, read_data);
          compareValues("DVEUESR_ErrVld", "RAZ/WI", read_data, 0);
          // write  DVEUUESR_ErrOvf = 1
          //SG write_csr(m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVEUUESR.ErrOvf, write_data);
          // Read DVEUUESR_ErrOvf , it should be 0
          //SG read_csr(m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVEUUESR.ErrOvf, read_data);
          //SG compareValues("DVEUUESR_ErrOvf", "RAZ/WI", read_data, 0);

<% } %>
    endtask
endclass : dve_csr_dveuecr_errCntOvf_seq

//-----------------------------------------------------------------------
//  Task    : 
//  Purpose : 
//
//-----------------------------------------------------------------------
class dve_csr_dveuedr_TransErrDetEn_seq extends dve_ral_csr_base_seq; 
  `uvm_object_utils(dve_csr_dveuedr_TransErrDetEn_seq)

    uvm_reg_data_t poll_data, read_data, read_data2, write_data;
    bit [7:0]  errthd;
    int        errcount_vld, errthd_vld;
    int        errcount_ovf;
    bit        errvld;
    bit [3:0]  errtype;
    bit [19:0] errinfo;
    bit [9:0] trgt_id;
    bit [9:0] msg_id;
    smi_seq_item req_pkt;

    static uvm_event_pool ev_pool = uvm_event_pool::get_global_pool();
    static uvm_event ev = ev_pool.get("ev");
    static uvm_event ev_addr = ev_pool.get("ev_addr");

    
    function new(string name="");
        super.new(name);
    endfunction

    task body();

      bit dis_uedr_ted_4resiliency = $test$plusargs("dis_uedr_ted_4resiliency") ? 1 : 0;
<% if(has_secded) { %>
      if(dis_uedr_ted_4resiliency) begin
        `uvm_info(get_full_name(),$sformatf("Skipping enabling of error detection inside xUEDR"),UVM_NONE)
      end
      else begin

            errvld = 1'b0;

           if (($test$plusargs("inject_cmd_trgt_id_err")) ||
	       ($test$plusargs("inject_dtw_trgt_id_err")) ||
	       ($test$plusargs("inject_str_trgt_id_err")) ||
	       ($test$plusargs("inject_snp_trgt_id_err")) ||
	       ($test$plusargs("inject_sys_trgt_id_err")) ||
               ($test$plusargs("inject_dtw_dbg_trgt_id_err")))
           begin      
               // Set the DVEUUEDR_ErrDetEn = 1
               write_data = 1;
               write_csr(m_regs.<%=obj.DutInfo.strRtlNamePrefix%>.DVEUUEDR.TransErrDetEn, write_data);
               while(errvld == 1'b0) begin
                   ev_addr.wait_trigger();
                   `uvm_info("RUN_MAIN", "Got ev_addr event trigger", UVM_NONE)
                   if($cast(req_pkt, ev_addr.get_trigger_data())) begin
                       trgt_id = req_pkt.smi_targ_ncore_unit_id;
                       // wait for packet with bad target id
                       if(trgt_id != <%=obj.DutInfo.FUnitId%>) begin
                           errinfo[0] = 1'b0;
                           //errinfo[5:1] = 1'b0;
                           //errinfo[15:6] = req_pkt.smi_src_ncore_unit_id << WSMINCOREPORTID;
                           errinfo[19:8] = req_pkt.smi_src_ncore_unit_id; //FUnitId
                           errvld = 1'b1;
                           `uvm_info("RUN_MAIN", $sformatf("targ_id 0x%0h, errinfo 0x%0h", trgt_id, errinfo), UVM_NONE);
                       end
                   end
               end
               errtype = 4'h8;
           end
           else begin
               errinfo = 20'h0;
               errtype = 4'h0;
               // Set the DVEUUEDR_ErrDetEn = 1
               write_data = 1;
               write_csr(m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVEUUEDR.TransErrDetEn, write_data);
           end
           // Set the DVEUUEDR_ErrDetEn = 1
           //write_data = 1;
           //write_csr(m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVEUUEDR.TransErrDetEn, write_data);
           //keep on  Reading the DVEUUESR_ErrVld bit = 1
           poll_DVEUUESR_ErrVld(1, poll_data);
           `uvm_info("RUN_MAIN",$sformatf("Poll exited: got ErrVld to 1"), UVM_NONE)
           read_csr(m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVEUUESR.ErrType, read_data);
           compareValues("DVEUUESR_ErrType","Valid Type", read_data, errtype);
           read_csr(m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVEUUESR.ErrInfo, read_data);
           compareValues("DVEUUESR_ErrInfo","Valid Info", read_data, errinfo);
           // Read DVEUUESAR_ErrVld , it should be 1
           // Set the DVEUUEDR_ErrDetEn = 0, to diable the error detection
           write_data = 0;
           write_csr(m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVEUUEDR.TransErrDetEn, write_data);
           // Read DVEUUESR_ErrVld , it should be 1
           read_csr(m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVEUUESR.ErrVld, read_data);
           compareValues("DVEUUESR_ErrVld", "set", read_data, 1);
           read_csr(m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVEUUESR.ErrType, read_data);
           compareValues("DVEUUESR_ErrType","Valid Type", read_data, errtype);
           // write  DVEUUESR_ErrVld = 1 , W1C
           write_data = 1;
           write_csr(m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVEUUESR.ErrVld, write_data);
           // Read the DVEUUESR_ErrVld should be cleared
           read_csr(m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVEUUESR.ErrVld, read_data);
           compareValues("DVEUUESR_ErrVld", "now clear", read_data, 0);
           // Read DVEUUESAR_ErrVld , it should also clear, beacuse it is alias register
           // of register DVEUUESR_*
           read_csr(m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVEUUESAR.ErrVld, read_data);
           //TODO compareValues("DVEUUESAR_ErrVld", "now clear", read_data, 0);
           // write  DVEUUESR_ErrVld = 1 , to make sure it only reset by 1, not set by 1
//FIXME           write_data = 1;
//FIXME           write_csr(m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVEUUESR.ErrVld, write_data);
//FIXME           // Read the DVEUUESR_ErrVld should be still be 0
//FIXME           if (!$test$plusargs("inject_trgt_id_err")) begin
//FIXME             read_csr(m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVEUUESR.ErrVld, read_data);
//FIXME             compareValues("DVEUUESR_ErrVld", "still clear", read_data, 0);
//FIXME           end
      end
<% } else { %>
           // Read the DVEUUESR_ErrVld should be clear
           read_csr(m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVEUUESR.ErrVld, read_data);
           compareValues("DVEUESR_ErrVld", "RAZ/WI", read_data, 0);
           // Read DVEUUESAR_ErrVld , it should also clear, beacuse it is alias register
           // of register DVEUUESR_*
           read_csr(m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVEUUESAR.ErrVld, read_data);
           compareValues("DVEUESAR_ErrVld", "RAZ/WI", read_data, 0);
           // Read the DVEUUESR_ErrVld should be still be 0
           read_csr(m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVEUUESR.ErrVld, read_data);
           compareValues("DVEUUESR_ErrVld", "still clear", read_data, 0);
           // write  DVEUUESR_ErrVld = 1 , to reset it
           write_data = 1;
           write_csr(m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVEUUESR.ErrVld, write_data);
           // Read the DVEUUESR_ErrVld should be cleared
           write_data = 1;
           write_csr(m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVEUUESR.ErrVld, write_data);
           read_csr(m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVEUUESR.ErrVld, read_data);
           compareValues("DVEUUESR_ErrVld", "clear", read_data, 0);
           // Read DVEUUESAR_ErrVld , it should also clear, beacuse it is alias register
           // of register DVEUUESR_*
           read_csr(m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVEUUESAR.ErrVld, read_data);
           compareValues("DVEUUESAR_ErrVld", "clear", read_data, 0);
<% } %>
    endtask
endclass : dve_csr_dveuedr_TransErrDetEn_seq

//-----------------------------------------------------------------------
//  Task    : 
//  Purpose : 
//
//-----------------------------------------------------------------------
class dve_sw_TransErrDetEn_seq extends dve_ral_csr_base_seq; 
  `uvm_object_utils(dve_sw_TransErrDetEn_seq)

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
<% if(has_secded) { %>                        

           // Set the DVEUUEDR_ErrDetEn = 1
           errtype = 4'h8;
           write_data = 1;
           write_csr(m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVEUUEDR.TransErrDetEn, write_data);
           // Set the DVEUUEDR_ErrIntEn = 1
           write_csr(m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVEUUEIR.TransErrIntEn, write_data);
	   // Set the DVEUUESAR_ErrVld = 1
           write_csr(m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVEUUESAR.ErrVld, write_data);
	   //Write error type into DVEUESAR_ErrType
	   write_csr(m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVEUUESAR.ErrType, errtype);

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
           // Read the DVEUUESR_ErrVld
           read_csr(m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVEUUESR.ErrVld, read_data);
           compareValues("DVEUUESR_ErrVld", "set after inte", read_data, 1);
	   // Read the DVEUUESE ErrType
           read_csr(m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVEUUESR.ErrType, read_data);
           compareValues("DVEUUESR_ErrType","Valid Type", read_data, errtype);
          
	   write_data = 1;
           // write 1 to clear
           write_csr(m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVEUUESR.ErrVld, write_data);
           // Read DVEUUESR_ErrVld , it should be 0
           read_csr(m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVEUUESR.ErrVld, read_data);
           compareValues("DVEUUESR_ErrVld", "reset", read_data, 0);
	   write_data = 0;
           write_csr(m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVEUUESAR.ErrVld, write_data);
	   // Set the DVEUUEDR_ErrIntEn = 0, to disable the error
           write_csr(m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVEUUEDR.TransErrDetEn, write_data);
           // Set the DVEUUEIR_ErrIntEn = 0, to disable the error Interrupt
           write_csr(m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVEUUEIR.TransErrIntEn, write_data);
           // Monitor IRQ_C pin , it should be 0 now
           if(u_csr_probe_vif.IRQ_UC == 0)begin
             `uvm_info("RUN_MAIN",$sformatf("IRQ_UC interrupted de-asseretd"), UVM_MEDIUM)
           end else begin
             `uvm_error("RUN_MAIN",$sformatf("IRQ_UC interruped still aseerted"));
           end

           <% } %>
    endtask
endclass : dve_sw_TransErrDetEn_seq


class dve_csr_dveueir_TransErrInt_seq extends dve_ral_csr_base_seq; 
  `uvm_object_utils(dve_csr_dveueir_TransErrInt_seq)

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
<% if(has_secded) { %>

//           if ($test$plusargs("ccp_double_bit_data_error_test") || $test$plusargs("ccp_double_bit_tag_error_test"))
//             errtype = 4'h7;
//           else
//             errtype = 4'h6;
             

           // Set the DVEUUEDR_ErrDetEn = 1
           errtype = 4'h8;
           write_data = 1;
           write_csr(m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVEUUEDR.TransErrDetEn, write_data);
           // Set the DVEUUEDR_ErrIntEn = 1
           write_csr(m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVEUUEIR.TransErrIntEn, write_data);
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
           // Read the DVEUUESR_ErrVld
           read_csr(m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVEUUESR.ErrVld, read_data);
           compareValues("DVEUUESR_ErrVld", "set after inte", read_data, 1);
           read_csr(m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVEUUESR.ErrType, read_data);
           compareValues("DVEUUESR_ErrType","Valid Type", read_data, errtype);
           //SG read_csr(m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVEUUESR.ErrCount, read_data);
           //SG compareValues("DVEUUESR_ErrCount","for uncorr", read_data, 0);
           // Read DVEUUESAR_ErrVld , it should have same as  DVEUUESR_*
           read_csr(m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVEUUESAR.ErrVld, read_data);
           //TODO compareValues("DVEUUESAR_ErrVld", "set after inte", read_data, 1);
           read_csr(m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVEUUESAR.ErrType, read_data);
           //TODO compareValues("DVEUUESAR_ErrType","Valid Type", read_data, errtype);
           //SG read_csr(m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVEUUESAR.ErrCount, read_data);
           //SG compareValues("DVEUUESAR_ErrCount","for uncorr", read_data, 0);
           // Set the DVEUUEDR_ErrDetEn = 0, to disable the error detection
           write_data = 0;
           write_csr(m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVEUUEDR.TransErrDetEn, write_data);
           // Set the DVEUUEDR_ErrIntEn = 0, to disable the error Interrupt
           write_csr(m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVEUUEIR.TransErrIntEn, write_data);
           // write DVEUUESR_ErrVld = 1 to clear it
           write_data = 1;
           write_csr(m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVEUUESR.ErrVld, write_data);
           // Read DVEUUESR_ErrVld , it should be 0
           read_csr(m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVEUUESR.ErrVld, read_data);
           compareValues("DVEUUESR_ErrVld", "reset", read_data, 0);
           // Read DVEUUESAR_ErrVld , it should be 0
           read_csr(m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVEUUESAR.ErrVld, read_data);
           //TODO compareValues("DVEUUESAR_ErrVld", "reset", read_data, 0);
           // Monitor IRQ_C pin , it should be 0 now
           if(u_csr_probe_vif.IRQ_UC == 0)begin
             `uvm_info("RUN_MAIN",$sformatf("IRQ_UC interrupted de-asseretd"), UVM_MEDIUM)
           end else begin
             `uvm_error("RUN_MAIN",$sformatf("IRQ_UC interruped still aseerted"));
           end
<% } else { %>
           // Monitor IRQ_UC pin , it should be 0 now
           if(u_csr_probe_vif.IRQ_UC == 0)begin
             `uvm_info("RUN_MAIN",$sformatf("IRQ_UC interrupted de-asserted"), UVM_MEDIUM)
           end else begin
             `uvm_error("RUN_MAIN",$sformatf("IRQ_UC interruped asserted"));
           end
          // Read DVEUUESR_ErrVld , it should be 0
           read_csr(m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVEUUESR.ErrVld, read_data);
           compareValues("DVEUUESR_ErrVld", "set", read_data, 0);
           read_csr(m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVEUUESR.ErrType, read_data);
           compareValues("DVEUUESR_ErrType","Valid Type", read_data, 4'h0);
           //SG read_csr(m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVEUUESR.ErrCount, read_data);
           //SG compareValues("DVEUUESR_ErrCount","for uncorr", read_data, 0);
          // Read DVEUUESAR_ErrVld , it should be 0
           read_csr(m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVEUUESAR.ErrVld, read_data);
           compareValues("DVEUUESAR_ErrVld", "set", read_data, 0);
           read_csr(m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVEUUESAR.ErrType, read_data);
           compareValues("DVEUUESAR_ErrType","Valid Type", read_data, 4'h0);
           //SG read_csr(m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVEUUESAR.ErrCount, read_data);
           //SG compareValues("DVEUUESAR_ErrCount","for uncorr", read_data, 0);
          // Monitor IRQ_C pin , it should be 0 now
          if(u_csr_probe_vif.IRQ_UC == 0)begin
             `uvm_info("RUN_MAIN",$sformatf("IRQ_UC interrupted de-asseretd"), UVM_MEDIUM)
          end else begin
             `uvm_error("RUN_MAIN",$sformatf("IRQ_UC interruped still aseerted"));
          end
<% } %>
    endtask
endclass : dve_csr_dveueir_TransErrInt_seq

//-----------------------------------------------------------------------
//  Task    : 
//  Purpose : 
//
//-----------------------------------------------------------------------
class dve_csr_dveuecr_errThd_seq extends dve_ral_csr_base_seq; 
  `uvm_object_utils(dve_csr_dveuecr_errThd_seq)

    uvm_reg_data_t poll_data, read_data, read_data2, write_data;
    bit [7:0]  errthd;
    int        errcount_vld, errthd_vld;
    int        errcount_ovf;

    function new(string name="");
        super.new(name);
    endfunction

    task body();

       //getCsrProbeIf();
<% if(has_secded) { %>
          // Set the DVEUUEDR_ErrDetEn = 1
          write_data = 1;
          write_csr(m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVEUUEDR.TransErrDetEn, write_data);
          // Set the DVEUUEDR_ErrIntEn = 1
          //SG write_csr(m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVEUUEDR.ErrIntEn, write_data);
          // Try set the DVEUUEDR_ErrThreshold; shouldn't work
          assert(randomize(errthd));
          write_data = errthd;
          //SG write_csr(m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVEUUEDR.ErrThreshold, write_data);
          //SG read_csr(m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVEUUEDR.ErrThreshold, read_data);
          //SG compareValues("DVEUUEDR_ErrThreshold", "can't be set", read_data, 0);
          // write  DVEUUESR_ErrVld = 1 , to reset it
          write_csr(m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVEUUESR.ErrVld, write_data);
          //keep on  Reading the DVEUUESR_ErrVld bit = 1 
          poll_DVEUUESR_ErrVld(1, poll_data);
          // Read DVEUUESR_ErrCount , it should be at errthd
          //SG read_csr(m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVEUUESR.ErrCount, read_data);
          //SG compareValues("DVEUUESR_ErrCount","for uncorr", read_data, 0);
          // Read alias field  DVEUUESAR_ErrCount , should match
          //SG read_csr(m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVEUUESAR.ErrCount, read_data);
          //SG compareValues("DVEUUESAR_ErrCount","for uncorr", read_data, 0);
          // Set the DVEUUEDR_ErrDetEn = 0
          write_data = 0;
          write_csr(m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVEUUEDR.TransErrDetEn, write_data);
          // write : DVEUUESR_ErrVld = 1 , to reset it
          write_data = 1;
          write_csr(m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVEUUESR.ErrVld, write_data);
          // Read DVEUUESAR_ErrVld , it should be 0
          read_csr(m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVEUUESAR.ErrVld, read_data);
          compareValues("DVEUUESAR_ErrVld", "now clear", read_data, 0);
          // Read DVEUUESR_ErrVld , it should be 0
          read_csr(m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVEUUESR.ErrVld, read_data);
          compareValues("DVEUUESR_ErrVld", "now clear", read_data, 0);
<% } else { %>
          // Read DVEUUESR_ErrCount , it should be 0
          //SG read_csr(m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVEUUESR.ErrCount, read_data);
          //SG compareValues("DVEUUESR_ErrCount","RAZ/WI", read_data, 0);
          // write alias : DVEUUESAR_ErrVld = 1 , to reset it
          write_data = 1;
          write_csr(m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVEUUESR.ErrVld, write_data);
          //#Test.DMI.ESARWriteUpdatesESR
          read_csr(m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVEUUESR.ErrVld, read_data);
          compareValues("DVEUUESR_ErrVld", "clear", read_data, 0);
<% } %>
    endtask
endclass : dve_csr_dveuecr_errThd_seq

//-----------------------------------------------------------------------
//  Task    : 
//  Purpose : 
//
//-----------------------------------------------------------------------
//#Test.DMI.ErrInjWhileSoftwareWriteHappens
class dve_csr_dveuedr_sw_write_seq extends dve_ral_csr_base_seq; 
  `uvm_object_utils(dve_csr_dveuedr_sw_write_seq)

    uvm_reg_data_t poll_data, read_data, read_data2, write_data;
    bit [7:0]  errthd;
    int        errcount_vld, errthd_vld;
    int        i;

    function new(string name="");
        super.new(name);
    endfunction

    task body();

       //getCsrProbeIf();
<% if(has_secded) { %>
          // Set the DVEUUEDR_ErrDetEn = 1
          write_data = 1;
          write_csr(m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVEUUEDR.TransErrDetEn, write_data);
          // write  DVEUCESR_ErrVld = 1 , to reset it
          write_csr(m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVEUUESR.ErrVld, write_data);
          write_data = 0;
          for (i=0;i<100;i++) begin
             write_csr(m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVEUUESAR.ErrVld, write_data);
          end
          // Set the DVEUUEDR_ErrDetEn = 0
          write_data = 0;
          write_csr(m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVEUUEDR.TransErrDetEn, write_data);
          // if vld is set, reset it
          read_csr(m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVEUUESR.ErrVld, read_data);
          if(read_data) begin
             write_csr(m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVEUUESAR.ErrVld, write_data);
          end
<% } %>
    endtask
endclass : dve_csr_dveuedr_sw_write_seq

//-----------------------------------------------------------------------
//  Task    : 
//  Purpose : 
//
//-----------------------------------------------------------------------
//#Test.DMI.DetectEnNotSetErrorsInjected
class dve_csr_dveuedr_noError_seq extends dve_ral_csr_base_seq; 
  `uvm_object_utils(dve_csr_dveuedr_noError_seq)

    uvm_reg_data_t poll_data, read_data, read_data2, write_data;
    bit [7:0]  errthd;
    int        errcount_vld, errthd_vld;
    int        errcount_ovf;

    function new(string name="");
        super.new(name);
    endfunction

    task body();

<% if(has_secded) { %>
          // Set the DVEUUEDR_ErrDetEn = 1
          write_data = 1;
          write_csr(m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVEUUEDR.TransErrDetEn, write_data);
          //Reading the DVEUUESR_ErrVld bit = 0
          while(1) begin
            read_csr(m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVEUUESR.ErrVld, read_data);
            compareValues("DVEUUESR_ErrVld", "not set", read_data, 0);
          end

<% } else { %>
          // Read the DVEUUESR_ErrVld should be cleared
          read_csr(m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVEUUESR.ErrVld, read_data);
          compareValues("DVEUUESR_ErrVld", "not set", read_data, 0);
          // Read DVEUUESAR_ErrVld , it should also clear, beacuse it is alias register
          // of register DVEUUESR_*
          read_csr(m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVEUUESAR.ErrVld, read_data);
          compareValues("DVEUUESAR_ErrVld", "not set", read_data, 0);
<% } %>
    endtask
endclass : dve_csr_dveuedr_noError_seq

//-----------------------------------------------------------------------
//  Task    : 
//  Purpose : 
//
//-----------------------------------------------------------------------
//#Test.DMI.DetectEnNotSetErrorsInjected
class dve_csr_dveuedr_noDetEn_seq extends dve_ral_csr_base_seq; 
  `uvm_object_utils(dve_csr_dveuedr_noDetEn_seq)

    uvm_reg_data_t poll_data, read_data, read_data2, write_data;
    bit [7:0]  errthd;
    int        errcount_vld, errthd_vld;
    int        errcount_ovf;

    function new(string name="");
        super.new(name);
    endfunction

    task body();

<% if(has_secded) { %>
          // Don't Set the DVEUUEDR_ErrDetEn = 1
          //Reading the DVEUUESR_ErrVld bit = 0
          read_csr(m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVEUUESR.ErrVld, read_data);
          compareValues("DVEUUESR_ErrVld", "not set", read_data, 0);
          // Read DVEUUESR_ErrCount , it should be at 0
          //SG read_csr(m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVEUUESR.ErrCount, read_data);
          //SG compareValues("DVEUUESR_ErrCount","not set", read_data, 0);
          // Read alias field  DVEUUESAR_ErrCount , should match
          //SG read_csr(m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVEUUESAR.ErrCount, read_data);
          //SG compareValues("DVEUUESAR_ErrCount","not set", read_data, 0);

          // Read DVEUUESAR_ErrVld , it should also clear, beacuse it is alias register
          // of register DVEUUESR_*
          read_csr(m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVEUUESAR.ErrVld, read_data);
          compareValues("DVEUUESAR_ErrVld", "not set", read_data, 0);
<% } else { %>
          // Read the DVEUUESR_ErrVld should be cleared
          read_csr(m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVEUUESR.ErrVld, read_data);
          compareValues("DVEUUESR_ErrVld", "not set", read_data, 0);
          // Read DVEUUESAR_ErrVld , it should also clear, beacuse it is alias register
          // of register DVEUUESR_*
          read_csr(m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVEUUESAR.ErrVld, read_data);
          compareValues("DVEUUESAR_ErrVld", "not set", read_data, 0);
<% } %>
    endtask
endclass : dve_csr_dveuedr_noDetEn_seq

//-----------------------------------------------------------------------
//  Task    : 
//  Purpose : 
//
//-----------------------------------------------------------------------
//#Test.DMI.DetectEnNotSetErrorsInjected


class dve_csr_dveuser_SnoopCap_seq extends dve_ral_csr_base_seq; 
  `uvm_object_utils(dve_csr_dveuser_SnoopCap_seq)

   <%
   let SnpEn = 0;
   for(let i in Dvm_NUnitIds) {
      SnpEn |= 1 << Dvm_NUnitIds[i];
    } %>

    uvm_reg_data_t poll_data, read_data, read_data2, write_data;
    int SnoopEn = <%=SnpEn%> ;

    function new(string name="");
        super.new(name);
    endfunction

    task body();

          read_csr(m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVEUSER0.SnpsEnb, read_data);
          read_data = read_data | SnoopEn;
          write_csr(m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVEUSER0.SnpsEnb, SnoopEn);
          read_csr(m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVEUSER0.SnpsEnb, read_data);
          SnoopEn = read_data;
          //compareValues("DVEUUESR_ErrVld", "not set", read_data, 8'h0f);
    endtask
endclass : dve_csr_dveuser_SnoopCap_seq

//-----------------------------------------------------------------------
//  Task    : 
//  Purpose : 
//
//-----------------------------------------------------------------------
class dve_csr_dveuecr_noIntEn_seq extends dve_ral_csr_base_seq; 
  `uvm_object_utils(dve_csr_dveuecr_noIntEn_seq)

    uvm_reg_data_t poll_data, read_data, read_data2, write_data;
    bit [7:0]  errthd;
    int        errcount_vld, errthd_vld;
    int        errcount_ovf;

    function new(string name="");
        super.new(name);
    endfunction

    task body();

       getCsrProbeIf();
<% if(has_secded) { %>
          // Set the DVEUUEDR_ErrDetEn = 1
          write_data = 1;
          write_csr(m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVEUUEDR.TransErrDetEn, write_data);
          // Dont Set the DVEUUEDR_ErrIntEn = 1
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
          //Reading the DVEUUESR_ErrVld bit = 1
          read_csr(m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVEUUESR.ErrVld, read_data);
          compareValues("DVEUUESR_ErrVld", "set", read_data, 1);
          // write DVEUUESR_ErrVld = 1 to clear it
          write_data = 1;
          write_csr(m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVEUUESR.ErrVld, write_data);
          //SG write_csr(m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVEUUESR.ErrOvf, write_data);
<% } else { %>
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
<% } %>
    endtask
endclass : dve_csr_dveuecr_noIntEn_seq

class dve_csr_dveuelr_seq extends dve_ral_csr_base_seq; 
  `uvm_object_utils(dve_csr_dveuelr_seq)

    uvm_reg_data_t poll_data, read_data, read_data2, write_data;
    bit [7:0]  errthd;
    bit [43:0] actual_addr;
    bit [43:0] expt_addr;
    int        errcount_vld, errthd_vld;
    bit [19:0] errentry;
    bit [5:0]  errway, errword;
    bit [11:0] erraddr;
    bit [31:0] erraddr0;
    smi_seq_item req_item; 

    static uvm_event_pool ev_pool = uvm_event_pool::get_global_pool();
    static uvm_event ev_addr = ev_pool.get("ev_addr");

    function new(string name="");
        super.new(name);
    endfunction

    task body();

<% if(has_secded) { %>
        `uvm_info("RUN_MAIN",$sformatf("Entered Test loop"), UVM_LOW)
    
          //keep on  Reading the DVEUUESR_ErrCount bit = 1
          write_data = 1;
          write_csr(m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVEUUEDR.TransErrDetEn, write_data);

          ev_addr.wait_trigger();
          if($cast(req_item, ev_addr.get_trigger_data())) begin
              expt_addr  = req_item.smi_addr;
          end 
          expt_addr = 0;

          poll_DVEUUESR_ErrVld(1, poll_data);
          //poll_csr(m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVEUUESR.ErrVld,1,poll_data);

          //#Test.DMI.UnCorrErrErrLoggingSetAfterErrorCntCrossesErrThreshold
          //#Test.DMI.UnCorrErrErrLoggingRegisters
          //#Check.DMI.DetectEnSet
          //readCompareUELR(1);
          read_csr(m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVEUUELR0.ErrAddr, read_data);
          erraddr0 = read_data;
//        read_csr(m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVEUUELR0.ErrEntry, read_data);
//        errentry = read_data;
//        read_csr(m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVEUUELR0.ErrWay, read_data);
//        errway = read_data;
//        read_csr(m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVEUUELR0.ErrWord, read_data);
//        errword = read_data;
          read_csr(m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVEUUELR1.ErrAddr, read_data);
          erraddr = read_data;
          actual_addr = {erraddr,erraddr0}; 
          compareValues("DVEUCELR", "error address matched", actual_addr, expt_addr);

<% } %>
    endtask
endclass : dve_csr_dveuelr_seq

class res_corr_err_threshold_seq extends dve_ral_csr_base_seq; 
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
      `uvm_info(get_name(), $sformatf("Writing DVEUCRTR res_corr_err_threshold = %0d", write_data), UVM_NONE)
      write_csr(m_regs.<%=obj.DveInfo[obj.Id].strRtlNamePrefix%>.DVEUCRTR.ResThreshold, write_data);
      <% } %>
    endtask
endclass : res_corr_err_threshold_seq
