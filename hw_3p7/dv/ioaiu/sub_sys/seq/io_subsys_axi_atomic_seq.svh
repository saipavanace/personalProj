class io_subsys_axi_atomic_seq extends io_subsys_axi_seq;
  `svt_xvm_object_utils(io_subsys_axi_atomic_seq)
  `svt_xvm_declare_p_sequencer(svt_axi_master_sequencer)
 
  svt_atomic_seq seq;

  function new(string name = "io_subsys_axi_atomic_seq");
    super.new(name);
  endfunction: new

  virtual task pre_body();
    super.pre_body();
  endtask:pre_body;

  virtual task body();
    if ((nativeif == "axi5") && (cfg.useCache==0) && (cfg.atomic_transactions_enable==1)) begin
    seq = svt_atomic_seq::type_id::create($psprintf("%0s_%0s_mstr_seq_p%0d", nativeif, instname, portid));
    seq.atmstr_wt = cfg.atmstr;
    seq.atmld_wt  = cfg.atmld ;
    seq.atmcmp_wt = cfg.atmcmp;
    seq.atmswp_wt = cfg.atmswp;
    seq.sequence_length = mstr_cfg.num_txns;
    //init_seq(seq);
    `uvm_info(get_full_name(), $psprintf("Entered body ... svt_atomic_seq, sequence_length %0d atmstr %0d atmld %0d atmcmp %0d atmswp %0d",seq.sequence_length,cfg.atmstr,cfg.atmld,cfg.atmcmp,cfg.atmswp), UVM_LOW)
    seq.start(p_sequencer);
    `uvm_info(get_full_name(), $psprintf("Exited body ... svt_atomic_seq"), UVM_LOW)
    end
  endtask:body

endclass:io_subsys_axi_atomic_seq
