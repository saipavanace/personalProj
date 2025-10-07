class reg2chi_adapter extends uvm_reg_adapter;

  `uvm_object_utils_begin(reg2chi_adapter)
  `uvm_object_utils_end


  function new(string name = "reg2chi_adapter");
     super.new(name);
     supports_byte_enable = 1;
     provides_responses = 1;
    `uvm_info("reg2chi_adapter", "Constructed", UVM_LOW);
  endfunction
 
  //convert the specified  <uvm_reg_bus_op> to a corresponding <uvm_sequence_item> subtype that defines the bus
  // transaction. in this case we convert to a denaliChiTransaction 
  virtual function uvm_sequence_item reg2bus(const ref uvm_reg_bus_op rw);

    denaliChiTransaction chi = denaliChiTransaction::type_id::create("chi");

    //Here we create a protocol transaction which represents the requested reg operation.
    //the protocol transaction should be set with enough information for the VIP to create a legal transaction
    //By default the transaction should be creates rather then being randomized.  

    `uvm_info(get_type_name(), "UVM_REG: In reg2bus", UVM_HIGH);

    if (rw.kind == UVM_WRITE) begin
      chi.ReqOpCode   = DenaliSvChi::DENALI_CHI_REQOPCODE_WriteNoSnpPtl;                  
      chi.Size        = DenaliSvChi::DENALI_CHI_SIZE_WORD; //32 bits - size of a DUT register 
      chi.Addr        = rw.addr;
      chi.Data        = new[rw.n_bits / 8];
      	for (int i=0; i < rw.n_bits / 8 ; i++) begin
        	chi.Data[i] = rw.data[(7+i*8)-:8];
      	end
    end else begin 
      chi.ReqOpCode   = DenaliSvChi::DENALI_CHI_REQOPCODE_ReadNoSnp;
      chi.Size        = DenaliSvChi::DENALI_CHI_SIZE_WORD; //32 bits - size of a DUT register
      chi.Addr        = rw.addr;
    end
    chi.NonSecure   = 0;
    chi.MemAttr     = DenaliSvChi::DENALI_CHI_V8MEMATTR_DEVICE_nGnRnE; //MemAttr[1]=1
    chi.Order	    = 3; //DEVICE
    chi.Endian      = 0;
    chi.TagOp       =  DenaliSvChi::DENALI_CHI_TAG_OP_Invalid;
    chi.TagOpResp   =  DenaliSvChi::DENALI_CHI_TAG_OP_Invalid;
    chi.TagOpData   =  DenaliSvChi::DENALI_CHI_TAG_OP_Invalid;
    chi.PAS         =  DenaliSvChi::DENALI_CHI_PAS_Secure;


    `uvm_info(get_type_name(), "UVM_REG: done reg2bus", UVM_HIGH);
    //return the translated protocol item to be transmitted
    return chi;

  endfunction : reg2bus



  // this method copy members the given bus-specific ~bus_item~ to corresponding members of the provided
  // ~bus_rw~ instance. Unlike <reg2bus>, the resulting transaction is not allocated from scratch
  // in other words we translate the protocol transaction (chi) to a uvm_reg operation.  
  virtual function void bus2reg(uvm_sequence_item bus_item, ref uvm_reg_bus_op rw);

    denaliChiTransaction chi;

    if (!$cast(chi,bus_item)) begin
      `uvm_fatal("NOT_CHI_TYPE", "Provided bus_item is not of the correct type")
      return;
    end

   `uvm_info(get_type_name(), "UVM_REG: In bus2reg", UVM_HIGH);

    if (chi.ReqOpCode == DenaliSvChi::DENALI_CHI_REQOPCODE_WriteNoSnpPtl)
    	rw.kind = UVM_WRITE;
    else if (chi.ReqOpCode == DenaliSvChi::DENALI_CHI_REQOPCODE_ReadNoSnp)
    	rw.kind = UVM_READ;
    else
      //`uvm_fatal("WRONG_OPCODE",$sformatf("Wrong opcode in bus_item reqopcode %0d",chi.ReqOpCode))


    rw.addr = chi.Addr;

    for (int i=0; (i < rw.n_bits / 8) && (i < chi.Data.size()) ; i++) begin
      rw.data[(7+i*8)-:8] = chi.Data[i];
    end

    // Status for write transactions
    if (chi.RespErr == DENALI_CHI_RESPERR_Okay)
    	rw.status = UVM_IS_OK;
    else
        rw.status = UVM_NOT_OK;

   `uvm_info(get_type_name(), "UVM_REG: bus2reg Done", UVM_HIGH);
  endfunction
  
endclass : reg2chi_adapter

