`ifndef GUARD_IOAIU_AXI_ACE_MASTER_BASE_VIRTUAL_SEQUENCE_CONTROLS_SVH
`define GUARD_IOAIU_AXI_ACE_MASTER_BASE_VIRTUAL_SEQUENCE_CONTROLS_SVH

/** 
 * Controls for the test writer
 */
class ioaiu_axi_ace_master_base_virtual_sequence_controls extends uvm_object;

  /** Distribution weight for generation of READNOSNOOP transactions */
  int readnosnoop_wt = 0;

  /** Distribution weight for generation of READONCE transactions */
  int readonce_wt = 0;

  /** Distribution weight for generation of READCLEAN transactions */
  int readclean_wt = 0;

  /** Distribution weight for generation of READNOTSHAREDDIRTY transactions */
  int readnotshareddirty_wt = 0;

  /** Distribution weight for generation of READSHARED transactions */
  int readshared_wt = 0;

  /** Distribution weight for generation of READUNIQUE transactions */
  int readunique_wt = 0;

  /** Distribution weight for generation of CLEANUNIQUE transactions */
  int cleanunique_wt = 0;

  /** Distribution weight for generation of CLEANSHARED transactions */
  int cleanshared_wt = 0;
  
  /** Distribution weight for generation of CLEANSHAREDPERSIST transactions */
  int cleansharedpersist_wt = 0;

  /** Distribution weight for generation of CLEANINVALID transactions */
  int cleaninvalid_wt = 0;

  /** Distribution weight for generation of MAKEUNIQUE transactions */
  int makeunique_wt = 0;

  /** Distribution weight for generation of MAKEINVALID transactions */
  int makeinvalid_wt = 0;

  /** Distribution weight for generation of WRITENOSNOOP transactions */
  int writenosnoop_wt = 0;

  /** Distribution weight for generation of WRITEUNIQUE transactions */
  int writeunique_wt = 0;

  /** Distribution weight for generation of WRITELINEUNIQUE transactions */
  int writelineunique_wt = 0;

`ifdef SVT_ACE5_ENABLE
   /** Distribution weight for generation of WRITEUNIQUEPTLSTASH transactions */
  int writeuniqueptlstash_wt = 0;

 /** Distribution weight for generation of WRITEUNIQUEFULLSTASH transactions */
  int writeuniquefullstash_wt = 0;

 /** Distribution weight for generation of stashonceunique transactions */
  int stashonceunique_wt = 0;

 /** Distribution weight for generation of stashonceshared transactions */
  int stashonceshared_wt = 0;

 /** Distribution weight for generation of CMO transactions */
  int cmo_wt = 0;

  /** Distribution weight for generation of CMO transactions */
  int writeptlcmo_wt = 0;

 /** Distribution weight for generation of CMO transactions */
  int writefullcmo_wt = 0;

 /** Distribution weight for generation of CLEANSHARED_ON_WRITE transactions */
  int cleanshared_on_write_wt = 0;
  
  /** Distribution weight for generation of CLEANSHAREDPERSIST_ON_WRITE transactions */
  int cleansharedpersist_on_write_wt = 0;

  /** Distribution weight for generation of CLEANINVALID_ON_WRITE transactions */
  int cleaninvalid_on_write_wt = 0;

`ifdef SVT_AXI_RME_INTERNAL_ENABLE
 /** Distribution weight for generation of CLEANINVALIDPOPA_ON_WRITE transactions */
  int cleaninvalidpopa_on_write_wt = 0;
`endif

 /** Distribution weight for generation of CLEANSHAREDDEEPPERSIST_ON_WRITE transactions */
  int cleanshareddeeppersist_on_write_wt = 0;

`endif

 /** Distribution weight for generation of WRITEBACK transactions */
  int writeback_wt = 0;

  /** Distribution weight for generation of WRITECLEAN transactions */
  int writeclean_wt = 0;

  /** Distribution weight for generation of EVICT transactions */
  int evict_wt = 0;

  /** Distribution weight for generation of WRITEEVICT transactions */
  int writeevict_wt = 0;

  /** Distribution weight for generation of READONCECLEANINVALID transactions */
  int readoncecleaninvalid_wt = 0;
  
  /** Distribution weight for generation of READONCEMAKEINVALID transactions */
  int readoncemakeinvalid_wt = 0;  

  /** Distribution weight for generation of WRITE transactions */
  int write_wt = 0;

  /** Distribution weight for generation of READ transactions */
  int read_wt = 0;

`uvm_object_param_utils(ioaiu_axi_ace_master_base_virtual_sequence_controls)

  function new(string name = "ioaiu_axi_ace_master_base_virtual_sequence_controls");
    super.new(name);
  endfunction

endclass 

`endif // `ifndef GUARD_IOAIU_AXI_ACE_MASTER_BASE_VIRTUAL_SEQUENCE_CONTROLS_SVH
