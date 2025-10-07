///////////////////////////////////////////////////////////////////////////////
//                                                                           //
// File         :   dmi_csr_ralgen_seq.sv                                    //
// Author       :   Aniket                                                   //
// Description  :   Sequence for OCP                                         //
//                                                                           //
// Revision     :                                                            //
//                                                                           //
///////////////////////////////////////////////////////////////////////////////


<% var rttUncorr = 0;
 if((obj.useRttDataEntries > 0) && (obj.DmiInfo[obj.Id].cmpInfo.RttDataErrorInfo.fnErrDetectCorrect.substring(0,4) !== "NONE")) { 
    rttUncorr = 1;
}
%>

<% var rttCorr = 0;
 if((obj.useRttDataEntries > 0) && (obj.DmiInfo[obj.Id].cmpInfo.RttDataErrorInfo.fnErrDetectCorrect.substring(0,6) === "SECDED")) { 
    rttCorr = 1;
}
%>

<% var cmcUncorr = 0;
 if((obj.useCmc > 0) && (obj.DmiInfo[obj.Id].ccpParams.DataErrInfo.substring(0,4) !== "NONE" || 
                         obj.DmiInfo[obj.Id].ccpParams.TagErrInfo.substring(0,6)  !== "NONE")) { 
    cmcUncorr = 1;
}
%>

<% var cmcCorr = 0;
 if((obj.useCmc > 0) && (obj.DmiInfo[obj.Id].ccpParams.DataErrInfo.substring(0,6) === "SECDED" || obj.DmiInfo[obj.Id].ccpParams.TagErrInfo.substring(0,6) === "SECDED")) { 
    cmcCorr = 1;
}
%>
//DEBUG_err: rttUncorr = <%=rttUncorr%>
//DEBUG_err: rttCorr = <%=rttCorr%>


class dmi_csr_ralgen_base_seq extends uvm_reg_sequence;
    `uvm_object_utils(dmi_csr_ralgen_base_seq)

    uvm_reg_data_t         rd_data,wr_data;
    uvm_reg_data_t         data;
    ral_sys_ncore          m_regs;
    uvm_status_e           status;
    uvm_reg_data_t         field_rd_data;


    virtual dmi_csr_probe_if u_csr_probe_vif;

    function new(string name="dmi_csr_ralgen_base_seq");
        super.new(name);
    endfunction

   function getCsrProbeIf();
      if(!uvm_config_db#(virtual dmi_csr_probe_if )::get(null, get_full_name(), "u_csr_probe_if",u_csr_probe_vif))
        `uvm_error("NOVIF",{"virtual interface must be set  for :",get_full_name(),".vif"})
   endfunction // checkCsrProbeIf

    task pre_body();
        $cast(m_regs,model);
    endtask
////////////////////////////////////////////////////////////////////////////////
//
// Common functions at the top
//
////////////////////////////////////////////////////////////////////////////////
   function compareValues(string one, string two, int data1, int data2);
      if (data1 == data2) begin
         `uvm_info("RUN_MAIN",$sformatf("%s:0x%x, expd %s:0x%0x OKAY", one, data1, two, data2), UVM_MEDIUM)
      end else begin
         `uvm_error("RUN_MAIN",$sformatf("Mismatch %s:0x%0x, expd %s:0x%0x",one, data1, two, data2));
      end
   endfunction // compareValues

 function uvm_reg_data_t mask_data(int lsb, int msb);
     uvm_reg_data_t mask_data_val = 0;

     for(int i=0;i<32;i++)begin
        if(i>=lsb &&  i<=msb)begin
          mask_data_val[i] = 1;     
        end
     end
    //$display("func maskdataval:0x%0x",mask_data_val);
    return mask_data_val;
  endfunction:mask_data

/*
<%
  var fnType = ["write", "read", "poll"];
  var regName = [];
  var fieldName = [[]];
  var fieldList = [];

regName.push("CECR");
regName.push("CESR");
regName.push("CELR0");
regName.push("CELR1");
regName.push("CESAR");
regName.push("UECR");
regName.push("UESR");
regName.push("UELR0");
regName.push("UELR1");
regName.push("UESAR");

var fieldName = new Array(regName.length);
for (var i=0; i < regName.length; i++) {
     fieldName[i] = new Array(5);
  }

fieldName[0] = ["ErrDetEn","ErrIntEn","ErrThreshold","Null","Null"];
fieldName[1] = ["ErrVld","ErrOvf","ErrCount","ErrType","ErrInfo"];
fieldName[2] = ["ErrEntry","ErrWay","ErrWord","Null","Null"];
fieldName[3] = ["ErrAddr","Null","Null","Null","Null"];
fieldName[4] = ["ErrVld","ErrOvf","ErrCount","ErrType","ErrInfo"];

fieldName[5] = ["ErrDetEn","ErrIntEn","ErrThreshold","Null","Null"];
fieldName[6] = ["ErrVld","ErrOvf","ErrCount","ErrType","ErrInfo"];
fieldName[7] = ["ErrEntry","ErrWay","ErrWord","Null","Null"];
fieldName[8] = ["ErrAddr","Null","Null","Null","Null"];
fieldName[9] = ["ErrVld","ErrOvf","ErrCount","ErrType","ErrInfo"];

for (var i=0;i < regName.length; i++) {
  for (var j=0; j < fieldName[i].length; j++) {
    if (fieldName[i][j] != "Null") { %>
      task write_CMIU<%=regName[i]%>_<%=fieldName[i][j]%>(uvm_reg_data_t wr_data);
        int lsb, msb;
        uvm_reg_data_t mask;
        m_regs.cmiu.CMIU<%=regName[i]%>.read(status, field_rd_data, .parent(this));
        lsb = m_regs.cmiu.CMIU<%=regName[i]%>.<%=fieldName[i][j]%>.get_lsb_pos();
        msb = lsb + m_regs.cmiu.CMIU<%=regName[i]%>.<%=fieldName[i][j]%>.get_n_bits() - 1;
        `uvm_info("CSR Ralgen Base Seq", $sformatf("Write CMIU<%=regName[i]%>_<%=fieldName[i][j]%> lsb=%0d msb=%0d",lsb, msb), UVM_MEDIUM);
        // and with actual field bits 0
        mask = mask_data(lsb, msb);
        //$display("mask:0x%0x",mask);
        mask = ~mask;
        field_rd_data = field_rd_data & mask;
        // shift write data to appropriate position
        wr_data = wr_data << lsb;
        // then or with this data to get value to write
        wr_data = field_rd_data | wr_data;
        m_regs.cmiu.CMIU<%=regName[i]%>.write(status, wr_data, .parent(this));
      endtask //write_CMIU<%=regName[i]%>_<%=fieldName[i][j]%>

      task read_CMIU<%=regName[i]%>_<%=fieldName[i][j]%>(output uvm_reg_data_t fieldVal);
        int lsb, msb;
        uvm_reg_data_t mask;
        m_regs.cmiu.CMIU<%=regName[i]%>.read(status, field_rd_data, .parent(this));
        lsb = m_regs.cmiu.CMIU<%=regName[i]%>.<%=fieldName[i][j]%>.get_lsb_pos();
        msb = lsb + m_regs.cmiu.CMIU<%=regName[i]%>.<%=fieldName[i][j]%>.get_n_bits() - 1;
        `uvm_info("CSR Ralgen Base Seq", $sformatf("Read CMIU<%=regName[i]%>_<%=fieldName[i][j]%> lsb=%0d msb=%0d",lsb, msb), UVM_MEDIUM);
        //$display("rd_data:0x%0x",field_rd_data);
        // AND other bits to 0
        mask = mask_data(lsb, msb);
        //$display("mask:0x%0x",mask);
        field_rd_data = field_rd_data & mask;
        //$display("masked data:0x%0x",field_rd_data);
        // shift read data by lsb to return field
        fieldVal = field_rd_data >> lsb;
        //$display("fieldVal:0x%0x",fieldVal);
      endtask //read_CMIU<%=regName[i]%>_<%=fieldName[i][j]%>

      task poll_CMIU<%=regName[i]%>_<%=fieldName[i][j]%>(bit [31:0] poll_till, output uvm_reg_data_t fieldVal);
        int timeout;
        timeout = 5000;
        do begin
          //m_regs.cmiu.CMIU<%=regName[i]%>.read(status, field_rd_data, .parent(this));
          timeout -=1;
          read_CMIU<%=regName[i]%>_<%=fieldName[i][j]%>(fieldVal);
          //m_regs.cmiu.CMIU<%=regName[i]%>.<%=fieldName[i][j]%>.read(status, field_rd_data, .parent(this));
          //fieldVal = field_rd_data;
          `uvm_info("CSR Ralgen Base Seq", $sformatf("CMIU<%=regName[i]%>_<%=fieldName[i][j]%> poll_till=0x%0x fieldVal=0x%0x timeout=%0d",poll_till, fieldVal, timeout), UVM_MEDIUM);

        end while ((fieldVal < poll_till) && (timeout != 0)); // UNMATCHED !!
        if (timeout == 0) begin
          `uvm_error("CSR Ralgen Base Seq", $sformatf("Timeout! Polling CMIU<%=regName[i]%>_<%=fieldName[i][j]%>, poll_till=0x%0x fieldVal=0x%0x",poll_till, fieldVal))
        end
      endtask //poll_CMIU<%=regName[i]%>_<%=fieldName[i][j]%>
<%  }
  }
}
%>
*/
endclass : dmi_csr_ralgen_base_seq

/*
//-----------------------------------------------------------------------
//  Task    : 
//  Purpose : 
//
//-----------------------------------------------------------------------
class dmi_reginit_seq extends dmi_csr_ralgen_base_seq; 
  `uvm_object_utils(dmi_reginit_seq)

    //string spkt;
    uvm_reg_data_t write_data;

    function new(string name="");
        super.new(name);
    endfunction

    task body();
          write_data = 1;

          write_CMIUUECR_ErrDetEn(write_data);

        `uvm_info("body", "Exiting init seq", UVM_MEDIUM)
    endtask
endclass : dmi_reginit_seq


//-----------------------------------------------------------------------
//  Task    : 
//  Purpose : 
//
//-----------------------------------------------------------------------
class dmi_csr_cmiucecr_errCntOvf_seq extends dmi_csr_ralgen_base_seq; 
  `uvm_object_utils(dmi_csr_cmiucecr_errCntOvf_seq)

    uvm_reg_data_t poll_data, read_data, read_data2, write_data;
    bit [7:0]  errthd;
    int        errcount_vld, errthd_vld;
    int        errcount_ovf;
    bit [3:0] errtype;

    function new(string name="");
        super.new(name);
    endfunction

    task body();

<% if(rttCorr) { %>
        `uvm_info("RUN_MAIN",$sformatf("Entered Test loop"), UVM_LOW)

           if ($test$plusargs("ccp_single_bit_data_error_test") || $test$plusargs("ccp_single_bit_tag_error_test"))
             errtype = 4'h7;
           else
             errtype = 4'h6;
             
          //#Test.DMI.ErrVldErrOvfNotResetW1CIfClr
          // Try Set the CMIUCESR_ErrVld = 1. Shouldn't work as this field is W1C
          write_data = 1;
          write_CMIUCESR_ErrVld(write_data);
          read_CMIUCESR_ErrVld(read_data);
          compareValues("CMIUCESR_ErrVld","Should be 0", read_data, 0);

          write_CMIUCESR_ErrOvf(write_data);
          read_CMIUCESR_ErrOvf(read_data);
          compareValues("CMIUCESR_ErrVld","Should be 0", read_data, 0);

          errthd = $urandom_range(1,1);
          write_data = errthd;
         // Set the CMIUCECR_ErrThreshold 
          write_CMIUCECR_ErrThreshold(write_data);
         // Set the CMIUCECR_ErrDetEn = 1
          //#Check.DMI.DetectEnSet
          write_data = 1;
          write_CMIUCECR_ErrDetEn(write_data);
         // Set the CMIUCECR_ErrIntEn = 1
          write_CMIUCECR_ErrIntEn(write_data);
         // write  CMIUCESR_ErrVld = 1 , to reset it
          write_CMIUCESR_ErrVld(write_data);

        ///////////////////////////////////////////////////////////

        //keep on  Reading the CMIUCESR_ErrVld bit = 1
          poll_CMIUCESR_ErrVld(1, poll_data);
          read_CMIUCESR_ErrOvf(read_data);
          compareValues("CMIUCESR_ErrVld", "set", poll_data, 1);
          //compareValues("CMIUCESR_ErrOvf", "not set yet", read_data, 0);

          read_CMIUCESR_ErrType(read_data);
          compareValues("CMIUCESR_ErrType","Valid Type", read_data, errtype);

          read_CMIUCECR_ErrThreshold(read_data);
          read_CMIUCESR_ErrCount(read_data2);
          compareValues("CMIUCESR_ErrCount","CMIUCECR_ErrThreshold", read_data2, read_data);

          errcount_vld = read_data2;
          errthd_vld = read_data;

        //keep on  Reading the CMIUCESR_ErrcountOvf bit = 1 
          poll_CMIUCESR_ErrOvf(1, poll_data);
          read_CMIUCESR_ErrVld(read_data);
          compareValues("CMIUCESR_ErrVld", "set", poll_data, 1);

          read_CMIUCESR_ErrCount(read_data2);
          compareValues("CMIUCESR_ErrCount", "Older Errcount with Vld Set", read_data2, errcount_vld);
          compareValues("CMIUCESR_ErrCount","Older CMIUCECR_ErrThreshold", read_data2, errthd_vld);

          // freeze count after valid is set
          errcount_ovf = read_data2; 
          compareValues("Ovf count","Older count", errcount_ovf, errcount_vld);

          read_CMIUCESR_ErrType(read_data);
          compareValues("CMIUCESR_ErrType","Valid Type", read_data, errtype);

        // Read CMIUCESAR_ErrVld , it should be 1
          read_CMIUCESAR_ErrVld(read_data);
          compareValues("CMIUESAR_ErrVld", "set", read_data, 1);

          //#Test.DMI.ESARWriteUpdatesESR
          read_CMIUCESR_ErrType(read_data);
          compareValues("CMIUCESR_ErrType","Valid Type", read_data, errtype);

        // Reset the CMIUCECR_ErrDetEn = 0
          write_data = 0;
          write_CMIUCECR_ErrDetEn(write_data);

        // write  CMIUCESAR_ErrVld = 0 , to reset it
          write_CMIUCESAR_ErrVld(write_data);

          //#Test.DMI.ESARWriteUpdatesESR
        // Read CMIUCESR_ErrVld , it should be 0
          read_CMIUCESR_ErrVld(read_data);
          compareValues("CMICESR_ErrVld", "cleared previously", read_data, 0);
          read_CMIUCESR_ErrType(read_data);
          compareValues("CMIUCESR_ErrType","Valid Type", read_data, errtype); // type isn't cleared without explicit write

        // Read CMIUCESAR_ErrVld , it should also be 0, because it is alias of register
        // CMIUCESR_ErrVld
          read_CMIUCESAR_ErrVld(read_data);
          compareValues("CMIUESAR_ErrVld", "cleared previously", read_data, 0);
          read_CMIUCESAR_ErrType(read_data);
          compareValues("CMIUCESAR_ErrType","Valid Type", read_data, errtype);

        // Read CMIUCESR_ErrOvf , it should be 1
          read_CMIUCESR_ErrOvf(read_data);
          compareValues("CMIUCESR_ErrOvf", "still set", read_data, 1);

        // write  CMIUCESR_ErrOvf = 1 , to reset it
          write_data = 1;
          write_CMIUCESR_ErrOvf(write_data);

        // Read CMIUCESR_ErrOvf , it should be 0
          read_CMIUCESR_ErrOvf(read_data);
          compareValues("CMIUCESR_ErrOvf", "now clear", read_data, 0);
          //read_CMIUCESR_ErrCount(read_data); // Since write was to ESAR, this is not reset
          //compareValues("CMIUCESR_ErrCount","cleared", read_data, 0);
        // Read CMIUCESAR_ErrOvf , it should be 0
          read_CMIUCESAR_ErrOvf(read_data);
          compareValues("CMIUCESAR_ErrOvf", "now clear", read_data, 0);

          write_data = 0;
          write_CMIUCESAR_ErrCount(read_data);
          read_CMIUCESAR_ErrCount(read_data);
          compareValues("CMIUCESAR_ErrCount","cleared", read_data, 0);

        // write  CMIUCESAR_ErrVld = 1 , to set it
          write_data = 1;
          write_CMIUCESAR_ErrVld(write_data);

          //#Test.DMI.ESARWriteUpdatesESR
        // write  CMIUCESR_ErrVld = 1 , to reset it
          write_data = 1;
          write_CMIUCESR_ErrVld(write_data);

        // Read CMIUCESAR_ErrOvf , it should be 0
          read_CMIUCESAR_ErrOvf(read_data);
          compareValues("CMIUCESAR_ErrOvf", "clear", read_data, 0);
          read_CMIUCESAR_ErrCount(read_data);
          compareValues("CMIUCESAR_ErrCount","cleared", read_data, 0);

<% } else { %>
        // Read the CMIUCESR_ErrVld bit = 0
          read_CMIUCESR_ErrVld(read_data);
          compareValues("CMIUESR_ErrVld", "RAZ/WI", read_data, 0);
        // Read the CMIUCESR_ErrcountOvf bit = 0 
          read_CMIUCESR_ErrOvf(read_data);
          compareValues("CMIUCESR_ErrOvf", "RAZ/WI", read_data, 0);
        // Read CMIUCESAR_ErrVld , it should be 0
          read_CMIUCESAR_ErrVld(read_data);
          compareValues("CMIUESAR_ErrVld", "RAZ/WI", read_data, 0);
          read_CMIUCESAR_ErrType(read_data);
          compareValues("CMIUCESAR_ErrType","RAZ/WI", read_data, 0);
          //#Test.DMI.ESARWriteUpdatesESR
        // Read CMIUCESR_ErrVld , it should be 0
          read_CMIUCESR_ErrOvf(read_data);
          compareValues("CMIUCESR_ErrOvf", "RAZ/WI", read_data, 0);
        // Read CMIUCESAR_ErrVld , it should also be 0, because it is alias of register
          read_CMIUCESAR_ErrOvf(read_data);
          compareValues("CMIUCESAR_ErrOvf", "RAZ/WI", read_data, 0);

<% } %>
    endtask
endclass : dmi_csr_cmiucecr_errCntOvf_seq

//-----------------------------------------------------------------------
//  Task    : 
//  Purpose : 
//
//-----------------------------------------------------------------------
class dmi_csr_cmiucecr_errDetEn_seq extends dmi_csr_ralgen_base_seq; 
  `uvm_object_utils(dmi_csr_cmiucecr_errDetEn_seq)

    uvm_reg_data_t poll_data, read_data, read_data2, write_data;
    bit [7:0]  errthd;
    int        errcount_vld, errthd_vld;
    int        errcount_ovf;

    function new(string name="");
        super.new(name);
    endfunction

    task body();

<% if(rttCorr) { %>
           // Set the CMIUCECR_ErrDetEn = 1
           write_data = 1;
           write_CMIUCECR_ErrDetEn(write_data);
           //keep on  Reading the CMIUCESR_ErrVld bit = 1
           poll_CMIUCESR_ErrVld(1, poll_data);
           // Read CMIUCESAR_ErrVld , it should be 1
           read_CMIUCESAR_ErrVld(read_data);
           compareValues("CMIUCESAR_ErrVld", "set", read_data, 1);
           // Set the CMIUCECR_ErrDetEn = 0, to diable the error detection
           write_data = 0;
           write_CMIUCECR_ErrDetEn(write_data);
           // Read CMIUCESR_ErrVld , it should be 1
           read_CMIUCESR_ErrVld(read_data);
           compareValues("CMIUCESR_ErrVld", "set", read_data, 1);
           // Read CMIUCESR_ErrVld , it should be 1
           read_CMIUCESR_ErrVld(read_data);
           compareValues("CMIUCESR_ErrVld", "set", read_data, 1);
           // Read CMIUCESAR_ErrVld , it should be 1
           read_CMIUCESAR_ErrVld(read_data);
           compareValues("CMIUCESAR_ErrVld", "set", read_data, 1);
           // write  CMIUCESR_ErrVld = 1 , W1C
           write_data = 1;
           write_CMIUCESR_ErrVld(write_data);
           // Read the CMIUCESR_ErrVld should be cleared
           read_CMIUCESR_ErrVld(read_data);
           compareValues("CMIUCESR_ErrVld", "now clear", read_data, 0);
           // Read CMIUCESAR_ErrVld , it should also clear, beacuse it is alias register
           // of register CMIUCESR_*
           read_CMIUCESAR_ErrVld(read_data);
           compareValues("CMIUCESAR_ErrVld", "now clear", read_data, 0);
<% } else { %>
           // Read the CMIUCESR_ErrVld should be clear
           read_CMIUCESR_ErrVld(read_data);
           compareValues("CMIUESR_ErrVld", "RAZ/WI", read_data, 0);
           // Read CMIUCESAR_ErrVld , it should also clear, beacuse it is alias register
           // of register CMIUCESR_*
           read_CMIUCESAR_ErrVld(read_data);
           compareValues("CMIUESAR_ErrVld", "RAZ/WI", read_data, 0);
<% } %>
    endtask
endclass : dmi_csr_cmiucecr_errDetEn_seq

//-----------------------------------------------------------------------
//  Task    : 
//  Purpose : 
//
//-----------------------------------------------------------------------
//#Check.DMI.ErrIntEnCorrErrs
class dmi_csr_cmiucecr_errInt_seq extends dmi_csr_ralgen_base_seq; 
  `uvm_object_utils(dmi_csr_cmiucecr_errInt_seq)

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
<% if(rttCorr) { %>
           // Set the CMIUCECR_ErrThreshold 
          errthd = $urandom_range(1,1);

           if ($test$plusargs("ccp_single_bit_data_error_test") || $test$plusargs("ccp_single_bit_tag_error_test"))
             errtype = 4'h7;
           else
             errtype = 4'h6;

           write_data = errthd;
           write_CMIUCECR_ErrThreshold(write_data);
           // Set the CMIUCECR_ErrDetEn = 1
           write_data = 1;
           write_CMIUCECR_ErrDetEn(write_data);
           // Set the CMIUCECR_ErrIntEn = 1
           write_CMIUCECR_ErrIntEn(write_data);
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
           // Read the CMIUCESR_ErrVld
           read_CMIUCESR_ErrVld(read_data);
           compareValues("CMIUCESR_ErrVld", "set after inte", read_data, 1);
           read_CMIUCESR_ErrType(read_data);
           compareValues("CMIUCESR_ErrType","Valid Type", read_data, errtype);
           read_CMIUCESR_ErrCount(read_data);
           compareValues("CMIUCESR_ErrCount","CMIUCECR_ErrThreshold", read_data, errthd);
           // Read CMIUCESAR_ErrVld , it should have same as  CMIUCESR_*
           read_CMIUCESAR_ErrVld(read_data);
           compareValues("CMIUCESAR_ErrVld", "set after inte", read_data, 1);
           read_CMIUCESAR_ErrType(read_data);
           compareValues("CMIUCESAR_ErrType","Valid Type", read_data, errtype);
           read_CMIUCESAR_ErrCount(read_data);
           compareValues("CMIUCESAR_ErrCount","CMIUCECR_ErrThreshold", read_data, errthd);
           // Set the CMIUCECR_ErrDetEn = 0, to disable the error detection
           write_data = 0;
           write_CMIUCECR_ErrDetEn(write_data);
           // Set the CMIUCECR_ErrIntEn = 0, to disable the error Interrupt
           write_CMIUCECR_ErrIntEn(write_data);
           // write CMIUCESR_ErrVld = 1 to clear it
           write_data = 1;
           write_CMIUCESR_ErrVld(write_data);
           // Read CMIUCESR_ErrVld , it should be 0
           read_CMIUCESR_ErrVld(read_data);
           compareValues("CMIUCESR_ErrVld", "reset", read_data, 0);
           // Read CMIUCESAR_ErrVld , it should be 0
           read_CMIUCESAR_ErrVld(read_data);
           compareValues("CMIUCESAR_ErrVld", "reset", read_data, 0);
           // Monitor IRQ_C pin , it should be 0 now
           if(u_csr_probe_vif.IRQ_C == 0)begin
             `uvm_info("RUN_MAIN",$sformatf("IRQ_C interrupted de-asseretd"), UVM_LOW)
           end else begin
             `uvm_error("RUN_MAIN",$sformatf("IRQ_C interruped still aseerted"));
           end
<% } else { %>
          // Read CMIUCESR_ErrVld , it should be 0
           read_CMIUCESR_ErrVld(read_data);
           compareValues("CMIUCESR_ErrVld", "set", read_data, 0);
          // Read CMIUCESAR_ErrVld , it should be 0
           read_CMIUCESAR_ErrVld(read_data);
           compareValues("CMIUCESAR_ErrVld", "set", read_data, 0);
          // Monitor IRQ_C pin , it should be 0 now
          if(u_csr_probe_vif.IRQ_C == 0)begin
             `uvm_info("RUN_MAIN",$sformatf("IRQ_C interrupted de-asseretd"), UVM_LOW)
          end else begin
             `uvm_error("RUN_MAIN",$sformatf("IRQ_C interruped still asserted"));
          end
<% } %>
    endtask
endclass : dmi_csr_cmiucecr_errInt_seq

//-----------------------------------------------------------------------
//  Task    : 
//  Purpose : 
//
//-----------------------------------------------------------------------
class dmi_csr_cmiucecr_errThd_seq extends dmi_csr_ralgen_base_seq; 
  `uvm_object_utils(dmi_csr_cmiucecr_errThd_seq)

    uvm_reg_data_t poll_data, read_data, read_data2, write_data;
    bit [7:0]  errthd;
    int        errcount_vld, errthd_vld;
    int        errcount_ovf;

    function new(string name="");
        super.new(name);
    endfunction

    task body();

       //getCsrProbeIf();
<% if(rttCorr) { %>
          // Set the CMIUCECR_ErrThreshold 
          errthd = $urandom_range(1,1);
          write_data = errthd;
          write_CMIUCECR_ErrThreshold(write_data);
          // Set the CMIUCECR_ErrDetEn = 1
          write_data = 1;
          write_CMIUCECR_ErrDetEn(write_data);
          // Set the CMIUCECR_ErrIntEn = 1
          write_CMIUCECR_ErrIntEn(write_data);
          // write  CMIUCESR_ErrVld = 1 , to reset it
          write_CMIUCESR_ErrVld(write_data);
          //keep on  Reading the CMIUCESR_ErrVld bit = 1 
          poll_CMIUCESR_ErrVld(1, poll_data);
          // Read CMIUCESR_ErrCount , it should be at errthd
          read_CMIUCESR_ErrCount(read_data);
          compareValues("CMIUCESR_ErrCount","ErrThreshold", read_data, errthd);
          // Read alias field  CMIUCESAR_ErrCount , should match
          read_CMIUCESAR_ErrCount(read_data);
          compareValues("CMIUCESAR_ErrCount","ErrThreshold", read_data, errthd);
          // Set the CMIUCECR_ErrDetEn = 0
          write_data = 0;
          write_CMIUCECR_ErrDetEn(write_data);
          // write : CMIUCESR_ErrVld = 1 , to reset it
          write_data = 1;
          write_CMIUCESR_ErrVld(write_data);
          // Read CMIUCESAR_ErrVld , it should be 0
          read_CMIUCESAR_ErrVld(read_data);
          compareValues("CMIUCESAR_ErrVld", "now clear", read_data, 0);
          //#Test.DMI.ESARWriteUpdatesESR
          // Read CMIUCESR_ErrVld , it should be 0
          read_CMIUCESR_ErrVld(read_data);
          compareValues("CMIUCESR_ErrVld", "now clear", read_data, 0);
<% } else { %>
        // Read CMIUCESR_ErrCount , it should be 0
          read_CMIUCESR_ErrCount(read_data);
          compareValues("CMIUCESR_ErrCount","RAZ/WI", read_data, 0);
<% } %>
    endtask
endclass : dmi_csr_cmiucecr_errThd_seq

//-----------------------------------------------------------------------
//  Task    : 
//  Purpose : 
//
//-----------------------------------------------------------------------
//#Test.DMI.ErrInjWhileSoftwareWriteHappens
class dmi_csr_cmiucecr_sw_write_seq extends dmi_csr_ralgen_base_seq; 
  `uvm_object_utils(dmi_csr_cmiucecr_sw_write_seq)

   uvm_reg_data_t poll_data, read_data, read_data2, write_data;
   bit [7:0]  errthd;
   int        errcount_vld, errthd_vld;
   int        i;

    function new(string name="");
        super.new(name);
    endfunction

   task body();

       //getCsrProbeIf();
<% if(rttCorr) { %>
          // Set the CMIUCECR_ErrThreshold 
          errthd = 1;
          write_CMIUCECR_ErrThreshold(write_data);
          // Set the CMIUCECR_ErrDetEn = 1
          write_data = 1;
          write_CMIUCECR_ErrDetEn(write_data);
          // write  CMIUCESR_ErrVld = 1 , to reset it
          write_CMIUCESR_ErrVld(write_data);
          write_data = 0;
          for (i=0;i<100;i++) begin
             write_CMIUCESAR_ErrVld(write_data);
          end
          // Set the CMIUCECR_ErrDetEn = 0
          write_data = 0;
          write_CMIUCECR_ErrDetEn(write_data);
          // if vld is set, reset it
          read_CMIUCESR_ErrVld(read_data);
          if(read_data) begin
             write_CMIUCESAR_ErrVld(write_data);
          end
<% } %>
    endtask
endclass : dmi_csr_cmiucecr_sw_write_seq

//-----------------------------------------------------------------------
//  Task    : 
//  Purpose : 
//
//-----------------------------------------------------------------------
//#Test.DMI.DetectEnNotSetErrorsInjected
class dmi_csr_cmiucecr_noDetEn_seq extends dmi_csr_ralgen_base_seq; 
  `uvm_object_utils(dmi_csr_cmiucecr_noDetEn_seq)

    uvm_reg_data_t poll_data, read_data, read_data2, write_data;
    bit [7:0]  errthd;
    int        errcount_vld, errthd_vld;
    int        errcount_ovf;

    function new(string name="");
        super.new(name);
    endfunction

    task body();

       //getCsrProbeIf();
<% if(rttCorr) { %>
          // Don't Set the CMIUCECR_ErrDetEn = 1
          //Reading the CMIUCESR_ErrVld bit = 0
          read_CMIUCESR_ErrVld(read_data);
          compareValues("CMIUCESR_ErrVld", "not set", read_data, 0);
          // Read CMIUCESR_ErrCount , it should be at 0
          read_CMIUCESR_ErrCount(read_data);
          compareValues("CMIUCESR_ErrCount","not set", read_data, 0);
          // Read alias field  CMIUCESAR_ErrCount , should match
          read_CMIUCESAR_ErrCount(read_data);
          compareValues("CMIUCESAR_ErrCount","not set", read_data, 0);
<% } else { %>
        // Read the CMIUCESR_ErrVld should be cleared
          read_CMIUCESR_ErrVld(read_data);
          compareValues("CMIUCESR_ErrVld", "not set", read_data, 0);
        // Read CMIUCESAR_ErrVld , it should also clear, beacuse it is alias register
        // of register CMIUCESR_*
          read_CMIUCESAR_ErrVld(read_data);
          compareValues("CMIUCESAR_ErrVld", "not set", read_data, 0);
<% } %>
    endtask
endclass : dmi_csr_cmiucecr_noDetEn_seq

//-----------------------------------------------------------------------
//  Task    : 
//  Purpose : 
//
//-----------------------------------------------------------------------
class dmi_csr_cmiucecr_noIntEn_seq extends dmi_csr_ralgen_base_seq; 
  `uvm_object_utils(dmi_csr_cmiucecr_noIntEn_seq)

    uvm_reg_data_t poll_data, read_data, read_data2, write_data;
    bit [7:0]  errthd;
    int        errcount_vld, errthd_vld;
    int        errcount_ovf;

    function new(string name="");
        super.new(name);
    endfunction

    task body();

       getCsrProbeIf();
<% if(rttCorr) { %>
          // Set the CMIUCECR_ErrThreshold 
          write_data = 1;
          write_CMIUCECR_ErrThreshold(write_data);
          // Set the CMIUCECR_ErrDetEn = 1
          write_CMIUCECR_ErrDetEn(write_data);
          // Dont Set the CMIUCECR_ErrIntEn = 1
          // wait for IRQ_C interrupt for a while. Shouldn't happen. Then join
          //#Cov.DMI.ErrIntDisEnCorrErrs
          fork
            begin
             `uvm_info("RUN_MAIN",$sformatf("Waiting for interrupt. It shouldn't happen"), UVM_LOW)
             @(u_csr_probe_vif.IRQ_C);
             `uvm_error("RUN_MAIN", $sformatf("Unexpected interrupt! IntEn is not set"));
            end
            begin
             #50000ns;
             `uvm_info("RUN_MAIN",$sformatf("Done waiting. No interrupt received"), UVM_LOW)
            end
          join_any
          disable fork;
          //Reading the CMIUCESR_ErrVld bit = 1
          read_CMIUCESR_ErrVld(read_data);
          compareValues("CMIUCESR_ErrVld", "set", read_data, 1);
          // write CMIUCESR_ErrVld = 1 to clear it
          write_data = 1;
          write_CMIUCESR_ErrVld(write_data);
          write_CMIUCESR_ErrOvf(write_data);
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
endclass : dmi_csr_cmiucecr_noIntEn_seq

//-----------------------------------------------------------------------
//  Task    : 
//  Purpose : To test writing to Vld bit when it is not set doesn't affect count
//
//-----------------------------------------------------------------------
class dmi_csr_cmiucesr_rstNoVld_seq1 extends dmi_csr_ralgen_base_seq; 
  `uvm_object_utils(dmi_csr_cmiucesr_rstNoVld_seq1)

    uvm_reg_data_t poll_data, read_data, read_data2, write_data;
    bit [7:0]  errthd;
    int        errcount_vld, errthd_vld;
    int        errentry, errway, errword, erraddr;

    function new(string name="");
        super.new(name);
    endfunction

    task body();

<% if(rttCorr) { %>
        `uvm_info("RUN_MAIN",$sformatf("Entered Test loop"), UVM_LOW)
        //repeat(5)
         //begin
          //#Test.DMI.ErrVldErrOvfNotResetW1CIfClr
          // Try Set the CMIUCESR_ErrVld = 1. Shouldn't work as this field is W1C
          write_data = 1;
          write_CMIUCESR_ErrVld(write_data);
          read_CMIUCESR_ErrVld(read_data);
          compareValues("CMIUCESR_ErrVld","Should be 0", read_data, 0);

          write_CMIUCESR_ErrOvf(write_data);
          read_CMIUCESR_ErrOvf(read_data);
          compareValues("CMIUCESR_ErrVld","Should be 0", read_data, 0);

          //assert(randomize(errthd));
          errthd = 10;
          write_data = errthd;
          // Set the CMIUCECR_ErrThreshold 
          write_CMIUCECR_ErrThreshold(write_data);
          // Set the CMIUCECR_ErrDetEn = 1
          write_data = 1;
          write_CMIUCECR_ErrDetEn(write_data);
        //end
<% } %>
    endtask
endclass : dmi_csr_cmiucesr_rstNoVld_seq1

class dmi_csr_cmiucesr_rstNoVld_seq2 extends dmi_csr_ralgen_base_seq; 
  `uvm_object_utils(dmi_csr_cmiucesr_rstNoVld_seq2)

    uvm_reg_data_t poll_data, read_data, read_data2, write_data;
    bit [7:0]  errthd;
    int        errcount, errthd_vld;
    int        errentry, errway, errword, erraddr;

    function new(string name="");
        super.new(name);
    endfunction

    task body();

          //keep on  Reading the CMIUCESR_ErrCount bit = 1
<% if(rttCorr) { %>
          poll_CMIUCESR_ErrCount(1, poll_data);
          read_CMIUCESR_ErrVld(read_data);
          compareValues("CMIUCESR_ErrVld", "not set yer", read_data, 0);
          read_CMIUCESR_ErrOvf(read_data);
          compareValues("CMIUCESR_ErrOvf", "not set yet", read_data, 0);

          //write_data = 0;
          //write_CMIUCECR_ErrDetEn(write_data);

          //readCompareCELR(0);

          //#Test.DMI.ErrVldErrOvfNotResetW1CIfClr
          write_data = 1;
          write_CMIUCESR_ErrVld(write_data);
          read_CMIUCESR_ErrVld(read_data);
          compareValues("CMIUCESR_ErrVld","Should be 0", read_data, 0);
          write_CMIUCESR_ErrOvf(write_data);
          read_CMIUCESR_ErrOvf(read_data);
          compareValues("CMIUCESR_ErrVld","Should be 0", read_data, 0);
<% } %>
    endtask
endclass : dmi_csr_cmiucesr_rstNoVld_seq2

class dmi_csr_cmiucesr_rstNoVld_seq3 extends dmi_csr_ralgen_base_seq; 
  `uvm_object_utils(dmi_csr_cmiucesr_rstNoVld_seq3)

    uvm_reg_data_t poll_data, read_data, read_data2, write_data;
    bit [7:0]  errthd;
    int        errcount_vld, errthd_vld;
    int        errentry, errway, errword, erraddr;

    function new(string name="");
        super.new(name);
    endfunction

    task body();

          //keep on  Reading the CMIUCESR_ErrCount bit = 1
<% if(rttCorr) { %>
          poll_CMIUCESR_ErrCount(1, poll_data);
          read_CMIUCESR_ErrVld(read_data);
          compareValues("CMIUCESR_ErrVld", "not set yer", read_data, 0);
          read_CMIUCESR_ErrOvf(read_data);
          compareValues("CMIUCESR_ErrOvf", "not set yet", read_data, 0);

          //readCompareCELR(0);

          //#Test.DMI.ErrVldErrOvfNotResetW1CIfClr
          write_data = 1;
          write_CMIUCESR_ErrVld(write_data);
          read_CMIUCESR_ErrVld(read_data);
          compareValues("CMIUCESR_ErrVld","Should be 0", read_data, 0);
          write_CMIUCESR_ErrOvf(write_data);
          read_CMIUCESR_ErrOvf(read_data);
          compareValues("CMIUCESR_ErrVld","Should be 0", read_data, 0);

          read_CMIUCESR_ErrCount(read_data);
          compareValues("CMIUCESR_ErrCount", "not reset", read_data, 1);

<% } %>
    endtask
endclass : dmi_csr_cmiucesr_rstNoVld_seq3


//-----------------------------------------------------------------------
//  Task    : 
//  Purpose : 
//
//-----------------------------------------------------------------------
class dmi_csr_cmiucelr_seq1 extends dmi_csr_ralgen_base_seq; 
  `uvm_object_utils(dmi_csr_cmiucelr_seq1)

    uvm_reg_data_t poll_data, read_data, read_data2, write_data;
    bit [7:0]  errthd;
    int        errcount_vld, errthd_vld;
    int        errentry, errway, errword, erraddr;

    function new(string name="");
        super.new(name);
    endfunction

    task body();

<% if(rttCorr) { %>
        `uvm_info("RUN_MAIN",$sformatf("Entered Test loop"), UVM_LOW)
          //#Test.DMI.ErrVldErrOvfNotResetW1CIfClr
          // Try Set the CMIUCESR_ErrVld = 1. Shouldn't work as this field is W1C
          //#Check.DMI.DetectEnSet
          write_data = 1;
          write_CMIUCESR_ErrVld(write_data);
          read_CMIUCESR_ErrVld(read_data);
          compareValues("CMIUCESR_ErrVld","Should be 0", read_data, 0);

          write_CMIUCESR_ErrOvf(write_data);
          read_CMIUCESR_ErrOvf(read_data);
          compareValues("CMIUCESR_ErrVld","Should be 0", read_data, 0);

          //assert(randomize(errthd));
          errthd = 1; // TODO: Randomize
          write_data = errthd;
          // Set the CMIUCECR_ErrThreshold
          write_CMIUCECR_ErrThreshold(write_data);
          // Set the CMIUCECR_ErrDetEn = 1
          write_data = 1;
          write_CMIUCECR_ErrDetEn(write_data);
<% } %>
    endtask
endclass : dmi_csr_cmiucelr_seq1

class dmi_csr_cmiucelr_seq11 extends dmi_csr_ralgen_base_seq; 
  `uvm_object_utils(dmi_csr_cmiucelr_seq11)

    uvm_reg_data_t poll_data, read_data, read_data2, write_data;
    bit [7:0]  errthd;
    int        errcount_vld, errthd_vld;
    int        errentry, errway, errword, erraddr;

    function new(string name="");
        super.new(name);
    endfunction

    task body();

<% if(rttCorr) { %>
        `uvm_info("RUN_MAIN",$sformatf("Entered Test loop"), UVM_LOW)
          //keep on  Reading the CMIUCESR_ErrCount bit = 1
          poll_CMIUCESR_ErrCount(1, poll_data);
<% } %>
    endtask
endclass : dmi_csr_cmiucelr_seq11

class dmi_csr_cmiucelr_seq2 extends dmi_csr_ralgen_base_seq; 
  `uvm_object_utils(dmi_csr_cmiucelr_seq2)

    uvm_reg_data_t poll_data, read_data, read_data2, write_data;
    bit [7:0]  errthd;
    int        errcount_vld, errthd_vld;
    int        errentry, errway, errword, erraddr;

    function new(string name="");
        super.new(name);
    endfunction

    task body();

<% if(rttCorr) { %>
        `uvm_info("RUN_MAIN",$sformatf("Entered Test loop"), UVM_LOW)
          poll_CMIUCESR_ErrVld(1, poll_data);
          read_CMIUCESR_ErrOvf(read_data);
          //compareValues("CMIUCESR_ErrOvf", "not set yet", read_data, 0);
          `uvm_info("RUN_MAIN",$sformatf("ErrOvf field=%0x", read_data), UVM_LOW)

          read_CMIUCELR0_ErrEntry(read_data);
          errentry = read_data;
          read_CMIUCELR0_ErrWay(read_data);
          errway = read_data;
          read_CMIUCELR0_ErrWord(read_data);
          errword = read_data;
          read_CMIUCELR1_ErrAddr(read_data);
          erraddr = read_data;

<% } %>
    endtask
endclass : dmi_csr_cmiucelr_seq2

class dmi_csr_cmiucelr_seq22 extends dmi_csr_ralgen_base_seq; 
  `uvm_object_utils(dmi_csr_cmiucelr_seq22)

    uvm_reg_data_t poll_data, read_data, read_data2, write_data;
    bit [7:0]  errthd;
    int        errcount_vld, errthd_vld;
    int        errentry, errway, errword, erraddr;

    function new(string name="");
        super.new(name);
    endfunction

    task body();

<% if(rttCorr) { %>
        `uvm_info("RUN_MAIN",$sformatf("Entered Test loop"), UVM_LOW)
          read_CMIUCELR0_ErrEntry(read_data);
          errentry = read_data;
          read_CMIUCELR0_ErrWay(read_data);
          errway = read_data;
          read_CMIUCELR0_ErrWord(read_data);
          errword = read_data;
          read_CMIUCELR1_ErrAddr(read_data);
          erraddr = read_data;

<% } %>
    endtask
endclass : dmi_csr_cmiucelr_seq22

class dmi_csr_cmiucelr_seq3 extends dmi_csr_ralgen_base_seq; 
  `uvm_object_utils(dmi_csr_cmiucelr_seq3)

    uvm_reg_data_t poll_data, read_data, read_data2, write_data;
    bit [7:0]  errthd;
    int        errcount_vld, errthd_vld;
    int        errentry, errway, errword, erraddr;

    function new(string name="");
        super.new(name);
    endfunction

    task body();

<% if(rttCorr) { %>
        `uvm_info("RUN_MAIN",$sformatf("Entered Test loop"), UVM_LOW)
          //poll_CMIUCESR_ErrCount(2, poll_data);
          poll_CMIUCESR_ErrOvf(1, poll_data);
          //compareValues("CMIUCESR_ErrOvf", "set now", read_data, 1);

          read_CMIUCELR0_ErrEntry(read_data);
          compareValues("CMIUCELR0_ErrEntry", "match with older value", read_data, errentry);
          read_CMIUCELR0_ErrWay(read_data);
          compareValues("CMIUCELR0_ErrWay", "match with older value", read_data, errway);
          read_CMIUCELR0_ErrWord(read_data);
          compareValues("CMIUCELR0_ErrWord", "match with older value", read_data, errword);
          read_CMIUCELR1_ErrAddr(read_data);
          compareValues("CMIUCELR1_ErrAddr", "match with older value", read_data, erraddr);
<% } %>
    endtask
endclass : dmi_csr_cmiucelr_seq3


//-----------------------------------------------------------------------
//  Task    : 
//  Purpose : Test Uncorrectable Error registers
//
//-----------------------------------------------------------------------
//#Check.DMI.ErrIntEnUnCorrErrs
class dmi_csr_cmiuuecr_errCntOvf_seq extends dmi_csr_ralgen_base_seq; 
  `uvm_object_utils(dmi_csr_cmiuuecr_errCntOvf_seq)

    uvm_reg_data_t poll_data, read_data, read_data2, write_data;
    bit [7:0]  errthd;
    int        errcount_vld, errthd_vld;
    int        errcount_ovf;
    bit [3:0] errtype;

    function new(string name="");
        super.new(name);
    endfunction

    task body();

<% if(rttUncorr) { %>

          if ($test$plusargs("ccp_double_bit_data_error_test") || $test$plusargs("ccp_double_bit_tag_error_test"))
            errtype = 4'h7;
          else
            errtype = 4'h6;
             

          assert(randomize(errthd));
          write_data = errthd;
          // Try Set the CMIUCECR_ErrThreshold. Shouldn't work as this is RAZ/WI
          write_CMIUUECR_ErrThreshold(write_data);
          read_CMIUUECR_ErrThreshold(read_data);
          compareValues("CMIUUECR_ErrThreshold","Should be 0", read_data, 0);

          //#Test.DMI.ErrVldErrOvfNotResetW1CIfClr
          // Try Set the CMIUUESR_ErrVld = 1. Shouldn't work as this field is W1C
          write_data = 1;
          write_CMIUUESR_ErrVld(write_data);
          read_CMIUUESR_ErrVld(read_data);
          compareValues("CMIUUESR_ErrVld","Should be 0", read_data, 0);

          write_CMIUUESR_ErrOvf(write_data);
          read_CMIUUESR_ErrOvf(read_data);
          compareValues("CMIUUESR_ErrVld","Should be 0", read_data, 0);

         // Set the CMIUUECR_ErrDetEn = 1
          //#Check.DMI.DetectEnSet
          write_data = 1;
          write_CMIUUECR_ErrDetEn(write_data);
         // Set the CMIUUECR_ErrIntEn = 1
          write_CMIUUECR_ErrIntEn(write_data);
         // write  CMIUUESR_ErrVld = 1 , to reset it
          write_CMIUUESR_ErrVld(write_data);

        ///////////////////////////////////////////////////////////

          //keep on  Reading the CMIUUESR_ErrVld bit = 1
          poll_CMIUUESR_ErrVld(1, poll_data);
          compareValues("CMIUUESR_ErrVld", "set", poll_data, 1);

          read_CMIUUESR_ErrType(read_data);
          compareValues("CMIUUESR_ErrType","Valid Type", read_data, errtype);
          read_CMIUUESR_ErrCount(read_data);
          compareValues("CMIUUESR_ErrCount","For uncorrectable", read_data, 0);

          //keep on  Reading the CMIUUESR_ErrcountOvf bit = 1 
          poll_CMIUUESR_ErrOvf(1, poll_data);
          compareValues("CMIUUESR_ErrOvf", "set", poll_data, 1);

          read_CMIUUESR_ErrVld(read_data);
          compareValues("CMIUUESR_ErrVld", "set", read_data, 1);

          read_CMIUUESR_ErrType(read_data);
          compareValues("CMIUUESR_ErrType","Valid Type", read_data, errtype);
          read_CMIUUESR_ErrCount(read_data);
          compareValues("CMIUUESR_ErrCount","For uncorrectable", read_data, 0);

          // Read CMIUUESAR_ErrVld , it should be 1
          read_CMIUUESAR_ErrVld(read_data);
          compareValues("CMIUESAR_ErrVld", "set", read_data, 1);

          read_CMIUUESR_ErrType(read_data);
          compareValues("CMIUUESR_ErrType","Valid Type", read_data, errtype);

          // Reset the CMIUUECR_ErrDetEn = 0
          write_data = 0;
          write_CMIUUECR_ErrDetEn(write_data);

          // Clear the CMIUUECR_ErrIntEn = 0
          write_CMIUUECR_ErrIntEn(write_data);
          //#Test.DMI.ErrVldErrOvfResetW1CAfterSet
          // write  CMIUUESAR_ErrVld = 0 , to reset it
          write_CMIUUESAR_ErrVld(write_data);
          read_CMIUUESR_ErrOvf(read_data);
          compareValues("CMIUUESR_ErrOvf", "still set", read_data, 1);
          read_CMIUUESR_ErrType(read_data);
          compareValues("CMIUUESR_ErrType","Valid Type", read_data, errtype);

         // Read CMIUUESAR_ErrVld , it should also be 0, because it is alias of register
         // CMIUUESR_ErrVld
          //#Test.DMI.ErrVldErrOvfResetW1CAfterSet
          read_CMIUUESAR_ErrVld(read_data);
          compareValues("CMIUESAR_ErrVld", "cleared previously", read_data, 0);
          read_CMIUUESAR_ErrOvf(read_data);
          compareValues("CMIUUESAR_ErrOvf", "still set", read_data, 1);
          read_CMIUUESAR_ErrType(read_data);
          compareValues("CMIUUESAR_ErrType","Valid Type", read_data, errtype);

          //#Test.DMI.ErrVldErrOvfResetW1CAfterSet
          // Read CMIUUESR_ErrOvf , it should be 1
          read_CMIUUESR_ErrOvf(read_data);
          compareValues("CMIUUESR_ErrOvf", "still set", read_data, 1);

          // write  CMIUUESR_ErrOvf = 1 , to reset it
          write_data = 1;
          write_CMIUUESR_ErrOvf(write_data);

          //#Test.DMI.ErrVldErrOvfResetW1CAfterSet
          // Read CMIUUESR_ErrOvf , it should be 0
          read_CMIUUESR_ErrOvf(read_data);
          compareValues("CMIUUESR_ErrOvf", "now clear", read_data, 0);
          read_CMIUUESR_ErrCount(read_data);
          compareValues("CMIUUESR_ErrCount","cleared", read_data, 0);
          // Read CMIUUESAR_ErrOvf , it should be 0
          read_CMIUUESAR_ErrOvf(read_data);
          compareValues("CMIUUESAR_ErrOvf", "now clear", read_data, 0);
          read_CMIUUESAR_ErrCount(read_data);
          compareValues("CMIUUESAR_ErrCount","cleared", read_data, 0);

          // write  CMIUUESAR_ErrVld = 1 , to set it
          write_data = 1;
          write_CMIUUESAR_ErrVld(write_data);

          //#Test.DMI.ESARWriteUpdatesESR
          // write  CMIUUESR_ErrVld = 1 , to reset it
          write_data = 1;
          write_CMIUUESR_ErrVld(write_data);

          // Read CMIUUESAR_ErrOvf , it should be 0
          read_CMIUUESAR_ErrOvf(read_data);
          compareValues("CMIUUESAR_ErrOvf", "clear", read_data, 0);
          read_CMIUUESAR_ErrCount(read_data);
          compareValues("CMIUUESAR_ErrCount","cleared", read_data, 0);

<% } else { %>
          // Read the CMIUUESR_ErrVld bit = 0
          read_CMIUUESR_ErrVld(read_data);
          compareValues("CMIUESR_ErrVld", "RAZ/WI", read_data, 0);
          // Read the CMIUUESR_ErrcountOvf bit = 0 
          read_CMIUUESR_ErrOvf(read_data);
          compareValues("CMIUUESR_ErrOvf", "RAZ/WI", read_data, 0);
          // Read CMIUUESAR_ErrVld , it should be 0
          read_CMIUUESAR_ErrVld(read_data);
          compareValues("CMIUESAR_ErrVld", "RAZ/WI", read_data, 0);
          read_CMIUUESAR_ErrType(read_data);
          compareValues("CMIUUESAR_ErrType","RAZ/WI", read_data, 0);
          // Read CMIUUESR_ErrVld , it should be 0
          read_CMIUUESR_ErrOvf(read_data);
          compareValues("CMIUUESR_ErrOvf", "RAZ/WI", read_data, 0);
          // Read CMIUUESAR_ErrVld , it should also be 0, because it is alias of register
          read_CMIUUESAR_ErrOvf(read_data);
          compareValues("CMIUUESAR_ErrOvf", "RAZ/WI", read_data, 0);
          // write  CMIUUESAR_ErrVld = 1
          write_data = 1;
          write_CMIUUESR_ErrVld(write_data);
          // Read CMIUUESR_ErrVld , it should be 0
          read_CMIUUESR_ErrVld(read_data);
          compareValues("CMIUESR_ErrVld", "RAZ/WI", read_data, 0);
          // write  CMIUUESR_ErrOvf = 1
          write_CMIUUESR_ErrOvf(write_data);
          // Read CMIUUESR_ErrOvf , it should be 0
          read_CMIUUESR_ErrOvf(read_data);
          compareValues("CMIUUESR_ErrOvf", "RAZ/WI", read_data, 0);

<% } %>
    endtask
endclass : dmi_csr_cmiuuecr_errCntOvf_seq

//-----------------------------------------------------------------------
//  Task    : 
//  Purpose : 
//
//-----------------------------------------------------------------------
class dmi_csr_cmiuuecr_errDetEn_seq extends dmi_csr_ralgen_base_seq; 
  `uvm_object_utils(dmi_csr_cmiuuecr_errDetEn_seq)

    uvm_reg_data_t poll_data, read_data, read_data2, write_data;
    bit [7:0]  errthd;
    int        errcount_vld, errthd_vld;
    int        errcount_ovf;
    bit [3:0]  errtype;

    function new(string name="");
        super.new(name);
    endfunction

    task body();

<% if(rttUncorr) { %>

           if ($test$plusargs("ccp_double_bit_data_error_test") || $test$plusargs("ccp_double_bit_tag_error_test"))
             errtype = 4'h7;
           else
             errtype = 4'h6;
             

           // Set the CMIUUECR_ErrDetEn = 1
           write_data = 1;
           write_CMIUUECR_ErrDetEn(write_data);
           //keep on  Reading the CMIUUESR_ErrVld bit = 1
           poll_CMIUUESR_ErrVld(1, poll_data);
           read_CMIUUESR_ErrType(read_data);
           compareValues("CMIUUESR_ErrType","Valid Type", read_data, errtype);
           // Read CMIUUESAR_ErrVld , it should be 1
           read_CMIUUESAR_ErrVld(read_data);
           compareValues("CMIUUESAR_ErrVld", "set", read_data, 1);
           // Set the CMIUUECR_ErrDetEn = 0, to diable the error detection
           write_data = 0;
           write_CMIUUECR_ErrDetEn(write_data);
           // Read CMIUUESR_ErrVld , it should be 1
           read_CMIUUESR_ErrVld(read_data);
           compareValues("CMIUUESR_ErrVld", "set", read_data, 1);
           read_CMIUUESR_ErrType(read_data);
           compareValues("CMIUUESR_ErrType","Valid Type", read_data, errtype);
           // Read CMIUUESAR_ErrVld , it should be 1
           read_CMIUUESAR_ErrVld(read_data);
           compareValues("CMIUUESAR_ErrVld", "set", read_data, 1);
           // Read CMIUUESAR_ErrVld , it should be 1
           read_CMIUUESAR_ErrVld(read_data);
           compareValues("CMIUUESAR_ErrVld", "set", read_data, 1);
           // write  CMIUUESR_ErrVld = 1 , W1C
           write_data = 1;
           write_CMIUUESR_ErrVld(write_data);
           // Read the CMIUUESR_ErrVld should be cleared
           read_CMIUUESR_ErrVld(read_data);
           compareValues("CMIUUESR_ErrVld", "now clear", read_data, 0);
           // Read CMIUUESAR_ErrVld , it should also clear, beacuse it is alias register
           // of register CMIUUESR_*
           read_CMIUUESAR_ErrVld(read_data);
           compareValues("CMIUUESAR_ErrVld", "now clear", read_data, 0);
           // write  CMIUUESR_ErrVld = 1 , to make sure it only reset by 1, not set by 1
           write_data = 1;
           write_CMIUUESR_ErrVld(write_data);
           // Read the CMIUUESR_ErrVld should be still be 0
           read_CMIUUESR_ErrVld(read_data);
           compareValues("CMIUUESR_ErrVld", "still clear", read_data, 0);
<% } else { %>
           // Read the CMIUUESR_ErrVld should be clear
           read_CMIUUESR_ErrVld(read_data);
           compareValues("CMIUESR_ErrVld", "RAZ/WI", read_data, 0);
           // Read CMIUUESAR_ErrVld , it should also clear, beacuse it is alias register
           // of register CMIUUESR_*
           read_CMIUUESAR_ErrVld(read_data);
           compareValues("CMIUESAR_ErrVld", "RAZ/WI", read_data, 0);
           // Read the CMIUUESR_ErrVld should be still be 0
           read_CMIUUESR_ErrVld(read_data);
           compareValues("CMIUUESR_ErrVld", "still clear", read_data, 0);
           // write  CMIUUESR_ErrVld = 1 , to reset it
           write_data = 1;
           write_CMIUUESR_ErrVld(write_data);
           // Read the CMIUUESR_ErrVld should be cleared
           write_data = 1;
           write_CMIUUESR_ErrVld(write_data);
           read_CMIUUESR_ErrVld(read_data);
           compareValues("CMIUUESR_ErrVld", "clear", read_data, 0);
           // Read CMIUUESAR_ErrVld , it should also clear, beacuse it is alias register
           // of register CMIUUESR_*
           read_CMIUUESAR_ErrVld(read_data);
           compareValues("CMIUUESAR_ErrVld", "clear", read_data, 0);
<% } %>
    endtask
endclass : dmi_csr_cmiuuecr_errDetEn_seq

//-----------------------------------------------------------------------
//  Task    : 
//  Purpose : 
//
//-----------------------------------------------------------------------
class dmi_csr_cmiuuecr_errInt_seq extends dmi_csr_ralgen_base_seq; 
  `uvm_object_utils(dmi_csr_cmiuuecr_errInt_seq)

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
<% if(rttUncorr) { %>

           if ($test$plusargs("ccp_double_bit_data_error_test") || $test$plusargs("ccp_double_bit_tag_error_test"))
             errtype = 4'h7;
           else
             errtype = 4'h6;
             

           // Set the CMIUUECR_ErrDetEn = 1
           write_data = 1;
           write_CMIUUECR_ErrDetEn(write_data);
           // Set the CMIUUECR_ErrIntEn = 1
           write_CMIUUECR_ErrIntEn(write_data);
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
           // Read the CMIUUESR_ErrVld
           read_CMIUUESR_ErrVld(read_data);
           compareValues("CMIUUESR_ErrVld", "set after inte", read_data, 1);
           read_CMIUUESR_ErrType(read_data);
           compareValues("CMIUUESR_ErrType","Valid Type", read_data, errtype);
           read_CMIUUESR_ErrCount(read_data);
           compareValues("CMIUUESR_ErrCount","for uncorr", read_data, 0);
           // Read CMIUUESAR_ErrVld , it should have same as  CMIUUESR0_*
           read_CMIUUESAR_ErrVld(read_data);
           compareValues("CMIUUESAR_ErrVld", "set after inte", read_data, 1);
           read_CMIUUESAR_ErrType(read_data);
           compareValues("CMIUUESAR_ErrType","Valid Type", read_data, errtype);
           read_CMIUUESAR_ErrCount(read_data);
           compareValues("CMIUUESAR_ErrCount","for uncorr", read_data, 0);
           // Set the CMIUUECR_ErrDetEn = 0, to disable the error detection
           write_data = 0;
           write_CMIUUECR_ErrDetEn(write_data);
           // Set the CMIUUECR_ErrIntEn = 0, to disable the error Interrupt
           write_CMIUUECR_ErrIntEn(write_data);
           // write CMIUUESR_ErrVld = 1 to clear it
           write_data = 1;
           write_CMIUUESR_ErrVld(write_data);
           // Read CMIUUESR_ErrVld , it should be 0
           read_CMIUUESR_ErrVld(read_data);
           compareValues("CMIUUESR_ErrVld", "reset", read_data, 0);
           // Read CMIUUESAR_ErrVld , it should be 0
           read_CMIUUESAR_ErrVld(read_data);
           compareValues("CMIUUESAR_ErrVld", "reset", read_data, 0);
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
          // Read CMIUUESR_ErrVld , it should be 0
           read_CMIUUESR_ErrVld(read_data);
           compareValues("CMIUUESR_ErrVld", "set", read_data, 0);
           read_CMIUUESR_ErrType(read_data);
           compareValues("CMIUUESR_ErrType","Valid Type", read_data, 4'h0);
           read_CMIUUESR_ErrCount(read_data);
           compareValues("CMIUUESR_ErrCount","for uncorr", read_data, 0);
          // Read CMIUUESAR_ErrVld , it should be 0
           read_CMIUUESAR_ErrVld(read_data);
           compareValues("CMIUUESAR_ErrVld", "set", read_data, 0);
           read_CMIUUESAR_ErrType(read_data);
           compareValues("CMIUUESAR_ErrType","Valid Type", read_data, 4'h0);
           read_CMIUUESAR_ErrCount(read_data);
           compareValues("CMIUUESAR_ErrCount","for uncorr", read_data, 0);
          // Monitor IRQ_C pin , it should be 0 now
          if(u_csr_probe_vif.IRQ_UC == 0)begin
             `uvm_info("RUN_MAIN",$sformatf("IRQ_UC interrupted de-asseretd"), UVM_MEDIUM)
          end else begin
             `uvm_error("RUN_MAIN",$sformatf("IRQ_UC interruped still aseerted"));
          end
<% } %>
    endtask
endclass : dmi_csr_cmiuuecr_errInt_seq

//-----------------------------------------------------------------------
//  Task    : 
//  Purpose : 
//
//-----------------------------------------------------------------------
class dmi_csr_cmiuuecr_errThd_seq extends dmi_csr_ralgen_base_seq; 
  `uvm_object_utils(dmi_csr_cmiuuecr_errThd_seq)

    uvm_reg_data_t poll_data, read_data, read_data2, write_data;
    bit [7:0]  errthd;
    int        errcount_vld, errthd_vld;
    int        errcount_ovf;

    function new(string name="");
        super.new(name);
    endfunction

    task body();

       //getCsrProbeIf();
<% if(rttUncorr) { %>
          // Set the CMIUUECR_ErrDetEn = 1
          write_data = 1;
          write_CMIUUECR_ErrDetEn(write_data);
          // Set the CMIUUECR_ErrIntEn = 1
          write_CMIUUECR_ErrIntEn(write_data);
          // Try set the CMIUUECR_ErrThreshold; shouldn't work
          assert(randomize(errthd));
          write_data = errthd;
          write_CMIUUECR_ErrThreshold(write_data);
          read_CMIUUECR_ErrThreshold(read_data);
          compareValues("CMIUUECR_ErrThreshold", "can't be set", read_data, 0);
          // write  CMIUUESR_ErrVld = 1 , to reset it
          write_CMIUUESR_ErrVld(write_data);
          //keep on  Reading the CMIUUESR_ErrVld bit = 1 
          poll_CMIUUESR_ErrVld(1, poll_data);
          // Read CMIUUESR_ErrCount , it should be at errthd
          read_CMIUUESR_ErrCount(read_data);
          compareValues("CMIUUESR_ErrCount","for uncorr", read_data, 0);
          // Read alias field  CMIUUESAR_ErrCount , should match
          read_CMIUUESAR_ErrCount(read_data);
          compareValues("CMIUUESAR_ErrCount","for uncorr", read_data, 0);
          // Set the CMIUUECR_ErrDetEn = 0
          write_data = 0;
          write_CMIUUECR_ErrDetEn(write_data);
          // write : CMIUUESR_ErrVld = 1 , to reset it
          write_data = 1;
          write_CMIUUESR_ErrVld(write_data);
          // Read CMIUUESAR_ErrVld , it should be 0
          read_CMIUUESAR_ErrVld(read_data);
          compareValues("CMIUUESAR_ErrVld", "now clear", read_data, 0);
          // Read CMIUUESR_ErrVld , it should be 0
          read_CMIUUESR_ErrVld(read_data);
          compareValues("CMIUUESR_ErrVld", "now clear", read_data, 0);
<% } else { %>
          // Read CMIUUESR_ErrCount , it should be 0
          read_CMIUUESR_ErrCount(read_data);
          compareValues("CMIUUESR_ErrCount","RAZ/WI", read_data, 0);
          // write alias : CMIUUESAR_ErrVld = 1 , to reset it
          write_data = 1;
          write_CMIUUESR_ErrVld(write_data);
          //#Test.DMI.ESARWriteUpdatesESR
          read_CMIUUESR_ErrVld(read_data);
          compareValues("CMIUUESR_ErrVld", "clear", read_data, 0);
<% } %>
    endtask
endclass : dmi_csr_cmiuuecr_errThd_seq

//-----------------------------------------------------------------------
//  Task    : 
//  Purpose : 
//
//-----------------------------------------------------------------------
//#Test.DMI.ErrInjWhileSoftwareWriteHappens
class dmi_csr_cmiuuecr_sw_write_seq extends dmi_csr_ralgen_base_seq; 
  `uvm_object_utils(dmi_csr_cmiuuecr_sw_write_seq)

    uvm_reg_data_t poll_data, read_data, read_data2, write_data;
    bit [7:0]  errthd;
    int        errcount_vld, errthd_vld;
    int        i;

    function new(string name="");
        super.new(name);
    endfunction

    task body();

       //getCsrProbeIf();
<% if(rttUncorr) { %>
          // Set the CMIUUECR_ErrDetEn = 1
          write_data = 1;
          write_CMIUUECR_ErrDetEn(write_data);
          // write  CMIUCESR_ErrVld = 1 , to reset it
          write_CMIUUESR_ErrVld(write_data);
          write_data = 0;
          for (i=0;i<100;i++) begin
             write_CMIUUESAR_ErrVld(write_data);
          end
          // Set the CMIUUECR_ErrDetEn = 0
          write_data = 0;
          write_CMIUUECR_ErrDetEn(write_data);
          // if vld is set, reset it
          read_CMIUUESR_ErrVld(read_data);
          if(read_data) begin
             write_CMIUUESAR_ErrVld(write_data);
          end
<% } %>
    endtask
endclass : dmi_csr_cmiuuecr_sw_write_seq

//-----------------------------------------------------------------------
//  Task    : 
//  Purpose : 
//
//-----------------------------------------------------------------------
//#Test.DMI.DetectEnNotSetErrorsInjected
class dmi_csr_cmiuuecr_noDetEn_seq extends dmi_csr_ralgen_base_seq; 
  `uvm_object_utils(dmi_csr_cmiuuecr_noDetEn_seq)

    uvm_reg_data_t poll_data, read_data, read_data2, write_data;
    bit [7:0]  errthd;
    int        errcount_vld, errthd_vld;
    int        errcount_ovf;

    function new(string name="");
        super.new(name);
    endfunction

    task body();

<% if(rttUncorr) { %>
          // Don't Set the CMIUUECR_ErrDetEn = 1
          //Reading the CMIUUESR_ErrVld bit = 0
          read_CMIUUESR_ErrVld(read_data);
          compareValues("CMIUUESR_ErrVld", "not set", read_data, 0);
          // Read CMIUUESR_ErrCount , it should be at 0
          read_CMIUUESR_ErrCount(read_data);
          compareValues("CMIUUESR_ErrCount","not set", read_data, 0);
          // Read alias field  CMIUUESAR_ErrCount , should match
          read_CMIUUESAR_ErrCount(read_data);
          compareValues("CMIUUESAR_ErrCount","not set", read_data, 0);
<% } else { %>
          // Read the CMIUUESR_ErrVld should be cleared
          read_CMIUUESR_ErrVld(read_data);
          compareValues("CMIUUESR_ErrVld", "not set", read_data, 0);
          // Read CMIUUESAR_ErrVld , it should also clear, beacuse it is alias register
          // of register CMIUUESR_*
          read_CMIUUESAR_ErrVld(read_data);
          compareValues("CMIUUESAR_ErrVld", "not set", read_data, 0);
<% } %>
    endtask
endclass : dmi_csr_cmiuuecr_noDetEn_seq

//-----------------------------------------------------------------------
//  Task    : 
//  Purpose : 
//
//-----------------------------------------------------------------------
class dmi_csr_cmiuuecr_noIntEn_seq extends dmi_csr_ralgen_base_seq; 
  `uvm_object_utils(dmi_csr_cmiuuecr_noIntEn_seq)

    uvm_reg_data_t poll_data, read_data, read_data2, write_data;
    bit [7:0]  errthd;
    int        errcount_vld, errthd_vld;
    int        errcount_ovf;

    function new(string name="");
        super.new(name);
    endfunction

    task body();

       getCsrProbeIf();
<% if(rttUncorr) { %>
          // Set the CMIUUECR_ErrDetEn = 1
          write_data = 1;
          write_CMIUUECR_ErrDetEn(write_data);
          // Dont Set the CMIUUECR_ErrIntEn = 1
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
          //Reading the CMIUUESR_ErrVld bit = 1
          read_CMIUUESR_ErrVld(read_data);
          compareValues("CMIUUESR_ErrVld", "set", read_data, 1);
          // write CMIUUESR_ErrVld = 1 to clear it
          write_data = 1;
          write_CMIUUESR_ErrVld(write_data);
          write_CMIUUESR_ErrOvf(write_data);
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
endclass : dmi_csr_cmiuuecr_noIntEn_seq

//-----------------------------------------------------------------------
//  Task    : 
//  Purpose : 
//
//-----------------------------------------------------------------------
class dmi_csr_cmiuuelr_seq1 extends dmi_csr_ralgen_base_seq; 
  `uvm_object_utils(dmi_csr_cmiuuelr_seq1)

    uvm_reg_data_t poll_data, read_data, read_data2, write_data;
    bit [7:0]  errthd;
    int        errcount_vld, errthd_vld;
    int        errentry, errway, errword, erraddr;

    function new(string name="");
        super.new(name);
    endfunction

    task body();

<% if(rttUncorr || cmcUncorr ) { %>
        `uvm_info("RUN_MAIN",$sformatf("Entered Test loop"), UVM_LOW)
          //#Test.DMI.ErrVldErrOvfNotResetW1CIfClr
          // Try Set the CMIUUESR_ErrVld = 1. Shouldn't work as this field is W1C
          write_data = 1;
          write_CMIUUESR_ErrVld(write_data);
          read_CMIUUESR_ErrVld(read_data);
          compareValues("CMIUUESR_ErrVld","Should be 0", read_data, 0);

          write_CMIUUESR_ErrOvf(write_data);
          read_CMIUUESR_ErrOvf(read_data);
          compareValues("CMIUUESR_ErrVld","Should be 0", read_data, 0);

          // Set the CMIUUECR_ErrDetEn = 1
          write_data = 1;
          write_CMIUUECR_ErrDetEn(write_data);
<% } %>
    endtask
endclass : dmi_csr_cmiuuelr_seq1

class dmi_csr_cmiuuelr_seq2 extends dmi_csr_ralgen_base_seq; 
  `uvm_object_utils(dmi_csr_cmiuuelr_seq2)

    uvm_reg_data_t poll_data, read_data, read_data2, write_data;
    bit [7:0]  errthd;
    int        errcount_vld, errthd_vld;
    int        errentry, errway, errword, erraddr;

    function new(string name="");
        super.new(name);
    endfunction

    task body();

<% if(rttUncorr || cmcUncorr ) { %>
        `uvm_info("RUN_MAIN",$sformatf("Entered Test loop"), UVM_LOW)
          //keep on  Reading the CMIUUESR_ErrCount bit = 1
          poll_CMIUUESR_ErrVld(1, poll_data);
          read_CMIUUESR_ErrOvf(read_data);
          compareValues("CMIUUESR_ErrOvf", "not set yet", read_data, 0);

          //#Test.DMI.UnCorrErrErrLoggingSetAfterErrorCntCrossesErrThreshold
          //#Test.DMI.UnCorrErrErrLoggingRegisters
          //#Check.DMI.DetectEnSet
          //readCompareUELR(1);

          write_data = 1;
          write_CMIUUESR_ErrVld(write_data);
          read_CMIUUESR_ErrVld(read_data);
          compareValues("CMIUUESR_ErrVld","Should be 0", read_data, 0);
          write_CMIUUESR_ErrOvf(write_data);
          read_CMIUUESR_ErrOvf(read_data);
          compareValues("CMIUUESR_ErrVld","Should be 0", read_data, 0);

          read_CMIUUESR_ErrCount(read_data);
          compareValues("CMIUUESR_ErrCount", "reset", read_data, 0);
<% } %>
    endtask
endclass : dmi_csr_cmiuuelr_seq2

class dmi_csr_cmiuuelr_seq3 extends dmi_csr_ralgen_base_seq; 
  `uvm_object_utils(dmi_csr_cmiuuelr_seq3)

    uvm_reg_data_t poll_data, read_data, read_data2, write_data;
    bit [7:0]  errthd;
    int        errcount_vld, errthd_vld;
    int        errentry, errway, errword, erraddr;

    function new(string name="");
        super.new(name);
    endfunction

    task body();

    endtask
endclass : dmi_csr_cmiuuelr_seq3
*/
