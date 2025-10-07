
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
       if((obj.AiuInfo[pidx].fnNativeInterface == 'ACE') || (obj.AiuInfo[pidx].fnNativeInterface == 'ACE5') ){
         aceaiu_idx += obj.AiuInfo[pidx].nNativeInterfacePorts;
         has_ace  = 1 ;
       } 

   } 

   nGPRA = obj.AiuInfo[0].nGPRA;
   nACE = aceaiu_idx;
   nCHI = chiaiu_idx;

%>
<% if (obj.SNPS) { %>
	bit [(((1<<svt_chi_transaction::SIZE_64BYTE)*8)-1):0] writeData[bit[<%=obj.Widths.Concerto.Ndp.Body.wAddr-1%>:0]];
	bit [((1<<svt_chi_transaction::SIZE_64BYTE)-1):0] writeBE[bit[<%=obj.Widths.Concerto.Ndp.Body.wAddr-1%>:0]],tmp_be[bit[<%=obj.Widths.Concerto.Ndp.Body.wAddr-1%>:0]];

<%}%>
<% if (obj.SNPS == 1) { %>
    time  		latency_new[int][$],min_latency,max_latency,seq_begin_time1;
<% } else { %>
    time  		latency_new[int][int][string],min_latency,max_latency,seq_begin_time1;
<% }   %>
    //time  		latency_new[int][string],min_latency,max_latency,seq_begin_time1;
    int addr_grp[int];
	bit[7:0] dat_que[bit[<%=obj.Widths.Concerto.Ndp.Body.wAddr-1%>:0]];
  //number of GPRA = <%=nGPRA%>
//=========================================================================
class ncore_axi_bw_sequence extends svt_axi_master_base_sequence;
//=========================================================================
  rand int unsigned sequence_length = 10;
  local  svt_axi_master_agent              my_agent;


  /** Constrain the sequence length to a reasonable value */
  constraint reasonable_sequence_length {
    sequence_length == 10;
  }

  rand int some_rand_delay;
  int transaction = 0;
  int cache_value = 4'h0;
  int address_group = 0;
  int is_write = 0;
  int no_ace_init = 0;
  string coherent_command = "READNOSNOOP";
  string protocol,init_type;
  int master_id = 0;
  int txn_no;
  int is_finished = 'h0;
  int qos_value   = 'h0;
  int xacttype = svt_axi_transaction::COHERENT;
  int burstlen = 2;
  int datawidth = svt_axi_transaction::BURST_SIZE_256BIT;
  int transaction_delay = 0;
  bit[<%=obj.wSysAddr-1%>:0] start_addr[int];
  int id_width,cnt1;
  bit[47:0]addr_value = 0;
  int cnt = -1;
  int cnt_id ,cnt_idx,id,burstlen_prev,diff,len1,aiu_id,idx1,idx0,mem_region; 
  int avg_latency,total;



  addr_trans_mgr_pkg::addrMgrConst::sys_addr_csr_t csrq[$];

  `svt_xvm_declare_p_sequencer(svt_axi_master_sequencer)

  `svt_xvm_object_utils_begin(ncore_axi_bw_sequence)
    `svt_xvm_field_int(sequence_length, `SVT_XVM_ALL_ON)
  `svt_xvm_object_utils_end

  function new(string name="ncore_axi_bw_sequence");
    super.new(name);
  endfunction

  virtual task body();
    svt_axi_master_transaction read_tran[];
    bit status,status_nw;
    int num_completed_perf_intervals_for_master,rd,wr;
    `SVT_XVM(component)           my_component;

/** BANDWIDTH_TEST time variable  */
    time  		begin_time;
    time  		seq_end_time1,end_time,latency[],min_latency,max_latency;
    shortreal   	bandwidth1, bandwidth2, bandwidth3, bandwidth4, latency1;
    super.body();

    my_component = p_sequencer.get_parent();
    void'($cast(my_agent,my_component));

    /** Gets the user provided sequence_length. */
`ifdef SVT_UVM_TECHNOLOGY
    status = uvm_config_db#(int unsigned)::get(m_sequencer, get_type_name(), "sequence_length", sequence_length);
`else
    status = m_sequencer.get_config_int({get_type_name(), ".sequence_length"}, sequence_length);
`endif
    `svt_xvm_debug("body", $sformatf("sequence_length is %0d as a result of %0s.", sequence_length, status ? "the config DB" : "randomization"));
    read_tran = new[sequence_length];

    repeat(100) @(posedge ncore_system_tb_top.sys_clk);

    init_type = (protocol=="ACE") ? "CAIU" : "NCAIU" ;
    
    `uvm_info("axi_bw body", $sformatf("mst_id=%0d, data_width=%0d, burst_len=%0d", master_id, datawidth, burstlen), UVM_LOW)

    if($test$plusargs("en_snps_vip_performance_calc"))begin
       status_nw = my_agent.perf_status.start_performance_monitoring();
       if(coherent_command=="READNOSNOOP" ||coherent_command=="READONCE"||coherent_command=="READUNIQUE") rd=1;
       else wr=1;
    end

    for (int i=0; i<sequence_length; i++)begin
     if(start_addr.exists(i)) begin
       fork
          automatic int idx0 = i;
          automatic int idx1 = i; 
    
          /** Set up the read transaction */
          `uvm_create(read_tran[idx0])
          read_tran[idx0].port_cfg = this.cfg;
          read_tran[idx0] = new($sformatf("read_tran_%0d",idx0));

          

          `svt_xvm_do_with(read_tran[idx0],
             {
               addr      == start_addr[idx0];
               //addr      == (addr_trans_mgr_pkg::addrMgrConst::memregions_info[address_group].start_addr + is_finished + (txn_no * idx1));
               addr[5:0] == 0;
               id        == idx0%id_width;
               xact_type == xacttype;
               atomic_type == svt_axi_transaction::NORMAL;
               coherent_xact_type == transaction;
               data_before_addr == 0;
               qos == qos_value;
               burst_size   == datawidth;
               allocate_in_cache == 0;
               cache_type == cache_value;
               prot_type == svt_axi_transaction::DATA_SECURE_NORMAL;
               barrier_type inside {svt_axi_transaction::NORMAL_ACCESS_RESPECT_BARRIER};
               burst_type   == svt_axi_transaction::INCR;
               burst_length == burstlen;
               foreach (wstrb[i]) { wstrb[i]==( 64'h1 << (64'h1<<burst_size) ) -1;}
             })
          read_tran[idx0].wait_end();
       join_none
     end
    end
    wait fork;

    //add for BANDWIDTH_TEST
    for (int i=0; i< sequence_length; i++)begin
      if(start_addr.exists(i)) begin
        begin_time  = read_tran[i].get_begin_time(); 
        end_time  = read_tran[i].get_end_time(); 
        if(latency_new[aiu_id].size()==0) seq_begin_time1 = begin_time/1000;
        latency_new[aiu_id].push_back((end_time - begin_time)); 
      end
    end

    wait(latency_new[aiu_id].size()==txn_no);

   if(is_finished==1)begin
      latency = new[sequence_length];
      for(int k=0; k<sequence_length;k++) begin
       if(latency_new[aiu_id].size()!==0)begin
        latency[k] = latency_new[aiu_id].pop_front() ; 
      end
   end 

    min_latency =  latency[0];
    max_latency =  latency[0];
    for(int i=0; i<sequence_length;i++) begin
      if (latency[i] != null)begin
        if(min_latency > latency[i])
          min_latency =  latency[i];
        if(max_latency < latency[i])
          max_latency =  latency[i];
        total = total + latency[i];
      end
    end
    avg_latency = total / txn_no ;

    seq_end_time1   =  $time;
    bandwidth1 =(txn_no*(2**datawidth)*burstlen*1000000)/((seq_end_time1-seq_begin_time1)*1000);
    latency1   = (seq_end_time1-seq_begin_time1)/txn_no;
    if($test$plusargs("performance_test"))begin
       $display("===============================================================");
       $display("Performance Results");
       $display("===============================================================");
       $display("BANDWIDTH %s %0d to Memory Region %0d %s :%.2f MB/s min_latency %0d ps max_latency %0d ps avg_latency %0d ps",init_type,aiu_id,mem_region,coherent_command,bandwidth1,min_latency,max_latency,avg_latency);
    end

  //  if($test$plusargs("en_snps_vip_performance_calc"))begin
  //     status_nw = my_agent.perf_status.stop_performance_monitoring();
  //       uvm_wait_for_nba_region();
  //     num_completed_perf_intervals_for_master = my_agent.perf_status.get_num_completed_performance_monitoring_intervals() -1;
  //     performance_report(my_agent, num_completed_perf_intervals_for_master,rd,wr);
  //  end
    latency_new[aiu_id].delete();
  end
  endtask: body

  virtual function bit is_applicable(svt_configuration cfg);
    return 1;
  endfunction : is_applicable
endclass

//===================================================================================
class ncore_chi_bw_base_sequence extends svt_chi_rn_transaction_base_sequence;
//===================================================================================
  local svt_chi_rn_agent my_agent;

   /** UVM Object Utility macro */
  `uvm_object_utils(ncore_chi_bw_base_sequence)

    /** Class Constructor */
  extern function new(string name="ncore_chi_bw_base_sequence");

  /** Node configuration obtained from the sequencer */
  svt_chi_node_configuration cfg;

  /** Parameter that controls the number of transactions that will be generated */
  rand int unsigned sequence_length;


  /** Constrain the sequence length to a reasonable value */
  constraint reasonable_sequence_length {
    sequence_length == 10;
  }

  bit[<%=obj.wSysAddr-1%>:0] start_addr[int] ;
  int transaction = 0;
  bit [5:0] cache_value = 5'h0;
  int address_group = 0;
  int is_write = 0;
  string coherent_command = "READNOSNOOP";
  int master_id = 0;
  int txn_no = 0;
  int is_finished = 'h0;
  int qos_value   = 'h0;
  int transaction_delay = 0;
  int id_width;
  int avg_latency,total,rd,wr;
  int cnt_id ,cnt_idx,id,aiu_id,idx1,idx0,mem_region; 

  addr_trans_mgr_pkg::addrMgrConst::sys_addr_csr_t csrq[$];

  `svt_xvm_declare_p_sequencer(svt_chi_rn_transaction_sequencer)

  virtual task body();
    svt_chi_rn_transaction read_tran[];
    int num_completed_perf_intervals_for_master;
    bit status;
    `SVT_XVM(component)           my_component;

/** BANDWIDTH_TEST time variable  */
    time  		begin_time;
    time  		seq_end_time1, end_time,latency[],min_latency,max_latency;
    shortreal   	bandwidth1, latency1;
    super.body();

    my_component = p_sequencer.get_parent();
    void'($cast(my_agent,my_component));

    read_tran = new[sequence_length];

    repeat(100) @(posedge ncore_system_tb_top.sys_clk);

   
    if($test$plusargs("en_snps_vip_performance_calc"))begin
       status = my_agent.perf_status.start_performance_monitoring();
       if(coherent_command=="READNOSNOOP" ||coherent_command=="READONCE"||coherent_command=="READUNIQUE") rd=1;
       else wr=1;
    end

	for (int i=0; i < sequence_length; i++) begin
	if(start_addr.exists(i)) begin
      fork
        automatic int idx0 = i;
        automatic int idx1 = i;

           // Set up the read transaction 
           `uvm_create(read_tran[idx0])
           read_tran[idx0].cfg = this.cfg;
           read_tran[idx0] = new($sformatf("read_tran_%0d",idx0));

           `svt_xvm_do_with(read_tran[idx0],
              {
                //addr             == (csrq[address_group].start_addr + is_finished + (txn_no * idx0));
                addr                               == start_addr[idx0];
                addr[5:0]                          == 0;
                txn_id                             == idx0%id_width;
                qos                                == qos_value;
                is_non_secure_access               == 1'b0;
                data_size                          == svt_chi_transaction::SIZE_64BYTE;
                xact_type                          == transaction;
                byte_enable                        == {`SVT_CHI_MAX_BE_WIDTH{1'b1}};
                is_likely_shared                   == cache_value[0];
                snp_attr_is_snoopable              == cache_value[1];
                mem_attr_is_early_wr_ack_allowed   == cache_value[2];
                mem_attr_is_cacheable              == cache_value[3];
                mem_attr_allocate_hint             ==   cache_value[4];
                exp_comp_ack                       == cache_value[5];
                snp_attr_snp_domain_type           == svt_chi_transaction::INNER;
                mem_attr_mem_type                  == svt_chi_transaction::NORMAL;
                order_type                         == svt_chi_transaction::NO_ORDERING_REQUIRED;
    <% if(has_chib == 1 || has_chie == 1){ %>
                trace_tag == trace_tag;
    <% } %>
              })
    
    
    // add for BANDWIDTH_TEST
   /** Wait for the write transaction to complete */
           read_tran[idx0].wait_end();
           join_none
          end
         end
           wait fork;


// add for BANDWIDTH_TEST
      for(int i=0; i<sequence_length;i++) begin
      if(start_addr.exists(i)) begin
      begin_time  = read_tran[i].get_begin_time(); 
      end_time  = read_tran[i].get_end_time(); 
      if(latency_new[aiu_id].size()==0) seq_begin_time1 = begin_time/1000;
      latency_new[aiu_id].push_back((end_time - begin_time)); 
     end 
     end
	//wait(latency_new[aiu_id].size()==txn_no);

   if(is_finished==1)begin
    latency = new[sequence_length];
    for(int k=0; k<sequence_length;k++) begin
     if(latency_new[aiu_id].size()!==0)begin
      latency[k] = latency_new[aiu_id].pop_front() ; 
    end
    end
    min_latency =  latency[0];
    max_latency =  latency[0];
    for(int i=0; i<sequence_length;i++) begin
        if (latency[i] != null)begin
        if(min_latency > latency[i])
          min_latency =  latency[i];
        if(max_latency < latency[i])
          max_latency =  latency[i];
        total = total + latency[i];
    end
    end
    avg_latency = total / txn_no ;

    seq_end_time1   =  $time;
    bandwidth1 =(txn_no*64*1000000)/((seq_end_time1-seq_begin_time1)*1000);
    latency1   = (seq_end_time1-seq_begin_time1)/txn_no;
    if($test$plusargs("performance_test"))begin
       $display("===============================================================");
       $display("Performance Results");
       $display("===============================================================");
       $display("BANDWIDTH CAIU%0d to Memory Region %0d  %s :%.2f MB/s  min_latency %0d ps max_latency %0d ps avg_latency %0d ps",aiu_id,mem_region,coherent_command,bandwidth1,min_latency,max_latency,avg_latency);
    end

  if($test$plusargs("en_snps_vip_performance_calc"))begin
     status = my_agent.perf_status.stop_performance_monitoring();
       uvm_wait_for_nba_region();
     num_completed_perf_intervals_for_master = my_agent.perf_status.get_num_completed_performance_monitoring_intervals() -1;
     retrieve_perf_metrics("after_perf_mon_stopped", my_agent, num_completed_perf_intervals_for_master, master_id,rd,wr);
  end

  latency_new[aiu_id].delete();
  end
    `uvm_info("body", "Exiting...", UVM_LOW)
  endtask: body

endclass: ncore_chi_bw_base_sequence

function ncore_chi_bw_base_sequence::new(string name="ncore_chi_bw_base_sequence");
  super.new(name);
  //Set the response depth to -1, to accept infinite number of responses
  this.set_response_queue_depth(-1);
endfunction

