class reg2axi_adapter extends uvm_reg_adapter;

  /** The svt_axi_master_reg_transaction is extended from  the svt_axi_transaction class, with additional constraints required for uvm reg */
  svt_axi_master_reg_transaction axi_reg_trans;

  /** The svt_axi_port_configuration ,which is passed from the Master Agent */
  svt_axi_port_configuration p_cfg=new("p_cfg");

// UVM Field Macros
// ****************************************************************************
  `uvm_object_utils_begin(reg2axi_adapter)
    `uvm_field_object(axi_reg_trans, UVM_ALL_ON);
    `uvm_field_object(p_cfg,     UVM_ALL_ON);
  `uvm_object_utils_end
  //----------------------------------------------------------------------------
  /**
  * CONSTUCTOR: Create a new transaction instance, passing the appropriate argument
  * values to the parent class.
  *
  * @param name Instance name of the transaction
  */

  // -----------------------------------------------------------------------------
  function new(string name= "reg2axi_adapter");
    super.new(name);
    supports_byte_enable = 1;
    provides_responses = 1;
    `svt_amba_debug("new", "Reg Model Constructed  .... ");
  endfunction

  // -----------------------------------------------------------------------------
  function uvm_sequence_item reg2bus(const ref uvm_reg_bus_op rw);
    bit [`SVT_AXI_TRANSACTION_BURST_SIZE_64:0] burst_size_e;
    bit [`SVT_AXI_WSTRB_WIDTH - 1 :0] wstrb = '0;
  
    axi_reg_trans = svt_axi_master_reg_transaction::type_id::create("axi_reg_trans");
    axi_reg_trans.port_cfg = p_cfg;
  
    if (rw.n_bits > p_cfg.data_width)
      `svt_fatal("reg2bus", "Transfer requested with a data width greater than the configured system data width. Please reconfigure the system with the appropriate data width or reduce the data size");
     `svt_amba_debug("reg2bus", $sformatf("n_bits data = %b log_base_2 n_bits", rw.n_bits));
  
     // Turn the TR burst size into an AXI one (smallest burst is 8bit)
     burst_size_e = $clog2(rw.n_bits) - $clog2(8);
     if (! axi_reg_trans.randomize() with {
       if ((p_cfg.axi_interface_type == svt_axi_port_configuration::AXI3)|| (p_cfg.axi_interface_type == svt_axi_port_configuration::AXI4)|| (p_cfg.axi_interface_type == svt_axi_port_configuration::AXI4_LITE)) {
         axi_reg_trans.xact_type == ((rw.kind == UVM_WRITE) ? svt_axi_master_reg_transaction::WRITE : svt_axi_master_reg_transaction::READ);
  	   }
       else if ((p_cfg.axi_interface_type == svt_axi_port_configuration::AXI_ACE)|| (p_cfg.axi_interface_type == svt_axi_port_configuration::ACE_LITE)) {
  	   axi_reg_trans.xact_type == svt_axi_transaction::COHERENT;
   	   axi_reg_trans.coherent_xact_type == ((rw.kind == UVM_READ) ? svt_axi_master_transaction::READNOSNOOP : svt_axi_master_transaction::WRITENOSNOOP);
  	 }
         axi_reg_trans.addr == rw.addr;
         axi_reg_trans.burst_length == 1;
         axi_reg_trans.burst_type == svt_axi_transaction::INCR;
         axi_reg_trans.burst_size == burst_size_e;
         axi_reg_trans.cache_type == 0;
        }) begin
        `svt_fatal("reg2bus", " Transaction randomization failed");
     end
  
    if (rw.kind == UVM_WRITE) begin
      axi_reg_trans.data[0] = rw.data;
      if (burst_size_e > 0) begin
        for(int i = 0; i < (2**burst_size_e); i++)
          wstrb[i] = 1'h1;
        end
      else begin
          wstrb[0] = 1'h1;
      end
      axi_reg_trans.wstrb[0] = wstrb;
    end
    else if (rw.kind == UVM_READ) begin
      axi_reg_trans.rresp     = new[axi_reg_trans.burst_length];
    end
  
    return axi_reg_trans;
  endfunction : reg2bus

  // -----------------------------------------------------------------------------
  function void bus2reg(uvm_sequence_item bus_item,
                                ref uvm_reg_bus_op rw);
    svt_axi_master_transaction bus_trans;
    if (!$cast(bus_trans,bus_item)) begin
       `svt_fatal("bus2reg", "bus2reg: Provided bus_item is not of the correct type");
      return;
    end
  
    if (bus_trans!= null) begin
      rw.addr = bus_trans.addr;
      rw.data = bus_trans.data[0] ;
      if (bus_trans.xact_type == svt_axi_master_reg_transaction::READ) begin
        rw.kind = UVM_READ;	    
        `svt_amba_debug("bus2reg" , $sformatf("bus_trans.data = %0h (READ)", bus_trans.data[0]));
        if (bus_trans.rresp[0] == svt_axi_transaction::OKAY)
          rw.status = UVM_IS_OK;
        else
          rw.status  = UVM_NOT_OK;
      end 
      else begin
        if (bus_trans.xact_type == svt_axi_master_reg_transaction::WRITE) begin
          rw.kind = UVM_WRITE;
          if (bus_trans.bresp == svt_axi_transaction::OKAY)
            rw.status = UVM_IS_OK;
          else
            rw.status  = UVM_NOT_OK;
        end
      end
    end
    else
      rw.status  = UVM_NOT_OK;
  endfunction

endclass : reg2axi_adapter