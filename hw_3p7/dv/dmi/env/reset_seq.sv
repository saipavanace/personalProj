//=======================================================================
// COPYRIGHT (C) 2010, 2011, 2012, 2013 SYNOPSYS INC.
// This software and the associated documentation are confidential and
// proprietary to Synopsys, Inc. Your use or disclosure of this software
// is subject to the terms and conditions of a written license agreement
// between you, or your company, and Synopsys, Inc. In the event of
// publications, the following notice is applicable:
// 
// ALL RIGHTS RESERVED
//
// The entire notice above must be reproduced on all authorized copies.
//=======================================================================

/**
 * Abstract:
 * class reset_seq defines a virtual sequence.
 * 
 * The reset_seq drives the reset pin through one
 * activation cycle.
 *
 * The reset_seq is configured as the default sequence for the
 * reset_phase of the testbench environment virtual sequencer, in the axi_base_test.
 *
 * The reset sequence obtains the handle to the reset interface through the
 * virtual sequencer. The reset interface is set in the virtual sequencer using
 * configuration database, in file top.sv.
 *
 * Execution phase: reset_phase
 * Sequencer: axi_virtual_sequencer in testbench environment
 */

class <%=obj.BlockId%>_reset_seq extends uvm_sequence;

  /** UVM Object Utility macro */
  `uvm_object_utils(<%=obj.BlockId%>_reset_seq)

  /** Declare a typed sequencer object that the sequence can access */
  `uvm_declare_p_sequencer(axi_virtual_sequencer)

  /** Class Constructor */
  function new (string name = "<%=obj.BlockId%>_reset_seq");
    super.new(name);
  endfunction : new

  /** Raise an objection if this is the parent sequence */
  virtual task pre_body();
    super.pre_body();
    if (starting_phase!=null) begin
      starting_phase.raise_objection(this);
    end
  endtask: pre_body

  /** Drop an objection if this is the parent sequence */
  virtual task post_body();
    super.post_body();
    if (starting_phase!=null) begin
      starting_phase.drop_objection(this);
    end
  endtask: post_body

  virtual task body();
    `uvm_info("body", "Entered...", UVM_LOW)

    p_sequencer.reset_mp.reset <= 1'b1;

    repeat(10) @(posedge p_sequencer.reset_mp.clk);
    #2;
    p_sequencer.reset_mp.reset <= 1'b0;

    repeat(10) @(posedge p_sequencer.reset_mp.clk);
    p_sequencer.reset_mp.reset <= 1'b1;

    `uvm_info("body", "Exiting...", UVM_LOW)
  endtask: body

endclass: <%=obj.BlockId%>_reset_seq

