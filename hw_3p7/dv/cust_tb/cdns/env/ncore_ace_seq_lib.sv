`ifndef _USER_ACE_FULL_SEQ_LIB
`define _USER_ACE_FULL_SEQ_LIB

class aceFullUvmUserTransaction extends denaliCdn_axiTransaction;

	`uvm_object_utils(aceFullUvmUserTransaction)

	aceFullUvmUserConfig cfg;

	//Chosen Segment Index
	rand int chosenSegmentIndex;

	function new(string name = "aceFullUvmUserTransaction");
		super.new(name);       
	endfunction : new 

 	function void pre_randomize();
		cdnAxiUvmSequencer seqr;
		super.pre_randomize();                             
	
		if (!$cast(seqr,get_sequencer())) begin
			`uvm_fatal(get_type_name(),"failed $cast(seqr,get_sequencer())");
		end

		if (!$cast(cfg,seqr.pAgent.cfg)) begin
			`uvm_fatal(get_type_name(),"failed $cast(cfg,seqr.pAgent.cfg))");
		end  

		this.SpecVer = (cfg.spec_ver == CDN_AXI_CFG_SPEC_VER_AMBA4 ? DENALI_CDN_AXI_SPECVERSION_AMBA4 :DENALI_CDN_AXI_SPECVERSION_AMBA3);    
		this.SpecSubtype = (cfg.spec_subtype == CDN_AXI_CFG_SPEC_SUBTYPE_ACE ? DENALI_CDN_AXI_SPECSUBTYPE_ACE : DENALI_CDN_AXI_SPECSUBTYPE_BASE);
		this.SpecInterface = (cfg.spec_interface == CDN_AXI_CFG_SPEC_INTERFACE_FULL ?  DENALI_CDN_AXI_SPECINTERFACE_FULL : DENALI_CDN_AXI_SPECINTERFACE_LITE);
		
		if (cfg.pins.rdata.size >= 1024) begin
			this.BurstMaxSize = DENALI_CDN_AXI_TRANSFERSIZE_K_BITS;
		end
		else if (cfg.pins.rdata.size >= 512) begin
			this.BurstMaxSize = DENALI_CDN_AXI_TRANSFERSIZE_SIXTEEN_WORDS;
		end
		else if (cfg.pins.rdata.size >= 256) begin
			this.BurstMaxSize = DENALI_CDN_AXI_TRANSFERSIZE_EIGHT_WORDS;
		end
		else if (cfg.pins.rdata.size >= 128) begin
			this.BurstMaxSize = DENALI_CDN_AXI_TRANSFERSIZE_FOUR_WORDS;
		end
		else if (cfg.pins.rdata.size >= 64) begin
			this.BurstMaxSize = DENALI_CDN_AXI_TRANSFERSIZE_TWO_WORDS;
		end
		else if (cfg.pins.rdata.size >= 32) begin
			this.BurstMaxSize = DENALI_CDN_AXI_TRANSFERSIZE_WORD;
		end
		else if (cfg.pins.rdata.size >= 16) begin
			this.BurstMaxSize = DENALI_CDN_AXI_TRANSFERSIZE_HALFWORD;
		end
		else if (cfg.pins.rdata.size >= 8) begin
			this.BurstMaxSize = DENALI_CDN_AXI_TRANSFERSIZE_BYTE;
		end
		
		this.CacheLineSize = cfg.cache_line_size;

		this.SpecVer.rand_mode(0);
		this.SpecSubtype.rand_mode(0);
		this.SpecInterface.rand_mode(0);
		this.BurstMaxSize.rand_mode(0);
		this.CacheLineSize.rand_mode(0);

	endfunction    
     
	constraint burstSizeCfgConstraint {                
		BurstSize <= (cfg.pins.rdata.size/8); 
		BurstSize <= (cfg.pins.wdata.size/8);
	}

	constraint burstIdCfgConstraint {      
		IdTag < (1 <<  cfg.pins.awid.size);
		IdTag < (1 << cfg.pins.arid.size);                  
	}

	//NOTE: This constraints is not enough , it doesn't take into considerations length and size to be inside memory segment.
	constraint burstAddresscfgConstraint { 

		solve chosenSegmentIndex before StartAddress;

		chosenSegmentIndex < cfg.memory_segments.size();
		chosenSegmentIndex >= 0;

		foreach (cfg.memory_segments[ii]) {

			if (IsBarrier == DENALI_CDN_AXI_ISBARRIER_NOT_BARRIER && 
					IsDvm == DENALI_CDN_AXI_DVM_NOT_DVM && 
					ii == chosenSegmentIndex) {
					
				StartAddress < cfg.memory_segments[ii].high_address;
				StartAddress >= cfg.memory_segments[ii].low_address;
				Domain == cfg.memory_segments[ii].domain;
			}
		}
	}

endclass

class ace5FullUvmUserTransaction extends denaliCdn_axiTransaction;

	`uvm_object_utils(ace5FullUvmUserTransaction)

	ace5FullUvmUserConfig cfg;

	//Chosen Segment Index
	rand int chosenSegmentIndex;

	function new(string name = "ace5FullUvmUserTransaction");
		super.new(name);       
	endfunction : new 

 	function void pre_randomize();
		cdnAxiUvmSequencer seqr;
		super.pre_randomize();                             
	
		if (!$cast(seqr,get_sequencer())) begin
			`uvm_fatal(get_type_name(),"failed $cast(seqr,get_sequencer())");
		end

		if (!$cast(cfg,seqr.pAgent.cfg)) begin
			`uvm_fatal(get_type_name(),"failed $cast(cfg,seqr.pAgent.cfg))");
		end  

		case(cfg.spec_ver)
	    	CDN_AXI_CFG_SPEC_VER_AMBA5: begin
	    		this.SpecVer = DENALI_CDN_AXI_SPECVERSION_AMBA5;
	    	end
	    	CDN_AXI_CFG_SPEC_VER_AMBA4: begin
	    		this.SpecVer = DENALI_CDN_AXI_SPECVERSION_AMBA4;
	    	end
	    	default: begin
	    		this.SpecVer = DENALI_CDN_AXI_SPECVERSION_AMBA3;
	    	end
    	endcase	
		this.SpecSubtype = (cfg.spec_subtype == CDN_AXI_CFG_SPEC_SUBTYPE_ACE ? DENALI_CDN_AXI_SPECSUBTYPE_ACE : DENALI_CDN_AXI_SPECSUBTYPE_BASE);
		this.SpecInterface = (cfg.spec_interface == CDN_AXI_CFG_SPEC_INTERFACE_FULL ?  DENALI_CDN_AXI_SPECINTERFACE_FULL : DENALI_CDN_AXI_SPECINTERFACE_LITE);
		
       $display("CUST_TB_CDNS_ACE5_SET_UP");
		if (cfg.pins.rdata.size >= 1024) begin
			this.BurstMaxSize = DENALI_CDN_AXI_TRANSFERSIZE_K_BITS;
		end
		else if (cfg.pins.rdata.size >= 512) begin
			this.BurstMaxSize = DENALI_CDN_AXI_TRANSFERSIZE_SIXTEEN_WORDS;
		end
		else if (cfg.pins.rdata.size >= 256) begin
			this.BurstMaxSize = DENALI_CDN_AXI_TRANSFERSIZE_EIGHT_WORDS;
		end
		else if (cfg.pins.rdata.size >= 128) begin
			this.BurstMaxSize = DENALI_CDN_AXI_TRANSFERSIZE_FOUR_WORDS;
		end
		else if (cfg.pins.rdata.size >= 64) begin
			this.BurstMaxSize = DENALI_CDN_AXI_TRANSFERSIZE_TWO_WORDS;
		end
		else if (cfg.pins.rdata.size >= 32) begin
			this.BurstMaxSize = DENALI_CDN_AXI_TRANSFERSIZE_WORD;
		end
		else if (cfg.pins.rdata.size >= 16) begin
			this.BurstMaxSize = DENALI_CDN_AXI_TRANSFERSIZE_HALFWORD;
		end
		else if (cfg.pins.rdata.size >= 8) begin
			this.BurstMaxSize = DENALI_CDN_AXI_TRANSFERSIZE_BYTE;
		end
		
		this.CacheLineSize = cfg.cache_line_size;

		this.SpecVer.rand_mode(0);
		this.SpecSubtype.rand_mode(0);
		this.SpecInterface.rand_mode(0);
		this.BurstMaxSize.rand_mode(0);
		this.CacheLineSize.rand_mode(0);

	endfunction    
     
	constraint burstSizeCfgConstraint {                
		BurstSize <= (cfg.pins.rdata.size/8); 
		BurstSize <= (cfg.pins.wdata.size/8);
	}

	constraint burstIdCfgConstraint {      
		IdTag < (1 <<  cfg.pins.awid.size);
		IdTag < (1 << cfg.pins.arid.size);                  
	}

	//NOTE: This constraints is not enough , it doesn't take into considerations length and size to be inside memory segment.
	constraint burstAddresscfgConstraint { 

		solve chosenSegmentIndex before StartAddress;

		chosenSegmentIndex < cfg.memory_segments.size();
		chosenSegmentIndex >= 0;

		foreach (cfg.memory_segments[ii]) {

			if (IsBarrier == DENALI_CDN_AXI_ISBARRIER_NOT_BARRIER && 
					IsDvm == DENALI_CDN_AXI_DVM_NOT_DVM && 
					ii == chosenSegmentIndex) {
					
				StartAddress < cfg.memory_segments[ii].high_address;
				StartAddress >= cfg.memory_segments[ii].low_address;
				Domain == cfg.memory_segments[ii].domain;
			}
		}
	}
	

endclass

class ace5FullUvmUserSeq extends cdnAxiUvmSequence;
	
	// ***************************************************************
	// Use the UVM registration macro for this class.
	// ***************************************************************
	`uvm_object_utils(ace5FullUvmUserSeq)
	
	

	// ***************************************************************
	// Method : new
	// Desc.  : Call the constructor of the parent class.
	// ***************************************************************
	function new(string name = "ace5FullUvmUserSeq");
		super.new(name);        
	endfunction : new

	denaliCdn_axiTransaction trans;

	virtual task pre_body();
		if (starting_phase != null) begin
			starting_phase.raise_objection(this);
		end    
	endtask

	// ***************************************************************
	// Method : post_body
	// Desc.  : Drop the objection raised earlier
	// ***************************************************************
	virtual task post_body();
		if (starting_phase != null) begin
			// Drain time
			#5000;
			starting_phase.drop_objection(this);
		end    
	endtask
	

endclass : ace5FullUvmUserSeq

class aceFullUvmUserSeq extends cdnAxiUvmSequence;
	
	// ***************************************************************
	// Use the UVM registration macro for this class.
	// ***************************************************************
	`uvm_object_utils(aceFullUvmUserSeq)  

	// ***************************************************************
	// Method : new
	// Desc.  : Call the constructor of the parent class.
	// ***************************************************************
	function new(string name = "aceFullUvmUserSeq");
		super.new(name);        
	endfunction : new

	denaliCdn_axiTransaction trans;

	virtual task pre_body();
		if (starting_phase != null) begin
			starting_phase.raise_objection(this);
		end    
	endtask

	// ***************************************************************
	// Method : post_body
	// Desc.  : Drop the objection raised earlier
	// ***************************************************************
	virtual task post_body();
		if (starting_phase != null) begin
			// Drain time
			#5000;
			starting_phase.drop_objection(this);
		end    
	endtask 

endclass : aceFullUvmUserSeq
	

class userSnoopSeq extends aceFullUvmUserSeq;

	// ***************************************************************
	// Use the UVM registration macro for this class.
	// ***************************************************************
	`uvm_object_utils(userSnoopSeq)  

	// ***************************************************************
	// Method : new
	// Desc.  : Call the constructor of the parent class.
	// ***************************************************************
	function new(string name = "userSnoopSeq");
		super.new(name);        
	endfunction : new

	virtual task body();
		for (int i=0; i<100; i++) begin
			`uvm_do_with(trans,{
				trans.Type == DENALI_CDN_AXI_TR_Snoop;
                                trans.StartAddress == 40'h1FF0;
				trans.Domain == DENALI_CDN_AXI_DOMAIN_INNER;
			});
			get_response(trans);	
		end

	endtask : body

endclass : userSnoopSeq
// ****************************************************************************
// Class : dvmMessageSeq
// Desc. : This sequence sends a DVM Message transaction
// ****************************************************************************
class dvmMessageSeq extends uvm_sequence;
  
  denaliCdn_axiTransaction dvmTrans;
  rand denaliCdn_axiDvmTypeT dvmType;
  denaliCdn_axiTransaction response;
  uvm_sequence_item item;
  rand denaliCdn_axiTransferSizeT size;
  
  constraint dvm_type {
  	dvmType inside {
    	DENALI_CDN_AXI_DVMTYPE_TLB_INVALIDATE,
      	DENALI_CDN_AXI_DVMTYPE_BRANCH_PREDICTOR_INVALIDATE,
      	DENALI_CDN_AXI_DVMTYPE_PHYSICAL_INSTRUCTION_CACHE_INVALIDATE,
      	DENALI_CDN_AXI_DVMTYPE_VIRTUAL_INSTRUCTION_CACHE_INVALIDATE,
      	DENALI_CDN_AXI_DVMTYPE_SYNC,
      	DENALI_CDN_AXI_DVMTYPE_HINT
    };		
  }

  constraint size_c {
    size inside {
       DENALI_CDN_AXI_TRANSFERSIZE_SIXTEEN_WORDS,
       DENALI_CDN_AXI_TRANSFERSIZE_EIGHT_WORDS,
       DENALI_CDN_AXI_TRANSFERSIZE_FOUR_WORDS,
       DENALI_CDN_AXI_TRANSFERSIZE_TWO_WORDS,
       DENALI_CDN_AXI_TRANSFERSIZE_WORD
     };
  }

  `uvm_object_utils(dvmMessageSeq)

  `uvm_declare_p_sequencer(cdnAxiUvmSequencer)

  function new (string name = "dvmMessageSeq");
    super.new(name);
  endfunction : new

  task body();
    `uvm_info(get_type_name(), $psprintf("Starting dvmMessageSeq sequence"), UVM_HIGH);
    dvmTrans = denaliCdn_axiTransaction::type_id::create("dvmTrans");

    // Turn on pre-defined constraints	
    `uvm_create(dvmTrans);
    dvmTrans.ace_no_dvm_const.constraint_mode(0);
    dvmTrans.ace_dvm_const.constraint_mode(1);

    `uvm_info(get_type_name(), $psprintf("Sending DVM Message Transaction size:%s",size.name()), UVM_HIGH);
    `uvm_rand_send_with(dvmTrans, {
        dvmTrans.Direction == DENALI_CDN_AXI_DIRECTION_READ;
        dvmTrans.ReadSnoop == DENALI_CDN_AXI_READSNOOP_DVM_Message;
        dvmTrans.DvmType == dvmType;
        dvmTrans.DvmHasVa == 0;
        dvmTrans.IdTag == 0;
        dvmTrans.Size == size;
      })
    
    // Turn off pre-defined constraints	
    dvmTrans.ace_no_dvm_const.constraint_mode(1);
    dvmTrans.ace_dvm_const.constraint_mode(0);
     // Blocking sequence. wait until response.
    `uvm_info("body",$sformatf("waiting for response"),UVM_LOW);
      get_response(item, dvmTrans.get_transaction_id());
    if (!$cast(response, item))
        `uvm_fatal(get_type_name(), "$cast(response, item) call failed!");

  endtask
endclass : dvmMessageSeq
// ****************************************************************************
// Class : dvmCompleteSeq
// Desc. : This sequence sends a DVM Complete transaction
// ****************************************************************************
class dvmCompleteSeq extends uvm_sequence;
   
  denaliCdn_axiTransaction dvmTrans;
  denaliCdn_axiTransaction response;
  uvm_sequence_item item;

  `uvm_object_utils(dvmCompleteSeq)
  `uvm_declare_p_sequencer(cdnAxiUvmSequencer)

  function new (string name = "dvmCompleteSeq");
    super.new(name);
  endfunction : new

  task body();
    `uvm_info(get_type_name(), $psprintf("Starting dvmCompleteSeq sequence"), UVM_HIGH);
    dvmTrans = denaliCdn_axiTransaction::type_id::create("dvmTrans");

    // Turn on pre-defined constraints	
    `uvm_create(dvmTrans);
    dvmTrans.ace_no_dvm_const.constraint_mode(0);
    dvmTrans.ace_dvm_const.constraint_mode(1);

    `uvm_info(get_type_name(), $psprintf("Sending DVM Complete Transaction"), UVM_HIGH);
    `uvm_rand_send_with(dvmTrans, {
        dvmTrans.Direction == DENALI_CDN_AXI_DIRECTION_READ;
        dvmTrans.ReadSnoop == DENALI_CDN_AXI_READSNOOP_DVM_Complete;
      })

    // Turn off pre-defined constraints	
    dvmTrans.ace_no_dvm_const.constraint_mode(1);
    dvmTrans.ace_dvm_const.constraint_mode(0);
     // Blocking sequence. wait until response.
    `uvm_info("body",$sformatf("waiting for response"),UVM_LOW);
      get_response(item, dvmTrans.get_transaction_id());
    if (!$cast(response, item))
        `uvm_fatal(get_type_name(), "$cast(response, item) call failed!");

  endtask
endclass : dvmCompleteSeq

// ----------------------------------------------------------------------------
// Class : cdnAxiUvmBlockingWriteSeq
// This class extends the uvm_sequence and implements a blocking Write Transaction.
// The sequence finishes only once the Write transaction in done.
// ----------------------------------------------------------------------------
class cdnAxiUvmBlockingWriteSeq extends  aceFullUvmUserSeq;

  // ---------------------------------------------------------------
  // The sequence item (transaction) that will be randomized and
  // passed to the driver.
  // ---------------------------------------------------------------
  rand aceFullUvmUserTransaction trans;

  // ---------------------------------------------------------------
  // Possible input write snoop to the sequence
  // ---------------------------------------------------------------
  rand denaliCdn_axiWriteSnoopT writeSnoop;

  // ---------------------------------------------------------------
  // Possible input address to the sequence
  // ---------------------------------------------------------------
  rand reg [43:0] address;

  // ---------------------------------------------------------------
  // Possible input kind to the sequence
  // ---------------------------------------------------------------
  rand denaliCdn_axiBurstKindT kind;

  // ---------------------------------------------------------------
  // Possible input secure to the sequence (AWPROT[1])
  // ---------------------------------------------------------------
  rand denaliCdn_axiSecureModeT secure;

  // ---------------------------------------------------------------
  // The sequence item (transaction) that will is returned
  // with the Ended callback once the Write transaction in done.
  // ---------------------------------------------------------------
  denaliCdn_axiTransaction response;
  uvm_sequence_item item;

 constraint Write_Sequence_Const
  {
  	kind inside { DENALI_CDN_AXI_BURSTKIND_INCR, DENALI_CDN_AXI_BURSTKIND_WRAP };
   	secure != DENALI_CDN_AXI_SECUREMODE_UNSET;
  }
  // ---------------------------------------------------------------
  // Use the UVM Sequence macro for this class.
  // ---------------------------------------------------------------
  `uvm_object_utils_begin(cdnAxiUvmBlockingWriteSeq)
    `uvm_field_object(trans, UVM_ALL_ON)
    `uvm_field_object(response, UVM_ALL_ON)
  `uvm_object_utils_end



  // ---------------------------------------------------------------
  // Method : new
  // Desc.  : Call the constructor of the parent class.
  // ---------------------------------------------------------------
  function new(string name = "cdnAxiUvmBlockingWriteSeq");
    super.new(name);
  endfunction : new

  // ---------------------------------------------------------------
  // Method : body
  // Desc.  : AXI Write Transaction.
  // ---------------------------------------------------------------
  virtual task body();
    `uvm_do_with(trans,
    	{trans.Direction == DENALI_CDN_AXI_DIRECTION_WRITE;
    	trans.WriteSnoop == writeSnoop;
    	trans.StartAddress == address;
    	trans.Kind == kind;
    	trans.Secure == secure;
    });

    // Blocking sequence. wait until response.
    get_response(item, trans.get_transaction_id());
    if (!$cast(response, item))
    	`uvm_fatal(get_type_name(), "$cast(response, item) call failed!");

  endtask : body

endclass

// ----------------------------------------------------------------------------
// Class : cdnAxiUvmBlockingReadSeq
// This class extends the uvm_sequence and implements a blocking Transaction.
// The sequence finishes only once the transaction in done.
// ----------------------------------------------------------------------------
class cdnAxiUvmBlockingReadSeq extends  aceFullUvmUserSeq;

  // ---------------------------------------------------------------
  // The sequence item (transaction) that will be randomized and
  // passed to the driver.
  // ---------------------------------------------------------------
  rand aceFullUvmUserTransaction trans;

  // ---------------------------------------------------------------
  // Possible input read snoop  to the sequence
  // ---------------------------------------------------------------
  rand denaliCdn_axiReadSnoopT readSnoop;

  // ---------------------------------------------------------------
  // Possible input address to the sequence
  // ---------------------------------------------------------------
  rand reg [43:0] address;

  // ---------------------------------------------------------------
  // Possible input kind to the sequence
  // ---------------------------------------------------------------
  rand denaliCdn_axiBurstKindT kind;

  // ---------------------------------------------------------------
  // Possible input secure to the sequence (ARPROT[1])
  // ---------------------------------------------------------------
  rand denaliCdn_axiSecureModeT secure;

  // ---------------------------------------------------------------
  // The sequence item (transaction) that will is returned
  // with the Ended callback once the Read transaction in done.
  // ---------------------------------------------------------------
  denaliCdn_axiTransaction response;
  uvm_sequence_item item;

 constraint Read_Sequence_Const
  {
  	kind inside { DENALI_CDN_AXI_BURSTKIND_FIXED, DENALI_CDN_AXI_BURSTKIND_INCR, DENALI_CDN_AXI_BURSTKIND_WRAP };
   	secure != DENALI_CDN_AXI_SECUREMODE_UNSET;
   	//Allowed values in Ace
   	readSnoop inside {
  	        DENALI_CDN_AXI_READSNOOP_UNSET,
  	        DENALI_CDN_AXI_READSNOOP_ReadOnce,
  	        DENALI_CDN_AXI_READSNOOP_ReadShared,
  	        DENALI_CDN_AXI_READSNOOP_ReadClean,
  	        DENALI_CDN_AXI_READSNOOP_ReadNotSharedDirty,
  	        DENALI_CDN_AXI_READSNOOP_ReadUnique,
  	        DENALI_CDN_AXI_READSNOOP_CleanShared,
  	        DENALI_CDN_AXI_READSNOOP_CleanInvalid,
  	        DENALI_CDN_AXI_READSNOOP_CleanUnique,
  	        DENALI_CDN_AXI_READSNOOP_MakeUnique,
  	        DENALI_CDN_AXI_READSNOOP_MakeInvalid,
  			DENALI_CDN_AXI_READSNOOP_DVM_Complete,
  		    DENALI_CDN_AXI_READSNOOP_DVM_Message
  	    };
  }
  // ---------------------------------------------------------------
  // Use the UVM Sequence macro for this class.
  // ---------------------------------------------------------------
  `uvm_object_utils_begin(cdnAxiUvmBlockingReadSeq)
    `uvm_field_object(trans, UVM_ALL_ON)
    `uvm_field_object(response, UVM_ALL_ON)
  `uvm_object_utils_end



  // ---------------------------------------------------------------
  // Method : new
  // Desc.  : Call the constructor of the parent class.
  // ---------------------------------------------------------------
  function new(string name = "cdnAxiUvmBlockingReadSeq");
    super.new(name);
  endfunction : new

  // ---------------------------------------------------------------
  // Method : body
  // Desc.  : AXI READ Transaction.
  // ---------------------------------------------------------------
  virtual task body();
    `uvm_do_with(trans,
    	{trans.Direction == DENALI_CDN_AXI_DIRECTION_READ;
    	trans.ReadSnoop == readSnoop;
    	trans.StartAddress == address;
    	trans.Kind == kind;
    	trans.Secure == secure;
    });

    // Blocking sequence. wait until response.
    get_response(item, trans.get_transaction_id());
    if (!$cast(response, item))
    	`uvm_fatal(get_type_name(), "$cast(response, item) call failed!");

  endtask : body

endclass

class userMasterSeq extends aceFullUvmUserSeq;

rand bit[<%=obj.wSysAddr-1%>:0] start_addr = 'h0;

	`uvm_object_utils(userMasterSeq)  

	function new(string name = "userMasterSeq");
		super.new(name);        
	endfunction : new

	virtual task body();
 
		for (int i=0; i<10; i++) begin
			`uvm_do_with(trans,{
				trans.Direction inside {DENALI_CDN_AXI_DIRECTION_READ, DENALI_CDN_AXI_DIRECTION_WRITE};
				(trans.ReadSnoop == DENALI_CDN_AXI_READSNOOP_ReadOnce) | (trans.WriteSnoop == DENALI_CDN_AXI_WRITESNOOP_WriteUnique);
				trans.Kind inside {DENALI_CDN_AXI_BURSTKIND_INCR, DENALI_CDN_AXI_BURSTKIND_WRAP};	
				trans.Domain == DENALI_CDN_AXI_DOMAIN_NON_SHAREABLE;			
				trans.Length <= 16;
				trans.StartAddress == start_addr + 'h400*i;
			});
			get_response(trans);
			#1000;
		end

	endtask : body

endclass : userMasterSeq

`endif //  `ifndef _USER_ACE_FULL_SEQ_LIB
