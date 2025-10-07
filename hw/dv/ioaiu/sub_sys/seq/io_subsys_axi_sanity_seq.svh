//=====================================================================================================================================
// uvm_sequence <-- io_subsys_base_seq <-- io_subsys_axi_seq <-- io_subsys_axi_sanity_seq
// svt_sequence <-- svt_axi_master_base_sequence <-- svt_axi_master_sanity_test_sequence
/* 
 */
//====================================================================================================================================

class io_subsys_axi_sanity_seq extends io_subsys_axi_seq;
  `svt_xvm_object_utils(io_subsys_axi_sanity_seq)
  `svt_xvm_declare_p_sequencer(svt_axi_master_sequencer)
  
  svt_axi_master_sanity_test_sequence seq;
  
  function new(string name = "io_subsys_axi_sanity_seq");
    super.new(name);
  endfunction: new

  virtual task pre_body();
    super.pre_body();
  endtask:pre_body;

  virtual task body();
    `uvm_info(get_full_name(), $psprintf("Entered body sanity_seq..."), UVM_LOW)
    seq = svt_axi_master_sanity_test_sequence::type_id::create($psprintf("%0s_%0s_mstr_seq_p%0d", nativeif, instname, portid));
    init_seq(seq);
    `uvm_info(get_full_name(), $psprintf("Starting svt_axi_master_sanity_test_sequence  sequence_length:%0d", seq.sequence_length), UVM_LOW)
    seq.start(p_sequencer);
    `uvm_info(get_full_name(), $psprintf("Exited body sanity_seq..."), UVM_LOW)
  endtask:body

virtual task init_seq(svt_axi_master_base_sequence seq);
    //AXI4 sequences
    svt_axi_master_sanity_test_sequence             sanity_seq;
     if ($cast(sanity_seq, seq)) begin
        bit insert_init_delay;
        bit is_zero_delay;
        int seq_burst_length;
        bit seq_data_before_addr;
        insert_init_delay     = $urandom_range(0,1);
        is_zero_delay         = $urandom_range(0,1);
        seq_burst_length      = $urandom_range(1,16);
        seq_data_before_addr  = $urandom_range(1,100);  
        sanity_seq.reasonable_sequence_length.constraint_mode(0);
        sanity_seq.sequence_length = mstr_cfg.num_txns;
        //uvm_config_db#(int unsigned)::set(null, "*", "sequence_length",mstr_cfg.num_txns );
        uvm_config_db#(bit)::set(null, "*", "insert_init_delay",insert_init_delay);
        uvm_config_db#(bit)::set(null, "*", "is_zero_delay",is_zero_delay);
        `uvm_info(get_full_name(), $sformatf("sanity_seq:: cfg.core_id:%0d portid:%0d ",cfg.core_id,portid), UVM_LOW)
        if(cfg.core_id == -1) begin
          uvm_config_db#(int unsigned)::set(null, "uvm_test_top.m_concerto_env.snps.svt.amba_system_env.axi_system[0].master[portid]*", "seq_burst_length", seq_burst_length);
        end
        uvm_config_db#(int unsigned)::set(null, "*", "seq_data_before_addr", seq_data_before_addr);
        `uvm_info(get_full_name(), $sformatf("sanity_seq:: insert_init_delay:%0d is_zero_delay:%0d seq_burst_length:%0d seq_data_before_addr=%0d",insert_init_delay,is_zero_delay,seq_burst_length,seq_data_before_addr), UVM_NONE)

      end  
  endtask: init_seq

endclass:io_subsys_axi_sanity_seq
