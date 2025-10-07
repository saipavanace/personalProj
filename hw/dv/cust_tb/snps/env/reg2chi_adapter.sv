class reg2chi_adapter extends uvm_reg_adapter;

  svt_chi_rn_transaction chi_trans;
  svt_chi_node_configuration p_cfg;

  `uvm_object_utils_begin(reg2chi_adapter)
    `uvm_field_object(chi_trans, UVM_ALL_ON);
    `uvm_field_object(p_cfg,     UVM_ALL_ON);
  `uvm_object_utils_end


  function new(string name = "reg2chi_adapter");
    super.new(name);
    supports_byte_enable = 1;
    provides_responses = 1;
    `uvm_info("reg2chi_adapter", "Constructed", UVM_LOW);
  endfunction


   // Convert a UVM REG transaction into an CHI transaction
  virtual function uvm_sequence_item reg2bus(const ref uvm_reg_bus_op rw);
    `uvm_info("reg2chi_adapter", "Entered reg2bus...", UVM_LOW);
    `uvm_info("reg2chi_adapter", $sformatf("n_bits = %0d", rw.n_bits), UVM_LOW);
    if (rw.n_bits > p_cfg.flit_data_width)
      `uvm_fatal("reg2chi_adapter", "Transfer requested with a data width greater than the configured system data width. Please reconfigure the system with the appropriate data width or reduce the data size");
    if(p_cfg.wysiwyg_enable == 1)
      `uvm_fatal("reg2chi_adapter", "reg2bus: unsupported wysiwyg_enable setting. the adapter only supports wysiwyg_enable=0"); 

    chi_trans = svt_chi_rn_transaction::type_id::create("chi_trans");
    if(rw.kind == UVM_READ) 
      chi_trans.xact_type=svt_chi_transaction::READNOSNP;
    else begin 
      chi_trans.xact_type=svt_chi_transaction::WRITENOSNPPTL;
      chi_trans.data = rw.data;
      `uvm_info("reg2chi_adapter" , $sformatf("chi_trans.data = %0h (WRITE)", chi_trans.data), UVM_LOW);  
      chi_trans.exp_comp_ack = 0; 
    end 
    chi_trans.addr         = rw.addr;
    chi_trans.cfg = p_cfg; 
    if(rw.n_bits == 32) begin 
      chi_trans.data_size = svt_chi_rn_transaction::SIZE_4BYTE;
    chi_trans.byte_enable = 4'hf; 
    end  
    else if(rw.n_bits == 64) begin 
      chi_trans.data_size = svt_chi_rn_transaction::SIZE_8BYTE;
      chi_trans.byte_enable = 8'hff; 
    end   
    else 
      `uvm_fatal("reg2chi_adapter", "reg2bus: unsupported size of register. Only 32-bit and 64-bit register access are supported");
    chi_trans.is_likely_shared = 1'b0;
    chi_trans.snp_attr_is_snoopable = 1'b0;
    chi_trans.order_type = svt_chi_transaction::REQ_EP_ORDERING_REQUIRED;
    chi_trans.mem_attr_is_early_wr_ack_allowed = 1'b0;
    chi_trans.mem_attr_mem_type = svt_chi_transaction::DEVICE;

    `uvm_info("reg2chi_adapter", "Exiting reg2bus...", UVM_LOW);

    return chi_trans;

  endfunction : reg2bus


  // Turn an CHI transaction into a UVM REG transaction
  virtual function void bus2reg(uvm_sequence_item bus_item,
                                ref uvm_reg_bus_op rw);
    svt_chi_rn_transaction bus_trans;
    `uvm_info("reg2chi_adapter", "Entering bus2reg...", UVM_LOW);

    if (!$cast(bus_trans,bus_item)) begin
      `uvm_fatal("NOT_CHI_TYPE", "reg2chi_adapter::bus2reg: Provided bus_item is not of the correct type")
      return;
    end

    if (bus_trans!= null) begin
      rw.data = bus_trans.data ;
      rw.addr = bus_trans.addr; 
      if (rw.kind == UVM_READ) begin
        `uvm_info("reg2chi_adapter" , $sformatf("bus_trans.data = %0h (READ)", bus_trans.data), UVM_LOW);
      end
      
	  if (bus_trans.response_resp_err_status== svt_chi_transaction::NORMAL_OKAY)
        rw.status = UVM_IS_OK;
      else
        rw.status  = UVM_NOT_OK;
      foreach(bus_trans.data_resp_err_status[i]) begin
        if(bus_trans.data_resp_err_status[i] != svt_chi_transaction::NORMAL_OKAY) begin
          rw.status  = UVM_NOT_OK;
          break;
        end 
      end 
    end
    else
      rw.status  = UVM_NOT_OK;

    `uvm_info("reg2chi_adapter", "Exiting bus2reg...", UVM_LOW);
  endfunction

endclass