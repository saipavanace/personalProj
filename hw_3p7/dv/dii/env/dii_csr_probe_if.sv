
//
// The entire notice above must be reproduced on all authorized copies.
//-----------------------------------------------------------------------

/**
 * Abstract:
 * Defines an interface that provides access to a internal signal of DUT .This
 */

interface <%=obj.BlockId%>_dii_csr_probe_if (input clk, input resetn);

  logic IRQ_C;
  logic IRQ_UC;

  logic [31:0] DIIUCESR_ErrVld;
  logic [31:0] DIIUUESR_ErrVld;

    
  logic [31:0] single_bit_count0;
  logic [31:0] single_bit_count1;

  logic [31:0] double_bit_count0;
  logic [31:0] double_bit_count1;

  
  // Signals for sys_event timeout Error verification
  logic [30:0] timeout_threshold ;
  logic [30:0] sys_timeout_threshold;
  logic        uedr_timeout_err_det_en;
  logic        uesr_errvld ;
  logic [3:0]  uesr_err_type ;
  logic [15:0] uesr_err_info ;
  logic fault_mission_fault;

<% if (obj.DiiInfo[obj.Id].useResiliency ) { %>
  logic fault_latent_fault;
  logic [9:0]  cerr_threshold;
  logic [15:0] cerr_counter;
  logic        cerr_over_thres_fault;
<% } %>

  logic inject_cmd_data_single_next_0; 
  logic inject_cmd_data_single_next_1;
  bit buffer_sel_probe;

<% if (obj.DiiInfo[obj.Id].CMDOverflowBufInSRAM == true){ %>
    assign inject_cmd_data_single_next_0 = dut.skidBufferMem0.external_mem_inst.internal_mem_inst.INJECT_SINGLE_NEXT;
    assign inject_cmd_data_single_next_1 = dut.skidBufferMem1.external_mem_inst.internal_mem_inst.INJECT_SINGLE_NEXT;  
 <% } %>



  //correctable error iff system contains secded.
<% 
if ( 
    (obj.fnReseiliencyProtectionType == "ECC")  //TODO call it SECDED
    || ((obj.useExternalMemoryFifo) && (obj.fnErrDetectCorrect == "SECDED")) || ((obj.fnErrDetectCorrect == "SECDED") && (obj.DiiInfo[obj.Id].CMDOverflowBufInSRAM == true))
)
 { 
%>
  assign DIIUCESR_ErrVld = dut.u_dii_unit.dii_csr.dii_csr_gen.DIIUCESR_ErrVld_out;
<% } else { %>
  assign DIIUCESR_ErrVld = 1'b0 ;   //correctable error excluded.
<% } %>

    
<% if (obj.useRttDataEntries) { %>
  //assign single_bit_count0 = dut.prot.memory.r_memory.internal_mem_inst.SINGLE_ERROR_COUNT[31:0];
  //assign double_bit_count0 = dut.prot.memory.r_memory.internal_mem_inst.DOUBLE_ERROR_COUNT[31:0];
<% } %>

<% if (obj.nHttCtrlEntries > 0) { %>
  //assign single_bit_count1 = dut.prot.memory.h_memory.internal_mem_inst.SINGLE_ERROR_COUNT[31:0];
  //assign double_bit_count1 = dut.prot.memory.h_memory.internal_mem_inst.DOUBLE_ERROR_COUNT[31:0];
<% } %>

  task inject_double_error(input bit buffer_sel); 

 <% if (obj.DiiInfo[obj.Id].CMDOverflowBufInSRAM == true) { %>

    if(buffer_sel == 0) begin
      dut.skidBufferMem0.external_mem_inst.internal_mem_inst.inject_double_error();
      buffer_sel_probe =0;
    end else begin
      dut.skidBufferMem1.external_mem_inst.internal_mem_inst.inject_double_error();
      buffer_sel_probe =1;
    end
    //$display("Vyshak and Random buffer_sel_probe in double_error: %0d", buffer_sel_probe);

 <% } %>    
  endtask: inject_double_error

  task inject_single_error(input bit buffer_sel); 

  <%if (obj.DiiInfo[obj.Id].CMDOverflowBufInSRAM == true) { %>

      if(buffer_sel == 0) begin
        dut.skidBufferMem0.external_mem_inst.internal_mem_inst.inject_single_error();
        buffer_sel_probe = 0;
      end else begin
        dut.skidBufferMem1.external_mem_inst.internal_mem_inst.inject_single_error();
        buffer_sel_probe = 1;
      end
      //$display("Vyshak and Random buffer_sel_probe in single_error: %0d", buffer_sel_probe);

  <%} %>  

  endtask: inject_single_error


  task inject_addr_error(input bit buffer_sel); 

  <%if(obj.DiiInfo[obj.Id].CMDOverflowBufInSRAM == true) { %>
    
      if(buffer_sel == 0) begin
        buffer_sel_probe =0;
        dut.skidBufferMem0.external_mem_inst.internal_mem_inst.init_addr_error(100);
        dut.skidBufferMem0.external_mem_inst.internal_mem_inst.inject_addr_error();
      end else begin
        buffer_sel_probe =1;
        dut.skidBufferMem1.external_mem_inst.internal_mem_inst.init_addr_error(100);
        dut.skidBufferMem1.external_mem_inst.internal_mem_inst.inject_addr_error();
      end
      //$display("Vyshak and Random buffer_sel_probe in addr_error: %0d", buffer_sel_probe);
      
  <%}%>

  endtask: inject_addr_error

endinterface
