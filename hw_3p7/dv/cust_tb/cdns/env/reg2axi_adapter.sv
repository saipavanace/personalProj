class reg2axi_adapter extends uvm_reg_adapter;

  `uvm_object_utils(reg2axi_adapter)

  function new(string name = "reg2axi_adapter");
    super.new(name);

    //this specify that the adapter is operating in blocking mode. i.e the read / write tasks will return after the sequencer wrote the response back.
    provides_responses = 1;

  endfunction

  //convert the specified  <uvm_reg_bus_op> to a corresponding <uvm_sequence_item> subtype that defines the bus
  // transaction. in this case we convert to a denaliCdn_axiTransaction 
  virtual function uvm_sequence_item reg2bus(const ref uvm_reg_bus_op rw);

    denaliCdn_axiTransaction axi = denaliCdn_axiTransaction::type_id::create("axi");

    //Here we create a protocol transaction which represents the requested reg operation.
    //the protocol transaction should be set with enough information for the VIP to create a legal transaction
    //By default the transaction should be creates rather then being randomized.  

    `uvm_info(get_type_name(), "UVM_REG: in reg2bus ", UVM_HIGH);
    //sets the reg operation kind Read/Write
    if (rw.kind == UVM_WRITE) begin
      axi.Direction   = DenaliSvCdn_axi::DENALI_CDN_AXI_DIRECTION_WRITE;                  
    end else begin 
      axi.Direction   = DenaliSvCdn_axi::DENALI_CDN_AXI_DIRECTION_READ;
    end

    //sets the data which we want to write
    if (rw.kind == UVM_WRITE) begin
      axi.Data        = new[rw.n_bits / 8];
      for (int i=0; i < rw.n_bits / 8 ; i++) begin
        axi.Data[i] = rw.data[(7+i*8)-:8];
      end
    end

    //sets the address we want to access 
    axi.StartAddress = rw.addr;

    //sets other protocol, interface properties 
    axi.Cacheable    = DenaliSvCdn_axi::DENALI_CDN_AXI_CACHEMODE_NON_CACHEABLE; // For ACE applications, set it to Cacheable as needed
    axi.Access       = DenaliSvCdn_axi::DENALI_CDN_AXI_ACCESS_NORMAL;    
    axi.Kind         = DenaliSvCdn_axi::DENALI_CDN_AXI_BURSTKIND_INCR;
    axi.Size         = DenaliSvCdn_axi::DENALI_CDN_AXI_TRANSFERSIZE_WORD;
    axi.Secure       = DenaliSvCdn_axi::DENALI_CDN_AXI_SECUREMODE_SECURE;
    axi.Length       = 1;
    axi.IdTag        = 1;                                                       // Set IdTag if needed
    axi.Domain       = DenaliSvCdn_axi::DENALI_CDN_AXI_DOMAIN_SYSTEM;

    `uvm_info(get_type_name(), "UVM_REG: Out reg2bus ", UVM_HIGH);
    //return the translated protocol item to be transmitted
    return axi;

  endfunction : reg2bus


  // this method copy members the given bus-specific ~bus_item~ to corresponding members of the provided
  // ~bus_rw~ instance. Unlike <reg2bus>, the resulting transaction is not allocated from scratch
  // in other words we translate the protocol transaction (axi) to a uvm_reg operation.  
  virtual function void bus2reg(uvm_sequence_item bus_item, ref uvm_reg_bus_op rw);

    denaliCdn_axiTransaction axi;

    `uvm_info(get_type_name(), "UVM_REG: In bus2reg", UVM_HIGH);
    if (!$cast(axi,bus_item)) begin
      `uvm_fatal("NOT_AXI_TYPE", "Provided bus_item is not of the correct type")
      return;
    end


    //sets the reg operation kind Read/Write
    rw.kind = (axi.Direction == DenaliSvCdn_axi::DENALI_CDN_AXI_DIRECTION_WRITE) ? UVM_WRITE : UVM_READ;

    //sets the address we want to access
    rw.addr = axi.StartAddress;


    //sets the data which was tx/rx    
    for (int i=0; (i < rw.n_bits / 8) && (i < axi.Data.size()) ; i++) begin
      rw.data[(7+i*8)-:8] = axi.Data[i];
    end

    // Status for write transactions
    if (axi.Direction == DenaliSvCdn_axi::DENALI_CDN_AXI_DIRECTION_WRITE)
    begin
      	if (axi.Resp == DENALI_CDN_AXI_RESPONSE_OKAY || 
	    axi.Resp == DENALI_CDN_AXI_RESPONSE_EXOKAY)
        	rw.status = UVM_IS_OK;
      	else
        	rw.status = UVM_NOT_OK;   

    end
    // Status for read transactions
    else if (axi.Direction == DenaliSvCdn_axi::DENALI_CDN_AXI_DIRECTION_READ)
    begin
    	rw.status = UVM_IS_OK;
	    for (int ii=0; (ii <= axi.Length-1) ; ii++) begin
		if ((axi.TransfersResp[ii] == DENALI_CDN_AXI_RESPONSE_SLVERR) || (axi.TransfersResp[ii] == DENALI_CDN_AXI_RESPONSE_DECERR)) begin
			rw.status = UVM_NOT_OK;		
			break;
	        end
            end
    end

    `uvm_info(get_type_name(), "UVM_REG: Out bus2reg", UVM_HIGH);

  endfunction

endclass : reg2axi_adapter
