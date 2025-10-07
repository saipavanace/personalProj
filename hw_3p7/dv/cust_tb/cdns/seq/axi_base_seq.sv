  <%var idx = 0; %>
<%if(!(obj.AiuInfo[idx].fnNativeInterface.includes('CHI'))) {%>
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
    //time  		latency_new[int][string],min_latency,max_latency,seq_begin_time1;
    int addr_grp[int];
	bit[7:0] dat_que[bit[<%=obj.Widths.Concerto.Ndp.Body.wAddr-1%>:0]];

//==================================================
class axi_base_seq extends cdnAxiUvmSequence;
//==================================================

  bit[<%=obj.wSysAddr-1%>:0] start_addr = 'h0;
  int size,id_width,seq_len,cnt,cnt1,resp,transaction,len,len1;
  int cache_value = 'h0;
  string command,protocol;
  int txn_no,is_finished,mem_region,aiu_id = 0;
  int master_id,transaction_delay = 0;
  int latency[],min_latency,max_latency,avg_latency,total;
  ncore_env env;
  int diff;

  uvm_sequence_item item;

  `uvm_object_utils(axi_base_seq)

  `uvm_declare_p_sequencer(cdnAxiUvmSequencer)

  function new(string name="axi_base_seq");
      super.new(name);
  endfunction // new

  virtual task body();
    denaliCdn_axiTransaction trans;

/** BANDWIDTH_TEST time variable  */
    time  	seq_end_time1,begin_time,end_time;
    shortreal  	bandwidth1, bandwidth2, bandwidth3, bandwidth4,latency1;
    super.body();

    trans = new();
    latency = new[seq_len];


<% if(has_ace == 1){ %>
    if(command =="READUNIQUE" && transaction == 1 && protocol =="ACE")begin
      p_sequencer.pAgent.cfg.memory_segments = {};
      p_sequencer.pAgent.cfg.addToMemorySegments(addr_trans_mgr_pkg::addrMgrConst::memregions_info[0].start_addr,addr_trans_mgr_pkg::addrMgrConst::memregions_info[0].end_addr, DENALI_CDN_AXI_DOMAIN_OUTER);
      p_sequencer.pAgent.reconfigure(p_sequencer.pAgent.cfg);

      env.m_aiuMstAgentPassive0.cfg.memory_segments = {};
      env.m_aiuMstAgentPassive0.cfg.addToMemorySegments(addr_trans_mgr_pkg::addrMgrConst::memregions_info[0].start_addr,addr_trans_mgr_pkg::addrMgrConst::memregions_info[0].end_addr, DENALI_CDN_AXI_DOMAIN_OUTER);
      env.m_aiuMstAgentPassive0.reconfigure(env.m_aiuMstAgentPassive0.cfg);
    end
<% } %>


              if(command =="READNOSNOOP" || (command =="READONCE" && protocol == "AXI4" && !transaction ))begin
	        `uvm_do_with(trans, {
                             Direction == DENALI_CDN_AXI_DIRECTION_READ;
    	                     StartAddress == start_addr ;
    	                     Domain == DENALI_CDN_AXI_DOMAIN_NON_SHAREABLE;
    	                     Size == size + 1;
    	                     Length == (diff ? len1 : len );
    	                     Kind inside {DENALI_CDN_AXI_BURSTKIND_INCR};
    	                     Secure == DENALI_CDN_AXI_SECUREMODE_SECURE;
    	                     DataInstr == DENALI_CDN_AXI_FETCHKIND_DATA;
                             }); 
              end
              if( command =="READONCE" && protocol == "AXI4" && transaction == 1 )begin
	        `uvm_do_with(trans, {
                             Direction == DENALI_CDN_AXI_DIRECTION_READ;
    	                     StartAddress == start_addr ;
    	                     Domain == DENALI_CDN_AXI_DOMAIN_NON_SHAREABLE;
    	                     Size == size + 1;
    	                     Length == (diff ? len1 : len );
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
              if(command =="READONCE" && protocol != "AXI4" )begin
	        `uvm_do_with(trans, {
    	                     ReadSnoop == DENALI_CDN_AXI_READSNOOP_ReadOnce;
    	                     StartAddress == start_addr ;
    	                     Domain inside {DENALI_CDN_AXI_DOMAIN_OUTER};
    	                     Size == size +1 ;
    	                     Length == (diff ? len1 : len );
    	                     Kind inside {DENALI_CDN_AXI_BURSTKIND_INCR};
    	                     Secure == DENALI_CDN_AXI_SECUREMODE_SECURE;
    	                     DataInstr == DENALI_CDN_AXI_FETCHKIND_DATA;
    	                     Privileged == DENALI_CDN_AXI_PRIVILEGEDMODE_NORMAL;
    	                     Bufferable == DENALI_CDN_AXI_BUFFERMODE_NON_BUFFERABLE;
    	                     Cacheable == DENALI_CDN_AXI_CACHEMODE_CACHEABLE;
    	                     ReadAllocate == DENALI_CDN_AXI_READALLOCATE_READ_ALLOCATE;

                             }); 
              end
              if(command =="READUNIQUE" && protocol != "AXI4" )begin
	        `uvm_do_with(trans, {
    	                     ReadSnoop == DENALI_CDN_AXI_READSNOOP_ReadUnique;
    	                     StartAddress == start_addr ;
    	                     Domain inside {DENALI_CDN_AXI_DOMAIN_OUTER};
    	                     Size == size + 1;
    	                     Length == len;
    	                     Kind inside {DENALI_CDN_AXI_BURSTKIND_INCR};
    	                     Secure == DENALI_CDN_AXI_SECUREMODE_SECURE;
    	                     DataInstr == DENALI_CDN_AXI_FETCHKIND_DATA;
    	                     Privileged == DENALI_CDN_AXI_PRIVILEGEDMODE_NORMAL;
    	                     Bufferable == DENALI_CDN_AXI_BUFFERMODE_BUFFERABLE;
    	                     Cacheable == DENALI_CDN_AXI_CACHEMODE_CACHEABLE;
    	                     ReadAllocate == DENALI_CDN_AXI_READALLOCATE_NO_READ_ALLOCATE;
    	                     //WriteAllocate == DENALI_CDN_AXI_WRITEALLOCATE_NO_WRITE_ALLOCATE;
    	                     Barrier == DENALI_CDN_AXI_BARRIER_NORMAL_RESPECTING;

                             }); 
              end
              if(command =="WRITENOSNOOP" || (command =="WRITEUNIQUE" && protocol == "AXI4"))begin
	        `uvm_do_with(trans,  {
    	                     Direction == DENALI_CDN_AXI_DIRECTION_WRITE;
    	                     StartAddress == start_addr;
    	                     Domain == DENALI_CDN_AXI_DOMAIN_NON_SHAREABLE;
    	                     Size == size + 1;
    	                     Length == (diff ? len1 : len );
    	                     Kind inside { DENALI_CDN_AXI_BURSTKIND_INCR };
    	                     Secure == DENALI_CDN_AXI_SECUREMODE_SECURE;
    	                     WriteAllocate == (cache_value[2] ? DENALI_CDN_AXI_WRITEALLOCATE_WRITE_ALLOCATE :DENALI_CDN_AXI_WRITEALLOCATE_NO_WRITE_ALLOCATE ) ;
                             }); 
              end
              if(command =="WRITEUNIQUE" && protocol != "AXI4")begin
	        `uvm_do_with(trans, { 
			     WriteSnoop == DENALI_CDN_AXI_WRITESNOOP_WriteUnique;
    	                     StartAddress == start_addr ;
    	                     Domain inside {DENALI_CDN_AXI_DOMAIN_OUTER,DENALI_CDN_AXI_DOMAIN_INNER};
    	                     Size == size + 1;
    	                     Length == (diff ? len1 : len );
    	                     Kind inside {DENALI_CDN_AXI_BURSTKIND_INCR};
    	                     Secure == DENALI_CDN_AXI_SECUREMODE_SECURE;
    	                     WriteAllocate == (cache_value[2] ? DENALI_CDN_AXI_WRITEALLOCATE_WRITE_ALLOCATE :DENALI_CDN_AXI_WRITEALLOCATE_NO_WRITE_ALLOCATE) ;
                             }); 
              end


              get_response(item, trans.get_transaction_id());


      begin_time  = trans.StartTime; 
      end_time  = trans.EndTime; 
      if(txn_no == 0) seq_begin_time1 =  trans.StartTime;
      //latency[i] = (end_time - begin_time) ; 
      latency_new[txn_no][aiu_id][protocol] = (end_time - begin_time) ; 
   if(is_finished==1)begin
    latency = new[seq_len];
    for(int k=0; k<seq_len;k++) begin
      latency[k] = latency_new[k][aiu_id][protocol] ; 
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

// add for BANDWIDTH_TEST
    seq_end_time1   =  $time;
    bandwidth1 =(seq_len*64*1000000)/((seq_end_time1-seq_begin_time1));
    latency1   = (seq_end_time1-seq_begin_time1)/seq_len;
    
    if($test$plusargs("performance_test"))begin
       $display("===============================================================");
       $display("Performance Results");
       $display("===============================================================");
       $display("BANDWIDTH %s %0d to Memory Region %0d  %s :%.2f MB/s min_latency=%0d ps max_latency=%0d ps avg_latency=%0d ps",((protocol== "ACE") ? "CAIU" : "NCAIU"), master_id,mem_region,command,bandwidth1,min_latency,max_latency,avg_latency);
    end
end
    `uvm_info(get_type_name(), "Finished body of axi_base_seq", UVM_MEDIUM);

  endtask

endclass : axi_base_seq

<% } %>
