`ifndef GUARD_IOAIU_AXI_ACE_MASTER_BASE_SEQUENCE_SVH
`define GUARD_IOAIU_AXI_ACE_MASTER_BASE_SEQUENCE_SVH

/**
 * Base class - svt_axi_ace_master_base_sequence from which all the ACE non-virtual sequences are extended. This
 * class is the base class for sequences that run on multiple master
 * sequencers. In addition to being extended to create new sequences, this
 * sequence is also called within some virtual sequences like
 * svt_axi_cacheline_initialization and svt_axi_cacheline_invalidation. This
 * sequence cannot be used as is, but must be called from within a virtual
 * sequence that is extended from svt_axi_ace_master_base_virtual_sequence.
 */

 /**
  * class - ioaiu_axi_ace_master_base_sequence is extended from svt_axi_ace_master_base_sequence in order to reuse everything contained in base
  * However if any updates needed in addition, we can do it over here.
  */
class ioaiu_axi_ace_master_base_sequence extends svt_axi_ace_master_base_sequence;

  `svt_xvm_declare_p_sequencer(svt_axi_master_sequencer)
  `svt_xvm_object_utils(ioaiu_axi_ace_master_base_sequence)

  virtual task pre_body();
    super.pre_body();
  endtask

  function new(string name="ioaiu_axi_ace_master_base_sequence");
    super.new(name);
  endfunction

endclass


`endif // `ifndef GUARD_IOAIU_AXI_ACE_MASTER_BASE_SEQUENCE_SVH
