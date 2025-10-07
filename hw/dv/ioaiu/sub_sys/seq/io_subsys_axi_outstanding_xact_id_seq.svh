//=====================================================================================================================================
// uvm_sequence <-- io_subsys_base_seq <-- io_subsys_axi_seq <-- io_subsys_axi_outstanding_xact_id_seq
// svt_sequence <-- svt_axi_master_base_sequence <-- svt_axi_master_outstanding_xact_id_sequence
/* 
 */
//====================================================================================================================================

class io_subsys_axi_outstanding_xact_id_seq extends io_subsys_axi_seq;
  `svt_xvm_object_utils(io_subsys_axi_outstanding_xact_id_seq)
  `svt_xvm_declare_p_sequencer(svt_axi_master_sequencer)
  
  svt_axi_master_outstanding_xact_id_sequence seq;
  
  function new(string name = "io_subsys_axi_outstanding_xact_id_seq");
    super.new(name);
  endfunction: new

  virtual task pre_body();
    super.pre_body();
  endtask:pre_body;

  virtual task body();
    `uvm_info(get_full_name(), $psprintf("Entered body outstanding_xact_id_seq..."), UVM_LOW)
    seq = svt_axi_master_outstanding_xact_id_sequence::type_id::create($psprintf("%0s_%0s_mstr_seq_p%0d", nativeif, instname, portid));
    init_seq(seq);
    `uvm_info(get_full_name(), $psprintf("Starting svt_axi_master_outstanding_xact_id_sequence sequence_length:%0d", seq.sequence_length), UVM_LOW)
    seq.start(p_sequencer);
    `uvm_info(get_full_name(), $psprintf("Exited body outstanding_xact_id_seq..."), UVM_LOW)
  endtask:body
virtual task init_seq(svt_axi_master_base_sequence seq);
    //AXI4 sequences
    svt_axi_master_outstanding_xact_id_sequence     outstanding_xact_id_seq;
   
     if ($cast(outstanding_xact_id_seq, seq)) begin
        bit multi_same_id_select;
        multi_same_id_select = $urandom_range(0,1); 
        outstanding_xact_id_seq.reasonable_sequence_length.constraint_mode(0);
        outstanding_xact_id_seq.sequence_length = mstr_cfg.num_txns;
       // uvm_config_db#(int unsigned)::set(null, "*" "sequence_length",mstr_cfg.num_txns );
        uvm_config_db#(bit)::set(null, "*", "multi_same_id_select", multi_same_id_select);
        `uvm_info(get_full_name(), $psprintf("outstanding_xact_id_seq:: multi_same_id_select:%0d",multi_same_id_select), UVM_NONE)

      end
endtask 

endclass:io_subsys_axi_outstanding_xact_id_seq
