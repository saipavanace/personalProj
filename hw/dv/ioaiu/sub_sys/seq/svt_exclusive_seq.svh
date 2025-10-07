// =============================================================================
/**
 *   This sequence performs Exclusive read transaction followed by Exclusive
 *   write transaction with same control fields as previous Exclusive read.
 *   Exclusive write commences only after response for Exclusive read is
 *   received by the master.
 **/
class svt_master_exclusive_test_sequence extends svt_axi_master_exclusive_test_sequence;
   
  /** Number of Transactions in this sequence. */
  rand int unsigned sequence_length = 10;
  
  /** Constrain the sequence length to a reasonable value */
  constraint reasonable_sequence_length {
    sequence_length == 10;
  }

  /** Handles for configurations. */
  svt_configuration get_cfg;
  svt_axi_port_configuration port_cfg;

  /** Indicates the slave number to be targetted */
  rand int slv_num = 0;

  `svt_xvm_declare_p_sequencer(svt_axi_master_sequencer)
  
  `svt_xvm_object_utils_begin(svt_master_exclusive_test_sequence)
    `svt_xvm_field_int(sequence_length, `SVT_XVM_ALL_ON)
    `svt_xvm_field_int(slv_num, `SVT_XVM_ALL_ON)
  `svt_xvm_object_utils_end

  function new(string name="svt_master_exclusive_test_sequence");
   
    super.new(name);
  endfunction

  /** Raise an objection if this is the parent sequence */
`ifdef SVT_UVM_TECHNOLOGY
  virtual task pre_body();
    uvm_phase starting_phase_for_curr_seq ;
    `svt_xvm_note("pre_body", "Entered ...")
`ifdef SVT_UVM_12_OR_HIGHER
    starting_phase_for_curr_seq = get_starting_phase();
`else
    starting_phase_for_curr_seq = starting_phase;
`endif
  if (starting_phase_for_curr_seq!=null) begin
    starting_phase_for_curr_seq.raise_objection(this);
  end
  endtask: pre_body
`endif
  /** Drop an objection if this is the parent sequence */
`ifdef SVT_UVM_TECHNOLOGY
  virtual task post_body();
    uvm_phase starting_phase_for_curr_seq;
    `svt_xvm_note("post_body", "Entered ...")
`ifdef SVT_UVM_12_OR_HIGHER
    starting_phase_for_curr_seq = get_starting_phase();
`else
    starting_phase_for_curr_seq = starting_phase;
`endif
  if (starting_phase_for_curr_seq!=null) begin
    starting_phase_for_curr_seq.drop_objection(this);
  end
  endtask: post_body
`endif

  virtual task body();
    /** Flag to determine whether to use the slave number in transactions or not */
    bit use_slv_num = 1'b0;
  
    /** Local variables */
    bit status;
    bit use_slv_num_status;
    bit slv_num_status;
    int ex_wr_id;
    int min_id_width;
    int id_q[$];
    int id_val; 
    bit [`SVT_AXI_MAX_ADDR_WIDTH-1:0] ex_wr_addr; 
    int burst_size_int;
    int burst_type_int;
    int prot_type_int ;
    bit[`SVT_AXI_MAX_ADDR_WIDTH-1:0] lo_addr;
    bit[`SVT_AXI_MAX_ADDR_WIDTH-1:0] hi_addr;


    /** Getting svt_axi_port_configuration object handle. */ 
    p_sequencer.get_cfg(get_cfg);
    if (!$cast(port_cfg, get_cfg)) begin
      `svt_xvm_fatal("body", "Unable to $cast the configuration to a svt_axi_system_configuration class");
    end  

`ifdef SVT_UVM_TECHNOLOGY
    status = uvm_config_db#(int unsigned)::get(null, get_full_name(), "sequence_length", sequence_length);
    slv_num_status = uvm_config_db#(int unsigned)::get(null, get_full_name(), "slv_num", slv_num);
    use_slv_num_status = uvm_config_db#(bit)::get(null, get_full_name(), "use_slv_num", use_slv_num);
`else
    status = m_sequencer.get_config_int({get_type_name(), ".sequence_length"}, sequence_length);
    slv_num_status = m_sequencer.get_config_int({get_type_name(), ".slv_num"}, slv_num);
    use_slv_num_status = m_sequencer.get_config_int({get_full_name(), ".use_slv_num"}, use_slv_num);
`endif
    `svt_xvm_debug("body", $sformatf("sequence_length is 'd%0d as a result of %0s.", sequence_length, status ? "the config DB" : "randomization"));
    `svt_xvm_debug("body", $sformatf("use_slv_num is 'd%0d as a result of %0s.", use_slv_num, use_slv_num_status ? "the config DB" : "default value"));
    `svt_xvm_debug("body", $sformatf("slv_num is 'd%0d as a result of %0s.", slv_num, slv_num_status ? "the config DB" : "default value"));
    if(port_cfg.axi_interface_category == svt_axi_port_configuration::AXI_READ_WRITE) begin
    
      /** Randomly select an Address range for the selected slave if we can use slv_num */
      if(use_slv_num)
        if (!port_cfg.sys_cfg.get_slave_addr_range(mstr_num,slv_num,lo_addr,hi_addr,null))
          `svt_xvm_warning("body", $sformatf("Unable to obtain a memory range for slave index 'd%0d", slv_num));

      for (int k=0; k < sequence_length; k++) begin 
        for (int i = 0; i < 5; i++) begin
          //int burst_size_int = svt_axi_transaction::burst_size_enum'(i);
          //int burst_type_int = svt_axi_transaction::burst_type_enum'(i % 3);
          //int prot_type_int = svt_axi_transaction::prot_type_enum'(i);

          if (port_cfg.use_separate_rd_wr_chan_id_width == 1)  begin
            if (port_cfg.write_chan_id_width < port_cfg.read_chan_id_width) begin
              min_id_width = port_cfg.write_chan_id_width;
            end 
            else begin
              min_id_width = port_cfg.read_chan_id_width;
            end
            /** Generating different id within the range of id_width */
            for(int k= 0;k <= (1<<min_id_width-1); k++)  begin
              id_q.push_back(k);
            end
            id_q.shuffle;
            id_val = id_q.pop_front();
          end

          if ((port_cfg.axi_interface_type == svt_axi_port_configuration::AXI_ACE) || (port_cfg.axi_interface_type == svt_axi_port_configuration::ACE_LITE)) begin
            _read_xact_type  = svt_axi_transaction::COHERENT;
            _write_xact_type = svt_axi_transaction::COHERENT;
            use_slv_num = 1;
          end
          else begin
            _read_xact_type  = svt_axi_transaction::READ;
            _write_xact_type = svt_axi_transaction::WRITE;
          end

  
          for(int j = 0; j < 2; j++) begin
            int xact_type_int = (j%2==0) ? _read_xact_type:
                                           _write_xact_type;

            `svt_xvm_do_with(req,
            {
              xact_type == xact_type_int;
              atomic_type == svt_axi_transaction::EXCLUSIVE;
              if(!j && use_slv_num) {
                addr >= lo_addr;
                addr <= hi_addr-(burst_length*(1<<burst_size));
                coherent_xact_type == svt_axi_transaction::READNOSNOOP;
                if (port_cfg.use_separate_rd_wr_chan_id_width == 1) 
                id == id_val; 
              }
              else if(j == 1 && use_slv_num)
                coherent_xact_type == svt_axi_transaction::WRITENOSNOOP;
              if (j == 1) {
                addr == ex_wr_addr;
                burst_size == burst_size_int;
                burst_type == burst_type_int;
                prot_type == prot_type_int;
                id == ex_wr_id;
              }
            })   
  
            ex_wr_addr = req.addr;
            burst_size_int = req.burst_size;
            burst_type_int = req.burst_type;
            prot_type_int  = req.prot_type;
            ex_wr_id = req.id;
            
            if( j== 0) begin
              bit exclusive_read_success = 1;
              //wait for transaction to complete
              wait ((req.addr_status == svt_axi_transaction::ACCEPT || req.addr_status == svt_axi_transaction::ABORTED) &&
                    (req.data_status == svt_axi_transaction::ACCEPT || req.data_status == svt_axi_transaction::ABORTED));
              foreach (req.rresp[i]) begin
                if (req.rresp[i] != svt_axi_transaction::EXOKAY) begin
                  exclusive_read_success = 0;
                  break;
                end
              end
              if (!exclusive_read_success) begin
                `svt_xvm_note("body", "Exclusive READ transaction completed but did not got an EXOKAY response ...")
              end
              else begin
                `svt_xvm_note("body", "Exclusive READ transaction completed successfully with an EXOKAY response ...")
              end
            end
            else begin
              //wait for transaction to complete
              wait ((req.addr_status == svt_axi_transaction::ACCEPT || req.addr_status == svt_axi_transaction::ABORTED) &&
                    (req.data_status == svt_axi_transaction::ACCEPT || req.data_status == svt_axi_transaction::ABORTED) &&
                    (req.write_resp_status == svt_axi_transaction::ACCEPT || req.write_resp_status == svt_axi_transaction::ABORTED));
              if (req.write_resp_status == svt_axi_transaction::ACCEPT) begin
                if (req.bresp != svt_axi_transaction::EXOKAY) begin
                  `svt_xvm_note("body", "Exclusive WRITE transaction completed but did not got an EXOKAY response ...")
                end
                else begin
                  `svt_xvm_note("body", "Exclusive WRITE transaction completed successfully with an EXOKAY response ...")
                end
              end
            end
          
          end     
        
        end
     
      end
    
    end
    `svt_xvm_note("body", "Exiting...")
  endtask: body
  
  virtual function bit is_applicable(svt_configuration cfg);
    svt_axi_port_configuration master_cfg;
    if(!$cast(master_cfg, cfg)) begin
      `svt_xvm_fatal("is_applicable", "Unable to cast cfg to svt_axi_port_configuration type");
    end
    if(
        (master_cfg.exclusive_access_enable == 1) &&
        (master_cfg.axi_interface_category == svt_axi_port_configuration::AXI_READ_WRITE) 
      )
      return 1;
    return 0;  
  endfunction : is_applicable

endclass : svt_master_exclusive_test_sequence


