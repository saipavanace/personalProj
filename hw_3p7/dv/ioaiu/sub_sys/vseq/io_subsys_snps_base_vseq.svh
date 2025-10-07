class io_subsys_snps_base_vseq extends svt_axi_ace_master_base_virtual_sequence;
  `uvm_object_utils(io_subsys_snps_base_vseq)

  string mstr_agnt_seqr_str[`NUM_IOAIU_SVT_MASTERS];
  svt_axi_master_sequencer mstr_agnt_seqr_a[`NUM_IOAIU_SVT_MASTERS];
  svt_axi_cache            my_cache;
  svt_axi_master_agent     my_agent;
  `SVT_XVM(component)      my_component;
  concerto_env_cfg env_cfg;//placeholder
  int 	      t_ioaiu_en[int];
  int         ioaiu_num_trans;
  
  function new(string name = "io_subsys_snps_base_vseq");
    super.new(name);
  endfunction

  /**  Raise an objection if this is the parent sequence */
  virtual task pre_body();
    super.pre_body();
    if  (starting_phase!=null) begin
      starting_phase.raise_objection(this);
    end
    apply_seq_overrides();
  endtask: pre_body

  /**  Drop an objection if this is the parent sequence */
  virtual task post_body();
    super.post_body();
  /** Utility to print caches of all masters */
   `uvm_info("DEBUG_info", $psprintf("****printing caches**** \n"), UVM_LOW);
    print_caches();
    if  (starting_phase!=null) begin
      starting_phase.drop_objection(this);
    end
  endtask: post_body

  function void apply_seq_overrides();
    string axi_seq, ace_seq;
    if ($value$plusargs("axi_seq=%0s", axi_seq)) begin 
      if (axi_seq == "excl_seq") begin
        svt_axi_master_exclusive_test_sequence::type_id::set_type_override(svt_master_exclusive_test_sequence::get_type());
        io_subsys_axi_seq::type_id::set_type_override(io_subsys_axi_exclusive_seq::get_type());
      end else if (axi_seq == "sanity_seq")begin 
        io_subsys_axi_seq::type_id::set_type_override(io_subsys_axi_sanity_seq::get_type());
      end else if (axi_seq == "outstanding_xact_id_seq")begin 
        io_subsys_axi_seq::type_id::set_type_override(io_subsys_axi_outstanding_xact_id_seq::get_type());
      end else if (axi_seq == "unique_id_random_seq")begin 
        io_subsys_axi_seq::type_id::set_type_override(io_subsys_axi_unq_id_random_seq::get_type());
      end else if (axi_seq == "unique_id_wr_rd_seq")begin 
        io_subsys_axi_seq::type_id::set_type_override(io_subsys_axi_unq_id_wr_rd_seq::get_type());
      end else if (axi_seq == "write_data_before_addr_seq")begin 
        io_subsys_axi_seq::type_id::set_type_override(io_subsys_axi_wr_data_before_addr_seq::get_type());
      end else if (axi_seq == "aligned_addr_seq")begin 
        io_subsys_axi_seq::type_id::set_type_override(io_subsys_axi_aligned_addr_seq::get_type()); 
      end else if(axi_seq == "io_subsys_axi_atomic_seq") begin
       io_subsys_axi_seq::type_id::set_type_override(io_subsys_axi_atomic_seq::get_type());
      end else if (axi_seq == "narrow_single_beat_rd_seq") begin 
       svt_axi_seq::type_id::set_type_override(svt_narrow_single_beat_rd_seq::get_type());
      end else if (axi_seq == "narrow_single_beat_wr_seq") begin 
       svt_axi_seq::type_id::set_type_override(svt_narrow_single_beat_wr_seq::get_type());
      end else if (axi_seq == "svt_rd_after_wr_wrap_seq") begin 
       svt_axi_seq::type_id::set_type_override(svt_rd_after_wr_wrap_seq::get_type());
      end else if (axi_seq == "svt_rd_after_wr_seq") begin 
       svt_axi_seq::type_id::set_type_override(svt_rd_after_wr_seq::get_type());
      end else if (axi_seq == "wr_ordering_selfchk_seq") begin 
       svt_axi_seq::type_id::set_type_override(wr_ordering_selfchk_seq::get_type());
      end else begin 
	      `uvm_error(get_name(), $psprintf("axi_seq:%0s provided is not recognized", axi_seq))
      end 
    end
   
   if ($value$plusargs("ace_seq=%0s", ace_seq)) begin 
      if(ace_seq == "io_subsys_atomic_seq") begin
       io_subsys_ace_seq::type_id::set_type_override(io_subsys_atomic_seq::get_type());
      end else if (ace_seq == "io_subsys_dvm_seq")begin 
       io_subsys_ace_seq::type_id::set_type_override(io_subsys_dvm_seq::get_type());
      end else begin 
	`uvm_error(get_name(), $psprintf("ace_seq:%0s provided is not recognized", axi_seq))
      end 
    end


  endfunction:apply_seq_overrides

endclass: io_subsys_snps_base_vseq
