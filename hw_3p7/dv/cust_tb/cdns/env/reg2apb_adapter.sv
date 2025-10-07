<%if((obj.useResiliency == 1) || (obj.DebugApbInfo.length > 0)){%>
class reg2apb_adapter extends uvm_reg_adapter;

  `uvm_object_utils(reg2apb_adapter)

  function new(string name = "reg2apb_adapter");
    super.new(name);

    supports_byte_enable = 1;
    //this specify that the adapter is operating in blocking mode. i.e the read / write tasks will return after the sequencer wrote the response back.
    provides_responses   = 1;

  endfunction

  //convert the specified  <uvm_reg_bus_op> to a corresponding <uvm_sequence_item> subtype that defines the bus
  // transaction. in this case we convert to a denaliCdn_apbTransaction 
  virtual function uvm_sequence_item reg2bus(const ref uvm_reg_bus_op rw);

    denaliCdn_apbTransaction apb = denaliCdn_apbTransaction::type_id::create("apb");

    //Here we create a protocol transaction which represents the requested reg operation.
    //the protocol transaction should be set with enough information for the VIP to create a legal transaction
    //By default the transaction should be creates rather then being randomized.  

    `uvm_info(get_type_name(), "UVM_REG: in reg2bus ", UVM_HIGH);
    //sets the reg operation kind Read/Write
    if (rw.kind == UVM_WRITE) begin
      apb.Direction   = DenaliSvCdn_apb::DENALI_CDN_APB_DIRECTION_WRITE;                  
    end else begin 
      apb.Direction   = DenaliSvCdn_apb::DENALI_CDN_APB_DIRECTION_READ;
    end

    //sets the data which we want to write
    if (rw.kind == UVM_WRITE) begin
      apb.Data        = rw.data;
    end
    apb.Addr = rw.addr;

    `uvm_info(get_type_name(), "UVM_REG: Out reg2bus ", UVM_HIGH);
    //return the translated protocol item to be transmitted
    return apb;

  endfunction : reg2bus


  // this method copy members the given bus-specific ~bus_item~ to corresponding members of the provided
  // ~bus_rw~ instance. Unlike <reg2bus>, the resulting transaction is not allocated from scratch
  // in other words we translate the protocol transaction (axi) to a uvm_reg operation.  
  virtual function void bus2reg(uvm_sequence_item bus_item, ref uvm_reg_bus_op rw);

    denaliCdn_apbTransaction apb;

    `uvm_info(get_type_name(), "UVM_REG: In bus2reg", UVM_HIGH);
    if (!$cast(apb,bus_item)) begin
      `uvm_fatal("NOT_APB_TYPE", "Provided bus_item is not of the correct type")
      return;
    end


    //sets the reg operation kind Read/Write
    rw.kind = (apb.Direction == DenaliSvCdn_apb::DENALI_CDN_APB_DIRECTION_WRITE) ? UVM_WRITE : UVM_READ;

    //sets the address we want to access
    rw.addr = apb.Addr;

    //sets the data which was tx/rx    
    for (int i=0; (i < (rw.n_bits)) ; i++) begin
      rw.data[(7+i*8)-:8] = apb.Data[i];
    `uvm_info(get_type_name(), $sformatf("UVM_REG: Out bus2reg %0d apbdata = %0x ",i,  apb.Data[i]), UVM_NONE)
    end
    rw.data = apb.Data;
    `uvm_info(get_type_name(), $sformatf("UVM_REG: Out bus2reg apbdata = %0x ", apb.Data), UVM_NONE)

    // Status for write transactions
    if (apb.Slverr) begin
      rw.status = UVM_NOT_OK;   
    end
    else begin
      rw.status = UVM_IS_OK;
    end
    `uvm_info(get_type_name(), $sformatf("UVM_REG: Out bus2reg rw apbdata = %0x ", rw.data), UVM_NONE)

    `uvm_info(get_type_name(), "UVM_REG: Out bus2reg", UVM_HIGH);

  endfunction

endclass : reg2apb_adapter
<% } %>
