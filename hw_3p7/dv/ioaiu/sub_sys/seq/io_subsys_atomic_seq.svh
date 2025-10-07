//=====================================================================================================================================
// uvm_sequence <-- io_subsys_ace_seq <-- io_subsys_atomic_seq 
// svt_sequence <-- svt_axi_master_base_sequence <-- svt_axi_ace_master_base_sequence <-- svt_axi_ace_master_generic_sequence
// svt_sequence <-- svt_axi_master_base_sequence <--svt_axi_master_base_sequence<--svt_atomic_seq
// This sequence run the svt_axi_ace_master_generic_sequence and svt_atomic_seq
//====================================================================================================================================
class io_subsys_atomic_seq extends io_subsys_ace_seq;
  `svt_xvm_object_utils(io_subsys_atomic_seq)
  `svt_xvm_declare_p_sequencer(svt_axi_master_sequencer)
 
  svt_atomic_seq seq;

  function new(string name = "io_subsys_atomic_seq");
    super.new(name);
  endfunction: new

  virtual task pre_body();
    super.pre_body();
  endtask:pre_body;

  virtual task body();
    if (nativeif == "acelite-e" && (cfg.atomic_transactions_enable==1)) begin
    seq = svt_atomic_seq::type_id::create($psprintf("%0s_%0s_mstr_seq_p%0d", nativeif, instname, portid));
    seq.atmstr_wt = cfg.atmstr;
    seq.atmld_wt  = cfg.atmld ;
    seq.atmcmp_wt = cfg.atmcmp;
    seq.atmswp_wt = cfg.atmswp;
    seq.sequence_length = mstr_cfg.num_txns;
    init_seq(seq);
    `uvm_info(get_full_name(), $psprintf("Entered body ... svt_atomic_seq"), UVM_LOW)
    seq.start(p_sequencer);
    `uvm_info(get_full_name(), $psprintf("Exited body ... svt_atomic_seq"), UVM_LOW)
    end
  endtask:body

endclass:io_subsys_atomic_seq
