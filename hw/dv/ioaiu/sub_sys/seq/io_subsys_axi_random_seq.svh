//=====================================================================================================================================
// uvm_sequence <-- io_subsys_base_seq <-- io_subsys_axi_seq <-- io_subsys_axi_random_seq 
// svt_sequence <-- svt_axi_master_base_sequence <-- svt_axi_master_random_sequence
/* 
 *  This sequence generates random master transactions.
 */
//====================================================================================================================================

class io_subsys_axi_random_seq extends io_subsys_axi_seq;
  `svt_xvm_object_utils(io_subsys_axi_random_seq)
  `svt_xvm_declare_p_sequencer(svt_axi_master_sequencer)
  
  svt_axi_master_random_sequence seq;
  
  function new(string name = "io_subsys_axi_random_seq");
    super.new(name);
  endfunction: new

  virtual task pre_body();
    super.pre_body();
  endtask:pre_body;

  virtual task body();
    `uvm_info(get_full_name(), $psprintf("Entered body random_seq..."), UVM_LOW)
    seq = svt_axi_master_random_sequence::type_id::create($psprintf("%0s_%0s_mstr_seq_p%0d", nativeif, instname, portid));
    init_seq(seq);
    `uvm_info(get_full_name(), $psprintf("Starting svt_axi_master_random_sequence sequence_length:%0d", seq.sequence_length), UVM_LOW)
    seq.start(p_sequencer);
    `uvm_info(get_full_name(), $psprintf("Exited body random_seq..."), UVM_LOW)
  endtask:body
virtual task init_seq(svt_axi_master_base_sequence seq);
    //AXI4 sequences
    svt_axi_master_random_sequence                  random_seq;
   
      if ($cast(random_seq, seq)) begin 
        random_seq.reasonable_sequence_length.constraint_mode(0);
        random_seq.sequence_length = mstr_cfg.num_txns;
      end 
  endtask      

endclass:io_subsys_axi_random_seq
