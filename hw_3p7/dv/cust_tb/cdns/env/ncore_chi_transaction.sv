
<%
   var chiaiu_idx = 0;
   var ioaiu_idx = 0;

   for(var pidx = 0; pidx < obj.nAIUs; pidx++) {
       if((obj.AiuInfo[pidx].fnNativeInterface == 'CHI-A')||(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-B')||(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-E')) {
       chiaiu_idx++;
       } else {
         ioaiu_idx += obj.AiuInfo[pidx].nNativeInterfacePorts;
       }
       } 
%>

// ----------------------------------------------------------------------------
// 
// @file cdnChiUvmUserSeqLib.sv
//
// ----------------------------------------------------------------------------

// @chapter myChiTransaction 
// @title CHI Transactions sub-classes

// **************************************************************************************
// @section myChiTransaction
// @title myChiTransaction
// @para This class extends the base denaliChiTransaction class
// @ulist
// **************************************************************************************
class myChiTransaction extends denaliChiTransaction;

	`uvm_object_utils(myChiTransaction)
	
	// @listitem cfg - Pointer to the agent configuration object in case running in UVM-CONFIG mode. 
	cdnChiUvmConfig cfg;

	// @listitem chosenSegmentIndex - Address segment index in case memory mapping was configured
	rand int chosenSegmentIndex;
	
	int maxSegmentIndex = 1;

	function new(string name = "myChiTransaction");
		super.new(name); 
	endfunction : new
	
	int unsigned RnIDs[$];
	int unsigned HnIDs[$];
	int unsigned SnIDs[$];
  
	function void unmapNodeIDs();
	   	foreach (cfg.NodeIdMapping[index]) begin
			if (cfg.NodeIdMapping[index].NodeType == CDN_CHI_CFG_NODETYPE_Rn) 
				RnIDs.push_front(cfg.NodeIdMapping[index].NodeID);
			if (cfg.NodeIdMapping[index].NodeType == CDN_CHI_CFG_NODETYPE_Hn) 
				HnIDs.push_front(cfg.NodeIdMapping[index].NodeID);
			if (cfg.NodeIdMapping[index].NodeType == CDN_CHI_CFG_NODETYPE_Sn) 
				SnIDs.push_front(cfg.NodeIdMapping[index].NodeID);
		end	
	endfunction

	function void pre_randomize();

		cdnChiUvmSequencer seqr;
		
		// @listitem Associate the transaction with an instance before randomization.
		super.pre_randomize();                             

		$cast(seqr,get_sequencer()); 
		
		// @listitem In UVM config flow, associate the transaction with the config object for additional pre-defined constraints.
		if (seqr != null && seqr.pAgent != null && seqr.pAgent.cfg != null)
		begin      
			$cast(cfg,seqr.pAgent.cfg);
			if (cfg.NodeIdMapping.size() == 0) 
				node_id_mapping.constraint_mode(0);
			else unmapNodeIDs();
			if (cfg.AddressMapping.size() == 0) 
				v8_address_mapping.constraint_mode(0);
			else maxSegmentIndex = cfg.AddressMapping.size();
		end
		else begin
			chosenSegmentIndex.rand_mode(0);
			chi_enhancements_fields_max_size.constraint_mode(0);
			node_id_mapping.constraint_mode(0);
			v8_address_mapping.constraint_mode(0);
		end  
	endfunction
	
	constraint chi_enhancements_fields_max_size {
		SrcID		< (1 << cfg.NodeIdWidth);
		TgtID		< (1 << cfg.NodeIdWidth);
		ReturnNID	< (1 << cfg.NodeIdWidth);
		StashNID	< (1 << cfg.NodeIdWidth);
		HomeNID		< (1 << cfg.NodeIdWidth);
		FwdNID		< (1 << cfg.NodeIdWidth);	
	}
	
	// @listitem In UVM config flow, constraint 'v8_address_mapping' will set MemAttr, Order and SnpAttr according to the V8 memory mapping in case memory mapping was configured.
	constraint v8_address_mapping {

		solve chosenSegmentIndex before Addr,ReqOpCode,MemAttr,Order,SnpAttr;

		chosenSegmentIndex < maxSegmentIndex;
		chosenSegmentIndex >= 0;

		foreach (cfg.AddressMapping[index]) {   
			if (index == chosenSegmentIndex && cfg.AddressMapping[index].MemAttr == CDN_CHI_CFG_V8MEMATTR_MEMORY_NC_NoEWA) { 
				Addr >= cfg.AddressMapping[index].StartAddress; 
				Addr <= cfg.AddressMapping[index].EndAddress;
				MemAttr == 'h0;
				Order inside {'h0,'h2};
				SnpAttr == 'h0;
			}
			if (index == chosenSegmentIndex && cfg.AddressMapping[index].MemAttr == CDN_CHI_CFG_V8MEMATTR_MEMORY_NC_EWA) { 
				Addr >= cfg.AddressMapping[index].StartAddress; 
				Addr <= cfg.AddressMapping[index].EndAddress;
				MemAttr == 'h1;
				Order inside {'h0,'h2};
				SnpAttr == 'h0;
			}
			if (index == chosenSegmentIndex && cfg.AddressMapping[index].MemAttr == CDN_CHI_CFG_V8MEMATTR_DEVICE_nGnRnE) { 
				Addr >= cfg.AddressMapping[index].StartAddress; 
				Addr <= cfg.AddressMapping[index].EndAddress;
				MemAttr == 'h2;
				Order == 'h3;
				SnpAttr == 'h0;
			}
			if (index == chosenSegmentIndex && cfg.AddressMapping[index].MemAttr == CDN_CHI_CFG_V8MEMATTR_DEVICE_GRE_nGRE) { 
				Addr >= cfg.AddressMapping[index].StartAddress; 
				Addr <= cfg.AddressMapping[index].EndAddress;
				MemAttr == 'h3;
				Order inside {'h0,'h2};
				SnpAttr == 'h0;
			}
			if (index == chosenSegmentIndex && cfg.AddressMapping[index].MemAttr == CDN_CHI_CFG_V8MEMATTR_DEVICE_nGnRE) { 
				Addr >= cfg.AddressMapping[index].StartAddress; 
				Addr <= cfg.AddressMapping[index].EndAddress;
				MemAttr == 'h3;
				Order == 'h3;
				SnpAttr == 'h0;                         
			}
			if (index == chosenSegmentIndex && cfg.AddressMapping[index].MemAttr == CDN_CHI_CFG_V8MEMATTR_MEMORY_WB_NoAlloc_NoSnp) { 
				Addr >= cfg.AddressMapping[index].StartAddress; 
				Addr <= cfg.AddressMapping[index].EndAddress;
				MemAttr == 'h5;
				Order inside {'h0,'h2};
				SnpAttr == 'h0;
			}
			if (index == chosenSegmentIndex && cfg.AddressMapping[index].MemAttr == CDN_CHI_CFG_V8MEMATTR_MEMORY_WB_NoAlloc_Inner) { 
				Addr >= cfg.AddressMapping[index].StartAddress; 
				Addr <= cfg.AddressMapping[index].EndAddress;
				MemAttr == 'h5;
				Order inside {'h0,'h2};
				SnpAttr inside {'h1,'h3};
			}
			if (index == chosenSegmentIndex && cfg.AddressMapping[index].MemAttr == CDN_CHI_CFG_V8MEMATTR_MEMORY_WB_NoAlloc_Outer) { 
				Addr >= cfg.AddressMapping[index].StartAddress; 
				Addr <= cfg.AddressMapping[index].EndAddress;
				MemAttr == 'h5;
				Order inside {'h0,'h2};
				SnpAttr inside {'h1,'h3};
			}
			if (index == chosenSegmentIndex && cfg.AddressMapping[index].MemAttr == CDN_CHI_CFG_V8MEMATTR_MEMORY_WB_Alloc_NoSnp) { 
				Addr >= cfg.AddressMapping[index].StartAddress; 
				Addr <= cfg.AddressMapping[index].EndAddress;
				MemAttr == 'hd;
				Order inside {'h0,'h2};
				SnpAttr == 'h0;
			}
			if (index == chosenSegmentIndex && cfg.AddressMapping[index].MemAttr == CDN_CHI_CFG_V8MEMATTR_MEMORY_WB_Alloc_Inner) { 
				Addr >= cfg.AddressMapping[index].StartAddress; 
				Addr <= cfg.AddressMapping[index].EndAddress;
				MemAttr == 'hd;
				Order inside {'h0,'h2};
				SnpAttr inside {'h1,'h3};
			}
			if (index == chosenSegmentIndex && cfg.AddressMapping[index].MemAttr == CDN_CHI_CFG_V8MEMATTR_MEMORY_WB_Alloc_Outer) { 
				Addr >= cfg.AddressMapping[index].StartAddress; 
				Addr <= cfg.AddressMapping[index].EndAddress;
				MemAttr == 'hd;
				Order inside {'h0,'h2};
				SnpAttr inside {'h1,'h3};
			}
			if (index == chosenSegmentIndex && cfg.RandomDownStreamTargetID == 1) {
				TgtID == cfg.AddressMapping[index].NodeID;
			}
		}
	} // v8_address_mapping
	
	constraint node_id_mapping {
		if (SpecVersion > 0) // Basic CHI Issue B
		{
			if (ReqOpCode == DENALI_CHI_REQOPCODE_ReadNoSnp || 
				ReqOpCode == DENALI_CHI_REQOPCODE_ReadNoSnpSep) {
				if (LinkType == DENALI_CHI_LINKTYPE_Hn2Sn && Excl == 0) {
	  				ReturnNID inside {RnIDs};
				}
	  		}
			if (ReqOpCode == DENALI_CHI_REQOPCODE_WriteUniqueFullStash ||
				ReqOpCode == DENALI_CHI_REQOPCODE_WriteUniquePtlStash ||
				ReqOpCode == DENALI_CHI_REQOPCODE_StashOnceShared ||
				ReqOpCode == DENALI_CHI_REQOPCODE_StashOnceUnique) {
				if (StashNIDValid) {
					StashNID != cfg.SourceID;
	  				StashNID inside {RnIDs};
				}
			}
			if (SnpOpCode == DENALI_CHI_SNPOPCODE_SnpSharedFwd ||
				SnpOpCode == DENALI_CHI_SNPOPCODE_SnpCleanFwd ||
				SnpOpCode == DENALI_CHI_SNPOPCODE_SnpOnceFwd ||
				SnpOpCode == DENALI_CHI_SNPOPCODE_SnpNotSharedDirtyFwd ||
				SnpOpCode == DENALI_CHI_SNPOPCODE_SnpUniqueFwd) {
				FwdNID != cfg.TargetID;
	  			FwdNID inside {RnIDs};
			}
			if (ReqOpCode == DENALI_CHI_REQOPCODE_PrefetchTgt) {
	  			SrcID inside {RnIDs};
	  			TgtID inside {SnIDs};
	  		}
		}
	} // node_id_mapping

endclass : myChiTransaction

// @ulist/
// @section/

// **************************************************************************************
// @section myChiSnoopTransaction
// @title myChiSnoopTransaction
// @para This class extends myChiTransaction class and is used for initiate snoop transactions 
// **************************************************************************************
class myChiSnoopTransaction extends myChiTransaction;

	`uvm_object_utils(myChiSnoopTransaction)

	function new(string name = "myChiSnoopTransaction");
		super.new(name);
		v8_address_mapping.constraint_mode(0);
	endfunction : new 

	function void pre_randomize();
		super.pre_randomize();
		if (cfg == null || cfg.AddressMapping.size() == 0) begin
			v8_snoop_address_mapping.constraint_mode(0);
		end
	endfunction

	constraint v8_snoop_address_mapping {

		solve chosenSegmentIndex before SnpAddr;

		chosenSegmentIndex < maxSegmentIndex;
		chosenSegmentIndex >= 0;

		foreach (cfg.AddressMapping[index]) {
			if (cfg.AddressMapping[index].MemAttr inside {
						CDN_CHI_CFG_V8MEMATTR_MEMORY_NC_NoEWA,
						CDN_CHI_CFG_V8MEMATTR_MEMORY_NC_EWA,
						CDN_CHI_CFG_V8MEMATTR_MEMORY_WB_Alloc_NoSnp,
						CDN_CHI_CFG_V8MEMATTR_DEVICE_nGnRnE,
						CDN_CHI_CFG_V8MEMATTR_DEVICE_GRE_nGRE,
						CDN_CHI_CFG_V8MEMATTR_DEVICE_nGnRE,
						CDN_CHI_CFG_V8MEMATTR_MEMORY_WB_NoAlloc_NoSnp }
			) { 
				chosenSegmentIndex != index;
			}
			if (index == chosenSegmentIndex && cfg.AddressMapping[index].MemAttr inside {
						CDN_CHI_CFG_V8MEMATTR_MEMORY_WB_NoAlloc_Inner,
						CDN_CHI_CFG_V8MEMATTR_MEMORY_WB_NoAlloc_Outer,
						CDN_CHI_CFG_V8MEMATTR_MEMORY_WB_Alloc_Inner,
						CDN_CHI_CFG_V8MEMATTR_MEMORY_WB_Alloc_Outer }
			) {
				SnpAddr >= cfg.AddressMapping[index].StartAddress[43:3]; 
				SnpAddr <= cfg.AddressMapping[index].EndAddress[43:3];  
			}
		}
	} // v8_snoop_address_mapping
	
endclass : myChiSnoopTransaction
// @section/

// **************************************************************************************
// @section myChiResponse
// @title myChiResponse
// @para This class extends the base denaliChiTransaction class and is used for pre-loaded UPSTREAM responses
// @ulist
// **************************************************************************************
class myChiResponse extends denaliChiTransaction;

	`uvm_object_utils(myChiResponse)

	function new(string name = "myChiResponse");
		super.new(name);
		// @listitem PortNum (Queue id) is set to DENALI_CHI_QUEUE_USER_RESPOND
		this.PortNum = DENALI_CHI_QUEUE_USER_RESPOND;
	endfunction : new 

endclass : myChiResponse
// @ulist/
// @section/

// **************************************************************************************
// @section myChiSnoopResponse
// @title myChiSnoopResponse
// @para This class extends the base denaliChiTransaction class and is used for pre-loaded DOWNSTREAM snoop responses
// @ulist
// **************************************************************************************
class myChiSnoopResponse extends denaliChiTransaction;

	`uvm_object_utils(myChiSnoopResponse)

	function new(string name = "myChiSnoopResponse");
		super.new(name);
		// @listitem PortNum (Queue id) is set to DENALI_CHI_QUEUE_USER_RESPOND
		this.PortNum = DENALI_CHI_QUEUE_USER_RESPOND;
	endfunction : new 

endclass : myChiSnoopResponse
// @ulist/
// @section/

// ****************************************************************************
// @section cacheAwareReq
// @title cacheAwareReq
// @para This class extends myChiTransaction class and take into consideration the current state of the cache line.
// @ulist
// ****************************************************************************
class cacheAwareReq extends myChiTransaction;

	// @listitem CacheLineState, Addr and NonSecure values are expected to be set by the calling sequence
	rand denaliChiCacheLineStateT CacheLineState;

	`uvm_object_utils(cacheAwareReq)

	function new(string name = "cacheAwareReq");
		super.new(name);
	endfunction : new 

	// @listitem The cache_aware constraint selects a legal value for ReqOpCode according to the given cache line state.
	constraint cache_aware {

		CacheLineState == DENALI_CHI_CACHELINESTATE_Invalid -> 
		(ReqOpCode inside {
				DENALI_CHI_REQOPCODE_ReadOnce,
				DENALI_CHI_REQOPCODE_ReadClean,
				DENALI_CHI_REQOPCODE_ReadShared,
				DENALI_CHI_REQOPCODE_ReadUnique,
				DENALI_CHI_REQOPCODE_MakeUnique,
				DENALI_CHI_REQOPCODE_CleanShared,
				DENALI_CHI_REQOPCODE_CleanInvalid,
				DENALI_CHI_REQOPCODE_MakeInvalid,
				DENALI_CHI_REQOPCODE_WriteUniquePtl,
				DENALI_CHI_REQOPCODE_WriteUniqueFull
			});

		CacheLineState == DENALI_CHI_CACHELINESTATE_UniqueCleanEmpty -> 
		(ReqOpCode inside {
				DENALI_CHI_REQOPCODE_ReadOnce,
				DENALI_CHI_REQOPCODE_ReadClean,
				DENALI_CHI_REQOPCODE_ReadShared,
				DENALI_CHI_REQOPCODE_ReadUnique,
				DENALI_CHI_REQOPCODE_MakeUnique,
				DENALI_CHI_REQOPCODE_CleanShared,
				DENALI_CHI_REQOPCODE_CleanInvalid,
				DENALI_CHI_REQOPCODE_MakeInvalid,
				DENALI_CHI_REQOPCODE_CleanUnique,
				DENALI_CHI_REQOPCODE_WriteUniquePtl,
				DENALI_CHI_REQOPCODE_WriteUniqueFull,
				DENALI_CHI_REQOPCODE_WriteBackFull,
				DENALI_CHI_REQOPCODE_WriteBackPtl,
				DENALI_CHI_REQOPCODE_WriteCleanFull,
				DENALI_CHI_REQOPCODE_WriteCleanPtl
			});

		CacheLineState == DENALI_CHI_CACHELINESTATE_UniqueDirtyPartial -> 
		(ReqOpCode inside {
				DENALI_CHI_REQOPCODE_ReadUnique,
				DENALI_CHI_REQOPCODE_CleanUnique,
				DENALI_CHI_REQOPCODE_MakeUnique,
				DENALI_CHI_REQOPCODE_WriteBackPtl,
				DENALI_CHI_REQOPCODE_WriteCleanPtl
			});

		CacheLineState == DENALI_CHI_CACHELINESTATE_UniqueClean -> 
		(ReqOpCode inside {
				DENALI_CHI_REQOPCODE_ReadUnique,
				DENALI_CHI_REQOPCODE_CleanUnique,
				DENALI_CHI_REQOPCODE_MakeUnique,
				DENALI_CHI_REQOPCODE_CleanShared, 
				DENALI_CHI_REQOPCODE_WriteEvictFull,
				DENALI_CHI_REQOPCODE_Evict
			});

		CacheLineState == DENALI_CHI_CACHELINESTATE_UniqueDirty -> 
		(ReqOpCode inside {
				DENALI_CHI_REQOPCODE_ReadUnique,
				DENALI_CHI_REQOPCODE_CleanUnique,
				DENALI_CHI_REQOPCODE_MakeUnique,
				DENALI_CHI_REQOPCODE_WriteBackFull,
				DENALI_CHI_REQOPCODE_WriteCleanFull
			});

		CacheLineState == DENALI_CHI_CACHELINESTATE_SharedClean -> 
		(ReqOpCode inside {
				DENALI_CHI_REQOPCODE_ReadUnique,
				DENALI_CHI_REQOPCODE_CleanUnique,
				DENALI_CHI_REQOPCODE_MakeUnique,
				DENALI_CHI_REQOPCODE_CleanShared,
				DENALI_CHI_REQOPCODE_Evict
			});

		CacheLineState == DENALI_CHI_CACHELINESTATE_SharedDirty -> 
		(ReqOpCode inside {
				DENALI_CHI_REQOPCODE_ReadUnique,
				DENALI_CHI_REQOPCODE_CleanUnique,
				DENALI_CHI_REQOPCODE_MakeUnique,
				DENALI_CHI_REQOPCODE_WriteBackFull,
				DENALI_CHI_REQOPCODE_WriteCleanFull
			});

		solve Addr before CacheLineState;
		solve NonSecure before CacheLineState;
		solve CacheLineState before ReqOpCode;
	}

endclass : cacheAwareReq
// @ulist/
// @section/

// @chapter/

// **************************************************************************************
// @chapter ChiAtomicReqTransaction 
// @title Atomic Request Transaction Sequences
// **************************************************************************************

// ****************************************************************************
// @section oneCacheAwareSeq
// @title oneCacheAwareSeq
// @para This sequence sends one RnF request that take into consideration the current state of the cache line.
// @ulist
// ****************************************************************************
class oneCacheAwareSeq extends cdnChiUvmSequence;

	// @listitem This sequence sends an item 'chiReq' of type 'cacheAwareReq'
	cacheAwareReq chiReq;
	denaliChiCacheLineStateT state;
	
	// @listitem The sequence randomizes an 'address' and 'non_secure' values.
	// @listitem The user can add constraints on these values.
	rand reg [51:0] address;
	rand reg non_secure;
	// @listitem The user can also constrain the transactions 'id' field.
	rand reg[7:0] id;

	uvm_sequence_item item;

	reg [43:0] aligned_addresss;

	`uvm_object_utils(oneCacheAwareSeq)
	`uvm_declare_p_sequencer(cdnChiUvmSequencer)

	function new(string name = "oneCacheAwareSeq");
		super.new(name);
	endfunction : new 

	task body();

		aligned_addresss = address;
		aligned_addresss[5:0] = 0;

		chiReq = cacheAwareReq::type_id::create("chiReq");
		
		// @listitem According to the (aligned) address, The sequence reads the current cache line state.
		state = p_sequencer.pAgent.inst.getCacheLineState(aligned_addresss,non_secure);   
		
		// @listitem The sequence generates a request item of type cacheAwareReq using the cache line state.
		`uvm_info(get_type_name(), "oneCacheAware sequence issuing a cache aware CHI Request", UVM_HIGH);
		`uvm_do_with(chiReq,  {
				chiReq.Addr == address;
				chiReq.NonSecure == non_secure; 
				chiReq.CacheLineState == state;
				chiReq.TxnID == id;
			}) 

//		// @listitem Blocking sequence. wait until transaction ends.
//		get_response(item, chiReq.get_transaction_id()); 

		#1000;

	endtask

endclass : oneCacheAwareSeq
// @ulist/
// @section/

// **************************************************************************************
// @section chiCoherentReadSeq
// @title chiCoherentReadSeq
// @para This sequence sends one random coherent READ request.
// @ulist
// **************************************************************************************
class chiCoherentReadSeq extends cdnChiUvmSequence;
	
	// @listitem This sequence sends an item 'trans' of type 'myChiTransaction'
	myChiTransaction trans;
	
	// @listitem The user can control the values of TxnID, Addr and NonSecure fields.
	rand reg [7:0] TxnID ;
	rand reg [43:0] Addr ;
	rand reg NonSecure ;
	
	rand denaliChiReqOpCodeT OpCode;
	
	`uvm_object_utils_begin(chiCoherentReadSeq)
		`uvm_field_object(trans, UVM_ALL_ON)
	`uvm_object_utils_end

	`uvm_declare_p_sequencer(cdnChiUvmSequencer)

	function new(string name="chiCoherentReadSeq");
		super.new(name);
	endfunction // new
	
	// @listitem The constraint 'random_read_opcode' keep the OpCode between ReadShared, ReadClean, ReadUnique.
	constraint random_read_opcode {
		OpCode inside {
				DENALI_CHI_REQOPCODE_ReadShared,
				DENALI_CHI_REQOPCODE_ReadClean,
				DENALI_CHI_REQOPCODE_ReadUnique
		};
	}

	virtual task body();
	
		`uvm_do_with(trans, {
				trans.ReqOpCode == OpCode;
				trans.TxnID == local::TxnID;
				trans.Addr == local::Addr;
				trans.NonSecure == local::NonSecure;
			}) 
	
	endtask // body
	
endclass : chiCoherentReadSeq
// @ulist/
// @section/

// **************************************************************************************
// @section chiCMOSeq
// @title chiCMOSeq
// @para This sequence sends one random Cache maintenence operation request.
// @ulist
// **************************************************************************************
class chiCMOSeq extends cdnChiUvmSequence;
	
	// @listitem This sequence sends an item 'trans' of type 'myChiTransaction'
	myChiTransaction trans;
	
	// @listitem The user can control the values of TxnID, Addr and NonSecure fields.
	rand reg [7:0] TxnID ;
	rand reg [43:0] Addr ;
	rand reg NonSecure ;
	
	rand denaliChiReqOpCodeT OpCode;
	
	`uvm_object_utils_begin(chiCMOSeq)
		`uvm_field_object(trans, UVM_ALL_ON)
	`uvm_object_utils_end

	`uvm_declare_p_sequencer(cdnChiUvmSequencer)

	function new(string name="chiCMOSeq");
		super.new(name);
	endfunction // new
	
	// @listitem The constraint 'random_CMO_opcode' keep the OpCode between Clean*, Make* and Evict
	constraint random_CMO_opcode {
		OpCode inside {
				 DENALI_CHI_REQOPCODE_CleanShared,
				 DENALI_CHI_REQOPCODE_CleanInvalid,
				 DENALI_CHI_REQOPCODE_MakeInvalid,
				 DENALI_CHI_REQOPCODE_CleanUnique,
				 DENALI_CHI_REQOPCODE_MakeUnique,
				 DENALI_CHI_REQOPCODE_Evict
		};
	}

	virtual task body();
	
		`uvm_do_with(trans, {
				trans.ReqOpCode == OpCode;
				trans.TxnID == local::TxnID;
				trans.Addr == local::Addr;
				trans.NonSecure == local::NonSecure;
			}) 
	
	endtask // body
	
endclass : chiCMOSeq
// @ulist/
// @section/

// **************************************************************************************
// @section chiCopyBackSeq
// @title chiCopyBackSeq
// @para This sequence sends one random Copy-Back WRITE request.
// @ulist
// **************************************************************************************
class chiCopyBackSeq extends cdnChiUvmSequence;
	
	// @listitem This sequence sends an item 'trans' of type 'myChiTransaction'
	myChiTransaction trans;
	
	// @listitem The user can control the values of TxnID, Addr and NonSecure fields.
	rand reg [7:0] TxnID ;
	rand reg [43:0] Addr ;
	rand reg NonSecure ;
	
	rand denaliChiReqOpCodeT OpCode;
	
	`uvm_object_utils_begin(chiCopyBackSeq)
		`uvm_field_object(trans, UVM_ALL_ON)
	`uvm_object_utils_end

	`uvm_declare_p_sequencer(cdnChiUvmSequencer)

	function new(string name="chiCopyBackSeq");
		super.new(name);
	endfunction // new
	
	// @listitem The constraint 'random_copy_back_opcode' keep the OpCode between WriteClean*, WriteBack* and WriteEvictFull
	constraint random_copy_back_opcode {
		OpCode inside {
			DENALI_CHI_REQOPCODE_WriteEvictFull,
			DENALI_CHI_REQOPCODE_WriteCleanPtl,
			DENALI_CHI_REQOPCODE_WriteCleanFull,
			DENALI_CHI_REQOPCODE_WriteBackPtl,
			DENALI_CHI_REQOPCODE_WriteBackFull
		};
	}

	virtual task body();
	
		`uvm_do_with(trans, {
				trans.ReqOpCode == OpCode;
				trans.TxnID == local::TxnID;
				trans.Addr == local::Addr;
				trans.NonSecure == local::NonSecure;
			}) 
	
	endtask // body
	
endclass : chiCopyBackSeq
// @ulist/
// @section/

// **************************************************************************************
// @section readSharedSeq
// @title readSharedSeq
// @para This sequence extends chiCoherentReadSeq and sends one ReadShared request.
// **************************************************************************************
class readSharedSeq extends chiCoherentReadSeq;

	`uvm_object_utils(readSharedSeq)

	function new(string name="readSharedSeq");
		super.new(name);
	endfunction // new

	constraint read_shared_opcode {
		OpCode == DENALI_CHI_REQOPCODE_ReadShared;
	}

endclass : readSharedSeq
// @section/

// **************************************************************************************
// @section readCleanSeq
// @title readCleanSeq
// @para This sequence extends chiCoherentReadSeq and sends one ReadClean request.
// **************************************************************************************
class readCleanSeq extends chiCoherentReadSeq;

	`uvm_object_utils(readCleanSeq)

	function new(string name="readCleanSeq");
		super.new(name);
	endfunction // new

	constraint read_clean_opcode {
		OpCode == DENALI_CHI_REQOPCODE_ReadClean;
	}

endclass : readCleanSeq
// @section/

// **************************************************************************************
// @section readOnceSeq
// @title readOnceSeq
// @para This sequence sends one ReadOnce request.
// @ulist
// **************************************************************************************
class readOnceSeq extends cdnChiUvmSequence;

	// @listitem This sequence sends an item 'trans' of type 'myChiTransaction'
	myChiTransaction trans;
	
	// @listitem The user can control the values of TxnID, Addr and NonSecure fields.
	rand reg [7:0] TxnID ;
	rand reg [43:0] Addr ;
	rand reg NonSecure ;

	`uvm_object_utils_begin(readOnceSeq)
		`uvm_field_object(trans, UVM_ALL_ON)
	`uvm_object_utils_end

	`uvm_declare_p_sequencer(cdnChiUvmSequencer)

	function new(string name="readOnceSeq");
		super.new(name);
	endfunction // new

	virtual task body();

		`uvm_do_with(trans,  {
				trans.ReqOpCode == DENALI_CHI_REQOPCODE_ReadOnce;
				trans.TxnID == local::TxnID;
				trans.Addr == local::Addr;
				trans.NonSecure == local::NonSecure;
			}) 

	endtask // body

endclass : readOnceSeq
// @ulist/
// @section/

// **************************************************************************************
// @section readNoSnpSeq
// @title readNoSnpSeq
// @para This sequence sends one ReadNoSnp request.
// @ulist
// **************************************************************************************
class readNoSnpSeq extends cdnChiUvmSequence;
	
	// @listitem This sequence sends an item 'trans' of type 'myChiTransaction'
	myChiTransaction trans;
	
	// @listitem The user can control the values of TxnID, Addr, NonSecure and Size fields.
	rand reg [7:0] TxnID ;
	rand reg [43:0] Addr ;
	rand reg NonSecure ;
	rand denaliChiSizeT Size ; // size of data, associated with the transaction
	
	constraint read_no_snoop_size { 
		Size != DENALI_CHI_SIZE_UNSET;
		Size != DENALI_CHI_SIZE_RESERVED7;
	}

	`uvm_object_utils_begin(readNoSnpSeq)
		`uvm_field_object(trans, UVM_ALL_ON)
	`uvm_object_utils_end

	`uvm_declare_p_sequencer(cdnChiUvmSequencer)

	function new(string name="readNoSnpSeq");
		super.new(name);
	endfunction // new

	virtual task body();

		`uvm_do_with(trans,  {
				trans.ReqOpCode == DENALI_CHI_REQOPCODE_ReadNoSnp;
				trans.TxnID == local::TxnID;
				trans.Addr == local::Addr;
				trans.NonSecure == local::NonSecure;
				trans.Size == local::Size;
			}) 

	endtask // body

endclass : readNoSnpSeq
// @ulist/
// @section/

// **************************************************************************************
// @section readUniqueSeq
// @title readUniqueSeq
// @para This sequence extends chiCoherentReadSeq and sends one ReadUnique request.
// **************************************************************************************
class readUniqueSeq extends chiCoherentReadSeq;

	`uvm_object_utils(readUniqueSeq)

	function new(string name="readUniqueSeq");
		super.new(name);
	endfunction // new

	constraint read_unique_opcode {
		OpCode == DENALI_CHI_REQOPCODE_ReadUnique;
	}

endclass : readUniqueSeq
// @section/

// **************************************************************************************
// @section cleanSharedSeq
// @title cleanSharedSeq
// @para This sequence extends chiCMOSeq and sends one CleanShared request.
// **************************************************************************************
class cleanSharedSeq extends chiCMOSeq;

	`uvm_object_utils(cleanSharedSeq)

	function new(string name="cleanSharedSeq");
		super.new(name);
	endfunction // new
	
	constraint clean_shared_opcode {
		OpCode == DENALI_CHI_REQOPCODE_CleanShared;
	}

endclass : cleanSharedSeq
// @section/

// **************************************************************************************
// @section cleanInvalidSeq
// @title cleanInvalidSeq
// @para This sequence extends chiCMOSeq and sends one CleanInvalid request.
// **************************************************************************************
class cleanInvalidSeq extends chiCMOSeq;

	`uvm_object_utils(cleanInvalidSeq)

	function new(string name="cleanInvalidSeq");
		super.new(name);
	endfunction // new
	
	constraint clean_invalid_opcode {
		OpCode == DENALI_CHI_REQOPCODE_CleanInvalid;
	}

endclass : cleanInvalidSeq
// @section/

// **************************************************************************************
// @section makeInvalidSeq
// @title makeInvalidSeq
// @para This sequence extends chiCMOSeq and sends one MakeInvalid request.
// **************************************************************************************
class makeInvalidSeq extends chiCMOSeq;

	`uvm_object_utils(makeInvalidSeq)

	function new(string name="makeInvalidSeq");
		super.new(name);
	endfunction // new
	
	constraint make_invalid_opcode {
		OpCode == DENALI_CHI_REQOPCODE_MakeInvalid;
	}

endclass : makeInvalidSeq
// @section/

// **************************************************************************************
// @section cleanUniqueSeq
// @title cleanUniqueSeq
// @para This sequence extends chiCMOSeq and sends one CleanUnique request.
// **************************************************************************************
class cleanUniqueSeq extends chiCMOSeq;

	`uvm_object_utils(cleanUniqueSeq)

	function new(string name="cleanUniqueSeq");
		super.new(name);
	endfunction // new
	
	constraint clean_unique_opcode {
		OpCode == DENALI_CHI_REQOPCODE_CleanUnique;
	}

endclass : cleanUniqueSeq
// @section/

// **************************************************************************************
// @section makeUniqueSeq
// @title makeUniqueSeq
// @para This sequence extends chiCMOSeq and sends one MakeUnique request.
// **************************************************************************************
class makeUniqueSeq extends chiCMOSeq;

	`uvm_object_utils(makeUniqueSeq)

	function new(string name="makeUniqueSeq");
		super.new(name);
	endfunction // new
	
	constraint make_unique_opcode {
		OpCode == DENALI_CHI_REQOPCODE_MakeUnique;
	}

endclass : makeUniqueSeq
// @section/

// **************************************************************************************
// @section evictSeq
// @title evictSeq
// @para This sequence extends chiCMOSeq and sends one Evict request.
// **************************************************************************************
class evictSeq extends chiCMOSeq;

	`uvm_object_utils(evictSeq)

	function new(string name="evictSeq");
		super.new(name);
	endfunction // new
	
	constraint evict_opcode {
		OpCode == DENALI_CHI_REQOPCODE_Evict;
	}

endclass : evictSeq
// @section/

// **************************************************************************************
// @section chiBarrierSeq
// @title chiBarrierSeq
// @para This sequence sends one Barrier request.
// @ulist
// **************************************************************************************
class chiBarrierSeq extends cdnChiUvmSequence;
	
	// @listitem This sequence sends an item 'trans' of type 'myChiTransaction'
	myChiTransaction trans;
	
	// @listitem The user can control the value of TxnID field.
	rand reg [7:0] TxnID ;

	`uvm_object_utils_begin(chiBarrierSeq)
		`uvm_field_object(trans, UVM_ALL_ON)
	`uvm_object_utils_end

	`uvm_declare_p_sequencer(cdnChiUvmSequencer)

	function new(string name="chiBarrierSeq");
		super.new(name);
	endfunction // new

	virtual task body();

		`uvm_create(trans);
		
    // @listitem Turns off the address mapping constraint for Barrier sequence.
    trans.v8_address_mapping.constraint_mode(0);
		
		`uvm_rand_send_with(trans, {
				trans.ReqOpCode inside { DENALI_CHI_REQOPCODE_ECBarrier};
				trans.TxnID == local::TxnID;
			}) 

	endtask // body

endclass : chiBarrierSeq
// @ulist/
// @section/

// **************************************************************************************
// @section chiDVMOpSeq
// @title chiDVMOpSeq
// @para This sequence sends one DVMOp request.
// @ulist
// **************************************************************************************
class chiDVMOpSeq extends cdnChiUvmSequence;
	
	// @listitem This sequence sends an item 'trans' of type 'myChiTransaction'
	myChiTransaction trans;
	
	// @listitem The user can control the value of TxnID field.
	rand reg [7:0] TxnID ;

	`uvm_object_utils_begin(chiDVMOpSeq)
		`uvm_field_object(trans, UVM_ALL_ON)
	`uvm_object_utils_end

	`uvm_declare_p_sequencer(cdnChiUvmSequencer)

	function new(string name="chiDVMOpSeq");
		super.new(name);
	endfunction // new

	virtual task body();
		
		`uvm_create(trans);
		
    // @listitem Turns off the address mapping constraint for DVM sequence.
    trans.v8_address_mapping.constraint_mode(0);
		
	`uvm_rand_send_with(trans, {
		trans.ReqOpCode == DENALI_CHI_REQOPCODE_DVMOp;
		trans.TxnID == local::TxnID;
	}) 

	endtask // body

endclass : chiDVMOpSeq
// @ulist/
// @section/

// **************************************************************************************
// @section writeEvictFullSeq
// @title writeEvictFullSeq
// @para This sequence extends chiCopyBackSeq and sends one WriteEvictFull request.
// **************************************************************************************
class writeEvictFullSeq extends chiCopyBackSeq;

	`uvm_object_utils(writeEvictFullSeq)

	function new(string name="writeEvictFullSeq");
		super.new(name);
	endfunction // new
	
	constraint write_evict_full_opcode {
		OpCode == DENALI_CHI_REQOPCODE_WriteEvictFull;
	}

endclass : writeEvictFullSeq
// @section/

// **************************************************************************************
// @section writeCleanPtlSeq
// @title writeCleanPtlSeq
// @para This sequence extends chiCopyBackSeq and sends one WriteCleanPtl request.
// **************************************************************************************
class writeCleanPtlSeq extends chiCopyBackSeq;

	`uvm_object_utils(writeCleanPtlSeq)

	function new(string name="writeCleanPtlSeq");
		super.new(name);
	endfunction // new
	
	constraint write_clean_ptl_opcode {
		OpCode == DENALI_CHI_REQOPCODE_WriteCleanPtl;
	}

endclass : writeCleanPtlSeq
// @section/

// **************************************************************************************
// @section writeCleanFullSeq
// @title writeCleanFullSeq
// @para This sequence extends chiCopyBackSeq and sends one WriteCleanFull request.
// **************************************************************************************
class writeCleanFullSeq extends chiCopyBackSeq;

	`uvm_object_utils(writeCleanFullSeq)

	function new(string name="writeCleanFullSeq");
		super.new(name);
	endfunction // new
	
	constraint write_clean_full_opcode {
		OpCode == DENALI_CHI_REQOPCODE_WriteCleanFull;
	}

endclass : writeCleanFullSeq
// @section/

// **************************************************************************************
// @section writeUniquePtlSeq
// @title writeUniquePtlSeq
// @para This sequence sends one WriteUniquePtl request.
// @ulist
// **************************************************************************************
class writeUniquePtlSeq extends cdnChiUvmSequence;
	
	// @listitem This sequence sends an item 'trans' of type 'myChiTransaction'
	myChiTransaction trans;
	
	// @listitem The user can control the values of TxnID, Addr, NonSecure and Size fields.
	rand reg [7:0] TxnID ;
	rand reg [43:0] Addr ;
	rand reg NonSecure ;
	rand denaliChiSizeT Size ; // size of data, associated with the transaction

	constraint write_unique_ptl_size { 
		Size != DENALI_CHI_SIZE_UNSET;
		Size != DENALI_CHI_SIZE_RESERVED7;
	}	
	
	`uvm_object_utils_begin(writeUniquePtlSeq)
		`uvm_field_object(trans, UVM_ALL_ON)
	`uvm_object_utils_end

	`uvm_declare_p_sequencer(cdnChiUvmSequencer)

	function new(string name="writeUniquePtlSeq");
		super.new(name);
	endfunction // new

	virtual task body();

		`uvm_do_with(trans,  {
				trans.ReqOpCode == DENALI_CHI_REQOPCODE_WriteUniquePtl;
				trans.TxnID == local::TxnID;
				trans.Addr == local::Addr;
				trans.NonSecure == local::NonSecure;
				trans.Size == local::Size;
			}) 

	endtask // body

endclass : writeUniquePtlSeq
// @ulist/
// @section/

// **************************************************************************************
// @section writeUniqueFullSeq
// @title writeUniqueFullSeq
// @para This sequence sends one WriteUniqueFull request.
// @ulist
// **************************************************************************************
class writeUniqueFullSeq extends cdnChiUvmSequence;
	
	// @listitem This sequence sends an item 'trans' of type 'myChiTransaction'
	myChiTransaction trans;

	// @listitem The user can control the values of TxnID, Addr and NonSecure fields.
	rand reg [7:0] TxnID ;
	rand reg [43:0] Addr ;
	rand reg NonSecure ;

	`uvm_object_utils_begin(writeUniqueFullSeq)
		`uvm_field_object(trans, UVM_ALL_ON)
	`uvm_object_utils_end

	`uvm_declare_p_sequencer(cdnChiUvmSequencer)

	function new(string name="writeUniqueFullSeq");
		super.new(name);
	endfunction // new

	virtual task body();

		`uvm_do_with(trans,  {
				trans.ReqOpCode == DENALI_CHI_REQOPCODE_WriteUniqueFull;
				trans.TxnID == local::TxnID;
				trans.Addr == local::Addr;
				trans.NonSecure == local::NonSecure;
			}) 

	endtask // body

endclass : writeUniqueFullSeq
// @ulist/
// @section/

// **************************************************************************************
// @section writeBackPtlSeq
// @title writeBackPtlSeq
// @para This sequence extends chiCopyBackSeq and sends one WriteBackPtl request.
// **************************************************************************************
class writeBackPtlSeq extends chiCopyBackSeq;

	`uvm_object_utils(writeBackPtlSeq)

	function new(string name="writeBackPtlSeq");
		super.new(name);
	endfunction // new
	
	constraint write_clean_full_opcode {
		OpCode == DENALI_CHI_REQOPCODE_WriteBackPtl;
	}
	
endclass : writeBackPtlSeq
// @section/

// **************************************************************************************
// @section writeBackFullSeq
// @title writeBackFullSeq
// @para This sequence extends chiCopyBackSeq and sends one WriteBackFull request.
// **************************************************************************************
class writeBackFullSeq extends chiCopyBackSeq;

	`uvm_object_utils(writeBackFullSeq)

	function new(string name="writeBackFullSeq");
		super.new(name);
	endfunction // new
	
	constraint write_clean_full_opcode {
		OpCode == DENALI_CHI_REQOPCODE_WriteBackFull;
	}

endclass : writeBackFullSeq
// @section/

// **************************************************************************************
// @section writeNoSnpPtlSeq
// @title writeNoSnpPtlSeq
// @para This sequence sends one WriteNoSnpPtl request.
// @ulist
// **************************************************************************************
class writeNoSnpPtlSeq extends cdnChiUvmSequence;
	
	// @listitem This sequence sends an item 'trans' of type 'myChiTransaction'
	myChiTransaction trans;
	
	// @listitem The user can control the values of TxnID, Addr, NonSecure and Size fields.
	rand reg [7:0] TxnID ;
	rand reg [43:0] Addr ;
	rand reg NonSecure ;
	rand denaliChiSizeT Size ; // size of data, associated with the transaction
	
	constraint write_no_snoop_ptl_size { 
		Size != DENALI_CHI_SIZE_UNSET;
		Size != DENALI_CHI_SIZE_RESERVED7;
	}		

	`uvm_object_utils_begin(writeNoSnpPtlSeq)
		`uvm_field_object(trans, UVM_ALL_ON)
	`uvm_object_utils_end

	`uvm_declare_p_sequencer(cdnChiUvmSequencer)

	function new(string name="writeNoSnpPtlSeq");
		super.new(name);
	endfunction // new

	virtual task body();

		`uvm_do_with(trans,  {
				trans.ReqOpCode == DENALI_CHI_REQOPCODE_WriteNoSnpPtl;
				trans.TxnID == local::TxnID;
				trans.Addr == local::Addr;
				trans.NonSecure == local::NonSecure;
				trans.Size == local::Size;
			}) 
			
	endtask // body

endclass : writeNoSnpPtlSeq
// @ulist/
// @section/

// **************************************************************************************
// @section writeNoSnpFullSeq
// @title writeNoSnpFullSeq
// @para This sequence sends one WriteNoSnpFull request.
// @ulist
// **************************************************************************************
class writeNoSnpFullSeq extends cdnChiUvmSequence;
	
	// @listitem This sequence sends an item 'trans' of type 'myChiTransaction'
	myChiTransaction trans;

	// @listitem The user can control the values of TxnID, Addr and NonSecure fields.
	rand reg [7:0] TxnID ;
	rand reg [43:0] Addr ;
	rand reg NonSecure ;

	`uvm_object_utils_begin(writeNoSnpFullSeq)
		`uvm_field_object(trans, UVM_ALL_ON)
	`uvm_object_utils_end

	`uvm_declare_p_sequencer(cdnChiUvmSequencer)

	function new(string name="writeNoSnpFullSeq");
		super.new(name);
	endfunction // new

	virtual task body();

		`uvm_do_with(trans,  {
				trans.ReqOpCode == DENALI_CHI_REQOPCODE_WriteNoSnpFull;
				trans.TxnID == local::TxnID;
				trans.Addr == local::Addr;
				trans.NonSecure == local::NonSecure;
			}) 
			
	endtask // body

endclass : writeNoSnpFullSeq
// @ulist/
// @section/

// @chapter/

// **************************************************************************************
// @chapter ChiAtomicSnoopTransaction 
// @title Atomic Snoop Transaction Sequences
// **************************************************************************************

// **************************************************************************************
// @section chiSnoopSeq
// @title chiSnoopSeq
// @para This sequence sends one random Snoop (non-DVM).
// @ulist
// **************************************************************************************
class chiSnoopSeq extends cdnChiUvmSequence;
	
	// @listitem This sequence sends an item 'trans' of type 'myChiSnoopTransaction'
	myChiSnoopTransaction trans;
	
	// @listitem The user can control the values of TxnID, Addr and NonSecure fields.
	rand reg [7:0] TxnID ;
	rand reg [43:0] Addr ;
	rand reg NonSecure ;
	
	rand denaliChiSnpOpCodeT OpCode;
	
	`uvm_object_utils_begin(chiSnoopSeq)
		`uvm_field_object(trans, UVM_ALL_ON)
	`uvm_object_utils_end

	`uvm_declare_p_sequencer(cdnChiUvmSequencer)

	function new(string name="chiSnoopSeq");
		super.new(name);
	endfunction // new
	
	// @listitem The constraint 'random_snoop_opcode' keep the OpCode inside legal range and non-DVM.
	constraint random_snoop_opcode {
		OpCode inside {
			DENALI_CHI_SNPOPCODE_SnpShared,
			DENALI_CHI_SNPOPCODE_SnpClean,
			DENALI_CHI_SNPOPCODE_SnpOnce,
			DENALI_CHI_SNPOPCODE_SnpUnique,
			DENALI_CHI_SNPOPCODE_SnpCleanShared,
			DENALI_CHI_SNPOPCODE_SnpCleanInvalid,
			DENALI_CHI_SNPOPCODE_SnpMakeInvalid
		};
	}

	virtual task body();
	
		`uvm_do_with(trans, {
			trans.SnpOpCode == OpCode;
			trans.TxnID == local::TxnID;
			trans.Addr == local::Addr;
			trans.SnpAddr == local::Addr >> 3;
			trans.NonSecure == local::NonSecure;
		}) 
	
	endtask // body
	
endclass : chiSnoopSeq
// @ulist/
// @section/

// **************************************************************************************
// @section snpOnceSeq
// @title snpOnceSeq
// @para This sequence extends chiSnoopSeq and sends one SnpOnce snoop.
// **************************************************************************************
class snpOnceSeq extends chiSnoopSeq;

	`uvm_object_utils(snpOnceSeq)

	function new(string name="snpOnceSeq");
		super.new(name);
	endfunction // new
	
	constraint snoop_once_opcode {
		OpCode == DENALI_CHI_SNPOPCODE_SnpOnce;
	}

endclass : snpOnceSeq
// @section/

// **************************************************************************************
// @section snpCleanSeq
// @title snpCleanSeq
// @para This sequence extends chiSnoopSeq and sends one SnpClean snoop.
// **************************************************************************************
class snpCleanSeq extends chiSnoopSeq;

	`uvm_object_utils(snpCleanSeq)

	function new(string name="snpCleanSeq");
		super.new(name);
	endfunction // new
	
	constraint snoop_once_opcode {
		OpCode == DENALI_CHI_SNPOPCODE_SnpClean;
	}

endclass : snpCleanSeq
// @section/

// **************************************************************************************
// @section snpSharedSeq
// @title snpSharedSeq
// @para This sequence extends chiSnoopSeq and sends one SnpShared snoop.
// **************************************************************************************
class snpSharedSeq extends chiSnoopSeq;

	`uvm_object_utils(snpSharedSeq)

	function new(string name="snpSharedSeq");
		super.new(name);
	endfunction // new
	
	constraint snoop_once_opcode {
		OpCode == DENALI_CHI_SNPOPCODE_SnpShared;
	}

endclass : snpSharedSeq
// @section/

// **************************************************************************************
// @section snpUniqueSeq
// @title snpUniqueSeq
// @para This sequence extends chiSnoopSeq and sends one SnpUnique snoop.
// **************************************************************************************
class snpUniqueSeq extends chiSnoopSeq;

	`uvm_object_utils(snpUniqueSeq)

	function new(string name="snpUniqueSeq");
		super.new(name);
	endfunction // new
	
	constraint snoop_once_opcode {
		OpCode == DENALI_CHI_SNPOPCODE_SnpUnique;
	}

endclass : snpUniqueSeq
// @section/

// **************************************************************************************
// @section snpCleanSharedSeq
// @title snpCleanSharedSeq
// @para This sequence extends chiSnoopSeq and sends one SnpCleanShared snoop.
// **************************************************************************************
class snpCleanSharedSeq extends chiSnoopSeq;

	`uvm_object_utils(snpCleanSharedSeq)

	function new(string name="snpCleanSharedSeq");
		super.new(name);
	endfunction // new
	
	constraint snoop_once_opcode {
		OpCode == DENALI_CHI_SNPOPCODE_SnpCleanShared;
	}

endclass : snpCleanSharedSeq
// @section/

// **************************************************************************************
// @section snpCleanInvalidSeq
// @title snpCleanInvalidSeq
// @para This sequence extends chiSnoopSeq and sends one SnpCleanInvalid snoop.
// **************************************************************************************
class snpCleanInvalidSeq extends chiSnoopSeq;

	`uvm_object_utils(snpCleanInvalidSeq)

	function new(string name="snpCleanInvalidSeq");
		super.new(name);
	endfunction // new
	
	constraint snoop_once_opcode {
		OpCode == DENALI_CHI_SNPOPCODE_SnpCleanInvalid;
	}

endclass : snpCleanInvalidSeq
// @section/

// **************************************************************************************
// @section snpMakeInvalidSeq
// @title snpMakeInvalidSeq
// @para This sequence extends chiSnoopSeq and sends one SnpMakeInvalid snoop.
// **************************************************************************************
class snpMakeInvalidSeq extends chiSnoopSeq;

	`uvm_object_utils(snpMakeInvalidSeq)

	function new(string name="snpMakeInvalidSeq");
		super.new(name);
	endfunction // new
	
	constraint snoop_once_opcode {
		OpCode == DENALI_CHI_SNPOPCODE_SnpMakeInvalid;
	}

endclass : snpMakeInvalidSeq
// @section/

// **************************************************************************************
// @section snpDVMOpSeq
// @title snpDVMOpSeq
// @para This sequence sends one SnpDVMOp snoop.
// @ulist
// **************************************************************************************
class snpDVMOpSeq extends cdnChiUvmSequence;
	
	// @listitem This sequence sends an item 'trans' of type 'myChiSnoopTransaction'
	myChiSnoopTransaction trans;
	
	// @listitem The user can control the value of TxnID field.
	rand reg [7:0] TxnID ;

	`uvm_object_utils_begin(snpDVMOpSeq)
		`uvm_field_object(trans, UVM_ALL_ON)
	`uvm_object_utils_end

	`uvm_declare_p_sequencer(cdnChiUvmSequencer)

	function new(string name="snpDVMOpSeq");
		super.new(name);
	endfunction // new

	virtual task body();
		
		`uvm_create(trans);
		
    // @listitem Turns off the address mapping constraint for SnpDVMOp sequence.
    trans.v8_snoop_address_mapping.constraint_mode(0);
		
		`uvm_rand_send_with(trans, {
				trans.SnpOpCode == DENALI_CHI_SNPOPCODE_SnpDVMOp;
				trans.TxnID == local::TxnID;
			}) 
	endtask // body

endclass : snpDVMOpSeq
// @ulist/
// @section/

// @chapter/

// **************************************************************************************
// @chapter ChiScenarioSequences 
// @title CHI Scenario Sequences
// **************************************************************************************

// ****************************************************************************
// @section chiExclusiveSeq
// @title chiExclusiveSeq
// @para This sequence performs an exclusive load operation followed by an exclusive store operation to the same location.
// @ulist
// ****************************************************************************
class chiExclusiveSeq extends cdnChiUvmSequence;
	
	// @listitem This sequence sends one item 'exclLoad' and one item 'exclStore', both of type 'myChiTransaction'
	myChiTransaction exclLoad;
	myChiTransaction exclStore;
	
	// @listitem The user can control the value for TxnID, Addr, NonSecure and Size.
	rand reg [7:0] TxnID ;
	rand reg [43:0] Addr ;
	rand reg NonSecure ;
	rand denaliChiSizeT Size ; // Size of data, associated with the transaction
	
	// @listitem The user can control the Load operation opcode between ReadShared, ReadClean and ReadNoSnp.
	rand denaliChiReqOpCodeT LoadOpCode;
	// @listitem The Store operation opcode is being set according to the Load operation opcode.
	rand denaliChiReqOpCodeT StoreOpCode;

	uvm_sequence_item item;

	constraint exclusive_seq_const {

		LoadOpCode inside 
		{ DENALI_CHI_REQOPCODE_ReadShared, DENALI_CHI_REQOPCODE_ReadClean, DENALI_CHI_REQOPCODE_ReadNoSnp };

		if (LoadOpCode inside { DENALI_CHI_REQOPCODE_ReadShared, DENALI_CHI_REQOPCODE_ReadClean}) {
			Size == DENALI_CHI_SIZE_FULLLINE;
			StoreOpCode == DENALI_CHI_REQOPCODE_CleanUnique;
		}

		if (LoadOpCode == DENALI_CHI_REQOPCODE_ReadNoSnp && Size != DENALI_CHI_SIZE_FULLLINE) {
			StoreOpCode == DENALI_CHI_REQOPCODE_WriteNoSnpPtl;
		}

		if (LoadOpCode == DENALI_CHI_REQOPCODE_ReadNoSnp && Size == DENALI_CHI_SIZE_FULLLINE) {
			StoreOpCode == DENALI_CHI_REQOPCODE_WriteNoSnpFull;
			Addr[5:0] == 6'b000000;
		}

		Size != DENALI_CHI_SIZE_UNSET;
		Size != DENALI_CHI_SIZE_RESERVED7;

		solve LoadOpCode before Size;
		solve Size before StoreOpCode;

	}

	`uvm_object_utils_begin(chiExclusiveSeq)
		`uvm_field_object(exclLoad, UVM_ALL_ON)
		`uvm_field_object(exclStore, UVM_ALL_ON)
	`uvm_object_utils_end

	`uvm_declare_p_sequencer(cdnChiUvmSequencer)

	function new(string name = "chiExclusiveSeq");
		super.new(name);
	endfunction : new 

	task body();

		// @listitem The sequence generates an exclusive load operation
		`uvm_info(get_type_name(), $sformatf("chiExclusiveSeq sequence issuing an exclusive load operation %s", LoadOpCode), UVM_HIGH);
		`uvm_do_with(exclLoad,  {
				exclLoad.ReqOpCode == LoadOpCode;
				exclLoad.Excl == 1;
				exclLoad.Order == 0;
				exclLoad.Size == local::Size;
				exclLoad.Addr == local::Addr;
				exclLoad.NonSecure == local::NonSecure;
				exclLoad.TxnID == local::TxnID;
			})

		// @listitem Blocking sequence. wait until load transaction ends.
		get_response(item, exclLoad.get_transaction_id());
		
		// @listitem The sequence generates an exclusive store operation with the same attributes.
		`uvm_info(get_type_name(), $sformatf("chiExclusiveSeq sequence issuing an exclusive store operation %s", StoreOpCode), UVM_HIGH);
		`uvm_do_with(exclStore,  {
				exclStore.ReqOpCode == StoreOpCode;
				exclStore.Excl == 1;
				exclStore.Order == 0;
				exclStore.Size == local::Size;
				exclStore.Addr == local::Addr;
				exclStore.NonSecure == local::NonSecure;
				exclStore.TxnID == local::TxnID;
				exclStore.MemAttr == exclLoad.MemAttr;
				exclStore.SnpAttr == exclLoad.SnpAttr;
				exclStore.LPID == exclLoad.LPID;
			})

		// @listitem Blocking sequence. wait until store transaction ends.
		get_response(item, exclStore.get_transaction_id());
		
	endtask

endclass : chiExclusiveSeq
// @ulist/
// @section/

// ****************************************************************************
// @section readAfterWriteSeq
// @title readAfterWriteSeq
// @para This sequence performs a write request followed by a read request to the same location.
// @para This sequence also checks that the data returned with the read is the same as the data previously written.
// @ulist
// ****************************************************************************
class readAfterWriteSeq extends cdnChiUvmSequence;
	
	// @listitem This sequence sends one item 'writeReq' and one item 'readReq', both of type 'myChiTransaction'
	myChiTransaction writeReq;
	myChiTransaction readReq;
	
	// @listitem The user can control the value for address, non_secure, txnId and size.
	rand reg [51:0] address;
	rand reg non_secure;
	rand reg[7:0] txnId;
	rand denaliChiSizeT size;

	reg [7:0] writeData [];
	reg writeBE [];

	uvm_sequence_item item;

	constraint base_size_const { 
		size != DENALI_CHI_SIZE_UNSET;
		size != DENALI_CHI_SIZE_RESERVED7;
	}

	`uvm_object_utils(readAfterWriteSeq)
	`uvm_declare_p_sequencer(cdnChiUvmSequencer)

	function new(string name = "readAfterWriteSeq");
		super.new(name);
	endfunction : new 

	task body();
		
		// @listitem The sequence generates a WriteNoSnpPtl request.
		`uvm_info(get_type_name(), "readAfterWriteSeq sequence issuing a WriteNoSnp Request", UVM_HIGH);
		`uvm_do_with(writeReq,  {
				writeReq.ReqOpCode == DENALI_CHI_REQOPCODE_WriteNoSnpPtl;
				writeReq.Size == size;
				writeReq.Addr == address;
				writeReq.NonSecure == non_secure; 
				writeReq.TxnID == txnId;
				writeReq.StashNIDValid ==0;
    		writeReq.Poison ==0;
			})

		// @listitem Blocking sequence. wait until the write transaction ends.
		get_response(item, writeReq.get_transaction_id());
		if (!$cast(writeReq, item)) 
			`uvm_fatal(get_type_name(), "$cast(writeReq, item) call failed!");

		writeData = new[writeReq.Data.size()];
		writeBE = new[writeReq.BE.size()];
		
		// @listitem Keep the write data value for future reference
		for (int i=0; i<writeData.size(); i++) begin
			writeData[i] = writeReq.Data[i];
			writeBE[i] = writeReq.BE[((i/8)*8)+(8-(i%8)-1)];
		end
		
		// @listitem The sequence generates a ReadNoSnp request to the same location.
		`uvm_info(get_type_name(), "readAfterWriteSeq sequence issuing a ReadNoSnp Request", UVM_HIGH);
		`uvm_do_with(readReq,  {
				readReq.ReqOpCode == DENALI_CHI_REQOPCODE_ReadNoSnp;
				readReq.Size == size;
				readReq.Addr == address;
				readReq.NonSecure == non_secure; 
				readReq.TxnID == txnId;
				readReq.MemAttr == writeReq.MemAttr;
			})

		// @listitem Blocking sequence. wait until the read transaction ends.
		get_response(item, readReq.get_transaction_id());
		if (!$cast(readReq, item)) 
			`uvm_fatal(get_type_name(), "$cast(readReq, item) call failed!");

		// @listitem After the completion of the Read request, check for data consistency
                if(writeReq.DataOpCode != DENALI_CHI_DATAOPCODE_WriteDataCancel) begin
	        	for (int i=0; i<readReq.Data.size(); i++) begin 
	        		if (writeBE[i] == 1 && readReq.Data[i] != writeData[i]) begin 
	        			`uvm_fatal(get_type_name(), $sformatf("ERROR: DATA INCONSISTENCY in address (%d)\nData after WRITE: %x\nData after READ: %x",
	        					readReq.Addr+i,writeData[i],readReq.Data[i]));
	        		end
	        	end
		end
		#1000;

	endtask

endclass : readAfterWriteSeq 

