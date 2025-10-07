
//
// The entire notice above must be reproduced on all authorized copies.
//-----------------------------------------------------------------------

/**
 * Abstract:
 * Defines an interface that provides access to a internal signal of DUT .This
 */

interface dve_csr_probe_if (input clk, input resetn);

  logic IRQ_C;
  logic IRQ_UC;

  logic [31:0] single_bit_count0;
  logic [31:0] single_bit_count1;

  logic [31:0] double_bit_count0;
  logic [31:0] double_bit_count1;

<% if(obj.useResiliency) { %>
  logic fault_mission_fault;
  logic fault_latent_fault;
  logic [9:0]  cerr_threshold;
  logic [15:0] cerr_counter;
  logic        cerr_over_thres_fault;
<% } %>

<% if (obj.useRttDataEntries) { %>
  //assign single_bit_count0 = dut.prot.memory.r_memory.internal_mem_inst.SINGLE_ERROR_COUNT[31:0];
  //assign double_bit_count0 = dut.prot.memory.r_memory.internal_mem_inst.DOUBLE_ERROR_COUNT[31:0];
<% } %>

<% if (obj.nHttCtrlEntries > 0) { %>
  //assign single_bit_count1 = dut.prot.memory.h_memory.internal_mem_inst.SINGLE_ERROR_COUNT[31:0];
  //assign double_bit_count1 = dut.prot.memory.h_memory.internal_mem_inst.DOUBLE_ERROR_COUNT[31:0];
<% } %>

endinterface
