  <%var idx = 0; %>
<%if(obj.AiuInfo[idx].fnNativeInterface.includes('CHI')) {%>
<%
//Embedded javascript code to figure number of blocks
   var _child_blkid = [];
   var _child_blk   = [];
   var nGPRA = 0;
   var chiaiu_idx = 0;
   var ioaiu_idx  = 0;
   var aceaiu_idx = 0;
   var has_chib  = 0;
   var has_chia  = 0;
   var has_chie  = 0;
   var has_ace  = 0;
   var nACE = 0;
   var nCHI = 0;


   for(var pidx = 0; pidx < obj.nAIUs; pidx++) {
       if((obj.AiuInfo[pidx].fnNativeInterface == 'CHI-A')||(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-B')||(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-E')) {
       _child_blkid[pidx] = 'chiaiu' + chiaiu_idx;
       _child_blk[pidx]   = 'chiaiu';
       chiaiu_idx++;
       if(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-A') {
        has_chia  = 1;
       }
       if(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-B') {
        has_chib  = 1;
       }
       if(obj.AiuInfo[pidx].fnNativeInterface == 'CHI-E') {
        has_chie  = 1;
       }
       } else {
       _child_blkid[pidx] = 'ioaiu' + ioaiu_idx;
       _child_blk[pidx]   = 'ioaiu';
       ioaiu_idx += obj.AiuInfo[pidx].nNativeInterfacePorts;
       }
       if((obj.AiuInfo[pidx].fnNativeInterface == 'ACE')){
         aceaiu_idx += obj.AiuInfo[pidx].nNativeInterfacePorts;
         has_ace  = 1 ;
       } 

   } 

   nGPRA = obj.AiuInfo[0].nGPRA;
   nACE = aceaiu_idx;
   nCHI = chiaiu_idx;

%>
    time  		latency_new[int][int][string],min_latency,max_latency,seq_begin_time1;
    int addr_grp[int];
    bit[7:0] dat_que[bit[<%=obj.Widths.Concerto.Ndp.Body.wAddr-1%>:0]];

//==================================================
class myChiUvmVirtualSequence extends uvm_sequence;
//==================================================

  `uvm_object_utils(myChiUvmVirtualSequence)

  `uvm_declare_p_sequencer(cdnChiUvmSequencer)

  function new(string name="myChiUvmVirtualSequence");
    super.new(name);
`ifdef UVM_VERSION
   // UVM-IEEE
   set_response_queue_error_report_enabled(0);
`else
   set_response_queue_error_report_disabled(1);
`endif
  endfunction // new

  virtual function void configSeq();
  endfunction : configSeq

  // ***************************************************************
  // Method : pre_body
  // Desc.  : Raise an objection to prevent premature simulation end
  // ***************************************************************
  virtual task pre_body();
`ifdef UVM_POST_VERSION_1_1
    var uvm_phase starting_phase = get_starting_phase();
`endif
    // configure the test
    configSeq();
    if (starting_phase != null)
      starting_phase.raise_objection(this,"seq not finished");
    #1000;
  endtask

  // ***************************************************************
  // Method : post_body
  // Desc.  : Drop the objection raised earlier
  // ***************************************************************
  virtual task post_body();
`ifdef UVM_POST_VERSION_1_1
    var uvm_phase starting_phase = get_starting_phase();
`endif
    if (starting_phase != null) begin
      starting_phase.drop_objection(this);
    end
  endtask

  // ***************************************************************
  // Method : store
  // This store task is first checking the cache line state of the given address.
  // If the line is invalid and the store is partial, it performs a ReadUnique transaction and merge the Store data.
  // If the line is invalid and the store is full line, it performs a MakeUnique transaction and update the line with the StoreData array.
  // If the line is in Shared state, it first issue a MakeUnique/CleanUnique Transaction to aquire line ownership and merge the Store data.
  // If the line is in Unique state, it performs a back-door write with the Store Data without any transactions on the bus.
  // Parameters:
  //    Rn: the Request node component to perform the store operation
  //    Address: <%=obj.Widths.Concerto.Ndp.Body.wAddr-1%> bit start address for the store operation
  //    NonSecure: The secure/non-secure attribute of the desire address.
  //    StoreData: The data byte array input to be stored.
  //    BE: (optional) Bit enable array input for the StoreData array.
  // ***************************************************************
  task store(cdnChiUvmAgent Rn, reg [43:0] Address, bit NonSecure, input reg [7:0] StoreData[] , input reg BE[] = '{64{1}});
	bit PartialStore = 0;
	reg [43:0] AlignedAddr;
	denaliChiCacheLineStateT State;
	reg [5:0] Offset;
	reg [7:0] ReadData [];
	reg ReadBE [];
	reg [7:0] AlignedStoreData [];
	reg AlignedBE [];
	integer CacheLineSize = 64;

	// You can replace the following line.
	// Instead of myChiTransaction, use your own class that extends denaliChiTransaction
	myChiTransaction ChiReq;

	uvm_sequence_item item;
	// Input validity checks
	if (StoreData.size() > CacheLineSize) begin
	  `uvm_fatal(get_type_name(), "store() task invalid input: StoreData array size is bigger than 64 elements.");
	end
	if (BE.size() > CacheLineSize) begin
	  `uvm_fatal(get_type_name(), "store() task invalid input: BE array size is bigger than 64 elements.");
    end
	if (BE.size() != 64 && StoreData.size() != BE.size()) begin
	  `uvm_fatal(get_type_name(), "store() task invalid input: StoreData array and BE array have different sizes.");
    end

	AlignedStoreData = new[CacheLineSize];
	AlignedBE = new[CacheLineSize];

	AlignedAddr = Address / CacheLineSize * CacheLineSize;
	Offset = Address - AlignedAddr;

	// aligning the input data and input BE to cache line boundaries
	for (int i=0; i<CacheLineSize ; i++) begin
	  if (i < StoreData.size()) begin
	    AlignedStoreData[(Offset+i)%CacheLineSize] = StoreData[i];
		AlignedBE[(Offset+i)%CacheLineSize] = BE[i];
		if (BE[i] == 0) begin
		  PartialStore = 1;
	    end
	  end
	  else begin
	    AlignedStoreData[(Offset+i)%CacheLineSize] = 0;
	    AlignedBE[(Offset+i)%CacheLineSize] = 0;
	    PartialStore = 1;
	  end
	end

    // Reading the current cache line state
    Rn.inst.cacheRead(AlignedAddr, State, ReadData, ReadBE, NonSecure);

    case (State)
      DENALI_CHI_CACHELINESTATE_Invalid: begin
		ChiReq = new;
		if (PartialStore) begin
		  `uvm_info(get_type_name(), "== store == Line is not in the cache for partial line store. Sending ReadUnique transaction", UVM_LOW);
		  `uvm_do_on_with(ChiReq, Rn.sequencer, {
		  				ChiReq.ReqOpCode == DENALI_CHI_REQOPCODE_ReadUnique;
		  				ChiReq.Addr == AlignedAddr;
		  				ChiReq.NonSecure == local::NonSecure;
		  });

		  // will wait for the ReadUnique to end.
		    get_response(item, ChiReq.get_transaction_id());

	        `uvm_info(get_type_name(), "== store == The ReadUnique was ended. Merging the data with the partially store data.", UVM_MEDIUM);

		  // Reading the cache line again after ReadUnique
		  Rn.inst.cacheRead(AlignedAddr, State, ReadData, ReadBE, NonSecure);

		  // Merging the read data with the partially store data.
          for (int i=0; i<CacheLineSize ; i++) begin
            if (AlignedBE[i]==0) begin
              AlignedStoreData[i] = ReadData[i];
              AlignedBE[i] = 1;
            end
          end
        end
        else begin
          `uvm_info(get_type_name(), "== store == Line is not in the cache for full line store. Sending MakeUnique transaction", UVM_LOW);
          `uvm_do_on_with(ChiReq, Rn.sequencer, {
                                  ChiReq.ReqOpCode == DENALI_CHI_REQOPCODE_MakeUnique;
                                  ChiReq.Addr == AlignedAddr;
                                  ChiReq.NonSecure == local::NonSecure;
                                  });
          // will wait for the MakeUnique to end.
          get_response(item, ChiReq.get_transaction_id());
        
          `uvm_info(get_type_name(), "== store == The MakeUnique was ended. Overriding the data with the full line store data.", UVM_MEDIUM);
        end

	    // Back-door write the store data to the cache
	    Rn.inst.cacheWrite(AlignedAddr, DENALI_CHI_CACHELINESTATE_UniqueDirty, AlignedStoreData, AlignedBE, NonSecure);
	  end

	  DENALI_CHI_CACHELINESTATE_SharedClean, DENALI_CHI_CACHELINESTATE_SharedDirty: begin
		ChiReq = new;
		if (PartialStore) begin
		  `uvm_info(get_type_name(), "== store == Line is in the cache with Shared state for partial line store. Sending CleanUnique transaction", UVM_LOW);
          `uvm_do_on_with(ChiReq, Rn.sequencer, {
                                  ChiReq.ReqOpCode == DENALI_CHI_REQOPCODE_CleanUnique;
                                  ChiReq.Addr == AlignedAddr;
                                  ChiReq.NonSecure == local::NonSecure;
                                  });
      
          // will wait for the CleanUnique to end.
          get_response(item, ChiReq.get_transaction_id());
          
          `uvm_info(get_type_name(), "== store == The CleanUnique was ended. Merging the existing data with the partially store data.", UVM_MEDIUM);
          
          // Merging the read data with the partially store data.
          for (int i=0; i<CacheLineSize ; i++) begin
            if (AlignedBE[i]==0) begin
              AlignedStoreData[i] = ReadData[i];
              AlignedBE[i] = 1;
            end
          end
        end
        else begin
          `uvm_info(get_type_name(), "== store == Line is in the cache with Shared state for full line store. Sending MakeUnique transaction", UVM_LOW);
          `uvm_do_on_with(ChiReq, Rn.sequencer, {
                                  ChiReq.ReqOpCode == DENALI_CHI_REQOPCODE_MakeUnique;
                                  ChiReq.Addr == AlignedAddr;
                                  ChiReq.NonSecure == local::NonSecure;
                                  });
          
          // will wait for the MakeUnique to end.
          get_response(item, ChiReq.get_transaction_id());
          
          `uvm_info(get_type_name(), "== store == The MakeUnique was ended. Overriding the data with the full line store data.", UVM_MEDIUM);
        end
      
        // Back-door write the store data to the cache
        Rn.inst.cacheWrite(AlignedAddr, DENALI_CHI_CACHELINESTATE_UniqueDirty, AlignedStoreData, AlignedBE, NonSecure);
      end

	  // if the data is already in the cache in unique FULL state
	  DENALI_CHI_CACHELINESTATE_UniqueClean, DENALI_CHI_CACHELINESTATE_UniqueDirty: begin
        `uvm_info(get_type_name(), "== store == Line is in the cache with Unique state. No need to send any transaction", UVM_LOW);
        if (PartialStore) begin
          // Merging the read data with the partially store data.
          for (int i=0; i<CacheLineSize ; i++) begin
            if (AlignedBE[i]==0) begin
              AlignedStoreData[i] = ReadData[i];
              AlignedBE[i] = 1;
            end
          end
        end
        // Back-door write the store data to the cache
        Rn.inst.cacheWrite(AlignedAddr, DENALI_CHI_CACHELINESTATE_UniqueDirty, AlignedStoreData, AlignedBE, NonSecure);
      end

      DENALI_CHI_CACHELINESTATE_UniqueDirtyPartial: begin
        `uvm_info(get_type_name(), "== store == Line is in the cache with UniqueDirtyPartial state. No need to send any transaction", UVM_LOW);
        if (PartialStore) begin
          PartialStore = 0;
          for (int i=0; i<CacheLineSize ; i++) begin
            if (AlignedBE[i]==0 && ReadBE[i]==1) begin
              AlignedStoreData[i] = ReadData[i];
              AlignedBE[i] = 1;
            end
			else if (AlignedBE[i]==0) begin
			  PartialStore = 1;
		    end
		  end
		end
        if (PartialStore) begin
          // Back-door write the partial store data to the cache
          Rn.inst.cacheWrite(AlignedAddr, DENALI_CHI_CACHELINESTATE_UniqueDirtyPartial, AlignedStoreData, AlignedBE, NonSecure);
        end
	    else begin
	      // Back-door write the store data to the cache
	      Rn.inst.cacheWrite(AlignedAddr, DENALI_CHI_CACHELINESTATE_UniqueDirty, AlignedStoreData, AlignedBE, NonSecure);
	    end
	  end

	  DENALI_CHI_CACHELINESTATE_UniqueCleanEmpty: begin
		`uvm_info(get_type_name(), "== store == Line is in the cache with Unique Empty state. No need to send any transaction", UVM_LOW);;
		if (PartialStore) begin
		  // Back-door write the partial store data to the cache
		  Rn.inst.cacheWrite(AlignedAddr, DENALI_CHI_CACHELINESTATE_UniqueDirtyPartial, AlignedStoreData, AlignedBE, NonSecure);
		end
		else begin
		  // Back-door write the store data to the cache
		  Rn.inst.cacheWrite(AlignedAddr, DENALI_CHI_CACHELINESTATE_UniqueDirty, AlignedStoreData, AlignedBE, NonSecure);
		end
	  end
	endcase

	`uvm_info(get_type_name(), " == store == Store operation ended.", UVM_LOW);
  endtask : store

  // ***************************************************************
  // Method : load
  // This load task is checking the cache line state of the given Address. If it is invalid, it performs
  // a ReadShared transaction to read the data and put the result in the LoadData array.
  // If the cache line state is valid and full, it will return the current data from the cache.
  // If the cache line state is valid and partial/empty, it will perform  a ReadUnique transaction
  // and merge the read data with the valid cache data.
  // Parameters:
  //	Rn: the Request node component to perform the load operation
  //    Address: <%=obj.Widths.Concerto.Ndp.Body.wAddr-1%> bit start address for the load operation
  //    NonSecure: The secure/non-secure attribute of the desire address.
  //    LoadData: Reference to the read cache line's data byte array.
  // The LoadData will always be full line (64 bytes) and aligned to cache line boundaries.
  // ***************************************************************
  task load(cdnChiUvmAgent Rn, reg [43:0] Address, bit NonSecure, ref reg [7:0] LoadData []);
    reg [43:0] AlignedAddr;
    reg BE[];
    reg BE2[];
    reg [7:0] MergedData[];
    denaliChiCacheLineStateT State;
    
    // You can replace the following line.
    // Instead of myChiTransaction, use your own class that extends denaliChiTransaction
    myChiTransaction ChiReq;
    
    uvm_sequence_item item;
    
    integer CacheLineSize = 64, status;
    
    AlignedAddr = Address / CacheLineSize * CacheLineSize;
    LoadData = new[CacheLineSize];
    
    ChiReq = new();
    
    // Reading the current cache line
    Rn.inst.cacheRead(AlignedAddr, State, LoadData, BE, NonSecure);

	case (State)
	  DENALI_CHI_CACHELINESTATE_Invalid: begin
	    `uvm_info(get_type_name(), "== load == data is not in the cache. Sending ReadShared transaction", UVM_LOW);
        `uvm_do_on_with(ChiReq, Rn.sequencer, {
                                ChiReq.ReqOpCode == DENALI_CHI_REQOPCODE_ReadShared;
                                ChiReq.Addr == AlignedAddr;
                                ChiReq.NonSecure == local::NonSecure;
                                });

        // will wait for the ReadShared to end.
        get_response(item, ChiReq.get_transaction_id());
        
        `uvm_info(get_type_name(), "== load == The ReadShared was ended and now the cache line is valid", UVM_MEDIUM);
        // Reading the cache line again after ReadShared
        Rn.inst.cacheRead(AlignedAddr, State, LoadData, BE, NonSecure);
      end

      // if the data is already in the cache, this data will be returned.
      // The data was already read above, so nothing to do
      DENALI_CHI_CACHELINESTATE_UniqueClean, DENALI_CHI_CACHELINESTATE_UniqueDirty,
      DENALI_CHI_CACHELINESTATE_SharedClean, DENALI_CHI_CACHELINESTATE_SharedDirty: begin
        `uvm_info(get_type_name(), "== load == data is already in the cache hence no READ transaction will be issued.", UVM_LOW);
      end

      DENALI_CHI_CACHELINESTATE_UniqueDirtyPartial: begin
        `uvm_info(get_type_name(), "== load == data is partially dirty in the cache. Need to read the full line again", UVM_MEDIUM);
        
        `uvm_do_on_with(ChiReq, Rn.sequencer, {
                                ChiReq.ReqOpCode == DENALI_CHI_REQOPCODE_ReadUnique;
                                ChiReq.Addr == AlignedAddr;
                                ChiReq.NonSecure == local::NonSecure;
                                });

        // will wait for the ReadUnique to end.
        get_response(item, ChiReq.get_transaction_id());
        
        `uvm_info(get_type_name(), "== load == The ReadUnique was ended. Merging the data with the partially dirty data.", UVM_MEDIUM);
        
        // Reading the cache line again after ReadUnique
        Rn.inst.cacheRead(AlignedAddr, State, MergedData, BE2, NonSecure);
        
        // Merging the read data with the partially existing data.
        for (int i=0; i<LoadData.size(); i++) begin
          if (BE[i] == 1'b0) begin
            LoadData[i] = MergedData[i];
            BE[i] = 1'b1;
          end
        end
         
        // Writing the full line back to the cache with UniqueDirty state
        Rn.inst.cacheWrite(AlignedAddr, DENALI_CHI_CACHELINESTATE_UniqueDirty, LoadData, BE, NonSecure);
      end

      DENALI_CHI_CACHELINESTATE_UniqueCleanEmpty: begin
        `uvm_info(get_type_name(), "== load == Line is in the cache with UniqueCleanEmpty state. Sending ReadUnique transaction.", UVM_LOW);
        
        `uvm_do_on_with(ChiReq, Rn.sequencer, {
                                ChiReq.ReqOpCode == DENALI_CHI_REQOPCODE_ReadUnique;
                                ChiReq.Addr == AlignedAddr;
                                ChiReq.NonSecure == local::NonSecure;
                                });
      
        // will wait for the ReadUnique to end.
        get_response(item, ChiReq.get_transaction_id());
        
        `uvm_info(get_type_name(), "== load == The ReadUnique was ended and now the cache line is UniqueClean state", UVM_MEDIUM);
        
        // Reading the cache line again after ReadUnique
        Rn.inst.cacheRead(AlignedAddr, State, LoadData, BE, NonSecure);
      end
    endcase

	`uvm_info(get_type_name(), " == load == load operation ended.", UVM_LOW);

  endtask : load

endclass

//==================================================
class readAfterWrite extends myChiUvmVirtualSequence;
//==================================================

  rand bit[<%=obj.wSysAddr-1%>:0] start_addr = 'h0;

  readAfterWriteSeq seq;

  `uvm_object_utils_begin(readAfterWrite)
    `uvm_field_object(seq, UVM_ALL_ON)
  `uvm_object_utils_end

  // ***************************************************************
  // Method : new
  // Desc.  : Call the constructor of the parent class.
  // ***************************************************************
  function new(string name = "readAfterWrite");
    super.new(name);
  endfunction : new

  virtual task body();
    `uvm_info(get_type_name(), "Virtual sequence readAfterWrite started", UVM_LOW);

    // Send multiple transactions
    for (int i=0; i<10; i++) begin
      `uvm_do_on_with(seq, p_sequencer, {
				           seq.address == start_addr + 'h40*i;
				           seq.txnId == i;
			          });
    end

    `uvm_info(get_type_name(), "Finished body of readAfterWrite", UVM_MEDIUM);

  endtask

endclass : readAfterWrite

//==================================================
class chi_base_seq extends cdnChiUvmSequence;
//==================================================

  bit[<%=obj.wSysAddr-1%>:0] start_addr = 'h0;
  int txnid,id_width,seq_len,cnt,cnt1;
  string command;
  int txn_no,is_finished,mem_region,aiu_id ;
  int master_id,transaction_delay = 0;
  int latency[],min_latency,max_latency,avg_latency,total,transaction;
  int cache_value = 'h0;
  myChiTransaction trans;

  uvm_sequence_item item;
  
  
  `uvm_object_utils(chi_base_seq)
  
  `uvm_declare_p_sequencer(cdnChiUvmSequencer)
  
  function new(string name="chi_base_seq");
  	super.new(name);
  endfunction // new

  virtual task body();
/** BANDWIDTH_TEST time variable  */
  time  	seq_end_time1;
  shortreal  	bandwidth1, latency1;
  time  		begin_time;
  time  		end_time,latency[],min_latency,max_latency;
 
    trans = new();
    latency = new[seq_len];
   

    `uvm_info(get_type_name(), "Virtual sequence chi_base_seq started", UVM_MEDIUM);

      //fork
          if(command =="READNOSNOOP")begin
	    `uvm_do_with(trans,  {
	    		ReqOpCode == DENALI_CHI_REQOPCODE_ReadNoSnp;
	    		TxnID == txn_no%id_width;
	    		Addr == start_addr ;
	    		Order == 0 ;
	    		NonSecure == 0 ;
	    		QoS == 0 ;
	    		MemAttr == 1 ;
	    		ExpCompAck == 0 ;
	    		Size == DENALI_CHI_SIZE_FULLLINE;
	    		Type == DENALI_CHI_TR_RequestTransaction;
	    		DynReqFlitDelay == 0;
	    	}) 
          end
          if(command =="READONCE")begin
	    `uvm_do_with(trans,  {
	    		ReqOpCode == DENALI_CHI_REQOPCODE_ReadOnce;
	    		TxnID == txn_no%id_width;
	    		Addr == start_addr;
	    		Order == 0 ;
	    		NonSecure == 0 ;
	    		QoS == 0 ;
	    		MemAttr == 5 ;
	    		Size == DENALI_CHI_SIZE_FULLLINE;
	    		//Type == DENALI_CHI_TR_RequestTransaction;
	    	}) 
          end
          if(command =="READUNIQUE")begin
	    `uvm_do_with(trans,  {
	    		ReqOpCode == DENALI_CHI_REQOPCODE_ReadUnique;
	    		TxnID == txn_no%id_width;
	    		Addr == start_addr ;
	    		Order == 0 ;
	    		NonSecure == 0 ;
	    		QoS == 0 ;
	    		MemAttr == 'hd ;
	    		Size == DENALI_CHI_SIZE_FULLLINE;
	    		//Type == DENALI_CHI_TR_RequestTransaction;
	    	}) 
          end
          if(command =="WRITENOSNOOP")begin
	    `uvm_do_with(trans,  {
	    		ReqOpCode == DENALI_CHI_REQOPCODE_WriteNoSnpPtl;
	    		TxnID == txn_no%id_width;
	    		Addr == start_addr ;
	    		Order == 0 ;
	    		NonSecure == 0 ;
	    		QoS == 0 ;
	    		MemAttr == DENALI_CHI_V8MEMATTR_DEVICE_nGnRE ;
	    		ExpCompAck == 0 ;
	    		Size == DENALI_CHI_SIZE_FULLLINE;
	    	}) 
          end
          if(command =="WRITEUNIQUE")begin
	    `uvm_do_with(trans,  {
	    		ReqOpCode == DENALI_CHI_REQOPCODE_WriteUniqueFull;
	    		TxnID == txn_no%id_width;
	    		Addr == start_addr ;
	    		Order == 0 ;
	    		NonSecure == 0 ;
	    		QoS == 0 ;
	    		MemAttr == (cache_value[4] ? 'hd : 'h5 ) ;
	    		//MemAttr == 5 ;
	    		Size == DENALI_CHI_SIZE_FULLLINE;
	    		ExpCompAck == 0 ;
	    	}) 
          end

          //if(txn_no == 0)
          //  seq_begin_time1 =  $time;

          get_response(item, trans.get_transaction_id());
    

// add for BANDWIDTH_TEST
      begin_time  =trans.StartTime; 
      if(command =="READONCE" || command =="READNOSNOOP" || command =="READUNIQUE" )end_time  = trans.CompDataEndTime; 
      if(command =="WRITENOSNOOP" || command =="WRITEUNIQUE") end_time = trans.WriteDataEndTime ; 
     
      latency_new[txn_no][aiu_id]["CHI"] = (end_time - begin_time) ; 
      if(txn_no==0)seq_begin_time1 =  trans.StartTime;
   if(is_finished==1)begin
    latency = new[seq_len];
    for(int k=0; k<seq_len;k++) begin
      latency[k] = latency_new[k][aiu_id]["CHI"] ; 
    end
    min_latency =  latency[0];
    max_latency =  latency[0];
    for(int i=0; i<seq_len;i++) begin
        if(min_latency > latency[i])
          min_latency =  latency[i];
        if(max_latency < latency[i])
          max_latency =  latency[i];
        total = total + latency[i];
    end
    avg_latency = total / seq_len ;
    
    seq_end_time1   =  $time;
    bandwidth1 =seq_len*64*1000000/(seq_end_time1-seq_begin_time1);
    latency1   = (seq_end_time1-seq_begin_time1)/seq_len;
    if($test$plusargs("performance_test"))begin
       $display("===============================================================");
       $display("Performance Results");
       $display("===============================================================");
       $display("BANDWIDTH CAIU%0d to Memory Region %0d  %s :%.2f MB/s min_latency=%0d ps max_latency=%0d ps avg_latency=%0d ps", master_id,mem_region,command,bandwidth1,min_latency,max_latency,avg_latency);
    end
    end
    `uvm_info(get_type_name(), "Finished body of chi_base_seq", UVM_MEDIUM);

  endtask

endclass : chi_base_seq
<% } %>
