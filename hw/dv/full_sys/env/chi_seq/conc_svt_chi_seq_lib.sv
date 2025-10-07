`ifndef GUARD_CONC_SVT_CHI_SEQ_LIB_SV
`define GUARD_CONC_SVT_CHI_SEQ_LIB_SV
/** 
 * 
 *  This svt sequence - svt_chi_rn_transaction_dvm_write_semantic_sequence is extended further in order to override enable_non_blocking. svt_chi_rn_transaction_dvm_write_semantic_sequence is 
 *  used in svt_chi_rn_transaction_dvm_sync_sequence which has enable_non_blocking=0
 */

class conc_svt_chi_rn_transaction_dvm_write_semantic_sequence extends svt_chi_rn_transaction_dvm_write_semantic_sequence;

   /** 
   * Factory Registration. 
   */
  `svt_xvm_object_utils(conc_svt_chi_rn_transaction_dvm_write_semantic_sequence) 

  /**
   * Constructs the conc_svt_chi_rn_transaction_dvm_write_semantic_sequence sequence
   */
  function new(string name = "conc_svt_chi_rn_transaction_dvm_write_semantic_sequence");
    super.new(name);
  endfunction

  virtual task pre_start();
    super.pre_start();
    enable_non_blocking = 1;
  endtask

endclass
`endif // `ifndef GUARD_CONC_SVT_CHI_SEQ_LIB_SV 
