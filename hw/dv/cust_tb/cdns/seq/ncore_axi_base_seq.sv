class ncore_axi_base_seq extends cdnAxiUvmSequence;
    `uvm_object_utils(ncore_axi_base_seq) 
 
	denaliCdn_axiTransaction trans;
    ral_sys_ncore model;
    rand bit[<%=obj.wSysAddr-1%>:0] start_addr = 'h0;
    bit write_txn_req = 'b0;

    int cache_value = 'h0;
    rand denaliCdn_axiWriteSnoopT Write_txn;
    rand denaliCdn_axiReadSnoopT  Read_txn;
    rand denaliCdn_axiDomainT Domain_t;
    rand int unsigned sequence_length;
    int burstlen = 1;
    string command,protocol;
    uvm_sequence_item item;

    constraint reasonable_sequence_length {
        sequence_length == 1;
    }

    function new(string name = "ncore_axi_base_seq");
    super.new(name);
    endfunction

	virtual task body();
        super.body();
        $cast(model, this.model);

        `uvm_info("BASE_SEQ", "Starting ncore_axi_base_seq", UVM_LOW);
        for (int i=0; i<sequence_length; i++) begin
            if(protocol != "AXI4" && command == "WRITE")begin
			    `uvm_do_with(trans,{
                    WriteSnoop == Write_txn;
				    Domain == Domain_t;			
    	            Kind inside {DENALI_CDN_AXI_BURSTKIND_INCR, DENALI_CDN_AXI_BURSTKIND_WRAP};
                    IsBarrier == DENALI_CDN_AXI_ISBARRIER_NOT_BARRIER;
  	                IsDvm == DENALI_CDN_AXI_DVM_NOT_DVM;
				    StartAddress == start_addr + 'h400*i;
                    Secure == DENALI_CDN_AXI_SECUREMODE_SECURE;
    	            WriteAllocate == (cache_value[2] ? DENALI_CDN_AXI_WRITEALLOCATE_WRITE_ALLOCATE :DENALI_CDN_AXI_WRITEALLOCATE_NO_WRITE_ALLOCATE);
    	            Length == burstlen;
                });
            end
            if(protocol != "AXI4" && command == "READ")begin
			    `uvm_do_with(trans,{
                    ReadSnoop == Read_txn;
				    Domain == Domain_t;			
    	            Kind inside {DENALI_CDN_AXI_BURSTKIND_INCR, DENALI_CDN_AXI_BURSTKIND_WRAP};
				    StartAddress == start_addr + 'h400*i;
                    Secure == DENALI_CDN_AXI_SECUREMODE_SECURE;
    	            Length == burstlen;
                });
            end
            if(protocol == "AXI4" && command == "READ")begin
			    `uvm_do_with(trans,{
                    Direction == DENALI_CDN_AXI_DIRECTION_READ;
    	            StartAddress == start_addr ;
    	            Domain == DENALI_CDN_AXI_DOMAIN_NON_SHAREABLE;
    	            Length == burstlen;
    	            Kind inside {DENALI_CDN_AXI_BURSTKIND_INCR};
    	            Secure == DENALI_CDN_AXI_SECUREMODE_SECURE;
    	            DataInstr == DENALI_CDN_AXI_FETCHKIND_DATA;
    	            Privileged == DENALI_CDN_AXI_PRIVILEGEDMODE_NORMAL;
    	            Bufferable == DENALI_CDN_AXI_BUFFERMODE_BUFFERABLE;
    	            Cacheable == DENALI_CDN_AXI_CACHEMODE_CACHEABLE;
    	            ReadAllocate == DENALI_CDN_AXI_READALLOCATE_NO_READ_ALLOCATE;
    	            WriteAllocate == DENALI_CDN_AXI_WRITEALLOCATE_NO_WRITE_ALLOCATE;
			    });
            end
            if(protocol == "AXI4" && command == "WRITE")begin
	            `uvm_do_with(trans,  {
    	            Direction == DENALI_CDN_AXI_DIRECTION_WRITE;
    	            StartAddress == start_addr;
    	            Domain == DENALI_CDN_AXI_DOMAIN_NON_SHAREABLE;
    	            Length == burstlen;
    	            Kind inside { DENALI_CDN_AXI_BURSTKIND_INCR };
    	            Secure == DENALI_CDN_AXI_SECUREMODE_SECURE;
    	            WriteAllocate == (cache_value[2] ? DENALI_CDN_AXI_WRITEALLOCATE_WRITE_ALLOCATE :DENALI_CDN_AXI_WRITEALLOCATE_NO_WRITE_ALLOCATE ) ;
                }); 
              end
            get_response(item, trans.get_transaction_id());
        end
        `uvm_info("BASE_SEQ", "Done ncore_axi_base_seq", UVM_LOW);
    endtask : body

endclass : ncore_axi_base_seq



